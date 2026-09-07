# Bank $00 — NMI/VBlank Handler & DMA

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$0082F8`–`$00843F`  
**ASM file:** `extracted/system/system_core.asm`  
**Block:** `system/system_core` in `us/blocks.json`

This page documents the vertical-blank interrupt handler and its same-bank helpers. Every visible frame passes through `NmiHandler`: it is the only place where OAM, CGRAM, VRAM DMA, HDMA enable, joypad sampling, and APU I/O are performed. The main game loop (`SystemInit`) blocks until VBlank; NMI runs concurrently on the interrupt stack.

**Related:** [`system-core.md`](system-core.md) covers reset, init, and main loop. [`chunk_008000-analysis.md`](../chunk_008000-analysis.md) covers the broader system page.

---

## Overview

| Function | Address | Size | Role |
|----------|---------|------|------|
| `NmiHandler` | `$0082F8` | 143 bytes | VBlank ISR — PPU upload, DMA, input, APU |
| `UploadScrollRegisters` | `$008387` | 77 bytes | BG1/BG2 scroll register write |
| `WriteBgScroll` | `$0083D4` | 61 bytes | Single-layer H/V scroll |
| `ExecuteVramDma` | `$008411` | 39 bytes | One VRAM DMA transfer |
| `FillWramBlock` | `$008438` | 52 bytes | **Unreferenced** WRAM fill stub |

### NMI vs Main Loop Split

```
Main thread (SystemInit loop)          NMI (NmiHandler @ $82F8)
─────────────────────────────          ───────────────────────────
Game logic, actors, collision    │     PPU register writes
Build OAM buffer in WRAM         │     DMA OAM → PPU
Build HDMA table → $66           │     DMA CGRAM, VRAM
Wait in func_028191 ─────────────┼──►  Enable HDMA ($66 → HDMAEN)
                                 │     Read JOY1L → $0660
                                 │     APU handshake ($06F8/$06FA)
                                 │     RTI
```

---

## NMI Handler Group — Shared Variables

| Address | Size | Name | Role in NMI Group |
|---------|------|------|-------------------|
| `$0036` | 2 | Frame parity counter | Incremented each NMI; even/odd APU timing |
| `$0066` | 1 | HDMA channel enable mask | Built by `func_03E146`; written to `$HDMAEN` |
| `$00AC`–`$00AE` | 4 | DMA source address + bank | `ExecuteVramDma` parameters |
| `$00B0` | 2 | VRAM destination (word addr) | `ExecuteVramDma` |
| `$00B2` | 2 | DMA transfer size (bytes) | Zero = skip transfer |
| `$0660` | 2 | Raw JOY1L joypad | Sampled once per frame after H-blank |
| `$068A`–`$068F` | 6 | BG1/BG2 scroll values | Normal scroll path |
| `$06C6`–`$06CB` | 6 | Scroll override values | Locked/override scroll path |
| `$06EE` | 1 | Layer draw priority | Normal scroll layer ordering |
| `$06EF` | 1 | Scroll mode flags | Bit 3 = locked scroll mode |
| `$06F8` | 2 | SFX channel 1 queue | Sent to `$APUIO2` on even frames |
| `$06FA` | 2 | Music transition handshake | Non-zero → call `UpdateFrame_Full` |
| `$0800` | 1 | DMA skip flag | Non-zero → skip tilemap DMA path |
| `$09EC` | 2 | Display mode flags | Bit 3 → special BG3 mode |

---

### NmiHandler

| Property | Value |
|----------|-------|
| **Old Name** | `native_mode_nmi_handler_0082F8` |
| **New Name** | `NmiHandler` |
| **Hex Address** | `$0082F8` |
| **Decimal Address** | 33528 |
| **Size** | 143 bytes |
| **ASM File** | `extracted/system/system_core.asm` |

#### Description

The **VBlank interrupt service routine**. Runs at ~60 Hz with interrupts globally masked (`SEI` implicit in NMI entry). Saves 12 bytes of CPU state, sets `DBR=$81`, disables HDMA during register writes, performs the full PPU upload pipeline, re-enables HDMA, polls the joypad, optionally runs a full game frame during music transitions, communicates with the SPC700 APU, increments the frame parity counter, and returns via `RTI`.

This routine must complete within ~20,000 CPU cycles (one VBlank period at NTSC). Heavy work is delegated to bank `$02`/`$03` JSL helpers; same-bank scroll and DMA helpers stay minimal.

#### Algorithm — 19-Step Execution Flow

| Step | Code / Call | Purpose |
|------|-------------|---------|
| 1 | **Save context** | `PHP`, `PHB`, `PHA`, `PHX`, `PHY`, `CLD` — 12-byte stack footprint |
| 2 | **Set DBR** | `LDA #$81` / `PHA` / `PLB` — WRAM data bank for `$0000`–`$7FFF` |
| 3 | **Disable HDMA** | `STZ $HDMAEN` — prevent HDMA during register/DMA setup |
| 4 | `JSR UploadScrollRegisters` | Write BG1/BG2 `$BGxHOFS`/`$BGxVOFS` |
| 5 | `JSL func_02AF5F` | Upload OAM table from `$7F3100` buffer to PPU `$2104` |
| 6 | `JSL func_029DE2` | Upload CGRAM (512-byte palette) via DMA |
| 7 | `JSL func_029E1D` | Upload additional PPU state (mode, windows, etc.) |
| 8 | `JSL func_02B038` | Process pending VRAM transfer queue |
| 9 | **Set VRAM DMA mode** | `VMAIN=$80` (increment high), `BBAD0=$18` (VRAM target), `DMAP0=$01` (2-address write) |
| 10 | **BG3 special mode** | If `$09EC` bit 3 set → `JSL func_03D881` (alternate BG3 tilemap path) |
| 11 | **DMA skip check** | If `$0800` non-zero → branch past tilemap DMA (step 12) |
| 12 | **Normal tilemap path** | `JSL func_03F1D0` (prepare tilemap) → `JSL func_02A310` (flush VRAM queue) → `JSR ExecuteVramDma` |
| 13 | **Enable HDMA** | `LDA $66` / `STA $HDMAEN` — activate channels built during main loop |
| 14 | **Wait H-blank end** | Poll `$HVBJOY` bit 0 until H-blank finished (safe joypad read window) |
| 15 | **Read joypad** | `LDA $JOY1L` / `STA $0660` — latched controller state |
| 16 | **Music handshake** | If `$06FA ≠ 0` → `JSL UpdateFrame_Full` — advance game during music crossfade |
| 17 | **APU communication** | On even frame (`$0036` bit 0 clear): `LDA $06F8` / `STA $APUIO2` — SFX port |
| 18 | **Frame counter** | Increment `$0036` (16-bit parity / timing) |
| 19 | **Restore & return** | `PLY`, `PLX`, `PLA`, `PLB`, `PLP`, `RTI` |

#### Stack Layout (on entry to step 4)

| Offset | Content |
|--------|---------|
| `$01,S` | Saved P (from `PHP`) |
| `$02,S` | Saved DBR (from `PHB`) |
| `$03,S` | Saved A low |
| `$04,S` | Saved A high |
| `$05,S` | Saved X low |
| `$06,S` | Saved X high |
| `$07,S` | Saved Y low |
| `$08,S` | Saved Y high |

Total: **12 bytes** above the pre-NMI stack pointer.

#### Variables

| Address | Size | Name | Step | R/W |
|---------|------|------|------|-----|
| `$0036` | 2 | Frame parity | 17–18 | R/W |
| `$0066` | 1 | HDMA enable mask | 13 | R |
| `$0660` | 2 | Raw joypad | 15 | W |
| `$06F8` | 2 | SFX queue | 17 | R |
| `$06FA` | 2 | Music handshake | 16 | R |
| `$0800` | 1 | DMA skip flag | 11 | R |
| `$09EC` | 2 | Display flags | 10 | R |
| `$00AC`–`$00B2` | 6 | VRAM DMA params | 12 | R (via `ExecuteVramDma`) |
| `$HDMAEN` | 1 | PPU HDMA enable | 3, 13 | W |
| `$HVBJOY` | 1 | PPU status | 14 | R |
| `$JOY1L` | 2 | Hardware joypad | 15 | R |
| `$APUIO2` | 1 | APU I/O port 2 | 17 | W |
| `$VMAIN` | 1 | VRAM address mode | 9 | W |
| `$BBAD0` / `$DMAP0` | 2 | DMA channel 0 cfg | 9 | W |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | `NmiVector` (`$00800B`) | Every VBlank |
| Calls | `UploadScrollRegisters` | Same-bank JSR |
| Calls | `ExecuteVramDma` | Same-bank JSR |
| Calls | `UpdateFrame_Full` | When `$06FA` active — see [`system-core.md`](system-core.md) |
| Calls | `func_02AF5F`, `func_029DE2`, `func_029E1D`, `func_02B038` | Bank `$02` PPU helpers |
| Calls | `func_03F1D0`, `func_02A310`, `func_03D881` | Bank `$03` tilemap helpers |
| Paired with | `func_028191` | Main loop end-frame wait |
| Cataloged in | `us/names.json` @ 33528 | |

---

### UploadScrollRegisters

| Property | Value |
|----------|-------|
| **Old Name** | `sub_008387` |
| **New Name** | `UploadScrollRegisters` |
| **Hex Address** | `$008387` |
| **Decimal Address** | 33671 |
| **Size** | 77 bytes |
| **ASM File** | `extracted/system/system_core.asm` |

#### Description

Writes **BG1 and BG2** horizontal and vertical scroll offsets to the SNES PPU registers `$210D`–`$2110` (`BG1HOFS`, `BG1VOFS`, `BG2HOFS`, `BG2VOFS`). Supports two distinct modes selected by `$06EF` bit 3:

- **Normal mode** (bit 3 clear): Calls `WriteBgScroll` twice with layer ordering determined by `$06EE` sign. When `$06EE ≥ 0`, BG1 is written first (X=0, Y=0) then BG2 (X=2, Y=2). When `$06EE` is negative, BG2 is written first.
- **Locked mode** (bit 3 set): Bypasses override logic and writes `$068A`–`$068F` directly to PPU registers in fixed order.

Layer priority from `$06EE` allows scenes to control which background scrolls "on top" during split-screen or parallax effects without changing the scroll values themselves.

#### Algorithm — Normal Mode

| Step | Action |
|------|--------|
| 1 | Test `$06EF` bit 3 — if set, jump to locked path |
| 2 | Test `$06EE` sign |
| 3a | If `$06EE ≥ 0`: `JSR WriteBgScroll` (X=0, Y=0) then (X=2, Y=2) |
| 3b | If `$06EE < 0`: `JSR WriteBgScroll` (X=2, Y=2) then (X=0, Y=0) |
| 4 | `RTS` |

#### Algorithm — Locked Mode

| Step | Action |
|------|--------|
| 1 | Write `$068A`/`$068B` → `$BG1HOFS` (H scroll BG1) |
| 2 | Write `$068C`/`$068D` → `$BG1VOFS` (V scroll BG1) |
| 3 | Write `$068E`/`$068F` → `$BG2HOFS` / `$BG2VOFS` |
| 4 | `RTS` |

#### Variables

| Address | Size | Name | Mode |
|---------|------|------|------|
| `$06EE` | 1 | Layer priority flag | Normal — sign selects write order |
| `$06EF` | 1 | Scroll mode flags | Bit 3: 0=normal, 1=locked |
| `$068A`–`$068D` | 4 | BG1 H/V scroll (16-bit each) | Both modes |
| `$068E`–`$068F` | 2 | BG2 H/V scroll low bytes | Locked; BG2 via `WriteBgScroll` in normal |
| `$06C6`–`$06CB` | 6 | Override scroll values | Normal — via `WriteBgScroll` |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | `NmiHandler` step 4 | Once per VBlank |
| Calls | `WriteBgScroll` | Up to 2× per NMI |
| Updated by | `func_02AC2E` | Main loop — computes scroll values |
| Cataloged in | `us/names.json` @ 33671 | |

---

### WriteBgScroll

| Property | Value |
|----------|-------|
| **Old Name** | `sub_0083D4` |
| **New Name** | `WriteBgScroll` |
| **Hex Address** | `$0083D4` |
| **Decimal Address** | 33748 |
| **Size** | 61 bytes |
| **ASM File** | `extracted/system/system_core.asm` |

#### Description

Writes **horizontal and vertical scroll** for a single BG layer to the PPU register pair `$BG1HOFS+Y` / `$BG1VOFS+Y`. Register offset **Y** selects the layer (`0` = BG1, `2` = BG2). Source data offset **X** selects which scroll value array to read (`0` = BG1 values, `2` = BG2 values).

Implements **override logic** for camera pans and scripted scroll locks: when the high byte of the override flag word is negative (`$06C7,X` for H, `$06CB,X` for V), the override value from `$06C6,X` / `$06CA,X` is used instead of the normal scroll from `$068A,X` / `$068E,X`.

Scroll high bytes are **masked to `$03`** before write — hardware scroll is 10 bits; the mask prevents stray bits from corrupting the tilemap fetch address.

#### Algorithm

| Step | Action |
|------|--------|
| 1 | **H scroll select** | If `$06C7,X` negative → use `$06C6,X`; else → `$068A,X` |
| 2 | Mask H high byte with `$03` | |
| 3 | Write H low → `$BG1HOFS+Y`, H high → `$BG1HOFS+Y` (auto-increment) | |
| 4 | **V scroll select** | If `$06CB,X` negative → use `$06CA,X`; else → `$068E,X` |
| 5 | Mask V high byte with `$03` | |
| 6 | Write V low/high → `$BG1VOFS+Y` | |
| 7 | `RTS` | |

#### Parameters

| Register | Meaning |
|----------|---------|
| **X** | Source array offset (0=BG1 data, 2=BG2 data) |
| **Y** | PPU register offset (0=BG1 regs, 2=BG2 regs) |

#### Variables

| Address | Size | Name | Role |
|---------|------|------|------|
| `$068A,X` | 2 | Normal H scroll | Default source |
| `$068E,X` | 2 | Normal V scroll | Default source |
| `$06C6,X` | 2 | Override H scroll | Used when `$06C7,X` bit 15 set |
| `$06C7,X` | 1 | H override flag | Negative = use override |
| `$06CA,X` | 2 | Override V scroll | Used when `$06CB,X` bit 15 set |
| `$06CB,X` | 1 | V override flag | Negative = use override |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | `UploadScrollRegisters` | 2× in normal mode |
| Used during | Camera pan COPs ($DC–$DF) | Set override flags in `$06C6`–`$06CB` |
| Cataloged in | `us/names.json` @ 33748 | |

---

### ExecuteVramDma

| Property | Value |
|----------|-------|
| **Old Name** | `sub_008411` |
| **New Name** | `ExecuteVramDma` |
| **Hex Address** | `$008411` |
| **Decimal Address** | 33809 |
| **Size** | 39 bytes |
| **ASM File** | `extracted/system/system_core.asm` |

#### Description

Performs a **single VRAM DMA transfer** using parameters pre-stored in direct page by bank `$03` tilemap helpers. If transfer size `$00B2` is zero, returns immediately without touching DMA registers — this is the standard "no work" path when no tilemap update is queued.

Uses DMA channel 0 in **fixed-destination, incrementing-source** mode (configured in `NmiHandler` step 9 before this call).

#### Algorithm

| Step | Action |
|------|--------|
| 1 | Load `$00B2` (size) — if zero, `RTS` |
| 2 | Write size → `$DAS0L` / `$DAS0H` (DMA size) |
| 3 | Write `$00B0` → `$VMADDL` / `$VMADDH` (VRAM word address) |
| 4 | Write `$00AC` → `$A1T0L` / `$A1T0H` (source address) |
| 5 | Write `$00AE` → `$A1B0` (source bank) |
| 6 | Write `$01` → `$MDMAEN` — start channel 0 DMA |
| 7 | `RTS` |

#### Variables

| Address | Size | Name | Role |
|---------|------|------|------|
| `$00AC` | 2 | DMA source address (low 16 bits) | Set by `func_03F1D0` |
| `$00AE` | 1 | DMA source bank | Set by `func_03F1D0` |
| `$00B0` | 2 | VRAM destination (word address) | Set by `func_03F1D0` |
| `$00B2` | 2 | Transfer size in bytes | Zero = no-op |

#### SNES Registers Written

| Register | Value source |
|----------|--------------|
| `$4305` (`DAS0L/H`) | `$00B2` |
| `$2116` (`VMADDL/H`) | `$00B0` |
| `$4302` (`A1T0L/H`) | `$00AC` |
| `$4304` (`A1B0`) | `$00AE` |
| `$420B` (`MDMAEN`) | `$01` (channel 0) |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | `NmiHandler` step 12 | After `func_03F1D0` + `func_02A310` |
| Parameters from | `func_03F1D0` | Bank `$03` tilemap prep |
| Related | `func_02A310` | Flushes VRAM write queue before DMA |
| Cataloged in | `us/names.json` @ 33809 | |

---

### FillWramBlock

| Property | Value |
|----------|-------|
| **Old Name** | `sub_008438_noref` |
| **New Name** | `FillWramBlock` |
| **Hex Address** | `$008438` |
| **Decimal Address** | 33848 |
| **Size** | 52 bytes (includes alignment to `$846C` constant) |
| **ASM File** | `extracted/system/system_core.asm` |

#### Description

**Unreferenced** routine — no `JSR`/`JSL` callers exist in the ROM. Performs a DMA fill of **512 bytes** at WRAM address `$000422` using a fixed fill byte **`$E0`** stored at `wram_fill_constant` (`$00846C`). Likely a debug tool, cut feature, or development leftover.

Uses DMA channel 0 in fill mode (`$DMAP0 = $08` — fixed source byte, incrementing destination). Destination is WRAM via `$2181`/`$2183` (`WMADDL`/`WMADDH`).

#### Algorithm

| Step | Action |
|------|--------|
| 1 | Set `$WMADDL/H` = `$0422` (WRAM destination) |
| 2 | Set `$DAS0L/H` = `$0200` (512 bytes) |
| 3 | Set `$DMAP0` = `$08` (fill mode, A→B) |
| 4 | Set `$BBAD0` = `$80` (WRAM `$2180` port) |
| 5 | Set `$A1B0` = `$00` (source bank — ROM `$00846C`) |
| 6 | Set `$A1T0L/H` = address of `byte_00846C` (`$E0` constant) |
| 7 | Write `$MDMAEN` = `$01` — start fill |
| 8 | `RTS` |

#### Variables / Constants

| Address | Size | Name | Role |
|---------|------|------|------|
| `$000422` | 512 | WRAM fill target | Destination buffer |
| `$00846C` | 1 | `wram_fill_constant` | Fill byte value `$E0` |

#### SNES Registers Written

| Register | Purpose |
|----------|---------|
| `$2181`/`$2183` (`WMADDL/H`) | WRAM write address |
| `$4305` (`DAS0L/H`) | Transfer size |
| `$4300` (`DMAP0`) | DMA mode ($08 = fill) |
| `$4301` (`BBAD0`) | Destination `$2180` |
| `$4304` (`A1B0`) | Source bank |
| `$4302` (`A1T0L/H`) | Source address (constant byte) |
| `$420B` (`MDMAEN`) | Start DMA |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | *(none)* | `_noref` suffix in original label |
| Data | `wram_fill_constant` @ `$00846C` | Single byte `$E0` |
| Next symbol | `CopDispatch` @ `$00846D` | COP engine follows immediately after |
| Cataloged in | `us/names.json` @ 33848 | |

---

## NMI Timing Budget

| Phase | Typical Cost | Notes |
|-------|--------------|-------|
| Context save + HDMA disable | ~30 cycles | Fixed overhead |
| Scroll upload | ~200 cycles | 2 layers × register writes |
| OAM DMA | ~500+ cycles | 544 bytes to `$2104` |
| CGRAM DMA | ~500 cycles | 512 bytes palette |
| VRAM DMA | Variable | Depends on `$00B2`; largest cost |
| HDMA enable + joypad | ~100 cycles | Includes `HVBJOY` poll |
| Music handshake frame | **Full frame cost** | Only when `$06FA` active |
| Context restore | ~30 cycles | `RTI` |

When `$06FA` triggers `UpdateFrame_Full`, the NMI handler may exceed normal VBlank budget — this is intentional during music transitions where the APU requires main-thread simulation to proceed in lockstep.

---

## Call Graph (NMI Group)

```
NmiHandler ($82F8)
├── UploadScrollRegisters ($8387)
│   └── WriteBgScroll ($83D4) [×2]
├── func_02AF5F — OAM upload ($02)
├── func_029DE2 — CGRAM upload ($02)
├── func_029E1D — PPU state ($02)
├── func_02B038 — VRAM queue ($02)
├── func_03D881 — special BG3 ($03) [conditional]
├── func_03F1D0 — tilemap prep ($03)
├── func_02A310 — VRAM flush ($03)
├── ExecuteVramDma ($8411)
├── UpdateFrame_Full ($81BC) [if $06FA ≠ 0]
└── (joypad, APU, $0036++)

FillWramBlock ($8438) — UNREFERENCED
```

---

*Source: analysis of `extracted/system/system_core.asm`, `us/names.json`, `us/blocks.json`. Names cataloged 2026-09-06.*
