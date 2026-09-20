# COP family: Callbacks

_Ops: `[57]`, `[58]`, `[59]`, `[5A]`, `[5E]`_ · _Source: [`cop_handlers_lifecycle.asm`](../../../extracted/system/engine/cop_handlers_lifecycle.asm)_

[← COP index](../index.md) · [Actor death](actor_death.md)

## Overview

Five opcodes **install script entry pointers** into per-actor WRAM callback slots. The main loop and combat systems dispatch to these addresses when the matching event fires (hit, dodge, death, actor–actor collide, or a custom hook). All setters are **continue** ops: they only write pointers and advance the script PC.

Callbacks run in **actor script context** (same bank rules as the owning actor). Near pointers (`&Code`) dominate; death alone stores a **far** pointer plus bank byte.

## Shared state

| WRAM | Opcode | Pointer type |
|------|--------|----------------|
| `$7F1000,X` (`onHitCallback`) | `$58` | Near `&Code` |
| `$7F1002,X` (`onDodgeCallback`) | `$59` | Near `&Code` |
| `$7F1004,X` + `$7F1006,X` (`onDeathCallback` + bank) | `$57` | Far `@Code` + bank byte |
| `$7F1008,X` (`onCollideCallback`) | `$5A` | Near `&Code` |
| `$7F1016,X` (`scratch1010+6`, custom) | `$5E` | Near `&Code` |

Clearing a callback: store **`#$0000`** (near) or **`$000000`** (far death) — see Dark Gaia teardown (`sE8_dark_gaia.asm`).

## Family notes

- **`$57` operand layout:** word at `@Code` then **one bank byte** (handler reads 3 bytes total). Matches `@Code` in `copdef.json`.
- Hit/dodge/collide/custom use **2-byte** near operands only; callee must live in the caller’s script bank or be reachable via same-bank `&` labels.
- `$5E` is the generic “extra” hook — often paired with `$5A` on the same label (Cyber Garden drones duplicate one routine for collide + custom).
- Legacy names unchanged for hit/death/dodge/collide; `$5E` was `SetExtraCallback` → **`SetCustomCallback`**.

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `57` | `SetDeathCallback` | 41 | `@Code` | `SetDeathCallback` | Continue |
| `58` | `SetHitCallback` | 104 | `&Code` | `SetHitCallback` | Continue |
| `59` | `SetDodgeCallback` | 3 | `&Code` | `SetDodgeCallback` | Continue |
| `5A` | `SetCollideCallback` | 11 | `&Code` | `SetCollideCallback` | Continue |
| `5E` | `SetCustomCallback` | 6 | `&Code` | `SetCustomCallback` | Continue |

**Family call-site total:** 165

## Opcodes

#### COP [57] — `SetDeathCallback` (install death script hook)

- **Preferred name:** `SetDeathCallback`
- **Handler:** `SetDeathCallback` @ [`cop_handlers_lifecycle.asm:240-253`](../../../extracted/system/engine/cop_handlers_lifecycle.asm)
- **Parameters:** `@Code` — 16-bit offset + **bank byte** following in script stream
- **Outcome:** Continue
- **Usage count:** 41

##### What it does

Reads far pointer word → `$7F1004,X`, bank byte → `$7F1006,X`. Engine death path jumps there instead of default removal when nonzero.

```asm
SetDeathCallback {
    TYX
    LDA [$0A]
    INC $0A
    INC $0A
    STA $onDeathCallback, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $7F1006, X
    ...
}
```

##### How it is used

Bosses and projectiles register custom death FX — Mystic Ball (`pyramid/pyCC_mystic_ball.asm`):

```asm
COP [SetDeathCallback] ( @code_0BC6E7 )
```

Wall Walker and Haunt reuse one death routine across states (`awB1_wall_walker.asm`, `pyD2_haunt.asm`). Clear on phase end:

```asm
COP [SetDeathCallback] ( $000000 )
```

##### Parameters & contract

| Item | Detail |
|------|--------|
| Storage | `$7F1004` word + `$7F1006` bank |
| Clear | `$000000` operand form in extracted ASM |
| Dispatched | When actor HP/ death pipeline runs user hook |

---

#### COP [58] — `SetHitCallback` (install damage reaction)

- **Preferred name:** `SetHitCallback`
- **Handler:** `SetHitCallback` @ [`cop_handlers_lifecycle.asm:258-267`](../../../extracted/system/engine/cop_handlers_lifecycle.asm)
- **Parameters:** `&Code`
- **Outcome:** Continue
- **Usage count:** 104

##### What it does

Stores near pointer in `$7F1000,X`.

```asm
SetHitCallback {
    TYX
    LDA [$0A]
    INC $0A
    INC $0A
    STA $onHitCallback, X
    ...
}
```

##### How it is used

**Pattern A — Ranged enemy idle:** Blaster sets hit once at init (`pyramid/pyCC_blaster.asm`):

```asm
COP [SetHitCallback] ( &code_0BC807 )
```

**Pattern B — Phase branch:** Mu Flasher picks one of four hit handlers per approach axis, then spawns child (`mu/mu5F_flasher.asm`):

```asm
COP [SetHitCallback] ( &code_0AE33F )
...
COP [ApplyMoveToChild] ( #06, #00 )
```

Hit callee typically plays hurt anim and `COP [RestoreSavedPtr]` or `COP [01]` return.

**Pattern C — Disable:** `COP [SetHitCallback] ( #$0000 )` during invulnerability (Dark Gaia).

##### Parameters & contract

| Item | Detail |
|------|--------|
| Pointer | Same-bank `&Code` |
| Re-entrant | Each `$58` overwrites prior hit hook |

---

#### COP [59] — `SetDodgeCallback` (install dodge / miss hook)

- **Preferred name:** `SetDodgeCallback`
- **Handler:** `SetDodgeCallback` @ [`cop_handlers_lifecycle.asm:272-281`](../../../extracted/system/engine/cop_handlers_lifecycle.asm)
- **Parameters:** `&Code`
- **Outcome:** Continue
- **Usage count:** 3

##### What it does

Stores near pointer in `$7F1002,X`.

##### How it is used

Rare — Seaside Palace Slipper (`seaside_palace/sp5C_slipper.asm`) toggles dodge handler for evade minigame:

```asm
COP [SetDodgeCallback] ( #$0000 )
...
COP [SetDodgeCallback] ( &code_0AE539 )
```

##### Parameters & contract

| Item | Detail |
|------|--------|
| WRAM | `$7F1002` |
| Usage | Almost unused globally (3 sites) |

---

#### COP [5A] — `SetCollideCallback` (actor–actor collision script)

- **Preferred name:** `SetCollideCallback`
- **Handler:** `SetCollideCallback` @ [`cop_handlers_lifecycle.asm:286-295`](../../../extracted/system/engine/cop_handlers_lifecycle.asm)
- **Parameters:** `&Code`
- **Outcome:** Continue
- **Usage count:** 11

##### What it does

Stores near pointer in `$7F1008,X`.

##### How it is used

Cyber Garden (`sky_garden/sg4D_cyber.asm`) — each drone mode installs matching collide + custom on the same handler, cleared with `#$0000` when mode ends:

```asm
COP [SetCollideCallback] ( &code_0ABD90 )
COP [SetCustomCallback] ( &code_0ABD90 )
...
COP [SetCollideCallback] ( #$0000 )
```

##### Parameters & contract

| Item | Detail |
|------|--------|
| Event | Another actor’s collision volume triggers script |
| Pairs with | `$5E` for dual dispatch |

---

#### COP [5E] — `SetCustomCallback` (game-specific extra hook)

- **Preferred name:** `SetCustomCallback`
- **Aliases:** `SetExtraCallback`
- **Handler:** `SetCustomCallback` @ [`cop_handlers_lifecycle.asm:300-309`](../../../extracted/system/engine/cop_handlers_lifecycle.asm)
- **Parameters:** `&Code`
- **Outcome:** Continue
- **Usage count:** 31

##### What it does

Stores near pointer at `$7F1016,X` (`scratch1010+6`).

##### How it is used

Great Wall archer aim modes (`great_wall/gw82_archer.asm`):

```asm
COP [SetCustomCallback] ( &code_0B92E9 )
...
COP [SetCustomCallback] ( &code_0B92F9 )
```

Cyber drones (above) share one routine for custom + collide. Engine call sites for `$7F1016` are sparser than hit/death — treat as **special-case** dispatch documented per actor class.

##### Parameters & contract

| Item | Detail |
|------|--------|
| WRAM | `$7F1016` |
| Semantics | Actor-dependent; inspect class `#` handler in engine |
