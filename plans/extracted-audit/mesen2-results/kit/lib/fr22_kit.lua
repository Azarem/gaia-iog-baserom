-- description: FR22 area-trial helpers on top of fr21_kit/fr20_kit (Mu / Seaside Palace / Diamond Mine / Sky Garden / Great Wall trials).
-- requires: fr21_kit
--
-- Load with run_script includes=["fr22_kit"] (the server resolves "requires": fr21_kit, fr20_kit, gaia_kit, mesen_kit, iog_kit).
-- Nothing here writes the low direct page ($00-$94). Writes use emu.write (they do not fire memory callbacks).
--
--   fr22.dlg()                     true while a dialog window is up (displayModeFlags $09EC bit $2000)
--   fr22.light(skip)               actors of the live list as light rows {slot, bank, pc, x, y, f10, f12, wait, chat}
--   fr22.adv(R, n, gap)            press physical B for 2 frames every `gap` (default 12) frames while a dialog window is up
--   fr22.drive{ rec, at, use, snaps, adv, gap, every }  returns an onSample(R, n) for fr20.visit:
--        rec    change-only recorder rows (as fr21.drive)
--        at     { [n] = function(R, n) ... end }
--        use    { {n=40, x=, y=, item=0x12, slot=0, btn='y', hold=3}, ... }: at settle frame n teleport the player actor to (x, y) when
--               given, poke the item into slot, and press the button on frames n+3 .. n+3+hold-1 (physical Y = item use); R.useRows
--               records the player tile two frames after the poke
--        snaps  { n, ... }: R.snap[n] = fr22.light() at those settle frames
--        adv    false disables the dialog advance (default on)
--        every  function(R, n) called every settle frame after the rest
fr22 = fr22 or {}

function fr22.dlg() return (kit.r16(0x09EC) & 0x2000) ~= 0 end

function fr22.light()
  local out = {}
  for _, a in ipairs(fr20.actors()) do
    out[#out + 1] = { slot = a.slot, bank = a.bank, pc = a.pc, x = a.x, y = a.y, f10 = a.f10, f12 = a.f12, wait = a.wait, chat = a.chat }
  end
  return out
end

function fr22.adv(R, n, gap)
  if fr22.dlg() and (n % (gap or 12)) < 2 then fr21.press(R, { "b" }) end
end

function fr22.drive(o)
  local base = fr21.drive{ rec = o.rec, at = o.at }
  local uses = o.use or {}
  local snaps = {}
  for _, n in ipairs(o.snaps or {}) do snaps[n] = true end
  return function(R, n)
    if o.adv ~= false then fr22.adv(R, n, o.gap) end
    for _, u in ipairs(uses) do
      if n == u.n then
        if u.x then fr21.pos(u.x, u.y) end
        fr21.item(u.item, u.slot or 0)
      end
      if n == u.n + 2 then
        R.useRows = R.useRows or {}
        R.useRows[#R.useRows + 1] = { n = n, tile = { fr21.tile() }, p09A2 = { kit.r16(0x09A2), kit.r16(0x09A4) }, mask = kit.r16(0x065A), dlg = fr22.dlg() }
      end
      if n >= u.n + 3 and n < u.n + 3 + (u.hold or 3) then fr21.press(R, { u.btn or "y" }) end
    end
    if snaps[n] then R.snap = R.snap or {}; R.snap[tostring(n)] = fr22.light() end
    base(R, n)
    if o.every then o.every(R, n) end
  end
end
