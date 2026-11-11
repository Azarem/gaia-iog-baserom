#!/usr/bin/env python3
"""FR30 batch 7: ability flags $0510+ (FL15): the inventory Status tab (TestAbilityFlag) and abilityBitmask $0AA2 are the same bits.
From scene $01 (S01r): Select (physical Select, logical $2000) opens the inventory overlay (scene $FF), Down x3 moves the tab cursor (vertical list Items/Order/Remove/Cond.) to tab 3 (Status), A confirms.
Runs: control (abilityBitmask 0) and forced (flag written through the flag index), Will and Freedan; the run stops at settle frame STOP and the harness takes a screenshot.
First check: flag <-> byte equivalence both ways, read back."""
import json
import sys
from fr30_lib import *  # noqa: F401,F403

EX = [190554, 190594, 190634, 190276, 46256]


def status(m, info, name, form, flags, abil_byte, stop, shot):
    """flags: global flag indices written (flag convention) after the scene is loaded; abil_byte: ($0AA2 value written instead, or None)."""
    at = "[3]=function(R,n) "
    if form is not None:
        at += "kit.w16(0x0AD4,%d) " % form
    for f in flags:
        at += "gaia.flags.set(%d) " % f
    if abil_byte is not None:
        at += "kit.w8(0x0AA2,%d) " % abil_byte
    at += "R.aa2=kit.r8(0x0AA2); R.aa3=kit.r8(0x0AA3); R.f1296=gaia.flags.get(1296); R.f1300=gaia.flags.get(1300) end"
    every = ("function(R,n) if n==10 or n==11 then fr21.press(R,{'select'}) end "
             "if kit.r16(0x0644)==0xFF then R.invOpen=R.invOpen or n end "
             "local o=R.invOpen; if o then local d=n-o; "
             "if d==50 or d==51 or d==70 or d==71 or d==90 or d==91 then fr21.press(R,{'down'}) end "
             "if d==110 or d==111 then fr21.press(R,{'a'}) end end "
             "if n>=STOP then R.stop=true end end").replace("STOP", str(stop))
    rec = [("tab", 0x0E8C, None, 2)]
    final = "final=function(R) R.aa2e=kit.r8(0x0AA2); R.form=kit.r16(0x0AD4); R.sceneEnd2=kit.r16(0x0644); R.flags=fr30.bytes(0x0AA0,4); R.abilIdx=kit.r16(0x0AE8) end"
    hooks = drive(at=at, every=every, adv=False) + "," + final
    return visit(m, info, name, S01R, shot=shot, settle=stop + 5, watch=False, hooks=hooks, execs=EX, frames=stop + 300)


def show(r):
    print("==", r["experiment"], "scene", r.get("sceneEnd2"), "err", r.get("error"), "aa2", r.get("aa2"), "aa2end", r.get("aa2e"), "form", r.get("form"), "flags", r.get("flags"),
          "abilIdx", r.get("abilIdx"), "invOpen", r.get("invOpen"), "readback f1296/f1300", r.get("f1296"), r.get("f1300"), "aa2 set", r.get("aa2"), r.get("aa3"))
    print("  execs", json.dumps(r.get("execs")), "shot", r.get("screenshot"))


if __name__ == "__main__":
    m, info = open_o()
    try:
        which = sys.argv[1:] or ["c60", "f60"]
        for k in which:
            parts = k.split("_")
            kind, stop = parts[0], int(parts[1])
            if kind == "ctl":
                r = status(m, info, f"status_will_control_{stop}", None, [], None, stop, f"status_will_control_{stop}")
            elif kind == "frc":
                r = status(m, info, f"status_will_forced0510_{stop}", None, [1296], None, stop, f"status_will_forced0510_{stop}")
            elif kind == "frd":
                r = status(m, info, f"status_freedan_forced_{stop}", 1, [1300], None, stop, f"status_freedan_forced_{stop}")
            elif kind == "frdc":
                r = status(m, info, f"status_freedan_control_{stop}", 1, [], None, stop, f"status_freedan_control_{stop}")
            elif kind == "wrong":
                r = status(m, info, f"status_will_flag1300_{stop}", None, [1300], None, stop, f"status_will_flag1300_{stop}")
            elif kind == "w4":
                r = status(m, info, f"status_will_flag1299_{stop}", None, [1299], None, stop, f"status_will_flag1299_{stop}")
            elif kind == "w3":
                r = status(m, info, f"status_will_flags1296_97_98_{stop}", None, [1296, 1297, 1298], None, stop, f"status_will_flags1296_97_98_{stop}")
            elif kind == "shc":
                r = status(m, info, f"status_shadow_control_{stop}", 2, [], None, stop, f"status_shadow_control_{stop}")
            elif kind == "shf":
                r = status(m, info, f"status_shadow_forced_{stop}", 2, [1304, 1305, 1306], None, stop, f"status_shadow_forced_{stop}")
            elif kind == "byt":
                r = status(m, info, f"status_will_byte01_{stop}", None, [], 1, stop, f"status_will_byte01_{stop}")
            show(r)
    finally:
        m.close()
