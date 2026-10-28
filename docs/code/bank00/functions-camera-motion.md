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
| `ApplyOrbitalOffsetFromRef` | `$F3C9` | 95 B | ✓ | JSL (21 sites) | **High** |
| `ApplyOrbitalOffsetXY` | `$F432` | 93 B | ✓ | JSL (3 call sites) | Medium |
| `CopyRefActorPos_unused` | `$F428` | 10 B | — | None (dead) | — |

---

## Camera Drift

### CameraDriftLoopSimple

**Address:** `$CF8E` · **Size:** 32 bytes

#### Description

120-frame random camera nudge loop. Each iteration adds a random offset of **−1 to +2** pixels (bias +0.5) to `cameraTargetX` / `cameraTargetY` and `cameraDeltaX` / `cameraDeltaY`, waits one frame, and decrements the counter. Offsets are not undone when the actor dies. Used in pyramid and Incan Ruins set pieces (`pyCD_flame_statue`, `ir25_ceiling_tile`, `ir29_castoth`).

Spawned via `COP [SpawnAfterFlags]` from scene thinker/actor scripts that want continuous gentle camera sway without player input.

#### Algorithm

```
1. LDX #120  ; Frame counter
2. Loop:
     a. JSR random
     b. AND #$03 → offset magnitude (0–3, mapped to ±1..±2)
     c. Add to cameraTargetX / cameraDeltaX
     d. JSR random → add to cameraTargetY / cameraDeltaY
     e. COP [WaitFrame]
     f. DEX; BNE Loop
3. COP [Die]
```

#### Variables

| Symbol | Role |
|--------|------|
| `cameraTargetX`, `cameraDeltaX` | Camera target / delta X |
| `cameraTargetY`, `cameraDeltaY` | Camera target / delta Y |
| Loop counter | 120 frames (~2 seconds) |

---

### CameraDriftLoopShip

**Address:** `$CFAE` · **Size:** 65 bytes

#### Description

Camera drift variant gated by `$player_flags`. Each frame, if bit `$0100` (forced walk) is clear, undoes the previous frame's stored offset (`$26`), draws a new 0–3 pixel offset, and adds it to `cameraTarget*` / `cameraDelta*`. Skips the update on forced-walk frames. Infinite loop until the hosting actor dies.

Used on Gold Ship and undersea tunnel scenes (`st68_kara`, `gs2D_lily`, `gs2D_lance`, `gs2B_erik`).

#### Algorithm

```
1. Loop:
     a. LDA $player_flags
     b. BIT #$0100 → skip if set (forced walk active)
     c. Undo prior offset, JSR random → apply 0..3 to cameraTarget/Delta X/Y
     d. COP [WaitFrame]
     e. BRA Loop
```

#### Variables

| Symbol | Role |
|--------|------|
| `$player_flags` bit `$0100` | Forced walk — skip drift update when set |
| `cameraTargetX/Y`, `cameraDeltaX/Y` | Camera words written each frame |
| `$26` (actor DP) | Previous offset undone before re-roll |

---

### CameraDriftPatterned

**Address:** `$CFEF` · **Size:** 121 bytes + 32-byte data

#### Description

Short-lived patterned drift (~9 frames total): three passes, three frames apart, each adding the next word from `camera_drift_offsets` (index masked to 3 bits — only the first eight signed words are used) to Y then X on `cameraTarget*` / `cameraDelta*`. When actor `$24` = `$FFFF`, the delta update is skipped. The thinker dies after the third pass.

Spawned from Angkor Gorgon, pyramid dangerslide, and Castoth (`awB1_gorgon`, `pyD9_dangerslide_controller`, `ir29_castoth`).

#### Algorithm

```
1. Three drift runs ($2A = 2, 1, 0), $08 = 3 frame gap between runs
2. Each run: read table[index++] → add to Y targets/deltas, then next word → add to X
3. Index AND #7 (8 words); after third run, COP [Die]
```

#### Data: `camera_drift_offsets`

**Address:** `$D068` · **Size:** 32 bytes (16 signed 16-bit words; only indices 0–7 are referenced)

| Format | Signed word offsets consumed one at a time (Y word, then X word) per drift step |

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

Computes a circular offset and writes the caller's `$14`/`$16`. **Two entry points** in one routine:

1. **`ApplyOrbitalOffsetFromRef`** — **Y** = reference actor slot. Copies that actor's `$14`/`$16` into the caller, then falls through.
2. **`ApplyOrbitalOffsetFromRef_AddToCurrent`** — adds the offset to the caller's current `$14`/`$16` (centre must already be set; 5 of 21 JSL sites use this entry).

Reads the low byte of `$7F0010,X` (angle, 256 steps/turn) and `$7F0012,X` (diameter ≤ 255). Offset magnitude ≈ diameter/2 via `sine_table_8bit` / `signed_cosine_table_8bit` (bank `$01`) and `Multiply8x8Unsigned` (bank `$02`). Angle 0 = below centre; increasing angle turns counter-clockwise on screen.

**21 JSL sites** in 11 files (16 first entry, 5 second), including COP `$6D` (`SpiralStep`), `attack_ability_system`, fire sprites, statue inventory, and Castoth orbs.

#### Algorithm

```
1. (First entry only) Copy ref actor $14/$16 → caller $14/$16
2. LDA orbitAngle byte → sin → × diameter >> 8 → add to $14
3. LDA orbitAngle byte → cos → × diameter >> 8 → add to $16
4. RTL
```

#### Variables

| Symbol | Role |
|--------|------|
| Y (first entry) | Reference actor slot for centre copy |
| `$7F0010,X` | Orbit angle (low byte used) |
| `$7F0012,X` | Orbit diameter (low byte used) |
| `$14`, `$16` | Centre + result position |
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

Elliptical offset: **adds** to the caller's current `$14`/`$16` (write the orbit centre there before each call). Four consecutive bytes at `$7F0010,X`: **+0** X angle, **+1** Y angle, **+2** X diameter, **+3** Y diameter (`orbitAngle` / `orbitDiameter` are the word views of the two pairs).

X offset uses `sine_table_8bit[angleX]` × diameterX; Y uses `signed_cosine_table_8bit[angleY]` × diameterY (signed multiply, >> 8).

**3 JSL call sites:** two in `gw8A_sand_fanger`, one in `awB1_goldcap`.

#### Algorithm

```
1. sin(angleX) × diamX → add to $14
2. cos(angleY) × diamY → add to $16
3. RTL
```

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Sin/cos tables | `sine_table_8bit`, `signed_cosine_table_8bit` | Bank `$01` |
| Math helper | `Multiply8x8Unsigned` | Bank `$02` |
| Callers | `gw8A_sand_fanger` (×2), `awB1_goldcap` | JSL |

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
| `gw8A_sand_fanger`, `awB1_goldcap` | `ApplyOrbitalOffsetXY` | JSL (3 sites) |

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
| Highest reference count | `ApplyOrbitalOffsetFromRef` (21 JSL) |
| Block grouping | `camera_drift` (3 functions + `camera_drift_offsets`) |

---

*Source: `extracted/functions/camera_drift.asm`, `extracted/functions/SpawnDebrisBurst.asm`, `extracted/functions/ApplyOrbitalOffsetFromRef.asm`, `extracted/functions/ApplyOrbitalOffsetXY.asm`, `docs/cop/README.md`.*
