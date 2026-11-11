-- description: F1 animation forcing: crop screenshots written as PNG from Lua (no io), contact sheets, OAM decode, spriteset frame-list reader, player/actor sprite forcing run.
-- requires: mesen_kit, iog_kit, gaia_kit
--
--   f1.grab(x, y, w, h)               copy of the crop of the current screen buffer ({w=, h=, p={rgb...}})
--   f1.encode(img, scale)             PNG bytes (indexed colour, fixed-Huffman deflate)
--   f1.shot(name, img, scale)         writes screenshots/F1_<name>.png under the results folder, returns the byte count
--   f1.sheet(imgs, cols, scale)       one image made of the crops in a grid (1 px magenta gaps)
--   f1.oam(x0, y0, x1, y1)            decoded OAM rows (list of strings) of the sprites whose box overlaps the rectangle
--   f1.anim(bank, ptr, idx)           frame records {hold, group} of frame list idx of a spriteset (ROM read), the list pointer
--   f1.bodyRow(row)                   spriteset ptr, bank, tile-graphics ptr, bank of body_table row (ROM offset 121201 + 6 * row)
--   f1.run{...}                       quick-warp host run: set form, warp, then force a list of (anim index, frame) on the actor slot
-- Force mechanism (measured in F1): the player's idle loop (player_character, loc_02C4BD: AnimOneFrame, hold -> $24, SetEntryHere, DEC $24 / BMI)
-- calls UpdateActorAnimation only when its tick counter $24 of the slot has run out. Writing $28 = idx, $2A = frame and $08 = $24 = 0 at every
-- frame end makes the next run of the loop show frame `frame` of list `idx` of the actor's spriteset (body_table row of characterForm).
f1 = f1 or {}

local P = emu.memType.snesPrgRom
local OAMM = emu.memType.snesSpriteRam

-- ---------------------------------------------------------------------------------------- PNG
local crcT = {}
for i = 0, 255 do
  local c = i
  for _ = 1, 8 do
    if c & 1 == 1 then c = 0xEDB88320 ~ (c >> 1) else c = c >> 1 end
  end
  crcT[i] = c
end
local function crc32(s)
  local c = 0xFFFFFFFF
  for i = 1, #s do c = crcT[(c ~ s:byte(i)) & 0xFF] ~ (c >> 8) end
  return c ~ 0xFFFFFFFF
end
local function be32(n) return string.pack(">I4", n) end
local function chunk(t, d) return be32(#d) .. t .. d .. be32(crc32(t .. d)) end

local LB = { 3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31, 35, 43, 51, 59, 67, 83, 99, 115, 131, 163, 195, 227, 258 }
local LE = { 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0 }
local DB = { 1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193, 257, 385, 513, 769, 1025, 1537, 2049, 3073, 4097, 6145, 8193, 12289, 16385, 24577 }
local DE = { 0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13 }

local function deflate(b, n, rowlen)
  local out, acc, nb = {}, 0, 0
  local function bits(v, k)
    acc = acc | (v << nb); nb = nb + k
    while nb >= 8 do out[#out + 1] = string.char(acc & 0xFF); acc = acc >> 8; nb = nb - 8 end
  end
  local function huff(code, k)
    local r = 0
    for _ = 1, k do r = (r << 1) | (code & 1); code = code >> 1 end
    bits(r, k)
  end
  local function lit(v)
    if v < 144 then huff(0x30 + v, 8) elseif v < 256 then huff(0x190 + v - 144, 9)
    elseif v < 280 then huff(v - 256, 7) else huff(0xC0 + v - 280, 8) end
  end
  bits(1, 1); bits(1, 2)
  local i = 1
  while i <= n do
    local best, bd = 0, 0
    for _, d in ipairs { 1, rowlen } do
      if i - d >= 1 then
        local l = 0
        while l < 258 and i + l <= n and b[i + l] == b[i + l - d] do l = l + 1 end
        if l > best then best, bd = l, d end
      end
    end
    if best >= 4 then
      local li = 29
      for k = 1, 29 do if LB[k] > best then li = k - 1; break end end
      lit(256 + li); if LE[li] > 0 then bits(best - LB[li], LE[li]) end
      local di = 30
      for k = 1, 30 do if DB[k] > bd then di = k - 1; break end end
      huff(di - 1, 5); if DE[di] > 0 then bits(bd - DB[di], DE[di]) end
      i = i + best
    else
      lit(b[i]); i = i + 1
    end
  end
  huff(0, 7)
  if nb > 0 then out[#out + 1] = string.char(acc & 0xFF) end
  return table.concat(out)
end

local function adler(b, n)
  local a, c = 1, 0
  for i = 1, n do a = (a + b[i]) % 65521; c = (c + a) % 65521 end
  return (c << 16) | a
end

function f1.grab(x, y, w, h)
  local sb = emu.getScreenBuffer()
  local p = {}
  for yy = 0, h - 1 do
    for xx = 0, w - 1 do p[yy * w + xx + 1] = sb[(y + yy) * 256 + (x + xx) + 1] & 0xFFFFFF end
  end
  return { w = w, h = h, p = p }
end

function f1.encode(img, scale)
  scale = scale or 1
  local w, h = img.w, img.h
  local pal, plist = {}, {}
  local ow = w * scale
  local rowlen = ow + 1
  local b, n = {}, 0
  for yy = 0, h - 1 do
    local row = {}
    for xx = 0, w - 1 do
      local c = img.p[yy * w + xx + 1]
      local k = pal[c]
      if not k then
        k = #plist; pal[c] = k; plist[#plist + 1] = c
        if k > 255 then error("more than 256 colours") end
      end
      row[xx + 1] = k
    end
    for _ = 1, scale do
      n = n + 1; b[n] = 0
      for xx = 1, w do
        local k = row[xx]
        for _ = 1, scale do n = n + 1; b[n] = k end
      end
    end
  end
  local z = "\x78\x01" .. deflate(b, n, rowlen) .. be32(adler(b, n))
  local pl = {}
  for _, c in ipairs(plist) do pl[#pl + 1] = string.char((c >> 16) & 255, (c >> 8) & 255, c & 255) end
  return "\x89PNG\r\n\x1a\n" .. chunk("IHDR", be32(ow) .. be32(h * scale) .. "\x08\x03\x00\x00\x00")
    .. chunk("PLTE", table.concat(pl)) .. chunk("IDAT", z) .. chunk("IEND", "")
end

function f1.shot(name, img, scale)
  local d = f1.encode(img, scale)
  emu.mcp.writeFile("screenshots/F1_" .. name .. ".png", d)
  return #d
end

function f1.sheet(imgs, cols, gap)
  gap = gap or 1
  local cw, ch = imgs[1].w, imgs[1].h
  local rows = (#imgs + cols - 1) // cols
  local W, H = cols * cw + (cols - 1) * gap, rows * ch + (rows - 1) * gap
  local p = {}
  for i = 1, W * H do p[i] = 0xFF00FF end
  for i, im in ipairs(imgs) do
    local c, r = (i - 1) % cols, (i - 1) // cols
    local ox, oy = c * (cw + gap), r * (ch + gap)
    for yy = 0, ch - 1 do
      for xx = 0, cw - 1 do p[(oy + yy) * W + ox + xx + 1] = im.p[yy * cw + xx + 1] end
    end
  end
  return { w = W, h = H, p = p }
end

-- ---------------------------------------------------------------------------------------- OAM
-- Rows: "n<i> t=<tile 9 bit> p=<palette> pr=<priority> (x,y) sz=<size bit> flips" for sprites whose box overlaps the rectangle.
function f1.oam(x0, y0, x1, y1)
  local rows = {}
  for i = 0, 127 do
    local x = emu.read(i * 4, OAMM)
    local y = emu.read(i * 4 + 1, OAMM)
    local t = emu.read(i * 4 + 2, OAMM)
    local a = emu.read(i * 4 + 3, OAMM)
    local sh = (emu.read(512 + (i >> 2), OAMM) >> ((i & 3) * 2)) & 3
    if (sh & 1) ~= 0 then x = x - 256 end
    local sz = (sh >> 1) & 1
    local ext = sz == 1 and 32 or 16
    y = y + 1
    if y < 224 and x + ext > x0 and x < x1 and y + ext > y0 and y < y1 then
      rows[#rows + 1] = string.format("n%d t=%03X p=%d pr=%d (%d,%d) sz=%d%s%s", i, t | ((a & 1) << 8), (a >> 1) & 7, (a >> 4) & 3, x, y, sz,
        (a & 0x40) ~= 0 and " H" or "", (a & 0x80) ~= 0 and " V" or "")
    end
  end
  return rows
end

-- ---------------------------------------------------------------------------------------- ROM frame lists
local function romOff(bank, ptr) return ((bank & 0x3F) << 16) | ptr end
local function rd16(o) return emu.read(o, P) | (emu.read(o + 1, P) << 8) end
f1.romOff, f1.rd16 = romOff, rd16

-- Frame records of list idx: {hold, group}; the list ends at a word with bit 15 set. Returns the records and the list pointer.
function f1.anim(bank, ptr, idx)
  local base = romOff(bank, ptr)
  local lp = rd16(base + idx * 2)
  local lo = romOff(bank, lp)
  local out = {}
  for f = 0, 63 do
    local w0 = rd16(lo + f * 4)
    if w0 >= 0x8000 then break end
    out[#out + 1] = { hold = w0, group = rd16(lo + f * 4 + 2) }
  end
  return out, lp
end

function f1.bodyRow(row)
  local o = 121201 + row * 6
  return rd16(o), emu.read(o + 2, P), rd16(o + 3), emu.read(o + 5, P)
end

-- ---------------------------------------------------------------------------------------- run
-- f1.run{ name=, form=0|1|2|nil, scene=1, steps={ {idx=, frame=0, tag=}, ... }, hold=10, crop={x,y,w,h}, scale=2, bank=, ptr=, slot=0x1000, cols=6 }
-- Stages: wait for $0642 = 0, poke the form ($0AD4), write the scene to $0642 (quick warp), wait for the scene and the banner, then run the steps.
-- Per step: `hold` frame ends with ($08 = 0, $28 = idx, $2A = frame); at the last one the crop is grabbed, written as F1_<name>_<tag>.png and the OAM rows
-- inside the crop, the metasprite pointer ($7F:000C of the slot) against the ROM record (group + 4) and the frame list shape are written to
-- F1_<name>_oam.txt. A sheet of all crops (scale 1) is written as F1_<name>_sheet.png. Ends with kit.finish (control36 = the NMI's INC $36 writes).
function f1.run(o)
  local slot = o.slot or 0x1000
  local crop = o.crop or { 104, 76, 96, 80 }
  local hold = o.hold or 10
  local scale = o.scale or 2
  local n, stage, pulse, si, k = 0, (o.nowarp and "settle" or "wait"), 0, 1, 0
  local settleFrames = o.settle or 300
  local ctl = 0
  emu.addMemoryCallback(function(a) if (a & 0xFFFF) == 0x36 then ctl = ctl + 1 end end, emu.callbackType.write, 0x36, 0x36, emu.cpuType.snes, emu.memType.snesWorkRam)
  local lines, imgs, res = {}, {}, { shots = {} }
  local byTag = {}
  local function put(s) lines[#lines + 1] = s end
  local bank, ptr
  kit.onFrame(function()
    n = n + 1
    local sc, sn = kit.r16(0x0644), kit.r16(0x0642)
    if stage == "wait" then
      if n >= 3 and sn == 0 then
        if o.form then kit.w16(0x0AD4, o.form) end
        for _, p in ipairs(o.pokes or {}) do if p.w == 16 then kit.w16(p.addr, p.v) else kit.w8(p.addr, p.v) end end
        kit.w16(0x0642, o.scene)
        stage = "warping"
      end
    elseif stage == "warping" then
      if sc == o.scene and sn == 0 then stage = "banner" end
      if n > 1500 then kit.finish({ error = "warp_timeout", scene = sc }); return end
    end
    if stage == "banner" then
      if kit.r8(0x00B4) ~= 0 then
        pulse = pulse + 1
        gaia.hold((pulse % 6 < 3) and { "a" } or {})
      else
        gaia.release(); stage = "settle"; res.settle = 0
      end
    elseif stage == "settle" then
      res.settle = (res.settle or 0) + 1
      if res.settle >= settleFrames then
        stage = "run"
        res.start = { frame = emu.getState().frameCount, form = kit.r16(0x0AD4), scene = sc, sprPtr = kit.r16(0x10000 + slot + 6), sprBank = kit.r8(0x10000 + slot + 8),
          flags = kit.r16(0x09AE), mask = kit.r16(0x065A), base28 = kit.r16(slot + 0x28), pos = { kit.r16(slot + 0x14), kit.r16(slot + 0x16) } }
        bank, ptr = res.start.sprBank, res.start.sprPtr
        put(string.format("# %s form=%d scene=%02X spriteset=%02X:%04X crop=%d,%d,%d,%d scale=%d hold=%d", o.name, res.start.form, sc, bank, ptr,
          crop[1], crop[2], crop[3], crop[4], scale, hold))
        local b = f1.grab(crop[1], crop[2], crop[3], crop[4])
        byTag["baseline"] = b
        res.baseline = f1.shot(o.name .. "_baseline", b, scale)
        put("baseline (unforced, a28=" .. res.start.base28 .. "): " .. table.concat(f1.oam(crop[1], crop[2], crop[1] + crop[3], crop[2] + crop[4]), "; "))
      end
    elseif stage == "run" then
      local st = o.steps[si]
      if not st then return end
      k = k + 1
      if o.tick then o.tick(si, k, put) end
      if st.entry then
        -- st.entry = {word=, bank=}: the player script is replaced the way the callers do it (LDA #bank / STA $0002,Y; LDA #word / STA $0000,Y; $0008 = $002A = 0)
        if k == 1 then
          kit.w16(slot + 0x02, st.entry.bank)
          kit.w16(slot + 0x00, st.entry.word)
          kit.w16(slot + 0x08, 0)
          kit.w16(slot + 0x2A, 0)
        end
        st.idx = st.idx or 0
      elseif st.watch then
        st.idx = st.idx or 0
      else
        kit.w16(slot + 0x08, 0)
        kit.w16(slot + 0x24, 0)
        kit.w16(slot + 0x28, st.idx)
        kit.w16(slot + 0x2A, st.frame or 0)
      end
      if k >= (st.hold or hold) then
        local recs, fr, want
        local mp = kit.r16(0x10000 + slot + 0x0C)
        if st.entry or st.watch then
          local lb, lp, li = kit.r8(0x10000 + slot + 8), kit.r16(0x10000 + slot + 6), kit.r16(slot + 0x28)
          st.idx = li
          recs = f1.anim(lb, lp, li)
          fr = kit.r16(slot + 0x2A)
          want = -1
          for _, r in ipairs(recs) do if r.group + 4 == mp then want = mp end end
          put(string.format("   live spriteset %02X:%04X idx=%02X $10=%04X", lb, lp, li, kit.r16(slot + 0x10)))
        else
          recs = f1.anim(bank, ptr, st.idx)
          fr = st.frame or 0
          want = recs[fr + 1] and (recs[fr + 1].group + 4) or -1
        end
        local img = f1.grab(crop[1], crop[2], crop[3], crop[4])
        local tag = st.tag or string.format("%02X", st.idx)
        local bytes = f1.shot(o.name .. "_" .. tag, img, scale)
        imgs[#imgs + 1] = img
        byTag[tag] = img
        local hl = {}
        for i, r in ipairs(recs) do hl[#hl + 1] = string.format("%d:%X", r.hold, r.group) end
        local rows = f1.oam(crop[1], crop[2], crop[1] + crop[3], crop[2] + crop[4])
        put(string.format("[%s] idx=%02X fr=%d frames=%d mp=%04X want=%04X %s a28=%02X a2a=%02X pf=%04X ac8=%d bytes=%d", tag, st.idx, fr, #recs, mp, want,
          (mp == want) and "MATCH" or "NOMATCH", kit.r16(slot + 0x28), kit.r16(slot + 0x2A), kit.r16(0x09AE), kit.r16(0x0AC8), bytes))
        put("   list " .. table.concat(hl, " "))
        put("   oam " .. table.concat(rows, "; "))
        res.shots[#res.shots + 1] = tag
        k = 0; si = si + 1
        if si > #o.steps then
          for _, pr in ipairs(o.pairs or {}) do
            local A, B = byTag[pr[1]], byTag[pr[2]]
            if A and B then
              local d = 0
              for i = 1, #A.p do if A.p[i] ~= B.p[i] then d = d + 1 end end
              put(string.format("pair %s vs %s: %d of %d pixels differ", pr[1], pr[2], d, #A.p))
            end
          end
          local sh = f1.sheet(imgs, o.cols or 6)
          res.sheet = f1.shot(o.name .. "_sheet", sh, 1)
          res.sheetSize = { sh.w, sh.h }
          emu.mcp.writeFile("F1_" .. o.name .. "_oam.txt", table.concat(lines, "\n") .. "\n", false)
          res.control36Writes, res.frames = ctl, n
          res.final = { pf = kit.r16(0x09AE), form = kit.r16(0x0AD4) }
          kit.finish(res)
        end
      end
    end
  end)
end
