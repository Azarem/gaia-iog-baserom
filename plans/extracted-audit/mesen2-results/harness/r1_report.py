#!/usr/bin/env python3
"""R1 report: raw/R1_acc.json + raw/R1_ranges.json -> raw/R1_table.md (one line per range) and a per-id summary on stdout.
usage: python r1_report.py [id ...]     (no id: summary of every id; with ids: also the full rows of those ids)
CDL flag bits (Mesen CdlFlags): 0x01 code, 0x02 data, 0x04 jump target, 0x08 sub entry point, 0x10 index 8-bit, 0x20 mem 8-bit.
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
RAW = os.path.join(HERE, "..", "raw")
R = json.load(open(os.path.join(RAW, "R1_ranges.json")))["rows"]
A = json.load(open(os.path.join(RAW, "R1_acc.json")))
LEGS = json.load(open(os.path.join(RAW, "R1_legs.json")))

# Fold the dedicated probe runs (raw/R1_probe_*.json, result.touched) into the counters: keyed by (label, start).
import glob
_key = {(r["name"], r["start"]): r["req"] for r in R}
PROBES = 0
for _f in sorted(glob.glob(os.path.join(RAW, "R1_probe_*.json"))):
    _d = json.load(open(_f, encoding="utf-8"))
    _res = _d.get("result", _d)
    _tag = "probe:" + os.path.basename(_f)[len("R1_probe_"):-5]
    PROBES += 1
    for _t in _res.get("touched", []):
        _req = _key.get((_t["label"], _t["start"]))
        if not _req:
            continue
        _a = A[_req]
        for _k in ("exec", "read", "write", "execFirstByte"):
            _a[_k] += _t.get(_k, 0)
        _a["legs"][_tag] = _a["legs"].get(_tag, 0) + _t.get("exec", 0) + _t.get("read", 0) + _t.get("write", 0)


def row(r):
    a = A[r["req"]]
    return a


def fmt(r):
    a = row(r)
    return (f"| {r['name']} | {r['start']}..{r['end']} | {a['exec']} | {a['execFirstByte']} | {a['execBytes']}/{r['end'] - r['start'] + 1} | {a['read']} | {a['write']} | "
            f"{a['cdlFlags']:02X} | {a.get('cdlCodeBytes', 0)}c {a.get('cdlDataBytes', 0)}d | {','.join(sorted(a['legs'], key=lambda k: -a['legs'][k])[:3])} |")


def main():
    want = set(sys.argv[1:])
    by = {}
    for r in R:
        by.setdefault(r["id"], []).append(r)
    out = ["| label | offset | exec (byte sum) | exec starts | exec bytes/len | read | write | CDL flags | CDL bytes | top legs |", "|---|---|---|---|---|---|---|---|---|---|"]
    for id_, rows in by.items():
        out.append(f"| **{id_}** | | | | | | | | | |")
        for r in rows:
            out.append(fmt(r))
    open(os.path.join(RAW, "R1_table.md"), "w", encoding="utf-8").write("\n".join(out) + "\n")
    tot = sum(l.get("frames", 0) for l in LEGS)
    nmi = sum(l.get("nmi", 0) for l in LEGS)
    print("probe files folded", PROBES, "legs", len(LEGS), "frames", tot, "nmi (positive control)", nmi)
    for id_, rows in by.items():
        hit = [r for r in rows if row(r)["exec"] or row(r)["read"] or row(r)["write"]]
        print(f"{id_:8s} ranges {len(rows):4d} touched {len(hit):4d}")
        if id_ in want:
            for r in rows:
                print(fmt(r))


main()
