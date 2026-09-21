# COP family: Dungeon / switch

_Ops: `[D8]`, `[D9]`_ · _Source: [`cop_handlers_dungeon_switch.asm`](../../../extracted/system/engine/cop_handlers_dungeon_switch.asm)_

[← COP index](../README.md)

## Overview

Two flow handlers with different jobs: **`SetDungeonKillFlag`** persists per-dungeon enemy defeat bits in WRAM, and **`SwitchCase`** performs byte-indexed jump-table dispatch (random AI, dialog variants, menu routing). Both live in [`cop_handlers_dungeon_switch.asm`](../../../extracted/system/engine/cop_handlers_dungeon_switch.asm) alongside flag and wait opcodes.

## Shared state

| Symbol | Address | Role |
|--------|---------|------|
| `enemyNum` | `$7F0022,X` | Dungeon monster / WRAM flag index for this actor |
| `wramFlags` | `$0A80` | WRAM bitfield (`SetWramFlag` target) |
| Case index | `$0000` (example) | Byte variable in bank-0 WRAM read by `SwitchCase` |

## Family notes

- **`SetDungeonKillFlag`** no-ops when `enemyNum` is zero (non-dungeon actors).
- **`SwitchCase`** is marked **`halt: true`** in `copdef.json` because it always **`RTI`**s into a table entry (never falls through).
- Table base uses **`&&Code`** — list of `&Code` labels in the script bank; index is **`byte_at_addr × 2`** added to table base.
- Enemy death pipelines often call **`SetDungeonKillFlag`** from `StandardEnemyDefeatHandler` / `EnemyDefeatDispatch`, not only from manual script lines.

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `D8` | `SetDungeonKillFlag` | 4 | — | `SetDungeonKillFlag` | Continue |
| `D9` | `SwitchCase` | 109 | `Word`, `&&Code` | `SwitchCase` | Halt (dispatch) |

**Family call-site total:** 113

---

## Opcodes

#### COP [D8] — `SetDungeonKillFlag` (record dungeon kill)

- **Confidence:** high
- **Preferred name:** `SetDungeonKillFlag`
- **Handler:** `SetDungeonKillFlag` @ [`cop_handlers_dungeon_switch.asm:555-566`](../../../extracted/system/engine/cop_handlers_dungeon_switch.asm)
- **Parameters:** none (`db-us/copdef.json`: `[]`)
- **Usage count:** 4

##### What it does

1. Load **`enemyNum,X`** (byte at `$7F0022`).
2. If zero, skip flag write.
3. Else **`JSR SetWramFlag`** — sets bit **`enemyNum`** in **`wramFlags` (`$0A80`)** so `actor_execution` can skip respawn on re-entry.
4. **`RTI`** to next opcode.

Pairs with **`TestWramFlag`** / scene load logic in `CheckEnemyDefeatedFlag`.

##### Handler excerpt

```asm
SetDungeonKillFlag {
    TYX
    LDA $enemyNum, X
    AND #$00FF
    BEQ loc_00AC8F
    JSR $&flag_helpers.SetWramFlag
  loc_00AC8F:
    LDA $0A
    STA $02, S
    RTI
}
```

##### How it is used

**Explicit script call** — rare; most kills set the flag inside defeat handlers:

```asm
; extracted/functions/EnemyDefeatDispatch.asm
COP [SetDungeonKillFlag]
```

**Boss / special rooms** — e.g. pyramid mystic ball, Angkor wall walker scripts call it at death end before `Die`.

##### Parameters & contract

| Item | Value |
|------|-------|
| Operands | none |
| Preconditions | `enemyNum,X` set at actor init for dungeon enemies |
| WRAM | `$0A80` bit indexed by `enemyNum` |
| Outcome | **Continue** |

---

#### COP [D9] — `SwitchCase` (WRAM byte → jump table)

- **Confidence:** high
- **Preferred name:** `SwitchCase`
- **Handler:** `SwitchCase` @ [`cop_handlers_dungeon_switch.asm:571-597`](../../../extracted/system/engine/cop_handlers_dungeon_switch.asm)
- **Parameters:** `Word IndexAddr`, `&&Code JmpList`
- **Usage count:** 109

##### What it does

1. Read **`IndexAddr`** (16-bit absolute WRAM address in bank 0).
2. Load **`(byte at IndexAddr)`**, zero-extend, **`ASL`** (×2 for word table).
3. Read jump table base from script stream; **`ADC`** scaled index.
4. Fetch target address from table; switch DBR to script bank; **`RTI`** into selected **`&Code`**.

Script execution **transfers** to the case handler; there is no fallthrough return to the `SwitchCase` site unless the target returns via control-flow ops.

##### Handler excerpt

```asm
SwitchCase {
    LDA [$0A]             ; WRAM address of index byte
    INC $0A
    INC $0A
    TAX
    LDA $0000, X
    AND #$00FF
    ASL
    STA $0000
    ...
    LDA [$0A]             ; &&Code table base
    CLC
    ADC $0000
    TAX
    LDA $0000, X          ; selected &Code
    STA $02, S
    RTI
}
```

##### How it is used

**Random AI phase pick** — viper stores a 0–3 counter in `$0000`, then dispatches movement loops:

```asm
; extracted/sky_garden/viper_lair/sg55_viper.asm
LDA $002A, Y
DEC
AND #$0003
STA $0000
COP [SwitchCase] ( #$0000, &code_list_0AD467 )

code_list_0AD467 [
  &code_0AD46F
  &code_0AD480
  &code_0AD491
  &code_0AD4A2
]
```

**NPC / menu routing** — diary, shop queues, wander AI, and `item_use_system` (`FluteMusicActorController` melody dispatch) use the same opcode with different WRAM index bytes.

**Typical setup:**

```asm
STA $0000               ; or STZ — index 0
COP [SwitchCase] ( #$0000, &choices )
choices [
  &path_a
  &path_b
]
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand 1 | 2-byte WRAM address (index byte) |
| Operand 2 | `&&Code` — aligned list of 2-byte `&Code` pointers |
| Index range | 0 … (table_entries−1); out-of-range reads garbage targets |
| Outcome | **Halt** ( **`RTI`** into case; engine treats as dispatch) |
