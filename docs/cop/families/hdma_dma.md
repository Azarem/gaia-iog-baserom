# COP family: HDMA / DMA

_Deep-audited ops: `[00]`, `[01]`, `[02]`, `[03]`_ · _Source: `cop_handlers_solid.asm`_

[← COP index](../index.md)

## Overview

Low-level **HDMA channel registration** and **linear DMA queueing** used by menu window masks, credits scroll, inventory blits, and legacy sine-table paths. `[00]` builds a fixed-layout indirect HDMA table from hardware-scaled sine data; `[01]`–`03]` delegate to `SetupHdmaChannel_Indirect` / `SetupHdmaChannel_Direct` in `hdma_dma_spc.asm`.

## Shared state

- `$0066` — Cached HDMA channel enable bitmask (OR’d by `[03]`)
- `$7F0006` (`spritesetPtr`) — Ping-pong index for `[00]` table generation (`BuildSineLookupTable` path)
- `$7F0008` — Amplitude byte for sine scaling in `[00]` (via `BuildSineLookupTable`)
- `$7E8800`–`$7E8CFF` — Typical WRAM homes for `[00]` indirect headers + sine payload
- `BuildSineLookupTable` — Internal in `cop_handlers_effects.asm`; fills `$7E8900` / `$7E8B00` sine arrays
- `SetupHdmaChannel_Indirect` / `SetupHdmaChannel_Direct` — Channel setup (`hdma_dma_spc.asm`)

## Family notes

- Prefer the **`[5F]`–`[61]` sine HDMA family** for scroll wobble; `[00]` is the older “full-table + `#0F` CGRAM/reg” path (see `babel_tower/sine_hdma_ending_wave.asm`).
- `[01]` and `[02]` both consume **two word operands** from the script stream; the second word packs B-bus target / transfer mode for the setup helper.
- `[03]` programs one channel **immediately** (does not go through the deferred queue used by `[01]`/`[02]`).
- Operand order for `[03]` in shipped scripts: `Byte Channel`, `Address Table`, `Word` (low = B-bus reg, high = source bank) — not the legacy copdef `Byte, Word, Word` layout.

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `00` | `GenHdmaSine` | 2 | — | `GenHdmaSine` | Continue |
| `01` | `QueueHdma` | 18 | `Address`, `Word` | `QueueHdma` | Continue |
| `02` | `QueueDma` | 28 | `Address`, `Word` | `QueueDma` | Continue |
| `03` | `QueueHdmaChannel` | 3 | `Byte`, `Address`, `Word` | `QueueHdmaChannel` | Continue |

**Family call-site total:** 51

## Opcodes

#### COP [00] — `GenHdmaSine` (build sine HDMA indirect table)

- **Preferred name:** `GenHdmaSine`
- **Handler:** `GenHdmaSine` @ `extracted/system/engine/cop_handlers_solid.asm`
- **Usage count:** 2

##### What it does

Calls `BuildSineLookupTable` (amplitude from `$7F0008`, gated by `displayModeFlags` / `animScratch2`), toggles a double-buffer page via `$7F0006`, and writes a **3-entry indirect HDMA table** at `$7E8800`:

```asm
GenHdmaSine {
    TYX
    PHP
    JSR $&cop_handlers_effects.BuildSineLookupTable
    LDA $spritesetPtr, X
    INC
    STA $spritesetPtr, X
    AND #$01FE
    CLC
    ADC #$8900
    STA $7E8801           ; indirect source pointers into sineTable region
    ; … $FF / $E0 / $00 HDMA control bytes …
    PLP
    LDA $0A
    STA $02, S
    RTI
}
```

The `$E0` line-count entry targets B-bus **`#0F`** (palette/CGRAM path in the ending-wave scripts). Regenerate tables when amplitude or phase drivers change, then queue with `[01]`.

##### How it is used

Legacy companion to manual sine HDMA; most field scenes use `[5F]` instead.

```asm
COP [GenHdmaSine]
COP [QueueHdma] ( $7E8800, #0F )    ; babel_tower/sine_hdma_ending_wave.asm:31-32
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operands | None |
| Preconditions | `$7F0008` = amplitude; trigger bit in `displayModeFlags` bit 6 or `animScratch2` bit 0 for table rebuild |
| WRAM | Indirect table at `$7E8800`; sine payload via `BuildSineLookupTable` |
| Pairs with | `[01] QueueHdma` on same table base |

---

#### COP [01] — `QueueHdma` (queue indirect HDMA)

- **Preferred name:** `QueueHdma`
- **Handler:** `QueueHdma` @ `extracted/system/engine/cop_handlers_solid.asm`
- **Usage count:** 18

##### What it does

Reads **HDMA table address** and **channel config word**, then `JSL SetupHdmaChannel_Indirect` (sets `DMAP` HDMA bit, B-bus register, A-bus pointer).

```asm
QueueHdma {
    TYX
    LDA [$0A]             ; table address
    INC $0A
    INC $0A
    TAY
    LDA [$0A]             ; channel / reg pack
    INC $0A
    INC $0A
    JSL $@hdma_dma_spc.SetupHdmaChannel_Indirect
    LDA $0A
    STA $02, S
    RTI
}
```

##### How it is used

Credits flicker, comet lair overlays, ending wave, `HdmaWindowEffect`, gradient thinkers.

```asm
COP [QueueHdma] ( $7E8800, #0F )           ; sine_hdma_ending_wave.asm
COP [QueueHdma] ( @hdma_table, #0E )       ; ending/credits/crF7_credits_hdma_flicker.asm
COP [QueueHdma] ( $7E8C00, #10 )           ; native_village_sine_hdma.asm (with [61] family)
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand 1 | `Address` — A-bus indirect HDMA table in WRAM/ROM |
| Operand 2 | `Word` — channel setup (B-bus reg + mode nibble as used elsewhere in engine) |
| Outcome | Continue — channel armed for next HDMA latch |

---

#### COP [02] — `QueueDma` (queue linear DMA)

- **Preferred name:** `QueueDma`
- **Handler:** `QueueDma` @ `extracted/system/engine/cop_handlers_solid.asm`
- **Usage count:** 28

##### What it does

Same operand shape as `[01]`, but calls `SetupHdmaChannel_Direct` for **non-indirect** DMA (VRAM/CGRAM bulk copies, window register bursts).

```asm
QueueDma {
    TYX
    LDA [$0A]
    INC $0A
    INC $0A
    TAY
    LDA [$0A]
    INC $0A
    INC $0A
    JSL $@hdma_dma_spc.SetupHdmaChannel_Direct
    LDA $0A
    STA $02, S
    RTI
}
```

##### How it is used

Diary menu window masks (dominant caller), inventory DMA setup, angel tunnel windows, scene lifecycle blits.

```asm
COP [QueueDma] ( @dma_channel_00BC4C, #26 )   ; system/diary_menu/diary_menu_window_dma.asm:27
COP [QueueDma] ( @dma_setup, #26 )            ; system/inventory/inventory_dma_setup.asm
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand 1 | `Address` — source table / staging buffer |
| Operand 2 | `Word` — transfer size / destination pack consumed by `SetupHdmaChannel_Direct` |
| Outcome | Continue |

---

#### COP [03] — `QueueHdmaChannel` (program one HDMA channel now)

- **Preferred name:** `QueueHdmaChannel`
- **Handler:** `QueueHdmaChannel` @ `extracted/system/engine/cop_handlers_solid.asm`
- **Usage count:** 3

##### What it does

Immediate per-channel register poke at `$4300+channel×16`: sets `DMAP` (HDMA `$40`), `BBAD`, `A1T`, `A1B`, and **`TSB $0066`** for enable tracking.

```asm
QueueHdmaChannel {
    ; channel ID → bitmask → DMAP/BBAD/A1T/A1B for that channel
    ORA #$40
    STA $DMAP0, X
    ; …
    RTI
}
```

##### How it is used

Mode-7 perspective thinkers and unused perspective experiments — when a script must pin a specific channel without the shared queue.

```asm
COP [QueueHdmaChannel] ( #04, $7Exxxx, #xxxx )   ; thinkers/mode7_perspective.asm
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand 1 | `Byte` channel 0–7 |
| Operand 2 | `Address` HDMA table |
| Operand 3 | `Word` — low 8 = B-bus reg (`BBAD`), high 8 = source bank |
| Outcome | Continue |
