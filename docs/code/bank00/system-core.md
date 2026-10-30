# Bank $00 — System Core: Reset, Init, Main Loop & Frame Updates

**Bank:** `$00` (mirrored at `$80` for FastROM access)  
**Address range:** `$008000`–`$0082DE`  
**ASM file:** [`extracted/system/engine/system_core.asm`](../../../extracted/system/engine/system_core.asm)

This page documents the CPU entry point, interrupt vector trampolines, one-time system initialization, the eternal main game loop, and the alternate per-frame update paths used during dialogue, text overlays, and music transitions. Together these routines form the backbone of Illusion of Gaia's runtime: everything else (actors, scenes, rendering) is invoked from here.

**Related:** [`nmi-handler.md`](nmi-handler.md) covers the VBlank handler at `$0082F8`–`$00843F`. [`cop-dispatch.md`](cop-dispatch.md) covers the COP dispatch engine.

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
                            └── EnableNmiAndJoypad → wait for NMI (VBlank)
                                    └── NmiHandler ($82F8) — see nmi-handler.md

Alternate frame paths (called from dialogue/text/music code):
    UpdateFrameDialogue ($811E)   — cutscenes / dialogue
    UpdateFrameRender   ($817D)   — text overlay only
    UpdateFrameFull     ($81BC)   — run by the NMI while the main loop is blocked in the SPC music upload
```

---

## Interrupt Vectors & Reset

### ResetVector

**Address:** `$8000` · **Size:** 7 bytes

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

---

### CopVector

**Address:** `$8007` · **Size:** 4 bytes

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
| Calls | `CopDispatch` (`$00846D`) | 24-byte dispatch engine; see `docs/cop/README.md` |

---

### NmiVector

**Address:** `$800B` · **Size:** 4 bytes

#### Description

NMI (Non-Maskable Interrupt) hardware vector, fired once per frame during vertical blank. The main game loop (`SystemInit` @ `$0080B5`) blocks in `EnableNmiAndJoypad` (end frame / wait VBlank); when NMI fires, control enters `NmiHandler` via this trampoline. All PPU register writes and DMA occur inside the handler, not in the main loop.

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

---

### IrqVector

**Address:** `$800F` · **Size:** 4 bytes

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

---

### IrqHandler

**Address:** `$8013` · **Size:** 1 byte

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

---

## SystemInit & Main Loop

### SystemInit

**Address:** `$8014` · **Size:** 266 bytes (init ~161 B @ `$8014`–`$80B4`, main loop ~105 B @ `$80B5`–`$811D`)

#### Description

Central system entry after reset. Performs complete hardware and game-state initialization once, then enters an infinite main loop that drives one logical frame per iteration. The loop is **not** interrupt-driven for game logic — it runs on the main thread and synchronizes to VBlank via `EnableNmiAndJoypad` at the end of each iteration. NMI handles PPU/DMA separately (see [`nmi-handler.md`](nmi-handler.md)).

The init phase configures the 65816 (16-bit A/X, DP=`$0000`, SP=`$01FF`, DBR=`$81`), writes `MEMSEL = 1` (live only until the register table's last row writes `MEMSEL = 0`; the real FastROM enable is `BootLogoInit` at frame 84), initializes the PPU registers, clears WRAM, uploads the SPC engine, reads the `$0100` byte (no effect), runs a first `ExecuteSceneTransition` with `scene_next = 0` (no scene selected; it only sets up the engine), seeds HUD/stat pointers, and queues the boot-logo scene (`$scene_next = $FB`).

The main loop at **`MainLoop`** executes 22 ordered steps every frame: frame begin, scene transitions, map/scroll, scene load, palette animation, scene logic, frame counters, actor scripts, OAM composition, full collision pipeline, position integration, BG scroll, HDMA, map tiles, sprites, HUD, deferred DMA, and frame end.

#### Initialization Algorithm

| Step | Call / Action | Effect |
|------|---------------|--------|
| 1 | `CLD` | Decimal mode off |
| 2 | `REP #$30` | 16-bit accumulator and index registers |
| 3 | `LDA #$0000` / `TCD` | Direct page register = `$0000` |
| 4 | `LDA #$01FF` / `TCS` | Stack pointer = `$01FF` |
| 5 | `LDA #$81` / `PHA` / `PLB` | Data bank register (DBR) = `$81` for WRAM `$0000`–`$7FFF` |
| 6 | `LDA #$01` / `STA $MEMSEL` | `MEMSEL = 1`: FastROM timing for the register loop only. The last row of `PpuRegisterInitTable` writes `MEMSEL = 0` again (frame 0), so the boot stays SlowROM until `BootLogoInit` (frame 84) |
| 7 | `JSL InitHardwareRegisters` | Initialize PPU control registers from the 76-row table (bank `$02`); `NMITIMEN = 0` row, `MEMSEL = 0` row |
| 8 | `JSL InitSystemVariables` | Clear WRAM (three DMA zero fills; the stack page `$0100`-`$01FF` is skipped, so `$0A02` flag bits are cleared but `$0100` is not) and write the init constant table |
| 9 | `JSL SpcLoadBuiltinEngine` | Upload the SPC engine (video frames 3-7 after reset, ~1.59 M master clocks, same duration under FastROM timing: it waits on the SPC port handshake) |
| 10 | `JSL EnterForcedBlank` | `INIDISP = $80` |
| 11 | `$0100` check | Read `$000100` and compare with `$83`; both outcomes leave `Y = 0`, so `scene_next = 0` for the first `ExecuteSceneTransition` either way. **No effect** (measured with `$83`, `$00`, `$5A`, 150 and random power-on values: identical frames and clocks). Not a save marker; see [`wram-memory-map.md` §2.2](../../wram-memory-map.md#22-sram-region-010001ff) |
| 12 | `JSL ExecuteSceneTransition` | Load initial scene data |
| 13 | HUD pointer init | Copy addresses from `slope_curve_table` (slope curve/HUD pointer region) into `$09BA`–`$09C4` |
| 14 | Stat display init | Seed HP/STR/DEF counters at `$0ACA`–`$0ADE` (playerMaxHp=8, playerHp=8, playerStr=1, playerDef=0) |
| 15 | Boot logos | `STA $scene_next` with `$FB` — queue the boot-logo scene (`sFB_boot_logo`; it queues the title `$FC` itself) |

#### Boot timeline (measured, cold power-on, Mesen2 C3)

Frame 0 is the first instruction after the reset vector; frames are video frames. Two cold boots were frame-identical; soft resets (WRAM kept) are identical too, except that the register-init and WRAM-clear steps run on the old contents.

| Frame | Event | Notes |
|------:|-------|-------|
| 0 | `ResetVector`, `SystemInit`, `MEMSEL = 1`, register loop (`NMITIMEN = 0`, `MEMSEL = 0`), WRAM clear | `$0A02` (event flag bits `$10`-`$17`) cleared; `$0100` not written |
| 3 | `SpcLoadBuiltinEngine` | first APUIO write; NMITIMEN `$01` from here (writes `$00` -> `$01`) |
| 3-7 | SPC engine upload | 6,045 APUIO writes, SlowROM |
| 7 | `$0100` read, first `ExecuteSceneTransition` with `scene_next = 0` | |
| 26 | `AfterSceneTransition`; `INIDISP = $00` for one frame; `scene_next = $FB`; first `EnableNmiAndJoypad` (`$81`) | |
| 27 | `sceneCurrent = $FB`; first `NmiHandler`; second `ExecuteSceneTransition` | |
| 59-65 | scene `$FB` music upload (`SpcBlockTransfer`) | SlowROM |
| 84 | `BootLogoInit` writes `MEMSEL = 1` | FastROM on from here; 81 frames after the first APUIO write |
| 85-100 | first logo (Nintendo, "PRESENTS") fades in | |
| 203 | event flag `$10` set (`$0A02` 0 -> 1), scene `$FB` reloaded | |
| 223 | `BootLogoInit` again (second visit), second logo (ENIX, "AN ... PRODUCTION") | |
| 343 | flag `$10` cleared, `scene_next = $FC` | |
| 360 | `sceneCurrent = $FC` (title) | |

Notes: Mesen2 fills WRAM with random power-on values (the boot is identical anyway); FastROM from reset would save only 4 of the 84 frames, all in the first scene loads; a reset keeps WRAM but the boot clears `$0A02`, so the Nintendo logo always plays first (event flag `$10` logic in [`bank0B-late-bosses-system-cutscene-actors.md`](../bank0B-late-bosses-system-cutscene-actors.md)).

#### Main Loop Algorithm (`MainLoop`)

| Step | Call | Bank | Purpose |
|------|------|------|---------|
| 1 | `VBlankWaitAndJoypad` | `$02` | **Begin frame** — reset per-frame rendering state |
| 2 | `DisableNmiKeepJoypad` | `$02` | **NMI off, auto-joypad on** — run main-thread logic without NMI preemption |
| 3 | `RunThinkers_General` | `$03` | **Map/scroll state** — update camera and map bookkeeping |
| 4 | `CheckSceneTransition` | `$03` | **Scene loading** — async scene data fetch |
| 5 | `CheckWarpAndChest` | `$02` | **Palette animation** — step ambient color cycles |
| 6 | `GlobalInputHandler` | `$03` | **Scene logic** — per-scene thinker/hook entry |
| 7 | `UpdateFrameCounters` | `$00` | Decrement run-window timer; increment frame timer |
| 8 | `RunActors_Normal` | `$03` | **Run actors** — execute all actor COP scripts |
| 9 | OAM sentinel | — | Write `$FF` to `$7F3100+$00D8` and `$7F3101+$00D8` (end-of-sprite marker) |
| 10 | `SortActorsByDepth` | `$03` | **OAM sort/compose** — build sprite table for NMI upload |
| 11 | `RunCombatCollision` | `$03` | **Collision responses** — run hit/damage handlers |
| 12 | `RunInteractionCollision` | `$03` | **Collision detect** — pairwise actor overlap tests |
| 13 | `CheckPlayerDeath` | `$03` | **Finalize collision** — commit collision results |
| 14 | `ProcessDodgeCallbacks` | `$03` | **Update positions** — integrate velocity into `$14`/`$16` |
| 15 | `CameraSmoothScroll` (X=0) | `$02` | **BG scroll layer 0** — compute BG1 scroll |
| 16 | `CameraSmoothScroll` (X=2) | `$02` | **BG scroll layer 1** — compute BG2 scroll |
| 17 | `ResetHdmaState` | `$03` | **HDMA update** — rebuild HDMA channel table → `$66` |
| 18 | `RunThinkers_Hdma` | `$03` | **Map tile updates** — queue metatile VRAM writes |
| 19 | `ComposeAllSprites` | `$03` | **Finalize sprites** — last-minute OAM adjustments |
| 20 | `UpdateHUD` | `$00` | **HUD update** — BG3 status bar (HP/DEF/STR/gems/enemy HP) |
| 21 | `LoadMusicFromTransitionState` | `$03` | **Deferred DMA** — flush queued non-VBlank DMA |
| 22 | `EnableNmiAndJoypad` | `$02` | **End frame** — wait for VBlank/NMI |
| — | `BRL MainLoop` | — | Loop forever |

#### Variables

| Address | Size | Name / Role | Access |
|---------|------|-------------|--------|
| `$000100` | 1 | "SRAM magic byte" (misnomer) | Read once per boot, no effect (see step 11) |
| `$00D8` | 2 | OAM write offset | R/W — index into `$7F3100` OAM buffer |
| `$7F3100`+ | 2 | OAM sentinel slot | Write — `$FF` marks end of sprite list |
| `$scene_next` | 2 | Next scene ID | Write — set to `$FB` for title |
| `$0654` | 2 | World-ready flag | Init — gates dialogue when ≠ `$000F` |
| `$099F` | 2 | Scene/state helper | Init |
| `$09BA`–`$09C4` | 11 | HUD slope/pointer table | Write — from `slope_curve_table` |
| `$09C8` / `$09CA` | 4 | HUD related pointers | Init |
| `$0ACA` / `$0ACE` | 4 | Player max HP / current HP | Init / HUD |
| `$0ADE` / `$0ADC` | 4 | Player STR / DEF stat values | Init / HUD |
| `$0B28`–`$0B33` | 12 | `hieroglyphSlots`: six hieroglyph plate slots (words, `$FFFF` = empty) | `SystemInit` clears them |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | `ResetVector` | Only entry from reset |
| Calls | 17 external JSL targets | Banks `$02` and `$03`; see main loop table |
| Calls | `UpdateFrameCounters`, `UpdateHUD` | Same-bank JSR |
| Related | `UpdateFrameDialogue`, `UpdateFrameRender`, `UpdateFrameFull` | Abbreviated loops for special modes |

---

## Frame Update Functions

These three routines provide **subset main loops** for modes that must advance the display without running the full simulation (collision, map updates, scene logic). All three save full CPU context before touching game state and restore it on return.

**Common context-save prologue:** `PHB`, `PHA`, `XBA`, `PHA`, `PHX`, `PHY`, `PHD` → set `D=$0000`, `DBR=$81` → … → reverse on exit.

---

### UpdateFrameDialogue

**Address:** `$811E` · **Size:** 95 bytes

#### Description

Abbreviated frame update for **dialogue boxes and cutscenes**. Keeps the world visible and animated (sprites, scroll, HDMA, map tile refresh) but **skips** collision detection, actor COP execution, scene logic, palette animation, and the full collision response pipeline. Used when the text engine needs to pump frames while blocking player control.

Clears `$09EC` bit `$08` (the player-tile DMA request, `TRB #$08` at `UpdateFrameDialogue`+68, just before the final `EnableNmiAndJoypad`; not a "dialogue display" flag: the dialogue-mode bit is bit 13, set and cleared by the COP handlers) so the NMI takes the normal VRAM path for the next frame. Writes the OAM sentinel at `$7F3100+$00D8` like the main loop.

#### Algorithm

| Step | Call | Purpose |
|------|------|---------|
| 1 | Save context | `PHB/PHA/XBA/PHA/PHX/PHY/PHD`; `D=$0000`, `DBR=$81` |
| 2 | *(order in the asm differs: the `TRB #$08` of `$09EC` sits at +68, after step 12)* | see description |
| 3 | `VBlankWaitAndJoypad` | Begin frame |
| 4 | `DisableNmiKeepJoypad` | NMI off during cutscene frame pump (same joypad/NMI contract as main loop) |
| 5 | `RunThinkers_General_Light` | Map/scroll helper (lightweight vs `RunThinkers_General`) |
| 6 | `RunActors_CutsceneOnly` | Dialogue-specific sprite prep. **NMITIMEN is `$01` here in 2,696 of 2,712 passes; in the first pass after a scene load (16 of 19 loads) it is `$81` with the NMI on**, because `ExecuteSceneTransition` ends with `EnableNmiAndJoypad` ([measured](../bank02/hardware-and-init.md#nmitimen-state-by-caller-measured)) |
| 7 | OAM sentinel | `$7F3100/01 + $00D8` ← `$FF` |
| 8 | `SortActorsByDepth` | OAM sort/compose |
| 9 | `CameraSmoothScroll` ×2 | BG scroll (layers 0 and 2) |
| 10 | `ResetHdmaState` | HDMA channel update |
| 11 | `RunThinkers_Hdma_Light` | Map tile refresh (subset of `RunThinkers_Hdma`) |
| 12 | `ComposeAllSprites` | Finalize sprites |
| 13 | `EnableNmiAndJoypad` | End frame / wait VBlank |
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
| Calls | 10 external JSL + context save | No collision or `RunActors_Normal` |

---

### UpdateFrameRender

**Address:** `$817D` · **Size:** 63 bytes

#### Description

**Lightest** frame pump — used for **text rendering overlays** where even map tile updates are unnecessary. Runs sprite sort, HDMA, scroll finalization, HUD, and frame begin/end only. Same full context save as `UpdateFrameDialogue`.

#### Algorithm

| Step | Call | Purpose |
|------|------|---------|
| 1 | Save context | Full `PHB`…`PHD` prologue; `D=$0000`, `DBR=$81` |
| 2 | `VBlankWaitAndJoypad` | Begin frame |
| 3 | `DisableNmiKeepJoypad` | NMI off during overlay frame pump |
| 4 | `RunThinkers_General_Light` | Minimal scroll finalize |
| 5 | `SortActorsByDepth` | OAM sort/compose |
| 6 | `ResetHdmaState` | HDMA update |
| 7 | `RunThinkers_Hdma_Light` | Scroll/layer finalize |
| 8 | `ComposeAllSprites` | Finalize sprites |
| 9 | `UpdateHUD` | Status bar (may still show during some overlays) |
| 10 | `EnableNmiAndJoypad` | End frame / wait VBlank |
| 11 | Restore context | `RTL` |

#### Variables

| Address | Size | Role |
|---------|------|------|
| `$00D8` | 2 | OAM offset (if sentinel written by caller) |
| `$09EC` | 2 | Inherited display flags |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | BG3 text overlay paths | Lighter than `UpdateFrameDialogue` |
| Calls | `UpdateHUD` | Same-bank JSR |

---

### UpdateFrameFull

**Address:** `$81BC` · **Size:** 74 bytes

#### Description

Single-frame update that `NmiHandler` calls while `musicTransitionState` (`$06FA`) is **positive** (neither 0 nor `$FFFF`), i.e. while the main loop is inside `LoadMusicFromTransitionState` → `SpcBlockTransfer`, the blocking SPC music upload, with NMI enabled. It keeps the screen animating during the upload: the light general thinkers, the overlay-only actor pass (`RunActors_OverlayOnly`), depth sort, camera scroll for both layers, `ResetHdmaState`, the light HDMA-phase thinkers and sprite composition. Uses a lighter save (`PHP`, `PHB`) because it runs inside the NMI stack frame.

Does not call `UpdateHUD`, the normal actor pass (`RunActors_Normal`) or the rest of the main loop.

#### Algorithm

| Step | Call | Purpose |
|------|------|---------|
| 1 | `PHP` / `PHB` | Save flags and data bank |
| 2 | Set `DBR=$81` | WRAM data bank |
| 3 | `DisableNmiKeepJoypad` | NMITIMEN `$01` (NMI off) while the overlay pass runs inside the NMI. Measured: 119 of 119 entries saw `$81` before this call and `$01` after it; the old comment "Enable NMI for partial V-Blank" on this call was wrong (the matching enable is step 13) |
| 4 | `VBlankPartial` | Frame begin variant (NMI-safe) |
| 5 | `RunThinkers_General_Light` | Scroll finalize |
| 6 | `RunActors_OverlayOnly` | Actor update pass (subset of full actor run) |
| 7 | OAM sentinel | `$7F3100/01 + $00D8` ← `$FF` |
| 8 | `SortActorsByDepth` | OAM sort |
| 9 | `CameraSmoothScroll` ×2 | BG scroll ×2 |
| 10 | `ResetHdmaState` | HDMA update |
| 11 | `RunThinkers_Hdma_Light` | Map tile helper |
| 12 | `ComposeAllSprites` | Finalize sprites |
| 13 | `EnableNmiAndJoypad` | End frame |
| 14 | `PLB` / `PLP` | Restore; `RTL` |

#### Variables

| Address | Size | Role |
|---------|------|------|
| `$00D8` | 2 | OAM write offset |
| `$7F3100` / `$7F3101` | 2 | OAM sentinel |
| `$06FA` | 2 | `musicTransitionState`: 0 idle, positive = SPC upload in progress (the gate in `NmiHandler`), `$FFFF` = finished |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | `NmiHandler` | When `$06FA` is positive |
| Related | [`nmi-handler.md`](nmi-handler.md) | Step 16 of NMI flow |

---

### UpdateHUD

**Address:** `$8206` · **Size:** 216 bytes

#### Description

Updates the **BG3 status bar overlay** showing HP, DEF, STR, gem count, and enemy health bar. Runs once per main-loop frame (step 20) and from `UpdateFrameRender`. Early exit if `$09ED` bit `$40` is set (HUD globally disabled — e.g. title screen, some cutscenes).

**Measured (Mesen2 C4):** `UpdateHUD` is entered every frame and leaves at the bit test (idle diary scene: 300 of 300 entries). While `displayModeFlags` bit 14 (`$4000`) is set nothing is redrawn: with HP and gems changed in South Cape the HUD stayed stale (5 full pips, gems 0) and was redrawn through the partial BG3 upload (`displayModeFlags` bit 4) in the next frames after the bit was cleared; in scene `$FA` (diary) the HUD never appears while the bit is set. The bit is set by the title / diary / boot-logo / credits scripts and by `OpenInventoryScreen` (which the scene display command clears two frames later); `LoadHudTilemap` has the same gate. Bit 4 is requested only here (three sites, two observed). Bit layout: [Display Mode Flags Reference](../../wram-memory-map.md#display-mode-flags-reference-09ec).

Handles three distinct visual behaviors:

1. **HP recovery** — when `hpToHeal` (`$0B22`) is nonzero, the frame counter (`$0036`) is a multiple of 8 and `playerStateByte` bit 1 (game over) is clear: decrements `hpToHeal`, then either clears it (when `playerHp` `$0ACE` already equals `playerMaxHp` `$0ACA`) or increments `playerHp` by 1 and plays sound `#0D` via inline COP `PlaySoundCh2`.
2. **Stat change detection** — compares HP, max HP and gem count against the cached previous values; triggers BG3 script refresh when any of them changes.
3. **Experience popup** — when `$09EA ≠ 0`, starts `$0AE4` countdown (`$001E` frames) and runs COP `RunBg3Script` referencing `consolestring_01E7F6` / `consolestring_01E818`.

Gem hundreds digit: `$0AD8 = $0AD6 / 100` for three-digit display.

#### Algorithm

| Step | Action | Detail |
|------|--------|--------|
| 1 | Gate | If `$09ED` & `$40` → `RTL` (HUD disabled) |
| 2 | Save flags | `PHP`/`PHA` — preserve `$09EC` bit 0 |
| 3 | HP recovery | Skipped if `playerStateByte` bit 1 is set, the frame counter is not a multiple of 8, or `hpToHeal` (`$0B22`) is 0. Otherwise `hpToHeal` − 1; if `playerHp` (`$0ACE`) = `playerMaxHp` (`$0ACA`): `hpToHeal` := 0; else `playerHp` + 1 and COP sound `#0D` |
| 4 | Compare stats | playerHp (`$0ACE`) vs `$0AD0`, maxHP (`$0ACA`) vs `$0ACC`, gems `$0AD6` vs `$0ADA` |
| 5 | Gem hundreds | `$0AD8 ← $0AD6 / 100` |
| 6 | Enemy health | If `$09EA`: set `$0AE4 = $001E`; COP `RunBg3Script` for enemy HP bar |
| 7 | Health countdown | If `$0AE4 > 0`: decrement; at 0 clear enemy health display |
| 8 | Refresh flag | Set `$09EC` bit `$10` if any stat display changed |
| 9 | Cache update | Copy current stats → `$0AD0`/`$0ACC`/`$0ADA` |
| 10 | Restore | Merge saved `$09EC` bit 0; `PLA`/`PLP`; `RTL` |

#### Variables

| Address | Size | Name / Role | R/W |
|---------|------|-------------|-----|
| `$0036` | 2 | Frame counter (parity) | R — HP recovery step every 8 frames |
| `$09AF` | 2 | HUD state helper | R |
| `$09E4` / `$09E6` | 4 | Enemy HP display values | R |
| `$09EA` | 2 | Enemy HP pending flag | R |
| `$09EC` | 2 | Display mode flags | R/W — bit `$10` refresh, bit 0 saved |
| `$09ED` | 1 | HUD disable (bit `$40`) | R |
| `$0ACA` / `$0ACE` | 4 | Player max HP / current HP | R/W |
| `$0ACC` / `$0AD0` | 4 | Cached previous max HP / HP | R/W |
| `$0AD6` / `$0AD8` | 4 | Gem count / hundreds digit | R/W |
| `$0ADA` | 2 | Cached previous gems | R/W |
| `$0AE4` | 2 | Enemy health bar timer | R/W |
| `$0B22` | 2 | `hpToHeal`: HP recovery counter (`UpdateHUD` reads and writes only the low byte) | R/W |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | `SystemInit` main loop step 20 | Every normal frame |
| Called by | `UpdateFrameRender` | Overlay frames |
| Inline COP | `PlaySoundCh2 #0D` | HP recovery tick sound |
| Inline COP | `RunBg3Script` | `consolestring_01E7F6`, `consolestring_01E818` |
| Data | `system_strings` include | HUD Console templates |

---

### UpdateFrameCounters

**Address:** `$82DE` · **Size:** 26 bytes

#### Description

Tiny per-frame timer maintenance called from main loop step 7. Decrements **`$040C` run-window timer** (13-frame D-pad run allowance; stops at `$FFFF` = closed) and increments the **global frame timer** used by various gameplay scripts (caps at `$0100` then stops incrementing). Hit-blink iframes use actor field `$7F0028`, not `$040C`.

Preserves and restores processor flags with `PHP`/`PLP` so caller flag state is unchanged.

#### Algorithm

| Step | Instruction pattern | Effect |
|------|---------------------|--------|
| 1 | `PHP` | Save P register |
| 2 | Load `$040C` | Run-window timer |
| 3 | If ≥ 0: decrement | Stop at `$FFFF` (−1) — window closed |
| 4 | Load `$040E` | Global frame timer |
| 5 | If < `$0100`: increment | Saturating counter |
| 6 | `PLP` / `RTS` | Return |

#### Variables

| Address | Size | Name | Behavior |
|---------|------|------|----------|
| `$040C` | 2 | Run-window timer | Decrements each frame; `$FFFF` = closed |
| `$040E` | 2 | Global frame timer | Increments to `$0100` max |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | `SystemInit` main loop step 7 | JSR each frame |
| Not called by | Frame update variants | Dialogue/render/full omit this |

---

## System Core — Global Variables Summary

| Address | Size | Name | Primary Functions |
|---------|------|------|-------------------|
| `$0036` | 2 | Frame parity counter | `UpdateHUD`, NMI |
| `$00D8` | 2 | OAM write offset | Main loop, frame updates |
| `$040C` | 2 | Run-window timer | `UpdateFrameCounters` |
| `$040E` | 2 | Global frame timer | `UpdateFrameCounters` |
| `$0654` | 2 | World-ready flag | `SystemInit` |
| `$scene_next` | 2 | Next scene ID | `SystemInit`, transitions |
| `$09BA`–`$09C4` | — | HUD pointer table | `SystemInit` |
| `$09EC` | 2 | Display mode flags | HUD, dialogue frame |
| `$09ED` | 1 | HUD disable flag | `UpdateHUD` |
| `$0ACA`–`$0ADE` | — | Stat display values | `SystemInit`, `UpdateHUD` |
| `$0B22` | 2 | `hpToHeal`: HP recovery counter | `UpdateHUD` (reader), item and reward actors (writers) |
| `$0B28`–`$0B33` | 12 | `hieroglyphSlots`: six hieroglyph plate slots (words, `$FFFF` = empty) | `SystemInit` (clears), `pyCD_puzzle`, `item_use_system` (plate placement); inside the saved WRAM range `$0A00`–`$0BFB` |

---

## External Call Dependency Summary

| Function | Bank | Called From |
|----------|------|-------------|
| `VBlankWaitAndJoypad` | `$02` | Main loop, all frame updates |
| `EnableNmiAndJoypad` | `$02` | Main loop, all frame updates |
| `DisableNmiKeepJoypad` | `$02` | Main loop, all frame updates |
| `InitHardwareRegisters` | `$02` | `SystemInit` only |
| `InitSystemVariables` | `$02` | `SystemInit` only |
| `SpcLoadBuiltinEngine` | `$02` | `SystemInit` only |
| `EnterForcedBlank` | `$02` | `SystemInit` only |
| `CheckWarpAndChest` | `$02` | Main loop only |
| `CameraSmoothScroll` | `$02` | Main loop, dialogue, full |
| `RunThinkers_General` | `$03` | Main loop only |
| `CheckSceneTransition` / `ExecuteSceneTransition` | `$03` | Main loop / init |
| `GlobalInputHandler` | `$03` | Main loop only |
| `RunActors_Normal` | `$03` | Main loop only |
| `SortActorsByDepth` | `$03` | Main loop, all frame updates |
| `RunCombatCollision` / `RunInteractionCollision` / `CheckPlayerDeath` / `ProcessDodgeCallbacks` | `$03` | Main loop only |
| `ResetHdmaState` | `$03` | Main loop, all frame updates |
| `RunThinkers_Hdma` / `RunThinkers_Hdma_Light` / `RunThinkers_General_Light` | `$03` | Map/scroll (various paths) |
| `ComposeAllSprites` | `$03` | Main loop, all frame updates |
| `LoadMusicFromTransitionState` | `$03` | Main loop only |

---

*Source: [`extracted/system/engine/system_core.asm`](../../../extracted/system/engine/system_core.asm)*
