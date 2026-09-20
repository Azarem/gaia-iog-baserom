# COP family: Invalid ops

_Ops: `$6E`–`$7F`, `$E3`_ · _Source: none (null / unmapped dispatch)_

[← COP index](../index.md)

## Overview

Nineteen opcode slots that **must never appear** in shipped scripts. They are not backed by handler code in `cop_handlers_*.asm`. **`CopDispatch`** always indirect-jumps through **`cop_dispatch_table`** (`extracted/system/engine/cop_dispatch.asm`); invalid slots either point at **`#$0000`** or fall outside the mapped handler table.

## Dispatch mechanics

```asm
CopDispatch {
    ...
    LDA [$0A]             ; opcode byte
    INC $0A
    ASL                   ; word index = opcode × 2
    TAX
    JMP ($&cop_dispatch_table, X)
}
```

If the selected table entry is **`#$0000`**, the CPU executes **`JMP ($0000)`** — an indirect jump through address **zero**, which crashes or hangs the game. There is no COP-level guard before the indirect jump.

## Invalid ranges

| Range | Table behavior | If executed |
|-------|----------------|-------------|
| `$6E`–`$7F` (18 opcodes) | Explicit **`#$0000`** placeholders in `cop_dispatch_table` @ `cop_dispatch.asm:164-181` | **`JMP ($0000)`** — null dispatch |
| `$E3` | No handler entry; index lies **past** last mapped opcode **`$E2`** (`SetEntryFar`) | Enters **`cop_table_sentinel`** (NOP / BRA loop) or unmapped ROM — undefined, treated as fatal |

Valid opcode coverage in the same table: **`$00`–`$6D`** and **`$80`–`$E2`** (209 handlers). The gap **`$6E`–`$7F`** exists because the original engine left a hole between lifecycle op **`$6D`** and sprite op **`$80`**.

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `6E`–`7F` | _(unassigned)_ | 0 | — | `#$0000` | Crash if executed |
| `E3` | _(past table)_ | 0 | — | none / sentinel | Crash / hang |

**Family call-site total:** 0

---

## Opcodes (documentary — do not emit)

#### COP `$6E`–`$7F` — null `cop_dispatch_table` gap

- **Handler:** none — table words are **`#$0000`**
- **Address range:** jump table indices **`$DC`–`$FE`** (opcode × 2)
- **Usage count:** 0 across `extracted/`

##### What it does

Not implemented. Dispatch loads a zero pointer and **`JMP`s through it**. No operand schema; **`db-us/copdef.json`** does not define these ops for tooling.

##### Parameters & contract

| Item | Value |
|------|-------|
| Operands | undefined |
| Call sites | **none** (audit: 0) |
| Intent | Reserved / removed opcodes in original Quintet layout |

---

#### COP `$E3` — past end of mapped opcodes

- **Handler:** none — last valid slot is **`$E2`** (`SetEntryFar` @ `cop_dispatch.asm:280`)
- **Guard:** **`cop_table_sentinel`** immediately follows the table (`NOP` / `BRA` loop @ `cop_dispatch.asm:286-289`)
- **Usage count:** 0

##### What it does

Opcode **`$E3`** indexes beyond the **`$E2`** entry. Execution is not supported; treat like corrupt script bytecode. Older notes referenced a phantom “table2” past **`$E2`**; the rebuilt engine uses a **single** 227-word table plus sentinel.

##### Parameters & contract

| Item | Value |
|------|-------|
| Operands | undefined |
| Call sites | **none** |
| Safe max opcode | **`$E2`** |

## Family notes

- Assemblers should only emit names present in **`db-us/copdef.json`**.
- If a rebuild introduces a new opcode, patch **`cop_dispatch_table`** **and** `copdef.json` together — do not reuse gap slots without a new handler.
- Mesen2 verification: breaking on **`CopDispatch`** with opcode ≥ **`$6E`** in the gap should show **`JMP ($0000)`** before any handler label.
