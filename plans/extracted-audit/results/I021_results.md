# I021 results

Files: `system/engine/hdma_dma_spc.asm` (517 lines lt), `system/engine/QuintetLzDecompress.asm` (313), `system/engine/thinker_execution.asm` (321). Cross-file corrections applied through the same spec: `cop_handlers_audio.asm`, `cop_handlers_palette.asm`.
Spec: [edits/I021.json](../edits/I021.json). New proposals: [renames/I021_renames.md](../renames/I021_renames.md). New questions: [questions/I021_questions.md](../questions/I021_questions.md).

Conventions (unchanged): verdicts **P/M/F/NA**; dispositions **FIXED / PROPOSED / DEFERRED-EVIDENCE / NOFIX**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 comment density, Q2 value, Q3 accuracy, Q4 mnemonic/address accuracy, Q5 mnemonic opportunity, Q6 part naming, Q7 evidence quality.

Answered from earlier iterations: **OQ-61** (I018) is answered, see the answer under hdma_dma_spc Q3(f).

### File 1: system/engine/hdma_dma_spc.asm (517 lines lt, Bank 03)

Evidence: E1 (every routine traced; ROM read-only via node: `palette_bundles` table at `$168000`, 128 bundle IDs, 800 sub-entries, the 87 with N ≥ 2 and the 14 with byte 4 = 2 counted; the first music stream parsed), E2 (callers of the palette COPs, `ResetHdmaState`, the frame routines in `system_core`, `scene_lifecycle` wave loops, `ApplyScrollWaveEffect`), E3 (`docs/audio/spc-disassembly.md` ProcessPortCommand: `$F0` CmdStop, `$F1` CmdFadeOut, `$F2` CmdF2, `$FF` → `sub_0f89`), E4 (DMA/HDMA registers, MVN).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Block and part notes existed, but the palette routines, the HDMA tail and the SPC handshake had almost no per-line comments | FIXED (block note rewritten, 10 part notes, 44 comments: 29 new, 15 updated) |
| Q2 | M | The palette-bundle half was unexplained (the reader could not tell what a sub-entry byte meant) | FIXED |
| Q3 | **F** | (a) **Palette bundle format**: byte 0 is the frame count N of an animation strip (not a "spriteset index"), bytes 1-2 the first frame's source in bank `$96` (not "chatPtr graphics data"), byte 3 the first CGRAM color index (destination `$7F0A00` + 2 × index, the palette staging buffer, not a "metasprite table"), byte 4 the frame size − 1 (not "graphics bank/type"), byte 5 the extra wait ticks stored in DP `$08`. (b) `DecompressGfxToVram` decompresses nothing and touches no VRAM: it MVN-copies one frame to the palette staging buffer through the RAM stub at `$0402` (`$0404 = $7F`, `$0405 = $96`) and advances `chatPtr` by one frame, so N consecutive calls play the N frames of one strip onto the same destination; the old "iterative decompression of multi-part graphics sets" is wrong. Check: for the bundle `palette-bundle < #08, &word_1682B2, #CE, #03, #03 >` the next bundle starts at `$82B2 + 8 × 4 = $82D2`; 61 of the 87 sub-entries with N ≥ 2 end exactly at a known sub-entry or data address (the others were not checkable that way). The 14 sub-entries with byte 4 = 2 are the backdrop color triplets (`$0A00 + $0200 = $0C00 = backdropColors`). (c) `ResetHdmaState`: `$6C` is a one-shot lock that covers exactly one call; the wave transition in `scene_lifecycle` resets explicitly, arms `$FF` and `ApplyScrollWaveEffect` calls `UpdateFrameDialogue`, whose reset is skipped and clears the lock (E1). (d) `SetupHdmaChannel_Indirect/Direct` entry description was wrong: A = bank (low) | B-bus register number (high), Y = table address; nothing on the caller's stack. The register number indexes `hdma_channel_config`. The shared tail has no CLC (`ASL $0068` supplies the carry), so at most 7 channels. (e) `DmaPlayerTilesToVram`: the second/fourth passes continue from the 9th pointer of the same list; in the NMI it replaces `DmaAdhocVramBlock`, it does not run in addition. (f) **SPC commands**: `$F1` = CmdFadeOut (**answers OQ-61**: the "fade" in `FadeThenStartMusic` is real and runs inside the SPC engine), `$F0` = CmdStop (the old "transfer-start"), `$FF` = jump into the engine's resident IPL clone `sub_0f89` ("ready-for-data"). `chatPtr` holds the music ID, not a "music data pointer". `COP WaitByte #01` is a one-frame delay, not an SPC acknowledgment. (g) `LoadMusicFromTransitionState`: index is (ID − 1) × 3, and `EnableNmiOnly` turns the NMI OFF (the note said it re-enabled "NMI-only mode"). (h) `DmaAdhocVramBlock` does not program channel 0: it relies on the VMAIN/DMAP0/BBAD0 values `NmiHandler` just wrote | FIXED |
| Q4 | M | `$0402/$0404/$0405` (MVN stub and its two bank bytes), `$00AC/$00AE/$00B0/$00B2` (VRAM DMA source/bank/destination/size DP bytes used as absolute operands) and `$7F0008` are bare addresses in this file | PROPOSED (R-I021-3) |
| Q5 | M | Same as Q4: stub and DMA-parameter mnemonics would make the palette and tile-streaming code readable | PROPOSED (R-I021-3) |
| Q6 | M | `DecompressGfxToVram` and `SpcCheckMusicReady` names mislead | PROPOSED (R-I021-1, R-I021-5) |
| Q7 | M | E1 + E2 + ROM data checks; the audibility of the fade and the `$01` command path are not settled | DEFERRED-EVIDENCE (OQ-I021-2) |

### File 2: system/engine/QuintetLzDecompress.asm (313 lines lt, Bank 02)

Evidence: E1 (every path of the three routines traced, including the shift-count tricks), E2 (callers: Decompress COP, `scene_script`; `ClearActorRenderList` and `sprite_composition` bucket array at `$0200-$03FE`), E3 (`gaia-core` QuintetLZ reference).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | P | Good block note; comments on the cascades were partly wrong | FIXED (block note, 3 part notes, 12 comments) |
| Q2 | M | The dictionary clash and the register contract were undocumented | FIXED |
| Q3 | **F** | (a) The 256-byte dictionary at `$7E:0200-02FF` is the first half of the depth-sort bucket array (`deathFlag` = `$0200`): every decompression leaves garbage there and callers must run `ClearActorRenderList` afterwards. (b) "All registers preserved" is false: X, Y, P and DBR are preserved, A is not. (c) The source pointer is advanced with 16-bit increments and never carries into the bank byte `$40`, so a compressed stream must not cross a bank end. (d) A size of 0 runs 65,536 bytes (`scene_script` skips size 0, the Decompress COP does not test it); the output offset is in bank `$7E` only. (e) `LzReadBitField` mask `$01` means 1 bit is left (7 consumed) and enters the ASL cascade at the top; the old comment said "no bits remain". (f) `LzReadBackRef`: the high path means mask ≥ `$10` (at least 5 bits left, the nibble fits), the mask doubles as the LSR shift counter (shift until its set bit leaves through carry), and the low-path comments at `$40`/`$10` had the "bits left in this byte" counts swapped (mask `$04` = 3 + 1, mask `$01` = 1 + 3). (g) The bit-stream paragraph said the mask is "the current" bit; it is the NEXT unread bit | FIXED |
| Q4 | NA | Only DP operands and the fixed `$0200` page | NOFIX |
| Q5 | NA | DP scratch bytes are never mnemonic candidates | NOFIX |
| Q6 | M | `LzReadBackRef` reads the 4-bit length nibble, not a back-reference | PROPOSED (R-I021-2) |
| Q7 | P | E1 complete; both cascades verified by hand for every mask value | NOFIX |

### File 3: system/engine/thinker_execution.asm (321 lines lt, Bank 03)

Evidence: E1 (four runners, spawn and init), E2 (all 59 `thinker-def` operand pairs in `extracted/` counted: 32 × `#04, #08` = `$0804`, 27 × `#00, #08` = `$0800`; every call site of the four runners in `system_core` and `scene_lifecycle`; the runtime `animScratch2` writes and the `SpawnThinker` flag inheritance in `cop_handlers_thinker`), E3 (`docs/code/bank03/actor-thinker-runtime.md:282` and `docs/code/bank00/system-core.md` thinker tables, now known to be off).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Runner part notes were generic; the dispatch had no comments | FIXED (block note, 4 part notes, 6 comments) |
| Q2 | M | The wait-counter and call-site facts were missing | FIXED |
| Q3 | **F** | (a) **Bit 11 is set in all 59 scene thinker-defs**, so for scene thinkers `RunThinkers_TypeC` selects exactly TypeA's set and TypeD exactly TypeB's. Runtime-spawned thinkers (`SpawnThinker`, 77 sites) inherit the spawner's `animScratch2` and three scripts store their own value (`future_vision_cutscene` `$0804`, `sE8_dark_gaia` `$0004`, `dc2F_adrift` ORs in `$0800`), so bit 11 means "keeps running in the lighter frame routines" (dialogue, render, music upload) rather than "cutscene": the old "cutscene overlay / deferred cutscene" wording in the notes and in `docs/code/bank03/actor-thinker-runtime.md` is not borne out. (b) TypeA/B run in the main loop (A after the VBlank sync, B after `ResetHdmaState`) and in the scene-start sequence; TypeC/D run in `UpdateFrameDialogue`, `UpdateFrameRender` and `UpdateFrameFull` (D after `ResetHdmaState`, C after the sync). (c) `$08` is the wait counter (`DEC $08` / `BPL`: a stored n skips n passes), not just a "frame delay timer". (d) The filter word is the first word of the thinker code (the first two operands of the `thinker-def`) | FIXED |
| Q4 | NA | Only DP and fixed list roots | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | TypeA-D say nothing about their role | PROPOSED (R-I021-4) |
| Q7 | M | E1 + E2; which runtime-spawned thinkers lack bit 11 (and so pause in dialogue) was not enumerated | DEFERRED-EVIDENCE (OQ-I021-4) |

### Cross-file corrections (same spec)

- `cop_handlers_audio.asm`: block note and `FadeThenStartMusic` part note: `$F1` is the SPC engine's CmdFadeOut, performed inside the SPC (OQ-61 answered); audibility is OQ-I021-2.
- `cop_handlers_palette.asm`: block note and `PaletteStep` part note: a sub-entry is a strip of N frames, `chatPtr` is the source pointer of the next frame and `animScratch` holds the wait value (it is not a "data pointer copied to `$08`"); 9 comments (3 new, 6 updated) fix "hold counter" and the `$08` wording.

### Shared gate (I021)

`npm run merge -- edits/I021.json --dry-run`: 5 files, 9 notes files would change, warnings none after rewording one comment (the text "RTS" matched a transform pattern). Applied: 5 block notes, 19 part notes, 71 comments (new and updated). Mid-iteration the thinker bit-11 wording was corrected in the same spec (runtime-spawned thinkers); the replay of `edits/I021.json` changed only `thinker_execution` (idempotent otherwise). `npm run extract:lt` OK and the new notes render in `extracted/` (spot-checked `hdma_dma_spc`, `QuintetLzDecompress`, `cop_handlers_palette`). `npm run rebuild` (after I022 as well): success, `artifacts/crc.json` = checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged). No mnemonic added (spec-only iteration). No `ingest` run.

Suggested commit message: `audit(I021): correct palette-bundle strip format, HDMA lock/channel notes and SPC port commands (answers OQ-61), QuintetLZ dictionary/bit-cascade notes and thinker filter semantics`

Please commit when you're ready.
