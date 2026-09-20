# COP family: Sine HDMA (scroll wobble)

_Deep-audited ops: `[5F]`, `[60]`, `[61]`_ · _Source: [`cop_handlers_effects.asm`](../../../extracted/system/engine/cop_handlers_effects.asm)_

[← COP index](../index.md)

## Overview

Per-scanline **BG scroll HDMA** driven by `sine_table_8bit` and hardware multiply. **`[5F]`** allocates four interleaved indirect tables at a WRAM base; **`[60]`** advances phase and rebuilds table data from camera coordinates; **`[61]`** registers a channel via `SetupHdmaChannel_Indirect` with **frame parity double-buffering** (`$0036` bit 0 → `+$0200`).

## Shared state

- `$7F0006` (`spritesetPtr`) — WRAM base of table set (from `[5F]`)
- `$7F0008` — Amplitude byte (**must be set before `[5F]`** — typically `#$0004`–`#$0008`)
- `$7F0000` (`animScratch`) — Max frame index / scanline-derived limit
- `$7F0004` (`retPtr1`) — Sine **phase** advanced by `[60]`
- `$7F0002` — Delay counter for `[60]`
- `$06BE` / `$06C2` — Camera targets sampled when `[60]` scroll layer operand references them
- `BuildSineHdmaTable` — Internal; fills horizontal (`$62`) and vertical (`$5E`) scanline words
- `SetupHdmaChannel_Indirect` — Channel bind (`[61]`)

## Family notes

- Typical thinker loop: **`[5F]` → `SetEntryHereAndYield` → flag gate → `[60]` → one or two `[61]`** (BG1/BG2 scroll regs `#0E` / `#10`).
- **`[60]` operand 2**: bit 7 set → index **`cameraTargetX/Y`** with low nibble mask; else full byte index.
- Distinct from **`[00] GenHdmaSine`** (CGRAM-oriented legacy table at `$7E8800`).

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `5F` | `InitSineHdma` | 13 | `Word`, `Byte` | `InitSineHdma` | Continue |
| `60` | `TickSineHdma` | 13 | `Byte`, `Byte` | `TickSineHdma` | Continue |
| `61` | `BindSineHdma` | 18 | `Address`, `Word` | `BindSineHdma` | Continue |

**Family call-site total:** 44

## Opcodes

#### COP [5F] — `InitSineHdma` (build sine HDMA tables)

- **Preferred name:** `InitSineHdma`
- **Handler:** `InitSineHdma` @ [`cop_handlers_effects.asm`](../../../extracted/system/engine/cop_handlers_effects.asm)
- **Usage count:** 13

##### What it does

Reads **`Word Base`** and **`Byte Scanlines`**, lays out **four** `$0200`-spaced indirect tables, computes HDMA entry stride via `UnsignedDivide`, writes repeating 3-byte headers, zeros phase/delay.

```asm
InitSineHdma {
    LDA [$0A]             ; WRAM base
    STA $spritesetPtr, X
    ; base+$0200, +$0400, +$0600 table pointers
    LDA [$0A]             ; scanline count
    ORA #$0080            ; HDMA repeat bit
    ; fill loop → all four tables
    STZ $animScratch+2, X
    STZ $retPtr1, X
    RTI
}
```

##### How it is used

Heat haze, Mu tint wave, comet lair triple-channel setup, ending comet shimmer.

```asm
LDA #$0004
STA $7F0008, X
COP [InitSineHdma] ( #$8800, #20 )     ; native_village/native_village_sine_hdma.asm:16
COP [InitSineHdma] ( #$8800, #40 )     ; babel_tower/sine_hdma_ending_wave.asm:17
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand 1 | `Word Base` — root WRAM address (bank `$7E`) |
| Operand 2 | `Byte Scanlines` — visible rows per table period |
| Precondition | `$7F0008` = amplitude (2× effective swing in table build) |
| Outcome | Continue |

---

#### COP [60] — `TickSineHdma` (advance sine phase)

- **Preferred name:** `TickSineHdma`
- **Handler:** `TickSineHdma` @ [`cop_handlers_effects.asm`](../../../extracted/system/engine/cop_handlers_effects.asm)
- **Usage count:** 13

##### What it does

Decrements delay in `$7F0002`; on underflow reloads delay from operand 1 and **increments `retPtr1` phase**. Operand 2 selects camera reference → DP `$18/$1C`, then **`JSR BuildSineHdmaTable`**.

```asm
TickSineHdma {
    DEC $animScratch+2, X
    ; reload delay / inc retPtr1
    ; load cameraTargetX/Y into $18/$1C
    JSR $&BuildSineHdmaTable
    RTI
}
```

`BuildSineHdmaTable` walks scanlines: sine sample × amplitude + camera offset → HDMA scroll data (ping-pong `$0200` on `$0036`).

##### How it is used

Inside thinker re-entry loops after `[5F]`.

```asm
COP [SetEntryHereAndYield]
COP [BranchOnFlagByte] ( #FF, #00, &loop )
COP [TickSineHdma] ( #04, #02 )        ; native_village_sine_hdma.asm:19 — delay 4, BG2-ish index
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand 1 | `Byte Delay` — frames between phase steps |
| Operand 2 | `Byte ScrollLayer` — camera index; bit 7 → masked index |
| Outcome | Continue (one table rebuild per call) |
| Pairs with | Re-yield loop + `[61]` |

---

#### COP [61] — `BindSineHdma` (bind HDMA channel)

- **Preferred name:** `BindSineHdma`
- **Handler:** `BindSineHdma` @ [`cop_handlers_effects.asm`](../../../extracted/system/engine/cop_handlers_effects.asm)
- **Usage count:** 18

##### What it does

Reads table address + config word; if **`$0036` bit 0** set, adds **`$0200`** to table pointer (double buffer), then `SetupHdmaChannel_Indirect`.

```asm
BindSineHdma {
    LDA $0036
    LSR
    BCC no_offset
    TYA
    ADC #$0200
    TAY
    JSL SetupHdmaChannel_Indirect
    RTI
}
```

##### How it is used

Often **twice** per tick — horizontal and vertical scroll registers.

```asm
COP [BindSineHdma] ( $7E8C00, #0E )   ; BG scroll H
COP [BindSineHdma] ( $7E8C00, #10 )   ; BG scroll V — native_village_sine_hdma.asm:20-21
COP [BindSineHdma] ( $7E8800, #0F )   ; comet lair variants
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand 1 | `Address` — indirect HDMA table (usually base+$0400 data region) |
| Operand 2 | `Word` — B-bus reg / channel pack (`#0E`, `#10`, `#0F`, …) |
| Outcome | Continue |

##### Canonical thinker pattern

```asm
LDA #$0004
STA $7F0008, X
COP [InitSineHdma] ( #$8800, #20 )
COP [SetEntryHereAndYield]
COP [TickSineHdma] ( #04, #02 )
COP [BindSineHdma] ( $7E8C00, #0E )
COP [BindSineHdma] ( $7E8C00, #10 )
RTL
```
