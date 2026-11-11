-- description: FR23 area-trial helpers on top of fr22_kit (Angel Village / Watermia / Euro trials): actor lookup by entry pc, talk bot, tile walker.
-- requires: fr22_kit
--
-- Load with run_script includes=["fr23_kit"] (the server resolves "requires": fr22_kit, fr21_kit, fr20_kit, gaia_kit, mesen_kit, iog_kit).
-- Nothing here writes the low direct page ($00-$94). Writes use emu.write (they do not fire memory callbacks).
--
--   fr23.count(lo, hi)        number of live actors (list walk from $56) whose entry pc low word is in [lo, hi]
--   fr23.talker{ {n=, x=, y=, dir=, len=, btn=}, ... }   returns an onSample(R, n) (use through fr22.drive `every`): at settle frame n teleport the player
--        actor to (x, y) (actor position words $1014/$1016), hold `dir` ("up" default) for 6 frames to face it, then press {btn or "b", dir} for 2 frames
--        every 14 frames up to n+len (default 120) while no dialog window is open; fr22.adv presses physical B while a dialog window is up.
--        With `find = {pcLo, pcHi}` the target is the first live actor whose entry pc is in that range: the player goes to (actor x + dx, actor y + dy) (default 0, 16).
--        R.talk[#] = { n, step, tile } records the player tile at the teleport.
--   fr23.walkTo(R, n, tx, ty)  one step of a tile walker toward tile (tx, ty)
--   fr23.cur(R)               the dialog state: R.dlgRows gets {n, dlg, mask} on every change of the dialog window flag
fr23 = fr23 or {}

function fr23.count(lo, hi)
  local c = 0
  for _, a in ipairs(fr20.actors()) do
    if a.pc >= lo and a.pc <= hi then c = c + 1 end
  end
  return c
end

function fr23.talker(steps)
  return function(R, n)
    for i, t in ipairs(steps) do
      local dir = t.dir or "up"
      if n == t.n then
        local tx, ty = t.x, t.y
        if t.find then
          local a = fr21.find(t.find[1], t.find[2])
          if a then tx, ty = a.x + (t.dx or 0), a.y + (t.dy or 16) end
        end
        fr21.pos(tx, ty)
        R.talk = R.talk or {}
        R.talk[#R.talk + 1] = { n = n, step = i, tile = { kit.r16(0x09A6), kit.r16(0x09A8) } }
      end
      if n > t.n and n <= t.n + 6 then fr21.press(R, { dir })
      elseif n > t.n + 6 and n <= t.n + (t.len or 120) and not fr22.dlg() and ((n - t.n - 7) % 14) < 2 then
        fr21.press(R, { t.btn or "b", dir })
      end
    end
  end
end

function fr23.walkTo(R, n, tx, ty)
  local cx, cy = kit.r16(0x09A6), kit.r16(0x09A8)
  if cx == tx and cy == ty then R.arrived = R.arrived or n; return true end
  local t = {}
  if cx < tx then t.right = true elseif cx > tx then t.left = true end
  if cy < ty then t.down = true elseif cy > ty then t.up = true end
  R.heldNow = t
  return false
end

-- fr23.seq(steps): returns an onSample(R, n) that runs a list of talk steps in order. A step:
--   { wait = function() ... end   start condition (default: immediately after the previous step)
--     find = {pcLo, pcHi}         target actor by entry pc (or x, y = the player actor position to teleport to)
--     dx, dy                      offset from the actor position (default 0, 16)
--     dir                         direction held to face the target (default "up")
--     btn                         button pressed with the direction (default "b" = physical B, the talk button of this ROM)
--     done = function() ... end   ends the step when true and no dialog window is up
--     pre = function() ... end    run once at the teleport
--     pdir                        direction held with the button (default = dir)
--     findMax                     frames to keep looking for the target actor (default 300)
--     nodlg                       ignore the dialog-window flag (scenes where $09EC bit $2000 stays set)
--     max                         frames before the step is abandoned (default 600) }
-- R.seq = { {step, n, how}, ... } records the frame at which each step started and ended (how = "done" | "timeout").
function fr23.seq(steps)
  local idx, t0 = 1, nil
  return function(R, n)
    local st = steps[idx]
    if not st then return end
    R.seq = R.seq or {}
    if not t0 then
      if st.wait and not st.wait() then return end
      local tx, ty = st.x, st.y
      if st.find then
        local a = fr21.find(st.find[1], st.find[2])
        if a then tx, ty = a.x + (st.dx or 0), a.y + (st.dy or 16)
        else
          st.nf = (st.nf or 0) + 1
          if st.nf > (st.findMax or 300) then R.seq[#R.seq + 1] = { step = idx, n = n, how = "notfound" }; idx = idx + 1 end
          return
        end
      end
      t0 = n
      if st.pre then st.pre() end
      fr21.pos(tx, ty)
      R.seq[#R.seq + 1] = { step = idx, n = n, how = "start", at = { tx, ty } }
      return
    end
    local k, dir = n - t0, st.dir or "up"
    if k >= 1 and k <= 6 then fr21.press(R, { dir })
    elseif k > 6 and (st.nodlg or not fr22.dlg()) and ((k - 7) % 14) < 2 and not (st.done and st.done()) then fr21.press(R, { st.btn or "b", st.pdir or dir }) end
    if (st.done and st.done() and (st.nodlg or not fr22.dlg()) and k > 8) or k > (st.max or 600) then
      R.seq[#R.seq + 1] = { step = idx, n = n, how = (st.done and st.done()) and "done" or "timeout" }
      idx = idx + 1
      t0 = nil
    end
  end
end
