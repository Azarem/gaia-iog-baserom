# Bank $02 — Hardware Math, VBlank, Decompression & System Init

*Part of the [Bank $02 Documentation Suite](README.md)*

> **Evidence labels.** Each major section is tagged with the kind of claim it makes: **[ASM]** = directly observed in the extracted asm of this block; **[INFERRED]** = interpretation of behavior that is not literally encoded in the file; **[XREF]** = cross-file / engine-wide convention stated elsewhere (not provable from this file alone). Sections that mix kinds split them into separately tagged bullets or paragraphs. The `.asm` files in `extracted/` are authoritative; where prose and asm comments disagree, the asm wins.

**Bank:** `$02` (FastROM; accessed via `$@` long calls from other banks)
**Address range:** `$028000`–`$0283A2`, `$029DE2`–`$02A040` (ROM addresses = `131072 + offset`; see `db-us/names/bank02.json` for decimal part starts)
**Source:** [`hardware_math.asm`](../../../extracted/system/engine/hardware_math.asm), [`vblank_joypad.asm`](../../../extracted/system/engine/vblank_joypad.asm), [`QuintetLzDecompress.asm`](../../../extracted/system/engine/QuintetLzDecompress.asm), [`system_init.asm`](../../../extracted/system/engine/system_init.asm)
**Block:** `hardware_math`, `vblank_joypad`, `QuintetLzDecompress`, `system_init` in `db-us/blocks.json` (scene: `engine`)

This page documents engine infrastructure in bank `$02`: SNES hardware multiply/divide wrappers, main-thread VBlank synchronization and joypad remapping, Quintet-LZ decompression, and boot-time WRAM/PPU setup plus per-frame palette/OAM DMA helpers. The `.asm` files are included from [`system_core.asm`](../../../extracted/system/engine/system_core.asm) (bank `$00`) and reached via `JSL $@…` from gameplay, scene loading, and overlay code.

**Related:** [`../bank00/system-core.md`](../bank00/system-core.md) (main loop and NMI) · [`../bank00/nmi-handler.md`](../bank00/nmi-handler.md) (NMI-side PPU/DMA, including `UploadCgramPalette` / `UploadOamTable`) · [`scene-script.md`](scene-script.md) (`QuintetLzDecompress` consumer) · [`../bank00/utility-math-movement.md`](../bank00/utility-math-movement.md) (bank `$00` movement math)

---

## Overview

*Evidence: [ASM] + [XREF]*

| Category | Parts (labels in asm) | ROM size (from part bounds) |
|----------|------------------------|-----------------------------|
| Hardware math | `MulDivide`, `Multiply8x8Unsigned`, `UnsignedDivide`, `SoftDivide_Unused`, `RngStep_Unused` | 218 bytes (`MulDivide` + `$0281D1`–`$0283A2` tail) |
| VBlank / joypad | `VBlankPartial`, `VBlankWaitAndJoypad`, `EnableNmiAndJoypad`, `DisableNmiKeepJoypad`, `ScreenBlackout`, `EnterForcedBlank`, `WaitFrames` | 406 bytes |
| Decompression | `QuintetLzDecompress`, `LzReadBitField`, `LzReadNibble` | 306 bytes |
| System init | `UploadCgramPalette`, `UploadOamTable`, `InitSystemVariables`, `SystemInitConstants`, `DmaFixedByteFill`, `InitHardwareRegisters`, `CacheSlotIndices`, `PpuRegisterInitTable` | 606 bytes |
| **Total (this document)** | **23** | **1,536 bytes** |

### ROM Layout (interleaved)

*Evidence: [ASM] + [XREF] (`db-us/names/bank02.json` part starts)*

```
$028000 ┌─ MulDivide ─────────────────────────────────────┐  hardware_math
$02803B ├─ VBlankPartial … WaitFrames ────────────────────┤  vblank_joypad
$0281D1 ├─ Multiply8x8Unsigned … RngStep_Unused ────────┤  hardware_math (ROM tail)
$028270 ├─ QuintetLzDecompress … LzReadNibble ────────────┤  QuintetLzDecompress
$0283A2 └─ (scene_script continues) ─────────────────────┘
        …
$029DE2 ┌─ UploadCgramPalette … PpuRegisterInitTable ───┐  system_init
$02A040 └─ (music_actors continues) ──────────────────────┘
```

---

## hardware_math.asm

*Evidence: [ASM]*

| Address | Name | Description |
|---------|------|-------------|
| `$028000` | MulDivide | **16×8 multiply then 16÷8 divide** via `$4202`–`$4217`: `(A low × Y) ÷ A high`, quotient in `A` (`RTL`). |
| `$0281D1` | Multiply8x8Unsigned | **8×8 unsigned multiply** via long-address `$80:4202`/`4203`; **16-bit product in `A`** (`RTL`). |
| `$0281E8` | UnsignedDivide | **16÷8 unsigned divide**: `Y` = dividend, `A` = divisor; **quotient low in A low, remainder in A high** (`RTL`). |
| `$0281FE` | SoftDivide_Unused | **Software divide** using DP scratch `$00`–`$06`; **`A` = divisor, `Y` = dividend** (`RTL`). No callers in extracted ROM. |
| `$028247` | RngStep_Unused | **Generator step** on WRAM state **`$0410`–`$041F`** (indexed via base `rngState` `$040F`); no callers (`RTL`). |

Hardware multiply needs **3 NOPs** (8 cycles) before reading `$4216`; divide needs **8 NOPs** (16 cycles) before reading `$4214` (per file header). **Divisor 0** on hardware divide yields **`$FFFF`** (header comment on `MulDivide` / hardware behaviour).

### MulDivide

*Evidence: [ASM] + [XREF] (call sites)*

Computes **(A low × Y) ÷ A high** using two 8×8 multiplies: `P1 = A low × Y low`, `P2 = A low × Y high`. The dividend written to `$4204`/`$4205` is **only the low 16 bits** of the product (`P1` plus `P2`’s low byte in the high byte of the dividend); carry and `P2`’s high byte are discarded. **`$4206` (`WRDIVB`)** receives **A high** (divisor). Returns **`LDA $4214` / `$4215` as 16-bit quotient in `A`** (`REP #$20` before read).

**Algorithm:**

| Step | Action | Effect |
|------|--------|--------|
| 1 | `STA $4202` (A low) | Multiplicand for both partial products |
| 2 | `XBA` / `PHA` | Save A high (divisor) |
| 3 | `TYA` / `STA $4203` | `Y` low → first multiply |
| 4 | `NOP` × 3, `LDY $4216` | Read `P1` |
| 5 | `STA $4203` (Y high) | Second multiply |
| 6 | Build `$4204`/`$4205` | 16-bit dividend |
| 7 | `PLA` / `STA $4206` | Start divide |
| 8 | `NOP` × 8 | Divide latency |
| 9 | `LDA $4214` / `RTL` | 16-bit quotient |

**Source:**

```42:78:../../../extracted/system/engine/hardware_math.asm
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
| `A` (input) | Input | Low byte = 8-bit multiplicand; high byte = 8-bit divisor |
| `Y` (input) | Input | 16-bit multiplicand |
| `$4202` / `$4203` | Write | Multiplier operands |
| `$4216` | Read | Partial product |
| `$4204` / `$4205` | Write | Dividend |
| `$4206` | Write | Divisor (triggers divide) |
| `$4214` | Read | Quotient low word |
| `A` (output) | Output | 16-bit quotient |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `ComputeScrollDeltas`, `ScrollCameraVertical` in [`camera_scroll.asm`](../../../extracted/system/engine/camera_scroll.asm) | Callers (`JSL $@hardware_math.MulDivide`) |
| [`scanline_band_hdma_thinker.asm`](../../../extracted/thinkers/scanline_band_hdma_thinker.asm) | Caller |
| [`layer1_scroll_actors.asm`](../../../extracted/actors/layer1_scroll_actors.asm) | Caller |

Convention (other file): bank `$00` exposes related movement scaling (`MultiplyThenDivide` in utility docs); register packing differs from this routine.

### Multiply8x8Unsigned

*Evidence: [ASM] + [XREF]*

**Input:** A low = first operand, A high = second operand (8-bit accumulator at entry). **Output:** 16-bit unsigned product in `A` — `LDA $804217`, `XBA`, `LDA $804216`, `RTL`. Uses **long addresses** so the multiply works regardless of current data bank. **Four NOPs** after writing `$4203`.

Callers include [`scene_script.asm`](../../../extracted/system/engine/scene_script.asm), [`map_coords.asm`](../../../extracted/system/engine/map_coords.asm), [`camera_tilemap.asm`](../../../extracted/system/engine/camera_tilemap.asm), [`tile_collision_physics.asm`](../../../extracted/system/engine/tile_collision_physics.asm), and [`player_character.asm`](../../../extracted/actors/player/player_character.asm) (grep `Multiply8x8Unsigned` in `extracted/`).

### UnsignedDivide

*Evidence: [ASM] + [XREF]*

**Input:** `STY $4204` (16-bit dividend), `STA $4206` (8-bit divisor). **Output:** after eight NOPs, `LDA $4216` (remainder) / `XBA` / `LDA $4214` (quotient low) — **quotient high byte is not returned**. Example caller: [`sg55_viper.asm`](../../../extracted/sky_garden/viper_lair/sg55_viper.asm).

### SoftDivide_Unused

*Evidence: [ASM] + [INFERRED]*

Software long division using **`PHD` / `TCD #$0000`** so scratch **`$00`–`$06`** maps to WRAM page zero. **Entry: `A` = divisor, `Y` = dividend** (asm comment). Normalizes the divisor in `A` by left shifts (`loc_028212`, count in `$00`, value in `$02`). Two trial-subtraction loops: first loop decrements `$00` and writes quotient bits to **`$06`**; second loop runs **`LDY #$0010`** times and writes bits to **`$04`**. Inferred: second pass may represent fractional bits (16.16 fixed-point), per asm comment “inferred”. **`PLD` / `RTL`**. No `JSL`/`JSR` to this label in extracted ROM.

**Algorithm:**

| Step | Action | Effect |
|------|--------|--------|
| 1 | `PHD` / `TCD #$0000` | DP → `$0000` scratch |
| 2 | Normalize divisor in `A` | Shift count `$00`, divisor `$02` |
| 3 | Loop 1 | Quotient bits → `$06` |
| 4 | Loop 2 (16 iter) | Bits → `$04` |
| 5 | `PLD` / `RTL` | Restore DP |

**Source:**

```130:192:../../../extracted/system/engine/hardware_math.asm
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

**Cross-References:** *(none — dead code in extracted ROM)*

### RngStep_Unused

*Evidence: [ASM] + [XREF]*

Standalone copy of the increment step that **`RngByte`** inlines elsewhere (`cop_handlers_movement`, per header). **State bytes updated: `$0410`–`$041F`**, using **`rngState` (`$040F`)** as the base for `ADC $040F,X` / `STA $040F,X` for **`X = $000F` down to `$0001`**. Then **`LDX #$0010`**: ripple **`INC $040F,X`** toward lower addresses until a byte does not wrap. Saves/restores `P`, `A`, `X`, `Y`. No callers in extracted ROM.

**Source:**

```199:230:../../../extracted/system/engine/hardware_math.asm
RngStep_Unused {
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
    ADC $rngState, X
    STA $rngState, X
    DEX
    BNE loc_028254
    LDX #$0010

  loc_028263:
    INC $rngState, X
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

**Cross-References:** *(none — dead code)*

---

## vblank_joypad.asm

*Evidence: [ASM] + [XREF] (NMI joypad store, main-loop order)*

| Address | Name | Description |
|---------|------|-------------|
| `$02803B` | VBlankPartial | Skips RDNMI wait; **`BRA loc_028057`** into shared Mode 7 + joypad path (`RTL`). |
| `$028043` | VBlankWaitAndJoypad | Poll **`$4210` (RDNMI)** until bit 7 set, then Mode 7 upload + joypad pipeline (`RTL`). |
| `$028191` | EnableNmiAndJoypad | **`$81` → `$4200` (NMITIMEN)** after reading RDNMI (`RTL`). |
| `$0281A2` | DisableNmiKeepJoypad | **`$01` → NMITIMEN** — NMI off, auto-joypad on (`RTL`). |
| `$0281AF` | ScreenBlackout | **`$00` → `$2100` (INIDISP)** — brightness 0, forced blank **off** (`RTL`). |
| `$0281BC` | EnterForcedBlank | **`$80` → INIDISP** — forced blank **on** (`RTL`). |
| `$0281C9` | WaitFrames | **`JSL VBlankWaitAndJoypad` / `DEC A` / `BNE`** loop (`RTL`). |

### VBlankPartial

*Evidence: [ASM] + [XREF]*

Saves **`P`** and **16-bit `A`** (`PHP`, `REP #$20`, `PHA`, `SEP #$20`), then branches to **`loc_028057`**. **Only caller in extracted ROM:** `UpdateFrameFull` in [`system_core.asm`](../../../extracted/system/engine/system_core.asm) (runs from NMI during blocking SPC music upload). Convention (other file): NMI has already stored fresh hardware data in **`joypadRaw` (`$0660`)** before this path runs.

### VBlankWaitAndJoypad

*Evidence: [ASM] + [XREF]*

**NMI wait:** Read **`$804210` (RDNMI)** before the loop, poll until bit 7 set, then one extra read (asm: does not change outcome after the poll read cleared the flag).

**Mode 7 upload:** If **`scrollModeFlags` (`$06EF`) bit `$08`** (bit 3), copy **`$C2`–`$CD`** to **`$211B`–`$2120`** (each register written twice: low byte, high byte). **`$CB` / `$CD`** high bytes **`AND #$1F`** before second write to **`M7X` / `M7Y`**. **`LDX $BE` / `STX $CE`**, **`LDX $C0` / `STX $D0`** — **X is not saved** (clobbered when this path runs).

**Joypad inject:** If **`joypadInject` (`$09AC`) ≠ 0**, copy to **`joypadCurrent` (`$0656`)**, clear **`$09AC`**, restore **`A`/`P`**, **`RTL`** — no remapping, no **`joypadHeld`** / repeat / **`joypadMaskStd`**; **`joypadRaw` unchanged**.

**Remapping:** Start from **`joypadRaw` AND `#$0F00`** into **`joypadRemapped` (`$065E`)**. For each **`remap*`** word **`$0DA6`–`$0DB4`**, if remap value non-zero and corresponding physical bit set in **`joypadRaw`**, **`TSB joypadRemapped`**. Physical bits (asm comment): Start `$1000`, Select `$2000`, B `$8000`, Y `$4000`, A `$0080`, X `$0040`, L `$0020`, R `$0010`. Defaults for face buttons may differ in this ROM after **`db-us/transforms.json`** (see **`SystemInitConstants`**).

**Consumption + output:** **`joypadRemapped` → `joypadCurrent` and → `joypadRaw`** (logical mask overwrites raw until next NMI stores JOY1L). **`joypadHeld` (`$0658`) AND= remapped** (keeps consumed bits still pressed). Auto-repeat: if result non-zero, **`AND joypadMaskInv` (`$065C`)**; if still non-zero, **`INC joypadRepeatCounter` (`$0662`)**; at **`CMP #$000C`**, **`TRB joypadHeld`** with **`joypadMaskInv`**. If no eligible held consumption, **`STZ joypadRepeatCounter`**. Finally **`TRB joypadCurrent`** with **`joypadHeld`**, then with **`joypadMaskStd` (`$065A`)**.

Convention (other file): **this routine does not read `$4218`**. NMI stores hardware **`JOY1L`** into **`joypadRaw`**. With NMI disabled between calls, remapping may run on an already-remapped **`joypadRaw`** (not idempotent for swapped mappings).

**Main-loop order** ([`system_core.asm`](../../../extracted/system/engine/system_core.asm) comment): **`VBlankWaitAndJoypad` → `DisableNmiKeepJoypad` → … logic … → `EnableNmiAndJoypad`**. Dialogue/render paths call **`EnableNmiAndJoypad` before `VBlankWaitAndJoypad`** then **`DisableNmiKeepJoypad`** after.

**Source:**

```101:261:../../../extracted/system/engine/vblank_joypad.asm
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
    LDA $scrollModeFlags
    BIT #$08
    BEQ loc_0280A6
    ...
    PLA
    PLP
    RTL
}
```

**Variables (WRAM / IO):**

| Symbol | Address | Role |
|--------|---------|------|
| `joypadCurrent` | `$0656` | Filtered output for game code |
| `joypadHeld` | `$0658` | Consumption mask (game sets bits with `TSB`) |
| `joypadMaskStd` | `$065A` | Unconditional suppress mask (`TRB` at end) |
| `joypadMaskInv` | `$065C` | Auto-repeat eligibility mask |
| `joypadRemapped` | `$065E` | Remap accumulator |
| `joypadRaw` | `$0660` | Hardware read (NMI) then overwritten with remapped value |
| `joypadRepeatCounter` | `$0662` | Repeat frame counter (threshold `$000C`) |
| `scrollModeFlags` | `$06EF` | Bit `$08` → Mode 7 upload |
| `joypadInject` | `$09AC` | One-shot script override |
| `remapR` … `remapSelect` | `$0DA6`–`$0DB4` | Per-button remap targets |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `MainLoop`, `UpdateFrameDialogue`, `UpdateFrameRender` | Callers ([`system_core.asm`](../../../extracted/system/engine/system_core.asm)) |
| `UpdateFrameFull` | Calls **`VBlankPartial`** |
| [`scene_lifecycle.asm`](../../../extracted/system/engine/scene_lifecycle.asm), [`GlobalInputHandler.asm`](../../../extracted/system/engine/GlobalInputHandler.asm), [`inventory_overlay.asm`](../../../extracted/system/inventory/inventory_overlay.asm) | Additional `VBlankWaitAndJoypad` call sites |
| `WaitFrames` | **`JSL VBlankWaitAndJoypad`** loop |
| [`spc_transfer.asm`](../../../extracted/system/engine/spc_transfer.asm) | Uses **`DisableNmiKeepJoypad` / `EnableNmiAndJoypad`** around port I/O |

### EnableNmiAndJoypad / DisableNmiKeepJoypad / ScreenBlackout / EnterForcedBlank / WaitFrames

*Evidence: [ASM]*

| Routine | Effect |
|---------|--------|
| `EnableNmiAndJoypad` | Read RDNMI; **`STA $804200` with `#$81`** |
| `DisableNmiKeepJoypad` | **`STA $804200` with `#$01`** |
| `ScreenBlackout` | **`STA $802100` with `#$00`** |
| `EnterForcedBlank` | **`STA $802100` with `#$80`** |
| `WaitFrames` | **`JSL $@VBlankWaitAndJoypad`**, **`DEC`**, **`BNE WaitFrames`**, **`RTL`** — **`A = 0` waits 256 frames** (8-bit); asm notes 65536 if A were 16-bit |

---

## QuintetLzDecompress.asm

*Evidence: [ASM] + [XREF]*

| Address | Name | Description |
|---------|------|-------------|
| `$028270` | QuintetLzDecompress | Quintet-LZ decompress to bank **`$7E`** (`RTL`). |
| `$0282DE` | LzReadBitField | Read **8 bits** from bitstream (`RTS`). |
| `$02833B` | LzReadNibble | Read **4-bit** length nibble (`RTS`). |

### QuintetLzDecompress

*Evidence: [ASM] + [XREF]*

Sets **`DBR = $7E`**. Dictionary page **`$7E:0200`–`02FF`**: initialize all **256** bytes to **`#$20`**, then set write pointer **`$74` = `$EF`**. Bit mask **`$72` = `$80`**. **`LDX $7A`**, **`LDY $78`** (output pointer and byte count). Source **`[$3E]`** with bank byte **`$40`** (24-bit pointer; asm: **`INC $3E`/`$3F` only** — stream must not cross a bank boundary).

Main loop: read control bit from **`[$3E] AND $72`**; shift **`$72` right**; when carry set after shift, **`ROR $72`** reloads **`$80`** and advances **`$3E`/`$3F`**.

- **Bit nonzero (literal):** **`JSR LzReadBitField`**, **`STA $0000,X`**, **`STA ($74)`**, **`INC $74`**, **`DEY`**, loop if **`Y ≠ 0`**.
- **Bit zero (back-reference):** index → **`$76`**, **`LzReadNibble`**, **`INC` ×2** (copy length = nibble + 2), copy loop from **`($76)`** to **`($74)`** and **`$0000,X`**.

Preserves **`P`, B, X, Y`**; **`A` not preserved**. **`$7E:0200`–`02FF`** overlaps the depth-sort bucket array (asm: callers should run **`ClearActorRenderList`** after decompress — e.g. scene load / Decompress COP).

**Caller preset:** **`$78`** = output byte count (**`Y = 0` → 65536 bytes**, per asm), **`$7A`** = output offset in **`$7E`**, **`$3E`/`$3F`/`$40`** = compressed data pointer (past 2-byte size header).

**Source:**

```48:124:../../../extracted/system/engine/QuintetLzDecompress.asm
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
  ...
    RTL
}
```

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| [`scene_script.asm`](../../../extracted/system/engine/scene_script.asm) | Primary caller (`JSL $@QuintetLzDecompress`) |
| [`cop_handlers_vram.asm`](../../../extracted/system/engine/cop_handlers_vram.asm) | Decompress COP |
| `LzReadBitField`, `LzReadNibble` | Callees |

### LzReadBitField

*Evidence: [ASM]*

Uses **`ASL`/`BMI` cascade** on **`$72`** to choose how many bits of the current source byte are consumed. **Fast path (`$72` bit 7 set):** **`LDA [$3E]`**, **`INC $3E`**, return byte in **`A`**. **Slow path:** read 16-bit word from **`[$3E]`**, **`XBA`**, enter **`ASL` fall-through** (`loc_02832E`–`034`) for 1–7 shifts, **`INC $3E`**, return aligned byte in **`A`**. **`RTS`** (caller must keep bitstream state in **`$72`**).

### LzReadNibble

*Evidence: [ASM]*

**If `$72` ≥ `$10`:** shift mask right 4, combine with current source byte, **`LSR` word** until one-hot mask bit exits carry; **`AND #$0F`**, **`RTS`** (pointer may not advance — asm high path).

**If `$72` < `$10`:** sub-paths for masks **`$08`**, **`$04`**, **`$02`**, **`$01`** — may reload **`$72`** to **`$80`/`$40`/`$20`/`$10`**, read next byte(s), **`INC $3E`** on straddle paths. Returns **4-bit length in `A`**; **`QuintetLzDecompress` adds 2** for copy count.

---

## system_init.asm

*Evidence: [ASM] + [XREF]*

| Address | Name | Description |
|---------|------|-------------|
| `$029DE2` | UploadCgramPalette | DMA **512 bytes** `$7F:0A00` → CGRAM; then 3× **`STA $2132`** from **`$7F:0C00`–`02`** (`RTL`). |
| `$029E1D` | UploadOamTable | DMA **544 bytes** from **`$0422`** → OAM **`$2104`** (`RTL`). |
| `$029E44` | InitSystemVariables | WRAM zero-fill + **`SystemInitConstants`** table (`RTL`). |
| `$029E85` | SystemInitConstants | **34** `(destination word, value word)` pairs + terminator (data; consumed by `InitSystemVariables`). |
| `$029F0F` | DmaFixedByteFill | Fixed-source DMA fill via **`$2180`** (`RTS`). |
| `$029F31` | InitHardwareRegisters | Walk **`PpuRegisterInitTable`** (`RTL`). |
| `$029F4E` | CacheSlotIndices | **4×3-byte** slot indices **`0…3`** (data). |
| `$029F5A` | PpuRegisterInitTable | **76** register writes + terminator (data). |

Boot vs VBlank (file header): **`InitHardwareRegisters`** and **`InitSystemVariables`** run once from **`SystemInit`**. **`UploadCgramPalette`** and **`UploadOamTable`** are **not boot-only** — **`NmiHandler`** calls them every VBlank (steps 5–6 in [`system_core.asm`](../../../extracted/system/engine/system_core.asm)); **`UploadCgramPalette`** is also called from [`camera_tilemap.asm`](../../../extracted/system/engine/camera_tilemap.asm) and [`inventory_overlay.asm`](../../../extracted/system/inventory/inventory_overlay.asm). Entry contract (header): **`A` 8-bit, X/Y 16-bit** (no `REP`/`SEP` for index registers inside upload routines).

### UploadCgramPalette

*Evidence: [ASM] + [XREF]*

**`STZ $2121` (CGADD)**. DMA channel 0: **`$4300 = 0`**, **`$4301 = $22`**, source **`$7F:0A00`**, size **`$0200`**, **`$420B = 1`**. Then three absolute loads **`$7F0C00`–`02`** → **`$2132` (COLDATA)**. **`PLP` / `RTL`**.

### UploadOamTable

*Evidence: [ASM] + [XREF]*

**`STX $2102` (OAMADDL) with X = 0**. DMA: **`$4301 = $04`**, source **`$00:0422`**, size **`$0220`**, trigger MDMAEN. **`RTL`**.

### InitSystemVariables

*Evidence: [ASM] + [XREF]*

Three **`JSR DmaFixedByteFill`** passes via WRAM port (**`$2181`/`$2183`** preset by caller):

| Pass | `WMADD` start | `Y` (size) | Coverage (asm header) |
|------|---------------|------------|------------------------|
| 1 | `$0000` | `$0100` | `$0000`–`$00FF` |
| 2 | `$0200` | `$FF00` | From `$0200` through **`$7F:00FF`** |
| 3 | (unchanged) | `$FF00` | Continues through **`$7F:FFFF`** |

Total **`$1FF00` bytes** cleared — **all 128 KB WRAM except stack page `$0100`–`$01FF`**. Fill byte is ROM **`math_lookup_tables.sine_table_8bit`** (sin(0) = **`$00`**).

Then loop **`SystemInitConstants`**: load destination word; **`BMI`** ends table; else **`TAY`**, load value word, **`STA $0000,Y`**, **`INX` ×4**. Requires **`DBR = $81`** during boot ( [`SystemInit`](../../../extracted/system/engine/system_core.asm) ) so **`STA $0000,Y`** hits WRAM.

**Cross-References:** **`SystemInit`** sole boot caller; **`DmaFixedByteFill`** callee ×3.

### SystemInitConstants

*Evidence: [ASM] + [INFERRED] (meanings of some values from file header comment)*

34 entries **`wram-init < dest, value >`** (`;00`–`;21`), then terminator (**negative destination word**). Table includes map/tilemap bases, collision pointers, **`$003A`/`$003C` → `scene_meta`**, RAM stub bytes **`$0402`/`$0406`**, **`$005E`/`$0060`/`$0062`**, gfx cache indices, **`remap*`** words (face-button defaults may match **`transforms.json`** rewrites), **`$0B14`**, **`inventoryEquippedIndex = $FFFF`**, **`$0B04 = 0`**.

**Source:** see [`system_init.asm`](../../../extracted/system/engine/system_init.asm) **`SystemInitConstants`** block (lines 204–239).

### DmaFixedByteFill

*Evidence: [ASM]*

**`STY $4305` (DAS0L)**. **`$4300 = $08`** (fixed source), **`$4301 = $80`** (B-bus **`$2180`** WRAM data port). Source **`math_lookup_tables.sine_table_8bit`** (bank in **`$4304`**, offset in **`$4302`**). **`$420B = 1`**. **`RTS`**. WRAM address continues across **`$7E`/`$7F`** banks between passes.

### InitHardwareRegisters

*Evidence: [ASM]*

**`LDX #0`**, loop: **`REP #$20`**, load **`PpuRegisterInitTable,X`** as address; **`BMI`** exit; **`TAY`**, **`SEP #$20`**, load value byte at **`+2,X`**, **`STA $0000,Y`**, **`INX` ×3**. Each entry is **`register-init < address word, value byte >`**, not an offset from `$2100`. Terminator: **negative address word**. Last entry **`MEMSEL = 0`** (asm: after **`SystemInit`** wrote **`MEMSEL = 1`**, this restores slow ROM until later code enables FastROM).

### CacheSlotIndices

*Evidence: [ASM] + [XREF]*

**`#000000010000020000030000`** — four 3-byte little-endian indices. **Reader:** **`RestoreCachedVram`** in [`scene_script.asm`](../../../extracted/system/engine/scene_script.asm) (VRAM cache ring **`$4000 + slot × $2000`**).

### PpuRegisterInitTable

*Evidence: [ASM] + [INFERRED] (register-name labels in header comment)*

76 **`register-init`** pairs **`;00`–`;4B`**: starts with **`MDMAEN`/`HDMAEN` = 0**, **`INIDISP = $80`**, OBJ/BG mode scroll/window/color registers through **`$2133`**, then **`NMITIMEN = 0`**, **`WRIO = $FF`**, math/timer registers, **`MEMSEL = 0`**. Duplicate rows (e.g. **`BG1HOFS` twice**) match **write-twice** SNES registers.

Full table: [`system_init.asm`](../../../extracted/system/engine/system_init.asm) lines 295–372.

---

### Key Call Chains

*Evidence: [XREF] (from [`system_core.asm`](../../../extracted/system/engine/system_core.asm) and file headers)*

```
Cold Start (SystemInit)
  ├── InitHardwareRegisters ← PpuRegisterInitTable
  ├── InitSystemVariables ← SystemInitConstants, DmaFixedByteFill
  ├── SpcLoadBuiltinEngine
  ├── EnterForcedBlank
  └── MainLoop:
        ├── VBlankWaitAndJoypad → DisableNmiKeepJoypad
        ├── … game logic …
        └── EnableNmiAndJoypad

NmiHandler (each VBlank)
  ├── UploadCgramPalette
  ├── UploadOamTable
  └── … (joypad store to joypadRaw, then other NMI work)

Scene load / COP (scene_script, cop_handlers_vram)
  └── QuintetLzDecompress ← LzReadBitField, LzReadNibble
        └── (callers: ClearActorRenderList after — dictionary overwrites $7E:0200 page)
```

---

## See Also

*Evidence: [XREF]*

| Document | Relationship |
|----------|--------------|
| [../bank00/system-core.md](../bank00/system-core.md) | Main loop, frame variants, cold-start sequence |
| [../bank00/nmi-handler.md](../bank00/nmi-handler.md) | NMI-side PPU/DMA (palette/OAM upload) |
| [../bank00/utility-math-movement.md](../bank00/utility-math-movement.md) | Bank `$00` movement math |
| [scene-script.md](scene-script.md) | `QuintetLzDecompress`, `Multiply8x8Unsigned`, VRAM cache |
| [camera-scrolling.md](camera-scrolling.md) | `MulDivide`, palette refresh |
| [game-systems.md](game-systems.md) | Frame update paths |
| [inventory-overlay.md](inventory-overlay.md) | `UploadCgramPalette`, VBlank sync |
| [README.md](README.md) | Bank `$02` document suite |
