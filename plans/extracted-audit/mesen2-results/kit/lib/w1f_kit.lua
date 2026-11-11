-- description: W1 address census, batch f (body table users): $0AC8 (body_table row last set by SetPlayerSpriteDirect) and every instruction that selects, applies or draws a body_table row.
-- requires: mesen_kit, iog_kit, gaia_kit, w1d_kit
--
-- Use:  includes = {"gaia_kit", "a_census", "a_actors", "w1d_kit", "w1f_kit"}
--         local h = w1f.start{logCap=60}
--         acen.run{..., final=function() return h.rowsF() end}
--
-- The census itself is w1d.start (kit/lib/w1d_kit.lua): every hit of a watch is keyed "<watch> <read|write> <K:PC>" (PC = the address AFTER the accessing instruction,
-- mapped by the harness to the instruction that ENDS there), with count, scenes, values and, for reads, the K:PC of the last write seen on the byte.
-- Added here (all keyed tables, ROM O offsets, decimal, from the `; {n}` tags of extract:lt output):
--   spsd    exec at the `STA $0AC8` of SetPlayerSpriteDirect (41019): index (A low byte), the script operand address ([$0A] / $0C of the player's direct page), D, scene
--   pf15    writes that change playerFlags bit 15 ($09AF bit 7): set / clear, K:PC, $0AC8 at that moment
--   rows    exec at the `TAX` of DecomposePlayerSprites (248127): A = body_table byte offset (row x 6) of the row the player is drawn with, with playerFlags bit 15 and characterForm
--   facing  exec at the entry of GetPlayerFacingDirection (258250): the caller (return address from the stack), playerFlags bit 15 and $0AC8; exec at the table load (258305)
--           with $0AC8; exec after the facing byte load (258323) with the byte
--   forms   probes: characterForm ($0AD4) at the two instructions that apply it (SetActorBody 44909, InitActorFromSceneData 249931)
w1f = w1f or {}

local WR = emu.memType.snesWorkRam
local function exec(off, fn)
  emu.addMemoryCallback(fn, emu.callbackType.exec, off, off, emu.cpuType.snes, emu.memType.snesPrgRom)
end

-- ROM offsets (decimal) of the 24 SetPlayerSpriteDirect COP sites of extracted/ and of related entry points
w1f.SITES = {
  { 647389, 4, "sF7_credits_player" }, { 647406, 4, "sF7_credits_player" }, { 647430, 4, "sF7_credits_player" }, { 647461, 4, "sF7_credits_player" },
  { 586293, 5, "sE6_gaia" }, { 586350, 5, "sE6_gaia" }, { 586403, 5, "sE6_gaia" }, { 586621, 5, "sE6_gaia" }, { 586673, 5, "sE6_gaia" },
  { 587257, 5, "sE6_gaia" }, { 587324, 5, "sE6_gaia" },
  { 181974, 6, "player_character" }, { 183301, 4, "player_character" }, { 183384, 4, "player_character" },
  { 178632, 6, "attack_ability_system" }, { 179908, 4, "attack_ability_system" }, { 179927, 4, "attack_ability_system" }, { 179946, 4, "attack_ability_system" },
  { 179962, 4, "attack_ability_system" }, { 180414, 4, "attack_ability_system" },
  { 50251, 4, "player_transition_handlers" }, { 50270, 4, "player_transition_handlers" }, { 50285, 4, "player_transition_handlers" },
  { 50535, 8, "player_transition_handlers" },
}
w1f.OFF = {
  SPSD_entry = 41014, SPSD_STA_0AC8 = 41019, SetActorBody = 44909, InitActorFromSceneData_form = 249931,
  DecomposePlayerSprites_TAX = 248127, GPFD = 258250, GPFD_tablePtrLoad = 258305, GPFD_resultAnd = 258323,
  PlayerAuraTransformEntry = 50519,
}

w1f.batch = {
  watch = {
    { name = "0AC8-0AC9", lo = 0x0AC8, hi = 0x0AC9, ctx = true },
    { name = "0AD4-0AD5 characterForm", lo = 0x0AD4, hi = 0x0AD5, ctx = true, kinds = { "write" } },
    { name = "player 7F0006-08 (spriteset ptr, bank)", lo = 0x11006, hi = 0x11008, ctx = true, kinds = { "write" } },
    { name = "player 7F000E (animScratch2)", lo = 0x1100E, hi = 0x1100F, ctx = true, kinds = { "write" } },
  },
  probes = {
    form_at_SetActorBody = { off = 44909, addr = 0x0AD4, size = 2 },
    form_at_InitActorFromSceneData = { off = 249931, addr = 0x0AD4, size = 2 },
    ac8_at_GPFD_LDA = { off = 258291, addr = 0x0AC8, size = 2 },
  },
  nmi = 33528,
}

local function sceneNow() return kit.r16(0x0644) end
local function frameNow() return emu.getState()["frameCount"] end

local function newT() return { keys = {}, n = 0 } end
local function tally(T, key, extra)
  local sc, f = sceneNow(), frameNow()
  local e = T.keys[key]
  if not e then
    if T.n >= 400 then return end
    e = { n = 0, first = f, sc0 = sc, scenes = {} }
    if extra then for k, v in pairs(extra) do e[k] = v end end
    T.keys[key] = e
    T.n = T.n + 1
  end
  e.n = e.n + 1
  e.last = f
  e.scenes[sc] = (e.scenes[sc] or 0) + 1
end
local function dump(T)
  local out = {}
  for k, e in pairs(T.keys) do
    local sc = {}
    for s, c in pairs(e.scenes) do sc[#sc + 1] = { s, c } end
    table.sort(sc, function(a, b) return a[1] < b[1] end)
    out[#out + 1] = { key = k, n = e.n, first = e.first, last = e.last, sc0 = e.sc0, scenes = sc, info = e.info }
  end
  table.sort(out, function(a, b) return a.key < b.key end)
  return out
end

function w1f.start(o)
  o = o or {}
  local cfg = { watch = {}, exec = {}, probes = {}, nmi = w1f.batch.nmi, control = true, logCap = o.logCap, publishEvery = o.publishEvery }
  for _, w in ipairs(w1f.batch.watch) do cfg.watch[#cfg.watch + 1] = w end
  for _, w in ipairs(o.extra or {}) do cfg.watch[#cfg.watch + 1] = w end
  for _, s in ipairs(w1f.SITES) do cfg.exec[string.format("SPSD #%02X @%d %s", s[2], s[1], s[3])] = s[1] end
  cfg.exec["SetPlayerSpriteDirect entry @41014"] = w1f.OFF.SPSD_entry
  cfg.exec["PlayerAuraTransformEntry @50519"] = w1f.OFF.PlayerAuraTransformEntry
  cfg.exec["GlobalInputHandler item-use JMP @229430"] = 229430
  cfg.exec["UseItem_Aura @236719"] = 236719
  cfg.exec["AttackSystemEntry @178099"] = 178099
  cfg.exec["WillAttackDispatch @178142"] = 178142
  cfg.exec["LaunchPsychoDash @178261"] = 178261
  cfg.exec["LaunchSpinDash @178273"] = 178273
  cfg.exec["FreedanAttackDispatch @178285"] = 178285
  cfg.exec["LaunchDarkFriar @178390"] = 178390
  cfg.exec["LaunchAuraBarrier @178407"] = 178407
  cfg.exec["CheckRunAttack @183186"] = 183186
  cfg.exec["RunAttackSpeedCheck @183221"] = 183221
  cfg.exec["SetActorBody @44909"] = w1f.OFF.SetActorBody
  cfg.exec["InitActorFromSceneData form @249931"] = w1f.OFF.InitActorFromSceneData_form
  cfg.exec["DecomposePlayerSprites TAX @248127"] = w1f.OFF.DecomposePlayerSprites_TAX
  cfg.exec["GetPlayerFacingDirection @258250"] = w1f.OFF.GPFD
  for k, v in pairs(w1f.batch.probes) do cfg.probes[k] = v end
  local h = w1d.start(cfg)

  local SPSD, PF15, ROWS, FAC, TBL, RES, IDX = newT(), newT(), newT(), newT(), newT(), newT(), newT()

  -- SetPlayerSpriteDirect: the operand index and where the script operand is (the 24-bit pointer [$0A] of the actor that executes the COP)
  exec(w1f.OFF.SPSD_STA_0AC8, function()
    local st = emu.getState()
    local d = st["cpu.d"] or 0
    local idx = st["cpu.a"] & 0xFF
    local ptr, bank = kit.r16(d + 0x0A), kit.r8(d + 0x0C)
    tally(SPSD, string.format("idx=%02X op=%02X:%04X D=%04X form=%d", idx, bank, ptr, d, kit.r16(0x0AD4)), { info = idx })
  end)

  -- playerFlags bit 15 transitions
  emu.addMemoryCallback(function(a, v)
    if (a & 0xFFFF) ~= 0x09AF then return end
    local old = kit.r8(0x09AF)
    if ((old ~ v) & 0x80) == 0 then return end
    local st = emu.getState()
    local what = ((v & 0x80) ~= 0) and "set" or "clear"
    tally(PF15, string.format("bit15 %s %02X:%04X ac8=%02X form=%d", what, st["cpu.k"], st["cpu.pc"], kit.r8(0x0AC8), kit.r16(0x0AD4)))
  end, emu.callbackType.write, 0x09AF, 0x09AF, emu.cpuType.snes, WR)

  -- the body_table byte offset the player is drawn with
  exec(w1f.OFF.DecomposePlayerSprites_TAX, function()
    local a = emu.getState()["cpu.a"]
    local f15 = (kit.r16(0x09AE) & 0x8000) ~= 0 and 1 or 0
    tally(ROWS, string.format("offset=%d row=%s f15=%d form=%d", a, (a % 6 == 0) and tostring(a // 6) or "?", f15, kit.r16(0x0AD4)))
  end)

  -- GetPlayerFacingDirection: caller, mode, $0AC8
  exec(w1f.OFF.GPFD, function()
    local st = emu.getState()
    local sp = st["cpu.sp"]
    local ret = kit.r16(sp + 1) + 1
    local bank = kit.r8(sp + 3)
    local f15 = (kit.r16(0x09AE) & 0x8000) ~= 0 and 1 or 0
    tally(FAC, string.format("caller=%02X:%04X f15=%d ac8=%02X", bank, ret & 0xFFFF, f15, kit.r8(0x0AC8)))
  end)
  exec(w1f.OFF.GPFD_tablePtrLoad, function()
    local st = emu.getState()
    tally(TBL, string.format("table-load ac8=%02X X=%04X", kit.r8(0x0AC8), st["cpu.x"]))
  end)
  exec(258317, function()   -- TAX after ADC $0028, Y: A = table-relative byte index, Y = the actor read for the frame
    local st = emu.getState()
    local y = st["cpu.y"]
    local extra = ""
    if kit.r8(0x0AC8) == 8 then   -- row 8: the byte read is at 84:0101 + ... = low WRAM $0100 + frame (see the report); log the stack page bytes it can hit
      extra = string.format(" wram0100=%02X%02X%02X%02X%02X%02X%02X%02X", kit.r8(0x100), kit.r8(0x101), kit.r8(0x102), kit.r8(0x103), kit.r8(0x104), kit.r8(0x105), kit.r8(0x106), kit.r8(0x107))
    end
    tally(IDX, string.format("index ac8=%02X A=%04X frame=%04X%s", kit.r8(0x0AC8), st["cpu.a"], kit.r16(y + 0x28), extra))
  end)
  exec(w1f.OFF.GPFD_resultAnd, function()
    local st = emu.getState()
    tally(RES, string.format("facing-byte ac8=%02X value=%02X (A=%04X)", kit.r8(0x0AC8), st["cpu.a"] & 0xFF, st["cpu.a"]))
  end)

  function h.rowsF()
    local r = h.rows()
    r.spsd, r.pf15, r.bodyRows, r.facing, r.facingTable, r.facingResult, r.facingIndex = dump(SPSD), dump(PF15), dump(ROWS), dump(FAC), dump(TBL), dump(RES), dump(IDX)
    return r
  end
  return h
end
