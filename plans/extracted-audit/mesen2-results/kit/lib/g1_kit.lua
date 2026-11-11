-- description: G1 hit and damage paths: exec logging of the combat collision gates, both damage routines, the player hitstun and stagger routines, the contact damage routine, the iframe counter reader of RunActors_Normal; trial driver (state already loaded, held-button schedule, disclosed pokes).
-- requires: mesen_kit, iog_kit, gaia_kit
--
--   g1.trial{ frames=N, tag="x", out="G1_x.txt",
--             sched=function(t) return {"a"} end,      -- buttons held at run clock t (NMI frames since the first callback)
--             tick=function(t, S) end,                  -- disclosed pokes, every frame after the scheduler (S.pl = player slot)
--             watch={slot,...} | function(S) -> slot    -- victim whose iframe counter / tick is sampled every frame (CL-02)
--           }
--
-- Offsets are decimal PRG offsets (ROM file offsets, = the ; {n} tags of extracted/). Callbacks run BEFORE the instruction. Keys used:
--   244708 RunCombatCollision   244729 CombatCollision_EnemyLoop (A = $10 of actor Y, the gate tests follow)   244819 phase-2 source (X = slot)
--   245075 JSR ApplyHitDamageToVictim ($08 = source slot, Y = victim)   245085 PlayerAttackHitTest (X = actor under test, entered through the gate)
--   245288 LDA chainDamage,X in PlayerAttackHitTest (X = actor under test, Y = victim)   245512 join after the hit in PlayerAttackHitTest (D = victim)
--   245960 join after the hit in ApplyHitDamageToVictim (D = victim)   246752 ApplyInteractionDamage (Y = actor touching the player)
--   50071 ApplyPlayerHitstun (A = damage, Y = direction)   55415 HitStaggerMain (X = child, $24 = victim)
--   248642 LDA iframeCounter,X in RunActors_Normal (X = actor)   248674 DEC $08 after the stun test (the actor script ticks)
g1 = g1 or {}

local WR  = emu.memType.snesWorkRam
local P   = emu.memType.snesPrgRom
local CPU = emu.cpuType.snes

local function s16(v) v = v & 0xFFFF; if v >= 0x8000 then return v - 0x10000 end return v end
local function s8(v) v = v & 0xFF; if v >= 0x80 then return v - 256 end return v end
local function f10(s) return kit.r16(s + 0x10) end
local function f12(s) return kit.r16(s + 0x12) end
local function hp(s) return kit.r16(0x10026 + s) end
local function ctr(s) return s16(kit.r16(0x10028 + s)) end
local function xf(s) return kit.r16(0x1002A + s) end
local function chain(s) return kit.r16(0x1101E + s) end      -- $7F101E,X (the $7F10xx block is addressed with the slot as index: 0x10000 + 0x101E + slot)
local function stats(s) return kit.r16(0x10020 + s) end

g1.helpers = { s16 = s16, s8 = s8, f10 = f10, f12 = f12, hp = hp, ctr = ctr, xf = xf, chain = chain, stats = stats }

function g1.renderList()
  local out, i = {}, 0x0C00
  while #out < 100 do
    local s = kit.r16(i)
    if s == 0 then break end
    out[#out + 1] = s; i = i + 2
  end
  return out
end

-- sprite group (13-byte header start) of an actor, as a ROM offset: entry bank at +8, metaspritePtr (= group + 4) at $7F000C,X
function g1.groupOf(s)
  local bank = kit.r8(0x10000 + s + 8)
  local mp = kit.r16(0x1000C + s)
  return ((bank & 0x3F) << 16) | ((mp - 4) & 0xFFFF)
end

function g1.dump(s)
  return string.format("%04X ent=%04X f10=%04X f12=%04X x12ext=%04X pos=(%d,%d) box20-23=%02X %02X %02X %02X hp=%d ctr=%d stats=%04X ch=%d grp=%06X", s,
    kit.r16(s), f10(s), f12(s), xf(s), kit.r16(s + 0x14), kit.r16(s + 0x16), kit.r8(s + 0x20), kit.r8(s + 0x21), kit.r8(s + 0x22), kit.r8(s + 0x23),
    hp(s), ctr(s), stats(s), chain(s), g1.groupOf(s))
end

function g1.trial(o)
  local S = {
    t = nil, pl = 0x1000, ev = {}, ctl = 0, passes = 0, nEv = 0,
    gate = {}, gateN = 0, srcN = {}, p1 = {}, p2 = {}, stun = {}, stag = {}, aid = {}, rd = {}, bonusRd = {}, bonusWr = {},
    cl = {}, clTick = {}, clCtr = {}, row = nil, wslot = nil, wlog = {}, cnt = {},
  }
  g1.S = S
  local function tstr() return S.t and ("t=" .. S.t) or "t=-" end
  local function ev(s) S.nEv = S.nEv + 1; if #S.ev < 700 then S.ev[#S.ev + 1] = s end end
  local function inc(key) S.cnt[key] = (S.cnt[key] or 0) + 1 end
  local state = function() return emu.getState() end

  -- positive controls
  emu.addMemoryCallback(function(a) if (a & 0xFFFF) == 0x36 then S.ctl = S.ctl + 1 end end, emu.callbackType.write, 0x36, 0x36, CPU, WR)
  emu.addMemoryCallback(function() S.passes = S.passes + 1; if not S.t then return end end, emu.callbackType.exec, 244708, 244708, CPU, P)

  -- gate: every actor tested in phase 1 (an actor WITHOUT $0400 reaches CombatCollision_EnemyLoop with A = its $10)
  emu.addMemoryCallback(function()
    local st = state()
    local y, a = st["cpu.y"], st["cpu.a"]
    local fl12 = f12(y)
    local c = ctr(y)
    local b80, b40, i10 = (a & 0x0080) ~= 0, (a & 0x0040) ~= 0, (fl12 & 0x0010) ~= 0
    local res
    if not b80 then res = "no0080"
    elseif b40 then res = "dead0040"
    elseif i10 then res = "immune12_0010"
    elseif c < 0 then res = "iframeNeg"
    else res = "PASS" end
    local key = string.format("%s", res)
    S.gate[key] = (S.gate[key] or 0) + 1
    S.gateN = S.gateN + 1
    if res ~= "no0080" and S.t then
      local k2 = string.format("%04X|%s|f10=%04X", y, res, a)
      if not S.gate[k2] then S.gate[k2] = 0; ev(string.format("GATE %s slot %04X %s f10=%04X f12=%04X ctr=%d hp=%d", tstr(), y, res, a, fl12, c, hp(y))) end
      S.gate[k2] = S.gate[k2] + 1
    end
  end, emu.callbackType.exec, 244729, 244729, CPU, P)

  -- phase-2 source
  emu.addMemoryCallback(function()
    local x = state()["cpu.x"]
    local key = string.format("%04X f10=%04X grp=%06X", x, f10(x), g1.groupOf(x))
    if not S.srcN[key] then
      S.srcN[key] = 0
      ev(string.format("SRC new %s %s f12=%04X pos=(%d,%d) ctr=%d", tstr(), key, f12(x), kit.r16(x + 0x14), kit.r16(x + 0x16), ctr(x)))
    end
    S.srcN[key] = S.srcN[key] + 1
  end, emu.callbackType.exec, 244819, 244819, CPU, P)

  -- ApplyHitDamageToVictim call (path 2)
  local pend2 = nil
  emu.addMemoryCallback(function()
    local st = state()
    local y = st["cpu.y"]
    local src = kit.r16(0x08)
    local isInter = kit.r16(0x24) ~= 0
    pend2 = { v = y, src = src, hp0 = hp(y), c0 = ctr(y), inter = isInter, t = S.t, str = kit.r16(0x0ADE), bonus = kit.r16(0x09E2), abil = kit.r16(0x09E0),
              form = kit.r16(0x0AD4), def = nil, pf = kit.r16(0x09AE) }
    local k = string.format("P2 src=%04X inter=%s", src, tostring(isInter))
    S.p2[k] = (S.p2[k] or 0) + 1
    ev(string.format("P2-CALL %s src=%04X (f10=%04X f12=%04X grp=%06X) victim=%04X (f10=%04X f12=%04X ctr=%d hp=%d stats=%04X) $24=%04X str=%d b09E2=%d a09E0=%d form=%d pf=%04X",
      tstr(), src, f10(src), f12(src), g1.groupOf(src), y, f10(y), f12(y), ctr(y), hp(y), stats(y), kit.r16(0x24), kit.r16(0x0ADE), kit.r16(0x09E2), kit.r16(0x09E0), kit.r16(0x0AD4), kit.r16(0x09AE)))
    if S.onHit then S.onHit("P2", y, src) end
  end, emu.callbackType.exec, 245075, 245075, CPU, P)
  emu.addMemoryCallback(function()
    -- join after the damage: D = victim
    if not pend2 then return end
    local d = state()["cpu.d"]
    local p = pend2; pend2 = nil
    if d ~= p.v then return end
    local row = S.statsRow and S.statsRow[stats(p.v)]
    local expd = "?"
    if row then
      local bonus = (p.src == 0x1000) and 0 or p.bonus
      local raw = p.str + bonus + p.abil - row[3]
      if raw < 1 then raw = 1 end
      expd = tostring(raw + p.form)
    end
    ev(string.format("P2-DONE %s victim=%04X hp %d -> %d netDamage(chain)=%d expected(max(1,str+%s+abil-DEF)+form)=%s DEF=%s ctr=%d f10=%04X f12=%04X", tstr(), p.v, p.hp0, hp(p.v), chain(p.v),
      (p.src == 0x1000) and "0(src $1000)" or ("b09E2=" .. p.bonus), expd, row and row[3] or "?", ctr(p.v), f10(p.v), f12(p.v)))
    S.last2 = { v = p.v, dmg = chain(p.v), hp0 = p.hp0, hp1 = hp(p.v), src = p.src, str = p.str, bonus = p.bonus, abil = p.abil, form = p.form, ctr = ctr(p.v), t = p.t }
    if S.onDone then S.onDone("P2", p.v, S.last2) end
  end, emu.callbackType.exec, 245960, 245960, CPU, P)
  -- HUD registers after ApplyHitDamageToVictim (loc_03C0E2) and after PlayerAttackHitTest (its End label, only when a hit was pending)
  emu.addMemoryCallback(function()
    ev(string.format("P2-HUD %s hudMax=%d hudPend=%d hudCur=%d (RunCombatCollision clears hudPend at entry)", tstr(), kit.r8(0x09E4), kit.r8(0x09EA), kit.r8(0x09E6)))
  end, emu.callbackType.exec, 245986, 245986, CPU, P)
  emu.addMemoryCallback(function()
    if S.p1hudPending then
      S.p1hudPending = false
      ev(string.format("P1-HUD %s hudMax=%d hudPend=%d hudCur=%d", tstr(), kit.r8(0x09E4), kit.r8(0x09EA), kit.r8(0x09E6)))
    end
  end, emu.callbackType.exec, 245538, 245538, CPU, P)

  -- PlayerAttackHitTest (path 1): X = actor under test (the "attacker"), then hits via 245288
  emu.addMemoryCallback(function()
    local x = state()["cpu.x"]
    local k = string.format("%04X", x)
    S.p1[k] = (S.p1[k] or 0) + 1
    if S.p1[k] == 1 then ev(string.format("P1-ENTER %s attacker=%s", tstr(), g1.dump(x))) end
  end, emu.callbackType.exec, 245085, 245085, CPU, P)
  local pend1 = nil
  emu.addMemoryCallback(function()
    local st = state()
    local x, y = st["cpu.x"], st["cpu.y"]
    pend1 = { a = x, v = y, hp0 = hp(y), ch = chain(x), vch0 = chain(y), c0 = ctr(y) }
    S.p1hudPending = true
    S.p1hits = (S.p1hits or 0) + 1
    ev(string.format("P1-HIT %s attacker=%04X (f10=%04X f12=%04X ctr=%d chainDamage=%d grp=%06X) victim=%04X (f10=%04X f12=%04X ctr=%d hp=%d stats=%04X) predicted dmg=%d", tstr(), x, f10(x), f12(x), ctr(x), chain(x), g1.groupOf(x),
      y, f10(y), f12(y), ctr(y), hp(y), stats(y), (chain(x) >> 1) + 1))
    if S.onHit then S.onHit("P1", y, x) end
  end, emu.callbackType.exec, 245288, 245288, CPU, P)
  emu.addMemoryCallback(function()
    if not pend1 then return end
    local d = state()["cpu.d"]
    local p = pend1; pend1 = nil
    if d ~= p.v then return end
    ev(string.format("P1-DONE %s victim=%04X hp %d -> %d victimChain=%d ctr=%d f10=%04X f12=%04X hudMax=%d hudCur=%d hudPend=%d", tstr(), p.v, p.hp0, hp(p.v), chain(p.v), ctr(p.v), f10(p.v), f12(p.v),
      kit.r8(0x09E4), kit.r8(0x09E6), kit.r8(0x09EA)))
    S.last1 = { v = p.v, a = p.a, hp0 = p.hp0, hp1 = hp(p.v), ch = p.ch, t = S.t }
    if S.onDone then S.onDone("P1", p.v, S.last1) end
  end, emu.callbackType.exec, 245512, 245512, CPU, P)

  -- ApplyPlayerHitstun (enemy script hits the player): A = damage (bit 15 heavy), Y = direction; return address on the stack
  emu.addMemoryCallback(function()
    local st = state()
    local sp = st["cpu.sp"]
    local ra = kit.r16(sp + 1, WR)
    local rb = kit.r8(sp + 3, WR)
    local k = string.format("ret=%02X:%04X", rb, ra + 1)
    S.stun[k] = (S.stun[k] or 0) + 1
    ev(string.format("HITSTUN %s A=%04X Y=%04X %s playerHp=%d pf=%04X ctr(player)=%d", tstr(), st["cpu.a"], st["cpu.y"], k, kit.r16(0x0ACE), kit.r16(0x09AE), ctr(0x1000)))
  end, emu.callbackType.exec, 50071, 50071, CPU, P)

  -- HitStaggerMain entry (the child actor): $24 = victim
  emu.addMemoryCallback(function()
    local x = state()["cpu.x"]
    local v = kit.r16(x + 0x24)
    local k = (v == 0x1000) and "victim=player" or "victim=actor"
    S.stag[k] = (S.stag[k] or 0) + 1
    ev(string.format("STAGGER %s child=%04X f10=%04X f12=%04X dir28=%d victim=%04X f10=%04X f12=%04X ctr=%d hp=%d tier101C=%d", tstr(), x, f10(x), f12(x), kit.r16(x + 0x28), v, f10(v), f12(v), ctr(v), hp(v), kit.r16(0x1101C + v)))
  end, emu.callbackType.exec, 55415, 55415, CPU, P)

  -- ApplyInteractionDamage (contact damage to the player)
  emu.addMemoryCallback(function()
    local y = state()["cpu.y"]
    local k = string.format("%04X", y)
    S.aid[k] = (S.aid[k] or 0) + 1
    if S.aid[k] <= 2 then ev(string.format("CONTACT %s actor=%s statsRow(hp,atk,def,gem)=%s playerHp=%d def=%d", tstr(), g1.dump(y), (S.statsRow and S.statsRow[stats(y)]) and table.concat(S.statsRow[stats(y)], ",") or "?", kit.r16(0x0ACE), kit.r16(0x0ADC))) end
  end, emu.callbackType.exec, 246752, 246752, CPU, P)

  -- RunActors_Normal: counter read and the tick after the stun test (CL-02)
  emu.addMemoryCallback(function()
    local x = state()["cpu.x"]
    local w = S.wslot
    if w and x == w then S.row = S.row or {}; S.row.ctr = ctr(x); S.row.f10 = f10(x); S.row.read = true end
  end, emu.callbackType.exec, 248642, 248642, CPU, P)
  emu.addMemoryCallback(function()
    local x = state()["cpu.x"]
    local w = S.wslot
    if w and x == w then S.row = S.row or {}; S.row.tick = true end
  end, emu.callbackType.exec, 248674, 248674, CPU, P)

  -- reads of the ability damage records (ROM $01:D9AD-$01:D9D8) and of the two bonus words $09E0/$09E2
  S.recReads = {}
  local function onRec(a, v)
    local st = state()
    local key = string.format("%02X:%04X off=%04X", st["cpu.k"], st["cpu.pc"], a & 0xFFFF)
    S.recReads[key] = (S.recReads[key] or 0) + 1
  end
  for _, bank in ipairs({ 0x01, 0x41, 0x81, 0xC1 }) do
    emu.addMemoryCallback(onRec, emu.callbackType.read, (bank << 16) | 0xD9AD, (bank << 16) | 0xD9D8, CPU, emu.memType.snesMemory)
  end
  local function onBonus(kind)
    return function(a, v)
      local a16 = a & 0xFFFF
      if a16 < 0x09E0 or a16 > 0x09E3 then return end
      local st = state()
      local key = string.format("%s %04X %02X:%04X", kind, a16, st["cpu.k"], st["cpu.pc"])
      local tbl = (kind == "R") and S.bonusRd or S.bonusWr
      tbl[key] = (tbl[key] or 0) + 1
      if kind == "W" then
        local lk = string.format("BONUSW %s %04X v=%02X", key, a16, v)
        if not S.bw then S.bw = {} end
        if #S.bw < 40 then S.bw[#S.bw + 1] = lk .. " " .. tstr() end
      end
    end
  end
  emu.addMemoryCallback(onBonus("R"), emu.callbackType.read, 0x09E0, 0x09E3, CPU, WR)
  emu.addMemoryCallback(onBonus("W"), emu.callbackType.write, 0x09E0, 0x09E3, CPU, WR)

  -- run machine
  local n = 0
  local started = false
  local function finish()
    local lines = {}
    for _, l in ipairs(S.ev) do lines[#lines + 1] = l end
    for k, v in pairs(S.recReads) do lines[#lines + 1] = string.format("RECREAD %s x%d", k, v) end
    for k, v in pairs(S.bonusRd) do lines[#lines + 1] = string.format("BONUSRD %s x%d", k, v) end
    for k, v in pairs(S.bonusWr) do lines[#lines + 1] = string.format("BONUSWR %s x%d", k, v) end
    for _, l in ipairs(S.wlog) do lines[#lines + 1] = l end
    if o.out then emu.mcp.writeFile(o.out, table.concat(lines, "\n") .. "\n", false) end
    local function copy(tb) local c = {} for k, v in pairs(tb) do if type(v) == "number" then c[k] = v end end return c end
    S.done = true
    kit.finish({
      tag = o.tag, control36 = S.ctl, passes = S.passes, gateN = S.gateN, gate = copy(S.gate), sources = copy(S.srcN), p1enter = copy(S.p1), p1hits = S.p1hits or 0, p2 = copy(S.p2), stun = copy(S.stun),
      stagger = copy(S.stag), contact = copy(S.aid), recReads = copy(S.recReads), bonusRd = copy(S.bonusRd), bonusWr = copy(S.bonusWr), nEvents = S.nEv, events = { table.unpack(S.ev, 1, math.min(o.show or 12, #S.ev)) },
      extra = S.extra, t = S.t, scene = kit.r16(0x0644), form = kit.r16(0x0AD4), hp = kit.r16(0x0ACE), frame = emu.getState()["frameCount"],
    })
  end
  g1.finish = finish
  kit.onFrame(function()
    if S.done then return end
    n = n + 1
    local clock = kit.r16(0x36)
    if not started then started = true; S.n36 = clock; S.t = 0 else S.t = (clock - S.n36) & 0xFFFF end
    -- CL-02 row flush (rows are produced by the exec callbacks of the previous frame)
    if S.wslot then
      local r = S.row or {}
      S.wlog[#S.wlog + 1] = string.format("CL %s slot=%04X ctr=%s tick=%s f10=%s hp=%d pos=(%d,%d) ent=%04X wait08=%d", tstr(), S.wslot, tostring(r.ctr), tostring(r.tick or false), r.f10 and string.format("%04X", r.f10) or "-",
        hp(S.wslot), kit.r16(S.wslot + 0x14), kit.r16(S.wslot + 0x16), kit.r16(S.wslot), kit.r16(S.wslot + 8))
      S.row = nil
    end
    if S.t == 0 then
      -- stats table rows (ROM $01:ABF0, 110 rows of 4 bytes); the key is the statsPtr word ($ABF0 + 4 * row)
      S.statsRow = {}
      for r = 0, 109 do
        local o2 = 109552 + r * 4
        S.statsRow[0xABF0 + r * 4] = { emu.read(o2, P), emu.read(o2 + 1, P), emu.read(o2 + 2, P), emu.read(o2 + 3, P) }
      end
      if o.setup then o.setup(S) end
    end
    local b = o.sched and o.sched(S.t) or nil
    if b then gaia.hold(b) else gaia.release() end
    if o.tick then o.tick(S.t, S) end
    if S.t >= o.frames then finish() end
  end)
end

-- warp builder: from S01r, poke (form, abilities, HP ...), write sceneNext, wait for the scene, dismiss the banner, run `settle` NMI frames, then finish with the actor list.
-- o = { scene=, pokes={{addr=,v=,w=16}}, settle=30, post=fn(S) }
function g1.warp(o)
  local n, stage, pulse, t0 = 0, "wait", 0, nil
  kit.onFrame(function()
    if stage == "done" then return end
    n = n + 1
    local sc, sn = kit.r16(0x0644), kit.r16(0x0642)
    if stage == "wait" then
      if n >= 5 and sn == 0 then
        for _, p in ipairs(o.pokes or {}) do if p.w == 16 then kit.w16(p.addr, p.v) else kit.w8(p.addr, p.v) end end
        kit.w16(0x0642, o.scene)
        stage = "warping"
      end
    elseif stage == "warping" then
      if sc == o.scene and sn == 0 then stage = "banner" end
      if n > 1500 then stage = "done"; kit.finish({ error = "warp_timeout", scene = sc }); return end
    end
    if stage == "banner" then
      if kit.r8(0x00B4) ~= 0 then
        pulse = pulse + 1
        gaia.hold((pulse % 6 < 3) and { "a" } or {})
      else
        gaia.release(); stage = "settle"; t0 = kit.r16(0x36)
      end
    elseif stage == "settle" then
      if ((kit.r16(0x36) - t0) & 0xFFFF) >= (o.settle or 30) then
        local rows = {}
        for _, s in ipairs(g1.renderList()) do rows[#rows + 1] = g1.dump(s) end
        stage = "done"
        kit.finish({ scene = kit.r16(0x0644), form = kit.r16(0x0AD4), hp = kit.r16(0x0ACE), maxHp = kit.r16(0x0ACA), abil = kit.r16(0x0AA2), str = kit.r16(0x0ADE), def = kit.r16(0x0ADC),
                     mask = kit.r16(0x065A), pflags = kit.r16(0x09AE), facing28 = kit.r16(0x1028), actors = rows, frame = emu.getState()["frameCount"] })
      end
    end
  end)
end
