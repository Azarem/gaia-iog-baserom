#!/usr/bin/env python3
"""FR23 batch 3: FL27-02 (flag $94 = byte $0A12 bit 4, scenes $79 / $78) with the talk bot.
D0: scene $79 with $97 set, no input (actor positions and entries).
C1: control order Neil first ("You got Kruks?"), Lance, Neil again. C2 forced: $94 preset before the load of $79 and $78, exit menu."""
import json
import sys
from fr23_lib import *  # noqa: F401,F403

REC = ("{ {name='f94',addr=0x0A12,bit=0x10},{name='f97',addr=0x0A12,bit=0x80},{name='s01',addr=0x0A00,bit=0x02},{name='mask',addr=0x065A,size=2},"
       "{name='dlg',addr=0x09EC,bit=0x2000},{name='sc',addr=0x0644,size=2} }")
EXECS = [500186, 500191, 500195, 500236, 503053, 503057, 52216, 52234, 52250, 52266]


def trial(m, info, name, scene, set_=None, post=None, tp=None, settle=300, shot=None, snaps=(), execs=None, talk=(), rec=REC, **kw):
    ev = f"every=fr23.talker({L.lit(list(talk))})" if talk else ""
    hooks = f"onSample=fr22.drive{{ rec={rec}, snaps={L.lit(list(snaps))}, {ev} }}"
    return visit(m, info, name, S01R, scene=scene, set=set_ or [], post=post, teleport=tp, settle=settle, watch=False, hooks=hooks, shot=shot,
                 execs=execs, frames=settle + 1400, **kw)


def show(r):
    print(summarize(r).split("\n")[0])
    print("   actors0 files:", dict(count_files(r, "actors0")))
    print("   execs", json.dumps(r.get("execs")))
    rows = r.get("rec") or []
    print("   REC (%d rows)" % len(rows), json.dumps(rows[:30], separators=(",", ":")))
    print("   talk", json.dumps(r.get("talk")))
    for k, v in sorted((r.get("snap") or {}).items(), key=lambda kv: int(kv[0])):
        nm = L.actor_names(v)
        print(f"   snap n={k}: " + "; ".join(f"{a['file']}@{a['line']}({a['x']},{a['y']}) pc{b['pc']:04X}" for a, b in zip(nm, v) if a["file"] not in SKIP and a["file"].startswith(("wa79", "wa78_prize"))))


which = [w for w in sys.argv[1:] if not w.startswith("-")] or ["D0"]
m, info = open_o()
try:
    if "D0" in which:
        show(trial(m, info, "FL27-02_D0_s79_97", 0x79, set_=[151], settle=120, execs=EXECS, shot="FL27-02_D0"))
    if "C1" in which:   # control: Neil, then Lance, then Neil
        talk = [dict(n=30, x=152, y=176, len=60), dict(n=380, x=120, y=144, len=60), dict(n=730, x=152, y=176, len=60)]
        show(trial(m, info, "FL27-02_C1_s79_order", 0x79, set_=[151], settle=1200, execs=EXECS, talk=talk, snaps=(20, 320, 700, 1100), shot="FL27-02_C1"))
    if "L0" in which:   # find a working talk position for Lance (scan, one run)
        cands = [(120, 144, "up"), (120, 148, "up"), (120, 152, "up"), (136, 144, "left"), (104, 144, "right"), (104, 136, "right"), (120, 160, "up")]
        talk = [dict(n=30 + 100 * i, x=c[0], y=c[1], dir=c[2], len=40) for i, c in enumerate(cands)]
        r = trial(m, info, "FL27-02_L0_scan_lance", 0x79, set_=[151], settle=30 + 100 * len(cands) + 50, execs=EXECS, talk=talk, snaps=(), shot="FL27-02_L0")
        show(r)
    if "C2" in which:   # control: Lance first, then Neil
        talk = [dict(n=30, x=120, y=144, len=60), dict(n=380, x=152, y=176, len=60)]
        show(trial(m, info, "FL27-02_C2_s79_lance_first", 0x79, set_=[151], settle=1000, execs=EXECS, talk=talk, snaps=(20, 360, 900), shot="FL27-02_C2"))
    if "F1" in which:   # forced: $94 preset, scene $79
        show(trial(m, info, "FL27-02_F1_s79_94", 0x79, set_=[151, 148], settle=300, execs=EXECS, snaps=(20,), shot="FL27-02_F1"))
    if "F2" in which:   # scene $78 with $97 set: $94 clear (control) and set (forced): prize kruks
        show(trial(m, info, "FL27-02_F2a_s78_97_ctl", 0x78, set_=[151, 141], settle=200, execs=EXECS, snaps=(20,), shot="FL27-02_F2a"))
        show(trial(m, info, "FL27-02_F2b_s78_97_94", 0x78, set_=[151, 141, 148], settle=200, execs=EXECS, snaps=(20,), shot="FL27-02_F2b"))
    if "E" in which:    # exit menu of scene $78: tiles (27,3D)-(29,40); $8D set so the intro does not run
        X = (0x28 * 16 + 8, 0x3E * 16 + 16)
        show(trial(m, info, "FL27-02_E0_s78_exit_ctl", 0x78, set_=[141], tp=X, settle=200, execs=EXECS, shot="FL27-02_E0"))
        show(trial(m, info, "FL27-02_E1_s78_exit_94", 0x78, set_=[141, 148], tp=X, settle=200, execs=EXECS, shot="FL27-02_E1"))
finally:
    m.close()
