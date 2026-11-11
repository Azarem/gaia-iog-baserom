#!/usr/bin/env python3
"""Merge the A1/A2 census files (raw/A1_*.txt, raw/A2_*.txt) and decode every K:PC with the server's disassembler.

usage: decode_flag_census.py [--tag A1|A2] [--date YYYYMMDD] [--out raw/<tag>_merged_<date>.json]

For each distinct K:PC the instruction that ENDS at the reported PC is found by disassembling from the label that
covers the PC (get_disassembly), together with the three instructions before it, the label + offset, and the
definition site of the label in extracted/ (rg). Nothing here writes outside mesen2-results/raw.
"""
import argparse
import glob
import json
import os
import re
import subprocess
from collections import defaultdict

from a_common import BASEROM, RAW, open_session, stamp

EXTRACTED = os.path.join(BASEROM, "extracted")


def parse_file(path):
    sess = os.path.basename(path).split("_", 1)[1].rsplit("_", 1)[0]
    pcs, writes, reads = {}, [], []
    with open(path, encoding="utf-8") as f:
        for line in f:
            p = line.split()
            if not p:
                continue
            if p[0] == "P":
                pcs[p[1]] = dict(ctx=p[2], ps=int(p[3]), a=int(p[4]), x=int(p[5]), y=int(p[6]), d=int(p[7]), dbr=int(p[8]))
            elif p[0] == "W":
                writes.append(dict(session=sess, word=p[1], bit=int(p[2]), dir=p[3], pc=p[4], n=int(p[5]), nPlayer=int(p[6]),
                                   first=int(p[7]), last=int(p[8]), scene0=p[9], form0=int(p[10]), slot0=p[11],
                                   old=int(p[12]), new=int(p[13]), scenes=p[14], slots=p[15]))
            elif p[0] == "R":
                reads.append(dict(session=sess, field=p[1], pc=p[2], n=int(p[3]), nPlayer=int(p[4]), first=int(p[5]),
                                  last=int(p[6]), scene0=p[7], form0=int(p[8]), slot0=p[9], scenes=p[10], slots=p[11]))
    return pcs, writes, reads


def label_site(label, cache={}):
    if label in cache:
        return cache[label]
    pat = rf"^\s*{re.escape(label)}\s*[:{{\[|]"
    out = subprocess.run(["rg", "-n", "-m", "1", pat, EXTRACTED], capture_output=True, text=True).stdout.strip()
    site = None
    if out:
        first = out.splitlines()[0]
        mm = re.match(r"(.*?):(\d+):", first)
        if mm:
            site = f"{os.path.relpath(mm.group(1), BASEROM).replace(os.sep, '/')}:{mm.group(2)}"
    cache[label] = site
    return site


def decode(m, pc):
    bank, off = (int(x, 16) for x in pc.split(":"))
    cpu = (bank << 16) | off
    r = m.call("resolve_address", cpu=pc)
    label, lo = r.get("label"), r.get("labelOffset") or 0
    start = cpu - lo
    rows = m.call("get_disassembly", address=start, rowCount=min(lo + 10, 2500))["rows"]
    ins = [x for x in rows if x.get("byteCode")]
    hit = None
    for i, x in enumerate(ins):
        ln = len(x["byteCode"].split())
        if x["address"] + ln == cpu:
            hit = i
            break
    res = dict(pc=pc, label=label, labelOffset=lo, site=label_site(label) if label else None, instr=None, prev=[], next=[])
    if hit is not None:
        res["instr"] = f"{ins[hit]['text'].strip()}  [{ins[hit]['byteCode']}]"
        res["prev"] = [f"{y['address'] & 0xFFFF:04X} {y['text'].strip()}" for y in ins[max(0, hit - 3):hit]]
        res["next"] = [f"{y['address'] & 0xFFFF:04X} {y['text'].strip()}" for y in ins[hit + 1:hit + 4]]
        res["at"] = f"{ins[hit]['address'] >> 16:02X}:{ins[hit]['address'] & 0xFFFF:04X}"
    return res


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tag", default="A1")
    ap.add_argument("--date", default=None)
    ap.add_argument("--out", default=None)
    args = ap.parse_args()
    files = sorted(glob.glob(os.path.join(RAW, f"{args.tag}_*_{args.date or '*'}.txt")))
    files = [f for f in files if "merged" not in f]
    pcinfo, W, R = {}, [], []
    for f in files:
        p, w, r = parse_file(f)
        pcinfo.update({k: v for k, v in p.items() if k not in pcinfo})
        W += w
        R += r
    print(len(files), "files,", len(W), "write rows,", len(R), "read rows,", len(pcinfo), "pcs")
    m, info = open_session()
    dec = {}
    try:
        for pc in sorted(set(pcinfo)):
            dec[pc] = decode(m, pc)
    finally:
        m.close()
    out = args.out or os.path.join(RAW, f"{args.tag}_merged_{args.date or stamp()}.json")
    with open(out, "w", encoding="utf-8") as f:
        json.dump({"files": [os.path.basename(x) for x in files], "pcinfo": pcinfo, "decoded": dec, "writes": W, "reads": R}, f, indent=1)
    miss = [pc for pc, d in dec.items() if not d["instr"]]
    print("decoded", len(dec) - len(miss), "unresolved", miss)
    print("wrote", out)


if __name__ == "__main__":
    main()
