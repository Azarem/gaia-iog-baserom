# Bank $02 — Game World Systems

*Part of the [Bank $02 Documentation Suite](README.md)*

**Bank:** `$02` (FastROM; accessed via `$@` long calls from other banks)  
**Address range:** `$02A040`–`$02AB8A` (through `CameraFullRefresh`; see [Block Layout](#block-layout))  
**Source:** [`music_actors.asm`](../../../extracted/system/engine/music_actors.asm), [`DisplaySceneTitle.asm`](../../../extracted/system/engine/DisplaySceneTitle.asm), [`event_blocks.asm`](../../../extracted/system/engine/event_blocks.asm), [`warps_interaction.asm`](../../../extracted/system/engine/warps_interaction.asm)  
**Scene:** `engine`

**Related docs:** [hardware-and-init.md](hardware-and-init.md) · [scene-script.md](scene-script.md) · [spc-transfer.md](spc-transfer.md) · [camera-scrolling.md](camera-scrolling.md) · [map-coordinates.md](map-coordinates.md) · [../bank00/event-flags.md](../bank00/event-flags.md) · [../../cop/README.md](../../cop/README.md)

> **Evidence labels.** Each major section is tagged with the kind of claim it makes: **[ASM]** = directly observed in the extracted asm of this block; **[INFERRED]** = interpretation of behavior that is not literally encoded in the file; **[XREF]** = cross-file / engine-wide convention stated elsewhere (not provable from this file alone). Sections that mix kinds split them into separately tagged bullets or paragraphs. The `.asm` files in `extracted/` are authoritative; where prose and asm comments disagree, the asm wins.

## Overview

*Evidence: [ASM] + [INFERRED] + [XREF]*

Four ASM compilation units in bank `$02` implement **interactive world state** — glue between the scene script loader ([`scene_lifecycle.asm`](../../../extracted/system/engine/scene_lifecycle.asm), `ClearSceneState`), the per-frame main loop ([`system_core.asm`](../../../extracted/system/engine/system_core.asm)), and map changes driven by flags, warps, and chest records. Together they:

1. **Synchronize music and rendering** via COP actors that mask joypad input, poll `musicTransitionState` (`$06FA`) until it reaches `$FFFF`, run a one-shot render/dialogue child, and restore scene music through `SpcTransferMusicData`.
2. **Display the scene area name** in a centered dialogue box when `ClearSceneState` runs and `$0D6E` ≠ `sceneCurrent` (`$0644`).
3. **Apply persistent map tile copies** driven by event flags — bulk instant copies at scene load and animated copies with VRAM queue flushes via COP `#32` / `#33`.
4. **Detect warp rectangles and chest interactions** each frame (warps first), staging transition parameters or running the chest-open flow.

These routines sit above the hardware/VBlank layer in [hardware-and-init.md](hardware-and-init.md). Map coordinate helpers: [map-coordinates.md](map-coordinates.md) ([`map_coords.asm`](../../../extracted/system/engine/map_coords.asm)). Event flag semantics: [../bank00/event-flags.md](../bank00/event-flags.md).

### Interaction Lifecycle

*Evidence: [ASM] + [XREF]*

The four compilation units split into **scene-entry** setup (`ClearSceneState` in [`scene_lifecycle.asm`](../../../extracted/system/engine/scene_lifecycle.asm)) and **per-frame** work (`CheckWarpAndChest` from [`system_core.asm`](../../../extracted/system/engine/system_core.asm) after `CheckSceneTransition`, before `GlobalInputHandler` and `RunActors_Normal`):

| When | Routine | Role |
|------|---------|------|
| Scene load | `ApplyAllEventBlocks` | Scan 256 event-flag bits in `$0A20`–`$0A3F`; for each set bit, `LookupEventBlock` + `CopyEventBlockTiles` when the table entry matches `sceneCurrent` |
| Scene load | `PlaceOpenedChestTiles` | For set chest event flags, write the open-chest 2×2 tile pattern into `mapLayerTilemap` (`$7EA000`) |
| Scene load | `DisplaySceneTitle` | After `SpawnSceneActors`, show centered area name if `$0D6E` ≠ `sceneCurrent` |
| Scene load | `InitWarpTable` | Set `$00D4` / `$00D6` to standard and extended warp list pointers for `sceneTableIndex` (`$0646`) |
| Every frame | `CheckWarpAndChest` | `CheckWarpRectangles` first; if carry clear, `HandleChestInteraction` |
| On demand (COP) | `MusicJingleActor` | Mask joypad, wait for `$06FA` = `$FFFF`, `MusicRenderSync`, APU poll, restore scene music via second `SpcTransferMusicData` |

**Music actors** ([ASM]): mask `$FFFC` into `joypadMaskStd` (`$065A`), poll `musicTransitionState` until `$FFFF`, spawn `MusicRenderSync` with dialogue pointer `$20`/`$22`, poll `APUIO1` (`$2141`) for `$FF`, unmask joypad, spawn a second `SpcTransferMusicData` with `chatPtr` = saved `musicParentActor` (`$06F2`) in `orbitAngle`, then `WaitByte #01` and `MusicLoadCleanup` (clears `displayModeFlags` bit `$0080`). **DisplaySceneTitle** ([ASM]): one-shot during scene load; sets `$00B4` = `$E0` for the transition epilogue wait loop in `ExecuteSceneTransition` ([XREF]). **Event blocks** ([ASM]): source rectangle → destination rectangle copy (source WRAM unchanged); animated path queues metatile VRAM writes consumed by `FlushVramWriteQueue` in NMI. **Warps / chests** ([ASM]): rectangle tests; chest open requires D-pad up (`joypadCurrent` `$0656` bit `$0800`), not the A button mask alone.

### Block Layout

*Evidence: [ASM]*

```
$02A040 ┌─ MusicJingleActor ─────────────────────┐
        │  MusicRenderSync / IsMusicPlaying         │  music_actors
$02A11B ├─ DisplaySceneTitle ────────────────────────┤  DisplaySceneTitle
        │  scene_title_box_format / CountTitleGlyphs│
$02A1E9 ├─ ApplyAllEventBlocks ─────────────────────┤
        │  CopyEventBlockTiles / FlushVramWriteQueue│  event_blocks
        │  LookupEventBlock / AnimateEventBlock …   │
$02A5DD ├─ CheckWarpAndChest ───────────────────────┤
        │  PlaceOpenedChestTiles / HandleChestInteraction│  warps_interaction
        │  ChestOpeningActor … StartForcedWalk      │
$02AB8A └─ CameraFullRefresh (next unit) ───────────┘
```

## music_actors.asm

*Evidence: [ASM] + [XREF]*

COP actors and `IsMusicPlaying` coordinate **SPC music transfer timing** with dialogue display. COP `MusicAndText` (opcode `$19` in [`cop_handlers_audio.asm`](../../../extracted/system/engine/cop_handlers_audio.asm)) allocates a thinker aimed at `MusicJingleActor`, sets operand fields `$26` (track ID), `$20`/`$22` (dialogue pointer/bank), and flag `$1000` in `$12`. Callers typically set `displayModeFlags` bit `$0080` first so only actors with `$1000` in `$12` run ([XREF] `RunActors_DisplayFiltered`).

| Address | Name | Description |
|---------|------|-------------|
| `$02A040` | MusicJingleActor | Primary COP coroutine for `MusicAndText`. |
| `$02A0E5` | MusicRenderSync | One-shot child: delay, render frame, `DialogStringRenderer`. |
| `$02A10A` | IsMusicPlaying | `JSL` query: SEC if music active, else CLC. |

### MusicJingleActor

*Evidence: [ASM]*

On entry, saves `musicParentActor` (`$06F2`) to `orbitAngle` (`$7F0010,X`). Spawns `@hdma_dma_spc.SpcTransferMusicData` via `COP [SpawnAfterFlags]` with flag `$2000`; pool full (`CPY #$1FC0`) → `MusicLoadCleanup`.

After spawn: child `chatPtr` (`$7F000A`) = `$26 + 1`; child `$12` \|= `$1000`; parent masks joypad with `TSB $joypadMaskStd` using `#$FFFC` (bits 2–15); yields with `SetEntryHere` until `musicTransitionState` = `$FFFF`.

Then spawns `MusicRenderSync`, copies `$20`/`$22` to child, sets child `$12` \|= `$1000`, yields polling `APUIO1` low byte = `$FF`. On `$FF`: `TRB $joypadMaskStd` with `#$FFFC`; spawns second `SpcTransferMusicData` with `chatPtr` = saved `orbitAngle`; waits again for `$FFFF`; `COP [WaitByte] (#01)` (2 ticks); falls through to `MusicLoadCleanup`.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `musicParentActor` → `orbitAngle` |
| 2 | Spawn first `SpcTransferMusicData`; on `$1FC0` → cleanup |
| 3 | Child `chatPtr` = `$26 + 1`; child `$12` \|= `$1000`; `joypadMaskStd` \|= `$FFFC` |
| 4 | Yield until `musicTransitionState` = `$FFFF` |
| 5 | Spawn `MusicRenderSync`; pass `$20`/`$22`; yield until `APUIO1` = `$FF` |
| 6 | `joypadMaskStd` &= ~`$FFFC`; spawn second `SpcTransferMusicData` with scene music index in `chatPtr` |
| 7 | Yield until `musicTransitionState` = `$FFFF`; `WaitByte #01` |
| 8 | `MusicLoadCleanup`: clear `displayModeFlags` bit `$0080`; `Die` |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$06F2` | In | `musicParentActor` — scene music index (saved to `orbitAngle`) |
| `$06FA` | In | `musicTransitionState` — `$FFFF` = SPC block transfer finished |
| `$065A` | Out | `joypadMaskStd` — OR mask `$FFFC` while waiting |
| `$09EC` | Out | `displayModeFlags` — bit `$0080` cleared on cleanup |
| `$2141` | In | `APUIO1` — `$FF` = SPC700 ready |
| `$7F0010,X` | Out | `orbitAngle` — saved scene music index |
| `$0012,X` | Out | Actor flags; `$1000` set on children during display-filter mode |
| `$20`/`$22` | In | Dialogue string pointer / bank for `MusicRenderSync` |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `cop_handlers_audio.asm` — `MusicAndText` | Spawns this actor |
| `MusicRenderSync` | One-shot dialogue frame |
| `SpcTransferMusicData` | SPC upload child (jingle, then scene restore) |
| `IsMusicPlaying` | Query while transfer or display-filter flag active |

### MusicRenderSync

*Evidence: [ASM]*

`COP [WaitByte] (#48)` → 73 ticks. Clears own `$12` bit `$1000`. `STZ joypadMaskStd`. Sets DBR from `$22`, `JSL UpdateFrameRender`, `JSL DialogStringRenderer` with `Y = $20`, `Die`.

Inferred: the wait may let the jingle play before the dialogue string appears (asm comment marks this as inferred).

### IsMusicPlaying

*Evidence: [ASM]*

Returns **SEC** if `musicTransitionState` ≠ 0 or `displayModeFlags` bit `$0080` is set; otherwise **CLC**. **RTL**.

## DisplaySceneTitle.asm

*Evidence: [ASM] + [XREF]*

Shows the **current scene area name** in a centered dialogue box during scene load. Called from `ClearSceneState` after `SpawnSceneActors` ([`scene_lifecycle.asm`](../../../extracted/system/engine/scene_lifecycle.asm)). Compares `$0D6E` (source scene recorded by `ExecuteSceneTransition`) to `sceneCurrent` (`$0644`).

| Address | Name | Description |
|---------|------|-------------|
| `$02A11B` | DisplaySceneTitle | Open box, render centered title via `DialogStringRenderer`. |
| `$02A169` | `scene_title_box_format` | `ConsoleString` template: `[DLG:7,7][SIZ:A,1][SFX:0]`. |
| `$02A172` | CountTitleGlyphs | Returns visible glyph count in `$00`. |

### DisplaySceneTitle

*Evidence: [ASM]*

If `$0D6E` = `sceneCurrent`, **RTL**. `JSR CountTitleGlyphs`; if `$00` = 0, **RTL**.

Centering: `(18 − count)`, negated, `AND #$FE`, added to VRAM write cursor `$0998` before the second `DialogStringRenderer` call. Sets `$00B4` = `$E0`, `$00B5` = 0. Saves `$40` and title pointer `$3E`/`Y`, `PHK`/`PLB`, first `JSL DialogStringRenderer` with `scene_title_box_format`, restores pointer, adjusts `$0998`, second `JSL` with title at `[$3E]`.

Inferred: 18 may be the interior width of the 10-column box in tile cells (asm comment; no clamp if count > 18).

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0D6E` | In | Scene ID before transition |
| `$0644` | In | `sceneCurrent` |
| `$3E` | In | Points at actor-list `$FF` terminator; title follows in scene record |
| `$40` | In/Out | String bank byte |
| `$0998` | In/Out | VRAM write cursor |
| `$00` | Temp | Glyph count |
| `$00B4`/`$00B5` | Out | Epilogue wait flag (`$E0` / `$00`) |

### CountTitleGlyphs

*Evidence: [ASM]*

`INC $3E` — steps past the `$FF` actor-list terminator left by `SpawnSceneActors`; the first title byte is counted. Walks `[$3E],Y`:

| Byte | Action |
|------|--------|
| `< $C0` | Count += 1 |
| `$CA` | Return count in `$00` |
| `$CC` | Count += next byte; skip 2 |
| `$D6` | Expand via `dialog_dictionary_a` (`dictionary_01EBA8` in bank `$01`) |
| `$D7` | Expand via `dialog_dictionary_b` (`dictionary_01F54D`) |
| Other `≥ $C0` | Skip one operand byte |

Dictionary expansion: switch DBR, count bytes until `$CA`, restore stream.

## event_blocks.asm

*Evidence: [ASM] + [XREF]*

**Event flag → tile copy** system. Table `event_block_table` (bank `$01`): 8-byte entries. Set flags in `$0A20`–`$0A3F` map to event indices `$0200`–`$02FF`.

| Address | Name | Description |
|---------|------|-------------|
| `$02A1E9` | ApplyAllEventBlocks | 256-bit flag scan at scene load. |
| `$02A220` | CopyEventBlockTiles | Instant source → dest copy (source unchanged). |
| `$02A310` | FlushVramWriteQueue | Drain `dmaSkipFlag` queue or direct `tileQueryResult` path. |
| `$02A363` | LookupEventBlock | Index × 8 into table; scene match → load `$96`–`$A4`. |
| `$02A3A8` | AnimateEventBlock | Copy + VRAM queue; SEC when done. |
| `$02A50D` | QueueVisibleTileVram | BG1 viewport cull; one 2×2 metatile per call. |
| `$02A58B` | AdvanceEventColumn | Next column or SEC = row done. |
| `$02A5B1` | AdvanceEventRow | Next row or SEC = all rows done. |

### ApplyAllEventBlocks

*Evidence: [ASM]*

`$04` = event index (0…255); walks `$0A20,Y` bytes; inner loop LSR × 8. Carry set from LSR → `LookupEventBlock` with A = `$04`; **BCS** skips copy; **CLC** path → `CopyEventBlockTiles`. Outer loop until `$04` wraps to 0 after 32 bytes. **RTL**.

**Cross-References:** `scene_lifecycle.asm`, `inventory_overlay.asm` ([XREF] callers per file header); `LookupEventBlock`, `CopyEventBlockTiles`.

### CopyEventBlockTiles

*Evidence: [ASM]*

Parameters from `LookupEventBlock` (DP `$00`–`$94`, `D` = 0): **source** tile `$96`/`$98`, **dest** `$9A`/`$9C`, width `$9E` (reset from `$A2`), height `$A0`, layer `$A4`.

- **Layer 0** (`$A4` = 0): copy `mapLayerTilemap` + `collisionLayer` bytes from source index `$02` to dest index `$00`.
- **Layer 1** (`$A4` ≠ 0): copy `effectLayerTilemap`; collision via `[$3E]` with base `collisionFlagTableL1` (`$06AC`, bank `$7F`) and tile ID in `$3E` low byte — write `collisionLayer` only if lookup ≠ 0.

Uses `TileCoordsToMapIndex`, `MapIndexMoveRight`, `MapIndexMoveDown` / `MapIndexMoveDown_L1`. No VRAM queue in this routine.

Inferred: visible map updates on scroll may still pick up WRAM changes via the normal render path ([XREF] camera DMA).

### FlushVramWriteQueue

*Evidence: [ASM]*

1. If `dmaSkipFlag` (`$0800`) ≠ 0: save SP, `TCS` to `$07FF`, pop word pairs to `VMADDL`/`VMDATAL` until address word = 0, restore SP, clear `dmaSkipFlag`.
2. Else: `VMAIN` = `$80`; if `tileQueryResult` (`$0902`) ≠ 0, write 2×2 words from `$0904`–`$090C` / `$0908`; clear `$0902`.

**Cross-References:** two `JSL` sites in `system_core.asm` render path; `AnimateEventBlock`, `DrawChestTiles` enqueue data.

### LookupEventBlock

*Evidence: [ASM]*

Entry: A = block index. Y = index × 8 → saved to `$A8`. Byte 0 vs `sceneCurrent` — mismatch **SEC** / **RTL**.

On match (8-bit load at DP 0):

| Table offset | Register | Field |
|--------------|----------|-------|
| +1, +2 | `$96`, `$98` | Source tile X/Y |
| +3 | `$A2`, `$9E` | Width |
| +4 | `$A0` | Height |
| +5, +6 | `$9A`, `$9C` | Destination tile X/Y |
| +7 | `$A4` | Layer flag (0 = L0, nonzero = L1) |

**CLC** / **RTL** on success.

**Cross-References:** `ApplyAllEventBlocks`; `cop_handlers_bg_rearrange.asm` — `StageBgChange` (`#32`), `StageBgChangeFromDeathIdx` (`#34`); `actor_execution.asm` — `CheckEnemyDefeatedFlag` path.

### AnimateEventBlock

*Evidence: [ASM]*

Same WRAM copy as `CopyEventBlockTiles`, plus VRAM queue at `$0800+Y` (16 metatiles max, Y = `$0100` full).

- **Layer 0:** after each tile, `JSR QueueVisibleTileVram`. Off-screen (**SEC**) → advance. Queue full (**CLC**, Z = 1 from `LDX #0` in helper) → write zero terminator, `JSL UpdateFrameDialogue`, restart from saved `$96`–`$A8`.
- **Layer 1:** inline visibility using `effectScrollH`/`effectScrollV`, `metatileEffectLayer` (`$7E2800`), BG2 VRAM addresses (+`$0800`). Queue full with tiles remaining → terminator, **CLC** (caller flushes). All tiles done → terminator, **SEC**.

**Cross-References:** `ApplyBgChange` (`COP #33`) loops until **SEC** ([`cop_handlers_bg_rearrange.asm`](../../../extracted/system/engine/cop_handlers_bg_rearrange.asm)).

### QueueVisibleTileVram

*Evidence: [ASM]*

Entry: X = map index, Y = queue offset. Visibility ([ASM]): `(pixelX + $10 − bg1ScrollH) < $0111` and `(pixelY − ((mapScrollV − $10) & $FFF0))` in `0…$F0`.

On-screen: map byte × 8 → four words from `metatileMapLayer` (`$7E2000`); four VRAM addresses via `PixelToVramAddress` (+1, +$1F, +$20 pattern). Y += `$10`.

Returns **SEC** off-screen; **CLC** queued; if Y = `$0100`, **RTS** with Z = 1 (`LDX #0`) for queue-full detection.

### AdvanceEventColumn / AdvanceEventRow

*Evidence: [ASM]*

**AdvanceEventColumn:** `DEC $9E`; if zero, **RTS** with carry set (row complete). Else `$1A` += `$10`, `$96`/`$9A` += 1, move map indices right, **CLC**.

**AdvanceEventRow:** `DEC $A0`; if zero, **RTS** carry set. Else `$1E` += `$10`, `$98`/`$9C` += 1, reload `$96`/`$9A` from `event_block_table+1` / `+5` via `$A8`, `$9E` = `$A2`, **CLC**.

## Event System — Flag → Tile Swap Pattern

*Evidence: [ASM] + [INFERRED]*

```
Event flag set ($0200–$02FF in $0A20–$0A3F)
  └─► LookupEventBlock (event_block_table[index])
        └─► Byte 0 = sceneCurrent?
              └─► CopyEventBlockTiles or AnimateEventBlock
                    └─► Copy source rect → dest rect (mapLayerTilemap / effectLayerTilemap + collision)
                          └─► [Animated] QueueVisibleTileVram → dmaSkipFlag queue → FlushVramWriteQueue
```

### Block Definition (`event_block_table`)

*Evidence: [ASM]*

| Offset | Field | Register | Meaning |
|--------|-------|----------|---------|
| 0 | Scene ID | — | Must match `$0644` |
| 1 | Source col | `$96` | Source rectangle X |
| 2 | Source row | `$98` | Source rectangle Y |
| 3 | Width | `$A2` / `$9E` | Tiles wide |
| 4 | Height | `$A0` | Tiles tall |
| 5 | Dest col | `$9A` | Destination X |
| 6 | Dest row | `$9C` | Destination Y |
| 7 | Layer flag | `$A4` | `$00` = L0; nonzero = L1 (`effectLayerTilemap`) |

Flag bit: index `n` → byte `$0A20 + (n >> 3)`, bit `(n & 7)`. Index 0 = flag `$0200`.

### Instant vs Animated Paths

*Evidence: [ASM] + [XREF]*

| Pattern | Entry | VRAM | When |
|---------|-------|------|------|
| Instant | `CopyEventBlockTiles` | None in this file | Scene load, inventory rebuild, defeated-enemy path |
| Animated | `AnimateEventBlock` | `$0800` queue → `FlushVramWriteQueue` | `StageBgChange` + `ApplyBgChange` (`#32` / `#33`) |

Layer 1: zero collision lookup result skips overwriting `collisionLayer` ([ASM]) — leaves existing collision for that cell.

Inferred: used for partial compound-tile changes (e.g. door frames) in gameplay terms.

## warps_interaction.asm

*Evidence: [ASM] + [XREF]*

Warp rectangles (`scene_warps`), chest records (`scene_chest_table`), and COP chest fanfare actors. `CheckWarpAndChest` every frame from `system_core`; `InitWarpTable` and `PlaceOpenedChestTiles` during scene setup (`scene_lifecycle`; `PlaceOpenedChestTiles` again on inventory overlay rebuild).

| Address | Name | Description |
|---------|------|-------------|
| `$02A5DD` | CheckWarpAndChest | Warp test, then chest if no warp hit. |
| `$02A5F0` | PlaceOpenedChestTiles | Open-chest tiles for flagged records. |
| `$02A65D` | HandleChestInteraction | D-pad up + guards → open flow. |
| `$02A7B8` | ChestOpeningActor | Fanfare + `SpcTransferMusicData` sequence. |
| `$02A893` | ChestDialogueActor | Delayed `ShowDialogueFrame`. |
| `$02A8A8` | SetAnimStatePointer | `$0000,Y` / clear `$0008,Y`. |
| `$02A8B2` | DrawChestTiles | 2×2 map + VRAM queue + `UpdateFrameRender`. |
| `$02A957` | InitWarpTable | `$00D4` / `$00D6` warp list pointers. |
| `$02A97B` | CheckWarpRectangles | Standard then extended passes. |
| `$02AA21` | ConvertWarpToPixels | Tile rect → pixel bounds. |
| `$02AA5A` | ExecuteWarp | Standard warp → transition staging. |
| `$02AAF2` | ExecuteForcedWalkWarp | Extended warp → forced walk. |
| `$02AB25` | StartForcedWalk | Spawn `ForcedWalk*` actor. |

### CheckWarpAndChest

*Evidence: [ASM]*

`JSR CheckWarpRectangles`; **BCS** skips chest. Else `JSR HandleChestInteraction`. Both branches merge to `PLP` / **RTL**; carry from helpers is not returned to the caller (four `NOP`s before `PLP`).

### PlaceOpenedChestTiles

*Evidence: [ASM]*

`sceneTableIndex` (`$0646`) → pointer into `scene_chest_table`. Each record 4 bytes: byte 0 bit `$80` = end. If `TestEventFlag_0200` on byte 3 AND `$7F` succeeds, write at (X, Y−1) / (X, Y): `$FE`, `$FF`, `$FC`, `$FD` into `mapLayerTilemap`. No VRAM queue.

### HandleChestInteraction

*Evidence: [ASM]*

Guards (all required):

1. `layerPriorityFlag` (`$06EE`) bit `$0200` clear  
2. Player actor `$10` bit `$0004` set (solid contact)  
3. `joypadCurrent` bit `$0800` (D-pad up)  
4. `GetPlayerFacingDirection` = `$0001` (north)

Tile in front: chest bottom `$F8`/`$F9` pair on `mapLayerTilemap`. Scan `scene_chest_table` for bytes 0/1 = origin. No match → `dialog_chest_locked`.

On match: set `displayModeFlags` bit `$0080`; `DrawChestTiles` with base `$FC` (open-chest graphics). Byte 2 = 0 → `dialog_chest_empty`, set flag byte 3 AND `$7F`. Byte 2 ≠ 0 → `GiveItemToPlayer`; inventory full → dialogue from Y, redraw closed base `$F8`. Success: byte 3 bit `$80` → `ChestOpeningActor` + `$26` = `$17`; else clear display filter, SFX `$2A` on `sfxQueueCh2`, `dialog_item_chest`. Always set event flag byte 3 AND `$7F` on success path.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Guards: `$06EE` bit `$0200`, player `$10` bit `$0004`, `joypadCurrent` bit `$0800`, facing = `$01` |
| 2 | Tile north of player; require `$F8`/`$F9` chest pair on `mapLayerTilemap` |
| 3 | Scan `scene_chest_table` for matching X/Y |
| 4 | No record → `dialog_chest_locked` |
| 5 | Set `displayModeFlags` bit `$0080`; `DrawChestTiles` with `$FC` |
| 6 | Item vs empty branch; `GiveItemToPlayer` / full inventory / fanfare actor |
| 7 | `SetEventFlag_0200` on success; clear display filter on exit paths |

Inferred: “push against chest from below” matches north-facing + up input (geometry in asm comments).

### ChestOpeningActor

*Evidence: [ASM]*

Saves `$06F2` → `orbitAngle`. First `SpcTransferMusicData`: `chatPtr` = `$26 + 1`. Joypad mask `$CFFC` on `joypadMaskStd`. Player `$12` \|= `$1000`; `SetAnimStatePointer` → `PlayerIdleAnimLoop`; `playerFlags` \|= `$0800`. Wait `$06FA` = `$FFFF`. Spawn `ChestDialogueActor` with `$24`/`$20`. Wait `APUIO1` = `$FF`. Clear player `$1000`; `RestorePlayerControlDirect`; unmask `$CFFC`. Second `SpcTransferMusicData` restores `orbitAngle` to `chatPtr`; wait `$FFFF`; `WaitByte #0B` (12 ticks); clear `displayModeFlags` bit `$0080`; `Die`.

### ChestDialogueActor

*Evidence: [ASM]*

`WaitByte #48`; clear own `$12` bit `$1000`; `$20` → `$0DB8`; `ShowDialogueFrame` with `$24`; `Die`.

### DrawChestTiles

*Evidence: [ASM]*

Base tile in `$06` (`$FC` open / `$F8` closed). Four corners: `+2`, `+3`, base, `+1` on map; `QueueVisibleTileVram` each; zero word at `dmaSkipFlag,Y`; `JSL UpdateFrameRender`.

### InitWarpTable

*Evidence: [ASM]*

`scene_warps[sceneTableIndex]` → `$00D4`. Walk 12-byte standard entries until byte 0 has bit 7 set (`BMI`, `$FF` sentinel). Next byte → `$00D6` (extended list).

### CheckWarpRectangles

*Evidence: [ASM]*

Pass 1: `$00D4`, 12-byte entries, `$FF` end. Pass 2: `$00D6`, 13-byte entries. Tile AABB on `playerXTile`/`playerYTile`; then `ConvertWarpToPixels` vs `playerXPos`/`playerYPos`. Hit → `JMP ExecuteWarp` or `ExecuteForcedWalkWarp`. Miss: `TRB playerFlags` bit `$0100`; **CLC** / **RTS**.

### ConvertWarpToPixels

*Evidence: [ASM]*

Bytes 0–3 × 16 → `$00`/`$02`; width/height × 16 − `$0F` → `$04`/`$06` (unsigned compare in caller).

### ExecuteWarp

*Evidence: [ASM] + [XREF]*

Entry+4 pointer + `scene_warps` bank → `reviveWarpPtr`/`reviveWarpBank` (`$0AF4`/`$0AF6`) for game-over revive ([XREF] `GameOverSequence`). Copies bytes 4–11 to `sceneNext`, `warpDestX/Y`, `warpFacing`, `warpScrollParams`; source rect bytes 0–3 and camera nibble pack to `$0B08`–`$0B12`; `sourceSceneId` = `sceneCurrent`.

Byte 9 bit `$80`: save-warp path — clear bit in `warpFacing`, also store entry+4 to `sceneSaveData`/`sceneSaveDataBank` (`$0AF0`/`$0AF2`). Both paths **SEC** / **RTL**.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Entry+4 → `$0AF4`/`$0AF6` (revive pointer + bank) |
| 2 | Bytes 4–11 → `sceneNext`, spawn X/Y, `warpFacing`, `warpScrollParams` |
| 3 | Snapshot source rect + camera nibbles → `$0B08`–`$0B12`; `$0B12` = `sceneCurrent` |
| 4 | Byte 9 bit `$80` clear → **SEC** / **RTL** |
| 5 | Byte 9 bit `$80` set → strip bit, copy entry+4 to `$0AF0`/`$0AF2`, **SEC** / **RTL** |

Convention (other file): fade style and scene reload timing are handled outside this file ([XREF] transition code in `scene_lifecycle`).

### ExecuteForcedWalkWarp

*Evidence: [ASM]*

If `playerFlags` bit `$0100` set, **RTS** (no carry). Else: `warpFacing` (`$0650`) = pointer to entry+7 (walk-step byte stream); zero `playerSpeedEw`/`playerSpeedNs`; bytes 4–5 → `warpScrollParams`; byte 6 → `scrollStepTableBase`; `JSL InitCameraBounds`; `JSR StartForcedWalk`; **SEC** / **RTS**.

### StartForcedWalk

*Evidence: [ASM]*

`playerFlags` \|= `$0100`; player `$10` \|= `$2000`; `STZ scrollStepIndex`; preserve walk sequence in low nibble of `scrollStepTableBase`. Direction from **saved** high bits of entry byte 6: bit `$0020` West, `$0010` East, `$0080` North, else South. `COP [SpawnBefore]` on matching `@forced_walk.ForcedWalk*`. **RTS**.

## Warp System — Rectangle Detection + Scene Transition

*Evidence: [ASM] + [INFERRED] + [XREF]*

Warp data per scene in `scene_warps` (bank `$01`). `InitWarpTable` splits standard (12-byte) and extended (13-byte) lists at the `$FF` (bit 7) terminator.

### `scene_warp` layout (12 bytes)

*Evidence: [ASM]* (field use in `ExecuteWarp` / `CheckWarpRectangles`)

| Offset | Field |
|--------|--------|
| 0–3 | Origin X/Y, width, height (tiles) |
| 4 | Destination scene ID |
| 5–6 | Spawn X (word) |
| 7–8 | Spawn Y (word) |
| 9 | `warpFacing` (byte 9 bit `$80` = save warp) |
| 10–11 | `warpScrollParams` (word) |

Extended 13-byte entries: bytes 0–3 same AABB; bytes 4–5 camera window → `warpScrollParams`; byte 6 → `scrollStepTableBase`; bytes 7+ walk steps ([ASM] `ExecuteForcedWalkWarp`).

### Detection pipeline

*Evidence: [ASM]*

```
InitWarpTable → $00D4 standard, $00D6 extended
CheckWarpRectangles → tile AABB → ConvertWarpToPixels → ExecuteWarp | ExecuteForcedWalkWarp
```

Inferred: pixel pass tightens triggers inside a tile ([INFERRED] from asm comments on the last 15 pixels).

### Scene transition flow

*Evidence: [ASM] + [XREF]*

```
CheckWarpAndChest
  └─► CheckWarpRectangles
        ├─► ExecuteWarp → staging at $0642, $064C–$0652, $0B08–$0B12, $0AF4/$0AF6 (+ optional $0AF0 save warp)
        └─► ExecuteForcedWalkWarp → InitCameraBounds → StartForcedWalk → ForcedWalk* ([XREF] later transition)
```

Return-warp bytes at `$0B08`–`$0B12` snapshot source rectangle and camera nibbles from `$06D6`–`$06DC` ([ASM]).

### Chest tables

*Evidence: [ASM]*

`scene_chest_table` (`table_01ADA8` in bank `$01`): per-scene list of 4-byte records:

| Offset | Meaning |
|--------|---------|
| 0 | Tile X (bit `$80` = end) |
| 1 | Tile Y (bottom row of 2×2) |
| 2 | Item ID (`0` = flag-only) |
| 3 | Event flag in bits 0–6; bit 7 = use `ChestOpeningActor` fanfare |

## Related Documentation

*Evidence: [XREF]*

| Document | Relevance |
|----------|-----------|
| [hardware-and-init.md](hardware-and-init.md) | Main loop, `UpdateFrameRender` / `UpdateFrameDialogue` |
| [scene-script.md](scene-script.md) | Scene load pipeline, `ClearSceneState` |
| [spc-transfer.md](spc-transfer.md) | `SpcTransferMusicData`, `musicTransitionState` |
| [camera-scrolling.md](camera-scrolling.md) | Map buffers (`mapLayerTilemap`, scroll registers) |
| [map-coordinates.md](map-coordinates.md) | `TileCoordsToMapIndex`, `PixelToVramAddress` |
| [../bank00/event-flags.md](../bank00/event-flags.md) | Flags `$0200`–`$02FF` |
| [../../cop/README.md](../../cop/README.md) | COP `#19`, `#32`–`#34` |
