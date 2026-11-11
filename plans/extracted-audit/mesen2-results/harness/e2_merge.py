#!/usr/bin/env python3
"""E2: merge the static decode (raw/E2_static.txt), the runtime rows (raw/E2_<glob>.txt) and the R1 counters (raw/E2_r1_*.json)
into raw/E2_bundles.md plus raw/E2_merged.json.   usage: python e2_merge.py [run-glob-prefix ...]   (default: sw trg)
Writes only under mesen2-results/raw."""
import collections
import glob
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
RAW = os.path.join(HERE, "..", "raw")
TABLE = 1474560


def load_static():
    B = {}
    for line in open(os.path.join(RAW, "E2_static.txt")):
        f = line.rstrip("\n").split("|")
        if len(f) < 14:
            continue
        strips = [tuple(int(x) for x in s.split(",")) for s in f[13].split(";") if s]
        B[int(f[0])] = dict(id=int(f[0]), ptr=int(f[1]), off=int(f[2]), term=int(f[3]), nsub=int(f[4]), frames=int(f[5]), ticks=int(f[6]),
                            dlo=int(f[9]), dhi=int(f[10]), backdrop=int(f[11]), strips=strips)
    return B


def load_runtime(prefixes):
    rt = collections.defaultdict(lambda: dict(starts=0, scenes=collections.Counter(), sites=collections.Counter(), ops=collections.Counter(),
                                              ends=0, ticks=collections.Counter(), load=0, caps=0, capdiff=0, capex=[], first=None))
    files = []
    for p in prefixes:
        files += sorted(glob.glob(os.path.join(RAW, f"E2_{p}*.txt")))
    for fn in files:
        for line in open(fn):
            f = line.rstrip("\n").split("|")
            t = f[0]
            if t == "N":
                r = rt[int(f[1], 16)]
                r["starts"] += int(f[2])
                for kv in f[3].split(","):
                    if ":" in kv:
                        k, v = kv.split(":")
                        r["scenes"][k] += int(v)
                for kv in f[4].split(","):
                    if ":" in kv:
                        k, v = kv.split(":")
                        r["sites"][k] += int(v)
                for kv in f[5].split(","):
                    if ":" in kv:
                        k, v = kv.split(":")
                        r["ops"][k] += int(v)
                r["load"] += int(f[7].replace("load", ""))
            elif t == "E":
                r = rt[int(f[1], 16)]
                r["ends"] += 1
                r["ticks"][int(f[5].replace("ticks", ""))] += 1
            elif t == "C":
                r = rt[int(f[1], 16)]
                r["caps"] += 1
                n = int(f[5][1:])
                if n > 0:
                    r["capdiff"] += 1
                    if len(r["capex"]) < 1:
                        r["capex"].append((f[2], f[6][:90] if len(f) > 6 else ""))
            elif t == "S":
                r = rt[int(f[1], 16)]
                if r["first"] is None:
                    r["first"] = (f[2], f[7], f[8])
    return rt, files


def load_r1(tag="sw"):
    """Sum of the per-chunk native counters (the counters are cleared by every state load: one dump per chunk, E2_r1_sw<k>.json)."""
    out = {}
    for p in sorted(glob.glob(os.path.join(RAW, f"E2_r1_{tag}[0-9].json"))):
        for r in json.load(open(p)):
            o = out.get(r["name"])
            if o is None:
                out[r["name"]] = dict(r)
            else:
                o["read"] += r["read"]
                o["bytesTouched"] = max(o["bytesTouched"], r["bytesTouched"])
    return out


def cgram_range(b):
    if b["dlo"] < 0:
        return "-"
    lo, hi = b["dlo"], b["dhi"]
    s = f"{lo:02X}" if lo == hi else f"{lo:02X}-{hi:02X}"
    return s + ("+bd" if b["backdrop"] else "")


def main():
    prefixes = sys.argv[1:] or ["sw", "trg"]
    B = load_static()
    rt, files = load_runtime(prefixes)
    rt_sw, _ = load_runtime(["sw"])
    rt_tr, _ = load_runtime(["trg"])
    r1 = load_r1()
    rows, never = [], []
    merged = {}
    for i in range(128):
        b = B[i]
        r = rt.get(i)
        reached = bool(r and r["starts"] > 0)
        how = ("sweep" if rt_sw.get(i) and rt_sw[i]["starts"] > 0 else "") + ("+trg" if rt_tr.get(i) and rt_tr[i]["starts"] > 0 and rt_sw.get(i) and rt_sw[i]["starts"] > 0 else ("trg" if rt_tr.get(i) and rt_tr[i]["starts"] > 0 else ""))
        l = r1.get(f"list{i:02X}")
        d = r1.get(f"data{i:02X}")
        t = r1.get(f"tbl{i:02X}")
        r1s = "-"
        if t:
            r1s = f"tbl{t['read']}/list{l['bytesTouched']}of{l['length']}/data{(d['bytesTouched'] if d else 0)}of{(d['length'] if d else 0)}"
        ticks_obs = ",".join(f"{k}x{v}" for k, v in sorted(r["ticks"].items())[:3]) if r else ""
        merged[i] = dict(static=b, reached=reached, how=how if reached else "no", r1=r1s, ticks=ticks_obs, starts=(r["starts"] if r else 0),
                         scenes=(sorted(r["scenes"]) if r else []), sites=(dict(r["sites"]) if r else {}), ops=(dict(r["ops"]) if r else {}),
                         caps=(r["caps"] if r else 0), capdiff=(r["capdiff"] if r else 0), load=(r["load"] if r else 0))
        nsc = len(r["scenes"]) if r else 0
        sc = ",".join(sorted(r["scenes"])[:6]) + ("..." if nsc > 6 else "") if r else ""
        ops = ",".join(sorted(r["ops"])) if r else ""
        rows.append(f"| {i:02X} | {b['nsub']} | {cgram_range(b)} | {b['frames']} | {b['ticks']} | {how if reached else 'no'} | "
                    f"{r['starts'] if r else 0} | {nsc} {sc} | {ops} | {ticks_obs} | {(str(r['capdiff']) + '/' + str(r['caps'])) if r else '-'} | {r1s} |")
        if not reached:
            never.append(i)
    with open(os.path.join(RAW, "E2_bundles.md"), "w") as o:
        o.write("# E2 bundle table (bundle id -> CGRAM range, frames, ticks, runtime coverage)\n\n")
        o.write("Static: decoded from `palette_bundles` (ROM offset 1474560) by `kit/lib/e2_palette.lua` `e2.decode` (`raw/E2_static.txt`). "
                "Runtime: `raw/E2_*` files " + ", ".join(os.path.basename(f) for f in files) + ".\n\n")
        o.write("Columns: id; sub-entries; CGRAM colour index range (`+bd` = also a 3-byte backdrop sub-entry); total frames (sum of N); static ticks (sum N*(wait+1)); "
                "reached (`sweep` = scene sweep, `trg` = targeted run only); starts logged; scenes (count, first six, hex ids); ops (op36 PaletteRestart, op37 PaletteStart, op38 PaletteStartLoop, op39 PaletteStep, op3A PaletteStepLoop callers at the start); "
                "observed ticks of the first ends (`ticks`x`count`); captures with a CGRAM/staging change / captures; R1 (`tbl` reads of the table entry, `list` bytes touched of the sub-entry list, `data` bytes touched of the frame data).\n\n")
        o.write("| id | sub | CGRAM | frames | ticks | reached | starts | scenes | start ops | ticks obs | cap diff | R1 |\n|---|---|---|---|---|---|---|---|---|---|---|---|\n")
        o.write("\n".join(rows) + "\n\n")
        xr = json.load(open(os.path.join(RAW, "E2_xref.json"))) if os.path.exists(os.path.join(RAW, "E2_xref.json")) else {}
        o.write("## Bundles never started at runtime: static references (extracted/, `harness/e2_xref.py`)\n\n| id | CGRAM | static references (file:line, kind) |\n|---|---|---|\n")
        for i in never:
            refs = xr.get(f"{i:02X}", [])
            txt = "; ".join(f"{r['file'].split(chr(92))[-1]}:{r['line']} ({r['kind']})" for r in refs[:4]) if refs else "none found by the xref scan (operand not an immediate, or unreferenced)"
            o.write(f"| {i:02X} | {cgram_range(B[i])} | {txt} |\n")
        o.write("\n")
        o.write(f"Reached: {128 - len(never)} of 128. Never started at runtime: {len(never)}: " + " ".join(f"{i:02X}" for i in never) + "\n")
    json.dump(merged, open(os.path.join(RAW, "E2_merged.json"), "w"), indent=0, default=str)
    print("reached", 128 - len(never), "never", len(never))
    print(" ".join(f"{i:02X}" for i in never))


if __name__ == "__main__":
    main()
