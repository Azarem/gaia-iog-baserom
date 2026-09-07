# chunk_008000.asm — System Code Page Deep Analysis

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$008000`–`$00B530`  
**Size:** ~13,616 bytes  
**Files:** `extracted/system/system_core.asm`, `cop_dispatch.asm`, `cop_handlers_actors.asm`, `cop_handlers_collision.asm`, `cop_handlers_script.asm`

This is the primary system code page for Illusion of Gaia. It contains the CPU
interrupt vectors, the main game loop, the NMI/VBlank handler, the COP bytecode
dispatch engine, and the core utility library for actor management, collision,
event flags, animation, and memory allocation.

> **COP handler documentation** has been moved to
> [`cop-commands-reference.md`](../cop-commands-reference.md) and
> `us/copdef.json`. This document covers the system architecture, utility
> subroutines, data tables, and variable maps only.

---

## Table of Contents

1. [Includes & Hardware Constants](#1-includes--hardware-constants)
2. [Interrupt Vectors & Reset](#2-interrupt-vectors--reset)
3. [Main Game Loop](#3-main-game-loop)
4. [Frame Update Functions](#4-frame-update-functions)
5. [NMI / VBlank Handler](#5-nmi--vblank-handler)
6. [COP Dispatch Engine](#6-cop-dispatch-engine)
7. [Utility Subroutines](#7-utility-subroutines)
8. [Data Tables](#8-data-tables)
9. [Call Reference Matrix](#9-call-reference-matrix)
10. [Variable / Memory Map](#10-variable--memory-map)
11. [Stack Usage Summary](#11-stack-usage-summary)
12. [Statistics](#12-statistics)

---

## 1. Includes & Hardware Constants

### Includes (`?INCLUDE`)

| Include | Purpose |
|---------|---------|
| `binary_01C384` | Sine/cosine lookup data (referenced by HUD pointer init) |
| `binary_01D8BE` | DMA channel configuration bytes |
| `body_table` | Player body sprite-set index table (Will/Freedan/Shadow) |
| `chunk_028000` | Bank $02 system functions (rendering, DMA, APU, actors) |
| `chunk_038000` | Bank $03 system functions (scenes, actors, text, metatiles) |
| `chunk_03BAE1` | Bank $03 extended (music, facing, animation helpers) |
| `func_00F3C9` | Orbital/spiral movement math |
| `func_0AA3A7` | Grid-snap walk helper (deferred resume target) |
| `system_strings` | System ASCII strings (BG3 HUD overlays) |
| `table_01B086` | Animation frame duration/speed lookup table |

### Hardware Register Aliases

| Alias | SNES Register | Use in this chunk |
|-------|---------------|-------------------|
| `L_WRMPYB` ($804203) | `WRMPYB` | Hardware 8×8 multiply (B operand) |
| `L_WRDIVL` ($804204) | `WRDIVL` | Hardware divide (dividend low) |
| `L_WRDIVB` ($804206) | `WRDIVB` | Hardware divide (divisor) |
| `L_RDDIVL` ($804214) | `RDDIVL` | Division quotient read |
| `L_RDMPYL` ($804216) | `RDMPYL` | Multiply product low read |
| `L_RDMPYH` ($804217) | `RDMPYH` | Multiply product high read |

---

## 2. Interrupt Vectors & Reset

### `ResetVector` ($008000) — CPU Reset Vector

- **ASM label:** `emulation_mode_reset_008000`
- **Purpose:** Entry point on power-on/reset. Switches from emulation to native 65816 mode.
- **Size:** 7 bytes
- **Flow:** `SEI` → `CLC` → `XCE` (enter native mode) → `JML` to `SystemInit`
- **Stack:** None (CPU just powered on)

### `CopVector` ($008007) — COP Vector Trampoline

- **ASM label:** `native_mode_cop_008007`
- **Purpose:** Hardware COP interrupt vector. Jumps to the full COP dispatch engine.
- **Size:** 4 bytes
- **Flow:** `JML $@CopDispatch`

### `NmiVector` ($00800B) — NMI Vector Trampoline

- **ASM label:** `native_mode_nmi_00800B`
- **Purpose:** Hardware NMI (VBlank) interrupt vector. Jumps to the NMI handler.
- **Size:** 4 bytes
- **Flow:** `JML $@NmiHandler`

### `IrqVector` ($00800F) — IRQ Vector Trampoline

- **ASM label:** `native_mode_irq_00800F`
- **Purpose:** Hardware IRQ interrupt vector. Jumps to the IRQ handler.
- **Size:** 4 bytes
- **Flow:** `JML $@IrqHandler`

### `IrqHandler` ($008013) — IRQ Handler (Stub)

- **ASM label:** `native_mode_irq_handler_008013`
- **Purpose:** IRQ handler — does nothing. The game does not use IRQ interrupts.
- **Size:** 1 byte
- **Flow:** `RTI`

---

## 3. Main Game Loop

### `SystemInit` ($008014) — System Initialization & Main Loop

- **ASM label:** `emulation_mode_reset_handler_008014`
- **Purpose:** Complete system initialization and the eternal main game loop.
- **Size:** ~166 bytes

#### Initialization Phase (runs once)

| Step | Code | Effect |
|------|------|--------|
| 1 | `CLD`, `REP #$30`, `LDA #$0000`, `TCD` | Clear decimal, 16-bit A/X, direct page = $0000 |
| 2 | `LDA #$01FF`, `TCS` | Stack pointer = $01FF |
| 3 | `LDA #$81`, `PHA`, `PLB` | Data bank = $81 |
| 4 | `LDA #$01`, `STA $MEMSEL` | Enable FastROM (3.58 MHz) |
| 5 | `JSL func_029F31` | Initialize PPU registers |
| 6 | `JSL func_029E44` | Clear VRAM |
| 7 | `JSL func_02908E` | Initialize WRAM/game state |
| 8 | `JSL func_0281BC` | Initialize actor system |
| 9 | Check `$000100` for magic `$83` | SRAM validity check → set starting scene |
| 10 | `JSL func_03D9F6` | Load initial scene |
| 11 | Initialize HUD pointers | `binary_01C384` addresses → `$09BA`–`$09C4` |
| 12 | Initialize stat display | DEF/STR/HP counters → `$0ACA`–`$0ADE` |
| 13 | Set `$scene_next = $FB` | Enter title screen scene |

#### Main Loop (runs every frame at `loc_0080B5`)

| Step | Call | Purpose |
|------|------|---------|
| 1 | `JSL func_028043` | Begin frame — prepare rendering state |
| 2 | `JSL func_0281A2` | Process scene transitions |
| 3 | `JSL func_03D12D` | Update map/scroll state |
| 4 | `JSL func_03D9E8` | Process scene loading |
| 5 | `JSL func_02A5DD` | Update palette animation |
| 6 | `JSL func_038000` | Run scene-specific logic |
| 7 | `JSR UpdateFrameCounters` | Update frame counters |
| 8 | `JSL run_actors_03CAF5` | Execute all actor COP scripts |
| 9 | Mark current OAM slot | `$7F3100/01 = $FF` at `$00D8` offset |
| 10 | `JSL func_03C5FF` | Sort/compose OAM table |
| 11 | `JSL func_03BBE4` | Process collision responses |
| 12 | `JSL code_03C25E` | Run actor collision detection |
| 13 | `JSL func_03BBB4` | Finalize collision results |
| 14 | `JSL func_03BB85` | Update actor positions from velocity |
| 15 | `JSL func_02AC2E` (×2) | Update BG layer scroll (X=0, X=2) |
| 16 | `JSL func_03E146` | Update HDMA channels |
| 17 | `JSL func_03D15D` | Process map tile updates |
| 18 | `JSL func_03C714` | Finalize sprite rendering |
| 19 | `JSL UpdateHUD` | Update HUD/status bar |
| 20 | `JSL func_03E21E` | Process deferred DMA requests |
| 21 | `JSL func_028191` | End frame — wait for VBlank |
| 22 | `BRL loc_0080B5` | Loop forever |

- **Variables:** `$00D8` (OAM write offset), `$scene_next`, `$0654`, `$099F`, `$09C8/$09CA`, `$0ACA/$0ACE/$0ADE/$0ADC`, `$09BA`–`$09C4`, `$0B28`–`$0B32`
- **Stack usage:** Standard frame (no deep nesting from this level)

---

## 4. Frame Update Functions

### `UpdateFrame_Dialogue` ($00811E) — Dialogue/Cutscene Frame Update

- **ASM label:** `func_00811E`
- **Purpose:** Abbreviated frame update used during dialogue and cutscenes. Updates sprites, scroll layers, HDMA, and begins next frame — but skips collision, scene logic, and map updates.
- **Size:** ~40 bytes
- **Calls:** `func_03CCFF`, `func_03C5FF`, `func_02AC2E` (×2), `func_03E146`, `func_03D1C2`, `func_03C714`, `func_028191`, `func_028043`, `func_0281A2`, `func_03D18D`
- **Stack:** `PHB`, `PHA`, `XBA`, `PHA`, `PHX`, `PHY`, `PHD` → full context save/restore
- **Register state:** Sets `D=$0000`, `DBR=$81`
- **Variables:** `$00D8`, `$7F3100/01`, `$09EC` (clears bit `$08`)

### `UpdateFrame_Render` ($00817D) — Simplified Render Pipeline

- **ASM label:** `func_00817D`
- **Purpose:** Even lighter frame update — only sprite sorting, HDMA, scroll finalization, and frame begin/end. Used for text rendering overlays.
- **Size:** ~30 bytes
- **Calls:** `func_03C5FF`, `func_03C714`, `func_03E146`, `func_03D1C2`, `UpdateHUD`, `func_028191`, `func_028043`, `func_0281A2`, `func_03D18D`
- **Stack:** `PHB`, `PHA`, `XBA`, `PHA`, `PHX`, `PHY`, `PHD` → full context save/restore
- **Register state:** Sets `D=$0000`, `DBR=$81`

### `UpdateFrame_Full` ($0081BC) — Full Frame Update (with Collision)

- **ASM label:** `func_0081BC`
- **Purpose:** Full single-frame update including collision, actors, sorting. Called from NMI handler when `$06FA` (music handshake) is active.
- **Size:** ~46 bytes
- **Called by:** `NmiHandler` (when `$06FA ≠ 0`)
- **Calls:** `func_0281A2`, `func_02803B`, `func_03D18D`, `func_03CD6E`, `func_03C5FF`, `func_02AC2E` (×2), `func_03E146`, `func_03D1C2`, `func_03C714`, `func_028191`
- **Stack:** `PHP`, `PHB` → saves flags and data bank
- **Register state:** Sets `DBR=$81`
- **Variables:** `$00D8`, `$7F3100/01`

### `UpdateHUD` ($008206) — HUD / Status Bar Update

- **ASM label:** `func_008206`
- **Purpose:** Updates the BG3 status bar overlay showing HP, DEF, STR values. Handles damage flash, gem counter display, and experience point text.
- **Size:** ~216 bytes
- **Called by:** Main loop (step 19), `UpdateFrame_Render`
- **Calls:** COP `PlaySoundCh2` (#0D) inline, COP `RunBg3Script` inline (references `asciistring_01E7F6`, `asciistring_01E818`)
- **Stack:** `PHP`, `PHA` (flag save for `$09EC` bit 0)

#### HUD Logic Flow

1. Check `$09ED` bit `$40` — if set, HUD is disabled, return immediately
2. **Damage flash:** Every 8 frames (when `$0B22 ≠ 0`), increment `$0ACE` toward `$0ACA` and play sound effect #$0D
3. **Stat comparison:** Compare current DEF/HP/gem values against cached previous values (`$0AD0`/`$0ACC`/`$0ADA`)
4. **Gem hundreds:** Compute `$0AD8 = $0AD6 / 100` for three-digit display
5. **Experience display:** When `$09EA ≠ 0`, set `$0AE4` timer and run BG3 script for XP text; timer counts down and clears display after `$001E` frames
6. **Cache update:** Copy current stat values to previous-value cache
7. **Restore flags:** Merge saved `$09EC` bit 0 back

- **Variables read:** `$09ED` (HUD disable flag, bit `$40`), `$09EC` (display flags), `$09AF`, `$0036` (frame counter), `$0B22` (damage flash timer), `$0ACE`/`$0ACA` (current/max DEF), `$0AD0`/`$0ACC`/`$0ADA` (previous stat values), `$0AD6` (gem count), `$0AD8` (gem hundreds), `$09EA` (experience pending), `$0AE4` (experience display timer), `$09E4`/`$09E6` (experience values)
- **Variables written:** `$09EC` (bit `$10` set when display needs refresh)

### `UpdateFrameCounters` ($0082DE) — Frame Counter Update

- **ASM label:** `sub_0082DE`
- **Purpose:** Decrements the global invincibility timer `$040C` (stops at -1) and increments the global frame timer `$040E` (caps at `$0100`).
- **Size:** 18 bytes
- **Called by:** Main loop (step 7)
- **Stack:** `PHP`/`PLP`
- **Variables:** `$040C` (invincibility frames, decrements to -1), `$040E` (frame counter, increments to $0100)

---

## 5. NMI / VBlank Handler

### `NmiHandler` ($0082F8) — VBlank Interrupt Handler

- **ASM label:** `native_mode_nmi_handler_0082F8`
- **Purpose:** Executes during every vertical blanking interval. Performs all SNES PPU register writes, DMA transfers, HDMA setup, input polling, and audio communication.
- **Size:** ~144 bytes

#### Execution Flow

| Step | Code | Purpose |
|------|------|---------|
| 1 | Save context | `PHP`, `PHB`, `PHA`, `PHX`, `PHY`, `CLD` |
| 2 | `DBR=$81` | Set data bank for game WRAM access |
| 3 | `STZ $HDMAEN` | Disable HDMA during register writes |
| 4 | `JSR UploadScrollRegisters` | Upload BG scroll registers |
| 5 | `JSL func_02AF5F` | Upload OAM data to PPU |
| 6 | `JSL func_029DE2` | Upload CGRAM (palette) data |
| 7 | `JSL func_029E1D` | Upload additional PPU state |
| 8 | `JSL func_02B038` | Process pending VRAM transfers |
| 9 | Set VRAM mode | `VMAIN=$80`, `BBAD0=$18`, `DMAP0=$01` |
| 10 | Check `$09EC` bit 3 | If set → `func_03D881` (special BG3 mode) |
| 11 | Check `$0800` | If set → skip tilemap DMA |
| 12 | Normal path | `func_03F1D0` + `func_02A310` + `ExecuteVramDma` |
| 13 | Enable HDMA | `$66 → $HDMAEN` |
| 14 | Wait for H-blank end | Poll `$HVBJOY` bit 0 |
| 15 | Read joypad | `$JOY1L → $0660` |
| 16 | Music handshake | If `$06FA ≠ 0` → `UpdateFrame_Full` (full frame during music transition) |
| 17 | APU communication | Even/odd frame: send `$06F8` → `$APUIO2` |
| 18 | Increment `$36` | Frame parity counter |
| 19 | Restore context | `PLY`, `PLX`, `PLA`, `PLB`, `PLP`, `RTI` |

- **Stack depth:** 12 bytes (6 pushes × 2 + processor status)
- **Critical variables:** `$66` (HDMA channel mask), `$0660` (raw joypad), `$06FA` (music state), `$06F8` (SFX channel 1), `$36` (frame counter), `$0800` (DMA skip flag), `$09EC` (display mode flags)

### `UploadScrollRegisters` ($008387) — BG Scroll Register Upload

- **ASM label:** `sub_008387`
- **Purpose:** Writes BG1–BG2 horizontal and vertical scroll registers to the PPU. Supports two modes: normal (priority-ordered layers) and locked (direct register write).
- **Size:** ~80 bytes
- **Called by:** `NmiHandler`
- **Calls:** `WriteBgScroll` (×2 in normal mode)
- **Variables:** `$06EF` (bit 3: locked scroll mode), `$06EE` (layer priority: 0=BG1 first, negative=BG2 first), `$068A`–`$068F` (BG1 scroll values), `$06C6`–`$06CB` (override scroll values)

#### Mode Selection

- **Normal mode** (`$06EF` bit 3 clear): Calls `WriteBgScroll` twice with layer ordering determined by `$06EE` sign. If `$06EE ≥ 0`, BG1 first (X=0, Y=0 then X=2, Y=2). If negative, BG2 first.
- **Locked mode** (`$06EF` bit 3 set): Directly writes `$068A`–`$068F` to `BG1HOFS`/`BG1VOFS` without override logic.

### `WriteBgScroll` ($0083D4) — Individual BG Scroll Write

- **ASM label:** `sub_0083D4`
- **Purpose:** Writes H and V scroll for one BG layer to `$BG1HOFS+Y` / `$BG1VOFS+Y`. Uses override values from `$06C6+X` if negative flag set, otherwise normal values from `$068A+X`.
- **Size:** ~46 bytes
- **Called by:** `UploadScrollRegisters` (X=layer source offset, Y=register offset)

#### Override Logic

- **H scroll:** If `$06C7,X` is negative → use `$06C6,X` (override). Otherwise use `$068A,X` (normal). High byte is masked to `$03`.
- **V scroll:** If `$06CB,X` is negative → use `$06CA,X` (override). Otherwise use `$068E,X` (normal). High byte is masked to `$03`.

### `ExecuteVramDma` ($008411) — Execute VRAM DMA Transfer

- **ASM label:** `sub_008411`
- **Purpose:** Performs a single VRAM DMA transfer using parameters stored in direct page.
- **Size:** ~26 bytes
- **Called by:** `NmiHandler` (normal rendering path)
- **Variables:** `$00B2` (transfer size — zero means no transfer), `$00B0` (VRAM destination word address), `$00AC` (DMA source address), `$00AE` (DMA source bank)
- **Registers written:** `$DAS0L`, `$VMADDL`, `$A1T0L`, `$A1B0`, `$MDMAEN`

### `FillWramBlock` ($008438) — WRAM Fill (Unused)

- **ASM label:** `sub_008438_noref`
- **Purpose:** DMA fill of 512 bytes at WRAM `$000422` from a constant byte `$E0` at address `$80846C`. Unreferenced — likely debug or cut feature.
- **Size:** ~32 bytes
- **Registers written:** `$WMADDL/H`, `$DAS0L`, `$DMAP0`, `$BBAD0`, `$A1B0`, `$A1T0L`, `$MDMAEN`

---

## 6. COP Dispatch Engine

### `CopDispatch` ($00846D) — COP Bytecode Dispatch

- **ASM label:** `CopDispatch`
- **Purpose:** Central dispatch for the COP bytecode instruction set. Every actor and thinker script instruction routes through this 24-byte engine.
- **Size:** 24 bytes

#### Dispatch Algorithm

1. Save actor index: `TXY` (X=actor ID → Y for later restore)
2. Extract return bank: `LDA $04,S → $0C` (COP return bank byte)
3. Compute arg pointer: `LDA $02,S`, `DEC` → `$0A` (points to COP opcode byte)
4. Read opcode byte: `LDA [$0A]`, `INC $0A`, `AND #$00FF`
5. Double for table index: `ASL`, `TAX`
6. Jump through table: `JMP ($&cop_dispatch_table, X)`

#### Entry State (guaranteed for all COP handlers)

| Register | Value |
|----------|-------|
| `A` | Clobbered (contains opcode×2) |
| `X` | Opcode table index |
| `Y` | Actor ID (saved) |
| `$0A` | Pointer to first argument byte |
| `$0C` | Script bank byte |
| `m` | 0 (16-bit A) |
| `x` | 0 (16-bit X/Y) |
| `D` | Actor direct page base |
| `DBR` | $81 |

#### Handler Exit Conventions

| Exit | Method | Meaning |
|------|--------|---------|
| **Continue** | `LDA $0A; STA $02,S; RTI` | Execute next COP instruction |
| **Branch** | `LDA [$0A]; STA $02,S; RTI` | Jump to script address |
| **Halt/Yield** | Store `$0A`→`$00`; `PLA; PLA; RTL` | Return to engine; resume next frame |
| **Kill** | Unlink actor; `RTL` | Actor removed from list |

> **Full COP handler catalog:** See [`cop-commands-reference.md`](../cop-commands-reference.md) for all 172 opcode handlers ($00–$6D, $80–$E2).

---

## 7. Utility Subroutines

### 7.1 Hardware Math Helpers

#### `ReadMultiplyResult` ($008D25)

- **ASM label:** `sub_008D25`
- **Purpose:** NOP delay then read `$RDMPYL` into Y. The NOP provides the required 8-cycle wait for the hardware multiplier.
- **Size:** 4 bytes
- **Called by:** `MultiplyThenDivide`

#### `ReadDivideResult` ($008D2A)

- **ASM label:** `sub_008D2A`
- **Purpose:** Five NOPs (pipeline delay for hardware divider), then load `$RDDIVL`.
- **Size:** 8 bytes
- **Called by:** `MultiplyThenDivide`

#### `MultiplyThenDivide` ($008D33)

- **ASM label:** `sub_008D33`
- **Purpose:** Combined 8×8 multiply → 16/8 divide helper. Stores A in `$WRMPYB`, reads product, divides by `$7F000E,X − 1`, stores quotient in `$0000`.
- **Size:** 24 bytes
- **Called by:** COP $22 (MoveToward)
- **Calls:** `ReadMultiplyResult`, `ReadDivideResult`
- **Variables:** `$WRMPYB`, `$WRDIVL`, `$WRDIVB`, `$RDMPYL`, `$RDDIVL`, `$7F000E,X`, `$0000`

#### `MovementVelocityCompute` ($008FDC)

- **ASM label:** `sub_008FDC`
- **Purpose:** Similar to `MultiplyThenDivide` but used by COP $53 (TickMove). Reads multiply result inline with carry set for velocity calculation. Uses longer NOP pipeline delay for divide.
- **Size:** ~24 bytes
- **Called by:** COP $53 (TickMove)

### 7.2 Movement Initialization

#### `InitSmoothMovement` ($008D4D)

- **ASM label:** `sub_008D4D`
- **Purpose:** Initialize actor smooth-movement state from script parameters. Reads speed/direction, computes absolute deltas from current to target position, stores direction flags, computes step count via `func_0281E8`, sets movement flag bit in `$7F002A,X`.
- **Size:** ~90 bytes
- **Called by:** COP $22 (MoveToward)
- **Calls:** `ProcessAnimFlag`, `func_0281E8`

#### Algorithm

1. Read sprite/direction byte from script args; if `$FF`, use current `$28`
2. Compute `|target_X − actor_X|` and `|target_Y − actor_Y|`; cap each at `$FE`
3. Store direction sign bits in `$0004` (bit 15 = X negative, bit 14 = Y negative)
4. Use the larger delta for step count calculation: `func_0281E8(delta, speed)`
5. Store step count +1 to `$7F000E,X`, speed to `$7F000F,X`
6. Clear accumulators `$7F0000,X`, `$7F0002,X`, step counter `$24`
7. Set `$7F002A,X` bit 1 (actor is moving)

- **Variables written:** `$7F0018,X` (X distance), `$7F001A,X` (Y distance), `$7F000E,X` (direction/steps), `$7F000F,X` (speed), `$7F0000,X`/`$7F0001,X` (accumulators), `$7F0002,X` (step counter), `$7F002A,X` (bit 1 = moving)

#### `HalveMovementDistance` ($008EF1)

- **ASM label:** `sub_008EF1`
- **Purpose:** Halves actor movement distances (`$7F0018,X` and `$7F001A,X` via LSR) and increments the sub-step counter `$7F000A,X`. Used when the maximum distance exceeds one byte.
- **Size:** ~16 bytes
- **Called by:** COP $52 (StageMove)

### 7.3 Tile / Map Helpers

#### `ParseMapEntry` ($0097EF)

- **ASM label:** `sub_0097EF`
- **Purpose:** Parses a map entry structure at index X. Returns carry set if entry is invalid (high bit set). Otherwise extracts tile X/Y from the 3-byte record, sign-extends, and scales ×16 into `$1A`/`$1E`.
- **Size:** ~40 bytes
- **Called by:** COP $4D (WorldMapStream3), COP $4E (WorldMapStream4)

#### Record Format

The map stream at X contains packed 3-byte records:
- Byte 0: tile X coordinate (carry-set = end of stream)
- Byte 1: tile Y coordinate
- Byte 2: metatile or collision type

Output: `$18/$1C` = tile coords, `$1A/$1E` = pixel coords (×16), `$00` = type byte.

#### `ResolveTileData` ($009829)

- **ASM label:** `sub_009829`
- **Purpose:** Resolves tile graphics and metadata from parsed coordinates. Queries `$7F0000`/`$7EA000`/`$7FC000` tile tables, bounds-checks against camera, reads tileset entries from `$7E2000`, stores results in `$0902`–`$090C`.
- **Size:** ~128 bytes
- **Called by:** COP $4B (DrawMetatileAbs), COP $4C (DrawMetatileHere), COP $4D, COP $4E
- **Calls:** `func_02B0A3`, `func_02B0CF`

#### Algorithm

1. Convert tile coords to WRAM index via `func_02B0A3`
2. Write collision type to `$7FC000,X` and tile ID to `$7EA000,X`
3. Bounds-check pixel coords against camera viewport (`$068A`, `$068E`)
4. If on-screen, look up tileset data from `$7E2000` (8 bytes per entry)
5. Store tile graphics pointers in `$0904`–`$090C`
6. Call `func_02B0CF` for VRAM address → `$0902`, `$0908`

#### `TileQueryGate` ($0098A9)

- **ASM label:** `sub_0098A9`
- **Purpose:** Gate function — if `$0902` is non-zero (tile query pending), rewinds `$0A` by 2 and returns carry set (abort COP, retry next frame). Otherwise returns carry clear.
- **Size:** ~16 bytes
- **Called by:** COP $4B–$4E (all metatile/map stream operations)

### 7.4 Animation / Visibility

#### `ProcessAnimFlag` ($009F5F)

- **ASM label:** `sub_009F5F`
- **Purpose:** Processes animation/visibility flag byte passed in A. Handles three modes:
  - `$FF` = no change (preserves current `$28`, clears `$2A`, returns)
  - Bit 7 set = mirror-aware: strip bit 7 for sprite index, check `$12` bit 2 to decide H-flip
  - Bit 7 clear = normal: set sprite index, check `$12` bit 2, clear H-flip if not set
- **Size:** ~32 bytes
- **Called by:** All sprite staging COPs ($80–$87, $8D, $8F–$92), movement init

#### `AnimFrameLookup` ($00B157)

- **ASM label:** `sub_00B157`
- **Purpose:** Animation frame table lookup: `A << 1` → index into `table_01B086`, returns duration/speed value in A.
- **Size:** 8 bytes
- **Called by:** Sprite staging COPs ($81–$87, $90–$92, $94), force-move COPs ($AA–$AC, $B0, $B1)

### 7.5 Sprite / Body Helpers

#### `BuildSineHdmaTable` ($00ADCF)

- **ASM label:** `sub_00ADCF`
- **Purpose:** Builds HDMA displacement data from the sine lookup table at `binary_01C455`. Computes buffer pointers from `$7F0006,X`, uses hardware multiply to scale sine values by amplitude, writes to paired buffers at `($62),Y` and `($5E),Y`. Double-buffered (even/odd frame via `$0036`).
- **Size:** ~150 bytes
- **Called by:** COP $60 (TickSineHdma)

#### Algorithm

1. Compute buffer base from `$7F0006,X + $100` (offset for ping-pong)
2. If frame is odd (`$0036` bit 0), advance both buffers by `$200`
3. Set bank to `$7E`, direct page to `$0000`
4. Compute step size: `$100 / (period/2)` via hardware divide → `$00`
5. Loop through sine table entries, multiply each by amplitude via `$WRMPYB`
6. Handle signed sine values (negative branch uses `$FF` multiply for sign extension)
7. Write displacement to both horizontal and vertical buffers
8. Advance sine table index by step size, wrap at 256 entries

#### `BuildSineLookupTable` ($00AEB8)

- **ASM label:** `sub_00AEB8`
- **Purpose:** Precomputes 512-byte sine lookup tables at `$7E8900`/`$7E8B00` from body data via hardware multiply. Triggered when `$7F000E,X` bit 0 is set or `$09EC` bit 6 is set.
- **Size:** ~100 bytes
- **Called by:** COP $00 (GenHdmaSine)

#### `SetActorBody` ($00AF6D)

- **ASM label:** `sub_00AF6D`
- **Purpose:** Sets actor body/sprite from `$0AD4` (current body index) into `body_table`. Computes table offset as `$0AD4 * 6` (3 words per entry), stores sprite pointer to `$7F0006,X`/`$7F0008,X`, clears `$player_flags` bit `$8000`.
- **Size:** ~24 bytes
- **Called by:** Player sprite COPs ($8F–$92, $94, $95)
- **Variables:** `$0AD4`, `body_table`, `$7F0006,X`, `$7F0008,X`, `$player_flags`

#### `ParseSignedTileOffset` ($00AF8F)

- **ASM label:** `sub_00AF8F`
- **Purpose:** Reads two signed bytes from script args, sign-extends each to 16-bit, scales ×16, adds to actor position `$14`/`$16`, then divides by 16 to produce tile coordinates in `$0018`/`$001C`.
- **Size:** ~40 bytes
- **Called by:** COP $0D (MarkSolidOffset), COP $0E (ClearSolidOffset)

### 7.6 Direction / Collision

#### `ComputeDirectionToPlayer` ($00AFCE)

- **ASM label:** `sub_00AFCE`
- **Purpose:** Computes 8-way (octant 0–7) direction from player actor position to target tile coords `$0018`/`$001C`. Uses Chebyshev distance with a 16-pixel threshold to distinguish cardinal from diagonal.
- **Size:** ~60 bytes
- **Called by:** COP $2D (DirToPlayer), COP $2E (DirToPlayerOffset), COP $2F (BranchIfDirToPlayer), COP $30 (BranchIfDirFromOffset)
- **Returns:** Direction index in A/Y (0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SW, 6=W, 7=NW)

#### Direction Encoding

The octant algorithm works in four quadrants based on X/Y sign:
- Positive X, Positive Y → check if `|dY| < 16` → E(2), if `|dX| < 16` → S(4), else SE(3)
- Positive X, Negative Y → check thresholds → E(2), N(0), else NE(1)
- Negative X, Positive Y → check thresholds → W(6), S(4), else SW(5)
- Negative X, Negative Y → check thresholds → W(6), N(0), else NW(7)

#### `TileCollisionQuery` ($00B43B)

- **ASM label:** `sub_00B43B`
- **Purpose:** Tile collision query at coordinates `$18`/`$1C`. Checks camera bounds, calls `func_03D78A` for map lookup. Returns the tile property byte, or `$000F` if out of range/blocked.
- **Size:** ~60 bytes
- **Called by:** All solidity branch COPs ($13–$1E), wall-gated player COPs ($96–$98)
- **Calls:** `func_03D78A`

#### Algorithm

1. Mask `$18` to tile boundary (`AND $FFF0`), bounds-check X against camera
2. Bounds-check Y against camera offset and `$06DE`
3. Divide both by 16, decrement Y by 1 (tile grid offset)
4. Call `func_03D78A` → returns carry set if invalid, Y = tile index
5. If valid: read `[$80],Y` for tile properties; check high nibble for wall flags
6. If any bounds check fails: return `$000F` (fully solid sentinel)

### 7.7 Event Flag System

All flag subroutines use the same bitfield pattern: `index >> 3` = byte offset in the array, `index & 7` = bit position via `bitmasks_bit_position` lookup table.

#### WRAM Flag Array (`$0A80` — 32 bytes)

| Routine | Address | ASM Label | Purpose |
|---------|---------|-----------|---------|
| `SetWramFlag` | $00B074 | `sub_00B074` | `ORA $0A80,Y` with bitmask |
| `TestWramFlag` | $00B095 | `sub_00B095` | `AND $0A80,Y` → carry set if bit clear |
| `SetWramFlag_Offset100` | $00B069 | `func_00B069` | Add `$0100` to index, then `SetWramFlag` |
| `TestWramFlag_Offset100` | $00B05E | `func_00B05E` | Add `$0100` to index, then `TestWramFlag` |
| `ClearAllWramFlags` | $00B4CC | `func_00B4CC` | Zero `$000A80`–`$000A9E` (16 words) |

#### Event Flag Array (`$0A00` — 256 bytes)

| Routine | Address | ASM Label | Purpose |
|---------|---------|-----------|---------|
| `SetEventFlag` | $00B0B7 | `sub_00B0B7` | `ORA $0A00,Y` with bitmask |
| `ClearEventFlag` | $00B0D8 | `sub_00B0D8` | `AND $0A00,Y` with inverted bitmask |
| `TestEventFlag` | $00B0FB | `sub_00B0FB` | `AND $0A00,Y` → carry set if bit clear |

#### Far-Call Flag Wrappers

These are thin RTL-terminated wrappers that add offsets to the flag index before calling core routines:

| Routine | Address | ASM Label | Offset | Operation |
|---------|---------|-----------|--------|-----------|
| `SetEventFlag_0200` | $00B481 | `func_00B481` | `+$0200` | Set |
| `TestEventFlag_0200` | $00B489 | `func_00B489` | `+$0200` | Test |
| `TestFlag_0300` | $00B496 | `func_00B496` | `+$0300` | Test |
| `SetFlag_0300` | $00B4A1 | `func_00B4A1` | `+$0300` | Set |
| `TestFlag_0510` | $00B4AC | `func_00B4AC` | `+$0510` | Test |
| `TestFlagRaw` | $00B4B7 | `func_00B4B7` | A direct | Test |
| `SetFlagRaw` | $00B4BE | `func_00B4BE` | A direct | Set |
| `ClearFlagRaw` | $00B4C5 | `func_00B4C5` | A direct | Clear |
| `SetFlag_0100` | $00B4E0 | `func_00B4E0` | `+$0100` | Set |
| `ClearFlag_0100` | $00B4EB | `func_00B4EB_noref` | `+$0100` | Clear (unreferenced) |
| `TestFlag_0100` | $00B4F6 | `func_00B4F6` | `+$0100` | Test |

### 7.8 Actor Allocation & Management

#### `ActorPoolAllocator` ($00B501)

- **ASM label:** `func_00B501`
- **Purpose:** Reads next free actor ID from pool at `($4E)`. If pool exhausted (ID negative), returns Y=`$1FC0` with carry set. Otherwise clears the pool entry, advances `$4E` by 2, increments `$0DBC` (active count), returns carry clear with new ID in A/Y.
- **Size:** ~28 bytes
- **Called by:** `AllocateActorBefore`, `AllocateActorAfter`, COP $A5, COP $A6, COP $19
- **Variables:** `($4E)` (free pool pointer), `$4E`, `$0DBC` (active count)

#### `AllocateActorBefore` ($00B15D)

- **ASM label:** `sub_00B15D`
- **Purpose:** Allocates actor from `$0056` free list, links as predecessor (`$04`), copies state via `CopyActorState`. Updates the doubly-linked list pointers.
- **Size:** ~40 bytes
- **Called by:** COP $99 (SpawnBefore), COP $9A (SpawnBeforeParam), COP $A1 (SpawnBeforeMarked)
- **Calls:** `ActorPoolAllocator`, `CopyActorState`

#### `AllocateActorAfter` ($00B189)

- **ASM label:** `sub_00B189`
- **Purpose:** Allocates actor from `$0058` free list, links as successor (`$06`), copies state via `CopyActorState`. Updates the doubly-linked list pointers.
- **Size:** ~40 bytes
- **Called by:** COP $9B–$A4 (SpawnAfter variants), COP $04/$05 (music thinkers), COP $3B/$3C (thinkers)
- **Calls:** `ActorPoolAllocator`, `CopyActorState`

#### `ReturnActorSlot` ($00B1B5)

- **ASM label:** `sub_00B1B5`
- **Purpose:** Returns actor slot to free pool. Sets D=0, decrements `$004E` and `$0DBC`, stores actor ID at `[$4E]`, restores D.
- **Size:** ~14 bytes
- **Called by:** `UnlinkActor`, `DieNow_UnlinkChildren`

#### `MarkChildActor` ($00B1CB)

- **ASM label:** `sub_00B1CB`
- **Purpose:** Stores the current actor's direct-page register value into `$7F001C,X` (parent link ID) of the child actor in Y, if the DP value is non-zero.
- **Size:** ~10 bytes
- **Called by:** COP $A1–$A4 (marked spawn variants)

#### `CopyActorState` ($00B1DA)

- **ASM label:** `sub_00B1DA`
- **Purpose:** Copies full actor state from current actor to target actor Y. Transfers flags (`$0E`/`$10`/`$12`), position (`$14`/`$16`), animation (`$28`/`$2A`), body data, velocity, and clears WRAM extended fields when not in scene `$FF`.
- **Size:** ~120 bytes
- **Called by:** `AllocateActorBefore`, `AllocateActorAfter`

#### Copied Fields

| Source | Destination | Notes |
|--------|-------------|-------|
| `$0E` | `$000E,Y` | OAM flags (direct copy) |
| `$10` | `$0010,Y` | Actor flags (`OR $2000`, `AND $F7FC` — set "spawned", clear collision) |
| `$12` | `$0012,Y` | Actor flags 2 (`AND $EFFF` — clear interact bit) |
| `$14/$16` | `$0014,Y`/`$0016,Y` | Position |
| `$28/$2A` | `$0028,Y`/`$002A,Y` | Animation state |
| `$7F0006,X`/`$7F0008,X` | `$7F0006,Y`/`$7F0008,Y` | Sprite pointer + bank |
| `$7F000C,X` | `$7F000C,Y` | Map header pointer |
| `$7F0020,X` | `$7F0020,Y` | Rearrange index |

Zeroed fields (if not scene `$FF`): `$7F001C` (parent), `$002C/$002E` (velocity), `$7F002C/$002E` (computed velocity), `$0008` (wait counter), `$7F000A` (interact handler), `$7F002A` (extended flags), `$7F1000`–`$7F101E` (all callbacks).

#### `UnlinkActor` ($00AF40)

- **ASM label:** `sub_00AF40`
- **Purpose:** Removes actor from doubly-linked list. Updates predecessor's `$06` and successor's `$04`. If removing the head, updates `$0056` or `$0058`. Calls `ReturnActorSlot` to free the slot.
- **Size:** ~40 bytes
- **Called by:** COP $A7 (DieDeferred), COP $A8/$A9 (KillPrev/KillNext), COP $E0 (DieNow)
- **Calls:** `ReturnActorSlot`

#### `DieNow_UnlinkChildren` ($00A608)

- **ASM label:** `code_00A608`
- **Purpose:** Shared death/cleanup routine used by both DieDeferred and DieNow when the dying actor has marked children (`$12` bit `$0040`). Walks backward and forward through the linked list, unlinking all actors whose `$7F001C,X` matches the dying actor's ID.
- **Size:** ~120 bytes
- **Called by:** COP $A7 (DieDeferred), COP $E0 (DieNow)
- **Calls:** `ReturnActorSlot`

#### `AllocateSpecialActor` ($00B27B)

- **ASM label:** `sub_00B27B`
- **Purpose:** Allocates a special (thinker) actor via `func_03CE8F`, links it into the thinker list at `$005C`.
- **Size:** ~24 bytes
- **Called by:** COP $3B (SpawnThinkerParam), COP $3C (SpawnThinker)
- **Calls:** `func_03CE8F`

#### `ResolveActorIndex` ($00B125)

- **ASM label:** `sub_00B125`
- **Purpose:** Maps 8-bit actor list index → WRAM actor ID. Swaps high byte to `$30`, calls `func_0281D1`, adds `$1000` to result. Returns actor ID in Y.
- **Size:** ~14 bytes
- **Called by:** COP $20 (BranchIfActorNear), COP $29 (BranchIfActorAt)
- **Calls:** `func_0281D1`

### 7.9 Collision Map Operations

#### `MarkCollisionRect` ($00B29F)

- **ASM label:** `sub_00B29F`
- **Purpose:** Marks collision/map tiles as occupied (`OR $F0` into `$7FC000,X`) in a rectangle under the actor, sized from the actor's map header.
- **Size:** ~80 bytes
- **Called by:** COP $0B (MarkSolidHere)
- **Calls:** `func_02B0A3`, `AdvanceMapY`

#### Algorithm

1. Read actor map header from `$7F000C,X` with bank from `$7F0008,X`
2. Parse rectangle dimensions: X offset, width from bytes 0/2; Y offset, height from bytes 1/3
3. Convert to tile coordinates via `func_02B0A3`
4. For each row: iterate columns, `ORA #$F0` into each `$7FC000` byte
5. Handle 16-pixel column wrapping with `AND $000F` check
6. Advance Y via `AdvanceMapY` for each row

#### `ClearCollisionRect` ($00B345)

- **ASM label:** `sub_00B345`
- **Purpose:** Clears collision tiles (`AND $0F` or full zero) in a map rectangle. When `$0000` is non-zero, delegates to `ClearCollisionRectFull` for full-byte clearing.
- **Size:** ~100 bytes
- **Called by:** COP $0C (ClearSolidHere), COP $11 (ClearAllHere)
- **Calls:** `func_02B0A3`

#### `ClearCollisionRectFull` ($00B3EF)

- **ASM label:** `code_00B3EF`
- **Purpose:** Full collision byte clear mode — writes `$00` to each byte in the rectangle (instead of just masking the high nibble). Used when `$0000 ≠ 0`.
- **Size:** ~50 bytes
- **Called by:** `ClearCollisionRect` (when full clear requested)

#### `AdvanceMapY` ($00B32B)

- **ASM label:** `sub_00B32B`
- **Purpose:** Advances map Y coordinate `$1C` by `$10` with bank/page wrap using `$0693` (map row stride). Handles the case where adding `$10` carries past a page boundary.
- **Size:** ~16 bytes
- **Called by:** `MarkCollisionRect`, `ClearCollisionRect`

### 7.10 Camera

#### `CameraScrollStepLookup` ($00B136)

- **ASM label:** `sub_00B136`
- **Purpose:** Indexes camera scroll step table at `$06E0 + $06E2 * 2`. Returns the step value in A. If the entry's high byte is zero, the step sequence is exhausted: resets `$06E2` to zero and returns carry set.
- **Size:** ~24 bytes
- **Called by:** COP $DC–$DF (CameraPan directions)

### 7.11 Miscellaneous

#### `PaletteResetAndKillThinker` ($00B519)

- **ASM label:** `func_00B519`
- **Purpose:** Emits inline COP commands (`PaletteRestart`, `PaletteStep`, `KillThinker`) and RTL. Used as a cleanup entry point for palette thinkers spawned by music/effect COPs.
- **Size:** ~8 bytes

---

## 8. Data Tables

| Name | Address | ASM Label | Size | Purpose |
|------|---------|-----------|------|---------|
| `cop_dispatch_table` | $008485 | `code_list_008485` | 220 bytes (110 entries) | Primary COP dispatch jump table ($00–$6D) |
| (gap) | $008561 | — | 36 bytes (18 entries) | Invalid/garbage entries ($6E–$7F range, all `#0000`) |
| (extended) | $008585 | — | 198 bytes (99 entries) | Extended COP dispatch table ($80–$E2) |
| `cop_table_sentinel` | $00864B | `byte_00864B` | 3 bytes | Sentinel/padding after COP table (`#EA #80 #FD`) |
| `wram_fill_constant` | $00846C | `byte_00846C` | 1 byte (`$E0`) | WRAM fill constant (unused, referenced by `FillWramBlock`) |
| `bitmasks_bit_position` | $00B11D | `bitmasks_00B11D` | 8 bytes | Bit position masks: `$01,$02,$04,$08,$10,$20,$40,$80` |
| `body_table` | (include) | `body_table` | Variable | Player body sprite-set index table (Will/Freedan/Shadow) |
| `table_01B086` | (include) | `table_01B086` | Variable | Animation frame duration/speed lookup table |
| `binary_01C384` | (include) | `binary_01C384` | Variable | Sine/cosine lookup data for HUD init |
| `binary_01C455` | (include) | `binary_01C455` | 256 bytes | Sine table for HDMA wave effects |
| `binary_01D8BE` | (include) | `binary_01D8BE` | Variable | DMA channel configuration bytes |

---

## 9. Call Reference Matrix

### Most-Called Subroutines (within this chunk)

| Subroutine | Address | Call Count | Primary Callers |
|------------|---------|------------|-----------------|
| `TileCollisionQuery` | $00B43B | 14 | Solidity branch COPs, player wall COPs |
| `ProcessAnimFlag` | $009F5F | 12 | Sprite staging COPs, movement init |
| `AnimFrameLookup` | $00B157 | 20+ | Sprite staging COPs, force-move COPs |
| `AllocateActorAfter` | $00B189 | 14 | Spawn COPs, music/thinker COPs |
| `SetEventFlag` | $00B0B7 | 6 | Flag COPs, far-call wrappers |
| `TestEventFlag` | $00B0FB | 8 | Flag COPs, far-call wrappers |
| `SetActorBody` | $00AF6D | 8 | Player sprite COPs |
| `AllocateActorBefore` | $00B15D | 4 | Spawn-before COPs |
| `CopyActorState` | $00B1DA | 2 (via allocators) | `AllocateActorBefore`, `AllocateActorAfter` |
| `MarkChildActor` | $00B1CB | 5 | Marked-spawn COPs |
| `ComputeDirectionToPlayer` | $00AFCE | 4 | Direction COPs |
| `UnlinkActor` | $00AF40 | 5 | Death/kill COPs |
| `ActorPoolAllocator` | $00B501 | 4 | Both allocators, list-splice COPs |

### External Function Dependencies (JSL calls to other banks)

| Function | Bank | Called From | Purpose |
|----------|------|-------------|---------|
| `func_028043` | $02 | Main loop, frame updates | Begin frame |
| `func_0281A2` | $02 | Main loop, frame updates | Scene transitions |
| `func_028191` | $02 | Main loop, frame updates | End frame / wait VBlank |
| `func_029F31` | $02 | SystemInit | PPU register init |
| `func_029E44` | $02 | SystemInit | Clear VRAM |
| `func_02908E` | $02 | SystemInit | Init WRAM/game state |
| `func_0281BC` | $02 | SystemInit | Init actor system |
| `func_02AF5F` | $02 | NmiHandler | Upload OAM |
| `func_029DE2` | $02 | NmiHandler | Upload CGRAM |
| `func_02B038` | $02 | NmiHandler | VRAM transfers |
| `func_02A310` | $02 | NmiHandler | Tilemap DMA |
| `func_02AC2E` | $02 | Main loop | BG scroll update |
| `func_02B0A3` | $02 | Tile/collision helpers | Map coord → WRAM index |
| `func_028270` | $02 | Decompress COP | Decompress bitstream |
| `func_0281D1` | $02 | `ResolveActorIndex` | Actor list index lookup |
| `func_0281E8` | $02 | `InitSmoothMovement` | Step count calculation |
| `func_02A5DD` | $02 | Main loop | Palette animation update |
| `func_03D12D` | $03 | Main loop | Map/scroll state |
| `func_03D9E8` | $03 | Main loop | Scene loading |
| `func_03D9F6` | $03 | SystemInit | Load initial scene |
| `func_038000` | $03 | Main loop | Scene-specific logic |
| `run_actors_03CAF5` | $03 | Main loop | Execute all actor scripts |
| `func_03C5FF` | $03 | Main loop, frame updates | OAM sort/compose |
| `func_03BBE4` | $03 | Main loop | Collision responses |
| `func_03C714` | $03 | Main loop, frame updates | Finalize sprites |
| `func_03CA55` | $03 | Animation COPs, movement | Advance animation frame |
| `func_03D78A` | $03 | `TileCollisionQuery` | Map tile lookup |
| `func_03E0B0` | $03 | Palette COPs | Load palette bundle |
| `func_03E125` | $03 | Palette COPs | Apply palette HDMA |
| `func_03E146` | $03 | Main loop | Update HDMA channels |
| `func_03E157` | $03 | HDMA queue COPs | Queue HDMA |
| `func_03E173` | $03 | DMA queue COPs | Queue DMA |
| `func_03EA62` | $03 | BG3 script COP | BG3 script runner |
| `sub_03E255` | $03 | Text COPs | Wide string interpreter |
| `func_03EF97` | $03 | Inventory COP | Inventory give/check |
| `func_03F08D` | $03 | Inventory COP | Inventory remove |
| `func_03F0B3` | $03 | Inventory COP | Inventory has-item check |
| `func_03F0CA` | $03 | Facing COPs | Player facing lookup |
| `func_03F1D0` | $03 | NmiHandler | Tilemap prep DMA |
| `func_03D881` | $03 | NmiHandler | Special BG3 mode |
| `func_03CE8F` | $03 | `AllocateSpecialActor` | Thinker allocator |
| `func_00F3C9` | $00 | Spiral/orbit COP | Orbital/spiral math |
| `func_0AA3A7` | $0A | Grid-snap COP | Grid-snap walk resume |

---

## 10. Variable / Memory Map

### Direct Page (Actor-Relative) Variables

| Address | Size | Name | Used By |
|---------|------|------|---------|
| `$00`/`$02` | 4 | EntryPtr + bank | Script control, dispatch engine |
| `$04` | 2 | Prev actor link | Linked list, spawn |
| `$06` | 2 | Next actor link | Linked list, spawn |
| `$08` | 2 | Frame wait counter | Waits, halt/yield, offscreen |
| `$0A`/`$0C` | 4 | ArgPtr + script bank | COP dispatch engine |
| `$0E` | 2 | OAM XOR flags | Priority, palette, mirror |
| `$10` | 2 | Actor flags word 1 | Collision priority, offscreen |
| `$12` | 2 | Actor flags word 2 | Force-flip, marked child, interact |
| `$14` | 2 | Position X (pixels) | All movement/position routines |
| `$16` | 2 | Position Y (pixels) | All movement/position routines |
| `$18` | 2 | Scratch / probe X | Collision, tile queries |
| `$1C` | 2 | Scratch / probe Y | Collision, tile queries |
| `$24` | 2 | Step counter / direction index | Movement, gravity |
| `$28` | 2 | Sprite set index | Animation staging |
| `$2A` | 2 | Animation frame | Animation execution |
| `$2C` | 2 | Velocity X / force X | Movement per frame |
| `$2E` | 2 | Velocity Y / force Y | Movement per frame |
| `$36` | 2 | Frame parity counter | NMI handler, main loop |

### WRAM Extended Actor Fields

| Address | Size | Name | Used By |
|---------|------|------|---------|
| `$7F0000,X` | 2 | Movement accumulator X | MoveToward, TickMove |
| `$7F0002,X` | 2 | Step counter | MoveToward, TickMove, palette |
| `$7F0004,X` | 2 | SavedPtr / deferred callback | Script control |
| `$7F0006,X` | 2 | Sprite set pointer (low) | SetMetasprite, body setup |
| `$7F0008,X` | 2 | Sprite set pointer (bank) / param | Sprite, sine amplitude |
| `$7F000A,X` | 2 | Movement sub-steps / interact handler | Movement, interact |
| `$7F000E,X` | 2 | Direction / step total | Movement handlers |
| `$7F0010,X` | 1 | Sound effect to play | WorldMapStream SFX |
| `$7F0012,X` | 2 | Orbit angle | InitSpiral, SpiralStep |
| `$7F0014,X` | 2 | Loop counter (thinker-type actors) | LoopInit/LoopDecrement |
| `$7F0016,X` | 2 | Loop counter (animation) | AnimLoop |
| `$7F0018,X` | 2 | Target distance X / anim X move | Movement, animation |
| `$7F001A,X` | 2 | Target distance Y / anim Y move | Movement, animation |
| `$7F001C,X` | 2 | Parent actor ID | Marked children |
| `$7F001E,X` | 2 | Loop start PC (thinker-type) | LoopInit |
| `$7F0020,X` | 2 | Rearrange index / misc | CopyActorState |
| `$7F0022,X` | 2 | Dungeon monster ID | SetDungeonKillFlag |
| `$7F002A,X` | 2 | Extended flags | SetActorFlags/ClearActorFlags |
| `$7F002C,X` | 2 | Computed velocity X | MoveToward |
| `$7F002E,X` | 2 | Computed velocity Y | MoveToward |
| `$7F1000,X` | 2 | OnHit callback | SetOnHit |
| `$7F1002,X` | 2 | OnDodge callback | SetOnDodge |
| `$7F1004,X` | 4 | OnDeath callback + bank | SetOnDeath |
| `$7F1008,X` | 2 | OnCollide callback | SetOnCollide |
| `$7F1010,X` | 2 | Gravity accel / orbit diameter | InitGravity, InitSpiral |
| `$7F1012,X` | 2 | Gravity speed / orbit angle | InitGravity, InitSpiral |
| `$7F1014,X` | 2 | Gravity state | TickGravity |
| `$7F1016,X` | 2 | Callback $5E | SetCallback5E |
| `$7F1018,X` | 2 | Snap resume PC | SnapToGrid |
| `$7F101A,X` | 2 | Snap resume bank | SnapToGrid |
| `$7F101C,X` | 2 | Cleared on spawn | CopyActorState |
| `$7F101E,X` | 2 | Cleared on spawn | CopyActorState |
| `$7F2100,X` | 2 | Loop start PC (actor-type) | LoopInit (X < $1000) |
| `$7F2102,X` | 2 | Loop counter (actor-type) | LoopInit (X < $1000) |

### Global State Variables

| Address | Size | Name | Used By |
|---------|------|------|---------|
| `$0036` | 2 | Frame counter (parity) | NMI, HUD, sine |
| `$004E` | 2 | Free pool pointer | ActorPoolAllocator |
| `$0052` | 2 | Thinker list count | KillThinker |
| `$0056` | 2 | Actor list head (before-pool) | AllocateActorBefore, UnlinkActor |
| `$0058` | 2 | Actor list head (after-pool) | AllocateActorAfter, UnlinkActor |
| `$005A` | 2 | Thinker prev head | KillThinker |
| `$005C` | 2 | Thinker list head | AllocateSpecialActor |
| `$0066` | 1 | HDMA channel enable mask | NmiHandler, HDMA COPs |
| `$00AC`/`$00AE` | 4 | DMA source address + bank | ExecuteVramDma |
| `$00B0` | 2 | VRAM destination word address | ExecuteVramDma |
| `$00B2` | 2 | DMA transfer size | ExecuteVramDma |
| `$00D8` | 2 | OAM write offset | Main loop, frame updates |
| `$00E4` | 2 | Actor limit threshold | HaltIfActorLimitHit |
| `$040C` | 2 | Invincibility timer | UpdateFrameCounters |
| `$040E` | 2 | Global frame timer | UpdateFrameCounters |
| `$040F`–`$041E` | 16 | RNG state | RngByte |
| `$0420` | 2 | RNG modulo result | RngMod |
| `$0654` | 2 | World-ready flag | DialogueOptions gate |
| `$0656` | 2 | Filtered joypad state | Button COPs |
| `$0660` | 2 | Raw joypad state | Button COPs, NMI |
| `$0693` | 1 | Map row stride | AdvanceMapY |
| `$068A`–`$068F` | 6 | BG1 scroll values | UploadScrollRegisters |
| `$06BE` | 2 | Camera scroll X | Camera pan COPs |
| `$06C2` | 2 | Camera scroll Y | Camera pan COPs |
| `$06C6`–`$06CB` | 6 | BG scroll override values | WriteBgScroll |
| `$06DE` | 2 | Map Y upper bound | TileCollisionQuery |
| `$06E0` | 2 | Scroll step table base | CameraScrollStepLookup |
| `$06E2` | 2 | Scroll step index | CameraScrollStepLookup |
| `$06EE` | 1 | Layer priority flag | UploadScrollRegisters |
| `$06EF` | 1 | Scroll mode flags | UploadScrollRegisters |
| `$06F8` | 2 | SFX channel 1 queue | PlaySoundCh1, NMI |
| `$06F9` | 1 | SFX channel 2 queue | PlaySoundCh2 |
| `$06FA` | 2 | Music transition state | NmiHandler |
| `$0800` | 1 | DMA skip flag | NmiHandler |
| `$0902` | 2 | Tile query result / VRAM addr | Metatile helpers |
| `$0904`–`$090C` | 8 | Tile graphics entries | ResolveTileData |
| `$09B0` | 2 | Wall type for player anim | PlayerAnimIfWall COPs |
| `$09EC` | 2 | Display mode flags | HUD, NMI, sine, various |
| `$09ED` | 1 | HUD disable flag (bit $40) | UpdateHUD |
| `$0A00`+ | 256 | Event flag bitfield | Flag system |
| `$0A80`+ | 32 | WRAM flag bitfield | Kill flags, dungeon state |
| `$0AD4` | 2 | Current body index | Body swap, SetActorBody |
| `$0DBC` | 2 | Active actor count | ActorPoolAllocator, ReturnActorSlot |
| `$7F0C03`–`$7F0C09` | 8 | Adhoc VRAM DMA params | AdhocVramDma COP |

---

## 11. Stack Usage Summary

### Stack Depth by Context

| Context | Max Depth | Notes |
|---------|-----------|-------|
| NMI Handler | 12 bytes | 6 pushes (PHP,PHB,PHA,PHX,PHY + CLD) |
| COP Handler (simple) | 0 extra | Uses `STA $02,S` to modify existing stack frame |
| COP Handler + D=0 | 2 bytes | `PHD`/`PLD` for zero direct page |
| COP Handler + spawn | 4–6 bytes | `PHD`+`PHX` or `PHY`+`PHD` |
| Frame update functions | 14 bytes | Full context: PHB,PHA,XBA,PHA,PHX,PHY,PHD |
| Movement handlers | 4 bytes | `PHA`×2 for velocity temp + stack cleanup `PLA PLA RTL` |

### Common Stack Patterns

1. **COP Continue:** `LDA $0A; STA $02,S; RTI` — overwrites return address on stack
2. **COP Branch:** `LDA [$0A]; STA $02,S; RTI` — indirect load of branch target
3. **COP Halt:** `PLA; PLA; RTL` — discard COP return frame, return to engine
4. **Context save:** `PHB; PHA; XBA; PHA; PHX; PHY; PHD` (7 pushes = 14 bytes)
5. **Bank switch:** `PHA; PLB` (1 byte round-trip for data bank)
6. **Zero DP:** `PHD; LDA #$0000; TCD` ... `PLD`

---

## 12. Statistics

### Code Distribution

| Category | Count | Approx. Size |
|----------|-------|-------------|
| Interrupt vectors / trampolines | 5 | 20 bytes |
| System init + main loop | 1 | 166 bytes |
| Frame update functions | 4 | ~330 bytes |
| NMI handler + DMA helpers | 5 | ~320 bytes |
| COP dispatch engine + tables | 4 | ~484 bytes |
| COP handlers (primary $00–$6D) | 96 | ~5,800 bytes |
| COP handlers (extended $80–$E2) | 76 | ~3,400 bytes |
| Utility subroutines (sub_*) | 28 | ~1,500 bytes |
| Far-call functions (func_*) | 16 | ~400 bytes |
| Shared code blocks (code_*) | 5 | ~200 bytes |
| Data tables | 6 | ~470 bytes |
| **Total** | **~241 routines** | **~13,090 bytes** |

### Named Entries Summary

**68 entries** cataloged in `us/names.json` for this chunk, covering:

| Category | Count |
|----------|-------|
| Interrupt vectors & trampolines | 5 |
| System / frame update functions | 6 |
| NMI handler & DMA helpers | 5 |
| COP dispatch engine & tables | 3 |
| Hardware math helpers | 4 |
| Movement initialization | 2 |
| Tile / map helpers | 3 |
| Animation / visibility | 2 |
| Sprite / body helpers | 4 |
| Direction / collision | 2 |
| Event flag system | 18 |
| Actor allocation & management | 8 |
| Collision map operations | 4 |
| Camera | 1 |
| Miscellaneous | 1 |
| Data tables / constants | 3 |

### External Dependency Count

| Bank | Unique Functions Called | Purpose |
|------|----------------------|---------|
| `$02` | 17 | Rendering, DMA, actor system, decompression, math |
| `$03` | 27 | Scenes, actors, text, metatiles, inventory, collision, HDMA |
| `$00` (other chunks) | 2 | Orbital math, grid-snap helper |
| `$0A` | 1 (reference only) | Grid-snap resume target |

---

*Generated from deep analysis of `extracted/system/system_core.asm`, `cop_dispatch.asm`, `cop_handlers_actors.asm`, `cop_handlers_collision.asm`, and `cop_handlers_script.asm` (Illusion of Gaia US ROM).*
*System names cataloged in `us/names.json`. COP handler reference in `cop-commands-reference.md`.*

---

# chunk_00D088.asm — Stair Trigger & Climb System

**Bank:** `$00`  
**Address range:** `$00D088`–`$00D2D2` (core); `$00D58A`–`$00D5BC` (shared utility)  
**Size:** ~1,336 bytes (13 parts)  
**File:** `extracted/system/chunk_00D088.asm`  
**Block flags:** `movable: false` — tight `$&` coupling to `ramps.asm`

This chunk implements the **stair trigger system** — five directional actor triggers
that detect when the player approaches a stair/step tile boundary, lock the player's
controls, and execute a climbing animation. Used in Mu, Angkor Wat, Angel Village,
and the Dracula Mansion to handle elevation changes on the isometric map.

> **Related file:** `extracted/actors/ramps.asm` — the ramp (slope walk) system that
> `?INCLUDE`s this chunk. Both files share `sub_00D58A` (RestorePlayerControl) and
> the `player_character` dependency.

---

## Table of Contents

1. [System Overview](#d088-1-system-overview)
2. [Actor Trigger Definitions](#d088-2-actor-trigger-definitions)
3. [Shared Utility Subroutines](#d088-3-shared-utility-subroutines)
4. [Directional Climb Functions](#d088-4-directional-climb-functions)
5. [Variable Map](#d088-5-variable-map)
6. [Call Reference Matrix](#d088-6-call-reference-matrix)
7. [Statistics](#d088-7-statistics)

---

## D088-1. System Overview

### Architecture

Each stair trigger is a small invisible `actor_def` placed at a tile boundary. Every
frame it:

1. Checks if the player is within X/Y proximity (±8 to ±$20 pixels)
2. Verifies the player is on the same row/column (`$14` or `$16` match)
3. Calls `CheckMoveState` to confirm the player's movement byte is `$8F` (walking)
4. Validates the player's facing direction matches the stair direction (e.g. facing south = `$12`/`$13`)
5. If all pass → overwrites the player's entry pointer to a climb function, calls `LockPlayerForClimb`

### Include Dependencies

| Include | Purpose |
|---------|---------|
| `player_character` | Access to `$player_actor` and player variables |

---

## D088-2. Actor Trigger Definitions

### `StairTriggerSouth` ($00D0D1) — South-Facing Stair Trigger

- **Hex address:** `$D0D1` (decimal 53457)
- **Size:** 72 bytes (actor def header + code)
- **Purpose:** Detects player approaching from the south (walking south, facing `$12`/`$13`). Redirects player to `ClimbSouth` (`func_00D218`).
- **Proximity check:** X range ±$8 to ±$20 pixels from trigger Y, same X row check
- **Valid facing:** `$0012` or `$0013`
- **Scene usage:** Mu Passage (`event_def_0CA923`) — actor slot #12/#13

### `StairTriggerNorth` ($00D119) — North-Facing Stair Trigger

- **Hex address:** `$D119` (decimal 53529)
- **Size:** 72 bytes
- **Purpose:** Detects player approaching from the north (walking north, facing `$15`/`$16`). Redirects to `ClimbNorth` (`func_00D246`).
- **Valid facing:** `$0015` or `$0016`
- **Scene usage:** Mu Passage (`event_def_0CA923`) — actor slot #12

### `StairTriggerWestEntry` ($00D161) — West-Facing Stair Entry

- **Hex address:** `$D161` (decimal 53601)
- **Size:** 9 bytes
- **Purpose:** Thin wrapper — adds position offset (`COP [AddPosition] #F8, #00`) then falls through to `StairTriggerWest` code (`code_00D16D`). Used in Angel Village 72.
- **Scene usage:** Angel Village (`event_def_0CB258`) — actor slot #14

### `StairTriggerWest` ($00D16A) — West-Facing Stair Trigger

- **Hex address:** `$D16A` (decimal 53610)
- **Size:** 75 bytes
- **Purpose:** Detects player approaching from the west (walking west, facing `$0F`/`$10`). Redirects to `ClimbWest` (`func_00D274`). Checks X-axis proximity (±$8 to ±$20) on the actor's Y column.
- **Valid facing:** `$000F` or `$0010`
- **Scene usage:** Mu Passage, Angel Village, Angkor Wat, Dracula Mansion — 12+ scene placements

### `StairTriggerEast` ($00D1B5) — East-Facing Stair Trigger

- **Hex address:** `$D1B5` (decimal 53685)
- **Size:** 79 bytes
- **Purpose:** Detects player approaching from the east (walking east, facing `$0C`/`$0D`). Redirects to `ClimbEast` (`func_00D2A2`). Same pattern but on the opposite horizontal axis.
- **Valid facing:** `$000C` or `$000D`
- **Scene usage:** Mu Cyclops, Angel Village, Angkor Wat temples — 10+ placements

---

## D088-3. Shared Utility Subroutines

### `LockPlayerForClimb` ($00D088)

- **Hex address:** `$D088` (decimal 53384)
- **Size:** 38 bytes
- **Purpose:** Called by all five stair triggers when activation conditions are met. Locks the player into the climb animation state:
  1. `$0E << 2` → compute climb frame count, store to `$7F0020,X` (player actor)
  2. Zero velocity `$002C`/`$002E` and wait counter `$0008` on the player
  3. Set joypad mask `$0F00` to block D-pad, set `$player_flags` bit `$0800` (climbing)
- **Called by:** All five stair triggers (JSR `$&sub_00D088`)

### `UnlockPlayerAfterClimb` ($00D0AE)

- **Hex address:** `$D0AE` (decimal 53422)
- **Size:** 35 bytes
- **Purpose:** Called when the climb animation finishes (frame counter reaches zero). Restores the player to normal state:
  1. `STZ $09E0` — clear climb data
  2. `TRB $joypad_mask_std` with `$CFF0` — unmask D-pad inputs
  3. Set actor flags `$10` bit `$0008`, clear bit `$0200`
  4. Set `$0658` bit `$8000`
  5. Clear `$player_flags` bit `$0002`
  6. Call `RestorePlayerControl` (`sub_00D58A`)
- **Called by:** All four directional climb functions after animation completes

### `CheckMoveState` ($00D204)

- **Hex address:** `$D204` (decimal 53764)
- **Size:** 20 bytes
- **Purpose:** Validates the player actor is in the "walking" move state. Reads `$7F0008,X` (where X = player actor) and compares to `$8F`. Returns carry clear if `$8F` (valid for stair trigger), carry set if not.
- **Called by:** All five stair triggers (JSR `$&sub_00D204`)
- **Register state:** Enters/exits with 8-bit A (SEP #$20 / REP #$20 implicit on return)

### `RestorePlayerControl` ($00D58A)

- **Hex address:** `$D58A` (decimal 54666)
- **Size:** 54 bytes
- **Purpose:** Resets the player actor to normal walking state after a climb or ramp completes. Sets player entry pointer to `code_02C3C8` (normal player state machine), zeros velocity/wait counter, adjusts actor flags, and unmasks joypad/player_flags.
- **Called by:** `UnlockPlayerAfterClimb` (this chunk) and ramp completion handlers (`ramps.asm`)
- **Cross-file sharing:** This is why `chunk_00D088` is `movable: false` — `ramps.asm` calls this via `JSR $&sub_00D58A`.

---

## D088-4. Directional Climb Functions

All four climb functions share the same pattern:

1. Set actor flags: `TSB $10` with `$2200` (invisible + priority), `TRB $10` with `$0008`
2. `COP [SetEntryContinue]` — allow multi-frame execution
3. Move position 4 pixels per frame in the climb direction
4. Decrement `$7F0020,X` (frame counter); if non-zero → `RTL` (continue next frame)
5. At zero: clear `$2000` from `$10`, stage a sprite frame, `COP [AnimOnce]`, call `UnlockPlayerAfterClimb`

### `ClimbSouth` ($00D218)

- **Hex address:** `$D218` (decimal 53784)
- **Size:** 46 bytes
- **Movement:** Decrements `$14` by 4 each frame (move player up/north on screen = climbing south in isometric)
- **End sprite frame:** `#14`

### `ClimbNorth` ($00D246)

- **Hex address:** `$D246` (decimal 53830)
- **Size:** 46 bytes
- **Movement:** Increments `$14` by 4 each frame
- **End sprite frame:** `#17`

### `ClimbWest` ($00D274)

- **Hex address:** `$D274` (decimal 53876)
- **Size:** 46 bytes
- **Movement:** Decrements `$16` by 4 each frame
- **End sprite frame:** `#11`

### `ClimbEast` ($00D2A2)

- **Hex address:** `$D2A2` (decimal 53922)
- **Size:** 46 bytes
- **Movement:** Increments `$16` by 4 each frame
- **End sprite frame:** `#0E`

---

## D088-5. Variable Map

| Address | Size | Name | Used By |
|---------|------|------|---------|
| `$0E` | 2 | OAM flags / frame count source | `LockPlayerForClimb` (ASL ASL for count) |
| `$10` | 2 | Actor flags word 1 | Climb functions (set `$2200`, clear `$0008`) |
| `$14` | 2 | Position X | Climb S/N (modify X for elevation) |
| `$16` | 2 | Position Y | Climb W/E (modify Y for elevation) |
| `$28` | 2 | Player facing direction | Trigger direction validation |
| `$7F0008,X` | 1 | Move state byte | `CheckMoveState` (`$8F` = walking) |
| `$7F0020,X` | 2 | Climb frame counter | `LockPlayerForClimb` → climb functions |
| `$002C,X` | 2 | Velocity X | Zeroed by lock |
| `$002E,X` | 2 | Velocity Y | Zeroed by lock |
| `$0008,X` | 2 | Wait counter | Zeroed by lock |
| `$09E0` | 2 | Climb state data | Cleared by unlock |
| `$0658` | 2 | Display flags | Bit `$8000` set by unlock |
| `$joypad_mask_std` | 2 | Joypad input mask | `$0F00` set (lock), `$CFF0` cleared (unlock) |
| `$player_flags` | 2 | Player state flags | Bit `$0800` set (lock), bits `$0002`/`$0800`/`$0F00` cleared (unlock) |

---

## D088-6. Call Reference Matrix

### Internal Calls

| Caller | Callee | Type |
|--------|--------|------|
| All 5 triggers | `CheckMoveState` ($D204) | JSR `$&` |
| All 5 triggers | `LockPlayerForClimb` ($D088) | JSR `$&` |
| All 4 climb funcs | `UnlockPlayerAfterClimb` ($D0AE) | JSR `$&` |
| `UnlockPlayerAfterClimb` | `RestorePlayerControl` ($D58A) | JSR `$&` |

### External Callers (from ramps.asm)

| Caller | Target | Type |
|--------|--------|------|
| `code_00D4D2` (ramp_east climb) | `RestorePlayerControl` ($D58A) | JSR `$&` |
| `code_00D550` (ramp_south climb) | `RestorePlayerControl` ($D58A) | JSR `$&` |
| `loc_00D518` (ramp_north climb) | `RestorePlayerControl` ($D58A) | JSR `$&` |
| `func_00D5C0` (ramp sprite anim) | `RestorePlayerControl` ($D58A) | JSR `$&` |

### External Dependencies

| Target | Bank | Purpose |
|--------|------|---------|
| `$player_actor` | global | Player actor slot ID |
| `code_02C3C8` | $02 | Normal player state machine (set by `RestorePlayerControl`) |

---

## D088-7. Statistics

### Code Distribution

| Category | Count | Size |
|----------|-------|------|
| Actor definitions (triggers) | 5 | ~307 bytes |
| Directional climb functions | 4 | ~184 bytes |
| Shared subroutines | 4 | ~147 bytes |
| **Total** | **13 parts** | **~638 bytes (core)** |

### Scene Usage (from scene_actors.asm)

| Actor | Scene Count | Areas |
|-------|-------------|-------|
| `StairTriggerSouth` | 2 | Mu Passage |
| `StairTriggerNorth` | 2 | Mu Passage |
| `StairTriggerWestEntry` | 1 | Angel Village |
| `StairTriggerWest` | 12+ | Mu, Angel Village, Angkor Wat, Dracula Mansion |
| `StairTriggerEast` | 10+ | Mu, Angel Village, Angkor Wat, Dracula Mansion |

---

# chunk_00E683.asm — Smooth Scroll & Camera Pan System

**Bank:** `$00`  
**Address range:** `$00E683`–`$00F292` (all parts)  
**Size:** ~3,376 bytes (22 parts)  
**File:** `extracted/system/chunk_00E683.asm`

This chunk implements two distinct subsystems: a **smooth actor follow/chase engine**
(used for sliding actors that track the player on a 16-direction grid) and a
**forced camera pan system** (used for stairway/elevation-transition autoscrolls).
It also contains four scene-support actors that manage camera scroll state and
a large binary lookup table for smooth movement interpolation.

---

## Table of Contents

1. [System Overview](#e683-1-system-overview)
2. [Smooth Follow Engine](#e683-2-smooth-follow-engine)
3. [Camera Pan Actors](#e683-3-camera-pan-actors)
4. [Forced Walk Functions](#e683-4-forced-walk-functions)
5. [Utility Subroutines](#e683-5-utility-subroutines)
6. [Data Tables](#e683-6-data-tables)
7. [Variable Map](#e683-7-variable-map)
8. [Call Reference Matrix](#e683-8-call-reference-matrix)
9. [Statistics](#e683-9-statistics)

---

## E683-1. System Overview

### Include Dependencies

| Include | Purpose |
|---------|---------|
| `chunk_028000` | `func_028000` — signed multiply/clamp helper |
| `chunk_03BAE1` | `func_03CA55` — advance sprite animation frame |
| `dir_sprite_01ABDE` | Direction-indexed sprite table (facing frames) |
| `table_01A95E` | Camera scroll speed table |
| `table_01B086` | Animation frame duration lookup |

### Subsystem Breakdown

| Subsystem | Functions | Purpose |
|-----------|-----------|---------|
| Smooth follow engine | `CopySiblingFollowState`, `InitFollowAndChase`, 8 direction handlers, `ApplyFollowMovement`, `SelectFallbackDirection`, dispatch table + 16 direction entries | NPC/platform sliding |
| Camera scroll actors | `ScrollCameraInit`, `ScrollCameraTrack`, `ScrollCameraVertical`, `ScrollCameraAccumulate` | Per-scene camera management |
| Forced walk functions | `ForcedWalkSouth`, `ForcedWalkNorth`, `ForcedWalkWest`, `ForcedWalkEast` | Player auto-walk during transitions |
| Utilities | `TileAlignCoord`, `TileAlignPosition`, `ComputeScrollDeltas`, `ReadDirSprite_YVelocity`, `ReadDirSprite_XVelocity`, `ApplyScrollOffset`, `SyncPlayerToCamera` | Coordinate helpers |
| Data | `SmoothFollowLookup` | 544-byte distance interpolation table |

---

## E683-2. Smooth Follow Engine

### `CopySiblingFollowState` ($00E683)

- **Hex address:** `$E683` (decimal 59011)
- **Size:** 35 bytes
- **Purpose:** Copies follow state (`$7F0014,X` → sibling sprite index; `$7F000A,X` → movement param) from the sibling actor referenced by `$0004,Y` (predecessor link), then falls through to `ChasePlayerLoop` at `code_00E6CE`.
- **Flow:** Reads sibling's extended fields → copies to self → BRA `ChasePlayerLoop`

### `InitFollowAndChase` ($00E6A6)

- **Hex address:** `$E6A6` (decimal 59046)
- **Size:** 561 bytes (includes the entire chase logic through `code_00E8BA`)
- **Purpose:** Main entry point for the smooth follow/chase engine. Same sibling copy as above, but additionally sets `$7F000E,X = $FFFF` (reset direction state), then enters `ChasePlayerLoop`.

#### ChasePlayerLoop (`code_00E6CE`)

The core tracking loop computes signed delta X/Y from the actor to the player (`$24` = player actor reference), determines the dominant axis via absolute magnitude comparison, and dispatches to one of 8 directional handler blocks:

| Condition | Direction Block | Handler |
|-----------|----------------|---------|
| +X, +Y, Y > X | `code_00E7A5` | NE-biased (Y dominant) |
| +X, +Y, X > Y | `code_00E789` | NE-biased (X dominant) |
| +X, -Y, Y > X | `code_00E736` | SE-biased (Y dominant, neg) |
| +X, -Y, X > Y | `loc_00E763` | SE-biased (X dominant, neg) |
| -X, +Y, Y > X | `code_00E7CE` | NW-biased (Y dominant) |
| -X, +Y, X > Y | `code_00E7FB` | NW-biased (X dominant) |
| -X, -Y, Y > X | `code_00E850` | SW-biased (Y dominant, neg) |
| -X, -Y, X > Y | `code_00E821` | SW-biased (X dominant, neg) |

Each handler calls either `ComputeFollowAngle` or `ComputeFollowAngleAlt` to determine a 16-step angular movement value, then uses `SelectFallbackDirection` to pick the actual direction index. After resolving, all handlers converge at `ApplyFollowMovement`.

### `ApplyFollowMovement` ($00E87E)

- **Hex address:** `$E87E` (decimal 59518)
- **Size:** ~60 bytes
- **Purpose:** Applies the computed movement deltas (`$0000`/`$0002`) to both the actor and its linked sibling. Updates position, stores velocity in `$7F002C,X`/`$7F002E,X`. If `$7F0012,X ≥ 8`, resets to zero and re-enters `ChasePlayerLoop` via `COP [SetEntryExitNow]`.

### `SelectFallbackDirection` ($00E8BA)

- **Hex address:** `$E8BA` (decimal 59578)
- **Size:** ~13 bytes
- **Purpose:** When the computed direction index indicates the target was already reached (direction = non-negative from `SelectFallbackDirection`), this routes through a `COP [SwitchCase]` on the low 3 bits to resume from the correct directional handler entry point.
- **Dispatch table:** `code_list_00E8C7` — 8 entries mapping back to the handler midpoints

---

## E683-3. Camera Pan Actors

These four `actor_def`s are scene-infrastructure actors placed at slot #2 in nearly every
overworld/town scene (typically at position `$11,$11` or `$21,$21` off-screen). They manage
camera scroll behavior for the scene.

### `ScrollCameraInit` ($00E94D)

- **Hex address:** `$E94D` (decimal 59725)
- **Size:** 62 bytes
- **Purpose:** Mt. Kress / special overworld scrolling. Tiles self-position to grid via `TileAlignCoord`, then loops 3 times calling `ComputeScrollDeltas` with `LoopInit/LoopNext`. Copies `$06C4` → `$0690`, sets forced scroll override `$06C8 = $06C0 | $8000`, then clears `$06C0`.
- **Special behavior:** `$12` bit `$1000` set (invisible actor), loops via `COP [LoopInit] #03`
- **Scene usage:** Mt. Kress scenes only (`event_def_0CC18C` through `event_def_0CCA02`) — always at position `$DF,$DF`

### `ScrollCameraTrack` ($00EA96)

- **Hex address:** `$EA96` (decimal 60054)
- **Size:** 17 bytes
- **Purpose:** Simplest camera actor — aligns self to tile grid, then calls `ComputeScrollDeltas` every frame. This is the **default camera controller** used in most town/overworld scenes.
- **Scene usage:** ~40+ scenes — the most common camera actor in the game

### `ScrollCameraVertical` ($00EAA7)

- **Hex address:** `$EAA7` (decimal 60071)
- **Size:** 28 bytes
- **Purpose:** Camera actor variant for vertically-scrolling maps (e.g. Edward's Castle throne room). Same base behavior as `ScrollCameraTrack` but also computes vertical scroll offset: if `$16 ≠ 0`, calls `func_028000(Y=$06C2)` and stores result to `$06C4`.
- **Scene usage:** Edward's Castle, Itory Village, Incan Ruins, Dao — scenes with forced vertical scroll

### `ScrollCameraAccumulate` ($00EAC3)

- **Hex address:** `$EAC3` (decimal 60099)
- **Size:** 42 bytes
- **Purpose:** Camera actor that accumulates scroll offsets from direct-page variables `$24`/`$26` into the global camera deltas `$06C0`/`$06C4` each frame. Used in Pyramid scenes with moving platforms.
- **Scene usage:** Pyramid D6/D7/D9/DA scenes — pyramid interior scrolling

---

## E683-4. Forced Walk Functions

These four functions execute an automated player walk in a cardinal direction, used during
scene transitions involving stairs or elevation changes. Each follows the same pattern:

1. Clear `$12` bits `$6000`, set entry continue
2. Mask joypad (`$FFFF` → `$joypad_mask_std`), zero `$0656`
3. Read direction sprite + animation duration from `dir_sprite_01ABDE` / `table_01B086`
4. Clear actor flags, stage player sprite, animate once
5. Look up camera scroll speed from `table_01A95E` → `$06E0`, zero `$2A`, reset X
6. Execute `COP [PanCamera*]` in the appropriate direction
7. Apply scroll position offset via `ApplyScrollOffset`
8. Re-read direction sprite, re-animate
9. Sync player position via `SyncPlayerToCamera`
10. Unmask joypad, `COP [Die]`

### `ForcedWalkSouth` ($00EB9B)

- **Hex address:** `$EB9B` (decimal 60315)
- **Size:** 84 bytes
- **Direction:** `COP [PanCameraDown]`
- **Sprite lookup:** `ReadDirSprite_YVelocity` → stores to `$2E`

### `ForcedWalkNorth` ($00EBEF)

- **Hex address:** `$EBEF` (decimal 60399)
- **Size:** 84 bytes
- **Direction:** `COP [PanCameraUp]`
- **Sprite lookup:** `ReadDirSprite_YVelocity`

### `ForcedWalkWest` ($00EC43)

- **Hex address:** `$EC43` (decimal 60483)
- **Size:** 84 bytes
- **Direction:** `COP [PanCameraLeft]`
- **Sprite lookup:** `ReadDirSprite_XVelocity` → stores to `$2C`

### `ForcedWalkEast` ($00EC97)

- **Hex address:** `$EC97` (decimal 60567)
- **Size:** 84 bytes
- **Direction:** `COP [PanCameraRight]`
- **Sprite lookup:** `ReadDirSprite_XVelocity`

---

## E683-5. Utility Subroutines

### `TileAlignCoord` ($00ECEB)

- **Hex address:** `$ECEB` (decimal 60651)
- **Size:** 13 bytes
- **Purpose:** Aligns a pixel coordinate to the tile grid. `A >> 4` (divide by 16) with 8-bit precision, then mask to `$0F0F`. Returns result in Y.
- **Called by:** `ScrollCameraInit`, `TileAlignPosition`

### `TileAlignPosition` ($00ECF8)

- **Hex address:** `$ECF8` (decimal 60664)
- **Size:** 19 bytes
- **Purpose:** Tile-aligns both actor X (`$14 - 8`) and Y (`$16`) via `TileAlignCoord`, storing results back to `$14`/`$16`.
- **Called by:** `ScrollCameraTrack`, `ScrollCameraVertical`, `ScrollCameraAccumulate`

### `ComputeScrollDeltas` ($00ED0B)

- **Hex address:** `$ED0B` (decimal 60683)
- **Size:** 29 bytes
- **Purpose:** Computes camera scroll deltas. If `$14 ≠ 0`, calls `func_028000(Y=$06BE)` → `$06C0`. If `$16 ≠ 0`, calls `func_028000(Y=$06C2)` → `$06C4`.
- **Called by:** `ScrollCameraInit`, `ScrollCameraTrack`, `ScrollCameraAccumulate`

### `ReadDirSprite_YVelocity` ($00ED28)

- **Hex address:** `$ED28` (decimal 60712)
- **Size:** 32 bytes
- **Purpose:** Reads a direction byte from the forced-walk data stream at `$0650`, looks up sprite index from `dir_sprite_01ABDE`, and animation duration from `table_01B086`. Stores sprite to `$0000`, duration to `$2E` (Y velocity).
- **Called by:** `ForcedWalkSouth`, `ForcedWalkNorth`

### `ReadDirSprite_XVelocity` ($00ED48)

- **Hex address:** `$ED48` (decimal 60744)
- **Size:** 32 bytes
- **Purpose:** Same as above but stores duration to `$2C` (X velocity). Used for horizontal walks.
- **Called by:** `ForcedWalkWest`, `ForcedWalkEast`

### `ApplyScrollOffset` ($00ED68)

- **Hex address:** `$ED68` (decimal 60776)
- **Size:** 28 bytes
- **Purpose:** Reads a 4-byte position delta from the data stream at `$0650`, adds to actor position `$14`/`$16`, advances stream pointer by 4.
- **Called by:** All four forced walk functions

### `SyncPlayerToCamera` ($00ED84)

- **Hex address:** `$ED84` (decimal 60804)
- **Size:** 36 bytes
- **Purpose:** Copies the actor's position to the player actor, sets player flags for normal walking (`OR $0008, AND $FDFF` on `$10`), copies animation state `$28`, zeros wait counter `$0008`.
- **Called by:** All four forced walk functions

### `ComputeFollowAngle` ($00EDA8)

- **Hex address:** `$EDA8` (decimal 60840)
- **Size:** ~27 bytes (through shared tail with `ComputeFollowAngleAlt`)
- **Purpose:** Computes angular step value for the smooth follow engine. Compares primary/secondary axis distances and uses `func_0281E8` (step count calculator) to derive a 16-step direction index. Stores result in `$7F0010,X`.
- **Axis comparison:** Primary axis is `$0018` (X distance)

### `ComputeFollowAngleAlt` ($00EDC3)

- **Hex address:** `$EDC3` (decimal 60867)
- **Size:** ~93 bytes (shared tail with `ComputeFollowAngle`)
- **Purpose:** Same as above but with axes swapped — primary is `$001C` (Y distance).

### `ComputeFollowStep` ($00EE1C)

- **Hex address:** `$EE1C` (decimal 60956)
- **Size:** 96 bytes
- **Purpose:** Computes the actual pixel movement step from the follow angle. Uses `$7F0010,X` (angle) and `$7F0012,X` (sub-step) combined as a table index into `binary_00F193` (smooth interpolation table). Accumulates fractional movement.
- **Called by:** All 8 direction handlers

### `ResolveFollowDirection` ($00EE7C)

- **Hex address:** `$EE7C` (decimal 61052)
- **Size:** ~18 bytes (entry point to shared resolution logic)
- **Purpose:** Entry point A — resolves follow direction for primary-axis-dominant cases. Branches based on `$7F0010,X` value ranges (< 5, 5–12, ≥ 13) into speed categories.

### `ResolveFollowDirectionAlt` ($00EE8C)

- **Hex address:** `$EE8C` (decimal 61059)
- **Size:** ~228 bytes (entire resolution + direction update + sprite dispatch)
- **Purpose:** Entry point B — resolves follow direction for secondary-axis-dominant cases. Same 3-category branching as above but with inverted comparisons. After categorizing, updates `$7F000E,X` (direction index 0–15), dispatches to one of 16 sprite/priority handlers via `FollowDirectionTable`, and calls `func_03CA55` to advance animation.

### Direction Sprite Handlers (`code_00EF92`–`code_00F172`)

- **Hex address range:** `$EF92`–`$F192`
- **Count:** 16 handlers (one per 22.5° direction)
- **Size:** ~33 bytes each (545 bytes total including table)
- **Purpose:** Each handler sets the actor's OAM flags (`$000E,Y`) for the correct sprite priority/mirror bits and computes the walking sprite index stored in `$0000` and angular step in `$7F0010,X`. Returns with RTS.

| Handler | Index | OAM Priority Bits | Walk Direction |
|---------|-------|--------------------|----------------|
| `code_00EF92` | 0 (N) | `AND $3FFF` (front) | `$0001` → step `$10` |
| `code_00EFB0` | 1 (NNE) | `AND $3FFF` | `$0001` → step `$08` |
| `code_00EFCE` | 2 (NE) | `AND $3FFF` | `$0002` → step `$00` |
| `code_00EFEC` | 3 (ENE) | `AND $3FFF` | `$0002` → step `$08` |
| `code_00F00A` | 4 (E) | `AND $3FFF` | `$0003` → step `$10` |
| `code_00F028` | 5 (ESE) | `OR $8000` (H-flip) | `$0003` → step `$08` |
| `code_00F049` | 6 (SE) | `OR $8000` | `$0004` → step `$00` |
| `code_00F06A` | 7 (SSE) | `OR $8000` | `$0004` → step `$08` |
| `code_00F08B` | 8 (S) | `OR $8000` | `$0005` → step `$10` |
| `code_00F0AC` | 9 (SSW) | `OR $C000` (H+V flip) | `$0005` → step `$08` |
| `code_00F0CD` | 10 (SW) | `OR $C000` | `$0006` → step `$00` |
| `code_00F0EE` | 11 (WSW) | `OR $C000` | `$0006` → step `$08` |
| `code_00F10F` | 12 (W) | `OR $4000` (V-flip) | `$0007` → step `$10` |
| `code_00F130` | 13 (WNW) | `OR $4000` | `$0007` → step `$08` |
| `code_00F151` | 14 (NW) | `OR $4000` | `$0008` → step `$00` |
| `code_00F172` | 15 (NNW) | `OR $4000` | `$0008` → step `$08` |

---

## E683-6. Data Tables

### `FollowDirectionTable` ($00EF72)

- **Hex address:** `$EF72` (decimal 61298)
- **Size:** 32 bytes (16 × 2-byte pointers)
- **Purpose:** Jump table for the 16-direction smooth follow sprite handlers. Indexed by `$7F000E,X & $0F`.

### `SmoothFollowLookup` ($00F193)

- **Hex address:** `$F193` (decimal 61843)
- **Size:** 544 bytes (binary data)
- **Purpose:** Interpolation table for smooth movement. Contains pairs of signed 16-bit values indexed by angle × sub-step, used by `ComputeFollowStep` to accumulate fractional pixel movement. The values decrease in magnitude at higher indices, creating smooth deceleration curves.
- **Format:** Sequence of 16-bit words; `$0100` (1.0) at low indices tapering to `$0000` at high indices

---

## E683-7. Variable Map

### Smooth Follow Engine Variables

| Address | Size | Name | Used By |
|---------|------|------|---------|
| `$7F000A,X` | 2 | Movement parameter / sprite flag | `CopySiblingFollowState`, direction resolve |
| `$7F000E,X` | 2 | Direction index (0–15) | Chase loop, direction resolve |
| `$7F0010,X` | 2 | Angular step / follow angle | `ComputeFollowAngle`, direction handlers |
| `$7F0012,X` | 2 | Sub-step accumulator | `ComputeFollowStep`, `ApplyFollowMovement` |
| `$7F0014,X` | 2 | Sibling sprite index | `CopySiblingFollowState` |
| `$7F002C,X` | 2 | Applied velocity X | `ApplyFollowMovement` |
| `$7F002E,X` | 2 | Applied velocity Y | `ApplyFollowMovement` |
| `$04` | 2 | Predecessor link (sibling ID) | `ApplyFollowMovement`, follow engine |
| `$24` | 2 | Player actor reference | Chase loop player position read |
| `$0018` | 2 | Absolute X distance | Chase loop direction dispatch |
| `$001C` | 2 | Absolute Y distance | Chase loop direction dispatch |

### Camera Actor Variables

| Address | Size | Name | Used By |
|---------|------|------|---------|
| `$14` | 2 | Tile-aligned X (after `TileAlignPosition`) | All camera actors |
| `$16` | 2 | Tile-aligned Y | All camera actors |
| `$24`/`$26` | 2 each | Scroll accumulator X/Y | `ScrollCameraAccumulate` |
| `$06BE` | 2 | Camera target X | `ComputeScrollDeltas` |
| `$06C0` | 2 | Camera delta X | `ComputeScrollDeltas`, `ScrollCameraAccumulate` |
| `$06C2` | 2 | Camera target Y | `ComputeScrollDeltas` |
| `$06C4` | 2 | Camera delta Y | `ComputeScrollDeltas`, `ScrollCameraVertical`, `ScrollCameraAccumulate` |
| `$06C8` | 2 | Forced scroll override | `ScrollCameraInit` |
| `$0690` | 2 | Saved camera delta | `ScrollCameraInit` |

### Forced Walk Variables

| Address | Size | Name | Used By |
|---------|------|------|---------|
| `$0650` | 2 | Walk data stream pointer | `ReadDirSprite_*`, `ApplyScrollOffset` |
| `$0656` | 2 | Filtered joypad state | Zeroed by forced walks |
| `$06E0` | 2 | Scroll speed table entry | All forced walks |
| `$06E2` | 2 | Scroll step index | All forced walks (zeroed) |
| `$2A` | 2 | Animation frame | All forced walks (zeroed) |
| `$2C` | 2 | X velocity (anim speed) | `ReadDirSprite_XVelocity` |
| `$2E` | 2 | Y velocity (anim speed) | `ReadDirSprite_YVelocity` |

---

## E683-8. Call Reference Matrix

### Internal Calls

| Caller | Callee | Count |
|--------|--------|-------|
| Chase direction blocks (8) | `ComputeFollowAngle` / `ComputeFollowAngleAlt` | 8 |
| Chase direction blocks (8) | `ComputeFollowStep` | 8 |
| Chase direction blocks (8) | `ResolveFollowDirection` / `ResolveFollowDirectionAlt` | 8 |
| Forced walks (4) | `ReadDirSprite_YVelocity` / `ReadDirSprite_XVelocity` | 4 |
| Forced walks (4) | `ApplyScrollOffset` | 4 |
| Forced walks (4) | `SyncPlayerToCamera` | 4 |
| Camera actors (3) | `TileAlignPosition` | 3 |
| Camera actors (3) | `ComputeScrollDeltas` | 3 |
| `TileAlignPosition` | `TileAlignCoord` | 2 |

### External Calls

| Target | Bank | Called By | Purpose |
|--------|------|-----------|---------|
| `func_028000` | $02 | `ComputeScrollDeltas`, `ScrollCameraVertical` | Signed multiply/clamp |
| `func_0281E8` | $02 | `ComputeFollowAngle`/`Alt` | Step count calculation |
| `func_03CA55` | $03 | `ResolveFollowDirectionAlt` (×16) | Advance sprite animation |

---

## E683-9. Statistics

### Code Distribution

| Category | Count | Size |
|----------|-------|------|
| Follow engine functions | 2 entry + 8 direction + 2 resolve | ~858 bytes |
| Apply movement + fallback | 2 | ~73 bytes |
| Camera actors | 4 | ~149 bytes |
| Forced walk functions | 4 | ~336 bytes |
| Utility subroutines | 9 | ~352 bytes |
| Direction sprite handlers | 16 | ~545 bytes |
| Data tables | 2 | ~576 bytes |
| **Total** | **~47 parts** | **~2,889 bytes** |

### Scene Usage Summary

| Actor/Function | Scene Count | Areas |
|----------------|-------------|-------|
| `ScrollCameraTrack` | ~40+ | Nearly all towns and overworlds |
| `ScrollCameraVertical` | ~10 | Edward's Castle, Itory, Incan Ruins, Dao |
| `ScrollCameraAccumulate` | ~5 | Pyramid interiors |
| `ScrollCameraInit` | ~10 | Mt. Kress exclusively |
| Forced walks (via COP pan) | Used by ramp/stair transitions | All areas with elevation changes |
| `CopySiblingFollowState` / `InitFollowAndChase` | 0 direct scene refs | Called programmatically by other actors |

---

# File Boundary Analysis & Split/Merge Recommendations

## Current Layout

| File | Block | Address Range | Content Mix |
|------|-------|---------------|-------------|
| `chunk_00D088.asm` | `chunk_00D088` | $D088–$D2D2 + $D58A | 5 stair triggers + 4 climb funcs + 4 utility subs |
| `ramps.asm` | (same block) | $D2D3–$D5BF + $D5C0 | 4 ramp actors + physics + sprite anim |
| `chunk_00E683.asm` | `chunk_00E683` | $E683–$F292 | Follow engine + 4 camera actors + 4 forced walks + data table |

## Recommendation 1: Keep `chunk_00D088.asm` + `ramps.asm` Together

**Verdict: Do NOT split.** These two files are already well-organized:

- `ramps.asm` `?INCLUDE`s `chunk_00D088`, so they compile as one unit
- Both share `RestorePlayerControl` ($D58A) via `JSR $&` — splitting would require cross-file long references
- The block is marked `movable: false` because of tight `$&` (same-bank short ref) coupling
- Total combined size is ~1,336 bytes — small enough for one conceptual unit
- All content is thematically related: "player elevation movement" (stairs + slopes)

**However**, renaming would help clarity:
- `chunk_00D088.asm` → conceptually this is "stair_triggers" (the trigger half)
- `ramps.asm` already has a good name (the slope half)

## Recommendation 2: Split `chunk_00E683.asm` into 3 Files

**Verdict: SPLIT URGENTLY.** This file conflates three unrelated subsystems:

### Split A: `smooth_follow.asm` (Follow/Chase Engine)
- `CopySiblingFollowState` ($E683)
- `InitFollowAndChase` ($E6A6) + all 8 direction handlers
- `ApplyFollowMovement` ($E87E)
- `SelectFallbackDirection` ($E8BA) + dispatch table
- `ComputeFollowAngle` ($EDA8) / `ComputeFollowAngleAlt` ($EDC3)
- `ComputeFollowStep` ($EE1C)
- `ResolveFollowDirection` ($EE7C) / `ResolveFollowDirectionAlt` ($EE8C)
- `FollowDirectionTable` ($EF72) + 16 direction handlers
- `SmoothFollowLookup` ($F193)
- **Why:** Self-contained engine with no dependency on camera actors or forced walks. Uses only `$&` internal calls + 3 external JSLs. ~2,000 bytes.

### Split B: `camera_scroll_actors.asm` (Scene Camera Actors)
- `ScrollCameraInit` ($E94D)
- `ScrollCameraTrack` ($EA96)
- `ScrollCameraVertical` ($EAA7)
- `ScrollCameraAccumulate` ($EAC3)
- `TileAlignCoord` ($ECEB)
- `TileAlignPosition` ($ECF8)
- `ComputeScrollDeltas` ($ED0B)
- **Why:** These four actors + their three helpers form a complete camera management package. They are the most-used actors in the game (~40+ scenes). ~210 bytes — compact but conceptually distinct.

### Split C: `forced_walk.asm` (Forced Player Walk)
- `ForcedWalkSouth` ($EB9B)
- `ForcedWalkNorth` ($EBEF)
- `ForcedWalkWest` ($EC43)
- `ForcedWalkEast` ($EC97)
- `ReadDirSprite_YVelocity` ($ED28)
- `ReadDirSprite_XVelocity` ($ED48)
- `ApplyScrollOffset` ($ED68)
- `SyncPlayerToCamera` ($ED84)
- **Why:** Four parallel forced-walk functions + four helpers. Referenced by ramp/stair transitions. ~450 bytes.

### Cross-Dependency Analysis

| From → To | References | Type |
|-----------|-----------|------|
| Smooth Follow → Camera Actors | **0** | None |
| Smooth Follow → Forced Walk | **0** | None |
| Camera Actors → Smooth Follow | **0** | None |
| Camera Actors → Forced Walk | **0** | None |
| Forced Walk → Camera Actors | **0** | None |
| Forced Walk → Smooth Follow | **0** | None |

**All three subsystems have zero internal cross-references**, making this a clean split with no `$&` dependency concerns. Each group's internal `$&` calls remain within the split boundary.

## Recommendation 3: Link Forced Walk to Stair/Ramp System

After splitting, `forced_walk.asm` should be considered for grouping with the stair/ramp system since both handle player elevation transitions. However, the forced walks use `COP [PanCamera*]` (system COPs) rather than `JSR $&`, so they don't need same-bank proximity. A `?INCLUDE` from `ramps.asm` or a shared parent file would be sufficient.

## Summary Priority

| Priority | Action | Risk | Impact |
|----------|--------|------|--------|
| **High** | Split `chunk_00E683.asm` into 3 files | Low (zero cross-deps) | Separates 3 unrelated systems, enables independent movement |
| **Low** | Rename `chunk_00D088` conceptually to "stair_triggers" | None | Documentation clarity only |
| **None** | Do not split `chunk_00D088` + `ramps.asm` | N/A | Already well-structured |
