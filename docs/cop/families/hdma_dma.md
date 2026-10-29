# COP family: HDMA / DMA

_Deep-audited ops: `[00]`, `[01]`, `[02]`, `[03]`_ · _Source: [`cop_handlers_hdma_dma.asm`](../../../extracted/system/engine/cop_handlers_hdma_dma.asm)_

[← COP index](../README.md)

## Overview

Low-level **HDMA channel registration** (indirect-table `[01]`, direct-table `[02]`, caller-chosen channel `[03]`) used by menu window masks, credits scroll, inventory scroll tables, mode 7 matrix tables, and sine-table paths. None of the four ops is a linear (general-purpose) DMA transfer. `[00]` builds a fixed-layout indirect HDMA table from hardware-scaled sine data; `[01]`–`[03]` delegate to `SetupHdmaChannel_Indirect` / `SetupHdmaChannel_Direct` in `hdma_dma_spc.asm`.

## Shared state

- `$0066` — Cached HDMA channel enable bitmask (OR’d by `[03]`)
- `$7F0006` (`spritesetPtr`) — Phase counter for `[00]` (incremented on every call; the sine window starts at `sineTableA + (counter AND $01FE)`; not a double buffer)
- `$7F0008` — Amplitude byte for sine scaling in `[00]` (via `BuildSineLookupTable`)
- `$7E8800`–`$7E8CFF` — Typical WRAM homes for `[00]` indirect headers + sine payload
- `BuildSineLookupTable` — Internal in [`cop_handlers_effects.asm`](../../../extracted/system/engine/cop_handlers_effects.asm); fills `$7E8900` / `$7E8B00` sine arrays
- `SetupHdmaChannel_Indirect` / `SetupHdmaChannel_Direct` — Channel setup (`hdma_dma_spc.asm`)

## Family notes

- Prefer the **`[5F]`–`[61]` sine HDMA family** for scroll wobble; `[00]` is the older “full-table + `#0F` (BG2HOFS) register” path (see `babel_tower/sine_hdma_ending_wave.asm`).
- `[01]` and `[02]` both take a 3-byte table address and one B-bus register byte (copdef `@dma-channel`, `Byte`). The handlers read them as two words: the table address word, then a word with the table bank in the low byte and the register number in the high byte. The setup helper takes the DMAP transfer mode from `hdma_channel_config[register]`; the word carries no mode bits.
- `[03]` programs one channel **immediately** (it names the channel itself instead of taking the next free channel that `[01]`/`[02]` bind).
- Operand order for `[03]` (copdef `Byte, Address, Byte`): `Byte Channel`, `Address Table`, `Byte` B-bus register. The handler reads the table bank and the register as one word (low = table bank, high = B-bus register).

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `00` | `GenHdmaSine` | 2 | — | `GenHdmaSine` | Continue |
| `01` | `QueueHdma` | 18 | `Address`, `Byte` | `QueueHdma` | Continue |
| `02` | `QueueHdmaDirect` | 28 | `Address`, `Byte` | `QueueHdmaDirect` | Continue |
| `03` | `QueueHdmaChannel` | 3 | `Byte`, `Address`, `Byte` | `QueueHdmaChannel` | Continue |

**Family call-site total:** 51

## Opcodes

#### COP [00] — `GenHdmaSine` (build sine HDMA indirect table)

- **Preferred name:** `GenHdmaSine`
- **Handler:** `GenHdmaSine` @ [`cop_handlers_hdma_dma.asm`](../../../extracted/system/engine/cop_handlers_hdma_dma.asm)
- **Usage count:** 2

##### What it does

Calls `BuildSineLookupTable` (amplitude from `$7F0008`, gated by `displayModeFlags` / `animScratch2`), increments the phase counter `$7F0006`, and writes a **7-byte indirect HDMA table** at `$7E8800` (two repeat-mode entries, `$FF` = 127 scanlines and `$E0` = 96 scanlines, then the `$00` end byte; 223 scanlines in total):

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

The table itself holds no register number: the following `[01]` binds it to a B-bus register (**`#0F`** = BG2HOFS in the ending-wave script). Each call of `[00]` advances the phase counter and rewrites the two data pointers.

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
- **Handler:** `QueueHdma` @ [`cop_handlers_hdma_dma.asm`](../../../extracted/system/engine/cop_handlers_hdma_dma.asm)
- **Usage count:** 18

##### What it does

Reads the **HDMA table address** (word) and a **bank | B-bus register** word (table bank in the low byte, register number in the high byte), then `JSL SetupHdmaChannel_Indirect`: the register number indexes `hdma_channel_config` for the `DMAP` transfer mode, `$40` (indirect addressing) is ORed in, and the next free channel is bound (`DMAP`, `DASB`, `BBAD`, `A1T`, `A1B`).

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

Credits flicker, comet lair overlays, ending wave, `WorldMapSplitEffect`, circle-window HDMA thinkers (`hdma_circle_window_thinker`).

```asm
COP [QueueHdma] ( $7E8800, #0F )           ; sine_hdma_ending_wave.asm
COP [QueueHdma] ( @hdma_table, #0E )       ; ending/credits/crF7_credits_hdma_flicker.asm
COP [QueueHdma] ( $7E8C00, #10 )           ; native_village_sine_hdma.asm (with [61] family)
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand 1 | `Address` — A-bus indirect HDMA table in WRAM/ROM |
| Operand 2 | `Byte` — PPU B-bus register number (`$21xx`, e.g. `#0F` = BG2HOFS); the `DMAP` transfer mode comes from `hdma_channel_config[register]`, not from the operand |
| Outcome | Continue — the next free channel (1–7) is bound and its bit is set in the HDMA enable mask |

---

#### COP [02] — `QueueHdmaDirect` (queue direct-table HDMA)

- **Preferred name:** `QueueHdmaDirect`
- **Handler:** `QueueHdmaDirect` @ [`cop_handlers_hdma_dma.asm`](../../../extracted/system/engine/cop_handlers_hdma_dma.asm)
- **Usage count:** 28

##### What it does

Same operand shape as `[01]`, but calls `SetupHdmaChannel_Direct`: `DMAP` is written without the `$40` indirect flag and the channel's bit is still set in the HDMA enable mask, so this is a **direct-table HDMA channel** (each table entry holds the register data inline). It is not a linear DMA transfer; the name only says "direct".

```asm
QueueHdmaDirect {
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

Diary menu window masks (dominant caller, register `#26`), the inventory BG3VOFS table, angel tunnel windows, the mode 7 matrix tables, `WorldMapSplitEffect` (BGMODE and COLDATA tables), the Dark Gaia script `sE8_dark_gaia` (comet lair), and the ending comet / credits scroll scripts.

```asm
COP [QueueHdmaDirect] ( @diary_band_empty, #26 )   ; system/diary_menu/diary_menu_window_dma.asm:27
COP [QueueHdmaDirect] ( @inventory_bg3vofs_table, #12 ) ; system/inventory/inventory_bg3_scroll_hdma.asm (BG3VOFS HDMA)
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand 1 | `Address` — direct HDMA table in WRAM/ROM |
| Operand 2 | `Byte` — PPU B-bus register number (`$21xx`, e.g. `#26` = WH0, `#12` = BG3VOFS); not a size |
| Outcome | Continue |

---

#### COP [03] — `QueueHdmaChannel` (program one HDMA channel now)

- **Preferred name:** `QueueHdmaChannel`
- **Handler:** `QueueHdmaChannel` @ [`cop_handlers_hdma_dma.asm`](../../../extracted/system/engine/cop_handlers_hdma_dma.asm)
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

Mode-7 perspective thinkers queue per-scanline matrix data with **`QueueHdmaDirect`**: operand 2 is a **B-bus register index** (`#1B`–`#1E` → `$211B`–`$211E` / M7A–M7D), not an HDMA channel number. Four **`QueueHdmaDirect`** calls bind the rebuilt tables each frame (`thinkers/mode7_perspective.asm`).

```asm
COP [QueueHdmaDirect] ( $tileStagingBuffer, #1B )   ; table A → M7A
COP [QueueHdmaDirect] ( $7E7800, #1C )              ; table B → M7B
; … two more (table C → M7C, table A again → M7D)
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand 1 | `Byte` channel 0–7 |
| Operand 2 | `Address` HDMA table |
| Operand 3 | `Byte` — PPU B-bus register number (`BBAD`); the table bank is the third byte of operand 2, read together with this byte as one word (low = bank, high = register) |
| Outcome | Continue |
