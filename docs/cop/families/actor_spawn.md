# COP family: Actor spawn

_Deep-audited ops: `[99]`–`[A6]`_

[← COP index](../index.md)

## Overview

Fourteen opcodes allocate a new actor WRAM slot, copy state from the spawner, and set the child’s script entry (`$0000`/`$0002`). Variants choose **list placement** (before/after the caller vs tail append), **position** (inherit, relative word/byte offset, or absolute pixels), **initial status** (`$0010` / `New10`), **parent–child marking** (`MarkChildActor`, spawner `$12` bit `$0040`), and optional **animation index** (`$0028` on list-append-with-sprite).

On success, **`Y` = new actor direct-page ID** (same convention as `AllocateActorBefore` / `AllocateActorAfter`). All handlers exit with **`RTI`** (script continues after operands).

## Shared state

| Symbol / address | Role |
|------------------|------|
| `AllocateActorBefore` | Insert new slot **before** caller in the doubly-linked list; higher execution priority |
| `AllocateActorAfter` | Insert **after** caller; lower priority |
| `CopyActorState` | Clone spawner pose, sprites, stats, `$10`/`$12` (masked), zero callbacks |
| `MarkChildActor` | Write spawner (or inherited) ID to child `$7F001C` (`parentId`) |
| `$0056` / `$0058` | Actor list head / tail (tail updated by list-append ops) |
| `$0010` | Status flags; `New10` operand sets initial value on the child |
| `$0012` bit `$0040` | Spawner “has marked children”; enables cascade death in `$A7`/`$E0` |
| `$0028` | Animation / sprite frame index (`SpawnListAppendSpr` only) |

## Family notes

- **Before** (`$99`–`$9A`, `$A1`) runs **earlier** in the per-frame actor chain than the spawner.
- **After** (`$9B`–`$A4`) runs **later** than the spawner.
- **Marked** (`$A1`–`$A4`) call `MarkChildActor` and set `$0040` on the **spawner** so grouped teardown is possible.
- **List append** (`$A5`–`$A6`) splices at **`$0058` (tail)**, not relative to the spawner; does **not** mark parent–child. On pool exhaustion (**carry set** from `ActorPoolAllocator`), operands are consumed and **no actor** is created.
- **`$A6` / `SpawnListAppendSpr`:** `db-us/copdef.json` part order does not match ROM; handler reads `@Code` (word + bank), **animation byte → `$0028`**, signed byte offsets, then `New10` word.
- Common `New10` values: `#$1800` (scene prop + interact), `#$2000` (hidden helper / thinker-style), `#$2800` (hidden + active during dialogue), `#$0301` (combat adjunct).

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `99` | `SpawnBefore` | 18 | `@Code Entry` | `SpawnBefore` | Continue |
| `9A` | `SpawnBeforeFlags` | 19 | `@Code Entry`, `Word New10` | `SpawnBeforeFlags` | Continue |
| `9B` | `SpawnAfter` | 23 | `@Code Entry` | `SpawnAfter` | Continue |
| `9C` | `SpawnAfterFlags` | 231 | `@Code Entry`, `Word New10` | `SpawnAfterFlags` | Continue |
| `9D` | `SpawnAfterOffset` | 0 | `@Code Entry`, `Word OffsX`, `Word OffsY` | `SpawnAfterOffset` | Continue |
| `9E` | `SpawnAfterOffsetFlags` | 126 | `@Code Entry`, `Word OffsX`, `Word OffsY`, `Word New10` | `SpawnAfterOffsetFlags` | Continue |
| `9F` | `SpawnAfterAbs` | 0 | `@Code Entry`, `Word AbsX`, `Word AbsY` | `SpawnAfterAbs` | Continue |
| `A0` | `SpawnAfterAbsFlags` | 106 | `@Code Entry`, `Word AbsX`, `Word AbsY`, `Word New10` | `SpawnAfterAbsFlags` | Continue |
| `A1` | `SpawnBeforeMarked` | 19 | `@Code Entry`, `Word New10` | `SpawnBeforeMarked` | Continue |
| `A2` | `SpawnAfterMarked` | 101 | `@Code Entry`, `Word New10` | `SpawnAfterMarked` | Continue |
| `A3` | `SpawnAfterAbsMarked` | 21 | `@Code Entry`, `Word AbsX`, `Word AbsY`, `Word New10` | `SpawnAfterAbsMarked` | Continue |
| `A4` | `SpawnAfterOffsetMarked` | 77 | `@Code Entry`, `Byte OffsX`, `Byte OffsY`, `Word New10` | `SpawnAfterOffsetMarked` | Continue |
| `A5` | `SpawnListAppend` | 256 | `@Code Entry`, `Byte OffsX`, `Byte OffsY`, `Word New10` | `SpawnListAppend` | Continue |
| `A6` | `SpawnListAppendSpr` | 0 | `@Code Entry`, `Byte Spr`, `Byte OffsX`, `Byte OffsY`, `Word New10` | `SpawnListAppendSpr` | Continue |

**Family call-site total:** 997

**Legacy names (same opcodes):** `SpawnAfterRel` → `SpawnAfterOffset`; `SpawnAfterRelFlags` → `SpawnAfterOffsetFlags`; `SpawnMarkedBefore` → `SpawnBeforeMarked`; `SpawnMarkedAfter` → `SpawnAfterMarked`; `SpawnMarkedAfterAbs` → `SpawnAfterAbsMarked`; `SpawnMarkedAfterRel` → `SpawnAfterOffsetMarked`; `SpawnLastRel` → `SpawnListAppend`; `SpawnLastRelSpr` → `SpawnListAppendSpr`.

## Opcodes

#### COP [99] — `SpawnBefore` (allocate before caller, entry only)

- **Preferred name:** `SpawnBefore`
- **Aliases:** (none in legacy copdef)
- **Handler:** `SpawnBefore` @ `extracted/system/engine/cop_handlers_spawn.asm:18-32`
- **Parameters:** `@Code Entry` — far script entry (word + bank byte)
- **Usage count:** 18

##### What it does (exact semantics)

1. `TYX` — restore spawner actor ID in **X** (from COP dispatch).
2. `JSR AllocateActorBefore` — allocate slot **Y**, splice before **X**, `CopyActorState`.
3. Read `@Code` from `[$0A]` → child `$0000` / `$0002`.
4. Patch COP stack PC (`$02,S`) to `$0A`, **`RTI`**.

Child inherits spawner position and visuals; entry pointer is the only script-specific setup.

```asm
SpawnBefore {
    TYX
    JSR $&actor_pool.AllocateActorBefore
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0000, Y
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0002, Y
    LDA $0A
    STA $02, S
    RTI
}
```

##### How it is used in source

Credits and ending directors spawn **high-priority** helper actors that must run before the director each frame:

```asm
; extracted/ending/ending_credits/sF7_credits_npc_c.asm
COP [SpawnBefore] ( @e_actor_09E464 )
```

Player bootstrap spawns the attack system **before** the player body so attack logic runs first:

```asm
; extracted/actors/player/player_character.asm
COP [SpawnBefore] ( @attack_ability_system.AttackSystemEntry )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Opcode | `$99` (copdef id 153) |
| Asm form | `COP [SpawnBefore] ( @label )` |
| Operand size | 3 bytes (`@Code`) |
| Side effects | New list link; child `$0000/$0002`; **Y** = child ID |
| On pool full | `AllocateActorBefore` returns carry → handler still RTI (no child) |
| Pairs with | `$A8`/`$A9`/`$E0` for teardown; `$B0` targets `$0058` tail child |

---

#### COP [9A] — `SpawnBeforeFlags` (before + initial `$0010`)

- **Preferred name:** `SpawnBeforeFlags`
- **Handler:** `SpawnBeforeFlags` @ `cop_handlers_spawn.asm:37-55`
- **Parameters:** `@Code Entry`, `Word New10`
- **Usage count:** 19

##### What it does

Same as `[99]`, then stores the **`Word`** operand at child **`$0010`** (status flags).

```asm
SpawnBeforeFlags {
    TYX
    JSR $&actor_pool.AllocateActorBefore
    ; ... entry pointer ...
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA $0A
    STA $02, S
    RTI
}
```

##### How it is used in source

Prologue text actors use **`#$2800`** (hidden + dialogue-active) on before-spawned helpers:

```asm
; extracted/prologue/prologue_prophecy/pr8C_prologue5.asm
COP [SpawnBeforeFlags] ( @code_0BCEBD, #$2800 )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Opcode | `$9A` |
| Extra operand | 16-bit little-endian → child `$0010` |
| Outcome | Continue (`RTI`) |

---

#### COP [9B] — `SpawnAfter` (allocate after caller, entry only)

- **Preferred name:** `SpawnAfter`
- **Handler:** `SpawnAfter` @ `cop_handlers_spawn.asm:60-74`
- **Parameters:** `@Code Entry`
- **Usage count:** 23

##### What it does

`JSR AllocateActorAfter` inserts the child **after** the spawner in the linked list, then writes `@Code` to `$0000/$0002`.

```asm
SpawnAfter {
    TYX
    JSR $&actor_pool.AllocateActorAfter
    ; ... entry pointer ...
    LDA $0A
    STA $02, S
    RTI
}
```

##### How it is used in source

Player companions that should run **after** the player (movement, slopes):

```asm
; extracted/actors/player/player_character.asm
COP [SpawnAfter] ( @player_move_controller.PlayerMoveController )
COP [SpawnAfter] ( @slope_ramp_physics.SlopePhysicsEntry )
```

Boss / cutscene controllers spawn follow-up logic in the same chain:

```asm
; extracted/babel_tower/comet_lair/sE8_dark_gaia.asm
COP [SpawnAfter] ( @code_0CED37 )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Opcode | `$9B` |
| List position | Immediately after spawner (`$06` link) |
| Outcome | Continue |

---

#### COP [9C] — `SpawnAfterFlags` (after + `$0010`)

- **Preferred name:** `SpawnAfterFlags`
- **Handler:** `SpawnAfterFlags` @ `cop_handlers_spawn.asm:79-97`
- **Parameters:** `@Code Entry`, `Word New10`
- **Usage count:** 231

##### What it does

`SpawnAfter` plus **`STA $0010,Y`** from the trailing word operand. Dominant spawn opcode in the ROM (helpers, FX, one-shot scene actors).

```asm
SpawnAfterFlags {
    TYX
    JSR $&actor_pool.AllocateActorAfter
    ; ... entry + bank ...
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0010, Y
    LDA $0A
    STA $02, S
    RTI
}
```

##### How it is used in source

Game-over wakeup message, combat telegraphs, Dark Gaia phase spawns:

```asm
; extracted/actors/player/player_character.asm
COP [SpawnAfterFlags] ( @game_over_sequence.DeathWakeupMessage, #$2000 )

; extracted/babel_tower/comet_lair/sE8_dark_gaia.asm
COP [SpawnAfterFlags] ( @code_0CF2BB, #$0B00 )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Opcode | `$9C` |
| Typical flags | `#$2000` helper, `#$1800` interactable prop, `#$0B00` combat |
| Outcome | Continue |

---

#### COP [9D] — `SpawnAfterOffset` (after + signed word offset)

- **Preferred name:** `SpawnAfterOffset`
- **Aliases:** `SpawnAfterRel`
- **Handler:** `SpawnAfterOffset` @ `cop_handlers_spawn.asm:102-128`
- **Parameters:** `@Code Entry`, `Word OffsX`, `Word OffsY`
- **Usage count:** 0

##### What it does

After `AllocateActorAfter` and entry setup, adds **signed 16-bit** offset words to inherited `$0014` / `$0016` (pixel position copied by `CopyActorState`).

```asm
SpawnAfterOffset {
    ; ... entry ...
    LDA [$0A]
    INC $0A
    INC $0A
    CLC
    ADC $0014, Y
    STA $0014, Y
    LDA [$0A]
    INC $0A
    INC $0A
    CLC
    ADC $0016, Y
    STA $0016, Y
    LDA $0A
    STA $02, S
    RTI
}
```

##### How it is used in source

Shipped scripts usually prefer **`SpawnAfterOffsetFlags`** (same geometry + `New10`). For the no-flags form, treat **`SpawnAfterOffsetFlags`** call sites with only positional intent as the pattern reference — e.g. pyramid blaster spawns ±X/Y from parent:

```asm
; extracted/pyramid/pyCC_blaster.asm (flags variant; offsets identical to [9D] math)
COP [SpawnAfterOffsetFlags] ( @code_0BC7CE, #$FFF4, #$FFF0, #$0200 )
COP [SpawnAfterOffsetFlags] ( @code_0BC7CE, #$000C, #$FFF0, #$0200 )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Opcode | `$9D` |
| Offsets | Signed 16-bit add to inherited position |
| Outcome | Continue |

---

#### COP [9E] — `SpawnAfterOffsetFlags` (after + word offset + flags)

- **Preferred name:** `SpawnAfterOffsetFlags`
- **Aliases:** `SpawnAfterRelFlags`
- **Handler:** `SpawnAfterOffsetFlags` @ `cop_handlers_spawn.asm:133-163`
- **Parameters:** `@Code Entry`, `Word OffsX`, `Word OffsY`, `Word New10`
- **Usage count:** 126

##### What it does

`SpawnAfterOffset` plus **`STA $0010,Y`**. Used for projectiles, blaster bolts, and offset FX tied to the spawner’s facing/position.

```asm
SpawnAfterOffsetFlags {
    TYX
    JSR $&actor_pool.AllocateActorAfter
    ; ... entry, X/Y offset add, flags word ...
    STA $0010, Y
    LDA $0A
    STA $02, S
    RTI
}
```

##### How it is used in source

```asm
; extracted/pyramid/pyCC_mystic_ball.asm
COP [SpawnAfterOffsetFlags] ( @code_0BC70D, #$000A, #$FFF6, #$0300 )

; extracted/mountain_temple/mtA1_yorrick_ns.asm
COP [SpawnAfterOffsetFlags] ( @code_0B9DA9, #$FFFD, #$FFF8, #$0202 )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Opcode | `$9E` |
| Outcome | Continue |

---

#### COP [9F] — `SpawnAfterAbs` (after + absolute pixel position)

- **Preferred name:** `SpawnAfterAbs`
- **Handler:** `SpawnAfterAbs` @ `cop_handlers_spawn.asm:168-190`
- **Parameters:** `@Code Entry`, `Word AbsX`, `Word AbsY`
- **Usage count:** 0

##### What it does

After spawn + entry, **stores** operand words directly into child **`$0014` / `$0016`** (does not add to inherited position).

```asm
SpawnAfterAbs {
    ; ... entry ...
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0014, Y
    LDA [$0A]
    INC $0A
    INC $0A
    STA $0016, Y
    LDA $0A
    STA $02, S
    RTI
}
```

##### How it is used in source

Prefer **`SpawnAfterAbsFlags`** in extracted ASM (same coordinates + `New10`). Semantics match the absolute words in:

```asm
; extracted/prologue/prologue_prophecy/pr8C_prologue1.asm
COP [SpawnAfterAbsFlags] ( @code_0BCAB1, #$016E, #$03E8, #$1800 )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Opcode | `$9F` |
| Coordinates | Absolute pixel X/Y in scene space |
| Outcome | Continue |

---

#### COP [A0] — `SpawnAfterAbsFlags` (after + absolute position + flags)

- **Preferred name:** `SpawnAfterAbsFlags`
- **Handler:** `SpawnAfterAbsFlags` @ `cop_handlers_spawn.asm:195-221`
- **Parameters:** `@Code Entry`, `Word AbsX`, `Word AbsY`, `Word New10`
- **Usage count:** 106

##### What it does

Absolute placement plus initial **`$0010`**. Workhorse for cutscene props, title comet, prologue Mode 7 actors, crystal gates.

```asm
SpawnAfterAbsFlags {
    TYX
    JSR $&actor_pool.AllocateActorAfter
    ; ... entry, AbsX, AbsY, New10 ...
    LDA $0A
    STA $02, S
    RTI
}
```

##### How it is used in source

Staggered prophecy silhouettes and epilogue placements:

```asm
; extracted/prologue/prologue_prophecy/pr8C_prologue1.asm
COP [SpawnAfterAbsFlags] ( @code_0BCAB1, #$016E, #$03E8, #$1800 )
COP [DA] ( #02 )
COP [SpawnAfterAbsFlags] ( @code_0BCAB1, #$0166, #$041A, #$1800 )

; extracted/system/title_screen/sFC_title_intro.asm
COP [SpawnAfterAbsFlags] ( @TitleCometSpriteActor, #$0080, #$0050, #$1800 )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Opcode | `$A0` |
| Outcome | Continue |

---

#### COP [A1] — `SpawnBeforeMarked` (before + flags + parent link)

- **Preferred name:** `SpawnBeforeMarked`
- **Aliases:** `SpawnMarkedBefore`
- **Handler:** `SpawnBeforeMarked` @ `cop_handlers_spawn.asm:226-247`
- **Parameters:** `@Code Entry`, `Word New10`
- **Usage count:** 19

##### What it does

`SpawnBeforeFlags`, then **`TSB $12`** with **`#$0040`** on the spawner and **`JSR MarkChildActor`** so the child’s `$7F001C` parent link participates in cascade death.

```asm
SpawnBeforeMarked {
    ; ... SpawnBeforeFlags path ...
    LDA #$0040
    TSB $12
    JSR $&actor_pool.MarkChildActor
    LDA $0A
    STA $02, S
    RTI
}
```

##### How it is used in source

Angkor zombie boss waves spawn **before** the body so pieces run first, then get torn down with **`KillPrev`**:

```asm
; extracted/angkor_wat/awB0_zombie.asm
COP [SpawnBeforeMarked] ( @code_0BB73D, #$2002 )
COP [SpawnBeforeMarked] ( @code_0BB6BD, #$2202 )
; ... later ...
COP [KillPrev]
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Opcode | `$A1` |
| Spawner | `$12` bit `$0040` set (has marked children) |
| Child | `$7F001C` = parent link via `MarkChildActor` |
| Outcome | Continue |

---

#### COP [A2] — `SpawnAfterMarked` (after + flags + parent link)

- **Preferred name:** `SpawnAfterMarked`
- **Aliases:** `SpawnMarkedAfter`
- **Handler:** `SpawnAfterMarked` @ `cop_handlers_spawn.asm:252-273`
- **Parameters:** `@Code Entry`, `Word New10`
- **Usage count:** 101

##### What it does

Same marking sequence as `[A1]`, but **`AllocateActorAfter`**. Used for siblings that should run after the spawner but die as a group.

```asm
SpawnAfterMarked {
    TYX
    JSR $&actor_pool.AllocateActorAfter
    ; ... entry, New10 ...
    LDA #$0040
    TSB $12
    JSR $&actor_pool.MarkChildActor
    LDA $0A
    STA $02, S
    RTI
}
```

##### How it is used in source

Dark Gaia phase actors and smooth-follow siblings:

```asm
; extracted/babel_tower/comet_lair/sE8_dark_gaia.asm
COP [SpawnAfterMarked] ( @code_0CF4E3, #$0301 )
COP [SpawnAfterMarked] ( @smooth_follow.CopySiblingFollowState, #$2000 )

; extracted/edward_castle/castle_prison/ec0B_cell.asm
COP [SpawnAfterMarked] ( @interaction_handlers.collect_handler_gem, #$2300 )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Opcode | `$A2` |
| Teardown | `$A9` `KillNext`, `$E0`/`$A7` with cascade when `$0040` set |
| Outcome | Continue |

---

#### COP [A3] — `SpawnAfterAbsMarked` (absolute + flags + marked)

- **Preferred name:** `SpawnAfterAbsMarked`
- **Aliases:** `SpawnMarkedAfterAbs`
- **Handler:** `SpawnAfterAbsMarked` @ `cop_handlers_spawn.asm:278-307`
- **Parameters:** `@Code Entry`, `Word AbsX`, `Word AbsY`, `Word New10`
- **Usage count:** 21

##### What it does

`SpawnAfterAbsFlags` + **`$0040` / `MarkChildActor`**.

##### How it is used in source

Boss adds and static gate crystals at fixed tiles:

```asm
; extracted/incan_ruins/ir29_castoth.asm
COP [SpawnAfterAbsMarked] ( @code_0A9A68, #$0058, #$00A0, #$0200 )

; extracted/babel_tower/babel_upper_floors/btE3_crystal_gate.asm
COP [SpawnAfterAbsMarked] ( @bt_static_sprite, #$02AE, #$0384, #$1800 )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Opcode | `$A3` |
| Outcome | Continue |

---

#### COP [A4] — `SpawnAfterOffsetMarked` (byte offset + flags + marked)

- **Preferred name:** `SpawnAfterOffsetMarked`
- **Aliases:** `SpawnMarkedAfterRel`
- **Handler:** `SpawnAfterOffsetMarked` @ `cop_handlers_spawn.asm:312-355`
- **Parameters:** `@Code Entry`, `Byte OffsX`, `Byte OffsY`, `Word New10`
- **Usage count:** 77

##### What it does

Like `[9E]` but offsets are **8-bit signed** (sign-extended with `$80` test). Then flags + mark child.

```asm
SpawnAfterOffsetMarked {
    ; ... entry ...
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00A466
    ORA #$FF00
  loc_00A466:
    CLC
    ADC $0014, Y
    STA $0014, Y
    ; ... Y byte likewise ...
    LDA #$0040
    TSB $12
    JSR $&actor_pool.MarkChildActor
    RTI
}
```

##### How it is used in source

Tight pixel offsets for attached FX (Dark Gaia sub-pieces):

```asm
; extracted/babel_tower/comet_lair/sE8_dark_gaia.asm
COP [SpawnAfterOffsetMarked] ( @code_0CF549, #FC, #FC, #$0301 )
COP [SpawnAfterOffsetMarked] ( @code_0CF543, #04, #00, #$0301 )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Opcode | `$A4` |
| Offsets | Signed **byte** −128…127, sign-extended |
| Outcome | Continue |

---

#### COP [A5] — `SpawnListAppend` (tail append + byte offset)

- **Preferred name:** `SpawnListAppend`
- **Aliases:** `SpawnLastRel`
- **Handler:** `SpawnListAppend` @ `cop_handlers_spawn.asm:360-439`
- **Parameters:** `@Code Entry`, `Byte OffsX`, `Byte OffsY`, `Word New10`
- **Usage count:** 256

##### What it does

1. `ActorPoolAllocator` — if **carry**, skip operands and **`RTI`** (no spawn).
2. Link new actor at **`$0058`** tail (`$0006`/`$0004` patch).
3. `CopyActorState` from spawner **X**.
4. Entry pointer, **sign-extended byte** offsets added to `$0014`/`$0016`, **`New10` → `$0010`**.

Does **not** set parent marks; **`$0058`** updated so **`COP [B0]`** (`ApplyMoveToChild`) can target the latest append.

```asm
SpawnListAppend {
    PHY
    LDA #$0000
    TCD
    JSL $@actor_pool.ActorPoolAllocator
    BCS loc_00A50A
    ; ... tail splice, CopyActorState, entry, offsets, flags ...
    RTI
  loc_00A50A:
    ; discard operands, RTI
}
```

##### How it is used in source

Dominant pattern for **VFX, projectiles, palette FX, rewards** without changing spawner list order:

```asm
; extracted/actors/player/player_character.asm
COP [SpawnListAppend] ( @shadow_shimmer.ShadowShimmerInit, #00, #00, #$2800 )

; extracted/functions/StandardEnemyDefeatHandler.asm
COP [SpawnListAppend] ( @EnemyDeathFlash, #00, #00, #$0302 )
COP [SpawnListAppend] ( @DarkGemDropSystem.SpawnDarkGemType1, #00, #00, #$0420 )

; extracted/system/inventory/inventory_mgmt.asm
COP [SpawnListAppend] ( @SpawnHitSparkSprites, #00, #00, #$2F00 )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Opcode | `$A5` |
| List role | Global tail (`$0058`), not spawner-local `$04`/`$06` |
| Pool full | Operands skipped; script continues |
| Outcome | Continue |

---

#### COP [A6] — `SpawnListAppendSpr` (tail append + sprite index)

- **Preferred name:** `SpawnListAppendSpr`
- **Aliases:** `SpawnLastRelSpr`
- **Handler:** `SpawnListAppendSpr` @ `cop_handlers_spawn.asm:444-530`
- **Parameters:** `@Code Entry`, `Byte Spr`, `Byte OffsX`, `Byte OffsY`, `Word New10` (see handler — bank follows `@Code` word)
- **Usage count:** 0

##### What it does

Same tail-append path as `[A5]`, plus stores an operand byte into child **`$0028`** (animation / sprite index) **before** applying byte offsets. Pool-exhaustion path discards **one extra** operand byte.

```asm
SpawnListAppendSpr {
    ; ... allocator + tail splice + CopyActorState ...
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $0028, Y          ; animation index
    ; ... signed byte offsets, New10 ...
    RTI
}
```

##### How it is used in source

Usage audit reports **49** call sites (`SpawnLastRelSpr` legacy name). Extracted ASM may still label some instances as `[A5]` when only `CopyActorState`’s inherited `$28` was sufficient; when a **distinct** initial frame is required, authors use `[A6]`. Compare list-append projectiles that rely on explicit anim index in **`attack_ability_system.asm`** (companion **`SpawnListAppend`** with offset bytes `#FE`, `#1A` for Dark Friar).

Documented operand layout (authoritative = handler, not copdef):

`@Code` (word + bank) · `Byte Spr` → `$0028` · `Byte OffsX` · `Byte OffsY` · `Word New10`

##### Parameters & contract

| Item | Value |
|------|-------|
| Opcode | `$A6` |
| copdef.json | Part list/order **wrong** — trust handler ASM |
| Side effect | Child `$0028` set from operand |
| Outcome | Continue |
