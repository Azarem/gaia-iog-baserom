-- description: Campaign A actor helpers: live-list walk, flag set/clear, HP, change tracker, motion counter, actor finders.
-- requires: gaia_kit
--
-- Use:  run_script{ includes={"a_census","a_actors"}, frames=N, turbo=true, code="... aact.inList(s) ..." }
--
-- All addresses are WRAM offsets. Actor slot k (84 slots) is at 0x1000 + 0x30*k (see docs/wram-memory-map.md section 2.11).
--
-- Facts the helpers rely on (Campaign A, A4):
--   * A freed slot is NOT cleared (InitActorPool / UnlinkActor only relink it), so "entry word ~= 0" counts dead actors.
--     A live actor is one that can be reached from the list head $56 through +6 (nextActorLink): use aact.inList / aact.live.
--   * The entry bank byte (+2) is the HiROM mirror: ROM bank $08 reads $88, $0A -> $8A, $00 -> $80, $03 -> $83.
--   * Extended fields are addressed with the actor id as the X index: $7F0026,X with X = slot is kit.r16(0x10026 + slot).
aact = aact or {}

local FIRST, LAST, STRIDE = 0x1000, 0x1F90, 0x30
aact.FIRST, aact.LAST, aact.STRIDE = FIRST, LAST, STRIDE

-- 24-bit entry address (word + mirrored bank byte)
function aact.ent(s) return kit.r16(s) | (kit.r8(s + 2) << 16) end

-- extended-field helpers
function aact.hp(s) return kit.r16(0x10026 + s) end
function aact.iframes(s) return kit.r16(0x10028 + s) end

-- forced-bit helpers (off = offset in the slot: 0x10 = Flags10, 0x12 = Flags12)
function aact.setf(s, off, mask) kit.w16(s + off, kit.r16(s + off) | mask) end
function aact.clrf(s, off, mask) kit.w16(s + off, kit.r16(s + off) & ~mask) end

-- true when slot t is reachable from the list head $56 through +6 (bounded walk)
function aact.inList(t)
  local s, k = kit.r16(0x56), 0
  while s ~= 0 and k < 120 do
    if s == t then return true end
    s = kit.r16(s + 6); k = k + 1
  end
  return false
end

-- array of the slots in the actor list, in list order
function aact.live()
  local out, s, k = {}, kit.r16(0x56), 0
  while s ~= 0 and k < 120 do
    out[#out + 1] = s
    s = kit.r16(s + 6); k = k + 1
  end
  return out
end

-- first live slot (skipping the player) whose entry is in [lo, hi]; nil when none
function aact.findEntry(lo, hi)
  for _, s in ipairs(aact.live()) do
    if s ~= FIRST then
      local e = aact.ent(s)
      if e >= lo and e <= hi then return s end
    end
  end
  return nil
end

-- Change tracker. Logs, after `from`, every slot whose entry changes (NEW line) and every change of Flags10/Flags12 on a
-- watched slot (CHG line). `emit(line)` receives each line. Call tr.snapshot() once at `from`, then tr.scan(n) every frame.
function aact.tracker(from, emit)
  local prev, last10, last12, watch = {}, {}, {}, {}
  local tr = {}
  function tr.snapshot()
    for s = FIRST, LAST, STRIDE do prev[s] = aact.ent(s) end
  end
  function tr.watch(s) watch[s] = true; last10[s], last12[s] = kit.r16(s + 0x10), kit.r16(s + 0x12) end
  function tr.scan(n)
    for s = FIRST, LAST, STRIDE do
      local e = aact.ent(s)
      if e ~= prev[s] then
        prev[s] = e
        if n > from then
          watch[s] = true
          emit(string.format('%d NEW slot=%04X ent=%06X f10=%04X f12=%04X x=%d y=%d hp=%d', n, s, e, kit.r16(s + 0x10), kit.r16(s + 0x12), kit.r16(s + 0x14), kit.r16(s + 0x16), aact.hp(s)))
          last10[s], last12[s] = kit.r16(s + 0x10), kit.r16(s + 0x12)
        end
      elseif watch[s] then
        local a, b = kit.r16(s + 0x10), kit.r16(s + 0x12)
        if a ~= last10[s] or b ~= last12[s] then
          emit(string.format('%d CHG slot=%04X f10 %04X>%04X f12 %04X>%04X ent=%06X hp=%d', n, s, last10[s] or 0, a, last12[s] or 0, b, e, aact.hp(s)))
          last10[s], last12[s] = a, b
        end
      end
    end
  end
  return tr
end

-- Motion counter over the LIVE list (not over slots ever used). Returns a function; each call returns
-- moved, filtered (actors with $12 bit 12), live, movedNotFiltered, comparing against the previous call.
function aact.motion()
  local lastpos = {}
  return function()
    local moved, filt, movedNF, count = 0, 0, 0, 0
    local seen = {}
    for _, s in ipairs(aact.live()) do
      if s ~= FIRST then
        seen[s] = true
        count = count + 1
        local x, y = kit.r16(s + 0x14), kit.r16(s + 0x16)
        local p = lastpos[s]
        local isf = kit.r16(s + 0x12) & 0x1000 ~= 0
        if p and (p[1] ~= x or p[2] ~= y) then moved = moved + 1; if not isf then movedNF = movedNF + 1 end end
        lastpos[s] = { x, y }
        if isf then filt = filt + 1 end
      end
    end
    for s in pairs(lastpos) do if not seen[s] then lastpos[s] = nil end end
    return moved, filt, count, movedNF
  end
end
