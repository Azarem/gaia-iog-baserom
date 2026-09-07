# Bank $00 — Thinkers: HDMA Wave Effects & Custom DMA

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00BCB3`–`$00BF19` (plus `$00B87B` angel tunnel DMA)  
**Block type:** `thinker_def` — background HDMA/DMA setup processes  
**Priority:** All thinkers in this family use priority `#08` (slot type `#04` for HDMA thinkers)  
**Related:** [`thinkers-palette.md`](thinkers-palette.md), [`thinkers-system.md`](thinkers-system.md), [`nmi-handler.md`](nmi-handler.md)

These thinkers configure SNES HDMA (Horizontal DMA) channels to produce sine-wave background oscillation, scroll-linked distortion, and custom PPU register DMA tables. The sine family shares COP helpers `InitSineHdma`, `TickSineHdma`, and `BindSineHdma` defined in the engine's COP handler bank.

---

## Overview

| Category | Count | Address Range |
|----------|-------|---------------|
| Sine HDMA wave effects | 11 | `$BCB3`–`$BF19` |
| Custom HDMA / DMA setup | 3 | `$BE39`, `$BCDF`, `$B87B` |
| Unused HDMA thinkers | 4 | `$BC97`, `$BDCA`, `$BEAA`, `$BF52` |

### Sine HDMA Pipeline

All sine-wave thinkers follow a common initialization pattern:

```
LDA #counter_init → $7F0008,X     ; frame counter seed
InitSineHdma (table_base, amplitude)
SetEntryExit                       ; re-enter each frame
[BranchIfFlagByte #FF == 0 → re-init]
TickSineHdma (speed, mode)
BindSineHdma (table_addr, channel)
RTL
```

WRAM sine tables typically reside at `$7E8800`, `$7E8C00`, `$7E8400`, or `$7E8000` depending on the thinker. HDMA channels `#0D`–`#10` and `#21` are used for BG scroll offsets, window positions, or color math registers.

---

## Sine HDMA Wave Effects

### sine_hdma_slow_wave

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00BE18` |
| **New Name** | `sine_hdma_slow_wave` |
| **Hex Address** | `$00BE18` |
| **Decimal Address** | 48664 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/thinkers/sine_hdma_slow_wave.asm` |

#### Purpose

Template sine HDMA thinker — the generic slow background oscillation used across many mid/late-game scenes. Initializes an 8-frame counter, builds a sine table at `$7E8800` with amplitude 40, ticks at speed `#01`, and binds channel `#0D`.

#### Parameters

| Parameter | Value |
|-----------|-------|
| Counter init | `#$0008` |
| Table base | `$7E8800` |
| Amplitude | 40 (`#28`) |
| Tick speed | `#01` |
| HDMA channel | `#0D` |

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Kress Maze / mid-game field | 37 (`thinker_0CE8BA`) | Water/distortion ambient |
| Late-game fields | 235–238 (`thinker_0CEB07`) | Dual ambient palette + slow wave |

#### Dependencies

None.

---

### sine_hdma_dual_channel

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00BE83` |
| **New Name** | `sine_hdma_dual_channel` |
| **Hex Address** | `$00BE83` |
| **Decimal Address** | 48771 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/seaside_palace/palace_coffins/sine_hdma_dual_channel.asm` |

#### Purpose

Dual-channel sine wave for Palace Coffins — faster tick (`#02`) with amplitude 8, binding both channels `#0F` and `#10` to `$7E8800` and `$7E8C00` respectively. Creates a more complex overlapping oscillation than the single-channel template.

#### Parameters

| Parameter | Value |
|-----------|-------|
| Counter init | `#$0002` |
| Amplitude | 8 |
| Tick speed | `#02` |
| HDMA channels | `#0F`, `#10` |

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Palace Coffins | 92 (`thinker_0CE96F` slot `#03`) | Coffin room water shimmer |
| Palace Coffins (alt layout) | 174 (`thinker_0CEA26` slot `#00`) | Standalone wave without coffin table |

#### Dependencies

None. Often paired with `palace_coffin_hdma_table` and `palace_scroll_brightness` in `thinker_0CE96F`.

---

### sine_hdma_ending_wave

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00BF19` |
| **New Name** | `sine_hdma_ending_wave` |
| **Hex Address** | `$00BF19` |
| **Decimal Address** | 48921 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/babel_tower/sine_hdma_ending_wave.asm` |

#### Purpose

Ending-region sine wave using amplitude 40, tick speed `#01`, channel `#0F`. Includes auxiliary code at `code_00BF3A` that sets thinker flag bit 0, calls `GenHdmaSine`, and queues HDMA — this subset was extracted into the unused `gen_hdma_sine_oneshot_unused`.

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Comet approach | 230–234 (`thinker_0CEAAC`) | Pre-Lair distortion |
| Comet Lair approach | 243 (`thinker_0CEAD3`) | Bundle `#3D` ambient + wave |
| Dark Space | 244–245 (`thinker_0CEAE0`, `thinker_0CEAED`) | Bundles `#79`, `#7B` |
| Dark Castoth Lair | 242 (`thinker_0CEAFA` slot `#01`) | Boss arena oscillation |

#### Dependencies

None. Contains inline helper `code_00BF3A` (not a separate thinker).

---

### ending_comet_sine_hdma

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00BCB3` |
| **New Name** | `ending_comet_sine_hdma` |
| **Hex Address** | `$00BCB3` |
| **Decimal Address** | 48307 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/ending/ending_comet/ending_comet_sine_hdma.asm` |

#### Purpose

Ending Comet approach sine wave with dual channels. Uses tick speed `#05` (fast), amplitude 8, channels `#0F` and `#10`. Zeroes `$7E8C30` and `$7E8E30` on init — clearing auxiliary table offsets for the comet's scrolling starfield effect.

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Ending Comet | 229 (`thinker_0CEA9B` slot `#02`) | Tim's comet flight sequence |

Paired with `ending_comet_dma_setup` (slot `#01`) and ambient palette bundle `#74`.

#### Dependencies

None.

---

### comet_lair_hdma_a

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00BCF5` |
| **New Name** | `comet_lair_hdma_a` |
| **Hex Address** | `$00BCF5` |
| **Decimal Address** | 48373 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/babel_tower/comet_lair/comet_lair_hdma_a.asm` |

#### Purpose

Comet Lair HDMA variant A — single channel `#10` bound to `$7E8C00`, tick speed `#05`, amplitude 8. Supports re-init via flag `#FF` gate (re-runs full init when flag is clear).

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Comet Lair | 232 (`thinker_0CEABA` slot `#03`) | Primary Lair distortion layer |

#### Dependencies

None.

---

### comet_lair_hdma_b

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00BD21` |
| **New Name** | `comet_lair_hdma_b` |
| **Hex Address** | `$00BD21` |
| **Decimal Address** | 48417 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/babel_tower/comet_lair/comet_lair_hdma_b.asm` |

#### Purpose

Comet Lair HDMA variant B — channel `#0F` bound to `$7E8400` (different WRAM base than variant A), counter init `#$0008`, tick speed `#05`, amplitude 8.

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Comet Lair | 232 (`thinker_0CEABA` slot `#04`) | Secondary Lair distortion layer |

#### Dependencies

None.

---

### comet_lair_hdma_c_timed

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00BD42` |
| **New Name** | `comet_lair_hdma_c_timed` |
| **Hex Address** | `$00BD42` |
| **Decimal Address** | 48450 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/babel_tower/comet_lair/comet_lair_hdma_c_timed.asm` |

#### Purpose

Timed transition HDMA for Comet Lair. Phase 1: standard sine on channel `#0D` at `$7E8400`. When flag `#01` is set, transitions to phase 2 (`code_00BD69`): reloads with amplitude 4, counts down `#$0070` (112) frames from `$7F0008,X`, then calls `SetEntryContinue` and stops — producing a gradual dampening of the wave effect during a story beat.

#### Algorithm

```
Phase 1: sine wave on #0D, wait for flag #01
Phase 2: reload amplitude 4, countdown 112 frames
         each frame: TickSineHdma #05 → BindSineHdma
         at zero: SetEntryContinue (thinker goes idle)
```

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Comet Lair | 232 (`thinker_0CEABA` slot `#05`) | Timed wave fade during Lair event |

#### Dependencies

None.

---

### larai_cliff_scroll_wave

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00BD96` |
| **New Name** | `larai_cliff_scroll_wave` |
| **Hex Address** | `$00BD96` |
| **Decimal Address** | 48534 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/incan_ruins/larai_cliff/larai_cliff_scroll_wave.asm` |

#### Purpose

Scroll-linked sine wave unique to Larai Cliff. Temporarily modifies scroll register `$06C0` by shifting `$0722` (subpixel scroll accumulator) right 4 bits into it before calling `TickSineHdma`, then restores the original `$06C0`. This ties the wave amplitude to camera scroll position, producing a parallax-linked distortion at the cliff edge.

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Larai Cliff | 29 (`thinker_0CE861` slot `#01`) | Cliff-edge water/wind distortion |

#### Dependencies

None. Reads `$06C0` and `$0722` (scroll state WRAM) directly.

---

### mu_tint_and_wave

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00BDCD` |
| **New Name** | `mu_tint_and_wave` |
| **Hex Address** | `$00BDCD` |
| **Decimal Address** | 48589 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/mu/mu_tint_and_wave.asm` |

#### Purpose

Combined COLDATA tint and dual-channel sine wave for Mu continent rooms. Selects green tint (`#$2A`/`#$44`) or alternate tint (`#$28`/`#$41`) based on flag `#7B`, then runs sine HDMA on channels `#0D` and `#0E` with tick speed `#03`.

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Mu rooms | 96–103 (`thinker_0CE98D` slot `#01`) | Eerie green Mu atmosphere with background oscillation |

#### Dependencies

None.

---

### dao_sine_hdma_slow

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00BED1` |
| **New Name** | `dao_sine_hdma_slow` |
| **Hex Address** | `$00BED1` |
| **Decimal Address** | 48849 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/dao/dao/dao_sine_hdma_slow.asm` |

#### Purpose

Slowest sine wave variant — tick speed `#00` (single-step per frame), amplitude 40, channel `#0D`. Counter init `#$0010` (16 frames). Creates a very gentle, almost imperceptible background sway for Dao Village's tranquil atmosphere.

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Dao Village | 195 (`thinker_0CEA6C` slot `#00`) | Subtle village ambient motion |

Paired with `dao_window_mask` (slot `#03`) in the same thinker set.

#### Dependencies

None.

---

### native_village_sine_hdma

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00BEF2` |
| **New Name** | `native_village_sine_hdma` |
| **Hex Address** | `$00BEF2` |
| **Decimal Address** | 48882 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/native_village/native_village/native_village_sine_hdma.asm` |

#### Purpose

Native Village (Amazon) sine wave with tick speed `#04`, amplitude 20, dual bind to channels `#0E` and `#10` both pointing at `$7E8C00`. The duplicate channel binding creates a doubled-amplitude effect on the same table.

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Native Village | 172 (`thinker_0CEA08` slot `#00`) | Jungle canopy sway |

#### Dependencies

None.

---

## Custom HDMA / DMA Setup

### palace_coffin_hdma_table

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00BE39` |
| **New Name** | `palace_coffin_hdma_table` |
| **Hex Address** | `$00BE39` |
| **Decimal Address** | 48697 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/seaside_palace/palace_coffins/palace_coffin_hdma_table.asm` |

#### Purpose

Builds a custom HDMA table at `$7E7000` rather than using the sine generator. Writes 16 entries of `#$0090`/`#$7100` (HDMA control + `$2171` BG scroll register target) to `$7E7000`, zeroes 16 words at `$7E7100`, then queues HDMA on channel `#21`. Rebuilds each frame when flag `#FF` is clear.

#### Algorithm

```
build 16×3-byte HDMA entries at $7E7000 → target $2171
zero 16 words at $7E7100
QueueHdma ($7E7000, #21)
SetEntryExit → SetFlagByte #FF → SetEntryContinue
QueueHdma again
if flag #FF clear → rebuild from top
```

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Palace Coffins | 92 (`thinker_0CE96F` slot `#00`) | Static HDMA scroll table for coffin room layout |

#### Dependencies

None.

---

### ending_comet_dma_setup

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00BCDF` |
| **New Name** | `ending_comet_dma_setup` |
| **Hex Address** | `$00BCDF` |
| **Decimal Address** | 48351 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/ending/ending_comet/ending_comet_dma_setup.asm` |

#### Purpose

One-shot DMA burst writing four PPU register values on scene entry. Queues DMA table `@dma_data_00BCE8` (4 entries × 3 bytes) targeting registers `#$70`, `#$10`, `#$01`, `#$01` — configuring `$VMADD`, `$VMAIN`, and related video port settings for the Ending Comet's bitmap mode display.

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Ending Comet | 229 (`thinker_0CEA9B` slot `#01`) | PPU init for comet flight |
| Comet Lair | 232 (`thinker_0CEABA` slot `#02`) | Shared DMA setup for Lair entry |

#### Dependencies

None.

---

### angel_tunnel_window_dma

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00B87B` |
| **New Name** | `angel_tunnel_window_dma` |
| **Hex Address** | `$00B87B` |
| **Decimal Address** | 47227 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/angel_village/angel_tunnel_rooms/angel_tunnel_window_dma.asm` |

#### Purpose

Configures SNES window registers for Angel Tunnel rooms via one-shot DMA. Writes two entries targeting `$6F` (WH0/WH1 window horizontal positions) and `$15` (WBGLOG window logic) with values `#$01`/`#$00` and `#$70`/`#$15`.

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Angel Tunnel rooms | 117 (`thinker_0CE9A3` slot `#01`) | Window masking for tunnel light beams |

#### Dependencies

None.

---

## Unused HDMA Thinkers

### dma_setup_variant_unused

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00BC97` |
| **New Name** | `dma_setup_variant_unused` |
| **Hex Address** | `$00BC97` |
| **Decimal Address** | 48279 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/unused/dma_setup_variant_unused.asm` |

#### Purpose

Variant of `ending_comet_dma_setup` with a 6-entry DMA table writing to registers `#$70`, `#$40`, `#$0C` (multiple `$210C`/`$2108` scroll offsets). No scene references — likely an earlier Ending Comet PPU configuration attempt.

#### Dependencies

None.

---

### empty_stub_unused

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00BDCA` |
| **New Name** | `empty_stub_unused` |
| **Hex Address** | `$00BDCA` |
| **Decimal Address** | 48586 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/unused/empty_stub_unused.asm` |
| **Size** | 3 bytes (RTL only) |

#### Purpose

Placeholder thinker containing only `RTL`. Reserves a thinker_def slot in bank $00 that was never populated. Possibly held space for a Larai Cliff or Mu variant that was merged into other thinkers.

#### Dependencies

None.

---

### native_village_dup_unused

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00BEAA` |
| **New Name** | `native_village_dup_unused` |
| **Hex Address** | `$00BEAA` |
| **Decimal Address** | 48810 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/unused/native_village_dup_unused.asm` |

#### Purpose

Byte-identical duplicate of `native_village_sine_hdma` at `$00BEF2`. Same counter init (`#$0004`), amplitude 20, tick `#04`, dual channel `#0E`/`#10` bind. Dead code — the live copy at `$BEF2` is referenced by scene 172.

#### Dependencies

None.

---

### gen_hdma_sine_oneshot_unused

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00BF52` |
| **New Name** | `gen_hdma_sine_oneshot_unused` |
| **Hex Address** | `$00BF52` |
| **Decimal Address** | 48978 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/unused/gen_hdma_sine_oneshot_unused.asm` |

#### Purpose

Extracted subset of `code_00BF3A` from `sine_hdma_ending_wave`. Sets `$0E` ← `#$0006`, counter ← `#$0005`, sets thinker flag bit 0, calls `GenHdmaSine`, queues HDMA on channel `#10`. Would have been a one-shot sine generation step, inlined back into the parent thinker during development.

#### Dependencies

None.

---

## HDMA Channel Map

| Channel | Thinkers | Target Effect |
|---------|----------|---------------|
| `#0D` | `sine_hdma_slow_wave`, `comet_lair_hdma_c_timed`, `larai_cliff_scroll_wave`, `mu_tint_and_wave`, `dao_sine_hdma_slow` | BG1 horizontal scroll offset |
| `#0E` | `mu_tint_and_wave`, `native_village_sine_hdma` | BG2 scroll / color math |
| `#0F` | `sine_hdma_dual_channel`, `sine_hdma_ending_wave`, `ending_comet_sine_hdma`, `comet_lair_hdma_b` | BG scroll / window |
| `#10` | `sine_hdma_dual_channel`, `ending_comet_sine_hdma`, `comet_lair_hdma_a`, `native_village_sine_hdma` | BG scroll / window |
| `#21` | `palace_coffin_hdma_table` | Custom `$2171` scroll table |

## Comet Lair Thinker Stack

Scene 232 (`thinker_0CEABA`) runs the full Comet Lair effect stack:

| Slot | Thinker | Role |
|------|---------|------|
| `#00` | `sE8_thinker_0CEB74` | Scene-specific Lair controller (bank `$0C`) |
| `#01` | `ambient_palette_cycler` (#71) | Eerie blue ambient |
| `#02` | `ending_comet_dma_setup` | PPU register init |
| `#03` | `comet_lair_hdma_a` | Wave layer A (channel `#10`) |
| `#04` | `comet_lair_hdma_b` | Wave layer B (channel `#0F`) |
| `#05` | `comet_lair_hdma_c_timed` | Timed fade wave (channel `#0D`) |
