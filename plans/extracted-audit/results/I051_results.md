# I051 - 2026-10-28 - files: actors/visual_effect_pipeline.asm, actors/boss_clear_reward_handler.asm, actors/field_reveal_object.asm
Status: COMPLETE

Spec: [edits/I051.json](../edits/I051.json). Proposals: [renames/I051_renames.md](../renames/I051_renames.md). Questions: [questions/I051_questions.md](../questions/I051_questions.md).

Conventions: verdicts **P/M/F/NA**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 coverage and verbosity, Q2 value, Q3 accuracy, Q4 mnemonic and variable names, Q5 new mnemonic, Q6 naming, Q7 evidence quality. Annotation style as in I049/I050: aggregated notes, a part note for every label, inline comments only for operands and non-obvious steps.

The spec also corrects two notes written in earlier iterations (see "Corrections to earlier iterations" below).

### actors/visual_effect_pipeline.asm (3 actors + 1 helper, 254 lines, Bank 00 59610-60053, parts: 20 code / 0 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | F | A header per actor but no part note for any of the 16 inner labels, and 18 inline comments of which every one was attached to the wrong line (they describe sine tables, `FollowSlopeDitherTable`, `UnsignedDivide`, "orbitAngle x 32" and "angle $05-$0C": text from a different routine) | E1 |
| Q2 value | F | The wrong comments actively misled; nothing said where the velocities come from, what the three actors do for the camera, or which variables are positions and which are deltas | E1, E2 |
| Q3 accuracy | **F** | (a) **The comments are garbage** (see Q1): 18 removed or replaced. (b) **`cameraDeltaX/Y` are the layer-1 scroll POSITION, not per-frame deltas**: `CameraSmoothScroll` copies them into `effectScrollH/V` (BG2) when `layerPriorityFlag` bit `$0400` is set. (c) **The velocity comes from the spawn record**: `InitActorFromSceneData` stores byte x 16 in `$14`/`$16`; the actor shifts it back down and decodes sign-magnitude (bit 7 = negative); the Y byte is decremented first, so the shipped records (`$01,$82` and `$02,$02`) give X +1, Y -1 and X +2, Y +1 px per frame (byte 0 would give +129, unused). (d) **`effect_subpixel_math` is not a refinement of the other two**: its `$14`/`$16` are set by the spawner (`$0201` in both sg55 spawns = camera target x 1/2, a half-speed parallax; `$000C` in `sg55_mystic_statue` for Y = +12 px per frame); a word with a nonzero high byte is the ratio lo / hi through `MulDivide`, otherwise the signed low byte is added. (e) **`effect_position_update` wraps** at `effectBoundsX/Y` (negative X wraps to the bound, negative Y to bound - 1); `effect_velocity_init` has no bounds. (f) **`effect_velocity_init` writes X only to `forcedScrollOverride`** (bit 15 set, the `ScrollCameraInit` convention) and Y to `cameraDeltaY`; `effectRenderDeltaX` gets the velocity, `effectRenderDeltaY` the position delta. (g) **No other file reads `forcedScrollOverride` or `effectRenderDeltaX/Y`** (only `scene_lifecycle` clears the latter). (h) The old text named Babel Tower; the spawn sites are four `scene_actors` entries ($09, $32, $4E, $50) and two Sky Garden scripts | E1 (the file; `hardware_math.MulDivide`; `camera_tilemap.CameraSmoothScroll`; `actor_execution.InitActorFromSceneData`; `camera_scroll_controller`), E2 (`scene_actors.asm` lines 987, 1636, 2004, 2055; `sg55_viper_arena` line 23, `sg55_mystic_statue` line 60; `rg` for `06C8`, `06E8`, `06EA`), E3 (`docs/code/bank00/actors-combat-interaction.md` lines 357-382 repeat the "camera/scroll effect subsystem in 22+ scenes" claim) |
| Q4 mnemonic/var names | M | `cameraDeltaX/Y` and `effectRenderDeltaX/Y` say "delta" for what are a position and an output; `$2C`/`$2E` are the velocity scratch | E1 |
| Q5 new mnemonic | NA | No new address is needed | E1 |
| Q6 naming | F | `visual_effect_pipeline`, `effect_*` name no layer or camera concept; `code_00E8DA` / `code_00E9EF` are the actor entries | PROPOSED R-I051-1, R-I051-2 |
| Q7 evidence quality | M | E1 + E2 + E3; the per-frame re-run of `effect_velocity_init` after its `WaitByte` (no own `SetEntryHere`) and the effect of the `forcedScrollOverride` write were not run | E1, E2 (UNVERIFIED-RUNTIME: OQ-I051-1, OQ-I051-2) |

Actions taken: block note rewritten; 17 new part notes (every inner label) and 3 updated (`effect_velocity_init`, `effect_subpixel_math`, `effect_position_update`); inline comments 34 new, 6 updated and 12 removed (the wrong ones); no mnemonics added.
Deferred: R-I051-1, R-I051-2; OQ-I051-1, OQ-I051-2.
Before/after stats: file 255 to 301 lines (`wc -l`); inline comments 18 before, 40 after; header comment lines 12 before, 40 after; generic labels remaining: 16 (`loc_` labels, now documented) plus `code_00E8DA`, `code_00E9EF`.

### actors/boss_clear_reward_handler.asm (1 actor + 1 subroutine + 1 table, 156 lines, Bank 00 49854-50070, parts: 14 code / 1 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A good set of 34 inline comments but no part notes for the 13 inner labels, and a header that mixed true and false statements | E1 |
| Q2 value | M | The comments narrate each instruction; the purpose (a catch-up of earlier rooms' rewards) and the table meaning were not stated | E1, E3 |
| Q3 accuracy | **F** | (a) **The flags are per SCENE, not per enemy**: the loop index is the scene id (`enemy_clear_reward_table` is indexed by scene) and `TestFlag_0300` / `SetFlag_0300` use `$0300 + scene`; the same flag is the one the room's own clear reward (`reward_actors`, `field_reveal_object`) tests, so a room cannot pay twice. (b) **`hpToHeal` is a heal counter, not a "flash HP bar timer"**: `UpdateHUD` refills 1 HP per 8 frames. (c) **The range is [first scene, last scene) and the last scene is the boss scene itself**; its tier is zero in all five rows, which ends the walk. (d) **Only the five boss rows are real** (`$29`, `$55`, `$67`, `$8A`, `$DD`); rows 5-10 are placeholders. (e) **Boss number = row index** = bit n of `wramFlags` `$0100` (event flags `$0500`-`$0507`). (f) **The range end is compared only after a zero tier**, and the scene search has no end test (harmless with the shipped data). (g) **The entry stores the range word in the actor's `$04` and the apply routine uses `$04`/`$0E`**: `wram-memory-map` lists `$04` as `prevActorLink`. (h) Tier 4 and above set the flag but give nothing | E1 (the file; `flag_helpers.TestFlag_0300`, `SetFlag_0300`, `TestWramFlag_Offset100`; `reward_actors` header and `RewardActorVFX`; `UpdateHUD`), E2 (`tables/enemy_clear_reward_table.asm` values at the five range ends, checked with `awk`; `scene_actors.asm` spawns), E3 (`structs-reference.md` boss-reward-range lines 912-931 are correct; `wram-memory-map.md` line 426 for `$04`) |
| Q4 mnemonic/var names | M | `$20` (row offset), `$04` (range word, then tier) and `$0E` (range end) are anonymous scratch | E1 |
| Q5 new mnemonic | NA | No new address is needed | E1 |
| Q6 naming | M | `BossRewardCheckInit` and `BossClearApplyStatReward` are fine; the `loc_` labels and `boss_reward_range_00C312` carry addresses | PROPOSED R-I051-3 |
| Q7 evidence quality | M | E1 + E2; whether the `$04` write damages the actor list was not examined at runtime | E1, E2 (UNVERIFIED-RUNTIME: OQ-I051-3) |

Actions taken: block note rewritten (flow, quirks); 14 new part notes (every label except the one that already had a note) and 1 updated (`BossClearApplyStatReward`); inline comments 3 new and 7 updated (the misleading ones); no mnemonics added.
Deferred: R-I051-3; OQ-I051-3.
Before/after stats: file 155 to 193 lines (`wc -l`); inline comments 34 before, 37 after; header comment lines 6 before, 29 after; generic labels remaining: 12 (10 `loc_` labels, `code_00C350` and `boss_reward_range_00C312`; all documented).

### actors/field_reveal_object.asm (1 actor + 2 tables + 8 stubs, 167 lines, Bank 00 55928-56200, parts: 15 code / 2 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | F | A 3-line header, no part notes and no inline comments in 166 lines of non-trivial code | E1 |
| Q2 value | F | Nothing explained the two pickup families, the downward probe, the hop or the life cycle | E1 |
| Q3 accuracy | **F** | (a) **Flag `$0300` means "this room's clear reward is already taken"**, not "all enemies cleared". (b) **Two pickup families**: the room tier (`enemy_clear_reward_table & 3`) gives a stat item (anim `$0C`-`$0E`, item `$80`-`$82` = Max HP / STR / DEF + 1); the spawner's stat byte +3 gives a gem (anim `$04`-`$06`, item `$83`-`$85` = 1 / 2 / 5 gems). "HP/STR/DEF gem sprites" mixed them. (c) **`$26` nonzero selects the gem path** (set by `EnemyDefeatDispatch` to the enemies remaining); `pyCC_mystic_ball` and `awB1_wall_walker` leave it 0. (d) **The "animates upward through solid tiles" is a downward probe**: from the spawn Y aligned to 16 px it moves down at most 8 rows while the tile is solid, stops early on collision byte `$0E`, and falls back to spawn Y + 1. (e) **The actor flies to the landing row (4 px per frame), hops once (Y chain `$45`), waits 11 frames and spawns `collect_handler_gem`** (L / R pulls it to the player), not a "spin / shrink loop". (f) **Gems expire after about 110 frames; stat items never do** (the `$28 >= 8` test). (g) **The script ends by running into `FieldRevealDieEmpty`** (a Die in the next block). (h) **Nothing here sets the scene flag `$0300`** | E1 (the file; `flag_helpers`, `cop_handlers_collision.BranchIfSolidHere`, `cop_handlers_movement.MoveToward`, `interaction_handlers` header; `movement_delta_table` chain `$45` followed by hand: -2, -2, -1, -1, 0, 0, +1, +1, +2, +2 then hold 0), E2 (the three spawn sites; `reward_actors` header for `RewardActorVFX` and the flag; `actor_pool.CopyActorState`), E3 (`interaction_handlers.asm` line 21 lists this actor as a spawner of `collect_handler_gem`) |
| Q4 mnemonic/var names | M | `orbitAngle` ($7F0010) is written `$FFFF` here and by `EnemyDefeatDispatch` as the enemies remaining (different meanings); `chatPtr` ($7F000A) carries the item id | E1, E2 |
| Q5 new mnemonic | NA | No new address is needed | E1 |
| Q6 naming | M | `FieldRevealHiddenSprite*` are the tier stat items and `FieldRevealCollectSprite*` the gems (names suggest the opposite); the `loc_` labels are the probe and the launch | PROPOSED R-I051-4 |
| Q7 evidence quality | M | E1 + E2; the `$FFFF` reader, the `$0E` collision byte, the blink animations and the scene-flag question were not resolved | E1, E2 (UNVERIFIED-RUNTIME: OQ-I051-4 to OQ-I051-7) |

Actions taken: block note rewritten; 17 new part notes (every label); 32 new inline comments; no mnemonics added.
Deferred: R-I051-4; OQ-I051-4, OQ-I051-5, OQ-I051-6, OQ-I051-7.
Before/after stats: file 166 to 224 lines (`wc -l`); inline comments 0 before, 32 after; header comment lines 3 before, 34 after; generic labels remaining: 8 (`code_list_00DAA4`, `code_list_00DAED`, `code_00DB21`, `loc_00DB0B`, `loc_00DB2C`, `loc_00DB43`, `loc_00DB47`, `loc_00DB69`; now documented).

### Corrections to earlier iterations (in the I051 spec)

| File | Iteration | Old claim | Corrected |
|------|-----------|-----------|-----------|
| `functions/EnemyDefeatDispatch.asm` | I046 | The stat-table byte +3 (low two bits) gives "a HP / STR / DEF gem"; part note and comment said "stat gem" | It gives a gem pickup worth 1 / 2 / 5 gems (items `$83` / `$84` / `$85`); the HP / STR / DEF items come only from the room-tier path of `field_reveal_object`, which this caller does not use. Block note, `EnemyDefeatDispatch_NotLast` part note and the `{697444}` comment rewritten |
| `functions/camera_drift.asm` | I050 | `cameraDeltaX/Y` are "the per-frame scroll deltas that the visual_effect_pipeline actors integrate" | They are the layer-1 scroll position (`CameraSmoothScroll` copies them to `effectScrollH/V` in layer-1 mode); the drift moves both layers together while that mode is active. The VARIABLES paragraph of the block note rewritten; OQ-I050-2 stays open |

### Iteration summary

- Files: 3 audited, 2 corrected. Verdict counts for Q3: 3 F. Notes written: 3 block notes (+2 rewritten for the corrections), 52 part notes (+1 corrected), 69 new inline comments, 13 updated and 12 removed.
- Patterns: (1) comments from a different routine attached to the wrong lines (visual pipeline); (2) the word "delta" used for a position (`cameraDeltaX/Y`); (3) per-enemy vs per-scene confusion for the `$0300` flag; (4) a flag named for the condition it does not test; (5) a script that ends by falling into the next block's `Die`; (6) bookkeeping fields (`$04`) used as scratch by an actor script.
- Docs repeating old claims: `docs/code/bank00/actors-combat-interaction.md` lines 357-382 (camera/scroll effect subsystem, `$06C8` seeding, "sub-pixel overflow pending"). `docs/structs-reference.md` boss-reward-range is correct.
- Gate: `npm run extract:lt` re-run, both specs dry-run to 0 files to change, `npm run rebuild` reports checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged).
- Spec: `plans/extracted-audit/edits/I051.json`.
- Suggested commit message: `Audit I051: layer-1 scroll drivers, boss stat catch-up, field reveal pickup; fix I046/I050 notes`

Please commit when you're ready.
