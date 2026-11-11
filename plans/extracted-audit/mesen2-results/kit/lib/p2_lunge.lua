-- description: P2 OQ-I025-5: Will lunge (Ranged*) in all four directions on S10 (swing, then a fresh press of the facing direction), per-frame player position / flags / $09E0; variants 5-6 paint a solid wall in the path.
-- requires: mesen_kit, iog_kit, gaia_kit, p2_kit
--
-- ROM O offsets (decimal ; {n} tags, extracted/actors/player/player_character.asm): AttackSouth 183514, AttackNorth 183643, AttackWest 183772, AttackEast 183898,
--   RangedAttackSouth 184079, RangedAttackNorth 184089, RangedAttackWest 184104, RangedAttackEast 184119, lunge exit (TRB $0200) 184127, RangedSetForceX 184138, RangedSetForceY 184143.
--   tile_collision_physics.asm: CollisionY_Setup bounce test 250755-250777 (EOR $6000 on $12).
-- Slot $1000 = player actor: +$10 flags, +$12 flags (WRAM 0x1010 / 0x1012); extendedFlags $7F002A,X = WRAM 0x1102A; $09E0 abilityDamageBonus.
-- Variants 1-4: down, up, left, right, no paint. Variant 5: up with solid cells (value 0F) painted at rows 7, cols 11-13. Variant 6: right with cells painted at cols 13-14, rows 8-10.
p2lunge = {}

local DIRS = { "down", "up", "left", "right", "up", "right" }
local PAINT = {
  [5] = { cols = { 11, 12, 13 }, rows = { 7 } },
  [6] = { cols = { 13, 14 }, rows = { 8, 9, 10 } },
}

function p2lunge.go(frames, out)
  local function ev(name) return function(S, st, n) p2.ev(S, "t=%d %s pos=(%d,%d) f10=%04X f12=%04X ext=%04X $09E0=%d pf=%04X", S.t, name, kit.r16(0x1014), kit.r16(0x1016), kit.r16(0x1010), kit.r16(0x1012), kit.r16(0x1102A), kit.r16(0x09E0), kit.r16(0x09AE)) end end
  p2.run{ frames = frames, variants = 6, tag = "lunge", out = out or "P2_lunge.txt", show = 0,
    marks = {
      atkS = { 183514, ev("AttackSouth") }, atkN = { 183643, ev("AttackNorth") }, atkW = { 183772, ev("AttackWest") }, atkE = { 183898, ev("AttackEast") },
      rS = { 184079, ev("RangedAttackSouth") }, rN = { 184089, ev("RangedAttackNorth") }, rW = { 184104, ev("RangedAttackWest") }, rE = { 184119, ev("RangedAttackEast") },
      fX = { 184138, ev("RangedSetForceX") }, fY = { 184143, ev("RangedSetForceY") }, exit = { 184127, ev("lunge exit") },
      bounce = { 250765, ev("bounce flag cleared, $12 EOR $6000 next") },
    },
    vsetup = function(S, v)
      S.di = v; S.px, S.py = nil, nil
      return "lunge dir=" .. DIRS[v] .. (PAINT[v] and " painted-wall" or "")
    end,
    sched = function(t, S, v)
      local d = DIRS[S.di]
      if t >= 1 and t <= 3 then return { d } end
      if t == 12 or t == 13 then return { "b" } end
      if t >= 18 and t <= 70 then return { d } end -- a fresh press of the facing direction on the 6th tick after the attack press (N2 pressAt = 6)
      return nil
    end,
    tick = function(t, S, v)
      if t == 10 then
        local x, y = 200, 144
        for _, ty in ipairs({ 3, 4, 12, 13 }) do for tx = 1, 30 do gaia.coll.set(tx, ty, 0) end end
        local pn = PAINT[v]
        if pn then for _, ty in ipairs(pn.rows) do for _, tx in ipairs(pn.cols) do gaia.coll.set(tx, ty, 0x0F) end end end
        kit.w16(0x1014, x); kit.w16(0x1016, y); kit.w16(0x09A2, x - 8); kit.w16(0x09A4, y - 16)
        p2.ev(S, "t=10 poke actor=(%d,%d) form=%d; collision rows 3,4,12,13 cleared%s (disclosed)", x, y, kit.r16(0x0AD4), pn and "; wall cells painted" or "")
        S.px, S.py = x, y
      end
      if t >= 12 and t <= 75 then
        local x, y = kit.r16(0x1014), kit.r16(0x1016)
        p2.row(S, "t=%d pos=(%d,%d) d=(%d,%d) f10=%04X f12=%04X ext=%04X $09E0=%d pf=%04X anim=%04X", t, x, y, p2.s16(x - S.px), p2.s16(y - S.py), kit.r16(0x1010), kit.r16(0x1012), kit.r16(0x1102A), kit.r16(0x09E0), kit.r16(0x09AE), kit.r16(0x1028))
        S.px, S.py = x, y
      end
    end,
    writes = {
      { name = "f12", lo = 0x1012, hi = 0x1013 },   -- who sets the direction / bounce bits of the player's flags $12
      { name = "ext2A", lo = 0x1102A, hi = 0x1102B },
    },
    collect = function(S, v) return { dir = DIRS[S.di], endx = kit.r16(0x1014), endy = kit.r16(0x1016) } end,
  }
end
