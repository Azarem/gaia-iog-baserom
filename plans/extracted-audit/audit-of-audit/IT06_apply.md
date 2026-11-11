# IT-06 apply: engine factual defects, I001-I030

Mechanism: `npm run merge` only. Spec: `plans/extracted-audit/audit-of-audit/IT06_spec.json` (one spec, 8 files). The `edit` entries are not repeatable (once applied, `find` no longer matches), so re-running the whole spec reports an error for them instead of `=unchanged`; the full-text sets (`cop_dispatch_table`, `RadarPlotActors`, the three `StatusAbilityRow*` part notes, the `awB2_stair_climb` block note) and the comments are re-applicable.

## Facts re-derived before editing (live `extract:lt`)

- `tile_collision_physics.asm` 1108-1156: `AdvanceTileOffsetY` adds `$10` to the low byte of `$00` (next row, +Y; carry adds `mapRowStrideL0` to the high byte); `AdvanceTileOffsetX` increments the low nibble (next column, +X). The names are right, the sentence "the names are swapped" is false. Line 57 only says the types `$06` / `$09` are not decoded.
- `actor_execution.asm` 157-168 (`RunActors_Normal`): hit flag `$10` bit 7 (`$0080`) set; `iframeCounter` zero clears the flag; negative = `INC` toward zero, then falls into the wait-counter test (the tick runs); positive = `DEC`, store, then `CPX playerActor` / `BEQ` (player continues into the wait-counter test) and otherwise `BRA loc_03CB8C`, which jumps to the next-actor link and skips script dispatch and movement. The same pattern is in `RunActors_DisplayFiltered` and `RunActors_PauseFiltered`. Actors with `$10` bit 13 (`$2000`) take the script path before this test and never reach it.
- Hit counter writers in `combat_collision.asm`: `$12` bit 0 set -> `$FFEF` (negative), clear -> `$0011` (positive) at three places (`PlayerAttackHitTest`, `ApplyHitDamageToVictim_DamagePath`, the `$0001` test at 905); `HitInvincibleVictim` writes `$FFEF`; `ApplyInteractionDamage` writes `$003C` to the PLAYER's counter.
- `SpawnListAppend` (`cop_handlers_spawn.asm` 364-418): the word operand is stored in `$0010,Y` of the new actor. So `$2F00`, `$2B00`, `$2400` are the spawned actor's `$10` flags word, not a priority. `$12` bit `$1000` is set only at `combat_collision` 821-823 (`ORA #$1000` / `STA $0012,Y` after the `$2B00` spawn); `actor_execution` `RunActors_DisplayFiltered` 247-262 tests bit 12 in `$10` or `$12`; `camera_drift.asm` 17 and 55 call it the display / overlay-active qualifier.
- `cop_dispatch_table` (227 entries) read entry by entry against `db-us/copdef.json`: every handler label equals the copdef key of the same id (`$00-$6D`, `$80-$E2`); no label differs, including `$1A-$1E`, `$80-$87`, `$8F-$92` (renamed by IT-04) and `$B6/$B7`.
- `radar_map_screen.asm`: `RadarPlotActors` tests bit 8 (`$0100`) first and calls `RadarPlotFriendlyActor` (enemy dot `$2AE7`), then bit 9 (`$0200`) and calls `RadarPlotEnemyActor` (dot `$280D`). Bit 8: only writer is `InitActorFromSceneData` (`actor_execution.asm` 997-1000, after the stats index and enemy number are non-zero and the enemy is not already defeated; counted in `enemiesRemaining`). Bit 9: `rg` over `extracted/` finds `OrExtraFlags` with `$01xx`-`$03xx` operands only at `dark_space.asm:85` (`DarkSpacePortalInit`, `#$0200`); no `ORA`/`STA` on `extendedFlags` with that bit elsewhere. `dark_space.asm` is the Dark Space portal.
- `RadarScreenSetup` 229605-229615: `STA adhocVramDmaDest` (arms the transfer) before `STA adhocVramDmaSize`; `hdma_dma_spc.asm:27` (`DmaAdhocVramBlock`) says writers store the size first. Whether an NMI can run between the two stores is not traced, so the comment says only the order.
- `ArrangePickTarget` 359-366: `$22` is saved to `$2E` (source), `$22` stays the target cursor; `ArrangePerformSwap` 399-416: the first refresh reads slot `$2E`, the second `$22`; the equipped-tracking tests agree (`$2E` source, `$22` target). So the comments at `{189954}` / `{189971}` were swapped, and so was `{189981}` ("Same: Y = the source slot actor": that call follows `LDY $22`).
- `StatusAbilityRow0/1/2` (`inventory_menu.asm` 856-913): Y = `$0048` / `$0060` / `$0078`, sprite bases `$44` / `$45` / `$46`; `InventoryMenuInit` spawns Row2, Row1, Row0 (143-145, `moveYAlt` = the last = Row0, the top row); the Status hover loop uses rows 0..2. The part notes and nine inline comments still counted rows 3 / 2 / 1.
- `ComputeAbilityIndex`: `characterForm x 4 + slot + 1`; `system_strings.asm` 578-680: entry 0 of `ability_menu_table` and `ability_name_table` is `consolestring_01DB3F` (empty string), entry 0 of `ability_description_table` is `consolestring_01E184` = `Nothing`. So the minimum index produced is 1.
- `awB2_stair_climb.asm`: `WaitOnFlagWord ( #$016B, #01 )` (handler: sense 1 = wait until the flag is set), `LDA #$000A` / `STA $0E`, `JumpFar slider_glide.SliderGlideTriggerNorthMain`. `LockPlayerForClimb` takes `$0E` as the glide length in units of 16 px.
- `palette_bundles.asm`: bundle `$0E` = `palette_bundle_168666` = `< #01, &word_16866D, #F1, #1D, #00 >` (1 frame, 15 words at colour index `$F1`); bundle `$10` = `palette_bundle_168792` = `< #08, &word_168799, #81, #1F, #03 >` (8 frames of 16 words at colour index `$81`, wait 3). Frame 7 of `$10` (words `$70-$7F`) is `$7D8C, $7E10, $7E94, $7F18, $7E10, $7E94, $7F5A, $7E10, $7E94, $7F18, $7E52, $7F18, $7E94, $7F18, $7BDE, $0000`: its first 15 words are identical to the 15 words of bundle `$0E`. BGR555 decode: `$7E10` = R16 G16 B31, `$7F18` = R24 G24 B31, `$7BDE` = R30 G30 B30. Frame 0 begins `$1080, $1008, $104A`. The frames between are not decoded, so the note says "last frame" and "first frame begins", not "fade towards".
- `thinker_execution.asm`: runner letters map to names as in IT-04 (A = `RunThinkers_General`, B = `_Hdma`, C = `_General_Light`, D = `_Hdma_Light`); `RunThinkers_Hdma` is bit 2 set, so "the complement of A" is `RunThinkers_General`.

## Items

| finding id | file:line (live, after merge) | status | note |
|---|---|---|---|
| item 1 | `tile_collision_physics.asm:32` (block note) | APPLIED | Sentence "AdvanceTileOffsetY actually steps ... (rename proposed)." deleted; the preceding sentence stands. |
| item 1 | `tile_collision_physics.asm:57` (block note) | APPLIED | "(audit OQ-16)" sentence replaced by "Collision types $06 and $09 are not traced to a purpose." |
| item 2 | `combat_collision.asm:53` (block note) | APPLIED | One wording: `$FFEF` = negative = recovery (counts up toward zero, the tick still runs); `$0011` = positive = hit-stun (non-player actors skip their tick, the player's tick still runs). "17 frames of invincibility" removed. Added the fact that `RunActors_Normal` handles the counter only for actors without `$10` bit 13. |
| item 2 (same fault, not listed) | `combat_collision.asm:428` (part note `PlayerAttackHitTest`) | APPLIED | "assigns iframe counter ($0011 normal or $FFEF for $0001 flag)" -> the same wording, with the `$12` bit 0 condition. |
| item 2 | `combat_collision.asm:640` (comment, tag 245488) | APPLIED | "victim frozen / keeps moving" -> the one wording. |
| item 2 (same fault, not listed) | `combat_collision.asm:688` (part note `ApplyHitDamageToVictim`) | APPLIED | "Assigns iframes ($0011 or $FFEF)" -> the one wording. |
| item 2 (same fault, not listed) | `combat_collision.asm:751` (part note `ApplyHitDamageToVictim_DamagePath`) | APPLIED | "sets the iframe counter ($FFEF or $0011)" -> the one wording. |
| item 2 | `combat_collision.asm:905` (comment, tag 245934) | APPLIED | "recovery vs invincibility iframes" -> the one wording (text identical to 640). |
| item 2 | `combat_collision.asm:1407` (part note `ApplyInteractionDamage`) | APPLIED | "60-frame iframe counter" -> `$003C` (60), positive = hit-stun, the player is exempt from the skip, longer than combat's `$0011`. |
| item 2 | `combat_collision.asm:1507` (comment, tag 246920) | APPLIED | "60-frame iframe ... longer than combat's 17" -> `$003C = 60: positive = hit-stun counter (...); longer than combat's $0011`. |
| item 2 (priority wording) | `combat_collision.asm:49` | DISPUTED | Live line 49 is the "DEATH HANDLING" paragraph (`HitStaggerMain`, `$0040`, `$0400`); it contains no "priority" wording and no `$1000` reference. Nothing to change there. |
| item 2 (priority wording) | `combat_collision.asm:430` (part note `PlayerAttackHitTest`) | APPLIED | "(priority $2F00)" -> "(spawn flags $2F00)". The word is `SpawnListAppend`'s operand, stored in the spawned actor's `$10`; it is not the `$12` bit `$1000`, and no `$1000` is set on this spawn. |
| item 2 (priority wording) | `combat_collision.asm:686` (part note `ApplyHitDamageToVictim`) | APPLIED | "(priority $2B00 with $1000 in spawned actor's $12)" -> spawn flags `$2B00`, then `$12` bit `$1000` of the spawned actor is set: the display-filter qualifier that lets it run in `RunActors_DisplayFiltered`. |
| item 2 (priority wording) | `combat_collision.asm:821` (comment, tag 245765) | APPLIED | "at $2B00 priority; set $1000 display flag" -> "spawn flags $2B00; $12 bit $1000 (display-filter qualifier) is set on the spawned actor below". |
| item 2 (priority wording) | `combat_collision.asm:1409` (part note `ApplyInteractionDamage`) | APPLIED | "($2400 priority)" -> "(spawn flags $2400)". |
| item 2 | `combat_collision.asm:217` (comment, tag 244729) | APPLIED | Ledger path and `OQ-8` removed: "$0080 in the tested actor's $10 must be set (the bit a victim gets when hit, see iframeCounter); why this test requires it is not traced". No `$8000` text written. |
| item 3 | `cop_dispatch.asm:5` (block note) | APPLIED | "but 19 handler labels differ ... (listed in the table note)" -> "and every handler label is spelled the same as the copdef name of its id". |
| item 3 | `cop_dispatch.asm:68-70` (part note `cop_dispatch_table`, bank 00) | APPLIED | Whole list of differing labels deleted (none differs); first paragraph now "ids and handler label names match copdef.json". Full-text set. |
| item 4 | `radar_map_screen.asm:343` (part note `RadarPlotActors`) | APPLIED | "both names are historical" gone: bit 8 -> `RadarPlotFriendlyActor` plots the stat-bearing enemies still in the actor list; bit 9 -> `RadarPlotEnemyActor` plots the Dark Space portals (only setter `dark_space.asm`, `DarkSpacePortalInit`); bit 8 is tested first. `OQ-63` removed. Full-text set. |
| item 4 | `radar_map_screen.asm:371` (part note `RadarPlotFriendlyActor`) | APPLIED | "(a stat-bearing enemy; the name is historical)" -> "(a stat-bearing enemy) as the enemy dot, tile word $2AE7". |
| item 4 | `radar_map_screen.asm:416` (part note `RadarPlotEnemyActor`) | APPLIED | "(probably a Dark Space entrance, OQ-63; the name is historical)" -> "(a Dark Space portal)". |
| item 4 (OQ-64) | `radar_map_screen.asm:76` (comment, tag 229608) | APPLIED | "the size is written next (ordering hazard, OQ-64)" -> "the size is stored after it (writers should store the size first)". |
| (same sentence as 343) | `radar_map_screen.asm:358` (comment, tag 230177) | APPLIED | "probably Dark Space (OQ-63)" -> "a Dark Space portal", so the comment agrees with the part note; not listed by the finding. |
| item 5 | `inventory_menu.asm:7` (block note) | APPLIED | `StatusAbilityRow2/2/3` -> `StatusAbilityRow0/1/2`. |
| item 5 | `inventory_menu.asm:113` (part note `InventoryMenuInit`) | APPLIED | "the three StatusCharRow actors (...)" -> `StatusAbilityRow` actors, spawn order Row2, Row1, Row0; `moveYAlt` = Row0, the top row. |
| item 5 | `inventory_menu.asm:143` (comment, tag 189416) | APPLIED | "Spawn three StatusCharRow actors for ability rows" -> "Spawn the three StatusAbilityRow actors (Row2, Row1, Row0), one per ability row". |
| item 5 | `inventory_menu.asm:508` (part note `DiscardAttempt`) | APPLIED | "(label is an auto name)" removed. |
| item 5 | `inventory_menu.asm:919` (part note `ComputeAbilityIndex`) | APPLIED | Hedge replaced by what is traced: the +1 means no slot selects entry 0; entry 0 of the name tables is the empty string and of the description table is "Nothing" (`system_strings`). |
| item 5 | `inventory_menu.asm:413` (comment, tag 189954) | APPLIED | `LDY $2E`: "Refresh the source slot ($2E) actor sprite after swap". |
| item 5 | `inventory_menu.asm:421` (comment, tag 189971) | APPLIED | `LDY $22`: "Refresh the target slot ($22) actor sprite after swap". |
| item 5 (same fault, not listed) | `inventory_menu.asm:426` (comment, tag 189981) | APPLIED | "Same: Y = the source slot actor" followed `LDY $22` (target) -> "the target slot actor". |
| item 5 | `inventory_menu.asm:856, 877, 898` (part notes `StatusAbilityRow0/1/2`, 3) | APPLIED | "Ability row 3 / 2 / 1 actor" -> "row 0 (topmost) / 1 (middle) / 2 (bottom)". Y values and sprite bases unchanged. Full-text sets. |
| item 5 (same fault, not listed) | `inventory_menu.asm:859, 861, 868, 880, 882, 889, 901, 903, 910` (9 comments) | APPLIED | Inline comments in the three row actors carried the old row numbers 3 / 2 / 1; now 0 / 1 / 2. |
| item 6 | `awB2_stair_climb.asm:1-3` (block note) | APPLIED | Now a Psycho Slider glide trigger: waits until event flag `$016B` is set, stores `$000A` in `$0E`, `JumpFar` to `slider_glide.SliderGlideTriggerNorthMain`. Label kept. |
| item 7 | `DeathPaletteFadeThinker.asm:3` (block note) | APPLIED | "were not decoded (OQ-I026-4)" replaced by the decoded facts (see above). The frames between the first and the last are not described; the note states the colour indices, the first frame's first words and the last frame, and says which screen elements use the indices is not traced. |
| item 8 | `thinker_execution.asm:34, 38` (block note, 3 edits) | APPLIED | "the complement of A" -> `RunThinkers_General`; "C selects exactly A's set and D exactly B's" -> the runner names; "(TypeA/B)" -> `(RunThinkers_General / RunThinkers_Hdma)`. |
| item 8 | `thinker_execution.asm:167` (comment, tag 250171) | APPLIED | "TypeA processes clear, TypeB processes set" -> the runner names. |
| item 8 | `thinker_execution.asm:197` (part note `RunThinkers_Hdma`) | APPLIED | "as TypeA" -> "as RunThinkers_General". |
| item 8 (same fault, not listed) | `thinker_execution.asm:210, 255, 257` (comments, tags 250219, 250272, 250277) | APPLIED | Runner names instead of TypeB / TypeC / TypeA; "(not deferred)" dropped (undefined term). |
| item 8 (same fault, not listed) | `thinker_execution.asm:285` (part note `RunThinkers_Hdma_Light`) | APPLIED | "TypeB's counterpart" -> "RunThinkers_Hdma's counterpart". |
| A15-09 | `notes/comments/bank00.json` key `"47052"` | BLOCKED | `merge` cannot remove an orphan key. |
| A02-03 | `MenuSelectionHandler.asm` | BLOCKED | Listed as blocked by the iteration prompt. Not attempted. |
| mnemonic text | `system_core.asm` ~510, `scene_lifecycle.asm` 828 | BLOCKED | Listed as blocked by the iteration prompt. Not attempted. |

Applied: 39 rows (47 entries changed by the tool: 7 block notes, 16 part notes, 24 comments, summed from the dry-run lines). DISPUTED: 1 (`combat_collision.asm:49`). SKIPPED: 0. BLOCKED: 3.

## Dry-run summary

```
system/engine/tile_collision_physics.asm: block +0 ~1 -0 =0, parts +0 ~0 -0 =0, comments +0 ~0 -0 =0   (+new ~updated -removed =unchanged)
system/engine/combat_collision.asm: block +0 ~1 -0 =0, parts +0 ~4 -0 =0, comments +0 ~5 -0 =0
system/engine/cop_dispatch.asm: block +0 ~1 -0 =0, parts +0 ~1 -0 =0, comments +0 ~0 -0 =0
system/engine/radar_map_screen.asm: block +0 ~0 -0 =0, parts +0 ~3 -0 =0, comments +0 ~2 -0 =0
system/inventory/inventory_menu.asm: block +0 ~1 -0 =0, parts +0 ~6 -0 =0, comments +0 ~13 -0 =0
angkor_wat/angkor_outer_east/awB2_stair_climb.asm: block +0 ~1 -0 =0, parts +0 ~0 -0 =0, comments +0 ~0 -0 =0
functions/DeathPaletteFadeThinker.asm: block +0 ~1 -0 =0, parts +0 ~0 -0 =0, comments +0 ~0 -0 =0
system/engine/thinker_execution.asm: block +0 ~1 -0 =0, parts +0 ~2 -0 =0, comments +0 ~4 -0 =0
[DRY RUN] 9 notes file(s) would change; nothing written.
OK
```

Totals from the tool: 7 block notes, 16 part notes, 24 comments (47 entries). The dry-run printed no warnings. Files written: `notes/blockNotes/bank00.json`, `bank02.json`, `bank03.json`, `bank08.json`, `notes/partNotes/bank00.json`, `bank02.json`, `bank03.json`, `notes/comments/bank02.json`, `bank03.json`.

## Gate

`npm run extract:lt`, then `npm run rebuild` (separate commands; `ROM rebuild completed successfully!`): `artifacts/crc.json` = checksum 223006080, crc 2083230829, totalSize 3062204. Equal to the baseline. Read back in the re-extracted files: `tile_collision_physics.asm` 32, 57; `combat_collision.asm` 53, 217, 428, 430, 640, 686, 688, 751, 821, 905, 1407, 1409, 1507; `cop_dispatch.asm` 5, 68; `radar_map_screen.asm` 76, 343, 358, 371, 416; `inventory_menu.asm` 7, 113, 143, 413, 421, 426, 508, 856-910, 919; `awB2_stair_climb.asm` 1-3; `DeathPaletteFadeThinker.asm` 3; `thinker_execution.asm` 34, 38, 167, 195-197, 210, 255, 257, 285. `rg` for `Type[A-D]` over `thinker_execution.asm` gives 0 hits; `rg` for `priority`, `historical`, `StatusCharRow`, `auto name`, `rename proposed` over the touched files gives no hit on the lines above.

## Found outside scope (not changed)

- OQ ids still in shipped text of files touched here (IT-12 / hygiene sweep): `combat_collision.asm:17, 210` ("role unresolved, OQ-8"); `inventory_menu.asm:359, 381, 392, 429` (`OQ-I028-1`, `OQ-I028-2`); `radar_map_screen.asm:3, 58, 205, 217` (`OQ-63`); `dark_space.asm:85` comment ("radar dot (OQ-63)"), `dark_space.asm:14` (`OQ-I025-2`) and the "=== CORRECTIONS ===" paragraph at `dark_space.asm:19-21` ("The old header said ..." history narration); `hdma_dma_spc.asm:27` (`OQ-64`); `actor_execution.asm:702` ("see audit OQ-15"); `actor_execution.asm:198` ("The flag's name is unverified: docs/wram-memory-map.md calls it \"player-hit\""); `player_character.asm`, `player_transition_handlers.asm:16` and `NpcDespawnStub.asm:3` (`OQ-I025-*`, "the old comment said ...").
- `radar_map_screen.asm:3` (file header) still says the bit-9 dots are "probably Dark Space entrances"; the part notes now say "Dark Space portal". Header text is for the sweep.
- Other iterations that touch the same facts: the ACTION_PLAN prompt that owns `EnemyDefeatDispatch.asm` (A04-05) asks for the same wording as here for `$12` `$1000`: "display-filter qualifier that lets the actor run in `RunActors_DisplayFiltered`", not a draw priority; and the prompt with A12-03 (sign of the hit counter in `combat_collision.asm` ~53 and ~751) can record "already correct": the block note line 53 and the `ApplyHitDamageToVictim_DamagePath` part note (751) now say positive = hit-stun, negative = recovery.
- `EnemyDefeatDispatch.asm:10` "priority boost on the flash" for the `$12` `$1000` bit (the display-filter qualifier, same fault as item 2's priority wording) and says "the old header said ..." (history narration).
- `combat_collision.asm:580, 833, 1207` call `$0080` "iframe-active"; the bit is the hit flag that the iframe counter test in `RunActors_Normal` reads, so the label is close but not the wording used in this iteration (not changed: not in the item list).
- `docs/` pages were not searched for the old statements (hit-stun / "17 frames of invincibility", "AdvanceTileOffset names swapped", radar names "historical", `StatusCharRow`); a docs iteration should check them.
