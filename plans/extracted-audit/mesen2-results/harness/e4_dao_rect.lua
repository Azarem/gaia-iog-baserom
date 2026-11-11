-- E4 OQ-I035-4: Dao window rectangle. Player actor moved next to the rectangle (disposable state), A/B render: window 1 BG1 enable (W12SEL bit 1) on vs forced off by a write override.
local WR = emu.memType.snesWorkRam
local SM = emu.memType.snesMemory
local CPU = emu.cpuType.snes
local S = e4.install{ census = false }
local px, py = tonumber(DAO_PX) or 352, tonumber(DAO_PY) or 395
local override = nil
for bank = 0, 0xBF do
  if bank <= 0x3F or bank >= 0x80 then
    emu.addMemoryCallback(function() if override ~= nil then return override end end, emu.callbackType.write, (bank << 16) | 0x2123, (bank << 16) | 0x2123, CPU, SM)
  end
end
local function grab()
  -- whole frame in one call: buffer index = y * width + x + 1
  local buf = emu.getScreenBuffer()
  local t = {}
  for y = 0, 223 do
    local r = {}
    for x = 0, 255 do r[x + 1] = buf[y * 256 + x + 1] end
    t[y + 1] = r
  end
  return t
end
local n, A, B, C, linesA = 0, nil, nil, nil, nil
local camA
kit.onFrame(function()
  n = n + 1
  if n == 1 then
    emu.write16(0x1014, px, WR); emu.write16(0x1016, py, WR); emu.write16(0x09A2, px + 8, WR); emu.write16(0x09A4, py + 16, WR)
  end
  if n == 119 then S.rec = true; S.lines = {} end
  if n == 120 then
    S.rec = false
    A = grab()
    camA = string.format("bg1H=%04X mapV=%04X cameraTargetX=%04X cameraTargetY=%04X player=%04X,%04X", emu.read16(0x68A, WR, false), emu.read16(0x68E, WR, false), emu.read16(0x6BE, WR, false),
      emu.read16(0x6C2, WR, false), emu.read16(0x1014, WR, false), emu.read16(0x1016, WR, false))
    local r0, r1 = {}, {}
    for _, e in ipairs(S.lines[0x2126] or {}) do r0[#r0 + 1] = e end
    local l0, l1 = S.lines[0x2126] or {}, S.lines[0x2127] or {}
    local function runs(list)
      local out, cur = {}, nil
      for _, e in ipairs(list) do
        local sc, v = e >> 8, e & 0xFF
        if cur and cur.v == v and sc == cur.b + 1 then cur.b = sc else cur = { a = sc, b = sc, v = v }; out[#out + 1] = cur end
      end
      local s = {}
      for i, r in ipairs(out) do if i <= 20 then s[#s + 1] = string.format("%d-%d=%02X", r.a, r.b, r.v) end end
      return table.concat(s, " "), #out
    end
    local a, na = runs(l0)
    local b, nb = runs(l1)
    emu.log("WH0 runs(" .. na .. "): " .. a)
    emu.log("WH1 runs(" .. nb .. "): " .. b)
    emu.log(camA)
    override = 0x00
  end
  if n == 123 then B = grab() end
  if n == 126 then
    C = grab()
    local function diff(P, Q)
      local cnt, x0, x1, y0, y1 = 0, 999, -1, 999, -1
      for y = 1, 224 do for x = 1, 256 do
        if P[y][x] ~= Q[y][x] then cnt = cnt + 1; if x < x0 then x0 = x end; if x > x1 then x1 = x end; if y < y0 then y0 = y end; if y > y1 then y1 = y end end
      end end
      return string.format("diff=%d bbox x=%d-%d y=%d-%d", cnt, x0 - 1, x1 - 1, y0 - 1, y1 - 1)
    end
    local rowdiff = {}
    for y = 1, 224, 8 do
      local c, mn, mx = 0, 999, -1
      for x = 1, 256 do if A[y][x] ~= B[y][x] then c = c + 1; if x < mn then mn = x end; if x > mx then mx = x end end end
      rowdiff[#rowdiff + 1] = string.format("y=%d n=%d x=%d-%d", y - 1, c, mn - 1, mx - 1)
    end
    local function colDiff(P, Q, x)
      local c = 0
      for y = 1, 224 do if P[y][x + 1] ~= Q[y][x + 1] then c = c + 1 end end
      return c
    end
    local cols = {}
    for x = 0, 4 do cols[#cols + 1] = string.format("x=%d A-vs-B rows=%d B-vs-C rows=%d", x, colDiff(A, B, x), colDiff(B, C, x)) end
    kit.finish({ cols = cols, cam = camA, AvsB_windowOnVsOff = diff(A, B), BvsC_noise_windowOffBoth = diff(B, C), rows = rowdiff, w12 = emu.getState()["ppu.window[0].activeLayers[0]"] })
  end
end)
