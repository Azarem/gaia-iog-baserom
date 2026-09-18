# Slope & Ramp Physics — `slope_ramp_physics.asm`

*Part of the [Bank $02 Documentation Suite](readme.md)*

> Terrain-based movement physics with slope detection, speed curves, and deceleration

**Source:** [`slope_ramp_physics.asm`](../../../extracted/actors/player/slope_ramp_physics.asm)

---

## Overview

Terrain-following slope and ramp physics companion actor. Probes tiles at the player's feet via `TileProbeMain`, dispatches through a 16-entry `SlopeTileDispatch` table by collision nibble, applies speed curves from WRAM table pointers, clamps to max speeds, and runs flat-ground deceleration when off ramps. The resulting `player_speed_ew`/`player_speed_ns` values feed into [`player_move_controller`](player-character.md#player_move_controllerasm), which merges them into the movement engine documented in [`player-movement.md`](player-movement.md).

**Related:** [`player-character.md`](player-character.md) · [`player-movement.md`](player-movement.md) · [`tile-collision.md`](tile-collision.md) (tile probing)

---

## Memory Map

| Address | Name | Description |
|---------|------|-------------|
| `$02B42B` | SlopePhysicsEntry | Main entry. Checks freeze + orb flags (`$0010,X` bit `$00C0`); skipped only when iframe counter is negative. If moving: probes tile at player feet, dispatches through `SlopeTileDispatch`. If not moving but `$1000`: probes 4 adjacent tiles for ramp exit. |
| `$02B538` | SlopeType03Handler | Slope `$03` — south-descending (NS+, positive NS curve via `slopeCurvePtrB`). |
| `$02B53D` | SlopeType05Handler | Slope `$05` — west (EW−, negative EW curve via `slopeCurvePtrA`). |
| `$02B542` | SlopeType0AHandler | Slope `$0A` — east (EW+, positive EW curve via `slopeCurvePtrA`). |
| `$02B547` | SlopeType0CHandler | Slope `$0C` — north-descending (NS−, negative NS curve via `slopeCurvePtrB`). |
| `$02B550` | SlopeFlatExit | No slope: clamp speed, clear `$09C6`/`$09B6`. |
| `$02B55B` | SlopeFlatDecelerate | Flat ground: check EW → `DecelerateEW`. If `$1000` → clear. Check NS → `DecelerateNS`. |
| `$02B57C` | SlopeTileDispatch | 16-entry lookup table by collision type. |
| `$02B59C` | ApplySlopeCurveNegEW | Read decel curve at `$09BA` indexed by `$09B6 & $0F`. Negate, add to `player_speed_ew`. |
| `$02B5BC` | ApplySlopeCurvePosEW | Positive addition to EW speed. |
| `$02B5E2` | ApplySlopeCurvePosNS | Add to `player_speed_ns` from `$09BC`. |
| `$02B5FE` | ApplySlopeCurveNegNS | Negated addition to NS speed. |
| `$02B61E` | ClampSpeeds | Clamp `player_speed_ew` to ±`$09C8` and `player_speed_ns` to ±`$09CA`. |
| `$02B675` | DecelerateEW | Flat-ground EW deceleration. Skips if on-slope (`$1000`). Zeros speed if < 3, otherwise reads curve table step and subtracts from `player_speed_ew`. |
| `$02B701` | ReadDecelerationStep | Read deceleration delta from `$09C2` indexed by `$09B8 & $0F`. |
| `$02B714` | DecelerateNS | Mirror of `DecelerateEW` for NS axis. |
| `$02B7A0` | ReadDecelerationStepNS | Mirror of `ReadDecelerationStep`. |

### Shared WRAM Variables

Most routines in this file read and write the player actor slot and shared state bitmask:

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |

#### Slope Detection & Entry

### SlopePhysicsEntry

Main entry. Checks freeze + orb flags on the player actor (`$0010,X` bit `$00C0`: freeze `$0080` + orb `$0040`); only bypassed when iframe counter is negative. If moving: probes tile at player feet, dispatches through `SlopeTileDispatch`. If not moving but `$1000`: probes 4 adjacent tiles for ramp exit.

**Algorithm:**
- Check freeze/orb flags → `SlopeFlatDecelerate` unless iframe counter is negative
- If moving: probe tile at feet via `TileProbeMain`
- Dispatch through `SlopeTileDispatch` by collision nibble
- If stopped but on-slope (`$1000`): probe adjacent cells for ramp exit
- Otherwise run `SlopeFlatDecelerate`

### SlopeFlatDecelerate

Flat ground: check EW → `DecelerateEW`. If `$1000` → clear. Check NS → `DecelerateNS`.

### SlopeTileDispatch

16-entry word table indexed by collision nibble × 2, used as a jump dispatch after `TileProbeMain` reads the tile under the player's feet. Only four entries are populated: `$03` → south-descending slope handler, `$05` → west-descending ramp, `$0A` → east-descending ramp, and `$0C` → north-descending slope handler; all other types (floor, ladder, walls, solids) are zero and fall through to flat-ground exit. Non-zero entries use the RTS dispatch trick (address − 1 stored, `DEC`/`PHA`/`RTS`) to branch directly into the matching curve-application handler.

#### Curve Application

### ApplySlopeCurveNegEW

Read decel curve at `$09BA` indexed by `$09B6 & $0F`. Negate, add to `player_speed_ew`.

### ApplySlopeCurvePosEW

Applies the current slope curve's acceleration to the player's east-west speed while standing on an **east-descending ramp tile** (`$0A`). Each frame, `slopeStepCounter & $0F` indexes a 16-bit delta from the WRAM table at `slopeCurvePtrA` (`$09BA`), which is added directly to `player_speed_ew` to produce gradual acceleration downhill (eastward). When speed reaches zero the `$1000` stopped-on-slope flag is set and the step counter resets; otherwise the counter increments for the next frame's curve sample.

### ApplySlopeCurvePosNS

Applies the NS-axis slope curve to `player_speed_ns` while the player stands on a **south-descending slope tile** (`$03`). The curve value is read from the WRAM table at `slopeCurvePtrB` (`$09BC`), indexed by `slopeStepCounter & $0F`, and added directly to produce gradual southward acceleration. Speed-zero sets the `$1000` stopped-on-slope flag; nonzero speed advances the step counter for the next frame.

### ApplySlopeCurveNegNS

Applies the NS-axis slope curve in the **negative direction** while the player stands on a **north-descending slope tile** (`$0C`). The table value from `slopeCurvePtrB` is two's-complement negated before addition to `player_speed_ns`, producing gradual northward acceleration (deceleration of southward speed). The sign flip distinguishes uphill-north terrain from the positive `$03` handler — both share the same curve table but apply opposite signs.

#### Speed Clamping

### ClampSpeeds

Limits both axis speeds after every slope curve application and on flat exit, preventing runaway acceleration down long ramps. Each axis compares `|speed|` against its configured maximum (`maxSpeedEw` at `$09C8`, `maxSpeedNs` at `$09CA`); speeds at or above the max are clamped to ±(`max` − 1), where the −1 prevents oscillation at the boundary. Called from all four slope type handlers and `SlopeFlatExit` before restoring registers.

#### Flat Deceleration

### DecelerateEW

Flat-ground EW deceleration. Skips if on-slope flag (`$1000`) is set. If absolute speed < 3, zeros `player_speed_ew`. Otherwise, reads deceleration delta from curve table at `$09C2` (indexed by `$09B8 & $0F`), negates it, and subtracts from speed. Handles both positive (eastward) and negative (westward) speed separately.

### DecelerateNS

Flat-ground north-south deceleration, structurally identical to `DecelerateEW` but operating on `player_speed_ns` with the south (`$0400`) and north (`$0800`) D-pad bits. Skips entirely when the `$1000` stopped-on-slope flag is set (player resting on a ramp without pushing off). Speeds below 3 are zeroed instantly; otherwise a deceleration step is read from `decelCurvePtr` via `ReadDecelerationStepNS` and subtracted, with extra braking when the player holds the opposite direction and suppression when holding the same direction as current motion.


## See Also

- [`player-movement.md`](player-movement.md) — `PlayerMovementTick` (`$02CFD0`), tile collision (`$02E102`)
- [`tile-collision.md`](tile-collision.md) — tile probing for slopes and shimmy
- [`../../cop-commands-reference.md`](../../cop-commands-reference.md) — COP command semantics
- [`../../actor-organization-analysis.md`](../../actor-organization-analysis.md) — global actor linked list
