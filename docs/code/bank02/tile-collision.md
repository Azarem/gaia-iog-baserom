# Bank $02 — Tile Collision Probe System

*Part of the [Bank $02 Documentation Suite](README.md)*

> **Evidence labels.** Each major section is tagged with the kind of claim it makes: **[ASM]** = directly observed in the extracted asm of this block; **[INFERRED]** = interpretation of behavior that is not literally encoded in the file; **[XREF]** = cross-file / engine-wide convention stated elsewhere (not provable from this file alone). Sections that mix kinds split them into separately tagged bullets or paragraphs. The `.asm` files in `extracted/` are authoritative; where prose and asm comments disagree, the asm wins.

**Bank:** `$02` (FastROM; `$@` long calls from other banks)  
**Document scope:** Position→tile conversion, collision nibble lookup at `$7FC000`, corner probes, map-cell stepping, movement delta helpers.  
**ASM source:** [`tile_collision.asm`](../../../extracted/system/player/tile_collision.asm) (block `tile_collision`, scene `player`; ROM `188674`–`189334`, `$02E102`–`$02E396`)

**[XREF]** Primary callers: `player_move_*` in `player_move_main`, `slope_ramp_physics.SlopePhysicsEntry`, and `map_coords` ramp helpers (`FindSlopeForWestMove` / `FindSlopeForEastMove`).

**Related:** [`player-movement.md`](player-movement.md) · [`map-coordinates.md`](map-coordinates.md) · [`../bank00/direction-collision.md`](../bank00/direction-collision.md) · [`../../cop/README.md`](../../cop/README.md)

## Block Layout (tile_collision)

*Evidence: [ASM]*

```
$02E102 ├─ CombinedProbe_Unused … CheckSubTileAlignY  │  tile_collision
$02E396 └─ (inventory_menu continues) ────────────────┘
```

**[ASM]** Output path: `extracted/system/player/` (scene `player`), not `system/engine/`.

## Collision Type Reference

*Evidence: [ASM] + [XREF]*

**[ASM]** `ReadCollisionNibble` returns the low nibble (terrain type) when the high nibble of `$7FC000,X` is zero; if the high nibble is nonzero (actor solid mark `$F0`), it returns the high nibble shifted down (e.g. `$F0` → `$0F`). **Callers** compare `A` to `$0E` for fully blocking solids; `TileProbeMain` sets carry for **any** nonzero type (slopes, ladders, walls included).

| Type | Role in this file / callers (asm block note) |
|------|-----------------------------------------------|
| `$00` | Passable — `TileProbeMain` returns carry clear |
| `$01`–`$04`, `$07`, `$08`, `$0B`, `$0D` | Nonzero types; meaning for movement redirects is in `player_move_*` / `player_character` (not defined in this file) |
| `$05` | West-facing slope (used by slope dispatch and ramp movement) |
| `$06` | Diagonal-edge cell: top-right + bottom-left quadrants ("/" edge). Handled by the wall-slide routines |
| `$09` | Diagonal-edge cell: top-left + bottom-right quadrants ("\\" edge). Handled by the wall-slide routines |
| `$0A` | East-facing slope |
| `$0E`+ | Solid — blocking threshold in movement cascades |
| `$0F` | Fully flagged cell (all four quadrants; the most common nonzero value). Also returned for invalid map index (`X ≥ $4000`) and OOB probes |

**[Runtime-verified]** The low nibble of a collision cell is a mask of the four 8 × 8 quadrants of the 16 × 16 cell (bit 9 of the four tilemap words of the metatile, via `BuildMetatileFlagTable`); `$06` and `$09` are the two diagonal pairs of that mask, not south- or north-facing walls. The words "North" / "South" in handler names such as `SouthWallNorthInteract` are type names, not directions (`$09` under the left foot → `SouthWallNorthInteract`, `$06` under the right foot → `SouthWallSouthInteract`). Census of all 223 map scenes and the full table: [`wram-memory-map.md` §4.10](../../wram-memory-map.md).

**Inferred:** Human-readable names for `$02` (ladder redirect), `$07` (shimmy wall), `$08` (vine) come from player movement FSM code, not from `ReadCollisionNibble` itself.

## Probe Corner Layout

*Evidence: [ASM]*

**[ASM]** Hitbox reference: center of the bottom edge of the 16×16 box. Sub-pixel position `$22`/`$26` is shifted right by 2 before offsets:

```
        TL (−8, −16)    TR (+7, −16)
              ┌──────────────┐
              │   16×16 px   │
              └──────────────┘
        BL (−8, −1)     BR (+7, −1)
```

Pixel coords stored in `$1A` (X) and `$1E` (Y). `ProbeFuture*` uses `$22+$20` and `$26+$24`.

## tile_collision.asm

*Evidence: [ASM]*

| Address | Name | Description |
|---------|------|-------------|
| `$02E102` | `CombinedProbe_Unused` | No callers in extracted ROM. Future corner probe; if type `< $0E` and probe Y not 16px-aligned, also probes `MapCellUp`. Returns SEC if type `≥ $0E`. |
| `$02E13F` | `CheckTileBoundaryXor` | `(($22>>2)+($20>>2)) EOR ($22>>2)`; `BIT #$0010` → **Z clear** = crossed 16px column (not carry). |
| `$02E154` | `ClearMovementDeltas` | `STZ $24`; `STZ $20`. |
| `$02E15B` | `SetActorCollisionFlag` | `Y = $000A` (actor **slot address**); `$0010,Y \|= $0004`. |
| `$02E16E` | `ApplyMovementDeltas` | `$22 += $20`; `$26 += $24`; zero `$20`/`$24`. |
| `$02E183` | `ProbeCurrentBR` | BR at current position; `INC $1A`; `INC $1E`; carry from second INC gates SEC return. |
| `$02E1A9` | `ProbeCurrentTR` | TR current; `INC $1A`. |
| `$02E1CD` | `ProbeCurrentBL` | BL current; `INC $1E`. |
| `$02E1F1` | `ProbeCurrentTL` | TL current; returns carry from `TileProbeMain` directly (no INC). |
| `$02E20D` | `ProbeFutureTR` | Future TR; `INC $1A`. |
| `$02E237` | `ProbeFutureBR` | Future BR; `INC $1A`; `INC $1E`. |
| `$02E263` | `ProbeFutureTL` | Future TL; direct carry from `TileProbeMain`. |
| `$02E285` | `ProbeFutureBL` | Future BL; `INC $1E`. |
| `$02E2AF` | `TileProbeMain` | Camera bounds; `CalcTileMapOffset`; `ReadCollisionNibble`. |
| `$02E2FC` | `ReadCollisionNibble` | Index in X; table `$7FC000`. |
| `$02E313` | `MapCellDown` | Low byte `+ $10`; page carry → high byte `+ mapRowStrideL0` (`$0693`). |
| `$02E32B` | `MapCellUp` | Low byte `− $10`; borrow → high byte `− mapRowStrideL0`. |
| `$02E343` | `MapCellRight` | `INC` low byte; column wrap → adjust high byte and low `+ $F0`. |
| `$02E35D` | `MapCellLeft` | `DEC` low byte; wrap from column 0 → high `DEC`, low `− $F0`. |
| `$02E37C` | `CheckSubTileAlignX` | `$1A & $0F`: zero → CLC (aligned). |
| `$02E389` | `CheckSubTileAlignY` | `$1E & $0F`: zero → CLC (aligned). |

### CombinedProbe_Unused

*Evidence: [ASM]*

**[ASM]** Entry uses caller A plus `$26` for Y pixel, `($22+$20)>>2 + $1A` for X. `JSR TileProbeMain`; if `A ≥ $0E` → SEC. If `A = 0` → CLC. Else if probe Y sub-tile nibble was nonzero (`PHP`/`PLP`/`BEQ`), `MapCellUp` + `ReadCollisionNibble`; if that `≥ $0E` → SEC; else CLC.

**Cross-References:** `TileProbeMain`, `MapCellUp` — no callers.

### CheckTileBoundaryXor

*Evidence: [ASM]*

**[ASM]** Compares pre-step pixel X (`$22>>2`) with post-step (`($22+$20)>>2`) via XOR and tests bit 4. Result in **Z flag** (`BNE` = boundary crossed).

**Cross-References:** **[XREF]** `player_move_*.asm` before corner probes.

### ClearMovementDeltas

*Evidence: [ASM]*

**[ASM]** `REP #$20`; `STZ $24`; `STZ $20`; `RTS`.

### SetActorCollisionFlag

*Evidence: [ASM]*

**[ASM]** `LDY $000A` (slot address written by `PlayerMovementTick`); OR `$0004` into `$0010,Y`.

### ApplyMovementDeltas

*Evidence: [ASM]*

**[ASM]** Adds `$20`/`$24` to `$22`/`$26`, then clears velocity words.

### ProbeCurrentBR / ProbeCurrentTR / ProbeCurrentBL / ProbeCurrentTL

*Evidence: [ASM]*

**[ASM]** Formulas match table above. After `TileProbeMain`, TR/BL/BR increment `$1A` and/or `$1E` so `CheckSubTileAlignX/Y` test whether the stored edge sits on a 16px grid line. TL has no post-INC.

**Cross-References:** **[XREF]** `FindSlopeForEastMove` uses `ProbeCurrentTR`; `FindSlopeForWestMove` uses `ProbeCurrentTL`.

### ProbeFutureTR / ProbeFutureBR / ProbeFutureTL / ProbeFutureBL

*Evidence: [ASM]*

**[ASM]** Same offsets applied to `$22+$20` / `$26+$24`. Post-INC pattern matches current probes.

### TileProbeMain

*Evidence: [ASM] + [XREF]*

**[ASM]** Bounds: `$cameraOffsetX` (`$06D6`) ≤ `$1A` < `$cameraBoundsX` (`$06DA`); `$cameraOffsetY` (`$06D8`) ≤ `$1E` < `$cameraLowerYBound` (`$06DE`); negative coords OOB.

In bounds: `$18 = $1A >> 4`, `$1C = $1E >> 4`, `JSL tile_collision_physics.CalcTileMapOffset` → `$00`, `ReadCollisionNibble` with index in X. **A = 0** → CLC; **A ≠ 0** → SEC (not equivalent to “solid only”).

OOB: `$00 = $4001`, **A = `$0F`**, SEC.

### ReadCollisionNibble

*Evidence: [ASM]*

**[ASM]** `CPX #$4000` → `A = $0F`. Else load `$7FC000,X`; high nibble set → return high nibble >> 4; else return full byte (low nibble terrain). `BIT #$FF` sets Z/N on result.

### MapCellDown / MapCellUp / MapCellRight / MapCellLeft

*Evidence: [ASM]*

**[ASM]** Row steps use low-byte `± $10` with `mapRowStrideL0` (`$0693`) on page crossing. Column steps use `INC`/`DEC` on low byte with `$F0` fixup on nibble wrap — **not** `± $10`. Return updated index in **X**; do not modify `$1A`/`$1E`.

**Cross-References:** **[XREF]** Parallel helpers in `map_coords` (`MapIndexMove*`).

### CheckSubTileAlignX / CheckSubTileAlignY

*Evidence: [ASM]*

**[ASM]** `$1A & $0F` or `$1E & $0F`: zero → CLC (aligned); nonzero → SEC.

## See Also

- [`camera-scrolling.md`](camera-scrolling.md) — `$06D6`–`$06DE` camera window
- [`map-coordinates.md`](map-coordinates.md) — ramp cascades and `MapIndexMove*`
- [`player-movement.md`](player-movement.md) — `PlayerMovementTick` consumer
- [`slope-ramp-physics.md`](slope-ramp-physics.md) — slope dispatch after probe
- [`../bank00/direction-collision.md`](../bank00/direction-collision.md) — COP writers of high nibble overlay
