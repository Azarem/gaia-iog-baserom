# I050 - 2026-10-27 - files: system/inventory/inventory_mgmt.asm, functions/npc_wander_ai.asm, functions/camera_drift.asm
Status: COMPLETE

Spec: [edits/I050.json](../edits/I050.json). Proposals: [renames/I050_renames.md](../renames/I050_renames.md). Questions: [questions/I050_questions.md](../questions/I050_questions.md).

Conventions: verdicts **P/M/F/NA**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 coverage and verbosity, Q2 value, Q3 accuracy, Q4 mnemonic and variable names, Q5 new mnemonic, Q6 naming, Q7 evidence quality. Annotation style as in I049: aggregated notes, inline comments only for operands and non-obvious steps.

### system/inventory/inventory_mgmt.asm (6 functions, 279 lines, Bank 03 257943-258249, parts: 25 code / 0 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A long header and one comment per instruction, 7 part notes, but no notes for the 19 inner labels and several comments restated a label or a handler name | E1 |
| Q2 value | M | Good structure, but the stat-up, gem and heal paths hid their side effects and the return convention | E1, E2 |
| Q3 accuracy | **F** | (a) **The `$55` is not a cap**: the 8-bit add `ADC #$01` / `BVC` triggers only when the old value is `$7F` (signed overflow), and then stores `$55`; below that the stat is unbounded and from `$80` it keeps counting up to `$FF` and wraps. (b) **`displayModeFlags` bit `$0080` is the display-filter actor mode** (`RunActors_Normal` switches to `RunActors_DisplayFiltered`; the chest code sets it), not a "HUD" or "stat-up refresh" bit. (c) **Only HP Max Up sets `hpToHeal`** (`new max - HP`, 8-bit), not STR / DEF. (d) **The `$86` and above path is a heal, not a "damage flash"**: `hpToHeal += 5` (`UpdateHUD` refills 1 HP every 8 frames), the sparkle effect and SFX `$22`. (e) **The spark is spawned at the calling actor** (`PHD / TXA / TCD`), not at the player, and the COP is `SpawnListAppend`, not "`SpawnLastRel`". (f) **Y and `$0DB8` are only set for regular items and the full case**: stat-ups return Y = 0 and gems and the heal leave Y alone. (g) `RemoveItemFromInventory` resets the equip state only when the id was found (the old text implied always). (h) Ten `JSL` sites in 5 files call `GiveItemToPlayer` | E1 (the file; `system_core.UpdateHUD` and `RunActors_Normal` / `actor_execution` display modes; `warps_interaction` chest code lines 38 and 345-379; `cop_handlers_inventory` lines 21-67; `combat_collision` lines 1559-1573), E2 (`rg` over `extracted/` for the callers), E3 (`docs/code/bank03/field-input-and-items.md` lines 360-364 repeat the "cap" claim; `docs/cop/families/inventory.md` lines 18 and 110) |
| Q4 mnemonic/var names | M | `$0DB8` / `$0DB9` (the item id shown by the item-get dialogue) are raw addresses in all four files that use them | E2 (`rg`: 3 sites here, 2 in `combat_collision`, 3 in `warps_interaction`, a comment in `cop_handlers_inventory`) |
| Q5 new mnemonic | M | `$0DB8` = last item id for the dialogue text | PROPOSED R-I050-1 (not applied: the plan limits this iteration to notes) |
| Q6 naming | P | `GiveItemToPlayer`, `GiveItem_*`, `RemoveItemFromInventory` and `CheckInventoryForItem` say what they do | E1 |
| Q7 evidence quality | M | E1 + E2 + E3; the `$7F` reset, the sparkle position for each caller and the 8-bit hpToHeal difference were not run | E1, E2 (UNVERIFIED-RUNTIME: OQ-I050-1, OQ-I050-6) |

Actions taken: block note rewritten; 19 new part notes (one per inner `loc_` label) and 2 updated (`GiveItemToPlayer`, `GiveItem_DefUp`); inline comments 7 new, 9 updated and 7 removed (comments that only repeated a label or a handler name); no mnemonics added.
Deferred: R-I050-1, R-I050-5; OQ-I050-1, OQ-I050-6.
Before/after stats: file 279 to 306 lines; inline comments 45 before, 45 after (net 0: 7 new, 7 removed, 9 corrected); header comment lines 45 before, 54 after; generic labels remaining: 0 (the `loc_` labels are now documented).

### functions/npc_wander_ai.asm (2 entries + 8 handlers, 140 lines, Bank 00 50968-51193, parts: 12 code / 1 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 3-line header and a few misplaced comments; no part notes | E1 |
| Q2 value | M | The calling pattern, the data words and the meaning of a step were not explained | E1, E2 |
| Q3 accuracy | **F** | (a) **The case table is 0 stand north, 1 stand south, 2 stand west, 3 stand east, 4 step north, 5 step south, 6 step west, 7 step east**; the old text and the `NpcWanderStandAnim` / `Step` order hid the north / south swap. (b) **A step is not "one tile"**: the delta chain is `$11` / `$12` = +1 / -1 pixel every second frame (0.5 px per frame) and the caller's `AnimOnce` ends it (and clears `$2C` / `$2E`) when the walk animation list ends. The step length is half the number of walk frames. (c) **The routine calls `MarkSolidHere` when standing and `ClearSolidHere` when walking**, not "`SolidHighHere` / `ClearLowHere`". (d) **Out-of-range or blocked steps turn into a stand facing that direction**, so about half of the rolls end in a pure turn. (e) **The wander range is `$30` pixels from the home** (`SyncActorPosFromDP`). (f) **`orbitAngle` / `orbitDiameter` are the home X / Y and `currentHp` is the base animation index** (base + 0 to 3 stand S/N/W/E, base + 4 to 7 walk S/N/W/E). (g) **13 NPC actors use it**, not about 12; the old `StageForceMoveY #11` comment named a nonexistent COP and said "on blocked path". (h) There is no re-roll in the middle of a step; the caller's loop waits for `AnimOnce` | E1 (the file; `cop_handlers_dungeon_switch.SwitchCase`, `cop_handlers_sprite.AnimOnce`, `StageMoveX/Y` and `BranchIfSolid*`; `tables/movement_delta_table.asm` entries `$11` and `$12`), E2 (the 13 callers; `wa78_water_kid` and `sc01_roof_man` loop code), E3 (`structs-reference.md` actor-def) |
| Q4 mnemonic/var names | M | The three mnemonics hide the meaning (see Q3 f); `$0000` is the case-index scratch | E1, E2 |
| Q5 new mnemonic | M | File-local aliases would help (the same mnemonics mean other things in 79 / 53 other files) | PROPOSED R-I050-2 |
| Q6 naming | M | `NpcWanderStandAnim0..3` are numbers, not directions; `loc_00C76B` / `loc_00C7EF` are the two shared tails | PROPOSED R-I050-3 |
| Q7 evidence quality | M | E1 + E2; the walk animation lengths per NPC and the visible result were not run | E1, E2 (UNVERIFIED-RUNTIME: OQ-I050-3) |

Actions taken: block note rewritten; 13 new part notes; inline comments 17 new, 2 updated and 1 removed; no mnemonics added.
Deferred: R-I050-2, R-I050-3, R-I050-5; OQ-I050-3.
Before/after stats: file 140 to 186 lines; inline comments 3 before, 19 after; header comment lines 5 before, 29 after; generic labels remaining: 2 (`loc_00C76B`, `loc_00C7EF`) plus `code_list_00C733`.

### functions/camera_drift.asm (3 actor scripts + table, 141 lines, Bank 00 53134-53350, parts: 11 code / 1 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A good header paragraph, 4 comments, no part notes | E1 |
| Q2 value | M | The three scripts differ in how they undo their offsets and in lifetime; nothing said what the words are | E1, E2 |
| Q3 accuracy | **F** | (a) **`CameraDriftLoopSimple` adds -1 to +2** (bias +0.5), not "+-1" (the same formula as the Y shake in `player_character`); the offset is never undone. (b) **`CameraDriftLoopShip` replaces its delta offset each frame** (undo `$26`, add a new 0 to 3) and skips forced-walk frames; the target offset is not undone. (c) **`CameraDriftPatterned` lives about 9 frames**: 3 runs, 3 frames apart (`$08 = 3`, `$2A` counts 2, 1, 0 and then dies), each run adding consecutive entries of the table to Y and then to X; the `$24 = $FFFF` test skips the delta update. (d) **Only the first 8 words of `binary_00D068` are used** (the index is masked to 3 bits); the second 8 words are unreferenced. (e) **The words written are `cameraTargetX/Y` and `cameraDeltaX/Y`**, not the `effectDeltaX/Y` that `camera_scroll_controller` writes. (f) **Callers**: `Simple` in `pyCD_flame_statue`, `ir25_ceiling_tile`, `ir29_castoth`; `Ship` in `st68_kara`, `gs2D_lily`, `gs2D_lance`, `gs2B_erik` (Gold Ship as well as the undersea tunnel); `Patterned` in `awB1_gorgon`, `pyD9_dangerslide_controller`, `ir29_castoth` (3 sites). The old list missed the Gold Ship and the Gorgon | E1 (the file; `LoopStart` / `LoopEnd` handlers; `player_character` Y shake lines around 698; `visual_effect_pipeline` consumers of `cameraDeltaX/Y`), E2 (`rg` over `extracted/` for the 16 spawn sites), E3 (`wram-memory-map.md` lines 225-227) |
| Q4 mnemonic/var names | M | `$24`, `$26`, `$28`, `$2A` and `$08` are actor DP fields with a different meaning in each script | E1 |
| Q5 new mnemonic | NA | The camera words already exist; the DP fields are per-script scratch | E1 |
| Q6 naming | M | `binary_00D068` is a raw hex blob of 16 signed words; the table has an obvious role | PROPOSED R-I050-4 |
| Q7 evidence quality | M | E1 + E2; whether the offsets survive the camera controller's recompute and the `$24 = $FFFF` case are not traced | E1, E2 (UNVERIFIED-RUNTIME: OQ-I050-2, OQ-I050-4, OQ-I050-5) |

Actions taken: block note rewritten; 12 new part notes; inline comments 15 new and 4 updated; no mnemonics added.
Deferred: R-I050-4; OQ-I050-2, OQ-I050-4, OQ-I050-5.
Before/after stats: file 141 to 184 lines; inline comments 4 before, 19 after; header comment lines 3 before, 34 after; generic labels remaining: 7 `loc_` (all now have part notes).

### Iteration summary

Totals (from the dry run): 3 block notes updated; 44 part notes added and 2 updated; 39 inline comments added, 15 updated and 8 removed. No mnemonic, name or block change; the ROM is unchanged.

Patterns: (1) numeric claims in the old text that do not match the data (a "cap" that is a one-value reset, "one tile" that is half a pixel per frame for an animation, "+-1" that is -1 to +2); (2) handler names that do not exist or do not match (`SpawnLastRel`, `SolidHighHere`, `ClearLowHere`); (3) mnemonics whose names describe another system's use of the same address (`orbitAngle`, `currentHp`); (4) comments that restate a label or a handler name and were removed.

Cross-file notes: `docs/code/bank03/field-input-and-items.md` lines 360-364 repeat the "cap at `$55`" claim and line 399 describes `$0DB8`; `docs/code/bank04-npc-actors.md` line 402 lists only two users of `NpcRandomWanderAI`; `docs/wram-memory-map.md` still has the `$068E` and `$12` bit `$1000` entries listed in the I049 results. `debug_man` (I049) sets STR and DEF to 127 (`$7F`), so a STR Up item in that state is the one case that triggers the `$55` reset in `GiveItemToPlayer` (OQ-I050-1).

Gate: `npm run merge -- plans/extracted-audit/edits/I050.json --dry-run` reported 3 files; after the real merge, `npm run extract:lt` and a second dry run of both I049 and I050 reported 0 notes files to change. `npm run rebuild` succeeded and `artifacts/crc.json` reads checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged).

Spec: `edits/I050.json`.

Suggested commit message: `audit(I050): document inventory_mgmt (item id encoding, $7F stat reset not a cap, heal path, return convention), npc_wander_ai (8-case table, half-pixel steps ended by AnimOnce, 13 users) and camera_drift (Simple/Ship/Patterned offsets and lifetimes, unused half of the offset table)`

Please commit when you're ready.
