# Bank $02 — Map Coordinate Helpers

*Part of the [Bank $02 Documentation Suite](README.md)*

**Bank:** `$02` (FastROM; accessed via `$@` long calls from other banks)  
**Document scope:** Tile/pixel coordinate transforms, map-buffer index navigation, and directional collision cascade probes.  
**ASM source:** [`map_coords.asm`](../../../extracted/system/engine/map_coords.asm) (block: `map_coords`, scene: `engine`)  
**Last updated:** 2026-09-07

> **Evidence labels.** Each major section is tagged with the kind of claim it makes: **[ASM]** = directly observed in the extracted asm of this block; **[INFERRED]** = interpretation of behavior that is not literally encoded in the file; **[XREF]** = cross-file / engine-wide convention stated elsewhere (not provable from this file alone). Sections that mix kinds split them into separately tagged bullets or paragraphs. The `.asm` files in `extracted/` are authoritative; where prose and asm comments disagree, the asm wins.

Convention (other file): map coordinate helpers are used by scrolling (shared `$18`/`$1C` with [`camera-scrolling.md`](camera-scrolling.md)), event/COP scripts, and player movement. The `?INCLUDE 'tile_collision'` directive links this compilation unit to collision helpers in [`tile-collision.md`](tile-collision.md).

**Related:** [`camera-scrolling.md`](camera-scrolling.md) · [`tile-collision.md`](tile-collision.md) · [`game-systems.md`](game-systems.md) · [`player-movement.md`](player-movement.md)

## Block Layout (map_coords)

*Evidence: [ASM]*

```
$02B0A3 ├─ TileCoordsToMapIndex ───────────────────────┤
        │  PixelToVramAddress / MapIndexMove*          │  map_coords
        │  FindSlopeForWestMove / FindSlopeForEastMove │
$02B20E └──────────────────────────────────────────────┘
```

`map_coords` (`db-us/blocks.json`: 176291–176654) and `tile_collision` (188674–189334) are not contiguous in ROM. They link at compile time via `?INCLUDE 'tile_collision'` in `map_coords.asm`.

## map_coords.asm

*Evidence: [ASM]*

| Address | Name | Description |
|---------|------|-------------|
| `$02B0A3` | TileCoordsToMapIndex | Tile coords `$18` / `$1C` + layer selector in `X` → map index in `X`. |
| `$02B0CF` | PixelToVramAddress | Pixel coords `$1A` / `$1E` → BG1 nametable VRAM word address in `A` (base `$1000`). |
| `$02B0F6` | MapIndexMoveRight | Index in `$02`: one cell east; result stored in `$02` and returned in `X`. |
| `$02B113` | MapIndexMoveLeft | One cell west; result in `X` only (`$02` not written back). |
| `$02B132` | MapIndexMoveDown | One row down (layer 0 stride `mapRowStrideL0` / `$0693`). |
| `$02B14E` | MapIndexMoveDown_L1 | Same as down-move with `mapRowStrideL1` / `$0695`. |
| `$02B168` | FindSlopeForWestMove | Slope probe for `DispatchWestMove` (`player_move_west.asm`). |
| `$02B1BB` | FindSlopeForEastMove | Slope probe for `DispatchEastMove` (`player_move_east.asm`). |

### TileCoordsToMapIndex

Computes the packed map index documented in the file header: 16×16-tile pages, row-major, stride from `mapRowStrideL0,X` (layer 0 when `X=0`, layer 1 when `X=2`). Row `$1C` is shifted left four times (×16), multiplied by the stride via `Multiply8x8Unsigned`, then combined with `$18 & $0F` and `$18 >> 4`. Returns with `PLX` so the 16-bit index is in `X`. Preserves flags through `PHP`/`PLP`; returns `RTL`.

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$18` | In | Tile X (low nibble = column within page, high nibble = page column) |
| `$1C` | In | Tile Y (row) |
| `mapRowStrideL0,X` | In | Page stride for selected layer |
| `X` | Out | Map byte index |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `hardware_math.Multiply8x8Unsigned` | Page-row × stride |
| `warps_interaction.asm` / `event_blocks.asm` | JSL callers (per file header: 16 sites) |

### PixelToVramAddress

Aligns `$1E` and `$1A` to 8 pixels (`AND #$F8`), forms `(Y&F8)×4 + (X&F8)>>3`, adds `(X&$100)×4` for the second 32×32 nametable half, then adds `$1000`. Returns address in `A` with `RTL`.

Convention (other file): `event_blocks` adds `$0800` for BG2 nametable base.

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `cop_handlers_metatile.ResolveTileData` | Caller (file header) |
| `event_blocks.asm` | Two call sites (file header) |

### MapIndexMoveRight

Increments low byte of `$02`; if column nibble did not wrap (`BIT #$0F` zero after `INC`), stores `$02` and returns index in `X`. On page wrap, increments high byte and adds `$F0` to the low byte. Stores result in `$02` and `X`.

### MapIndexMoveLeft

Decrements low byte; if low nibble ≠ `$0F`, returns index in `X` without updating `$02`. On underflow, decrements high byte and subtracts `$F0` from low byte; returns in `X` only.

### MapIndexMoveDown

Adds `$10` to low byte; without carry, stores in `$02`/`X`. On carry, adds `mapRowStrideL0` to the high byte via `XBA`/`ADC`/`XBA`.

### MapIndexMoveDown_L1

Same structure as `MapIndexMoveDown`, but initial `LDA $02` has no `REP #$20` (uses caller’s `M` width; both callers in `event_blocks` use `M=16` per asm comment). Page carry adds `mapRowStrideL1`.

### FindSlopeForWestMove

Single caller: `DispatchWestMove` in `player_move_west.asm` (file header).

Flow: `ProbeCurrentTL` (positions probe; result discarded) → `$1A += 8` → `TileProbeMain`. Types `$0A` / `$05` exit immediately. Type `$09`: `MapCellUp` + `ReadCollisionNibble`, check `$0A`. Then `MapCellDown` + nibble checks for `$0A`/`$05`, then `ProbeFutureTL` / `ProbeFutureBL` with the same type tests.

**Return convention (callers test `Z` first):** `Z` set = slope found — carry clear for `$0A`, carry set for `$05`; `Z` clear = no slope. (The file header documents that an older “carry clear when found” description was wrong.)

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$1A` | In/Out | Probe pixel X (+8 mid-routine) |
| `$00` | Temp | Map cell index via tile_collision helpers |
| `A` | Out | Last collision type compared |

### FindSlopeForEastMove

Single caller: `DispatchEastMove` in `player_move_east.asm`. Mirror of west probe: `ProbeCurrentTR`, `$1A -= 8`, `TileProbeMain`. Transition type `$06` checks one row up for `$05`. Then `MapCellDown`, `ProbeFutureTR` / `ProbeFutureBR`. Same `Z`/carry convention as west probe.

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `tile_collision.ProbeCurrent*` / `TileProbeMain` / `MapCellUp` / `MapCellDown` | Probe primitives |
| `player_move_east.asm` | Sole caller |

## See Also

*Evidence: [XREF]*

- [`camera-scrolling.md`](camera-scrolling.md) — camera scrolling, dirty-strip DMA, shared `$18`/`$1C` tile coordinates
- [`tile-collision.md`](tile-collision.md) — probe helpers used by cascade routines
- [`player-movement.md`](player-movement.md) — `FindSlopeForWestMove` / `FindSlopeForEastMove` callers
- [`game-systems.md`](game-systems.md) — event blocks and warps that JSL `TileCoordsToMapIndex`
