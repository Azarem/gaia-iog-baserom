#!/usr/bin/env python3
"""FR21 batch 13: FL22-10 ($FF = flag 255, byte $0A1F bit 7) in scene $1D: control and forced clear at n=100 and n=160; execs at 48543 (SetFlagByte #FF) and 48579 (BranchOnFlagByte #FF)."""
from fr21_lib import *  # noqa: F401,F403

m, info = open_o()
REC = "{ {name='fFF',addr=0x0A1F,bit=0x80},{name='hdma66',addr=0x0066},{name='ctr',addr=0x7F0008+0,size=1} }"
REC = "{ {name='fFF',addr=0x0A1F,bit=0x80},{name='hdma66',addr=0x0066} }"
try:
    for nm, at in (("ctl", "{}"), ("forced_clear", "{ [100]=function(R,n) gaia.flags.clear(255); R.clr=n end, [160]=function(R,n) gaia.flags.clear(255); R.clr2=n end }")):
        r = visit(m, info, f"FL22-10_{nm}", S01R, scene=0x1D, settle=240, watch=True, execs=[48543, 48579, 48546],
                  hooks="onSample=fr21.drive{ rec=" + REC + ", at=" + at + ", every=function(R,n) if n==5 or n==99 or n==101 or n==159 or n==161 or n==239 then R.s=R.s or {}; R.s[#R.s+1]={n=n,ex=R.execs['48543'][1]} end end }")
        print(brief(r, limit=12), "clr", r.get("clr"), r.get("clr2"), "execs48543 counts", r.get("s"))
finally:
    m.close()
