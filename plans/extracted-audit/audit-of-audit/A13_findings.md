# A13 findings: generic-label backlog triage for the audited ranges

Step: A13 of the audit of the audit. Inputs: `PLAN.md`, `report.md` §8.4 and §8.2, `gaia-core/docs/notes-and-comments.md` §"Names Merge", the checklist of I001..I072, and the live files under `extracted/`.
Nothing was edited except this file and the A13 row of `PLAN.md`. The names spec file is **not** written (the step says so). `npm run extract:lt` was not run: `extracted/` already carries `; {n}` tags on the instruction lines (checked on every file listed below).

**Evidence level.** Every behavioural statement is static (E1 code trace or E2 cross-reference). There is no Mesen2 ROM or save state, so nothing is E5.
**Tags.** VERIFIED = checked in the live files this session, with file:line. REPORTED = taken from a ledger, from a note, or from an earlier count in this same task that was not re-run now.
**Row basis codes** used in the NAME NOW tables: `T` = I traced the code against the note this session (E1); `N` = a part note sits directly on the label and I read it, but did not trace the code; `I` = an inline comment or block note names the role; `S` = structural (the label is the first line after the `actor-def` / `thinker-def` header, so it is the actor entry point).
**Working tree.** `git status --short extracted` lists 818 modified files (not by this step). Line numbers are those of the current checkout.

---

## 1. Scope and files read

### 1.1 Directories and the rg patterns

Audited directories: `extracted/system`, `extracted/tables`, `extracted/functions`, `extracted/thinkers`, `extracted/actors`. Every file with a generic label in these directories is an I001..I072 file (checked against the checklist; renamed files were mapped through the apply summaries).

Generic-label pattern (definition lines only):

```
^\s*(loc|code|sub|data|table|func|label|binary|sprite_set)_[0-9A-Fa-f]{4,6}\b
```

Supplementary families that the nine prefixes do not cover were counted with their own patterns (§5.3). Commands used: `rg --count`, `rg --stats` (for the directory totals), `rg -U -o -r` (to pair each label with the `; {n}` tag of its first instruction), `rg -B/-A` (notes and context). No script, no `sort`/`uniq`.

### 1.2 Files read (code and notes)

| File | What was read |
|---|---|
| `actors/hit_stagger_controller.asm` | lines 56–430, the whole routine set (all 29 labels traced) |
| `system/inventory/inventory_mgmt.asm` | lines 48–310, whole file (all 19 labels traced) |
| `functions/EnemyDropSystem.asm` | lines 91–133 |
| `functions/camera_drift.asm` | lines 100–185 (labels 53270, 53292, 53316, 53338, 53339, 53350) |
| `system/dark_space/sE6_gaia.asm` | notes above all 50 labels; code of `loc_08D9D5`, `loc_08D9E7`, `loc_08DB37`, `loc_08EA9B`, `loc_08EB33..57`, `loc_09A09E..0CC` (lines 2100–2166), table block 1380–1420 |
| `system/diary_menu/sFA_diary_menu.asm` | notes above all 84 labels; code of `loc_0BE960..972`, `loc_0BEDA3..1E`, `loc_0BF1F8`, `loc_0BF222`, `loc_0BF245` |
| `system/diary_menu/diary_menu_window_dma.asm` | notes above all 15 labels |
| `system/player/player_move_main.asm` | notes above the 10 labels |
| `system/engine/scene_script.asm` | 170–210, the `SceneCmd_LoadCharTiles` part (1400–1480) |
| `system/engine/combat_collision.asm` | 735–775 |
| `actors/player/slope_ramp_physics.asm` | 560–650 |
| `system/functions/vram_buffer_clear.asm` | whole file |
| `functions/ApplyOrbitalOffsetFromRef.asm`, `ApplyPlayerHitstun.asm`, `EnemyDefeatDispatch.asm`, `actors/camera_scroll_controller.asm`, `actors/layer1_scroll_actors.asm`, `thinkers/flag_gated_palette_*.asm`, `actors/jeweler_gem.asm`, `actors/hidden_red_jewel.asm` | notes above every generic label |
| `tables/inventory_spritemap.asm`, `tables/spriteset_will_abilities.asm` | the `; Animation $nn` notes and the label under each |
| 22 entry-stub files | header, label and first instruction (see E table) |
| `db-us/transforms.json` | generic keys (§2, A13-06) |
| `baserom/` patches and `IOGRetranslation/modules` patches | every use of a NAME NOW label as reference or `!` override (§2, A13-04) |

### 1.3 Ledgers read

`PLAN.md` (defect classes, A13 prompt, F06), `report.md`, `A07_findings.md` (format), `plans/extracted-audit/renames/B001_renames.md` (R-B001-1/-2, the spm sprite proposals), `gaia-core/docs/notes-and-comments.md` §"Names Merge" (spec shape and rules).

---

## 2. Findings

| id | tag | file:line | what is wrong | proposed fix | class |
|---|---|---|---|---|---|
| A13-01 | VERIFIED | all rows in §3 | 262 generic labels in the audited files have a purpose proven by a note and, for 86 of them, by a code trace this session. They still print as `loc_` / `code_` / `table_` / `sprite_set_`. No proposed new name collides with anything (§3.9). | F06 step (1): write `apply-F06_names.json` from §3, dry-run, wait for approval, apply in the groups of §4. | AP-13 backlog (no defect class) |
| A13-02 | VERIFIED | `extracted/system/diary_menu/sFA_diary_menu.asm:38` (block note), `sE6_gaia.asm:494,502,538,553,1501`, `player_move_main.asm` part `DiagSnapCompute_Unused`, `unused_particle_rain_spawner.asm` | 39 generic labels sit in code that nothing in the ROM calls (§3.11). Naming them has no value; deleting or renaming them blindly is wrong because patches touch parts of that code. | Keep generic. Record the DEAD list (§3.11) so F06 and later passes skip them. | AP-13 backlog |
| A13-03 | VERIFIED | `baserom/patches/APUWaitFixes.patch.asm:432,442` | The DEAD label `loc_08EFAD` (`Unreferenced pickup`, `sE6_gaia.asm:1501`) is referenced twice by a patch: `AuraItemGrant!` (patch line 392) is overridden and branches to it. "Dead" holds for the vanilla ROM only; the built ROM has a caller. | Mark `loc_08EFAD` DEAD-IN-VANILLA, PATCHED. Do not delete. Leave generic. | 3 |
| A13-04 | VERIFIED | `baserom/options-menu/OptionsMenu.patch.asm:203-204`; `baserom/inventory/InventoryManagement.patch.asm:242,243,249,284`; `baserom/new-game-plus/NewGamePlus.patch.asm:284,363,372`; `baserom/patches/APUWaitFixes.patch.asm:292,332`; `IOGRetranslation/modules/base/patches/OptionsNames.patch.asm:54` | 12 NAME NOW labels are `!` overrides in patches (`loc_0BE695!:`, `loc_0BE6B3!`, `loc_0BE433!`, `loc_03EFA2!:`, `loc_03EFAA!:`, `loc_03F0B9!`, `loc_03F0A0!`, `loc_0BEDA3!:`, `loc_0BEE11!`, `loc_00BC45!`, `loc_08DCAF!`, `loc_08EAAA!`). The names tool rewrites raw whole words in `baserom/` and in the modules (not with `--local-only`), so the overrides are renamed with the label. Sub-label overrides (`!:`) must stay in step with the parent override. | In F06 apply these rows as one group and run `npm run rebuild` after it. Do not use `--local-only` for this group: the module `OptionsNames.patch.asm` and `SwitchNameDictionary.patch.asm` (base and ichagas) reference `loc_0BE433` / `loc_0BE695` and live outside this repo. | AP-13, label-override hazard |
| A13-05 | VERIFIED | `db-us/transforms.json:117-119,487,530-533` | `transforms.json` keys contain generic labels: `sub_0B9CE8`, `loc_0B9CF9`, `loc_0B9D0E` (117–119, a block outside the audited ranges), `code_02B7BD` inside the alternation of line 487, and `loc_0386EA`, `loc_038800`, `loc_0386FA`, `loc_03880D` (530–533, `item_use_system`). The multi-line regexes at 532–533 need the `CMP` and the `BNE loc_…` adjacent. None of these labels is in NAME NOW, so no row touches them. | Leave them generic. If a later pass names one of them, the names tool rewrites the key (it scans `db-us/*.json`); re-run `npm run extract:lt` and check the line still matches. No note may be put between `CMP` and `BNE` there. | 12 |
| A13-06 | VERIFIED | `extracted/system|tables|functions|thinkers|actors`: 216 lines in 93 files | Comments and notes in the audited directories still carry `OQ-I…` / `R-I…` ids. Examples read this session: `system/inventory/inventory_mgmt.asm:151` (`… other values are unbounded, OQ-I050-1)`), `functions/camera_drift.asm:116` (`(OQ-I050-4)`), `actors/player/player_character.asm:7,79,91,127` (`OQ-I025-1`, `OQ-I025-2`). Several are the only trace of an open question, and several sit on lines where this triage proposes a name. | Not an A13 fix. Hand to the OQ pass (A12) and to a note-merge step. A13 rows do not depend on it. | 7 |
| A13-07 | VERIFIED | `extracted/actors/player/slope_ramp_physics.asm:633-634` | The inline comment on `loc_02B76C` ends "probably a copy slip". The code at `slope_ramp_physics.asm:630-634` clears `slopeStepCounter` (the EW twin clears `decelStepCounter`), so the name below states the fact and not the guess. The hedge is a purpose guess without a trace. | NAME NOW row S006 uses the factual name. A later note merge should drop "probably a copy slip" or move it to an OQ. | 1 |
| A13-08 | VERIFIED | `baserom/new-game-plus/NewGamePlus.patch.asm:53` (`;BCS code_0BE433`), `baserom/inventory/InventoryManagement.patch.asm:259` (`;BEQ code_03F0C7`), `IOGRetranslation/modules/base/patches/SwitchNameDictionary.patch.asm:196` (`;BNE code_0BE68C`) | Three commented-out lines use the `code_` prefix, but the extracted labels are `loc_0BE433`, `loc_03F0C7`, `loc_0BE68C`. After the rename the names tool will not touch them (different word). They are comments, so the build is not affected, but they point at nothing. | Report only. Fix in the owner's next patch edit (these are not notes or names the tools manage). | 3 |
| A13-09 | VERIFIED | `gaia-core/docs/patch-development.md` (two `loc_0BE695` mentions), `gaia-core/docs/rom-mapping-guide.md` and `gaia-knowledge/curated/gaialabs/rom-mapping-guide.md` (`table_08EB8F`), `gaia-core/docs/notes-and-comments.md` (`sprite_set_0F8076`), `docs/code/bank08-native-dao-pyramid-actors.md` (`loc_08DB9A`, `table_08EB8F`, `table_08EBD3`), `docs/code/bank02/scene-script.md` (`code_0283C1`, `code_0283ED`, `code_028CB0`), `baserom/fixes-tweaks/HudRedesign.patch.asm` (`loc_02F07E`) | Docs and a patch quote NAME NOW labels. The names tool rewrites `docs/`, `gaia-core/docs/` and the modules, but **not** `gaia-knowledge/curated/`. | In F06, after the apply, `rg` the old names in `gaia-knowledge/curated/` and fix by hand; tell the user. | 3 |
| A13-10 | VERIFIED | `extracted/` (whole tree) | The spm sprite-map labels (`spm_<map>_sprite_set_000004` …) carry an offset suffix inside the file, not a ROM address. 4616 definition lines in 44 files. R-B001-1 and R-B001-2 propose names, but the names key (`address`) for them is not documented in `notes-and-comments.md` §"Names Merge". | **Blocked.** No spec rows for spm labels. Ask the user how the names tool should key them (see §3.10 and §4). | tool question |
| A13-11 | VERIFIED | `extracted/` (whole tree) | `dialogstring_XXXXXX` has 1847 definition lines in 394 files, referenced 2644 times in 92 module files and 55 times in 23 baserom patches (counts REPORTED from the first pass of this step; the 1847/394 pair was re-run: VERIFIED). Each is an address-identity label for translators. | LEAVE GENERIC by policy. | policy |
| A13-12 | VERIFIED | `extracted/` whole tree | The step prompt's count of generic labels (745 files, `report.md` §8.4) is out of date: `rg --stats` now gives 8256 definition lines in 750 files for the nine prefixes with `\b`. | Quote 750 / 8256 in later steps. | 3 |

Not findings but worth a line: the window-DMA notes call the bands `diary_band_slot1..3` for cursor values 0, 1 and 2 (`diary_menu_window_dma.asm`, notes above `loc_00BBCF`, `loc_00BBD9`, `loc_00BBE4`). The proposed names use the cursor value (`…Cursor0`, `…Cursor1`, `…Cursor2Plus`) so the one-off shift does not enter the label.

---

## 3. The three lists

### 3.1 Rules used

- **NAME NOW** needs one of: a part note on the label (E1/E2, 234 labels), an inline comment or block note that names the role (6 labels: S001, S002, S004, S005, S006 and G040), or a structural entry stub (22 labels). Count: **262**. A first-instruction comment alone does not qualify (it describes the instruction, class 1 risk). About 788 labels have only such a comment; they stay generic (tier 2, REPORTED from the first pass, not re-run).
- **LEAVE GENERIC** = every other generic definition.
- **DEAD** needs a note, a part name (`…_noref`, `…_Unused`), a file name, or a doc statement that nothing calls the code.
- Spec shape: `{ "address": <integer ; {n} tag of the first instruction>, "old": "<label now>", "new": "<name>", "row": "<id>" }`. The `address` below is the tag number from the extract:lt asm. For the two data-part groups (G044, G045 and T001..T009) there are no instructions; the address is the integer of the 6-digit hex suffix, as `notes-and-comments.md` §"Names Merge" documents (REPORTED from the doc, not run).
- Naming style: `Parent_Sub` where the parent is a PascalCase routine (the file already uses it: `GiveItem_StoreInSlot`, `AutoAlignEW_North`), otherwise a PascalCase compound.

### 3.2 NAME NOW: functions, actors with notes (F, 81 rows)

| row | address | old | new | basis |
|---|---|---|---|---|
| A13-F001 | 62439 | loc_00F3E7 | ApplyOrbitalOffsetRefX | N |
| A13-F002 | 62460 | loc_00F3FC | ApplyOrbitalOffsetRefAddX | N |
| A13-F003 | 62477 | loc_00F40D | ApplyOrbitalOffsetRefY | N |
| A13-F004 | 62498 | loc_00F422 | ApplyOrbitalOffsetRefAddY | N |
| A13-F005 | 60160 | loc_00EB00 | CameraTrackRefreshPlayerPos | N |
| A13-F006 | 60237 | loc_00EB4D | CameraTargetXLeftLimit | N |
| A13-F007 | 60242 | loc_00EB52 | CameraTargetXRightEdge | N |
| A13-F008 | 60246 | loc_00EB56 | CameraTargetXStore | N |
| A13-F009 | 60281 | loc_00EB79 | CameraTargetYTopLimit | N |
| A13-F010 | 60286 | loc_00EB7E | CameraTargetYBottomEdge | N |
| A13-F011 | 60290 | loc_00EB82 | CameraTargetYStore | N |
| A13-F012 | 60293 | loc_00EB85 | CameraDeltaStep | N |
| A13-F013 | 53270 | loc_00D016 | CameraDriftYDeltaStep | T |
| A13-F014 | 53292 | loc_00D02C | CameraDriftYDeltaSkip | T |
| A13-F015 | 53293 | loc_00D02D | CameraDriftXAxis | N |
| A13-F016 | 53316 | loc_00D044 | CameraDriftXDeltaStep | N |
| A13-F017 | 53338 | loc_00D05A | CameraDriftXDeltaSkip | N |
| A13-F018 | 53339 | loc_00D05B | CameraDriftRunEnd | T |
| A13-F019 | 53350 | loc_00D066 | CameraDriftDie | T |
| A13-F020 | 697528 | loc_0AA4B8 | DefeatFieldRevealBookkeeping | N |
| A13-F021 | 697568 | loc_0AA4E0 | DefeatFieldRevealReturn | N |
| A13-F022 | 57241 | loc_00DF99 | DropGroupHalfHpTest | T |
| A13-F023 | 57255 | loc_00DFA7 | DropGroupZero | T |
| A13-F024 | 57258 | loc_00DFAA | DropRollStart | T |
| A13-F025 | 57268 | loc_00DFB4 | DropRollScanLoop | T |
| A13-F026 | 57281 | loc_00DFC1 | DropDispatchChosenRow | T |
| A13-F027 | 46542 | loc_00B5CE | FlagGatedPaletteWarmLoop | N |
| A13-F028 | 46573 | loc_00B5ED | FlagGatedPaletteCoolLoop | N |
| A13-F029 | 50090 | loc_00C3AA | HitstunApplyDamage | N |
| A13-F030 | 50104 | loc_00C3B8 | HitstunReactionIframes | N |
| A13-F031 | 50125 | loc_00C3CD | HitstunSpawnStagger | N |
| A13-F032 | 50157 | loc_00C3ED | HitstunConfigureStagger | N |
| A13-F033 | 50186 | loc_00C40A | HitstunSoundReturn | N |
| A13-F034 | 50192 | loc_00C410 | HitstunScriptLocked | N |
| A13-F035 | 55429 | loc_00D885 | HitStaggerRequestMovement | T |
| A13-F036 | 55494 | loc_00D8C6 | HitStaggerNoKnockbackWait | T |
| A13-F037 | 55507 | loc_00D8D3 | HitStaggerEnemyNoKnockbackResolve | T |
| A13-F038 | 55510 | loc_00D8D6 | HitStaggerDirSouth | T |
| A13-F039 | 55520 | loc_00D8E0 | HitStaggerDirNorth | T |
| A13-F040 | 55533 | loc_00D8ED | HitStaggerDirWest | T |
| A13-F041 | 55546 | loc_00D8FA | HitStaggerDirEast | T |
| A13-F042 | 55585 | loc_00D921 | HitStaggerEnemyDistanceCheck | T |
| A13-F043 | 55611 | loc_00D93B | HitStaggerVerticalMultipleCheck | T |
| A13-F044 | 55621 | loc_00D945 | HitStaggerVerticalCutShort | T |
| A13-F045 | 55631 | loc_00D94F | HitStaggerVerticalClearChain | T |
| A13-F046 | 55643 | loc_00D95B | HitStaggerHorizontalDistance | T |
| A13-F047 | 55658 | loc_00D96A | HitStaggerHorizontalMultipleCheck | T |
| A13-F048 | 55668 | loc_00D974 | HitStaggerHorizontalCutShort | T |
| A13-F049 | 55678 | loc_00D97E | HitStaggerHorizontalClearChain | T |
| A13-F050 | 55690 | loc_00D98A | HitStaggerHpCheck | T |
| A13-F051 | 55740 | loc_00D9BC | HitStaggerStandardDefeat | T |
| A13-F052 | 55760 | loc_00D9D0 | HitStaggerSurvives | T |
| A13-F053 | 55776 | loc_00D9E0 | HitStaggerRecoveryIframes | T |
| A13-F054 | 55783 | loc_00D9E7 | HitStaggerRemoveChild | T |
| A13-F055 | 55811 | loc_00DA03 | HitStaggerPlayerIframes | T |
| A13-F056 | 55846 | loc_00DA26 | HitStaggerThresholdTier1 | T |
| A13-F057 | 55856 | loc_00DA30 | HitStaggerThresholdTier2 | T |
| A13-F058 | 55866 | loc_00DA3A | HitStaggerThresholdTier3Plus | T |
| A13-F059 | 55877 | loc_00DA45 | HitStaggerNotEqualSetCarry | T |
| A13-F060 | 55892 | loc_00DA54 | HitStaggerOffsetTier1 | T |
| A13-F061 | 55899 | loc_00DA5B | HitStaggerOffsetTier2 | T |
| A13-F062 | 55906 | loc_00DA62 | HitStaggerOffsetTier3Plus | T |
| A13-F063 | 55923 | loc_00DA73 | HitStaggerStoreYChain | T |
| A13-F064 | 50802 | code_00C672 | HiddenRedJewelEntry | N (note: "Actor entry (after the 3-byte header)") |
| A13-F065 | 577238 | code_08CED6 | JewelerRewardTierCascade | N |
| A13-F066 | 59610 | code_00E8DA | Layer1DriftUnboundedInit | N |
| A13-F067 | 59633 | loc_00E8F1 | Layer1DriftUnboundedDecodeY | N |
| A13-F068 | 59654 | loc_00E906 | Layer1DriftUnboundedStoreVelY | N |
| A13-F069 | 59815 | loc_00E9A7 | Layer1ParallaxRatioXSignExtend | N |
| A13-F070 | 59826 | loc_00E9B2 | Layer1ParallaxRatioXAddOverride | N |
| A13-F071 | 59834 | loc_00E9BA | Layer1ParallaxRatioXHighZero | N |
| A13-F072 | 59842 | loc_00E9C2 | Layer1ParallaxRatioXHighZeroAddOverride | N |
| A13-F073 | 59868 | loc_00E9DC | Layer1ParallaxRatioYHighZero | N |
| A13-F074 | 59876 | loc_00E9E4 | Layer1ParallaxRatioYAddDelta | N |
| A13-F075 | 59887 | code_00E9EF | Layer1DriftWrappedInit | N |
| A13-F076 | 59910 | loc_00EA06 | Layer1DriftWrappedDecodeY | N |
| A13-F077 | 59931 | loc_00EA1B | Layer1DriftWrappedStoreVelY | N |
| A13-F078 | 59971 | loc_00EA43 | Layer1DriftWrappedXPositive | N |
| A13-F079 | 59987 | loc_00EA53 | Layer1DriftWrappedYStep | N |
| A13-F080 | 60017 | loc_00EA71 | Layer1DriftWrappedYPositive | N |
| A13-F081 | 60033 | loc_00EA81 | Layer1DriftWrappedRenderDeltas | N |

Hit-stagger trace summary (VERIFIED, `extracted/actors/hit_stagger_controller.asm`): the direction decode at lines 85–92 is `DEC` / `BMI` (0 south → `loc_00D8D6`, 1 north → `loc_00D8E0`, 2 west → `loc_00D8ED`, else east → `loc_00D8FA`); north and west call `ForceDirBoth` and differ by `SEC` (vertical chain) versus `CLC` (horizontal chain) at lines 122–142; the threshold chain at 335–360 gives tier 0 `$30`, tier 1 `$20`, tier 2 and above `$40`; the offset chain at 386–409 gives `$44` for tier 0 and `$46` for the rest. The notes match the code on all of these.

### 3.3 NAME NOW: diary window DMA (W, 15 rows)

| row | address | old | new | basis |
|---|---|---|---|---|
| A13-W001 | 48049 | code_00BBB1 | DiaryBandSlotCursorGate | N |
| A13-W002 | 48060 | loc_00BBBC | DiaryBandSlotDispatch | N |
| A13-W003 | 48071 | loc_00BBC7 | DiaryBandSlotQueueEmpty | N |
| A13-W004 | 48079 | loc_00BBCF | DiaryBandSlotCursor0 | N |
| A13-W005 | 48089 | loc_00BBD9 | DiaryBandSlotCursor1 | N |
| A13-W006 | 48100 | loc_00BBE4 | DiaryBandSlotCursor2Plus | N |
| A13-W007 | 48108 | loc_00BBEC | DiaryBandTargetDispatch | N |
| A13-W008 | 48127 | loc_00BBFF | DiaryBandTargetCursor0 | N |
| A13-W009 | 48137 | loc_00BC09 | DiaryBandTargetCursor1 | N |
| A13-W010 | 48148 | loc_00BC14 | DiaryBandTargetCursor2Plus | N |
| A13-W011 | 48156 | loc_00BC1C | DiaryBandTabDispatch | N |
| A13-W012 | 48168 | loc_00BC28 | DiaryBandTab0Queue | N |
| A13-W013 | 48177 | loc_00BC31 | DiaryBandTab1Queue | N |
| A13-W014 | 48187 | loc_00BC3B | DiaryBandTab2Queue | N |
| A13-W015 | 48197 | loc_00BC45 | DiaryBandTab3PlusQueue | N |

`loc_00BC45` is also a `!` override in `NewGamePlus.patch.asm:372` (A13-04).

### 3.4 NAME NOW: diary menu `sFA_diary_menu.asm` (D, 59 rows)

| row | address | old | new | basis |
|---|---|---|---|---|
| A13-D001 | 778954 | loc_0BE2CA | DiaryMenuSceneReadyJoin | N |
| A13-D002 | 778960 | loc_0BE2D0 | DiaryTabSelectResetCursors | N |
| A13-D003 | 779010 | loc_0BE302 | DiaryTabCursorUpStore | N |
| A13-D004 | 779038 | loc_0BE31E | DiaryTabCursorDownStore | N |
| A13-D005 | 779172 | loc_0BE3A4 | DiaryStartSlotUpStore | N |
| A13-D006 | 779200 | loc_0BE3C0 | DiaryStartSlotDownStore | N |
| A13-D007 | 779315 | loc_0BE433 | DiaryStartPresentSoundButtonConfig | N |
| A13-D008 | 779461 | loc_0BE4C5 | DiarySettingsToggleButtonType | N |
| A13-D009 | 779495 | loc_0BE4E7 | DiarySettingsRow0StartGame | N |
| A13-D010 | 779581 | loc_0BE53D | DiaryCameraPanScanName | N |
| A13-D011 | 779630 | loc_0BE56E | DiaryCameraPanDxNegative | N |
| A13-D012 | 779645 | loc_0BE57D | DiaryCameraPanDySign | N |
| A13-D013 | 779664 | loc_0BE590 | DiaryCameraPanDyStorePositive | N |
| A13-D014 | 779670 | loc_0BE596 | DiaryCameraPanDyNegative | N |
| A13-D015 | 779683 | loc_0BE5A3 | DiaryCameraPanDyStoreSign | N |
| A13-D016 | 779687 | loc_0BE5A7 | DiaryCameraPanMajorAxis | N |
| A13-D017 | 779729 | loc_0BE5D1 | DiaryCameraPanXMajorLoop | N |
| A13-D018 | 779775 | loc_0BE5FF | DiaryCameraPanXMajorCount | N |
| A13-D019 | 779792 | loc_0BE610 | DiaryCameraPanXMajorDone | N |
| A13-D020 | 779794 | loc_0BE612 | DiaryCameraPanYMajorSetup | N |
| A13-D021 | 779826 | loc_0BE632 | DiaryCameraPanYMajorLoop | N |
| A13-D022 | 779872 | loc_0BE660 | DiaryCameraPanYMajorCount | N |
| A13-D023 | 779889 | loc_0BE671 | DiaryCameraPanYMajorDone | N |
| A13-D024 | 779916 | loc_0BE68C | ApplySoundAndRemap_Mono | N |
| A13-D025 | 779925 | loc_0BE695 | ApplySoundAndRemap_ButtonTypeSelect | N |
| A13-D026 | 779955 | loc_0BE6B3 | ApplySoundAndRemap_ButtonType2 | N |
| A13-D027 | 780052 | loc_0BE714 | DiarySndBtnSlotConfirmUsed | N |
| A13-D028 | 780144 | loc_0BE770 | DiarySettingsUpStore | N |
| A13-D029 | 780172 | loc_0BE78C | DiarySettingsDownStore | N |
| A13-D030 | 780236 | loc_0BE7CC | DiarySndBtnToggleButtonType | N |
| A13-D031 | 780270 | loc_0BE7EE | DiarySndBtnRow0SaveChanges | N |
| A13-D032 | 780380 | loc_0BE85C | ReadSramSettings_StoreSound | N |
| A13-D033 | 780406 | loc_0BE876 | ReadSramSettings_StoreButtonType | N |
| A13-D034 | 780500 | loc_0BE8D4 | DiaryCopyTabStartFlow | N |
| A13-D035 | 780561 | loc_0BE911 | DiaryCopySourceUpStore | N |
| A13-D036 | 780589 | loc_0BE92D | DiaryCopySourceDownStore | N |
| A13-D037 | 780640 | loc_0BE960 | DiaryCopySourceUsed | T |
| A13-D038 | 780643 | loc_0BE963 | DiaryCopyEmptySearchLoop | T |
| A13-D039 | 780658 | loc_0BE972 | DiaryCopyEmptyFound | T |
| A13-D040 | 780696 | loc_0BE998 | DiaryCopyTargetUpStep | N |
| A13-D041 | 780702 | loc_0BE99E | DiaryCopyTargetUpStore | N |
| A13-D042 | 780733 | loc_0BE9BD | DiaryCopyTargetDownStep | N |
| A13-D043 | 780742 | loc_0BE9C6 | DiaryCopyTargetDownStore | N |
| A13-D044 | 780804 | loc_0BEA04 | DiaryCopyExecuteTargetEmpty | N |
| A13-D045 | 780946 | loc_0BEA92 | DiaryEraseSlotUpStore | N |
| A13-D046 | 780974 | loc_0BEAAE | DiaryEraseSlotDownStore | N |
| A13-D047 | 781040 | loc_0BEAF0 | DiaryEraseSlotConfirmUsed | N |
| A13-D048 | 781231 | loc_0BEBAF | DiaryRenderSlotStatsSlot2 | N |
| A13-D049 | 781267 | loc_0BEBD3 | DiaryRenderSlotStatsSlot3 | N |
| A13-D050 | 781303 | loc_0BEBF7 | DiaryRenderSlotStatsDone | N |
| A13-D051 | 781731 | loc_0BEDA3 | DiaryScanSramSlots_StoreLastUsed | T |
| A13-D052 | 781841 | loc_0BEE11 | DiaryScanSramSlots_ChecksumMismatch | T |
| A13-D053 | 781842 | loc_0BEE12 | DiaryScanSramSlots_NextSlot | T |
| A13-D054 | 781854 | loc_0BEE1E | DiaryScanSramSlots_Done | T |
| A13-D055 | 782840 | loc_0BF1F8 | FormatBcdNumber_HundredsLoop | T |
| A13-D056 | 782854 | loc_0BF206 | FormatBcdNumber_HundredsToHigh | N |
| A13-D057 | 782882 | loc_0BF222 | FormatBcdNumber_TensLoop | T |
| A13-D058 | 782894 | loc_0BF22E | FormatBcdNumber_Pack | N |
| A13-D059 | 782917 | loc_0BF245 | FormatBcdNumber_Overflow | T |

Parent routines that the `Parent_` prefixes refer to were found in `sFA_diary_menu.asm`: `ApplySoundAndRemap` (line 679), `ReadSramSettings` (932), `DiaryScanSramSlots` (1805), `FormatBcdNumber` (1986).
Overrides in patches: D007 (`OptionsNames.patch.asm:54`), D025/D026 (`OptionsMenu.patch.asm:203-204`), D051 (`NewGamePlus.patch.asm:284`), D052 (`NewGamePlus.patch.asm:363`). Plain references: `NewGamePlus.patch.asm` branches to `loc_0BE2CA` (line 169), `loc_0BE302` (181, 183, 189), `loc_0BE2D0` (199), `loc_0BE31E` (214, 216, 223), `loc_0BEDA3` (280) and `loc_0BEE12` (303).

### 3.5 NAME NOW: Gaia / Dark Space `sE6_gaia.asm` (G, 45 rows)

| row | address | old | new | basis |
|---|---|---|---|---|
| A13-G001 | 579539 | loc_08D7D3 | DarkSpaceStoreVariant | N |
| A13-G002 | 579683 | loc_08D863 | DS_BasicActive | N |
| A13-G003 | 579781 | loc_08D8C5 | DS_WillActive | N |
| A13-G004 | 579889 | loc_08D931 | DS_FreedanActive | N |
| A13-G005 | 579962 | loc_08D97A | DS_ShadowWait | N |
| A13-G006 | 579991 | loc_08D997 | DS_ShadowActive | N |
| A13-G007 | 580053 | loc_08D9D5 | DS_AbilityTableSearchLoop | T |
| A13-G008 | 580071 | loc_08D9E7 | DS_AbilityTableSceneFound | T |
| A13-G009 | 580124 | loc_08DA1C | DS_AbilityFreedanOrb | N |
| A13-G010 | 580164 | loc_08DA44 | DS_AbilityNoOrb | N |
| A13-G011 | 580165 | loc_08DA45 | DS_AbilityWait | N |
| A13-G012 | 580178 | loc_08DA52 | DS_AbilityActive | N |
| A13-G013 | 580407 | loc_08DB37 | GaiaHintSearchStart | T |
| A13-G014 | 580411 | loc_08DB3B | GaiaHintSearchLoop | T |
| A13-G015 | 580428 | loc_08DB4C | GaiaHintSceneFound | N |
| A13-G016 | 580506 | loc_08DB9A | GaiaHintNotFoundSave | N |
| A13-G017 | 580783 | loc_08DCAF | GaiaAuraGiftSequence | N |
| A13-G018 | 580831 | loc_08DCDF | GaiaAuraFanfareDone | N |
| A13-G019 | 584155 | loc_08E9DB | AbilityOrbSearchLoop | N |
| A13-G020 | 584174 | loc_08E9EE | AbilityOrbNotFoundDie | N |
| A13-G021 | 584177 | loc_08E9F1 | AbilityOrbSceneFound | N |
| A13-G022 | 584248 | loc_08EA38 | AbilityTransformShadowToFreedan | N |
| A13-G023 | 584280 | loc_08EA58 | AbilityTransformWillToFreedan | N |
| A13-G024 | 584312 | loc_08EA78 | AbilityTransformToWill | N |
| A13-G025 | 584347 | loc_08EA9B | AbilityTransformWait | T |
| A13-G026 | 584362 | loc_08EAAA | AbilityGrantSequence | N |
| A13-G027 | 584461 | loc_08EB0D | AbilityGrantFanfareDone | N |
| A13-G028 | 584499 | loc_08EB33 | LookupAbilityForm_SearchLoop | T |
| A13-G029 | 584517 | loc_08EB45 | LookupAbilityForm_SceneFound | T |
| A13-G030 | 584531 | loc_08EB53 | LookupAbilityForm_HighNibble | T |
| A13-G031 | 584535 | loc_08EB57 | LookupAbilityForm_NotFound | T |
| A13-G032 | 585930 | loc_08F0CA | FreedanTransformReturnToLoop | N |
| A13-G033 | 585989 | loc_08F105 | FreedanTransformShadowBranch | N |
| A13-G034 | 586470 | loc_08F2E6 | WillRevertNotWillPrompt | N |
| A13-G035 | 586545 | loc_08F331 | WillRevertShadowBranch | N |
| A13-G036 | 586806 | loc_08F436 | ShadowTransformWriteWillToShadow | N |
| A13-G037 | 586838 | loc_08F456 | ShadowTransformWriteFreedanToShadow | N |
| A13-G038 | 587460 | loc_08F6C4 | FireflyParticleFrameLoop | N (parent `FireflyParticle`, line 2049) |
| A13-G039 | 630942 | loc_09A09E | GaiaVoiceSparkleTestLoop | T |
| A13-G040 | 630949 | loc_09A0A5 | GaiaVoiceSparkleSfxCheck | T, I (block note and inline comment "SFX queued on channel 1"; no part note) |
| A13-G041 | 630955 | loc_09A0AB | GaiaVoiceSparkleChoose | T |
| A13-G042 | 630977 | loc_09A0C1 | GaiaVoiceSparkleVariant2 | T |
| A13-G043 | 630988 | loc_09A0CC | GaiaVoiceSparkleVariant3 | T |
| A13-G044 | 584591 | table_08EB8F | AbilityNameTable | N (data; hex suffix 08EB8F; note above the table: "Ability names by ability index") |
| A13-G045 | 584659 | table_08EBD3 | AbilityDescriptionTable | N (data; hex suffix 08EBD3; note above `dialogstring_08EB85`: "Description of the ability (table_08EBD3 by $0AAC …)") |

Trace result (VERIFIED, `sE6_gaia.asm`): `loc_08D9E7` masks the low nibble (`AND #$000F`, line ~428) and branches to the Freedan set-up when no Will bit is set; `LookupAbilityForm` returns 1 when the high nibble (`AND #$00F0`) is non-zero, returns 0 when it is zero, and returns carry set when the scene is not in the table (lines 1360–1379). The sparkle test loop at 2124–2133 tests `$24` and then `sfxQueueCh1` exactly as its notes say; the variant pick at 2137–2146 maps `RNG & 3` of 1 to frame #02, 2 to frame #03, others to #01.
`loc_08DCAF`, `loc_08EAAA` are `!` overrides in `APUWaitFixes.patch.asm:292,332` (A13-04). `table_08EB8F` and `table_08EBD3` appear inside `[ADR:&table_…,AAC]` dialog text (`dialogstring_08EB68` and `dialogstring_08EB85`, just above the table) and in both `chapter07.patch.asm` module files (base and ichagas): the tool rewrites those module files unless `--local-only` is used.

### 3.6 NAME NOW: inventory, player move, overlay (I, 25 rows)

| row | address | old | new | basis |
|---|---|---|---|---|
| A13-I001 | 257954 | loc_03EFA2 | GiveItem_RegularSlotScan | T |
| A13-I002 | 257962 | loc_03EFAA | GiveItem_SlotOccupied | T |
| A13-I003 | 257971 | loc_03EFB3 | GiveItem_SpecialItem | T |
| A13-I004 | 257985 | loc_03EFC1 | GiveItem_EffectIndex3Plus | T |
| A13-I005 | 258025 | loc_03EFE9 | GiveItem_Gems1 | T |
| A13-I006 | 258029 | loc_03EFED | GiveItem_Gems2 | T |
| A13-I007 | 258033 | loc_03EFF1 | GiveItem_Gems5 | T |
| A13-I008 | 258035 | loc_03EFF3 | GiveItem_AddGems | T |
| A13-I009 | 258052 | loc_03F004 | GiveItem_StoreGems | T |
| A13-I010 | 258060 | loc_03F00C | GiveItem_HpUp | T |
| A13-I011 | 258083 | loc_03F023 | GiveItem_HpUpStore | T |
| A13-I012 | 258098 | loc_03F032 | GiveItem_StrUp | T |
| A13-I013 | 258121 | loc_03F049 | GiveItem_StrUpStore | T |
| A13-I014 | 258152 | loc_03F068 | GiveItem_DefUpStore | T |
| A13-I015 | 258195 | loc_03F093 | RemoveItem_SlotScan | T |
| A13-I016 | 258208 | loc_03F0A0 | RemoveItem_Match | T |
| A13-I017 | 258225 | loc_03F0B1 | RemoveItem_Exit | T |
| A13-I018 | 258233 | loc_03F0B9 | CheckInventory_SlotScan | T |
| A13-I019 | 258247 | loc_03F0C7 | CheckInventory_Found | T |
| A13-I020 | 192023 | code_02EE17 | InventorySceneMainLoop | N |
| A13-I021 | 184314 | loc_02CFFA | PlayerMoveEastBranch | N |
| A13-I022 | 185101 | loc_02D30D | AutoAlignEW_NorthWestAttempt | N |
| A13-I023 | 185145 | loc_02D339 | AutoAlignEW_NorthNoNudge | N |
| A13-I024 | 185170 | loc_02D352 | NudgeAxisPlus8Clamped_Return | N |
| A13-I025 | 185204 | loc_02D374 | NudgeAxisMinus8Clamped_Return | N |

Trace result (VERIFIED, `inventory_mgmt.asm`): the special-item chain subtracts `$80` and walks `DEC` / `BEQ` for effect index 0 (HP), 1 (STR), 2 (DEF), 3/4/5 (gems 1/2/5) and falls into the heal for 6 and up (lines 70–100); the gem add clamps at `$03E7` (lines 123–131); the stat-ups clear `displayModeFlags` bit `$0080`, play SFX `$25` and add 1 with the `$7F → $55` overflow rule. The slot scans compare 16 `inventorySlots` bytes (`CPY #$0010`). Overrides in `InventoryManagement.patch.asm`: I001 (`:242`), I002 (`:243`), I016 (`:284`), I018 (`:249`); plain references to I003, I019 at `:219`, `:251`.

### 3.7 NAME NOW: scene script, collision, VRAM clear, slope (S, 6 rows)

| row | address | old | new | basis |
|---|---|---|---|---|
| A13-S001 | 164801 | code_0283C1 | SceneScriptMainLoop | I (inline: "Main command loop: read next scene command opcode") |
| A13-S002 | 164845 | code_0283ED | SceneScriptNoMusicLoop | T, I (block note above `SceneScriptNoMusic`: "Same dispatch loop … compares the handler address against SpcMusicLoadCmd") |
| A13-S003 | 167088 | code_028CB0 | SceneCmd_LoadCharTiles_VramBit1 | T, N (note above the part: "Continuation … Tests flag bit 1 for VRAM $1800") |
| A13-S004 | 192638 | loc_02F07E | ClearVramBufferLoop | T, I (`vram_buffer_clear.asm`, whole file read; "Join shared zero-fill loop") |
| A13-S005 | 245638 | loc_03BF86 | ApplyHitDamageToVictim_CombatEntry | T, I (block note, `combat_collision.asm:749-751`: "entered at loc_03BF86 when $24 is zero, is the combat-damage path") |
| A13-S006 | 178028 | loc_02B76C | DecelerateNS_ZeroSlopeStep | T, I (note above `DecelerateNS`; inline comment at `slope_ramp_physics.asm:634`) |

`HudRedesign.patch.asm` references `loc_02F07E` (A13-09). `docs/code/bank02/scene-script.md` quotes `code_0283C1`, `code_0283ED`, `code_028CB0`.

### 3.8 NAME NOW: entry stubs (E, 22 rows) and data sets (T, 9 rows)

Entry stubs. Each label is the first line after the `actor-def < …, {` or `thinker-def < …, {` header (VERIFIED by `rg -U` and by reading header, label and first instruction for all 22). Basis `S`.

| row | address | old | new | file |
|---|---|---|---|---|
| A13-E001 | 59728 | code_00E950 | ScrollCameraInitEntry | system/engine/camera_scroll.asm:43 |
| A13-E002 | 60057 | code_00EA99 | ScrollCameraTrackEntry | system/engine/camera_scroll.asm:81 |
| A13-E003 | 60074 | code_00EAAA | ScrollCameraVerticalEntry | system/engine/camera_scroll.asm:99 |
| A13-E004 | 60102 | code_00EAC6 | ScrollCameraAccumulateEntry | system/engine/camera_scroll.asm:123 |
| A13-E005 | 53460 | code_00D0D4 | SliderGlideTriggerWestEntry | system/engine/slider_glide.asm:36 |
| A13-E006 | 53532 | code_00D11C | SliderGlideTriggerEastEntry | system/engine/slider_glide.asm:87 |
| A13-E007 | 53688 | code_00D1B8 | SliderGlideTriggerSouthEntry | system/engine/slider_glide.asm:207 |
| A13-E008 | 46592 | loc_00B600 | PaletteParentChildEntry | thinkers/palette_parent_child.asm:17 |
| A13-E009 | 46688 | code_00B660 | OneshotColdataWarmFlashEntry | thinkers/oneshot_coldata_warm_flash.asm:15 |
| A13-E010 | 46707 | code_00B673 | GoldShipWreckPaletteEntry | thinkers/gold_ship_wreck_palette.asm:29 |
| A13-E011 | 46823 | code_00B6E7 | OneshotColdataR11g4b2Entry | thinkers/oneshot_coldata_r11g4b2.asm:15 |
| A13-E012 | 46530 | code_00B5C2 | FlagGatedPaletteWarmEntry | thinkers/flag_gated_palette_warm.asm:22 |
| A13-E013 | 46561 | code_00B5E1 | FlagGatedPaletteCoolEntry | thinkers/flag_gated_palette_cool.asm:21 |
| A13-E014 | 51558 | loc_00C966 | LargeRampBoosterEntry | actors/large_ramps.asm:23 |
| A13-E015 | 53971 | code_00D2D3 | RampEastEntry | actors/ramps.asm:67 |
| A13-E016 | 54091 | code_00D34B | RampWestEntry | actors/ramps.asm:151 |
| A13-E017 | 54205 | code_00D3BD | RampNorthEntry | actors/ramps.asm:230 |
| A13-E018 | 54315 | code_00D42B | RampSouthEntry | actors/ramps.asm:310 |
| A13-E019 | 50794 | code_00C66A | SceneFlagInitEntry | actors/scene_flag_init.asm:15 |
| A13-E020 | 577187 | code_08CEA3 | JewelerGemEntry | actors/jeweler_gem.asm:40 |
| A13-E021 | 778696 | code_0BE1C8 | DialogStringScannerEntry | actors/dialog_string_scanner.asm:24 |
| A13-E022 | 181135 | code_02C38F | PlayerCharacterEntry | actors/player/player_character.asm:90 |

The first stub of `hidden_red_jewel.asm` is counted in F064, the first of `layer1_scroll_actors.asm` in F066 and F075, the first of `diary_menu_window_dma.asm` in W001, because those carry a part note.

Data sets (tables). The notes say which animation index each set is. `address` = integer of the hex suffix (REPORTED rule); basis `N`.

| row | address | old | new | note |
|---|---|---|---|---|
| A13-T001 | 1082038 | sprite_set_1082B6 | inventory_anim_40_cursor | `inventory_spritemap.asm:405` "Animation $40: the selection cursor" |
| A13-T002 | 1082062 | sprite_set_1082CE | inventory_anim_44_status_row | `inventory_spritemap.asm:424` "Animation $44: the first of the nine status-row sets" |
| A13-T003 | 1015926 | sprite_set_0F8076 | will_ability_anim_04_psycho_dash_south | `spriteset_will_abilities.asm:101` |
| A13-T004 | 1016134 | sprite_set_0F8146 | will_ability_anim_0C_psycho_slider_south_start | `spriteset_will_abilities.asm:176` |
| A13-T005 | 1016342 | sprite_set_0F8216 | will_ability_anim_1C_spin_dash_start | `spriteset_will_abilities.asm:271` |
| A13-T006 | 1016392 | sprite_set_0F8248 | will_ability_anim_1D_spin_dash_guided_loop | `spriteset_will_abilities.asm:289` |
| A13-T007 | 1016508 | sprite_set_0F82BC | will_ability_anim_1F_flute_pose | `spriteset_will_abilities.asm:326` |
| A13-T008 | 1016518 | sprite_set_0F82C6 | will_ability_anim_20_hold_pose | `spriteset_will_abilities.asm:334` |
| A13-T009 | 1016578 | sprite_set_0F8302 | will_ability_anim_22_spin_dash_charge | `spriteset_will_abilities.asm:357` |

Caution: `notes-and-comments.md` §"Names Merge" is the doc for the key rule. I did not run the tool, so whether a `sprite_set_` data label keys on the hex suffix is REPORTED from the doc. F06 must confirm it with `--dry-run` before anything is applied. Note `sprite_set_0F8076` also appears in `gaia-core/docs/notes-and-comments.md` as an example (A13-09).

### 3.9 Name collision check

Method: `rg -o -N -w` (whole word; `-i` for most runs) of the proposed names over `extracted/`, `db-us/` (names, blocks, files, overrides, transforms), `baserom/`, `notes/`, `docs/`, `IOGRetranslation/modules/` and `gaia-core/docs/`, in six runs (the names changed between runs; each name in the tables above was in at least one run, and the names revised later were re-run; run 1 was case-sensitive, the others case-insensitive). Result of every run: no match (exit 1). Three further facts:

- The names inside this proposal are unique (checked by construction: each parent prefix plus a distinct suffix).
- No `new` name equals an existing `?INCLUDE` name or an existing extracted label (the runs cover `extracted/`).
- The names tool enforces the same rule again at dry-run time ("`new` must not already exist anywhere"); F06 relies on that.

Risks the check cannot see: a name that a later A-step or the user adds by hand before F06 runs.

### 3.10 LEAVE GENERIC

LEAVE GENERIC = 2456 audited definitions − 262 NAME NOW − 39 DEAD = **2155** (VERIFIED arithmetic; the directory totals are VERIFIED by `rg --stats`). By directory: system 1607, tables 155, functions 11, thinkers 83, actors 299. By file see §5.2.

Reasons, by class (REPORTED from the first pass, not re-run now unless noted):

1. **No note and no inline purpose**: pure scaffold. The large files: `actors/player/player_character.asm` 116, `actors/player/attack_ability_system.asm` 75, `system/engine/combat_collision.asm` 118, `system/engine/scene_script.asm` 113, `system/inventory/item_use_system.asm` 116, `system/player/player_move_west.asm` 72, `system/engine/actor_execution.asm` 68.
2. **Tier 2**: the first instruction has a comment of 20 or more characters, no part note (about 788 labels). The comment describes the instruction, not the purpose. A trace would make them NAME NOW, one routine at a time (a later pass).
3. **Data tables inside tables/**: `spriteset_pickups_effects.asm` 48, `inventory_spritemap.asm` 75 and `spriteset_will_abilities.asm` 32 still carry `sprite_set_` labels. R-B001-1 and the animation index in the pointer table would give a mechanical name `<map>_anim_<index>` for every set (scheme S-1, §4). Not proposed as rows: needs a decision and a check that every pointer table carries the index.
4. **Labels pinned by `transforms.json`**: A13-05. None of them in NAME NOW.
5. **spm sprite maps** (4616 labels, 44 files, §5.3): blocked by A13-10.
6. **String families**: `dialogstring_` 1847, `word_` 842, `consolestring_` 246, `sprite_group_` 1203, `code_list_` 182: policy LEAVE GENERIC (A13-11). They do not match the nine prefixes, so they are not part of the 2456.

### 3.11 DEAD (39)

DEAD = referenced by nothing in the ROM according to a note, a part or file name, or a doc. Tag VERIFIED for the notes read this session (sE6, `unused_particle_rain_spawner`), REPORTED for the sFA block note at `sFA_diary_menu.asm:38`, the `inventory_menu.asm:1086-1094` note and the `player_move_main.asm` part names (read in the first pass).

| group | count | addresses (old label) | basis |
|---|---|---|---|
| sE6 Aura / unreferenced pickup | 5 | 580203 `loc_08DA6B`, 580215 `loc_08DA77`, 580276 `loc_08DAB4`, 580297 `loc_08DAC9`, 585645 `loc_08EFAD` | notes at `sE6_gaia.asm:494,502,538,553,1501` ("Not referenced", "unreferenced Aura room", "Unreferenced pickup"); `loc_08EFAD` is patched, A13-03 |
| sFA `_noref` routines | 25 | 781361 `loc_0BEC31`, 781395 `loc_0BEC53`, 781407 `loc_0BEC5F`, 781586 `loc_0BED12`, 781597 `loc_0BED1D`, 781607 `loc_0BED27`, 782753 `loc_0BF1A1`, 782771 `loc_0BF1B3`, 782953 `loc_0BF269`, 782973 `loc_0BF27D`, 782993 `loc_0BF291`, 783013 `loc_0BF2A5`, 783024 `loc_0BF2B0`, 783113 `loc_0BF309`, 783129 `loc_0BF319`, 783157 `loc_0BF335`, 783176 `loc_0BF348`, 783195 `loc_0BF35B`, 783214 `loc_0BF36E`, 783233 `loc_0BF381`, 783252 `loc_0BF394`, 783271 `loc_0BF3A7`, 783290 `loc_0BF3BA`, 783330 `loc_0BF3E2`, 783333 `loc_0BF3E5` | the nine `_noref` routines and `DiaryMenuVBlankHandler` (its only caller is unreferenced), block note `sFA_diary_menu.asm:38` |
| `player_move_main` `DiagSnapCompute_Unused` | 5 | 184951 `loc_02D277`, 184973 `loc_02D28D`, 184992 `loc_02D2A0`, 184995 `loc_02D2A3`, 185005 `loc_02D2AD` | part name `_Unused` (starts 184919) |
| `inventory_menu` | 1 | 191046 `loc_02EA46` | block note `inventory_menu.asm:1086-1094` (second entry has no caller) |
| `unused_particle_rain_spawner` | 3 | 774835 `loc_0BD2B3`, 774844 `loc_0BD2BC`, 774903 `loc_0BD2F7` | file name and note |

Keep them generic. A generic name on dead code costs nothing; a name asserts a purpose that nothing in the ROM exercises.

---

## 4. Items for the fix specs (F06)

1. **F06 step (1), the names spec.** Build `plans/extracted-audit/renames/apply-F06_names.json` from §3 (rows F, W, D, G, I, S, E, T; 262 rows; spec shape in §3.1). Put the row ids in `row`. Dry-run first and show the summary.
2. **Apply in groups, rebuild after each** (checksum 223006080, crc 2083230829, size 3062204):
   1. F (functions and actors with notes) and E (entry stubs): no patch overrides.
   2. W, D and G (Gaia, diary): contains the `!` overrides of A13-04 and the module references; run **without** `--local-only`.
   3. I and S: inventory overrides (A13-04) and the `HudRedesign` reference.
   4. T (sprite sets): only after the dry-run confirms the data-part key.
3. **After apply**: `npm run extract:lt`, `npm run rebuild`, `npm run names -- --check`. Then `rg` the old names in `gaia-knowledge/curated/` (not covered by the tool, A13-09) and in the three commented lines of A13-08.
4. **Ask the user**:
   - How should the names tool key the spm sprite labels (A13-10)? Until then no spm rows.
   - Scheme S-1: name every `sprite_set_` in the three audited tables from its animation index (`<map>_anim_<index>`). It needs the pointer-table index check (REPORTED from A07 that the pointer tables are read in order; not verified for all three tables here).
   - Tier 2 (≈788 labels): trace in a separate pass, or leave.
5. **Do not touch** the labels in A13-05 (transforms) and the DEAD list (§3.11).
6. **Not in A13, for other steps**: A13-06 (216 OQ/R id lines in 93 files) to the OQ pass and a notes merge; A13-07 (the hedge on `loc_02B76C`) to a notes merge.
7. **Collision rule for F06**: names in §3 are unique now. If an A14 proposal adds a name with the same prefix (`Diary…`, `HitStagger…`, `GiveItem_…`), re-run the §3.9 check before applying.

---

## 5. Counts

### 5.1 Per directory (generic definitions, nine prefixes; VERIFIED by `rg --stats`)

| directory | files with generic labels | files searched | definitions | NAME NOW | DEAD | LEAVE |
|---|---|---|---|---|---|---|
| system | 73 | 124 | 1799 | 156 | 36 | 1607 |
| tables | 3 | 37 | 164 | 9 | 0 | 155 |
| functions | 8 | 27 | 35 | 24 | 0 | 11 |
| thinkers | 8 | 18 | 91 | 8 | 0 | 83 |
| actors | 16 | 29 | 367 | 65 | 3 | 299 |
| **audited total** | 108 | 235 | **2456** | **262** | **39** | **2155** |

Whole tree (nine prefixes, `\b` anchored): 8256 definition lines in 750 files. The pattern without `\b` found one more in the first pass (8257); the difference is not investigated.

By group: F 81, W 15, D 59, G 45, I 25, S 6, E 22, T 9 = 262.
By evidence: 234 have a part note on the label, 6 have no part note but an inline or block note (S001, S002, S004, S005, S006, G040), 22 are structural stubs (234 + 6 + 22 = 262). Independently of that split, 86 rows were traced against the code this session (basis `T`): 29 hit-stagger, 19 inventory, 5 drop system, 4 camera drift, 14 sE6, 10 diary, 5 scene/collision/VRAM/slope. The other 176 rows rest on the note alone (`N`, 153), on an inline comment (S001) or on structure (22).

### 5.2 Per file (total / NAME NOW / DEAD / LEAVE)

`actors`:

| file | total | NAME NOW | DEAD | LEAVE |
|---|---|---|---|---|
| camera_delta_oscillator.asm | 1 | 0 | 0 | 1 |
| camera_scroll_controller.asm | 8 | 8 | 0 | 0 |
| dialog_string_scanner.asm | 10 | 1 | 0 | 9 |
| hidden_red_jewel.asm | 1 | 1 | 0 | 0 |
| hit_stagger_controller.asm | 29 | 29 | 0 | 0 |
| jeweler_gem.asm | 13 | 2 | 0 | 11 |
| large_ramps.asm | 4 | 1 | 0 | 3 |
| layer1_scroll_actors.asm | 16 | 16 | 0 | 0 |
| player/attack_ability_system.asm | 75 | 0 | 0 | 75 |
| player/player_character.asm | 117 | 1 | 0 | 116 |
| player/player_move_controller.asm | 4 | 0 | 0 | 4 |
| player/shadow_shimmer.asm | 4 | 0 | 0 | 4 |
| player/slope_ramp_physics.asm | 46 | 1 | 0 | 45 |
| ramps.asm | 35 | 4 | 0 | 31 |
| scene_flag_init.asm | 1 | 1 | 0 | 0 |
| unused_particle_rain_spawner.asm | 3 | 0 | 3 | 0 |

`functions`:

| file | total | NAME NOW | DEAD | LEAVE |
|---|---|---|---|---|
| ActorMidpointCalc.asm | 2 | 0 | 0 | 2 |
| ApplyOrbitalOffsetFromRef.asm | 4 | 4 | 0 | 0 |
| ApplyOrbitalOffsetXY.asm | 4 | 0 | 0 | 4 |
| ApplyPlayerHitstun.asm | 6 | 6 | 0 | 0 |
| EnemyDefeatDispatch.asm | 2 | 2 | 0 | 0 |
| EnemyDropSystem.asm | 5 | 5 | 0 | 0 |
| EnemyPositionSnap.asm | 5 | 0 | 0 | 5 |
| camera_drift.asm | 7 | 7 | 0 | 0 |

`thinkers`:

| file | total | NAME NOW | DEAD | LEAVE |
|---|---|---|---|---|
| flag_gated_palette_cool.asm | 2 | 2 | 0 | 0 |
| flag_gated_palette_warm.asm | 2 | 2 | 0 | 0 |
| gold_ship_wreck_palette.asm | 5 | 1 | 0 | 4 |
| hdma_circle_window_thinker.asm | 44 | 0 | 0 | 44 |
| oneshot_coldata_r11g4b2.asm | 1 | 1 | 0 | 0 |
| oneshot_coldata_warm_flash.asm | 1 | 1 | 0 | 0 |
| palette_parent_child.asm | 1 | 1 | 0 | 0 |
| scanline_band_hdma_thinker.asm | 35 | 0 | 0 | 35 |

`tables`:

| file | total | NAME NOW | DEAD | LEAVE |
|---|---|---|---|---|
| inventory_spritemap.asm | 77 | 2 | 0 | 75 |
| spriteset_pickups_effects.asm | 48 | 0 | 0 | 48 |
| spriteset_will_abilities.asm | 39 | 7 | 0 | 32 |

`system` (files not listed in the "changed" block have NAME NOW 0 and DEAD 0; total = LEAVE):

| file | total | NAME NOW | DEAD | LEAVE |
|---|---|---|---|---|
| dark_space/sE6_gaia.asm | 50 | 45 | 5 | 0 |
| diary_menu/diary_menu_window_dma.asm | 15 | 15 | 0 | 0 |
| diary_menu/sFA_diary_menu.asm | 84 | 59 | 25 | 0 |
| engine/camera_scroll.asm | 7 | 4 | 0 | 3 |
| engine/combat_collision.asm | 119 | 1 | 0 | 118 |
| engine/scene_script.asm | 116 | 3 | 0 | 113 |
| engine/slider_glide.asm | 28 | 3 | 0 | 25 |
| functions/vram_buffer_clear.asm | 1 | 1 | 0 | 0 |
| inventory/inventory_menu.asm | 34 | 0 | 1 | 33 |
| inventory/inventory_mgmt.asm | 19 | 19 | 0 | 0 |
| inventory/inventory_overlay.asm | 9 | 1 | 0 | 8 |
| player/player_move_main.asm | 10 | 5 | 5 | 0 |

Unchanged system files (total = LEAVE): `engine/` ConsoleStringRenderer 50, DialogStringRenderer 34, DisplaySceneTitle 11, GetPlayerFacingDirection 3, GlobalInputHandler 6, MenuSelectionHandler 15, QuintetLzDecompress 26, actor_execution 68, actor_pool 13, camera_tilemap 40, cop_handlers_actor_death 10, cop_handlers_actor_flags 4, cop_handlers_actor_query 8, cop_handlers_audio 1, cop_handlers_bg_rearrange 3, cop_handlers_collision 36, cop_handlers_dialog 1, cop_handlers_dungeon_switch 1, cop_handlers_effects 41, cop_handlers_force_move 3, cop_handlers_input 12, cop_handlers_inventory 3, cop_handlers_metatile 14, cop_handlers_movement 47, cop_handlers_oam_attribs 2, cop_handlers_offscreen 2, cop_handlers_palette 7, cop_handlers_player_query 35, cop_handlers_player_sprite 13, cop_handlers_scene_flags 8, cop_handlers_script_control 5, cop_handlers_spawn 8, cop_handlers_sprite 13, cop_handlers_thinker 4, cop_handlers_vram 3, event_blocks 37, flag_helpers 3, hardware_math 12, hdma_dma_spc 14, map_coords 14, oam_digit_compose 6, radar_map_screen 18, save_system 5, scene_lifecycle 58, spc_transfer 22, sprite_composition 61, system_core 26, system_init 4, thinker_execution 12, tile_collision_physics 55, vblank_joypad 14, warps_interaction 41; `inventory/item_use_system` 116; `player/` player_move_east 27, player_move_ns 25, player_move_ramps 22, player_move_south 37, player_move_west 72, tile_collision 19; `statue_inventory/statue_inventory_reward` 10; `world_map/world_map_options` 27.

### 5.3 Supplementary families (not part of the 2456; VERIFIED by `rg --stats` this session)

| family | definitions | files |
|---|---|---|
| `dialogstring_XXXXXX` | 1847 | 394 |
| `word_XXXXXX` | 842 | 4 |
| `consolestring_XXXXXX` | 246 | 1 |
| `sprite_group_XXXXXX` (non-spm, all in `tables/`) | 1203 | 15 |
| `code_list_XXXXXX` | 182 | 108 |
| `spm_<map>_(sprite_set\|sprite_group\|table\|binary)_<offset>` | 4616 | 44 |

spm per file (definition lines): angel_sprites 84, tunnel_enemies 100, angkor_interior 108, angkor_outer 124, babel_spaceflight 8, dao 108, mine 167, prison_enemies 195, sc06_castle_actors 115, castle 112, ending_class 48, credits 66, ending_credits 138, euro 103, euro_geezers 100, freejia 134, goldship 85, sandfanger 121, greatwall 125, castoth 105, cliff_enemies 117, ruins_enemies 175, itory 164, solidarm 72, kress 106, vampires 148, mu_enemies 140, village 134, nazca 157, prologue_prophecy 36, mummyqueen 71, pyramid_puzzle 84, pyramid 94, descent 29, garden_enemies 155, viper 128, sc02_main_characters 152, southcape 163, boot_logos 4, darkspace 45, title_actors 2, overworld 62, watermia_lances 82, watermia 150.

`sprite_group_` per file (tables): inventory_spritemap 129, spriteset_aura 12, dark_friar 23, darkgaia_projectile 12, freedan 186, freedan_fx 13, freejia_tilefx 8, npc_props 20, pickups_effects 144, shadow 168, shadow_aura_body 23, shadow_fx 16, transform_poses 148, will 238, will_abilities 63.

### 5.4 Defect-class tally (this step)

| class | findings |
|---|---|
| 1 | A13-07 |
| 3 | A13-03, A13-08, A13-09, A13-12 |
| 7 | A13-06 |
| 12 | A13-05 |
| no class (backlog / policy / tool) | A13-01, A13-02, A13-04, A13-10, A13-11 |

Twelve findings, all VERIFIED in the sense of §"Tags" (A13-11 has REPORTED reference counts, flagged in the row).
