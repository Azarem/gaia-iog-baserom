-- description: FR50 preset-replay helpers: state snapshot (flags, items, form, abilities, gems), one scene arrival with joypad-lock writer rows and form history.
-- requires: fr40_kit
--
-- Load with run_script includes=["fr50_kit"] (the server resolves "requires": fr40_kit, fr20_kit, gaia_kit, mesen_kit, iog_kit).
-- Nothing here writes the low direct page ($00-$94) or any WRAM byte: the preset bytes are written by the harness with
-- write_memory (work RAM) before the script starts; the warp of fr40.arrive writes only the warp parameters and sceneNext.
--
--   fr50.snap()        { form, gems, abil, inv = {16 item bytes $0AB4-$0AC3}, equip ($0AC4), hp, hpMax, jewels, a6, ac, pf, p1010, mask, dmf, dump }
--                      dump = the 180 bytes $0A00-$0AB3 as hex (gaia.flags.dump)
--   fr50.arrive(P)     fr40.arrive(P) plus: R.s0 (snapshot at script start = the preset as written, before the warp), R.sA (at the end of the
--                      banner), R.s1 (end), R.formHist (frame, form) at every change, R.maskRows (stores that change joypadMaskStd: frame,
--                      scene, old > new, writer = ROM offset of the instruction that ends at the reported PC, D = actor slot, entry of that slot),
--                      R.cg (16 palette checksums at the end, when P.cg), R.track (every 10th watch frame: w, actor x/y, joypadMaskStd, playerFlags, scene)
--                      P fields: those of fr40.arrive (scene, set, watch, input, dest, stopFree, tag), cg, and walk = { {dir, fromFrame, toFrame}, ... }
--                      (watch frames counted from the end of the banner; the A pulses of input = "mashA" are sent in the same input poll).
fr50 = fr50 or {}

function fr50.snap()
  local inv = {}
  for i = 0, 15 do inv[#inv + 1] = kit.r8(0x0AB4 + i) end
  return { form = kit.r16(0x0AD4), gems = kit.r16(0x0AD6), abil = kit.r16(0x0AA2), inv = inv, equip = kit.r16(0x0AC4),
           hp = kit.r16(0x0ACE), hpMax = kit.r16(0x0ACA), jewels = kit.r8(0x0AB0), a6 = kit.r16(0x0AA6), ac = kit.r16(0x0AAC),
           pf = kit.r16(0x09AE), p1010 = kit.r16(0x1010), mask = kit.r16(0x065A), dmf = kit.r16(0x09EC), dump = gaia.flags.dump() }
end

function fr50.arrive(P)
  local s0 = fr50.snap()
  local m, R = fr40.arrive(P)
  R.s0 = s0
  R.formHist = { { f = kit.frame, form = s0.form } }
  R.maskRows = {}
  -- stores that change joypadMaskStd ($065A-$065B)
  emu.addMemoryCallback(function(a, v)
    local off = kit.wramOffset(a) or (a & 0xFFFF)
    if off ~= 0x065A and off ~= 0x065B then return end
    local old = kit.r8(off)
    if old == v or #R.maskRows >= 40 then return end
    local k, pc, frame = gaia.pc()
    local endOff = gaia.insEndingAt(k, pc)
    local d = emu.getState()["cpu.d"]
    R.maskRows[#R.maskRows + 1] = { f = kit.frame, sc = kit.r16(0x0644), a = off, old = old, new = v, ["end"] = endOff, d = d,
                                    entry = string.format("%02X:%04X", kit.r8(d + 2), kit.r16(d)) }
  end, emu.callbackType.write, 0x065A, 0x065B, emu.cpuType.snes, gaia.WR)
  kit.onFrame(function()
    local f = kit.r16(0x0AD4)
    if f ~= R.formHist[#R.formHist].form and #R.formHist < 20 then R.formHist[#R.formHist + 1] = { f = kit.frame, form = f } end
    if R.frame0 and not R.sA then R.sA = fr50.snap() end
  end)
  -- walk: list of { dir, from, to } in watch frames (frame 0 = end of the banner); the A pulses of mashA are folded into the same poll
  if P.walk then
    emu.addEventCallback(function()
      if not R.frame0 then return end
      local w = kit.frame - R.frame0
      local inp = {}
      for _, seg in ipairs(P.walk) do
        if w >= seg[2] and w < seg[3] then inp[seg[1]] = true end
      end
      if P.input == "mashA" and (w % 12) < 2 then inp.a = true end
      if next(inp) then emu.setInput(inp, 0) end
    end, emu.eventType.inputPolled)
  end
  R.track = {}
  kit.onFrame(function()
    if not R.frame0 then return end
    local w = kit.frame - R.frame0
    if w % 10 == 0 and #R.track < 150 then
      R.track[#R.track + 1] = { w = w, x = kit.r16(0x1014), y = kit.r16(0x1016), m = kit.r16(0x065A), pf = kit.r16(0x09AE), sc = kit.r16(0x0644) }
    end
  end)
  fr50.origFinish = fr50.origFinish or kit.finish
  local fin = fr50.origFinish
  kit.finish = function(r)
    if r == R then
      R.s1 = fr50.snap()
      if P.cg then
        local t = {}
        for pal = 0, 15 do
          local sum = 0
          for i = 0, 31 do sum = (sum * 31 + emu.read(pal * 32 + i, emu.memType.snesCgRam)) & 0xFFFFFFF end
          t[#t + 1] = sum
        end
        R.cg = t
      end
    end
    fin(r)
  end
  return m, R
end
