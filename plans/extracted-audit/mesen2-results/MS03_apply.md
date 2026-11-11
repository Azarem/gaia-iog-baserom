# MS03 apply: D1 to D3 notes (sound queue drain, `$06F2`, camera shake, fade and `$F0`/`$F2`, stream layout)

Date: 2026-10-31. Source reports: `D1_20261031.md`, `D2_20261031.md`, `D3_20261031.md`. Specs: `specs/D1_notes.json`, `specs/D2_notes.json` (written by the D sessions), merged into one conflict-free spec `plans/extracted-audit/edits/MS03.json` (format of `gaia-core/docs/notes-and-comments.md` §"Notes Merge"). D3 wrote no spec (no shipped note is wrong). No names spec (no shipped name is shown wrong; `musicParentActor` is a misnomer, see "Outside scope").

## Why one merged spec

Both specs touch `system_core.asm`, `hdma_dma_spc.asm` and `scene_script.asm` notes in the same banks and use `expectOld` for comments (no `; {n}` tags in a plain extraction). `MS03.json` holds the union of D1 and D2 with two changes: comment 254403 (`hdma_dma_spc.asm`) was shortened because the D2 dry-run warned about its length (176 characters), and comment 33648 (`system_core.asm`, the `STA APUIO2` line) was added, because the old text said only "write 0 to APUIO2".

| From | Entries |
|------|---------|
| D1 | `player_character.asm` block note and comment 182097; `music_actors.asm` block note, part note `MusicJingleActor`, comment 172096; `system_core.asm` part note `NmiHandler` (step 13), comments 33654, 33660 |
| D2 | `hdma_dma_spc.asm` block note, part note `SpcFadeOutHandshake`, comments 254403, 254405; `cop_handlers_audio.asm` block note, part note `FadeThenStartMusic`; `scene_script.asm` block note, part note `SpcMusicLoadCmd`, comments 166812, 166817, 166823 |
| added | `system_core.asm` comment 33648 |

## Procedure

1. Baseline: `artifacts/crc.json` before the merge: checksum 222990002, crc -575332819, totalSize 3062205, mode plain, sha1 `0cfcb55863052af92041107ecc28226d9f89f8aa`. The baseline was reproduced from a rebuild before the merge.
2. `specs/D1_notes.json` and `specs/D2_notes.json` each dry-run on their own: OK (D1 5 notes files, D2 8).
3. `npm run merge -- plans/extracted-audit/edits/MS03.json --dry-run`: 6 extracted files, OK.
4. `npm run merge -- plans/extracted-audit/edits/MS03.json` (real): wrote 9 notes files (the list is under "Files changed").
5. `npm run extract:lt`, then `npm run rebuild` (separate commands). Gate: `artifacts/crc.json` identical (checksum 222990002, crc -575332819, totalSize 3062205, sha1 `0cfcb558...`): **no ROM byte changed**.
6. Read-back in the tagged `extracted/`: every edited place carries the new text.
7. `npm run extract` (plain) to drop the tags, then `npm run rebuild`: `artifacts/crc.json` mode `plain`, numbers identical to the baseline.

## Result table

| Result id | File | Status | Note |
|-----------|------|--------|------|
| OQ-SAN2-1 | `extracted/actors/player/player_character.asm` (block note, comment 182097) | APPLIED | "once / about 60 frames" replaced: sound `#15` queued on every tick, 61 ticks |
| OQ-29 (c), OQ-I065-3 | `extracted/system/engine/music_actors.asm` (block note, `MusicJingleActor` part note, comment 172096) | APPLIED | "the scene's current music index" replaced: the BGM id stored by the scene's music record; `StartMusic` does not update it; `pyCD_jackal` and the Memory Melody item overwrite it with `$0F` / `$0E` |
| D1 side finding | `extracted/system/engine/system_core.asm` (`NmiHandler` part note step 13, comments 33648, 33654, 33660) | APPLIED | the drain is one 16-bit word to `$2142`/`$2143` on even frames, both bytes cleared, odd frames write 0 |
| OQ-I021-2 (a) | `extracted/system/engine/hdma_dma_spc.asm` (comments 254403, 254405) | APPLIED | the `$01` after the `$F1` echo is not dispatched while the SPC's `$08` holds `$01` |
| OQ-I021-2 (b), (c) | `extracted/system/engine/hdma_dma_spc.asm` (block note, `SpcFadeOutHandshake` part note), `cop_handlers_audio.asm` (block note, `FadeThenStartMusic` part note) | APPLIED | the three "not traced: audible" sentences replaced: audible, about 335 frames; "`$F0` one or two frames later" replaced: `$F0` follows the fade-end zero, later if a dialogue wait blocks the thinker |
| OQ-I021-3 (a), (b), OQ-I022-3 (a) | `extracted/system/engine/scene_script.asm` (block note, `SpcMusicLoadCmd` part note, comments 166812, 166817, 166823) | APPLIED | `$F0` = `CmdStop` (not a ready signal), `$F2` = `CmdF2` key-off of all voices, the resident loader writes no DSP register |
| OQ-I022-2 | (none) | NOT NEEDED | `spc_transfer.asm:20` and `:50` are right; the optional extra sentence is not merged |

Nothing DISPUTED, SKIPPED or BLOCKED.

## Files changed by the apply

`notes/blockNotes/bank00.json`, `bank02.json`, `bank03.json`; `notes/partNotes/bank00.json`, `bank02.json`, `bank03.json`; `notes/comments/bank00.json`, `bank02.json`, `bank03.json`; `extracted/actors/player/player_character.asm`, `extracted/system/engine/music_actors.asm`, `system_core.asm`, `hdma_dma_spc.asm`, `cop_handlers_audio.asm`, `scene_script.asm`. The rebuilds rewrote `artifacts/crc.json` (line endings only), `artifacts/file-layout.json` and `artifacts/master-lookup.json`.

## Documentation updated in the same pass

`docs/cop/families/audio.md` (overview, shared state, family notes, `$05` text, `$06`/`$07` drain target and latency, family summary row), `docs/cop-commands-reference.md`, `docs/wram-memory-map.md` (`$06F2`, `$06F8`, `$06F9` rows), `docs/ram_map.txt`, `docs/code/bank00/nmi-handler.md` (step 14, variable rows), `docs/code/bank00/data-tables-memory.md`, `docs/code/bank02/spc-transfer.md` (stream layout, `SpcMusicLoadCmd` timing, `$06F2` row), `docs/code/bank02/scene-script.md`, `docs/code/bank02/game-systems.md` (`MusicJingleActor`, `ChestOpeningActor`), `docs/code/bank02/player-character.md` (`CameraShakeActor`), `docs/code/bank02/README.md`, `docs/code/bank03/scene-and-hardware.md`, `docs/audio/spc-engine.md` (terminator word fixed, new "Song stream layout", new quirk 8 for `$F0`/`$F1`/`$F2`), `docs/audio/spc-engine-us-vs-jp.md` (`$F2` is a key-off, `$0E` is the KOFF source, status banner, open item 1), `docs/audio/spc-disassembly.md` (comments on `CmdFadeOut`, `CmdStop`, `CmdF2`, `ClearAramTail`), `docs/README.md`, and the new `docs/mesen2-d-series-summary.md`. Closure rows for D1 to D3 appended to `closures.md`.

## Outside scope (not applied)

- `closures.md` rows marked "not applied": `MusicAndText` runtime (OQ-48), the hit sound at runtime (OQ-I046-1 b), the `$0E` track after the Gaia rest (OQ-I056-5 b), the runtime upload of the `$17` record in scene `$F9`, `$F0`/`$FF` on a sounding track.
- Name quality: `musicParentActor` (`$06F2`) holds the music id, not an actor slot. A rename would go through `npm run names -- <spec.json>`; not part of this apply.
- `plans/extracted-audit/questions/*.md` is frozen and was not edited.
- The D2 shipped-build runs used R-b2, not the current R build; the shipped-build statements hold because the compared routine bytes are identical (see `D2_20261031.md`).

Please commit when you're ready. Suggested message: `Apply D1-D3 runtime measurements (SFX word to $2142/$2143, CameraShake ticks, $06F2 meaning, audible FadeThenStartMusic fade, $F0/$F2 semantics, SPC stream terminator) to notes and docs; add D-series summary`.
