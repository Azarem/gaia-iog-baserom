-- description: N2 experiment bodies (one function per scene / question); each is called from a run_script after load_state_file.
-- requires: mesen_kit, iog_kit, gaia_kit, m1_kit, n1_kit, e1_display, f1_kit, n2_kit
n2r = n2r or {}

local WR  = emu.memType.snesWorkRam
local P   = emu.memType.snesPrgRom
local CPU = emu.cpuType.snes

-- ------------------------------------------------------------------------------------------------ statue ceremony (OQ-I048-2, OQ-I048-3)
-- ROM O offsets (decimal ; {n} tags): StatueRewardEntry 52572, SpawnAfterFlags(confetti) 52797, ConfettiBurst entry 52991, RngByte (survivor path) 52999,
-- Die (confetti) 53031, orbital sparkle entry 52911, wait loop A DEC 52748, exit LDA sourceSceneId 52806.
-- o.gsi = globalScriptIndex (table index of the ceremony, 0-5), o.src = source scene, flag byte $0A1F cleared by the poke list.
function n2r.statue(o)
  o = o or {}
  local X = n2.execs({ spawn = 52797, burst1 = 52991, survive = 52999, dieC = 53031, orbEntry = 52911, ceremony = 52572, exit = 52806, waitA = 52748 })
  local imgs, rows, spawnN36, survN36 = {}, {}, {}, {}
  emu.addMemoryCallback(function() spawnN36[#spawnN36 + 1] = kit.r16(0x36) end, emu.callbackType.exec, 52797, 52797, CPU, P)
  emu.addMemoryCallback(function() survN36[#survN36 + 1] = kit.r16(0x36) end, emu.callbackType.exec, 52999, 52999, CPU, P)
  local peakConf, peakT, confFrames, lastT = 0, 0, {}, -1
  local peakOrb = 0
  local sheetT = {}
  e1.run{ scene = 0xFD, delay = 5, post = o.post or 330, noBanner = true,
    snapAt = {}, out = o.out, show = 12, runShow = 6, brief = true,
    pokes = { { addr = 0x0AAC, v = o.gsi or 1, w = 16 }, { addr = 0x0B12, v = o.src or 0x55, w = 16 }, { addr = 0x0B08, v = 0x10, w = 16 },
              { addr = 0x0B0C, v = 0x20, w = 16 }, { addr = 0x0B10, v = 0x1100, w = 16 }, { addr = 0x0A1F, v = 0x80, w = 8 } },
    tick = function(t, S, n)
      if t == lastT then return end
      lastT = t
      local conf = n2.countEnt(52991, 53031)
      local orb = n2.countEnt(52911, 52990)
      if conf > 0 then confFrames[#confFrames + 1] = t .. ":" .. conf end
      if conf > peakConf then peakConf, peakT = conf, t end
      if orb > peakOrb then peakOrb = orb end
      if t % 30 == 0 and t <= 330 then
        local s = e1.snap()
        rows[#rows + 1] = string.format("t=%d $36=%d live=%d orbit=%d conf=%d gsi=%04X spawn=%d b1=%d surv=%d sc=%02X TM=%02X TS=%02X cmMask=%02X cmUseSub=%s bgmode=%d bright=%d blank=%s bg1h=%s bg2h=%s $66=%02X dmf=%04X",
          t, kit.r16(0x36), #n1.live(), orb, conf, kit.r16(0x0AAC), X.spawn, X.burst1, X.survive, s.scene, s.TM, s.TS, s.cmMask, tostring(s.cmAddSub), s.bgMode,
          s.brightness, tostring(s.forcedBlank), s.layers[1]:match("h=(%d+)"), s.layers[2]:match("h=(%d+)"), s.hdmaMask66, s.dmf)
      end
    end,
    final = function(S)
      return { rows = rows, X = X, nspawn = #spawnN36, nsurv = #survN36, spawnN36 = table.concat(spawnN36, ","), survN36 = table.concat(survN36, ","),
               peakConf = peakConf, peakT = peakT, confFrames = table.concat(confFrames, " "), peakOrb = peakOrb }
    end }
end
