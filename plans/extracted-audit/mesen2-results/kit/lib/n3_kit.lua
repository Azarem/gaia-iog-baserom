-- description: N3 Dark Space and Gaia: portal lookup and entry, player $10 bit $2000 recorder, $0AAC write log, exec counters by ROM offset, per-frame state rows for the portal / Gaia room runs.
-- requires: mesen_kit, iog_kit, gaia_kit, m1_kit, n1_kit
--
--   n3.portal()             first live portal slot (entry in DarkSpacePortalInit .. DarkSpacePortalClose) or nil
--   n3.execs(map)           exec counters on ROM offsets {name = offset} -> {name = n}
--   n3.watchHidden(S)       write callbacks on the player actor $1010/$1011: logs every change of bit $2000 (S.hid rows) with the PC after the store
--   n3.watchGsi(S)          write callbacks on $0AAC/$0AAD (globalScriptIndex): S.gsi rows (frame, $36, scene, pc, byte, value) and a read counter
--   n3.px()                 player actor position (x, y) and tile words
-- Callbacks run BEFORE the access; a memory callback reports the PC AFTER the accessing instruction. Offsets are decimal ROM file offsets (the ; {n} tags of extract:lt).
n3 = n3 or {}

local WR  = emu.memType.snesWorkRam
local P   = emu.memType.snesPrgRom
local CPU = emu.cpuType.snes

n3.PORTAL_LO, n3.PORTAL_HI = 579253, 579345   -- DarkSpacePortalInit .. DarkSpacePortalClose
n3.MON_LO,    n3.MON_HI    = 579347, 579495   -- DarkSpaceInteractionMonitor .. DarkSpaceMonitorStartWarp

function n3.h4(v) return string.format("%04X", v) end

function n3.slotOf(lo, hi)
  for _, s in ipairs(n1.live()) do
    local r = n1.rom(n1.ent(s))
    if r >= lo and r <= hi then return s end
  end
  return nil
end
function n3.portal() return n3.slotOf(n3.PORTAL_LO, n3.PORTAL_HI) end
function n3.monitor() return n3.slotOf(n3.MON_LO, n3.MON_HI) end

function n3.execs(map)
  local cnt = {}
  for name, off in pairs(map) do
    cnt[name] = 0
    emu.addMemoryCallback(function() cnt[name] = cnt[name] + 1 end, emu.callbackType.exec, off, off, CPU, P)
  end
  return cnt
end

local function pcOff()
  local st = emu.getState()
  return ((st["cpu.k"] & 0x3F) << 16) | (st["cpu.pc"] & 0xFFFF), st["frameCount"]
end

-- the player actor is the slot in $09AA (value $1000 in every scene seen so far); the watch covers $1010/$1011 only
function n3.watchHidden(S)
  S.hid = S.hid or {}
  S.hidN = 0
  emu.addMemoryCallback(function(a, v)
    local w = a & 0xFFFF
    if w ~= 0x1011 then return end
    local old = emu.read(w, WR)
    if ((old ~ v) & 0x20) == 0 then return end
    local pc, f = pcOff()
    S.hidN = S.hidN + 1
    if #S.hid < 40 then
      S.hid[#S.hid + 1] = string.format("f=%d n36=%d sc=%02X pc=%d $1011 %02X->%02X (bit $2000 %s) bright=%s", f, kit.r16(0x36), kit.r16(0x0644), pc, old, v,
        (v & 0x20) ~= 0 and "SET" or "CLEARED", tostring(emu.getState()["ppu.screenBrightness"]))
    end
  end, emu.callbackType.write, 0x1010, 0x1011, CPU, WR)
end

function n3.watchGsi(S)
  S.gsi = S.gsi or {}
  S.gsiN, S.gsiR = 0, 0
  emu.addMemoryCallback(function(a, v)
    local w = a & 0xFFFF
    if w ~= 0x0AAC and w ~= 0x0AAD then return end
    local pc, f = pcOff()
    S.gsiN = S.gsiN + 1
    if #S.gsi < 40 then
      S.gsi[#S.gsi + 1] = string.format("f=%d n36=%d sc=%02X pc=%d [%04X]=%02X (old %02X) src=%02X", f, kit.r16(0x36), kit.r16(0x0644), pc, w, v, emu.read(w, WR), kit.r8(0x0B12))
    end
  end, emu.callbackType.write, 0x0AAC, 0x0AAD, CPU, WR)
  emu.addMemoryCallback(function(a, v)
    local w = a & 0xFFFF
    if w ~= 0x0AAC and w ~= 0x0AAD then return end
    local pc, f = pcOff()
    S.gsiR = S.gsiR + 1
    if S.gsiRows == nil then S.gsiRows = {} end
    if #S.gsiRows < 30 then
      S.gsiRows[#S.gsiRows + 1] = string.format("f=%d sc=%02X pc=%d read [%04X]=%02X src=%02X", f, kit.r16(0x0644), pc, w, v, kit.r8(0x0B12))
    end
  end, emu.callbackType.read, 0x0AAC, 0x0AAD, CPU, WR)
end

-- contact sheet of n2.grab images (cols per row) written to screenshots/N3_<name>.png; returns the byte count
function n3.sheet(imgs, cols, name, scale)
  -- f1.encode holds at most 256 colours: quantize the grabs (drop the low bits of each channel) until the sheet fits
  local masks = { 0xFFFFFF, 0xF8F8F8, 0xF0F0F0, 0xE0E0E0, 0xC0C0C0 }
  local sh
  for _, mk in ipairs(masks) do
    local seen, n = {}, 0
    for _, im in ipairs(imgs) do for _, c in ipairs(im.p) do local q = c & mk; if not seen[q] then seen[q] = true; n = n + 1 end end end
    if n <= 255 then
      if mk ~= 0xFFFFFF then for _, im in ipairs(imgs) do for i, c in ipairs(im.p) do im.p[i] = c & mk end end end
      break
    end
  end
  local d = f1.encode(f1.sheet(imgs, cols, 1), scale or 1)
  emu.mcp.writeFile("screenshots/N3_" .. name .. ".png", d)
  return #d
end

function n3.px() return kit.r16(0x1014), kit.r16(0x1016), kit.r16(0x09A6), kit.r16(0x09A8) end
