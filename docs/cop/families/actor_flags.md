# COP family: Actor flags

_Ops: `[5B]`, `[5C]`, `[5D]`_ · _Source: [`cop_handlers_callbacks.asm`](../../../extracted/system/engine/cop_handlers_callbacks.asm) + [`cop_handlers_actor_flags.asm`](../../../extracted/system/engine/cop_handlers_actor_flags.asm)_

[← COP index](../index.md) · [Callbacks](callbacks.md) · [Collision branch](collision_branch.md)

## Overview

Three opcodes for **extended actor state** and **line-of-sight** gating. `$5B` / `$5C` read/write the **`extendedFlags`** word at `$7F002A,X` (OR/AND masks from script). `$5D` samples the **collision layer** at the actor’s tile and **branches** when the actor is **occluded** (behind a blocking wall), skipping activation logic when the player cannot see the sprite.

## Shared state

| Symbol | Role |
|--------|------|
| `$7F002A,X` (`extendedFlags`) | Persistent per-actor flag word (gameplay bits, not `$12` status) |
| `$14` / `$16` | Actor pixel position (for `$5D` tile sample) |
| `$10` bit `$0010` | Layer-aware occlusion mode for `$5D` (when set, uses low collision nibble) |
| `$80` + `CalcTileMapOffset` | Map collision layer pointer ([`cop_handlers_metatile.asm`](../../../extracted/system/engine/cop_handlers_metatile.asm)) |

Common **`OrExtraFlags`** masks in shipped scripts: `$0010`, `$0080`, `$0090` (combined) — actor-specific meaning (smooth follow, damage rules, etc.).

## Family notes

- `$5C` **AND** keeps only bits set in the mask operand (clear bits where mask is 0).
- `$5D` semantics: **visible** → skip branch operand, **continue**; **occluded** → jump to `&Code`. (Opposite of a “branch if visible” test.)
- `$5D` handler lives in **[`cop_handlers_metatile.asm`](../../../extracted/system/engine/cop_handlers_metatile.asm)**, not lifecycle — same dispatch table, different compilation unit.
- Legacy: `OrActorFlags` → `OrExtraFlags`, `AndActorFlags` → `AndExtraFlags`.

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `5B` | `OrExtraFlags` | 74 | `Word` mask | `OrExtraFlags` | Continue |
| `5C` | `AndExtraFlags` | 9 | `Word` mask | `AndExtraFlags` | Continue |
| `5D` | `BranchIfBehindWall` | 4 | `&Code` | `BranchIfBehindWall` | Branch if occluded |

**Family call-site total:** 87

## Opcodes

#### COP [5B] — `OrExtraFlags` (set extended flag bits)

- **Preferred name:** `OrExtraFlags`
- **Aliases:** `OrActorFlags`
- **Handler:** `OrExtraFlags` @ [`cop_handlers_callbacks.asm:314-324`](../../../extracted/system/engine/cop_handlers_callbacks.asm)
- **Parameters:** `Word` bitmask ORed into `$7F002A,X`
- **Outcome:** Continue
- **Usage count:** 74

##### What it does

```asm
OrExtraFlags {                ; cop_handlers_callbacks.asm:313-323
    TYX 
    LDA [$0A]                 ; Read flags word operand
    INC $0A
    INC $0A
    ORA $extendedFlags, X     ; OR into $7F002A,X
    STA $extendedFlags, X
    LDA $0A
    STA $02, S
    RTI 
}
```

##### How it is used

Most-used position op in the family (74 sites). Mask distribution:

| Mask | Count | Meaning |
|------|------:|---------|
| `$0010` | 48 | Smooth-follow / child movement tracking |
| `$0008` | 12 | Damage-related flag |
| `$0080` | 7 | Mode-specific engine handling (bosses) |
| `$0020` | 4 | Secondary behavior enable |
| `$0040` | 1 | Child cascade marker |
| `$0090` | 1 | Combined `$0080`+`$0010` |
| `$0200` | 1 | Rare special flag |

**Dominant pattern:** children and projectiles spawned by bosses set `$0010` to enable tracking:

```asm
; extracted/mansion/solid_arm_lair/sEA_solid_arm.asm — 5 sites
COP [OrExtraFlags] ( #$0010 )

; extracted/mountain_temple/mtA1_yorrick_ns.asm — after spawn
COP [OrExtraFlags] ( #$0010 )
```

**Boss phases** — Dark Gaia, Wall Walker, space flight controller set `$0080` for mode-specific engine handling:

```asm
; extracted/unused/unused_mode7_boss.asm
COP [OrExtraFlags] ( #$0080 )
```

##### Parameters & contract

| Item | Detail |
|------|--------|
| Operand | 16-bit mask ORed in |
| WRAM | `$7F002A` updated in place |
| Does not | Touch `$12` actor status word |

---

#### COP [5C] — `AndExtraFlags` (clear selected extended bits)

- **Preferred name:** `AndExtraFlags`
- **Aliases:** `AndActorFlags`
- **Handler:** `AndExtraFlags` @ [`cop_handlers_callbacks.asm:329-339`](../../../extracted/system/engine/cop_handlers_callbacks.asm)
- **Parameters:** `Word` mask ANDed with `$7F002A,X`
- **Outcome:** Continue
- **Usage count:** 9

##### What it does

```asm
AndExtraFlags {               ; cop_handlers_callbacks.asm:329-339
    TYX 
    LDA [$0A]                 ; Read flags word operand
    INC $0A
    INC $0A
    AND $extendedFlags, X     ; AND with $7F002A,X (bits kept where mask=1)
    STA $extendedFlags, X
    LDA $0A
    STA $02, S
    RTI 
}
```

##### How it is used

Lower use (9 sites) — clears specific bits at phase boundaries. Mask distribution:

| Mask | Count | Clears bits |
|------|------:|-------------|
| `$FFED` | 4 | `$0010` + `$0002` — Cyber Garden mode resets |
| `$FFFD` | 2 | `$0002` — Mountain Temple fire sprite |
| `$FFEF` | 1 | `$0010` — Acid Spider |
| `$FFBF` | 1 | `$0040` — Player character cascade clear |
| `$FFBD` | 1 | `$0040` + `$0002` — Castoth |

```asm
; extracted/sky_garden/sg4D_cyber.asm — 4 sites, mode transition cleanup
COP [AndExtraFlags] ( #$FFED )

; extracted/mountain_temple/mtA1_fire_sprite.asm
COP [AndExtraFlags] ( #$FFFD )

; extracted/actors/player/player_character.asm
COP [AndExtraFlags] ( #$FFBF )
```

##### Parameters & contract

| Item | Detail |
|------|--------|
| Operand | Bits **kept** where mask is 1 |
| Typical | `AND #$FFxx` style masks to drop one bit |

---

#### COP [5D] — `BranchIfBehindWall` (skip logic when visible)

- **Preferred name:** `BranchIfBehindWall`
- **Handler:** `BranchIfBehindWall` @ [`cop_handlers_metatile.asm:570-622`](../../../extracted/system/engine/cop_handlers_metatile.asm)
- **Parameters:** `&Code` — taken when actor is **occluded**
- **Outcome:** Branch if occluded; Continue if visible
- **Usage count:** 4

##### What it does

1. Convert `$14`/`$16` to tile coords → `CalcTileMapOffset`.
2. Out of bounds (`Y ≥ $4000`) → treat as occluded → **branch**.
3. If `$10` bit `$0010`: low collision nibble `$0` → visible; else occluded.
4. Else standard mode: high nibble solid → occluded; low `$0` or type `$E` passthrough → visible.
5. **Visible:** skip 2-byte operand, continue. **Occluded:** jump to `&Code`.

```asm
BranchIfBehindWall {
    TYX
    ; ... tile coords, CalcTileMapOffset ...
    ; loc_009B2D: visible → skip operand
    ; loc_009B37: occluded → LDA [$0A] → STA $02,S ; RTI
}
```

##### How it is used

**Eyesore** — only resume chase anim if not hidden behind wall (`great_wall/gw82_eyesore.asm`):

```asm
COP [BranchIfBehindWall] ( &code_0B8EF0 )
COP [StageSpriteMoveXY] ( #04, #47, #45 )
...
code_0B8EF0 {
    COP [Die]
}
```

If occluded, branch removes the actor instead of animating through geometry.

**Diamond Mine followers** — three call sites gate follower AI (`diamond_mine/dm_follower_behavior.asm`):

```asm
COP [BranchIfBehindWall] ( &code_0ADC4C )
```

Same pattern: defer or cull behavior while follower is behind a blocking tile.

##### Parameters & contract

| Item | Detail |
|------|--------|
| Branch when | Tile blocks line-of-sight per collision nibble rules |
| Continue when | Actor visible to player |
| Not related | `$0E` OAM priority (despite older doc confusion) |
| Depends | `$10` bit `$0010` for layer-aware maps |
