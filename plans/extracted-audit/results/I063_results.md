# I063 - 2026-10-28 - files: tables/spriteset_particle_fx.asm, tables/shared_word_table.asm (checklist name `item_component_table.asm`), tables/spriteset_freedan.asm
Status: COMPLETE

Spec: [edits/I063.json](../edits/I063.json). Proposals: [renames/I063_renames.md](../renames/I063_renames.md). Questions: [questions/I063_questions.md](../questions/I063_questions.md).

Conventions: verdicts **P/M/F/NA**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 coverage and verbosity, Q2 value, Q3 accuracy, Q4 mnemonic and variable names, Q5 new mnemonic, Q6 naming, Q7 evidence quality. Annotation style as in I049 to I060. `spriteset_freedan.asm` is **SAMPLED ~15%** for line-by-line review (the first 400 lines, the head and tail of the group area and a few windows); whole-file properties were checked by lookups (see Q7). I061 and I062 have no results files yet and are still pending; this iteration was run on request ahead of them.

### tables/spriteset_particle_fx.asm (1 table, 1 frame list, 4 groups, 45 lines before / 64 after, Bank 14 1360172-1360280, parts: 0 code / 6 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 3-line header, no part notes, nothing on format | E1 |
| Q2 value | F | Nothing said who uses the block, what the frames do or how the engine reads it | E1, E2 |
| Q3 accuracy | **F** | **"sparkles, dust and other lightweight ambient particles"**: the only user is `awB4_snake_pit_fx`, which streams 4 tile frames (128 bytes each, `misc_fx_1CD380`) to VRAM word `$2020` with `AdvanceSpriteAnim` (it reads only `+$0D` and `+$12` of each group). Not a particle library and not OAM sprites on this path | E1 (`AdvanceSpriteAnim`, `awB4_snake_pit_fx`), E2 (grep: one user) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | `spriteset_particle_fx` describes a guess | PROPOSED R-I063-1 |
| Q7 evidence quality | M | E1 + E2 + a ROM check of the terminator; the whole file (45 lines) read | E1, E2 (UNVERIFIED-RUNTIME: OQ-I063-3) |

Actions taken: block note rewritten (user, what the engine reads, the 6-frame ping-pong, tile bytes and VRAM destination); 3 part notes (table, list, first group); no inline comments (data); no mnemonics added.
Deferred: R-I063-1.
Before/after stats: 45 to 64 lines; generic labels remaining: 5 (`sprite_set_14C12E`, `sprite_group_14C148` ... `14C184`).

### tables/shared_word_table.asm (formerly `item_component_table.asm`; 1 table of 15 pointers + 15 console strings, 54 lines before / 86 after, Bank 01 125711-125864, parts: 0 code / 16 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 3-line block note and a part note that repeats it; no index list and no usage | E1 |
| Q2 value | M | Did not say that the index is the `[LU:n]` operand, nor which indices are used | E1, E2 |
| Q3 accuracy | **F** | (a) **"item name prefix components"**: the words also build ability names (`Psycho Dash`, `Dark Friar`), descriptions (`Restores strength.`, `Letter from Lance.`) and the item menu prompts (`Rearrange`, `Select`); `Statue` ($0C) alone appears in 18 lines. (b) "etc." hid that `Rearrange`, `Select`, `Statue`, `Uses` and `from` are not prefixes. (c) Three words are never selected: `$00` Crystal, `$03` Hieroglyph, `$0D` Uses | E1 (`ConsoleCmd_InsertSharedWord`, `ConsoleStringRenderer` table), E2 (rg count of `[LU:n]` tags over `system_strings`: 68 tags in 63 lines) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | Offset names `consolestring_01EB2D` ... for words with a known index | PROPOSED R-I063-2, R-I063-5 (docs) |
| Q7 evidence quality | P | Whole file read; usage counts by rg over the whole `extracted/` tree | E1, E2 (UNVERIFIED-RUNTIME: OQ-I063-1) |

Actions taken: block note rewritten; table part note rewritten as an index / word / usage table; 3 part notes on the unused words; no inline comments; no mnemonics added.
Deferred: R-I063-2, R-I063-5.
Before/after stats: 54 to 86 lines; generic labels remaining: 15 (`consolestring_01EB2D` ... `01EBA2`).

### tables/spriteset_freedan.asm (1 table of 76 pointers, 76 frame lists, 353 records, 186 groups, 2147 sub-sprites, 3745 lines before / 3785 after, Bank 0E 950272-969435, parts: 0 code / ~263 data) SAMPLED ~15%

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | F | A 3-line header; no description of the table, the format, the index map or the counts; no part notes | E1 |
| Q2 value | F | A reader could not tell what an animation index or a sub-sprite field means, or which indices the player scripts use | E1, E2 |
| Q3 accuracy | **F** | (a) **"Includes Dark Friar cast poses"**: the cast in `attack_ability_system` stages `$36`-`$39`, the ordinary attack animations; no dedicated pose was found. (b) **"all 4 cardinal directions"** is true only for idle, walk, attack, block and the lunge; ladder, vine and shimmy are not directional in the same way. (c) `docs/structs-reference.md` (not this file) says the list terminator is `$0000`; every list ends with `$FFFF` | E1 (`AdvanceSpriteAnim`, `player_character`), E2 (ROM check of all 76 lists) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | 76 `sprite_set_0E....` and 186 `sprite_group_0E....` offset names; the `sprite-group` / `sprite-part` field names say nothing | PROPOSED R-I063-3, R-I063-4, R-I064-4 |
| Q7 evidence quality | M | **Sampled** for line reading; whole-file lookups: group count byte equals the number of sub-sprites in all 186 groups; list lengths are `4n + 2` for all 76 lists (label spacing) and the terminator is `$FFFF` in the ROM for all 76; record total 353 and sub-sprite total 2147 by arithmetic (`19163 = 152 + 76 x 2 + 4 x 353 + 186 x 13 + 7 x 2147`) | E1, E2 (UNVERIFIED-RUNTIME: OQ-I063-2, -4, -5) |

Actions taken: block note rewritten (format section shared by all `spriteset_*` files, player index sections, counts); 2 part notes (the table with the index map of the 48 attested animations, and the first group as a worked example); no inline comments (data table); no mnemonics added.
Deferred: R-I063-3, R-I063-4; the roles of about 28 indices (OQ-I063-2); the box bytes of the group header (OQ-I063-4).
Before/after stats: 3745 to 3785 lines; generic labels remaining: 262 (`sprite_set_...`, `sprite_group_...`).

### Iteration summary

- Files: 3 audited (1 sampled). Q3: 3 F. Notes written: 3 block notes, 9 part notes (8 new, 1 updated: the old `shared_word_table` part note), 0 inline comments.
- Patterns: (1) a purpose guessed from a label ("particle", "item prefix", "Dark Friar cast"); (2) a struct documented with the wrong terminator and no field meaning; (3) a block whose only user needed a different reading path (tile streaming rather than OAM).
- Docs repeating old claims (R-I063-4, R-I063-5): `docs/structs-reference.md` (terminator, header), `docs/bank01-data-tables.md` and `docs/code/README.md` ("item name prefix components").
- Gate: `npm run merge` for I063 and I064 (dry-run first), `npm run extract:lt`, both spec dry-runs to 0 files to change, `npm run rebuild`: checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged).
- Spec: `plans/extracted-audit/edits/I063.json`.
- Suggested commit message: `Audit I063: sprite set format, snake pit tile fx, shared word table, Freedan spriteset`

Please commit when you're ready.
