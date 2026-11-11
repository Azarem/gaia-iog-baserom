# I035 results

Files: `thinkers/parallax_thinker.asm` (Bank 00), `system/inventory/inventory_dma_setup.asm` (Bank 00), `actors/debug_stat_setter.asm` (Bank 0B). Related data notes corrected in the same spec: `tables/parallax_scroll_table.asm` and `system/hdma_ramp_tables.asm` (Bank 01).
Spec: [edits/I035.json](../edits/I035.json). New proposals: [renames/I035_renames.md](../renames/I035_renames.md). New questions: [questions/I035_questions.md](../questions/I035_questions.md).

Conventions (unchanged): verdicts **P/M/F/NA**; dispositions **FIXED / PROPOSED / DEFERRED-EVIDENCE / NOFIX**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 comment density, Q2 value, Q3 accuracy, Q4 mnemonic/address accuracy, Q5 mnemonic opportunity, Q6 part naming, Q7 evidence quality.

### File 1: thinkers/parallax_thinker.asm (Bank 00)

Evidence: E1 (the whole file read end to end; `RunThinkers_TypeB`, `SetupHdmaChannel_Direct`, `MulDivide`, `UploadScrollRegisters` / `WriteBgScroll` for the four scroll words, `scene_lifecycle` / `inventory_overlay` for the shared scratch, `sE7_space_bg_scroll` and the F7 credits code for the `$0720` region), E2 (all 37 `parallax_scroll_table` entries decoded with a scratch script; `scene_thinkers` spawn lists walked with a parser that handles `label+N` master entries, giving the scene list per table type), E3 `docs/code/bank00/thinkers-system.md`, `docs/bank01-data-tables.md`.

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A three-line header and 10 comments, several attached to the wrong line | FIXED (block note with spawn/frame flow, entry format, scroll sources, three record types, a generated table of the 20 used entries with buffers and scenes, quirks; 12 part notes; 199 comments: 189 new, 10 updated) |
| Q2 | M | A reader could not tell what a spawn does, what the parameter byte selects, or what the "speed" is | FIXED |
| Q3 | **F** | (a) **The table is not a "BG mode / scroll region" header.** `+3` = B-bus register index (bits 0-5), bit 6 = camera delta x16, bit 7 = swap sources; `+4` = record size (4 / 8 / 9); `+0` = WRAM buffer in bank `$7E`. (b) **Only some entries scroll a background.** Sizes 4 and 9 stream COLDATA / CGADSUB / CGDATA constants or a WH0/WH1 window rectangle; 9 of the 20 used entries are colour or window entries (the other 11 scroll). (c) **`ParallaxResolveChannelSpeed` returns the HDMA entry stride** (2 for mode 0, 3 for modes 1 and 2), not a "speed"; the band writers advance `$62` by it. The old `parallax_speed_config` note repeated the error. (d) **Comments sat on the wrong lines**: "Config bit $40" on the vertical-source load (`47357`), "Config bit $80" on the frame-parity test (`47385`), "Mode 9 HDMA" on the scroll-band loop head (`47462`), "Zero scroll-factor path" on the factor load (`47971`), the entry-point comment on the clear call (`47245`). (e) **The spawn parameter is a table index**, mislabelled "animScratch2 x 2" (`47316`; `animScratch2` is the filter word, the parameter is `animScratch+2`). (f) **Scroll sources**: default `$18` = BG1 H (`$068A`), `$1C` = BG2 V (`$0690`); with bit 7 `$18` = BG2 H (`$068C`), `$1C` = BG1 V (`$068E`). (g) **Band values are 12.4 fixed point**: factor `$0108` = x0.5, `$0110` = x1.0, `$010E` = x0.875; factor 0 = auto-scroll by `base/16` pixel per frame plus the camera delta; output = accumulator >> 4 sign-extended from bit 11. (h) **Window path**: records are 8 bytes (stride 9 decremented), skip rules are asymmetric (a rectangle starting on screen is clipped, one starting left of the screen is skipped when its right edge reaches `$FF`), gaps carry `$0000`, the 3-byte stride is hard-coded | FIXED |
| Q4 | M | Several operand roles were mislabelled (see Q3 d, e) | FIXED (comments) |
| Q5 | M | The four scroll words have misleading mnemonics: `effectScrollH` is BG2 H, `mapScrollV` is BG1 V, `effectScrollV` is BG2 V | PROPOSED (R-I035-4) |
| Q6 | M | The thinker and helpers are named for "parallax" and "ramp" but the code builds scanline bands; three internal branch targets and the thinker body are named by address | PROPOSED (R-I035-1, R-I035-2, R-I035-3, R-I035-5) |
| Q7 | M | E1 + E2 for the format, the stride, every decoded entry and the scene lists; the visible result of each entry, the meaning of the two `$5E` / `$60` stores and the window setup for scene `$C3` are static conclusions or open | DEFERRED-EVIDENCE (OQ-I035-1 to OQ-I035-4) |

### File 2: tables/parallax_scroll_table.asm and system/hdma_ramp_tables.asm (Bank 01, related data notes)

Evidence: E1 (all entries decoded; `hdma_channel_config` and `parallax_speed_config` read against `ParallaxResolveChannelSpeed`), E2 (`scene_thinkers` lists for the per-entry scene sets), E3 `docs/bank01-data-tables.md` lines 377-460.

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | One generic part note and one block note for 37 entries | FIXED (block note rewritten, `parallax_scroll_table` part note rewritten, 22 new per-entry part notes on the `binary_01xxxx` labels with band lists, buffers and scenes; `hdma_ramp_tables` block note and `parallax_speed_config` note rewritten) |
| Q3 | **F** | (a) "Header bytes specify BG mode, scroll region boundaries" is wrong (see File 1 Q3 a). (b) "speed" / "scroll speed parameters" for `parallax_speed_config` is wrong; it is a stride table, and only entries `00`-`02` are reachable. (c) Unused entries are `$09`, `$0C`, `$0D`, `$0F`-`$1A` (`$09` and `$19` share one `$FFFF` word), not "`$0D`-`$1A`" as in the docs. (d) Types `$04` and `$22` have data but no spawn | FIXED |
| Q6 | M | `parallax_speed_config` names a stride table as speeds; `binary_01xxxx` entry labels carry no type | PROPOSED (R-I035-2, R-I035-7) |
| Q7 | M | E1 + E2 (static) | DEFERRED-EVIDENCE (OQ-I035-1) |

### File 3: system/inventory/inventory_dma_setup.asm (Bank 00)

Evidence: E1 (`QueueDma` through `SetupHdmaChannel_Direct`, `hdma_channel_config[$12]`, `ResetHdmaState`, `RunThinkers_TypeB`), E2 (`scene_thinkers` list of scene `$FF`), E3 `docs/code/bank00/thinkers-system.md` line 158, `docs/cop/families/hdma_dma.md` line 172.

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Header only, no comments | FIXED (block note, 2 part notes, 2 comments) |
| Q2 | M | The header hid what the operands are | FIXED |
| Q3 | **F** | (a) **`#12` is the B-bus register index `$2112` (BG3VOFS), not a byte count.** (b) **It is a direct-mode HDMA table, not a "12-byte DMA table to VRAM"**: seven `{count, low, high}` entries, 21 bytes, lines 0-159 at V = 0, four 12-line bands at `$0B` / `$0F` / `$13` / `$17`, then 64 lines at `$20`; 272 lines in total so no terminator is needed. (c) **The thinker is type B** (filter word `$0804`), so it re-binds the channel every frame after `ResetHdmaState`; it is not "one-shot". (d) The docs describe seven DMA writes to VMAIN / TM / scroll registers / INIDISP; that does not match the table | FIXED |
| Q4 | M | The instruction operand `#12` was read as a size | FIXED (comment) |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | The block and table names ("dma_setup", "dma_channel_00BB97") do not say BG3 vertical-scroll HDMA | PROPOSED (R-I035-6) |
| Q7 | M | E1 + E2; the visible effect of the bands on the inventory screen was not checked | DEFERRED-EVIDENCE (OQ-I035-5) |

### File 4: actors/debug_stat_setter.asm (Bank 0B)

Evidence: E1 (the six instructions), E2 (searched `extracted/` for the label in spawn tables and scripts: none; sibling debug actors `debug_man` and `unused_debug_mode` read for comparison; searched for readers of `hpToHeal` / `$0B22`: none found), E3 `docs/wram-memory-map.md`, `docs/code/bank0B-late-bosses-system-cutscene-actors.md` line 474.

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Two comments, no context | FIXED (block note, 1 part note, 6 comments: 4 new, 2 updated) |
| Q2 | M | Nothing said that it is dead or that `playerHp` is not written | FIXED |
| Q3 | M | "Triggers HP bar flash" for the `hpToHeal` write was stated as fact; the only documentation is the WRAM map and no reader of `$0B22` exists in `extracted/` | FIXED (reworded as a heal request per the WRAM map) |
| Q4 | P | Mnemonics and operands are as annotated | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | P | `debug_stat_setter` / `DebugStatSetterInit` describe the code | NOFIX |
| Q7 | M | E1 + E2; the HUD reader of `hpToHeal` is a negative search | DEFERRED-EVIDENCE (OQ-I035-6) |

### Shared gate (I035)

`npm run merge -- plans/extracted-audit/edits/I035.json --dry-run` was clean (no warnings). Merged totals: 5 block notes (all updated), 39 part notes (37 new, 2 updated), 207 comments (195 new, 12 updated). A second dry run after `npm run extract:lt` reports 0 files to change. `npm run rebuild` succeeded with `artifacts/crc.json` at checksum 223006080 / crc 2083230829 / totalSize 3062204 (unchanged). No `.asm` file was edited by hand and `ingest` was not run.

Docs that repeat the old claims (not edited, `docs/` is outside the allowed folder): `docs/bank01-data-tables.md` lines 377-392 (`parallax_scroll_table` "BG mode, scroll region boundaries", "`$0D`-`$1A` are terminators") and 452-460 (`parallax_speed_config`), `docs/code/README.md` line 246, `docs/code/bank00/thinkers-system.md` line 158 onward (`inventory_dma_setup` "7 DMA writes targeting VMAIN / TM / INIDISP") and `docs/cop/families/hdma_dma.md` line 172 (`COP [QueueDma] ( @dma_setup, #26 )`; the real call is `@dma_channel_00BB97, #12`).

Suggested commit message: `audit(I035): document parallax_thinker band-table format, record types, scroll sources, stride and per-entry scene lists; correct parallax_scroll_table and parallax_speed_config notes; fix inventory_dma_setup (BG3VOFS HDMA, type B) and debug_stat_setter notes`

Please commit when you're ready.
