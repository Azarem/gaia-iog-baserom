-- description: E3 light runs from S08: scripted menu input, optional pokes, stop at frame n, report the Mode 7 words (for screenshots).
-- requires: mesen_kit, iog_kit, gaia_kit, e3_kit
--
-- e3shot.go{ stop=N, input=fn(n), poke=fn(n) (called each frame before the stop test), extra=fn() -> table merged into the result }
-- Frame n counts from the frame the state was loaded (frame 398 for orig_S08_world-map.mss).
e3shot = e3shot or {}

-- the menu trip of the main run: Down at n=300-301 (menu cursor to the second row), A at n=310-311 (choose)
function e3shot.menuInput(n)
  if n >= 300 and n <= 301 then return { down = true } end
  if n >= 310 and n <= 311 then return { a = true } end
  return nil
end

function e3shot.go(o)
  local f0 = emu.getState().frameCount
  local done = false
  local w36 = 0
  emu.addMemoryCallback(function(a) if (a & 0xFFFF) == 0x36 then w36 = w36 + 1 end end, emu.callbackType.write, 0x36, 0x36, emu.cpuType.snes, emu.memType.snesWorkRam)
  if o.input then e3.input(o.input, f0) end
  kit.onFrame(function()
    if done then return end
    local n = emu.getState().frameCount - f0
    if o.poke then o.poke(n) end
    if n >= o.stop then
      done = true
      local p = e3.ppu7()
      local r = { n = n, start = f0, w36 = w36, f36 = kit.r16(0x36), scene = kit.r16(0x644), choice = kit.r16(0xD58), route = kit.r16(0xD5A),
        B6 = kit.r16(0xB6), B8 = kit.r16(0xB8), BC = kit.r16(0xBC), CA = kit.r16(0xCA), CC = kit.r16(0xCC),
        mode = p.mode, large = p.large, fill0 = p.fill0, hflip = p.hflip, vflip = p.vflip, cx = p.cx, cy = p.cy, hs = p.hs, vs = p.vs,
        m0 = p.m0, m1 = p.m1, m2 = p.m2, m3 = p.m3 }
      -- HDMA channel set-up from the native state: mask, then per channel dest register ($21xx low byte), mode, source bank:address, current table pointer, indirect flag
      local s = emu.getState()
      local ch = {}
      for c = 0, 7 do
        local p = "dmaController.channel[" .. c .. "]."
        ch[#ch + 1] = string.format("ch%d mode=%d dest=21%02X src=%02X:%04X tbl=%04X ind=%s lc=%02X fin=%s", c, s[p .. "transferMode"] or -1, s[p .. "destAddress"] or 0,
          s[p .. "srcBank"] or 0, s[p .. "srcAddress"] or 0, s[p .. "hdmaTableAddress"] or 0, tostring(s[p .. "hdmaIndirectAddressing"]),
          s[p .. "hdmaLineCounterAndRepeat"] or 0, tostring(s[p .. "hdmaFinished"]))
      end
      r.hdmaMask = s["dmaController.hdmaChannels"]
      r.channels = ch
      r.bgmode = s["ppu.bgMode"]
      r.bg3prio = s["ppu.bgMode1Bg3Priority"]
      r.fixed = s["ppu.fixedColor"]
      r.cgwsel = s["ppu.colorMathClipMode"]
      if o.extra then for k, v in pairs(o.extra()) do r[k] = v end end
      kit.finish(r)
    end
  end)
end
