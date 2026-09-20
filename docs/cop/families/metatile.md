# COP family: Metatile / world map draw

_Ops: `[4B]`, `[4C]`, `[4D]`, `[4E]`_ · _Source: [`cop_handlers_map.asm`](../../../extracted/system/engine/cop_handlers_map.asm)_

[← COP index](../index.md)

## Overview

Map mutation from scripts: paint one metatile at fixed or actor coordinates, or stream many tile records for world-map / reveal sequences. All paths funnel through **`ResolveTileData`** (WRAM `mapLayerTilemap` `$7EA000`, `collisionLayer` `$7FC000`, optional BG VRAM queue). **`TileQueryGate`** (`$0902` / `tileQueryResult`) serializes updates — busy map engine causes **`RTL`** yield and handler re-entry.

## Shared state

| Symbol | Address | Role |
|--------|---------|------|
| `tileQueryResult` | `$0902` | Nonzero = tile update pending (gate closed) |
| `mapLayerTilemap` | `$7EA000` | Metatile ID layer |
| `collisionLayer` | `$7FC000` | Collision nibble layer |
| `metatileMapLayer` | `$7E2000` | Source tiles for VRAM expansion |
| `extendedFlags` | `$7F002A,X` | Bit 1 = stream init; bit 2 = SFX per tile |
| `$24` | actor scratch | Cached stream pointer for `$4D`/`$4E` |
| `orbitAngle` | `$7F0010,X` | SFX byte when bit 2 set |

## Family notes

- **`DrawMetatileAbs` / `DrawMetatileHere`** may **Halt** (yield) when `$0902 ≠ 0`; otherwise **Continue**.
- **`WorldMapStream3` / `WorldMapStream4`** always **Halt** between records until sentinel; **`extendedFlags` bit 1** remembers stream base across yields.
- Stream **sentinel:** first byte of record with **bit 7 set** → end stream, skip 2-byte operand, clear bit 1.
- **`WorldMapStream4`** stores 4th byte into **`$0008,Y`** before resolve (attribute side channel).

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `4B` | `DrawMetatileAbs` | 24 | 3×`Byte` | `DrawMetatileAbs` | Continue / Halt |
| `4C` | `DrawMetatileHere` | 8 | `Byte` | `DrawMetatileHere` | Continue / Halt |
| `4D` | `WorldMapStream3` | 0 | `Word` | `WorldMapStream3` | Halt |
| `4E` | `WorldMapStream4` | 0 | `Word` | `WorldMapStream4` | Halt |

**Family call-site total:** 32

---

## Opcodes

#### COP [4B] — `DrawMetatileAbs` (tile X/Y + metatile)

- **Confidence:** high
- **Handler:** `DrawMetatileAbs` @ [`cop_handlers_map.asm:39-80`](../../../extracted/system/engine/cop_handlers_map.asm)
- **Parameters:** `Byte tileX`, `Byte tileY`, `Byte metatileId`
- **Usage count:** 24

##### What it does

1. **`TileQueryGate`** — if busy, rewind `$0A` by 2, **`RTL`**.
2. Read tile X/Y bytes → convert to pixel coords in DP (`×16`).
3. Read metatile ID → **`ResolveTileData`** (WRAM + on-screen VRAM queue).
4. **`RTI`**.

##### Handler excerpt

```asm
DrawMetatileAbs {
    TYX
    JSR $&TileQueryGate
    BCC loc_00968E
    PLA
    PLA
    RTL
  loc_00968E:
    ...                   ; read X, Y, metatile → ResolveTileData
    LDA $0A
    STA $02, S
    RTI
}
```

##### How it is used

**Puzzle room floor strips** — pyramid arrangement puzzle paints a row of tiles when solved:

```asm
; extracted/pyramid/puzzle_room/pyCD_puzzle.asm
COP [DrawMetatileAbs] ( #05, #06, #87 )
COP [DrawMetatileAbs] ( #06, #06, #87 )
...
```

**Mine collapse / scene FX** — absolute coords for tiles outside actor footprint.

##### Parameters & contract

| Item | Value |
|------|-------|
| Operands | tile X, tile Y, metatile ID (each 1 byte) |
| Coords | Absolute map tile indices (not pixels) |
| Outcome | **Continue** or **Halt** if gate busy |

---

#### COP [4C] — `DrawMetatileHere` (metatile at actor cell)

- **Confidence:** high
- **Handler:** `DrawMetatileHere` @ [`cop_handlers_map.asm:85-122`](../../../extracted/system/engine/cop_handlers_map.asm)
- **Parameters:** `Byte metatileId`
- **Usage count:** 8

##### What it does

Same gate and **`ResolveTileData`** as **`DrawMetatileAbs`**, but tile coordinates derive from actor **`$14`/`$16`** (pixel position → tile grid). Used when the actor stands on the tile to change (breakable walls, jars).

##### Handler excerpt

```asm
DrawMetatileHere {
    TYX
    JSR $&TileQueryGate
    ...
    LDA $0014, X          ; actor X → tile
    ...
    JSR $&ResolveTileData
    RTI
}
```

##### How it is used

```asm
; extracted/pyramid/pyD0_breakable_wall.asm
COP [DrawMetatileHere] ( #E8 )
COP [DrawMetatileHere] ( #E9 )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand | 1 byte metatile ID |
| Position | Current actor `$14`/`$16` |
| Outcome | **Continue** or **Halt** |

---

#### COP [4D] — `WorldMapStream3` (3-byte record stream)

- **Confidence:** high
- **Handler:** `WorldMapStream3` @ [`cop_handlers_map.asm:127-195`](../../../extracted/system/engine/cop_handlers_map.asm)
- **Parameters:** `Word streamOffset` (script-bank data)
- **Usage count:** 48

##### What it does

**First entry:** cache operand word in **`$24`**, set **`extendedFlags` bit 1**.

**Each tick:** advance stream by 3 bytes, **`ParseMapEntry`** (X, Y, ID; MSB on X = end). On data record → **`ResolveTileData`**, optionally queue **`orbitAngle`** as SFX (bit 2), rewind script PC by 2, **`RTL`** (next frame). On sentinel → clear bit 1, skip operand, **`RTI`**.

##### Handler excerpt

```asm
WorldMapStream3 {
    ...
    JSR $&ParseMapEntry
    BCS loc_00975B        ; end sentinel
    JSR $&ResolveTileData
    LDA $0A
    DEC
    DEC
    STA $00
    PLA
    PLA
    RTL                   ; yield — more records
  loc_00975B:
    ...                   ; finish stream, RTI
}
```

##### How it is used

World-map reveal animations and long tile-replacement cinematics: data lives in script bank as byte streams; one **`COP [WorldMapStream3]`** call consumes the whole sequence across many frames. Enable **`OrExtraFlags #$0004`** on the actor for per-tile SFX.

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand | 2-byte offset to first record in script bank |
| Record | 3 bytes: X, Y, metatile (X bit 7 = end) |
| State | `$24`, `extendedFlags` bit 1 across yields |
| Outcome | **Halt** until complete |

---

#### COP [4E] — `WorldMapStream4` (4-byte record stream)

- **Confidence:** high
- **Handler:** `WorldMapStream4` @ [`cop_handlers_map.asm:200-270`](../../../extracted/system/engine/cop_handlers_map.asm)
- **Parameters:** `Word streamOffset`
- **Usage count:** 48

##### What it does

Same control flow as **`WorldMapStream3`**, but stream step is **4 bytes**. After **`ParseMapEntry`**, fourth byte → **`$0008,Y`** then **`ResolveTileData`**. Used when extra per-tile attribute must ride with map paints.

##### Handler excerpt

```asm
WorldMapStream4 {
    ...
    ADC #$0004            ; 4-byte stride
    ...
    LDA $0003, X
    STA $0008, Y
    JSR $&ResolveTileData
    ...
}
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand | 2-byte stream base |
| Record | 3-byte core + 1 attribute byte |
| Outcome | **Halt** (multi-frame) |
