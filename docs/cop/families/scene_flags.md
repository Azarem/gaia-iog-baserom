# COP family: Scene flags

_Ops: `[CC]`–`[D3]`_ · _Source: [`cop_handlers_flow.asm`](../../../extracted/system/engine/cop_handlers_flow.asm) (handlers), [`cop_handlers_flags.asm`](../../../extracted/system/engine/cop_handlers_flags.asm) (core routines)_

[← COP index](../index.md)

## Overview

Persistent story and map state live in the **`eventFlags`** bitfield at **`$0A00`**. These eight COP opcodes set/clear/test flags by index and implement conditional branches and cooperative waits. Core math (**byte = index ÷ 8**, **bit = index & 7**, mask from **`bitmasks_bit_position`**) is in **`SetEventFlag`**, **`ClearEventFlag`**, and **`TestEventFlag`** ([`cop_handlers_flags.asm`](../../../extracted/system/engine/cop_handlers_flags.asm)). Word-indexed ops (`*Word`) use the same routines with 16-bit indices (flags above `$FF`, map rearranges, prologue legend bits).

## Shared state

| Symbol | Address | Role |
|--------|---------|------|
| `eventFlags` | `$0A00` | Primary save-backed event bitfield |
| `wramFlags` | `$0A80` | Dungeon kill / WRAM flags (**not** these COPs — see `[D8]`) |
| `bitmasks_bit_position` | table in [`cop_handlers_flags.asm`](../../../extracted/system/engine/cop_handlers_flags.asm) | Bit 0–7 → `$01`–`$80` |

JSL wrappers with bases **`$0100`**, **`$0200`**, **`$0300`**, **`$0510`** offset indices for bosses, chests, scene scope, and late-game progression; COP flag ops use **raw** indices into **`$0A00`**.

## Family notes

- **`BranchOnFlagByte`** (`[D0]`) and **`BranchOnFlagWord`** (`[D1]`) share one compare tail (`loc_00AB9A`–`loc_00ABB7`): sense byte **`#00`** = branch when flag **clear**; **nonzero** = branch when flag **set**.
- **`WaitOnFlagByte`** / **`WaitOnFlagWord`** rewind entry to **`$0A − 2`** each attempt and **`RTL`** until **`TestEventFlag`** matches the sense — then **`RTI`** past the wait.
- Dominant branch pattern: **`BranchOnFlagByte ( #id, #00, &skip )`** — “if quest already done (flag set), skip spawn.”
- Extracted ASM uses preferred names; legacy **`BranchIfFlagByte`**, **`ExitIfFlagByte`**, etc. appear only in older commentary.

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `CC` | `SetFlagByte` | 475 | `Byte` | `SetFlagByte` | Continue |
| `CD` | `SetFlagWord` | 62 | `Word` | `SetFlagWord` | Continue |
| `CE` | `ClearFlagByte` | 71 | `Byte` | `ClearFlagByte` | Continue |
| `CF` | `ClearFlagWord` | 22 | `Word` | `ClearFlagWord` | Continue |
| `D0` | `BranchOnFlagByte` | 630 | `Byte`, `Byte`, `&Code` | `BranchOnFlagByte` | Branch / Continue |
| `D1` | `BranchOnFlagWord` | 40 | `Word`, `Byte`, `&Code` | `BranchOnFlagWord` | Branch / Continue |
| `D2` | `WaitOnFlagByte` | 384 | `Byte`, `Byte` | `WaitOnFlagByte` | Halt |
| `D3` | `WaitOnFlagWord` | 9 | `Word`, `Byte` | `WaitOnFlagWord` | Halt |

**Legacy aliases:** `SetFlagByte`/`Word` unchanged; `BranchIfFlagByte` → `BranchOnFlagByte`; `BranchIfFlagWord` → `BranchOnFlagWord`; `ExitIfFlagByte` → `WaitOnFlagByte`; `ExitIfFlagWord` → `WaitOnFlagWord`.

**Family call-site total:** 1693

---

## Opcodes

#### COP [CC] — `SetFlagByte` (set event flag, byte index)

- **Handler:** `SetFlagByte` @ [`cop_handlers_flow.asm:298-307`](../../../extracted/system/engine/cop_handlers_flow.asm)
- **Parameters:** `Byte Flag` (`db-us/copdef.json`)
- **Usage count:** 475

##### What it does

1. Read flag index byte from script; mask to 8 bits.
2. **`JSR SetEventFlag`** — OR bit into **`eventFlags[$0A00]`**.
3. **`RTI`** after operand.

##### Handler excerpt

```asm
SetFlagByte {
    TYX
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&cop_handlers_flags.SetEventFlag
    LDA $0A
    STA $02, S
    RTI
}
```

##### How it is used

Quest progression, boss phases, epilogue handshakes:

```asm
; extracted/ending/ending_comet/sE5_epilogue.asm
COP [SetFlagByte] ( #02 )
...
COP [SetFlagByte] ( #DB )

; extracted/babel_tower/comet_lair/sE8_dark_gaia.asm
COP [SetFlagByte] ( #03 )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Index range | `$00`–`$FF` (256 distinct bit positions in low table) |
| Persistence | Save-backed via `eventFlags` |

##### Relation to similar ops

| Op | Difference |
|----|------------|
| `[CD]` | 16-bit index |
| `[CE]` | Clears bit instead of set |

---

#### COP [CD] — `SetFlagWord` (set event flag, word index)

- **Handler:** `SetFlagWord` @ [`cop_handlers_flow.asm:312-321`](../../../extracted/system/engine/cop_handlers_flow.asm)
- **Parameters:** `Word Flag`
- **Usage count:** 62

##### What it does

Read 16-bit index, **`JSR SetEventFlag`**, continue.

##### Handler excerpt

```asm
SetFlagWord {
    TYX
    LDA [$0A]
    INC $0A
    INC $0A
    JSR $&cop_handlers_flags.SetEventFlag
    LDA $0A
    STA $02, S
    RTI
}
```

##### How it is used

Prologue legend pages and extended map flags:

```asm
; extracted/prologue/prologue_legends/pr8D_prologue2.asm
COP [SetFlagWord] ( #$017C )
COP [SetFlagWord] ( #$017D )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Index | e.g. **`#$011D`** for map rearrange slots |

##### Relation to similar ops

| Op | Difference |
|----|------------|
| `[CC]` | Byte operand only |
| `[CF]` | Clear word-indexed flag |

---

#### COP [CE] — `ClearFlagByte` (clear flag, byte index)

- **Handler:** `ClearFlagByte` @ [`cop_handlers_flow.asm:326-335`](../../../extracted/system/engine/cop_handlers_flow.asm)
- **Parameters:** `Byte Flag`
- **Usage count:** 71

##### What it does

**`JSR ClearEventFlag`** with byte index; AND off bit in **`eventFlags`**.

##### Handler excerpt

```asm
ClearFlagByte {
    TYX
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&cop_handlers_flags.ClearEventFlag
    LDA $0A
    STA $02, S
    RTI
}
```

##### How it is used

Reset handshake flags after cutscene beats, boot logo, breakable walls:

```asm
; extracted/ending/ending_comet/sE5_epilogue.asm
COP [ClearFlagByte] ( #04 )

; extracted/babel_tower/comet_lair/sE8_dark_gaia.asm
COP [ClearFlagByte] ( #02 )

; extracted/system/boot_logos/sFB_boot_logo.asm
COP [ClearFlagByte] ( #10 )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Pairing | Often after **`WaitOnFlagByte`** / spawn sync |

##### Relation to similar ops

| Op | Difference |
|----|------------|
| `[CC]` | Sets same bit |
| `[CF]` | Word index clear |

---

#### COP [CF] — `ClearFlagWord` (clear flag, word index)

- **Handler:** `ClearFlagWord` @ [`cop_handlers_flow.asm:340-349`](../../../extracted/system/engine/cop_handlers_flow.asm)
- **Parameters:** `Word Flag`
- **Usage count:** 22

##### What it does

**`JSR ClearEventFlag`** with word index.

##### Handler excerpt

```asm
ClearFlagWord {
    TYX
    LDA [$0A]
    INC $0A
    INC $0A
    JSR $&cop_handlers_flags.ClearEventFlag
    LDA $0A
    STA $02, S
    RTI
}
```

##### How it is used

```asm
; extracted/prologue/prologue_legends/pr8D_prologue2.asm
COP [ClearFlagWord] ( #$017C )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Mirror | **`SetFlagWord`** / **`BranchOnFlagWord`** |

##### Relation to similar ops

| Op | Difference |
|----|------------|
| `[CE]` | Byte index |

---

#### COP [D0] — `BranchOnFlagByte` (conditional branch)

- **Preferred name:** `BranchOnFlagByte`
- **Aliases:** `BranchIfFlagByte`
- **Handler:** `BranchOnFlagByte` @ [`cop_handlers_flow.asm:354-402`](../../../extracted/system/engine/cop_handlers_flow.asm) (shared tail with `[D1]`)
- **Parameters:** `Byte Flag`, `Byte Val`, `&Code`
- **Usage count:** 630

##### What it does

1. **`TestEventFlag`** on byte index — **carry set** = flag **set**, **carry clear** = **clear**.
2. Read **sense** byte **`Val`**:
   - **`Val = 0`**: branch to **`&Code`** when flag **clear** (BCC path + sense 0).
   - **`Val ≠ 0`**: branch when flag **set** (BCS path + sense nonzero).
3. If branch not taken, skip **`&Code`** word and continue.

##### Handler excerpt

```asm
BranchOnFlagByte {
    TYX
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&cop_handlers_flags.TestEventFlag
    BCS loc_00ABA5
    BCC loc_00AB9A
}
; loc_00AB9A / loc_00ABA5 / loc_00ABAE / loc_00ABB7 — shared with BranchOnFlagWord
```

##### How it is used

Skip NPC spawn if event already completed; gate epilogue path:

```asm
; extracted/ending/ending_comet/sE5_epilogue.asm
COP [BranchOnFlagByte] ( #DB, #01, &code_0BD374 )

; extracted/babel_tower/comet_lair/sE8_comet_display_config.asm
COP [BranchOnFlagByte] ( #FF, #00, &code_0CEB76 )

; extracted/babel_tower/comet_lair/sE8_dark_gaia.asm
COP [BranchOnFlagByte] ( #03, #01, &code_0CF5AD )
```

**`#01`** + branch target = “if flag **set**, go to **`&Code`**”. **`#00`** = “if flag **clear**, branch.”

##### Parameters & contract

| Item | Value |
|------|-------|
| Sense **`Val`** | `0` = test for clear; nonzero = test for set |
| Branch target | 2-byte **`&Code`** (same bank) |

##### Relation to similar ops

| Op | Difference |
|----|------------|
| `[D1]` | Word flag index |
| `[D2]` | **Wait** until sense matches instead of one-shot branch |

---

#### COP [D1] — `BranchOnFlagWord` (conditional branch, word index)

- **Preferred name:** `BranchOnFlagWord`
- **Aliases:** `BranchIfFlagWord`
- **Handler:** `BranchOnFlagWord` @ [`cop_handlers_flow.asm:367-402`](../../../extracted/system/engine/cop_handlers_flow.asm)
- **Parameters:** `Word Flag`, `Byte Val`, `&Code`
- **Usage count:** 40

##### What it does

Word-indexed **`TestEventFlag`**, then identical sense/branch logic as **`[D0]`**.

##### Handler excerpt

```asm
BranchOnFlagWord {
    TYX
    LDA [$0A]
    INC $0A
    INC $0A
    JSR $&cop_handlers_flags.TestEventFlag
    BCS loc_00ABA5
  loc_00AB9A:
    ; sense + &Code dispatch (shared)
}
```

##### How it is used

```asm
; extracted/prologue/prologue_legends/pr8D_prologue2.asm
COP [BranchOnFlagWord] ( #$017C, #01, &code_0BCB8A )
COP [BranchOnFlagWord] ( #$017C, #00, &code_0BCD14 )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Flag | 16-bit index (legend **`#$017C`–`#$017F`**, gates **`#$0177`+**) |

##### Relation to similar ops

| Op | Difference |
|----|------------|
| `[D0]` | Byte index |
| `[D3]` | Cooperative wait on word flag |

---

#### COP [D2] — `WaitOnFlagByte` (yield until flag matches sense)

- **Preferred name:** `WaitOnFlagByte`
- **Aliases:** `ExitIfFlagByte`
- **Handler:** `WaitOnFlagByte` @ [`cop_handlers_flow.asm:407-458`](../../../extracted/system/engine/cop_handlers_flow.asm) (shared tail with `[D3]`)
- **Parameters:** `Byte Flag`, `Byte Val`
- **Usage count:** 384

##### What it does

1. **`$00 ← $0A − 2`** — re-run this COP from the same script site each frame.
2. **`TestEventFlag`**; compare to **sense** **`Val`** (same rules as branch: **`0`** = wait **for clear**, **nonzero** = wait **for set**).
3. If **not** matched: **`RTL`** (yield, retry next frame).
4. If matched: **`RTI`** past operands.

##### Handler excerpt

```asm
WaitOnFlagByte {
    TYX
    LDA $0A
    DEC
    DEC
    STA $00
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&cop_handlers_flags.TestEventFlag
    BCS loc_00ABF4
    BCC loc_00ABE9
}
; loc_00ABE9 / loc_00ABF4 / loc_00ABFD / loc_00AC00 — shared with WaitOnFlagWord
```

##### How it is used

Sync spawns and dialog to companion actors / thinkers clearing handshake flags:

```asm
; extracted/ending/ending_comet/sE5_epilogue.asm
COP [SetFlagByte] ( #02 )
COP [SpawnAfterAbsFlags] ( ... )
COP [WaitOnFlagByte] ( #02, #00 )
COP [PrintDialogString] ( ... )
```

Wait **`#02, #00`** = pause until flag **#02 is clear** (companion clears it when ready).

##### Parameters & contract

| Item | Value |
|------|-------|
| Outcome | Halt each frame until condition true |
| Entry rewind | Same COP re-executes |

##### Relation to similar ops

| Op | Difference |
|----|------------|
| `[D0]` | Single-tick branch, no yield loop |
| `[DA]` | Time-based **`$08`**, not flag |
| `[D3]` | Word flag index |

---

#### COP [D3] — `WaitOnFlagWord` (yield until word flag matches)

- **Preferred name:** `WaitOnFlagWord`
- **Aliases:** `ExitIfFlagWord`
- **Handler:** `WaitOnFlagWord` @ [`cop_handlers_flow.asm:424-458`](../../../extracted/system/engine/cop_handlers_flow.asm)
- **Parameters:** `Word Flag`, `Byte Val`
- **Usage count:** 9

##### What it does

Same wait loop as **`[D2]`** with 16-bit flag index.

##### Handler excerpt

```asm
WaitOnFlagWord {
    TYX
    LDA $0A
    DEC
    DEC
    STA $00
    LDA [$0A]
    INC $0A
    INC $0A
    JSR $&cop_handlers_flags.TestEventFlag
    BCS loc_00ABF4
  loc_00ABE9:
    ; sense check → RTL or RTI (shared)
}
```

##### How it is used

Crystal gates and boss arenas (extended flags):

```asm
; extracted/babel_tower/babel_middle_floors/btE0_crystal_gate_c.asm
COP [WaitOnFlagWord] ( #$0177, #01 )

; extracted/great_wall/sand_fanger_lair/gw8A_sand_fanger.asm
COP [WaitOnFlagWord] ( #$016A, #01 )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Sense | Same as **`[D2]`** |
| Typical **`Val`** | **`#01`** = wait until flag **set** |

##### Relation to similar ops

| Op | Difference |
|----|------------|
| `[D2]` | Byte index |
| `[D1]` | Immediate branch on word flag |
