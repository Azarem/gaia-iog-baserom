"""W1-f aggregate: merge every raw/W1f_*.json and map each logged K:PC (the PC AFTER the accessing instruction) to the instruction that ENDS at it.

The map comes from the `; {n}` line tags of the extracted asm (n = ROM file offset of the instruction in ROM O). Output: raw/W1f_aggregate.json and a markdown digest on stdout.
usage: python w1f_report.py [--rows] [--sites] [--facing] [--sessions]
"""
import bisect
import collections
import glob
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
RAW = os.path.join(HERE, "..", "raw")
EXTRACTED = os.path.join(HERE, "..", "..", "..", "..", "extracted")
TAG = re.compile(r";\s*\{(\d+)\}")
TOP = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*)\s*[\{\[\|]")
SUB = re.compile(r"^\s+([A-Za-z_][A-Za-z0-9_]*):")


def build_tag_map():
    tags = []     # (offset, file, routine, text)
    for root, _, files in os.walk(EXTRACTED):
        for fn in files:
            if not fn.endswith(".asm"):
                continue
            path = os.path.join(root, fn)
            routine = ""
            sub = ""
            with open(path, encoding="utf-8", errors="replace") as fh:
                for line in fh:
                    m = TOP.match(line)
                    if m:
                        routine, sub = m.group(1), ""
                    else:
                        m = SUB.match(line)
                        if m:
                            sub = m.group(1)
                    t = TAG.search(line)
                    if t:
                        text = line[:t.start()].strip()
                        tags.append((int(t.group(1)), os.path.relpath(path, EXTRACTED).replace("\\", "/"), routine + ((" / " + sub) if sub else ""), text))
    tags.sort(key=lambda x: x[0])
    return tags


def pc_to_offset(pc):
    bank, addr = int(pc[:2], 16), int(pc[3:], 16)
    if bank in (0x7E, 0x7F) or addr < 0x8000 and bank < 0x40:
        return None
    return ((bank & 0x3F) << 16) | addr


def ending_instruction(tags, keys, pc):
    off = pc_to_offset(pc)
    if off is None:
        return dict(pc=pc, off=None, text="(RAM / non-ROM PC)", file="", routine="")
    i = bisect.bisect_left(keys, off) - 1     # last tag strictly below the PC
    if i < 0:
        return dict(pc=pc, off=off, text="?", file="", routine="")
    t = tags[i]
    nxt = tags[i + 1][0] if i + 1 < len(tags) else None
    return dict(pc=pc, off=t[0], text=t[3], file=t[1], routine=t[2], exact=(nxt == off), pcOff=off)


def load_sessions():
    out = {}
    for f in sorted(glob.glob(os.path.join(RAW, "W1f_*.json"))):
        d = json.load(open(f))
        if "census" in d:    # the recorded natural replay stores its result under "census"
            d = dict(session=dict(name="natural_fr10", frames=d["inputFrames"]), final=d["census"])
        if "final" not in d:
            continue
        out[os.path.basename(f)] = d
    return out


def main():
    args = set(sys.argv[1:])
    tags = build_tag_map()
    keys = [t[0] for t in tags]
    sessions = load_sessions()
    # watch rows: key "<name> <kind> <pc>"
    rows = collections.defaultdict(lambda: dict(n=0, sessions=set(), vals=collections.Counter(), scenes=collections.Counter(), ctx=collections.Counter()))
    execs = collections.defaultdict(lambda: dict(n=0, sessions=set(), scenes=collections.Counter()))
    spsd = collections.defaultdict(lambda: dict(n=0, sessions=set()))
    bodyRows = collections.defaultdict(lambda: dict(n=0, sessions=set()))
    pf15 = collections.defaultdict(lambda: dict(n=0, sessions=set()))
    facing = collections.defaultdict(lambda: dict(n=0, sessions=set()))
    ftab = collections.defaultdict(lambda: dict(n=0, sessions=set()))
    fres = collections.defaultdict(lambda: dict(n=0, sessions=set()))
    fidx = collections.defaultdict(lambda: dict(n=0, sessions=set()))
    probes = collections.defaultdict(lambda: dict(n=0, sessions=set(), vals=collections.Counter()))
    ctl = nmi = frames = 0
    names = []
    for fn, d in sessions.items():
        f = d["final"]
        sn = d["session"]["name"]
        names.append((sn, d["session"].get("frames"), f.get("control36Writes", d.get("control36Writes")), f.get("nmiExecs"), f.get("hits")))
        ctl += f.get("control36Writes") or 0
        nmi += f.get("nmiExecs") or 0
        frames += f.get("frames") or 0
        for r in f.get("rows", []):
            k = (r["name"], r["kind"], r["pc"])
            a = rows[k]
            a["n"] += r["n"]
            a["sessions"].add(sn)
            for v, c in r.get("vals", []):
                a["vals"][v] += c
            for s, c in r.get("scenes", []):
                a["scenes"][s] += c
        for e in f.get("execs", []):
            a = execs[e["name"]]
            a["n"] += e["n"]
            if e["n"]:
                a["sessions"].add(sn)
            for s, c in e.get("scenes", []):
                a["scenes"][s] += c
        for src, dst in (("spsd", spsd), ("bodyRows", bodyRows), ("pf15", pf15), ("facing", facing), ("facingTable", ftab), ("facingResult", fres), ("facingIndex", fidx)):
            for e in f.get(src, []):
                dst[e["key"]]["n"] += e["n"]
                dst[e["key"]]["sessions"].add(sn)
        for p in f.get("probes", []):
            a = probes[p["name"]]
            a["n"] += p["n"]
            if p["n"]:
                a["sessions"].add(sn)
            for v, c in p.get("vals", []):
                a["vals"][v] += c

    print("# W1-f aggregate: %d session files, %d frames, INC $36 control writes %d, NMI execs %d" % (len(sessions), frames, ctl, nmi))
    if "--sessions" in args:
        for n in names:
            print("%-22s frames=%s ctl36=%s nmi=%s hits=%s" % n)
    print("\n## Watch rows (K:PC -> instruction ending at the PC)")
    table = []
    for (name, kind, pc), a in sorted(rows.items(), key=lambda kv: (kv[0][0], kv[0][1], -kv[1]["n"])):
        ins = ending_instruction(tags, keys, pc)
        table.append(dict(watch=name, kind=kind, pc=pc, n=a["n"], sessions=sorted(a["sessions"]), vals=a["vals"].most_common(8), scenes=dict(a["scenes"]), ins=ins))
        print("%-38s %-5s %s n=%-7d off=%-7s %-34s %s | %s | sessions=%d vals=%s" % (name[:38], kind, pc, a["n"], ins.get("off"), ins.get("routine", "")[:34], ins.get("file", ""), ins.get("text", ""), len(a["sessions"]),
                                                                                    ",".join("%s:%d" % v for v in a["vals"].most_common(6))))
    print("\n## Exec marks")
    for name, a in sorted(execs.items()):
        print("%8d  %-52s sessions=%d scenes=%s" % (a["n"], name, len(a["sessions"]), ",".join("%02X" % s for s in sorted(a["scenes"]))[:60]))
    for title, dd in (("SPSD operands", spsd), ("body table rows drawn", bodyRows), ("playerFlags bit 15 changes", pf15), ("GetPlayerFacingDirection callers", facing), ("facing table loads", ftab), ("facing result", fres), ("facing byte index and actor frame", fidx)):
        print("\n## " + title)
        for k, a in sorted(dd.items()):
            print("%8d  %-70s sessions=%s" % (a["n"], k, ",".join(sorted(a["sessions"]))[:90]))
    print("\n## Probes")
    for k, a in probes.items():
        print(k, a["n"], a["vals"].most_common(10), sorted(a["sessions"]))
    out = dict(sessions=names, rows=table, execs={k: dict(n=v["n"], sessions=sorted(v["sessions"])) for k, v in execs.items()},
               spsd={k: v["n"] for k, v in spsd.items()}, bodyRows={k: v["n"] for k, v in bodyRows.items()}, pf15={k: v["n"] for k, v in pf15.items()},
               facing={k: v["n"] for k, v in facing.items()}, facingTable={k: v["n"] for k, v in ftab.items()}, facingResult={k: v["n"] for k, v in fres.items()}, facingIndex={k: v["n"] for k, v in fidx.items()})
    json.dump(out, open(os.path.join(RAW, "W1f_aggregate.json"), "w"), indent=1, default=list)


if __name__ == "__main__":
    main()
