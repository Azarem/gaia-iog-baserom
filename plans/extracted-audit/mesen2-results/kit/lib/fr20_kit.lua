-- description: FR20 area-trial helpers: scene visit with flag pokes, actor list walk, observation timeline (mask, dialog, flags), input helpers.
-- requires: gaia_kit
--
-- Load with run_script includes=["fr20_kit"]   (the server resolves "requires": gaia_kit, mesen_kit, iog_kit).
-- Nothing here writes the low direct page ($00-$94). Flag writes use emu.write (they do not fire memory callbacks).
--
--   fr20.actors()                 list of live actors walked from the list head $56 through +6: {slot, bank, pc, x, y, f10, f12, wait}
--                                 (bank = entry bank byte, a HiROM mirror: $84 = ROM bank 4; ROM offset = ((bank & $3F) << 16) | pc)
--   fr20.flagBytes(n)             the n bytes of $0A00.. as one hex string
--   fr20.visit(P)                 state machine: poke flags, queue a scene, wait for the load, dismiss the banner (A pulses only while
--                                 $00B4 is nonzero), then run `settle` frames and sample. P fields:
--        scene        scene id to queue (nil: no warp, sample the loaded state)
--        pre          { {wramOffset, byte}, ... } raw byte writes before the warp (persistent flag bytes)
--        set, clear   global flag indices written before the warp
--        post         { set = {...}, clear = {...} } global flag indices written AFTER the scene finished loading and the banner is
--                     gone (scratch flags $0000-$000F are cleared by every scene load)
--        settle       frames of observation after the banner (default 60); `sampleEvery` (default 10) frames per timeline row
--        hold         { frame = {buttons}, ... } buttons held at settle frame n for 1 frame (keys are frame numbers)
--        mash         { button = "a", from = n, to = m, down = 2, gap = 6 } press a button repeatedly during settle frames from..to
--        onSample     function(R, n) called each settle frame (R = the result table); may set R.stop = true to end the run
--        watch        true: gaia.flagwatch over $0A00-$0AB3 with actor = true (rows go to R.fw)
--        teleport     { x, y } written to the player actor position ($1014/$1016) after the load
--        walk         { {from, to, {"down", ...}}, ... } buttons held on every frame of each settle segment
--        cgram        true: R.cgram1 / R.cgram<mid> = 16 palette checksums at the first and middle settle frame
--        execs        { rom offsets }: R.execs[off] = {count, first frame, last frame} for the instruction starting at each offset
--        peek         { wramOffsets }: R.peek[hex] = word at the end
--        readwatch    { wramOffsets }: R.readRows / R.readCount = reads of those bytes with reader instruction and actor entry
--        cells        { {tx, ty}, ... } collision cells read at the banner end (R.cells0) and at the end (R.cells1)
--        vram         true: R.vram = 64 checksums of the 1 KB chunks of VRAM at the end
--        maskwatch    true: R.maskRows = stores that change joypadMaskStd with the writer's ROM offset
--        tag          string copied into the result
--   result R: { tag, scene, arrived36, arrivalFrame, flags0 (hex of $0A00-$0A27 right after the arrival), flags1 (end),
--               timeline = { {n, mask, dmf, banner, sc, f36, x, y}, ... } (rows only when mask/dmf/banner change, plus every
--               sampleEvery frames), actors0 (right after the banner), actors1 (end), loadStartFrame, ctl36, fw }
fr20 = fr20 or {}

local STX_EVENT_FLAGS = 253291   -- ROM offset of ClearSceneState's STX $eventFlags (O): marks the start of a scene load

function fr20.actors()
  local out, s, guard = {}, kit.r16(0x56), 0
  while s >= 0x1000 and s < 0x1000 + 0x30 * 84 and guard < 100 do
    out[#out + 1] = { slot = s, bank = kit.r8(s + 2), pc = kit.r16(s), x = kit.r16(s + 0x14), y = kit.r16(s + 0x16),
                      f10 = kit.r16(s + 0x10), f12 = kit.r16(s + 0x12), wait = kit.r16(s + 8) }
    local raw = {}
    for i = 0, 0x2F do raw[#raw + 1] = string.format("%02X", kit.r8(s + i)) end
    out[#out].raw = table.concat(raw)
    -- chatPtr ($7F000A,X = work RAM offset 0x1000A + slot): interact handler set by SetInteractHandler
    out[#out].chat = emu.read16(0x1000A + s, emu.memType.snesWorkRam, false)
    s = kit.r16(s + 6)
    guard = guard + 1
  end
  return out
end

function fr20.flagBytes(n)
  local t = {}
  for i = 0, n - 1 do t[#t + 1] = string.format("%02X", kit.r8(0x0A00 + i)) end
  return table.concat(t)
end

local function cpuFrame() return emu.getState().frameCount end

function fr20.visit(P)
  local R = { tag = P.tag, timeline = {}, scenes = {}, ctl36 = 0 }
  local settle, every = P.settle or 60, P.sampleEvery or 10
  local loadStarts = 0
  emu.addMemoryCallback(function(a, v) if (a & 0xFFFF) == 0x36 then R.ctl36 = R.ctl36 + 1 end end,
    emu.callbackType.write, 0x36, 0x36, emu.cpuType.snes, gaia.WR)
  emu.addMemoryCallback(function() loadStarts = loadStarts + 1 end,
    emu.callbackType.exec, STX_EVENT_FLAGS, STX_EVENT_FLAGS, emu.cpuType.snes, emu.memType.snesPrgRom)
  local fw = P.watch and gaia.flagwatch{ actor = true, control = false } or nil
  -- P.maskwatch: rows of every byte store that changes joypadMaskStd ($065A-$065B): frame, scene, old>new, writer (ROM offset of the instruction that ends at the reported PC), actor slot D
  if P.maskwatch then
    R.maskRows = {}
    emu.addMemoryCallback(function(a, v)
      local off = kit.wramOffset(a) or (a & 0xFFFF)
      if off ~= 0x065A and off ~= 0x065B then return end
      local old = kit.r8(off)
      if old == v or #R.maskRows >= 60 then return end
      local k, pc, frame = gaia.pc()
      local endOff, cands = gaia.insEndingAt(k, pc)
      R.maskRows[#R.maskRows + 1] = { f = frame, sc = kit.r16(0x0644), a = off, old = old, new = v, k = k, pc = pc, ["end"] = endOff,
                                      ins = cands and cands[1], d = emu.getState()["cpu.d"], n = R.n, f36 = kit.r16(0x0036) }
    end, emu.callbackType.write, 0x065A, 0x065B, emu.cpuType.snes, gaia.WR)
  end
  -- P.execs: decimal ROM offsets; R.execs[off] = { count, first frame, last frame } of the instruction starting there
  if P.execs then
    R.execs = {}
    for _, off in ipairs(P.execs) do
      R.execs[tostring(off)] = { 0, nil, nil }
      emu.addMemoryCallback(function()
        local e = R.execs[tostring(off)]
        local fr = cpuFrame()
        e[1] = e[1] + 1
        e[2] = e[2] or fr
        e[3] = fr
      end, emu.callbackType.exec, off, off, emu.cpuType.snes, emu.memType.snesPrgRom)
    end
  end
  -- P.readwatch = { wramOffset, ... }: rows of every read of those bytes: frame, scene, reader instruction (ROM offset) and actor slot D with its entry
  if P.readwatch then
    R.readRows = {}
    R.readCount = 0
    for _, off in ipairs(P.readwatch) do
      emu.addMemoryCallback(function(a, v)
        R.readCount = R.readCount + 1
        if #R.readRows >= 60 then return end
        local k, pc, frame = gaia.pc()
        local endOff, cands = gaia.insEndingAt(k, pc)
        local d = emu.getState()["cpu.d"]
        R.readRows[#R.readRows + 1] = { f = frame, sc = kit.r16(0x0644), a = off, ["end"] = endOff, ins = cands and cands[1], d = d,
                                        entry = string.format("%02X:%04X", kit.r8(d + 2), kit.r16(d)) }
      end, emu.callbackType.read, off, off, emu.cpuType.snes, gaia.WR)
    end
  end
  local last = ""
  local lastScene
  local function row(n)
    local scNow = kit.r16(0x0644)
    if lastScene and scNow ~= lastScene and #R.scenes < 60 then
      -- scene change during the settle: flag bytes $0A1E ($F4 group) and $0A2F ($017C-$017F) at the first frame of the new scene
      R.scenes[#R.scenes + 1] = { n = n, from = lastScene, to = scNow, b1E = kit.r8(0x0A1E), b2F = kit.r8(0x0A2F), mask = kit.r16(0x065A) }
    end
    lastScene = scNow
    local mask, dmf, ban = kit.r16(0x065A), kit.r16(0x09EC), kit.r8(0x00B4)
    local key = string.format("%04X %04X %02X", mask, dmf & 0x2000, ban)
    if key ~= last or (n % every) == 0 then
      last = key
      if #R.timeline < 200 then
        R.timeline[#R.timeline + 1] = { n = n, mask = mask, dmf = dmf, ban = ban, sc = kit.r16(0x0644), f36 = kit.r16(0x0036),
                                        x = kit.r16(0x1014), y = kit.r16(0x1016) }
      end
    end
  end
  local pulsing = false
  local mashed = 0
  local m
  m = kit.machine{ start = "stage", states = {
    stage = function(mm)
      if mm:elapsed() < 2 then return end
      if P.scene and kit.r16(0x0642) ~= 0 then return end
      for _, p in ipairs(P.pre or {}) do kit.w8(p[1], p[2]) end
      for _, n in ipairs(P.set or {}) do gaia.flags.set(n) end
      for _, n in ipairs(P.clear or {}) do gaia.flags.clear(n) end
      R.flagsPre = fr20.flagBytes(40)
      R.sceneBefore = kit.r16(0x0644)
      if P.scene then
        R.loadsBefore = loadStarts
        kit.w16(0x0642, P.scene)
        mm:go("loading")
      else
        R.arrived36 = kit.r16(0x0036)
        mm:go("banner")
      end
    end,
    loading = function(mm)
      if loadStarts > R.loadsBefore and kit.r16(0x0642) == 0 and kit.r16(0x0644) == P.scene then
        R.loadStartFrame = cpuFrame()
        R.arrived36 = kit.r16(0x0036)
        mm:go("await36")
      elseif mm:elapsed() > 900 then R.error = "load_timeout"; mm:go("done") end
    end,
    await36 = function(mm)
      -- the NMI (and so $36) runs again only when the scene setup has finished
      if kit.r16(0x0036) ~= R.arrived36 then
        R.arrivalFrame = cpuFrame()
        R.flags0 = fr20.flagBytes(40)
        R.scene = kit.r16(0x0644)
        mm:go("banner")
      elseif mm:elapsed() > 900 then R.error = "await36_timeout"; mm:go("done") end
    end,
    banner = function(mm)
      if not R.arrivalFrame then R.arrivalFrame = cpuFrame(); R.flags0 = fr20.flagBytes(40); R.scene = kit.r16(0x0644) end
      if kit.r8(0x00B4) ~= 0 then
        if not pulsing then kit.pulse({ "a" }, 3, 3); pulsing = true; R.bannerSeen = true end
        R.bannerFrames = (R.bannerFrames or 0) + 1
      elseif pulsing then
        kit.stopPulse(); pulsing = false
        mm:go("settle0")
      elseif mm:elapsed() > 20 and not R.bannerSeen then
        mm:go("settle0")
      end
      if mm:elapsed() > 900 then R.error = "banner_timeout"; kit.stopPulse(); mm:go("done") end
    end,
    settle0 = function(mm)
      R.bannerGoneFrame = cpuFrame()
      R.mask0, R.dmf0, R.flagsBanner = kit.r16(0x065A), kit.r16(0x09EC), fr20.flagBytes(40)
      R.actors0 = fr20.actors()
      R.n36 = kit.r16(0x0036)
      if P.cells then
        R.cells0 = {}
        for _, c in ipairs(P.cells) do R.cells0[#R.cells0 + 1] = gaia.coll.get(c[1], c[2]) end
      end
      local post = P.post or {}
      for _, n in ipairs(post.set or {}) do gaia.flags.set(n) end
      for _, n in ipairs(post.clear or {}) do gaia.flags.clear(n) end
      R.flagsPost = (post.set or post.clear) and fr20.flagBytes(40) or nil
      if P.teleport then
        -- player actor position words (actor RAM, not low DP): +14 x, +16 y
        kit.w16(0x1014, P.teleport[1])
        kit.w16(0x1016, P.teleport[2])
      end
      R.n = 0
      mm:go("settle")
    end,
    settle = function(mm)
      R.n = R.n + 1
      local n = R.n
      row(n)
      local h = P.hold and P.hold[n]
      if h then
        local t = {}
        for _, b in ipairs(h) do t[b] = true end
        -- one frame of input: the inputPolled callback is registered once and reads this table
        R.heldNow = t
      end
      if P.cgram and (n == 1 or n == math.floor(settle / 2)) then
        -- palette sums (16 palettes of 16 colours) at the first and middle settle frame: change between the two = animated palette
        local t = {}
        for pal = 0, 15 do
          local sum = 0
          for i = 0, 31 do sum = (sum * 31 + emu.read(pal * 32 + i, emu.memType.snesCgRam)) & 0xFFFFFFF end
          t[#t + 1] = sum
        end
        R["cgram" .. n] = t
      end
      if P.onSample then P.onSample(R, n) end
      if R.stop or n >= settle then mm:go("done") end
    end,
    done = function(mm)
      kit.stopPulse()
      R.flags1 = fr20.flagBytes(40)
      R.actors1 = fr20.actors()
      R.mask1, R.dmf1 = kit.r16(0x065A), kit.r16(0x09EC)
      R.sceneEnd = kit.r16(0x0644)
      R.d36 = (kit.r16(0x0036) - (R.n36 or 0)) & 0xFFFF
      if P.cells then
        R.cells1 = {}
        for _, c in ipairs(P.cells) do R.cells1[#R.cells1 + 1] = gaia.coll.get(c[1], c[2]) end
      end
      if P.vram then
        -- checksum of every 1 KB chunk of VRAM (64 chunks): a difference between two runs localizes a tilemap or CHR change
        R.vram = {}
        for ch = 0, 63 do
          local sum = 0
          for i = 0, 1023 do sum = (sum * 31 + emu.read(ch * 1024 + i, emu.memType.snesVideoRam)) & 0xFFFFFFF end
          R.vram[#R.vram + 1] = sum
        end
      end
      if P.peek then
        R.peek = {}
        for _, a in ipairs(P.peek) do R.peek[string.format("%04X", a)] = kit.r16(a) end
      end
      R.pos = { kit.r16(0x1014), kit.r16(0x1016) }
      R.p09A2 = { kit.r16(0x09A2), kit.r16(0x09A4) }
      R.player10 = kit.r16(0x1010)
      if fw then R.fw = fw:summary() end
      if P.final then P.final(R) end
      kit.finish(R)
    end,
  } }
  -- scripted input during the settle frames: P.hold (single frames) and P.mash
  emu.addEventCallback(function()
    if m.state ~= "settle" then return end
    local t = R.heldNow
    R.heldNow = nil
    if P.mash then
      local n, a = R.n or 0, P.mash
      if n >= (a.from or 1) and n <= (a.to or 1e9) and ((n - (a.from or 1)) % ((a.down or 2) + (a.gap or 6))) < (a.down or 2) then
        t = t or {}
        t[a.button or "a"] = true
      end
    end
    if P.walk then
      -- P.walk = { {from, to, {"down"}}, ... }: buttons held on every frame of the segment
      local n = R.n or 0
      for _, w in ipairs(P.walk) do
        if n >= w[1] and n <= w[2] then
          t = t or {}
          for _, b in ipairs(w[3]) do t[b] = true end
        end
      end
    end
    if t then emu.setInput(t, 0) end
  end, emu.eventType.inputPolled)
  return m, R
end
