# Utility Functions

> Small helper functions: dialogue display and VRAM buffer operations

**Source:** [`dialogue_display.asm`](../../../extracted/functions/dialogue_display.asm) · [`vram_buffer_clear.asm`](../../../extracted/functions/vram_buffer_clear.asm)

---

## dialogue_display.asm

| Address | Name | Size | Description |
|---------|------|------|-------------|
| `$02F048` | ShowDialogueFrame | 34 B | Single dialogue render frame. Saves joypad mask, sets DBR=`$81`, calls render pipeline, restores mask. Used by invent... |

---

### ShowDialogueFrame

Single dialogue render frame. Saves joypad mask, sets DBR=`$81`, calls render pipeline, restores mask. Used by inventory overlay loop.

**Algorithm:**
1. Save + zero joypad_mask_std
2. DBR ← `$81`
3. JSL UpdateFrame_Render
4. JSL sub_03E255 (dialogue box draw)
5. Restore joypad mask

**Source:**

```7:27:../../../extracted/functions/dialogue_display.asm
```

**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$065A` | RW | joypad_mask_std |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `OpenInventoryScreen` | Via UpdateFrame_Dialogue |
| `UpdateFrame_Render` | Bank system_core |

---

## vram_buffer_clear.asm


Both routines zero-word-fill the BG tilemap staging area at `$7F:0200`–`$7F:0800`.

| Address | Name | Size | Description |
|---------|------|------|-------------|
| `$02F06A` | ClearVramBufferPartial | 12 B | Partial VRAM buffer clear: zeros `$7F:0340`–`$7F:0800` (offset `$0140` from base). Preserves first 320 bytes. |
| `$02F076` | ClearVramBufferFull | 22 B | Full VRAM buffer clear: zeros entire `$7F:0200`–`$7F:0800` (2048 bytes). Called on inventory open and close. |

---

### ClearVramBufferFull

Full VRAM buffer clear: zeros entire `$7F:0200`–`$7F:0800` (2048 bytes). Called on inventory open and close.

**Algorithm:**
1. LDX `#$0000`
2. Shared zero loop to `$0800`

**Source:**

```12:28:../../../extracted/functions/vram_buffer_clear.asm
```

**Variables:**
| Location | Direction | Role |
|----------|-----------|------|
| `$7F:0200,X` | W | VRAM staging buffer |

**Cross-References:**
| Symbol | Relationship |
|--------|--------------|
| `OpenInventoryScreen` | JSL on open/close |
| `TabDrawCursor` | Writes into buffer |
