# COP family: Inventory

_Ops: `[D4]`, `[D5]`, `[D6]`, `[D7]`_ · _Source: `extracted/system/engine/cop_handlers_flow.asm`_

[← COP index](../index.md)

## Overview

Script-facing inventory primitives: grant or remove items, branch on possession, and branch on equipped slot. Regular items live in sixteen `$0AB4` slots; equipped index is `$0AC4`. All give/check/remove paths delegate to `inventory_mgmt` (`GiveItemToPlayer`, `RemoveItemFromInventory`, `CheckInventoryForItem`). Special item IDs `≥ $80` bypass slots (gold, HP, herbs, etc.) inside `GiveItemToPlayer`, not in the COP handlers themselves.

## Shared state

| Symbol | Address | Role |
|--------|---------|------|
| `inventorySlots` | `$0AB4` | 16 item bytes (0 = empty) |
| `inventoryEquippedIndex` | `$0AC4` | Index into slots for equipped item |
| `inventoryEquippedType` | `$0AC6` | Equipped category (cleared on remove) |
| `$0DB8` | — | Last item ID touched (dialogue display) |

## Family notes

- **`GiveItem` branches on failure** (inventory full, carry set), not on success — success is fallthrough after skipping the `&Code` operand.
- **`BranchIfMissingItem` branches when absent** (carry clear from `CheckInventoryForItem`); “player has item” is fallthrough.
- **`BranchIfItemEquipped`** compares the operand byte to `inventorySlots[inventoryEquippedIndex]`, not a direct “equipped item ID” field.
- **`RemoveItem`** always continues; missing items are a no-op in `RemoveItemFromInventory`.
- Extracted US scripts emit **preferred `copdef.json` names**; legacy **`BranchIfNoItem`** / **`BranchIfEquipped`** appear only in `extracted-jp/` and older notes.

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `D4` | `GiveItem` | 49 | `Byte`, `&Code` | `GiveItem` | Continue / Branch |
| `D5` | `RemoveItem` | 34 | `Byte` | `RemoveItem` | Continue |
| `D6` | `BranchIfMissingItem` | 35 | `Byte`, `&Code` | `BranchIfMissingItem` | Branch / Continue |
| `D7` | `BranchIfItemEquipped` | 5 | `Byte`, `&Code` | `BranchIfItemEquipped` | Branch / Continue |

**Preferred names** from `db-us/copdef.json`. **Legacy aliases:** `BranchIfNoItem` → `BranchIfMissingItem`; `BranchIfEquipped` → `BranchIfItemEquipped`.

**Family call-site total:** 123

---

## Opcodes

#### COP [D4] — `GiveItem` (try to add item)

- **Confidence:** high (handler + call-site audit)
- **Preferred name:** `GiveItem`
- **Handler:** `GiveItem` @ `extracted/system/engine/cop_handlers_flow.asm:463-483`
- **Parameters:** `Byte ItemId`, `&Code OnFull` (`db-us/copdef.json`: `["Byte", "&Code"]`)
- **Usage count:** 49

##### What it does

1. Read item ID byte; advance `$0A`.
2. **`JSL GiveItemToPlayer`** — carry **clear** = success (item placed or special reward applied); carry **set** = inventory full.
3. **Success:** skip the 2-byte `&Code` operand, set RTI PC to next opcode, **`RTI`**.
4. **Failure:** load `&Code OnFull` into `$02,S`, **`RTI`** into overflow handler (dialogue, alternate path).

Special IDs `≥ $80` never fill slots; the same carry rules apply inside `GiveItemToPlayer`.

##### Handler excerpt

```asm
GiveItem {
    TYX
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSL $@inventory_mgmt.GiveItemToPlayer
    BCS loc_00AC1E          ; full → branch target
    LDA [$0A]               ; success → skip &Code
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI
  loc_00AC1E:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI
}
```

##### How it is used

**Quest rewards with overflow text** — diamond-mine laborer gives items after dialog; full inventory jumps to shared overflow script:

```asm
; extracted/diamond_mine/mine_main/dm3F_laborer.asm
COP [GiveItem] ( #0C, &code_0AA767 )
...
COP [GiveItem] ( #0F, &code_0AA767 )

code_0AA767 {
    COP [PrintDialogString] ( &dialogstring_0AA9C5 )
    RTL
}
```

**Story pickups** — lithographs, keys, herbs, and dark-space rewards use the same pattern: `GiveItem` → flag / fanfare on success, `&overflow` on failure.

##### Parameters & contract

| Item | Value |
|------|-------|
| Operands | 1 byte ID + 2 byte same-bank branch |
| Success | Fallthrough; `$0DB8` may hold ID for follow-up dialog |
| Failure | **`RTI`** to `OnFull`; caller must **`RTL`** or continue script |
| Pairs with | `PrintDialogString`, `MusicAndText`, `SetFlagByte` after success |

---

#### COP [D5] — `RemoveItem` (delete one stack entry)

- **Confidence:** high
- **Preferred name:** `RemoveItem`
- **Handler:** `RemoveItem` @ `extracted/system/engine/cop_handlers_flow.asm:488-497`
- **Parameters:** `Byte ItemId`
- **Usage count:** 34

##### What it does

Reads item ID, calls **`RemoveItemFromInventory`**: scans all 16 slots, zeroes first match, resets equipped index to `$FFFF` and equipped type to 0. Always resumes after the operand.

##### Handler excerpt

```asm
RemoveItem {
    TYX
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSL $@inventory_mgmt.RemoveItemFromInventory
    LDA $0A
    STA $02, S
    RTI
}
```

##### How it is used

Payment gates (spirit guide takes Red Jewel or Herb), key consumption in `item_use_system.asm`, and puzzle scripts that delete quest items after use. Often chained: `BranchIfMissingItem` guard → gameplay → `RemoveItem`.

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand | 1 byte item ID |
| Missing item | Silent no-op |
| WRAM | Clears slot; may reset `$0AC4` / `$0AC6` |
| Outcome | Always **Continue** |

---

#### COP [D6] — `BranchIfMissingItem` (branch if player lacks item)

- **Confidence:** high
- **Preferred name:** `BranchIfMissingItem`
- **Aliases:** `BranchIfNoItem`
- **Handler:** `BranchIfMissingItem` @ `extracted/system/engine/cop_handlers_flow.asm:502-522`
- **Parameters:** `Byte ItemId`, `&Code`
- **Usage count:** 35

##### What it does

1. **`JSL CheckInventoryForItem`** with ID in A.
2. **Carry clear** (not in inventory) → **`RTI`** to `&Code`.
3. **Carry set** (found) → skip `&Code`, continue script.

Polarity matches legacy name **`BranchIfNoItem`**: branch runs when the item is **missing**.

##### Handler excerpt

```asm
BranchIfMissingItem {
    TYX
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSL $@inventory_mgmt.CheckInventoryForItem
    BCC loc_00AC51        ; absent → branch
    LDA [$0A]             ; present → skip &Code
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI
  loc_00AC51:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI
}
```

##### How it is used

**Gate until collection complete** — pyramid explorer blocks passage until all six hieroglyph stones are owned (fallthrough when all present):

```asm
; extracted/pyramid/puzzle_room/pyCD_explorer.asm
COP [BranchIfMissingItem] ( #1E, &code_08C250 )
COP [BranchIfMissingItem] ( #1F, &code_08C250 )
...
COP [BranchIfMissingItem] ( #23, &code_08C250 )
; all owned → fallthrough → ClearLowHere / Die
```

**Payment branches** — `BranchIfMissingItem` on currency item sends script to alternate “cannot pay” dialog.

##### Parameters & contract

| Item | Value |
|------|-------|
| Operands | 1 byte ID + 2 byte `&Code` |
| Branch | Item **not** in any slot |
| Continue | Item found at least once |
| Outcome | **Branch** or **Continue** |

---

#### COP [D7] — `BranchIfItemEquipped` (branch if item is equipped)

- **Confidence:** high
- **Preferred name:** `BranchIfItemEquipped`
- **Aliases:** `BranchIfEquipped`
- **Handler:** `BranchIfItemEquipped` @ `extracted/system/engine/cop_handlers_flow.asm:527-550`
- **Parameters:** `Byte ItemId`, `&Code`
- **Usage count:** 5

##### What it does

Loads equipped slot index `$0AC4`, compares **`inventorySlots[Y]`** to the operand byte (8-bit compare). **Equal** → **`RTI`** to branch target. **Unequal** → skip operand, continue.

Does not check whether the item exists elsewhere in the bag — only the **currently equipped** slot.

##### Handler excerpt

```asm
BranchIfItemEquipped {
    TYX
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    LDY $inventoryEquippedIndex
    CMP $inventorySlots, Y
    REP #$20
    BEQ loc_00AC79        ; equipped → branch
    ...
  loc_00AC79:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI
}
```

##### How it is used

**Equipment-gated hazards** — Angkor blinding crystal: loop until **Black Crystal Glasses (`#1C`)** are equipped, not merely carried:

```asm
; extracted/angkor_wat/angkor_shrine_crystal/awBC_blinding_light.asm
COP [BranchIfItemEquipped] ( #1C, &code_089A5B )
COP [WaitByte] ( #13 )
...
COP [BranchIfItemEquipped] ( #1C, &code_089A53 )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operands | 1 byte ID + 2 byte `&Code` |
| Branch | Equipped slot byte == operand |
| Continue | Different item equipped or `$FFFF` index |
| Outcome | **Branch** or **Continue** |
