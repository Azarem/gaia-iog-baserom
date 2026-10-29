# Bank $00 — Direction Computation & Collision Systems

**Bank:** `$00` (mirrored at `$80` for FastROM access)  
**Address range:** `$00AFCE`–`$00B481` (direction, collision map paint, tile query); `$00B136`–`$00B156` (`CameraScrollStepLookup` in `cop_handlers_movement.asm`)  
**ASM files:** `extracted/system/engine/cop_handlers_collision.asm`, `extracted/system/engine/cop_handlers_movement.asm` (`CameraScrollStepLookup`), `extracted/system/engine/tile_collision_physics.asm` (`CalcTileMapOffset`, collision map layout)

This page documents engine routines that compute **8-way octant indices** toward the player, **probe** tile collision bytes, **paint** dynamic occupancy into WRAM `$7FC000`, and **index** camera pan step tables. COP handlers in the `$00`–`$1E`, `$96`–`$98`, and `$2D`–`$30` ranges depend on these helpers.

**Related:** [`event-flags.md`](event-flags.md), [`actor-management.md`](actor-management.md), [`README.md`](README.md), [`../../cop/README.md`](../../cop/README.md)

## Source of truth

Primary extracted files:

- `extracted/system/engine/cop_handlers_collision.asm` — `ComputeDirectionToPlayer`, `MarkCollisionRect`, `ClearCollisionRect`, `ClearCollisionRectFull`, `AdvanceMapY`, `TileCollisionQuery`, `ParseSignedTileOffset`, COP `$0B`–`$1E` probes
- `extracted/system/engine/cop_handlers_movement.asm` — `CameraScrollStepLookup`
- `extracted/system/engine/cop_handlers_player_query.asm` — COP `$2D`–`$30` callers of `ComputeDirectionToPlayer`
- `extracted/system/engine/tile_collision_physics.asm` — `CalcTileMapOffset`, collision-byte semantics, `[$80],Y` map access during movement
- `extracted/system/engine/map_coords.asm` — `TileCoordsToMapIndex` (rectangle paint)

**Naming:** Labels such as `ComputeDirectionToPlayer`, `collisionLayer` (`$7FC000`), `mapRowStrideL0` (`$0693`), `scrollStepTableBase` / `scrollStepIndex` (`$06E0` / `$06E2`), and `cameraLowerYBound` are **extracted** symbols. Do not confuse this doc’s “reference point” wording with **`GetPlayerFacingDirection`** (bank `$03`, cardinal **0–3**, animation-frame tables) — that is a separate, global convention.

**Counts:** COP reference counts for mark/clear/probe ops appear in the block note at the top of `cop_handlers_collision.asm` (e.g. MarkSolidHere “462 call sites”); this doc does not restate exact totals unless re-counted in a fresh audit.

---

## Overview

| Category | Functions | Address Span | Approx. Size |
|----------|-----------|--------------|--------------|
| Direction computation | 1 | `$00AFCE`–`$00B05D` | 144 bytes |
| Camera scroll step | 1 | `$00B136`–`$00B156` | 33 bytes |
| Collision map (mark/clear) | 4 | `$00B29F`–`$00B435` | ~412 bytes |
| Tile collision query | 1 | `$00B43B`–`$00B481` | 70 bytes |
| **Total (this document)** | **7** | | **~659 bytes** |

### Collision query vs overlay paint

Two different mechanisms touch the same WRAM array **`collisionLayer` (`$7FC000`)**:

| Mechanism | Routine | Effect |
|-----------|---------|--------|
| **Tile property query** | `TileCollisionQuery` | Read-only: maps probe pixels → index via `CalcTileMapOffset`, reads byte through **`[$80],Y`** (DP `$80`–`$82` = collision map long pointer; must stay valid — see gaia-knowledge `AGENTS.md`) |
| **Dynamic occupancy overlay** | `MarkCollisionRect` / `ClearCollisionRect*` | Writes: **OR `$F0`** (mark solid nibble) or **AND `$0F` / `$00`** on `$7FC000,X` for actor footprint tiles |

**Collision byte semantics** (current extracted behavior; scene/metatile data is source-dependent):

- **High nibble (`$F0`):** non-zero ⇒ treated as **blocked** in `TileCollisionQuery` (returns sentinel **`$000F`**). Actors also **OR `$F0`** here via `MarkCollisionRect` (“occupancy”).
- **Low nibble (`$0F`):** **terrain / type** for dispatch (see `tile_collision_physics.asm` block note: `0` = passable for many paths, `1`–`F` = solid types). `ResolveTileData` (metatile COPs) copies a type from **`$7F0000 + metatile ID`** into the low nibble when repainting tiles.

`BranchIfSolid*` COPs use **`BIT #$000F`** on the **16-bit** query result: branch if **any** low bit is set — that includes sentinel **`$000F`**, non-zero terrain types, and is **not** the same as “high nibble only.”

### Data flow

```text
COP sets page-0 scratch $0018/$001C (pixel or tile coords per handler)
    ├── ComputeDirectionToPlayer → octant 0–7 in A (also Y after TYA)
    └── TileCollisionQuery → property word in A ($000F = blocked / OOB / high-nibble set)

COP $0B/$0C/$11 (+ offset variants via ParseSignedTileOffset)
    ├── MarkCollisionRect     → ORA #$F0 on $7FC000,X (per metasprite hitbox)
    ├── ClearCollisionRect    → AND #$0F when page-0 $00 = 0
    └── ClearCollisionRectFull → AND #$00 when page-0 $00 ≠ 0

CameraPan COPs ($DC–$DF)
    └── CameraScrollStepLookup → next table word; zero high byte = end (carry set)

Example mark/clear at actor position (COP $0B / $0C):
  Actor $14/$16 → $0018/$001C → MarkCollisionRect ORs $F0 on each hitbox tile
  ClearSolidHere: STZ $0000 → ClearCollisionRect ANDs $0F (keeps terrain nibble)
  ClearCollisionHere: LDA #$0001 → full clear via ClearCollisionRectFull
```

### Collision query flow (probe)

```text
  Probe pixel ($0018 X, $001C Y)
        │
        ▼
  TileCollisionQuery (page-0 DP)
        ├─ X &= $FFF0; vs cameraOffsetX / cameraBoundsX
        ├─ Y vs cameraOffsetY / cameraLowerYBound
        ├─ pixel → tile (Y row − 1, same as ParseSignedTileOffset)
        ▼
  CalcTileMapOffset → index in Y; Y ≥ $4000 ⇒ sentinel $000F
        ▼
  LDA [$80],Y  (collisionLayer via DP pointer)
        ├─ BIT #$00F0 set ⇒ $000F
        └─ else ⇒ full 16-bit map word in A (callers usually test #$000F)
        ▼
  BranchIfSolid*: BIT #$000F → branch if non-zero
```

---

## Direction Computation

### ComputeDirectionToPlayer

**Address:** `$AFCE` · **Size:** 144 bytes · **Status:** **live** (COP `$2D`–`$30` in `cop_handlers_player_query.asm`)

#### Description

Computes an **8-way octant index (0–7)** for the direction **from a reference pixel** to the **player**. Reference point: page-0 **`$0018` (X)** and **`$001C` (Y)**. Deltas are **`player − reference`**:

- `dX = $0014,Y − $0018` (player actor in **`Y = $playerActor`**)
- `dY = $0016,Y − $001C`

Positive `dX` ⇒ player is **east** of the reference; positive `dY` ⇒ player is **south**. This is the **global octant convention for COP `$2D`–`$30` only** (clockwise from north: 0=N … 7=NW). It is **not** the 0–3 cardinal encoding used by **`GetPlayerFacingDirection`** (bank `$03`).

Within each east/west half-plane, if **`|dY| < $10` (16 px)** the result is **pure east (2) or west (6)** regardless of `dX` (including `dX = 0` ⇒ east). Otherwise the vertical component picks N/S, and **`|dX| ≥ $10`** selects diagonals.

#### Direction encoding (this routine only)

| Value | Direction | Built in Y before `TYA` |
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
| 1 | `LDY $playerActor` | Player actor slot |
| 2 | `dX = $0014,Y − $0018` | **BMI** → west branch (`loc_00B01A`) |
| 3 | **East (`dX ≥ 0`)** | `dY = $0016,Y − $001C` |
| 3a | East, `dY ≥ 0` | Default **E(2)**; if `dY ≥ $10` → bias **S(4)**; if also `|dX| ≥ $10` → **SE(3)** |
| 3b | East, `dY < 0` | `\|dY\|`; if `< $10` → **E(2)**; elif `|dX| < $10` → **N(0)**; else **NE(1)** |
| 4 | **West (`dX < 0`)** | `\|dX\|` → `$0000`; same `dY` split |
| 4a | West, `dY ≥ 0` | Default **W(6)**; `dY ≥ $10` → **S(4)**; `|dX| ≥ $10` → **SW(5)** |
| 4b | West, `dY < 0` | `\|dY\|`; if `< $10` → **W(6)**; elif `|dX| < $10` → **N(0)**; else **NW(7)** |
| 5 | `loc_00B05C`: `TYA` / `RTS` | Octant in **A** and **Y** |

Absolute value: `EOR #$FFFF` / `INC` on 16-bit deltas.

#### Variables

| Address | Role |
|---------|------|
| `$0018` | Reference X (pixels, input) |
| `$001C` | Reference Y (pixels, input) |
| `$0000` | Temp: `\|dX\|` on west path |
| `$playerActor` | Player actor index |
| `$0014,Y` / `$0016,Y` | Player pixel position |

#### Cross-references

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | COP `$2D` `DirToPlayer` | Reference = actor `$14`/`$16` |
| Called by | COP `$2E` `DirToPlayerOffset` | Adds script offsets to reference |
| Called by | COP `$2F` / `$30` | Branch/compare on octant |

---

## Tile Collision Queries

### TileCollisionQuery

**Address:** `$B43B` · **Size:** 70 bytes · **Status:** **live** (all `BranchIfSolid*` / type probes; wall anim in `cop_handlers_player_sprite.asm`)

#### Description

**Read-only** probe at page-0 **`$0018` / `$001C`** (pixels). Clips to the **camera window**, converts to tile indices, calls **`CalcTileMapOffset`** (`tile_collision_physics.asm`), reads **`LDA [$80],Y`**. Returns **`$000F`** when:

- Probe is outside camera bounds or negative,
- Map index **`Y ≥ $4000`**, or
- Collision byte **high nibble** is non-zero (`BIT #$00F0`).

Otherwise returns the **16-bit word** read from the map (callers typically **`BIT #$000F`**). Does **not** write `$7FC000`.

#### Algorithm

| Step | Operation | Detail |
|------|-----------|--------|
| 1 | `PHD` / `TCD #$0000` | Page-zero scratch |
| 2 | X | `$18 &= $FFF0`; vs `cameraOffsetX` / `cameraBoundsX` |
| 3 | Y | vs `cameraOffsetY` / **`cameraLowerYBound`** |
| 4 | Tile | `LSR×4`; **Y row decremented by 1** (matches `ParseSignedTileOffset`) |
| 5 | `JSL CalcTileMapOffset` | **`Y ≥ $4000`** → sentinel |
| 6 | `LDA [$80],Y` | **`BIT #$00F0`** → sentinel |
| 7 | Fail | `LDA #$000F` |
| 8 | `PLD` / `RTS` | |

#### Variables

| Address | Role |
|---------|------|
| `$0018` / `$001C` | Probe position (X masked to 16 px) |
| `$cameraOffsetX` / `$cameraBoundsX` | Horizontal clip |
| `$cameraOffsetY` / `$cameraLowerYBound` | Vertical clip |
| `[$80],Y` | Collision map via engine DP pointer (`$7FC000` base) |

#### Cross-references

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | COP `$13`–`$1E` | Solid / type / grid probes |
| Called by | COP `$96`–`$98` | Player wall animation probes |
| Calls | `CalcTileMapOffset` | Bank `$03` |

---

## Collision Map Operations

Dynamic updates target **`collisionLayer` (`$7FC000`)**. Each byte:

- **High nibble:** dynamic **solid mark** (`MarkCollisionRect` ORs **`$F0`**).
- **Low nibble:** **terrain type** (preserved by partial clear; wiped on full clear).

Index math matches **`TileCoordsToMapIndex`** / **`CalcTileMapOffset`**: 256-byte **16×16 tile pages**; **+1** = next column, **+$10** = next row in page; crossing column 15 uses **+$F0** adjustment in rectangle loops; row page-cross uses **`mapRowStrideL0`** (`$0693`) or **`mapBoundsX`** (16-bit add in clear paths).

### MarkCollisionRect

**Address:** `$B29F` · **Status:** **live** (COP `$0B` `MarkSolidHere`)

#### Description

ORs **`$F0`** onto each byte in the actor **metasprite hitbox** rectangle. Hitbox header: **4 bytes at `[metaspritePtr]`** in the sprite data bank (`$7F0008,X` → DBR): X offset, Y offset, width in tiles, height in tiles (offsets forced negative with **`ORA #$FF00`**). Combined with page-0 **`$0018`/`$001C`** (pixel origin), converted to tile origin, indexed via **`TileCoordsToMapIndex`**. Skipped if start index **`≥ $4000`**.

#### Cross-references

| Called by | COP `$0B` | Actor `$14`/`$16` → `$0018`/`$001C` |
| Calls | `TileCoordsToMapIndex`, `AdvanceMapY` | Row step between scanlines |

### ClearCollisionRect

**Address:** `$B345` · **Status:** **live** (COP `$0C`, `$11`)

#### Description

Same hitbox setup as mark. Mode from page-0 **`$00`** after **`TCD #$0000`** (not the actor’s `$00` entry word):

- **`$00 = 0`:** **`AND #$0F`** — clear solid nibble, keep type.
- **`$00 ≠ 0`:** jump to **`ClearCollisionRectFull`**.

Row advance **inlined**: **`ADC #$10`** on `$1C`; on carry **`ADC mapBoundsX`** (16-bit).

| Called by | COP `$0C` | `STZ $0000` before call |
| Called by | COP `$11` | `LDA #$0001` → full clear |

### ClearCollisionRectFull

**Address:** `$B3EF` · **Status:** **live** (via `$11` / flag path)

**`AND #$00`** on each byte — zeros **both** nibbles.

### AdvanceMapY

**Address:** `$B32B` · **Status:** **live** (**`MarkCollisionRect` only**)

Adds **`$10`** to page-0 **`$1C`** (map index low byte in the mark loop’s row pointer). On carry, adds **`mapRowStrideL0`** to the hidden high byte of **`A`** (see block note in asm — differs from clear path’s **`mapBoundsX`** 16-bit add).

---

## Camera

### CameraScrollStepLookup

**Address:** `$B136` in `cop_handlers_movement.asm` · **Status:** **live** (COP `$DC`–`$DF`)

Reads the next **16-bit word** from the table pointed to by **`scrollStepTableBase` (`$06E0`)**, index **`scrollStepIndex` (`$06E2`)** (auto-incremented). **Carry clear:** high byte of entry non-zero — valid word in **A** (CameraPan stores low byte → **`$2A`**, high byte → **`$2B`**; step magnitude is low nibble of **`$2B`**). **Carry set:** high byte zero — end of table, **`scrollStepIndex`** reset to 0.

---

## Quick Reference

| Name | Address | Size | Primary Callers |
|------|---------|------|-----------------|
| `ComputeDirectionToPlayer` | `$AFCE` | 144 | COP `$2D`–`$30` |
| `TileCollisionQuery` | `$B43B` | 70 | COP `$13`–`$1E`, `$96`–`$98` |
| `MarkCollisionRect` | `$B29F` | 140 | COP `$0B` |
| `ClearCollisionRect` | `$B345` | 170 | COP `$0C`, `$11` |
| `ClearCollisionRectFull` | `$B3EF` | 76 | `ClearCollisionRect` |
| `AdvanceMapY` | `$B32B` | 26 | `MarkCollisionRect` |
| `CameraScrollStepLookup` | `$B136` | 33 | COP `$DC`–`$DF` |

## Source validation

**Files checked:** `cop_handlers_collision.asm`, `cop_handlers_movement.asm`, `cop_handlers_player_query.asm`, `cop_handlers_player_sprite.asm`, `tile_collision_physics.asm`, `map_coords.asm`, `GetPlayerFacingDirection.asm` (convention cross-check only).

**Verified:** Delta sign and octant rules in `ComputeDirectionToPlayer`; `TileCollisionQuery` bounds, `−1` row, `[$80],Y` read, `$000F` sentinel; mark/clear hitbox source **`metaspritePtr`** and **`OR $F0` / `AND $0F/$00`**; rectangle index stepping (`+$F0`, `AdvanceMapY` vs clear **`mapBoundsX`**); `CameraScrollStepLookup` carry/terminator; **`BranchIfSolidHere`** uses **`BIT #$000F`**.

**Notes:** Collision **type** meanings in the low nibble are **data-dependent** (table at `$7F0000` for metatile paints). Exact COP site counts taken from asm block notes, not re-counted here. **`AdvanceMapY`** page-byte dependency is documented in extracted comments as **inferred** edge-case behavior.
