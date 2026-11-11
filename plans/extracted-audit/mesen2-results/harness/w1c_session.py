#!/usr/bin/env python3
"""W1-c address census sessions (ROM O): batch "Event/flag bytes" ($0A00 bit 0, $0A80-$0AA7, $0AEC/$0AEE).

usage: w1c_session.py [--only name,name] [--skip name,name] [--list] [--natural] [--boot]

The session table of W1-a / W1-b is reused (states, seeded bots, direction patterns, timelines, quick warps, the recorded natural replay: imported
from w1a_session and w1b_session), the census is kit/lib/w1c_kit.lua (`w1c.startC`). Extra sessions of this batch (the "trial" rows):
  warp_f0_will / warp_f0_shadow   quick warps through the 26 scenes whose scene_flag_init sets flag #00 (Will / Shadow form)
  t_kill                          kill enemies in $3F, leave to $3E, return, snapshot $0A80-$0AA7 and $0AEC/$0AEE at each step (OQ-67, OQ-I054-2)
  t_flag01                        poke flag #01 (bit 1 of $0A00) in South Cape, quick warp to Itory $15, snapshot (OQ-I042-7)
  t_gameover_*                    natural state N01 with the wramFlags block and flag bytes poked, HP 0 + game-over bit: does game_over_sequence clear them
Every session: load a state, run the H1 validity test (load, advance_frame 120, check cpu.k / cpu.sp / scene), load the state again and run
the census. Result of each session: raw/W1c_<name>_<date>.json (census rows, controls, H1 record, the Lua text). w1c_merge.py merges them.
"""
import argparse
import json
import os
import sys
import time

import w1a_session as A
import w1b_session as B   # registers the three W1-b extra sessions into A.S
from a_common import RAW, S01R, open_session, stamp

S = A.S
st = A.st
MELEE = A.MELEE
TALK = A.TALK

# the 26 scenes in which scene_flag_init (offset 50794) sets flag #00 on its first tick (plans/flags/inventory.json, scene list of that site)
FLAG00_SCENES = [21, 26, 29, 43, 44, 47, 48, 50, 67, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 109, 110, 111, 112, 113, 114, 120]
PER = 700


def add(name, state, frames, note, **kw):
    S.append(dict(name=name, state=state, frames=frames, note=note, **kw))


# one session per scene (a scene that blocks a quick warp, as $2F does after the first load, only costs its own session): Will form (f0_XX) and Shadow form (f0s_XX)
for _sc in FLAG00_SCENES:
    add("f0_%02X" % _sc, S01R, 460, "scene $%02X (flag-#00 scene), Will form, quick warp at frame 2" % _sc, scene=_sc, drive="bot", bot=TALK)
    add("f0s_%02X" % _sc, S01R, 460, "scene $%02X (flag-#00 scene), Shadow form ($0AD4 = 2 poked after the state load)" % _sc, scene=_sc, drive="bot", bot=TALK, pokes=[(0x0AD4, 2, 2)])

# kill / leave / return. The census bots (W1-a, W1-b and the first W1-c pass: ~90k frames, A taps, B holds, Y taps) never killed an enemy, so the trial kills
# by the engine's own route: CheckPlayerDeath-style entry point replacement. The victim's entry word ($00) is set to StandardEnemyDefeatHandler ($DB8A, offset
# 56202) and its bank byte ($02) to $80, exactly what hit_stagger_controller / combat_collision do when an enemy's HP reaches zero without onDeathCallback.
# The bot only taps A (no walking): a scene-title box makes ExecuteSceneTransition wait for a button press, an idle bot would block every later quick warp.
# Victims: live actors (aact.live) with a statsPtr ($7F0020,X) that is neither 0 nor the first enemy_stats_table entry ($AB70) and extendedFlags ($7F002A,X) bit $0080 clear.
KILL_HEAD = ("function killN(n)\n"
             "  local done, pl = 0, kit.r16(0x09AA)\n"
             "  for _, s in ipairs(aact.live()) do\n"
             "    if done >= n then break end\n"
             "    local sp, ext = kit.r16(0x10020 + s), kit.r16(0x1002A + s)\n"
             "    if s ~= pl and sp ~= 0 and sp ~= 0xAB70 and (ext & 0x80) == 0 then kit.w16(s, 0xDB8A); kit.w8(s + 2, 0x80); done = done + 1 end\n"
             "  end\n"
             "  return done\n"
             "end\n")


def kill_trial(name, scene, other, note, world=False, nkill=5):
    ats = [(380, "killed1 = killN(%d)" % nkill), (902, "kit.w16(0x0642, 0x%02X)" % other), (1302, "kit.w16(0x0642, 0x%02X)" % scene), (1720, "killed2 = killN(2)")]
    snaps = [(360, "arrived"), (382, "kill 1 requested"), (560, "after kill 1"), (900, "before leaving"), (1300, "other scene"), (1700, "returned"),
             (1722, "kill 2 requested"), (2000, "after kill 2")]
    if world:
        ats += [(2002, "kit.w16(0x0642, 0xFE)"), (2502, "kit.w16(0x0642, 0x%02X)" % scene)]
        snaps += [(2500, "world map"), (3000, "back from the world map")]
    add(name, S01R, 3100 if world else 2100, note, scene=scene, drive="bot", bot=dict(TALK, dirs=[]), pokes=[], head=KILL_HEAD, snaps=snaps, ats=ats)


kill_trial("t_kill_a", 0x3F, 0x3E, "Diamond Mine $3F (24 enemies): kill 5, leave to $3E, return, kill 2")
kill_trial("t_kill_b", 0x3E, 0x3F, "Diamond Mine $3E (7 enemies): kill 5, leave to $3F, return, kill 2", nkill=5)
kill_trial("t_kill_c", 0x1B, 0x1C, "Incan Ruins $1B (6 enemies): kill 5, leave to $1C, return, kill 1", nkill=5)
kill_trial("t_kill_d", 0x29, 0x28, "Castoth lair $29 (boss room): the boss bit is set on Castoth, kill is skipped (no victim): control of the filter", nkill=5)

# boss reward latch: boss_clear_reward_handler waits for playerFlags bit $0020 (boss defeated), then SetWramFlag_Offset100 sets wramFlags $0100 + boss number ($0AA0 bit 0 for Castoth).
# The boss is not fought: the bit is forced in the Castoth lair ($29) after the scene is up, which is the condition the handler tests.
add("t_boss_reward", S01R, 1700, "Castoth lair $29: playerFlags |= $0020 at frame 400 (boss-defeated latch), leave to $28 at 702 and return at 1102",
    scene=0x29, drive="bot", bot=dict(TALK, dirs=[]), pokes=[],
    ats=[(400, "kit.w16(0x09AE, kit.r16(0x09AE) | 0x0020)"), (702, "kit.w16(0x0642, 0x28)"), (1102, "kit.w16(0x0642, 0x29)")],
    snaps=[(380, "before the latch"), (420, "latch forced"), (600, "+200"), (700, "before leaving"), (1000, "$28"), (1500, "returned to $29")])

# world-map entry: wramFlags block ($0A80-$0A9F) and the bytes behind it ($0AA0-$0AA3) dirty, quick warp to $FE (WorldMapController runs ClearAllWramFlags)
add("t_wmclear", S01R, 900, "wramFlags $0A80-$0A9F = $FF, $0AA0 = $01, $0AA1 = $02, $0AA2 = $04 forced in South Cape, quick warp to the world map $FE",
    scene=None, drive="bot", bot=TALK, pokes=[],
    ats=[(5, "for a = 0x0A80, 0x0A9F do kit.w8(a, 0xFF) end; kit.w8(0x0AA0, 0x01); kit.w8(0x0AA1, 0x02); kit.w8(0x0AA2, 0x04)"), (10, "kit.w16(0x0642, 0xFE)")],
    snaps=[(4, "before"), (8, "forced"), (200, "world map +190"), (500, "world map +490"), (880, "end")])

# flag #01 set in South Cape, then quick warp to Itory ($15)
add("t_flag01", S01R, 700, "flag #01 forced in South Cape (bit 1 of $0A00), quick warp to Itory $15: is it cleared by the scene setup", scene=None, drive="bot",
    bot=TALK, pokes=[],
    ats=[(5, "kit.w8(0x0A00, kit.r8(0x0A00) | 0x02); kit.w8(0x0A00 + 1, kit.r8(0x0A01) | 0x01)"), (10, "kit.w16(0x0642, 0x15)")],
    snaps=[(4, "before poke"), (8, "flag #01 and #08 forced"), (60, "still in scene 1?"), (320, "Itory arrived"), (400, "Itory +80"), (690, "end")])

# game over with the wramFlags block dirty (natural state N01: the respawn records exist). gems = 0 -> real game over; gems >= 100 -> revive
for nm, gems in (("t_gameover_lt100", 0), ("t_gameover_ge100", 150)):
    add(nm, st("orig_N01_sc_first_free.mss"), 900, f"N01: wramFlags poked ($0A80 = $FF, $0A9F = $80, $0AA0 = $01), gems {gems}, playerHp 0 (CheckPlayerDeath starts the game over)",
        scene=None, drive="bot", bot=A.BASE_BOT, pokes=[],
        ats=[(5, "kit.w8(0x0A80, 0xFF); kit.w8(0x0A9F, 0x80); kit.w8(0x0AA0, 0x01); kit.w16(0x0AD6, %d); kit.w16(0x0ACE, 0)" % gems)],
        snaps=[(3, "before"), (8, "poked"), (200, "+200"), (500, "+500"), (880, "end")])


def lua_for(s):
    ats = []
    if s.get("scene") is not None:
        ats.append("[2]=function() kit.w16(0x0642, %d) end" % s["scene"])
    for fr, sc in s.get("chain", []):
        ats.append("[%d]=function() kit.w16(0x0642, %d) end" % (fr, sc))
    byframe = {}
    for fr, code in s.get("ats", []):
        byframe.setdefault(fr, []).append(code)
    for fr, label in s.get("snaps", []):
        byframe.setdefault(fr, []).append("h.snap(%s)" % json.dumps(label))
    for fr, codes in byframe.items():
        # merge with an existing warp entry at the same frame
        ats.append("[%d]=function() %s end" % (fr, "; ".join(codes)))
    head, extra = s.get("head", ""), ""
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
    return (head + "local h = w1c.startC{logCap=60}\n" +
            "acen.run{frames=%d, writes=false, reads=false, refill=10, %s%s" % (s["frames"], extra, at) +
            "final=function() local r = h.rows(); r.endScene = kit.r16(0x0644); r.endHp = kit.r16(0x0ACE); "
            "r.endFlags = kit.r16(0x09AE); r.endAbil = kit.r16(0x0AA2); return r end}")


def check_ats(s):
    """Two entries of the same frame in `ats` / `chain` / `scene` would give a duplicate table key in Lua (the later one wins silently)."""
    seen = {}
    if s.get("scene") is not None:
        seen[2] = 1
    for fr, _ in s.get("chain", []):
        seen[fr] = seen.get(fr, 0) + 1
    for fr in [x[0] for x in s.get("ats", [])] + [x[0] for x in s.get("snaps", [])]:
        pass
    dup = [fr for fr, n in seen.items() if n > 1]
    if dup:
        raise RuntimeError("duplicate chain frames %s in %s" % (dup, s["name"]))


def run_session(m, info, s):
    t = time.time()
    check_ats(s)
    rec = A.h1(m, s["state"])
    if not rec["ok"]:
        raise RuntimeError("H1 failed %s" % rec)
    m.call("load_state_file", path=s["state"])
    for addr, val, size in s.get("pokes", []):
        m.poke(addr, val)
    code = lua_for(s)
    r = m.run_script_checked(code, ok_stop=("script_done",), name="w1c_run", includes=["gaia_kit", "a_census", "a_actors", "w1c_kit"], frames=s["frames"] + 20,
                             turbo=True, timeoutMs=2400000)
    res = r["result"]
    res["session"] = {k: v for k, v in s.items() if k not in ("bot", "steps")}
    res["h1"] = rec
    res["rom"] = info
    res["lua"] = code
    res["warnings"] = r.get("__warnings__", [])
    res["log"] = r.get("log")
    res["seconds"] = round(time.time() - t, 1)
    out = os.path.join(RAW, "W1c_%s_%s.json" % (s["name"], stamp()))
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
    lua = ("local h = w1c.startC{logCap=60}\nlocal pub = false\n"
           "kit.onFrame(function() if h.frames >= 20050 and not pub then pub = true; emu.mcp.result(h.rows()) end end)\n")
    m.call("load_script", name="w1c_nat", code=lua, includes=["gaia_kit", "a_census", "w1c_kit"])
    total = 0
    for part in A.chunk_sequence(doc["segments"]):
        m.call("play_input", sequence=part, turbo=True, thenPause=True)
        total += sum(p["frames"] for p in part)
        print("  natural: %d frames" % total, flush=True)
    m.call("advance_frame", frames=70, turbo=True)
    res = m.call("get_script_result", name="w1c_nat")
    res = res.get("result", res) if isinstance(res, dict) else res
    out_png = m.shot("W1c_natural_end")
    m.call("unload_script", name="w1c_nat")
    final = dict(census=res, h1=rec, rom=info, lua=lua, inputFile=os.path.basename(N["input"]), inputFrames=total, seconds=round(time.time() - t, 1),
                 screenshot=out_png, endScene=m.u16(0x0644))
    out = os.path.join(RAW, "W1c_%s_%s.json" % (N["name"], stamp()))
    with open(out, "w", encoding="utf-8") as f:
        json.dump(final, f, indent=1)
    return final


def run_boot(m, info):
    """Cold boot census (fromReset power, 720 frames): the boot-time writers of the watched bytes (wram-init, the boot DMA fill)."""
    t = time.time()
    code = ("local h = w1c.startC{logCap=60}\n"
            "kit.onFrame(function() if h.frames >= 700 then local r = h.rows(); r.endScene = kit.r16(0x0644); kit.finish(r) end end)")
    r = m.run_script_checked(code, ok_stop=("script_done",), name="w1c_run", includes=["gaia_kit", "w1c_kit"], frames=720, turbo=True,
                             timeoutMs=1800000, fromReset="power")
    res = dict(session=dict(name="boot_power", frames=700, note="cold boot (fromReset power), 700 frames"), final=r["result"], rom=info, lua=code,
               h1=dict(state="(cold boot, no state)", ok=True, k=0x80, sp=0x1FF, scene=r["result"].get("endScene"), expectScene=None),
               frames=r["result"].get("frames"), scene=r["result"].get("endScene"), seconds=round(time.time() - t, 1), log=r.get("log"))
    out = os.path.join(RAW, "W1c_boot_power_%s.json" % stamp())
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
            r = run_boot(m, info)
            print("boot", r["frames"], "frames, ctl36", r["final"].get("control36Writes"), "nmi", r["final"].get("nmiExecs"), "hits", r["final"].get("hits"), flush=True)
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
                res = run_session(m, info, s)
                fin = res.get("final") or {}
                print("%-22s %6.1fs frames=%s ctl36=%s nmi=%s hits=%s endScene=%02X" % (
                    s["name"], res["seconds"], res.get("frames"), fin.get("control36Writes"), fin.get("nmiExecs"), fin.get("hits"), fin.get("endScene", 0)), flush=True)
            except Exception as e:  # keep going: a failed session is reported, not hidden
                print("FAILED", s["name"], repr(e)[:400], flush=True)
    finally:
        m.close()


if __name__ == "__main__":
    main()
