# COP family: Sprite animation

_Ops: `[88]`, `[89]`, `[8A]`, `[8B]`, `[8C]`_ · _Source: [`cop_handlers_sprite.asm`](../../../extracted/system/engine/cop_handlers_sprite.asm)_

[← COP index](../index.md) · [Sprite staging (configure)](sprite_staging.md)

## Overview

Five opcodes that **execute** metasprite animation after [sprite staging](sprite_staging.md) (`$80`–`$87` / `$8D`) or player staging (`$8F`–`$92`). `$88` switches the actor’s metasprite table pointer. `$89` and `$8A` drive `UpdateActorAnimation` until a cycle (or N cycles) completes, **yielding** via `RTL` while in progress. `$8B` advances at most one frame without yielding. `$8C` (`WaitForAnimFrame`, legacy script name `ContinueIfFrame`) yields until frame counter `$2A` equals a target byte.

These handlers assume `$7F0006`/`$7F0008` point at valid sprite set data (usually after `$88` or actor init).

## Shared state

| Symbol / WRAM | Role |
|---------------|------|
| `$28` / `$2A` | Animation index / in-sequence frame counter |
| `$7F0006,X` / `$7F0008,X` | Metasprite set pointer + bank (`SetMetasprite`) |
| `$7F0016,X` | Loop counter from `$84`–`$87`; decremented by `AnimLoop` |
| `$2C` / `$2E` | Movement frame durations; cleared when anim completes (`$89`/`$8A`/`$8B`/`$8C` paths) |
| `UpdateActorAnimation` | Advances frames, movement, OAM; **carry set** = sequence completed this step |

## Family notes

- **`$89` vs `$8A`:** One full cycle vs repeat until `sprTimer` hits 0 (must stage loop count with `$84`–`$87`).
- **`$8B`:** Use inside per-frame actor loops (`SetEntryHere` + `RTL`) where nested `$89` would deadlock.
- **`$8C`:** Operand is compared to **`$2A` after** an update; still animating if not equal (yield).
- **Carry convention:** After `UpdateActorAnimation`, **carry clear** → still running; **carry set** → cycle finished (handlers branch with `BCC` to yield path).

## Usage statistics

| Op | Name (script) | Uses | Params | Handler | Outcome |
|----|---------------|-----:|--------|---------|---------|
| `88` | `SetMetasprite` | 186 | `@&sprite-set` | `SetMetasprite` | Continue |
| `89` | `AnimOnce` | 2075 | (none) | `AnimOnce` | Halt until cycle done |
| `8A` | `AnimLoop` | 1048 | (none) | `AnimLoop` | Halt until loops exhausted |
| `8B` | `AnimOneFrame` | 165 | (none) | `AnimOneFrame` | Continue |
| `8C` | `WaitForAnimFrame` | 29 | `Byte` frame | `WaitForAnimFrame` | Halt until `$2A` match |

**Family call-site total:** 3503

_Legacy ASM names:_ `$8C` = `ContinueIfFrame` in older comments; handler symbol `WaitForAnimFrame`.

## Opcodes

#### COP [88] — `SetMetasprite` (point actor at spritesheet table)

- **Handler:** `SetMetasprite` @ [`cop_handlers_sprite.asm:355-368`](../../../extracted/system/engine/cop_handlers_sprite.asm)
- **Parameters:** `@&sprite-set` — word pointer + bank byte per `db-us/copdef.json`
- **Outcome:** Continue
- **Usage count:** 186

##### What it does

Loads a new 24-bit metasprite table address into actor WRAM `$7F0006` (word) and `$7F0008` (bank).

```asm
SetMetasprite {
    TYX
    LDA [$0A]             ; spriteset pointer word
    INC $0A
    INC $0A
    STA $spritesetPtr, X  ; $7F0006
    LDA [$0A]             ; bank byte
    INC $0A
    AND #$00FF
    STA $7F0008, X
    LDA $0A
    STA $02, S
    RTI
}
```

Does not change `$28` / `$2A` — typically followed by staging ops on the new set.

##### How it is used

Swap to enemy sheet before anim (`extracted/babel_tower/comet_lair/sE8_dark_gaia.asm`):

```asm
COP [SetMetasprite] ( @spriteset_enemies )
COP [StageSpriteFrame] ( #07 )
COP [AnimOnce]
```

Epilogue prop sheet (`extracted/ending/ending_comet/sE5_epilogue.asm`):

```asm
COP [SetMetasprite] ( @spriteset_enemies )
...
COP [SetMetasprite] ( @spriteset_npc_props )
COP [StageSprAndHitbox] ( #04 )
```

FX actor with particle set + global anim path (`extracted/angkor_wat/snake_pit/awB4_snake_pit_fx.asm`):

```asm
COP [SetMetasprite] ( @spriteset_particle_fx )
COP [ResetSpriteState] ( #00, #$2020 )
COP [AdvanceSpriteAnim]
```

##### Parameters & contract

| Item | Detail |
|------|--------|
| Operand | `@&label` or absolute pointer + bank |
| WRAM | `$7F0006`, `$7F0008` overwritten |
| Related | [sprite_state](sprite_state.md) `$55`/`$56` for table-driven VRAM anim without `$89` |

##### Relations

- **`$55` / `$56`:** Alternate animation path using `$24` and DMA (`AdvanceSpriteAnim`), not `UpdateActorAnimation`.
- **Staging `$80`+:** Required after sheet change to pick anim index on new table.

---

#### COP [89] — `AnimOnce` (run one full animation cycle)

- **Handler:** `AnimOnce` @ [`cop_handlers_sprite.asm:373-388`](../../../extracted/system/engine/cop_handlers_sprite.asm)
- **Parameters:** none
- **Outcome:** Halt (yields each frame until sequence completes)
- **Usage count:** 2075

##### What it does

Each time the actor is scheduled, calls `UpdateActorAnimation`. If the sequence **has not** finished (carry clear), pops the COP stack and **`RTL`** (end of tick). When carry is set (cycle complete), clears **`$2C` and `$2E`**, patches script return PC, **`RTI`**.

```asm
AnimOnce {
    TYX
    JSL $@sprite_composition.UpdateActorAnimation
    BCC loc_009FBD        ; C=0: still animating → yield
    LDA #$0000
    STA $2C
    STA $2E
    LDA $0A
    STA $02, S
    RTI

  loc_009FBD:
    PLA
    PLA
    RTL
}
```

##### How it is used

Universal pair with `StageSpriteFrame` (throughout ROM), e.g. Dark Gaia:

```asm
COP [StageSpriteFrame] ( #03 )
COP [AnimOnce]
```

After movement staging:

```asm
COP [StageSpriteMoveX] ( #04, #02 )
COP [AnimOnce]
```

##### Parameters & contract

| Item | Detail |
|------|--------|
| Preconditions | `$28` staged; metasprite pointer valid |
| Clears on success | `$2C`, `$2E` |
| Does not read | `$7F0016` (loop counter) |

##### Relations

- **`$8A`:** Re-runs until `sprTimer` exhausted.
- **`$8B`:** Single step, no wait.
- **`$8D`:** One-shot visual/hitbox update without full cycle wait.

---

#### COP [8A] — `AnimLoop` (repeat animation N times)

- **Handler:** `AnimLoop` @ [`cop_handlers_sprite.asm:393-413`](../../../extracted/system/engine/cop_handlers_sprite.asm)
- **Parameters:** none
- **Outcome:** Halt until `$7F0016` reaches 0
- **Usage count:** 1048

##### What it does

Inner loop at `loc_009FC1`: run `UpdateActorAnimation` until one **cycle** completes (carry set). Then **DEC** `sprTimer`; if nonzero, restart another cycle from the top; if zero, clear `$2C`/`$2E` and `RTI`. Incomplete cycle → `RTL` yield.

```asm
AnimLoop {
    TYX
  loc_009FC1:
    JSL $@sprite_composition.UpdateActorAnimation
    BCC loc_009FDB        ; yield mid-cycle
    LDA $sprTimer, X
    DEC
    STA $sprTimer, X
    BNE loc_009FC1        ; another full cycle
    STZ $2C
    STZ $2E
    ...
    RTI
  loc_009FDB:
    PLA
    PLA
    RTL
}
```

##### How it is used

Title screen (`extracted/system/title_screen/sFC_title_intro.asm`):

```asm
COP [StageSpriteLoop] ( #00, #F0 )
COP [AnimLoop]
COP [StageSpriteLoopMoveX] ( #00, #40, #02 )
COP [AnimLoop]
```

Epilogue (`extracted/ending/ending_comet/sE5_epilogue.asm`):

```asm
COP [StageSpriteLoopMoveY] ( #02, #04, #11 )
COP [AnimLoop]
```

##### Parameters & contract

| Item | Detail |
|------|--------|
| Preconditions | **`StageSpriteLoop*`** must have set `$7F0016` |
| `$89` | Wrong choice — ignores loop counter |

##### Relations

- **`$84`–`$87`:** Supply loop count (and optional move durations).
- **`$89`:** Single cycle only.

---

#### COP [8B] — `AnimOneFrame` (single update, no yield)

- **Handler:** `AnimOneFrame` @ [`cop_handlers_sprite.asm:418-430`](../../../extracted/system/engine/cop_handlers_sprite.asm)
- **Parameters:** none
- **Outcome:** Continue (always `RTI` same invocation)
- **Usage count:** 165

##### What it does

One `UpdateActorAnimation` call. If carry set (finished), clears `$2C`/`$2E`; otherwise leaves them. Always resumes script immediately.

```asm
AnimOneFrame {
    TYX
    JSL $@sprite_composition.UpdateActorAnimation
    BCC loc_009FEC
    LDA #$0000
    STA $2C
    STA $2E
  loc_009FEC:
    LDA $0A
    STA $02, S
    RTI
}
```

##### How it is used

Dark Gaia sub-actor tick (`extracted/babel_tower/comet_lair/sE8_dark_gaia.asm`):

```asm
  loc_0CF3C5:
    COP [SetEntryHere]
    COP [AnimOneFrame]
    LDA $08
    STA $24
    ...
    RTL
```

Space flight (`extracted/babel_tower/space_flight/sE7_space_flight_controller.asm`):

```asm
    COP [AnimOneFrame]
```

Use when the actor already re-enters every frame and must not nest a halting `$89`.

##### Parameters & contract

| Item | Detail |
|------|--------|
| Yield | Never |
| Risk | Calling without prior staging still runs update on current `$28` |

##### Relations

- **`$89`:** Full cycle with yield.
- **`$8C`:** Yields until target frame, not single step.

---

#### COP [8C] — `WaitForAnimFrame` (halt until frame index reached)

- **Handler:** `WaitForAnimFrame` @ [`cop_handlers_sprite.asm:435-463`](../../../extracted/system/engine/cop_handlers_sprite.asm)
- **Script name:** `WaitForAnimFrame` (legacy: `ContinueIfFrame`)
- **Parameters:** `Byte` target frame index
- **Outcome:** Halt until `$2A == target` (or sequence ends early)
- **Usage count:** 36

##### What it does

Calls `UpdateActorAnimation`. If carry set (anim ended before target), clears `$2C`/`$2E`, consumes operand, `RTI`. Otherwise reads target byte, compares to **`$2A`**: equal → `RTI`; not equal → `RTL` yield.

```asm
WaitForAnimFrame {
    TYX
    JSL $@sprite_composition.UpdateActorAnimation
    BCC loc_00A00B
    LDA #$0000
    STA $2C
    STA $2E
    LDA [$0A]
    INC $0A
    ...
    RTI

  loc_00A00B:
    LDA [$0A]
    INC $0A
    AND #$00FF
    CMP $2A
    BEQ loc_00A019        ; target frame reached
    PLA
    PLA
    RTL
  loc_00A019:
    ...
    RTI
}
```

##### How it is used

Archer sync: hitbox pose, move, wait for wind-up frame 2 (`extracted/great_wall/gw82_archer.asm`):

```asm
COP [StageSprAndHitbox] ( #8A )
COP [StageMoveX] ( #04 )
COP [WaitForAnimFrame] ( #02 )
COP [SetEntryHereAndYield]
```

Skuddle boss (`extracted/seaside_palace/sp5C_skuddle.asm`):

```asm
COP [WaitForAnimFrame] ( #02 )
```

##### Parameters & contract

| Item | Detail |
|------|--------|
| Operand | Compared against **`$2A`** after update |
| Early exit | Sequence end clears deltas and skips wait |
| Often paired with | `$8D` staging + `$52`/`$53` movement |

##### Relations

- **`$89`:** Waits for full cycle, not a specific frame index.
- **`$8D`:** Instant pose; `$8C` for mid-animation timing (SFX, collision enable).
