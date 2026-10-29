# Bank $00 — Functions: Camera Drift, Ambient Motion & Orbital Math

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00C9B8`–`$00D068`, `$00F3B3`–`$00F432`  
**Source files:** [`extracted/functions/camera_drift.asm`](../../../extracted/functions/camera_drift.asm), [`SpawnDebrisBurst.asm`](../../../extracted/functions/SpawnDebrisBurst.asm), [`ApplyOrbitalOffsetFromRef.asm`](../../../extracted/functions/ApplyOrbitalOffsetFromRef.asm), [`ApplyOrbitalOffsetXY.asm`](../../../extracted/functions/ApplyOrbitalOffsetXY.asm)  
**Block:** `camera_drift` + standalone orbital math functions

Three subsystems share this address region: ambient camera drift loops for boss/ship arenas, debris burst VFX, and sin/cos orbital offset math used by COP handlers, bosses, and decorative actors.

**Related:** [`actors-infrastructure.md`](actors-infrastructure.md) (`camera_scroll_controller`) · [`camera-scroll-system.md`](camera-scroll-system.md) · [`utility-math-movement.md`](utility-math-movement.md) · [`README.md`](README.md)

## Source of truth

| File | Symbols |
|------|---------|
| `extracted/functions/camera_drift.asm` | `CameraDriftLoopSimple`, `CameraDriftLoopShip`, `CameraDriftPatterned`, `camera_drift_offsets` |
| `extracted/functions/SpawnDebrisBurst.asm` | `SpawnDebrisBurst` |
| `extracted/functions/ApplyOrbitalOffsetFromRef.asm` | `ApplyOrbitalOffsetFromRef`, `ApplyOrbitalOffsetFromRef_AddToCurrent` |
| `extracted/functions/ApplyOrbitalOffsetXY.asm` | `ApplyOrbitalOffsetXY` |

**Naming:** All function labels above are **extracted**. `camera_drift_offsets` is **extracted data** (16 words in asm; only indices 0–7 used). Doc names like “camera target” map to **`cameraTargetX/Y`** (`$06BE` / `$06C2`).

**Counts:** JSL / spawn caller counts from `rg` on `extracted/**/*.asm` this session. Drift caller lists follow the block comment in `camera_drift.asm`.

---

## Overview

| Function | Address | Size | Movable | Call Type | Priority |
|----------|---------|------|---------|-----------|----------|
| `CameraDriftLoopSimple` | `$CF8E` | 32 B | ✓ | COP `SpawnAfterFlags` | Medium |
| `CameraDriftLoopShip` | `$CFAE` | 65 B | ✓ | COP `SpawnAfterFlags` | Medium |
| `CameraDriftPatterned` | `$CFEF` | 121 B | ✓ (with data) | COP `SpawnListAppend` (Gorgon, Castoth) / `SpawnAfterFlags` (dangerslide) | Medium |
| `SpawnDebrisBurst` | `$C9B8` | 67 B | ✓ | COP `SpawnAfterFlags` | Medium |
| `ApplyOrbitalOffsetFromRef` | `$F3C9` | 95 B | ✓ | JSL (21 sites) | **High** |
| `ApplyOrbitalOffsetXY` | `$F432` | 93 B | ✓ | JSL (3 call sites) | Medium |
| `CopyRefActorPos_unused` | `$F428` | 10 B | — | None (dead) | — |

---

## Camera drift (script-spawned)

All three live in **`camera_drift.asm`**. Spawned via COP from scene actors/thinkers — **not** placed in `scene_actors.asm`. They add to **`cameraTarget*`** and often **`cameraDelta*`** (layer-1 position words — see file header), which is a different path from **`effectDeltaX/Y`** written by `camera_scroll_controller`.

| Function | Status | Spawn pattern |
|----------|--------|---------------|
| `CameraDriftLoopSimple` | **Live** | `SpawnAfterFlags` |
| `CameraDriftLoopShip` | **Live** | `SpawnAfterFlags` |
| `CameraDriftPatterned` | **Live** | `SpawnListAppend` / `SpawnAfterFlags` |
| `CopyRefActorPos_unused` | **Dead** | — |

### CameraDriftLoopSimple

**Address:** `$CF8E` · **Size:** 32 bytes

#### Description

120-frame random **vertical** nudge (`LoopStart` `#78`). Each pass adds **r = (RngByte & 3) − 1** (−1…+2) to **`cameraTargetY`** and **`cameraDeltaY` only** — **X is untouched**. Offsets are not undone at exit. Callers per asm note: `pyCD_flame_statue`, `ir25_ceiling_tile`, `ir29_castoth`.

Spawned via `COP [SpawnAfterFlags]` from scene thinker/actor scripts that want continuous gentle camera sway without player input.

#### Algorithm

```
1. LoopStart #78 (120 frames)
2. Each pass: r = (RngByte & 3) − 1; cameraTargetY += r; cameraDeltaY += r; LoopEnd
3. Die
```

#### Variables

| Symbol | Role |
|--------|------|
| `cameraTargetY`, `cameraDeltaY` | Only Y words modified |
| Loop counter | 120 frames (~2 s at 60 Hz) |

---

### CameraDriftLoopShip

**Address:** `$CFAE` · **Size:** 65 bytes

#### Description

**120-frame** drift (`LoopStart` `#78`), **Y axis only**, gated by **`playerFlags` bit `$0100`**: when forced walk is set, the pass is skipped (prior offset left in place). When clear: **`cameraDeltaY -= $26`** (undo last frame’s delta tweak), new **`$26 = RngByte & 3`**, then add **`$26`** to **`cameraTargetY`** and **`cameraDeltaY`**. After the loop: one **`SetEntryHereAndYield`**, subtract last **`$26`** from **`cameraDeltaY`**, **`Die`** — not an infinite loop.

Callers: `st68_kara`, `gs2D_lily`, `gs2D_lance`, `gs2B_erik` (asm block note).

#### Algorithm

```
1. $26 := 0; LoopStart #78
2. If playerFlags bit $0100 set → skip pass
3. Else cameraDeltaY -= $26; $26 := RngByte & 3; add $26 to cameraTargetY and cameraDeltaY
4. LoopEnd → yield once → cameraDeltaY -= $26 → Die
```

#### Variables

| Symbol | Role |
|--------|------|
| `playerFlags` bit `$0100` | Forced walk — skip pass when set |
| `cameraTargetY`, `cameraDeltaY` | Y words updated |
| `$26` (actor DP) | Last frame’s 0–3 px offset (undone on delta each pass) |

---

### CameraDriftPatterned

**Address:** `$CFEF` · **Size:** 121 bytes + 32-byte data

#### Description

Short-lived patterned drift (~9 frames total): three passes, three frames apart, each adding the next word from `camera_drift_offsets` (index masked to 3 bits — only the first eight signed words are used) to Y then X on `cameraTarget*` / `cameraDelta*`. When actor `$24` = `$FFFF`, the delta update is skipped. The thinker dies after the third pass.

Spawned from **`awB1_gorgon`**, **`pyD9_dangerslide_controller`**, **`ir29_castoth`** (asm block note — not Comet Lair).

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

## Debris burst (ambient VFX)

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

## Orbital math (live helpers)

**Angle convention (extracted):** 256 steps per turn (~1.406° each). **Angle 0** places the actor **below** the centre (cosine peak — Y grows downward on SNES). **`$40`** = east, **`$80`** = north, **`$C0`** = west; increasing angle moves **counter-clockwise** on screen. **`orbitDiameter`** low byte is full circle width; offset magnitude ≈ **diameter / 2** via `sine_table_8bit` / `signed_cosine_table_8bit` and `Multiply8x8Unsigned`.

### ApplyOrbitalOffsetFromRef

**Address:** `$F3C9` · **Size:** 95 bytes

#### Description

Computes a circular offset and writes the caller's `$14`/`$16`. **Two entry points** in one routine:

1. **`ApplyOrbitalOffsetFromRef`** — **Y** = reference actor slot. Copies that actor's `$14`/`$16` into the caller, then falls through.
2. **`ApplyOrbitalOffsetFromRef_AddToCurrent`** — adds the offset to the caller's current `$14`/`$16` (centre must already be set; 5 of 21 JSL sites use this entry).

Reads the low byte of `$7F0010,X` (angle, 256 steps/turn) and `$7F0012,X` (diameter ≤ 255). Offset magnitude ≈ diameter/2 via `sine_table_8bit` / `signed_cosine_table_8bit` (bank `$01`) and `Multiply8x8Unsigned` (bank `$02`). Angle 0 = below centre; increasing angle turns counter-clockwise on screen.

**21 JSL sites** in **11 files** (**16** `ApplyOrbitalOffsetFromRef`, **5** `ApplyOrbitalOffsetFromRef_AddToCurrent`) — verified with `rg 'JSL \$@ApplyOrbitalOffsetFromRef'` on `extracted/`.

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
| `CameraDriftPatterned` | Gorgon, dangerslide, Castoth | `SpawnListAppend` (Gorgon, Castoth) / `SpawnAfterFlags` (dangerslide); table-driven |

### Orbital callers (JSL matrix)

| File | Entry | Calls |
|------|-------|-------|
| `attack_ability_system.asm` | both | 2 |
| `mtA1_fire_sprite.asm` | base + AddToCurrent | 5 |
| `unused_mode7_boss.asm` | base + AddToCurrent | 6 |
| `cop_handlers_effects.asm` (SpiralStep) | base | 1 |
| `ir29_castoth.asm` | base | 1 |
| `pyDD_queen_orb_shot.asm` | base | 1 |
| `pyDD_queen_spirit_attack.asm` | AddToCurrent | 1 |
| `ec0E_lily.asm`, `btE4_kara.asm`, `item_use_system.asm`, `statue_inventory_reward.asm` | base | 1 each |
| `gw8A_sand_fanger.asm` | `ApplyOrbitalOffsetXY` | 2 |
| `awB1_goldcap.asm` | `ApplyOrbitalOffsetXY` | 1 |

`unused_mode7_boss.asm` counts toward JSL totals but is **unused** content in the extracted ROM layout.

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

## Source validation

**Files checked:** `camera_drift.asm`, `SpawnDebrisBurst.asm`, `ApplyOrbitalOffsetFromRef.asm`, `ApplyOrbitalOffsetXY.asm`, caller `.asm` files via `rg`.

**Verified:** `CameraDriftLoopSimple` / `Ship` **Y-only** semantics; Ship **120-frame** loop + final delta undo (not infinite); **`playerFlags` `$0100`** gate on Ship; `camera_drift_offsets` **16 words**, **8 used** (mask `#7`); **21** + **3** JSL counts; debris **4** COP spawn sites; orbital angle convention from `ApplyOrbitalOffsetFromRef.asm` header.

**Notes:** `StopPlayerOnDeath.asm` is listed in the header line of this doc’s older revision but is **out of scope** for camera motion — not documented here. Whether drift offsets survive `camera_scroll_controller` target refresh is **not established statically** (per `camera_drift.asm` comment).

*Primary sources: `extracted/functions/camera_drift.asm`, `SpawnDebrisBurst.asm`, `ApplyOrbitalOffsetFromRef.asm`, `ApplyOrbitalOffsetXY.asm`.*
