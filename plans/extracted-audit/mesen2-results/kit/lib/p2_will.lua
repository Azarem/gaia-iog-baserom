-- description: P2 Will abilities (S10): Spin Dash / Psycho Slider / Psycho Dash level-word matrix ($0B16/$0B18/$0B1A), damage records reads, body row and metasprite pointers at the end of the Spin Dash, writes of the player animation index.
-- requires: mesen_kit, iog_kit, gaia_kit, p2_kit
--
-- ROM O offsets (decimal ; {n} tags):
--   attack_ability_system.asm: PsychoDashMain 179872 (LoadAbilityDamageA return 179878?), SpinDashMain 180393, charge end (LDA #$0002 / LoadAbilityDamageA) 180475, return of that loader 180481,
--     SpinDashLaunch 180633, SpinDashLaunchLoop 180643, StagePlayerSprite #03 180678, #02 180683, #00 180696, #01 180701, SpinDashAbort 180708.
--   player_character.asm: RunAttackNS LoadAbilityDamageA 183295 (return 183301), RunAttackEW 183378 (return 183384).
--   ability_damage_tables: records at ROM 121255..121303 (HiROM $01:D9A7..$D9D7; bank-1 mirrors $41/$81/$C1).
-- Player actor slot $1000: spritesetPtr = 3 bytes at 0x10006+slot, metaspritePtr = 0x1000C+slot (WRAM offsets), anim index +$28, frame +$2A.
p2will = {}

local P = emu.memType.snesPrgRom
local function r16(a) return kit.r16(a) end

function p2will.go(specs, frames, out)
  local N = #specs
  local function snap(S, name)
    local s = 0x1000
    p2.ev(S, "t=%d %s pf=%04X row=%02X anim=%04X frame=%04X sprset=%02X:%04X meta=%04X $09E0=%d $09E2=%d lv0B16/18/1A=%d/%d/%d pos=(%d,%d) speed=(%d,%d)", S.t, name, r16(0x09AE), r16(0x0AC8) & 0xFF, r16(0x1028), r16(0x102A),
      kit.r8(0x10008 + s), r16(0x10006 + s), r16(0x1000C + s), r16(0x09E0), r16(0x09E2), r16(0x0B16), r16(0x0B18), r16(0x0B1A), r16(0x1014), r16(0x1016), p2.s16(r16(0x09B2)), p2.s16(r16(0x09B4)))
  end
  local function mk(name) return function(S, st, n) snap(S, name) end end

  local marks = {
    pdMain = { 179872, mk("PsychoDashMain") },
    spinMain = { 180393, function(S, st, n) S.spinMainT = S.spinMainT or S.t; snap(S, "SpinDashMain") end },
    spinChargeEnd = { 180475, function(S, st, n) S.chargeEndT = S.t; snap(S, "SpinDash charge complete ($26=" .. r16(0x1026) .. ")") end },
    spinAfterLoadA = { 180481, mk("after LoadAbilityDamageA #2 (charge end)") },
    spinLaunch = { 180633, mk("SpinDashLaunch (before LoadAbilityDamageA #1)") },
    spinLaunchLoop = { 180643, function(S, st, n)
      snap(S, "SpinDashLaunchLoop (after LoadAbilityDamageA #1)")
      if S.spec.short and not S.shortDone then
        S.shortDone = true
        local lc = r16(0x10014 + 0x1000)
        kit.w16(0x10014 + 0x1000, 1)
        p2.ev(S, "t=%d poke loopCounter %d -> 1 (disclosed): ends the dash after one more pass; the unmodified dash runs 12 passes of 9 ticks at 7 px and reaches a wall", S.t, lc)
      end
    end },
    spStageEast = { 180678, mk("StagePlayerSprite #03 (east)") }, spStageWest = { 180683, mk("StagePlayerSprite #02 (west)") },
    spStageSouth = { 180696, mk("StagePlayerSprite #00 (south)") }, spStageNorth = { 180701, mk("StagePlayerSprite #01 (north)") },
    spAfterStage = { 180704, mk("after StagePlayerSprite, before AnimOneFrame (SpinDashDir*)") },
    spinAbort = { 180708, function(S, st, n) S.abortT = S.t; snap(S, "SpinDashAbort") end },
    slGate = { 183186, function(S, st, n)
      if S.spec.kind ~= "slider" then return end
      local dir = S.spec.dir or "right"
      local ax = (dir == "up" or dir == "down") and 0x09B4 or 0x09B2
      local sgn = (dir == "left" or dir == "up") and -3 or 3
      local e = p2.s16(r16(ax))
      local pressed = (r16(0x0656) & 0x0080) ~= 0
      if pressed and math.abs(e) < 3 then
        kit.w16(ax, sgn & 0xFFFF)
        p2.ev(S, "t=%d CheckRunAttack with attack pressed: speed %d -> %d (disclosed poke) pf=%04X f10=%04X", S.t, e, sgn, r16(0x09AE), r16(0x1010))
      end
    end },
    slSpeed = { 183221, function(S, st, n) p2.ev(S, "t=%d RunAttackSpeedCheck speed=(%d,%d)", S.t, p2.s16(r16(0x09B2)), p2.s16(r16(0x09B4))) end },
    slNS = { 183301, mk("RunAttackNS after LoadAbilityDamageA") }, slEW = { 183384, mk("RunAttackEW after LoadAbilityDamageA") },
  }

  p2.run{ frames = frames, variants = N, tag = "will", out = out or "P2_will.txt", show = 0, marks = marks,
    writes = {
      { name = "body0AC8", lo = 0x0AC8, hi = 0x0AC9 },
      -- the player animation index (+$28) written while the body override is active (playerFlags bit 15 set, i.e. the abilities table is the one decoded)
      { name = "anim1028ov", lo = 0x1028, hi = 0x1028, cond = function(a, v) return (kit.r16(0x09AE) & 0x8000) ~= 0 end },
      { name = "anim1028all", lo = 0x1028, hi = 0x1028 },
      { name = "form0AD4", lo = 0x0AD4, hi = 0x0AD5 },
      { name = "recRead", lo = 121255, hi = 121303, kinds = { "read" }, mem = P },
    },
    vsetup = function(S, v)
      local sp = specs[v]
      S.spec = sp; S.spinMainT = nil; S.chargeEndT = nil; S.abortT = nil; S.shortDone = nil; S.pdx, S.pdy = nil, nil
      kit.w16(0x0B16, sp.pd or 0); kit.w16(0x0B18, sp.sl or 0); kit.w16(0x0B1A, sp.sd or 0)
      return string.format("%s pd=%d sl=%d sd=%d dir=%s", sp.kind, sp.pd or 0, sp.sl or 0, sp.sd or 0, sp.dir or "right")
    end,
    sched = function(t, S, v)
      local sp = S.spec
      local dir = sp.dir or "right"
      if sp.kind == "pd" then
        if t >= 1 and t <= 3 then return { dir } end
        if t >= 6 and t <= 171 then return { "b" } end
        return nil
      elseif sp.kind == "sd" then
        if t >= 1 and t <= 3 then return { dir } end
        local b = { "b" }
        if S.spinMainT and t >= S.spinMainT + 1 then b[#b + 1] = dir end
        if S.spinMainT and not S.abortT and t >= S.spinMainT + 2 and not S.chargeEndT then
          -- fresh L/R presses alternating (2 ticks down, 2 up): L R L R ...
          -- the key the charge tick wants: $26 odd = L, even = R (SpinDashChargeTick)
          if (t - S.spinMainT - 2) % 4 < 2 then b[#b + 1] = (r16(0x1026) % 2 == 1) and "l" or "r" end
        end
        if t >= 6 and t <= 230 then
          if t >= 170 and t <= 172 and not S.spinMainT then b[#b + 1] = "l" end -- launches the Spin Dash once the extended charge starts (needs 40 + 120 ticks)
          return b
        end
        if S.spinMainT and not S.abortT then return b end
        return nil
      else -- slider
        -- CheckRunAttack is called from the inertial states (MovingEastWest / MovingNorthSouth: speed nonzero, no D-pad held): walk, release the D-pad with speed 3, press attack
        if t >= 24 and t <= 28 then return { "b" } end
        if t >= 1 and t <= 21 then return { dir } end
        return nil
      end
    end,
    tick = function(t, S, v)
      local dir = S.spec.dir or "right"
      if t == 10 then
        local x, y = 120, 144
        if dir == "left" then x = (S.spec.kind == "slider") and 240 or 280 end
        if dir == "right" and S.spec.kind == "slider" then x = 100 end
        if dir == "up" or dir == "down" then
          x, y = 200, 144
          for _, ty in ipairs({ 3, 4, 12, 13 }) do for tx = 1, 30 do gaia.coll.set(tx, ty, 0) end end
        end
        kit.w16(0x1014, x); kit.w16(0x1016, y); kit.w16(0x09A2, x - 8); kit.w16(0x09A4, y - 16)
        p2.ev(S, "t=10 poke actor=(%d,%d) form=%d abilities=%04X%s", x, y, r16(0x0AD4), r16(0x0AA2), (dir == "up" or dir == "down") and "; collision rows 3,4,12,13 cleared (as in the P2 Psycho Dash run)" or "")
      end
      if S.spec.kind == "pd" and t >= 172 and t <= 206 then
        -- Psycho Dash trace: player position and displacement from the position at PsychoDashMain (mark pdMain, t = 173)
        local x, y = r16(0x1014), r16(0x1016)
        if not S.pdx then S.pdx, S.pdy = x, y end
        p2.row(S, "t=%d pd pos=(%d,%d) d=(%d,%d) speed=(%d,%d) anim=%04X f10=%04X pf=%04X $09E0=%d", t, x, y, p2.s16(x - S.pdx), p2.s16(y - S.pdy), p2.s16(r16(0x09B2)), p2.s16(r16(0x09B4)), r16(0x1028), r16(0x1010), r16(0x09AE), r16(0x09E0))
      end
      if S.spec.kind == "slider" and t == 21 then
        local ax = (dir == "up" or dir == "down") and 0x09B4 or 0x09B2
        local sgn = (dir == "left" or dir == "up") and -3 or 3
        local e = p2.s16(r16(ax))
        kit.w16(ax, sgn & 0xFFFF)
        p2.ev(S, "t=21 poke speed%s %d -> %d as the D-pad is released (disclosed) pf=%04X f10=%04X anim=%04X", ax == 0x09B4 and "Ns" or "Ew", e, sgn, r16(0x09AE), r16(0x1010), r16(0x1028))
      end
      if S.spec.kind == "slider" and t >= 20 and t <= 40 then
        p2.row(S, "t=%d slider-probe speed=(%d,%d) pos=(%d,%d) anim=%04X f10=%04X pf=%04X pad=%04X", t, p2.s16(r16(0x09B2)), p2.s16(r16(0x09B4)), r16(0x1014), r16(0x1016), r16(0x1028), r16(0x1010), r16(0x09AE), r16(0x0656))
      end
      if S.spinMainT and not S.chargeEndT and t <= S.spinMainT + 70 then
        p2.row(S, "t=%d charge $26=%d joypadCurrent=%04X joypadHeld=%04X raw=%04X anim=%04X", t, r16(0x1026), r16(0x0656), r16(0x0658), r16(0x0660), r16(0x1028))
      end
      if S.chargeEndT and not S.abortT and t >= S.chargeEndT + 56 and t <= S.chargeEndT + 100 then
        p2.row(S, "t=%d dash pos=(%d,%d) speed=(%d,%d) anim=%04X f10=%04X pf=%04X entry=%04X loop=%04X", t, r16(0x1014), r16(0x1016), p2.s16(r16(0x09B2)), p2.s16(r16(0x09B4)), r16(0x1028), r16(0x1010), r16(0x09AE), r16(0x1000), r16(0x10014 + 0x1000))
      end
      if S.abortT and t <= S.abortT + 40 then
        p2.row(S, "t=%d pf=%04X row=%02X anim=%04X sprset=%02X:%04X meta=%04X pos=(%d,%d)", t, r16(0x09AE), r16(0x0AC8) & 0xFF, r16(0x1028), kit.r8(0x10008 + 0x1000), r16(0x11006), r16(0x1100C), r16(0x1014), r16(0x1016))
      end
    end,
    collect = function(S, v) return { spec = string.format("%s pd=%d sl=%d sd=%d", S.spec.kind, S.spec.pd or 0, S.spec.sl or 0, S.spec.sd or 0), spinMainT = S.spinMainT, chargeEndT = S.chargeEndT, abortT = S.abortT } end,
  }
end
