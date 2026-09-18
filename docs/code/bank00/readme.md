# Bank $00 — Complete Code Analysis Index

**Bank:** `$00` (mirrored at `$80` for FastROM access at 3.58 MHz)  
**Full address range:** `$008000`–`$00F4FF`  
**Total size:** ~29,952 bytes  
**Game:** Illusion of Gaia (US ROM)  
**ASM files:** `extracted/system/`, `extracted/actors/`, `extracted/functions/`, `extracted/thinkers/`, `extracted/unused/`

Bank $00 is the **primary system bank** for Illusion of Gaia. It contains the CPU reset vector, the NMI/VBlank handler, the COP bytecode dispatch engine, the main game loop, and the entire core utility library. The upper half houses thinkers (background processes for palette/HDMA effects), scene infrastructure actors, combat mechanics, NPC AI, and specialized systems like stair climbing and camera scrolling.

> **COP handler documentation** lives in [`cop-commands-reference.md`](../../cop-commands-reference.md) and `db-us/copdef.json`. This index covers the system architecture, utility subroutines, actors, thinkers, and functions.

---

## Table of Contents

1. [Address Map](#1-address-map)
2. [Category Index](#2-category-index)
3. [System Core](#3-system-core) — Reset, Init, Main Loop, Frame Updates
4. [NMI/VBlank Handler](#4-nmivblank-handler) — VBlank, Scroll, DMA
5. [COP Dispatch Engine](#5-cop-dispatch-engine) — Bytecode Dispatch, Tables
6. [Utility: Math & Movement](#6-utility-math--movement) — Hardware Math, Movement Init
7. [Utility: Tiles & Animation](#7-utility-tiles--animation) — Tile/Map, Animation, Sprites
8. [Direction & Collision](#8-direction--collision) — Direction, Tile Queries, Collision Rects
9. [Event Flag System](#9-event-flag-system) — WRAM + Event Flags
10. [Actor Management](#10-actor-management) — Pool, Linking, Copy, Unlink
11. [Thinkers: Palette](#11-thinkers-palette) — Palette Cycling, One-Shot Flashes
12. [Thinkers: HDMA Effects](#12-thinkers-hdma-effects) — Sine HDMA, Custom DMA
13. [Thinkers: System](#13-thinkers-system) — HW Config, Menu, Boot, Dispatcher
14. [Actors: Infrastructure](#14-actors-infrastructure) — Camera, Scene Flags, Speed Zones
15. [Actors: Player & Rewards](#15-actors-player--rewards) — Transitions, Jewels, Inventory
16. [Actors: Combat & Interaction](#16-actors-combat--interaction) — Knockback, Push, Follow, Effects
17. [Functions: Combat & Defeat](#17-functions-combat--defeat) — Enemy Defeat Pipeline
18. [Functions: Game Over](#18-functions-game-over) — Death Sequence
19. [Functions: Player & NPC](#19-functions-player--npc) — Player State, NPC AI, Escort
20. [Functions: Camera & Motion](#20-functions-camera--motion) — Camera Drift, Orbital Math
21. [Stair & Climb System](#21-stair--climb-system) — Stair Triggers, Climb Functions
22. [Camera & Scroll System](#22-camera--scroll-system) — Smooth Follow, Pan, Forced Walk
23. [Data Tables & Memory Map](#23-data-tables--memory-map) — Tables, Variables, Stack, Statistics
24. [Statistics](#24-statistics)
25. [Structural Notes](#25-structural-notes)

---

## 1. Address Map

| Range | Size | Content | Document |
|-------|------|---------|----------|
| `$008000`–`$0082DE` | ~734 bytes | Interrupt vectors, system init, main loop, frame updates, HUD | [system-core.md](system-core.md) |
| `$0082F8`–`$00843F` | ~328 bytes | NMI/VBlank handler, scroll upload, VRAM DMA | [nmi-handler.md](nmi-handler.md) |
| `$00846C`–`$00864B` | ~480 bytes | COP dispatch engine, opcode tables, sentinel | [cop-dispatch.md](cop-dispatch.md) |
| `$008650`–`$00B530` | ~12,000 bytes | COP handlers ($00–$6D, $80–$E2) — 172 opcodes | [cop-commands-reference.md](../../cop-commands-reference.md) |
| `$008D25`–`$008FDC` | ~184 bytes | Hardware math helpers, movement initialization | [utility-math-movement.md](utility-math-movement.md) |
| `$0097EF`–`$00AF8F` | ~800 bytes | Tile/map helpers, animation, sprite/body utilities | [utility-tiles-animation.md](utility-tiles-animation.md) |
| `$00AFCE`–`$00B43B` | ~320 bytes | Direction computation, tile collision, collision rects | [direction-collision.md](direction-collision.md) |
| `$00B05E`–`$00B4F6` | ~280 bytes | Event flag system (WRAM + event flags + far-call wrappers) | [event-flags.md](event-flags.md) |
| `$00A608`–`$00B519` | ~400 bytes | Actor allocation, linking, copy state, unlink | [actor-management.md](actor-management.md) |
| `$00B520`–`$00B808` | ~740 bytes | Palette cycling thinkers + one-shot flashes | [thinkers-palette.md](thinkers-palette.md) |
| `$00B87B`–`$00BF52` | ~1,750 bytes | HDMA wave effects + custom DMA thinkers | [thinkers-hdma.md](thinkers-hdma.md) |
| `$00B78F`–`$00BF89` | ~1,200 bytes | System/menu/HW config thinkers + global dispatcher | [thinkers-system.md](thinkers-system.md) |
| `$00C1AA`–`$00EAED` | ~800 bytes | Scene infrastructure actors (camera, flags, speed, ramps) | [actors-infrastructure.md](actors-infrastructure.md) |
| `$00C2BB`–`$00CF29` | ~1,800 bytes | Player transitions, red jewels, inventory actors | [actors-player-rewards.md](actors-player-rewards.md) |
| `$00D877`–`$00E4DB` | ~2,400 bytes | Combat knockback, push handlers, follow, effects | [actors-combat-interaction.md](actors-combat-interaction.md) |
| `$00DB8A`–`$00DFFF` | ~1,150 bytes | Enemy defeat pipeline, VFX, field reveals, dark gem drops | [functions-combat-defeat.md](functions-combat-defeat.md) |
| `$00B5B3`–`$00F3B3` | ~500 bytes | Game over sequence, death messages | [functions-game-over.md](functions-game-over.md) |
| `$00C397`–`$00C98E` | ~600 bytes | Player/party state, NPC AI, escort pathfinding | [functions-player-npc.md](functions-player-npc.md) |
| `$00C9B8`–`$00F432` | ~450 bytes | Camera drift, debris burst, orbital math | [functions-camera-motion.md](functions-camera-motion.md) |
| `$00D088`–`$00D5BC` | ~1,336 bytes | Stair trigger & climb system | [stair-climb-system.md](stair-climb-system.md) |
| `$00E683`–`$00F292` | ~3,376 bytes | Smooth scroll, camera pan, forced walks | [camera-scroll-system.md](camera-scroll-system.md) |

---

## 2. Category Index

| # | Category | Document | Parts | Key Function |
|---|----------|----------|-------|--------------|
| 1 | System Core | [system-core.md](system-core.md) | 11 | `SystemInit`, Main Loop |
| 2 | NMI Handler | [nmi-handler.md](nmi-handler.md) | 5 | `NmiHandler` |
| 3 | COP Dispatch | [cop-dispatch.md](cop-dispatch.md) | 4 | `CopDispatch` |
| 4 | Math & Movement | [utility-math-movement.md](utility-math-movement.md) | 6 | `MultiplyThenDivide`, `InitSmoothMovement` |
| 5 | Tiles & Animation | [utility-tiles-animation.md](utility-tiles-animation.md) | 9 | `ResolveTileData`, `ProcessAnimFlag` |
| 6 | Direction & Collision | [direction-collision.md](direction-collision.md) | 7 | `ComputeDirectionToPlayer`, `TileCollisionQuery` |
| 7 | Event Flags | [event-flags.md](event-flags.md) | 19 | `SetEventFlag`, `TestEventFlag` |
| 8 | Actor Management | [actor-management.md](actor-management.md) | 11 | `ActorPoolAllocator`, `CopyActorState` |
| 9 | Thinkers: Palette | [thinkers-palette.md](thinkers-palette.md) | 20 | `ambient_palette_cycler` |
| 10 | Thinkers: HDMA | [thinkers-hdma.md](thinkers-hdma.md) | 18 | `sine_hdma_slow_wave` |
| 11 | Thinkers: System | [thinkers-system.md](thinkers-system.md) | 11 | `global_ambient_dispatcher` |
| 12 | Actors: Infrastructure | [actors-infrastructure.md](actors-infrastructure.md) | 8 | `camera_scroll_controller` |
| 13 | Actors: Player & Rewards | [actors-player-rewards.md](actors-player-rewards.md) | 10+ | `player_transition_handlers` |
| 14 | Actors: Combat & Interaction | [actors-combat-interaction.md](actors-combat-interaction.md) | 12 | `hit_stagger_controller` |
| 15 | Functions: Combat & Defeat | [functions-combat-defeat.md](functions-combat-defeat.md) | 9+7 | `StandardEnemyDefeatHandler` |
| 16 | Functions: Game Over | [functions-game-over.md](functions-game-over.md) | 5 | `GameOverSequence` |
| 17 | Functions: Player & NPC | [functions-player-npc.md](functions-player-npc.md) | 7 | `NpcRandomWanderAI` |
| 18 | Functions: Camera & Motion | [functions-camera-motion.md](functions-camera-motion.md) | 7 | `ApplyOrbitalOffsetFromRef` |
| 19 | Stair & Climb | [stair-climb-system.md](stair-climb-system.md) | 13 | `StairTriggerWest` |
| 20 | Camera & Scroll | [camera-scroll-system.md](camera-scroll-system.md) | 42 | `ScrollCameraTrack` |
| 21 | Data & Memory | [data-tables-memory.md](data-tables-memory.md) | — | Reference tables |

---

## 3. System Core

**→ [system-core.md](system-core.md)**

Covers `$008000`–`$0082DE`: CPU entry point, interrupt trampolines, system initialization, main game loop (22 steps/frame), and alternate frame update paths.

| Function | Address | Size | Description |
| ---------- | --------- | ------ | ------------- |
| `ResetVector` | `$8000` | 7 B | CPU reset — switch to native 65816 mode, JML SystemInit |
| `CopVector` | `$8007` | 4 B | COP interrupt trampoline → CopDispatch |
| `NmiVector` | `$800B` | 4 B | NMI interrupt trampoline → NmiHandler |
| `IrqVector` | `$800F` | 4 B | IRQ interrupt trampoline → IrqHandler |
| `IrqHandler` | `$8013` | 1 B | IRQ stub — RTI only (game doesn't use IRQ) |
| `SystemInit` | `$8014` | ~266 B | One-time init + eternal main loop at `$80B5` |
| `UpdateFrameDialogue` | `$811E` | ~40 B | Abbreviated frame for dialogue/cutscenes |
| `UpdateFrameRender` | `$817D` | ~30 B | Lightweight frame for text overlays |
| `UpdateFrameFull` | `$81BC` | ~46 B | Full frame with collision (NMI music handshake) |
| `UpdateHUD` | `$8206` | ~216 B | BG3 status bar: HP, DEF, STR, gems, enemy health bar |
| `UpdateFrameCounters` | `$82DE` | 18 B | Decrement invincibility timer, increment frame counter |

---

## 4. NMI/VBlank Handler

**→ [nmi-handler.md](nmi-handler.md)**

Covers `$0082F8`–`$00843F`: VBlank interrupt handler, BG scroll register upload, VRAM DMA execution.

| Function | Address | Size | Description |
| ---------- | --------- | ------ | ------------- |
| `NmiHandler` | `$82F8` | ~144 B | 19-step VBlank: PPU writes, DMA, OAM, CGRAM, input, APU |
| `UploadScrollRegisters` | `$8387` | ~80 B | BG1–BG2 scroll register upload (normal + locked modes) |
| `WriteBgScroll` | `$83D4` | ~46 B | Write H+V scroll for one BG layer with override logic |
| `ExecuteVramDma` | `$8411` | ~26 B | Single VRAM DMA transfer from DP parameters |
| `FillWramBlock` | `$8438` | ~32 B | UNREFERENCED — DMA fill of 512 bytes (debug/cut) |

---

## 5. COP Dispatch Engine

**→ [cop-dispatch.md](cop-dispatch.md)**

Covers `$00846C`–`$00864B`: The central COP bytecode interpreter that drives all actor and thinker scripts.

| Function | Address | Size | Description |
| ---------- | --------- | ------ | ------------- |
| `CopDispatch` | `$846D` | 24 B | Central 24-byte dispatch engine for 172 COP opcodes |
| `cop_dispatch_table` | `$8485` | 220 B | Primary jump table ($00–$6D, 110 entries) |
| *(extended table)* | `$8585` | 198 B | Extended table ($80–$E2, 99 entries) |
| `cop_table_sentinel` | `$864B` | 3 B | Sentinel bytes: `$EA $80 $FD` |

---

## 6. Utility: Math & Movement

**→ [utility-math-movement.md](utility-math-movement.md)**

Covers `$008D25`–`$008FDC`: Hardware multiply/divide wrappers and actor smooth-movement initialization.

| Function | Address | Size | Description |
| ---------- | --------- | ------ | ------------- |
| `ReadMultiplyResult` | `$8D25` | 4 B | NOP delay + read RDMPYL into Y |
| `ReadDivideResult` | `$8D2A` | 8 B | 5× NOP pipeline delay + read RDDIVL |
| `MultiplyThenDivide` | `$8D33` | 24 B | Combined 8×8 multiply → 16/8 divide |
| `InitSmoothMovement` | `$8D4D` | ~90 B | Init actor smooth-movement from script params |
| `HalveMovementDistance` | `$8EF1` | ~16 B | Halve X/Y movement distances via LSR |
| `MovementVelocityCompute` | `$8FDC` | ~24 B | Velocity calculation for COP $53 (TickMove) |

---

## 7. Utility: Tiles & Animation

**→ [utility-tiles-animation.md](utility-tiles-animation.md)**

Covers `$0097EF`–`$00AF8F`: Tile/map parsing, tile data resolution, animation flag processing, sprite body setup, and sine HDMA table builders.

| Function | Address | Size | Description |
| ---------- | --------- | ------ | ------------- |
| `ParseMapEntry` | `$97EF` | ~40 B | Parse 3-byte map entry, sign-extend, scale ×16 |
| `ResolveTileData` | `$9829` | ~128 B | Resolve tile graphics + metadata from parsed coords |
| `TileQueryGate` | `$98A9` | ~16 B | Gate: retry COP if tile query pending ($0902 ≠ 0) |
| `ProcessAnimFlag` | `$9F5F` | ~32 B | Process anim/visibility flag byte (3 modes) |
| `AnimFrameLookup` | `$B157` | 8 B | Animation frame table lookup → duration/speed |
| `BuildSineHdmaTable` | `$ADCF` | ~150 B | Build HDMA displacement from sine table (double-buffered) |
| `BuildSineLookupTable` | `$AEB8` | ~100 B | Precompute 512-byte sine tables at $7E8900/$7E8B00 |
| `SetActorBody` | `$AF6D` | ~24 B | Set actor body/sprite from $0AD4 into body_table |
| `ParseSignedTileOffset` | `$AF8F` | ~40 B | Read signed tile offset bytes, scale, add to position |

---

## 8. Direction & Collision

**→ [direction-collision.md](direction-collision.md)**

Covers `$00AFCE`–`$00B43B` + `$00B29F`–`$00B3EF`: 8-way direction computation, tile collision queries, and collision map rectangle operations.

| Function | Address | Size | Description |
| ---------- | --------- | ------ | ------------- |
| `ComputeDirectionToPlayer` | `$AFCE` | ~144 B | 8-way octant direction (0=N → 7=NW) with Chebyshev distance |
| `TileCollisionQuery` | `$B43B` | ~60 B | Tile property lookup at coords; returns $000F if blocked |
| `MarkCollisionRect` | `$B29F` | ~80 B | ORA $F0 into collision map rectangle under actor |
| `ClearCollisionRect` | `$B345` | ~100 B | AND $0F / full zero collision map rectangle |
| `ClearCollisionRectFull` | `$B3EF` | ~50 B | Full collision byte clear (writes $00) |
| `AdvanceMapY` | `$B32B` | ~16 B | Advance map Y with page wrap using $0693 stride |
| `CameraScrollStepLookup` | `$B136` | ~24 B | Index camera scroll step table at $06E0 |

---

## 9. Event Flag System

**→ [event-flags.md](event-flags.md)**

Covers `$00B05E`–`$00B4F6`: Bitfield-based flag operations for game progress tracking.

### WRAM Flag Array ($0A80 — 32 bytes)

| Function | Address | Description |
| ---------- | --------- | ------------- |
| `SetWramFlag` | `$B074` | ORA $0A80,Y with bitmask |
| `TestWramFlag` | `$B095` | AND $0A80,Y — carry set if bit clear |
| `SetWramFlag_Offset100` | `$B069` | Add $0100 to index → SetWramFlag |
| `TestWramFlag_Offset100` | `$B05E` | Add $0100 to index → TestWramFlag |
| `ClearAllWramFlags` | `$B4CC` | Zero $0A80–$0A9E (16 words) |

### Event Flag Array ($0A00 — 256 bytes)

| Function | Address | Description |
| ---------- | --------- | ------------- |
| `SetEventFlag` | `$B0B7` | ORA $0A00,Y with bitmask |
| `ClearEventFlag` | `$B0D8` | AND $0A00,Y with inverted bitmask |
| `TestEventFlag` | `$B0FB` | AND $0A00,Y — carry set if bit clear |

### Far-Call Flag Wrappers

| Function | Address | Offset | Operation |
| ---------- | --------- | -------- | ----------- |
| `SetEventFlag_0200` | `$B481` | +$0200 | Set |
| `TestEventFlag_0200` | `$B489` | +$0200 | Test |
| `TestFlag_0300` | `$B496` | +$0300 | Test |
| `SetFlag_0300` | `$B4A1` | +$0300 | Set |
| `TestFlag_0510` | `$B4AC` | +$0510 | Test |
| `TestFlagRaw` | `$B4B7` | Direct | Test |
| `SetFlagRaw` | `$B4BE` | Direct | Set |
| `ClearFlagRaw` | `$B4C5` | Direct | Clear |
| `SetFlag_0100` | `$B4E0` | +$0100 | Set |
| `ClearFlag_0100` | `$B4EB` | +$0100 | Clear *(unreferenced)* |
| `TestFlag_0100` | `$B4F6` | +$0100 | Test |

---

## 10. Actor Management

**→ [actor-management.md](actor-management.md)**

Covers `$00A608`–`$00B519`: Actor pool allocation, doubly-linked list management, state copying, unlinking, and thinker allocation.

| Function | Address | Size | Description |
| ---------- | --------- | ------ | ------------- |
| `ActorPoolAllocator` | `$B501` | ~28 B | Read next free actor from pool at ($4E) |
| `AllocateActorBefore` | `$B15D` | ~40 B | Allocate + link as predecessor ($04) |
| `AllocateActorAfter` | `$B189` | ~40 B | Allocate + link as successor ($06) |
| `ReturnActorSlot` | `$B1B5` | ~14 B | Return slot to free pool |
| `MarkChildActor` | `$B1CB` | ~10 B | Store parent DP into child's $7F001C,X |
| `CopyActorState` | `$B1DA` | ~120 B | Full actor state copy (flags, position, anim, body) |
| `UnlinkActor` | `$AF40` | ~40 B | Remove from doubly-linked list + free slot |
| `DieNow_UnlinkChildren` | `$A608` | ~153 B | Walk list unlinking all marked children |
| `AllocateSpecialActor` | `$B27B` | ~24 B | Allocate thinker via ThinkerPoolAlloc ($03) |
| `ResolveActorIndex` | `$B125` | ~14 B | Map 8-bit list index → WRAM actor ID |
| `PaletteResetAndKillThinker` | `$B519` | ~8 B | COP PaletteRestart + PaletteStep + KillThinker |

---

## 11. Thinkers: Palette

**→ [thinkers-palette.md](thinkers-palette.md)**

Covers `$00B520`–`$00B808`: 20 thinkers for ambient palette cycling and one-shot visual flashes.

### Palette Cycling Family

| Thinker | Address | Scene | Description |
| --------- | --------- | ------- | ------------- |
| `ambient_palette_cycler` | `$B520` | Dozens | Generic infinite palette loop from scene table |
| `flag_gated_palette_warm` | `$B5C0` | Oakton | Bundle #02, gated by flags #1C/#16 |
| `flag_gated_palette_cool` | `$B5DF` | Overworld | Bundle #4C, same gate pattern |
| `palette_parent_child` | `$B5FE` | Inventory | Bundle #03, spawns child on flag #01 |
| `edward_castle_alarm_palette` | `$B631` | Edward Castle | Red-alert palette #05 + COLDATA red tint |
| `incan_ruins_transform_palette` | `$B671` | Angkor/Incan | Multi-phase: #1A→#34/#33→#36 |
| `dream_palette_loop` | `$B6D2` | Gold Ship | Dream palette #35 with flag #FF exit |
| `palace_fountain_palette` | `$B71E` | Palace | CGADSUB=#03 + alternating #1A/#25 |
| `watermia_festival_palette` | `$B754` | Watermia | Default #42; child #72 on flag #96 |

### One-Shot Palette Flashes

| Thinker | Address | Bundle | Scene Usage |
| --------- | --------- | -------- | ------------- |
| `oneshot_coldata_warm_flash` | `$B65E` | COLDATA | Incan/Larai |
| `oneshot_coldata_green_tint` | `$B6E5` | COLDATA | Oakton storm |
| `oneshot_palette_flash_18` | `$B7CC` | #18 | Comet/Angkor/Mu |
| `oneshot_palette_flash_19` | `$B7D6` | #19 | (complement of #18) |
| `oneshot_palette_flash_1B` | `$B7E0` | #1B | Mu prayer/Castle |
| `oneshot_palette_flash_1C` | `$B7EA` | #1C | Snake Pit/Gold Ship |
| `oneshot_palette_flash_40` | `$B7F4` | #40 | Angel Tunnel/Palace |
| `oneshot_palette_flash_1F` | `$B7FE` | #1F | Itory Moon Tribe |

### Unused

| Thinker | Address | Reason |
| --------- | --------- | -------- |
| `palette_buffer_clear_unused` | `$B6FD` | No references |
| `babel_palette_65_unused` | `$B781` | Cut Babel Tower effect |
| `palette_loop_flash_unused` | `$B808` | No references |

---

## 12. Thinkers: HDMA Effects

**→ [thinkers-hdma.md](thinkers-hdma.md)**

Covers `$00BCB3`–`$00BF19` + `$00B87B`: 18 thinkers for sine-based HDMA oscillation and custom DMA setup.

### Sine HDMA Wave Effects

| Thinker | Address | Tick | Channel(s) | Scene |
| --------- | --------- | ------ | ------------ | ------- |
| `sine_hdma_slow_wave` | `$BE18` | #01 | #0D | Multiple mid/late |
| `sine_hdma_dual_channel` | `$BE83` | #02 | #0F, #10 | Palace Coffins |
| `sine_hdma_ending_wave` | `$BF19` | — | #0F | Comet/Castoth |
| `ending_comet_sine_hdma` | `$BCB3` | #05 | #0F, #10 | Ending Comet |
| `comet_lair_hdma_a` | `$BCF5` | — | #10 | Comet Lair |
| `comet_lair_hdma_b` | `$BD21` | — | #0F | Comet Lair |
| `comet_lair_hdma_c_timed` | `$BD42` | — | #0D | Comet Lair |
| `larai_cliff_scroll_wave` | `$BD96` | — | — | Larai Cliff |
| `mu_tint_and_wave` | `$BDCD` | — | #0D, #0E | Mu rooms |
| `dao_sine_hdma_slow` | `$BED1` | #00 | #0D | Dao Village |
| `native_village_sine_hdma` | `$BEF2` | #04 | #0E, #10 | Native Village |

### Custom HDMA / DMA

| Thinker | Address | Scene | Description |
| --------- | --------- | ------- | ------------- |
| `palace_coffin_hdma_table` | `$BE39` | Palace Coffins | Builds HDMA table at $7E7000 |
| `ending_comet_dma_setup` | `$BCDF` | Ending Comet | One-shot PPU DMA |
| `angel_tunnel_window_dma` | `$B87B` | Angel Tunnel | Window register DMA |

### Unused

| Thinker | Address | Reason |
|---------|---------|--------|
| `dma_setup_variant_unused` | `$BC97` | No references |
| `empty_stub_unused` | `$BDCA` | RTL only (3 bytes) |
| `native_village_dup_unused` | `$BEAA` | Byte-identical duplicate |
| `gen_hdma_sine_oneshot_unused` | `$BF52` | Extracted subset |

---

## 13. Thinkers: System

**→ [thinkers-system.md](thinkers-system.md)**

Covers `$00B78F`–`$00BF89`: 11 thinkers for hardware configuration, boot logos, menus, and the global scene dispatcher.

| Thinker | Address | Description |
| --------- | --------- | ------------- |
| `babel_elevator_color_add` | `$B78F` | CGADSUB=#02 — Babel elevator |
| `palace_scroll_brightness` | `$B79D` | COLDATA from $06C2 scroll |
| `dao_window_mask` | `$B7BE` | W12SEL=#02 — Dao Village |
| `itory_village_fog` | `$B818` | CGADSUB=$50 west of X=$01B0 *(not self-contained)* |
| `dark_castoth_layer_config` | `$BF78` | TM=#$17, TS=#$00 |
| `inventory_dma_setup` | `$BB8E` | Inventory screen PPU init |
| `diary_menu_window_dma` | `$BBAF` | State-machine DMA for diary |
| `boot_logo_palette_enix` | `$B83F` | Enix logo fade #50→#52→#54 |
| `boot_logo_palette_quintet` | `$B853` | Quintet logo fade #51→#53→#55 |
| `boot_logo_palette_third` | `$B867` | Third-party fade #56→#57→#58 |
| **`global_ambient_dispatcher`** | `$BF89` | **Hub:** SwitchCase on $0AD4 + player interaction *(not self-contained — has ?INCLUDE deps)* |

---

## 14. Actors: Infrastructure

**→ [actors-infrastructure.md](actors-infrastructure.md)**

Covers scene-level infrastructure actors: camera management, initialization, speed zones, and specialized systems.

| Actor | Address | Movable | Scenes | Description |
| ------- | --------- | --------- | -------- | ------------- |
| `camera_scroll_controller` | `$EAED` | ✓ | 100+ | Camera scroll deltas from player position |
| `scene_flag_init` | `$C667` | ✓ | 80+ | One-shot flag clear, then die |
| `speed_zone_ew_slow` | `$C1DF` | ✓ | MT | E-W speed $FFF9 (−7) |
| `speed_zone_ew_fast` | `$C218` | ✓ | Kress | E-W speed #7 |
| `speed_zone_ns_slow` | `$C286` | ✓ | MT | N-S speed $FFF9 (−7) |
| `speed_zone_ns_fast_unused` | `$C251` | — | None | **UNUSED** — dead duplicate |
| `dream_zoom_controller` | `$C1AA` | ✓ | Dream | Gold Ship scroll/zoom countdown |
| `large_ramp_booster` | `$C963` | **No** | 2 | Player speed ±1 on active ramp |

---

## 15. Actors: Player & Rewards

**→ [actors-player-rewards.md](actors-player-rewards.md)**

Covers player transition animations, red jewel rewards, statue inventory, and location-specific actors.

| Actor | Address | Movable | Description |
| ------- | --------- | --------- | ------------- |
| `boss_clear_reward_handler` | `$C2BB` | ✓ | Boss defeat → catchup uncollected scene clear stat rewards |
| `player_transition_handlers` | `$C418` | **No** | Library: 11 sub-functions for cutscene/warp anims |
| `statue_inventory_reward` | `$CD59` | ✓ | Scene $FD: grants statue collectibles |
| `inventory_statue_slot` | `$CF29` | ✓ | Scene $FF: displays collected statues |
| `freejia_street_prop` | `$C62D` | ✓ | Interactive scenery (Freejia) |
| `hidden_red_jewel` | `$C6A2` | ✓ | Collectible red jewel |
| `town_door` | `$C5A3` | ✓ | Door warp trigger |
| `floor_button` | `$C69B` | ✓ | Pressure plate actor |
| `overworld_exit` | `$CA52` | ✓ | Complex warp/fade logic |
| `field_reveal_object` | `$DA78` | ✓ | Animated reveal/collectible |

### Player Transition Sub-Functions

| Function | Address | Description |
|----------|---------|-------------|
| `SpawnSparkleEffect` | `$C418` | Spawns sparkle animation |
| `HoldPlayerSpriteLoop1` | `$C432` | Loops player sprite frame #01 |
| `HoldPlayerSpriteLoop11` | `$C43D` | Loops player sprite frame #11 |
| `HoldBodySpriteLoop` | `$C446` | Body sprite #04, frame #1F |
| `HoldBodySpriteRelease` | `$C455` | Release from body hold |
| `RestorePlayerControlDirect` | `$C45A` | JML to `PlayerIdleEntry` |
| `PlayerWakeAnim` | `$C45E` | Body #04, frame #20, anim once |
| `PlayerWakeReturn` | `$C46D` | Wake anim → normal control |
| `WarpClimbAnim` | `$C479` | Vertical climb + sound |
| `GardenJumpAnim` | `$C4D1` | Sky Garden ledge jump + flip |
| `FallIntoHoleAnim` | `$C557` | Fall through hollow tile |

---

## 16. Actors: Combat & Interaction

**→ [actors-combat-interaction.md](actors-combat-interaction.md)**

Covers combat knockback, stat reward actors, push handlers, smooth follow, and the visual effect pipeline.

| Actor | Address | Movable | Description |
| ------- | --------- | --------- | ------------- |
| `hit_stagger_controller` | `$D877` | ✓ | 7-part knockback system (spawned on hit) |
| `e_hp_increase` | `$E02D` | ✓ | +1 HP (capped at $0255) |
| `e_str_increase` | `$E07B` | ✓ | +1 STR |
| `e_def_increase` | `$E0C6` | ✓ | +1 DEF |
| `RewardActorVFX` | `$E110` | ✓ | Shared VFX: bounce, sound $25, flag $0300 |
| `collect_handler_gem` | `$E155` | ✓ | Gem collection: nudge toward player ±2 px on button press |
| `push_handler_solid` | `$E256` | ✓ | Requires ≥32 px offset, clears/sets tiles |
| `push_handler_forceball` | `$E3BA` | ✓ | Uses AddPosition, requires anim $003A–$003D |
| `smooth_follow_child` | `$E4DB` | **No** | Child homing via angle/step math |
| `effect_velocity_init` | `$E8D7` | ✓ | Convert coords → velocity, seed $06C8/$06C4 |
| `effect_subpixel_math` | `$E98B` | ✓ | Multiply/divide scroll helper |
| `effect_position_update` | `$E9EC` | ✓ | Integrate velocity, clamp bounds |

---

## 17. Functions: Combat & Defeat

**→ [functions-combat-defeat.md](functions-combat-defeat.md)**

Covers `$00DB8A`–`$00DFFF`: The complete enemy defeat pipeline from death handler through reward distribution.

| Function | Address | Movable | Description |
| ---------- | --------- | --------- | ------------- |
| `StandardEnemyDefeatHandler` | `$DB8A` | **No** | Central death: counters, flash, drops, rewards (~20 callers) |
| `EnemyGemDropRouter` | `$DD5B` | **No** | Routes to dark gem type 1/2/weighted |
| `EnemyStatBonusReward` | `$DD87` | **No** | Scene-indexed HP/STR/DEF spawner |
| `SpawnFieldRevealEffect` | `$DDF2` | ✓ | Field tile reveal effect (sparkles + event block tile swap) |
| `EnemyDeathFlash` | `$DF15` | ✓ | Brief white-flash metasprite (20 bytes) |
| `DarkGemDropSystem` | `$DF29` | ✓ | Dark gem drop spawner + 7 variant handlers |
| `NullActorScriptStub` | `$DC77` | **No** | Immediate COP Die (2 bytes — default actor script) |
| `SpawnAttackTrailEffect` | `$DCB4` | ✓ | 16-frame hit trail |
| `SpawnHitSparkSprites` | `$DD03` | ✓ | OAM spark entries for critical hits |

---

## 18. Functions: Game Over

**→ [functions-game-over.md](functions-game-over.md)**

Covers the complete death sequence from player death assignment through fadeout to reload.

| Function | Address | Movable | Description |
| ---------- | --------- | --------- | ------------- |
| `StopPlayerOnDeathAssign` | `$F3B3` | ✓ | Zero player speed, set $0200 flag (22 bytes) |
| `GameOverSequence` | `$D62F` | **No** | Full death flow: fade, palette, reload saved scene |
| `DeathPaletteFadeThinker` | `$B5B3` | ✓ | Death palette fade (spawned by GameOver) |
| `GameOverCutsceneSprites` | `$D718` | ✓ | Post-death visual: 3 marked sprite actors |
| `DeathWakeupMessage` | `$D796` | ✓ | Character-specific wake-up monologue (Will/Freedan/Shadow) |

---

## 19. Functions: Player & NPC

**→ [functions-player-npc.md](functions-player-npc.md)**

Covers player damage state, NPC wander AI, party escort pathfinding, and inventory messaging.

| Function | Address | Movable | Description |
| ---------- | --------- | --------- | ------------- |
| `ApplyPlayerHitstun` | `$C397` | ✓ | Damage knockback: stun, spawn hit actor (~12 callers) |
| `InitPlayerScriptVariant` | `$C6E4` | ✓ | Select player COP script from 4-entry table |
| `SyncActorPosFromDP` | `$C718` | ✓ | Copy $14/$16 to actor WRAM (13 bytes) |
| `NpcRandomWanderAI` | `$C725` | ✓ | RNG 8-direction walk with collision (~12 callers) |
| `ToggleActorVisibilityFlag` | `$C7FA` | ✓ | XOR $2000 on referenced actor (12 bytes) |
| `EscortFollowPathTracker` | `$C806` | ✓ | Ring buffer of 9 XY waypoints for party follow |
| `InventoryFullMessage` | `$C98E` | ✓ | "Your inventory is full." (10+ callers) |

---

## 20. Functions: Camera & Motion

**→ [functions-camera-motion.md](functions-camera-motion.md)**

Covers ambient camera drift, debris effects, and sin/cos orbital motion math.

| Function | Address | Movable | Description |
| ---------- | --------- | --------- | ------------- |
| `CameraDriftLoopSimple` | `$CF8E` | ✓ | 120-frame random ±1..2 camera nudge |
| `CameraDriftLoopShip` | `$CFAE` | ✓ | Camera drift gated by $player_flags |
| `CameraDriftPatterned` | `$CFEF` | ✓ | Direction-table drift (boss arenas) |
| `SpawnDebrisBurst` | `$C9B8` | ✓ | 8 RNG-scattered sparkle actors |
| `ApplyOrbitalOffsetFromRef` | `$F3C9` | ✓ | Sin/cos offset from reference actor (15+ refs) ⚠ *was misplaced in unused/* |
| `ApplyOrbitalOffsetXY` | `$F432` | ✓ | Sin/cos offset with separate X/Y angles |
| `CopyRefActorPos_unused` | `$F428` | — | **UNUSED** — dead entry stub (10 bytes) |

---

## 21. Stair & Climb System

**→ [stair-climb-system.md](stair-climb-system.md)**

Covers `$00D088`–`$00D5BC`: 13 parts implementing the directional stair trigger and climb animation system. Block is `movable: false` due to tight `$&` coupling to `ramps.asm`.

### Shared Utilities

| Function | Address | Size | Description |
|----------|---------|------|-------------|
| `LockPlayerForClimb` | `$D088` | 38 B | Lock player: set frame count, zero velocity, mask joypad |
| `UnlockPlayerAfterClimb` | `$D0AE` | 35 B | Restore player to normal after climb completes |
| `CheckMoveState` | `$D204` | 20 B | Validate player walking state ($8F) |
| `RestorePlayerControl` | `$D58A` | 54 B | Reset player to normal walking (shared with ramps.asm) |

### Stair Triggers

| Trigger | Address | Size | Valid Facing | Climb Target | Scenes |
|---------|---------|------|--------------|--------------|--------|
| `StairTriggerSouth` | `$D0D1` | 72 B | $12/$13 | `ClimbSouth` | Mu Passage |
| `StairTriggerNorth` | `$D119` | 72 B | $15/$16 | `ClimbNorth` | Mu Passage |
| `StairTriggerWestEntry` | `$D161` | 9 B | — | → `StairTriggerWest` | Angel Village |
| `StairTriggerWest` | `$D16A` | 75 B | $0F/$10 | `ClimbWest` | 12+ scenes |
| `StairTriggerEast` | `$D1B5` | 79 B | $0C/$0D | `ClimbEast` | 10+ scenes |

### Climb Functions

| Function | Address | Size | Movement | End Sprite |
|----------|---------|------|----------|------------|
| `ClimbSouth` | `$D218` | 46 B | $14 −= 4/frame | #14 |
| `ClimbNorth` | `$D246` | 46 B | $14 += 4/frame | #17 |
| `ClimbWest` | `$D274` | 46 B | $16 −= 4/frame | #11 |
| `ClimbEast` | `$D2A2` | 46 B | $16 += 4/frame | #0E |

---

## 22. Camera & Scroll System

**→ [camera-scroll-system.md](camera-scroll-system.md)**

Covers `$00E683`–`$00F292`: 42 parts implementing the smooth actor follow/chase engine, scene camera pan actors, forced walk functions, and coordinate utilities.

### Smooth Follow Engine

| Function | Address | Size | Description |
|----------|---------|------|-------------|
| `CopySiblingFollowState` | `$E683` | 35 B | Copy follow state from sibling |
| `InitFollowAndChase` | `$E6A6` | 561 B | Main entry + 8-direction chase loop |
| `ApplyFollowMovement` | `$E87E` | ~60 B | Apply deltas to actor + sibling |
| `SelectFallbackDirection` | `$E8BA` | ~13 B | SwitchCase dispatch on low 3 bits |

### Camera Pan Actors

| Actor | Address | Size | Scenes | Description |
|-------|---------|------|--------|-------------|
| `ScrollCameraInit` | `$E94D` | 62 B | Mt. Kress | Special overworld scroll init |
| `ScrollCameraTrack` | `$EA96` | 17 B | **40+** | Default camera controller (most common) |
| `ScrollCameraVertical` | `$EAA7` | 28 B | ~10 | Vertical-scroll variant |
| `ScrollCameraAccumulate` | `$EAC3` | 42 B | ~5 | Scroll offset accumulator (Pyramid) |

### Forced Walk Functions

| Function | Address | Size | Direction | Sprite Source |
|----------|---------|------|-----------|---------------|
| `ForcedWalkSouth` | `$EB9B` | 84 B | PanCameraDown | Y velocity |
| `ForcedWalkNorth` | `$EBEF` | 84 B | PanCameraUp | Y velocity |
| `ForcedWalkWest` | `$EC43` | 84 B | PanCameraLeft | X velocity |
| `ForcedWalkEast` | `$EC97` | 84 B | PanCameraRight | X velocity |

### Utilities & Data

| Function | Address | Size | Description |
|----------|---------|------|-------------|
| `TileAlignCoord` | `$ECEB` | 13 B | Pixel → tile grid alignment |
| `TileAlignPosition` | `$ECF8` | 19 B | Align both $14/$16 to grid |
| `ComputeScrollDeltas` | `$ED0B` | 29 B | Camera delta computation |
| `ReadDirSprite_YVelocity` | `$ED28` | 32 B | Direction sprite + Y duration |
| `ReadDirSprite_XVelocity` | `$ED48` | 32 B | Direction sprite + X duration |
| `ApplyScrollOffset` | `$ED68` | 28 B | 4-byte delta from stream → position |
| `SyncPlayerToCamera` | `$ED84` | 36 B | Copy position to player actor |
| `ComputeFollowAngle` | `$EDA8` | ~27 B | Angular step (X primary) |
| `ComputeFollowAngleAlt` | `$EDC3` | ~93 B | Angular step (Y primary) |
| `ComputeFollowStep` | `$EE1C` | 96 B | Pixel step from angle table |
| `ResolveFollowDirection` | `$EE7C` | ~18 B | Direction resolution entry A |
| `ResolveFollowDirectionAlt` | `$EE8C` | ~228 B | Direction resolution entry B + sprite dispatch |
| `FollowDirectionTable` | `$EF72` | 32 B | 16-direction handler jump table |
| 16 direction handlers | `$EF92`–`$F172` | ~545 B | OAM priority/mirror + walking sprite per 22.5° |
| `SmoothFollowLookup` | `$F193` | 544 B | Interpolation/deceleration table |

---

## 23. Data Tables & Memory Map

**→ [data-tables-memory.md](data-tables-memory.md)**

Comprehensive reference covering all data tables, hardware register aliases, the full direct-page variable map, WRAM extended actor fields, global state variables, stack usage patterns, and bank-wide statistics.

---

## 24. Statistics

### Full Bank Code Distribution

| Category | Count | Size |
|----------|-------|------|
| Interrupt vectors / trampolines | 5 | 20 bytes |
| System init + main loop | 1 | ~266 bytes |
| Frame update functions | 4 | ~330 bytes |
| NMI handler + DMA helpers | 5 | ~320 bytes |
| COP dispatch engine + tables | 4 | ~484 bytes |
| COP handlers (primary $00–$6D) | 96 | ~5,800 bytes |
| COP handlers (extended $80–$E2) | 76 | ~3,400 bytes |
| Utility subroutines | 28 | ~1,500 bytes |
| Event flag system | 19 | ~280 bytes |
| Actor management | 11 | ~400 bytes |
| Thinkers (palette + HDMA + system) | 49 | ~3,700 bytes |
| Actors (infrastructure + combat + effects) | 26 | ~4,000 bytes |
| Functions (upper half) | 29 | ~3,000 bytes |
| Stair/climb system | 13 | ~1,336 bytes |
| Camera/scroll system | 22 | ~3,376 bytes |
| Data tables | 20+ | ~1,500 bytes |
| **Total** | **~380+ routines** | **~29,700+ bytes** |

### External Bank Dependencies

| Bank | Unique Functions Called | Purpose |
|------|------------------------|---------|
| `$02` | 17 | Rendering, DMA, actor system, decompression, math |
| `$03` | 27 | Scenes, actors, text, metatiles, inventory, collision, HDMA |
| `$00` (other chunks) | 2 | Orbital math, grid-snap helper |
| `$0A` | 1 | Grid-snap resume target |

### Most-Referenced Blocks (within bank $00)

| Block | Ref Count | Primary Role |
|-------|-----------|-------------|
| `camera_scroll_controller` | 100+ | Every field scene |
| `scene_flag_init` | 80+ | Most scene templates |
| `global_ambient_dispatcher` | ~40 | Nearly every scene set |
| `ambient_palette_cycler` | ~30 | Paired with dispatcher |
| `StandardEnemyDefeatHandler` | ~20 | All enemy actors |
| `ApplyOrbitalOffsetFromRef` | ~15 | COP handlers, bosses, actors |
| `NpcRandomWanderAI` | ~12 | Town NPC scripts |
| `ApplyPlayerHitstun` | ~12 | Combat enemies |
| `EnemyDeathFlash` | ~10 | Enemy defeat |
| `push_handler_solid` | ~9 | Statue/archer/knight actors |

---

## 25. Structural Notes

### Immovable Blocks

These blocks have inbound `$&` (2-byte same-bank) references and **cannot** be relocated:

| Block | Inbound From | Reason |
|-------|-------------|--------|
| `GameOverSequence` ($D62F) | `ComposeDigits_Continuation` | Player death pointer |
| `StandardEnemyDefeatHandler` ($DB8A) | `ComposeDigits_Continuation`, `actor_00D877` | Enemy defeat pointer |
| `NullActorScriptStub` ($DC77) | `ComposeDigits_Continuation` | Default actor script |
| `player_transition_handlers` ($C418) | 15+ consumers | Player anim `#$&func_00C4xx` refs |
| `smooth_follow_child` ($E4DB) | Pyramid, Angkor, etc. | Hard `$&` refs |
| `large_ramp_booster` ($C963) | — | Tight `$&` proximity to ramp code |
| `stair trigger system` ($D088) | `ramps.asm` | `JSR $&` cross-file coupling |

### Known Issues (Resolved)

| Issue | Status | Resolution |
|-------|--------|------------|
| `ApplyOrbitalOffsetFromRef` misplaced in `unused/` | ✅ Fixed | Moved to `functions` section — 15+ live references |
| `thinker_00BEAA` duplicate | ⚠ Flagged | Byte-identical copy of `native_village_sine_hdma` — kept in unused |
| `func_00DC79` duplicate | ⚠ Flagged | Short variant of `SpawnAttackTrailEffect` — kept in unused |

### Source Documents

This documentation suite was generated from analysis of the complete bank $00 ASM codebase in `extracted/`.

---

*Source: Complete analysis of bank $00 ($008000–$00F4FF).*  
*Last updated: 2026-09-06*
