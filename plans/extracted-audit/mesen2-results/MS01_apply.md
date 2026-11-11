# MS01 apply: B4 notes (ramps, glide, booster, slope probe)

Date: 2026-10-30. Source report: `B4_20261030.md`. Spec: `plans/extracted-audit/mesen2-results/specs/B4_notes.json` (written by the B4 session, not under `edits/`; format of `gaia-core/docs/notes-and-comments.md` §"Notes Merge"). No names spec (no shipped name is shown wrong).

## Procedure

1. Baseline: `artifacts/crc.json` before the merge (no `GATE:` line exists in the plan's Progress log): checksum 222977929, crc -524441819, totalSize 3062193, mode tagged, sha1 `2e4a88a3de6dd4bdefc23c0dd626b953c18fe808`.
2. `npm run merge -- plans/extracted-audit/mesen2-results/specs/B4_notes.json --dry-run` (done by B4): 4 files, 1 block each, "2 notes file(s) would change", nothing written.
3. `npm run merge -- plans/extracted-audit/mesen2-results/specs/B4_notes.json` (real): `notes/blockNotes/bank00.json` and `notes/blockNotes/bank02.json` written.
4. `npm run extract:lt`, then `npm run rebuild` (separate commands).
5. Gate: `artifacts/crc.json` after the rebuild is identical to the baseline (same checksum, crc, totalSize, mode, sha1): **no ROM byte changed**.
6. `npm run extract` (plain) to drop the `; {n}` tags that `extract:lt` added to 818 extracted files.
7. `npm run names -- --check`: reports 18 formatting problems in names files this spec does not touch (bank16, bank17 and others); this apply writes no names file. Not part of this apply.
8. `git diff --stat` of `extracted/` and `notes/`: 6 files, 10 lines replaced (below).

## Result table

| Result id | File:line | Status | Note |
|-----------|-----------|--------|------|
| OQ-I036-2 | `extracted/actors/ramps.asm` (block note: arc paragraph) | APPLIED | "about 512 pixels of horizontal travel" becomes "519-520 pixels ... (measured from the launch X to the first frame with the lock released)"; "about 256 pixels" becomes "263-264 pixels" |
| OQ-I036-2 | `extracted/actors/ramps.asm` (static-estimate sentence) | APPLIED | replaced by the measured arc statement (frames, peak, end height) |
| OQ-I036-2, OQ-I036-3 | `extracted/actors/ramps.asm` (N/S paragraph) | APPLIED | gains the measured loop lengths (9 frames / 64 px north, 5 frames / 32 px south) and the animation indices |
| OQ-I036-1 | `extracted/actors/ramps.asm` (quirk: step size) | APPLIED | "not checked at runtime" replaced by the equality statistics and the walk/run note |
| OQ-I040-1, OQ-I040-2 | `extracted/actors/large_ramps.asm:8` | APPLIED | the blanket unverified sentence replaced by the measured booster behavior |
| OQ-I023-1 (south, north) | `extracted/system/engine/slider_glide.asm` (block note) | APPLIED | measured glide sentence added after the "no animation during the glide" sentence |
| OQ-I030-4 | `extracted/actors/player/slope_ramp_physics.asm:34` (block note) | APPLIED | measured MapCellDown / MapCellUp sentence added |

`ramps.asm` has 5 edits that change 3 lines of its block note. Nothing DISPUTED, SKIPPED or BLOCKED.

## Files changed by the apply

`notes/blockNotes/bank00.json`, `notes/blockNotes/bank02.json`, `extracted/actors/ramps.asm`, `extracted/actors/large_ramps.asm`, `extracted/system/engine/slider_glide.asm`, `extracted/actors/player/slope_ramp_physics.asm`. The rebuild also rewrote `artifacts/file-layout.json` and `artifacts/master-lookup.json` (generated; check the diff before committing: `crc.json` equals the baseline, so any layout difference is metadata only).

## Documentation updated in the same pass

`docs/code/bank00/ramp-launchers.md` (new), `stair-climb-system.md`, `actors-infrastructure.md`, `data-tables-memory.md`, `bank00/README.md`, `docs/code/README.md`, `docs/bank01-data-tables.md`, `docs/code/bank02/slope-ramp-physics.md`, `docs/code/bank02/tile-collision.md`.

## Outside scope (not applied)

- `specs/B1_notes.json` and `specs/B3_notes.json` are already applied in the working tree and HEAD (their old sentences are gone from `extracted/`, and `docs/wram-memory-map.md` §4.10 already carries the B1 table correction); nothing to do for them here.
- Three blanket "UNVERIFIED-RUNTIME" lines remain: `player_move_east.asm:34`, `player_move_ns.asm:36`, `player_move_main.asm:33` (`B_addendum_20261030.md`, items BA-N1 to BA-N3).
- `questions/*.md` is frozen: `I023_questions.md:7` still says "14 East, 12 West" (the shipped notes are right).

Please commit when you're ready. Suggested message: `Apply B4 runtime measurements (ramps, glide, booster, MapCell) to notes and docs; add ramp-launchers.md`.
