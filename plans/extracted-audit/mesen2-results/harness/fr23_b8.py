#!/usr/bin/env python3
"""FR23 batch 8: FL27-05 ($9F) and FL27-08 ($AC): Erasquez (scene $92, entry pc $D7A1-$D7AA) with and without the Teapot ($19), and the Euro exit menu (scene $91, tiles (3F,42)-(40,48))."""
import json
import sys
from fr23_lib import *  # noqa: F401,F403

DYS = [int(x[2:]) for x in sys.argv[1:] if x.startswith('dy')] or [16]
which = [x for x in sys.argv[1:] if not x.startswith('dy')] or ["R0", "R1", "R3", "E0", "E1", "E2", "E3"]
REC = "{ {name='f9F',addr=0x0A13,bit=0x80},{name='fAC',addr=0x0A15,bit=0x10},{name='inv0',addr=0x0AB4},{name='mask',addr=0x065A,size=2},{name='sc',addr=0x0644,size=2} }"


def er(m, info, name, inv, set_):
    steps = ",".join("{wait=function() return R.n>=60 end, find={0xD7A1,0xD7AA}, dy=%d, nodlg=true, max=30}" % d for d in DYS)
    ev = "every=function(R,n) R.n=n if not R.sq then R.sq=fr23.seq({" + steps + "}) end R.sq(R,n) end"
    hooks = f"onSample=fr22.drive{{ rec={REC}, snaps={{30}}, adv=false, {ev} }}"
    r = visit(m, info, name, S01R, scene=0x92, pre=[[0x0AB4, 0x19]] if inv else [], set=set_, settle=500, watch=False, hooks=hooks, execs=[513962, 513967, 513973, 513976, 513981, 513986], shot=name.split("_")[0] + "_" + name.split("_")[1], frames=1400)
    print(name, summarize(r).split(chr(10))[0][:150])
    print("   seq", json.dumps(r.get("seq")))
    print("   execs(513962 BranchIfHasItem, 513967 test $9F, 513973 SetFlag $9F, 513976 text1, 513981 text2, 513986 evil text)", json.dumps({k: v for k, v in (r.get("execs") or {}).items() if v[0]}))
    print("   rec", json.dumps(r.get("rec"), separators=(",", ":"))[:500])
    for k, v in sorted((r.get("snap") or {}).items()):
        print("   snap", k, "; ".join(f"{a['file']}({a['x']},{a['y']})" for a in L.actor_names(v) if a["file"].startswith("eu92_erasquez")))


def ex(m, info, name, set_):
    X = (0x3F * 16 + 8, 0x44 * 16 + 16)
    hooks = f"onSample=fr22.drive{{ rec={REC}, snaps={{}}, adv=false }}"
    r = visit(m, info, name, S01R, scene=0x91, set=set_, teleport=list(X), settle=200, watch=False, hooks=hooks, execs=[52328, 52344, 52360], shot=name.split("_")[0] + "_" + name.split("_")[1], frames=900)
    print(name, summarize(r).split(chr(10))[0][:150])
    print("   execs(52328 menu $0F, 52344 menu $10, 52360 menu $1A)", json.dumps(r.get("execs")))
    print("   rec", json.dumps(r.get("rec"), separators=(",", ":"))[:300])


def rof(m, info, name, inv):
    steps = ",".join("{wait=function() return R.n>=60 end, find={0xD606,0xD60E}, dy=8, nodlg=true, max=30}" for _ in range(4))
    ev = "every=function(R,n) R.n=n if not R.sq then R.sq=fr23.seq({" + steps + "}) end R.sq(R,n) end"
    hooks = f"onSample=fr22.drive{{ rec={REC}, snaps={{30}}, adv=false, {ev} }}"
    r = visit(m, info, name, S01R, scene=0x92, pre=[[0x0AB4, 0x19]] if inv else [], set=[158], settle=500, watch=False, hooks=hooks, execs=[513551, 513556, 513561], shot=name.split("_")[0] + "_" + name.split("_")[1], frames=1400)
    print(name, summarize(r))
    print("   execs(513551 test, 513556 no-Teapot text, 513561 Teapot text)", json.dumps({k: v for k, v in (r.get("execs") or {}).items() if v[0]}))
    print("   rec", json.dumps(r.get("rec"), separators=(",", ":"))[:300])


m, info = open_o()
try:
    if "RF0" in which:
        rof(m, info, "FL40-05_RF0_rofsky_noitem", False)
    if "RF1" in which:
        rof(m, info, "FL40-05_RF1_rofsky_teapot", True)
    if "R0" in which:
        er(m, info, "FL27-05_R0_er_noitem", False, [])
    if "R1" in which:
        er(m, info, "FL27-05_R1_er_teapot", True, [])
    if "R3" in which:
        er(m, info, "FL27-05_R3_er_9F_noitem", False, [159])
    if "E0" in which:
        ex(m, info, "FL27-05_E0_exit_ctl", [165])
    if "E1" in which:
        ex(m, info, "FL27-05_E1_exit_9F", [165, 159])
    if "E2" in which:
        ex(m, info, "FL27-08_E2_exit_AC", [165, 172])
    if "E3" in which:
        ex(m, info, "FL27-08_E3_exit_9F_AC", [165, 159, 172])
finally:
    m.close()
