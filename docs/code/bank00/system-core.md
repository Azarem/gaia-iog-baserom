# Bank $00 — System Core: Reset, Init, Main Loop & Frame Updates

**Bank:** `$00` (mirrored at `$80` for FastROM access)  
**Address range:** `$008000`–`$0082DE`  
**ASM file:** `extracted/system/system_core.asm`  
**Block:** `system/system_core` in `us/blocks.json`

This page documents the CPU entry point, interrupt vector trampolines, one-time system initialization, the eternal main game loop, and the alternate per-frame update paths used during dialogue, text overlays, and music transitions. Together these routines form the backbone of Illusion of Gaia's runtime: everything else (actors, scenes, rendering) is invoked from here.

**Related:** [`nmi-handler.md`](nmi-handler.md) covers the VBlank handler at `$0082F8`–`$00843F`. [`chunk_008000-analysis.md`](../chunk_008000-analysis.md) covers the full system code page including COP dispatch.

---

## Overview

| Category | Functions | Approx. Size |
|----------|-----------|--------------|
| Interrupt vectors & reset | 5 | 20 bytes |
| System init + main loop | 1 | 266 bytes |
| Frame update variants | 4 | ~400 bytes |
| **Total (this document)** | **11** | **~686 bytes** |

### Execution Model

```
Power-on / Reset
    └── ResetVector ($8000)
            └── SystemInit ($8014)
                    ├── Init phase (once)
                    └── Main loop @ $0080B5 (forever)
                            └── func_028191 → wait for NMI (VBlank)
                                    └── NmiHandler ($82F8) — see nmi-handler.md

Alternate frame paths (called from dialogue/text/music code):
    UpdateFrame_Dialogue ($811E)  — cutscenes / dialogue
    UpdateFrame_Render   ($817D)  — text overlay only
    UpdateFrame_Full     ($81BC)  — music handshake from NMI
```

---

## Interrupt Vectors & Reset

### ResetVector

| Property | Value |
|----------|-------|
| **Old Name** | `emulation_mode_reset_008000` |
| **New Name** | `ResetVector` |
| **Hex Address** | `$008000` |
| **Decimal Address** | 32768 |
| **Size** | 7 bytes |
| **ASM File** | `extracted/system/system_core.asm` |

#### Description

Hardware reset vector for the SNES. On power-on or soft reset the 65C816 enters **emulation mode** with the status register in a vendor-defined state. This 7-byte stub performs the minimum work required to enter **native mode** and transfer control to `SystemInit`. No stack frames are pushed; the stack pointer is undefined until `SystemInit` sets it.

The label prefix `emulation_mode_reset_` reflects the engine's naming convention for code that runs while the E (emulation) flag is still set. After `XCE`, all subsequent code in bank `$00` assumes native mode.

#### Algorithm

| Step | Instruction | Effect |
|------|-------------|--------|
| 1 | `SEI` | Mask IRQ/NMI during mode transition |
| 2 | `CLC` | Clear carry — required before `XCE` |
| 3 | `XCE` | Toggle emulation bit: enter native 65816 mode (M/X width, 24-bit addressing) |
| 4 | `JML $@SystemInit` | Long jump to system initialization (3-byte far address, bank `$00`) |

#### Variables

None — no WRAM access.

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | SNES hardware reset | Fixed vector at `$00:8000` |
| Calls | `SystemInit` (`$008014`) | Via `JML $@` (cross-bank-safe long jump) |
| Cataloged in | `us/names.json` @ 32768 | Renamed `ResetVector` |

---

### CopVector

| Property | Value |
|----------|-------|
| **Old Name** | `native_mode_cop_008007` |
| **New Name** | `CopVector` |
| **Hex Address** | `$008007` |
| **Decimal Address** | 32775 |
| **Size** | 4 bytes |
| **ASM File** | `extracted/system/system_core.asm` |

#### Description

COP (Coprocessor) hardware interrupt vector. The COP opcode is the primary bytecode mechanism for actor and thinker scripts in IOG. When any COP instruction executes, the CPU vectors here and immediately jumps to the full dispatch engine at `CopDispatch` (`$00846D`). This trampoline must remain in bank `$00` at the fixed vector offset `$8007`.

#### Algorithm

| Step | Instruction | Effect |
|------|-------------|--------|
| 1 | `JML $@CopDispatch` | Far jump to COP dispatch table engine |

#### Variables

None.

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | SNES COP opcode | All actor/thinker script instructions |
| Calls | `CopDispatch` (`$00846D`) | 24-byte dispatch engine; see `cop-commands-reference.md` |
| Cataloged in | `us/names.json` @ 32775 | |

---

### NmiVector

| Property | Value |
|----------|-------|
| **Old Name** | `native_mode_nmi_00800B` |
| **New Name** | `NmiVector` |
| **Hex Address** | `$00800B` |
| **Decimal Address** | 32779 |
| **Size** | 4 bytes |
| **ASM File** | `extracted/system/system_core.asm` |

#### Description

NMI (Non-Maskable Interrupt) hardware vector, fired once per frame during vertical blank. The main game loop (`SystemInit` @ `$0080B5`) blocks in `func_028191` (end frame / wait VBlank); when NMI fires, control enters `NmiHandler` via this trampoline. All PPU register writes and DMA occur inside the handler, not in the main loop.

#### Algorithm

| Step | Instruction | Effect |
|------|-------------|--------|
| 1 | `JML $@NmiHandler` | Far jump to VBlank handler at `$0082F8` |

#### Variables

None.

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | SNES NMI (VBlank) | ~60 Hz during active display |
| Calls | `NmiHandler` (`$0082F8`) | Documented in [`nmi-handler.md`](nmi-handler.md) |
| Cataloged in | `us/names.json` @ 32779 | |

---

### IrqVector

| Property | Value |
|----------|-------|
| **Old Name** | `native_mode_irq_00800F` |
| **New Name** | `IrqVector` |
| **Hex Address** | `$00800F` |
| **Decimal Address** | 32783 |
| **Size** | 4 bytes |
| **ASM File** | `extracted/system/system_core.asm` |

#### Description

IRQ (maskable interrupt) hardware vector. IOG does not use IRQ for gameplay; the vector still must point to valid code. The handler is a single-byte `RTI` stub. HDMA and joypad polling are handled from NMI instead.

#### Algorithm

| Step | Instruction | Effect |
|------|-------------|--------|
| 1 | `JML $@IrqHandler` | Far jump to IRQ stub at `$008013` |

#### Variables

None.

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | SNES IRQ (if enabled) | Never enabled in normal gameplay |
| Calls | `IrqHandler` (`$008013`) | No-op stub |
| Cataloged in | `us/names.json` @ 32783 | |

---

### IrqHandler

| Property | Value |
|----------|-------|
| **Old Name** | `native_mode_irq_handler_008013` |
| **New Name** | `IrqHandler` |
| **Hex Address** | `$008013` |
| **Decimal Address** | 32787 |
| **Size** | 1 byte |
| **ASM File** | `extracted/system/system_core.asm` |

#### Description

Minimal IRQ service routine. Immediately returns from interrupt without modifying registers or WRAM. Present only to satisfy the hardware vector at `$800F`; enabling IRQ in `$NMITIMEN` or PPU registers would cause an instant return with no side effects.

#### Algorithm

| Step | Instruction | Effect |
|------|-------------|--------|
| 1 | `RTI` | Restore P and PC from stack; return to interrupted code |

#### Variables

None.

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | `IrqVector` (`$00800F`) | |
| Cataloged in | `us/names.json` @ 32787 | |

---

## SystemInit & Main Loop

### SystemInit

| Property | Value |
|----------|-------|
| **Old Name** | `emulation_mode_reset_handler_008014` |
| **New Name** | `SystemInit` |
| **Hex Address** | `$008014` |
| **Decimal Address** | 32788 |
| **Size** | 266 bytes (init ~161 B @ `$8014`–`$80B4`, main loop ~105 B @ `$80B5`–`$811D`) |
| **ASM File** | `extracted/system/system_core.asm` |

#### Description

Central system entry after reset. Performs complete hardware and game-state initialization once, then enters an infinite main loop that drives one logical frame per iteration. The loop is **not** interrupt-driven for game logic — it runs on the main thread and synchronizes to VBlank via `func_028191` at the end of each iteration. NMI handles PPU/DMA separately (see [`nmi-handler.md`](nmi-handler.md)).

The init phase configures the 65816 (16-bit A/X, DP=`$0000`, SP=`$01FF`, DBR=`$81`), enables FastROM, initializes PPU/VRAM/WRAM/actors, validates SRAM, loads the first scene, seeds HUD/stat pointers, and sets the title screen as the next scene (`$scene_next = $FB`).

The main loop at **`loc_0080B5`** executes 22 ordered steps every frame: frame begin, scene transitions, map/scroll, scene load, palette animation, scene logic, frame counters, actor scripts, OAM composition, full collision pipeline, position integration, BG scroll, HDMA, map tiles, sprites, HUD, deferred DMA, and frame end.

#### Initialization Algorithm

| Step | Call / Action | Effect |
|------|---------------|--------|
| 1 | `CLD` | Decimal mode off |
| 2 | `REP #$30` | 16-bit accumulator and index registers |
| 3 | `LDA #$0000` / `TCD` | Direct page register = `$0000` |
| 4 | `LDA #$01FF` / `TCS` | Stack pointer = `$01FF` |
| 5 | `LDA #$81` / `PHA` / `PLB` | Data bank register (DBR) = `$81` for WRAM `$0000`–`$7FFF` |
| 6 | `LDA #$01` / `STA $MEMSEL` | Enable FastROM mapping (3.58 MHz) |
| 7 | `JSL func_029F31` | Initialize PPU control registers (bank `$02`) |
| 8 | `JSL func_029E44` | Clear VRAM to blank tiles |
| 9 | `JSL func_02908E` | Initialize WRAM / global game state |
| 10 | `JSL func_0281BC` | Initialize actor linked lists and pool |
| 11 | SRAM check | Read `$000100`; if magic byte = `$83`, valid save exists (affects starting scene path) |
| 12 | `JSL func_03D9F6` | Load initial scene data |
| 13 | HUD pointer init | Copy addresses from `binary_01C384` (sine/HUD table) into `$09BA`–`$09C4` |
| 14 | Stat display init | Seed DEF/STR/HP display counters at `$0ACA`–`$0ADE` |
| 15 | Title screen | `STA $scene_next` with `$FB` — queue title scene |

#### Main Loop Algorithm (`loc_0080B5`)

| Step | Call | Bank | Purpose |
|------|------|------|---------|
| 1 | `func_028043` | `$02` | **Begin frame** — reset per-frame rendering state |
| 2 | `func_0281A2` | `$02` | **Scene transitions** — process `$scene_next` / warp queue |
| 3 | `func_03D12D` | `$03` | **Map/scroll state** — update camera and map bookkeeping |
| 4 | `func_03D9E8` | `$03` | **Scene loading** — async scene data fetch |
| 5 | `func_02A5DD` | `$02` | **Palette animation** — step ambient color cycles |
| 6 | `func_038000` | `$03` | **Scene logic** — per-scene thinker/hook entry |
| 7 | `UpdateFrameCounters` | `$00` | Decrement invincibility; increment frame timer |
| 8 | `run_actors_03CAF5` | `$03` | **Run actors** — execute all actor COP scripts |
| 9 | OAM sentinel | — | Write `$FF` to `$7F3100+$00D8` and `$7F3101+$00D8` (end-of-sprite marker) |
| 10 | `func_03C5FF` | `$03` | **OAM sort/compose** — build sprite table for NMI upload |
| 11 | `func_03BBE4` | `$03` | **Collision responses** — run hit/damage handlers |
| 12 | `code_03C25E` | `$03` | **Collision detect** — pairwise actor overlap tests |
| 13 | `func_03BBB4` | `$03` | **Finalize collision** — commit collision results |
| 14 | `func_03BB85` | `$03` | **Update positions** — integrate velocity into `$14`/`$16` |
| 15 | `func_02AC2E` (X=0) | `$02` | **BG scroll layer 0** — compute BG1 scroll |
| 16 | `func_02AC2E` (X=2) | `$02` | **BG scroll layer 1** — compute BG2 scroll |
| 17 | `func_03E146` | `$03` | **HDMA update** — rebuild HDMA channel table → `$66` |
| 18 | `func_03D15D` | `$03` | **Map tile updates** — queue metatile VRAM writes |
| 19 | `func_03C714` | `$03` | **Finalize sprites** — last-minute OAM adjustments |
| 20 | `UpdateHUD` | `$00` | **HUD update** — BG3 status bar (HP/DEF/STR/gems/XP) |
| 21 | `func_03E21E` | `$03` | **Deferred DMA** — flush queued non-VBlank DMA |
| 22 | `func_028191` | `$02` | **End frame** — wait for VBlank/NMI |
| — | `BRL loc_0080B5` | — | Loop forever |

#### Variables

| Address | Size | Name / Role | Access |
|---------|------|-------------|--------|
| `$000100` | 1 | SRAM magic byte | Read — `$83` = valid save |
| `$00D8` | 2 | OAM write offset | R/W — index into `$7F3100` OAM buffer |
| `$7F3100`+ | 2 | OAM sentinel slot | Write — `$FF` marks end of sprite list |
| `$scene_next` | 2 | Next scene ID | Write — set to `$FB` for title |
| `$0654` | 2 | World-ready flag | Init — gates dialogue when ≠ `$000F` |
| `$099F` | 2 | Scene/state helper | Init |
| `$09BA`–`$09C4` | 11 | HUD sine/pointer table | Write — from `binary_01C384` |
| `$09C8` / `$09CA` | 4 | HUD related pointers | Init |
| `$0ACA` / `$0ACE` | 4 | Current/max DEF display | Init / HUD |
| `$0ADE` / `$0ADC` | 4 | STR / HP display bases | Init / HUD |
| `$0B28`–`$0B32` | 11 | Save/warp metadata region | Init context |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | `ResetVector` | Only entry from reset |
| Calls | 17 external JSL targets | Banks `$02` and `$03`; see main loop table |
| Calls | `UpdateFrameCounters`, `UpdateHUD` | Same-bank JSR |
| Related | `UpdateFrame_Dialogue`, `UpdateFrame_Render`, `UpdateFrame_Full` | Abbreviated loops for special modes |
| Cataloged in | `us/names.json` @ 32788 | |

---

## Frame Update Functions

These three routines provide **subset main loops** for modes that must advance the display without running the full simulation (collision, map updates, scene logic). All three save full CPU context before touching game state and restore it on return.

**Common context-save prologue:** `PHB`, `PHA`, `XBA`, `PHA`, `PHX`, `PHY`, `PHD` → set `D=$0000`, `DBR=$81` → … → reverse on exit.

---

### UpdateFrame_Dialogue

| Property | Value |
|----------|-------|
| **Old Name** | `func_00811E` |
| **New Name** | `UpdateFrame_Dialogue` |
| **Hex Address** | `$00811E` |
| **Decimal Address** | 33054 |
| **Size** | 95 bytes |
| **ASM File** | `extracted/system/system_core.asm` |

#### Description

Abbreviated frame update for **dialogue boxes and cutscenes**. Keeps the world visible and animated (sprites, scroll, HDMA, map tile refresh) but **skips** collision detection, actor COP execution, scene logic, palette animation, and the full collision response pipeline. Used when the text engine needs to pump frames while blocking player control.

Clears `$09EC` bit `$08` (dialogue display flag) as part of its setup. Writes the OAM sentinel at `$7F3100+$00D8` like the main loop.

#### Algorithm

| Step | Call | Purpose |
|------|------|---------|
| 1 | Save context | `PHB/PHA/XBA/PHA/PHX/PHY/PHD`; `D=$0000`, `DBR=$81` |
| 2 | Clear `$09EC` bit 8 | Exit dialogue-display mode flag |
| 3 | `func_028043` | Begin frame |
| 4 | `func_0281A2` | Scene transitions (still active during some cutscenes) |
| 5 | `func_03D18D` | Map/scroll helper (lightweight vs `func_03D12D`) |
| 6 | `func_03CCFF` | Dialogue-specific sprite prep |
| 7 | OAM sentinel | `$7F3100/01 + $00D8` ← `$FF` |
| 8 | `func_03C5FF` | OAM sort/compose |
| 9 | `func_02AC2E` ×2 | BG scroll (layers 0 and 2) |
| 10 | `func_03E146` | HDMA channel update |
| 11 | `func_03D1C2` | Map tile refresh (subset of `func_03D15D`) |
| 12 | `func_03C714` | Finalize sprites |
| 13 | `func_028191` | End frame / wait VBlank |
| 14 | Restore context | `PLD/PLY/PLX/PLA/XBA/PLA/PLB`; `RTL` |

#### Variables

| Address | Size | Role |
|---------|------|------|
| `$00D8` | 2 | OAM buffer offset |
| `$7F3100` / `$7F3101` | 2 | OAM sentinel write target |
| `$09EC` | 2 | Display flags — bit `$08` cleared |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | Text/dialogue engine (bank `$03`) | During `$BF`-class text without full refresh |
| Calls | 10 external JSL + context save | No collision or `run_actors` |
| Cataloged in | `us/names.json` @ 33054 | |

---

### UpdateFrame_Render

| Property | Value |
|----------|-------|
| **Old Name** | `func_00817D` |
| **New Name** | `UpdateFrame_Render` |
| **Hex Address** | `$00817D` |
| **Decimal Address** | 33149 |
| **Size** | 63 bytes |
| **ASM File** | `extracted/system/system_core.asm` |

#### Description

**Lightest** frame pump — used for **text rendering overlays** where even map tile updates are unnecessary. Runs sprite sort, HDMA, scroll finalization, HUD, and frame begin/end only. Same full context save as `UpdateFrame_Dialogue`.

#### Algorithm

| Step | Call | Purpose |
|------|------|---------|
| 1 | Save context | Full `PHB`…`PHD` prologue; `D=$0000`, `DBR=$81` |
| 2 | `func_028043` | Begin frame |
| 3 | `func_0281A2` | Scene transitions |
| 4 | `func_03D18D` | Minimal scroll finalize |
| 5 | `func_03C5FF` | OAM sort/compose |
| 6 | `func_03E146` | HDMA update |
| 7 | `func_03D1C2` | Scroll/layer finalize |
| 8 | `func_03C714` | Finalize sprites |
| 9 | `UpdateHUD` | Status bar (may still show during some overlays) |
| 10 | `func_028191` | End frame / wait VBlank |
| 11 | Restore context | `RTL` |

#### Variables

| Address | Size | Role |
|---------|------|------|
| `$00D8` | 2 | OAM offset (if sentinel written by caller) |
| `$09EC` | 2 | Inherited display flags |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | BG3 text overlay paths | Lighter than `UpdateFrame_Dialogue` |
| Calls | `UpdateHUD` | Same-bank JSR |
| Cataloged in | `us/names.json` @ 33149 | |

---

### UpdateFrame_Full

| Property | Value |
|----------|-------|
| **Old Name** | `func_0081BC` |
| **New Name** | `UpdateFrame_Full` |
| **Hex Address** | `$0081BC` |
| **Decimal Address** | 33212 |
| **Size** | 74 bytes |
| **ASM File** | `extracted/system/system_core.asm` |

#### Description

Near-complete single-frame update **including collision and actor movement**, but invoked from **NMI** during **music transition handshake** (`$06FA ≠ 0`). Allows the game simulation to advance while the main CPU thread is blocked waiting for APU acknowledgment. Uses a lighter save (`PHP`, `PHB`) because it runs inside the NMI stack frame.

Does not call `UpdateHUD`, scene logic, or the full 22-step main loop — it covers transitions, collision, OAM, scroll, HDMA, and sprites sufficient for music-crossfade frames.

#### Algorithm

| Step | Call | Purpose |
|------|------|---------|
| 1 | `PHP` / `PHB` | Save flags and data bank |
| 2 | Set `DBR=$81` | WRAM data bank |
| 3 | `func_0281A2` | Scene transitions |
| 4 | `func_02803B` | Frame begin variant (NMI-safe) |
| 5 | `func_03D18D` | Scroll finalize |
| 6 | `func_03CD6E` | Actor update pass (subset of full actor run) |
| 7 | OAM sentinel | `$7F3100/01 + $00D8` ← `$FF` |
| 8 | `func_03C5FF` | OAM sort |
| 9 | `func_02AC2E` ×2 | BG scroll ×2 |
| 10 | `func_03E146` | HDMA update |
| 11 | `func_03D1C2` | Map tile helper |
| 12 | `func_03C714` | Finalize sprites |
| 13 | `func_028191` | End frame |
| 14 | `PLB` / `PLP` | Restore; `RTL` |

#### Variables

| Address | Size | Role |
|---------|------|------|
| `$00D8` | 2 | OAM write offset |
| `$7F3100` / `$7F3101` | 2 | OAM sentinel |
| `$06FA` | 2 | Music handshake — gate in `NmiHandler` |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | `NmiHandler` | When `$06FA ≠ 0` |
| Related | [`nmi-handler.md`](nmi-handler.md) | Step 16 of NMI flow |
| Cataloged in | `us/names.json` @ 33212 | |

---

### UpdateHUD

| Property | Value |
|----------|-------|
| **Old Name** | `func_008206` |
| **New Name** | `UpdateHUD` |
| **Hex Address** | `$008206` |
| **Decimal Address** | 33286 |
| **Size** | 216 bytes |
| **ASM File** | `extracted/system/system_core.asm` |

#### Description

Updates the **BG3 status bar overlay** showing HP, DEF, STR, gem count, and experience text. Runs once per main-loop frame (step 20) and from `UpdateFrame_Render`. Early exit if `$09ED` bit `$40` is set (HUD globally disabled — e.g. title screen, some cutscenes).

Handles three distinct visual behaviors:

1. **Damage flash** — when `$0B22 ≠ 0`, every 8 frames (`$0036` AND `$07`) animates DEF display `$0ACE` toward max `$0ACA` and plays sound effect via inline COP `PlaySoundCh2 #0D`.
2. **Stat change detection** — compares live stats against cached previous values; triggers BG3 script refresh when DEF/HP/gems change.
3. **Experience popup** — when `$09EA ≠ 0`, starts `$0AE4` countdown (`$001E` frames) and runs COP `RunBg3Script` referencing `asciistring_01E7F6` / `asciistring_01E818`.

Gem hundreds digit: `$0AD8 = $0AD6 / 100` for three-digit display.

#### Algorithm

| Step | Action | Detail |
|------|--------|--------|
| 1 | Gate | If `$09ED` & `$40` → `RTL` (HUD disabled) |
| 2 | Save flags | `PHP`/`PHA` — preserve `$09EC` bit 0 |
| 3 | Damage flash | If `$0B22 ≠ 0` and frame mod 8: inc `$0ACE`, cap at `$0ACA`, COP sound `#0D` |
| 4 | Compare stats | `$0ACE` vs `$0AD0`, HP vs `$0ACC`, gems `$0AD6` vs `$0ADA` |
| 5 | Gem hundreds | `$0AD8 ← $0AD6 / 100` |
| 6 | XP timer | If `$09EA`: set `$0AE4 = $001E`; COP `RunBg3Script` for XP strings |
| 7 | XP countdown | If `$0AE4 > 0`: decrement; at 0 clear XP display |
| 8 | Refresh flag | Set `$09EC` bit `$10` if any stat display changed |
| 9 | Cache update | Copy current stats → `$0AD0`/`$0ACC`/`$0ADA` |
| 10 | Restore | Merge saved `$09EC` bit 0; `PLA`/`PLP`; `RTL` |

#### Variables

| Address | Size | Name / Role | R/W |
|---------|------|-------------|-----|
| `$0036` | 2 | Frame counter (parity) | R — flash timing |
| `$09AF` | 2 | HUD state helper | R |
| `$09E4` / `$09E6` | 4 | Experience values | R |
| `$09EA` | 2 | Experience pending flag | R |
| `$09EC` | 2 | Display mode flags | R/W — bit `$10` refresh, bit 0 saved |
| `$09ED` | 1 | HUD disable (bit `$40`) | R |
| `$0ACA` / `$0ACE` | 4 | Max / current DEF display | R/W |
| `$0ACC` / `$0AD0` | 4 | Cached previous HP / DEF | R/W |
| `$0AD6` / `$0AD8` | 4 | Gem count / hundreds digit | R/W |
| `$0ADA` | 2 | Cached previous gems | R/W |
| `$0AE4` | 2 | XP display timer | R/W |
| `$0B22` | 2 | Damage flash timer | R |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | `SystemInit` main loop step 20 | Every normal frame |
| Called by | `UpdateFrame_Render` | Overlay frames |
| Inline COP | `PlaySoundCh2 #0D` | Damage tick sound |
| Inline COP | `RunBg3Script` | `asciistring_01E7F6`, `asciistring_01E818` |
| Data | `system_strings` include | HUD ASCII templates |
| Cataloged in | `us/names.json` @ 33286 | |

---

### UpdateFrameCounters

| Property | Value |
|----------|-------|
| **Old Name** | `sub_0082DE` |
| **New Name** | `UpdateFrameCounters` |
| **Hex Address** | `$0082DE` |
| **Decimal Address** | 33502 |
| **Size** | 26 bytes |
| **ASM File** | `extracted/system/system_core.asm` |

#### Description

Tiny per-frame timer maintenance called from main loop step 7. Decrements the **invincibility timer** after hit blinking (stops at `$FFFF`, i.e. −1 as signed word) and increments the **global frame timer** used by various gameplay scripts (caps at `$0100` then stops incrementing).

Preserves and restores processor flags with `PHP`/`PLP` so caller flag state is unchanged.

#### Algorithm

| Step | Instruction pattern | Effect |
|------|---------------------|--------|
| 1 | `PHP` | Save P register |
| 2 | Load `$040C` | Invincibility frame counter |
| 3 | If ≥ 0: decrement | Stop at `$FFFF` (−1) — timer inactive |
| 4 | Load `$040E` | Global frame timer |
| 5 | If < `$0100`: increment | Saturating counter |
| 6 | `PLP` / `RTS` | Return |

#### Variables

| Address | Size | Name | Behavior |
|---------|------|------|----------|
| `$040C` | 2 | Invincibility timer | Decrements each frame; `$FFFF` = inactive |
| `$040E` | 2 | Global frame timer | Increments to `$0100` max |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | `SystemInit` main loop step 7 | JSR each frame |
| Not called by | Frame update variants | Dialogue/render/full omit this |
| Cataloged in | `us/names.json` @ 33502 | |

---

## System Core — Global Variables Summary

| Address | Size | Name | Primary Functions |
|---------|------|------|-------------------|
| `$0036` | 2 | Frame parity counter | `UpdateHUD`, NMI |
| `$00D8` | 2 | OAM write offset | Main loop, frame updates |
| `$040C` | 2 | Invincibility timer | `UpdateFrameCounters` |
| `$040E` | 2 | Global frame timer | `UpdateFrameCounters` |
| `$0654` | 2 | World-ready flag | `SystemInit` |
| `$scene_next` | 2 | Next scene ID | `SystemInit`, transitions |
| `$09BA`–`$09C4` | — | HUD pointer table | `SystemInit` |
| `$09EC` | 2 | Display mode flags | HUD, dialogue frame |
| `$09ED` | 1 | HUD disable flag | `UpdateHUD` |
| `$0ACA`–`$0ADE` | — | Stat display values | `SystemInit`, `UpdateHUD` |
| `$0B22`–`$0B32` | — | Damage/save metadata | `UpdateHUD`, init |

---

## External Call Dependency Summary

| Function | Bank | Called From |
|----------|------|-------------|
| `func_028043` | `$02` | Main loop, all frame updates |
| `func_028191` | `$02` | Main loop, all frame updates |
| `func_0281A2` | `$02` | Main loop, all frame updates |
| `func_029F31` | `$02` | `SystemInit` only |
| `func_029E44` | `$02` | `SystemInit` only |
| `func_02908E` | `$02` | `SystemInit` only |
| `func_0281BC` | `$02` | `SystemInit` only |
| `func_02A5DD` | `$02` | Main loop only |
| `func_02AC2E` | `$02` | Main loop, dialogue, full |
| `func_03D12D` | `$03` | Main loop only |
| `func_03D9E8` / `func_03D9F6` | `$03` | Main loop / init |
| `func_038000` | `$03` | Main loop only |
| `run_actors_03CAF5` | `$03` | Main loop only |
| `func_03C5FF` | `$03` | Main loop, all frame updates |
| `func_03BBE4` / `code_03C25E` / `func_03BBB4` / `func_03BB85` | `$03` | Main loop only |
| `func_03E146` | `$03` | Main loop, all frame updates |
| `func_03D15D` / `func_03D1C2` / `func_03D18D` | `$03` | Map/scroll (various paths) |
| `func_03C714` | `$03` | Main loop, all frame updates |
| `func_03E21E` | `$03` | Main loop only |

---

*Source: analysis of `extracted/system/system_core.asm`, `us/names.json`, `us/blocks.json`. Names cataloged 2026-09-06.*
