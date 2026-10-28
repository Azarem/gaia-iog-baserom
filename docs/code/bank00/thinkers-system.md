# Bank $00 — Thinkers: System, Menu & Hardware Configuration

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00B78F`–`$00BF89`  
**Block type:** `thinker_def` — PPU configuration, menu DMA, and global scene dispatch  
**Priority:** All thinkers use priority `#08`  
**Related:** [`thinkers-palette.md`](thinkers-palette.md), [`thinkers-hdma.md`](thinkers-hdma.md), [`system-core.md`](system-core.md)

These thinkers configure SNES PPU hardware registers (`$CGADSUB`, `$COLDATA`, `$TM`, `$TS`, `$W12SEL`), set up DMA for menu screens, run boot logo palette sequences, and implement the per-scene form-palette + talk-interaction dispatcher (`global_ambient_dispatcher`) present in most field scenes.

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

**Address:** `$00B78F`

#### Purpose

Sets `$CGADSUB` ← `#$02` each frame (color addition mode: add subscreen to main screen). Creates the bright, ethereal glow of the Babel Light Elevator shaft where subscreen graphics are additively blended onto the main layer.

#### Algorithm

```
SetEntryHere
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

**Address:** `$00B79D`

#### Purpose

Dynamic brightness control for Palace Coffins based on vertical scroll position. Reads `$06C2` (BG scroll Y), adds `#$0080`, shifts right 8 bits total, masks to `#$F8`, then writes the result to `$COLDATA` with base `#$E0` — dimming or brightening the screen as the player scrolls through the coffin room.

#### Algorithm

```
SetEntryHere
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

**Address:** `$00B7BE`

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

**Address:** `$00B818`

#### Purpose

Position-dependent fog effect for Itory Village. Reads the player's X coordinate via `$player_actor` → `$14,Y`. West of X = `$01B0` (432 pixels): sets `$CGADSUB` ← `#$50` (subscreen color addition with halftone). East of threshold: clears `$CGADSUB` ← `#$00`. Exits entirely when flag `#2B` is set.

#### Algorithm

```
if flag #2B == 1 → exit thinker
SetEntryHere
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

**Address:** `$00BF78`

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

### inventory_bg3_scroll_hdma

**Address:** `$00BB8E`

#### Purpose

Per-frame **BG3 vertical scroll HDMA**. Each thinker tick runs `COP [QueueDma] ( @inventory_bg3vofs_table, #12 )` — operand `#12` is B-bus **`$2112` BG3VOFS** (not a byte count). `ResetHdmaState` clears channel bindings every frame, so this thinker re-queues the same seven-entry direct table.

#### HDMA table (`inventory_bg3vofs_table`)

Seven `{line count, V low, V high}` bands: long runs at V=0, then stepped bands at `$0B`/`$0F`/`$13`/`$17`, ending at V=`$20` from scanline 160 downward (visual result not verified in emulator).

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Inventory menu | `$FF` (`thinker_0CEB46` slot `#00`) | PPU init on menu open |

#### Dependencies

None.

---

### diary_menu_window_dma

**Address:** `$00BBAF`

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

**Address:** `$00B83F`

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

**Address:** `$00B853`

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

**Address:** `$00B867`

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

**Address:** `$00BF89` · **Size:** ~545 bytes (largest bank $00 thinker)

#### Purpose

Per-scene hub thinker (usually the last slot). Two jobs:

1. **Form palette (spawn only):** `SwitchCase` on `characterForm` (`$0AD4`: 0 Will, 1 Freedan, 2 Shadow) runs `PaletteStart` / `PaletteStep` on bundle `#0B`, `#0C`, or `#23`. All write OBJ palette 0 colours `$81`–`8F` (the player's sprite palette). The fourth table entry is never reached. Not re-run on mid-scene form changes.

2. **Talk interaction (every frame):** Trigger is **`joypadCurrent` bit `$8000` (interact)**, not a direction press. After `GlobalAmbientInteractEntry` clears bit 11 of the thinker's `animScratch2` (`$7F000E,X`), it runs only in the main thinker pass (skipped during dialogue frame loops).

#### Algorithm

```
(at spawn) SwitchCase characterForm → PaletteStart #0B / #0C / #23 → PaletteStep

each frame:
  clear animScratch2 bit $0800 (drop out of Light runners)
  if joypadCurrent interact bit clear → RTL
  GetPlayerFacingDirection → carry set = invalid facing → RTL
  build probe point 1 px in front of player (GlobalAmbientProbeDown/Up/Left/Right)
  scan actors: smallest |dx|+|dy| with |dx|,|dy| each < $10, Flags10 bit $1000 set
  if target has chatPtr ($7F000A):
     in range → turn, optional MVN snapshot ($2F byte count), run chat, restore
     at/behind → run chat directly (or defer if Flags12 bit $0200)
  clear interact in joypadCurrent; latch into joypadHeld
RTL
```

The talk path's **`$2F` is the MVN byte count** (actor + extended snapshot to `$7E:3410`), not an APU sound. `GlobalAmbientTalkWithSnapshot` / `GlobalAmbientTalkRestoreActor` wrap the chat routine.

#### Scene Usage

**59** spawn-list entries in `scene_thinkers.asm`, covering **173 of 184** scenes that have thinkers (typically the last slot).

#### Dependencies

| Symbol | Type | Purpose |
|--------|------|---------|
| `ComposeDigitSprites_AtCursor` | `?INCLUDE` | Shared actor/engine constants |
| `$player_actor` | WRAM label | Player position for probe |
| `GetPlayerFacingDirection` | Far function | Facing 0 down / 1 up / 2 left / 3 right |
| `UpdateActorAnimation` | Far function | Stage talk facing frame |

#### Internal Sub-functions

| Label | Purpose |
|-------|---------|
| `GlobalAmbientFacingValid` | Carry-clear path after facing read |
| `GlobalAmbientProbeDown/Up/Left/Right` | 1 px probe from player |
| `GlobalAmbientFindActorInFront` | Nearest qualifying actor |
| `GlobalAmbientTalkWithSnapshot` / `GlobalAmbientTalkRestoreActor` | MVN save/restore around chat |
| `GlobalAmbientDeferToScript` | Skip turn when Flags12 `$0200` set |
| `GlobalAmbientClearTalkInput` | Consume interact press |

---

## Scene Thinker Slot Convention

Most field scenes follow a standard thinker slot layout:

| Slot | Typical Thinker | Role |
|------|----------------|------|
| `#00` | Scene-specific effect | Palette cycler, HDMA wave, fog, etc. |
| `#01` | `scanline_band_hdma_thinker` or second ambient | Scanline HDMA bands / secondary palette |
| `#02` | Additional effect (optional) | HDMA, scroll brightness, etc. |
| Last | `global_ambient_dispatcher` | Form OBJ palette (spawn) + interact talk |

System scenes use dedicated layouts:

| Scene | Thinkers |
|-------|----------|
| `$FA` (Diary) | `diary_menu_window_dma` |
| `$FB` (Boot) | 3× boot logo palette thinkers |
| `$FD` (Statue inventory) | `scanline_band_hdma_thinker` + `palette_parent_child` + ambient |
| `$FF` (Inventory) | `inventory_bg3_scroll_hdma` + `scanline_band_hdma_thinker` + `palette_parent_child` + ambient |

---

## PPU Register Reference

| Register | Thinkers | Value | Effect |
|----------|----------|-------|--------|
| `$CGADSUB` (`$2130`) | `babel_elevator_color_add`, `itory_village_fog`, `palace_fountain_palette` | `#02`, `#50`, `#03` | Color addition/subtraction mode |
| `$COLDATA` (`$2132`) | `palace_scroll_brightness`, `edward_castle_alarm_palette`, one-shot tints | varies | Direct color addition/subtraction |
| `$TM` / `$TS` (`$2105`/`$2106`) | `dark_castoth_layer_config` | `#17` / `#00` | Main/sub screen layer enables |
| `$W12SEL` (`$2123`) | `dao_window_mask` | `#02` | BG1/BG2 window mask select |
| `$WH0` (`$2126`) | `diary_menu_window_dma` | `#FF` | Window horizontal position |

---

*Source: `extracted/thinkers/global_ambient_dispatcher.asm` and related thinker ASM files in `extracted/`.*
