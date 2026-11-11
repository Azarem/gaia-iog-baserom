import json
import sys
from fr23_lib import *  # noqa: F401,F403
m, info = open_o()
try:
    steps = []
    for dy in (4, 4, 6):
        steps.append("{wait=function() return R.n>=60 end, find={0xE37D,0xE3B5}, dy=%d, max=70, done=function() return R.talked end, pre=function() R.talked=false end}" % dy)
    ev = ("every=function(R,n) R.n=n if fr22.dlg() then R.talked=true end if not R.sq then R.sq=fr23.seq({" + ",".join(steps) + "}) end R.sq(R,n) end")
    hooks = "onSample=fr22.drive{ rec={ {name='dlg',addr=0x09EC,bit=0x2000},{name='mask',addr=0x065A,size=2} }, snaps={}, adv=false, " + ev + " }"
    r = visit(m, info, "FL27-07_scan_neil", S01R, scene=0x95, pre=[], set=[164, 165], settle=700, watch=False, hooks=hooks, execs=[517010, 517016, 516636, 516886], frames=1500)
    print(json.dumps(r.get("seq")))
    print(json.dumps(r.get("execs")))
    print(json.dumps(r.get("rec"))[:600])
finally:
    m.close()
