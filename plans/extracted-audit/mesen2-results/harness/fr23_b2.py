#!/usr/bin/env python3
"""FR23 batch 2: FL27-01 (flag $8D, scene $78): control (flag clear) and forced (byte $0A11 |= $20 before the load).
Observables: joypadMaskStd, wa78_moving_pad position (snapshots), cameraTargetY, exec counts of the intro test (491523), the setter (491619),
the camera waiter (491980), the pad waiter (499621) and the scene change (QueueMapChange 491643)."""
import json
import sys
from fr23_lib import *  # noqa: F401,F403

REC = ("{ {name='f8D',addr=0x0A11,bit=0x20},{name='mask',addr=0x065A,size=2},"
       "{name='dlg',addr=0x09EC,bit=0x2000},{name='sc',addr=0x0644,size=2},{name='camY',addr=0x06C2,size=2} }")
EXECS = [491523, 491619, 491643, 491980, 499621, 499625, 499638]


def trial(m, info, name, scene, set_=None, post=None, tp=None, settle=300, shot=None, snaps=(), execs=None, rec=REC, **kw):
    hooks = f"onSample=fr22.drive{{ rec={rec}, snaps={L.lit(list(snaps))}, adv=false }}"
    return visit(m, info, name, S01R, scene=scene, set=set_ or [], post=post, teleport=tp, settle=settle, watch=False, hooks=hooks, shot=shot,
                 execs=execs, frames=settle + 1400, **kw)


def show(r, pads=True):
    print(summarize(r))
    print("   actors0 files:", dict(count_files(r, "actors0")))
    print("   execs", json.dumps(r.get("execs")))
    rows = r.get("rec") or []
    print("   REC (%d rows)" % len(rows), json.dumps(rows[:14], separators=(",", ":")))
    for k, v in sorted((r.get("snap") or {}).items(), key=lambda kv: int(kv[0])):
        nm = L.actor_names(v)
        print(f"   snap n={k}: " + "; ".join(f"{a['file']}@{a['line']}({a['x']},{a['y']}) pc{b['pc']:04X}" for a, b in zip(nm, v)
                                            if a["file"] in ("wa78_moving_pad", "wa78_lance_camera_pan", "wa78_intro")))


which = [w for w in sys.argv[1:] if not w.startswith("-")] or ["C0", "F0"]
m, info = open_o()
try:
    SN = (30, 150, 300, 450, 600, 800)
    if "C0" in which:
        show(trial(m, info, "FL27-01_C0_s78_ctl", 0x78, settle=900, execs=EXECS, snaps=SN, shot="FL27-01_C0"))
    if "F0" in which:
        show(trial(m, info, "FL27-01_F0_s78_8D", 0x78, set_=[141], settle=900, execs=EXECS, snaps=SN, shot="FL27-01_F0"))
finally:
    m.close()
