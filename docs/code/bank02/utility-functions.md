# Utility Functions

*Part of the [Bank $02 Documentation Suite](readme.md)*

> Small helper functions: dialogue display and VRAM buffer operations

**Source:** [`ShowDialogueFrame.asm`](../../../extracted/system/functions/ShowDialogueFrame.asm) · [`vram_buffer_clear.asm`](../../../extracted/system/functions/vram_buffer_clear.asm)

---

## ShowDialogueFrame.asm

| Address | Name | Description |
|---------|------|-------------|
| `$02F048` | ShowDialogueFrame | Single dialogue render frame. Saves joypad mask, sets DBR=`$81`, calls render pipeline, restores mask. Used by invent... |

---

### ShowDialogueFrame

Single dialogue render frame. Saves joypad mask, sets DBR=`$81`, calls render pipeline, restores mask. Used by inventory overlay loop.

**Algorithm:**
1. Save + zero joypad_mask_std
2. DBR ← `$81`
3. JSL UpdateFrameRender
4. JSL DialogStringRenderer (dialogue box draw)
5. Restore joypad mask


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$065A` | RW | joypad_mask_std |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `OpenInventoryScreen` | Via UpdateFrameDialogue |
| `UpdateFrameRender` | Bank system_core |

---

## vram_buffer_clear.asm


Both routines zero-word-fill the BG tilemap staging area at `$7F:0200`–`$7F:0800`.

| Address | Name | Description |
|---------|------|-------------|
| `$02F06A` | ClearVramBufferPartial | Partial VRAM buffer clear: zeros `$7F:0340`–`$7F:0800` (offset `$0140` from base). Preserves first 320 bytes. |
| `$02F076` | ClearVramBufferFull | Full VRAM buffer clear: zeros entire `$7F:0200`–`$7F:0800` (2048 bytes). Called on inventory open and close. |

---

### ClearVramBufferFull

Full VRAM buffer clear: zeros entire `$7F:0200`–`$7F:0800` (2048 bytes). Called on inventory open and close.

**Algorithm:**
1. LDX `#$0000`
2. Shared zero loop to `$0800`


**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$7F:0200,X` | W | VRAM staging buffer |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `OpenInventoryScreen` | JSL on open/close |
| `TabDrawCursor` | Writes into buffer |

---

## See Also

| Document | Relationship |
|----------|-------------|
| [scene-script.md](scene-script.md) | `DialogStringRenderer`, `UpdateFrameRender` render pipeline |
| [inventory-overlay.md](inventory-overlay.md) | `ShowDialogueFrame` caller during inventory loop |
| [inventory-menu.md](inventory-menu.md) | Inventory context where dialogue frames are drawn |
