-- description: P2 abilities: multi-variant trial driver (one state, N variants by emu.createSavestate/loadSavestate inside the NMI exec callback), scheduled buttons, disclosed pokes, exec marks with register snapshots, write watches by PC.
-- requires: mesen_kit, iog_kit, gaia_kit
--
--   p2.run{ frames=N, variants=V, tag="x", out="P2_x.txt",
--           nmi=33528,                                      -- ROM offset of the NMI entry (O: NmiHandler, the per-frame hook; ROM-specific)
--           vsetup=function(S, v) end,                      -- t == 0 of variant v (1..V): disclosed pokes; returns a label
--           sched=function(t, S, v) return {"b"} end,       -- buttons held at run clock t (NMI frames since the variant start; nil = release)
--           tick=function(t, S, v) end,                     -- every frame after the scheduler (S.rows / p2.ev(S, ...) for output)
--           collect=function(S, v) return {...} end,        -- at the end of each variant (after `frames` NMIs): summary row
--           marks={ name = {prgOffset, function(S, st, name) end}, ... },   -- exec callbacks (decimal ROM file offsets; the callback runs BEFORE the instruction)
--           writes={ {name=, lo=, hi=, kinds={"write"}, mem=, cond=fn(addr16, value)}, ... },  -- watches (WRAM by default; mem = emu.memType.snesPrgRom for ROM reads); each (name, kind, K:PC, address, new byte) logs once per variant, later hits count; cond filters
--         }
--   p2.pl()   player snapshot (actor position, speeds, flags, body row, animation index)
-- Offsets are the ; {n} tags of extracted/ (O: tag = ROM file offset). Memory callbacks report the PC of the NEXT instruction.
-- emu.createSavestate / loadSavestate only work inside an exec callback of the main CPU (so the NMI entry is the frame hook).
p2 = p2 or {}

local WR  = emu.memType.snesWorkRam
local P   = emu.memType.snesPrgRom
local CPU = emu.cpuType.snes

function p2.s16(v) v = v & 0xFFFF; if v >= 0x8000 then return v - 0x10000 end return v end

function p2.pl()
  return {
    x = kit.r16(0x1014), y = kit.r16(0x1016), px = kit.r16(0x09A2), py = kit.r16(0x09A4),
    sEw = p2.s16(kit.r16(0x09B2)), sNs = p2.s16(kit.r16(0x09B4)),
    f10 = kit.r16(0x1010), f12 = kit.r16(0x1012), pf = kit.r16(0x09AE), row = kit.r16(0x0AC8), anim = kit.r16(0x1028), frame = kit.r16(0x102A),
    ent = kit.r16(0x1000), form = kit.r16(0x0AD4), ability = kit.r16(0x0AA2), mask = kit.r16(0x065A), bonusW = kit.r16(0x09E0), bonusF = kit.r16(0x09E2),
    ms1 = p2.s16(kit.r16(0x1002C)), ms2 = p2.s16(kit.r16(0x1002E)),
  }
end

function p2.ev(S, fmt, ...)
  S.nEv = S.nEv + 1
  if #S.ev < 400 then S.ev[#S.ev + 1] = "v" .. S.v .. " " .. ((select("#", ...) > 0) and string.format(fmt, ...) or fmt) end
end

function p2.row(S, fmt, ...)
  if #S.rows < 3000 then S.rows[#S.rows + 1] = "v" .. S.v .. " " .. ((select("#", ...) > 0) and string.format(fmt, ...) or fmt) end
end

function p2.run(o)
  local V = o.variants or 1
  local S = { v = 1, t = nil, ctl = 0, ev = {}, nEv = 0, cnt = {}, rows = {}, wkeys = {}, done = false, firstT = {}, results = {}, labels = {} }
  p2.S = S
  local S0 = nil

  emu.addMemoryCallback(function(a) if (a & 0xFFFF) == 0x36 then S.ctl = S.ctl + 1 end end, emu.callbackType.write, 0x36, 0x36, CPU, WR)

  for name, m in pairs(o.marks or {}) do
    local off, fn = m[1], m[2]
    emu.addMemoryCallback(function()
      S.cnt[name] = (S.cnt[name] or 0) + 1
      if S.t and not S.firstT[name] then S.firstT[name] = S.t end
      if fn then fn(S, emu.getState(), name) end
    end, emu.callbackType.exec, off, off, CPU, P)
  end

  -- w.mem = emu.memType.snesMemory (24-bit CPU addresses, e.g. ROM reads of $01:D9AD): the key then carries the address only, no old byte
  for _, w in ipairs(o.writes or {}) do
    local function cb(kind)
      return function(a, v)
        local a16 = a & 0xFFFF
        if not w.mem and (a16 < w.lo or a16 > w.hi) then return end
        if w.cond and not w.cond(a16, v) then return end
        local st = emu.getState()
        local old = (not w.mem) and emu.read(a16, WR) or 0
        local key = string.format("%s %s %02X:%04X", w.name, kind, st["cpu.k"], st["cpu.pc"])
        S.cnt[key] = (S.cnt[key] or 0) + 1
        local vkey = key .. string.format(" %04X>%02X", a16, v)
        if not S.wkeys[vkey] then
          S.wkeys[vkey] = true
          p2.ev(S, "%s %s addr=%04X old=%02X new=%02X", S.t and ("t=" .. S.t) or "t=-", key, a16, old, v)
        end
      end
    end
    for _, k in ipairs(w.kinds or { "write" }) do
      emu.addMemoryCallback(cb(k), emu.callbackType[k], w.lo, w.hi, CPU, w.mem or WR)
    end
  end

  local function summary()
    local cnt, ft = {}, {}
    for k, v in pairs(S.cnt) do cnt[k] = v end
    for k, v in pairs(S.firstT) do ft[k] = v end
    return { v = S.v, label = S.labels[S.v], control36 = S.ctl, counts = cnt, firstT = ft, info = o.collect and o.collect(S, S.v) or nil }
  end

  local function finishAll()
    S.done = true
    local lines = {}
    for _, l in ipairs(S.ev) do lines[#lines + 1] = l end
    for _, l in ipairs(S.rows) do lines[#lines + 1] = l end
    if o.out then emu.mcp.writeFile(o.out, table.concat(lines, "\n") .. "\n", false) end
    local shown = {}
    for i = 1, math.min(o.show or 0, #S.ev) do shown[#shown + 1] = S.ev[i] end
    local st = emu.getState()
    kit.finish({ tag = o.tag, variants = S.results, nEvents = S.nEv, nRows = #S.rows, events = shown, extra = S.extra, scene = kit.r16(0x0644), form = kit.r16(0x0AD4),
                 frame = st["frameCount"], k = st["cpu.k"], sp = st["cpu.sp"] })
  end

  local function beginVariant()
    S.t = 0; S.ctl = 0; S.cnt = {}; S.firstT = {}; S.wkeys = {}
    S.labels[S.v] = o.vsetup and o.vsetup(S, S.v) or nil
  end

  local nmi = o.nmi or 33528
  emu.addMemoryCallback(function()
    if S.done then return end
    local clock = kit.r16(0x36)
    if S.justLoaded then
      S.justLoaded = false
      if clock == S.n36 then return end
    end
    if not S0 then
      S.n36 = clock
      S0 = emu.createSavestate()
      beginVariant()
    else
      S.t = (clock - S.n36) & 0xFFFF
    end
    local b = o.sched and o.sched(S.t, S, S.v) or nil
    if b then gaia.hold(b) else gaia.release() end
    if o.tick then o.tick(S.t, S, S.v) end
    if S.t >= o.frames then
      S.results[#S.results + 1] = summary()
      if S.v >= V then finishAll() return end
      S.v = S.v + 1
      gaia.release() -- buttons held at the end of a variant must not leak into the first frame of the next one
      emu.loadSavestate(S0)
      S.justLoaded = true
      beginVariant()
    end
  end, emu.callbackType.exec, nmi, nmi, CPU, P)
end
