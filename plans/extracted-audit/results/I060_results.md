# I060 - 2026-10-28 - files: system/world_map/world_map_options.asm, system/world_map/world_map_routes.asm, tables/palette_bundles.asm
Status: COMPLETE

Spec: [edits/I060.json](../edits/I060.json). Proposals: [renames/I060_renames.md](../renames/I060_renames.md). Questions: [questions/I060_questions.md](../questions/I060_questions.md).

Conventions: verdicts **P/M/F/NA**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 coverage and verbosity, Q2 value, Q3 accuracy, Q4 mnemonic and variable names, Q5 new mnemonic, Q6 naming, Q7 evidence quality. Annotation style as in I049 to I059. `palette_bundles.asm` is **SAMPLED ~3%** for line-by-line review (the notes cover every structural piece; frame data was not read colour by colour), plus whole-file counts.

### system/world_map/world_map_options.asm (1 table of 39 menu pointers, 39 menu scripts, 41 handler blocks, 786 lines before / 1069 after, Bank 03 242689-244449, parts: 80 code / 1 data table)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 22-line header and almost no inline comments; no part note for any of the 80 menu and handler blocks, no table of which choice id staged which menu, no account of the grid byte | E1 |
| Q2 value | M | The header described the pattern ("Quit / destination", handlers, `QueueMapChange`) but not who selects a menu (`overworld_exit` and 13 NPC scripts through `$0D58`), how the answer maps to a route and a scene, or which entries are dead | E1, E2 |
| Q3 accuracy | **F** | (a) **"Entries `$1E`-`$26` display `[TPL:11]` and return"** and **"entry `$26` (`code_03B922`) has a trailing REP/DEX sequence, dead code or padding"**: the empty-template entries are `$1C`-`$25` (not from `$1E`); `$26` prints Nothing!! and `loc_03B928` is that string decoded as code, so the REP/DEX is text. None of `$00` and `$1C`-`$26` is staged by any script. (b) **"2-5 menu choices"**: the grid byte of `DialogueOptions` is (total items in the high nibble, 0 for one column; items per column in the low nibble) and the shipped values are `#01` (Quit only), `#02`, `#32`, `#42`. (c) **`RestoreSavedPtr` "cleanup on cancel" after `DialogueOptions`**: the instruction after the COP is never reached; the Quit and B handlers `QueueMapChange` back to the origin with no route. (d) The list is **column by column**, so for `#32` / `#42` it differs from the reading order of the text; `MenuSelectionHandler` returns a 1-based index and always starts on item 0. (e) The pointer table is indexed by **choice id and `$1F`** (`$0D58` low five bits), not by a destination count. (f) The header does not say which ids are used (`$01`-`$1B`) and which are not (`$00`, `$1C`-`$26`; OQ-I060-1) | E1 (`DialogueOptions`, `MenuSelectionHandler`, `cop_handlers_dialog`), E2 (`overworld_exit`, 13 NPC scripts, `cop_handlers_effects` for the staging COPs), E3 (`docs/cop/families/dialog.md`) |
| Q4 mnemonic/var names | M | The `STA $0D60` writes (leader animation 7 for the Watermia to Euro legs) and `$0D58` / `$0D5A` have no mnemonics | PROPOSED R-I060-5 |
| Q5 new mnemonic | NA | None needed beyond R-I059-3 | E1 |
| Q6 naming | M | Eighty `code_03B...` labels; 7 handler blocks hold the Quit and the destination handler together | PROPOSED R-I060-1, R-I060-2, R-I060-3 |
| Q7 evidence quality | M | E1 + E2 + E3; the choice-id to menu to handler to route to scene map is a static trace of every handler | E1, E2 (UNVERIFIED-RUNTIME: OQ-I060-1, -3, -4) |

Actions taken: block note rewritten (menu format, handlers, choice-id table, unused ids, and a ROUTES section that carries the `world_map_routes.asm` facts, see below); 82 part notes (new); 6 inline comments (the 4 grid operands, the 2 `STA $0D60` writes); no mnemonics added.
Deferred: R-I060-1 to R-I060-3, R-I060-5.
Before/after stats: 786 to 1069 lines; generic labels remaining: 80 (`code_03B44F` ... `code_03BAD1`; each now has a part note) and `loc_03B928` (mis-decoded string, R-I060-3).

### system/world_map/world_map_routes.asm (1 table of 38 pointers + 37 route arrays, 420 lines, Bank 03 241015-242132, parts: 0 code / 38 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 16-line header with a wrong record layout; no part notes | E1 |
| Q2 value | F | Nothing says what the bytes drive, which route belongs to which trip, or which routes are unused | E1, E2 |
| Q3 accuracy | **F** | (a) **"`route-step < flags, direction, ?, distance >`"** with "turn left / right / sharp", "pixel distance `$10`-`$FF`", "airship/walking path": a step is three `movement_delta_table` indices (X into `$00CA`, Y into `$00CC`, rotation into `$00BC`) and a tick count; the map moves and rotates under the dots. (b) **"38 route definitions"**: 38 table entries, 37 distinct arrays (`$00` aliases `$01`); `$0E`-`$10` and `$23`-`$25` are staged by nothing found. (c) **"read steps until the array ends"**: each array ends with a hidden `$FF`; `$FE` (subroutine) is never used. (d) the step sums reproduce the distance between the staged start positions of the two scenes (e.g. route `$09` = 128 north), but only if each step runs n ticks while the engine applies n + 1 (OQ-I060-2) | E1 (`RouteAnimationEngine`, `movement_delta_table`), E2 (`overworld_exit`, `world_map_options`, NPC scripts) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | `route_step_03AD..` arrays are offset names, and the `route-step` field names are wrong | PROPOSED R-I060-6 |
| Q7 evidence quality | M | E1 + E2; geometry checked by hand on 5 routes; nothing run | E1, E2 (UNVERIFIED-RUNTIME: OQ-I060-2) |

Findings (carried in the `world_map_options.asm` block note, section ROUTES, because **this file has no bank information and the merge script cannot annotate it**: `cannot determine the ROM bank of this file`, the same tooling gap as the sprite files): format, delta indices, the route-to-trip table for all 31 used routes, the 6 unused ids.
Actions taken: none in this file.
Deferred: R-I060-6; a tool fix (accept the bank from the table's `?BANK`-less neighbours or add a `?BANK 03` line to the extraction output).
Before/after stats: 420 lines, unchanged; generic labels remaining: all (37).

### tables/palette_bundles.asm (1 table of 128 pointers, 132 bundle blocks, 1,200 sub-entries, 834 frame arrays, 10896 lines before / 10929 after, extraction bank 16 = ROM `$96`, parts: 0 code / ~966 data) SAMPLED ~3%

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | F | A 4-line header; no format description, no part notes | E1 |
| Q2 value | F | Nothing told the reader how to read a bundle, which colours the common ones set, or who starts them | E1, E2 |
| Q3 accuracy | **F** | (a) **"Compressed palette data"**: the data is plain BGR555 frames (a strip of N frames per sub-entry); only the sub-entry list and a hidden `0` byte frame it. (b) **"one or more CGRAM palette sets"**: a bundle is a list of 6-byte sub-entries `< N frames, &frames, CGRAM dest, size - 1, wait >` that animate independently. (c) **"Loaded by `LoadPaletteBundle` during scene setup"**: that COP, `PaletteRestart` / `PaletteStep` and the palette thinkers all take the id from `animScratch+2`; bundles are also started at run time (attack cleanup `$0B`/`$0C`, the world map palette reset, ambient cyclers). (d) the four empty labels `16D210`, `16D211`, `16D317`, `16D318` are one-byte bundles (only the end byte) that pad bundles `$77` and `$78` | E1 (`cop_handlers_palette`, `hdma_dma_spc`, the table), E2 (`WorldMapController`, `attack_ability_system`, `ambient_palette_cycler`), E3 (`docs/cop/families/palette.md`) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | `palette_bundle_168100` ... are offset names; the 4 empty bundles look like real ones | PROPOSED R-I060-4 |
| Q7 evidence quality | M | **Sampled**: whole-file counts by script (132 blocks, 1,200 sub-entries, 834 frame arrays; commonest (dest, size - 1) pairs `$21,$17` 446x, `$23,$19` 175x, `$81,$1D` 143x, `$80,$1F` 39x); read in full: the table, bundles `$0B`, `$0C`, `$77`, `$78` and about 30 other bundles | E1 (sampled), E3 |

Actions taken: block note rewritten (format, counts, commonest pairs, consumers, ROM bank); 9 part notes (the table, bundles `$0B`, `$0C`, `$77`, `$78`, the 4 empty bundles); no inline comments; no mnemonics added.
Deferred: R-I060-4; the bulk of the 128 bundles still have no part note (their colours and users are not identified: OQ-I060-5).
Before/after stats: 10896 to 10929 lines; generic labels remaining: about 960 (`palette_bundle_...`, `word_16...` arrays).

### Iteration summary

- Files: 3 audited (1 not editable by the tooling, 1 sampled). Q3: 3 F. Notes written: 3 block notes (the options one carries the routes section), 91 part notes (82 + 9), 6 inline comments.
- Patterns: (1) a mis-decoded string kept as code with an invented explanation (REP/DEX "dead code or padding"); (2) a record layout guessed from the field count (`flags, direction, ?, distance`) when the bytes are table indices and a tick count; (3) a "compressed" label on plain data; (4) a data file the note tooling cannot reach (now the fifth file: boot logos, Dark Space, title and overworld sprite files, then the routes); (5) a table described by its entry count instead of by its key (`$1F` mask of the choice id).
- Docs repeating old claims (logged in R-I060-7): `docs/code/bank03/radar-and-world-map.md` (route-step field meaning, the `$1E`-`$26` menu entries), `docs/structs-reference.md` (the `route-step` and `palette-bundle` struct field names, not re-checked), the "compressed" wording of the palette bundles in the bank 16 docs (not re-checked).
- Also this run: the I059 spec was re-merged (bundle `$0B` = Will's colours at CGRAM `$81`-`$8F`, one block note line and one comment).
- Gate: `npm run merge` for I059 and I060 (dry-run first; a first dry-run of I060 failed because `world_map_routes.asm` cannot take notes, its notes were moved into the `world_map_options.asm` block note), `npm run extract:lt`, both spec dry-runs to 0 files to change, `npm run rebuild`: checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged).
- Spec: `plans/extracted-audit/edits/I060.json`.
- Suggested commit message: `Audit I060: world map options menus and route table, palette bundle format`

### Phase roll-up (I055-I060, 6 iterations, 18 files, 3 per iteration)

Verdict distribution (Q1-Q7 rows for the 15 files of I055-I059, then the 3 files of I060):

| Q | P | M | F | NA |
|---|---|---|---|----|
| Q1 coverage/verbosity | 0 | 9 + 2 | 6 + 1 | 0 |
| Q2 value | 0 | 9 + 1 | 6 + 2 | 0 |
| Q3 accuracy | 0 | 0 | 11 + 3 | 4 + 0 |
| Q4 mnemonic/var names | 0 | 5 + 1 | 0 | 10 + 2 |
| Q5 new mnemonic | 0 | 2 + 0 | 0 | 13 + 3 |
| Q6 naming | 0 | 14 + 3 | 1 | 0 |
| Q7 evidence quality | 0 | 15 + 3 | 0 | 0 |

(The first number of each cell counts the Q rows of the I055-I059 results files, the second the I060 rows above. No Q row in the phase is a plain P.)

- **Q3 is the finding of the phase**: 14 of the 18 files had at least one factual error in the old notes (F) and none was fully right. The four files with nothing to check (sprite files with no prior notes) are NA.
- **Most common failures** (frequency across iterations):
  1. A name or sentence that describes a hypothesis rather than the registers or bytes (iris, sine, window, falling, altitude, template string): I058, I059, I060.
  2. A hardware register or bit read as the wrong layer or size (`TM`, `CGWSEL`, B-bus operands read as sizes, button bits): I055, I057, I058.
  3. A field or record described by its position rather than its function (route step fields, ability byte, scene id read as a location index): I056, I059, I060.
  4. A condition or answer order reversed (the menu wait, yes / no prompts, `BNE` read the wrong way): I056, I058, I059.
  5. Data decoded as code, or dead code kept beside live code: I056, I060.
  6. A note that cannot be written because the tool needs a bank (sprite files and `world_map_routes.asm`): I055, I056, I058, I059, I060.
- **Recurring naming patterns**: (a) `loc_` / `code_` / `binary_` / `route_step_` / `palette_bundle_` offset names in every file; (b) `scene` vs `location` vocabulary for the scene id; (c) type names inherited from the field count (`route-step`, `map-label`, `diary-entry` as a warp destination); (d) bank-0 absolute words with no mnemonic (`$B6`, `$B8`, `$BC`, `$CA`, `$CC`, `$DA`, `$0D52`-`$0D6F`): R-I059-3 and R-I060-5 together.
- **Tooling gaps**: the merge script cannot annotate files without bank information (5 files in the phase); a transform whose regex needs two adjacent labels forbids a note between them (I057); rebuild results are only valid after a fresh `extract:lt` (I056, I057, I058).
- **Open work for a follow-up**: the rename passes (R-I055 to R-I060), the docs corrections, a tool fix for bank-less files, and the runtime questions of all six iterations (none could be run).

Please commit when you're ready.
