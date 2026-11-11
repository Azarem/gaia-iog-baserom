#!/usr/bin/env python3
"""FR21 batch 16: FL23-02 ($4D = flag 77, byte $0A09 bit 5) and FL23-03 ($52 = flag 82, byte $0A0A bit 2): the wreck palette thinker (gold_ship_wreck_palette, 46705-46802) in scenes $2B, $2D, $2F.
Observables: execs of the phase labels, palette staging buffer ($7F0A00 = WRAM 0x10A00) sums of palette 2 (bytes $40-$5F), palette 7 (bytes $E0-$FF) and colour $59 (byte $B2), CGRAM checksums."""
from fr21_lib import *  # noqa: F401,F403

m, info = open_o()
EX = [46707, 46713, 46719, 46726, 46734, 46751, 46759, 46788]
EVERY = ("function(R,n) if n==30 or n==150 or n==290 then R.buf=R.buf or {}; local function sum(a,len) local s=0; for i=0,len-2,2 do s=s+emu.read16(0x10A00+a+i,emu.memType.snesWorkRam,false) end return s end "
         "local c={} for i=0,11 do c[#c+1]=string.format('%04X',emu.read16(0x10A42+2*i,emu.memType.snesWorkRam,false)) end "
         "R.buf[#R.buf+1]={n=n,p2=sum(0x40,32),p7=sum(0xE0,32),c59=emu.read16(0x10AB2,emu.memType.snesWorkRam,false),c0=emu.read16(0x10A00,emu.memType.snesWorkRam,false),c21_2C=table.concat(c,' ')} end end")
PAIRS = [
    ("2F_d1_ctl", 0x2F, 1, [], []),
    ("2F_d1_4D", 0x2F, 1, [77], []),
    ("2F_d3_ctl", 0x2F, 3, [], []),
    ("2F_d3_52", 0x2F, 3, [82], []),
    ("2F_d3_52_4D", 0x2F, 3, [82, 77], []),
    ("2B_ctl", 0x2B, None, [], []),
    ("2B_4D", 0x2B, None, [77], []),
    ("2D_ctl", 0x2D, None, [], []),
    ("2D_4D", 0x2D, None, [77], []),
]
try:
    for nm, sc, day, setf, clr in PAIRS:
        kw = {}
        if day is not None:
            kw["pre"] = [[0x0AA6, day]]
        r = visit(m, info, f"FL23-02_{nm}", S01R, scene=sc, set=setf, settle=300, watch=False, cgram=True, execs=EX,
                  hooks="onSample=fr21.drive{ rec={}, every=" + EVERY + " }", shot=f"FL23-02_{nm}", **kw)
        print(f"== {nm} scene {r['scene']}->{r['sceneEnd']} execs {json.dumps(r.get('execs'))}")
        for b in r.get("buf") or []:
            print("   ", json.dumps(b))
        print("    cgram1", r.get("cgram1"))
finally:
    m.close()
