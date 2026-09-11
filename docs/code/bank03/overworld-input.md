# Overworld Input Handler & Radar Map Screen

> Analysis of `chunk_038000.asm` §1 — the overworld button dispatcher,
> radar/map overlay, and their supporting subroutines.
>
> **Address range:** `$038000`–`$038409` (1,034 bytes)

---

## 1. Overview

This section is the **overworld HUD input gate** — called once per main-loop
frame from `system_core` (line 213). It intercepts button presses on the
overworld and dispatches to one of three subsystems:

| Button | Action | Target |
|--------|--------|--------|
| **L** | Open inventory overlay | `inventory_overlay.OpenInventoryScreen` (external) |
| **Y** | Use equipped item | `ItemUseDispatch` → item handler table (§2 of this chunk) |
| **Start** | Open radar/map screen | `RadarScreenSetup` (this section) |

If no relevant button is pressed, or if the player is in a state that blocks
input (scene transition pending, cutscene flag, music playing), the routine
returns immediately.

---

## 2. Piece-by-Piece Analysis

### 2.1 `func_038000` — Overworld Input Handler

**Proposed name:** `OverworldInputHandler`

| Property | Value |
|----------|-------|
| Address | `$038000`–`$03808E` |
| Size | 191 bytes |
| Entry | `JSL` from `system_core` main game loop |
| Exit | `RTL` |
| Callers | `system_core.asm` (line 213) — one external caller |

**Behavior:**

1. Saves processor state (`PHP`), sets 16-bit accumulator.
2. **Guard checks** (any true → bail via `RTL`):
   - `sceneNext` ≠ 0 (scene transition pending)
   - `playerFlags` bit 9 set (cutscene lock)
   - Music is playing (`IsMusicPlaying` returns carry set)
3. **Button dispatch:**
   - **Start** (`$1000`): Jumps to radar screen setup.
     - If `playerFlags` bit 3 set → runs a BG3 script to show the status bar,
       then enters radar display loop.
     - Otherwise → calls `RadarScreenSetup` to load graphics and lay out
       the radar tilemap, then enters radar display loop.
   - **L** (`$2000`): Opens inventory screen via
     `inventory_overlay.OpenInventoryScreen`, masks L+R in held-joypad to
     prevent re-trigger.
   - **Y** (`$4000`): Jumps to `ItemUseDispatch` (`sub_038410`).
4. **Radar display loop** (at `loc_03808F`):
   - Waits for VBlank, calls `RadarBorderAnimate` each frame.
   - On Start press again → exits loop, clears VRAM buffer, restores display.

**Key variables:**

| Variable | Meaning |
|----------|---------|
| `$sceneNext` (`$0642`) | Non-zero = scene transition pending |
| `$playerFlags` (`$09AE`) | Bit 9: cutscene lock; Bit 3: status bar active; Bit 13: attack |
| `$joypadCurrent` (`$0656`) | Current frame button state |
| `$joypadHeld` (`$0658`) | Buttons held (masked to prevent re-trigger) |
| `$displayModeFlags` (`$09EC`) | Bit 0: dialogue active; Bit 7: screen dim |

---

### 2.2 `sub_0380BF` — Radar Screen Setup

**Proposed name:** `RadarScreenSetup`

| Property | Value |
|----------|-------|
| Address | `$0380BF`–`$038258` |
| Size | 410 bytes |
| Entry | `JSR` from `OverworldInputHandler` (Start button path) |
| Exit | `RTS` |

**Behavior:**

1. **Wait for pending DMA** — spins on `$7F0C07` (ad-hoc VRAM DMA byte count)
   until zero, calling `VBlankWait` each frame.
2. **Upload radar icon tileset** — sets up a DMA transfer of `radar_icons_001C00`
   (512 bytes → VRAM `$7700`).
3. **Wait for icon DMA** — same spin-wait pattern.
4. **Clear VRAM buffer** — calls `ClearVramBufferPartial`.
5. **Copy radar tilemap template** — block-moves `radar_layout_001E00` (1,408
   bytes) into the WRAM tilemap buffer at `$7F0380` using `MVN`.
6. **Calculate visible tile bounds** — from `playerXTile`/`playerYTile`, computes a
   68×68-pixel visible region (tiles aligned to 4-pixel grid):
   - `$0018` = left bound, `$001A` = right bound
   - `$001C` = top bound, `$001E` = bottom bound
7. **Plot scene event markers** — calls `RadarPlotSceneMarkers`.
8. **Display jewel counter** — extracts tens/units digits from jewel count
   (`$0002`) in BCD, writes tile indices to the radar tilemap.
9. **Convert bounds to pixel coordinates** — shifts tile bounds left by 4
   (×16 pixels) for actor radar plotting.
10. **Plot actor markers** — calls `RadarPlotActors`.
11. **Display enemy kill counter** — extracts digits from `$0AEE`, writes
    to tilemap.
12. **Check enemy clear reward** — if the current scene has an enemy clear
    reward in `enemy_clear_reward_table` and the scene's flag `$0300` is not
    yet set, draws a 2×4 "reward available" indicator box using specific
    tile IDs, plus runs a BG3 script for the reward counter.
13. **Draw player position cursor** — writes `$32E5` tile to player's radar
    position.
14. **Set display mode** and return.

**Data dependencies:**

| Reference | Description |
|-----------|-------------|
| `radar_icons_001C00` | 512-byte tileset (VRAM upload) |
| `radar_layout_001E00` | 1,408-byte pre-built radar tilemap |
| `table_01ADA8` | Scene event location table (world map markers) |
| `enemy_clear_reward_table` | Per-scene reward data |

---

### 2.3 `sub_038259` — Radar Border Animation

**Proposed name:** `RadarBorderAnimate`

| Property | Value |
|----------|-------|
| Address | `$038259`–`$03827B` |
| Size | 35 bytes |
| Entry | `JSR` from radar display loop |
| Exit | `RTS` |

**Behavior:**

Called every frame while the radar screen is displayed. Reads a frame counter
from `$0036`, and on odd frames:

1. Increments a cycling index (0–28) stored on the stack.
2. Uses the index into `RadarBorderTileTable` to select a tile word.
3. Writes the tile to `$7F0A24` (a specific radar border tilemap cell).

This creates a shimmering/cycling animation on the radar border — cycling
through 29 distinct tile values representing different animation frames.

---

### 2.4 `sub_03827C` — Radar Plot Scene Markers

**Proposed name:** `RadarPlotSceneMarkers`

| Property | Value |
|----------|-------|
| Address | `$03827C`–`$03830D` |
| Size | 146 bytes |
| Entry | `JSR` from `RadarScreenSetup` |
| Exit | `RTS` |

**Behavior:**

Iterates through the scene's event location table (`table_01ADA8`) to plot
diamond-shaped markers on the radar for each discovered/active event.

For each 4-byte entry in the table:

1. Reads byte 3 (event flag ID, 7-bit).
2. Tests the event flag via `TestEventFlag_0200` — if set, **skips** this
   entry (event already completed).
3. Bounds-checks the X/Y coordinates (bytes 0 and 1) against the radar
   visible region (`$0018`–`$001E`).
4. Computes a tilemap offset: `((Y - top) >> 1 & $FE) << 5 + ((X - left) >> 1 & $FE) + $0216`.
5. Writes the marker tile `$2EE6` (diamond icon) to the WRAM tilemap.
6. Increments a BCD counter in `$0002` (total markers placed = jewel count
   for the displayed scene).

The loop terminates when a table entry has its high bit set (negative byte 0).

---

### 2.5 `sub_03830E` — Radar Plot Actors Iterator

**Proposed name:** `RadarPlotActors`

| Property | Value |
|----------|-------|
| Address | `$03830E`–`$03832E` |
| Size | 33 bytes |
| Entry | `JSR` from `RadarScreenSetup` |
| Exit | `RTS` |

**Behavior:**

Walks the active actor linked list (head at `$56`). For each actor, reads
`extendedFlags` (`$7F002A,X`):

- Bit 8 (`$0100`) set → calls `RadarPlotFriendlyActor` (player-allied NPC).
- Bit 9 (`$0200`) set → calls `RadarPlotEnemyActor` (visible enemy).

Follows the actor chain via `$0006,X` (next-actor pointer) until zero.

---

### 2.6 `sub_03832F` — Radar Plot Friendly Actor

**Proposed name:** `RadarPlotFriendlyActor`

| Property | Value |
|----------|-------|
| Address | `$03832F`–`$038378` |
| Size | 74 bytes |
| Entry | `JSR` from `RadarPlotActors` |
| Exit | `RTS` (carry always set) |

**Behavior:**

Plots a friendly-actor marker at the actor's world position:

1. Bounds-checks actor X (`$0014,X`) and Y (`$0016,X`) against the radar
   visible region.
2. Computes tilemap offset: same formula as scene markers.
3. Writes tile `$2AE7` (friendly marker — different color from diamonds) to
   the WRAM tilemap.
4. Sets carry (return flag for the iterator).

---

### 2.7 `sub_038379` — Radar Plot Enemy Actor

**Proposed name:** `RadarPlotEnemyActor`

| Property | Value |
|----------|-------|
| Address | `$038379`–`$0383D5` |
| Size | 93 bytes |
| Entry | `JSR` from `RadarPlotActors` |
| Exit | `RTS` |

**Behavior:**

Plots a visible-enemy marker, with an additional camera-visibility check:

1. Bounds-checks actor position against **camera bounds** (`cameraOffsetX/Y`,
   `cameraBoundsX/Y`) — only plots enemies currently on-screen.
2. Also bounds-checks against the radar visible region.
3. Computes tilemap offset and writes tile `$280D` (enemy marker).

The extra camera check means only enemies the player can currently see appear
on the radar.

---

### 2.8 `word_0383D6` — Radar Border Tile Table

**Proposed name:** `RadarBorderTileTable`

| Property | Value |
|----------|-------|
| Address | `$0383D6`–`$03840F` |
| Size | 58 bytes (29 × 2-byte entries) |
| Type | Word table |

Contains 29 VRAM tile indices used by `RadarBorderAnimate` to cycle the
radar border decoration. Values range from `$4B5B` to `$5CC4`, suggesting
these are tilemap entries with palette/priority bits encoding different
color phases of the animation.

---

## 3. Call Graph

```
system_core (main loop)
  └─ JSL OverworldInputHandler
       ├─ [Start] ─── JSR RadarScreenSetup
       │                ├─ JSR RadarPlotSceneMarkers
       │                │    └─ JSL TestEventFlag_0200 (external)
       │                ├─ JSR RadarPlotActors
       │                │    ├─ JSR RadarPlotFriendlyActor
       │                │    └─ JSR RadarPlotEnemyActor
       │                └─ COP RunBg3Script (reward counter)
       │
       │  (radar display loop)
       │  └─ JSR RadarBorderAnimate
       │       └─ reads RadarBorderTileTable
       │
       ├─ [L] ───── JSL OpenInventoryScreen (external)
       │
       └─ [Y] ───── JMP ItemUseDispatch (→ item-use-system.md)
```

---

## 4. Proposed Name Mapping

| Current Name | Proposed Name | Role |
|-------------|---------------|------|
| `func_038000` | `OverworldInputHandler` | Main input gate (Start/L/Y) |
| `sub_0380BF` | `RadarScreenSetup` | Load radar graphics, plot all markers |
| `sub_038259` | `RadarBorderAnimate` | Cycle radar border tiles per frame |
| `sub_03827C` | `RadarPlotSceneMarkers` | Plot event-table diamond markers |
| `sub_03830E` | `RadarPlotActors` | Walk actor list for radar plotting |
| `sub_03832F` | `RadarPlotFriendlyActor` | Plot allied NPC marker |
| `sub_038379` | `RadarPlotEnemyActor` | Plot visible enemy marker |
| `word_0383D6` | `RadarBorderTileTable` | 29-entry border animation frames |

---

## 5. External Dependencies

| External Symbol | Source File | Purpose |
|----------------|-------------|---------|
| `music_actors.IsMusicPlaying` | `music_actors.asm` | Guard: skip if music playing |
| `vblank_joypad.VBlankWaitAndJoypad` | `vblank_joypad.asm` | Frame sync |
| `vblank_joypad.EnableNmiAndJoypad` | `vblank_joypad.asm` | Enable NMI+joypad |
| `vblank_joypad.EnableNmiOnly` | `vblank_joypad.asm` | Enable NMI only |
| `inventory_overlay.OpenInventoryScreen` | `inventory_overlay.asm` | L-button handler |
| `vram_buffer_clear.ClearVramBufferPartial` | `vram_buffer_clear.asm` | Clear VRAM buffer |
| `system_core.UpdateFrameDialogue` | `system_core.asm` | Post-radar cleanup |
| `cop_handlers_script.TestEventFlag_0200` | `cop_handlers_script.asm` | Event flag test |
| `cop_handlers_script.TestFlag_0300` | `cop_handlers_script.asm` | Scene flag test |
| `table_01ADA8` | `table_01ADA8.asm` | Scene event location table |
| `enemy_clear_reward_table` | `enemy_clear_reward_table.asm` | Per-scene reward data |
| `radar_icons_001C00` | Data file | Radar icon tileset |
| `radar_layout_001E00` | Data file | Radar tilemap template |
| `system_strings.asciistring_01EAC6` | `system_strings.asm` | BG3 status bar script |
| `system_strings.asciistring_01EAD1` | `system_strings.asm` | BG3 reward counter script |
