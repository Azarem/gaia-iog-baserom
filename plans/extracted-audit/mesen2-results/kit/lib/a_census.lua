-- description: Campaign A census: who writes / reads actor Flags10 and Flags12 (+10..+13 of every actor slot), plus a seeded input bot.
-- requires: gaia_kit
--
-- Use:  run_script{ includes={"a_census"}, frames=N, turbo=true, code="acen.run{ frames=N, outFile='x.txt', writes=true, reads=false, bot={...} }" }
--
-- All addresses are WRAM offsets. Actor slot k (84 slots) is at 0x1000 + 0x30*k; the fields are +10/+11 (Flags10 low/high byte)
-- and +12/+13 (Flags12 low/high byte). The PC a memory callback reports is the address AFTER the instruction that made
-- the access; the six bytes before it are stored once per K:PC (line "P") so that the instruction can be decoded offline.
-- The callback runs before the store, so emu.read() inside it returns the old byte.
--
-- Options of acen.run: frames, outFile, writes, reads, bot, timeline, at={[n]=fn}, execs={Name=cpuAddress}, refill, sample/sampleEvery,
-- final, and (A4) input=function(n) -> button table or nil (nil falls through to timeline, then bot) and tick=function(n) (every frame, after `at`).
-- Result keys: control36Writes (positive control: one write of $36 per NMI), execCounts, stats, samples, final.
--
-- Output: the server keeps at most about 100,000 bytes of script output per step, so the result is written as compact
-- space-separated lines through emu.mcp.writeFile:
--   P kk:pppp ctx6 ps a x y d dbr                       one per distinct K:PC (ctx6 = the six bytes before pc)
--   W word bit dir kk:pppp n nPlayer first last scene0 form0 slot0 old new scenes slots
--   R field kk:pppp n nPlayer first last scene0 form0 slot0 scenes slots
acen = acen or {}

local WR = emu.memType.snesWorkRam
local SNES = emu.memType.snesMemory

local W, R, PCI = {}, {}, {}
local stats = { writes = 0, writeChanges = 0, reads = 0 }
local cfg = {}

local function contextBytes(k, pc)
  local t = {}
  for i = 6, 1, -1 do
    local a = ((k & 0xFF) << 16) | ((pc - i) & 0xFFFF)
    t[#t + 1] = string.format("%02X", emu.read(a, SNES))
  end
  return table.concat(t)
end

local function pcInfo(st, k, pc)
  local key = string.format("%02X:%04X", k, pc)
  if not PCI[key] then
    PCI[key] = string.format("P %s %s %d %d %d %d %d %d", key, contextBytes(k, pc), st["cpu.ps"], st["cpu.a"],
      st["cpu.x"], st["cpu.y"], st["cpu.d"], st["cpu.dbr"])
  end
  return key
end

local function fresh(e)
  e.n, e.nPlayer, e.nScenes, e.nSlots = 0, 0, 0, 0
  e.scenes, e.slots = {}, {}
  return e
end

local function bump(e, slot, frame, scene)
  e.n = e.n + 1
  if not e.scenes[scene] then
    e.scenes[scene] = 0
    e.nScenes = e.nScenes + 1
  end
  e.scenes[scene] = e.scenes[scene] + 1
  if slot == cfg.player then e.nPlayer = e.nPlayer + 1 end
  if not e.slots[slot] and e.nSlots < 6 then
    e.slots[slot] = true
    e.nSlots = e.nSlots + 1
  end
  e.last = frame
end

local function onWrite(addr, v)
  local off = addr & 0xFFFF
  if off < 0x1000 or off > 0x1FBF then return end
  local rel = off - 0x1000
  local f = rel % 0x30
  if f < 0x10 or f > 0x13 then return end
  stats.writes = stats.writes + 1
  local old = emu.read(off, WR)
  local ch = old ~ v
  if ch == 0 then return end
  stats.writeChanges = stats.writeChanges + 1
  local st = emu.getState()
  local k, pc = st["cpu.k"], st["cpu.pc"]
  local pck = pcInfo(st, k, pc)
  local word = (f < 0x12) and "10" or "12"
  local hi = (f & 1) == 1
  local slot = off - f
  local scene = kit.r16(0x0644)
  for b = 0, 7 do
    local m = 1 << b
    if (ch & m) ~= 0 then
      local bit = hi and (b + 8) or b
      local dir = ((v & m) ~= 0) and "+" or "-"
      local key = string.format("%s %02d %s %s", word, bit, dir, pck)
      local e = W[key]
      if not e then
        e = fresh({ word = word, bit = bit, dir = dir, pck = pck, first = st["frameCount"], scene0 = scene,
                    form0 = kit.r16(0x0AD4), slot0 = slot, old = old, new = v })
        W[key] = e
      end
      bump(e, slot, st["frameCount"], scene)
    end
  end
end

local function onRead(addr, v)
  local off = addr & 0xFFFF
  if off < 0x1000 or off > 0x1FBF then return end
  local rel = off - 0x1000
  local f = rel % 0x30
  if f < 0x10 or f > 0x13 then return end
  stats.reads = stats.reads + 1
  local st = emu.getState()
  local pck = pcInfo(st, st["cpu.k"], st["cpu.pc"])
  local key = string.format("%02X %s", f, pck)
  local slot = off - f
  local e = R[key]
  if not e then
    e = fresh({ f = f, pck = pck, first = st["frameCount"], scene0 = kit.r16(0x0644), form0 = kit.r16(0x0AD4),
                slot0 = slot })
    R[key] = e
  end
  bump(e, slot, st["frameCount"], kit.r16(0x0644))
end

-- seeded bot: segments of 8..30 frames, one direction (10% none), an action button chosen with probability pAct;
-- the press length is drawn from `pressLens` (default {3}); a press of 45 frames or more may add one of `alt`
-- (l/r) from frame 42 of the press, which is the charge-time ability selector of the attack companion.
local function makeBot(b)
  local seed = b.seed or 12345
  local function rnd(n)
    seed = (seed * 1103515245 + 12345) & 0x7FFFFFFF
    return (seed >> 8) % n
  end
  local dirs = b.dirs or { "up", "down", "left", "right" }
  local act = b.act or { "a", "b" }
  local lens = b.pressLens or { 3 }
  local alt = b.alt or {}
  local segLeft, curDir, curAct, pressLen, pressAt, curAlt = 0, nil, nil, 0, 0, nil
  return function()
    if segLeft <= 0 then
      curDir = nil
      if #dirs > 0 and rnd(10) ~= 0 then curDir = dirs[1 + rnd(#dirs)] end
      curAct, curAlt = nil, nil
      pressLen, pressAt = 0, 0
      if #act > 0 and rnd(100) < (b.pAct or 70) then
        curAct = act[1 + rnd(#act)]
        pressLen = lens[1 + rnd(#lens)]
        if pressLen >= 45 and #alt > 0 and rnd(2) == 0 then curAlt = alt[1 + rnd(#alt)] end
      end
      segLeft = math.max(8 + rnd(23), pressLen + 2)
    end
    segLeft = segLeft - 1
    pressAt = pressAt + 1
    local t = {}
    if curDir and not (curAct == "b" and pressLen >= 45 and b.stand) then t[curDir] = true end
    if curAct and pressAt <= pressLen then t[curAct] = true end
    if curAlt and pressAt >= 42 and pressAt <= 50 then t[curAlt] = true end
    return t
  end
end

local function joinKeys(t, fmt)
  local o = {}
  for s, n in pairs(t) do o[#o + 1] = n == true and string.format(fmt, s) or string.format(fmt, s, n) end
  table.sort(o)
  return #o > 0 and table.concat(o, ",") or "-"
end

local function lines(isWrite)
  local out = {}
  if isWrite then
    for key, e in pairs(W) do
      out[#out + 1] = { key = key, line = string.format("W %s %d %s %s %d %d %d %d %02X %d %04X %d %d %s %s", e.word, e.bit,
        e.dir, e.pck, e.n, e.nPlayer, e.first, e.last, e.scene0, e.form0, e.slot0, e.old, e.new,
        joinKeys(e.scenes, "%02X:%d"), joinKeys(e.slots, "%04X")) }
    end
  else
    for key, e in pairs(R) do
      out[#out + 1] = { key = key, line = string.format("R %02X %s %d %d %d %d %02X %d %04X %s %s", e.f, e.pck, e.n,
        e.nPlayer, e.first, e.last, e.scene0, e.form0, e.slot0, joinKeys(e.scenes, "%02X:%d"), joinKeys(e.slots, "%04X")) }
    end
  end
  table.sort(out, function(a, b) return a.key < b.key end)
  return out
end

local function emitAll(file)
  local nl = string.char(10)
  local buf, size = {}, 0
  local count = { P = 0, W = 0, R = 0 }
  local function push(line, kind)
    buf[#buf + 1] = line
    size = size + #line + 1
    count[kind] = count[kind] + 1
    if size >= 3000 then
      emu.mcp.writeFile(file, table.concat(buf, nl) .. nl, true)
      buf, size = {}, 0
    end
  end
  local keys = {}
  for k in pairs(PCI) do keys[#keys + 1] = k end
  table.sort(keys)
  for _, k in ipairs(keys) do push(PCI[k], "P") end
  for _, r in ipairs(lines(true)) do push(r.line, "W") end
  for _, r in ipairs(lines(false)) do push(r.line, "R") end
  if #buf > 0 then emu.mcp.writeFile(file, table.concat(buf, nl) .. nl, true) end
  return count
end

-- acen.run{ frames=N, outFile=name, writes=bool, reads=bool, bot={...}|nil, at={[frame]=fn}, sampleEvery=n, sample=fn, final=fn }
function acen.run(o)
  cfg.player = kit.r16(0x09AA)
  W, R, PCI = {}, {}, {}
  stats = { writes = 0, writeChanges = 0, reads = 0 }
  local ctl = { n36 = 0 }
  if o.writes ~= false then
    emu.addMemoryCallback(onWrite, emu.callbackType.write, 0x1000, 0x1FBF, emu.cpuType.snes, WR)
  end
  if o.reads then
    emu.addMemoryCallback(onRead, emu.callbackType.read, 0x1010, 0x1FBF, emu.cpuType.snes, WR)
  end
  -- positive control: the frame counter write in the NMI
  local execCounts = {}
  for name, addr in pairs(o.execs or {}) do
    execCounts[name] = 0
    emu.addMemoryCallback(function() execCounts[name] = execCounts[name] + 1 end, emu.callbackType.exec, addr, addr, emu.cpuType.snes)
  end
  emu.addMemoryCallback(function() ctl.n36 = ctl.n36 + 1 end, emu.callbackType.write, 0x36, 0x36, emu.cpuType.snes, WR)
  local botFn = o.bot and makeBot(o.bot)
  local n = 0
  -- timeline: { start = frame, steps = { {n = frames, b = {"b", "left"}}, ... }, loop = bool }; before `start` the bot (if any) drives
  local tl = o.timeline
  local tlStep, tlLeft = 1, tl and tl.steps[1].n or 0
  local ifn = o.input   -- optional per-frame input function: ifn(n) returns a button table (or nil to fall through to timeline / bot)
  if botFn or tl or ifn then
    emu.addEventCallback(function()
      if ifn then
        local t = ifn(n)
        if t then emu.setInput(t, 0); return end
      end
      if tl and n >= tl.start then
        local st = tl.steps[tlStep]
        if st then
          local t = {}
          for _, b in ipairs(st.b) do t[b] = true end
          emu.setInput(t, 0)
          tlLeft = tlLeft - 1
          if tlLeft <= 0 then
            tlStep = tlStep + 1
            if tlStep > #tl.steps and tl.loop then tlStep = 1 end
            tlLeft = tl.steps[tlStep] and tl.steps[tlStep].n or 0
          end
          return
        end
        emu.setInput({}, 0)
        return
      end
      if botFn then emu.setInput(botFn(), 0) end
    end, emu.eventType.inputPolled)
  end
  local samples = {}
  local stopped = nil
  kit.onFrame(function()
    n = n + 1
    if o.at and o.at[n] then o.at[n]() end
    if o.tick then o.tick(n) end
    if o.refill and (n % o.refill == 0) and kit.r16(0x0ACE) > 0 then kit.w16(0x0ACE, kit.r16(0x0ACA)) end
    if o.stop and n < o.frames and n > 5 and o.stop() then
      stopped = n
      o.frames = n
    end
    if o.sample and o.sampleEvery and (n % o.sampleEvery == 0) then
      samples[#samples + 1] = o.sample(n)
    end
    if n >= o.frames then
      local ok, err = pcall(function()
        local res = { stoppedAt = stopped, frames = n, control36Writes = ctl.n36, execCounts = execCounts, stats = stats, player = cfg.player,
                      scene = kit.r16(0x0644), form = kit.r16(0x0AD4), hp = kit.r16(0x0ACE), samples = samples }
        if o.final then res.final = o.final() end
        if o.outFile then
          emu.mcp.writeFile(o.outFile, "", false)
          res.counts = emitAll(o.outFile)
          res.outFile = o.outFile
        end
        kit.finish(res)
      end)
      if not ok then
        emu.log("acen finish failed: " .. tostring(err))
        kit.finish({ error = tostring(err), frames = n, stats = stats })
      end
    end
  end)
end
