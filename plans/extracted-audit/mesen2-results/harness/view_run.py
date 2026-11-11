#!/usr/bin/env python3
"""Print the log / sampled rows of a stored run, filtered by frame.

usage (from anywhere): view_run.py <prefix_name> [from] [to] [log|samp|both]
  view_run.py A4_K1b_gem_pickup_control 380 440 both        newest raw/A4_K1b_gem_pickup_control_<date>.json
Rows are the Lua strings the scenario collected in `final.log` / `final.sampled` (each starts with the frame number).
"""
import glob
import json
import os
import sys

RAW = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "raw"))


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 1
    name = sys.argv[1]
    lo = int(sys.argv[2]) if len(sys.argv) > 2 else 0
    hi = int(sys.argv[3]) if len(sys.argv) > 3 else 10 ** 9
    what = sys.argv[4] if len(sys.argv) > 4 else "both"
    files = sorted(glob.glob(os.path.join(RAW, f"{name}_2*.json")))
    if not files:
        print("no file for", name)
        return 1
    fin = json.load(open(files[-1], encoding="utf-8")).get("final") or {}
    for key, show in (("log", "log"), ("sampled", "samp"), ("rows", "log")):
        if what in (show, "both") and key in fin:
            for line in fin[key]:
                head = line.split()[0]
                if head.isdigit() and not lo <= int(head) <= hi:
                    continue
                print(line)
    return 0


if __name__ == "__main__":
    sys.exit(main())
