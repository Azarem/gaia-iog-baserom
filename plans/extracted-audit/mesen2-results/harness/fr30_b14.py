#!/usr/bin/env python3
"""FR30 batch 14: other D4 trials. Each from S01r with a quick warp to the scene, the player teleported under the target, `up` for 72 frames, then A/B pulses.
FL12-03: scene $60 flag-only chest (1E,18), flag $022E (global 558, byte $0A45 bit 6).
FL12-02: scene $2E fanfare chest (25,19), flag $0208 (global 520, byte $0A41 bit 0), item $38; control with free slots, forced with all 16 slots full ($0AB4-$0AC3 written).
FL12-04: scene $03 hidden jewel at (07,18), flag $0280 (global 640, byte $0A50 bit 0).  FL12-05: scene $01 jewel (08,0C), flag $0281 (641).
Args: key [stop]"""
import json
import sys
from fr30_lib import *  # noqa: F401,F403

EX = [173552, 173602, 173704, 257943]
CASES = {
    "c60": dict(scene=96, tele=(496, 424), flag=558, byte=0x0A45, bit=0x40, rect=(0x1E, 0x17, 2, 2)),
    "c2E": dict(scene=46, tele=(608, 440), flag=520, byte=0x0A41, bit=0x01, rect=(0x25, 0x18, 2, 2)),
    "j03": dict(scene=3, tele=(112, 408), flag=640, byte=0x0A50, bit=0x01, rect=None),
    "j01": dict(scene=1, tele=(136, 208), flag=641, byte=0x0A50, bit=0x02, rect=None),
}


def trial(m, info, key, name, setf, stop, full=False, shot=None):
    c = CASES[key]
    rect = ("R.rect1=fr30.rect(%d,%d,%d,%d,0)" % c["rect"]) if c["rect"] else ""
    full_lua = "for i=0,15 do kit.w8(0x0AB4+i, 0x11+i) end " if full else ""
    at = "[1]=function(R,n) %s R.inv1=fr21.inv(); R.b1=kit.r8(0x%04X) end" % (rect, c["byte"])
    if full:
        at += ",[2]=function(R,n) %s R.invF=fr21.inv() end" % full_lua
    every = ("function(R,n) if n>=90 and (n%%12)<2 then fr21.press(R,{(((n//12)%%2)==0) and 'a' or 'b'}) end "
             "if n==%d then R.mid={dmf=kit.r16(0x09EC),pf=kit.r16(0x09AE),b=kit.r8(0x%04X)} end if n>=%d then R.stop=true end end") % (stop, c["byte"], stop)
    final = ("final=function(R) %s R.inv2=fr21.inv(); R.b2=kit.r8(0x%04X); R.dmf=kit.r16(0x09EC); R.pf=kit.r16(0x09AE) end") % (
        ("R.rect2=fr30.rect(%d,%d,%d,%d,0);" % c["rect"]) if c["rect"] else "", c["byte"])
    hooks = drive(rec=[("flag", c["byte"], c["bit"], 1), ("inv0", 0x0AB4, None, 1), ("dmf20", 0x09EC, 0x2000, 2)], at=at, every=every, adv=False) + "," + final + ",walk={{12,72,{'up'}}}"
    return visit(m, info, name, S01R, shot=shot, scene=c["scene"], set=setf, teleport=list(c["tele"]), settle=stop + 20, watch=False, hooks=hooks, execs=EX)


def show(r, c):
    print("==", r["experiment"], "scene", r.get("scene"), "err", r.get("error"), "d36", r.get("d36"))
    print("  byte@arrival", hex(r.get("b1") or 0), "@mid", r.get("mid"), "@end", hex(r.get("b2") or 0), "dmf", hex(r.get("dmf") or 0), "pf", hex(r.get("pf") or 0))
    print("  inv1", r.get("inv1"), "inv2", r.get("inv2"), "invF", r.get("invF"))
    print("  rect1", r.get("rect1"), "rect2", r.get("rect2"))
    print("  execs", json.dumps(r.get("execs")), "shot", r.get("screenshot"))
    rec = [x for x in (r.get("rec") or []) if "flag" in x or "dmf20" in x]
    print("  rec", json.dumps(rec[:12], separators=(",", ":")))


if __name__ == "__main__":
    key = sys.argv[1]
    stops = [int(x) for x in sys.argv[2:]] or [160, 320]
    m, info = open_o()
    try:
        c = CASES[key]
        for stop in stops:
            for nm, setf, full in ((f"{key}_control_{stop}", [], False), (f"{key}_forced_{stop}", [c["flag"]], False)) + (((f"{key}_full_{stop}", [], True),) if key == "c2E" else ()):
                r = trial(m, info, key, nm, setf, stop, full, shot=nm)
                show(r, c)
    finally:
        m.close()
