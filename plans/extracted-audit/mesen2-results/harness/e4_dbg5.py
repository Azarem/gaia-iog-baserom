import json, sys
sys.path.insert(0, ".")
import e4_run as r
m, info = r.open_session()
m.call("load_state_file", path=r.sp("orig_E4_credits.mss"))
code = open("e4_dbg5.lua").read()
res = m.run_script_checked(code, frames=30000, includes=["gaia_kit"], turbo=True, timeoutMs=170000, maxLog=60, name="dbg5")
print(res.get("result"))
for e in res.get("log", {}).get("entries", [])[-20:]:
    print(e["text"][:200])
m.close()
