#!/usr/bin/env python3
"""FR22 batch 2: FL25-01 (flag $7B, scene $63 prayer room): control (no item), statue at the west pedestal, statue at the east pedestal,
flag preset, east spawn. One atomic run per trial from S01r; spawn override through warpDestX/Y ($064C/$064E, written as bytes before sceneNext)."""
import json
import sys
from fr22_lib import *  # noqa: F401,F403

REC = ("{ {name='f7B',addr=0x0A0F,bit=0x08},{name='f7E',addr=0x0A0F,bit=0x40},{name='f02',addr=0x0A00,bit=0x04},"
       "{name='mask',addr=0x065A,size=2},{name='bgm',addr=0x06F2,size=2},{name='dlg',addr=0x09EC,bit=0x2000},{name='sc',addr=0x0644,size=2},{name='inv0',addr=0x0AB4} }")


def spawn(tx, ty):
    """warpDestX/Y bytes for a spawn on player tile (tx, ty): the override stores x,y + (8, 16) as the actor position."""
    x, y = tx * 16, ty * 16
    return [[0x64C, x & 255], [0x64D, x >> 8], [0x64E, y & 255], [0x64F, y >> 8]]


def trial(m, info, name, scene=0x63, pre=None, set_=None, use=None, snaps=(), settle=700, shot=None, shots=()):
    uses = ",".join("{n=%d,x=%d,y=%d,item=%d}" % (u[0], u[1], u[2], u[3]) for u in (use or []))
    hooks = f"onSample=fr22.drive{{ rec={REC}, use={{{uses}}}, snaps={L.lit(list(snaps))} }}"
    r = visit(m, info, name, S01R, scene=scene, pre=pre or [], set=set_ or [], settle=settle, watch=False, hooks=hooks, shot=shot,
              execs=[432624, 432863, 432789, 433028, 432814, 433053], extra="", frames=settle + 1400)
    return r


def show(r):
    print(summarize(r))
    print("   useRows", json.dumps(r.get("useRows")), " execs(StartMusic W 432624, E 432863; SetFlag#02 W 432789, E 433028; placed W 432814, E 433053)", json.dumps(r.get("execs")))
    rows = r.get("rec") or []
    print("   REC", json.dumps(rows[:30], separators=(",", ":")))
    for k, v in sorted((r.get("snap") or {}).items(), key=lambda kv: int(kv[0])):
        nm = L.actor_names(v)
        print(f"   snap n={k}: " + "; ".join(f"{a['file']}@{a['line']}({a['x']},{a['y']}) pc{b['pc']:04X}" for a, b in zip(nm, v)
                                            if a["file"] not in ("camera_scroll", "camera_scroll_controller", "player_character", "player_move_controller", "slope_ramp_physics")))


which = sys.argv[1:] or ["T0", "T1", "T2", "T3", "T4", "T5"]
if "T1L" in which:
    pass
m, info = open_o()
try:
    # item ids are hex: Statue of Hope = $12. West pedestal tiles (06,06)-(0A,08); east pedestal (16,06)-(1A,08). Actor position = player p09A2 + (8,16).
    W = (8 * 16 + 12, 7 * 16 + 20)      # actor position inside the west box: tile (8,7)
    E = (0x18 * 16 + 12, 7 * 16 + 20)   # tile (24,7) east box
    if "T0" in which:
        show(trial(m, info, "FL25-01_T0_noitem", snaps=(30, 300, 690), shot="FL25-01_T0"))
    if "T1" in which:
        show(trial(m, info, "FL25-01_T1_west_use_west", use=[(40, W[0], W[1], 0x12)], snaps=(30, 100, 400, 690), shot="FL25-01_T1"))
    if "T1L" in which:
        show(trial(m, info, "FL25-01_T1L_west_use_west_long", use=[(40, W[0], W[1], 0x12)], snaps=(700, 1100, 1400, 1790), settle=1800, shot="FL25-01_T1L"))
    if "T2" in which:
        show(trial(m, info, "FL25-01_T2_west_use_east", use=[(40, E[0], E[1], 0x12)], snaps=(30, 100, 400, 690), shot="FL25-01_T2"))
    if "T3" in which:
        show(trial(m, info, "FL25-01_T3_flag7B_preset", set_=[123], snaps=(30, 100, 400, 690), shot="FL25-01_T3"))
    if "T4" in which:
        show(trial(m, info, "FL25-01_T4_east_spawn_use_east", pre=spawn(0x18, 7), use=[(40, E[0], E[1], 0x12)], snaps=(30, 100, 400, 690), shot="FL25-01_T4"))
    if "T5" in which:
        show(trial(m, info, "FL25-01_T5_east_spawn_use_west", pre=spawn(0x18, 7), use=[(40, W[0], W[1], 0x12)], snaps=(30, 100, 400, 690), shot="FL25-01_T5"))
finally:
    m.close()
