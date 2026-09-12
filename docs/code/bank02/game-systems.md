# Bank $02 — Game World Systems

**Bank:** `$02` (FastROM; accessed via `$@` long calls from other banks)  
**Address range:** `$02A040`–`$02AB8A`  
**Source:** [`music_actors.asm`](../../../extracted/system/engine/music_actors.asm), [`text_measure.asm`](../../../extracted/system/engine/text_measure.asm), [`event_blocks.asm`](../../../extracted/system/engine/event_blocks.asm), [`warps_interaction.asm`](../../../extracted/system/engine/warps_interaction.asm)  
**Scene:** `engine`

**Related docs:** [hardware-and-init.md](hardware-and-init.md) · [scene-engine.md](scene-engine.md) · [camera-and-map.md](camera-and-map.md) · [../bank00/event-flags.md](../bank00/event-flags.md) · [../../cop-commands-reference.md](../../cop-commands-reference.md)



## Overview

Four ASM compilation units in bank `$02` implement **interactive world state** — the glue between the scene script loader ([`chunk_03BAE1.asm`](../../../extracted/system/chunk_03BAE1.asm)), the per-frame main loop ([`system_core.asm`](../../../extracted/system/engine/system_core.asm)), and player-facing map changes (doors opening, chests, warps). Together they:

1. **Synchronize music and rendering** via COP actors that block input while the SPC700 finishes a track.
2. **Measure dialogue text width** so scroll offsets are pre-computed when entering a new scene.
3. **Apply persistent map tile swaps** driven by event flags — both instantly at scene load and animated during COP scripts.
4. **Detect warp rectangles and chest interactions** each frame, triggering scene transitions or item pickup flows.

These routines sit above the hardware/VBlank layer in [hardware-and-init.md](hardware-and-init.md) and below the camera/scrolling engine documented in [camera-and-map.md](camera-and-map.md). Map coordinate helpers live in [`map_coords.asm`](../../../extracted/system/engine/map_coords.asm). Event flag semantics are defined in [../bank00/event-flags.md](../bank00/event-flags.md).

### Block Layout

```
$02A040 ┌─ MusicPlaybackActor ─────────────────────┐
        │  MusicRenderSync / IsMusicPlaying         │  music_actors
$02A11B ├─ MeasureDialogueWidth ────────────────────┤  text_measure
        │  dialogue_measure_format / CountTextGlyphs│
$02A1E9 ├─ ApplyAllEventBlocks ─────────────────────┤
        │  SwapEventBlockTiles / FlushVramWriteQueue│  event_blocks
        │  LookupEventBlock / AnimateEventBlock …   │
$02A5DD ├─ CheckWarpAndChest ───────────────────────┤
        │  PlaceBarrierTiles / HandleChestInteraction│  warps_interaction
        │  ChestOpeningActor … StartForcedWalk      │
$02AB8A └─ (camera_tilemap continues) ──────────────┘
```



## music_actors.asm

COP-based actors and a query routine that coordinate **music playback lifecycle** with the render pipeline. When the `MusicAndText` COP command (opcode `$19`) fires, `cop_handlers_actors.asm` allocates an actor and points it at `MusicPlaybackActor`.

| Address | Name | Size | Description |
|---------|------|------|-------------|
| `$02A040` | MusicPlaybackActor | 165 B | MusicPlaybackActor is the primary COP coroutine spawned by the MusicAndText command. |
| `$02A0E5` | MusicRenderSync | 37 B | MusicRenderSync is a one-shot render-sync child spawned by MusicPlaybackActor after the music track reaches idle. |
| `$02A10A` | IsMusicPlaying | 17 B | IsMusicPlaying is a lightweight query routine callable from any bank via JSL. |

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

**Source:**

```11:86:../../../extracted/system/engine/music_actors.asm
MusicPlaybackActor {
    LDA $06F2
    STA $7F0010, X
    COP [SpawnAfterFlags] ( @chunk_03BAE1.func_03E1D6, #$2000 )
    // ... spawn failure, joypad mask, music wait loop ...
}

code_02A0DD {
    LDA #$0080
    TRB $09EC
    COP [Die]
}
```

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
| `cop_handlers_actors.asm` — `MusicAndText` | Spawns this actor with music ID and text pointer |
| `MusicRenderSync` | Child actor spawned after music ends |
| `chunk_03BAE1.func_03E1D6` | Visual overlay child respawned each cycle |
| `IsMusicPlaying` | Query used by other actors waiting for same idle state |



### MusicRenderSync

`MusicRenderSync` is a one-shot render-sync child spawned by `MusicPlaybackActor` after the music track reaches idle. It bridges the gap between music ending and visible dialogue display by forcing a full render frame after a fixed delay.

The actor waits 72 frames (`WaitByte #48`), clears actor flag bit `$1000`, zeroes the joypad mask at `$065A`, saves and restores DBR from the text pointer bank byte at `$22`, then calls `UpdateFrame_Render` followed by `sub_03E255` (dialogue box opener in chunk `$03`). It then dies. This ensures the dialogue frame is laid out on screen before the parent actor resumes and waits for the APU handshake.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `WaitByte #48` (72 frames) |
| 2 | Clear actor flag bit `$1000` on self |
| 3 | Zero `$065A` (full joypad block) |
| 4 | Set DBR from `$22`; set Y from `$20` (text pointer) |
| 5 | `JSL UpdateFrame_Render` |
| 6 | `JSL sub_03E255` (open dialogue sizing frame) |
| 7 | Restore DBR/P; `Die` |

**Source:**

```88:107:../../../extracted/system/engine/music_actors.asm
MusicRenderSync {
    COP [WaitByte] ( #48 )
    LDA #$1000
    TRB $12
    // ... zero joypad, render frame, dialogue opener ...
    COP [Die]
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$065A` | Out | Zeroed — full input block during render |
| `$20`/`$22` (actor) | In | Text pointer and bank for `sub_03E255` |
| `$0012` (self) | Out | Flag bit `$1000` cleared after wait |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `MusicPlaybackActor` | Parent that spawns this actor |
| `system_core.UpdateFrame_Render` | VBlank-synchronized render pass |
| `chunk_03BAE1.sub_03E255` | Dialogue frame layout routine |
| `APUWaitFixes.patch.asm` | Retranslation patch may spawn this directly |

### IsMusicPlaying

Lightweight **`JSL` query** callable from any bank to test whether a music-and-dialogue sequence is still active. Returns **carry clear** when both `$06FA` (`musicTransitionState`) is zero **and** `$09EC` bit `$0080` is clear; otherwise returns **carry set**. Other actors use this to avoid overlapping music/text flows while `MusicPlaybackActor` holds the joypad and display flags.

**Source:**

```114:126:../../../extracted/system/engine/music_actors.asm
IsMusicPlaying {
    LDA $musicTransitionState
    BNE loc_02A119
    LDA $displayModeFlags
    BIT #$0080
    BNE loc_02A119
    CLC 
    RTL 

  loc_02A119:
    SEC 
    RTL 
}
```

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `MusicPlaybackActor` | Sets `$09EC` bit `$0080` during sequence |
| `cop_handlers_actors.asm` | Callers waiting for music idle |

### code_02A0DD

Shared **cleanup epilogue** for `MusicPlaybackActor` when spawn fails or the music/text sequence completes. Clears `$09EC` bit `$0080` (music-and-text active flag) and dies via COP.

**Source:**

```87:91:../../../extracted/system/engine/music_actors.asm
code_02A0DD {
    LDA #$0080
    TRB $displayModeFlags
    COP [Die]
}
```

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `MusicPlaybackActor` | Jump target on failed spawn or sequence end |

## text_measure.asm

Pre-computes **horizontal dialogue scroll offset** when the player enters a scene whose target dialogue (`$0D6E`) differs from the current scene. Ensures multi-line dialogue boxes scroll correctly on first display without a visible width recalculation hitch.

| Address | Name | Size | Description |
|---------|------|------|-------------|
| `$02A11B` | MeasureDialogueWidth | 78 B | MeasureDialogueWidth runs during scene entry initialization when the destination scene's dialogue differs from the sc... |
| `$02A169` | dialogue_measure_format | 9 B | dialogue_measure_format is a fixed ConsoleString template passed to sub_03E255 during dialogue width measurement. |
| `$02A172` | CountTextGlyphs | 119 B | CountTextGlyphs walks a text byte stream starting at [$3E],Y and returns the total visible glyph count in $00. |

### MeasureDialogueWidth

`MeasureDialogueWidth` runs during scene entry initialization when the destination scene's dialogue differs from the scene currently loaded. It compares `$0D6E` (target scene ID for dialogue pre-measure) against `$0644` (`scene_current`) and returns immediately if they match — no scroll adjustment is needed.

When scenes differ, it calls `CountTextGlyphs` to walk the text stream at `($3E)` and tally visible character width. If the count is zero, it exits. Otherwise it computes a scroll increment: `(count − $12) ^ $FF + 1`, masked to even bytes (`AND #$FE`), and adds the result to the running accumulator at `$0998`.

Before measuring, it opens a sizing dialogue frame via `sub_03E255` using the format template `dialogue_measure_format` (`[DLG:7,7][SIZ:A,1][SFX:0]`). It then calls `sub_03E255` again with the actual scene text pointer. Register `$00B4/$00B5` is set to `$E0/$00` for dialogue bank context during the measurement pass.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | If `$0D6E = $0644`, return |
| 2 | `JSR CountTextGlyphs`; if `$00 = 0`, return |
| 3 | Scroll delta = `(count − $12) ^ $FF + 1`, even-aligned |
| 4 | Set `$00B4 = $E0`, `$00B5 = $00` |
| 5 | Call `sub_03E255` with `dialogue_measure_format` |
| 6 | Add delta to `$0998` |
| 7 | Call `sub_03E255` with text at `($3E)` |
| 8 | Return |

**Source:**

```11:57:../../../extracted/system/engine/text_measure.asm
MeasureDialogueWidth {
    LDA $0D6E
    CMP $scene_current
    BNE loc_02A124
    RTL 
  // ... CountTextGlyphs, scroll delta, sub_03E255 calls ...
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0D6E` | In | Target scene ID for dialogue width pre-measure |
| `$0644` | In | Current scene ID |
| `$3E` | In | Text stream pointer |
| `$0998` | Out | Dialogue horizontal scroll offset accumulator |
| `$00` | Temp | Glyph count from `CountTextGlyphs` |
| `$00B4`/`$00B5` | Out | Dialogue bank context (`$E0`/`$00`) |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `chunk_03BAE1.asm` (~line 5448) | Called during scene load after event blocks |
| `CountTextGlyphs` | Internal helper for glyph tally |
| `dialogue_measure_format` | Format string for sizing frame |
| `chunk_03BAE1.sub_03E255` | Dialogue frame opener/sizer |
| `chunk_03BAE1.func_03E050` | Runtime scroll logic that consumes `$0998` |

### dialogue_measure_format

Fixed **`ConsoleString` template** passed to `sub_03E255` during dialogue width measurement. Opens a minimal sizing dialogue frame (`[DLG:7,7][SIZ:A,1][SFX:0]`) so glyph counting runs against the same layout engine used in gameplay, without displaying scene text.

**Source:**

```59:59:../../../extracted/system/engine/text_measure.asm
dialogue_measure_format `[DLG:7,7][SIZ:A,1][SFX:0]`
```

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `MeasureDialogueWidth` | Sole consumer — sizing frame before real text measure |
| `chunk_03BAE1.sub_03E255` | Dialogue frame layout routine |

### CountTextGlyphs

`CountTextGlyphs` walks a text byte stream starting at `[$3E],Y` and returns the total visible glyph count in `$00`. It is the core width calculator used by `MeasureDialogueWidth` and mirrors the text engine's own parsing rules for control codes.

Plain characters (byte `< $C0`) increment the counter. `$CA` terminates the string. `$CC` reads the next byte as a repeat count and adds it to the total. Control codes in the `$C0`–`$CB` range skip their payload bytes without counting. Dictionary references `$D6` and `$D7` dereference entries in `dictionary_01EBA8` and `dictionary_01F54D` respectively, then recursively count nested string characters until `$CA`.

The routine increments `$3E` before walking (text pointer advanced past a leading byte) and preserves flags via PHP/PLP.

**Algorithm:**

| Byte range | Action |
|------------|--------|
| `< $C0` | Count += 1; advance Y |
| `$CA` | Return count in `$00` |
| `$CC` | Count += next byte; advance Y by 2 |
| `$C0`–`$CB` (not `$CC`) | Skip payload; advance Y |
| `$D6` | Lookup `dictionary_01EBA8[index]`; count nested chars |
| `$D7` | Lookup `dictionary_01F54D[index]`; count nested chars |

**Source:**

```61:150:../../../extracted/system/engine/text_measure.asm
CountTextGlyphs {
    PHP 
    REP #$20
    INC $3E
    STZ $00
    // ... byte walk loop, dictionary dereference ...
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$3E` | In/Out | Text stream pointer (incremented on entry) |
| `$00` | Out | Accumulated glyph count |
| Y | Temp | Index into `[$3E],Y` |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `MeasureDialogueWidth` | Sole caller |
| `dictionary_01EBA8` | `$D6` dictionary table (bank `$01`) |
| `dictionary_01F54D` | `$D7` dictionary table (bank `$01`) |



## event_blocks.asm

Implements the **event flag → tile swap** system. Each event block definition in `event_block_table` (bank `$01`) describes a source rectangle of hidden off-screen tiles and a destination rectangle in the visible tilemap. When the corresponding flag in `$0A20`–`$0A3F` is set, the hidden tiles are copied to the visible destination, revealing previously hidden terrain (paths, platforms, walls) after enemy defeats.

| Address | Name | Size | Description |
|---------|------|------|-------------|
| `$02A1E9` | ApplyAllEventBlocks | 55 B | ApplyAllEventBlocks performs a bulk scan of all 256 event flags in the $0200–$02FF range at scene load. |
| `$02A220` | SwapEventBlockTiles | 240 B | SwapEventBlockTiles performs an instant foreground/background tile exchange over a rectangular map region. |
| `$02A310` | FlushVramWriteQueue | 83 B | FlushVramWriteQueue drains pending tile graphics writes to SNES VRAM during the VBlank render path. |
| `$02A363` | LookupEventBlock | 69 B | LookupEventBlock indexes into event_block_table by block ID (passed in A on entry). |
| `$02A3A8` | AnimateEventBlock | 357 B | AnimateEventBlock applies the same tile swap logic as SwapEventBlockTiles, but spreads work across multiple frames wi... |
| `$02A50D` | QueueVisibleTileVram | 126 B | QueueVisibleTileVram performs viewport culling and enqueues four VRAM write pairs for a single map tile if it falls w... |
| `$02A58B` | AdvanceEventColumn | 38 B | AdvanceEventColumn moves the event block iteration to the next column within the current row. |
| `$02A5B1` | AdvanceEventRow | 44 B | AdvanceEventRow moves the event block iteration to the next row. |

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

**Source:**

```14:48:../../../extracted/system/engine/event_blocks.asm
ApplyAllEventBlocks {
    PHP 
    SEP #$20
    LDY #$0000
    STY $04
  // ... bit scan loop, LookupEventBlock, SwapEventBlockTiles ...
}
```

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

**Source:**

```50:176:../../../extracted/system/engine/event_blocks.asm
SwapEventBlockTiles {
    PHP 
    PHY 
    REP #$20
    // ... layer mode select, TileCoordsToMapIndex, swap loops ...
}
```

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

**Source:**

```178:223:../../../extracted/system/engine/event_blocks.asm
FlushVramWriteQueue {
    TSX 
    LDY $0800
    BEQ loc_02A32F
    // ... stack pop loop or shortcut slot write ...
}
```

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

**Source:**

```225:262:../../../extracted/system/engine/event_blocks.asm
LookupEventBlock {
    ASL 
    ASL 
    ASL 
    TAY 
    // ... scene check, geometry load ...
}
```

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
| `cop_handlers_actors.asm` | COP `$32`/`$34` `StageBgChange` |
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

**Source:**

```264:459:../../../extracted/system/engine/event_blocks.asm
AnimateEventBlock {
    PHX 
    PHD 
    LDA #$0000
    TCD 
  // ... swap + queue loop, dual-layer BG2 path ...
}
```

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
| `cop_handlers_actors.asm` | COP `$33` `ApplyBgChange` loop |
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

**Source:**

```461:528:../../../extracted/system/engine/event_blocks.asm
QueueVisibleTileVram {
    PHP 
    REP #$20
    LDA $1A
    CLC 
    ADC #$0010
    // ... viewport test, tile lookup, VRAM queue ...
}
```

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

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | DEC `$9E`; if zero → return SEC (row complete) |
| 2 | `$1A += 16`; INC `$96`; INC `$9A` |
| 3 | Move source and dest map indices right |
| 4 | Return CLC |

**Source:**

```530:553:../../../extracted/system/engine/event_blocks.asm
AdvanceEventColumn {
    SEC 
    DEC $9E
    BNE loc_02A591
    RTS 
  // ... advance pixel X, column regs, map indices ...
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$9E` | In/Out | Remaining column count |
| `$1A` | Out | Pixel X (advanced by 16) |
| `$96`/`$9A` | Out | Destination/source column |
| `$00`/`$02` | Out | Dest/source map indices |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `AnimateEventBlock` | Called after each tile in column loop |
| `SwapEventBlockTiles` | Uses inline column advance (not this helper) |
| `map_coords.MapIndexMoveRight` | Map index arithmetic |



### AdvanceEventRow

`AdvanceEventRow` moves the event block iteration to the next row. It decrements the height counter `$A0` and returns **SEC** when all rows are complete.

When rows remain, it advances pixel Y by 16 (`$1E`), increments destination and source row registers (`$98`, `$9C`), and resets the column counter `$9E` from the original width `$A2`. Column position `$96` and source column `$9A` are restored from the block definition at `$A8` (saved during `LookupEventBlock`). Returns **CLC** to start the next row.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | DEC `$A0`; if zero → return SEC (all rows done) |
| 2 | `$1E += 16`; INC `$98`; INC `$9C` |
| 3 | Reset `$96`/`$9A` from `event_block_table+1/+5` at index `$A8` |
| 4 | `$9E = $A2` (restore width); return CLC |

**Source:**

```555:579:../../../extracted/system/engine/event_blocks.asm
AdvanceEventRow {
    SEC 
    DEC $A0
    BNE loc_02A5B7
    RTS 
  // ... advance pixel Y, reset columns from block def ...
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$A0` | In/Out | Remaining row count |
| `$1E` | Out | Pixel Y (advanced by 16) |
| `$98`/`$9C` | Out | Destination/source row |
| `$A8` | In | Block definition index |
| `$A2`/`$9E` | In/Out | Original width / restored column count |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `AnimateEventBlock` | Called when column loop completes |
| `LookupEventBlock` | Saves `$A8` used for column reset |
| `event_block_table` | Source for column reset values |



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

| Address | Name | Size | Description |
|---------|------|------|-------------|
| `$02A5DD` | CheckWarpAndChest | 19 B | CheckWarpAndChest is the top-level per-frame trigger dispatcher called from system_core.asm after player movement. |
| `$02A5F0` | PlaceBarrierTiles | 109 B | PlaceBarrierTiles writes impassable 2×2 barrier tile patterns to the map buffer for blocked passages. |
| `$02A65D` | HandleChestInteraction | 347 B | HandleChestInteraction implements the full chest-open flow when the player presses the action button facing a chest t... |
| `$02A7B8` | ChestOpeningActor | 219 B | ChestOpeningActor is the animated chest-open COP coroutine, structurally parallel to MusicPlaybackActor. |
| `$02A893` | ChestDialogueActor | 21 B | ChestDialogueActor is a short-lived child actor spawned by ChestOpeningActor after the item jingle completes. |
| `$02A8A8` | SetAnimStatePointer | 10 B | SetAnimStatePointer is a minimal helper that switches a target actor's animation state. |
| `$02A8B2` | DrawChestTiles | 165 B | DrawChestTiles writes a 2×2 chest lid tile pattern to $7EA000 and queues VRAM updates for all four corners. |
| `$02A957` | InitWarpTable | 36 B | InitWarpTable initializes warp list pointers for the current scene during scene load. |
| `$02A97B` | CheckWarpRectangles | 166 B | CheckWarpRectangles performs two-pass warp detection against the player position each frame. |
| `$02AA21` | ConvertWarpToPixels | 57 B | ConvertWarpToPixels converts a warp rectangle definition (tile origin + tile size) into a pixel bounding box for prec... |
| `$02AA5A` | ExecuteWarp | 203 B | ExecuteWarp sets up all parameters for a scene transition when a standard warp rectangle is triggered. |
| `$02AB25` | StartForcedWalk | 101 B | StartForcedWalk dispatches a directional forced-walk COP actor when the player triggers an extended/stair warp. |

### CheckWarpAndChest

Top-level **per-frame trigger dispatcher** called from [`system_core.asm`](../../../extracted/system/engine/system_core.asm) after player movement. Runs `CheckWarpRectangles` first; if no warp hit (carry clear), falls through to `HandleChestInteraction`. Either path may set carry on success. Four trailing `NOP` instructions pad the epilogue before restoring `P`.

**Source:**

```47:62:../../../extracted/system/engine/warps_interaction.asm
CheckWarpAndChest {
    PHP 
    REP #$20
    JSR $&CheckWarpRectangles
    BCS loc_02A5EA
    JSR $&HandleChestInteraction
    BCS loc_02A5EA

  loc_02A5EA:
    NOP 
    NOP 
    NOP 
    NOP 
    PLP 
    RTL 
}
```

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `system_core.asm` | Caller — main loop after movement |
| `CheckWarpRectangles` | First-pass warp rectangle test |
| `HandleChestInteraction` | Chest open when no warp active |

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

**Source:**

```51:104:../../../extracted/system/engine/warps_interaction.asm
PlaceBarrierTiles {
    PHP 
    REP #$20
    LDY $0646
    LDX $&table_01ADA8, Y
  // ... flag test, 2x2 barrier write ...
}
```

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
| `cop_handlers_script.TestEventFlag_0200` | Flag test on entry byte 3 |
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

**Source:**

```106:291:../../../extracted/system/engine/warps_interaction.asm
HandleChestInteraction {
    LDA $06EE
    BIT #$0200
    BEQ loc_02A666
  // ... guards, chest tile detect, table scan, item branches ...
}
```

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

**Source:**

```293:386:../../../extracted/system/engine/warps_interaction.asm
ChestOpeningActor {
    LDA $06F2
    STA $7F0010, X
    COP [SpawnAfterFlags] ( @chunk_03BAE1.func_03E1D6, #$2000 )
  // ... joypad lock, music wait, dialogue spawn ...
}

code_02A88B {
    LDA #$0080
    TRB $09EC
    COP [Die]
}
```

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



### ChestDialogueActor

`ChestDialogueActor` is a short-lived child actor spawned by `ChestOpeningActor` after the item jingle completes. It waits 72 frames, clears actor flag bit `$1000`, saves the text pointer from `$20` to `$0DB8`, and displays the item name wide string at `$24` via `ShowDialogueFrame`.

This actor bridges the music completion and the visible "You got [item]!" dialogue box.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `WaitByte #48` (72 frames) |
| 2 | Clear actor flag `$1000` |
| 3 | Save `$20` → `$0DB8` |
| 4 | `ShowDialogueFrame` with wide string at `$24` |
| 5 | `Die` |

**Source:**

```388:397:../../../extracted/system/engine/warps_interaction.asm
ChestDialogueActor {
    COP [WaitByte] ( #48 )
    LDA #$1000
    TRB $12
    LDA $20
    STA $0DB8
    LDY $24
    JSL $@dialogue_display.ShowDialogueFrame
    COP [Die]
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$20` (actor) | In | Saved text pointer → `$0DB8` |
| `$24` (actor) | In | Item name wide string pointer |
| `$0DB8` | Out | Persisted text pointer |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `ChestOpeningActor` | Parent spawner |
| `dialogue_display.ShowDialogueFrame` | Item name display |

### SetAnimStatePointer

Minimal helper that **switches a target actor's animation state pointer**. Stores the animation script address from `A` at `$0000,Y` and clears the animation step counter at `$0008,Y`. Called by `ChestOpeningActor` to set the player to wait/idle animation states during the chest-open sequence.

**Source:**

```412:417:../../../extracted/system/engine/warps_interaction.asm
SetAnimStatePointer {
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    RTS 
}
```

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `ChestOpeningActor` | Caller — player wait/idle animation swap |
| `player_transition_handlers.loc_00C432` / `loc_00C45A` | Animation state targets |

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

**Source:**

```406:482:../../../extracted/system/engine/warps_interaction.asm
DrawChestTiles {
    PHP 
    LDA $0000, X
    AND #$00FF
    STA $18
  // ... 2x2 tile write, QueueVisibleTileVram x4 ...
}
```

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

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `$00D4 = scene_warps[$0646]` |
| 2 | Scan entries: if byte 0 ≥ 0, advance X by 12 |
| 3 | On terminator (byte 0 negative): `$00D6 = X + 1` |
| 4 | Return |

**Source:**

```484:507:../../../extracted/system/engine/warps_interaction.asm
InitWarpTable {
    REP #$20
    LDA $0646
    TAX 
    LDA $&scene_warps, X
    STA $00D4
  // ... scan to terminator, store $00D6 ...
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0646` | In | Scene index |
| `$00D4` | Out | Standard warp list pointer |
| `$00D6` | Out | Extended/stair warp list pointer |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `chunk_03BAE1.asm` (~line 5453) | Scene load initialization |
| `scene_warps` | Per-scene warp definition table (bank `$01`) |
| `CheckWarpRectangles` | Consumer of `$00D4`/`$00D6` |



### CheckWarpRectangles

`CheckWarpRectangles` performs two-pass warp detection against the player position each frame. **Pass 1** iterates 12-byte `scene_warp` entries from `$00D4`. **Pass 2** iterates 13-byte `stair_warp` entries from `$00D6`. Each entry is terminated by `$FF` in byte 0.

Each candidate entry undergoes a two-level test: first a tile-level AABB against `$09A6`/`$09A8` (player tile coords), then a pixel-level test via `ConvertWarpToPixels` against `$09A2`/`$09A4` (8-pixel precision player position). Standard hit jumps to `ExecuteWarp`; extended hit jumps to `code_02AAF2` (forced-walk path). No hit clears `$09AE` bit `$0100` and returns carry clear.

**Algorithm:**

| Pass | Entry size | Hit action |
|------|------------|------------|
| 1 (standard) | 12 bytes | Tile AABB → pixel AABB → `ExecuteWarp` |
| 2 (extended) | 13 bytes | Tile AABB → pixel AABB → `code_02AAF2` |
| Miss | — | Clear `$09AE` bit `$0100`; CLC |

**Source:**

```509:603:../../../extracted/system/engine/warps_interaction.asm
CheckWarpRectangles {
    SEP #$20
    LDX $00D4
    BEQ loc_02A9C9
  // ... pass 1 standard, pass 2 extended, pixel tests ...
}
```

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

**Source:**

```605:639:../../../extracted/system/engine/warps_interaction.asm
ConvertWarpToPixels {
    LDA $0000, X
    AND #$00FF
    ASL 
    ASL 
    ASL 
    ASL 
    STA $00
  // ... Y origin, width/height max bounds ...
}
```

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

**Source:**

```641:710:../../../extracted/system/engine/warps_interaction.asm
ExecuteWarp {
    PHP 
    TXA 
    CLC 
    ADC #$0004
    STA $0AF4
  // ... copy warp params, return save, transition flag branch ...
}
```

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

**Source:**

```738:792:../../../extracted/system/engine/warps_interaction.asm
StartForcedWalk {
    REP #$20
    LDA #$0100
    TSB $player_flags
    LDY $player_actor
  // ... direction decode, SpawnBefore ForcedWalk* ...
}
```

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
| [scene-engine.md](scene-engine.md) | Scene script interpreter, scene load pipeline |
| [camera-and-map.md](camera-and-map.md) | Camera scrolling, map buffer layout (`$7E:A000`) |
| [../bank00/event-flags.md](../bank00/event-flags.md) | Flag `$0200`–`$02FF` range used by event blocks |
| [../../cop-commands-reference.md](../../cop-commands-reference.md) | COP `$19` MusicAndText, `$32`–`$34` BG change commands |
