# A04 findings — I041–I050 row status, OQ registry, 34 fact re-checks, WaitByte and defect-class sweeps

Step: A04 (audit-of-audit). Date of the live checks: 2026-10-29. No notes, names, db files or docs were edited in this step. Shell use was limited to `rg`, `npm run names -- --check` and `git status` / `git diff --stat` / `git log`.

Evidence rules: every claim is **static** (E1 code trace, E2 cross-reference, E3 docs, E4 hardware docs). No Mesen2 ROM or state exists, so no E5 evidence was gathered. Tags: **VERIFIED** = checked in live files this session (file:line given); **REPORTED** = taken from a ledger and not re-checked.

Live `extracted/` is the **plain** tree (no `; {n}` tags), so line numbers below are plain-tree line numbers. Names were checked in `db-us/names/bank*.json` (`npm run names -- --check` → "Names check: OK (3510 names)").

---

## 1. Scope and files read

Plan and ledgers (read in full unless noted):
- `audit-of-audit/PLAN.md`, `report.md` (v2), `digest_I041-I072.md` (I041..I050 sections), `A01_findings.md` (first 70 lines, format only), `A03_findings.md` (findings section, for the hand-over of A03-12).
- `results/I041_results.md` … `I050_results.md`, `results/I041-I050_sanity-check.md`.
- `renames/I041_renames.md` … `I050_renames.md`, `renames/sanity-I041-I050_renames.md`, `renames/apply-I041-I050_plan.md`, `renames/apply-I041-I050_summary.md`. `renames/apply-I041-I050_map.json` was read as old→new pairs only (164 pairs).
- `questions/I041_questions.md` … `I050_questions.md`, `questions/sanity-I041-I050_questions.md`. Later results and questions files (I051..I072) were searched with `rg` for OQ ids; not read in full.
- Not read: `edits/*.json` (large spec files; the rename pass is described by the apply summary).

Live files used for checks (all under `gaia-iog-baserom`):
- `extracted/actors/`: `player/player_move_controller`, `player/player_character` (grep), `player/shadow_shimmer`, `dialog_string_scanner`, `reward_actors`, `hit_stagger_controller`, `hit_switch`, `jeweler_gem`, `town_door`, `overworld_exit`, `camera_scroll_controller`, `debug_man`, `field_reveal_object` (read ~140 lines), `unused_particle_rain_spawner` (grep).
- `extracted/functions/`: `ApplyPlayerHitstun`, `EnemyDefeatDispatch`, `EnemyDropSystem`, `SpawnItemSparkleEffect`, `camera_drift`, `npc_wander_ai`.
- `extracted/system/`: `player/player_move_main`, `inventory/inventory_mgmt`, `statue_inventory/statue_inventory_reward`, `engine/combat_collision`, `engine/actor_execution`, `engine/cop_handlers_script_control`, `engine/system_init`, `engine/MenuSelectionHandler` (grep), `engine/thinker_execution` (grep).
- `extracted/thinkers/`: `global_ambient_dispatcher`, `mode7_perspective`, `gold_ship_wreck_palette` (grep); `extracted/tables/enemy_stats_table.asm:103`; `extracted/mansion/solid_arm_lair/sEA_solid_arm.asm:57`.
- `db-us/transforms.json`, `db-us/structs.json`, `db-us/copdef.json`, `db-us/names/bank*.json`, `db-us/blocks.json`; `artifacts/crc.json`; `temp/`.
- File set swept with `rg` (30 live files; the I041..I050 renames moved four of the ledger file names): `hit_switch` (was `floor_button`), `SpawnDamageNumberEffect` (was `SpawnAttackTrailEffect`), `SpawnItemSparkleEffect` (was `SpawnHitSparkSprites`), `gold_ship_wreck_palette` (was `incan_ruins_transform_palette`), `unused_particle_rain_spawner`, `EnemyDropSystem` (was `DarkGemDropSystem`), plus the 24 files named above and `hidden_red_jewel`, `EnemyPositionSnap`, `ApplyOrbitalOffsetXY`, `ApplyOrbitalOffsetFromRef`, `inventory_statue_slot`. `tables/movement_delta_table.asm` of I050 is now `tables/move_chain_table.asm` (renamed by I062) and `tables/palette_bundles.asm`, `scene_actors.asm`, `scene_thinkers.asm`, `world_map/WorldMapController.asm` were only touched by the I041..I050 notes for cross-references; none of those was swept here.

---

## 2. Per-row status table (rename rows and Q5 rows)

Status codes: APPLIED, PROPOSED (still open), SUPERSEDED, DROPPED. "partial" = part of the row was done.

**How the APPLIED rows were checked (VERIFIED).**
- Old names: `rg -w` over `extracted/`, `db-us/`, `notes/`, `docs/`, `src/`, `baserom/` for the 59 retired descriptive names of the apply map (all old names that are not auto `loc_` / `code_` / `binary_` / `dialogstring_` labels; the 105 auto labels were not searched, only their new names were spot-checked) finds **no label, names entry or `blocks.json` key**. The only hits are prose "formerly …" mentions (8 lines in 7 extracted files, 8 lines in `notes/`, 1 line in `docs/code/bank00/functions-combat-defeat.md:256`; see A04-08). `docs/code/bank02/player-movement.md:68` matches only the pattern `AutoAlignEW*`.
- New names: 29 of 30 sampled new names are keys in `db-us/names/bank00/02/03/08/0A/0B.json`; the thirtieth, `EnemyDropSystem`, is a block name (file `extracted/functions/EnemyDropSystem.asm` exists, the old `DarkGemDropSystem.asm` does not).
- The apply summary says 164 pairs (105 auto-labelled addresses gained a names entry, 59 existing names or block keys renamed). Not re-counted.

### 2.1 Rename rows (56) and sanity rows (2)

| Row | Status | Tag | Evidence |
|---|---|---|---|
| R-I041-1 | APPLIED | VERIFIED | `SpawnDamageNumberEffect`, `DamageNumberShort_unused` in names / files |
| R-I041-2 | APPLIED | VERIFIED | `Mode7InitEntry`, `Mode7Q1Scanline` … `NormalizeDivisorShift`, `HiddenRedJewelDone` in names |
| R-I041-3 | PROPOSED | VERIFIED | `$00B6 / $00B8 / $00BC / $00CA / $00CC` still bare in `mode7_perspective.asm` (11 lines) |
| R-I041-4 | PROPOSED (text part done) | REPORTED | summary §2: `structs-reference.md` corrected, `structs.json` untouched |
| R-I041-5 | APPLIED (docs) | REPORTED | summary §4 |
| R-I042-1 | APPLIED | VERIFIED | `SpawnItemSparkleEffect`, `AppendSparkleOamEntries` |
| R-I042-2 | APPLIED | VERIFIED | `hit_switch`, `HitSwitchInit`, `HitSwitchRearm`, `HitSwitchTriggered` |
| R-I042-3 | APPLIED | VERIFIED | 15 `OverworldExit*Stage` / `OverworldExitSouthCapeEdge` labels (`OverworldExitEdwardCastleStage` present) |
| R-I042-4 | PROPOSED | VERIFIED | `$0D60` is still a bare operand in 27 lines of `overworld_exit.asm` (`STA $0D60`; 27 matches) |
| R-I042-5 | APPLIED (docs) | REPORTED | summary §4 |
| R-I043-1 | APPLIED | VERIFIED | `TownDoorHoldUpLoop`, `TownDoorOpenSound` |
| R-I043-2 | APPLIED | VERIFIED | `JewelerCancelReply`, `JewelerGiveJewelsOption`, `JewelerMenuTable`, `JewelerInventoryFull`, `JewelerGoodbye_unused` |
| R-I043-3 | PROPOSED | VERIFIED | `jeweler_gem.asm:312,323` still `STA $0B16` / `STA $0B1C`; `$0000` scratch still bare |
| R-I043-4 | DROPPED (keep as is) | REPORTED | summary §2 |
| R-I043-5 | APPLIED (docs ×6) | REPORTED | plan step 8 |
| R-I044-1 | APPLIED | VERIFIED | `gold_ship_wreck_palette`, `GoldShipWreckPaletteFlag4D` (names) |
| R-I044-2 | APPLIED | VERIFIED | `GlobalAmbientProbeDown/Up/Left/Right`, `GlobalAmbientFacingValid`, `GlobalAmbientOnInteractPress`, `GlobalAmbientTalkWithSnapshot`, `GlobalAmbientTalkRestoreActor`, `GlobalAmbientTargetAtOrBehind`, `GlobalAmbientPaletteUnused` live in the file |
| R-I044-3 | PROPOSED (out of scope in the pass) | VERIFIED | block name is still `global_ambient_dispatcher` (file exists) |
| R-I044-4 | PROPOSED | VERIFIED | `global_ambient_dispatcher.asm` `STA $09EE` (3 sites), `$0404`/`$0405`; `ApplyOrbitalOffsetXY.asm:50,60` `$7F0011` / `$7F0013` still bare |
| R-I044-5 | APPLIED (docs ×6) | REPORTED | plan step 8 |
| R-I045-1 | APPLIED | VERIFIED | `AutoAlignEW_North`, `NudgeAxisPlus8Clamped` / `NudgeAxisMinus8Clamped` |
| R-I045-2 | APPLIED | VERIFIED | `PlayerMovementTick_AfterHorizontal` / `_SouthStep` / `_Exit` (names) |
| R-I045-3 | PROPOSED | REPORTED | DP scratch mnemonics (`$20`–`$26`, `$AA`, `$AB`, `$1A`, `$1E`); not re-grepped |
| R-I045-4 | APPLIED (variant: `PlayerMovementTick_SouthStep`) | VERIFIED | summary §1 deviation; name in `db-us/names/bank02.json` |
| R-I045-5 | APPLIED | REPORTED | `ApplyOrbitalOffsetFromRef_AddToCurrent` (summary §1) |
| R-I045-6 | APPLIED | VERIFIED | `unused_particle_rain_spawner`, `UnusedRainSpawnerLoop` |
| R-I045-7 | APPLIED (docs) | REPORTED | plan step 8 |
| R-I046-1 | APPLIED | VERIFIED | `HitStaggerSlideLoop`, `HitStaggerReleasePlayer` |
| R-I046-2 | APPLIED | VERIFIED | `HitStaggerZeroToCarry` |
| R-I046-3 | APPLIED | VERIFIED | `EnemyDefeatDispatch_CountKill` / `_NotLast` |
| R-I046-4 | PROPOSED | REPORTED | mnemonic aliases for `orbitAngle` / `orbitDiameter` reuse in the stagger actor |
| R-I046-5 | PROPOSED | REPORTED | same family (`free101C`, `moveScratch1/2`) |
| R-I046-6 | APPLIED | VERIFIED | `EnemyDefeatDispatch` labels |
| R-I046-7 | APPLIED (docs) | REPORTED | plan step 8 |
| R-I047-1 | APPLIED (variant: `PlayerMoveCollisionTick`) | VERIFIED | summary §1 deviation; `PlayerMoveCollisionTick` in `bank02.json` |
| R-I047-2 | APPLIED (variant: `JoypadVelocityPureUp/Down`) | VERIFIED | `JoypadVelocityDone` etc. in names |
| R-I047-3 | PROPOSED | REPORTED | scratch word mnemonics |
| R-I047-4 | APPLIED | VERIFIED | `InventoryStatueSlotEntry` |
| R-I047-5 | APPLIED | VERIFIED | `HpIncreaseStore` (and `StrIncreaseStore`, `DefIncreaseStore`, `reward_actors.asm:35,59,80`) |
| R-I047-6 | APPLIED (docs ×6) | REPORTED | plan step 8 |
| R-I048-1 | APPLIED | VERIFIED | `StatueRewardEntry`, `StatueRewardNotThisStatue`, `statue_reward_table` |
| R-I048-2 | APPLIED (partial: subset by design) | VERIFIED | `IsNotLoromAddress`, `ShadowShimmerSlowStrips` / `FastStrips`; `ShadowShimmerIdle` / `Active` kept |
| R-I048-3 | PROPOSED | VERIFIED | `statue_inventory_reward.asm:168,174,182` still `LDA $0B08 / $0B0C / $0B10` |
| R-I048-4 | PROPOSED | VERIFIED | `dialog_string_scanner.asm:79,81` still `STA $0100` / `STA $0102` |
| R-I048-5 | APPLIED (docs) | REPORTED | plan step 8 |
| R-I049-1 | APPLIED | VERIFIED | `EnemyDropSystem` block, `SpawnDropGem1`, `DropBodyGem1/2/5`, `DropBodyHeal5` |
| R-I049-2 | APPLIED | VERIFIED | `drop_threshold_by_hp` (struct rows read, §4) |
| R-I049-3 | APPLIED | VERIFIED | `DebugManEntry`, `DebugMenuLevel2..7`, `DebugMenuTable1..7`, 21 `DebugWarp*` labels (`debug_man.asm` read) |
| R-I049-4 | APPLIED (partial: renamed, not removed) | VERIFIED | `CameraDeadBoundsX/Y` live in `camera_scroll_controller.asm` |
| R-I049-5 | APPLIED (docs) | REPORTED | plan step 8 |
| R-I049-6 | APPLIED (note) | REPORTED | `EnemyGemDropRouter` header (plan step 7) |
| R-I050-1 | PROPOSED | VERIFIED | `inventory_mgmt.asm:214,215,233,234` still `STA $0DB8` / `STZ $0DB9` |
| R-I050-2 | PROPOSED | REPORTED | file-local aliases for the shared mnemonics |
| R-I050-3 | APPLIED | VERIFIED | `NpcWanderStandSouth/North/West/East`, `NpcWanderStageStand` / `StageWalk`, `npc_wander_case_table` |
| R-I050-4 | APPLIED (partial) | VERIFIED | `camera_drift_offsets`, `CameraDriftShipPassEnd`; typing / dead-code removal not applied (summary §1) |
| R-I050-5 | APPLIED (docs) | REPORTED | plan step 8 |
| D-S4150-1 | APPLIED (comments) | REPORTED | plan step 7 (`sE6_gaia` `$0008` comments) |
| D-S4150-2 | APPLIED (doc) | REPORTED | plan step 8 |

Totals: 56 rename rows = **APPLIED 41** (including the variants and partials marked above: R-I045-4, R-I047-1, R-I047-2, R-I048-2, R-I049-4, R-I050-4), **PROPOSED 14** (R-I041-3, R-I041-4, R-I042-4, R-I043-3, R-I044-3, R-I044-4, R-I045-3, R-I046-4, R-I046-5, R-I047-3, R-I048-3, R-I048-4, R-I050-1, R-I050-2; R-I041-4 and R-I044-3 were outside the pass by decision), **DROPPED 1** (R-I043-4), **SUPERSEDED 0**. Per iteration (APPLIED / PROPOSED / DROPPED): I041 3/2/0, I042 4/1/0, I043 3/1/1, I044 3/2/0, I045 6/1/0, I046 5/2/0, I047 5/1/0, I048 3/2/0, I049 6/0/0, I050 3/2/0. Both sanity rows APPLIED (REPORTED).

### 2.2 Q5 rows (30 rows: three per iteration)

| Group | Count | Status |
|---|---|---|
| Q5 = M (new mnemonic proposed) | 14 rows (R-I041-3; R-I042-4; R-I043-3; R-I044-4 ×3; R-I045-3; R-I046-4/5; R-I047-3; R-I048-3; R-I048-4 ×2; R-I050-1; R-I050-2) | all **PROPOSED** (the apply pass excluded mnemonics). VERIFIED still open for R-I041-3, R-I042-4, R-I043-3, R-I044-4, R-I048-3, R-I048-4, R-I050-1; the other rows REPORTED |
| Q5 = NA (nothing to add) | 16 rows (I041 ×2, I042 ×2, I043 ×2, I045 ×2, I046 ×2, I047 ×2, I049 ×3, I050 ×1) | NOFIX (no action) |

---

## 3. Open questions of I041..I050 (53 questions)

"Answered later by id" = a later ledger (I051..I072 results, renames, questions, sanity files) cites the id and closes it. `rg` over the later ledgers for all 53 ids: **no hit** (VERIFIED). The OQ-* are not answered in this step; where live code gives static evidence it is recorded as evidence, not as a closure.

| OQ | Answered later by id | Note |
|---|---|---|
| OQ-I041-1 | no | `$7F0B22` / `$7F0B24`: still "no reader found" (`mode7_perspective.asm:53,84`) |
| OQ-I041-2 | no | needs picture (Mesen2) |
| OQ-I041-3 | no | `mode7_perspective.asm:52`; the note also names a block that no longer exists (A04-06) |
| OQ-I041-4 | no | needs runtime |
| OQ-I041-5 | no | `SpawnDamageNumberEffect.asm:19` |
| OQ-I041-6 | no | child flag `$0400`: topical evidence in `hit_stagger_controller` (victim is the player) does not cover the damage-number child; open |
| OQ-I041-7 | no | `hidden_red_jewel.asm:36`, needs picture |
| OQ-I042-1 | no | **static evidence found in this step** (A04-01): the heal id `$86` is reachable via `EnemyDropSystem`; the live note still calls it open |
| OQ-I042-2 | no | tile look; needs picture (`SpawnItemSparkleEffect.asm:12`) |
| OQ-I042-3 | no | `hit_switch.asm:25` |
| OQ-I042-4 | no | iframe mode of `$12` bit `$0001`; "not traced" in `hit_switch.asm:5` |
| OQ-I042-5 | no | `overworld_exit.asm:37,193`; needs runtime (`CMP #$02D0` equality is VERIFIED, §4 #33) |
| OQ-I042-6 | partial topical (REPORTED: I057 says `gfxCacheIdxB` is two speed bytes) | `$0D60 := 0` side effect still open; ids at `overworld_exit.asm:39,141,163` |
| OQ-I042-7 | no | `overworld_exit.asm:38` |
| OQ-I042-8 | no | "Quit only" menus |
| OQ-I043-1 | no | `town_door.asm:7` |
| OQ-I044-1 | no | `gold_ship_wreck_palette.asm:19` |
| OQ-I044-2 | no | Flags12 bit `$0200` meaning |
| OQ-I044-3 | no | yielding chat routine |
| OQ-I044-4 | no | **static evidence found**: `transforms.json:756` rewrites `remapA` to `#$8080` and `system_init.asm:231` initialises it; the dispatcher note already says "the A button feeds it". Not closed here |
| OQ-I045-1 | no | `player_move_main.asm:14,99,108`; code shows only `$0040` is ever set (§4 #5) |
| OQ-I045-2 | no | `unused_particle_rain_spawner.asm:12` |
| OQ-I045-3 | no | |
| OQ-I045-4 | no | by name, no reference to `unused_particle_rain_spawner` outside its own file (VERIFIED `rg -w`); unlabelled pointer data needs CDL |
| OQ-I045-5 | no | orbit angle direction |
| OQ-I046-1 | no | sound `#07` vs `#08` |
| OQ-I046-2 | no | `ApplyPlayerHitstun.asm:9` |
| OQ-I046-3 | no | `hit_stagger_controller.asm:15` |
| OQ-I046-4 | no | `EnemyDefeatDispatch.asm:12,34` |
| OQ-I046-5 | no | knockback tier ≥ 2 |
| OQ-I046-6 | no | the static half (gem 1/2/5 by low two bits of stat byte +3) is established by I051 and VERIFIED live (§4 #7); the visible drop is runtime |
| OQ-I047-1 | no | |
| OQ-I047-2 | no | |
| OQ-I047-3 | no | pedestal pixels |
| OQ-I048-1 | no | `shadow_shimmer.asm:11` (also quotes OQ-I030-1) |
| OQ-I048-2 | no | persistence of direct PPU writes |
| OQ-I048-3 | no | static count 60 VERIFIED (§4 #12); visible count needs runtime |
| OQ-I048-4 | no | by name, `dialog_string_scanner` has no reference outside its block entry (`blocks.json:281`); unlabelled data needs CDL |
| OQ-I048-5 | no | |
| OQ-I049-1 | no | by name, `debug_man` has no spawn reference (`blocks.json:282` only); needs CDL |
| OQ-I049-2 | no | |
| OQ-I049-3 | no | `EnemyDropSystem.asm:10,44` |
| OQ-I049-4 | no | `camera_scroll_controller.asm:14,125` |
| OQ-I049-5 | no | |
| OQ-I049-6 | no | **static evidence found**: all nine table percentages recomputed from `drop_threshold_by_hp` match the note (§4 #22); the in-play distribution is runtime |
| OQ-I049-7 | no | `CameraDeadBoundsX/Y` never branched to (VERIFIED by reading the file: preceding code ends in `BRA`) |
| OQ-I050-1 | no | `inventory_mgmt.asm:151` |
| OQ-I050-2 | no | `camera_drift.asm:9` |
| OQ-I050-3 | no | step length (static formula in the note: half the frames of the walk animation) |
| OQ-I050-4 | no | `camera_drift.asm:116` |
| OQ-I050-5 | no | **static evidence found**: the only readers of `camera_drift_offsets` are `camera_drift.asm:105` and `:139`, both after `AND #$0007`; no other reference by name |
| OQ-I050-6 | no | partial static evidence: for the drop pickup the sparkle appears at the pickup actor (`combat_collision.asm` `InteractionDamage_NPCChat` starts `TYX`, then `GiveItemToPlayer`; `inventory_mgmt.asm` `PHD / TXA / TCD`). Chest / COP callers not traced |
| OQ-I050-7 | no | |

Summary: **0 of 53 answered later by id**; 1 topical partial (OQ-I042-6); static evidence found in this step for 5 (OQ-I042-1, OQ-I044-4, OQ-I049-6, OQ-I050-5, OQ-I050-6 partial); OQ-I045-1 is already answered in the live note itself.

---

## 4. Re-verified facts (34 checks over 22 files)

| # | Claim | Source | Live evidence | Result |
|---|---|---|---|---|
| 1 | Flags10 `$0008` = collision-checked movement (controller dispatch) | I047, block note | `player_move_controller.asm` `BIT #$0008` → `PlayerMoveCollisionTick`, else direct add (~174-175) | CORRECT (VERIFIED) |
| 2 | Hit-stun gate: `$0080` plus negative / positive `iframeCounter` | I047 | `player_move_controller.asm` ~45-52 | CORRECT (VERIFIED) |
| 3 | Script / ability lock `$0A00` in `playerFlags` | I047 | `player_move_controller.asm` ~60 `BIT #$0A00` | CORRECT (VERIFIED) |
| 4 | Flags10 `$0008` meaning in the block note ("collision-checked movement; vine / ladder / shimmy clear it") | I045 / R-I045 docs | `player_move_main.asm:1-32`; `player_character.asm:7,484,489,840-854,1041-1042` | CORRECT (VERIFIED) |
| 5 | `$AA`: only bit `$0040` is ever set; `$0800` and `$0400` are never set | I045 | `player_move_main.asm`: `STZ $AA` (~60), `TSB $AA` (~69, ~77); gates at 99 (`BIT #$0800`) and 108 | CORRECT (VERIFIED, static) |
| 6 | `ComputeYSnapOffset` returns 1..16 | I045 | `player_move_main.asm` ~125-132 | CORRECT (VERIFIED) |
| 7 | Stat-table byte +3 gives "a HP / STR / DEF gem" | I046 results Q3(b) (`I046_results.md:44`) | `EnemyDefeatDispatch.asm:6` (live): low two bits → 0 nothing, 1/2/3 = gem pickup of 1/2/5 gems (items `$83/$84/$85`); `field_reveal_object.asm` `FieldRevealFromActorStats` (`LDA $0003,Y; AND #$0003`); HP/STR/DEF items `$80-$82` come only from the room-tier path | **I046 ledger statement WRONG** (corrected by I051 `I051_results.md:48,62`); live note CORRECT |
| 8 | Scanner pointer test: carry set below `$8000`, caller skips on carry set | I048 | `dialog_string_scanner.asm:74-75` (`JSR IsNotLoromAddress`, `BCS`), `:101-109` (`CMP #$8000; BCC`→`SEC`, else `CLC`) | CORRECT (VERIFIED) |
| 9 | `02 BF` scan = COP `PrintDialogString` | I048 | `dialog_string_scanner.asm:55-56` (`LDA #$BF02`, `CMP $0000,Y`); `db-us/copdef.json:175` id 191 = `$BF` | CORRECT (VERIFIED) |
| 10 | `$0100` = "the scan offset after this hit" | I048 | `dialog_string_scanner.asm:76-79`: after the hit `Y` is incremented once (`INY` at 76), then `TYA / STA $0100`, so `$0100` = hit offset + 1; the resume offset (hit + 4) is `PHY` after three more `INY` | IMPRECISE (A04-07) |
| 11 | `reward_actors` clamp `#$0255` never loaded | I047 | `reward_actors.asm:32-36, 56-60, 77-81`: 16-bit `ADC #$0001; BVC …Store; LDA #$0255`; overflow only at `$7FFF` + 1 | CORRECT (VERIFIED, static) |
| 12 | Statue ceremony: 8 sparkles, 60 confetti bursts (`LoopStart #3C`) | I048 | `statue_inventory_reward.asm` `LoopStart ( #3C )`; `cop_handlers_script_control.asm:7` (LoopStart/LoopEnd run exactly N iterations) | CORRECT (VERIFIED) |
| 13 | `statue-reward` struct has a 1-byte tail (4-byte stride, matching `ASL ASL`) | I048 | `db-us/structs.json:106` `{ "types": ["Byte","Byte","Byte"], "tail": 1 }` | CORRECT (VERIFIED) |
| 14 | `joypadMaskStd |= $FFFC`, vanilla `$FFF0` rewritten by `transforms.json`, probably for the remapped X bit `$0004` | I048 | `statue_inventory_reward.asm:19,61,64`; `transforms.json:553-555` (multi-line regex, `LDA #$FFF0` + next-line `TSB $joypadMaskStd`); `transforms.json:758` `remapX` → `#$0004` | CORRECT (VERIFIED; "probably" is a stated inference) |
| 15 | Stagger child flags: `$2000` enemy path, `$2400` player; `$0400` = victim is the player | I046 | `hit_stagger_controller.asm:99-100, 160`; `combat_collision.asm` spawn sites 615, 870 (`#$2000`), 1512 (`#$2400`); `ApplyPlayerHitstun` passes `#$2400` | CORRECT (VERIFIED) |
| 16 | `HitStaggerReleasePlayer` sets the iframe counter `$FFE2` after the 16-frame slide (stun ends in about 17 ticks, not 60) | I046 | `hit_stagger_controller.asm:15, 23, 301`; `LoopStart #$10`; positive counter freezes the controller | CORRECT (VERIFIED, static) |
| 17 | `ApplyPlayerHitstun` has 9 JSL sites | I046 | `ir1F_stone_guard.asm:554,607,660,711`; `gw83_asp.asm:340,401,456`; `gw82_archer.asm:615,668` | CORRECT (VERIFIED count) |
| 18 | `$12 |= $1000` is a "priority boost" on the defeat flash | I046 / `EnemyDefeatDispatch.asm:10` | Bit `$1000` of `$12` is the display / overlay-active qualifier (`camera_scroll_controller.asm:5`; `camera_drift.asm:14`) | **WRONG vocabulary** (A04-05) |
| 19 | Jeweler tiers `$E9`-`$EE`, BCD thresholds 3/5/8/12/20/30/50, 8-jewel text mismatch, Solid Arm flag `$E8` | I043 | `jeweler_gem.asm` cascade (`CMP #$0012 / #$0020 / #$0030 / #$0050`), `JewelerRewardHp` `INC $playerMaxHp` vs `dialogstring_08D395` ("Your Strength is raised by one"); `sEA_solid_arm.asm:57` `SetFlagByte ( #E8 )` | CORRECT (VERIFIED) |
| 20 | Gem is talked to by "pressing B" | I043 / `jeweler_gem.asm:5,55` | Interact bit `$8000` is fed by the A button in this build (`transforms.json:755-758`, `system_init.asm:230-233`, `global_ambient_dispatcher.asm:13,105`) | **WRONG vocabulary** (A04-04) |
| 21 | Town door opens after holding Up (`$0800`) for 8 frames | I043 | `town_door.asm` `LoopStart ( #08 )`, `BranchIfPressed ( #$0800 )`; `$0800` = Up (JOY1H bit 3, E4; also `JoypadToVelocity` in `player_move_controller.asm`) | CORRECT (VERIFIED) |
| 22 | Weighted drop percentages (nine values) | I049 | `drop_threshold_by_hp`: group 0 thresholds `$0F,$3C,$99,$100` → heal 5.9%, 5 gems 17.6%, 2 gems 36.3%, 1 gem 40.2%; group `$10` `$19,$4C,$99,$100` → 9.8 / 19.9 / 30.1 / 40.2; group `$20` `$0C,$33,$7F,$100` → 4.7 / 15.2 / 29.7 / 50.4; HP tier code (`LSR LSR; CMP playerHp; BCC`) | CORRECT (VERIFIED, arithmetic) |
| 23 | "No item id of $86 or more was found … reachability open (OQ-I042-1)" | `SpawnItemSparkleEffect.asm:5` | `EnemyDropSystem.asm:6,10` and `DropBodyHeal5` (`LDA #$0086; STA $chatPtr,X`), rows 00/06/0B of `drop_threshold_by_hp`; `combat_collision.asm` `InteractionDamage_NPCChat` → `GiveItemToPlayer(chatPtr)` (line 1559) | **WRONG (stale)** (A04-01) |
| 24 | `GiveItemToPlayer` has 10 JSL sites in 5 files | I050 | `pyCD_puzzle.asm:99,110,118,126,134,142`; `item_use_system.asm:1563`; `combat_collision.asm:1559`; `cop_handlers_inventory.asm:28`; `warps_interaction.asm:345` | CORRECT (VERIFIED) |
| 25 | Stat-up `$7F` → `$55` is a reset, not a cap; gems cap at 999 | I050 | `inventory_mgmt.asm` 8-bit `ADC #$01; BVC`, `LDA #$55`; `CMP #$03E7` | CORRECT (VERIFIED) |
| 26 | `camera_drift`: 120 passes, 3-run pattern, table masked to 8 entries (sum 0), last 8 words unused | I050 | `camera_drift.asm` `LoopStart ( #78 )`, `$2A := 2 / DEC $2A / BMI`, `AND #$0007`; table bytes `0100 FFFF FEFF 0100 0200 0000 FEFF 0100 | 0500 FCFF FEFF 0400 0100 FBFF 0400 FDFF` | CORRECT (VERIFIED) |
| 27 | Camera target = `P - $80`, clamped to `cameraOffset` / `cameraBounds - $100` | I049 | `camera_scroll_controller.asm` (`SBC #$0080`, `BMI`, `CMP offset`, `ADC #$0100`, `CMP bounds`, `SBC #$0100`) | CORRECT (VERIFIED) |
| 28 | Facing codes 0/1/2/3 = down/up/left/right; probe point and "at or behind" test | I044 | `global_ambient_dispatcher.asm` `GlobalAmbientFacingValid` chain (`AND #$00FF; BEQ; DEC; BEQ; DEC; BEQ`), four probe labels, `BMI GlobalAmbientTargetAtOrBehind` | CORRECT (VERIFIED) |
| 29 | `debug_man` has 21 destinations in 7 five-entry menus | I049 | `debug_man.asm` tables 1..7 (entry 0 = `DebugManQuit`) and 21 `DebugWarp*` leaves | CORRECT (VERIFIED) |
| 30 | `hit_switch` stats row `enemy_stats_table + $118` = entry `$46`, `HP $14, ATK $16, DEF $FF, type 0` | I042 | `tables/enemy_stats_table.asm:103` `enemy-stats < #14, #16, #FF, #00 > ;46`; 70 × 4 = `$118` | CORRECT (VERIFIED) |
| 31 | `WaitByte #0F` holds "$0F frames" | `hit_switch.asm:10,75` | Wait counter runner: `actor_execution.asm:144,180` (`DEC $08`; runs when negative) → n + 1 = 16 ticks | **WRONG** (A04-02) |
| 32 | `$08 := $78` sleeps 120 frames; `$08 := 3` waits 3 frames | `npc_wander_ai.asm:14,100,106`; `camera_drift.asm:21,89,171` | same runner → 121 and 4 ticks | **WRONG** (A04-03) |
| 33 | Edward's Castle exit tests `playerYPos == $2D0` (equality; South Cape uses `Y < $10`) | I042 | `overworld_exit.asm:191-194` `CMP #$02D0; BEQ`; 27 `StageWorldMapChoice` sites | CORRECT (VERIFIED) |
| 34 | `M7SEL $80` written by the thinker init (transparent outside the map) | I041 | `mode7_perspective.asm:81-82` (`LDA #$80; STA $M7SEL`) and note line 48; bit meaning from E4 memory, not re-read | CORRECT for the code (VERIFIED); hardware wording REPORTED |

Tally: **27 CORRECT, 1 ledger statement wrong (#7, already corrected live), 6 live defects (#10 imprecise, #18, #20, #23, #31, #32)**.

---

## 5. Findings

Fields: id, tag, location, what is wrong, proposed fix, defect class (PLAN.md numbering), fix step. F07 is the batch id used by A02 and A03 for note clean-ups that are not listed in PLAN.md's F01–F06.

**A04-01** (VERIFIED, class 3 and 11 and 7). `SpawnItemSparkleEffect.asm:5` says "No item id of `$86` or more was found in the chest tables or GiveItem operands of extracted/, so whether this path is reachable in the shipped game is open (OQ-I042-1)" and that the sparkle position is "the actor whose slot is in X … (the in-line comment there says the player; not verified)". The heal id is reachable: `EnemyDropSystem.asm:6,10,150-153` documents the pickup `DropBodyHeal5` (`LDA #$0086; STA $chatPtr,X`), `drop_threshold_by_hp` rows 00, 06 and 0B select it (5.9% / 30.1% / 50.4%), and `combat_collision.asm:1550-1559` (`InteractionDamage_NPCChat`: `TYX`, then `JSL GiveItemToPlayer` with `chatPtr`) calls the heal branch of `inventory_mgmt.asm` (`PHD / TXA / TCD`, `SpawnListAppend`), so the sparkle is created at the pickup actor. The same stale claim is in the I042/I050 ledgers (OQ-I042-1, OQ-I050-6) and probably in the part notes (not re-read). The note also quotes OQ-I042-1 and OQ-I042-2 (`:12`) and narrates "The old text … is wrong" (`:1`). Fix: `merge` spec: state that the heal pickup of `EnemyDropSystem` reaches it, the sparkle sits at the pickup, drop the ids and the old-text sentence. Step: F07.

**A04-02** (VERIFIED, class 2). `hit_switch.asm:75` (`COP [WaitByte] ( #0F ) ; Hold for $0F frames`) and the block note `:10` ("struck again after about `$0F` frames plus two animation cycles") and the part note above `HitSwitchTriggered` ("wait `$0F` frames") state n instead of n + 1. `WaitByte #0F` holds **16** ticks (`actor_execution.asm:144,180`; the correct form is already in `hit_stagger_controller.asm:10` "WaitByte #$0F (16 ticks)" and `unused_particle_rain_spawner.asm:5`). The sanity pass did not report it. Fix: `merge` spec: "16 ticks" in the inline comment, the part note and the block note. Step: F02 (add `hit_switch.asm` to its target list).

**A04-03** (VERIFIED, class 2). Direct stores to the wait counter `$08` are described as N frames, but the runner skips N passes and runs on pass N + 1: `npc_wander_ai.asm:14` ("the script sleeps 120 frames"), `:100` ("wait 120 frames"), `:106` (inline comment) → **121 ticks**; `camera_drift.asm:21` ("A run is followed by `$08 := 3` (3 frames) … lives about 9 frames"), `:89` ("3 frames apart"), `:171` ("Wait 3 frames before the next run") → **4 ticks** apart, three runs span 8 ticks. `statue_inventory_reward.asm:23` and `:147` (`WaitByte #0F`) state no tick count and are fine. Fix: `merge` specs for both files. Step: F02.

**A04-04** (VERIFIED, class 13). `jeweler_gem.asm:5` ("runs `JewelerInteract` when the player presses B facing him") and `:55` (inline: "when the player presses B facing Gem") use the vanilla button. The talk trigger is the interact bit `$8000` of `joypadCurrent` (`global_ambient_dispatcher.asm:13,105`), which this build feeds from the **A** button (`transforms.json:755-758`, `system_init.asm:230-233`: `remapA = $8080`, `remapB = $4008`). The `B cancel` wording at `jeweler_gem.asm:21,133,137` and `debug_man.asm:58` is correct for this build (`MenuSelectionHandler.asm:12` names bit `$4000` "B"; `remapB = $4008` includes it). Fix: `merge` spec: say "the interact button (A in this build)" in the two places. Step: F07.

**A04-05** (VERIFIED, class 11 and 3). `EnemyDefeatDispatch.asm:10` calls `$12 |= $1000` a "priority boost on the flash". Bit `$1000` of `$12` is the display / overlay-active qualifier that lets an actor run in the display-filtered modes (`camera_scroll_controller.asm:5`, `camera_drift.asm:14` for `CameraDriftLoopShip`, `hit_stagger_controller.asm:5` "`$12` (without `$1000`)"), not a draw priority. Stale "priority" wording for the same bit was found earlier in `combat_collision.asm` at lines 49, 430, 686, 821 and 1409 (VERIFIED earlier in this step; outside the I041..I050 file set, pass to A09 / the owner of that file). Fix: `merge` spec for `EnemyDefeatDispatch.asm:10` ("the `$12` bit `$1000` display-filter flag is not set on the flash") and the part note (REPORTED). Step: F07.

**A04-06** (VERIFIED, class 3 and 7). `mode7_perspective.asm:5` says bit 2 puts the thinker "into `RunThinkers_TypeB`" and `:52` names "buffers of `parallax_thinker`". The live runner is `RunThinkers_Hdma` (`thinker_execution.asm:34,199`; names `bank03.json:332`); `RunThinkers_TypeB_Next` survives only as a sub-label name (`bank03.json:333`, `thinker_execution.asm:211-227`). `parallax_thinker` exists nowhere in `db-us/`, `extracted/` (other than this line) or `docs/`. `notes/blockNotes/bank03.json` carries the same text (rg hit, 1 line). The note also carries OQ ids at `:52,53,84` (class 7) and "The old notes said 'repeat'" at `:48` (class 4). This is the A03-12 hand-over. Fix: `merge` spec (block note and the `:84` comment); the sub-label `RunThinkers_TypeB_Next` is a separate `names` decision (class 10; it is the one remaining retired name in this family). Step: F07, F06.

**A04-07** (VERIFIED, class 6). `dialog_string_scanner.asm:79` ("`$0100` = scan offset after this hit") and the block note `:9` ("`$0100` = the scan offset after a hit"): `$0100` is the hit offset **+ 1** (the offset of the `$BF` signature byte; `INY` at `:76` runs before `TYA / STA $0100`). The resume offset is hit + 4 (the pushed `Y`). Fix: `merge` spec: "hit offset + 1". Step: F07.

**A04-08** (VERIFIED, class 4). History narration is still present: **68 lines in 26 of the 30 swept files** (`rg -i '\b(old|older|formerly|previously|earlier version|used to|was wrong|originally)\b'`; one line can hold several mentions). Clean files: `hidden_red_jewel`, `inventory_statue_slot`, `reward_actors`, `shadow_shimmer`. Largest: `global_ambient_dispatcher.asm` 12 (`:1,9,14,15,18,115,123,138,154,170,186,412`), `player_move_main.asm` 10 (`:5,11,14,18,27,31,295,302,318,329`), `ApplyPlayerHitstun.asm` 4 (`:1,8,12,24`), `unused_particle_rain_spawner.asm` 3-4 (`:1,5,11`), `hit_stagger_controller.asm` 3 (`:5,10,301`), `gold_ship_wreck_palette.asm` 3 (`:1,13,17`), `inventory_mgmt.asm` 3 (`:13,150,186`), `player_move_controller.asm` 3 (`:10,66,75`), `dialog_string_scanner.asm` 3 (`:3,5,7`). Retired names kept as prose: `EnemyDropSystem.asm:1` (`DarkGemDropSystem`, `SpawnDarkGemType1`), `gold_ship_wreck_palette.asm:1` (`incan_ruins_transform_palette`), `hit_switch.asm:1` (`floor_button`), `DamageNumberShort_unused.asm:1` (`AttackTrailShort_unused`), `hit_stagger_controller.asm:5,301` (`HitStaggerReturnAI`), `statue_inventory_reward.asm:210` (old wrong-tab label), the same text in 8 `notes/` lines, and `docs/code/bank00/functions-combat-defeat.md:256`. Fix: `merge` specs removing the narration clauses and keeping the technical content, batched with A04-09 and the A03-10 list. Step: F07.

**A04-09** (VERIFIED, class 7). OQ ids in shipped text: **32 lines in 18 of the 30 files** (OQ-I041..I050 plus one OQ-I030-1): `overworld_exit.asm` 6 (`:37,38,39,141,163,193`), `player_move_main.asm` 3 (`:14,99,108`), `mode7_perspective.asm` 3 (`:52,53,84`), `camera_scroll_controller.asm` 2 (`:14,125`), `camera_drift.asm` 2 (`:9,116`), `EnemyDefeatDispatch.asm` 2 (`:12,34`), `EnemyDropSystem.asm` 2 (`:10,44`), `SpawnItemSparkleEffect.asm` 2 (`:5,12`), and one each in `hidden_red_jewel.asm:36`, `hit_stagger_controller.asm:15`, `hit_switch.asm:25`, `shadow_shimmer.asm:11` (two ids, one of them OQ-I030-1), `town_door.asm:7`, `unused_particle_rain_spawner.asm:12`, `ApplyPlayerHitstun.asm:9`, `SpawnDamageNumberEffect.asm:19`, `inventory_mgmt.asm:151`, `gold_ship_wreck_palette.asm:19`. `notes/` holds the same text (28 lines in 9 files: `comments/bank00` 6, `blockNotes/bank00` 12, `blockNotes/bank02` 2, `blockNotes/bank03` 1, `comments/bank02` 2, `comments/bank03` 2, `comments/bank0A` 1, `blockNotes/bank0A` 1, `blockNotes/bank0B` 1). `docs/` has none. Out of range but seen: `tables/scene_meta.asm:19` cites `R-I065-6`. Fix: `merge` specs replacing each id by the plain open-question statement (the OQ document keeps the id). Step: F07.

**A04-10** (VERIFIED, class 9). The Q5 mnemonic proposals are all still open; the bare operands are live: `$0D60` (27 sites, `overworld_exit.asm`), `$0B16` / `$0B1C` (`jeweler_gem.asm:312,323`), `$0B08` / `$0B0C` / `$0B10` (`statue_inventory_reward.asm:168,174,182`), `$09EE` (`global_ambient_dispatcher.asm:126,404,423,431`), `$0404` / `$0405` (RAM MVN stub bytes, `:257,260,325`), `$0DB8` / `$0DB9` (`inventory_mgmt.asm:214,215,233,234`), `$0100` / `$0102` (`dialog_string_scanner.asm:79,81`), `$7F0011` / `$7F0013` (`ApplyOrbitalOffsetXY.asm:50,60`), `$00B6 / $00B8 / $00BC / $00CA / $00CC` (11 lines in `mode7_perspective.asm`). None has a `!name` alias line anywhere in `extracted/` (`rg '^!\w+\s+(0B16|0B1C|0D60|09EE|0B08|0B0C|0B10|0DB8|0DB9)'` → no hit). Fix: user-owned mnemonic decisions. Step: A14, F06.

**A04-11** (VERIFIED, process). The I041..I050 rename pass used throwaway scripts that today's `no-adhoc-scripts` rule forbids for bulk edits of names, notes, `blocks.json` and docs: the apply summary §5 lists them and they exist untracked in `temp/` (`mkmap.mjs`, `apply-rename-I041-I050.mjs`, `chk.mjs`, `mkspec.mjs`, plus `edits-I041-I050.json`; `git status` shows them as `??`). The names files are valid (`npm run names -- --check` OK, 3510 names), so there is no data defect; the risk is process only. Also `artifacts/crc.json` currently reads checksum 222967024, crc -1004081563, size 3062189 (differs from the gate 223006080 / 2083230829 / 3062204; `git diff --stat` shows `artifacts/*` modified). This matches the plain-vs-tagged build issue (report G-1 / T01); no rebuild was run in this step, so the cause is not investigated. Fix: user decision on deleting `temp/*.mjs`; T01 decides the gate. Step: T01.

**A04-12** (informational, class 12). No note or comment of the 30 swept files sits between the two lines of a multi-line transform regex: the only transform keyed to a swept block is `statue_inventory_reward` (`transforms.json:553-555`), whose regex spans `LDA #$FFF0` (plus its trailing comment) and the next-line `TSB $joypadMaskStd`; in the extracted file `StatueRewardEntry:` and its part note come **before** the `LDA` (`statue_inventory_reward.asm:61-65`), so nothing sits between the two lines. The inline comment on the `LDA` line is allowed by the `[^\r\n]*` group. See §9.

**A04-13** (informational). No other defect found in the sampled facts: all other 27 of 34 checks agree with the live code, including the `ApplyPlayerHitstun` / `EnemyDropSystem` / `hit_stagger_controller` / `player_move_*` / `inventory_mgmt` core claims, the Flags10 meanings (`$0008`, `$0080`, `$0400`, `$0040`) and the stat-byte statement after I051's correction.

---

## 6. WaitByte n vs n + 1 sweep

Runner semantics (VERIFIED): `actor_execution.asm:144,180,265,301,…` decrement the wait counter `$08` and run the script when it is negative, so a stored value `n` skips n passes and runs on pass n + 1.

`rg 'WaitByte|WaitFrames|WaitTicks|\[Wait'` plus `rg 'STA \$08\b|\$08 :='` over the 30 files:

| Site | Text | Verdict |
|---|---|---|
| `hit_switch.asm:75` + `:10` + part note | "Hold for `$0F` frames" | **WRONG**, 16 ticks (A04-02) |
| `npc_wander_ai.asm:14,100,106` | `$08 := $78` = 120 frames | **WRONG**, 121 ticks (A04-03) |
| `camera_drift.asm:21,89,171` | `$08 := 3` = 3 frames | **WRONG**, 4 ticks (A04-03) |
| `hit_stagger_controller.asm:10` | `WaitByte #$0F (16 ticks)` | CORRECT |
| `unused_particle_rain_spawner.asm:5` | "N + 1 ticks (see WaitByte)" | CORRECT |
| `statue_inventory_reward.asm:23,147` | `WaitByte #0F`, no tick count | no claim |
| `town_door.asm:27` | `WaitWhileOffscreen ( #0A )` "every 10 passes" | different op; not checked against its handler (REPORTED) |
| `EnemyDefeatDispatch.asm:10` | "no WaitByte" | no claim |
| `hit_stagger_controller.asm:261,274`, `shadow_shimmer.asm:41,59,91` | `STA $0008,X/Y` with value `#$0000` ("run at once") | CORRECT (zero = next pass) |
| `shadow_shimmer.asm` / `global_ambient_dispatcher.asm` / `SpawnItemSparkleEffect` | "wait 2 each" for palette strips | PaletteStep wait semantics not checked (needs `cop_handlers` palette handler); REPORTED |

The sanity pass reported none of the three wrong sites. Result: 3 files with wrong tick counts.

---

## 7. One-comment-per-instruction check (10 files)

Pattern: `rg -U '(^[ ]{2,}[A-Z]{3}[^;\n]*;[^\n]*\n){5,}'` (five or more consecutive instruction lines each with a trailing comment) over all 30 files: **1 hit**, `jeweler_gem.asm:268-272` (`JewelerRewardHerb`, five different COP / JMP lines, each comment adds information). Commented fraction of instruction lines (`rg -c`), 10 files: `player_move_controller` 49/193 (25%), `player_move_main` 39/200 (20%), `hit_stagger_controller` 49/214 (23%), `ApplyPlayerHitstun` 16/53 (30%), `jeweler_gem` 73/152 (48%), `camera_drift` 19/104 (18%), `inventory_mgmt` 42/143 (29%), `dialog_string_scanner` 19/60 (32%), `reward_actors` 20/62 (32%), `mode7_perspective` 48/265 (18%). The one-comment-per-instruction pattern is **gone** from I041..I050.

One cosmetic point: `jeweler_gem.asm:268` quotes the string as `"You've collected more than three!"`; the string is `[CLR]You've collected more than [N]three Jewels![FIN]According to the list,…` (`dialogstring_08D2D0`): the comment is a paraphrase in quote marks (class 6, trivial; batch with F07).

---

## 8. Defect-class sweep (classes 1-13, 30 files)

| Class | Result |
|---|---|
| 1 Purpose guessed from a label | No new case. Hedges ("assumed", "probably", "UNVERIFIED-RUNTIME", "not viewed") are explicit in `hit_switch.asm:10,70`, `unused_particle_rain_spawner.asm:5`, `statue_inventory_reward.asm:19`. Not enumerated further |
| 2 `WaitByte(n)` as n ticks | 3 files, 5 sites (A04-02, A04-03; §6) |
| 3 Comment or note not updated | A04-01, A04-05, A04-06 (stale names, stale reachability, stale bit vocabulary) |
| 4 History narration | 68 lines in 26 of 30 files (A04-08) |
| 5 Handler / opcode table text of another row | No case found in the sampled files (`debug_man` menu tables and `drop_threshold_by_hp` rows checked against their notes) |
| 6 Inline comment contradicting code | A04-07 (`$0100`); `jeweler_gem.asm:268` paraphrase in quotes (§7) |
| 7 OQ / R ids in note text | 32 lines in 18 files in `extracted/`, 28 in `notes/` (A04-09); one `R-I065-6` out of range |
| 8 Hidden sprite groups as extra sub-sprites | Not applicable: none of the 30 files is a sprite file; I041..I050 touched no `.sprite.asm` |
| 9 Unnamed fixed-address operands | 10 address families, none aliased (A04-10) |
| 10 Retired nickname in a name | `RunThinkers_TypeB_Next` (A04-06); retired names kept only as prose in 8+8+1 lines (A04-08). `DarkGem*`, `floor_button`, `incan_ruins_*`, `AttackTrail*`, `SpawnHitSpark*` do not occur as labels |
| 11 Wrong flag bit / register / branch | A04-05 (`$12` bit `$1000`), A04-01 (reachability). Checked and correct: Flags10 `$0008/$0080/$0400/$0040`, `$AA` bits, `playerFlags $0A00`, `M7SEL`, the BCD thresholds, the HP-tier branch (`BCC` after `CMP playerHp`), `BVC` after the 8-bit and 16-bit adds |
| 12 Note inside a multi-line transform regex | none in the swept files (A04-12; §9) |
| 13 Button vocabulary | 1 case: `jeweler_gem.asm:5,55` (A04-04). `global_ambient_dispatcher.asm:13,105` is correct; `town_door.asm` says "Up", not a button; `debug_man.asm:58` and `jeweler_gem.asm:21,133,137` "B cancel" is correct for this build |

---

## 9. Transform-adjacency inventory (class 12)

| Block with a rule in `transforms.json` | Rule | Adjacent notes / comments |
|---|---|---|
| `statue_inventory_reward` (`transforms.json:553-555`) | `LDA #\$FFF0([^\r\n]*\s+T[SR]B \$joypadMaskStd)` → `LDA #$$FFFC$1` (two lines: the `LDA` line with its own trailing comment, then the `TSB` line) | `StatueRewardEntry:` label and its part note are above the `LDA`; nothing between `LDA` and `TSB`. **Safe** (VERIFIED) |

No other swept block name appears in `transforms.json` (`rg` for all 30 block names: 1 hit). Joypad remap rewrites at `transforms.json:755-758` are keyed to `system_init` (not in the swept set).

Tagged-build caveat (REPORTED from report G-1): the rule above has no optional `; {n}` tag group, so it does not match in the `extract:lt` build.

---

## 10. Not verified / needs Mesen2

No Mesen2 ROM or state exists; everything here is static. Not verified:
- Runtime behaviour of all 53 OQ-I041..I050 questions (§3). In particular: whether the town door re-entry pattern opens a door without the Up hold (OQ-I043-1), the visible number of confetti bursts (OQ-I048-3), the drop distribution in play (OQ-I049-6), `Y == $2D0` reachability (OQ-I042-5), reachability of `debug_man`, `dialog_string_scanner`, `unused_particle_rain_spawner` through unlabelled pointer data (CDL).
- `M7SEL` bit semantics were not re-read in the nesdev / sfcwiki corpus (E4 REPORTED).
- Palette-strip waits ("wait 2 each") depend on the `PaletteStep` handler, not checked for n vs n + 1.
- `town_door.asm:27` `WaitWhileOffscreen ( #0A )` "every 10 passes" not checked against its handler.
- The `edits/*.json` specs and `apply-I041-I050_map.json` (beyond the pair list) were not read; the count "164 pairs" is REPORTED.
- Mnemonic rows R-I045-3, R-I046-4/5, R-I047-3, R-I050-2 were not re-grepped (REPORTED).
- Docs rows (R-I041-5 … R-I050-5, D-S4150-2) are REPORTED from the apply summary; the docs were not re-read except `functions-combat-defeat.md:256` and `player-movement.md:68`.
- The `artifacts/crc.json` mismatch (A04-11) was not investigated (no rebuild in this step).

---

## 11. Items for the fix specs (F-step ids)

| Item | Target | Step |
|---|---|---|
| A04-01 | `SpawnItemSparkleEffect.asm:1,5,12` (block note + part notes + comment): reachable through `EnemyDropSystem` heal pickup, sparkle at the pickup actor, drop OQ ids and old-text sentence | F07 |
| A04-02 | `hit_switch.asm:10,75` + part note `HitSwitchTriggered`: "16 ticks" | F02 (extend target list) |
| A04-03 | `npc_wander_ai.asm:14,100,106` (121 ticks); `camera_drift.asm:21,89,171` (4 ticks apart, 8-tick span) | F02 |
| A04-04 | `jeweler_gem.asm:5,55`: "interact button (A in this build)" | F07 |
| A04-05 | `EnemyDefeatDispatch.asm:10` (+ part note): `$12` bit `$1000` = display-filter qualifier; also `combat_collision.asm:49,430,686,821,1409` "priority" wording (other owner) | F07 |
| A04-06 | `mode7_perspective.asm:5,48,52,53,84` + `notes/blockNotes/bank03.json`: `RunThinkers_Hdma`, drop `parallax_thinker`, ids, history; `RunThinkers_TypeB_Next` rename decision | F07, F06 |
| A04-07 | `dialog_string_scanner.asm:9,79`: "`$0100` = hit offset + 1" | F07 |
| A04-08 | 68 history lines, 26 files (list in A04-08) | F07 |
| A04-09 | 32 `extracted/` lines + 28 `notes/` lines with OQ ids | F07 |
| A04-10 | 10 mnemonic families | A14, F06 |
| A04-11 | `temp/*.mjs`; `artifacts/crc.json` vs the gate | T01 / user |
| Hand-over | `combat_collision.asm` "priority" wording; `scene_meta.asm:19` `R-I065-6` | A09 / A06 |

---

## 12. Counts

- Files read as ledgers: 10 results + 1 sanity results + 10 renames + 1 sanity renames + plan + summary + 10 questions + 1 sanity questions + PLAN / report / digest. Live files opened or grepped: 30 swept + 8 others.
- Rename rows: **56** (+ 2 sanity rows): **APPLIED 41** (R-I041-1,2,5; I042-1,2,3,5; I043-1,2,5; I044-1,2,5; I045-1,2,4,5,6,7; I046-1,2,3,6,7; I047-1,2,4,5,6; I048-1,2,5; I049-1,2,3,4,5,6; I050-3,4,5), **PROPOSED 14** (R-I041-3,4; I042-4; I043-3; I044-3,4; I045-3; I046-4,5; I047-3; I048-3,4; I050-1,2), **DROPPED 1** (R-I043-4), **SUPERSEDED 0**. 41 + 14 + 1 = 56.
- Of the 41 APPLIED rows, 29 are VERIFIED live (name rows); 12 are REPORTED (docs rows, note rows, and R-I045-5, the single `ApplyOrbitalOffsetFromRef_AddToCurrent` name). Of the 14 PROPOSED rows, 8 are VERIFIED still open (R-I041-3, I042-4, I043-3, I044-3, I044-4, I048-3, I048-4, I050-1) and 6 are REPORTED.
- Q5 rows: 30 (14 M, all PROPOSED; 16 NA, NOFIX).
- OQ ids: 53; answered later by id 0; topical partial 1; static evidence found 5.
- Fact re-checks: 34 over 22 files: 27 correct, 1 ledger statement wrong and already corrected, 6 live defects.
- Findings: 13 (A04-01 … A04-13): 11 VERIFIED defects or process items, 2 informational.
- Sweeps: WaitByte 3 wrong files / 5 sites; history 68 lines in 26 files; OQ ids 32 lines in 18 files (+28 in `notes/`); unnamed operand families 10; one-comment-per-instruction runs 1 (acceptable); class 12 none; class 13 one.
- Edits made: none (only `A04_findings.md` and the A04 row of `PLAN.md`).
