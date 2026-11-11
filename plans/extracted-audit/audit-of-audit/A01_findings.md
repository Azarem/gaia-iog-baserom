# A01 findings — I001–I020 row status, OQ registry, 25 fact re-checks

Step: A01 (audit-of-audit). Date of the live checks: 2026-10-29. No notes, names, db files or docs were edited in this step.

Evidence rules used here: every claim is **static** (E1 code trace, E2 cross-reference, E3 docs, E4 hardware docs). No Mesen2 ROM or state exists, so no E5 evidence was gathered. Tags: **VERIFIED** = checked in live files this session (file:line given); **REPORTED** = taken from a ledger and not re-checked.

---

## 1. Scope and files read

Plan and ledgers:
- `audit-of-audit/PLAN.md` (A01 prompt, defect classes 1–13, F-step list), `report.md` (v2), `digest_I001-I020.md` (and the I021–I040 / I041–I072 digests for orientation).
- `renames/I001-I020_rename-proposals.md` (96 rows), `renames/apply-I001-I020_summary.md`, `renames/apply-I001-I020_plan.md`.
- `questions/I001-I020_open-questions.md` (OQ-1…OQ-69). Later question files and results files I021–I072 were searched with `rg` for answers to OQ-1…OQ-69 (not read in full).
- `results/I001-I020_results.md` (read in full), `results/I001-I020_sanity-check.md`.

Live files used for checks (all under `gaia-iog-baserom`):
- `extracted/system/engine/`: `scene_script`, `scene_lifecycle`, `tile_collision_physics`, `combat_collision`, `actor_execution`, `camera_tilemap`, `vblank_joypad`, `sprite_composition`, `hardware_math`, `cop_dispatch`, `cop_handlers_audio`, `cop_handlers_offscreen`, `cop_handlers_actor_flags`, `cop_handlers_script_control`, `cop_handlers_player_query`, `GetPlayerFacingDirection`, `GlobalInputHandler`, `DialogStringRenderer`, `radar_map_screen`, `warps_interaction`, `forced_walk` and the other I001–I020 files for the grep sweeps (60 files).
- `extracted/functions/SpawnFieldRevealEffect.asm`, `StandardEnemyDefeatHandler.asm`; `extracted/tables/scene_chest_table.asm`, `walk_step_table.asm`; `extracted/diary_menu/sFA_diary_menu.asm`.
- `db-us/names/bank00–03.json`, `db-us/blocks.json`, `db-us/mnemonics.json`, `db-us/copdef.json`, `db-us/transforms.json`.
- Docs: `docs/wram-memory-map.md`, `docs/structs-reference.md`, `docs/bank01-data-tables.md`, `docs/code/bank02/scene-script.md`, `docs/code/bank03/movement-and-collision.md`, `docs/code/bank03/text-and-menus.md`, `docs/code/bank00/system-core.md`, `docs/code/bank00/data-tables-memory.md`, `docs/cop/families/{input,collision_branch,hdma_dma,force_move,vram_memory,sine_hdma,dialog,audio,script_control}.md`, `docs/audio/spc-disassembly.md`.

Discrepancy: the A01 prompt says "rows 1..90"; the ledger has **96 rows** (rows 91–96 were added by I019/I020). All 96 are in the table below.

---

## 2. Rename-proposal rows 1–96: status

Status codes: APPLIED (done in `db-us/names`, `blocks.json`, extracted text or docs), PROPOSED (still open), SUPERSEDED, DROPPED. "partial" = part of the row was done.
For APPLIED name rows, the old name is absent from `db-us`, `extracted`, `baserom`, `src` (VERIFIED by `rg -w` over all old names: no hit) and the new name is present in `db-us/names/bank00–03.json` or `blocks.json` (VERIFIED).

| # | Status | Tag | Evidence |
|---|--------|-----|----------|
| 1 | APPLIED | VERIFIED | `BuildMetatileFlagTable` at 167885 (bank02) |
| 2 | APPLIED | VERIFIED | `RebuildCollisionLayer` in names; old name absent |
| 3 | APPLIED | VERIFIED | `FillCollisionFromLayer0` / `OverlayCollisionFromLayer1` |
| 4 | APPLIED (variant) | VERIFIED | `SceneCmd_Default` at 164956, not `SceneCmd_Noop` (summary §3 records the deviation) |
| 5 | APPLIED | VERIFIED | `InterleaveTilesPriority` |
| 6 | APPLIED | VERIFIED | `WaitStoreAndYield` at 44233 |
| 7 | PROPOSED | VERIFIED | `animScratch` still `mnemonics.json:232` (OQ-2) |
| 8 | DROPPED | VERIFIED | conditional on the extractor substituting DP operands; not true today; `collisionLayerBase` stays a doc-only name (`wram-memory-map.md:142`) |
| 9 | PROPOSED | VERIFIED | `wram-memory-map.md:207` still says `gfxLoadParams` |
| 10 | PROPOSED | VERIFIED | `structs-reference.md:824` still "+5 tilemapAddr" |
| 11 | PROPOSED | VERIFIED | `docs/code/bank02/scene-script.md:234` still "cached source pointer at `$06AA`" |
| 12 | PROPOSED | REPORTED | the six orphan block-note names are not listed in the ledger; not checked |
| 13 | APPLIED | VERIFIED | `ApplyHitDamageToVictim` at 245543 |
| 14 | APPLIED | VERIFIED | `HitInvincibleVictim` |
| 15 | PROPOSED | VERIFIED | `bank01-data-tables.md:341-343` music table still has an "ID" column with no index+1 note |
| 16 | PROPOSED | VERIFIED | `movement-and-collision.md:251, 314-315` still use `previousDamage($09E2)` |
| 17 | PROPOSED | REPORTED | waits for OQ-8 |
| 18 | APPLIED | VERIFIED | `slope_curve_table` (blocks.json + names) |
| 19 | APPLIED | VERIFIED | `signed_cosine_table_8bit` |
| 20 | APPLIED | VERIFIED | `neg_sine_halfwave_16bit` |
| 21 | APPLIED | VERIFIED | `cosine_table_16bit_tail` |
| 22 | PROPOSED | VERIFIED | `actorLimitThreshold` still `mnemonics.json:7` |
| 23 | PROPOSED | VERIFIED | `gfxCacheIdxA/B` still `mnemonics.json:22-25` |
| 24 | PROPOSED | REPORTED | cosmetic `loc_*` loop labels; summary §7 says not applied |
| 25 | APPLIED (partial) | VERIFIED + REPORTED | no "VRAM command queue" string left in `docs/`; the sine/cosine doc rows are REPORTED by the apply summary §5 |
| 26 | APPLIED | VERIFIED | `AdvanceTileOffsetY/X` in names; but see finding F2 (stale sentence at `tile_collision_physics.asm:32`) |
| 27 | PROPOSED | VERIFIED | `deathActionIdx` still `mnemonics.json:251` |
| 28 | PROPOSED | VERIFIED | `iframeCounter` still `mnemonics.json:253` |
| 29 | PROPOSED | VERIFIED (absence) | `wram-memory-map.md` has no `$0D5E` line, so nothing is marked unused |
| 30 | APPLIED (partial) | VERIFIED + REPORTED | strings "scene IDs and companion bytes" and "sprite tileset" are gone from `extracted/`; the `wram-memory-map.md` `$0D52-$0D5E` part is REPORTED |
| 31 | PROPOSED | VERIFIED | `wram-memory-map.md:358` still "16 item words" for `$0AB4–$0AD2` (31 bytes) |
| 32 | PROPOSED | VERIFIED | `blocks.json:39` is still `cop_handlers_actor_flags` |
| 33 | PROPOSED | VERIFIED | `copdef.json:100` still `BranchIfCollisionTypeNe` (id 98 = `$62`); the handler branches on EQUAL (V02) |
| 34 | APPLIED | VERIFIED | `BranchIfSolidType*` labels; no old label left |
| 35 | APPLIED | VERIFIED | `GetPlayerFacing_BaseBodyFallback` |
| 36 | APPLIED | VERIFIED | `FacingData_WillAlt/AbilityFx/FreedanFx/ShadowFx` at 258431–258506 (name drift is a separate F03 item) |
| 37 | PROPOSED | VERIFIED | `scratch1010+6` still `mnemonics.json:278` |
| 38 | PROPOSED | VERIFIED | `blocks.json:156` still `hdma_ramp_tables` |
| 39 | APPLIED | VERIFIED | `ramp_curve_arc_64` present; the summary lists `ramp_curve_arc_32` too |
| 40 | PROPOSED (partial) | VERIFIED | `collision_branch.md:24, 416` still say the handler is in `cop_handlers_metatile.asm`; the `BranchOnPlayerFacing` comment is fixed (V04); the other sub-items are REPORTED |
| 41 | APPLIED | VERIFIED | `PlaceOpenedChestTiles` |
| 42 | APPLIED | VERIFIED | block `scene_chest_table`; `scene_chest_table.asm:1` header corrected (but it narrates the old note: F11) |
| 43 | APPLIED | VERIFIED | `ExecuteForcedWalkWarp` |
| 44 | PROPOSED | VERIFIED | `copdef.json:4` still `QueueDma` |
| 45 | PROPOSED (partial) | VERIFIED | `hdma_dma.md:9, 139` still "linear DMA"; the other sub-items are REPORTED |
| 46 | PROPOSED | VERIFIED | `warpFacing` / `warpScrollParams` still `mnemonics.json:28-30` |
| 47 | APPLIED | VERIFIED | `ConsoleCmd_NewLine` / `ConsoleCmd_DoubleNewLine` |
| 48 | APPLIED | VERIFIED | `ConsoleCmd_InsertSharedWord`, `shared_word_table` (`blocks.json:1034`) |
| 49 | PROPOSED | VERIFIED | `sceneStateHelper` still `mnemonics.json:133` |
| 50 | APPLIED | VERIFIED | `text-and-menus.md:303, 307` now say 2 rows / 1 row |
| 51 | PROPOSED | REPORTED | not reviewed in the ledger; `cop-commands-reference.md:526, 1212` unchanged |
| 52 | APPLIED | VERIFIED | `StandardEnemyDefeatHandler.asm:15` rewritten (history narration: F11) |
| 53 | APPLIED | VERIFIED | `ComposeDigitSprites_AtCursor` (`oam_digit_compose.asm:45`, `sFA_diary_menu.asm:1965`) |
| 54 | PROPOSED | VERIFIED | `deathFlag` still `mnemonics.json:9`; the doc statement in `docs/` is gone (no `deathFlag` in `docs/`) |
| 55 | APPLIED | VERIFIED | `RenderColumnStrip`, `RenderRowStrip`, `DmaColumnStrip`, `DmaRowStrip` |
| 56 | APPLIED | VERIFIED | `Bg3TilemapVramDma` at 176184; behaviour confirmed (V10) |
| 57 | APPLIED | VERIFIED | `SetSpritePriority` / `SetSpritePalette` |
| 58 | APPLIED (partial) | VERIFIED + REPORTED | `deathFlag` text is gone from docs; the other sub-items are REPORTED |
| 59 | APPLIED | VERIFIED (absence) | "up to 8 entries", "status cache vars", "Start ($4000)" not found in `extracted/` |
| 60 | APPLIED | VERIFIED (absence) | `SpriteVramDma` and "sprite VRAM tiles" gone from `docs/` and `extracted/system` |
| 61 | APPLIED | VERIFIED | `SpawnFieldRevealEffect.asm:15` rewritten (history narration: F11) |
| 62 | PROPOSED | VERIFIED | (b): `GlobalInputHandler.asm:114` still consumes `$6000` (V19). (a): the `MenuSelectionHandler` transform artefact was handled by hand later (REPORTED, digest) |
| 63 | PROPOSED | REPORTED | deferred mnemonic candidates |
| 64 | APPLIED (partial) | VERIFIED | `FollowChaseHead*`, `Apply*`, `Dx/DyNegative*` done; `FollowChaseDiagQuadrant*` (`names/bank00.json:805-808`) and `ResolveFollowDir*` (`:862-864`) not |
| 65 | DROPPED | REPORTED | the row itself says "do not rename" (contextual aliases only) |
| 66 | APPLIED (partial) | VERIFIED + REPORTED | `FollowSlopeDitherTable` named; the `visual_effect_pipeline` comment and doc parts are REPORTED |
| 67 | APPLIED (partial) | VERIFIED | `MusicJingleActor` (172096) and the five sub-labels done; `musicParentActor` still `mnemonics.json:1778` |
| 68 | PROPOSED | VERIFIED | `copdef.json:157-161` (`ForceDir*`, `ReloadMoveDurations`), `mnemonics.json:245-246` unchanged |
| 69 | PROPOSED | VERIFIED | `force_move.md:9, 19, 20` still "frame durations" / "force SW/NE" |
| 70 | PROPOSED | VERIFIED | `sine_hdma.md:55` still "scanline count" |
| 71 | PROPOSED | VERIFIED | `vram_memory.md:111` still "Source bank forced to `$7F`" |
| 72 | APPLIED | VERIFIED | `DieExit` (42504), `UnlinkChildrenCascade` (42510) |
| 73 | APPLIED | VERIFIED | `OamFillE0_unused` (33848), `OamFillConstant_unused` (33900) |
| 74 | APPLIED | VERIFIED | `MainLoop` (32949), `UpdateHUD_Active` (33294) |
| 75 | PROPOSED | VERIFIED | `playerStateByte` still `mnemonics.json:142` |
| 76 | PROPOSED | REPORTED | contextual bit aliases (comments/docs); not checked |
| 77 | PROPOSED | VERIFIED | `system-core.md:36` "music handshake from NMI"; `data-tables-memory.md:415` `$0B28–$0B32` "Save/warp metadata"; `dialog.md:18, 53, 57, 119` "dialogue mode", "inventory input" |
| 78 | PROPOSED | VERIFIED | `copdef.json:36, 84` `MoveToward` / `StageMove` operands unchanged |
| 79 | PROPOSED | VERIFIED | `rngState` still `mnemonics.json:14` (key 1039) |
| 80 | PROPOSED | REPORTED | comments only; not checked |
| 81 | PROPOSED | REPORTED | docs/`scene_actors` comments; not checked |
| 82 | APPLIED | VERIFIED | `CopyEventBlockTiles` (172576); no `SwapEventBlockTiles` in `docs/` |
| 83 | PROPOSED | VERIFIED | `tileQueryResult` still `mnemonics.json:131` |
| 84 | APPLIED | VERIFIED | `Multiply8x8Unsigned` (`blocks.json:79`, `hardware_math.asm`); no `SignedMultiply` in `docs/` |
| 85 | APPLIED | VERIFIED | `RngStep_Unused` at 164423 |
| 86 | APPLIED (partial) | VERIFIED + REPORTED | `SwapEventBlockTiles` / `SignedMultiply` gone from docs; `audio.md:24` ("fades or waits") and `:105` ("cross-fade") remain and conflict with V18 only in wording; the COP #44/#45 operand order is REPORTED |
| 87 | APPLIED | VERIFIED | `scene_chest_table.asm:1` and `walk_step_table.asm:7` corrected (both narrate the old text: F11) |
| 88 | APPLIED | VERIFIED | `RadarBorderColorTable` |
| 89 | PROPOSED | VERIFIED | `RadarPlotFriendlyActor` / `RadarPlotEnemyActor` still named; `radar_map_screen.asm:343, 371, 416` say "the name is historical" (F14); waits for OQ-63 |
| 90 | PROPOSED | VERIFIED | `loopStartPcActor` / `loopCounterActor` still `mnemonics.json:283-284`; `cop_handlers_script_control.asm:7` cites "rename proposal 90" |
| 91 | APPLIED | VERIFIED | `CardinalToPlayer_Exit` (37424) |
| 92 | SUPERSEDED | VERIFIED | rows 34, 57 and the apply map renamed `BranchIfType*`, `StageSpr*`, `SetOam*`; three labels `StagePlayerSpriteMoveX/Y/XY` still differ from copdef `StagePlayerMoveX/Y/XY` (F5) |
| 93 | PROPOSED | VERIFIED | `SetOnInteract` still in `bank08-native-dao-pyramid-actors.md:124, 127, 193, 250`, `bank0A-dungeon-enemy-actors.md:257`, `actors-player-rewards.md:329`; `script_control.md:53, 65, 103` keep it as a labelled legacy alias |
| 94 | PROPOSED | VERIFIED | `wram-memory-map.md:347` "Cleared by `ClearAllWramFlags` at scene boundaries"; `GlobalInputHandler.asm:26` "scene markers" |
| 95 | PROPOSED | VERIFIED | `TestWramFlag_Offset100` still at 45150 (waits for OQ-68) |
| 96 | PROPOSED | VERIFIED | `BitMaskTable_Wram` still at `actor_execution.asm:1231` / names 250149 |

Row counts: **APPLIED 47** (of which partial or variant: 4, 25, 30, 58, 64, 66, 67, 86), **SUPERSEDED 1** (92), **DROPPED 2** (8, 65), **PROPOSED 46**. Total 96.
PROPOSED rows checked live (still open): 37 (7, 9, 10, 11, 15, 16, 22, 23, 27, 28, 31, 32, 33, 37, 38, 40, 44, 45, 46, 49, 54, 62, 68, 69, 70, 71, 75, 77, 78, 79, 83, 89, 90, 93, 94, 95, 96). PROPOSED rows not checked (REPORTED): 9 (12, 17, 24, 29, 51, 63, 76, 80, 81).

---

## 3. Open questions OQ-1…OQ-69

Source: `questions/I001-I020_open-questions.md` (the only questions file for I001–I020). "Answered later" = a later results/questions file says it answers or closes the question (REPORTED, found by `rg`); "in range" = the same ledger resolves it; "live" = checked in the live file this session.

| OQ | One-line question | Answered later? |
|----|-------------------|-----------------|
| 1 | Why do `LoadBgTiles` modes 0/1 invalidate neighbouring cache slots? | no |
| 2 | Do `$7F0000-$01FF` hold the collision flag tables or the `animScratch` mnemonic block? | no |
| 3 | Meaning of tilemap word bit 9 as a collision flag | no |
| 4 | Why `ReloadMapLayer1` reads `$0080` instead of `$06A0` | no |
| 5 | Are `display_preset_table` records +8/+9 unused? | **yes, I068** (REPORTED: "closes the old OQ-5") |
| 6 | Who sets `$09ED` bit 7? | in range (I012 text: it gates the BG3 upload; the setter is still unknown, see OQ-42) |
| 7 | `inventory_overlay` "Zero `$0673/$0676`" comment is wrong | **fixed, live** (no such string in `inventory_overlay.asm`) |
| 8 | Roles of actor `$10` bits `$0080` / `$0400` in `RunCombatCollision` | no (still cited at `combat_collision.asm:17, 210, 217`) |
| 9 | Which actor is slot `$1000` in the `bonus` test? | no |
| 10 | Is 1-based music-ID indexing intended? What do IDs `$0D`/`$17` select? | no |
| 11 | What reads `slope_curve_table` bytes `$40-$D0`? | no |
| 12 | Are `$7F0200` BG3 buffer and `$7F0600` text/OAM uses mutually exclusive? | no |
| 13 | `LoadPlayerGraphics` skip scenes and MVN bank; consumers of event flag `$FF` | no |
| 14 | Two meanings of `$0D6E`; roles of `$09CC/$09CE`, `$06CC` | partial (`$09CC/$09CE` closed by OQ-40 text; `$0AEC/$0AEE` closed in I005) |
| 15 | `InitActorPool` zeroes `$7F0E00`; what is `$7F3000`? | no (still cited at `actor_execution.asm:702`) |
| 16 | Meaning of collision types `$06` / `$09` | partial (docs list `$06`, `$09` as walls; Mesen2 to confirm; still cited at `tile_collision_physics.asm:57`) |
| 17 | `AllocateSpecialActor` failure, `KillThinker` `$5C`, `$5A` init | no |
| 18 | `$06F0` default actor properties: writer? | no |
| 19 | `BranchIfItemEquipped` with `$FFFF` reads `$0AB3` | no |
| 20 | Does actor `$10` bit 3 mean grounded or player-hit? | no |
| 21 | `hdma_channel_config` bit 7; `parallax_speed_config` entries 03-0C unreadable | in range (bit-7 part resolved in I009; remainder open, see OQ-32) |
| 22 | Facing order: 0=down/up/left/right vs 0=N,E,S,W | **answered statically, live** (V03, V04: handler notes now use 0 down, 1 up, 2 left, 3 right; no later file cites OQ-22) |
| 23 | Who consumes `displayModeFlags` bit 0? | no (`DialogStringRenderer.asm:142` still cites it) |
| 24 | Y-row inconsistency between `TileCollisionQuery` and `MarkCollisionRect` | no |
| 25 | `AdvanceMapY` page-edge case | no |
| 26 | Unchecked index range in `MarkSolidOffset` etc. | no |
| 27 | `PrintNumber` with more than 4 digits; `$00DC` reader | no |
| 28 | Is `$0AC8 - 4` selecting the `FacingData_*` tables at runtime? | no |
| 29 | BGM tracks used by the chest fanfare; is `$06F2` the current music ID? | no |
| 30 | Warp entry byte 9 bit 7 "save warp" | no |
| 31 | `PaletteStep` hold delay calls `DecompressGfxToVram` every frame | no |
| 32 | `SetupHdmaChannel_*` carry after `ASL $68`; `parallax_speed_config` 03-0C | no |
| 33 | `PrintBcdNumber` blank tile `$20`; `ClearColumn` width 0 wrap | no |
| 34 | `DrawBox` cursor end position; `[N]`/`[DBL]` line spacing | no |
| 35 | `ComposeDigits_Continuation` 6 px shift and `$001A` | no |
| 36 | Who sets `layerPriorityFlag` bit 12? | no |
| 37 | Is the map screen a Start toggle? | no |
| 38 | Actor `$10` bit 4 in the `sprite_composition` blink gate | no |
| 39 | `GlobalInputHandler` consumes `$6000` but not `$0008` | no (still true: `GlobalInputHandler.asm:114`) |
| 40 | Actor `$10` bits 0/1 consumers; `STZ $070F` | no (the `$09CC/$09CE` part is closed) |
| 41 | `$069A,X` as map-data wrap modulus | no |
| 42 | Who requests the partial BG3 upload; who sets `hudDisableFlag` bit 7 | no |
| 43 | `ComputeFollowStep` with `loopCounter` 0 or ≥ 16 | no |
| 44 | Why aim 8 px above the target; `chatPtr` bit 15 users | no |
| 45 | `AdhocVramDma` writes trigger before size | no (still cited at `cop_handlers_vram.asm:24`) |
| 46 | `InitGravity` negation of a byte with bit 7 | no |
| 47 | `CameraPanUp/Left` end-of-pan clamp | no |
| 48 | `MusicRenderSync` waits `$48` frames: why? | no |
| 49 | `extract:lt` vs plain `extract` rebuild differs by 15 bytes | no (this is report gate item G-1; no resolution found) |
| 50 | `SystemInit` `$0100` / `$83` warmboot test | no (`system_core.asm:176`) |
| 51 | `displayModeFlags` bit 13 has no reader | no (`cop_handlers_dialog.asm:75`) |
| 52 | `$09BE/$09C0/$09C4` readers | no (`system_core.asm:204`) |
| 53 | `enemyHealthTimer` stores of 25/30 dead? | no (`system_core.asm:462, 476`) |
| 54 | Why do the dialogue COPs clear actor `$10` bit 11? | no (`cop_handlers_dialog.asm:92, 143`) |
| 55 | `StageMove` speed ≥ `$80` extra halve pass | no (`cop_handlers_movement.asm:11`) |
| 56 | `MoveToward` with distance < speed | no (`cop_handlers_movement.asm:5`) |
| 57 | Camera scroll spawn ratios; `forcedScrollOverride` reader | no (`camera_scroll.asm:5, 38, 65, 94`) |
| 58 | `DisplaySceneTitle` centring constant and `$00B4` | no (`DisplaySceneTitle.asm:13`) |
| 59 | transforms rewrite button masks inside note text (`MenuSelectionHandler`) | partial (REPORTED: I024 says the file cannot take notes via merge, corrected notes were prepared by hand) |
| 60 | Actor `$10` bit meanings in audio and forced-walk code | no (cited at `actor_pool.asm:219, 226`, `cop_handlers_audio.asm:46`, `forced_walk.asm:39, 251, 260`) |
| 61 | Is `$F1` on port 0 a fade command? | **yes, I021** (REPORTED; also VERIFIED here: V18) |
| 62 | `QueueVisibleTileVram` flag contract (Z after PLP) | no (`event_blocks.asm:35, 569`; the digest calls it answerable by reading) |
| 63 | Radar icon meanings and colours | no (`radar_map_screen.asm:3, 58, 205, 217, 343, 358, 416`) |
| 64 | Can NMI fire between the `adhocVramDmaDest` and size stores? | **yes, I022** (REPORTED; `radar_map_screen.asm:76` still cites OQ-64 as an "ordering hazard") |
| 65 | Does anything read `$0024` as spawner? | no (`actor_pool.asm:7, 219, 241`) |
| 66 | `UnlinkActor` and `actorListLast` when the list empties | no (`actor_pool.asm:44`) |
| 67 | Lifetime of `wramFlags` | no (cited at `actor_execution.asm:45, 1174`, `flag_helpers.asm:11, 270`, `cop_handlers_dungeon_switch.asm:3, 17`) |
| 68 | `Offset100` flag helpers reach `$0AA0` | no (`flag_helpers.asm:11, 26, 31`) |
| 69 | `SetEntryHere` stray byte in actor `$03`; `LoopStart` count 0 | no (`cop_handlers_script_control.asm:42`) |

OQ counts: **69** total. Answered by a later results/questions file: **3** (OQ-5, OQ-61, OQ-64; REPORTED). Closed otherwise: **2** (OQ-7 fixed live, OQ-22 answered statically live). Resolved in range: **2** (OQ-6, OQ-21; both partial because a remainder stays open). Partial: **3** (OQ-14, OQ-16, OQ-59). Open: **59**.
Check: 3 + 2 + 2 + 3 + 59 = 69.

---

## 4. Re-verification of 25 facts against live code

Result: **18 VERIFIED-CORRECT, 7 VERIFIED-WRONG, 0 CANNOT-CHECK.** The 25 facts span 19 files (one is `db-us/transforms.json`) and 12 of the 13 defect classes (all except class 8, hidden sprite groups, which no sampled fact touched).

| ID | Class | Fact from `results/I001-I020_results.md` | File:line (live) | Verdict |
|----|-------|------------------------------------------|------------------|---------|
| V01 | 11 | `HaltIfMaxFrames` branches with `BCC` after `CMP actorLimitThreshold` (note direction) | `cop_handlers_offscreen.asm:50` and the code | VERIFIED-CORRECT |
| V02 | 11 | `BranchIfBehindWall` / `BranchIfCollisionTypeNe` branch directions in the block notes; the `Ne` handler branches on EQUAL | `cop_handlers_actor_flags.asm` (notes and code) | VERIFIED-CORRECT (the copdef name `BranchIfCollisionTypeNe`, `copdef.json:100`, is still the inverted one; row 33) |
| V03 | 11 | Facing order 0 = down, 1 = up, 2 = left, 3 = right | `GetPlayerFacingDirection.asm` (whole file) | VERIFIED-CORRECT |
| V04 | 11 | `BranchOnPlayerFacing` and `CardinalToPlayer` order notes (0=N,1=E,2=S,3=W is `CardinalToPlayer` only) | `cop_handlers_player_query.asm:10, 305, 504-515` | VERIFIED-CORRECT |
| V05 | 11 | `AdvanceTileOffsetY` adds `$10` to the low byte (carry into `mapRowStrideL0`); `AdvanceTileOffsetX` steps the low nibble, then `+$F0` and `INC` of the high byte | `tile_collision_physics.asm:1108-1156` | VERIFIED-CORRECT |
| V06 | 3 | I006 note: the two names are swapped, "rename proposed" | `tile_collision_physics.asm:32` | **VERIFIED-WRONG**: after row 26 the names match the behaviour; the sentence is false and narrates a rename |
| V07 | 6 | `SpcMusicLoadCmd` inline comment | `scene_script.asm:1303-1306` | **VERIFIED-WRONG**: comment says "same group means music is already loaded"; code is `CMP $06F4 / BEQ loc_028B88 / RTS`, so EQUAL continues to the load path and a mismatch returns. The block note at `:1294` has it right; `:75` ("gates loading to prevent redundant transfers") describes the wrong gate (the redundancy check is `CheckSourceCacheHit` at `:1309`) |
| V08 | 2 | `WaitByte(N)` waits N+1 ticks | `actor_execution.asm:180-182` (`DEC $08 / BPL / STZ $08 / dispatch`, same pattern at 144, 265, 301, 389, 428, 532, 547, 629, 644) | VERIFIED-CORRECT (N passes skipped, then the dispatch tick = N+1) |
| V09 | 2 | `JumpAfterDelay` stores N in `$08` and "actor waits this many frames" | `cop_handlers_script_control.asm:79` | **VERIFIED-WRONG**: the runner of V08 makes it N+1 ticks. Same wording class at `cop_handlers_player_query.asm:112` (COP #27, "delay in frames") |
| V10 | 11 | `Bg3TilemapVramDma`: `$0800` bytes `$7F0200` → VRAM `$7800` (bit 0); `$0140` bytes `$7F0280` → `$7840` (bits 4/5); DMAP0=`$01`, BBAD0=`$18`, VMAIN=`$80`; `hudDisableFlag` bit 7 gates it; TRB `$31` | `camera_tilemap.asm:873-935` | VERIFIED-CORRECT (E1 + E4: 160 words = 5 rows of 32; `$7840 = $7800 + 2 × 32`; `$0280 = $0200 + 2 × $40`) |
| V11 | 11 | `DisableNmiKeepJoypad` writes `$01` to NMITIMEN (NMI off, joypad auto-read on) | `vblank_joypad.asm:45, 284-297`; used at `scene_lifecycle.asm:195` | VERIFIED-CORRECT (E4: bit 7 NMI enable, bit 0 auto-joypad) |
| V12 | 11 | Scroll-wave HDMA: `$FF` = repeat × 127, `$E0` = repeat × 96, second pointer = first + `$FE`, total 223 lines; ch6/ch7 → B-bus `$0D`/`$0F` (BG1HOFS/BG2HOFS) | `scene_lifecycle.asm:498-530` | VERIFIED-CORRECT (E4: `$FF & $7F = 127`, `$E0 & $7F = 96`) |
| V13 | 11 | `playerFlags` bit 3 (`$0008`) = combat lock strips `$0080` from `joypadCurrent`; actor `$10` bit 7 uses a signed iframe counter (positive = DEC, non-player actors skip the tick; negative = INC, tick continues; 0 clears `$0080`) | `actor_execution.asm:113-121, 157-176` | VERIFIED-CORRECT |
| V14 | 6 | Positive counter `$0011` "17 frames of invincibility" | `combat_collision.asm:53`, inline `:905`; contrast `:640` and `actor_execution.asm:105, 157-168` | **VERIFIED-WRONG (inconsistent)**: for a non-player victim the positive counter freezes the whole actor tick (hit-stun); only the player is exempt from the skip (`CPX $playerActor / BEQ`, `actor_execution.asm:165-166`). `:53` and `:905` say "invincibility" without that distinction while `:640` says "victim frozen" without the player exemption. One consistent wording is needed |
| V15 | 11 | Actor `$10` bit 14 (`$4000`) = off-screen flag set/cleared by the depth sort | `sprite_composition.asm:108, 205, 216-217`; `actor_execution.asm:935, 1026` | VERIFIED-CORRECT |
| V16 | 11 | `MulDivide` = (A low × Y) ÷ A high with only the low 16 bits of the product kept; divide-by-0 gives `$FFFF`; `UnsignedDivide` returns quotient low byte + remainder | `hardware_math.asm:3-14, 36-77, 103-121` | VERIFIED-CORRECT (E4: WRDIV 16÷8 → RDDIV, remainder in RDMPY) |
| V17 | 11 | `AND #$EFFF` clears bit 12 (`$1000`) in actor `$10`; `$1000` is the display-filter run flag | `cop_handlers_audio.asm:46-49, 70-78`; `actor_execution.asm:242, 255-258` | VERIFIED-CORRECT |
| V18 | 1 | `FadeThenStartMusic` "fade" is real: `$F1` on APUIO0 is the SPC `CmdFadeOut` | `cop_handlers_audio.asm:3, 59`; `docs/audio/spc-disassembly.md:419-421` (`CMP A,#$f1 / BEQ CmdFadeOut`) | VERIFIED-CORRECT (E2) |
| V19 | 13 | Button bits: A `$0080`, B `$8000`, Y `$4000`, Select `$2000`, Start `$1000`; this ROM's item-use button is logical `$0008` (transform) while the consume constant `$6000` is untouched | `GlobalInputHandler.asm:3, 18-20, 100, 114`; `docs/cop/families/input.md:22-25`; `transforms.json:535-537` | VERIFIED-CORRECT |
| V20 | 13 | `$C040` = `$8000 \| $4000 \| $0040` (confirm, cancel, item-palette), `$0F00` = D-pad | `DialogStringRenderer.asm:46, 192, 839-848` | VERIFIED-CORRECT |
| V21 | 12 | The handler-text transforms (`cop_handlers_audio`, `_palette`, `_effects`, …) use the regex `LDA \$0A … STA \$00 … STA \$02, S` with comment-tolerant groups; `combat_collision` and `actor_execution` rewrite every `$8000` to `$0080` | `transforms.json:16-20, 82-87, 495-499`; live `combat_collision.asm` has no `$8000` text | VERIFIED-CORRECT (no adjacency hazard found in the I001–I020 handler files; the `$8000` rule would rewrite any `$8000` that a note adds) |
| V22 | 9 | Actor pool: 84 slots of `$30` bytes at `$1000–$1FBF`; extended data at `$7F:0000+slot` (= `$7F1000–$7F1FBF`) | `actor_execution.asm:29, 694-696` | VERIFIED-CORRECT (84 × `$30` = `$FC0`) |
| V23 | 3, 5 | `cop_dispatch` note: 19 handler labels differ from copdef names | `cop_dispatch.asm:5, 70` (duplicate in `notes/partNotes/bank00.json:136`) | **VERIFIED-WRONG (stale)**: after rows 34/57 the labels for `$1A–$1E`, `$80–$87`, `$B6/$B7` equal copdef; only `StagePlayerSpriteMoveX/Y/XY` (`$90–$92`) still differ |
| V24 | 10 | Retired nicknames in `GetPlayerFacingDirection` | `GetPlayerFacingDirection.asm:16` (`will_alt`, `ability_fx`, `freedan_fx`, `shadow_fx`) | **VERIFIED-WRONG**: still present (F03 already targets this line) |
| V25 | 4, 7 | `deathActionIdx` "the name is historical"; OQ ids in note text | `actor_execution.asm:43, 45, 702, 1174` | **VERIFIED-WRONG**: history narration and OQ ids still present in four lines |

---

## 5. Mnemonic operand counts (the nine clearly wrong names)

`rg -c` over the whole `extracted/` tree with the pattern `$name` (word end), lines containing the name (comment mentions included):

| Mnemonic | Lines | Files |
|----------|-------|-------|
| `deathFlag` | 5 | 1 |
| `actorLimitThreshold` | 34 | 10 |
| `musicParentActor` | 7 | 5 |
| `sceneStateHelper` | 6 | 3 |
| `deathActionIdx` | 19 | 7 |
| `iframeCounter` | 26 | 8 |
| `scratch1010+6` | 9 | 6 |
| `loopStartPcActor` | 2 | 1 |
| `loopCounterActor` | 3 | 1 |
| **Sum** | **111** | 42 name-file pairs (36 distinct files in the earlier narrower count) |

The digest says "about 107 lines in 37 non-sprite files". The earlier count of this session gave 107 lines in 36 files; the 111 here includes comment mentions. All nine names are still in `db-us/mnemonics.json` (VERIFIED). A rename is byte-neutral and changes every site at once; it belongs to F06 (user-owned file).

---

## 6. Defect-class grep sweep, I001–I020 files only (60 files)

| Sweep | Pattern | Lines | Files | Result |
|-------|---------|-------|-------|--------|
| WaitByte / WaitWord wording | "waits/delay … N frames/ticks", "this many frames" | 8 raw hits | 5 | **2 real hits**: `cop_handlers_script_control.asm:79` (V09), `cop_handlers_player_query.asm:112`. The other six are not WaitByte-related (frame parity in `system_core`, palette animation ticks, `DialogStringRenderer` `$C9 WaitFrames` which is a loop count) |
| History narration | "previously", "formerly", "old header", "historical", "stale name", "rename proposed", "was renamed" | 11 | 6 | **7 real hits**: `actor_execution.asm:43`, `cop_handlers_script_control.asm:23`, `radar_map_screen.asm:343, 371, 416`, `scene_lifecycle.asm:17`, `tile_collision_physics.asm:32`. **4 false positives** (runtime sense): `scene_lifecycle.asm:237`, `scene_script.asm:47, 1317, 1964` |
| OQ-/R- ids and audit references in note text | `OQ-…`, `R-…`, "rename proposal", "audit …" | 54 | 20 | all real (class 7). Includes a path to a frozen ledger in code: `combat_collision.asm:217` (`questions/I001-I020_open-questions.md`); "(see the audit rename proposals)" at `warps_interaction.asm:46`; "(audit rename proposal)" at `cop_handlers_actor_flags.asm:5`; "rename proposal 90" at `cop_handlers_script_control.asm:7`; "audit OQ-15/16/23" at `actor_execution.asm:702`, `tile_collision_physics.asm:57`, `DialogStringRenderer.asm:142`. Per-file counts: `radar_map_screen` 8, `actor_pool` 5, `camera_scroll` 4, `flag_helpers` 4, `system_core` 4, `actor_execution` 3, `combat_collision` 3, `cop_handlers_audio` 3, `cop_handlers_dialog` 3, `forced_walk` 3, 11 files with 1–2 |
| Retired nicknames | `will_alt`, `ability_fx`, `freedan_fx`, `shadow_fx` | 1 | 1 | `GetPlayerFacingDirection.asm:16` (V24) |
| Direction vocabulary (digest gap) | `0=N`, `0 = up` etc. | 5 raw hits | 5 | no remaining clash with `GetPlayerFacingDirection` order; the compass numbering in `cop_handlers_collision.asm:714` is labelled as a different numbering |

---

## 7. Findings

Format: id, tag, file:line, what is wrong, proposed fix, defect class. Fixes are proposals; nothing was edited.

**F1 — VERIFIED — `scene_script.asm:1303` and `:75` (class 6).** The inline comment on `LDA $musicRoomGroup` says "same group means music is already loaded". The code continues to the load path when the groups are equal and returns when they differ (`BEQ loc_028B88 / RTS`). Line 75 says `musicRoomGroup` "gates loading to prevent redundant transfers when re-entering the same music region"; the redundancy gate is `CheckSourceCacheHit` on `$0687` (`:1308-1310`). The operand `$06F4` (the script's group byte, stored at `:1300`) is also an unnamed fixed address (class 9). Fix: reword both to "load only when the script's group equals `musicRoomGroup`; `CheckSourceCacheHit` skips repeated transfers" (F01 already lists these two lines).

**F2 — VERIFIED — `tile_collision_physics.asm:32` (class 3, 4).** "AdvanceTileOffsetY actually steps +Y and AdvanceTileOffsetX steps +X: the names are swapped relative to their behavior (rename proposed)". The code at `:1108-1156` confirms Y steps +Y and X steps +X (V05), and row 26 applied the rename, so the names are now correct and the sentence is false. Fix: delete the second sentence and the "rename proposed" clause. `:57` "(audit OQ-16)" is a class-7 id (types `$06`/`$09`; see OQ-16).

**F3 — VERIFIED — `combat_collision.asm:53`, `:905` (class 6).** "positive counter `$0011` (17 frames of invincibility)" and "recovery ($FFEF) vs invincibility ($0011) iframes". `actor_execution.asm:157-168` shows the positive counter DECs and, for every non-player actor, skips the whole tick (hit-stun); the player alone is exempt (`CPX $playerActor / BEQ`). `:640` says "victim frozen" without the player exemption. Fix: one wording in all four places (53, 640, 905, `:1407/1507` "longer than combat's 17"): "positive = stun counter (non-player actors skip their tick; the player keeps moving), negative = recovery".

**F4 — VERIFIED — `cop_handlers_script_control.asm:79`, `cop_handlers_player_query.asm:112` (class 2).** The delay in `$08` is N+1 ticks (V08), not "this many frames" / "the delay". Fix: add "(N+1 ticks, see the WaitByte note)". Neither line is in the F02 list: add them.

**F5 — VERIFIED — `cop_dispatch.asm:5`, `:70` and `notes/partNotes/bank00.json:136` (class 3, 5).** The note lists 19 differing handler labels with pairs that are now identical (`$1A–$1E`, `$80–$87`, `$B6/$B7`). Only `$90–$92` still differ (`StagePlayerSpriteMoveX/Y/XY` vs copdef `StagePlayerMoveX/Y/XY`). Fix: rename the three labels to the copdef spelling with `npm run names` (or rename in copdef, user-owned) and rewrite the note through `npm run merge`.

**F6 — VERIFIED — `GetPlayerFacingDirection.asm:16` (class 10).** Retired lower-case nicknames in the note text (`will_alt`, `ability_fx`, `freedan_fx`, `shadow_fx`). Already in F03 scope.

**F7 — VERIFIED — 54 lines in 20 files (class 7).** OQ ids and audit/ledger references live in extracted notes (list in §6). Worst: a ledger file path in a code comment (`combat_collision.asm:217`) and "see the audit rename proposals" (`warps_interaction.asm:46`). Fix: rewrite each as a plain statement of what is unknown ("not traced", "no reader found"); drop the ids. Needs one merge spec over 20 files.

**F8 — VERIFIED — history narration (class 4), 7 in-scope lines** listed in §6, plus out-of-scope-file hits found while checking rows 42, 52, 61, 87: `scene_chest_table.asm:1` ("The old note … was wrong"), `walk_step_table.asm:7` ("The old header called …"), `SpawnFieldRevealEffect.asm:15` ("The old header named …"), `StandardEnemyDefeatHandler.asm:15` ("The old header said …"). Fix: state only the current facts.

**F9 — VERIFIED — `radar_map_screen.asm:343, 371, 416` (class 1, 4).** The part notes call `RadarPlotFriendlyActor` / `RadarPlotEnemyActor` "historical" names. Row 89 is blocked by OQ-63, but the note should say what the routine plots (bit 8: enemies still alive; bit 9: set only by `dark_space.asm`) and avoid the word "historical".

**F10 — VERIFIED — `cop_handlers_script_control.asm:23`, `:7` (class 4, 7).** "'SetOnInteract' is only a stale name in the docs" and "(rename proposal 90)". Fix the docs (row 93) instead of explaining their staleness in the asm.

**F11 — VERIFIED — docs still wrong (class 3, 11; owner F05).** The following doc lines still carry the facts that the ledger rows say to correct: rows 9 (`wram-memory-map.md:207`), 10 (`structs-reference.md:824`), 11 (`scene-script.md:234`), 15 (`bank01-data-tables.md:341-343`), 16 (`movement-and-collision.md:251, 314-315`), 31 (`wram-memory-map.md:358`), 40 (`collision_branch.md:24, 416`), 45 (`hdma_dma.md:9, 139`), 69 (`force_move.md:9, 19, 20`), 70 (`sine_hdma.md:55`), 71 (`vram_memory.md:111`), 77 (`system-core.md:36`, `data-tables-memory.md:415`, `dialog.md:18, 53, 57, 119`), 93 (`SetOnInteract`, 6 files), 94 (`wram-memory-map.md:347`).

**F12 — VERIFIED — `copdef.json:100` (class 11).** `BranchIfCollisionTypeNe` (id 98) is the script-visible name of a handler that branches on EQUAL (V02). Row 33; user-owned file.

**F13 — VERIFIED — mnemonic backlog (class 1, 9).** All nine misnamed mnemonics and the other rows 7, 22, 23, 27, 28, 37, 46, 49, 54, 67 (musicParentActor), 75, 79, 83, 90 are still unchanged in `db-us/mnemonics.json` (§5). Owner: F06.

**F14 — VERIFIED — `GlobalInputHandler.asm:114`, `:34`, `:74` (class 13).** The consume constant `$6000` (Select + vanilla Y) is not covered by the button-remap transforms, so the logical item-use bit `$0008` is not consumed (OQ-39, row 62b). The notes say so correctly; the behaviour question is open.

**F15 — REPORTED — process deviations in the apply file** (`apply-I001-I020_summary.md` §4, §8): the renames were applied "with sed using a reviewed old→new map", and the new part notes "with `npm run annotate`", a command that was later retired. The result was checked (no old name left, rebuild gate unchanged), but the method conflicts with the no-ad-hoc-scripts rule. Not re-checked beyond the outcome.

**F16 — VERIFIED — documentation of the A01 inputs.** `digest_I001-I020.md` says the `wram-memory-map.md:170` `deathFlag` statement exists; it no longer does (`deathFlag` is not in `docs/`). The digest's "107 lines in 37 files" is 107/36 (narrow) or 111/42 pairs (this session's count).

---

## 8. Not verified / needs Mesen2

No Mesen2 ROM or state exists; everything below is static only.
- Runtime claims behind OQ-1…OQ-4, OQ-8, OQ-9, OQ-12, OQ-13, OQ-15, OQ-18, OQ-20, OQ-28–OQ-31, OQ-33–OQ-35, OQ-37–OQ-39, OQ-42, OQ-44, OQ-45, OQ-47, OQ-48, OQ-50, OQ-53, OQ-54, OQ-57, OQ-58, OQ-63, OQ-65–OQ-68.
- The 17-tick hit-stun length (V14): counted from the DEC loop, not observed.
- Class 8 (hidden sprite groups) was not sampled in the 25 facts.
- The REPORTED rows: 12, 17, 24, 29, 51, 63, 76, 80, 81 (not checked), and the sub-items marked REPORTED in rows 25, 30, 40, 45, 58, 66, 86.
- `item_use_system.asm` and `future_vision_cutscene.asm` were not part of A01.
- The per-iteration "edits" JSON specs (`edits/I015-I016.json` etc.) were not read.

---

## 9. Items for the fix specs

| F-step | Items from A01 |
|--------|----------------|
| F01 (scene_script) | F1: `scene_script.asm:1303` and `:75` (both already listed); add the unnamed `$06F4` to the part note |
| F02 (WaitByte n+1) | F4: add `cop_handlers_script_control.asm:79` and `cop_handlers_player_query.asm:112` to the target list |
| F03 (nicknames) | F6: `GetPlayerFacingDirection.asm:16` (already listed) |
| F04 (barrier) | none new from A01 |
| F05 (docs) | F11: the 14 doc rows listed there (rows 9, 10, 11, 15, 16, 31, 40, 45, 69, 70, 71, 77, 93, 94) |
| F06 (renames/mnemonics) | F5 (three `StagePlayerSpriteMove*` labels), F12 (`BranchIfCollisionTypeNe`), F13 (mnemonic backlog), rows 32, 33, 38, 44, 64 (remainder), 68, 78, 89, 95, 96; rows 89, 95 wait for OQ-63 / OQ-68 |
| New (no F-step covers it; suggest F07, one `merge` spec) | F2 (`tile_collision_physics.asm:32`), F3 (`combat_collision.asm:53, 640, 905, 1407, 1507`), F5 note rewrite (`cop_dispatch.asm:5, 70`), F7 (54 id/audit lines in 20 files), F8 (11 history-narration lines, incl. 4 out-of-scope files), F9, F10 |

---

## 10. Counts

- Rename rows: 96 (APPLIED 47, SUPERSEDED 1, DROPPED 2, PROPOSED 46); 37 of the 46 open rows checked live.
- OQ registry: 69 (answered later 3, closed otherwise 2, resolved in range 2, partial 3, open 59).
- Fact re-checks: 25 (VERIFIED-CORRECT 18, VERIFIED-WRONG 7, CANNOT-CHECK 0); 19 files; 12 of 13 classes.
- Mnemonic operand lines (nine names): 111 (comment mentions included), 42 name-file pairs.
- Sweep hits (60 files): WaitByte wording 2 real; history 7 real + 4 false positives; ids 54 lines in 20 files; nicknames 1.
- Findings: 16 (F1–F14 and F16 VERIFIED, F15 REPORTED).
