#!/usr/bin/env python3
"""Campaign A follow-up (A4), scripted events: Dark Space warp, forced walk, dialogue text.

usage: scenario_a4_events.py [ds] [fw] [talk:T0] [talk:T2]        (default: all four)

  ds       OQ-I025-2, OQ-I053-3: South Cape (scene $01) spawns dark_space2 at tile (14,6) (extracted/tables/scene_actors.asm).
           Will is put one tile south of the portal actor and Up is pressed (DarkSpaceInteractionMonitor: BranchIfPressed $0801).
           Write census on the player's $10 (who sets / clears $2000), per-frame rows of player $10, scene ids, entry word.
  fw       OQ-60: scene $03 warp_def_03 has a stair-warp (extended warp) at tile (11,5), 1x2 (extracted/tables/scene_warps.asm).
           Will is put south of it and Up is held; ExecuteForcedWalkWarp -> StartForcedWalk -> ForcedWalkNorth.
  talk:T0  OQ-54 baseline: hideout cutscene (scene $02, talks by itself); observe the calling actor (D at the PrintDialogString
           entry) before, during and after each text: `$10`, `$08`, entry word.
  talk:T2  OQ-54 forced: while displayModeFlags `$2000` (text active) is set, `$10 |= $0800` is re-written on the caller at the end
           of every frame, so RunActors_CutsceneOnly (run by the renderer's frame updates) sees the calling actor mid-COP.

Each experiment is one atomic run_script from the South Cape state (a_common.run_experiment); the result is raw/A4_<name>_<date>.json.
"""
import sys

from a_common import S01R, label_addresses, open_session, run_experiment, stamp

LOG_ROWS = r"""
local rows = {}
local function L(s) if #rows < 3000 then rows[#rows + 1] = s end end
local ent = aact.ent
"""

# one line of player state, logged when it changes
PLAYER_STATE = r"""string.format('cur=%02X next=%02X pf10=%04X pent=%06X px=%d py=%d dm=%04X jm=%04X lp=%04X', kit.r16(0x0644) & 0xFF, kit.r16(0x0642) & 0xFF, kit.r16(0x1010), ent(0x1000), kit.r16(0x1014), kit.r16(0x1016), kit.r16(0x09EC), kit.r16(0x065A), kit.r16(0x06EE))"""


def lua_ds(ex, frames):
    return LOG_ROWS + f"""
local portal, last = nil, nil
acen.run{{
  frames = {frames}, writes = true, reads = false, outFile = 'A4_DS_south_cape_{stamp()}.txt', refill = 10,
  execs = {{ DarkSpaceMonitorStartWarp = {ex['DarkSpaceMonitorStartWarp']}, DarkSpaceInteractionMonitor = {ex['DarkSpaceInteractionMonitor']} }},
  input = function(n)
    if n >= 12 and n < 400 and (n % 20) < 4 then return {{up = true}} end
    return nil
  end,
  tick = function(n)
    if n == 6 then
      -- the portal's entry bank is the HiROM mirror $88 of ROM bank $08 (not $08)
      for _, s in ipairs(aact.live()) do
        local e = ent(s)
        if kit.r8(s + 2) == 0x88 and (e & 0xFFFF) >= 0xD69E and (e & 0xFFFF) <= 0xD700 then portal = s; break end
      end
      if portal then
        L(string.format('%d PORTAL slot=%04X ent=%06X x=%d y=%d f10=%04X', n, portal, ent(portal), kit.r16(portal + 0x14), kit.r16(portal + 0x16), kit.r16(portal + 0x10)))
        local x, y = kit.r16(portal + 0x14), kit.r16(portal + 0x16) + 16
        kit.w16(0x1014, x); kit.w16(0x1016, y); kit.w16(0x09A2, x - 8); kit.w16(0x09A4, y - 16)
      else
        L('no portal actor found')
      end
    end
    local st = {PLAYER_STATE}
    if st ~= last then L(n .. ' ' .. st); last = st end
  end,
  final = function() return {{rows = rows, portal = portal}} end,
}}
"""


def lua_fw(ex, frames):
    execs = ", ".join(f"{k} = {v}" for k, v in ex.items())
    return LOG_ROWS + f"""
local tp_at, tp_n, last = nil, nil, nil
acen.run{{
  frames = {frames}, writes = true, reads = false, outFile = 'A4_FW_scene03_{stamp()}.txt', refill = 10,
  execs = {{ {execs} }},
  at = {{ [2] = function() kit.w16(0x0642, 3) end }},
  input = function(n)
    if tp_at and n >= tp_at + 5 and n < tp_at + 400 and ((n - tp_at) % 60) < 50 then return {{up = true}} end
    return nil
  end,
  tick = function(n)
    if not tp_at and (kit.r16(0x0644) & 0xFF) == 3 and n > 20 then
      tp_n = (tp_n or 0) + 1
      if tp_n == 120 then
        tp_at = n
        local x, y = 11 * 16 + 8, 7 * 16 + 24
        kit.w16(0x1014, x); kit.w16(0x1016, y); kit.w16(0x09A2, x - 8); kit.w16(0x09A4, y - 16)
        L(string.format('%d TP to %d,%d', n, x, y))
      end
    end
    local st = {PLAYER_STATE}
    if st ~= last then L(n .. ' ' .. st); last = st end
  end,
  final = function() return {{rows = rows}} end,
}}
"""


def lua_talk(mode, ex, frames):
    force = ("if caller and (kit.r16(0x09EC) & 0x2000) ~= 0 then kit.w16(caller + 0x10, kit.r16(caller + 0x10) | 0x0800) end"
             if mode == "T2" else "")
    return LOG_ROWS + f"""
local prints, caller = 0, nil
local curN = 0
local PDS = {ex['PrintDialogString']}
local printCb = emu.addMemoryCallback(function()
  local st = emu.getState()
  caller = st["cpu.d"]
  prints = prints + 1
  L(string.format('%d PRINT #%d caller=%04X ent=%06X f10=%04X f12=%04X wt=%d dm=%04X', curN, prints, caller, ent(caller), kit.r16(caller + 0x10), kit.r16(caller + 0x12), kit.r16(caller + 8), kit.r16(0x09EC)))
end, emu.callbackType.exec, PDS, PDS, emu.cpuType.snes)
local lastDm, lastCallerState = 0, nil
acen.run{{
  frames = {frames}, writes = false, reads = false,
  bot = {{seed=5,pAct=60,act={{'a'}},pressLens={{3}}}},
  at = {{ [2] = function() kit.w16(0x0642, 2) end }},
  execs = {{ PrintDialogString = {ex['PrintDialogString']}, RunActors_CutsceneOnly = {ex['RunActors_CutsceneOnly']}, DialogStringRenderer = {ex['DialogStringRenderer']}, UpdateFrameRender = {ex['UpdateFrameRender']} }},
  tick = function(n)
    curN = n
    local dm = kit.r16(0x09EC)
    if caller then
      local st = string.format('ent=%06X f10=%04X f12=%04X wt=%d', ent(caller), kit.r16(caller + 0x10), kit.r16(caller + 0x12), kit.r16(caller + 8))
      if (dm & 0x2000) ~= 0 or st ~= lastCallerState then L(string.format('%d caller=%04X dm=%04X %s', n, caller, dm, st)) end
      lastCallerState = st
      if (dm & 0x2000) == 0 and (lastDm & 0x2000) ~= 0 then L(string.format('%d TEXT END caller=%04X', n, caller)); caller = nil; lastCallerState = nil end
    end
    lastDm = dm
    {force}
  end,
  final = function() emu.removeMemoryCallback(printCb, emu.callbackType.exec, PDS, PDS, emu.cpuType.snes); return {{rows = rows, prints = prints}} end,
}}
"""


EXPERIMENTS = {
    "ds": dict(name="DS_south_cape", frames=700, labels=("DarkSpaceMonitorStartWarp", "DarkSpaceInteractionMonitor"), lua=lua_ds),
    "fw": dict(name="FW_scene03", frames=900,
               labels=("ExecuteForcedWalkWarp", "ForcedWalkNorth", "ForcedWalkSouth", "StartForcedWalk", "SyncPlayerToCamera"), lua=lua_fw),
    "talk:T0": dict(name="OQ54_T0", frames=1500, labels=("PrintDialogString", "RunActors_CutsceneOnly", "DialogStringRenderer", "UpdateFrameRender"),
                    lua=lambda ex, frames: lua_talk("T0", ex, frames)),
    "talk:T2": dict(name="OQ54_T2", frames=1500, labels=("PrintDialogString", "RunActors_CutsceneOnly", "DialogStringRenderer", "UpdateFrameRender"),
                    lua=lambda ex, frames: lua_talk("T2", ex, frames)),
}


def main():
    # One server session per experiment: after talk:T0 a second bot-driven run in the same session (even the same script)
    # never reached scene $02 (0 PrintDialogString, scene stayed $01) while WRAM and SRAM after `load_state_file` were identical
    # to the first run's start (checked by hash). The cause is not found; a fresh session reproduces the stored numbers.
    wanted = sys.argv[1:] or list(EXPERIMENTS)
    for key in wanted:
        e = EXPERIMENTS[key]
        m, info = open_session()
        try:
            ex = label_addresses(m, e["labels"])
            res = run_experiment(m, info, e["name"], e["lua"](ex, e["frames"]), e["frames"], "A4", state=S01R)
            fin = res.get("final") or {}
            print(f"{e['name']:16s} {res['__seconds__']:5.1f}s execs={res['execCounts']} scene={res['scene']:02X} rows={len(fin.get('rows', []))}"
                  + (f" prints={fin['prints']}" if "prints" in fin else ""))
        finally:
            m.close()


if __name__ == "__main__":
    main()
