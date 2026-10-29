# COP family: Force move

_Ops: `[AA]`, `[AB]`, `[AC]`, `[AD]`, `[AE]`, `[AF]`, `[B0]`, `[B1]`_ · _Source: [`cop_handlers_force_move.asm`](../../../extracted/system/engine/cop_handlers_force_move.asm)_

[← COP index](../README.md) · [Sprite staging](sprite_staging.md) · [Movement](movement.md)

## Overview

Eight opcodes that configure **non-sprite** movement: they write movement **indices** (into `move_chain_table`) into WRAM (`moveXAlt` / `moveYAlt`) and load the **delta-chain head pointers** at actor `$2C` (X) / `$2E` (Y) via `AnimFrameLookup`; the movement code consumes one chain node (a signed per-frame delta) per frame. Companion ops set the **delta-negate** bits on `$12` (`$4000` negates the X delta, `$2000` the Y delta) or copy the same staging onto the **newest actor in the list** (`actorListLast`, `$0058`). `$B1` reloads the chain pointers from the saved indices without changing the indices, which rewinds both chains to their first node — used after gravity, interrupts, or other code that clobbered or advanced `$2C` / `$2E`.

These pair with `COP [53]` (`TickMove`) and with sprite staging (`$81`–`$87`) when scripts want motion during an animation clip. They do **not** start animation by themselves.

## Shared state

| Symbol / WRAM | Role |
|---------------|------|
| `$7F0018,X` (`moveXAlt`) | X movement **index** (operand byte) |
| `$7F001A,X` (`moveYAlt`) | Y movement **index** |
| `$2C` / `$2E` | X / Y **delta-chain pointers** (output of `AnimFrameLookup`; the movement code consumes one node per frame) |
| `$12` | Actor flags; `$4000` = negate the X delta, `$2000` = negate the Y delta, `$6000` = both (via `$AD`–`$AF`) |
| `$0058` | Actor list **tail** pointer (`actorListLast`) — target of `$B0` (typically the child just appended by spawn) |
| `AnimFrameLookup` | `actor_pool` — returns `move_chain_table[index × 2]`, the head pointer of a delta chain (not a duration) |

## Family notes

- Operands are **table indices**, not pixel deltas. Direction of travel still comes from animation movement tables, the `$12` negate bits, and optional `ForceDir*` overrides.
- `$AD` / `$AE` / `$AF`: operand **`#00` clears** the corresponding bit(s) via `TRB`; nonzero sets via `TSB`.
- `$B0` runs on **`LDX $0058`** (global tail), not the caller’s slot — spawn the child immediately before `$B0`, or the wrong actor receives the slide.
- `$B1` does not reload indices from elsewhere; it only re-runs `AnimFrameLookup` on the current `moveXAlt` / `moveYAlt`.
- Legacy script names: `StageForceMoveX/Y/XY`, `SetForceSW/NE/Both`, `ForceMoveLastChild`, `ReloadForceMove` (renamed as in `db-us/copdef.json`).

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `AA` | `StageMoveX` | 60 | `Byte` X index | `StageMoveX` | Continue |
| `AB` | `StageMoveY` | 45 | `Byte` Y index | `StageMoveY` | Continue |
| `AC` | `StageMoveXY` | 42 | `Byte`, `Byte` X, Y | `StageMoveXY` | Continue |
| `AD` | `SetMoveNegateX` | 1 | `Byte` set/clear | `SetMoveNegateX` | Continue |
| `AE` | `SetMoveNegateY` | 2 | `Byte` set/clear | `SetMoveNegateY` | Continue |
| `AF` | `SetMoveNegateXY` | 6 | `Byte` set/clear | `SetMoveNegateXY` | Continue |
| `B0` | `ApplyMoveToChild` | 16 | `Byte`, `Byte` X, Y | `ApplyMoveToChild` | Continue |
| `B1` | `ReloadMoveChains` | 25 | (none) | `ReloadMoveChains` | Continue |

**Family call-site total:** 197

## Opcodes

#### COP [AA] — `StageMoveX` (stage X movement index and delta chain)

- **Preferred name:** `StageMoveX`
- **Aliases:** `StageForceMoveX`
- **Handler:** `StageMoveX` @ [`cop_handlers_force_move.asm:22-33`](../../../extracted/system/engine/cop_handlers_force_move.asm)
- **Parameters:** `Byte` — X movement index (`db-us/copdef.json`)
- **Outcome:** Continue
- **Usage count:** 60

##### What it does

Reads one byte, stores it in `moveXAlt` (`$7F0018,X`), calls `AnimFrameLookup`, writes the returned delta-chain pointer to actor `$2C`.

```asm
StageMoveX {
    TYX
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X
    JSR $&actor_pool.AnimFrameLookup
    STA $2C
    LDA $0A
    STA $02, S
    RTI
}
```

##### How it is used

Projectile spawn hooks pick an X slide index from player facing (`extracted/great_wall/gw82_eyesore.asm`):

```asm
COP [StageMoveX] ( #00 )   ; or #11 / #13 by direction RNG
```

Great Wall archer and Sand Fanger use repeated `StageMoveX` with different indices during attack phases (`gw82_archer.asm`, `gw8A_sand_fanger.asm`). Debris actors zero horizontal slide on cleanup (`pyramid/mummy_queen_lair/pyDD_queen_debris.asm`).

##### Parameters & contract

| Item | Detail |
|------|--------|
| Operand | Unsigned movement index into `move_chain_table` |
| WRAM | `moveXAlt` = operand; `$2C` = lookup result (chain head pointer) |
| Pairs with | `TickMove`, `StageSpriteMoveX`, gravity init on child actors |
| Outcome | Script PC advanced past 1 byte; same tick continue |

---

#### COP [AB] — `StageMoveY` (stage Y movement index and delta chain)

- **Preferred name:** `StageMoveY`
- **Aliases:** `StageForceMoveY`
- **Handler:** `StageMoveY` @ [`cop_handlers_force_move.asm:38-49`](../../../extracted/system/engine/cop_handlers_force_move.asm)
- **Parameters:** `Byte` Y index
- **Outcome:** Continue
- **Usage count:** 45

##### What it does

Same as `$AA` for the Y axis: operand → `moveYAlt` (`$7F001A,X`), `AnimFrameLookup` → `$2E` (Y delta-chain pointer).

```asm
StageMoveY {
    TYX
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveYAlt, X
    JSR $&actor_pool.AnimFrameLookup
    STA $2E
    ...
}
```

##### How it is used

Less common alone than `$AA`; appears in vertical knockback setups alongside `$AC` and sprite loop staging. Mystic ball and wall-walker scripts combine axis staging with anim ops (`pyramid/pyCC_mystic_ball.asm`, `angkor_wat/awB1_wall_walker.asm`).

##### Parameters & contract

| Item | Detail |
|------|--------|
| WRAM | `moveYAlt`, `$2E` updated |
| Outcome | Continue |

---

#### COP [AC] — `StageMoveXY` (stage both axes)

- **Preferred name:** `StageMoveXY`
- **Aliases:** `StageForceMoveXY`
- **Handler:** `StageMoveXY` @ [`cop_handlers_force_move.asm:54-71`](../../../extracted/system/engine/cop_handlers_force_move.asm)
- **Parameters:** `Byte` X index, `Byte` Y index
- **Outcome:** Continue
- **Usage count:** 42

##### What it does

Two sequential index stores and lookups: X → `moveXAlt` / `$2C`, then Y → `moveYAlt` / `$2E`.

```asm
StageMoveXY {
    TYX
    LDA [$0A]
    ...
    STA $moveXAlt, X
    JSR $&actor_pool.AnimFrameLookup
    STA $2C
    LDA [$0A]
    ...
    STA $moveYAlt, X
    JSR $&actor_pool.AnimFrameLookup
    STA $2E
    ...
}
```

##### How it is used

Diagonal slides on bosses and set pieces — e.g. Sand Fanger lunge (`gw8A_sand_fanger.asm`):

```asm
COP [StageMoveXY] ( #13, #45 )
COP [StageMoveXY] ( #03, #01 )
```

Reset to idle drift: `COP [StageMoveXY] ( #00, #00 )` after an attack (`pyCC_mystic_ball.asm`, `awB1_wall_walker.asm`).

##### Parameters & contract

| Item | Detail |
|------|--------|
| Operands | X index then Y index (2 bytes) |
| Outcome | Continue |

---

#### COP [AD] — `SetMoveNegateX` (negate or release the X delta)

- **Preferred name:** `SetMoveNegateX`
- **Aliases:** `SetForceSW`
- **Handler:** `SetMoveNegateX` @ [`cop_handlers_force_move.asm:76-94`](../../../extracted/system/engine/cop_handlers_force_move.asm)
- **Parameters:** `Byte` — nonzero sets bit `$4000` on `$12`; `#00` clears it
- **Outcome:** Continue
- **Usage count:** 1

##### What it does

```asm
SetMoveNegateX {
    TYX
    LDA [$0A]
    INC $0A
    AND #$00FF
    BEQ loc_clear
    LDA #$4000
    TSB $12
    ...
loc_clear:
    LDA #$4000
    TRB $12
    ...
}
```

While bit `$4000` is set, `ApplyMovement` and the collision-checked move negate the actor's X delta (the alias name `SetForceSW` says "southwest"; the effect is an X flip).

##### How it is used

Child projectile init sets `$4000` manually in Eyesore spawn (`gw82_eyesore.asm` `code_0B8E67`); `$AD`/`$AE`/`$AF` appear where scripts toggle the delta-negate bits without extra LDA/TSB boilerplate (Knight armor boss — `$AF` below).

##### Parameters & contract

| Item | Detail |
|------|--------|
| `$12` bit | `$4000` negate X delta |
| Clear | Operand `#00` |

---

#### COP [AE] — `SetMoveNegateY` (negate or release the Y delta)

- **Preferred name:** `SetMoveNegateY`
- **Aliases:** `SetForceNE`
- **Handler:** `SetMoveNegateY` @ [`cop_handlers_force_move.asm:99-117`](../../../extracted/system/engine/cop_handlers_force_move.asm)
- **Parameters:** `Byte` set/clear
- **Outcome:** Continue
- **Usage count:** 2

##### What it does

Identical pattern to `$AD` with mask `$2000` on `$12`: while set, the Y delta is negated (the alias name `SetForceNE` says "northeast"; the effect is a Y flip).

##### How it is used

Paired with `$AD`/`$AF` where a script flips the sign of the staged Y or X delta.

##### Parameters & contract

| Item | Detail |
|------|--------|
| `$12` bit | `$2000` negate Y delta |

---

#### COP [AF] — `SetMoveNegateXY` (negate or release both deltas)

- **Preferred name:** `SetMoveNegateXY`
- **Aliases:** `SetForceBoth`
- **Handler:** `SetMoveNegateXY` @ [`cop_handlers_force_move.asm:122-140`](../../../extracted/system/engine/cop_handlers_force_move.asm)
- **Parameters:** `Byte` set/clear
- **Outcome:** Continue
- **Usage count:** 6

##### What it does

TSB/TRB **`$6000`** on `$12` (both `$4000` and `$2000`).

##### How it is used

Sky Garden Knight armor (`sg4D_knight_armor.asm`):

```asm
COP [SetMoveNegateXY] ( #01 )
```

Sets both negate bits (`$6000`), so the staged slide runs with both deltas reversed.

##### Parameters & contract

| Item | Detail |
|------|--------|
| `$12` mask | `$6000` |
| Clear | `#00` operand |

---

#### COP [B0] — `ApplyMoveToChild` (stage tail child movement)

- **Preferred name:** `ApplyMoveToChild`
- **Aliases:** `ForceMoveLastChild`
- **Handler:** `ApplyMoveToChild` @ [`cop_handlers_force_move.asm:145-164`](../../../extracted/system/engine/cop_handlers_force_move.asm)
- **Parameters:** `Byte` X index, `Byte` Y index
- **Outcome:** Continue
- **Usage count:** 16

##### What it does

Switches context to **`LDX $0058`** (list tail), writes both indices and refreshed `$2C` / `$2E` on **that** actor, then restores caller context.

```asm
ApplyMoveToChild {
    PHY
    LDX $0058
    LDA [$0A]
    ...
    STA $moveXAlt, X
    JSR $&actor_pool.AnimFrameLookup
    STA $002C, X
    LDA [$0A]
    ...
    STA $moveYAlt, X
    JSR $&actor_pool.AnimFrameLookup
    STA $002E, X
    PLX
    ...
}
```

##### How it is used

Mu Flasher (`mu/mu5F_flasher.asm`) — parent plays wind-up anim, spawns projectile via `SpawnListAppend`, then pushes slide onto the child:

```asm
COP [SpawnListAppend] ( @code_0AE3D7, #F0, #F0, #$0202 )
LDA #$000C
STA $0026, Y
COP [ApplyMoveToChild] ( #06, #00 )
```

Four facing branches use different `(X,Y)` index pairs (`#06,#00`, `#05,#00`, `#00,#06`, `#00,#05`). Hit callbacks on the parent swap anim without respawning the child.

##### Parameters & contract

| Item | Detail |
|------|--------|
| Target | Actor at global `$0058`, not `X` |
| Preconditions | Child spawn immediately before op |
| WRAM on child | `moveXAlt`, `moveYAlt`, `$2C`, `$2E` |

---

#### COP [B1] — `ReloadMoveChains` (reload delta chains from indices)

- **Preferred name:** `ReloadMoveChains`
- **Aliases:** `ReloadForceMove`
- **Handler:** `ReloadMoveChains` @ [`cop_handlers_force_move.asm:169-180`](../../../extracted/system/engine/cop_handlers_force_move.asm)
- **Parameters:** (none)
- **Outcome:** Continue
- **Usage count:** 25

##### What it does

Re-reads existing `moveXAlt` / `moveYAlt` for the **current** actor and overwrites `$2C` / `$2E` with fresh `AnimFrameLookup` results (the chain head pointers, which rewinds both chains to their first node). Does not change indices or position.

```asm
ReloadMoveChains {
    TYX
    LDA $moveXAlt, X
    JSR $&actor_pool.AnimFrameLookup
    STA $002C, X
    LDA $moveYAlt, X
    JSR $&actor_pool.AnimFrameLookup
    STA $002E, X
    ...
}
```

##### How it is used

After gravity or special movement clobbers or advances the chain pointers — Dark Gaia / space flight (`babel_tower/comet_lair/sE8_dark_gaia.asm`, `sE7_space_flight_controller.asm`):

```asm
COP [ReloadMoveChains]
```

The unused **`unused_particle_rain_spawner`** child calls **`ReloadMoveChains`** once per 21-tick animation pass (not every frame) so movement chains stay armed after **`AnimOnce`** clears `$2C`/`$2E` (`actors/unused_particle_rain_spawner.asm`).

##### Parameters & contract

| Item | Detail |
|------|--------|
| Requires | Valid `moveXAlt` / `moveYAlt` already set |
| Does not | Restore indices from saved WRAM elsewhere |
