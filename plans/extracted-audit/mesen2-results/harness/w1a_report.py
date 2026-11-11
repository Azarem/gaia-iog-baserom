#!/usr/bin/env python3
"""Merge the W1-a census sessions (raw/W1a_*_<date>.json) and map every K:PC to the instruction that ENDS at the PC.

usage: w1a_report.py [--date yyyymmdd] [--out raw/W1a_report.md]

Reads (read-only): extracted/**/*.asm (the `; {n}` line tags and the `!name hex` RAM definitions), db-us/names/bank*.json (labels).
Writes: raw/W1a_report.md and raw/W1a_merged.json.
For each watch name: rows (reader / writer) with ROM offset of the instruction, file:line, text, routine (nearest name), total count,
sessions, scenes, whether the extracted source names the watched address in that instruction's operand (static = yes) or not (NEW).
"""
import argparse
import bisect
import glob
import json
import os
import re
import sys
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
RESULTS = os.path.dirname(HERE)
RAW = os.path.join(RESULTS, "raw")
BASEROM = os.path.abspath(os.path.join(RESULTS, "..", "..", ".."))
EXTRACTED = os.path.join(BASEROM, "extracted")
NAMES = os.path.join(BASEROM, "db-us", "names")

WATCH_RANGES = {
    "AA": (0xAA, 0xAA), "AB": (0xAB, 0xAB), "AA bit6(0x40)": (0xAA, 0xAA), "AB bit1(0x02)": (0xAB, 0xAB), "AB bit2,3(0x0C)": (0xAB, 0xAB),
    "AB bit7(0x80)": (0xAB, 0xAB), "5E-5F": (0x5E, 0x5F), "60-61": (0x60, 0x61), "62-64": (0x62, 0x64), "DC-DD": (0xDC, 0xDD),
    "0720-0761": (0x0720, 0x0761),
}

TAG = re.compile(r";\s*\{(\d+)\}")
DEF = re.compile(r"^!(\w+)\s+([0-9A-Fa-f]+)\s*$")
HEX = re.compile(r"\$([0-9A-Fa-f]{2,6})\b")
NAMEREF = re.compile(r"\$([A-Za-z_]\w*)")


def load_tags():
    tags = {}
    for path in glob.glob(os.path.join(EXTRACTED, "**", "*.asm"), recursive=True):
        defs = {}
        with open(path, encoding="utf-8", errors="replace") as f:
            lines = f.read().split("\n")
        for ln in lines:
            m = DEF.match(ln)
            if m:
                defs[m.group(1)] = int(m.group(2), 16)
        rel = os.path.relpath(path, EXTRACTED).replace("\\", "/")
        for i, ln in enumerate(lines, 1):
            m = TAG.search(ln)
            if not m:
                continue
            body = ln[:m.start()].strip()
            tags[int(m.group(1))] = dict(file=rel, line=i, text=re.sub(r"\s+", " ", body.split(";")[0].strip()), defs=defs)
    return tags


def load_names():
    out = {}
    for p in glob.glob(os.path.join(NAMES, "bank*.json")):
        with open(p, encoding="utf-8") as f:
            for k, v in json.load(f).items():
                out[int(k)] = v
    keys = sorted(out)
    return out, keys


NOOP_MNEMONICS = ("JSR", "JSL", "JMP", "JML", "BRA", "BRL", "BEQ", "BNE", "BCC", "BCS", "BPL", "BMI", "BVC", "BVS", "MVN", "MVP", "PEA", "PEI", "PER")


def operand_values(text, defs):
    """Addresses the instruction's operand names (direct page / absolute / long-in-RAM), immediates and branch targets excluded."""
    parts = text.split(None, 1)
    if not parts or parts[0].upper() in NOOP_MNEMONICS or len(parts) < 2:
        return []
    op = re.sub(r"#\$?[&@]?[A-Za-z0-9_+]*", "", parts[1])
    vals = []
    for m in HEX.finditer(op):
        h = m.group(1)
        if len(h) in (2, 4):
            vals.append(int(h, 16))
        elif len(h) == 6 and (int(h[:2], 16) == 0x7E or int(h[:2], 16) <= 0x3F or 0x80 <= int(h[:2], 16) <= 0xBF) and int(h[2:], 16) < 0x2000:
            vals.append(int(h[2:], 16))
    for m in NAMEREF.finditer(op):
        n = m.group(1)
        if n in defs:
            vals.append(defs[n] & 0xFFFF if defs[n] < 0x1000000 else defs[n])
    return vals


def static_hit(tag, wname):
    lo, hi = WATCH_RANGES[wname]
    # a word access at v also touches v+1, so v = lo - 1 counts (16-bit LDA/STA/STZ/TSB of the byte below the watched one)
    return any(lo - 1 <= v <= hi for v in operand_values(tag["text"], tag["defs"]))


def access_class(tag, wname):
    """static = the operand names a watched address; indexed/indirect = the form can reach it through a register or pointer; otherwise the
    callback PC is the instruction a DMA/HDMA interrupted or the one after a DMA trigger (not a CPU access to the watched byte)."""
    if tag is None:
        return "unmapped"
    if static_hit(tag, wname):
        return "static"
    if re.search(r"[,\[\(]|^MV[NP]", tag["text"]):
        return "indexed/indirect"
    return "DMA/HDMA-attributed"


def rom_offset(k, pc):
    if k in (0x7E, 0x7F):
        return None
    if k <= 0x3F or 0x80 <= k <= 0xBF:
        if pc < 0x8000:
            return None
        return ((k & 0x3F) << 16) | pc
    if 0xC0 <= k <= 0xFF:
        return ((k & 0x3F) << 16) | pc
    return None


def instr_ending_at(tag_keys, end):
    i = bisect.bisect_left(tag_keys, end)
    if i == 0:
        return None
    p = tag_keys[i - 1]
    return p if 1 <= end - p <= 4 else None


def routine(names, nkeys, off):
    i = bisect.bisect_right(nkeys, off)
    if i == 0:
        return "?"
    k = nkeys[i - 1]
    return names[k] if off == k else f"{names[k]}+{off - k}"


def load_sessions(date):
    out = []
    for p in sorted(glob.glob(os.path.join(RAW, f"W1a_*_{date}.json"))):
        base = os.path.basename(p)
        if base.startswith("W1a_merged") or base.startswith("W1a_report"):
            continue
        with open(p, encoding="utf-8") as f:
            d = json.load(f)
        if "census" in d:   # natural replay file
            name = "natural_fr10"
            c = d["census"]
            if not isinstance(c, dict) or "rows" not in c:
                continue
            out.append(dict(name=name, final=c, frames=d.get("inputFrames"), h1=d["h1"], scene=d.get("endScene")))
        else:
            if not d.get("final"):
                continue
            out.append(dict(name=d["session"]["name"], final=d["final"], frames=d.get("frames"), h1=d["h1"], scene=d.get("scene"),
                            rom=d.get("rom")))
    return out


def merge(sessions):
    rows = {}
    pairs = {}
    execs = defaultdict(lambda: dict(n=0, sessions={}, scenes={}))
    ctl = dict(ctl36=0, nmi=0, frames=0)
    scenes_seen = defaultdict(int)
    snaps = []
    gates = {}
    for s in sessions:
        f = s["final"]
        ctl["ctl36"] += f.get("control36Writes", 0)
        ctl["nmi"] += f.get("nmiExecs", 0)
        ctl["frames"] += f.get("frames", 0) or 0
        for sc in f.get("sceneFrames", []):
            if isinstance(sc, list) and len(sc) == 2:
                scenes_seen[sc[0]] += sc[1]
            elif isinstance(sc, dict):
                scenes_seen[sc.get("key")] += sc.get("count", 0)
        for r in f["rows"]:
            e = rows.setdefault(r["key"], dict(key=r["key"], name=r["name"], kind=r["kind"], pc=r["pc"], n=0, sessions={}, scenes={}, addrs={}, vals={}))
            e["n"] += r["n"]
            e["sessions"][s["name"]] = e["sessions"].get(s["name"], 0) + r["n"]
            for k, v in r.get("scenes", []):
                e["scenes"][k] = e["scenes"].get(k, 0) + v
            for k, v in r.get("addrs", []):
                e["addrs"][k] = e["addrs"].get(k, 0) + v
            for k, v in r.get("vals", []):
                e["vals"][k] = e["vals"].get(k, 0) + v
        for r in f.get("pairs", []):
            e = pairs.setdefault(r["key"], dict(key=r["key"], n=0, sessions={}, scenes={}))
            e["n"] += r["n"]
            e["sessions"][s["name"]] = e["sessions"].get(s["name"], 0) + r["n"]
            for k, v in r.get("scenes", []):
                e["scenes"][k] = e["scenes"].get(k, 0) + v
        for x in f.get("execs", []):
            e = execs[x["name"]]
            e["off"] = x["off"]
            e["n"] += x.get("n", 0)
            if x.get("n"):
                e["sessions"][s["name"]] = x["n"]
            for k, v in x.get("scenes", []):
                e["scenes"][k] = e["scenes"].get(k, 0) + v
        for g in f.get("gates", []):
            e = gates.setdefault(g["name"], dict(off=g["off"], n=0, set=0, sessions={}))
            e["n"] += g["n"]
            e["set"] += g["set"]
            if g["set"]:
                e["sessions"][s["name"]] = g["set"]
        for line in f.get("snaps", []):
            snaps.append(f"{s['name']}: {line}")
    return rows, pairs, execs, ctl, scenes_seen, snaps, gates


def fmt_sessions(d, top=4):
    items = sorted(d.items(), key=lambda kv: -kv[1])
    s = ", ".join(f"{k} {v}" for k, v in items[:top])
    return s + (f" (+{len(items) - top})" if len(items) > top else "")


def fmt_scenes(d, top=8):
    items = sorted(d.items(), key=lambda kv: kv[0])
    s = " ".join(f"{int(k):02X}" for k, _ in items[:top])
    return f"{len(items)}: {s}" + (" ..." if len(items) > top else "")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--date", default=None)
    ap.add_argument("--out", default=os.path.join(RAW, "W1a_report.md"))
    args = ap.parse_args()
    import time
    date = args.date or time.strftime("%Y%m%d")
    sessions = load_sessions(date)
    tags = load_tags()
    tag_keys = sorted(tags)
    names, nkeys = load_names()
    rows, pairs, execs, ctl, scenes_seen, snaps, gates = merge(sessions)

    resolved = {}

    def resolve(pc):
        if pc in resolved:
            return resolved[pc]
        k, p = (int(x, 16) for x in pc.split(":"))
        end = rom_offset(k, p)
        if end is None:
            r = dict(off=None, text="(not ROM: bank %02X pc %04X)" % (k, p), where="", routine="?")
        else:
            off = instr_ending_at(tag_keys, end)
            if off is None:
                r = dict(off=None, end=end, text="(no tagged instruction ends at %d)" % end, where="", routine=routine(names, nkeys, end))
            else:
                t = tags[off]
                r = dict(off=off, end=end, text=t["text"], where=f"{t['file']}:{t['line']}", routine=routine(names, nkeys, off), tag=t)
        resolved[pc] = r
        return r

    L = []
    L.append(f"# W1-a merged census ({date})\n")
    L.append(f"sessions: {len(sessions)}; frames (sum of per-session frame counters): {ctl['frames']}; $36 write control: {ctl['ctl36']}; NMI exec control: {ctl['nmi']}\n")
    L.append("## Sessions\n")
    L.append("| session | frames | end scene | H1 (k, sp, scene) | hits |")
    L.append("|---|---|---|---|---|")
    for s in sessions:
        h = s["h1"]
        L.append(f"| {s['name']} | {s['frames']} | {(s['scene'] or 0):02X} | {h.get('k'):02X} {h.get('sp'):04X} {h.get('scene'):02X} | {s['final'].get('hits')} |")
    L.append("")
    L.append("## Scenes visited (frames, sum)\n")
    L.append(" ".join(f"{int(k):02X}:{v}" for k, v in sorted(scenes_seen.items(), key=lambda kv: int(kv[0]))) + "\n")

    merged = dict(ctl=ctl, rows=[], pairs=[], execs=execs, snaps=snaps)
    for wname in WATCH_RANGES:
        L.append(f"## {wname}\n")
        L.append("| kind | offset | file:line | instruction | routine | count | class | sessions | scenes | addrs | values |")
        L.append("|---|---|---|---|---|---|---|---|---|---|---|")
        agg = {}
        dma = {}
        for key, e in rows.items():
            if e["name"] != wname:
                continue
            r = resolve(e["pc"])
            cls = access_class(r.get("tag"), wname)
            if wname == "0720-0761" and e["kind"] == "read" and cls in ("indexed/indirect", "unmapped") and set(int(k) for k in e["scenes"]) <= {0xE7, 0xF7}:
                cls = "DMA/HDMA-attributed"   # scenes E7/F7 read the $0720 area through an HDMA channel (verified separately with get_dma_state)
            merged["rows"].append(dict(watch=wname, kind=e["kind"], pc=e["pc"], off=r.get("off"), where=r["where"], text=r["text"], routine=r["routine"],
                                       n=e["n"], cls=cls, sessions=e["sessions"], scenes=e["scenes"], addrs=e["addrs"], vals=e["vals"]))
            if cls == "DMA/HDMA-attributed":
                d = dma.setdefault(e["kind"], dict(n=0, pcs=set(), addrs={}, sessions={}))
                d["n"] += e["n"]
                d["pcs"].add(e["pc"])
                for a_, c_ in e["addrs"].items():
                    d["addrs"][a_] = d["addrs"].get(a_, 0) + c_
                for k_, v_ in e["sessions"].items():
                    d["sessions"][k_] = d["sessions"].get(k_, 0) + v_
                continue
            g = agg.setdefault((e["kind"], r.get("off"), e["pc"] if r.get("off") is None else ""), dict(r=r, cls=cls, n=0, sessions={}, scenes={}, addrs={}, vals={}, kind=e["kind"]))
            g["n"] += e["n"]
            for src, dst in ((e["sessions"], g["sessions"]), (e["scenes"], g["scenes"]), (e["addrs"], g["addrs"]), (e["vals"], g["vals"])):
                for k_, v_ in src.items():
                    dst[k_] = dst.get(k_, 0) + v_
        for key, g in sorted(agg.items(), key=lambda kv: (kv[0][0], kv[0][1] or 0)):
            r = g["r"]
            addrs = ",".join(f"{int(a):04X}:{c}" for a, c in sorted(g["addrs"].items()))
            vals = ",".join(f"{int(v):02X}:{c}" for v, c in sorted(g["vals"].items())) if g["kind"] == "write" else ""
            L.append(f"| {g['kind']} | {r.get('off')} | {r['where']} | {r['text']} | {r['routine']} | {g['n']} | {g['cls']} | {fmt_sessions(g['sessions'])} | "
                     f"{fmt_scenes(g['scenes'])} | {addrs[:120]} | {vals} |")
        for kind, d in dma.items():
            addrs = ",".join(f"{int(a):04X}:{c}" for a, c in sorted(d["addrs"].items()))
            L.append(f"| {kind} | - | - | (callbacks attributed to {len(d['pcs'])} different PCs that cannot access the watched byte: DMA/HDMA reads, or a DMA write after its trigger) | - | {d['n']} | DMA/HDMA-attributed | {fmt_sessions(d['sessions'])} | - | {addrs[:160]} | |")
        L.append("")

    # static census: every tagged instruction whose operand names a watched address, with its runtime hit count
    STORES = {"STA", "STX", "STY", "STZ"}
    RMW = {"TSB", "TRB", "INC", "DEC", "ASL", "LSR", "ROL", "ROR"}
    rt = defaultdict(int)      # (watch, offset) -> runtime hits (reads + writes)
    for e in rows.values():
        r = resolve(e["pc"])
        if r.get("off") is not None:
            rt[(e["name"], r["off"])] += e["n"]
    L.append("## Static census (operand names a watched address) with runtime count\n")
    static_rows = []
    for wname in ("AA", "AB", "5E-5F", "60-61", "62-64", "DC-DD", "0720-0761"):
        L.append(f"### {wname}\n")
        L.append("| offset | file:line | instruction | routine | access | runtime hits (all sessions) |")
        L.append("|---|---|---|---|---|---|")
        for off in tag_keys:
            t = tags[off]
            if not static_hit(t, wname):
                continue
            mn = t["text"].split(None, 1)[0].upper() if t["text"] else ""
            acc = "write" if mn in STORES else ("read+write" if mn in RMW and len(t["text"].split()) > 1 else "read")
            n = rt.get((wname, off), 0)
            L.append(f"| {off} | {t['file']}:{t['line']} | {t['text']} | {routine(names, nkeys, off)} | {acc} | {n} |")
            static_rows.append(dict(watch=wname, off=off, where=f"{t['file']}:{t['line']}", text=t["text"], routine=routine(names, nkeys, off), access=acc, runtime=n))
        L.append("")
    merged["static"] = static_rows

    L.append("## Read <- last writer pairs (watch names 5E-5F, 60-61, 62-64, DC-DD, 0720-0761)\n")
    L.append("| watch | reader off | reader instr | <- last writer off | writer instr | count | sessions |")
    L.append("|---|---|---|---|---|---|---|")
    dma_pcs = {(m_["watch"], m_["pc"]) for m_ in merged["rows"] if m_["cls"] == "DMA/HDMA-attributed" and m_["kind"] == "read"}
    pagg = {}
    for key, e in sorted(pairs.items()):
        m = re.match(r"(.+?) read (\S+) <- (\S+)$", key)
        if not m or m.group(1) in ("AA", "AB") or (m.group(1), m.group(2)) in dma_pcs:
            continue
        rd = resolve(m.group(2))
        wr = resolve(m.group(3)) if m.group(3) != "init" else dict(off="init", text="(no write seen in this run)")
        g = pagg.setdefault((m.group(1), rd.get("off"), wr.get("off")), dict(rd=rd, wr=wr, n=0, sessions={}))
        g["n"] += e["n"]
        for k_, v_ in e["sessions"].items():
            g["sessions"][k_] = g["sessions"].get(k_, 0) + v_
    for (wn, ro, wo), g in sorted(pagg.items(), key=lambda kv: (kv[0][0], kv[0][1] or 0, str(kv[0][2]))):
        L.append(f"| {wn} | {ro} | {g['rd']['text']} | {wo} | {g['wr']['text']} | {g['n']} | {fmt_sessions(g['sessions'], 3)} |")
        merged["pairs"].append(dict(watch=wn, n=g["n"], reader=ro, writer=wo, sessions=g["sessions"]))
    L.append("")

    L.append("## Exec marks\n")
    L.append("| name | offset | count | sessions | scenes |")
    L.append("|---|---|---|---|---|")
    for name, e in sorted(execs.items()):
        L.append(f"| {name} | {e.get('off')} | {e['n']} | {fmt_sessions(e['sessions'], 4)} | {fmt_scenes(e['scenes'])} |")
    L.append("")
    L.append("## Gate register values (A seen by the instruction)\n")
    for name, g in gates.items():
        L.append(f"- {name}: off {g['off']}, executed {g['n']}, bit set {g['set']} ({fmt_sessions(g['sessions'], 6)})")
    L.append("")
    L.append("## Accumulator snapshots ($0750-$0760, non-zero words)\n")
    for sn in snaps:
        L.append("- " + sn)
    with open(args.out, "w", encoding="utf-8") as f:
        f.write("\n".join(L) + "\n")
    with open(os.path.join(RAW, "W1a_merged.json"), "w", encoding="utf-8") as f:
        json.dump(merged, f, indent=1, default=str)
    print("wrote", args.out, len(L), "lines")


if __name__ == "__main__":
    main()
