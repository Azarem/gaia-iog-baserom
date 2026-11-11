#!/usr/bin/env python3
"""FR21 batch 19: FL23-08 ($FF = flag 255, byte $0A1F bit 7) in the dream scene $2A: dream_palette_loop (46804 PaletteStart #35, 46809 SetFlagByte #FF, 46812 WaitOnFlagByte #FF,#00, 46818 KillThinker). Forced: clear $FF with gaia.flags.clear (stands for the engine clear; the inventory was not opened)."""
from fr21_lib import *  # noqa: F401,F403

m, info = open_o()
REC = "{ {name='fFF',addr=0x0A1F,bit=0x80},{name='mask',addr=0x065A,size=2} }"
try:
    for nm, at in (("ctl", "{}"), ("forced_clear", "{ [250]=function(R,n) gaia.flags.clear(255); R.clr=n end, [450]=function(R,n) gaia.flags.clear(255); R.clr2=n end }")):
        r = visit(m, info, f"FL23-08_{nm}", S01R, scene=0x2A, settle=700, watch=False, cgram=True, execs=[46804, 46809, 46812, 46818],
                  hooks="onSample=fr21.drive{ rec=" + REC + ", at=" + at + ", every=function(R,n) if n==5 or n==249 or n==251 or n==449 or n==451 or n==699 then R.s=R.s or {}; R.s[#R.s+1]={n=n,start=R.execs['46804'] and R.execs['46804'][1] or 0,set=R.execs['46809'] and R.execs['46809'][1] or 0} end end }")
        print(brief(r, limit=14), "clr", r.get("clr"), r.get("clr2"), "counts", r.get("s"))
finally:
    m.close()
