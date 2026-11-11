#!/usr/bin/env python3
"""W1-a address census sessions (ROM O): engine DP scratch watch list ($00AA/$00AB, $005E-$0062, $00DC, $0720-$0760).

usage: w1a_session.py [--only name,name] [--list]

Every session: load a state, run the H1 validity test (load, advance_frame 120, check cpu.k / cpu.sp / scene), load the state again and run
the W1-a census (kit/lib/w1a_kit.lua, `w1a.startA`) under a driver (a seeded bot, a direction pattern, a timeline, or a recorded input
file). Result of each session: raw/W1a_<name>_<date>.json (census rows, controls, H1 record, the Lua text). w1a_report.py merges them.
"""
import argparse
import json
import os
import sys
import time

from a_common import (ROM_O, RAW, STATE_DIR, S01R, open_session, stamp)

HERE = os.path.dirname(os.path.abspath(__file__))
RESULTS = os.path.dirname(HERE)


def st(name):
    return os.path.join(STATE_DIR, name)


BASE_BOT = dict(seed=11, pAct=60, act=["a", "b"], pressLens=[3, 3, 10])
MELEE = dict(seed=21, pAct=75, act=["b", "b", "a"], pressLens=[3, 3, 3, 60, 110], alt=["l", "r"])
TALK = dict(seed=5, pAct=60, act=["a"], pressLens=[3])

DIR_PATTERN = ("local PAT = { {'right'},{'down','right'},{'down'},{'down','left'},{'left'},{'up','left'},{'up'},{'up','right'} }\n"
               "local function pattern(n) local seg = ((n - 1) // 45) %% 8 + 1; local t = {} for _, b in ipairs(PAT[seg]) do t[b] = true end\n"
               "  if n %% 90 < 3 then t.b = true end return t end\n")


def bot_lua(b):
    def lst(v):
        return "{" + ",".join(json.dumps(x) for x in v) + "}"
    parts = [f"seed={b['seed']}", f"pAct={b['pAct']}"]
    for k in ("act", "dirs", "alt", "pressLens"):
        if k in b:
            parts.append(f"{k}={lst(b[k])}")
    return "{" + ",".join(parts) + "}"


# Sessions. state: state file; scene: quick warp ($0642) at frame 2; chain: [(frame, scene)] further warps; drive: bot | pattern | timeline;
# pokes: [(addr, value, size)] applied after the H1 test.
S = []


def add(name, state, frames, note, **kw):
    S.append(dict(name=name, state=state, frames=frames, note=note, **kw))


# P1: natural-ish play states and bots
add("sc_bot", S01R, 1800, "South Cape: seeded walk/talk/doors", drive="bot", bot=BASE_BOT)
add("n01_bot", st("orig_N01_sc_first_free.mss"), 1500, "natural state N01 (South Cape, first free control), bot", drive="bot", bot=BASE_BOT)
add("n02_bot", st("orig_N02_wills_house_after_feast.mss"), 900, "natural state N02 (Will's house), bot", drive="bot", bot=BASE_BOT)
add("n03_bot", st("orig_N03_castle_gate.mss"), 1500, "natural state N03 (castle gate), bot", drive="bot", bot=BASE_BOT)
for i, (fn, sc, fr) in enumerate([
        ("orig_P00_new_game_start.mss", "08", 900), ("orig_P01_after_castle_letter.mss", "0A", 900), ("orig_P02_before_incan_ruins.mss", "1C", 1200),
        ("orig_P03_before_castoth.mss", "29", 1500), ("orig_P04_before_diamond_mine.mss", "3E", 1200), ("orig_P05_before_sky_garden.mss", "58", 1200),
        ("orig_P06_before_viper.mss", "55", 1200), ("orig_P07_before_seaside_palace.mss", "5A", 1200), ("orig_P08_before_mu.mss", "60", 1200),
        ("orig_P09_before_vampires.mss", "67", 1200), ("orig_P10_before_great_wall.mss", "82", 1200), ("orig_P11_before_sand_fanger.mss", "8A", 1200),
        ("orig_P12_before_mt_kress.mss", "A0", 1200), ("orig_P13_before_angkor_wat.mss", "B0", 1200), ("orig_P14_before_pyramid.mss", "CD", 1200),
        ("orig_P15_before_mummy_queen.mss", "DD", 1500), ("orig_P16_before_babel_tower.mss", "DE", 1200), ("orig_P17_before_final_area.mss", "E7", 1200),
        ("orig_P18_before_dark_gaia.mss", "E8", 1200), ("orig_P18_before_dark_gaia_shadow.mss", "E8", 1200)]):
    nm = "p" + fn[len("orig_P"):len("orig_P") + 2] + ("s" if "shadow" in fn else "") + "_" + sc
    add(nm, st(fn), fr, f"preset state {fn} (scene ${sc}), melee bot", drive="bot", bot=dict(MELEE, seed=30 + i))

# P2: slope / ramp scenes, 8-direction pattern
for fn, nm, fr in [("orig_S13_slope-field.mss", "s13", 1500), ("orig_S14_ramp-scene.mss", "s14", 1500), ("orig_S14b_ir21-ns-ramps.mss", "s14b", 1200),
                   ("orig_S14c_ir22-booster.mss", "s14c", 900), ("orig_S14d_dm41-boosters.mss", "s14d", 900), ("orig_S14e_mu62-glide.mss", "s14e", 900),
                   ("orig_S14f_mtA1-ns-ramps.mss", "s14f", 1200), ("orig_S14g_scB5-glide.mss", "s14g", 900), ("orig_S14i_av72-statue-tunnel.mss", "s14i", 600)]:
    add("slope_" + nm, st(fn), fr, f"slope scene from {fn}: 8-direction pattern", drive="pattern")

# P3: dungeon with enemies, boss
add("mine_melee", S01R, 3000, "Diamond Mine main ($3F), Will, melee bot, abilities", scene=0x3F, drive="bot", bot=MELEE, pokes=[(0x0AA2, 0x77, 2)])
add("castoth_melee", S01R, 2400, "Castoth lair ($29), melee bot", scene=0x29, drive="bot", bot=dict(MELEE, seed=25), pokes=[(0x0AA2, 0x77, 2)])

# P4: menus, chests
add("menu_inventory", st("orig_S09_inventory.mss"), 900, "inventory overlay: move the cursor, close with cancel, reopen with Select", drive="timeline",
    steps=[(30, []), (3, ["right"]), (15, []), (3, ["down"]), (15, []), (3, ["right"]), (15, []), (3, ["down"]), (15, []), (3, ["a"]), (30, []),
           (3, ["y"]), (60, []), (6, ["select"]), (120, []), (3, ["left"]), (15, []), (3, ["up"]), (15, []), (3, ["y"]), (200, [])])
add("menu_diary", st("orig_S07_diary.mss"), 600, "diary menu: down / A / cancel", drive="timeline",
    steps=[(30, []), (3, ["down"]), (20, []), (3, ["a"]), (60, []), (3, ["a"]), (60, []), (3, ["y"]), (60, []), (3, ["down"]), (20, []), (3, ["a"]), (200, [])])
add("chest_0E", st("orig_C1_chest-0E.mss"), 700, "chest $0E (herb, no fanfare): walk to the chest and open it", drive="bot", bot=TALK)
add("chest_1D", st("orig_C1_chest-1D-fanfare.mss"), 900, "chest $1D (Larai Cliff, fanfare)", drive="bot", bot=TALK)

# P5: warps through the parallax / accumulator scenes (OQ-I035-3: snapshots of $0750-$0760 at the thinker entry)
CHAIN = [0x2B, 0xE5, 0x1D, 0x2B, 0xE5, 0x2D, 0x2E, 0xFD, 0x15, 0xE7, 0xE5]
add("warp_chain", S01R, 2 + 700 * len(CHAIN), "quick warp chain through the parallax scenes: " + " ".join(f"${c:02X}" for c in CHAIN), scene=CHAIN[0],
    chain=[(2 + 700 * i, c) for i, c in enumerate(CHAIN) if i > 0], drive="bot", bot=TALK, snapEvery=350)
add("warp_credits", S01R, 1400, "credits scene $F7", scene=0xF7, drive="bot", bot=TALK, snapEvery=350)
add("warp_misc", S01R, 600 * 6, "quick warps: church $08, hideout $02, Edward castle $0A, Itory $15, $1A, $1C", scene=0x08,
    chain=[(2 + 600 * i, c) for i, c in enumerate([0x02, 0x0A, 0x15, 0x1A, 0x1C], 1)], drive="bot", bot=TALK, snapEvery=300)

# P6: the recorded natural replay (title to N01 and beyond)
NATURAL = dict(name="natural_fr10", state=st("orig_S06_title.mss"), input=os.path.join(RAW, "FR10_early_game.input"), note="FR10 recorded input from the title screen")


def lua_for(s):
    ats = []
    if s.get("scene") is not None:
        ats.append(f"[2]=function() kit.w16(0x0642, {s['scene']}) end")
    for fr, sc in s.get("chain", []):
        ats.append(f"[{fr}]=function() kit.w16(0x0642, {sc}) end")
    if s.get("snapEvery"):
        pass
    head = ""
    drive = s["drive"]
    extra = ""
    if drive == "pattern":
        head += DIR_PATTERN % ()
        extra = "input=pattern, "
    elif drive == "bot":
        extra = f"bot={bot_lua(s['bot'])}, "
    elif drive == "timeline":
        steps = ",".join("{n=%d,b={%s}}" % (n, ",".join(json.dumps(b) for b in bl)) for n, bl in s["steps"])
        extra = "timeline={start=1,loop=false,steps={%s}}, " % steps
    snap = ""
    if s.get("snapEvery"):
        snap = (f"w1a.snapOnExec('thinkerEntry', 47245); w1a.snapOnExec('afterClear', 47248)\n"
                f"local SE = {s['snapEvery']}\n")
        ats.append("[1]=function() w1a.snap('start') end")
    tick = "tick=function(n) if n % SE == 0 then w1a.snap('n' .. n) end end, " if s.get("snapEvery") else ""
    at = "at={" + ",".join(ats) + "}, " if ats else ""
    return (head + "local h = w1a.startA{logCap=60}\n" + snap +
            f"acen.run{{frames={s['frames']}, writes=false, reads=false, refill=10, {extra}{at}{tick}"
            "final=function() local r = h.rows(); r.snaps = w1a.snaps; r.endScene = kit.r16(0x0644); r.endHp = kit.r16(0x0ACE); "
            "r.endFlags = kit.r16(0x09AE); r.endAbil = kit.r16(0x0AA2); r.end750 = {}; for a = 0x0750, 0x0760, 2 do r.end750[#r.end750 + 1] = kit.r16(a) end; return r end}")


def h1(m, path):
    rec = dict(state=os.path.basename(path), ok=False)
    r = m.call("load_state_file", path=path)
    rec["load"] = "ok"
    a = m.call("advance_frame", frames=120)
    cpu = a.get("cpu", {}) if isinstance(a, dict) else {}
    k = cpu.get("k", cpu.get("K"))
    sp = cpu.get("sp", cpu.get("SP"))
    rec["k"], rec["sp"] = k, sp
    rec["scene"] = m.u16(0x0644)
    meta = {}
    try:
        with open(path + ".json", encoding="utf-8") as f:
            meta = json.load(f).get("meta", {})
    except OSError:
        pass
    rec["expectScene"] = meta.get("scene")
    ok = k is not None and sp is not None and (0x80 <= k <= 0xCF) and (0x100 <= sp <= 0x1FF)
    if rec["expectScene"] is not None and rec["scene"] != rec["expectScene"]:
        # the scene may change inside 120 frames when the state was saved at a scene transition: report it, do not fail on it
        rec["sceneNote"] = "scene after 120 frames differs from the sidecar scene"
    rec["ok"] = bool(ok)
    return rec


def run_session(m, info, s):
    t = time.time()
    rec = h1(m, s["state"])
    if not rec["ok"]:
        raise RuntimeError(f"H1 failed {rec}")
    m.call("load_state_file", path=s["state"])
    for addr, val, size in s.get("pokes", []):
        m.poke(addr, val)
    code = lua_for(s)
    r = m.run_script_checked(code, ok_stop=("script_done",), name="w1a_run", includes=["gaia_kit", "a_census", "w1a_kit"], frames=s["frames"] + 20,
                             turbo=True, timeoutMs=900000)
    res = r["result"]
    res["session"] = {k: v for k, v in s.items() if k not in ("bot", "steps")}
    res["h1"] = rec
    res["rom"] = info
    res["lua"] = code
    res["warnings"] = r.get("__warnings__", [])
    res["log"] = r.get("log")
    res["seconds"] = round(time.time() - t, 1)
    out = os.path.join(RAW, f"W1a_{s['name']}_{stamp()}.json")
    with open(out, "w", encoding="utf-8") as f:
        json.dump(res, f, indent=1)
    return res


def chunk_sequence(segments, max_frames=500, max_segments=150):
    """Chunks of at most max_frames frames (a play_input call that runs longer than the server's call timeout is cut)."""
    cur, frames = [], 0
    for sg in segments:
        cur.append(dict(frames=sg["frames"], buttons=sg.get("ports", {}).get("0", [])))
        frames += sg["frames"]
        if frames >= max_frames or len(cur) >= max_segments:
            yield cur
            cur, frames = [], 0
    if cur:
        yield cur


def run_natural(m, info):
    t = time.time()
    rec = h1(m, NATURAL["state"])
    if not rec["ok"]:
        raise RuntimeError(f"H1 failed {rec}")
    m.call("load_state_file", path=NATURAL["state"])
    with open(NATURAL["input"], encoding="utf-8") as f:
        doc = json.load(f)
    segs = doc["segments"]
    lua = ("local h = w1a.startA{logCap=60, publishEvery=120, kinds={ ['62-64'] = {'write'} }}\n"
           "kit.onFrame(function() end)\n")
    m.call("load_script", name="w1a_nat", code=lua, includes=["gaia_kit", "a_census", "w1a_kit"])
    total = 0
    for part in chunk_sequence(segs):
        m.call("play_input", sequence=part, turbo=True, thenPause=True)
        total += sum(p["frames"] for p in part)
        print(f"  natural: {total} frames", flush=True)
    m.call("advance_frame", frames=70, turbo=True)
    res = m.call("get_script_result", name="w1a_nat")
    res = res.get("result", res) if isinstance(res, dict) else res
    out_png = m.shot("W1a_natural_end")
    m.call("unload_script", name="w1a_nat")
    final = dict(census=res, h1=rec, rom=info, lua=lua, inputFile=os.path.basename(NATURAL["input"]), inputFrames=total, seconds=round(time.time() - t, 1),
                 screenshot=out_png, endScene=m.u16(0x0644))
    out = os.path.join(RAW, f"W1a_{NATURAL['name']}_{stamp()}.json")
    with open(out, "w", encoding="utf-8") as f:
        json.dump(final, f, indent=1)
    return final


def run_boot(m, info):
    """Cold boot census: power reset, 720 frames (title screen reached). Covers the boot-time writers of the watched bytes."""
    t = time.time()
    code = ("local h = w1a.startA{logCap=60}\n"
            "kit.onFrame(function() if h.frames >= 700 then local r = h.rows(); r.endScene = kit.r16(0x0644); kit.finish(r) end end)")
    r = m.run_script_checked(code, ok_stop=("script_done",), name="w1a_run", includes=["gaia_kit", "w1a_kit"], frames=720, turbo=True,
                             timeoutMs=900000, fromReset="power")
    res = dict(session=dict(name="boot_power", frames=700, note="cold boot (fromReset power), 700 frames"), final=r["result"], rom=info, lua=code,
               h1=dict(state="(cold boot, no state)", ok=True, k=0x80, sp=0x1FF, scene=r["result"].get("endScene"), expectScene=None),
               frames=r["result"].get("frames"), scene=r["result"].get("endScene"), seconds=round(time.time() - t, 1), log=r.get("log"))
    out = os.path.join(RAW, f"W1a_boot_power_{stamp()}.json")
    with open(out, "w", encoding="utf-8") as f:
        json.dump(res, f, indent=1)
    return res


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--only", default="")
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--natural", action="store_true")
    ap.add_argument("--boot", action="store_true")
    args = ap.parse_args()
    if args.list:
        for s in S:
            print(s["name"], s["frames"], s["note"])
        return
    only = set(x for x in args.only.split(",") if x)
    m, info = open_session()
    print("ROM", info["fileSha1"], info["fileSizeBytes"], flush=True)
    try:
        if args.boot:
            r = run_boot(m, info)
            print("boot", r["frames"], "frames, ctl36", r["final"].get("control36Writes"), "nmi", r["final"].get("nmiExecs"), "hits", r["final"].get("hits"), "scene", hex(r["scene"] or 0), flush=True)
            return
        if args.natural:
            f = run_natural(m, info)
            print("natural", f["inputFrames"], "frames", f["seconds"], "s end scene", hex(f["endScene"]), flush=True)
            return
        for s in S:
            if only and s["name"] not in only:
                continue
            try:
                res = run_session(m, info, s)
                print(f"{s['name']:22s} {res['seconds']:6.1f}s frames={res.get('frames')} ctl36={res.get('control36Writes')} "
                      f"hits={res['final'].get('hits') if res.get('final') else None} endScene={res.get('scene', 0):02X}", flush=True)
            except Exception as e:  # keep going: a failed session is reported, not hidden
                print("FAILED", s["name"], repr(e)[:400], flush=True)
    finally:
        m.close()


if __name__ == "__main__":
    main()
