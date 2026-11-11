-- description: P4 run file: Freedan ledge jump from orig_P4_s01_freedan_ledge-north.mss with a chosen button during the fall (OQ-I025-7, OQ-SAN2-1 order).
-- requires: mesen_kit, iog_kit, gaia_kit, p4_kit
-- p4ledge.go{ btn = "a" | "b" | nil, out = "P4_x.txt", frames = 215, pressFrom = 32, pressTo = 36 }
p4ledge = p4ledge or {}
function p4ledge.go(o)
  local offs = {}
  local frames = o.frames or 215
  p4.run{ frames = frames + 2, to = frames, out = o.out,
    setup = function(S)
      if o.clearCombatLock then kit.w16(0x09AE, kit.r16(0x09AE) & 0xFFF7) end -- disclosed poke: playerFlags bit 3 (combat lock) cleared
    end,
    sched = function(t)
      if t < 2 then return { "down" } end
      if o.btn and t >= (o.pressFrom or 32) and t <= (o.pressTo or 36) then return { o.btn } end
      return nil
    end,
    marks = {
      BIP = { 38113, function(S) if S.t >= 36 and S.t <= 40 then local st = emu.getState(); p4.emit(S, string.format("BIP t=%d A=%04X $0656=%04X X=%04X D=%04X", S.t, st["cpu.a"], kit.r16(0x0656), st["cpu.x"], st["cpu.d"])) end end },
      RMP = { 164183, function(S) if S.t >= 29 and S.t <= 32 then p4.emit(S, string.format("RMP t=%d remapped=%04X raw=%04X remapB=%04X held=%04X maskStd=%04X inject=%04X", S.t, kit.r16(0x065E), kit.r16(0x0660), kit.r16(0x0DAA), kit.r16(0x0658), kit.r16(0x065A), kit.r16(0x09AC))) end end },
      LJE = { 181790 }, LJL = { 181906 }, CLA = { 181948 }, CLB = { 181957 }, CLC = { 181966 }, DROPATK = { 181973 }, DROPLAND = { 182010, function(S) if o.freezeAtLand then kit.w16(0x06EE, kit.r16(0x06EE) | 0x0200); S.frz = S.t end end },   -- disclosed poke (freezeAtLand): layerPriorityFlag bit $0200 set at the landing
      CSA = { 182097, function(S) S.csaT = S.csaT or S.t end },
      CSF = { 182110, function(S) S.pre = { kit.r16(0x06BE), kit.r16(0x06C2) }; S.lpfAtCsf = S.lpfAtCsf or {}; S.lpfAtCsf[#S.lpfAtCsf + 1] = kit.r16(0x06EE) & 0x0200 end },
      CSR = { 182163, function(S)
          local dx, dy = p4.s16(kit.r16(0x06BE) - S.pre[1]), p4.s16(kit.r16(0x06C2) - S.pre[2])
          offs[#offs + 1] = dx .. "," .. dy
        end },
      CX = { 60246 }, CY = { 60290 }, SS = { 175150 }, UP = { 33671 },
    },
    rowfmt = function(t, c, S) return string.format("res=%d,%d jc=%04X jh=%04X mk=%04X rw=%04X", p4.s16(c.tx - c.ex_), p4.s16(c.ty - c.ey_), kit.r16(0x0656), kit.r16(0x0658), kit.r16(0x065A), kit.r16(0x0660)) end,
    collect = function(S) return { csaFirstT = S.csaT, shakeOffsets = table.concat(offs, " "), nOffs = #offs, lpf0200AtCsf = S.lpfAtCsf and table.concat(S.lpfAtCsf, "") or "" } end }
end
