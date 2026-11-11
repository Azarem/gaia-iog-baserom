# IT-12 apply: hygiene sweep 1, history narration and ledger ids (I001-I040 files)

Mechanism: `npm run merge` only. Spec: `plans/extracted-audit/audit-of-audit/IT12_spec.json` (one spec, 57 files, dry-run first). The run reported 52 block notes, 39 part notes and 65 comments updated (156 entries), nothing added or removed. Scope: the A01 section 1, A02 section 1 (32-file sweep set) and A03 section 1 files that still had a hit in the live `extracted/` tree after `npm run extract:lt`; many "known hits" had already been removed by IT-01 to IT-07, so I swept the live files instead of trusting the line numbers.

Files edited: `system/engine/` 23, `system/player/` 7, `system/boot_logos/sFB_boot_logo`, `system/inventory/` 3 (`inventory_overlay`, `inventory_menu`, `item_use_system`), `functions/` 11, `actors/` 6 (`player/player_character`, `large_ramps`, `ramps`, `camera_delta_oscillator`, `idle_sprite_display`, `scene_flag_init`), `thinkers/` 6.

## Sweeps (rg over the same 57 files plus the other files of those directories)

- narration: `\b(previously|formerly|old header|old note|the old |older|was renamed|rename proposed|historical|stale name|used to be|first audit)\b`
- ids: `OQ-[A-Za-z0-9-]+|\bR-(I[0-9]{3}|B[0-9]{3}|SAN[0-9]|[0-9]+)(-[0-9a-z]+)?\b|\bD-S[0-9]+-[0-9]+\b|rename proposal|questions file|\(I0[0-9]{2}\)|audit (OQ|rename)`

| sweep | before (whole `extracted/`) | after (whole `extracted/`) | after, in the 57 edited files |
|---|---|---|---|
| ids | 231 matches in 85 files | 87 matches in 40 files | 3 (`item_use_system.asm` lines 37, 368, 450: skipped by instruction) |
| narration | 172 matches in 83 files | 107 matches in 59 files | 0 narration; the 5 remaining hits are runtime words ("old Y", "old plate", "old accumulator value", "previously ready") |

All other remaining hits are in files this iteration does not own (listed under "Found outside scope").

## Facts re-derived before writing

- `OQ-I034-1` (`displayModeFlags` bit 14 "no reader"): the word at `$09EC` is stored 16-bit, so bit 14 is bit 6 of `hudDisableFlag` (`$09ED`). `UpdateHUD` (`system_core.asm` 394-401) tests `BIT #$40` of `hudDisableFlag` and returns at once when it is set. So "no reader found" is false. I wrote the answer instead (sFB_boot_logo block note and comment 772285, inventory_overlay block note and comment 191778). This is the A12-02 item of IT-19; IT-19 can record it as already done.
- `OQ-I032-5` (`ramps.asm` line 41, "reader of the player's `$10` bit `$0200` is unknown"): `combat_collision.asm` 333 and 340 test `BIT #$76E0` (skip mask of the normal enemy-hits-player pass, contains `$0200`) and `BIT #$74E0` (friendly pass, allows `$0200`). I wrote that statement instead of "unknown". This is part of A12-04/05 (IT-19).
- `OQ-I025-4` (`player_character` north attack tests `BranchIfSolidSouth`): kept as a plain code fact, id removed.
- `OQ-I025-1/2/5`, `OQ-I030-1`, `OQ-I038-3`, `OQ-I040-3`: no trace found in `extracted/`; each id became "not traced" (or the clause was dropped where the sentence already said so).
- `OQ-I026-2`, `OQ-I026-3`, `OQ-I026-4`, `OQ-I026-5/6`, `OQ-I025-6`, `OQ-I028-1/2`, `OQ-I029-3/4/5`, `OQ-I033-1/2/3/4`, `OQ-I034-2/4`, `OQ-I038-2`, `OQ-I039-4`, `OQ-I045-1`, `OQ-I033-5`: the sentence already states the current fact; only the id was removed.
- `OQ-I030-2` in `SetPlayerGameOverFlag`: kept "most likely" (static inference) and dropped the docs sentence that quoted the old docs claim.

## Applied (by file)

| file | what changed |
|---|---|
| `system/engine/*` (23 files) | ids and narration removed from `hdma_dma_spc` (fade-out "not traced"), `actor_execution`, `combat_collision` ("role unresolved"), `radar_map_screen`, `warps_interaction`, `event_blocks`, `DisplaySceneTitle` (block note), `forced_walk` (comment 60334: `$0008` = collision-aware movement, `$2000` = skipped by `SortActorsByDepth`), `camera_scroll`, `flag_helpers` (callers of `ClearAllWramFlags`), `actor_pool`, `cop_handlers_*` (dungeon_switch, script_control, dialog, actor_flags, sprite, vram, movement, audio, oam_attribs), `system_core`, `system_init`, `map_coords` |
| `system/player/*` (7 files) | `tile_collision`, `player_move_west/ramps/east/south/ns/main`: "old header / older / old text" corrections dropped, ids dropped, 28 comments rewritten as present-tense statements |
| `system/boot_logos/sFB_boot_logo` | OQ-I034-1 answered (see above); "old header said TM = $10 puts BG1 ..." replaced by "TM = $10 is bit 4, the OBJ layer; it puts no BG on the main screen" |
| `system/inventory/*` | `inventory_overlay` (5 narration / id clauses, 5 comments), `inventory_menu` (2 ids, 2 comments), `item_use_system` (part notes `UseItem_WindFlute`, `UseItem_LolaMelody_Effect`; comments 231160, 231435, 232521) |
| `functions/*` (11 files) | `ActorMidpointCalc`, `EnemyInitBasic`, `SetPlayerGameOverFlag`, `ActorDisplayModeSwap`, `EnemyDeathFlash`, `SpawnFieldRevealEffect`, `NpcDespawnStub`, `FlickerParentActor`, `SetPlayerIdleFacing` (+ comment 50938), `StandardEnemyDefeatHandler` (whole "=== CORRECTIONS ===" section removed; every fact in it is already stated in the flow section; part note `EnemyGemDropRouter`), `game_over_sequence` (CORRECTIONS tail rewritten as statements, comment 54845) |
| `actors/*` | `player_character` (10 ids: block note, three part notes, five comments), `large_ramps`, `ramps`, `camera_delta_oscillator` (docs claim and blanket `UNVERIFIED-RUNTIME` removed), `idle_sprite_display` (a blanket `UNVERIFIED-RUNTIME` clause removed), `scene_flag_init` |
| `thinkers/*` | `hdma_circle_window_thinker` (block note and `HdmaEmitRepeatSegments`), `sine_hdma_slow_wave`, `oneshot_coldata_r11g4b2`, `oneshot_coldata_warm_flash`, `palette_parent_child`, `scanline_band_hdma_thinker` |

Applied: 156 entries (52 block notes, 39 part notes, 65 comments) in 57 files.
DISPUTED: 0 (but three contradicted claims were corrected instead of copied: the two `OQ-I034-1` notes and `ramps.asm:41`, see "Facts re-derived").
SKIPPED: `item_use_system.asm` lines 37, 368, 450 (build-mode difference); `MenuSelectionHandler.asm` (blocked by the merge guard); `DialogStringRenderer.asm` (IT-11); forbidden tags: none touched (`item_use_system` 231157 and 231432 left as they were; only the BNE comments 231160 / 231435 changed, which carry no `LDA`/joypad hazard); no `$8000` written in `combat_collision` or `actor_execution` notes.
BLOCKED: 0 new.

## Dry-run summary

```
[DRY RUN] 17 notes file(s) would change; nothing written.
  notes/blockNotes/bank00,02,03,05,06,08,0A,0B.json
  notes/partNotes/bank00,02,03,05.json
  notes/comments/bank00,02,03,0A,0B.json
OK
```

The first dry-run of the engine chunk failed once (`DisplaySceneTitle`: the text was in the block note, not the part note); the entry was corrected to `blockNote` and the full spec dry-ran clean before the real run. The real run wrote the same 17 files.

## Gate

`npm run extract:lt`, then `npm run rebuild` (separate commands; the rebuild reported `ROM rebuild completed successfully!`): `artifacts/crc.json` = checksum 223006080, crc 2083230829, totalSize 3062204. Equal to the baseline.

Read back in the re-extracted files: `player_character.asm` 7 and the id lines, `ramps.asm` 41, `sFB_boot_logo.asm` 5 and 49, `inventory_overlay.asm` 17 and 116, `StandardEnemyDefeatHandler.asm` 1-18, `game_over_sequence.asm` 24-26, `SetPlayerGameOverFlag.asm` 3, `player_move_ramps.asm` 1-14, the six thinker and five actor block notes (rg for the new wording), and the post-edit sweeps above.

## Process note

One shell command in this iteration piped rg output through `sort`; no output was relied on from it, no other rule deviation (no git writes, no scripts, no sub-agents). The spec file itself is the only new file besides this one.

## Found outside scope (not changed)

- `cop_handlers_actor_flags.asm:75` still says the COP name "BranchIfCollisionTypeEq" "says 'not equal'": false after IT-04 renamed it (IT-47 / A14-F11).
- `tile_collision.asm:3` ("the earlier note said only the `player_move_*` blocks do") and `actors/ramps.asm:447` ("unnamed in the original") are narration that no sweep pattern catches; they belong to the `earlier|original` sweep (IT-23 to IT-25).
- `player_move_ramps`, `player_move_east`, `player_move_ns`, `player_move_main` block notes still carry "Everything here is UNVERIFIED-RUNTIME" sentences (blanket tag, IT-23).
- Ids left in other iterations' files (not in the A01/A02/A03 sets): `player_transition_handlers` 9, `overworld_exit` 6, `layer1_scroll_actors` 5, `field_reveal_object` 4, `sFA_diary_menu` 4 (IT-13), `WorldMapController` 5, `world_map_options` 2, `sE6_gaia` 2 (IT-09 files), `scene_thinkers` 3, `system_strings` 3, `dialog_dictionaries` 1, `spriteset_*` 11, `inventory_spritemap` 1 (IT-21 / IT-10 tables), `dark_space` 2, `camera_scroll_controller` 2, `boss_clear_reward_handler` 2, `shadow_shimmer` 1 (`OQ-I030-1; OQ-I048-1`), `EnemyDropSystem` 2, `camera_drift` 2, `EnemyDefeatDispatch` 2, `ApplyPlayerHitstun` 1, `EscortFollowPathTracker` 1, `SpawnDamageNumberEffect` 1, `unused_particle_rain_spawner` 1, `town_door` 1, `hit_switch` 1, `hit_stagger_controller` 1, `hidden_red_jewel` 1, `gold_ship_wreck_palette` 1, `diary_menu_window_dma` 1, `WorldMapSplitEffect` 1, `world_map_scene_names` 1, `inventory_mgmt` 1, `boot_logo_enix_palette_obj0/1` 2.
- Narration left in those same files (IT-13 and later): `global_ambient_dispatcher` 11, `unused_particle_rain_spawner` 3, `hit_stagger_controller` 3, `ApplyPlayerHitstun` 3, `player_move_controller` 3, `sE6_gaia` 5, `scene_script` 3 (IT-17), `dark_space`, `dialog_string_scanner`, `jeweler_gem`, `npc_wander_ai`, `EnemyDefeatDispatch`, and the table files. `game_over_sequence.asm:24` keeps the heading "=== CORRECTIONS ===" (A09-09, IT-13).
- IT-19 can mark A12-02 (the HUD bit) and the `$0200` reader in `ramps.asm` as already done; `StopPlayerOnDeath.asm` and `debug_stat_setter.asm` were not touched.
- `docs/` still repeats several of the dropped claims (for example `docs/code/bank0A-dungeon-enemy-actors.md` "boss kill invulnerability flash", `docs/code/bank08-native-dao-pyramid-actors.md` pyramid scroll claim, `docs/code/bank00/actors-infrastructure.md` large ramp text): IT-16.
- `git status` shows `extracted/` as modified because `extract:lt` writes the `; {n}` line tracking; run `npm run extract` if you want the plain form before committing.
