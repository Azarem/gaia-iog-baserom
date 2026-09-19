# Bank $02 — Map Coordinate Helpers

*Part of the [Bank $02 Documentation Suite](readme.md)*

**Bank:** `$02` (FastROM; accessed via `$@` long calls from other banks)  
**Document scope:** Tile/pixel coordinate transforms, map-buffer index navigation, and directional collision cascade probes.  
**ASM source:** [`map_coords.asm`](../../../extracted/system/engine/map_coords.asm) (block: `map_coords`, scene: `engine`)  
**Last updated:** 2026-09-07

Map coordinate helpers serve scrolling (shared `$18`/`$1C` with [`camera-scrolling.md`](camera-scrolling.md)), event/COP scripts, and player movement collision cascades. The `?INCLUDE 'tile_collision'` directive makes this file the bridge between scroll math and collision probing in [`tile-collision.md`](tile-collision.md).

**Related:** [`camera-scrolling.md`](camera-scrolling.md) · [`tile-collision.md`](tile-collision.md) · [`game-systems.md`](game-systems.md) · [`player-movement.md`](player-movement.md)

## Block Layout (map_coords)

```
$02B0A3 ├─ TileCoordsToMapIndex ───────────────────────┤
        │  PixelToVramAddress / MapIndexMove*          │  map_coords
        │  ProbeRightTiles / ProbeLeftTiles            │
$02B20E └──────────────────────────────────────────────┘
```

> **Note:** `map_coords` and `tile_collision` are **not contiguous** in ROM. Roughly 12 KB of unrelated engine code sits between `$02B20E` and `$02E102`. They link at compile time via `?INCLUDE 'tile_collision'` in `map_coords.asm`.

## map_coords.asm

Map coordinate helpers serve scrolling (shared `$18`/`$1C`), event/COP scripts, and player movement collision cascades. The `?INCLUDE 'tile_collision'` directive makes this file the bridge between scroll math and collision probing.

| Address | Name | Description |
|---------|------|-------------|
| `$02B0A3` | TileCoordsToMapIndex | TileCoordsToMapIndex converts tile coordinates in $18 (column) and $1C (row) into a 16-bit byte offset into the decom... |
| `$02B0CF` | PixelToVramAddress | PixelToVramAddress converts pixel coordinates in $1A (X) and $1E (Y) to a BG1 nametable VRAM word address. |
| `$02B0F6` | MapIndexMoveRight | MapIndexMoveRight advances a 16-bit packed map index in $02 one cell to the right. |
| `$02B113` | MapIndexMoveLeft | MapIndexMoveLeft is the mirror of MapIndexMoveRight. |
| `$02B132` | MapIndexMoveDown | MapIndexMoveDown advances the map index at $02 one row downward on layer 0. |
| `$02B14E` | MapIndexMoveDown_L1 | MapIndexMoveDown_L1 is identical to MapIndexMoveDown except it uses $0695 (layer 1 map row width) as the page-carry s... |
| `$02B168` | ProbeRightTiles | ProbeRightTiles implements a rightward collision cascade for diagonal movement. |
| `$02B1BB` | ProbeLeftTiles | ProbeLeftTiles is the mirror cascade for leftward diagonal movement. |

### TileCoordsToMapIndex

`TileCoordsToMapIndex` converts tile coordinates in `$18` (column) and `$1C` (row) into a 16-bit byte offset into the decompressed map buffer. The row is multiplied by the map width in columns (`$0693`) via `SignedMultiply`; the column nibble (`$18 & $0F`) and row high nibble (`$18 >> 4`) are added to form the final index.

The result is returned in the X register (low byte) with the high byte on the stack. This packed index format is shared across scrolling, collision, and event systems. Event blocks, warps, and COP collision handlers JSL to this routine.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Row `$1C` × 16 → push; multiply by `$0693` via `SignedMultiply` |
| 2 | Add column nibble `$18 & $0F` to low byte |
| 3 | Add row high nibble `$18 >> 4` to high byte |
| 4 | Return index in X (PLX restores high byte to X) |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$18` | In | Tile column (packed: low nibble = col, high nibble = row fragment) |
| `$1C` | In | Tile row |
| `$0693,X` | In | Map width in columns |
| X | Out | 16-bit map byte index |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `hardware_math.SignedMultiply` | Row × width |
| `event_blocks.asm` / `warps_interaction.asm` | External JSL callers |
| `RenderScrollRow` / `RenderScrollColumn` | Share `$18`/`$1C` convention |

### PixelToVramAddress

`PixelToVramAddress` converts pixel coordinates in `$1A` (X) and `$1E` (Y) to a BG1 nametable VRAM word address. Both coordinates are aligned to the 8-pixel grid (`& $F8`), then combined into a 32×32 tilemap offset formula.

The X component contributes via `(Y & $F8) × 4 + (X & $F8) >> 3`, plus `$0100` if X bit 8 is set (second nametable column). The final address adds the BG1 base `$1000`. Used for queued dynamic tile writes such as chests and event blocks.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Y aligned = `$1E & $F8`; × 4 → stack |
| 2 | X aligned = `$1A & $F8`; >> 3; add to stack |
| 3 | If `$1A` bit 8: add `$0100` |
| 4 | Pop Y component; add `$1000`; return in A |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$1A` | In | Pixel X |
| `$1E` | In | Pixel Y |
| A | Out | VRAM word address (BG1 base `$1000`) |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `event_blocks.asm` | Dynamic tile write caller |
| `cop_handlers_map.asm` | COP tile overlay caller |

### MapIndexMoveRight

`MapIndexMoveRight` advances a 16-bit packed map index in `$02` one cell to the right. The low byte column nibble is incremented; if it overflows past `$0F`, the high byte (row) is incremented and `$F0` is added to realign the column nibble to the next row start.

This navigation convention matches the collision overlay layout at `$7FC000` and mirrors `MapCellRight` in `tile_collision.asm`.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Increment low byte of `$02` |
| 2 | If column nibble ≠ overflow (`BIT $0F` = 0): return |
| 3 | Increment high byte; add `$F0` to low byte for row alignment |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$02` | In/Out | 16-bit packed map index |
| X | Out | Updated index (on return) |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `MapCellRight` | Parallel cell navigation in tile_collision |
| `ProbeRightTiles` | Uses index navigation indirectly via MapCell* |

### MapIndexMoveLeft

`MapIndexMoveLeft` is the mirror of `MapIndexMoveRight`. It decrements the column nibble in the packed index at `$02`. When the nibble underflows to `$0F` (past column 0), the high byte row is decremented and `$F0` is subtracted to align to the previous row's last column.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Decrement low byte of `$02` |
| 2 | If column nibble ≠ `$0F`: return |
| 3 | Decrement high byte; subtract `$F0` from low byte |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$02` | In/Out | 16-bit packed map index |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `MapCellLeft` | Parallel in tile_collision |

### MapIndexMoveDown

`MapIndexMoveDown` advances the map index at `$02` one row downward on layer 0. It adds `$10` to the low byte (next row within the same 16-column page). On carry (crossing a 16-row page boundary), it adds the map width in columns (`$0693`) to the high byte.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `$02` low byte += `$10` |
| 2 | If no carry: return |
| 3 | High byte += `$0693` (map row stride) |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$02` | In/Out | Map index |
| `$0693` | In | Layer 0 row width |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `MapCellDown` | Parallel cell navigation |
| `MapIndexMoveDown_L1` | Layer 1 variant using `$0695` |

### MapIndexMoveDown_L1

`MapIndexMoveDown_L1` is identical to `MapIndexMoveDown` except it uses `$0695` (layer 1 map row width) as the page-carry stride instead of `$0693`. Layer 1 maps may have a different column count than layer 0, requiring a separate navigation helper.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `$02` += `$10` |
| 2 | If carry: high byte += `$0695` |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$02` | In/Out | Map index |
| `$0695` | In | Layer 1 row width |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `MapIndexMoveDown` | Layer 0 counterpart |

### ProbeRightTiles

`ProbeRightTiles` implements a rightward collision cascade for diagonal movement. It is the primary cross-chunk entry from `player_move_diag.asm`. The routine probes multiple tile positions in sequence, looking for passable ramp (`$0A`) or semi-solid (`$05`) tiles that allow sliding around north-facing walls (`$09`).

The cascade begins at the current top-left corner via `ProbeCurrentTL`, then offsets X by +8 pixels and re-probes via `TileProbeMain`. If blocked by a north wall, it checks the cell to the left. It then walks right through adjacent cells and future-position corners (`ProbeFutureTL`, `ProbeFutureBL`), returning carry clear when a ramp path is found.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `ProbeCurrentTL`; offset `$1A` += 8; `TileProbeMain` |
| 2 | If type `$0A` or `$05`: pass (CLC/RTS) |
| 3 | If type `$09`: check left cell for `$0A` |
| 4 | `MapCellRight` → `ReadCollisionNibble`; check `$0A`/`$05` |
| 5 | `ProbeFutureTL` / `ProbeFutureBL`; check `$0A`/`$05` |
| 6 | Default: SEC (blocked) or CLC (ramp found) |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$1A` | In/Out | Probe X (adjusted +8 mid-routine) |
| `$00` | Temp | Map cell index (via TileProbeMain) |
| A | Out | Collision type from last probe |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `ProbeCurrentTL` | Initial corner probe |
| `TileProbeMain` | Direct probe after X offset |
| `MapCellRight` / `MapCellLeft` | Adjacent cell walk |
| `ProbeFutureTL` / `ProbeFutureBL` | Destination corner probes |
| `player_move_diag.asm` | Primary caller |

### ProbeLeftTiles

`ProbeLeftTiles` is the mirror cascade for leftward diagonal movement. It begins at `ProbeCurrentTR`, offsets X by −8 pixels, and walks adjacent cells looking for ramp (`$0A`) or semi-solid (`$05`) passability.

South-facing walls (`$06`) receive special handling: when encountered, the routine checks the cell to the left for semi-solid (`$05`) before continuing the cascade. Future-position probes use `ProbeFutureTR` and `ProbeFutureBR`.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `ProbeCurrentTR`; `$1A` −= 8; `TileProbeMain` |
| 2 | If `$0A`: CLC return; if `$05`: return |
| 3 | If `$06`: check left cell for `$05` |
| 4 | `MapCellRight` → probe; check `$0A`/`$05` |
| 5 | `ProbeFutureTR` / `ProbeFutureBR`; check passability |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$1A` | In/Out | Probe X (adjusted −8) |
| A | Out | Collision type |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `ProbeRightTiles` | Mirror cascade |
| `ProbeCurrentTR` | Initial corner |
| `player_move_diag.asm` | Primary caller |

## See Also

- [`camera-scrolling.md`](camera-scrolling.md) — camera scrolling, dirty-strip DMA, shared `$18`/`$1C` tile coordinates
- [`tile-collision.md`](tile-collision.md) — probe helpers called by cascade routines (`ProbeCurrent*`, `TileProbeMain`, `MapCell*`)
- [`player-movement.md`](player-movement.md) — diagonal movement callers (`ProbeRightTiles` / `ProbeLeftTiles`)
- [`game-systems.md`](game-systems.md) — event blocks and warps that JSL `TileCoordsToMapIndex`
