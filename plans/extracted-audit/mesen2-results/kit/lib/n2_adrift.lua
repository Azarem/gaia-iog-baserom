-- description: N2 Gold Ship adrift scene $2F: stage one 'day' (globalScriptIndex-like counter $0AA6 and the event flags $4D / $52 the story sets for it) and stop after k frames for screenshots.
-- requires: mesen_kit, iog_kit, gaia_kit, m1_kit, n1_kit, n2_kit
--
-- dc2F_adrift dispatches on $0AA6 (SwitchCase, 7 segments 0..6). Static reading of the SetFlagByte / ClearFlagByte sites (366548 set $4D after segment 1, 367045 clear $4D after segment 2,
-- 367375 set $52 after segment 3, 367501 clear $52 after segment 4, 367637 set $4D after segment 5) gives the flags present when each state is entered:
--   state 0 none, 1 none, 2 $4D, 3 none, 4 $52, 5 none, 6 $4D.
n2ad = n2ad or {}

local FLAGS = { [0] = {}, [1] = {}, [2] = { 0x4D }, [3] = {}, [4] = { 0x52 }, [5] = {}, [6] = { 0x4D } }

-- Stage state o.day, then pulse A (dialogue advance) until PlayerPoseHold (ROM 50270) or PlayerPoseHoldExit (50285) runs, hold o.k more frames and stop there.
function n2ad.pose(o)
  local hits = { hold = 0, exit = 0 }
  local P, CPU = emu.memType.snesPrgRom, emu.cpuType.snes
  emu.addMemoryCallback(function() hits.hold = hits.hold + 1; hits.holdFrame = hits.holdFrame or m1.t end, emu.callbackType.exec, 50270, 50270, CPU, P)
  emu.addMemoryCallback(function() hits.exit = hits.exit + 1; hits.exitFrame = hits.exitFrame or m1.t end, emu.callbackType.exec, 50285, 50285, CPU, P)
  m1.run(function(m)
    local L = m.log
    kit.w16(0x0AA6, o.day)
    for _, id in ipairs(o.flags or FLAGS[o.day] or {}) do iog.setEventFlag(id) end
    kit.w16(0x0642, 0x2F)
    m.wait(2)
    local n = 0
    while n < 900 and not (kit.r16(0x0644) == 0x2F and kit.r16(0x0642) == 0 and emu.getState()["ppu.screenBrightness"] == 15) do m.wait(1); n = n + 1 end
    L("state %d in $2F after %d frames; $0AA6=%d", o.day, n, kit.r16(0x0AA6))
    local f = 0
    local last = {}
    while f < (o.max or 6000) and hits.hold == 0 and hits.exit == 0 do
      -- walk right to Kara for 90 frames (she is the interact target of segment 6), then pulse B (interact) and A (dialogue) while facing right
      if f < 90 then gaia.hold({ "right" })
      else gaia.hold(((f % 12) < 4) and { "right", "b" } or (((f % 12) < 8) and { "right", "a" } or { "right" })) end
      m.wait(1); f = f + 1
      local sc = kit.r16(0x0644) & 0xFF
      if sc ~= (last.sc or sc) or kit.r16(0x0AA6) ~= (last.day or kit.r16(0x0AA6)) then L("f=%d scene=%02X $0AA6=%d", f, sc, kit.r16(0x0AA6)) end
      last.sc, last.day = sc, kit.r16(0x0AA6)
    end
    gaia.release()
    L("pose hold hits=%d exit hits=%d after %d frames (hold at m1.t=%s, exit at %s)", hits.hold, hits.exit, f, tostring(hits.holdFrame), tostring(hits.exitFrame))
    m.wait(o.k or 20)
    local pa = kit.r16(0x09AA)
    L("player slot=%04X $28=%04X $2A=%04X $10=%04X $12=%04X pos=(%d,%d) scene=%02X dmf=%04X", pa, kit.r16(pa + 0x28), kit.r16(pa + 0x2A), kit.r16(pa + 0x10), kit.r16(pa + 0x12), kit.r16(pa + 0x14), kit.r16(pa + 0x16), kit.r16(0x0644) & 0xFF, kit.r16(0x09EC))
    return { lines = m.lines }
  end, o)
end

-- Put the player into PlayerPoseHold exactly as code_059C7A does (ROM 367784..367805: entry bank byte at 367788, entry word at 367794, then +08 := 0 and +2A := 0),
-- by poking the same words into the player actor (disclosed poke), after staging state o.day in scene $2F.
function n2ad.poseForce(o)
  m1.run(function(m)
    local L = m.log
    local P = emu.memType.snesPrgRom
    kit.w16(0x0AA6, o.day)
    for _, id in ipairs(o.flags or FLAGS[o.day] or {}) do iog.setEventFlag(id) end
    kit.w16(0x0642, 0x2F)
    m.wait(2)
    local n = 0
    while n < 900 and not (kit.r16(0x0644) == 0x2F and kit.r16(0x0642) == 0 and emu.getState()["ppu.screenBrightness"] == 15) do m.wait(1); n = n + 1 end
    for i = 1, 90 do gaia.hold((i % 8 < 4) and { "a" } or {}); m.wait(1) end -- dismiss the 'Drifting, Day N' title box
    gaia.release()
    m.wait(30)
    L("title box cleared: $065A=%04X dmf=%04X $B4=%02X", kit.r16(0x065A), kit.r16(0x09EC), kit.r8(0xB4))
    local bank = emu.read(367788, P)
    local ptr = emu.read(367794, P) | (emu.read(367795, P) << 8)
    local pa = kit.r16(0x09AA)
    L("immediate operands in ROM: bank byte %02X (367788), entry word %04X (367794); player slot %04X entry before = %02X:%04X", bank, ptr, pa, kit.r8(pa + 2), kit.r16(pa))
    kit.w8(pa + 2, bank); kit.w16(pa, ptr); kit.w16(pa + 8, 0); kit.w16(pa + 0x2A, 0)
    m.wait(o.k or 30)
    L("after %d frames: player $00=%04X $02=%02X $28=%04X $2A=%04X $10=%04X pos=(%d,%d) hits PoseHold? entry now=%d", o.k or 30, kit.r16(pa), kit.r8(pa + 2), kit.r16(pa + 0x28), kit.r16(pa + 0x2A), kit.r16(pa + 0x10),
      kit.r16(pa + 0x14), kit.r16(pa + 0x16), n1.rom(n1.ent(pa)))
    return { lines = m.lines }
  end, o)
end

-- o.day = $0AA6 value, o.k = frames to run after the scene is entered (no button presses), o.pulse = pulse A for the banner only
function n2ad.stage(o)
  m1.run(function(m)
    local L = m.log
    kit.w16(0x0AA6, o.day)
    for _, id in ipairs(o.flags or FLAGS[o.day] or {}) do iog.setEventFlag(id) end
    L("poked $0AA6=%d flags=%s; bytes $0A09=%02X $0A0A=%02X", o.day, table.concat((function() local t = {} for _, id in ipairs(o.flags or FLAGS[o.day] or {}) do t[#t + 1] = string.format("%02X", id) end return t end)(), ","),
      kit.r8(0x0A09), kit.r8(0x0A0A))
    local n = 0
    kit.w16(0x0642, 0x2F)
    m.wait(2)
    while n < 900 and not (kit.r16(0x0644) == 0x2F and kit.r16(0x0642) == 0 and emu.getState()["ppu.screenBrightness"] == 15) do m.wait(1); n = n + 1 end
    L("scene $2F reached after %d frames: $0AA6=%d $4D=%d $52=%d $36=%d", n, kit.r16(0x0AA6), (kit.r8(0x0A09) >> 5) & 1, (kit.r8(0x0A0A) >> 2) & 1, kit.r16(0x36))
    m.wait(o.k or 120)
    local st = emu.getState()
    local cg = {}
    for i = 0x21, 0x2C do cg[#cg + 1] = string.format("%04X", emu.read16(i * 2, emu.memType.snesCgRam, false)) end
    L("after k=%d: $0AA6=%d scene=%02X player anim=%04X pos=(%d,%d) $B4=%02X cg21-2C=%s cg0=%04X", o.k or 120, kit.r16(0x0AA6), kit.r16(0x0644) & 0xFF, kit.r16(0x1028), kit.r16(0x1014), kit.r16(0x1016), kit.r8(0xB4),
      table.concat(cg, " "), emu.read16(0, emu.memType.snesCgRam, false))
    return { lines = m.lines }
  end, o)
end
