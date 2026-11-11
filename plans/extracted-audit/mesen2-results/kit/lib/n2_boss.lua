-- description: N2 Castoth defeat: kill the boss (slot 1090, HP poked to 1 while it is held 25 px north of the player) and trace bit $0200 of the player actor flags, the SetPlayerIgnoreContactFlag helper actor, HP and scene afterwards.
-- requires: mesen_kit, iog_kit, gaia_kit, m1_kit, n1_kit, n2_kit, a_census, a_actors, g1_kit, g2_kit
--
-- ROM O offsets (decimal ; {n} tags): SpawnListAppend of SetPlayerIgnoreContactFlag in ir29_castoth 695407; helper body SetPlayerIgnoreContactFlag 697198..697210 (ORA #$0200 at 697204).
n2b = n2b or {}

function n2b.castoth(o)
  o = o or {}
  local H = n2.execs({ spawnHelper = 695407, helperFirst = 697198, helperBody = 697204 })
  m1.run(function(m)
    local L = m.log
    local pa = kit.r16(0x09AA)
    local boss = o.boss or 0x1090
    -- intro: pulse A until the arrival lock mask clears
    for i = 1, 400 do
      gaia.hold((i % 8 < 2) and { "a" } or {}); m.wait(1)
      if i > 20 and kit.r16(0x065A) == 0 then L("intro done after %d frames: boss HP=%d pos=(%d,%d) player=(%d,%d)", i, g2.hp(boss), kit.r16(boss + 0x14), kit.r16(boss + 0x16), kit.r16(pa + 0x14), kit.r16(pa + 0x16)); break end
    end
    if o.force then
      -- the body's death entry func_0A9C1E (ROM 695326 = 0A:9C1E, entry bank byte 8A like the 80 of ROM 50270): the same entry poke the boss script performs when its HP part dies
      kit.w16(boss + 0x00, 0x9C1E); kit.w8(boss + 0x02, 0x8A); kit.w16(boss + 0x08, 0)
      L("forced boss entry: $00=%04X $02=%02X", kit.r16(boss + 0x00), kit.r8(boss + 0x02))
    end
    -- kill phase: hold the boss at HP 1 in front of the player and attack (B pulses) until the defeat spawns the helper
    local n = o.force and 899 or 0
    if o.force then for i = 1, 60 do m.wait(1); if H.spawnHelper > 0 then break end end end
    while H.spawnHelper == 0 and n < 900 do
      n = n + 1
      local px, py = kit.r16(pa + 0x14), kit.r16(pa + 0x16)
      kit.w16(0x0ACE, kit.r16(0x0ACA))
      if g2.hp(boss) > 0 then g2.place(boss, px, py - 25); g2.setHp(boss, 1) end
      gaia.hold((n % 10 < 5) and { "b" } or {}); m.wait(1)
    end
    gaia.release()
    L("kill phase: %d frames, helper spawned=%d", n, H.spawnHelper)
    if o.dump then
      for k = 1, o.dump do
        local t = {}
        for _, s in ipairs(n1.live()) do t[#t + 1] = string.format("%04X:%d:%04X", s, n1.rom(n1.ent(s)), kit.r16(s + 0x10)) end
        L("dump+%d live actors (slot:entryROM:$10): %s", k, table.concat(t, " "))
        -- every slot, linked or not, whose entry lies in the helper body
        local hs = {}
        for s = 0x1000, 0x1400, 0x30 do
          local r = n1.rom(n1.ent(s))
          if r >= 697190 and r <= 697215 then hs[#hs + 1] = string.format("%04X:%d:$10=%04X", s, r, kit.r16(s + 0x10)) end
        end
        L("dump+%d helper-body slots: %s | exec first-insn=%d ORA=%d", k, table.concat(hs, " "), H.helperFirst, H.helperBody)
        m.wait(1)
      end
    end
    -- watch phase: no more HP pokes
    local lastBit, lastHelper, lastScene = nil, nil, nil
    local hp0 = kit.r16(0x0ACE)
    local peakHelper = 0
    for t = 0, (o.watch or 900) do
      local bit = (kit.r16(pa + 0x10) & 0x0200) ~= 0
      local hn = 0
      for _, s in ipairs(n1.live()) do
        local r = n1.rom(n1.ent(s))
        if r >= 697198 and r <= 697210 then hn = hn + 1 end
      end
      if hn > peakHelper then peakHelper = hn end
      local sc = kit.r16(0x0644) & 0xFF
      if bit ~= lastBit or hn ~= lastHelper or sc ~= lastScene or t % 120 == 0 then
        L("t=%d bit0200=%s helperActors=%d scene=%02X HP=%d pf=%04X $10=%04X mask=%04X bossHP=%d", t, tostring(bit), hn, sc, kit.r16(0x0ACE), kit.r16(0x09AE), kit.r16(pa + 0x10), kit.r16(0x065A), g2.hp(boss))
        lastBit, lastHelper, lastScene = bit, hn, sc
      end
      gaia.hold((t % 8 < 2) and { "a" } or {}); m.wait(1)
    end
    gaia.release()
    L("helper exec count (body ORA) = %d; spawn count = %d; peak helper actors = %d; HP start of watch %d end %d", H.helperBody, H.spawnHelper, peakHelper, hp0, kit.r16(0x0ACE))
    return { lines = m.lines }
  end, o)
end
