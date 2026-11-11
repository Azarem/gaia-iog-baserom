-- description: G2 experiment scripts (counter census with re-entry, last-kill reward chain, EnemyDefeatDispatch rooms, boss handler, game over, stat-up, heal sparkle, pickup blink).
-- requires: mesen_kit, iog_kit, gaia_kit, a_census, a_actors, g1_kit, g2_kit
--
-- Every function takes the scaffold S = g2.new{...} and registers hooks and per-frame stages; the caller finishes with S:finish when S.over is set.
g2r = g2r or {}

local r8, r16, w8, w16 = kit.r8, kit.r16, kit.w8, kit.w16
local O = g2.OFF

local function pc24()
  local st = emu.getState()
  return ((st["cpu.k"] or 0) << 16) | (st["cpu.pc"] or 0)
end
g2r.pc24 = pc24

-- terse watcher: logs a row whenever one of the watched values changes
function g2r.watch(S, fields)
  local prev = {}
  return function(tag)
    for _, f in ipairs(fields) do
      local v = f.get()
      if prev[f.name] ~= v then
        S:log("%s%s %s -> %s", tag or "", f.name, tostring(prev[f.name]), type(v) == "number" and string.format("%X", v) or tostring(v))
        prev[f.name] = v
      end
    end
  end
end

function g2r.counters() return string.format("$0AEC=%d $0AEE=%02X flag0300(scene)=%d", r16(0x0AEC), r16(0x0AEE), g2.flag0300(r16(0x0644))) end

-- k1: counter census. Kill the bats of one room one at a time; between the first and the second kill leave the room and come back.
-- o = { away = scene to visit, kills = number of kills before the trip }
function g2r.k1(S, o)
  local W, D = g2.warper(), g2.driver(S)
  S:wr(0x0AEC, 0x0AEF, function(a, v) S:log("W %04X <- %02X pc=%06X", a & 0xFFFF, v & 0xFF, pc24()) end)
  S:wr(0x0A80, 0x0A9F, function(a, v) S:log("W wramFlag %04X <- %02X pc=%06X", a & 0xFFFF, v & 0xFF, pc24()) end)
  S:wr(0x0A60, 0x0A7F, function(a, v) S:log("W flag0300 byte %04X <- %02X pc=%06X", a & 0xFFFF, v & 0xFF, pc24()) end)
  local ae4 = {}
  S:wr(0x0AE4, 0x0AE5, function(a, v) local k = string.format("W %04X pc=%06X", a & 0xFFFF, pc24()); ae4[k] = (ae4[k] or 0) + 1; S:inc("ae4_writes") end)
  S:rd(0x0AE4, 0x0AE5, function(a, v) local k = string.format("R %04X pc=%06X", a & 0xFFFF, pc24()); ae4[k] = (ae4[k] or 0) + 1; S:inc("ae4_reads") end)
  S.ae4 = ae4
  S:ex(O.STAT_BONUS, function() S:log("EnemyStatBonusReward entered cnt=%d", r16(0x0AEC)) end)
  local stage, vic, wait = "a0", nil, 0
  local function live() return g2.enemies() end
  local function listEnemies(tag)
    local t = {}
    for _, e in ipairs(live()) do t[#t + 1] = string.format("%04X(row%02X en=%02X)", e.slot, e.row.idx, r16(0x10022 + e.slot) & 0xFF) end
    S:log("%s enemies=%s %s wramFlags=%s", tag, table.concat(t, " "), g2r.counters(), g2.wramFlags())
  end
  S.kills = 0
  local wch = g2r.watch(S, {
    { name = "dmf&0080", get = function() return r16(0x09EC) & 0x80 end }, { name = "maxHp", get = function() return r16(0x0ACA) end },
    { name = "str", get = function() return r16(0x0ADE) end }, { name = "def", get = function() return r16(0x0ADC) end },
    { name = "hpToHeal", get = function() return r16(0x0B22) end }, { name = "scene", get = function() return r16(0x0644) end },
  })
  S:frame(function(t)
    wch("")
    W.step(); D.step()
    kit.w16(0x0ACE, kit.r16(0x0ACA)) -- keep HP full
    if stage == "a0" then
      if t >= 2 then
        listEnemies("start")
        local l = live()
        vic = l[1] and l[1].slot
        S:log("victim slot %s", tostring(vic))
        if vic then D.start(vic); stage = "kill" end
      end
    elseif stage == "kill" then
      if D.state == "done" or D.state == "timeout" then
        wait = wait + 1
        if wait > 60 then
          S.kills = S.kills + 1
          listEnemies(string.format("after kill %d (state %s, waited %d)", S.kills, D.state, wait))
          wait = 0
          if S.kills == o.kills and o.away then W.go(o.away); stage = "away"
          else
            local l = live()
            vic = l[1] and l[1].slot
            if vic then D.start(vic) else stage = "end" end
          end
        end
      end
    elseif stage == "away" then
      if W.state == "done" or W.state == "fail" then
        listEnemies("in scene " .. string.format("%02X", r16(0x0644)) .. " (" .. W.state .. ")")
        W.go(o.home); stage = "home"
      end
    elseif stage == "home" then
      if W.state == "done" or W.state == "fail" then
        listEnemies("back in scene " .. string.format("%02X", r16(0x0644)) .. " (" .. W.state .. ")")
        local l = live()
        vic = l[1] and l[1].slot
        if vic then D.start(vic); stage = "kill" else stage = "end" end
      end
    elseif stage == "end" then
      wait = wait + 1
      if wait == 400 then S.over = true end
    end
  end)
end

-- k2: last-kill reward chain with other actors alive.
-- Setup poke (disclosed): $0AEC := 1 and $0AEE := 1 (BCD) so the first kill is the "last enemy" while the room keeps its roaming actors.
-- o = { victim = slot, holdRight = bool, clearFlash = bool (clear $12 bit $1000 of the death flash right after its spawn), frames = observation length }
function g2r.k2(S, o)
  local D = g2.driver(S)
  local flash, snap = nil, nil
  local prevPos, phase = {}, "pre"
  local playerPrev = nil
  S.cnt.frames_pre, S.cnt.frames_filter, S.cnt.frames_post = 0, 0, 0
  -- SetSpritePalette #00 at the head of EnemyStatBonusReward: byte diff of the 0x30-byte slot around the COP (A = tag 56711 -> 56714, 56733 -> 56736)
  local function snapshot(x) local t = {}; for i = 0, 0x2F do t[i] = r8(x + i) end; return t end
  local function diff(a, b) local d = {}; for i = 0, 0x2F do if a[i] ~= b[i] then d[#d + 1] = string.format("+%02X %02X->%02X", i, a[i], b[i]) end end; return #d == 0 and "no change" or table.concat(d, " ") end
  S:ex(56711, function() snap = snapshot(emu.getState()["cpu.x"]) end)
  S:ex(56714, function() if snap then S:log("SetSpritePalette #00 (56711) victim f10=%04X $0E before=%04X after=%04X; slot diff: %s", r16(emu.getState()["cpu.x"] + 0x10), snap[0x0E] | (snap[0x0F] << 8), r16(emu.getState()["cpu.x"] + 0x0E), diff(snap, snapshot(emu.getState()["cpu.x"]))) end end)
  S:ex(56733, function() snap = snapshot(emu.getState()["cpu.x"]) end)
  S:ex(56736, function() if snap then S:log("SetSpritePalette #00 (56733) slot diff: %s", diff(snap, snapshot(emu.getState()["cpu.x"]))) end end)
  S:ex(56282, function()
    flash = emu.getState()["cpu.y"]; S.flashT = S.t
    S:log("flash slot=%04X f12=%04X ent=%06X", flash, r16(flash + 0x12), aact.ent(flash))
    if o.clearFlash then aact.clrf(flash, 0x12, 0x1000); S:log("flash $12 bit $1000 cleared (disclosed poke) f12=%04X", r16(flash + 0x12)) end
  end)
  S:ex(O.STAT_BONUS, function() S:log("EnemyStatBonusReward entered $0AEC=%d scene=%02X", r16(0x0AEC), r16(0x0644)) end)
  S:ex(56758, function() S:log("e_hp_increase spawn (tier 1)") end)
  S:ex(57616, function() S:log("RewardActorVFX entered") end)
  S:ex(57662, function() S:log("RewardActorVFX: pickup arrived at player; dmf=%04X", r16(0x09EC)) end)
  S:ex(57404, function() S:log("e_hp_increase: after CallNear returns, maxHp=%d", r16(0x0ACA)) end)
  S:wr(0x0A60, 0x0A7F, function(a, v) S:log("W flag0300 byte %04X <- %02X pc=%06X", a & 0xFFFF, v & 0xFF, pc24()) end)
  local started, tEnd = false, nil
  local nflags = 0
  S:frame(function(t)
    D.step()
    if t == 1 and not started then
      started = true
      w16(0x0AEC, 1); w16(0x0AEE, 1)
      S:log("poked $0AEC=1 $0AEE=1; victim=%04X; roaming list: %s", o.victim, (function()
        local out = {}
        for _, e in ipairs(g2.enemies()) do out[#out + 1] = string.format("%04X", e.slot) end
        return table.concat(out, " ")
      end)())
      if o.pokePal then w16(o.victim + 0x0E, r16(o.victim + 0x0E) | o.pokePal); S:log("poked victim $0E |= %04X -> %04X", o.pokePal, r16(o.victim + 0x0E)) end
      D.start(o.victim)
    end
    w16(0x0ACE, r16(0x0ACA) > r16(0x0ACE) and r16(0x0ACE) or r16(0x0ACA))
    -- phase by displayModeFlags bit 7 and the reward spawn
    local filt = (r16(0x09EC) & 0x80) ~= 0
    local newPhase = phase
    if filt then newPhase = "filter" elseif phase == "filter" then newPhase = "post" end
    if newPhase ~= phase then
      S:log("phase %s -> %s dmf=%04X", phase, newPhase, r16(0x09EC)); phase = newPhase
      if phase == "filter" and o.holdRight then gaia.hold({ "right" }) end
      if phase == "post" then tEnd = t end
    end
    if t >= 2 then
      -- count actors that moved this frame, split by the $12 bit $1000
      local mv, mv1000 = 0, 0
      for _, s in ipairs(aact.live()) do
        if s ~= 0x1000 then
          local x, y = r16(s + 0x14), r16(s + 0x16)
          local p = prevPos[s]
          if p and (p[1] ~= x or p[2] ~= y) then
            if (r16(s + 0x12) & 0x1000) ~= 0 then mv1000 = mv1000 + 1 else mv = mv + 1 end
          end
          prevPos[s] = { x, y }
        end
      end
      local px = r16(0x1014)
      local pm = (playerPrev and playerPrev ~= px) and 1 or 0
      playerPrev = px
      S.cnt["frames_" .. phase] = (S.cnt["frames_" .. phase] or 0) + 1
      S.cnt["movedNon1000_" .. phase] = (S.cnt["movedNon1000_" .. phase] or 0) + mv
      S.cnt["moved1000_" .. phase] = (S.cnt["moved1000_" .. phase] or 0) + mv1000
      S.cnt["playerMoved_" .. phase] = (S.cnt["playerMoved_" .. phase] or 0) + pm
      if flash and not S.flashGone and not aact.inList(flash) then S.flashGone = true; S:log("flash left the actor list (phase %s); spawned at t=%s", phase, tostring(S.flashT)) end
      if flash and (phase == "filter") and nflags < 3 then
        nflags = nflags + 1
        S:log("filter frame: flash in list=%s f12=%04X anim28=%04X pos=(%d,%d) player=(%d,%d)", tostring(aact.inList(flash)), r16(flash + 0x12), r16(flash + 0x28), r16(flash + 0x14), r16(flash + 0x16), r16(0x1014), r16(0x1016))
      end
    end
    if phase == "post" and tEnd and t - tEnd >= 40 then gaia.release(); S.over = true end
    if t > (o.frames or 900) then gaia.release(); S.over = true end
  end)
end

-- killAll: kill every enemy of the room one after the other (driver), with hooks on the defeat dispatch, the field reveal object and the reward.
-- o = { max = kills, pre = function() end (run at t == 1), settle = frames after a kill, tail = frames after the last kill }
function g2r.killAll(S, o)
  local D = g2.driver(S)
  S:ex(O.DISPATCH, function() local x = emu.getState()["cpu.x"]; S:log("EnemyDefeatDispatch entered X=%04X $0AEC=%d", x, r16(0x0AEC)) end)
  S:ex(O.DISPATCH_NOTLAST, function() S:log("EnemyDefeatDispatch: not-last path") end)
  S:ex(697435, function() S:log("EnemyDefeatDispatch: last-enemy path -> JumpFar StandardEnemyDefeatHandler") end)
  S:ex(55928, function() local x = emu.getState()["cpu.x"]; S:log("field_reveal_object entry child=%04X $26=%d statsPtr=%04X", x, r16(x + 0x26), r16(0x10020 + x)) end)
  S:ex(56079, function() local st = emu.getState(); S:log("field_reveal_object item id=%02X (child %04X)", st["cpu.a"] & 0xFF, st["cpu.x"]) end)
  S:ex(O.STD_DEFEAT, function() local x = emu.getState()["cpu.x"]; S:inc("std_defeat_entries") end)
  S:ex(O.GEM_JMP, function() S:inc("gem_path") end)
  S:ex(O.STAT_BONUS, function() S:log("EnemyStatBonusReward entered $0AEC=%d", r16(0x0AEC)) end)
  S:ex(57662, function() S:log("RewardActorVFX: pickup arrived") end)
  S:wr(0x0A60, 0x0A7F, function(a, v) S:log("W flag0300 byte %04X <- %02X pc=%06X", a & 0xFFFF, v & 0xFF, pc24()) end)
  local stage, vic, wait = "a0", nil, 0
  S.kills = 0
  S:frame(function(t)
    D.step()
    w16(0x0ACE, r16(0x0ACA)); w16(0x11028, 0x0100)
    if stage == "a0" then
      if t == 1 and o.pre then o.pre() end
      if t >= 2 then
        local l = g2.enemies()
        S:log("start: %d enemies, $0AEC=%d $0AEE=%02X maxHp=%d str=%d def=%d", #l, r16(0x0AEC), r16(0x0AEE), r16(0x0ACA), r16(0x0ADE), r16(0x0ADC))
        stage = "next"
      end
    elseif stage == "next" then
      local l = g2.enemies()
      if #l == 0 or S.kills >= (o.max or 99) then stage = "tail"; wait = 0
      else
        local pk = (o.pick and o.pick(l)) or l[1]
        vic = pk.slot
        S:log("kill %d: victim %04X ent=%06X row=%02X gem=%d $0AEC=%d", S.kills + 1, vic, aact.ent(vic), pk.row.idx, pk.row.gem, r16(0x0AEC))
        D.start(vic); stage = "kill"; wait = 0
      end
    elseif stage == "kill" then
      if D.state == "done" or D.state == "timeout" then
        wait = wait + 1
        if wait >= (o.settle or 70) then
          S.kills = S.kills + 1
          S:log("after kill %d (%s): $0AEC=%d $0AEE=%02X flag0300=%d dmf=%04X", S.kills, D.state, r16(0x0AEC), r16(0x0AEE), g2.flag0300(r16(0x0644)), r16(0x09EC))
          stage = "next"
        end
      end
    elseif stage == "tail" then
      wait = wait + 1
      if wait >= (o.tail or 400) then
        S:log("end: maxHp=%d str=%d def=%d flag0300=%d dmf=%04X gems=%d", r16(0x0ACA), r16(0x0ADE), r16(0x0ADC), g2.flag0300(r16(0x0644)), r16(0x09EC), r16(0x0AD6))
        S.over = true
      end
    end
  end)
end

-- k4: pickup item poke. A drop pickup (gem type 1 enemy: body DropBodyGem1) gets chatPtr := case.item right after the body stored $83, then it is touched by the player
-- (combat_collision.InteractionDamage_NPCChat -> GiveItemToPlayer). cases = { { name=, item=, pokes={ {addr, val}, ... } } }
function g2r.k4(S, o)
  local R
  S.res = {}
  local function stat() return { str = r16(0x0ADE), def = r16(0x0ADC), max = r16(0x0ACA), hp = r16(0x0ACE), heal = r16(0x0B22), gems = r16(0x0AD6), dmf = r16(0x09EC) } end
  local function fmt(s) return string.format("STR=%02X DEF=%02X maxHP=%02X HP=%02X hpToHeal=%d gems=%d dmf=%04X", s.str & 0xFF, s.def & 0xFF, s.max & 0xFF, s.hp & 0xFF, s.heal, s.gems, s.dmf) end
  for _, off in ipairs({ 57151, 57192, 57296, 57322 }) do
    S:ex(off, function()
      if R and not R.poked then
        local x = emu.getState()["cpu.x"]
        R.pickup = x
        R.before = r16(0x1000A + x)
        w16(0x1000A + x, R.case.item)
        R.poked = true; R.poked_t = 0
        S:log("[%s] pickup slot %04X (body hook %d) chatPtr %04X -> %04X (disclosed poke); pickup pos (%d,%d) player (%d,%d)", R.case.name, x, off, R.before, R.case.item, r16(x + 0x14), r16(x + 0x16), r16(0x1014), r16(0x1016))
      end
    end)
  end
  S:ex(O.GIVE_ITEM, function()
    if R then
      local st = emu.getState()
      R.give = { a = st["cpu.a"] & 0xFF, x = st["cpu.x"], pre = stat() }
      S:log("[%s] GiveItemToPlayer entered A=%02X X=%04X (pickup slot %s): %s", R.case.name, R.give.a, R.give.x, tostring(R.pickup), fmt(R.give.pre))
    end
  end)
  S:ex(247014, function() if R and R.give and not R.post then R.post = stat(); S:log("[%s] after GiveItemToPlayer: %s", R.case.name, fmt(R.post)) end end)
  S:ex(O.GIVE_SPARK, function()
    if R then local st = emu.getState(); R.sparkCaller = st["cpu.x"]; S:log("[%s] sparkle spawn: X=%04X D=%04X hpToHeal=%d", R.case.name, st["cpu.x"], st["cpu.d"], r16(0x0B22)) end
  end)
  S:ex(258018, function()
    if R then
      local st = emu.getState(); local y = st["cpu.y"]
      R.spark = { y = y, x = r16(y + 0x14), yy = r16(y + 0x16) }
      S:log("[%s] sparkle child slot %04X pos (%d,%d) f10=%04X ent=%06X; caller (pickup) pos (%d,%d); player (%d,%d)", R.case.name, y, r16(y + 0x14), r16(y + 0x16), r16(y + 0x10), aact.ent(y), r16(st["cpu.x"] + 0x14), r16(st["cpu.x"] + 0x16), r16(0x1014), r16(0x1016))
    end
  end)
  g2.trials(S, {
    n = #o.cases, maxT = 220,
    prepare = function() g2.setHp(o.victim, 1) end,
    setup = function(i)
      R = { case = o.cases[i], i = i }
      gaia.release()
      w16(0x0B22, 0); w16(0x0AD6, 0)
      for _, p in ipairs(R.case.pokes or {}) do w16(p[1], p[2]) end
      S:log("trial %d [%s] pokes: %s", i, R.case.name, fmt(stat()))
    end,
    step = function(i, tt)
      w16(0x11028, 0x0100)
      if R.post and not R.postT then R.postT = tt; R.poked_t = tt end
      if g2.hp(o.victim) > 0 then g2.place(o.victim, 88, 135); g2.setHp(o.victim, 1) end
      if tt == 1 then gaia.hold({ "b" }) end
      if R.poked and not R.post then gaia.hold({ "up" }) end
      if R.post and not R.released then gaia.release(); R.released = true end
    end,
    over = function(i, tt) return R.post ~= nil and tt >= R.poked_t + 60 end,
    record = function(i, tt)
      R.final = stat()
      S:log("[%s] final (tt=%d): %s ; GiveItem %s", R.case.name, tt, fmt(R.final), R.give and "called" or "NOT called")
      S.res[#S.res + 1] = R.case.name
    end,
    finish = function() gaia.release(); S.over = true end,
  })
end

-- gameover: die (playerHp := 0, disclosed poke) with chosen gem counts and the two respawn records set to two real scene_warps entries
-- (found by scanning the ROM for the first bytes of warp_def_01 entry ;00 and ;03). cases = { {name=, gems=} }
function g2r.gameover(S, o)
  local P = emu.memType.snesPrgRom
  local function pat(start)
    for a = 98868, 108894 - 12 do
      local ok = true
      for k = 1, #start do if emu.read(a + k - 1, P) ~= start[k] then ok = false; break end end
      if ok then return a end
    end
  end
  local e0 = pat({ 0x11, 0x0D, 0x02, 0x02, 0x08, 0xB8, 0x01, 0x80, 0x00, 0x00, 0x00, 0x12 })
  local e3 = pat({ 0x22, 0x1E, 0x01, 0x03, 0x04, 0xC8, 0x01, 0xC0, 0x01, 0x00, 0x10, 0x22 })
  e3 = e3 or (e0 and (e0 + 36))
  assert(e0 and e3, "warp entries not found")
  local saveRec, reviveRec = (e0 + 4) - 0x10000, (e3 + 4) - 0x10000   -- bank 01 CPU offsets, $8000 mirror
  S:log("records: save entry at ROM %d -> ptr %04X (dest %02X); revive entry at ROM %d -> ptr %04X (dest %02X)", e0, saveRec, emu.read(e0 + 4, P), e3, reviveRec, emu.read(e3 + 4, P))
  S.res = {}
  local R
  local function st() return string.format("scene %02X next %02X form %d HP %d/%d gems %d wramFlags[0..1]=%04X,%04X dest(%d,%d) save=%04X:%02X revive=%04X:%02X wake=%d", r16(0x0644) & 0xFF, r16(0x0642) & 0xFF, r16(0x0AD4) & 0xFF, r16(0x0ACE), r16(0x0ACA), r16(0x0AD6), r16(0x0A80), r16(0x0A82), r16(0x064C), r16(0x064E), r16(0x0AF0), r16(0x0AF2) & 0xFF, r16(0x0AF4), r16(0x0AF6) & 0xFF, r16(0x0AF8)) end
  S:ex(54924, function() if R then S:log("[%s] t=%d GameOverChooseRespawn gem test: gems=%d", R.case.name, S.t, r16(0x0AD6)) end end)
  S:ex(54955, function() if R then R.path = "revive"; S:log("[%s] revive path: Y(pointer)=%04X DBR=%02X", R.case.name, emu.getState()["cpu.y"], emu.getState()["cpu.dbr"]) end end)
  S:ex(55014, function() if R then R.path = "real"; S:log("[%s] real path: Y(pointer)=%04X DBR=%02X form=%d HP=%d gems=%d", R.case.name, emu.getState()["cpu.y"], emu.getState()["cpu.dbr"], r16(0x0AD4) & 0xFF, r16(0x0ACE), r16(0x0AD6)) end end)
  g2.trials(S, {
    n = #o.cases, maxT = 520,
    prepare = function() end,
    setup = function(i)
      R = { case = o.cases[i], i = i, t0 = S.t, n0 = r16(0x0642) & 0xFF }
      w16(0x0AD6, R.case.gems)
      if R.case.form then w16(0x0AD4, R.case.form) end
      w16(0x0AF0, saveRec); w16(0x0AF2, 1); w16(0x0AF4, reviveRec); w16(0x0AF6, 1)
      w16(0x0A80, 0x1234); w16(0x0A82, 0x00FF)
      S:log("trial %d [%s] before: %s", i, R.case.name, st())
    end,
    step = function(i, tt)
      if tt == 2 then w16(0x0ACE, 0) end
      if tt % 60 == 0 then S:log("[%s] tt=%d %s playerFlags=%04X", R.case.name, tt, st(), r16(0x09AE)) end
      if (r16(0x0642) & 0xFF) ~= R.n0 and not R.next then
        R.next = tt
        S:log("[%s] tt=%d sceneNext changed: %s", R.case.name, tt, st())
      end
    end,
    over = function(i, tt) return R.next ~= nil and tt >= R.next + 3 end,
    record = function(i, tt)
      S:log("[%s] done tt=%d path=%s %s", R.case.name, tt, tostring(R.path), st())
      S.res[#S.res + 1] = R.case.name
    end,
    finish = function() S.over = true end,
  })
end

-- boss: warp to a boss arena, wait for boss_clear_reward_handler, poke playerFlags bit $0020 (disclosed: a genuine boss kill is not driven), and log
--  * the handler slot H, its $04 (prevActorLink) before / at the STA $0004 / after, the actor list ($56 head, +6 next, +4 prev) before and after,
--  * every read and write of H+4/H+5 (pc, kind, value),
--  * the stat deltas against the delta predicted from enemy_clear_reward_table over [first, last) for scenes whose $0300 flag is clear.
-- o = { scene=0x29, after=function() end (optional second warp target scene) }
function g2r.boss(S, o)
  local O = g2.OFF
  local W = g2.warper()
  local H, phase, nph = nil, 0, 0
  local acc = {}
  if o.extra then o.extra(S) end
  local function listdump()
    local out, prevOk, bad = {}, true, 0
    local s, p, k = r16(0x56), 0, 0
    while s ~= 0 and k < 120 do
      local pv = r16(s + 4)
      if k > 0 and pv ~= p then bad = bad + 1 end
      out[#out + 1] = string.format("%04X(p%04X)", s, pv)
      p, s, k = s, r16(s + 6), k + 1
    end
    return table.concat(out, " "), bad, k
  end
  S:ex(O.BOSS_INIT, function() local x = emu.getState()["cpu.x"]; H = x; S:log("BossRewardCheckInit: X (slot)=%04X sceneCurrent=%02X boss flag word wramFlags[0x0100]=%02X", x, r16(0x0644) & 0xFF, r8(0x0A80 + 0x100 - 0x80 + 0)) end)
  local before
  S:ex(O.BOSS_GRANT, function()
    local st = emu.getState()
    local scene, tier = r16(0x0644) & 0xFF, nil
    local first, last = 0, 0
    for a = 49938, 49938 + 40, 4 do if emu.read(a, P) == scene then first, last = emu.read(a + 1, P), emu.read(a + 2, P); break end end
    local exp = { 0, 0, 0 }; local list = {}
    for sc = first, last - 1 do
      local tr = emu.read(109278 + sc, P)
      if tr ~= 0 and g2.flag0300(sc) == 0 then if tr >= 1 and tr <= 3 then exp[tr] = exp[tr] + 1 end; list[#list + 1] = string.format("%02X:%d", sc, tr) end
    end
    before = { max = r16(0x0ACA) & 0xFF, str = r16(0x0ADE) & 0xFF, def = r16(0x0ADC) & 0xFF, hp = r16(0x0ACE) & 0xFF, exp = exp }
    S:log("BossRewardGrant: scene %02X range [%02X,%02X) X=%04X D=%04X H.$04=%04X; unclaimed tiers (scene:tier): %s ; predicted +maxHP %d +STR %d +DEF %d", scene, first, last, st["cpu.x"], st["cpu.d"], r16(H + 4), table.concat(list, " "), exp[1], exp[2], exp[3])
  end)
  S:ex(O.BOSS_STA04, function() S:log("STA $0004 about to run: A=%04X H.$04 before=%04X (D=%04X)", emu.getState()["cpu.a"], r16(H + 4), emu.getState()["cpu.d"]) end)
  S:ex(50070, function() S:log("BossClearApplyStatReward RTS: maxHP %d STR %d DEF %d", r16(0x0ACA) & 0xFF, r16(0x0ADE) & 0xFF, r16(0x0ADC) & 0xFF) end)
  S:ex(49932, function() if not S.granted then S.granted = S.t; S:log("BossRewardIdle reached: hpToHeal=%d H.$04=%04X", r16(0x0B22), r16(H + 4)) end end)
  local wrote
  S:frame(function()
    W.step()
    if phase == 0 then W.go(o.scene); phase = 1; return end
    if phase == 1 and W.state == "done" then
      if not H then S:log("no boss_clear_reward_handler seen in scene %02X (state %s)", o.scene, W.state); phase = 9; S.over = true; return end
      local d, bad, n = listdump()
      S:log("list before (n=%d, prev-link mismatches %d): %s", n, bad, d)
      S:log("H=%04X ent=%06X $04=%04X before the poke; playerFlags=%04X; the sparkle-free list head $56=%04X", H, aact.ent(H), r16(H + 4), r16(0x09AE), r16(0x56))
      emu.addMemoryCallback(function(a, v) local pc = emu.getState()["cpu.pc"]; local key = "R" .. string.format("%04X:%04X", a & 0xFFFF, pc); acc[key] = (acc[key] or 0) + 1; if acc[key] == 1 then S:log("READ  H+%d pc=%06X value=%02X", (a & 0xFFFF) - H, emu.getState()["cpu.k"] * 65536 + pc, v or -1) end end, emu.callbackType.read, H + 4, H + 5, CPU, WR)
      emu.addMemoryCallback(function(a, v) local pc = emu.getState()["cpu.pc"]; local key = "W" .. string.format("%04X:%04X", a & 0xFFFF, pc); acc[key] = (acc[key] or 0) + 1; if acc[key] == 1 then S:log("WRITE H+%d pc=%06X value=%02X", (a & 0xFFFF) - H, emu.getState()["cpu.k"] * 65536 + pc, v or -1) end end, emu.callbackType.write, H + 4, H + 5, CPU, WR)
      phase, nph = 2, S.t
    elseif phase == 2 and S.t - nph >= 20 then
      w16(0x09AE, r16(0x09AE) | 0x0020); S:log("poke playerFlags |= $0020 -> %04X (disclosed)", r16(0x09AE)); phase, nph = 3, S.t
    elseif phase == 3 and S.granted and S.t - nph >= 90 then
      local d, bad, n = listdump()
      S:log("after: maxHP %d STR %d DEF %d (delta %+d %+d %+d); H.$04=%04X ; list n=%d prev-link mismatches %d: %s", r16(0x0ACA) & 0xFF, r16(0x0ADE) & 0xFF, r16(0x0ADC) & 0xFF, (r16(0x0ACA) & 0xFF) - before.max, (r16(0x0ADE) & 0xFF) - before.str, (r16(0x0ADC) & 0xFF) - before.def, r16(H + 4), n, bad, d)
      S:log("boss flag: wramFlags[0x0100..]=%02X ; scene flags $0300+: see byte dump %s", r8(0x0A00 + 0x20), "n/a")
      if o.leave then W.go(o.leave); phase = 4 else phase = 9; S.over = true end
    elseif phase == 4 and W.state == "done" then
      S:log("left the arena for scene %02X: no crash; scene now %02X", o.leave, r16(0x0644) & 0xFF); phase = 9; S.over = true
    end
  end)
end

-- killScene: warp to `scene` (from any state with sceneNext = 0), then kill every enemy (killAll). Sets S.over at the end of the tail.
function g2r.killScene(S, scene, o)
  local W = g2.warper()
  local ph = 0
  S:frame(function(t)
    if ph == 0 then W.go(scene); ph = 1 end
    W.step()
    if ph == 1 and W.state == "done" then
      ph = 2
      S:log("warped to %02X: $0AEC=%d $0AEE=%02X flag0300=%d maxHp=%d str=%d def=%d", r16(0x0644) & 0xFF, r16(0x0AEC), r16(0x0AEE), g2.flag0300(scene), r16(0x0ACA), r16(0x0ADE), r16(0x0ADC))
      g2r.killAll(S, o)
    end
    if ph == 1 and W.state == "fail" then S:log("warp to %02X failed", scene); S.over = true end
  end)
end
