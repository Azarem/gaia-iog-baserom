#!/usr/bin/env python3
"""W1-f address census sessions (ROM O): batch "body table users" ($0AC8 and every instruction that selects, applies or draws a body_table row).

usage: w1f_session.py [--only name,name] [--skip name,name] [--list] [--natural] [--boot] [--frames N] [--tag TEXT]

The session table of W1-a / W1-b is reused (states, seeded bots, direction patterns, timelines, quick warps, the recorded natural replay: imported from
w1a_session and w1b_session); the census is kit/lib/w1f_kit.lua (`w1f.start`: the w1d census engine plus the SetPlayerSpriteDirect, body-row, playerFlags bit 15 and
GetPlayerFacingDirection probes). Extra sessions of this batch: the `add(...)` calls below (the rows after the shared table).
Every session: load a state, run the H1 validity test (load, advance_frame 120, check cpu.k / cpu.sp / scene), load the state again and run the census.
Result of each session: raw/W1f_<name>_<date>.json (census rows, probe tables, controls, H1 record, the Lua text). w1f_report.py merges them.
"""
import argparse
import json
import os
import sys
import time

import w1a_session as A
import w1b_session as B   # registers the W1-b extra sessions into A.S
from a_common import RAW, S01R, open_session, stamp

S = A.S
st = A.st
TALK = A.TALK
MELEE = A.MELEE
INCLUDES = ["gaia_kit", "a_census", "a_actors", "w1d_kit", "w1f_kit"]


def add(name, state, frames, note, **kw):
    S.append(dict(name=name, state=state, frames=frames, note=note, **kw))


# ---- extra sessions of batch f are appended by w1f_extra.py (imported below when present) ----
try:
    import w1f_extra  # noqa: F401  (calls add() of this module)
except ImportError:
    pass


def lua_for(s):
    ats = []
    if s.get("scene") is not None:
        ats.append("[2]=function() kit.w16(0x0642, %d) end" % s["scene"])
    for fr, sc in s.get("chain", []):
        ats.append("[%d]=function() kit.w16(0x0642, %d) end" % (fr, sc))
    for fr, code in s.get("atcode", []):
        ats.append("[%d]=function() %s end" % (fr, code))
    head, extra = "", ""
    drive = s["drive"]
    if drive == "pattern":
        head += A.DIR_PATTERN % ()
        extra = "input=pattern, "
    elif drive == "bot":
        extra = "bot=%s, " % A.bot_lua(s["bot"])
    elif drive == "timeline":
        steps = ",".join("{n=%d,b={%s}}" % (n, ",".join(json.dumps(b) for b in bl)) for n, bl in s["steps"])
        extra = "timeline={start=%d,loop=%s,steps={%s}}, " % (s.get("tlstart", 1), "true" if s.get("loop") else "false", steps)
    if s.get("lua_head"):
        head += s["lua_head"] + "\n"
    if s.get("input_fn"):
        extra += "input=%s, " % s["input_fn"]
    at = "at={" + ",".join(ats) + "}, " if ats else ""
    return ("W1F_DBG = {}\n" + head + "local h = w1f.start{logCap=60}\n" +
            "acen.run{frames=%d, writes=false, reads=false, refill=%d, %s%s" % (s["frames"], s.get("refill", 10), extra, at) +
            "final=function() local r = h.rowsF(); r.endScene = kit.r16(0x0644); r.endHp = kit.r16(0x0ACE); "
            "r.endFlags = kit.r16(0x09AE); r.endAbil = kit.r16(0x0AA2); r.endForm = kit.r16(0x0AD4); r.endAc8 = kit.r16(0x0AC8); r.dbg = W1F_DBG; return r end}")


def check_ats(s):
    seen = {}
    if s.get("scene") is not None:
        seen[2] = 1
    for fr, _ in s.get("chain", []):
        seen[fr] = seen.get(fr, 0) + 1
    for fr, _ in s.get("atcode", []):
        seen[fr] = seen.get(fr, 0) + 1
    dup = [fr for fr, n in seen.items() if n > 1]
    if dup:
        raise RuntimeError("duplicate at-frames %s in %s" % (dup, s["name"]))


def run_session(m, info, s, frames=None, tag=""):
    t = time.time()
    if frames:
        s = dict(s, frames=frames)
    check_ats(s)
    rec = A.h1(m, s["state"])
    if not rec["ok"]:
        raise RuntimeError("H1 failed %s" % rec)
    m.call("load_state_file", path=s["state"])
    for addr, val, size in s.get("pokes", []):
        m.poke(addr, val)
    code = lua_for(s)
    r = m.run_script_checked(code, ok_stop=("script_done",), name="w1f_run", includes=INCLUDES, frames=s["frames"] + 20, turbo=True, timeoutMs=2400000)
    res = r["result"]
    res["session"] = {k: v for k, v in s.items() if k not in ("bot", "steps")}
    res["h1"] = rec
    res["rom"] = info
    res["lua"] = code
    res["warnings"] = r.get("__warnings__", [])
    res["log"] = r.get("log")
    res["seconds"] = round(time.time() - t, 1)
    out = os.path.join(RAW, "W1f_%s%s_%s.json" % (s["name"], tag, stamp()))
    with open(out, "w", encoding="utf-8") as f:
        json.dump(res, f, indent=1)
    return res


def run_natural(m, info):
    t = time.time()
    N = A.NATURAL
    rec = A.h1(m, N["state"])
    if not rec["ok"]:
        raise RuntimeError("H1 failed %s" % rec)
    m.call("load_state_file", path=N["state"])
    with open(N["input"], encoding="utf-8") as f:
        doc = json.load(f)
    lua = ("local h = w1f.start{logCap=60}\nlocal pub = false\n"
           "kit.onFrame(function() if h.frames >= 20050 and not pub then pub = true; emu.mcp.result(h.rowsF()) end end)\n")
    m.call("load_script", name="w1f_nat", code=lua, includes=INCLUDES)
    total = 0
    for part in A.chunk_sequence(doc["segments"]):
        m.call("play_input", sequence=part, turbo=True, thenPause=True)
        total += sum(p["frames"] for p in part)
        print("  natural: %d frames" % total, flush=True)
    m.call("advance_frame", frames=70, turbo=True)
    res = m.call("get_script_result", name="w1f_nat")
    res = res.get("result", res) if isinstance(res, dict) else res
    out_png = m.shot("W1f_natural_end")
    m.call("unload_script", name="w1f_nat")
    final = dict(census=res, h1=rec, rom=info, lua=lua, inputFile=os.path.basename(N["input"]), inputFrames=total, seconds=round(time.time() - t, 1),
                 screenshot=out_png, endScene=m.u16(0x0644))
    out = os.path.join(RAW, "W1f_%s_%s.json" % (N["name"], stamp()))
    with open(out, "w", encoding="utf-8") as f:
        json.dump(final, f, indent=1)
    return final


def run_boot(m, info, frames=900):
    """Cold boot census (fromReset power): the boot-time writers (DMA zero fill, wram-init) and the first scene transitions."""
    t = time.time()
    code = ("local h = w1f.start{logCap=60}\n"
            "kit.onFrame(function() if h.frames >= %d then local r = h.rowsF(); r.endScene = kit.r16(0x0644); kit.finish(r) end end)" % frames)
    r = m.run_script_checked(code, ok_stop=("script_done",), name="w1f_run", includes=["gaia_kit", "w1d_kit", "w1f_kit"], frames=frames + 20, turbo=True,
                             timeoutMs=1800000, fromReset="power")
    res = dict(session=dict(name="boot_power", frames=frames, note="cold boot (fromReset power), %d frames" % frames), final=r["result"], rom=info, lua=code,
               h1=dict(state="(cold boot, no state)", ok=True, k=0x80, sp=0x1FF, scene=r["result"].get("endScene"), expectScene=None),
               frames=r["result"].get("frames"), scene=r["result"].get("endScene"), seconds=round(time.time() - t, 1), log=r.get("log"))
    out = os.path.join(RAW, "W1f_boot_power_%s.json" % stamp())
    with open(out, "w", encoding="utf-8") as f:
        json.dump(res, f, indent=1)
    return res


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--only", default="")
    ap.add_argument("--skip", default="")
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--natural", action="store_true")
    ap.add_argument("--boot", action="store_true")
    ap.add_argument("--frames", type=int, default=0)
    ap.add_argument("--tag", default="")
    args = ap.parse_args()
    if args.list:
        for s in S:
            print(s["name"], s["frames"], s["note"])
        return
    only = set(x for x in args.only.split(",") if x)
    skip = set(x for x in args.skip.split(",") if x)
    m, info = open_session()
    print("ROM", info["fileSha1"], info["fileSizeBytes"], flush=True)
    try:
        if args.boot:
            r = run_boot(m, info, frames=args.frames or 900)
            print("boot", r["frames"], "frames, ctl36", r["final"].get("control36Writes"), "nmi", r["final"].get("nmiExecs"), "hits", r["final"].get("hits"), "scene", hex(r["scene"] or 0), flush=True)
            return
        if args.natural:
            f = run_natural(m, info)
            print("natural", f["inputFrames"], "frames", f["seconds"], "s end scene", hex(f["endScene"]), flush=True)
            return
        for s in S:
            if only and s["name"] not in only:
                continue
            if s["name"] in skip:
                continue
            try:
                res = run_session(m, info, s, frames=args.frames, tag=args.tag)
                fin = res["final"]
                print("%-22s %6.1fs frames=%s ctl36=%s nmi=%s hits=%s endScene=%02X form=%s ac8=%s rows=%s" % (
                    s["name"], res["seconds"], res.get("frames"), fin.get("control36Writes"), fin.get("nmiExecs"), fin.get("hits"), fin.get("endScene", 0),
                    fin.get("endForm"), fin.get("endAc8"), [r["key"] for r in fin.get("bodyRows", [])][:6]), flush=True)
            except Exception as e:  # keep going: a failed session is reported, not hidden
                print("FAILED", s["name"], repr(e)[:400], flush=True)
    finally:
        m.close()


if __name__ == "__main__":
    main()
