-- description: G2 death, rewards and drops: script scaffold (NMI-frame clock, capped event log, exec/read/write hooks with the t clock), live-enemy finder, attack driver, savestate trial loop.
-- requires: mesen_kit, iog_kit, gaia_kit, a_census, a_actors, g1_kit
--
--   local S = g2.new{ cap = 150 }                 -- S.t = NMI frames since the first frame callback ($36 deltas), S.ctl = INC $36 writes (positive control)
--   S:log(fmt, ...)                               -- event row prefixed "t=<S.t>", capped (S.cap rows, then a counter)
--   S:ex(off, fn)  S:wr(lo, hi, fn)  S:rd(lo, hi, fn)    -- exec (ROM file offset, decimal) / write / read (WRAM offset) hooks
--   S:frame(fn)                                   -- fn(t) after the clock update, every frame
--   S:finish(extra)                               -- kit.finish with S.rows, S.ctl, S.dropped
--
-- All addresses are decimal ROM file offsets (= the "; {n}" tags of extracted/) or WRAM offsets ($7F:xxxx = 0x10000 + xxxx).
g2 = g2 or {}

local WR  = emu.memType.snesWorkRam
local P   = emu.memType.snesPrgRom
local CPU = emu.cpuType.snes
local r8, r16, w8, w16 = kit.r8, kit.r16, kit.w8, kit.w16

local function s16(v) v = v & 0xFFFF; if v >= 0x8000 then return v - 0x10000 end return v end
g2.s16 = s16

-- ROM offsets (original ROM; the `; {n}` tags of extracted/)
g2.OFF = {
  STD_DEFEAT = 56202,       -- StandardEnemyDefeatHandler (X = victim)
  STD_AFTER_COUNT = 56246,  -- EnemyDefeatFlashAndDrop entry (counters already written when entered by the fall-through)
  GEM_JMP = 56336,          -- JMP EnemyGemDropRouter (gem path taken)
  HIDE_RELEASE = 56339,     -- DefeatHideAndRelease
  DIE_OR_REWARD = 56404,    -- DefeatDieOrReward (orbitAngle test)
  STAT_BONUS = 56711,       -- EnemyStatBonusReward entry
  SPAWN_HP_PICKUP = 56758, SPAWN_STR_PICKUP = 56778, SPAWN_DEF_PICKUP = 56798,
  ROUTER = 56667,           -- EnemyGemDropRouter entry (A = stat byte +3)
  DROP_GEM1 = 57129, DROP_GEM2 = 57170, DROP_TIER = 57211,
  BODY_GEM1 = 57144, BODY_GEM2 = 57185, BODY_GEM5 = 57289, BODY_HEAL = 57315,
  ROLL_CMP = 57268,         -- first CMP of the threshold scan (A = random byte, $26 = group offset)
  DISPATCH = 697407,        -- EnemyDefeatDispatch entry
  DISPATCH_NOTLAST = 697440,
  GIVE_ITEM = 257943,       -- GiveItemToPlayer entry (A = item id)
  GIVE_SPARK = 258009,      -- COP SpawnListAppend of the heal sparkle (D = X = caller actor)
  NPC_CHAT_GIVE = 247010,   -- JSL GiveItemToPlayer in combat_collision (pickup touch)
  PHASE2_SRC = 244819,      -- phase-2 source (X = slot)
  GAMEOVER = 54831, GO_REVIVE_TEST = 54924, GO_REAL = 54957, GO_TAIL = 55014,
  BOSS_INIT = 49854, BOSS_GRANT = 49900, BOSS_APPLY = 49910, BOSS_STA04 = 49907,
}

-- scaffold -------------------------------------------------------------------------------------
function g2.new(o)
  o = o or {}
  local S = { t = 0, ctl = 0, rows = {}, cap = o.cap or 150, dropped = 0, fr = {}, started = false, n36 = nil, cnt = {} }
  function S:log(fmt, ...)
    local s = select("#", ...) > 0 and string.format(fmt, ...) or fmt
    if #self.rows < self.cap then self.rows[#self.rows + 1] = string.format("t=%d %s", self.t, s) else self.dropped = self.dropped + 1 end
  end
  function S:inc(key, n) self.cnt[key] = (self.cnt[key] or 0) + (n or 1) end
  function S:ex(off, fn) emu.addMemoryCallback(fn, emu.callbackType.exec, off, off, CPU, P) end
  function S:wr(lo, hi, fn) emu.addMemoryCallback(fn, emu.callbackType.write, lo, hi, CPU, WR) end
  function S:rd(lo, hi, fn) emu.addMemoryCallback(fn, emu.callbackType.read, lo, hi, CPU, WR) end
  function S:frame(fn) self.fr[#self.fr + 1] = fn end
  function S:finish(extra)
    local res = extra or {}
    res.rows, res.control36 = self.rows, self.ctl
    res.dropped, res.cnt, res.t, res.frame = self.dropped, self.cnt, self.t, emu.getState()["frameCount"]
    kit.finish(res)
  end
  emu.addMemoryCallback(function(a) if (a & 0xFFFF) == 0x36 then S.ctl = S.ctl + 1 end end, emu.callbackType.write, 0x36, 0x36, CPU, WR)
  kit.onFrame(function()
    local c = r16(0x36)
    if not S.started then S.started = true; S.n36 = c; S.t = 0 else S.t = (c - S.n36) & 0xFFFF end
    for _, fn in ipairs(S.fr) do
      local ok, err = pcall(fn, S.t)
      if not ok then S.errs = (S.errs or 0) + 1; if S.errs <= 3 then S:log("LUA ERROR %s", tostring(err)) end end
    end
  end)
  g2.S = S
  return S
end

-- actors ---------------------------------------------------------------------------------------
function g2.stats(s) return r16(0x10020 + s) end
function g2.hp(s) return r16(0x10026 + s) end
function g2.setHp(s, v) w16(0x10026 + s, v) end
function g2.row(s)
  local st = g2.stats(s)
  if st < 0xABF0 or st > 0xABF0 + 109 * 4 then return nil end
  local o = 109552 + (st - 0xABF0)
  return { idx = (st - 0xABF0) // 4, hp = emu.read(o, P), atk = emu.read(o + 1, P), def = emu.read(o + 2, P), gem = emu.read(o + 3, P) }
end
-- live slots of the actor list with a stats row (index >= 1)
function g2.enemies()
  local out = {}
  for _, s in ipairs(aact.live()) do
    if s ~= 0x1000 then
      local rw = g2.row(s)
      -- freed slots are not cleared and spawned children inherit stats words: require a nonzero enemyNum and not hidden
      if rw and rw.idx >= 1 and (r16(0x10022 + s) & 0xFF) ~= 0 and (r16(s + 0x10) & 0x2000) == 0 then out[#out + 1] = { slot = s, row = rw } end
    end
  end
  return out
end
function g2.pos(s) return r16(s + 0x14), r16(s + 0x16) end
function g2.place(s, x, y) w16(s + 0x14, x); w16(s + 0x16, y) end
function g2.dump(s) return g1.dump(s) end
function g2.flag0300(scene)
  local n = 0x300 + scene
  return (r8(0x0A00 + (n >> 3)) >> (n & 7)) & 1
end
function g2.setFlag0300(scene, on)
  local n = 0x300 + scene
  local a, b = 0x0A00 + (n >> 3), n & 7
  local v = r8(a)
  if on then v = v | (1 << b) else v = v & ~(1 << b) end
  w8(a, v & 0xFF)
end
function g2.wramFlags()
  local t = {}
  for i = 0, 31 do t[#t + 1] = string.format("%02X", r8(0x0A80 + i)) end
  return table.concat(t)
end

-- savestate trial loop ----------------------------------------------------------------------------
-- g2.trials{ n=, setup=function(i) -> k (frames to wait, hold begins), hold={"b"}, maxT=, over=function(i,t) -> true when the trial is over, record=function(i,t) }
-- The scene setup must have run already; the first frame callback saves the start state, each trial reloads it (S.t restarts at 0 per trial).
function g2.trials(S, o)
  local saved, i, t0, phase = nil, 0, nil, "init"
  local n36 = nil
  local tt = 0
  -- createSavestate / loadSavestate are only legal inside an exec callback of the main CPU: the trial machine runs at the NMI vector stub (JML NmiHandler, tag 32779), once per frame.
  local function machine()
    if S.done then return end
    if phase == "init" then
      if o.prepare then o.prepare() end
      saved = emu.createSavestate()
      phase = "start"
      return
    end
    if phase == "start" then
      if i >= o.n then S.done = true; if o.finish then o.finish() end; return end
      i = i + 1
      emu.loadSavestate(saved)
      o.setup(i)
      tt = 0
      phase = "run"
      return
    end
    -- phase == "run": executed in the frame after the load (clock re-based on the loaded $36)
    tt = tt + 1
    if o.step then o.step(i, tt) end
    if o.over(i, tt) or tt >= o.maxT then
      if o.record then o.record(i, tt) end
      phase = "start"
    end
  end
  S:ex(32779, function()
    local ok, err = pcall(machine)
    if not ok then S.errs = (S.errs or 0) + 1; if S.errs <= 3 then S:log("LUA ERROR %s", tostring(err)) end end
  end)
end

-- drop farm ---------------------------------------------------------------------------------------
-- One victim (HP 1) is placed in front of the player (facing north) and hit with B; the savestate is reloaded for every trial.
-- The generator state $0410-$041F is poked per trial from a seeded xorshift (o.seed) because the unpoked state is frozen in this room (the same byte for any delay); RngByte itself runs unmodified.
-- o = { victim=slot, hp=player HP to hold, n=trials, seed=, sweep=true (output byte = trial index mod 256, exact), px=88, py=135, maxExtra=60, k=frames before the B hold }
-- Per trial: S.trial[i] = { byte, grp, hpAtRoll, body, pred } ; pred = the body the ROM table gives for (grp, byte), decoded from the CMP operand.
local BODY = { [57144] = "83", [57185] = "84", [57289] = "85", [57315] = "86" }
local BODYW = { [0xDF38] = "83", [0xDF61] = "84", [0xDFC9] = "85", [0xDFE3] = "86" }
function g2.dropFarm(S, o)
  local O = g2.OFF
  local R
  local rs = (o.seed or 1) | 1
  local function rnd(n) rs = rs ~ ((rs << 13) & 0xFFFFFFFF); rs = rs ~ (rs >> 17); rs = rs ~ ((rs << 5) & 0xFFFFFFFF); return rs % n end
  S.trial = {}
  S.tally = {}
  local tab
  S:ex(O.ROLL_CMP, function()
    local st = emu.getState()
    if R and R.byte == nil then
      R.byte = st["cpu.a"] & 0xFF
      R.grp = st["cpu.x"]
      R.hpAtRoll = kit.r16(0x0ACE)
      R.maxAtRoll = kit.r16(0x0ACA)
      if not tab then
        local w = emu.read(57269, P) | (emu.read(57270, P) << 8)
        local b = emu.read(57271, P)
        tab = ((b & 0x3F) << 16) | w
        S.tabOff = tab
      end
      local x = R.grp
      for r = 0, 3 do
        local thr = emu.read(tab + x + r * 4, P) | (emu.read(tab + x + r * 4 + 1, P) << 8)
        if R.byte < thr then
          local bw = emu.read(tab + x + r * 4 + 2, P) | (emu.read(tab + x + r * 4 + 3, P) << 8)
          R.pred = BODYW[bw] or string.format("%04X", bw)
          break
        end
      end
    end
  end)
  for off, id in pairs(BODY) do
    S:ex(off, function() if R and R.body == nil then R.body = id end end)
  end
  local px, py = o.px or 88, o.py or 135
  local K = o.k or 0
  g2.trials(S, {
    n = o.n, maxT = K + (o.maxExtra or 60),
    prepare = function()
      kit.w16(0x0ACA, 8)
      g2.setHp(o.victim, 1)
    end,
    setup = function(i)
      R = { i = i }
      S.trial[i] = R
      gaia.release()
      if o.sweep then
        -- exact output control: with $0411-$041F = 0 the carry chain adds nothing, so the next RngByte output is the poked $0410
        for a = 0x0411, 0x041F do kit.w8(a, 0) end
        kit.w8(0x0410, (i - 1) % 256)
        R.want = (i - 1) % 256
      else
        for a = 0x0410, 0x041F do kit.w8(a, rnd(256)) end
      end
    end,
    step = function(i, tt)
      kit.w16(0x0ACE, type(o.hp) == "function" and o.hp(i) or o.hp)
      kit.w16(0x11028, 0x0100)
      if g2.hp(o.victim) > 0 then g2.place(o.victim, px, py); g2.setHp(o.victim, 1) end
      if tt == K + 1 then gaia.hold({ "b" }) end
    end,
    over = function(i, tt) return R.body ~= nil and tt >= K + 2 end,
    record = function(i, tt)
      R.tt = tt
      local key = string.format("%02X/%s", R.grp or 255, R.body or "none")
      S.tally[key] = (S.tally[key] or 0) + 1
      if R.body ~= R.pred then S:inc("pred_mismatch") end
      if R.want ~= nil and R.want ~= R.byte then S:inc("byte_not_wanted") end
      if R.body == nil then S:inc("no_body") end
      local bin = (R.byte or 0) // 16
      S.hist = S.hist or {}
      S.hist[bin] = (S.hist[bin] or 0) + 1
      if i <= 5 or R.body == nil or R.body ~= R.pred then
        S:log("trial %d byte=%s grp=%s hp=%s body=%s pred=%s tt=%d", i, tostring(R.byte), tostring(R.grp), tostring(R.hpAtRoll), tostring(R.body), tostring(R.pred), tt)
      end
    end,
    finish = function() gaia.release() end,
  })
end

-- save the rows of S to raw/<name> (relative to the results raw directory)
function g2.save(S, name)
  local lines = {}
  for _, r in ipairs(S.rows) do lines[#lines + 1] = r end
  if S.dropped > 0 then lines[#lines + 1] = string.format("... %d rows beyond the cap not kept", S.dropped) end
  emu.mcp.writeFile(name, table.concat(lines, "\n") .. "\n", false)
end

-- warp controller ($0642 write; the scene-title wait flag $00B4 is answered with A pulses whenever it is nonzero; 30 NMI frames of settle with $00B4 clear); call W.go(scene), then W.step() every frame; W.state == "done" when settled
function g2.warper()
  local W = { state = "idle", n = 0 }
  local pulse, pulsing = 0, false
  function W.go(scene) W.scene, W.state, W.n = scene, "wait", 0 end
  function W.step()
    if W.state == "idle" or W.state == "done" or W.state == "fail" then return end
    W.n = W.n + 1
    local sc, sn = r16(0x0644), r16(0x0642)
    local b4 = r8(0x00B4) ~= 0
    if b4 then
      pulse = pulse + 1; pulsing = true
      gaia.hold((pulse % 6 < 3) and { "a" } or {})
      if W.state == "settle" then W.state = "banner" end
    elseif pulsing then
      gaia.release(); pulsing = false
    end
    if W.state == "wait" then
      if sn == 0 and not b4 and W.n >= 2 then w16(0x0642, W.scene); W.state, W.n = "warping", 0 end
    elseif W.state == "warping" then
      if sc == W.scene and sn == 0 and not b4 then W.state, W.t0 = "settle", r16(0x36) end
      if W.n > 1500 then W.state = "fail" end
    elseif W.state == "banner" then
      if not b4 then W.state, W.t0 = "settle", r16(0x36) end
    elseif W.state == "settle" then
      if ((r16(0x36) - W.t0) & 0xFFFF) >= 30 then W.state = "done" end
    end
  end
  return W
end

-- attack driver: D.start(slot) places the victim 25 px in front of the player (facing north) with HP 1 every frame and holds B until the standard defeat handler has started for it
function g2.driver(S)
  local D = { state = "idle", n = 0 }
  function D.start(v) D.v, D.state, D.n, D.std = v, "hit", 0, false end
  S:ex(g2.OFF.STD_DEFEAT, function()
    local x = emu.getState()["cpu.x"]
    if D.v and x == D.v then D.std = true end
  end)
  function D.step()
    if D.state ~= "hit" then return end
    D.n = D.n + 1
    local v = D.v
    if not D.std then
      local px, py = r16(0x1014), r16(0x1016)
      if g2.hp(v) > 0 then g2.place(v, px, py - 25); g2.setHp(v, 1) end
      w16(0x11028, 0x0100)
      if D.n == 1 then gaia.hold({ "b" }) end
    else
      gaia.release(); D.state = "done"
    end
    if D.n > 200 and D.state == "hit" then gaia.release(); D.state = "timeout" end
  end
  return D
end
