# Bank $00 — Functions: Camera Drift, Ambient Motion & Orbital Math

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00C9B8`–`$00D068`, `$00F3B3`–`$00F432`  
**Source files:** `extracted/functions/SpawnDebrisBurst.asm`, `CameraDriftLoopSimple.asm`, `CameraDriftLoopShip.asm`, `CameraDriftPatterned.asm`, `StopPlayerOnDeathAssign.asm`, `ApplyOrbitalOffsetFromRef.asm`, `ApplyOrbitalOffsetXY.asm`  
**Block:** `camera_drift`, standalone functions in `us/blocks.json`

Three subsystems share this address region: ambient camera drift loops for boss/ship arenas, debris burst VFX, and sin/cos orbital offset math used by COP handlers, bosses, and decorative actors.

**Related:** [`actors-infrastructure.md`](actors-infrastructure.md) (`camera_scroll_controller`) · [`utility-math-movement.md`](utility-math-movement.md) · [`bank00-upper-analysis.md`](../bank00-upper-analysis.md) §4.6–§4.7

---

## Overview

| Function | Old Name | Address | Size | Movable | Call Type | Priority |
|----------|----------|---------|------|---------|-----------|----------|
| `CameraDriftLoopSimple` | `func_00CF8E` | `$CF8E` | 32 B | ✓ | COP `SpawnAfterFlags` | Medium |
| `CameraDriftLoopShip` | `func_00CFAE` | `$CFAE` | 65 B | ✓ | COP `SpawnAfterFlags` | Medium |
| `CameraDriftPatterned` | `func_00CFEF` | `$CFEF` | 121 B | ✓ (with data) | COP `SpawnLastRel` | Medium |
| `SpawnDebrisBurst` | `func_00C9B8` | `$C9B8` | 67 B | ✓ | COP `SpawnAfterFlags` | Medium |
| `ApplyOrbitalOffsetFromRef` | `func_00F3C9` | `$F3C9` | 95 B | ✓ | JSL (15+ refs) | **High** |
| `ApplyOrbitalOffsetXY` | `func_00F432` | `$F432` | 93 B | ✓ | JSL (~3 callers) | Medium |
| `CopyRefActorPos_unused` | `func_00F428` | `$F428` | 10 B | — | None (dead) | — |

---

## Camera Drift

### CameraDriftLoopSimple

| Property | Value |
|----------|-------|
| **Old Name** | `func_00CF8E` |
| **New Name** | `CameraDriftLoopSimple` |
| **Hex Address** | `$00CF8E` |
| **Decimal Address** | 53134 |
| **End Address** | `$00CFAE` (53166) |
| **Size** | 32 bytes |
| **ASM File** | `extracted/functions/CameraDriftLoopSimple.asm` |
| **Movable** | Yes |

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

| Property | Value |
|----------|-------|
| **Old Name** | `func_00CFAE` |
| **New Name** | `CameraDriftLoopShip` |
| **Hex Address** | `$00CFAE` |
| **Decimal Address** | 53166 |
| **End Address** | `$00CFEF` (53231) |
| **Size** | 65 bytes |
| **ASM File** | `extracted/functions/CameraDriftLoopShip.asm` |
| **Movable** | Yes |

#### Description

Camera drift variant gated by `$player_flags`. Only applies random nudges when `$player_flags` bit `$0100` is clear (player not in a special state like cutscene or menu). Used on the Gold Ship and similar moving-platform scenes where camera drift should pause during transitions.

Same ±1..±2 pixel random offset as `CameraDriftLoopSimple` but with an additional flag check each frame and an infinite loop (no 120-frame limit) — runs until the hosting actor dies.

#### Algorithm

```
1. Loop:
     a. LDA $player_flags
     b. BIT #$0100 → skip if set (special state active)
     c. JSR random → apply ±1..±2 to $06C0/$06C4
     d. COP [WaitFrame]
     e. BRA Loop
```

#### Variables

| Symbol | Role |
|--------|------|
| `$player_flags` bit `$0100` | Gate — drift paused when set |
| `$06C0`, `$06C4` | Camera scroll deltas |

---

### CameraDriftPatterned

| Property | Value |
|----------|-------|
| **Old Name** | `func_00CFEF` |
| **New Name** | `CameraDriftPatterned` |
| **Decimal Address** | 53231 |
| **Hex Address** | `$00CFEF` |
| **End Address** | `$00D068` (53352) |
| **Size** | 121 bytes + 32-byte data |
| **ASM File** | `extracted/functions/CameraDriftPatterned.asm` |
| **Movable** | Yes (must move with `binary_00D068`) |

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

| Property | Value |
|----------|-------|
| **Address** | `$00D068` |
| **Size** | 32 bytes (8 × 4-byte X/Y delta pairs) |
| **Format** | Signed byte X offset, signed byte Y offset, 2 padding/reserved bytes per entry |

---

## Ambient VFX

### SpawnDebrisBurst

| Property | Value |
|----------|-------|
| **Old Name** | `func_00C9B8` |
| **New Name** | `SpawnDebrisBurst` |
| **Hex Address** | `$00C9B8` |
| **Decimal Address** | 51640 |
| **End Address** | `$00C9FB` (51707) |
| **Size** | 67 bytes |
| **ASM File** | `extracted/functions/SpawnDebrisBurst.asm` |
| **Movable** | Yes |

#### Description

Spawns 8 RNG-scattered sparkle/debris actors around a central point. Each child actor gets a random X/Y offset (±$10 to ±$30 pixels) from the spawn origin and a short-lived animation before dying. Used for wall destruction, treasure reveal, and environmental break effects.

Invoked via `COP [SpawnAfterFlags]` from scene scripts and destructible object actors.

#### Algorithm

```
1. LDX #8  ; Spark count
2. Loop:
     a. JSR random → X offset (±$10..$30)
     b. JSR random → Y offset (±$10..$30)
     c. Add to origin $14/$16
     d. COP [SpawnAfterFlags] sparkle actor
     e. DEX; BNE Loop
3. COP [Die]
```

---

## Orbital / Circular Math

### ApplyOrbitalOffsetFromRef

| Property | Value |
|----------|-------|
| **Old Name** | `func_00F3C9` |
| **New Name** | `ApplyOrbitalOffsetFromRef` |
| **Hex Address** | `$00F3C9` |
| **Decimal Address** | 62409 |
| **End Address** | `$00F428` (62504) |
| **Size** | 95 bytes |
| **ASM File** | `extracted/functions/ApplyOrbitalOffsetFromRef.asm` |
| **Movable** | Yes |
| **Priority** | **High** (15+ live references) |

#### Description

Computes sin/cos orbital offset from a reference actor's position. Reads the reference actor index from `$0000`, loads that actor's `$14`/`$16` as the orbit center, then applies `$7F0010,X` (angle) and `$7F1010,X` (diameter/radius) to compute new X/Y positions using the sin/cos lookup tables at `binary_01C455`/`binary_01C495` (bank `$01`) and signed multiply via `SignedMultiply` (bank `$02`).

**Previously misplaced in `extracted/unused/`** — moved to `functions` section in `blocks.json` (2026-09-06) after discovery of 15+ active `$@func_00F3C9` references.

Used by:
- COP `$6D` (`SpiralStep`) handler in `cop_handlers_collision.asm`
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
5. JSR SignedMultiply with $7F1010,X (diameter) → delta_x
6. LDA cos_table,X → A
7. JSR SignedMultiply with diameter → delta_y
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
| `binary_01C455` | Sin lookup table (bank `$01`) |
| `binary_01C495` | Cos lookup table (bank `$01`) |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| COP handler | `cop_handler_6D_00A9AE` | SpiralStep |
| Boss scripts | Castoth, Viper | Orbiting attacks |
| Actors | Fire sprites, statue pickup | Decorative orbit |
| System core | `system_core.asm` | `?INCLUDE` reference |
| Cataloged in | `us/blocks.json` | Moved from `unused` → `functions` |

---

### ApplyOrbitalOffsetXY

| Property | Value |
|----------|-------|
| **Old Name** | `func_00F432` |
| **New Name** | `ApplyOrbitalOffsetXY` |
| **Hex Address** | `$00F432` |
| **Decimal Address** | 62514 |
| **End Address** | `$00F48F` (62607) |
| **Size** | 93 bytes |
| **ASM File** | `extracted/functions/ApplyOrbitalOffsetXY.asm` |
| **Movable** | Yes |

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
| Sin/cos tables | `binary_01C455/495` | Bank `$01` |
| Math helper | `SignedMultiply` | Bank `$02` |
| Callers | ~3 boss/actor scripts | JSL |
| Cataloged in | `us/names.json` @ 62514 | |

---

### CopyRefActorPos_unused

| Property | Value |
|----------|-------|
| **Old Name** | `func_00F428` |
| **New Name** | `CopyRefActorPos_unused` |
| **Hex Address** | `$00F428` |
| **Decimal Address** | 62504 |
| **End Address** | `$00F432` (62514) |
| **Size** | 10 bytes |
| **Movable** | N/A — dead code |

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
| `binary_01C455/495` | `$01` | Sin/cos tables |
| `SignedMultiply` | `$02` | Orbital offset functions |
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

*Source: `us/blocks.json`, `us/names.json`, `docs/code/bank00-upper-analysis.md`, `docs/cop-commands-reference.md` §3.15.*
