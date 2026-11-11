-- description: B2 traced walking trial for the player movement tick (exec hooks on the movement routines, per-frame rows).
-- requires: gaia_kit
--
-- All routine offsets are ROM FILE offsets of the ORIGINAL ROM (decimal keys of db-us/names/bank02.json; the local labels
-- are 0x20000 + the bank-02 address of the loc_02xxxx label). Do not use them on the rebuilt ROM: b2.routines is replaced by
-- the harness with an R table in that case (the harness resolves them from artifacts/labels/iog-rebuilt.mlb).
--
--   b2.trial{ frames=N, hold={...}, setup=fn, snap={names}, extra={wramOffsets}, final=fn }
--   Row per frame (array): { n, x, y, sEw, sNs, flags10, flags09AE, tinX, tinY, tin20, tin24, toutX, toutY, aa, ab, s02,
--                            visited, snaps, extra... }
--   tin* = $22/$26/$20/$24 at PlayerMovementTick entry; tout* = $22/$26 at its exit (sub-pixels, 4 per pixel);
--   aa, ab, s02 = $AA, $AB, $02 at the exit; visited = names of the traced routines entered this frame, in order;
--   snaps = {name, $20, $22, $24, $26, $02, $1A, $1E, $AA, $AB, $09C6, actorX($1014)} at the entry of each routine in `snap`.
b2 = b2 or {}
local PRG = emu.memType.snesPrgRom
local WR = emu.memType.snesWorkRam
local function o2(a) return 0x20000 + a end

b2.routines = b2.routines or {
  Tick = 184272, North = 184376, South = 185206, East = 186076, West = 187264,
  SWHandler = 184712, NWHandler = 184818, SWNudge = 184782, NProbeRedir = 184888, NSlopeR = 184558, NSlopeL = 184610,
  SSlopeR = 185422, SSlopeL = 185471, SWNorthInt = 185562, SWNorthProbe = 185636, SWSouthInt = 185654, SSlideShim = 185724,
  FineE = 185941, FineW = 186010, CompSouthSnap = 185849, CompYSnap = 184902,
  SnapYN = 184508, SnapYS = 185335, SnapXE = 186208, SnapXW = 187408, SouthBlocked = 185322,
  AAlignEWN = 185023, AAlignEWS = 185732, AAlignNSE = 187085, AAlignY = 188327,
  ERampDown = 186435, ERampUp = 186687, WRampUp = 186758, WRampDown = 187018,
  WRampDesc = 187635, WRampAsc = 187985, WEdgeDesc = 187906, WEdgeAsc = 188252,
  EWPushDown = 186267, EWPushUp = 186351, EWNorthFlag = 186337, EWSouthFlag = 186395,
  PushUp = 188512, PushDown = 188587, CompEastSnap = 187170, CompWSPush = 188406,
  ClrEW5 = 186343, ClrEW6 = 186429, ClrNS1 = 184812, ClrNS2 = 184896, ClrNS3 = 185648, ClrNS4 = 185726,
  W4B = o2(0xDC4B), W77 = o2(0xDC77), W9F = o2(0xDC9F), WCB = o2(0xDCCB),
  ECorner = o2(0xD8F4), WCorner = o2(0xDA3F), CancelV = 188666, EBlocked = o2(0xD753), NBlocked = o2(0xD0AF),
}

local function r16(a) return kit.r16(a) end

-- ROM offset of the PLX/PLD/PLP/RTL tail of PlayerMovementTick (searched from the entry; bytes FA 2B 28 6B)
function b2.tickExit()
  local base = b2.routines.Tick
  if not base then return nil end
  for i = 0, 400 do
    local a = base + i
    if emu.read(a, PRG) == 0xFA and emu.read(a + 1, PRG) == 0x2B and emu.read(a + 2, PRG) == 0x28 and emu.read(a + 3, PRG) == 0x6B then
      return a
    end
  end
  return nil
end

function b2.trial(o)
  local A = gaia.addr
  local cur = { vis = {}, snaps = {}, tin = nil, tout = nil, ticks = 0 }
  local rows, ctl36 = {}, 0
  local snapset = {}
  for _, nm in ipairs(o.snap or {}) do snapset[nm] = true end
  emu.addMemoryCallback(function(a, v) if (a & 0xFFFF) == 0x36 then ctl36 = ctl36 + 1 end end,
    emu.callbackType.write, 0x36, 0x36, emu.cpuType.snes, WR)
  for name, off in pairs(b2.routines) do
    emu.addMemoryCallback(function()
      if name == "Tick" then
        cur.ticks = cur.ticks + 1
        cur.tin = { r16(0x22), r16(0x26), kit.r16(0x20, nil, true), kit.r16(0x24, nil, true) }
      else
        cur.vis[#cur.vis + 1] = name
      end
      if snapset[name] then
        cur.snaps[#cur.snaps + 1] = { name, kit.r16(0x20, nil, true), r16(0x22), kit.r16(0x24, nil, true), r16(0x26), r16(0x02),
          r16(0x1A), r16(0x1E), r16(0xAA), r16(0xAB), r16(0x09C6), r16(0x1014) }
      end
    end, emu.callbackType.exec, off, off, emu.cpuType.snes, PRG)
  end
  local ex = b2.tickExit()
  if ex then
    emu.addMemoryCallback(function()
      cur.tout = { r16(0x22), r16(0x26), r16(0xAA), r16(0xAB), r16(0x02) }
    end, emu.callbackType.exec, ex, ex, emu.cpuType.snes, PRG)
  end
  local n, started, handle = 0, false, nil
  handle = kit.onFrame(function()
    if not started then
      started = true
      if o.setup then o.setup() end
      gaia.hold(o.hold)
      cur = { vis = {}, snaps = {}, tin = nil, tout = nil, ticks = 0 }
      return
    end
    n = n + 1
    local p = gaia.player()
    local tin = cur.tin or { -1, -1, 0, 0 }
    local tout = cur.tout or { -1, -1, 0, 0, 0 }
    local row = { n, p.x, p.y, p.sEw, p.sNs, p.flags10, r16(0x09AE), tin[1], tin[2], tin[3], tin[4], tout[1], tout[2], tout[3], tout[4],
      tout[5], table.concat(cur.vis, ">"), cur.snaps, cur.ticks }
    for _, a in ipairs(o.extra or {}) do row[#row + 1] = r16(a) end
    rows[#rows + 1] = row
    cur = { vis = {}, snaps = {}, tin = nil, tout = nil, ticks = 0 }
    if n >= o.frames then
      kit.off(handle)
      gaia.release()
      local res = { rows = rows, ctl36 = ctl36, tickExit = ex }
      if o.final then res.final = o.final() end
      kit.finish(res)
    end
  end)
end
