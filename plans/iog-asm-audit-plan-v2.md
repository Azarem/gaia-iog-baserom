# IOG ASM Full Audit Plan — v2

> Replaces the original plan. See [prior session](f1b0ef1e-85d5-4749-bbfd-692c1331240f) for context on what went wrong.

## Current Baseline (2026-09-19)

| Resource | Count |
|---|---|
| Block notes | 194 (bank00: 117, bank01: 20, bank02: 30, bank03: 27) |
| Part notes | 908 (bank00: 299, bank01: 39, bank02: 320, bank03: 250) |
| Inline comments | 6,614 (bank00: 1,999, bank02: 2,978, bank03: 1,637) |
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

Before touching ANY comment/note JSON file:

1. **`git add notes/ && git commit -m "snapshot: pre-phase-N"`** — always commit first
2. **Read `extract:lt` output** — never build parallel data structures
3. **One file at a time** — add comments, re-extract, verify, then next file
4. **Never empty JSON files** — `extract:lt` shows `; {addr} comment text` on commented lines
5. **Never bulk-shift addresses** — fix individually by reading `extract:lt` output
6. **Verify immediately** — after adding comments, run `extract:lt` and confirm each appears on the correct instruction

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
All unaudited.

### Remaining System Files (32 files) — `extracted/system/` (non-engine, non-player)
All unaudited. Includes inventory, world map, dialogue, UI, cutscenes.

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
4. Flag and fix any remaining mismatches
5. Note gaps in complex routines that need new comments
6. `git commit` after each file

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
2. Verify block note accuracy (handler count, description matches contents)
3. Verify all part notes exist and are accurate
4. Audit `names.json` labels for this file's address range
5. Run `extract:lt`, read for address tags
6. Write inline comments following density guidelines
7. Re-extract standard, verify output reads naturally
8. `git commit` after each file or small batch

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
- [ ] `git commit` current notes state (snapshot before changes)
- [ ] Verify block note: routine count matches, description accurate, no cross-file claims
- [ ] Verify all part notes: exist for each named routine, keys match `names.json`, description accurate
- [ ] Audit `names.json` labels: no generic `code_XXXXXX`, names describe actual behavior
- [ ] Run `extract:lt`, read for `{address}` tags in complex routines
- [ ] Add inline comments using addresses from `extract:lt` output (NEVER compute manually)
- [ ] Run standard `extract`, read result — comments flow naturally, no clutter
- [ ] `git commit` the completed file's notes

---

## Progress Tracking

### Phase 1: Re-verify engine files
- [ ] `cop_handlers_flags.asm`
- [ ] `cop_handlers_movement.asm`
- [ ] `cop_handlers_effects.asm`
- [ ] `cop_handlers_lifecycle.asm`
- [ ] `cop_handlers_sprite.asm`
- [ ] `cop_handlers_spatial.asm`
- [ ] `system_core.asm`
- [ ] `cop_dispatch.asm`
- [ ] `cop_handlers_flow.asm`
- [ ] `cop_handlers_solid.asm`
- [ ] `cop_handlers_player_sprite.asm`
- [ ] `cop_handlers_audio.asm`
- [ ] `cop_handlers_input.asm`
- [ ] `cop_handlers_palette.asm`
- [ ] `cop_handlers_map.asm`
- [ ] `cop_handlers_spawn.asm`
- [ ] `actor_pool.asm`
- [ ] `combat_collision.asm`
- [ ] `player_character.asm`

### Phase 2: Remaining engine files
*(30 items — see list above)*

### Phase 3–9: To be tracked as we reach them
