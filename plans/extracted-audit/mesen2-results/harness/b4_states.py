#!/usr/bin/env python3
"""Create the B4 states on the original ROM (O): S14b (Incan Ruins ir21 N/S ramps $21), S14c (ir22 booster $22), S14d (Diamond Mine dm41
boosters $41), S14e (Mu glide room $62).

Per state: load S01r, quick warp (scenario_b1_census.warp: full 300 frames, banner dismissed, 30 frames), the player stays at the scene's
spawn, advance 30 more frames, save the state with a sidecar, then run the H1 validity test twice (load, advance 120 frames, check
cpu.k in $80-$CF, cpu.sp in $0100-$01FF, scene $0644 unchanged). Writes raw/B4_states_<date>.json.

usage: b4_states.py
"""
import json
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from mcp_client import Mesen  # noqa: E402
from scenario_b1_census import ROM_O, STATE, warp, RESULTS  # noqa: E402

ROOT = os.path.abspath(os.path.join(RESULTS, "..", "..", ".."))
STATE_DIR = os.path.join(ROOT, "rebuilt", "states")

STATES = [
    dict(name="orig_S14b_ir21-ns-ramps.mss", scene=0x21, note="S14b: Incan Ruins ir21 ($21), ramp_south (37,21) type $0B and ramp_north (37,26) type 3; spawn position; banner dismissed, 30 frames"),
    dict(name="orig_S14c_ir22-booster.mss", scene=0x22, note="S14c: Incan Ruins ir22 ($22), large_ramp_booster at tile (16,11); spawn position; banner dismissed, 30 frames"),
    dict(name="orig_S14d_dm41-boosters.mss", scene=0x41, note="S14d: Diamond Mine minecart room ($41), two large_ramp_booster at (22,28) and (27,11); spawn position; banner dismissed, 30 frames"),
    dict(name="orig_S14f_mtA1-ns-ramps.mss", scene=0xA1, note="S14f: Mountain temple mtA1 ($A1), ramp_north type 9 (54,39) and (22,30), ramp_south type $11 (26,35), ramp_west type 3 (16,12); spawn position; banner dismissed, 30 frames"),
    dict(name="orig_S14g_scB5-glide.mss", scene=0xB5, note="S14g: scene $B5 (single layer) with SliderGlideTriggerSouth (6,14) (8,14) (7,30) and North (6,21) (8,21) (7,39); spawn position; banner dismissed, 30 frames"),
    dict(name="orig_S14e_mu62-glide.mss", scene=0x62, note="S14e: Mu ($62) with SliderGlideTriggerEast (32,28), West (40,28) and North (51,5); spawn position; banner dismissed, 30 frames"),
]


def main():
    lib = os.path.join(RESULTS, "kit", "lib")
    out = {"states": []}
    with Mesen(args=[f"--mcp-lib-dir={lib}", f"--mcp-results-dir={os.path.join(RESULTS, 'raw')}"]) as m:
        info = m.call("load_rom", path=ROM_O)["rom"]
        m.call("pause")
        assert info["fileSha1"] == "38de0c84dd2bc3bdfc0a3d7ab0220c79b70887c3"
        for st in [x for x in STATES if len(sys.argv) < 2 or sys.argv[1] in x["name"]]:
            m.call("load_state_file", path=STATE)
            w = warp(m, st["scene"])
            m.call("advance_frame", frames=30)
            path = os.path.join(STATE_DIR, st["name"])
            m.call("save_state_file", path=path, note=st["note"], meta={"scene": st["scene"], "flags": [], "form": "Will"})
            checks = []
            for i in range(2):
                m.call("load_state_file", path=path)
                a = m.call("advance_frame", frames=120, turbo=True)
                cpu = a["cpu"]
                ok = (0x80 <= cpu["k"] <= 0xCF) and (0x0100 <= cpu["sp"] <= 0x01FF) and m.u16(0x644) == st["scene"]
                checks.append({"run": i + 1, "k": cpu["k"], "pc": cpu["pc"], "sp": cpu["sp"], "scene": m.u16(0x644),
                               "actor": [m.u16(0x1014), m.u16(0x1016)], "ok": ok})
            out["states"].append({"state": st["name"], "scene": st["scene"], "warp": w, "checks": checks})
            print(st["name"], "warp", w, "->", [c["ok"] for c in checks], [c["actor"] for c in checks])
    out["rom"] = info
    out["date"] = time.strftime("%Y%m%d")
    p = os.path.join(RESULTS, "raw", f"B4_states_{out['date']}.json")
    with open(p, "w", encoding="utf-8") as f:
        json.dump(out, f, indent=1)
    print("wrote", p)


if __name__ == "__main__":
    main()
