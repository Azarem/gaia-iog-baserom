# I061 - 2026-10-28 - files: tables/direction_velocity_table.asm, tables/body_table.asm, tables/scene_actors.asm (+ one correction in system/engine/DisplaySceneTitle.asm)
Status: COMPLETE

Spec: [edits/I061.json](../edits/I061.json). Proposals: [renames/I061_renames.md](../renames/I061_renames.md). Questions: [questions/I061_questions.md](../questions/I061_questions.md).

Conventions: verdicts **P/M/F/NA**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 coverage and verbosity, Q2 value, Q3 accuracy, Q4 mnemonic and variable names, Q5 new mnemonic, Q6 naming, Q7 evidence quality. Data tables get block and part notes only, no inline comments. `tables/scene_actors.asm` (5,445 lines) is **SAMPLED ~12%** for line-by-line review of the list body (first ~300 lines plus nine 20-line windows from 11% to 95%); the pointer table (256 entries), the whole title list and every count in the notes are whole-file.

### tables/direction_velocity_table.asm (1 table, 9 entries of 2 bytes, 20 lines, Bank 01 109534-109551, parts: 0 code / 1 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 2-line header and one part paragraph; no per-entry decode | E1 |
| Q2 value | M | The note named the two consumers but not what the step code is, where it comes from, or what the entries mean | E1, E2 |
| Q3 accuracy | **F** | (a) **"byte 0 = base animation frame for that direction, byte 1 = movement speed"**: byte 0 is the player animation index (`StagePlayerSprFromDP`, and `$28` at scene entry), byte 1 is a **`movement_delta_table` index** (a velocity chain: `$11`/`$12` = +/-1/2, `$13`/`$14` = +/-1/4 pixel per frame, 0 = none), not a speed. (b) **"cardinal/diagonal directions ... S, N, E, W, SE, SW, idle variants, NE/NW"**: there are no diagonals and no idle rows; the table is indexed by a **step code** (scene-entry facing value / walk-step stream byte), and the rows are up (anim 9), down (anim 8), left (2), right (3) with FacingDirectionLookup. Rows `$00`=`$05`, `$01`=`$03`, `$02`=`$04` are identical. (c) **"Maps 9 cardinal/diagonal directions to sprite frame and velocity"** hides that left/right steps carry no velocity (the east/west forced walks move through the camera pan) | E1 (`ReadDirSprite_YVelocity` / `_XVelocity`, `InitActorFromSceneData`, `ApplyMovement`, `FacingDirectionLookup`), E2 (`movement_delta_table` nodes) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | `direction_velocity_table` and the `direction-velocity` fields suggest compass directions and a speed | PROPOSED R-I061-1 |
| Q7 evidence quality | M | E1 + E2; all nine rows decoded by hand; no runtime | E1, E2 (UNVERIFIED-RUNTIME: OQ-I061-2) |

Actions taken: block note rewritten (step code, consumers, the old wrong claims); 1 part note rewritten (decoded row table); no inline comments; no mnemonics added.
Deferred: R-I061-1, R-I061-4.
Before/after stats: 20 to 41 lines; generic labels remaining: 0.

### tables/body_table.asm (1 table, 9 entries of 6 bytes, 29 lines before, Bank 01 121201-121254, parts: 0 code / 1 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A short header, no row table, no selection paths | E1 |
| Q2 value | M | Did not say who selects a row, what the 6 bytes are, or that the row also names the player's tile graphics | E1, E2 |
| Q3 accuracy | **F** | (a) **row list "Will, Freedan, Shadow, Shadow alt, Will alt, Ability FX, Will FX, Shadow FX, Shadow mode"**: row `$03` is an exact copy of `$02` (not an alternate), row `$04` is Will's alternate poses with Will's own tile graphics, there is **no "Will FX" row** (`$05` ability FX, `$06` Freedan FX, `$07` Shadow FX, `$08` Shadow mode). (b) **"Address spriteset_ptr, @Binary sprite_tiles_ptr"** is correct as bytes but the note omits that the second pointer feeds the player's tile DMA list (`DecomposePlayerSprites`, `$06FC` / `$06FE`) while `playerFlags` bit 15 is set. (c) **"Referenced by actor_execution.asm (form transitions)"**: `InitActorFromSceneData` reads it once at scene entry for the current `characterForm`; form changes go through `SetActorBody` and `SetPlayerSpriteDirect`. (d) selection by `characterForm` only reaches rows 0-3, rows 4-8 only through `SetPlayerSpriteDirect` | E1 (`SetActorBody`, `SetPlayerSpriteDirect`, `DecomposePlayerSprites`, `GetPlayerFacingDirection`, `InitActorFromSceneData`), E2 (`slider_glide`, `cop_handlers_player_sprite` header banks) |
| Q4 mnemonic/var names | NA | `$0AC8` (body index) has no mnemonic; logged in R-I061-4 | PROPOSED R-I061-4 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | P | `body_table` is accurate; the rows have no names | E1 |
| Q7 evidence quality | M | E1 + E2; rows decoded by hand; nothing found selects rows 3 or 8 by number (OQ-I061-1) | E1, E2 (UNVERIFIED-RUNTIME) |

Actions taken: block note rewritten (two selection paths, tile-graphics use, the old wrong row list); 1 part note (row table with banks and uses); no inline comments; no mnemonics added.
Deferred: R-I061-4.
Before/after stats: 29 to 48 lines; generic labels remaining: 0.

### tables/scene_actors.asm (1 pointer table of 256 entries, 241 scene lists, 241 title strings, 1 generated extract table, 5,445 lines before / about 5,490 after, extraction bank 0C (ROM `$8C`) 819200-845285, parts: 0 code / 484 data) SAMPLED ~12%

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | F | A 4-line header; no record format, no counts, no mention that titles are part of each record | E1 |
| Q2 value | F | The note said "which actors spawn, their initial positions, sprite assignments, and behavior flags" without saying that the stream is `actor-spawn` (7 bytes) / `enemy-spawn` (9 bytes) plus `$FF` plus a title, which scenes share a list, which lists have no player, or what `scene_actors_extract_table` and the `_value` blocks are | E1, E2 |
| Q3 accuracy | **F** | (a) **"sprite assignments"**: the records hold no sprite data; byte 2 is an OAM attribute or a spawn parameter, bytes 3-5 an actor-def pointer. (b) the layout hid that every scene record ends with a **title string** after the `$FF`: `scene_actors_extract_table` (end of file) is **not in the ROM**, it is created by the `Extract(1)` post-process that splits record = list + title, and the `scene_event_..._value` blocks are the titles. (c) **sixteen scene ids ($48 $57 $76 $77 $80 $81 $9E $AA $AB $AF $C1 $C2 $CA $CB $F8 $F9) share one default list** (`scene_event_0C8200`, title TEST MAP), reached by no warp or `QueueMapChange` found. (d) **14 scene ids have lists without a player first** (cutscenes, menus, credits, title, boot, world map) and 2 are empty ($00, $9F); the inferred rule "player is the first record" holds for 224 of 240 own lists | E1 (`SpawnSceneActors`, `InitActorFromSceneData`, `CheckEnemyDefeatedFlag`, `postprocessor.ts Extract`), E2 (whole-file searches, `scene_warps`) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | `scene_event_0CXXXX` and `scene_event_0CXXXX_value` are offset names; the table is `scene_actors` but the lists are scene records | PROPOSED R-I061-2 |
| Q7 evidence quality | M | **Sampled** (see above); counts are whole-file by search: 224 player records (all record `$00`), 220 camera controllers (219 at `$01`), 1,798 actor-spawn, 1,317 enemy-spawn, 254 distinct enemy numbers, 62 distinct stats indices, 64 non-empty titles of 241; 12 actor labels spot-checked and found; the longest lists identified (0CC7A1 scene $A7, 62 records) | E1, E2 (UNVERIFIED-RUNTIME: OQ-I061-3) |

Actions taken: block note rewritten (layout vs extraction, record format, counts, conventions); 8 part notes (new: the table, the default list, scenes $00, $A7, $F7, $FF, the extract table, the default title). The part notes live in `notes/partNotes/bank0E.json` and the block note stays in `notes/blockNotes/bank0E.json` because that is where the existing block note was; the file has no `?BANK`, so a tool change was needed (see below). No inline comments; no mnemonics added.
Deferred: R-I061-2, R-I061-3.
Before/after stats: 5,445 to about 5,490 lines; generic labels remaining: 482 (`scene_event_0C...` and `_value`).

### system/engine/DisplaySceneTitle.asm (correction of an earlier annotation; not an I061 audit file)

Found while checking the title strings of `scene_actors`: the header, the `DisplaySceneTitle` part note, the `CountTitleGlyphs` part note and the `INC $3E` comment (address 172405) said that `CountTitleGlyphs` skips "a leading type/length byte (assumed)" of the title string. That byte is the **`$FF` that ends the scene's actor list**: `SpawnSceneActors` exits with `$3E` pointing at it, `scene_lifecycle` calls `DisplaySceneTitle` straight after (lines 872-873), the title string follows the `$FF` directly in the ROM, and the first title byte is a real character (counted). The claim is now corrected in 1 block note, 2 part notes and 1 comment. Also added: 177 of 241 titles are only `$CA`, which is what the empty-title guard handles.

### Tooling change (src/ingest.ts, src/merge.ts, gaia-iog-baserom)

`scene_actors.asm` (a movable block: no `?BANK`, no address tags in data, no named top label) made `npm run merge` stop with `cannot determine the ROM bank of this file`. A first stopgap (fall back to the bank of an existing block note) was replaced after review by the proper rule: when there is no `?BANK`, the bank is the block's `start` in `db-us/blocks.json` / `db-us/files.json` (bank = floor(start / 65536)); see B001 and `gaia-core/docs/notes-and-comments.md` section "Bank detection". The scene_actors notes now live in bank 0C (they were first written to bank 0E by the stopgap and were moved with `edits/I061-rebank-scene_actors.json` followed by a re-merge of `edits/I061.json`). Dry-runs of I061, I062 and I064 report 0 changes.

### Iteration summary

- Files: 3 audited (+ 1 corrected). Q3: 3 F. Notes written: 3 block notes (+1 corrected), 10 part notes (1 + 1 + 8; +2 corrected), 1 inline comment (the corrected one).
- Verification: `npm run extract:lt` run before the merge (line tags needed) and after; both specs re-run as dry-runs report 0 changes; `npm run rebuild` OK, `artifacts/crc.json` checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged).
- Patterns: (1) a table described by guessed compass names when the index is a step code and the second byte a table index into another table; (2) a form list with invented members ("Will FX", "Shadow alt"); (3) a note that hides part of the record (the title after the `$FF`) and an extractor artifact (`_extract_table`) presented as ROM structure; (4) a guessed "type/length byte" in the next consumer that was really the previous record's terminator.

Suggested commit message: `Audit I061: decode direction_velocity/body/scene_actors tables, fix scene title terminator note, merge fallback for bankless files`
