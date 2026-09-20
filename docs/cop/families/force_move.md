# COP family: Force move

_Ops: `[AA]`, `[AB]`, `[AC]`, `[AD]`, `[AE]`, `[AF]`, `[B0]`, `[B1]`_ · _Source: [`cop_handlers_lifecycle.asm`](../../../extracted/system/engine/cop_handlers_lifecycle.asm)_

[← COP index](../index.md) · [Sprite staging](sprite_staging.md) · [Movement](movement.md)

## Overview

Eight opcodes that configure **non-sprite** movement: they write movement **speed indices** into WRAM (`moveXAlt` / `moveYAlt`) and refresh **frame durations** at actor `$2C` / `$2E` via `AnimFrameLookup`. Companion ops set **forced facing** bits on `$12` (SW / NE diagonals) or copy the same staging onto the **list-tail child** at global `$0058`. `$B1` recomputes durations from the saved indices without changing indices — used after gravity, interrupts, or other code that clobbered `$2C` / `$2E`.

These pair with `COP [53]` (`TickMove`) and with sprite staging (`$81`–`$87`) when scripts want motion during an animation clip. They do **not** start animation by themselves.

## Shared state

| Symbol / WRAM | Role |
|---------------|------|
| `$7F0018,X` (`moveXAlt`) | X movement speed **index** (operand byte) |
| `$7F001A,X` (`moveYAlt`) | Y movement speed **index** |
| `$2C` / `$2E` | X / Y **frame durations** (output of `AnimFrameLookup`, consumed by movement tick) |
| `$12` | Actor flags; `$4000` = force SW, `$2000` = force NE, `$6000` = both (via `$AD`–`$AF`) |
| `$0058` | Actor list **tail** pointer — target of `$B0` (typically the child just appended by spawn) |
| `AnimFrameLookup` | `actor_pool` — maps speed index → duration word |

## Family notes

- Operands are **table indices**, not pixel deltas. Direction of travel still comes from animation movement tables, `$12` facing bits, and optional `ForceDir*` overrides.
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
| `AD` | `ForceDirSW` | 1 | `Byte` set/clear | `ForceDirSW` | Continue |
| `AE` | `ForceDirNE` | 2 | `Byte` set/clear | `ForceDirNE` | Continue |
| `AF` | `ForceDirBoth` | 6 | `Byte` set/clear | `ForceDirBoth` | Continue |
| `B0` | `ApplyMoveToChild` | 16 | `Byte`, `Byte` X, Y | `ApplyMoveToChild` | Continue |
| `B1` | `ReloadMoveDurations` | 25 | (none) | `ReloadMoveDurations` | Continue |

**Family call-site total:** 197

## Opcodes

#### COP [AA] — `StageMoveX` (stage X speed index and duration)

- **Preferred name:** `StageMoveX`
- **Aliases:** `StageForceMoveX`
- **Handler:** `StageMoveX` @ [`cop_handlers_lifecycle.asm:541-552`](../../../extracted/system/engine/cop_handlers_lifecycle.asm)
- **Parameters:** `Byte` — X movement speed index (`db-us/copdef.json`)
- **Outcome:** Continue
- **Usage count:** 60

##### What it does

Reads one byte, stores it in `moveXAlt` (`$7F0018,X`), calls `AnimFrameLookup`, writes the returned duration to actor `$2C`.

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
| Operand | Unsigned speed index; duration comes from engine table |
| WRAM | `moveXAlt` = operand; `$2C` = lookup result |
| Pairs with | `TickMove`, `StageSpriteMoveX`, gravity init on child actors |
| Outcome | Script PC advanced past 1 byte; same tick continue |

---

#### COP [AB] — `StageMoveY` (stage Y speed index and duration)

- **Preferred name:** `StageMoveY`
- **Aliases:** `StageForceMoveY`
- **Handler:** `StageMoveY` @ [`cop_handlers_lifecycle.asm:557-568`](../../../extracted/system/engine/cop_handlers_lifecycle.asm)
- **Parameters:** `Byte` Y index
- **Outcome:** Continue
- **Usage count:** 45

##### What it does

Same as `$AA` for the Y axis: operand → `moveYAlt` (`$7F001A,X`), `AnimFrameLookup` → `$2E`.

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
- **Handler:** `StageMoveXY` @ [`cop_handlers_lifecycle.asm:573-590`](../../../extracted/system/engine/cop_handlers_lifecycle.asm)
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

#### COP [AD] — `ForceDirSW` (force or release southwest diagonal)

- **Preferred name:** `ForceDirSW`
- **Aliases:** `SetForceSW`
- **Handler:** `ForceDirSW` @ [`cop_handlers_lifecycle.asm:595-613`](../../../extracted/system/engine/cop_handlers_lifecycle.asm)
- **Parameters:** `Byte` — nonzero sets bit `$4000` on `$12`; `#00` clears it
- **Outcome:** Continue
- **Usage count:** 1

##### What it does

```asm
ForceDirSW {
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

When set, movement staging respects SW-facing regardless of sprite flip — used so `$81`–`$87` deltas run “backward” on the diagonal plane.

##### How it is used

Child projectile init sets `$4000` manually in Eyesore spawn (`gw82_eyesore.asm` `code_0B8E67`); `$AD`/`$AE`/`$AF` appear where scripts toggle forced diagonals without extra LDA/TSB boilerplate (Knight armor boss — `$AF` below).

##### Parameters & contract

| Item | Detail |
|------|--------|
| `$12` bit | `$4000` SW force |
| Clear | Operand `#00` |

---

#### COP [AE] — `ForceDirNE` (force or release northeast diagonal)

- **Preferred name:** `ForceDirNE`
- **Aliases:** `SetForceNE`
- **Handler:** `ForceDirNE` @ [`cop_handlers_lifecycle.asm:618-636`](../../../extracted/system/engine/cop_handlers_lifecycle.asm)
- **Parameters:** `Byte` set/clear
- **Outcome:** Continue
- **Usage count:** 2

##### What it does

Identical pattern to `$AD` with mask `$2000` on `$12`.

##### How it is used

Paired with `$AD`/`$AF` on enemies that must slide along fixed isometric diagonals during scripted knockback or cutscene pushes.

##### Parameters & contract

| Item | Detail |
|------|--------|
| `$12` bit | `$2000` NE force |

---

#### COP [AF] — `ForceDirBoth` (force or release both diagonal bits)

- **Preferred name:** `ForceDirBoth`
- **Aliases:** `SetForceBoth`
- **Handler:** `ForceDirBoth` @ [`cop_handlers_lifecycle.asm:641-659`](../../../extracted/system/engine/cop_handlers_lifecycle.asm)
- **Parameters:** `Byte` set/clear
- **Outcome:** Continue
- **Usage count:** 6

##### What it does

TSB/TRB **`$6000`** on `$12` (both `$4000` and `$2000`).

##### How it is used

Sky Garden Knight armor (`sg4D_knight_armor.asm`):

```asm
COP [ForceDirBoth] ( #01 )
```

Locks both diagonal force bits during a scripted slide so movement tables cannot flip sign mid-attack.

##### Parameters & contract

| Item | Detail |
|------|--------|
| `$12` mask | `$6000` |
| Clear | `#00` operand |

---

#### COP [B0] — `ApplyMoveToChild` (stage tail child movement)

- **Preferred name:** `ApplyMoveToChild`
- **Aliases:** `ForceMoveLastChild`
- **Handler:** `ApplyMoveToChild` @ [`cop_handlers_lifecycle.asm:664-683`](../../../extracted/system/engine/cop_handlers_lifecycle.asm)
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

#### COP [B1] — `ReloadMoveDurations` (refresh durations from indices)

- **Preferred name:** `ReloadMoveDurations`
- **Aliases:** `ReloadForceMove`
- **Handler:** `ReloadMoveDurations` @ [`cop_handlers_lifecycle.asm:688-699`](../../../extracted/system/engine/cop_handlers_lifecycle.asm)
- **Parameters:** (none)
- **Outcome:** Continue
- **Usage count:** 25

##### What it does

Re-reads existing `moveXAlt` / `moveYAlt` for the **current** actor and overwrites `$2C` / `$2E` with fresh `AnimFrameLookup` results. Does not change indices or position.

```asm
ReloadMoveDurations {
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

After gravity or special movement corrupts durations — Dark Gaia / space flight (`babel_tower/comet_lair/sE8_dark_gaia.asm`, `sE7_space_flight_controller.asm`):

```asm
COP [ReloadMoveDurations]
```

Particle rain spawner reapplies velocity each tick (`actors/particle_rain_spawner.asm`).

##### Parameters & contract

| Item | Detail |
|------|--------|
| Requires | Valid `moveXAlt` / `moveYAlt` already set |
| Does not | Restore indices from saved WRAM elsewhere |
