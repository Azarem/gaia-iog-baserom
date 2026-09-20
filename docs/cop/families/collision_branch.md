# COP family: Collision branch

_Ops: `[13]`, `[14]`, `[15]`, `[16]`, `[17]`, `[18]`, `[1A]`, `[1B]`, `[1C]`, `[1D]`, `[1E]`, `[62]`_ · _Source: [`cop_handlers_collision.asm`](../../../extracted/system/engine/cop_handlers_collision.asm) (+ `[62]` in [`cop_handlers_actor_flags.asm`](../../../extracted/system/engine/cop_handlers_actor_flags.asm))_

[← COP index](../index.md) · [Collision paint (write)](collision_paint.md)

## Overview

Read-only probes of `$7FC000` that **conditionally branch** in COP scripts. Solid probes (`$13`–`$18`) ask “is this tile blocked?” via `TileCollisionQuery`. Type probes (`$1A`–`$1E`) compare the sampled collision byte to an expected terrain type. `[62]` uses a separate lookup path (`CalcTileMapOffset`) and compares only the **low type nibble**. For writers, see [collision_paint](collision_paint.md).

## Shared state

- `$7FC000` — Collision layer
- `$14` / `$16` — Actor pixel X/Y (probe origin for most ops)
- `$18` / `$1C` — Probe coordinates (direct page, set by handlers)
- `TileCollisionQuery` — Camera-bounded sample; returns `$000F` when OOB or solid hi-nibble set
- `CalcTileMapOffset` — Tile coord → pointer in `$80` for raw layer read (`[62]`)

## Family notes

- **Solid branches** (`$13`–`$18`): branch when `TileCollisionQuery` result has **any bit in `$000F` set** (includes the `$000F` “blocked” sentinel).
- **Directional solid ops** move the probe one tile (`±$10` pixels) from `$14`/`$16` on N/S/E/W; `[14]` uses signed tile offsets like paint op `[0D]`.
- **Type branches** (`$1A`–`$1E`): branch when `(query result & $FF) == Type` operand (full byte compare after query).
- **`[62]`** is **not** the same as `[1A]`: no `TileCollisionQuery` (no camera clamp / solid fallback), compares **`(byte & $0F) == Nibble`**, and branches on **match** or OOB. Handler lives in [`cop_handlers_metatile.asm`](../../../extracted/system/engine/cop_handlers_metatile.asm).
- Opcode `$19` (`MusicAndText`) sits between `$18` and `$1A` in the dispatch table — it is audio, not collision.

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `13` | `BranchIfSolidHere` | 27 | `&Code` | `BranchIfSolidHere` | Branch or Continue |
| `14` | `BranchIfSolidOffset` | 160 | Byte dX, Byte dY, `&Code` | `BranchIfSolidOffset` | Branch or Continue |
| `15` | `BranchIfSolidNorth` | 75 | `&Code` | `BranchIfSolidNorth` | Branch or Continue |
| `16` | `BranchIfSolidSouth` | 78 | `&Code` | `BranchIfSolidSouth` | Branch or Continue |
| `17` | `BranchIfSolidWest` | 67 | `&Code` | `BranchIfSolidWest` | Branch or Continue |
| `18` | `BranchIfSolidEast` | 71 | `&Code` | `BranchIfSolidEast` | Branch or Continue |
| `1A` | `BranchIfSolidType` | 9 | Byte Type, `&Code` | `BranchIfSolidType` | Branch or Continue |
| `1B` | `BranchIfSolidTypeNorth` | 4 | Byte Type, `&Code` | `BranchIfSolidTypeNorth` | Branch or Continue |
| `1C` | `BranchIfSolidTypeSouth` | 6 | Byte Type, `&Code` | `BranchIfSolidTypeSouth` | Branch or Continue |
| `1D` | `BranchIfSolidTypeWest` | 4 | Byte Type, `&Code` | `BranchIfSolidTypeWest` | Branch or Continue |
| `1E` | `BranchIfSolidTypeEast` | 4 | Byte Type, `&Code` | `BranchIfSolidTypeEast` | Branch or Continue |
| `62` | `BranchIfCollisionTypeNe` | 2 | Byte Nibble, `&Code` | `BranchIfCollisionTypeNe` | Branch or Continue |

**Family call-site total:** 507

**Legacy COP names:** `BranchIfSolid` → `[13]`; script/copdef still often shows `BranchIfSolidType*` for `[1A]`–`[1E]`; `[62]` alias `BranchIfSolidNibbleNe`.

## Opcodes

#### COP [13] — `BranchIfSolidHere` (branch if actor tile blocked)

- **Preferred name:** `BranchIfSolidHere`
- **Aliases:** `BranchIfSolid`
- **Handler:** `BranchIfSolidHere` @ [`cop_handlers_collision.asm:353-375`](../../../extracted/system/engine/cop_handlers_collision.asm)
- **Usage count:** 27

##### What it does

```asm
BranchIfSolidHere {
    TYX
    LDA $14
    STA $0018
    LDA $16
    STA $001C
    JSR $&TileCollisionQuery
    BIT #$000F
    BNE loc_0089CA          ; Blocked → take branch
    LDA [$0A]               ; Free → skip &Code, continue
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI
  loc_0089CA:
    LDA [$0A]               ; Load branch target into script PC
    INC $0A
    INC $0A
    STA $02, S
    RTI
}
```

`TileCollisionQuery` clamps to the camera window, maps to a collision byte, and forces **`A = $000F`** when out of range or when the stored byte has a non-zero **solid** hi-nibble. `BIT #$000F` branches if any low bit is set in the result — so `$000F`, terrain types `$01`–`$0F`, etc. all **take** the branch.

##### How it is used

Enemy AI “stuck against wall” / contact checks:

```asm
COP [BranchIfSolidHere] ( &code_0BBA54 )
```

(`angkor_wat/awB1_gorgon.asm:245`)

| Param | Contract |
|-------|------------|
| `&Code` | Same-bank script label; becomes new `$0A` when taken |

- **Source examples:**
  - `extracted/mountain_temple/mtA0_acid_spider.asm:687`
  - `extracted/great_wall/gw83_asp.asm:255`
  - `extracted/mu/mu60_plasma_chain.asm:25`

- **Relations:** Same probe point as `[0B]` but read-only. Directional variants `[15]`–`[18]`. Robotrek has no direct named equivalent in the `[44]`–`[49]` paint/probe family.

---

#### COP [14] — `BranchIfSolidOffset` (branch if offset tile blocked)

- **Preferred name:** `BranchIfSolidOffset`
- **Handler:** `BranchIfSolidOffset` @ [`cop_handlers_collision.asm:380-428`](../../../extracted/system/engine/cop_handlers_collision.asm)
- **Usage count:** 160

##### What it does

```asm
BranchIfSolidOffset {
    TYX
    LDA [$0A]               ; Signed dX byte
    …                       ; Sign-extend, ×16, add to $14 → $18
    LDA [$0A]               ; Signed dY byte
    …                       ; Sign-extend, ×16, add to $16 → $1C
    JSR $&TileCollisionQuery
    BIT #$000F
    BNE loc_008A19
    …                       ; Skip branch operand
  loc_008A19:
    …                       ; Take branch
}
```

Inlines the same signed offset math as `[0D]`/`[0E]` (not via `ParseSignedTileOffset`, but equivalent pixel scaling), then the shared solid test.

##### How it is used

Wall-walkers and haunts probe tiles ahead or below feet:

```asm
COP [BranchIfSolidOffset] ( #00, #01, &code_0BC1A0 )
COP [BranchIfSolidOffset] ( #00, #03, &code_0BBC1F )
```

(`pyramid/pyD2_haunt.asm:34`, `angkor_wat/awB1_wall_walker.asm:106`)

| Param | Contract |
|-------|------------|
| dX, dY | Signed tile offsets (8-bit) |
| `&Code` | Branch target |

- **Relations:** Probe counterpart to `[0D]` paint. Most-used branch in this family (160 sites).

---

#### COP [15] — `BranchIfSolidNorth` (branch if tile north blocked)

- **Preferred name:** `BranchIfSolidNorth`
- **Handler:** `BranchIfSolidNorth` @ [`cop_handlers_collision.asm:433-457`](../../../extracted/system/engine/cop_handlers_collision.asm)
- **Usage count:** 75

##### What it does

```asm
BranchIfSolidNorth {
    TYX
    LDA $14
    STA $0018
    LDA $16
    SEC
    SBC #$0010            ; One tile up (−16 px)
    STA $001C
    JSR $&TileCollisionQuery
    BIT #$000F
    …
}
```

Fixed **Y − $10** probe; same branch/skip operand pattern as `[13]`.

##### How it is used

Maze actors test the tile above before moving up (mystic ball, tuts, haunts):

```asm
COP [BranchIfSolidNorth] ( &code_0BC632 )
```

(`pyramid/pyCC_mystic_ball.asm:93`)

- **Relations:** `[16]`/`[17]`/`[18]` are S/E/W with `ADC/SBC #$10` on Y or X. Equivalent to `[14] ( #00, #FF, … )` in pixel space but clearer in scripts.

---

#### COP [16] — `BranchIfSolidSouth` (branch if tile south blocked)

- **Preferred name:** `BranchIfSolidSouth`
- **Handler:** `BranchIfSolidSouth` @ [`cop_handlers_collision.asm:462-486`](../../../extracted/system/engine/cop_handlers_collision.asm)
- **Usage count:** 78

##### What it does

Same as `[15]`, but **`ADC #$0010`** to Y (one tile south).

##### How it is used

```asm
COP [BranchIfSolidSouth] ( &code_0BC60C )
```

(`pyramid/pyCC_mystic_ball.asm:112`, `pyramid/pyCE_tuts.asm:96-99`)

- **Relations:** Pair with `[15]` for vertical movement AI. Player vine/ladder code uses **type** south probe `[1C]` with `#00` for landing — different comparison.

---

#### COP [17] — `BranchIfSolidWest` (branch if tile west blocked)

- **Preferred name:** `BranchIfSolidWest`
- **Handler:** `BranchIfSolidWest` @ [`cop_handlers_collision.asm:491-515`](../../../extracted/system/engine/cop_handlers_collision.asm)
- **Usage count:** 67

##### What it does

**`SBC #$0010`** on X; Y unchanged; then `TileCollisionQuery` + `BIT #$000F`.

##### How it is used

```asm
COP [BranchIfSolidWest] ( &code_0BC5D9 )
```

(`pyramid/pyCC_mystic_ball.asm:46`, `angkor_wat/awB1_wall_walker.asm:134`)

- **Relations:** Mirror of `[18]`. Common in 4-way random walkers (`pyCE_tuts.asm`).

---

#### COP [18] — `BranchIfSolidEast` (branch if tile east blocked)

- **Preferred name:** `BranchIfSolidEast`
- **Handler:** `BranchIfSolidEast` @ [`cop_handlers_collision.asm:520-544`](../../../extracted/system/engine/cop_handlers_collision.asm)
- **Usage count:** 71

##### What it does

**`ADC #$0010`** to X; same query and branch discipline.

##### How it is used

```asm
COP [BranchIfSolidEast] ( &code_0BC5B3 )
```

(`pyramid/pyCC_mystic_ball.asm:65`)

- **Relations:** With `[17]`/`[15]`/`[16]`, forms complete orthogonal solid sensing for grid actors.

---

#### COP [1A] — `BranchIfTypeHere` (branch if terrain type matches at actor)

- **Preferred name:** `BranchIfTypeHere`
- **Aliases:** `BranchIfSolidType` (copdef / extracted scripts)
- **Handler:** `BranchIfTypeHere` @ [`cop_handlers_collision.asm:549-578`](../../../extracted/system/engine/cop_handlers_collision.asm)
- **Usage count:** 9

##### What it does

```asm
BranchIfTypeHere {
    TYX
    LDA $14
    STA $0018
    LDA $16
    STA $001C
    JSR $&TileCollisionQuery
    AND #$00FF
    PHA
    LDA [$0A]             ; Expected Type byte
    INC $0A
    AND #$00FF
    CMP $01, S
    BEQ loc_008AF7        ; Equal → branch
    …                     ; Skip &Code
  loc_008AF7:
    …                     ; Take &Code
}
```

Compares the **full query byte** (after `TileCollisionQuery` solid/OOB rules) to the type operand. Match → branch; mismatch → continue.

##### How it is used

Player movement: detect “solid ground” type `#00` while climbing vines or landing:

```asm
COP [BranchIfSolidType] ( #00, &ClimbVineLand )
```

(`actors/player/player_character.asm:497,514,531`)

Aura landing checks other types (`#04`) in `player_transition_handlers.asm`.

| Param | Contract |
|-------|------------|
| Type | Expected collision **byte** value (often low nibble only in practice) |
| `&Code` | Taken on equality |

- **Relations:** Differs from `[13]` (any `$000F` bit vs exact equality). Differs from `[62]` (full byte + query vs low nibble + raw read). Directional siblings `[1B]`–`[1E]`.

---

#### COP [1B] — `BranchIfTypeNorth` (branch if type matches north tile)

- **Preferred name:** `BranchIfTypeNorth`
- **Aliases:** `BranchIfSolidTypeNorth`
- **Handler:** `BranchIfTypeNorth` @ [`cop_handlers_collision.asm:583-614`](../../../extracted/system/engine/cop_handlers_collision.asm)
- **Usage count:** 4

##### What it does

Probe at **Y − $10** (same geometry as `[15]`), then same **`CMP` equality** pattern as `[1A]` on the query result.

##### How it is used

Ladder / shimmy: detect solid wall above when reaching top:

```asm
COP [BranchIfSolidTypeNorth] ( #00, &LadderReachTop )
COP [BranchIfSolidTypeNorth] ( #00, &ShimmyTopCorner )
```

(`actors/player/player_character.asm:782,908,970,1027`)

- **Relations:** Type-aware north probe. Use `[15]` when any blocking solid is enough.

---

#### COP [1C] — `BranchIfTypeSouth` (branch if type matches south tile)

- **Preferred name:** `BranchIfTypeSouth`
- **Aliases:** `BranchIfSolidTypeSouth`
- **Handler:** `BranchIfTypeSouth` @ [`cop_handlers_collision.asm:619-650`](../../../extracted/system/engine/cop_handlers_collision.asm)
- **Usage count:** 6

##### What it does

Probe **Y + $10**; equality compare on query byte vs Type operand.

##### How it is used

```asm
COP [BranchIfSolidTypeSouth] ( #00, &LadderLandBottom )
COP [BranchIfSolidTypeSouth] ( #08, &code_0BB939 )
```

(`player_character.asm:760`, `angkor_wat/awB1_gorgon.asm:142`)

- **Relations:** Landing-on-floor tests often use `#00` south. `[16]` is the solid-any test on the same geometry.

---

#### COP [1D] — `BranchIfTypeWest` (branch if type matches west tile)

- **Preferred name:** `BranchIfTypeWest`
- **Aliases:** `BranchIfSolidTypeWest`
- **Handler:** `BranchIfTypeWest` @ [`cop_handlers_collision.asm:655-686`](../../../extracted/system/engine/cop_handlers_collision.asm)
- **Usage count:** 4

##### What it does

Probe **X − $10**; same type equality branch pattern.

##### How it is used

Player shimmy along ledges — allow movement when west tile type is `#00` or `#07`:

```asm
COP [BranchIfSolidTypeWest] ( #07, &ShimmyLeftLoop )
COP [BranchIfSolidTypeWest] ( #00, &ShimmyLeftLoop )
```

(`player_character.asm:932+`)

- **Relations:** Mirror `[1E]`. Pairs with east probes for horizontal ledge logic.

---

#### COP [1E] — `BranchIfTypeEast` (branch if type matches east tile)

- **Preferred name:** `BranchIfTypeEast`
- **Aliases:** `BranchIfSolidTypeEast`
- **Handler:** `BranchIfTypeEast` @ [`cop_handlers_collision.asm:691-722`](../../../extracted/system/engine/cop_handlers_collision.asm)
- **Usage count:** 4

##### What it does

Probe **X + $10**; equality on type byte.

##### How it is used

```asm
COP [BranchIfSolidTypeEast] ( #07, &ShimmyRightLoop )
COP [BranchIfSolidTypeEast] ( #00, &ShimmyRightLoop )
```

(`player_character.asm:870-871,892-893`)

- **Relations:** Completes directional type set with `[1B]`–`[1D]`.

---

#### COP [62] — `BranchIfCollisionTypeNe` (branch on type nibble match at actor tile)

- **Preferred name:** `BranchIfCollisionTypeNe`
- **Aliases:** `BranchIfSolidNibbleNe`
- **Handler:** `BranchIfCollisionTypeNe` @ [`cop_handlers_metatile.asm:627-668`](../../../extracted/system/engine/cop_handlers_metatile.asm)
- **Usage count:** 2

##### What it does

```asm
BranchIfCollisionTypeNe {
    TYX
    LDA $14               ; Pixel → tile (÷16, no camera clamp)
    LSR ×4
    STA $0018
    LDA $16
    LSR ×4
    STA $001C
    LDA [$0A]             ; Nibble operand
    INC $0A
    AND #$00FF
    STA $0000
    PHD
    LDA #$0000
    TCD
    JSL $@tile_collision_physics.CalcTileMapOffset
    CPY #$4000
    BCS loc_009B7F        ; OOB → branch
    LDA [$80], Y
    AND #$000F            ; Type nibble only (ignore solid hi bits)
    CMP $00
    BEQ loc_009B7F        ; Equal → branch
    PLD
    LDA $0A               ; Not equal → skip &Code, continue
    CLC
    ADC #$0002
    STA $02, S
    RTI
  loc_009B7F:
    PLD
    LDA [$0A]             ; Take branch target
    …
}
```

**Branch taken when:** map index is out of bounds **or** `(collision byte & $0F) == Nibble`. **Continue when** the type nibble differs. Ignores hi-nibble solid flags for the comparison (unlike `[1A]`’s full-byte query result). Does not use `TileCollisionQuery` (no camera-bounds solid fallback).

> The mnemonic `…TypeNe` / `SolidNibbleNe` is legacy naming; the implementation branches on **equality** (and OOB), not inequality.

##### How it is used

Great Wall archer waits until standing on type `$0F` tile before firing sequence:

```asm
COP [SetEntryHere]
COP [BranchIfCollisionTypeNe] ( #0F, &code_0B92A8 )
DEC $24
BMI loc_0B9297
```

(`great_wall/gw82_archer.asm:487-495`)

| Param | Contract |
|-------|------------|
| Nibble | Low collision type (`$0F` = special/block in many maps) |
| `&Code` | Taken on match or OOB |

- **Relations:** Use `[1A]` when you need `TileCollisionQuery` behavior and full-byte match. Use `[13]` when any block solid is enough. Only 2 ROM call sites — most actors prefer simpler solid-test wait loops.

---

##### Family summary

| Group | Ops | Branch when |
|-------|-----|-------------|
| Solid (here) | `[13]` | Query at actor: `$000F` bits set |
| Solid (offset) | `[14]` | Query at actor + signed Δ tile |
| Solid (cardinal) | `[15]`–`[18]` | Query one tile N/S/W/E |
| Type (here) | `[1A]` | `(TileCollisionQuery & $FF) == Type` |
| Type (cardinal) | `[1B]`–`[1E]` | Same, directional probe |
| Type nibble | `[62]` | `(raw byte & $0F) == Nibble` or OOB |

All branch ops: if not taken, COP skips the `&Code` word and continues; if taken, `$02,S` ← branch address (standard COP branch contract).
