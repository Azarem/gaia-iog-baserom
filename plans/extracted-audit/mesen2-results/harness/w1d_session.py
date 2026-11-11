#!/usr/bin/env python3
"""W1-d address census sessions (ROM O): batch "$7F scratch" ($7F0000-$7F01FF, the per-slot fields $7F0010 / $7F0020, $7F0200-$7F09FF, $7F0B22/24, $7F0C00-02,
$7F0E00, $7F3000).

usage: w1d_session.py [--only name,name] [--skip name,name] [--list] [--natural] [--boot] [--frames N] [--tag TEXT] [--discover SCENE]

The session table of W1-a / W1-b is reused (states, seeded bots, direction patterns, timelines, quick warps, the recorded natural replay: imported from
w1a_session and w1b_session), the census is kit/lib/w1d_kit.lua (`w1d.startD`). Extra sessions of this batch (the "trial" rows):
  t_glide_s          S14g (scene $B5): Psycho Slider south through a glide trigger (LockPlayerForGlide stores the countdown in the player's statsPtr), then the melee bot
  t_reveal_<scene>   quick warp to a scene with a field_reveal_object source (a mystic ball or a wall walker), the engine's own death transition on that actor
                     (hit_stagger_controller route: $10 |= $0040, entry := onDeathCallback), then the bot (it pulls with L / R and walks into the pickup)
  t_fade_*           quick warps through the scenes that write the COLDATA triplet
  t_inv_scroll       inventory overlay opened during a scroll wave (the unsaved words of the inventory open path)
Every session: load a state, run the H1 validity test (load, advance_frame 120, check cpu.k / cpu.sp / scene), load the state again and run
the census. Result of each session: raw/W1d_<name>_<date>.json (census rows, controls, H1 record, the Lua text). w1d_merge.py merges them.
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


def add(name, state, frames, note, **kw):
    S.append(dict(name=name, state=state, frames=frames, note=note, **kw))


# ---- trial sessions ----
S14G = st("orig_S14g_scB5-glide.mss")
SLIDE_S = "local function slideS(n)\n  local s = { {2, {'down'}}, {3, {}}, {8, {'down'}}, {2, {'down', 'b'}}, {90, {'down'}} }\n  local k = n - 2\n  if k < 0 then return nil end\n  for _, seg in ipairs(s) do\n    if k < seg[1] then local t = {} for _, b in ipairs(seg[2]) do t[b] = true end return t end\n    k = k - seg[1]\n  end\n  return nil\nend\n"
add("t_glide_s", S14G, 900, "S14g ($B5): player placed at (112, 154), Psycho Slider ability poked, slide south through the South trigger at frame 3-108, then the melee bot",
    drive="bot", bot=dict(MELEE, seed=44), head=SLIDE_S, input_fn="slideS", pokes=[(0x0AA2, 0x03, 2)],
    ats=[(2, "kit.w16(0x1014, 112); kit.w16(0x1016, 154); kit.w16(0x09B2, 0); kit.w16(0x09B4, 0); kit.w16(0x09C6, 0); kit.w16(0x09AE, kit.r16(0x09AE) & ~0x1000)")],
    snaps=[(3, "before the slide"), (60, "mid slide"), (112, "after the glide"), (300, "+300"), (890, "end")])

KILL_PICK = "function(s, cb) return cb ~= 0 end"


def reveal_trial(name, scene, note, nkill=1, pick=KILL_PICK, frames=1500, kill_at=400):
    ats = [(kill_at, "killed1, killedList = w1d.kill(%d, %s)" % (nkill, pick))]
    snaps = [(kill_at - 20, "arrived"), (kill_at + 2, "kill requested"), (kill_at + 120, "+120 after kill"), (kill_at + 400, "+400 after kill"), (frames - 20, "end")]
    add(name, S01R, frames, note, scene=scene, drive="bot", bot=dict(MELEE, seed=60 + scene % 40, pAct=70, act=["a", "b"], alt=["l", "r"]), pokes=[(0x0AA2, 0x77, 2)],
        ats=ats, snaps=snaps)


reveal_trial("t_reveal_CE", 0xCE, "Pyramid $CE (mystic balls, tier 3 DEF): kill one actor with an onDeathCallback at frame 400 (the callback calls field_reveal_object when enemies remain)")
reveal_trial("t_reveal_CC", 0xCC, "Pyramid $CC (mystic ball, tier 3 DEF): same trial")
reveal_trial("t_reveal_B3", 0xB3, "Angkor $B3 (wall walkers, tier 1 HP): same trial")
reveal_trial("t_reveal_B1", 0xB1, "Angkor $B1 (wall walkers, tier 2 STR): same trial")

# the kills that reach the other users of field_reveal_object and of the enemy stats pointer: EnemyDefeatDispatch (fire bugs of $82 end their callback with it) and
# StandardEnemyDefeatHandler (enemies without an onDeathCallback: entry := $DB8A, bank $80)
def kill_trial(name, scene, note, nkill, pick, later=2, frames=1500):
    ats = [(400, "killed1, killedList = w1d.kill(%d, %s)" % (nkill, pick)), (800, "w1d.kill(%d, %s)" % (later, pick))]
    snaps = [(380, "arrived"), (402, "kill requested"), (560, "+160 after kill"), (800, "second wave"), (frames - 20, "end")]
    add(name, S01R, frames, note, scene=scene, drive="bot", bot=dict(MELEE, seed=70 + scene % 30, pAct=70, act=["a", "b"], alt=["l", "r"]), pokes=[(0x0AA2, 0x77, 2)], ats=ats, snaps=snaps)


kill_trial("t_kill_82", 0x82, "Great Wall $82 (32 enemies): kill 3 fire bugs (onDeathCallback $8B:8DB9, EnemyDefeatDispatch) at frame 400 and 2 at 800", 3, "function(s, cb) return cb == 0x8DB9 end")
kill_trial("t_kill_8A", 0x8A, "Great Wall $8A: kill sand fangers (EnemyDefeatDispatch via gw8A_sand_fanger) at frame 400 and 2 at 800", 3, "function(s, cb) return cb ~= 0 end")
kill_trial("t_kill_3F", 0x3F, "Diamond Mine $3F: kill 5 enemies without a callback (StandardEnemyDefeatHandler) at frame 400 and 2 at 800", 5, "function(s, cb) return cb == 0 end")

# fades: scenes writing the COLDATA triplet ($7F0C00-02): the crow crew deck $2C, the class dismissed ending $F0, the comet lair $E8 and Dark Gaia
FADE_CHAIN = [0x2C, 0xF0, 0xE8, 0xE5]
add("t_fade", S01R, 3100, "quick warps: gold ship deck $2C (crow crew), ending $F0, comet lair $E8, $E5: the COLDATA writers",
    scene=FADE_CHAIN[0], chain=[(2 + 700 * i, c) for i, c in enumerate(FADE_CHAIN) if i > 0], drive="bot", bot=TALK, snapEvery=350)

# inventory during a scroll wave: poke the scroll override words, open the overlay with Select at frame 120, close it with cancel, reopen
add("t_inv_scroll", S01R, 700, "South Cape: $06CA / $06CC / $0672-$0677 poked to nonzero values at frame 60, the inventory opens with Select (frame 120) and closes with B (frame 260)",
    drive="timeline", steps=[(119, []), (3, ["select"]), (60, []), (3, ["b"]), (60, []), (3, ["select"]), (60, []), (3, ["b"]), (400, [])],
    ats=[(60, "kit.w16(0x06CA, 0x0012); kit.w16(0x06CC, 0x0034); kit.w8(0x0672, 0x11); kit.w8(0x0673, 0x22); kit.w8(0x0674, 0x33); kit.w8(0x0675, 0x44); kit.w8(0x0676, 0x55); kit.w8(0x0677, 0x66)")],
    snaps=[(59, "before poke"), (118, "poked"), (200, "overlay open"), (330, "closed"), (450, "reopened"), (690, "end")])


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
    if s.get("snapEvery"):
        for fr in range(s["snapEvery"], s["frames"], s["snapEvery"]):
            byframe.setdefault(fr, []).append("h.snap('every %d')" % fr)
    for fr, codes in byframe.items():
        ats.append("[%d]=function() %s end" % (fr, "; ".join(codes)))
    head, extra = s.get("head", ""), ""
    drive = s["drive"]
    if drive == "pattern":
        head += A.DIR_PATTERN % ()
        extra = "input=pattern, "
    elif drive == "bot":
        extra = "bot=%s, " % A.bot_lua(s["bot"])
        if s.get("input_fn"):
            extra += "input=%s, " % s["input_fn"]
    elif drive == "timeline":
        steps = ",".join("{n=%d,b={%s}}" % (n, ",".join(json.dumps(b) for b in bl)) for n, bl in s["steps"])
        extra = "timeline={start=1,loop=false,steps={%s}}, " % steps
    at = "at={" + ",".join(ats) + "}, " if ats else ""
    return (head + "local h = w1d.startD{logCap=60}\n" +
            "acen.run{frames=%d, writes=false, reads=false, refill=10, %s%s" % (s["frames"], extra, at) +
            "final=function() local r = h.rows(); r.endScene = kit.r16(0x0644); r.endHp = kit.r16(0x0ACE); "
            "r.endFlags = kit.r16(0x09AE); r.endAbil = kit.r16(0x0AA2); r.killed1 = killed1; r.killedList = killedList; return r end}")


def check_ats(s):
    """Two entries of the same frame in `chain` / `scene` would give a duplicate table key in Lua (the later one wins silently)."""
    seen = {}
    if s.get("scene") is not None:
        seen[2] = 1
    for fr, _ in s.get("chain", []):
        seen[fr] = seen.get(fr, 0) + 1
    dup = [fr for fr, n in seen.items() if n > 1]
    if dup:
        raise RuntimeError("duplicate chain frames %s in %s" % (dup, s["name"]))
    # the scene warp at frame 2 and an `ats` entry at frame 2 share a key: `ats` entries are merged by lua_for only among themselves
    if s.get("scene") is not None and any(fr == 2 for fr, _ in s.get("ats", [])):
        raise RuntimeError("scene warp and ats collide at frame 2 in %s" % s["name"])


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
    code = "killed1 = nil\n" + lua_for(s)
    r = m.run_script_checked(code, ok_stop=("script_done",), name="w1d_run", includes=["gaia_kit", "a_census", "a_actors", "w1d_kit"], frames=s["frames"] + 20,
                             turbo=True, timeoutMs=2400000)
    res = r["result"]
    res["session"] = {k: v for k, v in s.items() if k not in ("bot", "steps")}
    res["h1"] = rec
    res["rom"] = info
    res["lua"] = code
    res["warnings"] = r.get("__warnings__", [])
    res["log"] = r.get("log")
    res["seconds"] = round(time.time() - t, 1)
    out = os.path.join(RAW, "W1d_%s%s_%s.json" % (s["name"], tag, stamp()))
    with open(out, "w", encoding="utf-8") as f:
        json.dump(res, f, indent=1)
    return res


DISCOVER = r"""
local n = 0
kit.onFrame(function()
  n = n + 1
  if n == 2 then kit.w16(0x0642, SCENE) end
  if n == 330 then
    local rows = {}
    for _, s in ipairs(aact.live()) do
      rows[#rows + 1] = string.format("%04X ent=%02X:%04X sp=%04X ext=%04X cb=%04X:%02X hp=%04X f10=%04X", s, kit.r8(s + 2), kit.r16(s), kit.r16(0x10020 + s), kit.r16(0x1002A + s),
                                       kit.r16(0x11004 + s), kit.r8(0x11006 + s), kit.r16(0x10026 + s), kit.r16(s + 0x10))
    end
    kit.finish({ scene = kit.r16(0x0644), left = kit.r16(0x0AEC), rows = rows, flag = kit.r8(0x0A00) })
  end
end)
"""


def discover(m, scene):
    m.call("load_state_file", path=S01R)
    r = m.run_script_checked(DISCOVER.replace("SCENE", str(scene)), ok_stop=("script_done",), name="w1d_disc", includes=["gaia_kit", "a_actors"], frames=340, turbo=True,
                             timeoutMs=600000)["result"]
    print("scene %02X enemiesRemaining=%d" % (r["scene"], r["left"]))
    for row in r["rows"]:
        print(" ", row)


ANGLE = r"""
local n, seen, zero = 0, {}, {}
kit.onFrame(function()
  n = n + 1
  if n == 2 then kit.w16(0x0642, SCENE) end
  if n > 330 then
    for _, s in ipairs(aact.live()) do
      local cb = kit.r16(0x11004 + s)
      if cb ~= 0 then
        local a = kit.r16(0x10010 + s)
        local k = string.format("%04X cb=%04X", s, cb)
        seen[k] = seen[k] or {}
        local v = string.format("%04X", a)
        seen[k][v] = (seen[k][v] or 0) + 1
      end
    end
  end
  if n == 1330 then
    local out = {}
    for k, t in pairs(seen) do
      local vs = {}
      for v, c in pairs(t) do vs[#vs + 1] = v .. ":" .. c end
      table.sort(vs)
      out[#out + 1] = k .. " -> " .. table.concat(vs, " ", 1, math.min(#vs, 14)) .. (#vs > 14 and (" ... (" .. #vs .. " values)") or "")
    end
    table.sort(out)
    kit.finish({ rows = out })
  end
end)
"""


def probe_angle(m, scene):
    m.call("load_state_file", path=S01R)
    r = m.run_script_checked(ANGLE.replace("SCENE", str(scene)), ok_stop=("script_done",), name="w1d_ang", includes=["gaia_kit", "a_actors"], frames=1340, turbo=True,
                             timeoutMs=600000)["result"]
    print("scene %02X: orbitAngle word ($7F0010,X) of the actors with an onDeathCallback, frames 331-1330" % scene)
    for row in r["rows"]:
        print(" ", row)


def run_natural(m, info):
    t = time.time()
    N = A.NATURAL
    rec = A.h1(m, N["state"])
    if not rec["ok"]:
        raise RuntimeError("H1 failed %s" % rec)
    m.call("load_state_file", path=N["state"])
    with open(N["input"], encoding="utf-8") as f:
        doc = json.load(f)
    lua = ("local h = w1d.startD{logCap=60}\nlocal pub = false\n"
           "kit.onFrame(function() if h.frames >= 20050 and not pub then pub = true; emu.mcp.result(h.rows()) end end)\n")
    m.call("load_script", name="w1d_nat", code=lua, includes=["gaia_kit", "a_census", "a_actors", "w1d_kit"])
    total = 0
    for part in A.chunk_sequence(doc["segments"]):
        m.call("play_input", sequence=part, turbo=True, thenPause=True)
        total += sum(p["frames"] for p in part)
        print("  natural: %d frames" % total, flush=True)
    m.call("advance_frame", frames=70, turbo=True)
    res = m.call("get_script_result", name="w1d_nat")
    res = res.get("result", res) if isinstance(res, dict) else res
    out_png = m.shot("W1d_natural_end")
    m.call("unload_script", name="w1d_nat")
    final = dict(census=res, h1=rec, rom=info, lua=lua, inputFile=os.path.basename(N["input"]), inputFrames=total, seconds=round(time.time() - t, 1),
                 screenshot=out_png, endScene=m.u16(0x0644))
    out = os.path.join(RAW, "W1d_%s_%s.json" % (N["name"], stamp()))
    with open(out, "w", encoding="utf-8") as f:
        json.dump(final, f, indent=1)
    return final


def run_boot(m, info):
    """Cold boot census (fromReset power, 720 frames): the boot-time writers (wram-init, the boot DMA fill)."""
    t = time.time()
    code = ("local h = w1d.startD{logCap=60}\n"
            "kit.onFrame(function() if h.frames >= 700 then local r = h.rows(); r.endScene = kit.r16(0x0644); kit.finish(r) end end)")
    r = m.run_script_checked(code, ok_stop=("script_done",), name="w1d_run", includes=["gaia_kit", "w1d_kit"], frames=720, turbo=True,
                             timeoutMs=1800000, fromReset="power")
    res = dict(session=dict(name="boot_power", frames=700, note="cold boot (fromReset power), 700 frames"), final=r["result"], rom=info, lua=code,
               h1=dict(state="(cold boot, no state)", ok=True, k=0x80, sp=0x1FF, scene=r["result"].get("endScene"), expectScene=None),
               frames=r["result"].get("frames"), scene=r["result"].get("endScene"), seconds=round(time.time() - t, 1), log=r.get("log"))
    out = os.path.join(RAW, "W1d_boot_power_%s.json" % stamp())
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
    ap.add_argument("--discover", default="")
    ap.add_argument("--angle", default="")
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
        if args.discover:
            for sc in args.discover.split(","):
                discover(m, int(sc, 16))
            return
        if args.angle:
            for sc in args.angle.split(","):
                probe_angle(m, int(sc, 16))
            return
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
                res = run_session(m, info, s, frames=args.frames, tag=args.tag)
                fin = res.get("final") or {}
                print("%-22s %6.1fs frames=%s ctl36=%s nmi=%s hits=%s endScene=%02X" % (
                    s["name"], res["seconds"], res.get("frames"), fin.get("control36Writes"), fin.get("nmiExecs"), fin.get("hits"), fin.get("endScene", 0)), flush=True)
            except Exception as e:  # keep going: a failed session is reported, not hidden
                print("FAILED", s["name"], repr(e)[:400], flush=True)
    finally:
        m.close()


if __name__ == "__main__":
    main()
