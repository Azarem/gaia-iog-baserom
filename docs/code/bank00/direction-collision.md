# Bank $00 — Direction Computation & Collision Systems

**Bank:** `$00` (mirrored at `$80` for FastROM access)  
**Address range:** `$00AFCE`–`$00B47F` (direction, collision map, tile query, camera scroll step)  
**ASM files:** `extracted/system/engine/cop_handlers_collision.asm`, `extracted/system/engine/cop_handlers_actors.asm` (partial)  
**Blocks:** `system/cop_handlers_collision`, `system/cop_handlers_actors` in `us/blocks.json`

This page documents the engine routines that compute 8-way facing directions, query tile solidity against the live map, read/write the dynamic collision overlay at `$7FC000`, and index camera pan step tables. These functions sit between COP script handlers and bank `$03` map lookup code; almost every movement, spawn, and branch-on-wall COP in the `$00`–`$1E` and `$96`–`$98` ranges depends on them.

**Related:** [`event-flags.md`](event-flags.md), [`actor-management.md`](actor-management.md), [`../chunk_008000-analysis.md`](../chunk_008000-analysis.md), [`../../cop-commands-reference.md`](../../cop-commands-reference.md)

---

## Overview

| Category | Functions | Address Span | Approx. Size |
|----------|-----------|--------------|--------------|
| Direction computation | 1 | `$00AFCE`–`$00B05D` | 144 bytes |
| Camera scroll step | 1 | `$00B136`–`$00B156` | 33 bytes |
| Collision map (mark/clear) | 4 | `$00B29F`–`$00B435` | ~412 bytes |
| Tile collision query | 1 | `$00B43B`–`$00B481` | 70 bytes |
| **Total (this document)** | **7** | | **~659 bytes** |

### Data Flow

```
COP handler sets $0018/$001C (tile coords)
    ├── ComputeDirectionToPlayer → octant 0–7 in A/Y
    └── TileCollisionQuery → property byte in A ($000F = blocked)

COP $0B/$0C/$11 + offset variants
    ├── MarkCollisionRect   → ORA #$F0 into $7FC000,X (occupy high nibble)
    ├── ClearCollisionRect  → AND #$0F (partial) or delegate full clear
    └── ClearCollisionRectFull → write $00 per tile byte

CameraPan COPs ($DC–$DF)
    └── CameraScrollStepLookup → step delta from table at $06E0
```

---

## Direction Computation

### ComputeDirectionToPlayer

| Property | Value |
|----------|-------|
| **Old Name** | `sub_00AFCE` |
| **New Name** | `ComputeDirectionToPlayer` |
| **Hex Address** | `$00AFCE` |
| **Decimal Address** | 45006 |
| **End Address** | `$00B05D` (exclusive `$00B05E`) |
| **Size** | 144 bytes |
| **ASM File** | `extracted/system/engine/cop_handlers_collision.asm` |

#### Description

Computes an **8-way octant index (0–7)** describing where the **player** lies relative to a **target point** stored in zero-page `$0018` (X) and `$001C` (Y). The delta vector is `player_position − target_position`; the routine does not normalize to unit length but uses a **16-pixel Chebyshev threshold** (`$0010`) to decide between **cardinal** and **diagonal** directions within each quadrant.

Despite the name, the math is “direction **to** the player **from** the target coordinates,” not the reverse. COP handlers typically preload `$0018`/`$001C` with the calling actor's pixel position before invoking this routine.

#### Direction Encoding

| Value | Direction | Index in Y before `TYA` |
|-------|-----------|-------------------------|
| 0 | North | `$0000` |
| 1 | Northeast | `$0001` |
| 2 | East | `$0002` |
| 3 | Southeast | `$0003` |
| 4 | South | `$0004` |
| 5 | Southwest | `$0005` |
| 6 | West | `$0006` |
| 7 | Northwest | `$0007` |

#### Algorithm

| Step | Operation | Detail |
|------|-----------|--------|
| 1 | `LDY $player_actor` | Load direct-page index of the player actor |
| 2 | `dX = $0014,Y − $0018` | Horizontal delta; **BMI** → player is west (−X branch) |
| 3 | **Quadrant +X** (`loc_00B01A` not taken) | Compute `dY = $0016,Y − $001C` |
| 3a | +X, +Y (`dY ≥ 0`) | If `\|dY\| < 16` → **E(2)**; elif `\|dX\| < 16` → **S(4)**; else **SE(3)** |
| 3b | +X, −Y (`dY < 0`) | Abs(`dY`); if `< 16` → **E(2)**; elif `\|dX\| < 16` → **N(0)**; else **NE(1)** |
| 4 | **Quadrant −X** | Abs(`dX`) stored in `$0000`; compute `dY` |
| 4a | −X, +Y | If `\|dY\| < 16` → **W(6)**; elif `\|dX\| < 16` → **S(4)**; else **SW(5)** |
| 4b | −X, −Y | If `\|dY\| < 16` → **W(6)**; elif `\|dX\| < 16` → **N(0)**; else **NW(7)** |
| 5 | `loc_00B05C`: `TYA` / `RTS` | Return octant in **A** and **Y** |

Absolute value uses the common 65816 idiom `EOR #$FFFF` / `INC` on 16-bit deltas.

#### Variables

| Address | Role |
|---------|------|
| `$0018` | Target X (pixel coords, input) |
| `$001C` | Target Y (pixel coords, input) |
| `$0000` | Temp: abs(dX) in −X quadrants |
| `$player_actor` | Direct-page index of player actor |
| `$0014,Y` / `$0016,Y` | Player X/Y position |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | COP `$2D` `DirToPlayer` | Sets actor pos → calls routine → returns octant in A |
| Called by | COP `$2E` `DirToPlayerOffset` | Adds script offset to actor pos first |
| Called by | COP `$2F` `BranchIfDirToPlayer` | Compares result to script byte; branches on match |
| Called by | COP `$30` `BranchIfDirToPlayerFrom` | Uses offset origin for `$0018`/`$001C` |
| Cataloged in | `us/names.json` @ 45006 | |

---

## Tile Collision Queries

### TileCollisionQuery

| Property | Value |
|----------|-------|
| **Old Name** | `sub_00B43B` |
| **New Name** | `TileCollisionQuery` |
| **Hex Address** | `$00B43B` |
| **Decimal Address** | 46139 |
| **End Address** | `$00B481` (exclusive) |
| **Size** | 70 bytes |
| **ASM File** | `extracted/system/engine/cop_handlers_collision.asm` |

#### Description

Performs a **read-only solidity query** at pixel coordinates `$0018` (X) and `$001C` (Y). Validates the point against the **active camera window**, converts to map tile indices, calls bank `$03` map lookup, and returns the **tile property byte** in A. Returns the sentinel **`$000F`** (all low bits set — treated as fully solid) when the point is out of camera bounds, off the loaded map, or when the tile's **upper property nibble** (`$00F0`) indicates a wall.

COP branch handlers test **`BIT #$000F`** on the result: a **non-zero low nibble** means blocked for movement purposes.

#### Algorithm

| Step | Operation | Detail |
|------|-----------|--------|
| 1 | `PHD` / `TCD #$0000` | Switch to zero page for `$18`/`$1C` access |
| 2 | X bounds | `$18 &= $FFF0`; reject if negative, `< $camera_offset_x`, or `≥ $camera_bounds_x` |
| 3 | Y bounds | Reject if `$1C < 0`, `< $camera_offset_y`, or `≥ $06DE` |
| 4 | Tile index | Both coords `LSR ×4`; **Y decremented by 1** (engine tile-grid origin fudge) |
| 5 | `JSL $@func_03D78A` | Map lookup; **Y = `$4000`** means invalid → branch to sentinel |
| 6 | Property read | `LDA [$80],Y`; test **`BIT #$00F0`** — if any wall bit in high nibble, use sentinel |
| 7 | Success | Return raw property byte in A |
| 8 | Failure (`loc_00B47C`) | `LDA #$000F` — universal “solid” return |
| 9 | `PLD` / `RTS` | Restore direct page |

#### Variables

| Address | Role |
|---------|------|
| `$0018` | Query X (pixel, input/output — masked to tile boundary) |
| `$001C` | Query Y (pixel, converted to tile row) |
| `$camera_offset_x` | Left edge of valid query window |
| `$camera_bounds_x` | Right edge (exclusive) |
| `$camera_offset_y` | Top edge |
| `$06DE` | Bottom Y bound for map queries |
| `[$80],Y` | Map property table (bank in `$80` DP byte) |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | COP `$13`–`$1E` | All `BranchIfSolid*` handlers (here, offset, abs, directional) |
| Called by | COP `$96`–`$98` | Wall-gated player movement COPs |
| Calls | `func_03D78A` (`$03D78A`) | Map tile index → carry/Y validation |
| Cataloged in | `us/names.json` @ 46139 | Highest call volume in bank `$00` upper page (~14 call sites) |

---

## Collision Map Operations

Dynamic collision lives in WRAM **`$7FC000+`**. Each byte holds **occupancy in the high nibble** (`$F0`, written by `MarkCollisionRect`) and **static/low tile data in the low nibble** (`$0F`). Clearing preserves static data unless a **full clear** is requested.

### MarkCollisionRect

| Property | Value |
|----------|-------|
| **Old Name** | `sub_00B29F` |
| **New Name** | `MarkCollisionRect` |
| **Hex Address** | `$00B29F` |
| **Decimal Address** | 45727 |
| **End Address** | `$00B32A` (exclusive `$00B32B`) |
| **Size** | 140 bytes |
| **ASM File** | `extracted/system/engine/cop_handlers_collision.asm` |

#### Description

Marks a **rectangle of collision tiles as occupied** by OR-ing **`$F0`** into each `$7FC000,X` byte. Rectangle size and offset come from the **actor's map header** pointed to by `$7F000C,X` with data bank loaded from `$7F0008,X`. Used when an actor should block movement (solid object, NPC standing on tile).

#### Algorithm

| Step | Operation | Detail |
|------|-----------|--------|
| 1 | Save `B`, `D`, `X`; `TCD #$0000` | Preserve actor DP in X |
| 2 | Load map header | `Y = $7F000C,X`; switch DBR to `$7F0008,X` |
| 3 | Parse rect | Bytes 0/2 → X offset+width; bytes 1/3 → Y offset+height (signed 16-bit + 8-bit extent) |
| 4 | Pixel → tile | Add actor `$18`/`$1C`, divide by 16 → `$18` origin, `$1A` width, `$1C` row, `$1E` height |
| 5 | `JSL $@TileCoordsToMapIndex` | Base index in X; abort if `X ≥ $4000` |
| 6 | Row loop (`loc_00B2F6`) | For each column: `ORA #$F0` into `$7FC000,X`; decrement width |
| 7 | Column wrap | If `(X+1) & $000F ≠ 0`, simple increment; else add `$00F0` (next map row stride within 16-tile page) |
| 8 | Next row | Decrement height; reset width from `$1A`; **`JSR AdvanceMapY`**; loop |
| 9 | Restore registers / `RTS` | |

#### Variables

| Address | Role |
|---------|------|
| `$7F000C,X` | Pointer to map header (footprint rect) |
| `$7F0008,X` | Data bank for header |
| `$0018` / `$001C` | Actor position (input); become tile origin |
| `$001A` / `$001E` | Tile width / height counters |
| `$7FC000,X` | Collision overlay byte |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | COP `$0B` `MarkSolidHere` | Sets `$18`/`$1C` from actor `$14`/`$16`, `$00=0` |
| Calls | `TileCoordsToMapIndex` (`$02B0A3`) | Pixel tile coords → `$7FC000` index |
| Calls | `AdvanceMapY` | Row advance with page wrap |
| Cataloged in | `us/names.json` @ 45727 | |

---

### ClearCollisionRect

| Property | Value |
|----------|-------|
| **Old Name** | `sub_00B345` |
| **New Name** | `ClearCollisionRect` |
| **Hex Address** | `$00B345` |
| **Decimal Address** | 45893 |
| **End Address** | `$00B3EE` (exclusive `$00B3EF`) |
| **Size** | 170 bytes |
| **ASM File** | `extracted/system/engine/cop_handlers_collision.asm` |

#### Description

Clears **dynamic occupancy** in a map rectangle matching the actor footprint — the inverse of `MarkCollisionRect`. Two modes controlled by zero-page **`$00`** at entry:

- **`$00 = 0` (default):** `AND #$0F` — preserves low nibble (static tile flags).
- **`$00 ≠ 0`:** Jumps to `ClearCollisionRectFull` — zeroes entire bytes.

#### Algorithm

Identical header parsing and index setup as `MarkCollisionRect`. Inner loop at `loc_00B3A4`:

| Step | Operation | Detail |
|------|-----------|--------|
| 1 | Mode check | `LDA $00` — if non-zero, `JMP ClearCollisionRectFull` |
| 2 | Partial clear | `LDA $7FC000,X` / `AND #$0F` / store — strips `$F0` occupancy |
| 3 | Column iteration | Same 16-tile page wrap as mark routine |
| 4 | Row advance | Adds `$10` to `$1C`; on carry, adds `$map_bounds_x` (row stride — note: uses `$map_bounds_x` label here vs `$0693` in `AdvanceMapY`) |

#### Variables

Same as `MarkCollisionRect`, plus:

| Address | Role |
|---------|------|
| `$00` | `0` = partial clear (high nibble only); non-zero = full clear |
| `$map_bounds_x` | Map row stride for Y wrap in this routine's inline path |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | COP `$0C` `ClearSolidHere` | `$00=0` partial clear at actor position |
| Called by | COP `$11` `ClearAllHere` | Sets `$00≠0` for full-byte clear |
| Calls | `ClearCollisionRectFull` | When full clear requested |
| Calls | `TileCoordsToMapIndex` | Shared with mark routine |
| Cataloged in | `us/names.json` @ 45893 | |

---

### ClearCollisionRectFull

| Property | Value |
|----------|-------|
| **Old Name** | `code_00B3EF` |
| **New Name** | `ClearCollisionRectFull` |
| **Hex Address** | `$00B3EF` |
| **Decimal Address** | 46063 |
| **End Address** | `$00B435` (exclusive) |
| **Size** | 76 bytes |
| **ASM File** | `extracted/system/engine/cop_handlers_collision.asm` |

#### Description

**Full collision-byte reset** — writes **`$00`** to each byte in the rectangle (via `AND #$00`). Invoked only from `ClearCollisionRect` when `$0000 ≠ 0`. Used when an actor leaves a tile and both dynamic occupancy and merged low-nibble state must be wiped (e.g. COP `$11`).

#### Algorithm

Same nested row/column loop structure as partial clear, but inner operation is:

```asm
LDA $7FC000, X
AND #$00          ; force zero
STA $7FC000, X
```

Row advancement matches `ClearCollisionRect`'s inline path (`+$10` / `$map_bounds_x` on carry).

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | `ClearCollisionRect` | When `$00 ≠ 0` at entry |
| Called by | COP `$11` `ClearAllHere` | Indirectly via `ClearCollisionRect` |
| Cataloged in | `us/names.json` @ 46063 | |

---

### AdvanceMapY

| Property | Value |
|----------|-------|
| **Old Name** | `sub_00B32B` |
| **New Name** | `AdvanceMapY` |
| **Hex Address** | `$00B32B` |
| **Decimal Address** | 45867 |
| **End Address** | `$00B344` (exclusive `$00B345`) |
| **Size** | 26 bytes |
| **ASM File** | `extracted/system/engine/cop_handlers_collision.asm` |

#### Description

Increments map Y coordinate **`$001C` by `$10`** (one tile row in pixel space), handling **16-bit page/bank carry** using the map row stride at **`$0693`**. Shared by collision rectangle iterators when moving to the next row within the `$7FC000` overlay.

#### Algorithm

| Step | Operation | Detail |
|------|-----------|--------|
| 1 | `PHP` / `SEP #$20` | 8-bit accumulator for carry test |
| 2 | `LDA $1C` / `ADC #$10` | Add one tile row |
| 3 | No carry | Store back to `$1C`, restore, `RTS` |
| 4 | Carry (`loc_00B339`) | `XBA`; add `$0693` to high byte; `XBA`; store 16-bit `$1C` |

The `$0693` value is the **map width in bytes** (typically `$0100` for 16-tile rows), causing the index high byte to advance when Y crosses a 256-pixel page within the collision map layout.

#### Variables

| Address | Role |
|---------|------|
| `$001C` | Map Y coordinate (pixel units, advanced in place) |
| `$0693` | Map row stride (bytes per row in collision grid) |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | `MarkCollisionRect` | Between row iterations |
| Note | `ClearCollisionRect` | Uses inline `+$10`/`$map_bounds_x` instead of this helper |
| Cataloged in | `us/names.json` @ 45867 | |

---

## Camera

### CameraScrollStepLookup

| Property | Value |
|----------|-------|
| **Old Name** | `sub_00B136` |
| **New Name** | `CameraScrollStepLookup` |
| **Hex Address** | `$00B136` |
| **Decimal Address** | 45366 |
| **End Address** | `$00B156` (exclusive `$00B157`) |
| **Size** | 33 bytes |
| **ASM File** | `extracted/system/engine/cop_handlers_collision.asm` |

#### Description

Indexes the **camera pan step sequence** for COP `$DC`–`$DF` (`CameraPanUp/Down/Left/Right`). Reads a signed 16-bit step from table base **`$06E0`** at index **`$06E2`**, auto-incrementing the index each call. When the fetched entry's **high byte is zero**, the sequence is **exhausted**: resets **`$06E2 = 0`** and returns **carry set** so the COP handler can stop scrolling.

#### Algorithm

| Step | Operation | Detail |
|------|-----------|--------|
| 1 | `PHP` / `PHX` | Preserve flags and index |
| 2 | `LDA $06E2` / `INC $06E2` | Current step index; advance for next call |
| 3 | `ASL` / `ADC $06E0` / `TAX` | Word index into step table |
| 4 | `LDA $0000,X` / `BIT #$FF00` | Load step; test high byte |
| 5 | Non-zero high byte | Restore, **CLC**, `RTS` — valid step in A |
| 6 | Zero high byte (`loc_00B150`) | `STZ $06E2`; restore, **SEC**, `RTS` — sequence done |

#### Variables

| Address | Role |
|---------|------|
| `$06E0` | Pointer/base to camera scroll step table (words) |
| `$06E2` | Current index into step sequence (auto-incremented) |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | COP `$DC` | `CameraPanUp` |
| Called by | COP `$DD` | `CameraPanDown` |
| Called by | COP `$DE` | `CameraPanLeft` |
| Called by | COP `$DF` | `CameraPanRight` |
| Cataloged in | `us/names.json` @ 45366 | |

---

## Quick Reference

| New Name | Old Name | Address | Size | Primary Callers |
|----------|----------|---------|------|-----------------|
| `ComputeDirectionToPlayer` | `sub_00AFCE` | `$00AFCE` | 144 | COP `$2D`–`$30` |
| `TileCollisionQuery` | `sub_00B43B` | `$00B43B` | 70 | COP `$13`–`$1E`, `$96`–`$98` |
| `MarkCollisionRect` | `sub_00B29F` | `$00B29F` | 140 | COP `$0B` |
| `ClearCollisionRect` | `sub_00B345` | `$00B345` | 170 | COP `$0C`, `$11` |
| `ClearCollisionRectFull` | `code_00B3EF` | `$00B3EF` | 76 | `ClearCollisionRect` |
| `AdvanceMapY` | `sub_00B32B` | `$00B32B` | 26 | `MarkCollisionRect` |
| `CameraScrollStepLookup` | `sub_00B136` | `$00B136` | 33 | COP `$DC`–`$DF` |
