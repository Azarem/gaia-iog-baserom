"""Extra W1-f sessions: the natural triggers of the SetPlayerSpriteDirect sites that the shared W1-a/b session table does not reach.

Imported by w1f_session.py (it calls that module's add()). Every session loads the S01r state (Will, South Cape) and quick-warps by writing sceneNext at frame 2;
the form ($0AD4), the ability bitmask ($0AA2) and the equipped item slot ($0AC4) are written in the disposable loaded state (pokes), the way the diary / statues /
inventory menu would leave them; the poke values are listed in each note. Buttons in ROM O (vanilla joypad remap words; joypadHeld shows physical B as $8000): physical B = attack / interact ($8000: the COP masks are $8001 / $8000), Y = item use ($4000), A = $0080 (confirm / banner), L/R = $0020/$0010, Select = inventory $2000.
"""
import w1f_session as W
from a_common import S01R

BANNER = [(10, []), (3, ["a"])] * 6          # dismisses the scene banner ($00B4 waits for a button after a quick warp)


def tl(steps):
    return BANNER + steps


# Will, Psycho Dash / Spin Dash: WillAttackDispatch needs 40 frames of attack (B) held + a 120-frame charge before a release launches Psycho Dash (bitmask bit 0 or 2) and L/R launches Spin Dash (bit 2);
# ValidateAttackReady needs a cardinal facing, so every direction is tried (abilityBitmask $0077)
DASH = [(20, [])]
for d in ("down", "left", "right", "up"):
    DASH += [(5, [d]), (190, ["b"]), (80, [])]
DASH += [(190, ["b"]), (4, ["b", "l"]), (150, []), (190, ["b"]), (4, ["b", "r"]), (150, [])]
W.add("f_will_dash", S01R, 570 + 12 * 13 + 5200, "Diamond Mine $3F, Will, abilityBitmask $0077: hold B 190 frames per facing and release (Psycho Dash), hold then L / R (Spin Dash)", scene=0x3F, drive="timeline",
      loop=True, tlstart=570, pokes=[(0x0AA2, 0x77, 2)], steps=tl(DASH))
# Will, Psycho Slider: CheckRunAttack is called only from the four inertial states (MovingEastWest, MovingNorthSouth: D-pad released while a residual speed is left), so the sequence is run (D-pad),
# release, press B for 3 frames after a gap of 1, 3 or 6 frames, in every direction (abilityBitmask bit 1 set by $0077)
SLIDE = []
for d in ("right", "left", "down", "up"):
    for g in (1, 3, 6):
        SLIDE += [(50, [d]), (g, []), (3, ["b"]), (50, [])]
W.add("f_will_slider", S01R, 570 + 12 * 13 + 2600, "Diamond Mine $3F, Will, abilityBitmask $0077: run, release the D-pad, press B 1 / 3 / 6 frames later (Psycho Slider from the inertial states)", scene=0x3F, drive="timeline", loop=True,
      tlstart=570, pokes=[(0x0AA2, 0x77, 2)], steps=tl(SLIDE))
# Freedan, Aura Barrier: FreedanAttackDispatch needs 40 frames held + a 100-frame charge, then L or R while standing still (bitmask bit 5); release alone launches Dark Friar
W.add("f_freedan_aura", S01R, 570 + 12 * 13 + 2400, "Diamond Mine $3F, Freedan (characterForm 1), abilityBitmask $0070: hold B 160 frames, then L / R (Aura Barrier); hold B 180 and release (Dark Friar)",
      scene=0x3F, drive="timeline", loop=True, tlstart=570, pokes=[(0x0AA2, 0x70, 2), (0x0AD4, 1, 2)],
      steps=tl([(20, []), (160, ["b"]), (4, ["b", "l"]), (260, []), (160, ["b"]), (4, ["b", "r"]), (260, []), (180, ["b"]), (100, [])]))
# Freedan melee bot: the generic cover of the Freedan attacks; the drop attack (LedgeJumpDropAttack) needs a ledge jump and was not reached
W.add("f_freedan_melee", S01R, 3000, "Diamond Mine $3F, Freedan, abilityBitmask $0070, melee bot", scene=0x3F, drive="bot", bot=dict(W.MELEE, seed=77), pokes=[(0x0AA2, 0x70, 2), (0x0AD4, 1, 2)])
# Shadow, Aura item: slot 3 holds item $24 (UseItem_Aura), equipped slot $0AC4 = 3; physical Y uses the equipped item while Shadow stands still
W.add("f_shadow_aura", S01R, 2400, "Diamond Mine $3F, Shadow (characterForm 2), item $24 (Aura) in slot 3 ($0AB6 word = $2400), equipped slot $0AC4 = 3: Y while standing still (UseItem_Aura; ROM O item-use bit $4000 = physical Y)",
      scene=0x3F, drive="timeline", loop=True, tlstart=570, pokes=[(0x0AB6, 0x2400, 2), (0x0AC4, 3, 2), (0x0AD4, 2, 2)],
      steps=tl([(60, []), (3, ["y"]), (500, [])]))
# Gold Ship cutscene scenes with the body-4 hold poses (gs2D_lily, gs2E_sleep, dc2F_adrift, dc31_*), talk bot; scene $2D at frame 2, then $2E, $2F, $31
CH = [0x2E, 0x2F, 0x31]
W.add("f_goldship", S01R, 2 + 700 * 4, "quick warps: Gold Ship $2D (lily), $2E (sleep), $2F (adrift), $31 (rescuer / kara), talk bot", scene=0x2D,
      chain=[(2 + 700 * i, c) for i, c in enumerate(CH, 1)], drive="bot", bot=W.TALK)




# Dark Space ($E6) statue transformations (sE6_gaia, SetPlayerSpriteDirect #05): globalScriptIndex $0AAC = 1 selects the statue layout (DS_LayoutTransform), the Lua input function walks the
# player (tile words $09A6 / $09A8) out of the exit zone (5,D)-(B,F), to the left statue zone (3,A)-(5,B) or the right one (B,A)-(D,B), alternating every 800 frames (from frame 700; frames 500-700 press A for the banner), and presses B every 12 frames
# while he stands in a zone to advance the dialogue (the first option is the default answer).
NAV = """function f1f_nav(n)
  local xt, yt = kit.r16(0x09A6), kit.r16(0x09A8)
  local phase = math.floor(math.max(n - 700, 0) / 800) % 2
  local tx = (phase == 0) and 4 or 12
  local inz = (yt >= 10 and yt <= 11) and ((phase == 0 and xt >= 3 and xt <= 5) or (phase == 1 and xt >= 11 and xt <= 13))
  if n < 700 then if n >= 500 and n % 10 < 3 then return { a = true } end return {} end
  if inz then
    if n % 12 < 3 then return { b = true } end
    return {}
  end
  if yt >= 13 then return { up = true } end
  if yt > 12 and false then return {} end
  if xt < tx then return { right = true } end
  if xt > tx then return { left = true } end
  return { up = true }
end
"""
W.add("f_darkspace", S01R, 700 + 3200, "Dark Space $E6 with $0AAC = 1 (statue layout): the input function walks to the left / right statue zone and confirms the dialogue, alternating every 800 frames",
      scene=0xE6, drive="fn", lua_head=NAV, input_fn="f1f_nav", pokes=[(0x0AAC, 1, 2)])

# FORCED (not a natural trigger): the Transform_* library of sE6_gaia is entered by writing the routine into the player actor's entry pointer ($0000 word, $0002 bank, $0008 = 0), the same way
# UseItem_Aura / SetPlayerTransition and the statue dialogues do it. Each routine plays ~200 frames and ends in DarkSpaceRestoreControl; entry offsets are the ROM offsets of the first instruction.
TRANSFORMS = [("Transform_WillToFreedan", 586293), ("Transform_FreedanToWill", 586621), ("Transform_WillToFreedanAlt", 586350), ("Transform_FreedanToShadow", 587324),
              ("Transform_ShadowToFreedan", 586403), ("Transform_FreedanToWill", 586621), ("Transform_WillToShadow", 587257), ("Transform_ShadowToWill", 586673)]
AT = []
for k, (nm, off) in enumerate(TRANSFORMS):
    AT.append((700 + 450 * k, "local y = kit.r16(0x09AA); kit.w16(y + 2, 0x%04X); kit.w16(y + 8, 0); kit.w16(y, 0x%04X)" % (0x80 | (off >> 16), off & 0xFFFF)))
W.add("f_transform_forced", S01R, 700 + 450 * len(TRANSFORMS) + 200, "FORCED entry of the Transform_* routines (" + ", ".join("%s@%d" % t for t in TRANSFORMS) + ") in Diamond Mine $3F after the scene is up",
      scene=0x3F, drive="fn", input_fn="function() return {} end", atcode=AT)
