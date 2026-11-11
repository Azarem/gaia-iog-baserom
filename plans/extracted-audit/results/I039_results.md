# I039 results

Files: `system/player/player_move_ns.asm` (Bank 02), `functions/SpawnDebrisBurst.asm` (Bank 00), `functions/InitPlayerScriptVariant.asm` (Bank 00).
Spec: [edits/I039.json](../edits/I039.json). New proposals: [renames/I039_renames.md](../renames/I039_renames.md). New questions: [questions/I039_questions.md](../questions/I039_questions.md).

Conventions as in [I029_results.md](I029_results.md).

### File 1: system/player/player_move_ns.asm (Bank 02)

Evidence: E1 (all 451 lines read with `extract:lt` addresses; every branch, the 8-bit / 16-bit mode at each load, the slope row-offset maths and the `slopeFracAccum` filter traced by hand, including a worked sequence for `$24 = -8`), E2 (`tile_collision` probes, `MapCell*` (all read `$00`, none writes it), `CheckSubTileAlign*`, `ReadCollisionNibble`, `player_move_south` `FineAdjustX*`, `player_move_main` `AutoAlignEW` / `ComputeYSnapOffset` / `PlayerMovementTick` (`STZ $AA` clears `$AB` too), `player_move_diag` `DispatchDiagDownLeft` (sets `$AB` bit 1) and `DiagPush*`, `player_character` `LadderClimbSouth`, `rg` over `extracted/` for every `$AA` / `$AB` writer and reader), E3 (`docs/code/bank02/player-movement.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Every line had a comment, but the block header, most routine headers and several inline notes disagreed with the code or with each other | FIXED (block note rewritten: conventions, dispatch order, snapping, slopes, wall handlers; 11 part notes replaced; 74 comment entries, 21 new and 53 replaced) |
| Q2 | M | The reader could not tell what carry from `CheckSubTileAlign*` means, which case runs the probe chains, or what the wall slides do to X | FIXED |
| Q3 | **F** | (a) **Aligned / straddling were inverted in the header and the handler notes.** `CheckSubTileAlignX` / `Y` return carry CLEAR for a probe on a 16-px line. In `DispatchNorthMove` the `MapCellRight` secondary probe runs when X straddles two columns (the header said "sub-tile aligned"). In `SouthWallHandler` / `NorthWallHandler` the gap chain runs when Y straddles and the future corner is `$06` / `$09`; Y flush (or another type) takes the snap path (the header said the opposite). (b) **`FineAdjustXWest` moves X EAST and `FineAdjustXEast` moves X WEST** ([I033](I033_results.md)), so `SouthWallHandler` slides the player east and `NorthWallHandler` west; the header said west and east. (c) **`$AB` bit 1 is not a "wall interaction flag from a prior collision pass"**: `DispatchDiagDownLeft` sets it in every tick where the west horizontal phase ran, and the `STZ $AA` at the start of `PlayerMovementTick` clears it. `SouthWallNudge` therefore means: moving west with X flush cancels the north step and keeps the X move. (d) **Slope `d` threshold**: `d = 16 - n` with `n` the row offset of the top probe in the tile; "d < 8" is the LOWER half of the tile (n >= 9), not the "upper half" the header and comments said; the flag `$09AF` bit `$10` is set for Y flush, same slope below, or `d >= 8`. (e) **`SnapYNorthCollision`** floors the stepped Y and adds one row: in the normal case it backs the player off the step (between Y' and Y), "snaps upward" was only half the story; the east / west wall-slide callers run it with `$24 = 0` and push the player SOUTH by 1..16 px. (f) **`NorthSlopeLeft` filter**: when `|accum + $24| < 16` the full `$24` is applied and the sum kept; otherwise `$24` is REPLACED by `-(|sum| >> 4)`; nothing subtracts the distance moved, so `$24 = -8` alternates -8 and -1 sub-pixels (about 56 percent of the speed). (g) **`NorthProbeRedirect`'s `MapCellDown` + `ReadCollisionNibble` are dead**: `MapCellDown` returns only X, the nibble result is unused, and `MapCellLeft` at the BRA target reads `$00` again. (h) Inline comments saying "below" for the `MapCellRight` neighbour (five lines), "ceiling" for the Y snap, "walkable" for a cell that must be exactly type 0, and `ComputeYSnapOffset` "0 when flush" (it returns 16; its own header in `player_move_main` is wrong, see R-I039-4). (i) The slope notes called `$03` / `$0C` "right-descending / left-descending" in the header and "ascending" in the inline text; the direction is undecoded | FIXED (all as note text) |
| Q4 | M | Operands correct; the register / probe descriptions were wrong as above | FIXED |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | `NorthProbeRedirect` hides that it only re-enters the gap chain; `NorthSlopeRight` / `NorthSlopeLeft` assume a direction | PROPOSED (R-I039-2, R-I039-3) |
| Q7 | M | E1 + E2 for control flow and arithmetic; the effect of the `slopeFracAccum` filter, the slide directions, the `$AB` bit 1 gate and the undecoded `$06` / `$09` types have no runtime check | DEFERRED-EVIDENCE (OQ-I039-1 to OQ-I039-5, OQ-I029-5, OQ-I033-3) |

### File 2: functions/SpawnDebrisBurst.asm (Bank 00)

Evidence: E1 (all 18 script lines), E2 (`cop_handlers_script_control` `LoopStart` / `LoopEnd` (`LoopEnd` yields while the counter is nonzero), `cop_handlers_spawn` `SpawnAfterFlags` / `SpawnAfterAbsFlags`, `actor_pool` `AllocateActorAfter` -> `CopyActorState`, `actor_execution` `DEC $08` wait semantics, `rg` for the four spawn sites), E3 (`docs/code/bank00/functions-camera-motion.md:128`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A three-line header and a nonsensical entry comment ("particle burst actor at range boundary") | FIXED (block note, 2 part notes, 14 comment entries) |
| Q2 | M | The header gave no timing, flags or spawn sites | FIXED |
| Q3 | **F** | (a) Spawn sites: four, not two (also `it19_breakable_wall` through `SpawnAfterAbsFlags` at (152, 96) and `dm40_trapped_slave` with flags `$3000`). (b) Timing: `WaitByte(3)` waits 4 frames and `LoopEnd` yields once more per pass, so one particle every 5 frames (about 40 frames); the header did not mention the wait. (c) The offsets are -16 .. +15 px (`AND #$1F` minus `$10`), independent in X and Y; the doc says +-$10 .. +-$30. (d) Every particle plays sound `#$0F` on both channels (eight sounds in total). (e) The docs describe an `LDX #8` / `JSR random` / `DEX` loop; the code is a COP `LoopStart` / `LoopEnd` script | FIXED |
| Q4 | M | Operands correct | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | Names match the behaviour | NOFIX |
| Q7 | M | E1 + E2; the frame timing and the meaning of the `$10` flags `$0302` (bit `$0200` appears in `combat_collision` skip masks, [OQ-I030-2](../questions/I030_questions.md)) are static readings | DEFERRED-EVIDENCE (OQ-I039-6) |

### File 3: functions/InitPlayerScriptVariant.asm (Bank 00)

Evidence: E1 (all 18 instructions plus the 4-entry table), E2 (`rg` over `extracted/`: 17 `JSL` call sites in 14 actor files, `player_character` `IdleStand*` handlers, `GetPlayerFacingDirection` order, `sEA_solid_arm` / `awB1_wall_walker` use of `$7F002C` / `$7F002E` as movement scratch), E3 (`docs/code/bank00/data-tables-memory.md:105`, `docs/code/bank00/README.md:197`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A two-line header and no inline comments | FIXED (block note, 2 part notes, 11 comment entries) |
| Q2 | M | Input register, index meaning, bank byte and cleared fields were undocumented | FIXED |
| Q3 | **F** | (a) The "frame counter" cleared is the wait counter `$0008`. (b) The caller list was a sample: 14 actor files (also `st68_lily`, `dc31_kara`, `it15_*`, `av74_kara`, `na4B_lily`, `sc06_*`, `sc02_seth`). (c) The docs say the table is selected "based on body form and scene context"; only A is used (the `IdleStand*` handlers themselves test the Shadow flag byte `#00`). (d) A has no range check | FIXED |
| Q4 | M | Operands correct | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | The name says "script variant" but the routine selects an idle facing | PROPOSED (R-I039-1) |
| Q7 | M | E1 + E2; no runtime check | NOFIX |

### Shared gate (I039)

`npm run merge -- edits/I039.json --dry-run` was clean. Merge applied: 3 block notes, 11 part notes replaced and 4 added, 99 comment entries (74 in `player_move_ns`, 14 in `SpawnDebrisBurst`, 11 in `InitPlayerScriptVariant`). The gate was run once after the I040 merge (see [I040_results.md](I040_results.md)): `npm run extract:lt` then `npm run rebuild`, `artifacts/crc.json` = checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged). With comments and tags stripped the code of all three files is identical to HEAD; the only structural difference is the `---` separator line that the extractor writes in front of newly added part notes in the two small files.

Suggested commit message: `audit(I039): player_move_ns probe-alignment cases, slide directions and slope filter, SpawnDebrisBurst timing and sites, InitPlayerScriptVariant callers`

Please commit when you're ready.
