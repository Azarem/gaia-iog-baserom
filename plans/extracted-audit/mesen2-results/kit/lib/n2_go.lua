-- description: N2 game over experiments: natural save / revive records through two real warps (stageE8), and the GameOverSequence run with per-frame sparkle, fade and OAM recording (gameover).
-- requires: mesen_kit, iog_kit, gaia_kit, m1_kit, n1_kit, n2_kit
--
-- ROM O offsets (decimal ; {n} tags of extract:lt): GameOverSequence 54831, GameOverChooseRespawn gem test LDA 54924, GameOverRealDeath 54957, GameOverRespawnTail first LDA 55014,
-- tail STZ worldReadyFlag 55058, GameOverCutsceneSprites 55064..55117, GameOverSparkleOrbitA 55118..55153, GameOverSparkleOrbitB 55154..55189.
-- The sparkle entries are matched by range, because the entry word moves inside the actor body after every COP wait.
n2go = n2go or {}

local P   = emu.memType.snesPrgRom
local CPU = emu.cpuType.snes
local OAMM = emu.memType.snesSpriteRam

local function h4(v) return string.format("%04X", v) end

-- the 7 record bytes at bank:ptr (ROM file offset, bank mirror removed)
local function recBytes(ptr, bank)
  local off = ((bank & 0x3F) << 16) | ptr
  local t = {}
  for i = 0, 7 do t[#t + 1] = string.format("%02X", emu.read(off + i, P)) end
  return string.format("%02X:%04X @%d = %s", bank, ptr, off, table.concat(t, " "))
end

local function records(tag)
  return string.format("%s save($0AF0/$0AF2)=%s | revive($0AF4/$0AF6)=%s", tag, recBytes(kit.r16(0x0AF0), kit.r16(0x0AF2) & 0xFF), recBytes(kit.r16(0x0AF4), kit.r16(0x0AF6) & 0xFF))
end

local function dismissBanner(m)
  local pulse, n = 0, 0
  while kit.r8(0x00B4) ~= 0 and n < 400 do
    pulse = pulse + 1
    gaia.hold((pulse % 6 < 3) and { "a" } or {})
    m.wait(1); n = n + 1
  end
  gaia.release()
end

-- Wait for sceneCurrent == scene (sceneNext back to 0), pulsing A while the title banner flag $00B4 is set (the banner wait loop blocks the warp until a button press).
function n2go.waitScene(m, scene, maxn)
  local n, pulse = 0, 0
  while n < (maxn or 600) do
    if kit.r8(0x00B4) ~= 0 then pulse = pulse + 1; gaia.hold((pulse % 6 < 3) and { "a" } or {}) else gaia.release() end
    m.wait(1); n = n + 1
    -- sceneCurrent changes when the load starts; the scene is running again once the screen is back at full brightness (about 275 frames later for a natural warp)
    if kit.r16(0x0644) == scene and kit.r16(0x0642) == 0 and kit.r8(0x00B4) == 0 and emu.getState()["ppu.screenBrightness"] == 15 then break end
  end
  gaia.release()
  return n
end

-- Pulse A until the joypad mask $065A is 0 and displayModeFlags $09EC is 0 for 20 frames in a row (scene entry dialogues block the main loop, so no warp check runs meanwhile). Returns frames used.
function n2go.clearDialog(m, maxn)
  local n, quiet = 0, 0
  while n < (maxn or 600) and quiet < 20 do
    if kit.r16(0x065A) ~= 0 or kit.r16(0x09EC) ~= 0 then quiet = 0; gaia.hold((n % 8 < 4) and { "a" } or {}) else quiet = quiet + 1; gaia.release() end
    m.wait(1); n = n + 1
  end
  gaia.release()
  return n
end

-- Move the player actor by at most `step` px per axis per frame until it reaches (x, y) (actor coordinates; player copy $09A2/$09A4 = actor - 8 / - 16).
-- A single far jump hangs the map streaming loop (brightness 0, $36 frozen), so the poke is applied in small steps. Returns the frames used.
function n2go.walkTo(m, x, y, step)
  step = step or 3
  local n = 0
  while n < 600 do
    local ax, ay = kit.r16(0x1014), kit.r16(0x1016)
    if ax == x and ay == y then break end
    local function mv(a, b) if a < b then return math.min(a + step, b) elseif a > b then return math.max(a - step, b) else return a end end
    n1.teleport(mv(ax, x), mv(ay, y))
    m.wait(1); n = n + 1
  end
  return n
end

-- Walk (teleport onto the warp rectangle: disclosed poke of the player position) through two real warps so both records are written by ExecuteWarp:
--   scene $1A entry ;01 (rect tile 0C,17 1x2, dest $1B, flag $80 = save warp), then scene $1B entry ;00 (rect 0F,1D 2x2, dest $1A, flag $03 = plain warp).
-- Then quick-warp to scene $E8 and stop (the emulator is left running the scene; save the state afterwards).
function n2go.stageE8(o)
  o = o or {}
  m1.run(function(m)
    local L = m.log
    L("%s", "start scene=" .. h4(kit.r16(0x0644)))
    L("%s", records("before"))
    local w = m.warp(0x1A, 20)
    L("quick warp $1A frames=%s scene=%s", tostring(w), h4(kit.r16(0x0644)))
    L("%s", records("in $1A"))
    local nw = n2go.walkTo(m, 200, 388) -- player pos (192, 372): inside rect 0C,17 1x2 (x == 192, y 368..384)
    L("walked %d frames, scene=%s", nw, h4(kit.r16(0x0644)))
    local n = n2go.waitScene(m, 0x1B, 900)
    L("save warp: scene=%s after %d frames, sceneNext=%s", h4(kit.r16(0x0644)), n, h4(kit.r16(0x0642)))
    L("entry dialogue cleared after %d frames", n2go.clearDialog(m))
    L("%s", records("in $1B (after save warp)"))
    L("in $1B player=(%d,%d)", kit.r16(0x1014), kit.r16(0x1016))
    nw = n2go.walkTo(m, 252, 484) -- player pos (244, 468): inside rect 0F,1D 2x2 (x 240..257, y 464..481)
    L("walked %d frames, scene=%s", nw, h4(kit.r16(0x0644)))
    n = n2go.waitScene(m, 0x1A, 900)
    L("plain warp: scene=%s after %d frames, player=(%d,%d)", h4(kit.r16(0x0644)), n, kit.r16(0x1014), kit.r16(0x1016))
    L("entry dialogue cleared after %d frames", n2go.clearDialog(m))
    L("%s", records("in $1A (after plain warp back)"))
    local w2 = m.warp(0xE8, 40)
    L("quick warp $E8 frames=%s scene=%s form=%d hp=%d/%d gems=%d", tostring(w2), h4(kit.r16(0x0644)), kit.r16(0x0AD4), kit.r16(0x0ACE), kit.r16(0x0ACA), kit.r16(0x0AD6))
    L("%s", records("in $E8"))
    return { lines = m.lines, scene = kit.r16(0x0644) }
  end, o)
end

-- Poke HP := 0 (and optionally the gem count), run to the first frame with playerFlags $0200, then `k` frames more and stop there (the emulator stays paused at death frame d = k
-- so the caller can take screenshots / OAM dumps with advance_frame + take_screenshot).
function n2go.deathAt(o)
  o = o or {}
  m1.run(function(m)
    if o.gems then kit.w16(0x0AD6, o.gems) end
    kit.w16(0x0ACE, 0)
    local n = 0
    while (kit.r16(0x09AE) & 0x0200) == 0 and n < 300 do m.wait(1); n = n + 1 end
    m.wait(o.k or 1)
    m.log("death flag after %d frames; stopped at d=%d $36=%d", n, o.k or 1, kit.r16(0x36))
    return { lines = m.lines }
  end, o)
end

-- Game over in the current scene. o.gems = gem count to poke (nil keeps it), o.hp0 = write HP 0 at frame 1 (always; disclosed poke), o.sample = print a row every o.sample frames.
-- Records per frame (relative to the first frame with playerFlags $0200): frame counter delta, INIDISP brightness, player $10, sparkle actors (dx, dy from the player, $10 depth bits, anim),
-- spawner liveness and the OAM sprites whose tile ids appeared with the first sparkle.
function n2go.gameover(o)
  o = o or {}
  local H = {}
  emu.addMemoryCallback(function()
    H.gemTest = H.gemTest or {}
    H.gemTest[#H.gemTest + 1] = string.format("gem test: gems=%d hp=%d/%d form=%d scene=%02X", kit.r16(0x0AD6), kit.r16(0x0ACE), kit.r16(0x0ACA), kit.r16(0x0AD4), kit.r16(0x0644) & 0xFF)
  end, emu.callbackType.exec, 54924, 54924, CPU, P)
  emu.addMemoryCallback(function()
    local st = emu.getState()
    H.realDeath = (H.realDeath or 0) + 1
  end, emu.callbackType.exec, 54957, 54957, CPU, P)
  emu.addMemoryCallback(function()
    local st = emu.getState()
    H.tail = string.format("tail enter: Y=%04X DBR=%02X gems=%d hp=%d form=%d wramFlags=%s", st["cpu.y"], st["cpu.dbr"], kit.r16(0x0AD6), kit.r16(0x0ACE), kit.r16(0x0AD4),
      (function() local t = {} for i = 0, 15 do t[#t + 1] = string.format("%04X", kit.r16(0x0A80 + i * 2)) end return table.concat(t, " ") end)())
  end, emu.callbackType.exec, 55014, 55014, CPU, P)
  emu.addMemoryCallback(function()
    H.tailEnd = string.format("tail done: sceneNext=%02X dest=(%d,%d) facing=%02X scroll=%04X wakeup=%d gems=%d hp=%d/%d form=%d", kit.r16(0x0642) & 0xFF, kit.r16(0x064C), kit.r16(0x064E),
      kit.r16(0x0650) & 0xFF, kit.r16(0x0652), kit.r16(0x0AF8), kit.r16(0x0AD6), kit.r16(0x0ACE), kit.r16(0x0ACA), kit.r16(0x0AD4))
    H.target = kit.r16(0x0642) & 0xFF
  end, emu.callbackType.exec, 55058, 55058, CPU, P)

  local function oamOn()
    local t = {}
    for i = 0, 127 do
      local y = emu.read(i * 4 + 1, OAMM)
      local x = emu.read(i * 4, OAMM)
      local sh = (emu.read(512 + (i >> 2), OAMM) >> ((i & 3) * 2)) & 3
      if (sh & 1) ~= 0 then x = x - 256 end
      y = y + 1
      if y < 224 and x > -16 and x < 256 then
        t[#t + 1] = { i = i, x = x, y = y, t = emu.read(i * 4 + 2, OAMM) | ((emu.read(i * 4 + 3, OAMM) & 1) << 8), sz = (sh >> 1) & 1 }
      end
    end
    return t
  end

  m1.run(function(m)
    local L = m.log
    if o.gems then kit.w16(0x0AD6, o.gems) end
    if o.flags then kit.w16(0x0A80, 0x1234); kit.w16(0x0A9E, 0x00FF) end -- disclosed poke: non-zero first and last wramFlags words
    if o.form then kit.w16(0x0AD4, o.form) end
    local pre = string.format("before: scene=%02X gems=%d hp=%d/%d form=%d $0AF0=%02X:%04X $0AF4=%02X:%04X", kit.r16(0x0644) & 0xFF, kit.r16(0x0AD6), kit.r16(0x0ACE), kit.r16(0x0ACA), kit.r16(0x0AD4),
      kit.r16(0x0AF2) & 0xFF, kit.r16(0x0AF0), kit.r16(0x0AF6) & 0xFF, kit.r16(0x0AF4))
    L("%s wramFlags[0]=%04X wramFlags[15]=%04X", pre, kit.r16(0x0A80), kit.r16(0x0A9E))
    L("%s", records("records"))
    local baseline = oamOn()
    m.wait(1)
    local scene0 = kit.r16(0x0644) & 0xFF
    kit.w16(0x0ACE, 0) -- disclosed poke: HP := 0
    local d0, d, tiles, firstSpark, lastSpark = nil, 0, nil, nil, nil
    local rowsS, vis, bright, firstBlack = {}, {}, {}, nil
    local sp = {}      -- slot -> { first, last, front, behind, pts = {{dx,dy,depth}} }
    local order = {}
    local spawner = { first = nil, last = nil }
    local plot = {}
    local frames, arrived = 0, nil
    local sample = o.sample or 10
    local tgt = nil
    while frames < 700 do
      m.wait(1); frames = frames + 1
      local pf = kit.r16(0x09AE)
      if not d0 and (pf & 0x0200) ~= 0 then d0 = frames end
      if d0 then
        d = frames - d0
        local px, py = kit.r16(0x1014), kit.r16(0x1016)
        local alive = 0
        local rowS = {}
        local spwn = false
        for _, s in ipairs(n1.live()) do
          local r = n1.rom(n1.ent(s))
          if r >= 55118 and r <= 55189 then
            alive = alive + 1
            local S = sp[s]
            if not S then S = { first = d, front = 0, behind = 0, pts = {}, kind = (r < 55154) and "A" or "B", slot = s }; sp[s] = S; order[#order + 1] = s end
            S.last = d
            local f10 = kit.r16(s + 0x10)
            -- absolute world position (signed 16 bit); the camera is at (0,0) in this scene, so world = screen
            local dx, dy = kit.r16(s + 0x14), kit.r16(s + 0x16)
            if dx >= 0x8000 then dx = dx - 0x10000 end
            if dy >= 0x8000 then dy = dy - 0x10000 end
            if (f10 & 2) ~= 0 then S.front = S.front + 1 elseif (f10 & 1) ~= 0 then S.behind = S.behind + 1 end
            S.pts[#S.pts + 1] = { d, dx, dy, f10 & 3 }
            S.on = (S.on or 0) + ((dx >= 0 and dx < 256 and dy >= 0 and dy < 224) and 1 or 0)
            S.onFirst = S.onFirst or ((dx >= 0 and dx < 256 and dy >= 0 and dy < 224) and d or nil)
            if dx >= 0 and dx < 256 and dy >= 0 and dy < 224 then S.onLast = d; H.onSet = H.onSet or {}; H.onSet[d] = true end
            rowS[#rowS + 1] = string.format("%s%04X(%d,%d,%d)", S.kind, s, dx, dy, f10 & 3)
            H.sp = H.sp or {}
            H.sp[#H.sp + 1] = { S = S, x = dx, y = dy }
          elseif r >= 55064 and r <= 55117 then
            spwn = true
          end
        end
        if spwn then spawner.first = spawner.first or d; spawner.last = d end
        -- OAM proximity: a sparkle is drawn this frame when an on-screen OAM sprite box (8x8 or 16x16) contains a point within 4 px of its world position (world = screen here)
        if H.sp and #H.sp > 0 then
          local oam = oamOn()
          local anyV = false
          for _, e in ipairs(H.sp) do
            local hit = false
            for _, c in ipairs(oam) do
              local w = (c.sz == 1) and 16 or 8
              if e.x >= c.x - 4 and e.x <= c.x + w + 4 and e.y >= c.y - 4 and e.y <= c.y + w + 4 then hit = true; break end
            end
            if hit then e.S.vis = (e.S.vis or 0) + 1; anyV = true end
          end
          if anyV then H.visAny = (H.visAny or 0) + 1 end
          H.sp = {}
        end
        if alive > 0 then
          firstSpark = firstSpark or d; lastSpark = d
          if not tiles and d - firstSpark >= 2 then
            -- tile ids that were not on screen before the first sparkle
            local seen = {}
            for _, b in ipairs(baseline) do seen[b.t] = true end
            local cand = {}
            for _, c in ipairs(oamOn()) do if not seen[c.t] then cand[c.t] = true end end
            tiles = cand
            local tl = {}
            for tt in pairs(cand) do tl[#tl + 1] = string.format("%03X", tt) end
            table.sort(tl)
            L("d=%d sparkle OAM tile ids new vs baseline: %s", d, table.concat(tl, " "))
          end
        end
        local nv = 0
        if tiles then
          for _, c in ipairs(oamOn()) do if tiles[c.t] then nv = nv + 1 end end
        end
        vis[#vis + 1] = { d, alive, nv }
        local st = emu.getState()
        local br = st["ppu.screenBrightness"]
        bright[#bright + 1] = br
        if br == 0 and not firstBlack then firstBlack = d end
        if d % sample == 0 or (alive > 0 and (firstSpark == d)) then
          L("d=%d $36=%d bright=%d player=(%d,%d) f10=%04X alive=%d oamT=%d spawner=%s %s", d, kit.r16(0x36), br, px, py, kit.r16(0x1010), alive, nv, tostring(spwn), table.concat(rowS, " "))
        end
      end
      if H.target and not tgt then tgt = H.target; L("tail target scene %02X at d=%d", tgt, d) end
      if tgt and (kit.r16(0x0644) & 0xFF) == tgt and kit.r16(0x0642) == 0 then arrived = arrived or frames end
      if arrived and frames - arrived >= 60 then break end
    end
    -- results
    for i = 1, #H.gemTest or 0 do L("%s", H.gemTest[i]) end
    L("realDeath path execs=%d", H.realDeath or 0)
    L("%s", H.tail or "no tail")
    L("%s", H.tailEnd or "no tailEnd")
    L("after: scene=%02X gems=%d hp=%d/%d form=%d player=(%d,%d) wakeup=%d dialog? $B4=%02X $0AF0=%02X:%04X $0AF4=%02X:%04X wramFlags=%s", kit.r16(0x0644) & 0xFF, kit.r16(0x0AD6),
      kit.r16(0x0ACE), kit.r16(0x0ACA), kit.r16(0x0AD4), kit.r16(0x1014), kit.r16(0x1016), kit.r16(0x0AF8), kit.r8(0x00B4), kit.r16(0x0AF2) & 0xFF, kit.r16(0x0AF0), kit.r16(0x0AF6) & 0xFF, kit.r16(0x0AF4),
      (function() local t = {} for i = 0, 15 do t[#t + 1] = string.format("%04X", kit.r16(0x0A80 + i * 2)) end return table.concat(t, " ") end)())
    -- sparkle summary
    local sum = {}
    for _, s in ipairs(order) do
      local S = sp[s]
      sum[#sum + 1] = string.format("%s%04X alive d=%d..%d (%d frames) front=%d behind=%d oamNear=%d", S.kind, s, S.first, S.last, S.last - S.first + 1, S.front, S.behind, S.vis or 0)
    end
    L("sparkles: %s", table.concat(sum, " | "))
    L("frames with >=1 sparkle having an OAM sprite box around its position: %d", H.visAny or 0)
    local nOn, onFirst, onLast = 0, nil, nil
    for dd, _ in pairs(H.onSet or {}) do nOn = nOn + 1; onFirst = math.min(onFirst or dd, dd); onLast = math.max(onLast or dd, dd) end
    L("frames with >=1 sparkle actor inside the 256x224 screen (world = screen): %d, first d=%s last d=%s", nOn, tostring(onFirst), tostring(onLast))
    L("spawner d=%s..%s; first/last frame with >=1 sparkle actor d=%s..%s", tostring(spawner.first), tostring(spawner.last), tostring(firstSpark), tostring(lastSpark))
    local nAlive, nVis, nBoth = 0, 0, 0
    for _, v in ipairs(vis) do
      if v[2] > 0 then nAlive = nAlive + 1 end
      if v[3] > 0 then nVis = nVis + 1 end
      if v[2] > 0 and v[3] > 0 then nBoth = nBoth + 1 end
    end
    L("frames with a sparkle actor=%d, frames with >=1 sparkle-tile OAM sprite on screen=%d, both=%d; first black INIDISP d=%s", nAlive, nVis, nBoth, tostring(firstBlack))
    -- brightness series (only changes)
    local bs, pb = {}, nil
    for i, b in ipairs(bright) do if b ~= pb then bs[#bs + 1] = string.format("d=%d:%d", vis[i][1], b); pb = b end end
    L("INIDISP brightness changes: %s", table.concat(bs, " "))
    -- visible-count runs of the OAM test: (alive, nv) per frame compressed
    local runs, cur = {}, nil
    for _, v in ipairs(vis) do
      local key = v[2] .. "/" .. v[3]
      if cur and cur.k == key then cur.n = cur.n + 1 else cur = { k = key, n = 1, d = v[1] }; runs[#runs + 1] = cur end
    end
    local rs = {}
    for _, r in ipairs(runs) do if r.k ~= "0/0" then rs[#rs + 1] = string.format("d%d:%s x%d", r.d, r.k, r.n) end end
    if o.brief then return { lines = m.lines, frames = frames, d0 = d0 } end
    L("alive/oam runs (first at d): %s", table.concat(rs, " "))
    -- ASCII plot of every sparkle path: columns dx -40..+40 step 2, rows dy -60..+12 step 3 (x = behind, # = front)
    local grid = {}
    for r = 0, 27 do grid[r] = {} for c = 0, 63 do grid[r][c] = " " end end
    local offTop, offOther = 0, 0
    for _, s in ipairs(order) do
      for _, p in ipairs(sp[s].pts) do
        local c = p[2] // 4
        local r = p[3] // 8
        if c >= 0 and c <= 63 and r >= 0 and r <= 27 then
          local ch = (p[4] == 2) and "#" or "x"
          if grid[r][c] == " " or ch == "#" then grid[r][c] = ch end
        elseif p[3] < 0 then offTop = offTop + 1 else offOther = offOther + 1 end
      end
    end
    L("plot of the on-screen part of the sparkle paths: screen x 0..255 (4 px per column), y 0..223 (8 px per row); # depth $0002 (in front), x depth $0001 (behind); off-screen points above y=0: %d, other: %d", offTop, offOther)
    for r = 0, 27 do L("%s", string.format("%3d|%s|", r * 8, table.concat(grid[r]))) end
    -- raw positions of each sparkle for the first 40 frames of its life and extremes
    for _, s in ipairs(order) do
      local S = sp[s]
      local minx, maxx, miny, maxy = 999, -999, 999, -999
      for _, p in ipairs(S.pts) do minx = math.min(minx, p[2]); maxx = math.max(maxx, p[2]); miny = math.min(miny, p[3]); maxy = math.max(maxy, p[3]) end
      local lst = {}
      for i = 1, #S.pts, 6 do local p = S.pts[i]; lst[#lst + 1] = string.format("%d:(%d,%d,%d)", p[1], p[2], p[3], p[4]) end
      L("%s%04X x %d..%d y %d..%d on-screen frames=%d (d=%s..%s) samples(d:(x,y,depth)): %s", S.kind, s, minx, maxx, miny, maxy, S.on or 0, tostring(S.onFirst), tostring(S.onLast), table.concat(lst, " "))
    end
    return { lines = m.lines, frames = frames, d0 = d0 }
  end, o)
end
