# IT-13 apply: hygiene sweep 2, history narration and ledger ids (I041-I060 files)

Mechanism: `npm run merge` only. Specs: `plans/extracted-audit/audit-of-audit/IT13_spec.json` (one spec, 42 files, dry-run first) and `IT13_spec_b.json` (one follow-up entry, see "Follow-up spec"). The first run reported 41 block notes, 22 part notes and 20 comments updated (83 entries), nothing added or removed. Scope: the A04 section 1 and A05 section 1 files that still had a hit in the live `extracted/` tree after `npm run extract:lt`. I swept the live files with the IT-12 patterns (and a case-insensitive variant, which also finds "The old comments ...") instead of trusting the line numbers of A04-08 / A04-09 / A05-04 / A05-05.

Files edited (42): `actors/` 16 (`debug_man`, `dialog_string_scanner`, `unused_particle_rain_spawner`, `jeweler_gem`, `camera_scroll_controller`, `hit_stagger_controller`, `overworld_exit`, `hit_switch`, `hidden_red_jewel`, `town_door`, `player/shadow_shimmer`, `field_reveal_object`, `layer1_scroll_actors`, `player_transition_handlers`, `dark_space`, `boss_clear_reward_handler`), `functions/` 11 (`EnemyDefeatDispatch`, `EnemyPositionSnap`, `ApplyOrbitalOffsetXY`, `ApplyOrbitalOffsetFromRef`, `EnemyDropSystem`, `SpawnDamageNumberEffect`, `camera_drift`, `npc_wander_ai`, `ApplyPlayerHitstun`, `EscortFollowPathTracker`, `game_over_sequence`), `thinkers/` 2 (`global_ambient_dispatcher`, `gold_ship_wreck_palette`), `unused/DamageNumberShort_unused`, `system/` 12 (`inventory/inventory_mgmt`, `statue_inventory/statue_inventory_reward`, `dark_space/sE6_gaia`, `boot_logos/boot_logo_enix_palette_obj0|1|2`, `diary_menu/sFA_diary_menu`, `diary_menu/diary_menu_window_dma`, `world_map/WorldMapSplitEffect`, `WorldMapController`, `world_map_options`, `world_map_route_table`).

## Sweeps

- narration: `\b(previously|formerly|old header|old note|the old |older|was renamed|rename proposed|historical|stale name|used to be|first audit)\b` (second pass with `-i`, plus `first called` and `old comments?`)
- ids: `OQ-[A-Za-z0-9-]+|\bR-(I[0-9]{3}|B[0-9]{3}|SAN[0-9]|[0-9]+)(-[0-9a-z]+)?\b|\bD-S[0-9]+-[0-9]+\b|rename proposal|questions file|\(I0[0-9]{2}\)|audit (OQ|rename)` (plus `\bI05[45]\b` and `=== CORRECTIONS` for the A05 prose)

| sweep | before (whole `extracted/`, = the "after" of IT-12) | after (whole `extracted/`) | after, in the 56 scope files |
|---|---|---|---|
| ids | 87 matches in 40 files | 22 matches in 12 files | 1 (`sFA_diary_menu.asm` line 34, `OQ-I026-1`: build-mode sentence, skipped by instruction) |
| narration | 107 matches in 59 files | 39 matches in 28 files | 0 narration; 7 hits are runtime words or game text (below) |

Case-insensitive narration sweep over the 30 A04 files before editing: 53 matching lines. For the A05 files I did not count before editing; the inspection list was about 22 lines plus the five `=== CORRECTIONS ===` sections. After editing, the in-scope narration hits left are all runtime words, not history: `player_move_controller.asm` 10, 66, 75 ("the old fraction is lost"), `interaction_handlers.asm` 249 ("the old position"), `inventory_mgmt.asm` 13 and 150 ("the old value" of the stat before the add), `sE6_gaia.asm` 1142 (dialog text "previously obtained").

## Facts re-derived before writing

- `ApplyPlayerHitstun` (OQ-I046-2): after a failed spawn Y = `$1FC0`; the stores after the `LDA $0000` are `STA $0028, Y`, `$002C, Y`, `$002E, Y` and `STA $extendedFlags, X` after `TYX`. So they are indexed by that Y. What `$1FC0` plus those offsets hits is not traced; the note now says so.
- `EnemyDefeatDispatch` (OQ-I046-4): the test is `LDA $enemiesRemaining` / exact-1 compare; a 0 would wrap. No caller that passes 0 was found in `extracted/`, so the id became "Not traced: whether any caller can reach this with `$0AEC` = 0".
- `EnemyDropSystem` (OQ-I049-3): `combat_collision` tests `$10` bit `$0400` in its player-attack phase (existing statement in the note); why the `$0420` spawn flags set it first is not traced. The note and comment 57154 say that.
- `layer1_scroll_actors` (OQ-I051-1): comment 59675 already said "no SetEntryHere in this actor"; the part note now states it the same way.
- `boss_clear_reward_handler` (OQ-I051-3): `$04` is written by the entry and used as scratch by the apply routine; whether anything reads the list-predecessor link meanwhile is not traced.
- `EscortFollowPathTracker` (OQ-I052-7): no caller was traced that can pass `A >= 4`; the sentence says so.
- `=== CORRECTIONS ===` sections of `dark_space`, `sE6_gaia`, `world_map_route_table` and `boot_logo_enix_palette_obj0|1|2`: each fact was checked against the rest of the same note and the code (route-step bytes: world_map_options notes; palette bundles and spawn params: the thinker header; sE6 ability table, voice sparkle, warp parameters: the flow sections). Every fact is already stated elsewhere in its file, so the sections were removed whole.
- `game_over_sequence`: the section is not purely narration. It keeps the transform fact (`$FFF0` / `$CFF0` widened to `$FFFC` / `$CFFC`) and the 16-bit sound operand, under the heading `=== JOYPAD MASKS AND SOUND ===`. The dropped sentence (33-tick first wait, 100 gems in the revive case, `wramFlags` cleared on a real game over, two warp records) is stated in the flow sections of the same note.
- Other ids (`OQ-I042-5/6/7`, `OQ-I042-3`, `OQ-I041-5/7`, `OQ-I043-1`, `OQ-I044-1`, `OQ-I045-2`, `OQ-I046-3`, `OQ-I048-1`/`OQ-I030-1`, `OQ-I049-4`, `OQ-I050-1/2/4`, `OQ-I051-2/4/5/6/7`, `OQ-I052-1..5/9`, `OQ-I025-2`, `OQ-I056-2/3`, `OQ-I057-1/3`, `OQ-I058-1`, `OQ-I059-1/2/4/7`, `OQ-I060-2`, `OQ-63`, `R-I057-4`, `R-I060-3`): the sentence already stated the current fact; the id was removed, or the clause became "not traced" where the id only marked an open question. The `OQ-I056-2` firefly sentence ("it rises") kept the fact that the loop must move down.
- `R-I060-4` (four hits in A05-05) and "I054 / I055" in prose: `R-I060-4` no longer exists in the live files; the `I054` prose was inside the boot-logo CORRECTIONS sections and went with them.
- Blanket `UNVERIFIED-RUNTIME` tags: removed only in paragraphs this iteration touched (`EnemyDefeatDispatch`, `ApplyOrbitalOffsetFromRef`, `unused_particle_rain_spawner`: the two claims there are computed from the code, so they now say "computed from the code, not run").

## Applied (by file)

| file | what changed |
|---|---|
| `actors/debug_man`, `dialog_string_scanner`, `jeweler_gem` (+ part `JewelerDie`), `town_door`, `hidden_red_jewel`, `hit_switch`, `shadow_shimmer` | old header / old docs / old note clauses and ids dropped; `town_door` "not verified at runtime (OQ-I043-1)" became "whether that case occurs is not traced" (follow-up spec) |
| `actors/unused_particle_rain_spawner` | 7 clauses (old header, old note, old part note, old comments, doc quote) removed; two `UNVERIFIED-RUNTIME` tags replaced by "computed from the code, not run" |
| `actors/camera_scroll_controller`, `functions/camera_drift` | old-note and old-comment clauses and ids removed; comments 60252 and 53270 |
| `actors/hit_stagger_controller` (+ part `HitStaggerReleasePlayer`), `functions/ApplyPlayerHitstun`, `EnemyDefeatDispatch` | old header / old note / old label clauses and 4 ids; comment 697407 |
| `actors/overworld_exit` | 3 ids in the block note, the "old header" bullet rewritten as "The handlers do not fall through into OverworldExitFinalize: they JMP to it"; comments 51905, 51940, 51988 |
| `functions/EnemyPositionSnap`, `ApplyOrbitalOffsetXY`, `ApplyOrbitalOffsetFromRef`, `EnemyDropSystem`, `SpawnDamageNumberEffect`, `npc_wander_ai`, `EscortFollowPathTracker`, `unused/DamageNumberShort_unused` | old header / old name clauses and ids; comment 57154 |
| `thinkers/global_ambient_dispatcher` | 6 clauses in the block note and 7 part notes (`GlobalAmbientOnInteractPress`, `FacingValid`, `ProbeDown/Up/Left/Right`, `AnimFacingHorizontal`): "the old label said ..." dropped |
| `thinkers/gold_ship_wreck_palette` | 5 old name / old doc / old note clauses and one id |
| `system/inventory/inventory_mgmt`, `statue_inventory/statue_inventory_reward` | "old note called it a cap" dropped; comment 258081; part `StatueRewardNotThisStatue` old-label sentence dropped |
| `actors/field_reveal_object`, `layer1_scroll_actors` (+ parts `Layer1DriftUnbounded`, `Layer1ParallaxRatio`), `player_transition_handlers` (+ parts `PlayerIdleAnimLoop`, `PlayerFallFromHeight`, `PlayerAuraTransformEntry`, `PlayerAuraLandOnSolid`), `boss_clear_reward_handler` | old header paragraphs and ids; comments 55986, 56118, 59675, 59692, 50226, 50633, 49907 |
| `actors/dark_space` | `=== CORRECTIONS ===` section removed, "answers part of OQ-I025-2" dropped; comment 579278 |
| `system/dark_space/sE6_gaia` (+ parts `DS_WillTransformRoom`, `LookupAbilityForm`, `FireflyParticle`) | 5 clauses and the `=== CORRECTIONS ===` section removed |
| `system/boot_logos/boot_logo_enix_palette_obj0|1|2` | `=== CORRECTIONS ===` sections removed |
| `functions/game_over_sequence` | heading renamed to `=== JOYPAD MASKS AND SOUND ===`; duplicate flow facts dropped |
| `system/diary_menu/sFA_diary_menu` (+ part `DiaryUnused24B_noref`), `diary_menu_window_dma`, `system/world_map/WorldMapSplitEffect`, `WorldMapController` (+ part `LookupMapNameMiss`), `world_map_options` (+ part `dialogstring_03B928`), `world_map_route_table` | ids dropped, "old header read" clauses and the CORRECTIONS section removed; comments 238340, 238372, 238469, 239265 |

Applied: 83 entries (41 block notes, 22 part notes, 20 comments) in 42 files, plus the one follow-up block-note edit in `town_door.asm`.
DISPUTED: 0.
SKIPPED:
- `sFA_diary_menu.asm` line 34 (`OQ-I026-1`): build-mode sentence, waits for Part 2. No comment was written on any forbidden tag; the transform-hazard list of section 6.3 was not touched (only block notes and the `DiaryUnused24B_noref` part note changed in that file). No part note was added on `diary_band_slot1` / `diary_band_empty`.
- The ids in `spm_darkspace_sprites.sprite.asm` (`OQ-B001`): IT-10.
- `interaction_handlers.asm` line 18 "the wram map calls it push-in-progress": a docs cross-reference, not narration; left as is. `StandardEnemyDefeatHandler`, `SpawnFieldRevealEffect`, `sFB_boot_logo`, `sFC_title_*`, `palette_bundles`, `reward_actors`, `mode7_perspective`, `SpawnItemSparkleEffect`, `inventory_statue_slot`, `player_move_main`: no hit left in the live files (cleaned by IT-08, IT-09, IT-12 or earlier).
- Runtime-word hits listed under "Sweeps".
BLOCKED: 0. `world_map_route_table.asm` resolved its bank fine in the dry-run.

## Dry-run summary (IT13_spec.json)

```
[DRY RUN] 14 notes file(s) would change; nothing written.
  notes/blockNotes/bank00,02,03,08,0A,0B.json
  notes/partNotes/bank00,03,08,0B.json
  notes/comments/bank00,03,08,0A.json
OK
```

No `find` mismatch, no transform warning. The real run wrote the same 14 files.

## Follow-up spec

After applying `IT13_spec.json` the id sweep found one id I had left out of the spec: `town_door.asm` line 7 "not verified at runtime (OQ-I043-1)". It is `IT13_spec_b.json` (one block-note edit), dry-run clean, applied, then `extract:lt` and `rebuild` were run again. Gate numbers below are from the second run (the first run gave the same numbers).

## Gate

`npm run extract:lt`, then `npm run rebuild` (separate commands; `ROM rebuild completed successfully!`): `artifacts/crc.json` = checksum 223006080, crc 2083230829, totalSize 3062204. Equal to the baseline, after the first spec and again after the follow-up.

## Found outside scope

- `system/world_map/world_map_scene_names.asm` line 5: `OQ-I059-7` (not in the A05 table; a later sweep).
- Remaining whole-tree hits after this iteration: 22 id lines in 12 files and 39 narration lines in 28 files. The `spriteset_*` tables (I069-series ids) and the other tables belong to IT-10 / IT-11; the rest to the residual sweeps IT-23 to IT-25.
- `functions/ApplyPlayerHitstun.asm` and `actors/hit_stagger_controller.asm` still carry a blanket `UNVERIFIED-RUNTIME` sentence (not in a paragraph touched here): IT-23.
- `git status` shows many `extracted/` files and `artifacts/*.json` as modified from `extract:lt` / `rebuild` runs of earlier iterations; this iteration only changed `notes/*/bank*.json` on purpose.
