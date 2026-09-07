# Bank $00 — Data Tables, Variable Map, Stack Usage & Statistics

**Bank:** `$00` (mirrored at `$80` for FastROM access)  
**Scope:** All of bank `$00` — system core (`$008000`–`$00B530`), upper-half actors/thinkers/functions (`$00B500`–`$00F4FF`), stair/climb system (`$00D088`–`$00D5BC`), and camera/follow engine (`$00E683`–`$00F292`)  
**Sources:** [`chunk_008000-analysis.md`](../chunk_008000-analysis.md), [`bank00-upper-analysis.md`](../bank00-upper-analysis.md), live `extracted/` ASM, `us/names.json`, `us/blocks.json`

This document consolidates **data tables**, **compile-time includes**, **WRAM/direct-page memory maps**, **stack conventions**, and **bank-wide statistics** for Illusion of Gaia's primary system bank.

**Related topic docs:** [`system-core.md`](system-core.md), [`cop-dispatch.md`](cop-dispatch.md), [`actor-management.md`](actor-management.md), [`utility-math-movement.md`](utility-math-movement.md), [`../cop-commands-reference.md`](../../cop-commands-reference.md)

---

## Table of Contents

1. [Data Tables](#1-data-tables)
2. [Includes & Hardware Constants](#2-includes--hardware-constants)
3. [Variable / Memory Map](#3-variable--memory-map)
4. [Stack Usage Summary](#4-stack-usage-summary)
5. [Statistics](#5-statistics)

---

## 1. Data Tables

Bank `$00` embeds dispatch jump tables, bitmasks, interpolation curves, and co-located lookup data referenced by COP handlers, movement systems, and scene actors. Tables marked *(include)* live in other ROM banks but are pulled in at assemble time via `?INCLUDE`.

### 1.1 Master Table Index

| Name | Address | ASM Label | Size | Purpose |
|------|---------|-----------|------|---------|
| `cop_dispatch_table` | `$008485` | `code_list_008485` | 220 bytes (110 entries) | Primary COP dispatch jump table ($00–$6D) |
| *(gap)* | `$008561` | — | 36 bytes (18 entries) | Invalid/garbage entries ($6E–$7F range, all `#0000`) |
| *(extended)* | `$008585` | — | 198 bytes (99 entries) | Extended COP dispatch table ($80–$E2) |
| `cop_table_sentinel` | `$00864B` | `byte_00864B` | 3 bytes | Sentinel: `EA 80 FD` |
| `wram_fill_constant` | `$00846C` | `byte_00846C` | 1 byte (`$E0`) | WRAM fill constant (unused) |
| `bitmasks_bit_position` | `$00B11D` | `bitmasks_00B11D` | 8 bytes | `$01,$02,$04,$08,$10,$20,$40,$80` |
| `body_table` | *(include)* | `body_table` | Variable | Player body sprite-set index (Will/Freedan/Shadow) |
| `table_01B086` | *(include)* | `table_01B086` | Variable | Animation frame duration/speed lookup |
| `binary_01C384` | *(include)* | `binary_01C384` | Variable | Sine/cosine lookup data for HUD init |
| `binary_01C455` | *(include)* | `binary_01C455` | 256 bytes | Sine table for HDMA wave effects |
| `binary_01D8BE` | *(include)* | `binary_01D8BE` | Variable | DMA channel configuration bytes |
| `FollowDirectionTable` | `$00EF72` | `code_list_00EF72` | 32 bytes | 16-direction smooth follow sprite handler jump table |
| `SmoothFollowLookup` | `$00F193` | `binary_00F193` | 544 bytes | Interpolation table for smooth movement deceleration |
| `binary_00D068` | `$00D068` | `binary_00D068` | 32 bytes | Camera drift direction offset data |
| `reward_table_01AADE` | *(include)* | `reward_table_01AADE` | Variable | Red jewel reward tier lookup |
| `table_00C710` | `$00C710` | `table_00C710` | 8 bytes | Player script variant pointer table (4 entries) |
| `code_list_00C733` | `$00C733` | `code_list_00C733` | 16 bytes | NPC wander direction handler jump table |
| `code_list_00E8C7` | `$00E8C7` | `code_list_00E8C7` | 16 bytes | Follow fallback direction dispatch (8 entries) |
| `array_00C943` | `$00C943` | `array_00C943` | Variable | Escort follow path direction deltas |
| `array_00DFFD` | `$00DFFD` | `array_00DFFD` | Variable | Enemy reward chest spawn parameters |
| `unk19_00CE97` | `$00CE97` | `unk19_00CE97` | 18 bytes | Statue inventory 6×3-byte slot table |

### 1.2 COP Dispatch Tables (`$008485`–`$00864D`)

The COP engine at `CopDispatch` (`$00846D`) reads the opcode byte, doubles it (`ASL`), and indexes a word-aligned jump table. The layout spans three contiguous regions:

| Region | Opcode Range | Entries | Notes |
|--------|--------------|---------|-------|
| Primary | `$00`–`6D` | 110 | One handler per even index; 96 live handlers |
| Gap | `$6E`–`7F` | 18 | All `#0000` — invalid opcodes trap to address `$0000` |
| Extended | `$80`–`E2` | 99 | Sprite staging, palette, HDMA, spawn, death — 76 live handlers |

**Dispatch algorithm:**

1. Save actor ID: `TXY`
2. Extract return bank: `LDA $04,S → $0C`
3. Compute arg pointer: `LDA $02,S`, `DEC` → `$0A` (points at opcode byte)
4. Read opcode, `INC $0A`, `AND #$00FF`, `ASL`, `TAX`
5. `JMP ($&cop_dispatch_table, X)`

**Sentinel (`$00864B`):** Three bytes `EA 80 FD` terminate the extended table region — not a valid jump target during normal dispatch.

### 1.3 Event Flag Bitmasks (`$00B11D`)

Eight single-byte masks used by the entire flag subsystem (`SetEventFlag`, `TestEventFlag`, `SetWramFlag`, etc.):

```
$01, $02, $04, $08, $10, $20, $40, $80
```

Index computation: `byte_offset = index >> 3`, `bitmask = bitmasks[index & 7]`.

### 1.4 Movement & Camera Tables

#### `FollowDirectionTable` (`$00EF72`) — 32 bytes

16 × 2-byte same-bank pointers (`$&`) into direction sprite handlers at `code_00EF92`–`code_00F172`. Indexed by `$7F000E,X & $0F` after the smooth-follow engine resolves a 16-way direction (22.5° steps). Each handler sets OAM priority/mirror bits and computes walking sprite index + angular step.

#### `SmoothFollowLookup` (`$00F193`) — 544 bytes

Binary interpolation table consumed by `ComputeFollowStep` (`$00EE1C`). Format: pairs of signed 16-bit values indexed by `(angle × sub-step)`. Low indices hold values near `$0100` (1.0 fixed-point); magnitudes taper toward `$0000` at high indices, producing smooth deceleration curves for NPC/platform homing.

#### `code_list_00E8C7` — 16 bytes

8-entry fallback dispatch table used by `SelectFallbackDirection` (`$00E8BA`). When the computed direction indicates the target was already reached, a `COP [SwitchCase]` on the low 3 bits routes back to the correct directional handler midpoint.

#### `binary_00D068` — 32 bytes

Eight direction delta pairs (16-bit X/Y offsets) for `CameraDriftPatterned` (`$00CFEF`). Used in boss arenas for scripted camera nudge patterns rather than pure RNG drift.

### 1.5 NPC & Player Script Tables

#### `table_00C710` — 8 bytes (4 entries)

Player COP script variant pointer table read by `InitPlayerScriptVariant` (`$00C6E4`). Selects among four player state-machine entry points based on body form and scene context (~15 scene callers).

#### `code_list_00C733` — 16 bytes

8-direction jump table for `NpcRandomWanderAI` (`$00C725`). Each entry points to a direction-specific wander handler that applies velocity and collision checks.

#### `array_00C943` — Variable

Ring-buffer direction delta table for `EscortFollowPathTracker` (`$00C806`). Stores 9 XY waypoint pairs for party escort pathfinding (Kara/party follow sequences).

#### `array_00DFFD` — Variable

Spawn parameter table for `EnemyRewardChestSystem` (`$00DF29`). Six chest variant handlers index weighted reward types, HP/DEF bonus chests, and item-drop routing.

### 1.6 Include Tables (External ROM Data)

| Include | Bank | Referenced By | Purpose |
|---------|------|---------------|---------|
| `body_table` | `$01` | `SetActorBody`, player sprite COPs | 6 bytes × N entries: sprite pointer triplets for Will/Freedan/Shadow bodies |
| `table_01B086` | `$01` | `AnimFrameLookup`, forced walks, sprite staging | Animation frame duration/speed; indexed as `A << 1` |
| `binary_01C384` | `$01` | `SystemInit` HUD pointer init | Sine/cosine pairs → copied to `$09BA`–`$09C4` at boot |
| `binary_01C455` | `$01` | `BuildSineHdmaTable`, `BuildSineLookupTable`, orbital math | 256-byte sine wave for HDMA displacement and `$7E8900`/`$7E8B00` precompute |
| `binary_01D8BE` | `$01` | HDMA queue COPs, DMA setup thinkers | Per-channel HDMA register template bytes |
| `reward_table_01AADE` | `$01` | `red_jewel_reward_handler` | Scene-indexed HP/STR/DEF reward tier bytes |

### 1.7 Inventory & Statue Tables

#### `unk19_00CE97` — 18 bytes

6 × 3-byte records in `statue_inventory_reward` (`$00CD59`):

| Byte | Meaning |
|------|---------|
| 0 | Statue slot index |
| 1 | Event flag byte offset (high) |
| 2 | Event flag bit index |

Shared via `?INCLUDE` with `inventory_statue_slot` (`$00CF29`) for the inventory menu display at scene `$FF`.

### 1.8 WRAM Fill Constant (`$00846C`)

Single byte `$E0` referenced only by the unreferenced `FillWramBlock` (`$008438`) routine, which would DMA-fill 512 bytes at WRAM `$000422`. Likely a cut debug feature.

---

## 2. Includes & Hardware Constants

### 2.1 Compile-Time Includes (`?INCLUDE`)

All `?INCLUDE` directives observed in bank `$00` system and upper-half code:

| Include | Purpose |
|---------|---------|
| `binary_01C384` | Sine/cosine lookup data (HUD pointer init in `SystemInit`) |
| `binary_01D8BE` | DMA channel configuration bytes |
| `body_table` | Player body sprite-set index table (Will/Freedan/Shadow) |
| `chunk_028000` | Bank `$02` system functions (rendering, DMA, APU, actors, math) |
| `chunk_038000` | Bank `$03` system functions (scenes, actors, text, metatiles) |
| `chunk_03BAE1` | Bank `$03` extended (music, facing, animation helpers) |
| `func_00F3C9` | Orbital/spiral movement math (`ApplyOrbitalOffsetFromRef`) |
| `func_0AA3A7` | Grid-snap walk helper (deferred resume target, bank `$0A`) |
| `system_strings` | System ASCII strings (BG3 HUD overlays) |
| `table_01B086` | Animation frame duration/speed lookup table |

**Additional includes in upper-half blocks** (not in system core chunk):

| Include | Used By |
|---------|---------|
| `player_character` | Stair triggers (`chunk_00D088`), `ramps.asm`, `itory_village_fog` thinker |
| `chunk_03BAE1` | Push handlers, `global_ambient_dispatcher`, statue inventory |
| `cop_handlers_script` | Statue inventory reward actors |
| `inventory_spritemap` | Inventory statue slot display |
| `dir_sprite_01ABDE` | Forced walk functions, smooth follow |
| `table_01A95E` | Forced walk camera pan speed lookup |
| `smooth_follow` | `smooth_follow_child` actor |
| `reward_table_01AADE` | Red jewel reward handler |

### 2.2 Hardware Register Aliases

Bank `$00` uses the SNES hardware multiplier/divider for movement, sine HDMA, and subpixel math. These aliases map to WRIO registers in bank `$80`:

| Alias | SNES Register | Address | Use in Bank `$00` |
|-------|---------------|---------|-------------------|
| `L_WRMPYB` | `WRMPYB` | `$804203` | 8×8 multiply — B operand (multiplicand high byte) |
| `L_WRDIVL` | `WRDIVL` | `$804204` | Hardware divide — dividend low word |
| `L_WRDIVB` | `WRDIVB` | `$804206` | Hardware divide — divisor byte |
| `L_RDDIVL` | `RDDIVL` | `$804214` | Division quotient read (after pipeline delay) |
| `L_RDMPYL` | `RDMPYL` | `$804216` | Multiply product low byte read |
| `L_RDMPYH` | `RDMPYH` | `$804217` | Multiply product high byte read |

**Pipeline delays:** `ReadMultiplyResult` (`$008D25`) uses 1 NOP (8 cycles); `ReadDivideResult` (`$008D2A`) uses 5 NOPs before reading `$RDDIVL`. `MovementVelocityCompute` (`$008FDC`) uses an extended divide delay for velocity tick calculations.

---

## 3. Variable / Memory Map

Illusion of Gaia's actor system uses a **64-byte direct-page slot per actor** (ID = slot base address, e.g. `$1FC0`) plus **WRAM extended fields** indexed by `(actor_id − $1000), X`. Global game state lives in WRAM `$0036`–`$0FFF` (direct page `$0000` when `D=$0000`).

### 3.1 Direct Page (Actor-Relative) Variables

When `TCD` points at an actor slot, offsets `$00`–`$3F` address that actor's script control block. The table below covers `$00`–`$36` (55 bytes of the 64-byte slot):

| Address | Size | Name | Used By |
|---------|------|------|---------|
| `$00`/`$02` | 4 | **EntryPtr + bank** | Script entry address (word) + script bank byte; COP continue/branch writes `$02,S` |
| `$04` | 2 | **Prev actor link** | Doubly-linked list predecessor ID; spawn, unlink, follow sibling copy |
| `$06` | 2 | **Next actor link** | Doubly-linked list successor ID |
| `$08` | 2 | **Wait counter** | Frame wait/yield/halt; zeroed on spawn and climb lock |
| `$0A`/`$0C` | 4 | **ArgPtr + script bank** | COP dispatch engine: points past opcode byte; `$0C` = return bank |
| `$0E` | 2 | **OAM XOR flags** | Sprite priority, palette line, H/V flip XOR mask |
| `$10` | 2 | **Actor flags word 1** | Collision priority, offscreen, spawned (`$2000`), player-hit (`$0008`), invisible (`$2200`) |
| `$12` | 2 | **Actor flags word 2** | Force-flip, marked-child parent (`$0040`), interact (`$1000`), push-in-progress (`$0010`) |
| `$14` | 2 | **Position X** (pixels) | All movement, collision, camera, climb, push handlers |
| `$16` | 2 | **Position Y** (pixels) | All movement, collision, camera, climb, push handlers |
| `$18` | 2 | **Scratch / probe X** | Tile coords, collision query, direction-to-player target |
| `$1A` | 2 | **Scratch X2 / tile width** | Map stream pixel coords (`ParseMapEntry`); collision rect width counter |
| `$1C` | 2 | **Scratch / probe Y** | Tile coords, collision query, map Y iteration |
| `$1E` | 2 | **Scratch Y2 / tile height** | Map stream pixel coords; collision rect height counter |
| `$20` | 2 | **Rearrange / misc index** | OAM rearrange slot; copied on spawn (`CopyActorState` → `$7F0020,X`) |
| `$22` | 2 | *(reserved / script scratch)* | Occasional COP arg staging |
| `$24` | 2 | **Step counter / target actor index** | Movement direction index, escort target, player actor ref in follow engine |
| `$26` | 2 | **Scroll accumulator Y** | `ScrollCameraAccumulate` actor — feeds `$06C4` camera delta |
| `$28` | 2 | **Sprite set / facing index** | Animation staging, stair trigger facing validation, forceball anim range check |
| `$2A` | 2 | **Animation frame** | Current frame index; cleared by `ProcessAnimFlag`, forced walks |
| `$2C` | 2 | **Velocity X / force X** | Per-frame movement; zeroed on climb lock and hitstun |
| `$2E` | 2 | **Velocity Y / force Y** | Per-frame movement; anim speed in forced walks (`ReadDirSprite_*`) |
| `$30` | 2 | **Actor index high byte scratch** | `ResolveActorIndex` swaps high byte for list lookup |
| `$32` | 2 | *(script scratch)* | Temporary staging in wander/push handlers |
| `$34` | 2 | *(script scratch)* | Temporary staging in COP handlers |
| `$36` | 2 | **Frame parity counter** | Global when `D=$0000`: NMI increments; sine HDMA double-buffer select |

> **Note:** Offsets `$37`–`$3F` exist within the 64-byte slot but are rarely referenced directly; extended state lives in WRAM `$7F0000+`.

### 3.2 WRAM Extended Actor Fields

Extended fields use `(actor_id − $1000)` as the X index into WRAM `$7F0000+`. Standard actors use `$7F0000,X`–`$7F002E,X`; callback blocks at `$7F1000+`; actor-type loop state at `$7F2100+`.

| Address | Size | Name | Used By |
|---------|------|------|---------|
| `$7F0000,X` | 1 | Movement sub-pixel accumulator X | `MoveToward`, `TickMove`, `MultiplyThenDivide` |
| `$7F0001,X` | 1 | Movement sub-pixel accumulator Y | Same as above |
| `$7F0002,X` | 1 | Animation/step sub-counter | `InitSmoothMovement`, `StageMove`, palette thinkers |
| `$7F0003,X` | 1 | Extra frame counter | `TickMove` velocity pipeline |
| `$7F0004,X` | 2 | SavedPtr / deferred callback | Script control, resume-after-wait |
| `$7F0006,X` | 2 | Sprite set pointer (low) | `SetMetasprite`, `SetActorBody`, sine amplitude |
| `$7F0008,X` | 2 | Sprite bank / move state byte | Map header bank; `$8F` = walking (stair `CheckMoveState`) |
| `$7F000A,X` | 2 | Movement sub-steps / interact handler | Smooth follow param; halving counter |
| `$7F000E,X` | 2 | Direction / step total | Movement handlers; `$FFFF` = follow reset |
| `$7F0010,X` | 1 | Sound effect to play | WorldMapStream SFX COP |
| `$7F0010,X` | 2 | Angular step / follow angle *(overlap by context)* | Smooth follow engine, hitstun distance |
| `$7F0012,X` | 2 | Orbit angle / sub-step accumulator | `InitSpiral`, `SpiralStep`, `ComputeFollowStep` |
| `$7F0014,X` | 2 | Loop counter (thinker) / sibling sprite index | `LoopInit`; `CopySiblingFollowState` |
| `$7F0016,X` | 2 | Loop counter (animation) | `AnimLoop` COP |
| `$7F0018,X` | 2 | Target distance X / anim X move | `InitSmoothMovement`, movement COPs |
| `$7F001A,X` | 2 | Target distance Y / anim Y move | `InitSmoothMovement`, movement COPs |
| `$7F001C,X` | 2 | **Parent actor ID** | Marked children; batch death in `DieNow_UnlinkChildren` |
| `$7F001E,X` | 2 | Loop start PC (thinker-type) | `LoopInit` / `LoopDecrement` |
| `$7F0020,X` | 2 | Rearrange index / climb frame counter | `CopyActorState`; stair `LockPlayerForClimb` |
| `$7F0022,X` | 2 | Dungeon monster ID | `SetDungeonKillFlag` COP |
| `$7F002A,X` | 2 | **Extended flags** | Bit 1 = moving; bit `$0020` = hitstun skip; `SetActorFlags`/`ClearActorFlags` |
| `$7F002C,X` | 2 | Computed velocity X | `MoveToward`, `ApplyFollowMovement` |
| `$7F002E,X` | 2 | Computed velocity Y | `MoveToward`, `ApplyFollowMovement` |
| `$7F1000,X` | 2 | OnHit callback | `SetOnHit` COP |
| `$7F1002,X` | 2 | OnDodge callback | `SetOnDodge` COP |
| `$7F1004,X` | 4 | OnDeath callback + bank | `SetOnDeath` COP |
| `$7F1008,X` | 2 | OnCollide callback | `SetOnCollide` COP |
| `$7F1010,X` | 2 | Gravity accel / orbit diameter | `InitGravity`, `InitSpiral` |
| `$7F1012,X` | 2 | Gravity speed / orbit angle | `InitGravity`, `InitSpiral` |
| `$7F1014,X` | 2 | Gravity state | `TickGravity` COP |
| `$7F1016,X` | 2 | Callback `$5E` | `SetCallback5E` COP |
| `$7F1018,X` | 2 | Snap resume PC | `SnapToGrid` COP |
| `$7F101A,X` | 2 | Snap resume bank | `SnapToGrid` COP |
| `$7F101C,X` | 2 | Cleared on spawn | `CopyActorState` zero-fill |
| `$7F101E,X` | 2 | Cleared on spawn | `CopyActorState` zero-fill |
| `$7F2100,X` | 2 | Loop start PC (actor-type) | `LoopInit` when actor ID < `$1000` |
| `$7F2102,X` | 2 | Loop counter (actor-type) | `LoopInit` / `LoopDecrement` |

### 3.3 Global State Variables

Global variables use direct-page addressing with `D=$0000` (or absolute `$xxxx` when DBR=$81). Grouped by functional region:

#### System & Actor List Management

| Address | Size | Name | Used By |
|---------|------|------|---------|
| `$0036` | 2 | Frame counter (parity) | NMI handler, HUD, sine HDMA double-buffer |
| `$004E` | 2 | Free pool pointer | `ActorPoolAllocator`, `ReturnActorSlot` |
| `$0052` | 2 | Thinker list count | `KillThinker` COP |
| `$0056` | 2 | Actor list head (before-pool) | `AllocateActorBefore`, `UnlinkActor` |
| `$0058` | 2 | Actor list head (after-pool) | `AllocateActorAfter`, `UnlinkActor` |
| `$005A` | 2 | Thinker prev head | `KillThinker` |
| `$005C` | 2 | Thinker list head | `AllocateSpecialActor` |
| `$0066` | 1 | HDMA channel enable mask | NMI handler, HDMA COPs |
| `$00D8` | 2 | OAM write offset | Main loop, frame updates, OAM sentinel |
| `$00E4` | 2 | Actor limit threshold | `HaltIfActorLimitHit` COP |
| `$0DBC` | 2 | Active actor count | `ActorPoolAllocator`, `ReturnActorSlot` |

#### Timers & RNG

| Address | Size | Name | Used By |
|---------|------|------|---------|
| `$040C` | 2 | Invincibility timer | `UpdateFrameCounters` (decrements to −1) |
| `$040E` | 2 | Global frame timer | `UpdateFrameCounters` (increments to `$0100`) |
| `$040F`–`$041E` | 16 | RNG state | `RngByte` COP |
| `$0420` | 2 | RNG modulo result | `RngMod` COP |

#### Input & Display Flags

| Address | Size | Name | Used By |
|---------|------|------|---------|
| `$0654` | 2 | World-ready flag | Dialogue gate (`≠ $000F`) |
| `$0656` | 2 | Filtered joypad state | Button COPs, `global_ambient_dispatcher` |
| `$0658` | 2 | Display flags | Bit `$8000` set after climb unlock |
| `$0660` | 2 | Raw joypad state | NMI read (`$JOY1L`), button COPs |
| `$0800` | 1 | DMA skip flag | NMI tilemap DMA bypass |
| `$09EC` | 2 | Display mode flags | HUD, NMI BG3 mode, sine precompute, dialogue |
| `$09ED` | 1 | HUD disable flag (bit `$40`) | `UpdateHUD` early exit |
| `$09E0` | 2 | Climb state data | Cleared by `UnlockPlayerAfterClimb` |

#### Audio Handshake

| Address | Size | Name | Used By |
|---------|------|------|---------|
| `$06F8` | 2 | SFX channel 1 queue | `PlaySoundCh1`, NMI → `$APUIO2` |
| `$06F9` | 1 | SFX channel 2 queue | `PlaySoundCh2` |
| `$06FA` | 2 | Music transition state | NMI → triggers `UpdateFrame_Full` when ≠ 0 |

#### Camera & Scroll

| Address | Size | Name | Used By |
|---------|------|------|---------|
| `$068A`–`$068F` | 6 | BG1 scroll values (H/V × layers) | `UploadScrollRegisters`, `WriteBgScroll` |
| `$0690` | 2 | Saved camera delta | `ScrollCameraInit` |
| `$0693` | 1 | Map row stride | `AdvanceMapY` collision iterator |
| `$06BE` | 2 | Camera target X | Camera pan COPs, `ComputeScrollDeltas` |
| `$06C0` | 2 | Camera delta X | Scroll actors, forced walks |
| `$06C2` | 2 | Camera target Y | Camera pan COPs, `ComputeScrollDeltas` |
| `$06C4` | 2 | Camera delta Y | Scroll actors, `ScrollCameraVertical` |
| `$06C6`–`$06CB` | 6 | BG scroll override values | `WriteBgScroll` (negative = use override) |
| `$06C8` | 2 | Forced scroll override | `ScrollCameraInit`, effect velocity init |
| `$06DE` | 2 | Map Y upper bound | `TileCollisionQuery` |
| `$06E0` | 2 | Scroll step table base | `CameraScrollStepLookup`, forced walks |
| `$06E2` | 2 | Scroll step index | `CameraScrollStepLookup` |
| `$06EE` | 1 | Layer priority flag | `UploadScrollRegisters` (sign = BG2 first) |
| `$06EF` | 1 | Scroll mode flags (bit 3 = locked) | `UploadScrollRegisters` |
| `$06E4`/`$06E6` | 2 each | Effect subpixel remainder | Visual effect pipeline integration |

#### HUD & Player Stats

| Address | Size | Name | Used By |
|---------|------|------|---------|
| `$09AF` | 2 | HUD helper | `UpdateHUD` |
| `$09BA`–`$09C4` | 11 | HUD sine/pointer table | `SystemInit` from `binary_01C384` |
| `$09C8`/`$09CA` | 4 | HUD related pointers | System init |
| `$09E4`/`$09E6` | 4 | Experience values | HUD XP display |
| `$09EA` | 2 | Experience pending flag | HUD XP popup trigger |
| `$0ACE`/`$0ACA` | 4 | Current/max DEF display | HUD damage flash |
| `$0AD0`/`$0ACC`/`$0ADA` | 6 | Previous stat cache (DEF/HP/gem) | HUD change detection |
| `$0AD4` | 2 | Current body index | `SetActorBody`, body swap COPs |
| `$0AD6`/`$0AD8` | 4 | Gem count / hundreds digit | HUD gem display |
| `$0ADC`/`$0ADE` | 4 | DEF / STR display bases | HUD, stat reward actors |
| `$0AE4` | 2 | Experience display timer | HUD (`$001E` frame countdown) |
| `$0B22` | 2 | Damage flash timer | HUD (every 8 frames) |
| `$09B0` | 2 | Wall type for player anim | Player wall-gated animation COPs |
| `$0AFA` | 2 | Inventory highlight state | Statue inventory slot display |

#### Event & WRAM Flags

| Address | Size | Name | Used By |
|---------|------|------|---------|
| `$0A00`+ | 256 | Event flag bitfield | `SetEventFlag`, `TestEventFlag`, all flag COPs |
| `$0A80`+ | 32 | WRAM flag bitfield | Kill flags, dungeon state, jewel reward dup-check |

#### DMA & Tile Query (Direct Page when `D=$0000`)

| Address | Size | Name | Used By |
|---------|------|------|---------|
| `$00AC`/`$00AE` | 4 | DMA source address + bank | `ExecuteVramDma`, `AdhocVramDma` COP |
| `$00B0` | 2 | VRAM destination word address | `ExecuteVramDma` |
| `$00B2` | 2 | DMA transfer size | `ExecuteVramDma` (0 = no transfer) |
| `$0902` | 2 | Tile query result / VRAM addr | Metatile helpers, `TileQueryGate` |
| `$0904`–`$090C` | 8 | Tile graphics entries | `ResolveTileData` |

#### WRAM Extended (Non-Actor)

| Address | Size | Name | Used By |
|---------|------|------|---------|
| `$7F0C03`–`$7F0C09` | 8 | Adhoc VRAM DMA params | `AdhocVramDma` COP |
| `$7F3100/01`+ | 2 | OAM compose buffer | Main loop sentinel `$FF` at `$00D8` offset |

#### Save / Scene State (referenced from upper-half)

| Address | Size | Name | Used By |
|---------|------|------|---------|
| `$000100` | 1 | SRAM magic byte (`$83` = valid) | `SystemInit` save check |
| `$0AF0`–`$0AF8` | 16 | Scene save data | `GameOverSequence` reload |
| `$0B28`–`$0B32` | 11 | Save/warp metadata | System init |

---

## 4. Stack Usage Summary

Bank `$00` code follows consistent stack conventions across interrupt handlers, COP bytecode handlers, and utility subroutines. COP handlers run inside an **emulated RTI frame** created by the COP instruction itself.

### 4.1 Stack Depth by Context

| Context | Max Depth | Notes |
|---------|-----------|-------|
| NMI Handler | 12 bytes | 6 pushes: `PHP`, `PHB`, `PHA`, `PHX`, `PHY` + `CLD` |
| COP Handler (simple) | 0 extra | Modifies existing frame via `STA $02,S` |
| COP Handler + D=0 | 2 bytes | `PHD`/`PLD` for zero direct page |
| COP Handler + spawn | 4–6 bytes | `PHD`+`PHX` or `PHY`+`PHD` |
| Frame update functions | 14 bytes | Full: `PHB`, `PHA`, `XBA`, `PHA`, `PHX`, `PHY`, `PHD` |
| Movement handlers | 4 bytes | `PHA`×2 for velocity temp; exit via `PLA PLA RTL` |

### 4.2 Common Stack Patterns

| # | Pattern | Instructions | Meaning |
|---|---------|--------------|---------|
| 1 | **COP Continue** | `LDA $0A; STA $02,S; RTI` | Advance to next COP instruction (overwrite return PC on stack) |
| 2 | **COP Branch** | `LDA [$0A]; STA $02,S; RTI` | Indirect branch — load target address from script stream |
| 3 | **COP Halt** | `PLA; PLA; RTL` | Discard COP return frame; yield until next frame |
| 4 | **Context save** | `PHB; PHA; XBA; PHA; PHX; PHY; PHD` | 7 pushes = 14 bytes; used by frame update variants |
| 5 | **Bank switch** | `PHA; PLB` | Save old DBR on stack, load new bank from A |
| 6 | **Zero DP** | `PHD; LDA #$0000; TCD … PLD` | Temporary direct page at `$0000` for pool/global access |

### 4.3 COP Handler Exit Conventions

| Exit | Method | Meaning |
|------|--------|---------|
| **Continue** | Pattern 1 | Execute next COP instruction same frame |
| **Branch** | Pattern 2 | Jump to new script address |
| **Halt/Yield** | Store `$0A`→`$00`; Pattern 3 | Return to engine; resume next frame |
| **Kill** | Unlink actor; `RTL` | Actor removed from list |

### 4.4 Entry State (Guaranteed for All COP Handlers)

| Register | Value |
|----------|-------|
| `A` | Clobbered (opcode×2 during dispatch) |
| `X` | Opcode table index during dispatch; actor ID in Y |
| `Y` | Actor ID (saved from dispatch) |
| `$0A` | Pointer to first argument byte |
| `$0C` | Script bank byte |
| `m` | 0 (16-bit A) |
| `x` | 0 (16-bit X/Y) |
| `D` | Actor direct page base |
| `DBR` | `$81` |

---

## 5. Statistics

### 5.1 Code Distribution (Full Bank `$00`)

| Category | Count | Approx. Size |
|----------|-------|-------------|
| Interrupt vectors/trampolines | 5 | 20 bytes |
| System init + main loop | 1 | 166 bytes |
| Frame update functions | 4 | ~330 bytes |
| NMI handler + DMA helpers | 5 | ~320 bytes |
| COP dispatch + tables | 4 | ~484 bytes |
| COP handlers (primary $00–$6D) | 96 | ~5,800 bytes |
| COP handlers (extended $80–$E2) | 76 | ~3,400 bytes |
| Utility subroutines | 28 | ~1,500 bytes |
| Far-call functions (`func_*`) | 16 | ~400 bytes |
| Shared code blocks (`code_*`) | 5 | ~200 bytes |
| Data tables (in-bank) | 6 | ~470 bytes |
| Thinkers | 49 | ~3,500 bytes |
| Actors | 26 | ~4,000 bytes |
| Functions (upper half) | 29 | ~3,000 bytes |
| Stair/climb system | 13 | ~1,336 bytes |
| Camera/scroll system | 22 | ~3,376 bytes |
| **Total** | **~380+ routines** | **~28,000+ bytes** |

#### System Core Sub-Breakdown (`$008000`–`$00B530`)

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

### 5.2 Named Entries

| Metric | Value |
|--------|-------|
| **Total in `us/names.json`** | **721** entries |
| System core cataloged | 68 entries |
| Upper-half additions (2026-09-06) | 104 entries |
| COP handler reference | [`cop-commands-reference.md`](../../cop-commands-reference.md) + `us/copdef.json` |

### 5.3 External Dependencies

| Bank | Unique Functions Called | Purpose |
|------|-------------------------|---------|
| `$02` | 17 | Rendering, DMA, actors, decompression, math |
| `$03` | 27 | Scenes, actors, text, metatiles, inventory, collision, HDMA |
| `$00` (other chunks) | 2 | Orbital math (`func_00F3C9`), grid-snap (`func_0AA3A7`) |
| `$0A` | 1 | Grid-snap resume target |

#### Key External Calls from System Core

| Function | Bank | Called From | Purpose |
|----------|------|-------------|---------|
| `func_028043` | $02 | Main loop, frame updates | Begin frame |
| `func_028191` | $02 | Main loop, frame updates | End frame / wait VBlank |
| `func_0281A2` | $02 | Main loop, frame updates | Scene transitions |
| `func_029F31` | $02 | SystemInit | PPU register init |
| `func_02908E` | $02 | SystemInit | Init WRAM/game state |
| `func_02AF5F` | $02 | NmiHandler | Upload OAM |
| `func_03D9F6` | $03 | SystemInit | Load initial scene |
| `run_actors_03CAF5` | $03 | Main loop | Execute all actor scripts |
| `func_03C5FF` | $03 | Main loop | OAM sort/compose |
| `func_03E146` | $03 | Main loop | Update HDMA channels |
| `func_03CA55` | $03 | Animation COPs | Advance animation frame |
| `func_03D78A` | $03 | TileCollisionQuery | Map tile lookup |

### 5.4 Upper Half Block Breakdown

| Category | Total | Named | Auto-Named | Unused |
|----------|-------|-------|------------|--------|
| Thinkers | 49 | 1 (`parallax_thinker`) | 48 | 7 |
| Actors | 26 | 11 | 15 | 1 |
| Functions | 29 | 2 | 22 active + 5 unused | 5 |

#### Address Distribution (Upper Half)

| Range | Count | Content |
|-------|-------|---------|
| `$00B500`–`$00BFFF` | 49 | Thinkers (palette, HDMA, DMA, screen config) |
| `$00C100`–`$00CFFF` | 20 | Actors (speed zones, dream, rewards, push) + functions (NPC AI, camera, menus) |
| `$00D600`–`$00DFFF` | 14 | Functions (game over, combat defeat, item drops, chest spawning) |
| `$00E100`–`$00EAFF` | 12 | Actors (push handlers, smooth follow, visual effects, camera) |
| `$00F300`–`$00F4FF` | 4 | Functions (player stop, orbital math) |

### 5.5 Most-Referenced Blocks (Top 10)

| Block | Ref Count | Primary Callers |
|-------|-----------|-----------------|
| `camera_scroll_controller` (`$00EAED`) | 100+ | Every field scene (actor slot #1/#2) |
| `scene_flag_init` (`$00C667`) | 80+ | Most scene templates (slot #3/#4) |
| `StandardEnemyDefeatHandler` (`$00DB8A`) | ~20 | All enemy actors via death callback pointer |
| `global_ambient_dispatcher` (`$00BF89`) | ~40 | Nearly every scene thinker set |
| `ApplyOrbitalOffsetFromRef` (`$00F3C9`) | ~15 | COP handlers, bosses, statue inventory, fire sprites |
| `NpcRandomWanderAI` (`$00C725`) | ~12 | Town NPC scripts |
| `ApplyPlayerHitstun` (`$00C397`) | ~12 | Combat enemies, damage sources |
| `ambient_palette_cycler` (`$00B520`) | ~30 | Paired with global dispatcher |
| `EnemyDeathFlash` (`$00DF15`) | ~10 | Enemy actors + defeat handler |
| `push_handler_solid` (`$00E256`) | ~9 | Statue/archer/knight push actors |

#### Most-Called Utility Subroutines (System Core)

| Subroutine | Address | Call Count | Primary Callers |
|------------|---------|------------|-----------------|
| `AnimFrameLookup` | $00B157 | 20+ | Sprite staging COPs, force-move COPs |
| `TileCollisionQuery` | $00B43B | 14 | Solidity branch COPs, player wall COPs |
| `AllocateActorAfter` | $00B189 | 14 | Spawn COPs, music/thinker COPs |
| `ProcessAnimFlag` | $009F5F | 12 | Sprite staging COPs, movement init |
| `TestEventFlag` | $00B0FB | 8 | Flag COPs, far-call wrappers |
| `SetActorBody` | $00AF6D | 8 | Player sprite COPs |

### 5.6 Engine Integration Points

| Bank `$00` Block | Connects To | Via |
|------------------|-------------|-----|
| `GameOverSequence` ($D62F) | `chunk_03BAE1` | `$&func_00D62F` player death pointer |
| `StandardEnemyDefeatHandler` ($DB8A) | `chunk_03BAE1` | `$&func_00DB8A` enemy defeat pointer |
| `NullActorScriptStub` ($DC77) | `chunk_03BAE1` | `$&stub_00DC77` default actor script |
| `player_transition_handlers` ($C418) | Scene scripts, bank $03 | `#$&func_00C4xx` player anim refs |
| `hit_stagger_controller` ($D877) | Bank $03 | `SpawnLastRel` from damage routines |
| `smooth_follow_child` ($E4DB) | `smooth_follow` chunk | `$&ComputeFollow*` same-bank refs |
| `ApplyOrbitalOffsetFromRef` ($F3C9) | System core | `?INCLUDE 'func_00F3C9'` from `$008000` chunk |

### 5.7 Scene Usage Highlights

| Actor/System | Scene Count | Areas |
|--------------|-------------|-------|
| `ScrollCameraTrack` | ~40+ | Nearly all towns and overworlds |
| `StairTriggerWest` | 12+ | Mu, Angel Village, Angkor Wat, Dracula Mansion |
| `StairTriggerEast` | 10+ | Mu, Angel Village, Angkor Wat temples |
| `ScrollCameraVertical` | ~10 | Edward's Castle, Itory, Incan Ruins, Dao |
| `ScrollCameraInit` | ~10 | Mt. Kress exclusively |
| `ScrollCameraAccumulate` | ~5 | Pyramid interiors |

---

*Consolidated from [`chunk_008000-analysis.md`](../chunk_008000-analysis.md) and [`bank00-upper-analysis.md`](../bank00-upper-analysis.md). Ground truth: `extracted/system/*.asm`, `us/names.json` (721 entries), `us/blocks.json`, `us/copdef.json`.*
