import json
from fr23_lib import *  # noqa: F401,F403
m, info = open_o()
try:
    ev = "every=function(R,n) R.n=n if n%100==0 then local a=fr21.find(0xD7A1,0xD7AA); R.dbg=R.dbg or {}; R.dbg[#R.dbg+1]={n, fr22.dlg() and 1 or 0, a and a.pc or -1, a and a.x or -1, a and a.y or -1, kit.r16(0x065A)} end end"
    hooks = "onSample=fr22.drive{ rec={}, snaps={}, adv=false, " + ev + " }"
    r = visit(m, info, "FL27-05_dbg", S01R, scene=0x92, set=[], settle=400, watch=False, hooks=hooks, frames=900)
    print(json.dumps(r.get("dbg")))
finally:
    m.close()
