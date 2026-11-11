# IOG extracted/ ASM audit — checklist

## 0. Process for I021 and later (write-new-file-per-iteration)

This file, the legacy ledgers and every earlier results file are **frozen**: never append to or edit them (appending to big files pushed the agent into throwaway scripts). Each iteration (one `I0nn` = 3 files) instead creates **new files**, each written once with the Write tool:

| File | When | Content |
|------|------|---------|
| `edits/I0nn.json` | when annotations change | merge spec applied this iteration (the replayable edit record) |
| `results/I0nn_results.md` | always | per-file Q1–Q7 verdicts, dispositions, gate result, suggested commit message |
| `renames/I0nn_renames.md` | only if renames are proposed | rows `R-I0nn-1`, `R-I0nn-2`, ... |
| `questions/I0nn_questions.md` | only if questions are opened | rows `OQ-I0nn-1`, `OQ-I0nn-2`, ... |

Rules:
- IDs are iteration-scoped (`OQ-I021-1`, `R-I021-1`). Do not reuse or renumber. The legacy `OQ-1..OQ-69` and rename rows 1..96 stay valid (they live in `questions/I001-I020_open-questions.md` and `renames/I001-I020_rename-proposals.md`).
- A closed or answered question is recorded in a *later* iteration's questions or results file by referencing its ID, never by editing the old file.
- **Status of an iteration = existence of `results/I0nn_results.md`.** The `[ ]`/`[x]` ticks in §12 are frozen at I001–I020 and are no longer maintained. The next iteration is the lowest number without a results file.
- The §11 progress log below is frozen at I020; the one-line summary and the suggested commit message of each later iteration live in its own results file.
- **Process update (2026-10-27, user-approved): the loop is now write the spec, `npm run merge -- edits/I0nn.json [--dry-run]`, then `npm run extract:lt` to verify.** `merge` writes straight into `notes/` JSON (no `.asm` edit). **The `ingest` and `annotate` commands were removed on 2026-10-28 (user decision): `merge` and `names` are the only scripts; do not recreate or call the others.** `extracted/` is stale after a merge until the next extract. See `gaia-core/docs/notes-and-comments.md` section "Notes Merge".
- **Name changes (2026-10-28, user-approved): `npm run names -- renames/apply-<range>_names.json [--dry-run]`.** The spec is a JSON array of `{ "address", "old", "new", "row" }` (address = the `; {n}` line-tracking integer of the part's first instruction from `extract:lt`, label the extracted asm prints now, new label, ledger id; no hex, nothing taken from `blocks.json` / `files.json`); the tool updates `db-us/names/bankNN.json` and rewrites the references in notes, `db-us/*.json`, `baserom/`, `docs/` and the sibling docs/modules. Never write an ad-hoc rename or ingest script (see `gaia-core/docs/notes-and-comments.md` section "Names Merge"). Renames are still only *proposed* in `renames/I0nn_renames.md` during an audit iteration; the spec is written when the user approves a rename pass.
- Notes, comments and mnemonics are still changed only with a spec in `edits/`. The spec itself is a new file per iteration; if a later iteration must correct an earlier annotation, it writes a new spec file (for example `edits/I0nn.json` or `edits/sanity-<topic>.json`).
- Gate after each pair: `npm run extract:lt`, `npm run rebuild`, `artifacts/crc.json` must read checksum 223006080 / crc 2083230829 / totalSize 3062204.
- Mentions of `results.md`, `rename-proposals.md` and `open-questions.md` in the frozen sections below mean `results/I001-I020_results.md`, `renames/I001-I020_rename-proposals.md` and `questions/I001-I020_open-questions.md`.

## 11. Progress log (FROZEN at I020)

- Phase 0: baseline rebuild OK (crc 2083230829); extract:lt active; results/rename-proposals/open-questions created.
- I001 (scene_script, cop_handlers_linked_actor, cop_handlers_wait): done. 7 accuracy defects fixed in scene_script, 2 in the COP handlers; 25+ mnemonics added; ingest applied; rebuild OK, CRC unchanged (2083230829). Suggested commit: "audit(I001): correct scene_script/COP wait+linked-actor notes, add gfx/source-cache/collision-flag mnemonics". See results.md.
- I002 (combat_collision, DmaWordToVram, music_pointer_array): done. 7 accuracy defects in combat_collision (damage formula uses DEF and characterForm, knockback enumeration, terrain-shake path, A/B button naming, misaligned comments), DMAP wording fix, 1-based music table documented; 4 mnemonics added; rebuild OK, CRC unchanged. Suggested commit: "audit(I002): correct combat_collision damage/knockback notes, document 1-based music table, add enemy HP scratch mnemonics".
- I003 (scene_lifecycle, vram_buffer_clear, ShowDialogueFrame): done. 15 accuracy defects in scene_lifecycle (EnableNmiOnly/ScreenBlackout semantics, transition-parameter bytes, amplitude vs phase, HDMA wave table, palette/MVN, tile counts, flag `$FF`), `$7F0200` identified as the BG3 tilemap staging buffer (not a command queue), ShowDialogueFrame contract; 12 mnemonics added. Suggested commit: "audit(I003): correct scene_lifecycle transition/HDMA/palette notes, document BG3 staging buffer, add transition and bg3TilemapBuffer mnemonics".
- I004 (math_lookup_tables SAMPLED ~25%, cop_handlers_dungeon_switch, cop_handlers_offscreen): done. 5 defects in math tables (scene_flag_table is the slope curve data, tables rely on ROM adjacency, cosine/negated half-wave/quarter), inverted HaltIfMaxFrames logic fixed, block notes added to both COP handler files; 0 mnemonics (rename proposals 18-22). Rebuild OK, CRC unchanged (2083230829) for I003+I004. Suggested commit: "audit(I004): document math table adjacency and slope curves, fix HaltIfMaxFrames notes, add COP handler block notes".
- I005 (actor_execution, cop_handlers_bg_rearrange, cop_handlers_world_map): done. 13 accuracy defects in actor_execution (iframe sign convention, combat lock, pool/region labels, off-screen flag, event-block index, scene-local defeat flag), BG-rearrange and world-map handler semantics corrected, 3 block notes; 9 mnemonics added (sceneTableIndex, enemiesRemaining/Bcd, 6 world-map). Rename proposals 27-30, OQ-15, 17, 18, 20.
- I006 (tile_collision_physics, cop_handlers_thinker, cop_handlers_inventory): done. 9 accuracy defects in tile_collision_physics (page-based tile-map offset, swapped AdvanceTileOffset names, DBR bank, special tiles), block notes for both COP handler files, inventorySlots is a 16-byte array; combat_collision hit-stun comment fixed. Rebuild OK, CRC unchanged (2083230829) for I005+I006. Rename proposals 26, 31; OQ-16, 19. Suggested commits: "audit(I005): correct actor_execution iframe/pool/flag notes, document BG-rearrange and world-map handlers, add scene/enemy/world-map mnemonics" and "audit(I006): document collision tile-map format, thinker and inventory COP handlers, fix combat_collision hit-stun comment".
- I007 (DialogStringRenderer, hdma_ramp_tables, cop_handlers_actor_flags): done. ~14 accuracy defects in the dialog renderer (row stride, PrintNumber operand order/stack, joypad consumption-mask semantics, scene `$FA` is the diary menu, box/cursor/scroll mechanics), HDMA/parallax/ramp table semantics (curves are Y pixel deltas), inverted `BranchIfBehindWall` note fixed; `menuModeFlag` mnemonic added. Rename proposals 32-33, 38-39; OQ-21, 23, 24, 27.
- I008 (cop_handlers_collision, GetPlayerFacingDirection, cop_handlers_callbacks): done. ~12 defects in the collision handlers (TileCollisionQuery return, `$000F` branch test, hitbox header, ComputeDirectionToPlayer), facing tables map to body_table 4-7 (labels wrong, bit 15 is sprite-override), callback/extendedFlags block notes; `onDeathCallbackBank` mnemonic added. Rebuild OK, CRC unchanged (2083230829) for I007+I008. Rename proposals 34-37, 40; OQ-22, 25, 26, 28; OQ-16 partly resolved. Suggested commits: "audit(I007): correct dialog renderer notes, document HDMA/ramp tables and collision-probe COP handlers, add menuModeFlag mnemonic" and "audit(I008): document collision COP handlers and tile query, fix player facing tables notes, add callback block note and onDeathCallbackBank mnemonic".
- I009 (warps_interaction, cop_handlers_palette, cop_handlers_hdma_dma): done. ~25 accuracy defects: palette handler block note described the wrong handlers, HDMA operand model corrected (second word = bank | B-bus register; indexes `hdma_channel_config`; `QueueDma` is direct HDMA), `PlaceBarrierTiles` redraws opened chests, `$CFFC` mask, item ID in `$20`/`$0DB8`, `$0AF4/$0AF6` revive pointer vs `sceneSaveData`, extended-warp fields (`$0650` is a walk-step stream pointer, `$0652` a camera window). `hdma_ramp_tables` note re-edited (I007 OQ-21 bit-7 theory resolved). 4 mnemonics (`sceneSaveDataBank`, `reviveWarpPtr/Bank`, `gameOverWakeupFlag`). Rename proposals 41-46; OQ-29..32, OQ-21 revised.
- I010 (ConsoleStringRenderer, oam_digit_compose, cop_handlers_input): done. ~20 accuracy defects: `[N]`/`[DBL]` are 1 and 2 rows (names/comments said 2 and 4), `InsertItemName` is a shared-word lookup, `$099E/$099F` attribute word and `$09A0` line start, RCC height reads the next byte, DrawBox/BCD/Print3Digit details, HP clamp side effect; digit composer callers and `Continuation` entry were wrong; `cop_handlers_input` header listed 11 handlers (file has 4) and mis-described `joypadCurrent/joypadRaw`. 8 mnemonics (`consoleAttrWord`, `consoleLineStart`, `oamComposeBuffer+1/2/4/6/8/A`). Rebuild OK, CRC unchanged (2083230829) for I009+I010. Rename proposals 47-53; OQ-33..35. Suggested commits: "audit(I009): correct palette/HDMA COP handler notes and chest/warp documentation, add revive-pointer mnemonics" and "audit(I010): correct console string renderer, digit composer and joypad COP notes, add console and compose-buffer mnemonics".
- I011 (sprite_composition, GlobalInputHandler, cop_handlers_oam_attribs): done. ~50 accuracy defects: depth-sort priority direction was inverted (lower OAM index draws in front), `ClearActorRenderList` is not per-frame, tile-DMA list/source pointers and mirror handling documented, the map screen is a Start toggle and the item-use button is logical `$0008` (not vanilla Y `$4000`), `$6000` is Select+Y; the OAM attribute COP handlers had no block note; mnemonic `deathFlag` (`$0200`) is really the depth bucket array. 13 mnemonics (`oamStaging`+0/1/2, `joypadCurrent+1`, `joypadHeld+1`, `playerTile*`, `playerSpriteCache*`, `actorRenderList`+0/2). Rename proposals 54, 57-59, 62; OQ-36..40.
- I012 (camera_tilemap, event_block_table, cop_handlers_scene_flags): done. `SpriteVramDma` is the BG3 tilemap upload (not sprite DMA; BG3SC=`$78` -> VRAM `$7800`), `CameraFullRefresh` renders 32 columns (not rows), row/column vocabulary and DMA-half semantics corrected, camera wrap is `AND bounds-1` (not a clamp), layer-1 delta mode documented; event table field order verified (note extended: metatile units, placeholder entry `$07`, layer-1 entries `$06/$14/$20`); the scene-flag COP handlers got a block note. 6 mnemonics (`colStripStagingPtr`, `rowStripStagingPtr`, `bgTilemapVramBase`, each +0/+2). Rebuild OK, CRC unchanged (2083230829) for I011+I012; the `extract:lt` `rm` step failed mid-way (busy directory), so extraction was re-run directly and all 909 `.asm` were regenerated. Rename proposals 55-56, 60-61, 63; OQ-41, 42; OQ-6 resolved. Suggested commits: "audit(I011): correct sprite_composition depth/tile-DMA notes and GlobalInputHandler toggle/remap notes, add OAM attribute COP block note, add oam/player-tile/render-list mnemonics" and "audit(I012): correct camera_tilemap row/column and BG3 upload notes, extend event_block_table note, add scene-flag COP block note, add strip-staging mnemonics".
- I013 (smooth_follow, music_actors, cop_handlers_force_move) + I014 (cop_handlers_effects, cop_handlers_vram, cop_handlers_actor_death): done. smooth_follow fully reverse-engineered (eight handlers named for the wrong heading, SmoothFollowLookup is a Bresenham dither table, 36 part notes); music_actors is the MusicAndText jingle-then-restore-scene-music actor (mask is $FFFC, $1000 = display-filter flag); force-move COPs stage delta-chain pointers ($2C/$2E), not frame durations, and ForceDir* negate X/Y deltas; sine HDMA operand is the wave period, BindSineHdma takes a long Address + config byte, gravity/camera/spiral comments corrected; AdhocVramDma/CopyPalette/Decompress semantics fixed (WRAM output, MVN destination bank, RAM stub at $0402); actor-death cascade documented. 3 mnemonics added (adhocVramDmaBank/Dest/Size). Rebuild OK, CRC unchanged (2083230829). Rename proposals 64-72, OQ-43..OQ-48. Suggested commit: "audit(I013-I014): correct smooth_follow, music/force-move/effects/vram/actor-death notes, add adhoc VRAM DMA mnemonics". See results.md.

- 2026-10-27 PROCESS CHANGE (user-approved), not an iteration: ad-hoc edit scripts retired in favour of `npm run annotate -- <spec.json> [--dry-run] [--no-ingest]` (`src/annotate.ts`). Specs live in `plans/extracted-audit/edits/` (first one: `tool-fix-smooth-follow-lookup.json`). `src/ingest.ts` now recognises data-part labels (`Name #hex`, backtick, `~`, `|`); the I013 SmoothFollowLookup part note had been silently dropped by the old regex and was restored. Doc updated: `gaia-core/docs/notes-and-comments.md` "Annotation Editor". Tested: error paths, set/remove of block note, part note (top-level, data, sub-label) and comment, with ingest re-check and notes/ verification. Gate OK with `extract:lt` + `rebuild` (crc 2083230829, totalSize 3062204). Found: plain `extract` + `rebuild` gives a different CRC (OQ-49), so always gate in lt mode. Next: I015 + I016 using the tool.
- I015 (system_core, cop_handlers_dialog, save_system) + I016 (cop_handlers_movement, camera_scroll, DisplaySceneTitle): done with `annotate` (spec `edits/I015-I016.json`, 7 files incl. a `hdma_dma_spc` note fix). ~60 accuracy defects: the warmboot check never selects a scene (Y = 0 both ways); `UpdateFrameFull` runs from the NMI during the blocking SPC music upload (not a fade); `displayModeFlags` bit 3 = player-tile DMA pending, bit 0 = full BG3 upload, bit 4 = partial upload; HUD enemy bar is one 60-frame hold; `$0B28-$0B32` are hieroglyph plate slots (mnemonic `hieroglyphSlots` added); dialogue COPs: `$0800` = cutscene-active, `joypadMaskInv` = D-pad auto-repeat, mask direction reversed in comments; save checksums are order-independent; `MoveToward` operand 2 is speed (copdef says frames), proximity is a square box, `RngByte` is not an LFSR, `StageMove` speed >= $80 adds a halving pass; camera scroll spawn bytes are MulDivide ratios; `DisplaySceneTitle` guard is a same-ID reload. Open questions OQ-50 to OQ-58, rename rows 73-81. Gate OK (extract:lt + rebuild, crc 2083230829, totalSize 3062204).
- I017 (event_blocks, cop_handlers_actor_query, hardware_math) + I018 (cop_handlers_spawn, cop_handlers_audio, forced_walk): done with `annotate` (spec `edits/I017-I018.json`, 6 files). Main corrections: SwapEventBlockTiles is a copy (not a swap); `tileQueryResult` ($0902) is a pending 2x2 metatile VRAM update; queue neighbour addresses +1/+$20/+$21; BCS/BEQ meanings after QueueVisibleTileVram were swapped (carry = off-screen, Z = full); COP #44/#45 operand order is minX, minY, maxX, maxY (bounds: lower exclusive, upper inclusive); MulDivide divides only the low 16 bits of the product; SignedMultiply is an unsigned multiply; SoftDivide normalizes the divisor; StartMusic clears $1000 in $10 (not $0800) and SpcCheckMusicReady has no fade; forced-walk $2C/$2E hold movement_delta_table velocity-curve pointers, not durations; SyncPlayerToCamera clears $0200 (not $0400). Open questions OQ-60 to OQ-62, rename rows 82-87. Gate OK (extract:lt + rebuild, crc 2083230829, totalSize 3062204).
- I019 (radar_map_screen, cop_handlers_script_control, actor_pool) + I020 (cop_handlers_player_query, flag_helpers, cop_dispatch): done with `annotate` (spec `edits/I019-I020.json`, 7 files incl. a one-comment fix in `GlobalInputHandler`). Main corrections: the radar marks unopened treasure chests (`scene_barrier_chest_table`), counts remaining enemies (bit-8 dots) and probably Dark Space entrances (bit 9), and the border table is BGR555 colors; `BranchOnPlayerFacing` used the wrong direction order (facing is down/up/left/right); `QueueMapChange` bit 7 records a revive warp record, not a resume PC; `flag_helpers` now documents the flag regions in the `$0A00` array (`_Offset100` hits `$0AA0`, `ClearAllWramFlags` is not called at scene changes); `cop_dispatch` target list was stale (30 blocks) and 19 handler labels differ from copdef names. Rename rows 88-96, OQ-63 to OQ-69. Gate passed, CRC unchanged.

## 12. Master checklist (303 iterations, 909 files; line counts are approximate)

Phase headers mark where a phase begins; the first triple of a phase can contain trailing files of the previous one. Within P1-P2 and P4, files are interleaved large+small to balance effort.

### P1 Engine core (system/engine, system root tables, system/functions) - I001
- [x] I001: system/engine/scene_script.asm (2149) | system/engine/cop_handlers_linked_actor.asm (21) | system/engine/cop_handlers_wait.asm (33)
- [x] I002: system/engine/combat_collision.asm (1727) | system/engine/DmaWordToVram.asm (35) | system/music_pointer_array.asm (41)
- [x] I003: system/engine/scene_lifecycle.asm (1230) | system/functions/vram_buffer_clear.asm (43) | system/functions/ShowDialogueFrame.asm (47)
- [x] I004: system/math_lookup_tables.asm (1216) | system/engine/cop_handlers_dungeon_switch.asm (53) | system/engine/cop_handlers_offscreen.asm (63)
- [x] I005: system/engine/actor_execution.asm (1206) | system/engine/cop_handlers_bg_rearrange.asm (64) | system/engine/cop_handlers_world_map.asm (69)
- [x] I006: system/engine/tile_collision_physics.asm (1156) | system/engine/cop_handlers_thinker.asm (94) | system/engine/cop_handlers_inventory.asm (99)
- [x] I007: system/engine/DialogStringRenderer.asm (1153) | system/hdma_ramp_tables.asm (106) | system/engine/cop_handlers_actor_flags.asm (108)
- [x] I008: system/engine/cop_handlers_collision.asm (1083) | system/engine/GetPlayerFacingDirection.asm (112) | system/engine/cop_handlers_callbacks.asm (113)
- [x] I009: system/engine/warps_interaction.asm (1046) | system/engine/cop_handlers_palette.asm (130) | system/engine/cop_handlers_hdma_dma.asm (135)
- [x] I010: system/engine/ConsoleStringRenderer.asm (1041) | system/engine/oam_digit_compose.asm (140) | system/engine/cop_handlers_input.asm (149)
- [x] I011: system/engine/sprite_composition.asm (972) | system/engine/GlobalInputHandler.asm (164) | system/engine/cop_handlers_oam_attribs.asm (166)
- [x] I012: system/engine/camera_tilemap.asm (933) | system/event_block_table.asm (169) | system/engine/cop_handlers_scene_flags.asm (169)
- [x] I013: system/engine/smooth_follow.asm (906) | system/engine/music_actors.asm (170) | system/engine/cop_handlers_force_move.asm (171)
- [x] I014: system/engine/cop_handlers_effects.asm (788) | system/engine/cop_handlers_vram.asm (177) | system/engine/cop_handlers_actor_death.asm (186)
- [x] I015: system/engine/system_core.asm (776) | system/engine/cop_handlers_dialog.asm (194) | system/engine/save_system.asm (200)
- [x] I016: system/engine/cop_handlers_movement.asm (761) | system/engine/camera_scroll.asm (205) | system/engine/DisplaySceneTitle.asm (208)
- [x] I017: system/engine/event_blocks.asm (713) | system/engine/cop_handlers_actor_query.asm (214) | system/engine/hardware_math.asm (226)
- [x] I018: system/engine/cop_handlers_spawn.asm (532) | system/engine/cop_handlers_audio.asm (239) | system/engine/forced_walk.asm (249)
- [x] I019: system/engine/radar_map_screen.asm (519) | system/engine/cop_handlers_script_control.asm (276) | system/engine/actor_pool.asm (296)
- [x] I020: system/engine/cop_handlers_player_query.asm (518) | system/engine/flag_helpers.asm (299) | system/engine/cop_dispatch.asm (306)
- [ ] I021: system/engine/hdma_dma_spc.asm (517) | system/engine/QuintetLzDecompress.asm (313) | system/engine/thinker_execution.asm (321)
- [ ] I022: system/engine/cop_handlers_sprite.asm (482) | system/engine/spc_transfer.asm (328) | system/engine/vblank_joypad.asm (340)
- [ ] I023: system/engine/stair_climb.asm (415) | system/engine/cop_handlers_player_sprite.asm (368) | system/engine/cop_handlers_metatile.asm (378)
- [ ] I024: system/engine/system_init.asm (393) | system/engine/MenuSelectionHandler.asm (379) | system/engine/map_coords.asm (383)

### P2 Shared runtime code (functions, thinkers, actors, player, inventory) - I025
- [ ] I025: actors/player/player_character.asm (1893) | functions/NullActorScriptStub.asm (10) | functions/f_inventory_full.asm (13)
- [ ] I026: system/inventory/item_use_system.asm (1843) | functions/ToggleActorVisibilityFlag.asm (14) | functions/DeathPaletteFadeThinker.asm (15)
- [ ] I027: actors/player/attack_ability_system.asm (1645) | thinkers/oneshot_palette_flash_40.asm (17) | thinkers/oneshot_palette_flash_1F.asm (17)
- [ ] I028: system/inventory/inventory_menu.asm (1510) | thinkers/oneshot_palette_flash_1C.asm (17) | thinkers/oneshot_palette_flash_1B.asm (17)
- [ ] I029: system/player/player_move_diag.asm (985) | thinkers/oneshot_palette_flash_19.asm (17) | thinkers/oneshot_palette_flash_18.asm (17)
- [ ] I030: system/player/tile_collision.asm (691) | functions/SetPlayerGameOverFlag.asm (17) | actors/scene_flag_init.asm (17)
- [ ] I031: thinkers/hdma_gradient_thinker.asm (670) | thinkers/ambient_palette_cycler.asm (18) | functions/EnemyDeathFlash.asm (18)
- [ ] I032: actors/player/slope_ramp_physics.asm (669) | functions/StopPlayerOnDeathAssign.asm (20) | thinkers/sine_hdma_slow_wave.asm (21)
- [ ] I033: system/player/player_move_south.asm (668) | functions/ActorDisplayModeSwap.asm (22) | thinkers/oneshot_coldata_warm_flash.asm (23)
- [ ] I034: system/inventory/inventory_overlay.asm (514) | actors/idle_sprite_display.asm (23) | thinkers/oneshot_coldata_green_tint.asm (25)
- [ ] I035: thinkers/parallax_thinker.asm (499) | system/inventory/inventory_dma_setup.asm (25) | actors/debug_stat_setter.asm (26)
- [ ] I036: actors/ramps.asm (493) | thinkers/flag_gated_palette_warm.asm (27) | thinkers/flag_gated_palette_cool.asm (27)
- [ ] I037: actors/interaction_handlers.asm (475) | functions/EnemyInitBasic.asm (27) | functions/RandomPlayerOffset.asm (29)
- [ ] I038: system/player/player_move_ramps.asm (453) | actors/camera_delta_oscillator.asm (30) | functions/ActorMidpointCalc.asm (37)
- [ ] I039: system/player/player_move_ns.asm (451) | functions/SpawnDebrisBurst.asm (40) | functions/InitPlayerScriptVariant.asm (40)
- [ ] I040: system/player/player_move_east.asm (445) | thinkers/palette_parent_child.asm (42) | actors/large_ramps.asm (46)
- [ ] I041: thinkers/mode7_perspective.asm (423) | functions/SpawnAttackTrailEffect.asm (47) | actors/hidden_red_jewel.asm (47)
- [ ] I042: actors/overworld_exit.asm (387) | functions/SpawnHitSparkSprites.asm (50) | actors/floor_button.asm (50)
- [ ] I043: actors/jeweler_gem.asm (384) | actors/town_door.asm (57) | functions/EnemyPositionSnap.asm (62)
- [ ] I044: thinkers/global_ambient_dispatcher.asm (356) | functions/ApplyOrbitalOffsetXY.asm (68) | thinkers/incan_ruins_transform_palette.asm (72)
- [ ] I045: system/player/player_move_main.asm (345) | functions/ApplyOrbitalOffsetFromRef.asm (73) | actors/particle_rain_spawner.asm (73)
- [ ] I046: actors/hit_stagger_controller.asm (322) | functions/ApplyPlayerHitstun.asm (85) | functions/EnemyDefeatDispatch.asm (88)
- [ ] I047: actors/player/player_move_controller.asm (310) | system/inventory/inventory_statue_slot.asm (106) | actors/reward_actors.asm (106)
- [ ] I048: system/statue_inventory/statue_inventory_reward.asm (300) | actors/dialog_string_scanner.asm (111) | actors/player/shadow_shimmer.asm (126)
- [ ] I049: actors/debug_man.asm (285) | functions/DarkGemDropSystem.asm (133) | actors/camera_scroll_controller.asm (134)
- [ ] I050: system/inventory/inventory_mgmt.asm (279) | functions/npc_wander_ai.asm (140) | functions/camera_drift.asm (141)
- [ ] I051: actors/visual_effect_pipeline.asm (254) | actors/boss_clear_reward_handler.asm (156) | actors/field_reveal_object.asm (167)
- [ ] I052: actors/player_transition_handlers.asm (248) | functions/SpawnFieldRevealEffect.asm (169) | functions/EscortFollowPathTracker.asm (177)
- [ ] I053: actors/smooth_follow_child.asm (247) | actors/dark_space.asm (197) | functions/game_over_sequence.asm (208)
- [ ] I054: functions/StandardEnemyDefeatHandler.asm (209) | system/boot_logos/boot_logo_palette_enix.asm (21) | system/boot_logos/boot_logo_palette_quintet.asm (21)

### P3 System screens (world_map, title_screen, boot_logos, diary_menu, dark_space) - I055
- [ ] I055: system/boot_logos/boot_logo_palette_third.asm (21) | system/boot_logos/sFB_boot_logo.asm (90) | system/boot_logos/spm_boot_logos.sprite.asm (75)
- [ ] I056: system/dark_space/sE6_gaia.asm (1854) | system/dark_space/spm_darkspace_sprites.sprite.asm (380) | system/diary_menu/diary_entry_table.asm (362)
- [ ] I057: system/diary_menu/diary_menu_window_dma.asm (145) | system/diary_menu/sFA_diary_menu.asm (2083) | system/title_screen/sFC_title_intro.asm (85)
- [ ] I058: system/title_screen/sFC_title_start_handler.asm (71) | system/title_screen/spm_title_actors.sprite.asm (62) | system/world_map/HdmaWindowEffect.asm (177)
- [ ] I059: system/world_map/WorldMapController.asm (668) | system/world_map/spm_overworld_sprites.sprite.asm (894) | system/world_map/world_map_names.asm (128)
- [ ] I060: system/world_map/world_map_options.asm (787) | system/world_map/world_map_routes.asm (421) | tables/palette_bundles.asm (10897)

### P4 Global data tables (tables/) - I061
- [ ] I061: tables/direction_velocity_table.asm (20) | tables/body_table.asm (29) | tables/scene_actors.asm (5445)
- [ ] I062: tables/ability_anim_tables.asm (35) | tables/spriteset_field_fx.asm (43) | tables/movement_delta_table.asm (4788)
- [ ] I063: tables/spriteset_particle_fx.asm (45) | tables/item_component_table.asm (54) | tables/spriteset_freedan.asm (3745)
- [ ] I064: tables/forced_walk_sequence_table.asm (59) | tables/spriteset_town_objects.asm (75) | tables/spriteset_will.asm (3668)
- [ ] I065: tables/dialog_template_table.asm (77) | tables/parallax_scroll_table.asm (120) | tables/scene_meta.asm (3080)
- [ ] I066: tables/enemy_stats_table.asm (121) | tables/spriteset_aura.asm (125) | tables/spriteset_shadow.asm (2689)
- [ ] I067: tables/item_get_dialog_table.asm (149) | tables/spriteset_will_projectile.asm (227) | tables/spriteset_ability_fx.asm (2505)
- [ ] I068: tables/spriteset_npc_props.asm (239) | tables/display_preset_table.asm (246) | tables/scene_warps.asm (2209)
- [ ] I069: tables/spriteset_freedan_fx.asm (252) | tables/spriteset_shadow_fx.asm (253) | tables/spriteset_enemies.asm (1880)
- [ ] I070: tables/enemy_clear_reward_table.asm (267) | tables/spriteset_dark_friar.asm (271) | tables/dialog_dictionaries.asm (1383)
- [ ] I071: tables/spriteset_shadow_mode.asm (273) | tables/scene_barrier_chest_table.asm (432) | tables/inventory_spritemap.asm (1296)
- [ ] I072: tables/scene_thinkers.asm (729) | tables/system_strings.asm (767) | tables/spriteset_will_alt.asm (1031)

### Area: prologue - I073
- [ ] I073: prologue/pr_text_placement_calc.asm (140) | prologue/pr_thinkers.asm (20) | prologue/prologue_legends/pr8D_prologue2.asm (240)
- [ ] I074: prologue/prologue_mishap/pr8F_prologue4.asm (39) | prologue/prologue_missing/pr8E_prologue3.asm (125) | prologue/prologue_prophecy/IrisCircleEffect.asm (278)
- [ ] I075: prologue/prologue_prophecy/pr8C_prologue1.asm (139) | prologue/prologue_prophecy/pr8C_prologue5.asm (116) | prologue/prologue_prophecy/spm_prologue_prophecy_sprites.sprite.asm (252)

### Area: south_cape - I076
- [ ] I076: south_cape/chefs_house/sc07_chef.asm (24) | south_cape/church/sc08_erik.asm (40) | south_cape/church/sc08_lance.asm (30)
- [ ] I077: south_cape/church/sc08_priest.asm (67) | south_cape/church/sc08_seth.asm (27) | south_cape/coastal_cave/sc02_card.asm (74)
- [ ] I078: south_cape/coastal_cave/sc02_entry.asm (54) | south_cape/coastal_cave/sc02_erik.asm (133) | south_cape/coastal_cave/sc02_lance.asm (190)
- [ ] I079: south_cape/coastal_cave/sc02_seth.asm (199) | south_cape/coastal_cave/spm_sc02_main_characters.sprite.asm (1300) | south_cape/erics_house/sc04_eriks_father.asm (24)
- [ ] I080: south_cape/erics_house/sc04_eriks_mother.asm (35) | south_cape/erics_house/sc04_poverty.asm (35) | south_cape/lances_house/sc03_lances_mother.asm (68)
- [ ] I081: south_cape/seths_house/sc05_seths_father.asm (25) | south_cape/seths_house/sc05_seths_mother.asm (25) | south_cape/south_cape/sc01_astronomer.asm (74)
- [ ] I082: south_cape/south_cape/sc01_fisherman.asm (115) | south_cape/south_cape/sc01_girl1.asm (61) | south_cape/south_cape/sc01_girl2.asm (44)
- [ ] I083: south_cape/south_cape/sc01_girl3.asm (36) | south_cape/south_cape/sc01_guard.asm (85) | south_cape/south_cape/sc01_house_intro.asm (100)
- [ ] I084: south_cape/south_cape/sc01_jar_door.asm (51) | south_cape/south_cape/sc01_roof_man.asm (36) | south_cape/south_cape/sc01_salesman.asm (100)
- [ ] I085: south_cape/south_cape/sc01_seagull.asm (83) | south_cape/south_cape/sc01_smoke.asm (15) | south_cape/south_cape/sc01_sprint_man.asm (25)
- [ ] I086: south_cape/south_cape/sc01_startled_woman.asm (66) | south_cape/south_cape/sc01_sympathetic_woman.asm (54) | south_cape/south_cape/sc01_worried_woman.asm (93)
- [ ] I087: south_cape/south_cape/spm_southcape_sprites.sprite.asm (1485) | south_cape/wills_house/sc06_bill.asm (217) | south_cape/wills_house/sc06_hamlet.asm (134)
- [ ] I088: south_cape/wills_house/sc06_kara.asm (127) | south_cape/wills_house/sc06_kara_return.asm (226) | south_cape/wills_house/sc06_lily.asm (154)
- [ ] I089: south_cape/wills_house/sc06_lola.asm (211) | south_cape/wills_house/sc06_main_soldier.asm (52) | south_cape/wills_house/sc06_monologue.asm (65)
- [ ] I090: south_cape/wills_house/sc06_wills_pet.asm (30) | edward_castle/aqueduct_back/ec12_aqueduct_dark_space.asm (25) | edward_castle/aqueduct_back/ec12_aqueduct_enemy.asm (58)

### Area: edward_castle - I091
- [ ] I091: edward_castle/aqueduct_doorway/ec11_aqueduct_blocker.asm (50) | edward_castle/aqueduct_doorway/ec11_aqueduct_gate_sprite.asm (33) | edward_castle/aqueduct_doorway/ec11_button_voice.asm (83)
- [ ] I092: edward_castle/aqueduct_doorway/ec11_countdown.asm (104) | edward_castle/aqueduct_doorway/ec11_flower.asm (29) | edward_castle/aqueduct_entrance/ec0C_force_hint.asm (38)
- [ ] I093: edward_castle/aqueduct_entrance/spm_prison_enemies.sprite.asm (1975) | edward_castle/aqueduct_exit/ec13_lily.asm (108) | edward_castle/aqueduct_hall/ec0F_rusty_switch.asm (55)
- [ ] I094: edward_castle/aqueduct_hall/ec0F_spear.asm (70) | edward_castle/aqueduct_lockway/ec0E_barrier.asm (99) | edward_castle/aqueduct_lockway/ec0E_lily.asm (165)
- [ ] I095: edward_castle/aqueduct_lockway/ec0E_statue.asm (34) | edward_castle/aqueduct_lockway/ec0E_switch.asm (47) | edward_castle/aqueduct_treasure/ec10_dp_hint_spirit.asm (33)
- [ ] I096: edward_castle/castle_prison/ec0B_ball.asm (26) | edward_castle/castle_prison/ec0B_cell.asm (212) | edward_castle/castle_prison/ec0B_door.asm (26)
- [ ] I097: edward_castle/castle_prison/ec0B_guard.asm (49) | edward_castle/castle_prison/ec0B_moss.asm (27) | edward_castle/castle_prison/spm_sc06_castle_actors.sprite.asm (1096)
- [ ] I098: edward_castle/ec0C_bat.asm (68) | edward_castle/ec0C_ribber.asm (252) | edward_castle/ec0D_canal_worm.asm (274)
- [ ] I099: edward_castle/ec0E_spiney.asm (83) | edward_castle/ec0F_king_bat.asm (195) | edward_castle/ec12_skull_chaser.asm (199)
- [ ] I100: edward_castle/ec_proximity_door_toggle.asm (68) | edward_castle/edward_castle/ec0A_barrel_roast.asm (51) | edward_castle/edward_castle/ec0A_bed_maid.asm (24)
- [ ] I101: edward_castle/edward_castle/ec0A_caring_maid.asm (25) | edward_castle/edward_castle/ec0A_door_guard.asm (24) | edward_castle/edward_castle/ec0A_edward.asm (63)
- [ ] I102: edward_castle/edward_castle/ec0A_edwina.asm (28) | edward_castle/edward_castle/ec0A_kara.asm (208) | edward_castle/edward_castle/ec0A_kara_guard.asm (113)
- [ ] I103: edward_castle/edward_castle/ec0A_left_guard.asm (77) | edward_castle/edward_castle/ec0A_null_actor.asm (14) | edward_castle/edward_castle/ec0A_prison_guard.asm (31)
- [ ] I104: edward_castle/edward_castle/ec0A_right_guard.asm (79) | edward_castle/edward_castle/ec0A_shy_guard.asm (28) | edward_castle/edward_castle/ec0A_stair_guard.asm (58)
- [ ] I105: edward_castle/edward_castle/ec0A_stair_maid.asm (33) | edward_castle/edward_castle/ec0A_throne_guards.asm (142) | edward_castle/edward_castle/ec0A_torch1.asm (33)
- [ ] I106: edward_castle/edward_castle/ec0A_torch2.asm (33) | edward_castle/edward_castle/edward_castle_alarm_palette.asm (35) | edward_castle/edward_castle/spm_castle_sprites.sprite.asm (1105)

### Area: itory - I107
- [ ] I107: itory/itory_cave/it19_breakable_wall.asm (68) | itory/itory_cave/it19_inca_statue_a.asm (41) | itory/itory_couple_house/it18_warning_man.asm (24)
- [ ] I108: itory/itory_couple_house/it18_warning_woman.asm (24) | itory/itory_legend_house/it16_song_woman.asm (25) | itory/itory_village/it15_bill.asm (48)
- [ ] I109: itory/itory_village/it15_elder.asm (160) | itory/itory_village/it15_fable_man.asm (27) | itory/itory_village/it15_fable_woman.asm (26)
- [ ] I110: itory/itory_village/it15_friendly_woman.asm (25) | itory/itory_village/it15_kara.asm (93) | itory/itory_village/it15_lily.asm (149)
- [ ] I111: itory/itory_village/it15_lola.asm (83) | itory/itory_village/it15_running_man.asm (24) | itory/itory_village/itory_village_fog.asm (34)
- [ ] I112: itory/lilys_house/it17_kara.asm (44) | itory/lilys_house/it17_lily.asm (93) | itory/moon_tribe_camp/it1A_lily.asm (205)
- [ ] I113: itory/moon_tribe_camp/it1A_moon_tribe.asm (189) | itory/moon_tribe_cave/it1B_inca_statue_b.asm (41) | itory/moon_tribe_cave/it1B_trial.asm (110)
- [ ] I114: itory/spm_itory_sprites.sprite.asm (1364) | incan_ruins/castoth_lair/ir29_transform.asm (68) | incan_ruins/castoth_lair/spm_castoth.sprite.asm (1396)

### Area: incan_ruins - I115
- [ ] I115: incan_ruins/ceiling_trap_room/ir28_bones.asm (27) | incan_ruins/ceiling_trap_room/ir28_ceiling_trap_trigger.asm (84) | incan_ruins/inca_entryway/ir25_block_slot.asm (26)
- [ ] I116: incan_ruins/inca_entryway/ir25_ceiling_tile.asm (57) | incan_ruins/inca_plate_room/ir24_glowing_tile.asm (45) | incan_ruins/inca_secret_hallway/ir20_statue.asm (61)
- [ ] I117: incan_ruins/inca_treasure_room/ir26_bones.asm (29) | incan_ruins/inca_treasure_room/ir26_journal_bones.asm (29) | incan_ruins/inca_treasure_room/ir26_statue.asm (53)
- [ ] I118: incan_ruins/incan_ruins_entrance/ir1C_kara.asm (70) | incan_ruins/incan_ruins_entrance/ir1C_lily.asm (126) | incan_ruins/ir1B_slugger.asm (156)
- [ ] I119: incan_ruins/ir1D_four_way.asm (162) | incan_ruins/ir1D_mudpit.asm (167) | incan_ruins/ir1D_scuttlebug.asm (208)
- [ ] I120: incan_ruins/ir1F_stone_guard.asm (781) | incan_ruins/ir1F_stone_lord.asm (313) | incan_ruins/ir21_frozen_whirligig.asm (23)
- [ ] I121: incan_ruins/ir21_splop.asm (113) | incan_ruins/ir21_switch.asm (47) | incan_ruins/ir21_whirligig.asm (173)
- [ ] I122: incan_ruins/ir29_castoth.asm (1167) | incan_ruins/larai_cliff/ir1D_bones.asm (28) | incan_ruins/larai_cliff/ir1D_monologue.asm (35)
- [ ] I123: incan_ruins/larai_cliff/ir1D_wind_melody.asm (69) | incan_ruins/larai_cliff/larai_cliff_scroll_wave.asm (33) | incan_ruins/larai_cliff_back/ir1E_cliff_mantel_a.asm (21)
- [ ] I124: incan_ruins/larai_cliff_back/ir1E_cliff_mantel_b.asm (21) | incan_ruins/larai_cliff_back/ir1E_cliff_slide_trigger.asm (88) | incan_ruins/spm_cliff_enemies.sprite.asm (998)
- [ ] I125: incan_ruins/spm_ruins_enemies.sprite.asm (1951) | incan_ruins/stone_lord_plates/ir1F_gold_tile.asm (57) | incan_ruins/stone_lord_plates/ir1F_plate_gate_opener.asm (36)

### Area: freejia - I126
- [ ] I126: freejia/adequacy_manor/fr38_ashamed.asm (25) | freejia/adequacy_manor/fr38_boyfriend.asm (40) | freejia/adequacy_manor/fr38_girlfriend.asm (39)
- [ ] I127: freejia/eriks_captivity/fr33_erik.asm (48) | freejia/fr35_slave1.asm (27) | freejia/fr35_slave2.asm (28)
- [ ] I128: freejia/fr35_slave3.asm (28) | freejia/freejia/fr32_alley_guard.asm (47) | freejia/freejia/fr32_bg_sprite_a.asm (17)
- [ ] I129: freejia/freejia/fr32_bg_sprite_b.asm (17) | freejia/freejia/fr32_bg_sprite_c.asm (19) | freejia/freejia/fr32_creep.asm (43)
- [ ] I130: freejia/freejia/fr32_doomsday.asm (28) | freejia/freejia/fr32_fragrance.asm (26) | freejia/freejia/fr32_guide.asm (88)
- [ ] I131: freejia/freejia/fr32_herb.asm (41) | freejia/freejia/fr32_honest_life.asm (27) | freejia/freejia/fr32_hotel_hint.asm (34)
- [ ] I132: freejia/freejia/fr32_hp_jewel.asm (35) | freejia/freejia/fr32_idle_npc_a.asm (20) | freejia/freejia/fr32_idle_npc_b.asm (19)
- [ ] I133: freejia/freejia/fr32_kara.asm (88) | freejia/freejia/fr32_kidnapper.asm (107) | freejia/freejia/fr32_laborer_npc.asm (34)
- [ ] I134: freejia/freejia/fr32_locked_door.asm (51) | freejia/freejia/fr32_showman.asm (61) | freejia/freejia/fr32_slap.asm (32)
- [ ] I135: freejia/freejia/fr32_slaver1.asm (37) | freejia/freejia/fr32_slaver2.asm (101) | freejia/freejia/fr32_walking_npc.asm (26)
- [ ] I136: freejia/freejia/freejia_street_prop.asm (46) | freejia/freejia_hotel/fr39_erik.asm (62) | freejia/freejia_hotel/fr39_kara.asm (75)
- [ ] I137: freejia/freejia_hotel/fr39_lance.asm (120) | freejia/freejia_hotel/fr39_lily.asm (98) | freejia/harborer_house/fr3A_harborer.asm (31)
- [ ] I138: freejia/harborer_house/fr3A_sympathetic.asm (34) | freejia/messy_house/fr3B_tornado.asm (26) | freejia/mothers_house/fr36_mother.asm (34)
- [ ] I139: freejia/oakton/dc30_dog.asm (34) | freejia/oakton/dc30_kara.asm (42) | freejia/oakton_interior/dc31_kara.asm (88)
- [ ] I140: freejia/oakton_interior/dc31_rescuer.asm (65) | freejia/slave_market/fr3C_imas.asm (34) | freejia/slave_market/fr3C_man1.asm (26)
- [ ] I141: freejia/slave_market/fr3C_man2.asm (26) | freejia/slave_market/fr3C_remus.asm (48) | freejia/slave_market/fr3C_sam.asm (34)
- [ ] I142: freejia/slave_market/fr3C_slaver.asm (55) | freejia/spm_freejia_sprites.sprite.asm (1158) | freejia/thorn_tower/fr37_caution.asm (26)

### Area: diamond_mine - I143
- [ ] I143: diamond_mine/dm3D_eye_stalker.asm (588) | diamond_mine/dm3D_flayzer.asm (646) | diamond_mine/dm3D_grundit.asm (100)
- [ ] I144: diamond_mine/dm_follower_behavior.asm (163) | diamond_mine/mine_collapsed_tunnel/dm40_hidden_dark_space.asm (30) | diamond_mine/mine_collapsed_tunnel/dm40_trapped_slave.asm (116)
- [ ] I145: diamond_mine/mine_elevator/dm43_elevator.asm (184) | diamond_mine/mine_entrance/dm3E_intro.asm (50) | diamond_mine/mine_foyer/dm44_cell_door.asm (83)
- [ ] I146: diamond_mine/mine_inner/dm47_imas.asm (55) | diamond_mine/mine_inner/dm47_remus.asm (54) | diamond_mine/mine_inner/dm47_sam.asm (113)
- [ ] I147: diamond_mine/mine_inner/dm_mine_static_prop.asm (14) | diamond_mine/mine_main/dm3F_elevator_door.asm (43) | diamond_mine/mine_main/dm3F_elevator_sign.asm (27)
- [ ] I148: diamond_mine/mine_main/dm3F_laborer.asm (174) | diamond_mine/mine_main/dm3F_mine_collapse_trigger.asm (36) | diamond_mine/mine_main/dm3F_switch.asm (51)
- [ ] I149: diamond_mine/mine_main/dm41_solid_wall_setup.asm (21) | diamond_mine/mine_morgue/dm45_key.asm (53) | diamond_mine/mine_promise_passage/dm3D_breakable_wall.asm (70)
- [ ] I150: diamond_mine/mine_zigzag/dm41_bat_spawner.asm (36) | diamond_mine/mine_zigzag/dm41_minecart.asm (128) | diamond_mine/spm_mine_sprites.sprite.asm (2128)

### Area: angel_village - I151
- [ ] I151: angel_village/angel_annex/av6A_erik.asm (79) | angel_village/angel_annex/av6A_kara.asm (41) | angel_village/angel_annex/av6A_lance.asm (106)
- [ ] I152: angel_village/angel_annex/av6A_lily.asm (48) | angel_village/angel_annex/av6A_neil.asm (97) | angel_village/angel_entrance/av69_erik.asm (40)
- [ ] I153: angel_village/angel_entrance/av69_kara.asm (36) | angel_village/angel_entrance/av69_lance.asm (59) | angel_village/angel_entrance/av69_lily.asm (58)
- [ ] I154: angel_village/angel_entrance/av69_neil.asm (33) | angel_village/angel_entrance/av69_signs.asm (42) | angel_village/angel_rooms/av6C_harpist.asm (21)
- [ ] I155: angel_village/angel_rooms/av6C_only_sleeping.asm (28) | angel_village/angel_rooms/av6C_villagers4.asm (59) | angel_village/angel_rooms/av6C_villagers5.asm (67)
- [ ] I156: angel_village/angel_tunnel_river/av70_crawlspace.asm (55) | angel_village/angel_tunnel_river/av70_flame_center.asm (19) | angel_village/angel_tunnel_river/av70_hidden_passage.asm (52)
- [ ] I157: angel_village/angel_tunnel_rooms/angel_tunnel_window_dma.asm (22) | angel_village/angel_tunnel_rooms/av74_ishtar.asm (84) | angel_village/angel_tunnel_rooms/av74_kara.asm (135)
- [ ] I158: angel_village/angel_tunnel_test/av75_apprentice.asm (57) | angel_village/angel_tunnel_test/av75_voice_doors.asm (132) | angel_village/angel_tunnel_test/av75_voice_rooms.asm (249)
- [ ] I159: angel_village/angel_tunnel_waterfall/av73_waterfall_sound.asm (65) | angel_village/angel_tunnel_wind/av71_wind_effect.asm (76) | angel_village/angel_village/av6B_door.asm (41)
- [ ] I160: angel_village/angel_village/av6B_musician.asm (30) | angel_village/angel_village/av6B_ocean_ache.asm (52) | angel_village/angel_village/av6B_villagers1.asm (114)
- [ ] I161: angel_village/angel_village/av6B_villagers2.asm (58) | angel_village/angel_village/av6B_villagers3.asm (60) | angel_village/av6B_flame.asm (22)
- [ ] I162: angel_village/av6C_portrait.asm (36) | angel_village/av6D_dive_bat.asm (107) | angel_village/av6D_flame_left.asm (19)
- [ ] I163: angel_village/av6D_flame_right.asm (20) | angel_village/av6D_steelbones.asm (614) | angel_village/av6E_draco.asm (266)
- [ ] I164: angel_village/av70_ramskull.asm (73) | angel_village/spm_angel_sprites.sprite.asm (686) | angel_village/spm_tunnel_enemies.sprite.asm (939)
- [ ] I165: angel_village/undersea_tunnel/st68_ambient_bubbles.asm (109) | angel_village/undersea_tunnel/st68_campfire.asm (39) | angel_village/undersea_tunnel/st68_erik.asm (78)
- [ ] I166: angel_village/undersea_tunnel/st68_kara.asm (155) | angel_village/undersea_tunnel/st68_lance.asm (60) | angel_village/undersea_tunnel/st68_lily.asm (90)
- [ ] I167: angel_village/undersea_tunnel/st68_mushrooms.asm (45) | angel_village/undersea_tunnel/st68_neil.asm (85) | watermia/gambling_house/wa7B_competitor_left.asm (33)

### Area: watermia - I168
- [ ] I168: watermia/gambling_house/wa7B_competitor_right.asm (39) | watermia/glass_players_house/wa7D_glass_opponent.asm (94) | watermia/lance_lily_exchange/wa7F_lance.asm (107)
- [ ] I169: watermia/lance_lily_exchange/wa7F_lily.asm (79) | watermia/lances_fathers_house/fireplace_journal.asm (39) | watermia/lances_fathers_house/spm_watermia_lances_sprites.sprite.asm (697)
- [ ] I170: watermia/lances_fathers_house/wa7A_lance.asm (83) | watermia/lances_fathers_house/wa7A_lances_father.asm (39) | watermia/lukes_house/wa79_erik.asm (64)
- [ ] I171: watermia/lukes_house/wa79_kara.asm (147) | watermia/lukes_house/wa79_lance.asm (111) | watermia/lukes_house/wa79_lily.asm (109)
- [ ] I172: watermia/lukes_house/wa79_neil.asm (82) | watermia/spm_watermia_sprites.sprite.asm (1415) | watermia/wa78_lance_camera_pan.asm (116)
- [ ] I173: watermia/watermia/wa78_centipede_man.asm (56) | watermia/watermia/wa78_children.asm (83) | watermia/watermia/wa78_crazy_man.asm (30)
- [ ] I174: watermia/watermia/wa78_diary.asm (45) | watermia/watermia/wa78_flower.asm (21) | watermia/watermia/wa78_full_pad.asm (57)
- [ ] I175: watermia/watermia/wa78_glass_game.asm (628) | watermia/watermia/wa78_intro.asm (94) | watermia/watermia/wa78_kruk.asm (30)
- [ ] I176: watermia/watermia/wa78_lily_pad.asm (18) | watermia/watermia/wa78_men.asm (178) | watermia/watermia/wa78_moving_pad.asm (339)
- [ ] I177: watermia/watermia/wa78_moving_woman.asm (57) | watermia/watermia/wa78_prize_kruk.asm (36) | watermia/watermia/wa78_water_kid.asm (48)
- [ ] I178: watermia/watermia/wa78_women.asm (99) | watermia/watermia/watermia_festival_palette.asm (43) | great_wall/gw82_archer.asm (722)

### Area: great_wall - I179
- [ ] I179: great_wall/gw82_eyesore.asm (174) | great_wall/gw82_fire_bug.asm (194) | great_wall/gw82_necklace_stone.asm (75)
- [ ] I180: great_wall/gw82_wall_spear.asm (44) | great_wall/gw83_asp.asm (576) | great_wall/sand_fanger_lair/gw8A_sand_fanger.asm (1619)
- [ ] I181: great_wall/sand_fanger_lair/spm_sandfanger.sprite.asm (989) | great_wall/spm_greatwall_sprites.sprite.asm (1312) | great_wall/wall_dive/gw83_lily.asm (77)
- [ ] I182: great_wall/wall_dive/gw83_switch.asm (42) | great_wall/wall_entrance/gw82_trail_intro.asm (31) | great_wall/wall_inner/gw8B_lance_lily.asm (184)
- [ ] I183: great_wall/wall_rampway/gw85_long_switch_spear.asm (31) | great_wall/wall_rampway/gw85_multi_switch_spear.asm (31) | great_wall/wall_rampway/gw85_retractable_gate.asm (31)
- [ ] I184: great_wall/wall_rampway/gw85_short_switch_spear.asm (31) | great_wall/wall_rampway/gw85_spin_dash_gate.asm (39) | great_wall/wall_tomb/gw88_short_wall_spear.asm (41)
- [ ] I185: great_wall/wall_tomb/gw88_tomb_dark_space.asm (38) | euro/dark_chapel/eu9D_altar.asm (63) | euro/dark_chapel/eu9D_bones.asm (25)

### Area: euro - I186
- [ ] I186: euro/dark_chapel/eu9D_slaves.asm (73) | euro/eu91_men1.asm (136) | euro/eu91_men2.asm (67)
- [ ] I187: euro/eu91_women1.asm (108) | euro/eu91_women2.asm (73) | euro/euro/eu91_book.asm (28)
- [ ] I188: euro/euro/eu91_crate.asm (31) | euro/euro/eu91_intro.asm (95) | euro/euro/eu91_merchant.asm (206)
- [ ] I189: euro/euro/eu91_merchant_counter.asm (122) | euro/euro/eu91_peeking_man.asm (35) | euro/euro/eu91_shop_door.asm (23)
- [ ] I190: euro/euro/eu91_shop_queue.asm (390) | euro/euro/spm_euro_sprites.sprite.asm (738) | euro/euro_bg_scroll_actor.asm (18)
- [ ] I191: euro/flea_market/eu97_clerk1.asm (56) | euro/flea_market/eu97_clerk2.asm (54) | euro/flea_market/eu97_dark_medicine.asm (69)
- [ ] I192: euro/flea_market/eu97_life_medicine.asm (66) | euro/friezers_house/eu9A_friezer.asm (31) | euro/friezers_house/eu9A_max.asm (31)
- [ ] I193: euro/friezers_house/eu9A_rudy.asm (31) | euro/geezer_central/eu92_erasquez.asm (43) | euro/geezer_central/eu92_rofsky.asm (49)
- [ ] I194: euro/guest_room/eu96_erik.asm (39) | euro/guest_room/eu96_kara.asm (69) | euro/guest_room/eu96_neil.asm (127)
- [ ] I195: euro/power_house/eu93_found.asm (40) | euro/rolek_mansion/eu95_ann.asm (101) | euro/rolek_mansion/eu95_neil.asm (46)
- [ ] I196: euro/rolek_mansion/eu95_neils_father.asm (60) | euro/rolek_mansion/eu95_neils_mother.asm (47) | euro/rolek_office/eu94_employee.asm (38)
- [ ] I197: euro/spm_euro_geezers_sprites.sprite.asm (847) | native_village/gorgon_hut/nvAE_erik.asm (48) | native_village/gorgon_hut/nvAE_kara.asm (97)

### Area: native_village - I198
- [ ] I198: native_village/gorgon_hut/nvAE_stone_girl1.asm (55) | native_village/gorgon_hut/nvAE_stone_girl2.asm (70) | native_village/gorgon_hut/nvAE_stone_girl3.asm (52)
- [ ] I199: native_village/native_village/native_village_sine_hdma.asm (24) | native_village/native_village/nvAC_beckon_kid.asm (98) | native_village/native_village/nvAC_bones.asm (33)
- [ ] I200: native_village/native_village/nvAC_bonfire.asm (27) | native_village/native_village/nvAC_dumpling_man.asm (115) | native_village/native_village/nvAC_erik.asm (77)
- [ ] I201: native_village/native_village/nvAC_hamlet.asm (165) | native_village/native_village/nvAC_hand_man.asm (97) | native_village/native_village/nvAC_kara.asm (211)
- [ ] I202: native_village/native_village/nvAC_map_kid.asm (67) | native_village/native_village/nvAC_staring_man.asm (103) | native_village/native_village/nv_village_event_sprite.asm (24)
- [ ] I203: native_village/spm_village_sprites.sprite.asm (1090) | native_village/vacant_hut/nvAD_erik.asm (41) | native_village/vacant_hut/nvAD_hamlet.asm (41)
- [ ] I204: native_village/vacant_hut/nvAD_kara.asm (63) | dao/dao/daC3_babel_travel_spirit.asm (67) | dao/dao/daC3_carpet_man.asm (26)

### Area: dao - I205
- [ ] I205: dao/dao/daC3_freedom_man.asm (26) | dao/dao/daC3_jackal_girl.asm (32) | dao/dao/daC3_kruk1.asm (29)
- [ ] I206: dao/dao/daC3_kruk2.asm (29) | dao/dao/daC3_luggage_man.asm (96) | dao/dao/daC3_man1.asm (37)
- [ ] I207: dao/dao/daC3_merchant.asm (29) | dao/dao/daC3_moving_kruk.asm (37) | dao/dao/daC3_prisoner.asm (55)
- [ ] I208: dao/dao/daC3_sandy.asm (25) | dao/dao/daC3_slaver.asm (30) | dao/dao/daC3_training_man.asm (57)
- [ ] I209: dao/dao/daC3_treasure_man.asm (30) | dao/dao/dao_sine_hdma_slow.asm (22) | dao/dao/dao_window_mask.asm (22)
- [ ] I210: dao/dao_dorm/daC8_neil.asm (69) | dao/dao_hotel/daC4_erik.asm (30) | dao/dao_hotel/daC4_kara.asm (54)
- [ ] I211: dao/desert_explorers/daC7_explorer1.asm (26) | dao/desert_explorers/daC7_explorer2.asm (26) | dao/desert_explorers/daC7_explorer3.asm (25)
- [ ] I212: dao/indecision_room/daC9_businessman.asm (38) | dao/panic_room/daC6_snake_panic.asm (226) | dao/spm_dao_sprites.sprite.asm (932)
- [ ] I213: dao/sweatshop/daC5_slaver.asm (30) | dao/sweatshop/daC5_weaver.asm (84) | pyramid/CollisionLayerRenderer.asm (116)

### Area: pyramid - I214
- [ ] I214: pyramid/heiroglyph_room/pyDA_lithograph1.asm (59) | pyramid/heiroglyph_room/pyDA_lithograph2.asm (49) | pyramid/heiroglyph_room/pyDA_lithograph3.asm (47)
- [ ] I215: pyramid/heiroglyph_room/pyDA_lithograph4.asm (47) | pyramid/heiroglyph_room/pyDA_lithograph5.asm (47) | pyramid/heiroglyph_room/pyDA_lithograph6.asm (48)
- [ ] I216: pyramid/mummy_queen_lair/mummy_queen_angle_table.asm (12) | pyramid/mummy_queen_lair/pyDD_mummy_queen.asm (630) | pyramid/mummy_queen_lair/pyDD_mystic_statue.asm (48)
- [ ] I217: pyramid/mummy_queen_lair/pyDD_queen_arena_boundary.asm (41) | pyramid/mummy_queen_lair/pyDD_queen_debris.asm (60) | pyramid/mummy_queen_lair/pyDD_queen_invincible_orb.asm (18)
- [ ] I218: pyramid/mummy_queen_lair/pyDD_queen_orb_shot.asm (155) | pyramid/mummy_queen_lair/pyDD_queen_phase_transition.asm (103) | pyramid/mummy_queen_lair/pyDD_queen_spirit_attack.asm (111)
- [ ] I219: pyramid/mummy_queen_lair/pyDD_teleporter.asm (208) | pyramid/mummy_queen_lair/spm_mummyqueen.sprite.asm (1455) | pyramid/puzzle_room/pyCD_explorer.asm (45)
- [ ] I220: pyramid/puzzle_room/pyCD_flame_statue.asm (78) | pyramid/puzzle_room/pyCD_jackal.asm (258) | pyramid/puzzle_room/pyCD_kara.asm (140)
- [ ] I221: pyramid/puzzle_room/pyCD_puzzle.asm (172) | pyramid/puzzle_room/spm_pyramid_puzzle_sprites.sprite.asm (821) | pyramid/pyCC_blaster.asm (127)
- [ ] I222: pyramid/pyCC_mystic_ball.asm (259) | pyramid/pyCE_tuts.asm (283) | pyramid/pyD0_breakable_wall.asm (138)
- [ ] I223: pyramid/pyD2_haunt.asm (297) | pyramid/py_death_particle.asm (25) | pyramid/pyramid_dangerslide_b/pyD9_dangerslide_controller.asm (160)
- [ ] I224: pyramid/pyramid_main/pyCC_dark_space_portal.asm (43) | pyramid/pyramid_main/pyCC_entrance_portal.asm (63) | pyramid/pyramid_main/pyCC_portal.asm (73)
- [ ] I225: pyramid/pyramid_trickle_a/pyD4_falling_orb.asm (94) | pyramid/pyramid_vader_a/pyD6_vader_barrier_lower.asm (98) | pyramid/pyramid_vader_a/pyD6_vader_barrier_upper.asm (111)
- [ ] I226: pyramid/pyramid_vader_b/pyD7_sliding_wall.asm (159) | pyramid/spm_pyramid_sprites.sprite.asm (1074) | babel_tower/babel_entrance/btDE_kara_missing.asm (116)

### Area: babel_tower - I227
- [ ] I227: babel_tower/babel_entrance/btDE_monologue.asm (68) | babel_tower/babel_entrance/btDE_olman.asm (122) | babel_tower/babel_exterior/btE2_brought_back.asm (95)
- [ ] I228: babel_tower/babel_flight/btDC_plane_jumping.asm (95) | babel_tower/babel_light_elevator/babel_elevator_color_add.asm (23) | babel_tower/babel_light_elevator/btE1_comet_soon.asm (136)
- [ ] I229: babel_tower/babel_light_elevator/btE1_light_elevator.asm (93) | babel_tower/babel_lower_floors/btDF_crystal_ring.asm (141) | babel_tower/babel_lower_floors/btDF_kara.asm (84)
- [ ] I230: babel_tower/babel_lower_floors/btDF_spirits.asm (92) | babel_tower/babel_middle_floors/btE0_crystal_gate_a.asm (24) | babel_tower/babel_middle_floors/btE0_crystal_gate_b.asm (24)
- [ ] I231: babel_tower/babel_middle_floors/btE0_crystal_gate_c.asm (23) | babel_tower/babel_middle_floors/btE0_crystal_gate_d.asm (24) | babel_tower/babel_rooftop/btE4_kara.asm (192)
- [ ] I232: babel_tower/babel_rooftop/btE4_olman.asm (259) | babel_tower/babel_upper_floors/btE3_crystal_gate.asm (24) | babel_tower/babel_upper_floors/btE3_dao_travel_spirit.asm (63)
- [ ] I233: babel_tower/babel_upper_floors/btE3_kara.asm (64) | babel_tower/bt_static_sprite.asm (16) | babel_tower/comet_lair/comet_lair_hdma_a.asm (25)
- [ ] I234: babel_tower/comet_lair/comet_lair_hdma_b.asm (22) | babel_tower/comet_lair/comet_lair_hdma_c_timed.asm (43) | babel_tower/comet_lair/sE8_comet_display_config.asm (134)
- [ ] I235: babel_tower/comet_lair/sE8_dark_gaia.asm (1010) | babel_tower/comet_lair/sprite_1607B0.sprite.asm (847) | babel_tower/dark_castoth_lair/dark_castoth_layer_config.asm (25)
- [ ] I236: babel_tower/sine_hdma_ending_wave.asm (35) | babel_tower/space_flight/sE7_space_bg_scroll.asm (26) | babel_tower/space_flight/sE7_space_flight_controller.asm (213)
- [ ] I237: babel_tower/space_flight/spm_babel_spaceflight_sprites.sprite.asm (64) | mu/mu5F_cyclops.asm (622) | mu/mu5F_flasher.asm (256)

### Area: mu - I238
- [ ] I238: mu/mu60_floor_spikes.asm (43) | mu/mu60_force_ball.asm (152) | mu/mu60_plasma_chain.asm (131)
- [ ] I239: mu/mu_altar_room/mu66_altar1.asm (40) | mu/mu_altar_room/mu66_altar2.asm (22) | mu/mu_altar_room/mu66_altar_dialog.asm (40)
- [ ] I240: mu/mu_altar_room/mu66_rama_spirits.asm (205) | mu/mu_connector/mu64_switch_spikes.asm (37) | mu/mu_prayer_room/mu63_spirits.asm (164)
- [ ] I241: mu/mu_south/mu61_hint.asm (31) | mu/mu_tint_and_wave.asm (46) | mu/mu_vampire_lair/mu67_bomb.asm (189)
- [ ] I242: mu/mu_vampire_lair/mu67_erik.asm (99) | mu/mu_vampire_lair/mu67_kara.asm (42) | mu/mu_vampire_lair/mu67_lair_curtain.asm (24)
- [ ] I243: mu/mu_vampire_lair/mu67_neil_lily.asm (98) | mu/mu_vampire_lair/mu67_vampires.asm (1347) | mu/mu_vampire_lair/spm_vampires.sprite.asm (1302)
- [ ] I244: mu/mu_west/mu62_hope_statue.asm (71) | mu/spm_mu_enemies.sprite.asm (1563) | seaside_palace/palace_coffins/palace_coffin_hdma_table.asm (48)

### Area: seaside_palace - I245
- [ ] I245: seaside_palace/palace_coffins/sine_hdma_dual_channel.asm (23) | seaside_palace/palace_coffins/sp5C_key_coffin.asm (99) | seaside_palace/palace_coffins/sp5C_stone_coffin.asm (155)
- [ ] I246: seaside_palace/palace_fountain/palace_fountain_palette.asm (43) | seaside_palace/palace_fountain/sp5D_fountain.asm (116) | seaside_palace/palace_main/sp5A_monologue.asm (63)
- [ ] I247: seaside_palace/palace_main/sp5A_phantom_ribber.asm (73) | seaside_palace/palace_main/sp5A_villagers.asm (187) | seaside_palace/palace_main/sp5A_voice.asm (73)
- [ ] I248: seaside_palace/palace_passageway/sp5E_passageway.asm (30) | seaside_palace/palace_rooms/sp5B_erik.asm (44) | seaside_palace/palace_rooms/sp5B_kara.asm (43)
- [ ] I249: seaside_palace/palace_rooms/sp5B_lance.asm (43) | seaside_palace/palace_rooms/sp5B_lily.asm (75) | seaside_palace/palace_rooms/sp5B_neil.asm (43)
- [ ] I250: seaside_palace/palace_scroll_brightness.asm (35) | seaside_palace/sp5C_skuddle.asm (366) | seaside_palace/sp5C_slipper.asm (351)

### Area: mountain_temple - I251
- [ ] I251: mountain_temple/kress_circuit/mtA5_mushroom_drop_gate_a.asm (49) | mountain_temple/kress_circuit/mtA5_mushroom_drop_gate_b.asm (57) | mountain_temple/kress_crossroads/mtA2_mushroom_drop_gate.asm (48)
- [ ] I252: mountain_temple/kress_entrance/mtA0_intro.asm (32) | mountain_temple/movement_speed_zones.asm (148) | mountain_temple/mtA0_acid_spider.asm (738)
- [ ] I253: mountain_temple/mtA0_skulker.asm (231) | mountain_temple/mtA1_fire_sprite.asm (431) | mountain_temple/mtA1_yorrick_ew.asm (202)
- [ ] I254: mountain_temple/mtA1_yorrick_ns.asm (193) | mountain_temple/spm_kress_sprites.sprite.asm (914) | gold_ship/adrift/dc2F_adrift.asm (619)

### Area: gold_ship - I255
- [ ] I255: gold_ship/adrift/dc2F_adrift_fx.asm (22) | gold_ship/dream/dream_palette_loop.asm (24) | gold_ship/dream/dream_zoom_controller.asm (41)
- [ ] I256: gold_ship/dream/gs2A_shira.asm (82) | gold_ship/gs_gold_ship_intro_text.asm (6) | gold_ship/ship_gold/gs2C_crew1.asm (25)
- [ ] I257: gold_ship/ship_gold/gs2C_crew2.asm (47) | gold_ship/ship_gold/gs2C_crew3.asm (46) | gold_ship/ship_gold/gs2C_crew4.asm (26)
- [ ] I258: gold_ship/ship_gold/gs2C_crew5.asm (36) | gold_ship/ship_gold/gs2C_crow_crew.asm (108) | gold_ship/ship_gold/gs2C_descent.asm (79)
- [ ] I259: gold_ship/ship_gold/gs2C_rain_particle.asm (18) | gold_ship/ship_gold/gs2C_rain_spawner.asm (42) | gold_ship/ship_gold_interior/gs2E_crew0.asm (28)
- [ ] I260: gold_ship/ship_gold_interior/gs2E_crew1.asm (26) | gold_ship/ship_gold_interior/gs2E_crew2.asm (56) | gold_ship/ship_gold_interior/gs2E_crew3.asm (25)
- [ ] I261: gold_ship/ship_gold_interior/gs2E_queen.asm (61) | gold_ship/ship_gold_interior/gs2E_sleep.asm (94) | gold_ship/ship_wreck/gs2B_bones.asm (34)
- [ ] I262: gold_ship/ship_wreck/gs2B_erik.asm (235) | gold_ship/ship_wreck/gs2B_seth.asm (49) | gold_ship/ship_wreck/gs2B_wreck_wave_motion.asm (212)
- [ ] I263: gold_ship/ship_wreck_interior/gs2D_kara.asm (35) | gold_ship/ship_wreck_interior/gs2D_lance.asm (65) | gold_ship/ship_wreck_interior/gs2D_lily.asm (135)
- [ ] I264: gold_ship/ship_wreck_interior/gs2D_mummy.asm (43) | gold_ship/spm_goldship_sprites.sprite.asm (696) | nazca/nazca/na4B_buried_tile.asm (131)

### Area: nazca - I265
- [ ] I265: nazca/nazca/na4B_erik.asm (74) | nazca/nazca/na4B_kara.asm (109) | nazca/nazca/na4B_lance.asm (74)
- [ ] I266: nazca/nazca/na4B_lily.asm (113) | nazca/nazca/na4B_neil.asm (117) | nazca/nazca/na4B_spirit.asm (51)
- [ ] I267: nazca/neils_cottage/na49_camera.asm (34) | nazca/neils_cottage/na49_erik.asm (39) | nazca/neils_cottage/na49_kara.asm (63)
- [ ] I268: nazca/neils_cottage/na49_lance.asm (76) | nazca/neils_cottage/na49_lily.asm (87) | nazca/neils_cottage/na49_neil.asm (139)
- [ ] I269: nazca/neils_cottage/na49_tank.asm (34) | nazca/neils_cottage/na49_telescope.asm (33) | nazca/neils_cottage/na49_wings.asm (35)
- [ ] I270: nazca/neils_cottage/spm_nazca_sprites.sprite.asm (1341) | sky_garden/garden_crash/garden_crash_cutscene.asm (227) | sky_garden/garden_descent/sp58_descent_cutscene.asm (67)

### Area: sky_garden - I271
- [ ] I271: sky_garden/garden_descent/sp58_missed_flight.asm (59) | sky_garden/garden_descent/sp58_monologue.asm (70) | sky_garden/garden_descent/sp58_red_eye.asm (88)
- [ ] I272: sky_garden/garden_descent/spm_descent_sprites.sprite.asm (398) | sky_garden/garden_main/sg4C_platforms.asm (119) | sky_garden/garden_main/sg4C_spirits.asm (76)
- [ ] I273: sky_garden/garden_southwest/sg51_statue.asm (45) | sky_garden/garden_southwest_underside/sg52_blocker_enemy_a.asm (61) | sky_garden/garden_southwest_underside/sg52_blocker_enemy_b.asm (70)
- [ ] I274: sky_garden/garden_southwest_underside/sg52_switch.asm (53) | sky_garden/garden_west_underside/sg54_pressure_switch.asm (32) | sky_garden/sg4C_auto_advance.asm (29)
- [ ] I275: sky_garden/sg4D_cyber.asm (1474) | sky_garden/sg4D_dynapede.asm (367) | sky_garden/sg4D_jump_handler.asm (91)
- [ ] I276: sky_garden/sg4D_knight_armor.asm (626) | sky_garden/sg4E_nitropede.asm (552) | sky_garden/sg4E_plasma_snake.asm (159)
- [ ] I277: sky_garden/sg___hint_spirit.asm (30) | sky_garden/sg_bird_flight_patterns.asm (139) | sky_garden/spm_garden_enemies.sprite.asm (1680)
- [ ] I278: sky_garden/viper_lair/sg55_falling_tile.asm (29) | sky_garden/viper_lair/sg55_mystic_statue.asm (112) | sky_garden/viper_lair/sg55_viper.asm (1151)
- [ ] I279: sky_garden/viper_lair/sg55_viper_arena.asm (125) | sky_garden/viper_lair/spm_viper.sprite.asm (1273) | angkor_wat/angkor_entrance/awB0_intro.asm (32)

### Area: angkor_wat - I280
- [ ] I280: angkor_wat/angkor_inner_courtyard/awBA_bones.asm (49) | angkor_wat/angkor_inner_courtyard/awBA_glasses.asm (52) | angkor_wat/angkor_inner_gate/awB7_sliding_gate.asm (59)
- [ ] I281: angkor_wat/angkor_outer_courtyard/awB6_bones.asm (48) | angkor_wat/angkor_outer_east/awB2_stair_climb.asm (21) | angkor_wat/angkor_outer_north/awB3_vine_reveal.asm (52)
- [ ] I282: angkor_wat/angkor_pinnacle/awBF_spirit_guide.asm (132) | angkor_wat/angkor_shrine_crystal/awBC_blinding_light.asm (57) | angkor_wat/angkor_shrine_crystal/awBC_bouncing_crystal.asm (64)
- [ ] I283: angkor_wat/awB0_shrubber.asm (119) | angkor_wat/awB0_zip_fly.asm (339) | angkor_wat/awB0_zombie.asm (686)
- [ ] I284: angkor_wat/awB1_goldcap.asm (202) | angkor_wat/awB1_gorgon.asm (400) | angkor_wat/awB1_wall_walker.asm (546)
- [ ] I285: angkor_wat/awBD_fall_trigger.asm (67) | angkor_wat/aw_spirit_follower.asm (99) | angkor_wat/future_vision/future_vision_cutscene.asm (178)
- [ ] I286: angkor_wat/snake_pit/awB4_snake_pit_entry.asm (81) | angkor_wat/snake_pit/awB4_snake_pit_fx.asm (21) | angkor_wat/spm_angkor_interior_sprites.sprite.asm (1002)
- [ ] I287: angkor_wat/spm_angkor_outer_sprites.sprite.asm (1214) | mansion/mansion/sE9_mansion_intro.asm (54) | mansion/solid_arm_lair/btEA_conveyor_controller.asm (135)

### Area: mansion - I288
- [ ] I288: mansion/solid_arm_lair/sEA_solid_arm.asm (359) | mansion/solid_arm_lair/spm_solidarm.sprite.asm (1443) | ending/ending_changed_world/s90_changed_world.asm (78)

### Area: ending - I289
- [ ] I289: ending/ending_class_dismissed/sF0_class_dismissed.asm (211) | ending/ending_class_dismissed/spm_ending_class_sprites.sprite.asm (592) | ending/ending_comet/ending_comet_dma_setup.asm (23)
- [ ] I290: ending/ending_comet/ending_comet_sine_hdma.asm (25) | ending/ending_comet/sE5_epilogue.asm (263) | ending/ending_credits/CreditPositionLookup.asm (42)
- [ ] I291: ending/ending_credits/crF7_credits_camera_pan.asm (198) | ending/ending_credits/crF7_credits_dma_scroll.asm (131) | ending/ending_credits/crF7_credits_hdma_flicker.asm (38)
- [ ] I292: ending/ending_credits/sF7_credits.asm (827) | ending/ending_credits/sF7_credits_misc_timeline.asm (302) | ending/ending_credits/sF7_credits_npc_a.asm (213)
- [ ] I293: ending/ending_credits/sF7_credits_npc_b.asm (158) | ending/ending_credits/sF7_credits_npc_c.asm (115) | ending/ending_credits/sF7_credits_npc_d.asm (97)
- [ ] I294: ending/ending_credits/sF7_credits_npc_e.asm (62) | ending/ending_credits/sF7_credits_player.asm (410) | ending/ending_credits/spm_credits.sprite.asm (573)
- [ ] I295: ending/ending_credits/spm_ending_credits_sprites.sprite.asm (1235) | ending/ending_new_babel/s89_new_babel.asm (49) | unused/AttackTrailShort_unused.asm (36)

### Unused code (unused/) - I296
- [ ] I296: unused/CopyRefActorPos_unused.asm (13) | unused/InitSmoothFollowChase_unused.asm (35) | unused/SceneTransPaletteThinker_unused.asm (92)
- [ ] I297: unused/babel_palette_65_unused.asm (18) | unused/dark_rewards.asm (230) | unused/dma_setup_variant_unused.asm (24)
- [ ] I298: unused/empty_stub_unused.asm (14) | unused/gen_hdma_sine_oneshot_unused.asm (27) | unused/hint_npc.asm (184)
- [ ] I299: unused/mode7_perspective_unused.asm (300) | unused/native_village_dup_unused.asm (22) | unused/palette_buffer_clear_unused.asm (31)
- [ ] I300: unused/palette_loop_flash_unused.asm (19) | unused/sc01_unused_null_npc.asm (15) | unused/speed_zone_ns_fast_unused.asm (48)
- [ ] I301: unused/unused_debug_input_test.asm (48) | unused/unused_debug_mode.asm (74) | unused/unused_follow_chain.asm (32)
- [ ] I302: unused/unused_kara_dialog.asm (42) | unused/unused_mode7_boss.asm (1998) | unused/unused_null_actor.asm (14)
- [ ] I303: unused/unused_proximity_check_noref.asm (20) | unused/unused_random_position_noref.asm (21) | unused/unused_window_config.asm (21)