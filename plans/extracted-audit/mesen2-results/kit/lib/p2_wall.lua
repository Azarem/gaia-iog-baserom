-- description: P2 OQ-I025-4: Freedan wall-push sprite choice in AttackSouth / AttackNorth (BranchIfSolidSouth + BranchIfSolidOffset), one painted collision cell per variant.
-- requires: mesen_kit, iog_kit, gaia_kit, p2_kit
--
-- ROM O offsets (decimal ; {n} tags of extracted/actors/player/player_character.asm): AttackSouth BranchIfSolidSouth 183531, BranchIfSolidOffset 183543, wall sprite #48 183551, normal #36 183556;
-- AttackNorth BranchIfSolidSouth 183660, BranchIfSolidOffset 183672, wall sprite #49 183680, normal #37 183685.
-- Disclosed pokes: actor position and the 09A2/09A4 copy at t=10 (after the facing taps); ONE collision cell painted (value 01) from the exec callback of the first probe until the sprite is staged, then restored.
p2wall = {}

local DIRS = { "up", "down" }
-- case: {x, dc, dr}  (dc, dr = painted cell relative to (x & ~15) >> 4, y >> 4); nil = no paint
local CASES = {
  { 200, nil },        -- 1 no paint
  { 200, { 0, 0 } },   -- 2 the cell of the actor's own column and row
  { 200, { 0, 1 } },   -- 3 one row below the actor's row
  { 200, { 0, -1 } },  -- 4 one row above
  { 204, { 1, 0 } },   -- 5 unaligned X, column to the right, actor's row (BranchIfSolidOffset #01,#01 target)
  { 204, { 1, -2 } },  -- 6 unaligned X, column to the right, two rows above (BranchIfSolidOffset #01,#FF target)
}

function p2wall.go()
  local function pre(S, st, name)
    local c = S.case
    local x, y = kit.r16(0x1014), kit.r16(0x1016)
    if c[2] and not S.paint then
      local tx, ty = ((x & 0xFFF0) >> 4) + c[2][1], (y >> 4) + c[2][2]
      S.paint = { tx = tx, ty = ty, old = gaia.coll.get(tx, ty) }
      gaia.coll.set(tx, ty, 0x01)
    end
    p2.ev(S, "t=%d %s actor=(%d,%d) $09A2=%d paint=%s old=%s", S.t, name, x, y, kit.r16(0x09A2), S.paint and string.format("(%d,%d)", S.paint.tx, S.paint.ty) or "none", S.paint and string.format("%02X", S.paint.old) or "-")
  end
  local function post(S, st, name)
    p2.ev(S, "t=%d %s anim=%04X f28=%04X", S.t, name, kit.r16(0x1028), kit.r16(0x1028))
    S.result = name
    if S.paint then gaia.coll.set(S.paint.tx, S.paint.ty, S.paint.old); S.paint = nil end
  end
  local function off(S, st, name) p2.ev(S, "t=%d %s reached (BranchIfSolidOffset about to run)", S.t, name) end
  p2.run{ frames = 40, variants = 12, tag = "wall", out = "P2_wall.txt", show = 0,
    marks = {
      S_pre = { 183531, pre }, N_pre = { 183660, pre },
      S_off = { 183543, off }, N_off = { 183672, off },
      S_wall = { 183551, post }, S_norm = { 183556, post }, N_wall = { 183680, post }, N_norm = { 183685, post },
    },
    vsetup = function(S, v)
      S.paint = nil; S.result = nil
      S.di = (v - 1) // 6; S.case = CASES[(v - 1) % 6 + 1]
      return string.format("dir=%s x=%d paint=%s", DIRS[S.di + 1], S.case[1], S.case[2] and string.format("(%d,%d)", S.case[2][1], S.case[2][2]) or "none")
    end,
    sched = function(t, S, v)
      if t >= 1 and t <= 3 then return { DIRS[S.di + 1] } end
      if t >= 12 and t <= 14 then return { "b" } end
      return nil
    end,
    tick = function(t, S, v)
      if t == 10 then
        local x, y = S.case[1], 144
        kit.w16(0x1014, x); kit.w16(0x1016, y); kit.w16(0x09A2, x - 8); kit.w16(0x09A4, y - 16)
        p2.ev(S, "t=10 poke actor=(%d,%d) form=%d facing/anim=%04X pf=%04X", x, y, kit.r16(0x0AD4), kit.r16(0x1028), kit.r16(0x09AE))
      end
    end,
    collect = function(S, v) return { dir = DIRS[S.di + 1], x = S.case[1], paint = S.paint and "unrestored" or "ok", result = S.result } end,
  }
end
