#!/usr/bin/env python3
"""Merge the B1 batch files (raw/B1_census_O_*.json) into raw/B1_census.md and print the summaries the result file quotes.

usage: b1_report.py [--raw DIR]
Reads only; writes raw/B1_census.md and raw/B1_census_merged.json.

Validity of a row (column `census`):
  ok                    the layer was rebuilt for this scene and the positive control fired
  stale                 the scene did not load a map: bounds and low-nibble histogram equal South Cape's, which is the scene of the
                        start state (the layer still holds that map)
  not rebuilt ($F7)     SceneScriptMain skips RebuildCollisionLayer for scene $F7 (scene_script.asm), the bytes are leftovers
  control failed        the frame counter $36 was not written during the run (scene $FE)
"""
import argparse
import glob
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
RESULTS = os.path.abspath(os.path.join(HERE, ".."))
BASEROM = os.path.abspath(os.path.join(HERE, "..", "..", "..", ".."))
TYPES = [3, 4, 5, 6, 9, 10, 12, 14]


def pow2(n):
    return n > 0 and (n & (n - 1)) == 0


def validity(sid, r, sc1):
    if "error" in r:
        return "error"
    if r["control36Writes"] < 4:
        return "control failed"
    if sid == 0xF7:
        return "not rebuilt ($F7)"
    if sid != 1 and r["boundsX"] == sc1["boundsX"] and r["boundsY"] == sc1["boundsY"] and r["low"] == sc1["low"]:
        return "stale"
    if not (r["ok"] and r["scene"] == sid):
        return "scene differs"
    return "ok"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--raw", default=os.path.join(RESULTS, "raw"))
    args = ap.parse_args()
    meta = {s["id"]: s for s in json.load(open(os.path.join(BASEROM, "artifacts", "scenes.json"), encoding="utf-8"))["scenes"]}
    rows = {}
    for p in sorted(glob.glob(os.path.join(args.raw, "B1_census_O_*.json"))):
        d = json.load(open(p, encoding="utf-8"))
        for r in d["rows"]:
            rows[r["requested"]] = r
    sc1 = rows[1]
    val = {sid: validity(sid, r, sc1) for sid, r in rows.items()}
    out = ["# B1 collision census, original ROM (O)\n"]
    out.append("Source: `harness/scenario_b1_census.py` (one row per scene id of `artifacts/scenes.json`; state `orig_S01r_south-cape-ready.mss`, quick warp of 300 frames, banner dismissed, 30 frames, then `gaia.coll.censusRun`). Counts are cells of the paged collision layer (16 x 16 px per cell); low nibble = base type; `hiNZ` = cells whose high nibble (dynamic mark) is nonzero. `$0692`/`$0696` = map bounds in pixels; `$069A` = map data size word; `ctl` = writes of `$36` seen by the run (positive control, expect 5 in 6 frames); `mask` = `$065A` after the banner; `census` = validity of the row (see the header of `harness/b1_report.py`).\n")
    hdr = ("| id | key | scene read | bounds X x Y (px) | stride | rows | cells | " + " | ".join(f"${t:02X}" for t in TYPES)
           + " | hiNZ | `$069A` | `$0692` pow2 | `$0696` pow2 | ctl | banner left | mask | census |")
    out.append(hdr)
    out.append("|" + "---|" * (hdr.count("|") - 1))
    for sid in sorted(rows):
        r = rows[sid]
        k = meta.get(sid, {}).get("key", "?")
        if "error" in r:
            out.append(f"| ${sid:02X} | {k} | ERROR {r['error'][:60]} |")
            continue
        low, hi = r["low"], r["hi"]
        out.append(f"| ${sid:02X} | {k} | ${r['scene']:02X} | {r['boundsX']} x {r['boundsY']} | {r['stride']} | {r['rows']} | {r['cellsW'] * r['cellsH']} | "
                   + " | ".join(str(low[t]) for t in TYPES)
                   + f" | {sum(hi[1:])} | {r['size069A']} | {'y' if pow2(r['boundsX']) else 'n'} | {'y' if pow2(r['boundsY']) else 'n'} | {r['control36Writes']} | {r['bannerLeft']:02X} | {r['mask']:04X} | {val[sid]} |")
    out.append("")
    out.append("## Full low-nibble histogram (cells per type `$00`-`$0F`) of every valid row\n")
    out.append("| id | " + " | ".join(f"{t:X}" for t in range(16)) + " |")
    out.append("|" + "---|" * 17)
    for sid in sorted(rows):
        if val[sid] == "ok":
            out.append(f"| ${sid:02X} | " + " | ".join(str(c) for c in rows[sid]["low"]) + " |")
    out.append("")
    out.append("## Scenes with `$06` or `$09` (valid rows only)\n")
    out.append("| id | key | $06 | $09 | first `$06` cells (tx,ty) | first `$09` cells (tx,ty) |")
    out.append("|---|---|---|---|---|---|")
    with69 = []
    for sid in sorted(rows):
        r = rows[sid]
        if val[sid] != "ok":
            continue
        n6, n9 = r["low"][6], r["low"][9]
        if n6 or n9:
            with69.append(sid)
            f = r["first"]
            c6 = " ".join(f"({a},{b})" for a, b, _ in f["06"])
            c9 = " ".join(f"({a},{b})" for a, b, _ in f["09"])
            out.append(f"| ${sid:02X} | {meta[sid]['key']} | {n6} | {n9} | {c6} | {c9} |")
    out.append("")
    notok = {f"${s:02X}": v for s, v in val.items() if v != "ok"}
    out.append(f"Rows that are not valid census rows: {notok}\n")

    # flow check (scenario_b1_census.py --mode flow): collision low nibble against flagTable[mapData[i]] & 15
    flow = {}
    for p in sorted(glob.glob(os.path.join(args.raw, "B1_flow_O_*.json"))):
        for r in json.load(open(p, encoding="utf-8"))["rows"]:
            flow[r["requested"]] = r
    if flow:
        out.append("## Flow check: collision low nibble against flagTable[mapData[i]] (valid rows)\n")
        out.append("`mismatch` = cells whose collision low nibble differs from the flag-table nibble of the metatile in the map data at the same index. "
                   "`dual` = `$06EF` bit 0 (layer 1 overlays nonzero flags). `bit9` = words of the metatiles in use whose bit 9 is still set in the metatile definitions.\n")
        fv = [flow[s] for s in sorted(rows) if val[s] == "ok" and s in flow]
        single = [r for r in fv if not r["scrollMode06EF"] & 1]
        out.append(f"Valid rows: {len(fv)}; single-layer: {len(single)} ({sum(1 for r in single if not r['mismatches'])} with 0 mismatches, "
                   f"{sum(1 for r in single if r['mismatches'])} with mismatches); dual-layer: {len(fv) - len(single)}; cells compared: {sum(r['cells'] for r in fv)}; "
                   f"metatile words in use with bit 9 set: {sum(r['usedMetatileWordsWithBit9'] for r in fv)}; flag table pointer `$06AA` values: {sorted({r['flagTable'] for r in fv})}; "
                   f"definitions `$06AE`: {sorted({r['defTable'] for r in fv})}; map data `$069E`: {sorted({r['baseA'] for r in fv})}.\n")
        out.append("| id | key | dual | cells | mismatch | first mismatches (index, metatile, collision, flag) |")
        out.append("|---|---|---|---|---|---|")
        for r in fv:
            if r["mismatches"]:
                out.append(f"| ${r['requested']:02X} | {meta[r['requested']]['key']} | {'y' if r['scrollMode06EF'] & 1 else 'n'} | {r['cells']} | {r['mismatches']} | "
                           + " ".join(str(tuple(x)) for x in r["firstMismatches"]) + " |")
        out.append("")

    # screenshots (scenario_b1_shots.py --all)
    shots = []
    for p in sorted(glob.glob(os.path.join(args.raw, "B1_shots_O_*.json"))):
        shots += json.load(open(p, encoding="utf-8"))["rows"]
    if shots:
        out.append("## Screenshots next to the first `$06` / `$09` cell (30 frames after writing `$1014/$1016`)\n")
        out.append("`shot valid` = the scene id stayed the same and the actor position after 30 frames equals the written position (the player did not walk or get moved). "
                   "A shot with `no` may show another scene or a moved player.\n")
        out.append("| id | type | cell | player cell | actor written | actor after | scene after | shot valid | file |")
        out.append("|---|---|---|---|---|---|---|---|---|")
        for r in shots:
            if "error" in r or r.get("cell") is None:
                continue
            okv = r.get("sceneNow") == r["scene"] and r.get("actorAfter") == r.get("actorXY")
            out.append(f"| ${r['scene']:02X} | ${r['type']:02X} | {tuple(r['cell'])} | {tuple(r['playerCell'])} | {tuple(r['actorXY'])} | {tuple(r['actorAfter'])} | ${r['sceneNow']:02X} | "
                       f"{'yes' if okv else 'no'} | `{os.path.basename(r['shot'])}` |")
        out.append("")
    path = os.path.join(args.raw, "B1_census.md")
    with open(path, "w", encoding="utf-8") as f:
        f.write("\n".join(out) + "\n")
    with open(os.path.join(args.raw, "B1_census_merged.json"), "w", encoding="utf-8") as f:
        json.dump({str(k): dict(v, census=val[k]) for k, v in rows.items()}, f)
    good = [r for s, r in rows.items() if val[s] == "ok"]
    print("rows", len(rows), "valid", len(good), "not valid", notok)
    n6 = sum(1 for r in good if r["low"][6]); n9 = sum(1 for r in good if r["low"][9])
    print("valid scenes with $06:", n6, " with $09:", n9, " with both:", sum(1 for r in good if r["low"][6] and r["low"][9]),
          " with either:", len(with69))
    only = [(s, rows[s]["low"][6], rows[s]["low"][9]) for s in with69 if not (rows[s]["low"][6] and rows[s]["low"][9])]
    print("only one of $06/$09:", [("%02X" % s, a, b) for s, a, b in only])
    print("valid scenes with $03:", sum(1 for r in good if r["low"][3]), "$04:", sum(1 for r in good if r["low"][4]),
          "$05:", sum(1 for r in good if r["low"][5]), "$0A:", sum(1 for r in good if r["low"][10]),
          "$0C:", sum(1 for r in good if r["low"][12]), "$0E:", sum(1 for r in good if r["low"][14]))
    print("valid scenes with hi nibble nonzero:", sum(1 for r in good if sum(r["hi"][1:])))
    print("non power-of-two boundsX:", sum(1 for r in good if not pow2(r["boundsX"])), " boundsY:", sum(1 for r in good if not pow2(r["boundsY"])),
          " either:", sum(1 for r in good if not (pow2(r["boundsX"]) and pow2(r["boundsY"]))))
    mism = [(s, r["size069A"], r["stride"] * r["rows"] * 256) for s, r in rows.items() if r["size069A"] != r["stride"] * r["rows"] * 256]
    print("size069A != stride*rows*256:", len(mism), "of", len(rows))
    print("size069C != stride1*rows1*256:", sum(1 for r in rows.values() if r["size069C"] != r["stride1"] * r["rows1"] * 256))
    print("bounds not multiple of 256:", sum(1 for r in rows.values() if r["boundsX"] & 255 or r["boundsY"] & 255))
    print("max pages:", max(r["stride"] * r["rows"] for r in rows.values()), " clamped:", [s for s, r in rows.items() if r["clamped"]])
    print("dual-layer (06EF bit0):", [("%02X" % s) for s, r in rows.items() if r["scrollMode06EF"] & 1])
    print("0E scenes:", len([1 for r in good if r["low"][14]]), " 0E cells total:", sum(r["low"][14] for r in good))
    print("04 scenes:", [("%02X" % s, rows[s]["low"][4]) for s in sorted(rows) if val[s] == "ok" and rows[s]["low"][4]])
    print("03 scenes:", [("%02X" % s, rows[s]["low"][3]) for s in sorted(rows) if val[s] == "ok" and rows[s]["low"][3]])
    print("0C scenes:", [("%02X" % s, rows[s]["low"][12]) for s in sorted(rows) if val[s] == "ok" and rows[s]["low"][12]])
    print("top 05/0A:", sorted([(rows[s]["low"][5] + rows[s]["low"][10], "%02X" % s, meta[s]["key"], rows[s]["low"][5], rows[s]["low"][10]) for s in with69], reverse=True)[:12])
    print("wrote", path)


if __name__ == "__main__":
    main()
