# B addendum: plan to investigate everything B1 to B4 left open

Date: 2026-10-30. Written after the B4 apply (`MS01_apply.md`). Sources read: `B1_20261030.md`, `B2_20261030.md`, `B2_special_tiles_20261029.md`, `B3_20261030.md`, `B4_20261030.md`, `closures.md`, `states-index.md`. This file only plans; nothing in it has been run. Ids `BA-nn` are new and local to this addendum; Z1 assigns the real question ids.

## 0. Starting state (checked today)

| Item | State |
|------|-------|
| B1 notes spec (`specs/B1_notes.json`) | applied (old sentences gone from `extracted/`; committed) |
| B3 notes spec (`specs/B3_notes.json`) | applied (same check) |
| B4 notes spec (`specs/B4_notes.json`) | applied today, gate unchanged (`MS01_apply.md`) |
| `docs/wram-memory-map.md` §4.10 collision table (B1 CONTRADICTED rows) | already carries the corrected `$06` / `$09` / `$0F` rows |
| B2 (`B2_20261030.md`) | no notes spec (no shipped note wrong); 7 INCONCLUSIVE ids, of which B3 closed OQ-16, OQ-I029-5, OQ-I033-4, OQ-24, OQ-25 and OQ-I038-2 |
| `closures.md` | B2 special-tile rows and B4 rows appended; B1 to B3 verdicts are not in it yet (Z1 task) |
| ROM for every step below | O (vanilla) unless the item says R |

Items that **cannot be decided by running the game** (intent, "why"): they are closed as undecidable, not scheduled. The shipped notes already say so or say nothing.

| Id | What | Why not schedulable |
|----|------|---------------------|
| BA-X1 | Why `SlopePhysicsEntry` samples two different world points (moving probe at (X, Y-8), stopped latch at (X-8, Y-16)) | intent (B3) |
| BA-X2 | Why OQ-I032-3 geometry and the I038-1 bias exist | intent (B2, B3) |
| BA-X3 | Why the west and east player files use opposite north / south words for `$06` / `$09` | naming (B1) |
| BA-X4 | OQ-I038-5 (why; no observable difference in detection) | B2 found no observable effect |
| BA-X5 | OQ-I033-2 value reason (`$22` = 28) | intent |

## 1. Open items (every one with the missing piece)

Priority: **P1** = a shipped note says "unverified" or a doc depends on it; **P2** = completes a measured claim; **P3** = curiosity or rare path. "Method" refers to existing harness/kits (`b2_kit`, `b3_kit`, `b4_kit`, `gaia_kit`) and the plan's §6 techniques.

### 1.1 Collision layer and scene data (from B1)

| Id | Missing piece | From | Method | State | Pri |
|----|---------------|------|--------|-------|-----|
| BA-01 | What rewrites the collision layer after `RebuildCollisionLayer` in scenes `$55` (20 cells, table `$0E`, layer `$00`), `$6B` (4, table `$06`/`$09`, layer `$0F`), `$78` (36, table `$0F`, layer `$00`), `$D6` (24, table `$0F`, layer `$00`), `$D7` (2,208, table `$00`, layer `$0F`) | B1 Q1 | write watch on `$7F:C000-$DFFF` from scene load, record PC and frame; one load per scene | scene-spawn states (quick warp), new | P2 |
| BA-02 | Is the layer-1 overlay exactly "nonzero layer-1 flags win" in the dual-layer scenes (`$0B $30 $5F $60 $61 $62 $64 $65 $67`; mismatch counts 6 to 2,612; `$30` has none)? | B1 Q5 | rebuild reference: compute `layer0 OR-merge layer1` from the dumped data and compare cell by cell with the live layer | same scenes | P2 |
| BA-03 | The active collision layer base of the dual-layer scene `$62`: which layer does the player's movement read (the base dump is all `$0E`)? **Prerequisite of BA-20** | B4 Q3 | read `$06EF`, `$0694-$069C` and the probe base used by `TileProbeMain` (hook the probe, read the index and bank) in `$62`; compare with a collision dump at that base | `S14e` (`$62`) | P1 |
| BA-04 | Does the `AND #$0100` column wrap of `CameraFullRefresh` show on screen in scenes whose bounds are not powers of two (83 of 223 scenes; Itory `$15` 1280 wide)? | B1 Q2 | scroll to the right edge in `S13`, screenshot, compare the tilemap word column against the map | `S13` | P3 |
| BA-05 | Why scene `$FE` (world map) never writes `$36` while `$FA` and `$FC` do; needed for any positive control there | B1 Q4 | `set_breakpoints` write on `$36` and exec on NMI during `$FE`; find which routine runs instead | new `S08`-style state | P3 |
| BA-06 | Quadrant bit order of `$05` / `$0A` / `$03` / `$0C` is VERIFIED-STATIC only | B1 verdict row 3 | covered by BA-10 (quadrant sweep) | `S13` | P2 |

### 1.2 Player hit box and slope handlers (B1, B2, B2 special tiles, B3)

| Id | Missing piece | From | Method | State | Pri |
|----|---------------|------|--------|-------|-----|
| BA-10 | Which quadrants of a `$05` / `$0A` / `$0E` / `$04` / `$01` / `$08` cell are solid for the player's hit box (B2 sweep covered `$0F`, `$06`, `$09`, `$05`, `$0A` for one east approach only) | B1 Q3, B2 special tiles | the `scenario_b2_special_tiles.py` single-tile paint, 1 px approaches from all four sides, at 4 sub-cell phases | `S01r` | P2 |
| BA-11 | `$05` on row +1 changes y by -2 and `$0A` on row +1 changes x by -6, y by +16 although the player stands on row 0 (hit box lower edge overlaps row +1?) | B2 special Q1 | the same paint at Y offsets 160..191 step 2 | `S01r` | P2 |
| BA-12 | Which geometry reaches the `WestRampUp` corner snap? (1 to 5 stair cells with a wall two columns east, X 350-360; 0 of 96 single-cell and 46 of 50 stair cases reached it). Which real maps have it? | B3 Q6, B2 Q3 | static search of the 223 layers for `$05` stacks with a solid column two cells east (census data, `raw/B1_census_O_*.json`), then run the first hit in play | `S13`, then the hit scene | P1 (the corner text in `player_move_ramps.asm` is partly "not observed") |
| BA-13 | Is the `$0A` corner snap's net +2 px per tick south intended, given the `$05` copy nets 0? | B3 Q4 | after BA-12, measure `$26` in the `$05` copy | as BA-12 | P2 |
| BA-14 | Can a player in the real game stand on a `$06` right-foot cell with probe-Y low nibble 15 and a south step crossing a row line (the X = 7 teleport of `FineAdjustXEast` at `$02` = 17)? | B2 Q1 | enumerate `$06` cells at the staircase from the layer data, place the player at each with Y phase 15, step south | `S01r` | P2 |
| BA-15 | What produces the first push of 8 px at `$02` = 8 in `WallSlidePushDown`, then 2 px afterwards (`$02` 8, 10, 12, 14)? | B2 Q4 | per-tick hook with `$02`, `$00`, `$26` columns on the wall-slide case (suite `flushpush`) | `S01r` | P2 |
| BA-16 | At Y = 191 the `$06` / `$09` mirrors differ (X = 7 versus a normal slide): are other `$02` values above 16 (up to `$1F`) reachable with the corner at a different Y phase? | B2 Q5 | Y-phase sweep 184..199 on the mirror pair | `S01r` | P3 |
| BA-17 | A lone `$05` east of the player makes a repeating east/west wobble (net x 384..386): is the east entry of the `$05` handler reachable without a `$0A` descent in real maps? | B2 Q2 | census data: `$05` cells with no `$0A` neighbour in the column; walk it | `S13` | P3 |
| BA-18 | `OQ-I039-5`: the `n = 8` boundary of the `$1000` flag (`d = 8`) was not sampled | B2 | one paint case at the boundary phase | `S01r` | P3 |
| BA-19 | Stopped-latch probe of `SlopePhysicsEntry`: after `MapCellDown` does the code store the new index in `$00` (`slope_ramp_physics.asm:38`) or leave the probe index (`:187`)? Also the page-carry case of `MapCellDown` (row stride added to the high byte) | B4 Q2 | stop on a `$06` cap with `$1000` set; the `i030` hooks 177283/177293/177312/177322 plus the stopped-path hooks; for the carry, a `$06` cell in the last row of a page (layer data gives one) | `S13` | P1 (the B4 sentence says "moving probe only") |

### 1.3 Speed, deceleration and COP collision (B3)

| Id | Missing piece | From | Method | State | Pri |
|----|---------------|------|--------|-------|-----|
| BA-30 | With EW = +5 and NS = +12 poked, `$09B4` goes 12 -> 0 at frame 3 (EW = NS = +12: frame 10; EW +5 / NS -12: frame 5) although `DecelerateNS` does not run: which routine writes it? | B3 Q2 | write watch on `$09B4` with PC for the three poke cases | `S13` | P2 |
| BA-31 | Who reads the published `$1014-$1017` after the between-phase publish (0 reads between `D015` and `B3A9` in 15 ticks; reads at `B2DA`, `EB07`, `95F4`, `9608` outside it)? | B3 Q1 | read watch on `$1014-$1017` with PC across several frames; classify the readers | `S13` | P3 |
| BA-32 | Do all real sprite hit box headers have Y offset -16 and live in bank `$7E`? (`MarkSolidHere` / `BranchIfSolidHere` agree only for -16; `MarkCollisionRect`'s absolute stride read needs DBR `$7E`) | B3 Q3 | static scan of the hit box header table plus the spawn records, then one runtime check on the odd ones | static first | P2 |
| BA-33 | The layer-aware bit of `BranchIfBehindWall` (OQ-24 half) | B3 | a dual-layer scene (`$62` after BA-03) with an actor that runs `BranchIfBehindWall`; or a forged script in a disposable state | `S14e` | P2 |
| BA-34 | What is at `$82:CB46` / `CB4F` (the iframe counter step; nearest name `MovingToNorth`+36) and what sets the counter back to a positive value on the next hit? | B3 Q5 | static read of those bytes plus a write watch on `iframeCounter` | `S10`-type combat state | P2 |

### 1.4 Ramps, glide, booster, MapCell (B4)

| Id | Missing piece | From | Method | State | Pri |
|----|---------------|------|--------|-------|-----|
| BA-20 | East and West glide triggers: length, frames and landing (scene `$62`, triggers at (32, 28) and (40, 28)); `$0E` of the East trigger, finish frame versus landing tile | B4 Q3, B4 verdict | after BA-03 use `b4_kit` (`gsweep` for the E/W direction) with the active layer known | `S14e` | P1 (the `stair-climb-system.md` section says "not run") |
| BA-21 | `SliderGlideTriggerNorthEntry` (scene `$72`): the nudge to X-8 and the hand-over to `SliderGlideTriggerNorth` | B4 | slide into the entry trigger, hook its three instructions and the North fire | new state `$72` | P2 |
| BA-22 | Glide triggers at (7, 30) South and (7, 39) North of scene `$B5` (types `$13` and `$15`, longer glides) and the third trigger columns | B4 | `gsweep` / `gnorth` with the new trigger coordinates | `S14g` | P2 |
| BA-23 | Exact lateral window edges of the glide triggers (`trigger - 7` and `trigger + $18`; B4 saw the edge cases stopped by the walls, not by the window) | B4 | the same sweep at dx -9..-5 and +22..+26, with the walls cleared in RAM so the slide is not held | `S14g` | P2 |
| BA-24 | A player 1-6 px short and 13-15 px short of a ramp coordinate (B4 measured only 7-12 px short): does stage 2 wait in every case, and is there a timeout | B4 audit finding 5 | place at the ramp X +/- n, hold; read `S2` hook counts for 300 frames | `S14f`, `S14` | P2 |
| BA-25 | Natural arrival speeds at the north/south ramps (B4 forced 6 and 8 with the slope latch cleared; only Itory east was natural) | B4 audit finding 6 | walk and run into `$21` north, `$A1` north/south from far enough to build speed; no pokes | `S14b`, `S14f` | P2 |
| BA-26 | What stops the player at the `$A1` `ramp_south` (424, 560): 5 of 16 forced approaches launch, 11 stand 7-12 px short; does natural play reach the coordinate | B4 Q5 | dump cells (suite `cells`) around the ramp; natural approach | `S14f` | P2 |
| BA-27 | Is the `$21` `ramp_south` (600, 336, type `$0B`) reachable in play (other flag state or layout) and from which side | B4 Q4 | dump the cells; try other approach rows; check scene-flag dependent layout | `S14b` | P3 |
| BA-28 | Booster scene `$41` (state `S14d` made, unused): does the 32 / 48 px behavior match; and which room name belongs to `$22` (the block note calls it "ir21") | B4 Q6 | `booster` suite on `S14d`; a name check against `artifacts/scenes.json` | `S14d`, `S14c` | P3 |
| BA-29 | Does any flat-ground walk path leave a nonzero speed word at the booster gate? (B4: only a slope opened it) | B4 Q7 | many short walks with start offsets through the 32-px box, hook `BoosterGate` | `S14c` | P3 |
| BA-35 | The climb poses: what animations `$21`, `$24`, `$19`, `$1E` look like and how many animation frames each has | B4 Q1 | `take_screenshot` on each climb frame; decode the animation table by reading the ROM (static) | `S14`, `S14f` | P3 |
| BA-36 | Ramp quirk `RampPlayerClimbEast` writes through `LDX $06` without checking that `SpawnAfter` succeeded (pool full) | `ramps.asm` quirks | fill the actor pool in a disposable state, then launch | `S14` | P3 |
| BA-37 | The contact skip for the player's `$10` bit `$0200` was measured with the bit forced on; the real write sites in the ramp climbs and the glide were not run with an enemy in contact | `ramps.asm` quirks | place an enemy at the arc path in `$85`; hook `CombatCollision_InnerLoop` during a launch | `S14` | P3 |

### 1.5 Pickup, aura and other B1 leftovers

| Id | Missing piece | From | Method | State | Pri |
|----|---------------|------|--------|-------|-----|
| BA-40 | Where does a dropped pickup land on a `$0E` row (`field_reveal_object.asm:167`)? Rows of `$0E` exist in 106 scenes (candidates `$0B`, `$0C`, `$0D`) | B1 OQ-I051-6 | drop a pickup (spawn the reveal object or kill an enemy) near a `$0E` row; hook the probe | `$0C` spawn state, new | P3 |
| BA-41 | Does the unbounded scan of the aura landing terminate when the room has no `$04` tile (213 of 223 scenes have none), and what happens | B1 OQ-I052-4 | run the aura in `S01r` (no `$04`) and in `$CC` (30 cells) | `S01r`, `$CC` state | P3 |
| BA-42 | Which routine reads the first row of the probe for OQ-I030-3 (which probe results reach the handlers) | B1 | B3's per-action table already lists routines per operand; check whether OQ-I030-3 is covered, else write watch on handler entries on `S13`, `S14`, `S01r` | `S13` | P3 |
| BA-43 | `displayModeFlags` `$09EC` bit 3 differs by one frame between O and R on a `B` press (relevant to the button remap) | B2 special Q2 | repeat the 90-frame run with 5 repeats per ROM, same input; record the first frame the bit changes | `S01r` and `R-plain_S01r` | P2 for M-steps |
| BA-44 | Which actor class calls `CheckActorOnSpecialTile` in South Cape | B2 special Q3 | exec watch on its entry with the slot and the actor's entry point | `S01r` | P3 |

## 2. Sessions

Every session follows the plan's HARD RULES (write only under `mesen2-results/` and `rebuilt/states/`, no real merge, no git writes, positive control `$36`, every case twice, verdict vocabulary VERIFIED-RUNTIME / CONTRADICTED / INCONCLUSIVE, H1 on every state before use, ROM SHA-1 in the first line). New states are named `S14h`.. or `S13b`.. (the plan reserves `S15`-`S19`).

| Session | Items | Order reason | Output |
|---------|-------|--------------|--------|
| **B5a** layer and dual-layer | BA-03, BA-33, BA-01, BA-02 | BA-03 unblocks BA-20 and BA-33 | `B5a_<date>.md` |
| **B5b** glide leftovers | BA-20, BA-21, BA-22, BA-23 | needs BA-03; `b4_kit` ready | `B5b_<date>.md`, notes spec for `slider_glide.asm` and `stair-climb-system.md` |
| **B5c** slope handlers | BA-19, BA-12, BA-13, BA-15, BA-16, BA-17, BA-14, BA-18 | all use `S01r` / `S13`; BA-19 narrows a B4 sentence | `B5c_<date>.md`, spec for `slope_ramp_physics.asm`, `player_move_ramps.asm`, `player_move_ns.asm` |
| **B5d** hit box | BA-10, BA-11, BA-06, BA-32 | BA-32 static first | `B5d_<date>.md` |
| **B5e** ramp leftovers | BA-24, BA-25, BA-26, BA-27, BA-28, BA-29, BA-35, BA-36, BA-37 | independent | `B5e_<date>.md`, spec for `ramps.asm`, `large_ramps.asm` |
| **B5f** speed / COP | BA-30, BA-31, BA-34, BA-42 | independent | `B5f_<date>.md` |
| **B5g** one-offs | BA-04, BA-05, BA-40, BA-41, BA-43, BA-44 | lowest value | `B5g_<date>.md` |
| **B5-apply** | notes in 3 below | after each session's spec | `MS<NN>_apply.md` |

### Session text skeleton (copy into each step prompt)

```
You are running one step of the Mesen2 investigation for Illusion of Gaia (US). Workspace: c:\Work\gaia-iog-baserom.
Read first: plans/extracted-audit/mesen2-investigation-plan.md (HARD RULES, section 6 techniques, states table),
mesen2-results/B_addendum_20261030.md (items of this session), mesen2-results/closures.md, tool-issues.md,
and the B-report named in the item's "From" column.
STEP <B5x>. Items: <BA-nn ...>. ROM: O unless an item says R. States: <list>.
Deliver: mesen2-results/<B5x>_<date>.md in the section-8.1 template: per item a table, a verdict row, new questions as text,
the shipped note affected (file:line), and a notes spec specs/<B5x>_notes.json (dry-run only).
```

## 3. Notes still to narrow (shipped text; no new runtime needed for the first three)

| Id | File:line | Today | Plan |
|----|-----------|-------|------|
| BA-N1 | `extracted/system/player/player_move_east.asm:34` | "Everything here is UNVERIFIED-RUNTIME (no emulator trace); the arithmetic is read from the code." | list the routines B2 and B3 traced (`FineAdjustXEast`, `WallSlidePushDown`, the `$06` / `$09` east pushes, the ramp east entries) and keep the line for the rest; needs a per-routine list from `B2_20261030.md` and the B3 per-action table |
| BA-N2 | `extracted/system/player/player_move_ns.asm:36` | same sentence | same, using the B2 I039 results and the B3 N/S table |
| BA-N3 | `extracted/system/player/player_move_main.asm:33` | same sentence | same (B3 per-action table) |
| BA-N4 | optional "measured" additions suggested by B1: `scene_script.asm:2041` ("first tile in bit 0" confirmed statically only), `slope_ramp_physics.asm:72` (the neighbour counts 220 of 335 and 238 of 311), `player_transition_handlers.asm:243` ("`$04` occurs in 10 rooms"), B2 `player_move_south.asm:544` ("X becomes 7 at `$02` = 17") | present | add only the measured fact, one `merge` spec |
## 4. Counts

- 39 open items (BA-01 to BA-06, BA-10 to BA-37 without gaps, BA-40 to BA-44; the number gaps are group breaks): P1 = 4 (BA-03, BA-12, BA-19, BA-20), P2 = 19, P3 = 16; 5 items closed as undecidable (BA-X1 to BA-X5); 4 notes to narrow (BA-N1 to BA-N4).
- Prerequisite chain: BA-03 -> BA-20 and BA-33; BA-12 -> BA-13; BA-19 and BA-12 before any rewrite of the `player_move_*` blanket lines.

## 5. Recommended order

1. B5a (BA-03 first), then B5b: the East and West glides are the only whole trigger kinds never run.
2. B5c: BA-19 and BA-12 remove the two "not observed" phrases left in the slope notes.
3. B5-apply for the three blanket lines (BA-N1 to BA-N3), which needs no new runs.
4. B5d and B5e, then B5f and B5g.

## Status (2026-10-30)

Investigated in `B5_20261030.md`: BA-01, 02, 03, 05, 10, 11, 14 (geometry), 15-24, 28 (name half), 30-34, 43 answered or partly answered; BA-06, 12, 13, 44 inconclusive; BA-04, 25-27, 28 (booster), 29, 35-37, 40-42 not run; BA-N1..N4 untouched.
