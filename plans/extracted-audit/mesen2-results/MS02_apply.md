# MS02 apply: C1 to C4 notes (adhoc DMA order, NMITIMEN callers, boot and MEMSEL, displayModeFlags)

Date: 2026-10-30. Source reports: `C1_20261030.md`, `C2_20261030.md`, `C3_20261030.md`, `C4_20261030.md`. Specs: `specs/C1_notes.json`, `C2_notes.json`, `C3_notes.json`, `C4_notes.json` (written by the C sessions), merged into one conflict-free spec `plans/extracted-audit/edits/MS02.json` (format of `gaia-core/docs/notes-and-comments.md` §"Notes Merge"). No names spec (no shipped name is shown wrong).

## Why one merged spec

C2 explicitly replaces two C1 entries ("apply `C2_notes.json` instead of those two"): both edit the same sentence of the `hdma_dma_spc.asm` block note and the same sentence of the `AdhocVramDma` part note, and a second apply would fail because the `find` text is gone after the first. `MS02.json` therefore holds:

| From | Entries kept |
|------|--------------|
| C1 | `radar_map_screen.asm` comment 229608, `system_core.asm` comment 33215 (the two `hdma_dma_spc` / `AdhocVramDma` entries are superseded by C2) |
| C2 | `hdma_dma_spc.asm` block note, `cop_handlers_vram.asm` part note `AdhocVramDma`, `GlobalInputHandler.asm` comments 229449 and 229519, `scene_lifecycle.asm` part note `ExecuteSceneTransition` |
| C3 | `system_core.asm` part note `SystemInit` (two edits: step 3, step 6), comment 32807, `sFB_boot_logo.asm` block note |
| C4 | `cop_handlers_dialog.asm` part notes `DialogueOptions`, `PrintDialogString` and comments 43174, 43260; `DialogStringRenderer.asm` comment 254630; `inventory_overlay.asm` comment 191778; `camera_tilemap.asm` part note `Bg3TilemapVramDma` (two edits) |

## Procedure

1. Baseline: `artifacts/crc.json` before the merge (no `GATE:` line exists in the plan's Progress log): checksum 222977929, crc -524441819, totalSize 3062193, mode plain, sha1 `2e4a88a3de6dd4bdefc23c0dd626b953c18fe808`.
2. Each of the four specs dry-run on its own: OK (C1 4 files, C2 4, C3 3, C4 5 notes files).
3. `npm run merge -- plans/extracted-audit/edits/MS02.json --dry-run`: 11 extracted files, "8 notes file(s) would change", OK, one warning (the `191778` comment is 217 characters).
4. `npm run merge -- plans/extracted-audit/edits/MS02.json` (real): wrote `notes/blockNotes/bank03.json`, `bank0B.json`; `notes/partNotes/bank00.json`, `bank02.json`, `bank03.json`; `notes/comments/bank00.json`, `bank02.json`, `bank03.json`. Same warning.
5. `npm run extract:lt`, then `npm run rebuild` (separate commands). Gate: `artifacts/crc.json` after the rebuild has the identical checksum, crc, totalSize and sha1 (the mode label read `tagged` for the tagged extraction): **no ROM byte changed**.
6. Read-back in the tagged `extracted/` (all 15 edited places found with the expected new text, including every `; {n}` comment).
7. `npm run extract` (plain) to drop the tags, then `npm run rebuild` again: `artifacts/crc.json` mode `plain`, numbers identical to the baseline.
8. `npm run names -- --check`: still reports 12 formatting problems in names files this spec does not touch (the visible tail: bank07, bank09, bank0B, bank0C, bank0F, bank16, bank17; MS01 had counted 18). This apply writes no names file. Not part of this apply.
9. `git diff --stat` of `extracted/` and `notes/` (unstaged against the index that already holds MS01): 19 files, 36 lines replaced (below).

## Result table

| Result id | File:line | Status | Note |
|-----------|-----------|--------|------|
| OQ-45 (a) | `extracted/system/engine/hdma_dma_spc.asm:27` (block note) | APPLIED (C2 version) | "Writers must store the size before the destination" replaced by what the code does: both writers store the destination first, no NMI can run between the stores (27 pairs), the first `UpdateFrameDialogue` pass after a scene load runs with NMITIMEN `$81`, a writer that can run with the NMI on must store the size first |
| OQ-45 (a) | `extracted/system/engine/radar_map_screen.asm:76` (comment 229608) | APPLIED | "(writers should store the size first)" replaced by "the NMI is off here (NMITIMEN = $01), so it cannot run before the size store below" |
| OQ-45 (a) | `extracted/system/engine/cop_handlers_vram.asm:24` (`AdhocVramDma` part note) | APPLIED (C2 version) | the implied open window removed; NMITIMEN `$01` in actors, `UpdateFrameFull` disables first, the first dialogue pass after a load has no protection |
| OQ-I022-4 | `extracted/system/engine/system_core.asm:350` (comment 33215) | APPLIED | "Enable NMI for partial V-Blank" replaced: the call is `DisableNmiKeepJoypad` (NMITIMEN = `$01`), the enable is at the end of the routine |
| OQ-I022-4 | `extracted/system/engine/GlobalInputHandler.asm:113` (comment 229449), `:146` (comment 229519) | APPLIED | "NMI-only mode" corrected: `$01` = NMI off, joypad auto-read on; the display loop writes `$81` for one VBlank wait and then `$01` |
| OQ-I022-4 | `extracted/system/engine/scene_lifecycle.asm:178` (`ExecuteSceneTransition` part note) | APPLIED | says the chain ends with `EnableNmiAndJoypad` and leaves NMITIMEN `$81` into the enter transition |
| OQ-I024-4 | `extracted/system/engine/system_core.asm:141` (`SystemInit` step 3), `:169` (comment 32807) | APPLIED | FastROM timing from the first `MEMSEL = 1` lasts only for the register loop; WRAM clear, SPC upload and first scene loads run SlowROM until `BootLogoInit` (frame 84); upload takes the same master clocks under FastROM |
| OQ-50 | `extracted/system/engine/system_core.asm:144` (`SystemInit` step 6) | APPLIED | the `$0100` check has no effect; value after a cold boot and after a reset; identical boot measured with `$83`, `$00`, `$5A` and random values |
| OQ-I055-3 | `extracted/system/boot_logos/sFB_boot_logo.asm:8` (block note) | APPLIED | a reset clears event flag `$10` too (boot WRAM clear), so the first logo always plays |
| OQ-6, OQ-42 | `extracted/system/engine/camera_tilemap.asm:871`, `:875` (`Bg3TilemapVramDma` part note) | APPLIED | gate bit: no instruction sets it, requests stay pending and run after the clear; bits 4/5 measured range and the "only bit 4 is requested, bit 5 has no setter" sentence |
| OQ-23† | `extracted/system/engine/DialogStringRenderer.asm:142` (comment 254630) | APPLIED | "(consumer not traced)" replaced by the consumer and the VRAM target |
| OQ-51 | `extracted/system/engine/cop_handlers_dialog.asm:59`, `:122` (part notes), `:75` (comment 43174), `:126` (comment 43260) | APPLIED | the four "no reader of bit 13" sentences (CONTRADICTED) replaced: the only reader is the Mu bomb countdown |
| OQ-I034-1† | `extracted/system/inventory/inventory_overlay.asm:116` (comment 191778) | APPLIED | adds that `SceneCmd_ConfigDisplay` clears bit 14 again two frames after the store (217 characters, merge warning accepted) |

Nothing DISPUTED, SKIPPED or BLOCKED.

## Files changed by the apply

`notes/blockNotes/bank03.json`, `bank0B.json`; `notes/partNotes/bank00.json`, `bank02.json`, `bank03.json`; `notes/comments/bank00.json`, `bank02.json`, `bank03.json`; `extracted/system/boot_logos/sFB_boot_logo.asm`, `extracted/system/engine/DialogStringRenderer.asm`, `GlobalInputHandler.asm`, `camera_tilemap.asm`, `cop_handlers_dialog.asm`, `cop_handlers_vram.asm`, `hdma_dma_spc.asm`, `radar_map_screen.asm`, `scene_lifecycle.asm`, `system_core.asm`, `extracted/system/inventory/inventory_overlay.asm`. The rebuilds rewrote `artifacts/crc.json` (line endings only), `artifacts/file-layout.json` and `artifacts/master-lookup.json`.

## Overlap with open items

`inventory_overlay.asm:116` (comment 191778) and `camera_tilemap.asm` `Bg3TilemapVramDma` and `DialogStringRenderer.asm:142` are also named by ACTION_PLAN IT-19 (open). The text added here is runtime fact only (no rename, no block move); whoever applies IT-19 should re-read these three places before editing and keep the measured sentences.

## Documentation updated in the same pass

`docs/wram-memory-map.md` (new "Display Mode Flags Reference (`$09EC`)", `$09EC` / `$09ED` rows, `$0100` row, `$0A00` flag reset note, §4.3 adhoc DMA block), `docs/code/bank00/system-core.md` (boot steps, boot timeline, `UpdateHUD`, `UpdateFrameDialogue`, `UpdateFrameFull`), `docs/code/bank00/nmi-handler.md`, `docs/code/bank00/data-tables-memory.md`, `docs/code/bank02/hardware-and-init.md` (new "NMITIMEN state by caller (measured)", MEMSEL), `docs/code/bank02/camera-scrolling.md`, `docs/code/bank02/inventory-overlay.md`, `docs/code/bank02/scene-script.md`, `docs/code/bank03/field-input-and-items.md`, `docs/code/bank03/scene-and-hardware.md`, `docs/code/bank06-late-midgame-actors.md`, `docs/code/bank0B-late-bosses-system-cutscene-actors.md`, `docs/cop/families/dialog.md`, `docs/cop/families/vram_memory.md`, and the new `docs/mesen2-c-series-summary.md`. Closure rows for C1 to C4 appended to `closures.md`.

## Outside scope (not applied)

- `closures.md` rows marked "not applied": the `AdhocVramDma` callers that were not run (Aura, Dark Friar, `$0B`, `$67`, `$74`, `$E1`), the diary and second radar `NMITIMEN` pairs, the intent of the first `MEMSEL = 1`, whether anything sets `$0100` = `$83` during play, and the OQ-42 element question (rows 2-6 of the BG3 buffer).
- The Cursor-registered `user-mesen2-mcp-dev` namespace is a stale client schema (no `get_server_status`, no `paused` / `fromReset` / `reset mode`); the C2 to C4 runs used `harness/mcp_client.py` against the 0.6.0 server. Environment issue, not a server defect.
- `plans/extracted-audit/questions/*.md` is frozen and was not edited.

Please commit when you're ready. Suggested message: `Apply C1-C4 runtime measurements (adhoc DMA order, NMITIMEN, boot/MEMSEL, displayModeFlags) to notes and docs; add C-series summary`.
