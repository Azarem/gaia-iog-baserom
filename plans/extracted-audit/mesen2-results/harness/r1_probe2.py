#!/usr/bin/env python3
"""R1 targeted probes (ROM O): attribute the few counter rows that need a name for the reader, and run the cases coverage cannot reach by chance.
usage: python r1_probe2.py [name ...]     (no name: all)  -> raw/R1_probe_<name>.json (result + the Lua verbatim)
Probes: thinker_overrun, north_probe, sparkle_read, drop_lowhp_s22, drop_lowhp_s6d, status_f0, status_f1, status_f2
"""
import json
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from a_common import open_session, STATE_DIR, RAW, S01R  # noqa: E402
import w1a_session as W  # noqa: E402

PRG = "emu.memType.snesPrgRom"

HDR = r"""
local PRG, WR, CPU = emu.memType.snesPrgRom, emu.memType.snesWorkRam, emu.cpuType.snes
local function stinfo()
  local st = emu.getState()
  return st, string.format("pc=%02X:%04X ps=%02X d=%04X sc=%02X n36=%d", st["cpu.k"], st["cpu.pc"], st["cpu.ps"], st["cpu.d"], kit.r16(0x0644) & 0xFF, kit.r16(0x36))
end
"""

THINKER = HDR + r"""
local hits, n = {}, {}
local function mk(tag) return function(addr, v)
  n[tag] = (n[tag] or 0) + 1
  if #hits < 60 then local _, s = stinfo(); hits[#hits + 1] = string.format("%s addr=%d v=%02X %s", tag, addr, v or -1, s) end
end end
emu.addMemoryCallback(mk("E8"), emu.callbackType.read, 846040, 846075, CPU, PRG)
emu.addMemoryCallback(mk("E9"), emu.callbackType.read, 846300, 846335, CPU, PRG)
emu.addMemoryCallback(mk("EA"), emu.callbackType.read, 846395, 846425, CPU, PRG)
local S = { nev = 0 }
e2.sweep({ scenes = {0x3E, 0x3F, 0x41, 0x42, 0x43, 0x44, 0x47, 0x68, 0x6A, 0x6B, 0x40, 0x4B, 0x4C, 0x04, 0x07}, post = 40, noBanner = {[254] = true, [255] = true},
  done = function(S2, per) kit.finish({ n = n, hits = hits, scenes = #per }) end }, S)
"""

NORTH = HDR + r"""
local pend, cnt, same, log = nil, { entry = 0, bra = 0, target = 0 }, { w00 = 0, sp = 0, mx = 0, d = 0, dbr = 0, all = 0 }, {}
local function snap()
  local st = emu.getState()
  return { w00 = emu.read16(st["cpu.d"], WR, false), sp = st["cpu.sp"], mx = st["cpu.ps"] & 0x30, d = st["cpu.d"], dbr = st["cpu.dbr"], a = st["cpu.a"], x = st["cpu.x"], y = st["cpu.y"], p = st["cpu.ps"] }
end
emu.addMemoryCallback(function() cnt.entry = cnt.entry + 1; pend = snap() end, emu.callbackType.exec, 184888, 184888, CPU, PRG)
emu.addMemoryCallback(function() cnt.bra = cnt.bra + 1; if pend then pend.bra = snap() end end, emu.callbackType.exec, 184894, 184894, CPU, PRG)
emu.addMemoryCallback(function()
  cnt.target = cnt.target + 1
  if pend and pend.bra then
    local t = snap()
    same.all = same.all + 1
    for _, k in ipairs({ "w00", "sp", "mx", "d", "dbr" }) do if t[k] == pend[k] then same[k] = same[k] + 1 end end
    if #log < 12 then
      log[#log + 1] = string.format("entry w00=%04X sp=%04X p=%02X a=%04X x=%04X y=%04X | bra a=%04X x=%04X p=%02X | target w00=%04X sp=%04X p=%02X a=%04X x=%04X d=%04X sc=%02X",
        pend.w00, pend.sp, pend.p, pend.a, pend.x, pend.y, pend.bra.a, pend.bra.x, pend.bra.p, t.w00, t.sp, t.p, t.a, t.x, t.d, kit.r16(0x0644) & 0xFF)
    end
    pend = nil
  end
end, emu.callbackType.exec, 184840, 184840, CPU, PRG)
-- the natural replay is played by play_input from Python; this script only observes and ends itself near the end of the replay
local f = 0
kit.onFrame(function() f = f + 1; if f >= 20060 then kit.finish({ cnt = cnt, same = same, log = log }) end end)
"""

SPARK_READ = r"""
local hits, n = {}, 0
emu.addMemoryCallback(function(addr, v)
  n = n + 1
  if #hits < 25 then local _, s = stinfo(); hits[#hits + 1] = string.format("addr=%d v=%02X %s", addr, v or -1, s) end
end, emu.callbackType.read, 56570, 56583, CPU, PRG)
acen.run{ frames = 2400, writes = false, reads = false, refill = 10, bot = @BOT@, final = function() return { n = n, hits = hits } end }
"""

DROP = r"""
local hist, spawn, heal, sparks, pos = {}, 0, 0, 0, {}
emu.addMemoryCallback(function()
  local st = emu.getState(); local a = st["cpu.a"] & 0xFF
  hist[a] = (hist[a] or 0) + 1
end, emu.callbackType.exec, 257943, 257943, CPU, PRG)
emu.addMemoryCallback(function() heal = heal + 1 end, emu.callbackType.exec, 57315, 57315, CPU, PRG)
emu.addMemoryCallback(function()
  spawn = spawn + 1
  local st = emu.getState(); local x = st["cpu.x"]
  if #pos < 8 then pos[#pos + 1] = string.format("GiveItem heal branch: slot X=%04X pickup(%d,%d) player(%d,%d) sc=%02X n36=%d", x, emu.read16(x + 0x14, WR, false), emu.read16(x + 0x16, WR, false), kit.r16(0x1014), kit.r16(0x1016), kit.r16(0x0644) & 0xFF, kit.r16(0x36)) end
end, emu.callbackType.exec, 258009, 258009, CPU, PRG)
emu.addMemoryCallback(function()
  sparks = sparks + 1
  local st = emu.getState(); local d = st["cpu.d"]
  if sparks <= 4 then pos[#pos + 1] = string.format("SpawnItemSparkleEffect entry: slot D=%04X child(%d,%d) player(%d,%d) flags10=%04X", d, emu.read16(d + 0x14, WR, false), emu.read16(d + 0x16, WR, false), kit.r16(0x1014), kit.r16(0x1016), emu.read16(d + 0x10, WR, false)) end
end, emu.callbackType.exec, 56579, 56579, CPU, PRG)
local h = {}
local saved, rolls = nil, 0
if @LOWROLL@ then
  emu.addMemoryCallback(function() rolls = rolls + 1; saved = kit.r16(0x0ACE); kit.w16(0x0ACE, 1) end, emu.callbackType.exec, 57211, 57211, CPU, PRG)
  emu.addMemoryCallback(function() if saved then kit.w16(0x0ACE, saved); saved = nil end end, emu.callbackType.exec, 57288, 57288, CPU, PRG)
end
acen.run{ frames = @FRAMES@, writes = false, reads = false, bot = @BOT@, refill = @REFILL@,
  tick = function(n) if @KEEPLOW@ then local hp = kit.r16(0x0ACE); if hp > 0 then kit.w16(0x0ACE, 2) end end; if n % 600 == 0 then h[#h + 1] = string.format("n=%d hp=%d gems=%d hpToHeal=%d sc=%02X", n, kit.r16(0x0ACE), kit.r16(0x0AD6), kit.r16(0x0ACC), kit.r16(0x0644) & 0xFF) end end,
  final = function() local hh = {}; for k, v in pairs(hist) do hh[#hh + 1] = string.format("%02X:%d", k, v) end; table.sort(hh)
    return { giveItemHist = table.concat(hh, " "), rolls = rolls, healDropBodies = heal, healBranch = spawn, sparkleEntries = sparks, pos = pos, track = h } end }
"""


def bot_lua(b):
    return W.bot_lua(b)


def run(m, name, state, lua, frames, pokes=(), includes=("gaia_kit", "a_census"), turbo=True):
    ls = m.call("load_state_file", path=state)
    for a, v, s in pokes:
        m.poke(a, v)
    t = time.time()
    r = m.run_script_checked(lua, ok_stop=("script_done",), name="r1_probe", includes=list(includes), frames=frames + 20, turbo=turbo, timeoutMs=900000)
    res = r["result"]
    a = m.call("get_access_summary", type="prgRom", rangesPath=os.path.join(RAW, "R1_ranges_req.json"), cdl=True)
    names = {x["req"]: x for x in json.load(open(os.path.join(RAW, "R1_ranges.json")))["rows"]}
    res["touched"] = [dict(label=names[x["name"]]["name"], id=names[x["name"]]["id"], start=x["start"], exec=x["exec"], execFirstByte=x["execFirstByte"], read=x["read"], write=x["write"], bytesTouched=x["bytesTouched"])
                      for x in a["rows"] if x["exec"] or x["read"] or x["write"]]
    out = dict(name=name, state=os.path.basename(state), romCheck=ls.get("romCheck"), frames=frames, result=res, lua=lua, seconds=round(time.time() - t, 1), warnings=r.get("__warnings__", []))
    json.dump(out, open(os.path.join(RAW, f"R1_probe_{name}.json"), "w"), indent=1, default=str)
    return out


def st(n):
    return os.path.join(STATE_DIR, n)


RICH = dict(seed=77, pAct=70, act=["b", "a", "y", "x", "b"], pressLens=[3, 3, 10, 30], alt=["l", "r"])


def probe_thinker(m):
    return run(m, "thinker_overrun", S01R, THINKER, 20000, includes=("e2_palette",))


def probe_north(m):
    # observe over the natural replay (it reaches NorthProbeRedirect 13 times) and the South Cape bot
    m.call("load_state_file", path=W.NATURAL["state"])
    r = m.call("load_script", name="r1_north", code=NORTH, includes=["gaia_kit"])
    doc = json.load(open(W.NATURAL["input"], encoding="utf-8"))
    for part in W.chunk_sequence(doc["segments"]):
        m.call("play_input", sequence=part, turbo=True, thenPause=True)
    m.call("advance_frame", frames=30, turbo=True)
    out = m.call("get_script_result", name="r1_north")
    json.dump(dict(name="north_probe", lua=NORTH, load=r, result=out), open(os.path.join(RAW, "R1_probe_north_probe.json"), "w"), indent=1, default=str)
    return out


def probe_sparkle_read(m):
    return run(m, "sparkle_read", st("orig_G2_s22_gem3_will.mss"), HDR + SPARK_READ.replace("@BOT@", bot_lua(dict(RICH, seed=3))), 2400, pokes=[(0x0AA2, 0x77, 2)])


def probe_drop(m, name, state, frames, seed, lowroll=False):
    lua = HDR + DROP.replace("@FRAMES@", str(frames)).replace("@BOT@", bot_lua(dict(RICH, seed=seed))).replace("@LOWROLL@", "true" if lowroll else "false")
    lua = lua.replace("@REFILL@", "10" if lowroll else "100000").replace("@KEEPLOW@", "false" if lowroll else "true")
    return run(m, name, state, lua, frames, pokes=[(0x0AA2, 0x77, 2)])


STATUS = r"""
local FORM = @FORM@
local strs, n = {}, 0
acen.run{ frames = 900, writes = false, reads = false, timeline = { start = 1, loop = false, steps = {
  {n=30,b={}},{n=3,b={"down"}},{n=40,b={}},{n=3,b={"down"}},{n=40,b={}},{n=3,b={"down"}},{n=60,b={}},{n=3,b={"b"}},{n=60,b={}},{n=3,b={"down"}},{n=40,b={}},{n=3,b={"down"}},{n=40,b={}},
  {n=3,b={"up"}},{n=40,b={}},{n=3,b={"b"}},{n=60,b={}},{n=3,b={"up"}},{n=40,b={}},{n=3,b={"up"}},{n=60,b={}} } },
  final = function() return { form = kit.r16(0x0AD4), abil = kit.r16(0x0AA2), tab = kit.r16(0x0AFA), idx = kit.r16(0x0AE8), sc = kit.r16(0x0644) } end }
"""


def probe_status(m, form):
    return run(m, f"status_f{form}", st("orig_S09_inventory.mss"), HDR + STATUS.replace("@FORM@", str(form)), 900, pokes=[(0x0AD4, form, 2), (0x0AA2, 0x7777, 2)])


PROBES = {
    "thinker_overrun": probe_thinker,
    "north_probe": probe_north,
    "sparkle_read": probe_sparkle_read,
    "drop_lowhp_s22": lambda m: probe_drop(m, "drop_lowhp_s22", st("orig_G2_s22_gem3_will.mss"), 4800, 11),
    "drop_lowhp_s6d": lambda m: probe_drop(m, "drop_lowhp_s6d", st("orig_G2_s6D_dispatch_will.mss"), 4800, 12),
    "drop_lowhp_s11": lambda m: probe_drop(m, "drop_lowhp_s11", st("orig_S11_combat-room-freedan.mss"), 6000, 21),
    "drop_lowhp_s10": lambda m: probe_drop(m, "drop_lowhp_s10", st("orig_S10_combat-room-will.mss"), 6000, 22),
    "drop_lowhp_s12": lambda m: probe_drop(m, "drop_lowhp_s12", st("orig_S12_combat-room-shadow.mss"), 6000, 23),
    "drop_lowhp_s11b": lambda m: probe_drop(m, "drop_lowhp_s11b", st("orig_S11_combat-room-freedan.mss"), 6000, 24),
    "drop_roll_s11": lambda m: probe_drop(m, "drop_roll_s11", st("orig_S11_combat-room-freedan.mss"), 4800, 31, True),
    "drop_roll_s10": lambda m: probe_drop(m, "drop_roll_s10", st("orig_S10_combat-room-will.mss"), 4800, 32, True),
    "drop_roll_s12": lambda m: probe_drop(m, "drop_roll_s12", st("orig_S12_combat-room-shadow.mss"), 4800, 33, True),
    "drop_roll_s22": lambda m: probe_drop(m, "drop_roll_s22", st("orig_G2_s22_gem3_will.mss"), 4800, 34, True),
    "drop_roll_s6d": lambda m: probe_drop(m, "drop_roll_s6d", st("orig_G2_s6D_dispatch_will.mss"), 4800, 35, True),
    "status_f0": lambda m: probe_status(m, 0),
    "status_f1": lambda m: probe_status(m, 1),
    "status_f2": lambda m: probe_status(m, 2),
}


def main():
    names = sys.argv[1:] or list(PROBES)
    m, info = open_session()
    print("ROM", info["fileSha1"], flush=True)
    try:
        for n in names:
            try:
                o = PROBES[n](m)
                res = o.get("result", o) if isinstance(o, dict) else o
                print("PROBE", n, json.dumps(res, default=str)[:1500], flush=True)
            except Exception as e:
                print("FAILED", n, repr(e)[:600], flush=True)
    finally:
        m.close()


if __name__ == "__main__":
    main()
