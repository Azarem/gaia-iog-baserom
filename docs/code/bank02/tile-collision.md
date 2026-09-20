# Bank $02 — Tile Collision Probe System

*Part of the [Bank $02 Documentation Suite](readme.md)*

**Bank:** `$02` (FastROM; accessed via `$@` long calls from other banks)  
**Document scope:** Position→tile conversion, collision nibble lookup at `$7FC000`, corner probes, and movement delta finalization.  
**ASM source:** [`tile_collision.asm`](../../../extracted/system/player/tile_collision.asm) (block: `tile_collision`, scene: `player`)  
**Last updated:** 2026-09-07

The most-called subroutines in the player movement system. The movement engine in [`player-movement.md`](player-movement.md) is this block's primary consumer — every directional handler in `player_move_ns.asm`, `player_move_east.asm`, and `player_move_diag.asm` depends on `TileProbeMain` and the corner probe helpers documented here. Map index navigation parallels [`map-coordinates.md`](map-coordinates.md); camera window bounds come from [`camera-scrolling.md`](camera-scrolling.md).

**Related:** [`player-movement.md`](player-movement.md) · [`map-coordinates.md`](map-coordinates.md) · [`../bank00/direction-collision.md`](../bank00/direction-collision.md) · [`../../cop/index.md`](../../cop/index.md)

## Block Layout (tile_collision)

```
$02E102 ├─ CombinedProbe_Unused … CheckSubTileAlignY  │  tile_collision
$02E396 └─ (inventory_menu continues) ────────────────┘
```

> **Note:** `tile_collision` outputs to `system/player/` (scene: `player`) rather than `system/engine/`, as its routines are exclusively called by the player movement dispatchers.

## Collision Type Reference

| Type | Meaning | Direction Handling |
|------|---------|-------------------|
| `$00` | Passable (empty) | Free movement |
| `$01` | Passable (variant) | Free movement (down-left special) |
| `$02` | Interactive tile | Redirect to alternate animation |
| `$03` | Slope (right / ascending east) | Computed sub-pixel Y correction |
| `$05` | Semi-solid / ramp entry | Ramp passability checks |
| `$06` | Wall (south-facing) | Block southward, allow eastward slide |
| `$07` | Ladder / climbable | Auto-climb state change |
| `$08` | Stairs | Stair-step movement redirect |
| `$09` | Wall (north-facing) | Block northward, allow slide |
| `$0A` | Ramp / passable slope | Full ramp movement with Y tracking |
| `$0C` | Slope (left / ascending west) | Computed sub-pixel Y correction with accumulator |
| `$0E`+ | Solid wall | Full block, zero speed |
| `$0F` | Out of bounds / solid | Returned for OOB probes |

## Probe Corner Layout

Player collision uses four corner probes offset from the 16×16 pixel footbox:

```
        TL (−8, −16)    TR (+7, −16)
              ┌──────────────┐
              │   16×16 px   │
              │   footbox    │
              └──────────────┘
        BL (−8, −1)     BR (+7, −1)
```

Coordinates are in **tile-pixel space** (`$22`/`$26` divided by 4).

## tile_collision.asm

The most-called subroutines in the player movement system. Every directional handler in `player_move_ns.asm`, `player_move_east.asm`, and `player_move_diag.asm` depends on `TileProbeMain` and the corner probe helpers.

| Address | Name | Description |
|---------|------|-------------|
| `$02E102` | CombinedProbe_Unused | CombinedProbe_Unused is a dead-code combined probe routine with no callers in the extracted ROM. |
| `$02E13F` | CheckTileBoundaryXor | CheckTileBoundaryXor tests whether the player crossed a 64-pixel (16-tile sub-unit) boundary during movement. |
| `$02E154` | ClearMovementDeltas | ClearMovementDeltas zeroes both movement delta registers $20 (horizontal) and $24 (vertical). |
| `$02E15B` | SetActorCollisionFlag | SetActorCollisionFlag marks the current actor (ID at $000A) as collision-blocked for this frame by ORing $0004 into t... |
| `$02E16E` | ApplyMovementDeltas | ApplyMovementDeltas commits a accepted movement frame by adding deltas to player position and clearing the deltas. |
| `$02E183` | ProbeCurrentBR | ProbeCurrentBR probes the bottom-right corner of the player's 16×16 footbox at the current position. |
| `$02E1A9` | ProbeCurrentTR | ProbeCurrentTR probes the top-right corner at the current position. |
| `$02E1CD` | ProbeCurrentBL | ProbeCurrentBL probes the bottom-left corner. |
| `$02E1F1` | ProbeCurrentTL | ProbeCurrentTL probes the top-left corner — the simplest corner probe with no post-increment boundary check. |
| `$02E20D` | ProbeFutureTR | ProbeFutureTR probes the top-right corner at the future position after applying movement deltas. |
| `$02E237` | ProbeFutureBR | ProbeFutureBR probes the bottom-right corner at the future position. |
| `$02E263` | ProbeFutureTL | ProbeFutureTL probes the top-left corner at the future position. |
| `$02E285` | ProbeFutureBL | ProbeFutureBL probes the bottom-left corner at the future position. |
| `$02E2AF` | TileProbeMain | TileProbeMain is the master tile collision probe — the central lookup invoked by every corner probe and cascade routine. |
| `$02E2FC` | ReadCollisionNibble | ReadCollisionNibble reads the collision type for map cell index X from the runtime overlay at $7FC000. |
| `$02E313` | MapCellDown | MapCellDown moves the cell index at $00 one row down. |
| `$02E32B` | MapCellUp | MapCellUp moves the cell index at $00 one row up. |
| `$02E343` | MapCellRight | MapCellRight advances the map cell index in $00 one cell to the right. |
| `$02E35D` | MapCellLeft | MapCellLeft moves the cell index at $00 one cell left. |
| `$02E37C` | CheckSubTileAlignX | CheckSubTileAlignX tests whether probe X coordinate $1A is aligned to a 16-pixel tile boundary. |
| `$02E389` | CheckSubTileAlignY | CheckSubTileAlignY tests whether probe Y coordinate $1E is aligned to a 16-pixel tile boundary. |

### CombinedProbe_Unused

`CombinedProbe_Unused` is a dead-code combined probe routine with no callers in the extracted ROM. It computes tile coordinates from the future player position (`$22+$20`, `$26+$24`), calls `TileProbeMain`, and rejects collision types ≥ `$0E`.

If the initial probe finds a non-zero type below `$0E`, it falls through to re-probe the cell to the left via `MapCellLeft` and `ReadCollisionNibble`. Returns carry set on solid block, carry clear on passable. Likely a superseded movement helper retained in ROM.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Compute Y probe coord from `$26+$24`; compute X from `$22+$20` + `$1A` |
| 2 | `TileProbeMain`; if type ≥ `$0E`: SEC return |
| 3 | If type = 0: CLC return |
| 4 | `MapCellLeft` → `ReadCollisionNibble`; if ≥ `$0E`: SEC return |
| 5 | CLC return |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$22` / `$20` | In | Player X + delta |
| `$26` / `$24` | In | Player Y + delta |
| `$1A` / `$1E` | Out | Probe coordinates |
| A | Out | Collision type |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `TileProbeMain` | Primary lookup |
| `MapCellLeft` | Fallback adjacent probe |
| *(none)* | No callers — unused |

### CheckTileBoundaryXor

`CheckTileBoundaryXor` tests whether the player crossed a 64-pixel (16-tile sub-unit) boundary during movement. It compares the current tile coordinate (`$22 >> 2`) XOR'd with the future tile coordinate (`($22+$20) >> 2`). If bit `$0010` differs between the two, carry is set indicating a boundary crossing.

Movement handlers use this to trigger sub-tile alignment checks or alternate collision paths when the player moves between major tile grid sections.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Push current tile coord: `$22 >> 2` |
| 2 | Compute future: `($22+$20) >> 2` |
| 3 | EOR with stacked current; test bit `$0010` |
| 4 | Carry = boundary crossed |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$22` | In | Player X position |
| `$20` | In | Horizontal movement delta |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `player_move_*.asm` | Called before corner probes |

### ClearMovementDeltas

`ClearMovementDeltas` zeroes both movement delta registers `$20` (horizontal) and `$24` (vertical) when a movement frame is rejected after collision probing. Called from the player movement handlers in `player_move_*.asm` on the rejection path — the counterpart to `ApplyMovementDeltas`, which commits accepted movement.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `$24` ← 0 (vertical delta) |
| 2 | `$20` ← 0 (horizontal delta) |
| 3 | Return |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$20` / `$24` | Out | Cleared movement deltas |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `ApplyMovementDeltas` | Opposite path on acceptance |
| `player_move_*.asm` | Caller on collision rejection |

### SetActorCollisionFlag

`SetActorCollisionFlag` marks the current actor (ID at `$000A`) as collision-blocked for this frame by ORing `$0004` into its actor flags word at `$0010,Y`. Movement handlers call this when a probe fails so downstream systems know the actor did not move this frame.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Save P; load actor ID from `$000A` into Y |
| 2 | `$0010,Y` ← `$0010,Y \| $0004` |
| 3 | Restore and return |

**Source:**

```81:92:../../../extracted/system/player/tile_collision.asm
SetActorCollisionFlag {
    PHP 
    REP #$20
    PHY 
    LDY $000A
    LDA $0010, Y
    ORA #$0004
    STA $0010, Y
    PLY 
    PLP 
    RTS 
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$000A` | In | Current actor ID |
| `$0010,Y` | Out | Actor flags (bit `$0004` set) |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `player_move_*.asm` | Caller when movement blocked |
| `TileProbeMain` | Probe failure triggers this flag |

### ApplyMovementDeltas

`ApplyMovementDeltas` commits a accepted movement frame by adding deltas to player position and clearing the deltas. `$22 += $20` and `$26 += $24`, then both delta registers are zeroed. This is the final step after all corner probes pass.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `$22` ← `$22 + $20` |
| 2 | `$26` ← `$26 + $24` |
| 3 | `$20` ← 0; `$24` ← 0 |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$22` / `$26` | Out | Updated player position |
| `$20` / `$24` | In/Out | Deltas (consumed) |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `player_move_*.asm` | Called when movement accepted |
| `ClearMovementDeltas` | Opposite path on rejection |

### ProbeCurrentBR

`ProbeCurrentBR` probes the bottom-right corner of the player's 16×16 footbox at the **current** position. Probe coordinates are `$22/4 + 7` (X) and `$26/4 − 1` (Y) in tile-pixel space. After `TileProbeMain`, both coordinates are incremented by 1 to check the inner-tile boundary; if the increment wraps (BCC fails), carry is set indicating blockage.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `$1A` ← `$22>>2 + 7`; `$1E` ← `$26>>2 − 1` |
| 2 | `TileProbeMain` (carry = blocked if type ≠ 0) |
| 3 | `$1A++`; `$1E++`; if overflow: SEC return |
| 4 | CLC return |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$22` / `$26` | In | Current player position |
| `$1A` / `$1E` | Out | Probe coordinates |
| Carry | Out | Set = blocked |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `TileProbeMain` | Collision lookup |
| `ProbeFutureBR` | Future-position counterpart |

### ProbeCurrentTR

`ProbeCurrentTR` probes the top-right corner at the current position. Coordinates: X = `$22/4 + 7`, Y = `$26/4 − 16`. After probing, X is incremented by 1 for inner-tile boundary check. Used heavily in leftward movement cascades (`ProbeLeftTiles` entry point).

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `$1A` ← `$22>>2 + 7`; `$1E` ← `$26>>2 − 16` |
| 2 | `TileProbeMain` |
| 3 | `$1A++`; if overflow: SEC; else CLC |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$22` / `$26` | In | Current player position |
| `$1A` / `$1E` | Out | Probe coordinates |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `ProbeLeftTiles` | Entry probe |
| `ProbeFutureTR` | Future counterpart |

### ProbeCurrentBL

`ProbeCurrentBL` probes the bottom-left corner. Coordinates: X = `$22/4 − 8`, Y = `$26/4 − 1`. After probing, Y is incremented for inner-tile boundary validation.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `$1A` ← `$22>>2 − 8`; `$1E` ← `$26>>2 − 1` |
| 2 | `TileProbeMain` |
| 3 | `$1E++`; if overflow: SEC; else CLC |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$22` / `$26` | In | Current position |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `ProbeFutureBL` | Future counterpart |

### ProbeCurrentTL

`ProbeCurrentTL` probes the top-left corner — the simplest corner probe with no post-increment boundary check. Coordinates: X = `$22/4 − 8`, Y = `$26/4 − 16`. Returns carry directly from `TileProbeMain` (set if collision type non-zero).

Entry point for `ProbeRightTiles` diagonal cascade.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `$1A` ← `$22>>2 − 8`; `$1E` ← `$26>>2 − 16` |
| 2 | `TileProbeMain`; return carry |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$22` / `$26` | In | Current position |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `ProbeRightTiles` | Entry probe |
| `ProbeFutureTL` | Future counterpart |

### ProbeFutureTR

`ProbeFutureTR` probes the top-right corner at the **future** position after applying movement deltas. Base coordinates use `($22+$20)/4 + 7` for X and `($26+$24)/4 − 16` for Y. Post-probe X increment validates inner-tile boundary crossing.

Used in leftward diagonal cascades to predict whether the destination position will be blocked.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `$1A` ← `($22+$20)>>2 + 7`; `$1E` ← `($26+$24)>>2 − 16` |
| 2 | `TileProbeMain` |
| 3 | `$1A++`; overflow → SEC |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$22+$20` / `$26+$24` | In | Future player position |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `ProbeCurrentTR` | Current-position counterpart |
| `ProbeLeftTiles` | Cascade caller |

### ProbeFutureBR

`ProbeFutureBR` probes the bottom-right corner at the future position. Coordinates: X = `($22+$20)/4 + 7`, Y = `($26+$24)/4 − 1`. Both X and Y are incremented post-probe for inner-tile boundary validation.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Compute future BR coords |
| 2 | `TileProbeMain` |
| 3 | `$1A++`; `$1E++`; overflow → SEC |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$20` / `$24` | In | Movement deltas added to position |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `ProbeCurrentBR` | Current-position counterpart |
| `ProbeLeftTiles` | Cascade caller |

### ProbeFutureTL

`ProbeFutureTL` probes the top-left corner at the future position. Coordinates: X = `($22+$20)/4 − 8`, Y = `($26+$24)/4 − 16`. No post-increment check — returns carry directly from `TileProbeMain`.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Compute future TL coords in `$1A`/`$1E` |
| 2 | `TileProbeMain`; return |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$22+$20` / `$26+$24` | In | Future position |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `ProbeCurrentTL` | Current counterpart |
| `ProbeRightTiles` | Cascade caller |

### ProbeFutureBL

`ProbeFutureBL` probes the bottom-left corner at the future position. Coordinates: X = `($22+$20)/4 − 8`, Y = `($26+$24)/4 − 1`. Post-probe Y increment checks inner-tile boundary.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Compute future BL coords |
| 2 | `TileProbeMain` |
| 3 | `$1E++`; overflow → SEC |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$20` / `$24` | In | Movement deltas |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `ProbeCurrentBL` | Current counterpart |
| `ProbeRightTiles` | Cascade caller |

### TileProbeMain

`TileProbeMain` is the master tile collision probe — the central lookup invoked by every corner probe and cascade routine. It bounds-checks probe coordinates `$1A`/`$1E` against the active camera window (`$camera_offset_x`/`$camera_bounds_x` for X, `$camera_offset_y`/`$06DE` for Y).

In bounds: converts pixel coords to tile col/row (`$18`/`$1C` via >> 4), JSLs to `CalcTileMapOffset` in bank `$03` for map cell index resolution, stores result in `$00`, and reads collision via `ReadCollisionNibble`. Carry clear = type `$00` (passable); carry set = blocked.

Out of bounds: stores `$4001` in `$00`, returns type `$0F` (solid) with carry set.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | If `$1A` < 0 or < `$06D6` or ≥ `$06DA`: goto OOB |
| 2 | If `$1E` < 0 or < `$06D8` or ≥ `$06DE`: goto OOB |
| 3 | `$18` ← `$1A >> 4`; `$1C` ← `$1E >> 4` |
| 4 | JSL `CalcTileMapOffset`; `$00` ← cell index; `ReadCollisionNibble` |
| 5 | If A = 0: CLC return; else SEC return |
| 6 | OOB: `$00` ← `$4001`; A ← `$0F`; SEC return |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$1A` / `$1E` | In | Probe pixel coordinates |
| `$18` / `$1C` | Out | Tile column / row |
| `$00` | Out | Map cell index |
| A | Out | Collision type nibble |
| Carry | Out | Clear = passable |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `CalcTileMapOffset` | JSL map cell resolver (bank `$03`) |
| `ReadCollisionNibble` | Collision byte lookup |
| All `ProbeCurrent*` / `ProbeFuture*` | Callers |

### ReadCollisionNibble

`ReadCollisionNibble` reads the collision type for map cell index X from the runtime overlay at `$7FC000`. If X ≥ `$4000`, returns `$0F` (out of bounds / solid).

For valid indices, reads `$7FC000,X`. If the high nibble (bits `$F0`) is non-zero (dynamic overlay from COP handlers), returns the high nibble (shifted right by 4). Otherwise returns the low nibble (base map type). Sets Z/N flags on the result in A.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | If X ≥ `$4000`: A ← `$0F`; return |
| 2 | A ← `$7FC000,X` |
| 3 | If high nibble ≠ 0: A ← high nibble (>> 4) |
| 4 | Return A with Z/N flags set |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| X | In | Map cell index |
| A | Out | Collision type (`$00`–`$0F`) |
| `$7FC000,X` | In | Collision overlay byte |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `TileProbeMain` | Primary caller |
| `MapCellRight/Left/Down/Up` | Cascade callers |
| COP collision handlers | Writers of high nibble overlay |

### MapCellDown

`MapCellDown` moves the cell index at `$00` one row down. Increments the low byte; if the column nibble wraps (`$0F` → `$00`), increments the high byte and adds `$F0` for row alignment.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Increment low byte of `$00` |
| 2 | If column nibble ≠ wrap: return |
| 3 | High byte++; low byte += `$F0` |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$00` | In/Out | Map cell index |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `MapIndexMoveDown` | Parallel in map_coords |

### MapCellUp

`MapCellUp` moves the cell index at `$00` one row up. Decrements the low byte; if the column nibble underflows to `$0F`, decrements the high byte and subtracts `$F0`.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Decrement low byte |
| 2 | If nibble ≠ `$0F`: return |
| 3 | High byte--; low byte −= `$F0` |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$00` | In/Out | Map cell index |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `MapIndexMoveUp` | Parallel in map_coords |

### MapCellRight

`MapCellRight` advances the map cell index in `$00` one cell to the right. Adds `$10` to the low byte; on carry (page boundary), adds map width `$0693` to the high byte. Returns updated index in X.

Operates on the cell index format established by `TileProbeMain` / `CalcTileMapOffset`, parallel to `MapIndexMoveRight` in map_coords.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Low byte of `$00` += `$10` |
| 2 | If no carry: return X |
| 3 | High byte += `$0693` |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$00` | In/Out | Map cell index |
| `$0693` | In | Map row width |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `MapIndexMoveRight` | Parallel in map_coords |
| `ProbeRightTiles` / `ProbeLeftTiles` | Cascade callers |

### MapCellLeft

`MapCellLeft` moves the cell index at `$00` one cell left. Subtracts `$10` from the low byte; on borrow, subtracts `$0693` from the high byte.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Low byte −= `$10` |
| 2 | If no borrow: return |
| 3 | High byte −= `$0693` |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$00` | In/Out | Map cell index |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `MapIndexMoveLeft` | Parallel in map_coords |
| `CombinedProbe_Unused` | Fallback probe path |

## See Also

- [`camera-scrolling.md`](camera-scrolling.md) — camera window bounds used by `TileProbeMain` (`$06D6`–`$06DE`)
- [`map-coordinates.md`](map-coordinates.md) — diagonal cascade probes (`ProbeRightTiles` / `ProbeLeftTiles`) and parallel `MapIndexMove*` helpers
- [`player-movement.md`](player-movement.md) — movement physics engine that JSRs into these probe routines
- [`slope-ramp-physics.md`](slope-ramp-physics.md) — slope/ramp handling after collision type lookup
- [`../bank00/direction-collision.md`](../bank00/direction-collision.md) — dynamic collision overlay (COP handlers)
