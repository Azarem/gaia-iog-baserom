#!/usr/bin/env python3
"""Condensed per-address reader / writer tables for the W1-b result file, from raw/W1b_merged.json (written by w1b_report.py).

One table per watch: kind, ROM offset, routine, file:line, count, number of scenes, plus the static sites that never ran. Output: raw/W1b_tables.md
(the result file pastes it as section "Per-address census"). usage: w1b_tables.py
"""
import json
import os

from a_common import RAW

ORDER = ["06A0", "06C6-06C7", "06C8", "06CA-06CB", "06CC-06CD", "06EE-06EF", "06EF bit4(0x10)", "06F0", "06F2", "0402-0405", "0D6E-0D6F", "09CC-09CF",
         "0A1F flag FF bit7", "0A1F bit7 change", "7F0600-06FF", "00DA"]


def main():
    m = json.load(open(os.path.join(RAW, "W1b_merged.json"), encoding="utf-8"))
    L = []
    static_by = {}
    for r in m["static"]:
        static_by.setdefault(r["watch"], []).append(r)
    for w in ORDER:
        rows = [r for r in m["rows"] if r["watch"] == w]
        dma = [r for r in rows if r["cls"] == "DMA/HDMA-attributed"]
        real = [r for r in rows if r["cls"] != "DMA/HDMA-attributed"]
        L.append(f"### `{w}`\n")
        L.append("| Kind | Offset | Routine | file:line | Count | Scenes |")
        L.append("|---|---|---|---|---|---|")
        agg = {}
        for r in real:
            k = (r["kind"], r["off"])
            g = agg.setdefault(k, dict(r=r, n=0, scenes=set()))
            g["n"] += r["n"]
            g["scenes"].update(r["scenes"].keys())
        for (kind, off), g in sorted(agg.items(), key=lambda kv: (kv[0][0], kv[0][1] if kv[0][1] is not None else -1)):
            r = g["r"]
            L.append(f"| {kind} | {off} | `{r['routine']}` | `{r['where']}` | {g['n']} | {len(g['scenes'])} |")
        if dma:
            n = sum(r["n"] for r in dma)
            L.append(f"| write | (boot DMA fill) | callbacks attributed to PCs that cannot access the byte (cold boot) | - | {n} | 0 |")
        seen = {off for (_, off) in agg}
        missing = [r for r in static_by.get(w, []) if r.get("off") not in seen]
        if missing:
            L.append("")
            L.append("Static sites with no runtime hit: " + "; ".join(f"{r['off']} `{r['routine']}` ({r['access']})" for r in missing) + ".")
        L.append("")
    out = os.path.join(RAW, "W1b_tables.md")
    with open(out, "w", encoding="utf-8") as f:
        f.write("\n".join(L))
    print("wrote", out, len(L), "lines")


if __name__ == "__main__":
    main()
