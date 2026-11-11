#!/usr/bin/env python3
"""Merged W1-d report: raw/W1d_*_<date>.json -> raw/W1d_report.md and raw/W1d_merged.json.

Maps every logged K:PC to the instruction that ENDS at the PC (tags `; {n}` of extracted/), names the routine, merges counts, scenes, addresses, values,
exec marks, value probes and snapshots over all sessions, and compares the runtime hits per watch with the static list of w1d_static.py.

usage: w1d_merge.py [--date YYYYMMDD ...] [--out path]
"""
import argparse
import glob
import json
import os
import re
import sys
import time
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import w1a_report as R  # noqa: E402
import w1d_static as ST  # noqa: E402

RAW = R.RAW
DMA_TEXT = re.compile(r"\$(420B|420C|MDMAEN|HDMAEN)|dma", re.I)

# watch name -> (static group names that list its sites, static address range (WRAM low 16 bits) or None for "all rows of the group")
STATIC_OF = {
    "7F0000-00FF": ("7F0000-01FF", (0x0000, 0x00FF)),
    "7F0100-01FF": ("7F0000-01FF", (0x0100, 0x01FF)),
    "7F0200-09FF": ("7F0200-09FF", (0x0200, 0x09FF)),
    "7F0B22-0B25": ("7F0A00-0BFF", (0x0B22, 0x0B25)),
    "7F0C00-0C02": ("7F0C00-0CFF", (0x0C00, 0x0C02)),
    "7F0E00-0EFF": ("7F0E00-0FFF", (0x0E00, 0x0EFF)),
    "7F3000-30FF": ("7F3000-31FF", (0x3000, 0x30FF)),
    "7F0010,X orbitAngle": ("7F0000-01FF", (0x0010, 0x0011)),
    "7F0020,X statsPtr": ("7F0000-01FF", (0x0020, 0x0021)),
    "player 7F0010": ("7F0000-01FF", (0x0010, 0x0011)),
    "player 7F0020": ("7F0000-01FF", (0x0020, 0x0021)),
}
WATCH_ORDER = ["7F0000-00FF", "7F0100-01FF", "7F0010,X orbitAngle", "7F0020,X statsPtr", "player 7F0010", "player 7F0020", "7F0200-09FF", "7F0B22-0B25", "7F0C00-0C02",
               "7F0E00-0EFF", "7F3000-30FF", "00B2-00B3", "00F4-00F5", "00F8-00F9", "0672-0677"]


def load_sessions(dates):
    out = []
    for date in dates:
        for p in sorted(glob.glob(os.path.join(RAW, "W1d_*_%s.json" % date))):
            base = os.path.basename(p)
            if base.startswith(("W1d_merged", "W1d_report", "W1d_run", "W1d_static")):
                continue
            with open(p, encoding="utf-8") as f:
                d = json.load(f)
            if "census" in d:
                c = d["census"]
                if isinstance(c, str):
                    c = json.loads(c)
                if not isinstance(c, dict) or "rows" not in c:
                    raise SystemExit("%s: census has no rows (truncated or failed run); the file is not merged" % base)
                out.append(dict(name="natural_fr10", final=c, frames=d.get("inputFrames"), h1=d["h1"], scene=d.get("endScene"), rom=d.get("rom"), seconds=d.get("seconds"),
                                session={}))
            else:
                if not d.get("final"):
                    continue
                out.append(dict(name=d["session"]["name"], final=d["final"], frames=d.get("frames"), h1=d["h1"], scene=d.get("scene") or d["final"].get("endScene"),
                                rom=d.get("rom"), seconds=d.get("seconds"), session=d["session"]))
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
            e = rows.setdefault(r["key"], dict(key=r["key"], name=r["name"], kind=r["kind"], pc=r["pc"], n=0, sessions={}, scenes={}, addrs={}, vals={}, ctx={}, amin=r["amin"],
                                               amax=r["amax"]))
            e["n"] += r["n"]
            e["amin"], e["amax"] = min(e["amin"], r["amin"]), max(e["amax"], r["amax"])
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
        self.resolved = {}

    def routine(self, off):
        return R.routine(self.names, self.nkeys, off)

    def is_dma_store(self, off):
        t = self.tags.get(off)
        return t is not None and re.match(r"(STA|STX|STY|STZ)", t["text"], re.I) is not None and re.search(r"\$(420B|420C|MDMAEN|HDMAEN)", t["text"], re.I) is not None

    def resolve_pc(self, pc):
        """The instruction that ENDS at the PC; a DMA / HDMA callback reports the CPU one byte into the instruction after the $420B / $420C store
        (the opcode is fetched, then the transfer runs): such a PC is attributed to that store and flagged dma."""
        if pc in self.resolved:
            return self.resolved[pc]
        k, p = (int(x, 16) for x in pc.split(":"))
        end = R.rom_offset(k, p)
        if end is None:
            r = dict(off=None, text="(not ROM: bank %02X pc %04X)" % (k, p), where="", routine="?", dma=False)
        else:
            r = None
            for cand in (end - 1, end):
                if cand in self.tags:
                    i = self.tag_keys.index(cand) if cand in self.tag_keys else -1
                    prev = self.tag_keys[i - 1] if i > 0 else None
                    if prev is not None and self.is_dma_store(prev):
                        t = self.tags[prev]
                        r = dict(off=prev, end=end, text=t["text"] + " [DMA trigger: callback PC is after the next opcode]", where="%s:%d" % (t["file"], t["line"]),
                                 routine=self.routine(prev), tag=t, dma=True)
                        break
            if r is None:
                off = R.instr_ending_at(self.tag_keys, end)
                if off is None:
                    r = dict(off=None, end=end, text="(no tagged instruction ends at %d)" % end, where="", routine=self.routine(end), dma=False)
                else:
                    t = self.tags[off]
                    r = dict(off=off, end=end, text=t["text"], where="%s:%d" % (t["file"], t["line"]), routine=self.routine(off), tag=t, dma=False)
        self.resolved[pc] = r
        return r


def main(args):
    dates = args.date or [time.strftime("%Y%m%d")]
    out = args.out or os.path.join(RAW, "W1d_report.md")
    sessions = load_sessions(dates)
    tags = R.load_tags()
    tag_keys = sorted(tags)
    names, nkeys = R.load_names()
    dec = Decoder(tags, tag_keys, names, nkeys)
    rows, pairs, execs, probes, ctl, scenes_seen = merge(sessions)
    srows, _, _, _ = ST.scan()

    L = ["# W1-d merged census (%s)\n" % ", ".join(dates)]
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

    merged = dict(ctl=ctl, rows=[], pairs=[], execs=execs, probes=probes, sessions=[s["name"] for s in sessions], scenes=dict(scenes_seen), snaps={}, static=[], compare=[])
    watch_names = []
    for r in rows.values():
        if r["name"] not in watch_names:
            watch_names.append(r["name"])
    watch_names.sort(key=lambda n: WATCH_ORDER.index(n) if n in WATCH_ORDER else 99)

    runtime_offs = defaultdict(lambda: defaultdict(int))   # watch -> instruction offset -> count
    for wname in watch_names:
        L.append("## %s\n" % wname)
        L.append("| kind | offset | file:line | instruction | routine | count | sessions | scenes | addrs (distinct, first 12) | values (max 8) | DMA? |")
        L.append("|---|---|---|---|---|---|---|---|---|---|---|")
        agg = {}
        for key, e in rows.items():
            if e["name"] != wname:
                continue
            r = dec.resolve_pc(e["pc"])
            g = agg.setdefault((e["kind"], r.get("off"), e["pc"] if r.get("off") is None else ""), dict(r=r, n=0, sessions={}, scenes={}, addrs={}, vals={}, ctx={}, kind=e["kind"],
                                                                                                         amin=e["amin"], amax=e["amax"]))
            g["n"] += e["n"]
            g["amin"], g["amax"] = min(g["amin"], e["amin"]), max(g["amax"], e["amax"])
            for src, dst in ((e["sessions"], g["sessions"]), (e["scenes"], g["scenes"]), (e["addrs"], g["addrs"]), (e["vals"], g["vals"]), (e["ctx"], g["ctx"])):
                for k_, v_ in src.items():
                    dst[k_] = dst.get(k_, 0) + v_
        ctx_blocks = []
        for key, g in sorted(agg.items(), key=lambda kv: (kv[0][0], kv[0][1] or 0)):
            r = g["r"]
            ad = sorted(g["addrs"].items(), key=lambda kv: int(kv[0]))
            addrs = ",".join("%05X:%d" % (int(a), c) for a, c in ad[:12]) + (" ..(%d..%05X)" % (len(ad), g["amax"]) if len(ad) > 12 else "")
            vals = ",".join("%02X:%d" % (int(v), c) for v, c in sorted(g["vals"].items(), key=lambda kv: int(kv[0])))
            dma = "DMA" if r.get("dma") else ""
            L.append("| %s | %s | %s | %s | %s | %d | %s | %s | %s | %s | %s |" % (g["kind"], r.get("off"), r["where"], r["text"], r["routine"], g["n"], fmt_sessions(g["sessions"]),
                                                                               fmt_scenes(g["scenes"]), addrs, vals[:80], dma))
            merged["rows"].append(dict(watch=wname, kind=g["kind"], pc=key[2], off=r.get("off"), where=r["where"], text=r["text"], routine=r["routine"], n=g["n"], sessions=g["sessions"],
                                       scenes=g["scenes"], addrs=g["addrs"], amin=g["amin"], amax=g["amax"], vals=g["vals"], ctx=g["ctx"], dma=bool(dma)))
            if r.get("off") is not None:
                runtime_offs[wname][r["off"]] += g["n"]
            if g["ctx"]:
                ctx_blocks.append((g, r))
        L.append("")
        for g, r in ctx_blocks:
            top = sorted(g["ctx"].items(), key=lambda kv: -kv[1])[:8]
            L.append("- %s at offset %s (%s): %s" % (g["kind"], r.get("off"), r["routine"], "; ".join("%s x%d" % (k, c) for k, c in top)))
        L.append("")

    # static versus runtime
    L.append("## Static list versus runtime\n")
    L.append("Static rows: tagged instructions whose operand names an address of the watch (`w1d_static.py`; an indexed form counts by its base). Runtime: the instruction that ends at the logged PC.\n")
    all_static = defaultdict(list)
    for sr in srows:
        all_static[sr["group"]].append(sr)
    for wname in watch_names + [w for w in STATIC_OF if w not in watch_names]:
        if wname not in STATIC_OF:
            continue
        grp, (lo, hi) = STATIC_OF[wname]
        slist = [x for x in all_static[grp] if lo - 1 <= x["addr"] <= hi]
        if wname in ("7F0000-00FF", "7F0100-01FF"):
            slist = [x for x in slist if not x["indexed"]]    # an indexed 7F00xx form is slot-relative: it belongs to the slot-field watches
        elif wname.startswith(("7F0010,X", "7F0020,X", "player")):
            slist = [x for x in slist if x["indexed"]]
        rt = runtime_offs.get(wname, {})
        soffs = set(x["off"] for x in slist)
        miss = [x for x in slist if x["off"] not in rt]
        new = sorted(o for o in rt if o not in soffs)
        L.append("### %s\n" % wname)
        L.append("static sites: %d; hit at runtime: %d; not hit: %d; runtime sites not in the static list: %d\n" % (len(slist), len(slist) - len(miss), len(miss), len(new)))
        merged["compare"].append(dict(watch=wname, static=len(slist), hit=len(slist) - len(miss), missed=[x["off"] for x in miss], new=new))
        if miss:
            L.append("| static offset | file:line | instruction | routine | access |")
            L.append("|---|---|---|---|---|")
            for x in miss[:60]:
                L.append("| %d | %s | %s | %s | %s |" % (x["off"], x["where"], x["text"], x["routine"], x["access"]))
            if len(miss) > 60:
                L.append("| ... | (%d more not hit) | | | |" % (len(miss) - 60))
            L.append("")
        if new:
            L.append("Runtime sites not in the static list:\n")
            L.append("| offset | file:line | instruction | routine | count |")
            L.append("|---|---|---|---|---|")
            for o in new:
                t = tags[o]
                L.append("| %d | %s:%d | %s | %s | %d |" % (o, t["file"], t["line"], t["text"], dec.routine(o), rt[o]))
            L.append("")
        for x in slist:
            merged["static"].append(dict(watch=wname, off=x["off"], where=x["where"], text=x["text"], routine=x["routine"], access=x["access"], runtime=rt.get(x["off"], 0)))

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
            L.append("- %s (off %s, WRAM %05X): 0 executions" % (name, e["off"], e["addr"]))
            continue
        vs = ", ".join("%0*X@%s:%d" % (4 if e["size"] == 2 else 2, int(k.split("@")[0]), k.split("@")[1], c) for k, c in sorted(e["vals"].items(), key=lambda kv: -kv[1])[:30])
        L.append("- %s (off %s, WRAM %05X, size %d): %d executions (%s): %s" % (name, e["off"], e["addr"], e["size"], e["n"], fmt_sessions(e["sessions"], 4), vs))
    L.append("")

    L.append("## Snapshots (trial sessions)\n")
    for s in sessions:
        snaps = s["final"].get("snaps") or []
        if not snaps:
            continue
        merged["snaps"][s["name"]] = snaps
        L.append("### %s (killed: %s)\n" % (s["name"], s["final"].get("killed1")))
        L.append("| label | frame | scene | cg91 / stg91 | cg92 / stg92 | back | pl+10 | pl+20 | playerFlags | $0672-77 | $00B2 | $00F4 | $00F8 | $06C6 $06C8 $06CA $06CC |")
        L.append("|---|---|---|---|---|---|---|---|---|---|---|---|---|---|")
        for sn in snaps:
            L.append("| %s | %s | %02X | %04X / %04X | %04X / %04X | %s | %04X | %04X | %04X | %s %s | %04X | %04X | %04X | %04X %04X %04X %04X |" % (
                sn.get("label"), sn.get("frame"), sn.get("scene", 0), sn.get("cg91", 0), sn.get("stg91", 0), sn.get("cg92", 0), sn.get("stg92", 0), sn.get("back"), sn.get("pl10", 0),
                sn.get("pl20", 0), sn.get("pf", 0), sn.get("c0672"), sn.get("c0675"), sn.get("b2", 0), sn.get("f4", 0), sn.get("f8", 0), sn.get("s06c6", 0), sn.get("s06c8", 0),
                sn.get("s06ca", 0), sn.get("s06cc", 0)))
        L.append("")

    with open(out, "w", encoding="utf-8") as f:
        f.write("\n".join(L) + "\n")
    with open(os.path.join(RAW, "W1d_merged.json"), "w", encoding="utf-8") as f:
        json.dump(merged, f, indent=1, default=str)
    print("wrote", out, len(L), "lines")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--date", nargs="*", default=None)
    ap.add_argument("--out", default=None)
    main(ap.parse_args())
