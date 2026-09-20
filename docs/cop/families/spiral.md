# COP family: Spiral / orbit

_Deep-audited ops: `[6C]`, `[6D]`_ · _Source: [`cop_handlers_effects.asm`](../../../extracted/system/engine/cop_handlers_effects.asm)_

[← COP index](../index.md)

## Overview

**Orbital motion** around a reference actor stored in **`$0000`**. **`[6C]`** seeds **`orbitDiameter`** (`$7F0012`) and **`orbitAngle`** (`$7F0010`); **`[6D]`** adds signed deltas and calls **`ApplyOrbitalOffsetFromRef`** to reposition the current actor on the circle.

## Shared state

- `$7F0010` (`orbitAngle`) — Angle index (0–255 circle)
- `$7F0012` (`orbitDiameter`) — Radius scalar for orbit math
- `$0000` — Reference actor slot pointer (orbit center — set by spawn/list ops before spiral)
- `ApplyOrbitalOffsetFromRef` — Sine/cosine table offset from ref position

## Family notes

- **Operand order for `[6C]`:** **`Byte Diameter`, `Byte Angle`** (first script byte → diameter, second → angle).
- **`[6D]`** operand order: **`Byte DiameterDelta`, `Byte AngleDelta`** (signed).
- Entire family usage is concentrated in **Mu vampire boss** bat-orbit patterns (`mu67_vampires.asm`).

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `6C` | `InitSpiral` | 8 | `Byte`, `Byte` | `InitSpiral` | Continue |
| `6D` | `SpiralStep` | 3 | `Byte`, `Byte` | `SpiralStep` | Continue |

**Family call-site total:** 11

## Opcodes

#### COP [6C] — `InitSpiral` (initialize orbit)

- **Preferred name:** `InitSpiral`
- **Handler:** `InitSpiral` @ [`cop_handlers_effects.asm`](../../../extracted/system/engine/cop_handlers_effects.asm)
- **Usage count:** 8

##### What it does

```asm
InitSpiral {
    LDA [$0A]
    INC $0A
    STA $orbitDiameter, X
    LDA [$0A]
    INC $0A
    STA $orbitAngle, X
    RTI
}
```

Does not move the actor — only seeds WRAM for subsequent **`[6D]`** steps.

##### How it is used

Four spawn points at 0° / 64° / 128° / 192° on the orbit (duplicate passes for both vampire phases).

```asm
COP [InitSpiral] ( #00, #00 )
COP [InitSpiral] ( #00, #40 )
COP [InitSpiral] ( #00, #80 )
COP [InitSpiral] ( #00, #C0 )        ; mu67_vampires.asm:719-757
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand 1 | `Byte Diameter` → `$7F0012` |
| Operand 2 | `Byte Angle` → `$7F0010` |
| Precondition | `$0000` = center actor pointer |
| Outcome | Continue |

---

#### COP [6D] — `SpiralStep` (advance orbit one frame)

- **Preferred name:** `SpiralStep`
- **Handler:** `SpiralStep` @ [`cop_handlers_effects.asm`](../../../extracted/system/engine/cop_handlers_effects.asm)
- **Usage count:** 3

##### What it does

Sign-extends both operands, accumulates into diameter/angle, loads **`Y = [$0000]`**, `JSL ApplyOrbitalOffsetFromRef`.

```asm
SpiralStep {
    ; diameter delta → orbitDiameter
    ; angle delta → orbitAngle
    LDY $0000
    JSL ApplyOrbitalOffsetFromRef
    RTI
}
```

##### How it is used

Bat swarm motion during vampire fight — expand/rotate orbit over multiple script frames.

```asm
COP [SpiralStep] ( #03, #02 )        ; mu67_vampires.asm:773 — widen + rotate
COP [SpiralStep] ( #00, #04 )        ; pure rotation
COP [SpiralStep] ( #FC, #04 )        ; #$FC = −4 diameter delta (contract)
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand 1 | `Byte DiameterDelta` — signed add to radius |
| Operand 2 | `Byte AngleDelta` — signed add to angle |
| Outcome | Continue (position updated immediately) |
| Pairs with | `[6C]` init on same actor; center in `$0000` |
