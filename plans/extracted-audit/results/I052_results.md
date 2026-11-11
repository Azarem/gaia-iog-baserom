# I052 - 2026-10-28 - files: actors/player_transition_handlers.asm, functions/SpawnFieldRevealEffect.asm, functions/EscortFollowPathTracker.asm
Status: COMPLETE

Spec: [edits/I052.json](../edits/I052.json). Proposals: [renames/I052_renames.md](../renames/I052_renames.md). Questions: [questions/I052_questions.md](../questions/I052_questions.md).

Conventions: verdicts **P/M/F/NA**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 coverage and verbosity, Q2 value, Q3 accuracy, Q4 mnemonic and variable names, Q5 new mnemonic, Q6 naming, Q7 evidence quality. Annotation style as in I049/I050: aggregated notes, a part note for every label, inline comments only for operands and non-obvious steps.

### actors/player_transition_handlers.asm (24 labelled entry points, 248 lines, Bank 00 50200-50671, parts: 24 code / 0 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | F | A header of three paragraphs, 4 inline comments and no part note for any of the 24 entry points (the file is a library of unrelated routines) | E1 |
| Q2 value | F | The header said what kinds of moments exist but not how a routine is entered (pointer written into the player actor), who calls which one, or what the flag bits mean | E1, E2 |
| Q3 accuracy | **F** | (a) **The routines are entered by writing the player actor's entry pointer** (`$0000,Y` / `$0002,Y`, then `$0008,Y := 0`), so X = D = the player slot; 15 callers found by `rg`. (b) **`PlayerItemRevealSpawn` is an impact spark, not an item reveal**: SFX `$09`, frame `$2A`, `Die`; spawned by `gw82_archer` (at X +- 14, Y - 14) and by the first entry `player_transition_handlers`, which is also the default script `combat_collision.ApplyHitDamageToVictim` writes into a struck actor (`$10 |= $0040`) and the `JumpFar` target of `gw8A_sand_fanger` (old repo docs call it `SpawnSparkleEffect`). (c) **The joypad mask is `$CFFC`**, not `$CFF0` (hides every button except Select / Start). (d) **`layerPriorityFlag` bit `$0200` freezes the camera** (`camera_scroll_controller` returns at once), it does not "force layer priority". (e) **`NudgePosition` operands are signed bytes**: the fall starts 128 px higher (`$80`), the Sky Garden jump moves -64, +64, -32, +32. (f) **`PlayerIdleEntry` clears `playerFlags $2800`**, which releases the `$0800` lock these routines (or their callers) set; they never clear it themselves. (g) **`PlayerIdleAnimLoop` picks anim `$11` or `$01` by per-scene flag `#00`**, then loops forever. (h) **The aura routine has two phases**: a one-frame scan down to the first blocked tile, a test for terrain type `$04` below it, then a 1 px per frame sink until type `$04` and a slide until the tile type is 0; the old comment named only the first. (i) **`PlayerIdleEntryJump` has no reference**. (j) **The name Freedan has no support in the callers** (Gold Ship, Oakton, adrift scenes; `gs2E_sleep` moves the player up 8 px first). (k) The Sky Garden jump never masks or unmasks the buttons | E1 (the file; `player_character` header and `PlayerIdleEntry`; `combat_collision.ApplyHitDamageToVictim`; `cop_handlers_oam_attribs.NudgePosition` / `ToggleVMirror`; `cop_handlers_scene_flags.BranchOnFlagByte`; `cop_handlers_collision.BranchIfSolidHere` / `BranchIfSolidType*`; `camera_scroll_controller` line 57; `movement_delta_table` chains 0-4, 7, 8 read from the table), E2 (`rg` for every label: `warps_interaction` 450 and 485, `item_use_system` 1652, 1776 and 1807, `awBD_fall_trigger` 47, `sg4D_jump_handler` 48, `gs2D_lily` 31, `gs2E_sleep` 50, `dc2F_adrift` 539, `dc31_rescuer` 27, `dc31_kara` 34, `ir29_castoth` 1152 and 1164, `gw82_archer` 563, `gw8A_sand_fanger` 1308, `combat_collision` 709), E3 (`actors/shadow_shimmer.asm` and `scene_flag_init.asm` for flag `#00`; `item_use_system.UseItem_Aura` header; `docs/code/README.md` line 192 names the first entry `SpawnSparkleEffect`; `docs/cop/families/player_sprite.md` line 102 repeats "Freedan reveal") |
| Q4 mnemonic/var names | M | `$10` bits (`$0008`, `$0200`, `$2000`, `$0002`) and `$24` / `$26` (saved X / Y in the aura code) are anonymous | E1 |
| Q5 new mnemonic | NA | No new address is needed | E1 |
| Q6 naming | F | `PlayerItemRevealSpawn` and `player_transition_handlers` (as an entry label) hide the spark; `PlayerFreedanReveal*` has no evidence; `PlayerIdleEntryJump` is unreferenced | PROPOSED R-I052-1, R-I052-2 |
| Q7 evidence quality | M | E1 + E2 + E3; what the flag `#00`, frame `$20` of body 4, terrain type `$04` and `$10` bit `$0002` mean and whether the fall ends on the original Y were not run | E1, E2, E3 (UNVERIFIED-RUNTIME: OQ-I052-1 to OQ-I052-5, OQ-I052-9) |

Actions taken: block note rewritten (entry mechanism, callers, flag bits); 24 new part notes (every label); inline comments 61 new, 2 updated and 1 removed (a label echo); no mnemonics added.
Deferred: R-I052-1, R-I052-2, R-I052-3; OQ-I052-1 to OQ-I052-5, OQ-I052-9.
Before/after stats: file 247 to 321 lines (`wc -l`); inline comments 4 before, 64 after; header comment lines 5 before, 42 after; generic labels remaining: 0.

### functions/SpawnFieldRevealEffect.asm (3 actor bodies, 169 lines, Bank 00 56818-57107, parts: 11 code / 0 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 7-line header and 27 inline comments, no notes for the 8 inner labels, and most of the table-reading comments were wrong | E1 |
| Q2 value | M | The sequence was described; the target arithmetic and the scatter ranges were not understood | E1 |
| Q3 accuracy | **F** | (a) **The event-block bytes are +3 width, +4 height, +5 dstX, +6 dstY** (`event-block-def`), not "tile" and "size"; the target is the CENTRE of the destination rectangle, `(2 x dstX + width) x 8` (same for Y). (b) **`orbitAngle` / `orbitDiameter` are half the width / height**, passed to the sparkles as `$20` / `$22` (the old comment said half-size "range" without the source). (c) **Four spawn sites**: `StandardEnemyDefeatHandler` (56375), `EnemyDefeatDispatch_CountKill` (697548, guarded by event flag `$0100 + index`), `pyCC_mystic_ball` (771970), `awB1_wall_walker` (770414); the "Incan Ruins wind trap" has no spawn. (d) **The scatter ranges differ per axis**: X `>= 4` 0-63 px, 2-3 0-31, 0-1 0-15; Y `>= 3` 0-63, 2 0-31, 0-1 0-15 (the old header gave the X tiers for both). (e) **`field_reveal_scatter` has no `Die`: it runs into `field_reveal_flash`**, so each of the ten sparkles also plays SFX `$06` on both channels and shows frame `$25`; the arrival flash is the same code started directly. (f) **The "rising animation" is three passes with Y chains `$02`, `$12`, `$14`**, then a 2-pass hover. (g) **Children get `$12 |= $1000`** because `CopyActorState` clears it. (h) `StageBgChangeFromDeathIdx` queues SFX `$0F` on both channels (handler header) | E1 (the file; `cop_handlers_bg_rearrange` headers; `cop_handlers_movement.StageMove`; `actor_pool.CopyActorState`), E2 (`rg` for the four spawn sites; `EnemyDefeatDispatch` lines 90-98), E3 (`docs/structs-reference.md` event-block-def lines 1045-1064 are correct) |
| Q4 mnemonic/var names | M | `orbitAngle` / `orbitDiameter` hold half-width / half-height here, the escort ring head / animation base in `EscortFollowPathTracker` and the home position in `npc_wander_ai` | E1, E2 |
| Q5 new mnemonic | NA | No new address is needed | E1 |
| Q6 naming | M | `SpawnFieldRevealEffect` names the spawn, not the actor; `field_reveal_scatter` hides the fall-through; the `loc_` labels are the tier branches | PROPOSED R-I052-4 |
| Q7 evidence quality | M | E1 + E2 + E3; the exact rise distance (chain `$14`), the fact that `dstX` is in 16 px units and the visual result were not run | E1, E2 (UNVERIFIED-RUNTIME: OQ-I052-6) |

Actions taken: block note rewritten; 9 new part notes and 2 updated (`field_reveal_scatter`, `field_reveal_flash`); inline comments 5 new and 16 updated (the table-reading and sequence ones); no mnemonics added.
Deferred: R-I052-4; OQ-I052-6.
Before/after stats: file 168 to 193 lines (`wc -l`); inline comments 27 before, 32 after; header comment lines 11 before, 27 after; generic labels remaining: 8 (`loc_00DECC` ... `loc_00DF05`, now documented).

### functions/EscortFollowPathTracker.asm (1 actor + 1 table, 177 lines, Bank 00 51206-51538, parts: 7 code / 1 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | F | A 3-line header, 4 inline comments (3 of them describing other code) and no part notes | E1 |
| Q2 value | F | The ring buffer, the seed, the replay delay and the idle branch were not explained | E1 |
| Q3 accuracy | **F** | (a) **`orbitAngle` is a seed on entry**: facing + 1 (Lily passes 4), or 0 = ask `GetPlayerFacingDirection`; it is not a "timer" to decrement. After setup it is the ring head. (b) **The ring has 8 entries, not 9**: setup writes 9 (offsets `$00`-`$40`), but every read masks with `$3F`, so `$7EDF40` is never used. (c) **The head advances by 8 only on frames where the player moved**, not every frame. (d) **The NPC is the actor's list predecessor (`$04`)**, which is how the tracker moves and animates it. (e) **The NPC walks the player's route about 8 recorded frames behind**: it takes the head entry (written 8 frames ago), the head is overwritten with the player's current position. (f) **Animation = `orbitDiameter` + facing (+4 while walking)**, restarted only when the facing changed; while the player stands still the NPC shows `orbitDiameter` + facing and `$0E := $FFFF`. (g) **The initial trail runs along the OPPOSITE of the facing** (table rows: South `(0, -2)`, North `(0, +2)`, West `(+2, 0)`, East `(-2, 0)`) with the opposite facing word. (h) **An unknown facing (carry set, A >= 4) would index past the table** | E1 (the file; `GetPlayerFacingDirection` lines 32-55; `SetPlayerIdleFacing` header for the facing order), E2 (seven spawn sites; `it1A_lily` lines 37-56 for the seed 4 and base `$1A`; `rg` for `7EDF`: no other user; `docs/wram-memory-map.md` line 426 for `$04`), E3 (`docs/code/bank00/data-tables-memory.md` line 113 repeats "9 XY waypoint pairs") |
| Q4 mnemonic/var names | M | `orbitAngle` / `orbitDiameter` are the ring head and the animation base here; `$0E` (last facing), `$14` / `$16` (player's last position), `$1C` (row facing word) are anonymous | E1 |
| Q5 new mnemonic | NA | No new address is needed | E1 |
| Q6 naming | M | `EscortFollowPathTracker` and the table are fine; the five `loc_` labels are the tail steps | PROPOSED R-I052-5 |
| Q7 evidence quality | M | E1 + E2 + E3; the opposite-facing trail, the 8-frame delay and the out-of-range facing were not run | E1, E2 (UNVERIFIED-RUNTIME: OQ-I052-7, OQ-I052-8) |

Actions taken: block note rewritten; 8 new part notes (every label); inline comments 24 new and 4 updated (the stale ones); no mnemonics added.
Deferred: R-I052-5; OQ-I052-7, OQ-I052-8.
Before/after stats: file 176 to 207 lines (`wc -l`); inline comments 4 before, 28 after; header comment lines 3 before, 25 after; generic labels remaining: 6 (`loc_00C810`, `loc_00C814`, `loc_00C830`, `loc_00C89F`, `loc_00C8F7`, `loc_00C924`; now documented).

### Iteration summary

- Files: 3 audited. Q3: 3 F. Notes written: 3 block notes, 43 part notes, 90 new inline comments, 22 updated and 1 removed.
- Patterns: (1) a shared library whose entries are reached by pointer writes, not by calls (the callers are only visible through the `LDA #$&label` / `STA $0000, Y` pairs); (2) names from an old guess (Freedan, item reveal) that no caller supports; (3) scratch mnemonics (`orbitAngle`, `orbitDiameter`) reused with different meanings (now four meanings across the audited files); (4) a routine that falls through into a second actor body (`field_reveal_scatter` into `field_reveal_flash`, as `field_reveal_object` into `FieldRevealDieEmpty`); (5) table-reading comments that named the wrong struct fields; (6) a buffer written one entry longer than it is read.
- Docs repeating old claims: `docs/code/bank00/data-tables-memory.md` line 113 (9 XY waypoint pairs); `docs/code/README.md` line 192 (`SpawnSparkleEffect`, the old name); `docs/cop/families/player_sprite.md` line 102 ("Freedan reveal" poses); `docs/code/bank05-midgame-actors.md` line 112 ("freezes the player via `PlayerFreedanRevealIdle`" is accurate, the label is the problem). Not re-checked: `docs/code/bank00/actors-player-rewards.md` line 117 section.
- Gate: `npm run extract:lt` re-run, both specs dry-run to 0 files to change, `npm run rebuild` reports checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged).
- Spec: `plans/extracted-audit/edits/I052.json`.
- Suggested commit message: `Audit I052: player transition scripts, field reveal effect, escort path tracker`

Please commit when you're ready.
