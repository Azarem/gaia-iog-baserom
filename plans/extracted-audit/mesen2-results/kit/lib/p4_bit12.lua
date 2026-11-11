-- description: P4 run file: actor $12 bit 12 ($1000) as the display-filter qualifier (OQ-57 (c)): optionally sets displayModeFlags bit 7 ($09EC |= $0080, disposable poke), holds a direction and counts which RunActors variant runs, whether the camera controller (bit 12 set in $12) and the player (bit 12 clear) execute, and how far the player moves.
-- requires: mesen_kit, iog_kit, gaia_kit, p4_kit
-- p4b12.go{ out = "P4_x.txt", frames = 40, filter = true | false, hold = {"right"} }
p4b12 = p4b12 or {}
function p4b12.go(o)
  local frames = o.frames or 40
  local R = { x0 = nil }
  p4.run{ frames = frames, out = o.out, from = 1, to = 3,
    setup = function(S)
      if o.filter then kit.w16(0x09EC, kit.r16(0x09EC) | 0x0080) end   -- disclosed poke: displayModeFlags bit 7
      R.dmf0 = kit.r16(0x09EC)
      R.x0, R.y0 = kit.r16(0x1014), kit.r16(0x1016)
      -- the camera controller slot: first live slot whose $12 has bit 12 and whose entry is the controller's; report $12 of the player and of the controller by scanning the list
    end,
    sched = function(t) return o.hold end,
    marks = {
      RN  = { 248565 },   -- RunActors_Normal entry
      RDF = { 248739 },   -- RunActors_DisplayFiltered entry
      CX  = { 60246 },    -- camera_scroll_controller target X store (the controller ran)
      DFS = { 248762 },   -- RunActors_DisplayFiltered: an actor passed the bit-12 test
      DFK = { 248760 },   -- RunActors_DisplayFiltered: the BEQ that skips an actor (counts every actor tested after the BIT on $12)
    },
    rowfmt = function(t, c, S) return string.format("dmf=%04X f12(player)=%04X", kit.r16(0x09EC), kit.r16(0x1012)) end,
    collect = function(S)
      local live = {}
      local s, k = kit.r16(0x56), 0
      while s ~= 0 and k < 120 do
        live[#live + 1] = string.format("%04X:%04X/%04X", s, kit.r16(s + 0x10), kit.r16(s + 0x12))
        s = kit.r16(s + 6); k = k + 1
      end
      R.dmfEnd = kit.r16(0x09EC)
      R.x1, R.y1 = kit.r16(0x1014), kit.r16(0x1016)
      R.live = table.concat(live, " ")
      return R
    end }
end
