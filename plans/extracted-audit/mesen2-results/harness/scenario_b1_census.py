#!/usr/bin/env python3
"""Scenario B1: collision census over the scene ids of artifacts/scenes.json (plan section 7 B1).

For every scene id: load the ready state `S01r` (same start every time, so the census is reproducible), quick warp
(`$0642 = id`, up to 300 frames until `$0644 == id`), dismiss the scene banner (A pulses until `$00B4 == 0`, at most 12
tries), 30 frames, then ONE `run_script` with includes ["gaia_kit"] that calls `gaia.coll.censusRun(...)`: every cell
of the paged collision layer is read with `gaia.coll.get`, and the row (histograms of the low and the high nibble, bounds
words, strides, the first ten cells of types $06 and $09 ...) is returned with `kit.finish`. The row carries the positive
control `control36Writes` (writes of the frame counter $36 seen by the run).

usage: scenario_b1_census.py [--rom PATH] [--tag O] [--first N] [--count N] [--scenes 1,2,3] [--out DIR] [--name B1_census]
Writes <out>/<name>_<tag>_<first>-<last>.json (one file per batch) and prints one line per scene.
"""
import argparse
import json
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from mcp_client import Mesen  # noqa: E402

RESULTS = os.path.abspath(os.path.join(HERE, ".."))
BASEROM = os.path.abspath(os.path.join(HERE, "..", "..", "..", ".."))
ROM_O = os.path.join(BASEROM, "rebuilt", "Illusion of Gaia.smc")
STATE = os.path.join(BASEROM, "rebuilt", "states", "orig_S01r_south-cape-ready.mss")
SCENES = os.path.join(BASEROM, "artifacts", "scenes.json")

# the Lua of every scene run (verbatim in the result file)
CENSUS_LUA = "gaia.coll.censusRun({6, 9, 4, 14}, 10, 6)"

# scenes that need an event flag for the player to be free (db-us/scene-flags.json)
FLAGS = {10: [63]}


def set_flag(m, n):
    addr = 0x0A00 + (n >> 3)
    m.poke(addr, [m.u8(addr) | (1 << (n & 7))])


def warp(m, scene, max_frames=300):
    """State S01r is loaded; returns dict(ok, frames, banner, mask)."""
    for n in FLAGS.get(scene, []):
        set_flag(m, n)
    m.poke(0x642, scene)
    # $0644 takes the new id at the start of the load; the load itself needs about 250 frames (plan H3): run the full 300
    m.call("advance_frame", frames=max_frames)
    done = max_frames
    ok = m.u16(0x644) == scene and m.u16(0x642) == 0
    extra = 0
    while not ok and extra < 200:
        m.call("advance_frame", frames=20)
        extra += 20
        ok = m.u16(0x644) == scene and m.u16(0x642) == 0
    done += extra
    tries = 0
    while m.u8(0xB4) != 0 and tries < 12:
        m.call("set_input", buttons=["a"], frames=2)
        m.call("advance_frame", frames=4)
        tries += 1
        done += 6
    m.call("advance_frame", frames=30)
    done += 30
    return {"ok": ok, "warpFrames": done, "bannerTries": tries, "bannerLeft": m.u8(0xB4), "maskAfterBanner": m.u16(0x65A)}


def census_scene(m, scene):
    m.call("load_state_file", path=STATE)
    w = warp(m, scene)
    r = m.run_script_checked(CENSUS_LUA, name="b1_census", includes=["gaia_kit"], frames=20, turbo=True)
    row = r["result"]
    row.update(w)
    row["requested"] = scene
    return row


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--rom", default=ROM_O)
    ap.add_argument("--tag", default="O")
    ap.add_argument("--first", type=int, default=0, help="index into the id list of scenes.json")
    ap.add_argument("--count", type=int, default=20)
    ap.add_argument("--scenes", default="", help="comma list of ids; overrides --first/--count")
    ap.add_argument("--out", default=os.path.join(RESULTS, "raw"))
    ap.add_argument("--name", default="B1_census")
    ap.add_argument("--mode", default="census", choices=["census", "flow"],
                    help="census: gaia.coll.censusRun; flow: gaia.coll.flowRun (collision byte vs metatile flag table, OQ-3)")
    args = ap.parse_args()
    global CENSUS_LUA
    if args.mode == "flow":
        CENSUS_LUA = "gaia.coll.flowRun({6, 9}, 6)"
        if args.name == "B1_census":
            args.name = "B1_flow"
    ids = json.load(open(SCENES, encoding="utf-8"))["ids"]
    batch = [int(x) for x in args.scenes.split(",")] if args.scenes else ids[args.first:args.first + args.count]
    lib = os.path.join(RESULTS, "kit", "lib")
    rows = []
    t0 = time.time()
    with Mesen(args=[f"--mcp-lib-dir={lib}", f"--mcp-results-dir={args.out}"]) as m:
        info = m.call("load_rom", path=args.rom)["rom"]
        m.call("pause")
        assert info["fileSha1"] == "38de0c84dd2bc3bdfc0a3d7ab0220c79b70887c3", "not the original ROM"
        for sc in batch:
            try:
                row = census_scene(m, sc)
            except Exception as e:  # keep going: record the failure
                row = {"requested": sc, "error": str(e)[:300]}
            rows.append(row)
            if "error" in row:
                print(f"{sc:3d} ERROR {row['error']}")
                continue
            if args.mode == "flow":
                print(f"{sc:3d} cur={row['scene']:3d} ok={row['ok']!s:5} cells={row['cells']:5d} mismatches={row['mismatches']:5d} "
                      f"bit9words={row['usedMetatileWordsWithBit9']} dual={row['scrollMode06EF'] & 1} ctl={row['control36Writes']}")
                continue
            low = row["low"]
            print(f"{sc:3d} cur={row['scene']:3d} ok={row['ok']!s:5} {row['boundsX']:5d}x{row['boundsY']:5d} stride={row['stride']} "
                  f"06={low[6]:4d} 09={low[9]:4d} 05={low[5]:4d} 0A={low[10]:4d} 0E={low[14]:4d} ctl={row['control36Writes']}")
    last = batch[-1] if batch else 0
    out = os.path.join(args.out, f"{args.name}_{args.tag}_{batch[0]:03d}-{last:03d}.json")
    with open(out, "w", encoding="utf-8") as f:
        json.dump({"tag": args.tag, "rom": info, "state": STATE, "lua": CENSUS_LUA, "seconds": round(time.time() - t0, 1),
                   "rows": rows}, f, indent=1)
    print("wrote", out, round(time.time() - t0, 1), "s")


if __name__ == "__main__":
    main()
