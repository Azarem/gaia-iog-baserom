# I058 - 2026-10-28 - files: system/title_screen/sFC_title_start_handler.asm, system/title_screen/spm_title_actors.sprite.asm, system/world_map/HdmaWindowEffect.asm
Status: COMPLETE

Spec: [edits/I058.json](../edits/I058.json). Proposals: [renames/I058_renames.md](../renames/I058_renames.md). Questions: [questions/I058_questions.md](../questions/I058_questions.md).

Conventions: verdicts **P/M/F/NA**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 coverage and verbosity, Q2 value, Q3 accuracy, Q4 mnemonic and variable names, Q5 new mnemonic, Q6 naming, Q7 evidence quality. Annotation style as in I049 to I055: aggregated notes, a part note for every label, inline comments only for operands and non-obvious steps.

### system/title_screen/sFC_title_start_handler.asm (2 actors + 1 shared routine, 71 lines before / 74 after, Bank 0B 772529-772609, parts: 3 code / 0 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 10-line header and 11 comments; no part notes, no note on the mask, the poll operand or the transition values | E1 |
| Q2 value | M | It said what the file does, not why `$FFFC` and `#$1001` work together or what the transition parameters mean | E1, E2 |
| Q3 accuracy | **F** | (a) **"Start or R"**: `BranchIfPressed #$1001` has `$1000` = Start and bit 0 = "test `joypadRaw` instead of `joypadCurrent`"; **R (`$0001` in a button word) is never tested**. (b) **"Mask all joypad input except Start/Select/L/R"**: `$FFFC` clears nearly everything from `joypadCurrent` (the vanilla `$FFF0` is widened by `transforms.json`); Start still works only because it is read from `joypadRaw`. (c) **`sFC_actor_0BC9AE` "adds a delay"** names the title-scene variant by an old address; the extracted label is `TitleStartDelayedInit` inside `sFC_title_start_handler`. (d) **`sFC_actor_0BC9BD` is not for "respawned or quick-entry cases"**: it is spawned in the actor lists of the prologue scenes `$8C-$8F`, so Start skips the slides. (e) **"clears GFX cache state"** / **"Clear dialogue/state scratch"** is `transitionBrightness := 0` plus the speed bytes `gfxCacheIdxB := 0` and the type word `gfxCacheIdxA := 1` (exit type 1 = instant blank, enter type 0 = graduated fade). (f) **`SetEntryHereAndYield` "Mark actor for cleanup"** saves the re-entry point and yields one frame; the actor lives until the scene change replaces it, holding INIDISP = `$00` | E1 (the file; `BranchIfPressed` handler in `cop_handlers_player_query`; `QueueMapChange`; `vblank_joypad`; `db-us/transforms.json`), E2 (`scene_actors` for the `$8C-$8F` and `$FC` lists; `gfxCacheIdxA/B` readers in `scene_lifecycle`), E3 (`docs/cop/families/input.md` documents the raw-source bit) |
| Q4 mnemonic/var names | NA | `joypadMaskStd`, `transitionBrightness`, `gfxCacheIdxA/B` used; nothing missing | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | `sFC_actor_0BC9BD` is an address name for the prologue-scene Start poll; `loc_0BC9C6` is the shared poll loop | PROPOSED R-I058-1 |
| Q7 evidence quality | M | E1 + E2 + E3; the Start press itself and the transition look were not run | E1, E2 (UNVERIFIED-RUNTIME: none specific; the R claim rests on the handler code) |

Actions taken: block note rewritten (two variants, mask plus raw-source Start, transition parameters); 4 part notes (3 new, 1 rewritten); 9 inline comments (1 new, 8 rewritten); no mnemonics added.
Deferred: R-I058-1, R-I058-3 (doc fix).
Before/after stats: file 71 to 74 lines (`wc -l`); full-line comment lines 11 before, 11 after (content longer); generic labels remaining: 2 (`loc_0BC9C6`, documented; `sFC_actor_0BC9BD`).

### system/title_screen/spm_title_actors.sprite.asm (1 pointer list, 1 sprite-set, 1 sprite-group with 48 parts, 61 lines, parts: 0 code / 3 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | F | No block note and no part notes | E1 |
| Q2 value | F | Nothing says it is the title comet's frame data or how it is loaded | E1, E2 |
| Q3 accuracy | NA | There was nothing to check | E1 |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | `sprite_set_000002` and `sprite_group_000008` are offset names | PROPOSED R-I058-2 |
| Q7 evidence quality | M | E1 + E2; what the 48 parts draw was not run | E1, E2 (UNVERIFIED-RUNTIME: OQ-I058-2) |

Findings (carried here because the file cannot take notes, see below): `scene_meta` line 2980 (`spritemap < #$0165, #00, @spm_title_actors >` in the `$FC` scene card) loads it; `TitleCometSpriteActor` (in `sFC_title_intro`) plays animation `#00` from it. The pointer list has one entry, `sprite_set_000002`, one frame (`sprite-set < #$0000, &sprite_group_000008 >`). The group is 12 header values (extents and 8 values nothing reads, as found in I055), then the part count `$30` (48), then 48 parts of 7 bytes (size flag, X, mirror, Y, mirror, tile word); the parts form a diagonal run with rows 16 px apart, i.e. the comet and its tail. The count is the 13th value, the last of the header (the first value happens to be `$30` too).
Actions taken: none in this file: **the merge script cannot attach notes to `.sprite.asm` files** (`cannot determine the ROM bank of this file`; the same tooling gap as I055, R-I055-5). The note text was prepared, rejected by the dry-run, and removed from the spec; the findings above are in this results file only.
Deferred: R-I058-2; R-I055-5 (tooling); OQ-I058-2.
Before/after stats: file unchanged (61 lines by `wc -l`); full-line comment lines 0 before, 0 after; generic labels remaining: 2 (`sprite_set_000002`, `sprite_group_000008`).

### system/world_map/HdmaWindowEffect.asm (1 thinker, 5 routines, 2 templates, 178 lines before / 171 after, Bank 03 239678-239936, parts: 9 code / 2 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 25-line header plus 43 comment lines, none of them on the table templates, the `QueueDma` operands or the offset arithmetic | E1 |
| Q2 value | M | The phases were described, the data they produce were not | E1 |
| Q3 accuracy | **F** | (a) **"iris/spotlight", "sine tables", "HDMA window registers"**: no window register or sine table is involved. The two tables are **BGMODE (`$2105`)** and **COLDATA (`$2132`)** HDMA tables: Mode 7 (`$07`) down to a boundary row, one line of Mode 1 / BG3 priority (`$09`), and a white fixed-colour write on the boundary row. (b) **"channel 5 / channel `$32`"**: `#05` and `#32` are the PPU B-bus registers of `COP QueueDma`, not channel numbers (`hdma_channel_config` gives the transfer mode). (c) **"sine table read position scrolls"**: the actor offset `$7F2104,X` is added to the second line count of both tables, so the **boundary row moves down 1 line per offset step**: 151 at spawn to 231 after the 40 frames (off the 224-line screen). (d) **Inverted condition**: "route active, `$0D58` nonzero and `$0D5A` = 0" is destination chosen with **no route playing yet**; the opening sequence runs when there is no destination or a route id is set. (e) **"`InitSineTableBuffers` fills both buffers with `$01FF` (fully open window)"**: the fill is a pattern that, read as HDMA entries, becomes a count `$FF` followed by `01 FF` pairs: every other scanline below the boundary gets a white fixed-colour write. (f) The COLDATA template's seventh byte is never copied (6 bytes are) and the terminator is written for the BGMODE table only | E1 (the file; `hdma_channel_config`; `QueueDma` handler; `thinker_execution`), E2 (`WorldMapController` spawn and the `$0D58` / `$0D5A` writers; `frameCounter` in the NMI), E3 (`docs/code/bank03*`; PPU registers), E4 (BGMODE bit layout, COLDATA bits 7-5 planes / 4-0 intensity) |
| Q4 mnemonic/var names | M | `sineTableA`, `sineTableB`, `S_sineTableB` are misnamed (BGMODE / COLDATA buffers); `UpdateHdmaWindowParams` has a raw `$0036` operand where `frameCounter` exists | PROPOSED R-I058-1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | **F** | `HdmaWindowEffect`, `QueueHdmaSineBuffers`, `UpdateHdmaWindowParams`, `InitSineTableBuffers` and the two mnemonics claim a window and a sine table that are not there | PROPOSED R-I058-1 |
| Q7 evidence quality | M | E1 + E2 + E3 + E4; what the split looks like on the world map was decoded from the tables, not observed | E1, E2, E4 (UNVERIFIED-RUNTIME: OQ-I058-1) |

Actions taken: block note rewritten (what the two tables are, buffers by parity, contents, phases, the misleading names); 11 part notes (7 new, 4 rewritten); 27 inline comments (2 new, 25 rewritten); no mnemonics added.
Deferred: R-I058-1, R-I058-3 (the "iris" wording in `WorldMapController.asm`, for I059); OQ-I058-1.
Before/after stats: file 178 to 171 lines (`wc -l`); full-line comment lines 43 before, 27 after (wrapped lines became single-line paragraphs; the content grew); generic labels remaining: 7 (`loc_03A85B`, `loc_03A899`, `loc_03A8BA`, `loc_03A8BD`, `loc_03A91A`, all documented; `binary_03A932` and `binary_03A939`, the two templates, documented).

### Iteration summary

- Files: 3 audited (1 not editable by the tooling). Q3: 2 F, 1 NA. Notes written: 2 block notes, 15 part notes (4 + 11), 36 inline comments (9 + 27).
- Patterns: (1) a button word's flag bit read as a button (`#$1001` bit 0 = raw source, not R); (2) a PPU B-bus register operand read as a channel number or a size (`#05`, `#32`; also `#26` in I057); (3) names that describe a hypothesis (iris, sine, window) instead of the registers written; (4) an inverted condition in a header ("route active"); (5) a data file the note tooling cannot reach (sprite files, second time).
- Docs repeating old claims (logged in R-I058-3): `docs/cop/families/input.md` (the `$0001` = R claim; see also R-I057-6); the "iris" wording in `WorldMapController.asm` (I059); docs calling `HdmaWindowEffect` an iris or window effect (not re-checked).
- Gate: `npm run extract:lt`, the I058 spec dry-run to 0 files to change (also the I057 spec), `npm run rebuild`: checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged). A first attempt to run the I057 dry-run and the rebuild right after the I058 merge hit a transient missing `extracted/` (and left `artifacts/crc.json` with a bad checksum); re-running `extract:lt` and the rebuild restored it and the gate above is from that clean run.
- Spec: `plans/extracted-audit/edits/I058.json`.
- Suggested commit message: `Audit I058: title Start handler (raw Start poll, not R), world-map BGMODE/COLDATA HDMA effect`

Please commit when you're ready.
