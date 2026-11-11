-- description: N2 Will lunge (Ranged*) and Dark Gaia projectile (Projectile*) trace: attack while holding the facing direction, per-frame player position / flags / abilityDamageBonus and projectile actors.
-- requires: mesen_kit, iog_kit, gaia_kit, m1_kit, n1_kit, n2_kit, a_census, a_actors, g1_kit, g2_kit
-- victim mode: o.victim = true, o.vdy = victim offset in Y from the player
--
-- ROM O offsets (decimal ; {n} tags): AttackSouth spawn of ProjectileSouth 183567, BranchIfPressed south lunge 183610, RangedAttackSouth 184079, RangedAttackNorth 184089, RangedAttackWest 184104,
-- RangedAttackEast 184119, lunge exit (TRB $0200) 184127, RangedSetForceX 184138, RangedSetForceY 184143; Projectile* actors 184168..(entries matched by range 184168-184330).
n2lg = n2lg or {}

local P   = emu.memType.snesPrgRom
local CPU = emu.cpuType.snes

-- o.dir = "down"|"up"|"left"|"right", o.hold = frames the direction is held after the attack press (default 70), o.rows = print per-frame rows for the first o.rows frames after the press (default 70)
function n2lg.run(o)
  local X = n2.execs({ southLunge = 183610, rSouth = 184079, rNorth = 184089, rWest = 184104, rEast = 184119, exit = 184127, forceX = 184138, forceY = 184143, spawnS = 183567 })
  m1.run(function(m)
    local L = m.log
    local pa = kit.r16(0x09AA)
    local dir = o.dir or "down"
    -- optional intro wait (scene $E8 locks the player for about 100 frames after the warp): pulse A, keep HP full
    for i = 1, (o.pre or 0) do
      gaia.hold((i % 8 < 2) and { "a" } or {}); kit.w16(0x0ACE, kit.r16(0x0ACA)); m.wait(1)
    end
    gaia.release()
    -- face the direction: hold it 10 frames, release 10
    gaia.hold({ dir }); m.wait(10); gaia.release(); m.wait(10)
    local x0, y0 = kit.r16(pa + 0x14), kit.r16(pa + 0x16)
    L("start: scene=%02X form=%d player=(%d,%d) $10=%04X $12=%04X ext=%04X $09E0=%04X pf=%04X abilities=%04X", kit.r16(0x0644) & 0xFF, kit.r16(0x0AD4), x0, y0, kit.r16(pa + 0x10), kit.r16(pa + 0x12), kit.r16(0x10000 + pa + 0x2A), kit.r16(0x09E0), kit.r16(0x09AE), kit.r16(0x0AA2))
    -- attack: press B (the attack button on ROM O: Mesen input "b") and keep holding the direction
    local rows, peakBonus, projSeen, hits = {}, 0, {}, {}
    local victim
    if o.victim then
      local e = g2.enemies()
      victim = e[1] and e[1].slot
      if victim then g2.setHp(victim, 200); L("victim slot=%04X row idx=%d atk=%d def=%d hp0=%d", victim, e[1].row.idx, e[1].row.atk, e[1].row.def, e[1].row.hp) else L("no victim found") end
    end
    local px, py = x0, y0
    local f = 0
    local lunged = false
    local hold = o.hold or 70
    local rowsN = o.rows or 70
    for i = 1, hold do
      local pressAt = o.pressAt or 1; gaia.hold(i <= 2 and (i >= pressAt and { "b", dir } or { "b" }) or (i >= pressAt and { dir } or {}))
      if victim then
        -- keep the victim at HP 200 and 25 px in front of the player (dy sign by direction); log every HP loss
        g2.place(victim, kit.r16(pa + 0x14), kit.r16(pa + 0x16) + (o.vdy or 25))
      end
      if o.pre then kit.w16(0x0ACE, kit.r16(0x0ACA)) end
      m.wait(1); f = f + 1
      if victim then
        local hp = g2.hp(victim)
        if hp ~= 200 then hits[#hits + 1] = string.format("f=%d victim HP 200 -> %d (loss %d) $09E0=%04X ent=%d", f, hp, 200 - hp, kit.r16(0x09E0), n1.rom(n1.ent(pa))); g2.setHp(victim, 200) end
      end
      local x, y = kit.r16(pa + 0x14), kit.r16(pa + 0x16)
      local b = kit.r16(0x09E0)
      if b > peakBonus then peakBonus = b end
      if f <= rowsN then
        rows[#rows + 1] = string.format("f=%d $36=%d x=%d y=%d dx=%d dy=%d $10=%04X $12=%04X ext=%04X $09E0=%04X pf=%04X f28=%04X w08=%04X", f, kit.r16(0x36), x, y, (x - px + 0x8000) % 0x10000 - 0x8000, (y - py + 0x8000) % 0x10000 - 0x8000,
          kit.r16(pa + 0x10), kit.r16(pa + 0x12), kit.r16(0x10000 + pa + 0x2A), b, kit.r16(0x09AE), kit.r16(pa + 0x28), kit.r16(pa + 8))
      end
      px, py = x, y
      for _, s in ipairs(n1.live()) do
        local r = n1.rom(n1.ent(s))
        if r >= 184168 and r <= 184275 then
          if not projSeen[s] then
            projSeen[s] = { f = f, x = kit.r16(s + 0x14), y = kit.r16(s + 0x16), f10 = kit.r16(s + 0x10), px = x, py = y, ent = r, n = 0 }
          end
          local v = projSeen[s]
          v.n = v.n + 1; v.lastF = f; v.lx, v.ly, v.lf10 = kit.r16(s + 0x14), kit.r16(s + 0x16), kit.r16(s + 0x10)
        end
      end
    end
    gaia.release()
    if not o.quiet then for _, r in ipairs(rows) do L("%s", r) end end
    for _, h in ipairs(hits) do L("%s", h) end
    L("exec counts: southLunge-branch=%d RangedAttackSouth=%d North=%d West=%d East=%d forceX=%d forceY=%d exit=%d spawnProjectile=%d", X.southLunge, X.rSouth, X.rNorth, X.rWest, X.rEast, X.forceX, X.forceY, X.exit, X.spawnS)
    L("peak $09E0=%04X over the hold; end: player=(%d,%d) $10=%04X ext=%04X $09E0=%04X pf=%04X", peakBonus, kit.r16(pa + 0x14), kit.r16(pa + 0x16), kit.r16(pa + 0x10), kit.r16(0x10000 + pa + 0x2A), kit.r16(0x09E0), kit.r16(0x09AE))
    local n = 0
    for s, v in pairs(projSeen) do
      n = n + 1
      L("projectile slot=%04X first seen f=%d ent=%d pos=(%d,%d) offset from player=(%d,%d) $10=%04X; last seen f=%d (%d frames) pos=(%d,%d) $10=%04X", s, v.f, v.ent, v.x, v.y, v.x - v.px, v.y - v.py, v.f10, v.lastF, v.n, v.lx, v.ly, v.lf10)
    end
    L("projectile actors seen: %d", n)
    return { lines = m.lines }
  end, o)
end
