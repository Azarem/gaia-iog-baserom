#!/usr/bin/env python3
"""FR23 batch 11: FL31-04 / FL24-14 setter of flag $96 (gw8B_lance at {505825}): play the Great Wall reunion from scene $8B with the Lilly's Necklace ($17) in the inventory."""
import json
import sys
from fr23_lib import *  # noqa: F401,F403

REC = ("{ {name='f96',addr=0x0A12,bit=0x40},{name='fC8',addr=0x0A19,bit=0x01},{name='s02',addr=0x0A00,bit=0x04},{name='s03',addr=0x0A00,bit=0x08},{name='s04',addr=0x0A00,bit=0x10},{name='s05',addr=0x0A00,bit=0x20},"
       "{name='inv0',addr=0x0AB4},{name='mask',addr=0x065A,size=2},{name='sc',addr=0x0644,size=2},{name='px',addr=0x09A2,size=2},{name='py',addr=0x09A4,size=2} }")
m, info = open_o()
try:
    talk = "{wait=function() return R.n>=60 end, find={0xB776,0xB7A2}, dy=16, nodlg=true, max=30, done=function() return (kit.r8(0x0A00)&0x04)~=0 end}"
    steps = ["{x=%d,y=%d,max=6,nodlg=true,wait=function() return R.n>=20 end}" % (8 * 16 + 8, 0x19 * 16 + 16)]
    steps += [talk] * 5
    steps.append("{x=%d,y=%d,max=6,nodlg=true,wait=function() return (kit.r8(0x0A00)&0x04)~=0 and R.n>=R.t02+60 end}" % (0x13 * 16 + 8, 0x19 * 16 + 16))
    ev = ("every=function(R,n) R.n=n if (kit.r8(0x0A00)&0x04)~=0 and not R.t02 then R.t02=n end if not R.sq then R.sq=fr23.seq({" + ",".join(steps) + "}) end "
          "if kit.r8(0xB4)~=0 and n%6<2 then fr21.press(R,{'a'}) end if fr22.dlg() and n%12<2 then fr21.press(R,{'b'}) end "
          "if kit.r16(0x0644)~=0x8B and kit.r16(0x0644)~=0 then R.endSc=R.endSc or n end if R.endSc and n>R.endSc+20 then R.stop=true end R.sq(R,n) end")
    hooks = f"onSample=fr22.drive{{ rec={REC}, snaps={{30,400}}, adv=false, {ev} }}"
    r = visit(m, info, "FL31-04_gw8B", S01R, scene=0x8B, pre=[[0x0AB4, 0x17]], set=[], settle=7000, watch=False, hooks=hooks, execs=[505825, 505828, 505837, 505852, 505858, 505737], shot="FL31-04_gw8B", frames=8200)
    print(summarize(r).split(chr(10))[0][:200])
    print("   seq", [(q.get("step"), q.get("how"), q.get("n")) for q in r.get("seq") or []])
    print("   execs", json.dumps(r.get("execs")))
    print("   rec", json.dumps(r.get("rec"), separators=(",", ":"))[:1500])
    for k, v in sorted((r.get("snap") or {}).items(), key=lambda kv: int(kv[0])):
        print("   snap", k, [f"{a['file']}({a['x']},{a['y']})" for a in L.actor_names(v) if a["file"].startswith(("gw8B", "e_gw8B"))])
finally:
    m.close()
