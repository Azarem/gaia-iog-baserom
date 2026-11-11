#!/usr/bin/env python3
"""FR23 batch 6: FL27-07 (flag $A8, Teapot $19 in scene $95 Rolek mansion; $A5 $A4 preset). Item in slot 0 before the load, use at n=40 inside tiles (28,09)-(2D,0D) or outside,
then talk to Neil (entry pc $E37D-$E3B5)."""
import json
import sys
from fr23_lib import *  # noqa: F401,F403

REC = ("{ {name='fA8',addr=0x0A15,bit=0x01},{name='fAA',addr=0x0A15,bit=0x04},{name='inv0',addr=0x0AB4},{name='mask',addr=0x065A,size=2},{name='bgm',addr=0x06F2,size=2},"
       "{name='dlg',addr=0x09EC,bit=0x2000},{name='sc',addr=0x0644,size=2} }")
EXECS = [517010, 235581, 235601, 235606, 235610, 235613, 516562, 516569, 516575, 516622, 516631, 517010, 517016, 517021, 517025, 517034, 516886, 516636, 516884, 516634]
# 235601 "But nothing happened" (outside), 235606 code_039856 (inside), 235610 RemoveItem, 235613 SetFlag $A8; father: 516562 wait $A8, 516569 TSB mask, 516575 StartMusic #1B, 516622 StartMusic #04, 516631 TRB mask;
# Neil: 517010 handler test $A8, 517016 first text, 517021 emotional text, 517025 SetFlag $AA, 517034 QueueMapChange #96; 516636 father text, 516886 mother text, 516634/516884 father/mother Die


def trial(m, info, name, use=None, inv=True, talk_after=None, snaps=(30, 700), settle=900, shot=None, set_=(164, 165)):
    pre = [[0x0AB4, 0x19]] if inv else []
    uses = "{ {n=40,x=%d,y=%d,item=25} }" % use if use else "{}"
    t0 = talk_after or 120
    step = ("{wait=function() return R.n>=" + str(t0) + " and kit.r16(0x065A)==0 and not R.talkedOnce end, find={0xE37D,0xE3B5}, dy=4, max=70, "
            "done=function() return R.talkedOnce end}")
    ev = ("every=function(R,n) R.n=n if fr22.dlg() and n>=" + str(t0) + " then R.talkedOnce=true end if not R.sq then R.sq=fr23.seq({" + ",".join([step] * 5) + "}) end R.sq(R,n) end")
    hooks = f"onSample=fr22.drive{{ rec={REC}, use={uses}, snaps={L.lit(list(snaps))}, {ev} }}"
    return visit(m, info, name, S01R, scene=0x95, pre=pre, set=list(set_), settle=settle, watch=False, hooks=hooks, execs=EXECS, shot=shot, frames=settle + 1200)


def show(r):
    print(summarize(r).split(chr(10))[0][:200])
    print("   useRows", json.dumps(r.get("useRows")))
    print("   seq", json.dumps(r.get("seq")))
    print("   execs", json.dumps({k: v for k, v in (r.get("execs") or {}).items() if v[0]}))
    print("   REC", json.dumps(r.get("rec"), separators=(",", ":"))[:1500])
    for k, v in sorted((r.get("snap") or {}).items(), key=lambda kv: int(kv[0])):
        nm = L.actor_names(v)
        print(f"   snap n={k}: " + "; ".join(f"{a['file']}@{a['line']}({a['x']},{a['y']}) pc{b['pc']:04X}" for a, b in zip(nm, v) if a["file"].startswith("eu95")))


IN = (0x2A * 16 + 12, 0x0B * 16 + 20)
OUT = (0x20 * 16 + 12, 0x0B * 16 + 20)
which = sys.argv[1:] or ["C"]
m, info = open_o()
try:
    if "C" in which:   # control: no Teapot, talk to Neil
        show(trial(m, info, "FL27-07_C_noitem_talk_neil", inv=False, shot="FL27-07_C"))
    if "I" in which:   # use inside the box, then talk to Neil after the father's sequence
        show(trial(m, info, "FL27-07_I_use_inside", use=IN, talk_after=500, snaps=(30, 300, 700), settle=1100, shot="FL27-07_I"))
    if "O" in which:   # use outside the box, then talk to Neil
        show(trial(m, info, "FL27-07_O_use_outside", use=OUT, talk_after=300, snaps=(30, 700), shot="FL27-07_O"))
finally:
    m.close()
