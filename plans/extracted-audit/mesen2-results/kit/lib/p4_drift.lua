-- description: P4 run file: camera_drift actors (OQ-I050-2, OQ-I050-4): warps to a scene by poking sceneNext ($0642) in a disposable run, then logs on every frame where a drift actor ran: the in-frame order of the controller, the drift code and the scroll step, the actor's $24, the target before / after the run, the scroll and the PPU BG1 scroll.
-- requires: mesen_kit, iog_kit, gaia_kit, a_actors, p4_kit
-- p4drift.go{ out = "P4_x.txt", frames = 900, scene = 0xD9, hold = {"down"}, pokes = { {addr, value16}, ... }, warpAt = 0 }
-- Marks are ROM offsets of the O build (the "; {n}" tags of extracted/functions/camera_drift.asm, camera_scroll_controller.asm, camera_tilemap.asm, system_core.asm).
p4drift = p4drift or {}
function p4drift.go(o)
  local frames = o.frames or 900
  local ev = {}          -- per-frame ordered names of the marks that fired
  local v24 = {}         -- $24 values read at the two LDA $24 sites
  local R = { nPat = 0, nSim = 0, nShip = 0, y24 = {}, x24 = {}, rows = 0, scenePoked = false, sceneSeen = -1 }
  local function add(n) ev[#ev + 1] = n end
  local function d24() local d = emu.getState()["cpu.d"]; return kit.r16(d + 0x24) end
  local pre = {}
  R.extra = {}
  for _, e in ipairs(o.extra or {}) do   -- e = { name, prgOffset }: extra exec marks, counted in R.extra[name], shown as "name" in the rows
    emu.addMemoryCallback(function() R.extra[e[1]] = (R.extra[e[1]] or 0) + 1; add("*" .. e[1]) end, emu.callbackType.exec, e[2], e[2], emu.cpuType.snes, emu.memType.snesPrgRom)
  end
  p4.run{ frames = frames, out = o.out, from = o.rows and o.rows[1] or 1, to = o.rows and o.rows[2] or 0,
    setup = function(S)
      for _, p in ipairs(o.pokes or {}) do kit.w16(p[1], p[2]) end
      if o.scene then kit.w16(0x0642, o.scene); R.scenePoked = true end
    end,
    sched = function(t) return o.hold end,
    marks = {
      UP  = { 33671,  function() add("UP") end },
      CX  = { 60246,  function() add("CX") end },
      CY  = { 60290,  function() add("CY") end },
      SS  = { 175150, function() add("SS") end },
      SIM = { 53134,  function(S) add("SIM"); R.nSim = R.nSim + 1; pre.t = { kit.r16(0x06BE), kit.r16(0x06C2) } end },
      SHP = { 53166,  function(S) add("SHP"); R.nShip = R.nShip + 1 end },
      PSE = { 53231,  function(S) add("PSE"); R.nPat = R.nPat + 1 end },
      Y24 = { 53270,  function(S) local v = d24(); add(string.format("Y24=%04X", v)); R.y24[v] = (R.y24[v] or 0) + 1; pre.ty = { kit.r16(0x06BE), kit.r16(0x06C2), kit.r16(0x06C0), kit.r16(0x06C4) } end },
      X24 = { 53316,  function(S) local v = d24(); add(string.format("X24=%04X", v)); R.x24[v] = (R.x24[v] or 0) + 1 end },
      PEN = { 53339,  function(S)
          local b = pre.ty or { 0, 0, 0, 0 }
          add(string.format("PEN(tgt %d,%d->%d,%d d1 %d,%d->%d,%d)", b[1], b[2], kit.r16(0x06BE), kit.r16(0x06C2), p4.s16(b[3]), p4.s16(b[4]), p4.s16(kit.r16(0x06C0)), p4.s16(kit.r16(0x06C4))))
        end },
    },
    tick = function(t, S, c)
      if o.tele and t == o.tele[1] + 0 and (c.sc & 0xFF) == (o.scene or 0) then
        -- disclosed poke: move the player actor (and the sprite-adjusted point) next to an enemy
        kit.w16(0x1014, o.tele[2]); kit.w16(0x1016, o.tele[3]); kit.w16(0x09A2, o.tele[2] - 8); kit.w16(0x09A4, o.tele[3] - 16)
        R.teleAt = t
      end
      if o.toEnemy and t >= o.toEnemy[1] and (t - o.toEnemy[1]) % (o.toEnemy[6] or 200) == 0 then
        -- disclosed poke: move the player actor next to the first live actor whose entry lies in [lo, hi] (dx, dy relative to that actor)
        if not R.live then
          local l = {}
          for _, sl in ipairs(aact.live()) do l[#l + 1] = string.format("%04X:%06X@%d,%d", sl, aact.ent(sl), kit.r16(sl + 0x14), kit.r16(sl + 0x16)) end
          R.live = table.concat(l, " ")
        end
        local s = aact.findEntry(o.toEnemy[2], o.toEnemy[3])
        if s then
          local x, y = (kit.r16(s + 0x14) + o.toEnemy[4]) & 0xFFFF, (kit.r16(s + 0x16) + o.toEnemy[5]) & 0xFFFF
          kit.w16(0x1014, x); kit.w16(0x1016, y); kit.w16(0x09A2, x - 8); kit.w16(0x09A4, y - 16)
          R.teleTo = string.format("slot %04X at %d,%d -> player %d,%d (t=%d)", s, kit.r16(s + 0x14), kit.r16(s + 0x16), x, y, t)
        else R.teleTo = "no actor in range at t=" .. t end
      end
      if o.keepHp then kit.w16(0x0ACE, kit.r16(0x0ACA)) end
      local interesting = false
      for _, n in ipairs(ev) do if n:sub(1, 1) == "*" or n:sub(1, 3) == "PSE" or n:sub(1, 3) == "SIM" or n:sub(1, 3) == "SHP" or n:sub(1, 3) == "Y24" or n:sub(1, 3) == "X24" or n:sub(1, 3) == "PEN" then interesting = true end end
      if c.sc & 0xFF ~= R.sceneSeen then R.sceneSeen = c.sc & 0xFF; R.sceneChangeT = t end
      if interesting and R.rows < 120 then
        R.rows = R.rows + 1
        p4.emit(S, string.format("t=%d f=%d sc=%02X pl=%d,%d tgt=%d,%d exp=%d,%d scr=%d,%d ppu=%d,%d d1=%d,%d fo=%04X [%s]", t, c.f, c.sc & 0xFF, c.px, c.py, c.tx, c.ty, c.ex_, c.ey_, c.sx, c.sy, c.ppux or -1, c.ppuy or -1, c.dx, c.dy, kit.r16(0x06C8), table.concat(ev, " ")))
      end
      ev = {}
    end,
    collect = function(S)
      local function dump(t) local s = {} for k, v in pairs(t) do s[#s + 1] = string.format("%04X:%d", k, v) end table.sort(s) return table.concat(s, ",") end
      local ex = {}
      for k, v in pairs(R.extra) do ex[#ex + 1] = k .. "=" .. v end
      table.sort(ex)
      return { extra = table.concat(ex, ","), teleAt = R.teleAt, teleTo = R.teleTo, live = R.live, nPat = R.nPat, nSim = R.nSim, nShip = R.nShip, y24 = dump(R.y24), x24 = dump(R.x24), rows = R.rows, scene = R.sceneSeen, sceneChangeT = R.sceneChangeT }
    end }
end
