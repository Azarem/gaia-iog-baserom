#!/usr/bin/env python3
"""FR30 batch 9: scene-load and inventory-overlay behaviour of the scratch flags.
FL10-01: all flag bytes $0A00-$0A0F, $0A10 and $0A20 written $FF in the disposable load, scene $0E is loaded; at arrival only $0A00-$0A01 are zero (flags $0000-$000F).
FL10-02 / FL10-04: scratch word $0A00 = $035A and flag $FF (byte $0A1F bit 7) set, then the inventory overlay is opened (Select), the bytes are sampled while it is open, B closes it
(tab bar cancel $6000), and the bytes are sampled after the close."""
import json
import sys
from fr30_lib import *  # noqa: F401,F403


def inv_flags(m, info, name, poke, shot=None):
    at = "[3]=function(R,n) %s R.pre=fr30.bytes(0x0A00,2) .. '|' .. fr30.bytes(0x0A1F,1) .. '|' .. fr30.bytes(0x0A02,2) end" % poke
    every = ("function(R,n) if n==10 or n==11 then fr21.press(R,{'select'}) end "
             "if kit.r16(0x0644)==0xFF then R.invOpen=R.invOpen or n end "
             "local o=R.invOpen; if o then local d=n-o; "
             "if d==60 then R.open=fr30.bytes(0x0A00,2) .. '|' .. fr30.bytes(0x0A1F,1) .. '|' .. fr30.bytes(0x0A02,2) .. '|sc=' .. kit.r16(0x0644) end "
             "if d>=70 and d<=150 and (d%16)<4 then fr21.press(R,{(((d//16)%2)==0) and 'b' or 'select'}) end "
             "if d==200 then R.closed=fr30.bytes(0x0A00,2) .. '|' .. fr30.bytes(0x0A1F,1) .. '|' .. fr30.bytes(0x0A02,2) .. '|sc=' .. kit.r16(0x0644) end "
             "if d>=210 then R.stop=true end end end")
    hooks = drive(at=at, every=every, adv=False)
    return visit(m, info, name, S01R, shot=shot, settle=400, watch=False, hooks=hooks)


if __name__ == "__main__":
    m, info = open_o()
    try:
        which = sys.argv[1:] or ["load", "inv"]
        if "load" in which:
            pre = [[a, 0xFF] for a in list(range(0x0A00, 0x0A10)) + [0x0A10, 0x0A20]]
            r = visit(m, info, "load_all_ff", S01R, shot="load_all_ff", scene=14, pre=pre, settle=30, watch=False,
                      hooks="final=function(R) R.endB=fr30.bytes(0x0A00,0x24) end")
            print("FL10-01 pre", r.get("flagsPre")[:72], "\n arrival", (r.get("flags0") or "")[:72], "\n end", r.get("endB"), "err", r.get("error"), "d36", r.get("d36"))
            r2 = visit(m, info, "load_all_ff_repeat", S01R, scene=14, pre=pre, settle=30, watch=False, hooks="final=function(R) R.endB=fr30.bytes(0x0A00,0x24) end")
            print(" repeat equal", r2.get("endB") == r.get("endB"), (r2.get("flags0") or "") == (r.get("flags0") or ""))
        if "inv" in which:
            poke = "kit.w8(0x0A00,0x5A) kit.w8(0x0A01,0x03) kit.w8(0x0A1F,kit.r8(0x0A1F)|0x80) kit.w8(0x0A02,0xC3) kit.w8(0x0A03,0x3C)"
            for nm, p in (("inv_flags", poke), ("inv_flags_repeat", poke)):
                r = inv_flags(m, info, nm, p, shot=nm)
                print(nm, "invOpen", r.get("invOpen"), "\n  pre   ", r.get("pre"), "\n  open  ", r.get("open"), "\n  closed", r.get("closed"), "\n  end sc", r.get("sceneEnd"), "err", r.get("error"), "shot", r.get("screenshot"))
    finally:
        m.close()
