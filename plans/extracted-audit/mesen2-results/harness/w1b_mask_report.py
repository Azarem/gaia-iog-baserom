#!/usr/bin/env python3
"""Summary of the W1-b follow-up sessions (`w1b_session.py --mask`): reads of $0A1F keyed on the accumulator mask (TestEventFlag: A = bit mask,
$80 = flag $FF) with the actor context, and the $0080 probe at FillCollisionFromLayer1 (OQ-4). Output: raw/W1b_mask_report.md.

usage: w1b_mask_report.py [--date YYYYMMDD]
"""
import argparse
import glob
import json
import os
from collections import defaultdict

from a_common import RAW


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--date", default="20261107")
    args = ap.parse_args()
    files = sorted(glob.glob(os.path.join(RAW, f"W1bm_*_{args.date}.json")))
    by_mask = defaultdict(int)
    by_ctx = defaultdict(lambda: defaultdict(int))
    pcs = defaultdict(int)
    scenes_ff = defaultdict(int)
    probe = defaultdict(int)
    nses = 0
    cls = defaultdict(int)
    for f in files:
        d = json.load(open(f, encoding="utf-8"))
        fin = d["final"]
        nses += 1
        for r in fin["rows"]:
            if r["name"] != "0A1F mask":
                continue
            pcs[r["pc"]] += r["n"]
            for k, c in r["ctx"]:
                a = k.split(":")[0]
                by_mask[(r["pc"], a)] += c
                by_ctx[(r["pc"], a)][k] += c
                dd = int(k.split(":")[1][1:], 16)
                cls[(r["pc"], a, "thinker pool D=0F00-0FFF" if 0x0F00 <= dd < 0x1000 else ("actor slot D>=1000" if dd >= 0x1000 else "D<0F00"))] += c
            for sc, c in r["scenes"]:
                scenes_ff[(r["pc"], sc)] += c
        for p in fin.get("probes", []):
            if p["name"] == "collL1_0080":
                for k, c in p["vals"]:
                    probe[k] += c
    L = [f"# W1-b follow-up: $0A1F reads by mask, $0080 probe ({args.date})\n", f"sessions: {nses}\n", "## $0A1F read callbacks by PC\n"]
    for pc, n in sorted(pcs.items()):
        L.append(f"- {pc}: {n}")
    L.append("\n## by (PC, accumulator mask at the read); ctx = actor D / entry word (first 40 distinct per PC and session)\n")
    L.append("| PC | A (mask) | count | top contexts |")
    L.append("|---|---|---|---|")
    for (pc, a), n in sorted(by_mask.items(), key=lambda kv: (kv[0][0], -kv[1])):
        ctx = sorted(by_ctx[(pc, a)].items(), key=lambda kv: -kv[1])[:5]
        L.append(f"| {pc} | {a} | {n} | " + "; ".join(f"{k}:{c}" for k, c in ctx) + " |")
    L.append("\n## by caller class (only the contexts the script recorded: first 40 distinct per PC and session)\n")
    for (pc, a, c), n in sorted(cls.items()):
        L.append(f"- {pc} A={a}: {c}: {n}")
    L.append("\n## $0080 word at FillCollisionFromLayer1 (value@scene:count)\n")
    L.append(", ".join(f"{k}:{c}" for k, c in sorted(probe.items())))
    out = os.path.join(RAW, "W1b_mask_report.md")
    with open(out, "w", encoding="utf-8") as fh:
        fh.write("\n".join(L) + "\n")
    print("wrote", out)


if __name__ == "__main__":
    main()
