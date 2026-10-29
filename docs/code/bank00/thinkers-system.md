# Bank $00 — Thinkers: System, Menu & Hardware Configuration

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00B78F`–`$00BF89` (hardware + menu + boot logos + dispatcher)  
**Block type:** `thinker_def` — PPU configuration, menu HDMA, boot palette sequences, global talk dispatch  
**Filter word:** Most use `thinker-def < #00, #08 >` → **`$0800`** (General/Light runners only). Menu/window HDMA uses **`#04, #08`** → **`$0804`** (HDMA pass). Spawn-record byte 0 is the **parameter** (`animScratch+2`), not a universal “slot type”.  
**Related:** [`thinkers-palette.md`](thinkers-palette.md), [`thinkers-hdma.md`](thinkers-hdma.md), [`system-core.md`](system-core.md)

---

## Source of truth

| Role | Path |
|------|------|
| Scene spawn lists | `extracted/tables/scene_thinkers.asm` |
| Global talk + form palette | `extracted/thinkers/global_ambient_dispatcher.asm` |
| Hardware / fog / scroll | `extracted/babel_tower/babel_light_elevator/babel_elevator_color_add.asm`, `extracted/seaside_palace/palace_scroll_brightness.asm`, `extracted/dao/dao/dao_window_mask.asm`, `extracted/itory/itory_village/itory_village_fog.asm`, `extracted/babel_tower/dark_castoth_lair/dark_castoth_layer_config.asm` |
| Menu HDMA | `extracted/system/inventory/inventory_bg3_scroll_hdma.asm`, `extracted/system/diary_menu/diary_menu_window_dma.asm` |
| Boot logos | `extracted/system/boot_logos/boot_logo_enix_palette_obj{0,1,2}.asm`, `extracted/system/boot_logos/sFB_boot_logo.asm` |
| Thinker dispatch | `extracted/system/engine/thinker_execution.asm` |

**Naming:** All section labels match extracted symbols. **`thinker_spawn_*`** names are spawn-list labels in bank `$0C`.

**Counts:** **`59`** spawn records reference `@global_ambient_dispatcher` in source tables (`rg` count in `scene_thinkers.asm`). **`70`** scene IDs point at the shared **`thinker_spawn_dispatcher_only`** list (one dispatcher record, many scenes). **11** scene IDs use lists with **no** dispatcher (boot, diary, inventory, comet lair, ending comet flight, credits, etc. — see below). Scene placements for hardware thinkers counted from spawn tables this session.

---

## Overview

| Category | Thinkers | Filter |
|----------|----------|--------|
| Hardware / PPU each frame | 5 | `$0800` except none HDMA |
| Menu HDMA | 2 | `$0804` |
| Boot logo palette (one-shot sequence) | 3 | `$0800` |
| Global scene dispatcher | 1 | `$0800` |

---

## Hardware configuration (live)

### `babel_elevator_color_add` — `$00B78F`

Each frame: **`$CGADSUB` ← `#$02`** (`!CGADSUB` equate **`$2131`** in extracted file). Additive color math on subscreen.

| Scene ID | List | Slot |
|----------|------|------|
| `$E1` (225) | `thinker_spawn_0CEA8E` | `#01` |

---

### `palace_scroll_brightness` — `$00B79D`

Reads **`cameraTargetY` (`$06C2`)**, adds `#$0080`, shifts right **7** times total (with `AND #$F8` mid-way), adds **`#$E0`**, writes **`$COLDATA`** (`$2132`). HDMA filter **`$0804`**.

| Scene ID | List | Slot |
|----------|------|------|
| `$5C` (92) | `thinker_spawn_0CE96F` | `#04` |

Also spawned on **`$5A`/`$5B`** via `thinker_spawn_0CE96F+8` (slots `#04`).

---

### `dao_window_mask` — `$00B7BE`

Each frame: **`$W12SEL` ← `#$02`** (`$2123`).

| Scene ID | List | Slot |
|----------|------|------|
| `$C3` (195) | `thinker_spawn_0CEA6C` | `#03` |

---

### `itory_village_fog` — `$00B818`

Exits when flag **`#2B`** set (`WaitOnFlagByte`). Else reads **`$playerActor` → `$14,Y` (X)**. If X **`>= #$01B0`**: **`$CGADSUB` ← 0**; else **`#$50`**. Register label in asm: **`!CGADSUB` `$2131`**.

| Scene ID | List | Slot |
|----------|------|------|
| `$15` (21) | `thinker_spawn_0CE843` | `#00` |

(Scene **`$0E` (14)** uses a different list — no fog thinker.)

---

### `dark_castoth_layer_config` — `$00BF78`

Each frame: **`$TM` ← `#$17`**, **`$TS` ← `#$00`** (`!TM` **`$212C`**, `!TS` **`$212D`** in extracted equates). Filter **`$0804`**.

| Scene ID | List | Slot |
|----------|------|------|
| `$F2` (242) | `thinker_spawn_0CEAFA` | `#00` |

---

## Menu / system HDMA (live)

### `inventory_bg3_scroll_hdma` — `$00BB8E`

Each HDMA pass: **`QueueHdmaDirect (@inventory_bg3vofs_table, #12)`** — operand **`#12`** = B-bus **`$2112` BG3VOFS**. Fixed 7-entry direct table; re-queued every frame after `ResetHdmaState`.

| Scene ID | List | Slot |
|----------|------|------|
| `$FF` | `thinker_spawn_0CEB46` | `#00` |

**Note:** Inventory list has **no** `global_ambient_dispatcher` (menu overlay).

---

### `diary_menu_window_dma` — `$00BBAF`

State machine on **`$0D92`**, **`$0D96`**, **`$0D98`**, **`$0036`**: up to three **`QueueHdmaDirect (... , #26)`** calls per frame (**`#26`** = WH0/WH1). Band tables embedded in same file.

| Scene ID | List | Slot |
|----------|------|------|
| `$FA` | `thinker_spawn_0CEB18` | `#00` (only record) |

Referenced by **`NewGamePlus.patch.asm`** via `?INCLUDE 'diary_menu_window_dma'`.

---

## Boot logo palette sequence (live)

Three parallel thinkers (OBJ palettes **0 / 1 / 2**), spawned only on scene **`$FB`** (`thinker_spawn_0CEB1D`, params **`#01` / `#02` / `#03`** — **never read** by scripts). Each runs **`PaletteStart` + `PaletteStep`** three times then **`KillThinker`**. Scene script **`sFB_boot_logo.asm`**: thinkers animate **Enix logo** (`sprite_group_000010`); first logo visit runs them on unseen OBJ palettes.

| Thinker | Address | Bundles (OBJ palette) |
|---------|---------|------------------------|
| `boot_logo_enix_palette_obj0` | `$00B83F` | `#50` → `#52` → `#54` (CGRAM `$81`–`$8F`) |
| `boot_logo_enix_palette_obj1` | `$00B853` | `#51` → `#53` → `#55` (`$91`–`$9F`) |
| `boot_logo_enix_palette_obj2` | `$00B867` | `#56` → `#57` → `#58` (`$A1`–`$AF`) |

Boot list has **no** `global_ambient_dispatcher`.

---

## Global scene dispatcher (live)

### `global_ambient_dispatcher` — `$00BF89`

**Size:** ~545 bytes (label span in bank `$00`; block note).

**Spawn-time (once):** `SwitchCase` on **`characterForm` (`$0AD4`)** → palette bundles **`#0B` / `#0C` / `#23`** (OBJ **`$81`–`$8F`**). Fourth case unreachable. **Not** refreshed on mid-scene form change.

**Each frame (talk):** Documented flow matches `global_ambient_dispatcher.asm`:

```text
GlobalAmbientInteractEntry: clear animScratch2 bit $0800 → leave Light runners
  if joypadCurrent bit $8000 clear → RTL
  GetPlayerFacingDirection (carry set = abort)
  probe 1px in front → GlobalAmbientFindActorInFront (Flags10 $1000, |dx|+|dy| bounds)
  chat via chatPtr ($7F000A); MVN snapshot $2F bytes to $7E:3410 when turning to talk
  GlobalAmbientClearTalkInput
```

**Interact bit:** **`joypadCurrent` `$8000`** (logical interact; this build maps to **A** via `transforms.json` — see block note).

**Spawn coverage:** **`59`** `@global_ambient_dispatcher` records in source lists; **`70`** scenes use dispatcher-only list; **11** scene IDs omit dispatcher entirely (`$E5`, `$E8`, `$FA`, `$FB`, `$FD`, `$FF`, credits `$F7`, space `$E7`, etc.).

**Dependencies:** `GetPlayerFacingDirection`, `$playerActor`, `ComposeDigitSprites_AtCursor` include; talk helpers are internal labels (`GlobalAmbientProbe*`, `GlobalAmbientTalkWithSnapshot`, …).

---

## Scene thinker slot convention (source-backed)

Slot order is **defined per spawn list** in `scene_thinkers.asm`, not a ROM-wide rule.

| Pattern | Source fact |
|---------|-------------|
| **`global_ambient_dispatcher` last** | Common, not universal — **first** in lists like `thinker_spawn_0CE98D` (Mu), `thinker_spawn_0CE9A3`, `thinker_spawn_0CE8C7` |
| **Mid-list entry** | **43** scene pointers use **`+4` / `+8`** byte offsets into another list — later slots only |
| **Dispatcher-only** | **`70`** scene IDs → `thinker_spawn_dispatcher_only` |
| **No dispatcher** | Menu / boot / inventory / some ending scenes (see boot and inventory sections) |

Example **field** list (`thinker_spawn_0CE861`, scene **`$1D`**):

| Slot | Thinker |
|------|---------|
| `#00` | `scanline_band_hdma_thinker` (`#0B`) |
| `#01` | `larai_cliff_scroll_wave` |
| `#02` | `ambient_palette_cycler` (`#13`) |
| `#03` | `global_ambient_dispatcher` |

Example **system** lists (from spawn tables):

| Scene ID | Thinkers (spawn order) |
|----------|-------------------------|
| `$FA` | `diary_menu_window_dma` only |
| `$FB` | 3× boot logo palette thinkers |
| `$FD` | `scanline_band_hdma_thinker`, `palette_parent_child`, `ambient_palette_cycler` — **no** dispatcher |
| `$FF` | `inventory_bg3_scroll_hdma`, scanline, `palette_parent_child`, 2× `ambient_palette_cycler` — **no** dispatcher |

---

## PPU register reference (this doc’s thinkers)

Equates are from extracted `!label` lines (B-bus addresses as used by the engine).

| Register (SNES) | Equate in asm | Thinkers | Value / effect |
|-----------------|---------------|----------|----------------|
| Color math subscreen | `CGADSUB` `$2131` | `babel_elevator_color_add`, `itory_village_fog` | `#$02` add mode; `#$50` halftone add; `#$00` clear |
| Fixed color | `COLDATA` `$2132` | `palace_scroll_brightness` | Scroll-derived add/sub term + `#$E0` base |
| Main screen layers | `TM` `$212C` | `dark_castoth_layer_config` | `#$17` (BG1+2+3+OBJ) |
| Sub screen layers | `TS` `$212D` | `dark_castoth_layer_config` | `#$00` |
| Window BG1/2 mask | `W12SEL` `$2123` | `dao_window_mask` | `#$02` |
| Window 1 left | `WH0` `$2126` | `diary_menu_window_dma` (via HDMA `#26`) | Band tables / `#$FF` empty |
| BG3 V scroll | `$2112` (HDMA `#12`) | `inventory_bg3_scroll_hdma` | Stepped `inventory_bg3vofs_table` |

Palette-family thinkers that also touch `$CGADSUB` / `$COLDATA` are documented in [`thinkers-palette.md`](thinkers-palette.md).

---

## Source validation

**Files checked:** `extracted/tables/scene_thinkers.asm`; all thinker `.asm` files listed above; `extracted/system/boot_logos/sFB_boot_logo.asm`; `extracted/system/engine/thinker_execution.asm`.

**Verified against:** Spawn records and list offsets; register writes in hardware thinkers; `global_ambient_dispatcher` block note vs instruction flow (interact bit, MVN `$2F`, animScratch2 bit 11); boot scene cross-reference; inventory/diary filter words `$0804`.

**Notes:** **`173 of 184`** dispatcher coverage claim removed — not supported by spawn table arithmetic (**59** named records + **70** shared dispatcher-only scenes, **11** scenes without). Scene **names** in prose only where block notes confirm. On-screen appearance of fog/brightness bands **not** emulator-verified in this pass.
