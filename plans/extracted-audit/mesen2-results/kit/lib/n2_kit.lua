-- description: N2 cutscenes and bosses: live-actor counts by entry (ROM offset), exec counters on ROM offsets, per-30-frame contact sheets of the screen (PNG written from Lua), statue ceremony run, game-over run.
-- requires: mesen_kit, iog_kit, gaia_kit, m1_kit, n1_kit, e1_display, f1_kit
--
--   n2.live()                       list of live slots (n1.live)
--   n2.countEnt(rom, rom2)          number of live actors whose entry (ROM file offset, bank mirror removed) is rom (or in [rom, rom2])
--   n2.execs(map)                   exec callbacks on ROM offsets {name = offset}; returns the counter table {name = n}
--   n2.sheet(imgs, cols, name)      one PNG contact sheet of full-screen grabs (256 x 224, scale 1) under <results>/screenshots/N2_<name>.png
-- Callbacks run BEFORE the access; a memory callback reports the PC AFTER the accessing instruction. Offsets are the decimal ; {n} tags of extract:lt.
n2 = n2 or {}

local P   = emu.memType.snesPrgRom
local CPU = emu.cpuType.snes

function n2.live() return n1.live() end

function n2.countEnt(rom, rom2)
  local c = 0
  for _, s in ipairs(n1.live()) do
    local r = n1.rom(n1.ent(s))
    if r == rom or (rom2 and r >= rom and r <= rom2) then c = c + 1 end
  end
  return c
end

function n2.execs(map)
  local cnt = {}
  for name, off in pairs(map) do
    cnt[name] = 0
    emu.addMemoryCallback(function() cnt[name] = cnt[name] + 1 end, emu.callbackType.exec, off, off, CPU, P)
  end
  return cnt
end

-- grab the screen buffer (256 x 224) keeping every `step`-th pixel (step 2 = 128 x 112); the run output cap is 100,000 bytes, so a sheet needs small images
function n2.grab(step, x0, y0, w, h)
  step = step or 2
  x0, y0, w, h = x0 or 0, y0 or 0, w or 256, h or 224
  local sb = emu.getScreenBuffer()
  local ow, oh = w // step, h // step
  local p = {}
  for yy = 0, oh - 1 do
    for xx = 0, ow - 1 do p[yy * ow + xx + 1] = sb[(y0 + yy * step) * 256 + (x0 + xx * step) + 1] & 0xFFFFFF end
  end
  return { w = ow, h = oh, p = p }
end

function n2.sheet(imgs, cols, name)
  local sh = f1.sheet(imgs, cols, 1)
  local d = f1.encode(sh, 1)
  emu.mcp.writeFile("screenshots/N2_" .. name .. ".png", d)
  return #d
end

-- hex helpers
function n2.h4(v) return string.format("%04X", v) end

-- WRAM word at an actor slot field
function n2.f(slot, off) return kit.r16(slot + off) end
