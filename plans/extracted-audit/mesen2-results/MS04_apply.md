# MS04 apply: E, F, G, M, N, P, R, S, T, V, W1 and FR notes

Date: 2026-11-10. Source reports: every result file after D3 (`E1`-`E4`, `F1`-`F3`, `G1`-`G4`, `M1`-`M4`, `N1`-`N4`, `P1`, `P2`, `P4`, `R1`-`R3`, `S1`, `T1`, `V1`, `W1-a`-`W1-g`, `FR00`-`FR50`). The `A` and `B1`-`B3` files are not part of this step.

- Merge spec: `plans/extracted-audit/edits/MS04.json` (107 extracted files, hand-merged from the session drafts under `mesen2-results/specs/`; overlapping edits were combined into one).
- Names spec: `plans/extracted-audit/renames/apply-MS04_names.json` (7 entries).
- Closure rows: appended to `mesen2-results/closures.md` (186 rows for this step; 110 of them name MS04).

## Preconditions

1. ACTION_PLAN Progress log and §6: Part 2 iterations (IT-17, IT-20, IT-21, IT-29 and others) still own some of the touched files. As in MS01-MS03 the edits are note, comment and name text only and the gate shows no ROM change.
2. `git status --short` was read, not changed. 5705 files were already modified before the step (the `extracted/` tree, `artifacts/`, `baserom/` patch files); nothing was staged or reverted.
3. No `GATE:` line exists in the ACTION_PLAN. The baseline was re-established by rebuild before the merge (plain and tagged builds identical): checksum 222965960, crc -34152415, totalSize 3062205, sha1 `90a04067dd5b5284bd9e152ad222df0e65d08979`. The stored baseline in `artifacts/crc.json` from the earlier step (222990002 / -575332819 / `0cfcb558...`) no longer reproduced because the tree changed after MS03.

## Procedure

1. `npm run extract:lt`, then `npm run merge -- plans/extracted-audit/edits/MS04.json --dry-run`: OK, 32 notes files would change (15 blockNotes, 11 partNotes, 6 comments banks), 19 length warnings (comments over 160 characters, advisory).
2. `npm run names -- plans/extracted-audit/renames/apply-MS04_names.json --dry-run`: 1 added, 6 renamed, 17 files would change (including 2 files in `IOGRXLT/IOGRetranslation/modules`).
3. User approved with references rewritten in the retranslation modules too. Real merge: OK. Real names: wrote 19 files.
4. `npm run extract:lt`, then `npm run rebuild` (separate commands). `artifacts/crc.json`: checksum 222965960, crc -34152415, totalSize 3062205, mode tagged, sha1 `90a04067dd5b5284bd9e152ad222df0e65d08979`. **Identical to the gate: no ROM byte changed.**
5. Read-back in `extracted/` (tagged): every one of the 275 notes, part notes and comments in the spec (block-note edits, part-note edits, comments) is present with the new text. No old name (`IdleStand*Shadow`, `PlayerIdleUseShadowSprite`, `TitleCometSpriteActor`, `code_0AF53D`) remains in the baserom, `docs/`, `gaia-core/docs` or the retranslation modules.
6. `npm run names -- --check`: **11 problems, none from this step.** The files listed as "not sorted / formatted like the tool writes it" are `bank01`, `03`, `04`, `05`, `06`, `07`, `09`, `0C`, `0F`, `16`, `17`. All are unmodified in git; the four bank files this step wrote (`bank00`, `02`, `0A`, `0B`) pass. The pass criterion "check clean" is therefore not met for the whole directory; the formatting is a pre-existing issue (see "Tool issues").

## Result table

First line is the line of the first changed note in the tagged extraction (b = block note, p = part note, c = comment).

| Result id | File:line | Status | Note |
|-----------|-----------|--------|------|
| E1 | `gold_ship/ship_gold/gs2C_crow_crew.asm:b1`; `thinkers/palette_parent_child.asm:7`; `flag_gated_palette_warm.asm:9`; `flag_gated_palette_cool.asm:9`; `ambient_palette_cycler.asm:5` | APPLIED | ramp channels and palette-thinker facts replace the "not traced" sentences |
| E2 | `system/world_map/WorldMapController.asm:37`; `thinkers/mode7_perspective.asm:22` | APPLIED | ambient bundle use (59 records, 33 bundle ids) |
| E3 | `WorldMapSplitEffect.asm:16`; `mode7_perspective.asm:17,52`; `diary_entry_table.asm:1`; `sFA_diary_menu.asm:22`; `hdma_circle_window_thinker.asm:33`; `diary_menu_window_dma.asm:3` | APPLIED | Mode 7 HDMA tables are written once; the diary scene is Mode 1 (comments 84, 124, 143, 146 and others) |
| E4 + R2 + W1-a (band thinker) | `thinkers/scanline_band_hdma_thinker.asm:65`; `mu/mu_vampire_lair/mu67_vampires.asm:p456` | APPLIED | the 20 band types, $0F spawn, extra words kept; Mu window setup described and renamed `mu_color_window_setup` |
| F1-F3 | `spriteset_will_abilities.asm:16`; `spriteset_shadow_aura_body.asm:13`; `spriteset_shadow.asm:9`; `spriteset_freedan.asm:p48`; `spriteset_aura.asm:17` (OBSEL sentence at 15); `spriteset_dark_friar.asm:13`; `spriteset_freedan_fx.asm:10` | APPLIED | pose and frame facts replace the "art not viewed" sentences |
| G1-G4, N2, P2, P4, W1-c, W1-g (combat) | `attack_ability_system.asm:38`; `combat_collision.asm:17`; `enemy_stats_table.asm:12`; `ability_damage_tables.asm:3`; `player_character.asm:40`; `hit_switch.asm:5`; `EnemyInitBasic.asm:5`; `boss_clear_reward_handler.asm:13`; `EnemyDefeatDispatch.asm:12`; `ApplyPlayerHitstun.asm:9`; `hit_stagger_controller.asm:29`; `ramps.asm:40`; `SpawnDamageNumberEffect.asm:19` | APPLIED | `$0080` is the hit-reaction state; record byte used; `$0AEC` = 0 drop; knockback tier; lunge needs a fresh press. `combat_collision` has no `$8000` text |
| M1, G3 | `inventory_mgmt.asm:13`; `game_over_sequence.asm:14`; `item_use_system.asm:p584`; `StandardEnemyDefeatHandler.asm:8`; `cop_handlers_thinker.asm:9`; `actor_pool.asm:p44` | APPLIED | Lola's Melody gate, max HP clamp, enemyNum 0, `$0024` readers |
| M2, V1, R3 | `sFB_boot_logo.asm:24`; `spm_title_actors.sprite.asm:5`; `sFC_title_intro.asm:7`; `TitleEarthSpriteActor` rename | APPLIED | "Nintendo PRESENTS" boot logo; half-lit Earth; `WaitByte #B3` = 180 ticks (313 NMI frames incl. the fade); unreferenced `TitlePaletteStep_noref` |
| M3 | `WorldMapController.asm:p395`; `overworld_exit.asm:37`; `world_map_scene_names.asm:5`; `spm_overworld_sprites.sprite.asm:11`; `world_map_route_table.asm:11`; `world_map_options.asm:38` | APPLIED | four separate figures, n + 1 deltas over n frames, the miss path of `LookupMapName`, Edward's Castle exit |
| M4 | `ConsoleStringRenderer.asm:p691`; `DisplaySceneTitle.asm:13`; `music_actors.asm:c141`; `dialog_template_table.asm:28`; `DialogStringRenderer.asm:p331`; `oam_digit_compose.asm:p43` | APPLIED | tile `$20` is a period; 20-tile title box; `PrintNumber` zeros; digit-compose caller unreferenced |
| N1 + FR20 | `sg51_statue.asm:3`; `ir26_statue.asm:4`; `town_door.asm:7`; `hidden_red_jewel.asm:36`; `jeweler_gem.asm:17` (comment 41) | APPLIED | the statue is pulled by L / R as Will; `$E8` set before the intro dialog |
| N2 | `gold_ship_wreck_palette.asm:19`; `statue_inventory_reward.asm:24`; `game_over_sequence.asm:p195` | APPLIED | adrift looks, 15 of 60 confetti bursts, sparkle ellipse |
| N3 | `sE6_gaia.asm:p2048` and 5 comments (2060-2066); `dark_space.asm:p168`; `spriteset_darkgaia_projectile.asm:15` | APPLIED | firefly chains 4/3 and 8/7, statue pictures, flame-bird tiles |
| N4 + S1 | `cop_handlers_script_control.asm:p260`; `cop_handlers_effects.asm:p228,p418`; `scene_warps.asm:19`; `ActorMidpointCalc.asm:5` | APPLIED | `LoopEnd` yields n - 1 times; `CameraPanUp` ends at 0; forced-walk codes `$04` / `$05`; `$06` = 0 case |
| S1 | `cop_handlers_inventory.asm:p85`; `dialog_dictionaries.asm:12`; `combat_collision.asm` comments 334, 485 | APPLIED | `BranchIfItemEquipped` reads bank `$82`; the dictionary substitution rule; skip-mask comments |
| P1 | `global_ambient_dispatcher.asm:13`; `GlobalInputHandler.asm:3`; `EscortFollowPathTracker.asm:5` | APPLIED | physical-button wording follows the remap table; escort tracker carry |
| W1-f | `tables/body_table.asm:p35` | APPLIED | row 8 reads the stack page; `$DC` observed |
| P4 | `camera_scroll.asm:3`; `camera_scroll_controller.asm:14`; `camera_drift.asm:21`; `player_character.asm:p1789` (CameraShakeFrame) | APPLIED | bit 12 qualifier; same packed ratio on X and Y; drift offsets do not accumulate |
| R1 | `player_move_ns.asm:36` | APPLIED | the dead pair checked at runtime |
| R2 | `scene_meta.asm:11`; `scene_actors.asm:16`; `scene_warps.asm:23`; `scene_script.asm:61`; `display_preset_table.asm:1` | APPLIED | the 25 ids crash or hang; pan-list use; save-warp records; unused modes |
| R3 | `camera_delta_oscillator.asm:5` | APPLIED | nothing spawns it |
| W1-a | `player_move_main.asm:14`; `player_move_west.asm:7`; `player_move_east.asm:22`; `player_move_south.asm:3` | APPLIED | `$AA` bits `$0800` / `$0400` are set (by `TSB $AB`) |
| W1-b, W1-e | `sprite_composition.asm:7,p409`; `actor_execution.asm:p924`; `layer1_scroll_actors.asm:15`; `camera_scroll.asm:p38` (comment 65 and 83); `inventory_overlay.asm:c177`; `scene_lifecycle.asm:c807,c886` | APPLIED | `$06C8` has a reader; `$06F0` / `$06F1` written; bit 12 has a setter; `ClearActorRenderList` has a third caller. `actor_execution` has no `$8000` text |
| W1-c | `scene_flag_init.asm:7`; `SetPlayerIdleFacing.asm:5`; `player_transition_handlers.asm:p45`; `ir29_castoth.asm:12`; `player_character.asm` comments 1378-1568; `scene_lifecycle.asm:p759`; names | APPLIED | flag `#00` selects the idle sprite family; `IdleStand*Flagged`, `PlayerIdleFlaggedAnim` |
| W1-d | `field_reveal_object.asm:5`; `mode7_perspective.asm` comment 124; `actor_execution.asm` comment 779 | APPLIED | child `$26` nonzero; `$7F0E00` readers |
| W1-g | `actor_pool.asm:c241,c265`; `smooth_follow_child.asm:5`; `EscortFollowPathTracker.asm:9,17` | APPLIED | `$0024` readers; `pyCC_blaster` speed 3; `$7EDF00` is shared |
| FR20 | `ec0E_statue.asm:1`; `jeweler_gem.asm:5` | APPLIED | |
| FR21 | `item_use_system.asm:p755`; `ir20_statue.asm:4`; `it1A_lily.asm:c112` | APPLIED | Diamond Block places at X `$0E` only; no position test |
| FR23 | `eu92_erasquez.asm:1`; `eu95_neils_father.asm:1`; `eu95_neils_mother.asm:1` | APPLIED | the Teapot test reversed; fall-through into `Die` |
| FR24 | `pyD6_vader_barrier_upper.asm:1`; `pyD6_vader_barrier_lower.asm:1` | APPLIED | no form test |
| W1-e (`MenuSelectionHandler`) | `MenuSelectionHandler.asm` | BLOCKED | merge refuses this file (IT-28 / IT-30) |
| T1 | five "extract:lt still shows vanilla" sentences | SKIPPED | left for IT-29; the results were recorded in `closures.md` |
| FR00-FR10, FR22, FR30, FR40, FR50 and the FR flag rows | registry, `scene-flags.json` and preset updates | SKIPPED | flag-registry work (`npm run flags` or the flags plans), outside merge and names |
| Every row marked INCONCLUSIVE or "no shipped note wrong" in `closures.md` (for example N2 OQ-I048-2, N3 OQ-I056-5 (b), P2 OQ-I027-1 (a)) | none | SKIPPED | not run, or the shipped note agrees; no note changed |

Nothing is DISPUTED.

## Dry-run summary

Merge: 107 files, 32 notes files. Names: 7 entries, 17 files (2 outside this repo). See "Procedure".

## Verdict counts (rows of `closures.md` for this step)

186 rows. VERIFIED (runtime or static): 131. CONTRADICTED: 53. INCONCLUSIVE: 50. A row can carry more than one verdict, so the three counts add to more than 186.

## Items outside scope

- `MenuSelectionHandler.asm` correction (W1-e): BLOCKED, see the table.
- T1's five shipped sentences saying `extract:lt` still shows the vanilla text: left for IT-29.
- Registry, `db-us/scene-flags.json` (for example the wrong note on scene `$0A` at line 4) and preset updates from the FR results: need `npm run flags` or the flags plans.
- FR22 notes lie in the unapplied `plans/flags/results/specs/FL10`, `FL24`, `FL25` and `FL27_notes.json` drafts.
- `notes/blockNotes/bank08.json:84` (imprecise `Transform_WillToShadow` caller list): left to its owner.
- Docs that still repeat sentences now shown wrong (not edited here): `docs/code/bank0A-dungeon-enemy-actors.md:257,269` (FR20); `docs/code/bank07-watermia-euro-actors.md:241` (FR23); `docs/code/bank00/data-tables-memory.md:97-99` (R3); `docs/wram-memory-map.md:364` and `:438`; `docs/code/bank00/camera-scroll-system.md:39`; `docs/code/bank00/actors-combat-interaction.md:382`; `docs/cop/families/player_sprite.md:127-135`; `docs/code/bank02/player-character.md`.

## Tool issues

- `gaia-core/docs/notes-and-comments.md:1353` says `extract:lt` prints no tag on commented lines and that `expectOld` replaces them. In this baserom the line prints `; {n} <comment>` and merge refuses `expectOld`, so `expect` must be used.
- `npm run names -- --check` flags 11 bank files as "not sorted / formatted like the tool writes it" although they are unmodified; the check and the files disagree (probably line endings or formatting from an earlier tool version).
- Earlier tool notes T-43, T-47 and T-50 stay with their sessions.
