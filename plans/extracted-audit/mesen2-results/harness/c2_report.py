#!/usr/bin/env python3
"""C2 report: merge raw/C2_*_<date>.json, map offsets to routines through db-us/names/bankNN.json (read only).

usage: python c2_report.py [--date yyyymmdd] [--only a,b]
Prints (1) the $4200 writer table over all runs, (2) callers of EnableNmiAndJoypad / DisableNmiKeepJoypad / VBlankWaitAndJoypad /
WaitFrames by JSL offset with the NMITIMEN state seen at entry, (3) per-run coverage. Writes nothing.
"""
import argparse
import bisect
import datetime
import glob
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
RESULTS = os.path.abspath(os.path.join(HERE, ".."))
BASEROM = os.path.abspath(os.path.join(HERE, "..", "..", "..", ".."))


def load_names():
    names = {}
    for p in glob.glob(os.path.join(BASEROM, "db-us", "names", "bank*.json")):
        with open(p, encoding="utf-8") as fh:
            for k, v in json.load(fh).items():
                names[int(k)] = v
    keys = sorted(names)
    return names, keys


NAMES, KEYS = load_names()


def routine(off):
    i = bisect.bisect_right(KEYS, off) - 1
    if i < 0:
        return "?"
    k = KEYS[i]
    return f"{NAMES[k]}+{off - k}" if off != k else NAMES[k]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--date", default=datetime.date.today().strftime("%Y%m%d"))
    ap.add_argument("--only", default="")
    a = ap.parse_args()
    runs = {}
    for p in sorted(glob.glob(os.path.join(RESULTS, "raw", f"C2_*_{a.date}.json"))):
        d = json.load(open(p, encoding="utf-8"))
        if "scenario" in d:
            runs[d["scenario"]] = d
    if a.only:
        runs = {k: v for k, v in runs.items() if k in a.only.split(",")}

    print("== runs")
    for n, d in runs.items():
        r = d["reply"]["result"]
        sl = d.get("stateLoad")
        chk = (sl.get("romCheck") if isinstance(sl, dict) else None) if sl else "cold boot"
        c = r["control"]
        print(f"{n:14} frames {r['frames']:5} nmiExec {c['nmiExec']:5} w36 {c['w36Writes']:5} w4200 {c['w4200Writes']:5} "
              f"state {d.get('stateFile', '-')} romCheck {chk} end scene {r['final']['scene']:04X} k {r['final']['k']:02X} sp {r['final']['sp']:04X}")

    print("\n== $4200 writers, all runs (offset = PRG offset of the instruction after the store)")
    W = {}
    for n, d in runs.items():
        for key, e in d["reply"]["result"]["writes"].items():
            off, val = key.split("=")
            row = W.setdefault(key, dict(n=0, runs=[], first=None, hw0=0, hw1=0, prev={}, pc24=e["pc24"], alias=e["alias"]))
            row["n"] += e["n"]
            row["runs"].append(n)
            row["hw0"] += e["hw0"]
            row["hw1"] += e["hw1"]
            for k, v in e["prev"].items():
                row["prev"][k] = row["prev"].get(k, 0) + v
            if n.startswith("boot") and (row["first"] is None):
                row["first"] = e["first"]
    for key, row in sorted(W.items()):
        off, val = key.split("=")
        o = int(off, 16)
        print(f"{o:7} ({off}) = ${val}  K:PC {row['pc24'][:2]}:{row['pc24'][2:]}  alias {row['alias']}  n {row['n']}  hw before {row['hw0']}/{row['hw1']}(off/on) "
              f"prev {row['prev']}  first(boot) {row['first']}  runs {len(row['runs'])}  -> {routine(o - 1)} .. {routine(o)}")

    print("\n== NMI state at the entry of the sampled routines (nt = last NMITIMEN value written, hw = hardware NMI enable bit)")
    A = {}
    for n, d in runs.items():
        for key, c in (d["reply"]["result"].get("at") or {}).items():
            row = A.setdefault(key, dict(n=0, runs=set()))
            row["n"] += c
            row["runs"].add(n)
    for key, row in sorted(A.items()):
        print(f"{key:48} n {row['n']:6}  runs {','.join(sorted(row['runs']))}")

    print("\n== adhoc VRAM DMA staging pairs ($7F0C07 dest store -> $7F0C09 size store)")
    P = {}
    for n, d in runs.items():
        for key, c in (d["reply"]["result"].get("adhoc") or {}).items():
            row = P.setdefault(key, dict(n=0, runs=set()))
            row["n"] += c
            row["runs"].add(n)
    for key, row in sorted(P.items()):
        print(f"{key:60} n {row['n']:5}  runs {','.join(sorted(row['runs']))}")

    print("\n== callers by JSL offset")
    E = {}
    for n, d in runs.items():
        for key, e in d["reply"]["result"]["entries"].items():
            who, rest = key.split(" <- ")
            off_s, nt, hw = rest.split()
            row = E.setdefault((who, int(off_s, 16), nt, hw), dict(n=0, runs=set(), first=None, scene=None))
            row["n"] += e["n"]
            row["runs"].add(n)
    for (who, off, nt, hw), row in sorted(E.items()):
        print(f"{who:22} <- JSL at {off:7} ({off:06X}) {routine(off):34} {nt} {hw}  n {row['n']:6}  runs {','.join(sorted(row['runs']))}")


if __name__ == "__main__":
    main()
