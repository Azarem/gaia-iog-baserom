# Utility Functions

*Part of the [Bank $02 Documentation Suite](README.md)*

> Small helper functions: dialogue display and VRAM buffer operations

**Source:** [`ShowDialogueFrame.asm`](../../../extracted/system/functions/ShowDialogueFrame.asm) · [`vram_buffer_clear.asm`](../../../extracted/system/functions/vram_buffer_clear.asm)

> **Evidence labels.** Each major section is tagged with the kind of claim it makes: **[ASM]** = directly observed in the extracted asm of this block; **[INFERRED]** = interpretation of behavior that is not literally encoded in the file; **[XREF]** = cross-file / engine-wide convention stated elsewhere (not provable from this file alone). Sections that mix kinds split them into separately tagged bullets or paragraphs. The `.asm` files in `extracted/` are authoritative; where prose and asm comments disagree, the asm wins.

---

## ShowDialogueFrame.asm

*Evidence: [ASM]*

| Address | Name | Description |
|---------|------|-------------|
| `$02F048` | ShowDialogueFrame | One dialogue render frame: save `joypadMaskStd`, set DBR=`$81`, `UpdateFrameRender`, `DialogStringRenderer`, restore mask. |

---

### ShowDialogueFrame

Saves processor flags and the data bank (`PHP`, `PHB`), saves `joypadMaskStd` (`$065A`) and zeroes it, sets DBR to `$81`, calls `UpdateFrameRender` then `DialogStringRenderer` (bank `$81` via long call), restores the saved joypad mask and data bank, returns with `RTL`.

**Input:** `Y` = dialogue string pointer (passed through to `DialogStringRenderer`; `UpdateFrameRender` preserves `Y` per asm comment).

**Algorithm:**

1. `PHP` / `PHB`; `REP #$20`; load `joypadMaskStd`, `STZ joypadMaskStd`, push saved mask
2. `SEP #$20`; push `$81`, `PLB` (DBR = `$81`)
3. `JSL UpdateFrameRender`
4. `JSL DialogStringRenderer`
5. Pop mask → `joypadMaskStd`; `PLB`; `PLP`; `RTL`

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$065A` | RW | `joypadMaskStd` — saved and cleared during the call |
| `Y` | In | Dialogue string pointer for `DialogStringRenderer` |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `warps_interaction.asm` | JSL caller (chest / item dialogue) |
| `combat_collision.asm` | JSL caller (`InteractionDamage_NPCChat` item strings) |
| `system_core.UpdateFrameRender` | Render-only frame tick before dialogue |
| `DialogStringRenderer` | Bank `$81` dialogue engine (included module) |

---

## vram_buffer_clear.asm

*Evidence: [ASM] + [INFERRED]*

Both routines word-fill `$7F:0200`–`$7F:0800` with zero (`REP #$20`, `STA bg3TilemapBuffer,X`, `INX`/`INX` until `CPX #$0800`). They preserve `X` and `P` via `PHX`/`PHP`/`PLP`/`PLX`. The asm note states the loop is assembled for 16-bit index registers and does not set `REP #$10` itself.

| Address | Name | Description |
|---------|------|-------------|
| `$02F06A` | ClearBg3TilemapBuffer_PreserveHud | Clears `$7F:0200+$0140` through `$7F:0800` (keeps first `$0140` bytes). |
| `$02F076` | ClearBg3TilemapBuffer_Full | Clears `$7F:0200` through `$7F:0800` (2048 bytes). |

Inferred: the preserved `$0140` bytes (320 bytes, 160 words) match the HUD tilemap span filled by `LoadHudTilemap` (asm comment in `vram_buffer_clear.asm`).

---

### ClearBg3TilemapBuffer_PreserveHud

Entry sets `LDX #$0140` and branches to the shared loop at `loc_02F07E` (same loop as full clear).

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `scene_lifecycle.asm` | JSL after scene-title dialogue teardown |
| `radar_map_screen.asm` | JSL before radar draw |
| `GlobalInputHandler.asm` | JSL when closing radar/pause overlay |

---

### ClearBg3TilemapBuffer_Full

Entry sets `TAX` with `#$0000` after loading zero in `A`, then falls into the shared loop.

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `scene_lifecycle.asm` `ClearSceneState` | JSL before `SceneScriptMain` |
| `inventory_overlay.asm` | JSL during inventory open/close setup |
| `sFA_diary_menu.asm` | JSL via diary wrapper |

---

## See Also

*Evidence: [XREF]*

| Document | Relationship |
|----------|-------------|
| [scene-script.md](scene-script.md) | Scene load calls `ClearBg3TilemapBuffer_Full` from `ClearSceneState` |
| [inventory-overlay.md](inventory-overlay.md) | Inventory path uses `ClearBg3TilemapBuffer_Full` and `SceneScriptNoMusic` |
| [bank00/system-core.md](../bank00/system-core.md) | `UpdateFrameRender` / `UpdateFrameDialogue` in `system_core.asm` |
