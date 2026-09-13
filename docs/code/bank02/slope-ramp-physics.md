# Slope & Ramp Physics — `slope_ramp_physics.asm`

*Part of the [Bank $02 Documentation Suite](index.md)*

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


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `slope_ramp_physics` block | Parent compilation unit |

### SlopeFlatDecelerate

Flat ground: check EW → `DecelerateEW`. If `$1000` → clear. Check NS → `DecelerateNS`.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `slope_ramp_physics` block | Parent compilation unit |

### SlopeTileDispatch

16-entry lookup table by collision type.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `slope_ramp_physics` block | Parent compilation unit |

#### Curve Application

### ApplySlopeCurveNegEW

Read decel curve at `$09BA` indexed by `$09B6 & $0F`. Negate, add to `player_speed_ew`.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `slope_ramp_physics` block | Parent compilation unit |

### ApplySlopeCurvePosEW

Positive addition to EW speed.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `slope_ramp_physics` block | Parent compilation unit |

### ApplySlopeCurvePosNS

Add to `player_speed_ns` from `$09BC`.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `slope_ramp_physics` block | Parent compilation unit |

### ApplySlopeCurveNegNS

Negated addition to NS speed.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `slope_ramp_physics` block | Parent compilation unit |

#### Speed Clamping

### ClampSpeeds

Clamp `player_speed_ew` to ±`$09C8` and `player_speed_ns` to ±`$09CA`.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `slope_ramp_physics` block | Parent compilation unit |

#### Flat Deceleration

### DecelerateEW

Flat-ground EW deceleration. Skips if on-slope flag (`$1000`) is set. If absolute speed < 3, zeros `player_speed_ew`. Otherwise, reads deceleration delta from curve table at `$09C2` (indexed by `$09B8 & $0F`), negates it, and subtracts from speed. Handles both positive (eastward) and negative (westward) speed separately.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `slope_ramp_physics` block | Parent compilation unit |

### DecelerateNS

Mirror of `DecelerateEW` for NS axis.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `slope_ramp_physics` block | Parent compilation unit |


## See Also

- [`player-movement.md`](player-movement.md) — `PlayerMovementTick` (`$02CFD0`), tile collision (`$02E102`)
- [`tile-collision.md`](tile-collision.md) — tile probing for slopes and shimmy
- [`../../cop-commands-reference.md`](../../cop-commands-reference.md) — COP command semantics
- [`../../actor-organization-analysis.md`](../../actor-organization-analysis.md) — global actor linked list
