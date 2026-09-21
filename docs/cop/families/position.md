# COP family: Position

_Deep-audited ops: `[25]`, `[46]`, `[47]`, `[BC]`_ · _Source: [`cop_handlers_player_query.asm`](../../../extracted/system/engine/cop_handlers_player_query.asm), [`cop_handlers_actor_query.asm`](../../../extracted/system/engine/cop_handlers_actor_query.asm), [`cop_handlers_oam_attribs.asm`](../../../extracted/system/engine/cop_handlers_oam_attribs.asm)_

[← COP index](../README.md)

## Overview

Instant tile teleport, copy position to linked actors in the doubly-linked actor list, and signed pixel nudging. These ops only mutate `$14`/`$16` (and linked actors for copy ops); they do not yield.

## Shared state

| Symbol | Role |
|--------|------|
| `$14` / `$16` | Actor pixel X/Y |
| `$04` / `$06` | Previous / next actor list links |
| `$7F0014,Y` / `$7F0016,Y` | Linked actor coordinates |

## Family notes

- `[25]` centers X on the tile (`×16+8`); Y is **top** of tile (`×16` only, no +8).
- `[46]` / `[47]` require valid `$04` or `$06` links (party followers, multi-part actors, debris chains).
- `[BC]` is documented in legacy material as `AddPosition`; extracted ASM name is **`NudgePosition`**.

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `25` | `SetTilePos` | 100 | Byte tileX, Byte tileY | `SetTilePos` | Continue |
| `46` | `CopyPosToPrev` | 0 | (none) | `CopyPosToPrev` | Continue |
| `47` | `CopyPosToNext` | 0 | (none) | `CopyPosToNext` | Continue |
| `BC` | `NudgePosition` | 194 | Byte dX, Byte dY | `NudgePosition` | Continue |

**Family call-site total:** 294

## Opcodes

#### COP [25] — `SetTilePos` (teleport to tile coordinates)

- **Handler:** `SetTilePos` @ [`cop_handlers_player_query.asm`](../../../extracted/system/engine/cop_handlers_player_query.asm)
- **Parameters:** `Byte` tile X, `Byte` tile Y

##### What it does

`$14 = tileX×16 + 8`, `$16 = tileY×16`. RTI immediately — no collision or camera fixup in the handler.

```asm
SetTilePos {
    TYX
    ; tileX → ASL×4 + 8 → $14
    ; tileY → ASL×4 → $16
    RTI
}
```

##### How it is used

Cutscene repositioning, minigame resets, epilogue staging:

```asm
; ending/ending_comet/sE5_epilogue.asm
COP [SetTilePos] ( #08, #01 )
```

Heavy use in town NPCs, portals, and puzzle rooms (100 sites).

##### Parameters & return contract

| Item | Value |
|------|-------|
| Coordinates | **Tile** units, not pixels |
| X semantics | Horizontal center of tile |
| Y semantics | Top edge of tile row |
| Source examples | `sE5_epilogue.asm:141`, `pyCC_portal.asm`, `interaction_handlers.asm` |

---

#### COP [46] — `CopyPosToPrev`

- **Handler:** `CopyPosToPrev` @ [`cop_handlers_actor_query.asm`](../../../extracted/system/engine/cop_handlers_actor_query.asm)
- **Parameters:** (none)

##### What it does

`LDY $04` (previous actor in list), copy `$14`/`$16` to `$0014`/`$0016` at Y, RTI.

##### How it is used

Multi-segment enemies and follower chains: the head actor moves via `[22]`/`StageMove*`, then `[46]` drags the trailing segment to the same pixel (Castoth limbs, elevator platforms, party escorts).

##### Parameters & return contract

| Item | Value |
|------|-------|
| Requires | Non-zero `$04` link |
| Source examples | `ir29_castoth.asm`, `dm43_elevator.asm` |

---

#### COP [47] — `CopyPosToNext`

- **Handler:** `CopyPosToNext` → shared `loc_00964F` @ [`cop_handlers_actor_query.asm`](../../../extracted/system/engine/cop_handlers_actor_query.asm)
- **Parameters:** (none)

##### What it does

Same as `[46]` but `LDY $06` (next actor).

##### How it is used

Forward propagation to a child/next slot (debris, tail sprites, spawned echo actors).

##### Parameters & return contract

| Item | Value |
|------|-------|
| Requires | Non-zero `$06` link |
| Source examples | `sg4D_cyber.asm`, `mu67_vampires.asm` |

---

#### COP [BC] — `NudgePosition` (signed pixel offset)

- **Aliases:** `AddPosition` (legacy docs)
- **Handler:** `NudgePosition` @ [`cop_handlers_actor_query.asm`](../../../extracted/system/engine/cop_handlers_actor_query.asm)
- **Parameters:** Signed `Byte` dX, signed `Byte` dY

##### What it does

Sign-extends each operand byte and adds to `$14`/`$16`. Wrap/clamp is **not** performed — caller must keep positions valid.

```asm
NudgePosition {
    TYX
    ; read dX, sign-extend, ADC $14
    ; read dY, sign-extend, ADC $16
    RTI
}
```

##### How it is used

**Most-used position op (194)** — fine alignment for dialog facing, projectile spawn offsets, boot logo centering, boss hitboxes:

```asm
; system/boot_logos/sFB_boot_logo.asm
COP [NudgePosition] ( #08, #00 )
COP [NudgePosition] ( #00, #F0 )   ; Y −16

; pyramid/pyCC_blaster.asm — vertical bob
COP [NudgePosition] ( #00, #02 )
COP [NudgePosition] ( #00, #FA )
```

##### Parameters & return contract

| Item | Value |
|------|-------|
| Operands | Two's-complement bytes (`#$F0` = −16) |
| Side effects | Only `$14`/`$16` |
| Source examples | `sFB_boot_logo.asm:52-54`, `gw82_archer.asm`, `sc06_bill.asm` |
