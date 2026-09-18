# Bank $00 — NMI/VBlank Handler & DMA

*Part of the [Bank $00 Documentation Suite](readme.md)*

> The VBlank interrupt handler — the only place where OAM, CGRAM, VRAM DMA, HDMA enable, joypad sampling, and APU I/O are performed.

**Source:** [`extracted/system/engine/system_core.asm`](../../../extracted/system/engine/system_core.asm)

---

## Overview

Every visible frame passes through `NmiHandler` at `$82F8`. The main game loop (`SystemInit`) blocks in `EnableNmiAndJoypad` ($02) until VBlank fires; NMI runs on the interrupt stack and performs all PPU register writes and DMA transfers. No rendering happens outside this handler.

| Function | Address | Size | Role |
|----------|---------|------|------|
| `NmiHandler` | `$82F8` | 143 B | VBlank ISR — PPU upload, DMA, input, APU |
| `UploadScrollRegisters` | `$8387` | 77 B | BG1/BG2 scroll register write |
| `WriteBgScroll` | `$83D4` | 61 B | Single-layer H/V scroll with override logic |
| `ExecuteVramDma` | `$8411` | 39 B | One VRAM DMA transfer from DP parameters |
| `FillWramBlock` | `$8438` | 52 B | **Unreferenced** — DMA fill stub (debug/cut) |

### NMI vs Main Loop Split

```
Main thread (SystemInit loop)          NMI (NmiHandler @ $82F8)
─────────────────────────────          ───────────────────────────
Game logic, actors, collision    │     PPU register writes
Build OAM buffer in WRAM         │     DMA OAM → PPU
Build HDMA table → $66           │     DMA CGRAM, VRAM
Wait in EnableNmiAndJoypad ──────┼──►  Enable HDMA ($66 → HDMAEN)
                                 │     Read JOY1L → $0660
                                 │     APU handshake ($06F8/$06FA)
                                 │     RTI
```

---

## NmiHandler

**Address:** `$82F8` · **Size:** 143 bytes

The **VBlank interrupt service routine**. Runs at ~60 Hz with interrupts masked. Saves 12 bytes of CPU state, sets `DBR=$81`, disables HDMA during register writes, performs the full PPU upload pipeline, re-enables HDMA, polls the joypad, optionally runs a full game frame during music transitions, communicates with the SPC700 APU, increments the frame counter, and returns via `RTI`.

Must complete within ~20,000 CPU cycles (one VBlank period at NTSC). Heavy work is delegated to bank `$02`/`$03` helpers; same-bank scroll and DMA helpers stay minimal.

### 19-Step Execution Flow

| Step | Call | Purpose |
|------|------|---------|
| 1 | `PHP/PHB/PHA/PHX/PHY/CLD` | Save 12-byte context to interrupt stack |
| 2 | `LDA #$81 / PHA / PLB` | Set DBR=$81 for WRAM data bank |
| 3 | `STZ $HDMAEN` | Disable HDMA during register/DMA setup |
| 4 | `JSR UploadScrollRegisters` | Write BG1/BG2 scroll offsets to PPU |
| 5 | `JSL FlushDirtyTilemapStrips` ($02) | Flush dirty tilemap column/row strips to VRAM |
| 6 | `JSL UploadCgramPalette` ($02) | DMA 512-byte palette buffer → PPU CGRAM |
| 7 | `JSL UploadOamTable` ($02) | DMA OAM sprite table → PPU OAM |
| 8 | `JSL SpriteVramDma` ($02) | Transfer queued sprite tile data to VRAM |
| 9 | *inline* | Configure DMA ch0: `VMAIN=$80`, `BBAD0=$18`, `DMAP0=$01` |
| 10 | `JSL DmaPlayerTilesToVram` ($03) | **Conditional:** if `$09EC` bit 3 — alternate BG3 tilemap path |
| 11 | *inline* | If `$0800` non-zero → skip tilemap DMA (step 12) |
| 12 | `JSL DmaAdhocVramBlock` ($03) → `JSL FlushVramWriteQueue` ($02) → `JSR ExecuteVramDma` | Prepare tilemap, flush VRAM queue, execute final DMA |
| 13 | `LDA $66 / STA $HDMAEN` | Re-enable HDMA channels built during main loop |
| 14 | *poll `$HVBJOY`* | Wait for H-blank to end (safe joypad read window) |
| 15 | `LDA $JOY1L / STA $0660` | Latch current controller state |
| 16 | `JSL UpdateFrameFull` | **Conditional:** if `$06FA ≠ 0` — advance full game frame during music crossfade |
| 17 | `LDA $06F8 / STA $APUIO2` | **Even frames only** (`$0036` bit 0 clear): send SFX to APU |
| 18 | `INC $0036` | Increment 16-bit frame parity counter |
| 19 | `PLY/PLX/PLA/PLB/PLP/RTI` | Restore context and return from interrupt |

### Variables

| Address | Size | Name | Step | Role |
|---------|------|------|------|------|
| `$0036` | 2 | Frame parity | 17–18 | Even/odd APU timing; incremented every NMI |
| `$0066` | 1 | HDMA enable mask | 13 | Channel bitmask written to `$HDMAEN` |
| `$0660` | 2 | Raw joypad | 15 | Latched JOY1L state for main loop |
| `$06F8` | 2 | SFX channel queue | 17 | Sound effect sent to APU on even frames |
| `$06FA` | 2 | Music transition flag | 16 | Non-zero → run `UpdateFrameFull` inside NMI |
| `$0800` | 1 | DMA skip flag | 11 | Non-zero → bypass tilemap DMA path |
| `$09EC` | 2 | Display mode flags | 10 | Bit 3 → alternate BG3 path |

### Cross-References

| Symbol | Relationship |
|--------|-------------|
| `NmiVector` (`$800B`) | Hardware vector trampoline — calls this every VBlank |
| `EnableNmiAndJoypad` ($02) | Main loop blocks here until NMI fires |
| `UpdateFrameFull` | Called conditionally — advances a full game frame for music crossfade lockstep |
| `FlushDirtyTilemapStrips` ($02) | Tilemap strip DMA — largest variable time cost |
| `DmaPlayerTilesToVram` ($03) | Alternate BG3 mode for special display configurations |
| `DmaAdhocVramBlock` ($03) | Prepares tilemap data into DMA parameters for `ExecuteVramDma` |

---

## UploadScrollRegisters

**Address:** `$8387` · **Size:** 77 bytes

Writes **BG1 and BG2** scroll offsets to PPU registers `$210D`–`$2110` during VBlank. Two modes:

- **Normal** (`$06EF` bit 3 clear): Calls `WriteBgScroll` twice; layer order depends on `$06EE` sign. Positive → BG1 first, negative → BG2 first. This controls which layer "wins" during parallax without changing the values.
- **Locked** (`$06EF` bit 3 set): Writes `$068A`–`$068F` directly to PPU in fixed BG1→BG2 order, bypassing override logic.

### Variables

| Address | Size | Name | Role |
|---------|------|------|------|
| `$06EE` | 1 | Layer priority | Sign selects BG1/BG2 write order |
| `$06EF` | 1 | Scroll mode | Bit 3: normal (0) vs locked (1) |
| `$068A`–`$068F` | 6 | BG1/BG2 scroll | H/V offsets for both layers |
| `$06C6`–`$06CB` | 6 | Override scroll | Used in normal mode via `WriteBgScroll` |

**Called by:** `NmiHandler` step 4 (every VBlank) · **Scroll values set by:** `CameraSmoothScroll` ($02)

---

## WriteBgScroll

**Address:** `$83D4` · **Size:** 61 bytes

Writes H and V scroll for **one BG layer** to PPU. Register offset **Y** selects the layer (`0`=BG1, `2`=BG2); source offset **X** selects which value array to read.

**Override logic:** When `$06C7,X` (H flag) or `$06CB,X` (V flag) has its sign bit set, the override value from `$06C6`/`$06CA` is used instead of the normal scroll from `$068A`/`$068E`. This is how camera pan COPs (`$DC`–`$DF`) temporarily lock scroll without modifying the base values.

Scroll high bytes are **masked to `$03`** — hardware scroll is 10 bits; the mask prevents stray bits from corrupting tilemap fetch addresses.

| Parameter | Values |
|-----------|--------|
| **X** | Source array offset: `0`=BG1 data, `2`=BG2 data |
| **Y** | PPU register offset: `0`=BG1 regs, `2`=BG2 regs |

**Called by:** `UploadScrollRegisters` (2× in normal mode) · **Overrides set by:** Camera pan COPs `CameraPanDown`/`Up`/`Left`/`Right`

---

## ExecuteVramDma

**Address:** `$8411` · **Size:** 39 bytes

Performs a **single VRAM DMA transfer** using parameters stored in direct page by bank `$03` tilemap helpers. Returns immediately if size (`$00B2`) is zero — the standard "no work" path when no tilemap update is queued.

Uses DMA channel 0 in **incrementing-source, fixed-destination** mode (pre-configured by `NmiHandler` step 9).

| DP Variable | Size | → SNES Register | Purpose |
|-------------|------|------------------|---------|
| `$00AC` | 2 | `$4302` (`A1T0L/H`) | Source address |
| `$00AE` | 1 | `$4304` (`A1B0`) | Source bank |
| `$00B0` | 2 | `$2116` (`VMADDL/H`) | VRAM word address |
| `$00B2` | 2 | `$4305` (`DAS0L/H`) | Transfer size (0 = skip) |

**Called by:** `NmiHandler` step 12 · **Parameters set by:** `DmaAdhocVramBlock` ($03) tilemap prep

---

## FillWramBlock

**Address:** `$8438` · **Size:** 52 bytes · **⚠ Unreferenced**

DMA fill of **512 bytes** at WRAM `$000422` using fixed byte `$E0` from `WramFillConstant` (`$846C`). No callers exist in the ROM — likely a debug or development tool. Uses DMA channel 0 in fill mode (`$DMAP0=$08`).

Immediately followed in ROM by `CopDispatch` at `$846D` — the fill constant byte (`$E0`) doubles as the last byte before the COP engine.

---

## NMI Timing Budget

| Phase | Typical Cost | Notes |
|-------|-------------|-------|
| Context save + HDMA disable | ~30 cycles | Fixed overhead |
| Scroll upload | ~200 cycles | 2 layers × register writes |
| Tilemap strip flush | ~500+ cycles | `FlushDirtyTilemapStrips` — variable |
| CGRAM DMA | ~500 cycles | 512-byte palette |
| OAM DMA | ~544 cycles | 544 bytes to PPU |
| Sprite VRAM DMA | Variable | Queued sprite tile transfers |
| HDMA enable + joypad | ~100 cycles | Includes `HVBJOY` poll loop |
| Music handshake frame | **Full frame** | Only when `$06FA` active — intentionally exceeds VBlank |
| Context restore | ~30 cycles | `RTI` |

---

## Call Graph

```
NmiHandler ($82F8)
├── UploadScrollRegisters ($8387)
│   └── WriteBgScroll ($83D4) [×2]
├── FlushDirtyTilemapStrips ($02) — tilemap strip DMA
├── UploadCgramPalette ($02) — 512-byte palette DMA
├── UploadOamTable ($02) — sprite table DMA
├── SpriteVramDma ($02) — sprite tile VRAM transfer
├── DmaPlayerTilesToVram ($03) — special BG3 [conditional]
├── DmaAdhocVramBlock ($03) — tilemap prep
├── FlushVramWriteQueue ($02) — flush VRAM write queue
├── ExecuteVramDma ($8411) — final VRAM DMA
├── UpdateFrameFull ($81BC) [if $06FA ≠ 0]
└── (joypad latch, APU handshake, frame counter++)

FillWramBlock ($8438) — UNREFERENCED
```

---

**See Also:** [system-core.md](system-core.md) (reset, init, main loop) · [cop-dispatch.md](cop-dispatch.md) (COP engine at `$846D`) · [data-tables-memory.md](data-tables-memory.md) (full variable map)
