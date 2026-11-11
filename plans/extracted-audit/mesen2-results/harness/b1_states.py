#!/usr/bin/env python3
"""Create the B1 states S13 (slope field, Itory Village $15) and S14 (ramp scene, Great Wall wall_rampway $85) on the original ROM (O).

Per state: load S01r, quick warp (scenario_b1_census.warp: full 300 frames, banner dismissed, 30 frames), write the actor position
$1014/$1016 = (cx*16+8, cy*16+16) and zero the speeds $09B2/$09B4, advance 30 frames, take a screenshot, save the state with a sidecar
(meta scene / flags / form), then run the H1 validity test twice (load, advance 120 frames, check cpu.k in $80-$CF, cpu.sp in $0100-$01FF,
scene $0644 unchanged, mask $09B2.. free). Writes raw/B1_states_<date>.json.

usage: b1_states.py
"""
import json
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from mcp_client import Mesen  # noqa: E402
from scenario_b1_census import ROM_O, STATE, warp, RESULTS  # noqa: E402
from scenario_b1_shots import make_reader  # noqa: E402

ROOT = os.path.abspath(os.path.join(RESULTS, "..", "..", ".."))
STATE_DIR = os.path.join(ROOT, "rebuilt", "states")

STATES = [
    dict(name="orig_S13_slope-field.mss", scene=0x15, cell=(71, 17), settle=30,
         note="S13 slope field: Itory Village $15, player on the landing at the top of the $05/$06 stair band, cell (71,17); banner dismissed, 30 frames"),
    dict(name="orig_S14_ramp-scene.mss", scene=0x85, cell=(58, 11), settle=300,
         note="S14 ramp scene: Great Wall wall_rampway $85, player 4 cells west of the first ramp_west actor (62,11); banner dismissed, then 300 frames so the horizontal camera has caught up with the teleported player"),
]


def main():
    lib = os.path.join(RESULTS, "kit", "lib")
    out = {"states": []}
    with Mesen(args=[f"--mcp-lib-dir={lib}", f"--mcp-results-dir={os.path.join(RESULTS, 'raw')}"]) as m:
        info = m.call("load_rom", path=ROM_O)["rom"]
        m.call("pause")
        assert info["fileSha1"] == "38de0c84dd2bc3bdfc0a3d7ab0220c79b70887c3"
        for st in STATES:
            m.call("load_state_file", path=STATE)
            w = warp(m, st["scene"])
            stride, rows, cell = make_reader(m)
            cx, cy = st["cell"]
            assert cell(cx, cy) == 0, f"target cell {st['cell']} is not free: {cell(cx, cy)}"
            m.poke(0x1014, cx * 16 + 8)
            m.poke(0x1016, cy * 16 + 16)
            m.poke(0x09B2, 0)
            m.poke(0x09B4, 0)
            m.call("advance_frame", frames=st["settle"])
            shot = m.shot(st["name"].replace(".mss", ""))
            path = os.path.join(STATE_DIR, st["name"])
            m.call("save_state_file", path=path, note=st["note"],
                   meta={"scene": st["scene"], "flags": [], "form": "Will", "playerCell": [cx, cy]})
            checks = []
            for i in range(2):
                m.call("load_state_file", path=path)
                a = m.call("advance_frame", frames=120, turbo=True)
                cpu = a["cpu"]
                ok = (0x80 <= cpu["k"] <= 0xCF) and (0x0100 <= cpu["sp"] <= 0x01FF) and m.u16(0x644) == st["scene"]
                checks.append({"run": i + 1, "k": cpu["k"], "pc": cpu["pc"], "sp": cpu["sp"], "scene": m.u16(0x644),
                               "actor": [m.u16(0x1014), m.u16(0x1016)], "ok": ok})
            out["states"].append({"state": st["name"], "scene": st["scene"], "cell": st["cell"], "warp": w,
                                  "shot": shot.get("path"), "checks": checks})
            print(st["name"], "->", [c["ok"] for c in checks], shot.get("path"))
    out["rom"] = info
    out["date"] = time.strftime("%Y%m%d")
    p = os.path.join(RESULTS, "raw", f"B1_states_{out['date']}.json")
    with open(p, "w", encoding="utf-8") as f:
        json.dump(out, f, indent=1)
    print("wrote", p)


if __name__ == "__main__":
    main()
