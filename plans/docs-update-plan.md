# Documentation Update Plan — Post-Audit Name & Description Sync

## Overview

After completing Phases 1–10.1 of the ASM audit, many labels were renamed in `names.json` and `blocks.json` but the 62 documentation files in `docs/` still reference the old generic names. This plan updates all docs systematically.

**Scope:**
- 256 stale generic labels (renamed in `names.json` but still old in docs)
- 16 stale block names (renamed in `blocks.json`)
- Description accuracy updates where audit findings changed our understanding
- Missing documentation for newly annotated code

## Method per phase

1. Read each doc file fully
2. Find-and-replace all stale generic labels with their current names
3. Find-and-replace stale block names
4. Verify descriptions still match the audited understanding
5. Note any missing docs or valuable additions in the Appendix

**No scripts.** All edits are manual `StrReplace` operations.

## Stale block name mappings (reference for all phases)

| Old name | Current name |
|----------|-------------|
| `sE8_actor_0CEEAA` | `sE8_dark_gaia` |
| `sFC_actor_0BC9AE` | `sFC_title_start_handler` |
| `sFE_actor_03A2F1` | `WorldMapController` |
| `sFC_actor_0BC924` | `sFC_title_intro` |
| `s2B_actor_058027` | `gs2B_wreck_wave_motion` |
| `s2C_actor_05813A` | `gs2C_rain_spawner` |
| `s2C_actor_05816F` | `gs2C_rain_particle` |
| `sF7_actor_09DFF8` | `sF7_credits_player` |
| `sF7_actor_09E26C` | `sF7_credits_npc_a` |
| `sF7_actor_09E3EB` | `sF7_credits_npc_b` |
| `sF7_actor_09E4DD` | `sF7_credits_npc_c` |
| `sF7_actor_09E591` | `sF7_credits_npc_d` |
| `sF7_actor_09E607` | `sF7_credits_npc_e` |
| `sFB_actor_0BC8BA` | `sFB_boot_logo` |
| `sFC_actor_0BC9BD` | `sFC_title_start_handler` (merged) |
| `sE7_actor_0CEDC5` | `sE7_space_flight_controller` |

---

## Phased execution

### Phase D1: `docs/code/bank00/` — System core & COP dispatch (2 files) ✅ COMPLETE

- `system-core.md` — 2 replacements (`binary_01C384` → `scene_flag_table`)
- `cop-dispatch.md` — verified clean

### Phase D2: `docs/code/bank00/` — Camera, scroll, & follow system (2 files) ✅ COMPLETE

- `camera-scroll-system.md` — 26 replacements (FollowDirHandler00–0F, FollowChase*, SmoothFollowLookup)
- `functions-camera-motion.md` — 6 replacements (sine_table_8bit ×4, signed_sine_table ×2)

### Phase D3: `docs/code/bank00/` — Actors, combat, & interaction (3 files) ✅ COMPLETE

- `actors-combat-interaction.md` — 11 replacements (HitStagger*, SmoothFollowChildTick, EffectUpdateCameraDeltaY)
- `actors-player-rewards.md` — 4 replacements (OverworldExitFinalize, StatueReward*, EnemyDefeatDispatch)
- `actors-infrastructure.md` — verified clean

### Phase D4: `docs/code/bank00/` — Functions (3 files) ✅ COMPLETE

- `functions-combat-defeat.md` — 10 replacements (AppendHitSparkOamEntry, DarkGemDrop*, EnemyDefeatDispatch)
- `functions-player-npc.md` — verified clean
- `functions-game-over.md` — verified clean

### Phase D5: `docs/code/bank00/` — Thinkers & data tables (4 files) ✅ COMPLETE

- `thinkers-palette.md` — 4 replacements (PaletteParentChildWaveLoop ×3, sE8_dark_gaia)
- `thinkers-hdma.md` — 4 replacements (CometLairHdmaCTimedBurst, SineHdmaEndingWaveGen ×3)
- `thinkers-system.md` — verified clean
- `data-tables-memory.md` — 16 replacements (FollowDirHandler*, SmoothFollowLookup, scene_flag_table, etc.)

### Phase D6: `docs/code/bank00/` — Remaining bank 00 (8 files) ✅ COMPLETE

- `stair-climb-system.md` — 7 replacements (StairTriggerWestMain, RampPlayerClimb*, RampApplyMotionCurve)
- `direction-collision.md` — verified clean
- `event-flags.md` — 1 replacement (WorldMapController)
- `utility-tiles-animation.md` — 8 replacements (sine_table_8bit)
- `utility-math-movement.md` — verified clean
- `actor-management.md` — verified clean
- `nmi-handler.md` — verified clean
- `readme.md` — 1 replacement (HitStaggerMain)

### Phase D7: `docs/code/bank02/` — Engine (5 files) ✅ COMPLETE

- `game-systems.md` — 16 replacements (MusicLoadCleanup, CheckEnemyDefeatedFlag, InitCameraBounds ×6, etc.)
- `hardware-and-init.md` — 8 replacements (scene_flag_table ×3, sine_table_8bit ×5)
- `scene-script.md` — verified clean
- `spc-transfer.md` — verified clean
- `camera-scrolling.md` — 2 replacements (CalcTileMapOffset)

### Phase D8: `docs/code/bank02/` — Player, movement & menus (9 files) ✅ COMPLETE

- `tile-collision.md` — 4 replacements (CalcTileMapOffset)
- `inventory-menu.md` — 3 replacements (item_table_separator)
- `player-character.md`, `player-movement.md`, `slope-ramp-physics.md`, `attack-ability-system.md`, `utility-functions.md`, `inventory-overlay.md`, `map-coordinates.md` — all verified clean

### Phase D10: `docs/code/bank03/` — All bank 03 (9 files) ✅ COMPLETE

- `readme.md` — 2 replacements (sine_table_16bit, cosine_table_16bit)
- `field-input-and-items.md` — 2 replacements (PlayerAuraTransformEntry)
- `mode7-and-cutscenes.md` — 5 replacements (FlashPalette19, sine_table_16bit ×2, cosine_table_16bit ×2)
- `scene-and-hardware.md` — 3 replacements (hdma_channel_config)
- `actor-thinker-runtime.md`, `movement-and-collision.md`, `radar-and-world-map.md`, `sprite-rendering.md`, `text-and-menus.md` — all verified clean

### Phase D11: `docs/code/bank04–07` — Scene actor banks (4 files) ✅ COMPLETE

- `bank04-npc-actors.md` — verified clean
- `bank05-midgame-actors.md` — 15 replacements (PlayerFreedanRevealIdle, HiddenRedJewelInventoryFull, HdmaGradient*, DarkSpacePortalInit, EnemyInitBasic, dm_follower_behavior + 3 block renames: gs2B_wreck_wave_motion, gs2C_rain_spawner, gs2C_rain_particle)
- `bank06-late-midgame-actors.md` — 9 replacements (sp58_actor_068380, ActorDisplayModeSwap ×7, Transform_FreedanToWill)
- `bank07-watermia-euro-actors.md` — 2 replacements (euro_bg_scroll_actor, DarkSpacePortalInit)

### Phase D12: `docs/code/bank08–0B` — Late-game & system actors (4 files) ✅ COMPLETE

- `bank08-native-dao-pyramid-actors.md` — 33 replacements (DarkSpace*, Transform_*, AbilityOrbActor, CollisionLayerRenderer, etc.)
- `bank09-babel-ending-overflow-actors.md` — 48 replacements (7 labels + 6 block renames: sF7_credits_player/npc_a-e × 5 each)
- `bank0A-dungeon-enemy-actors.md` — 47 replacements (SetPlayerGameOverFlag, EnemyPositionSnap, EnemyInitBasic, EnemyDefeatDispatch, dm_follower_behavior, etc.)
- `bank0B-late-bosses-system-cutscene-actors.md` — 57 replacements (21 labels + 4 block renames: sFB_boot_logo, sFC_title_intro, sFC_title_start_handler)

### Phase D13: `docs/code/bank0C–0D` — Scene tables & meta (2 files) ✅ COMPLETE

- `bank0C-scene-spawn-tables-comet.md` — 25 replacements (SetPlayerGameOverFlag ×4, unused_null_actor ×4, sE7_space_flight_controller ×8, sE8_dark_gaia ×9)
- `bank0D-scene-meta.md` — verified clean

### Phase D14: Top-level docs (5 files) ✅ COMPLETE

- `cop-commands-reference.md` — 49 replacements (40 unique: COP handler names, sub_*, func_*, block rename sFC_title_intro)
- `actor-organization-analysis.md` — 78 replacements (38 unique: actor names, function refs, 3 block renames)
- `structs-reference.md` — 7 replacements (WorldMapController, UpdateActorAnimation, etc.)
- `bank01-data-tables.md` — 23 replacements (10 unique: all binary_* data table names)
- `wram-memory-map.md` — 1 replacement (ResetHdmaState)

### Phase D15: Readmes (2 files) ✅ COMPLETE

- `docs/code/readme.md` — verified clean
- `docs/code/bank02/readme.md` — verified clean

### Final verification ✅ COMPLETE

Re-scanned all 62 doc files. **0 remaining stale standalone labels. 0 stale block names.**
(2 regex false positives: substrings inside composite names `sp58_sp58_actor_068380` and `pyD7_actor_08C57F` — not stale)

---

## Appendix: Additional changes to make in a final pass

_(Updated as phases are completed — track missing notes, valuable additions, description corrections)_

### Name accuracy issues

1. **`scene_flag_table` misnomer** (`system-core.md`, `data-tables-memory.md`, `hardware-and-init.md`): The data at `$01C384` was renamed to `scene_flag_table` in `names.json`, but the doc and ASM both show it being used for "slope acceleration curve pointers" and "HUD pointer initialization." The name `scene_flag_table` may not accurately describe all its contents. Consider verifying the data structure and potentially renaming it.

2. **`sp58_sp58_actor_068380` double-prefix** (`bank06-late-midgame-actors.md`): This composite label has a redundant `sp58_sp58_` prefix. The doc text says "stub sp58_sp58_actor_068380 (falls through to shared Y-drift loop…)". This appears to be a naming artifact. Consider auditing the `blocks.json` part name to remove the double prefix.

### Missing documentation candidates

3. **`smooth_follow_child.asm`** — Now fully annotated with part notes and inline comments. A dedicated doc section in `actors-combat-interaction.md` or `camera-scroll-system.md` would consolidate the follow-chase behavior explanation that's currently split across block notes and inline comments.

4. **`town_door.asm`** — Now has comprehensive part notes and inline comments. Could benefit from a mention in the bank 00 readme under "Interactive actors" section.

5. **Dark Space system** (`bank08-native-dao-pyramid-actors.md`) — After renaming `DarkSpacePortalInit`, `DarkSpaceInteractionMonitor`, `DarkSpaceEnterWarp`, `DarkSpaceExit`, `DS_Layout*`, `DarkSpaceRestoreControl`, `DarkSpaceAmbientParticle`, this subsystem now has clean, descriptive names. A dedicated "Dark Space Portal System" section in the doc would tie these together.

6. **Transform functions** — `Transform_WillToFreedan`, `Transform_FreedanToWill`, `Transform_WillToShadow`, `Transform_FreedanToShadow`, `Transform_ShadowToFreedan`, `Transform_ShadowToWill` — now consistently named. A cross-reference table showing which scenes use which transforms would be valuable.

7. **Enemy utility functions** (`bank0A`) — `SetPlayerGameOverFlag`, `EnemyPositionSnap`, `EnemyInitBasic`, `ActorMidpointCalc`, `EnemyDefeatDispatch` now have clear names. Part notes exist but could be expanded with caller counts.

8. **Diary/boot system** (`bank0B`) — All diary menu functions are now named (`DiaryMainMenuEntry`, `DiaryCameraPan`, `DiarySndBtnTab`, etc.). Consider a dedicated diary system doc page.

9. **Credits actors** (`bank09`) — The 6 renamed `sF7_credits_*` blocks could benefit from a concise "Credits Scene Architecture" section describing the player + 5 NPC pattern.

