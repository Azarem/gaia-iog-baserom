-- description: P2 Freedan abilities (S11): Dark Friar at levels 0/1/2 (cast branch on $16, spawn offsets, damage byte, fragments at detonation) and Aura Barrier (L/R launch, $16, orbitals).
-- requires: mesen_kit, iog_kit, gaia_kit, p2_kit
--
-- ROM O offsets (decimal ; {n} tags of extracted/actors/player/attack_ability_system.asm):
--   Aura: AuraBarrierMain LDA $16 178587, bounded SetEntryHereAndYield 178594, unbounded SetEntryHere 178612, CopyPalette (after the wait) 178624, AuraOrbitalSpawner 178711, LDA $0B1E 178722,
--         AuraProjectileChild SetMetasprite 178963, orbital shrink loop start 178820.
--   Dark Friar: DarkFriarMain LDA $16 179026, bounded 179033, unbounded 179051, CopyPalette after the wait 179063, DarkFriarProjectile 179213, DarkFriarTrailNorthInit 179239, DarkFriarTrailSouth 179244,
--         SetMetasprite after LoadAbilityDamageB (S) 179250, DarkFriarTrailWestInit 179316, DarkFriarTrailEastWest 179321, SetMetasprite after LoadAbilityDamageB (E/W) 179327,
--         bounce-loop level test 179414, bounce-loop Die 179436, DarkFriarOnHit 179442, DarkFriarFragmentInit STA orbitAngle 179481, loadAbilityDamageB return 179491, reversal 179624, fragment Die 179700.
--   Slot field addresses (WRAM): actor at slot s: $14/$16 = s+0x14/0x16; orbitAngle 0x10010+s, orbitDiameter 0x10012+s, moveScratch1/2 0x1002C/0x1002E+s, stored velocity $7F100C/E,X = 0x1100C / 0x1100E + s.
p2df = {}

local DIRS = { "down", "up", "left", "right" }

local function r16(a) return kit.r16(a) end
local function s16(v) return p2.s16(v) end

-- spec fields per variant: kind = "df"|"aura", lvl = ability level word value, dir, det = hold attack in flight (level 2 detonation), y20 = force the actor Y word to $0020 at the LDA $16
function p2df.go(specs, frames, out)
  local N = #specs
  local function at(S, name, pcname)
    local st = emu.getState()
    return st
  end

  local function cast16(S, st, name)
    local d, y = st["cpu.d"], r16(0x1016)
    p2.ev(S, "t=%d %s D=%04X $16=%04X (player slot Y word) actor=(%d,%d) playerFlags=%04X adhocDest=%04X lvl=%d", S.t, name, d, r16(d + 0x16), r16(0x1014), y, r16(0x09AE), r16(0x10C07), r16(S.lvlAddr))
    if S.spec.y20 then S.y0 = y; kit.w16(0x1016, 0x20); p2.ev(S, "t=%d poke actor Y %d -> $0020 at the LDA $16 (disclosed)", S.t, y) end
  end
  local function branch(S, st, name)
    p2.ev(S, "t=%d %s taken (D=%04X $16=%04X)", S.t, name, st["cpu.d"], r16(st["cpu.d"] + 0x16))
    if S.y0 then kit.w16(0x1016, S.y0); S.y0 = nil end
  end
  local function waited(S, st, name) p2.ev(S, "t=%d %s: DMA wait over, adhocDest=%04X", S.t, name, r16(0x10C07)) end

  local function spawnAt(S, st, name)
    local s = st["cpu.x"]
    local px, py = r16(0x1014), r16(0x1016)
    p2.ev(S, "t=%d %s slot=%04X pos=(%d,%d) offset from player=(%d,%d) $10=%04X $12=%04X", S.t, name, s, r16(s + 0x14), r16(s + 0x16), s16(r16(s + 0x14) - px), s16(r16(s + 0x16) - py), r16(s + 0x10), r16(s + 0x12))
  end
  local function dmg(S, st, name)
    p2.ev(S, "t=%d %s slot=%04X level words 0B16=%d 0B18=%d 0B1A=%d 0B1C=%d 0B1E=%d 0B20=%d bonus $09E0=%d $09E2=%d", S.t, name, st["cpu.x"], r16(0x0B16), r16(0x0B18), r16(0x0B1A), r16(0x0B1C), r16(0x0B1E), r16(0x0B20), r16(0x09E0), r16(0x09E2))
  end

  local marks = {
    aura16 = { 178587, cast16 }, auraB = { 178594, branch }, auraU = { 178612, branch }, auraWait = { 178624, waited },
    auraSpawner = { 178711, spawnAt }, auraLvl = { 178722, function(S, st, name) p2.ev(S, "t=%d AuraOrbitalSpawner reads $0B1E=%d ($0B16..$0B20 = %d %d %d %d %d %d)", S.t, r16(0x0B1E), r16(0x0B16), r16(0x0B18), r16(0x0B1A), r16(0x0B1C), r16(0x0B1E), r16(0x0B20)) end },
    auraChild = { 178963, function(S, st, name) S.children = (S.children or 0) + 1; p2.ev(S, "t=%d AuraProjectileChild #%d slot=%04X angle=%04X", S.t, S.children, st["cpu.x"], r16(0x10010 + st["cpu.x"])) end },
    auraShrink = { 178820, function(S, st, name) p2.ev(S, "t=%d aura shrink pass starts (children=%d)", S.t, S.children or 0) end },
    df16 = { 179026, cast16 }, dfB = { 179033, branch }, dfU = { 179051, branch }, dfWait = { 179063, waited },
    dfProj = { 179213, spawnAt }, dfTrN = { 179239, spawnAt }, dfTrS = { 179244, spawnAt }, dfTrW = { 179316, spawnAt }, dfTrEW = { 179321, spawnAt },
    dfDmgS = { 179250, dmg }, dfDmgEW = { 179327, dmg },
    dfBounce = { 179414, function(S, st, name)
      if not S.bounceT then S.bounceT = S.t; p2.ev(S, "t=%d trail enters the bounce loop: slot=%04X pos=(%d,%d) level $0B1C=%d $12=%04X", S.t, st["cpu.x"], r16(st["cpu.x"] + 0x14), r16(st["cpu.x"] + 0x16), r16(0x0B1C), r16(st["cpu.x"] + 0x12)) end
    end },
    dfTrailDie = { 179436, function(S, st, name) p2.ev(S, "t=%d trail Die (off-screen) slot=%04X pos=(%d,%d)", S.t, st["cpu.x"], r16(st["cpu.x"] + 0x14), r16(st["cpu.x"] + 0x16)) end },
    dfHit = { 179442, function(S, st, name) p2.ev(S, "t=%d DarkFriarOnHit slot=%04X pos=(%d,%d) $12=%04X moveScratch=(%d,%d) player=(%d,%d)", S.t, st["cpu.x"], r16(st["cpu.x"] + 0x14), r16(st["cpu.x"] + 0x16), r16(st["cpu.x"] + 0x12), s16(r16(0x1002C + st["cpu.x"])), s16(r16(0x1002E + st["cpu.x"])), r16(0x1014), r16(0x1016)) end },
    dfFrag = { 179481, function(S, st, name)
      local s = st["cpu.x"]
      S.fr = S.fr or {}
      S.fr[s] = { t0 = S.t, a0 = st["cpu.a"] & 0xFFFF, n = (S.nfr or 0) + 1 }
      S.nfr = (S.nfr or 0) + 1
      p2.ev(S, "t=%d fragment init #%d slot=%04X angle0=%04X center=(%d,%d) $12=%04X", S.t, S.nfr, s, st["cpu.a"] & 0xFFFF, r16(s + 0x14), r16(s + 0x16), r16(s + 0x12))
    end },
    dfFragDmg = { 179491, dmg },
    dfRev = { 179624, function(S, st, name)
      local s = st["cpu.x"]
      p2.ev(S, "t=%d fragment reversal slot=%04X pos=(%d,%d) stored vel=(%d,%d) angle=%04X dia=%04X ms=(%d,%d)", S.t, s, r16(s + 0x14), r16(s + 0x16), s16(r16(0x1100C + s)), s16(r16(0x1100E + s)), r16(0x10010 + s), r16(0x10012 + s), s16(r16(0x1002C + s)), s16(r16(0x1002E + s)))
    end },
    dfFragDie = { 179700, function(S, st, name) local s = st["cpu.x"]; p2.ev(S, "t=%d fragment Die slot=%04X pos=(%d,%d)", S.t, s, r16(s + 0x14), r16(s + 0x16)); if S.fr and S.fr[s] then S.fr[s].dead = S.t end end },
  }

  p2.run{ frames = frames, variants = N, tag = "df", out = out or "P2_df.txt", show = 0, marks = marks,
    writes = {
      { name = "body0AC8", lo = 0x0AC8, hi = 0x0AC9 },
      { name = "form0AD4", lo = 0x0AD4, hi = 0x0AD5 },
    },
    vsetup = function(S, v)
      local sp = specs[v]
      S.spec = sp; S.fr = nil; S.nfr = nil; S.children = nil; S.bounceT = nil; S.y0 = nil
      S.lvlAddr = (sp.kind == "aura") and 0x0B1E or 0x0B1C
      kit.w16(S.lvlAddr, sp.lvl)
      return string.format("%s lvl=%d dir=%s det=%s y20=%s", sp.kind, sp.lvl, sp.dir or "down", tostring(sp.det), tostring(sp.y20))
    end,
    sched = function(t, S, v)
      local sp = S.spec
      local di = 1; for i, d in ipairs(DIRS) do if d == (sp.dir or "down") then di = i end end
      if t >= 1 and t <= 3 then return { DIRS[di] } end
      if sp.kind == "aura" then
        if t >= 6 and t <= 175 then
          if t >= 160 and t <= 162 then return { "b", "l" } end
          return { "b" }
        end
        return nil
      end
      -- Dark Friar: hold the attack through the charge (40 + 100 ticks), release at 172
      if t >= 6 and t <= 171 then return { "b" } end
      local da = sp.detAt or 20
      if sp.det and S.bounceT and t >= S.bounceT + da and t <= S.bounceT + da + 40 then return { "b" } end
      return nil
    end,
    tick = function(t, S, v)
      if t == 10 then
        local x, y = 200, 144
        kit.w16(0x1014, x); kit.w16(0x1016, y); kit.w16(0x09A2, x - 8); kit.w16(0x09A4, y - 16)
        p2.ev(S, "t=10 poke actor=(%d,%d) form=%d anim=%04X ability mask=%04X", x, y, r16(0x0AD4), r16(0x1028), r16(0x0AA2))
      end
      if S.fr then
        for s, f in pairs(S.fr) do
          if not f.dead and t - f.t0 <= 100 then
            p2.row(S, "t=%d frag%d slot=%04X ang=%04X dia=%04X pos=(%d,%d) vel=(%d,%d) ms=(%d,%d) $10=%04X", t, f.n, s, r16(0x10010 + s), r16(0x10012 + s), r16(s + 0x14), r16(s + 0x16), s16(r16(0x1100C + s)), s16(r16(0x1100E + s)), s16(r16(0x1002C + s)), s16(r16(0x1002E + s)), r16(s + 0x10))
          end
        end
      end
    end,
    collect = function(S, v)
      local frs = {}
      for s, f in pairs(S.fr or {}) do frs[#frs + 1] = string.format("%04X:a0=%04X t0=%d dead=%s", s, f.a0, f.t0, tostring(f.dead)) end
      table.sort(frs)
      return { spec = string.format("%s lvl=%d dir=%s det=%s y20=%s", S.spec.kind, S.spec.lvl, S.spec.dir or "down", tostring(S.spec.det), tostring(S.spec.y20)), bounceT = S.bounceT, children = S.children, frags = table.concat(frs, " ; ") }
    end,
  }
end
