-- description: F2 lone-set check: force one frame list of the player actor three ways (natural control, anim index, repointed table pointer) and compare OAM with the ROM sprite group.
-- requires: mesen_kit, iog_kit, gaia_kit, f1_kit
--
--   f2.run{ name=, form=1, scene=1, settle=300, hold=8, crop={x,y,w,h}, scale=2, idx=0x4B, set=<offset of the frame list inside the spriteset bank> }
--
-- Engine chain (extracted/system/engine/sprite_composition.asm UpdateActorAnimation): DBR = $7F:0008,X (sprite bank); table word = [$7F:0006,X + 2 * $28];
-- frame record = [that word + 4 * $2A]; metasprite pointer $7F:000C,X = group + 4. There is no per-actor frame-list pointer: the list is the word of the table.
-- Trials (the slot is the player actor, $1000; the force is written at every frame end, like f1_kit):
--   T0 natural : no write; the idle loop shows the facing animation (control for the OAM formula).
--   T1 index   : $08 = $24 = 0, $28 = idx, $2A = 0 (the table row of idx).
--   T2 setaddr : $08 = $24 = 0, $28 = 0, $2A = 0, $7F:0006,X = table pointer + 2 * idx. Row 0 of the moved table is then the word that holds the set address.
-- Per trial at the last force frame: metasprite pointer against group + 4 of the list that the live registers select, the live list pointer, the OAM rows
-- inside the crop, and a part-by-part comparison of the OAM with the ROM group (position = host screen position - extent + part offset, size, H flip,
-- palette, priority; the constant offset between OAM and formula is taken from the control trial's vote and reported).
f2 = f2 or {}

local P = emu.memType.snesPrgRom
local OAMM = emu.memType.snesSpriteRam

local function rd8(o) return emu.read(o, P) end
local function rd16(o) return emu.read(o, P) | (emu.read(o + 1, P) << 8) end

local function hostRows(crop)
  local rows = {}
  for i = 0, 127 do
    local x = emu.read(i * 4, OAMM)
    local y = emu.read(i * 4 + 1, OAMM)
    local t = emu.read(i * 4 + 2, OAMM)
    local a = emu.read(i * 4 + 3, OAMM)
    local sh = (emu.read(512 + (i >> 2), OAMM) >> ((i & 3) * 2)) & 3
    if (sh & 1) ~= 0 then x = x - 256 end
    local sz = (sh >> 1) & 1
    local ext = sz == 1 and 16 or 8
    if y < 224 and x + ext > crop[1] and x < crop[1] + crop[3] and y + 1 + ext > crop[2] and y + 1 < crop[2] + crop[4] then
      rows[#rows + 1] = { n = i, x = x, y = y, t = t | ((a & 1) << 8), pal = (a >> 1) & 7, pr = (a >> 4) & 3, h = (a >> 6) & 1, v = (a >> 7) & 1, sz = sz }
    end
  end
  return rows
end

local function group(bank, g)
  local o = f1.romOff(bank, g)
  local hdr = {}
  for i = 0, 12 do hdr[i] = rd8(o + i) end
  local parts = {}
  for k = 0, hdr[12] - 1 do
    local q = o + 13 + 7 * k
    parts[#parts + 1] = { size = rd8(q), x = rd8(q + 1), xm = rd8(q + 2), y = rd8(q + 3), ym = rd8(q + 4), tile = rd16(q + 5) }
  end
  return hdr, parts
end

-- fixed: nil = vote for the offset; {dx, dy} = use it
local function compare(rows, hdr, parts, sx, sy, fixed)
  local dx, dy
  if fixed then
    dx, dy = fixed[1], fixed[2]
  else
    local votes = {}
    for _, r in ipairs(rows) do
      for _, p in ipairs(parts) do
        if r.sz == p.size then
          local key = string.format("%d,%d", r.x - (sx - hdr[0] + p.x), r.y - (sy - hdr[2] + p.y))
          votes[key] = (votes[key] or 0) + 1
        end
      end
    end
    local bk, bv = nil, 0
    for k, v in pairs(votes) do if v > bv then bk, bv = k, v end end
    if not bk then return nil, "no votes" end
    local a, b = bk:match("(-?%d+),(-?%d+)")
    dx, dy = tonumber(a), tonumber(b)
  end
  local used, m, hm, pm, prm = {}, 0, 0, 0, 0
  for _, p in ipairs(parts) do
    for i, r in ipairs(rows) do
      if not used[i] and r.sz == p.size and r.x == sx - hdr[0] + p.x + dx and r.y == sy - hdr[2] + p.y + dy then
        used[i] = true
        m = m + 1
        if r.h == ((p.tile >> 14) & 1) then hm = hm + 1 end
        if r.pal == ((p.tile >> 9) & 7) then pm = pm + 1 end
        if r.pr == ((p.tile >> 12) & 3) then prm = prm + 1 end
        break
      end
    end
  end
  return { dx, dy }, string.format("offset(%d,%d) matched %d/%d parts, H flip %d, palette %d, priority %d, OAM rows in crop %d", dx, dy, m, #parts, hm, pm, prm, #rows)
end

local function rowText(rows)
  local out = {}
  for _, r in ipairs(rows) do
    out[#out + 1] = string.format("n%d (%d,%d) s%d t%03X p%d pr%d%s%s", r.n, r.x, r.y, r.sz, r.t, r.pal, r.pr, r.h == 1 and " H" or "", r.v == 1 and " V" or "")
  end
  return out
end

function f2.run(o)
  local slot = o.slot or 0x1000
  local crop = o.crop or { 88, 56, 128, 112 }
  local hold = o.hold or 8
  local scale = o.scale or 2
  local idx = o.idx or 0x4B
  -- T2 runs right after the control, so a metasprite pointer equal to group + 4 of the set cannot be a leftover of another trial.
  local trials = { { tag = "T0_control" }, { tag = "T2_setaddr" }, { tag = "T1_index" } }
  local n, stage, pulse, ti, k = 0, "wait", 0, 1, 0
  local ctl, uaa, uaaAtTrial = 0, 0, 0
  emu.addMemoryCallback(function(a) if (a & 0xFFFF) == 0x36 then ctl = ctl + 1 end end, emu.callbackType.write, 0x36, 0x36, emu.cpuType.snes, emu.memType.snesWorkRam)
  -- UpdateActorAnimation entry (ROM offset 248405) with X = the host slot (X is the actor slot id at the call)
  emu.addMemoryCallback(function() if emu.getState()["cpu.x"] == slot then uaa = uaa + 1 end end, emu.callbackType.exec, 248405, 248405, emu.cpuType.snes, emu.memType.snesPrgRom)
  local lines, imgs, res = {}, {}, { trials = {} }
  local function put(s) lines[#lines + 1] = s end
  local bank, ptr0, fixed
  kit.onFrame(function()
    n = n + 1
    local sc, sn = kit.r16(0x0644), kit.r16(0x0642)
    if stage == "wait" then
      if n >= 3 and sn == 0 then
        if o.form then kit.w16(0x0AD4, o.form) end
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
      if res.settle >= (o.settle or 300) then
        stage = "run"
        bank, ptr0 = kit.r8(0x10000 + slot + 8), kit.r16(0x10000 + slot + 6)
        res.start = { frame = emu.getState().frameCount, form = kit.r16(0x0AD4), scene = sc, sprBank = bank, sprPtr = ptr0, a28 = kit.r16(slot + 0x28),
          flags10 = kit.r16(slot + 0x10), flags12 = kit.r16(slot + 0x12), oamXor = kit.r16(slot + 0x0E), pos = { kit.r16(slot + 0x14), kit.r16(slot + 0x16) },
          scroll = { kit.r16(0x068A), kit.r16(0x068E) }, playerFlags = kit.r16(0x09AE), mask = kit.r16(0x065A) }
        local tw = rd16(f1.romOff(bank, ptr0) + idx * 2)
        res.start.tableWordOfIdx = tw
        put(string.format("# %s form=%d scene=%02X spriteset=%02X:%04X a28=%d pos=(%d,%d) scroll=(%d,%d) $0E=%04X $10=%04X $12=%04X crop=%d,%d,%d,%d",
          o.name, res.start.form, sc, bank, ptr0, res.start.a28, res.start.pos[1], res.start.pos[2], res.start.scroll[1], res.start.scroll[2],
          res.start.oamXor, res.start.flags10, res.start.flags12, crop[1], crop[2], crop[3], crop[4]))
        put(string.format("# table word of idx %02X in the ROM spriteset: %04X (list at %02X:%04X)", idx, tw, bank, tw))
      end
    elseif stage == "run" then
      local t = trials[ti]
      if not t then return end
      k = k + 1
      if k == 1 then uaaAtTrial = uaa end
      if t.tag == "T1_index" then
        kit.w16(slot + 0x08, 0); kit.w16(slot + 0x24, 0); kit.w16(slot + 0x28, idx); kit.w16(slot + 0x2A, 0)
        kit.w16(0x10000 + slot + 6, ptr0)
      elseif t.tag == "T2_setaddr" then
        kit.w16(slot + 0x08, 0); kit.w16(slot + 0x24, 0); kit.w16(slot + 0x28, 0); kit.w16(slot + 0x2A, 0)
        kit.w16(0x10000 + slot + 6, ptr0 + idx * 2)
      end
      if k >= hold then
        local mp = kit.r16(0x10000 + slot + 0x0C)
        local lb, lptr, l28, l2a = kit.r8(0x10000 + slot + 8), kit.r16(0x10000 + slot + 6), kit.r16(slot + 0x28), kit.r16(slot + 0x2A)
        local lp = rd16(f1.romOff(lb, lptr) + l28 * 2)
        local recs = f1.anim(lb, lptr, l28)
        local g = mp - 4
        local want = recs[1] and (recs[1].group + 4) or -1
        local hl = {}
        for _, r in ipairs(recs) do hl[#hl + 1] = string.format("hold %d group %04X", r.hold, r.group) end
        local sx, sy = kit.r16(slot + 0x14) - kit.r16(0x068A), kit.r16(slot + 0x16) - kit.r16(0x068E)
        local rows = hostRows(crop)
        local hdr, parts = group(lb, g)
        local newFixed, text = compare(rows, hdr, parts, sx, sy, fixed)
        if t.tag == "T0_control" then fixed = newFixed end
        local img = f1.grab(crop[1], crop[2], crop[3], crop[4])
        imgs[#imgs + 1] = img
        local d = f1.encode(img, scale)
        emu.mcp.writeFile("screenshots/F2_" .. t.tag .. ".png", d)
        put(string.format("[%s] live $28=%02X $2A=%02X spriteset=%02X:%04X list=%04X mp=%04X group=%04X (list rec 0: %s) %s; UpdateActorAnimation entries with X = host slot in the trial: %d", t.tag, l28, l2a, lb, lptr, lp, mp, g,
          hl[1] or "-", (t.tag == "T0_control") and "(control, no wanted value)" or ((mp == want) and "MATCH" or "NOMATCH"), uaa - uaaAtTrial))
        put(string.format("   header ext X %d/%d Y %d/%d boxes %02X %02X %02X %02X | %02X %02X %02X %02X parts %d host screen (%d,%d)", hdr[0], hdr[1], hdr[2], hdr[3],
          hdr[4], hdr[5], hdr[6], hdr[7], hdr[8], hdr[9], hdr[10], hdr[11], hdr[12], sx, sy))
        put("   " .. (text or "no comparison") .. (t.tag ~= "T0_control" and fixed and " (offset of the control)" or ""))
        if t.tag ~= "T0_control" then
          local _, tv = compare(rows, hdr, parts, sx, sy, nil)
          put("   own vote: " .. (tv or "no comparison"))
        end
        put("   oam " .. table.concat(rowText(rows), "; "))
        res.trials[#res.trials + 1] = { tag = t.tag, a28 = l28, a2a = l2a, list = lp, mp = mp, group = g, rows = #rows, compare = text, png = #d, uaaCalls = uaa - uaaAtTrial }
        k = 0; ti = ti + 1
        if ti > #trials then
          local sh = f1.sheet(imgs, #imgs)
          emu.mcp.writeFile("screenshots/F2_sheet.png", f1.encode(sh, 1))
          emu.mcp.writeFile("F2_oam.txt", table.concat(lines, "\n") .. "\n", false)
          res.control36Writes, res.frames = ctl, n
          kit.finish(res)
        end
      end
    end
  end)
end
