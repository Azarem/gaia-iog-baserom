#!/usr/bin/env python3
"""W1-e address census sessions (ROM O): batch "unknown readers" ($0B14, $0648/$0649, $090E-$0911, $09BA-$09C5, $0200-$02FF).

usage: w1e_session.py [--only name,name] [--skip name,name] [--list] [--natural] [--boot] [--frames N] [--tag TEXT]

The session table of W1-a / W1-b is reused (states, seeded bots, direction patterns, timelines, quick warps, the recorded natural replay: imported from
w1a_session and w1b_session); the census is kit/lib/w1e_kit.lua (`w1e.startE`: the w1d census engine plus the decompressor / depth-sort ordering probe).
Extra sessions of this batch: see the `add(...)` calls below (the rows after the shared table).
Every session: load a state, run the H1 validity test (load, advance_frame 120, check cpu.k / cpu.sp / scene), load the state again and run the census.
Result of each session: raw/W1e_<name>_<date>.json (census rows, ordering probe, controls, H1 record, the Lua text). w1e_report.py merges them.
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
INCLUDES = ["gaia_kit", "a_census", "a_actors", "w1d_kit", "w1e_kit"]


def add(name, state, frames, note, **kw):
    S.append(dict(name=name, state=state, frames=frames, note=note, **kw))


# ---- extra sessions of batch e ----
# the Decompress COP (COP #51) users: credits $F7 is in warp_credits; the other three are cutscene actors of the angel tunnel, the Babel elevator and the Mu vampire lair
add("e_av74", S01R, 1500, "quick warp to the angel tunnel room $74 (av74_kara: two COP #51 Decompress calls), talk bot", scene=0x74, drive="bot", bot=TALK)
add("e_btE1", S01R, 1500, "quick warp to the Babel elevator $E1 (btE1_comet_soon: two COP #51 Decompress calls), talk bot", scene=0xE1, drive="bot", bot=TALK)
add("e_mu67", S01R, 1500, "quick warp to the Mu vampire lair $67 (mu67_neil_lily: two COP #51 Decompress calls), talk bot", scene=0x67, drive="bot", bot=TALK)
# the world map options menu: B cancels the choice (ReadMenuSelection writes $090E / $0910)
add("e_worldmap", S01R, 1800, "quick warp to the world map $FE, seeded bot with a and b (the options dialogue and its cancel)", scene=0xFE, drive="bot",
    bot=dict(seed=71, pAct=70, act=["a", "b"], pressLens=[3, 3, 10]))

# more B-cancels of the dialogue choice menu (ReadMenuSelection writes $090E / $0910 once per cancel): the castle-gate state with three more bot seeds
for i, sd in enumerate((101, 202, 303)):
    add("e_n03_s%d" % (i + 1), A.S[[x["name"] for x in A.S].index("n03_bot")]["state"], 4000, "natural state N03 (castle gate), a/b bot, seed %d" % sd, drive="bot",
        bot=dict(A.BASE_BOT, seed=sd) if hasattr(A, "BASE_BOT") else dict(seed=sd, pAct=70, act=["a", "b"], pressLens=[3, 3, 10]))


# sessions that watch the whole $0200-$02FF page; every other session watches $0200-$021F only (speed: the depth sort reads the page 256 times per frame)
FULL0200 = {"sc_bot", "menu_inventory", "chest_1D", "e_av74", "e_btE1", "e_mu67", "warp_credits"}


DM_EXTRA = 'extra={{name="09EC-09ED",lo=0x09EC,hi=0x09ED,ctx=true}}'
# the displayModeFlags run (OQ-I024-3, second half): the menu and dialogue sessions with an extra watch on $09EC-$09ED
DM_SET = ["sc_bot", "n01_bot", "n03_bot", "n02_bot", "menu_inventory", "menu_diary", "chest_1D", "e_worldmap", "e_av74", "warp_credits", "p03_29"]


def lua_for(s, dm=False):
    ats = []
    if s.get("scene") is not None:
        ats.append("[2]=function() kit.w16(0x0642, %d) end" % s["scene"])
    for fr, sc in s.get("chain", []):
        ats.append("[%d]=function() kit.w16(0x0642, %d) end" % (fr, sc))
    head, extra = "", ""
    drive = s["drive"]
    if drive == "pattern":
        head += A.DIR_PATTERN % ()
        extra = "input=pattern, "
    elif drive == "bot":
        extra = "bot=%s, " % A.bot_lua(s["bot"])
    elif drive == "timeline":
        steps = ",".join("{n=%d,b={%s}}" % (n, ",".join(json.dumps(b) for b in bl)) for n, bl in s["steps"])
        extra = "timeline={start=1,loop=false,steps={%s}}, " % steps
    at = "at={" + ",".join(ats) + "}, " if ats else ""
    xe = ""
    if s.get("extraExec"):
        xe = ", extraExec={" + ",".join("%s=%d" % (k, v) for k, v in s["extraExec"].items()) + "}"
    win = xe + ("" if s["name"] in FULL0200 else ", win0200=true") + (", " + DM_EXTRA if dm else "")
    return (head + "local h = w1e.startE{logCap=60%s}\n" % win +
            "acen.run{frames=%d, writes=false, reads=false, refill=10, %s%s" % (s["frames"], extra, at) +
            "final=function() local r = h.rowsE(); r.endScene = kit.r16(0x0644); r.endHp = kit.r16(0x0ACE); "
            "r.endFlags = kit.r16(0x09AE); r.endAbil = kit.r16(0x0AA2); return r end}")


def check_ats(s):
    seen = {}
    if s.get("scene") is not None:
        seen[2] = 1
    for fr, _ in s.get("chain", []):
        seen[fr] = seen.get(fr, 0) + 1
    dup = [fr for fr, n in seen.items() if n > 1]
    if dup:
        raise RuntimeError("duplicate chain frames %s in %s" % (dup, s["name"]))


def run_session(m, info, s, frames=None, tag="", dm=False):
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
    code = lua_for(s, dm)
    r = m.run_script_checked(code, ok_stop=("script_done",), name="w1e_run", includes=INCLUDES, frames=s["frames"] + 20, turbo=True, timeoutMs=2400000)
    res = r["result"]
    res["session"] = {k: v for k, v in s.items() if k not in ("bot", "steps")}
    res["h1"] = rec
    res["rom"] = info
    res["lua"] = code
    res["warnings"] = r.get("__warnings__", [])
    res["log"] = r.get("log")
    res["seconds"] = round(time.time() - t, 1)
    out = os.path.join(RAW, "W1e_%s%s_%s.json" % (s["name"], tag, stamp()))
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
    lua = ("local h = w1e.startE{logCap=60, win0200=true}\nlocal pub = false\n"
           "kit.onFrame(function() if h.frames >= 20050 and not pub then pub = true; emu.mcp.result(h.rowsE()) end end)\n")
    m.call("load_script", name="w1e_nat", code=lua, includes=INCLUDES)
    total = 0
    for part in A.chunk_sequence(doc["segments"]):
        m.call("play_input", sequence=part, turbo=True, thenPause=True)
        total += sum(p["frames"] for p in part)
        print("  natural: %d frames" % total, flush=True)
    m.call("advance_frame", frames=70, turbo=True)
    res = m.call("get_script_result", name="w1e_nat")
    res = res.get("result", res) if isinstance(res, dict) else res
    out_png = m.shot("W1e_natural_end")
    m.call("unload_script", name="w1e_nat")
    final = dict(census=res, h1=rec, rom=info, lua=lua, inputFile=os.path.basename(N["input"]), inputFrames=total, seconds=round(time.time() - t, 1),
                 screenshot=out_png, endScene=m.u16(0x0644))
    out = os.path.join(RAW, "W1e_%s_%s.json" % (N["name"], stamp()))
    with open(out, "w", encoding="utf-8") as f:
        json.dump(final, f, indent=1)
    return final


def run_boot(m, info, frames=900):
    """Cold boot census (fromReset power): the boot-time writers (wram-init table loop) and the first scene transitions (boot logo $FB to title $FC)."""
    t = time.time()
    code = ("local h = w1e.startE{logCap=60}\n"
            "kit.onFrame(function() if h.frames >= %d then local r = h.rowsE(); r.endScene = kit.r16(0x0644); kit.finish(r) end end)" % frames)
    r = m.run_script_checked(code, ok_stop=("script_done",), name="w1e_run", includes=["gaia_kit", "w1d_kit", "w1e_kit"], frames=frames + 20, turbo=True,
                             timeoutMs=1800000, fromReset="power")
    res = dict(session=dict(name="boot_power", frames=frames, note="cold boot (fromReset power), %d frames" % frames), final=r["result"], rom=info, lua=code,
               h1=dict(state="(cold boot, no state)", ok=True, k=0x80, sp=0x1FF, scene=r["result"].get("endScene"), expectScene=None),
               frames=r["result"].get("frames"), scene=r["result"].get("endScene"), seconds=round(time.time() - t, 1), log=r.get("log"))
    out = os.path.join(RAW, "W1e_boot_power_%s.json" % stamp())
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
    ap.add_argument("--dm", action="store_true", help="the displayModeFlags run: DM_SET sessions with an extra $09EC-$09ED watch (files tagged _dm)")
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
            if args.dm and s["name"] not in DM_SET:
                continue
            if s["name"] in skip:
                continue
            try:
                res = run_session(m, info, s, frames=args.frames, tag=args.tag + ("_dm" if args.dm else ""), dm=args.dm)
                fin = res["final"]
                print("%-22s %6.1fs frames=%s ctl36=%s nmi=%s hits=%s endScene=%02X dirtyBuilds=%s" % (
                    s["name"], res["seconds"], res.get("frames"), fin.get("control36Writes"), fin.get("nmiExecs"), fin.get("hits"), fin.get("endScene", 0),
                    (fin.get("order") or {}).get("dirtyBuilds")), flush=True)
            except Exception as e:  # keep going: a failed session is reported, not hidden
                print("FAILED", s["name"], repr(e)[:400], flush=True)
    finally:
        m.close()


if __name__ == "__main__":
    main()
