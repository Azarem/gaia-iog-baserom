# I046 results

Files: `actors/hit_stagger_controller.asm` (Bank 00), `functions/ApplyPlayerHitstun.asm` (Bank 00), `functions/EnemyDefeatDispatch.asm` (Bank 0A).
Spec: [edits/I046.json](../edits/I046.json). New proposals: [renames/I046_renames.md](../renames/I046_renames.md). New questions: [questions/I046_questions.md](../questions/I046_questions.md).

Conventions (unchanged): verdicts **P/M/F/NA**; dispositions **FIXED / PROPOSED / DEFERRED-EVIDENCE / NOFIX**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 comment density, Q2 value, Q3 accuracy, Q4 mnemonic/address accuracy, Q5 mnemonic opportunity, Q6 part naming, Q7 evidence quality.

### File 1: actors/hit_stagger_controller.asm (Bank 00)

Evidence: E1 (the whole file; `combat_collision` for both enemy-hit spawn sites, `ApplyInteractionDamage`, `CalcKnockbackDirection` and the `$0010` / `$0020` bits inherited by the child; `actor_pool.CopyActorState` for what the child inherits; `actor_execution` for the `$2000` run path, the `$12` bit 3 movement request and the iframe counter rules; `cop_handlers_force_move` and `cop_handlers_script_control` for `StageMove*`, `ForceDir*`, `LoopStart`, `SetEntryHereAndYield`, `WaitByte`; `player_move_controller` for the stun skip), E2 (`rg` for every reader and writer of `$free101C`, `onHitCallback`, `onDeathCallback`; the `movement_delta_table` entries `$22` and `$23` summed by hand: 48 px and 32 px), E3 (`docs/code/bank00/actors-combat-interaction.md`, `docs/wram-memory-map.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A few block-level lines and sparse comments; the 37 parts had no notes | FIXED (block note, 37 part notes, 214 comments covering every instruction) |
| Q2 | M | The reader could not tell what the spawner passes in, which flag selects the player, what the distance test does or why the player's stun ends early | FIXED (spawn contract, curves, slide loop, resolve and release paths, helpers) |
| Q3 | **F** | (a) **`$0400` in the child's `$10` marks the victim as the player, not an enemy**: `ReturnAI` only ever handles the player, and the enemy path (`ResolveHit`) is taken when the bit is clear. (b) **No "3-deep stack-encoded direction index" exists**: the direction code in `$28` is decoded with chained `DEC` / `BMI` and the branches `JSR` the movement stages, with `PEA HitStaggerDirection-1` as the common return. (c) **The slide is a fixed 16 frames of the child's own collision-checked movement** (the victim is only moved by copying `$14` / `$16` each frame), with curve entry `$22` (48 px) for tier 0 and `$23` (32 px) for tier 1 and above. (d) **`free101C` is a knockback tier**: 0 for ordinary actors, 1 for the player and `mu5F_cyclops`; the diary menu reuses the same word for something else, so the name is generic. (e) **Distance test**: d = abs(start - current); multiples of 16 are compared with `$30` / `$20` / `$40` by tier, any other d means a wall cut the slide short and the victim's delta chain on that axis is cleared. (f) **`ReturnAI` shortens the player's stun**: it overwrites the `$003C` iframe counter written by `ApplyPlayerHitstun` with `$FFE2`, so the stun lasts about 17 ticks, not 60. (g) **`ResolveHit`**: a surviving enemy's iframe counter becomes `$FFF4` and its `onHitCallback` replaces the entry address (low word only); a dead one gets `$10` bit `$0040` and the death callback, or `StandardEnemyDefeatHandler` in the same bank. (h) the spawner, not the child, sets the direction code and clears `$2C` / `$2E`; the child copies `extendedFlags` bit `$0020` ("hitstun skip") | FIXED |
| Q4 | M | The four-digit operands (`$0000`, `$002C`, `$002E`, `$0008`) read like DP words but are absolute; `$26` has two meanings (axis flag here, remaining count in the dispatcher's child) | FIXED (block note and comments) |
| Q5 | M | `orbitAngle` / `orbitDiameter` hold the start X / Y here; `free101C` is the tier; `moveScratch1/2` are the X / Y delta words | PROPOSED (R-I046-4, R-I046-5) |
| Q6 | M | `HitStaggerDirection` is the slide loop; `HitStaggerReturnAI` releases the player; `HitStaggerKnockbackCallbackPass` is a Z-to-carry converter | PROPOSED (R-I046-1, R-I046-2, R-I046-3) |
| Q7 | M | E1 + E2 + hand-summed curves; the purpose of the cut-short cleanup and the use of tiers 2 and above are inferred | DEFERRED-EVIDENCE (OQ-I046-3, OQ-I046-5) |

### File 2: functions/ApplyPlayerHitstun.asm (Bank 00)

Evidence: E1 (the whole file; `combat_collision.ApplyInteractionDamage` for the sibling code; `SpawnListAppend` in `cop_handlers_*` for the operand order, the flags word and the failed-spawn Y value; `joypadMaskStd` handling in `actor_execution` and `player_move_controller`), E2 (all 9 `JSL` sites in `gw82_archer`, `gw83_asp`, `ir1F_stone_guard` with the A and Y values read at each; `$0B02` = difficulty in `ram_map.txt`), E3 (`docs/code/bank00/functions-player-npc.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A short header, almost no inline comments | FIXED (block note, 7 part notes, 53 comments) |
| Q2 | M | The header gave the wrong argument layout and function | FIXED (arguments, steps, call table) |
| Q3 | **F** | (a) **Arguments**: A = damage with bit 15 as the heavy-hit flag, Y = direction code; the old header said "damage in Y and knockback metadata on the stack". (b) **Damage is not halved**: `ASL` / `LSR` cancel out, bit 15 only selects the `$FFC4` iframe counter. (c) **`$2400` is the child's flags word** (script-driven + player victim), not a priority. (d) **The function never hides the D-pad**: it only reveals it, on the lock path and on the failed-spawn path; callers hide it with `TSB #$0F00` first. (e) **Fall-through on a failed spawn**: with Y = `$1FC0` the child-setup stores still run, unlike `ApplyInteractionDamage` which skips them. (f) **The `$003C` stun is shortened** by `HitStaggerReturnAI` as in file 1. (g) **9 call sites** in 3 files, not "about 12"; the stone guard adds the difficulty (`$0B02`) to its two strongest hits | FIXED |
| Q4 | M | Operands `$0000`, `$0002`, `#$FFC4`, `#$003C`, `#$2400`, `#07` carried no meaning | FIXED (comment on each) |
| Q5 | NA | The scratch words `$0000` / `$0002` are absolute globals; no mnemonic exists and creating one for two locals is not warranted | NOFIX |
| Q6 | P | `ApplyPlayerHitstun` is an accurate name: the routine applies the damage, the hit reaction and the stagger | NOFIX |
| Q7 | M | E1 + E2; the failed-spawn path and the sound choice are not runtime-verified | DEFERRED-EVIDENCE (OQ-I046-1, OQ-I046-2) |

### File 3: functions/EnemyDefeatDispatch.asm (Bank 0A)

Evidence: E1 (the whole file; `StandardEnemyDefeatHandler`, `EnemyDeathFlash`, `SpawnFieldRevealEffect` and `field_reveal_object` for the `$26` semantics and the stat-table byte at +3; `flag_helpers` for `TestFlag_0100` / `SetDungeonKillFlag`; `cop_handlers_collision` for `ClearSolidHere`), E2 (the three callers `gw82_fire_bug`, `av6D_dive_bat`, `gw8A_sand_fanger`; the enemy-count words in `ram_map.txt`), E3 (`docs/code/bank0A-dungeon-enemy-actors.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A one-paragraph header and sparse comments | FIXED (block note, 4 new part notes and 1 updated, 51 comments) |
| Q2 | M | The reader could not see the two branches or what `$26` means for the spawned child | FIXED |
| Q3 | **F** | (a) **The dispatch tests `$0AEC` = 1 ("last enemy")**: only then does it hand over to `StandardEnemyDefeatHandler`, which does the full defeat and the clear reward; every other kill takes `code_0AA474` and spawns `field_reveal_object`. (b) **The child's `$26` carries the remaining count**, and a nonzero value makes `field_reveal_object` use the defeated enemy's own stats (the low two bits of the stat byte at +3 pick none or a HP / STR / DEF gem). The old note said only "spawn stat gem reveal". (c) **Differences from the standard handler**: death sound `#03` instead of `#06`, no boss / stat-table checks, no `WaitByte`, no `EnemyGemDropRouter`, and no `$1000` priority boost on the flash. (d) **The callers** reach it with `COP JumpFar` from a death callback. (e) **Field-reveal bookkeeping**: the index in `$7F0024` is tested against event flag `$0100 + idx` and the effect is spawned once | FIXED |
| Q4 | M | `$0AEC` / `$0AEE` are the enemy counts in hex and BCD; the old text did not say which | FIXED |
| Q5 | NA | `enemiesRemaining` / `enemiesRemainingBcd` already exist | NOFIX |
| Q6 | M | `code_0AA474` is the shared kill-count step; `loc_0AA460` is the non-last branch | PROPOSED (R-I046-6) |
| Q7 | M | E1 + E2; the edge case `$0AEC` = 0 and the visible result of the `field_reveal_object` spawn are not traced at runtime | DEFERRED-EVIDENCE (OQ-I046-4, OQ-I046-6) |

### Shared gate (I046)

`npm run merge -- plans/extracted-audit/edits/I046.json --dry-run` reported 3 block notes (all updated), 49 part notes (48 new, 1 updated) and 318 comments (282 new, 36 updated). Per file: `hit_stagger_controller` 37 parts (all new) and 214 comments (206 new, 8 updated); `ApplyPlayerHitstun` 7 parts (all new) and 53 comments (49 new, 4 updated); `EnemyDefeatDispatch` 5 parts (4 new, 1 updated) and 51 comments (27 new, 24 updated).

Merge warnings: three `RTS` transform warnings for `hit_stagger_controller` (comments at 55480, 55922, 55927; false positive, the `RTS`-to-`RTL` transform applies only inside `CreditPositionLookup`, and the extracted lines show the comment text unchanged), and five "part note already lives in bank0A but the file resolves to bank0B; keeping the existing bank" notices for `EnemyDefeatDispatch` (the ROM address 697407 is bank 0A; the existing notes stay in `notes/*/bank0A.json` and the round trip below is clean).

After the real merge of I045 and I046, `npm run extract:lt` and the repeated dry runs of both specs reported 0 files to change. `npm run rebuild` finished successfully and `artifacts/crc.json` reads checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged).

Docs that repeat the old claims (not edited, `docs/` is outside the allowed folder): `docs/code/bank00/actors-combat-interaction.md` lines 37-111 (`$0400` as an enemy marker, the "re-enables AI" `ReturnAI` row, the algorithm lists for `HitStaggerMain` / `HitStaggerDirection`, "~12 enemy types"); `docs/code/bank00/functions-player-npc.md` lines 17, 27-64 and 300 (damage "in Y", halving, joypad masking for heavy hits, "~12 callers"); `docs/code/bank00/README.md` lines 700 and 871 ("~12 callers"); `docs/code/bank00/data-tables-memory.md` line 569 ("~12"); `docs/code/bank0A-dungeon-enemy-actors.md` lines 542, 583 and 605 (the dispatcher as the standard death pipeline, without the last-enemy branch and the `$26` count); `docs/code/bank00/actors-player-rewards.md` line 462 and `docs/code/bank00/functions-combat-defeat.md` line 219 ("generic field reveal helper" / "generic enemy death").

Suggested commit message: `audit(I046): document hit_stagger_controller (spawn contract, $0400 = player victim, 16-frame slide with curves $22 / $23, cut-short test, ReturnAI shortening the stun), ApplyPlayerHitstun (A = damage + heavy flag, Y = direction, 9 call sites) and EnemyDefeatDispatch (last-enemy branch, field_reveal_object count in $26)`

Please commit when you're ready.
