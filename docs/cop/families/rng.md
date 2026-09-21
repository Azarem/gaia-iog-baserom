# COP family: RNG

_Deep-audited ops: `[23]`, `[24]`_ · _Source: [`cop_handlers_movement.asm`](../../../extracted/system/engine/cop_handlers_movement.asm)_

[← COP index](../README.md)

## Overview

Global pseudo-random bytes from a 16-byte Galois LFSR at `$040F`–`$041F`, plus an optional modulo helper that writes `$0420` for script consumption.

## Shared state

| Symbol | Role |
|--------|------|
| `$040F`–`$041F` | PRNG state chain |
| `$0410` | Latest output byte (also advanced by `[23]`) |
| `$0420` (`rngModuloResult`) | `[24]` remainder |

## Family notes

- `[23]` returns the new byte in **A** at RTI (visible to inline ASM following the COP in the same routine).
- `[24]` does **not** advance RNG extra times — it modulo-reduces the current `$0410` via repeated subtraction (bias toward smaller values is possible; games usually follow with tables or `[D9]` switches).
- Heavy `[23]` use is enemy AI, debris, dark-space effects, and Castoth phase randomization.

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `23` | `RngByte` | 221 | (none) | `RngByte` | Continue (A = byte) |
| `24` | `RngMod` | 4 | Byte max | `RngMod` | Continue (`$0420` = rem) |

**Family call-site total:** 225

## Opcodes

#### COP [23] — `RngByte`

- **Handler:** `RngByte` @ [`cop_handlers_movement.asm`](../../../extracted/system/engine/cop_handlers_movement.asm)
- **Parameters:** (none)

##### What it does

Runs a 16-iteration ADC chain across `$0410+X` with `$040F+X`, ripple-increments state from `$0410` upward, loads `$0410` into A (low byte), RTI.

```asm
RngByte {
    ; LDX #$000F … ADC chain … INC ripple …
    LDA $0410
    AND #$00FF
    RTI
}
```

##### How it is used

**Pattern A — AI direction pick**  
`npc_wander_ai.asm` uses `[23]` then `AND #$07` for eight-way wander.

**Pattern B — Position jitter**  
Bosses add RNG to scroll or coordinates before `[BranchIfSolidHere]` (`awB1_gorgon.asm`).

**Pattern C — Table index**  
Double `[23]` + `[24]` for uniform-ish range selection:

```asm
; incan_ruins/ir29_castoth.asm
COP [RngByte]
COP [RngByte]
COP [RngMod] ( #60 )
```

##### Parameters & return contract

| Item | Value |
|------|-------|
| Return | A = `$0410 & $FF` at RTI |
| Side effects | Entire `$040F`–`$041F` state advanced |
| Source examples | `npc_wander_ai.asm:25`, `ir29_castoth.asm:361-372`, `sE8_dark_gaia.asm` |

---

#### COP [24] — `RngMod`

- **Handler:** `RngMod` @ [`cop_handlers_movement.asm`](../../../extracted/system/engine/cop_handlers_movement.asm)
- **Parameters:** `Byte` modulus (must be > 0 for sensible results)

##### What it does

Repeated `SBC modulus` until negative, then add modulus back → remainder in `$0420`, RTI.

```asm
RngMod {
    ; A = $0410 & FF; subtract loop; STA rngModuloResult
    RTI
}
```

##### How it is used

Rare (4 sites) — Castoth and similar bosses where scripts read `$0420` instead of using immediate `AND #mask`. Prefer `AND #small_power_of_2_minus_1` when range is 2/4/8.

##### Parameters & return contract

| Item | Value |
|------|-------|
| Output | `$0420` = `$0410 mod modulus` |
| Does not | Re-seed or advance LFSR beyond prior `[23]` |
| Source examples | `ir29_castoth.asm` (mod `#60`) |
