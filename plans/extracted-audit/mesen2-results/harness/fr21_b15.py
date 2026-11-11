#!/usr/bin/env python3
"""FR21 batch 15: FL22-13 ($B9 = flag 185, byte $0A17 bit 1) the gold statue in scene $20: real sword hits (attack = physical A), simulated hit by an HP poke with playerFlags bit $0002 clear/set, reload."""
from fr21_lib import *  # noqa: F401,F403

m, info = open_o()
REC = "{ {name='fB9',addr=0x0A17,bit=0x02},{name='pf',addr=0x09AE,size=2},{name='mask',addr=0x065A,size=2} }"
HPREC = ("function(R,n) local d=fr21.find(0x88E1,0x892F); if d then local h=fr21.hp(d.slot); if R.hl~=h then R.hl=h; R.hp=R.hp or {}; "
         "if #R.hp<30 then R.hp[#R.hp+1]={n=n,hp=h,pf=kit.r16(0x09AE)} end end elseif not R.gone then R.gone=n end end")
EX = [690458, 690466, 690471]
try:
    runs = (
        ("real_hits", [], "{ [3]=function(R,n) fr21.pos(120,392) end }", "function(R,n) " + "if n>=10 and n%14<2 then fr21.press(R,{'a','up'}) elseif n>=5 then fr21.press(R,{'up'}) end end"),
        ("poke_pf_clear", [], "{ [20]=function(R,n) local d=fr21.find(0x88E1,0x892F); if d then emu.write16(0x10026+d.slot, 0x00FA, emu.memType.snesWorkRam); R.poked=n end end }", None),
        ("poke_pf_set", [], "{ [18]=function(R,n) kit.w16(0x09AE, kit.r16(0x09AE) | 0x0002) end, [20]=function(R,n) local d=fr21.find(0x88E1,0x892F); if d then emu.write16(0x10026+d.slot, 0x00FA, emu.memType.snesWorkRam); R.poked=n end end, [30]=function(R,n) kit.w16(0x09AE, kit.r16(0x09AE) & 0xFFFD) end }", None),
        ("reload_B9", [185], "{}", None),
    )
    for nm, setf, at, ev in runs:
        P = {}
        if nm == "real_hits":
            pass
        extra_every = HPREC
        if ev:
            extra_every = "function(R,n) (" + HPREC + ")(R,n); (" + ev + ")(R,n) end"
        r = visit(m, info, f"FL22-13_{nm}", S01R, scene=0x20, set=setf, settle=260, watch=True, execs=EX,
                  hooks="onSample=fr21.drive{ rec=" + REC + ", at=" + at + ", every=" + extra_every + " }", shot=f"FL22-13_{nm}")
        print(brief(r, limit=8), "hp", r.get("hp"), "gone", r.get("gone"), "poked", r.get("poked"))
        print("   statue actors1:", [(x["file"], x["x"], x["y"]) for x in r["actors1_named"] if "statue" in x["file"]])
finally:
    m.close()
