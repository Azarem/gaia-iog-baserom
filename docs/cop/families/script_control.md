# COP family: Script control

_Ops: `[C0]`–`[CB]`, `[E1]`, `[E2]`_ · _Source: [`cop_handlers_flow.asm`](../../../extracted/system/engine/cop_handlers_flow.asm)_

[← COP index](../index.md)

## Overview

Actor-script “VM” primitives: program counter (`$0A` script cursor, `$0C` bank), resume entry (`$00`/`$02`), frame timer (`$08`), interact pointer (`chatPtr` / `$7F000A`), near-call return slot (`retPtr1` / `$7F0004`), and counted-loop state (`loopCounter`/`retPtr2` for player-range actors, `loopCounterActor`/`loopStartPcActor` for scene actors). These fourteen opcodes implement interact registration, entry/resume manipulation, timed and next-frame jumps, near calls with optional deferral, loop headers, and signal returns.

## Shared state

| Symbol | Address | Role |
|--------|---------|------|
| EntryPtr | `$00` / `$02` | Resume PC + bank (engine reloads each tick from here after `RTL`) |
| Script PC | `$0A` / `$0C` | Current COP operand cursor + script bank during handler |
| Frame timer | `$08` | Countdown; actor skips script while nonzero |
| `retPtr1` | `$7F0004,X` | Saved return PC for `CallNear*` / `RestoreSavedPtr` / `ReturnWithSignal` |
| `chatPtr` | `$7F000A,X` | Interact script entry (`SetInteractHandler`) |
| `loopCounter` | `$7F0014,X` | Player actor loop count (`X ≥ $1000`) |
| `retPtr2` | `$7F001E,X` | Player loop-head PC |
| `loopStartPcActor` | `$7F2100,X` | Scene-actor loop-head PC |
| `loopCounterActor` | `$7F2102,X` | Scene-actor loop count |

## Family notes

- **`SetEntryHere` + `RTL`** is the standard idle loop: engine re-enters at the saved `$00`/`$02` every frame.
- **`CallNear` / `CallNearDeferred`** store exactly **one** return address in `retPtr1`; nested calls overwrite the outer return.
- **`LoopStart` / `LoopEnd`** pick player vs scene storage by comparing actor index `X` to `$1000` (player slot range vs scene pool).
- **`ReturnWithSignal`** is **`RestoreSavedPtr`** plus **`A = $FFFF`** on the RTI path so callers can use **`ASL`** (carry set) to detect “subroutine finished with signal” vs a plain return.
- **`SetEntryFar`** lives in opcode slot `[E2]` (between `Die` and invalid `[E3]`) but is script control, not death handling.
- Extracted ASM uses **preferred `copdef.json` names**; legacy names appear in comments (e.g. `SetEntryContinue` → `SetEntryHere`).

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `C0` | `SetInteractHandler` | 486 | `&Code` | `SetInteractHandler` | Continue |
| `C1` | `SetEntryHere` | 1295 | — | `SetEntryHere` | Continue |
| `C2` | `SetEntryHereAndYield` | 502 | — | `SetEntryHereAndYield` | Halt |
| `C3` | `JumpAfterDelay` | 12 | `@Code`, `Word` | `JumpAfterDelay` | Halt |
| `C4` | `JumpNextFrame` | 61 | `@Code` | `JumpNextFrame` | Halt |
| `C5` | `RestoreSavedPtr` | 309 | — | `RestoreSavedPtr` | Halt / RTI |
| `C6` | `SetSavedPtr` | 53 | `&Code` | `SetSavedPtr` | Continue |
| `C7` | `JumpFar` | 22 | `@Code` | `JumpFar` | Continue |
| `C8` | `CallNear` | 230 | `&Code` | `CallNear` | Continue |
| `C9` | `CallNearDeferred` | 8 | `&Code` | `CallNearDeferred` | Halt |
| `CA` | `LoopStart` | 277 | `Byte` | `LoopStart` | Continue |
| `CB` | `LoopEnd` | 284 | — | `LoopEnd` | Branch / Continue |
| `E1` | `ReturnWithSignal` | 4 | — | `ReturnWithSignal` | Halt / RTI |
| `E2` | `SetEntryFar` | 1 | `@Code` | `SetEntryFar` | Continue |

**Preferred names** are from `db-us/copdef.json`. **Legacy aliases:** `SetOnInteract`, `SetEntryContinue`, `SetEntryExit`, `SetEntryDelayExit`, `SetEntryExitNow`, `JumpScript`, `CallScript`, `CallScriptDeferred`, `LoopInit`, `LoopNext`, `RestoreSavedPtrFFFF`, `SetEntryContinueDeferred`.

**Family call-site total:** 3544

---

## Opcodes

#### COP [C0] — `SetInteractHandler` (register talk / touch handler)

- **Confidence:** high (handler + call-site audit)
- **Preferred name:** `SetInteractHandler`
- **Aliases:** `SetOnInteract`
- **Handler:** `SetInteractHandler` @ [`cop_handlers_flow.asm:31-40`](../../../extracted/system/engine/cop_handlers_flow.asm)
- **Parameters:** `&Code` — same-bank interact script entry (`db-us/copdef.json`: `["&Code"]`)
- **Usage count:** 486

##### What it does

1. **`TYX`** — actor slot in `X`.
2. **`LDA [$0A]`** — read 16-bit interact target; advance `$0A` by 2.
3. **`STA $chatPtr,X`** — store in `$7F000A` (interaction system jumps here on player contact).
4. **`LDA $0A` / `STA $02,S` / `RTI`** — resume script after the operand.

##### Handler excerpt

```asm
SetInteractHandler {
    TYX
    LDA [$0A]
    INC $0A
    INC $0A
    STA $chatPtr, X
    LDA $0A
    STA $02, S
    RTI
}
```

##### How it is used

Nearly every NPC, chest, and inspectable registers an interact script, then parks with `SetEntryHere` + `RTL`:

```asm
; extracted/actors/debug_man.asm
COP [SetInteractHandler] ( &DebugManInteract )
COP [SetEntryHere]
RTL
```

Legacy name `SetOnInteract` does not appear in extracted COP lines; only the modern name is emitted.

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand | 2-byte `&Code` |
| WRAM | `$7F000A,X` ← interact entry |
| Callee | Invoked by engine interact dispatch, not by this COP |
| Typical pairing | `SetEntryHere` + `RTL` idle after registration |

##### Relation to similar ops

| Op | Difference |
|----|------------|
| `[C1]` | Saves **current** PC as entry, does not set interact pointer |
| `[C8]` | Calls a subroutine once; does not register persistent interact |

---

#### COP [C1] — `SetEntryHere` (save resume point, continue)

- **Preferred name:** `SetEntryHere`
- **Aliases:** `SetEntryContinue`
- **Handler:** `SetEntryHere` @ [`cop_handlers_flow.asm:45-53`](../../../extracted/system/engine/cop_handlers_flow.asm)
- **Parameters:** (none)
- **Usage count:** 1295

##### What it does

1. Copy **`$0C` → `$02`** and **`$0A` → `$00`** — entry bank + PC = byte **after** this COP.
2. Patch COP stack **`$02,S`** and **`RTI`** — same tick continues at next script byte.

Does **not** yield; use with **`RTL`** on a later line so the engine re-enters at this label each frame.

##### Handler excerpt

```asm
SetEntryHere {
    TYX
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI
}
```

##### How it is used

**Idle loop** (Dark Gaia boss, epilogue, diary, space flight):

```asm
; extracted/ending/ending_comet/sE5_epilogue.asm
COP [SetEntryHere]
RTL
```

Comments and docs often say `SetEntryContinue`; extracted COP text is `SetEntryHere`.

##### Parameters & contract

| Item | Value |
|------|-------|
| Sets | `$00`, `$02` (entry pointer) |
| Does not | Clear `$08`, change `retPtr1`, or yield |

##### Relation to similar ops

| Op | Difference |
|----|------------|
| `[C2]` | Same entry save, then **`RTL`** immediately |
| `[E2]` | Sets **far** `@Code` entry without yielding |
| `[C4]` | Sets entry to **explicit** `@Code` and yields |

---

#### COP [C2] — `SetEntryHereAndYield` (save entry, yield now)

- **Preferred name:** `SetEntryHereAndYield`
- **Aliases:** `SetEntryExit`
- **Handler:** `SetEntryHereAndYield` @ [`cop_handlers_flow.asm:58-67`](../../../extracted/system/engine/cop_handlers_flow.asm)
- **Parameters:** (none)
- **Usage count:** 502

##### What it does

Same **`$0C`/`$0A` → `$02`/`$00`** write as `[C1]`, then **`PLA PLA RTL`** — end this actor tick; next frame resumes at saved entry.

##### Handler excerpt

```asm
SetEntryHereAndYield {
    TYX
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    PLA
    PLA
    RTL
}
```

##### How it is used

One-frame deferral without a numeric wait (cutscenes, boss phases, menu loops):

```asm
; extracted/babel_tower/comet_lair/sE8_dark_gaia.asm
COP [SetEntryHereAndYield]
```

Diary slot UI combines **`SetEntryHereAndYield`** with **`SetEntryFar`** to re-arm a far loop head after camera pan:

```asm
; extracted/system/diary_menu/sFA_diary_menu.asm
DiaryStartSlotLoop:
    COP [SetEntryHereAndYield]
    ...
    COP [SetEntryFar] ( @DiaryStartSlotLoop )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Outcome | Halt (yield) |
| Entry | Post-COP PC |

##### Relation to similar ops

| Op | Difference |
|----|------------|
| `[DA]` | Yields for **N frames** via `$08`, not “next frame only” |
| `[C1]` | Saves entry but **continues same tick** |

---

#### COP [C3] — `JumpAfterDelay` (far jump after timer)

- **Preferred name:** `JumpAfterDelay`
- **Aliases:** `SetEntryDelayExit`
- **Handler:** `JumpAfterDelay` @ [`cop_handlers_flow.asm:72-89`](../../../extracted/system/engine/cop_handlers_flow.asm)
- **Parameters:** `@Code`, `Word` delay frames
- **Usage count:** 12

##### What it does

1. Read **`@Code`** (word + bank) → **`$00`/`$02`**.
2. Read **`Word`** delay → **`$08`**.
3. **`RTL`** — actor sleeps until `$08` hits 0, then runs at target entry.

##### Handler excerpt

```asm
JumpAfterDelay {
    TYX
    LDA [$0A]
    INC $0A
    INC $0A
    STA $00
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $02
    LDA [$0A]
    INC $0A
    INC $0A
    STA $08
    PLA
    PLA
    RTL
}
```

##### How it is used

Timed cutscene beats and long cell/prison waits:

```asm
; extracted/edward_castle/castle_prison/ec0B_cell.asm
COP [JumpAfterDelay] ( @code_04D251, #$04B0 )

; extracted/gold_ship/adrift/dc2F_adrift.asm
COP [JumpAfterDelay] ( @code_059C04, #$04B0 )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| `@Code` | 3-byte far pointer |
| Delay | 16-bit frame count in `$08` |
| Outcome | Halt until timer expires at **new** entry |

##### Relation to similar ops

| Op | Difference |
|----|------------|
| `[C4]` | Jump next frame, **`STZ $08`** |
| `[DA]`/`[DB]` | Resume **after** wait at **post-COP** PC, not arbitrary `@Code` |

---

#### COP [C4] — `JumpNextFrame` (deferred state switch)

- **Preferred name:** `JumpNextFrame`
- **Aliases:** `SetEntryExitNow`
- **Handler:** `JumpNextFrame` @ [`cop_handlers_flow.asm:94-108`](../../../extracted/system/engine/cop_handlers_flow.asm)
- **Parameters:** `@Code`
- **Usage count:** 61

##### What it does

Load far target into **`$00`/`$02`**, **`STZ $08`**, **`RTL`** — resume at target **next frame** (no extra delay).

##### Handler excerpt

```asm
JumpNextFrame {
    TYX
    LDA [$0A]
    INC $0A
    INC $0A
    STA $00
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $02
    STZ $08
    PLA
    PLA
    RTL
}
```

##### How it is used

AI phase changes (archers, vampires, slipper chase):

```asm
; extracted/great_wall/gw82_archer.asm
COP [JumpNextFrame] ( @code_0B8F15 )

; extracted/mu/mu_vampire_lair/mu67_vampires.asm
COP [JumpNextFrame] ( @code_0AF5D7 )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Outcome | Halt (1-frame deferral) |
| Entry | Explicit `@Code`, not current PC |

##### Relation to similar ops

| Op | Difference |
|----|------------|
| `[C7]` | **`RTI`** jumps **same tick** to far target |
| `[C9]` | Deferred **near** call with `retPtr1` save |

---

#### COP [C5] — `RestoreSavedPtr` (return from near call)

- **Preferred name:** `RestoreSavedPtr`
- **Handler:** `RestoreSavedPtr` @ [`cop_handlers_flow.asm:132-145`](../../../extracted/system/engine/cop_handlers_flow.asm)
- **Parameters:** (none); `halt` in copdef when slot empty
- **Usage count:** 309

##### What it does

1. If **`retPtr1,X ≠ 0`**: restore to **`$02,S`**, clear slot, **`RTI`** at caller return site.
2. If zero: **`PLA PLA RTL`** — no pending return (yield / end tick).

##### Handler excerpt

```asm
RestoreSavedPtr {
    TYX
    LDA $retPtr1, X
    BEQ loc_00AA71
    STA $02, S
    LDA #$0000
    STA $retPtr1, X
    RTI
  loc_00AA71:
    PLA
    PLA
    RTL
}
```

##### How it is used

Epilogue of **`CallNear`** / **`CallNearDeferred`** callees (diary render, cyclops movement, mystic ball):

```asm
; extracted/mu/mu5F_cyclops.asm (callee paths)
COP [RestoreSavedPtr]

; extracted/system/diary_menu/sFA_diary_menu.asm
COP [RestoreSavedPtr]
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Requires | Prior `CallNear*` or `SetSavedPtr` |
| Clears | `retPtr1` on success |
| **`A`** | Unchanged (contrast `[E1]`) |

##### Relation to similar ops

| Op | Difference |
|----|------------|
| `[E1]` | Same restore + **`A = $FFFF`** |
| `[C6]` | **Writes** `retPtr1` without transferring control |

---

#### COP [C6] — `SetSavedPtr` (arm return address)

- **Preferred name:** `SetSavedPtr`
- **Handler:** `SetSavedPtr` @ [`cop_handlers_flow.asm:169-178`](../../../extracted/system/engine/cop_handlers_flow.asm)
- **Parameters:** `&Code`
- **Usage count:** 53

##### What it does

Store operand **`&Code`** in **`retPtr1,X`**; continue after operand. Does not jump.

##### Handler excerpt

```asm
SetSavedPtr {
    TYX
    LDA [$0A]
    INC $0A
    INC $0A
    STA $retPtr1, X
    LDA $0A
    STA $02, S
    RTI
}
```

##### How it is used

Pre-arm return before multi-path enemy logic (pyramid mystic ball, Angkor zombies):

```asm
; extracted/pyramid/pyCC_mystic_ball.asm
COP [SetSavedPtr] ( &code_0BC5C8 )
...
COP [RestoreSavedPtr]
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand | 2-byte return PC |
| Overwrites | Previous `retPtr1` (single level) |

##### Relation to similar ops

| Op | Difference |
|----|------------|
| `[C8]` | Saves **`$0A`** (dynamic return) and jumps to callee |
| `[C5]` | Consumes `retPtr1` |

---

#### COP [C7] — `JumpFar` (immediate cross-bank jump)

- **Preferred name:** `JumpFar`
- **Aliases:** `JumpScript`
- **Handler:** `JumpFar` @ [`cop_handlers_flow.asm:183-198`](../../../extracted/system/engine/cop_handlers_flow.asm)
- **Parameters:** `@Code`
- **Usage count:** 22

##### What it does

1. Target word → **`$00`** and **`$02,S`**.
2. Bank byte → **`$02`** and **`$04,S`** (8-bit stores).
3. **`RTI`** — same tick continues at far target (no return saved).

##### Handler excerpt

```asm
JumpFar {
    TYX
    LDA [$0A]
    INC $0A
    INC $0A
    STA $00
    STA $02, S
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    STA $02
    STA $04, S
    REP #$20
    RTI
}
```

##### How it is used

Shared defeat handlers and transition tables:

```asm
; extracted/pyramid/pyCC_mystic_ball.asm
COP [JumpFar] ( @StandardEnemyDefeatHandler )

; extracted/great_wall/sand_fanger_lair/gw8A_sand_fanger.asm
COP [JumpFar] ( @player_transition_handlers )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| No return | Unlike `CallNear` |
| Bank | Updates both entry and COP stack bank byte |

##### Relation to similar ops

| Op | Difference |
|----|------------|
| `[C4]` | Deferred jump; **`RTL`** |
| `[E2]` | Sets `$00`/`$02` but **falls through** same script path via `RTI` at post-operand PC |

---

#### COP [C8] — `CallNear` (same-bank gosub)

- **Preferred name:** `CallNear`
- **Aliases:** `CallScript`
- **Handler:** `CallNear` @ [`cop_handlers_flow.asm:203-212`](../../../extracted/system/engine/cop_handlers_flow.asm)
- **Parameters:** `&Code`
- **Usage count:** 230

##### What it does

1. Read target → **`$02,S`** (RTI destination).
2. **`$0A` → retPtr1** (return = next script byte after call).
3. **`RTI`** into callee.

##### Handler excerpt

```asm
CallNear {
    TYX
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    LDA $0A
    STA $retPtr1, X
    RTI
}
```

##### How it is used

```asm
; extracted/system/diary_menu/sFA_diary_menu.asm
COP [CallNear] ( &DiaryRenderSlotStats )
COP [CallNear] ( &DiaryCameraPan )

; extracted/mu/mu5F_cyclops.asm
COP [CallNear] ( &code_0AE0A7 )
```

Callee ends with **`RestoreSavedPtr`** or **`ReturnWithSignal`**.

##### Parameters & contract

| Item | Value |
|------|-------|
| Nesting | **Single** `retPtr1` — do not nest |
| Return | `RestoreSavedPtr` / `ReturnWithSignal` |

##### Relation to similar ops

| Op | Difference |
|----|------------|
| `[C9]` | Sets **`$00`** to target, yields; callee next **frame** |
| Robotrek `[00]` gosub | IOG uses **`retPtr1`** and **`$0A`** cursor, not `$7F001A` |

---

#### COP [C9] — `CallNearDeferred` (gosub next frame)

- **Preferred name:** `CallNearDeferred`
- **Aliases:** `CallScriptDeferred`
- **Handler:** `CallNearDeferred` @ [`cop_handlers_flow.asm:217-228`](../../../extracted/system/engine/cop_handlers_flow.asm)
- **Parameters:** `&Code`
- **Usage count:** 8

##### What it does

Target → **`$00`**, return PC → **`retPtr1`**, **`RTL`**. Callee runs after yield.

##### Handler excerpt

```asm
CallNearDeferred {
    TYX
    LDA [$0A]
    INC $0A
    INC $0A
    STA $00
    LDA $0A
    STA $retPtr1, X
    PLA
    PLA
    RTL
}
```

##### How it is used

Cyclops chase: deferred step routines polled each frame until **`ReturnWithSignal`**:

```asm
; extracted/mu/mu5F_cyclops.asm
COP [CallNearDeferred] ( &code_0ADF29 )
ASL
BCS code_0ADE6C
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Outcome | Halt then run callee |
| Signal return | Pair with **`ReturnWithSignal`** + **`ASL`** |

##### Relation to similar ops

| Op | Difference |
|----|------------|
| `[C8]` | Immediate **`RTI`** into callee |
| `[C4]` | No `retPtr1`; far `@Code` |

---

#### COP [CA] — `LoopStart` (counted loop header)

- **Preferred name:** `LoopStart`
- **Aliases:** `LoopInit`
- **Handler:** `LoopStart` @ [`cop_handlers_flow.asm:233-259`](../../../extracted/system/engine/cop_handlers_flow.asm)
- **Parameters:** `Byte` count
- **Usage count:** 277

##### What it does

- **`X ≥ $1000` (player):** count → **`loopCounter`**, loop head PC → **`retPtr2`**, also **`$00`**.
- **Scene actor:** count → **`loopCounterActor`**, head → **`loopStartPcActor`**, **`$00`**.

##### Handler excerpt

```asm
LoopStart {
    TYX
    CPX #$1000
    BCC loc_00AAF6
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $loopCounter, X
    LDA $0A
    STA $retPtr2, X
    STA $00
    LDA $0A
    STA $02, S
    RTI
  loc_00AAF6:
    ; ... loopCounterActor / loopStartPcActor ...
}
```

##### How it is used

```asm
; extracted/babel_tower/comet_lair/sE8_dark_gaia.asm
COP [LoopStart] ( #10 )
    ...
COP [LoopEnd]
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Count | 8-bit iterations |
| Head | PC after **`LoopStart`** operand |

##### Relation to similar ops

| Op | Difference |
|----|------------|
| `[CB]` | Decrements count; branch back or exit |
| Robotrek `[05]`–`[07]` | Different WRAM (`$7F0024` / `$7F0026`) |

---

#### COP [CB] — `LoopEnd` (decrement / back-edge)

- **Preferred name:** `LoopEnd`
- **Aliases:** `LoopNext`
- **Handler:** `LoopEnd` @ [`cop_handlers_flow.asm:264-293`](../../../extracted/system/engine/cop_handlers_flow.asm)
- **Parameters:** (none)
- **Usage count:** 284

##### What it does

Decrement active counter; if **nonzero**, restore loop head to **`$00`** and **`RTL`**; if **zero**, **`RTI`** past **`LoopEnd`**.

##### Handler excerpt

```asm
LoopEnd {
    TYX
    CPX #$1000
    BCC loc_00AB2D
    LDA $loopCounter, X
    DEC
    BEQ loc_00AB28
    STA $loopCounter, X
    LDA $retPtr2, X
    STA $00
    PLA
    PLA
    RTL
  loc_00AB28:
    LDA $0A
    STA $02, S
    RTI
  loc_00AB2D:
    ; scene-actor variant ...
}
```

##### How it is used

Paired with **`LoopStart`** in boss scripts, epilogue FX, dark gaia sequences (see **`sE8_dark_gaia.asm`**).

##### Parameters & contract

| Item | Value |
|------|-------|
| Outcome | Branch (loop) or Continue (exit) |
| Requires | Matching **`LoopStart`** on same actor |

##### Relation to similar ops

| Op | Difference |
|----|------------|
| `[CA]` | Initializes counter and head |
| `[C1]`/`RTL` | Infinite idle, not counted |

---

#### COP [E1] — `ReturnWithSignal` (return + `A = $FFFF`)

- **Preferred name:** `ReturnWithSignal`
- **Aliases:** `RestoreSavedPtrFFFF`
- **Handler:** `ReturnWithSignal` @ [`cop_handlers_flow.asm:150-164`](../../../extracted/system/engine/cop_handlers_flow.asm)
- **Parameters:** (none)
- **Usage count:** 4

##### What it does

Same as **`RestoreSavedPtr`**, but successful path loads **`A = $FFFF`** before **`RTI`**. Callers test **`ASL`** / carry to see “signal return” vs plain **`RestoreSavedPtr`** path.

##### Handler excerpt

```asm
ReturnWithSignal {
    TYX
    LDA $retPtr1, X
    BEQ loc_00AA88
    STA $02, S
    LDA #$0000
    STA $retPtr1, X
    LDA #$FFFF
    RTI
  loc_00AA88:
    PLA
    PLA
    RTL
}
```

##### How it is used

```asm
; extracted/mu/mu5F_cyclops.asm
COP [ReturnWithSignal]
; caller:
ASL
BCS code_0ADE6C
```

##### Parameters & contract

| Item | Value |
|------|-------|
| **`A` on return** | `$FFFF` if restored |
| Empty `retPtr1` | Yields like **`RestoreSavedPtr`** |

##### Relation to similar ops

| Op | Difference |
|----|------------|
| `[C5]` | Restore without **`A`** signal |

---

#### COP [E2] — `SetEntryFar` (arm far entry, continue)

- **Preferred name:** `SetEntryFar`
- **Aliases:** `SetEntryContinueDeferred`
- **Handler:** `SetEntryFar` @ [`cop_handlers_flow.asm:113-127`](../../../extracted/system/engine/cop_handlers_flow.asm)
- **Parameters:** `@Code`
- **Usage count:** 1

##### What it does

Write **`@Code`** to **`$00`/`$02`**, **`STZ $08`**, then **`RTI`** at post-operand PC — **same tick** continues after the COP while entry now points at far label (used before **`RTL`** to re-enter a loop head).

##### Handler excerpt

```asm
SetEntryFar {
    TYX
    LDA [$0A]
    INC $0A
    INC $0A
    STA $00
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $02
    STZ $08
    LDA $0A
    STA $02, S
    RTI
}
```

##### How it is used

```asm
; extracted/system/diary_menu/sFA_diary_menu.asm
COP [SetEntryFar] ( @DiaryStartSlotLoop )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Outcome | Continue (no yield by itself) |
| Typical use | Re-arm **`@`** loop label before branch/input **`RTL`** |

##### Relation to similar ops

| Op | Difference |
|----|------------|
| `[C1]` | Entry = **current** PC, not operand |
| `[C4]` | Sets entry **and yields** to that code next frame |
