-- description: G2 static decode of ROM tables read through prgRom: enemy stats rows, scene actor lists (enemy-spawn records), clear-reward tiers, boss ranges. No emulation needed (frames=0 or 1).
-- requires: mesen_kit, iog_kit, gaia_kit
--
-- ROM O offsets (decimal keys of the db files): stats table 109552 ($01:ABF0, 110 rows x 4), enemy_clear_reward_table 109278 (256 bytes),
-- scene_actors pointer table 819200 (256 words; record = 0xC0000 + word), boss_reward_range_table: located by the caller (ROM offset passed in).
g2s = g2s or {}
local P = emu.memType.snesPrgRom
local function rb(o) return emu.read(o, P) end
local function rw(o) return rb(o) | (rb(o + 1) << 8) end

function g2s.stats()
  local rows = {}
  for r = 0, 109 do
    local o = 109552 + r * 4
    rows[r] = { hp = rb(o), atk = rb(o + 1), def = rb(o + 2), gem = rb(o + 3) }
  end
  return rows
end

function g2s.tiers()
  local t = {}
  for s = 0, 255 do t[s] = rb(109278 + s) end
  return t
end

-- enemy-spawn records of a scene: stats index (byte 6, nonzero), enemy number (byte 7), event-block index (byte 8)
function g2s.scene(s)
  local p = 0xC0000 + rw(819200 + s * 2)
  local list, n = {}, 0
  while n < 200 do
    local x = rb(p)
    if x == 0xFF then break end
    local y, attr = rb(p + 1), rb(p + 2)
    local ptr, bank = rw(p + 3), rb(p + 5)
    local st = rb(p + 6)
    if st ~= 0 then
      list[#list + 1] = { x = x, y = y, ptr = ptr, bank = bank, st = st, en = rb(p + 7), ev = rb(p + 8) }
      p = p + 9
    else
      p = p + 7
    end
    n = n + 1
  end
  return list
end

-- boss rows (4 bytes: scene, first, last, pad) at ROM offset `off` (the table is not named in the db; the caller resolves it)
function g2s.bossRows(off, n)
  local out = {}
  for i = 0, n - 1 do out[i] = { rb(off + i * 4), rb(off + i * 4 + 1), rb(off + i * 4 + 2) } end
  return out
end
