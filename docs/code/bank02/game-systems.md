# Bank $02 — Game World Systems

*Part of the [Bank $02 Documentation Suite](readme.md)*

**Bank:** `$02` (FastROM; accessed via `$@` long calls from other banks)  
**Address range:** `$02A040`–`$02AB8A`  
**Source:** [`music_actors.asm`](../../../extracted/system/engine/music_actors.asm), [`DisplaySceneTitle.asm`](../../../extracted/system/engine/DisplaySceneTitle.asm), [`event_blocks.asm`](../../../extracted/system/engine/event_blocks.asm), [`warps_interaction.asm`](../../../extracted/system/engine/warps_interaction.asm)  
**Scene:** `engine`

**Related docs:** [hardware-and-init.md](hardware-and-init.md) · [scene-script.md](scene-script.md) · [spc-transfer.md](spc-transfer.md) · [camera-scrolling.md](camera-scrolling.md) · [map-coordinates.md](map-coordinates.md) · [../bank00/event-flags.md](../bank00/event-flags.md) · [../../cop-commands-reference.md](../../cop-commands-reference.md)

## Overview

Four ASM compilation units in bank `$02` implement **interactive world state** — the glue between the scene script loader ([`chunk_03BAE1.asm`](../../../extracted/system/chunk_03BAE1.asm)), the per-frame main loop ([`system_core.asm`](../../../extracted/system/engine/system_core.asm)), and player-facing map changes (doors opening, chests, warps). Together they:

1. **Synchronize music and rendering** via COP actors that block input while the SPC700 finishes a track.
2. **Display the scene area name** in a centered dialogue box overlay when entering a new area.
3. **Apply persistent map tile swaps** driven by event flags — both instantly at scene load and animated during COP scripts.
4. **Detect warp rectangles and chest interactions** each frame, triggering scene transitions or item pickup flows.

These routines sit above the hardware/VBlank layer in [hardware-and-init.md](hardware-and-init.md) and below the camera/scrolling engine documented in [camera-scrolling.md](camera-scrolling.md). Map coordinate helpers are documented in [map-coordinates.md](map-coordinates.md) ([`map_coords.asm`](../../../extracted/system/engine/map_coords.asm)). Event flag semantics are defined in [../bank00/event-flags.md](../bank00/event-flags.md).

### Interaction Lifecycle

The four compilation units split into **scene-entry** setup (during `ClearSceneState`) and **per-frame** interaction (from `system_core.asm` after player movement):

| When | Routine | Role |
|------|---------|------|
| Scene load | `ApplyAllEventBlocks` | Scan all 256 event flags; instantly swap hidden map tiles into place for set flags |
| Scene load | `PlaceBarrierTiles` | Write impassable 2×2 barrier patterns for flagged blocked passages |
| Scene load | `DisplaySceneTitle` | After `SpawnSceneActors`, show centered area name if entering from a different scene (`$0D6E ≠ scene_current`) |
| Scene load | `InitWarpTable` | Set `$00D4`/`$00D6` to standard and extended warp lists for the current scene |
| Every frame | `CheckWarpAndChest` | Warp rectangle hit-testing; chest interaction when no warp is active |
| On demand (COP) | `MusicPlaybackActor` | Mask input, wait for SPC track idle, sync render frame, show dialogue |

**Music actors** coordinate playback timing with the render pipeline: they block directional input, poll `$06FA` until the active track reaches idle (`$FFFF`), spawn `MusicRenderSync` for a clean dialogue frame, and wait for the APU handshake (`$2141 = $FF`) before restoring joypad control. **DisplaySceneTitle** is a one-shot on scene entry — it suppresses the overlay when re-entering the same area and sets `$00B4` so the transition epilogue can wait for player acknowledgment. **Event blocks** connect persistent story flags to map geometry: bulk-applied at load for instant WRAM tile swaps, or animated mid-script via COP `$32`/`$33` with VRAM queue flushes during VBlank. **Warps** run rectangle detection every frame — tile-level AABB first, then pixel-precision overlap — triggering `ExecuteWarp` for doorways or a forced-walk path for stair warps.

### Block Layout

```
$02A040 ┌─ MusicPlaybackActor ─────────────────────┐
        │  MusicRenderSync / IsMusicPlaying         │  music_actors
$02A11B ├─ DisplaySceneTitle ────────────────────────┤  DisplaySceneTitle
        │  scene_title_box_format / CountTitleGlyphs│
$02A1E9 ├─ ApplyAllEventBlocks ─────────────────────┤
        │  SwapEventBlockTiles / FlushVramWriteQueue│  event_blocks
        │  LookupEventBlock / AnimateEventBlock …   │
$02A5DD ├─ CheckWarpAndChest ───────────────────────┤
        │  PlaceBarrierTiles / HandleChestInteraction│  warps_interaction
        │  ChestOpeningActor … StartForcedWalk      │
$02AB8A └─ (camera_tilemap continues) ──────────────┘
```

## music_actors.asm

COP-based actors and a query routine that coordinate **music playback lifecycle** with the render pipeline. When the `MusicAndText` COP command (opcode `$19`) fires, `cop_handlers_audio.asm` allocates an actor and points it at `MusicPlaybackActor`.

| Address | Name | Description |
|---------|------|-------------|
| `$02A040` | MusicPlaybackActor | MusicPlaybackActor is the primary COP coroutine spawned by the MusicAndText command. |
| `$02A0E5` | MusicRenderSync | MusicRenderSync is a one-shot render-sync child spawned by MusicPlaybackActor after the music track reaches idle. |
| `$02A10A` | IsMusicPlaying | IsMusicPlaying is a lightweight query routine callable from any bank via JSL. |

### MusicPlaybackActor

`MusicPlaybackActor` is the primary COP coroutine spawned by the `MusicAndText` command. It orchestrates the full music-and-dialogue sequence: blocking player input, waiting for the active music track to finish, synchronizing a render frame so dialogue can appear cleanly, and respawning the visual overlay child actor that keeps the screen updated during the wait.

On entry the actor saves the parent actor ID from `$06F2` into `$7F0010,X`, then spawns `@chunk_03BAE1.func_03E1D6` as a visual-sync child with flag `$2000`. If spawn fails (`CPY #$1FC0`), control jumps to cleanup at `code_02A0DD`. Otherwise the actor increments its child counter, sets actor flag bit `$1000`, and masks the joypad via `TSB $065A` with mask `$FFF0` (stripping directional input).

The main loop waits until `$06FA` (active music track ID) equals `$FFFF` (idle). When music ends, it spawns `MusicRenderSync`, copies text pointer registers `$20`/`$22` to the child, waits for APU handshake (`$2141` = `$FF`), restores joypad input, respawns the visual child, and loops. When the sequence completes, cleanup clears `$09EC` bit `$0080` and dies.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Save parent actor ID → `$7F0010,X` |
| 2 | Spawn visual child `func_03E1D6`; on failure → cleanup |
| 3 | Set actor flag `$1000`; mask joypad (`$065A \|= $FFF0`) |
| 4 | **Loop:** if `$06FA ≠ $FFFF`, yield (`RTL` on resume) |
| 5 | Spawn `MusicRenderSync`; copy `$20`/`$22` to child |
| 6 | Wait until `$2141` low byte = `$FF` |
| 7 | Restore joypad; respawn visual child |
| 8 | If `$06FA = $FFFF`, `WaitByte #01` and repeat from step 4 |
| 9 | **Cleanup:** clear `$09EC` bit `$0080`; `Die` |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$06F2` | In | Parent actor ID to restore after visual child respawn |
| `$06FA` | In | Active music track ID (`$FFFF` = idle) |
| `$065A` | Out | Joypad mask — `$FFF0` stripped during wait |
| `$09EC` | Out | Scene status; bit `$0080` cleared on cleanup |
| `$2141` | In | APU I/O port 1 — `$FF` signals music completion |
| `$7F0010,X` | Out | Saved parent actor ID |
| `$0012,X` | Out | Actor flags; bit `$1000` set during sequence |
| `$20`/`$22` (actor) | In/Out | Text pointer passed to `MusicRenderSync` child |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `cop_handlers_audio.asm` — `MusicAndText` | Spawns this actor with music ID and text pointer |
| `MusicRenderSync` | Child actor spawned after music ends |
| `chunk_03BAE1.func_03E1D6` | Visual overlay child respawned each cycle |
| `IsMusicPlaying` | Query used by other actors waiting for same idle state |

### MusicRenderSync

`MusicRenderSync` is a one-shot render-sync child spawned by `MusicPlaybackActor` after the music track reaches idle. It bridges the gap between music ending and visible dialogue display by forcing a full render frame after a fixed delay.

The actor waits 72 frames (`WaitByte #48`), clears actor flag bit `$1000`, zeroes the joypad mask at `$065A`, saves and restores DBR from the text pointer bank byte at `$22`, then calls `UpdateFrame_Render` followed by `sub_03E255` (dialogue box opener in chunk `$03`). It then dies. This ensures the dialogue frame is laid out on screen before the parent actor resumes and waits for the APU handshake.

## DisplaySceneTitle.asm

Displays the **current scene's area name** in a centered dialogue box overlay when the player enters a new area. Called from `ClearSceneState` in [`scene_lifecycle.asm`](../../../extracted/system/engine/scene_lifecycle.asm) after `SpawnSceneActors`. Compares the source scene recorded at `$0D6E` against `$0644` (`sceneCurrent`) to suppress the title when re-entering the same area.

| Address | Name | Description |
|---------|------|-------------|
| `$02A11B` | DisplaySceneTitle | Main entry: measures title width, opens a dialogue box, and renders the centered area name via `DialogStringRenderer`. |
| `$02A169` | scene_title_box_format | Fixed `ConsoleString` template that opens a 10×1 dialogue box at position (7, 7) before the title text is drawn. |
| `$02A172` | CountTitleGlyphs | CountTitleGlyphs walks the scene title wide-string at `[$3E]` and returns the total visible glyph count in `$00`. |

### DisplaySceneTitle

`DisplaySceneTitle` is the main entry point for the scene title overlay. It runs during `ClearSceneState` after actor spawning and before `SpawnSceneThinkers`. The source scene ID at `$0D6E` (recorded during `ExecuteSceneTransition`) is compared against `$0644` (`sceneCurrent`); if they match, the player is re-entering the same area and the routine returns without drawing a title.

When the scene has changed, `CountTitleGlyphs` measures the visible width of the title string pointed to by `$3E`. A zero count means the scene has no area name — the routine exits immediately. Otherwise it computes a centering offset: `(18 − glyphCount)`, negated, masked to even bytes (`AND #$FE`), so the title is horizontally centered within the 18-glyph dialogue row.

The routine then sets `$00B4 = $E0` (wait-for-input flag consumed by the scene transition epilogue in `ExecuteSceneTransition`) and clears `$00B5`. It saves the current string state (`$40`, `$3E`/Y), sets DBR to the current bank, and calls `DialogStringRenderer` with `scene_title_box_format` to open the dialogue frame. After restoring the title pointer, it adds the centering offset to the VRAM write cursor at `$0998` and calls `DialogStringRenderer` again with the scene title string to render the centered area name.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | If `$0D6E = $0644`, return (same area — no title) |
| 2 | `JSR CountTitleGlyphs`; if `$00 = 0`, return (no title for this scene) |
| 3 | Centering offset = `(18 − count)`, negated, `AND #$FE` |
| 4 | Set `$00B4 = $E0`, `$00B5 = $00` |
| 5 | Save `$40`, `$3E`/Y; set DBR to current bank |
| 6 | `JSL DialogStringRenderer` with `scene_title_box_format` |
| 7 | Restore `$3E`/Y; add centering offset to `$0998` |
| 8 | `JSL DialogStringRenderer` with title string at `[$3E]` |
| 9 | Restore DBR and processor state; return |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0D6E` | In | Source scene ID recorded during transition |
| `$0644` | In | Current scene ID (`sceneCurrent`) |
| `$3E` | In | Scene title wide-string pointer |
| `$40` | In/Out | String bank byte (saved/restored around renderer calls) |
| `$0998` | In/Out | VRAM write cursor — adjusted for horizontal centering |
| `$00` | Temp | Glyph count from `CountTitleGlyphs` |
| `$00B4`/`$00B5` | Out | Wait-for-input flag (`$E0`/`$00`) for transition epilogue |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `ClearSceneState` | Caller — step 8 of scene load, after `SpawnSceneActors` |
| `ExecuteSceneTransition` | Records source scene in `$0D6E`; epilogue waits on `$00B4` |
| `CountTitleGlyphs` | Internal helper for title width measurement |
| `scene_title_box_format` | Format string for dialogue box frame |
| `DialogStringRenderer` | Renders dialogue box frame and title text (bank `$03`) |

### CountTitleGlyphs

`CountTitleGlyphs` walks the scene title wide-string at `[$3E],Y` and returns the total visible glyph count in `$00`. It is called by `DisplaySceneTitle` to determine whether a title exists and to compute horizontal centering. The parser handles the command subset used in scene title strings, mirroring the text engine's own rules.

The routine increments `$3E` before walking (skipping a leading type/length byte). Plain tile characters (byte `< $C0`) increment the counter. `$CA` (Return) terminates the string. `$CC` (AdvanceCursor) reads the next byte as additional visible width and adds it to the count. Dictionary references `$D6` and `$D7` dereference entries in `dictionary_01EBA8` and `dictionary_01F54D` respectively, switch DBR to the dictionary bank, and count each expanded character until `$CA`. Other commands (`≥ $C0`, not handled above) skip one operand byte without counting.

**Algorithm:**

| Byte range | Action |
|------------|--------|
| `< $C0` | Count += 1; advance Y |
| `$CA` | Return count in `$00` |
| `$CC` | Count += next byte (cursor advance width); advance Y by 2 |
| `$D6` | Lookup `dictionary_01EBA8[index]`; count expanded chars until `$CA` |
| `$D7` | Lookup `dictionary_01F54D[index]`; count expanded chars until `$CA` |
| Other `≥ $C0` | Skip one operand byte; advance Y |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$3E` | In/Out | Title string pointer (incremented on entry past type byte) |
| `$00` | Out | Accumulated visible glyph count |
| Y | Temp | Index into `[$3E],Y` |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `DisplaySceneTitle` | Sole caller |
| `dictionary_01EBA8` | `$D6` dictionary table (bank `$01`) |
| `dictionary_01F54D` | `$D7` dictionary table (bank `$01`) |

## event_blocks.asm

Implements the **event flag → tile swap** system. Each event block definition in `event_block_table` (bank `$01`) describes a source rectangle of hidden off-screen tiles and a destination rectangle in the visible tilemap. When the corresponding flag in `$0A20`–`$0A3F` is set, the hidden tiles are copied to the visible destination, revealing previously hidden terrain (paths, platforms, walls) after enemy defeats.

| Address | Name | Description |
|---------|------|-------------|
| `$02A1E9` | ApplyAllEventBlocks | ApplyAllEventBlocks performs a bulk scan of all 256 event flags in the $0200–$02FF range at scene load. |
| `$02A220` | SwapEventBlockTiles | SwapEventBlockTiles performs an instant foreground/background tile exchange over a rectangular map region. |
| `$02A310` | FlushVramWriteQueue | FlushVramWriteQueue drains pending tile graphics writes to SNES VRAM during the VBlank render path. |
| `$02A363` | LookupEventBlock | LookupEventBlock indexes into event_block_table by block ID (passed in A on entry). |
| `$02A3A8` | AnimateEventBlock | AnimateEventBlock applies the same tile swap logic as SwapEventBlockTiles, but spreads work across multiple frames wi... |
| `$02A50D` | QueueVisibleTileVram | QueueVisibleTileVram performs viewport culling and enqueues four VRAM write pairs for a single map tile if it falls w... |
| `$02A58B` | AdvanceEventColumn | AdvanceEventColumn moves the event block iteration to the next column within the current row. |
| `$02A5B1` | AdvanceEventRow | AdvanceEventRow moves the event block iteration to the next row. |

### ApplyAllEventBlocks

`ApplyAllEventBlocks` performs a bulk scan of all 256 event flags in the `$0200`–`$02FF` range at scene load. It walks 32 bytes starting at `$0A20`, testing each bit in each byte. For every set bit, it calls `LookupEventBlock` with the running block index in `$04`, then `SwapEventBlockTiles` if the lookup succeeds (scene ID matches).

The bit index in `$04` wraps: after processing 8 bits per byte across 32 bytes (256 total), the outer loop exits when `$04` wraps to zero after increment. This ensures every event flag in the `$0200` wrapper range is checked exactly once per scene entry.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `$04 = 0` (block ID counter); Y = 0 (flag byte index) |
| 2 | Load flag byte `$0A20,Y`; increment Y |
| 3 | For 8 bits: LSR; if carry set → `LookupEventBlock` → `SwapEventBlockTiles` |
| 4 | Increment `$04`; repeat 8 times per byte |
| 5 | If `$04 ≠ 0`, goto step 2 (next byte) |
| 6 | Return |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0A20`–`$0A3F` | In | Event flag bytes (256 flags, `$0200`–`$02FF`) |
| `$04` | Temp | Running block ID / bit index |
| `$06` | Temp | Current flag byte being tested |
| `$0E` | Temp | Bit counter (8 per byte) |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `chunk_03BAE1.asm` (~line 5440) | Scene load initialization |
| `inventory_overlay.asm` | Inventory exit — refresh map state |
| `LookupEventBlock` | Resolves block geometry from flag index |
| `SwapEventBlockTiles` | Applies instant WRAM tile swap |

### SwapEventBlockTiles

`SwapEventBlockTiles` performs an instant foreground/background tile exchange over a rectangular map region. Geometry registers `$96`–`$A4` must be pre-loaded by `LookupEventBlock`: destination col/row (`$96`/`$98`), source col/row (`$9A`/`$9C`), width (`$9E`), height (`$A0`), and layer flag (`$A4`).

Two modes exist. **Layer-0 mode** (`$A4 = 0`): swaps `$7EA000` ↔ `$7FC000` per cell directly. **Dual-layer mode** (`$A4 ≠ 0`): reads overlay from `$7EC000`; writes to `$7FC000` only when overlay byte ≠ 0; always writes source back to `$7EC000`. Map indices are computed via `TileCoordsToMapIndex` and iterated using `MapIndexMoveRight` / `MapIndexMoveDown` (or `MapIndexMoveDown_L1` for dual-layer).

No VRAM writes occur — the camera DMA picks up WRAM changes on the next scroll refresh.

**Algorithm:**

| Mode | Per-cell operation |
|------|-------------------|
| Layer-0 | Swap `$7EA000[X]` ↔ `$7FC000[X]` |
| Dual-layer | If `$7EC000[src] ≠ 0` → write to `$7FC000[dest]`; write src back to `$7EC000[src]` |
| Iteration | `$9E` columns × `$A0` rows; advance indices per column/row |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$96`/`$98` | In | Destination rectangle col/row |
| `$9A`/`$9C` | In | Source rectangle col/row |
| `$9E`/`$A0` | In | Width / height (tile counts) |
| `$A4` | In | Layer flag (`$00` = direct; non-zero = dual-layer) |
| `$06AC` | In | Layer-1 overlay map source pointer (bank `$7F`) |
| `$7EA000` | In/Out | Map layer-0 tile buffer |
| `$7EC000`/`$7FC000` | In/Out | Overlay / swap target buffers |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `ApplyAllEventBlocks` | Bulk caller at scene load |
| `chunk_03BAE1.func_03D0DB` | Scene-script conditional reload |
| `map_coords.TileCoordsToMapIndex` | Resolves tile coords → map index |
| `AnimateEventBlock` | Animated variant with VRAM queue |

### FlushVramWriteQueue

`FlushVramWriteQueue` drains pending tile graphics writes to SNES VRAM during the VBlank render path. Two mechanisms are supported: a hardware-stack-based queue at `$0800` and a single 2×2 tile shortcut at `$0902`–`$090C`.

When `$0800` is non-zero, the routine switches the stack pointer to `$07FF` and pops `(VRAM_addr, tile_word)` pairs until a zero address terminator, writing each to `$2116`/`$2118`. When the queue head is zero, it checks shortcut slots — if `$0902` is set, writes four tile words in a 2×2 pattern. Both paths clear their respective heads on completion.

**Algorithm:**

| Path | Steps |
|------|-------|
| Stack queue (`$0800 ≠ 0`) | TCS to `$07FF`; pop addr → `$2116`; pop word → `$2118`; repeat until addr = 0; restore SP; clear `$0800` |
| Shortcut (`$0902 ≠ 0`) | Set `$2115 = $80`; write 4 (addr, word) pairs from `$0902`–`$090C`; clear `$0902` |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0800` | In/Out | VRAM write queue stack head |
| `$0902`–`$090C` | In/Out | Single 2×2 tile write shortcut slots |
| `$2115`/`$2116`/`$2118` | Out | SNES VRAM control/data registers |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `system_core.asm` | 2 call sites in `UpdateFrame_Render` VBlank path |
| `AnimateEventBlock` | Queues writes consumed here |
| `DrawChestTiles` | Queues writes consumed here |

### LookupEventBlock

`LookupEventBlock` indexes into `event_block_table` by block ID (passed in A on entry). Each entry is 8 bytes; the index is computed as `block_id × 8`. Byte 0 must match `$0644` (`scene_current`) or the routine returns **SEC** (block not applicable to this scene).

On success, geometry is loaded into working registers: destination col/row (`$96`/`$98`), width (`$A2` → also `$9E`), height (`$A0`), source col/row (`$9A`/`$9C`), and layer flag (`$A4`). The block index is also saved to `$A8` for row-reset in `AdvanceEventRow`. Returns **CLC** on match.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Y = block_id × 8; save index → `$A8` |
| 2 | If `event_block_table[0,Y] ≠ scene_current`, return SEC |
| 3 | Load bytes 1–7 into `$96`–`$A4` |
| 4 | Return CLC |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| A (in) | In | Block ID to look up |
| `$0644` | In | Current scene ID |
| `$96`–`$A4` | Out | Block geometry registers |
| `$A8` | Out | Saved block index for row advance |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `ApplyAllEventBlocks` | Called per set flag bit |
| `cop_handlers_palette.asm` | COP `$32`/`$34` `StageBgChange` |
| `chunk_03BAE1.func_03D0DB` | Conditional scene-script reload |
| `event_block_table` | 8-byte event block definition array (bank `$01`) |

### AnimateEventBlock

`AnimateEventBlock` applies the same tile swap logic as `SwapEventBlockTiles`, but spreads work across multiple frames with VRAM updates for viewport-visible tiles. Called in a loop by COP `$33` `ApplyBgChange` until it returns **SEC** (complete).

Each tile processed calls `QueueVisibleTileVram` to enqueue VRAM writes for on-screen cells. When the queue fills (`Y = $0100`) or a batch completes, the routine terminates the queue with a zero entry, calls `UpdateFrame_Dialogue` for VBlank sync, and returns **CLC** to resume next frame. Dual-layer mode reads tile graphics from `$7E:2800` (BG2 table) instead of the layer-0 path.

Returns **SEC** when all columns and rows are processed; **CLC** if interrupted mid-pass for frame budget.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Select layer mode from `$A4`; compute initial map indices |
| 2 | **Per cell:** swap WRAM tiles; queue VRAM if visible |
| 3 | On queue full (`Y = $0100`): terminate queue, return CLC |
| 4 | `AdvanceEventColumn` → if row done, `AdvanceEventRow` |
| 5 | When all rows/columns done: terminate queue, return SEC |
| 6 | Mid-pass interrupt: `UpdateFrame_Dialogue`; restart from saved state |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$96`–`$A4` | In | Block geometry (from `LookupEventBlock`) |
| `$0800,Y` | Out | VRAM write queue entries |
| `$068A`–`$0690` | In | Camera viewport bounds |
| `$7E:2000`/`$7E:2800` | In | BG1/BG2 tile graphics lookup tables |
| `$1A`/`$1E` | Temp | Pixel X/Y for viewport culling |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `cop_handlers_palette.asm` | COP `$33` `ApplyBgChange` loop |
| `QueueVisibleTileVram` | Per-tile VRAM enqueue |
| `AdvanceEventColumn` / `AdvanceEventRow` | Rectangle iteration |
| `FlushVramWriteQueue` | Drains queue in VBlank |
| `system_core.UpdateFrame_Dialogue` | Frame sync between batches |

### QueueVisibleTileVram

`QueueVisibleTileVram` performs viewport culling and enqueues four VRAM write pairs for a single map tile if it falls within the camera bounds. Called from both `AnimateEventBlock` and `DrawChestTiles`.

The visibility test compares tile pixel position (`$1A`/`$1E`) against camera bounds `$068A`–`$0690` with 16-pixel tile size margins. If visible, it looks up four tile words from `$7E:2000` (BG1 graphics table) indexed by the map tile byte at `$7EA000,X`, computes VRAM addresses via `PixelToVramAddress`, and stores four `(addr, data)` pairs at `$0800,Y`.

Returns **CLC** if queued, **SEC** if off-screen, and sets **X = 0** if the queue is full (`Y` reaches `$0100`).

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Pixel test: tile `$1A+16` vs camera `$068A`; tile `$1E` vs `$068E−16` |
| 2 | If off-screen → return SEC |
| 3 | Lookup 4 tile words from `$7E:2000` via map byte |
| 4 | Compute 4 VRAM addresses via `PixelToVramAddress` |
| 5 | Store 4 pairs at `$0800,Y`; advance Y by `$10` |
| 6 | If Y = `$0100` → X=0 (queue full); else CLC |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$1A`/`$1E` | In | Tile pixel X/Y position |
| `$068A`–`$0690` | In | Camera viewport bounds |
| `$0800,Y` | Out | VRAM write queue (4 entries × 4 bytes) |
| Y (in/out) | In/Out | Queue write offset |
| X (in) | In | Map index for tile byte lookup |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `AnimateEventBlock` | Primary caller during animated swaps |
| `DrawChestTiles` | Chest lid open/close VRAM refresh |
| `map_coords.PixelToVramAddress` | Tile pixel → VRAM address |

### AdvanceEventColumn

`AdvanceEventColumn` moves the event block iteration to the next column within the current row. It decrements the width counter `$9E` and returns **SEC** (carry set) when the row is complete (counter reached zero before decrement would continue).

When columns remain, it advances pixel X by 16 (`$1A`), increments destination and source column registers (`$96`, `$9A`), and moves both map indices right via `MapIndexMoveRight`. Returns **CLC** to continue the inner column loop.

### AdvanceEventRow

`AdvanceEventRow` moves the event block iteration to the next row. It decrements the height counter `$A0` and returns **SEC** when all rows are complete.

When rows remain, it advances pixel Y by 16 (`$1E`), increments destination and source row registers (`$98`, `$9C`), and resets the column counter `$9E` from the original width `$A2`. Column position `$96` and source column `$9A` are restored from the block definition at `$A8` (saved during `LookupEventBlock`). Returns **CLC** to start the next row.

## Event System — Flag → Tile Swap Pattern

Event blocks connect persistent story flags to visible map changes. The data flow is:

```
Event flag set ($0200–$02FF in $0A20–$0A3F)
  └─► LookupEventBlock (event_block_table[block_id])
        └─► Verify scene ID matches $0644
              └─► SwapEventBlockTiles or AnimateEventBlock
                    └─► Exchange map WRAM tiles ($7EA000 ↔ $7FC000)
                          └─► [Animated path] QueueVisibleTileVram → FlushVramWriteQueue
```

### Block Definition (`event_block_table`)

Each entry is 8 bytes:

| Offset | Field | Register | Meaning |
|--------|-------|----------|---------|
| 0 | Scene ID | — | Must match `$0644` or block is skipped |
| 1 | Dest col | `$96` | Destination rectangle start column |
| 2 | Dest row | `$98` | Destination rectangle start row |
| 3 | Width | `$A2` / `$9E` | Tiles wide |
| 4 | Height | `$A0` | Tiles tall |
| 5 | Source col | `$9A` | Swap-source rectangle column |
| 6 | Source row | `$9C` | Swap-source rectangle row |
| 7 | Layer flag | `$A4` | `$00` = layer-0 direct swap; non-zero = dual-layer overlay |

Flag indices map to `$0A20 + (index >> 3)` with bit `(index & 7)`. Index 0 corresponds to event flag `$0200`.

### Instant vs Animated Paths

| Pattern | Entry point | VRAM update | When used |
|---------|-------------|-------------|-----------|
| **Instant** | `SwapEventBlockTiles` | None — camera DMA picks up WRAM changes | Scene load, conditional reload, inventory exit |
| **Animated** | `AnimateEventBlock` | Queued visible writes → VBlank flush | COP `$32`/`$33` (`StageBgChange` → `ApplyBgChange`) |

In dual-layer mode, overlay byte `$00` means "keep existing BG tile" — used when only part of a compound tile should change (e.g. opening a door frame without altering adjacent wall tiles).

## warps_interaction.asm

Per-frame **trigger detection** for warp zones and chest tiles, plus COP actors and helpers that animate chest opening. Called every frame from the main loop after player movement processing.

| Address | Name | Description |
|---------|------|-------------|
| `$02A5DD` | CheckWarpAndChest | CheckWarpAndChest is the top-level per-frame trigger dispatcher called from system_core.asm after player movement. |
| `$02A5F0` | PlaceBarrierTiles | PlaceBarrierTiles writes impassable 2×2 barrier tile patterns to the map buffer for blocked passages. |
| `$02A65D` | HandleChestInteraction | HandleChestInteraction implements the full chest-open flow when the player presses the action button facing a chest t... |
| `$02A7B8` | ChestOpeningActor | ChestOpeningActor is the animated chest-open COP coroutine, structurally parallel to MusicPlaybackActor. |
| `$02A893` | ChestDialogueActor | ChestDialogueActor is a short-lived child actor spawned by ChestOpeningActor after the item jingle completes. |
| `$02A8A8` | SetAnimStatePointer | SetAnimStatePointer is a minimal helper that switches a target actor's animation state. |
| `$02A8B2` | DrawChestTiles | DrawChestTiles writes a 2×2 chest lid tile pattern to $7EA000 and queues VRAM updates for all four corners. |
| `$02A957` | InitWarpTable | InitWarpTable initializes warp list pointers for the current scene during scene load. |
| `$02A97B` | CheckWarpRectangles | CheckWarpRectangles performs two-pass warp detection against the player position each frame. |
| `$02AA21` | ConvertWarpToPixels | ConvertWarpToPixels converts a warp rectangle definition (tile origin + tile size) into a pixel bounding box for prec... |
| `$02AA5A` | ExecuteWarp | ExecuteWarp sets up all parameters for a scene transition when a standard warp rectangle is triggered. |
| `$02AB25` | StartForcedWalk | StartForcedWalk dispatches a directional forced-walk COP actor when the player triggers an extended/stair warp. |

### PlaceBarrierTiles

`PlaceBarrierTiles` writes impassable 2×2 barrier tile patterns to the map buffer for blocked passages. It indexes `table_01ADA8` by scene index `$0646` and iterates 4-byte entries until byte 0 has bit `$80` set (end marker).

For each entry with bit `$80` clear and the corresponding event flag set (`TestEventFlag_0200` on byte 3), it writes a 2×2 pattern (`$FE`/`$FF`/`$FC`/`FD`) to `$7EA000` at the entry's tile coordinates. Called at scene load and on inventory exit to restore boulder/barrier state.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Load `table_01ADA8[$0646]` pointer into X |
| 2 | If entry byte 0 bit `$80` set → return |
| 3 | If `TestEventFlag_0200(entry[3])` fails → skip |
| 4 | Write 2×2 barrier tiles at entry (X, Y−1) coords |
| 5 | Advance X by 4; repeat |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0646` | In | Scene index into `table_01ADA8` |
| `$7EA000` | Out | Map layer-0 tile buffer |
| `$18`/`$1C` | Temp | Tile coordinates for map index |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `chunk_03BAE1.asm` (~line 5441) | Scene load initialization |
| `inventory_overlay.asm` | Inventory exit — restore barriers |
| `cop_handlers_flags.TestEventFlag_0200` | Flag test on entry byte 3 |
| `table_01ADA8` | Per-scene chest/barrier entry table |

### HandleChestInteraction

`HandleChestInteraction` implements the full chest-open flow when the player presses the action button facing a chest tile. Multiple guard conditions must pass: `$06EE` bit `$0200` clear (chest interaction not blocked), player actor bit `$0004` set (action enabled), `$0656` bit `$0800` set (A button), and `func_03F0CA` returning `$01` (facing interactable).

The handler computes the tile in front of the player and checks for chest tile pair `$F8`/`$F9`. It scans `table_01ADA8` for matching coordinates. On miss, shows the empty-chest string. On hit: sets `$09EC` bit `$0080`, draws closed lid via `DrawChestTiles`, checks inventory space via `func_03EF97`.

Outcomes branch three ways: empty item slot → name dialogue + set flag; key item → jingle via `$06F9` + name dialogue; normal item → spawn `ChestOpeningActor` for animated open. Event flag from entry byte 3 is always set on successful pickup.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Guard checks: scene flag, actor flag, A button, facing |
| 2 | Compute tile in front of player; verify `$F8`/`$F9` pair |
| 3 | Scan `table_01ADA8` for matching (X, Y) |
| 4 | On miss → empty-chest dialogue |
| 5 | On hit → set `$09EC` bit `$0080`; draw closed lid |
| 6 | Check inventory space |
| 7 | Full inventory → restore tiles + message |
| 8 | Key item → jingle + dialogue + set flag |
| 9 | Normal item → spawn `ChestOpeningActor` + set flag |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$06EE` | In | Scene system flags; bit `$0200` blocks chests |
| `$0656` | In | Button state; bit `$0800` = A button |
| `$09EC` | Out | Bit `$0080` set during chest sequence |
| `$06F9` | Out | APU command staging (key item jingle = `$2A`) |
| `$0DB8` | Out | Saved text pointer for chest actor |
| `$18`/`$1C` | Temp | Chest tile coordinates |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `CheckWarpAndChest` | Caller (when no warp active) |
| `DrawChestTiles` | Lid tile draw open/closed |
| `ChestOpeningActor` | Animated open for normal items |
| `dialogue_display.ShowDialogueFrame` | Empty/full inventory/key item messages |
| `itemget_table_01FD24` | Item name wide strings |

### ChestOpeningActor

`ChestOpeningActor` is the animated chest-open COP coroutine, structurally parallel to `MusicPlaybackActor`. It locks joypad input with mask `$CFF0`, sets the player to wait animation `$00C432` via `SetAnimStatePointer`, and sets `$09AE` bit `$0800`.

After music reaches idle (`$06FA = $FFFF`), it spawns `ChestDialogueActor` with the item name pointer, waits for APU handshake (`$2141 = $FF`), restores player animation to `$00C45A`, unblocks joypad, respawns the visual child, and waits 11 frames before dying. Cleanup clears `$09EC` bit `$0080`.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Save parent ID; spawn visual child |
| 2 | Mask joypad `$CFF0`; set player wait animation |
| 3 | Wait until `$06FA = $FFFF` |
| 4 | Spawn `ChestDialogueActor` with item name |
| 5 | Wait APU `$FF` handshake |
| 6 | Restore player animation `$00C45A`; unblock joypad |
| 7 | Respawn visual child; `WaitByte #0B`; die |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$065A` | Out | Joypad mask — `$CFF0` stripped |
| `$09AE` | Out | Player flags; bit `$0800` set during open |
| `$20`/`$24` (actor) | In | Text pointer / item name wide string |
| `$06FA` | In | Music track idle check |
| `$2141` | In | APU handshake port |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `HandleChestInteraction` | Spawner via `SpawnLastRel` |
| `ChestDialogueActor` | Child for item name display |
| `SetAnimStatePointer` | Player animation switch |
| `player_transition_handlers.loc_00C432`/`loc_00C45A` | Wait/idle animations |

### DrawChestTiles

`DrawChestTiles` writes a 2×2 chest lid tile pattern to `$7EA000` and queues VRAM updates for all four corners. On entry, X points to a `table_01ADA8` entry and `$06` holds the base tile ID: `$FC` for closed lid, `$F8` for open variants.

Tile IDs are computed as base + offset for each corner (`+2`, `+3`, base, `+1`). Each corner calls `event_blocks.QueueVisibleTileVram` to enqueue VRAM writes. After all four corners, the queue is terminated with a zero at `$0800,Y` and `UpdateFrame_Render` forces an immediate screen refresh.

**Algorithm:**

| Corner | Tile ID | Map move |
|--------|---------|----------|
| Top-left | `$06 + 2` | Origin |
| Top-right | `$06 + 3` | MoveRight |
| Bottom-left | `$06` | MoveDown |
| Bottom-right | `$06 + 1` | MoveRight |
| Finish | Queue terminator + `UpdateFrame_Render` | — |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| X (in) | In | `table_01ADA8` entry pointer |
| `$06` (in) | In | Base lid tile ID (`$FC` closed / `$F8` open) |
| `$7EA000` | Out | Map tile buffer |
| `$0800,Y` | Out | VRAM write queue |
| `$1A`/`$1E` | Temp | Pixel coords for VRAM culling |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `HandleChestInteraction` | Caller (closed lid before open, restore on full inventory) |
| `event_blocks.QueueVisibleTileVram` | Per-corner VRAM enqueue |
| `system_core.UpdateFrame_Render` | Immediate screen refresh |

### InitWarpTable

`InitWarpTable` initializes warp list pointers for the current scene during scene load. It loads `scene_warps[$0646]` into `$00D4` (standard warp list start), then scans forward in 12-byte steps until byte 0 of an entry is negative (`BMI` — the `$FF` terminator).

The pointer after the terminator (extended/stair warp list start) is stored in `$00D6`. This two-pointer setup enables `CheckWarpRectangles` to iterate standard and extended warp arrays separately.

### CheckWarpRectangles

`CheckWarpRectangles` performs two-pass warp detection against the player position each frame. **Pass 1** iterates 12-byte `scene_warp` entries from `$00D4`. **Pass 2** iterates 13-byte `stair_warp` entries from `$00D6`. Each entry is terminated by `$FF` in byte 0.

Each candidate entry undergoes a two-level test: first a tile-level AABB against `$09A6`/`$09A8` (player tile coords), then a pixel-level test via `ConvertWarpToPixels` against `$09A2`/`$09A4` (8-pixel precision player position). Standard hit jumps to `ExecuteWarp`; extended hit jumps to `code_02AAF2` (forced-walk path). No hit clears `$09AE` bit `$0100` and returns carry clear.

**Algorithm:**

| Pass | Entry size | Hit action |
|------|------------|------------|
| 1 (standard) | 12 bytes | Tile AABB → pixel AABB → `ExecuteWarp` |
| 2 (extended) | 13 bytes | Tile AABB → pixel AABB → `code_02AAF2` |
| Miss | — | Clear `$09AE` bit `$0100`; CLC |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$00D4`/`$00D6` | In | Standard / extended warp list pointers |
| `$09A6`/`$09A8` | In | Player tile X/Y |
| `$09A2`/`$09A4` | In | Player pixel X/Y |
| `$09AE` | Out | Bit `$0100` cleared on miss |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `CheckWarpAndChest` | Caller |
| `ConvertWarpToPixels` | Tile rect → pixel bounds |
| `ExecuteWarp` | Standard warp handler |
| `code_02AAF2` | Extended/stair forced-walk handler |

### ConvertWarpToPixels

`ConvertWarpToPixels` converts a warp rectangle definition (tile origin + tile size) into a pixel bounding box for precise player overlap testing. On entry, X points to the warp entry; bytes 0–3 are origin X, origin Y, width, height in tile units.

Each coordinate is multiplied by 16 (four ASL operations) to convert to pixels. Width and height extents have `$0F` subtracted for inclusive edge testing. Results are stored in `$00`/`$02` (origin) and `$04`/`$06` (max bounds).

**Algorithm:**

| Output | Calculation |
|--------|-------------|
| `$00` | `entry[0] × 16` (pixel origin X) |
| `$02` | `entry[1] × 16` (pixel origin Y) |
| `$04` | `entry[2] × 16 − $0F` (pixel max X) |
| `$06` | `entry[3] × 16 − $0F` (pixel max Y) |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| X (in) | In | Warp entry pointer |
| `$00`/`$02` | Out | Pixel origin X/Y |
| `$04`/`$06` | Out | Pixel max X/Y |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `CheckWarpRectangles` | Called after tile-level AABB pass |

### ExecuteWarp

`ExecuteWarp` sets up all parameters for a scene transition when a standard warp rectangle is triggered. It copies the destination scene ID to `$0642`, spawn position/flags to `$064C`–`$0652`, and saves return-warp data to `$0B08`–`$0B12` (tile rect + camera nibble from `$06D6`–`$06DC`).

The warp entry pointer (adjusted by +4) is saved to `$0AF4`–`$0AF6` with bank byte from `scene_warps`. If transition flag `$0650` bit `$80` is clear, returns **SEC** for instant warp (caller initiates fade + scene reload). If bit `$80` is set, the flag is stripped and the pointer is saved to `$0AF0`–`$0AF2` for the animated transition handler.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Save warp entry pointer → `$0AF4`–`$0AF6` |
| 2 | Copy destination scene → `$0642` |
| 3 | Copy spawn X/Y/flags/facing → `$064C`–`$0652` |
| 4 | Save return position + camera → `$0B08`–`$0B12` |
| 5 | If `$0650` bit `$80` clear → SEC (instant warp) |
| 6 | Else strip bit `$80`; save pointer → `$0AF0`–`$0AF2`; SEC (animated) |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0642` | Out | Destination scene ID (`scene_next`) |
| `$064C`–`$0652` | Out | Spawn position, transition flags, facing |
| `$0B08`–`$0B12` | Out | Return-warp save area |
| `$0AF0`–`$0AF6` | Out | Warp entry pointer(s) for transition handler |
| `$0650` | In/Out | Transition flags; bit `$80` = animated |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `CheckWarpRectangles` | Caller on standard warp hit |
| `scene_warps` | Warp entry data source |
| `chunk_03BAE1.asm` | Transition handler consumes saved params |
| `code_02AAF2` | Extended path eventually reaches same transition |

### code_02AAF2

**Extended/stair warp handler** reached when `CheckWarpRectangles` pass 2 finds a pixel-level hit on a 13-byte `stair_warp` entry. Guards against re-entry when `$09AE` bit `$0100` is already set, copies transition flags from the warp entry, calls `func_03E050` for transition prep, then dispatches `StartForcedWalk`. Returns **carry set** on success.

**Source:**

```725:749:../../../extracted/system/engine/warps_interaction.asm
code_02AAF2 {
    LDA $playerFlags
    BIT #$0100
    BEQ loc_02AAFB
    RTS 

  loc_02AAFB:
    TXA 
    CLC 
    ADC #$0007
    STA $0650
    LDA #$0000
    STA $playerSpeedEw
    STA $playerSpeedNs
    SEP #$20
    LDY $0004, X
    STY $0652
    LDA $0006, X
    STA $scrollStepTableBase
    JSL $@chunk_03BAE1.func_03E050
    JSR $&StartForcedWalk
    REP #$20
    SEC 
    RTS 
}
```

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `CheckWarpRectangles` | Caller on extended warp hit |
| `StartForcedWalk` | Spawns directional forced-walk actor |
| `chunk_03BAE1.func_03E050` | Transition prep before walk |

### StartForcedWalk

`StartForcedWalk` dispatches a directional forced-walk COP actor when the player triggers an extended/stair warp. Called from `code_02AAF2` after transition prep via `func_03E050`.

It sets `$09AE` bit `$0100` (warp-in-progress), sets player actor bit `$2000`, and reads direction from `$06E0`. The low nibble selects the base direction; flag bits `$0020`/`$0010`/`$0080` on the high byte select west/east/north respectively. Default direction is south. The matching `ForcedWalk` actor from `forced_walk.asm` is spawned via `SpawnBefore` with the player actor as direct page context.

**Algorithm:**

| Direction bit | Actor spawned |
|---------------|---------------|
| `$06E0` bit `$0020` | `ForcedWalkWest` |
| `$06E0` bit `$0010` | `ForcedWalkEast` |
| `$06E0` bit `$0080` | `ForcedWalkNorth` |
| Default | `ForcedWalkSouth` |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$09AE` | Out | Bit `$0100` set (warp-in-progress) |
| `$06E0` | In | Direction data from stair warp entry |
| `$06E2` | Out | Zeroed before direction decode |
| Player actor `$0010` | Out | Bit `$2000` set |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `code_02AAF2` | Caller from extended warp path |
| `forced_walk.ForcedWalk{North,South,East,West}` | Spawned walk actors |
| `chunk_03BAE1.func_03E050` | Transition prep before forced walk |

## Warp System — Rectangle Detection + Scene Transition

Warp data is organized per scene in `scene_warps.asm` (bank `$01`). Each scene entry is a `warp_def` containing two delimited arrays (see `us/structs.json`):

| Array | Struct | Entry size | Terminator | Purpose |
|-------|--------|------------|------------|---------|
| Standard | `scene_warp` | 12 bytes | `$FF` in byte 0 | Doorways, area exits — instant or animated transition |
| Extended | `stair_warp` | 13 bytes | `$FF` in byte 0 | Staircases — forced player walk before transition |

### `scene_warp` Layout (12 bytes)

| Offset | Type | Field |
|--------|------|-------|
| 0 | Byte | Origin tile X |
| 1 | Byte | Origin tile Y |
| 2 | Byte | Rectangle width (tiles) |
| 3 | Byte | Rectangle height (tiles) |
| 4 | Byte | Destination scene ID |
| 5–6 | Word | Spawn X position |
| 7–8 | Word | Spawn Y position |
| 9 | Byte | Transition flags (`$0650`; bit `$80` = animated) |
| 10–11 | Word | Facing / extra param (`$0652`) |

### Detection Pipeline

```
InitWarpTable (scene load)
  $00D4 ← scene_warps[scene].standard_list
  $00D6 ← byte after $FF terminator (extended list)

CheckWarpRectangles (every frame)
  ├─► Pass 1: standard 12-byte entries [$00D4]
  │     tile AABB → pixel AABB → ExecuteWarp
  └─► Pass 2: extended 13-byte entries [$00D6]
        tile AABB → pixel AABB → forced-walk path
```

Two-level testing prevents false triggers at tile boundaries: the tile test is a fast reject; the pixel test using `$09A2`/`$09A4` (8-pixel precision player position) ensures the player's hitbox overlaps the warp volume.

### Scene Transition Flow

```
CheckWarpAndChest (main loop, every frame)
  └─► CheckWarpRectangles
        ├─► [standard warp hit]
        │     ExecuteWarp → sets $0642, $064C–$0652, $0B08–$0B12
        │     SEC return → chunk_03BAE1 transition handler
        │       ├─ $0650 bit $80 clear: instant fade + scene reload
        │       └─ $0650 bit $80 set: animated transition (saved $0AF0)
        └─► [extended warp hit]
              code_02AAF2
                ├─ guard: $09AE bit $0100 clear
                ├─ func_03E050 (transition prep)
                └─ StartForcedWalk → ForcedWalk{North,South,East,West}
                      └─ walk completes → ExecuteWarp path
```

Return-warp data at `$0B08`–`$0B12` allows the destination scene to send the player back to the exact tile and camera position they left from.

### Chest and Barrier Tables

`table_01ADA8` (bank `$01`) maps scene index → binary blob of 4-byte entries:

| Offset | Meaning |
|--------|---------|
| 0 | Tile X (bit `$80` set = end of table) |
| 1 | Tile Y |
| 2 | Item ID (chest contents) |
| 3 | Event flag index (via `SetEventFlag_0200` / `TestEventFlag_0200`) |

`PlaceBarrierTiles` uses the same table with a different interpretation: entries with flag set and bit `$80` clear become impassable 2×2 barrier patterns for blocked passages (e.g. boulder events).

## Related Documentation

| Document | Relevance |
|----------|-----------|
| [hardware-and-init.md](hardware-and-init.md) | Main loop, VBlank, `UpdateFrame_Render` / `UpdateFrame_Dialogue` |
| [scene-script.md](scene-script.md) | Scene script interpreter, scene load pipeline |
| [spc-transfer.md](spc-transfer.md) | SPC700 music upload, scene command `$11` |
| [camera-scrolling.md](camera-scrolling.md) | Camera scrolling, map buffer layout (`$7E:A000`) |
| [map-coordinates.md](map-coordinates.md) | `TileCoordsToMapIndex`, `PixelToVramAddress` for event blocks |
| [../bank00/event-flags.md](../bank00/event-flags.md) | Flag `$0200`–`$02FF` range used by event blocks |
| [../../cop-commands-reference.md](../../cop-commands-reference.md) | COP `$19` MusicAndText, `$32`–`$34` BG change commands |
