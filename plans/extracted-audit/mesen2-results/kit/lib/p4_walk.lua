-- description: P4 run file: normal-play camera sampler (OQ-I049-4): walks the player along a schedule and records player actor position minus layer-1 scroll on frames where the target is not clamped.
-- requires: mesen_kit, iog_kit, gaia_kit, p4_kit
-- p4walk.go{ out = "P4_x.txt", frames = 120, segs = { {1, 40, {"right"}}, {41, 80, {"down"}} }, rows = {from, to} }
p4walk = p4walk or {}
function p4walk.go(o)
  local frames = o.frames or 120
  local r = { uxN = 0, uyN = 0, dxMin = 9999, dxMax = -9999, dyMin = 9999, dyMax = -9999, clampX = 0, clampY = 0 }
  p4.run{ frames = frames, out = o.out, from = o.rows and o.rows[1] or 1, to = o.rows and o.rows[2] or 3,
    sched = function(t)
      for _, s in ipairs(o.segs or {}) do
        if t >= s[1] and t <= s[2] then return s[3] end
      end
      return nil
    end,
    tick = function(t, S, c)
      -- unclamped axis: target == actor - $80 (exp from the controller formula equals it) and the scroll has reached the target
      local ux = (c.ex_ == ((c.px - 0x80) & 0xFFFF)) and c.sx == c.tx
      local uy = (c.ey_ == ((c.py - 0x80) & 0xFFFF)) and c.sy == c.ty
      if ux then
        r.uxN = r.uxN + 1
        local d = (c.px - c.sx) & 0xFFFF
        if d < r.dxMin then r.dxMin = d end
        if d > r.dxMax then r.dxMax = d end
      else r.clampX = r.clampX + 1 end
      if uy then
        r.uyN = r.uyN + 1
        local d = (c.py - c.sy) & 0xFFFF
        if d < r.dyMin then r.dyMin = d end
        if d > r.dyMax then r.dyMax = d end
      else r.clampY = r.clampY + 1 end
      if t == frames then
        r.final = string.format("pl=%d,%d scr=%d,%d tgt=%d,%d bounds=%d,%d off=%d,%d", c.px, c.py, c.sx, c.sy, c.tx, c.ty, c.bx, c.by, c.ox, c.oy)
      end
    end,
    rowfmt = function(t, c, S) return string.format("pt=%d,%d", kit.r16(0x09A2), kit.r16(0x09A4)) end,
    collect = function(S) return r end }
end
