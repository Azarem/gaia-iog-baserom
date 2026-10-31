# Mesen2 D series: SPC port, music transfer and fade findings (D1 to D3)

Runtime and static investigation of the 65816-to-SPC700 path of the US ROM: the sound-queue drain in the NMI, the music ids and who stores them, the `FadeThenStartMusic` fade, the port commands `$F0` / `$F1` / `$F2` / `$FF`, the resident loader, and the layout of the song streams that `SpcBlockTransfer` sends. Compiled 2026-10-31 from `plans/extracted-audit/mesen2-results/D1_20261031.md`, `D2_20261031.md`, `D3_20261031.md` and the apply log `MS03_apply.md`.

ROM: O (vanilla, SHA-1 `38de0c84dd2bc3bdfc0a3d7ab0220c79b70887c3`) for D1, D3 and runs A and D of D2. D2 runs B and C used the shipped build R-b2 (`rebuilt/variants/plain.smc`, SHA-1 `2e4a88a3de6dd4bdefc23c0dd626b953c18fe808`). Server: Mesen2 MCP 0.6.0. D3 is a static parse of the ROM file (no emulator session). Only the US ROM was run; the JP ROM was not.

Sections: 1 Result in one page, 2 What was run, 3 Findings, 4 Shipped notes corrected, 5 Rules for patch authors, 6 Where the findings live in the docs, 7 Open questions, 8 Apply log.

---

## 1. Result in one page

| Id | Question | Verdict |
|----|----------|---------|
| OQ-I021-2 | What does the `$01` after the `$F1` echo do, is the `FadeThenStartMusic` fade audible, and how long after the `$01` does `$F0` arrive? | **The `$01` does nothing** (the SPC's last-command byte `$08` already holds `$01`, so the edge compare skips it). **The fade is audible**: master volume `$53` to 0 in steps of 1 about every 4 frames, about 335 frames; `$F1` dispatched at f478, fade end at f819 (341 frames; the shipped build 426 to 767, also 341). **`$F0` does not follow the `$01` by a frame or two**: the SPC's fade-end `CmdStop` answers 0 on port 0, and the thinker sends `$F0` only after reading that zero (and only when it runs: a dialogue wait delayed it from f819 to f1018). VERIFIED-RUNTIME; the old sentence is CONTRADICTED |
| OQ-I021-3 | What are `$F0` and `$F2` on the SPC side? | **`$F0` = `CmdStop`** (master and echo volume 0, `EON` 0, `FLG` `$20`), not a "ready signal". **`$F2` = `CmdF2`**: `$0E` = `$FF`, the main loop writes KOFF = `$FF`, all voices fall silent within 4 frames; master volume, echo and `FLG` stay unchanged. It is re-dispatched on every tick while the port holds it. VERIFIED-RUNTIME. The US-vs-JP doc's "`$F2` is a no-op in the US engine" is CONTRADICTED (the table-driven read of `$0E` was missed) |
| OQ-I022-3 | What does the resident loader (`$FF`) do to the DSP? | **Nothing**: 0 DSP register writes with `spc.pc` in `$0F89-$0FD0` in four transfers (about 5,000 other DSP writes per run were seen). The DSP state during the upload comes from `CmdStop` / `$F2` before it. 4 of 4 transfers completed. VERIFIED-RUNTIME. Whether `$F0`/`$FF` clicks on a track that still sounds: INCONCLUSIVE |
| OQ-I022-2 | Where does the first sample chunk go? | **To the terminator word**, which is the first free ARAM address after the song data. First stream (`bgm_lively_city`): `$5532 + $0B34 = $6066`, bytes `66 60` at ROM 1560563. True for all 30 shipped streams (directory start words and the `$0FFE` end word equal the computed chunk destinations). VERIFIED-STATIC. `spc-engine.md` called the terminator word the "sample end address": CONTRADICTED |
| OQ-10 | Which music table entry does id n load, and what about ids `0`, `$0D`, `$17`? | **Entry n-1.** Id 0 only occurs in the scene `$FA` record (`bgm_restart`, loaded by pointer). No call site selects `$0D` or `$17` (71 `StartMusic`/`FadeThenStartMusic` operands, 22 `MusicAndText #17` = id `$18`). VERIFIED-RUNTIME / VERIFIED-STATIC |
| OQ-29, OQ-I065-3 | What is `$06F2`? | **The BGM id stored by `SpcMusicLoadCmd`** (8 of 8 stores equal operand 1 of the `music` record). Two other writers (`pyCD_jackal` `$0F`, Memory Melody item `$0E`); `StartMusic` / `FadeThenStartMusic` never update it. "The scene's current music index" is CONTRADICTED. The chest fanfare is id `$18` (`bgm_important_item`); the restore afterwards reloads id `$07`. VERIFIED-RUNTIME |
| OQ-SAN2-1 | How often does `CameraShakeActor` play `#15`? | **On every tick**, 61 ticks (`$26` = `$3C`, no `SetEntryHere`): 61 queue writes, 31 NMI writes to `$2143`. VERIFIED-RUNTIME. "Once / about 60 frames" CONTRADICTED |
| (side) | Where does the SFX queue go? | **`$06F8` to `$2142`, `$06F9` to `$2143`** as one 16-bit word on even `$36` frames, `STZ` clears both bytes, odd frames write 0. `docs/cop/families/audio.md` said `$2140`/`$2141`: CONTRADICTED. VERIFIED-RUNTIME |
| OQ-I046-1 (a) | Hit sound | `ApplyPlayerHitstun` plays `#07` on both exits, no read of `characterForm`. VERIFIED-STATIC (no hit landed at runtime: INCONCLUSIVE) |
| OQ-I056-5, OQ-48 | Gaia rest music, `MusicAndText` jingle | The Gaia rest state is never left in 1,200 frames (VERIFIED-RUNTIME). In that run the `$F1` echo never arrived and track `$0E` was never uploaded (INCONCLUSIVE, new question 1). No `MusicAndText` actor ran (INCONCLUSIVE) |

Counts: D1 7 VERIFIED-RUNTIME, 2 VERIFIED-STATIC, 2 shipped statements CONTRADICTED (+ the audio doc), 4 INCONCLUSIVE; D2 4 VERIFIED-RUNTIME, 2 CONTRADICTED, 1 INCONCLUSIVE; D3 1 VERIFIED-STATIC, 1 doc CONTRADICTED. The campaign changed **0 ROM bytes**.

What changed in what we believe:

1. **The fade-out is audible and slow.** `FadeThenStartMusic` costs about 340 frames of audible fade before the next track is even requested; a dialogue wait can add more because the thinker does not run.
2. **`$F0` is the SPC's stop command and the zero on port 0 is its answer**, not a ready signal and not an acknowledgement of the `$01`.
3. **`$F2` silences by key-off, in the US engine too.** The old "no-op" conclusion came from looking only for direct reads of `$0E`; the main-loop DSP refresh reads it through `DspRegSourceTable`.
4. **`$06F2` is not "the music playing now".** It is the id the scene's record stored; scripted music changes leave it alone.
5. **One sound word per two frames.** Both SFX channels share a word that is sent and cleared on even frames; a second queue write inside the same window overwrites the first.
6. **The chunk placement is fully determined by the stream.** The terminator word is the end of the song data; chunk destinations are running sums of the chunk sizes.

---

## 2. What was run

| Step | Ids | Method | Volume |
|------|-----|--------|--------|
| D1 | OQ-10, OQ-29, OQ-48, OQ-I046-1, OQ-I056-5, OQ-I065-3, OQ-SAN2-1 | Write callbacks on `$2140-$2143` (all 128 bank aliases), the sound queue `$06F8/$06F9`, `$06F2`, `$06FA/$06FB`, exec marks on the music routines and `SpcBlockTransfer` (source and id); runs: chest `$1D` (fanfare), 7 scene loads, camera shake (`LedgeJumpDropLand`), Gaia rest (`$E6`), scene `$19` statue, scripted-hit placements; plus a static census of every `$06F2` writer and every music operand | ~12,000 frames, 8 scene loads |
| D2 | OQ-I021-2, OQ-I021-3, OQ-I022-3 | SPC-side trace: exec callbacks on the engine routines, read/write callbacks on the SPC's `$F4`, a `$F3` callback decoding the DSP register written, a count of DSP writes made while `spc.pc` is in the loader, one row per 4 frames with the DSP master volume; runs A/D on the vanilla loader, B/C on the shipped build | 4 runs of 700 frames, run A repeated 5 times |
| D3 | OQ-I022-2 | Read-only parser that reproduces `SpcBlockTransfer` on all 30 song streams (records, terminator word, chunk indices, library walk) plus `od` dumps of the first stream | no emulator |

---

## 3. Findings

### 3.1 Sound queue and NMI drain (D1)

- `NmiHandler` with `musicTransitionState` = 0: on even `$36` frames it loads the word `$06F8/$06F9`, clears both bytes (`STZ`), and stores the word 16-bit to `APUIO2`: low byte (`sfxQueueCh1`) on `$2142`, high byte (`sfxQueueCh2`) on `$2143`. Odd frames write 0 to both. `musicTransitionState` = `$FFFF` skips the write; a positive value runs `UpdateFrameFull` instead.
- Measured with the camera shake: 61 queue writes (`#15` into `$06F9`, frames 387 to 447), 31 NMI writes of `$15` to `$2143` on the even frames, 0 on odd frames, `sfxQ w0` = 200 in 200 frames. `PlaySoundCh1` reaches `$2142`, `PlaySoundCh2` reaches `$2143`.
- `CameraShakeActor`: `COP [PlaySoundCh2] ( #15 )`, `JSR CameraShakeFrame`, `DEC $26`, `BMI`, `RTL`; no `SetEntryHere`, so the sound is queued on every tick (61 ticks for `$26` = `$3C`). `LedgeJumpDropLand` was entered directly; the natural fall was not run.
- `ApplyPlayerHitstun` (50071): `PlaySoundCh2 #07` at `loc_00C40A`, reached by both exits, no read of `characterForm` (`combat_collision` branches to `#08` for a nonzero form). Static only.

### 3.2 Music ids and `$06F2` (D1)

- `StartMusic` / `FadeThenStartMusic` store the operand in `chatPtr`, then `SpcTransferMusicData` (`$F0`, yield, `$FF`) writes the id to `$06FA`; `LoadMusicFromTransitionState` reads `music_pointer_array-3 + 3*id` = entry **id - 1**. `MusicAndText` and `ChestOpeningActor` pass `$26 + 1`.
- Chest scene `$1D`: first upload id `$18` = offset 1923068 `bgm_important_item` (43 frames of bulk writes), play `$01` at f1064; the SPC's `$FF` reply came at f1639 (575 frames after the play command); the restore uploaded id `$07` = offset 1337103 `bgm_awakening_the_wind` (the scene record's id). `$06F2` = `$07` throughout.
- Scene loads (`SpcMusicLoadCmd`, eight records): the store at pc 166771 equals operand 1 of the executed `music` record (`$03 $04 $07 $16 $00 $12 $13 $17`); then `$F2` +26 frames, `$F0` +32, `$FF` +3 to +4, `SpcBlockTransfer` +2, final `$01` or `$00` +25 to +50 (transfer length). The scene `$FA` record with id `#00` uploads `bgm_restart` and writes `$00`.
- Writers of `$06F2` in `extracted/`: `scene_script.asm:1298`, `pyCD_jackal.asm:118` (`#$000F`), `item_use_system.asm:921` (`#$000E`). Nothing else.
- Call-site census: `StartMusic` / `FadeThenStartMusic` 71 sites (all immediate; operands `01 02 03 04 06 0E 0F 10 11 13 14 15 16 18 19 1A 1B 1C 1E`), `MusicAndText` 22 (all `#17`). No `$00`, `$0D`, `$17`. The only `music` record with id `$17` is scene `$F9` (pointer `@bgm_1D4F6B`). Scene `$F9` stopped in the `$F0` poll of that second record in the one run (hang; not a result about id `$17`).

### 3.3 `FadeThenStartMusic`, `$F0`, `$F1`, `$F2`, the loader (D2)

Run A (vanilla, scene `$58`, `FadeThenStartMusic #02`):

```
f477 CPU wr $2140 = F1        f478 SPC CmdFadeOut ($30=FF $31=FD), echoes F1 on its port 0
f478 CPU wr $2140 = 01        SPC reads 01 at f480: no Dispatch ($08 already 01)
f481..f814 MVOL $53 -> 0, steps of 1 about every 4 frames (EVOL stays $19)
f819 SPC fade end -> CmdStop (EON 0, FLG $20, MVOL/EVOL 0), SPC writes 00 to port 0, KOFF = FF
f776..f1017 main loop inside a dialogue wait: the thinker does not run
f1018 CPU reads 00, sends F0     f1020 CmdStop dispatch, CPU sends FF, SpcBlockTransfer, loader
f1066 CPU sends 01               f1069 SPC ProcessPortCommand / Path01 / SongInit
```

- Shipped build (run B): `$F1` f424, CmdFadeOut f426, zero from `CmdStop` at f767, thinker reads 0 at f958, `bgm_halt` sends `$F0` at f959, `$FF` f962, `SpcBlockTransfer` f964, `$01` f1008. `SpcTransferMusicData` writes no port there.
- Run C (shipped build, scene change `$01` to `$0A`): `$F2` written at f392 by `count_check` (fade brightness 6), CmdF2 at f394 (`$0E` 00 to `$FF`, KOFF = `$FF`), re-dispatched on f396, f397, f398, f400 while the port holds it; ENVX sum 460 (4 voices) at f393, 0 at f397; MVOL/EVOL stay `$53`/`$19` until `$F0` (f399 sent, CmdStop f401, EON 0, FLG `$20`, port 0 = 0). Run D (vanilla): `$F2` f424, CmdF2 f426, `$F2` re-dispatched f424 to f456 (32 frames held), `$F0` f456, CmdStop f458, `$FF` f460.
- Dispatch rule: commands `>= $F0` jump to the dispatch without updating `$08`; other commands go through the edge compare against `$08`. This is why `$01` after the `$F1` echo is ignored while `$08` = `$01`, and why `$F2` repeats every tick.
- Loader: `spc Loader` fired twice per run; the DSP callback (about 5,000 writes per run) never fired for a write made with `spc.pc` in `$0F89-$0FD0`.
- Build differences (without MSU hardware): the shipped build keeps the `$F1` / echo / `$01` / wait-0 handshake, drops the `$F2` from `SpcMusicLoadCmd` (the scene-change token sends it from `count_check` at brightness 6, only when the BGM differs and neither id is `$FF`), and `bgm_halt` replaces the `$F0` poll (`WaitFrames(1)`, `$F0`, `WaitFrames(3)`, `$FF`, `WaitFrames(2)`, transfer, `WaitFrames(3)`, `$01`/`$00`).

### 3.4 Song stream layout (D3)

- `SpcBlockTransfer` (ROM 168091): session 1 sends the records up to the size-0 terminator; `Y` is backed up by 2 so the terminator's destination word becomes `$2E`; `STZ $2C`; then count `$28` and the chunk indices; port `$FF` re-enters the loader; session 2 sends the chunks from the library at `$C5:0000` (61 chunks, 162,524 bytes, 32 KB pages), `$2E += $2C` before each non-empty chunk.
- All 30 streams: terminator word = end of the highest song record (sequence block at `$5532`, or `$1400` for extended songs), equal to the first sample directory start word; the directory start words equal the computed chunk destinations; the `$0FFE` record equals the end of the last chunk (below `$10000`, largest `$BE54`, `bgm_great_pyramid`); `$0FFC` equals the sequence block's address. `bgm_waterfall` has a count of 1 and one empty slot; `bgm_restart` has no `$0FFC`/`$0FFE` record.
- First stream: records `24 00 54 12` (36 bytes to `$1254`), `18 00 00 13`, `34 0b 32 55` (2,868 bytes to `$5532`), directory `18 00 38 10`, `$0FFC` = `$5532`, `$0FFE` = `$AD1C`, slot table; tail at 1560556: `0f 10 11 12 13 | 00 00 | 66 60 | 06 | 0e 0f 10 11 12 13`. First chunk: index `$0E`, size word at 342783 (`ea 12` = 4,842), data from 342785, destination `$6066`-`$7350`. Chunks: `$6066, $7350, $8D0C, $92B5, $9573, $9951`.
- Library: the 30 streams name 60 distinct chunks (`$00-$3B`); chunk `$3C` (1,028 bytes, not a multiple of 9) is named by none. `SpcBlockTransfer` does not check any of these relations.

---

## 4. Shipped notes corrected

The apply pass (`MS03.json`, 6 extracted files) replaced these statements; all of them were wrong or untraced:

| File | Old statement | Now |
|------|---------------|-----|
| `player_character.asm` (block note, comment 182097) | the shake sound plays once, shake lasts about 60 frames | sound `#15` queued on every tick, 61 ticks |
| `music_actors.asm` (block note, `MusicJingleActor` part note, comment 172096) | `$06F2` is the scene's current music index | the BGM id stored by the scene's music record; `StartMusic` does not update it; two other writers |
| `system_core.asm` (`NmiHandler` part note step 13, comments 33648, 33654, 33660) | the drain writes Ch1 to `$2142` / 0 to `APUIO2` | one 16-bit word to `$2142`/`$2143` on even frames, both bytes cleared |
| `hdma_dma_spc.asm` (block note, `SpcFadeOutHandshake` part note, comments 254403, 254405) | "not traced: audible?", "`$F0` arrives one or two frames later", "engine path ASL to `$02` ... not traced further" | audible about 335 frames; `$01` ignored because `$08` = `$01`; `$F0` follows the fade-end zero |
| `cop_handlers_audio.asm` (block note, `FadeThenStartMusic` part note) | "not traced: whether the fade is audible" | measured: audible |
| `scene_script.asm` (block note, `SpcMusicLoadCmd` part note, comments 166812, 166817, 166823) | `$F0` "ready signal", `$F2` "optional stop command" | `$F0` = `CmdStop`; `$F2` = `CmdF2` key-off of all voices; resident loader writes no DSP register |

Still shipped and left alone (not wrong): the `PlaySoundCh1`/`PlaySoundCh2` part notes, comment 172195 "SPC700 music engine ready signal" (describes the `$BBAA` ready state of the IPL), and the `SpcMusicLoadCmd` comment "Wait 26 frames for audio system settling".

---

## 5. Rules for patch authors

1. **Do not read `$06F2` as the track in use.** After `StartMusic`, `FadeThenStartMusic`, `pyCD_jackal` or the Memory Melody item it holds an older id. The chest and `MusicAndText` restore plays whatever id `$06F2` holds.
2. **One sound word per two frames.** `PlaySoundCh1` and `PlaySoundCh2` write the two halves of a word that the NMI sends and clears on even frames. A second write to the same half inside the same window replaces the first; the drain does not run while `musicTransitionState` is nonzero (`$FFFF` skips the write; a positive value runs `UpdateFrameFull`), so a queued sound waits until it is 0 again.
3. **`FadeThenStartMusic` blocks the track change for about 340 frames of audible fade**, plus any wait during which the main loop does not run the thinker. Use `StartMusic` for a hard cut (it sends `$F0` without a fade).
4. **`$F2` is not a mute.** It keys off the voices and leaves master volume, echo and `FLG` untouched; it repeats on every tick while the port holds it. `$F0` is the stop that clears master and echo volume.
5. **Do not expect the loader to reset DSP state.** The state during an upload is whatever `CmdStop` or `$F2` left. Sending `$F0`/`$FF` while a track still sounds was not measured.
6. **A song stream must keep the terminator word at the end of its song data.** The code does not check it; the first chunk goes wherever the word points, and the sample directory start words must match the computed chunk destinations.

---

## 6. Where the findings live in the docs

| Topic | Doc |
|-------|-----|
| SFX word, `$2142`/`$2143`, even frames | [cop/families/audio.md](cop/families/audio.md), [code/bank00/nmi-handler.md](code/bank00/nmi-handler.md), [wram-memory-map.md](wram-memory-map.md), [code/bank00/data-tables-memory.md](code/bank00/data-tables-memory.md), [cop-commands-reference.md](cop-commands-reference.md), `ram_map.txt` |
| Music ids, id n-1, call sites, hit and shake sounds | [cop/families/audio.md](cop/families/audio.md) (Family notes), [code/bank02/player-character.md](code/bank02/player-character.md) |
| `$06F2` | [wram-memory-map.md](wram-memory-map.md), [code/bank02/spc-transfer.md](code/bank02/spc-transfer.md), [code/bank02/scene-script.md](code/bank02/scene-script.md), [code/bank02/game-systems.md](code/bank02/game-systems.md), [code/bank02/README.md](code/bank02/README.md) |
| Fade, `$F0`/`$F1`/`$F2`, loader | [cop/families/audio.md](cop/families/audio.md), [audio/spc-engine.md](audio/spc-engine.md) §"Known Quirks" 8, [audio/spc-engine-us-vs-jp.md](audio/spc-engine-us-vs-jp.md) §5.3 and §5.7, [audio/spc-disassembly.md](audio/spc-disassembly.md), [code/bank03/scene-and-hardware.md](code/bank03/scene-and-hardware.md) |
| Stream layout, first chunk | [audio/spc-engine.md](audio/spc-engine.md) §"Song stream layout", [code/bank02/spc-transfer.md](code/bank02/spc-transfer.md) |

---

## 7. Open questions

1. After `FadeThenStartMusic` in `GaiaThenRest` the `$F1` echo never arrived (`APUIO0` read `$01`, SPC `$04` = `$01`), so track `$0E` was never uploaded. Do the other 13 `FadeThenStartMusic` sites complete, and does it depend on what the SPC is playing when `$F1` arrives?
2. Does the `$01` after the `$F1` echo reset `$30/$31/$0E` (cutting the fade) when `$08` is not `$01`?
3. What is audible when the shipped loader's `$F0` hits a track that still sounds (scene changes whose `bgm_table` entry is `$FF`): does the one-step MVOL change click?
4. Which dialogue in scene `$58` holds the main loop for about 240 frames after `FadeThenStartMusic`, and do other sites freeze the thinker the same way?
5. Does a scene change whose fade never passes brightness 6 still send `$F2` (`loc_03DAF2`), and does `$F0` then hit a sounding track?
6. Scene `$F9` stops in the `$F0` poll of its second `music` record (id `$17`). Does the real credits flow reach it, and what does it load?
7. What gates the spawn of Incan Statue A (scene `$19`)? `MusicAndText` (OQ-48) has no runtime answer until it spawns.
8. `LedgeJumpDropAttack`: `CheckLedgeJumpAttack` tests `BranchIfPressed #$0080`, the interact bit fed by physical A, not B. The header comment ("B pressed while falling") is unverified.
9. The stone guard's attack (`#1E`, every 47 frames) missed a player on 30 offsets; which relative position does `code_0A93E9` / `code_0A9441` accept? No hit landed for the `ApplyPlayerHitstun` sound check (Will only).
10. Library chunk `$3C` (1,028 bytes) is named by no stream. What is it?
11. Which SRCN does each entry of an extended sample directory (`$1000`, count × 4 bytes) get, and what fills the entries below the written range?

---

## 8. Apply log

- Notes: `plans/extracted-audit/edits/MS03.json` (union of `specs/D1_notes.json` and `specs/D2_notes.json`; comment 254403 shortened to stay under the length limit, comment 33648 added). Dry-run OK, merge wrote 9 notes files (`notes/blockNotes`, `notes/partNotes`, `notes/comments` for banks 00, 02, 03). Verified with `npm run extract:lt` and `npm run rebuild`: `artifacts/crc.json` identical before and after (checksum 222990002, crc -575332819, totalSize 3062205).
- Docs: the files in section 6, plus this summary.
- Names: none. `musicParentActor` is a misnomer (the value is the music id); a rename through `npm run names` is not part of this round.
