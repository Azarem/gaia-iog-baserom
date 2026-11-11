-- description: G1/F3 combat hit rectangle check: for every source actor of the phase-2 collision pass (actors with $10 bit $0400) compare the rectangle the engine builds in DP $00-$06 with the rectangle computed from the header bytes 8-11 of the actor's sprite group; compare the victims the engine hits (JSR ApplyHitDamageToVictim) with the victims predicted from that rectangle; log the Aura orbital sources, victim HP before and after, and the readers of the Aura group header bytes.
-- requires: mesen_kit, iog_kit, gaia_kit
--
--   g1f3.run{ scene=0x0C, form=1, pokes={{addr=,v=,w=16}}, sched=function(t) return {"b"} end, post=500, out="F3_x.txt",
--             force=function(t, S) end,  -- optional: runs every frame of the run clock (disclosed pokes)
--             recon=true }              -- list the actors at t=0 and finish
--
-- Offsets are decimal PRG offsets (ROM file offsets). Callbacks run BEFORE the instruction; the PC a memory callback reports is the address after the
-- accessing instruction. Engine entries used (extract:lt tags of extracted/system/engine/combat_collision.asm):
--   244708 RunCombatCollision (PHP, entry)           244819 LDA metaspritePtr,X of the phase-2 source (X = source slot, $08 = slot)
--   244921 LDX #$0000 after the rectangle is stored  245075 JSR ApplyHitDamageToVictim (Y = victim, $08 = source slot)
--   245078 PLX after the call                        245082 CombatCollision_Exit (PLB)
--   245085 PlayerAttackHitTest (X = actor under test)
g1f3 = g1f3 or {}

local WR  = emu.memType.snesWorkRam
local P   = emu.memType.snesPrgRom
local CPU = emu.cpuType.snes

local function s8(v) v = v & 0xFF; if v >= 0x80 then return v - 256 end return v end
local function romOff(bank, ptr) return ((bank & 0x3F) << 16) | (ptr & 0xFFFF) end
local function rom8(o) return emu.read(o, P) end

-- the 12 sprite groups of spriteset_aura (ROM offsets, bank $17), from extracted/tables/spriteset_aura.asm
local AURA_GROUPS = { 0x17903C, 0x179057, 0x179072, 0x17908D, 0x1790A8, 0x1790CA, 0x1790EC, 0x17910E, 0x179130, 0x17914B, 0x179166, 0x17918F }
local AURA_LO, AURA_HI = 0x179000, 0x1791BA

local function auraGroupOf(rom)
  for i, g in ipairs(AURA_GROUPS) do if rom == g then return i - 1 end end
  return nil
end

-- source rectangle exactly as CombatCollision builds it (lines {244826}-{244919}); returns L, R, T, B (16-bit)
local function expectedBox(slot)
  local bank = kit.r8(0x10000 + slot + 8)
  local mp = kit.r16(0x10000 + slot + 0x0C)
  local o = romOff(bank, mp)           -- metaspritePtr = group + 4, so +4..+7 of it are the group bytes 8..11
  local b4, b5, b6, b7 = rom8(o + 4), rom8(o + 5), rom8(o + 6), rom8(o + 7)
  local x, y = kit.r16(slot + 0x14), kit.r16(slot + 0x16)
  local mirror = (kit.r16(slot + 0x0E) & 0x4000) ~= 0   -- ASL ASL of $0E,X: carry = bit 14
  local L, R
  if not mirror then
    L = (x + s8(b4)) & 0xFFFF; R = (L + b5) & 0xFFFF
  else
    R = (x - s8(b4)) & 0xFFFF; L = (R - b5) & 0xFFFF
  end
  local T = (y + s8(b6)) & 0xFFFF
  local B = (T + b7) & 0xFFFF
  return L, R, T, B, { b4, b5, b6, b7 }, mirror, o - 4
end

-- victim test exactly as the inner loop ({244975}-{245069}); box = L, R, T, B
local function overlaps(v, L, R, T, B)
  local e20, e21, e22, e23 = kit.r8(v + 0x20), kit.r8(v + 0x21), kit.r8(v + 0x22), kit.r8(v + 0x23)
  local xv, yv = kit.r16(v + 0x14), kit.r16(v + 0x16)
  if ((xv - s8(e20)) & 0xFFFF) >= R then return false end
  if ((s8(e21) + xv) & 0xFFFF) < L then return false end
  if ((yv - s8(e22)) & 0xFFFF) >= B then return false end
  if ((s8(e23) + yv) & 0xFFFF) < T then return false end
  return true
end

local function renderList()
  local out, i = {}, 0x0C00
  while #out < 100 do
    local s = kit.r16(i)
    if s == 0 then break end
    out[#out + 1] = s; i = i + 2
  end
  return out
end

function g1f3.run(o)
  local S = {
    ev = {}, ctl = 0, passes = 0, srcPass = 0, hits = 0, orbSrcPasses = 0, orbHits = 0, rectMatch = 0, rectMismatch = 0,
    predOnly = 0, actOnly = 0, both = 0, pahtCalls = 0, pahtOrb = 0, srcSlots = {}, victims = {}, hdrReads = {}, nReads = 0,
    t = nil, mism = {},
  }
  local function ev(s) if #S.ev < 400 then S.ev[#S.ev + 1] = s end end
  local function tstr() return S.t and ("t=" .. S.t) or "t=-" end
  local function dpw(a) return emu.read16(emu.getState()["cpu.d"] + a, WR, false) end

  -- positive controls: INC $36 in the NMI, RunCombatCollision entries
  emu.addMemoryCallback(function(a) if (a & 0xFFFF) == 0x36 then S.ctl = S.ctl + 1 end end, emu.callbackType.write, 0x36, 0x36, CPU, WR)
  -- scan / place hooks run at the entry of RunCombatCollision, before the pass reads any position (disclosed pokes on one victim actor)
  local scanN = 0
  local function orbitalSlot()
    for _, s in ipairs(renderList()) do
      if (kit.r16(s + 0x10) & 0x0400) ~= 0 then
        local _, _, _, _, _, _, group = expectedBox(s)
        if auraGroupOf(group) then return s end
      end
    end
    return nil
  end
  emu.addMemoryCallback(function()
    S.passes = S.passes + 1
    if not S.t then return end
    local sc, pl = o.scan, o.place
    if pl and S.t == pl.t and not S.placed then
      local s = orbitalSlot()
      if s then
        S.placed = true
        local v = pl.victim
        kit.w16(v + 0x14, (kit.r16(s + 0x14) + (pl.dx or 0)) & 0xFFFF); kit.w16(v + 0x16, (kit.r16(s + 0x16) + (pl.dy or 0)) & 0xFFFF)
        kit.w16(v + 0x08, 0x7FFF)
        ev(string.format("PLACE %s victim %04X at orbital %04X pos (%d,%d) hp=%d flags10=%04X iframes=%04X", tstr(), v, s, kit.r16(v + 0x14), kit.r16(v + 0x16), kit.r16(0x10026 + v), kit.r16(v + 0x10), kit.r16(0x10028 + v)))
      end
    end
    if sc and S.t >= sc.from and S.t < sc.to then
      local s = orbitalSlot()
      if not s then return end
      local L, R, T, B = expectedBox(s)
      local v = sc.victim
      local e20, e21, e22, e23 = s8(kit.r8(v + 0x20)), s8(kit.r8(v + 0x21)), s8(kit.r8(v + 0x22)), s8(kit.r8(v + 0x23))
      local pts = {}
      for d = -3, 3 do
        pts[#pts + 1] = { "R" .. d, R + e20 + d, T + 8 }     -- hit iff xv - e20 < R
        pts[#pts + 1] = { "L" .. d, L - e21 + d, T + 8 }     -- hit iff xv + e21 >= L
        pts[#pts + 1] = { "B" .. d, L + 4, B + e22 + d }     -- hit iff yv - e22 < B
        pts[#pts + 1] = { "T" .. d, L + 4, T - e23 + d }     -- hit iff yv + e23 >= T
      end
      local pt = pts[(scanN % #pts) + 1]
      scanN = scanN + 1
      kit.w16(v + 0x14, pt[2] & 0xFFFF); kit.w16(v + 0x16, pt[3] & 0xFFFF)
      kit.w16(v + 0x08, 0x7FFF); kit.w16(v + 0x10, 0); kit.w16(0x10026 + v, sc.hp or 3); kit.w16(0x10028 + v, 0)
      S.scanOrb, S.scanTag, S.scanVictim = s, pt[1], v
    else
      S.scanTag = nil
    end
  end, emu.callbackType.exec, 244708, 244708, CPU, P)

  -- readers of the Aura group header bytes: unique (K:PC, byte index inside the 13-byte header) with counts. ROM reads by the CPU are
  -- seen through the CPU address space (all four HiROM aliases of bank $17), not through snesPrgRom.
  S.grpRead = {}
  local function onHdrRead(a, v)
    local off = (((a >> 16) & 0x3F) << 16) | (a & 0xFFFF)
    for gi, g in ipairs(AURA_GROUPS) do
      if off >= g and off <= g + 12 then
        local st = emu.getState()
        local key = string.format("%02X:%04X idx%d", st["cpu.k"], st["cpu.pc"], off - g)
        S.hdrReads[key] = (S.hdrReads[key] or 0) + 1
        S.nReads = S.nReads + 1
        S.grpRead[gi - 1] = true
        return
      end
    end
  end
  for _, bank in ipairs({ 0x17, 0x57, 0x97, 0xD7 }) do
    emu.addMemoryCallback(onHdrRead, emu.callbackType.read, (bank << 16) | (AURA_LO & 0xFFFF), (bank << 16) | (AURA_HI & 0xFFFF), CPU, emu.memType.snesMemory)
  end
  S.points = {}

  -- phase-2 source: pending prediction is resolved at the next source or at the exit
  local cur = nil   -- {slot, L,R,T,B (expected), obs = {...}, pred = set, act = set, orb = bool, grp = n}
  local function resolve()
    if not cur then return end
    local c = cur; cur = nil
    local both, po, ao = 0, 0, 0
    if c.tag and c.slot == S.scanOrb then
      local p = S.points[c.tag] or { n = 0, pred = 0, act = 0, agree = 0 }
      S.points[c.tag] = p
      local pv, av = c.pred[c.tagVictim] and 1 or 0, c.act[c.tagVictim] and 1 or 0
      p.n = p.n + 1; p.pred = p.pred + pv; p.act = p.act + av; if pv == av then p.agree = p.agree + 1 end
    end
    for v in pairs(c.pred) do if c.act[v] then both = both + 1 else po = po + 1 end end
    for v in pairs(c.act) do if not c.pred[v] then ao = ao + 1 end end
    S.both = S.both + both; S.predOnly = S.predOnly + po; S.actOnly = S.actOnly + ao
    if (po > 0 or ao > 0) and #S.mism < 12 then
      local ps, as = {}, {}
      for v in pairs(c.pred) do ps[#ps + 1] = string.format("%04X", v) end
      for v in pairs(c.act) do as[#as + 1] = string.format("%04X", v) end
      S.mism[#S.mism + 1] = string.format("%s src %04X pred {%s} act {%s} box L%d R%d T%d B%d", tstr(), c.slot, table.concat(ps, ","), table.concat(as, ","), c.L, c.R, c.T, c.B)
    end
  end

  emu.addMemoryCallback(function()
    resolve()
    local st = emu.getState()
    local slot = st["cpu.x"]
    local L, R, T, B, bytes, mirror, group = expectedBox(slot)
    local gi = auraGroupOf(group)
    cur = { slot = slot, L = L, R = R, T = T, B = B, bytes = bytes, mirror = mirror, pred = {}, act = {}, orb = gi ~= nil, grp = gi,
            flags = kit.r16(slot + 0x10), x = kit.r16(slot + 0x14), y = kit.r16(slot + 0x16), tag = S.scanTag, tagVictim = S.scanVictim }
    S.srcPass = S.srcPass + 1
    local key = string.format("%04X", slot)
    local e = S.srcSlots[key]
    if not e then
      e = { n = 0, orbN = 0, flags = cur.flags, grp = group, hdr = bytes }
      S.srcSlots[key] = e
      ev(string.format("SRC new slot %04X %s flags10=%04X flags12=%04X group=%06X hdr8-11=%02X %02X %02X %02X mirror=%s pos=(%d,%d) aura=%s", slot, tstr(), cur.flags, kit.r16(slot + 0x12),
        group, bytes[1], bytes[2], bytes[3], bytes[4], tostring(mirror), cur.x, cur.y, tostring(gi)))
    end
    e.n = e.n + 1
    if cur.orb then S.orbSrcPasses = S.orbSrcPasses + 1; e.orbN = e.orbN + 1 end
  end, emu.callbackType.exec, 244819, 244819, CPU, P)

  -- the rectangle the engine stored (DP $04 left, $06 right, $00 top, $02 bottom) against the header formula; then the predicted victims
  emu.addMemoryCallback(function()
    if not cur then return end
    local oL, oR, oT, oB = dpw(0x04), dpw(0x06), dpw(0x00), dpw(0x02)
    cur.oL, cur.oR, cur.oT, cur.oB = oL, oR, oT, oB
    if oL == cur.L and oR == cur.R and oT == cur.T and oB == cur.B then
      S.rectMatch = S.rectMatch + 1
    else
      S.rectMismatch = S.rectMismatch + 1
      if #S.mism < 12 then S.mism[#S.mism + 1] = string.format("%s RECT slot %04X obs L%d R%d T%d B%d exp L%d R%d T%d B%d", tstr(), cur.slot, oL, oR, oT, oB, cur.L, cur.R, cur.T, cur.B) end
    end
    for _, v in ipairs(renderList()) do
      if (kit.r16(v + 0x10) & 0x76E0) == 0 and overlaps(v, cur.L, cur.R, cur.T, cur.B) then cur.pred[v] = true end
    end
  end, emu.callbackType.exec, 244921, 244921, CPU, P)

  -- the hit itself
  local pending = nil
  emu.addMemoryCallback(function()
    local st = emu.getState()
    local v = st["cpu.y"]
    S.hits = S.hits + 1
    if cur then cur.act[v] = true end
    local hp0 = kit.r16(0x10026 + v)
    pending = { v = v, hp0 = hp0 }
    local orb = cur and cur.orb
    if orb then S.orbHits = S.orbHits + 1 end
    local vk = string.format("%04X", v)
    local ve = S.victims[vk] or { n = 0, orbN = 0 }
    S.victims[vk] = ve
    ve.n = ve.n + 1
    if orb then ve.orbN = ve.orbN + 1 end
    if (not S.firstHit) or (orb and not S.firstOrbHit) then
      if orb then S.firstOrbHit = true else S.firstHit = true end
      local c = cur
      ev(string.format("HIT %s %s src=%04X (orb=%s grp=%s flags10=%04X pos=(%d,%d) hdr8-11=%02X %02X %02X %02X mirror=%s) victim=%04X flags10=%04X flags12=%04X pos=(%d,%d) box bytes 20-23=%02X %02X %02X %02X hp=%d statsPtr=%04X | DP box L%d R%d T%d B%d | expected L%d R%d T%d B%d",
        orb and "ORBITAL" or "other", tstr(), c and c.slot or 0, tostring(orb), tostring(c and c.grp), c and c.flags or 0, c and c.x or 0, c and c.y or 0,
        c and c.bytes[1] or 0, c and c.bytes[2] or 0, c and c.bytes[3] or 0, c and c.bytes[4] or 0, tostring(c and c.mirror),
        v, kit.r16(v + 0x10), kit.r16(v + 0x12), kit.r16(v + 0x14), kit.r16(v + 0x16), kit.r8(v + 0x20), kit.r8(v + 0x21), kit.r8(v + 0x22), kit.r8(v + 0x23), hp0,
        kit.r16(0x10020 + v), c and c.oL or 0, c and c.oR or 0, c and c.oT or 0, c and c.oB or 0, c and c.L or 0, c and c.R or 0, c and c.T or 0, c and c.B or 0))
    end
  end, emu.callbackType.exec, 245075, 245075, CPU, P)

  emu.addMemoryCallback(function()
    if pending then
      local hp1 = kit.r16(0x10026 + pending.v)
      local ve = S.victims[string.format("%04X", pending.v)]
      ve.hpDrop = (ve.hpDrop or 0) + math.max(0, pending.hp0 - hp1)
      if cur and cur.orb then ve.orbHpDrop = (ve.orbHpDrop or 0) + math.max(0, pending.hp0 - hp1) end
      if #S.ev < 400 and (cur and cur.orb) and (not S.orbHpLogged or S.orbHpLogged < 6) then
        S.orbHpLogged = (S.orbHpLogged or 0) + 1
        ev(string.format("ORB-HP %s victim %04X hp %d -> %d iframes=%04X", tstr(), pending.v, pending.hp0, hp1, kit.r16(0x10028 + pending.v)))
      end
      pending = nil
    end
  end, emu.callbackType.exec, 245078, 245078, CPU, P)

  emu.addMemoryCallback(function() resolve() end, emu.callbackType.exec, 245082, 245082, CPU, P)

  -- PlayerAttackHitTest: which actors does it test (X = actor), and does it ever run for an Aura orbital
  emu.addMemoryCallback(function()
    local x = emu.getState()["cpu.x"]
    S.pahtCalls = S.pahtCalls + 1
    local bank = kit.r8(0x10000 + x + 8)
    local g = romOff(bank, kit.r16(0x10000 + x + 0x0C) - 4)
    if auraGroupOf(g) then S.pahtOrb = S.pahtOrb + 1 end
    S.pahtSlots = S.pahtSlots or {}
    local k = string.format("%04X", x)
    S.pahtSlots[k] = (S.pahtSlots[k] or 0) + 1
  end, emu.callbackType.exec, 245085, 245085, CPU, P)

  -- run machine (warp, banner, clock), as e1_aura / f2_kit
  local n, stage, pulse = 0, "wait", 0
  kit.onFrame(function()
    if stage == "done" then return end
    n = n + 1
    local f = emu.getState()["frameCount"]
    local sc, sn = kit.r16(0x0644), kit.r16(0x0642)
    if stage == "wait" then
      if n >= 5 and sn == 0 then
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
        gaia.release(); stage = "run"; S.t = 0; S.n36 = kit.r16(0x36); S.arrived = f
      end
    elseif stage == "run" then
      S.t = (kit.r16(0x36) - S.n36) & 0xFFFF
      if o.recon and S.t >= (o.reconAt or 60) then
        local rows = {}
        for _, s in ipairs(renderList()) do
          rows[#rows + 1] = string.format("%04X ent=%04X f10=%04X f12=%04X pos=(%d,%d) box=%02X %02X %02X %02X hp=%d stats=%04X", s, kit.r16(s), kit.r16(s + 0x10), kit.r16(s + 0x12),
            kit.r16(s + 0x14), kit.r16(s + 0x16), kit.r8(s + 0x20), kit.r8(s + 0x21), kit.r8(s + 0x22), kit.r8(s + 0x23), kit.r16(0x10026 + s), kit.r16(0x10020 + s))
        end
        stage = "done"
        kit.finish({ recon = rows, form = kit.r16(0x0AD4), hp = kit.r16(0x0ACE), maxHp = kit.r16(0x0ACA), abil = kit.r16(0x0AA2), mask = kit.r16(0x065A), pflags = kit.r16(0x09AE),
                     scroll = { kit.r16(0x068A), kit.r16(0x068E) }, frame = f, t = S.t })
        return
      end
      local b = (S.t >= 1 and o.sched) and o.sched(S.t) or nil
      if b then gaia.hold(b) else gaia.release() end
      if o.force then o.force(S.t, S) end
      if o.tick then o.tick(S.t, S) end
      if o.post and S.t >= o.post then
        local lines = {}
        for _, l in ipairs(S.ev) do lines[#lines + 1] = l end
        local keys = {}
        for k, v in pairs(S.hdrReads) do keys[#keys + 1] = k end
        table.sort(keys)
        for _, k in ipairs(keys) do lines[#lines + 1] = string.format("HDRREAD %s x%d", k, S.hdrReads[k]) end
        for _, l in ipairs(S.mism) do lines[#lines + 1] = "MISMATCH " .. l end
        if o.out then emu.mcp.writeFile(o.out, table.concat(lines, "\n") .. "\n", false) end
        local readers = {}
        for _, k in ipairs(keys) do readers[#readers + 1] = k .. " x" .. S.hdrReads[k] end
        stage = "done"
        kit.finish({
          control36Writes = S.ctl, runCombatCollisionEntries = S.passes, sourcePasses = S.srcPass, orbitalSourcePasses = S.orbSrcPasses,
          rectMatch = S.rectMatch, rectMismatch = S.rectMismatch, predictedAndActual = S.both, predictedOnly = S.predOnly, actualOnly = S.actOnly,
          applyHitCalls = S.hits, orbitalApplyHitCalls = S.orbHits, playerAttackHitTestCalls = S.pahtCalls, playerAttackHitTestOnOrbital = S.pahtOrb,
          points = S.points, pahtSlots = S.pahtSlots, grpRead = (function() local t = {} for k in pairs(S.grpRead) do t[#t + 1] = k end table.sort(t) return t end)(), sources = S.srcSlots, victims = S.victims, auraHeaderReads = S.nReads, auraHeaderReaders = readers, mismatches = S.mism, nEvents = #S.ev, events = { table.unpack(S.ev, 1, math.min(8, #S.ev)) },
          form = kit.r16(0x0AD4), scene = kit.r16(0x0644), cpuK = emu.getState()["cpu.k"], cpuSp = emu.getState()["cpu.sp"], t = S.t, frame = f,
        })
      end
    end
  end)
end
