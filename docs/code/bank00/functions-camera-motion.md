# Bank $00 — Functions: Camera Drift, Ambient Motion & Orbital Math

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00C9B8`–`$00D068`, `$00F3B3`–`$00F432`  
**Source files:** [`extracted/functions/camera_drift.asm`](../../../extracted/functions/camera_drift.asm) (contains `CameraDriftLoopSimple`, `CameraDriftLoopShip`, `CameraDriftPatterned`), [`SpawnDebrisBurst.asm`](../../../extracted/functions/SpawnDebrisBurst.asm), [`StopPlayerOnDeath.asm`](../../../extracted/functions/StopPlayerOnDeath.asm), [`ApplyOrbitalOffsetFromRef.asm`](../../../extracted/functions/ApplyOrbitalOffsetFromRef.asm), [`ApplyOrbitalOffsetXY.asm`](../../../extracted/functions/ApplyOrbitalOffsetXY.asm)  
**Block:** `camera_drift` + standalone orbital math functions

Three subsystems share this address region: ambient camera drift loops for boss/ship arenas, debris burst VFX, and sin/cos orbital offset math used by COP handlers, bosses, and decorative actors.

**Related:** [`actors-infrastructure.md`](actors-infrastructure.md) (`camera_scroll_controller`) · [`utility-math-movement.md`](utility-math-movement.md) · [`README.md`](README.md)

---

## Overview

| Function | Address | Size | Movable | Call Type | Priority |
|----------|---------|------|---------|-----------|----------|
| `CameraDriftLoopSimple` | `$CF8E` | 32 B | ✓ | COP `SpawnAfterFlags` | Medium |
| `CameraDriftLoopShip` | `$CFAE` | 65 B | ✓ | COP `SpawnAfterFlags` | Medium |
| `CameraDriftPatterned` | `$CFEF` | 121 B | ✓ (with data) | COP `SpawnLastRel` | Medium |
| `SpawnDebrisBurst` | `$C9B8` | 67 B | ✓ | COP `SpawnAfterFlags` | Medium |
| `ApplyOrbitalOffsetFromRef` | `$F3C9` | 95 B | ✓ | JSL (15+ refs) | **High** |
| `ApplyOrbitalOffsetXY` | `$F432` | 93 B | ✓ | JSL (~3 callers) | Medium |
| `CopyRefActorPos_unused` | `$F428` | 10 B | — | None (dead) | — |

---

## Camera Drift

### CameraDriftLoopSimple

**Address:** `$CF8E` · **Size:** 32 bytes

#### Description

120-frame random camera nudge loop. Each iteration generates a random offset of ±1 or ±2 pixels in X and/or Y, applies it to the camera scroll accumulator (`$06C0`/`$06C4`), waits one frame, and decrements the 120-frame counter. Creates subtle ambient camera motion in boss arenas and enclosed spaces.

Spawned via `COP [SpawnAfterFlags]` from scene thinker/actor scripts that want continuous gentle camera sway without player input.

#### Algorithm

```
1. LDX #120  ; Frame counter
2. Loop:
     a. JSR random
     b. AND #$03 → offset magnitude (0–3, mapped to ±1..±2)
     c. Add to $06C0 (scroll X delta)
     d. JSR random → add to $06C4 (scroll Y delta)
     e. COP [WaitFrame]
     f. DEX; BNE Loop
3. COP [Die]
```

#### Variables

| Symbol | Role |
|--------|------|
| `$06C0` | Camera scroll delta X |
| `$06C4` | Camera scroll delta Y |
| Loop counter | 120 frames (~2 seconds) |

---

### CameraDriftLoopShip

**Address:** `$CFAE` · **Size:** 65 bytes

#### Description

Camera drift variant gated by `$player_flags`. Only applies random nudges when `$player_flags` bit `$0100` is clear (no forced-walk warp pan in progress). Used on the Gold Ship and similar moving-platform scenes where camera drift should pause during transitions.

Same ±1..±2 pixel random offset as `CameraDriftLoopSimple` but with an additional flag check each frame and an infinite loop (no 120-frame limit) — runs until the hosting actor dies.

#### Algorithm

```
1. Loop:
     a. LDA $player_flags
     b. BIT #$0100 → skip if set (forced walk active)
     c. JSR random → apply ±1..±2 to $06C0/$06C4
     d. COP [WaitFrame]
     e. BRA Loop
```

#### Variables

| Symbol | Role |
|--------|------|
| `$player_flags` bit `$0100` (forced walk) | Gate — drift paused when set |
| `$06C0`, `$06C4` | Camera scroll deltas |

---

### CameraDriftPatterned

**Address:** `$CFEF` · **Size:** 121 bytes + 32-byte data

#### Description

Direction-table camera drift for boss arenas with deliberate motion patterns rather than pure RNG. Reads sequential entries from `binary_00D068` (8 direction delta pairs) in a looping pattern, applying each offset to `$06C0`/`$06C4` with a configurable frame delay between steps.

Used in Viper boss arena, Comet Lair, and other set-piece battles where the camera should sway in a predictable rhythm.

#### Algorithm

```
1. LDX #0  ; Direction table index
2. Loop:
     a. Read binary_00D068,X → delta X
     b. Read binary_00D068+1,X → delta Y
     c. Add to $06C0/$06C4
     d. COP [WaitFrame] × delay_count
     e. INX; INX; CPX #16; BCC Loop (8 pairs × 2 bytes)
     f. LDX #0 → wrap to start
3. BRA Loop (infinite)
```

#### Data: `binary_00D068`

**Address:** `$D068` · **Size:** 32 bytes (8 × 4-byte X/Y delta pairs)

| Format | Signed byte X offset, signed byte Y offset, 2 padding/reserved bytes per entry |

---

## Ambient VFX

### SpawnDebrisBurst

**Address:** `$C9B8` · **Size:** 67 bytes

#### Description

Spawns eight `DebrisBurstParticle` children via a COP **`LoopStart` / `LoopEnd`** script (not an `LDX` loop). Each pass **`WaitByte` #3** (four frame skips) then `SpawnAfterFlags`; one particle about every five frames (~40 frames total). Each particle scatters **−16..+15 px** independently on X and Y (`RngByte` & `$1F` − `$10`), plays **`PlaySoundBoth` #$0F0F**, animates frame `#01` once, and dies.

Callers include `dm3D_breakable_wall`, `gw83_switch`, `it19_breakable_wall`, and `dm40_trapped_slave` (four sites).

#### Algorithm

```
1. LoopStart #08
2. Each pass: WaitByte #03 → SpawnAfterFlags @DebrisBurstParticle (#$0302) → LoopEnd
3. Die
```

---

## Orbital / Circular Math

### ApplyOrbitalOffsetFromRef

**Address:** `$F3C9` · **Size:** 95 bytes

#### Description

Computes sin/cos orbital offset from a reference actor's position. Reads the reference actor index from `$0000`, loads that actor's `$14`/`$16` as the orbit center, then applies `$7F0010,X` (angle) and `$7F1010,X` (diameter/radius) to compute new X/Y positions using the sin/cos lookup tables at `sine_table_8bit`/`signed_cosine_table_8bit` (bank `$01`) and signed multiply via `Multiply8x8Unsigned` (bank `$02`).

**Previously misplaced in `extracted/unused/`** — moved to `functions` after discovery of 15+ active `$@ApplyOrbitalOffsetFromRef` references.

Used by:
- COP `$6D` (`SpiralStep`) handler in `cop_handlers_effects.asm`
- Castoth boss orbiting projectiles
- Fire sprite actors
- Statue inventory pickup children
- System core (included via `?INCLUDE`)

#### Algorithm

```
1. LDY $0000           ; Reference actor index
2. LDA $14,Y → center_x; LDA $16,Y → center_y
3. LDA $7F0010,X       ; Orbit angle (0–255)
4. TAX; LDA sin_table,X → A
5. JSR Multiply8x8Unsigned with $7F1010,X (diameter) → delta_x
6. LDA cos_table,X → A
7. JSR Multiply8x8Unsigned with diameter → delta_y
8. Add deltas to center → store in actor $14/$16
9. RTL
```

#### Variables

| Symbol | Role |
|--------|------|
| `$0000` | Reference actor index (orbit center) |
| `$7F0010,X` | Orbit angle byte |
| `$7F1010,X` | Orbit diameter/radius |
| `$14`, `$16` | Output position (also input center via ref actor) |
| `sine_table_8bit` | Sin lookup table (bank `$01`) |
| `signed_cosine_table_8bit` | Cos lookup table (bank `$01`) |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| COP handler | `cop_handler_6D_00A9AE` | SpiralStep |
| Boss scripts | Castoth, Viper | Orbiting attacks |
| Actors | Fire sprites, statue pickup | Decorative orbit |
| System core | `system_core.asm` | `?INCLUDE` reference |

---

### ApplyOrbitalOffsetXY

**Address:** `$F432` · **Size:** 93 bytes

#### Description

Sin/cos offset variant using separate X and Y angle bytes instead of a single angle + reference actor. Reads angle X from `$7F0010,X` and angle Y from `$7F0012,X`, applies independent sin/cos lookups with separate diameter values `$7F1010,X` (X radius) and `$7F1012,X` (Y radius).

Used for elliptical orbits and Lissajous-style motion patterns where X and Y oscillate at different rates. Called from ~3 boss/actor scripts that need non-circular orbital paths.

#### Algorithm

```
1. LDA $7F0010,X → sin lookup → × $7F1010,X → delta_x
2. LDA $7F0012,X → cos lookup → × $7F1012,X → delta_y
3. Add deltas to current $14/$16
4. RTL
```

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Sin/cos tables | `sine_table_8bit/495` | Bank `$01` |
| Math helper | `Multiply8x8Unsigned` | Bank `$02` |
| Callers | ~3 boss/actor scripts | JSL |

---

### CopyRefActorPos_unused

**Address:** `$F428` · **Size:** 10 bytes

#### Description

Dead entry stub between `ApplyOrbitalOffsetFromRef` (`$F3C9`) and `ApplyOrbitalOffsetXY` (`$F432`). Contains partial/unfinished code that would have copied a reference actor's position without orbital offset. No live references — retained as padding between the two orbital functions.

---

## Call Reference Matrix

### Camera Drift

| Function | Spawned By | Pattern |
|----------|------------|---------|
| `CameraDriftLoopSimple` | Boss arena actors | `SpawnAfterFlags`, 120-frame |
| `CameraDriftLoopShip` | Gold Ship scenes | `SpawnAfterFlags`, infinite |
| `CameraDriftPatterned` | Viper, Comet Lair | `SpawnLastRel`, table-driven |

### Orbital Math

| Caller | Function | Mechanism |
|--------|----------|-----------|
| COP `$6D` SpiralStep | `ApplyOrbitalOffsetFromRef` | JSL |
| Castoth boss | `ApplyOrbitalOffsetFromRef` | JSL |
| Fire sprite actors | `ApplyOrbitalOffsetFromRef` | JSL |
| Elliptical orbit scripts (~3) | `ApplyOrbitalOffsetXY` | JSL |

### External Dependencies

| Target | Bank | Used By |
|--------|------|---------|
| `sine_table_8bit/495` | `$01` | Sin/cos tables |
| `Multiply8x8Unsigned` | `$02` | Orbital offset functions |
| RNG routine | `$00`/`$02` | Camera drift, debris burst |

---

## Statistics

| Metric | Value |
|--------|-------|
| Functions documented | 7 (6 live + 1 dead) |
| Camera drift span | `$CF8E`–`$D068` (250 bytes + 32-byte table) |
| Orbital math span | `$F3B3`–`$F48F` (220 bytes) |
| Highest reference count | `ApplyOrbitalOffsetFromRef` (15+) |
| Block grouping | `camera_drift` (3 functions + `binary_00D068`) |

---

*Source: `extracted/functions/camera_drift.asm`, `extracted/functions/SpawnDebrisBurst.asm`, `extracted/functions/ApplyOrbitalOffsetFromRef.asm`, `extracted/functions/ApplyOrbitalOffsetXY.asm`, `docs/cop/README.md`.*
