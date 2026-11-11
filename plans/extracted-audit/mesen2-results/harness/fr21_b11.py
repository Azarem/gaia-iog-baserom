#!/usr/bin/env python3
"""FR21 batch 11: scene $1E trials: FL22-02 (scratch $00 vs Y), FL22-05 (Incan Statue A, $30), FL22-06 (Incan Statue B, $31, slide), FL22-08 tail (spirits hint text, $44)."""
from fr21_lib import *  # noqa: F401,F403

m, info = open_o()
REC = ("{ {name='s00',addr=0x0A00,bit=0x01},{name='f30',addr=0x0A06,bit=0x01},{name='f31',addr=0x0A06,bit=0x02},{name='mask',addr=0x065A,size=2},"
       "{name='ypos',addr=0x09A4,size=2},{name='sp',addr=0x09B2,size=2},{name='slot0',addr=0x0AB4} }")
KEEP = ("ir1E_cliff_mantel_a", "ir1E_cliff_mantel_b", "ir1E_cliff_slide_trigger")
SNAP = "function(R,n) R.snap=R.snap or {}; R.snap[tostring(n)]=fr20.actors() end"


def go(nm, setf, at, settle, every="", hold=None, shot=None, execs=None, walk=None, mash=None):
    P = dict(scene=0x1E, set=setf, settle=settle, watch=True)
    if execs:
        P["execs"] = execs
    if hold:
        P["hold"] = hold
    if walk:
        P["walk"] = walk
    if mash:
        P["mash"] = mash
    r = visit(m, info, nm, S01R, shot=shot or nm, hooks="onSample=fr21.drive{ rec=" + REC + ", at=" + at + (", every=" + every if every else "") + " }", **P)
    print(brief(r, files=KEEP, keys=("s00", "f30", "f31", "mask", "ypos", "sp", "slot0"), limit=14))
    print("   mantel/trigger actors1:", [(x["file"], x["x"], x["y"], hex(x["f10"])) for x in r["actors1_named"] if x["file"] in KEEP], "n actors", len(r["actors1"]))
    return r


try:
    # FL22-02: scratch $00 follows playerYPos < $0110 (actor y < $0120); forced: $30 and $31 set
    for nm, setf in (("FL22-02_ctl", []), ("FL22-02_f30_31", [48, 49])):
        at = "{ [10]=function(R,n) fr21.pos(100,0x100) end, [70]=function(R,n) fr21.pos(100,0x200) end, [130]=function(R,n) fr21.pos(100,0x100) end, [190]=function(R,n) fr21.pos(100,0x200) end }"
        go(nm, setf, at, 250)
    # FL22-05: Incan Statue A on tile (37,12): px = 0x37*16+8, py = 0x12*16+24
    at = "{ [4]=function(R,n) fr21.pos(0x378,0x138); fr21.item(3,0) end, [10]=function(R,n) R.t=fr21.tile() end }"
    go("FL22-05_use", [], at, 300, hold={14: ["y"], 15: ["y"], 16: ["y"]}, mash={"button": "b", "from": 50, "to": 120, "down": 2, "gap": 20}, execs=[231098], every="function(R,n) if n==3 then R.snap=R.snap or {}; end end")
    go("FL22-05_reload_f30", [48], "{}", 120)
    go("FL22-05_reload_none", [], "{}", 120)
    # FL22-06: statue B on (26,15): px = 0x26*16+8, py = 0x15*16+24
    at = "{ [4]=function(R,n) fr21.pos(0x268,0x168); fr21.item(4,0) end, [200]=function(R,n) fr21.pos(0x1E8,0x120) end }"
    go("FL22-06_use_then_trigger", [48], at, 600, hold={14: ["y"], 15: ["y"], 16: ["y"]}, mash={"button": "b", "from": 50, "to": 120, "down": 2, "gap": 20}, execs=[231376])
    go("FL22-06_ctl_trigger_only30", [48], "{ [10]=function(R,n) fr21.pos(0x1E8,0x120) end }", 400)
    go("FL22-06_trigger_both", [48, 49], "{ [10]=function(R,n) fr21.pos(0x1E8,0x120) end }", 400)
    go("FL22-06_trigger_both_1E7", [48, 49], "{ [10]=function(R,n) fr21.pos(0x1E7,0x120) end }", 400)
    # FL22-08 tail: statue A on a wrong tile: text with $44 clear / set
    for nm, setf in (("FL22-08_spirits_ctl44clear", []), ("FL22-08_spirits_44set", [68])):
        go(nm, setf, "{ [4]=function(R,n) fr21.item(3,0) end }", 60, hold={14: ["y"], 15: ["y"], 16: ["y"]})
finally:
    m.close()
