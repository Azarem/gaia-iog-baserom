# Slope & Ramp Physics — `slope_ramp_physics.asm`

> Terrain-based movement physics with slope detection, speed curves, and deceleration

**Source:** [`slope_ramp_physics.asm`](../../../extracted/actors/player/slope_ramp_physics.asm)

---

## Overview

Terrain-following slope and ramp physics companion actor. Probes tiles at the player's feet via `TileProbeMain`, dispatches through a 16-entry `SlopeTileDispatch` table by collision nibble, applies speed curves from WRAM table pointers, clamps to max speeds, and runs flat-ground deceleration when off ramps.

**Related:** [`player-character.md`](player-character.md) · [`camera-and-map.md`](camera-and-map.md) (tile probing)

---

## Memory Map

| Address | Name | Size | Description |
|---------|------|------|-------------|
| `$02B42B` | SlopePhysicsEntry | 301 B | Main entry. Checks paralysis/death. If moving: probes tile at player feet, dispatches through `SlopeTileDispatch`. If not moving but `$1000`: probes 4 adjacent tiles for ramp exit. |
| `$02B538` | SlopeType03Handler | 5 B | Slope `$03` (right ascending). |
| `$02B53D` | SlopeType05Handler | 5 B | Slope `$05` (semi-solid ramp). |
| `$02B542` | SlopeType0AHandler | 5 B | Slope `$0A` (passable ramp). |
| `$02B547` | SlopeType0CHandler | 3 B | Slope `$0C` (left ascending). |
| `$02B550` | SlopeFlatExit | 11 B | No slope: clamp speed, clear `$09C6`/`$09B6`. |
| `$02B55B` | SlopeFlatDecelerate | 27 B | Flat ground: check EW → `DecelerateEW`. If `$1000` → clear. Check NS → `DecelerateNS`. |
| `$02B57C` | SlopeTileDispatch | 32 B | 16-entry lookup table by collision type. |
| `$02B59C` | ApplySlopeCurveNegEW | 32 B | Read decel curve at `$09BA` indexed by `$09B6 & $0F`. Negate, add to `player_speed_ew`. |
| `$02B5BC` | ApplySlopeCurvePosEW | 28 B | Positive addition to EW speed. |
| `$02B5E2` | ApplySlopeCurvePosNS | 28 B | Add to `player_speed_ns` from `$09BC`. |
| `$02B5FE` | ApplySlopeCurveNegNS | 32 B | Negated addition to NS speed. |
| `$02B61E` | ClampSpeeds | 87 B | Clamp `player_speed_ew` to ±`$09C8` and `player_speed_ns` to ±`$09CA`. |
| `$02B675` | DecelerateEW | 140 B | Flat-ground EW deceleration. Skips if on-slope (`$1000`). Zeros speed if < 3, otherwise reads curve table step and subtracts from `player_speed_ew`. |
| `$02B701` | ReadDecelerationStep | 19 B | Read deceleration delta from `$09C2` indexed by `$09B8 & $0F`. |
| `$02B714` | DecelerateNS | 140 B | Mirror of `DecelerateEW` for NS axis. |
| `$02B7A0` | ReadDecelerationStepNS | 19 B | Mirror of `ReadDecelerationStep`. |

#### Subgroup 17A — Detection & Dispatch

### SlopePhysicsEntry

Main entry. Checks paralysis/death. If moving: probes tile at player feet, dispatches through `SlopeTileDispatch`. If not moving but `$1000`: probes 4 adjacent tiles for ramp exit.

**Algorithm:**
- Check paralysis/death → flat decelerate if inactive
- If moving: probe tile at feet via `TileProbeMain`
- Dispatch through `SlopeTileDispatch` by collision nibble
- If stopped but on-slope (`$1000`): probe adjacent cells for ramp exit
- Otherwise run `SlopeFlatDecelerate`

**Source:**

```14:152:../../../extracted/actors/player/slope_ramp_physics.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `slope_ramp_physics` block | Parent compilation unit |

### SlopeFlatDecelerate

Flat ground: check EW → `DecelerateEW`. If `$1000` → clear. Check NS → `DecelerateNS`.

**Source:**

```185:207:../../../extracted/actors/player/slope_ramp_physics.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `slope_ramp_physics` block | Parent compilation unit |

### SlopeTileDispatch

16-entry lookup table by collision type.

**Source:**

```208:226:../../../extracted/actors/player/slope_ramp_physics.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `slope_ramp_physics` block | Parent compilation unit |

#### Subgroup 17B — Speed Curves

### ApplySlopeCurveNegEW

Read decel curve at `$09BA` indexed by `$09B6 & $0F`. Negate, add to `player_speed_ew`.

**Source:**

```227:244:../../../extracted/actors/player/slope_ramp_physics.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `slope_ramp_physics` block | Parent compilation unit |

### ApplySlopeCurvePosEW

Positive addition to EW speed.

**Source:**

```245:266:../../../extracted/actors/player/slope_ramp_physics.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `slope_ramp_physics` block | Parent compilation unit |

### ApplySlopeCurvePosNS

Add to `player_speed_ns` from `$09BC`.

**Source:**

```267:282:../../../extracted/actors/player/slope_ramp_physics.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `slope_ramp_physics` block | Parent compilation unit |

### ApplySlopeCurveNegNS

Negated addition to NS speed.

**Source:**

```283:300:../../../extracted/actors/player/slope_ramp_physics.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `slope_ramp_physics` block | Parent compilation unit |

#### Subgroup 17C — Clamping

### ClampSpeeds

Clamp `player_speed_ew` to ±`$09C8` and `player_speed_ns` to ±`$09CA`.

**Source:**

```301:362:../../../extracted/actors/player/slope_ramp_physics.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `slope_ramp_physics` block | Parent compilation unit |

#### Subgroup 17D — Deceleration

### DecelerateEW

Flat-ground EW deceleration. Skips if on-slope flag (`$1000`) is set. If absolute speed < 3, zeros `player_speed_ew`. Otherwise, reads deceleration delta from curve table at `$09C2` (indexed by `$09B8 & $0F`), negates it, and subtracts from speed. Handles both positive (eastward) and negative (westward) speed separately.

**Source:**

```363:455:../../../extracted/actors/player/slope_ramp_physics.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `slope_ramp_physics` block | Parent compilation unit |

### DecelerateNS

Mirror of `DecelerateEW` for NS axis.

**Source:**

```468:560:../../../extracted/actors/player/slope_ramp_physics.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `slope_ramp_physics` block | Parent compilation unit |


## See Also

- [`../bank2-code-analysis.md`](../bank2-code-analysis.md) — `PlayerMovementTick` (`$02CFD0`), tile collision (`$02E102`)
- [`camera-and-map.md`](camera-and-map.md) — tile probing for slopes and shimmy
- [`../../cop-commands-reference.md`](../../cop-commands-reference.md) — COP command semantics
- [`../../actor-organization-analysis.md`](../../actor-organization-analysis.md) — global actor linked list
