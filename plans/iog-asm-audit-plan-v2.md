# IOG ASM Full Audit Plan — v2

> Replaces the original plan. See [prior session](f1b0ef1e-85d5-4749-bbfd-692c1331240f) for context on what went wrong.

## Current Baseline (2026-09-19)

| Resource | Count |
|---|---|
| Block notes | 200 (bank00: 117, bank01: 20, bank02: 30, bank03: 27, bank08: 1, bank0B: 5) |
| Part notes | 972 (bank00: 299, bank01: 39, bank02: 320, bank03: 250, bank08: 35, bank0B: 29) |
| Inline comments | 6,914 (bank00: 1,978, bank02: 2,977, bank03: 1,636, bank08: 180, bank09: 6, bank0B: 137) |
| Named addresses | 1,706 (only 6 generic `loc_` labels remain) |
| Total .asm files | 892 |

### What was accomplished in the prior session

- Audited and fixed comments in 19 engine files (listed below)
- Fixed opcode count in `cop_dispatch` block/part notes (172 → 209)
- Fixed handler block count (15 → 13 confirmed)
- Removed 107 contaminated `cop_handlers_movement` comments from `cop_handlers_flags` range
- Fixed ~50 semantic mismatches (LDA/"Store", STA/"Load", BEQ with inverted conditions)
- **Net result:** bank00 grew from 437 → 1,999 (+1,562 new comments)

### What was lost

~1,065 comments were lost during bulk cleanup scripts that:
1. Emptied JSON files to build "clean" address maps (destroying the comparison baseline)
2. Bulk-shifted addresses by ±1 (kept wrong copy, dropped good copy)
3. Aggressively deduplicated entries (removed valid comments at adjacent addresses)

**CRITICAL:** Read `gaia-core/docs/notes-and-comments.md` → "Critical Rules for Comment JSON Manipulation" before making ANY bulk edits.

---

## Safety Protocol (MANDATORY for every phase)

Before making annotation changes:

1. **Ask the user to commit** — agents must NEVER run `git commit`. Prompt: "Please commit the current notes state before I proceed."
2. **Edit `.asm` files, not JSON** — use `npm run extract:lt` to produce address-tagged output, edit the `.asm` file directly, then run `npm run ingest` to synchronize changes to `notes/` JSON
3. **One file at a time** — edit, ingest, re-extract, verify, then next file
4. **Never empty JSON files** — the ingest script handles deletions safely (scoped to processed files only)
5. **Never bulk-shift addresses** — fix individually by reading `extract:lt` output
6. **Verify immediately** — after ingesting, run standard `extract` and confirm each comment appears on the correct instruction

### The ingest workflow

```
npm run extract:lt          → Address-tagged .asm output
Edit the .asm file          → Add/update/remove block notes, part notes, inline comments
npm run ingest              → Synchronize edits into notes/ JSON (adds, updates, AND deletes)
npm run extract             → Verify final output reads naturally
```

**Deletions:** To remove an annotation, delete it from the `.asm` file and run `npm run ingest`:
- **Block note:** Remove `; ` lines at the top of the file (before the first `-----`)
- **Part note:** Remove `; ` lines before a label
- **Comment:** Clear the text after `; {address}` (keep the tag: `; {39414}` instead of `; {39414} old text`)

**Dry run:** Use `npm run ingest:dry` to preview changes without writing. Use `npm run ingest:verbose` for detailed output.

See `gaia-core/docs/notes-and-comments.md` → "Implemented: Notes Ingestion Script" for full reference.

---

## Files by Category

### Engine Core (49 files) — `extracted/system/engine/`

**Previously audited (19 files):**
- [x] `system_core.asm`
- [x] `cop_dispatch.asm`
- [x] `cop_handlers_flow.asm`
- [x] `cop_handlers_flags.asm`
- [x] `cop_handlers_solid.asm`
- [x] `cop_handlers_sprite.asm`
- [x] `cop_handlers_player_sprite.asm`
- [x] `cop_handlers_effects.asm`
- [x] `cop_handlers_lifecycle.asm`
- [x] `cop_handlers_movement.asm`
- [x] `cop_handlers_spatial.asm`
- [x] `cop_handlers_audio.asm`
- [x] `cop_handlers_input.asm`
- [x] `cop_handlers_palette.asm`
- [x] `cop_handlers_map.asm`
- [x] `cop_handlers_spawn.asm`
- [x] `actor_pool.asm`
- [x] `combat_collision.asm`
- [x] `player_character.asm` (partially — only referenced)

**Not yet audited (30 files):**
- [ ] `actor_execution.asm`
- [ ] `camera_scroll.asm`
- [ ] `camera_tilemap.asm`
- [ ] `ConsoleStringRenderer.asm`
- [ ] `DialogStringRenderer.asm`
- [ ] `DisplaySceneTitle.asm`
- [ ] `DmaWordToVram.asm`
- [ ] `event_blocks.asm`
- [ ] `forced_walk.asm`
- [ ] `GetPlayerFacingDirection.asm`
- [ ] `GlobalInputHandler.asm`
- [ ] `hardware_math.asm`
- [ ] `hdma_dma_spc.asm`
- [ ] `map_coords.asm`
- [ ] `MenuSelectionHandler.asm`
- [ ] `music_actors.asm`
- [ ] `oam_digit_compose.asm`
- [ ] `QuintetLzDecompress.asm`
- [ ] `radar_map_screen.asm`
- [ ] `save_system.asm`
- [ ] `scene_lifecycle.asm`
- [ ] `scene_script.asm`
- [ ] `smooth_follow.asm`
- [ ] `spc_transfer.asm`
- [ ] `sprite_composition.asm`
- [ ] `stair_climb.asm`
- [ ] `system_init.asm`
- [ ] `thinker_execution.asm`
- [ ] `tile_collision_physics.asm`
- [ ] `vblank_joypad.asm`
- [ ] `warps_interaction.asm`

### Player System (7 files) — `extracted/system/player/`
All audited (Phase 3 complete).

### Remaining System Files (28 files) — `extracted/system/` (non-engine, non-player)
All audited (Phase 4 complete). Includes inventory, world map, diary menu, dark space, boot logos, title screen, functions, statue inventory, and data tables.

### Actors (29 files) — `extracted/actors/`
Shared enemy/NPC actor scripts. All unaudited.

### Thinkers (18 files) — `extracted/thinkers/`
Shared AI/behavior scripts. All unaudited.

### Functions (27 files) — `extracted/functions/`
Shared utility functions. All unaudited.

### Data Tables (37 files) — `extracted/tables/`
Static data tables. Block/part notes only (no inline comments needed for pure data).

### Scene Scripts (~600 files) — `extracted/<location>/`
COP scripts for each game scene/map. Biggest category by far.

### Unused (25 files) — `extracted/unused/`
Dead/unreachable code. Low priority — verify existing notes only.

---

## Phased Execution Plan

### Phase 1: Re-verify previously audited engine files

**Goal:** Confirm the 19 files audited in the prior session have correct, verified comments.

**Method per file:**
1. Run `npm run extract:lt`
2. Read the file — every commented line shows `; {addr} comment text`
3. Verify each comment describes the instruction it's attached to
4. Fix mismatches by editing the `.asm` file directly (correct text, remove bad comments, add missing ones)
5. Run `npm run ingest` to synchronize edits into `notes/` JSON
6. Run `npm run extract` to verify the final output
7. Ask the user to `git commit` after each file

**Files (in priority order):**
1. `cop_handlers_flags.asm` — had 107 contaminated entries removed; re-verify replacement comments
2. `cop_handlers_movement.asm` — source of contamination; verify its own comments
3. `cop_handlers_effects.asm` — had 12 specific fixes
4. `cop_handlers_lifecycle.asm` — had INC $0A semantic fixes
5. `cop_handlers_sprite.asm` — had BEQ condition fixes
6. `cop_handlers_spatial.asm` — had INC $0A fix
7. `system_core.asm` — first file audited; verify HP/defense corrections
8. `cop_dispatch.asm` — verify opcode count fix (209)
9. `cop_handlers_flow.asm`
10. `cop_handlers_solid.asm`
11. `cop_handlers_player_sprite.asm`
12. `cop_handlers_audio.asm`
13. `cop_handlers_input.asm`
14. `cop_handlers_palette.asm`
15. `cop_handlers_map.asm`
16. `cop_handlers_spawn.asm`
17. `actor_pool.asm`
18. `combat_collision.asm`
19. `player_character.asm`

**Estimated scope:** ~2 hours. Mostly verification, minimal new writing.

### Phase 2: Complete remaining engine files

**Goal:** Audit and document the remaining 30 engine files.

**Method per file:**
1. Read the standard extracted `.asm` file end-to-end
2. Run `npm run extract:lt` to get address-tagged output
3. Edit the `.asm` file directly:
   - Add/update/remove block note at the top of file
   - Add/update/remove part notes before labels
   - Add/update/remove inline comments after `; {address}` tags
   - Follow comment density guidelines from `notes-and-comments.md`
4. Audit `names.json` labels for this file's address range (rename generic labels)
5. Run `npm run ingest` to synchronize all edits to `notes/` JSON
6. Run `npm run extract` (standard), verify output reads naturally
7. Ask the user to `git commit` after each file or small batch

**Priority order (complex/critical first):**
1. `scene_lifecycle.asm` — scene management, high importance
2. `actor_execution.asm` — actor main loop
3. `thinker_execution.asm` — thinker/AI main loop
4. `tile_collision_physics.asm` — collision system
5. `camera_scroll.asm` + `camera_tilemap.asm` — camera system
6. `DialogStringRenderer.asm` + `ConsoleStringRenderer.asm` — text rendering
7. `hdma_dma_spc.asm` — hardware DMA
8. `vblank_joypad.asm` — VBlank/NMI handler
9. `system_init.asm` — boot sequence
10. `save_system.asm` — save/load
11. `warps_interaction.asm` — warp/door system
12. `scene_script.asm` — COP script interpreter
13. `event_blocks.asm` — event/trigger system
14. `sprite_composition.asm` — sprite assembly
15. `GlobalInputHandler.asm` — input processing
16. `MenuSelectionHandler.asm` — menu navigation
17. `radar_map_screen.asm` — world map
18. `music_actors.asm` — music/SFX integration
19. `spc_transfer.asm` — SPC700 data transfer
20. `hardware_math.asm` — hardware multiply/divide
21. `map_coords.asm` — coordinate math
22. `oam_digit_compose.asm` — damage number display
23. `smooth_follow.asm` — smooth camera follow
24. `stair_climb.asm` — stair walking
25. `forced_walk.asm` — cutscene movement
26. `QuintetLzDecompress.asm` — LZ decompression
27. `DmaWordToVram.asm` — single VRAM DMA helper
28. `GetPlayerFacingDirection.asm` — direction query
29. `DisplaySceneTitle.asm` — scene title display
30. `player_character.asm` — complete the partial audit

**Estimated scope:** ~8 hours. Mix of verification and new documentation.

### Phase 3: Player movement system

**Goal:** Audit the 7 files in `extracted/system/player/`.

### Phase 4: Remaining system files

**Goal:** Audit the ~32 remaining system files (inventory, world map, UI, dialogue, cutscenes).

### Phase 5: Shared actors and thinkers

**Goal:** Document the 29 actor scripts and 18 thinker scripts in `extracted/actors/` and `extracted/thinkers/`.

### Phase 6: Shared functions

**Goal:** Document the 27 shared function files in `extracted/functions/`.

### Phase 7: Data tables

**Goal:** Verify and document the 37 data table files. Block/part notes only (no inline comments for pure data). Table format documentation is the priority.

### Phase 8: Scene scripts (location-specific)

**Goal:** Document the ~600 scene-specific COP scripts. This is the largest phase and will be broken into sub-phases by game region:

| Sub-phase | Location | Files |
|---|---|---|
| 8a | South Cape | 43 |
| 8b | Edward Castle | 50 |
| 8c | Itory Village | 22 |
| 8d | Diamond Mine | 24 |
| 8e | Incan Ruins | 35 |
| 8f | Gold Ship | 30 |
| 8g | Freejia | 51 |
| 8h | Diamond Mine / Sky Garden | 28 |
| 8i | Mu | 22 |
| 8j | Angel Village | 50 |
| 8k | Watermia | 33 |
| 8l | Great Wall | 20 |
| 8m | Euro | 36 |
| 8n | Native Village / Dao | 49 |
| 8o | Pyramid | 39 |
| 8p | Babel Tower | 32 |
| 8q | Seaside Palace / Angkor Wat | 42 |
| 8r | Ending / Prologue / Misc | 34 |

### Phase 9: Unused code

**Goal:** Verify the 25 unused files have accurate documentation. Low priority — these are dead/unreachable code paths.

---

## Per-File Audit Checklist

Use this for every file:

- [ ] Read the standard-extracted `.asm` file end-to-end
- [ ] `git commit` current notes state (snapshot before changes) — **ask the user to do this; agents must never commit**
- [ ] Run `npm run extract:lt` to get address-tagged output
- [ ] Edit the `.asm` file directly:
  - [ ] Verify/update block note: routine count matches, description accurate, no cross-file claims
  - [ ] Verify/update all part notes: exist for each named routine, description accurate
  - [ ] Add inline comments after `; {address}` tags in complex routines (NEVER compute addresses manually)
  - [ ] Remove any misplaced, redundant, or incorrect comments (clear text after the `; {addr}` tag)
- [ ] Audit `names.json` labels: no generic `code_XXXXXX`, names describe actual behavior
- [ ] Run `npm run ingest` to synchronize all edits into `notes/` JSON
- [ ] Run `npm run extract` (standard), read result — comments flow naturally, no clutter
- [ ] Ask the user to `git commit` the completed file's notes (agents must never commit)

---

## Progress Tracking

### Phase 1: Re-verify engine files
- [x] `cop_handlers_flags.asm` — fixed block note count (5+14+1, not 7+12+1), fixed 3 misplaced comments (LDA described next instruction)
- [x] `cop_handlers_movement.asm` — fixed 2 swapped bit numbers (14↔15 in MoveToward), removed redundant TickMoveComplete comment, fixed LDA forward-ref and RNG STA comment
- [x] `cop_handlers_effects.asm` — fixed 2 contaminated comments (BuildSineHdmaTable BNE/RTS from BuildSineLookupTable), fixed gravity PHA description, fixed BPL/STA/AND/BNE/REP misattributions, removed 3 redundant comments
- [x] `cop_handlers_lifecycle.asm` — fixed 3 misplaced comments (GetPlayerFacing LDA, MarkDeath LDA $12, Die BEQ), removed 3 redundant comments
- [x] `cop_handlers_sprite.asm` — fixed wrong operand label (sprTimer→X distance at 40670), wrong bit number ($0002=bit 1 not 2), forward-ref on ProcessAnimFlag call
- [x] `cop_handlers_spatial.asm` — verified clean, no fixes needed
- [x] `system_core.asm` — fixed 1 JSL comment ("Store" → "Execute" for scene transition call)
- [x] `cop_dispatch.asm` — verified clean, no fixes needed
- [x] `cop_handlers_flow.asm` — fixed 1 inverted BCC condition in BranchIfMissingItem
- [x] `cop_handlers_solid.asm` — fixed misattributed register load in ComputeDirectionToPlayer, reversed BEQ condition in BranchIfNotOnGridline
- [x] `cop_handlers_player_sprite.asm` — verified clean, no fixes needed
- [x] `cop_handlers_audio.asm` — verified clean, no fixes needed
- [x] `cop_handlers_input.asm` — verified clean, no fixes needed
- [x] `cop_handlers_palette.asm` — verified clean, no fixes needed
- [x] `cop_handlers_map.asm` — verified clean, no fixes needed
- [x] `cop_handlers_spawn.asm` — verified clean, no fixes needed
- [x] `actor_pool.asm` — fixed block note count (11 routines, not 12)
- [x] `combat_collision.asm` — verified clean, no fixes needed
- [x] `player_character.asm` — verified clean, no fixes needed

**Phase 1 complete.** All 19 previously audited files re-verified.

### Phase 2: Remaining engine files
- [x] `scene_lifecycle.asm` — fixed worldReadyFlag $0F0F→$000F in part note + inline, BG3SC "64×32"→"32×32" size
- [x] `actor_execution.asm` — fixed swapped link labels (prev.$06=new), "dead"→"input lock" in TRB $0088, 2 misleading "AND destroyed" reload comments
- [x] `thinker_execution.asm` — fixed same swapped link labels as actor_execution
- [x] `tile_collision_physics.asm` — verified clean, no fixes needed
- [x] `camera_scroll.asm` — removed 13 contaminated comments from direction/facing routine, fixed 1 centering offset
- [x] `camera_tilemap.asm` — verified clean, no fixes needed
- [x] `DialogStringRenderer.asm` — fixed 3 comments: border pointer +8→+4 bytes, $4000 Start→Y button, column width formula
- [x] `ConsoleStringRenderer.asm` — fixed 4 issues: enemy HP swap ($09E4/$09E6 roles), FillTile operand mislabeling, contaminated GiveItemToPlayer comment, block note table entry
- [x] `hdma_dma_spc.asm` — verified clean, no fixes needed
- [x] `vblank_joypad.asm` — fixed NMITIMEN bit 7/bit 0 swap in part notes, inline comments, and block note utility summary
- [x] `system_init.asm` — verified clean, no fixes needed
- [x] `hardware_math.asm` — verified clean, no fixes needed
- [x] `forced_walk.asm` — fixed 2 swapped direction/mask comments in ReadDirSprite_YVelocity
- [x] `stair_climb.asm` — fixed 1 misplaced comment (loop body text in landing path)
- [x] `smooth_follow.asm` — fixed 1 misplaced comment (8px anchor), 2 contaminated comments (equal deltas/angle text)
- [x] `map_coords.asm` — fixed 1 contaminated comment (shimmer actor/Shadow-only)
- [x] `oam_digit_compose.asm` — verified clean, no fixes needed
- [x] `music_actors.asm` — verified clean, no fixes needed
- [x] `save_system.asm` — verified clean, no fixes needed
- [x] `sprite_composition.asm` — verified clean, no fixes needed
- [x] `warps_interaction.asm` — fixed 1 comment: "A button" → "Up button" for $0800
- [x] `scene_script.asm` — fixed FindCurrentScene INY cascade skip sizes (part note + inline comment both wrong)
- [x] `event_blocks.asm` — verified clean, no fixes needed
- [x] `GlobalInputHandler.asm` — verified clean, no fixes needed
- [x] `MenuSelectionHandler.asm` — verified clean, no fixes needed
- [x] `spc_transfer.asm` — verified clean, no fixes needed
- [x] `radar_map_screen.asm` — verified clean, no fixes needed
- [x] `QuintetLzDecompress.asm` — verified clean, no fixes needed
- [x] `DmaWordToVram.asm` — verified clean, no fixes needed
- [x] `GetPlayerFacingDirection.asm` — verified clean, no fixes needed
- [x] `DisplaySceneTitle.asm` — verified clean, no fixes needed

**Phase 2 complete.** All 30 remaining engine files audited.

### Phase 3: Player movement system
- [x] `player_move_main.asm` — fixed 3 wrong direction labels in block note (west→east, south→north, east→south), fixed "player_move_ew"→"player_move_east" filename, fixed 1 MapCell inline mislabel
- [x] `player_move_ns.asm` — fixed "player_move_ew"→"player_move_south" and "player_move_ew"→"player_move_east" filename refs, fixed 9 MapCell direction mislabels (inline) + 14 MapCell mislabels (block/part notes)
- [x] `player_move_south.asm` — fixed 10 MapCell direction mislabels (inline) + 8 MapCell mislabels (block/part notes)
- [x] `player_move_east.asm` — fixed 6 MapCell direction mislabels (inline) + 6 MapCell mislabels (block/part notes)
- [x] `player_move_ramps.asm` — fixed 3 `_TEMP` artifacts, swapped ascend↔descend for WestRampUp/WestRampDown (part notes + inline), fixed 4 MapCell mislabels (inline) + 2 MapCell mislabels (block notes)
- [x] `player_move_diag.asm` — verified clean, no fixes needed (all MapCell labels correct)
- [x] `tile_collision.asm` — verified clean, no fixes needed

**Phase 3 complete.** All 7 player movement files audited. Major systematic finding: MapCell direction labels in 5 of 7 files had a consistent 90° CW rotation error (Right↔Down, Left↔Up). ~60 total fixes across inline comments, part notes, and block notes. Only `player_move_diag.asm` had correct labels.

### Phase 4: Remaining system files
- [x] `WorldMapController.asm` — verified clean, no fixes needed (world map controller lifecycle well-documented)
- [x] `HdmaWindowEffect.asm` — verified clean, no fixes needed
- [x] `world_map_options.asm` — verified clean, pure COP script data
- [x] `world_map_routes.asm` — verified clean, pure route data tables
- [x] `world_map_names.asm` — verified clean, pure name lookup data
- [x] `inventory_mgmt.asm` — verified clean, no fixes needed
- [x] `item_use_system.asm` — verified clean, no fixes needed (41 item handlers thoroughly documented)
- [x] `inventory_menu.asm` — **fixed 8 button label errors**: `$C040` mislabeled as "A/X" (is B+Y+X), `$4040` mislabeled as "B/X" (is Y+X), `$6040` mislabeled as "B/Y/X" (is Y+Select+X). 1 block note + 7 inline comment fixes.
- [x] `inventory_overlay.asm` — verified clean, no fixes needed (detailed save/restore lifecycle docs)
- [x] `inventory_statue_slot.asm` — verified clean, no fixes needed
- [x] `inventory_dma_setup.asm` — verified clean, small data file
- [x] `statue_inventory_reward.asm` — verified clean, no fixes needed
- [x] `sFA_diary_menu.asm` — **annotated from scratch**: 1 block note (menu structure, SRAM layout, button remap), 24 part notes (tab handlers, settings, SRAM helpers, camera pan, BCD formatter, VBlank handler), 77 inline comments
- [x] `diary_menu_window_dma.asm` — verified clean, small thinker with data tables
- [x] `strings_0BF706.asm` — verified, pure string data
- [x] `sE6_gaia.asm` — **annotated from scratch**: 1 block note (Dark Space architecture, transformation system, ability system), 35 part notes (room layouts, Gaia dialogue, HP heal, hint dispatch, save flow, all 6 transform animations, ability orb, firefly VFX, player restore), 186 inline comments
- [x] `sFB_actor_0BC8BA.asm` — **annotated from scratch**: 1 block note (boot logo sequence, PAL/NTSC detection), 2 part notes (second logo phase, PAL fallback), 17 inline comments
- [x] `boot_logo_palette_*.asm` (3 files) — already annotated with block notes
- [x] `sFC_actor_0BC924.asm` — **annotated from scratch**: 1 block note (title intro sequence, text timing), 2 part notes (comet sprite actor, palette fade), 19 inline comments
- [x] `sFC_actor_0BC9AE.asm` — **annotated from scratch**: 1 block note (Start button handler, diary transition), 1 part note (transition routine), 24 inline comments
- [x] `spm_*.sprite.asm` (4 files) — auto-generated sprite data, no audit needed
- [x] `vram_buffer_clear.asm` — verified clean, well-documented
- [x] `ShowDialogueFrame.asm` — verified clean, well-documented
- [x] `hdma_ramp_tables.asm` — verified clean, data table with block note
- [x] `event_block_table.asm` — verified clean, data table with block note
- [x] `music_pointer_array.asm` — verified clean, data table with block note
- [x] `math_lookup_tables.asm` — verified clean, data tables with block notes

**Phase 4 complete.** All 28 remaining system files audited. Findings:
- **inventory_menu.asm**: Fixed 8 button label errors (SNES physical button names wrong).
- **5 unannotated files**: Generated comprehensive annotations from scratch for `sFA_diary_menu.asm`, `sE6_gaia.asm`, `sFB_actor_0BC8BA.asm`, `sFC_actor_0BC924.asm`, and `sFC_actor_0BC9AE.asm`. Total: 5 new block notes, 64 new part notes, 323 new inline comments.

### Phase 5: Shared actors and thinkers (in progress)

**Unannotated files (9) — annotated from scratch:**
- [x] `camera_delta_oscillator.asm` — 1 block note, 1 part note, 5 inline comments. Named: `CameraDeltaOscillate`
- [x] `debug_stat_setter.asm` — 1 block note, 1 part note, 2 inline comments. Named: `DebugStatSetterInit`
- [x] `idle_sprite_display.asm` — 1 block note, 1 part note, 2 inline comments. Named: `IdleSpriteDisplayInit`
- [x] `particle_rain_spawner.asm` — 1 block note, 2 part notes, 13 inline comments. Named: `ParticleRainSpawnerLoop`, `ParticleRainChild`
- [x] `dark_space.asm` — 1 block note, 5 part notes, 29 inline comments. Named 6 labels: `DarkSpacePortalInit`, `DarkSpacePortalOpen`, `DarkSpacePortalOpenIdle`, `DarkSpaceInteractionMonitor`, `DarkSpaceButtonCheck`, `DarkSpaceEnterWarp`
- [x] `debug_man.asm` — 1 block note, 2 part notes, 17 inline comments. Named: `DebugManInteract`, `DebugManQuit`
- [x] `dialog_string_scanner.asm` — 1 block note, 2 part notes, 22 inline comments. Named: `IsStringPointer`
- [x] `jeweler_gem.asm` — 1 block note, 8 part notes, 28 inline comments. Named 17 labels including `JewelerInteract`, `JewelerCountJewels`, `JewelerRewardHerb/Def/Hp/Str/PsychoDash/DarkFriar`, `JewelerSecretRoom`, etc. BCD jewel counting noted.
- [x] `thinkers_05FB16.asm` — 1 block note, 9 part notes, 35 inline comments. Named 13 labels: `HdmaGradientSimpleEntry`, `HdmaGradientFullEntry`, `HdmaGradientBuildV1/V2`, `HdmaSegmentSplitDown/Up`, `HdmaParamChangeCheck`, `HdmaCompareParams`, etc.

**Audited existing actor files (fixes applied):**
- [x] `boss_clear_reward_handler.asm` — added 21 inline comments, 1 part note, 1 name (`BossRewardCheckInit`)
- [x] `camera_scroll_controller.asm` — fixed 8 contaminated comments (direction circles, OAM flip), added 1 name (`CameraScrollUpdate`)
- [x] `field_reveal_object.asm` — fixed block note "Dark Space field-reveal" → "Field-reveal"
- [x] `incan_ruins_transform_palette.asm` — added 14 inline comments across 3 phases

**Verified clean actors (no changes needed):**
- [x] `floor_button.asm`
- [x] `hidden_red_jewel.asm`
- [x] `hit_stagger_controller.asm`
- [x] `interaction_handlers.asm`
- [x] `large_ramps.asm`
- [x] `overworld_exit.asm`
- [x] `player_transition_handlers.asm`
- [x] `ramps.asm`
- [x] `reward_actors.asm`
- [x] `scene_flag_init.asm`
- [x] `smooth_follow_child.asm`
- [x] `town_door.asm`
- [x] `visual_effect_pipeline.asm`

**Audited existing thinker files (fixes applied):**
- [x] `global_ambient_dispatcher.asm` — fixed "TRB" → "AND+STA" in inline comment

**Verified clean thinkers (no changes needed):**
- [x] `ambient_palette_cycler.asm`
- [x] `flag_gated_palette_cool.asm`
- [x] `flag_gated_palette_warm.asm`
- [x] `hdma_gradient_thinker.asm` (renamed from `thinkers_05FB16.asm`)
- [x] `mode7_perspective.asm`
- [x] `oneshot_coldata_green_tint.asm`
- [x] `oneshot_coldata_warm_flash.asm`
- [x] `oneshot_palette_flash_18.asm`
- [x] `oneshot_palette_flash_19.asm`
- [x] `oneshot_palette_flash_1B.asm`
- [x] `oneshot_palette_flash_1C.asm`
- [x] `oneshot_palette_flash_1F.asm`
- [x] `oneshot_palette_flash_40.asm`
- [x] `palette_parent_child.asm`
- [x] `parallax_thinker.asm`
- [x] `sine_hdma_slow_wave.asm`

**Phase 5 complete.** All 25 actor files and 18 thinker files audited. 9 annotated from scratch, 5 had fixes applied, 29 verified clean. 46 new names added to `names.json`.

### Phase 6: Shared functions

**Goal:** Document the 27 shared function files in `extracted/functions/`.

**Annotated from scratch (7 unannotated files):**
- [x] `ActorDisplayModeSwap.asm` — 1 block note, 5 inline comments
- [x] `ActorMidpointCalc.asm` — 1 block note, 4 inline comments
- [x] `EnemyDefeatDispatch.asm` — 1 block note, 1 part note, 24 inline comments
- [x] `EnemyInitBasic.asm` — 1 block note, 4 inline comments
- [x] `EnemyPositionSnap.asm` — 1 block note, 15 inline comments
- [x] `RandomPlayerOffset.asm` — 1 block note, 4 inline comments
- [x] `SetPlayerGameOverFlag.asm` — 1 block note, 1 inline comment

**Audited existing files (fixes applied):**
- [x] `game_over_sequence.asm` — fixed 2 swapped comments: "Gems≥100" label was on gems<100 path, "No gems" label was on shared respawn path
- [x] `SpawnFieldRevealEffect.asm` — fixed block note "Dark Space room-clear" → "Dungeon room-clear", added 2 part notes (field_reveal_scatter, field_reveal_flash), 21 inline comments

**Verified clean (no changes needed):**
- [x] `ApplyOrbitalOffsetFromRef.asm`
- [x] `ApplyOrbitalOffsetXY.asm`
- [x] `ApplyPlayerHitstun.asm`
- [x] `camera_drift.asm`
- [x] `DarkGemDropSystem.asm`
- [x] `DeathPaletteFadeThinker.asm`
- [x] `EnemyDeathFlash.asm`
- [x] `EscortFollowPathTracker.asm`
- [x] `f_inventory_full.asm`
- [x] `InitPlayerScriptVariant.asm`
- [x] `npc_wander_ai.asm`
- [x] `NullActorScriptStub.asm`
- [x] `SpawnAttackTrailEffect.asm`
- [x] `SpawnDebrisBurst.asm`
- [x] `SpawnHitSparkSprites.asm`
- [x] `StandardEnemyDefeatHandler.asm`
- [x] `StopPlayerOnDeathAssign.asm`
- [x] `ToggleActorVisibilityFlag.asm`

**Phase 6 complete.** All 27 function files audited. 7 annotated from scratch, 2 had fixes, 18 verified clean.

### Phase 7: Data tables

**Goal:** Verify and document the 37 data table files. Block/part notes only (no inline comments for pure data).

**Annotated from scratch (21 files):**
- [x] 16 spriteset files (`spriteset_*.asm`) — added block notes describing character/effect sprite contents
- [x] `scene_meta.asm` — per-scene metadata records (tileset, tilemap, palette, music, collision)
- [x] `scene_actors.asm` — per-scene actor spawn lists
- [x] `scene_thinkers.asm` — per-scene thinker spawn lists
- [x] `inventory_spritemap.asm` — inventory UI sprite tile layouts
- [x] `palette_bundles.asm` — compressed palette data bundles

**Verified clean (16 files):**
- [x] `ability_anim_tables.asm`, `body_table.asm`, `dialog_dictionaries.asm`, `dialog_template_table.asm`, `direction_velocity_table.asm`, `display_preset_table.asm`, `enemy_clear_reward_table.asm`, `enemy_stats_table.asm`, `forced_walk_sequence_table.asm`, `item_component_table.asm`, `item_get_dialog_table.asm`, `movement_delta_table.asm`, `parallax_scroll_table.asm`, `scene_barrier_chest_table.asm`, `scene_warps.asm`, `system_strings.asm`

**Phase 7 complete.** All 37 data table files have block notes.

### Phase 8: Scene scripts (in progress)

**8a: South Cape — COMPLETE (41/41 files)**
All 41 scene files annotated with block notes describing NPC roles, dialog branches, and story context.

**8b: Edward Castle — COMPLETE (47/47 files)**
All 47 scene files annotated. Covers castle NPCs, prison sequence, aqueduct dungeon rooms, and aqueduct enemies.

**8c: Itory Village — COMPLETE (21/21 files)**
All 21 scene files annotated. Covers village NPCs, Elder exposition, Moon Tribe encounter, cave puzzles, and item pickups.

**8d: Diamond Mine — COMPLETE (23/23 files)**
All 23 scene files annotated. Covers mine enemies (Eye Stalker, Flayzer, Grundit), follower behavior, elevator, minecart, laborers, keys, and breakable walls.

**8e: Incan Ruins — COMPLETE (31/31 files)**
All 31 scene files annotated. Covers Castoth boss fight (~1,150 lines), Stone Guard, Stone Lord, Scuttlebug, Slugger, puzzle rooms, Larai Cliff, Wind Melody, gold tiles, and NPC dialogs.

**8f: Gold Ship — COMPLETE (27/27 files)**
All 27 scene files annotated. Covers adrift sequence (~608 lines), dream scene with Shira, Gold Ship NPCs, Freedan transformation, and crew dialog.

**8g: Freejia — COMPLETE (49/49 files)**
All 49 scene files annotated. Covers town NPCs, slave market, Dark Gem shop, laborers, quest progression, and area-specific dialog.

**8h: Sky Garden — COMPLETE (24/24 files)**
All 24 scene files annotated. Covers Viper boss, Dynapede, garden enemies, platform mechanics, and Sky Garden exploration.

**8i: Mu — COMPLETE (19/19 files)**
All 19 scene files annotated. Covers Cyclops, underwater temple, Mu NPCs, and puzzle mechanics.

**8j: Angel Village — COMPLETE (47/47 files)**
All 47 scene files annotated. Covers Ishtar boss, Dive Bat, Steelbones, Draco, Ramskull, angel NPCs, tunnel areas, and underwater passage.

**8k: Watermia — COMPLETE (30/30 files)**
All 30 scene files annotated. Covers town NPCs, Lance's father's house, raft racing, and story progression.

**8l: Great Wall — COMPLETE (18/18 files)**
All 18 scene files annotated. Covers Sand Fanger boss, Archer, Eyesore, Fire Bug, wall mechanics, and dungeon rooms.

**8m: Euro — COMPLETE (34/34 files)**
All 34 scene files annotated. Covers town NPCs, Rolek Mansion, Neil's parents, Ann, guest room, and Euro-specific dialog.

**8n: Native Village — COMPLETE (19/19 files)**
All 19 scene files annotated. Covers village NPCs, Gorgon hut stone girls, Hamlet subplot, and cultural interactions.

**8o: Dao — COMPLETE (25/25 files)**
All 25 scene files annotated. Covers Snake Panic mini-game, Dao NPCs, desert explorers, carpet weavers, and Neil reunion.

**8p: Pyramid — COMPLETE (36/36 files)**
All 36 scene files annotated. Covers Mummy Queen boss (~619 lines), Blaster, Haunt, Tuts, Mystic Ball, Jackal puzzle, hieroglyphs, danger slides, and collision renderer.

**8q: Babel Tower — COMPLETE (24/24 files)**
All 24 scene files annotated. Covers Dark Gaia final boss (~998 lines), space flight sequence, Olman reunion, Kara scenes, crystal gates, light elevator, and spirits.

**8r: Seaside Palace — COMPLETE (15/15 files)**
All 15 scene files annotated. Covers Skuddle, Slipper, coffin puzzles, fountain, phantom enemies, and villager rescue.

**8s: Angkor Wat — COMPLETE (20/20 files)**
All 20 scene files annotated. Covers Zombie, Gorgon, Wall Walker, Shrubber, Zip Fly, Goldcap, spirit guide, crystal shrine, and snake pit.

**8t: Ending/Prologue — COMPLETE (23/23 files)**
All 23 scene files annotated. Covers credits sequence (~815 lines), epilogue, class dismissed finale, changed world, prologue sequences 1-5, and credit NPC groups.

**8u: Mansion/Mountain Temple/Nazca — COMPLETE (28/28 files)**
All 28 scene files annotated. Covers Solid Arm boss, mansion intro, conveyor belt, Acid Spider, Skulker, Fire Sprite, Yorrick variants, crystal ball gates, Nazca NPCs, and buried tile discovery.

**Phase 8 complete.** All 601 scene files across 21 sub-regions have block notes. Key highlights:
- 492 new block notes generated in this session
- 51 boss/enemy descriptions hand-refined with game-specific context
- 141 generic auto-notes improved with content-aware descriptions
- 100% block note coverage across all 847 .asm files

### Phase 9: Unused code — COMPLETE (25/25 files)

All 25 unused files have block notes. 12 annotated from scratch, 13 already had notes.

### Phase 10: Generic label renames, inline comments for shared code, and overflow utilities

**Goal:** Rename all remaining `code_`, `func_`, `sub_`, `dm_func_`, `dm_sub_` prefixed labels to descriptive names, add inline comments to heavily-referenced shared files, and audit overflow utility functions at bank boundaries.

**Methodology:** Cross-reference scan of all `.asm` files for `$&block.part`, `$@block.part`, `#$&block.part`, `#$@block.part`, `&label`, `@label`, and `Address label` operands. This captures references that `?INCLUDE` alone cannot reveal (auto-discovered parts, dot-notation refs to parts not in blocks.json, direct label refs).

**Current baseline (cross-reference scan results):**
- 5,555 distinct cross-file reference targets across all .asm files
- 551 of those targets have generic names (`code_`, `func_`, `sub_`, `loc_`, `binary_`, etc.)
- 577 total cross-file references point to those 551 generic targets
- 34 `func_`/`sub_` part names in `blocks.json` needing key updates
- 3,310 total generic labels in all .asm files (3,276 `code_`, 20 `func_`, 12 `sub_`, 2 `dm_*`)
- 7,214 existing inline comments (concentrated in engine banks 00-03)

**How to discover shared code targets (agent instructions):**

Scan the extracted `.asm` files for these reference patterns:
```
$&blockName.partName        — short cross-file ref (same bank)
$@blockName.partName        — long cross-file ref (cross-bank)
#$&blockName.partName       — immediate short pointer
#$@blockName.partName       — immediate long pointer
&label / @label             — COP operand refs
Address label               — data table far pointer
JSL $@blockName.partName    — long subroutine call
JSR $&blockName.partName    — short subroutine call
```

Not all referenced "parts" will exist in `blocks.json` — many are auto-discovered by the engine during code analysis. These still appear in the extracted `.asm` as labels and can be referenced via dot-notation from other files.

#### Step 10a: Rename high-impact generic labels referenced from multiple external files

**Tier 1 — Cross-file dot-notation generics (2+ external files):**

These appear in other files as `block.code_XXXXXX` and are the most visible generics:

| Target | Ext refs | Referenced by |
|--------|----------|---------------|
| `oneshot_palette_flash_19.code_00B7D8` | 6 | awBC_blinding_light, awBF_spirit_guide, future_vision_cutscene, it15_lily, mu66_rama_spirits, sE8_dark_gaia |
| `oneshot_palette_flash_18.code_00B7CE` | 5 | awBC_blinding_light, awBF_spirit_guide, it15_lily, mu66_rama_spirits, sE8_dark_gaia |
| `oneshot_palette_flash_1C.code_00B7EC` | 5 | awB4_snake_pit_entry, ec0B_cell, gs2C_crow_crew, gs2C_descent, mu63_spirits |
| `pr_text_placement_calc.code_0BCF8F` | 5 | pr8C_prologue1, pr8C_prologue5, pr8D_prologue2, pr8E_prologue3, pr8F_prologue4 |
| `ApplyOrbitalOffsetFromRef.code_00F3D3` | 4 | attack_ability_system, mtA1_fire_sprite, pyDD_queen_spirit_attack, unused_mode7_boss |
| `nv_village_event_sprite.code_0881AE` | 2 | nvAC_erik, nvAC_kara |
| `oneshot_palette_flash_1B.code_00B7E2` | 2 | ec0B_cell, mu63_spirits |
| `oneshot_palette_flash_40.code_00B7F6` | 2 | av74_kara, sp5D_fountain |
| `player_character.loc_02C63B` | 2 | awB4_snake_pit_entry, gs2C_descent |
| `sg_bird_flight_patterns.code_0ADAA0` | 2 | pyCC_mystic_ball, sg4D_cyber |
| `sg_bird_flight_patterns.code_0ADAB5` | 2 | pyCC_mystic_ball, sg4D_cyber |

Plus single-ref dot-notation generics (lower priority but still cross-file visible):

| Target | Referenced by |
|--------|---------------|
| `aw_spirit_follower.code_0BBEF7` | awB1_goldcap |
| `aw_spirit_follower.code_0BBF64` | pyDD_queen_spirit_attack |
| `stair_climb.code_00D16D` | awB2_stair_climb |
| `sp5D_fountain.code_069502` | awBC_bouncing_crystal |
| `btE1_comet_soon.code_0997B7` | btE2_brought_back |
| `sE8_comet_display_config.code_0CEB76` | sE8_dark_gaia |
| `sE8_comet_display_config.code_0CEBA1` | sE8_dark_gaia |
| `sE8_comet_display_config.code_0CEBF7` | sE8_dark_gaia |
| `sE8_comet_display_config.code_0CEC35` | sE8_dark_gaia |
| `sF7_credits_misc_timeline.code_09E65D` .. `code_09E8C1` (25 entries) | sF7_credits |
| `town_door.code_00C5F6` | fr32_guide |
| `ec_proximity_door_toggle.code_09C2DB`, `.code_09C2E4` | ir28_ceiling_trap_trigger |
| `oneshot_palette_flash_1F.code_00B800` | it1A_moon_tribe |
| `pyCD_jackal.code_08B804` | pyCD_flame_statue |
| `sg55_viper_arena.code_0AD034` | sg55_mystic_statue |
| `gs2B_wreck_wave_motion.code_05F859` | sg55_viper_arena |
| `sg_bird_flight_patterns.code_0ADA69`, `.code_0ADA81`, `.code_0ADAD1`, `.code_0ADAE7`, `.code_0ADB04` | sg4D_cyber |
| `sc02_card.code_04AFBF` | sc02_lance |
| `smooth_follow_child.loc_00E4FA` | combat_collision |
| `ambient_palette_cycler.code_00B522` | item_use_system |
| `hint_npc.code_09A38D`, `.code_09A3A0` | dark_rewards |
| `dm_follower_behavior.code_0ADC25` | unused_follow_chain |
| `wa7B_competitor_right.code_07A192` | wa7B_competitor_left |
| `wa78_men.code_078504` | wa78_full_pad |

**Tier 2 — `?INCLUDE`-level shared files with generic top-level labels:**

Files `?INCLUDE`d by 2+ other files with `code_`/`func_`/`sub_` as top-level block or part labels:

| File | Ext refs | Generics | Key labels |
|------|----------|----------|------------|
| `music_actors.asm` | 8 | 1 | `code_02A0DD` |
| `pr_text_placement_calc.asm` | 6 | 1 | `code_0BCF8F` |
| `player_move_diag.asm` | 5 | 10 | 10 diagonal collision subroutines |
| `dm_follower_behavior.asm` | 3 | 6 | `dm_func_0ADB6B`, `dm_sub_0ADD27`, 4 `code_` |
| `warps_interaction.asm` | 3 | 2 | `code_02A88B`, `code_02AAF2` |
| `EnemyDefeatDispatch.asm` | 3 | 1 | `code_0AA474` |
| `spc_transfer.asm` | 3 | 1 | `code_029153` |
| `scene_script.asm` | 2 | 3 | `code_02845C`, `code_0285F3`, `code_028CB0` |
| `sg4D_dynapede.asm` | 2 | 26 | 26 movement/attack subroutines |
| `wa78_men.asm` | 2 | 15 | 15 NPC dialog branch labels |
| `pyCD_jackal.asm` | 2 | 10 | 10 stealth puzzle states |
| `sg_bird_flight_patterns.asm` | 2 | 9 | 9 flight path entries |
| `btE1_comet_soon.asm` | 2 | 4 | 4 spirit dialog sections |
| `sE8_comet_display_config.asm` | 2 | 4 | 4 display setup routines |
| `ec11_countdown.asm` | 2 | 4 | 4 countdown/puzzle states |
| `sp5D_fountain.asm` | 2 | 4 | 4 fountain puzzle states |
| `sg55_viper_arena.asm` | 2 | 4 | 4 arena setup routines |
| `pyDA_lithograph1.asm` | 6 | 3 | 3 lithograph helper routines |
| `ec11_button_voice.asm` | 2 | 3 | 3 button event states |
| `fr39_kara.asm` | 2 | 3 | 3 dialog branches |
| `sc02_card.asm` | 2 | 3 | 3 card game states |
| `aw_spirit_follower.asm` | 2 | 2 | 2 follow behavior states |
| `wa7B_competitor_right.asm` | 2 | 2 | 2 reaction states |
| `gs2B_wreck_wave_motion.asm` | 2 | 1 | 1 wave computation |
| `gs2C_crew4.asm` | 2 | 1 | 1 dialog callback |
| `nv_village_event_sprite.asm` | 2 | 1 | 1 event handler |

**Method per label:**
1. Read the `.asm` file and understand each generic label's purpose
2. For `code_` labels: add descriptive entry to `names.json`
3. For `func_`/`sub_`/`dm_*` labels: update the part key in `blocks.json` via targeted string replacement AND add `names.json` entry
4. For dot-notation refs that are auto-discovered (not in blocks.json): add `names.json` entry only
5. Run `npm run extract` to verify the labels appear correctly
6. Update any `notes/partNotes/` keys that reference the old name (rename propagation checklist)

#### Step 10b: Rename `func_`/`sub_` part names in blocks.json (34 entries)

These are `blocks.json` part keys with generic prefixes. They require key updates (targeted string replacement to preserve formatting) plus `names.json` additions:

| Block | Part count | Description |
|-------|-----------|-------------|
| `mu67_vampires` | 16 (`func_` × 9, `sub_` × 7) | Boss helper routines + shared utilities |
| `ir29_castoth` | 9 (`func_` × 7, `sub_` × 2) | Boss helper routines — JSL utilities |
| `dm_follower_behavior` | 2 (`dm_func_0ADB6B`, `dm_sub_0ADD27`) | Mine follower init + tile check |
| `ramps` | 1 (`func_00D5C0`) | Ramp calculation utility |
| `av6E_draco` | 1 (`sub_0AFD26`) | Draco enemy subroutine |
| `sF7_credits` | 1 (`func_09F69F`) | Credits utility |
| `sF7_credits_npc_e` | 1 (`func_09E5DE`) | Credits NPC utility |
| `mtA1_fire_sprite` | 1 (`sub_0BA5D5`) | Fire Sprite math utility |
| `sg4D_cyber` | 1 (`sub_0ADD1E`) | Cyber enemy subroutine |
| `sg4D_knight_armor` | 1 (`sub_0ADD59`) | Knight Armor subroutine |
| `gw8A_sand_fanger` | 1 (`sub_0B9CE8`) | Sand Fanger boss subroutine |

**Method:** Read the function's code to understand its role, then:
1. Choose descriptive name that reflects the function's behavior
2. Update `blocks.json` part key via targeted string replacement
3. Add `names.json` entry at the part's start address
4. Update `notes/partNotes/` key if a part note exists
5. Run `npm run extract` to verify

#### Step 10c: Add inline comments to high-reference shared files

Files that are heavily referenced via both `?INCLUDE` AND cross-file `$&`/`$@` operands, with >100 lines, and currently lacking inline comments. These are the backbone of the codebase and benefit most from inline documentation.

**Top 13 cross-file reference targets (10+ files reference their parts via dot-notation):**

| Target | Part refs | Description |
|--------|----------|-------------|
| `tile_collision.*` | 50+ part refs | Collision probes, movement deltas, map cell reads |
| `npc_wander_ai.*` | 26 refs | NPC random walk + position sync |
| `sprite_composition.*` | 14 refs | Animation update, OAM composition, depth sort |
| `hardware_math.*` | 16 refs | SignedMultiply, UnsignedDivide, MulDivide |
| `actor_pool.*` | 15 refs | Allocator, palette reset, anim frame lookup |
| `vblank_joypad.*` | 25 refs | NMI enable, VBlank wait, joypad read |
| `system_core.*` | 15 refs | Frame render, dialogue, main loop |
| `cop_handlers_flags.*` | 24 refs | Flag test/set/clear across all flag spaces |
| `interaction_handlers.*` | 12 refs | Push handler, collect handler |
| `player_character.*` | 13 refs | Idle entry, vine entry, loc_02C63B |
| `sE6_gaia.*` | 19 refs | Transform routines, Dark Space architecture |
| `smooth_follow.*` | 8 refs | Follow+chase, sibling copy |
| `map_coords.*` | 8 refs | Tile-to-index, pixel-to-VRAM, movement |

**Engine/System files needing inline comments (sorted by reference impact):**
1. `tile_collision.asm` (8 `?INCLUDE` + 50+ part refs, 691L) — collision core
2. `player_character.asm` (19 `?INCLUDE` + 13 part refs, 1891L) — player state machine
3. `sprite_composition.asm` (15 `?INCLUDE` + 14 part refs, 970L) — OAM pipeline
4. `system_core.asm` (13 `?INCLUDE` + 15 part refs, 772L) — main loop
5. `actor_pool.asm` (17 `?INCLUDE` + 15 part refs, 294L) — actor allocation
6. `hardware_math.asm` (18 `?INCLUDE` + 16 part refs, 226L) — multiply/divide
7. `vblank_joypad.asm` (11 `?INCLUDE` + 25 part refs, 340L) — VBlank/NMI
8. `hdma_dma_spc.asm` (12 `?INCLUDE` + 7 part refs, 516L) — DMA/HDMA
9. `smooth_follow.asm` (9 `?INCLUDE` + 8 part refs, 906L) — follow AI
10. `scene_lifecycle.asm` (3 `?INCLUDE` + part refs, 1228L) — scene management
11. `actor_execution.asm` (5 `?INCLUDE` + part refs, 1201L) — actor main loop
12. `tile_collision_physics.asm` (4 `?INCLUDE` + 3 part refs, 1156L) — physics
13. `map_coords.asm` (6 `?INCLUDE` + 8 part refs, 383L) — coordinate math

**Shared Functions/Actors needing inline comments:**
14. `StandardEnemyDefeatHandler.asm` (16 part refs + 18 `?INCLUDE`, 209L)
15. `npc_wander_ai.asm` (26 part refs + 13 `?INCLUDE`, 140L)
16. `interaction_handlers.asm` (12 part refs + 13 `?INCLUDE`, 475L)
17. `player_transition_handlers.asm` (6 part refs + 13 `?INCLUDE`, 248L)
18. `camera_drift.asm` (7 part refs + 9 `?INCLUDE`, 141L)
19. `EscortFollowPathTracker.asm` (7 `?INCLUDE`, 177L)
20. `ApplyOrbitalOffsetFromRef.asm` (4 part refs + 11 `?INCLUDE`, 73L)
21. `mode7_perspective.asm` (4 part refs + 5 `?INCLUDE`, 423L)

**Player Movement files needing inline comments:**
22. `player_move_diag.asm` (5 `?INCLUDE` + 4 part refs, 985L)
23. `player_move_main.asm` (5 `?INCLUDE` + 3 part refs, 345L)
24. `player_move_ns.asm` (5 `?INCLUDE` + 4 part refs, 450L)
25. `player_move_south.asm` (5 `?INCLUDE` + 4 part refs, 667L)
26. `player_move_east.asm` (4 `?INCLUDE` + 2 part refs, 445L)

**Method per file:**
1. Run `npm run extract:lt` to get address-tagged output
2. Read file — identify complex logic, non-obvious operations, key branch points
3. Add inline comments directly in the `.asm` file after `; {addr}` tags
4. Aim for ~1 comment per 5-8 instructions in complex code, fewer in straightforward code
5. Run `npm run ingest` to synchronize
6. Run `npm run extract` to verify

#### Step 10d: Audit remaining high-generic-count internal files

Files with 1 external reference but many generic labels. These are primarily boss scripts and complex enemies whose internal structure benefits from named labels:

| File | Generics | Lines | Description |
|------|----------|-------|-------------|
| `sg4D_cyber.asm` | 104 | 1474 | Cyber enemy — Sky Garden |
| `mu67_vampires.asm` | 83 | 1347 | Vampire duo boss — Mu |
| `world_map_options.asm` | 80 | 787 | World map menu system |
| `item_use_system.asm` | 66 | 1840 | All 41 item use handlers |
| `mu5F_cyclops.asm` | 63 | 622 | Cyclops enemy — Mu |
| `sg55_viper.asm` | 60 | 1150 | Viper boss — Sky Garden |
| `gw8A_sand_fanger.asm` | 53 | 1610 | Sand Fanger boss — Great Wall |
| `sE8_dark_gaia.asm` | 48 | 1005 | Dark Gaia — final boss |
| `gw83_asp.asm` | 48 | 573 | Asp enemy — Great Wall |
| `ir29_castoth.asm` | 46 | 1150 | Castoth boss — Incan Ruins |
| `ir1F_stone_guard.asm` | 44 | 770 | Stone Guard — Incan Ruins |
| `pyDD_mummy_queen.asm` | 44 | 627 | Mummy Queen — Pyramid |
| `sF7_credits_misc_timeline.asm` | ~25 | — | Credits timeline entries (all `code_09E*`) |
| (+ ~50 more files with 10-40 generics each) | | | |

Also includes ~100 `binary_` labels referenced once each (mostly sprite data in banks 01, 03) — lowest priority.

These are lower priority since they're only referenced internally or by `scene_actors`, but renaming improves readability for anyone auditing the boss/enemy logic.

#### Step 10e: Rename oneshot thinker/palette entry points

A recurring pattern found by the cross-reference scan: the `oneshot_palette_flash_*` thinker files each have a single auto-discovered `code_` entry point that is referenced by multiple scene scripts via dot-notation. These are small files (1 label each) with high cross-file visibility:

| Thinker | Label | Refs | Description |
|---------|-------|------|-------------|
| `oneshot_palette_flash_19` | `code_00B7D8` | 6 | Bright white flash (used by spirit/vision scenes) |
| `oneshot_palette_flash_18` | `code_00B7CE` | 5 | Spirit flash variant |
| `oneshot_palette_flash_1C` | `code_00B7EC` | 5 | Dark/dramatic flash |
| `oneshot_palette_flash_1B` | `code_00B7E2` | 2 | Prison/spirit flash |
| `oneshot_palette_flash_40` | `code_00B7F6` | 2 | Subtle flash |
| `oneshot_palette_flash_1F` | `code_00B800` | 1 | Moon tribe flash |
| `ambient_palette_cycler` | `code_00B522` | 1 | Cycler entry point |

These are quick wins — read, name, verify.

#### Sub-phase breakdown

Work is split into file-sized chunks. Each sub-phase: read file(s), rename generics (`names.json` + `blocks.json` + `partNotes` propagation), audit block/part notes and inline comments.

| Sub-phase | Files | Scope |
|-----------|-------|-------|
| **10.1** | Oneshot thinkers (7), ambient_palette_cycler, smooth_follow_child, music_actors, town_door, stair_climb | Quick wins: 12 files, ~14 generic labels, audit existing notes |
| **10.2** | scene_script, spc_transfer, warps_interaction | Engine shared code: 3 files, 6 generics |
| **10.3** | player_move_diag, player_character (`loc_02C63B`) | Player movement: 2 files, 11 generics |
| **10.4** | EnemyDefeatDispatch, ApplyOrbitalOffsetFromRef, dm_follower_behavior | Shared functions: 3 files, 8 generics |
| **10.5** | sc02_card, ec11_countdown, ec11_button_voice, ec_proximity_door_toggle, hint_npc | Scene cross-refs early game: 5 files, ~15 generics |
| **10.6** | fr39_kara, gs2C_crew4, gs2B_wreck_wave_motion, wa78_men, wa7B_competitor_right, nv_village_event_sprite | Scene cross-refs mid game: 6 files, ~24 generics |
| **10.7** | sg_bird_flight_patterns, sg55_viper_arena, sg4D_dynapede, sp5D_fountain, aw_spirit_follower | Scene cross-refs dungeons: 5 files, ~45 generics |
| **10.8** | pyDA_lithograph1, pyCD_jackal, btE1_comet_soon, sE8_comet_display_config, pr_text_placement_calc | Scene cross-refs late game: 5 files, ~22 generics |
| **10.9** | sF7_credits_misc_timeline, sF7_credits (`func_`), sF7_credits_npc_e (`func_`) | Credits: 3 files, ~27 generics |
| **10.10** | ramps, av6E_draco, mtA1_fire_sprite, sg4D_cyber (`sub_`), sg4D_knight_armor (`sub_`), gw8A_sand_fanger (`sub_`) | `func_`/`sub_` blocks.json renames — small files: 6 files, 7 entries |
| **10.11** | ir29_castoth | `func_`/`sub_` blocks.json renames — Castoth boss: 1 file, 9 entries |
| **10.12** | mu67_vampires | `func_`/`sub_` blocks.json renames — Vampires boss: 1 file, 16 entries |
| **10.13** | sg4D_cyber, world_map_options, item_use_system, boss/enemy files | Internal high-generic files: ~60 files, 500+ labels |

#### Progress tracking

**10.1: Quick wins — COMPLETE**
- Renamed 13 generic labels across 12 files via `names.json`
- 7 oneshot thinker entry points: `FlashPalette18`/`19`/`1B`/`1C`/`1F`/`40`, `PaletteCycleLoop`
- `smooth_follow_child.loc_00E4FA` → `SmoothFollowChildDie` (2 cross-file refs in combat_collision)
- `music_actors.code_02A0DD` → `MusicLoadCleanup` (propagated to block note + 2 part note refs)
- `town_door.code_00C5F6`/`code_00C60A` → `TownDoorInit`/`TownDoorProximityCheck`
- `stair_climb.code_00D164`/`code_00D16D` → `StairTriggerWestOffset`/`StairTriggerWestMain`
- Added 14 part notes: town_door (5), smooth_follow_child (8), stair_climb (0 — existing)
- Added 59 inline comments: smooth_follow_child (43), town_door (14), stair_climb (2 existing)
- 0 stale cross-file generic dot-notation refs remain for these targets

### Phase 11: Future — inline comments for complex scene scripts and remaining generic labels
