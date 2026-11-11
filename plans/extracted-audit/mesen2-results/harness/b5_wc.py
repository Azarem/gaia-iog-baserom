#!/usr/bin/env python3
"""BA-12 / BA-17 / BA-13: natural geometry search results (layers_<date>.json) -> run the WestRampUp corner label (186943) on the first candidates of each scene.
Per scene a disposable state (warp from S01r, 30 frames; file tmp_b5_sceneNN.mss in rebuilt/states, removed at the end), then per candidate cell (a $05 cell with a free
cell east and a solid cell two east): the player is placed one cell west of it (probe-aligned) and holds right for 90 frames; hooks WCorner / WestRampUp / EastRampDown."""
import json
import os
import sys
sys.path.insert(0, ".")
from b5_common import *
import scenario_b4 as b4
from scenario_b4 import case, FCOLS

CAND = json.load(open("/tmp/cands.json"))
HK = [{"name": n, "off": o, "slot": None, "cols": [0x1014, 0x1016, [0x09B2, True], [0x09B4, True], 0x0026, 0x0022, 0x09AE]} for n, o in
      (("WCorner", 186943), ("WestRampUp", 186758), ("WestRampDescend", 187010 - 0), ("EastRampDown", 186435))]

def main():
    m = open_session()
    from scenario_b1_census import FLAGS
    by = {}
    for sc, tx, ty in CAND["res12"]:
        by.setdefault(sc, []).append((tx, ty))
    out = []
    for sc, lst in sorted(by.items()):
        if sc == 21:
            continue
        w = warp_scene(m, sc, FLAGS.get(sc, []))
        path = st(f"tmp_b5_scene{sc:02X}.mss")
        m.call("advance_frame", frames=30)
        m.call("save_state_file", path=path, note="tmp B5 BA-12", meta={"scene": sc})
        picks = lst[:3]
        for tx, ty in picks:
            pl = [tx * 16 - 8 + 8, ty * 16 + 16]   # actor X = (tx-1)*16 + 16: probe column tx-1
            c = case(f"s{sc:02X} ({tx},{ty})", 90, [[90, ["right"]]], state=path, hooks=HK, cols=FCOLS, place=pl, maxEvents=500)
            res = []
            for rep in range(2):
                res.append(b4.run_case(m, c, path))
            r = res[0]
            f = r["frames"]
            cnt = {}
            for e in r["events"]:
                cnt[e[1]] = cnt.get(e[1], 0) + 1
            same = [q["frames"] for q in res][0] == [q["frames"] for q in res][1]
            print(c["name"], "start", f[0][1:3], "end", f[-1][1:3], "ctl", r["controlOk"], cnt, "repeat-identical", same, flush=True)
            out.append({"case": c["name"], "scene": sc, "cell": [tx, ty], "start": f[0][1:3], "end": f[-1][1:3], "counts": cnt, "ctl": r["controlOk"], "identical": same})
        os.remove(path)
    save("wc_natural", out)
    m.close()

main()
