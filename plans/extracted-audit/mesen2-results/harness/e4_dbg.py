#!/usr/bin/env python3
"""E4 debug: load a state, load a short Lua snippet, advance, print the script log (harness bugs only)."""
import json
import sys

sys.path.insert(0, ".")
import e4_run as r  # noqa: E402

state = sys.argv[1]
frames = int(sys.argv[2])
code = open(sys.argv[3]).read()
m, info = r.open_session()
m.call("load_state_file", path=r.sp(state))
print(json.dumps(m.call("load_script", code=code, name="dbg", includes=r.INC))[:600])
for i in range(frames // 30):
    m.call("advance_frame", frames=30, turbo=True)
    if len(sys.argv) > 4:
        print(m.shot("E4_dbg").get("path"))
    print("chunk", i, json.dumps(m.call("get_script_result", name="dbg"))[:60])
for e in m.call("get_script_log", name="dbg", max=5000)["entries"]:
    if not e["text"].startswith("Registered"):
        print(e["frame"], e["text"][:700])
print(json.dumps(m.call("get_script_result", name="dbg"))[:3000])
m.close()
