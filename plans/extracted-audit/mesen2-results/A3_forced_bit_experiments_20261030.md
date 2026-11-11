# A3: forced-bit experiments on actor Flags10 (Campaign A, step A3)

ROM: O (original)

| Tag | File | Size | SHA-1 | CRC-32 | Mode source |
|-----|------|-----:|-------|--------|-------------|
| O | `rebuilt/Illusion of Gaia.smc` | 2,097,152 | `38de0c84dd2bc3bdfc0a3d7ab0220c79b70887c3` | `1c3848c0` | vanilla ROM |

State: `rebuilt/states/orig_S01r_south-cape-ready.mss` (South Cape, Will, scene `$01`). Experiments X3, X4, X4c additionally write `$0642 = $3F` (sceneNext = Diamond Mine) at frame 2 and `$0AA2 = $0AA3 = $77` (all abilities) right after the load; no new state file was saved.

## Static prelude

- Method: every experiment is a pair of atomic `run_script` runs from the same state, one **forced** and one **control** that leaves the bit alone. Inputs come from a seeded bot until the timeline starts, so the two runs are identical up to the first forced write (checked: the first samples of every pair match). A difference after that point is the effect of the write.
- All bits are written with Lua `kit.w16` into the actor slot (`$1000-$1FBF`), never into low direct page.
- Slot layout is `$30` per slot (see A1). Player slot `$1000`; the South Cape NPC used in X2 is slot `$12D0` (a bird, `$10 = $5802`); the mine enemy in X4 is found at run time as the slot with entry word `$B10A` and bank `$8A`.
- Expected effects before the run (from `extracted/`): `$2000` on the player: `PlayerIdleEntry+32` returns at once, `SortActorsByDepth+82` skips the sprite; `$2000` on an NPC: `RunActors_*` take the script path (no standard movement) and the sprite is skipped; `$0008` cleared: `ApplyMovement` instead of `ApplyMovementWithCollision`; `$0200` on the player: skipped by `$76E0` in `CombatCollision_InnerLoop`.

## Script

`harness/scenario_a3_forced_bits.py` generates the Lua; the exact `code` of every run is saved in `raw/A3_scripts_20261030.lua.txt`. Library `kit/lib/a_census.lua` (`acen.run{frames, at = {[frame] = fn}, timeline, sample, ...}`). Raw results, one JSON per run (all samples, the Lua, ROM info, screenshot record): `raw/A3_X*_20261030.json`. Screenshots: `raw/screenshots/A3_X*_*.png`.

| Experiment | Frames | Forced write | Inputs |
|------------|-------:|--------------|--------|
| X1 `player_2000` | 70 | frame 10: `$1010 \|= $2000` | from frame 40: Left 30 frames, then idle |
| X1 `set_then_clear` | 90 | frame 10: `$1010 \|= $2000`; frame 40: bit cleared | from frame 20: Left 30, idle 40 |
| X2 `npc_2000` | 60 | frame 4: teleport Will to (136, 340); frame 12: `$12D0 + $10 \|= $2000` | none (bot) |
| X3 `player_0008` | 546 | frame 346: `$1010 &= $FFF7` | from frame 346: Left 50, Down 50, Up 60, Right 40 |
| X4 `player_0200` | 466 | frames 346-465: `$1010 \|= $0200` every frame; enemy teleported next to Will at frames 345, 385, 425 | idle 120 |
| X4c `player_0200_cleared_at_366` | 466 | `$0200` forced 346-365, cleared at 366 (before the first contact) | same |

## Positive control

- Each forced run has a control run with the same inputs (table above, "control" rows in the raw files). The controls show the unforced behaviour: X1 Will walks and is drawn; X2 the bird flies to x = 234; X3 Will stops at a wall (x = 168, `$10` bit 2 set) and later leaves by the south exit (scene `$3F` -> `$3E`); X4 the enemy touches Will and HP falls 8 -> 1 (frame 372) -> 0 (frame 436, `playerFlags $0200`).
- `control36Writes` is 69 / 69 / 89 / 59 / 59 / 365 / 376 / 296 / 296 / 296 (X1 control, forced, set_then_clear; X2 control, forced; X3 control, forced; X4 control, forced; X4c), one per frame, in every run: the callback harness was alive.
- Determinism: the first samples of each pair are identical (for example X1, frames 1-9: same `x`, `$10`, entry word).

## Coverage

ROM O only; scenes `$01` (X1, X2) and `$3F` (X3, X4, X4c); Will only; one NPC (the bird), one enemy type; single forced bit per run. Not run (and why): OQ-54 (dialogue-COP bit `$0800`: needs a dialogue under a breakpoint, not done), OQ-I023-6 (`ClimbX` glide: no glide reached), OQ-I025-6 (`$0700`: `InteractionDamage_NPCChat` never ran), OQ-I026-5 (`ToggleActorVisibilityFlag`: no `sp5B` room), OQ-I033-6 (`$0E`): one attempt (X5, `$0E` on the bird placed on top of Will) was discarded because both sprites were hidden behind the building layer in the chosen spot; no data kept.

## Observations

1. X1, Will with `$2000` set (frame 10 on): the sprite is gone (screenshot `A3_X1_player_2000_forced_447.png` against `..._control_447.png`), but Will still walks: x = 604 at frame 70 in both runs, the same 2 px per frame. The entry word stays `$C3CA` (`PlayerIdleEntry`, which returns at once) while the control switches to `$C59B` (walk pose). `playerFlags` and HP unchanged.
2. X1 `set_then_clear`: the bit cleared at frame 40: the entry word goes back to `$C59B` the next frame and the sprite is drawn again (screenshot `A3_X1_player_2000_set_then_clear_467.png`). No other routine clears it on its own: it stayed on from frame 10 to 40.
3. X2, NPC `$2000` set at frame 12: the control bird flies from x = 136 to x = 234 (frame 60) and is visible; the forced bird stays at (138, 306) from frame 13 to 60 and is not drawn (screenshots `A3_X2_npc_2000_*_437.png`). Its wait counter (`wt`) and entry word (`$809D` at frame 60) are the same as in the control: the script still runs; only the standard movement and the sprite are lost.
4. X3, Will with `$0008` cleared at frame 346: control stops at x = 168 (`$10` goes `$8508 -> $850C`, bit 2 = blocked) and leaves through the south exit at frame 440 (scene `$3E`, x = 88, y = 80). Forced: Will continues left to x = 84 through the wall (frames 350-400), `$10` bit 2 stays set the whole time (`$8504`), walks down to y = 1028 and up again, and never reaches the exit (still in scene `$3F` at frame 545, x = 162, y = 916).
5. X4, `$0200` forced: an enemy standing on Will (enemy x = 264 y = 400, Will x = 266 y = 406 at frame 464) for 120 frames: HP 8 at the end. Control: HP 1 at frame 372, 0 at frame 436 (`playerFlags $0200`, Will `$10` = `$87C8`). X4c (cleared at frame 366): HP 0 at the end: damage resumes once the bit is cleared.
6. A first version of X4c that did not clear the bit left it set for the rest of the run: nothing in the engine cleared it in at least 100 frames (that run was not saved; X4's rewrites make it not testable from the saved data).

## Verdicts

| ID | Verdict | Grade | Shipped note (file:line) | Action |
|----|---------|-------|--------------------------|--------|
| OQ-20 | `$10` bit 3 = collision-aware movement selector (obs. 4). Not "grounded", not "player-hit". | VERIFIED-RUNTIME | `docs/code/bank03/actor-thinker-runtime.md:185`, `docs/code/bank00/data-tables-memory.md:215` (wrong); `extracted/system/engine/actor_execution.asm:198` (hedge) | rewrite both docs lines; replace the hedge with the verified meaning |
| OQ-I026-6 | `$2000` = script-driven / no standard movement and not drawn: on an NPC the bit freezes movement and hides it (obs. 3); on Will it hides him and makes `PlayerIdleEntry` return at once (obs. 1-2). Both readers (`RunActors_Normal+45`, `SortActorsByDepth+82`) confirmed. The "flip every tick" part (`ToggleActorVisibilityFlag`) was not run. | VERIFIED-RUNTIME | `sprite_composition.asm`, `actor_execution.asm`, old `item_use` comments | none |
| OQ-I044-2 | Not in A3 (A1 `sc_npc_talk` pair). | see A1 | | |
| OQ-I025-2 | Effect of the bit on the player shown (obs. 1-2); the writer is still unseen. | INCONCLUSIVE (writer) | `player_character.asm` | needs `DarkSpaceEnterWarp` run |
| OQ-I053-3 | The bit does not clear itself in 30 frames (obs. 2); who clears it after `DarkSpaceEnterWarp` was not seen. | INCONCLUSIVE | - | Dark Space run |
| OQ-I023-3 / OQ-I027-2 / OQ-I030-2 / OQ-I032-5 / OQ-I036-4 | `$0200` confirmation (obs. 5): HP 8 -> 8 forced, 8 -> 1 -> 0 control, HP 0 when cleared at 366. | VERIFIED-RUNTIME | see the A2 file | see A2 |
| OQ-54 | Not run. | INCONCLUSIVE | `PrintDialogString` save / clear / restore of `$0800` ran 12 times (A2) | needs a forced run |
| OQ-I023-6, OQ-I025-6, OQ-I026-5, OQ-I033-6 | Not run (reasons in Coverage). | INCONCLUSIVE | - | later plans |

## Tool issues

See `tool-issues.md` T-31 to T-37.

## New questions

1. X1: with `$2000` the player moves but `PlayerIdleEntry` returns at once. Which routine moves Will in that state, and does the walk animation advance? (`PlayerMoveController` ran; the entry word never changed.)
2. X3: with `$0008` cleared the contact flag `$0004` stays set while Will moves freely. Is `$0004` then set by `ApplyMovement` (simple path) for every step, and is it harmless?
3. X2: the NPC's script keeps running while it cannot move. Do cutscene scripts that set `$2000` on NPCs rely on this (script-driven motion via `$14`/`$16` writes), and which `$12` bit 3 requests ordinary movement (`RunActors_CopScriptPostTick+9`)?
