#!/usr/bin/env python3
"""FR23 batch 10: scratch $00 (byte $0A00 bit 0) and the player's idle sprite (FL26-02, FL26-03, FL27-09, FL27-10).
Idle South/North/West/East normal StagePlayerSprite #00-#03 at 181381/181397/181413/181429, Shadow #10-#13 at 181386/181402/181418/181434 (player_character.asm IdleStand*)."""
import json
import sys
from fr23_lib import *  # noqa: F401,F403

IDLE = [181381, 181386, 181397, 181402, 181413, 181418, 181429, 181434]
REC = "{ {name='s00',addr=0x0A00,bit=0x01},{name='aa6',addr=0x0AA6,size=2},{name='mask',addr=0x065A,size=2},{name='sc',addr=0x0644,size=2},{name='px',addr=0x09A2,size=2},{name='py',addr=0x09A4,size=2} }"
which = sys.argv[1:] or ["Z78"]
m, info = open_o()


def trial(name, scene, pre=None, set_=None, tps=(), taps=(), clear0=False, settle=400, shot=None, sample=None, snaps=()):
    ev = "every=function(R,n) "
    for (n, x, y) in tps:
        ev += f"if n=={n} then fr21.pos({x},{y}) end "
    for t in taps:
        t, ln = (t if isinstance(t, tuple) else (t, 8))
        ev += f"if n>={t} and n<{t + ln} then fr21.press(R,{{'right'}}) end "
    if clear0:
        ev += "kit.w8(0x0A00, kit.r8(0x0A00) & 0xFE) "
    for n in (sample or ()):
        ev += f"if n=={n} then R.smp=R.smp or {{}}; R.smp[#R.smp+1]={{n,kit.r8(0x0A00)&1,kit.r16(0x09A2),kit.r16(0x09A4)}} end "
    ev += "end"
    hooks = f"onSample=fr22.drive{{ rec={REC}, snaps={L.lit(list(snaps))}, adv=false, {ev} }}"
    r = visit(m, info, name, S01R, scene=scene, pre=pre or [], set=set_ or [], settle=settle, watch=False, hooks=hooks, execs=IDLE, shot=shot, frames=settle + 800)
    print(name, summarize(r).split(chr(10))[0][:140])
    print("   idle execs (S,Ssh,N,Nsh,W,Wsh,E,Esh):", [(r.get("execs") or {}).get(str(o), [0])[0] for o in IDLE])
    print("   rec", json.dumps(r.get("rec"), separators=(",", ":"))[:700])
    if r.get("smp"):
        print("   smp", json.dumps(r["smp"]))
    return r


try:
    if "Z78" in which:   # FL27-09 scene $78
        trial("FL27-09_ctl", 0x78, set_=[141, 145], taps=(60,), shot="FL27-09_ctl", settle=300)
        trial("FL27-09_clear", 0x78, set_=[141, 145], clear0=True, taps=(60,), shot="FL27-09_clear", settle=300)
    if "Z75" in which:   # FL26-02 scene $75: fourth room spawn (0798,00B0) and third room (0598,00B0), $0AA6 = 7
        trial("FL26-02_s75_room4", 0x75, pre=spawn_px(0x798, 0xB0) + [[0xAA6, 7], [0xAA7, 0]], taps=(60,), shot="FL26-02_room4")
        trial("FL26-02_s75_room3", 0x75, pre=spawn_px(0x598, 0xB0) + [[0xAA6, 7], [0xAA7, 0]], taps=(60,), shot="FL26-02_room3")
        trial("FL26-02_s75_default", 0x75, taps=(60,), shot="FL26-02_default")
    if "Z73" in which:   # FL26-03 scene $73: top-left start box and the box (2A,17)-(2F,1D)
        trial("FL26-03_s73_startbox", 0x73, pre=spawn_px(0x100, 0x80), taps=(60,), shot="FL26-03_startbox")
        trial("FL26-03_s73_default_walk", 0x73, pre=spawn_px(0x80, 0x1C0), tps=[(100, 0x2C * 16 + 8, 0x1A * 16 + 16), (250, 0x20 * 16 + 8, 0x1A * 16 + 16)], taps=(130, 280), sample=(90, 180, 240, 330), shot="FL26-03_walk", settle=400)
    if "Z9D" in which:   # FL27-10 scene $9D: box (0F,07)-(10,09)
        trial("FL27-10_s9D_walk", 0x9D, tps=[(100, 0x0F * 16 + 6, 0x08 * 16 + 16), (250, 0x14 * 16 + 8, 0x0C * 16 + 16)], taps=((130, 3), (280, 3)), sample=(90, 180, 240, 330), shot="FL27-10_walk", settle=400)
    if "Z6B" in which:   # FL26-05 scene $6B: $0AA6 = 5 preset; door opens when the player is near and writes $0AA6 = 0
        REC6 = "{ {name='aa6',addr=0x0AA6,size=2},{name='mask',addr=0x065A,size=2},{name='sc',addr=0x0644,size=2} }"
        steps = ",".join("{wait=function() return R.n>=60 and not R.opened end, find={0xD748,0xD76E}, dy=%d, nodlg=true, max=30}" % d for d in (16, 16, 8, 8, 24, 24, 12))
        for nm, near in (("interact", False), ("spawn_near", True)):
            ev = "every=function(R,n) R.n=n if kit.r16(0x0AA6)==0 and n>5 then R.opened=true end if not R.sq then R.sq=fr23.seq({" + steps + "}) end if %s then R.sq(R,n) end end" % ("true" if not near else "false")
            hooks = f"onSample=fr22.drive{{ rec={REC6}, snaps={{30}}, adv=false, {ev} }}"
            pre = [[0xAA6, 5], [0xAA7, 0]] + (spawn_px(944, 640) if near else [])
            r = visit(m, info, f"FL26-05_s6B_{nm}", S01R, scene=0x6B, pre=pre, set=[117], settle=500, watch=False, hooks=hooks, execs=[448378, 448363, 448384], shot=f"FL26-05_{nm}", frames=1200)
            print(nm, summarize(r).split(chr(10))[0][:140])
            print("   seq", [(q.get("step"), q.get("how"), q.get("n")) for q in r.get("seq") or []][:10], "execs", json.dumps(r.get("execs")))
            print("   rec", json.dumps(r.get("rec"), separators=(",", ":"))[:500])
finally:
    m.close()
