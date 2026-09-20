# COP family: Movement / staged

_Deep-audited ops: `[22]`, `[43]`, `[4A]`, `[52]`, `[53]`_

[← COP index](../index.md)

## Overview

Smooth interpolated movement toward a pre-written target, optional grid snapping via a helper script, and a two-opcode staged move pipeline with sub-pixel stepping. Targets live in `$7F0018`/`$7F001A` (`moveXAlt` / `moveYAlt`) and must be set before `[22]` or `[52]`.

## Shared state

| Symbol | Role |
|--------|------|
| `$7F0018,X` / `$7F001A,X` | Movement destination X/Y (pixel) |
| `$7F002A,X` bit 1 | Smooth-move active (`MoveToward`) |
| `$7F1018,X` / `$7F101A,X` | Grid-snap resume PC + bank (`SnapToGrid` / `ResumeAfterSnap`) |
| `$7F002C`–`$7F002E,X` | Per-frame X/Y velocity scratch (`moveScratch1` / `moveScratch2`) |
| `$7F0000`–`$7F000F,X` | Interpolation accumulators, anim delay, tick limit |
| `$24` | MoveToward / TickMove frame tick counter |
| `EnemyPositionSnap` | Grid-alignment helper entered from `[43]` |

## Family notes

- `[22]` is **multi-frame**: first entry runs `InitSmoothMovement`, then each tick interpolates via hardware multiply/divide until the tick counter reaches the duration operand; finishes in `MoveTowardFinish` (RTL).
- `[52]` then `[53]` are a **pair**: `[52]` computes frame count from distance ÷ speed (with optional distance halving passes), `[53]` advances one frame per actor tick until complete.
- `[43]` then `[4A]` pair with `EnemyPositionSnap`: `[43]` RTI-redirects into the snap helper when not 16×16 aligned; the helper loops `[22]` and ends with `[4A]`.
- Animation operand `#$FF` on `[22]` / `[52]` keeps the current animation index (`$28`).

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `22` | `MoveToward` | 108 | Byte anim, Byte frames | `MoveToward` | Halt (RTL each frame until done) |
| `43` | `SnapToGrid` | 5 | (none) | `SnapToGrid` | Continue or RTI→snap helper |
| `4A` | `ResumeAfterSnap` | 1 | (none) | `ResumeAfterSnap` | Continue |
| `52` | `StageMove` | 32 | Byte anim, Byte speed, Byte delay | `StageMove` | Continue |
| `53` | `TickMove` | 32 | (none) | `TickMove` | Halt (RTL until staged path done) |

**Family call-site total:** 178

## Opcodes

#### COP [22] — `MoveToward` (interpolate toward target)

- **Preferred name:** `MoveToward`
- **Handler:** `MoveToward` @ `extracted/system/engine/cop_handlers_movement.asm`
- **Pairs with:** Pre-written `$7F0018`/`$7F001A`; often `[43]`/`[4A]` via `EnemyPositionSnap`
- **Parameters:** `Byte` animation index (`#$FF` = keep `$28`), `Byte` duration in movement ticks

##### What it does (exact semantics)

1. **First entry** (`extendedFlags` bit 1 clear): `InitSmoothMovement` reads operands, optionally updates animation via `ProcessAnimFlag`, converts `moveXAlt`/`moveYAlt` from absolute targets to signed deltas (capped at `$FE` per axis), stores direction bits in `animScratch2`, divides the larger axis distance by the frame-count byte for per-tick velocity, zeros accumulators and `$24`, sets `extendedFlags` bit 1.
2. **Each subsequent tick:** Compares masked tick limit in `animScratch2` to `$24`. When equal → `MoveTowardFinish` clears bit 1, skips operands, RTL.
3. **Interpolation:** For each axis, `MultiplyThenDivide` computes expected position at tick `$24`, subtracts accumulator → signed delta stored in `moveScratch1`/`moveScratch2` (applied by the movement engine outside this handler). Waits on `UpdateActorAnimation` when the anim sub-counter expires, increments `$24`, **RTL** (yield).

```asm
; Handler (core loop — see also InitSmoothMovement / MoveTowardFinish)
MoveToward {
    TYX
    LDA $extendedFlags, X
    BIT #$0002
    BNE loc_008C7C
    JSR $&InitSmoothMovement
  loc_008C7C:
    ; ... tick compare → MoveTowardFinish or per-axis velocity + RTL
}
```

##### How it is used in source (patterns)

**Pattern A — Cutscene / boss glide**  
Set destination in WRAM or via position ops, then slow `[22]`:

```asm
; ending/ending_comet/sE5_epilogue.asm
COP [MoveToward] ( #1F, #01 )
```

**Pattern B — Grid snap helper (max speed, 1 tick)**  
`EnemyPositionSnap` writes rounded tile centers to `moveXAlt`/`moveYAlt` and calls `[22]` until aligned:

```asm
; functions/EnemyPositionSnap.asm
COP [MoveToward] ( #FF, #01 )
; ...
COP [ResumeAfterSnap]
```

**Pattern C — Enemy AI approach**  
Common in Angkor Wat, Great Wall, Mu lairs — `#FF` anim + `#02` frames for short steps toward player or waypoints (`awB1_gorgon.asm`, `mu67_vampires.asm`, etc.).

##### Parameters & return contract

| Item | Value |
|------|-------|
| Opcode | `$22` |
| Asm form | `COP [MoveToward] ( #anim, #frames )` |
| Preconditions | `moveXAlt`/`moveYAlt` = destination pixels |
| Side effects | `extendedFlags` bit 1; `$24`, `animScratch*`; may change `$28` |
| Completion | `MoveTowardFinish` → RTL with resume PC past operands |
| Source examples | `sE5_epilogue.asm:111`, `EnemyPositionSnap.asm:54`, `sE8_dark_gaia.asm:716` |

---

#### COP [43] — `SnapToGrid` (start grid alignment)

- **Preferred name:** `SnapToGrid`
- **Handler:** `SnapToGrid` @ `cop_handlers_movement.asm`
- **Parameters:** (none)

##### What it does

Clears movement deltas `$2C`/`$2E`. If `(($14−8) \| $16) & $0F = 0` (already on 16×16 grid), RTI-continues. Otherwise saves `$0A` → `snapResumePtr` and bank → `$7F101A`, then **RTI** into `EnemyPositionSnap` (far entry). The helper eventually executes `[4A]`.

```asm
SnapToGrid {
    TYX
    STZ $2C
    STZ $2E
    LDA $14
    SEC
    SBC #$0008
    ORA $16
    AND #$000F
    BEQ loc_008E14          ; aligned → continue
    ; save PC/bank, RTI → EnemyPositionSnap
}
```

##### How it is used

Bosses and platform enemies that must interact with tile-aligned collision (`sg4D_cyber.asm`, `ec0C_ribber.asm`, `av6D_steelbones.asm`) call `[43]` before attacks or jumps so subsequent solid tests hit grid centers.

##### Parameters & return contract

| Item | Value |
|------|-------|
| Outcome | Aligned: Continue (RTI). Not aligned: redirect to snap helper |
| Resume | `[4A]` restores PC from `snapResumePtr` |
| Source examples | `ec0C_ribber.asm:60`, `sg4D_cyber.asm:368` |

---

#### COP [4A] — `ResumeAfterSnap` (restore PC after grid snap)

- **Preferred name:** `ResumeAfterSnap`
- **Handler:** `ResumeAfterSnap` @ `cop_handlers_movement.asm`
- **Parameters:** (none)

##### What it does

Restores script PC from `$7F1018,X` and bank from `$7F101A,X` into the COP stack frame, clears both slots, RTI.

##### How it is used

Only emitted from `EnemyPositionSnap` when alignment completes (`functions/EnemyPositionSnap.asm:61`). Scripts do not call it directly in normal flow.

##### Parameters & return contract

| Item | Value |
|------|-------|
| Outcome | Continue at saved PC |
| Must follow | `[43]` + snap helper path |

---

#### COP [52] — `StageMove` (init staged movement)

- **Preferred name:** `StageMove`
- **Handler:** `StageMove` @ `cop_handlers_movement.asm`
- **Pairs with:** `[53]` `TickMove` (required for motion)
- **Parameters:** `Byte` anim (`#$FF` = keep), `Byte` speed (≥ `$80` treated as negative magnitude), `Byte` anim frame delay (high byte of internal counter via `XBA`)

##### What it does

Computes signed deltas from `moveXAlt`/`moveYAlt` to `$14`/`$16`, stores direction in `animScratch2` bits 14–15, optionally **halves** both distances in a loop until they fit in one byte (`HalveMovementDistance` / `chatPtr` pass counter). Divides distance by speed via hardware divider → frame count (+1), merges direction bits, may halve again if divide carry set. Zeros accumulators and `$24`, RTI **without** yielding — caller must invoke `[53]`.

##### How it is used

**Gorgon boss** — after RNG placement, `[52]`/`[53]` lunge then sprite loop moves:

```asm
; angkor_wat/awB1_gorgon.asm
STA $moveYAlt, X          ; target already in WRAM
COP [StageMove] ( #18, #04, #FF )
COP [TickMove]
```

Same pattern for minion spawn scripts at `#09`–`#0B` with speed `#06`.

##### Parameters & return contract

| Item | Value |
|------|-------|
| Preconditions | `moveXAlt`/`moveYAlt` destination pixels |
| Next opcode | `[53]` on same or following script lines |
| Side effects | `animScratch2`, `chatPtr`, `moveXAlt`/`moveYAlt` become absolute distances |
| Source examples | `awB1_gorgon.asm:254-255`, `awB1_goldcap.asm:190-191` |

---

#### COP [53] — `TickMove` (advance staged move one frame)

- **Preferred name:** `TickMove`
- **Handler:** `TickMove` / `TickMoveComplete` @ `cop_handlers_movement.asm`
- **Parameters:** (none)

##### What it does

Each actor tick: if `$24` equals masked frame count in `animScratch2`, jump to `TickMoveComplete`. Otherwise `MovementVelocityCompute` per axis (same multiply/divide pipeline as `[22]`), update accumulators, honor anim delay in `animScratch+3`, spin `UpdateActorAnimation`, increment `$24`, **RTL**. On complete: if `chatPtr` (halving passes) ≠ 0, reset accumulators and loop another pass at halved scale; else save `$0A` to `$00` and RTL once.

##### How it is used

Always immediately after `[52]` in boss and set-piece scripts (32 paired sites). Differs from `[22]` in speed-based frame budgeting and multi-pass halving for long distances.

##### Parameters & return contract

| Item | Value |
|------|-------|
| Outcome | Halt (RTL) until trajectory + halving passes complete |
| Requires | Prior `[52]` in same movement sequence |
| Source examples | `awB1_gorgon.asm:255`, `awB1_gorgon.asm:291` |
