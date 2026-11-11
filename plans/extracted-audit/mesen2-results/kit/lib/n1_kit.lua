-- description: N1 NPC and actor behaviour experiments: per-slot ring recorder (n1.track / n1.dump), live-actor listing, teleport, face, interact helpers on top of m1_kit.
-- requires: mesen_kit, iog_kit, gaia_kit, m1_kit
--
--   n1.live()                 list of live slots from $56 (+6 links)
--   n1.rows(filterFn)         one line per live slot: slot ent(rom offset, decimal) f10 f12 x y a28 w08 (m1.log)
--   n1.at(x, y, tol)          first live slot (not the player) whose actor position is within tol px of (x, y)
--   n1.track(slot)            record that slot every frame (ent, +08, +10, +12, +14, +16, +28, +2A, chatPtr)
--   n1.dump(slot, f0, f1)     m1.log the recorded changes of the slot between recorder frames f0..f1 (all when nil)
--   n1.teleport(x, y)         set the player actor position (actor $1014/$1016) and the player copy ($09A2/$09A4 = actor - 8 / - 16)
--   n1.face(dir, frames)      hold up/down/left/right (names) for frames
--   n1.interact()             press A (physical A = logical interact bit $0080) for 2 frames
--   n1.rom(ent)               24-bit mirrored entry address -> ROM file offset
-- Recorder frames are NMI frames counted by the recorder itself (n1.t increments once per end-of-frame callback).
n1 = n1 or {}

n1.t = 0
n1.rec = {}
n1.names = {}

local FIRST, LAST, STRIDE = 0x1000, 0x1F90, 0x30

function n1.rom(ent) return (((ent >> 16) & 0x3F) << 16) | (ent & 0xFFFF) end
function n1.ent(s) return kit.r16(s) | (kit.r8(s + 2) << 16) end

function n1.live()
  local out, s, k = {}, kit.r16(0x56), 0
  while s ~= 0 and k < 120 do out[#out + 1] = s; s = kit.r16(s + 6); k = k + 1 end
  return out
end

function n1.rows(filter)
  for _, s in ipairs(n1.live()) do
    local e = n1.ent(s)
    if not filter or filter(s, e) then
      m1.log("slot=%04X ent=%d f10=%04X f12=%04X x=%d y=%d a28=%04X w08=%04X ch=%04X", s, n1.rom(e), kit.r16(s + 0x10), kit.r16(s + 0x12),
        kit.r16(s + 0x14), kit.r16(s + 0x16), kit.r16(s + 0x28), kit.r16(s + 8), kit.r16(0x1000A + s - 0))
    end
  end
end

function n1.at(x, y, tol)
  tol = tol or 24
  for _, s in ipairs(n1.live()) do
    if s ~= FIRST then
      local ax, ay = kit.r16(s + 0x14), kit.r16(s + 0x16)
      if math.abs(ax - x) <= tol and math.abs(ay - y) <= tol then return s end
    end
  end
  return nil
end

function n1.tracking(slot) return n1.rec[slot] ~= nil end

function n1.track(slot)
  if not n1.rec[slot] then n1.rec[slot] = { slot = slot, n = 0 } end
end

local function sample()
  n1.t = n1.t + 1
  for slot, r in pairs(n1.rec) do
    local k = r.n + 1
    if k <= 6000 then
      r.n = k
      r[k] = {
        n1.t, kit.r16(0x36), n1.rom(n1.ent(slot)), kit.r16(slot + 8), kit.r16(slot + 0x10), kit.r16(slot + 0x12),
        kit.r16(slot + 0x14), kit.r16(slot + 0x16), kit.r16(slot + 0x28), kit.r16(slot + 0x2A), kit.r16(0x1000A + slot),
        kit.r16(slot + 6),
      }
    end
  end
end
kit.onFrame(sample)

-- fields: 1 t, 2 $36, 3 ent(rom), 4 +08, 5 +10, 6 +12, 7 x, 8 y, 9 +28, 10 +2A, 11 chatPtr, 12 +06 link
function n1.dump(slot, f0, f1, o)
  o = o or {}
  local r = n1.rec[slot]
  if not r then m1.log("no recording for slot %04X", slot); return end
  local prev, w0, wl, wn = nil, nil, nil, 0
  local function flushWait()
    if wn > 0 then m1.log("      (+08 runs %04X..%04X over %d frames)", w0, wl, wn); wn = 0 end
  end
  for k = 1, r.n do
    local v = r[k]
    if (not f0 or v[1] >= f0) and (not f1 or v[1] <= f1) then
      local changed = true
      if prev then
        changed = v[3] ~= prev[3] or v[5] ~= prev[5] or v[6] ~= prev[6] or v[7] ~= prev[7] or v[8] ~= prev[8]
          or (not o.ignoreAnim and (v[9] ~= prev[9])) or v[11] ~= prev[11] or v[12] ~= prev[12]
        if not changed and v[4] ~= prev[4] then
          -- only the wait counter changed: collapse
          if wn == 0 then w0 = v[4] end
          wl = v[4]; wn = wn + 1
          prev = v
          goto continue
        end
      end
      if changed then
        flushWait()
        m1.log("t=%d $36=%04X ent=%d +08=%04X f10=%04X f12=%04X x=%d y=%d a28=%04X a2A=%04X ch=%04X lnk=%04X", v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10], v[11], v[12])
      end
      prev = v
    end
    ::continue::
  end
  flushWait()
end

function n1.teleport(x, y)
  kit.w16(0x1014, x); kit.w16(0x1016, y)
  kit.w16(0x09A2, x - 8); kit.w16(0x09A4, y - 16)
end

function n1.face(dir, frames) m1.press({ dir }, frames or 4) end

function n1.interact(btn) m1.press({ btn or "b" }, 2) end -- ROM O: interact = physical B ($8000); R build: physical A

-- hex formatting helpers
function n1.h4(v) return string.format("%04X", v) end
