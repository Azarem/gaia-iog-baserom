#!/usr/bin/env python3
"""FR21 batch 20: FL23-11 ($53 = flag 83 byte $0A0A bit 3 herbs, $54 = flag 84 byte $0A0A bit 4 HP jewels) in Freejia scene $32: talk (physical B, direction up) to the three fr32_herb and the three fr32_hp_jewel actors in turn."""
from fr21_lib import *  # noqa: F401,F403

m, info = open_o()
REC = "{ {name='f53',addr=0x0A0A,bit=0x08},{name='f54',addr=0x0A0A,bit=0x10},{name='maxhp',addr=0x0ACA,size=2},{name='mask',addr=0x065A,size=2} }"
EVERY = ("function(R,n) "
         "if n==2 then R.tg={}; for _,a in ipairs(fr20.actors()) do if a.pc>=0xCF20 and a.pc<=0xCF40 then R.tg[#R.tg+1]={k='herb',x=a.x,y=a.y} elseif a.pc>=0xCF88 and a.pc<=0xCFA0 then R.tg[#R.tg+1]={k='jewel',x=a.x,y=a.y} end end "
         "table.sort(R.tg,function(p,q) if p.k~=q.k then return p.k<q.k end return p.x<q.x end) end "
         "local seg=math.floor((n-5)/220)+1; local t=R.tg and R.tg[seg]; local off=(n-5)%220; "
         "if t and off==0 then fr21.pos(t.x,t.y+16); R.seg=R.seg or {}; R.seg[#R.seg+1]={seg=seg,k=t.k,x=t.x,y=t.y,n=n,e53=R.execs['380732'] and R.execs['380732'][1] or 0,e54=R.execs['380828'] and R.execs['380828'][1] or 0,call=(R.execs['380721'] and R.execs['380721'][1] or 0)+(R.execs['380822'] and R.execs['380822'][1] or 0),inv=fr21.inv()} end "
         "if t and off>=10 and off<200 and off%14<2 then fr21.press(R,{'b','up'}) end "
         "if n==5+220*6 then R.seg[#R.seg+1]={seg=7,n=n,e53=R.execs['380732'] and R.execs['380732'][1] or 0,e54=R.execs['380828'] and R.execs['380828'][1] or 0,call=(R.execs['380721'] and R.execs['380721'][1] or 0)+(R.execs['380822'] and R.execs['380822'][1] or 0),inv=fr21.inv()} end end")
try:
    r = visit(m, info, "FL23-11_all", S01R, scene=0x32, set=[100, 87], settle=1400, watch=False, execs=[380721, 380727, 380732, 380822, 380828],
              hooks="onSample=fr21.drive{ rec=" + REC + ", every=" + EVERY + " }", shot="FL23-11_all")
    print(brief(r, limit=16))
    for s in r.get("seg") or []:
        print("  ", json.dumps(s))
    print("   targets", r.get("tg"))
finally:
    m.close()
