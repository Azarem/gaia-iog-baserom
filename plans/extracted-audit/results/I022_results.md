# I022 results

Files: `system/engine/cop_handlers_sprite.asm` (Bank 00), `system/engine/spc_transfer.asm` (Bank 02), `system/engine/vblank_joypad.asm` (Bank 02).
Spec: [edits/I022.json](../edits/I022.json). New proposals: [renames/I022_renames.md](../renames/I022_renames.md). New questions: [questions/I022_questions.md](../questions/I022_questions.md).

Conventions (unchanged): verdicts **P/M/F/NA**; dispositions **FIXED / PROPOSED / DEFERRED-EVIDENCE / NOFIX**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 comment density, Q2 value, Q3 accuracy, Q4 mnemonic/address accuracy, Q5 mnemonic opportunity, Q6 part naming, Q7 evidence quality.

Answered from earlier iterations: **OQ-64** (I019) is answered, see the answer under vblank_joypad Q3(f).

### File 1: system/engine/cop_handlers_sprite.asm (Bank 00)

Evidence: E1 (all 16 handlers and `ProcessAnimFlag` traced; `UpdateActorAnimation`, `AnimFrameLookup` and the `movement_delta_table` consumers in `sprite_composition`, `actor_pool` and `cop_handlers_force_move`), E2 (script-site counts per COP over `extracted/`, the four tile-streaming effect actors, the `$12` bit-1 writers `awB0_zombie` and `sE8_dark_gaia`, `db-us/transforms.json` for `cop_handlers_sprite`), E3 (`docs/cop/families/sprite_anim.md`, `sprite_state.md`, now known to be off), E4 (VRAM DMA through the NMI).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Per-handler descriptions existed, but the model that ties them together (Stage chooses, Anim plays) and the movement operands were not explained | FIXED (block note rewritten, 17 part notes, 22 comments) |
| Q2 | M | The reader could not tell which ops yield, which continue, and which touch the entry address | FIXED |
| Q3 | **F** | (a) **Movement operands are indices, not durations or distances**: `StageSpriteMove*`/`StageSpriteLoopMove*` store the byte in `moveXAlt`/`moveYAlt` and put the head of the delta chain from `movement_delta_table` (returned by `AnimFrameLookup`) in `$2C`/`$2E`, exactly as `StageMoveX/Y/XY` in `cop_handlers_force_move`. (b) **Frame list model**: 4-byte records (hold word → `$08`, sprite pointer word) addressed by `$2A`, one list per animation index in the spriteset table; a negative hold word ends the list; a hold of n shows the frame for n + 1 ticks. `UpdateActorAnimation` returns carry SET at the end of a list and does not stage anything. (c) **Stage* ops only choose the animation** (`ProcessAnimFlag` stores `$28`, clears `$2A`); `AnimOnce`/`AnimLoop`/`AnimOneFrame`/`WaitForAnimFrame` play it, yielding with PLA PLA RTL. The Stage* ops save the entry point; the Anim* ops do not, so the same op repeats until the list ends. The two `LDA $0C / STA $02` lines before each entry store are inserted by `transforms.json` (no address tag): the bank follows the op as well. (d) `SetMetasprite` sets the actor's spriteset table (frame lists per animation index) and its bank, not "a metasprite pointer". (e) `ResetSpriteState` resets no composition state: it sets `$28`, `$2A = 0`, `$24` (VRAM word address) and the entry point for the tile-streaming effect actors; `AdvanceSpriteAnim` streams one frame (32 or 128 bytes from `animScratch` + 32 × byte at +`$12`) per call and waits while `$B2` is nonzero. (f) `ProcessAnimFlag`: `$FF` keeps the index and the flip, bit 7 selects the mirrored variant (flip `$4000` in `$0E`), and **bit 1 of `$12` is a persistent mirror lock**, not a facing flag (old docs). (g) `AnimLoop` restarts the list in the same run (no idle tick) and a repeat count of 0 gives 65,536 passes. (h) `WaitForAnimFrame` compares `$2A` after the increment: it resumes when frame (operand − 1) has been staged; the operand is consumed on every path. (i) `StageSprAndHitbox` poses the first frame at once (no yield) and clears `$2A` again | FIXED |
| Q4 | M | `$B0/$AC/$AE/$B2` (VRAM DMA destination/source/bank/size, ExecuteVramDma inputs) and `$24/$28/$2A/$2C/$2E` are bare DP operands in the tile-streaming handlers | PROPOSED (R-I021-3 for the DMA bytes; the actor DP fields are shared by 100+ files and stay unnamed) |
| Q5 | M | `moveXAlt`/`moveYAlt` store indices, but the names read as alternate positions | PROPOSED (R-I022-3) |
| Q6 | M | `ResetSpriteState` resets nothing of the sprite system; `SetMetasprite` sets a spriteset table | PROPOSED (R-I022-2) |
| Q7 | M | E1 + E2; whether `$12` bit 1 is ever cleared deliberately and which writers set it was only sampled | DEFERRED-EVIDENCE (OQ-I022-1) |

### File 2: system/engine/spc_transfer.asm (Bank 02)

Evidence: E1 (both transfer routines and the shared handshake traced), E2 (callers: `LoadMusicFromTransitionState`, `SpcMusicLoadCmd`; the first music stream and the sample library at `$C5:0000` = file `0x50000` parsed read-only via node: 61 chunks, indices 0-60, first track = 6 chunks with indices 14-19), E3 (`docs/audio/spc-disassembly.md`: resident loader `sub_0f89`, ports `$BBAA`; `docs/code/bank02/spc-transfer.md`), E4 (APUIO0-3).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A short block note and bare part notes; the structure of a music upload (two sessions) was undocumented | FIXED (block note rewritten, 4 part notes, 16 comments) |
| Q2 | M | The protocol steps (kick, counter, V flag, the +4 step) were not explained | FIXED |
| Q3 | **F** | (a) **Two sessions on one stream**: session 1 = the song records (ARAM `$1254, $1300, $5532, $1038, $0FFC, $0FFE, $0FE0` in the first stream) to a size-0 terminator whose destination word is reused as the ARAM address of the first sample chunk; then a count byte and chunk-index bytes (bit 7 = empty slot); port command `$FF` re-enters the engine's resident loader (a fresh `$BBAA`); session 2 sends the chunks from the sample library, walking it from the start for each index (32 KB pages, `$4A` wraps into the next bank even inside a chunk). (b) The counter arithmetic: the carry from the equal compare makes `ADC #$03` add 4 and a result of 0 is stepped over, so the next kick is non-zero. (c) The V flag means "more records", produced by `ROL` of the `CPX #1` carry into port 1 and `ADC #$7F`. (d) **NMI state**: `EnableNmiOnly` is `NMITIMEN = $01` (NMI OFF) around each header and kick; after the kick echo the NMI is turned back on only if `worldReadyFlag = $0F`, so during gameplay the byte loop runs with the NMI enabled (and `UpdateFrameFull` runs inside it), while at boot it stays off. (e) `SpcLoadBuiltinEngine`: one record of 3,018 bytes to ARAM `$0400` plus the terminator whose entry `$0400` starts the engine. (f) `SpcIplHandshake` is shared by the boot ROM and the engine's clone, and returns with Y just past the terminator | FIXED |
| Q4 | NA | Only DP operands and the APU ports | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | `code_029153` and the loop labels `code_0290C9`, `loc_0290F1`, `loc_02911D`, `loc_029160`, `loc_0291D5` are auto names inside a documented structure | PROPOSED (R-I022-4) |
| Q7 | M | E1 + E2 + ROM parse; the engine behavior after the `$FF` command was read from the disassembly, not run | DEFERRED-EVIDENCE (OQ-I022-2, OQ-I022-3) |

### File 3: system/engine/vblank_joypad.asm (Bank 02)

Evidence: E1 (both entry points and the pipeline traced; `EnableNmiOnly`/`EnableNmiAndJoypad`/`WaitFrames`), E2 (callers: 19 `JSL EnableNmiOnly` sites in 8 files, `UpdateFrameFull` for `VBlankPartial`, the `joypadInject` writers `sg4C_auto_advance` and `sc06_bill` and the clear in `scene_lifecycle`, the NMI handler's JOY1L store), E3 (`docs/code/bank00/system-core.md` tables, now known to be off), E4 (RDNMI, NMITIMEN, JOY1L).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A large block note existed, but the interaction with the NMI, the inject path and the repeat were stated wrongly or not at all | FIXED (block note rewritten, 4 part notes, 12 comments) |
| Q2 | M | The pipeline order and the stored values were unclear | FIXED |
| Q3 | **F** | (a) **`joypadRaw` is overwritten with the REMAPPED value**; the hardware value comes from the NMI handler (step 11, JOY1L), so the routine only sees fresh data when the NMI ran since the previous call; with the NMI off the remap would be applied twice (not idempotent for swapped or software-only mappings). (b) `joypadInject` is one-shot, goes straight to `joypadCurrent` and bypasses remap, consumption mask, repeat and `joypadMaskStd`; writers `sc06_bill` (rewrites it every frame) and `sg4C_auto_advance` (once); `scene_lifecycle` clears it. (c) Auto-repeat fires in the same call, 12 calls after the counter started, and only for buttons the game code keeps consuming; `joypadMaskInv` is the repeat mask (`$0F00` set by the dialog handler and the diary menu), not an "inverse mask". (d) **X is clobbered** in Mode 7 scenes (`LDX $BE`/`STX`); A and P are preserved. (e) The third RDNMI read after the loop is redundant. (f) **`EnableNmiOnly` turns the NMI OFF** (`NMITIMEN = $01`): the old "NMI-only mode" reading is inverted. This **answers OQ-64**: `RadarScreenSetup` writes `adhocVramDmaDest` before `adhocVramDmaSize`, but the main loop enters the logic with the NMI off and both wait loops end in `EnableNmiOnly`, so the NMI cannot fire between the two stores in that context (the residual risk is a caller that runs with the NMI on, see OQ-I022-4). (g) `VBlankPartial` is only called by `UpdateFrameFull`, which the NMI handler runs during a music upload; it skips the wait because the NMI just stored a fresh `joypadRaw`. (h) `WaitFrames` with A = 0 waits 256 frames (8-bit A) | FIXED |
| Q4 | NA | Only DP operands and PPU/CPU registers with names | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | **F** | `EnableNmiOnly` says the opposite of what it does (NMI off, auto-read on). 19 JSL sites in 8 files; `docs/code/bank00/system-core.md` and others describe it as "scene transitions / `$02`" | PROPOSED (R-I022-1, R-I022-5) |
| Q7 | M | E1 + E2; the Mode 7 X clobber and the double-remap with the NMI off are static conclusions only | DEFERRED-EVIDENCE (OQ-I022-4) |

### Shared gate (I022)

`npm run merge -- edits/I022.json` applied without warnings; the replay (`--dry-run`) now reports every entry unchanged and 0 notes files would change. Applied: 3 block notes, 25 part notes, 50 comments (new and updated). `npm run extract:lt` OK and the new notes render in `extracted/`. `npm run rebuild` (after I021 and I022 together): success, `artifacts/crc.json` = checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged). No mnemonic added (spec-only iteration). No `ingest` run.

Suggested commit message: `audit(I022): document sprite frame-list/movement-index model, SPC two-session upload and NMI state, joypad inject/repeat and EnableNmiOnly NMI-off semantics (answers OQ-64)`

Please commit when you're ready.
