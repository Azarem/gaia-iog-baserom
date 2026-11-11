-- description: P4 run file: the packed ratio of the camera_scroll actors (OQ-57 (b)): visits a list of scenes by poking sceneNext ($0642) in a disposable run, moves the player to the middle of the scene window (disclosed poke, so the camera targets are nonzero) and logs every ComputeScrollDeltas MulDivide call: the packed word, the target, the result and the expected (lo x target / hi).
-- requires: mesen_kit, iog_kit, gaia_kit, p4_kit
-- p4ratio.go{ out = "P4_x.txt", scenes = {0x01, 0x23}, settle = 20, sample = 20 }
-- Marks (O file offsets, the "; {n}" tags of extracted/system/engine/camera_scroll.asm): 60690 / 60704 = before the MulDivide JSL (A = packed, Y = target); 60694 / 60708 = after it (A = result).
p4ratio = p4ratio or {}
function p4ratio.go(o)
  local scenes = o.scenes
  local settle, sample = o.settle or 20, o.sample or 20
  local st = { idx = 1, phase = "warp", n = 0, wait = 0, rec = {}, seen = {}, spawn = {}, tele = {}, order = {}, timeouts = {} }
  local pend = {}
  local function cur() return scenes[st.idx] end
  local function pre(axis)
    return function(S)
      if st.phase ~= "sample" then return end
      local s = emu.getState()
      local d = s["cpu.d"]
      pend[axis] = { a = s["cpu.a"] & 0xFFFF, y = s["cpu.y"] & 0xFFFF, d14 = kit.r16(d + 0x14), d16 = kit.r16(d + 0x16), d = d, entry = kit.r16(d) }
    end
  end
  local function post(axis)
    return function(S)
      if st.phase ~= "sample" or not pend[axis] then return end
      local p = pend[axis]; pend[axis] = nil
      local res = emu.getState()["cpu.a"] & 0xFFFF
      local lo, hi = p.a & 0xFF, (p.a >> 8) & 0xFF
      local exp = hi ~= 0 and ((lo * p.y) // hi) & 0xFFFF or -1
      local key = string.format("%02X%s%04X%04X", cur(), axis, p.a, p.y)
      if not st.seen[key] and #st.rec < 150 then
        st.seen[key] = true
        st.rec[#st.rec + 1] = string.format("sc=%02X axis=%s packed=%04X (lo=%d hi=%d) target=%d result=%d expected=%d %s slot=%04X entry=%04X $14=%04X $16=%04X",
          cur(), axis, p.a, lo, hi, p.y, res, exp, (exp == res) and "OK" or "DIFF", p.d, p.entry, p.d14, p.d16)
      end
    end
  end
  p4.run{ frames = o.frames or 4000, out = o.out, from = 1, to = 0,
    marks = {
      PX = { 60690, pre("X") }, RX = { 60694, post("X") },
      PY = { 60704, pre("Y") }, RY = { 60708, post("Y") },
    },
    tick = function(t, S, c)
      if not cur() then S.stop = true; return end
      local sc = c.sc & 0xFF
      st.n = st.n + 1
      if st.phase == "warp" then
        if st.n == 1 then kit.w16(0x0642, cur()) end
        if sc == cur() and kit.r16(0x0642) == 0 then st.phase = "settle"; st.n = 0 end
        if st.n > 700 then st.timeouts[#st.timeouts + 1] = string.format("%02X", cur()); st.idx = st.idx + 1; st.n = 0 end
      elseif st.phase == "settle" then
        if st.n == settle then
          local bx, by, ox, oy = c.bx, c.by, c.ox, c.oy
          local x, y = (ox + bx) // 2, (oy + by) // 2
          kit.w16(0x1014, x); kit.w16(0x1016, y); kit.w16(0x09A2, x - 8); kit.w16(0x09A4, y - 16)
          st.tele[#st.tele + 1] = string.format("%02X:%d,%d", cur(), x, y)
          st.phase = "sample"; st.n = 0
        end
      elseif st.phase == "sample" then
        if st.n == sample then
          for _, l in ipairs(st.rec) do p4.emit(S, l); st.total = (st.total or 0) + 1 end
          st.rec = {}
          p4.emit(S, string.format("sc=%02X end: pl=%d,%d tgt=%d,%d scr=%d,%d d1=%d,%d bounds=%d,%d off=%d,%d", cur(), c.px, c.py, c.tx, c.ty, c.sx, c.sy, c.dx, c.dy, c.bx, c.by, c.ox, c.oy))
          st.idx = st.idx + 1; st.phase = "warp"; st.n = 0
        end
      end
    end,
    collect = function(S)
      return { recs = st.total or 0, tele = table.concat(st.tele, " "), timeouts = table.concat(st.timeouts, ","), idx = st.idx }
    end }
end
