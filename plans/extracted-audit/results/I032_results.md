# I032 results

Files: `actors/player/slope_ramp_physics.asm` (Bank 02), `functions/StopPlayerOnDeathAssign.asm` (Bank 00), `thinkers/sine_hdma_slow_wave.asm` (Bank 00).
Spec: [edits/I032.json](../edits/I032.json). New proposals: [renames/I032_renames.md](../renames/I032_renames.md). New questions: [questions/I032_questions.md](../questions/I032_questions.md).

Conventions (unchanged): verdicts **P/M/F/NA**; dispositions **FIXED / PROPOSED / DEFERRED-EVIDENCE / NOFIX**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 comment density, Q2 value, Q3 accuracy, Q4 mnemonic/address accuracy, Q5 mnemonic opportunity, Q6 part naming, Q7 evidence quality.

### File 1: actors/player/slope_ramp_physics.asm (Bank 02)

Evidence: E1 (the whole file read end to end; `tile_collision` `MapCellDown/Up/Right/Left`, `ReadCollisionNibble` and `TileProbeMain` read to confirm that they step by rows (+-$10) or columns (+-1) from the index in `$00` and return the new index in X without writing `$00`), E2 (`math_lookup_tables` for the curve tables and `system_core` for the pointer and `maxSpeed` setup; `player_move_controller` for the `$3000` joypad gate, the `TRB $1000` clears and the speed x 4 conversion; `player_move_ramps` / `player_move_diag` for the `TSB $1000` writers; `player_character`, `item_use_system` for the `$1000` readers; `camera_scroll_controller`, `actor_execution`, `dark_space` for `playerXPos` / `playerYPos`; `player_move_south` / `player_move_ns` for `slopeFracAccum`; `cop_handlers_sprite` for the `$08` wait counter), E3 `docs/wram-memory-map.md` (the `$1000` row is consistent; the "ascending/descending" curve pointer description is not).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Good headers, but the shared model (what the companion edits, the `$1000` latch, the curves) was incomplete and many comments carried wrong directions | FIXED (block note rewritten with frame flow, tile types, curves, latch, transition tiles, stopped probe, deceleration and quirk sections; 16 part notes, 37 comments: 8 new, 29 updated) |
| Q2 | M | A reader could not tell what the actor changes or what makes the latch set or clear | FIXED |
| Q3 | **F** | (a) **Cell directions were wrong.** `MapCellDown` = +1 map row (`+$10`), `MapCellUp` = -1 row, `MapCellRight` = +1 column; none writes `$00`. The transition-tile test reads the cell BELOW and then the cell ABOVE the probe tile (old text: "right" and "left"). The stopped probe visits, in order, the probe cell, the cell to the RIGHT, the cell BELOW and the cell below-right (old text and header: "current, down, right, down-right" with the comments for probes 2 and 3 swapped). (b) **`SlopeFlatDecelerate` does not decelerate both axes**: EW first and then `RTL`; NS is only handled when EW speed is already zero, and the `$1000` latch is only cleared on that same condition (header: "First decelerates EW ... Then checks NS"). (c) **`ClampSpeeds` clamps NS only when EW speed is zero** (it returns after the EW check); the header says "for each axis". (d) **`ReadDecelerationStepNS` is an identical copy that shares `decelStepCounter`** (comment: "separate counter increment"). (e) **`DecelerateNS` stop resets `slopeStepCounter`**, where `DecelerateEW` resets `decelStepCounter` (probable copy slip, OQ). (f) **After the first deceleration step the braking test is reached whether or not the step was zero**; the comment said "Decel step was zero". (g) **Curve tables are ROM, not WRAM**, both slope pointers share one table (`math_lookup_tables` start) and the deceleration pointer is +`$20`; default slope curve +1 every fourth step, default deceleration curve +1 at steps 7 and 15; `slopeStepCounter` is cleared every frame of the stopped probe and `decelStepCounter` advances on every read. (h) **`$1000` latch**: set by the ramp walkers and by `loc_02B5D8`, cleared by `player_move_controller` whenever an axis speed is nonzero and by `SlopeFlatDecelerate`; while set the controller discards joypad velocity, both decelerations return at once, Aura Barrier is blocked and the L/R block check is skipped. (i) **Dispatch**: the table holds the handler addresses; the `DEC` before `PHA; RTS` makes the return land on them (header: "address - 1 stored"). (j) **Probe points differ**: moving uses (actor X, actor Y - 8), stopped uses `playerXPos` / `playerYPos` = (actor X - 8, actor Y - $10) from `camera_scroll_controller` ("not actor local coords" and "8px above base" were unexplained). (k) **Gate**: `BIT #$00C0` tests either `$0080` or `$0040` (not both), and a positive `iframeCounter` is hit-stun; "freeze $0080 + orb $0040" was misleading. (l) "Descending ramp" wording removed: the handlers push toward a direction; the art was not checked. (m) `SlopeFlatExit` has no `RTL`: it falls into `SlopeFlatDecelerate` | FIXED (all of the above in the notes and comments) |
| Q4 | M | Direction words and probe order in many comments were wrong | FIXED (comments) |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | `loc_02B5D8` (shared by four routines, placed inside `ApplySlopeCurvePosEW`), `loc_02B54A`, `loc_02B6CD`, `loc_02B76C` are named by address although each is a branch target of several callers; `ReadDecelerationStepNS` duplicates `ReadDecelerationStep` | PROPOSED (R-I032-1, R-I032-2) |
| Q7 | M | E1 + E2 for direction semantics, curve data, latch writers and readers; the on-screen effect of slopes, the quirks (e), (c) and (j) and the transition-tile intent are static conclusions | DEFERRED-EVIDENCE (OQ-I032-1 to OQ-I032-4) |

### File 2: functions/StopPlayerOnDeathAssign.asm (Bank 00)

Evidence: E1 (the six stores; `CheckPlayerDeath` in `combat_collision`; `GlobalInputHandler` game-over guard; `cop_handlers_sprite` for the `$08` wait counter), E2 (searched `BIT/AND/ORA/TSB/TRB/CMP #$0200` in `actors/player` and `system`: besides this routine the only actor-`$10` writer found is the Psycho Slider code in `player_character`; no reader found), E3 `docs/wram-memory-map.md` line 170.

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Three-line header, no comments | FIXED (block note, 1 part note, 7 comments) |
| Q2 | M | The header hid the caller's setup and the two different `$0200` bits | FIXED |
| Q3 | **F** | (a) **Order**: `CheckPlayerDeath` sets playerFlags `$0200` and installs `GameOverSequence` BEFORE calling this routine; the old header implied this routine "ensures the player stops before `GameOverSequence` takes over". (b) **`STA $0008,Y`** zeroes the wait counter `$08`, not an "actor frame counter": the runner decrements it before running a script, so a pending hold time no longer delays `GameOverSequence`. (c) **The `$0200` it sets is a bit of the actor's own `$10`**, a different flag from playerFlags `$0200`; "freeze movement" is unverified because no reader of the actor bit was found. (d) `docs/wram-memory-map.md` lists `$0200 deathFlag` as a WRAM address "set by StopPlayerOnDeathAssign"; no such address is written | FIXED (notes and comments; the doc entry is logged below) |
| Q4 | P | Mnemonics and operands are as annotated | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | `Assign` in the name refers to the entry-point assignment in the caller; the routine only stops the player | PROPOSED (R-I032-3) |
| Q7 | M | E1 + E2; the missing reader of the actor bit is a negative search result | DEFERRED-EVIDENCE (OQ-I032-5) |

### File 3: thinkers/sine_hdma_slow_wave.asm (Bank 00)

Evidence: E1 (`InitSineHdma`, `TickSineHdma`, `BindSineHdma`, `BuildSineHdmaTable`, `BranchOnFlagByte`; `hdma_channel_config`; `scene_lifecycle` for event flag `$FF`), E2 (`scene_thinkers` spawn lists via the scratch parser: scene `$32` and scenes `$E9` / `$EA`; `dao_sine_hdma_slow` exists as a separate Dao copy; `docs/code/bank08-native-dao-pyramid-actors.md` for "mansion" = scene `$E9`; `fr32_*` actors for Freejia = scene `$32`), E3 `docs/code/bank0C-scene-spawn-tables-comet.md`.

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Two-line header, no comments | FIXED (block note, 2 part notes, 8 comments) |
| Q2 | M | The operands were misread, so the header misled | FIXED |
| Q3 | **F** | (a) **`$7F0008,X = 8` is the amplitude**, not "8 steps". (b) **`#$8800` is the WRAM table base (`$7E8800`) and `#40` the wave period (64 scanlines per HDMA entry, four tables of 4 repeat entries)**, not "channel `$8800`, 40-byte table". (c) **`TickSineHdma ( #01, #02 )`**: delay 1 = phase advances every second call; `#02` is the byte offset into the camera scroll words, not an "amplitude". (d) **`BindSineHdma ( ..., #0D )`**: `hdma_channel_config` entry `#0D` = BG1HOFS (`$210D`), so the effect is a horizontal ripple of BG1, not a "vertical sine-wave distortion". (e) **Scenes**: `$32` (Freejia) and `$E9` / `$EA` (the mansion), not "Dao and ending-comet scene groups" (Dao has `dao_sine_hdma_slow`). (f) **Flow**: it waits on event flag `$FF` (cleared at the start of the scene transition, set again when setup finishes): while clear every frame jumps back to the init label (amplitude, tables, phase 0), once set it ticks and binds every frame. (g) `code_00BE1A` is the init label | FIXED |
| Q4 | M | The operand roles were mis-assigned in the header | FIXED |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | `code_00BE1A` is a loop-back target named by address | PROPOSED (R-I031-3) |
| Q7 | M | E1 + E2; the on-screen result and the meaning of the `cameraTargetX/Y + 2` operand were not traced | DEFERRED-EVIDENCE (OQ-I032-6) |

### Shared gate (I032)

`npm run merge -- edits/I032.json --dry-run` first warned once ("comment {177265}: text matches a transforms.json pattern (RTS...)"); the comment was reworded ("the return below lands on it") and the dry run was clean. Merged totals: 3 block notes, 19 part notes (12 new, 7 updated), 52 comments (23 new, 29 updated). A second dry run after `npm run extract:lt` reports 0 files to change. `npm run rebuild` (after I031 and I032): success, `artifacts/crc.json` = checksum 223006080, crc 2083230829, totalSize 3062204.

Docs that repeat the old claims (not edited, `docs/` is outside the allowed folder): `docs/wram-memory-map.md` line 170 (`$0200 deathFlag`) and line 286 (`slopeCurvePtrs` "ascending/descending": A is east-west, B is north-south), `docs/code/bank0C-scene-spawn-tables-comet.md` line 440 (`sine_hdma_slow_wave`: "Slow water wave ... (Gold Ship, Babel Tower)"; it is scenes `$32` and `$E9` / `$EA`) and `docs/code/README.md` line 204 ("18 thinkers"; 2 spawn entries). `docs/code/bank02/slope-ramp-physics.md` was not read and likely repeats the MapCell direction and curve claims.

Suggested commit message: `audit(I032): correct slope_ramp_physics cell directions, probe order, deceleration/clamp flow, curve tables and $1000 latch; document StopPlayerOnDeathAssign ordering and the two $0200 bits; fix sine_hdma_slow_wave operand roles, BG1HOFS ripple and scene list`

Please commit when you're ready.
