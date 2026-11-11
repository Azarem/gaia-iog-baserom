# Sanity check of iterations I041–I050 — 2026-10-27

Scope: the 30 files of I041–I050 (see `checklist.md`), their notes under `notes/`, the ledgers and the gate. Method: re-read every audited file in `extract:lt` form against the rubric of `plans/iog_extracted_asm_audit` (Q1–Q7) and the Comment Authoring Guide in `gaia-core/docs/notes-and-comments.md` (density follows complexity, aggregate sequences, document a repeated pattern once, no instruction restating, no duplication of part/block notes); check each factual claim in the kept comments against the code; then run the integrity checks. Fixes were applied only through `npm run merge` (specs below); verification only through `extract:lt`, `rebuild` and plain `extract`. No script generated any edit: every keep/null list was typed by hand from the lt output.

Companion files: [I041_results.md](I041_results.md) … [I050_results.md](I050_results.md), [../renames/sanity-I041-I050_renames.md](../renames/sanity-I041-I050_renames.md), [../questions/sanity-I041-I050_questions.md](../questions/sanity-I041-I050_questions.md), template: [I021-I040_sanity-check.md](I021-I040_sanity-check.md).

## Verdict

The code, the ledgers and the facts in the notes are sound; the comment **style** was not. Six iterations (I041, I042, I045, I046 from a scratch builder script, I047 and I048 written by hand) commented 55–100 % of the instructions, line by line, in aggregated sequences (`ASL`/`ASL`/`ASL`, `LSR`/`LSR`, `CLC`/`ADC`/`STA`), restating instructions and repeating the same comment in each copy of a repeated pattern. That violates plan Q2 and the authoring guide (the I049 note already admitted it for I045/I046). It is fixed: **1,182 comments removed, about 245 rewritten as aggregated comments (counts from the merge reports), 3 stale original comments removed, 1 block note + 1 part note corrected.** I043, I044, I049 and I050 were already at 25–45 % density with accurate content and needed one change in total.

One **factual defect** was found and fixed: `player_move_main` still described Flags10 bit `$0008` as "grounded / airborne frames skip it". I047 established (and `player_move_controller` documents) that `$0008` means collision-checked movement and that the vine, ladder and shimmy states clear it. Block note and the `PlayerMovementTick` part note now say so.

## Checks that passed

- **Structure:** each of I041–I050 has a results file (Q1–Q7 for every file), an `edits/I0nn.json`, a renames file and a questions file; files in `checklist.md` match (30 files, 0 missing, 0 duplicated). Cited IDs (`OQ-I042-5/6`, `OQ-I043-1`, `OQ-I044-1`, `OQ-I045-1`, `OQ-I046-3/4`, `OQ-I048-1`) all exist in the questions files.
- **Code integrity:** after all corrections, plain `npm run extract` equals `HEAD` for every changed file when comments, tags, `---` lines and trailing blanks are stripped from both sides (`CODE_IDENTICAL`). `git diff HEAD -- db-us/names us` is empty: no name, block, override or transform changed in I041–I050.
- **Gate:** `npm run extract:lt` then `npm run rebuild`: `artifacts/crc.json` = checksum 223006080 / crc 2083230829 / totalSize 3062204 (unchanged). A plain `extract` was re-run afterwards so the working tree is the plain tree.
- **Spec idempotence:** every `sanity-*` spec re-applied with `--dry-run` on the final tree reports 0 changes. (The original `I041`–`I048` specs are superseded for the files touched here: replaying them would re-add the noise comments. Apply `sanity-*` after them, or not at all.)
- **`ingest:dry`:** the same baseline as the I021–I040 pass (unmerged `MenuSelectionHandler` proposal and the `bank0B` / `bank09` / `bank03` quirks); nothing new from I041–I050.
- **Facts re-verified against the code** while thinning: all three `Check*` tier thresholds and curve sums in `hit_stagger_controller` (48 / 32 px), the direction decode, the 120-to-5-tick ramp (7,250 ticks) and the diagonal-fall indices in `particle_rain_spawner`, the 21-leaf table of `debug_man` (row 3 / row 4 leaf order, scene ids), the nine drop percentages of `DarkGemDropSystem` (recomputed from the thresholds: 5.9 / 17.6 / 36.3 / 40.2, 9.8 / 19.9 / 30.1 / 40.2, 4.7 / 15.2 / 29.7 / 50.4), HP-tier logic, the `binary_00D068` sums and the three-run death count in `camera_drift`, the bound tests (`BCC` / `BCS` strictness) in `npc_wander_ai`, the 8-bit `BVC` reset to `$55` in `inventory_mgmt` against the 16-bit never-reached clamp in `reward_actors`, and the `camera_scroll_controller` target maths.

## Defects found and fixed

| # | Cause | Where | Fix (spec) |
|---|-------|-------|------------|
| 1 | **Comment-per-instruction noise** (Q2) | `mode7_perspective` (265 → 48 comments), `SpawnAttackTrailEffect` (36 → 10), `hidden_red_jewel` (19 → 10) | `sanity-I041.json`: kept the one-per-step comments (magic numbers, quadrant dispatch, packed BCD scratch word, event-flag numbers); a 190-char comment shortened |
| 2 | same | `overworld_exit` (208 → 10: the 15 handlers repeat `LDA #0 / STA $0D60 / COP StageWorldMapChoice / JMP OverworldExitFinalize`, documented once), `SpawnHitSparkSprites` (35 → 8), `floor_button` (25 → 14) | `sanity-I042.json` |
| 3 | same + **wrong fact** | `player_move_main` (197 → 39), `ApplyOrbitalOffsetFromRef` (46 → 8), `particle_rain_spawner` (37 → 13) | `sanity-I045.json`, `sanity-I045-I046-leftovers.json`. Block note and `PlayerMovementTick` part note: "grounded / airborne" → collision-checked movement (bit `$0008`; cleared by vine, ladder, shimmy) |
| 4 | Comment-per-instruction noise | `hit_stagger_controller` (214 → 49), `ApplyPlayerHitstun` (53 → 16), `EnemyDefeatDispatch` (51 → 15) | `sanity-I046.json`: one comment per step; the four direction branches share one comment on the first branch; 164-char comment shortened in the leftovers spec |
| 5 | same (my own I047 / I048 specs) | `player_move_controller` (106 → 49), `inventory_statue_slot` (31 → 15), `reward_actors` (51 → 20) | `sanity-I047.json` |
| 6 | same (my own I048 spec) | `statue_inventory_reward` (113 → 49), `dialog_string_scanner` (52 → 19), `shadow_shimmer` (51 → 17) | `sanity-I048.json`: pattern copies (`Idle` / `Active` / `Guard` entry-word + waitCounter writes) documented once |
| 7 | **Original comment contradicting the audit** | `inventory_mgmt` {258062} {258100} {258131}: "clear stat-up HUD refresh flag" on `TRB displayModeFlags #$0080` | `sanity-I050.json`: removed; the next line's comment (display-filter clear) is correct, and I050 had already corrected the same fact |

Density after the pass (commented lines / instruction lines, from `extract:lt`): `mode7_perspective` 48/265, `overworld_exit` 10/208, `player_move_main` 39/200, `hit_stagger_controller` 49/214, `statue_inventory_reward` 49/174, `player_move_controller` 49/193; the small files `floor_button` 14/25 and `hidden_red_jewel` 10/19 stay above half because each of their lines carries a flag number, a table offset or a scratch-word fact. All other files in the range are between 10 % and 45 %.

## Observations (no change made here)

- **`sE6_gaia` comments** (lines ~1774 and ~1789, `ORA #$0008`) call bit `$0008` "grounded/collision". It is the collision-checked-movement bit (same fact as defect 3). Candidate for a follow-up spec with the file's own iteration.
- **Doc corrections still pending** (docs outside `extracted/`, not part of the audit): `slope_ramp_physics` header "next pass"; `SpawnLastRel` naming in `player_character.asm:107`, `docs/code/bank02/README.md:382` and `inventory_mgmt.asm:101`; `wram-memory-map` `displayModeFlags` bit `$0080`; the `actors-player-rewards.md` and `actors-combat-interaction.md` statements listed in `renames/I047_renames.md` and `renames/I048_renames.md`; any doc that calls Flags10 `$0008` "grounded".
- **Not re-read in full this pass:** `global_ambient_dispatcher` (62 of 251 lines commented) and `ApplyOrbitalOffsetXY` (I044); I043 and I044 files were checked for density only apart from `jeweler_gem`, `town_door`, `EnemyPositionSnap` and `incan_ruins_transform_palette`, which were read in full and left unchanged.
- No new open questions and no new rename proposals (see the two companion files).

Please commit when you're ready. Suggested message: `Sanity check I041–I050: thin comment-per-instruction noise, fix $0008 grounded claim in player_move_main`.
