-- description: G3 runs (verbatim Lua of every experiment): scripted-enemy hit probe, pool-full variants, scene census of the actor and thinker lists, flute, ramps, knockback into a wall, damage number slot reuse.
-- requires: mesen_kit, iog_kit, gaia_kit, a_actors, g1_kit, g3_kit, g3_hit
--
-- Every run is called as  g3r.<name>{...}  from run_script after load_state_file (disclosed pokes are listed in the result file).
g3r = g3r or {}

local function poke(S, o)
  -- o.pos = {x, y} actor position (the player's $09A2/$09A4 are 8 / 16 px less); o.hp = {hp, maxHp}
  if o.pos then
    kit.w16(0x1014, o.pos[1]); kit.w16(0x1016, o.pos[2]); kit.w16(0x09A2, o.pos[1] - 8); kit.w16(0x09A4, o.pos[2] - 16)
    S.ev(string.format("POKE position (%d,%d)", o.pos[1], o.pos[2]))
  end
  if o.hp then kit.w16(0x0ACA, o.hp[2]); kit.w16(0x0ACE, o.hp[1]); S.ev(string.format("POKE hp=%d max=%d", o.hp[1], o.hp[2])) end
end

-- scripted-enemy / contact hit probe. o = { tag, frames, pos, hp, hold (buttons held before the hit), holdAfter (buttons held after the hit, for `holdFor` frames),
--   fillActors (keep), fillAt, fillOnHit (keep: fill at the entry of the first hit routine), win }
function g3r.hit(o)
  g3.trial{ frames = o.frames or 200, tag = o.tag, out = "G3_" .. o.tag .. ".txt", show = 12, maxEv = 700,
    fillActors = o.fillActors, fillThinkers = o.fillThinkers, fillAt = o.fillAt,
    hooks = function(S) g3.hitProbe(S, { win = o.win or 80, fillOnHit = o.fillOnHit }) end,
    setup = function(S) poke(S, o) end,
    sched = function(t, S)
      local h
      if S.hitT then
        if t - S.hitT < (o.holdFor or 90) then h = o.holdAfter end
      elseif t >= 1 then h = o.hold end
      S.curHold = h and table.concat(h, "+") or nil
      return h
    end,
    tick = function(t, S) g3.rowTick(t, S); if t >= (o.frames or 200) - 2 and not S.tailDone then S.tailDone = true; g3.hitTail(S) end end }
end

-- thinker pool full: pop the thinker free list at fillAt, then let a COP SpawnThinker / SpawnThinkerParam run (the player's death sequence spawns DeathPaletteFadeThinker).
-- Logs the allocator result (carry, Y) after `JSR AllocateSpecialActor` (37952 in SpawnThinker, 37892 in SpawnThinkerParam) and every write to the player's slot $1000-$1003 / $100E
-- and to the extended word $7F:100E; plus the thinker list writes.
-- o = { tag, frames, pos, hp, hold, fillThinkers (keep), fillAt }
function g3r.thinkerFull(o)
  g3.trial{ frames = o.frames or 260, hardFrames = (o.frames or 260) + 100, tag = o.tag, out = "G3_" .. o.tag .. ".txt", show = 14, maxEv = 300,
    fillThinkers = o.fillThinkers, fillAt = o.fillAt,
    hooks = function(S)
      local function after(which)
        return function()
          local st = S.state()
          S.inc("spawnThinker")
          S.ev(string.format("%s %s carry=%d X=%04X Y=%04X D=%04X t5A=%04X t5C=%04X thinkerFree($52)=%04X", which, S.tstr(), st["cpu.ps"] & 1, st["cpu.x"], st["cpu.y"], st["cpu.d"], kit.r16(0x5A), kit.r16(0x5C), kit.r16(0x52)))
        end
      end
      S.ex(37952, after("SPAWNTHINKER-after-alloc"))
      S.ex(37892, after("SPAWNTHINKERPARAM-after-alloc"))
      S.wr(0x1000, 0x1003, function(a, v)
        S.inc("wPlayerEntry")
        local st = S.state()
        if (S.t or 0) >= (o.entryFrom or 30) and S.cnt.wPlayerEntry <= 400 then S.ev(string.format("W-PLAYER-ENTRY %s [%04X] <- %02X pc=%02X:%04X", S.tstr(), a & 0xFFFF, v & 0xFF, st["cpu.k"], st["cpu.pc"])) end
      end)
      S.wr(0x5A, 0x5D, function(a, v) S.inc("w5A5D") end)
      -- the other stores of the spawn handlers land on the caller too: $000E (oamXorFlags), $7F:0002+X (param byte) and $7F:000E+X (animScratch2)
      local function other(tag, lo, hi)
        S.wr(lo, hi, function(a, v)
          S.inc("w" .. tag)
          local st = S.state()
          if S.cnt["w" .. tag] <= 12 then S.ev(string.format("W-%s %s [%05X] <- %02X pc=%02X:%04X", tag, S.tstr(), a & 0x1FFFF, v & 0xFF, st["cpu.k"], st["cpu.pc"])) end
        end)
      end
      other("PLAYER-0E", 0x100E, 0x100F)
      other("PLAYER-EXT02", 0x11002, 0x11003)   -- $7F:1002 = animScratch+2,X with X = $1000
      other("PLAYER-EXT0E", 0x1100E, 0x1100F)   -- $7F:100E = animScratch2,X
    end,
    setup = function(S) poke(S, o) end,
    sched = function(t, S) if t >= 1 then return o.hold end return nil end,
    tick = function(t, S, w, tw)
      if S.t % 20 == 0 then S.ev(string.format("ROW t=%d scene=%02X hp=%d pflags=%04X list=%d thinkers=%d $5A=%04X $5C=%04X $52=%04X ent=%04X", S.t, kit.r16(0x0644), kit.r16(0x0ACE), kit.r16(0x09AE), w.n, tw.n, kit.r16(0x5A), kit.r16(0x5C), kit.r16(0x52), kit.r16(0x1000))) end
    end }
end

-- damage number vs victim slot reuse (state S10: bat in slot $1060). Poked: bat HP 1 ($7F:1086), bat $12 = o.f12 (default $0010 = the immune bat of the inline-lethal path), bat position, player attacks with physical B.
-- Logs the number actor (entry 56500) every frame: its X / Y, its $24 and what the $24 slot holds (entry, $10, X / Y).
function g3r.number(o)
  local V = o.victim or 0x1060
  g3.trial{ frames = o.frames or 60, tag = o.tag, out = "G3_" .. o.tag .. ".txt", show = 14, maxEv = 300, selftest = false,
    hooks = function(S)
      S.ex(56500, function()
        local x = S.state()["cpu.x"]
        S.inc("numberSpawn")
        if not S.numSlot then S.numSlot = x; S.numT = S.t end
        S.ev(string.format("NUMBER-ENTRY %s slot=%04X $24=%04X $28=%04X pos=(%d,%d) f10=%04X", S.tstr(), x, kit.r16(x + 0x24), kit.r16(x + 0x28), kit.r16(x + 0x14), kit.r16(x + 0x16), kit.r16(x + 0x10)))
      end)
      S.ex(245075, function() S.ev(string.format("ApplyHitDamageToVictim %s", S.tstr())) end)
    end,
    setup = function(S)
      kit.w16(0x10000 + V + 0x26, 1)            -- ext +26: HP ($7F:1086 for $1060)
      kit.w16(V + 0x12, o.f12 or 0x0010)
      kit.w16(V + 0x14, o.vpos and o.vpos[1] or 88); kit.w16(V + 0x16, o.vpos and o.vpos[2] or 135)
      S.ev(string.format("POKE victim %04X hp=1 $12=%04X pos=(%d,%d)", V, o.f12 or 0x0010, kit.r16(V + 0x14), kit.r16(V + 0x16)))
    end,
    sched = function(t, S) if t < 30 then return { "b" } end return nil end,
    tick = function(t, S)
      if t == 1 then kit.w16(V + 0x14, o.vpos and o.vpos[1] or 88); kit.w16(V + 0x16, o.vpos and o.vpos[2] or 135) end
      if S.numSlot and t - S.numT <= (o.rows or 22) then
        local n = S.numSlot
        local v = kit.r16(n + 0x24)
        S.ev(string.format("NUM d=%d entry=%04X f10=%04X pos=(%d,%d) $24=%04X occ: entry=%04X f10=%04X pos=(%d,%d) ", t - S.numT, kit.r16(n), kit.r16(n + 0x10), kit.r16(n + 0x14), kit.r16(n + 0x16), v, kit.r16(v), kit.r16(v + 0x10), kit.r16(v + 0x14), kit.r16(v + 0x16)))
      end
    end }
end

-- Wind Flute (state S05: scene $24, Will, item $08 equipped). Presses physical Y (logical item use $0008) at t=o.useAt for 3 frames, then holds o.after buttons from t=o.useAt+20.
-- o = { tag, frames, useAt, fillOnUse (keep: pop the actor free list at the entry of UseItem_WindFlute, 231834), after }
function g3r.flute(o)
  local useAt = o.useAt or 30
  g3.trial{ frames = o.frames or 300, hardFrames = (o.frames or 300) + 120, tag = o.tag, out = "G3_" .. o.tag .. ".txt", show = 14, maxEv = 400,
    hooks = function(S)
      S.ghost = {}
      local function gw(tag, lo, hi)
        S.wr(lo, hi, function(a, v)
          S.inc("ghost" .. tag)
          local st = S.state()
          if #S.ghost < 60 then S.ghost[#S.ghost + 1] = string.format("GHOST %s %s [%05X] <- %02X pc=%02X:%04X", S.tstr(), tag, a & 0x1FFFF, v & 0xFF, st["cpu.k"], st["cpu.pc"]) end
        end)
      end
      gw("low", 0x1FC0, 0x1FFF); gw("extA", 0x11FC0, 0x11FFF); gw("extB", 0x12FC0, 0x12FFF)
      S.ex(231834, function()
        local st = S.state()
        S.inc("useWindFlute")
        S.ev(string.format("USE-WINDFLUTE %s form=%d scene=%02X dispMode=%04X mask=%04X pf=%04X $4E=%04X [$4E]=%04X count=%d", S.tstr(), kit.r16(0x0AD4), kit.r16(0x0644), kit.r16(0x09EC), kit.r16(0x065A), kit.r16(0x09AE), kit.r16(0x4E), kit.r16(kit.r16(0x4E)), kit.r16(0x0DBC)))
        if o.fillOnUse and not S.fillUseDone then
          S.fillUseDone = true
          local popped = g3.fillActorsNow(o.fillOnUse)
          S.ev(string.format("FILL-ON-USE %s popped=%d [$4E]=%04X count=%d", S.tstr(), popped, kit.r16(kit.r16(0x4E)), kit.r16(0x0DBC)))
        end
      end)
      S.ex(231883, function()
        local st = S.state()
        S.ev(string.format("FLUTE-SPAWN-RESULT %s Y=%04X (%s) dispMode=%04X mask=%04X", S.tstr(), st["cpu.y"], st["cpu.y"] == 0x1FC0 and "POOL FULL" or "child", kit.r16(0x09EC), kit.r16(0x065A)))
      end)
      S.ex(231897, function() S.ev(string.format("FLUTE-CONFIGURE %s Y=%04X", S.tstr(), S.state()["cpu.y"])) end)
      S.ex(237514, function() S.ev(string.format("CONTROLLER-ENTRY %s X=%04X dispMode=%04X", S.tstr(), S.state()["cpu.x"], kit.r16(0x09EC))) end)
      S.ex(237720, function() S.ev(string.format("CONTROLLER-EXIT %s dispMode=%04X", S.tstr(), kit.r16(0x09EC))) end)
    end,
    setup = function(S) S.ev(string.format("STATE scene=%02X form=%d item word $0AB6=%04X equipped $0AC4=%04X flags $0A00=%02X", kit.r16(0x0644), kit.r16(0x0AD4), kit.r16(0x0AB6), kit.r16(0x0AC4), kit.r8(0x0A00))) end,
    sched = function(t, S)
      if t >= useAt and t < useAt + 3 and not o.noUse then return { "y" } end
      if o.after and t >= useAt + 20 then
        if type(o.after) == "function" then return o.after(t) end
        return o.after
      end
      return nil
    end,
    tick = function(t, S, w, tw)
      if t % (o.rowEvery or 15) == 0 and t >= useAt - 5 then
        S.ev(string.format("ROW t=%d dispMode=%04X mask=%04X pf=%04X f10=%04X pos=(%d,%d) ent=%04X list=%d count=%d [$4E]=%04X", t, kit.r16(0x09EC), kit.r16(0x065A), kit.r16(0x09AE), kit.r16(0x1010), kit.r16(0x1014), kit.r16(0x1016), kit.r16(0x1000), w.n, kit.r16(0x0DBC), kit.r16(kit.r16(0x4E))))
      end
      if t >= (o.frames or 300) - 1 and not S.tailDone then
        S.tailDone = true
        S.tail = S.tail or {}
        for _, l in ipairs(S.ghost) do S.tail[#S.tail + 1] = l end
      end
    end }
end

-- Ramp launch (state S14, scene $85). Place the player west of ramp_west `slot` (default $1090, X 1000, Y 176) like the B4 sweep: actor X = rampX - 100, Y = rampY + 16,
-- $09B2 (speed EW) = 8, $09B4 / $09C6 = 0, playerFlags bit $1000 cleared, right held. o.fillAtLaunch = keep: pop the free list at the entry of RampPlayerClimbWest (54517).
-- Hooks: 54517 climb entry, 54522 after SpawnAfter, 54528 the store through X (orbitDiameter, X): X, the entry of the actor X, the old value; the store target is read back one frame later.
function g3r.ramp(o)
  local slot = o.slot or 0x1090
  g3.trial{ frames = o.frames or 300, hardFrames = (o.frames or 300) + 100, tag = o.tag, out = "G3_" .. o.tag .. ".txt", show = 14, maxEv = 400,
    hooks = function(S)
      S.ghost = {}
      local function gw(tag, lo, hi)
        S.wr(lo, hi, function(a, v)
          S.inc("ghost" .. tag)
          local st = S.state()
          if #S.ghost < 40 then S.ghost[#S.ghost + 1] = string.format("GHOST %s %s [%05X] <- %02X pc=%02X:%04X", S.tstr(), tag, a & 0x1FFFF, v & 0xFF, st["cpu.k"], st["cpu.pc"]) end
        end)
      end
      gw("low", 0x1FC0, 0x1FFF); gw("extA", 0x11FC0, 0x11FFF); gw("extB", 0x12FC0, 0x12FFF)
      S.ex(54517, function()
        S.inc("climbEntry")
        S.climbT = S.t
        S.ev(string.format("CLIMB-ENTRY %s pos=(%d,%d) f10=%04X pf=%04X player$06=%04X [$4E]=%04X count=%d list=%d", S.tstr(), kit.r16(0x1014), kit.r16(0x1016), kit.r16(0x1010), kit.r16(0x09AE), kit.r16(0x1006), kit.r16(kit.r16(0x4E)), kit.r16(0x0DBC), #aact.live()))
        if o.fillAtLaunch and not S.fillRampDone then
          S.fillRampDone = true
          local popped = g3.fillActorsNow(o.fillAtLaunch)
          S.ev(string.format("FILL-AT-LAUNCH %s popped=%d [$4E]=%04X count=%d", S.tstr(), popped, kit.r16(kit.r16(0x4E)), kit.r16(0x0DBC)))
        end
      end)
      S.ex(54522, function()
        local st = S.state()
        S.ev(string.format("AFTER-SPAWNAFTER %s X=%04X Y=%04X player$06=%04X count=%d [$4E]=%04X", S.tstr(), st["cpu.x"], st["cpu.y"], kit.r16(0x1006), kit.r16(0x0DBC), kit.r16(kit.r16(0x4E))))
      end)
      S.ex(54528, function()
        local x = S.state()["cpu.x"]
        S.target = x
        S.targetOld = kit.r16(0x10012 + x)
        S.ev(string.format("STORE-ORBITDIAMETER %s X=%04X (%s) entry(X)=%04X f10(X)=%04X old $7F:0012+X=%04X", S.tstr(), x, x == 0x1000 and "the player" or (x == 0x1FC0 and "ghost slot" or "other actor"), kit.r16(x), kit.r16(x + 0x10), S.targetOld))
        S.targetCheck = S.t
      end)
    end,
    setup = function(S)
      kit.w16(0x1014, o.x or (1000 - 100)); kit.w16(0x1016, o.y or (176 + 16))
      kit.w16(0x09B2, 8); kit.w16(0x09B4, 0); kit.w16(0x09C6, 0)
      kit.w16(0x09AE, kit.r16(0x09AE) & 0xEFFF)
      S.ev(string.format("POKE place pos=(%d,%d) speedEW=8 slot %04X entry=%04X pos=(%d,%d)", kit.r16(0x1014), kit.r16(0x1016), slot, kit.r16(slot), kit.r16(slot + 0x14), kit.r16(slot + 0x16)))
    end,
    sched = function(t, S) if t >= 1 then return { "right" } end return nil end,
    tick = function(t, S, w, tw)
      if S.targetCheck and S.targetCheck == t - 1 then
        S.ev(string.format("TARGET-AFTER %s $7F:0012+X=%04X (stored $0008 or $FFF8)", S.tstr(), kit.r16(0x10012 + S.target)))
      end
      if t % (o.rowEvery or 10) == 0 or (S.climbT and t - S.climbT < 3) then
        S.ev(string.format("ROW t=%d pos=(%d,%d) f10=%04X pf=%04X ent=%04X spdEW=%04X mask=%04X list=%d count=%d", t, kit.r16(0x1014), kit.r16(0x1016), kit.r16(0x1010), kit.r16(0x09AE), kit.r16(0x1000), kit.r16(0x09B2), kit.r16(0x065A), w.n, kit.r16(0x0DBC)))
      end
      if t >= (o.frames or 300) - 1 and not S.tailDone then
        S.tailDone = true
        S.tail = S.tail or {}
        for _, l in ipairs(S.ghost) do S.tail[#S.tail + 1] = l end
      end
    end }
end

-- Knockback of an enemy into a wall (state S10: bat in slot $1060, player (88,160) facing north, attack = physical B held).
-- Disclosed pokes: bat HP 30 ($7F:1086), bat position (88,135) at t=0 and t=1 (as in G1), and when o.wall is set the collision cells (tx 4..6, ty 6..7) are painted with o.wall (0F = solid).
-- Hooks: 55415 stagger start, 55621 cut-short vertical (the zeroing is about to run), 55668 cut-short horizontal, 55688 ResolveHit entry; per-frame rows of the bat from the hit to hit+30.
function g3r.wall(o)
  local V = 0x1060
  g3.trial{ frames = o.frames or 60, tag = o.tag, out = "G3_" .. o.tag .. ".txt", show = 14, maxEv = 300, selftest = false,
    hooks = function(S)
      S.ex(55415, function()
        local x = S.state()["cpu.x"]
        S.staggerT = S.t; S.child = x
        S.ev(string.format("STAGGER-START %s child=%04X $28=%d (dir) tier=%d victim=%04X victim pos=(%d,%d) $10=%04X", S.tstr(), x, kit.r16(x + 0x28), kit.r16(0x1101C + kit.r16(x + 0x24)), kit.r16(x + 0x24), kit.r16(kit.r16(x + 0x24) + 0x14), kit.r16(kit.r16(x + 0x24) + 0x16), kit.r16(kit.r16(x + 0x24) + 0x10)))
      end)
      local function cut(which)
        return function()
          local v = kit.r16(S.child + 0x24)
          S.ev(string.format("CUT-SHORT-%s %s victim=%04X $08=%04X $2C=%04X $2E=%04X ext2C=%04X ext2E=%04X entry=%04X child pos=(%d,%d) $26=%d", which, S.tstr(), v, kit.r16(v + 8), kit.r16(v + 0x2C), kit.r16(v + 0x2E), kit.r16(0x1002C + v), kit.r16(0x1002E + v), kit.r16(v), kit.r16(S.child + 0x14), kit.r16(S.child + 0x16), kit.r16(S.child + 0x26)))
        end
      end
      S.ex(55621, cut("V")); S.ex(55668, cut("H"))
      S.ex(55688, function()
        local v = kit.r16(S.child + 0x24)
        S.ev(string.format("RESOLVE-ENTRY %s victim=%04X $08=%04X $2C=%04X $2E=%04X entry=%04X hp=%d", S.tstr(), v, kit.r16(v + 8), kit.r16(v + 0x2C), kit.r16(v + 0x2E), kit.r16(v), kit.r16(0x10026 + v)))
      end)
    end,
    setup = function(S)
      kit.w16(0x10026 + V, 30)
      local dy = o.dy or 0
      kit.w16(V + 0x14, 88); kit.w16(V + 0x16, 135 + dy)
      if dy ~= 0 then kit.w16(0x1016, 160 + dy); kit.w16(0x09A4, 144 + dy); S.ev(string.format("POKE player (88,%d)", 160 + dy)) end
      if o.wall then
        for ty = 6, 7 do for tx = 4, 6 do gaia.coll.set(tx, ty, o.wall) end end
        S.ev(string.format("POKE walls tx 4..6 ty 6..7 = %02X", o.wall))
      end
      S.ev(string.format("POKE bat HP 30, pos (88,135); entry=%04X $10=%04X $12=%04X", kit.r16(V), kit.r16(V + 0x10), kit.r16(V + 0x12)))
    end,
    sched = function(t, S) if t < 6 then return { "b" } end return nil end,
    tick = function(t, S)
      if t == 1 then kit.w16(V + 0x14, 88); kit.w16(V + 0x16, 135 + (o.dy or 0)) end
      if S.staggerT and t - S.staggerT <= (o.rows or 26) then
        S.ev(string.format("BAT d=%d entry=%04X pos=(%d,%d) $08=%04X $2C=%04X $2E=%04X ext2C=%04X ext2E=%04X $10=%04X $12=%04X ctr=%d", t - S.staggerT, kit.r16(V), kit.r16(V + 0x14), kit.r16(V + 0x16), kit.r16(V + 8), kit.r16(V + 0x2C), kit.r16(V + 0x2E), kit.r16(0x1002C + V), kit.r16(0x1002E + V), kit.r16(V + 0x10), kit.r16(V + 0x12), g3.s16(kit.r16(0x10028 + V))))
      end
    end }
end

-- list census over a scene change: from a loaded state, write sceneNext ($0642) at t=3, dismiss the banner with A pulses, run `frames` NMI frames.
-- The walkers (actor list and thinker list) run every frame; exec hooks count the sole-entry removals (UnlinkActor head path 44875 with $56 = 0 afterwards,
-- KillThinker head path 37967 with $5A = 0 afterwards) and log the list state at that instant.
-- o = { tag, scene, frames, fillThinkers (keep), fillAt }
function g3r.scene(o)
  g3.trial{ frames = o.frames or 400, hardFrames = o.hardFrames or ((o.frames or 400) + 200), tag = o.tag, out = "G3_" .. o.tag .. ".txt", show = 12, maxEv = 300,
    fillThinkers = o.fillThinkers, fillAt = o.fillAt, fillActors = o.fillActors,
    hooks = function(S)
      S.ex(44875, function()
        S.inc("unlinkHead")
        if kit.r16(0x56) == 0 then
          S.inc("unlinkSole")
          S.ev(string.format("UNLINK-SOLE %s $56=0000 $58=%04X count=%d scene=%02X", S.tstr(), kit.r16(0x58), kit.r16(0x0DBC), kit.r16(0x0644)))
        end
      end)
      S.ex(37967, function()
        S.inc("killThinkerHead")
        if kit.r16(0x5A) == 0 then
          S.inc("killThinkerSole")
          S.ev(string.format("KILLTHINKER-SOLE %s $5A=0000 $5C=%04X scene=%02X", S.tstr(), kit.r16(0x5C), kit.r16(0x0644)))
        end
      end)
      -- writes to the list head / tail words: count and log the first ones with the writer
      -- (byte writes; the 16-bit STA/STY of a head or tail word is two callbacks, low byte first; the pc is the instruction after the store)
      local function trace(tag)
        return function(a, v)
          S.inc("w" .. tag)
          if o.trace then
            local st = S.state()
            S.ev(string.format("W%s %s [%04X] <- %02X pc=%02X:%04X", tag, S.tstr(), a & 0xFFFF, v & 0xFF, st["cpu.k"], st["cpu.pc"]))
          end
        end
      end
      S.wr(0x5A, 0x5D, trace("5A5D"))
      S.wr(0x56, 0x59, trace("5659"))
    end,
    setup = function(S) S.sceneWas = kit.r16(0x0644) end,
    sched = function(t, S)
      if t == 3 and o.scene and kit.r16(0x0642) == 0 then
        kit.w16(0x0642, o.scene); S.ev(string.format("POKE sceneNext=%02X", o.scene))
      end
      if kit.r8(0x00B4) ~= 0 and o.scene and t > 3 then return ((t % 6) < 3) and { "a" } or {} end
      return nil
    end,
    tick = function(t, S, w, tw)
      local sc = kit.r16(0x0644)
      if sc ~= S.lastScene then S.lastScene = sc; S.ev(string.format("SCENE %s -> %02X (list %d, thinkers %d, $56=%04X $58=%04X $5A=%04X $5C=%04X)", S.tstr(), sc, w.n, tw.n, kit.r16(0x56), kit.r16(0x58), kit.r16(0x5A), kit.r16(0x5C))) end
      if w.n == 0 and not S.emptyNoted then S.emptyNoted = true; S.ev(string.format("EMPTY-ACTOR-LIST %s scene=%02X $56=%04X $58=%04X count=%d", S.tstr(), sc, kit.r16(0x56), kit.r16(0x58), kit.r16(0x0DBC))) end
      if tw.n == 0 and not S.tEmptyNoted then S.tEmptyNoted = true; S.ev(string.format("EMPTY-THINKER-LIST %s scene=%02X $5A=%04X $5C=%04X", S.tstr(), sc, kit.r16(0x5A), kit.r16(0x5C))) end
    end }
end
