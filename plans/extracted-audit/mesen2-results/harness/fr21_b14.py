#!/usr/bin/env python3
"""FR21 batch 14: FL22-12 (flag word $0112 = flag 274, byte $0A22 bit 2) in scene $24: the 600-frame counter (orbitAngle $7F0010,X of ir24_glowing_tile) on tiles (14,17)-(17,1A)."""
from fr21_lib import *  # noqa: F401,F403

m, info = open_o()
REC = "{ {name='f112',addr=0x0A22,bit=0x04},{name='mask',addr=0x065A,size=2} }"
EVERY = ("function(R,n) local d=fr21.find(0xC671,0xC6A7); if d then local o=emu.read16(0x10010+d.slot, emu.memType.snesWorkRam, false); "
         "if n==2 or n==4 or n==100 or n==299 or n==302 or n==304 or n==306 or n==400 or n==500 then R.orb=R.orb or {}; R.orb[#R.orb+1]={n=n,orb=o,slot=d.slot} end "
         "elseif n==2 then R.orb={'no actor'} end end")
try:
    for nm, at in (("stay", "{ [3]=function(R,n) fr21.pos(344,408) end }"),
                   ("stepoff", "{ [3]=function(R,n) fr21.pos(344,408) end, [300]=function(R,n) fr21.pos(100,300) end, [303]=function(R,n) fr21.pos(344,408) end }"),
                   ("never_on", "{ [3]=function(R,n) fr21.pos(100,300) end }")):
        r = visit(m, info, f"FL22-12_{nm}", S01R, scene=0x24, settle=1000, watch=True, execs=[640666],
                  hooks="onSample=fr21.drive{ rec=" + REC + ", at=" + at + ", every=" + EVERY + " }", shot=f"FL22-12_{nm}")
        print(brief(r, limit=6), "orb", r.get("orb"))
finally:
    m.close()
