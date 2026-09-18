# Mode 7 & Cutscenes

> The Mode 7 rotation/scaling engine and the HDMA iris generator, plus the two
> scene-specific cutscene actors that drive them. Includes one confirmed-dead
> alternate Mode 7 implementation.

*Part of the [Bank $03 Documentation Suite](readme.md)*

## Parts in this category

| Part | Range | Source |
|------|-------|--------|
| mode7_perspective | `$03A940`–`$03AB88` | [mode7_perspective.asm](../../../extracted/thinkers/mode7_perspective.asm) |
| mode7_perspective_unused | `$03AB88`–`$03AD77` | [mode7_perspective_unused.asm](../../../extracted/unused/mode7_perspective_unused.asm) |
| IrisCircleEffect | `$03A6BA`–`$03A83E` | [IrisCircleEffect.asm](../../../extracted/prologue/prologue_prophecy/IrisCircleEffect.asm) |
| garden_crash_cutscene | `$03A0AA`–`$03A1FA` | [garden_crash_cutscene.asm](../../../extracted/sky_garden/garden_crash/garden_crash_cutscene.asm) |
| future_vision_cutscene | `$03A1FA`–`$03A2F1` | [future_vision_cutscene.asm](../../../extracted/angkor_wat/future_vision/future_vision_cutscene.asm) |

> **Note on the blocks.json block `mode7_perspective`:** it spans
> `$03A940`–`$03AD77`, but only `$03A940`–`$03AB88` is the active implementation;
> `$03AB88`–`$03AD77` is the separate `mode7_perspective_unused` source unit.

## Overview

This category is the game's Mode 7 special-effects toolkit. `mode7_perspective` is
a thinker that computes per-scanline rotation/scaling matrices and queues them as
HDMA tables for the M7A–M7D registers, producing the perspective-rotation look.
`IrisCircleEffect` is a companion HDMA thinker that builds a circular window
gradient (spotlight/iris). Two scene actors —
`garden_crash_cutscene` (Sky Garden fall) and `future_vision_cutscene`
(Angkor Wat vision) — set up the PPU for Mode 7 color math, spawn the perspective
thinker, and choreograph their sequences frame-by-frame.
`mode7_perspective_unused` is an earlier, unreferenced variant kept for reference.

**Related:** [radar-and-world-map.md](radar-and-world-map.md) (HdmaWindowEffect comparison; world map scene uses Mode 7) · [actor-thinker-runtime.md](actor-thinker-runtime.md) (thinker spawn/execution) · [scene-and-hardware.md](scene-and-hardware.md) (Mode 7 register setup, scene transitions)

---

## mode7_perspective — `$03A940`–`$03AB88`

Source: [mode7_perspective.asm](../../../extracted/thinkers/mode7_perspective.asm)

**Type:** `thinker-def`.

### Purpose

Thinker (type `$04`, priority `$08`) generating per-scanline Mode 7 rotation/
scaling matrices, queued as HDMA tables for M7A/M7B/M7C/M7D (`$211B`–`$211E`).
Drives the perspective-rotation effect on the world map, prologue prophecy,
Sky Garden crash, and Angkor Wat future vision.

### Initialization (`Mode7PerspectiveInit`)

Sets `M7SEL = $80` (repeat playfield). Loads initial position from `$0D54`/`$0D56`,
centers camera (X−`$80`, Y−`$70`) with scroll-override flags. Initializes
`$B6 = 0` (rotation angle), `$BC = 0` (perspective parameter), `$B8 = $0400`
(base scale).

### Per-frame update (`Mode7PerspectiveUpdate`)

- **Phase 1** — fill three 224-entry HDMA tables (`$7E7000`, `$7E7800`, `$7E8000`)
  with 1-scanline defaults; yield.
- **Phase 2** — matrix computation: index sine (`binary_01C595`) and cosine
  (`binary_01C695`) tables by `$BC × 2`; dispatch to one of four quadrant handlers
  by sine/cosine sign; `NormalizeDivisor` right-shifts until the scale divisor fits
  8 bits; per-scanline hardware 16÷8 divide (`WRDIV`/`RDDIV`) yields cos/scale and
  sin/scale; adaptive overflow halving preserves the ratio.
- **Phase 3** — `QueueMode7HdmaTables`: queue 4 HDMA channels (`$7E7000`→M7A,
  `$7E7800`→M7B, `$7E8000`→M7C, `$7E7000`→M7D).

### Rotation matrix

| Register | Value | HDMA table |
|----------|-------|-----------|
| M7A (`$211B`) | cos θ / scale | `$7E7000` |
| M7B (`$211C`) | sin θ / scale | `$7E7800` |
| M7C (`$211D`) | −sin θ / scale | `$7E8000` |
| M7D (`$211E`) | cos θ / scale | `$7E7000` |

### Actor/thinker fields

| Field | Meaning |
|-------|---------|
| `$B6` | rotation angle (per-scanline rotation increment) |
| `$B8` | base scale factor (hardware divide divisor; e.g. `$0400` = base distance) |
| `$BC` | perspective rotation index (0–511, indexes into sine/cosine tables) |
| `$00CA` | world X position / Mode 7 scroll center X |
| `$00CC` | world Y position / Mode 7 scroll center Y |
| `$7F0B22` | Mode 7 config flag A (initialized to `$FFFF`) |
| `$7F0B24` | Mode 7 config flag B (initialized to `$FFFF`) |
| `$7F000E` | animScratch2 — thinker type/filter flags (set to `$0804` by cutscenes) |

### Key routines

| Address | Label | Role |
|---------|-------|------|
| `$03A940` | `Mode7PerspectiveInit` | `thinker-def` entry: set `M7SEL=$80`, scroll overrides, initial params |
| `$03A985` | `Mode7PerspectiveUpdate` | per-frame: init 224-entry HDMA tables, then compute rotation matrix |
| `$03AA12` | `QueueMode7HdmaTables` | RTS-trick target: queue 4 HDMA channels (M7A/B/C/D) via `COP QueueDma` |
| `$03AA2D` | `Mode7Quadrant_PosCosPosSin` | quadrant 1: +cos, +sin → M7A=cos/s, M7B=sin/s, M7C=−sin/s |
| `$03AA7E` | `Mode7Quadrant_PosCosNegSin` | quadrant 2: +cos, −sin (sin negated via EOR/INC) |
| `$03AACF` | `Mode7Quadrant_NegCosPosSin` | quadrant 3: −cos, +sin (cos negated) |
| `$03AB22` | `Mode7Quadrant_NegCosNegSin` | quadrant 4: −cos, −sin (both negated) |
| `$03AB75` | `NormalizeDivisor` | right-shift scale/cos/sin until divisor fits 8 bits for WRDIVB |

### Sine/cosine table format

Two 512-entry signed word tables stored in bank `$01`:

| Table | Address | Content |
|-------|---------|---------|
| `binary_01C595` | `$01C595` | sine values (512 entries × 2 bytes = 1024 bytes) |
| `binary_01C695` | `$01C695` | cosine values (512 entries × 2 bytes) |

Indexed by `($BC AND $01FF) × 2` (word-sized lookup). The 512-step period gives
`~0.7°` per step. Negative values indicate the respective quadrant sign.

### `$0804` params (animScratch2)

Both `GardenCrashCutscene` and `FutureVisionCutscene` write `$0804` into the
spawned thinker's `animScratch2` (`$7F000E,X`). This value serves as the thinker's
filter-type tag: bit 2 (`$0004`) makes it a TypeB thinker (deferred dispatch after
TypeA), and bit 11 (`$0800`) marks it as cutscene-eligible (TypeC/D). The
combination `$0804` = bits 2 + 11 set means the thinker runs in the TypeD slot
(cutscene deferred), ensuring Mode 7 HDMA tables are computed after primary
cutscene logic has set the rotation/scale/position parameters for the current frame.

### Per-scanline computation detail

Each quadrant handler runs a 224-iteration loop:
1. Load divisor (`$02` = scale) → Y
2. `LDA |cos|` → `WRDIVL`; `STY WRDIVB` — triggers 16÷8 hardware divide
3. 6× `NOP` (wait ~16 cycles for divider)
4. Read `RDDIVL` → write cos/scale to `$7E7000` table (M7A)
5. `LDA |sin|` → `WRDIVL`; `STY WRDIVB` — second divide
6. Read `RDDIVL` → write to `$7E7800` (M7B); negate → `$7E8000` (M7C)
7. Accumulate rotation: `$04 + $01 → $01` (perspective foreshortening per scanline)
8. On carry overflow: halve cos, sin, divisor, and angle to prevent overflow

---

## mode7_perspective_unused — `$03AB88`–`$03AD77`  *(dead code)*

Source: [mode7_perspective_unused.asm](../../../extracted/unused/mode7_perspective_unused.asm)

**Type:** `Code`, `movable: true`. **Never referenced** by any scene actor,
thinker spawn, or COP handler in the shipped ROM.

### Purpose

An earlier/alternate Mode 7 perspective implementation. Uses the same sine/cosine
tables and 4-quadrant hardware-divide approach but differs significantly from the
active version:

1. **HDMA table format** — 3-entry indirect HDMA headers (three `$F0` counts at
   offsets 0/3/6) with WRAM data addresses; matrix data fills `$7E7100`/`$7E7900`/
   `$7E8100` separately.
2. **Fill direction** — X starts at `$01C0` and decrements (high→low), vs. the
   active version filling low→high.
3. **Perspective direction** — subtracts the rotation increment (inverting
   foreshortening) instead of adding.
4. **No `NormalizeDivisor`** — scale > 255 would truncate the divisor → wrong
   results.
5. **Underflow handling** — borrow-based (`BCC`/`DEC`) vs. carry-based.
6. **DMA command** — `QueueHdma` instead of `QueueDma`.
7. **NOP count** — quadrants 3/4 use only 4 delay NOPs (vs. 6), risking early
   reads of the hardware divide.

Likely superseded during development due to the missing divisor normalization and
simpler per-scanline table format.

### Key routines (dead code)

| Address | Label | Role |
|---------|-------|------|
| `$03AB88` | `Mode7PerspectiveAlt` | alternate thinker entry (unreferenced) |
| `$03AC38` | `QueueMode7HdmaAlt` | HDMA queue (uses `QueueHdma` instead of `QueueDma`) |
| `$03AC53` | `Mode7AltQ1_PosCosPosSin` | quadrant 1 (4 NOP delays instead of 6) |
| `$03AC9B` | `Mode7AltQ2_PosCosNegSin` | quadrant 2 |
| `$03ACE3` | `Mode7AltQ3_NegCosPosSin` | quadrant 3 |
| `$03AD2D` | `Mode7AltQ4_NegCosNegSin` | quadrant 4 |

### Notes

Historical reference only — do not wire into scenes. The missing
`NormalizeDivisor` call means scales above 255 would silently truncate the
8-bit divisor, producing incorrect rotation matrices. The reduced NOP count in
quadrants 3/4 (4 instead of 6) risks reading `RDDIVL` before the hardware
divider has completed, yielding stale or partial results.

---

## IrisCircleEffect — `$03A6BA`–`$03A83E`

Source: [IrisCircleEffect.asm](../../../extracted/prologue/prologue_prophecy/IrisCircleEffect.asm)

**Type:** `thinker-def`, `movable: true`.

### Purpose

Thinker (type `$04`, priority `$08`) generating a circular-window HDMA table each
frame via hardware multiply. Double-buffered: odd frames → `$7E8D00`, even frames
→ `$7E8E00`. Used in the prologue prophecy scene (`$8C`) and the world map (`$FE`)
for spotlight/iris transitions.

### Circle algorithm

Radius controlled by actor field `$B6`:
- base radius = `$0400` − (`$B6` / 2)
- step decrement per band = base × 2 → `$0E`
- initial circle value = base × 32 → `$00`

For each of 16 scanline bands (X from `$1E` down to `$00`, 2 bytes/entry):
1. 16×8 hardware multiply `circle_value × $60` (WRMPYA/WRMPYB).
2. Two 8×8 multiplies (low then high) with NOP delays for latency.
3. High byte (`$04`) = scanline count (window half-width for the band).
4. Write HDMA entry: scanline count at `$8D00,X`, right edge at `$8D01,X`.
5. Accumulate scanline count (`$08`); handle overflow past 255.
6. Right edge (`$06`) starts at `$E0`, increments by 1 per band.
7. Subtract step (`$0E`) from circle_value — each band narrower.

As `$B6` grows, the radius shrinks and the iris closes.

### HDMA table format

Each 2-byte entry: byte 0 = scanline count, byte 1 = window right edge. Terminated
by `$E07F` sentinel + `$0000` padding. Passed to `SetupHdmaChannel_Direct` with
register `$32`, bank `$7E`.

### Key routines

| Address | Label | Role |
|---------|-------|------|
| `$03A6BA` | `IrisCircleEffect` | `thinker-def` entry: frame parity check → odd/even buffer path |
| `$03A6CA` | *(odd-frame body)* | multiply loop → `$7E8D00` buffer |
| `$03A784` | `IrisCircleEvenFrame` | same algorithm → `$7E8E00` buffer |

### Overflow handling

The running scanline accumulator `$08` tracks total scanlines consumed. When
adding a band's count causes carry (total > 255), the overflow handler at
`$03A76F` subtracts the excess from the last band's scanline count and writes
the final right-edge without incrementing `$06`. This ensures the HDMA table
never exceeds the 224/240 visible scanline limit.

### Comparison with HdmaWindowEffect

`IrisCircleEffect` generates a **circular** window using hardware multiply
(`WRMPYA`/`WRMPYB`) with a fixed multiplier `$60` and per-band subtraction for
curvature. `HdmaWindowEffect` (at `$03A83E`) instead uses a **sine-table-based**
approach for smoother, arbitrary window shapes with configurable parameters.
Both are HDMA-driven window generators, but IrisCircle is simpler and dedicated
to the circular iris/spotlight look, while HdmaWindowEffect is more general.

### Double-buffer timing

Odd frames write to `$7E8D00`, even frames to `$7E8E00`. The HDMA channel
always reads from one buffer while the thinker fills the other. This prevents
tearing — each buffer is fully computed before the next VBlank reads it.

---

## garden_crash_cutscene — `$03A0AA`–`$03A1FA`

Source: [garden_crash_cutscene.asm](../../../extracted/sky_garden/garden_crash/garden_crash_cutscene.asm)

**Type:** `actor-def`, `movable: true`, scene `$59` (garden_crash).

### Purpose

Actor orchestrating the Sky Garden plummet. Uses the active `mode7_perspective`
thinker for per-scanline rotation/scaling and a companion camera controller.

### Architecture

- `GardenCrashCutscene` — main actor-def; Mode 7 setup + spawns companions.
- `CrashCameraController` — companion thinker (SpawnBefore); camera scroll +
  gravity + scene transition.
- `GardenCrashExitPhase` — terminal animation after the camera signals completion.
- `CrashDebrisSfx` — 6-frame random SFX burst during the gravity phase.

### Rendering setup

`M7SEL=$00`, `TS=$01` (BG1 main only), `CGADSUB=$01` (add on BG1), `CGWSEL=$82`,
joypad masked (`$FFF0` → `joypadMaskStd`).

### Timeline

1. Init: spawn `Mode7PerspectiveUpdate` (params `$0804`), spawn
   `CrashCameraController`, position at camera center.
2. Approach (600 frames): camera scrolls up 2px/frame, rotation angle `$0200`,
   scale from `$0032`.
3. Signal: controller sets flag byte `#01` after timer; 60 more frames.
4. Gravity: `InitGravity(0,5,0)` accelerates scale via `TickGravity`.
5. Impact: when scale ≥ `$0500`, set game flag `$0AA6`, load post-crash gfx
   (`$0404` → `gfxCacheIdxB`), `QueueMapChange` to scene `$58`.
6. Post-transition: continued gravity + scroll for a smooth exit.
7. Debris SFX: 6 random bursts (sound `#15`).

### Key routines

| Address | Label | Role |
|---------|-------|------|
| `$03A0AA` | `GardenCrashCutscene` | `actor-def` entry: PPU init, thinker spawn, animation loop |
| `$03A109` | `GardenCrashExitPhase` | terminal phase: 30-frame fadeout tracking camera Y+`$B4` |
| `$03A120` | `CrashCameraController` | companion thinker: 3-phase (approach → signal → gravity) |
| `$03A1E9` | `CrashDebrisSfx` | 6-iteration random SFX actor (sound #15, mask `$1C`) |

### Camera Y-center math

The camera controller computes the Mode 7 Y center each frame as:

```
$00CC = (cameraTargetY AND $03FF) + $70
```

`AND $03FF` masks to a 10-bit value (0–1023), matching the Mode 7 playfield
coordinate range. Adding `$70` (112 pixels = half the 224-scanline screen height)
centers the rotation origin vertically. This value is written to `$00CC`, which
`Mode7PerspectiveUpdate` uses as the scroll center Y for HDMA table generation.

### Phase details

**Phase 1 (Approach, 600 frames):** Camera scrolls up at 2px/frame
(`cameraTargetY -= 2`). Mode 7 params: rotation `$0200`, scale `$0032` (50),
perspective 0. The actor positions at `cameraTargetX + $80` (X center) and cycles
a two-yield animation loop. Flag byte #01 check each frame — CrashCameraController
sets this when the timer expires.

**Phase 2 (Signal, 60 frames):** Camera controller sets flag byte #01 →
GardenCrashCutscene enters `GardenCrashExitPhase`. Controller continues scrolling
for 60 more frames, then spawns `CrashDebrisSfx` with `$2000` flags.

**Phase 3 (Gravity):** `InitGravity(0, 5, 0)` starts vertical acceleration.
Each frame: `TickGravity` updates `moveScratch2`; velocity added to Mode 7 scale
`$B8`. The garden appears to rush closer as scale ramps. When `$B8 ≥ $0500`:
set `$0AA6 = 1` (game flag), `gfxCacheIdxB = $0404`, `QueueMapChange` to scene
`$58`. Post-transition, gravity + scroll continue for a smooth visual exit.

---

## future_vision_cutscene — `$03A1FA`–`$03A2F1`

Source: [future_vision_cutscene.asm](../../../extracted/angkor_wat/future_vision/future_vision_cutscene.asm)

**Type:** `actor-def`, `movable: true`, scene `$C0` (future_vision).

### Purpose

Plays a prophetic Mode 7 vision of Earth's future. Shares the garden-crash
Mode 7 setup (identical PPU config + `Mode7PerspectiveUpdate` spawn with `$0804`),
but drives a different camera choreography via `FutureVisionController`.

### Architecture

- `FutureVisionCutscene` — minimal actor-def: Mode 7 init, thinker spawns
  (including `oneshot_palette_flash_19`), immediate yield.
- `FutureVisionController` — companion thinker (SpawnBefore) driving the 5-phase
  sequence.

### Timeline

1. Zoom-in + rotate (~200 frames): camera (`$0170`,`$01D0`), M7 center
   (`$01F0`,`$0250`); scale `$1C`→`$80` at half speed; perspective (`$BC`)
   increments every frame from `$0130`.
2. Complete rotation: increment `$BC` until (`$BC & $01FF`) == 0.
3. Pause + zoom-out + scroll (119 + ~32 frames): `WaitByte $77`, then zoom
   `$80`→`$60` while incrementing rotation (`$B6`) and scrolling down 2px/frame.
4. Long scroll up (255+128+127 frames): scroll `cameraTargetY`/`$CC` up 1px/frame;
   the final 127-frame loop adds a 16-step brightness fade via
   `INIDISP = (loopCounter & $78) >> 3`.
5. Transition: `QueueMapChange` to scene `$BF` at (`$00F8`,`$00C0`), flags `$2200`;
   `gfxCacheIdxA = $01` (instant blank), `gfxCacheIdxB = $0400`.

### Brightness fade

During the final loop: `loopCounter & $0078` (bits 3–6, 8-frame granularity),
`LSR ×3` → brightness 15→0, each level held 8 frames (smooth 16-step fade).

### Key routines

| Address | Label | Role |
|---------|-------|------|
| `$03A1FA` | `FutureVisionCutscene` | `actor-def` entry: PPU init, thinker spawns, idle yield |
| `$03A22E` | `FutureVisionController` | companion thinker: 5-phase sequence driver |

### Palette-flash thinker

`FutureVisionCutscene` spawns `oneshot_palette_flash_19.code_00B7D8` as a separate
thinker during init. This produces a dramatic white-flash effect at the vision's
start by cycling palette entries rapidly for a few frames, then dying automatically.
`GardenCrashCutscene` does not use a palette flash.

### Shared setup pattern with garden_crash

Both cutscene actors follow an identical PPU initialization sequence:

| Step | Garden Crash | Future Vision |
|------|-------------|---------------|
| joypad mask | `$FFF0` → `joypadMaskStd` | `$FFF0` → `joypadMaskStd` |
| M7SEL | `$00` | `$00` |
| layer enable | `TS = $01` (BG1 sub) | `TM = $01` (BG1 main) |
| color math add | `CGADSUB = $01` | `CGADSUB = $01` |
| color math mode | `CGWSEL = $82` | `CGWSEL = $82` |
| thinker params | `$0804` → animScratch2 | `$0804` → animScratch2 |

The only difference is `TS` vs. `TM` — garden crash enables BG1 on the sub screen,
future vision on the main screen. Both spawn `Mode7PerspectiveUpdate` with
identical params. A common helper was not factored out in the shipped code.

### Phase detail (FutureVisionController)

**Phase 1 — Zoom-in + rotate (~200 frames):** Camera at (`$0170`,`$01D0`), M7
center (`$01F0`,`$0250`). Scale starts at `$1C`, perspective at `$0130`. Each
frame: `INC $BC` (rotate). On even frames only (`$0036 & 1 == 0`): `INC $B8`
(zoom in). Runs until scale reaches `$0080` — approximately 200 frames at
half-speed (odd frames skip the zoom increment).

**Phase 2 — Full rotation:** New yield via `SetEntryContinue`. Each frame:
`INC $BC`. Exits when `($BC AND $01FF) == 0` — a complete 512-step rotation has
been performed.

**Phase 3 — Hold + zoom-out + scroll:** `WaitByte $77` (119-frame pause). Then per
frame: `DEC $B8` (zoom out), `INC $B6` (spin), camera + M7 center scroll down at
2px/frame. Exits when scale reaches `$0060` (~32 frames).

**Phase 4 — Long upward scroll + brightness fade:** Three nested loops:
- 255 frames: camera up 1px/frame
- 128 frames: continued scroll
- 127 frames: scroll + INIDISP brightness fade. `loopCounter AND $0078` extracts
  bits 3–6; `LSR ×3` produces values 15→0 at 8-frame granularity. Each brightness
  level is held for 8 frames, giving a smooth 16-step fade to black.

**Phase 5 — Scene transition:** `QueueMapChange` to scene `$BF` at
(`$00F8`,`$00C0`), flags `$2200`. Graphics cache: `gfxCacheIdxA = $0001` (instant
blank type), `gfxCacheIdxB = $0400`. Final `SetEntryContinue` + `RTL` ends the
controller.

---

## Category-wide notes

**Shared Mode 7 color-math pattern:** Both cutscenes use `M7SEL=$00`,
`CGADSUB=$01`, `CGWSEL=$82` to configure Mode 7 with color addition on BG1. The
`$82` value sets: bit 7 = sub-screen backdrop enabled, bit 1 = color math on
BG1 and OBJ. This is the standard Quintet color-math setup for Mode 7 rotation
effects — no color subtraction, fixed sub-screen color provides the background
tint.

**Scene→thinker mapping:**

| Scene | Thinker spawned |
|-------|-----------------|
| `$59` (garden_crash) | `Mode7PerspectiveUpdate` (cutscene actor) |
| `$C0` (future_vision) | `Mode7PerspectiveUpdate` + `oneshot_palette_flash_19` (cutscene actor) |
| `$8C` (prologue_prophecy) | `IrisCircleEffect` (scene thinker `thinker_spawn_0CEB2A`); `Mode7PerspectiveUpdate` (prologue actors) |
| `$FE` (world_map) | `Mode7PerspectiveInit` + `IrisCircleEffect` (scene thinker `thinker_spawn_0CEB3D`) |
| `$FE` (world_map travel) | `HdmaWindowEffect` (WorldMapController during travel) |

`Mode7PerspectiveInit`/`Mode7PerspectiveUpdate` are spawned by cutscene actors in
scenes `$59` and `$C0`, by prologue actors in scene `$8C`, and by the scene thinker
table (`thinker_spawn_0CEB3D`) in world map scene `$FE`. `IrisCircleEffect` is
spawned by scene thinker tables in scenes `$8C` and `$FE` (`thinker_spawn_0CEB2A`
and `thinker_spawn_0CEB3D` respectively). WorldMapController spawns
`HdmaWindowEffect` during route travel, not `IrisCircleEffect`.

---

## See Also

- [radar-and-world-map.md](radar-and-world-map.md) — world map scene $FE uses both Mode 7 perspective and IrisCircleEffect thinkers
- [actor-thinker-runtime.md](actor-thinker-runtime.md) — thinker execution pipeline, `SpawnSceneThinkers` spawns Mode 7 / iris thinkers
- [scene-and-hardware.md](scene-and-hardware.md) — `ClearSceneState` configures Mode 7 registers; HDMA channel management
- [Bank $03 index](readme.md) — bank-wide memory map, WRAM reference, design patterns
