-- description: P2 OQ-I071-1/-2: the Shadow Aura item (UseItem_Aura) on S12: per-tick anim index ($28), body row ($0AC8), playerFlags, entry pointer of the player actor, and the writers of $28 / $0AC8.
-- requires: mesen_kit, iog_kit, gaia_kit, p2_kit
--
-- ROM O offsets (decimal ; {n}): UseItem_Aura 236719, PlayerAuraTransformEntry 50519 (SetPlayerSpriteDirect #08 at 50535), PlayerAuraBlockedBySolid / PlayerAuraLandAnimLoop / PlayerAuraTransformExit: see the report (found by rg in extracted/).
-- Disclosed pokes (the same as W1-f f_shadow_aura): $0AB6 word = $2400 (inventory slot 3 = item $24), $0AC4 = 3 (equipped slot), at t=3. The use is then a physical Y (logical item bit $4000 is fed by physical Y) while the player stands still.
p2ai = {}

function p2ai.go(frames, out, paint)
  local function ev(name) return function(S, st, n) p2.ev(S, "t=%d %s pos=(%d,%d) anim=%04X row=%04X pf=%04X entry=%04X:%02X", S.t, name, kit.r16(0x1014), kit.r16(0x1016), kit.r16(0x1028), kit.r16(0x0AC8), kit.r16(0x09AE), kit.r16(0x1000), kit.r8(0x10002)) end end
  p2.run{ frames = frames, variants = 1, tag = "auraitem", out = out or "P2_auraitem.txt", show = 0,
    marks = {
      useItem = { 236719, ev("UseItem_Aura") },
      entry = { 50519, ev("PlayerAuraTransformEntry") },
      spsd8 = { 50535, ev("SetPlayerSpriteDirect #08 about to run") },
      blocked = { 50572, ev("PlayerAuraBlockedBySolid") },
      descend = { 50593, ev("PlayerAuraDescendToFloor") },
      land = { 50625, ev("PlayerAuraLandOnSolid") },
      loopPass = { 50635, ev("PlayerAuraLandAnimLoop pass") },
      landDone = { 50648, ev("PlayerAuraLandComplete") },
      exit = { 50659, ev("PlayerAuraTransformExit") },
    },
    vsetup = function(S, v) return "shadow aura item" end,
    sched = function(t, S, v)
      if t >= 12 and t <= 14 then return { "y" } end
      return nil
    end,
    tick = function(t, S, v)
      if t == 3 then
        kit.w16(0x0AB6, 0x2400); kit.w16(0x0AC4, 3)
        p2.ev(S, "t=3 poke $0AB6=%04X $0AC4=%d form=%d (disclosed)", kit.r16(0x0AB6), kit.r16(0x0AC4), kit.r16(0x0AD4))
        if paint then
          -- terrain type $04 cells in row 13 (the row below the first solid row 12) and open cells in row 14, columns 4-6 (disclosed), to take the sink / landing path
          for tx = 4, 6 do gaia.coll.set(tx, 13, 0x04); gaia.coll.set(tx, 14, 0x00) end
          p2.ev(S, "t=3 collision cells (4..6,13)=04 and (4..6,14)=00 painted (disclosed)")
        end
      end
      if t >= 8 and t <= 400 then
        local a, row = kit.r16(0x1028), kit.r16(0x0AC8)
        if a ~= S.la or row ~= S.lr then
          p2.row(S, "t=%d anim=%04X row=%04X pf=%04X pos=(%d,%d) f10=%04X f12=%04X", t, a, row, kit.r16(0x09AE), kit.r16(0x1014), kit.r16(0x1016), kit.r16(0x1010), kit.r16(0x1012))
          S.la, S.lr = a, row
        end
      end
    end,
    writes = {
      { name = "anim1028", lo = 0x1028, hi = 0x1028, cond = function(a, v) return kit.r16(0x0AD4) == 2 end },
      { name = "body0AC8", lo = 0x0AC8, hi = 0x0AC9 },
    },
    collect = function(S, v) return { x = kit.r16(0x1014), y = kit.r16(0x1016), anim = kit.r16(0x1028), row = kit.r16(0x0AC8) } end,
  }
end
