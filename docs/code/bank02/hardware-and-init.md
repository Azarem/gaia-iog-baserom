# Bank $02 — Hardware Math, VBlank, Decompression & System Init

*Part of the [Bank $02 Documentation Suite](readme.md)*

**Bank:** `$02` (FastROM; accessed via `$@` long calls from other banks)
**Address range:** `$028000`–`$0283A2`, `$029DE2`–`$02A040`
**Source:** [`hardware_math.asm`](../../../extracted/system/engine/hardware_math.asm), [`vblank_joypad.asm`](../../../extracted/system/engine/vblank_joypad.asm), [`QuintetLzDecompress.asm`](../../../extracted/system/engine/QuintetLzDecompress.asm), [`system_init.asm`](../../../extracted/system/engine/system_init.asm)
**Block:** `hardware_math`, `vblank_joypad`, `QuintetLzDecompress`, `system_init` in `us/blocks.json` (scene: `engine`)

This page documents the lowest-level engine infrastructure in bank `$02`: SNES hardware multiply/divide wrappers, the main-thread VBlank synchronization and joypad polling layer, Quintet-LZ decompression, and cold-start WRAM/PPU initialization. These routines are included from [`system_core.asm`](../../../extracted/system/engine/system_core.asm) (bank `$00`) and called throughout gameplay, scene loading, and overlay code.

**Related:** [`../bank00/system-core.md`](../bank00/system-core.md) (main loop that calls VBlank/joypad routines) · [`../bank00/nmi-handler.md`](../bank00/nmi-handler.md) (NMI-side PPU/DMA) · [`scene-script.md`](scene-script.md) (primary `QuintetLzDecompress` consumer) · [`../bank00/utility-math-movement.md`](../bank00/utility-math-movement.md) (bank `$00` movement math helpers)

---

## Overview

| Category | Parts | Approx. Size |
|----------|-------|--------------|
| Hardware math | 5 | 218 bytes |
| VBlank / joypad | 7 | 406 bytes |
| Decompression | 3 | 306 bytes |
| System init | 8 | 606 bytes |
| **Total (this document)** | **23** | **1,536 bytes** |

### ROM Layout (interleaved)

```
$028000 ┌─ MulDivide ─────────────────────────────────────┐
$02803B ├─ VBlankPartial … WaitFrames ────────────────────┤  vblank_joypad
$0281D1 ├─ SignedMultiply … IncrementCounter_Unused ───────┤  hardware_math (part 2)
$028270 ├─ QuintetLzDecompress … LzReadBackRef ────────────┤  decompress
$0283A2 └─ (scene_script continues) ─────────────────────┘
        …
$029DE2 ┌─ UploadCgramPalette … ppu_register_init_table ──┐  system_init
$02A040 └─ (music_actors continues) ──────────────────────┘
```

---

## hardware_math.asm

| Address | Name | Description |
|---------|------|-------------|
| `$028000` | MulDivide | Performs a **16×8 multiply followed by an 8-bit divide** using the SNES hardware math unit at `$4202`–`$4217`. |
| `$0281D1` | SignedMultiply | Performs an **8×8 signed multiply** via `$WRMPYA`/`$WRMPYB` and returns the **16-bit product** in `A` (low byte in A after `XBA`, then high byte swapped in). |
| `$0281E8` | UnsignedDivide | Performs a **16÷8 unsigned divide** using the hardware divider. |
| `$0281FE` | SoftDivide_Unused | A **software 16÷16 fixed-point division** routine that operates entirely in direct-page scratch at `$00`–`$06`. |
| `$028247` | IncrementCounter_Unused | Increments a **128-bit (16-byte) big-endian counter** stored at WRAM `$040F`–`$041F`. |

### MulDivide


Performs a **16×8 multiply followed by an 8-bit divide** using the SNES hardware math unit at `$4202`–`$4217`. The routine computes `(A_low × Y) ÷ A_high`, returning the 16-bit quotient in `A`. The low byte of the 16-bit `A` input becomes the 8-bit multiplicand written to `$WRMPYA`; the high byte of `A` (saved on the stack) becomes the 8-bit divisor written to `$WRDIVB` after the 24-bit product is assembled in `$WRDIVL`/`$WRDIVH`. This is the bank `$02` counterpart to the movement math in bank `$00` (`MultiplyThenDivide`), but with a different register layout: callers pass a 16-bit scale factor in `A` (low = multiplicand, high = divisor) and a 16-bit operand in `Y`. The eight `NOP` instructions after writing `$WRDIVB` provide the mandatory pipeline delay before reading `$RDDIVL`. Used for camera scroll delta computation (`ComputeScrollDeltas` in [`camera_scroll.asm`](../../../extracted/system/engine/camera_scroll.asm)), parallax scrolling (`parallax_thinker.asm`), and visual-effect coordinate scaling (`visual_effect_pipeline.asm`).

**Algorithm:**

| Step | Action | Effect |
|------|--------|--------|
| 1 | `STA $WRMPYA` (A low byte) | First multiplicand |
| 2 | `XBA` / `PHA` | Save A high byte (future divisor) |
| 3 | `TYA` / `STA $WRMPYB` | Multiply A_lo × Y_lo |
| 4 | `NOP` × 3, `LDY $RDMPYL` | Read partial product |
| 5 | `STA $WRMPYB` (Y high) | Multiply A_lo × Y_hi |
| 6 | Build `$WRDIVL`/`$WRDIVH` | 24-bit dividend from both products |
| 7 | `PLA` / `STA $WRDIVB` | Divisor = A high byte |
| 8 | `NOP` × 8 | Divider pipeline delay |
| 9 | `LDA $RDDIVL` / `RTL` | Return 16-bit quotient |

**Source:**

```17:53:../../../extracted/system/engine/hardware_math.asm
MulDivide {
    SEP #$20
    STA $WRMPYA
    XBA
    PHA
    REP #$20
    TYA
    SEP #$20
    STA $WRMPYB
    XBA
    NOP
    NOP
    NOP
    LDY $RDMPYL
    STA $WRMPYB
    REP #$20
    TYA
    SEP #$20
    STA $WRDIVL
    XBA
    CLC
    ADC $RDMPYL
    STA $WRDIVH
    PLA
    STA $WRDIVB
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    REP #$20
    LDA $RDDIVL
    RTL
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `A` (input) | Input | 16-bit value: low byte = multiplicand, high byte = divisor |
| `Y` (input) | Input | 16-bit multiplier |
| `$WRMPYA` / `$WRMPYB` | Write | Hardware multiplier operands |
| `$RDMPYL` | Read | Partial product bytes |
| `$WRDIVL` / `$WRDIVH` | Write | 24-bit dividend |
| `$WRDIVB` | Write | 8-bit divisor |
| `$RDDIVL` | Read | Quotient low word |
| `A` (output) | Output | 16-bit quotient |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `ComputeScrollDeltas` | Caller — scroll delta from player offset × scroll factor |
| `ScrollCameraVertical` | Caller — vertical scroll scaling |
| `parallax_thinker.asm` | Caller — parallax layer offset |
| `visual_effect_pipeline.asm` | Caller — effect coordinate scaling |

### SoftDivide_Unused


A **software 16÷16 fixed-point division** routine that operates entirely in direct-page scratch at `$00`–`$06`. Sets `TCD` to `$0000` so direct-page offsets map to WRAM `$0000`–`$00FF`. Normalizes the dividend via bit-shifting (`loc_028212`), then performs two 16-iteration restore/subtract loops producing quotient bits in `$06` and remainder bits in `$04`. No `JSL`/`JSR` references to this routine exist anywhere in the extracted ROM. It is retained in the binary but unreachable from active code paths. The algorithm resembles a binary long-division implementation for cases where the hardware divider's 8-bit divisor limit is insufficient.

**Algorithm:**

| Step | Action | Effect |
|------|--------|--------|
| 1 | `PHD` / `TCD #$0000` | Direct page → WRAM `$0000` |
| 2 | Normalize `$00` shift count, `$02` divisor | Left-shift dividend until negative |
| 3 | Loop 1 (16 iter) | Restore/subtract → quotient bits in `$06` |
| 4 | Loop 2 (16 iter) | Second pass → bits in `$04` |
| 5 | `PLD` / `RTL` | Restore direct page |

**Source:**

```87:149:../../../extracted/system/engine/hardware_math.asm
SoftDivide_Unused {
    PHD
    PHA
    LDA #$0000
    TCD
    PLA
    STZ $00
    STZ $02
    STZ $04
    STZ $06
    CMP #$0000
    BMI loc_028217

  loc_028212:
    INC $00
    ASL
    BPL loc_028212

  loc_028217:
    STA $02
    TYA
    LDY #$0010
    CLC

  loc_02821E:
    BCS loc_028224
    CMP $02
    BCC loc_028227

  loc_028224:
    SBC $02
    SEC

  loc_028227:
    ROL $06
    DEC $00
    BMI loc_028231
    ASL
    DEY
    BNE loc_02821E

  loc_028231:
    ASL
    LDY #$0010
    CLC

  loc_028236:
    BCS loc_02823C
    CMP $02
    BCC loc_02823F

  loc_02823C:
    SBC $02
    SEC

  loc_02823F:
    ROL $04
    ASL
    DEY
    BNE loc_028236
    PLD
    RTL
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `A` (input) | Input | Dividend (16-bit) |
| `Y` (input) | Input | Divisor (16-bit) |
| `$00` | Scratch | Normalization shift count |
| `$02` | Scratch | Normalized divisor |
| `$04` | Output | Remainder/secondary quotient bits |
| `$06` | Output | Primary quotient bits |
| Direct page | Temp | `TCD #$0000` for the duration of the routine |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| *(none)* | No callers — dead code |

### IncrementCounter_Unused


Increments a **128-bit (16-byte) big-endian counter** stored at WRAM `$040F`–`$041F`. The first loop (`loc_028254`) propagates carry through bytes `$0410`–`$041F` using `ADC` with `$040F,X` as the base. The second loop (`loc_028263`) performs a simple `INC` cascade from `$040F` upward until a non-zero byte is found or 16 bytes are processed. No references to this routine exist in the extracted codebase. The counter location `$040F` is not associated with any active gameplay system in current documentation.

**Algorithm:**

| Step | Action | Effect |
|------|--------|--------|
| 1 | Save `P`, `A`, `X`, `Y` | Standard entry prologue |
| 2 | Loop `$040F`–`$041F` with carry | Big-endian add-with-carry |
| 3 | Loop `$040F`+ cascade `INC` | Propagate increment until byte ≠ 0 |
| 4 | Restore registers / `RTL` | Return |

**Source:**

```151:182:../../../extracted/system/engine/hardware_math.asm
IncrementCounter_Unused {
    PHP
    SEP #$20
    PHA
    PHX
    PHY
    LDX #$000F
    LDA #$00
    XBA
    CLC

  loc_028254:
    LDA $0410, X
    ADC $040F, X
    STA $040F, X
    DEX
    BNE loc_028254
    LDX #$0010

  loc_028263:
    INC $040F, X
    BNE loc_02826B
    DEX
    BNE loc_028263

  loc_02826B:
    PLA
    PLY
    PLX
    PLP
    RTL
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$040F`–`$041F` | Read/Write | 128-bit counter (big-endian) |
| `A`, `X`, `Y` | Saved/restored | Caller registers preserved via stack |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| *(none)* | No callers — dead code |

## vblank_joypad.asm

| Address | Name | Description |
|---------|------|-------------|
| `$02803B` | VBlankPartial | Lightweight VBlank entry that **skips the NMI wait loop** and jumps directly into the post-VBlank portion of `VBlankWaitAndJoypad` at `loc_028057`. |
| `$028043` | VBlankWaitAndJoypad | The **primary main-thread VBlank synchronization and joypad handler**. |
| `$028191` | EnableNmiAndJoypad | Enables **NMI and auto-joypad polling** by writing `$81` to `$L_NMITIMEN` (`$4200`). |
| `$0281A2` | EnableNmiOnly | Enables **NMI only** (no auto-joypad) by writing `$01` to `$L_NMITIMEN`. |
| `$0281AF` | ScreenBlackout | Releases forced blank but sets brightness to zero — screen appears black but PPU remains active. Writes `$00` to `$L_INIDISP` (`$2100`). |
| `$0281BC` | EnterForcedBlank | Enables SNES forced blank — PPU halted, VRAM/OAM/CGRAM accessible for DMA transfers. Writes `$80` to `$L_INIDISP`. |
| `$0281C9` | WaitFrames | Waits **A frames** by calling `VBlankWaitAndJoypad` in a decrement loop. |

### VBlankWaitAndJoypad


The **primary main-thread VBlank synchronization and joypad handler**. Called at the start and end of every main-loop frame in `SystemInit` (`loc_0080B5`), as well as from dialogue/render frame paths and scene-transition code. Performs four major duties: 1. **NMI wait** — Polls `$L_RDNMI` (`$4210`) until bit 7 is set, indicating vertical blank has begun. A dummy read clears the NMI flag before the wait loop. 2. **Mode 7 matrix upload** — When `$06EF` bit `$08` is set, writes the 14-byte Mode 7 parameter block from `$C2`–`$CD` to PPU registers `$211B`–`$2120` (double-written for latch timing). 3. **Joypad injection bypass** — If `$09AC` is non-zero, copies its value to `$0656` (current-frame joypad), clears `$09AC`, and returns early without reading hardware. 4. **Joypad read + remapping + auto-repeat** — Reads raw state from `$0660`, applies per-button remapping masks from `$0DA6`–`$0DB4` based on which buttons are held, stores the filtered result in `$0656`/`$065E`, and implements auto-repeat via `$0658` (held bits), `$0662` (frame counter), and `$joypad_mask_inv` (cleared after 12 frames). The main loop pattern is: `VBlankWaitAndJoypad` → game logic → `EnableNmiOnly` at frame start; `EnableNmiAndJoypad` at frame end. This ensures NMI fires during VBlank while game logic runs with NMI disabled.

**Algorithm:**

| Step | Action | Effect |
|------|--------|--------|
| 1 | Poll `$L_RDNMI` until VBlank (bit 7 set) | Frame sync |
| 2 | If `$06EF` bit `$08`: upload `$C2`–`$CD` → Mode 7 regs | Affine BG matrix |
| 3 | If `$09AC` ≠ 0: `$0656` ← `$09AC`, clear, return | Injected input |
| 4 | Read `$0660`, apply remap masks → `$065E` | Button remapping |
| 5 | Auto-repeat: increment `$0662`, at 12 frames clear `$0658` | Held-button repeat |
| 6 | `$0656` ← filtered state; mask with `$0658`/`joypad_mask_std` | Final joypad output |
| 7 | Restore stack / `RTL` | Return to caller |

**Source:**

```25:185:../../../extracted/system/engine/vblank_joypad.asm
VBlankWaitAndJoypad {
    PHP
    REP #$20
    PHA
    SEP #$20
    LDA $L_RDNMI

  loc_02804D:
    LDA $L_RDNMI
    BPL loc_02804D
    LDA $L_RDNMI

  loc_028057:
    LDA $06EF
    BIT #$08
    BEQ loc_0280A6
    LDA $C2
    STA $M7A
    LDA $C3
    STA $M7A
    LDA $C4
    STA $M7B
    LDA $C5
    STA $M7B
    LDA $C6
    STA $M7C
    LDA $C7
    STA $M7C
    LDA $C8
    STA $M7D
    LDA $C9
    STA $M7D
    LDA $CA
    STA $M7X
    LDA $CB
    AND #$1F
    STA $M7X
    LDA $CC
    STA $M7Y
    LDA $CD
    AND #$1F
    STA $M7Y
    LDX $BE
    STX $CE
    LDX $C0
    STX $D0

  loc_0280A6:
    REP #$20
    LDA $09AC
    BEQ loc_0280B6
    STA $0656
    STZ $09AC
    PLA
    PLP
    RTL

  loc_0280B6:
    LDA $0660
    AND #$0F00
    STA $065E
    LDA $0DB2
    BEQ loc_0280D2
    LDA $0660
    BIT #$1000
    BEQ loc_0280D2
    LDA $0DB2
    TSB $065E

  loc_0280D2:
    LDA $0DB4
    BEQ loc_0280E5
    LDA $0660
    BIT #$2000
    BEQ loc_0280E5
    LDA $0DB4
    TSB $065E

  loc_0280E5:
    LDA $0DAA
    BEQ loc_0280F8
    LDA $0660
    BIT #$8000
    BEQ loc_0280F8
    LDA $0DAA
    TSB $065E

  loc_0280F8:
    LDA $0DAE
    BEQ loc_02810B
    LDA $0660
    BIT #$4000
    BEQ loc_02810B
    LDA $0DAE
    TSB $065E

  loc_02810B:
    LDA $0DAC
    BEQ loc_02811E
    LDA $0660
    BIT #$0080
    BEQ loc_02811E
    LDA $0DAC
    TSB $065E

  loc_02811E:
    LDA $0DB0
    BEQ loc_028131
    LDA $0660
    BIT #$0040
    BEQ loc_028131
    LDA $0DB0
    TSB $065E

  loc_028131:
    LDA $0DA8
    BEQ loc_028144
    LDA $0660
    BIT #$0020
    BEQ loc_028144
    LDA $0DA8
    TSB $065E

  loc_028144:
    LDA $0DA6
    BEQ loc_028157
    LDA $0660
    BIT #$0010
    BEQ loc_028157
    LDA $0DA6
    TSB $065E

  loc_028157:
    LDA $065E
    STA $0656
    STA $0660
    AND $0658
    STA $0658
    BEQ loc_02817F
    AND $joypad_mask_inv
    BEQ loc_02817F
    LDA $0662
    INC
    STA $0662
    CMP #$000C
    BNE loc_028182
    LDA $joypad_mask_inv
    TRB $0658

  loc_02817F:
    STZ $0662

  loc_028182:
    LDA $0658
    TRB $0656
    LDA $joypad_mask_std
    TRB $0656
    PLA
    PLP
    RTL
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$L_RDNMI` | Read | NMI/VBlank status (bit 7 = in VBlank) |
| `$06EF` | Read | Scene flags; bit `$08` = Mode 7 active |
| `$C2`–`$CD` | Read | Mode 7 matrix + center coordinates |
| `$BE`, `$C0` | Read | Saved scroll values → `$CE`, `$D0` |
| `$09AC` | Read/Write | Injected joypad override (non-zero = skip hardware read) |
| `$0660` | Read/Write | Raw/auto-read joypad state |
| `$0656` | Output | Current-frame filtered joypad bits |
| `$0658` | Read/Write | Held-button auto-repeat mask |
| `$065E` | Scratch | Remapped button accumulator |
| `$0662` | Read/Write | Auto-repeat frame counter (threshold `$000C`) |
| `$0DA6`–`$0DB4` | Read | Per-button remapping masks |
| `$joypad_mask_std` / `$joypad_mask_inv` | Read | Standard and inverted button masks |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SystemInit` (main loop) | Caller — every frame at `loc_0080B5` |
| `UpdateFrame_Dialogue` | Caller — dialogue frame path |
| `UpdateFrame_Render` | Caller — text overlay frame path |
| `chunk_038000.asm` | Caller — alternate frame handlers |
| `chunk_03BAE1.asm` | Caller — scene transition sequences |
| `inventory_overlay.asm` | Caller — inventory display sync |
| `spc_transfer.asm` | Indirect caller — via `WaitFrames` |
| `VBlankPartial` | Alternate entry — skips NMI wait, shares `loc_028057` tail |
| `WaitFrames` | Caller — frame delay loop |

## decompress.asm

| Address | Name | Description |
|---------|------|-------------|
| `$028270` | QuintetLzDecompress | Main entry point for **Quintet-LZ decompression**, the dictionary-based compression format used for all BG tile, tilemap, and sprite graphics in IOG. |
| `$0282DE` | LzReadBitField | Extracts a **variable-length bit field (1–8 bits)** from the compressed bitstream. |
| `$02833B` | LzReadBackRef | Decodes the **copy length for a back-reference** in the Quintet-LZ stream. |

### QuintetLzDecompress


Main entry point for **Quintet-LZ decompression**, the dictionary-based compression format used for all BG tile, tilemap, and sprite graphics in IOG. Sets `DBR` to `$7E` so output writes target WRAM bank `$7E`. Initializes a 256-byte sliding dictionary at `($74)` filled with `$20` (space character), sets the dictionary write pointer to `$EF`, and resets the bit accumulator at `$72` to `$80`. The decompression loop reads bits from the compressed stream at `[$3E]` (24-bit pointer in `$3E`/`$3F`/bank). When a **literal bit** is set, `LzReadBitField` extracts the next byte, writes it to both the output buffer `($74)` and `$0000,X` (direct-page mirror), and advances the dictionary pointer. When a **reference bit** is clear, `LzReadBitField` reads the dictionary index, `LzReadBackRef` reads the copy length, and a byte-copy loop duplicates from the dictionary ring buffer. Callers must preset: `$78` = output byte count, `$7A` = output write pointer (16-bit WRAM offset), and `$3E`/`$3F`/bank = compressed data source pointer. The scene script engine is the primary caller (10+ sites in [`scene_script.asm`](../../../extracted/system/engine/scene_script.asm)); COP handlers and retranslation patches also invoke it directly.

**Algorithm:**

| Step | Action | Effect |
|------|--------|--------|
| 1 | Set `DBR = $7E`; save `P`, `B`, `X`, `Y` | WRAM output bank |
| 2 | Fill dictionary `($74)` with `$20` × 256 bytes | Initialize sliding window |
| 3 | `$74` ← `$EF`, `$72` ← `$80` | Dictionary write ptr + bit buffer |
| 4 | `X` ← `$7A`, `Y` ← `$78` | Output pointer and byte count |
| 5 | Read next bit from `[$3E]` via `$72` | Bitstream decode |
| 6a | Bit = 1: read literal byte → output + dictionary | Literal path |
| 6b | Bit = 0: read index + length → copy from dictionary | Back-reference path |
| 7 | Loop until `Y` = 0 (all output bytes written) | Complete decompression |
| 8 | Restore registers / `RTL` | Return |

**Source:**

```5:81:../../../extracted/system/engine/decompress.asm
QuintetLzDecompress {
    PHP
    PHB
    PHX
    PHY
    SEP #$20
    LDA #$7E
    PHA
    PLB
    LDX #$0200
    STX $74
    STX $76
    LDA #$20

  loc_028283:
    STA ($74)
    INC $74
    BNE loc_028283
    LDA #$EF
    STA $74
    LDA #$80
    STA $72
    LDX $7A
    LDY $78

  loc_028295:
    LDA [$3E]
    AND $72
    PHA
    LSR $72
    BCC loc_0282A6
    ROR $72
    INC $3E
    BNE loc_0282A6
    INC $3F

  loc_0282A6:
    PLA
    BEQ loc_0282B9
    JSR $&LzReadBitField
    STA $0000, X
    INX
    STA ($74)
    INC $74
    DEY
    BNE loc_028295
    BRA loc_0282D9

  loc_0282B9:
    JSR $&LzReadBitField
    STA $76
    JSR $&LzReadBackRef
    INC
    INC

  loc_0282C3:
    XBA
    LDA ($76)
    INC $76
    STA ($74)
    INC $74
    STA $0000, X
    INX
    DEY
    BEQ loc_0282D9
    XBA
    DEC
    BNE loc_0282C3
    BRA loc_028295

  loc_0282D9:
    PLY
    PLX
    PLB
    PLP
    RTL
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$78` | Input | Output byte count (decompressed size) |
| `$7A` | Input | Output write pointer (16-bit WRAM offset) |
| `$3E` / `$3F` | Input | Compressed data source address (16-bit + bank byte) |
| `$72` | Read/Write | Bit accumulator for stream decode |
| `$74` | Read/Write | Dictionary write pointer (wraps at 256) |
| `$76` | Scratch | Dictionary read pointer for back-references |
| `$0000,X` | Write | Secondary output buffer (direct page, bank `$7E`) |
| `DBR` | Set to `$7E` | Output data bank for indirect writes |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `scene_script.asm` | Primary caller — all compressed graphics loaders |
| `cop_handlers_map.asm` | Caller — runtime decompression |
| `LzReadBitField` | Callee — variable-length bit/byte extraction |
| `LzReadBackRef` | Callee — back-reference length decode |

### LzReadBitField


Extracts a **variable-length bit field (1–8 bits)** from the compressed bitstream. Uses a cascade of `ASL`/`BMI` tests on the bit accumulator `$72` to determine how many bits remain in the current byte. When `$72` goes negative (bit 7 set before shift), fetches the next source byte from `[$3E]` and reloads the accumulator. The routine switches to 16-bit mode to read a word from the source when 6+ bits are needed, then shifts the result right by the appropriate count (1–7 positions depending on entry point) to isolate the requested field. Returns the extracted value in `A` (8-bit). Called for both literal byte reads (8 bits) and dictionary index reads (8 bits) within the main decompression loop.

**Algorithm:**

| Step | Action | Effect |
|------|--------|--------|
| 1 | Test `$72` via `ASL`/`BMI` cascade | Determine bits remaining (1–7) |
| 2 | If exhausted: read next byte from `[$3E]`, reload `$72` | Refill bit buffer |
| 3 | If 6+ bits needed: read word, shift to isolate field | Wide bit extraction |
| 4 | Advance `$3E`, return value in `A` | Field delivered to caller |

**Source:**

```83:170:../../../extracted/system/engine/decompress.asm
LzReadBitField {
    LDA $72
    BMI loc_028325
    ASL
    BMI loc_02831E
    ASL
    BMI loc_028317
    ASL
    BMI loc_028310
    ASL
    BMI loc_028309
    ASL
    BMI loc_028302
    ASL
    BMI loc_0282FB
    REP #$20
    LDA [$3E]
    XBA
    BRA loc_02832E

  loc_0282FB:
    REP #$20
    LDA [$3E]
    XBA
    BRA loc_02832F

  loc_028302:
    REP #$20
    LDA [$3E]
    XBA
    BRA loc_028330

  loc_028309:
    REP #$20
    LDA [$3E]
    XBA
    BRA loc_028331

  loc_028310:
    REP #$20
    LDA [$3E]
    XBA
    BRA loc_028332

  loc_028317:
    REP #$20
    LDA [$3E]
    XBA
    BRA loc_028333

  loc_02831E:
    REP #$20
    LDA [$3E]
    XBA
    BRA loc_028334

  loc_028325:
    LDA [$3E]
    REP #$20
    INC $3E
    SEP #$20
    RTS

  loc_02832E:
    ASL

  loc_02832F:
    ASL

  loc_028330:
    ASL

  loc_028331:
    ASL

  loc_028332:
    ASL

  loc_028333:
    ASL

  loc_028334:
    ASL
    INC $3E
    XBA
    SEP #$20
    RTS
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$72` | Read/Write | Bit accumulator |
| `$3E` / `$3F` | Read/Write | Compressed stream pointer (advanced on byte fetch) |
| `A` | Output | Extracted bit field (1–8 bits, zero-extended) |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `QuintetLzDecompress` | Sole caller — literal and index reads |
| `LzReadBackRef` | Sibling — uses same bitstream state |

### LzReadBackRef


Decodes the **copy length for a back-reference** in the Quintet-LZ stream. Examines the current state of the bit accumulator `$72` to determine how many length bits to read. Three paths exist based on the top bits of `$72`: - **`$72` ≥ `$10`:** Shift `$72` right by 4, read length bits inline from the next source byte(s) with variable right-shift. - **`$72` < `$10`, carry clear after first shift:** Reload `$72` to `$80`, read 4-bit length from next byte. - **Other paths:** Set `$72` to `$40`, `$20`, or `$10` and read 16-bit word with 1–3 left shifts to extract a 4-bit length nibble. Returns the length value in `A` (4-bit, 0–15). The caller (`QuintetLzDecompress`) adds 2 to this value (`INC` × 2) to get the actual copy count (minimum match length = 2 bytes).

**Algorithm:**

| Step | Action | Effect |
|------|--------|--------|
| 1 | Compare `$72` to `$10` | Choose decode path |
| 2a | `$72` ≥ `$10`: shift `$72` >> 4, read inline length bits | Fast path |
| 2b | Low `$72`: reload bit buffer, read from next byte(s) | Refill path |
| 3 | Extract 4-bit length nibble | Length 0–15 |
| 4 | `RTS` with length in `A` | Caller adds 2 for actual count |

**Source:**

```172:250:../../../extracted/system/engine/decompress.asm
LzReadBackRef {
    LDA $72
    CMP #$10
    BCC loc_02835D
    LSR
    LSR
    LSR
    LSR
    STA $72
    XBA
    LDA [$3E]
    XBA
    REP #$20
    LSR
    BCS loc_028357
    LSR
    BCS loc_028357
    LSR
    BCS loc_028357
    LSR

  loc_028357:
    SEP #$20
    XBA
    AND #$0F
    RTS

  loc_02835D:
    LSR
    BCS loc_02838E
    LSR
    BCS loc_028381
    LSR
    BCS loc_028375
    LDA #$80
    STA $72
    LDA [$3E]
    REP #$20
    INC $3E
    SEP #$20
    AND #$0F
    RTS

  loc_028375:
    LDA #$40
    STA $72
    REP #$20
    LDA [$3E]
    XBA
    ASL
    BRA loc_02839A

  loc_028381:
    LDA #$20
    STA $72
    REP #$20
    LDA [$3E]
    XBA
    ASL
    ASL
    BRA loc_02839A

  loc_02838E:
    LDA #$10
    STA $72
    REP #$20
    LDA [$3E]
    XBA
    ASL
    ASL
    ASL

  loc_02839A:
    INC $3E
    SEP #$20
    XBA
    AND #$0F
    RTS
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$72` | Read/Write | Bit accumulator (may be reloaded to `$80`/`$40`/`$20`/`$10`) |
| `$3E` / `$3F` | Read/Write | Compressed stream pointer |
| `A` | Output | 4-bit length nibble (0–15; caller adds 2) |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `QuintetLzDecompress` | Sole caller — back-reference length decode |
| `LzReadBitField` | Sibling — shares `$72` bitstream state |

## system_init.asm

| Address | Name | Description |
|---------|------|-------------|
| `$029DE2` | UploadCgramPalette | Uploads the **512-byte CGRAM palette** from WRAM `$7F:0A00` to the PPU color generator via DMA channel 0, then writes... |
| `$029E1D` | UploadOamTable | Uploads the **544-byte OAM (sprite) table** from WRAM `$00:0422` to PPU OAM via DMA channel 0. |
| `$029E44` | InitSystemVariables | Performs **cold-start WRAM initialization** in two phases. |
| `$029E85` | system_init_constants | A **34-entry initialization table** of `(WRAM address, value)` word pairs used by `InitSystemVariables`. |
| `$029F0F` | DmaFixedByteFill | Performs a **fixed-byte DMA fill** of WRAM using DMA channel 0 in fill mode (`$DMAP0 = $08`). |
| `$029F31` | InitHardwareRegisters | Loads **PPU and system register defaults** from the `ppu_register_init_table` during cold start. |
| `$029F4E` | cache_slot_indices | A **4-entry lookup table** of 32-bit slot indices (`0`, `1`, `2`, `3`) used by the scene graphics VRAM ring-buffer ca... |
| `$029F5A` | ppu_register_init_table | A **76-entry PPU register initialization table** consumed by `InitHardwareRegisters`. |

### UploadCgramPalette


Uploads the **512-byte CGRAM palette** from WRAM `$7F:0A00` to the PPU color generator via DMA channel 0, then writes three **fixed backdrop colors** to `$COLDATA` from `$7F:0C00`–`$7F:0C02`. Configures DMA in word mode (`$DMAP0 = $00`, `$BBAD0 = $22` for `$2122` CGRAM data port), source at `$7F:0A00`, transfer size `$0200` bytes. Called during cold start (via `SystemInit` frame path), scene palette reloads (`camera_tilemap.asm`), and inventory overlay entry (`inventory_overlay.asm`) when the display palette must be refreshed from WRAM.

**Algorithm:**

| Step | Action | Effect |
|------|--------|--------|
| 1 | `$CGADD` ← `$00` | Start at CGRAM address 0 |
| 2 | Configure DMA channel 0: word mode, dest `$2122` | CGRAM write port |
| 3 | Source `$7F:0A00`, size `$0200` | 512-byte palette |
| 4 | Trigger `$MDMAEN` | Execute DMA transfer |
| 5 | Write 3 bytes from `$7F:0C00`–`02` to `$COLDATA` | Fixed backdrop colors |
| 6 | `RTL` | Return |

**Source:**

```20:43:../../../extracted/system/engine/system_init.asm
UploadCgramPalette {
    PHP
    SEP #$20
    STZ $CGADD
    STZ $DMAP0
    LDA #$22
    STA $BBAD0
    LDX #$0A00
    STX $A1T0L
    LDA #$7F
    STA $A1B0
    LDX #$0200
    STX $DAS0L
    LDA #$01
    STA $MDMAEN
    LDA $7F0C00
    STA $COLDATA
    LDA $7F0C01
    STA $COLDATA
    LDA $7F0C02
    STA $COLDATA
    PLP
    RTL
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$7F:0A00` | Read (DMA) | 512-byte palette source |
| `$7F:0C00`–`$02` | Read | Fixed backdrop color bytes |
| `$CGADD` | Write | CGRAM address latch |
| `$COLDATA` | Write | Backdrop color register |
| DMA channel 0 | Config | `$4300`–`$4305`, triggered via `$420B` |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SystemInit` | Caller — HUD/palette refresh in main loop |
| `camera_tilemap.asm` | Caller — scene palette reload |
| `inventory_overlay.asm` | Caller — inventory palette upload |

### UploadOamTable


Uploads the **544-byte OAM (sprite) table** from WRAM `$00:0422` to PPU OAM via DMA channel 0. Configures DMA in word mode with destination `$2104` (OAM data write port), transfer size `$0220` (544 bytes = 128 sprites × 4 bytes + 32-byte extension). Called from `SystemInit` during the main loop's sprite composition phase to DMA the composed OAM buffer to the PPU each frame. (Address `$00:0422` is in low WRAM — the OAM shadow buffer composed by the engine each frame.)

**Algorithm:**

| Step | Action | Effect |
|------|--------|--------|
| 1 | `$OAMADDL` ← `$0000` | OAM address 0 |
| 2 | Configure DMA channel 0: word mode, dest `$2104` | OAM write port |
| 3 | Source `$00:0422`, size `$0220` | 544-byte OAM table |
| 4 | Trigger `$MDMAEN` / `RTL` | Execute transfer |

**Source:**

```46:63:../../../extracted/system/engine/system_init.asm
UploadOamTable {
    PHP
    LDX #$0000
    STX $OAMADDL
    STZ $DMAP0
    LDA #$04
    STA $BBAD0
    LDX #$0422
    STX $A1T0L
    LDA #$00
    STA $A1B0
    LDX #$0220
    STX $DAS0L
    LDA #$01
    STA $MDMAEN
    PLP
    RTL
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$00:0422` | Read (DMA) | OAM shadow buffer in WRAM |
| `$OAMADDL` | Write | OAM address latch |
| DMA channel 0 | Config | `$4300`–`$4305` |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SystemInit` | Caller — per-frame OAM DMA in main loop |

### InitSystemVariables


Performs **cold-start WRAM initialization** in two phases. First, three DMA fixed-byte fills zero large WRAM regions via `DmaFixedByteFill`: `$0000`–`$00FF` (256 bytes), then `$0200`–`$FFFF` twice (65280 bytes each pass, covering the bulk of low WRAM). Second, iterates the `system_init_constants` table, writing each `(address, value)` pair into WRAM until a terminator entry (address with bit 15 set) is encountered. Called once from `SystemInit` immediately after `InitHardwareRegisters` during cold start. Seeds joypad remapping masks, scene pointer defaults, scroll parameters, cache indices, and other global game-state variables.

**Algorithm:**

| Step | Action | Effect |
|------|--------|--------|
| 1 | `$WMADD` ← `$0000`, DMA fill `$0100` bytes | Zero `$0000`–`$00FF` |
| 2 | `$WMADD` ← `$0200`, DMA fill `$FF00` × 2 | Zero `$0200`–`$FFFF` |
| 3 | Loop `system_init_constants`: read word addr + word value | Seed WRAM variables |
| 4 | Stop when address word has bit 15 set (terminator) | End of init table |
| 5 | `RTL` | Return |

**Source:**

```66:99:../../../extracted/system/engine/system_init.asm
InitSystemVariables {
    PHP
    REP #$20
    LDA #$0000
    SEP #$20
    STA $WMADDH
    REP #$20
    STA $WMADDL
    LDY #$0100
    JSR $&DmaFixedByteFill
    LDA #$0200
    STA $WMADDL
    LDY #$FF00
    JSR $&DmaFixedByteFill
    LDY #$FF00
    JSR $&DmaFixedByteFill
    LDX #$0000

  loc_029E6F:
    LDA $@system_init_constants, X
    BMI loc_029E83
    TAY
    LDA $@system_init_constants+2, X
    STA $0000, Y
    INX
    INX
    INX
    INX
    BRA loc_029E6F

  loc_029E83:
    PLP
    RTL
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$WMADDL` / `$WMADDH` | Write | WRAM DMA destination address |
| `$0200`–`$FFFF` | Write (via DMA) | Bulk zero-fill target |
| `system_init_constants` | Read | 34-entry init table |
| `Y` | Temp | Target WRAM address for each constant |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SystemInit` | Sole caller — cold start |
| `DmaFixedByteFill` | Callee — WRAM zero-fill (3 calls) |
| `system_init_constants` | Data — init value table |

### system_init_constants


A **34-entry initialization table** of `(WRAM address, value)` word pairs used by `InitSystemVariables`. Each entry is 4 bytes: a 16-bit WRAM address followed by a 16-bit initial value. The loop terminates when the address word has bit 15 set (`BMI` on the loaded address). Entries initialize scroll/camera parameters (`$069E`–`$06B8`), scene meta pointers (`$003A`/`$003C` → `scene_meta`), joypad remapping masks (`$0DA6`–`$0DB4`), default joypad state (`$005E`–`$0062`), graphics cache indices (`$0648`/`$064A`), and various gameplay flags (`$0402`, `$0406`, `$0AC4`, `$0B04`, `$0B14`).

**Algorithm:**

Table is consumed sequentially by `InitSystemVariables`:

| Step | Action | Effect |
|------|--------|--------|
| 1 | Read word at `table+X` → address | Target WRAM location |
| 2 | If address bit 15 set → stop | Terminator entry |
| 3 | Read word at `table+X+2` → value | Initial value |
| 4 | `STA $0000,Y` where Y = address | Write to WRAM |
| 5 | `X += 4`, repeat | Next entry |

**Source:**

```102:137:../../../extracted/system/engine/system_init.asm
system_init_constants [
  const < #$069E, #$A000 >   ;00
  const < #$06A0, #$C000 >   ;01
  const < #$0080, #$C000 >   ;02
  const < #$0082, #$007F >   ;03
  const < #$06BA, #$1000 >   ;04
  const < #$06BC, #$1800 >   ;05
  const < #$06AE, #$2000 >   ;06
  const < #$06B0, #$2800 >   ;07
  const < #$06B2, #$3100 >   ;08
  const < #$06B4, #$3288 >   ;09
  const < #$06B6, #$3184 >   ;0A
  const < #$06B8, #$330C >   ;0B
  const < #$06AA, #$0000 >   ;0C
  const < #$06AC, #$0100 >   ;0D
  const < #$003A, &scene_meta >   ;0E
  const < #$003C, *scene_meta >   ;0F
  const < #$0402, #$548B >   ;10
  const < #$0406, #$60AB >   ;11
  const < #$005E, #$0000 >   ;12
  const < #$0060, #$0081 >   ;13
  const < #$0062, #$0000 >   ;14
  const < #$064A, #$0001 >   ;15
  const < #$0648, #$0404 >   ;16
  const < #$0DA8, #$0020 >   ;17
  const < #$0DA6, #$0010 >   ;18
  const < #$0DAA, #$8000 >   ;19
  const < #$0DAC, #$0080 >   ;1A
  const < #$0DAE, #$4000 >   ;1B
  const < #$0DB0, #$0040 >   ;1C
  const < #$0DB4, #$2000 >   ;1D
  const < #$0DB2, #$1000 >   ;1E
  const < #$0B14, #$003C >   ;1F
  const < #$0AC4, #$FFFF >   ;20
  const < #$0B04, #$0000 >   ;21
]
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| Entries `$069E`–`$06B8` | Output targets | Scroll/camera/limit defaults |
| `$003A` / `$003C` | Output targets | Scene meta table pointers |
| `$0DA6`–`$0DB4` | Output targets | Joypad remapping masks |
| `$005E`–`$0062` | Output targets | Joypad state defaults |
| `$0648` / `$064A` | Output targets | Graphics cache indices |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `InitSystemVariables` | Sole consumer — cold-start WRAM seeding |
| `scene_meta` | Referenced — scene metadata table pointer |
| `VBlankWaitAndJoypad` | Indirect — uses joypad masks initialized here |

### DmaFixedByteFill


Performs a **fixed-byte DMA fill** of WRAM using DMA channel 0 in fill mode (`$DMAP0 = $08`). The fill byte comes from a single-byte source at `scene_flag_table.sine_table_8bit` (a zero byte in the shared binary block). The destination is the current `$WMADDL`/`$WMADDH` address; the transfer size is passed in `Y` (16-bit byte count). Called three times by `InitSystemVariables` to zero WRAM regions during cold start. The `$BBAD0 = $80` setting selects fixed-byte mode where the same source byte is repeated for the entire transfer length.

**Algorithm:**

| Step | Action | Effect |
|------|--------|--------|
| 1 | `STY $DAS0L` | Transfer size in bytes |
| 2 | `$DMAP0` ← `$08` (fill mode), `$BBAD0` ← `$80` | Fixed-byte DMA config |
| 3 | Source ← `sine_table_8bit` (zero byte) | Fill value |
| 4 | Trigger `$MDMAEN` / `RTS` | Fill WRAM at `$WMADD` |

**Source:**

```140:156:../../../extracted/system/engine/system_init.asm
DmaFixedByteFill {
    PHP
    SEP #$20
    STY $DAS0L
    LDA #$08
    STA $DMAP0
    LDA #$80
    STA $BBAD0
    LDA #$^scene_flag_table.sine_table_8bit
    STA $A1B0
    LDX #$&scene_flag_table.sine_table_8bit
    STX $A1T0L
    LDA #$01
    STA $MDMAEN
    PLP
    RTS
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `Y` (input) | Input | DMA transfer byte count |
| `$WMADDL` / `$WMADDH` | Input (preset) | WRAM destination address |
| `sine_table_8bit` | Read | Single-byte fill value (zero) |
| DMA channel 0 | Config | Fill mode via `$4300`–`$4305` |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `InitSystemVariables` | Sole caller — 3 calls during WRAM zero-fill |

### InitHardwareRegisters


Loads **PPU and system register defaults** from the `ppu_register_init_table` during cold start. Iterates 3-byte entries: a register index byte and a 16-bit value word. Writes each value to the corresponding MMIO register at `$2100+index`. Terminates when the register index byte has bit 7 set (`BMI` test on the loaded index). Called as the first initialization step in `SystemInit`, before WRAM clearing and actor setup. Configures BG mode, screen settings, window masks, DMA enables, and all PPU layer control registers to their power-on gameplay defaults.

**Algorithm:**

| Step | Action | Effect |
|------|--------|--------|
| 1 | `X` ← 0 | Table index |
| 2 | Read byte at `table+X` → register index | Target MMIO register |
| 3 | If index bit 7 set → stop | Terminator |
| 4 | Read word at `table+X+1` → value | Register value |
| 5 | `STA $2100+index` | Write to PPU register |
| 6 | `X += 3`, repeat | Next entry |

**Source:**

```159:179:../../../extracted/system/engine/system_init.asm
InitHardwareRegisters {
    PHP
    LDX #$0000

  loc_029F35:
    REP #$20
    LDA $@ppu_register_init_table, X
    BMI loc_029F4C
    TAY
    SEP #$20
    LDA $@ppu_register_init_table+2, X
    STA $0000, Y
    INX
    INX
    INX
    BRA loc_029F35

  loc_029F4C:
    PLP
    RTL
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `ppu_register_init_table` | Read | 76-entry register init table |
| `$2100`–`$213F` | Write | PPU MMIO registers (via indexed addressing) |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SystemInit` | Sole caller — first init step after CPU setup |
| `ppu_register_init_table` | Data — register default values |

### ppu_register_init_table


A **76-entry PPU register initialization table** consumed by `InitHardwareRegisters`. Each entry is 3 bytes in `unk6` format: a 1-byte register index (offset from `$2100`) and a 2-byte value word. The low byte of the value word typically ends in `$21` (indicating a specific PPU register write pattern); entries with `$42` suffix are 8-bit register writes via the `$0042` type marker. The table configures: `$INIDISP` (forced blank initially), `$OBSEL` (OBJ tile format), all BG scroll/mode/control registers (`$2105`–`$210A`), `$BG1SC`/`$BG2SC` (tilemap base addresses), `$BG12NBA`/`$BG34NBA` (tile base addresses), `$BG1HOFS`/`$BG1VOFS` (scroll offsets), window mask settings, and `$CGWSEL`/`$CGADSUB` (color math). Duplicate entries for `$210D`/`$210E` suggest multi-byte register pairs written sequentially.

**Algorithm:**

Table is consumed sequentially by `InitHardwareRegisters` — see that routine for the iteration algorithm.

**Source:**

```185:262:../../../extracted/system/engine/system_init.asm
ppu_register_init_table [
  unk6 < #0B, #$0042 >   ;00
  unk6 < #0C, #$0042 >   ;01
  unk6 < #00, #$8021 >   ;02
  unk6 < #01, #$0221 >   ;03
  unk6 < #02, #$0021 >   ;04
  unk6 < #03, #$0021 >   ;05
  unk6 < #05, #$0921 >   ;06
  unk6 < #06, #$0021 >   ;07
  unk6 < #07, #$1121 >   ;08
  unk6 < #08, #$1921 >   ;09
  unk6 < #09, #$7821 >   ;0A
  unk6 < #0A, #$0021 >   ;0B
  unk6 < #0B, #$2221 >   ;0C
  unk6 < #0C, #$0621 >   ;0D
  unk6 < #0D, #$0021 >   ;0E
  unk6 < #0D, #$0021 >   ;0F
  unk6 < #0E, #$0021 >   ;10
  unk6 < #0E, #$0021 >   ;11
  unk6 < #0F, #$0021 >   ;12
  unk6 < #0F, #$0021 >   ;13
  unk6 < #10, #$0021 >   ;14
  unk6 < #10, #$0021 >   ;15
  unk6 < #11, #$0021 >   ;16
  unk6 < #11, #$0021 >   ;17
  unk6 < #12, #$0021 >   ;18
  unk6 < #12, #$0021 >   ;19
  unk6 < #13, #$0021 >   ;1A
  unk6 < #13, #$0021 >   ;1B
  unk6 < #14, #$0021 >   ;1C
  unk6 < #14, #$0021 >   ;1D
  unk6 < #15, #$8021 >   ;1E
  unk6 < #16, #$0021 >   ;1F
  unk6 < #17, #$0021 >   ;20
  unk6 < #1A, #$8021 >   ;21
  unk6 < #1B, #$0121 >   ;22
  unk6 < #1B, #$0021 >   ;23
  unk6 < #1C, #$0021 >   ;24
  unk6 < #1C, #$0021 >   ;25
  unk6 < #1D, #$0021 >   ;26
  unk6 < #1D, #$0021 >   ;27
  unk6 < #1E, #$0021 >   ;28
  unk6 < #1E, #$0021 >   ;29
  unk6 < #1F, #$0021 >   ;2A
  unk6 < #1F, #$0021 >   ;2B
  unk6 < #20, #$0021 >   ;2C
  unk6 < #20, #$0021 >   ;2D
  unk6 < #21, #$0021 >   ;2E
  unk6 < #23, #$3321 >   ;2F
  unk6 < #24, #$3321 >   ;30
  unk6 < #25, #$3321 >   ;31
  unk6 < #26, #$0021 >   ;32
  unk6 < #27, #$FF21 >   ;33
  unk6 < #28, #$0021 >   ;34
  unk6 < #29, #$0021 >   ;35
  unk6 < #2A, #$0021 >   ;36
  unk6 < #2B, #$0021 >   ;37
  unk6 < #2C, #$0421 >   ;38
  unk6 < #2D, #$0021 >   ;39
  unk6 < #2E, #$0021 >   ;3A
  unk6 < #2F, #$0021 >   ;3B
  unk6 < #30, #$8221 >   ;3C
  unk6 < #31, #$0021 >   ;3D
  unk6 < #32, #$E021 >   ;3E
  unk6 < #33, #$0021 >   ;3F
  unk6 < #00, #$0042 >   ;40
  unk6 < #01, #$FF42 >   ;41
  unk6 < #02, #$0042 >   ;42
  unk6 < #03, #$0042 >   ;43
  unk6 < #04, #$0042 >   ;44
  unk6 < #05, #$0042 >   ;45
  unk6 < #06, #$0042 >   ;46
  unk6 < #07, #$0042 >   ;47
  unk6 < #08, #$0042 >   ;48
  unk6 < #09, #$0042 >   ;49
  unk6 < #0A, #$0042 >   ;4A
  unk6 < #0D, #$0042 >   ;4B
]
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$2100` (`INIDISP`) | Write target | Display control — forced blank initially |
| `$2105`–`$210A` | Write targets | BG mode, mosaic, BG enables |
| `$2107`–`$2108` | Write targets | BG1/BG2 tilemap base addresses |
| `$210B`–`$210C` | Write targets | BG tile data base addresses |
| `$2115`–`$2116` | Write targets | BG1/BG2 scroll offsets |
| `$2123`–`$2125` | Write targets | Window mask settings |
| `$2130`–`$2133` | Write targets | Color math, screen mode |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `InitHardwareRegisters` | Sole consumer — cold-start PPU setup |


### Key Call Chains

```
Cold Start (SystemInit)
  ├── InitHardwareRegisters ← ppu_register_init_table
  ├── InitSystemVariables ← system_init_constants, DmaFixedByteFill
  ├── EnterForcedBlank
  └── Main loop:
        ├── VBlankWaitAndJoypad → EnableNmiOnly
        ├── … game logic …
        ├── UploadCgramPalette / UploadOamTable
        └── EnableNmiAndJoypad

Scene Load (scene_script)
  ├── SignedMultiply (offset math)
  └── QuintetLzDecompress ← LzReadBitField, LzReadBackRef
        └── DMA decompressed data to VRAM
```

## See Also

| Document | Relationship |
|----------|-------------|
| [../bank00/system-core.md](../bank00/system-core.md) | Main loop, frame variants, cold-start sequence |
| [../bank00/nmi-handler.md](../bank00/nmi-handler.md) | NMI-side PPU/DMA (complements VBlank wait here) |
| [../bank00/utility-math-movement.md](../bank00/utility-math-movement.md) | Bank `$00` movement math (parallel to `MulDivide`) |
| [scene-script.md](scene-script.md) | Primary consumer of `QuintetLzDecompress` and `SignedMultiply` |
| [camera-scrolling.md](camera-scrolling.md) | Consumer of `MulDivide`, `UploadCgramPalette` |
| [game-systems.md](game-systems.md) | Frame update paths using VBlank/joypad routines |
| [inventory-overlay.md](inventory-overlay.md) | Inventory overlay NMI/display sync |
| [index.md](readme.md) | Full bank `$02` memory map and document suite |
