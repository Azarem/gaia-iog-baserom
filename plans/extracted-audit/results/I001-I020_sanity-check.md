# Sanity check of iterations I001–I020 — 2026-10-27

Scope: the 60 files of I001–I020, their notes under `notes/`, the ledgers, and the gate. Method: read-only coverage, orphan, reference-integrity and results-completeness scans, plus targeted greps over all of `extracted/` for claims that later iterations corrected. Fixes were applied only through `npm run annotate` (specs below).

Companion files: [I001-I020_results.md](I001-I020_results.md), [../renames/I001-I020_rename-proposals.md](../renames/I001-I020_rename-proposals.md), [../questions/I001-I020_open-questions.md](../questions/I001-I020_open-questions.md).

## Verdict

Structure is complete and consistent; the audit found and fixed 3 groups of stale or missing annotations, all caused by a later iteration correcting a fact that an earlier note still stated.

## Checks that passed

- All 20 iterations have a results section with Q1–Q7 verdicts for each of their 60 files, and a ticked checklist line.
- Ledger integrity: rename rows 1..96 and OQ-1..OQ-69 are contiguous, every ID cited inside an asm note or comment exists, and no ID is defined twice.
- `notes/blockNotes`, `partNotes` and `comments` match the extracted `.asm` (ingest dry-run is a no-op; the only noise is the known `MenuSelectionHandler` item, OQ-59).
- Every annotate spec in `edits/` is idempotent (second run: "Wrote 0 file(s)").
- Gate after the fixes: `extract:lt` then `rebuild`, `artifacts/crc.json` = checksum 223006080 / crc 2083230829 / totalSize 3062204 (unchanged).

## Defects found and fixed (spec `edits/sanity-I001-I020.json`)

| # | File | Problem | Fix |
|---|------|---------|-----|
| 1 | `actor_pool` tag 45401 | Comment said the table gives a "frame duration"; the part note (I019) correctly says it is a movement delta chain head pointer | Comment reworded |
| 2 | `system_core` tag 33232 | "Run overlay actors during music fade" contradicted I015 (UpdateFrameFull is run from the NMI during the blocking SPC music upload) | Comment reworded, `expect` = `RunActors_OverlayOnly` |
| 3 | `actor_execution` block note | Item 5 said "music-fade tick ... musicTransitionState"; final paragraph said "scene-local WRAM flags" (OQ-67: lifetime unproven) | Block note rewritten |
| 4 | `actor_execution` part `CheckEnemyDefeatedFlag` | Claimed flags are cleared at scene boundaries | Reworded, points to OQ-67 |
| 5 | `cop_handlers_dungeon_switch` block note and part `SetDungeonKillFlag` | Same "scene-local, cleared at scene boundaries" claim | Reworded, points to OQ-67 |

## Coverage gaps filled (same spec)

Sub-labels that had no part note although they hold real logic or are pass-specific:

- `actor_execution`: the 10 `*_PostTick`, `*_CopPostTick`, `*_Exit` labels of the display-filtered, pause-filtered, cutscene and overlay passes (including the iframe-only tail after the pause-filtered exit).
- `combat_collision`: `CombatCollision_Exit`, `PlayerAttackHitTest_End`, `InteractionCollision_Exit`, `InteractionCollision_FriendlyMode`, and `EnemyHitPlayer_Epilogue`. The last one is a mid-routine label: the part holds the whole combat-damage path of `EnemyHitPlayerHandler`, which is also why the handler's own part note now says "the code under EnemyHitPlayer_Epilogue".
- `DialogStringRenderer`: `DialogCmd_InfiniteLoop`, `_WaitFrames`, `_AdvanceCursor`, `_InsertRemoteString`, `_JumpToAddress`, `_SetSfx`, `WaitNFrames_Loop`.

## Stale file-name references fixed (spec `edits/sanity-ledger-links.json`)

Notes that cited `rename-proposals.md` or `open-questions.md` by the old file names now cite `renames/I001-I020_rename-proposals.md` and `questions/I001-I020_open-questions.md`: `EnemyHitPlayerHandler` part note and the comment at tag 244729 in `combat_collision`, and the `FollowChaseMoveWest` part note in `smooth_follow`.

## Observations, deliberately not changed

- Renames remain proposals only (see the renames file). New proposal found in this pass: `EnemyHitPlayer_Epilogue` is misleading because it contains the damage routine, not an epilogue (candidate: `ApplyHitDamageToVictim_DamagePath`; sub-label of existing rename row 13).
- `FacingFormOffsetTable` and `code_02A88B` have no own part note, but their owning block notes describe them fully; left as is to avoid duplicate text.
- Pre-existing, not caused by the audit: 7 orphan block notes, 1 orphan part note and 80 orphan comment addresses in `notes/`.
- `db-us/names.json` shows as deleted in `git status`: names now live in `db-us/names/bank*.json` (user's restructure, not an audit change).

## Process change

From I021 on, every iteration writes new files in `results/`, `renames/`, `questions/` and `edits/`; ledgers are never appended to. Details: [../checklist.md](../checklist.md) section 0 and `gaia-core/docs/notes-and-comments.md` ("Write new files; never append to or splice into a large file").

## Suggested commit message

```
audit(sanity I001-I020): fix stale scene-local/music-fade notes, add missing sub-label part notes, split ledgers into per-iteration folders
```

Please commit when you're ready.
