from fr21_lib import *
m, info = open_o()
try:
    DBG = "function(R,n) R.dbg=R.dbg or {}; if n%100==0 then R.dbg[#R.dbg+1]={n=n,free=R.free,dmf=kit.r16(0x09EC),mask=kit.r16(0x065A),used=R.used} end end"
    r = visit(m, info, "dbg_first", S01R, scene=0x15, set=[38], settle=700, watch=True,
              hooks=f"onSample=fr21.drive{{ every=fr21.auto{{ item=9, anymask=true, minN=250, free=30, extra={DBG} }} }}")
    print(r.get("dbg"), r.get("used"))
finally:
    m.close()
