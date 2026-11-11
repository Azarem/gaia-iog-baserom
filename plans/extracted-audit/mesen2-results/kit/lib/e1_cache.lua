-- description: E1 OQ-1: log every write to the BG source-cache slot area ($7E:066C-$0681) during chained quick warps, with the LoadBgTiles operands ($0664 window start, $0666 window end, $0668 VRAM page) at the time of the write.
-- requires: mesen_kit, iog_kit, gaia_kit
--
-- run_script {includes={"gaia_kit","e1_cache"}, code='e1c.run{scenes={0x23,0x30}, settle=60, out="E1_oq1.txt"}'}
--
-- Callbacks run BEFORE the access (old value is still readable; the PC they report is the address after the writing instruction).
-- Offsets are decimal PRG (ROM file) offsets: off = ((bank & 0x3F) << 16) | pc16.
-- Each scene: wait until $0642 = 0, write the scene id to $0642 (quick warp), wait for $0644 = scene and $0642 = 0, run o.settle emulator frames.
-- The lines of a scene are appended to o.out when the scene's settle time ends (a crash in a later scene keeps the earlier lines);
-- a scene whose arrival does not happen within o.warpTimeout frames (default 600), or a wait for $0642 = 0 that lasts that long, ends the run with an error result.
-- o.append = true appends to o.out instead of replacing it (for several batches into one file).
-- Line format: s=<scene> f=<frame> <addr> <old>-><new> pc=<offset> win=<$0664>-<$0666> page=<$0668>
e1c = e1c or {}

local WR  = emu.memType.snesWorkRam
local CPU = emu.cpuType.snes
local function off24(k, pc) return ((k & 0x3F) << 16) | (pc & 0xFFFF) end

function e1c.run(o)
  local lines, nw, nz, byAddr, nlines = {}, 0, 0, {}, 0
  local cur, wroteAny = 0, o.append == true
  emu.addMemoryCallback(function(a, v)
    local addr = a & 0xFFFF
    local old = kit.r8(addr)
    local st = emu.getState()
    nw = nw + 1
    if v == 0 and old ~= 0 then nz = nz + 1 end
    local key = string.format("%04X", addr)
    byAddr[key] = (byAddr[key] or 0) + 1
    lines[#lines + 1] = string.format("s=%02X f=%d %04X %02X->%02X pc=%d win=%04X-%04X page=%04X", cur, st["frameCount"], addr, old, v,
      off24(st["cpu.k"], st["cpu.pc"]), kit.r16(0x0664), kit.r16(0x0666), kit.r16(0x0668))
  end, emu.callbackType.write, 0x066C, 0x0681, CPU, WR)

  local function flush()
    if #lines > 0 then
      emu.mcp.writeFile(o.out, table.concat(lines, "\n") .. "\n", wroteAny)
      wroteAny = true; nlines = nlines + #lines; lines = {}
    end
  end

  local idx, stage, n, arriveN = 1, "wait", 0, 0
  kit.onFrame(function()
    n = n + 1
    local sc, sn = kit.r16(0x0644), kit.r16(0x0642)
    if kit.r8(0x00B4) ~= 0 then gaia.hold((n % 6 < 3) and { "a" } or {}) else gaia.release() end
    if stage == "wait" and n > (o.warpTimeout or 600) then
      flush()
      kit.finish({ error = "wait_timeout", scene = cur, scene644 = sc, next = sn, writes = nw, lines = nlines, byAddr = byAddr })
      return
    end
    if stage == "wait" then
      if n >= 5 and sn == 0 then
        cur = o.scenes[idx]
        kit.w16(0x0642, cur)
        stage = "warping"
      end
    elseif stage == "warping" then
      if sc == cur and sn == 0 then stage = "run"; arriveN = n
      elseif n > (o.warpTimeout or 600) then
        flush()
        kit.finish({ error = "warp_timeout", scene = cur, scene644 = sc, next = sn, writes = nw, lines = nlines, byAddr = byAddr })
        return
      end
    elseif stage == "run" then
      if n - arriveN >= (o.settle or 60) then
        flush()
        idx = idx + 1
        if idx > #o.scenes then
          kit.finish({ writes = nw, nonzeroToZero = nz, byAddr = byAddr, lines = nlines, scenes = #o.scenes })
        else
          stage = "wait"; n = 0
        end
      end
    end
  end)
end
