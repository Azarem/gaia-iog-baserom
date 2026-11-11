"""W1-g aggregate: merge every raw/W1g_*.json and map each logged K:PC (the PC AFTER the accessing instruction) to the instruction that ENDS at it.

The map comes from the `; {n}` line tags of the extracted asm (n = ROM file offset of the instruction in ROM O). Output: raw/W1g_aggregate.json and a text digest on stdout.
usage: python w1g_report.py [--sessions] [--w24] [--w26] [--b02] [--ring] [--tallies] [--exec] [--trk] [--static]
  --w24 / --w26   readers and writers of the slot fields $24-$25 / $26-$27 (byte hits; a 16-bit access is two), the writer each read is paired with, who runs (self / other / thinker)
  --b02           $0B02 hits, the probes at the 13 static readers
  --ring          $DF00-$DF3F and $DF40-$DF7F hits and the tracker tallies
  --tallies       speed stores, tick speed, step, setup facing, head read, idle read, facing written
  --exec          exec marks with the sessions that reach them
  --trk           the first-frames trace of the escort trackers
  --static        compare the logged K:PC of the $24 readers with the static list (raw/W1g_static_24_*.txt)
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
    for f in sorted(glob.glob(os.path.join(RAW, "W1g_*.json"))):
        if f.endswith("aggregate.json"):
            continue
        d = json.load(open(f))
        if "census" in d:    # the recorded natural replay stores its result under "census"
            d = dict(session=dict(name="natural_fr10", frames=d["inputFrames"]), final=d["census"])
        if "final" not in d:
            continue
        out[os.path.basename(f)] = d
    return out


def ctx_kind(c):
    return c.split(" ")[0]


def fmt_ins(ins):
    return "off=%-7s %-34s %s | %s" % (ins.get("off"), ins.get("routine", "")[:34], ins.get("file", ""), ins.get("text", ""))


def main():
    args = set(sys.argv[1:])
    tags = build_tag_map()
    keys = [t[0] for t in tags]
    sessions = load_sessions()
    blank = lambda: dict(n=0, sessions=set(), vals=collections.Counter(), scenes=collections.Counter(), ctx=collections.Counter(), lo=0, hi=0, amin=1 << 30, amax=0)
    rows = collections.defaultdict(blank)
    pairs = collections.defaultdict(lambda: dict(n=0, sessions=set()))
    execs = collections.defaultdict(lambda: dict(n=0, sessions=set(), scenes=collections.Counter()))
    probes = collections.defaultdict(lambda: dict(n=0, sessions=set(), vals=collections.Counter(), scenes=collections.Counter()))
    tall = {k: collections.defaultdict(lambda: dict(n=0, sessions=set(), scenes=collections.Counter())) for k in ("spd", "tickspd", "step", "setupFacing", "ringWrites", "headRead", "idleRead", "facingWritten")}
    trk, maxraw, trackers = [], 0, 0
    ctl = nmi = frames = 0
    names = []
    for fn, d in sessions.items():
        f = d["final"]
        sn = d["session"]["name"]
        names.append((sn, d["session"].get("frames"), f.get("control36Writes", d.get("control36Writes")), f.get("nmiExecs"), f.get("hits"), f.get("endScene")))
        ctl += f.get("control36Writes") or 0
        nmi += f.get("nmiExecs") or 0
        frames += f.get("frames") or 0
        for r in f.get("rows", []):
            k = (r["name"], r["kind"], r["pc"])
            a = rows[k]
            a["n"] += r["n"]
            a["sessions"].add(sn)
            a["amin"], a["amax"] = min(a["amin"], r["amin"]), max(a["amax"], r["amax"])
            for v, c in r.get("vals", []):
                a["vals"][v] += c
            for s, c in r.get("scenes", []):
                a["scenes"][s] += c
            for c, n in r.get("ctx", []):
                a["ctx"][c] += n
            for off, c in r.get("addrs", []):
                if r["name"].startswith("$2"):
                    fld = (off - 0x1000) % 0x30
                    if fld in (0x24, 0x26):
                        a["lo"] += c
                    else:
                        a["hi"] += c
        for p in f.get("pairs", []):
            a = pairs[p["key"]]
            a["n"] += p["n"]
            a["sessions"].add(sn)
        for e in f.get("execs", []):
            a = execs[e["name"]]
            a["n"] += e["n"]
            if e["n"]:
                a["sessions"].add(sn)
            for s, c in e.get("scenes", []):
                a["scenes"][s] += c
        for p in f.get("probes", []):
            a = probes[p["name"]]
            a["n"] += p["n"]
            if p["n"]:
                a["sessions"].add(sn)
            for v, c in p.get("vals", []):
                a["vals"][v] += c
            for s, c in p.get("scenes", []):
                a["scenes"][s] += c
        for src in tall:
            for e in f.get(src, []):
                t = tall[src][e["key"]]
                t["n"] += e["n"]
                t["sessions"].add(sn)
                for s, c in e.get("scenes", []):
                    t["scenes"][s] += c
        for line in f.get("trk", []):
            trk.append((sn, line))
        maxraw = max(maxraw, f.get("maxRaw") or 0)
        trackers += f.get("trackers") or 0

    print("# W1-g aggregate: %d session files, %d frames, INC $36 control writes %d, NMI execs %d" % (len(sessions), frames, ctl, nmi))
    if "--sessions" in args:
        for n in names:
            print("%-22s frames=%s ctl36=%s nmi=%s hits=%s endScene=%s" % n)

    def show(prefix_list, title):
        print("\n## " + title)
        for (name, kind, pc), a in sorted(rows.items(), key=lambda kv: (kv[0][0], kv[0][1], -kv[1]["n"])):
            if not any(name.startswith(p) for p in prefix_list):
                continue
            ins = ending_instruction(tags, keys, pc)
            wr = collections.Counter()
            for pk, pv in pairs.items():
                pre = "%s %s %s <- " % (name, kind, pc)
                if pk.startswith(pre):
                    wr[pk[len(pre):]] += pv["n"]
            ck = collections.Counter()
            for c, n in a["ctx"].items():
                ck[ctx_kind(c)] += n
            print("%-16s %-5s %s n=%-8d lo=%-6d hi=%-6d %s | sessions=%d scenes=%s" % (name[:16], kind, pc, a["n"], a["lo"], a["hi"], fmt_ins(ins), len(a["sessions"]),
                                                                                   ",".join("%02X" % s for s in sorted(a["scenes"]))[:50]))
            if kind == "read" and wr:
                print("      paired writers: " + ", ".join("%s:%d" % (k, v) for k, v in wr.most_common(6)))
            if ck:
                print("      who: " + ", ".join("%s:%d" % kv for kv in ck.most_common(5)) + "   vals: " + ",".join("%s:%d" % v for v in a["vals"].most_common(5)))

    if "--w24" in args:
        show(["$24-$25"], "slot $24-$25 (byte hits)")
    if "--w26" in args:
        show(["$26-$27"], "slot $26-$27 (byte hits)")
    if "--b02" in args:
        show(["0B02"], "$0B02-$0B03")
        print("\n### probes at the 13 static readers")
        for k, a in sorted(probes.items()):
            if k.startswith("B02"):
                print("%-22s n=%-6d vals=%s sessions=%s" % (k, a["n"], a["vals"].most_common(8), sorted(a["sessions"])))
    if "--ring" in args:
        show(["DF00", "DF40"], "ring $DF00-$DF3F and $DF40-$DF7F")
    if "--tallies" in args or "--ring" in args:
        for title, src in (("setup facing", "setupFacing"), ("ring offsets written at setup", "ringWrites"), ("head index read (moved)", "headRead"), ("idle head index", "idleRead"), ("facing written", "facingWritten")):
            print("\n## " + title)
            for k, a in sorted(tall[src].items()):
                print("%8d  %-60s sessions=%s" % (a["n"], k, ",".join(sorted(a["sessions"]))[:80]))
        print("max raw head seen:", maxraw, "trackers spawned:", trackers)
    if "--tallies" in args:
        for title, src in (("speed stores (A at the STA $loopCounter,X)", "spd"), ("tick speed load (speed, animation of the body)", "tickspd"), ("step per frame (speed, |dx|, |dy|)", "step")):
            print("\n## " + title)
            for k, a in sorted(tall[src].items()):
                print("%8d  %-60s scenes=%s sessions=%s" % (a["n"], k, ",".join("%02X" % s for s in sorted(a["scenes"])), ",".join(sorted(a["sessions"]))[:60]))
    if "--exec" in args:
        print("\n## Exec marks")
        for name, a in sorted(execs.items()):
            print("%8d  %-40s sessions=%d scenes=%s" % (a["n"], name, len(a["sessions"]), ",".join("%02X" % s for s in sorted(a["scenes"]))[:70]))
        print("\n## Probes (all)")
        for k, a in sorted(probes.items()):
            if not k.startswith("B02"):
                print(k, a["n"], a["vals"].most_common(12), sorted(a["sessions"]))
    if "--trk" in args:
        print("\n## Escort tracker traces")
        for sn, line in trk:
            print(sn, line)
    if "--static" in args:
        stat = collections.defaultdict(list)
        for kind in ("readers", "writers"):
            for line in open(os.path.join(RAW, "W1g_static_24_%s.txt" % kind), encoding="utf-8"):
                m = TAG.search(line)
                if m:
                    stat[kind].append(int(m.group(1)))
        seen = collections.defaultdict(set)
        for (name, kind, pc), a in rows.items():
            if name.startswith("$24-$25"):
                ins = ending_instruction(tags, keys, pc)
                seen[kind].add(ins.get("off"))
        for kind, key in (("read", "readers"), ("write", "writers")):
            st = set(stat[key])
            print("\n## $24 %s: static %d tagged instructions, runtime %d distinct instructions, static reached %d" % (key, len(st), len(seen[kind]), len(st & seen[kind])))
            print("   runtime-only (not in the static list):", sorted(x for x in seen[kind] if x not in st and x is not None)[:80])
            print("   static, not reached:", len(st - seen[kind]))
    out = dict(sessions=names, rows=[dict(watch=k[0], kind=k[1], pc=k[2], n=v["n"], lo=v["lo"], hi=v["hi"], sessions=sorted(v["sessions"]), scenes=dict(v["scenes"]), vals=v["vals"].most_common(8),
                                          ctx=v["ctx"].most_common(8), ins=ending_instruction(tags, keys, k[2])) for k, v in rows.items()],
               pairs={k: v["n"] for k, v in pairs.items()}, execs={k: dict(n=v["n"], sessions=sorted(v["sessions"])) for k, v in execs.items()},
               probes={k: dict(n=v["n"], vals=v["vals"].most_common(12)) for k, v in probes.items()},
               tallies={s: {k: v["n"] for k, v in t.items()} for s, t in tall.items()}, maxRaw=maxraw, trackers=trackers, trk=trk)
    json.dump(out, open(os.path.join(RAW, "W1g_aggregate.json"), "w"), indent=1, default=list)


if __name__ == "__main__":
    main()
