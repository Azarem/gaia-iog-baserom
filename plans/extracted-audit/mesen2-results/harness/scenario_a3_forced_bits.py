#!/usr/bin/env python3
"""A3 (forced-bit experiments) and the A2 `$0200` confirmation: actor Flags10 / Flags12, ROM O.

usage: scenario_a3_forced_bits.py [--only name,name]

Every experiment is a pair (forced, control) of identical atomic run_script runs from the same state: the control
leaves the bit alone. The inputs are deterministic (seeded bot until the timeline starts), so a difference between
the two runs is the effect of the forced write. Bits are forced with Lua memory writes into the actor slot
($1000-$1FBF, never low direct page). Per-frame samples and a screenshot of the end state go to raw/.
"""
import argparse
import json
import os
import time

from a_common import (ROM_O, RAW, S01R, open_session, stamp)
from scenario_a1_flag_census import BASE_BOT, bot_lua, hold, timeline_lua, tp

PLAYER = 0x1000
SCN_MINE = 0x3F


def bot_lua_part(bot):
    return f"bot={bot_lua(bot)}, " if bot else ""


def lua_run(frames, at, timeline, sample_fmt, sample_args, bot=BASE_BOT, every=1):
    ats = ",".join(f"[{fr}]=function() {code} end" for fr, code in at.items())
    tl = timeline_lua(timeline) if timeline else ""
    return (f"acen.run{{frames={frames}, writes=false, reads=false, {bot_lua_part(bot)}at={{{ats}}}, {tl}"
            f"sampleEvery={every}, sample=function(n) return string.format('{sample_fmt}', n, {sample_args}) end}}")


def player_sample(extra_fmt="", extra_args=""):
    return ("%d x=%d y=%d f10=%04X f12=%04X ent=%04X wt=%04X pf=%04X hp=%d" + extra_fmt,
            "kit.r16(0x1014), kit.r16(0x1016), kit.r16(0x1010), kit.r16(0x1012), kit.r16(0x1000), kit.r16(0x1008), kit.r16(0x09AE), kit.r16(0x0ACE)"
            + extra_args)


def setbit(slot, off, mask):
    return f"kit.w16({slot + off}, kit.r16({slot + off}) | {mask})"


def clrbit(slot, off, mask):
    return f"kit.w16({slot + off}, kit.r16({slot + off}) & {0xFFFF ^ mask})"


FIND_ENEMY = ("local ex, ey, es; for s = 0x1030, 0x1F90, 0x30 do "
              "if kit.r8(s + 2) == 0x8A and kit.r16(s) == 0xB10A then ex, ey, es = kit.r16(s + 0x14), kit.r16(s + 0x16), s; break end end; ")
TP_ENEMY = FIND_ENEMY + "SLOT = es; if ex then kit.w16(0x1014, ex); kit.w16(0x1016, ey + 6); kit.w16(0x09A2, ex - 8); kit.w16(0x09A4, ey - 10) end"


def experiments():
    ex = []
    # --- X1: OQ-I025-2 / OQ-I053-3 / OQ-I026-6 / OQ-I023-6: player $10 |= $2000 (South Cape) ---------------
    fmt, args = player_sample()
    for kind in ("control", "forced"):
        at = {10: setbit(PLAYER, 0x10, 0x2000)} if kind == "forced" else {}
        ex.append(dict(name=f"X1_player_2000_{kind}", state="S01R", frames=70, shot=True,
                       lua=lua_run(70, at, dict(start=40, steps=[hold(30, "left"), hold(30)]), fmt, args, bot=None)))
    at = {10: setbit(PLAYER, 0x10, 0x2000), 40: clrbit(PLAYER, 0x10, 0x2000)}
    ex.append(dict(name="X1_player_2000_set_then_clear", state="S01R", frames=90, shot=True,
                   lua=lua_run(90, at, dict(start=20, steps=[hold(30, "left"), hold(40)]), fmt, args, bot=None)))
    # --- X2: OQ-I026-6 / OQ-I026-5: NPC $10 |= $2000 (South Cape NPC slot $12D0 next to the player) ---------
    npc = 0x12D0
    fmt2 = "%d npc x=%d y=%d f10=%04X f12=%04X ent=%04X wt=%04X oam=%04X | pl x=%d y=%d"
    args2 = ("kit.r16(0x12E4), kit.r16(0x12E6), kit.r16(0x12E0), kit.r16(0x12E2), kit.r16(0x12D0), kit.r16(0x12D8), kit.r16(0x12DE), "
             "kit.r16(0x1014), kit.r16(0x1016)")
    for kind in ("control", "forced"):
        at = {4: tp(136, 340)}
        if kind == "forced":
            at[12] = setbit(npc, 0x10, 0x2000)
        ex.append(dict(name=f"X2_npc_2000_{kind}", state="S01R", frames=60, shot=True,
                       lua=lua_run(60, at, None, fmt2, args2, bot=None)))
    # --- X3: OQ-20: clear player $10 bit 3 ($0008) in the Diamond Mine, walk into walls ------------------
    for kind in ("control", "forced"):
        at = {2: "kit.w16(0x0642, 0x3F)"}
        if kind == "forced":
            at[346] = clrbit(PLAYER, 0x10, 0x0008)
        ex.append(dict(name=f"X3_player_0008_{kind}", state="S01R+abil", frames=346 + 200, shot=True,
                       lua=lua_run(346 + 200, at, dict(start=346, steps=[hold(50, "left"), hold(50, "down"), hold(60, "up"), hold(40, "right")]),
                                   fmt, args, every=5)))
    # --- X4: OQ-I023-3 / I027-2 / I030-2 / I032-5 / I036-4 / OQ-8: player $10 |= $0200, enemy touches Will ----
    fmt4 = "%d hp=%d pf=%04X f10=%04X f12=%04X ent=%04X pl x=%d y=%d | en slot=%X f10=%04X x=%d y=%d"
    args4 = ("kit.r16(0x0ACE), kit.r16(0x09AE), kit.r16(0x1010), kit.r16(0x1012), kit.r16(0x1000), kit.r16(0x1014), kit.r16(0x1016), "
             "SLOT or 0, SLOT and kit.r16(SLOT + 0x10) or 0, SLOT and kit.r16(SLOT + 0x14) or 0, SLOT and kit.r16(SLOT + 0x16) or 0")
    for kind in ("control", "forced"):
        at = {2: "kit.w16(0x0642, 0x3F)",
              345: TP_ENEMY, 385: TP_ENEMY, 425: TP_ENEMY}
        if kind == "forced":
            for fr in range(346, 346 + 120):
                at[fr] = setbit(PLAYER, 0x10, 0x0200)
        ex.append(dict(name=f"X4_player_0200_{kind}", state="S01R+abil", frames=346 + 120, shot=True,
                       lua="SLOT = nil; " + lua_run(346 + 120, at, dict(start=346, steps=[hold(120)]), fmt4, args4, every=4)))
    # --- X4c: the same, the bit is forced for frames 346-365 and cleared at 366, before the hit that the control takes at ~372 -----------
    at = {2: "kit.w16(0x0642, 0x3F)", 345: TP_ENEMY, 385: TP_ENEMY, 425: TP_ENEMY}
    for fr in range(346, 366):
        at[fr] = setbit(PLAYER, 0x10, 0x0200)
    at[366] = clrbit(PLAYER, 0x10, 0x0200)
    ex.append(dict(name="X4c_player_0200_cleared_at_366", state="S01R+abil", frames=346 + 120, shot=True,
                   lua="SLOT = nil; " + lua_run(346 + 120, at, dict(start=346, steps=[hold(120)]), fmt4, args4, every=4)))
    return ex


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--only", default="")
    args = ap.parse_args()
    only = [x for x in args.only.split(",") if x]
    m, info = open_session()
    print("ROM", info["fileSha1"], info["fileSizeBytes"])
    try:
        for e in experiments():
            if only and not any(e["name"].startswith(o) for o in only):
                continue
            m.call("load_state_file", path=S01R)
            if "abil" in e["state"]:
                m.poke(0x0AA2, 0x77)
                m.poke(0x0AA3, 0x77)
            t = time.time()
            r = m.call("run_script", code=e["lua"], name=f"a3_{e['name']}", includes=["a_census"], frames=e["frames"] + 20, turbo=True,
                       timeoutMs=300000)
            if r.get("stopReason") != "script_done":
                print("NOT FINISHED", e["name"], r.get("stopReason"), r.get("log"))
                continue
            res = r["result"]
            res["experiment"] = e["name"]
            res["screenshot"] = m.shot(f"A3_{e['name']}") if e.get("shot") else None
            res["rom"] = info
            res["state"] = e["state"]
            res["lua"] = e["lua"]
            out = os.path.join(RAW, f"A3_{e['name']}_{stamp()}.json")
            with open(out, "w", encoding="utf-8") as f:
                json.dump(res, f, indent=1)
            print(f"{e['name']:34s} {time.time()-t:5.1f}s samples={len(res.get('samples', []))} last={res['samples'][-1] if res.get('samples') else None}")
    finally:
        m.close()


if __name__ == "__main__":
    main()
