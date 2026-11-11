-- description: G4 knockback tier watch: from a loaded state, log every store to the tier byte ($7F101C,X of the 84 actor slots) for N NMI frames, with the writing instruction and the final non-zero tiers.
-- requires: mesen_kit, iog_kit, gaia_kit, a_census, a_actors, g1_kit, g2_kit, g4_kit
--
--   g4.tier{ frames = N, cap = 60, pulses = { { t = 60, btn = { "a" }, len = 3 }, ... } }   -- pulses: button list held for `len` NMI frames from t
--     S.t = NMI frames ($36 deltas); rows "t=.. site=<ROM offset of the writing instruction's end>=<value> slot=<slot>"; S.ctl = INC $36 writes (positive control)
--     result: tier = { "<site>=<value> n=<count> first t=<t> slot=<slot>", ... }, finalTiers = "slot:value ...", readExec = exec count of the tier read in the stagger controller (55463)
--
-- The tier byte of slot s ($1000 + 0x30 k) is WRAM 0x1101C + s (low byte written first by a 16-bit store).

g4 = g4 or {}

function g4.tier(o)
  local S = g2.new{ cap = o.cap or 60 }
  local CPU, WR = emu.cpuType.snes, emu.memType.snesWorkRam
  local agg, order, readExec = {}, {}, 0
  for k = 0, 83 do
    local slot = 0x1000 + 0x30 * k
    local a = 0x1101C + slot
    emu.addMemoryCallback(function(addr, v)
      local st = emu.getState()
      local pc = ((st["cpu.k"] or 0) << 16) | (st["cpu.pc"] or 0)
      local site = g4.romOff(pc)
      local key = string.format("%s=%02X", site and tostring(site) or string.format("%06X", pc), v & 0xFF)
      local e = agg[key]
      if not e then e = { n = 0, t = S.t, slot = slot }; agg[key] = e; order[#order + 1] = key end
      e.n = e.n + 1
    end, emu.callbackType.write, a, a, CPU, WR)
  end
  S:ex(55463, function() readExec = readExec + 1 end)
  S:frame(function(t)
    if o.pulses then
      local held = nil
      for _, p in ipairs(o.pulses) do
        if S.t >= p.t and S.t < p.t + (p.len or 3) then held = p.btn end
      end
      if held then gaia.hold(held) else gaia.release() end
    end
    if S.t >= o.frames then
      local rows = {}
      for _, key in ipairs(order) do local e = agg[key]; rows[#rows + 1] = string.format("%s n=%d first t=%d slot=%X", key, e.n, e.t, e.slot) end
      local fin = {}
      for k = 0, 83 do
        local slot = 0x1000 + 0x30 * k
        local v = kit.r16(0x1101C + slot)
        if v ~= 0 then fin[#fin + 1] = string.format("%X:%X", slot, v) end
      end
      S:finish({ tier = rows, finalTiers = table.concat(fin, " "), readExec = readExec })
    end
  end)
end
