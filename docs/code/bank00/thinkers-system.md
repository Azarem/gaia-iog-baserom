# Bank $00 — Thinkers: System, Menu & Hardware Configuration

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00B78F`–`$00BF89`  
**Block type:** `thinker_def` — PPU configuration, menu DMA, and global scene dispatch  
**Priority:** All thinkers use priority `#08`  
**Related:** [`thinkers-palette.md`](thinkers-palette.md), [`thinkers-hdma.md`](thinkers-hdma.md), [`system-core.md`](system-core.md)

These thinkers configure SNES PPU hardware registers (`$CGADSUB`, `$COLDATA`, `$TM`, `$TS`, `$W12SEL`), set up DMA for menu screens, run boot logo palette sequences, and implement the global ambient/interaction dispatcher present in nearly every field scene.

---

## Overview

| Category | Count | Address Range |
|----------|-------|---------------|
| Hardware configuration | 5 | `$B78F`–`$B818`, `$BF78` |
| Menu / system DMA | 2 | `$BB8E`, `$BBAF` |
| Boot logo sequence | 3 | `$B83F`–`$B867` |
| Global scene dispatcher | 1 | `$BF89` |

---

## Hardware Configuration

### babel_elevator_color_add

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00B78F` |
| **New Name** | `babel_elevator_color_add` |
| **Hex Address** | `$00B78F` |
| **Decimal Address** | 46991 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/babel_tower/babel_light_elevator/babel_elevator_color_add.asm` |

#### Purpose

Sets `$CGADSUB` ← `#$02` each frame (color addition mode: add subscreen to main screen). Creates the bright, ethereal glow of the Babel Light Elevator shaft where subscreen graphics are additively blended onto the main layer.

#### Algorithm

```
SetEntryContinue
CGADSUB ← #$02    ; fixed color math mode
RTL               ; runs every frame
```

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Babel Light Elevator | 225 (`thinker_0CEA8E` slot `#01`) | Elevator shaft additive glow |

#### Dependencies

None.

---

### palace_scroll_brightness

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00B79D` |
| **New Name** | `palace_scroll_brightness` |
| **Hex Address** | `$00B79D` |
| **Decimal Address** | 47005 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/seaside_palace/palace_scroll_brightness.asm` |

#### Purpose

Dynamic brightness control for Palace Coffins based on vertical scroll position. Reads `$06C2` (BG scroll Y), adds `#$0080`, shifts right 8 bits total, masks to `#$F8`, then writes the result to `$COLDATA` with base `#$E0` — dimming or brightening the screen as the player scrolls through the coffin room.

#### Algorithm

```
SetEntryContinue
brightness = ((scroll_Y + 0x80) >> 8) & 0xF8
COLDATA ← brightness + 0xE0
RTL
```

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Palace Coffins | 92 (`thinker_0CE96F` slot `#04`) | Scroll-linked brightness in coffin maze |

#### Dependencies

None. Reads `$06C2` (scroll WRAM) directly.

---

### dao_window_mask

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00B7BE` |
| **New Name** | `dao_window_mask` |
| **Hex Address** | `$00B7BE` |
| **Decimal Address** | 47038 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/dao/dao/dao_window_mask.asm` |

#### Purpose

Sets `$W12SEL` ← `#$02` each frame, configuring window mask logic so BG2 participates in window masking. Creates the vignette/frame effect in Dao Village where the edges of the screen are clipped.

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Dao Village | 195 (`thinker_0CEA6C` slot `#03`) | Window-masked village viewport |

#### Dependencies

None.

---

### itory_village_fog

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00B818` |
| **New Name** | `itory_village_fog` |
| **Hex Address** | `$00B818` |
| **Decimal Address** | 47128 |
| **Self-Contained** | **No** |
| **ASM File** | `extracted/itory/itory_village/itory_village_fog.asm` |

#### Purpose

Position-dependent fog effect for Itory Village. Reads the player's X coordinate via `$player_actor` → `$14,Y`. West of X = `$01B0` (432 pixels): sets `$CGADSUB` ← `#$50` (subscreen color addition with halftone). East of threshold: clears `$CGADSUB` ← `#$00`. Exits entirely when flag `#2B` is set.

#### Algorithm

```
if flag #2B == 1 → exit thinker
SetEntryContinue
player_X = [$player_actor + $14]
if player_X >= $01B0 → CGADSUB = 0 (clear fog)
else → CGADSUB = $50 (fog overlay)
RTL
```

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Itory Village | 14 (`thinker_0CE843` slot `#00`) | Rolling fog on village west side |

#### Dependencies

| Symbol | Type | Purpose |
|--------|------|---------|
| `$player_actor` | WRAM label | Player actor index for position read |

---

### dark_castoth_layer_config

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00BF78` |
| **New Name** | `dark_castoth_layer_config` |
| **Hex Address** | `$00BF78` |
| **Decimal Address** | 49016 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/babel_tower/dark_castoth_lair/dark_castoth_layer_config.asm` |

#### Purpose

Forces BG layer configuration for the Dark Castoth boss arena. Sets `$TM` ← `#$17` (BG1+BG2+BG3+OBJ on main screen) and `$TS` ← `#$00` (no subscreen layers). Ensures all background layers are visible for the multi-layer boss room layout.

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Dark Castoth Lair | 242 (`thinker_0CEAFA` slot `#00`) | Boss arena layer setup |

#### Dependencies

None.

---

## Menu / System

### inventory_dma_setup

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00BB8E` |
| **New Name** | `inventory_dma_setup` |
| **Hex Address** | `$00BB8E` |
| **Decimal Address** | 48014 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/system/inventory/inventory_dma_setup.asm` |

#### Purpose

One-shot DMA burst configuring PPU registers for the inventory screen. Queues 7 DMA writes targeting `$70` (VMAIN), `$30` (TM), four `$210C`/`$2108` scroll offsets, and `$40` (INIDISP) — setting up tilemap addresses, layer enables, and screen brightness for the item menu overlay.

#### DMA Table

| Entry | Register | Value | Effect |
|-------|----------|-------|--------|
| 0 | `$2170` | `$00` | VMAIN config |
| 1 | `$2130` | `$00` | TM (layer enable) |
| 2–5 | `$210C`/`$2108` | scroll offsets | BG scroll positions |
| 6 | `$2140` | `$20` | INIDISP (brightness) |

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Inventory menu | `$FF` (`thinker_0CEB46` slot `#00`) | PPU init on menu open |

#### Dependencies

None.

---

### diary_menu_window_dma

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00BBAF` |
| **New Name** | `diary_menu_window_dma` |
| **Hex Address** | `$00BBAF` |
| **Decimal Address** | 48047 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/system/diary_menu/diary_menu_window_dma.asm` |

#### Purpose

State-machine DMA thinker for the diary menu window animation. Reads state variables `$0D96`, `$0D92`, `$0D98`, and `$0036` to select among multiple DMA tables (`@dma_data_00BC4C` through `@dma_data_00BC83`), configuring window registers (`$WH0`, `$WBGLOG`, etc.) for the sliding diary panel reveal. Handles both the primary window track and a secondary track (`$0D98`) with independent state.

#### Algorithm

```
each frame:
  read $0D96 → select window DMA table variant
  read $0D92 → sub-state (0/1/2 → different table)
  read $0036 bit 0 → override path
  QueueDma (selected_table, #26)
  repeat for secondary track ($0D98)
  RTL
```

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Diary menu | `$FA` (`thinker_0CEB18`) | Window animation during diary read |

Referenced by `NewGamePlus.patch.asm` via `?INCLUDE 'diary_menu_window_dma'`.

#### Dependencies

None. Uses embedded DMA data tables within the same block.

---

## Boot Logo Sequence

Three one-shot thinkers that run sequential palette fades during the publisher logo screens at boot. Each applies three palette bundle steps then self-terminates.

### boot_logo_palette_enix

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00B83F` |
| **New Name** | `boot_logo_palette_enix` |
| **Hex Address** | `$00B83F` |
| **Decimal Address** | 47167 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/system/boot_logos/boot_logo_palette_enix.asm` |

#### Purpose

Enix logo palette fade: bundle `#50` → `#52` → `#54`, then `KillThinker`.

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Boot logos | `$FB` (`thinker_0CEB1D` slot `#00`, bundle `#01`) | Enix logo fade-in |

#### Dependencies

None.

---

### boot_logo_palette_quintet

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00B853` |
| **New Name** | `boot_logo_palette_quintet` |
| **Hex Address** | `$00B853` |
| **Decimal Address** | 47187 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/system/boot_logos/boot_logo_palette_quintet.asm` |

#### Purpose

Quintet logo palette fade: bundle `#51` → `#53` → `#55`, then `KillThinker`.

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Boot logos | `$FB` (`thinker_0CEB1D` slot `#01`, bundle `#02`) | Quintet logo fade-in |

#### Dependencies

None.

---

### boot_logo_palette_third

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00B867` |
| **New Name** | `boot_logo_palette_third` |
| **Hex Address** | `$00B867` |
| **Decimal Address** | 47207 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/system/boot_logos/boot_logo_palette_third.asm` |

#### Purpose

Third-party logo palette fade: bundle `#56` → `#57` → `#58`, then `KillThinker`.

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Boot logos | `$FB` (`thinker_0CEB1D` slot `#02`, bundle `#03`) | Additional credit logo fade |

#### Dependencies

None.

---

## Global Scene Dispatcher

### global_ambient_dispatcher

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00BF89` |
| **New Name** | `global_ambient_dispatcher` |
| **Hex Address** | `$00BF89` |
| **Decimal Address** | 49033 |
| **Self-Contained** | **No** |
| **ASM File** | `extracted/thinkers/global_ambient_dispatcher.asm` |
| **Size** | ~545 bytes (largest bank $00 thinker) |

#### Purpose

Hub thinker present in nearly every field scene. Combines two responsibilities:

1. **Ambient palette dispatch:** `SwitchCase` on `$0AD4` (current character/form index) selects one of four palette bundles (`#0B`, `#0C`, `#23`, `#0C`) for character-specific color grading during gameplay.

2. **Player-proximity interaction:** After palette step, checks `$0656` bit 15 (`#$8000`). When set, calls `$@func_03F0CA` (direction probe) and scans all actors within 16×16 pixels of the player. If a matching actor with a linked script (`$7F000A,X` ≠ 0) is found and the player presses a direction button, triggers the actor's interaction script via `$@func_03CA55`.

#### Algorithm

```
SwitchCase $0AD4:
  case 0 → PaletteStart #0B → PaletteStep
  case 1 → PaletteStart #0C → PaletteStep
  case 2 → PaletteStart #23 → PaletteStep
  case 3 → PaletteStart #0C → PaletteStep

clear thinker flag $0800 on $7F000E,X
SetEntryExit
if $0656 bit 15 == 0 → RTL

direction = func_03F0CA()
find nearest actor within 16px of player in facing direction
if found and button pressed:
  DMA sound #002F to APUIO
  call func_03CA55 (interaction handler)
  spawn deferred script callback
else:
  toggle $0656/$0658 interaction flags
RTL
```

#### Scene Usage

Present as the final slot in virtually every multi-thinker scene set, and as the sole thinker in minimal scenes (`thinker_0CE7E5`). Examples:

| Pattern | Scenes | Role |
|---------|--------|------|
| Solo dispatcher | 0, 9, 11–13, 16–19, 24, 27, 28, 31 | Ambient + interaction only |
| Last slot in set | 1–8, 10, 14–15, 20–26, 29–30, 32–36, 38+ | Character palette + NPC interaction |

The `$0AD4` character index drives Will/Freedan/Shadow palette variants automatically.

#### Dependencies

| Symbol | Type | Purpose |
|--------|------|---------|
| `chunk_03BAE1` | `?INCLUDE` | Shared actor/engine constants |
| `$player_actor` | WRAM label | Player actor index for proximity scan |
| `$@func_03F0CA` | Far function | Direction probe from joypad input |
| `$@func_03CA55` | Far function | Actor interaction script executor |

#### Internal Sub-functions

| Address | Name | Purpose |
|---------|------|---------|
| `$00BF99`–`$00BFAE` | SwitchCase targets | Character-specific palette starts |
| `$00BFD4` | Proximity handler | Direction-based actor search |
| `$00C133` | Actor scan | Find nearest qualifying actor within 16px |
| `$00C182` | Direction map | Map facing direction to animation frame |
| `$00C0DE` | Flag cleanup | Clear interaction enable flags |
| `$00C0ED` | Deferred callback | Post-interaction script continuation |

---

## Scene Thinker Slot Convention

Most field scenes follow a standard thinker slot layout:

| Slot | Typical Thinker | Role |
|------|----------------|------|
| `#00` | Scene-specific effect | Palette cycler, HDMA wave, fog, etc. |
| `#01` | `parallax_thinker` or second ambient | Parallax scroll / secondary palette |
| `#02` | Additional effect (optional) | HDMA, scroll brightness, etc. |
| Last | `global_ambient_dispatcher` | Character palette + NPC interaction |

System scenes use dedicated layouts:

| Scene | Thinkers |
|-------|----------|
| `$FA` (Diary) | `diary_menu_window_dma` |
| `$FB` (Boot) | 3× boot logo palette thinkers |
| `$FD` (Statue inventory) | `parallax_thinker` + `palette_parent_child` + ambient |
| `$FF` (Inventory) | `inventory_dma_setup` + `parallax_thinker` + `palette_parent_child` + ambient |

---

## PPU Register Reference

| Register | Thinkers | Value | Effect |
|----------|----------|-------|--------|
| `$CGADSUB` (`$2130`) | `babel_elevator_color_add`, `itory_village_fog`, `palace_fountain_palette` | `#02`, `#50`, `#03` | Color addition/subtraction mode |
| `$COLDATA` (`$2132`) | `palace_scroll_brightness`, `edward_castle_alarm_palette`, one-shot tints | varies | Direct color addition/subtraction |
| `$TM` / `$TS` (`$2105`/`$2106`) | `dark_castoth_layer_config` | `#17` / `#00` | Main/sub screen layer enables |
| `$W12SEL` (`$2123`) | `dao_window_mask` | `#02` | BG1/BG2 window mask select |
| `$WH0` (`$2126`) | `diary_menu_window_dma` | `#FF` | Window horizontal position |
