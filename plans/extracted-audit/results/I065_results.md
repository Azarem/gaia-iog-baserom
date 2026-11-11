# I065 - 2026-10-28 - files: tables/dialog_template_table.asm, tables/parallax_scroll_table.asm, tables/scene_meta.asm
Status: COMPLETE

Spec: [edits/I065.json](../edits/I065.json). Proposals: [renames/I065_renames.md](../renames/I065_renames.md). Questions: [questions/I065_questions.md](../questions/I065_questions.md).

Conventions: verdicts **P/M/F/NA**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 coverage and verbosity, Q2 value, Q3 accuracy, Q4 mnemonic and variable names, Q5 new mnemonic, Q6 naming, Q7 evidence quality. Annotation style as in I049 to I064. `scene_meta.asm` is **SAMPLED ~10%** for line-by-line review (header, the first 340 lines, four more windows, the tail); the whole-file checks are in Q7.

### tables/dialog_template_table.asm (1 table of 22 pointers + 22 strings, 77 lines before / 169 after, Bank 01 117397-117670, parts: 0 code / 23 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 2-line header and one part note for the table; no note on any of the 22 strings | E1 |
| Q2 value | F | Nothing on what the tags do, which template is used how often, or who the colours belong to | E1, E2 |
| Q3 accuracy | **F** | (a) **"screen-effect presets (Dark Space transforms)"** for `$00`-`$07`: `[SEP:11,..][SEP:12,..]` write two colours of palette 4 (`DialogCmd_SetPaletteColor` to `$7F0A00 + index x 2`, `[PAL:4]` selects it) and `[SFX]` sets the per-character sound; the 8 templates are the colour pairs of Will, Kara, Lilly, Erik, Lance, Seth, Neil and a pink/red one (the `Name:` that follows `[TPL:n]` in the strings, e.g. `Will:` 124 times after `[TPL:0]`, `Kara:` 161 after `[TPL:1]`). (b) **ranges shifted by one**: size presets are `$08`-`$10` (not `$08`-`$11`), the "Where do you go?" prompt is `$11` (not `$12`, 49 uses), the silent variants are `$12`-`$15` (not `$13`-`$15`) and are the colours of `$00`, `$01`, `$02` and `$04`. (c) **`$10` is a duplicate** of `$0F`. (d) **`[SIZ:D,n]` is a box width and height** (`DialogCmd_OpenDialogueBox`: 13 x n), `[DLG:3,6]` / `[DLG:3,11]` the position; the old note said "line count" | E1 (`DialogStringRenderer`: InsertTemplate, SetPosition, SetPalette, SetSfx, SetPaletteColor, OpenDialogueBox, OpenDefaultBox), E2 (whole-file `[TPL:n]` counts, speaker names) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | 22 `dialogstring_01CAxx` offset names hide a table of roles | PROPOSED R-I065-1 |
| Q7 evidence quality | M | Whole file read (77 lines); counts by whole-file `rg`; the colour decoding (BGR555 to R/G/B) was computed from the words; which word is the glyph and which the outline was not seen on screen | E1, E2 (UNVERIFIED-RUNTIME: OQ-I065-1) |

Actions taken: block note rewritten (mechanism, tag meanings, table of the 22 templates with use counts and speakers); table part note rewritten; 22 string part notes (new, each with the decoded colours); no inline comments (data); no mnemonics added.
Deferred: R-I065-1, R-I065-5 (`docs/bank01-data-tables.md` repeats the old claims); OQ-I065-1, OQ-I065-6.
Before/after stats: 77 to 169 lines; generic labels remaining: 22 (`dialogstring_01CAC1` ... `01CB9B`).

### tables/parallax_scroll_table.asm (1 table of 37 pointers, 22 entry blobs, 14 `$FFFF` words, 190 lines before / 231 after, Bank 01 117760-119758, parts: 0 code / 37 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | Block note and the 22 per-type part notes are complete (earlier iterations); the 14 `binary_01D120` ... `01D13A` words had no notes | E1 |
| Q2 value | M | The unused words were only covered by one sentence in the block note | E1 |
| Q3 accuracy | P | The block note and the per-type notes were re-checked against the pointer list: types `$09`, `$0C`, `$0D` and `$0F`-`$1A` are the bare words, `$09` and `$19` share `binary_01D124`; the 14 words map to the 15 table indices as listed in the new notes. No correction needed | E1, E2 |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | `binary_01D12x` hide empty entries | PROPOSED R-I065-2 |
| Q7 evidence quality | P | Whole file read; every `&binary_` pointer matched to its table index | E1, E2 |

Actions taken: 14 part notes (new) for the `$FFFF` words, one table index each (`$09` and `$19` share one). Block note and the type notes left unchanged. No inline comments; no mnemonics added.
Deferred: R-I065-2.
Before/after stats: 190 to 231 lines (the plan's 120 was stale); generic labels remaining: 14.

### tables/scene_meta.asm (1 pointer table, 1 label table, 231 records, 2052 commands, 3080 lines before / 3131 after, Bank 0D 884736-897023, parts: 0 code / ~290 data) SAMPLED ~10%

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | F | A 4-line block note, no part notes, nothing on the commands, labels, jumps, branches or the two generated tables | E1 |
| Q2 value | F | Did not say how the records are found or what a record is (a command stream) | E1, E2 |
| Q3 accuracy | **F** | (a) **"fixed fields: tileset, tilemap, palette bundle, music track, collision layer, display configuration"**: a record is a command stream (display-mode first in all 231, then bitmap / palette / tileset / tilemap / spritemap / music / branch / label / jump / char-tiles); there is no collision data (`RebuildCollisionLayer` runs after the script). (b) **"indexed by scene ID"** is only true for the generated `scene_meta_list`; the original ROM scans packed records, and the rebuilt layout needs `SceneMetaLoad.patch`. (c) the **operand meanings** that `docs/code/bank0D-scene-meta.md` gives are wrong in several places (palette = start colour / count / offset, bitmap start / end as the destination, music operands swapped, bitmap modes as strip sizes): the handlers read palette < start, end, dest >, bitmap windows of the source with a VRAM base per mode, music < BGM id, room group > | E1 (`scene_script` handlers: ConfigDisplay, LoadBgTiles, LoadTilemap, LoadDualTilemap, FullGraphics, LoadSpriteTiles, SpcMusicLoadCmd, ConditionalLoad, Nop, LoadCharTiles, SkipScriptCommands; `SceneMetaLoad.patch`; `system_init` wram-init), E2 (whole-file operand counts), E3 (`docs/code/bank0D-scene-meta.md`) |
| Q4 mnemonic/var names | M | Handler names do not match the opcode meaning: `SceneCmd_LoadTilemap` ($04) loads palettes, `SceneCmd_LoadDualTilemap` ($05) the metatile sets, `SceneCmd_FullGraphics` ($06) the maps; `musicParentActor` ($06F2) receives the BGM id | PROPOSED R-I065-6, R-I065-7 |
| Q5 new mnemonic | NA | The mnemonics already exist (`display-mode`, `bitmap`, ...); field names inside them are a proposal | PROPOSED R-I065-8 |
| Q6 naming | M | `meta_label_NN` hides what is shared (56 labels); `scene_meta_00XX` is by id (acceptable) | PROPOSED R-I065-3 |
| Q7 evidence quality | M | **Sampled** for line reading (scenes `$00` to `$0C`, the `$06` branch pair, `$59`-`$5B`, `$AC` and the last records); whole-file checks: 231 records all starting with display-mode, 2052 commands by opcode, operand distributions (bitmap modes 255 / 62 / 2, tilemap flags `$01` 225 and `$02` 158, tileset layers `$01` 167, `$02` 105, `$03` 28, palette destinations), 25 null ids, 56 labels, 18 branches, 176 jumps (top targets), 234 music commands against 32 BGM ids, the 15-of-16 overlap with the unused ids of `scene_actors` | E1, E2 (UNVERIFIED-RUNTIME: OQ-I065-2, OQ-I065-3, OQ-I065-4) |

Actions taken: block note rewritten (readers, layout vs the original ROM, command table with counts, labels and branches); 8 part notes (new): the two generated tables and six sample records (`$00`, `$01`, `$03`, `$06`, `$AC`, `$FF`); no inline comments (data); no mnemonics added.
Deferred: R-I065-3, R-I065-5, R-I065-6, R-I065-7, R-I065-8; the scene id to place mapping (not decoded); OQ-I065-2 to OQ-I065-5.
Before/after stats: 3080 to 3131 lines; generic labels remaining: 231 `scene_meta_00XX` (id names) and 56 `meta_label_NN`.

### Iteration summary

- Files: 3 audited (1 sampled). Q3: 2 F (dialog, scene_meta), 1 P (parallax). Notes written: 2 block notes (dialog, scene_meta), 1 table part note updated, 44 part notes new (22 + 14 + 8), 0 inline comments.
- Patterns: (1) ranges listed from a mental model of the data instead of the table (the dialog templates were off by one); (2) a purpose guessed from a tag name ("screen effect") when the handler does something else (colours of a speaker); (3) a layout described as fixed fields when the data is a command stream; (4) handler and variable names that describe the first guess (`LoadTilemap` for palettes).
- Docs repeating old claims: `docs/bank01-data-tables.md` section 10 (template ranges, Dark Space) and `docs/code/bank0D-scene-meta.md` (operand meanings, modes, music operand order) are logged under R-I065-5.
- Gate: `npm run merge` for both I065 and I066 (dry-run first), `npm run extract:lt`, both spec dry-runs to 0 files to change, `npm run rebuild`: checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged).
- Spec: `plans/extracted-audit/edits/I065.json`.
- Suggested commit message: `Audit I065: dialog template colours and boxes, scene_meta command stream, parallax unused entries`

Please commit when you're ready.
