#!/usr/bin/env python3
"""FR23 batch 4: FL27-03 / FL31-04 (flag $96 = byte $0A12 bit 6, scene $78): control (flags $8D $91 set, $96 $97 clear) talk to the wandering glass actor;
forced ($96 set before the load): palette (CGRAM), festival thinker execs, ten children, opponent."""
import json
import os
import sys
from fr23_lib import *  # noqa: F401,F403

REC = ("{ {name='f96',addr=0x0A12,bit=0x40},{name='f97',addr=0x0A12,bit=0x80},{name='mask',addr=0x065A,size=2},"
       "{name='dlg',addr=0x09EC,bit=0x2000},{name='sc',addr=0x0644,size=2},{name='aa6',addr=0x0AA6,size=2},{name='s02',addr=0x0A00,bit=0x04},{name='s0F',addr=0x0A01,bit=0x80} }")
EXECS = [46934, 46940, 46947, 46952, 496183, 496188, 496192, 495734, 495738]


def trial(m, info, name, scene, set_=None, post=None, tp=None, settle=300, shot=None, snaps=(), execs=None, talk=(), rec=REC, **kw):
    ev = f"every=fr23.talker({L.lit(list(talk))})" if talk else ""
    hooks = f"onSample=fr22.drive{{ rec={rec}, snaps={L.lit(list(snaps))}, {ev} }}"
    return visit(m, info, name, S01R, scene=scene, set=set_ or [], post=post, teleport=tp, settle=settle, watch=False, hooks=hooks, shot=shot,
                 execs=execs, frames=settle + 1400, **kw)


def show(r):
    print(summarize(r).split("\n")[0])
    print("   actors0 files:", dict(count_files(r, "actors0")))
    print("   actors1 files:", dict(count_files(r, "actors1")))
    print("   execs", json.dumps(r.get("execs")))
    rows = r.get("rec") or []
    print("   REC (%d rows)" % len(rows), json.dumps(rows[:30], separators=(",", ":")))
    print("   talk", json.dumps(r.get("talk")))
    cg = [k for k in r if k.startswith("cgram")]
    if cg:
        ks = sorted(cg, key=lambda k: int(k[5:]))
        print("   cgram1", r[ks[0]])
    for k, v in sorted((r.get("snap") or {}).items(), key=lambda kv: int(kv[0])):
        nm = L.actor_names(v)
        print(f"   snap n={k}: " + "; ".join(f"{a['file']}@{a['line']}({a['x']},{a['y']}) pc{b['pc']:04X}" for a, b in zip(nm, v) if a["file"] == "wa78_glass_game"))


which = [w for w in sys.argv[1:] if not w.startswith("-")] or ["G0", "G1"]
m, info = open_o()
try:
    if "G0" in which:
        talk = [dict(n=40, find=[0x8FC0, 0x8FFF], dy=16, len=60)]
        show(trial(m, info, "FL27-03_G0_s78_ctl", 0x78, set_=[141, 145], settle=400, execs=EXECS, talk=talk, cgram=True, snaps=(30, 380), shot="FL27-03_G0"))
    if "G1" in which:
        show(trial(m, info, "FL27-03_G1_s78_96", 0x78, set_=[141, 145, 150], settle=400, execs=EXECS, cgram=True, snaps=(30,), shot="FL27-03_G1"))
    if "PAL" in which:   # CGRAM colours 0x10-0x7F right after the banner (settle 2) against the two palette files
        import struct
        base = r"C:\Work\gaia-iog-baserom\extracted\watermia\watermia"
        files = {k: open(os.path.join(base, k + ".pal"), "rb").read() for k in ("pal_watermia", "pal_watermia_dark")}
        for nm, st in (("ctl", [141, 145]), ("f96", [141, 145, 150])):
            r = trial(m, info, f"FL27-03_PAL_{nm}", 0x78, set_=st, settle=2, execs=None)
            cg = m.mem(0x20, 224, type="snesCgRam")
            cgb = bytes(cg["bytes"]) if isinstance(cg, dict) else bytes(cg)
            out = {}
            for k, b in files.items():
                seg = b[:224]
                out[k] = sum(1 for i in range(224) if seg[i] == cgb[i])
            print(nm, "bytes equal to file (of 224):", out, " scene", r.get("scene"))
            store(f"FL27-03_PAL_{nm}_cgram", {"cgram_0x20_224": list(cgb), "equal": out})
    if "GAME" in which:   # play the Russian Glass game from the start: talk, player glass $08, talk, player glass $02, talk (opponent skips glasses the player took)
        bits = "function(b) return (kit.r16(0x0AA6) & b) ~= 0 end"
        steps = [
            "{find={0x8FCA,0x9230}, dy=16, done=function() return (kit.r8(0x0A00)&0x04)~=0 end}",
            "{wait=function() return (kit.r8(0x0A01)&0x80)~=0 end, find={0x99D6,0x99F4}, dy=16, done=function() return (kit.r16(0x0AA6)&0x08)~=0 end}",
            "{find={0x8FCA,0x9230}, dy=16, done=function() return (kit.r8(0x0A00)&0x08)~=0 end}",
            "{wait=function() return (kit.r8(0x0A01)&0x80)~=0 end, find={0x9A50,0x9A6E}, dy=16, done=function() return (kit.r16(0x0AA6)&0x02)~=0 end}",
            "{find={0x8FCA,0x9230}, dy=16, done=function() return (kit.r8(0x0A00)&0x10)~=0 end}",
        ]
        ev = "every=function(R,n) if not R.sq then R.sq=fr23.seq({" + ",".join(steps) + "}) end R.sq(R,n); if kit.r16(0x0644)~=0x78 and kit.r16(0x0644)~=0 then R.endSc=R.endSc or n end; if R.endSc and n>R.endSc+10 then R.stop=true end end"
        rec = REC.replace("{name='s0F'", "{name='s03',addr=0x0A00,bit=0x08},{name='s04',addr=0x0A00,bit=0x10},{name='hp',addr=0x0ACE,size=2},{name='s0F'")
        hooks = f"onSample=fr22.drive{{ rec={rec}, snaps={{}}, {ev} }}"
        r = visit(m, info, "FL27-03_GAME_s78_96", S01R, scene=0x78, set=[141, 145, 150], settle=3000, watch=False, hooks=hooks, execs=[496163, 496166, 496153, 496125, 495734, 495820, 495905, 495994, 496069], shot="FL27-03_GAME", frames=4500)
        print(summarize(r).split(chr(10))[0])
        print("   seq", json.dumps(r.get("seq")))
        print("   execs", json.dumps(r.get("execs")))
        print("   REC", json.dumps(r.get("rec"), separators=(",", ":"))[:2500])
        print("   flag diff arrival>end", json.dumps(flag_diff(r["flags0"], r["flags1"])) if r.get("flags0") else None, "scene end", r.get("sceneEnd"))
    if "FIFTH" in which:   # FL27-11: fifth glass (code_079AAC) with scratch $0F clear and set; Yes/No via pdir
        for tag, pre, pdir in (("ctl", "nil", "up"), ("f0F_up", "function() kit.w8(0x0A01, kit.r8(0x0A01)|0x80) end", "up"), ("f0F_down", "function() kit.w8(0x0A01, kit.r8(0x0A01)|0x80) end", "down")):
            st = "{pre=%s, find={0x9A8D,0x9AD2}, dy=16, pdir='%s', max=500, done=function() return kit.r16(0x0ACE)==0 end}" % (pre, pdir)
            ev = "every=function(R,n) if not R.sq then R.sq=fr23.seq({" + st + "}) end if n>=60 then R.sq(R,n) end end"
            rec = REC.replace("{name='s0F'", "{name='hp',addr=0x0ACE,size=2},{name='s0F'")
            hooks = f"onSample=fr22.drive{{ rec={rec}, snaps={{}}, {ev} }}"
            r = visit(m, info, f"FL27-11_FIFTH_{tag}", S01R, scene=0x78, set=[141, 145, 150], settle=700, watch=False, hooks=hooks, execs=[498348, 498354, 498358, 498370, 498381, 498386], shot=f"FL27-11_{tag}", frames=2000)
            print(tag, summarize(r).split(chr(10))[0][:200])
            print("   seq", json.dumps(r.get("seq")))
            print("   execs", json.dumps(r.get("execs")))
            print("   REC", json.dumps(r.get("rec"), separators=(",", ":"))[:900])
finally:
    m.close()
