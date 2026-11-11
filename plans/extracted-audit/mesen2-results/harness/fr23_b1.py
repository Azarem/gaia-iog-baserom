#!/usr/bin/env python3
"""FR23 batch 1: FL26-01 / FL27-01 (flag $8D, byte $0A11 bit 5): scenes $69, $6A (party actors, exit menu), $78 (intro, pad, camera).
Every trial loads S01r and quick-warps (flags written before the warp). One atomic run per trial."""
import json
import sys
from fr23_lib import *  # noqa: F401,F403

REC = ("{ {name='f8D',addr=0x0A11,bit=0x20},{name='f75',addr=0x0A0E,bit=0x20},{name='mask',addr=0x065A,size=2},"
       "{name='dlg',addr=0x09EC,bit=0x2000},{name='sc',addr=0x0644,size=2},{name='camY',addr=0x06C2,size=2} }")

EXIT_OFFS = [52160, 52169, 52181, 52197, 52207, 52216, 52234, 52250, 52266]


def trial(m, info, name, scene, set_=None, post=None, tp=None, settle=300, shot=None, snaps=(), execs=None, hooks_extra="", rec=REC, **kw):
    hooks = f"onSample=fr22.drive{{ rec={rec}, snaps={L.lit(list(snaps))}, adv=false }}"
    return visit(m, info, name, S01R, scene=scene, set=set_ or [], post=post, teleport=tp, settle=settle, watch=False, hooks=hooks, shot=shot,
                 execs=execs, frames=settle + 1400, **kw)


def show(r):
    print(summarize(r))
    ac = r.get("actors0_named") or []
    print("   actors0 files:", dict(count_files(r, "actors0")))
    print("   actors1 files:", dict(count_files(r, "actors1")))
    print("   execs", json.dumps(r.get("execs")))
    print("   REC", json.dumps((r.get("rec") or [])[:24], separators=(",", ":")))
    for k, v in sorted((r.get("snap") or {}).items(), key=lambda kv: int(kv[0])):
        nm = L.actor_names(v)
        print(f"   snap n={k}: " + "; ".join(f"{a['file']}@{a['line']}({a['x']},{a['y']}) pc{b['pc']:04X}" for a, b in zip(nm, v) if a["file"] not in SKIP))


which = [w for w in sys.argv[1:] if not w.startswith("-")] or ["A0", "A1", "A2", "A3", "B0", "B1"]
m, info = open_o()
try:
    # exit box of scene $69: tiles (29,0D)-(2C,0F): actor position of tile (0x2A, 0x0E) = tile*16 + (8, 16)
    EXP = (0x2A * 16 + 8, 0x0E * 16 + 16)
    if "A0" in which:   # scene $69, $8D and $75 clear: control
        show(trial(m, info, "FL26-01_A0_s69_ctl", 0x69, settle=400, execs=EXIT_OFFS, shot="FL26-01_A0", snaps=(30, 300)))
    if "A1" in which:   # scene $69, $8D set: forced
        show(trial(m, info, "FL26-01_A1_s69_8D", 0x69, set_=[141], settle=400, execs=EXIT_OFFS, shot="FL26-01_A1", snaps=(30, 300)))
    if "A2" in which:   # exit menu control: $75 set, $8D clear, player teleported into the exit box
        show(trial(m, info, "FL26-01_A2_s69_exit_ctl", 0x69, set_=[117], post=None, tp=EXP, settle=200, execs=EXIT_OFFS, shot="FL26-01_A2"))
    if "A3" in which:   # exit menu forced: $8D set
        show(trial(m, info, "FL26-01_A3_s69_exit_8D", 0x69, set_=[141], tp=EXP, settle=200, execs=EXIT_OFFS, shot="FL26-01_A3"))
    if "B0" in which:   # scene $6A control
        show(trial(m, info, "FL26-01_B0_s6A_ctl", 0x6A, settle=300, shot="FL26-01_B0", snaps=(30,)))
    if "M2" in which:   # menu screenshot control ($15 expected)
        show(trial(m, info, "FL26-01_M2_menu_ctl", 0x69, set_=[117], tp=EXP, settle=int(__import__("os").environ.get("MS","190")), execs=EXIT_OFFS, shot="FL26-01_M2"))
    if "M3" in which:   # menu screenshot forced ($0A expected)
        show(trial(m, info, "FL26-01_M3_menu_8D", 0x69, set_=[141], tp=EXP, settle=int(__import__("os").environ.get("MS","190")), execs=EXIT_OFFS, shot="FL26-01_M3"))
    if "B1" in which:   # scene $6A, $8D set
        show(trial(m, info, "FL26-01_B1_s6A_8D", 0x6A, set_=[141], settle=300, shot="FL26-01_B1", snaps=(30,)))
finally:
    m.close()
