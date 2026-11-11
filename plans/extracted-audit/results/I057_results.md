# I057 - 2026-10-28 - files: system/diary_menu/diary_menu_window_dma.asm, system/diary_menu/sFA_diary_menu.asm, system/title_screen/sFC_title_intro.asm
Status: COMPLETE

Spec: [edits/I057.json](../edits/I057.json). Proposals: [renames/I057_renames.md](../renames/I057_renames.md). Questions: [questions/I057_questions.md](../questions/I057_questions.md).

Conventions: verdicts **P/M/F/NA**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 coverage and verbosity, Q2 value, Q3 accuracy, Q4 mnemonic and variable names, Q5 new mnemonic, Q6 naming, Q7 evidence quality. Annotation style as in I049 to I055: aggregated notes, a part note for every label, inline comments only for operands and non-obvious steps.

I055 and I056 were skipped at the user's request; I057 does not depend on them.

### system/diary_menu/diary_menu_window_dma.asm (1 thinker with 15 inner labels + 9 data tables, 144 lines before / 211 after, Bank 00 48049-48203, parts: 16 code / 9 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | F | A 3-line header; no part note for any of the 25 labels, no comment on the `QueueDma` operands or on the selection logic | E1 |
| Q2 value | F | The header named the cursor words `$0D92`, `$0D96`, `$0D98` but not what they are, which rows the tables cover, or what each of the three `QueueDma` calls does | E1, E2 |
| Q3 accuracy | **F** | (a) **"window-mask DMA channel tables" / "26-byte HDMA/DMA setups"**: `#26` is the B-bus register operand of `COP QueueDma` (`$2100 + 26` = WH0, with WH1 as the second register of the mode); it is not a size. (b) **Each table is a direct HDMA table** (line count, WH0 left, WH1 right, terminator appended by the assembler): 3n + 1 bytes. They are highlight bands under a cursor (31-line slot bands, 15-line tab bands), not "window layers for the diary UI panels". (c) **"as the player navigates diary pages"**: the three words are slot cursor, copy-target slot and tab / settings-row cursor. (d) **Not in the header**: while a copy target is set the source band is queued on odd frames only (a 30 Hz flicker); each `QueueDma` takes its own channel so the three bands overlay. (e) **TRANSFORM HAZARD**: `db-us/transforms.json` swaps `dma_channel_00BC4C []` and `dma_channel_00BC4D [...]` with one regex that needs the two labels directly adjacent; a part note on either label makes the regex miss and the ROM loses a byte (first gate after the first I057 merge failed with checksum 223006106, crc 643346720, size 3062203) | E1 (the file; `hdma_channel_config`; `cop_handlers_vram.QueueDma`), E2 (`sFA_diary_menu` writes the cursors; `transforms.json`), E3 (`docs/cop/families/*`), E4 (WH0/WH1, WOBJSEL, CGWSEL) |
| Q4 mnemonic/var names | NA | `frameCounter`, `WH0` are named; the cursor words are `sFA` state words with no mnemonic (see R-I057-2) | E1 |
| Q5 new mnemonic | NA | None needed here | E1 |
| Q6 naming | M | `dma_channel_*` names are offsets and "channel" is wrong (the COP allocates the HDMA channel); `diary_menu_window_dma` is acceptable | PROPOSED R-I057-3 |
| Q7 evidence quality | M | E1 + E2 + E4; the on-screen look (black inside the window) is decoded from the registers, not observed | E1, E2, E4 (UNVERIFIED-RUNTIME: OQ-I057-3) |

Actions taken: block note rewritten (the three cursors, the table format, the selection, the transform-adjacency warning); 23 part notes (the 2 transform-adjacent labels are deliberately `null` and the block note says why); 7 new inline comments; no mnemonics added.
Deferred: R-I057-3; R-I057-7 (hazard recorded for the ledger); OQ-I057-3.
Before/after stats: file 144 to 211 lines (`wc -l`); full-line comment lines 3 before, 40 after; generic labels remaining: 24 (`code_00BBB1`, 14 `loc_`, 9 `dma_channel_*`; all documented except the two adjacent ones, which the block note covers).

### system/diary_menu/sFA_diary_menu.asm (scene `$FA` actor and ~40 routines, 2084 lines before / 2455 after, Bank 0B 778810-783347 plus strings, parts: ~100 code / 6 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | 96 full-line comment lines, many of them echoes of the instruction; the large flows (slot scan, copy, erase, camera pan, remap, warp) had a title and no contract, and ~160 labels had no part note | E1 |
| Q2 value | M | The structure was described; the meaning of each word in `$0D74-$0D9E`, the SRAM page contents and the return values of the menus were not | E1, E2 |
| Q3 accuracy | **F** | See the list below | E1, E2, E3, E4 |
| Q4 mnemonic/var names | M | `sourceSceneId`, `joypadHeld`, `joypadCurrent`, `remapA/B/X/Y` are used; `free101C` (`$7F101C`) holds the camera-pan step count and its name says nothing (6 uses here, 14 in other files, so it is a shared actor field); the sound setting `$0B24` / `$0D90` and button type `$0B26` / `$0D8E` have no mnemonic | E1 |
| Q5 new mnemonic | M | `soundMode` / `buttonType` would help; none added (mnemonics frozen in this campaign) | PROPOSED R-I057-1, R-I057-2 |
| Q6 naming | M | 7 `loc_` labels, 2 `code_list_*` and 5 `table_*` are generic; the routine names (`Diary*`) are good; `DiaryUnused24B_noref` is mis-decoded | PROPOSED R-I057-2, R-I057-4 |
| Q7 evidence quality | M | E1 + E2 + E3 + E4; the behaviours that depend on the baserom's transformed remaps and on how the bands look are marked UNVERIFIED-RUNTIME | E1, E2, E3 (UNVERIFIED-RUNTIME: OQ-I057-1, OQ-I057-2, OQ-I057-4) |

Wrong or stale statements in the old header and comments, corrected:

1. **Display**: `CGWSEL = $82 (sub=fixed, always apply)` is "main screen forced black inside the colour window, addend = sub screen"; `CGADSUB = $41 (add BG1+backdrop)` is add, half intensity, BG1 only (backdrop bit not set); `W34SEL` / `WOBJSEL` "for dialogue box masking" are window 2 on BG3/BG4 and window 1 on OBJ and the colour window, whose edges `diary_menu_window_dma` drives as highlight bands. The scene meta says overworld-map background (display mode `#08`); the old "Mode 7 scrolling" statement is kept only where the camera comments use it, and the display look is OQ-I057-3.
2. **State block**: `$0D80/82/84` holds **DEF** (`playerDef $0ADC`) and `$0D86/88/8A` **STR** (`playerStr $0ADE`); the old table had them swapped. The block runs to `$0D9E` (the BCD scratch for the stat strings), not `$0D98`. The cursors `$0D92` (slot), `$0D94` (slot being edited), `$0D96` (copy target), `$0D98` (tab or settings row) were described as "menu cursor / selected slot".
3. **SRAM**: the checksums are at `$3063FC` / `$3063FE` + n x 512 (not "+ slot x 4"), seeded `$3652`, by `save_system.ComputeSaveChecksum` with X = n x 512; the page at `$306200` + n x 512 is a copy of WRAM `$0A00-$0BFB` (508 bytes), not "event flag data".
4. **Masks**: `$3000` ("L+R shoulder buttons") is Start + Select in `joypadMaskStd`; `$2800` ("running + ability-active flags", also at the exit) is the `playerFlags` script lock `$0800` + guard stance `$2000`.
5. **Pan speed**: "12 frames per camera pan step" is `free101C = 12` pan steps per frame (the Bresenham walk of `DiaryCameraPan`).
6. **Warp**: "Camera X = 120px / Camera Y = 144px" are the `QueueMapChange` / warp destination X and Y (with facing and scroll-params word), not camera positions.
7. **Button types**: "Layout A / B" with "remap A to B" wording describe the raw remap words (`remapA := $8000` etc. are the values the physical buttons report); the legend names are Type 1 / Type 2. "Layout B: clear Start remap only" is `remapX := 0` (Type 2 only sets `remapX`). The statement that Type 2 is "no remap" is not true in this baserom (OQ-I057-1).
8. **`DiaryMenuVBlankHandler`** ("provides a custom VBlank handler that reads raw joypad input... for the menu") is a copy of `VBlankWaitAndJoypad` whose only caller is the unreferenced `DiaryAwaitButtonRelease_noref`; the live menu uses the engine routine.
9. **Tab menu**: the actor header called scene `$FA` "title screen menu"; the title screen is `$FC`, which queues `$FA` through `TitleToDiaryTransition`, and the prologue scenes `$8C-$8F` spawn the Start-poll actor so Start there lands in `$FA` too (see I058).
10. Added what the old text never said: the Dark Space layout variant `$0AB2`, the sound and button settings inside the save page, the `DialogueOptions` return (index + 1, 0 = cancel), the copy and erase flows.

Code quirks found (not changed, documented in the notes): `DiaryScanSramSlots` repeats the `$0D80-$0D84` stores, so `$0D86-$0D8A` are never zeroed for empty slots; `DiaryCopyExecute` falls back to `DiaryCopySourceConfirm` when the target is used (normally unreachable); a Type 2 selection leaves the other remaps untouched; `DiaryUnused24B_noref` is decoded in the wrong register width (R-I057-4).

Actions taken: block note rewritten (overview, display setup, state block, SRAM layout, button types, unreferenced code); 168 part notes; 146 inline comments (none on or between the `LDA #$8000` / `TSB joypadHeld` lines that `transforms.json` matches); no mnemonics added.
Deferred: R-I057-1, R-I057-2, R-I057-4, R-I057-6; OQ-I057-1, OQ-I057-2, OQ-I057-4, OQ-I057-6.
Before/after stats: file 2084 to 2455 lines (`wc -l`); full-line comment lines 96 before, 242 after; generic labels remaining: 14 (7 `loc_` documented, 2 `code_list_`, 5 `table_`).

### system/title_screen/sFC_title_intro.asm (title scene `$FC` intro actor + comet actor + a palette stub, 84 lines before / 82 after, Bank 0B 772391-772524, parts: 3 code / 0 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 19-line header and 19 comments but no part notes and no block note on flag `$F4` or the palette | E1 |
| Q2 value | M | The flow was narrated; who reads `$F4`, where the palette ends up and what is on screen after each TM write were not | E1 |
| Q3 accuracy | **F** | (a) **`TM = $10` is OBJ only**, not "BG1 only / title background"; **`TM = $16` is BG2 + BG3 + OBJ**, not "BG1 + BG2 + BG3" (`TM` bits are `---o4321`). (b) **Flag `$F4` is not "title screen viewed"**: it is tested by `pr8C_prologue1` (branch when clear) and `pr8C_prologue5` (when set) and cleared in `pr8C_prologue1`, so it marks a prologue started by the idle timeout. (c) **`pal_ending_comet` is not a "comet sprite palette"**: it is copied over CGRAM colours 0-7, which are BG colours (it replaces the first 8 title colours). (d) **`gfxCacheIdxB = $0804` is not a "transition effect index"**: it is the two speed bytes (exit `$04`, enter `$08`). (e) **`$4001` "title display mode"** is bit 14 = HUD off + bit 0 = full BG3 upload (`displayModeFlags`). (f) **"64px" and "240 ticks"** are loop cycles (`StageSpriteLoopMoveX ( #00, #40, #02 )` = 64 cycles at X speed 2). (g) **`TitlePaletteFadeStep`** ("palette fade") has no spawn or pointer anywhere in `extracted/` | E1 (the file; `QueueMapChange`; `CopyPalette`; `StageSpriteLoop*`), E2 (`pr8C_prologue*`; `scene_actors`; rg for `TitlePaletteFadeStep`), E3 (`docs/structs-reference.md`), E4 (`TM`) |
| Q4 mnemonic/var names | NA | Existing names used | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | `TitleCometSpriteActor` and `TitleIntroInit` are fine; `TitlePaletteFadeStep` suggests a fade it may not perform and is unreferenced | PROPOSED R-I057-5 |
| Q7 evidence quality | M | E1 + E2 + E4; the idle-timeout path and the on-screen order were not run | E1, E2 (UNVERIFIED-RUNTIME: OQ-I057-5) |

Actions taken: block note rewritten (spawn, flag `$F4`, TM states); 3 part notes; 12 inline comments; no mnemonics added.
Deferred: R-I057-5; OQ-I057-5.
Before/after stats: file 84 to 82 lines (`wc -l`); full-line comment lines 19 before, 16 after (wrapped lines became single-line paragraphs; the content grew); generic labels remaining: 0.

### Iteration summary

- Files: 3 audited. Q3: 3 F. Notes written: 3 block notes, 194 part notes (23 + 168 + 3), 165 inline comments (7 + 146 + 12).
- Patterns: (1) hardware registers or bits read as the wrong layer or mode (`TM`, `CGWSEL`, `CGADSUB`); (2) a count and a rate swapped (12 frames per step); (3) a B-bus register operand read as a size (`#26`); (4) two adjacent state fields swapped (STR / DEF); (5) button masks named after the wrong buttons; (6) **a transform whose regex needs two labels adjacent, which no note may separate**.
- Docs repeating old claims (logged in R-I057-6): `docs/cop/families/input.md` (the `$0001` = R claim), `docs/wram-memory-map.md` section 2.9 (remap table), `docs/code/bank0B-late-bosses-system-cutscene-actors.md` (diary rows).
- Gate: the first rebuild after the merge failed (see (e) above); both notes were set to `null`, the merge, `extract:lt` and the rebuild re-run: checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged); the I057 spec dry-run reports 0 files to change. The gate was re-checked after the I058 merge (see I058).
- Spec: `plans/extracted-audit/edits/I057.json`.
- Suggested commit message: `Audit I057: diary menu scene, window HDMA bands, title intro; note the dma_channel transform adjacency hazard`

Please commit when you're ready.
