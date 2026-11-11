-- description: R2 warp-entry probe: warp to a scene, put the player on a warp rectangle, let the warp fire, read the revive/save records.
-- requires: mesen_kit, iog_kit, gaia_kit
--
--   r2w.run{ scene=, x=, y=, dest=, settle=60, hold=90, maxWait=900 }
--
-- Run it from the S01r state. Frame 1 writes `scene` into sceneNext $0642. After `scene` has arrived ($0644 == scene, $0642 == 0) and $36
-- (frame parity counter, +1 per NMI) has advanced `settle` NMIs, the player actor position ($1014 / $1016, pixels) is written to (x, y) on every
-- frame (at most `hold` frames) until the warp stages a destination ($0642 != 0). The row (kit.finish) holds:
--   before / after = { ptr0AF0, bank0AF2, ptr0AF4, bank0AF6 } read at the staging frame (before) and after the destination arrived (after)
--   staged = $0642 at the staging frame, arrived = destination reached, pos = player (x, y) at staging, spawn = $064C / $064E / $0650 / $0652
r2w = r2w or {}

local WR = emu.memType.snesWorkRam
local function r16(a) return emu.read16(a, WR, false) end
local function r8(a) return emu.read(a, WR, false) end

function r2w.run(o)
  local settle, hold, maxWait = o.settle or 60, o.hold or 90, o.maxWait or 900
  local S = { scene = o.scene, dest = o.dest, tx = o.x, ty = o.y }
  local nf, started, arrivedAt36, staged, stagedF = 0, false, nil, nil, nil
  local arrivedDest = false
  local lastCwr, lastCwrF = 0, 0
  S.cwr, S.tile, S.pix = 0, 0, 0
  if o.cwr then
    local PRG, CPU = emu.memType.snesPrgRom, emu.cpuType.snes
    S.samp = {}
    emu.addMemoryCallback(function()
      S.cwr = S.cwr + 1
      if S.hf and #S.samp < 6 then
        local st = emu.getState()
        S.samp[#S.samp + 1] = { r8(0x09A6), r8(0x09A8), r16(0x09A2), r16(0x09A4), r16(0x00D4), r16(0x1014), r16(0x1016), st["cpu.a"], st["cpu.x"], st["cpu.d"], st["cpu.dbr"] }
      end
    end, emu.callbackType.exec, o.cwr, o.cwr, CPU, PRG)
    -- ConvertWarpToPixels entry: the tile AABB hit
    emu.addMemoryCallback(function() S.tile = S.tile + 1 end, emu.callbackType.exec, o.cwr + 166, o.cwr + 166, CPU, PRG)
    -- JMP ExecuteWarp: the pixel test passed
    emu.addMemoryCallback(function() S.pix = S.pix + 1 end, emu.callbackType.exec, o.cwr + 75, o.cwr + 75, CPU, PRG)
  end
  local function rec() return { r16(0x0AF0), r16(0x0AF2), r16(0x0AF4), r16(0x0AF6) } end
  local function finish(why)
    S.why = why
    S.after = rec()
    S.endScene = r16(0x0644)
    S.endNext = r16(0x0642)
    S.endPos = { r16(0x1014), r16(0x1016) }
    S.endFlags = { r16(0x1010), r16(0x09AE), r16(0x00D4), r16(0x00D6), r16(0x0B12), r16(0x09A2), r16(0x09A4), r16(0x09A6), r16(0x09A8) }
    kit.finish(S)
  end
  kit.onFrame(function()
    nf = nf + 1
    if not started then
      started = true
      S.start = rec()
      emu.write16(0x0642, o.scene, WR)
      return
    end
    local sc = r16(0x0644)
    -- a dialog or banner that blocks the main loop (no CheckWarpRectangles call for 20 frames) is dismissed with A pulses
    if S.cwr ~= lastCwr then lastCwr, lastCwrF = S.cwr, nf end
    if r8(0x00B4) ~= 0 or (o.cwr and nf - lastCwrF > 20) then
      gaia.hold((nf % 6 < 3) and { "a" } or {})
      S.apulse = (S.apulse or 0) + 1
    else
      gaia.release()
    end
    if not staged then
      if sc == o.scene and r16(0x0642) == 0 and not arrivedAt36 then arrivedAt36 = r16(0x0036) end
      if arrivedAt36 and ((r16(0x0036) - arrivedAt36) & 0xFFFF) >= settle then
        S.hf = (S.hf or 0) + 1
        emu.write16(0x1014, o.x, WR)
        emu.write16(0x1016, o.y, WR)
        if r16(0x0642) ~= 0 then
          staged, stagedF = r16(0x0642), nf
          S.staged = staged
          S.before = rec()
          S.pos = { r16(0x1014), r16(0x1016) }
          S.spawn = { r16(0x064C), r16(0x064E), r16(0x0650), r16(0x0652) }
        elseif S.hf > hold then
          finish("no-trigger")
        end
      end
    else
      if sc == staged and r16(0x0642) == 0 then
        arrivedDest = true
        S.arrived = true
        S.arriveF = nf - stagedF
        -- 5 more frames so the load finishes its record writes
        S.fin = (S.fin or 0) + 1
        if S.fin >= 5 then finish("arrived") end
      elseif nf - stagedF > maxWait then
        finish("timeout")
      end
    end
  end)
end

-- r2w.fw{ scene=, x=, y=, hooks={ south=<prg offset of the instruction after JSR ReadDirSprite_YVelocity>, north=..., ... },
--         settle=60, hold=600, observe=300, cwr= }
-- Forced-walk probe: same placement as r2w.run; the trigger is the first execution of one of the hook addresses (the instruction after the
-- first ReadDirSprite_* call of a ForcedWalk* actor). At the hook it records the entry word `$0000` (low byte = animation index, high byte =
-- move_chain_table index), the chain pointer the call loaded (`$2E` of the actor, `$2C` for east/west) and the actor slot (D). It then samples
-- every 10 frames for `observe` frames: player x / y ($1014 / $1016), animation index ($1028), joypadMaskStd $065A, playerFlags $09AE and the
-- camera scroll ($068A / $068E).
function r2w.fw(o)
  local settle, hold, observe = o.settle or 60, o.hold or 600, o.observe or 300
  local PRG, CPU = emu.memType.snesPrgRom, emu.cpuType.snes
  local S = { scene = o.scene, tx = o.x, ty = o.y, hits = {}, samples = {}, cwr = 0 }
  local nf, started, arrived36, trig, lastCwr, lastCwrF = 0, false, nil, nil, 0, 0
  for name, addr in pairs(o.hooks or {}) do
    emu.addMemoryCallback(function()
      local st = emu.getState()
      local d = st["cpu.d"]
      if #S.hits < 6 then
        S.hits[#S.hits + 1] = { name = name, nf = nf, d = d, w0 = r16(0x0000), c2e = r16((d + 0x2E) & 0xFFFF), c2c = r16((d + 0x2C) & 0xFFFF),
          stream = r16(0x0650), pan = r16(0x06E0) }
      end
      if not trig then trig = nf end
    end, emu.callbackType.exec, addr, addr, CPU, PRG)
  end
  if o.cwr then
    emu.addMemoryCallback(function() S.cwr = S.cwr + 1 end, emu.callbackType.exec, o.cwr, o.cwr, CPU, PRG)
    emu.addMemoryCallback(function() S.tile = (S.tile or 0) + 1 end, emu.callbackType.exec, o.cwr + 166, o.cwr + 166, CPU, PRG)
  end
  local function finish(why) S.why = why; S.endScene = r16(0x0644); S.endNext = r16(0x0642); kit.finish(S) end
  kit.onFrame(function()
    nf = nf + 1
    if not started then
      started = true
      emu.write16(0x0642, o.scene, WR)
      return
    end
    local sc = r16(0x0644)
    if S.cwr ~= lastCwr then lastCwr, lastCwrF = S.cwr, nf end
    if r8(0x00B4) ~= 0 or (o.cwr and not trig and nf - lastCwrF > 20) then gaia.hold((nf % 6 < 3) and { "a" } or {}) else gaia.release() end
    if not trig then
      if sc == o.scene and r16(0x0642) == 0 and not arrived36 then arrived36 = r16(0x0036) end
      if arrived36 and ((r16(0x0036) - arrived36) & 0xFFFF) >= settle then
        S.hf = (S.hf or 0) + 1
        emu.write16(0x1014, o.x, WR)
        emu.write16(0x1016, o.y, WR)
        if S.hf > hold then finish("no-trigger") end
      end
    else
      local k = nf - trig
      if k % 10 == 0 and #S.samples < 40 then
        S.samples[#S.samples + 1] = { k, r16(0x1014), r16(0x1016), r16(0x1028), r16(0x065A), r16(0x09AE), r16(0x068A), r16(0x068E), r16(0x06E2) }
      end
      if k > observe then finish("observed") end
    end
  end)
end
