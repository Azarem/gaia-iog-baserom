# COP family: VRAM / memory

_Ops: `[4F]`, `[50]`, `[51]`, `[54]`_ · _Source: [`cop_handlers_map.asm`](../../../extracted/system/engine/cop_handlers_map.asm)_

[← COP index](../index.md)

## Overview

Graphics memory helpers: stage one-off VRAM DMA, copy palette rows into CGRAM staging, Quintet-LZ decompress to WRAM/VRAM staging, and store a far pointer in per-actor **`animScratch`**. Credits, title, boot logos, and battle UI are the heaviest users.

## Shared state

| Symbol | Address | Role |
|--------|---------|------|
| `adhocVramDma` | `$7F0C03` | Source ptr, bank, VRAM dest, size staging |
| `extendedFlags` | `$7F002A,X` | Bit 0 = adhoc DMA in flight |
| `$7F0C07` | staging | VRAM dest word (also busy sentinel) |
| CGRAM staging | `$7F0A00+` | **`CopyPalette`** destination window |
| `animScratch` | `$7F0000,X` / `$7F0002,X` | Word + bank scratch |
| `$0402` | DMA helper | Internal palette copy routine |

## Family notes

- **`AdhocVramDma`** operand order in ASM: **`Address` src, `Word` vramDest, `Word` size** — match `copdef.json`, not legacy wiki swaps.
- First **`AdhocVramDma`** entry **yields** until engine drains prior DMA; completion skips **7 bytes** of operands.
- **`Decompress`** calls **`QuintetLzDecompress`** then **`ClearActorRenderList`** (sprite rebuild after GFX swap).
- **`Cop51Patch.patch.asm`** (optional rebuild) extends **`Decompress`** semantics for MVN shortcuts — base ROM uses LZ only.
- Legacy name **`SetAnimScratch`** → **`SetScratchPointer`**.

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `4F` | `AdhocVramDma` | 67 | `Address`, `Word`, `Word` | `AdhocVramDma` | Halt |
| `50` | `CopyPalette` | 23 | `Address`, 3×`Byte` | `CopyPalette` | Continue |
| `51` | `Decompress` | 13 | `Address`, `Address` | `Decompress` | Continue |
| `54` | `SetScratchPointer` | 4 | `Address` | `SetScratchPointer` | Continue |

**Legacy alias:** `SetAnimScratch` → `SetScratchPointer`.

**Family call-site total:** 107

---

## Opcodes

#### COP [4F] — `AdhocVramDma` (one-shot VRAM upload)

- **Confidence:** high
- **Handler:** `AdhocVramDma` @ [`cop_handlers_map.asm:402-463`](../../../extracted/system/engine/cop_handlers_map.asm)
- **Parameters:** `Address Src`, `Word VramWord`, `Word Size` (`db-us/copdef.json`)
- **Usage count:** 67

##### What it does

**Phase A (bit 0 clear):** If `$7F0C07` staging busy, yield. Else rewind PC, read src word + bank byte + VRAM dest + size into **`$7F0C03–$09`**, set **`extendedFlags` bit 0**, **`RTL`**.

**Phase B (bit 0 set):** Poll until hardware/engine advances VRAM dest past staged value; clear bit 0, skip 7 operand bytes, **`RTI`**.

##### Handler excerpt

```asm
AdhocVramDma {
    TYX
    LDA $extendedFlags, X
    BIT #$0001
    BNE loc_00990E          ; poll completion
    ...
    ORA #$0001              ; staged — yield
    STA $extendedFlags, X
    PLA
    PLA
    RTL
  loc_00991C:
    AND #$FFFE              ; done — skip 7-byte block
    ...
    RTI
}
```

##### How it is used

**Credits GFX upload** — burst of WRAM → VRAM copies after decompress:

```asm
; extracted/ending/ending_credits/sF7_credits.asm
COP [AdhocVramDma] ( $7F0200, #$7C00, #$0800 )
COP [AdhocVramDma] ( $7FC000, #$2000, #$0800 )
...
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operands | 3-byte `Address` + 2 VRAM words |
| State | `extendedFlags` bit 0, `$7F0C03` block |
| Outcome | **Halt** (multi-entry) until DMA done |

---

#### COP [50] — `CopyPalette` (CGRAM staging copy)

- **Confidence:** high
- **Handler:** `CopyPalette` @ [`cop_handlers_map.asm:468-509`](../../../extracted/system/engine/cop_handlers_map.asm)
- **Parameters:** `Address Src`, `Byte srcPalIndex`, `Byte dstPalIndex`, `Byte count`
- **Usage count:** 23

##### What it does

Builds source pointer from **`Src` + (srcIndex×2)**, destination **`$0A00 + (dstIndex×2)`**, calls **`JSR $0402`** to move **`count`** palette entries (words). Source bank forced to **`$7F`** for anim/scratch region. Single **`RTI`**.

##### Handler excerpt

```asm
CopyPalette {
    LDA [$0A]             ; source base
    ...
    ADC #$0A00            ; CGRAM staging base
    TAY
    ...
    JSR $0402
    RTI
}
```

##### How it is used

```asm
; extracted/system/title_screen/sFC_title_intro.asm
COP [CopyPalette] ( @pal_title, #00, #00, #20 )
COP [CopyPalette] ( @pal_ending_comet, #00, #00, #08 )
```

Credits swap full **`#80`**-entry palettes between scenes.

##### Parameters & contract

| Item | Value |
|------|-------|
| Operands | far src + 3 byte indices/count |
| Units | Palette **entries** (×2 internally for words) |
| Outcome | **Continue** |

---

#### COP [51] — `Decompress` (Quintet LZ)

- **Confidence:** high
- **Handler:** `Decompress` @ [`cop_handlers_map.asm:514-547`](../../../extracted/system/engine/cop_handlers_map.asm)
- **Parameters:** `Address Src`, `Address Dest` (dest includes bank byte in `Address` form)
- **Usage count:** 13

##### What it does

Loads compressed stream pointer and destination, reads size word from bitstream header, **`JSL QuintetLzDecompress`**, then **`JSL ClearActorRenderList`**. **`RTI`**.

##### Handler excerpt

```asm
Decompress {
    ...
    JSL $@QuintetLzDecompress
    JSL $@sprite_composition.ClearActorRenderList
    ...
    RTI
}
```

##### How it is used

Credits load large GFX blobs into **`$7EE000` / `$7EA000`** before **`AdhocVramDma`** pushes tiles to VRAM.

##### Parameters & contract

| Item | Value |
|------|-------|
| Operands | 3-byte src + 3-byte dest |
| Side effect | Actor render list cleared |
| Patch | `Cop51Patch` adds non-LZ MVN modes when enabled |
| Outcome | **Continue** |

---

#### COP [54] — `SetScratchPointer` (anim / FX far pointer)

- **Confidence:** high
- **Preferred name:** `SetScratchPointer`
- **Aliases:** `SetAnimScratch`
- **Handler:** `SetScratchPointer` @ [`cop_handlers_map.asm:552-565`](../../../extracted/system/engine/cop_handlers_map.asm)
- **Parameters:** `Address` (word + bank)
- **Usage count:** 4

##### What it does

Writes **`animScratch,X`** (word) and **`animScratch+2,X`** (bank byte) from script operands. Downstream sprite init / FX code reads the pointer without re-parsing script.

##### Handler excerpt

```asm
SetScratchPointer {
    TYX
    LDA [$0A]
    INC $0A
    INC $0A
    STA $animScratch, X
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $animScratch+2, X
    ...
    RTI
}
```

##### How it is used

Snake pit FX, laborer NPC setup, adrift ship effects — typically **`SetScratchPointer`** then **`ResetSpriteState`** / global anim load:

```asm
; extracted/angkor_wat/snake_pit/awB4_snake_pit_fx.asm (pattern)
COP [SetScratchPointer] ( @misc_fx_1CD380 )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand | 3-byte `Address` |
| WRAM | `$7F0000,X` word, `$7F0002,X` bank |
| Outcome | **Continue** |
