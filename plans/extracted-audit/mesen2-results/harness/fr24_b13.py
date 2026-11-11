#!/usr/bin/env python3
"""FR24 batch 13: FL29-04 / FL29-05 (falling orbs $F2 / $F3, scene 212 = $D4, Freedan trigger)."""
import sys
from fr24_lib import *  # noqa: F401,F403

which = [w for w in sys.argv[1:] if not w.startswith("-")]
m, info = open_o()
PL = ("function(R,n) local X=kit.r16(0x09AA) local b=emu.read(0x10008+X, emu.memType.snesWorkRam, false) "
      "local a=emu.read16(X+0x28, emu.memType.snesWorkRam, false) R.pl=R.pl or {} R.last=R.last or {} "
      "if R.last.b~=b or R.last.a~=a then R.last.b=b R.last.a=a R.pl[#R.pl+1]=string.format('n%d b=%02X a=%d', n, b, a) end end")
try:
    if "U0" in which:   # Freedan form from the load, list actors, try each button
        h = {}
        for base, bt in ((40, "b"), (90, "a"), (140, "y"), (190, "x"), (240, "l"), (290, "r")):
            for k in range(base, base + 4): h[k] = [bt]
        r = trial(m, info, "FL29-04_U0_freedan_buttons", 212, pre=[[0x0AD4, 1], [0x0AD5, 0]], settle=340, execs=[575213, 575249, 575287, 575293], hold=h, every=PL,
                  rec=[flagrec(242, "fF2"), flagrec(243, "fF3"), ("form", 0x0AD4, None, 2)], shot="FL29-04_U0")
        show(r, rec_limit=10)
        print("   PL", r.get("pl"))
    if "U1" in which:
        h = {}
        for k in range(40, 100): h[k] = ["b"]
        for k in range(140, 144): h[k] = ["b"]
        for k in range(180, 240): h[k] = ["a"]
        for k in range(280, 284): h[k] = ["y"]
        for k in range(320, 380): h[k] = ["x"]
        r = trial(m, info, "FL29-04_U1_freedan_abilities", 212, pre=[[0x0AD4, 1], [0x0AD5, 0], [0x0AA2, 0x70], [0x0AA3, 0]], settle=420, execs=[575213, 575249, 575287, 575293], hold=h, every=PL,
                  at="[10]=function(R,n) fr21.pos(576,448) end", rec=[flagrec(242, "fF2"), flagrec(243, "fF3"), ("form", 0x0AD4, None, 2), ("abil", 0x0AA2, None, 2)], shot="FL29-04_U1")
        show(r, rec_limit=10)
        print("   PL", r.get("pl"))
    if "U2" in which:
        h = {}
        for k in range(40, 100): h[k] = ["b"]
        for k in range(80, 84): h[k] = ["b", "l"]
        for k in range(160, 220): h[k] = ["b"]
        for k in range(200, 204): h[k] = ["b", "r"]
        for k in range(300, 360): h[k] = ["b"]
        for k in range(340, 344): h[k] = ["b", "l", "r"]
        r = trial(m, info, "FL29-04_U2_freedan_charge_LR", 212, pre=[[0x0AD4, 1], [0x0AD5, 0], [0x0AA2, 0x77], [0x0AA3, 0]], settle=420, execs=[575213, 575249, 575287, 575293], hold=h, every=PL,
                  at="[10]=function(R,n) fr21.pos(576,448) end", rec=[flagrec(242, "fF2"), flagrec(243, "fF3"), ("form", 0x0AD4, None, 2), ("pf", 0x09AE, None, 2)], shot="FL29-04_U2")
        show(r, rec_limit=14)
        print("   PL", r.get("pl"))
    POKE = ("function(R,n) if n>=60 and n<=100 then local X=kit.r16(0x09AA) emu.write(0x10008+X, 0x97, emu.memType.snesWorkRam) "
            "emu.write16(X+0x28, 1, emu.memType.snesWorkRam) end end")
    OREC = [flagrec(242, "fF2"), flagrec(243, "fF3"), ("form", 0x0AD4, None, 2)]
    OEX = [575246, 575249, 575267, 575278, 575287, 575293, 575299]
    if "U3" in which:
        show(trial(m, info, "FL29-04_U3_poke_freedan_g1", 212, pre=[[0x0AD4, 1], [0x0AD5, 0]], settle=300, execs=OEX, rec=OREC, every=POKE,
                   at="[10]=function(R,n) fr21.pos(576,448) end", shot="FL29-04_U3", snaps=(30, 250)), rec_limit=10)
    if "U4" in which:
        show(trial(m, info, "FL29-04_U4_poke_will_g1", 212, settle=300, execs=OEX, rec=OREC, every=POKE,
                   at="[10]=function(R,n) fr21.pos(576,448) end", shot="FL29-04_U4"), rec_limit=10)
    if "U6" in which:
        show(trial(m, info, "FL29-05_U6_poke_freedan_g2", 212, pre=[[0x0AD4, 1], [0x0AD5, 0]], settle=300, execs=OEX, rec=OREC, every=POKE,
                   at="[10]=function(R,n) fr21.pos(224,1216) end", shot="FL29-05_U6", snaps=(30, 250)), rec_limit=10)
    if "U7" in which:
        show(trial(m, info, "FL29-05_U7_forced_F3_load", 212, set_=[243], settle=120, execs=OEX, rec=OREC, shot="FL29-05_U7", snaps=(30,)), rec_limit=10)
    if "U8" in which:
        show(trial(m, info, "FL29-04_U8_forced_F2_load", 212, set_=[242], settle=120, execs=OEX, rec=OREC, shot="FL29-04_U8", snaps=(30,)), rec_limit=10)
finally:
    m.close()
