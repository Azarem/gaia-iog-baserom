# COP family: Sprite staging

_Ops: `[80]`, `[81]`, `[82]`, `[83]`, `[84]`, `[85]`, `[86]`, `[87]`, `[8D]`_ · _Source: [`cop_handlers_sprite.asm`](../../../extracted/system/engine/cop_handlers_sprite.asm)_

[← COP index](../README.md) · [Sprite animation (execute)](sprite_anim.md)

## Overview

Nine opcodes that **configure** actor sprite animation before playback. The core eight (`$80`–`$87`) form a **combinatorial set** over three optional operand dimensions: loop count (`sprTimer`), X movement duration, and Y movement duration. None of them advance animation by themselves — they set `$28` (animation index), clear `$2A` (frame counter), and optionally `$2C` / `$2E` (axis frame durations) and `$7F0016` (loop counter).

**Critical pairing:** After staging, scripts almost always call `$89` (`AnimOnce`), `$8A` (`AnimLoop`), or occasionally `$8B` / `$8C` from [sprite_anim](sprite_anim.md). `$8D` is the exception: it stages **and** runs one `UpdateActorAnimation` pass so hitbox/OAM data match the pose immediately.

Handler labels in ASM (`StageSpr`, `StageSprX`, …) differ from **script names** in extracted source (`StageSpriteFrame`, `StageSpriteMoveX`, …); both refer to the same COP bytes.

## Shared state

| Symbol / WRAM | Role |
|---------------|------|
| `$28` | Animation index into the current metasprite set |
| `$2A` | Frame counter within the current animation sequence (cleared on every stage via `ProcessAnimFlag`) |
| `$2C` / `$2E` | X / Y **frame durations** (ticks per sub-frame), from `AnimFrameLookup` |
| `$7F0016,X` (`sprTimer`) | Loop/repeat count for `$84`–`$87`, consumed by `AnimLoop` |
| `$7F0018,X` / `$7F001A,X` (`moveXAlt` / `moveYAlt`) | Raw movement **speed indices** (operands), used when animation runs |
| `$0E` | OAM attribute word; horizontal flip `$4000` adjusted by `ProcessAnimFlag` |
| `$12` | Actor status; bit `$0002` selects facing for flip logic |
| `$7F0006,X` / `$7F0008,X` | Metasprite table pointer (set by `$88`, not by staging ops) |
| `ProcessAnimFlag` | Internal helper at end of same file — interprets anim index byte (`$FF`, bit `$80`, flip) |
| `AnimFrameLookup` | Maps movement speed index → duration in `$2C` / `$2E` (`actor_pool`) |
| `UpdateActorAnimation` | Used only by `$8D` in this family (`sprite_composition`) |

## Family notes

- **Combinatorial encoding:** `(loop?)(move X?)(move Y?)`. `$80` = frame only; `$84` = frame + loop; `$85` = loop + X; `$87` = loop + X + Y.
- Movement operands are **indices** into the movement delta / duration table, not pixel counts. Actual step direction comes from movement staging elsewhere (`StageMoveX`, etc.) and from flip bits on `$0E`.
- Anim index **`#$FF`:** `ProcessAnimFlag` leaves `$28` unchanged but still clears `$2A` (restart current clip from frame 0).
- Anim index **bit `$80` set:** low 7 bits go to `$28`; flip on `$0E` is toggled based on facing (`$12` bit `$0002`).
- Do not call `$89` / `$8A` without a preceding `$80`–`$87` or `$8D` (or player equivalents `$8F`–`$92`) — executors assume staged `$28` / timers / deltas.

## Usage statistics

| Op | Name (script) | Uses | Params | Handler | Outcome |
|----|---------------|-----:|--------|---------|---------|
| `80` | `StageSpriteFrame` | 1200 | `Byte` anim | `StageSpr` | Continue |
| `81` | `StageSpriteMoveX` | 310 | `Byte`, `Byte` anim, X speed | `StageSprX` | Continue |
| `82` | `StageSpriteMoveY` | 331 | `Byte`, `Byte` anim, Y speed | `StageSprY` | Continue |
| `83` | `StageSpriteMoveXY` | 68 | `Byte`, `Byte`, `Byte` anim, X, Y | `StageSprXY` | Continue |
| `84` | `StageSpriteLoop` | 455 | `Byte`, `Byte` anim, loops | `StageSprLoop` | Continue |
| `85` | `StageSpriteLoopMoveX` | 278 | `Byte`, `Byte`, `Byte` anim, loops, X | `StageSprLoopX` | Continue |
| `86` | `StageSpriteLoopMoveY` | 252 | `Byte`, `Byte`, `Byte` anim, loops, Y | `StageSprLoopY` | Continue |
| `87` | `StageSpriteLoopMoveXY` | 61 | four bytes anim, loops, X, Y | `StageSprLoopXY` | Continue |
| `8D` | `StageSprAndHitbox` | 229 | `Byte` anim | `StageSprAndHitbox` | Continue |

**Family call-site total:** 3184

## Opcodes

#### COP [80] — `StageSpriteFrame` (stage animation index only)

- **Handler:** `StageSpr` @ [`cop_handlers_sprite.asm:118-130`](../../../extracted/system/engine/cop_handlers_sprite.asm)
- **Script alias:** `COP [StageSpriteFrame]` (same as handler name `StageSpr` in dispatch table)
- **Parameters:** `Byte` — animation index byte (see `ProcessAnimFlag` for `$FF` / `$80` semantics)
- **Outcome:** Continue (`RTI` same tick)
- **Usage count:** 1200
- **Pairs with:** `COP [89]` (`AnimOnce`) or `COP [8A]` (`AnimLoop`) after loop staging on `$84`–`$87`

##### What it does

Reads one anim index byte, runs `ProcessAnimFlag` (sets `$28`, clears `$2A`, may adjust flip on `$0E`), refreshes script bank `$02` and entry cache `$00` from `$0C` / `$0A`, then returns to script.

```asm
StageSpr {
    TYX
    LDA [$0A]             ; anim index operand
    INC $0A
    AND #$00FF
    JSR $&ProcessAnimFlag ; → $28, $2A=0, flip rules
    LDA $0C
    STA $02
    LDA $0A
    STA $00               ; script PC cache
    STA $02, S
    RTI
}
```

Line-by-line:

1. **`TYX`** — COP handler convention: `X` = actor slot index.
2. **Operand read** — Low byte of anim index; advance script PC `$0A`.
3. **`ProcessAnimFlag`** — Shared helper (lines 318–350): always `STZ $2A`; `$FF` = keep `$28`; bit 7 = direction-sensitive index + flip; else store index and clear/set `$4000` on `$0E` from `$12`.
4. **Script resume fields** — `$0C` → data bank for script; `$0A` → saved entry / return PC for this actor.

##### How it is used

Dominant pattern: one line stage + one line animate.

`extracted/babel_tower/comet_lair/sE8_dark_gaia.asm`:

```asm
COP [StageSpriteFrame] ( #1F )
COP [AnimOnce]
```

Loop setup uses `$84` elsewhere; frame-only staging for state changes:

```asm
COP [StageSpriteFrame] ( #FF )   ; keep $28, restart from frame 0
COP [AnimOnce]
```

Epilogue pose without movement bytes (`extracted/ending/ending_comet/sE5_epilogue.asm`):

```asm
COP [StageSpriteFrame] ( #2A )
COP [AnimOnce]
```

##### Parameters & contract

| Item | Detail |
|------|--------|
| Operand | Animation index; `$80`–`$FF` encodes flip / hold-current-index per `ProcessAnimFlag` |
| `$28` | Written (unless operand is `$FF`) |
| `$2A` | Cleared to 0 |
| `$2C` / `$2E` | **Not** set by `$80` — prior values may linger until `$89`/`$8A` clear them on completion |
| `$7F0016` | Unchanged |
| Next op | Typically `$89` or `$8A` |

##### Relations

- **`$81`–`$87`:** Same staging prefix with movement and/or loop operands.
- **`$8D`:** Same anim index semantics but immediately applies pose + hitbox via `UpdateActorAnimation`.
- **Player `$8F`:** Parallel staging for the player actor ([`cop_handlers_player_sprite.asm`](../../../extracted/system/engine/cop_handlers_player_sprite.asm)).

---

#### COP [81] — `StageSpriteMoveX` (stage + X axis duration)

- **Handler:** `StageSprX` @ [`cop_handlers_sprite.asm:135-153`](../../../extracted/system/engine/cop_handlers_sprite.asm)
- **Parameters:** `Byte` anim, `Byte` X speed index
- **Outcome:** Continue
- **Usage count:** 310

##### What it does

After `ProcessAnimFlag`, stores the second operand in `$7F0018,X` (`moveXAlt`) and calls `AnimFrameLookup` to fill **`$2C`** (X frame duration). Y duration `$2E` is untouched.

```asm
StageSprX {
    TYX
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&ProcessAnimFlag
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $moveXAlt, X
    JSR $&actor_pool.AnimFrameLookup
    STA $2C
    ; … script PC / RTI same as StageSpr
}
```

##### How it is used

Horizontal walk cycles with anim + speed (`extracted/ending/ending_comet/sE5_epilogue.asm`):

```asm
COP [StageSpriteMoveX] ( #21, #13 )
```

Pyramid tutorial actors stepping on X (`extracted/pyramid/pyCE_tuts.asm`):

```asm
COP [StageSpriteMoveX] ( #05, #02 )
COP [AnimOnce]
```

Direction-bit anim indices (`#85` = index `$05` | flip flag):

```asm
COP [StageSpriteMoveX] ( #85, #01 )
```

##### Parameters & contract

| Item | Detail |
|------|--------|
| Byte 1 | Anim index (`ProcessAnimFlag`) |
| Byte 2 | X movement **speed index** → `$2C` via lookup |
| WRAM | `$7F0018,X` = raw speed index for runtime movement |
| Pairs with | `COP [89]` / `[8A]`; often `COP [StageMoveX]` in same script beat |

##### Relations

- **`$82` / `$83`:** Y-only or both axes.
- **`$85`:** Adds loop count before X speed byte.

---

#### COP [82] — `StageSpriteMoveY` (stage + Y axis duration)

- **Handler:** `StageSprY` @ [`cop_handlers_sprite.asm:158-176`](../../../extracted/system/engine/cop_handlers_sprite.asm)
- **Parameters:** `Byte` anim, `Byte` Y speed index
- **Outcome:** Continue
- **Usage count:** 331

##### What it does

Mirrors `$81` for the Y axis: operand → `$7F001A,X` (`moveYAlt`), lookup → **`$2E`**.

##### How it is used

Vertical motion on Dark Gaia (`extracted/babel_tower/comet_lair/sE8_dark_gaia.asm`):

```asm
COP [StageSpriteMoveY] ( #13, #0A )
COP [AnimOnce]
COP [StageSpriteMoveY] ( #13, #2A )
```

Mystic ball drift (`extracted/pyramid/pyCC_mystic_ball.asm`):

```asm
COP [StageSpriteMoveY] ( #0F, #12 )
COP [AnimOnce]
```

##### Parameters & contract

| Item | Detail |
|------|--------|
| Byte 2 | Y speed index → `$2E` |
| `$2C` | Not modified |

##### Relations

- **`$81` / `$83`:** X-only or combined XY staging.
- **`$86` / `$87`:** Loop variants with Y or XY.

---

#### COP [83] — `StageSpriteMoveXY` (stage + both axis durations)

- **Handler:** `StageSprXY` @ [`cop_handlers_sprite.asm:181-205`](../../../extracted/system/engine/cop_handlers_sprite.asm)
- **Parameters:** `Byte` anim, `Byte` X speed, `Byte` Y speed
- **Outcome:** Continue
- **Usage count:** 68

##### What it does

`ProcessAnimFlag`, then X operand → lookup → `$2C`, then Y operand → lookup → `$2E`.

##### How it is used

Diagonal comet lair motion (`extracted/babel_tower/comet_lair/sE8_dark_gaia.asm`):

```asm
COP [StageSpriteMoveXY] ( #1B, #00, #06 )
COP [AnimOnce]
COP [StageSpriteMoveXY] ( #1C, #00, #06 )
COP [AnimOnce]
```

##### Parameters & contract

| Item | Detail |
|------|--------|
| Bytes 2–3 | Independent speed indices for X and Y durations |

##### Relations

- **`$87`:** Same operands plus leading loop count for `$8A`.

---

#### COP [84] — `StageSpriteLoop` (stage + loop count)

- **Handler:** `StageSprLoop` @ [`cop_handlers_sprite.asm:210-226`](../../../extracted/system/engine/cop_handlers_sprite.asm)
- **Parameters:** `Byte` anim, `Byte` loops
- **Outcome:** Continue
- **Usage count:** 455

##### What it does

After `ProcessAnimFlag`, second byte → **`$7F0016,X`** (`sprTimer`). `$8A` (`AnimLoop`) decrements this after each full animation cycle.

```asm
StageSprLoop {
    ...
    STA $sprTimer, X      ; loop count for AnimLoop
    ...
}
```

##### How it is used

Title comet idle loop (`extracted/system/title_screen/sFC_title_intro.asm`):

```asm
COP [StageSpriteLoop] ( #00, #F0 ) ; 240 cycles
COP [AnimLoop]
```

Dark Gaia timed loop (`extracted/babel_tower/comet_lair/sE8_dark_gaia.asm`):

```asm
COP [StageSpriteLoop] ( #06, #3C )
COP [AnimLoop]
```

##### Parameters & contract

| Item | Detail |
|------|--------|
| Byte 2 | Repeat count for **`AnimLoop`** only (ignored by `AnimOnce`) |
| Must pair with | `COP [8A]` — not `$89` |

##### Relations

- **`$85`–`$87`:** Add movement speed bytes while still using `$8A`.

---

#### COP [85] — `StageSpriteLoopMoveX` (stage + loop + X duration)

- **Handler:** `StageSprLoopX` @ [`cop_handlers_sprite.asm:231-253`](../../../extracted/system/engine/cop_handlers_sprite.asm)
- **Parameters:** `Byte` anim, `Byte` loops, `Byte` X speed
- **Outcome:** Continue
- **Usage count:** 278

##### What it does

`ProcessAnimFlag` → `sprTimer` → X speed → `$2C` via lookup (same field order as operands).

##### How it is used

Title horizontal sweep after idle loop (`extracted/system/title_screen/sFC_title_intro.asm`):

```asm
COP [StageSpriteLoopMoveX] ( #00, #40, #02 ) ; 64 repeats, X speed 2
COP [AnimLoop]
```

Prologue walk (`extracted/prologue/prologue_missing/pr8E_prologue3.asm`):

```asm
COP [StageSpriteLoopMoveX] ( #0C, #08, #02 )
COP [AnimLoop]
```

##### Parameters & contract

| Item | Detail |
|------|--------|
| Byte 2 | Loop count → `$7F0016` |
| Byte 3 | X speed index → `$2C` |

##### Relations

- **`$84`:** Loop without X duration.
- **`$86` / `$87`:** Y or XY loop staging.

---

#### COP [86] — `StageSpriteLoopMoveY` (stage + loop + Y duration)

- **Handler:** `StageSprLoopY` @ [`cop_handlers_sprite.asm:258-280`](../../../extracted/system/engine/cop_handlers_sprite.asm)
- **Parameters:** `Byte` anim, `Byte` loops, `Byte` Y speed
- **Outcome:** Continue
- **Usage count:** 252

##### What it does

Same as `$85` but Y speed → `$2E` / `$7F001A`.

##### How it is used

Epilogue vertical march (`extracted/ending/ending_comet/sE5_epilogue.asm`):

```asm
COP [StageSpriteLoopMoveY] ( #02, #04, #11 )
COP [AnimLoop]
...
COP [StageSpriteLoopMoveY] ( #04, #04, #14 )
COP [AnimLoop]
```

##### Parameters & contract

| Item | Detail |
|------|--------|
| Byte 3 | Y speed index → `$2E` |

##### Relations

- **`$85`:** X loop variant.
- **`$87`:** Both axes with loop.

---

#### COP [87] — `StageSpriteLoopMoveXY` (stage + loop + X + Y durations)

- **Handler:** `StageSprLoopXY` @ [`cop_handlers_sprite.asm:285-313`](../../../extracted/system/engine/cop_handlers_sprite.asm)
- **Parameters:** `Byte` anim, `Byte` loops, `Byte` X speed, `Byte` Y speed
- **Outcome:** Continue
- **Usage count:** 61

##### What it does

Full staging: timer, both movement indices, both `$2C` and `$2E`.

##### How it is used

Zip fly enemy figure-eight (`extracted/angkor_wat/awB0_zip_fly.asm`):

```asm
COP [StageSpriteLoopMoveXY] ( #03, #04, #06, #05 )
COP [AnimLoop]
COP [StageSpriteLoopMoveXY] ( #04, #04, #06, #06 )
COP [AnimLoop]
```

Viper lair boss paths (`extracted/sky_garden/viper_lair/sg55_viper.asm`):

```asm
COP [StageSpriteLoopMoveXY] ( #1D, #20, #02, #00 )
COP [AnimLoop]
```

##### Parameters & contract

| Item | Detail |
|------|--------|
| Four bytes | anim, loop count, X speed, Y speed |
| Executor | **`AnimLoop`** only |

##### Relations

- **`$83`:** Same movement staging without loop (use `$89`).
- **`$85` / `$86`:** Single-axis loop forms.

---

#### COP [8D] — `StageSprAndHitbox` (stage + immediate sprite/hitbox refresh)

- **Handler:** `StageSprAndHitbox` @ [`cop_handlers_sprite.asm:468-482`](../../../extracted/system/engine/cop_handlers_sprite.asm)
- **Parameters:** `Byte` anim
- **Outcome:** Continue (no yield — completes in one COP invocation)
- **Usage count:** 229

##### What it does

`ProcessAnimFlag`, then **`JSL UpdateActorAnimation`** once (updates tiles, metasprite, **hitbox**), then **`STZ $2A`** so the staged pose is treated as frame 0 without leaving the counter mid-sequence.

```asm
StageSprAndHitbox {
    TYX
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&ProcessAnimFlag
    JSL $@sprite_composition.UpdateActorAnimation
    STZ $2A               ; staging snapshot, not a full AnimOnce run
    ; … script PC / RTI
}
```

Unlike `$80`, this **does not** replace `$89` for a full multi-frame cycle — it applies one update for collision/OAM sync (e.g. hurtbox resize on attack frames).

##### How it is used

Great Wall archer: pose + move + wait on frame 2 (`extracted/great_wall/gw82_archer.asm`):

```asm
COP [StageSprAndHitbox] ( #8A )
COP [StageMoveX] ( #04 )
COP [WaitForAnimFrame] ( #02 )
```

Space flight controller pose steps (`extracted/babel_tower/space_flight/sE7_space_flight_controller.asm`):

```asm
COP [StageSprAndHitbox] ( #00 )
...
COP [StageSprAndHitbox] ( #03 )
```

Blaster enemy form change (`extracted/pyramid/pyCC_blaster.asm`):

```asm
COP [StageSprAndHitbox] ( #1A )
...
COP [StageSprAndHitbox] ( #9A )
```

##### Parameters & contract

| Item | Detail |
|------|--------|
| Side effect | Hitbox and sprite composition updated **immediately** |
| `$2A` | Forced to 0 after update |
| Follow-up | Often `$89`, `$8C`, or movement ops — not redundant with `$80` |

##### Relations

- **`$80`:** Stage only; hitbox updates when animation runs via `$89`/`$8A`.
- **`$8C`:** Waits until `$2A` matches a frame **during** a running anim; `$8D` sets pose/hitbox in one shot.
