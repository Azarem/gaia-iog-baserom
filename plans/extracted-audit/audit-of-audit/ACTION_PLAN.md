# Action plan — fixes from the audit of the audit (Parts 1 and 2)

Date: 2026-10-29. Source: `A01_findings.md` … `A15_findings.md`, the F/T steps of `PLAN.md`, and `report.md` (AP-01…AP-23).
**Part 1 (IT-01…IT-16, §3–§9)** covers everything the findings of A01–A07 say should be done with notes, names and docs under the existing tooling. **Part 2 (IT-17…IT-53, §10–§16)** covers A08–A15: the I069–I072 clean-up (A08), the notes-JSON sweeps and orphan prune (A09, A10), the doc reconciliation (A11), the OQ registry (A12), generic labels (A13), the mnemonic/struct/copdef consolidation and F06 (A14), the tooling steps T01–T04 (A15), and the carry-forward items of §8. Part 2 is the only part that edits tools (`src/`, `gaia-core/`) and the user-owned JSON files, and only where an iteration says so.

Nothing in this file has been executed. Each iteration below is one chat, run by an agent, and ends with a gate run and an `IT<NN>_apply.md` file.

---

## 1. How to use

1. Open a **new chat** in the multi-root workspace (`gaia-snes.code-workspace`).
2. Paste the **Fix preamble** (§3) and then **one iteration prompt** (§5) as a single message. Do not combine iterations. For Part 2 the prompts are in §12; mechanisms M, N, D and R use the Fix preamble (§3) as it stands, mechanisms T and U use **Preamble B** (§10.2) instead.
3. When the agent finishes: read `IT<NN>_apply.md`, check the status row in §2, commit yourself.
4. Run the iterations in the order of §2 unless a "Depends on" cell says otherwise. Notes iterations need no decision from you except where §4 lists one.

Findings files are linked from every prompt. The agent reads the cited finding ids in full: they carry the evidence, the live `file:line` and the proposed fix. The prompts only give the scope, the order of work and the traps.

---

## 2. Iteration index and status

Mechanism: **M** = `npm run merge` (notes and comments), **N** = `npm run names`, **D** = manual doc edits (`StrReplace`); Part 2 adds **T** = tool edit (`src/`, `gaia-core/`), **U** = user-owned JSON edit (`mnemonics.json`, `copdef.json`, `structs.json`, `blocks.json`, `types.json`, `overrides.json`, `transforms.json`), **R** = new report/registry file only. Gate = `extract:lt` + `rebuild` must give 223006080 / 2083230829 / 3062204 (M and N only; D needs `npm run names -- --check`) **until IT-27 (T01) is DONE**; after that the newest `GATE` line of the Progress log is the gate (see §10.3).

| ID | PLAN step | Title | Mech. | Depends on | Status |
|---|---|---|---|---|---|
| IT-01 | F01 | `scene_script.asm` notes: opcode table, `SpcMusicLoadCmd`, handler headers, `table_018000` | M | none | [x] DONE (`IT01_apply.md`) |
| IT-02 | F02 | Timing wording: `WaitByte` / wait counter n+1 (engine, actors, functions) | M | none | [x] DONE (`IT02_apply.md`) |
| IT-03 | F04 | "barrier" wording and the chest table (`scene_lifecycle`, `scene_chest_table`) | M | none | [x] DONE (`IT03_apply.md`) |
| IT-04 | F03 part 2 + new | Name renames that are clear now (`FacingData_*`, `RunThinkers_*_Next`, `StagePlayerSpriteMove*`) | N | decision U1, U2 | [x] DONE (`IT04_apply.md`) |
| IT-05 | F03 part 1 | Retired nicknames and `body_table`, `slider_glide`, player-sprite notes | M | IT-04 | [x] DONE (`IT05_apply.md`) |
| IT-06 | new (A02/A01/A04 "F07") | Engine factual defects, I001–I030 | M | IT-04 | [x] DONE (`IT06_apply.md`) |
| IT-07 | new (A03 "F07") | Actor and thinker factual defects, I031–I040 | M | none | [x] DONE (`IT07_apply.md`) |
| IT-08 | new (A04 "F07") | Factual defects, I041–I050 (incl. `mode7_perspective`) | M | IT-04 | [x] DONE (`IT08_apply.md`) |
| IT-09 | new (A05 "F07") | Factual defects and timing, I051–I060 | M | decision U3 | [x] DONE (`IT09_apply.md`) |
| IT-10 | new (A06 "F07") | Tables I061–I064 and the four `spm_*` maps, complete clean-up | M | IT-05 | [x] DONE (`IT10_apply.md`) |
| IT-11 | new (A07 "F08") | Tables I065–I068, complete clean-up, plus three actor comments | M | IT-01, IT-10 | [x] DONE (`IT11_apply.md`) |
| IT-12 | new | Hygiene sweep 1: history narration, ledger ids (I001–I040 files) | M | IT-01…IT-07 | [x] DONE (`IT12_apply.md`) |
| IT-13 | new | Hygiene sweep 2: history narration, ledger ids (I041–I060 files) | M | IT-08, IT-09 | [x] DONE (`IT13_apply.md`) |
| IT-14 | F05 part 1 | Docs: scene/table names (`table_018000`, "barrier", `itemget_*`, scene-meta opcodes) | D | IT-01, IT-03 | [x] DONE (`IT14_apply.md`) |
| IT-15 | F05 part 2 | Docs: `$0B22` / `hpToHeal`, `will_alt`, WRAM and `deathFlag` rows | D | IT-05 | [x] DONE (`IT15_apply.md`) |
| IT-16 | F05 part 3 | Docs: COP families, structs, SetOnInteract, zoom-out timing | D | IT-09, IT-10 | [x] DONE (`IT16_apply.md`) |
| **Part 2, phase A: notes, tagged gate** (run after the Part 1 iteration it depends on) | | | | | |
| IT-17 | new (A10 "F10") | `scene_script.asm` second pass: rows `$10/$13/$14/$15`, ring buffer, script-pointer mapping | M | IT-01 | [ ] |
| IT-18 | new (A09/A10) | Wait wording: residual sweep and verification of IT-02 | M | IT-02 | [ ] |
| IT-19 | new (A12 + A08) | Notes that contradict the code: `Bg3TilemapVramDma` consumer, HUD bit, `$0200` reader, stale dictionary names | M | IT-06, IT-07, IT-11 | [ ] |
| IT-20 | new (A08) | I069–I072 sprite sets without hidden groups, `body_table` row `$06` | M | IT-05 | [ ] |
| IT-21 | new (A08) | I069–I072 string and list tables (`system_strings`, dictionaries, reward table, thinkers) | M | IT-11 | [ ] |
| IT-22 | new (CF-7) | Static checks that no A-step did (enemy census, `Projectile*`, chain ends, ramp watch, `PaletteStep`) | M, R | IT-02, IT-11 | [ ] |
| IT-23 | new (A09) | Residual sweep banks 00–01: narration, ids, hedges, buttons | M | IT-12, IT-13 | [ ] |
| IT-24 | new (A10) | Residual sweep banks 02–03 | M | IT-12, IT-13 | [ ] |
| IT-25 | new (A10) | Residual sweep banks 04–1E | M | IT-12, IT-13 | [ ] |
| **Part 2, phase B: tools, transforms, orphans** | | | | | |
| IT-26 | T04 (A15 "F11") | Extract/rebuild hygiene: no `rm -rf`, state marker, `crc.json` mode | T | none | [ ] |
| IT-27 | T01 | Tag-tolerant transforms, one build mode, **new gate baseline** | U | decision U8 | [ ] |
| IT-28 | T03 | `merge --check`, `merge --prune`, transform guard | T | IT-27 | [ ] |
| IT-29 | F11 (A15-20) | Notes that describe the plain-versus-tagged build difference | M | IT-27 | [ ] |
| IT-30 | A02-03 | `MenuSelectionHandler.asm`: anchor the transforms, merge the corrected notes | U, M | IT-27, IT-28 | [ ] |
| IT-31 | new (A09) | Orphan keys, bank 00: re-key or prune | M | IT-28 | [ ] |
| IT-32 | new (A10) | Orphan keys, banks 01–1E: re-key or prune, duplicates | M | IT-28 | [ ] |
| IT-33 | T02 | Hidden sprite groups: `[@N]` extractor notation | T | IT-27, clean git state | [ ] |
| IT-34 | new (A08, A15) | Sprite notes that T02 makes stale or wrong | M | IT-33 | [ ] |
| **Part 2, phase C: questions, names, mnemonics** | | | | | |
| IT-35 | new (A12) | OQ registry document and static answers | R | none | [ ] |
| IT-36 | F06 (A13) | Names group 1: functions, actors (F) and entry stubs (E) | N | none | [ ] |
| IT-37 | F06 (A13) | Names group 2: diary-window DMA (W), diary menu (D), Gaia / Dark Space (G) | N | IT-36 | [ ] |
| IT-38 | F06 (A13) | Names group 3: inventory, player move, overlay (I), scene script, collision, slope (S) | N | IT-37 | [ ] |
| IT-39 | F06 (A13) | Names group 4: sprite-set data (T) | N | IT-38, decision U13 | [ ] |
| IT-40 | F06 (CF-5) | Gated rename rows: re-triage after the OQ document | N, R | IT-35, IT-39 | [ ] |
| IT-41 | F06 (A14) | Mnemonic renames, batch 1 (clearly wrong, no patch hits) | U | decision U14 | [ ] |
| IT-42 | F06 (A14) | Mnemonic renames, batch 2 (`gfxCacheIdx*`) and batch 3 (cross-repo) | U | IT-41, decision U15 | [ ] |
| IT-43 | F06 (A14) | `copdef.json` renames C01–C08 | U | IT-41 | [ ] |
| IT-44 | F06 (A14) | Mnemonic appends, batch A (small, local) | U | IT-41 | [ ] |
| IT-45 | F06 (A14) | Mnemonic appends, batch B (wide or ambiguous) | U | IT-44 | [ ] |
| IT-46 | F06 (A14) | `structs.json`, `types.json`, `overrides.json`, `blocks.json` rows | U | IT-33 | [ ] |
| IT-47 | F06 (A14, A13) | Notes after the renames: stale names, apologies, hedges | M | IT-41…IT-46 | [ ] |
| IT-48 | F06 (A14) | Notes: wording for the 12 multi-meaning mnemonics, alias notes | M | IT-47 | [ ] |
| **Part 2, phase D: docs** | | | | | |
| IT-49 | F05 (A11) | Docs: data tables, structs, code README | D | IT-14, IT-16, IT-36 | [ ] |
| IT-50 | F05 (A11) | Docs: `docs/code/bank00` and banks 08/0A/0C | D | IT-15, IT-41 | [ ] |
| IT-51 | F05 (A11) | Docs: `docs/code/bank02/03`, COP families, WRAM map | D | IT-50, IT-43 | [ ] |
| IT-52 | F05 (A11, A15) | `gaia-core` docs and `gaia-knowledge/curated` | D (Preamble B) | IT-28, IT-36 | [ ] |
| **Part 2, phase E** | | | | | |
| IT-53 | new (A11, A12, A15) | Close-out: errata, final checks, `PLAN.md` status, parked list | R, D | all | [ ] |

Findings files use the labels "F07" (A02–A06), "F08" (A07), "F10" (A10) and "F11" (A15) for batches that `PLAN.md` never defined. In this plan those batches are the IT-numbers above.

### Progress log
(The agent appends one line per finished iteration: date, gate numbers, skipped items. IT-27 additionally appends a line that starts with `GATE:` and holds the new baseline numbers; see §10.3.)

- 2026-10-29 IT-01: gate 223006080 / 2083230829 / 3062204 (unchanged); applied 15 items (1 block note, 6 part notes, 4 comments), disputed 0, skipped 0, blocked 2 (`EquippedIcon.patch.asm:474` stale `?INCLUDE`; docs to IT-14); outside scope listed in `IT01_apply.md`.
- 2026-10-29 IT-02: gate 223006080 / 2083230829 / 3062204 (unchanged); applied 31 rows (34 notes/comments in 11 files, incl. 8 same-fault lines the finding did not list and the `town_door` `#0A` comment), disputed 0, skipped 0, blocked 0; not-verified: PaletteStep "wait 2" (data field, not provably wrong), run window = 13 later passes (report only); outside scope listed in `IT02_apply.md`.
- 2026-10-29 IT-03: gate 223006080 / 2083230829 / 3062204 (unchanged); applied 6 rows (5 notes/comments in 3 files, incl. the `warps_interaction.asm:180` "barrier cell" comment the finding did not list), disputed 0, skipped 2 (lines 828 and 237, by instruction), blocked 1 (docs, IT-14); the live text said "barrier collision tiles" / "place barriers", not "barrier/chest"; narration hits left for IT-12 listed in `IT03_apply.md`.
- 2026-10-29 IT-04: gate 223006080 / 2083230829 / 3062204 (unchanged); applied 37 name entries in one spec (`apply-IT04_names.json`: 2 `FacingData_*`, 4 `RunThinkers_*_Next`, 3 `StagePlayerMove*`, 5 `FollowChase*` head/apply/trampoline, 14 `ResolveFacing*`, 9 copdef renames C01, C02, C03, C06, C07, C08 that carried `db-us/copdef.json` through the tool), disputed 0, skipped 1 (C05 alias), blocked: C04 `SetMetasprite` (3 patch sources) and the rows the prompt excluded; three copdef names differ from the A14 proposal (`SetTileStreamAnim`, `DrawMetatileStream`/`DrawMetatileStreamDelay`, `SetMoveNegate*`); notes that now read wrongly are listed in `IT04_apply.md` for IT-05/06/47.
- 2026-10-29 IT-05: gate 223006080 / 2083230829 / 3062204 (unchanged); applied 21 rows in one spec (`IT05_spec.json`: `body_table` complete clean-up (8 rows: nicknames, row 8 fact, bit-15 wording, rows `$05`/`$07`, narration, ids), `slider_glide` 8, `cop_handlers_player_sprite` 4, `GetPlayerFacingDirection` 1; 4 block notes, 3 part notes, 6 comments), disputed 0, skipped 1 (`slider_glide` mnemonic note, Part 2), blocked 1 (docs with `will_alt`, IT-15); outside scope listed in `IT05_apply.md` (row `$06` text for IT-20, history narration in three `spriteset_*` notes, `GetPlayerFacingDirection` row-8 sentence).
- 2026-10-29 IT-06: gate 223006080 / 2083230829 / 3062204 (unchanged); applied 39 rows in one spec (`IT06_spec.json`: 7 block notes, 16 part notes, 24 comments in 8 files; includes same-fault lines the prompt did not list: hit-counter and spawn-flags wording in four `combat_collision` part notes, the `{189981}` swapped comment, nine `StatusAbilityRow` inline comments, the radar comment at `{230177}`, four `thinker_execution` comments), disputed 1 (`combat_collision.asm:49` has no "priority" text), skipped 0, blocked 3 (orphan key `47052`, `MenuSelectionHandler.asm`, mnemonic text); outside scope listed in `IT06_apply.md` (OQ ids left in `combat_collision`, `inventory_menu`, `radar_map_screen`, `dark_space`, `hdma_dma_spc`, `actor_execution`; `EnemyDefeatDispatch` "priority boost"; docs not searched).
- 2026-10-29 IT-07: gate 223006080 / 2083230829 / 3062204 (unchanged); applied 9 items in one spec (`IT07_spec.json`: 5 block notes, 1 part note, 6 comments in 6 files; includes 4 same-fault `interaction_handlers` comments with the "15 px" off-by-one), disputed 1 (A03-05: only `RampEastWatch` and `RampNorthWatch` have the dead `BPL`; West and South do not), skipped 0, blocked 0; outside scope listed in `IT07_apply.md` (the actor `$0200` bit IS read by `combat_collision` mask `$76E0`, so the `StopPlayerOnDeath.asm {62402}` comment and the `ramps` "reader unknown" lines stay wrong until IT-19; `UNVERIFIED-RUNTIME` and narration lines for IT-12; `player_query.md` for IT-16).
- 2026-10-29 IT-08: gate 223006080 / 2083230829 / 3062204 (unchanged); applied 14 rows in one spec (`IT08_spec.json`: 5 block notes in 8 edit pairs, 5 comments in 5 files: `SpawnItemSparkleEffect` reachability via `DropBodyHeal5` / `InteractionDamage_NPCChat`, `jeweler_gem` interact button and real dialogue quote, `EnemyDefeatDispatch` `$12` bit `$1000` wording as in IT-06, `mode7_perspective` `RunThinkers_Hdma` / `scanline_band_hdma_thinker` / ids and history removed, `dialog_string_scanner` `$0100` = hit + 1, resume = hit + 4), disputed 0, skipped 1 ("B cancel" text by instruction), blocked 0; part notes of `SpawnItemSparkleEffect` and `EnemyDefeatDispatch` carry none of the faults (no change); outside scope listed in `IT08_apply.md` (history narration and OQ / `UNVERIFIED-RUNTIME` text left in these files and in `EnemyDropSystem`, `overworld_exit`, `hit_switch`, `idle_sprite_display`, `inventory_mgmt` for IT-13; two more paraphrase quotes in `jeweler_gem`).
- 2026-10-29 IT-09: gate 223006080 / 2083230829 / 3062204 (unchanged); applied 9 findings in one spec (`IT09_spec.json`: 7 block notes, 28 part notes, 18 comments in 7 files: zoom-out = 44 passes, 2 ticks per pass, about 88 ticks (re-traced, `$B8` sum -972 kept); route-step comments renumbered 0-3 as in the route table, `SetEntryHere` does not yield, "Z" = rotation; `$1C`-`$1F` unused but reachable, `$20`-`$26` unreachable (mask), 11 `WorldMapMenu_Empty*/Nothing26` notes; n + 1 wording; "Ankor Wat" prose in `world_map_options`; wait operands with ticks; Aura cluster per U3; PAL lockout skipped by `Utils.patch.asm`; `palette_padding_*` hedged), disputed 0, skipped 0, blocked 2 (docs `radar-and-world-map.md` to IT-16; R-I056-8 per U3); outside scope listed in `IT09_apply.md` (route steps overlap by one tick, so "n + 1 ticks" is exact for deltas only; the retranslation stages choice id `$1C`; ids and history narration left in touched blocks for IT-13).
- 2026-10-29 IT-10: gate 223006080 / 2083230829 / 3062204 (unchanged); applied the A06 findings 02-09, 12, 13, 14, 16, 17 and A07-03 in one spec (`IT10_spec.json`: 16 block notes, 11 part notes, 16 files; 17 ids and 224 lists in `scene_actors`, six `$FF` statue slots, hold `$63` = 100 ticks, `eu97_dark_medicine` second writer of `$0B1C`, inclusive ranges, staging wording written once for freedan / will / shadow:7, `tile_collision_physics` reader in 5 places, live `spm_*` labels, `cameraBoundsY` store), disputed 0, skipped 1 (A06-20 chain-end counts kept, not re-derived), blocked 1 (A06-21 `blocks.json` types); outside scope listed in `IT10_apply.md` (`spriteset_shadow` header range and narration for IT-11; `fr32_laborer_npc` header "walking laborer"; unprefixed `spm_*` names in other files; `structs-reference.md` for IT-16).
- 2026-10-29 IT-11: gate 223006080 / 2083230829 / 3062204 (unchanged); applied 21 rows in one spec (`IT11_spec.json`: 11 block notes, 10 part notes (+1 new, -1 removed), 3 comments in 14 files; Aura palette cycling `$A1-$A8` (bundle #5B), `transform_pose_0C`, three `npc_props` users, `FieldRevealFromActorStats` second reader of byte +3, `$0020` boss bit, template cursor reload from `$0998` (table note and `DialogCmd_InsertTemplate`), `[TPL:11]` 37 uses, tilemap layer 0 / 1, projectile names, old `table_17D000` / `table_179000` names and "3-frame" in three actor texts, `reviveWarpPtr`, history / OQ ids / process narration removed from 11 files, inclusive end addresses in 11 headers incl. `spriteset_shadow`), disputed 0, skipped 4 (`body_table:32` and docs, A07-21 struct name, other-iteration items, `parallax_scroll_table` clean); the "Animation $0C" note was stored under `transform_pose_0B` and was moved to `transform_pose_0C` (the finding placed it correctly); outside scope listed in `IT11_apply.md` (OQ ids left in `player_character.asm`; `scene_warps.asm:5` wording).
- 2026-10-29 IT-12: gate 223006080 / 2083230829 / 3062204 (unchanged); applied 156 entries in one spec (`IT12_spec.json`: 52 block notes, 39 part notes, 65 comments in 57 files in `system/engine`, `system/player`, `system/inventory`, `sFB_boot_logo`, `functions`, `actors`, `thinkers`); id sweep over `extracted/` 231 -> 87 (3 left in the edited files: `item_use_system` 37 / 368 / 450, skipped), narration sweep 172 -> 107 (0 narration left in the edited files); `OQ-I034-1` answered (displayModeFlags bit 14 = bit 6 of `hudDisableFlag` `$09ED`, HUD off) in `sFB_boot_logo` and `inventory_overlay`, and the `ramps.asm` "reader unknown" for actor `$10` bit `$0200` replaced by the `combat_collision` `$76E0` / `$74E0` masks (both are IT-19 items A12-02 / A12-04); disputed 0, skipped `item_use_system` 37 / 368 / 450, `MenuSelectionHandler`, `DialogStringRenderer`, blocked 0; outside scope listed in `IT12_apply.md` (`cop_handlers_actor_flags.asm:75` false COP-name sentence for IT-47, blanket `UNVERIFIED-RUNTIME` in `player_move_*` for IT-23, ids / narration left in `player_transition_handlers`, `overworld_exit`, `layer1_scroll_actors`, `field_reveal_object`, `global_ambient_dispatcher` and the table files for IT-13 / IT-21).
- 2026-10-29 IT-13: gate 223006080 / 2083230829 / 3062204 (unchanged, checked after the main spec and after the follow-up); applied 83 entries in one spec (`IT13_spec.json`: 41 block notes, 22 part notes, 20 comments in 42 files of the I041-I060 sets) plus one follow-up id in `town_door` (`IT13_spec_b.json`); whole-tree id sweep 87 -> 22, narration sweep 107 -> 39, 1 id left in the 56 scope files (`sFA_diary_menu` line 34, build-mode sentence, skipped by instruction), 0 history narration (7 runtime-word hits kept); `=== CORRECTIONS ===` sections removed from `dark_space`, `sE6_gaia`, `world_map_route_table` and `boot_logo_enix_palette_obj0|1|2` after checking each fact against the rest of the file, `game_over_sequence` section kept as `=== JOYPAD MASKS AND SOUND ===`; disputed 0, skipped `sFA_diary_menu:34`, `spm_darkspace_sprites` ids (IT-10), blocked 0; outside scope listed in `IT13_apply.md` (`world_map_scene_names.asm:5` `OQ-I059-7`; blanket `UNVERIFIED-RUNTIME` in `ApplyPlayerHitstun` and `hit_stagger_controller` for IT-23).
- 2026-10-29 IT-14: no gate (docs only); `npm run names -- --check` OK (3510 names); applied 40 rows in 10 docs (`structs-reference.md`, `bank01-data-tables.md`, `code/README.md`, `code/bank0D-scene-meta.md`, `code/bank02/{scene-script,game-systems,player-character,README}.md`, `code/bank03/{text-and-menus,field-input-and-items}.md`: `table_018000` / `itemget_table_01FD24` / `table_179000` / `table_17D000` renamed, scene-meta opcodes `$04`-`$06` and `$11` (music runs when group EQUALS `musicRoomGroup`, operands are track then group), `$06AA` = `collisionFlagTableL0` flag-table page (not a cached source pointer), chest table "barrier" removed and its record layout rewritten from the code, dialog templates = speaker colour/sound and box presets, music table index = id - 1), disputed 1 (`text-and-menus.md` "item data for equipment icons": the console renderer does not use `item_pickup_text_table`, so the bullet was removed instead of renamed), skipped 1 (rename-map rows, by instruction), blocked 0; 5 same-fault rows added (`scene-script.md` 207-209 / 1058-1074, `game-systems.md` barrier lines, `player-character.md` 99 / 377); outside scope listed in `IT14_apply.md` (`display-preset` byte table in `bank01-data-tables.md` and `structs-reference.md`, prose sections of `scene-script.md` for `$04`-`$06` and `BuildMetatileFlagTable`, retired `table_01*` names, `player-character.md` include tree).
- 2026-10-29 IT-15: no gate (docs only); `npm run names -- --check` OK (3510 names); applied 36 rows in 12 docs (`system-core.md`, `data-tables-memory.md`, `actors-player-rewards.md`, `actors-combat-interaction.md`, `stair-climb-system.md`, `README.md` (bank00), `functions-combat-defeat.md`, `event-flags.md`, `wram-memory-map.md`, `inventory-menu.md`, bank 08 and 0A actor docs: `$0B22` = `hpToHeal` (HP recovery counter, `$0ACE` current HP, not DEF), `will_alt` -> bank `$8F` of `spriteset_will_abilities`, `gfxLoadParams` -> `gfxSrcStart` / `gfxSrcEnd` / `gfxDestPage` / `gfxLayerFlags` (four words, `$0664`-`$066B`), `inventorySlots` = 16 bytes `$0AB4`-`$0AC3`, `wramFlags` cleared only by `ClearAllWramFlags` callers and `game_over_sequence` (not at scene boundaries), `$0B28`-`$0B33` = `hieroglyphSlots` (six plate words, not "save/warp metadata"), `UpdateFrameFull` = run by the NMI while `musicTransitionState` is positive (SPC upload), "formerly / previously misnamed" removed, six `SetOnInteract` -> `SetInteractHandler`), disputed 0, skipped 1 (`script_control.md` alias, by instruction), blocked 0, no edit needed for `deathFlag` / `collisionLayerBase` in docs (A01 rows 54, 8, 58); 14 same-fault rows added; outside scope listed in `IT15_apply.md` (`$0AE4` timer `$001E` vs code `$3C` in three docs, `UpdateFrameCounters` timer text, `nmi-handler.md` `$06FA ≠ 0` gate wording, `bank00/README.md:420` range).
- 2026-10-29 IT-16: no gate (docs only); `npm run names -- --check` OK (3510 names); applied 31 rows in 16 docs (`cop/families/{player_query,collision_branch,hdma_dma,force_move,sine_hdma,vram_memory,dialog,audio,gravity,camera}.md`, `cop-commands-reference.md`, `code/bank02/game-systems.md`, `wram-memory-map.md`, `code/bank03/{radar-and-world-map,movement-and-collision}.md`, `structs-reference.md`: `BranchOnPlayerX/Y` operands W,Here,E / N,Here,S and the 11 handler ranges, `QueueHdmaDirect` = direct-table HDMA (not linear DMA), force-move operand = `move_chain_table` index (not frame duration / SW-NE), sine-HDMA operand 2 = wave period, `musicParentActor` = current music index, gravity `g - v0` and landing conditions, camera pan Up/Left negate-and-resume and strict `<` stop, zoom-out = 44 passes at 2 ticks = about 88 ticks, damage formula `totalStr = playerStr + climbStateData+2 + climbStateData` (no `previousDamage`), `display-preset` +0..+7 rewritten from `SceneCmd_ConfigDisplay`, `direction-velocity` = animation index + `move_chain_table` index, `sprite-set` = `< hold, &group >` with hidden `$FFFF`, retired `table_*` / `dir_sprite_01ABDE` names replaced); disputed 3 (`cop/README.md` rows already correct; the finding's `cop_handlers_metatile.asm` / `BranchOnPlayerFacing` attribution; "13-byte group header" is correct, only its content was wrong), skipped 0, blocked 0; 11 same-fault rows added; outside scope listed in `IT16_apply.md` (`actor_flags.md` / `offscreen.md` / `metatile.md` wrong files and ranges, `bank01-data-tables.md` display-preset and retired names, `camera-scroll-system.md` "animation duration", `table_0EE000` and `chunk_03BAE1` in about 25 docs).

---

## 3. Fix preamble (paste first, every time)

```text
You are running ONE fix iteration of the "audit-of-audit" action plan for the Illusion of Gaia baserom (workspace folder gaia-iog-baserom; plan folder plans/extracted-audit/audit-of-audit/).

Read first, in order:
1. plans/extracted-audit/audit-of-audit/ACTION_PLAN.md: section 6 "Ground rules" and the section of YOUR iteration only.
2. The findings files named in your iteration. Read each cited finding id in full (they carry file:line evidence and the proposed fix).
3. gaia-core/docs/notes-and-comments.md sections "Notes Merge", "Merge spec format and iteration files" (and "Names Merge" if your iteration changes names).
4. gaia-knowledge/curated/gaialabs/assembler-syntax.md before you quote any asm in a note.

Hard rules:
- Never run git commit, push, tag, merge, rebase, reset, revert or any history-changing git command. git status, diff, log and add are allowed. At the end say "Please commit when you're ready." with a suggested message.
- Do not use sub-agents (no Task tool).
- Do not write or run throwaway scripts (.py .mjs .js .sh PowerShell). Use Grep, Glob, Read, StrReplace, Write. The only shell commands allowed: rg, npm run extract:lt, npm run rebuild, npm run merge, npm run names, npm run names -- --check, git status/diff/log. Never use the retired ingest or annotate commands. Never add ?BANK to extracted files. Never run npm run ingest:all.
- Notes and comments change only through npm run merge -- <spec.json> (dry-run first). Names change only through npm run names -- <spec.json> (dry-run first). DOCS iterations edit docs/ only, by hand with StrReplace. If the tool cannot do what is needed, say so and stop; do not work around it.
- You may NOT edit: transforms.json, overrides.json, blocks.json, files.json, mnemonics.json, copdef.json, structs.json, types.json, src/, gaia-core/, baserom/ patch sources, or any frozen ledger (results/, renames/, questions/, edits/ files that already exist, checklist.md, A*_findings.md, report.md, digest_*.md). If a finding needs one of them, list it in the apply file under BLOCKED and move on.
- Be patient: no stubs, no simplifying. If you make a mistake, do not fall back to an older method; stop and ask me.
- Evidence ladder: E1 code trace, E2 cross-reference, E3 docs, E4 hardware docs, E5 runtime. No Mesen2 ROM or state exists, so every behavioural claim is static. Do not write a runtime claim into a note.
- Findings were made in an earlier session. BEFORE writing any item: run npm run extract:lt once, read the live target lines, and re-derive the fact from the code. Line numbers are hints; locate by label or text. If the live code disagrees with the finding, do NOT write the finding's wording: mark the item DISPUTED in the apply file with your evidence, and continue.
- Writing style, rebuild gate, transform hazards and the apply-file format are in ACTION_PLAN.md section 6. Follow them.
- Quote COP/DP facts only as the code shows them (AGENTS.md hazards apply if you quote code).
- Procedure: (1) read targets; (2) write ONE spec for the iteration; (3) merge/names --dry-run and show me the summary; (4) apply; (5) npm run extract:lt, then npm run rebuild (two separate commands) and compare with checksum 223006080, crc 2083230829, totalSize 3062204 (or with the newest `GATE:` line of the Progress log if one exists: ACTION_PLAN.md section 10.3) (if different: stop, report the numbers and the last file changed, do not fix by editing unrelated files); (6) verify every change by reading the extracted file; (7) write plans/extracted-audit/audit-of-audit/IT<NN>_apply.md; (8) update only your row in ACTION_PLAN.md section 2 (StrReplace) and append one line to the Progress log.
- Final message: counts (applied / disputed / skipped / blocked), the gate numbers, anything you found outside scope, "Please commit when you're ready." and a suggested commit message.
```

---

## 4. Decisions for you

None of these blocks the start. The default is what the iteration does if you say nothing.

| ID | Question | Used by | Default |
|---|---|---|---|
| U1 | Names for `FacingData_WillAlt` (`db-us/names/bank03.json:473`, address 258431) and `FacingData_AbilityFx` (`:474`, address 258458). They encode retired nicknames. | IT-04 | The agent proposes names that follow the block names and **waits for your approval** before applying. |
| U2 | Three handler labels `StagePlayerSpriteMoveX/Y/XY` differ from the copdef spelling `StagePlayerMoveX/Y/XY` (A01 F5). Rename the labels (names tool) or the copdef (your file)? | IT-04, IT-06 | Rename the **labels**; the copdef is not touched. |
| U3 | The `DS_AuraItemRoom` cluster is called "no reference anywhere", but `baserom/patches/APUWaitFixes.patch.asm:392-416` rewrites `AuraItemGrant!` and uses its labels (A05-03). How should the cluster be described? | IT-09 | Write "no reference in extracted code; `APUWaitFixes.patch.asm` rewrites `AuraItemGrant` and uses these labels". No "Dead:" marker, no rename. R-I056-8 stays blocked. |
| U4 | `baserom/equipped-icon/EquippedIcon.patch.asm:474` has `?INCLUDE 'table_018000'` (retired name, A07-17). Patch sources are not edited by these iterations. | IT-11 | Reported only. |
| U5 | Spelling "Ankor Wat" (in-game strings) versus "Angkor Wat" (labels and some notes) (A05-12). | IT-09 | Quoted game text and prose use the in-game spelling; labels are not renamed. |
| U6 | The throwaway scripts in `temp/` (A04-11, A05-15) and the untracked `plans/`. Not part of any iteration. | you | untouched |

Build mode (AP-01 / T01): until IT-27 is DONE, every iteration here uses the recorded **tagged** gate and the hazard list in §6.3. Part 2 decisions U7–U19 are in §11.

---

## 5. Iterations

Each prompt is pasted after the Fix preamble (§3). `IT<NN>` in the preamble means the number of the iteration you run.

### IT-01 — `scene_script.asm` notes (PLAN F01)

Reads: [report.md](report.md) §4 N-1, N-2, N-3 · [A01](A01_findings.md) F1 · [A07](A07_findings.md) A07-01, A07-10, A07-11, A07-12, A07-17 (the `scene_script.asm` and `notes/comments/bank02.json` parts only).

```text
ITERATION IT-01 (PLAN step F01). Targets: extracted/system/engine/scene_script.asm and the matching entries in notes/ (bank02). Mechanism: merge only.

Do, in this order, re-deriving each fact from the handlers first:
1. Block-note opcode table (about lines 15-24): $04 loads palette colours ( < start, end, dest > ), $05 loads metatile sets, $06 loads layer maps, $14 records a label that scene_meta jumps to. The real opcode semantics are summarised in extracted/tables/scene_meta.asm lines 15-27 (A07-10 confirmed the 12 handler names in the jump table are right; only the surrounding text is stale).
2. The part note of the jump table (about line 227) still lists five retired handler names ($04=LoadTilemap, $05=LoadDualTilemap, $06=FullGraphics, $13=ConditionalLoad, $14=Nop). Rewrite it with the live SceneCmd_* names.
3. The four part notes / handler headers that carry the old descriptions: SceneCmd_LoadPalette (about 646, "palette tilemap"), the metatile-set handler (about 687, "tilemaps for both BG layers"), SceneCmd_Label (about 277, "placeholder or padding byte": it is a no-op that skips the label id; the position is what jump/branch target), and the fourth one the table pairs wrongly (find it from the opcode table).
4. SpcMusicLoadCmd: the inline comment on `LDA $musicRoomGroup` (about 1303) is inverted. The code is CMP $06F4 / BEQ loc_028B88 / RTS: EQUAL continues to the load path, a mismatch returns. Fix the comment AND the block-note sentence at about line 75 ("gates loading to prevent redundant transfers"): the redundancy check is CheckSourceCacheHit on $0687. Name $06F4 as "the script's group byte, stored at the top of the routine" (no mnemonic exists; do not invent one).
5. About line 1378: "decompress to VRAM $4000" is wrong, the destination is WRAM $7E:4000 (see the handler header and scene_meta.asm:23).
6. Replace every table_018000 mention in this file (about lines 15, 71, 1159, 1161) and in notes/comments/bank02.json (about keys near 283-284) by display_preset_table where the text means that table.
7. Add one sentence to the block note: the rebuilt tree finds scenes through scene_meta_list via baserom/scene-load/SceneMetaLoad.patch.asm.
No history narration, no OQ ids. Do NOT touch baserom/equipped-icon/EquippedIcon.patch.asm (list its stale ?INCLUDE 'table_018000' under BLOCKED) and do not edit docs (IT-14). Run the dry-run and the gate as the preamble says.
```

### IT-02 — Timing wording, `WaitByte` n+1 (PLAN F02)

Reads: [report.md](report.md) N-4 · [A01](A01_findings.md) F4 (V08, V09) · [A02](A02_findings.md) A02-04 · [A03](A03_findings.md) A03-09 · [A04](A04_findings.md) A04-02, A04-03 and §6 · [A07](A07_findings.md) A07-14.

```text
ITERATION IT-02 (PLAN step F02). Mechanism: merge only. Rule: WaitByte #n / WaitWord #n and a stored wait counter in $08 skip n passes and run on pass n+1, so they wait n+1 ticks. First re-read the runner yourself (actor_execution.asm DEC $08 / BPL pattern at about lines 144 and 180, and cop_handlers_wait.asm) and confirm the rule before editing anything. The correct form already exists in SpawnDebrisBurst.asm lines 1 and 16 and hit_stagger_controller.asm line 10.

Targets (state the operand AND the ticks, e.g. "WaitByte #0F, 16 ticks"):
- warps_interaction.asm: lines about 52 ("11 frames" -> 12 ticks), 509 (#0B), 522 ($48, "72 frames" -> 73), 529 (#48); and the InitWarpTable header about line 647 ("each entry starts with a non-$FF byte": the list ends at the first byte with bit 7 set; all lists use $FF; scene_warps.asm:5 has it right) [A07-14].
- music_actors.asm lines about 122, 125 (#01 = 2 ticks).
- item_use_system.asm block note about line 1826 ("WaitByte one frame": WaitByte #01 = 2 ticks; lines 1745 and 1848 are already right).
- cop_handlers_script_control.asm about line 79 (JumpAfterDelay "waits this many frames") and cop_handlers_player_query.asm about line 112 (COP #27 "delay in frames") [A01 F4].
- player_character.asm about lines 653-655 ("wait 479 frames ($01DF)": 480 ticks) [A02-04].
- RandomPlayerOffset.asm lines about 4 and 18 ("60 frames", $08 = $3C): check against the runner, expect 61 ticks [A03-09].
- hit_switch.asm line about 75 (inline), block note about line 10, and the part note above HitSwitchTriggered ("$0F frames" -> 16 ticks) [A04-02].
- npc_wander_ai.asm about lines 14, 100, 106 ($08 := $78 -> 121 ticks) and camera_drift.asm about lines 21, 89, 171 ($08 := 3 -> runs 4 ticks apart; recompute "lives about 9 frames" and the 3-run span) [A04-03].

Verification only (change text only if you can prove the error from code; otherwise list under NOT-VERIFIED in the apply file): (a) PaletteStep "wait 2 each" in shadow_shimmer.asm, global_ambient_dispatcher.asm, SpawnItemSparkleEffect.asm [A04 section 6]; (b) town_door.asm "WaitWhileOffscreen ( #0A ) every 10 passes" against its handler; (c) player_character.asm lines about 12 and 294-308, 475-477: is the run window 13 or 14 states (A02 section 8)? Report only.

Do NOT edit future_vision_cutscene.asm (not audited; carried forward). The world-map timing items (A05-01, A05-13, A05-14) belong to IT-09 and the Freedan/Will table items (A06-03) to IT-10; do not edit those files here. In item_use_system.asm do not put a comment on the CMP lines at about 388 and 463 (transform hazard).
```

### IT-03 — "barrier" wording and the chest table (PLAN F04)

Reads: [report.md](report.md) N-7 · [A01](A01_findings.md) §6 (history sweep), rows 42 and 87.

```text
ITERATION IT-03 (PLAN step F04). Mechanism: merge only.
1. extracted/system/engine/scene_lifecycle.asm lines about 32, 767, 864 call the chest table a "barrier/chest" table. The table is scene_chest_table and holds chest placement entries only (check extracted/tables/scene_chest_table.asm and the code that reads it). Replace "barrier/chest" by "chest"; keep every other fact. Run rg -n -i "barrier" over extracted/ and decide hit by hit (some "barrier" hits are genuine, e.g. Aura Barrier; leave those).
2. scene_lifecycle.asm line about 17 carries history narration: state the current fact only. Do NOT touch line about 828 ("invincibility timer disabled": it waits for the mnemonic decision in Part 2) and ignore line about 237 (a runtime "previously", not narration).
3. extracted/tables/scene_chest_table.asm line 1 narrates the old note ("The old note ... was wrong"): rewrite it as a plain statement of what the table holds.
Docs (bank01-data-tables.md, docs/code/README.md) are IT-14, not here.
```

### IT-04 — Name renames that are clear now (PLAN F03 part 2 and new)

Reads: [A01](A01_findings.md) rows 36, 64 and 92 and F5 · [A02](A02_findings.md) A02-02 · [A03](A03_findings.md) A03-12 · [A04](A04_findings.md) A04-06 · [A06](A06_findings.md) A06-15 · [report.md](report.md) §3.3 (AP-04) · [A02](A02_findings.md) section 8 (names rewrite `db-us/*.json`, including `transforms.json` keys).

```text
ITERATION IT-04. Mechanism: npm run names only. One spec: plans/extracted-audit/renames/apply-IT04_names.json (array of { address, old, new, row }; address = the decimal `; {n}` tag of the part's first instruction from extract:lt output; old = the label the extracted asm prints now; row = the finding id, e.g. "A02-02"). Dry-run, show me the summary, WAIT for my "go", then apply.

Items:
1. FacingData_WillAlt (names/bank03.json:473, address 258431) and FacingData_AbilityFx (:474, 258458) embed retired nicknames. FacingData_FreedanFx and _ShadowFx (:475-476) still match their blocks. Read blocks.json for the current spriteset block names (spriteset_will_abilities, spriteset_transform_poses, ...) and the extracted GetPlayerFacingDirection.asm, then PROPOSE two names that follow the block names. Show me the proposal and wait for approval before they go into the spec (decision U1).
2. The four thinker-runner sub-labels RunThinkers_TypeA_Next, _TypeB_Next, _TypeC_Next, _TypeD_Next (names/bank03.json:331, 333, 335, 337; used on about 17 lines of thinker_execution.asm) still carry the retired type letters. The parent labels at :330, 332, 334, 336 are RunThinkers_General, _Hdma, _General_Light, _Hdma_Light. Rename each sub-label to match its parent (for example RunThinkers_Hdma_Next). Confirm which letter maps to which parent from the code before writing the spec.
3. Rename the three labels StagePlayerSpriteMoveX/Y/XY (COP handlers $90-$92 in cop_dispatch) to the copdef spelling StagePlayerMoveX/Y/XY (decision U2). Check that the new names do not already exist in names/*.json.
4. Row 64 remainder (A01): FollowChaseDiagQuadrant* (names/bank00.json:805-808) and ResolveFollowDir* (:862-864) were never renamed. Read plans/extracted-audit/renames/I001-I020_rename-proposals.md row 64 for the proposed names. Include them only if the row gives names with evidence you can confirm in the code; otherwise list them under BLOCKED.

Before applying: rg every old name over extracted/, baserom/, db-us/ (especially db-us/transforms.json), notes/, docs/ and src/. npm run names rewrites references in db-us, baserom and docs; if an old name appears as a transforms.json key or inside a patch, stop and tell me. After applying: npm run names -- --check, npm run extract:lt, npm run rebuild (gate), then rg the old names again (expect no hits except intentional history, which you report).
Not in this iteration (list under BLOCKED with the reason): the PROPOSED rows that wait on an open question (A03 section 2: R-I033-1/2/3, R-I034-3, R-I036-6, R-I037-1/3/4, R-I038-1/3, R-I039-2; A02: R-I030-1/2; A01 rows 89 and 95), the actor label awB2_stair_climb (OQ-I023-1), the "Ankor/Angkor" label spelling (U5), and every mnemonic/copdef/struct rename.
```

### IT-05 — Retired nicknames, `body_table`, `slider_glide`, player-sprite notes (PLAN F03 part 1)

Reads: [report.md](report.md) N-5, N-6 · [A01](A01_findings.md) V24, F6 · [A02](A02_findings.md) A02-07 · [A06](A06_findings.md) A06-01, A06-10, A06-11, A06-15 · [A07](A07_findings.md) A07-16 (the `body_table.asm:32` item).

```text
ITERATION IT-05 (PLAN step F03 part 1). Mechanism: merge only. Needs IT-04 applied (use the final FacingData_* names in text).
body_table.asm is cleaned COMPLETELY in this iteration (every finding for that file, so it is edited once). Facts first: read GetPlayerFacingDirection.asm, sprite_composition.asm (about 690-711), actor_pool.asm (about 74-87), player_transition_handlers.asm and the SetPlayerSpriteDirect callers.

1. body_table.asm:
   a. Line about 37 lists the FacingFormOffsetTable forms by retired nicknames (will_alt, ability_fx, freedan_fx, shadow_fx): use the current block names (read blocks.json; the live names include spriteset_will_abilities, spriteset_transform_poses and the shadow aura body set).
   b. Line about 37 also says "rows 0-3 and 8 use FacingDirectionLookup". Row 8 is wrong (A06-01): with playerFlags bit 15 set, $0AC8 = 8 gives index 4, no fallback, and the code reads FacingFormOffsetTable + 8, past the 4-entry table. State that as a fact. Do not claim whether GetPlayerFacingDirection runs while row 8 is active (not shown statically).
   c. Line about 5: "While bit 15 is set, DecomposePlayerSprites reads row +3 / +5": it reads them always; bit 15 only changes where the row number comes from (animScratch2 vs characterForm x 6) [A06-10].
   d. Rows note about lines 30-37: say that row $07 is not selected by any SetPlayerSpriteDirect operand (the only operands are 04, 05, 06, 08) and that sE6_gaia is the only user of row $05 [A06-11]. Re-run the rg from A06-11 yourself.
   e. Line about 32, row $05 "Ability poses and effects": the set is spriteset_transform_poses, selected only by the seven Transform_* scripts of sE6_gaia [A07-16].
   f. Remove the history narration (line about 7 "The old header listed ..."), the "Checked:" paragraph and UNVERIFIED-RUNTIME tag (line about 9), and the ids on lines about 30 and 37 (state the open fact in words).
2. slider_glide.asm lines about 4, 5, 9, 59, 256, 263, 267, 298: replace will_alt with the current block name; line about 263 says "4 = Psycho Slider poses, 5 = ability poses" but body row 4 also holds Psycho Dash, the Spin Dash charge, the flute pose, the hold pose and the credits poses (body_table.asm 31-32), and row 5 is used only by sE6_gaia: fix it; drop the narration at 5 and 9 ("The old comments called these ...", "the old '+/-$20' wording is wrong"). Skip line about 411 (a note about a live mnemonic name; Part 2).
3. cop_handlers_player_sprite.asm lines about 6, 33, 38, 52 (will_alt, ability_fx, shadow_mode, freedan_fx, shadow_fx) and GetPlayerFacingDirection.asm line about 16: current block names only.
Do not rename labels or mnemonics here. Docs are IT-15.
```

### IT-06 — Engine factual defects, I001–I030

Reads: [A01](A01_findings.md) F2, F3, F5, F9 · [A02](A02_findings.md) A02-05, A02-06, A02-08 (note part), A02-02 (prose part) · [A04](A04_findings.md) A04-05 (the `combat_collision.asm` hand-over).

```text
ITERATION IT-06. Mechanism: merge only. Needs IT-04 applied. Re-derive every fact before writing.
1. tile_collision_physics.asm: line about 32 says the names AdvanceTileOffsetY/X "are swapped ... (rename proposed)"; the rename was applied and the code (about 1108-1156) confirms Y steps +Y and X steps +X. Delete the false sentence and the rename clause. Line about 57 cites an audit id: say in words what is unknown (collision types $06/$09 are not traced to a purpose).
2. combat_collision.asm (A01 F3): the hit-stun counter wording is inconsistent at about lines 53, 640, 905, 1407, 1507. Facts from actor_execution.asm about 157-168: a positive counter DECs and, for every non-player actor, skips the whole actor tick (hit-stun); only the player is exempt (CPX playerActor / BEQ); a negative value is the recovery window. Use ONE wording in all places. Also A04-05: the actor flag $12 bit $1000 is the display-filter qualifier that lets an actor run in the display-filtered modes (see camera_scroll_controller.asm:5, camera_drift.asm:14), NOT a draw priority: check lines about 49, 430, 686, 821, 1409 and fix the "priority" wording where it refers to that bit. Line about 217 cites a ledger file path: replace it by the plain statement. HAZARD: a transform rewrites every literal $8000 in this block to $0080; never write the text $8000 in a note here (write $0080).
3. cop_dispatch.asm lines about 5 and 70 (and the partNotes entry for it, bank00 about key line 136): the note lists 19 handler labels that differ from the copdef names. After IT-04 none of the $90-$92 differences remain, and the rest already match copdef: state what is true now, or delete the list if nothing differs.
4. radar_map_screen.asm lines about 343, 371, 416 call RadarPlotFriendlyActor / RadarPlotEnemyActor "historical" names: say what each routine plots instead (A01 F9: bit 8 = enemies still alive; bit 9 is set only by dark_space.asm; verify). Line about 76 cites an ordering hazard by OQ id: write the fact (the DMA size is written after the destination/trigger; see the AGENTS.md adhoc DMA ordering rule).
5. inventory_menu.asm (A02-05): line about 7 "StatusAbilityRow2/2/3" (typo for 0/1/2); lines about 113 and 143 still say "StatusCharRow"; line about 508 "(label is an auto name)" but the label is now DiscardAttempt; line about 919 hedges "inferred from the earlier note" (state what you can trace, say "not traced" for the rest); SWAPPED inline comments at about 413 (`LDY $2E`) and 421 (`LDY $22`): $2E is the source slot and $22 the target (header about 392, save about 359). The part notes carry the old text too (partNotes bank02 about lines 85 and 337-339). Do not comment the lines that a transform rewrites (see ground rules).
6. awB2_stair_climb.asm lines 1-5: the actor waits for flag word $016B, stores $000A in $0E and JumpFar's to SliderGlideTriggerNorthMain (a north Psycho Slider glide). slider_glide.asm line 1 already describes it. Keep the label.
7. DeathPaletteFadeThinker.asm line about 3 says the two bundles "were not decoded". They are decoded in plans/extracted-audit/questions/I029_questions.md lines 14-18 (8-frame fade of 16 words to a pale blue/lavender tint; bundle $0E is the instant end state): confirm from palette_bundles.asm yourself, then state the fact without the id.
8. thinker_execution.asm prose about lines 167 and 197 ("TypeA..."): current RunThinkers_* names.
BLOCKED, list in the apply file (do not attempt): removing the orphan comment key "47052" in notes/comments/bank00.json (merge cannot remove an orphan; A15-09, Part 2); MenuSelectionHandler.asm (the merge guard refuses it; A02-03, Part 2); any mnemonic text (system_core.asm line about 510 "Decrement invincibility timer", scene_lifecycle.asm 828).
```

### IT-07 — Actor and thinker factual defects, I031–I040

Reads: [A03](A03_findings.md) A03-01, A03-02, A03-04, A03-05, A03-06, A03-07, A03-08 and section 6 (ordering table).

```text
ITERATION IT-07. Mechanism: merge only. Re-derive every fact first.
1. debug_stat_setter.asm line about 5 says "no reader of $0B22 was found ... documentation only (see the questions file)". UpdateHUD_Active in system_core.asm (about 416-424) reads hpToHeal: DEC, INC playerHp every 8 frames, SFX $0D, cleared when playerHp = playerMaxHp. State the reader; drop the pointer [A03-01].
2. interaction_handlers.asm block note, lines about 10-13 and 17 [A03-02, A03-04]: (a) the copdef does NOT label the BranchOnPlayerX operands (db-us/copdef.json:44-45 are bare &Code); only docs/cop/families/player_query.md does, and the handler order is West / Here / East (cop_handlers_player_query.asm about 193-218); (b) "more than 15 px" is off by one: |delta| = 15 already takes the outer slot ("15 px or more"; verify BCC against CMP [$0A]); (c) item 6 describes labels that no longer exist (*AlignWest / *MoveWest ...): the family is now CollectGemAlignPlayer* and PushSolidMovePlayer* (names/bank00.json:734-759), named by where the player stands; state that rule and the dead-branch fact; (d) item 5 and line 17 narrate the old names ("the old names and header"): remove.
3. ramps.asm (A03-05): RampEastWatch (about lines 102-108) has a BMI to a target that starts with BPL, so the BPL is never taken and the EOR/INC always runs; interaction_handlers.asm documents the same pattern (about 13 and 61), ramps.asm does not. Verify the same pattern in the other three watch blocks, then add one note line (or one inline comment per site) to each.
4. hdma_circle_window_thinker.asm lines about 18 and 73 say "the first frame always builds / rebuilds". The code (about 667-693: HdmaInitPrevState stores zeros, HdmaCompareParams reports no change when the current parameters are also zero) builds only when the scene has set a non-zero parameter. Fix both [A03-06].
5. SpawnDebrisBurst.asm lines about 3 and 5 [A03-07]: flag bit $0002 is decoded (StandardEnemyDefeatHandler.asm about 6 and 75: "draws it in front of every actor"); remove the "undecoded" claim, the OQ id and the "older header" narration.
6. StopPlayerOnDeath.asm line about 5 and the block note in notes/blockNotes/bank00.json about line 138 [A03-08]: they quote a docs entry "$0200 deathFlag, set by StopPlayerOnDeath" that no longer exists and narrate "the old claim that it freezes movement". State what the routine does. Do not discuss the mnemonic name deathFlag (Part 2).
Not here: RandomPlayerOffset (IT-02), mode7_perspective (IT-08), the 27 + 39 narration lines and 33 id lines of this range (IT-12), docs (IT-16), and every R-I03x rename row (IT-04 / Part 2).
```

### IT-08 — Factual defects, I041–I050

Reads: [A04](A04_findings.md) A04-01, A04-04, A04-05, A04-06, A04-07 · [A02](A02_findings.md) A02-02 · [A03](A03_findings.md) A03-12.

```text
ITERATION IT-08. Mechanism: merge only. Needs IT-04 applied. Re-derive every fact first.
1. SpawnItemSparkleEffect.asm lines about 1, 5, 12 [A04-01]: the note says no item id $86 or more was found and the sparkle position is unproven (OQ ids). The heal id $86 IS reachable: EnemyDropSystem.asm (about 6, 10, 150-153; DropBodyHeal5 loads $0086 into chatPtr; drop_threshold_by_hp rows 00, 06, 0B select it); combat_collision.asm InteractionDamage_NPCChat (about 1550-1559) does TYX then GiveItemToPlayer; inventory_mgmt.asm switches the direct page to the pickup actor, so the sparkle appears at the pickup actor. Also fix the matching part notes; drop the ids and "The old text ... is wrong".
2. jeweler_gem.asm lines about 5 and 55 [A04-04]: "when the player presses B" is the vanilla button. The talk trigger is interact bit $8000 of joypadCurrent (global_ambient_dispatcher.asm about 13 and 105), fed by the A button in this build (transforms.json:755-758, system_init.asm:230-233). Write "the interact button (A in this build)". The "B cancel" text at about 21, 133, 137 and debug_man.asm:58 is right: leave it. Line about 268 quotes a string in quote marks that is a paraphrase of dialogstring_08D2D0: remove the quote marks or quote the real text.
3. EnemyDefeatDispatch.asm line about 10 and its part note [A04-05]: "$12 |= $1000 priority boost on the flash": that bit is the display-filter qualifier, not a draw priority. Keep the wording identical to the one used in IT-06 for combat_collision.asm.
4. mode7_perspective.asm and notes/blockNotes/bank03.json (about line 15) [A04-06, A02-02, A03-12]: line about 5 says the thinker goes into RunThinkers_TypeB (live: RunThinkers_Hdma, thinker_execution.asm about 34 and 199); line about 52 names "parallax_thinker" (the block is scanline_band_hdma_thinker); lines about 52, 53, 84 carry OQ ids and about 48 "The old notes said 'repeat'": state facts in words.
5. dialog_string_scanner.asm lines about 9 and 79 [A04-07]: $0100 is the hit offset + 1 (INY at about 76 runs before TYA / STA $0100), the resume offset is hit + 4 (the pushed Y).
Not here: the wait-count items of this range (IT-02), the 68 narration lines and 32 id lines (IT-13), the mnemonic proposals R-I041-3 etc. (Part 2).
```

### IT-09 — Factual defects and timing, I051–I060

Reads: [A05](A05_findings.md) A05-01, A05-02, A05-03, A05-07, A05-10, A05-11, A05-12, A05-13, A05-14 · decision U3 and U5 in §4.

```text
ITERATION IT-09. Mechanism: merge only. Re-derive every fact first. Do not edit docs (IT-16).
1. WorldMapController.asm (A05-01, A05-02):
   a. The zoom-out is called "44 ticks" in about lines 37, 39, 150, 163-164, 170-171 and in the matching notes (notes/comments/bank03.json about 315-316 and 333-334, partNotes/bank03.json about 11 and 300, blockNotes/bank03.json about 27). The loop is 44 PASSES, and each pass runs SetEntryHereAndYield and then a non-final LoopEnd, which yields again (cop_handlers_script_control.asm about 52-60 and 260-285): about 88 ticks. Re-trace this yourself. If your trace agrees, write "44 passes, 2 ticks per pass, about 88 ticks" and keep the $B8 arithmetic (it counts passes). If it disagrees, mark DISPUTED and change nothing.
   b. Inline comments about lines 425, 428, 432, 439, 446, 450: SetEntryHere does NOT yield (cop_handlers_script_control.asm about 36-47; the yield is the RTL near line 501); the route bytes are numbered 2/3/4 there but differently in world_map_route_table.asm 11-16 (byte 3 = tick count n); line about 439 says "Z movement": re-derive the meaning of that index from RouteDeltaTables first. Use ONE numbering that matches the route-table block note.
2. world_map_options.asm lines about 38 and 40 [A05-13]: use the n+1 wording of world_map_route_table.asm line 11. Lines about 13, 34, 67 [A05-07]: the notes say ids $1C-$26 are "never staged"; WorldMapController.asm about line 121 masks the staged id with AND #$001F, so $1C-$1F are unused but reachable and $20-$26 cannot be staged at all. Spelling (U5): quoted game text "Ankor Wat", do not rename labels.
3. StandardEnemyDefeatHandler.asm lines about 6, 7, 66 and layer1_scroll_actors.asm line about 44 [A05-14]: wait operands are quoted without ticks; write operand and ticks.
4. sE6_gaia.asm lines about 30, 519-530, 1441-1545 [A05-03, decision U3]: the DS_AuraItemRoom cluster (AuraItemInventoryFull, dialogstring_08EFEF) is referenced by baserom/patches/APUWaitFixes.patch.asm (about 392, 396, 416). Write "no reference in extracted code; APUWaitFixes.patch.asm rewrites AuraItemGrant and uses these labels". No "Dead:" marker, no rename.
5. sFB_boot_logo.asm notes on BootLogoPalLockout [A05-10]: add that baserom/fixes-tweaks/Utils.patch.asm (about 75-76) rewrites BootLogoPalLockout! to branch to BootLogoNtsc, so the shipped ROM skips the PAL lockout screen (static reading of the patch).
6. palette_bundles.asm padding notes (about 10105-10260) [A05-11]: the notes assert "padding" but the only evidence is "nothing references them": say that, or settle it by comparing the bytes.
Do not comment lines of sFA_diary_menu.asm at the addresses in §6.3. Not here: the 19 narration and 49 id lines of this range (IT-13); the mnemonic rows R-I059-3 / R-I060-5 (Part 2).
```

### IT-10 — Tables I061–I064 and the four `spm_*` maps (complete clean-up)

Reads: [A06](A06_findings.md) all findings except A06-18 (docs, IT-16), A06-19 (plan-level), A06-20/21 (Part 2) · [A07](A07_findings.md) A07-03 (the "Shadow only" wording).

```text
ITERATION IT-10. Mechanism: merge only. Every file of this list is cleaned COMPLETELY (facts, narration, ids, process paragraphs) so each note is edited once. body_table.asm is already done by IT-05: skip it. Note: spm_* are .sprite.asm files; dry-run shows the bank for each key, check it.
Files: walk_step_table, scene_actors, ability_damage_tables, forced_walk_pan_table, move_chain_table, shared_word_table, spriteset_freedan, spriteset_will, spriteset_adrift_wave, spriteset_snake_pit_fx, spriteset_freejia_tilefx (all extracted/tables/), spm_boot_logos, spm_title_actors, spm_darkspace_sprites, spm_overworld_sprites (the four spm_*.sprite.asm files under extracted/system/), plus spriteset_shadow.asm line about 7 (wording shared with Freedan/Will).
Facts to fix (re-derive each; severity in the findings):
- A06-02: the group-header bytes 4-7 box is ALSO read by tile_collision_physics.asm (8 sites; its own header about 34-42 documents it). Add it to the reader list in the five places (spriteset_freedan.asm:9, spm_boot_logos:13, spm_title_actors:13, spm_darkspace_sprites:20, spm_overworld_sprites:23).
- A06-03: hold $63 = 100 ticks, not 101 (spriteset_freedan.asm:30, spriteset_will.asm:6).
- A06-04: scene_actors.asm line 25 lists 17 ids, not 16; line 23 (224 includes the default list: say so). A06-05: line about 4734 has six inventory_statue_slot actors, not three (give the six parameters). A06-06: retired names scene_event_0CXXXX, 0C8200, 0CC7A1, 0CBDC4 -> live labels scene_NN_actors / scene_default_actors / scene_A7_actors / scene_91_actors.
- A06-07: ability_damage_tables.asm:14: eu97_dark_medicine.asm:44 is a second writer ($0B1C = 1, Dark Friar level 1); the other four level words have no direct STA in extracted/ (say so). A06-08: one end-address convention (inclusive last byte); the ability range is 121255-121303.
- A06-09 and A07-03: the "not staged by the player scripts" / "$10-$13 staged for Shadow only" lists in spriteset_freedan.asm:47 and :34, spriteset_will.asm:35 and :29, and spriteset_shadow.asm:7 contradict the code. They are true only for the StagePlayerSprite family and the Will/Freedan/Shadow tables; the same indexes are staged under body row 4 (spriteset_will_abilities) by the Psycho Slider and Psycho Dash code. Re-run the rg of A06-09 and write the corrected wording ONCE and use it in all five places.
- A06-17: spriteset_freejia_tilefx.asm: add the cameraBoundsY store ($06DC) of fr32_laborer_npc.asm to the users paragraph. A06-16: replace offset/unprefixed names by the live labels (spriteset_adrift_wave 19, spriteset_snake_pit_fx 29 and 41, the spm notes, spm_boot_logos 18).
- Hygiene in these 15 files: A06-12 (12 narration lines, incl. walk_step_table:7, spm_boot_logos:18 quoting the "nothing reads" claim), A06-13 (15 id lines), A06-14 (6 "Checked:" paragraphs and 7 UNVERIFIED-RUNTIME tags; keep a hedge only on a specific untraced claim, "not traced: X").
Do NOT delete the B001 hit-box facts; they are correct (A06 section 2.4). Not here: docs (IT-16), blocks.json types (Part 2).
```

### IT-11 — Tables I065–I068 and three actor comments (complete clean-up)

Reads: [A07](A07_findings.md) all findings except A07-01/10/11/12 (IT-01), A07-03 (IT-10), A07-14 (IT-02), A07-17 (IT-01 and IT-14), A07-21 and A07-23/24 (Part 2).

```text
ITERATION IT-11. Mechanism: merge only. Needs IT-01 and IT-10 applied. Every table file below is cleaned COMPLETELY (facts, narration, ids, process paragraphs).
Files (extracted/tables/): dialog_template_table, parallax_scroll_table (clean, read only), scene_meta, enemy_stats_table, spriteset_aura, spriteset_shadow (except line 7, done in IT-10), item_pickup_text_table, spriteset_darkgaia_projectile, spriteset_transform_poses, spriteset_npc_props, display_preset_table, scene_warps. Also: system/engine/DialogStringRenderer.asm (the DialogCmd_InsertTemplate header about lines 242-244 and the OQ id at about 142), actors/player/attack_ability_system.asm (lines about 114 and 552), actors/player/player_character.asm (line about 1850).
Facts to fix (re-derive each from code or bytes):
- A07-02 spriteset_aura.asm:15: AuraBarrierMain copies 7 colours to CGRAM $A9-$AF, but AuraBarrierPaletteFX cycles bundle #5B over colours $A1-$A8 (attack_ability_system.asm about 1610-1612; palette_bundles.asm about 8221-8230).
- A07-04 spriteset_transform_poses.asm:14: "$0C (transform_pose_0B)" must be transform_pose_0C.
- A07-05 spriteset_npc_props.asm users table: add fr32_locked_door (rows $00, $01), fr32_kidnapper ($01), mu63_spirits ($06, the flame animation).
- A07-06 enemy_stats_table.asm:6-10: byte +3 has a second reader, FieldRevealFromActorStats in field_reveal_object.asm (about 100-104: AND #$0003, 0 = nothing, 1/2/3 = gem pickups of 1/2/5 gems). A07-07: line 12, bit $0020 of $12 is the boss bit, not immunity.
- A07-08 dialog_template_table.asm:1 and the DialogStringRenderer header: the caller's string pointer, bank and flags are restored, but the cursor is reloaded from $0998 (DialogCmd_Return hands the new cursor back), so a [DLG] template positions the text that follows. A07-09: template $11 has 37 real uses (the 49 counts 12 comment mentions in world_map_options.asm); say "comment lines excluded".
- A07-13 scene_meta.asm:21: tilemap operand $01 = layer 0 (225 uses), $02 = layer 1 (158). A07-15: spriteset_darkgaia_projectile.asm:11 uses retired offset names; use projectile_travel_north/west/east.
- A07-16: the old names table_17D000 (player_character.asm:1850) and table_179000 (attack_ability_system.asm:552) in comments; attack_ability_system.asm:114 says 3-frame animation: the set has 3 animations of 4 frames.
- A07-22: where the text mentions $0AF4 write reviveWarpPtr; other unnamed operands stay as they are (Part 2 names them).
- Hygiene: A07-18 (12 narration lines in 11 files), A07-19 (ids in 11 files), A07-20 (process narration at scene_warps.asm:23, a line number inside a note at item_pickup_text_table.asm:10: name the routine instead).
Not here: the stair-warp struct name (A07-21, Part 2), enemy_stats_table.asm:21's 16-row census (A07-23, not recomputed: leave the sentence, add "not recomputed" only if you cannot re-derive it).
```

### IT-12 — Hygiene sweep 1 (I001–I040 files)

Reads: [A01](A01_findings.md) §6, F7, F8, F10 · [A02](A02_findings.md) A02-09, A02-10 · [A03](A03_findings.md) A03-10, A03-11.

```text
ITERATION IT-12. Mechanism: merge only. Needs IT-01 to IT-07 applied (the files they cleaned will show no hits; that is fine). Scope: the file sets listed in A01 section 1, A02 section 1 (the 32-file sweep set) and A03 section 1, and only those.
Sweeps (run with rg -n over those files, record pattern and hit count in the apply file before and after):
 narration: \b(previously|formerly|old header|old note|the old |older|was renamed|rename proposed|historical|stale name|used to be|first audit)\b
 ids: OQ-[A-Za-z0-9-]+|\bR-(I[0-9]{3}|B[0-9]{3}|SAN[0-9]|[0-9]+)(-[0-9a-z]+)?\b|\bD-S[0-9]+-[0-9]+\b|rename proposal|questions file|\(I0[0-9]{2}\)|audit (OQ|rename)
Known hits (A01 section 6, A02-09/10, A03-10/11): narration in actor_execution:43, cop_handlers_script_control:23, tile_collision.asm:7 and 129, map_coords:10-11, system_init:8 and 253, scene_flag_init:3, player_move_west:916, SetPlayerGameOverFlag:3, oneshot_palette_flash_18:3 and 7, oneshot_palette_flash_19:3, hdma_circle_window_thinker:3 and 565, sine_hdma_slow_wave:3, ambient_palette_cycler:5, oneshot_coldata_r11g4b2:3 and 5, oneshot_coldata_warm_flash:5, flag_gated_palette_warm:14, flag_gated_palette_cool:13, RandomPlayerOffset:4, ActorMidpointCalc:4, EnemyInitBasic:1, ActorDisplayModeSwap:10, EnemyDeathFlash:7, SetPlayerIdleFacing:5 and 29, slope_ramp_physics:34, large_ramps:6, idle_sprite_display:3, camera_delta_oscillator:3, inventory_overlay:16, sFB_boot_logo:29, and 39 lines in system/player (player_move_east 15, _south 7, _ramps 6, _main 6, _ns 5). Ids: A01 section 6 per-file counts (radar_map_screen 8, actor_pool 5, camera_scroll 4, flag_helpers 4, system_core 4, actor_execution 3, cop_handlers_audio 3, cop_handlers_dialog 3, forced_walk 3, 11 files with 1-2, "rename proposal 90" in cop_handlers_script_control:7, "(see the audit rename proposals)" in warps_interaction:46, cop_handlers_actor_flags:5) and A02-10 / A03-11 lists (player_character 10, item_use_system 8, player_move_west 6, hdma_dma_spc 5, inventory_overlay 7, player_move_south 8, player_move_ns 6, ...).
Rewrite rules: keep the current technical fact, drop the clause. An id becomes a plain statement of what is unknown ("no reader found in extracted/", "not traced"). If the question has since been answered by code you can trace (e.g. OQ-61 fade command, OQ-64 DMA ordering, OQ-7, OQ-22 facing order), state the answer instead. Do NOT delete a sentence that carries a fact only because it contains an id.
Skip: item_use_system.asm lines 37, 368, 450 (they describe the plain-versus-tagged build difference and stay until Part 2 decides the build mode), MenuSelectionHandler.asm (blocked), DialogStringRenderer.asm (IT-11), and any hit inside a line whose label the hazard list forbids. Report the numbers of hits left (should be 0 except the skipped ones).
```

### IT-13 — Hygiene sweep 2 (I041–I060 files)

Reads: [A04](A04_findings.md) A04-08, A04-09 · [A05](A05_findings.md) A05-04, A05-05 and §7.

```text
ITERATION IT-13. Mechanism: merge only. Needs IT-08 and IT-09 applied. Scope: the 30-file sets of A04 section 1 and A05 section 1 (table), and only those. Use the same sweeps, rewrite rules and apply-file counters as IT-12.
Known hits: A04-08 lists 68 narration lines in 26 files (largest: global_ambient_dispatcher 12, player_move_main 10, ApplyPlayerHitstun 4, unused_particle_rain_spawner 3-4, hit_stagger_controller 3, gold_ship_wreck_palette 3, inventory_mgmt 3, player_move_controller 3, dialog_string_scanner 3) and retired names kept as prose (EnemyDropSystem:1 DarkGemDropSystem, gold_ship_wreck_palette:1, hit_switch:1 floor_button, DamageNumberShort_unused:1, hit_stagger_controller:5 and 301, statue_inventory_reward:210). A04-09 lists 32 id lines in 18 files. A05-04: 19 narration lines in 17 files; A05-05: 49 id lines in 19 files (player_transition_handlers 9, WorldMapController 5, layer1_scroll_actors 5, sFA_diary_menu 4, palette_bundles 4, field_reveal_object 4, plus `(R-I060-4)` x4 and iteration ids "I054"/"I055" in prose). Also the five lines where A05 section 7 found retired names as prose.
Extra rules: sFA_diary_menu.asm is a transform-hazard file: edit comments only on lines whose `; {n}` tag is NOT in the forbidden list of section 6.3, and add no part note on diary_band_slot1 / diary_band_empty. In the "extracted/" copy the ids inside spm_darkspace_sprites.sprite.asm (OQ-B001) belong to IT-10; skip them. Do not touch the build-mode sentences ("the tagged extract still shows ...") in sFA_diary_menu.asm line about 34; they wait for Part 2.
```

### IT-14 — Docs part 1: scene and table names (PLAN F05 part 1)

Reads: [report.md](report.md) §5, N-1, N-2, N-3, N-7 · [A07](A07_findings.md) A07-17, A07-16 (docs part) · [A01](A01_findings.md) F11 rows 11 and 15.

```text
ITERATION IT-14 (DOCS). Allowed edits: docs/ only, by hand with StrReplace. No merge, no names, no gate run. Finish with npm run names -- --check. For every line: re-read the cited code first, edit, and record doc file, line, before and after in IT14_apply.md. Do not run npm run ingest:all.
1. table_018000 -> display_preset_table where the text means that table: docs/structs-reference.md (about 362, 833, 841, 843), docs/bank01-data-tables.md (about 46, 662), docs/code/bank0D-scene-meta.md (about 105), docs/code/bank02/scene-script.md (about 99, 215, 733, 739, 758, 1095). Leave docs/bank01-data-tables.md lines about 688 and 712: they are rename-map rows that must name the old identifiers.
2. docs/code/bank0D-scene-meta.md: the music-group sentence ("already matches -> skipped" is inverted: the load runs when the script group EQUALS musicRoomGroup) and the $04/$05/$06 operand descriptions (palette colours, metatile sets, layer maps). docs/code/bank02/scene-script.md: the opcode table (same facts) and about line 234 "cached source pointer at $06AA" [A01 row 11: check the real address in scene_script.asm before editing].
3. "barrier" for the chest table: docs/bank01-data-tables.md about 21, 199-209, 692; docs/code/README.md about 241 ("Per-scene barrier/chest placement data").
4. docs/bank01-data-tables.md about 323 and 326 and docs/code/README.md: dialog_template_table "screen-effect presets" wording; re-verify against extracted/tables/dialog_template_table.asm (templates are colour/SFX/box presets for dialog text; read the file) and fix.
5. docs/bank01-data-tables.md about 341-343: the music table has an "ID" column with no note that the stored id is index + 1 (A01 row 15): check the code first.
6. Retired names in other docs: itemget_table_01FD24 -> item_pickup_text_table (docs/code/bank03/text-and-menus.md about 346, docs/code/bank03/field-input-and-items.md about 401, docs/code/bank02/game-systems.md about 570); table_179000 -> spriteset_aura (docs/code/bank02/player-character.md about 93); table_17D000 -> spriteset_darkgaia_projectile (docs/code/bank02/README.md about 169).
```

### IT-15 — Docs part 2: `hpToHeal`, nicknames, WRAM rows (PLAN F05 part 2)

Reads: [report.md](report.md) N-6, N-10, §5 · [A03](A03_findings.md) A03-01 · [A01](A01_findings.md) F11 rows 9, 31, 77, 94, 54, 58, 93 · [A04](A04_findings.md) A04-08 (the docs history line).

```text
ITERATION IT-15 (DOCS). Same rules as IT-14 (StrReplace only, record before/after in IT15_apply.md, names --check at the end).
1. $0B22 is hpToHeal, the HP-recovery counter (UpdateHUD_Active, system_core.asm about 416-424: DEC, INC playerHp every 8 frames, SFX $0D), $0ACE is current HP, $0ACA is max HP. Fix docs/code/bank00/system-core.md (about 421 "Damage flash ... animates DEF display $0ACE toward max $0ACA", 457 "Damage flash timer", 522 "Damage/save metadata") and docs/code/bank00/data-tables-memory.md about 381; match docs/wram-memory-map.md about line 378 (correct already). Check docs/code/bank00/actors-player-rewards.md about 58 and 73 ("HP bar display delta") against the same code.
2. will_alt and the other retired nicknames: docs/code/bank00/stair-climb-system.md (about line 5), docs/code/bank00/README.md about 740, docs/code/bank00/data-tables-memory.md about 250. Use the current block names.
3. docs/wram-memory-map.md: about 207 (gfxLoadParams: the field names are those of the live mnemonics; read mnemonics.json and the code before editing), about 358 ("16 item words" for $0AB4-$0AD2, which is 31 bytes), about 347 ("Cleared by ClearAllWramFlags at scene boundaries"; check the code), and any remaining deathFlag, collisionLayerBase text (A01 rows 8, 54, 58: the file may already be clean; report).
4. docs/code/bank00/system-core.md about 36 ("music handshake from NMI"), data-tables-memory.md about 415 ($0B28-$0B32 "Save/warp metadata") [A01 row 77]: re-derive from the code before changing.
5. docs/code/bank00/functions-combat-defeat.md about 256: history narration ("formerly ..."): state the current fact only.
6. The SetOnInteract legacy name [A01 row 93]: docs/code/bank08-native-dao-pyramid-actors.md (about 124, 127, 193, 250), docs/code/bank0A-dungeon-enemy-actors.md about 257, docs/code/bank00/actors-player-rewards.md about 329. Use the current COP name. docs/cop/families/script_control.md (53, 65, 103) keeps it as a labelled alias; leave it.
```

### IT-16 — Docs part 3: COP families, structs, timing (PLAN F05 part 3)

Reads: [A01](A01_findings.md) F11 rows 10, 16, 40, 45, 69, 70, 71, 86 and row 67 · [A03](A03_findings.md) A03-03 · [A05](A05_findings.md) A05-01 (doc part) · [A06](A06_findings.md) A06-18 · [report.md](report.md) §5.

```text
ITERATION IT-16 (DOCS). Same rules as IT-14 (StrReplace only, before/after in IT16_apply.md, names --check at the end). Re-read the cited code before each edit.
1. docs/cop/families/player_query.md [A03-03]: lines about 45-46 list the BranchOnPlayerX/Y operands as W, E, Here / N, S, Here; the handler order is West / Here / East and North / Here / South (cop_handlers_player_query.asm about 193-218 and the Y handler after it). Fix the handler line references at about 141 (181-206 -> 193-218) and 178 (re-read the Y handler for the new range). docs/cop/README.md carries the same row: fix it.
2. A01 F11, one family at a time: collision_branch.md about 24 and 416 (the BranchOnPlayerFacing handler is not in cop_handlers_metatile.asm: find the real file), hdma_dma.md about 9 and 139 ("linear DMA"), force_move.md about 9, 19, 20 ("frame durations", "force SW/NE"), sine_hdma.md about 55 ("scanline count"), vram_memory.md about 111 ("Source bank forced to $7F"), dialog.md about 18, 53, 57, 119 ("dialogue mode", "inventory input"), audio.md about 24, 105 ("fades or waits", "cross-fade") and its "spawned by scene transition" statement (musicParentActor, A01 row 67), gravity.md / camera.md old operand descriptions (A01 row 70). For each: read the handler, correct only what the code contradicts.
3. docs/code/bank03/radar-and-world-map.md about line 164 and the phase table near 202 [A05-01]: the zoom-out is 44 passes, about 88 ticks (use the number only if IT-09 confirmed it; otherwise skip and report).
4. docs/code/bank02/movement-and-collision.md about 251 and 314-315 (previousDamage($09E2)) and docs/structs-reference.md about 824 ("+5 tilemapAddr") [A01 rows 16, 10]: verify against the live code and the live mnemonic names.
5. docs/structs-reference.md [A06-18]: lines about 670-683 describe direction-velocity as "xVelIdx / yVelIdx into the delta-node table, 9 entries cover all directions": live facts are byte 0 = animation index, byte 1 = move_chain index, the nine entries are step codes, left and right carry no chain (walk_step_table.asm 1-30, forced_walk.asm 189-225); lines about 1181-1200 describe sprite-set as `frameCount` with a $0000 terminator and a 13-byte group header "bounds, flags, tile counts": live format is 4-byte records < hold, &group > ended by a hidden $FFFF, header = 4 extents + two 4-byte boxes + count (spriteset_freedan.asm 1-19); line about 1214 uses retired table_0E8000 ... names. The body-entry text (about 1080-1094) is right: leave it.
```

---

## 6. Ground rules

### 6.1 Writing style for notes and docs (policy from the report: H-1, H-2, H-3, H-6, H-7)

- State what the code does **now**. No history ("previously", "the old header said", "was misnamed", "formerly"). History lives in git and the frozen ledgers.
- No OQ, R, D or iteration ids and no paths into `plans/` in shipped text. An open question becomes a plain statement ("not traced", "no reader found in extracted/").
- Every behavioural claim is static. Keep a hedge only on a specific untraced claim ("not traced: who sets bit 3"). Do not use blanket tags such as `UNVERIFIED-RUNTIME` and do not write "Checked:" or "SAMPLED" paragraphs (they are audit narration).
- Waits: say the operand and the ticks. `WaitByte #n` = n+1 ticks.
- Buttons: name the bit or mnemonic and say which physical button it is in this build (`$0080` interact is fed by A; `$4000` cancel is B). Do not write "B" for the interact bit.
- Words: "slot" (actor / thinker / palette / VRAM), "group" (music room / sprite header / drop), "frame" (animation frame / tick) mean different things: say which.
- Accumulator forms are bare `LSR`, `ASL`, `INC`, `DEC`, `ROL`, `ROR` in any asm you quote.
- Do not rename mnemonics, add `Dead:` markers or restructure notes beyond the finding.

### 6.2 The gate and the apply file

- Gate (tagged build only; after IT-27 the newest `GATE:` line of the Progress log replaces these numbers, §10.3): `npm run extract:lt`, then `npm run rebuild` as two separate commands; expected checksum 223006080, crc 2083230829, totalSize 3062204. If `extract:lt` fails with an `rm -rf` error (an open handle), retry it alone, then run `rebuild`. A different number means stop and report.
- `IT<NN>_apply.md` (new file, written whole, in this folder): a table `finding id | file:line | status | note`, status = APPLIED / DISPUTED (your evidence) / SKIPPED (reason) / BLOCKED (which owner or step); the spec path; the dry-run summary; the gate numbers; items found outside scope.

### 6.3 Transform hazards while the gate is the tagged build (A15 section 2.2, A02 section 9, A03 section 8)

Ten transform rules only fire in the **plain** build, so the tagged gate cannot see a break. Until Part 2 makes them tag-tolerant, **do not put a comment or note** on these:

| Block (file) | Comment keys (`; {n}` tags) that must stay empty |
|---|---|
| `sEA_solid_arm` | 587588, 587591, 588300, 588303 |
| `pyDD_teleporter` | 765644, 765658 |
| `pyD7_sliding_wall` | 574811, 574812, 574815, 574817, 574828, 574829, 574832, 574834 |
| `sFA_diary_menu` | 779416, 779452, 779486, 780227, 780261, 780605, 781132; 781111, 781114, 781117; 781138, 781141, 781144, 781147, 781153, 781156, 781159, 781162 |
| `item_use_system` | 231157, 231432 (the `CMP #$0027` / `CMP #$0038` lines at about 388 and 463) |
| `diary_menu_window_dma` | no part note on the labels `diary_band_slot1` and `diary_band_empty` |

Also:
- In the blocks `combat_collision` and `actor_execution` a transform rewrites every literal `$8000` to `$0080`: never write `$8000` in a note there.
- Do not add a label, part note or comment-only line between an `LDA #imm` and its `TSB` / `TRB` on `$joypadMaskStd` / `$joypadHeld` (several hundred sites; the tolerant tail group allows an inline comment on the same line only).
- `MenuSelectionHandler.asm` is refused by `merge` on purpose; do not try to bypass it.
- `npm run names` rewrites references in `db-us/*.json` too; check `db-us/transforms.json` for every old name before a rename.
- If a target sits on one of these lines, skip it and list it under BLOCKED.

### 6.4 Ownership

Where one file appears in several findings, the iteration that cleans it completely is: `body_table` IT-05; the 15 tables of A06 and the four `spm_*` IT-10; the 12 tables of A07, `DialogStringRenderer`, `attack_ability_system` 114/552 and `player_character` 1850 IT-11; `scene_chest_table` and `scene_lifecycle` IT-03; `WorldMapController`, `world_map_options`, `sE6_gaia` IT-09; `mode7_perspective` IT-08. Hygiene sweeps (IT-12, IT-13) only pick up what is left. If you find a hit in a file whose owner iteration is not DONE, skip it and say so.

---

## 7. Coverage: every finding of A01–A07 and where it went

"CF" = carried forward to Part 2 (see §8). "none" = informational or already correct.

| File | Finding | Goes to |
|---|---|---|
| A01 | rows 1–96 (rename proposals) | applied rows: none; open rows: CF-5, CF-1/2/3 by kind; row 12 (six orphan block-note keys): Part 2 (A09/A10) |
| A01 | F1 scene_script 1303 / 75 | IT-01 |
| A01 | F2 tile_collision_physics 32 | IT-06 |
| A01 | F3 hit-stun wording | IT-06 |
| A01 | F4 JumpAfterDelay / COP #27 n+1 | IT-02 |
| A01 | F5 cop_dispatch note, StagePlayerSpriteMove* | IT-04 (names), IT-06 (note) |
| A01 | F6 nicknames in GetPlayerFacingDirection | IT-05 |
| A01 | F7 54 id lines in 20 files | IT-12 |
| A01 | F8 history narration (11 lines) | IT-03 (scene_chest_table), IT-12, IT-10 (walk_step_table), IT-13 (SpawnFieldRevealEffect, StandardEnemyDefeatHandler) |
| A01 | F9 radar plot names | IT-06 |
| A01 | F10 SetOnInteract narration | IT-12 (asm), IT-15 (docs) |
| A01 | F11 14 doc rows | IT-14, IT-15, IT-16 |
| A01 | F12 `BranchIfCollisionTypeNe`, F13 mnemonic backlog | CF-1, CF-2 |
| A01 | F14 button consume mask, F16 digest count | none (informational) |
| A01 | F15 sed/annotate in the apply pass | CF-6 |
| A02 | A02-01 13 Q5 rows | CF-1, CF-2 |
| A02 | A02-02 `_Next` labels, prose | IT-04, IT-06 |
| A02 | A02-03 MenuSelectionHandler | CF-4 (needs the T-steps) |
| A02 | A02-04 wait counts | IT-02 |
| A02 | A02-05 inventory_menu, A02-06 awB2_stair_climb | IT-06 |
| A02 | A02-07 nicknames slider_glide etc. | IT-05 |
| A02 | A02-08 DeathPaletteFadeThinker, orphan key 47052 | IT-06 (note), CF-4 (key removal) |
| A02 | A02-09 narration, A02-10 ids | IT-12 |
| A02 | A02-11 system_init operands | CF-1 |
| A02 | A02-12 build narration in item_use_system | CF-4 (after the build-mode decision) |
| A02 | A02-13 | none |
| A03 | A03-01, 02, 04, 05, 06, 07, 08 | IT-07 |
| A03 | A03-03 player_query.md | IT-16 |
| A03 | A03-09 RandomPlayerOffset 60/61 | IT-02 |
| A03 | A03-10 narration, A03-11 ids | IT-12 |
| A03 | A03-12 mode7_perspective residue | IT-08 |
| A03 | A03-13 15 proposed renames, A03-14 mnemonic rows | CF-5, CF-1 |
| A03 | A03-15, A03-16; section 8 `$8000` guard | none; CF-4 |
| A04 | A04-01, 04, 05, 06, 07 | IT-08 (A04-05 also IT-06) |
| A04 | A04-02, A04-03 waits | IT-02 |
| A04 | A04-08 narration, A04-09 ids | IT-13 |
| A04 | A04-10 mnemonic families | CF-1 |
| A04 | A04-11 scripts / crc.json, A04-12, A04-13 | CF-6; none |
| A05 | A05-01, 02, 03, 07, 10, 11, 12, 13, 14 | IT-09 (A05-01 doc part IT-16) |
| A05 | A05-04 narration, A05-05 ids | IT-13 |
| A05 | A05-06 missing mnemonics | CF-1 |
| A05 | A05-08, A05-09 registry errata | Part 2 (A12) |
| A05 | A05-15 scripts | CF-6 |
| A05 | A05-16 hidden sprite groups | Part 2 (A08, T02) |
| A06 | A06-01, 10, 11, 15 (`body_table`) | IT-05 |
| A06 | A06-02 … 09, 12, 13, 14, 16, 17 | IT-10 |
| A06 | A06-18 structs-reference | IT-16 |
| A06 | A06-19 digest wording | none (plan-level; correct only if the digest is re-issued) |
| A06 | A06-20 (58/26 split), A06-21 (blocks.json types) | CF-7, CF-3 |
| A07 | A07-01, 10, 11, 12, 17 (scene_script lines) | IT-01 |
| A07 | A07-02, 04, 05, 06, 07, 08, 09, 13, 15, 16, 18, 19, 20, 22 | IT-11 |
| A07 | A07-03 "Shadow only" | IT-10 |
| A07 | A07-14 InitWarpTable header | IT-02 |
| A07 | A07-17 patch include, other docs | U4 (patch), IT-14 (docs) |
| A07 | A07-16 `body_table:32` | IT-05 |
| A07 | A07-21 `stair-warp` struct name | CF-3 |
| A07 | A07-23, A07-24 | CF-7 |
| PLAN | F01 / F02 / F03 / F04 | IT-01 / IT-02 / IT-04 + IT-05 / IT-03 |
| PLAN | F05 (docs, report §5) | IT-14, IT-15, IT-16 (A11's doc items: Part 2) |
| PLAN | F06 (renames, mnemonics, structs) | Part 2 (needs A13 and A14); inputs in §8 |
| PLAN | T01, T02, T03 | Part 2 (A15; its findings change the T01 acceptance and add T04) |

---

## 8. Carry-forward to Part 2

These are the items of A01–A07 that no iteration of Part 1 can do. Part 2 must fold them into F06, the tooling steps, or the A08–A15 iterations.

**CF-1 Mnemonic backlog (user-owned `db-us/mnemonics.json`).** The nine clearly wrong names with live counts (A01 §5: 111 lines): `deathFlag` (a depth-bucket array; A02: 8 lines in 3 files), `actorLimitThreshold` 34/10 files, `musicParentActor` 7/5, `sceneStateHelper` 6/3, `deathActionIdx` 19/7, `iframeCounter` 26/8, `scratch1010+6` 9/6, `loopStartPcActor` 2, `loopCounterActor` 3. Also A02-01: `invincibilityTimer` (20 lines in 3 files; a run window), `climbStateData` (25/6; rows R-I023-3 and R-I025-6 propose **conflicting** targets), `effectScrollH/mapScrollV/effectScrollV`, `tileQueryResult`, `orbitAngle/orbitDiameter`, `moveXAlt/moveYAlt` (repurposed field: per-site check); A03-14: `playerStateByte`, `chatPtr`, R-I035-4 / R-I036-4; A04-10: ten bare-operand families (`$0D60` 27 sites, `$0B16/$0B1C`, `$0B08/$0B0C/$0B10`, `$09EE`, `$0404/$0405`, `$0DB8/$0DB9`, `$0100/$0102`, `$7F0011/$7F0013`, `$00B6/$00B8/$00BC/$00CA/$00CC`); A05-06 (`worldMapPartyArray`, Mode 7 words, `sFA` remap words, `$0036` in `WorldMapSplitEffect`); A02-11 (12 unnamed `system_init` operands incl. `$0080/$0082`); A01 rows 7, 22, 23, 27, 28, 37, 46, 49, 54, 67, 75, 79, 83, 90 and `$06F4` (script music group). Stale text that waits for the rename: `system_core.asm` ~510, `scene_lifecycle.asm` 828, notes that apologise for live names (`player_character.asm:12`, `QuintetLzDecompress.asm:24`, `cop_handlers_metatile.asm:6`, `slider_glide.asm:411`).
**CF-2 copdef (user-owned).** `BranchIfCollisionTypeNe` is the inverted name of an EQUAL branch (A01 F12, row 33); `QueueDma` (row 44), `ForceDir*` / `ReloadMoveDurations` (row 68), `MoveToward` / `StageMove` operands (row 78); A02: `ResetSpriteState`, `SetMetasprite`, `RunPlayerAnim` alias, `WorldMapStream3/4`.
**CF-3 `blocks.json` / `structs.json` / `overrides.json` (user-owned).** `forced_walk_pan_table` type `&Binary`, `walk_step_table` struct `direction-velocity` (A06-21), `stair-warp` struct name (A07-21), `hdma_ramp_tables` (row 38), `cop_handlers_actor_flags` (row 32), R-I041-4 `structs.json`, `$06B0` / `$0B04` rows (R-I024-1/2), `UploadCgramPalette/UploadOamTable` move (R-I024-3).
**CF-4 Tooling and the build decision.** `MenuSelectionHandler.asm` stays unmergeable until the three unanchored transform patterns are anchored or `merge` is extended (A02-03; corrected notes sit unmerged in `edits/I024_MenuSelectionHandler_PROPOSED.json`); the unanchored `$8000` rules in `combat_collision` / `actor_execution` need the transform guard (A03 §8); orphan comment key `47052` (A02-08) needs `merge --prune`; the build-mode sentences in `item_use_system.asm` (37, 368, 450) and `sFA_diary_menu.asm` must change after T01 (A02-12, A15-20).
**CF-5 Gated rename rows.** A01 rows 89, 95 (wait for OQ-63, OQ-68); A02 R-I030-1/2; A03 ten rows gated on open questions (§2); `awB2_stair_climb` (OQ-I023-1); A04 `R-I044-3` (block `global_ambient_dispatcher`); R-I056-8 (blocked by U3); A05-12 label spelling (U5).
**CF-6 Process and user.** `temp/*.mjs` scripts and the `sed` / `annotate` use in the apply passes (A01 F15, A04-11, A05-15); `artifacts/crc.json` holds plain-build numbers (A04-11); the apply-summary claims that are false ("none of the old names is left": A02 row 22, A03-12), to be recorded as errata (AP-22); digest corrections (A02 I-10, A06-19).
**CF-7 Static checks not done in the A-steps.** A07-23 (the 16 unused enemy-stat rows need a census over `scene_actors`), A07-24 (`Projectile*` only in scene `$E8`), A06-20 (58 / 26 chain-end split), A01 rows 12, 17, 24, 29, 51, 63, 76, 80, 81 (never checked), A04 §10 (`PaletteStep` waits, `WaitWhileOffscreen`), A02 §8 (`SetAutoWalkTimer` 13 or 14), A03 §9 (ramp watch blocks, scanline-band counts), OQs answerable statically (A02, A03, A04 §3, A05 §3 lists).
**CF-8 Registry updates.** A05-08, A05-09 (stale entries in `mesen2-question-inventory.md`, apply summary status): to be written into the Part 2 registry, never into frozen files.

---

## 9. Part 2 follows

Part 2 (IT-17…IT-53) starts at §10. Its iterations are listed in the §2 index below the Part 1 rows; the prompts are in §12; §13–§15 hold the coverage table, the closure of CF-1…CF-8 and the parked items; §16 is the run order.

---

# Part 2: A08–A15 (IT-17 … IT-53)

## 10. Part 2 ground rules

### 10.1 Phases

| Phase | Iterations | What it changes | Gate |
|---|---|---|---|
| A: notes | IT-17 … IT-25 | notes and comments only (`merge`) | tagged gate of §6.2 (or the newest `GATE:` line if IT-27 is DONE); hazards of §10.4 |
| B: tools, transforms, orphans | IT-26 … IT-34 | `src/`, `gaia-core/`, `transforms.json`, notes (re-key / prune) | §10.3; most iterations run **both** builds |
| C: questions, names, mnemonics | IT-35 … IT-48 | names (`npm run names`), user-owned JSON (edit lists), notes after the renames | §10.3 |
| D: docs | IT-49 … IT-52 | `docs/`, `gaia-core/docs/`, `gaia-knowledge/curated/` by hand | `npm run names -- --check` (+ gate when the iteration touches a db file) |
| E: close-out | IT-53 | report files, `PLAN.md` status | final checks |

Iterations inside a phase may be run in any order unless the "Depends on" cell says otherwise. IT-26 (T04) has no dependency and can run at any time. The recommended order across phases is in §16.

### 10.2 Preamble B: for mechanism T and U iterations (paste instead of the Fix preamble)

```text
You are running ONE tool or user-owned-file iteration (mechanism T or U) of the "audit-of-audit" action plan for the Illusion of Gaia baserom (workspace folder gaia-iog-baserom; plan folder plans/extracted-audit/audit-of-audit/).

Read first, in order:
1. plans/extracted-audit/audit-of-audit/ACTION_PLAN.md: section 6 "Ground rules", section 10 "Part 2 ground rules" and the section of YOUR iteration only.
2. The findings files named in your iteration. Read each cited finding id in full (they carry file:line evidence and the proposed fix).
3. gaia-core/docs/notes-and-comments.md sections "Notes Merge", "Names Merge" and "Merge spec format and iteration files"; gaia-core/docs/patch-development.md section "Transforms vs Overrides" when your iteration touches transforms.json.

Hard rules:
- Never run git commit, push, tag, merge, rebase, reset, revert, stash, checkout or restore, or any other git command that changes history or the working tree. git status, diff, log and add are allowed. At the end say "Please commit when you're ready." with a suggested message.
- No sub-agents (no Task tool). No throwaway scripts (.py .mjs .js .sh PowerShell) to edit notes, names, comments, db files or docs. Use Grep, Glob, Read, StrReplace, Write.
- Shell commands allowed: rg, npm run extract:lt, npm run extract, npm run rebuild, npm run merge, npm run names, git status/diff/log, plus exactly the extra commands your iteration lists (for example npm run build inside gaia-core, or node --test for a permanent test file you were told to add). Never npm run ingest:all. Never the retired ingest/annotate commands. Never add ?BANK to extracted files.
- You may edit ONLY the files listed under "Allowed edits" in your iteration. The text of the iteration prompt is my approval for those edits and for nothing else. Edit JSON db files with StrReplace on the single line concerned: never rewrite a whole file, never reformat or reorder it. Anything else you find: list it in the apply file under BLOCKED.
- Be patient: no stubs, no simplified versions, no "temporary" shortcuts. If a step fails, do not fall back to an older method and do not work around a tool: stop and ask me.
- Findings were made in an earlier session. Before editing, re-read the live file and re-derive the fact; if the live state disagrees, mark the item DISPUTED with your evidence and continue.
- Gate and apply file: ACTION_PLAN.md sections 10.3 and 6.2. After EVERY change group run the gate your iteration names and compare with the newest "GATE:" line of the Progress log (section 6.2 numbers if there is none). A different number: stop, report the numbers and your last edit, revert only your own last edit.
- After any plain "npm run extract" run "npm run extract:lt" again before you finish, so extracted/ is left as the tagged tree.
- Procedure: (1) read targets; (2) do the work in the order of the iteration; (3) where the iteration says WAIT, end your message with the list and wait for my reply; (4) write plans/extracted-audit/audit-of-audit/IT<NN>_apply.md (table: finding id | file:line | status | note; status APPLIED / DISPUTED / SKIPPED / BLOCKED; list of files edited; gate numbers); (5) update only your row in ACTION_PLAN.md section 2 (StrReplace) and append one line to the Progress log.
- Final message: counts (applied / disputed / skipped / blocked), gate numbers, anything outside scope, then "Please commit when you're ready." and a suggested commit message.
```

### 10.3 The gate after IT-27 (T01)

- **Current gate** = the newest line of the Progress log that starts with `GATE:`. If there is none, it is the tagged gate of §6.2 (223006080 / 2083230829 / 3062204). IT-27 appends the first `GATE:` line; every iteration after it compares with that line. Part 1 prompts say so in their step (5).
- After IT-27 the plain build (`npm run extract`) and the tagged build (`npm run extract:lt`) must give the **same** numbers. Mechanism T/U iterations of phase B and C run both: `npm run extract`, `npm run rebuild`, compare; then `npm run extract:lt`, `npm run rebuild`, compare; then stop with the tagged tree in place. Mechanism M, N, D iterations run the tagged build only.
- IT-26 (T04) adds the mode to `artifacts/crc.json`; from then on the label there tells you which build wrote the numbers.
- A plain extract churns every tagged file in `git diff`. That is expected while an iteration runs; the last command of the iteration is always `npm run extract:lt`.

### 10.4 Transform hazards before and after IT-27 / IT-28

| Hazard (§6.3) | Until IT-27 is DONE | After IT-27 | After IT-28 |
|---|---|---|---|
| comments at the `; {n}` tags of `sEA_solid_arm`, `pyDD_teleporter`, `pyD7_sliding_wall`, `sFA_diary_menu`, `item_use_system` | forbidden (§6.3 table) | **allowed** (rules R1, R3, R4, R7–R10 are tag-tolerant) | allowed |
| part note on `diary_band_slot1` / `diary_band_empty` (rule R5) | forbidden | forbidden (R5 stays label-spanning unless IT-27 made it tolerant: see that apply file) | refused by the `merge` guard |
| literal `$8000` in a note of `combat_collision` / `actor_execution` | forbidden | forbidden (unanchored rules stay) | refused by the `merge` guard |
| label, part note or comment-only line between `LDA #imm` and `TSB/TRB $joypadMaskStd` / `$joypadHeld` | forbidden | forbidden | refused by the `merge` guard |
| `MenuSelectionHandler.asm` | refused by `merge` | refused by `merge` | merged by IT-30 |
| a name that is a key or value of a `transforms.json` rule (A13-05: `sub_0B9CE8`, `loc_0B9CF9`, `loc_0B9D0E`, `code_02B7BD`, `loc_0386EA`, `loc_038800`, `loc_0386FA`, `loc_03880D`) | do not rename | do not rename | do not rename |

IT-27's apply file states which of these rows actually changed; that file overrides this table if they differ.

### 10.5 Sweep recipe (hygiene; used by IT-23, IT-24, IT-25 and reused by IT-47)

Run from `gaia-iog-baserom` with `rg -n -i` over `notes/blockNotes`, `notes/partNotes`, `notes/comments`, restricted to the banks of your iteration (for example `-g "bank0[23].json"`). Patterns (the classes are those of `PLAN.md`):

| Sweep | Pattern |
|---|---|
| narration (4) | `previously|formerly|the old (header|name|note|comment|label|text|description|docs)|older (header|name|note)|was (named|misnamed|wrongly|mislabel)|until I0[0-9]|renamed from|used to (be|say|read|call)|=== ?CORRECTIONS ?===|WHAT WAS WRONG` |
| ids (7) | `OQ-[A-Za-z0-9-]+|\bR-[A-Z]?I?[0-9][A-Za-z0-9-]*|\bD-S[A-Za-z0-9-]+|\bI0[0-9]{2}\b|audit (rename|proposal)|rename proposals?` |
| hedges (H) | `UNVERIFIED-RUNTIME|\(inferred\)|not traced at runtime|no emulator trace|Checked:|SAMPLED|\(E[1-5][,)]` |
| retired names (3, 10) | `will_alt|ability_fx|shadow_mode|spriteset_(enemies|particle_fx)|table_01(8000|ADA8)|itemget_table|itemcomp_table|table_1[0-9A-F]{5}|dictionary_01(EBA8|F54D)|scene_barrier|forced_walk_sequence_table|RunThinkers_Type[ABCD]|DarkGemDropSystem|floor_button|SpawnSparkleEffect` |
| buttons (13) | `\b[ABXY][ -]?[Bb]utton|\b[AB] \(\$` |

Verdict rules (from A09 §3.2–§3.7, A10 §3.3–§3.8):
1. **Narration**: delete the history and keep the current fact; if the only statement of a fact is the historical sentence, rewrite it as a present-tense fact. Keep "previously" / "old" when they are game logic ("previously loaded VRAM", "old" game data: A09 comments 48002 and 58030, A10 keys 166807, 252531). A section headed `=== CORRECTIONS ===` or `WHAT WAS WRONG` is removed; the facts it carries go into the description.
2. **Ids** (decision U7, default remove): delete the token. If the sentence says "unknown / open question", keep the sentence in plain words ("not traced: who sets bit 3"). If the id was the only content, write "meaning not established". Never replace an id by a path into `plans/`.
3. **Hedges**: a blanket `UNVERIFIED-RUNTIME` / "no emulator trace" on a claim that was read from code is noise: delete. A hedge on one specific untested claim stays, in plain words. `(inferred)`: trace the claim in code first; if it holds, drop the word, if you cannot, write "not traced".
4. **Retired names**: replace by the live label; inside a history sentence the sentence goes (rule 1).
5. **Buttons**: name the bit or mnemonic and the physical button of this build (`$0080` interact/attack is A; `$4000` cancel is B; `vblank_joypad` physical map: B `$8000`, Y `$4000`). The on-screen legend strings (`consolestring_01EADC` etc.) are game text and stay.
6. Every edit is one `merge` spec entry (A09/A10 wording: one `find` / `replace` or a whole note). Work one block or part note at a time. Skip hazards (§10.4).
7. Re-run the sweeps at the end. The residue must be 0 except the items in the verdict rules that stay on purpose; list those in the apply file by `file:key`.

### 10.6 Names-group rules (IT-36 … IT-40)

1. Spec file: `plans/extracted-audit/renames/apply-<group>_names.json`. Rows: `{ "address": <integer>, "old": "<label the extracted .asm prints now>", "new": "<name>", "row": "<A13 row id>" }`. `address` is the `; {n}` tag of the part's first instruction read from the live `extract:lt` file, never copied from `blocks.json`. For data parts without instructions (G044, G045, T001…T009) the address is the integer of the six-digit hex suffix (A13 §3.1; **dry-run first** and stop if the tool rejects it).
2. `old` must equal the label printed now. If an earlier iteration renamed the label, take the current name; if the label is gone, SKIP the row and say why.
3. Dry-run, show me the summary (rows, files, references rewritten), then **WAIT** for my go. Apply without `--local-only`: the module patches in `IOGRetranslation/` must follow the names.
4. After apply: `npm run names -- --check`, `npm run extract:lt`, `npm run rebuild` (gate). Then `rg -w` every old name over `gaia-knowledge/curated/` (not covered by the tool, A13-09) and report the hits; list the old names still present in `baserom/` as commented-out lines (A13-08) but do not edit patch sources.
5. A `!` override of a renamed label in a patch is renamed by the tool; a sub-label override (`!:`) must stay in step with its parent. Check that the dry-run lists both.
6. Never touch the DEAD list (A13 §3.11), the transform keys (A13-05) or the LEAVE rows.

### 10.7 User-owned JSON edit protocol (IT-41 … IT-46, IT-27, IT-30)

`db-us/mnemonics.json`, `copdef.json`, `structs.json`, `types.json`, `overrides.json`, `blocks.json` and `transforms.json` are edited by no sanctioned tool (A14-F16). The iteration prompt names the exact rows; the protocol is:
1. For each row re-check the live state: the key exists, the current name equals the ledger text, the decimal key equals the hex address (compute and confirm it in the extracted text), the counts (`rg -w` lines / files).
2. Write `IT<NN>_edits.md`: a table `row | file | key | old | new | counts | old-name hits outside extracted/ (baserom/, IOGRetranslation/, notes/, docs/, gaia-core/docs, gaia-knowledge/curated)`. Then **WAIT** for my go per row (default: nothing is applied without it).
3. Apply approved rows with `StrReplace` on the one line. After each group run the gate (bytes unchanged) and `npm run names -- --check`.
4. A mnemonic is **global by address** (A14-F01): a rename or ADD changes every absolute operand at that address in every file; direct-page (`Byte`) operands are never substituted. For an ADD, read every site first (`rg "\$ADDR\b"` in `extracted/` and `baserom/`), classify what the word means at each site; if any file uses it for something else, do not add the key (the row becomes ALIAS-IN-NOTE for IT-48).
5. Never rename a name that a patch or module resolves through `mnemonics.json` without a local `!name addr` (A14-F02) unless the iteration says the patch edit is approved.
6. The old names left in notes and docs after a group go to the apply file as a list; IT-47 (notes) and IT-49…IT-51 (docs) clean them.

---

## 11. Decisions for you (Part 2)

None blocks the start of phase A. The default is what the iteration does if you say nothing.

| ID | Question | Used by | Default |
|---|---|---|---|
| U7 | Ids (`OQ-…`, `R-…`) in shipped note text: remove them (A12-11, 147 cited ids), or define when an id may stay. | IT-23 … IT-25, IT-34, IT-47, IT-52 | Remove. Open questions become plain statements; the registry (IT-35) holds the ids. |
| U8 | Accept the new baseline after T01: the tagged build starts applying the ten transform rules, so the gate moves to the plain numbers (about 3,062,189 bytes) and the content of 7 diary `TSB $joypadHeld` sites and two Inca statue branches changes in the tagged text (A15-01…03). The `item_use_system` note says these edits repair vanilla quirks. | IT-27 and every iteration after it | Yes. Plain is the intended product. If you say no, IT-27 is not run and phase B/C stay on the tagged gate with the hazard list. |
| U9 | `transforms.json` housekeeping (A09-05, A15-06): remove the four dead `cop_handlers_*` keys; keep the four inert keys; the unpatched `cop_handlers_script_control` triple and the three mushroom-drop-gate blocks without a `joypadMaskStd` rule (A09-25) are only reported. | IT-27 | Remove the dead four; change nothing else; report the rest (changing the mushroom-gate masks changes the ROM). |
| U10 | Test form for tool changes (A15 §2.3 "test form is yours", A15-14): permanent `node --test` files in `gaia-iog-baserom/test/`, or acceptance by real data only. | IT-28 | `node --test` files in the baserom `test/` folder (run with `node --test`); `gaia-core` gets no test framework. |
| U11 | T04 scope (A15 §2.5): options 1 and 2 (stale-file sweep, state marker), plus the one-line `rebuild-jp` fix (A15-18). | IT-26 | Options 1 and 2 and the `rebuild-jp` fix. |
| U12 | `Dead:` marker policy (AP-19). | IT-52 | No marker. Say "no reference in extracted code" in plain words (as U3 already does). |
| U13 | spm sprite-map labels (A13-10, 4616 labels), scheme S-1 for `sprite_set_` data labels (A13 §4 item 4), tier-2 labels (about 788). | IT-39 | None of them: spm rows are not written, S-1 and tier 2 are not applied. The names tool may need an extension for spm keys; that is a separate request (§15). |
| U14 | Mnemonic names and batches: M03 `$06F2` (`musicTrackId` or `currentMusicIndex`), M11 `$0902` (`pendingMetatileVram` or `pendingTileVramAddr`); which rows of A14 §3.1 are approved. | IT-41 … IT-46 | A14's recommended names (`musicTrackId`, `pendingMetatileVram`). Nothing is applied before you answer the edit list of the iteration. |
| U15 | Cross-repo lockstep edits: `IOGRetranslation/modules/widescreen/Widescreen.patch.asm` for M13 / M16; `ChestFlaggedHiddenRedJewel.patch.asm:31`, `generic_sparkle.asm:13` and `walkable_world_map_core.asm:253` for C04 (A14-F02). | IT-42, IT-43 | **Not approved**: M13, M16 and C04 are skipped. Say "approve cross-repo" in the reply to the edit list to release them. |
| U16 | Patch-source findings that the agents must not edit (extends U4): `EquippedIcon.patch.asm:474` `?INCLUDE 'table_018000'`; `:526` raw `COP [8E] ( #06 )` (A08-12); three commented-out `code_` lines (A13-08). | IT-19, IT-36 … IT-38 | Reported only. |
| U17 | `CreditPositionLookup` block note exists in `bank09.json` and `bank13.json` (A15-11). The block starts at 649444 = bank 09. | IT-32 | Keep bank 09, remove the bank 13 copy. |
| U18 | Features outside the sanctioned tools: struct field-name slot in `gaia-core` (A14-F03: R-I064-4, R-I065-8, R-I066-2, R-I068-2/3, R-I069-4, R-I060-6b, R-I001-78 stay LEAVE); block (file) renames that move note keys (A14 §3.4, rows 32 and 38). | IT-46, IT-53 | Not in this plan. Parked in §15. |
| U19 | Things only you can do at the end: `npm run ingest:all` in `gaia-knowledge` (A11 §2.5); regenerate `IOGRetranslation/artifacts/file-layout.json` (D110); commit each repo touched (`gaia-iog-baserom`, `gaia-core`, `IOGRetranslation`, `gaia-knowledge`); keep or delete `db-us/mnemonics_new.json` (A14-F12) and `temp/*.mjs` (U6). | IT-53 | Listed in the IT-53 apply file; not done by agents. |

---

## 12. Part 2 iteration prompts

Prompts for mechanism M, N, D and R are pasted after the **Fix preamble** (§3); prompts for T and U after **Preamble B** (§10.2). `IT<NN>` is the number of the iteration you run. Every prompt says which findings to read; read the cited ids in full, they carry the evidence.

### Phase A: notes (tagged gate, hazards of §10.4)

### IT-17 — `scene_script.asm` second pass (A10 "F10")

Reads: [A10](A10_findings.md) §3.1 (A10-01 … A10-10 and the "checked and correct" paragraph after the table) · [report.md](report.md) §4 N-1, N-2, N-3 · `IT01_apply.md` (what IT-01 already changed).

```text
ITERATION IT-17. Targets: extracted/system/engine/scene_script.asm and its entries in notes/ (bank 02). Mechanism: merge only. IT-01 rewrote part of the scene-script notes. First read IT01_apply.md and the live text, then handle only what is still wrong or still missing. Re-derive each fact from the handlers; the A10 wording is a hint.
1. Block-note opcode table, row $10 (A10-02): SceneCmd_LoadSpriteTiles decompresses to WRAM $7E:4000 and scene_meta.asm calls the opcode "spritemap". Say "sprite map" and the staging address in the row and in the summary line ("load sprite tiles").
2. Rows $13, $14, $15 and SkipScriptCommands (A10-04): the table rows, the SceneCmd_Label part note, the SkipScriptCommands header (about line 1588) and part note, the comment near tag 167302 and the SceneCmd_Branch comment near tag 164949. Verify, then write: SkipScriptCommands reads one byte (a label id) and rescans the scene from the script base (two INY over the scene id); it stops at an opcode $14 whose operand equals the saved id (not at $15); opcode $15 only skips its one operand; $12 ends at once; $00 restarts after a 2-byte id. So the scan starts at the beginning: it does not "skip the rest of the block". SceneCmd_Label consumes its id byte: it is not padding. $13 = branch if a flag is set (flag, label id), $14 = label, $15 = jump to a label id. If IT-01 already wrote this correctly, record it as already correct.
3. Graphics cache ring (A10-07): re-read ComputeRingBufferAddr (about line 1950). State base and end of the ring in the "GRAPHICS CACHE SYSTEM" paragraph: four slots of $2000 from base $4000 end at $BFFF, not $DFFF; confirm the base from the code.
4. Script pointer mapping (A10-08): the block note "SCRIPT POINTER ADDRESS MAPPING", the LoadScriptPointer part note (header about 1662) and the comments near tags 167336 and 167341. Re-derive from about lines 1676-1688: a bank below $70 gets +$80; if the result is $A0 or more, a further $20 is added and bit 15 of the word is cleared; a bank of $70 or more is unchanged. So original $00-$1F -> $80-$9F, original $20-$6F -> $C0-$EF, $70 and up unchanged. Rewrite all four texts to this.
5. Comment near tag 166738 (A10-10): `TRB hudDisableFlag` with #$40 clears bit 6, so the HUD is shown; replace "(HUD off)".
6. Verify and record, change only if still wrong: A10-01 (rows $04-$06), A10-03 (SpcMusicLoadCmd: equal runs the load), A10-05 (jump-table part note), A10-06 (table_018000), A10-09 (comment near tag 166924).
No history narration, no OQ ids, no mnemonic renames. Do not put a comment on a line listed in the hazards of section 10.4 (none are expected in this file).
```

### IT-18 — Wait wording: residual sweep and verification of IT-02

Reads: [A10](A10_findings.md) §3.6 (A10-17a … f) · [A09](A09_findings.md) §3.5 (A09-16 … A09-19) · [A01](A01_findings.md) F4 · [A04](A04_findings.md) A04-02, A04-03, §6 · `IT02_apply.md`.

```text
ITERATION IT-18. Mechanism: merge only. Rule: WaitByte #n, WaitWord #n and a wait counter stored in $08 run n+1 ticks. Confirm it once in the runner (actor_execution.asm DEC $08 / BPL pattern and cop_handlers_wait.asm) before editing.
1. Read IT02_apply.md: list what it applied and what it left NOT-VERIFIED.
2. Re-run the sweep over notes/ (all banks) and extracted/: `rg -n -i "wait(byte|word)?[^\"]{0,40}frames?|(waits?|delay|hold|pause|sleep)[^\"]{0,30}[0-9A-F$]+ frames?|one frame|\$08 *(:=|=)"`. For each hit read the operand in the code and compare the stated count with n+1.
3. Check that IT-02 applied each of these, and apply what is missing: A09-16 hit_switch (comment key 51768, part note HitSwitchTriggered: #0F = 16 ticks); A09-17 camera_drift (key 53343, part note loc_00D05B: $08 := 3 = 4 ticks); A09-18 npc_wander_ai (key 51059, part note NpcWanderStageStand: $78 = 121 ticks); A09-19 cop_handlers_script_control (key 43563: "N + 1 ticks"); A10-17a #48 = 73 ticks (partNotes bank02 lines 47 and 199, blockNotes bank02 line 31, keys 174227 and 172261, warps_interaction.asm 522 and 529); A10-17b #0B = 12 ticks (key 174216, warps_interaction.asm 52); A10-17c #01 = 2 ticks (key 172250, music_actors.asm 122 and 125); A10-17d (partNotes bank03 line 113: "WaitByte one frame" contradicts the same note's "#01 = N + 1"); A10-17e #77 = 120 ticks (partNotes bank03 line 119 and comment key 238213).
4. A10-17f (REPORTED, re-read each): dm3D_flayzer.asm:467 (#4F), dm3D_grundit.asm:60 (#77), dm41_bat_spawner.asm:29 (#3B), ir21_switch.asm:45 (#3B), ir25_ceiling_tile.asm:24 and 27 (#3B, #B3). State operand and ticks.
5. Leave alone (A09/A10 verified them as right): comment keys 51643, 59675, 39463; partNotes bank00 line 117 (code_00E8DA); blockNotes bank00 lines 55 and 132; the bank0B and bank08 keys listed in A10 §3.6 "Correct".
6. A LoopStart / LoopEnd counted wait (town_door.asm "8 frames to hold Up", A09 §4 item 7): only change it if you trace the count through LoopEnd in the runner; otherwise list it as NOT-VERIFIED.
Do not edit the item_use_system CMP lines (hazard, section 10.4) before IT-27.
```

### IT-19 — Notes that contradict the code (A12 + A08 outside the tables)

Reads: [A12](A12_findings.md) §5 (RC-01, RC-07, RC-08, RC-09, RC-14) and §7 A12-01 … A12-06 · [A08](A08_findings.md) §2.2 A08-10, A08-11, A08-12.

```text
ITERATION IT-19. Mechanism: merge only. Comment-only and note-only corrections where a note states the opposite of the code. Re-derive each from the cited code.
1. A12-01 DialogStringRenderer.asm line about 142: the comment "consumer not traced; see audit OQ-23" is wrong and cites an id. The consumer is Bg3TilemapVramDma (camera_tilemap.asm about 880-892): it tests mask $31 of displayModeFlags; bit 0 = full BG3 tilemap upload ($0800 bytes), bits 4 and 5 = partial upload ($0140 bytes); the bits are cleared after the transfer. Name the consumer; no id.
2. A12-02 sFB_boot_logo.asm lines about 5 and 49 and the inventory_overlay note that cites OQ-I034-1: "displayModeFlags bit 14: no reader found". Bit 14 is bit 6 of hudDisableFlag: read by UpdateHUD (system_core.asm about 396-401) and the HUD routine (scene_lifecycle.asm about 924-936); the scene command $02 (display preset) sets it per scene. Rewrite both notes. sFA_diary_menu.asm line 7 already says "HUD off": do not touch it.
3. A12-03 combat_collision.asm lines about 53 and 751: the sign of the hit counter ($7F0028) is reversed. The reader actor_execution.asm about 25 and 159-165 says positive = hit-stun (non-player actors freeze), negative = recovery/invincibility, and combat_collision skips victims with a negative counter. Verify, then fix both sentences. IT-06 may have done this: record "already correct" if so. Never write the literal $8000 in this file (hazard).
4. A12-04 combat_collision.asm about 1207 (inline comment on BIT #$0280 of the actor word): "$0200 game-over / $0080 iframe-active" is wrong. Actor $10 bit $0200 = the actor must not be hit (skip mask $76E0 at about 333, friendly pass $74E0 at about 340, BIT #$0280 sends the actor to the friendly-only pass at about 1207); game over is playerFlags $0200 (about 162-174). Replace the comment accordingly.
5. A12-05 StopPlayerOnDeath.asm lines about 5 and 21 (and its block note): the claim "no reader of actor $10 $0200 was found" is false; cite the readers of item 4. Do not discuss the mnemonic name deathFlag.
6. A12-06 debug_stat_setter.asm about line 5: "no reader of $0B22" is false. system_core.asm about 416-423 (UpdateHUD) decrements it, raises playerHp and plays sound $0D. IT-07 may have done this: record it if so.
7. A08-10: replace the retired dictionary names by the live labels in DisplaySceneTitle.asm lines about 112, 113, 143, 145, 171, 175 and DialogStringRenderer.asm about 1004 (write dialog_dictionaries.dialog_dictionary_a / dialog_dictionary_b). Do not touch db-us/stringTypes.json: the ids there are keys.
8. A08-11: attack_ability_system.asm about 659 ("table_178000": the live label is spriteset_dark_friar). Lines 552 and 1850 of the related files belong to IT-11.
9. A08-12: cop_handlers_player_sprite.asm about line 33 says "24 sites": write "24 sites in extracted/ and one more raw COP [8E] in baserom/equipped-icon/EquippedIcon.patch.asm". Do not edit the patch (decision U16).
Do not record answers to open questions here (IT-35 does). No ids, no history narration.
```

### IT-20 — I069–I072 sprite sets without hidden groups, and `body_table` row `$06`

Reads: [A08](A08_findings.md) §2.1 A08-01 and A08-09, §2.4 A08-14 / A08-15 / A08-16, §2.6 (a), (d).

```text
ITERATION IT-20. Targets: extracted/tables/spriteset_freedan_fx.asm, spriteset_shadow_fx.asm, spriteset_dark_friar.asm, spriteset_shadow_aura_body.asm, and extracted/tables/body_table.asm (rows only). Mechanism: merge only.
1. A08-01: spriteset_shadow_aura_body.asm about line 33 says "thirteen small groups of 2 ticks each". Records ;06-;12 have hold #$0002 = 3 ticks (hold n = n+1 ticks: cop_handlers_sprite.asm). Write "thirteen small groups of 3 ticks each (hold 2)". Re-check the rest of the file's tick figures with the same rule (lines about 24 and 84 are right).
2. A08-14 / A08-15 / A08-16 in the four files (lines about: freedan_fx 1 and 10; shadow_fx 1 and 13; dark_friar 1 and 13; shadow_aura_body 1 and 13): delete the history sentences ("the old note ... was wrong"), remove the ids (OQ-I069-3, OQ-I069-1, OQ-I071-1) and keep one plain limit sentence per file ("the art was not viewed"). Drop evidence tags and sampling percentages.
3. A08-09 body_table.asm rows $05-$07 (about lines 32-34): the generic row texts. Row $06 = Freedan's body poses for the Aura Barrier cast and the vine drop (SetPlayerSpriteDirect #06; sites player_character.asm about 603 and attack_ability_system.asm about 402). Row $07 = not selected by any SetPlayerSpriteDirect operand; content not used (spriteset_shadow_fx.asm line 1 says so). Verify with `rg -n "SetPlayerSpriteDirect\]" extracted baserom --glob "*.asm"` (expected 24 sites: #04 x14, #05 x7, #06 x2, #08 x1; none with #07) and `rg -n "COP \[8E\]" extracted baserom --glob "*.asm"` (one raw hit in the EquippedIcon patch, #06). IT-05 owns body_table: if it already wrote these rows correctly, record that.
No hidden group exists in these four files (A08 §2.3): do not write about extractor artefacts here. spriteset_will_abilities, spriteset_pickups_effects, inventory_spritemap and spriteset_transform_poses belong to IT-34 (after the extractor change IT-33). A08-12 is IT-19. No mnemonic renames.
```

### IT-21 — I069–I072 string and list tables

Reads: [A08](A08_findings.md) §2.1 A08-05 … A08-08, §2.4 A08-14 … A08-16, §2.5 A08-17 / A08-18, §2.6 (b), (c), (d) (the facts that came out right).

```text
ITERATION IT-21. Targets: extracted/tables/enemy_clear_reward_table.asm, system_strings.asm, dialog_dictionaries.asm, scene_thinkers.asm, scene_chest_table.asm (verify only). Mechanism: merge only.
1. A08-05 enemy_clear_reward_table.asm about line 10: "Values above 3 do not occur; the readers treat 3 and above as DEF" is true for one reader only. StandardEnemyDefeatHandler (EnemyStatBonusReward, about 216-220) sends everything above 2 to DEF; field_reveal_object.asm about 49 masks with $0003; BossClearApplyStatReward (boss_clear_reward_handler.asm about 176-181) pays DEF only for exactly 3. No value above 3 exists (tiers 0/1/2/3 = 169/29/27/31). Write that, or drop the sentence.
2. A08-06 system_strings.asm: the block note (about line 11, "two to four rows") and the item_description_table part note (about 447, "three or four rows") are wrong. RECOUNT with Grep first: of the 41 entries $00 'Nothing' has no [DBL], $06 has one, and the rest have two or three. Expected 27 with two and 12 with three; no entry has four. Write "one to three [DBL] lines (two in N entries, three in M, one in $06)" with your recounted N and M, and state the unit once ([DBL] = two tilemap rows per line).
3. A08-07 system_strings.asm about 717 (part note of consolestring_01E7F6): strings 01E82B, 01E834, 01E83D print digits 1, 2, 3 at (DE,1); 01E846 and 01E85C print raw tile 0; 01E851 prints a number from RAM $08 ([NUM:8] at (9E,1)). Rewrite the sentence accordingly.
4. A08-08 system_strings.asm about lines 9 and 244: item_name_line_table holds the names on one line except that $03-$05 use the shared word [LU:4] = 'Inca ' (shared_word_table.asm about 64), so they read 'Inca Statue A/B' and 'Inca Melody' where item_name_table reads 'Incan ...'. Add that exception. Both spellings are in the ROM; no rename.
5. A08-14 / A08-15 / A08-16 in these files: delete history narration (system_strings.asm lines 1, 26-28 "WHAT WAS WRONG IN THE OLD NOTES" paragraph, 46; enemy_clear_reward_table 1 and 12; dialog_dictionaries 3 and 10; scene_thinkers 1; scene_chest_table 1); remove ids (system_strings 24, 244, 717; dialog_dictionaries 12; scene_thinkers 455, 589, 634); drop the evidence tags ("(E1, counted in the extracted file)", "SAMPLED about 6%") and keep one plain limit sentence ("was not traced") per file. A sentence that is the only statement of an open question stays in plain words.
6. Leave alone (A08 §2.6 verified them): the 59-of-70 dispatcher count, the 200 entries of dictionary B, the chest and reward counts. A08-17 and A08-18 are REPORTED (credits frames of spriteset_will_abilities, chest tile ids): do not change those sentences; list them in the apply file as REPORTED.
No hidden-group text, no mnemonic renames.
```

### IT-22 — Static checks that no A-step did (CF-7)

Reads: [A07](A07_findings.md) A07-23, A07-24 · [A06](A06_findings.md) A06-20 · [A01](A01_findings.md) §2 rows 24, 51, 76, 80, 81 · [A04](A04_findings.md) §6, §10 · [A02](A02_findings.md) §8 · [A03](A03_findings.md) §9 · `IT02_apply.md` (NOT-VERIFIED list).

```text
ITERATION IT-22 (static checks). Mechanism: merge for note corrections; the results go into IT22_apply.md only (no new ledger file). Each item below was never checked, or was left NOT-VERIFIED. For each: run the check with rg and Read, state the result with file:line, and if a shipped note is wrong correct it through merge; if the note is right, leave it. If a check cannot be done with rg and Read in reasonable effort, mark it NOT-VERIFIED with the reason.
1. A07-23: enemy_stats_table.asm about line 21 says 16 rows are unused. Census: for each stat row id, count enemy-spawn records in tables/scene_actors.asm (byte 6 = stats row; read the record format at the top of that file) that use it. Method: one rg per row id or one multiline rg per range. Report the unused rows; correct the sentence if the list is different.
2. A07-24: scene_thinkers / actors: "Projectile* appears only in scene $E8". Check every spawn record and SpawnList reference of the Projectile* actors; correct or confirm.
3. A06-20: move_chain_table.asm lines about 7-10 give a 58 / 26 split of chain ends. Recount from the table rows and correct the numbers if they differ.
4. A04 section 6 / IT-02 NOT-VERIFIED: PaletteStep "wait 2 each" in shadow_shimmer.asm, global_ambient_dispatcher.asm, SpawnItemSparkleEffect.asm (read the PaletteStep handler: what is the wait operand and is it n or n+1); town_door.asm "WaitWhileOffscreen ( #0A ) every 10 passes" (read the handler); A02 section 8: is the walk/run window of player_character.asm 13 or 14 states (read the SetAutoWalkTimer / invincibilityTimer-named counter sites). State the number with the tick rule.
5. A03 section 9: the ramp watch blocks and the scanline-band counts of the band actors: recompute the counts named there and compare with the notes.
6. A01 rows 24, 51, 76, 80, 81 (the "never checked" rows): read each row, decide whether the shipped note or doc line it points at is still wrong. Notes: correct here. Docs: list for IT-49 / IT-50 / IT-51.
7. Static answers to open questions that fall out of these checks (OQ-ids): record them in IT22_apply.md as "answer + file:line"; IT-35 collects them. Do not write ids into notes.
Do not touch hazard lines (section 10.4). No mnemonic renames.
```

### IT-23 — Residual hygiene sweep, banks 00–01

Reads: [A09](A09_findings.md) §2 (sweep patterns), §3.2 (A09-07 … A09-11), §3.3 (A09-12), §3.4 (A09-13 … A09-15), §3.7 (A09-22, A09-23), §3.6 (A09-20) · §10.5 of this plan.

```text
ITERATION IT-23. Targets: notes/blockNotes, partNotes, comments for bank 00 and bank 01 (-g "bank0[01].json"). Mechanism: merge only. Procedure: section 10.5 of ACTION_PLAN.md (sweep recipe and verdict rules), decision U7 default (ids removed).
Part 1 (IT-12, IT-13) already cleaned the files of I001-I060; this iteration picks up what is left. Run the five sweeps first and write the hit list into the apply file. Known residue to look for (A09):
- Narration: A09-07 (22 bank00 block notes: ApplyOrbitalOffsetFromRef, ApplyOrbitalOffsetXY, ApplyPlayerHitstun, boot_logo_enix_palette_obj0/_obj1/_obj2, boss_clear_reward_handler, DamageNumberShort_unused, EscortFollowPathTracker, field_reveal_object, game_over_sequence, global_ambient_dispatcher, hit_switch, interaction_handlers, layer1_scroll_actors, overworld_exit, player_transition_handlers, SetPlayerIdleFacing, smooth_follow_child, SpawnFieldRevealEffect, StandardEnemyDefeatHandler, town_door; bank01: body_table, move_chain_table, walk_step_table); A09-08 (large_ramps, oneshot_coldata_r11g4b2, SpawnDebrisBurst, comment key 50938 "older header"); A09-09 (seven "=== CORRECTIONS ===" / "WHAT WAS WRONG" sections); A09-10 (retired names inside history sentences: AttackTrailShort_unused, DarkGemDropSystem, SpawnDarkGemType1, incan_ruins_transform_palette, floor_button, SpawnAttackTrailEffect, boot_logo_palette_quintet, boot_logo_palette_third, scene_chest_table "The old note"); A09-11 (REPORTED candidates of the broader pattern "The old ...": read each, strip real narration, keep game-logic uses).
- Ids: A09-12 (99 notes: the key lists in A09 section 3.3 for blockNotes bank00 (38), bank01 (9), partNotes bank00 (17), bank01 (6), and the 29 valid comment keys 32830 ... 60819).
- Hedges: A09-13 (blanket UNVERIFIED-RUNTIME: ApplyOrbitalOffsetFromRef, ApplyPlayerHitstun, hit_stagger_controller, body_table: delete), A09-14 (FlickerParentActor, interaction_handlers, large_ramps, ability_damage_tables, enemy_stats_table, walk_step_table, music_pointer_array: keep the one specific claim in plain words; for large_ramps "whether another path adds speed" find the writers of playerSpeedNs and settle it or write "not traced"), A09-15 (comment key 39694: verify the OAM priority-bit claim against the handler, then drop "(inferred)"), plus the partial cases SpawnDebrisBurst and move_chain_table.
- Buttons: A09-22 (comment key 33009 "Process B-button dodge callbacks" on system_core.asm about 242: ProcessDodgeCallbacks tests BIT #$0080 of joypadCurrent, combat_collision.asm about 136: the bit is the A position in this build; word it "action bit $0080 (A button in this build)"); A09-23 (comment key 43300 "A/B to advance": read the text-advance mask in cop_handlers_dialog.asm and the renderer, then name the logical bit or the physical button). Leave alone: comment 49098, blockNotes bank00 lines 35 and 84.
- A09-20 (retired nicknames will_alt / ability_fx / shadow_mode in 11 notes and comments): IT-05 should have done these; apply what is left.
Skip anything on a hazard line (section 10.4). Skip files whose owner iteration (section 6.4) is not DONE and say so. At the end re-run the sweeps and list the residue by file:key.
```

### IT-24 — Residual hygiene sweep, banks 02–03

Reads: [A10](A10_findings.md) §3.3 (narration), §3.4 (ids), §3.5 (hedges), §3.7 (A10-18a … c), §3.8 (buttons) · [A12](A12_findings.md) A12-13, A12-07 · §10.5 of this plan.

```text
ITERATION IT-24. Targets: notes/blockNotes, partNotes, comments for banks 02 and 03 (-g "bank0[23].json"). Mechanism: merge only. Procedure: section 10.5 (sweeps and verdict rules), decision U7 default.
Known residue (A10):
- Narration (21 real lines): blockNotes bank02 lines 15, 16, 17, 19; partNotes bank02 line 127; comments keys 185346 and 186088; blockNotes bank03 lines 24 and 25 (including the "=== CORRECTIONS ===" section). Keep the noise hits (blockNotes bank02:22 "previously-saved VRAM", partNotes bank02:258, comments 166807 and 252531).
- Ids: the per-file counts in A10 §3.4 (comments bank02 30, bank03 16; partNotes bank02 14, bank03 13; blockNotes bank02 12, bank03 10). A12 §6 gives the answered-but-cited ids (OQ-5 display_preset_table, OQ-I029-4 player_move_west/east): state the fact plainly. Where a sentence only says "(OQ-I025-1)" after a bit meaning, write "meaning not established".
- Hedges: blockNotes bank02 lines 15-18 (four blanket "UNVERIFIED-RUNTIME ... arithmetic is read from the code": delete, keep one plain "not run in an emulator" per note at most); partNotes bank02 lines 202 and 384 (token and id out); partNotes bank03:109, blockNotes bank03:5, comments bank03 keys at lines 438 and 1316, comments bank02 line 737 ("(inferred)": trace each in the code; drop the word if it holds, else "not traced").
- Retired names: A10-18a blockNotes bank03:8 (will_alt, ability_fx -> spriteset_will_abilities for $04 and spriteset_transform_poses for $05; body_table rows 31-32); A10-18b "barrier" for PlaceOpenedChestTiles in blockNotes bank03:20, partNotes bank03:26, comments key 253481 (it redraws already opened chests: partNotes bank02:210, blockNotes bank02:10); A10-18c comment key 173599 TileCoordsToMapIndex "top-left barrier cell" (REPORTED: check; an event-block cell, not a barrier).
- Buttons: A12-13: add one header line to the notes of inventory_menu.asm (about lines 326, 359, 473) saying which vocabulary the file uses (logical bits of this build: B $4000 cancel, A $8000 ... check each in the code against transforms.json remap rows 755-758 and vblank_joypad.asm physical map B $8000 / Y $4000). MenuSelectionHandler.asm is IT-30: skip it.
- item_use_system comments at keys 231160 and 231435 (they cite OQ-I026-1 and mix BNE and BEQ): leave them to IT-29.
Skip hazard lines (section 10.4). Note files outside the audited ranges only for the patterns above. At the end re-run the sweeps and list the residue by file:key.
```

### IT-25 — Residual hygiene sweep, banks 04–1E

Reads: [A10](A10_findings.md) §3.3, §3.4, §3.5, §3.7, §4 (what was only sampled) · [A12](A12_findings.md) §6 · §10.5 of this plan.

```text
ITERATION IT-25. Targets: notes/blockNotes, partNotes, comments for banks 04 through 1E (-g "bank0[4-9A-F].json" -g "bank[1][0-9A-E].json", i.e. every bank file except 00-03). Mechanism: merge only. Procedure: section 10.5 (sweeps and verdict rules), decision U7 default.
Known residue (A10):
- Narration: blockNotes bank0B lines 9, 11, 12, 51, 54; bank08 lines 40, 42, 84 (keep line 4 "previously blocked passage"); bank0A lines 27, 29; bank14 lines 3, 5; bank17 line 8; each with its "=== CORRECTIONS ===" section where present.
- Ids (A10 §3.4 per-file counts: partNotes bank0C 4, 0E 4, 0F 4, 16 4, 08 2, 0B 1, 15 1; blockNotes bank14 4, 17 5, 0A 3, 0B 3, 08 3, 0E 2, 0F 2, 0D 1, 10 1, 1D 1, 15 1; comments bank0A 2, 08 1, 0B 1). Old bare ids (OQ-8, 15, 16, 23, 58, 61, 62, 63, 64, 67) may refer to closed questions: A12 §6 lists the closed ones (OQ-61, OQ-64 in hdma_dma_spc / radar_map_screen, OQ-I054-1 in the boot-logo palette actors).
- Hedges: partNotes bank0B line 266 ("UNVERIFIED-RUNTIME whether anything reaches it": real open claim, keep in plain words); blockNotes bank08 lines 15 and 41, bank0A lines 27, 28, 47, bank0B line 54 (twice), bank0C line 2, bank14 line 3 (genuine statements of what a static read cannot show: remove the token and any id next to it).
- Banks 04-0F were only sampled for orphans and hygiene (A10 §4): run the sweeps over every file of these banks, not only the lines above, and read each hit.
Do not change facts in files that were not audited unless the sweep pattern hits; if a hit needs a fact you cannot re-derive quickly, strip only the id or the history and list the sentence as NOT-VERIFIED.
Skip hazard lines (section 10.4). At the end re-run the sweeps and list the residue by file:key.
```

### Phase B: tools, transforms, orphans

### IT-26 — T04: extract / rebuild hygiene (Preamble B)

Reads: [A15](A15_findings.md) §2.5 (the `rm -rf` analysis and spec), §2.6 (AP-23 hypotheses), A15-15, A15-16, A15-17, A15-18, §3.2 item 5 · decision U11.

```text
ITERATION IT-26 (T04). Mechanism: T. Goal: stop `npm run extract` / `extract:lt` from deleting extracted/ (the `rm -rf extracted/*` that fails with "Device or resource busy" and leaves a partial tree), and stop `rebuild` from accepting an incomplete tree.
Allowed edits: gaia-iog-baserom/src/index.ts, one new file src/extract-state.ts (only if you want the marker helpers outside index.ts), the "extract" and "extract:lt" scripts of gaia-iog-baserom/package.json (and the same `rm -rf` prefix in any sibling script of that file that deletes a directory the same way, such as the -jp extract scripts). Extra commands: none.
1. Read src/index.ts (extract function, rebuild about lines 133-168, rebuild-jp about 226-229), package.json scripts (about lines 26-27), and gaia-core src/rom/extraction (read only) to learn how the extractor writes files. CONFIRM the extractor writes every output file on every run (an unconditional write). If it can skip a file whose content is unchanged, STOP and ask me: a stale-file sweep by modification time would delete valid files.
2. Stale-file sweep (A15 §2.5 option 1): record start = Date.now() before extraction; after it, walk extracted/ and delete every FILE whose mtime is older than start, with fs.rmSync(path, { force: true, maxRetries: 10, retryDelay: 200 }); keep empty directories; print "stale files removed: N". Remove `rm -rf extracted/* &&` from both scripts.
3. Completeness marker (option 2): write extracted/.extract-state.json = { status: "running", mode: "tagged" | "plain", startedAt } before the first file and { status: "complete", mode, files: N, finishedAt } after the last. `rebuild` refuses with "extracted/ is incomplete (.extract-state.json says 'running'); run npm run extract:lt" when the status is "running"; a MISSING marker is only a warning (existing trees have none). Write `mode` into artifacts/crc.json. A dot-file is skipped by the engine (A15 §2.5: listDirectory / applyFolder), so the rebuild input is unaffected: verify that claim by reading the two code sites.
4. rebuild-jp (A15-18): src/index.ts calls rebuild(...) (the US paths) where rebuildJp(...) is meant. Fix the call if rebuildJp exists with that signature. You cannot test it without the JP inputs: say so.
5. Tests (no scripts; use the Write tool for the dummy file): (a) Write extracted/zz_stale_test.asm containing one comment line; run `npm run extract:lt`; the file must be gone and the output must say 1 stale file removed. (b) Run extract:lt again: 0 stale files, and `git status --short extracted` identical to after (a). (c) Write extracted/.extract-state.json with status "running"; `npm run rebuild` must refuse with the message above; run `npm run extract:lt` to restore the marker. (d) Normal gate.
6. Gate: `npm run extract:lt`, then `npm run rebuild`; numbers must equal the current gate (section 10.3). No ROM change is expected from this iteration.
No other file may change. Do not touch notes, names, transforms.
```

### IT-27 — T01: tag-tolerant transforms and the new gate baseline (Preamble B)

Reads: [A15](A15_findings.md) §2.1 (R1 … R12 and the tolerant forms), A15-01 … A15-07, §3.1, §3.2 item 1 · [A09](A09_findings.md) A09-05, A09-25 · [A02](A02_findings.md) §9 · [A03](A03_findings.md) §8 · `PLAN.md` T01 prompt · decisions U8, U9.

```text
ITERATION IT-27 (T01). Mechanism: U. Precondition: decision U8 (accept the new baseline) is yes (default). If I answered no, stop at once and say so.
Allowed edits: gaia-iog-baserom/db-us/transforms.json (the rules named below and the four dead keys), the T01 acceptance sentence of plans/extracted-audit/audit-of-audit/PLAN.md (only that sentence), and the Progress log of ACTION_PLAN.md. Extra commands: npm run extract (plain build) in addition to extract:lt.
Goal: make the ten multi-line rules that only match when no "; {n}" tag follows the line ends tag-tolerant, so the plain and the tagged build produce the same ROM and comments are safe at the former hazard addresses.
1. Re-measure first (A15 reports plain numbers from I026 that were never reproduced). Run `npm run extract`, then `npm run rebuild`: record P0 (expected totalSize 3062189, checksum 222967024, crc -1004081563). Run `npm run extract:lt`, then `npm run rebuild`: record T0 (expected 3062204, 223006080, 2083230829). If either differs from the expected numbers, STOP and report; the tree has changed since the audit.
2. One rule at a time, in this order: R7, R10, R1, R3 (3a and 3b), R4, R8, R9 (A15 §2.1 gives the tolerant forms; they were designed, not run). In transforms.json a literal "$" in a value must be written "$$" (R1: #$$0120). Read the existing tolerant rules at lines about 196-199 and 489 and copy their JSON escaping. R3: keep the existing prefix behaviour of `STA \$00` (it also matches `STA $0012`) so the bytes stay identical. R4: the original rule is `$1$1` (the span twice); the tolerant form must keep the second copy WITHOUT tags (A15-07), otherwise merge fails with "tag appears on 2 lines". After EACH rule run both builds (plain then tagged, each followed by rebuild) and record both numbers. Expected after the rule: the plain numbers do not change (the tolerant rule still matches the same plain sites); the tagged size moves by exactly the rule's delta (R1 -4, R3 +6, R4 +16, R8 -24, R9 -9; R7 and R10 do not change the size: verify their content effect by Grep on the tagged tree: the 7 diary sites now read #$8300 / #$4000 and the two Inca statue branches read BEQ). Any other result: undo that rule and report.
3. After the last rule both builds must equal P0. If they do not, find the rule that differs (the per-rule log tells you) and stop.
4. Dead keys (U9): confirm that blocks.json has no block for cop_handlers_lifecycle, cop_handlers_solid, cop_handlers_spatial, cop_handlers_map, then remove those four keys (lines about 46, 58, 70, 76). Both builds must still equal P0. Do NOT change: the four inert keys (cop_handlers_audio, _palette, _spawn, actor_pool), the label-spanning rule R5 (diary_band swap: leave it; the merge guard of IT-28 protects it), the unpatched cop_handlers_script_control triple (report it), or the three mushroom-drop-gate blocks without a joypadMaskStd rule (A09-25: report it; changing masks changes the ROM).
5. PLAN.md: change the T01 acceptance sentence (A15-02): both builds must equal each other AND the re-measured plain numbers P0; the recorded gate moves once.
6. Progress log: append the normal line and one line "GATE: <date> IT-27 checksum <n>, crc <n>, totalSize <n> (plain and tagged build identical)" with P0.
7. Apply file: the per-rule table (rule, plain numbers, tagged numbers), the list of hazards that are now lifted (the rows of ACTION_PLAN.md section 10.4 you actually verified; "lifted" means the key now tolerates a tag tail; note that IT-29 is the first iteration that proves it with a real comment), the items you reported but left, and the removed keys.
End with the tagged tree in place (`npm run extract:lt`).
```

### IT-28 — T03: `merge --check`, `merge --prune`, transform guard (Preamble B)

Reads: [A15](A15_findings.md) §2.2 (guard), §2.3 (check, prune, AC-1 … AC-8), A15-08, A15-09, A15-11, A15-12, A15-21, A15-22 · [A09](A09_findings.md) A09-06 · [A03](A03_findings.md) §8 · [A02](A02_findings.md) A02-03, A02-08 · decision U10.

```text
ITERATION IT-28 (T03). Mechanism: T. Depends on IT-27 (the guard's comment rules are only needed for the rules that stay label-spanning or literal).
Allowed edits: gaia-iog-baserom/src/merge.ts, src/notes-common.ts, new files src/merge-check.ts and src/transform-guard.ts (names are yours), src/index.ts (the CLI flags only), gaia-iog-baserom/package.json (a "test" script only if needed), new test files test/*.test.ts with fixtures under test/fixtures/ (decision U10), and the section "Notes Merge" of gaia-core/docs/notes-and-comments.md (document the new flags and the guard; replace the two embedded Python scripts of "Rename propagation checklist" lines about 599-700 by a pointer to `npm run names` and `npm run merge -- --check`: A11 AP17-01, AP17-02). Extra commands: node --test test/ (run only the test files you added).
Build, in this order, each with a test:
1. The guard (A15 §2.2). Build the tail-free view of each extracted file (strip `\s*;.*$` per line), run every multi-line key of the block's rules over it, collect the "{n}" tags and the labels spanned, and reject: a comment whose tag is inside a span of a rule that is not tag-tolerant (the message of A15 §2.2 step 5); a part note on a label named in a label-spanning key (diary_band_slot1 / diary_band_empty). Rename rules (key and value plain identifiers, A15-22: mtA0_skulker sub_0B9CE8 -> sub2_0B9CE8 ...): translate a part-note key written for the new name to the old name, and let --check accept either. Add the literal guard that A03 section 8 asks for: for a block with a single-line transform whose key is a plain literal and whose value differs (combat_collision and actor_execution rewrite every literal $8000 to $0080), reject a note or comment text of that block that contains the literal. READ src/index.ts first to confirm where transforms run relative to note insertion; if notes are not inside the transformed text the literal rule is unnecessary: say so and skip it. Leave the existing MenuSelectionHandler refusal (merge.ts about 248-249) in place: IT-30 removes it.
2. `npm run merge -- --check [--bank NN]` (A15 §2.3): read-only; exit 1 on any error, exit 0 with warnings; needs a tagged tree (stop with "extracted/ has no address tags; run npm run extract:lt" otherwise, and when the marker of IT-26 says mode plain). Checks 1-6 of §2.3 with the message formats given there (comment key live iff exactly one line has its tag, with the block-offset hint; part-note key must be a label or a rename alias, with the "names maps <address> to '<name>'" hint for <prefix>_<6 hex digits> keys; block-note key must be a file and a block; one bank file per key; the six detectBank rules; the guard on existing notes).
3. `npm run merge -- --prune <orphans.json> [--dry-run]` (A15 §2.3): refuses any key that the check does not report as an orphan or duplicate; removes only the listed keys; re-runs the check and the disk verify. The file shape is { "comments": [...], "partNotes": [...], "blockNotes": [...] }; for a duplicate (A15-11: CreditPositionLookup in bank09.json and bank13.json) a key may be written "bank13:CreditPositionLookup" to name the copy to remove.
4. Acceptance cases AC-1 … AC-8 of §2.3 as tests: AC-1, AC-2, AC-4, AC-5 against the real tree (assert the counts: 80 comment orphans in banks 00 and 02, 6 + 1 block-note orphans, the duplicate); AC-3, AC-6, AC-7 and AC-8 with fixtures (a copy of the needed notes/extracted files, a transforms.json copy that still has an intolerant rule for AC-8). `--prune` must be tested on a COPY of notes/ (a fixture), never on the real files in this iteration.
5. Regression: run `npm run merge -- <one already-applied spec from plans/extracted-audit/audit-of-audit/ or renames/> --dry-run` before and after your change; the result must not change.
6. Run `npm run merge -- --check` on the real tree and write the complete output into IT28_apply.md (IT-31 and IT-32 start from it). Do not prune anything.
Gate: npm run extract:lt, npm run rebuild (no data change is expected: numbers must equal the current gate). No note, name or db file may change.
```

### IT-29 — F11: notes that describe the plain-versus-tagged difference

Reads: [A15](A15_findings.md) A15-20, §3.2 item 2 · [A10](A10_findings.md) §3.9 (item_use_system comments) · [A02](A02_findings.md) A02-12 · `IT27_apply.md`.

```text
ITERATION IT-29. Mechanism: merge only. Depends on IT-27. EXTRA permission for this iteration: you may also run `npm run extract` (the plain build) and its rebuild, because this is the first iteration that puts comments on lines that used to be transform hazards.
Targets (find with `rg -n -i "tagged|plain build|extract:lt text|still shows|OQ-I026-1|OQ-49" notes extracted/system/inventory/item_use_system.asm extracted/system/diary_menu/sFA_diary_menu.asm` and the blocks sEA_solid_arm, pyDD_teleporter, pyD7_sliding_wall): item_use_system.asm lines about 37, 368, 389, 450, 464 (block note and part notes), the two comments at tags 231160 and 231435 (they mix "BNE" and "BEQ" in one sentence and cite OQ-I026-1), sFA_diary_menu.asm line about 34 ("the tagged extract still shows ...") and every note of the four blocks that says the tagged text "still shows" vanilla code.
After IT-27 the tagged text shows the same code as the plain text: the two Inca statue branches read BEQ, the diary remap sites read #$8300 / #$4000 / are removed, the teleporter saves $02, the sliding wall repeats its decrement-and-branch. Re-read the live text of each site and write what the code does now. A sentence that says this build changes a vanilla instruction (transforms.json) is a current fact and may stay; "the tagged extract still shows" and "OQ-I026-1" go. No ids, no history.
Proof of tolerance: after the merge run the gate for BOTH builds (npm run extract, npm run rebuild; then npm run extract:lt, npm run rebuild) and compare each with the newest GATE: line. If the plain build differs, a comment on a former hazard address broke a rule: remove that comment, report the address, and do NOT edit transforms.json. End with the tagged tree in place.
```

### IT-30 — `MenuSelectionHandler.asm`: anchor the transforms, merge the corrected notes (Preamble B)

Reads: [A02](A02_findings.md) A02-03, §9 · [A15](A15_findings.md) §2.2 · [A12](A12_findings.md) A12-13, RC-18 · `plans/extracted-audit/edits/I024_MenuSelectionHandler_PROPOSED.json` (frozen).

```text
ITERATION IT-30. Mechanism: U then M. Depends on IT-27 and IT-28.
Allowed edits: gaia-iog-baserom/db-us/transforms.json (only the three MenuSelectionHandler patterns, about lines 522-526), gaia-iog-baserom/src/merge.ts (only the MenuSelectionHandler refusal at about lines 248-249, and only after step 3), a NEW notes spec plans/extracted-audit/audit-of-audit/edits/IT30_MenuSelectionHandler.json, and the notes it merges. Extra commands: npm run extract (plain build).
1. Read the three unanchored patterns, MenuSelectionHandler.asm and the frozen PROPOSED spec. Find out why the patterns also match inside note or comment text (A02-03). Anchor each pattern so that it matches the instruction only (for example the full instruction line start with its operand), keeping the same sites in the instruction text. Prove it: both builds (plain and tagged, each followed by rebuild) must equal the current gate after your change, and the number of sites changed by each pattern must be the same as before (Grep the count in the plain tree before and after).
2. Remove the refusal in merge.ts (about 248-249) only if `npm run merge -- --check` and the guard of IT-28 now protect this file (a note placed on a line the anchored patterns still need must be refused). If they do not, leave the refusal, stop and report why.
3. Write IT30_MenuSelectionHandler.json as a COPY of the PROPOSED spec with every entry re-derived from the live code (never copy a fact unchecked). Rules: post-transform facts only (the extracted text now shows the transformed instructions: A = $8000/$0080 attack-interact bit, B cancel = $4000 in this build: read MenuSelectionHandler.asm lines about 12 and 43 and transforms.json 755-758 and vblank_joypad.asm 20 and 189 for the physical bits); add the one header line of A12-13 that says which vocabulary the file uses; no ids, no history (section 10.5).
4. Dry-run, show me the summary, apply, then the gate for both builds. Verify every note in the extracted file. End with the tagged tree.
```

### IT-31 — Orphan keys, bank 00: re-key or prune

Reads: [A09](A09_findings.md) §3.1 (A09-01 … A09-04, A09-06), §4 items 4 and 5 · [A15](A15_findings.md) §2.3 (prune), A15-10 · `IT28_apply.md` (check output).

```text
ITERATION IT-31. Mechanism: merge (including the new `merge --check` and `merge --prune` of IT-28). Depends on IT-28. Targets: notes/comments/bank00.json and notes/blockNotes/bank00.json.
1. Run `npm run merge -- --check --bank 00` on a fresh `npm run extract:lt` tree. Put the output in the apply file. Take the key lists from THIS output, not from A09 (they were counted in an earlier session; A09 expects 53 comment keys and 6 block-note keys).
2. Classify every orphan (do not re-key blindly; read the instruction at the target address):
   - A09-01 (29 comment keys: 59593 ... 60294, the smooth-follow angle/step/direction texts): compare each text with the comments at ComputeFollowAngle (about tag 60840) and ComputeFollowStep (about tag 60956) in extracted/system/engine/smooth_follow.asm. A fact the live comments lack is added at the right tag; the rest is pruned. The texts use stale operand names (orbitAngle, orbitDiameter, UnsignedDivide, chatPtr): do not copy a name you cannot see in the live code.
   - A09-02 (15 keys on data or header bytes): 46991 is the CGADSUB comment for the STA at tag 46999 (babel_elevator_color_add.asm about line 19): ADD it there first. 47052 is the thinker header of oneshot_palette_flash_18 and is covered by the comments at 47054-47059. 52887, 52891, 52895, 52899, 52903, 52907 are data-table entry notes: check that statue_inventory_reward (block or part notes) carries each entry fact, else add it to that note. 52569, 53033, 49851, 48664 describe whole actors: check that the block notes say it.
   - A09-03 (9 keys inside an instruction): 50105 has a newer duplicate at 50112 (ApplyPlayerHitstun.asm about 72); 52692, 53048, 53105 have neighbours that say the same; 53086 (JMP InventoryStatueSlotClaimed, tag 53085, no comment now), 52728 ("Music wait countdown: $00B4 (180) frames": apply the n+1 rule, section 6.1) and 62455 lost text: re-key at the corrected tag with current wording.
   - A09-04 (six block-note keys cop_handlers_flags, _flow, _lifecycle, _map, _solid, _spatial): for each, check that every fact has a home in the successor block notes (cop_handlers_script_control, _inventory, _actor_death, _world_map, _metatile, _collision, _hdma_dma, _movement and the others of extracted/system/engine); add a missing fact to the successor note first.
3. Write ONE spec with the re-keys and additions, dry-run, apply, gate. Texts follow section 6.1 (no history, no ids, ticks per n+1).
4. Write orphans.json (Write tool, in this folder) with exactly the keys the check still reports, run `npm run merge -- --prune <orphans.json> --dry-run`, show me the summary, apply, gate.
5. `npm run merge -- --check --bank 00` must now list no orphan. List anything left (with reason) in the apply file.
```

### IT-32 — Orphan keys, banks 01–1E: re-key or prune, duplicates

Reads: [A10](A10_findings.md) §3.2 (A10-11, A10-11b, A10-12, A10-13), §4 · [A15](A15_findings.md) A15-10, A15-11 · decision U17 · `IT28_apply.md`.

```text
ITERATION IT-32. Mechanism: merge (--check, --prune). Depends on IT-28 (and IT-31 only for the shared procedure). Targets: every bank file except bank 00.
1. `npm run merge -- --check` on a fresh tagged tree; take the lists from the output (A10 only sampled banks 04-0F, A10 §4: the output is the full list). Write the output into the apply file.
2. player_character range (A10-11, 26 comment keys in comments/bank02.json: 181319, 181558, 181631, 181704, 181766, 181804, 181994, 182035, 182122, 182166, 182302, 182338, 182524, 182900, 182925, 182960, 182976, 183071, 183087, 183117, 183393, 183424, 183561, 183590, 184133, 184148) plus the one unlocalised orphan of the attack_ability_system range (A10-11b: the check localises it). Pinned targets from A10: 182035 -> 182057 (WaitByte #27: apply the n+1 rule), 182900 -> 182903 (COP [BranchIfNotPressed] ( #$0030, &BlockStopToIdle )), 181558 -> 181559 (STZ slopeStepCounter). 181319 sits on the PlayerIdleDispatchTable data: comments cannot attach to data; fold the text into the table's part note if it is not already there. For each other key read the text, find the instruction it described, then re-key (text missing at the target) or prune (covered).
3. A10-12: the block-note key attack_trail_followers__removed is a tombstone ("Merged into attack_ability_system as part 2"): prune it.
4. A10-13: partNotes/bank1E.json keys sprite_group_000008 and sprite_set_000002 do not render because the labels in extracted/system/title_screen/spm_title_actors.sprite.asm are spm_title_actors_sprite_set_000002 and spm_title_actors_sprite_group_000008. Try re-keying through merge to the prefixed names (dry-run). If merge rejects the prefixed label, fold the two texts into the block note (the file header already repeats the facts) and prune the two keys. If neither works, BLOCKED: report that a tool extension is needed; do not script.
5. A15-11 / U17: CreditPositionLookup exists in bank09.json and bank13.json; keep bank 09 (the block starts at 649444), prune "bank13:CreditPositionLookup" after confirming both texts are the same.
6. Every other orphan or bank error the check reports (banks 01, 03-1E): classify as in IT-31 (re-key / prune / BLOCKED), spec, dry-run, apply, gate; then orphans.json, `--prune --dry-run`, apply, gate.
7. `npm run merge -- --check` must end with no error. Warnings (bank guessed by strategy S3/S4/S5/S6) are listed in the apply file, not fixed.
```

### IT-33 — T02: hidden sprite groups in the extractor (Preamble B)

Reads: [A15](A15_findings.md) §2.4 (design, expected output, the 15 candidate groups), A15-13, A15-14, §3.1 · [A08](A08_findings.md) A08-13 · [A12](A12_findings.md) A12-12 and the "Hidden sprite groups" row of §4 · [A14](A14_findings.md) B07.

```text
ITERATION IT-33 (T02). Mechanism: T. Depends on IT-27 (both builds must be identical before you start).
Allowed edits: gaia-core/src/rom/extraction/parser.ts (TypeParser.parseType) and gaia-iog-baserom/db-us/structs.json (line 14 only). Extra commands: `npm run build` with working directory c:\Work\gaia-core (the baserom uses gaia-core through its dist/, A15-14).
PRECONDITION: run `git status` in gaia-iog-baserom. If extracted/, db-us/ or notes/ have uncommitted changes, STOP and ask me to commit first ("Please commit now"): the diff after your change must show the T02 effect and nothing else. gaia-core must have no other uncommitted change in src/rom/extraction.
1. Baseline: both builds (plain, tagged, each with rebuild) equal the current gate.
2. Implement A15 §2.4 steps 1-3. In parseType add an optional maxItems; a struct member written `name[@N]` (N = index of an earlier member of the same struct, a Byte) is parsed with maxItems = that member's value; stop the item loop after maxItems objects; maxItems 0 returns an empty list. The existing `[hex]` fixed-count notation (parser.ts about 43-51) is the model: extend the same parse. Check the "roll back struct overflow" code (about 196-205) still behaves. Do not touch blocks.ts unless the extractor cannot print the hidden group as a second `sprite-group` entry of the same labelled part (A15 §2.4 step 3 expects it can).
3. `npm run build` in gaia-core. Confirm the baserom resolves @gaialabs/core to ../gaia-core (the link) and that the build picked up your change.
4. structs.json line 14: the last member of `sprite-group` becomes "sprite-part[@12]".
5. `npm run extract:lt`, then `npm run rebuild`: the numbers must equal the current gate (bytes unchanged). Run the plain build too. Then `git diff --stat extracted/`: list the changed files. Expected: spriteset_will_abilities, spriteset_pickups_effects, inventory_spritemap, spriteset_transform_poses and up to eleven of the candidate files of A15 §2.4 (spm_southcape_sprites, spm_viper, spm_pyramid_puzzle_sprites, spm_mu_enemies, sprite_1607B0, spm_castle_sprites, spm_sc06_castle_actors, spm_itory_sprites, spm_angkor_outer_sprites, spm_pyramid_sprites, spm_ending_credits_sprites). A changed file outside that list is not an error but must be explained.
6. For every file in the diff verify the arithmetic of each new `sprite-group` entry (13 + n x 7 bytes) against the byte budget of its labelled part (A08 §2.3 has the four audited ones: will_abilities 0F8BCC -> hidden 0F8BF5 = 69 B; pickups_effects 0EEE5E -> 0EEEB8 = 20 B; inventory_spritemap 108B67 -> 108B82, 108B96 and 108BAA -> 108BBE, 108BD2, 108BE6, 20 B each). A group whose header count is wrong would print junk as a second group: if the rebuild is byte-identical this cannot happen, but read at least one example per file. Also read spriteset_will_abilities group 0F8BCC: two entries, first with rows ;00-;03, second with rows ;00-;07, whose first row begins #00.
7. `npm run merge -- --check` (after IT-28) and `npm run names -- --check` must be as clean as before: no label or part-note key changed.
8. List in the apply file every note that now describes an artefact that no longer prints or is now false: spriteset_will_abilities line about 25, spriteset_pickups_effects about 1135, inventory_spritemap about 16, 1064, 1080, spriteset_transform_poses about 7, 1013, 1358, and any hit of `rg -n -i "extractor artefact|printed as|extra sub-sprite|not referenced by any" extracted` in the eleven candidate files. IT-34 starts from this list.
If the rebuild bytes differ at step 5: revert your two edits (and rebuild gaia-core), report the numbers, stop.
```

### IT-34 — Sprite notes that the extractor change makes stale

Reads: [A08](A08_findings.md) A08-02, A08-03, A08-04, A08-13, A08-14, A08-15, A08-16 · [A12](A12_findings.md) A12-12 · [A15](A15_findings.md) §2.4 · `IT33_apply.md` (the list of stale notes).

```text
ITERATION IT-34. Targets: extracted/tables/spriteset_will_abilities.asm, spriteset_pickups_effects.asm, inventory_spritemap.asm, spriteset_transform_poses.asm and the files IT33_apply.md lists. Mechanism: merge only. Depends on IT-33. The hidden groups now print as their own `sprite-group` entries, so every note that explained them as an extractor artefact is wrong or obsolete. Read the live text of each file first.
1. spriteset_will_abilities: A08-02 lines about 8 and 101 ("nine one-tick frames" -> nine two-tick frames, hold 1; records ;01-;09 have hold #$0001; the Psycho Dash cycle is 10 + 9 x 2 = 28 ticks; re-check each tick figure with the n+1 rule); block note line about 25: it claims the hidden group is a byte-identical copy of sprite_group_0F8D7D: re-compare the bytes now that both print correctly and state the result; the unreferenced group at 0F8BF5 (69 B, no frame list points at it) is a normal group now; ids at 7, 16, 25 (OQ-I072-4, OQ-I072-5, OQ-I067-5) out; history line 1 out.
2. spriteset_pickups_effects: A08-03 the sentence at about 1135 is gone (replace by one sentence on the unreferenced group at 0EEEB8: 13 B header + 1 sub-sprite = 20 B, no set points to it; delete the claim about 0EEECC); A08-04 line 1: the list of larger sets lacks spriteset_freedan (19163 B, db-us/blocks.json about 1046): put it first and re-check the other three sizes (17441, 12443, 11653) against blocks.json; A08-14 line 1 history; A08-15 lines about 18 and 1135 ids (OQ-I069-2, OQ-I069-4); A08-16 line about 242 keep one plain limit sentence.
3. inventory_spritemap: block note line about 16 (R-I071-3) and the part notes at about 1064 and 1080: the groups 108B67 and 108BAA print correctly now; the five unreferenced groups 108B82, 108B96, 108BBE, 108BD2, 108BE6 (20 B each) print as groups of their own. Recheck 13 x 3 + 4 x 7 = 67 and 13 x 4 + 4 x 7 = 80 and the address arithmetic of A08 §2.3. History line 1 and the id out.
4. spriteset_transform_poses: the three notes about lines 7, 1013, 1358 (two hidden groups at 0FCF65 and 0FD5E8).
5. The eleven candidate files of A15 §2.4: edit a sentence only if it describes an extractor artefact that no longer prints; list what you found.
6. One question, one plain statement: OQ-I067-5, OQ-I069-4 and OQ-I071-5 are the same question (A12-12) and it is now answered statically: the groups are unreferenced; no id in any note.
Ownership: these four files (and the A08 hygiene lines in them) are cleaned completely here; IT-20 and IT-21 own the other A08 tables; spriteset_transform_poses was otherwise cleaned by IT-11. Make no other changes.
```

### Phase C: questions, names, mnemonics

### IT-35 — OQ registry document and static answers (R)

Reads: [A12](A12_findings.md) all of it (§3 registry, §4 duplicate groups, §5 RC-01 … RC-21, §6, §7, §8, §9) · [A05](A05_findings.md) A05-08, A05-09 · `plans/extracted-audit/mesen2-question-inventory.md` and `mesen2-investigation-plan.md` (both frozen; read only) · every `IT*_apply.md` written so far (for "answer" lines, esp. `IT22_apply.md`).

```text
ITERATION IT-35. Mechanism: R (new report files only; no note, name, db or doc edit). Output files (Write): plans/extracted-audit/open-questions.md and plans/extracted-audit/static-answers.md. Never edit mesen2-question-inventory.md, A12_findings.md or any questions/ or results/ file.
Step 1 - static answers. For each open question below that A12 marks "static-answerable" (†), re-derive the answer from the live code with rg and Read, and record it in static-answers.md as: id(s), answer in 2-4 sentences, evidence file:line (E1), what remains open (if anything). If the static check does not settle it, record "not settled" and why; do not guess.
  - OQ-23 with OQ-I034-1 and OQ-I057-4 (consumer of displayModeFlags bits 0/4/5 and the meaning of bit 14: A12 RC-08, RC-09; Bg3TilemapVramDma camera_tilemap.asm about 880-892; hudDisableFlag bit 6 read by UpdateHUD). OQ-42 (writers of bits 4 and 5) and OQ-51 (bit 13) were never searched: search now (rg on the bit masks and the stores to displayModeFlags) and answer or mark not settled.
  - OQ-I035-6 (reader of $0B22 hpToHeal: system_core.asm about 416-423).
  - The OQ-I023-3 family: OQ-I023-3, OQ-I027-2, OQ-I030-2, OQ-I032-5, OQ-I036-4 and the part of OQ-60 (actor $10 bit $0200 = "must not be hit": readers combat_collision.asm about 333, 340, 1207; RC-01).
  - OQ-I044-4 (the static part: which remap vocabulary the menu files use; confirmation of the effect needs a rebuilt ROM: say so).
  - The other † pointers of A12 §8 that were never checked (R tag): OQ-I037-2, OQ-I037-3, OQ-I051-1, OQ-I042-1, OQ-I049-6 (half), OQ-I050-5, OQ-I060-3, OQ-I070-1, OQ-19, OQ-21 (remainder), OQ-26, OQ-46, OQ-I022-2, OQ-I060-6. Try each; unsettled ones stay "not settled".
  - Add the "answer" lines that the IT*_apply.md files collected (IT-22 especially) after re-checking each one yourself.
Step 2 - open-questions.md. Contents: (a) header with date, source (A12_findings.md section 3 is the full 358-row registry: do not copy it) and the recounted status totals (A12: 309 OPEN, 10 ANSWERED-LATER, 39 DUPLICATE-OF; recount after step 1); (b) "Status changes since A12": the eight ids the inventory wrongly lists as open (A12-08: OQ-5, OQ-7, OQ-22, OQ-I027-5, OQ-I029-1, OQ-I029-4, OQ-I054-1, OQ-I055-4, and its duplicate OQ-I063-4) with the evidence that answers each, plus the ids of step 1; (c) the experiment list: one row per duplicate group of A12 section 4 with canonical id, members, verdict (true duplicate / method only), the experiment (take the experiment letters from mesen2-investigation-plan.md) and what to observe; (d) corrections to the old inventory: A12-09 (a)-(h) and A12-10 (heading counts 56/53+2/63/60 vs rows 55/57+2/64/56; A02's registry has 54 rows and lacks OQ-I025-7); the hidden-sprite-group trio (OQ-I067-5, I069-4, I071-5) is now static and answered (IT-33/IT-34); (e) RC-01 … RC-20 evidence under the canonical ids (one line each; RC-21 was never re-checked: say so); (f) the ids cited in shipped text: none should remain after IT-23 to IT-25 and IT-34; re-run `rg -n "OQ-[A-Za-z0-9-]+" extracted notes` and list the residue.
Step 3 - A05-08 / A05-09 (registry updates): write the corrected statuses into open-questions.md; the stale inventory and apply-summary lines stay as they are (frozen).
No gate is needed (no tool-managed file changes). Run `npm run names -- --check` at the end.
```

### IT-36 — Names group 1: functions, actors (F) and entry stubs (E)

Reads: [A13](A13_findings.md) §3.1 (rules), §3.2 (rows A13-F001 … A13-F081), §3.8 (rows A13-E001 … A13-E022), §3.9, §3.11, §4 · A13-01, A13-02, A13-03, A13-12 · §10.6 of this plan.

```text
ITERATION IT-36 (names, group 1 of 4). Mechanism: names only. Procedure: section 10.6 of ACTION_PLAN.md. Spec: plans/extracted-audit/renames/apply-F06_names_FE.json with the 81 F rows (functions and actors that carry a part note) and the 22 E rows (the first label after each actor-def / thinker-def header) of A13. Build the rows from the A13 tables: take `new` and `row` from A13, but read `address` (the ; {n} tag of the first instruction) and `old` from the live extract:lt asm, never from the tables (labels may have been renamed by IT-04 or earlier iterations; skip a row whose label no longer exists and say so).
Notes: (1) three E stubs are counted in other rows (A13 §3.8 closing note): the first stub of hidden_red_jewel is in F064, of layer1_scroll_actors in F066 and F075, of diary_menu_window_dma in W001; do not write them twice. (2) The 39 DEAD labels (A13 §3.11) are not in these groups; do not add them. (3) The names tool enforces that `new` does not exist anywhere; if it reports a collision, stop and report (A13 §3.9 checked the names once; an iteration since then may have added one). (4) After the apply, rg the old names in db-us/transforms.json and in baserom/ and IOGRetranslation/modules (A13-05 says none is a transform key; confirm).
After the apply: names --check, extract:lt, rebuild (gate), then the curated-docs search of 10.6 step 4. Apply file: rows applied / skipped, the references the tool rewrote (counts per area), the curated hits.
```

### IT-37 — Names group 2: diary-window DMA (W), diary menu (D), Gaia / Dark Space (G)

Reads: [A13](A13_findings.md) §3.3 (A13-W001 … W015), §3.4 (A13-D001 … D059), §3.5 (A13-G001 … G045), A13-04, A13-03, A13-08, A13 §4 item 2.2 · §10.6 of this plan.

```text
ITERATION IT-37 (names, group 2 of 4). Mechanism: names only. Procedure: section 10.6. Spec: plans/extracted-audit/renames/apply-F06_names_WDG.json with the 15 W rows, 59 D rows and 45 G rows. This group contains the `!` overrides of patches (A13-04): from A13 and from your own rg of baserom/ and IOGRetranslation/modules, list every patch line that overrides or references a label of this group before you write the spec (A13 names: OptionsMenu.patch.asm 203-204, NewGamePlus.patch.asm 284, 363, 372, APUWaitFixes.patch.asm 292, 332, and OptionsNames.patch.asm 54 / SwitchNameDictionary.patch.asm in IOGRetranslation/modules, which reference loc_0BE433 / loc_0BE695). The dry-run must list these references as rewritten; if a `!` override or a sub-label override (`!:`) of the group is NOT in the dry-run, stop and report.
Run WITHOUT --local-only. After the apply: names --check, extract:lt, rebuild (gate; both builds, because sFA_diary_menu carries transform rules R7-R9 and the rename may change a transformed span: the gate must be identical in both modes, section 10.3), the curated search of 10.6 step 4.
Do not name the DEAD labels: the 25 sFA `_noref` routines, the five sE6 unreferenced labels (loc_08EFAD is DEAD-IN-VANILLA and patched, A13-03: keep generic). W rows use the cursor value in the names (Cursor0, Cursor1, Cursor2Plus), not the diary_band_slotN numbering (A13 closing note of section 2). Report the three commented-out lines of A13-08 (patch sources; decision U16): do not edit them. Because IOGRetranslation/ files are rewritten by the tool, list them in the apply file so I commit that repo as well.
```

### IT-38 — Names group 3: inventory, player move, overlay (I) and scene script, collision, VRAM clear, slope (S)

Reads: [A13](A13_findings.md) §3.6 (A13-I001 … I025), §3.7 (A13-S001 … S006), A13-04, A13-07, A13-09 · §10.6 of this plan.

```text
ITERATION IT-38 (names, group 3 of 4). Mechanism: names only. Procedure: section 10.6. Spec: plans/extracted-audit/renames/apply-F06_names_IS.json with the 25 I rows and the 6 S rows. The inventory overrides of InventoryManagement.patch.asm (A13-04, lines about 242, 243, 249, 284) and the HudRedesign.patch.asm reference to loc_02F07E must appear in the dry-run as rewritten; sub-label overrides stay in step with their parent (stop if not). S006 (loc_02B76C in slope_ramp_physics.asm) is named by the fact the code shows (clears slopeStepCounter): its inline comment ends "probably a copy slip": leave the comment (IT-47 removes the hedge, A13-07).
After the apply: names --check, extract:lt, rebuild (gate, both builds), the curated search. Also check that docs/code/bank02/scene-script.md (code_0283C1, code_0283ED, code_028CB0) and the other docs of A13-09 were rewritten by the tool; list what it did and did not touch (gaia-knowledge/curated is never rewritten by the tool).
```

### IT-39 — Names group 4: sprite-set data (T)

Reads: [A13](A13_findings.md) §3.8 (A13-T001 … T009), A13 §4 item 2.4, A13-10 · decision U13 · §10.6 of this plan.

```text
ITERATION IT-39 (names, group 4 of 4). Mechanism: names only. Depends on IT-38. The nine T rows rename `sprite_set_` data labels (inventory_spritemap: sprite_set_1082B6 and sprite_set_1082CE; spriteset_will_abilities: sprite_set_0F8076, 0F8146, 0F8216, 0F8248, 0F82BC, 0F82C6, 0F8302). A13 did not run the tool for data parts: whether a data label is keyed by the integer of its six-digit hex suffix (1082B6 hex = 1082038 decimal) is REPORTED from the doc only.
1. Write plans/extracted-audit/renames/apply-F06_names_T.json and run `npm run names -- <spec> --dry-run`. Show me the result. If the tool rejects a row or reports nothing to rename, STOP: the apply file says BLOCKED (the names tool needs an extension for data keys; I will decide; no workaround, no hand edit).
2. If the dry-run is correct, apply (without --local-only), then names --check, extract:lt, rebuild (gate), and rg for the old names in notes/, docs/ and gaia-core/docs (A13-09 found sprite_set_0F8076 in gaia-core/docs/notes-and-comments.md as an example).
3. The part notes in these two files were rewritten by IT-34 (if DONE): after the rename the note keys must follow the new labels; check that the notes render.
Do not touch the spm labels (A13-10) or any other sprite_set_ label: decision U13.
```

### IT-40 — Gated rename rows: re-triage after the OQ document

Reads: [A02](A02_findings.md) R-I030-1, R-I030-2 · [A03](A03_findings.md) §2 (the ten PROPOSED rows gated on open questions) · [A04](A04_findings.md) R-I044-3 · [A05](A05_findings.md) R-I056-8 and decision U3, A05-12 · [A01](A01_findings.md) rows 89, 95 · [A14](A14_findings.md) §3.4 · `open-questions.md` and `static-answers.md` (IT-35) · §10.6 of this plan.

```text
ITERATION IT-40. Mechanism: names (rows that are label renames) plus a report. Depends on IT-35 and IT-39. These are the label-rename proposals that earlier steps held back because an open question gates them. Re-triage each against the OQ documents of IT-35:
1. List the gated rows: A01 rows 89 and 95 (gated on OQ-63, OQ-68); A02 R-I030-1 and R-I030-2 (SetPlayerGameOverFlag: gate OQ-I030-2, which IT-35 may have answered: actor $10 bit $0200 = "must not be hit"); the ten rows of A03 section 2; awB2_stair_climb (OQ-I023-1); A04 R-I044-3 (block global_ambient_dispatcher: a block key rename, see item 4); A05 R-I056-8 (blocked by decision U3: stays blocked); A05-12 spelling (decision U5: no rename).
2. For each row decide: GATE ANSWERED (the OQ is answered statically with E1 evidence in static-answers.md) -> write a names row; GATE OPEN -> leave it, record the gating id and what would answer it; STALE (the live label already equals the proposal) -> record.
3. Second list (A14 section 3.4, first bullet): the label-name proposals of the I001-I020 ledger that A14 sent to the names owner (A01 rows 1-6, 11-14, 18-21, 24, 26, 35, 36, 38, 39, 41-43, 47, 48, 53, 55-57, 64, 66, 72-74, 82-85, 88, 89, 91, 95, 96; read the rows in plans/extracted-audit/renames/I001-I020_rename-proposals.md) and the label rows named in the last bullet of A14 section 3.4 (R-I035-1..3, 5..7, R-I036-1..3, R-I042-1..3, R-I043-1..2, R-I051-4, R-I058-1(a, c, d), R-I060-4(a), R-I061-3, R-I062-2..4, R-I063-1..2, R-I064-2, R-I066-1, R-I069-1..2, R-I071-1..2, R-I072-1..4). Row 32 of A01 is a block rename (IT-46 parks it). Classify each: APPLIED (already live), LABEL RENAME with E1/E2 evidence and no gate -> names row, BLOCK RENAME (a blocks.json key: parked, section 15), STALE, or NEEDS EVIDENCE.
4. Write plans/extracted-audit/renames/apply-F06_names_gated.json with the names rows of items 2 and 3 (at most 60 rows in this run: if more qualify, write the first 60 and list the rest as DEFERRED in the apply file; I will re-run this prompt for them). Procedure of section 10.6 for the dry-run, my go, apply and gate.
5. Block (blocks.json key) renames are never applied here: they change file names, note keys and transform keys (U18). List them under PARKED.
```

### IT-41 — Mnemonic renames, batch 1 (Preamble B)

Reads: [A14](A14_findings.md) A14-F01, A14-F05, A14-F15, A14-F16, §3.1 rows M01, M02, M03, M04, M05, M06, M07, M08, M09, M10, M11, M14, M15, M17, §3.2, §5 item 1 · decision U14 · §10.7 of this plan.

```text
ITERATION IT-41 (F06 mnemonic batch 1). Mechanism: U. Procedure: section 10.7 (edit list, WAIT, apply, gate). Allowed edits: gaia-iog-baserom/db-us/mnemonics.json (the NAME value of the rows I approve, nothing else). Extra commands: none.
Rows (A14 section 3.1; the key is the decimal address; rename the value only; byte-neutral): M01 deathFlag -> depthBucketArray (512); M02 actorLimitThreshold -> creditsTimelineCounter (228); M03 musicParentActor -> musicTrackId (1778; decision U14: you may offer currentMusicIndex as the alternative); M04 sceneStateHelper -> consoleAttrHi (2463); M05 playerStateByte -> playerFlags+1 (2479); M06 deathActionIdx -> eventBlockIdx (8323108); M07 iframeCounter -> hitStunCounter (8323112); M08 scratch1010+6 -> customCallback (8327190); M09 loopStartPcActor -> thinkerLoopStartPc (8331520) and M10 loopCounterActor -> thinkerLoopCounter (8331522), together; M11 tileQueryResult -> pendingMetatileVram (2306; decision U14); M14 climbStateData and climbStateData+2 -> willAbilityBonus and freedanAbilityBonus (2528, 2530); M15 invincibilityTimer -> walkRunWindowTimer (1036); M17 warpDestX / warpDestY -> warpPlayerX / warpPlayerY (1612, 1614). M12 (gfxCacheIdx*, 81 files) is IT-42; M13 / M16 are cross-repo (IT-42).
Per row, before the edit list: re-verify the semantics in 3 to 5 key sites (the A14 Reason column is the claim; the code decides). Known caveats: M08: pyDD_mummy_queen stores a different value in that slot (say so in the edit list; the note wording is IT-48); M11: HieroglyphPuzzle.patch.asm line 6 declares `!tileQueryResult 0902` locally, so the patch still builds but its text becomes stale (patch source is user-owned: report); M17: each file that uses it declares a local `!warpDestX` header that the extractor regenerates; M14 supersedes R-I023-3 (R-I025-6 wins). If a proposed `new` name already exists as a mnemonic key, STOP that row.
Apply group by group (one gate per group, both builds, section 10.3): group 1 M01 M04 M05 M09+M10; group 2 M02 M06 M07; group 3 M08 M11 M14 M15 M17; M03 after your answer. After each group list the old names still present outside extracted/ (the apply file feeds IT-47 and IT-49 to IT-51).
```

### IT-42 — Mnemonic renames, batch 2 (`gfxCacheIdx*`) and batch 3 (cross-repo) (Preamble B)

Reads: [A14](A14_findings.md) A14-F02, §3.1 rows M12, M13, M16, §3.2 (patch hits), §5 items 2 and 3 · [A12](A12_findings.md) A12-14, RC-15 · decision U15 · §10.7 of this plan.

```text
ITERATION IT-42. Mechanism: U. Depends on IT-41. Allowed edits: gaia-iog-baserom/db-us/mnemonics.json (rows below) and, ONLY if decision U15 says "approve cross-repo", IOGRetranslation/modules/widescreen/Widescreen.patch.asm (the lines named below).
Batch 2 - M12: keys 1608, 1609, 1610, 1611 (gfxCacheIdxA, gfxCacheIdxA+1, gfxCacheIdxB, gfxCacheIdxB+1) -> transitionTypeWord, transitionTypeWord+1, transitionSpeedWord, transitionSpeedWord+1 (rename as pairs; a local `gfxCacheIdxB_exit` in some files is a different name and stays). It changes 137 lines in 81 files. A12-14: the ledger evidence covers two files (sFC_title_start_handler.asm line 7, dark_space.asm line 17); "where else the two words act as cache indices was not checked". Therefore step 1 is a classification: `rg -n "gfxCacheIdx" extracted baserom` and, for EVERY file, read the context and decide: scene-transition parameter (type or speed) or graphics cache index. Write the table into the edit list. If any file uses the word as a cache index, do NOT rename: the row becomes ALIAS-IN-NOTE (IT-48) and you say why. Otherwise follow 10.7.
Batch 3 - M13 (keys 1676, 1678, 1680: effectScrollH, mapScrollV, effectScrollV -> bg2ScrollH, bg1ScrollV, bg2ScrollV; bg1ScrollH, key 1674, unchanged) and M16 (keys 1764, 1766: effectDeltaX, effectDeltaY -> cameraMoveDeltaX, cameraMoveDeltaY). Patch hits (A14 section 3.2): Widescreen.patch.asm lines 169, 235, 391, 447, 814 use mapScrollV and lines 166, 170 use effectDeltaX / effectDeltaY, resolved through mnemonics.json (no local `!name addr`). Verify the A14 claim for UploadScrollRegisters ($068A BG1 H, $068C BG2 H, $068E BG1 V, $0690 BG2 V) in the code. If cross-repo is not approved: list the rows as SKIPPED (U15) and stop after batch 2. If approved: change the mnemonic keys AND the seven Widescreen lines in the same step; then run the gate (both builds) and, if IOGRetranslation has its own build or verify command for the Widescreen module (read its package.json and docs), run it; if there is none, say the module was not built.
The edit list (10.7 step 2) must include for each row the old-name hits in ApocalypseGaia.patch.asm (currentHp, cameraDeltaX/Y, moveXAlt/YAlt are NOT renamed: M18, M20, M28 stay).
```

### IT-43 — `copdef.json` renames C01–C08 (Preamble B)

Reads: [A14](A14_findings.md) §3.1 rows C01 … C10, A14-F02, A14-F03, A14-F11, §3.2, §5 item 4 · [A01](A01_findings.md) F12 · decision U15 · §10.7 of this plan.

```text
ITERATION IT-43 (F06 copdef). Mechanism: U. Depends on IT-41 (procedure). Allowed edits: gaia-iog-baserom/db-us/copdef.json (the name of each approved row; ids and operand types never change), and, ONLY with decision U15 "approve cross-repo", the three C04 patch sources named below. Extra commands: none.
Rows (A14): C01 id #62 BranchIfCollisionTypeNe -> BranchIfCollisionTypeEq (cop_handlers_actor_flags.asm about line 75 branches on EQUAL: verify; decide what happens to the legacy alias BranchIfSolidNibbleNe: read how copdef stores aliases and keep it only if it is already an alias entry); C02 id #02 QueueDma -> QueueHdmaDirect (45 lines, 12 files; it binds a direct HDMA table to a B-bus register, WorldMapSplitEffect.asm about lines 78-79); C03 id #55 ResetSpriteState -> StartTileStreamAnim (17/8); C06 ids #4D #4E WorldMapStream3 / WorldMapStream4 -> PaintTileStream3 / PaintTileStream4 (no script sites); C07 ReloadMoveDurations -> ReloadMoveChains ($2C/$2E are chain pointers); C08 ForceDirSW / ForceDirNE / ForceDirBoth -> ForceFlipX / ForceFlipY / ForceFlipXY (FIRST read the ApplyMovement handler: it tests $12 bits $4000 / $2000 to negate the delta; check which of SW / NE negates X and which Y before you assign the new names). C04 id #88 SetMetasprite -> SetSpritesetTable (203 lines, 125 files; patch hits baserom/red-jewels/ChestFlaggedHiddenRedJewel.patch.asm line 31, baserom/red-jewels/generic_sparkle.asm line 13, IOGRetranslation/modules/walkable-world-map/walkable_world_map_core.asm line 253): only with U15 approval, in the same step as those three lines; otherwise SKIPPED (U15). C05 (RunPlayerAnim is an alias of AnimOnce #89): no key change; docs only (IT-51). C09 / C10: LEAVE (copdef parts hold types only; A14-F03).
Protocol: section 10.7. Group gate (both builds): C01 C02 C03; C06 C07 C08; C04 last. Old names to hunt after each group (the apply file lists them for IT-47 and IT-51): extracted/ comments, notes/, docs/cop/families, docs/cop/cop-commands-reference.md, gaia-core docs, corpus (not edited).
```

### IT-44 — Mnemonic appends, batch A (small and local) (Preamble B)

Reads: [A14](A14_findings.md) A14-F01, A14-F13, §3.1 rows M37, M38, M39, M40, M41, M42, M45, M46, M50, §5 item 5 · decision U14 · §10.7 of this plan.

```text
ITERATION IT-44 (F06 mnemonic appends A). Mechanism: U. Allowed edits: gaia-iog-baserom/db-us/mnemonics.json (new keys for the approved rows, nothing else). An ADD names an address that was raw until now: EVERY absolute operand at that address in every file changes text (A14-F01). Rows: M37 $00AC $00AE $00B0 $00B2 -> vramDmaSrc, vramDmaSrcBank, vramDmaDest, vramDmaSize (absolute forms only; DP forms stay raw; compare AGENTS.md "IOG Persistent Engine DP State"); M38 1712 ($06B0) -> metatileDefBase+2; M39 2820 ($0B04) -> savedDialogFrameDelay; M40 $0904 $0906 $0908 $090A $090C -> metatileQueueTL, metatileQueueTR, pendingMetatileVramRow2, metatileQueueBL, metatileQueueBR (pairs with M11); M41 $0DB8 / $0DB9 -> one word key itemGetId (the high byte is always zero: confirm); M42 $0AC8 -> playerBodyIndex; M45 $09EE -> talkFacing; M46 $7F0A40 -> cgramPal2 (the assembler does not support `$label+constant, X`, so a separate name is the only way); M50 $0D6C $0D6E $0D6F -> worldMapDeferredScroll, worldMapDestScene, worldMapSourceScene.
Per row, the site check of 10.7 step 4 is mandatory: list every site (file:line), the meaning at the site, and whether the proposed name is true there. A14 counts for M38, M39 were taken from ledgers and not recounted: recount. If one file uses the word for something else, do not add the key. Compute each decimal key from the hex address and confirm it by one extract:lt run (the operand prints as the name). Immediates (#$xxxx) are probably not substituted (A14-F14, unverified): note what you see.
Group by file overlap, gate after each group (both builds, bytes unchanged). The apply file lists the notes and docs that now quote a raw address where a name exists (optional follow-up, not required).
```

### IT-45 — Mnemonic appends, batch B (wide or ambiguous) (Preamble B)

Reads: [A14](A14_findings.md) A14-F01, A14-F13, A14-F14, §3.1 rows M36, M43, M44, M47, M48, M49, M51, M52, M53, §4 · decision U14 · §10.7 of this plan.

```text
ITERATION IT-45 (F06 mnemonic appends B). Mechanism: U. Depends on IT-44 (procedure). Allowed edits: gaia-iog-baserom/db-us/mnemonics.json (new keys for approved rows). These rows touch many sites or addresses that other files use differently; the per-site classification of 10.7 step 4 is the main work and any ambiguity means "do not add".
Rows: M36 $0402 -> blockMoveStub (the ledger says 12 `JSR $0402` lines; the live count is 23 lines in 7 files: classify every line; only the JSR sites are the stub; comments and other uses decide whether a global key is safe); M43 $0B16 / $0B1C -> psychoDashLevel / darkFriarLevel (A14-F14: the #$0B1C immediates in the four spm_* sprite files are sprite-part parameters: run extract:lt after the edit and diff the four spm files; if anything in them changed, revert the row); M44 $0B08 $0B0C $0B10 -> savedTileX, savedTileY, savedScroll; M47 $0D60 -> worldMapPartyArray (six-word array $0D60-$0D6A: entries $0D62..$0D6A stay raw; WorldMapController.asm lines 19-22; not worldMapCompanion0); M48 $00B6 $00B8 $00BC $00CA $00CC -> mode7PerspectiveStep, mode7Divisor, mode7Rotation, mode7CenterX, mode7CenterY ($00CA / $00CC are also used by other thinkers: per-file check first; for $00BC use mode7Rotation); M49 $00DA -> spriteTextByteCount; M51 $0D74-$0D9E block, $0D8E $0D90 $0D92 $0D94 $0D96 $0D98 $0B24 $0B26 -> diarySlotCursor, diaryEditSlot, diaryCopyTarget, diaryTabCursor, buttonType, soundMode, soundSetting, buttonTypeSetting (world_map_options and diary_menu_window_dma also use some of these words: per-file check); M52 $097E $0980 $098E $0990 $0992 $0994 -> dialogBoxOriginCol/Row, menuCursorTileOffset, menuSavedTileTop/Bottom, uiBlinkCounter ($090E / $0910 only after OQ-I024-3 is answered: it is not: SKIP those two); M53 $0AB2 $0D8C -> darkSpaceVariantSaved, activeSaveSlot (count the raw uses first).
Gate after each row group (both builds). The edit list (WAIT) must show, per row, the full site table and your recommendation (ADD / ALIAS-IN-NOTE / LEAVE).
```

### IT-46 — `structs.json`, `types.json`, `overrides.json`, `blocks.json` rows (Preamble B)

Reads: [A14](A14_findings.md) A14-F03, A14-F04, §3.1 rows S01, S02, S03, B01, B02, B03, B06, B07 · [A15](A15_findings.md) §2.4 (why B07 is closed by IT-33) · [A06](A06_findings.md) A06-21 · [A07](A07_findings.md) A07-21 · §10.7 of this plan.

```text
ITERATION IT-46. Mechanism: U. Depends on IT-33 (B07 is solved by the extractor change; do not add the nine blocks.json parts). Allowed edits: gaia-iog-baserom/db-us/structs.json (names and the S02 types only), db-us/blocks.json (the type of the parts named below and struct names used in parts), db-us/types.json (B03), db-us/overrides.json (B06). Extra commands: none.
Rows: S01 struct `direction-velocity` -> `walk-step` (blocks.json about line 1007: walk_step_table; the block name is already applied: only the struct name remains); S02 struct `stair-warp` -> `forced-walk-warp` and its use in `warp-def` (blocks.json about line 1004 `&warp-def`) plus the retype so the 6-byte walk stream is not split as word, word, word, byte, word (types only: read structs.json and the printed rows of scene_warps.asm first; if the retype cannot be made byte-neutral, do the rename only and report); S03 struct `map-label` -> `scene-label` (parts at 242132-242689); B01 forced_walk_pan_table (blocks.json about line 1005) type &Binary -> a Word array ending $0000 (A14: "verify the extractor prints Word runs with the $0000 terminator": check the printed text and the four operands in forced_walk.asm; if it prints junk, revert and BLOCKED); B02 the 14 `binary_01D1xx` parts (119072-119099) -> Word; B03 types.json key 53352 `Binary` -> `Word` (16 signed words); B06 overrides.json add key 782923 `{ "M": 1 }` (no entry exists today: verify). Field names (R-I064-4, R-I065-8, R-I066-2, R-I068-2/3, R-I069-4, R-I060-6b) are LEAVE (A14-F03: the schema has no field-name slot); S10 (ability-damage struct) is LEAVE; B04, B05, B08, B09 are LEAVE.
Protocol 10.7: edit list, WAIT, apply, gate (both builds, bytes unchanged) after EACH row; the extracted text changes (250 lines in 3 files for S01-S03, the rows of scene_warps.asm, a few lines for B01-B03, B06): read one before/after example per row. Names of structs also appear in docs/structs-reference.md: list for IT-49.
Block (file) renames (A14 rows 32 `cop_handlers_actor_flags` -> `cop_handlers_collision_probe` and 38 `hdma_ramp_tables`) are NOT done here (decision U18): they move note keys and transform keys. List them under PARKED.
```

### IT-47 — Notes after the renames: stale names, apologies, hedges

Reads: [A14](A14_findings.md) A14-F11, §5 "F06 follow-up (comments)" · [A13](A13_findings.md) A13-07 · [A12](A12_findings.md) A12-14, A12-15, A12-16 · `IT41_apply.md` … `IT46_apply.md` (the old-name lists) · §10.5 of this plan.

```text
ITERATION IT-47. Mechanism: merge only. Depends on IT-41 to IT-46 (only the rows that were really applied; read the apply files). 
1. For every mnemonic, COP and struct rename that IT-41 to IT-46 applied: `rg -n -w <old name> extracted notes` (notes JSON and extracted comments) and replace the old name with the new one in notes and comments through merge, where the text really means that word. The renames change the extracted code text automatically; the notes do not follow.
2. Unconditional items (A14-F11, A12-15, A13-07): cop_handlers_actor_flags.asm lines about 5 and 75: remove "audit rename proposal"; if C01 was applied the note names BranchIfCollisionTypeEq and says it branches on EQUAL, else keep the live name and say the handler branches on equal; field_reveal_object.asm line about 70: the inline comment carries an OQ id: remove it, keep the fact; warps_interaction.asm line about 46: "(see the audit rename proposals)" goes; state what $06F2 holds (the BGM id stored by SpcMusicLoadCmd, scene_meta.asm line about 23) under the live name; slope_ramp_physics.asm lines about 633-634: drop "probably a copy slip" (the code clears slopeStepCounter, the EW twin decelStepCounter; the name states the fact).
3. Notes that apologise for or mention a name that a rename removed (A14 section 5): player_character.asm line about 12 (invincibilityTimer "stale": M15), system_core.asm line about 510 and scene_lifecycle.asm line about 828 ("invincibility timer" wording: it is the walk/run window), slider_glide.asm lines about 411-414 ("named climbStateData": M14), QuintetLzDecompress.asm line about 24 and StopPlayerOnDeath.asm line about 5 (deathFlag: M01), cop_handlers_metatile.asm line about 6 (tileQueryResult: M11), sprite_composition (deathFlag / depth bucket wording), music_actors.asm and item_use_system.asm (musicParentActor wording "the original music ID": M03), the notes that cite iframeCounter / deathActionIdx (M07, M06). If the row was NOT applied, leave the live name and rewrite the apology as a plain present-tense fact about the word ("holds the ... ", section 6.1); that is an alias statement for IT-48 only when the word has several meanings.
4. Comments-only rows of the ledger (A14 section 3.4: A01 rows 30, 52, 59, 61; read them in plans/extracted-audit/renames/I001-I020_rename-proposals.md): check whether the comment change is live; if not, apply it through merge when the evidence is E1.
5. Sweep (section 10.5, retired-names row) for every renamed name; the residue list goes into the apply file.
Do not rename anything here. Do not put ids or history into the new text. Skip hazard lines.
```

### IT-48 — Notes: wording for the 12 multi-meaning mnemonics and alias notes

Reads: [A14](A14_findings.md) §3.3 (the table of 12, and the thirteenth case `sineTableA/B`), A14-F06 … A14-F10, §3.1 rows M18 … M35, M56, M59, M08, S11, C05 · [A12](A12_findings.md) RC-12, RC-13, RC-15, RC-16.

```text
ITERATION IT-48. Mechanism: merge only. Depends on IT-47. The mnemonic names stay (a mnemonic is global by address; file-local aliases are impossible, A14-F01); the per-file meaning goes into the block note of each file that uses the word differently. Pattern (A14 section 3.3): "In this file `<name>` (`$addr`, X) is the <role>; the global name belongs to <default users>." Present tense, no ids, no history. The default meaning of the global name is stated once in docs/wram-memory-map.md (IT-51), not in every note.
A14 marks each line VERIFIED or REPORTED. RE-READ every cited line in the live code before writing; for REPORTED ones (npc_wander_ai: home X/Y, escort: ring head, gem pickup: step counter, StageMove / halving code: pass counter, escort / reveal half-width, InitGravity / SpawnFieldRevealEffect: moveXAlt / moveYAlt hold a target pixel position, the effectRenderDeltaX/Y sentence) write only what you can derive; otherwise list them NOT-VERIFIED.
Items (A14 section 3.3 numbering): 1 orbitAngle (hit_stagger_controller 73 and 207: slide start X; ramps 542 and 553: curve byte offset of the arc child; smooth_follow 461: slope row, offset = row x 32 bytes; StandardEnemyDefeatHandler 62 and EnemyDefeatDispatch 50: enemies remaining after this kill; music_actors 51 and 109: saved scene music index; field_reveal_object 70, 81, 92: $FFFF at spawn, not read again); 2 orbitDiameter (hit_stagger_controller 76 and 172: slide start Y; ramps 435, 454, 571: the player's exit speed given by the climb; smooth_follow 339, 468, 482: dither phase 0-15 left by ComputeFollowStep); 3 chatPtr (field_reveal_object 147: item id of the pickup; smooth_follow 38: animation base id, bit 15 = leave the animation alone; music_actors 65 and 111: scene track number plus one); 4 loopCounter (smooth_follow 36: follow speed in pixels per frame; ramps 544: frame count of the arc child); 5 currentHp (NPC actors via npc_wander_ai: base animation index, not hit points; hit_stagger_controller 248: HP, zero = the victim dies); 6 layerPriorityFlag (bit field: bit 9 $0200 camera frozen and field interaction off, player_transition_handlers 135 and warps_interaction 230; bit 11 $0800 interleaved-tile mode, scene_script 391 and 434; bits 0-3 BG1/BG2 screen base, scene_script 1244; bit 15 BG1/BG2 write swap, system_core 636); 7 globalScriptIndex (sE6_gaia 78: Dark Space layout variant; 87: cleared on entry, GaiaHint_AuraItem tests it; 144: selection state of the item list; 514, 991, 1194 were not re-read: read them); 8 free101C (hit_stagger_controller 79 and 81: knockback tier 0 or 1; sFA_diary_menu 284 and 586: camera-pan step budget per frame); 9 cameraDeltaX/Y (camera_scroll 66: cleared after its value moves into the override word; camera_tilemap 182: copied to effectScrollH/V in layer-1 delta mode; state both observations without choosing: the question is open); 10 effectRenderDeltaX/Y; 11 moveXAlt / moveYAlt; 12 hpToHeal is NOT a per-file alias: skip it here (IT-51, docs only). The thirteenth case: sineTableA/B are the scaled sine tables of the scroll-wave effect in three files, and in WorldMapSplitEffect.asm the same arrays hold the BGMODE and COLDATA tables on odd frames (already in that note).
Also: M08 (pyDD_mummy_queen stores a different value in the callback slot: only if M08 was applied; read the actor first); M31 warpFacing / warpScrollParams (three meanings; warps_interaction 924 and 938, forced_walk 5 and 192-193 already say pointer, not facing byte: check, do not duplicate); M35 moveScratch1 / moveScratch2 (hit_stagger_controller and EnemyDefeatDispatch notes); M56 orbitAngleY / orbitDiameterY are mid-word addresses of items 1 and 2 (note only); M59 the circle-window words in $7E7000/7100/7200 (tileStagingBuffer is a shared name); S11 thinker-def word $0804 (state "word $0804 = animScratch2 filter" in the thinker notes only after you confirm it); M34 displayModeFlags bit names stay in docs.
```

### Phase D: docs

Common to IT-49 … IT-51: [A11](A11_findings.md) table T1 (rows D01 … D114) is the work list, §2.2 (N-A11-01 … N-A11-10) the new findings, §2.3 the sweeps and §4 the by-file list. Status in A11 is as of the A11 run; IT-14, IT-15 and IT-16 (Part 1) and the names iterations have changed docs since. **Every row is re-checked against the live file first**: row already correct -> record DONE and skip; otherwise re-read the cited code, then edit.

### IT-49 — Docs part 4: data tables, structs, code README

Reads: [A11](A11_findings.md) §4 rows for `docs/bank01-data-tables.md`, `docs/structs-reference.md`, `docs/code/README.md`; T1 rows D02, D08, D51, D58, D59, D88, D89, D90, D93, D94, D95, D97, D98, D99, D100, D101; N-A11-05, N-A11-06, N-A11-07 · `IT14_apply.md`, `IT16_apply.md`, `IT36_apply.md` … `IT39_apply.md`, `IT46_apply.md` · [A14](A14_findings.md) rows S01 … S03 (struct names).

```text
ITERATION IT-49 (DOCS). Allowed edits: docs/bank01-data-tables.md, docs/structs-reference.md, docs/code/README.md only, by hand with StrReplace. No merge, no names (except the final check), no gate run. Finish with npm run names -- --check. Record every line (file, line, before, after, evidence) in IT49_apply.md; unchanged rows with their status.
Work list (A11 section 4; re-check each row first):
- bank01-data-tables.md: D58 parallax_scroll_table bullets (lines about 377-392: the header bytes and "$0D-$1A are terminators"; re-read the data part notes in extracted/tables/parallax_scroll_table.asm); D88 shared_word_table is shared strings (about 33, 600, 709; note extracted/tables/shared_word_table.asm:1); D89 forced_walk_pan_table is camera pan step lists (about 17, 99); D90 dialog_template_table: 22 templates, mostly speaker colour templates, ranges shifted by one (about 24, 323-326; note dialog_template_table.asm:1); D93 item_pickup_text_table: 64 item names plus 5 wrappers (about 36, 561, 679, 712); D94 second warp list = forced-walk warps, all vertical (about 82); D95 table_018000 residue (lines about 46 and 688 may be rename-map rows that must keep the old identifier: leave those); D97 body-table row names (about 494-498; the live names are in extracted/tables/body_table.asm 27-35, for example spriteset_will_abilities ($8F)); D98 enemy_clear_reward_table (about 118-122: tiers select the stat; any scene with a nonzero entry); D99 dictionaries "256 per dictionary" (about 654: dialog_dictionaries.asm:1 says A has 256 entries, B 200; recount before you write numbers); D100 scene_chest_table is chests not barriers (about 21, 199-208, 692; leave the legit barrier uses); D101 item menu table descriptions (about 564, 582, 585, 673, heading 18c; the code claim is REPORTED: read the code); D08 music_pointer_array music ids off by one (about 332-345; UNCHECKED: read scene_meta / the table, fix only what you prove).
- structs-reference.md: D02 display-preset field map (+0 TM/TMW, +1 TS/TSW, +2 CGWSEL, +3 CGADSUB, +4 layer flags, +5 layerPriorityFlag, +6 BGMODE, +7 scroll/HUD flags; about 812-843 and 362; live note extracted/tables/display_preset_table.asm:3); D95 residue (362, 833, 841, 843); D97 (about 1104-1108); D94 (about 1275-1340: second warp list is forced-walk warps, not stair-warp; if IT-46 renamed the struct to forced-walk-warp, use the live name); D51 (about 1171: "water shimmer, lava glow, torch flicker" is a guess: say what the palette thinker does, from its note). Use the struct names that are live in db-us/structs.json after IT-46 (walk-step, forced-walk-warp, scene-label), if IT-46 applied them.
- docs/code/README.md: D52 ("18 thinkers", about 204: sine_hdma_slow_wave is spawned in scenes $32 and $E9/$EA only, 2 spawn entries; extracted/tables/scene_thinkers.asm 433 and 724), D88 (about 253), D89 (about 237), D93 (about 256), D100 (about 241), D59 (about 246: "HDMA scroll configs" -> "band templates").
- N-A11-05, N-A11-06, N-A11-07 in these three files: retired auto-names (table_01ADA8, itemget_table_01FD24, itemcomp_table_01EB0F; table_0F8000, table_0FC000, table_17A000 in body-table rows): use the live block names from db-us/blocks.json (look them up; do not invent). Rename-map rows that must name the old identifier stay.
After the edits: `rg -n "table_018000|table_01ADA8|itemget_table_01FD24|itemcomp_table_01EB0F|will_alt|SpawnSparkleEffect" docs/bank01-data-tables.md docs/structs-reference.md docs/code/README.md`; list what remains and why. Do not run npm run ingest:all (the corpus copies are refreshed by you at the end, U19).
```

### IT-50 — Docs part 5: `docs/code/bank00`, banks 08, 0A, 0C

Reads: [A11](A11_findings.md) §4 rows for `docs/code/bank00/*`, `docs/code/bank08-…`, `bank0A-…`, `bank0C-…`; T1 rows D10, D25 (utility-tiles-animation.md line), D28, D32, D40, D49, D51, D52, D55, D77, D78, D79, D81, D102, D103, D104, D105; N-A11-02, N-A11-04, N-A11-07, N-A11-08 · `IT15_apply.md`, `IT41_apply.md` (old to new mnemonic names).

```text
ITERATION IT-50 (DOCS). Same rules as IT-49 (StrReplace only; before/after and evidence in IT50_apply.md; names --check at the end). Re-check each row against the live file first (IT-15 already did hpToHeal, will_alt and some wram rows); skip DONE rows.
Files and rows (A11 section 4): docs/code/bank00/system-core.md D102 (lines about 421, 457, 522: $0B22 is hpToHeal, not a "damage flash" timer) and D28 (line about 36: "music handshake from NMI": read the code before you change it; REPORTED); data-tables-memory.md D10 and N-A11-04 (lines about 39, 125, 158: slope_curve_table is not a sine/cosine HUD table; its first 64 bytes are the default slope acceleration and deceleration curves; note math_lookup_tables.asm:9), D78 (about 113: the escort path is a ring of 9 entries written, 8 read, and array_00C943 is the facing delta table; EscortFollowPathTracker.asm:7), D102 (about 381), D105 (about 250: will_alt -> the live block name spriteset_will_abilities), N-A11-02 (about 336: climbStateData / previousDamage: use the live mnemonic names if IT-41 renamed M14, else one wording for both bytes: $09E0 Will ability byte, $09E2 Freedan table byte), N-A11-07; README.md D40 (about 316 "Decrement invincibility timer": it is the walk/run window timer), D78 (about 705), D79 and N-A11-08 (about 192, 619: SpawnSparkleEffect does not exist; $C418 = SpawnImpactSparkAndDie, the item sparkle is SpawnItemSparkleEffect: choose per call site), D105 (about 740), D55 (about 134, 136, 494, 495); stair-climb-system.md D105 (about 8, 33, 117, 127, 288); actors-player-rewards.md D32 (about 329: SetOnInteract is not a copdef name; copdef id 192 is SetInteractHandler; keep legacy-alias mentions only where the text says alias), D79 (133, 155), D104 (58 is right; 73 is vague: "HP bar delta" is hpToHeal recovery); actors-combat-interaction.md D77 (about 382: $06C8 is forcedScrollOverride, not "sub-pixel overflow pending"; no reader found: say "no reader found" and nothing more), D104 (about 134); functions-player-npc.md D78 (about 224); utility-tiles-animation.md D25 (about 294: $2C/$2E are delta-chain head pointers, not frame durations); bank08-native-dao-pyramid-actors.md D32 (about 124, 127, 193) and D103 (about 417: "damage flash" for item #EB: the item heals HP via hpToHeal); bank0A-dungeon-enemy-actors.md D32 (about 257); bank0C-scene-spawn-tables-comet.md D51 (about 432: the "water shimmer, lava glow, torch flicker" guess), D52 (about 441: "Gold Ship, Babel Tower" for sine_hdma_slow_wave: scenes $32 and $E9/$EA), D55 (445, 464: palette_parent_child and flag_gated_palette_warm descriptions: read both thinker notes), D81 (about 854: smooth_follow aims once and flies straight, it is not "player-tracking homing"); thinkers-palette.md D51 (about 56) and the "Warm interior" residue (about 105).
Also: D49 stays as is (wording done; the SetPlayerGameOverFlag rename is IT-40's business); D104 line 58 is correct.
If IT-41 renamed mnemonics (deathFlag, actorLimitThreshold, ...), `rg -n -w <old name> docs/code/bank00 docs/code/bank08-native-dao-pyramid-actors.md docs/code/bank0A-dungeon-enemy-actors.md docs/code/bank0C-scene-spawn-tables-comet.md` and update the doc text where the old name stands for the renamed address (listed in IT41_apply.md).
```

### IT-51 — Docs part 6: banks 02/03, COP families, `wram-memory-map.md`

Reads: [A11](A11_findings.md) §4 rows for `docs/code/bank02/*`, `docs/code/bank03/*`, `docs/code/bank0D-scene-meta.md`, `docs/cop/families/*`, `docs/cop/cop-commands-reference.md`, `docs/wram-memory-map.md`; T1 rows D01, D03, D04, D05, D06, D07, D09, D12, D13, D14, D18, D20, D21, D24, D25, D26, D27, D29, D30, D33, D34, D35, D50, D54, D63, D70, D71, D85, D91, D92, D94, D95, D96, D106; N-A11-01, 02, 03, 05, 06, 09 · [A14](A14_findings.md) C01 … C08, §3.3 (item 12: `hpToHeal`) · `IT16_apply.md`, `IT43_apply.md`, `IT41_apply.md`, `IT47_apply.md`, `IT48_apply.md`.

```text
ITERATION IT-51 (DOCS). Same rules as IT-49 (StrReplace only; IT51_apply.md with before/after and evidence; names --check at the end). This is the largest docs iteration: do whole files in the order below; if you run short of room, finish the file you are in, write the apply file with the remaining rows marked NOT-REACHED and tell me; I will re-run this prompt for them.
1. docs/code/bank03/movement-and-collision.md: D05 and N-A11-01 (about 250, 251-254, 269: ApplyHitDamageToVictim is the player-hits-actor routine; formula from combat_collision.asm 36-40: rawDamage = max(1, totalStr - victim DEF), netDamage = rawDamage + characterForm, totalStr = playerStr + bonus + Will/Freedan ability byte), D06, D07 (about 311-318: $09E0 Will ability byte, $09E2 Freedan table byte; remove previousDamage / climbStateData; use the live mnemonic names if IT-41 applied M14); also D71 docs/code/bank02/player-movement.md about 116, 138 ("direction not suppressed").
2. docs/code/bank02/scene-script.md: D03 (about 234, 1003, 1070: $06AA is the 1-byte flag table pointer: code meaning REPORTED: read it), D04 (about 232, 539, 585, 600, 995-1003: BuildMetatileFlagTable lifts a tilemap-word bit into a 1-byte flag table), D92 and N-A11-03 (about 99, 101-104: SpcMusicLoadCmd is at scene_script.asm 1296, not spc_transfer.asm), D95 residue, D96 (opcode $04/$05/$06/$14 descriptions: use the live handler names and notes); docs/code/bank0D-scene-meta.md D91 (about 161: equal music-room group = the load path runs; scene_script.asm 1303-1306) and D95 (about 105).
3. docs/code/bank02/game-systems.md: D34 and D100 (about 509, 525, 527: PlaceOpenedChestTiles / chests, not barriers), D94 (about 820-880, REPORTED: read), N-A11-05 (about 498, 506, 516, 527, 533, 543, 611, 629, 881) and N-A11-06 (about 570); docs/code/bank03/radar-and-world-map.md (N-A11-05 about 54, 80), text-and-menus.md (N-A11-06 about 346), field-input-and-items.md (about 401), README.md (about 302), nmi-handler.md D21 (about 177: Bg3TilemapVramDma, a BG3 tilemap DMA), actor-thinker-runtime.md D35 (about 282-283: bit-11 _Light routines; REPORTED: read), D20 sprite-rendering.md (about 53, 62: UNCHECKED), D50 tile-collision.md (about 77-78, 512-514: MapCellDown / MapCellUp: UNCHECKED; read the code before touching).
4. COP families (docs/cop/families/): D13 palette.md (about 25: "bundle ID forced to 0": REPORTED; read the handler), D14 hdma_dma.md (about 9, 22, 70, 147: QueueDma is a direct-table HDMA channel and #0F is $210F BG2HOFS, not CGRAM; if IT-43 renamed C02 to QueueHdmaDirect use the live name), D25 force_move.md (about 9, 19), player_sprite.md (about 20, 238), sprite_staging.md (about 21), cop-commands-reference.md (about 829) ($2C/$2E are delta-chain head pointers, not frame durations; use ReloadMoveChains / ForceFlipX... only if IT-43 applied C07 / C08), D27 vram_memory.md (about 111 "source bank forced to $7F": REPORTED), D29 dialog.md (about 119), D30 movement.md (about 34, MoveToward operands: two Byte operands, the second is the speed; REPORTED), D63 and N-A11-09 player_query.md (about 45-46: West/Here/East, North/Here/South; may already be done by IT-16), D106 sprite_anim.md (3 lines) and sprite_state.md (1 line: spriteset_particle_fx, spriteset_enemies), D26 sine_hdma.md / gravity.md / camera.md operand descriptions (UNCHECKED), D18 cop-commands-reference.md joypad rows (UNCHECKED: "$0001 is not a button; bit 0 is the raw source"). If IT-43 applied renames, update every doc that names the old COP (docs/cop/families, cop-commands-reference.md, docs/cop/index.md and README.md): the apply file of IT-43 lists the old names.
5. docs/wram-memory-map.md: D01 (about 207: gfxSrcStart, gfxSrcEnd, gfxDestPage, gfxLayerFlags), D12 (about 358: inventorySlots is 16 bytes $0AB4-$0AC3; code stride REPORTED), D24 (about 248: $06F2 stores the music track id; use the live mnemonic), D33 (about 347: wramFlags; ClearAllWramFlags clears $0A80 only: see event-flags.md 191, 377, 393), D54 (about 285 slopeCurvePtrs "(ascending/descending)": REPORTED), N-A11-02 (about 290), D09 (UNCHECKED, depends on OQ-8: do not edit), D85 (UNCHECKED: section 2.9 remap table: read, fix only what you prove). Also, once IT-41, IT-44 and IT-45 are applied: one row per renamed or added mnemonic whose old description is now wrong, and the default-meaning sentence for the multi-meaning mnemonics of IT-48 (A14 section 3.3: orbitAngle, orbitDiameter, chatPtr, loopCounter, currentHp, layerPriorityFlag, globalScriptIndex, free101C, cameraDeltaX/Y, moveXAlt/moveYAlt, hpToHeal = recovery counter, sineTableA/B).
6. docs/code/bank00/functions-camera-motion.md D70 (about 203-228: ApplyOrbitalOffsetXY field layout +0 X angle, +1 Y angle, +2 X diameter, +3 Y diameter; 3 call sites: UNCHECKED, the earlier grep failed: do it now).
```

### IT-52 — `gaia-core` docs and `gaia-knowledge/curated` (Preamble B)

Reads: [A11](A11_findings.md) §2.4 (AP17-01 … AP17-11), §2.5 · [A12](A12_findings.md) A12-11 · [A13](A13_findings.md) A13-09 · [A09](A09_findings.md) A09-26 · [A15](A15_findings.md) A15-21 · [A14](A14_findings.md) A14-F03 · `IT28_apply.md`, `IT33_apply.md` · decisions U7, U12.

```text
ITERATION IT-52 (DOCS, outside the baserom). Use Preamble B (section 10.2). Allowed edits: c:\Work\gaia-core\docs\notes-and-comments.md, c:\Work\gaia-core\docs\patch-development.md, c:\Work\gaia-core\docs\rom-mapping-guide.md, c:\Work\gaia-knowledge\curated\gaialabs\rom-mapping-guide.md and, if a name below sits in another file of those two folders, that doc line only. Never edit gaia-knowledge/corpus/ or gaia-core/src (the corpus is refreshed by you, U19). Record every edit in IT52_apply.md.
1. notes-and-comments.md, AP-17 (verify each against the live file; IT-28 already did AP17-01 and AP17-02: the rename-propagation checklist with its two Python scripts is replaced by a pointer, merge --check / --prune are documented; read and keep consistent): AP17-03 (about 1315, 1358: a spec is a record of one run; say which entry types replay: `edit` entries do not; the I061/I062 specs use hex addresses); AP17-04 new "Note text rules" section (present tense, no history narration, no hedges or UNVERIFIED-RUNTIME labels, no ledger or OQ ids in note text: decision U7; quote game text with the in-game spelling; the writing style of section 6.1 of ACTION_PLAN.md is the model); AP17-05 `Dead:` marker: decision U12 = no marker, say "no reference in extracted code" in plain words; AP17-06 button vocabulary table ($0001 is not a button, bit 0 is the raw source; read docs/cop/families/input.md for the table); AP17-07 glossary rule: the vocabulary of ACTION_PLAN.md section 6.1 (slot, group, frame) and a pointer to a glossary file only if one exists; AP17-08 one line: WaitByte(n) / WaitWord(n) / `$08` counters = n+1 ticks; AP17-09 post-rename grep list (docs/, gaia-knowledge/corpus, gaia-knowledge/curated, IOGRetranslation/modules and artifacts, gaia-core/docs); AP17-10 one sentence: after T01 plain and tagged builds are identical, before it ten multi-line transform rules matched only in the plain build (A15-01), and the merge transform guard; AP17-11 nothing.
2. A09-26: document the line-tracking behaviour that a `; {n}` tag and a comment can share a line (example oneshot_palette_flash_18 line 16) and what merge does with such a line (read src/merge.ts and the T03 apply file; document only what the code does).
3. The `[@N]` count-bounded member notation added by IT-33 (parser.ts) and its use in structs.json (`sprite-part[@12]`): document the notation where struct member types are described (find the section: gaia-core/docs or gaia-knowledge/curated/gaialabs/reference-model.md; if the doc is in curated, edit it only if it describes member types; otherwise write the paragraph in notes-and-comments.md and say where you put it). Include: the sprite-group header's 13th byte is the member count, hidden groups are now extracted.
4. A12-11: the id convention lines (about 1370-1372 of notes-and-comments.md) now say ids stay out of notes (U7); A13-09: after the names iterations the tool rewrote gaia-core/docs but not curated: `rg -n "loc_0BE695|table_08EB8F|sprite_set_0F8076|code_0283C1" c:\Work\gaia-core\docs c:\Work\gaia-knowledge\curated` and fix the examples to the live names (check each against names/bankNN.json). rom-mapping-guide.md: A13 found `table_08EB8F`.
5. A15-21: where T04 / T01 / T03 behaviour is user-facing (extract scripts, crc.json mode field, merge --check / --prune, transform guard), make sure the doc agrees with the apply files of IT-26, IT-27, IT-28 (read them; correct your docs, not their results).
6. Final: `rg -n "annotate|ingest" c:\Work\gaia-core\docs` for retired-command text; report what remains. No gate (no baserom file changes).
```

### Phase E: close-out

### IT-53 — Close-out: errata, final checks, status

Reads: [report.md](report.md) §4, §5 · [A02](A02_findings.md) row 22, I-10 · [A03](A03_findings.md) A03-12 · [A05](A05_findings.md) A05-08, A05-09 · [A06](A06_findings.md) A06-19 · [A10](A10_findings.md) (defect class 14) · [A11](A11_findings.md) N-A11-10 · [A12](A12_findings.md) A12-08, A12-09, A12-10 · [PLAN.md](PLAN.md) · every `IT*_apply.md` and the §2 index, §13, §15 of this plan.

```text
ITERATION IT-53 (CLOSE-OUT). Mechanism: R and D (plan files only). Allowed edits: new file plans/extracted-audit/audit-of-audit/ERRATA.md; plans/extracted-audit/audit-of-audit/PLAN.md (status rows and defect-class list); ACTION_PLAN.md (section 2 status column, Progress log, section 15). No notes, names, db or doc edit. No git except status, diff, log.
1. Final checks (record each command and its result in IT53_apply.md): `npm run merge -- --check` (expect no orphan key; every key left is listed with a reason), `npm run names -- --check`, `npm run extract:lt`, `npm run rebuild` plain and tagged (identical, equal to the newest GATE: line), the sweeps of section 10.5 over extracted/ and notes/ (counts per sweep; residue per file), `rg -n "OQ-[A-Za-z0-9-]+|R-I[0-9]+" extracted notes` (expect none), the retired-name list of section 10.6 step 4 over docs/ and gaia-core/docs, and `git status --short` in gaia-iog-baserom, gaia-core, IOGRetranslation and gaia-knowledge (list changed files per repo; do not stage or commit).
2. ERRATA.md. One table: file:line | what it says | what is true | evidence. Entries: A02 row 22 and A03-12 ("none of the old names is left" is false); A02 I-10 and A06-19 (digest wording); A05-08, A05-09 and A12-08 / 09 / 10 (inventory and apply-summary statuses; corrected counts in open-questions.md); N-A11-10 (report claim N-9 holds only for spriteset and table names, not address-style auto-names); A15-02 (T01 acceptance sentence of PLAN.md: done in IT-27: confirm); every other claim of a frozen file that an iteration of this plan found false (read the "unexpected" and "FALSE" lines of the apply files). Frozen files are not edited; ERRATA.md points at them.
3. PLAN.md: update the status table with one row per phase of this plan (A-step rows stay as they are); add defect class 14 "orphan key" (a part-note, comment or transform key that matches no block or label: A10; test: merge --check) and the transform-adjacency / build-mode class if absent; point the F-step rows to the iterations (F01 = IT-01 ...; F05 = IT-14, IT-15, IT-16, IT-49 ... IT-52; F06 = IT-36 ... IT-48; T01 = IT-27; T02 = IT-33; T03 = IT-28; T04 = IT-26).
4. Parked list: re-read section 15 of this plan; for every parked item write the current status (still parked, done elsewhere, new). Add any item that an apply file marked BLOCKED, SKIPPED or DEFERRED.
5. User actions (U19): list in IT53_apply.md what only I can do: `npm run ingest:all` in gaia-knowledge, regenerate IOGRetranslation/artifacts/file-layout.json (D110), commit each repo (suggest one commit message per repo and per phase), keep or delete db-us/mnemonics_new.json and temp/*.mjs, restart or rebuild the gaia-core dist if IT-33 left it to me, re-run any iteration marked NOT-REACHED or DEFERRED.
6. Mark IT-53 DONE in section 2 and write the closing Progress log line.
```

---

## 13. Coverage: every finding of A08–A15 and where it went

"user" = needs your action; "parked" = §15; "none" = informational.

| File | Finding | Goes to |
|---|---|---|
| A08 | A08-01 (sprite-set hygiene, ids) | IT-20 |
| A08 | A08-02, A08-03, A08-04 (hidden sprite groups, 3 files) | IT-34 (after IT-33) |
| A08 | A08-05 … A08-08 (string tables) | IT-21 |
| A08 | A08-09 | IT-20 |
| A08 | A08-10, A08-11, A08-12 | IT-19 (A08-12 is a patch source: reported, U16) |
| A08 | A08-13 | IT-33, IT-34 |
| A08 | A08-14, A08-15, A08-16 | the file's owning iteration (IT-20, IT-21, IT-34) |
| A08 | A08-17, A08-18 | IT-21 (listed as REPORTED; sentences unchanged); parked |
| A09 | A09-01 … A09-04 (orphan keys, bank 00) | IT-31 |
| A09 | A09-05 | IT-27 |
| A09 | A09-06 | IT-28 |
| A09 | A09-07 … A09-15, A09-22, A09-23 | IT-23 |
| A09 | A09-16 … A09-19 | IT-02, IT-18 |
| A09 | A09-20, A09-21 | IT-05, IT-04 |
| A09 | A09-24 | none |
| A09 | A09-25 | IT-27 (report) |
| A09 | A09-26 | IT-52 |
| A10 | A10-01 … A10-10 | IT-17 |
| A10 | A10-11 … A10-13 | IT-32 |
| A10 | A10-17 | IT-18 |
| A10 | A10-18 | IT-24 |
| A10 | hygiene counts | IT-24, IT-25 |
| A10 | §3.9 | IT-29 |
| A10 | defect class 14 | IT-53 |
| A11 | table T1 rows D01 … D114 | IT-49, IT-50, IT-51 (D110: user; D114, D107, D108: done or corpus) |
| A11 | N-A11-01 … N-A11-09 | IT-49, IT-50, IT-51 |
| A11 | N-A11-10 | IT-53 (ERRATA.md) |
| A11 | AP17-01, AP17-02 | IT-28 |
| A11 | AP17-03 … AP17-11 | IT-52 |
| A11 | §2.5 corpus | user (`npm run ingest:all`, U19) |
| A12 | A12-01 … A12-06 | IT-19 |
| A12 | A12-07 | the sweeps (IT-23 … IT-25) |
| A12 | A12-08, A12-09, A12-10 | IT-35, IT-53 |
| A12 | A12-11 | decision U7; IT-23 … IT-25, IT-52 |
| A12 | A12-12 | IT-33, IT-34 |
| A12 | A12-13 | IT-24, IT-30 |
| A12 | A12-14, A12-15, A12-16 | IT-42, IT-47, IT-41 |
| A12 | RC-21 | parked (never re-checked) |
| A13 | A13-01 (name groups F, E, W, D, G, I, S, T) | IT-36, IT-37, IT-38, IT-39 |
| A13 | A13-04 (patch `!` overrides) | IT-37, IT-38 |
| A13 | A13-06 | the sweeps |
| A13 | A13-07 | IT-47 |
| A13 | A13-08 | U16 (reported, IT-37) |
| A13 | A13-09 | IT-52 (curated), IT-38 (gaia-core docs by the tool) |
| A13 | A13-10 | decision U13 (nothing applied) |
| A13 | A13-02, A13-03, A13-05, A13-11, A13-12 | the same group iterations (rules and checks) |
| A14 | rows M01 … M17 | IT-41 |
| A14 | M12, M13, M16 | IT-42 |
| A14 | rows C01 … C08 | IT-43 |
| A14 | ADD rows M36 … M53 | IT-44, IT-45 |
| A14 | rows S01 … S03, B01 … B03, B06 | IT-46 |
| A14 | B07 | IT-33 |
| A14 | ALIAS-IN-NOTE rows, §3.3 | IT-48 |
| A14 | §3.4 (rows sent elsewhere) | IT-40 (names), IT-47 (comments), IT-49 … IT-51 (docs) |
| A14 | F11 (stale notes) | IT-47 |
| A14 | F03, field-name slot; block renames rows 32, 38 | parked (U18) |
| A14 | LEAVE rows | none |
| A15 | A15-01, 02, 03, 06, 07 | IT-27 |
| A15 | A15-04, 05, 08, 09, 12, 22 | IT-28 |
| A15 | A15-10, A15-11 | IT-31, IT-32 |
| A15 | A15-13, A15-14 | IT-33 |
| A15 | A15-15 … A15-18 | IT-26 |
| A15 | A15-20 | IT-29 |
| A15 | A15-21 | IT-28, IT-52 |
| PLAN | F05 (A11) | IT-49 … IT-52 |
| PLAN | F06 | IT-36 … IT-48 |
| PLAN | T01 / T02 / T03 / T04 | IT-27 / IT-33 / IT-28 / IT-26 |

---

## 14. Closure of the carry-forward items CF-1 … CF-8

| CF | Goes to | Notes |
|---|---|---|
| CF-1 mnemonic backlog | IT-41, IT-42, IT-44, IT-45 (renames and adds), IT-47, IT-48 (text) | cross-repo rows need U15 |
| CF-2 copdef | IT-43 | C04 needs U15; C05 is docs only (IT-51) |
| CF-3 blocks / structs / overrides | IT-46 | block renames parked (U18) |
| CF-4 tooling and build decision | IT-27, IT-28, IT-29, IT-30, IT-31, IT-32 | order in §16 |
| CF-5 gated renames | IT-40 | R-I056-8 stays blocked (U3) |
| CF-6 process and user | IT-53 (ERRATA, user list) | `temp/*.mjs`, `crc.json` (IT-26) |
| CF-7 static checks | IT-22 | each check reports FALSE / TRUE / NOT-CHECKED |
| CF-8 registry updates | IT-35, IT-53 | |

---

## 15. Parked items and actions only you can do

Parked (no iteration; each needs a decision or a tool that does not exist):

- **Struct field-name slot** (A14-F03): `structs.json` has no slot for member names; rows R-I064-4, R-I065-8, R-I066-2, R-I068-2/3, R-I069-4, R-I060-6b, R-I001-78 stay LEAVE. Needs a `gaia-core` extension and your go.
- **Block (file) renames** that move note keys and transform keys: A01 rows 32 (`cop_handlers_actor_flags` -> `cop_handlers_collision_probe`) and 38 (`hdma_ramp_tables`), R-I044-3 (block `global_ambient_dispatcher`) and any other block key rename found by IT-40. Needs a tool that rewrites `db-us/blocks.json`, `files.json`, notes and transforms together.
- **spm labels** (4616) and tier-2 labels (about 788) and scheme S-1 for `sprite_set_` data labels (U13).
- **Patch-source findings** (U4, U16): `EquippedIcon.patch.asm:474` `?INCLUDE 'table_018000'`, `:526` raw COP, three commented-out `code_` lines (A13-08), `HieroglyphPuzzle.patch.asm:6` local `!tileQueryResult`, the `SetMetasprite` / Widescreen lockstep edits if U15 is not approved.
- **Mushroom-drop-gate masks** without a `joypadMaskStd` rule (A09-25): changing them changes the ROM.
- **Mesen2 questions** (E5): every experiment of `open-questions.md` needs a ROM that runs; none exists in this workspace.
- **A08-17, A08-18** (credits frames of `spriteset_will_abilities`, chest tile ids: static re-reads that nobody did; the shipped sentences stay) and **RC-21** (A12, never re-checked).
- **Multi-meaning mnemonics** stay global by address (A14-F01); the per-file meaning lives in notes (IT-48).

Only you:

- Commit each touched repo (`gaia-iog-baserom`, `gaia-core`, `IOGRetranslation`, `gaia-knowledge`). Agents never commit.
- `npm run ingest:all` in `gaia-knowledge` (corpus copies of docs: A11 §2.5).
- Regenerate `IOGRetranslation/artifacts/file-layout.json` (D110).
- Decide U1 … U19 where the default is not what you want (before the iteration that uses them).
- Keep or delete `db-us/mnemonics_new.json` (A14-F12) and `temp/*.mjs`.
- Run the Mesen2 experiments when a ROM exists.

---

## 16. Run order

Part 1 first (IT-01 … IT-16, §5). Part 2, recommended order:

1. IT-26 (T04). It can run at any time; it removes the Windows `rm -rf extracted/*` failure that stops `extract:lt` from being reliable.
2. IT-27 (T01), then IT-28 (T03), then IT-29 and IT-30 (they need the new gate and the transform guard).
3. Phase A: IT-17 … IT-25 (notes). IT-17 … IT-22 can run in any order; IT-23 … IT-25 are the bank sweeps and come last in the phase.
4. IT-31 and IT-32 (orphan prune; need IT-28).
5. IT-33 (T02, needs a clean git state and the `gaia-core` build), then IT-34.
6. Phase C: IT-35 first; then IT-36 … IT-39 (names, in order); IT-40 (needs IT-35 and IT-39); then the mnemonic and COP iterations IT-41 … IT-46 (need your answers to U14 and U15); then IT-47 and IT-48.
7. Phase D: IT-49, IT-50, IT-51, IT-52. They can start as soon as their dependencies in §2 are DONE; the mnemonic-dependent parts run after IT-41 … IT-46.
8. IT-53 last.

After each iteration: read the apply file, check `git diff --stat`, update the §2 status and the Progress log, then commit. **Please commit when you're ready**; a suggested message per iteration is `audit-of-audit: IT-<NN> <short title>`.
