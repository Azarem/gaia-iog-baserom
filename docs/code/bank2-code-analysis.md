# Bank 2 Code Analysis — chunk_028000 & chunk_02CFD0

> Deep analysis of IOG's bank 02 system code, covering purpose, calling conventions,
> reference patterns, functional groupings, and proposed file splits.

## 1. Overview

Bank 02 contains two large compilation units that together form the bulk of the
game's non-actor system infrastructure:

| File | Address Range | Size (bytes) | Parts |
|------|--------------|--------------|-------|
| `chunk_028000.asm` | $028000–$02B20C | ~12,812 | 120 |
| `chunk_02CFD0.asm` | $02CFD0–$02E395 | ~5,062 | 89 |

**Total analyzed:** ~17,874 bytes, 209 named parts.

`chunk_028000` is the central hub of the game engine: it houses hardware math,
VBlank/NMI handling, decompression, the scene script interpreter, all scene
graphics loading commands, SPC700 music transfer, system initialization, event
block logic, warp/interaction handling, the full camera/scrolling engine, and map
coordinate helpers.

`chunk_02CFD0` is the **player movement and tile collision physics engine**. It
handles all 8 movement directions (cardinal + diagonal), slope handling, corner
auto-alignment, and the tile-probing primitives used by both files.

### Compilation Relationship

`chunk_028000.asm` is the parent compilation unit for bank 02. Its header
`?INCLUDE`s 17 other files including `chunk_02CFD0`. All code shares the same
`?BANK 02` directive, so `JSR $&label` (same-bank short calls) work freely
between the two files.

**Include list from chunk_028000.asm header:**
```
?INCLUDE 'array_01D3CE'        — event block definitions
?INCLUDE 'binary_01C384'       — binary data (static)
?INCLUDE 'chunk_02CFD0'        — player movement engine
?INCLUDE 'chunk_03BAE1'        — scene loading orchestrator (bank 3)
?INCLUDE 'cop_handlers_script' — COP script handler table
?INCLUDE 'dictionary_01EBA8'   — text dictionary A
?INCLUDE 'dictionary_01F54D'   — text dictionary B
?INCLUDE 'entry_points_00C418' — entry point label imports
?INCLUDE 'forced_walk'         — forced-walk actor routines
?INCLUDE 'func_02F048'         — dialogue display function
?INCLUDE 'itemget_table_01FD24'— item acquisition table
?INCLUDE 'scene_meta'          — scene metadata table
?INCLUDE 'scene_warps'         — warp rectangle data
?INCLUDE 'system_core'         — main game loop
?INCLUDE 'table_018000'        — display layer configuration table
?INCLUDE 'table_01ADA8'        — special warp/block table
```

---

## 2. External Callers

Functions in these files are called from across the codebase. The most-referenced
entry points:

| Function | Callers Outside Bank 2 | Purpose |
|----------|----------------------|---------|
| `func_028000` | `camera_scroll` | 16×8 hardware multiply |
| `func_028043` | `chunk_038000`, `chunk_03BAE1`, `sFC_actor_0BC9AE` | VBlank wait + joypad read |
| `func_028191` | `chunk_038000`, `chunk_03BAE1`, `diary_menu` | Enable NMI+auto-joypad |
| `func_0281A2` | `chunk_038000`, `chunk_03BAE1`, `diary_menu` | Enable NMI only |
| `func_0281AF` | `chunk_03BAE1` | Force blanking |
| `func_0281BC` | `chunk_03BAE1` | Enable display |
| `func_0281C9` | (self only) | Wait N frames |
| `func_0281D1` | `chunk_03BAE1`, self | 8×8 hardware multiply |
| `func_0281E8` | `smooth_follow`, `cop_handlers_collision` | 16÷8 hardware divide |
| `func_028270` | (self only) | Quintet-LZ decompress |
| `func_0283A2` | `chunk_03BAE1` | DMA to VRAM |
| `func_0283BB` | `chunk_03BAE1` | Scene script interpreter |
| `func_02897D` | `chunk_03BAE1` | Palette build + DMA |
| `func_02908E` | `system_core` | Load built-in SPC data |
| `func_02909B` | `chunk_03BAE1` | SPC700 data upload |
| `func_029DE2` | (self only) | DMA palette to CGRAM |
| `func_029E1D` | `system_core` | DMA OAM |
| `func_029E44` | `system_core` | WRAM init + constants |
| `func_029F31` | `system_core` | Hardware register init |
| `func_02A10A` | `chunk_038000` | Check music playing |
| `func_02A11B` | `chunk_03BAE1` | Text width measure |
| `func_02A1E9` | `chunk_03BAE1` | Apply event blocks |
| `func_02A220` | `chunk_03BAE1`, self | Execute event block swap |
| `func_02A310` | `system_core` | Flush queued VRAM writes |
| `func_02A363` | `chunk_03BAE1`, self | Event block lookup |
| `func_02A3A8` | `cop_handlers_actors` | Animated event block |
| `func_02A5DD` | `system_core` | Check warp/chest triggers |
| `func_02A5F0` | `chunk_03BAE1` | Apply special warp events |
| `func_02A957` | `chunk_03BAE1` | Init warp table |
| `func_02AB8A` | `chunk_03BAE1` | Camera full refresh |
| `func_02AC2E` | `system_core` | Camera smooth scroll |
| `func_02AF5F` | `system_core` | Render dirty tilemap strips |
| `func_02B038` | `system_core` | Sprite/OAM VRAM DMA |
| `func_02B0A3` | (self only) | Map coordinate → index |
| `func_02B0CF` | (self only) | Pixel → VRAM address |
| `func_02B0F6`–`func_02B14E` | (self only) | Map index navigation |
| `func_02CFD0` | (no direct JSL callers found — called via COP/actor dispatch) | Player movement entry |

---

## 3. Calling Conventions

### 3.1 JSL vs JSR Pattern

All inter-file calls use **JSL** (`$@label` = 3-byte long address). Within the
same bank 02 compilation unit, functions freely use **JSR** (`$&label` = 2-byte
short address) for intra-group calls.

The two chunks share bank 02, so `sub_02B168` (in chunk_028000) calls
`sub_02E1F1`, `sub_02E2AF`, etc. (in chunk_02CFD0) via `JSR $&label`.

### 3.2 Register State Conventions

| Convention | Where Used |
|-----------|-----------|
| `PHP`/`PLP` wrapper | Most public entry points — callee-saves processor flags |
| `PHD`/`PLD` wrapper | `func_02CFD0`, `func_02A3A8` — use direct page for local vars |
| `PHB`/`PLB` wrapper | Graphics functions that set DBR to $7E |
| A=16-bit (`REP #$20`) | Default for most arithmetic; many functions assume 16-bit A on entry |
| A=8-bit (`SEP #$20`) | Used for MMIO register writes, tile collision checks |
| RTL | Public (JSL-callable) entry points |
| RTS | Internal subroutines (JSR-callable) |
| COP opcodes | Actor-spawning functions: `COP [SpawnAfterFlags]`, `COP [SetEntryContinue]`, etc. |

### 3.3 Memory Conventions

| Address | Purpose |
|---------|---------|
| `$3E`–`$40` | General-purpose source pointer (addr + bank) |
| `$42`–`$44` | General-purpose destination pointer |
| `$46`–`$48` | SPC data source pointer |
| `$78`–`$7A` | Compressed data size / decompression target |
| `$00`–`$06` | Scratch registers (short-lived) |
| `$0E`–`$12` | Loop counters |
| `$18`–`$1E` | Tile coordinate scratch (x, y, col, row) |
| `$0656` | Joypad current frame bits |
| `$0658` | Joypad held-repeat bits |
| `$0660` | Joypad raw state |
| `$0664`–`$066A` | Graphics loading parameters (start, end, VRAM offset, flags) |
| `$068A`–`$0690` | Camera position/limits |
| `$0693`–`$069D` | Map geometry (rows, cols per layer) |
| `$069E`–`$06B8` | Map buffer pointers and VRAM layout |
| `$06BE`–`$06D2` | Camera target position and scroll delta |
| `$06EE`–`$06EF` | Scene display flags |
| `$06F2`–`$06F6` | Music track IDs |

### 3.4 Player Movement Variables (chunk_02CFD0)

| Variable | Purpose |
|----------|---------|
| `$20` | Horizontal movement delta (speed × direction) |
| `$22` | Player X position (sub-pixel, ×4 scale) |
| `$24` | Vertical movement delta |
| `$26` | Player Y position (sub-pixel, ×4 scale) |
| `$AA`–`$AB` | Movement state flags |
| `$1A` | Probe X coordinate (tile-space) |
| `$1E` | Probe Y coordinate (tile-space) |
| `$00`–`$04` | Scratch: tile index, alignment offset |
| `player_speed_ew` | East-West speed variable |
| `player_speed_ns` | North-South speed variable |
| `player_flags` | Player state bitmask |
| `player_actor` | Actor slot index for player character |
| `player_x_tile` / `player_y_tile` | Player tile coordinates |
| `player_x_pos` / `player_y_pos` | Player pixel coordinates |

---

## 4. Functional Group Analysis — chunk_028000.asm

### Group 1: Hardware Math Utilities ($028000–$0281E8)

**Purpose:** Thin wrappers around SNES hardware multiply/divide registers.

| Part | Size | Description |
|------|------|-------------|
| `func_028000` | 59 B | 16×8 multiply with 24-bit result (uses WRMPYA/WRMPYB + WRDIV for overflow) |
| `func_0281D1` | 23 B | Simple 8×8 multiply → 16-bit result |
| `func_0281E8` | 22 B | 16÷8 unsigned divide → quotient + remainder |
| `func_0281FE_noref` | 73 B | 16÷16 fixed-point software division (unreferenced) |
| `func_028247_noref` | 41 B | 128-bit increment at $040F (unreferenced — likely debug counter) |

**Internal calls:** None between these functions.
**External callers:** `func_028000` from `camera_scroll`; `func_0281D1` from
`chunk_03BAE1` and many internal users; `func_0281E8` from `smooth_follow` and
`cop_handlers_collision`.

### Group 2: VBlank / NMI / Display / Joypad ($02803B–$0281C9)

**Purpose:** Frame synchronization, hardware register updates during VBlank, and
joypad state machine.

| Part | Size | Description |
|------|------|-------------|
| `func_02803B` | 8 B | VBlank entry (skip NMI wait — used for partial updates) |
| `func_028043` | 334 B | **Main VBlank handler**: wait for NMI, write Mode 7 registers ($C2–$CD → $M7A–$M7Y), read composite joypad with auto-repeat logic |
| `func_028191` | 17 B | Enable NMI + auto-joypad read ($81 → NMITIMEN) |
| `func_0281A2` | 13 B | Enable NMI only ($01 → NMITIMEN) |
| `func_0281AF` | 13 B | Force blanking ($00 → INIDISP) |
| `func_0281BC` | 13 B | Enable display ($80 → INIDISP) |
| `func_0281C9` | 8 B | Wait A frames (loops calling func_028043) |

**Joypad auto-repeat logic** (in func_028043): Merges button masks from
addresses $0DA6–$0DB4 against raw state $0660, tracks hold duration at $0662,
and clears repeat bits after 12 frames via `joypad_mask_inv`.

**External callers:** Very widely called — the NMI/display functions are used by
`system_core`, `chunk_038000`, `chunk_03BAE1`, `diary_menu`, `title_screen`.

### Group 3: Quintet-LZ Decompression ($028270–$02833B)

**Purpose:** Decompress tile/graphics data from ROM into RAM at $7E:xxxx.

| Part | Size | Description |
|------|------|-------------|
| `func_028270` | 110 B | Main decompression entry: sets DBR=$7E, reads bitstream via helpers, writes decompressed output |
| `sub_0282DE` | 93 B | Variable-length bit field extraction (1–8 bits from stream) |
| `sub_02833B` | 103 B | Length/offset field extraction for back-references |

**Algorithm:** Reads a bitstream from `[$3E]`, decodes literal bytes or
length+offset back-references. Uses `$72` as a bit position tracker that shifts
right through the current byte. Output written linearly to X-indexed destination,
with a parallel index at `($74)` for reference window lookup.

**Only called via JSL** from within chunk_028000 (scene graphics loaders).

### Group 4: Scene Script Engine ($0283A2–$028D3D)

**Purpose:** Bytecode interpreter that drives scene setup — parsing per-scene
command streams to load graphics, tilemaps, palettes, music, and configure display
layers.

| Part | Size | Description |
|------|------|-------------|
| `func_0283A2` | 25 B | Generic DMA word-transfer to VRAM (channel 0) |
| `func_0283BB` | 44 B | **Main script interpreter loop**: find scene, dispatch commands via table |
| `func_0283E7` | 47 B | Variant interpreter — skips music command ($11/func_028B6D) |
| `table_028416` | 48 B | 24-entry dispatch table (word pointers to command handlers) |
| `func_028446` | 21 B | Command $13: conditional load (test flag → skip or execute $15) |
| `func_02845B` | 2 B | Command $14: NOP (skip 1 byte) |
| `sub_028CE7` | 11 B | **Read next script byte** from `[$3A], Y` and advance Y |
| `sub_028CF2` | 75 B | **Find current scene** in script data — linear scan matching `scene_current` |
| `func_028D3D` | 82 B | **Skip-to-command**: advance Y past N commands of varying sizes (used for conditional branches) |
| `sub_028D8F` | 50 B | **Load 3-byte pointer** from script stream into `(X) = addr+bank`, with bank fixup for $70–$9F mirror range |
| `sub_028DC1` | 41 B | **Cache check**: compare `($3E,$40)` against `(X)` — returns carry=changed (needs reload) |

**Script command dispatch table ($028416):**

| Index | Handler | Purpose |
|-------|---------|---------|
| $02 | `func_028A6D` | Configure display layers (BG mode, windows, etc.) |
| $03 | `func_02845D` | Load BG tile data (multi-mode) |
| $04 | `func_0286C3` | Load BG tilemap |
| $05 | `func_028712` | Load dual-layer tilemap |
| $06 | `func_0287BC` | Full scene graphics (map geometry + tiles) |
| $0E | `func_028B69` | Skip 3 bytes (placeholder) |
| $10 | `func_028BE4` | Load sprite graphics |
| $11 | `func_028B6D` | Load music / SPC data |
| $13 | `func_028446` | Conditional flag-test load |
| $14 | `func_02845B` | NOP |
| $15 | `func_028D3D` | Seek to indexed command |
| $17 | `func_028C30` | Load character tile data |

### Group 5: Scene Graphics Loading ($02845D–$029060)

**Purpose:** The command handler implementations for loading tile graphics,
tilemaps, palettes, and map data into VRAM and WRAM. These are the workhorses
called by the scene script engine.

#### Subgroup 5A: BG Tile Data Loading

| Part | Size | Description |
|------|------|-------------|
| `func_02845D` | 245 B | **Command $03 handler**: Multi-mode BG tile loader. Reads VRAM offset, range, mode byte. Mode 0: horizontal strip. Mode 1: two-row block. Mode 2: full 4bpp page. Mode 3: raw copy. Decompresses if needed, DMAs to VRAM. |
| `sub_028552` | 3 B | Entry shim → func_028560 |
| `func_028555` | 11 B | Check interleaved graphics flag ($06EE bit $0800) → branch to planar path |
| `func_028560` | 50 B | **DMA tile strip to VRAM**: configures channel 0 word-mode DMA from `($3E+offset)` to VRAM address `($0668)` |
| `func_028592` | 73 B | **Load full 4bpp page**: decompress → DMA $4000 bytes to VRAM $2000 (byte mode for mode-7 format) |
| `func_0285DB` | 177 B | **Planar tile loader**: decodes interleaved 2bpp+2bpp format to SNES 4bpp planar. Reads from `$7E:7000`, interleaves bitplanes, writes to `$7E:A000`, then DMAs to VRAM. |
| `sub_02868C` | 55 B | **Palette-to-attribute mapper**: builds 256-byte attribute table at `$7E:2800` from tilemap metadata |

#### Subgroup 5B: Tilemap Loading

| Part | Size | Description |
|------|------|-------------|
| `func_0286C3` | 79 B | **Command $04 handler**: Load single-layer tilemap. Reads start/end/VRAM offsets, DMAs tilemap data via `sub_028DEA`. Special case for $0020 offset: copies row. |
| `func_028712` | 170 B | **Command $05 handler**: Load dual-layer tilemap. Reads separate parameters for BG1 and BG2, each with cache check. Decompresses and DMAs independently. |
| `func_0287BC` | 217 B | **Command $06 handler**: Full scene graphics — loads map geometry (dimensions, layer config), tile data, and tilemap. Complex multi-path logic depending on layer count and interleave flag. |
| `sub_028895` | 32 B | Store map geometry + decompress tileset for one layer |
| `func_0288B5` | 95 B | Handle empty geometry (size=0): compute tileset size, DMA, store bounds |
| `sub_028914` | 18 B | Write map bounds (X size, Y size) into `map_bounds_x/y + offset` |
| `func_028926` | 87 B | Low-VRAM tileset DMA — word-write mode for Mode 0/low VRAM addressing |

#### Subgroup 5C: Graphics Support

| Part | Size | Description |
|------|------|-------------|
| `func_02897D` | 240 B | **Palette rendering**: converts 4bpp palette definition to SNES format, DMAs $4000 bytes to VRAM $0000 for color math. Complex nested loops over tile columns/rows. |
| `func_028A6D` | 252 B | **Command $02 handler**: Read `table_018000` entry, configure TM, TS, TMW, TSW, CGWSEL, CGADSUB, BGMODE, BG1SC, BG2SC, and scene display flags. Very complex — sets up the entire PPU layer configuration. |
| `func_028B69` | 4 B | **Command $0E handler**: Skip 3 script bytes (NOP placeholder) |
| `func_028BE4` | 76 B | **Command $10 handler**: Load sprite tile graphics — cache check + decompress + DMA to VRAM $4000 |
| `func_028C30` | 183 B | **Command $17 handler**: Load character-specific tile data. Computes VRAM address from parameters, supports multi-bank character sets (BG1/BG2/both). |

#### Subgroup 5D: DMA & Cache Helpers

| Part | Size | Description |
|------|------|-------------|
| `sub_028DEA` | 133 B | **RAM-to-WRAM DMA**: If source is in high ROM ($80+), uses channel 0 DMA to WMADDL. If source is in low memory, calls `$0402` (MVN block move handler). |
| `sub_028E6F` | 37 B | **Graphics cache lookup**: check if `($3E,$40)` matches any of 4 cached source slots at `$0084`–`$008F` |
| `sub_028E94` | 36 B | **Graphics cache store**: write `($3E,$40)` into round-robin cache slot (4-entry ring at `$0084`) |
| `sub_028EB8` | 96 B | **VRAM save/restore**: Read VRAM data back into WRAM `$7F:4000+` ring buffer (for cache-based tile swapping) |
| `sub_028F18` | 43 B | **VRAM-to-RAM DMA**: read-back from VRAM into $7F ring buffer |
| `sub_028F43` | 16 B | Compute ring buffer WRAM address from cache index |
| `sub_028F53` | 84 B | **Restore cached VRAM data**: read from ring buffer, DMA back to original VRAM address. Handles >$2000 byte spans. |
| `sub_028FA7` | 38 B | **DMA from $7F WRAM to VRAM**: simple channel 0 word-mode transfer |
| `sub_028FCD` | 83 B | **Tilemap attribute update**: rebuild attribute bytes for 4×N tile region in WRAM tilemap buffer |
| `sub_029020` | 20 B | **Reload map data**: refresh both layers' map data from source |
| `sub_029034` | 44 B | Reload layer 0 map strip from source pointer |
| `sub_029060` | 46 B | Reload layer 1 map strip from source pointer (with zero-skip for overlay) |

### Group 6: SPC700 Music Transfer ($028B6D–$02919B + binary_029210)

**Purpose:** Upload music data to the SPC700 sound processor using the IPL boot
protocol.

| Part | Size | Description |
|------|------|-------------|
| `func_028B6D` | 119 B | **Command $11 handler**: Music load orchestrator. Cache-checks track ID. If changed: fade out current music, wait, reset APU, call upload routine, restart playback. |
| `func_02908E` | 13 B | Load built-in SPC engine (binary_029210) to APU |
| `func_02909B` | 256 B | **Full SPC transfer**: handshake with APU, multi-block upload with address/size headers, handles bank-crossing and IPL protocol timing |
| `sub_02919B` | 117 B | **Initial IPL upload**: first-stage SPC transfer (before main data), handles BBAA handshake |
| `binary_029210` | 3,026 B | Embedded SPC700 sound engine binary |

**Protocol:** Uses APU I/O ports ($2140–$2143) with IPL-compatible handshake
(wait for $BBAA, then alternating acknowledge bytes). Supports multi-block
transfers with 4-byte headers (size, destination address).

### Group 7: System Initialization ($029DE2–$029F5A)

**Purpose:** One-time boot initialization — clear WRAM, set default register
values, initialize game variables.

| Part | Size | Description |
|------|------|-------------|
| `func_029DE2` | 59 B | DMA palette from `$7F:0A00` to CGRAM + write fixed color (COLDATA) |
| `func_029E1D` | 39 B | DMA OAM table from `$0422` to OAM |
| `func_029E44` | 65 B | **System variable init**: clear WRAM via fixed-byte DMA, then load `constants_029E85` table into RAM |
| `constants_029E85` | 138 B | Initialization constant table: 33 entries of `(address, value)` pairs — sets up map pointers, joypad masks, scene pointer, default bounds, etc. |
| `sub_029F0F` | 34 B | Fixed-byte DMA fill (writes repeated byte pattern via WMDATA) |
| `func_029F31` | 29 B | Load hardware register defaults from `struct_029F5A` |
| `binary_029F4E` | 12 B | Small lookup table (cache slot indices) |
| `struct_029F5A` | 230 B | Hardware register initialization table: 76 entries of `(register_index, value)` |

### Group 8: Music Playback Actors ($02A040–$02A10A)

**Purpose:** COP-based actor coroutines that manage music playback lifecycle
(spawn render-sync actors, wait for SPC completion).

| Part | Size | Description |
|------|------|-------------|
| `func_02A040` | 165 B | Music playback actor: spawns visual-sync child (`func_03E1D6`), blocks joypad, waits for SPC `$FF` signal, manages respawn loop |
| `func_02A0E5` | 37 B | Music render-sync actor: waits $48 frames, clears flag, calls `UpdateFrame_Render` + `sub_03E255`, dies |
| `func_02A10A` | 17 B | Query: returns carry set if music is still playing (`$06FA ≠ 0` or `$09EC` bit 7 set) |

### Group 9: Text Width Measurement ($02A11B–$02A172)

**Purpose:** Measure rendered pixel width of dialogue text (accounting for
dictionary-compressed tokens) for dialogue box sizing.

| Part | Size | Description |
|------|------|-------------|
| `func_02A11B` | 78 B | Compare target scene to current; if different, count text width and add to `$0998` for scroll offset calculation. Opens dialogue box via `sub_03E255`. |
| `asciistring_02A169` | 9 B | Format string: `[DLG:7,7][SIZ:A,1][SFX:0]` |
| `sub_02A172` | 119 B | **Text width counter**: walks text stream byte-by-byte. Handles control codes ($C0+ range), dictionary lookups ($D6 → `dictionary_01EBA8`, $D7 → `dictionary_01F54D`), counts visible characters into `$00`. |

### Group 10: Event Block System ($02A1E9–$02A5B1)

**Purpose:** Toggle map tile graphics based on event flags — opening passages,
revealing chests, etc.

| Part | Size | Description |
|------|------|-------------|
| `func_02A1E9` | 55 B | **Iterate all event blocks**: scan flag byte array at `$0A20`, for each set bit call `func_02A363` to look up the block definition, then `func_02A220` to apply it |
| `func_02A220` | 240 B | **Apply event block**: swap foreground/background tile bytes in map RAM (`$7E:A000` / `$7F:C000`). Handles both layer-0-only and dual-layer (with overlay zero-skip) modes. Loops over columns/rows. |
| `func_02A310` | 83 B | **Flush VRAM write queue**: drain queued `(VRAM_addr, tile_data)` entries from `$0800`+ stack. Also handles single-tile pair writes at `$0902–$090C`. |
| `func_02A363` | 69 B | **Event block lookup**: index into `array_01D3CE` by block ID, verify scene match, extract geometry (position, size, layer flag). Returns carry clear if applicable. |
| `func_02A3A8` | 357 B | **Animated event block**: like `func_02A220` but generates VRAM write queue entries for visible tiles and calls `UpdateFrame_Dialogue` to animate the change. Handles both direct and overlay-layer modes. |
| `sub_02A50D` | 126 B | Bounds check a tile against camera viewport; if visible, queue 4 VRAM tile writes |
| `sub_02A58B` | 38 B | Advance column pointer (decrement width counter, move tile indices right) |
| `sub_02A5B1` | 44 B | Advance row pointer (decrement height counter, reset column, move tile indices down) |

### Group 11: Warp / Chest Interaction System ($02A5DD–$02AB25)

**Purpose:** Detect player entering warp zones, handle chest opening, trigger
scene transitions and forced walks.

| Part | Size | Description |
|------|------|-------------|
| `func_02A5DD` | 19 B | **Top-level trigger check**: call `sub_02A97B` (warp check) then `sub_02A65D` (chest interaction) |
| `func_02A5F0` | 109 B | **Special event warps**: scan `table_01ADA8` for flagged blocked-passage entries, place barrier tiles (`$FE/$FF/$FC/$FD`) on map |
| `sub_02A65D` | 347 B | **Chest interaction handler**: check if player faces chest tile ($F8/$F9 pair), look up chest definition, test/set event flag. Shows dialogue for item name/key item. Can spawn chest-opening actor for animated chests. |
| `func_02A7B8` | 219 B | **Chest-opening COP actor**: spawn visual child, lock joypad, play chest music, wait for APU, restore player control, die |
| `func_02A893` | 21 B | **Chest dialogue actor**: wait, remove flag, display item text, die |
| `sub_02A8A8` | 10 B | Set actor animation state (write function pointer + clear frame counter) |
| `sub_02A8B2` | 165 B | **Draw chest tiles**: write 4 tiles (open/closed lid) to map data and queue VRAM update, call `UpdateFrame_Render` |
| `func_02A957` | 36 B | **Init warp table**: load `scene_warps` base pointer and scan to find end-of-table marker |
| `sub_02A97B` | 166 B | **Warp rectangle check**: test player position against two warp table sections (standard 12-byte entries, extended 13-byte entries). Computes pixel-level overlap. |
| `sub_02AA21` | 57 B | Convert warp rectangle (tile coords + tile sizes) → pixel bounds |
| `func_02AA5A` | 203 B | **Execute warp**: copy warp parameters to scene transition variables ($scene_next, $064C–$0652), save return-warp data ($0B08–$0B11). Handle animated vs instant transitions. |
| `sub_02AB25` | 101 B | **Start forced walk**: set player flags, dispatch to directional ForcedWalk actors based on warp direction byte |

### Group 12: Camera / Scrolling Engine ($02AB8A–$02B038)

**Purpose:** Manage camera position, smooth scrolling, and incremental
VRAM tilemap updates as the camera moves.

| Part | Size | Description |
|------|------|-------------|
| `func_02AB8A` | 164 B | **Full camera refresh**: clamp camera to map bounds, render all 32 columns via DMA loop. Used on scene load. |
| `func_02AC2E` | 158 B | **Smooth scroll update**: compute camera delta, clamp to ±16px/frame, trigger column/row updates when crossing tile boundaries |
| `sub_02ACCC` | 37 B | Vertical row update: compute row address from camera Y, call `sub_02AD0B` |
| `sub_02ACF1` | 26 B | Horizontal column update: compute column from camera X, call `sub_02ADA2` |
| `sub_02AD0B` | 130 B | **Render one scroll column**: compute map index, DMA 16 tiles from map buffer to VRAM tilemap. Handles both BG1 and BG2 nametables. |
| `sub_02AD8D` | 21 B | **Map index wrap**: if index exceeds map extent, wrap around |
| `sub_02ADA2` | 335 B | **Render one scroll row**: complex function that computes map indices for a 16-tile-wide vertical strip, handles wrap-around at map edges, writes tile data + attributes to both BG nametables. Largest single function in the scrolling engine. |
| `sub_02AEF1` | 53 B | Horizontal tilemap segment fill (right half of a row) |
| `sub_02AF26` | 57 B | Vertical tilemap segment fill (column stride) |
| `func_02AF5F` | 104 B | **Render all dirty strips**: DMA all pending tilemap buffer rows/columns to VRAM, clear dirty flags |
| `sub_02AFC7` | 57 B | Horizontal DMA: 2 × 64-byte chunks (word mode) |
| `sub_02B000` | 56 B | Vertical DMA: 2 × 128-byte chunks (byte mode) |
| `func_02B038` | 107 B | **Sprite VRAM DMA**: transfer sprite tile data from $7F to VRAM $7800+ |

### Group 13: Map Coordinate Helpers ($02B0A3–$02B14E)

**Purpose:** Convert between tile coordinates and linear map buffer indices.
Used extensively by event blocks, scrolling, chest interaction, and collision.

| Part | Size | Description |
|------|------|-------------|
| `func_02B0A3` | 44 B | **(col, row) → map index**: multiply row by map width (`$0693`), add column. Returns X = byte offset. |
| `func_02B0CF` | 39 B | **Pixel (x, y) → VRAM address**: compute VRAM nametable address from pixel coordinates for queued tile writes |
| `func_02B0F6` | 29 B | **Move index right**: increment low nibble; if overflow, advance to next row-start |
| `func_02B113` | 31 B | **Move index left**: decrement low nibble; if underflow, retreat to previous row-end |
| `func_02B132` | 28 B | **Move index down (layer 0)**: add 16 to low byte; if overflow, add map width to high byte |
| `func_02B14E` | 26 B | **Move index down (layer 1)**: same logic but uses `$0695` (layer 1 width) |

### Group 14: Collision Probing (Boundary) ($02B168–$02B1BB)

**Purpose:** Probe tiles in the rightward and leftward directions to detect
passable/impassable terrain. These are called from `func_02D6DC` and
`sub_02DB80` in chunk_02CFD0.

| Part | Size | Description |
|------|------|-------------|
| `sub_02B168` | 83 B | **Probe right**: check tiles at player right edge + 8px offset. Cascade through multiple tile probes looking for type $0A (passable ramp) or $05 (wall). |
| `sub_02B1BB` | 83 B | **Probe left**: mirror of `sub_02B168` for leftward movement. Checks for types $0A, $05, $06, $09. |

**Cross-file dependency:** These call `sub_02E1F1`, `sub_02E1A9`, `sub_02E2AF`,
`sub_02E2FC`, `sub_02E313`, `sub_02E32B`, `sub_02E343`, `sub_02E35D`,
`sub_02E263`, `sub_02E285`, `sub_02E20D`, `sub_02E237` — all in
`chunk_02CFD0.asm`. This is the primary cross-chunk JSR dependency.

---

## 5. Functional Group Analysis — chunk_02CFD0.asm

### Group A: Player Movement Dispatcher ($02CFD0)

| Part | Size | Description |
|------|------|-------------|
| `func_02CFD0` | 104 B | **Main entry**: saves registers, sets direct page to 0. If `$20` (H-delta) is negative → call `sub_02DB80` (left-diagonal), positive → call `func_02D6DC` (right-diagonal). Then updates player actor position from `$22/$26`. If `$24` (V-delta) is negative → call `sub_02D038` (downward), positive → call `sub_02D376` (rightward/upward). |

### Group B: Downward (South) Movement ($02D038–$02D1CE)

Handles player moving south, dispatching to tile-type-specific handlers.

| Part | Size | Description |
|------|------|-------------|
| `sub_02D038` | 132 B | **South dispatcher**: probe tile below player. Branch to specific handler by collision type: $06→wall-south, $03→slope-right, $0C→slope-left, $09→wall-north (redirect), $02→interact, $0E+→solid wall. Default: apply movement. |
| `sub_02D0BC` | 24 B | **Snap Y on collision**: align `$26` to next tile boundary downward, zero `$24` |
| `func_02D0D4` | 26 B | Tile type $02 (interact): redirect player to alternate animation state |
| `func_02D0EE` | 52 B | Tile type $03 (slope-right going south): check sub-tile alignment, compute correction, apply or set slope flag |
| `func_02D122` | 102 B | Tile type $0C (slope-left going south): similar to $03 but uses `$09C6` accumulator for multi-frame slope tracking |
| `func_02D188` | 70 B | Tile type $06 (wall-south): probe adjacent tiles, redirect to diagonal handler or snap |
| `func_02D1CE` | 30 B | Tile type $06 (nudge variant): check `$AB` flags for approach direction |
| `rep_stz_rts_1` | 6 B | `STZ player_speed_ns; RTS` |

### Group C: Upward (North) Movement ($02D1F2–$02D238)

| Part | Size | Description |
|------|------|-------------|
| `func_02D1F2` | 70 B | Tile type $09 (wall-north going north): probe, redirect, or snap |
| `func_02D238` | 8 B | Cross-reference shim: probe next tile then jump to $09 handler |
| `rep_stz_rts_2` | 6 B | `STZ player_speed_ns; RTS` |

### Group D: Alignment Helpers ($02D246–$02D354)

Shared subroutines for computing sub-tile snap offsets.

| Part | Size | Description |
|------|------|-------------|
| `sub_02D246` | 17 B | Compute negative Y snap offset from `$1E` (used after eastward collision) |
| `sub_02D257_noref` | 104 B | Unused: diagonal snap computation |
| `sub_02D2BF` | 124 B | **EW auto-align when blocked NS**: if player is partially overlapping a tile boundary horizontally, nudge them left or right to clear the obstruction. Checks approach direction ($04) and nearby tile types. |
| `sub_02D33B` | 25 B | Snap coordinate toward lower boundary (+8, align to $40) |
| `sub_02D354` | 34 B | Snap coordinate toward upper boundary (−8, align to $40) |

### Group E: Rightward (East) Movement ($02D376–$02D69A)

Handles player moving east with all collision tile types.

| Part | Size | Description |
|------|------|-------------|
| `sub_02D376` | 116 B | **East dispatcher**: probe tiles right of player. Branch by type: $09, $03, $0C, $06, $02, $08, $0E+. Many sub-cases. |
| `func_02D3EA` | 13 B | Wall collision east: flag actor, check auto-align |
| `sub_02D3F7` | 20 B | Snap X east + zero NS speed |
| `func_02D40B` | 26 B | Tile $02 east: redirect to alternate state |
| `func_02D425` | 41 B | Tile $08 (stairs) east: set stair flag, redirect player |
| `func_02D44E` | 49 B | Tile $03 (slope) east: check alignment, compute correction |
| `func_02D47F` | 91 B | Tile $0C (slope) east: with `$09C6` slope accumulator |
| `func_02D4DA` | 74 B | Tile $09 east: wall-north interaction while moving east |
| `func_02D524` | 12 B | Secondary $09 check: probe then branch |
| `func_02D536` | 70 B | Tile $06 east: wall-south interaction while moving east |
| `func_02D57C` | 2 B | Jump shim to loc_02D54C |
| `rep_stz_rts_3` | 6 B | `STZ player_speed_ns; RTS` |
| `rep_stz_rts_4` | 6 B | `STZ player_speed_ns; RTS` |
| `sub_02D584` | 117 B | **NS auto-align when blocked EW** (east variant): mirror of `sub_02D2BF` |
| `sub_02D5F9` | 92 B | Compute east snap alignment offset |
| `func_02D655` | 69 B | Fine X position adjust after eastward snap |
| `func_02D69A` | 66 B | Fine X position adjust after westward snap |

### Group F: Leftward (West) Movement ($02D6DC–$02DB22)

Handles player moving west — largest movement group due to slope/ramp complexity.

| Part | Size | Description |
|------|------|-------------|
| `func_02D6DC` | 132 B | **West dispatcher**: probe left, branch by tile type. Checks ramp probes (`sub_02B1BB`) first. |
| `sub_02D760` | 28 B | Snap X west + zero EW speed |
| `func_02D77C` | 29 B | Tile $07 (ladder) west: set auto-climb state |
| `func_02D799` | 72 B | Tile $09 diagonal going west (north-west bias) |
| `func_02D7E1` | 6 B | $09 sub-variant: set direction flag |
| `rep_stz_rts_5` | 6 B | `STZ player_speed_ew; RTS` |
| `func_02D7ED` | 80 B | Tile $06 diagonal going west (south-west bias) |
| `rep_stz_rts_6` | 6 B | `STZ player_speed_ew; RTS` |
| `func_02D843` | 252 B | **Ramp left (down slope)**: complex diagonal movement — detect ramp entry, compute sub-pixel Y offset, set $1000 player_flags, handle edge cases where ramp meets wall |
| `func_02D93F` | 57 B | **Ramp left (up slope)**: similar to `func_02D843` but opposite Y direction |
| `func_02D978` | 14 B | Redirect to $09 handler |
| `func_02D986` | 260 B | **Ramp right (down slope)**: mirror of `func_02D843` for opposite slope direction |
| `func_02DA8A` | 53 B | **Ramp right (up slope)**: minor variant |
| `func_02DABF` | 14 B | Redirect to $06 handler |
| `sub_02DACD` | 85 B | NS auto-align when blocked EW (west variant) |
| `sub_02DB22` | 94 B | Compute west snap alignment offset |

### Group G: Down-Left Diagonal ($02DB80–$02DC2C)

| Part | Size | Description |
|------|------|-------------|
| `sub_02DB80` | 144 B | **Down-left dispatcher**: probe bottom-left quadrant tiles. Uses `sub_02B168` first for ramp detection, then dispatches by tile type. |
| `sub_02DC10` | 28 B | Snap X + zero EW speed (down-left) |
| `func_02DC2C` | 29 B | Tile $07 (ladder) down-left |
| `func_02DC49` | 84 B | Tile $06 diagonal from down-left approach |
| `func_02DC9D` | 86 B | Tile $09 diagonal from down-left approach |

### Group H: Up-Left / Remaining Diagonals ($02DCF3–$02DF99)

| Part | Size | Description |
|------|------|-------------|
| `func_02DCF3` | 271 B | **Ramp up-left**: complex slope handler with multi-probe, sub-pixel correction, and wall-edge snap |
| `func_02DE02` | 65 B | Ramp edge case (up-left minor variant) |
| `func_02DE43` | 14 B | Redirect to $06 handler |
| `func_02DE51` | 267 B | **Ramp down-right**: mirror of `func_02DCF3` |
| `func_02DF5C` | 61 B | Ramp edge case (down-right minor variant) |
| `func_02DF99` | 14 B | Redirect to $09 handler |

### Group I: Diagonal Auto-Align & Fine Adjust ($02DFA7–$02E0FA)

| Part | Size | Description |
|------|------|-------------|
| `sub_02DFA7` | 79 B | NS nudge when blocked EW (diagonal variant, checks `$06,S`) |
| `sub_02DFF6` | 106 B | Compute EW snap offset for diagonal |
| `func_02E060` | 75 B | Left-push realignment after diagonal collision — modifies `$24` |
| `func_02E0AB` | 79 B | Right-push realignment after diagonal collision |
| `sub_02E0FA` | 8 B | Clear return flags (`STA $05,S` = 0) |

### Group J: Tile Probing Primitives ($02E102–$02E389)

The most-called subroutines in the entire player movement system. These convert
player position to tile coordinates and read collision type.

#### Subgroup J1: State / Finalization

| Part | Size | Description |
|------|------|-------------|
| `sub_02E102_noref` | 61 B | Unused: combined position→tile→collision probe |
| `sub_02E13F` | 21 B | Check if player crossed a tile boundary (compare `$22+$20` with current tile) |
| `func_02E154` | 7 B | **Reset all deltas**: `STZ $24; STZ $20; RTS` |
| `sub_02E15B` | 19 B | **Set collision flag**: `ORA #$0004` into actor `$0010,Y` |
| `func_02E16E` | 21 B | **Finalize movement**: `$22 += $20; $26 += $24; STZ $20; STZ $24` — applies accumulated deltas to position |

#### Subgroup J2: Current-Position Probes

These compute tile coordinates from the player's *current* position and check
the collision map. Each returns the collision type in A.

| Part | Offset Formula | Description |
|------|---------------|-------------|
| `sub_02E183` | X: `$22/4 + 7`, Y: `$26/4 − 1` | Bottom-right of current position |
| `sub_02E1A9` | X: `$22/4 + 7`, Y: `$26/4 − 16` | Top-right of current position |
| `sub_02E1CD` | X: `$22/4 − 8`, Y: `$26/4 − 1` | Bottom-left of current position |
| `sub_02E1F1` | X: `$22/4 − 8`, Y: `$26/4 − 16` | Top-left of current position |

#### Subgroup J3: Destination-Position Probes

These use the *future* position (`$22 + $20`, `$26 + $24`) to predict collision
at the next frame's position.

| Part | Offset Formula | Description |
|------|---------------|-------------|
| `sub_02E20D` | X: `($22+$20)/4 + 7`, Y: `($26+$24)/4 − 16` | Future top-right |
| `sub_02E237` | X: `($22+$20)/4 + 7`, Y: `($26+$24)/4 − 1` | Future bottom-right |
| `sub_02E263` | X: `($22+$20)/4 − 8`, Y: `($26+$24)/4 − 16` | Future top-left |
| `sub_02E285` | X: `($22+$20)/4 − 8`, Y: `($26+$24)/4 − 1` | Future bottom-left |

#### Subgroup J4: Core Tile Lookup

| Part | Size | Description |
|------|------|-------------|
| `sub_02E2AF` | 77 B | **Master tile probe**: bounds-check `$1A/$1E` against camera/map limits. If in bounds, call `func_03D78A` (external: compute map cell), read collision via `sub_02E2FC`. If out of bounds, return $0F (solid). |
| `sub_02E2FC` | 23 B | **Read collision nibble**: if X < $4000, read `$7F:C000,X`, extract high nibble if non-zero, return in A with flags set. If X ≥ $4000, return $0F (solid). |

#### Subgroup J5: Adjacent Cell Navigation

| Part | Size | Description |
|------|------|-------------|
| `sub_02E313` | 24 B | Next cell right (from `$00` index) |
| `sub_02E32B` | 24 B | Next cell left |
| `sub_02E343` | 26 B | Next cell down |
| `sub_02E35D` | 31 B | Next cell up |
| `sub_02E37C` | 13 B | Check X sub-tile alignment (`$1A & $0F`) |
| `sub_02E389` | 13 B | Check Y sub-tile alignment (`$1E & $0F`) |

---

## 6. Collision Type Reference

The movement code tests tile collision types extensively. Observed types:

| Type | Meaning | Direction Handling |
|------|---------|-------------------|
| $00 | Passable (empty) | Free movement |
| $01 | Passable (variant) | Free movement (down-left special) |
| $02 | Interactive tile | Redirect to alternate animation |
| $03 | Slope (right/ascending east) | Computed sub-pixel Y correction |
| $05 | Semi-solid / ramp entry | Ramp passability checks |
| $06 | Wall (south-facing) | Block southward, allow eastward slide |
| $07 | Ladder / climbable | Auto-climb state change |
| $08 | Stairs | Stair-step movement redirect |
| $09 | Wall (north-facing) | Block northward, allow slide |
| $0A | Ramp / passable slope | Full ramp movement with Y tracking |
| $0C | Slope (left/ascending west) | Computed sub-pixel Y correction with accumulator |
| $0E+ | Solid wall | Full block, zero speed |
| $0F | Out of bounds / solid | Returned for OOB probes |

---

## 7. Cross-File Call Graph Summary

```
chunk_028000.asm                      chunk_02CFD0.asm
─────────────────                     ─────────────────
                                      
  [Group 14: Collision Probing]       [Group J: Tile Probing Primitives]
  sub_02B168 ──── JSR ──────────────► sub_02E1F1, sub_02E2AF, sub_02E2FC
  sub_02B1BB ──── JSR ──────────────► sub_02E1A9, sub_02E2AF, sub_02E2FC
             ──── JSR ──────────────► sub_02E313, sub_02E32B, sub_02E343
             ──── JSR ──────────────► sub_02E35D, sub_02E263, sub_02E285
             ──── JSR ──────────────► sub_02E20D, sub_02E237

  [Group 5: Scene GFX]               [Group A: Movement Dispatcher]
  (no direct calls)                   func_02CFD0 ─ JSR ─► sub_02DB80
                                                   ─ JSR ─► func_02D6DC
                                                   ─ JSR ─► sub_02D038
                                                   ─ JSR ─► sub_02D376

  [Group 12: Camera]                  [Group B–I: all movement handlers]
  (no calls into 02CFD0)              ──── JSR ──────────────► sub_02D0BC
                                      ──── JSR ──────────────► sub_02D3F7
                                      ──── JSR ──────────────► sub_02D760
                                      ──── JSR ──────────────► sub_02DC10
                                      ──── JSR ──────────────► func_02E16E
                                      (all internal to 02CFD0)
```

**Key insight:** The only cross-file JSR calls from chunk_028000 → chunk_02CFD0
are in Group 14 (collision probing at $02B168–$02B1BB), which calls Group J
primitives. All other coupling is one-directional or via JSL to shared utilities.

---

## 8. Proposed File Splits

### 8.1 chunk_028000.asm → 10 files

| Proposed File | Groups | Parts | Size Est. | Rationale |
|--------------|--------|-------|-----------|-----------|
| **`hardware_math.asm`** | 1 | 5 | ~218 B | Pure utility, no deps. Self-contained. |
| **`vblank_joypad.asm`** | 2 | 7 | ~398 B | Cohesive NMI/display/joypad unit. |
| **`decompress.asm`** | 3 | 3 | ~306 B | Self-contained algorithm. |
| **`scene_script.asm`** | 4 + 5 | ~40 | ~3,680 B | Script engine + all graphics commands + DMA/cache helpers. Tightly coupled — the dispatch table references all command handlers. Keep as one unit. |
| **`spc_transfer.asm`** | 6 | 5 | ~3,531 B | SPC protocol + binary blob. Self-contained after init. |
| **`system_init.asm`** | 7 | 8 | ~607 B | Boot-time only. Self-contained. |
| **`music_actors.asm`** | 8 | 3 | ~219 B | COP-based actors, few deps. |
| **`text_measure.asm`** | 9 | 3 | ~206 B | Text processing, references dictionaries. |
| **`event_blocks.asm`** | 10 | 8 | ~1,012 B | Event flag → tile swap system. References `array_01D3CE` and map coord helpers. |
| **`warps_interaction.asm`** | 11 | 12 | ~1,464 B | Warp detection + chest handling. References `scene_warps`, `table_01ADA8`, forced_walk. |

**Remaining in chunk_028000.asm:** Groups 12 + 13 + 14 (~2,172 B) — camera/scrolling + map coords + collision probes. These form a cohesive "spatial engine" that should stay together or be renamed:

| Proposed File | Groups | Parts | Size Est. | Rationale |
|--------------|--------|-------|-----------|-----------|
| **`camera_tilemap.asm`** | 12 | 13 | ~1,330 B | Scrolling DMA engine. Note: `camera_scroll.asm` already exists as a separate file — this is the VRAM update side. |
| **`map_coords.asm`** | 13 + 14 | 8 | ~393 B | Coordinate helpers + boundary probes. The probes call into chunk_02CFD0 tile primitives — this is the only cross-file JSR link. |

### 8.2 chunk_02CFD0.asm → 5 files

| Proposed File | Groups | Parts | Size Est. | Rationale |
|--------------|--------|-------|-----------|-----------|
| **`player_move_main.asm`** | A + D | 6 | ~294 B | Entry dispatcher + shared alignment helpers (used by all directions). |
| **`player_move_ns.asm`** | B + C | 13 | ~490 B | All north/south movement handlers. Heavily cross-call each other. |
| **`player_move_ew.asm`** | E + F | ~30 | ~1,700 B | All east/west movement + slope/ramp handlers. Largest group — slopes are direction-coupled. |
| **`player_move_diag.asm`** | G + H + I | ~15 | ~1,360 B | All diagonal movement + auto-align + fine adjust. |
| **`tile_collision.asm`** | J | ~22 | ~565 B | All tile probing primitives. Used by both chunk_028000 (Group 14) and all movement handlers. **This should be a standalone file** to formalize the shared dependency. |

### 8.3 Cross-File Call Minimization

After the proposed splits:

| Caller File | Callee File | Call Type | Count |
|-------------|-------------|-----------|-------|
| `map_coords.asm` | `tile_collision.asm` | JSR (same bank) | ~12 calls |
| `player_move_main.asm` | `player_move_ns.asm` | JSR | 2 |
| `player_move_main.asm` | `player_move_ew.asm` | JSR | 1 |
| `player_move_main.asm` | `player_move_diag.asm` | JSR | 2 |
| `player_move_ns.asm` | `tile_collision.asm` | JSR | ~20 |
| `player_move_ew.asm` | `tile_collision.asm` | JSR | ~30 |
| `player_move_diag.asm` | `tile_collision.asm` | JSR | ~40 |
| `player_move_ew.asm` | `player_move_ns.asm` | JSR | ~5 (shared snap routines) |
| `player_move_diag.asm` | `player_move_ns.asm` | JSR | ~4 |
| `player_move_diag.asm` | `player_move_ew.asm` | JSR | ~6 |
| `scene_script.asm` | `decompress.asm` | JSL | ~8 |
| `scene_script.asm` | `hardware_math.asm` | JSL | ~4 |
| `event_blocks.asm` | `map_coords.asm` | JSL | ~20 |
| `warps_interaction.asm` | `map_coords.asm` | JSL | ~6 |

All other inter-file calls are to well-defined JSL entry points (already
cross-file by convention).

---

## 9. Dependency Diagram

```
                    ┌───────────────────────┐
                    │     system_core        │ (main game loop)
                    └──────┬───┬───┬────────┘
                           │   │   │
              ┌────────────┘   │   └────────────┐
              ▼                ▼                 ▼
    ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
    │ system_init  │  │ camera_      │  │ event_blocks │
    │              │  │ tilemap      │  │              │
    └──────────────┘  └──────┬───────┘  └──────┬───────┘
                             │                 │
                    ┌────────┘                 │
                    ▼                          ▼
              ┌──────────────┐          ┌──────────────┐
              │ map_coords   │◄─────────┤ warps_       │
              │              │          │ interaction   │
              └──────┬───────┘          └──────────────┘
                     │ JSR
                     ▼
              ┌──────────────┐
              │ tile_         │◄──── player_move_*
              │ collision     │      (all 4 files)
              └──────────────┘

    ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
    │ scene_script │  │ spc_transfer │  │ music_actors │
    │ (+ gfx cmds)│  │              │  │              │
    └──────┬───────┘  └──────────────┘  └──────────────┘
           │
    ┌──────┴───────┐
    │ decompress   │
    └──────────────┘

    ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
    │ hardware_    │  │ vblank_      │  │ text_measure │
    │ math         │  │ joypad       │  │              │
    └──────────────┘  └──────────────┘  └──────────────┘
         ▲                   ▲
         │                   │
         └───── (called by many files via JSL) ─────┘
```

---

## 10. Size Distribution

### chunk_028000.asm by proposed group:

| Group | Bytes | % of chunk |
|-------|-------|-----------|
| Hardware Math | 218 | 1.7% |
| VBlank/Joypad | 398 | 3.1% |
| Decompression | 306 | 2.4% |
| Scene Script + Graphics | 3,680 | 28.7% |
| SPC Transfer + Binary | 3,531 | 27.6% |
| System Init | 607 | 4.7% |
| Music Actors | 219 | 1.7% |
| Text Measure | 206 | 1.6% |
| Event Blocks | 1,012 | 7.9% |
| Warps/Interaction | 1,464 | 11.4% |
| Camera/Tilemap | 1,330 | 10.4% |
| Map Coords + Probes | 393 | 3.1% |

### chunk_02CFD0.asm by proposed group:

| Group | Bytes | % of chunk |
|-------|-------|-----------|
| Movement Main + Alignment | 294 | 5.8% |
| North/South Movement | 490 | 9.7% |
| East/West Movement + Slopes | 1,700 | 33.6% |
| Diagonal Movement | 1,360 | 26.9% |
| Tile Collision Primitives | 565 | 11.2% |
| Speed-reset stubs (scattered) | 36 | 0.7% |
| Fine position adjust | 162 | 3.2% |

---

## 11. Notable Patterns

### 11.1 Repeated Code Patterns

The `rep_stz_rts_*` stubs (6 copies) are identical:
```
REP #$20
STZ player_speed_ns  ; or player_speed_ew
RTS
```
These exist because 65816 branch range limits prevent a single shared copy. A
refactor could consolidate them if relative branch distances allow.

### 11.2 Collision Cascade Pattern

Nearly every movement handler follows this pattern:
1. Probe tile at destination → get collision type
2. Switch on type ($02, $03, $06, $08, $09, $0A, $0C, $0E+)
3. For complex types: probe adjacent tiles, check sub-tile alignment
4. Apply movement or snap to boundary
5. Call `func_02E16E` to finalize

### 11.3 Cache-and-Diff Pattern (Graphics)

The scene graphics loading consistently uses:
1. `sub_028DC1` — check if source pointer changed since last load
2. If changed: decompress (`func_028270`), then DMA
3. If unchanged: skip (cached)

This avoids redundant decompression when scenes share tilesets.

### 11.4 The Slope Accumulator

Tiles $03 and $0C use a 16-bit accumulator at `$09C6` to track fractional
vertical displacement across multiple frames of slope traversal. This prevents
rounding errors from accumulating when the player walks diagonally across
multi-tile slopes.

---

## 12. Recommendations

1. **Extract `tile_collision.asm` first** — it's the highest-value split because
   it formalizes the shared interface between the two chunks and has zero
   outgoing dependencies (only calls `func_03D78A` externally).

2. **Keep scene script + graphics loading together** — the dispatch table
   creates hard coupling between the interpreter and all 10+ command handlers.
   Splitting them would require extensive cross-file `?INCLUDE` additions with
   no readability benefit.

3. **The six `rep_stz_rts_*` stubs** should be analyzed for consolidation.
   Since they're RTS-terminated (not RTL), they must be within JSR range of
   their callers. A single pair of stubs (one NS, one EW) placed centrally
   in the movement code could replace all six if branch ranges permit.

4. **`sub_02D257_noref` and `sub_02E102_noref`** are unreferenced and can be
   safely removed or commented out to reduce code size.

5. **Map coordinate helpers** (`func_02B0A3`–`func_02B14E`) are called via JSL
   from many places. They should remain as a standalone file with well-documented
   entry/exit conventions since they're a de facto API.
