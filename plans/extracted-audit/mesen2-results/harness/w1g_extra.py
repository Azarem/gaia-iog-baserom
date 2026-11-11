"""Extra W1-g sessions: the natural triggers of the readers and writers of $24 / $26 (spawned actors), of the escort ring $7EDF00 (Lily, Kara, the Euro clerk) and of $0B02 (the
projectile / boss callers) that the shared W1-a/b session table does not reach for long enough.

Imported by w1g_session.py (it calls that module's add()). States: the preset states of FR50 (flags written in the disposable state), S01r (Will, South Cape; quick warp by writing sceneNext at
frame 2). Chains write sceneNext again at the listed frames. Buttons in ROM O (vanilla joypad remap words): physical B = attack / interact ($8000), A = $0080 (confirm / banner), Y = item ($4000).
Melee bot: walks, attacks (B), L / R. The Lua input function `g_explore` presses A and B every 15 frames for the first 700 frames (banner, dialogue), then walks in a fixed 8-direction cycle (45 frames per
direction) and presses A / B again every 90 frames (the first pass of an escort NPC needs the dialogue to finish).
"""
import w1g_session as W
from a_common import S01R

st = W.st

EXPLORE = """function g_explore(n)
  if n < 700 then
    local m = n % 15
    if m < 3 then return { a = true } end
    if m >= 7 and m < 10 then return { b = true } end
    return {}
  end
  local seg = ((n - 700) // 45) % 8 + 1
  local dirs = { { "right" }, { "down", "right" }, { "down" }, { "down", "left" }, { "left" }, { "up", "left" }, { "up" }, { "up", "right" } }
  local t = {}
  for _, b in ipairs(dirs[seg]) do t[b] = true end
  local m = n % 90
  if m < 3 then t.a = true elseif m >= 40 and m < 43 then t.b = true end
  return t
end
"""


def explore(name, state, frames, note, **kw):
    W.add(name, state, frames, note, drive="fn", lua_head=EXPLORE, input_fn="g_explore", **kw)


def chain(first, rest, each):
    """scene chain: `first` is written at frame 2 (scene=), `rest` at 2 + each * i"""
    return dict(scene=first, chain=[(2 + each * i, c) for i, c in enumerate(rest, 1)])


# ---- escort NPCs (EscortFollowPathTracker, ring $7EDF00): Lily in Itory (it1A_lily, seed 4) and in the Incan Ruins entrance (ir1C_lily, seed 3), Kara in Edward's Castle (ec0A_kara), the Euro clerk
explore("g_lily_1a", S01R, 3000, "Moon Tribe camp $1A (it1A_lily, tracker seed 4), quick warp from S01r, dialogue with A / B then an 8-direction walk", scene=0x1A)
explore("g_lily_1c", st("orig_P02_before_incan_ruins.mss"), 3000, "Incan Ruins entrance $1C (ir1C_lily, tracker seed 3), state P02, dialogue then walk")
explore("g_kara_0a", st("orig_P01_after_castle_letter.mss"), 3000, "Edward's Castle gate $0A (ec0A_kara), state P01, dialogue then walk")
explore("g_clerk_97", S01R, 3000, "Euro scene $97 (eu97_clerk2), quick warp from S01r, dialogue then walk", scene=0x97)
explore("g_babel", st("orig_P16_before_babel_tower.mss"), 6000, "Babel Tower $DE (btDE_kara_missing, tracker flags $2800), then $DF (btDF_kara) and $E3 (btE3_kara) by quick warp, dialogue then walk",
        chain=[(2000, 0xDF), (4000, 0xE3)])

# ---- smooth_follow_child callers (the speed in loopCounter, the target in $24): pyCC_blaster ($D2-$DB), awB1_wall_walker ($B1-$BE), ec0C_ribber ($0D $0E $0F $12), gw8A_sand_fanger ($8A),
#      pyDD_mummy_queen ($DD, speed 4 + $0B02), melee bot (the bot walks and attacks; HP is refilled)
W.add("g_pyCC", st("orig_P14_before_pyramid.mss"), 2 + 900 * 9, "Pyramid blaster scenes $D2 $D3 $D4 $D5 $D6 $D7 $D8 $D9 $DB (pyCC_blaster), melee bot, state P14", drive="bot",
      bot=dict(W.MELEE, seed=31), **chain(0xD2, [0xD3, 0xD4, 0xD5, 0xD6, 0xD7, 0xD8, 0xD9, 0xDB], 900))
W.add("g_awB1", st("orig_P13_before_angkor_wat.mss"), 2 + 900 * 7, "Angkor Wat scenes $B1 $B2 $B3 $B4 $B5 $B7 $B8 (awB1_wall_walker, awB1_goldcap), melee bot, state P13", drive="bot",
      bot=dict(W.MELEE, seed=32), **chain(0xB1, [0xB2, 0xB3, 0xB4, 0xB5, 0xB7, 0xB8], 900))
W.add("g_ec0C", st("orig_P01_after_castle_letter.mss"), 2 + 900 * 4, "Edward's Castle ribber scenes $0D $0E $0F $12 (ec0C_ribber), melee bot, state P01", drive="bot",
      bot=dict(W.MELEE, seed=33), **chain(0x0D, [0x0E, 0x0F, 0x12], 900))
W.add("g_gw8A", st("orig_P11_before_sand_fanger.mss"), 3600, "Sand Fanger lair $8A (gw8A_sand_fanger, speed 2), melee bot, state P11", drive="bot", bot=dict(W.MELEE, seed=34))
W.add("g_pyDD", st("orig_P15_before_mummy_queen.mss"), 4000, "Mummy Queen lair $DD (pyDD_mummy_queen, pyDD_queen_orb_shot: speed 4 + $0B02), melee bot, state P15", drive="bot", bot=dict(W.MELEE, seed=35))
W.add("g_pyDD_d1", st("orig_P15_before_mummy_queen.mss"), 2500, "Mummy Queen lair $DD with $0B02 poked to 1 in the loaded state (the speed 4 + $0B02, the orb shot ADC), melee bot", drive="bot",
      bot=dict(W.MELEE, seed=36), pokes=[(0x0B02, 1, 2)])
W.add("g_pyDD_d3", st("orig_P15_before_mummy_queen.mss"), 2500, "Mummy Queen lair $DD with $0B02 poked to 3, melee bot", drive="bot", bot=dict(W.MELEE, seed=37), pokes=[(0x0B02, 3, 2)])

# ---- other $0B02 readers: ir1F_stone_guard ($21 $22), mtA1_fire_sprite ($A1 $A5-$A8), mu5F_cyclops ($5F $60 $61 $64 $65)
W.add("g_stone_guard", st("orig_P02_before_incan_ruins.mss"), 2 + 1200 * 2, "Incan Ruins stone guards $21 and $22 (ir1F_stone_guard, ApplyPlayerHitstun with $0B02 + 2), melee bot, state P02", drive="bot",
      bot=dict(W.MELEE, seed=38), **chain(0x21, [0x22], 1200))
W.add("g_mtA1", st("orig_P12_before_mt_kress.mss"), 2 + 800 * 5, "Mt. Temple fire sprite scenes $A1 $A5 $A6 $A7 $A8 (mtA1_fire_sprite ADC $0B02), melee bot, state P12", drive="bot",
      bot=dict(W.MELEE, seed=39), **chain(0xA1, [0xA5, 0xA6, 0xA7, 0xA8], 800))
W.add("g_mu60", st("orig_P08_before_mu.mss"), 2 + 900 * 5, "Mu cyclops scenes $60 $5F $61 $64 $65 (mu5F_cyclops LDA $0B02), melee bot, state P08", drive="bot",
      bot=dict(W.MELEE, seed=40), **chain(0x60, [0x5F, 0x61, 0x64, 0x65], 900))

# ---- OQ-65, second half: the scene $FF exception of CopyActorState (the `BEQ` at ROM offset 45652 skips the clearing of extendedFlags / onHit / onDodge / onDeath callbacks while sceneCurrent = $FF).
# Counterfactual: the same inventory timeline on S01r with and without the BEQ turned into two NOPs (a ROM-image write in the emulator only: emu.write on snesPrgRom at frame 2, checked against the
# opcode $F0 first; the harness runs the patched session in its own server process so that no other session sees the patch).
BANNER = [(10, []), (3, ["a"])] * 6
FFSTEPS = BANNER + [(120, []), (6, ["select"]), (120, []), (3, ["right"]), (15, []), (3, ["down"]), (15, []), (3, ["right"]), (15, []), (3, ["a"]), (30, []), (3, ["y"]), (90, []),
                    (6, ["select"]), (120, []), (3, ["left"]), (15, []), (3, ["up"]), (15, []), (3, ["y"]), (200, [])]
W.add("g_ff_ctl", S01R, 1700, "inventory open / move / close / reopen from S01r (unpatched control for the scene $FF counterfactual)", drive="timeline", steps=FFSTEPS)
PATCH = ("if emu.read(45652, emu.memType.snesPrgRom) == 0xF0 then emu.write(45652, 0xEA, emu.memType.snesPrgRom); emu.write(45653, 0xEA, emu.memType.snesPrgRom); W1G_DBG.patched = 1 "
         "else W1G_DBG.patched = 0 end")
W.add("g_ff_patch", S01R, 1700, "the same timeline with CopyActorState's `BEQ` at 45652 (scene $FF test) replaced by two NOPs at frame 2: spawned actors lose their extendedFlags and callbacks in scene $FF",
      drive="timeline", steps=FFSTEPS, atcode=[(2, PATCH)])

# ---- second pass for the projectile / $0B02 callers: the first pass (melee bot) died or never drew fire (the preset states carry max HP 8, `$0ACA`) and the callers never ran.
# Here the player has HP 99 (pokes of `$0ACA` / `$0ACC` / `$0ACE` in the disposable state, refill every 2 frames) and the Lua tick `g_hunt` PLACES the player (actor fields $14 / $16, FORCED positioning by the
# harness, not a game action) 40 pixels east of the next live enemy (an actor with a statsPtr, not the player) every 45 frames from frame 700; the player presses A for the first 700 frames (banner) and then
# attack (B, 3 frames of every 14) and never walks, so the scene is not left; the enemy scripts then run as in play.
HUNT = """function g_hunt(n)
  if n < 700 or n % 45 ~= 0 then return end
  local pl = kit.r16(0x09AA)
  local list = {}
  for _, s in ipairs(aact.live()) do
    local sp = kit.r16(0x10020 + s)
    if s ~= pl and sp ~= 0 and sp ~= 0xAB70 and (kit.r16(0x1002A + s) & 0x80) == 0 then list[#list + 1] = s end
  end
  W1G_DBG.calls = (W1G_DBG.calls or 0) + 1
  W1G_DBG.maxEnemies = math.max(W1G_DBG.maxEnemies or 0, #list)
  if #list == 0 then return end
  local s = list[(n // 45) % #list + 1]
  W1G_DBG.lastEnt = string.format('%04X', kit.r16(s))
  kit.w16(pl + 0x14, kit.r16(s + 0x14) + 40)
  kit.w16(pl + 0x16, kit.r16(s + 0x16))
end
"""
ATK = """function g_atk(n)
  if n < 700 then
    local m = n % 15
    if m < 3 then return { a = true } end
    return {}
  end
  local m = n % 14
  if m < 3 then return { b = true } end
  return {}
end
"""
HP = [(0x0ACA, 99, 2), (0x0ACC, 99, 2), (0x0ACE, 99, 2)]


def hunt(name, state, frames, note, **kw):
    kw.pop("seed", None)
    W.add(name, state, frames, note, drive="fn", input_fn="g_atk", lua_head=HUNT + ATK, tick_fn="g_hunt", refill=2, pokes=HP + kw.pop("pokes", []), **kw)


hunt("g_h_pyCC", st("orig_P14_before_pyramid.mss"), 2 + 1000 * 9, "HUNT, HP 99: Pyramid blaster scenes $D2 $D3 $D4 $D5 $D6 $D7 $D8 $D9 $DB (pyCC_blaster), state P14", **chain(0xD2, [0xD3, 0xD4, 0xD5, 0xD6, 0xD7, 0xD8, 0xD9, 0xDB], 1000))
hunt("g_h_awB1", st("orig_P13_before_angkor_wat.mss"), 2 + 1000 * 7, "HUNT, HP 99: Angkor Wat scenes $B1 $B2 $B3 $B4 $B5 $B7 $B8 (awB1_wall_walker, awB1_goldcap), state P13", seed=42, **chain(0xB1, [0xB2, 0xB3, 0xB4, 0xB5, 0xB7, 0xB8], 1000))
hunt("g_h_ec0C", st("orig_P01_after_castle_letter.mss"), 2 + 1000 * 4, "HUNT, HP 99: Edward's Castle ribber scenes $0D $0E $0F $12 (ec0C_ribber), state P01", seed=43, **chain(0x0D, [0x0E, 0x0F, 0x12], 1000))
hunt("g_h_gw8A", st("orig_P11_before_sand_fanger.mss"), 4000, "HUNT, HP 99: Sand Fanger lair $8A (gw8A_sand_fanger), state P11", seed=44)
hunt("g_h_pyDD", st("orig_P15_before_mummy_queen.mss"), 4000, "HUNT, HP 99: Mummy Queen lair $DD (pyDD_mummy_queen, pyDD_queen_orb_shot), state P15", seed=45)
hunt("g_h_pyDD_d1", st("orig_P15_before_mummy_queen.mss"), 3000, "HUNT, HP 99, $0B02 poked to 1: Mummy Queen lair $DD", seed=46, pokes=[(0x0B02, 1, 2)])
hunt("g_h_pyDD_d3", st("orig_P15_before_mummy_queen.mss"), 3000, "HUNT, HP 99, $0B02 poked to 3: Mummy Queen lair $DD", seed=47, pokes=[(0x0B02, 3, 2)])
hunt("g_h_stone", st("orig_P02_before_incan_ruins.mss"), 2 + 1500 * 2, "HUNT, HP 99: Incan Ruins stone guards $21 and $22 (ir1F_stone_guard, $0B02 + 2 into ApplyPlayerHitstun), state P02", seed=48, **chain(0x21, [0x22], 1500))
hunt("g_h_mtA1", st("orig_P12_before_mt_kress.mss"), 2 + 900 * 5, "HUNT, HP 99: Mt. Temple fire sprite scenes $A1 $A5 $A6 $A7 $A8 (mtA1_fire_sprite ADC $0B02), state P12", seed=49, **chain(0xA1, [0xA5, 0xA6, 0xA7, 0xA8], 900))
hunt("g_h_mu", st("orig_P08_before_mu.mss"), 2 + 1000 * 5, "HUNT, HP 99: Mu cyclops scenes $60 $5F $61 $64 $65 (mu5F_cyclops LDA $0B02), state P08", seed=50, **chain(0x60, [0x5F, 0x61, 0x64, 0x65], 1000))

# ---- third pass (h2): the first hunt placed the player 40 px east of the enemy without attacking it. The second pyCC_blaster projectile (speed 3, code_0BC85D) is only fired after the blaster took a hit
# (SetHitCallback code_0BC807 switches its loop), so here the player stands 20 px east of the enemy, HOLDS LEFT (faces west) and attacks (B, 3 frames of every 14).
HUNT2 = HUNT.replace("g_hunt", "g_hunt2").replace("+ 40)", "+ 20)")
ATK2 = """function g_atk2(n)
  if n < 700 then
    if n % 15 < 3 then return { a = true } end
    return {}
  end
  if n % 14 < 3 then return { b = true, left = true } end
  return { left = true }
end
"""


def hunt2(name, state, frames, note, **kw):
    W.add(name, state, frames, note, drive="fn", input_fn="g_atk2", lua_head=HUNT2 + ATK2, tick_fn="g_hunt2", refill=2, pokes=HP + kw.pop("pokes", []), **kw)


hunt2("g_h2_pyCC", st("orig_P14_before_pyramid.mss"), 2 + 1000 * 6, "HUNT2 (20 px east, facing west, attack), HP 99: Pyramid scenes $D2 $D3 $D4 $D5 $D6 $D7 (pyCC_blaster hit -> second projectile), state P14",
      **chain(0xD2, [0xD3, 0xD4, 0xD5, 0xD6, 0xD7], 1000))
hunt2("g_h2_gw8A", st("orig_P11_before_sand_fanger.mss"), 4000, "HUNT2, HP 99: Sand Fanger lair $8A (gw8A_sand_fanger), state P11")
hunt2("g_h2_pyDD", st("orig_P15_before_mummy_queen.mss"), 4000, "HUNT2, HP 99: Mummy Queen lair $DD (pyDD_queen_orb_shot ADC $0B02), state P15")
hunt2("g_h2_stone", st("orig_P02_before_incan_ruins.mss"), 2 + 1500 * 2, "HUNT2, HP 99: Incan Ruins stone guards $21 and $22 (ir1F_stone_guard), state P02", **chain(0x21, [0x22], 1500))
hunt2("g_h2_mu", st("orig_P08_before_mu.mss"), 2 + 1000 * 5, "HUNT2, HP 99: Mu cyclops scenes $60 $5F $61 $64 $65 (mu5F_cyclops), state P08", **chain(0x60, [0x5F, 0x61, 0x64, 0x65], 1000))
