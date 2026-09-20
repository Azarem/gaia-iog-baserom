# COP family: Proximity / area

_Deep-audited ops: `[1F]`, `[20]`, `[21]`, `[44]`, `[45]`_ · _Source: [`cop_handlers_collision.asm`](../../../extracted/system/engine/cop_handlers_collision.asm), [`cop_handlers_movement.asm`](../../../extracted/system/engine/cop_handlers_movement.asm), [`cop_handlers_actor_query.asm`](../../../extracted/system/engine/cop_handlers_actor_query.asm)_

[← COP index](../index.md)

## Overview

Conditional branches based on grid alignment, Chebyshev-style tile distance to another actor or the player, and axis-aligned tile rectangles (relative to the current actor or absolute on the map). All branch ops consume a `&Code` target and RTI either into that target or past the operand block.

## Shared state

| Symbol | Role |
|--------|------|
| `$14` / `$16` | Current actor pixel X/Y |
| `$09AA` (`playerActor`) | Player WRAM pointer |
| `ResolveActorIndex` | List index → `$1000 + index×$30` |

## Family notes

- `[20]` / `[21]` share one implementation path: threshold = **`radius×16 + 1`** pixels; branch taken only if **both** `|ΔX|` and `|ΔY|` are **strictly less** than threshold (axis-aligned square, equivalent to Chebyshev distance `< radius` in tile units).
- `[44]` uses **signed** tile offsets added to the **current actor** position; `[45]` uses **unsigned** absolute tile bounds (×16 to pixels). `[45]` compares player Y against **player Y − 8** (feet/center).
- `[1F]` is a **gridline** test (Y low nibble, then X adjusted by metasprite width from `$7F0006`), not a forward-tile solidity check — do not confuse with `BranchIfSolid*` in the solid family.

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `1F` | `BranchIfNotOnGridline` | 7 | `&Code` | `BranchIfNotOnGridline` | Branch or Continue |
| `20` | `BranchIfActorNear` | 4 | Byte ac, Byte dist, `&Code` | `BranchIfActorNear` | Branch or Continue |
| `21` | `BranchIfPlayerNear` | 148 | Byte dist, `&Code` | `BranchIfPlayerNear` | Branch or Continue |
| `44` | `BranchIfPlayerInRelTiles` | 44 | 4×Byte offsets, `&Code` | `BranchIfPlayerInRelTiles` | Branch or Continue |
| `45` | `BranchIfPlayerInAbsTiles` | 140 | 4×Byte tiles, `&Code` | `BranchIfPlayerInAbsTiles` | Branch or Continue |

**Family call-site total:** 343

## Opcodes

#### COP [1F] — `BranchIfNotOnGridline`

- **Handler:** `BranchIfNotOnGridline` @ [`cop_handlers_collision.asm`](../../../extracted/system/engine/cop_handlers_collision.asm)
- **Parameters:** `&Code` branch target

##### What it does

1. If `$16 & $0F ≠ 0` (actor Y not on 16px horizontal gridline) → branch.
2. Else load metasprite width from `$7F0006`, sign-extend, add to `$14`; if result `& $0F ≠ 0` → branch.
3. Else skip branch operand and continue.

```asm
BranchIfNotOnGridline {
    TYX
    LDA $16
    BIT #$000F
    BEQ loc_008BF0        ; Y aligned → check X+hitbox
    ; RTI → branch target
  loc_008BF0:
    ; metasprite width + $14, BIT #$000F
}
```

##### How it is used

Rare alignment gate before movement or spawn logic (7 sites). Audited uses include tutorial and wall-walker scripts where actors must sit on gridlines before continuing.

##### Parameters & return contract

| Item | Value |
|------|-------|
| Branch when | Y off gridline **or** hitbox-adjusted X off gridline |
| Source examples | `pyCE_tuts.asm`, `awB1_wall_walker.asm` (via solid-handler family) |

---

#### COP [20] — `BranchIfActorNear`

- **Handler:** `BranchIfActorNear` → `BranchIfPlayerNear` @ `loc_008C2A` @ [`cop_handlers_movement.asm`](../../../extracted/system/engine/cop_handlers_movement.asm)
- **Parameters:** `Byte` actor list index, `Byte` tile radius, `&Code`

##### What it does

`ResolveActorIndex` on the index byte, then same proximity test as `[21]` against that actor’s `$14`/`$16`.

##### How it is used

Sparse (4 sites): multi-actor scenes where proximity to a **specific** list slot matters (not the player). Prefer `[21]` when the target is always the player.

##### Parameters & return contract

| Item | Value |
|------|-------|
| Near test | `|ΔX| < dist×16+1` **and** `|ΔY| < dist×16+1` |
| Source examples | `unused/unused_proximity_check_noref.asm` |

---

#### COP [21] — `BranchIfPlayerNear`

- **Handler:** `BranchIfPlayerNear` @ [`cop_handlers_movement.asm`](../../../extracted/system/engine/cop_handlers_movement.asm)
- **Parameters:** `Byte` tile radius, `&Code`

##### What it does

Loads `playerActor` into Y, reads radius byte, computes pixel threshold `radius×16+1`, compares absolute ΔX and ΔY from current actor to player. Both axes inside threshold → RTI to `&Code`; else skip branch and continue.

```asm
BranchIfPlayerNear {
    TYX
    LDY $playerActor
  loc_008C2A:
    ; threshold in $0000; |ΔX|, |ΔY| vs threshold → branch or skip
}
```

##### How it is used

**Dominant proximity op (148 uses)** — enemy aggro, dialog triggers, item use (`system/inventory/item_use_system.asm`), dark-space Gaia (`sE6_gaia.asm`), overworld helpers.

```asm
; pyramid/pyCE_tuts.asm
COP [BranchIfPlayerNear] ( #04, &code_0BC4B1 )

; angkor_wat/awB1_gorgon.asm — multiple radii for attack phases
COP [BranchIfPlayerNear] ( #04, &code_0BB939 )
COP [BranchIfPlayerNear] ( #05, &code_0BB82E )
```

##### Parameters & return contract

| Item | Value |
|------|-------|
| Radius | Tile count; effective pixel box side ≈ `2×(dist×16+1)` |
| Source examples | `pyCE_tuts.asm:33`, `awB0_zombie.asm` (patrol branches), `interaction_handlers.asm` |

---

#### COP [44] — `BranchIfPlayerInRelTiles`

- **Handler:** `BranchIfPlayerInRelTiles` @ [`cop_handlers_actor_query.asm`](../../../extracted/system/engine/cop_handlers_actor_query.asm)
- **Parameters:** Four signed `Byte` tile offsets (minX, minY, maxX, maxY style rectangle), `&Code`

##### What it does

Sign-extends each offset, ×16, adds to **current actor** `$14`/`$16` to form min/max pixel bounds. Player must satisfy minX ≤ player.X < maxX and minY ≤ player.Y < maxY (implemented via `CMP`/`BCS`/`BCC` chain). Inside → branch; outside → skip 6 bytes of operands.

##### How it is used

Interaction zones anchored to NPCs (`dark_space.asm`, `ec_proximity_door_toggle.asm`, palace voice lines). Offsets are **relative tile deltas**, not width/height pairs.

##### Parameters & return contract

| Item | Value |
|------|-------|
| Rectangle | Actor position + signed tile offset × 16 per edge |
| Source examples | `sp5A_voice.asm`, `fr32_kidnapper.asm` |

---

#### COP [45] — `BranchIfPlayerInAbsTiles`

- **Handler:** `BranchIfPlayerInAbsTiles` @ [`cop_handlers_actor_query.asm`](../../../extracted/system/engine/cop_handlers_actor_query.asm)
- **Parameters:** Four `Byte` tile coordinates (min X, min Y, max X, max Y), `&Code`

##### What it does

Each tile byte ×16 compared to player X; Y compared against **player Y − 8** stored in `$0000` for min/max Y tile bounds. All four inequalities must pass to take the branch.

##### How it is used

**Overworld exit controller** — each region defines absolute tile rectangles on the world map:

```asm
; actors/overworld_exit.asm
COP [BranchIfPlayerInAbsTiles] ( #2D, #2E, #2F, #30, &OverworldExitItoryVillageEnter )
COP [BranchIfPlayerInAbsTiles] ( #06, #1C, #08, #1E, &OverworldExitRuinsEntranceEast )
```

Also common for room-local triggers (doors, cutscenes) where map tile coords are fixed.

##### Parameters & return contract

| Item | Value |
|------|-------|
| Y compare | Player sprite center adjusted by −8 pixels |
| Operand skip | +6 bytes when outside |
| Source examples | `overworld_exit.asm` (28+ sites), `item_use_system.asm` |
