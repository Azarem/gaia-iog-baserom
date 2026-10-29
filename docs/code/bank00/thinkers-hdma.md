# Bank $00 — Thinkers: HDMA Wave Effects & Custom DMA

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00BCB3`–`$00BF19` (sine family), plus custom setup through `$00B87B`  
**Block type:** `thinker_def` — background HDMA/DMA setup processes  
**Filter word:** HDMA thinkers use `thinker-def < #04, #08 >` → **`animScratch2 = $0804`** (bit 2 → `RunThinkers_Hdma` after `ResetHdmaState`; bit 11 → also runs in Light frame runners). This is **not** a scene-table “priority” byte — spawn-record byte 0 is the per-thinker parameter stored at `animScratch+2` (`$7F0002,X`).  
**Related:** [`thinkers-palette.md`](thinkers-palette.md), [`thinkers-system.md`](thinkers-system.md), [`nmi-handler.md`](nmi-handler.md)

These thinkers configure SNES HDMA channels for sine-wave BG scroll ripples, scroll-linked distortion, custom direct HDMA tables, and (in one case) window registers. The sine family shares COP helpers `InitSineHdma`, `TickSineHdma`, and `BindSineHdma` in the engine COP bank.

---

## Source of truth

Primary extracted files (paths relative to repo root):

| Role | Path |
|------|------|
| Scene spawn lists (scene ID = `$0646` index) | `extracted/tables/scene_thinkers.asm` |
| Sine / ending / comet / coffin thinkers | `extracted/thinkers/sine_hdma_slow_wave.asm`, `extracted/seaside_palace/palace_coffins/*.asm`, `extracted/ending/ending_comet/*.asm`, `extracted/babel_tower/sine_hdma_ending_wave.asm`, `extracted/babel_tower/comet_lair/*.asm`, `extracted/dao/dao/dao_sine_hdma_slow.asm`, `extracted/native_village/native_village/native_village_sine_hdma.asm`, `extracted/incan_ruins/larai_cliff/larai_cliff_scroll_wave.asm`, `extracted/mu/mu_tint_and_wave.asm` |
| Custom DMA / window | `extracted/angel_village/angel_tunnel_rooms/angel_tunnel_window_dma.asm` |
| **Dead / unreferenced** | `extracted/unused/dma_setup_variant_unused.asm`, `extracted/unused/empty_stub_unused.asm`, `extracted/unused/native_village_dup_unused.asm`, `extracted/unused/gen_hdma_sine_oneshot_unused.asm` |
| Dispatch / filter semantics | `extracted/system/engine/thinker_execution.asm` |
| HDMA COP implementation | `extracted/system/engine/cop_handlers_hdma_dma.asm`, `extracted/system/hdma_ramp_tables.asm` |

**Naming:** Section titles use extracted label names (e.g. `sine_hdma_slow_wave`). List labels like `thinker_spawn_0CE8BA` are **spawn-list addresses** in bank `$0C`, not scene IDs.

**Counts:** Scene placements below were counted from `scene_thinkers.asm` this session (static spawn records, including mid-list `+4`/`+8` offsets). Approximately **4** HDMA-related thinker bodies in `extracted/unused/` have **no** spawn record (**dead**). All other thinkers in this doc are **live** (referenced by at least one scene list or overlay scene ID).

---

## Overview

| Category | Live bodies | Notes |
|----------|-------------|--------|
| Generic sine HDMA (`InitSineHdma` / `TickSineHdma` / `BindSineHdma` loop) | 11 | Shared COP pipeline; parameters differ per thinker |
| Custom direct HDMA table build / queue | 2 | `palace_coffin_hdma_table`, `angel_tunnel_window_dma` |
| One-shot / single-queue PPU setup | 1 | `ending_comet_dma_setup` (`QueueHdmaDirect`, not VRAM DMA) |
| Dead / legacy (no scene reference) | 4 | See [Dead / legacy HDMA thinker bodies](#dead--legacy-hdma-thinker-bodies) |

### Sine HDMA pipeline (live thinkers)

```text
[optional init label]
  amplitude → $7F0008,X
  InitSineHdma ( WRAM_table_base_short, period_scanlines )
  SetEntryHereAndYield / SetEntryExit
  [optional BranchOnFlagByte #FF → re-init while scene setup incomplete]
  TickSineHdma ( phase_delay, camera_word_offset )
  BindSineHdma ( table_addr, hdma_channel_config_index )
  RTL
```

**Operand semantics** (from `sine_hdma_slow_wave.asm` block note, verified on other sine thinkers):

| Operand | Meaning |
|---------|---------|
| `$7F0008,X` | Wave **amplitude** (not the `#40` in `InitSineHdma`) |
| `InitSineHdma` `#$8800` | WRAM base `$7E8800` (short form) |
| `InitSineHdma` `#40` / `#08` / … | **Period** in scanlines per table entry, not amplitude |
| `BindSineHdma` `#0D` | `hdma_channel_config` entry → B-bus **`$210D` BG1HOFS** (horizontal ripple) |
| `BindSineHdma` `#0E`–`#10`, `#21` | Other entries in the same config table (BG2 scroll, custom `$2171`, etc.) |

WRAM sine tables commonly use `$7E8800`, `$7E8C00`, `$7E8400`, or `$7E8000`.

---

## Live sine HDMA thinkers

### `sine_hdma_slow_wave` — `$00BE18` · **live**

Slow horizontal BG1 ripple. Amplitude **8** (`#$0008` → `$7F0008,X`), period **64** (`InitSineHdma` `#40`), `TickSineHdma (#01,#02)`, `BindSineHdma ($7E8800,#0D)`. Re-inits while event flag **`#FF`** is clear.

| Scene ID | Spawn list | Slot | Notes |
|----------|------------|------|--------|
| `$32` (50) | `thinker_spawn_0CE8BA` | `#00` | Block note: Freejia |
| `$E9`, `$EA` (233–234) | `thinker_spawn_0CEB07` | `#00` | Mansion pair; also dual `ambient_palette_cycler` |

---

### `sine_hdma_dual_channel` — `$00BE83` · **live**

Dual bind: amplitude **2**, period **8**, `TickSineHdma (#02,#02)`, channels **`#0F`** + **`#10`** → `$7E8800` / `$7E8C00`. Flag **`#FF`** gate.

| Scene ID | Spawn list | Slot | Notes |
|----------|------------|------|--------|
| `$5C` (92) | `thinker_spawn_0CE96F` | `#03` | With `palace_coffin_hdma_table`, `palace_scroll_brightness` |
| `$5A`, `$5B` (90–91) | `thinker_spawn_0CE96F+8` | `#03`–`#04` | Enters list after coffin table + scanline band |
| `$6F` (111) | `thinker_spawn_0CEA26` | `#00` | Standalone dual channel |

---

### `sine_hdma_ending_wave` — `$00BF19` · **live**

Ending-region ripple: amplitude **8**, period **64** (`#40`), `TickSineHdma (#01,#02)`, single bind **`#0F`**. Flag **`#FF`** re-init. Inline label **`SineHdmaEndingWaveGen`** (GenHdmaSine path) remains in-file; not a separate spawned thinker.

| Scene ID | Spawn list | Slot | Notes |
|----------|------------|------|--------|
| `$E6`, `$EB`–`$EE` (230, 235–238) | `thinker_spawn_0CEAAC` | `#00` | + dispatcher |
| `$F3`–`$F6` (243–246) | `thinker_spawn_0CEAD3` / `0CEAE0` / `0CEAED` | `#00` | + ambient bundle `#3D` / `#79` / `#7B` |
| `$F2` (242) | `thinker_spawn_0CEAFA` | `#01` | After `dark_castoth_layer_config` |

---

### `ending_comet_sine_hdma` — `$00BCB3` · **live**

Comet flight dual-channel: amplitude **1**, period **8**, `TickSineHdma (#05,#02)`, binds **`#0F`** + **`#10`**. Clears `$7E8C30` / `$7E8E30` on init. **Not** the same script as `sine_hdma_ending_wave`.

| Scene ID | Spawn list | Slot | Notes |
|----------|------------|------|--------|
| `$E5` (229) | `thinker_spawn_0CEA9B` | `#02` | With bundle `#74`, `ending_comet_dma_setup` |

---

### `comet_lair_hdma_a` — `$00BCF5` · **live**

Amplitude **1**, period **8**, table `$7E8C00`, `TickSineHdma (#05,#02)`, channel **`#10`**. Clears `$7E8C30` / `$7E8E30`. Flag **`#FF`**.

| Scene ID | Spawn list | Slot |
|----------|------------|------|
| `$E8` (232) | `thinker_spawn_0CEABA` | `#03` |

---

### `comet_lair_hdma_b` — `$00BD21` · **live**

Amplitude **8**, period **8**, table **`$7E8400`**, `TickSineHdma (#05,#02)`, channel **`#0F`**.

| Scene ID | Spawn list | Slot |
|----------|------------|------|
| `$E8` (232) | `thinker_spawn_0CEABA` | `#04` |

---

### `comet_lair_hdma_c_timed` — `$00BD42` · **live**

Two phases:

```text
Phase 1: amp 2, InitSineHdma #$8000 period 8, flag #FF, flag #01 → burst
Phase 2 (CometLairHdmaCTimedBurst): amp 4, countdown 112 ($0070) on $7F0008,X
         each frame TickSineHdma #05 → BindSineHdma $7E8400 #0D
         at 0: SetEntryHere → idle (RTL only)
```

| Scene ID | Spawn list | Slot |
|----------|------------|------|
| `$E8` (232) | `thinker_spawn_0CEABA` | `#05` |

---

### `larai_cliff_scroll_wave` — `$00BD96` · **live**

Amplitude **4**, period **16** (`InitSineHdma #$8800,#10`). Before `TickSineHdma`, saves `cameraDeltaX` (`$06C0`), replaces it with `$0722 >> 4`, restores after tick. Channel **`#0D`**, `TickSineHdma (#04,#02)`.

| Scene ID | Spawn list | Slot |
|----------|------------|------|
| `$1D` (29) | `thinker_spawn_0CE861` | `#01` |

---

### `mu_tint_and_wave` — `$00BDCD` · **live**

Writes **`$COLDATA`** (`!COLDATA` `$2132`): default **`#$2A` / `#$44`**; if flag **`#7B`** set, **`#$28` / `#$41`**. Then sine: amplitude **1**, period **8**, `TickSineHdma (#03,#02)`, channels **`#0D`** + **`#0E`**. Flag **`#FF`** re-init path.

| Scene ID | Spawn list | Slot |
|----------|------------|------|
| `$5F`–`$62`, `$64`, `$65` (95–98, 100–101) | `thinker_spawn_0CE98D` | `#01` |

(Scene `$63` / `$66` use dispatcher-only lists — no Mu tint thinker.)

---

### `dao_sine_hdma_slow` — `$00BED1` · **live**

Amplitude **16** (`#$0010`), period **64**, slowest tick **`TickSineHdma (#00,#02)`**, channel **`#0D`**.

| Scene ID | Spawn list | Slot |
|----------|------------|------|
| `$C3` (195) | `thinker_spawn_0CEA6C` | `#00` |

Paired with `dao_window_mask` (slot `#03`) in the same list.

---

### `native_village_sine_hdma` — `$00BEF2` · **live**

Amplitude **4** (`#$0004` → `$7F0008,X`), period **32** (`InitSineHdma #$8800,#20`), `TickSineHdma (#04,#02)`, dual bind **`#0E`** + **`#10`** on **`$7E8C00`** (init builds at `$7E8800` short form, bind uses `$7E8C00`).

| Scene ID | Spawn list | Slot |
|----------|------------|------|
| `$AC` (172) | `thinker_spawn_0CEA08` | `#00` |

---

## Custom HDMA / direct setup (live)

### `palace_coffin_hdma_table` — `$00BE39` · **live**

Builds 16×3-byte HDMA entries at **`$7E7000`** (`#$0090` / `#$7100` pattern), zeroes 16 words at **`$7E7100`**, `QueueHdma ($7E7000,#21)` (config index **21** → register target **`$2171`** in table build). Flag **`#FF`** loop with `SetEntryHereAndYield`.

| Scene ID | Spawn list | Slot |
|----------|------------|------|
| `$5C` (92) | `thinker_spawn_0CE96F` | `#00` |

---

### `ending_comet_dma_setup` — `$00BCDF` · **live**

Each frame: **`COP [QueueHdmaDirect] (@dma_channel_00BCE8, #10)`** then `RTL`. Table entries target B-bus indices **`#70`, `#10`, `#01`, `#01`** (direct HDMA register writes — PPU init for comet bitmap path). **Not** a one-shot VRAM DMA burst.

| Scene ID | Spawn list | Slot |
|----------|------------|------|
| `$E5` (229) | `thinker_spawn_0CEA9B` | `#01` |
| `$E8` (232) | `thinker_spawn_0CEABA` | `#02` |

---

### `angel_tunnel_window_dma` — `$00B87B` · **live**

`QueueHdmaDirect (@dma_channel_00B884, #2C)` — window position HDMA (**`#2C`** = WH0/WH1 pair in `hdma_channel_config`).

| Scene ID | Spawn list | Slot |
|----------|------------|------|
| `$74` (116) | `thinker_spawn_0CE9A3` | `#01` |

---

## Comet Lair stack (scene `$E8`)

Scene **`$E8`** (`thinker_spawn_0CEABA`) — **no** `global_ambient_dispatcher` in this list:

| Slot | Thinker | Role |
|------|---------|------|
| `#00` | `sE8_comet_display_config` | Bank `$0C` display setup (not bank `$00`) |
| `#01` | `ambient_palette_cycler` (param `#71`) | Ambient palette |
| `#02` | `ending_comet_dma_setup` | Direct HDMA PPU setup |
| `#03`–`#05` | `comet_lair_hdma_a` / `_b` / `_c_timed` | Three sine layers |

---

## Dead / legacy HDMA thinker bodies

| Label | Address | Status | Evidence |
|-------|---------|--------|----------|
| `dma_setup_variant_unused` | `$00BC97` | **Dead** | No `@dma_setup_variant_unused` in `scene_thinkers.asm`; block note: alternate layout vs `inventory_bg3_scroll_hdma`, **`QueueHdmaDirect` `#12`**, 6-entry table |
| `empty_stub_unused` | `$00BDCA` | **Dead** | `thinker-def` body is **`RTL` only**; unreferenced |
| `native_village_dup_unused` | `$00BEAA` | **Dead** | Byte-identical to `native_village_sine_hdma`; only `@native_village_sine_hdma` is spawned |
| `gen_hdma_sine_oneshot_unused` | `$00BF52` | **Dead** | Subset of `SineHdmaEndingWaveGen` pattern; unreferenced |

---

## Thinker / channel / table matrix (live only)

| Thinker | HDMA config index | WRAM / table base | Scene IDs (hex) |
|---------|-------------------|-------------------|-----------------|
| `sine_hdma_slow_wave` | `#0D` | `$7E8800` | `$32`, `$E9`, `$EA` |
| `sine_hdma_dual_channel` | `#0F`, `#10` | `$7E8800`, `$7E8C00` | `$5A`–`$5C`, `$6F` |
| `sine_hdma_ending_wave` | `#0F` | `$7E8800` | `$E6`, `$EB`–`$EE`, `$F2`–`$F6` |
| `ending_comet_sine_hdma` | `#0F`, `#10` | `$7E8800`, `$7E8C00` | `$E5` |
| `comet_lair_hdma_a` | `#10` | `$7E8C00` | `$E8` |
| `comet_lair_hdma_b` | `#0F` | `$7E8400` | `$E8` |
| `comet_lair_hdma_c_timed` | `#0D` | `$7E8400` | `$E8` |
| `larai_cliff_scroll_wave` | `#0D` | `$7E8800` | `$1D` |
| `mu_tint_and_wave` | `#0D`, `#0E` | `$7E8800`, `$7E8C00` | `$5F`–`$62`, `$64`, `$65` |
| `dao_sine_hdma_slow` | `#0D` | `$7E8800` | `$C3` |
| `native_village_sine_hdma` | `#0E`, `#10` | `$7E8C00` (both) | `$AC` |
| `palace_coffin_hdma_table` | `#21` | `$7E7000` built | `$5C` |
| `ending_comet_dma_setup` | `#10` direct | `@dma_channel_00BCE8` | `$E5`, `$E8` |
| `angel_tunnel_window_dma` | `#2C` direct | `@dma_channel_00B884` | `$74` |

---

## Source validation

**Files checked:** `extracted/tables/scene_thinkers.asm`; all live thinker `.asm` paths listed above; `extracted/system/engine/thinker_execution.asm`; unused bodies under `extracted/unused/`.

**Verified against:** `thinker-spawn` records and `+4`/`+8` list offsets; per-thinker COP operands and `$7F0008,X` amplitudes; `thinker-def < #04, #08 >` filter word vs dispatch in `thinker_execution.asm`; absence of spawn pointers for unused labels (`rg` on `scene_thinkers.asm`).

**Notes:** Scene **names** (Freejia, Larai, etc.) taken from extracted block notes where present; not all scene IDs are named in ROM tables. Visual on-screen effects are **inferred** from register targets except where block notes state otherwise. Register numbers in prose use B-bus indices from `BindSineHdma` / `QueueHdmaDirect` operands.
