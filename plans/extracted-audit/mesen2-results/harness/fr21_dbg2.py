from fr21_lib import *
m, info = open_o()
try:
    for nm, dn in (("a_only", False), ("down_a", True)):
        every = ("function(R,n) local e=R.execs['324865']; if e and e[1]>0 then R.o=R.o or n; local k=n-R.o; "
                 + ("if k>=20 and k<=21 then fr21.press(R,{'down'}) end " if dn else "")
                 + "if k>=40 and k<=41 then fr21.press(R,{'a'}) end "
                 "elseif n>=60 and n%24<2 then fr21.press(R,{'a'}) end end")
        r = visit(m, info, f"dbg2_{nm}", S01R, scene=0x1A, set=[73], settle=400, teleport=[0xD8, 0x1B8], watch=True, execs=[324865, 324877, 324881],
                  walk=[[5, 100, ["up"]]], hold={20: ["b"], 21: ["b"], 22: ["b"]},
                  hooks="onSample=fr21.drive{ at={ [3]=function(R,n) fr21.item(4,0) end }, every=" + every + " }", shot=f"dbg2_{nm}")
        print(nm, r["execs"], "o", r.get("o"))
finally:
    m.close()
