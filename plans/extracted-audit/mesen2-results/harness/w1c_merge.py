#!/usr/bin/env python3
"""Merged W1-c report: raw/W1c_*_<date>.json -> raw/W1c_report.md and raw/W1c_merged.json.

Maps every logged K:PC to the instruction that ENDS at the PC (tags `; {n}` of extracted/), names the routine, merges counts, scenes, values,
exec marks, value probes, snapshots over all sessions, decodes the caller descriptors of the flag helpers (COP handler -> COP site through
the static inventory plans/flags/inventory.json; native JSR callers through the tags) and lists the static sites with their runtime hits.

usage: w1c_merge.py [--date YYYYMMDD] [--out path]
"""
import argparse
import bisect
import glob
import json
import os
import re
import time
from collections import defaultdict

import w1a_report as R

RAW = R.RAW
INV = os.path.join(R.BASEROM, "plans", "flags", "inventory.json")

# watch name -> (lo, hi) for the static census (operand names an address in the range; word access at lo-1 counts)
R.WATCH_RANGES.update({
    "0A00": (0x0A00, 0x0A00),
    "0A80-0AA7": (0x0A80, 0x0AA7),
    "0AEC-0AEF": (0x0AEC, 0x0AEF),
})
STATIC_NAMES = ["0A00", "0A80-0AA7", "0AEC-0AEF"]
BASE_OF = {"0A00 bit0 change": "0A00", "0A80-0AA7 change": "0A80-0AA7", "0AEC-0AEF change": "0AEC-0AEF"}
STORES = ("STA", "STX", "STY", "STZ")
RMW = ("INC", "DEC", "ASL", "LSR", "ROL", "ROR", "TSB", "TRB")
COP_HELPER_NAMES = ("SetFlagByte", "ClearFlagByte", "BranchOnFlagByte", "WaitOnFlagByte", "SetFlagWord", "ClearFlagWord", "BranchOnFlagWord", "WaitOnFlagWord")


def load_sessions(date):
    out = []
    for p in sorted(glob.glob(os.path.join(RAW, "W1c_*_%s.json" % date))):
        base = os.path.basename(p)
        if base.startswith(("W1c_merged", "W1c_report", "W1c_run")):
            continue
        with open(p, encoding="utf-8") as f:
            d = json.load(f)
        if "census" in d:
            c = d["census"]
            if isinstance(c, str):
                c = json.loads(c)
            if not isinstance(c, dict) or "rows" not in c:
                raise SystemExit("%s: census has no rows (truncated or failed run); the file is not merged" % base)
            out.append(dict(name="natural_fr10", final=c, frames=d.get("inputFrames"), h1=d["h1"], scene=d.get("endScene"), rom=d.get("rom"), seconds=d.get("seconds")))
        else:
            if not d.get("final"):
                continue
            out.append(dict(name=d["session"]["name"], final=d["final"], frames=d.get("frames"), h1=d["h1"], scene=d.get("scene") or d["final"].get("endScene"),
                            rom=d.get("rom"), seconds=d.get("seconds")))
    return out


def addto(dst, src_list):
    for k, v in src_list:
        dst[k] = dst.get(k, 0) + v


def merge(sessions):
    rows, pairs, execs, probes = {}, {}, {}, {}
    ctl = dict(ctl36=0, nmi=0, frames=0)
    scenes_seen = defaultdict(int)
    for s in sessions:
        f = s["final"]
        ctl["ctl36"] += f.get("control36Writes", 0)
        ctl["nmi"] += f.get("nmiExecs", 0)
        ctl["frames"] += f.get("frames", 0) or 0
        for k, v in f.get("sceneFrames", []):
            scenes_seen[k] += v
        for r in f["rows"]:
            e = rows.setdefault(r["key"], dict(key=r["key"], name=r["name"], kind=r["kind"], pc=r["pc"], n=0, sessions={}, scenes={}, addrs={}, vals={}, ctx={}))
            e["n"] += r["n"]
            e["sessions"][s["name"]] = e["sessions"].get(s["name"], 0) + r["n"]
            addto(e["scenes"], r.get("scenes", []))
            addto(e["addrs"], r.get("addrs", []))
            addto(e["vals"], r.get("vals", []))
            addto(e["ctx"], r.get("ctx", []))
        for r in f.get("pairs", []):
            e = pairs.setdefault(r["key"], dict(key=r["key"], n=0, sessions={}))
            e["n"] += r["n"]
            e["sessions"][s["name"]] = e["sessions"].get(s["name"], 0) + r["n"]
        for x in f.get("execs", []):
            e = execs.setdefault(x["name"], dict(off=x["off"], n=0, sessions={}, scenes={}))
            e["n"] += x.get("n", 0)
            if x.get("n"):
                e["sessions"][s["name"]] = x["n"]
            addto(e["scenes"], x.get("scenes", []))
        for x in f.get("probes", []):
            e = probes.setdefault(x["name"], dict(off=x["off"], addr=x["addr"], size=x["size"], n=0, vals={}, scenes={}, sessions={}))
            e["n"] += x.get("n", 0)
            if x.get("n"):
                e["sessions"][s["name"]] = x["n"]
            addto(e["vals"], x.get("vals", []))
            addto(e["scenes"], x.get("scenes", []))
    return rows, pairs, execs, probes, ctl, scenes_seen


def fmt_sessions(d, top=4):
    items = sorted(d.items(), key=lambda kv: -kv[1])
    s = ", ".join("%s %s" % (k, v) for k, v in items[:top])
    return s + (" (+%d)" % (len(items) - top) if len(items) > top else "")


def fmt_scenes(d, top=10):
    items = sorted(d.items(), key=lambda kv: int(kv[0]))
    s = " ".join("%02X" % int(k) for k, _ in items[:top])
    return "%d: %s" % (len(items), s) + (" ..." if len(items) > top else "")


class Decoder:
    def __init__(self, tags, tag_keys, names, nkeys):
        self.tags, self.tag_keys, self.names, self.nkeys = tags, tag_keys, names, nkeys
        with open(INV, encoding="utf-8") as f:
            inv = json.load(f)
        self.sites = defaultdict(list)
        for s in inv["sites"]:
            if s["kind"] == "cop":
                self.sites[s["opcode"]].append(s)
        for v in self.sites.values():
            v.sort(key=lambda s: s["offset"])
        self.resolved = {}

    def routine(self, off):
        return R.routine(self.names, self.nkeys, off)

    def resolve_pc(self, pc):
        if pc in self.resolved:
            return self.resolved[pc]
        k, p = (int(x, 16) for x in pc.split(":"))
        end = R.rom_offset(k, p)
        if end is None:
            r = dict(off=None, text="(not ROM: bank %02X pc %04X)" % (k, p), where="", routine="?")
        else:
            off = R.instr_ending_at(self.tag_keys, end)
            if off is None:
                r = dict(off=None, end=end, text="(no tagged instruction ends at %d)" % end, where="", routine=self.routine(end))
            else:
                t = self.tags[off]
                r = dict(off=off, end=end, text=t["text"], where="%s:%d" % (t["file"], t["line"]), routine=self.routine(off), tag=t)
        self.resolved[pc] = r
        return r

    def caller(self, desc):
        """Decode `i=XXXX s=AAAA,BBBB,CC [cop=BB:PPPP]`: the COP site (static inventory), else the native JSR caller, else the raw descriptor."""
        m = re.match(r"i=([0-9A-F]{4}) s=([0-9A-F]{4}),([0-9A-F]{4}),([0-9A-F]{2})(?: cop=([0-9A-F]{2}):([0-9A-F]{4}))?$", desc)
        if not m:
            return dict(kind="other", text=desc)
        idx, s0, s1, s2 = int(m.group(1), 16), int(m.group(2), 16), int(m.group(3), 16), int(m.group(4), 16)
        jsr = s0 - 2  # JSR pushes the address of its last byte: the instruction starts two bytes earlier
        tg = self.tags.get(jsr)
        handler = None
        if tg is not None and tg["text"].upper().startswith("JSR"):
            handler = re.sub(r"\+\d+$", "", self.routine(jsr))
        if m.group(5) is not None:
            bank, a = int(m.group(5), 16), int(m.group(6), 16)
            base = ((bank & 0x3F) << 16) | a
            cands = [s for s in self.sites.get(handler or "", []) if s["offset"] <= base - 2 and s["offset"] >= base - 9 and s["index"] == idx]
            if not cands and handler is None:
                cands = [s for op in COP_HELPER_NAMES for s in self.sites.get(op, []) if base - 9 <= s["offset"] <= base - 2 and s["index"] == idx]
            if cands:
                s = max(cands, key=lambda s: s["offset"])
                return dict(kind="cop", off=s["offset"], text="%s ( %s )" % (s["opcode"], s["operands"]), where="%s:%d" % (s["file"], s["line"]), idx=idx,
                            handler=handler)
            return dict(kind="cop?", off=None, text="COP in bank %02X, operand pointer %04X (offset %d), handler %s: no inventory site within 9 bytes (flag index varies)" % (
                bank, a, base, handler), where="", idx=idx, handler=handler)
        if tg is not None:
            return dict(kind="native", off=jsr, text=tg["text"], where="%s:%d" % (tg["file"], tg["line"]), idx=idx, handler=handler)
        return dict(kind="raw", off=None, text="stack %04X,%04X,%02X (no COP, no tagged JSR at the return address; flag index varies)" % (s0, s1, s2), where="", idx=idx, handler=None)


def main(args):
    date = args.date or time.strftime("%Y%m%d")
    out = args.out or os.path.join(RAW, "W1c_report.md")
    sessions = load_sessions(date)
    tags = R.load_tags()
    tag_keys = sorted(tags)
    names, nkeys = R.load_names()
    dec = Decoder(tags, tag_keys, names, nkeys)
    rows, pairs, execs, probes, ctl, scenes_seen = merge(sessions)

    L = ["# W1-c merged census (%s)\n" % date]
    L.append("sessions: %d; frames (sum of per-session frame counters): %d; $36 write control: %d; NMI exec control: %d\n" % (len(sessions), ctl["frames"], ctl["ctl36"], ctl["nmi"]))
    L.append("## Sessions\n")
    L.append("| session | frames | end scene | H1 (k, sp, scene) | hits | $36 writes | NMI execs | seconds |")
    L.append("|---|---|---|---|---|---|---|---|")
    for s in sessions:
        h = s["h1"]
        L.append("| %s | %s | %02X | %02X %04X %02X | %s | %s | %s | %s |" % (s["name"], s["frames"], (s["scene"] or 0), h.get("k") or 0, h.get("sp") or 0,
                                                                              h.get("scene") or 0, s["final"].get("hits"), s["final"].get("control36Writes"), s["final"].get("nmiExecs"),
                                                                              s.get("seconds")))
    L.append("")
    L.append("## Scenes visited (frames, sum)\n")
    L.append(" ".join("%02X:%d" % (int(k), v) for k, v in sorted(scenes_seen.items(), key=lambda kv: int(kv[0]))) + "\n")
    L.append("## Scene sequences (per session)\n")
    for s in sessions:
        L.append("- %s: %s" % (s["name"], " ".join(s["final"].get("sceneSeq") or [])))
    L.append("")

    merged = dict(ctl=ctl, rows=[], pairs=[], execs=execs, probes=probes, sessions=[s["name"] for s in sessions], scenes=dict(scenes_seen), callers=[], snaps={})
    watch_names = []
    for r in rows.values():
        if r["name"] not in watch_names:
            watch_names.append(r["name"])
    order = ["0A00", "0A00 bit0 change", "0A80-0AA7", "0A80-0AA7 change", "0AEC-0AEF", "0AEC-0AEF change"]
    watch_names.sort(key=lambda n: order.index(n) if n in order else 99)

    for wname in watch_names:
        L.append("## %s\n" % wname)
        L.append("| kind | offset | file:line | instruction | routine | count | sessions | scenes | addrs | values | changes (old>new) |")
        L.append("|---|---|---|---|---|---|---|---|---|---|---|")
        agg = {}
        for key, e in rows.items():
            if e["name"] != wname:
                continue
            r = dec.resolve_pc(e["pc"])
            g = agg.setdefault((e["kind"], r.get("off"), e["pc"] if r.get("off") is None else ""), dict(r=r, n=0, sessions={}, scenes={}, addrs={}, vals={}, ctx={}, kind=e["kind"]))
            g["n"] += e["n"]
            for src, dst in ((e["sessions"], g["sessions"]), (e["scenes"], g["scenes"]), (e["addrs"], g["addrs"]), (e["vals"], g["vals"]), (e["ctx"], g["ctx"])):
                for k_, v_ in src.items():
                    dst[k_] = dst.get(k_, 0) + v_
        callers_by_row = []
        for key, g in sorted(agg.items(), key=lambda kv: (kv[0][0], kv[0][1] or 0)):
            r = g["r"]
            addrs = ",".join("%04X:%d" % (int(a), c) for a, c in sorted(g["addrs"].items()))
            vals = ",".join("%02X:%d" % (int(v), c) for v, c in sorted(g["vals"].items()))
            chg = "; ".join("%s:%d" % (k.replace("x:", ""), c) for k, c in sorted(g["ctx"].items(), key=lambda kv: -kv[1]) if k.startswith("x:"))[:160]
            L.append("| %s | %s | %s | %s | %s | %d | %s | %s | %s | %s | %s |" % (g["kind"], r.get("off"), r["where"], r["text"], r["routine"], g["n"], fmt_sessions(g["sessions"]),
                                                                              fmt_scenes(g["scenes"]), addrs[:100], vals[:80], chg))
            merged["rows"].append(dict(watch=wname, kind=g["kind"], pc=key[2], off=r.get("off"), where=r["where"], text=r["text"], routine=r["routine"], n=g["n"],
                                       sessions=g["sessions"], scenes=g["scenes"], addrs=g["addrs"], vals=g["vals"], changes={k: c for k, c in g["ctx"].items() if k.startswith("x:")}))
            cl = {}
            for k, c in g["ctx"].items():
                if k.startswith("x:"):
                    continue
                d = dec.caller(k)
                ck = (d["kind"], d.get("off"), d["text"], d.get("where"))
                cl[ck] = cl.get(ck, 0) + c
            if cl:
                callers_by_row.append((g, r, cl))
        L.append("")
        for g, r, cl in callers_by_row:
            L.append("Callers of %s at offset %s (%s), top by count (descriptors are capped per row, counts are lower bounds):\n" % (g["kind"], r.get("off"), r["text"]))
            L.append("| caller kind | site offset | file:line | site | count |")
            L.append("|---|---|---|---|---|")
            for ck, c in sorted(cl.items(), key=lambda kv: -kv[1])[:40]:
                L.append("| %s | %s | %s | %s | %d |" % (ck[0], ck[1], ck[3] or "", ck[2], c))
                merged["callers"].append(dict(watch=wname, kind=g["kind"], helper_off=r.get("off"), caller_kind=ck[0], site=ck[1], where=ck[3], text=ck[2], n=c))
            L.append("")

    # static census
    rt = defaultdict(int)
    for e in rows.values():
        r = dec.resolve_pc(e["pc"])
        if r.get("off") is not None:
            wn = BASE_OF.get(e["name"], e["name"])
            if e["name"] in STATIC_NAMES:
                rt[(wn, r["off"])] += e["n"]
    L.append("## Static census (operand names a watched address) with runtime count\n")
    static_rows = []
    for wname in STATIC_NAMES:
        L.append("### %s\n" % wname)
        L.append("| offset | file:line | instruction | routine | access | runtime hits (all sessions) |")
        L.append("|---|---|---|---|---|---|")
        for off in tag_keys:
            t = tags[off]
            if not R.static_hit(t, wname):
                continue
            mn = t["text"].split(None, 1)[0].upper() if t["text"] else ""
            acc = "write" if mn in STORES else ("read+write" if mn in RMW and len(t["text"].split()) > 1 else "read")
            n = rt.get((wname, off), 0)
            L.append("| %d | %s:%d | %s | %s | %s | %s |" % (off, t["file"], t["line"], t["text"], dec.routine(off), acc, n))
            static_rows.append(dict(watch=wname, off=off, where="%s:%d" % (t["file"], t["line"]), text=t["text"], routine=dec.routine(off), access=acc, runtime=n))
        L.append("")
    merged["static"] = static_rows

    # COP sites that name flags 0-7 (byte $0A00) / flag #00: static list with runtime attribution through the callers
    seen_sites = defaultdict(int)
    for c in merged["callers"]:
        if c["caller_kind"] == "cop" and c["site"] is not None:
            seen_sites[c["site"]] += c["n"]
    L.append("## COP sites on flag #00 (static inventory) and runtime attribution\n")
    L.append("Runtime counts come from the helper callers decoded above (a lower bound: descriptors are capped per instruction row).\n")
    L.append("| offset | file:line | COP | scenes (static) | runtime attributed hits |")
    L.append("|---|---|---|---|---|")
    with open(INV, encoding="utf-8") as f:
        inv = json.load(f)
    for s in sorted([s for s in inv["sites"] if s["kind"] == "cop" and s["width"] == "byte" and s["index"] == 0], key=lambda s: s["offset"]):
        L.append("| %d | %s:%d | %s ( %s ) | %s | %d |" % (s["offset"], s["file"], s["line"], s["opcode"], s["operands"], ",".join("%02X" % x for x in s.get("scenes", [])[:12]),
                                                         seen_sites.get(s["offset"], 0)))
    L.append("")

    L.append("## Read <- last writer pairs\n")
    L.append("| watch | reader off | reader instr | <- last writer off | writer instr | count | sessions |")
    L.append("|---|---|---|---|---|---|---|")
    pagg = {}
    for key, e in sorted(pairs.items()):
        m = re.match(r"(.+?) read (\S+) <- (\S+)$", key)
        if not m:
            continue
        rd = dec.resolve_pc(m.group(2))
        wr = dec.resolve_pc(m.group(3)) if m.group(3) != "init" else dict(off="init", text="(no write seen in this run)")
        g = pagg.setdefault((m.group(1), rd.get("off"), wr.get("off")), dict(rd=rd, wr=wr, n=0, sessions={}))
        g["n"] += e["n"]
        for k_, v_ in e["sessions"].items():
            g["sessions"][k_] = g["sessions"].get(k_, 0) + v_
    for (wn, ro, wo), g in sorted(pagg.items(), key=lambda kv: (kv[0][0], kv[0][1] or 0, str(kv[0][2]))):
        L.append("| %s | %s | %s | %s | %s | %d | %s |" % (wn, ro, g["rd"]["text"], wo, g["wr"]["text"], g["n"], fmt_sessions(g["sessions"], 3)))
        merged["pairs"].append(dict(watch=wn, n=g["n"], reader=ro, writer=wo))
    L.append("")

    L.append("## Exec marks\n")
    L.append("| name | offset | count | sessions | scenes |")
    L.append("|---|---|---|---|---|")
    for name, e in sorted(execs.items()):
        L.append("| %s | %s | %d | %s | %s |" % (name, e.get("off"), e["n"], fmt_sessions(e["sessions"], 6), fmt_scenes(e["scenes"], 14)))
    L.append("")
    L.append("## Value probes (value at each execution of the instruction, as value@scene:count)\n")
    for name, e in sorted(probes.items()):
        if not e["n"]:
            L.append("- %s (off %s, WRAM %04X): 0 executions" % (name, e["off"], e["addr"]))
            continue
        vs = ", ".join("%0*X@%s:%d" % (4 if e["size"] == 2 else 2, int(k.split("@")[0]), k.split("@")[1], c) for k, c in sorted(e["vals"].items(), key=lambda kv: -kv[1])[:30])
        L.append("- %s (off %s, WRAM %04X, size %d): %d executions (%s): %s" % (name, e["off"], e["addr"], e["size"], e["n"], fmt_sessions(e["sessions"], 4), vs))
    L.append("")

    L.append("## Snapshots (trial sessions)\n")
    for s in sessions:
        snaps = s["final"].get("snaps") or []
        if not snaps:
            continue
        merged["snaps"][s["name"]] = snaps
        L.append("### %s\n" % s["name"])
        L.append("| label | frame | scene | next | enemies | enemiesBcd | $0A00 | $0A1F | form | wramFlags $0A80-$0AA7 |")
        L.append("|---|---|---|---|---|---|---|---|---|---|")
        for sn in snaps:
            wf = sn.get("wramFlags", "")
            wf = " ".join(wf[i:i + 2] for i in range(0, len(wf), 2))
            L.append("| %s | %s | %02X | %02X | %s | %s | %04X | %02X | %s | %s |" % (sn.get("label"), sn.get("frame"), sn.get("scene", 0), sn.get("next", 0), sn.get("enemies"),
                                                                                 sn.get("enemiesBcd"), sn.get("a00", 0), sn.get("a1F", 0), sn.get("form"), wf))
        L.append("")

    with open(out, "w", encoding="utf-8") as f:
        f.write("\n".join(L) + "\n")
    with open(os.path.join(RAW, "W1c_merged.json"), "w", encoding="utf-8") as f:
        json.dump(merged, f, indent=1, default=str)
    print("wrote", out, len(L), "lines")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--date", default=None)
    ap.add_argument("--out", default=None)
    main(ap.parse_args())
