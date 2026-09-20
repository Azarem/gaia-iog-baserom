# COP family: Collision paint

_Ops: `[0B]`, `[0C]`, `[0D]`, `[0E]`, `[0F]`, `[10]`, `[11]`, `[12]`, `[42]`_ · _Source: `cop_handlers_solid.asm`_

[← COP index](../index.md) · [Collision branch (read/probe)](collision_branch.md)

## Overview

Write collision data into WRAM `$7FC000` (`collisionLayer`). The high nibble (`#$F0`) marks actor occupancy (“solid here”); the low nibble is terrain / special type. These ops **paint** the map — for read-only probes and branches, see [collision_branch](collision_branch.md).

## Shared state

- `$7FC000` — Collision layer (`!collisionLayer`)
- `$14` / `$16` — Actor pixel X/Y
- `$7F000C,X` — `metaspritePtr` (hitbox width/height/offsets for rectangle ops)
- `MarkCollisionRect` / `ClearCollisionRect` — Metasprite footprint iterators
- `ParseSignedTileOffset` — Signed tile Δ → DP `$18`/`$1C` tile coords
- `TileCoordsToMapIndex` — Tile coords → byte index in `$7FC000`

## Family notes

- **Here** ops (`$0B`/`$0C`/`$11`) use the actor metasprite hitbox rectangle, not a single tile (unless the hitbox is 1×1).
- **Offset** ops (`$0D`/`$0E`) touch **one** tile after `ParseSignedTileOffset` (signed bytes ×16 pixels, Y adjusted −`$10` before tile conversion).
- **Abs** ops (`$0F`–`$12`, `$42`) use **absolute tile** X/Y bytes (map tile coordinates, not pixels).
- `$11` (`ClearCollisionHere`) zeros **both** nibbles; `$0C`/`$0E`/`$10` clear only the solid nibble (`AND #$0F`).
- `$12` (`ClearTypeAbs`) clears only the **type** nibble (`AND #$F0`), preserving solid flags.
- `$42` (`SetCollisionAbs`) stores a **full byte** — can set type and solid in one write.

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `0B` | `MarkSolidHere` | 462 | (none) | `MarkSolidHere` | Continue |
| `0C` | `ClearSolidHere` | 163 | (none) | `ClearSolidHere` | Continue |
| `0D` | `MarkSolidOffset` | 20 | Byte dX, Byte dY | `MarkSolidOffset` | Continue |
| `0E` | `ClearSolidOffset` | 11 | Byte dX, Byte dY | `ClearSolidOffset` | Continue |
| `0F` | `MarkSolidAbs` | 86 | Byte tileX, Byte tileY | `MarkSolidAbs` | Continue |
| `10` | `ClearSolidAbs` | 60 | Byte tileX, Byte tileY | `ClearSolidAbs` | Continue |
| `11` | `ClearCollisionHere` | 9 | (none) | `ClearCollisionHere` | Continue |
| `12` | `ClearTypeAbs` | 27 | Byte tileX, Byte tileY | `ClearTypeAbs` | Continue |
| `42` | `SetCollisionAbs` | 1 | Byte tileX, Byte tileY, Byte Type | `SetCollisionAbs` | Continue |

**Family call-site total:** 839

**Legacy COP names (same handlers):** `SolidHighHere`, `ClearLowHere`, `SolidHighOffset`, `ClearLowOffset`, `SolidHighAbs`, `ClearLowAbs`, `ClearAllHere`, `ClearHighAbs`, `SetSolidAbs`.

## Opcodes

#### COP [0B] — `MarkSolidHere` (mark actor footprint solid)

- **Preferred name:** `MarkSolidHere`
- **Aliases:** `SolidHighHere`, `solid_on`, `occupy_tile`
- **Handler:** `MarkSolidHere` @ `extracted/system/engine/cop_handlers_solid.asm:163-174` → `MarkCollisionRect`
- **Usage count:** 462

##### What it does

```asm
MarkSolidHere {
    TYX
    LDA $14               ; Actor pixel X → probe coordinate
    STA $0018
    LDA $16               ; Actor pixel Y
    STA $001C
    STZ $0000             ; Flag 0 → OR #$F0 path (not full clear)
    JSR $&MarkCollisionRect
    LDA $0A
    STA $02, S
    RTI
}
```

Line by line: saves script bank in Y and actor index in X; copies `$14`/`$16` into direct-page `$18`/`$1C` as the rectangle origin; clears `$0000` so `ClearCollisionRect` is not used (only relevant for `$0C`/`$11`); calls `MarkCollisionRect`, which reads metasprite hitbox bounds from `$7F000C,X`, converts to tile coordinates, and for each cell in the rectangle loads `$7FC000,X`, **`ORA #$F0`**, and stores back (terrain low nibble preserved); restores the COP script pointer into `$02,S` and returns via RTI.

##### How it is used

Nearly every solid NPC, enemy, and prop claims its footprint when idle or extended:

```asm
COP [MarkSolidHere]
```

Wall spear extends collision on a neighbor tile while extended, then clears both:

```asm
COP [MarkSolidHere]
COP [MarkSolidOffset] ( #00, #03 )
…
COP [ClearSolidHere]
COP [ClearSolidOffset] ( #00, #03 )
```

(`great_wall/gw82_wall_spear.asm:31-35`)

| Item | Value |
|------|-------|
| Buffer | `$7FC000` — high nibble OR `$F0` |
| Footprint | Metasprite hitbox from `$7F000C,X` |
| Pairs with | `[0C]` clear; `[0D]` neighbor paint |

- **Source examples:**
  - `extracted/actors/debug_man.asm:26`
  - `extracted/angkor_wat/awB0_shrubber.asm:18`
  - `extracted/great_wall/gw82_archer.asm:48,93,152`
  - `extracted/mu/mu5F_cyclops.asm:25,81,101`

- **Relations:** Inverse of `[0C]`. Same solid paint as `[0F]`/`[0D]` but rectangle vs single tile. Robotrek `[44]` `solid_on` is the same role on `$7FA000`.

---

#### COP [0C] — `ClearSolidHere` (clear actor footprint solid)

- **Preferred name:** `ClearSolidHere`
- **Aliases:** `ClearLowHere`, `solid_off`, `vacate_tile`
- **Handler:** `ClearSolidHere` @ `extracted/system/engine/cop_handlers_solid.asm:179-190` → `ClearCollisionRect`
- **Usage count:** 163

##### What it does

```asm
ClearSolidHere {
    TYX
    LDA $14
    STA $0018
    LDA $16
    STA $001C
    STZ $0000             ; Flag 0 → AND #$0F (solid clear only)
    JSR $&ClearCollisionRect
    LDA $0A
    STA $02, S
    RTI
}
```

Same XY setup as `[0B]`, but `ClearCollisionRect` **`AND #$0F`** on each hitbox tile, stripping the solid nibble while keeping terrain type.

##### How it is used

Before moving, despawning, or retracting hazards so the player can pass:

```asm
COP [ClearSolidHere]
```

Often immediately after `[0B]` in cyclic traps or when an enemy dies:

- `extracted/pyramid/pyCC_mystic_ball.asm:241`
- `extracted/great_wall/gw82_archer.asm:81,147`
- `extracted/angel_village/av6E_draco.asm:211`

| Item | Value |
|------|-------|
| Effect | Clear hi nibble only |
| vs `[11]` | `[11]` zeros entire byte |

- **Relations:** Inverse of `[0B]`. Pairs with `[0E]` for offset clears. Robotrek `[45]` `solid_off`.

---

#### COP [0D] — `MarkSolidOffset` (mark one tile at signed offset)

- **Preferred name:** `MarkSolidOffset`
- **Aliases:** `SolidHighOffset`, `solid_on_at`
- **Handler:** `MarkSolidOffset` @ `extracted/system/engine/cop_handlers_solid.asm:195-214`
- **Usage count:** 20

##### What it does

```asm
MarkSolidOffset {
    TYX
    JSR $&ParseSignedTileOffset
    PHX
    PHD
    LDA #$0000
    TCD
    LDX #$0000
    JSL $@map_coords.TileCoordsToMapIndex
    SEP #$20
    LDA $collisionLayer, X
    ORA #$F0
    STA $collisionLayer, X
    REP #$20
    PLD
    PLX
    LDA $0A
    STA $02, S
    RTI
}
```

`ParseSignedTileOffset` reads two signed bytes from the script, scales each by 16 pixels, adds to `$14`/`$16` (with Y − `$10` bias), converts to tile coords in `$18`/`$1C`, then this handler maps to `$7FC000` and ORs `$F0` on **one** cell.

##### How it is used

Block a tile beside the actor without moving (spear tip, multi-part props):

```asm
COP [MarkSolidOffset] ( #00, #03 )
```

Signed offsets: `#FF` = −1 tile, `#01` = +1 tile (same encoding as `[0E]`).

- **Source examples:**
  - `extracted/great_wall/gw82_wall_spear.asm:32`
  - `extracted/great_wall/sand_fanger_lair/gw8A_sand_fanger.asm` (with `[0F]` abs marks)

| Param | Contract |
|-------|------------|
| dX, dY | Signed **tile** offsets (8-bit, sign-extended, ×16 px) |
| Outcome | Always continue |

- **Relations:** Single-tile counterpart to `[0B]` rectangle. Pairs with `[0E]`. Robotrek `[46]` `solid_on_at`.

---

#### COP [0E] — `ClearSolidOffset` (clear solid at signed offset)

- **Preferred name:** `ClearSolidOffset`
- **Aliases:** `ClearLowOffset`, `solid_off_at`
- **Handler:** `ClearSolidOffset` @ `extracted/system/engine/cop_handlers_solid.asm:219-238`
- **Usage count:** 11

##### What it does

Same path as `[0D]` through `ParseSignedTileOffset` and `TileCoordsToMapIndex`, then **`AND #$0F`** on one collision byte.

##### How it is used

Clear a previously painted neighbor when a trap retracts or puzzle opens:

```asm
COP [ClearSolidOffset] ( #00, #03 )
```

(`great_wall/gw82_wall_spear.asm:35`)

- **Source examples:** Paired with `[0D]` in wall spear, sand fanger lair cleanup with `[10]`.

| Param | Contract |
|-------|------------|
| dX, dY | Same signed tile encoding as `[0D]` |

- **Relations:** Inverse of `[0D]`. Robotrek `[47]` `solid_off_at`.

---

#### COP [0F] — `MarkSolidAbs` (mark solid at absolute tile)

- **Preferred name:** `MarkSolidAbs`
- **Aliases:** `SolidHighAbs`
- **Handler:** `MarkSolidAbs` @ `extracted/system/engine/cop_handlers_solid.asm:243-269`
- **Usage count:** 86

##### What it does

```asm
MarkSolidAbs {
    TYX
    LDA [$0A]             ; Absolute tile X
    INC $0A
    AND #$00FF
    STA $0018
    LDA [$0A]             ; Absolute tile Y
    INC $0A
    AND #$00FF
    STA $001C
    …
    JSL $@map_coords.TileCoordsToMapIndex
    SEP #$20
    LDA $collisionLayer, X
    ORA #$F0
    STA $collisionLayer, X
    …
}
```

Reads tile coordinates from the script (not relative to the actor), resolves index, ORs `$F0` on that cell.

##### How it is used

Scripted barriers at fixed map cells (doors, boss arenas, falling platforms):

```asm
COP [MarkSolidAbs] ( #0F, #2A )
COP [MarkSolidAbs] ( #10, #2A )
```

(`great_wall/sand_fanger_lair/gw8A_sand_fanger.asm:194-197`)

| Param | Contract |
|-------|------------|
| tileX, tileY | Map **tile** coordinates (0-based bytes) |

- **Relations:** Absolute version of `[0D]` single-tile paint. Often batched with `[10]` to remove. `[0B]` uses actor position + hitbox instead.

---

#### COP [10] — `ClearSolidAbs` (clear solid at absolute tile)

- **Preferred name:** `ClearSolidAbs`
- **Aliases:** `ClearLowAbs`
- **Handler:** `ClearSolidAbs` @ `extracted/system/engine/cop_handlers_solid.asm:274-300`
- **Usage count:** 60

##### What it does

Identical operand handling to `[0F]`, then **`AND #$0F`** on the resolved collision byte.

##### How it is used

Remove absolute barrier cells when a script event completes:

```asm
COP [ClearSolidAbs] ( #0F, #2A )
COP [ClearSolidAbs] ( #10, #2A )
```

(`gw8A_sand_fanger.asm:215-218`)

- **Relations:** Inverse of `[0F]`. Does not clear terrain type (use `[12]` for that).

---

#### COP [11] — `ClearCollisionHere` (zero full collision at footprint)

- **Preferred name:** `ClearCollisionHere`
- **Aliases:** `ClearAllHere`
- **Handler:** `ClearCollisionHere` @ `extracted/system/engine/cop_handlers_solid.asm:305-317` → `ClearCollisionRectFull`
- **Usage count:** 9

##### What it does

```asm
ClearCollisionHere {
    TYX
    LDA $14
    STA $0018
    LDA $16
    STA $001C
    LDA #$0001            ; Flag → ClearCollisionRectFull
    STA $0000
    JSR $&ClearCollisionRect
    …
}
```

With `$0000 = 1`, `ClearCollisionRect` jumps to `ClearCollisionRectFull`, which **`AND #$00`** on every hitbox tile — both solid and type nibbles removed.

##### How it is used

Falling tiles, disappearing floors, or actors that should leave no collision trace:

```asm
COP [ClearCollisionHere]
…
COP [MarkSolidHere]       ; restore when reset
```

(`sky_garden/viper_lair/sg55_falling_tile.asm:14,25`)

| Item | Value |
|------|-------|
| vs `[0C]` | `[0C]` keeps terrain type; `[11]` wipes byte |

- **Relations:** Stronger clear than `[0C]`. Use `[12]` to clear type at a fixed tile without touching solid flags elsewhere.

---

#### COP [12] — `ClearTypeAbs` (clear terrain type nibble at absolute tile)

- **Preferred name:** `ClearTypeAbs`
- **Aliases:** `ClearHighAbs` (legacy — clears **low** type nibble, not high)
- **Handler:** `ClearTypeAbs` @ `extracted/system/engine/cop_handlers_solid.asm:322-348`
- **Usage count:** 27

##### What it does

```asm
ClearTypeAbs {
    …
    LDA $collisionLayer, X
    AND #$F0              ; Keep solid bits, zero type nibble
    STA $collisionLayer, X
    …
}
```

Absolute tile X/Y operands; **`AND #$F0`** preserves actor-solid flags, clears terrain type.

##### How it is used

Open invisible collision “type” barriers (Vader pyramid gates) while leaving solidity bits if any:

```asm
COP [ClearTypeAbs] ( #34, #4B )
COP [ClearTypeAbs] ( #35, #4B )
…
```

(`pyramid/pyramid_vader_a/pyD6_vader_barrier_lower.asm:22-33`)

- **Relations:** Type-only edit at absolute coords. Complements `[0F]`/`[10]` (solid nibble). For full-byte writes use `[42]`.

---

#### COP [42] — `SetCollisionAbs` (write full collision byte)

- **Preferred name:** `SetCollisionAbs`
- **Aliases:** `SetSolidAbs`
- **Handler:** `SetCollisionAbs` @ `extracted/system/engine/cop_handlers_solid.asm:768-796`
- **Usage count:** 1

##### What it does

```asm
SetCollisionAbs {
    …
    LDA [$0A]             ; tile X
    …
    LDA [$0A]             ; tile Y
    …
    LDA [$0A]             ; full collision byte value
    …
    JSL $@map_coords.TileCoordsToMapIndex
    SEP #$20
    LDA $00               ; Value staged in DP $00
    STA $collisionLayer, X
    …
}
```

Stores the third operand directly into `$7FC000` — both nibbles replaced. No OR/AND merge.

##### How it is used

Set explicit terrain + solidity (e.g. special ladder/vine type on one cell):

```asm
COP [SetCollisionAbs] ( #07, #0C, #08 )
```

(`sky_garden/viper_lair/sg55_mystic_statue.asm:90`)

| Param | Contract |
|-------|------------|
| tileX, tileY | Absolute tile coords |
| Type | Full 8-bit collision entry (hi = solid, lo = type) |

- **Relations:** Only paint op that assigns the whole byte. Prefer `[0B]`/`[0F]` when you only need `$F0` solid mark. Pairs with `[12]` when scripts mix type clears and explicit sets.

---

##### Family summary (`[0B]`–`[12]`, `[42]`)

| Op | Name | Scope | Solid nibble | Type nibble |
|----|------|-------|--------------|-------------|
| `[0B]` | `MarkSolidHere` | Hitbox rect | OR `$F0` | preserved |
| `[0C]` | `ClearSolidHere` | Hitbox rect | clear | preserved |
| `[0D]` | `MarkSolidOffset` | 1 tile @ actor+Δ | OR `$F0` | preserved |
| `[0E]` | `ClearSolidOffset` | 1 tile @ actor+Δ | clear | preserved |
| `[0F]` | `MarkSolidAbs` | 1 tile abs | OR `$F0` | preserved |
| `[10]` | `ClearSolidAbs` | 1 tile abs | clear | preserved |
| `[11]` | `ClearCollisionHere` | Hitbox rect | zero | zero |
| `[12]` | `ClearTypeAbs` | 1 tile abs | preserved | zero |
| `[42]` | `SetCollisionAbs` | 1 tile abs | **write** | **write** |

Shared helpers: `ParseSignedTileOffset` (offset ops), `TileCoordsToMapIndex` (all single-tile abs/offset), `MarkCollisionRect` / `ClearCollisionRect` (here ops).
