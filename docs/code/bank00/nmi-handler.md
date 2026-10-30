# Bank $00 — NMI/VBlank Handler & DMA

*Part of the [Bank $00 Documentation Suite](README.md)*

> The VBlank interrupt handler — the only place where scroll PPU writes, OAM/CGRAM/VRAM DMA, HDMA enable, hardware joypad latch, and APU I/O port writes run for each displayed frame.

## Source of truth

Primary: `extracted/system/engine/system_core.asm` (`NmiHandler`, `UploadScrollRegisters`, `WriteBgScroll`, `ExecuteVramDma`, `OamFillE0_unused`)

Related: `extracted/system/engine/camera_tilemap.asm` (`FlushDirtyTilemapStrips`, `Bg3TilemapVramDma`), `extracted/system/engine/system_init.asm` (`UploadCgramPalette`, `UploadOamTable`), `extracted/system/engine/hdma_dma_spc.asm` (`DmaAdhocVramBlock`, `DmaPlayerTilesToVram`), `extracted/system/engine/event_blocks.asm` (`FlushVramWriteQueue`), `extracted/system/engine/vblank_joypad.asm` (`EnableNmiAndJoypad`, `VBlankWaitAndJoypad`), `db-us/names/bank00.json`.

**Naming:** Symbol names match extracted labels. WRAM names in the variable table use **`db-us` / asm equates** where noted (`joypadRaw`, `displayModeFlags`, `dmaSkipFlag`, `musicTransitionState`, `sfxQueueCh1`).

**Counts:** `OamFillE0_unused` — **dead/unreferenced** (stated in `system_core.asm`); no caller `rg` hits in extracted tree this session.

---

## Overview

Every visible frame enters **`NmiHandler`** at **`$82F8`**. The main loop (`SystemInit` → `MainLoop`) ends each pass with **`EnableNmiAndJoypad`** and begins the next with **`VBlankWaitAndJoypad`** (bank `$02`); NMI runs on the interrupt stack and performs PPU/DMA/APU work. Game logic (actors, collision, etc.) runs on the main thread except when **`UpdateFrameFull`** is invoked from NMI during a blocking music upload.

| Function | Address | Size (label span) | Role |
|----------|---------|-------------------|------|
| `NmiHandler` | `$82F8` | 143 B (`$82F8`–`$8386`) | VBlank ISR |
| `UploadScrollRegisters` | `$8387` | 77 B | BG1/BG2 scroll register writes |
| `WriteBgScroll` | `$83D4` | 61 B | One layer H/V scroll + overrides |
| `ExecuteVramDma` | `$8411` | 39 B | DMA channel 0 from DP staging |
| `OamFillE0_unused` | `$8438` | 52 B | **Dead** — WRAM OAM fill stub |

### Main thread vs NMI

```text
Main thread (MainLoop)                 NMI (NmiHandler @ $82F8)
------------------------               ---------------------------
Actors, collision, camera prep   |     STZ HDMAEN; scroll + DMA uploads
Build OAM / HDMA table ($66)     |     HDMAEN <- $66
EnableNmiAndJoypad at loop end   |     Latch JOY1L -> joypadRaw (hardware)
VBlankWaitAndJoypad at loop start|     Optional UpdateFrameFull (music upload)
                                   |     APUIO2 handshake (music idle only)
                                   |     INC $36; RTI
```

**Joypad:** NMI stores **raw hardware** **`JOY1L`** into **`joypadRaw` (`$0660`)**. Remapping, consumption masks, and **`joypadCurrent`** are applied later in **`VBlankWaitAndJoypad`** / **`VBlankPartial`** (bank `$02`), not in `NmiHandler`.

---

## NmiHandler (`$82F8`)

### Hardware / engine assumptions

- **Direct page:** Handler does **not** **`PHD`/`PLD`**. It uses DP-relative **`$36`**, **`$66`**, **`$00AC`–`$00B2`** expecting **DP = `$0000`**. This matches **`SystemInit`** (`TCD` → `$0000`) and **`UpdateFrameFull`** (sets **`TCD`** before nested work). Custom code that enables NMI must keep **DP = 0** during VBlank sync (see `AGENTS.md` / patch docs).
- **DBR:** Set to **`$81`** after save (FastROM data bank for WRAM **`$0000`** reads).
- **Interrupt masking:** Handler runs with CPU interrupt state from entry; the NMI is enabled (**`NMITIMEN` = `$81`**, `EnableNmiAndJoypad`) **only during the VBlank wait** at the end of a main-loop pass. The main thread (actors, collision, COP handlers) runs with **`NMITIMEN` = `$01`** (NMI off, joypad auto-read on), so an NMI never interrupts it; the one exception is the first `UpdateFrameDialogue` pass after a scene load (16 of 19 loads), which runs `RunActors_CutsceneOnly` with `$81`. `UpdateFrameFull` (called from this handler during a music upload) switches the NMI off first. Measured table: [`hardware-and-init.md` §NMITIMEN state by caller](../bank02/hardware-and-init.md#nmitimen-state-by-caller-measured).

### Execution flow (source order)

Steps marked **HW** touch PPU/APU/DMA registers; **GL** touch game WRAM only.

| # | Kind | Action |
|---|------|--------|
| 1 | — | **`PHP`/`PHB`/`REP #$20`/`PHA`/`PHX`/`PHY`/`CLD`** — save context (no **`PHD`**) |
| 2 | — | **`DBR = $81`**, **`STZ HDMAEN`** **HW** |
| 3 | call | **`JSR UploadScrollRegisters`** **HW** |
| 4 | call | **`JSL FlushDirtyTilemapStrips`** (bank `$02`) **HW** |
| 5 | call | **`JSL UploadCgramPalette`** (`system_init`) **HW** |
| 6 | call | **`JSL UploadOamTable`** (`system_init`) **HW** |
| 7 | call | **`JSL Bg3TilemapVramDma`** (bank `$02`) **HW** |
| 8 | inline | **`VMAIN=$80`**, **`BBAD0=$18`**, **`DMAP0=$01`** — DMA ch0 setup **HW** |
| 9 | branch | **VRAM path** (see diagram below) **HW** |
| 10 | GL/HW | **`LDA $66` / `STA HDMAEN`** — re-enable HDMA from main-thread mask |
| 11 | HW | Poll **`HVBJOY`** until auto-joypad read finished |
| 12 | HW | **`JOY1L` → `joypadRaw`** |
| 13 | branch | **`musicTransitionState`**: if **> 0** and **< `$8000`**, **`JSL UpdateFrameFull`** **GL** (full mini-frame during SPC upload) |
| 14 | branch | If **`musicTransitionState == 0`**: even/odd via **`$36` LSR** → dequeue **`sfxQueueCh1`** to **`APUIO2`** on even frames, **`0`** on odd **HW** |
| 15 | GL | **`INC $36`** (16-bit frame parity at DP **`$36`**) |
| 16 | — | Restore **`Y`/`X`/`A`/`B`/`P`**, **`RTI`** |

**Skipped paths:** When **`musicTransitionState ≠ 0`**, step 14 (APU dequeue) is **not** executed. When **`musicTransitionState = $FFFF`**, step 13 skips **`UpdateFrameFull`** (**`BMI`** to parity increment).

### VRAM DMA path (step 9)

```text
displayModeFlags bit 3 ($08) set?
  YES -> JSL DmaPlayerTilesToVram (bank $03)  [player-tile path; clears the bit]
  NO  -> dmaSkipFlag ($0800) nonzero?
          YES -> JSL FlushVramWriteQueue ONLY (event_blocks)
          NO  -> JSL DmaAdhocVramBlock (hdma_dma_spc)
                 JSL FlushVramWriteQueue
                 JSR ExecuteVramDma
        -> merge at HDMA re-enable (step 10)
```

**Adhoc transfer timing (measured, Mesen2 C1).** The transfer staged at `$7F:0C03`-`$7F:0C09` runs in the first NMI after the staging (the destination word `$7F:0C07` is the pending flag; `DmaAdhocVramBlock` zeroes it, clear latency 1 NMI in 26 of 27 cases and 2 NMIs once, when the first NMI skipped the block because `dmaSkipFlag` or `displayModeFlags` bit 3 was set). Both writers store the destination before the size and are safe because no NMI can run between their two stores; see [`wram-memory-map.md` §4.3](../../wram-memory-map.md#43-adhoc-dma-parameters-7f0c037f0c09). `Bg3TilemapVramDma` (step 7) is a separate, earlier upload driven by `displayModeFlags` bits 0/4/5 and gated by `hudDisableFlag` bit 7; see [Display Mode Flags Reference](../../wram-memory-map.md#display-mode-flags-reference-09ec).

**Ordering note:** Adhoc path runs **`DmaAdhocVramBlock`** before **`FlushVramWriteQueue`** then **`ExecuteVramDma`** (DP **`$AC`–`$B2`**). **`dmaSkipFlag`** bypasses adhoc staging and **`ExecuteVramDma`** but still **flushes** the VRAM write queue.

### Variables referenced in NMI

| Address | Label (asm) | Step | Role |
|---------|-------------|------|------|
| `$0036` | (frame parity) | 14–15 | Even/odd APU **`APUIO2`** timing; incremented every NMI |
| `$0066` | HDMA enable cache | 10 | Channel mask → **`HDMAEN`** |
| `$0660` | `joypadRaw` | 12 | Raw **`JOY1L`** latch |
| `$0800` | `dmaSkipFlag` | 9 | Nonzero → skip adhoc + **`ExecuteVramDma`** |
| `$06F8` | `sfxQueueCh1` | 14 | Pending SFX ID for APU (even frames) |
| `$06FA` | `musicTransitionState` | 13–14 | **`0`** idle; **`>0`** SPC upload → **`UpdateFrameFull`**; **`$FFFF`** finished |
| `$09EC` | `displayModeFlags` | 7, 9 | Step 7 (`Bg3TilemapVramDma`): bits **`$01`** (full BG3 upload, `$0800` bytes `$7F:0200` → VRAM `$7800`), **`$10`/`$20`** (partial, `$0140` bytes → VRAM `$7840`), gated by `$09ED` bit 7. Step 9: bit **`$08`** → **`DmaPlayerTilesToVram`** instead of normal path |
| `$00AC`–`$00B2` | (DP staging) | 9 | **`ExecuteVramDma`** source/dest/size |

### Cross-references

| Symbol | Relationship |
|--------|--------------|
| `NmiVector` (`$800B`) | **`JML NmiHandler`** each VBlank |
| `EnableNmiAndJoypad` / `VBlankWaitAndJoypad` | Frame sync (bank `$02`) |
| `UpdateFrameFull` | **Live** — NMI when **`musicTransitionState`** active during **`LoadMusicFromTransitionState`** |
| `OamFillE0_unused` | **Dead** — no callers |

---

## UploadScrollRegisters (`$8387`)

**Live** — **`NmiHandler`** step 3.

Two modes via **`scrollModeFlags` (`$06EF`)** bit **`$08`**:

- **Normal (bit clear):** Two **`JSR WriteBgScroll`** calls; order swapped when **`layerPriorityFlag` (`$06EE`)** is negative (BG2 first vs BG1 first).
- **Direct (bit set):** Writes **`bg1ScrollH` / `$068B` / `mapScrollV` / `$068F`** to **BG1** **`BG1HOFS`/`BG1VOFS` only** (high bytes masked **`AND #$7F`** in this path). Does **not** write BG2 registers in extracted code.

---

## WriteBgScroll (`$83D4`)

**Live** — called from **`UploadScrollRegisters`**.

**X** = scroll data index (**`0`** BG1, **`2`** BG2); **Y** = PPU register pair offset. Override when **`$06C7,X` / `$06CB,X`** negative (bit 7): use **`scrollOverrideH/V`**. Scroll high bytes **`AND #$03`** (10-bit Mode 1 scroll).

---

## ExecuteVramDma (`$8411`)

**Live** — **`NmiHandler`** adhoc path finale.

Reads DP **`$00B2`** (size); **RTS** if zero. Else programs DMA channel 0 (**`A1T0`**, **`VMADD`**, **`DAS0`**, **`MDMAEN`**) and clears **`$00B2`**.

| DP | → SNES | Purpose |
|----|--------|---------|
| `$00AC`–`$00AE` | `$4302`–`$4304` | Source |
| `$00B0` | `$2116` | VRAM word address |
| `$00B2` | `$4305` | Byte count |

---

## OamFillE0_unused (`$8438`)

**Dead/unreferenced** — DMA fill **`$E0`** × 512 bytes to WRAM **`$0422`**. **`OamFillConstant_unused`** (`$846C`) immediately precedes **`CopDispatch`** in ROM.

---

## Timing budget (source-anchored)

| Phase | Cost | Source note |
|-------|------|-------------|
| Entry + **`HDMAEN=0`** | Fixed small | `NmiHandler` prologue |
| Scroll | ~hundreds of cycles | **`UploadScrollRegisters`** / **`WriteBgScroll`** |
| Strip flush | Variable, often largest | **`FlushDirtyTilemapStrips`** comment trail in `camera_tilemap.asm` |
| CGRAM DMA | ~512 B transfer | **`UploadCgramPalette`** |
| OAM DMA | 544 B | **`UploadOamTable`** |
| BG3 + adhoc VRAM | Variable | **`Bg3TilemapVramDma`**, optional **`DmaPlayerTilesToVram`**, **`ExecuteVramDma`** |
| Joypad poll | Spin on **`HVBJOY`** | Until auto-read complete |
| **`UpdateFrameFull`** | **Up to full frame** | Only when **`musicTransitionState > 0`** — intentional overlap with main-thread SPC blocking |
| APU **`APUIO2`** | Small | Even frames only when music idle |

NTSC VBlank ≈ **~20k cycles**; normal path targets fitting in one VBlank; music-upload **`UpdateFrameFull`** path **by design** can exceed it.

---

## Call graph

```text
NmiHandler ($82F8)
├── UploadScrollRegisters ($8387)
│   └── WriteBgScroll ($83D4) [×2 in normal mode]
├── FlushDirtyTilemapStrips ($02)
├── UploadCgramPalette (system_init)
├── UploadOamTable (system_init)
├── Bg3TilemapVramDma ($02)
├── [displayModeFlags.$08 ? DmaPlayerTilesToVram ($03)
│   : dmaSkipFlag ? FlushVramWriteQueue only
│   : DmaAdhocVramBlock ($03) → FlushVramWriteQueue → ExecuteVramDma ($8411)]
├── UpdateFrameFull ($81BC) [if musicTransitionState in (0,$8000)]
└── (joypad latch, conditional APUIO2, INC $36)

OamFillE0_unused ($8438) — UNREFERENCED
```

---

**See also:** [system-core.md](system-core.md) · [cop-dispatch.md](cop-dispatch.md) · [data-tables-memory.md](data-tables-memory.md)

---

## Source validation

**Files checked:** `extracted/system/engine/system_core.asm` (NMI block lines 546–623, helpers through **`OamFillE0_unused`**), `vblank_joypad.asm` (NMI/joypad split), `db-us/names/bank00.json` (address spans).

**Verified:** Full **`NmiHandler`** instruction order; DMA branch conditions (**`displayModeFlags` `$08`**, **`dmaSkipFlag`**); **`musicTransitionState`** **`BEQ`/`BMI`/`JSL UpdateFrameFull`** behavior; APU path only when music state **0**; **`$36`/`sfxQueueCh1`/`APUIO2`** even-frame dequeue; no **`PHD`**; sizes **`143/77/61/39/52`** from label address differences; **`OamFillE0_unused`** unreferenced; direct scroll mode BG1-only writes.

**Notes:** Step numbering in this doc replaces the earlier fixed “19-step” list with source-ordered phases plus explicit skipped paths. Joypad remapping documented per `vblank_joypad.asm` header, not re-verified instruction-by-instruction in bank `$02`.
