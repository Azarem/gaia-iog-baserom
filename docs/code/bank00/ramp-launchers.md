# Bank $00 — Ramp Jump Launchers (`ramps.asm`)

**Source:** [`extracted/actors/ramps.asm`](../../../extracted/actors/ramps.asm) (Bank `$00`, ROM offsets 53971–54829, `$D2D3`–`$D62D`) · **Related:** [`slider-glide-system.md`](slider-glide-system.md) (`RestorePlayerControl`, glide), [`actors-infrastructure.md`](actors-infrastructure.md) (`large_ramp_booster`), [`../../bank01-data-tables.md`](../../bank01-data-tables.md) §14c (`ramp_motion_curves`)

Four invisible launcher actors — `ramp_east`, `ramp_west`, `ramp_north`, `ramp_south` — watch the player. When the player runs into a launcher's window at speed, the launcher takes over the player's script, locks the controls and carries the player a fixed distance along one axis. East/west ramps add a precomputed vertical arc (the player leaps); north/south ramps move the player vertically for a number of animation cycles. They are actors placed through `scene_actors`, not collision tiles.

*Evidence tags: [ASM] = read from the extracted code; [RT] = measured in Mesen2 on the original ROM (session B4, every case run twice with identical results).*

## Per-frame watch (two stages)

**[ASM]** Each launcher runs the same two stages, mirrored per direction:

1. **Stage 1 (every frame).** `RampCheckPlayerSpeed` passes when |speed| on the ramp's axis (`playerSpeedEw` for east/west, `playerSpeedNs` for north/south) is at least 6 **and** `playerFlags` bit `$0800` (script lock) is clear. The player must then be inside the window below. The direction of the speed is not tested. When both hold, the ramp runs `SetEntryHere` and enters stage 2.
2. **Stage 2 (every frame).** The ramp compares the player's axis coordinate with its own. **Exactly equal → launch.** A distance of `$10` or more → back to stage 1. Speed and lock are not rechecked.

| Ramp | Axis | Window (player minus ramp) | Climb direction | Exit speed |
|------|------|----------------------------|-----------------|-----------|
| `ramp_east` | X, \|dy\| ≤ `$18` | +2 … +15 (player just east) | west, −8 px/frame | `$FFF8` |
| `ramp_west` | X, \|dy\| ≤ `$18` | −16 … −2 (player just west) | east, +8 px/frame | `$0008` |
| `ramp_north` | Y, \|dx\| ≤ `$10` | +2 … +15 (player just south) | north, −8 px/frame | `$FFF8` on `playerSpeedNs` |
| `ramp_south` | Y, \|dx\| ≤ `$10` | −16 … −2 (player just north) | south, +8 px/frame | `$0008` on `playerSpeedNs` |

Hook sites (ROM offsets, decimal): east watch 53973 / armed 54038 / stage 2 54040 / disarm 54063 / launch 54068; west 54093 / 54152 / 54154 / 54177 / 54182; north 54207 / 54262 / 54264 / 54287 / 54292; south 54317 / 54372 / 54374 / 54397 / 54402; north climb loop head 54577, south 54635.

### Measured: when does the equality fire?

**[RT]** The equality is not guaranteed by the step size. The player has to stop **exactly** on the ramp coordinate.

| Situation | Launched |
|-----------|---------:|
| Great Wall (`$85`): 8 ramps (4 west, 4 east, type 3), each backed by a wall; arrival speed forced to 6, 7, 8; 8 start phases each | 191 of 192 |
| Itory (`$15`) `ramp_east`, natural approach down the slope band (speed −7) | 1 of 1 |
| Itory `ramp_west` in its 3-cell pocket (wall to the east), speeds 6 and 8, 8 phases | 16 of 16 |
| `ramp_north` type 3 (`$21`) / type 9 (`$A1`), wall-backed | `$21`: speed 8 yes, speed 6 no; `$A1`: 16 of 16 |
| `ramp_south` type `$0B` in `$21` with the wall cells cleared in RAM (open ground), speeds 6 and 8, 8 phases | 3 of 16 |
| `ramp_south` type `$11` in `$A1`, speed 6 / speed 8 | 0 of 8 / 5 of 8 |
| Walking or running on flat ground (speed 2 and 3), Great Wall west ramp | 0 (never armed) |

- A wall or slope cell that stops the player on the ramp coordinate produces the equality; on open ground it needs the arrival step to divide the remaining distance.
- A player left short of the ramp coordinate stays in stage 2 while the distance is under 16 (code); measured only at 7–12 px short: stage 2 ran every frame for 112–115 frames, with no timeout. A player 16 px or more away disarms the ramp.
- **Edge quirk:** a west ramp can arm at exactly −16 and disarm in the same frame (stage 2 sees distance 16); it re-arms within two frames and launches (speed 6: armed frame 13, re-armed frame 14, launch frame 16).
- **Speed:** an approach whose speed falls below 6 before it enters the window never arms. On the slope latch (`playerFlags` `$1000`) the speed word drops by 1 per frame: a poked speed of 6 reads 5 on arrival in the `$21` north case. The only natural approach measured (Itory) arms at −7 on the slope band.
- One miss in the Great Wall sweep: the slope path pushed the player 30 px below the ramp row (outside `|dy| ≤ $18`) while it crossed the X window.

## Launch (`RampBeginPlayerControl`)

**[ASM]** The ramp stores the climb routine's address in the player's entry pointer (`$00/$02`), zeroes `playerSpeedEw` and `playerSpeedNs`, stores its own `$0E` (spawn type byte >> 1) in the player's `statsPtr`, zeroes the player's `$2C` / `$2E`, masks the D-pad (`joypadMaskStd` ← `$0F00`) and sets `playerFlags` `$0800`. **[RT]** At the launch frame `$09AE` goes `$0008` → `$1008` (slope latch + lock), speed 0, joypad mask `$0F00`.

## East / west climb

**[ASM]** Runs as the player. `RampArcDriver` is spawned as a child; the player writes the exit speed into the child, clears `$10` bit `$0008` (collision-aware movement off) and loops `StagePlayerMoveXY` + `AnimOnce` (X chain `$10` = −8 px/frame east ramp, `$0F` = +8 west ramp) until the child restores the player. The child adds one signed byte of `ramp_motion_curves` to the player's Y per frame.

| Type (`$0E`) | Curve | Ramps | Lock | Peak rise | End height | First free frame (dx from launch X) | Exit speed |
|-------------:|-------|-------|-----:|----------:|-----------:|------------------------------------|-----------:|
| 1 (`$0E` = 0) | `ramp_curve_arc_64` | Itory pair only | 64 frames **[RT]** | 204 (peak at frame 28) | launch height | −520 (east ramp), +519 (west ramp) | −8 / +7 |
| 3 (`$0E` = 1) | `ramp_curve_arc_32` | every other east/west ramp | 32 frames **[RT]** | 50 | +8 (lower) | +264 (west ramps), −263 / −264 (east ramps) | +8 / −7 or −8 |

**[RT]** The player's animation index (`$7F:0028`) is `$24` for the whole west-ramp arc and `$21` for the east-ramp arc, set two frames after the launch frame.

## North / south climb

**[ASM]** No child, no arc. The player's `loopCounter` ← `statsPtr` (the ramp's `$0E`: type `$09` = 4, `$0B` = 5, `$11` = 8, `$03` = 1); each loop is `StagePlayerMoveXY` + `AnimOnce` (one animation cycle of Y movement). At the end `playerSpeedNs` = `$FFF8` (north) / `$0008` (south), `RestorePlayerControl`, counters reset. `LoopEnd` decrements before testing, so a count of 0 would run 65,536 loops; no placed ramp uses 0.

| Climb | Animation | One loop **[RT]** | Placed types measured | Distance |
|-------|----------:|-------------------|-----------------------|----------|
| north | `$1E` | 9 frames: 8 moving (−8 px) + 1 hold = 64 px | type 3 (1 loop, `$21`): 9 locked frames; type 9 (4 loops, `$A1`): 36 locked frames | 64 px / 256 px |
| south | `$19` | 5 frames: 4 moving (+8 px) + 1 hold = 32 px | type `$11` (8 loops, `$A1`): 40 locked frames; type `$0B` (5 loops, counterfactual): 25 locked frames | 256 px / 160 px |

The first free frame is 7 px beyond the moving distance (type 9 north −263, type `$11` south +263).

## Quirks

- **[ASM]** `RampPlayerClimbEast` stores the exit speed through `LDX $06` without checking that `SpawnAfter` succeeded; with a full actor pool the climb loop would never end. No evidence that this happens.
- **[ASM]** The player's `$10` bit `$0200` is set here and by `slider_glide`; `combat_collision` includes it in its skip mask `$76E0`.
- **[RT]** The scene `$21` `ramp_south` (600, 336, type `$0B`) is not reachable in the loaded layout: the player is stopped 16 px short (Y 320) by a wall. The scene `$A1` `ramp_south` leaves the player 7–12 px short in 11 of 16 forced approaches.

## Placement

58 `actor-spawn` records: 26 `ramp_east`, 22 `ramp_west`, 6 `ramp_north`, 4 `ramp_south`, in scenes `$15`, `$1E`, `$21`, `$23`, `$4F`, `$53`, `$82`, `$83`, `$85` (Great Wall), `$88`, `$A1`–`$A3`, `$A5`, `$A7`, `$B3`, `$B5`, `$CE`, `$CF`, `$D6`. East/west ramps use type 3 except the Itory pair; north uses type 9 (one type 3 in `$21`); south uses type `$0B` in `$21` and `$11` elsewhere. Measured in `$15`, `$21`, `$85`, `$A1`.

## Source validation

**Files checked:** `extracted/actors/ramps.asm`, `extracted/actors/large_ramps.asm`, `extracted/tables/scene_actors.asm`, `db-us/names/bank00.json`. **Runtime:** `plans/extracted-audit/mesen2-results/B4_20261030.md` (states `S13`, `S14`, `S14b`, `S14f`; suites `sweep`, `itory`, `itoryw`, `ns`, `nsclear`, `nsa1`, `anim`).
