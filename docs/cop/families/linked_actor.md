# COP family: Linked actor

_Ops: `[6A]`_ · _Source: `extracted/system/engine/cop_handlers_lifecycle.asm`_

[← COP index](../index.md)

## Overview

Single-op family that retargets the **next actor in the doubly-linked list** (`$06` chain pointer). Credits parade controllers use it to swap animation scripts on a linked child (Will’s body actor, NPC marchers) without respawning. The handler writes the far entry pointer and clears movement staging on the **linked** actor only.

## Shared state

| Symbol | Address | Role |
|--------|---------|------|
| `$06` | actor field | Next actor index in list (linked child) |
| `$0000,Y` | linked actor | Entry PC (resume point) |
| `$0008,Y` / `$002C,Y` / `$002E,Y` | linked actor | Cleared (wait / move scratch) |

## Family notes

- Does **not** change the **caller’s** entry pointer — only **`$0000` of `$06`**.
- **`&Code`** operand is a same-bank script label (2 bytes); bank comes from script DBR on **`RTI`** into linked actor.
- Dominant use: **`HaltIfMaxFrames`** timeline on controller → **`SetLinkedEntryPtr`** → repeat (credits bank `$09`).
- Legacy script name **`SetLinkedActorScript`** appears in comments and JP extract; US rebuild emits **`SetLinkedEntryPtr`**.

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `6A` | `SetLinkedEntryPtr` | 164 | `&Code` | `SetLinkedEntryPtr` | Continue |

**Legacy alias:** `SetLinkedActorScript` → `SetLinkedEntryPtr`.

**Family call-site total:** 164

---

## Opcodes

#### COP [6A] — `SetLinkedEntryPtr` (set linked actor entry)

- **Confidence:** high (handler + credits audit)
- **Preferred name:** `SetLinkedEntryPtr`
- **Aliases:** `SetLinkedActorScript`
- **Handler:** `SetLinkedEntryPtr` @ `extracted/system/engine/cop_handlers_lifecycle.asm:344-358`
- **Parameters:** `&Code` (`db-us/copdef.json`: `["&Code"]`)
- **Usage count:** 164

##### What it does

1. Read 16-bit **`&Code`** from script; advance `$0A`.
2. **`LDY $06`** — resolve linked (next) actor index.
3. **`STA $0000,Y`** — new entry / script PC for that actor.
4. Zero **`$0008,Y`**, **`$002C,Y`**, **`$002E,Y`** — drop pending wait and move staging on the child.
5. **`RTI`** — caller continues; linked actor picks up new entry on its next tick.

##### Handler excerpt

```asm
SetLinkedEntryPtr {
    TYX
    LDA [$0A]
    INC $0A
    INC $0A
    LDY $06
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002C, Y
    STA $002E, Y
    LDA $0A
    STA $02, S
    RTI
}
```

##### How it is used

**Credits timeline driver** — player parade controller `e_actor_09DDA7` waits until frame threshold, then points Will’s linked sprite actor at the next animation block:

```asm
; extracted/ending/ending_credits/sF7_credits_player.asm
loc_09DDAD:
    COP [HaltIfMaxFrames] ( #$012C )
    COP [SetLinkedEntryPtr] ( &code_09E013 )
    COP [HaltIfMaxFrames] ( #$01CC )
    COP [SetLinkedEntryPtr] ( &code_09E02E )
    COP [HaltIfMaxFrames] ( #$0CA8 )
    COP [SetLinkedEntryPtr] ( &code_09E05F )
    ...
```

**NPC credits rows** — `sF7_credits_npc_a` … `sF7_credits_npc_e` and `sF7_credits_misc_timeline` use the same **`HaltIfMaxFrames` / `SetLinkedEntryPtr`** pairs to choreograph dozens of marchers off one lightweight director actor.

**Setup requirement:** spawn path must leave a valid **`$06`** link (e.g. **`SpawnBefore`** child) so the opcode has a target actor.

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand | 2-byte `&Code` (same bank as caller script) |
| Target actor | **`$06`** next pointer only (not `$04` prev) |
| Side effects | Clears child `$08`, `$2C`, `$2E` |
| Outcome | **Continue** on caller |
| Typical pairing | **`HaltIfMaxFrames`**, **`SpawnBefore`** / list spawn |
