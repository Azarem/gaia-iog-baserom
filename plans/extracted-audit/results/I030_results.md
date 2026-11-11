# I030 results

Files: `system/player/tile_collision.asm` (Bank 02), `functions/SetPlayerGameOverFlag.asm` (Bank 0A), `actors/scene_flag_init.asm` (Bank 00).
Spec: [edits/I030.json](../edits/I030.json). New proposals: [renames/I030_renames.md](../renames/I030_renames.md). New questions: [questions/I030_questions.md](../questions/I030_questions.md).

Conventions as in [I029_results.md](I029_results.md).

### File 1: system/player/tile_collision.asm (Bank 02)

Evidence: E1 (every routine read; MapCell steps worked through with sample indices; the INC pattern checked in all eight probes), E2 (`player_move_*` callers, `slope_ramp_physics`, `map_coords` `ProbeRightTiles` / `MapIndexMove*`, `tile_collision_physics` `CalcTileMapOffset`, `cop_handlers_collision` MarkSolid* / ClearSolid* ops, `combat_collision`), E3 (`structs-reference.md`; the bank02 docs were not re-read).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Header and part notes existed, the probes carried almost no explanation of the corner geometry or return protocol | FIXED (block note with 6 sections, 5 part notes, 15 comment entries) |
| Q2 | M | The notes did not state the carry convention (the key fact for every caller) nor the collision byte layout | FIXED |
| Q3 | **F** | (a) **Callers**: the header said only the `player_move_*` blocks call these; `slope_ramp_physics` and `map_coords` (`ProbeRightTiles` / `ProbeLeftTiles`) use the probes and MapCell steps too. (b) **Collision byte**: the high-nibble "layer-priority override" wording is wrong: the high nibble is the actor solid mark (`$F0`) that MarkSolidHere/Offset/Abs OR in and the Clear ops remove; `ReadCollisionNibble` returns it shifted down (`$F0` becomes `$0F`, solid) when nonzero. (c) **Carry**: `TileProbeMain` returns carry SET for any NONZERO type (slopes, ladders, wall types), not "blocked"; solid is `A >= $0E`, which callers test themselves. (d) **INC `$1A` / `$1E`** in the TR, BL and BR probes is not a "shift inward for MapCell navigation": it moves the stored coordinate one pixel past the hitbox edge so that `CheckSubTileAlignX/Y` ask "is this edge flush with a tile boundary". TL needs none. (e) **`CheckTileBoundaryXor` returns its answer in Z** (Z clear = boundary crossed), not carry; the XOR is with the pre-step pixel. (f) **`SetActorCollisionFlag`**: Y is the actor slot address loaded from `$000A`, not "actor ID x 2"; bit `$0004` is the per-tick solid-contact flag. (g) **MapCell steps**: Down/Up are +/- one row (`$10`), Right/Left one column; callers in `slope_ramp_physics` describe MapCellDown as the "right" cell (logged in R-I030-3, not editable in this iteration). (h) Hitbox reference point is the centre of the bottom edge (left -8, right +7, top -16, bottom -1) | FIXED in this file; `slope_ramp_physics` wording logged (R-I030-3) |
| Q4 | M | Operands correct; carry and Z conventions in comments wrong as above | FIXED |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | P | `ProbeCurrent*` / `ProbeFuture*`, `MapCell*`, `TileProbeMain` and `ReadCollisionNibble` match their behaviour | NOFIX |
| Q7 | M | E1 + E2; collision-type meanings `$06`/`$09` remain undecoded | DEFERRED-EVIDENCE (OQ-I029-5 / audit OQ-16; OQ-I030-3) |

### File 2: functions/SetPlayerGameOverFlag.asm (Bank 0A)

Evidence: E1 (5 instructions), E2 (`combat_collision` skip masks `$76E0` / `$74E0` and the friendly pass, `player_character` for the actor-flag bit users, spawn sites in `ir29_castoth`, `sg55_viper`, `gw8A_sand_fanger`, `pyDD_mummy_queen`, `mu67_vampires`, `sE8_dark_gaia`, `unused_mode7_boss`), E3 (`docs/code/bank0A-dungeon-enemy-actors.md`, `docs/code/bank0C-scene-spawn-tables-comet.md`, `wram-memory-map.md` Player Flags Reference).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A one-line note, no comments | FIXED (block note, 5 comments) |
| Q2 | M | The note named the effect without saying which word the bit lives in | FIXED |
| Q3 | **F** | (a) **The bit `$0200` is set in the player ACTOR's flags (`$0010,Y`, Y = slot address from WRAM `$09AA`), not in `playerFlags` (`$09AE`)**. The real game-over bit (`playerFlags` bit 9) is set by `combat_collision` at HP 0; the two are different words. (b) `combat_collision` puts `$0200` in the skip mask of its normal enemy-hits-player pass and sends such an actor to the friendly-only interaction pass, so the likely effect is "player cannot be hit during the boss-defeat sequence", not "game over" and not a "flash" (the docs call it "boss kill invulnerability flash"; nothing here flashes). (c) The helper ends with `RTL` and no `Die`, so it re-applies the bit every tick for as long as it lives (it is not a marked child); the earlier text implied a one-shot. (d) Spawners: `ir29_castoth`, `sg55_viper`, `gw8A_sand_fanger`, `pyDD_mummy_queen`, `mu67_vampires` (both death callbacks, each after `playerFlags $0020`), `sE8_dark_gaia`, `unused_mode7_boss` | FIXED; intent flagged as OQ-I030-2 |
| Q4 | M | The `ORA #$0200` comment claimed game over | FIXED |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | **F** | `SetPlayerGameOverFlag` names a bit that is not the game-over bit | PROPOSED (R-I030-1) |
| Q7 | M | E1 + E2; the invulnerability reading comes from `combat_collision` masks, not a runtime test | DEFERRED-EVIDENCE (OQ-I030-2) |

### File 3: actors/scene_flag_init.asm (Bank 00)

Evidence: E1 (two COP ops), E2 (`cop_handlers_scene_flags` / `flag_helpers` for SetFlagByte indexing, `scene_lifecycle` flag reset, `tables/scene_actors.asm` placements counted, flag `#00` readers/writers grepped across `extracted/`, `player_transition_handlers`, `shadow_shimmer`, `inventory_menu`, `inventory_overlay`), E3 (`docs/code/bank00/actors-infrastructure.md`, `README.md`, `data-tables-memory.md`, `bank0C-scene-spawn-tables-comet.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A two-line note, no comments | FIXED (block note, 2 comments) |
| Q2 | M | The note did not say what the flag is, who reads it or where the actor is placed | FIXED |
| Q3 | **F** | (a) **It sets flag `#00`; it does not "clear event flag byte zero"**: `SetFlagByte` takes a flag INDEX and sets that bit (the first bit of `eventFlags` `$0A00`). (b) `scene_lifecycle` zeroes flags `$00-$0F` when a scene is set up, so the flag starts every scene clear and this actor sets it on its first tick. (c) **Placement count**: the actor appears in 26 scene actor lists (slot `#02` x4, `#03` x13, `#04` x6, `#14`, `#1A`, `#1C` once each), not "slot #03 or #04 only"; the docs' "80+" is also wrong (the bank0C doc says 26) | FIXED in the asm; docs rows in R-I030-2 |
| Q4 | M | The operand comment said "byte" | FIXED |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | `scene_flag_init` describes "init" but the effect is a set; meaning of flag `#00` is open | PROPOSED (R-I030-2), DEFERRED-EVIDENCE (OQ-I030-1) |
| Q7 | M | E1 + E2 on the flag's users; the unconditional set conflicts with the "Shadow flag" wording used by `shadow_shimmer` and `player_transition_handlers` | DEFERRED-EVIDENCE (OQ-I030-1) |

### Shared gate (I030)

`npm run merge -- edits/I030.json --dry-run` first reported two `expect` errors (comments at 188913 and 189027: the lines hold `PHP`, the probe names are in the comment text); both `expect` strings were changed to `PHP` and the dry run was then clean (no transform warnings). Merge applied: 3 block notes, 5 part notes, 22 comment entries (15 in `tile_collision`, 5 in `SetPlayerGameOverFlag`, 2 in `scene_flag_init`). `npm run extract:lt` OK, `npm run rebuild` OK. `artifacts/crc.json` = checksum 223006080, crc 2083230829, totalSize 3062204, read once after both I029 and I030 were merged.

Suggested commit message: `audit(I030): tile_collision carry/Z protocol, INC edge-flush purpose and solid-mark nibble; SetPlayerGameOverFlag sets actor $0200 (not playerFlags game over); scene_flag_init sets flag #00`

Please commit when you're ready.
