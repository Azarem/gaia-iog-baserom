# Inventory Overlay — `inventory_overlay.asm`

> Overlay state sandwich — saves/restores WRAM around inventory screen

**Source:** [`inventory_overlay.asm`](../../../extracted/functions/inventory/inventory_overlay.asm)

---

## Overview

`OpenInventoryScreen` is the JSL entry point called from gameplay when the player opens inventory. It implements a **state sandwich** — save everything, run an isolated scene, restore everything.

### State Preservation Map

| Saved Region | Size | Source → Temp Location |
|---|---|---|
| Joypad state | 6 B | `$0656` / `$0658` → `$7E:38AC` / `$7E:38AE` |
| Joypad mask | 2 B | `$065A` → `$7E:38B0` |
| Joypad repeat timer | 2 B | `$0DBC` ↔ `$0DBE` (swap) |
| Direct-page vars | 16 B | `$004E`–`$005D` → `$7E:389C` |
| Camera positions | 12 B | `$06BE`–`$06C9` → `$7E:3890` |
| WRAM `$00:0E00` | 256 B | → `$7E:3490` |
| WRAM `$7E:3000` | 256 B | self-swap MVN |
| WRAM `$00:1000` | 4 KB | → `$7F:E000` |
| WRAM `$7F:1000` | 4 KB | self-swap MVN |
| WRAM `$00:0F00` | 256 B | → `$7E:3690` |
| WRAM `$7F:0F00` | 256 B | self-swap MVN |
| Palette buffer | 515 B | `$7F:0A00` → `$7E:38B4` |

---

## Memory Map

| Address | Name | Size | Description |
|---------|------|------|-------------|
| `$02ED02` | OpenInventoryScreen | 389 B | Master inventory orchestrator (JSL entry). Implements the state sandwich: save gameplay, switch to scene `$FF`, run i... |
| `$02EECC` | ReloadAbilityFX | 63 B | Post-close ability graphics reload. DMAs Dark Friar or Aura FX tiles and palette based on active ability `$00EA`. |
| `$02EF0B` | DrainActorQueue | 15 B | Walks actor linked list from `$5A` and zeroes frame counter `$0008` on each actor. |
| `$02EF1D` | SaveGameState | 149 B | Snapshots ~5.5 KB of gameplay WRAM, joypad state, camera, and palette buffer before inventory opens. |
| `$02EFB2` | RestoreGameState | 131 B | Inverse of SaveGameState: restores all six MVN regions, joypad, repeat timer, DP vars, and camera. |
| `$02F035` | RestorePaletteBuffer | 19 B | Copies 515 bytes of saved palette from `$7E:38B4` back to `$7F:0A00` after scene script may have overwritten it. |

---

### OpenInventoryScreen

Master inventory orchestrator (JSL entry). Implements the state sandwich: save gameplay, switch to scene `$FF`, run inventory UI loop, restore everything on exit.

**Algorithm:**
1. Disable HDMA; SaveGameState
2. Set inventory joypad mask `$0F00`
3. Push/pop `$06E4`, `$09EC`, `$0A00`, scene ID
4. scene_current ← `$FF`; SceneScriptNoMusic
5. Upload palette, zero camera, ClearVramBufferFull
6. Run actor init chain (chunk_03BAE1)
7. Loop UpdateFrame_Dialogue until `$0AE6` flag set
8. RestoreGameState, reload scene, event blocks, palette
9. ReloadAbilityFX, ClearVramBufferFull, map refresh
10. DrainActorQueue; exit flag `$FF`

**Source:**

```34:190:../../../extracted/functions/inventory/inventory_overlay.asm
```

**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$0644` | RW | scene_current |
| `$065C` | W | joypad_mask_inv |
| `$0AE6` | RW | Exit/tab flag |
| `$065A` | RW | joypad_mask_std |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `SaveGameState` | JSR |
| `RestoreGameState` | JSR |
| `ShowDialogueFrame` | Via UpdateFrame_Dialogue |
| `ClearVramBufferFull` | JSL |

### ReloadAbilityFX

Post-close ability graphics reload. DMAs Dark Friar or Aura FX tiles and palette based on active ability `$00EA`.

**Algorithm:**
1. If `$00EA = 0`: RTS
2. If 1 (Dark Friar): DMA misc_fx_1CC000 → VRAM `$4400`, copy palette
3. If 2 (Aura): DMA misc_fx_1CC480, alternate palette

**Source:**

```192:218:../../../extracted/functions/inventory/inventory_overlay.asm
```

**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$00EA` | R | Active ability |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `OpenInventoryScreen` | Caller on exit |
| `DmaWordToVram` | Bank scene_script |

### SaveGameState

Snapshots ~5.5 KB of gameplay WRAM, joypad state, camera, and palette buffer before inventory opens.

**Algorithm:**
1. Save joypad `$0656`/`$0658`/`065A` (zero live copies)
2. Swap repeat timer `$0DBC`↔`$0DBE`
3. Copy DP vars `$4E–$5D`, camera `$06BE–$06C9`
4. MVN six WRAM regions to scratch (see state map)
5. Copy palette `$7F:0A00` → `$7E:38B4`

**Source:**

```239:299:../../../extracted/functions/inventory/inventory_overlay.asm
```

**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$0656` | RW | Joypad held |
| `$0658` | RW | Joypad pressed |
| `$7E:3490` | W | Scratch save area |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `RestoreGameState` | Inverse |
| `OpenInventoryScreen` | Caller |

### RestoreGameState

Inverse of SaveGameState: restores all six MVN regions, joypad, repeat timer, DP vars, and camera.

**Algorithm:**
1. Restore joypad from `$7E:38AC`/`38AE`/`38B0`
2. Swap repeat timer back
3. Restore DP + camera
4. Inverse MVN for all six regions

**Source:**

```301:355:../../../extracted/functions/inventory/inventory_overlay.asm
```

**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$0656` | W | Joypad held |
| `$06BE` | W | Camera X |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `RestorePaletteBuffer` | Separate palette restore |
| `OpenInventoryScreen` | Caller |

### DrainActorQueue

Walks actor linked list from `$5A` and zeroes frame counter `$0008` on each actor.

**Algorithm:**
1. Load list head from `$5A`; exit if zero
2. Walk `$0006` chain via TCD
3. STZ `$0008` on each actor until list end

**Source:**

```241:258:../../../extracted/functions/inventory/inventory_overlay.asm
```

**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$5A` | R | Actor list head |
| `$08` | W | Frame counter per actor |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `OpenInventoryScreen` | Caller on exit |

---

## State Sandwich Pattern

The overlay follows a strict save → transform → run → restore sequence:

```
OpenInventoryScreen
  │
  ├─1─ SAVE ─────────────────────────────────────────────
  │     SaveGameState (WRAM, joypad, camera, palette)
  │     Push scene ID, $09EC, $0A00, $06E4 on stack
  │
  ├─2─ TRANSFORM ────────────────────────────────────────
  │     scene_current ← $FF (inventory scene)
  │     SceneScriptNoMusic (load inventory BG, no BGM)
  │     UploadCgramPalette, zero camera, ClearVramBufferFull
  │     Run actor init (chunk_03BAE1 helpers)
  │
  ├─3─ RUN ──────────────────────────────────────────────
  │     Loop: UpdateFrame_Dialogue until $0AE6 ≠ 0
  │       (TabCancel sets flag via COP SetFlagByte #00)
  │
  ├─4─ RESTORE ──────────────────────────────────────────
  │     RestoreGameState + RestorePaletteBuffer
  │     Pop scene ID → re-run SceneScriptNoMusic
  │     ApplyAllEventBlocks + PlaceBarrierTiles
  │     ReloadAbilityFX, ClearVramBufferFull, map refresh
  │     DrainActorQueue, exit flag $FF
  │
  └─5─ RETURN ───────────────────────────────────────────
        RTL to gameplay caller
```

This ensures the inventory scene can freely reconfigure PPU registers, BG modes, and `$7F:1000+` script space without corrupting overworld state.
