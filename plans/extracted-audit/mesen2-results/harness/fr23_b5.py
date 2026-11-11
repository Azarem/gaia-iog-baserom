#!/usr/bin/env python3
"""FR23 batch 5: FL26-04 (Magic Dust $14 on Kara's picture, scene $74; scratch $01, flags $89 $8A $8C).
Item preset in inventory slot 0 before the load (the Kara actor tests BranchIfHasItem #14 at spawn), flags written before the warp,
use at n=40 from tile (8,9), optional leave (scene $73) and re-entry at RE, then talk to the picture actor (entry pc $D251-$D257)."""
import json
import sys
from fr23_lib import *  # noqa: F401,F403

REC = ("{ {name='inv0',addr=0x0AB4},{name='s01',addr=0x0A00,bit=0x02},{name='f89',addr=0x0A11,bit=0x02},{name='f8A',addr=0x0A11,bit=0x04},{name='f8C',addr=0x0A11,bit=0x10},"
       "{name='mask',addr=0x065A,size=2},{name='dlg',addr=0x09EC,bit=0x2000},{name='sc',addr=0x0644,size=2} }")
EXECS = [234401, 234421, 234426, 234430, 234433, 446833, 446837, 446841, 447003, 447035, 447044, 447066, 447072, 447078, 447083, 447087, 447090, 447091]
# 234426 code_0393BA (dust on the picture), 234421 "But nothing happened", 446833 Kara rescue entry, 446837 wait $01, 446841 wait $8A,
# 447003 first rescue dialog, 447035 SetFlag $8C, 447044 QueueMapChange $6A, 447066 picture handler test $89, 447072 test $01, 447078 text ($89 set, $01 clear), 447083/447087 text + SetFlag $8A


def trial(m, info, name, set_=None, inv=True, use_at=40, re=None, talk_at=None, set89_on_reentry=False, settle=900, snaps=(), shot=None):
    pre = [[0x0AB4, 0x14]] if inv else []
    uses = "{ {n=%d,x=%d,y=%d,item=20} }" % (use_at, 8 * 16 + 12, 9 * 16 + 20) if use_at else "{}"
    ph = ""
    if re:
        ph = (f"if n=={re} and not R.ph then kit.w16(0x0642,0x73); R.ph='out'; R.tout=n end "
              "if R.ph=='out' and kit.r16(0x0644)==0x73 and n>R.tout+70 then kit.w16(0x0642,0x74); R.ph='in' end "
              "if R.ph=='in' and kit.r16(0x0644)==0x74 and kit.r8(0xB4)==0 then R.ph='ready'; R.nready=n; "
              + ("kit.w8(0x0A11, kit.r8(0x0A11)|0x02); " if set89_on_reentry else "") + "end ")
        ready = "R.ph=='ready' and R.n>R.nready+40"
    else:
        ready = f"R.n>={talk_at or 120}"
    ev = ("every=function(R,n) R.n=n if not R.sq then R.sq=fr23.seq({{wait=function() return " + ready + " end, find={0xD251,0xD257}, dy=16, max=700, done=function() return (kit.r8(0x0A11)&0x04)~=0 or R.nready and R.n>R.nready+400 end}}) end "
          + ph + "if kit.r8(0xB4)~=0 and n%6<2 then fr21.press(R,{'a'}) end R.sq(R,n) end")
    hooks = f"onSample=fr22.drive{{ rec={REC}, use={uses}, snaps={L.lit(list(snaps))}, adv=true, {ev} }}"
    return visit(m, info, name, S01R, scene=0x74, pre=pre, set=set_ or [], settle=settle, watch=False, hooks=hooks, execs=EXECS, shot=shot, frames=settle + 1400)


def show(r):
    print(summarize(r).split(chr(10))[0][:230])
    print("   useRows", json.dumps(r.get("useRows")))
    print("   seq", json.dumps(r.get("seq")))
    print("   execs", json.dumps({k: v for k, v in (r.get("execs") or {}).items() if v[0]}))
    print("   REC", json.dumps(r.get("rec"), separators=(",", ":"))[:1800])
    for k, v in sorted((r.get("snap") or {}).items(), key=lambda kv: int(kv[0])):
        nm = L.actor_names(v)
        print(f"   snap n={k}: " + "; ".join(f"{a['file']}@{a['line']}({a['x']},{a['y']}) pc{b['pc']:04X}" for a, b in zip(nm, v) if a["file"].startswith("av74")))


which = sys.argv[1:] or ["P"]
m, info = open_o()
try:
    if "A" in which:   # control: $89 set, dust used, talk to the picture
        show(trial(m, info, "FL26-04_A_f89set_use_talk", set_=[137], snaps=(30, 700), shot="FL26-04_A", settle=1200))
    if "B" in which:   # $89 clear at the use, leave and re-enter, then $89 set and talk
        show(trial(m, info, "FL26-04_B_f89clear_use_reenter_set89", set_=[], re=300, set89_on_reentry=True, snaps=(30, 700), shot="FL26-04_B", settle=1200))
    if "C" in which:   # $89 set at the use, leave and re-enter, talk
        show(trial(m, info, "FL26-04_C_f89set_use_reenter", set_=[137], re=300, snaps=(30, 700), shot="FL26-04_C", settle=1200))
    if "D" in which:   # $89 clear, use, talk at once (hint text for the unsolved test)
        show(trial(m, info, "FL26-04_D_f89clear_use_talk", set_=[], snaps=(30,), shot="FL26-04_D", settle=700))
    if "P" in which:
        show(trial(m, info, "FL26-04_P_probe_f89set", set_=[137], snaps=(30, 100), shot="FL26-04_P"))
finally:
    m.close()
