# I049 - 2026-10-27 - files: actors/debug_man.asm, functions/DarkGemDropSystem.asm, actors/camera_scroll_controller.asm
Status: COMPLETE

Spec: [edits/I049.json](../edits/I049.json). Proposals: [renames/I049_renames.md](../renames/I049_renames.md). Questions: [questions/I049_questions.md](../questions/I049_questions.md).

Conventions: verdicts **P/M/F/NA**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 coverage and verbosity, Q2 value, Q3 accuracy, Q4 mnemonic and variable names, Q5 new mnemonic, Q6 naming, Q7 evidence quality.

Annotation style for this iteration: the notes aggregate (block note, one part note per label, inline comments only where an operand or a non-obvious step needs them). The I045 and I046 specs were generated with a scratch builder script and comment almost every instruction; that goes against the plan and `notes-and-comments.md` and was not redone here.

### actors/debug_man.asm (actor + menu chain, 285 lines, Bank 0B 781856-782712, parts: 31 code / 16 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A header and a handful of comments; none of the 47 labels had a part note | E1 |
| Q2 value | M | The reader could not see the menu mechanics (what the two `DialogueOptions` bytes mean, what table entry 0 is, how rows map to table entries) or the destination list | E1, E2 |
| Q3 accuracy | **F** | (a) **The destination count is 21, not about 35.** (b) **Level 1 leaf comments were swapped**: `code_0BEEE4` (row 4, EDOWA-DO) goes to scene `$0A` = Edward Castle and `code_0BEEF3` (row 3, LAST GAIA LOOK) goes to scene `$E5`, the ending sequence (the same scene `sE8_dark_gaia` and `s90_changed_world` queue); the old comments said "Last Gaia scene" for `$0A` and "Edward's Castle" for `$E5`. (c) **`$32` is Freejia (HANANOMIYAKO) and `$3E` is the Diamond Mine (DAIYAMONDO)**, not "Gold Ship" and "Diamond Coast". (d) **`DialogueOptions` returns the confirmed row + 1 and 0 for B**, so every table has 5 entries and entry 0 is the cancel (`DebugManQuit`); level 7 also uses `DebugManQuit` for its row 1 "Quit". (e) The actor is solid, has no per-frame code and sets the stats on every conversation. (f) The header's region list ("Level 2+: ... etc.") was incomplete; each of the 7 levels holds exactly 3 destinations (7 x 3 = 21). | E1 (the file, `MenuSelectionHandler` header, `DialogueOptions` and `QueueMapChange` handlers), E2 (scene id to area directory names, e.g. `ec0A_*`, `ec0F_*`, `fr32`, `dm3E`; the two `$E5` callers), E3 (`docs/cop/families/dialog.md` lines 87 and 152) |
| Q4 mnemonic/var names | M | `#04, #00` and the facing byte (`#07`, `#03`, `#00`) had no meaning; the scroll-params word is still opaque | E1, E2 (`direction_velocity_table`, `warpFacing`) |
| Q5 new mnemonic | NA | `abilityBitmask`, `playerMaxHp`, `playerHp`, `playerStr`, `playerDef` already exist | E1 |
| Q6 naming | M | The `code_` / `code_list_` labels are positional; every menu level and leaf has a clear role | E1 (PROPOSED R-I049-3) |
| Q7 evidence quality | M | E1 + E2 + E3; "never spawned" is static (no reference in `extracted/`), the destination coordinates and the scroll-params word were not run | E1, E2 (UNVERIFIED-RUNTIME: OQ-I049-1, OQ-I049-2) |

Actions taken: block note rewritten; 45 new part notes and 2 updated (`DebugManInteract`, `DebugManQuit`); inline comments 2 new and 21 updated (the 21 destination decodes, the `DialogueOptions` operands, the shared confirmation string); no mnemonics added.
Deferred: R-I049-3; OQ-I049-1, OQ-I049-2.
Before/after stats: file 285 to 425 lines; inline comments 25 before, 27 after (23 touched); header comment lines 13 before, 66 after; every label has a part note; generic labels remaining: 35 (`code_*` / `code_list_*`).

### functions/DarkGemDropSystem.asm (spawner functions + weighted table, 133 lines, Bank 00 57129-57340, parts: 12 code / 1 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A two-sentence header, 4 misplaced comments, no part notes | E1 |
| Q2 value | M | The reader could not tell which items drop, how the type byte and the HP tier choose, or how long the pickup lives | E1, E2 |
| Q3 accuracy | **F** | (a) **The drops are not "dark gems": chatPtr `$83` to `$86` are `GiveItemToPlayer` ids** (1, 2, 5 gems and a 5 HP heal with the spark effect); `$86` is not a gem at all. (b) **The router calls it only when the enemy's stat byte +3 is nonzero and scene flag `$0300` is clear**, not "for each enemy kill"; byte 1 and 2 are fixed drops (`$83`, `$84`), anything else nonzero goes through the weighted picker. (c) **`DarkGemDropAnimVariantA` is not an entry point**: only the table reaches it (the 5-gem body), as do `code_00DF38`, `code_00DF61` and `code_00DFE3` besides their fixed-entry uses. (d) "Bob animations" are a shimmer and a blink; lifetime is about 1050 ticks for gems and 600 for the heal. (e) **The weighted roll depends on HP tier** (above half, up to half, up to a quarter) with three different probability groups; the heal is the most likely drop (50%) at low HP. (f) The old comment at `SetMetasprite` ("animate chatPtr gem `$83`") and at `STA $26` ("tier sets chatPtr `$85/$86/$84/$83`") sat on the wrong instruction and mixed up the tier with the roll. (g) The pickup works through the `$0020` friendly flag and `InteractionDamage_NPCChat`; `collect_handler_gem` is only the L / R pull. | E1 (the file; `StandardEnemyDefeatHandler.EnemyGemDropRouter`; `GiveItemToPlayer`; `combat_collision.InteractionDamage_NPCChat`; `interaction_handlers.collect_handler_gem`; `spriteset_enemies` lists 4/5/6, 9/`$0A`/`$0B`, `$22`, `$35`), E2 (`idle_sprite_display` uses chatPtr `$85`), E3 (`structs-reference.md` enemy-stats `gemDropType`) |
| Q4 mnemonic/var names | M | `$26` is the table byte offset, `$10` bit `$0400` and `#$0420` / `#$2700` flag words had no meaning | E1 |
| Q5 new mnemonic | NA | `chatPtr`, `playerHp`, `playerMaxHp` exist; `$26` is DP scratch | E1 |
| Q6 naming | **F** | "DarkGem" and "AnimVariantA / B" are wrong: the entries spawn gem or heal pickups and differ by item id; `AnimVariantA` is a table-only body | E1 (PROPOSED R-I049-1, R-I049-2) |
| Q7 evidence quality | M | E1 + E2 + E3; probabilities are computed from the threshold table (each group sums to 256); lifetimes are from the animation lists (the 2-tick and 75-tick pass lengths); the visible blink, the `$0400` clear and the sparkle position are not runtime-verified | E1, E2 (UNVERIFIED-RUNTIME: OQ-I049-3, OQ-I049-5, OQ-I049-6) |

Actions taken: block note rewritten; 13 new part notes; inline comments 20 new, 1 updated and 2 removed (the two misplaced comments); no mnemonics added.
Deferred: R-I049-1, R-I049-2, R-I049-6 (the wrong claim in `StandardEnemyDefeatHandler`'s header); OQ-I049-3, OQ-I049-5, OQ-I049-6.
Before/after stats: file 133 to 178 lines; inline comments 3 before, 21 after; header comment lines 3 before, 32 after; generic labels remaining: 3 (`code_00DF38`, `code_00DF61`, `code_00DFE3`).

### actors/camera_scroll_controller.asm (actor, 134 lines, Bank 00 60144-60314, parts: 12 code / 0 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | Reasonable inline comments, but no part notes and a block note with several claims that do not hold | E1 |
| Q2 value | M | The target / bounds arithmetic and the roles of the three flags were unclear | E1 |
| Q3 accuracy | **F** | (a) **There is no dead zone**: `P - $80` centres the player in the 256-pixel view; the old comments called it a "128px dead zone". (b) **`cameraBoundsX/Y` are the right / bottom edge** of the window (`+ $100` is compared with it), `cameraOffsetX/Y` the left / top edge. (c) **`playerFlags` bit `$0100` is forced walk**, not a generic "camera lock flag" (see `wram-memory-map.md`). (d) **`mapScrollV` is the BG1 vertical scroll** (`UploadScrollRegisters` writes it to `BG1VOFS`), not BG2. (e) **The delta step also runs while the target is held**, using whatever `forced_walk` wrote. (f) **`$12` bit `$1000`** is the display / overlay-active qualifier; `wram-memory-map.md` mislabels it "interact". (g) `playerXPos` is X - 8 and `playerYPos` is Y - `$10`, refreshed every frame. (h) **`loc_00EB48` and `loc_00EB74` are dead code** (never branched to; nothing else references them). (i) Both axes use `$80` / `$100`, but the screen is 224 lines tall. | E1 (the file; `actor_execution` display-filter modes; `CopyActorState`; `system_core.UploadScrollRegisters`; `player_character` attack setup for `$0200`), E2 (`rg` for the two dead labels: no references), E3 (`wram-memory-map.md` lines 224-241, 309, 434) |
| Q4 mnemonic/var names | M | `playerXPos` / `playerYPos` are sprite-adjusted (X - 8, Y - `$10`) and `effectDeltaX/Y` are not `cameraDeltaX/Y` (`camera_drift` writes the latter) | E1, E2 |
| Q5 new mnemonic | NA | All names exist | E1 |
| Q6 naming | M | The two dead labels are named like live code | E1 (PROPOSED R-I049-4) |
| Q7 evidence quality | M | E1 + E2 + E3; the vertical centring offset and the dead code are not run | E1, E2 (UNVERIFIED-RUNTIME: OQ-I049-4, OQ-I049-7) |

Actions taken: block note rewritten; 11 new part notes and 1 updated (`loc_00EB85`); inline comments 4 new, 6 updated and 1 removed; no mnemonics added.
Deferred: R-I049-4, R-I049-5 (docs); OQ-I049-4, OQ-I049-7.
Before/after stats: file 134 to 172 lines; inline comments 24 before, 27 after; header comment lines 6 before, 34 after; generic labels remaining: 10 `loc_` (all now have part notes).

### Iteration summary

Totals (from the dry run): 3 block notes updated; 69 part notes added and 3 updated; 26 inline comments added, 28 updated and 3 removed. No mnemonic, name or block change; the ROM is unchanged.

Patterns: (1) legacy headers described the drop and camera systems by their names instead of their data (a "dark gem" that is an item id, a "dead zone" that is a centring offset); (2) labels and comments that land on the wrong instruction (the gem file) or that are swapped (`debug_man` level 1); (3) the stat-up and display flags are misdescribed in the WRAM doc (see the docs list below).

Cross-file notes for later iterations: `StandardEnemyDefeatHandler.EnemyGemDropRouter` (header lines 144-147) says the kill-count value is in `orbitAngle`; the code tests the stat byte at +3 (`AND #$00FF` before the dispatch), to be fixed when that file is audited. `idle_sprite_display` (I042) already uses `DarkGemDropAnimVariantA` in its comments, so a rename needs updating there too.

Docs that repeat old claims (not edited, `docs/` is outside the allowed folder): `docs/code/bank0B-late-bosses-system-cutscene-actors.md` section 4.11 (about 35 destinations, the interaction mechanism) and line 741; `docs/cop/families/dialog.md` lines 87 and 152 (`actors/debug_man.asm:45` line references); `docs/cop/families/collision_paint.md` line 102; `docs/structs-reference.md` lines 105 and 880-904 ("dark gem", "`SpawnDarkGemWeighted`", variant list); `docs/code/bank00/README.md` lines 233, 665 and 669 ("7 variant handlers"); `docs/code/bank00/data-tables-memory.md` lines 50 and 117; `docs/wram-memory-map.md` line 214 ("BG2 scroll values"), line 224 ("dead zone") and line 434 (`$12` bit `$1000` "interact").

Gate: `npm run merge -- plans/extracted-audit/edits/I049.json --dry-run` reported 3 files; after the real merge, `npm run extract:lt` and a second dry run reported 0 notes files to change. `npm run rebuild` succeeded and `artifacts/crc.json` reads checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged). The `RTS` transform warning for the comment at 57287 was removed by rewording the comment.

Spec: `edits/I049.json`.

Suggested commit message: `audit(I049): document debug_man (21-destination warp menu, DialogueOptions row + 1 tables, corrected scene labels), DarkGemDropSystem (item ids $83-$86, HP-weighted drop table, lifetimes) and camera_scroll_controller (centring target, bounds as right/bottom edge, forced-walk skip, dead labels)`

Please commit when you're ready.
