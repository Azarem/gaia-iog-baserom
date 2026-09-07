# Bank $00 — Event Flag System

**Bank:** `$00` (mirrored at `$80` for FastROM access)  
**Address range:** `$00B05E`–`$00B4F6`  
**ASM file:** `extracted/system/engine/cop_handlers_script.asm`  
**Block:** `system/cop_handlers_script` in `us/blocks.json`

This page documents the complete **bitfield flag subsystem** used throughout Illusion of Gaia for scene progression, puzzle state, WRAM-scoped actor flags, and cross-bank event queries. All core routines share one indexing scheme; far-call wrappers add constant offsets before delegating to the core set/test/clear functions.

**Related:** [`direction-collision.md`](direction-collision.md), [`actor-management.md`](actor-management.md), [`../../cop-commands-reference.md`](../../cop-commands-reference.md)

---

## Overview

| Category | Functions | Address Span | Approx. Size |
|----------|-----------|--------------|--------------|
| WRAM flags (`$0A80`, 32 bytes) | 5 | `$00B05E`–`$00B095`, `$00B4CC` | ~70 bytes |
| Event flags (`$0A00`, 256 bytes) | 3 | `$00B0B7`–`$00B0FB` | ~102 bytes |
| Bitmask table | 1 (data) | `$00B11D` | 8 bytes |
| Far-call wrappers (RTL) | 11 | `$00B481`–`$00B4F6` | ~128 bytes |
| **Total (this document)** | **19 routines + 1 table** | | **~308 bytes** |

---

## Bitfield Architecture

The engine stores flags as **packed bits in byte arrays**. A logical flag index (16-bit, passed in **A** on entry) maps to storage via:

```
byte_offset = index >> 3    ; divide by 8 — which byte in the array
bit_number  = index & 7     ; which bit within that byte (0–7)
bitmask     = bitmasks_bit_position[bit_number]
```

### Bitmask Lookup Table

| Property | Value |
|----------|-------|
| **Old Name** | `bitmasks_00B11D` |
| **New Name** | `bitmasks_bit_position` |
| **Hex Address** | `$00B11D` |
| **Decimal Address** | 45341 |
| **Size** | 8 bytes |

| Index | Mask | Binary |
|-------|------|--------|
| 0 | `$01` | `0000 0001` |
| 1 | `$02` | `0000 0010` |
| 2 | `$04` | `0000 0100` |
| 3 | `$08` | `0000 1000` |
| 4 | `$10` | `0001 0000` |
| 5 | `$20` | `0010 0000` |
| 6 | `$40` | `0100 0000` |
| 7 | `$80` | `1000 0000` |

All set/test/clear routines load the bitmask with `LDA $bitmasks_bit_position,X` where **X = index & 7** (8-bit AND after `SEP #$20`).

### Memory Regions

| Base | Size | Capacity | Purpose |
|------|------|----------|---------|
| `$000A00` | 256 bytes | 2048 flags | **Event flags** — persistent scene/world state |
| `$000A80` | 32 bytes | 256 flags | **WRAM flags** — shorter-lived / local state (often per-scene scratch) |

The **`+$0100` offset wrappers** remap indices 0–7 into the `$0A80` array (indices `$0100`–`$0107` → bytes 0–0 of `$0A80`). **`+$0200`** and **`+$0300`** wrappers remap into overlapping regions of the **`$0A00`** event array for subsystem-specific numbering (e.g. red jewel collection uses `$0200+` range via `TestEventFlag_0200` / `SetEventFlag_0200`).

### Carry Flag Convention (Test Routines)

`TestWramFlag` and `TestEventFlag` use **inverted carry semantics** for branch-friendly script code:

| Condition | Carry | Meaning for `BCC`/`BCS` |
|-----------|-------|-------------------------|
| Bit **set** (flag true) | **Clear** | `BCC` taken → "flag is set" path |
| Bit **clear** (flag false) | **Set** | `BCS` taken → "flag is clear" path |

Implementation pattern:

```asm
LDA bitmask
AND array_byte, Y
SEC              ; assume clear
BNE flag_is_set  ; non-zero AND → bit was set
; fall through with SEC → carry set
flag_is_set:
CLC              ; carry clear → bit set
```

---

## WRAM Flag Array ($0A80 — 32 bytes)

### TestWramFlag_Offset100

| Property | Value |
|----------|-------|
| **Old Name** | `func_00B05E` |
| **New Name** | `TestWramFlag_Offset100` |
| **Hex Address** | `$00B05E` |
| **Decimal Address** | 45150 |
| **End Address** | `$00B068` (exclusive `$00B069`) |
| **Size** | 11 bytes |
| **Termination** | `RTL` (far-call entry) |

#### Description

Far-call wrapper: masks index to low 3 bits, adds **`$0100`**, then **`JSR TestWramFlag`**. Maps COP/script indices 0–7 into WRAM flag bits `$0100`–`$0107`.

#### Algorithm

1. `AND #$0007` — only 8 WRAM flags accessible through this entry.
2. `CLC` / `ADC #$0100`.
3. `JSR $&TestWramFlag` / `RTL`.

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Calls | `TestWramFlag` | Core test |
| Used by | Scene scripts via `JSL` | e.g. red jewel reward handler |

---

### SetWramFlag_Offset100

| Property | Value |
|----------|-------|
| **Old Name** | `func_00B069` |
| **New Name** | `SetWramFlag_Offset100` |
| **Hex Address** | `$00B069` |
| **Decimal Address** | 45161 |
| **Size** | 11 bytes |
| **Termination** | `RTL` |

#### Description

Identical to `TestWramFlag_Offset100` but calls **`SetWramFlag`**. Used when scripts need to set one of the 8 low WRAM flags without knowing the `$0100` base offset.

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Calls | `SetWramFlag` | |
| Used by | `red_jewel_reward_handler.asm` | `JSL $@SetWramFlag_Offset100` |

---

### SetWramFlag

| Property | Value |
|----------|-------|
| **Old Name** | `sub_00B074` |
| **New Name** | `SetWramFlag` |
| **Hex Address** | `$00B074` |
| **Decimal Address** | 45172 |
| **End Address** | `$00B094` (exclusive `$00B095`) |
| **Size** | 33 bytes |
| **Termination** | `RTS` (near call) |

#### Description

Sets one bit in the **WRAM flag array** at `$000A80`. Index in **A** on entry (16-bit).

#### Algorithm

| Step | Operation | Detail |
|------|-----------|--------|
| 1 | `STA $0000` | Preserve full index |
| 2 | `LSR` ×3 | Byte offset → **Y** |
| 3 | `LDA $0000` / `AND #$07` / `TAX` | Bit position |
| 4 | `SEP #$20` | 8-bit for array access |
| 5 | `ORA $0A80,Y` with `$bitmasks_bit_position,X` | Set bit |
| 6 | `REP #$20` / `PLX` / `RTS` | |

#### Variables

| Address | Role |
|---------|------|
| `$000A80,Y` | WRAM flag byte (32-byte array) |
| `$bitmasks_bit_position` | 8-byte mask table at `$00B11D` |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | `SetWramFlag_Offset100` | After `+$0100` offset |
| Called by | COP flag-set handlers | Near `JSR` from script bank |
| Cataloged in | `us/names.json` @ 45172 | |

---

### TestWramFlag

| Property | Value |
|----------|-------|
| **Old Name** | `sub_00B095` |
| **New Name** | `TestWramFlag` |
| **Hex Address** | `$00B095` |
| **Decimal Address** | 45205 |
| **End Address** | `$00B0B6` (exclusive `$00B0B7`) |
| **Size** | 34 bytes |
| **Termination** | `RTS` |

#### Description

Tests one bit in **`$000A80`**. Returns with **carry clear** if bit set, **carry set** if bit clear (see [Carry Flag Convention](#carry-flag-convention-test-routines)).

#### Algorithm

Same index decomposition as `SetWramFlag`, but:

```asm
LDA bitmask
AND $0A80, Y
SEC
BNE loc_00B0B3   ; bit set → CLC at label
; carry remains set (bit clear)
loc_00B0B3:
CLC
```

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | `TestWramFlag_Offset100` | |
| Cataloged in | `us/names.json` @ 45205 | |

---

### ClearAllWramFlags

| Property | Value |
|----------|-------|
| **Old Name** | `func_00B4CC` |
| **New Name** | `ClearAllWramFlags` |
| **Hex Address** | `$00B4CC` |
| **Decimal Address** | 46284 |
| **End Address** | `$00B4DF` (exclusive `$00B4E0`) |
| **Size** | 19 bytes |
| **Termination** | `RTL` |

#### Description

Zeroes the entire **32-byte WRAM flag region** (`$000A80`–`$000A9F`) by writing 16 words of zero. Invoked at scene boundaries or puzzle resets when local WRAM flags must not persist.

#### Algorithm

```asm
LDX #$0000
LDA #$0000
loop:
  STA $000A80, X
  INX / INX
  CPX #$0020       ; 16 words = 32 bytes
  BNE loop
RTL
```

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Used by | `st68_kara.asm`, `sp58_red_eye.asm`, `sFE_actor_03A2F1.asm` | Scene entry cleanup via `JSL` |
| Cataloged in | `us/names.json` @ 46284 | |

---

## Event Flag Array ($0A00 — 256 bytes)

### SetEventFlag

| Property | Value |
|----------|-------|
| **Old Name** | `sub_00B0B7` |
| **New Name** | `SetEventFlag` |
| **Hex Address** | `$00B0B7` |
| **Decimal Address** | 45239 |
| **End Address** | `$00B0D7` (exclusive `$00B0D8`) |
| **Size** | 33 bytes |
| **Termination** | `RTS` |

#### Description

Sets one bit in the **2048-bit event flag array** starting at **`$000A00`**. This is the primary persistence mechanism for story progression (chests opened, bosses defeated, switches flipped).

#### Algorithm

Identical bitfield indexing to `SetWramFlag`, targeting **`$0A00,Y`** instead of `$0A80,Y`.

#### Variables

| Address | Role |
|---------|------|
| `$000A00,Y` | Event flag byte (256-byte array = 2048 flags) |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | All `Set*` far-call wrappers | After offset addition |
| Called by | COP `$65`–style flag handlers | Direct `JSR` |
| Cataloged in | `us/names.json` @ 45239 | ~6+ direct COP call sites |

---

### ClearEventFlag

| Property | Value |
|----------|-------|
| **Old Name** | `sub_00B0D8` |
| **New Name** | `ClearEventFlag` |
| **Hex Address** | `$00B0D8` |
| **Decimal Address** | 45272 |
| **End Address** | `$00B0FA` (exclusive `$00B0FB`) |
| **Size** | 35 bytes |
| **Termination** | `RTS` |

#### Description

Clears one event flag bit using **inverted-mask AND**:

```asm
LDA bitmask
EOR #$FF          ; invert mask
AND $0A00, Y
STA $0A00, Y
```

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | `ClearFlagRaw`, `ClearFlag_0100` | Far-call wrappers |
| Cataloged in | `us/names.json` @ 45272 | |

---

### TestEventFlag

| Property | Value |
|----------|-------|
| **Old Name** | `sub_00B0FB` |
| **New Name** | `TestEventFlag` |
| **Hex Address** | `$00B0FB` |
| **Decimal Address** | 45307 |
| **End Address** | `$00B11C` (exclusive `$00B11D`) |
| **Size** | 34 bytes |
| **Termination** | `RTS` |

#### Description

Tests one **event flag** bit with the same carry convention as `TestWramFlag`. Most common flag query path — all `Test*` wrappers funnel here.

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | All `Test*` far-call wrappers | ~8+ call sites |
| Called by | `chunk_038000.asm`, `warps_interaction.asm` | Cross-bank `JSL` |
| Cataloged in | `us/names.json` @ 45307 | |

---

## Far-Call Flag Wrappers (RTL-terminated)

All wrappers below are **`RTL` entry points** intended for **`JSL`** from other banks. They preserve the standard index-in-**A** convention, optionally mask or offset it, then **`JSR`** the near core routine.

| New Name | Old Name | Address | Offset Added | Operation | Notes |
|----------|----------|---------|--------------|-----------|-------|
| `SetEventFlag_0200` | `func_00B481` | `$00B481` | `+$0200` | Set | Red jewel / warp flag range |
| `TestEventFlag_0200` | `func_00B489` | `$00B489` | `+$0200` | Test | Masks A to `$FF` first |
| `TestFlag_0300` | `func_00B496` | `$00B496` | `+$0300` | Test | Subsystem flags |
| `SetFlag_0300` | `func_00B4A1` | `$00B4A1` | `+$0300` | Set | |
| `TestFlag_0510` | `func_00B4AC` | `$00B4AC` | `+$0510` | Test | High-index event range |
| `TestFlagRaw` | `func_00B4B7` | `$00B4B7` | none (`AND #$FF`) | Test | Direct 8-bit index |
| `SetFlagRaw` | `func_00B4BE` | `$00B4BE` | none (`AND #$FF`) | Set | |
| `ClearFlagRaw` | `func_00B4C5` | `$00B4C5` | none (`AND #$FF`) | Clear | |
| `SetFlag_0100` | `func_00B4E0` | `$00B4E0` | `+$0100` | Set | Event array high page |
| `ClearFlag_0100` | `func_00B4EB_noref` | `$00B4EB` | `+$0100` | Clear | **Unreferenced** in ROM |
| `TestFlag_0100` | `func_00B4F6` | `$00B4F6` | `+$0100` | Test | |

### SetEventFlag_0200

| Property | Value |
|----------|-------|
| **Hex Address** | `$00B481` |
| **Size** | 8 bytes |

```asm
CLC
ADC #$0200
JSR $&SetEventFlag
RTL
```

Used by warp and red-jewel actors (`hidden_red_jewel.asm`, `warps_interaction.asm`).

### TestEventFlag_0200

| Property | Value |
|----------|-------|
| **Hex Address** | `$00B489` |
| **Size** | 13 bytes |

```asm
REP #$20
AND #$00FF
CLC
ADC #$0200
JSR $&TestEventFlag
RTL
```

### TestFlag_0300 / SetFlag_0300

| Property | Value |
|----------|-------|
| **Addresses** | `$00B496` / `$00B4A1` |
| **Size** | 11 bytes each |

`AND #$00FF`, add `$0300`, JSR test/set, RTL.

### TestFlag_0510

| Property | Value |
|----------|-------|
| **Hex Address** | `$00B4AC` |
| **Size** | 11 bytes |

Adds **`$0510`** before test — accesses flags in the `$0510`–`$051F` index range (byte `$0A00+$A2` area).

### TestFlagRaw / SetFlagRaw / ClearFlagRaw

| Property | Value |
|----------|-------|
| **Addresses** | `$00B4B7` / `$00B4BE` / `$00B4C5` |
| **Size** | 7 bytes each |

Pass **`A & $FF`** directly as the flag index with no offset — simplest cross-bank API for indices 0–255 in the base event array.

### SetFlag_0100 / TestFlag_0100

| Property | Value |
|----------|-------|
| **Addresses** | `$00B4E0` / `$00B4F6` |
| **Size** | 11 bytes each |

Add **`$0100`** to access the second 256-flag page within the `$0A00` array (indices `$0100`–`$01FF`).

### ClearFlag_0100 (Unreferenced)

| Property | Value |
|----------|-------|
| **Old Name** | `func_00B4EB_noref` |
| **Hex Address** | `$00B4EB` |
| **Size** | 11 bytes |
| **Status** | **Dead code** — no `JSL`/reference in extracted ROM |

Mirrors `SetFlag_0100` but calls `ClearEventFlag`. Present in the binary but unused by any shipped script.

---

## Usage Patterns

### From COP Handlers (Same Bank)

Script COPs typically load a flag index from the bytecode stream, then `JSR $&TestEventFlag` or `JSR $&SetEventFlag` (near call, `RTS` return).

### From Actor Code (Cross-Bank)

Actor `.asm` files in other banks use **`JSL $@TestEventFlag_0200`** etc. The wrapper adds the subsystem offset and returns via **`RTL`**, restoring the caller's program bank.

### Scene Reset

`ClearAllWramFlags` clears **`$0A80`** only — **not** the `$0A00` event array. Persistent story flags survive scene transitions; WRAM flags are scratch.

---

## Quick Reference

| New Name | Old Name | Address | Array | Operation |
|----------|----------|---------|-------|-----------|
| `TestWramFlag_Offset100` | `func_00B05E` | `$00B05E` | `$0A80` | Test (+$0100) |
| `SetWramFlag_Offset100` | `func_00B069` | `$00B069` | `$0A80` | Set (+$0100) |
| `SetWramFlag` | `sub_00B074` | `$00B074` | `$0A80` | Set |
| `TestWramFlag` | `sub_00B095` | `$00B095` | `$0A80` | Test |
| `SetEventFlag` | `sub_00B0B7` | `$00B0B7` | `$0A00` | Set |
| `ClearEventFlag` | `sub_00B0D8` | `$00B0D8` | `$0A00` | Clear |
| `TestEventFlag` | `sub_00B0FB` | `$00B0FB` | `$0A00` | Test |
| `bitmasks_bit_position` | `bitmasks_00B11D` | `$00B11D` | — | Data table |
| `ClearAllWramFlags` | `func_00B4CC` | `$00B4CC` | `$0A80` | Clear all |
| `SetEventFlag_0200` | `func_00B481` | `$00B481` | `$0A00` | Set (+$0200) |
| `TestEventFlag_0200` | `func_00B489` | `$00B489` | `$0A00` | Test (+$0200) |
| `TestFlag_0300` | `func_00B496` | `$00B496` | `$0A00` | Test (+$0300) |
| `SetFlag_0300` | `func_00B4A1` | `$00B4A1` | `$0A00` | Set (+$0300) |
| `TestFlag_0510` | `func_00B4AC` | `$00B4AC` | `$0A00` | Test (+$0510) |
| `TestFlagRaw` | `func_00B4B7` | `$00B4B7` | `$0A00` | Test (raw) |
| `SetFlagRaw` | `func_00B4BE` | `$00B4BE` | `$0A00` | Set (raw) |
| `ClearFlagRaw` | `func_00B4C5` | `$00B4C5` | `$0A00` | Clear (raw) |
| `SetFlag_0100` | `func_00B4E0` | `$00B4E0` | `$0A00` | Set (+$0100) |
| `ClearFlag_0100` | `func_00B4EB_noref` | `$00B4EB` | `$0A00` | Clear (+$0100, unused) |
| `TestFlag_0100` | `func_00B4F6` | `$00B4F6` | `$0A00` | Test (+$0100) |
