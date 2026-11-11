# I064 - 2026-10-28 - files: tables/forced_walk_sequence_table.asm, tables/spriteset_town_objects.asm, tables/spriteset_will.asm
Status: COMPLETE

Spec: [edits/I064.json](../edits/I064.json). Proposals: [renames/I064_renames.md](../renames/I064_renames.md). Questions: [questions/I064_questions.md](../questions/I064_questions.md).

Conventions: verdicts **P/M/F/NA**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 coverage and verbosity, Q2 value, Q3 accuracy, Q4 mnemonic and variable names, Q5 new mnemonic, Q6 naming, Q7 evidence quality. Annotation style as in I049 to I063. `spriteset_will.asm` is **SAMPLED ~15%** for line-by-line review (the first 230 lines, the tail and a few windows); the whole-file checks are in Q7. The struct format is documented once, in the `spriteset_freedan` block note of I063.

### tables/forced_walk_sequence_table.asm (1 table of 16 pointers + 16 lists, 59 lines before / 129 after, Bank 01 108894-109278, parts: 0 code / 17 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | Header and part note repeated each other; no per-list information | E1 |
| Q2 value | F | Did not say what the numbers drive (the camera pan speed), nor the totals | E1, E2 |
| Q3 accuracy | **F** | (a) **"byte pairs: sprite frame index + movement step delta"**, "selecting walking animation frames": the lists are little-endian words, low byte the delay and high byte the step, read by `CameraScrollStepLookup` for the four `CameraPan*` handlers; the walk sprite comes from the warp stream and `direction_velocity_table`. (b) **"terminated by `$00,$00`"**: any word with a zero high byte ends the list (always `$0000`). (c) **"indexed by direction"**: the index is the low nibble of byte 6 of the extended warp entry, the direction is in bits 4/5/7. (d) the hand sums of all 16 lists are multiples of 16 pixels (256 to 1280) | E1 (`CameraScrollStepLookup`, `CameraPanDown`, `forced_walk`), E2 (`warps_interaction`, ROM bytes decoded by hand) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | `binary_01A97E` ... hide a word list; the block name says "sequence" | PROPOSED R-I064-1 |
| Q7 evidence quality | M | Whole file read (59 lines); totals computed by hand for all 16; the pan loop was traced only for `CameraPanDown` (the other three are assumed symmetric) | E1, E2 (UNVERIFIED-RUNTIME: OQ-I064-1) |

Actions taken: block note rewritten (consumers, format, ease profile, a table of the 16 totals); table part note rewritten; 16 list part notes (new); no inline comments (data); no mnemonics added.
Deferred: R-I064-1; which warp uses which list (OQ-I064-1).
Before/after stats: 59 to 129 lines; generic labels remaining: 16 (`binary_01A97E` ... `01AAC2`).

### tables/spriteset_town_objects.asm (1 table of 2 pointers, 2 frame lists, 8 groups, 75 lines before / 94 after, Bank 14 1359872-1360072, parts: 0 code / 11 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 3-line header; no part notes | E1 |
| Q2 value | F | No user, no VRAM destination, no art file | E1, E2 |
| Q3 accuracy | **F** | **"doors, switches and other common interactive elements in town scenes"**: the only user is `fr32_laborer_npc` (Freejia), two tile streams of 4 frames, one 8x8 tile each, to VRAM `$3FE0` (animation 0, hold 7) and `$3FF0` (animation 1, hold 6), art `misc_fx_1CD080` | E1 (`AdvanceSpriteAnim`, `fr32_laborer_npc`), E2 (grep: one user) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | `spriteset_town_objects` is a guess; the two lists are told apart only by offset | PROPOSED R-I064-2 |
| Q7 evidence quality | M | Whole file read (75 lines); the art content was not looked at | E1, E2 (UNVERIFIED-RUNTIME: OQ-I064-2) |

Actions taken: block note rewritten; 3 part notes (table and both lists); no inline comments (data); no mnemonics added.
Deferred: R-I064-2.
Before/after stats: 75 to 94 lines; generic labels remaining: 10.

### tables/spriteset_will.asm (1 table of 72 pointers, 72 frame lists, 398 records, 238 groups, 1781 sub-sprites, 3668 lines before / 3697 after, Bank 15 1409024-1426465, parts: 0 code / ~311 data) SAMPLED ~15%

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | F | A 3-line header; no index map, no counts, no part notes | E1 |
| Q2 value | F | Nothing on the shapes of the frames, what differs from Freedan, or the index space shared by all forms | E1, E2 |
| Q3 accuracy | **F** | **"flute-play ... animation frames"**: `FluteMusicActorController` holds the player in the static pose `PlayerStaticBodyPose` while a melody plays, and no other stager of a flute animation exists; the claim is dropped (OQ-I064-3) | E1 (`item_use_system`, `player_character`) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | 72 `sprite_set_15....` and 238 `sprite_group_15....` offset names | PROPOSED R-I064-3, R-I064-4 |
| Q7 evidence quality | M | **Sampled** for line reading; whole-file lookups: count byte equals the number of sub-sprites in all 238 groups (at most 12), lists are `4n + 2` bytes and end with `$FFFF` in the ROM for all 72, `17441 = 144 + 72 x 2 + 4 x 398 + 238 x 13 + 7 x 1781` | E1, E2 (UNVERIFIED-RUNTIME: OQ-I064-4) |

Actions taken: block note rewritten (differences from Freedan, checks, the flute claim); 2 part notes (the table with the shapes and the first group); no inline comments (data table); no mnemonics added.
Deferred: R-I064-3, R-I064-4; the unattributed indices (OQ-I064-4).
Before/after stats: 3668 to 3697 lines; generic labels remaining: 310.

### Iteration summary

- Files: 3 audited (1 sampled). Q3: 3 F. Notes written: 3 block notes, 22 part notes (21 new, 1 updated: the old `forced_walk_sequence_table` part note), 0 inline comments.
- Patterns: (1) a layout described from the file name instead of the reader (frame / step byte pairs for a camera speed profile); (2) a purpose guessed from a label ("town objects", "flute-play"); (3) a tile-streaming block documented as if it were an OAM spriteset.
- Docs repeating old claims: `docs/cop/families/camera.md` and `docs/bank01-data-tables.md` / `docs/code/README.md` still name the lists "forced-walk animation sequences" (logged under R-I064-1).
- Gate: shared with I063: `npm run merge` for both specs, `npm run extract:lt`, both spec dry-runs to 0 files to change, `npm run rebuild`: checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged).
- Spec: `plans/extracted-audit/edits/I064.json`.
- Suggested commit message: `Audit I064: forced-walk camera pan lists, Freejia tile fx, Will spriteset`

Please commit when you're ready.
