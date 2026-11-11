-- description: P4 camera: per-frame sampler of the camera target / scroll registers / player position, exec marks with the in-frame order, scheduled buttons, disclosed pokes, file output in 2.5 KB chunks.
-- requires: mesen_kit, iog_kit, gaia_kit
--
--   p4.run{ frames=N, out="P4_x.txt",
--           setup=function(S) end,                     -- once, at the first end of frame (disclosed pokes)
--           sched=function(t, S) return {"down"} end,  -- buttons held for the next frame (nil = release); t = frames since setup
--           tick=function(t, S, c) end,                -- after the sample of frame t (c = p4.cam() row); may call p4.emit(S, text)
--           marks={ name = {prgOffset, function(S, name) end}, ... },  -- exec callbacks on ROM file offsets (O: the "; {n}" tags); the callback runs BEFORE the instruction
--           rowfmt=function(t, c, S) return "extra text" end,           -- appended to every row
--           from=1, to=N,                                -- write the per-frame row only for from <= t <= to (default all)
--           collect=function(S) return {} end }          -- fields of the final result
--   p4.cam()      one snapshot table (WRAM only; the PPU BG1 scroll comes from emu.getState())
--   p4.expect(x, y)  the camera target camera_scroll_controller computes for a player actor at (x, y): offsets / bounds from $06D6-$06DC
--   p4.emit(S, text)  add a line to the output file (flushed in chunks of 2.5 KB)
-- Offsets of marks are ROM-specific (O). Memory callbacks report the PC of the NEXT instruction.
p4 = p4 or {}

local WR  = emu.memType.snesWorkRam
local P   = emu.memType.snesPrgRom
local CPU = emu.cpuType.snes

local function s16(v) v = v & 0xFFFF; if v >= 0x8000 then return v - 0x10000 end return v end
p4.s16 = s16

-- camera_scroll_controller (60144-60314): t = P - $80; t < 0 or t < offset -> offset; e = t + $100; e >= bounds -> bounds - $100; else t.
local function axis(pos, off, bounds)
  local t = s16(pos - 0x80)
  if t < 0 or s16(t - off) < 0 then return off end
  local e = t + 0x100
  if s16(e - bounds) < 0 then return t end
  return bounds - 0x100
end

function p4.expect(x, y)
  local ox, oy, bx, by = kit.r16(0x06D6), kit.r16(0x06D8), kit.r16(0x06DA), kit.r16(0x06DC)
  return axis(x, ox, bx), axis(y, oy, by)
end

function p4.cam()
  local st = emu.getState()
  local c = {
    f = st["frameCount"], n36 = kit.r16(0x36), sc = kit.r16(0x0644),
    px = kit.r16(0x1014), py = kit.r16(0x1016), ent = kit.r16(0x1000), an = kit.r16(0x1028),
    tx = kit.r16(0x06BE), ty = kit.r16(0x06C2), sx = kit.r16(0x068A), sy = kit.r16(0x068E),
    ppux = st["ppu.layers[0].hscroll"], ppuy = st["ppu.layers[0].vscroll"],
    dx = s16(kit.r16(0x06C0)), dy = s16(kit.r16(0x06C4)),
    ex = s16(kit.r16(0x06E4)), ey = s16(kit.r16(0x06E6)),
    ox = kit.r16(0x06D6), oy = kit.r16(0x06D8), bx = kit.r16(0x06DA), by = kit.r16(0x06DC),
    lpf = kit.r16(0x06EE), pf = kit.r16(0x09AE), f10 = kit.r16(0x1010),
  }
  c.ex_, c.ey_ = p4.expect(c.px, c.py)
  return c
end

local function flush(S)
  if S.out and #S.buf > 0 then
    emu.mcp.writeFile(S.out, S.buf, S.wrote)
    S.wrote = true
    S.buf = ""
  end
end

function p4.emit(S, text)
  S.buf = S.buf .. text .. "\n"
  S.lines = S.lines + 1
  if #S.buf > 2500 then flush(S) end
end

function p4.run(o)
  local S = { t = 0, ctl = 0, cnt = {}, seq = {}, buf = "", lines = 0, out = o.out, wrote = false, started = false, done = false }
  p4.S = S

  emu.addMemoryCallback(function(a) if (a & 0xFFFF) == 0x36 then S.ctl = S.ctl + 1 end end, emu.callbackType.write, 0x36, 0x36, CPU, WR)

  for name, m in pairs(o.marks or {}) do
    local off, fn = m[1], m[2]
    emu.addMemoryCallback(function()
      S.cnt[name] = (S.cnt[name] or 0) + 1
      S.seq[#S.seq + 1] = name
      if fn then fn(S, name) end
    end, emu.callbackType.exec, off, off, CPU, P)
  end

  local handle
  handle = kit.onFrame(function()
    if S.done then return end
    if not S.started then
      S.started = true
      if o.setup then o.setup(S) end
      S.seq = {}
      local b = o.sched and o.sched(0, S) or nil
      if b then gaia.hold(b) else gaia.release() end
      return
    end
    S.t = S.t + 1
    local c = p4.cam()
    if S.t >= (o.from or 1) and S.t <= (o.to or o.frames) then
      local extra = o.rowfmt and o.rowfmt(S.t, c, S) or ""
      p4.emit(S, string.format("t=%d f=%d n36=%d sc=%02X pl=%d,%d tgt=%d,%d exp=%d,%d scr=%d,%d ppu=%d,%d d1=%d,%d efd=%d,%d lpf=%04X pf=%04X ent=%04X an=%02X [%s] %s",
        S.t, c.f, c.n36, c.sc & 0xFF, c.px, c.py, c.tx, c.ty, c.ex_, c.ey_, c.sx, c.sy, c.ppux or -1, c.ppuy or -1, c.dx, c.dy, c.ex, c.ey,
        c.lpf, c.pf, c.ent, c.an & 0xFF, table.concat(S.seq, " "), extra))
    end
    S.seq = {}
    if o.tick then o.tick(S.t, S, c) end
    local b = o.sched and o.sched(S.t, S) or nil
    if b then gaia.hold(b) else gaia.release() end
    if S.t >= o.frames or S.stop then
      S.done = true
      flush(S)
      local r = o.collect and o.collect(S) or {}
      r.ctl36 = S.ctl; r.counts = S.cnt; r.lines = S.lines; r.out = S.out; r.frames = S.t
      kit.finish(r)
    end
  end)
  return S
end
