# Illusion of Gaia — Complete WRAM Memory Map

> Comprehensive reference for all WRAM addresses (`$7E:0000`–`$7F:FFFF`) used by
> Illusion of Gaia (US ROM). Compiled from extracted ASM analysis, engine
> documentation, `us/names.json`, `us/blocks.json`, live `.asm` files, and
> cross-validated against the
> [DataCrystal RAM map](https://datacrystal.tcrf.net/wiki/Illusion_of_Gaia/RAM_map)
> and [DataCrystal Notes](https://datacrystal.tcrf.net/wiki/Illusion_of_Gaia/Notes).
>
> **Excludes:** SNES hardware MMIO registers (`$2100`–`$21FF`, `$4200`–`$43FF`)
> which are documented in `gaia-core/snes/vectors.json` and standard SNES references.

---

## Table of Contents

1. [Memory Layout Overview](#1-memory-layout-overview)
2. [Bank $7E: Low WRAM ($0000–$1FFF)](#2-bank-7e-low-wram-00001fff)
   - [Direct Page / System Variables ($0000–$00FF)](#21-direct-page--system-variables-000000ff)
   - [SRAM Region ($0100–$01FF)](#22-sram-region-010001ff)
   - [System State ($0200–$06FF)](#23-system-state-020006ff)
   - [DMA / Tilemap Scratch ($0800–$0901)](#24-dma--tilemap-scratch-080009ff)
   - [Tile Query / Graphics Cache ($0902–$09A1)](#25-tile-query--graphics-cache-090209a1)
   - [Player State ($09A2–$09FF)](#26-player-state-09a209ff)
   - [Event & WRAM Flags ($0A00–$0A9F)](#27-event--wram-flags-0a000a9f)
   - [Player Stats / Inventory ($0AA0–$0B3F)](#28-player-stats--inventory-0aa00b3f)
   - [Input Remapping ($0DA0–$0DC0)](#29-input-remapping-0da00dc0)
   - [Actor Pool ($0DBC–$0FFF)](#210-actor-pool-0dbc0fff)
   - [Actor Direct-Page Slots ($1000–$1FFF)](#211-actor-direct-page-slots-10001fff)
3. [Bank $7E: High WRAM ($2000–$FFFF)](#3-bank-7e-high-wram-2000ffff)
4. [Bank $7F: Extended WRAM ($7F:0000–$7F:FFFF)](#4-bank-7f-extended-wram-7f00007fffff)
   - [Actor Extended Fields ($7F:0000–$7F:002F per slot)](#41-actor-extended-fields-7f00007f002f-per-slot)
   - [CGRAM / Palette Buffer ($7F:0A00–$7F:0C02)](#42-cgram--palette-buffer-7f0a007f0c02)
   - [Adhoc DMA Parameters ($7F:0C03–$7F:0C09)](#43-adhoc-dma-parameters-7f0c037f0c09)
   - [Actor Callback Tables ($7F:1000–$7F:101F per slot)](#44-actor-callback-tables-7f10007f101f-per-slot)
   - [Actor Loop State ($7F:2100–$7F:2103 per slot)](#45-actor-loop-state-7f21007f2103-per-slot)
   - [OAM Compose Buffer ($7F:3100–$7F:340F)](#46-oam-compose-buffer-7f31007f340f)
   - [Inventory Backup ($7F:3490–$7F:38B4)](#47-inventory-backup-7f34907f38b4)
   - [VRAM Cache Ring Buffer ($7F:4000–$7F:6FFF)](#48-vram-cache-ring-buffer-7f40007f6fff)
   - [Decompression / Tile Staging ($7F:7000–$7F:9FFF)](#49-decompression--tile-staging-7f70007f9fff)
   - [Collision Layer ($7F:C000–$7F:DFFF)](#410-collision-layer-7fc0007fdfff)
   - [Inventory State Backup ($7F:E000–$7F:FFFF)](#411-inventory-state-backup-7fe0007fffff)
5. [DataCrystal Cross-Reference & Validation](#5-datacrystal-cross-reference--validation)
6. [Sources](#6-sources)

---

## 1. Memory Layout Overview

The SNES maps WRAM as two 64 KB banks:
- **Bank `$7E`** (`$7E:0000`–`$7E:FFFF`) — mirrored at `$0000`–`$1FFF` in banks `$00`–`$3F` and `$80`–`$BF`
- **Bank `$7F`** (`$7F:0000`–`$7F:FFFF`) — only accessible via long addressing or DMA

IOG sets `DBR = $81` on entry to all game code, so absolute addressing (`LDA $xxxx`) accesses bank `$81` which mirrors low WRAM `$0000`–`$1FFF`. Addresses `$2000`+ in bank `$7E` require explicit long addressing (`LDA $7Exxxx`).

```
Bank $7E
$0000 ┌───────────────────────────────────────────────────────────┐
      │ Direct Page / System Variables                            │ 256 B
$0100 ├───────────────────────────────────────────────────────────┤
      │ Stack / SRAM region                                       │ 256 B
$0200 ├───────────────────────────────────────────────────────────┤
      │ System state: timers, flags, scroll, audio, scene         │ ~1.3 KB
$0800 ├───────────────────────────────────────────────────────────┤
      │ DMA parameters, tile query, graphics cache, player state  │ ~1.8 KB
$1000 ├───────────────────────────────────────────────────────────┤
      │ Actor direct-page slots (64 bytes × ~64 actors)           │ 4 KB
$2000 ├───────────────────────────────────────────────────────────┤
      │ MapLayer metatile mappings (RAM→VRAM map)                 │ 2 KB
$2800 ├───────────────────────────────────────────────────────────┤
      │ EffectLayer metatile mappings (RAM→VRAM map)              │ 2 KB
$3000 ├───────────────────────────────────────────────────────────┤
      │ Thinker pool addresses                                    │ ~34 B
$3100 ├───────────────────────────────────────────────────────────┤
      │ BG tilemap RAM→VRAM staging area                          │ ~784 B
$4000 ├───────────────────────────────────────────────────────────┤
      │ Decompressed tilesets / sprite data                       │ 12 KB
$7000 ├───────────────────────────────────────────────────────────┤
      │ Sprite/BG tile staging → VRAM (freed after load)          │ 12 KB
      │ Also: HDMA tables for some actors                         │
$A000 ├───────────────────────────────────────────────────────────┤
      │ MapLayer tilemap ($B000+ = Mode 7 tilemap)                │ 8 KB
$C000 ├───────────────────────────────────────────────────────────┤
      │ EffectLayer tilemap + Mode 7 tilemap                      │ 8 KB
$E000 ├───────────────────────────────────────────────────────────┤
      │ Mode 7 tilemap / scratch                                  │ 4 KB
$F000 ├───────────────────────────────────────────────────────────┤
      │ Thinker extended data ($10-byte chunks)                   │ 4 KB
$FFFF └───────────────────────────────────────────────────────────┘

Bank $7F
$0000 ┌───────────────────────────────────────────────────────────┐
      │ Actor extended fields ($30 per slot)                      │ ~3 KB
$0A00 ├───────────────────────────────────────────────────────────┤
      │ CGRAM palette buffer (512 B) + backdrop colors (3 B)      │ 515 B
$0C03 ├───────────────────────────────────────────────────────────┤
      │ Adhoc DMA parameters                                      │ 8 B
$0F00 ├───────────────────────────────────────────────────────────┤
      │ Thinker data table ($10-byte chunks)                      │ 256 B
$1000 ├───────────────────────────────────────────────────────────┤
      │ Actor callback tables ($20 per slot)                      │ ~2 KB
$2100 ├───────────────────────────────────────────────────────────┤
      │ Actor loop state (actor-type entries)                     │ ~256 B
$3100 ├───────────────────────────────────────────────────────────┤
      │ Manual OAM compose buffer                                 │ ~784 B
$3490 ├───────────────────────────────────────────────────────────┤
      │ Inventory state backup area                               │ ~1 KB
$4000 ├───────────────────────────────────────────────────────────┤
      │ VRAM cache ring buffer (4 × $2000 slots)                  │ 32 KB
$C000 ├───────────────────────────────────────────────────────────┤
      │ CollisionLayer tilemap (dynamic collision overlay)        │ 8 KB
$E000 ├───────────────────────────────────────────────────────────┤
      │ Inventory backup of $7E:1000–$7E:1FFF                    │ 4 KB
$F000 ├───────────────────────────────────────────────────────────┤
      │ Inventory backup of $7E:0xxx (partial)                    │ 4 KB
$FFFF └───────────────────────────────────────────────────────────┘
```

---

## 2. Bank $7E: Low WRAM ($0000–$1FFF)

Low WRAM is directly accessible via absolute addressing when `DBR = $81` (mirror of `$7E:0000`–`$7E:1FFF`).

### 2.1 Direct Page / System Variables ($0000–$00FF)

When a COP handler or game code sets `TCD #$0000`, offsets `$00`–`$FF` access these global variables. When `TCD` points to an actor slot (`$1000`+), these same offsets become actor-local — see [§2.11](#211-actor-direct-page-slots-10001fff).

| Address | Size | Name | Description | Primary Users |
|---------|------|------|-------------|---------------|
| `$0000`–`$0004` | 5 | Scratch | Map cell index, alignment offset, tile scratch | Movement physics, collision |
| `$0036` | 2 | `frameCounter` | Parity counter — incremented each NMI; used for timing, sine HDMA double-buffer select, HUD flash timing | `NmiHandler`, `UpdateHUD`, sine HDMA thinkers |
| `$003A`–`$003D` | 4 | `sceneMetaPtr` | Long pointer to scene metadata table (hardcoded `$8D8000`) | `InitSystemVariables`, scene loading |
| `$004E`–`$0051` | 4 | `actorPoolPtr` | Long pointer to next free RAM address for new actors | `ActorPoolAllocator`, `ReturnActorSlot` |
| `$0052`–`$0055` | 4 | `thinkerPoolPtr` | Long pointer to next free RAM address for new thinkers | `KillThinker` COP, thinker allocation |
| `$0056`–`$0057` | 2 | `actorListFirst` | Base address of first actor in doubly-linked list | `AllocateActorBefore`, `UnlinkActor` |
| `$0058`–`$0059` | 2 | `actorListLast` | Base address of last actor in actor list | `AllocateActorAfter`, `UnlinkActor` |
| `$005A`–`$005B` | 2 | `thinkerListFirst` | Base address of first thinker in thinker list | `KillThinker` |
| `$005C`–`$005D` | 2 | `thinkerListLast` | Base address of last thinker in thinker list | `AllocateSpecialActor` |
| `$005E`–`$0062` | 5 | Joypad state defaults | Initialized to `$0000/$0081/$0000` at cold start | `InitSystemVariables` |
| `$0066`–`$0067` | 2 | `hdmaEnableMask` | Bitwise flags: HDMA channels queued for enable; written to `$HDMAEN` during NMI | `NmiHandler`, HDMA COPs, `func_03E146` |
| `$0080`–`$0082` | 3 | `collisionLayerBase` | Base RAM address of CollisionLayer (hardcoded `$7FC000`) | Collision routines, `MarkCollisionRect` |
| `$00AC`–`$00AE` | 3 | `dmaSourceAddr` | DMA source address (16-bit) + bank byte | `ExecuteVramDma`, `AdhocVramDma` COP |
| `$00B0` | 2 | `vramDestAddr` | VRAM destination word address | `ExecuteVramDma` |
| `$00B2` | 2 | `dmaTransferSize` | DMA transfer size in bytes (0 = skip) | `ExecuteVramDma` |
| `$00BE`–`$00C0` | 4 | Saved scroll values | Written during Mode 7 VBlank upload (`$BE → $CE`, `$C0 → $D0`) | `VBlankWaitAndJoypad` |
| `$00C2`–`$00CD` | 12 | Mode 7 matrix params | M7A/M7B/M7C/M7D/M7X/M7Y parameters uploaded during VBlank when `$06EF` bit `$08` is set | `VBlankWaitAndJoypad` |
| `$00D8` | 2 | `oamWriteOffset` | Current OAM buffer write index; sentinel written at `$7F3100 + $00D8` | Main loop, frame updates |
| `$00E4` | 2 | `actorLimitThreshold` | Actor limit for `HaltIfActorLimitHit` COP | Actor management |
| `$00EA` | 1 | `activeAbilityGfx` | Active special ability type for graphics reload | Player character, attack system |

> **ASM example** — Frame counter increment in NMI (`system_core.asm`):
> ```asm
> INC $0036           ; 16-bit parity counter
> ```

### 2.2 SRAM Region ($0100–$01FF)

| Address | Size | Name | Description | Primary Users |
|---------|------|------|-------------|---------------|
| `$0100` | 1 | `sramMagicByte` | Save validity marker — `$83` indicates a valid save exists | `SystemInit` cold-start check |
| `$0101`–`$01FF` | 255 | CPU stack | Hardware stack (`SP` initialized to `$01FF` at reset) | All code |

### 2.3 System State ($0200–$06FF)

#### Flags, Counters & Scene State

| Address | Size | Name | Description | Primary Users |
|---------|------|------|-------------|---------------|
| `$0200` | 2 | `deathFlag` | Set by `StopPlayerOnDeathAssign` when player HP reaches 0 | Game over sequence |
| `$0402` | 2 | (init `$548B`) | System flag initialized at cold start | `InitSystemVariables` |
| `$0406` | 2 | (init `$60AB`) | System flag initialized at cold start | `InitSystemVariables` |
| `$0408` | 2 | `extVelocityX` | External velocity accumulator X (knockback, conveyors) | Player movement, hit stagger |
| `$040A` | 2 | `extVelocityY` | External velocity accumulator Y | Player movement, hit stagger |
| `$040C` | 2 | `invincibilityTimer` | Decremented each frame; `$FFFF` = inactive. Controls hit-blink immunity | `UpdateFrameCounters` |
| `$040E` | 2 | `globalFrameTimer` | Incremented each frame; saturates at `$0100` | `UpdateFrameCounters` |
| `$040F`–`$041E` | 16 | `rngState` | Random number generator state bytes | `RngByte` COP handler |
| `$0420` | 2 | `rngModuloResult` | Last `RngMod` COP result | `RngMod` COP |
| `$0422`–`$0621` | 512 | OAM table source | OAM sprite table uploaded to PPU via DMA. Also target of the unused `FillWramBlock` | `UploadOamTable`, DMA |
| `$0642` | 2 | `sceneNext` | Scene ID to transition to (written by warp triggers) | Scene loading, `SystemInit` |
| `$0644` | 2 | `sceneCurrent` | Currently loaded scene ID | Scene engine, warps, inventory overlay |
| `$0648` | 2 | `gfxCacheIdxA` | Graphics cache slot index A (init `$0404`) | Scene graphics cache |
| `$064A` | 2 | `gfxCacheIdxB` | Graphics cache slot index B (init `$0001`) | Scene graphics cache |
| `$0654` | 2 | `worldReadyFlag` | World initialization status; gates dialogue when `≠ $000F` | `SystemInit`, dialogue engine |

#### Input System

| Address | Size | Name | Description | Primary Users |
|---------|------|------|-------------|---------------|
| `$0656` | 2 | `joypadCurrent` | Current-frame filtered joypad bits (after remapping + auto-repeat) | Button COPs, `global_ambient_dispatcher`, all input checks |
| `$0658` | 2 | `joypadHeld` | Held-button auto-repeat mask; bits cleared after 12 frames | `VBlankWaitAndJoypad` |
| `$065A` | 2 | `joypadMaskStd` | Standard joypad suppression mask — `TRB $0656` each frame | Overlay, dialogue, music wait |
| `$065C` | 2 | `joypadMaskInv` | Inverted joypad mask for auto-repeat logic | Overlay, `VBlankWaitAndJoypad` |
| `$065E` | 2 | `joypadRemapped` | Remapped button accumulator (scratch during `VBlankWaitAndJoypad`) | `VBlankWaitAndJoypad` |
| `$0660` | 2 | `joypadRaw` | Raw hardware joypad state from `$JOY1L` — sampled in NMI | `NmiHandler`, `VBlankWaitAndJoypad` |
| `$0662` | 2 | `joypadRepeatCounter` | Auto-repeat frame counter (threshold `$000C` = 12 frames) | `VBlankWaitAndJoypad` |

> **ASM example** — Joypad read in NMI (`system_core.asm`):
> ```asm
> LDA $JOY1L          ; hardware auto-read result
> STA $0660           ; → raw joypad state
> ```

#### Graphics Loading Parameters

| Address | Size | Name | Description | Primary Users |
|---------|------|------|-------------|---------------|
| `$0664`–`$066A` | 7 | `gfxLoadParams` | Scene graphics loading scratch (source pointers, cache flags, layer bits) | Scene script commands |

#### Camera & Scroll System

| Address | Size | Name | Description | Primary Users |
|---------|------|------|-------------|---------------|
| `$068A`–`$068D` | 4 | `bg1ScrollHv` | BG1 horizontal (H) and vertical (V) scroll positions (16-bit each) | `UploadScrollRegisters`, `WriteBgScroll`, `CameraSmoothScroll` |
| `$068E`–`$068F` | 2 | `bg2ScrollHv` | BG2 scroll values (low bytes; extended via `$06C6`+ overrides) | `UploadScrollRegisters` |
| `$0690` | 2 | `savedCameraDelta` | Saved camera delta for `ScrollCameraInit` | `ScrollCameraInit` |
| `$0692` | 2 | `mapBoundsX` | Map width in pixels | Camera bounds clamping |
| `$0693` | 1 | `mapRowStrideL0` | Map row width in columns (layer 0) — byte stride for index math | `AdvanceMapY`, collision iterators, `map_coords.asm` |
| `$0695` | 1 | `mapRowStrideL1` | Map row width for layer 1 | Dual-layer tilemap routines |
| `$0696` | 2 | `mapBoundsY` | Map height in pixels | Camera bounds clamping |
| `$069A`–`$069D` | 4 | Map origin/extent helpers | Map wrap calculations | Camera tilemap |
| `$069E`–`$06A1` | 4 | `mapTilemapBases` | MapLayer/EffectLayer base RAM addresses in bank `$7E` (hardcoded `$A000`, `$C000`) | Scene loading, tilemap DMA |
| `$06AE`–`$06BD` | 16 | VRAM layout addresses | Hardcoded RAM addresses of RAM→VRAM mapping and staging tables | Tile strip DMA, camera tilemap |
| `$06BA`–`$06BC` | 3 | VRAM nametable bases | VRAM nametable base address for queued tile writes | Dirty-strip DMA system |
| `$06BE` | 2 | `cameraTargetX` | Camera target X position (follows player with dead zone) | Camera pan COPs, `ComputeScrollDeltas`, `camera_scroll_controller` |
| `$06C0` | 2 | `cameraDeltaX` | Per-frame camera scroll delta X | Scroll actors, forced walks |
| `$06C2` | 2 | `cameraTargetY` | Camera target Y position | Camera pan COPs, `ComputeScrollDeltas` |
| `$06C4` | 2 | `cameraDeltaY` | Per-frame camera scroll delta Y | Scroll actors, `ScrollCameraVertical` |
| `$06C6`–`$06C7` | 2 | `scrollOverrideH` | Override horizontal scroll value + flag (bit 15 = active) | `WriteBgScroll`, camera pan COPs |
| `$06C8` | 2 | `forcedScrollOverride` | Forced scroll override value | `ScrollCameraInit`, `effect_velocity_init` |
| `$06CA`–`$06CB` | 2 | `scrollOverrideV` | Override vertical scroll value + flag | `WriteBgScroll`, camera pan COPs |
| `$06CE` | 2 | `scrollDeltaXClamped` | Per-frame scroll delta X (clamped ±16 px) | `CameraSmoothScroll` |
| `$06D2` | 2 | `scrollDeltaYClamped` | Per-frame scroll delta Y (clamped ±16 px) | `CameraSmoothScroll` |
| `$06D6` | 2 | `cameraOffsetX` | Left edge of active map window (min scroll X) | `camera_scroll_controller` |
| `$06D8` | 2 | `cameraOffsetY` | Top edge of active map window (min scroll Y) | `camera_scroll_controller` |
| `$06DA` | 2 | `cameraBoundsX` | Right edge of active map window (max scroll X) | `camera_scroll_controller` |
| `$06DE` | 2 | `cameraLowerYBound` | Camera lower Y boundary for collision probes | `TileCollisionQuery` |
| `$06E0` | 2 | `scrollStepTableBase` | Base address for scroll step lookup table | `CameraScrollStepLookup`, forced walks |
| `$06E2` | 2 | `scrollStepIndex` | Current index into scroll step table | `CameraScrollStepLookup` |
| `$06E4` | 2 | `effectDeltaX` | Scroll delta X fed to visual effect pipeline | `camera_scroll_controller` → `effect_velocity_init` |
| `$06E6` | 2 | `effectDeltaY` | Scroll delta Y fed to visual effect pipeline | `camera_scroll_controller` → `effect_position_update` |
| `$06EE` | 1 | `layerPriorityFlag` | Layer draw priority (sign = BG2 first); bit `$0200` = freeze camera | `UploadScrollRegisters`, `camera_scroll_controller` |
| `$06EF` | 1 | `scrollModeFlags` | Bit 3 = locked scroll mode; bit `$08` = Mode 7 active; bit `$01` = BG2 active | `UploadScrollRegisters`, `VBlankWaitAndJoypad` |

#### Audio System

| Address | Size | Name | Description | Primary Users |
|---------|------|------|-------------|---------------|
| `$06F2` | 2 | `musicParentActor` | Music parent actor ID (saved by `MusicPlaybackActor`) | `MusicPlaybackActor` |
| `$06F6` | 2 | `musicRoomGroup` | Room group ID for music continuity; non-zero prevents re-triggering | Scene script `$11` command |
| `$06F8` | 2 | `sfxQueueCh1` | SFX channel 1 queue; sent to `$APUIO2` on even frames during NMI | `PlaySoundCh1` COP, `NmiHandler` |
| `$06F9` | 1 | `sfxQueueCh2` | SFX channel 2 queue | `PlaySoundCh2` COP |
| `$06FA` | 2 | `musicTransitionState` | Active music track transition ID; `$FFFF` = idle. Non-zero triggers `UpdateFrame_Full` from NMI | `NmiHandler`, `MusicPlaybackActor` |

### 2.4 DMA / Tilemap Scratch ($0800–$0901)

| Address | Size | Name | Description | Primary Users |
|---------|------|------|-------------|---------------|
| `$0800` | 1 | `dmaSkipFlag` | Non-zero → skip tilemap DMA path in NMI | `NmiHandler` step 11 |

### 2.5 Tile Query / Graphics Cache ($0902–$09A1)

| Address | Size | Name | Description | Primary Users |
|---------|------|------|-------------|---------------|
| `$0902` | 2 | `tileQueryResult` | Tile query result / VRAM address from metatile helpers; `≠ 0` = query pending | `TileQueryGate`, `ResolveTileData` |
| `$0904`–`$090C` | 8 | `tileGraphicsEntries` | Tile graphics entries resolved by `ResolveTileData` | Tile/map helpers |
| `$0084`–`$008F` | 12 | VRAM content cache slots | 4 slots × 3 bytes (addr+bank) for tile-strip content caching | `GraphicsCacheLookup`, `GraphicsCacheStore` |
| `$0094` | 2 | `cacheRingIndex` | Round-robin slot index for VRAM cache ring buffer | `ComputeRingBufferAddr` |

### 2.6 Player State ($09A2–$09FF)

| Address | Size | Name | Description | Primary Users |
|---------|------|------|-------------|---------------|
| `$099F` | 2 | `sceneStateHelper` | Scene/state helper variable | `SystemInit` |
| `$09A2` | 2 | `playerXPos` | Player pixel X position (sprite-adjusted) | `camera_scroll_controller`, movement physics |
| `$09A4` | 2 | `playerYPos` | Player pixel Y position (sprite-adjusted) | `camera_scroll_controller`, movement physics |
| `$09AA` | 2 | `playerActor` | Player actor slot index (e.g. `$1FC0`) | All player-referencing code |
| `$09AC` | 2 | `joypadInject` | Injected joypad override — non-zero replaces `$0656` and skips hardware read | `VBlankWaitAndJoypad` (forced-walk scripts) |
| `$09AE` | 2 | `playerFlags` | Player state bitmask (see below) | Player character, attack system, slope physics, camera |
| `$09AF` | 1 | `playerStateByte` | Player state high byte — bit `$08` = stair entry; `$8F` = walking state | `CheckMoveState`, stair triggers |
| `$09B0` | 2 | `playerWallType` | Wall type for player animation gating | Player wall-gated animation COPs |
| `$09B2` | 2 | `playerSpeedEw` | East-West speed (written by slope physics, read by move controller) | `player_move_controller`, `slope_ramp_physics` |
| `$09B4` | 2 | `playerSpeedNs` | North-South speed | `player_move_controller`, `slope_ramp_physics` |
| `$09B6` | 2 | `slopeStepCounter` | Slope step counter — indexes into speed curve tables | `slope_ramp_physics` |
| `$09B8` | 2 | `decelStepCounter` | Deceleration step counter | `slope_ramp_physics` |
| `$09BA`–`$09BC` | 4 | `slopeCurvePtrs` | Pointers to slope speed delta tables (ascending/descending) | `slope_ramp_physics`, `SystemInit` |
| `$09C2` | 2 | `decelCurvePtr` | Pointer to flat-ground deceleration speed table | `slope_ramp_physics` |
| `$09C6` | 2 | `slopeFracAccum` | Slope fractional accumulator for sub-pixel Y correction | `slope_ramp_physics`, tile types `$03`/`$0C` |
| `$09C8` | 2 | `maxSpeedEw` | Maximum speed clamp for East-West movement | Movement physics |
| `$09CA` | 2 | `maxSpeedNs` | Maximum speed clamp for North-South movement | Movement physics |
| `$09E0` | 2 | `climbStateData` | Cleared by `UnlockPlayerAfterClimb` after stair/climb completion | Stair/climb system |
| `$09E4`–`$09E6` | 4 | `enemyHpValues` | Enemy HP display values (current + max) for boss health bar | HUD enemy health display |
| `$09EA` | 2 | `enemyHpPending` | Non-zero triggers enemy health bar update in HUD | `UpdateHUD` |
| `$09EC` | 2 | `displayModeFlags` | Scene display mode — bit `$0008` = special BG3; bit `$0010` = stat refresh; bit `$0080` = music sequence; bit `$08` = dialogue display | HUD, NMI, dialogue, sine precompute |
| `$09ED` | 1 | `hudDisableFlag` | Bit `$40` set → HUD globally disabled (title screen, cutscenes) | `UpdateHUD` early exit |
| `$09F4` | 2 | `playerActorDp` | Player actor direct page base for camera reads | `camera_scroll_controller` |

#### Player Flags Reference (`$09AE`)

| Bit | Hex | Meaning |
|-----|-----|---------|
| 0 | `$0001` | Attack system active / attack lock |
| 1 | `$0002` | Attack in progress (combo state) |
| 3 | `$0008` | Player disabled / dead |
| 4 | `$0010` | Terrain shake active |
| 8 | `$0100` | Skip scroll computation in camera controller |
| 9 | `$0200` | Blocked movement flag |
| 11 | `$0800` | Ability FX active (Aura/charge) |
| 12 | `$1000` | On-slope flag (set by ramp physics) |
| 14 | `$4000` | Running / auto-walk |
| 15 | `$8000` | Damage state / hitstun |

### 2.7 Event & WRAM Flags ($0A00–$0A9F)

Two bitfield arrays provide the primary persistence mechanism for game state.

| Address | Size | Capacity | Name | Description |
|---------|------|----------|------|-------------|
| `$0A00`–`$0AFF` | 256 B | 2048 flags | `eventFlags` | **Persistent scene/world state** — chests opened, bosses defeated, switches flipped, red jewel collection. Survives scene transitions. Accessed via `SetEventFlag`, `ClearEventFlag`, `TestEventFlag` and offset wrappers (`+$0100`, `+$0200`, `+$0300`, `+$0510`). |
| `$0A80`–`$0A9F` | 32 B | 256 flags | `wramFlags` | **Scene-local scratch flags** — dungeon kill tracking, puzzle state, per-room logic. Cleared by `ClearAllWramFlags` at scene boundaries. Accessed via `SetWramFlag`, `TestWramFlag`. |

> **Bitfield indexing:** `byte_offset = index >> 3`, `bitmask = bitmasks_bit_position[index & 7]` where the mask table at `$00B11D` is `$01,$02,$04,$08,$10,$20,$40,$80`.
>
> **Carry convention (test routines):** Carry **clear** = flag is set; carry **set** = flag is clear. This inverted convention allows `BCC flag_true` patterns in COP scripts.

### 2.8 Player Stats / Inventory ($0AA0–$0B3F)

| Address | Size | Name | Description | Primary Users |
|---------|------|------|-------------|---------------|
| `$0AA2` | 2 | `abilityBitmask` | Ability availability bitmask — bits select which abilities are unlocked | Player character, attack system |
| `$0AB4`–`$0AD2` | 31 | `inventorySlots` | 16 item words — low byte = item ID (0 = empty) | All inventory tabs |
| `$0AC4` | 2 | `inventoryEquippedIdx` | Equipped item slot index (`$FFFF` = none) | Inventory use tab, equip cursor |
| `$0AC6` | 2 | `inventoryEquippedType` | Equipped item type ID | Use confirm, HUD |
| `$0ACA` | 2 | `playerMaxHp` | Player's maximum HP — ceiling for HP recovery animation | `UpdateHUD` |
| `$0ACC` | 2 | `cachedPrevMaxHp` | Previous max HP value for HUD change detection | `UpdateHUD` |
| `$0ACE` | 2 | `playerHp` | Player's current HP (decreases from damage, recovers toward max) | `UpdateHUD` |
| `$0AD0` | 2 | `cachedPrevHp` | Previous HP value for HUD change detection | `UpdateHUD` |
| `$0AD4` | 2 | `characterForm` | Current character form: 0 = Will, 1 = Freedan, 2 = Shadow | `SetActorBody`, body swap COPs, `dark_space_palette` |
| `$0AD6` | 2 | `gemCount` | Current gem count | HUD gem display |
| `$0AD8` | 2 | `gemHundredsDigit` | Gem count ÷ 100 for three-digit display | `UpdateHUD` |
| `$0ADA` | 2 | `cachedPrevGems` | Previous gem count for change detection | `UpdateHUD` |
| `$0ADC` | 2 | `playerDef` | Player's defense stat value | HUD, stat reward actors |
| `$0ADE` | 2 | `playerStr` | Player's strength stat value | HUD, stat reward actors |
| `$0AE4` | 2 | `enemyHealthTimer` | Enemy health bar display countdown (`$001E` frames → 0) | `UpdateHUD` |
| `$0AE6` | 2 | `bg1ConfigMode` | BG1 scroll/config mode; also serves as overlay exit poll flag | Inventory overlay, tab handlers |
| `$0AE8` | 2 | `itemAbilityIndex` | Item/ability index for BG3 description strings | Inventory use, discard, status |
| `$0AF0`–`$0AF8` | 9 | `sceneSaveData` | Scene save data for game-over reload | `GameOverSequence` |
| `$0AFA` | 2 | `inventoryTabIndex` | Tab index (0–3: Use, Arrange, Discard, Status); also slot spawn counter during init | Inventory menu, statue display |
| `$0B04` | 2 | (init `$0000`) | Gameplay flag | `InitSystemVariables` |
| `$0B14` | 2 | (init `$003C`) | System flag (60 decimal) | `InitSystemVariables` |
| `$0B22` | 2 | `damageFlashTimer` | Non-zero triggers DEF display animation every 8 frames | `UpdateHUD` |
| `$0B28`–`$0B32` | 11 | `saveWarpMetadata` | Save and warp state metadata | System init |

> **ASM example** — Stat reward actor incrementing HP (`actors-combat-interaction.md`):
> ```asm
> ; e_hp_increase at $E02D
> LDA $0ACA           ; current max HP (playerMaxHp)
> INC                 ; +1 max HP
> CMP #$0028          ; cap check (40 max)
> BCC .store
> LDA #$0028
> .store:
> STA $0ACA
> ```

### 2.9 Input Remapping ($0DA0–$0DC0)

Per-button remapping masks. When a hardware button is held, its corresponding remap mask is `TSB`'d into `$065E` during `VBlankWaitAndJoypad`. Allows remapping physical buttons to logical actions.

| Address | Size | Name | Hardware Button | Init Value |
|---------|------|------|-----------------|------------|
| `$0DA6` | 2 | `remapSelect` | Select (`$0010`) | `$0010` |
| `$0DA8` | 2 | `remapX` | X (`$0020`) | `$0020` |
| `$0DAA` | 2 | `remapB` | B (`$8000`) | `$8000` |
| `$0DAC` | 2 | `remapA` | A (`$0080`) | `$0080` |
| `$0DAE` | 2 | `remapY` | Y (`$4000`) | `$4000` |
| `$0DB0` | 2 | `remapStart` | Start (`$0040`) | `$0040` |
| `$0DB2` | 2 | `remapL` | L (`$1000`) | `$1000` |
| `$0DB4` | 2 | `remapR` | R (`$2000`) | `$2000` |

> These are identity-mapped by default (each button maps to itself). Games or patches could remap by changing these values.

### 2.10 Actor Pool ($0DBC–$0FFF)

| Address | Size | Name | Description |
|---------|------|------|-------------|
| `$0DBC` | 2 | `activeActorCount` | Count of currently active actors |
| `$0E00`–`$0EFF` | 256 | `actorPoolTable` | Table of available RAM addresses for new actors (freed slots returned here) |
| `$0F00`–`$0FFF` | 256 | `thinkerDataTable` | Main thinker table in `$10`-byte chunks |

### 2.11 Actor Direct-Page Slots ($1000–$1FFF)

Actors use 64-byte (`$40`) direct-page slots. Each actor's ID **is** its DP base address (e.g. actor `$1FC0` has DP from `$1FC0`–`$1FFF`). When COP dispatches to an actor, `TCD` is set to the actor ID, making offsets `$00`–`$3F` access the actor's local control block.

| Offset | Size | Name | Description |
|--------|------|------|-------------|
| `$00`–`$02` | 3 | `entryPtr` | Script entry address (16-bit word + bank byte); written by COP continue/branch via `STA $02,S` |
| `$03` | 1 | *(dummy)* | Padding for 24-bit `entryPtr` alignment |
| `$04` | 2 | `prevActorLink` | Doubly-linked list predecessor actor ID |
| `$06` | 2 | `nextActorLink` | Doubly-linked list successor actor ID |
| `$08` | 2 | `waitCounter` | Frame wait/yield/halt countdown; zeroed on spawn and climb lock |
| `$0A`–`$0C` | 3 | `argPtr` | COP dispatch: pointer to first argument byte after opcode |
| `$0C` | 1 | `scriptBank` | Script bank byte (return bank from COP) |
| `$0D` | 1 | *(dummy)* | Padding for 24-bit `argPtr` |
| `$0E` | 2 | `oamXorFlags` | Sprite priority, palette line, H/V flip XOR mask |
| `$10` | 2 | `actorFlags1` | **Flags10** — collision priority (`$0004`), offscreen, spawned (`$2000`), player-hit (`$0008`), invisible (`$2200`) |
| `$12` | 2 | `actorFlags2` | **Flags12** — force-flip, marked-child (`$0040`), interact (`$1000`), push-in-progress (`$0010`) |
| `$14` | 2 | `posX` | Actor pixel X position (NW corner of map = origin) |
| `$16` | 2 | `posY` | Actor pixel Y position |
| `$18` | 2 | `offsX` | Sprite offset from `posX` (used for scratch/probe X in some contexts) |
| `$1A` | 2 | `offsY` | Sprite offset from `posY` (also tile width counter for collision rects) |
| `$1C` | 2 | `offsXMir` | Mirrored sprite offset X (when H-mirror in `$0E` is flipped) |
| `$1E` | 2 | `offsYMir` | Mirrored sprite offset Y |
| `$20` | 1 | `hitboxW` | Hitbox size, West (−X direction). Free if no hitbox. |
| `$21` | 1 | `hitboxE` | Hitbox size, East (+X direction) |
| `$22` | 1 | `hitboxN` | Hitbox size, North (−Y direction) |
| `$23` | 1 | `hitboxS` | Hitbox size, South (+Y direction) |
| `$24` | 2 | `free24` | Free / step counter / target actor index (context-dependent) |
| `$26` | 2 | `free26` | Free / scroll accumulator Y (context-dependent) |
| `$28` | 2 | `sprIdx` | Sprite (graphics) index; animation staging |
| `$2A` | 2 | `sprFrame` | Animation frame of sprite |
| `$2C` | 2 | `moveX` | Movement data / velocity X |
| `$2E` | 2 | `moveY` | Movement data / velocity Y |
| `$30`–`$3F` | 16 | *(script scratch)* | Remaining bytes used as temporary staging by various COP handlers |

> **DataCrystal cross-reference:** The DataCrystal Notes page documents the same layout with field names `EntryPtr`, `PrevId`, `NextId`, `WaitTime`, `ArgPtr`, `OamXor`, `Flags10`, `Flags12`, `PosX`, `PosY`, `OffsX`, `OffsY`, `OffsXMir`, `OffsYMir`, `HitboxW`/`E`/`N`/`S`, `Free24`, `Free26`, `SprIdx`, `SprFrame`, `MoveX`, `MoveY`. Our field definitions match exactly.

---

## 3. Bank $7E: High WRAM ($2000–$FFFF)

These regions require long addressing (`LDA $7Exxxx`) since they fall outside the `$0000`–`$1FFF` mirror range.

| Range | Size | Name | Description |
|-------|------|------|-------------|
| `$7E:2000`–`$7E:27FF` | 2 KB | `metatileMapLayer` | MapLayer metatile mappings — RAM→VRAM tile map. Maps RAM tile indices `$00`–`$FF` to eight VRAM character bytes. Written by scene command `$05` (Layers=1). |
| `$7E:2800`–`$7E:2FFF` | 2 KB | `metatileEffectLayer` | EffectLayer metatile mappings — same format for BG2. Written by scene command `$05` (Layers=2). |
| `$7E:3000`–`$7E:3021` | 34 B | `thinkerPoolAddrs` | Table of available RAM addresses for new thinkers |
| `$7E:3100`–`$7E:340F` | ~784 B | `tilemapStaging` | BG tilemap RAM→VRAM staging area. Used for dirty-strip buffering during scroll. Dirty flags at `$7E:3100`/`$7E:3288` (horizontal) and `$7E:3184`/`$7E:330C` (vertical). |
| `$7E:3490`–`$7E:358F` | 256 B | `inventoryBackupPool` | Inventory screen's backup of `$0E00`–`$0EFF` (actor pool table) |
| `$7E:4000`–`$7E:6FFF` | 12 KB | `decompressedTilesets` | Decompressed tilesets, sprite connectivity data. Written by `QuintetLzDecompress` and scene commands `$03`/`$10`. |
| `$7E:7000`–`$7E:9FFF` | 12 KB | `tileStagingBuffer` | During map load: sprite and BG tiles before VRAM push. **Freed after load** — some actors reuse for HDMA tables (e.g. `palace_coffin_hdma_table` builds at `$7E7000`). |
| `$7E:8900`–`$7E:8AFF` | 512 B | `sineTableA` | Precomputed sine table A (built by `BuildSineLookupTable`) |
| `$7E:8B00`–`$7E:8CFF` | 512 B | `sineTableB` | Precomputed sine table B (double-buffered with A) |
| `$7E:A000`–`$7E:BFFF` | 8 KB | `mapLayerTilemap` | MapLayer tilemap (conventionally BG1). `$B000`+ is also the Mode 7 tilemap. Written by scene command `$06` (Layer=1). |
| `$7E:C000`–`$7E:DFFF` | 8 KB | `effectLayerTilemap` | EffectLayer tilemap (conventionally BG2) and Mode 7 tilemap. Written by scene command `$06` (Layer=2). |
| `$7E:E000`–`$7E:EFFF` | 4 KB | `mode7Tilemap` | Mode 7 tilemap (world map screen) |
| `$7E:F000`–`$7E:FFFF` | 4 KB | `thinkerExtendedData` | Additional thinker data in `$10`-byte chunks |

---

## 4. Bank $7F: Extended WRAM ($7F:0000–$7F:FFFF)

### 4.1 Actor Extended Fields ($7F:0000–$7F:002F per slot)

Extended actor state uses `(actor_id − $1000)` as the X index. Each actor has up to `$30` bytes of extended state here.

| Address | Size | Name | Description | Primary Users |
|---------|------|------|-------------|---------------|
| `$7F:0000,X` | 4 | `animScratch` | **AnimScr1** — 4 bytes of scratch for sprite animation COPs. Individual bytes used as sub-pixel accumulators, animation sub-counters, or frame counters depending on context | `MoveToward`, `TickMove`, `InitSmoothMovement`, palette thinkers |
| `$7F:0004,X` | 2 | `retPtr1` | **RetPtr1** — return pointer set by some COPs; used for deferred callbacks and resume-after-wait | Script control COPs |
| `$7F:0006,X` | 3 | `spritesetPtr` | **SprSetPtr** — long pointer to spriteset data (e.g. "Diamond Mine" tileset); `$28` indexes within this | `SetMetasprite`, `SetActorBody` |
| `$7F:000A,X` | 2 | `chatPtr` | **ChatPtr** — how actor interacts with player (NPC talk handler, chest contents, etc.) | Context-dependent |
| `$7F:000C,X` | 2 | `metaspritePtr` | **SprMetPtr** — pointer to metasprite (sprite tile assembly data) | Sprite rendering |
| `$7F:000E,X` | 2 | `animScratch2` | **AnimScr2** — scratch bytes for sprite animation COPs. Used for direction/step totals in movement handlers, thinker header copy, etc. | Smooth follow, movement COPs, thinker init |
| `$7F:0010,X` | 2 | `orbitAngle` | **OrbitAng** — orbiting angle; not reserved by engine. Also used for sound effect ID (WorldMapStream) or follow angle (smooth follow, hitstun distance) | `InitSpiral`, `SpiralStep`, context-dependent |
| `$7F:0012,X` | 2 | `orbitDiameter` | **OrbitDia** — orbiting diameter; not reserved by engine. Also used as sub-step accumulator | `InitSpiral`, `SpiralStep`, `ComputeFollowStep` |
| `$7F:0014,X` | 2 | `loopCounter` | **LoopCntr** — loop counter; not reserved by engine. Used by some COPs as iteration counter, also for sibling sprite index | `LoopInit`, `CopySiblingFollowState` |
| `$7F:0016,X` | 2 | `sprTimer` | **SprTimer** — timer for sprite animation COPs | `AnimLoop` COP |
| `$7F:0018,X` | 2 | `moveXAlt` | **MoveXAlt** — alternate MoveX / target distance X; meaning depends on context | `InitSmoothMovement`, movement COPs |
| `$7F:001A,X` | 2 | `moveYAlt` | **MoveYAlt** — alternate MoveY / target distance Y | `InitSmoothMovement`, movement COPs |
| `$7F:001C,X` | 2 | `parentId` | **ParentId** — if set and conditions met, actor dies with parent | `MarkChildActor`, `DieNow_UnlinkChildren` |
| `$7F:001E,X` | 2 | `retPtr2` | **RetPtr2** — return pointer set by some COPs; used by `LoopDecrement` for loop start PC | `LoopInit`, script control |
| `$7F:0020,X` | 2 | `statsPtr` | **StatsPtr** — pointer to monster's HP/STR/DEF/DP stats table | `StandardEnemyDefeatHandler`, combat |
| `$7F:0022,X` | 2 | `enemyNum` | **EnemyNum** — dungeon-level enemy number for tracking kills | `SetDungeonKillFlag` COP |
| `$7F:0024,X` | 2 | `deathActionIdx` | **DeathIdx** — index of map rearrangement script triggered on death | `StandardEnemyDefeatHandler` |
| `$7F:0026,X` | 2 | `currentHp` | **CurrHp** — actor's current hit points | Combat system |
| `$7F:0028,X` | 2 | `iframeCounter` | **IframeCtr** — invincibility frame counter; positive = stunned, absolute value = iframes remaining | Hit stagger, combat |
| `$7F:002A,X` | 2 | `extendedFlags` | **Flags7F2A** — extended state flags — bit 1 = moving; bit `$0020` = hitstun skip; bit `$0004` = execute-after-actors | `SetActorFlags`/`ClearActorFlags` COPs |
| `$7F:002C,X` | 2 | `moveScratch1` | **MoveScr1** — scratch bytes for movement COPs. Commonly holds computed velocity X for smooth movement | `MoveToward`, `ApplyFollowMovement` |
| `$7F:002E,X` | 2 | `moveScratch2` | **MoveScr2** — scratch bytes for movement COPs. Commonly holds computed velocity Y | `MoveToward`, `ApplyFollowMovement` |

> **DataCrystal cross-reference:** Field names now align with DataCrystal canonical names shown in **bold** above: `AnimScr1` (4-byte scratch), `RetPtr1`, `SprSetPtr`, `ChatPtr`, `SprMetPtr`, `AnimScr2`, `OrbitAng`, `OrbitDia`, `LoopCntr`, `SprTimer`, `MoveXAlt`, `MoveYAlt`, `ParentId`, `RetPtr2`, `StatsPtr`, `EnemyNum`, `DeathIdx`, `CurrHp`, `IframeCtr`, `Flags7F2A`, `MoveScr1`, `MoveScr2`.

### 4.2 CGRAM / Palette Buffer ($7F:0A00–$7F:0C02)

| Range | Size | Name | Description |
|-------|------|------|-------------|
| `$7F:0A00`–`$7F:0BFF` | 512 B | `cgramPalette` | Full 512-byte CGRAM palette buffer. DMA'd to PPU `$2122` by `UploadCgramPalette`. Written by scene command `$04` during map loads. |
| `$7F:0C00`–`$7F:0C02` | 3 B | `backdropColors` | Fixed backdrop color bytes written to `$COLDATA` after palette upload | `UploadCgramPalette` |

### 4.3 Adhoc DMA Parameters ($7F:0C03–$7F:0C09)

| Range | Size | Name | Description |
|-------|------|------|-------------|
| `$7F:0C03`–`$7F:0C09` | 7 B | `adhocVramDma` | Parameters for `AdhocVramDma` COP (`$4F`): source address, VRAM destination, transfer size |

### 4.4 Actor Callback Tables ($7F:1000–$7F:101F per slot)

Extended callback pointers, indexed by `(actor_id − $1000)`.

| Address | Size | Name | Description | Set By |
|---------|------|------|-------------|--------|
| `$7F:1000,X` | 2 | `onHitCallback` | When hit by player, `entryPtr` is redirected here | `SetOnHit` COP |
| `$7F:1002,X` | 2 | `onDodgeCallback` | When player attacks but misses, `entryPtr` redirected here | `SetOnDodge` COP |
| `$7F:1004,X` | 4 | `onDeathCallback` | When actor dies, `entryPtr` set to this long pointer | `SetOnDeath` COP |
| `$7F:1008,X` | 2 | `onCollideCallback` | When actor collides with player (if `extendedFlags` is so set) | `SetOnCollide` COP |
| `$7F:100A`–`$0F` | 6 | *(free)* | No known use — probably free memory | — |
| `$7F:1010,X` | 8 | `scratch1010` | **Scr1010** — 8 bytes of scratch for some COPs, otherwise free. Used by `InitGravity`/`TickGravity` (acceleration, speed, state) and `InitSpiral` (orbit diameter/angle). Individual words at +0/+2/+4/+6 | `InitGravity`, `TickGravity`, `InitSpiral` COPs |
| `$7F:1018,X` | 4 | `snapResumePtr` | **SnapPtr** — long pointer: COP `$43` (`SnapToGrid`) stores caller here for resume; no other known use | `SnapToGrid` COP |
| `$7F:101C,X` | 2 | `free101C` | **Free101C** — no known reserved use; cleared to zero on actor spawn by `CopyActorState` | — |
| `$7F:101E,X` | 2 | `chainDamage` | **ChainDmg** — when colliding with an actor, damage to deal to it | Collision system |

### 4.5 Actor Loop State ($7F:2100–$7F:2103 per slot)

| Address | Size | Name | Description |
|---------|------|------|-------------|
| `$7F:2100,X` | 2 | `loopStartPcActor` | Loop start PC for actor-type entities (when actor ID < `$1000`) | `LoopInit` |
| `$7F:2102,X` | 2 | `loopCounterActor` | Loop counter for actor-type entities | `LoopInit` / `LoopDecrement` |

### 4.6 OAM Compose Buffer ($7F:3100–$7F:340F)

| Range | Size | Name | Description |
|-------|------|------|-------------|
| `$7F:3100`–`$7F:340F` | ~784 B | `oamComposeBuffer` | Manual OAM table for rendering sprite tiles without needing a full actor. The main loop writes sentinel `$FF` at `$7F:3100 + $00D8` and `$7F:3101 + $00D8` to mark end-of-sprites. |

### 4.7 Inventory Backup ($7F:3490–$7F:38B4)

| Range | Size | Name | Description |
|-------|------|------|-------------|
| `$7F:3490`–`$7F:38B4` | ~1,060 B | `inventorySaveScratch` | Overlay state-sandwich scratch. `SaveGameState` uses MVN block moves to save ~5.5 KB of gameplay WRAM before entering the inventory scene. `RestoreGameState` restores byte-for-byte afterward. |

### 4.8 VRAM Cache Ring Buffer ($7F:4000–$7F:6FFF)

| Range | Size | Name | Description |
|-------|------|------|-------------|
| `$7F:4000`–`$7F:BFFF` | 32 KB | `vramCacheRing` | 4 slots × `$2000` bytes each. Stores VRAM snapshots for the tile-strip content cache. When a scene reloads identical tile data, `RestoreCachedVram` DMAs from here instead of re-decompressing. Slot index tracked in `$0094`. |

### 4.9 Decompression / Tile Staging ($7F:7000–$7F:9FFF)

| Range | Size | Name | Description |
|-------|------|------|-------------|
| `$7F:7000`–`$7F:9FFF` | 12 KB | `decompressStaging` | Scene command `$03` decompresses BG character data here before VRAM DMA. After scene load completes, this memory is **freed** and reused by actors for HDMA tables and scratch buffers. |

> **ASM example** — HDMA table reuse (`thinkers-hdma.md`):
> ```asm
> ; palace_coffin_hdma_table thinker builds HDMA data at $7E7000
> ; This only works because the scene has finished loading by the time the thinker runs
> ```

### 4.10 Collision Layer ($7F:C000–$7F:DFFF)

| Range | Size | Name | Description |
|-------|------|------|-------------|
| `$7F:C000`–`$7F:DFFF` | 8 KB | `collisionLayer` | Runtime collision overlay tilemap. High nibble = dynamic block (ORed by COP `$0B`/`$0C`/`$11` handlers); low nibble = base tile collision type (`$00`–`$0F`). `ReadCollisionNibble` prefers high nibble when non-zero. Base address stored at `$0080` (hardcoded `$7FC000`). |

**Collision type reference:**

| Type | Meaning | Movement Effect |
|------|---------|-----------------|
| `$00` | Passable (empty) | Free movement |
| `$01` | Passable (variant) | Free movement (special diagonal handling) |
| `$02` | Interactive tile | Redirect to alternate animation |
| `$03` | Slope (ascending east) | Computed sub-pixel Y correction |
| `$05` | Semi-solid / ramp entry | Ramp passability checks |
| `$06` | Wall (south-facing) | Block south, allow east slide |
| `$07` | Ladder / climbable | Auto-climb state change |
| `$08` | Stairs | Stair-step movement redirect |
| `$09` | Wall (north-facing) | Block north, allow slide |
| `$0A` | Ramp / passable slope | Full ramp movement with Y tracking |
| `$0C` | Slope (ascending west) | Sub-pixel correction with accumulator |
| `$0E`+ | Solid wall | Full block, zero speed |
| `$0F` | Out of bounds | Returned for OOB probes |

### 4.11 Inventory State Backup ($7F:E000–$7F:FFFF)

| Range | Size | Name | Description |
|-------|------|------|-------------|
| `$7F:E000`–`$7F:EFFF` | 4 KB | `invBackupActors` | Inventory screen's backup of `$7E:1000`–`$7E:1FFF` (all actor DP slots) |
| `$7F:F000`–`$7F:FFFF` | 4 KB | `invBackupSystem` | Inventory screen's backup of low WRAM system state |

---

## 5. DataCrystal Cross-Reference & Validation

The following table compares our analysis against the [DataCrystal RAM map](https://datacrystal.tcrf.net/wiki/Illusion_of_Gaia/RAM_map) and [Notes](https://datacrystal.tcrf.net/wiki/Illusion_of_Gaia/Notes). Status column indicates agreement.

| DC Address | DC Description | Our Address | Our Name | Status |
|------------|----------------|-------------|----------|--------|
| `$003A`–`$003D` | Map header data table address (hardcoded `$8D8000`) | `$003A`–`$003D` | `sceneMetaPtr` | ✅ Match |
| `$004E`–`$0051` | Long pointer to next available RAM for actors | `$004E`–`$0051` | `actorPoolPtr` | ✅ Match |
| `$0052`–`$0055` | Long pointer to next available RAM for thinkers | `$0052`–`$0055` | `thinkerPoolPtr` | ✅ Match |
| `$0056`–`$0057` | Base address of first actor | `$0056`–`$0057` | `actorListFirst` | ✅ Match |
| `$0058`–`$0059` | Base address of last actor | `$0058`–`$0059` | `actorListLast` | ✅ Match |
| `$005A`–`$005B` | Base address of first thinker | `$005A`–`$005B` | `thinkerListFirst` | ✅ Match |
| `$005C`–`$005D` | Base address of last thinker | `$005C`–`$005D` | `thinkerListLast` | ✅ Match |
| `$0066`–`$0067` | DMA channel ready flags | `$0066`–`$0067` | `hdmaEnableMask` | ✅ Match — we clarify these are HDMA channels, not general DMA |
| `$0080`–`$0082` | CollisionLayer base (hardcoded `$7FC000`) | `$0080`–`$0082` | `collisionLayerBase` | ✅ Match |
| `$069E`–`$06A1` | MapLayer/EffectLayer base RAM (hardcoded `$A000`/`$C000`) | `$069E`–`$06A1` | `mapTilemapBases` | ✅ Match |
| `$06AE`–`$06BD` | Hardcoded RAM→VRAM mapping/staging addresses | `$06AE`–`$06BD` | VRAM layout addresses | ✅ Match |
| `$0E00`–`$0EFF` | Table of available RAM addresses for actors | `$0E00`–`$0EFF` | `actorPoolTable` | ✅ Match |
| `$0F00`–`$0FFF` | Main thinker table (`$10`-byte chunks) | `$0F00`–`$0FFF` | `thinkerDataTable` | ✅ Match |
| `$7E:2000`–`$27FF` | MapLayer tilemap RAM→VRAM mapping | `$7E:2000`–`$27FF` | `metatileMapLayer` | ✅ Match |
| `$7E:2800`–`$2FFF` | EffectLayer tilemap RAM→VRAM mapping | `$7E:2800`–`$2FFF` | `metatileEffectLayer` | ✅ Match |
| `$7E:3000`–`$3021` | Thinker pool addresses | `$7E:3000`–`$3021` | `thinkerPoolAddrs` | ✅ Match |
| `$7E:3100`–`$340F` | BG tilemap RAM→VRAM staging | `$7E:3100`–`$340F` | `tilemapStaging` | ✅ Match |
| `$7E:3490`–`$358F` | Item screen's backup of `$0E00`–`$0EFF` | `$7E:3490`–`$358F` | `inventoryBackupPool` | ✅ Match |
| `$7E:4000`–`$6FFF` | Decompressed tilesets/sprite data | `$7E:4000`–`$6FFF` | `decompressedTilesets` | ✅ Match |
| `$7E:7000`–`$9FFF` | Tile staging (freed after load) | `$7E:7000`–`$9FFF` | `tileStagingBuffer` | ✅ Match — we add detail about HDMA table reuse |
| `$7E:A000`–`$BFFF` | MapLayer tilemap | `$7E:A000`–`$BFFF` | `mapLayerTilemap` | ✅ Match |
| `$7E:C000`–`$DFFF` | EffectLayer tilemap | `$7E:C000`–`$DFFF` | `effectLayerTilemap` | ✅ Match |
| `$7F:0A00` | CGRAM buffer | `$7F:0A00`–`$0BFF` | `cgramPalette` | ✅ Match |
| `$7F:0F00`–`$0FFF` | Additional thinker data | `$7E:F000`–`$FFFF` | `thinkerExtendedData` | ⚠️ Note: DC lists as `$7F:0F00`; actual bank depends on context. Both banks have thinker data regions. |
| `$7F:3100`–`????` | Manual OAM table | `$7F:3100`–`$340F` | `oamComposeBuffer` | ✅ Match — we provide the end bound |
| `$7F:C000`–`$DFFF` | CollisionLayer tilemap | `$7F:C000`–`$DFFF` | `collisionLayer` | ✅ Match |
| `$7F:E000`–`$EFFF` | Item screen's backup of `$7E:1000`–`$1FFF` | `$7F:E000`–`$EFFF` | `invBackupActors` | ✅ Match |
| `$7F:F000`–`$FFFF` | Item screen's backup of low WRAM | `$7F:F000`–`$FFFF` | `invBackupSystem` | ✅ Match |
| DC `$7e:00`–`$2e` (actor DP) | Actor direct page layout | `$00`–`$2E` in §2.11 | Full actor slot layout | ✅ Match — all 23 named fields match |
| DC `$7f:00`–`$2e` (actor ext) | Actor extended memory layout | §4.1 full table | Full actor extended layout | ✅ Match — names now aligned with DC canonical: `AnimScr1`→`animScratch`, `RetPtr1`→`retPtr1`, `AnimScr2`→`animScratch2`, `OrbitAng`→`orbitAngle`, `OrbitDia`→`orbitDiameter`, `LoopCntr`→`loopCounter`, `RetPtr2`→`retPtr2`, `MoveScr1`→`moveScratch1`, `MoveScr2`→`moveScratch2` |
| DC `$7f:1000`–`$101e` (callbacks) | Actor callback table | §4.4 full table | Full callback layout | ✅ Match — `Scr1010`→`scratch1010`, `Free101C`→`free101C`, callbacks match |

### Notable Additions Beyond DataCrystal

Our analysis documents the following addresses not present in the DataCrystal RAM map:

- **Complete input system** (`$0656`–`$0662`, `$0DA6`–`$0DB4`) — joypad filtering, remapping masks, auto-repeat
- **Full camera/scroll pipeline** (`$068A`–`$06EF`) — 25+ variables for scroll targets, overrides, deltas, bounds
- **Audio handshake** (`$06F2`–`$06FA`) — music state machine, SFX queues, APU sync
- **Player state block** (`$09A2`–`$09F4`) — 20+ player-specific variables including slope physics, speed curves, climb state
- **Complete stats/inventory** (`$0AA2`–`$0B32`) — ability bitmask, 16 inventory slots, equipped item, stat display cache
- **HUD management** (`$0ACA`–`$0B22`) — HP recovery animation, enemy health bar timer, cached stat comparisons
- **Display mode flags** (`$09EC`–`$09ED`) — dialogue, BG3 mode, stat refresh, HUD disable
- **DMA control** (`$00AC`–`$00B2`, `$0800`) — VRAM DMA parameters, skip flag
- **VRAM cache ring buffer** (`$7F:4000`–`$7F:BFFF`) — 32 KB tile-strip content cache
- **Sine lookup tables** (`$7E:8900`–`$7E:8CFF`) — double-buffered precomputed sine

---

## 6. Sources

| Source | Role |
|--------|------|
| `gaia-source/docs/code/bank00/*.md` | Bank $00 system core, NMI, COP dispatch, actors, thinkers, camera/scroll documentation |
| `gaia-source/docs/code/bank02/*.md` | Bank $02 hardware init, scene engine, player character, movement physics, inventory documentation |
| `gaia-source/src/system/engine/*.asm` | Live extracted ASM — ground truth for WRAM address usage |
| `gaia-source/src/actors/player/*.asm` | Player actor ASM — slope physics, attack system, dark space palette |
| `gaia-source/us/names.json` | 721 (bank $00) + 477 (bank $02) named address entries |
| `gaia-source/us/blocks.json` | Block/part structure definitions |
| `gaia-source/us/overrides.json` | Per-address register state corrections |
| [DataCrystal RAM map](https://datacrystal.tcrf.net/wiki/Illusion_of_Gaia/RAM_map) | External RAM map — validated against |
| [DataCrystal Notes](https://datacrystal.tcrf.net/wiki/Illusion_of_Gaia/Notes) | External actor/thinker documentation — validated against |

---

*Generated from deep analysis of the complete Illusion of Gaia US ROM.*
*Cross-referenced against DataCrystal community documentation.*
*Last updated: 2026-09-08*
