-- description: G3 hit-stun probe for g3.trial: hooks ApplyPlayerHitstun, ApplyInteractionDamage, the stagger child, the player controller's stun gate, the sfx queue and the ghost slot $1FC0; per-frame rows around the hit.
-- requires: mesen_kit, iog_kit, gaia_kit, a_actors, g1_kit, g3_kit
--
--   g3.hitProbe(S, {win=70, ghost=true})   call from the `hooks` function of g3.trial; S.hitT = run clock of the first hit entry (either routine)
--   g3.rowTick(t, S)                       call from `tick`; one row per frame from 3 frames before the first hit to `win` frames after it
--
-- Offsets (decimal PRG offsets): 50071 ApplyPlayerHitstun, 50146 CPY #$1FC0 after its spawn, 50186 PlaySoundCh2 COP, 55415 HitStaggerMain,
-- 55556 HitStaggerSlideLoop, 55787 HitStaggerReleasePlayer, 246752 ApplyInteractionDamage, 176824 player controller iframe read,
-- 176830 stunned return (PLX before RTL), 176832 not-stunned continue, 248642 / 248674 RunActors_Normal counter read and tick.
g3 = g3 or {}

local WR  = emu.memType.snesWorkRam
local P   = emu.memType.snesPrgRom
local CPU = emu.cpuType.snes

local function ctr(s) return g3.s16(kit.r16(0x10028 + s)) end

function g3.hitProbe(S, o)
  o = o or {}
  S.win = o.win or 70
  S.pm = {}          -- per run clock: 'stun' (controller returned early) or 'pass'
  S.hits = {}
  S.ghostW = {}
  S.sfx = {}
  local function mark(kind)
    if not S.hitT and S.t then S.hitT = S.t end
  end
  -- o.fillOnHit = keep: pop the actor free list down to `keep` entries at the entry of the first hit routine that runs (the pool is full at that instant)
  local function fillNow(where)
    if o.fillOnHit and not S.fillHitDone then
      S.fillHitDone = true
      local n0 = select(2, g3.freeActors())
      local popped = g3.fillActorsNow(o.fillOnHit)
      S.ev(string.format("FILL-ON-HIT %s at %s popped=%d (free %d -> %d) count=%d [$4E]=%04X", S.tstr(), where, popped, n0, select(2, g3.freeActors()), kit.r16(0x0DBC), kit.r16(kit.r16(0x4E))))
    end
  end
  S.ex(50071, function()
    mark()
    fillNow("ApplyPlayerHitstun")
    local st = S.state()
    local sp = st["cpu.sp"]
    local ra, rb = kit.r16(sp + 1), kit.r8(sp + 3)
    local pf = kit.r16(0x09AE)
    S.inc("hitstunCalls")
    S.hits[#S.hits + 1] = S.t
    S.ev(string.format("HITSTUN %s A=%04X Y=%04X ret=%02X:%04X form=%d hp=%d pf=%04X mask=%04X [$4E]=%04X free=%d list=%d count=%d", S.tstr(), st["cpu.a"], st["cpu.y"], rb, (ra + 1) & 0xFFFF,
      kit.r16(0x0AD4), kit.r16(0x0ACE), pf, kit.r16(0x065A), kit.r16(kit.r16(0x4E)), select(2, g3.freeActors()), #aact.live(), kit.r16(0x0DBC)))
  end)
  S.ex(246752, function()
    mark()
    fillNow("ApplyInteractionDamage")
    local y = S.state()["cpu.y"]
    S.inc("interactionCalls")
    if S.cnt.interactionCalls <= 2 then
      S.ev(string.format("INTERACT %s victim-source actor=%04X f10=%04X form=%d hp=%d [$4E]=%04X free=%d", S.tstr(), y, kit.r16(y + 0x10), kit.r16(0x0AD4), kit.r16(0x0ACE), kit.r16(kit.r16(0x4E)), select(2, g3.freeActors())))
    end
  end)
  S.ex(50146, function()
    local st = S.state()
    S.ev(string.format("HITSTUN-SPAWN %s Y=%04X (%s) joypadMask=%04X", S.tstr(), st["cpu.y"], st["cpu.y"] == 0x1FC0 and "POOL FULL" or "child", kit.r16(0x065A)))
  end)
  S.ex(50186, function()
    S.ev(string.format("HITSTUN-SOUND %s COP PlaySoundCh2 #07 executed, form=%d", S.tstr(), kit.r16(0x0AD4)))
  end)
  S.ex(55415, function()
    local x = S.state()["cpu.x"]
    local v = kit.r16(x + 0x24)
    S.inc("staggerStart")
    S.staggerT = S.t
    S.ev(string.format("STAGGER-START %s child=%04X flags=%04X $28=%d victim=%04X ctr(victim)=%d", S.tstr(), x, kit.r16(x + 0x10), kit.r16(x + 0x28), v, ctr(v)))
  end)
  S.ex(55787, function()
    S.inc("releasePlayer")
    S.releaseT = S.t
    S.ev(string.format("RELEASE-PLAYER %s ctr(player)=%d slide frames since start=%s", S.tstr(), ctr(0x1000), S.staggerT and tostring(S.t - S.staggerT) or "?"))
  end)
  S.ex(176830, function() S.pm[S.t or -1] = "stun"; S.inc("pmStun") end)
  S.ex(176832, function() if S.pm[S.t or -1] ~= "stun" then S.pm[S.t or -1] = "pass" end; S.inc("pmPass") end)
  -- sfx queue (PlaySoundCh2 writes $06F9)
  S.wr(0x06F9, 0x06F9, function(a, v)
    if v == 0 then return end   -- the NMI clears the queue every other frame (80:837C); only the queued ids are of interest
    local st = S.state()
    S.sfx[#S.sfx + 1] = string.format("%s v=%02X pc=%02X:%04X form=%d", S.tstr(), v, st["cpu.k"], st["cpu.pc"], kit.r16(0x0AD4))
  end)
  if o.ghost ~= false then
    -- the ghost slot $1FC0: low RAM $1FC0-$1FEF, extended A $7F:1FC0-1FEF (WRAM 0x11FC0), extended B $7F:2FC0-2FEF (WRAM 0x12FC0)
    local function ghost(tag, lo, hi)
      S.wr(lo, hi, function(a, v)
        local a16 = a & 0xFFFF
        if a16 < (lo & 0xFFFF) or a16 > (hi & 0xFFFF) then return end
        local st = S.state()
        S.inc("ghost" .. tag)
        if #S.ghostW < 24 then S.ghostW[#S.ghostW + 1] = string.format("%s %s %04X <- %02X pc=%02X:%04X", S.tstr(), tag, a16, v, st["cpu.k"], st["cpu.pc"]) end
      end)
    end
    ghost("low", 0x1FC0, 0x1FFF)
    ghost("extA", 0x11FC0, 0x11FFF)
    ghost("extB", 0x12FC0, 0x12FFF)
  end
end

-- per-frame rows
function g3.rowTick(t, S)
  if not S.hitT then return end
  local d = t - S.hitT
  if d > S.win then return end
  local pl = 0x1000
  local f10 = kit.r16(pl + 0x10)
  S.rows = S.rows or {}
  local row = string.format("ROW %s d=%d ctr=%d f10=%04X pos=(%d,%d) ent=%04X mask=%04X ctl=%s pm=%s list=%d cnt=%d [$4E]=%04X", S.tstr(), d, ctr(pl), f10, kit.r16(pl + 0x14), kit.r16(pl + 0x16), kit.r16(pl),
    kit.r16(0x065A), tostring(S.curHold or "-"), tostring(S.pm[t - 1] or "-"), S.last.w and S.last.w.n or -1, kit.r16(0x0DBC), kit.r16(0x4E))
  S.ev(row)
end

-- final summary lines for the written file
function g3.hitTail(S)
  S.tail = S.tail or {}
  for _, l in ipairs(S.sfx) do S.tail[#S.tail + 1] = "SFX06F9 " .. l end
  for _, l in ipairs(S.ghostW) do S.tail[#S.tail + 1] = "GHOST " .. l end
end
