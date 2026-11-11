-- description: FR21 area-trial helpers on top of fr20_kit: item pokes (inventory slot + equip), player tile read/teleport, change-only recorder, scripted one-frame presses.
-- requires: fr20_kit
--
-- Load with run_script includes=["fr21_kit"] (the server resolves "requires": fr20_kit, gaia_kit, mesen_kit, iog_kit).
-- Nothing here writes the low direct page ($00-$94). Flag and item pokes use emu.write (they do not fire memory callbacks).
--
--   fr21.tile()                  playerXTile, playerYTile ($09A6, $09A8 words)
--   fr21.item(id, slot)          inventorySlots[slot] = id ($0AB4+slot), inventoryEquippedIndex $0AC4 = slot, inventoryEquippedType $0AC6 = id
--                                (ItemUseDispatch reads only the index and the slot byte; the type is HUD data)
--   fr21.pos(x, y)               player actor position words $1014/$1016
--   fr21.press(R, {"y"})         buttons for the next input poll only (R.heldNow, consumed by fr20.visit's inputPolled callback)
--   fr21.drive{ rec, at, every } returns an onSample(R, n) for fr20.visit:
--        rec    { {name=, addr=, size=1|2, bit=mask}, ... }  change-only recorder -> R.rec rows {n=, <name>=value} (150 rows max, bit = mask gives 0/1)
--        at     { [n] = function(R, n) ... end }              actions at settle frame n
--        every  function(R, n)                                called every settle frame after `at`
--   fr21.inv()                   the 16 inventory slot bytes as one hex string
--   fr21.dlgOpen()               true while a dialog window is up (the BG3 text window flag of the engine is not decoded: returns joypadMaskStd and displayModeFlags instead)
fr21 = fr21 or {}

function fr21.tile() return kit.r16(0x09A6), kit.r16(0x09A8) end

function fr21.item(id, slot)
  slot = slot or 0
  kit.w8(0x0AB4 + slot, id)
  kit.w16(0x0AC4, slot)
  kit.w16(0x0AC6, id)
end

function fr21.pos(x, y)
  kit.w16(0x1014, x)
  kit.w16(0x1016, y)
end

function fr21.press(R, btns)
  local t = {}
  for _, b in ipairs(btns) do t[b] = true end
  R.heldNow = t
end

-- first live actor whose entry pc (low word, the re-entry address updated by SetEntryHere) is in [pc, hi] (hi defaults to pc), or nil
function fr21.find(pc, hi)
  hi = hi or pc
  for _, a in ipairs(fr20.actors()) do
    if a.pc >= pc and a.pc <= hi then return a end
  end
  return nil
end

-- currentHp word ($7F0026,X) of an actor slot (work RAM offset 0x10026 + slot)
function fr21.hp(slot) return emu.read16(0x10026 + slot, emu.memType.snesWorkRam, false) end

-- adaptive bot for fr20.visit's `every`: presses o.dlg (default physical B, 2 frames every o.gap = 12) while a dialog is open (displayModeFlags $2000),
-- and once the player is free (joypadMaskStd = 0, no dialog) for o.free = 20 frames after settle frame o.minN = 60 pokes item o.item and presses o.btn
-- (default physical Y = item use) on frames used+3..used+5. R.used = settle frame of the poke. Pass `extra` to run more code each frame.
function fr21.auto(o)
  return function(R, n)
    local mask, dmf = kit.r16(0x065A), kit.r16(0x09EC)
    local dlg = (dmf & 0x2000) ~= 0
    if dlg and n % (o.gap or 12) < 2 then fr21.press(R, { o.dlg or 'b' }) end
    if (not dlg) and (o.anymask or mask == 0) and n > (o.minN or 60) then R.free = (R.free or 0) + 1 else R.free = 0 end
    if o.item and not R.used and R.free >= (o.free or 20) then
      R.used = n
      fr21.item(o.item, 0)
    end
    if R.used and n >= R.used + 3 and n <= R.used + 5 then fr21.press(R, { o.btn or 'y' }) end
    -- o.repeatEvery: press o.btn again for 3 frames every that many frames after the first press, while the player is free (mask 0, no dialog)
    if R.used and o.repeatEvery and n > R.used + 5 and mask == 0 and (not dlg) and ((n - R.used) % o.repeatEvery) < 3 then fr21.press(R, { o.btn or 'y' }) end
    if o.extra then o.extra(R, n) end
  end
end

function fr21.inv()
  local t = {}
  for i = 0, 15 do t[#t + 1] = string.format("%02X", kit.r8(0x0AB4 + i)) end
  return table.concat(t)
end

function fr21.drive(o)
  local last = {}
  return function(R, n)
    R.rec = R.rec or {}
    if o.rec then
      local row, changed = { n = n }, false
      for _, s in ipairs(o.rec) do
        local v = (s.size == 2) and kit.r16(s.addr) or kit.r8(s.addr)
        if s.bit then v = ((v & s.bit) ~= 0) and 1 or 0 end
        if last[s.name] ~= v then
          last[s.name] = v
          row[s.name] = v
          changed = true
        end
      end
      if changed and #R.rec < 150 then R.rec[#R.rec + 1] = row end
    end
    local a = o.at and o.at[n]
    if a then a(R, n) end
    if o.every then o.every(R, n) end
  end
end
