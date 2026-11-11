#!/usr/bin/env python3
"""Condensed per-address reader / writer tables for the W1-c result file, from raw/W1c_merged.json (written by w1c_merge.py).

One table per watch (kind, ROM offset, routine, file:line, count, number of scenes), the static sites that never ran, and the grouped callers of the
shared flag helpers. Output: raw/W1c_tables.md (the result file pastes it as section "Per-address census"). usage: w1c_tables.py
"""
import json
import os

from a_common import RAW

ORDER = ["0A00", "0A00 bit0 change", "0A80-0AA7", "0A80-0AA7 change", "0AEC-0AEF", "0AEC-0AEF change"]
CALLER_TOP = 12


def main():
    m = json.load(open(os.path.join(RAW, "W1c_merged.json"), encoding="utf-8"))
    L = []
    static_by = {}
    for r in m["static"]:
        static_by.setdefault(r["watch"], []).append(r)
    callers = {}
    for c in m["callers"]:
        callers.setdefault((c["watch"], c["kind"], c["helper_off"]), []).append(c)
    for w in ORDER:
        rows = [r for r in m["rows"] if r["watch"] == w]
        L.append(f"### `{w}`\n")
        L.append("| Kind | Offset | Routine | file:line | Count | Scenes |")
        L.append("|---|---|---|---|---|---|")
        agg = {}
        for r in rows:
            k = (r["kind"], r["off"])
            g = agg.setdefault(k, dict(r=r, n=0, scenes=set()))
            g["n"] += r["n"]
            g["scenes"].update(r["scenes"].keys())
        for (kind, off), g in sorted(agg.items(), key=lambda kv: (kv[0][0], kv[0][1] if kv[0][1] is not None else -1)):
            r = g["r"]
            L.append(f"| {kind} | {off} | `{r['routine']}` | `{r['where']}` | {g['n']} | {len(g['scenes'])} |")
        seen = {off for (_k, off) in agg}
        miss = [r for r in static_by.get(w.split(" ")[0], []) if r["off"] not in seen and r.get("runtime", 0) == 0]
        if w in ("0A00", "0A80-0AA7", "0AEC-0AEF"):
            L.append("")
            if miss:
                L.append("Static sites with no runtime hit: " + "; ".join(
                    f"{r['off']} `{r['routine']}` ({r['access']}, `{r['where']}`)" for r in sorted(miss, key=lambda r: r['off'])) + ".")
            else:
                L.append("Static sites with no runtime hit: none.")
        L.append("")
        for (cw, kind, helper), cs in sorted(callers.items(), key=lambda kv: (kv[0][1], kv[0][2])):
            if cw != w:
                continue
            L.append(f"Callers of the {kind} at offset {helper} (top {CALLER_TOP}, count = hits attributed to the site):\n")
            L.append("| Caller | Site offset | file:line | Site | Count |")
            L.append("|---|---|---|---|---|")
            for c in sorted(cs, key=lambda c: -c["n"])[:CALLER_TOP]:
                L.append(f"| {c['caller_kind']} | {c['site']} | `{c['where']}` | `{c['text']}` | {c['n']} |")
            L.append("")
    out = os.path.join(RAW, "W1c_tables.md")
    open(out, "w", encoding="utf-8").write("\n".join(L) + "\n")
    print("wrote", out, len(L), "lines")


if __name__ == "__main__":
    main()
