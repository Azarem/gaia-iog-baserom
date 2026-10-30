# Bank $02 — Scene Script Engine

*Part of the [Bank $02 Documentation Suite](README.md)*

**Bank:** `$02` (FastROM; accessed via `$@` long calls from other banks)
**Document scope:** Scene script interpreter, graphics loading commands, VRAM DMA helpers, and source-pointer caching in the `engine` scene.
**ASM sources:** [`scene_script.asm`](../../../extracted/system/engine/scene_script.asm) (block: `scene_script`), [`DmaWordToVram.asm`](../../../extracted/system/engine/DmaWordToVram.asm), [`spc_transfer.asm`](../../../extracted/system/engine/spc_transfer.asm) (block: `spc_transfer` — see [spc-transfer.md](spc-transfer.md))

> **Evidence labels.** Each major section is tagged with the kind of claim it makes: **[ASM]** = directly observed in the extracted asm of this block; **[INFERRED]** = interpretation of behavior that is not literally encoded in the file; **[XREF]** = cross-file / engine-wide convention stated elsewhere (not provable from this file alone). Sections that mix kinds split them into separately tagged bullets or paragraphs. The `.asm` files in `extracted/` are authoritative; where prose and asm comments disagree, the asm wins.

The scene script interpreter reads byte opcodes from WRAM scene data (`[$3A],Y`), dispatches through `scene_script_jump_table`, and runs until opcode `$00`. Command `$11` (`SpcMusicLoadCmd`, assembled in this file) calls into [spc-transfer.md](spc-transfer.md). **`ClearSceneState`** in [`scene_lifecycle.asm`](../../../extracted/system/engine/scene_lifecycle.asm) JSLs `SceneScriptMain` during room loads. The built-in SPC engine is uploaded once at cold start via `SpcLoadBuiltinEngine` from [`system_core.asm`](../../../extracted/system/engine/system_core.asm).

Quintet-LZ decompression is [`QuintetLzDecompress.asm`](../../../extracted/system/engine/QuintetLzDecompress.asm). Hardware math, VBlank, and init are in [hardware-and-init.md](hardware-and-init.md).

### Scene Load Pipeline

*Evidence: [ASM] + [XREF]*

Room transitions call `ClearSceneState` in [`scene_lifecycle.asm`](../../../extracted/system/engine/scene_lifecycle.asm). After `ClearBg3TilemapBuffer_Full`, `SceneScriptMain` runs until opcode `$00`; post-script collision rebuild and tilemap work continue in the caller.

```mermaid
flowchart TD
    ClearSceneState["ClearSceneState<br/>(scene_lifecycle)"] --> ClearVram["ClearBg3TilemapBuffer_Full"]
    ClearVram --> SSM["SceneScriptMain"]
    SSM --> FCS["FindCurrentScene"]
    FCS --> Loop["ReadScriptByte loop"]
    Loop -->|"opcode ≠ $00"| Dispatch["scene_script_jump_table"]
    Dispatch --> ConfigDisplay["SceneCmd_ConfigDisplay ($02)"]
    Dispatch --> LoadBg["SceneCmd_LoadBgTiles ($03)"]
    Dispatch --> LoadPalette["SceneCmd_LoadPalette ($04)"]
    Dispatch --> LoadDual["SceneCmd_LoadMetatileSets ($05)"]
    Dispatch --> FullGfx["SceneCmd_LoadLayerMaps ($06)"]
    Dispatch --> LoadSprite["SceneCmd_LoadSpriteTiles ($10)"]
    Dispatch --> SpcMusic["SpcMusicLoadCmd ($11)"]
    Dispatch --> LoadChar["SceneCmd_LoadCharTiles ($17)"]
    ConfigDisplay --> Loop
    LoadBg --> Loop
    LoadPalette --> Loop
    LoadDual --> Loop
    FullGfx --> Loop
    LoadSprite --> Loop
    SpcMusic --> Loop
    LoadChar --> Loop
    Loop -->|"opcode $00"| EndCheck{"scene_current ≠ $F7?"}
    EndCheck -->|yes| RLD["RebuildCollisionLayer"]
    EndCheck -->|no| ScriptDone["SceneScriptMain RTL"]
    RLD --> ReloadL0["FillCollisionFromLayer0"]
    RLD --> ReloadL1["OverlayCollisionFromLayer1"]
    ReloadL0 --> ScriptDone
    ReloadL1 --> ScriptDone
    ScriptDone --> PostLoad["Caller: InitCameraBounds<br/>+ CameraFullRefresh or RenderPaletteTiles"]
```

---

## Address Layout

*Evidence: [ASM] + [XREF] (`db-us/blocks.json`)*

```
$0283A2 ┌─ DmaWordToVram (block: DmaWordToVram) ────────┐
$0283BB ├─ scene_script block ─────────────────────────┤
        │  SceneScriptMain / SceneScriptNoMusic       │
        │  scene_script_jump_table + command handlers │
        │  … SpcMusicLoadCmd ($11) at $028B6D         │
        │  … OverlayCollisionFromLayer1               │
$02908E ├─ spc_transfer block ─────────────────────────┤
        │  SpcLoadBuiltinEngine / SpcBlockTransfer    │
        │  SpcIplHandshake / spc_sound_engine         │
$029DE2 └─ system_init block begins ───────────────────┘
```

`scene_script.asm` and `spc_transfer.asm` cross-include at assemble time; in ROM, **`SpcMusicLoadCmd` is still inside the `scene_script` block** (ends `$02908E`). The **`spc_transfer` block** starts at `$02908E` with `SpcLoadBuiltinEngine`.

| Block | ROM range | Size (bytes) |
|--------|-----------|--------------|
| `DmaWordToVram` | `$0283A2`–`$0283BB` | 25 |
| `scene_script` | `$0283BB`–`$02908E` | 3,283 |
| `spc_transfer` | `$02908E`–`$029DE2` | 3,412 |

Embedded `spc_sound_engine` IPL payload: **3,018 bytes** (`$0BCA`) per `spc_transfer.asm` header (ROM part 168464–171490).

---

## Scene Load Flow

*Evidence: [ASM] + [XREF] (`scene_lifecycle.asm`)*

`ClearSceneState` JSLs `ClearBg3TilemapBuffer_Full`, then `SceneScriptMain`, with `sceneCurrent` (`$0644`) already set. The script pointer at `$3A`/`$3C` (bank byte) addresses WRAM scene data; **`FindCurrentScene`** scans from `Y = 0`, reads a 16-bit scene id, and skips operand bytes until the id matches `$0644` (extracted scanning implementation; a patched indexed loader may replace this in some builds — see `scene_script.asm` header).

Opcodes `$02`–`$17` dispatch through **`scene_script_jump_table`** via `PEA loop−1` / `DEC` / `PHA` / `RTS`. Opcode `$00` ends the scene; **`RebuildCollisionLayer`** runs unless `sceneCurrent = $F7`. **`SceneScriptNoMusic`** skips `$11` by comparing the jump-table handler word to `SpcMusicLoadCmd` and advancing `Y` by 5; it does not call `RebuildCollisionLayer`.

After `SceneScriptMain` returns, `ClearSceneState` JSLs **`InitCameraBounds`**, spawns actors/thinkers, loads palettes, then either **`RenderPaletteTiles`** when `scrollModeFlags` (`$06EF`) bit `$08` is set, or **`CameraFullRefresh`** for layers flagged in `$069B` / `$069D` ([XREF] `scene_lifecycle.asm`).

Loaders use **Tier-1** source-pointer slots at `$066C`–`$0687` (`CheckSourceCacheHit`) and **Tier-2** VRAM ring cache at `$0084`–`$009F` / `$7F:4000+` on selected `SceneCmd_LoadBgTiles` paths ([Cache-and-Diff Pattern](#cache-and-diff-pattern)).

---

## Command Dispatch Table

*Evidence: [ASM]*

The 24-entry jump table at `$028416` maps command indices `$00`–`$17` to handler addresses. Unimplemented indices fall through to `SceneCmd_Default` (immediate `RTS` — no-op).

| Cmd | Hex | Handler | Description |
|-----|-----|---------|-------------|
| `$00`–`01` | — | `SceneCmd_Default` | Unimplemented (NOP return) |
| `$02` | `$02` | `SceneCmd_ConfigDisplay` | Read the `display_preset_table` record; configure TM/TS/TMW/TSW/CGWSEL/CGADSUB/BGMODE/BG1SC/BG2SC and scene flags |
| `$03` | `$03` | `SceneCmd_LoadBgTiles` | Multi-mode BG tile loader (4 modes) |
| `$04` | `$04` | `SceneCmd_LoadPalette` | Palette colours: colours `[start, end)` of the source go to the palette buffer `$7F:0A00` at colour `dest` |
| `$05` | `$05` | `SceneCmd_LoadMetatileSets` | Metatile sets for layer 0 and/or layer 1 (per-layer cache check) to `$7E:2000` / `$7E:2800`, then `BuildMetatileFlagTable` |
| `$06` | `$06` | `SceneCmd_LoadLayerMaps` | Layer maps (width, height, compressed map) for layer 0 and/or layer 1; with no layer bit set, a tileset to low VRAM |
| `$07`–`0D` | — | `SceneCmd_Default` | Unimplemented (NOP return) |
| `$0E` | `$0E` | `SceneCmd_Skip3` | Skip 3 script bytes (placeholder NOP) |
| `$0F` | — | `SceneCmd_Default` | Unimplemented (NOP return) |
| `$10` | `$10` | `SceneCmd_LoadSpriteTiles` | Sprite tile graphics → VRAM `$4000` |
| `$11` | `$11` | `SpcMusicLoadCmd` | Reads `musicParentActor`, group byte → `$06F4`; continues only if `$06F4` = `musicRoomGroup` (`$06F6`); else `RTS`. Source cache at `$0687` |
| `$12` | — | `SceneCmd_Default` | Unimplemented (NOP return) |
| `$13` | `$13` | `SceneCmd_Branch` | Test event flag → skip or execute command `$15` |
| `$14` | `$14` | `SceneCmd_Label` | Skip 1 script byte |
| `$15` | `$15` | `SkipScriptCommands` | Skip N commands of varying sizes |
| `$16` | — | `SceneCmd_Default` | Unimplemented (NOP return) |
| `$17` | `$17` | `SceneCmd_LoadCharTiles` | Character-specific tile data to BG1/BG2 VRAM |

**Implemented script commands:** 11 of 24 table entries (`$02`–`$06`, `$0E`, `$10`–`$11`, `$13`–`$15`, `$17`).

### Command Operand Sizes

Used by `FindCurrentScene` and `SkipScriptCommands` when advancing past unknown scenes:

| Cmd | Bytes after opcode | Notes |
|-----|-------------------|-------|
| `$02` | 1 | Display config index |
| `$03` | 7 | VRAM offset, range, mode, 3-byte source pointer |
| `$04` | 6 | start, end, dest colour + 3-byte pointer |
| `$05` | 7 | start, end, dest (window operands), layer flags + 3-byte pointer |
| `$06` | 4+ | Layer flags + 3-byte pointer (+ inline geometry) |
| `$0E` | 3 | Skipped inline |
| `$10` | 5 | 2-byte size + 3-byte pointer |
| `$11` | 5 | Byte → `musicParentActor` (`$06F2`); byte → `$06F4`; 3-byte pointer (`LoadScriptPointer`) |
| `$13` | 2 | Flag index + `$15` count |
| `$14` | 1 | NOP skip |
| `$15` | 1+ | Count byte, then N commands |
| `$17` | 4+ | Mode byte + 3-byte pointer (+ inline size) |

---

## Cache-and-Diff Pattern

*Evidence: [ASM]*

Graphics loaders avoid redundant VRAM uploads through a two-tier **compare-and-skip** system.

### Tier 1 — Per-Command Source Cache (`CheckSourceCacheHit`)

Most commands store the last-used `(addr, bank)` pair at a dedicated WRAM slot. Before any decompression or DMA:

1. `LoadScriptPointer` fills `($3E,$40)` from the script stream.
2. `CheckSourceCacheHit` compares `($3E,$40)` against `(X)` — the cache slot passed in `X`.
3. **Match (carry clear):** Source unchanged → handler returns immediately (no VRAM touch).
4. **Mismatch (carry set):** Updates the cache slot and proceeds to load.

### Tier 2 — VRAM Content Cache (tile strips)

After a Tier-1 **miss** on `SceneCmd_LoadBgTiles` modes **0 or 1** (not mode **2**, which skips Tier-1, or mode **3** → `Load4bppPage`), an additional content cache may run:

1. `GraphicsCacheLookup` scans 4 slots at `$0084`–`$008F` for a matching `(addr, bank)`.
2. **Hit:** `RestoreCachedVram` DMAs the saved VRAM snapshot from the ring buffer at `$7F:4000+` back to the target VRAM address.
3. **Miss:** Decompress → DMA to VRAM → `GraphicsCacheStore` records the source pointer → `SaveVramToRingBuffer` reads VRAM back into the ring buffer.

The ring-buffer slot index is tracked in `$0094` (round-robin, 4 slots). Slot-to-buffer mapping uses `ComputeRingBufferAddr` and `system_init.cache_slot_indices`.

### Dual-Layer Partial Reload

`SceneCmd_LoadMetatileSets` and `SceneCmd_LoadLayerMaps` use bit flags in `$066A` to independently cache-check each layer. If layer 0 hits cache but layer 1 misses, only layer 1 reloads.

### Cache Tier Decision Tree

```mermaid
flowchart TD
    Start["Graphics load command"] --> LSP["LoadScriptPointer → $3E/$40"]
    LSP --> T1{"CheckSourceCacheHit<br/>Tier-1 (addr,bank) match?"}
    T1 -->|"match / CLC"| SkipAll["Skip — source unchanged"]
    T1 -->|"mismatch / SEC"| UpdateT1["Update Tier-1 cache slot at X"]
    UpdateT1 --> StripCheck{"LoadBgTiles mode 0<br/>horizontal strip?"}
    StripCheck -->|no| Decompress["Decompress + DMA to VRAM"]
    StripCheck -->|yes| T2{"GraphicsCacheLookup<br/>Tier-2 ring buffer hit?"}
    T2 -->|"hit / SEC"| Restore["RestoreCachedVram<br/>from $7F:4000+ ring"]
    T2 -->|"miss / CLC"| Decompress
    Decompress --> DMA["DmaTileStripToVram / DmaWramToVram"]
    DMA --> StoreT2["GraphicsCacheStore + SaveVramToRingBuffer"]
    Restore --> HandlerReturn["Handler RTS → next command"]
    StoreT2 --> HandlerReturn
    SkipAll --> HandlerReturn
```

Tier 1 applies to cached loaders (`SceneCmd_LoadBgTiles` modes 0–1, metatile/layer/sprite/music commands). Tier 2 (`GraphicsCacheLookup` / `RestoreCachedVram`) runs on the post–Tier-1-miss path at `loc_028520` in `SceneCmd_LoadBgTiles` (including `$066F`/`$0672`/`$0675` slots), unless `layerPriorityFlag` (`$06EE`) bit `$0800` with slot `$066C` diverts to `DeinterleavePlanarTiles` first.

---

## scene_script.asm

*Evidence: [ASM]*

| Address | Name | Description |
|---------|------|-------------|
| `$0283A2` | DmaWordToVram | `DmaWordToVram` is the shared primitive for word-mode DMA transfers from a source address in any bank to VRAM. |
| `$0283BB` | SceneScriptMain | `SceneScriptMain` is the primary scene script interpreter invoked during room loads. |
| `$0283E7` | SceneScriptNoMusic | `SceneScriptNoMusic` is a variant interpreter identical to `SceneScriptMain` except that command `$11` (`SpcMusicLoadCmd`) is skipped inline. |
| `$028416` | scene_script_jump_table | The 24-entry dispatch table maps scene script command indices `$00`–`$17` to handler addresses. |
| `$028446` | SceneCmd_Branch | Command `$13` implements conditional script execution based on event flags. |
| `$02845B` | SceneCmd_Label | Command `$14` is a minimal no-operation handler. |
| `$02845D` | SceneCmd_LoadBgTiles | Command `$03` is the multi-mode BG tile loader — the most complex graphics command in the scene script. |
| `$028552` | SceneDmaTileShim | A 3-byte entry shim consisting of `PHP` followed by `BRA DmaTileStripToVram`. |
| `$028555` | CheckInterleavedFlag | Tests `layerPriorityFlag` (`$06EE`) bit `$0800`; if set, branches to `InterleaveTilesPriority` instead of `DmaTileStripToVram`. |
| `$028560` | DmaTileStripToVram | DMAs a tile strip from the current source pointer (`$3E`/`$40`) to VRAM. |
| `$028592` | Load4bppPage | Loads a full 4bpp tile page (4096 bytes) to VRAM address `$2000`. |
| `$0285DB` | DeinterleavePlanarTiles | Converts interleaved 2bpp+2bpp planar tile data to SNES 4bpp format. |
| `$02868C` | BuildAttributeTable | Builds a 256-byte palette-to-attribute lookup table at `$7E:2800` from tilemap metadata at `$7E:2000`. |
| `$0286C3` | SceneCmd_LoadPalette | Command `$04` loads palette colours from ROM into the palette buffer at `$7F:0A00`. |
| `$028712` | SceneCmd_LoadMetatileSets | Command `$05` loads metatile sets for layer 0 and/or layer 1 from a single compressed blob into WRAM and builds the metatile flag table. |
| `$0287BC` | SceneCmd_LoadLayerMaps | Command `$06` loads the layer map (width, height, compressed map) of layer 0 and/or layer 1, or a tileset to low VRAM when no layer bit is set. |
| `$028895` | StoreMapAndDecompress | Stores map dimensions from inline geometry bytes (`$00`/`$02` = width/height) into the map bounds array at `$0693,X` ... |
| `$0288B5` | HandleEmptyGeometry | Handles the case where the geometry size word read from the source stream is zero — meaning no compressed tileset follows inline. |
| `$028914` | WriteMapBounds | Writes map width and height from `$00`/`$02` into the bounds arrays at `$0692,X` and `$0696,X`, then DMAs the first map row from the current source pointer via `DmaRomToWram`. |
| `$028926` | DmaLowVramTileset | Uploads a tileset to low VRAM at address `$2000` using byte-write mode, required for Mode 0 BG tile uploads. |
| `$02897D` | RenderPaletteTiles | Converts palette-indexed map data at `$7E:A000` into SNES 4bpp tile format at `$7E:B000`, then DMAs 4096 bytes to VRAM address `$0000`. |
| `$028A6D` | SceneCmd_ConfigDisplay | Command `$02` configures the SNES PPU for a scene by reading a 1-byte index into `display_preset_table` — a preset table of display register values. |
| `$028B69` | SceneCmd_Skip3 | Command `$0E` is a placeholder NOP that advances the script index by 3 bytes. |
| `$028BE4` | SceneCmd_LoadSpriteTiles | Command `$10` loads sprite tile graphics to OBJ VRAM. |
| `$028C30` | SceneCmd_LoadCharTiles | Command `$17` loads character-specific tile data to BG VRAM. |
| `$028CE7` | ReadScriptByte | Reads the next byte from the script stream at `[$3A],Y` and advances `Y` by one. |
| `$028CF2` | FindCurrentScene | Linearly scans the script stream at `($3A)` starting from `Y = 0` to find the entry matching `scene_current` at `$0644`. |
| `$028D3D` | SkipScriptCommands | Advances `Y` past N commands in the script stream, where N is read from the first byte via `ReadScriptByte` and stored on the stack. |
| `$028D8F` | LoadScriptPointer | Reads a 3-byte pointer (2-byte address + 1-byte bank) from the script stream at `[$3A],Y` and stores it at `(X)` (address at offset 0, bank at offset 2). |
| `$028DC1` | CheckSourceCacheHit | Compares the current source pointer at `$3E`/`$40` against a cached `(addr, bank)` pair at `(X)`. |
| `$028DEA` | DmaRomToWram | Transfers data from ROM (or any source at `$3E`/`$40`) to a WRAM destination at `$42`/`$44`. |
| `$028E6F` | GraphicsCacheLookup | Scans 4 cached source pointer slots at `$0084`–`$008F` (each 3 bytes: addr + bank) for a match against the current `$3E`/`$40`. |
| `$028E94` | GraphicsCacheStore | Writes the current source pointer `$3E`/`$40` into the round-robin graphics cache at `$0084`–`$008F`. |
| `$028EB8` | SaveVramToRingBuffer | Reads VRAM content back into the ring buffer at `$7F:4000+` via `DmaVramToRam`, preserving uploaded tile data for future cache hits. |
| `$028F18` | DmaVramToRam | Performs a VRAM-to-RAM DMA read-back using DMA channel 0. |
| `$028F43` | ComputeRingBufferAddr | Computes the WRAM ring-buffer address for the current cache slot index in `$0094`. |
| `$028F53` | RestoreCachedVram | Restores previously saved VRAM tile data from the ring buffer back to VRAM. |
| `$028FA7` | DmaWramToVram | DMAs data from WRAM bank `$7F` to VRAM. |
| `$028FCD` | BuildMetatileFlagTable | Rebuilds tilemap attribute bytes for a 4×N tile region. |
| `$029020` | RebuildCollisionLayer | `FillCollisionFromLayer0` (X=0), then `OverlayCollisionFromLayer1` (X=2) if `scrollModeFlags` (`$06EF`) **bit 0** is set (`BIT #$01`). |
| `$029034` | FillCollisionFromLayer0 | Fills the collision layer (`$7F:C000`) from the layer 0 map (`$7E:A000`): each cell's metatile number indexes the flag table whose page address is in `$06AA` (`collisionFlagTableL0`, bank `$7F`). |
| `$029060` | OverlayCollisionFromLayer1 | Overlays layer 1's flags onto the collision layer (`$7F:C000`) from the flag table whose page address is in `$06AC` (`collisionFlagTableL1`, bank `$7F`); zero flag bytes are skipped. |

#### Script Engine Core

### SceneScriptMain

`SceneScriptMain` is the primary scene script interpreter invoked during room loads. It saves processor flags, switches to 8-bit accumulator mode, and calls `FindCurrentScene` to position `Y` at the command stream for the current scene ID in `$0644`. The main loop reads bytes via `ReadScriptByte` until `$00` (end-of-scene marker). Non-zero bytes index into `scene_script_jump_table` (`command_id × 2` → word handler address). Handlers are invoked via the **fake return-address jump** pattern: `PEA handler-1` / `RTS`, which pushes a return address pointing one byte before the loop label so execution resumes after the handler returns. When `$00` is encountered, if `scene_current ≠ $F7`, `RebuildCollisionLayer` refreshes both map layers from cached source pointers (used when returning to a previously loaded room). Scene `$F7` is a special case that skips the reload.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `PHP`; `SEP #$20` |
| 2 | `JSR FindCurrentScene` — set `Y` to current scene's command stream |
| 3 | Loop: `JSR ReadScriptByte` |
| 4 | If byte = `$00` → goto step 7 |
| 5 | `PEA loop-1`; index jump table; `DEC`/`PHA`/`RTS` to dispatch handler |
| 6 | Handler returns → goto step 3 |
| 7 | If `$0644 ≠ $F7`, `JSR RebuildCollisionLayer` |
| 8 | `PLP`; `RTL` |

**Source:**

```35:64:../../../extracted/system/engine/scene_script.asm
SceneScriptMain {
    PHP
    SEP #$20
    JSR $&FindCurrentScene

  code_0283C1:
    JSR $&ReadScriptByte
    CMP #$00
    BEQ loc_0283DB
    PEA $&code_0283C1-1
    REP #$20
    AND #$00FF
    ASL
    TAX
    LDA $@scene_script_jump_table, X
    DEC
    PHA
    SEP #$20
    RTS

  loc_0283DB:
    LDA $scene_current
    CMP #$F7
    BEQ loc_0283E5
    JSR $&RebuildCollisionLayer

  loc_0283E5:
    PLP
    RTL
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$3A`/`$3B`/`$3C` | In | Script stream pointer (bank `$7F` WRAM) |
| `$0644` | In | `scene_current` — scene ID to match |
| `Y` | In/Out | Script stream index; advanced by handlers |
| `$06EF` | In | `scrollModeFlags` — bit 0 gates `OverlayCollisionFromLayer1` |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `scene_lifecycle.asm` `ClearSceneState` | JSL caller during scene load |
| `FindCurrentScene` | Positions `Y` at matching scene entry |
| `scene_script_jump_table` | Command dispatch table |
| `RebuildCollisionLayer` | Post-scene map refresh |
| `SceneScriptNoMusic` | Variant that skips music command |

### SceneScriptNoMusic

`SceneScriptNoMusic` is a variant interpreter identical to `SceneScriptMain` except that command `$11` (`SpcMusicLoadCmd`) is skipped inline. When the jump table entry matches `SpcMusicLoadCmd`, the routine advances `Y` by 5 bytes (the full operand size of command `$11`) instead of dispatching to the music handler. This variant is used by the inventory overlay so opening the menu does not restart BGM. Unlike `SceneScriptMain`, it does not call `RebuildCollisionLayer` at scene end — it simply restores flags and returns.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Same setup as `SceneScriptMain`: `FindCurrentScene` |
| 2 | Loop: read byte; if `$00` → exit |
| 3 | Index jump table; compare handler to `SpcMusicLoadCmd` |
| 4 | If music handler: `INY` × 5 (skip operands); `RTS` to loop |
| 5 | Else: fake-return dispatch as in `SceneScriptMain` |
| 6 | On `$00`: `PLP`; `RTL` (no map reload) |

**Source:**

```66:100:../../../extracted/system/engine/scene_script.asm
SceneScriptNoMusic {
    PHP
    SEP #$20
    JSR $&FindCurrentScene

  code_0283ED:
    JSR $&ReadScriptByte
    CMP #$00
    BEQ loc_028414
    PEA $&code_0283ED-1
    REP #$20
    AND #$00FF
    ASL
    TAX
    LDA $@scene_script_jump_table, X
    CMP #$&spc_transfer.SpcMusicLoadCmd
    BEQ loc_02840C
    DEC
    PHA
    SEP #$20
    RTS

  loc_02840C:
    INY
    INY
    INY
    INY
    INY
    SEP #$20
    RTS

  loc_028414:
    PLP
    RTL
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$3A`/`Y` | In/Out | Script stream pointer and index |
| `$0644` | In | Current scene ID |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `inventory_overlay.asm` | Caller — preserves BGM during menu |
| `SpcMusicLoadCmd` | Handler explicitly bypassed |
| `SceneScriptMain` | Full-featured counterpart |

### scene_script_jump_table

The 24-entry dispatch table maps scene script command indices `$00`–`$17` to handler addresses. Each entry is a 2-byte same-bank pointer (`&handler`). Unimplemented commands point to `SceneCmd_Default`, which is a single `RTS`. Command `$11` points across the compilation unit boundary to `spc_transfer.SpcMusicLoadCmd`, reflecting the physical interleaving of the two ASM files in ROM. The table is indexed by `command_byte × 2` in 16-bit mode during dispatch.

### SceneCmd_LoadBgTiles

Command `$03` reads start/end script bytes (each × `$200` into `$0664`/`$0666`), VRAM page byte → `$0668`, 3-byte pointer, mode byte. **Mode 0:** page += `$20`; cache slot `$066C` or `$066F` from page bit `$0010`. **Mode 1:** page += `$40`; slots `$0672`/`$0675`. **Mode 2:** page += `$60`; **no** `CheckSourceCacheHit`. **Mode 3:** `JMP Load4bppPage`. On Tier-1 miss (modes 0–1): optional `DeinterleavePlanarTiles` when slot `$066C` and `layerPriorityFlag` `$0800`; else `GraphicsCacheLookup` / decompress to `$7E:7000` / `SceneDmaTileShim` / `SaveVramToRingBuffer`.

**Algorithm:**

| Mode | Value | Behavior |
|------|-------|----------|
| 0 | `$00` | VRAM base + `$20`; Tier-1 slot `$066C`/`$066F` |
| 1 | `$01` | VRAM base + `$40`; Tier-1 slot `$0672`/`$0675` |
| 2 | `$02` | VRAM base + `$60`; no Tier-1 check |
| 3 | `$03` | `Load4bppPage` (4096-byte 4bpp page) |

| Step | Action |
|------|--------|
| 1 | Read VRAM offset, range, base, source pointer, mode |
| 2 | Adjust `$0668` base per mode; select cache slot in `X` |
| 3 | `CheckSourceCacheHit` — return if unchanged |
| 4 | Read size word from source; branch compressed/uncompressed |
| 5 | On miss: decompress → `SceneDmaTileShim` → `SaveVramToRingBuffer` |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0664` | Out | Source range start (×2) |
| `$0666` | Out | Source range end (×2) |
| `$0668` | Out | VRAM destination base |
| `$066C`–`$0675` | Out | Tier-1 source cache slots (mode 0/1) |
| `$78` | Out | Compressed size word |
| `$06EE` | In | `layerPriorityFlag` bit `$0800` → deinterleave path |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `Load4bppPage` | Mode 2 target |
| `SceneDmaTileShim` | Post-decompress DMA entry |
| `GraphicsCacheLookup` | Tier 2 cache check |
| `DeinterleavePlanarTiles` | Interleaved path from mode 0 |

### DmaTileStripToVram

DMAs a tile strip from the current source pointer (`$3E`/`$40`) to VRAM. Computes the source address as `$3E + $0664`, transfer size as `$0666 - $0664`, and writes the VRAM destination from `$0668` to `$2116` (`VMADDL`). Uses channel 0 word-mode DMA to VRAM. This is the final upload step for uncompressed tile data in modes 0 and 1, and for decompressed data that does not require planar conversion.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Write `$0668` → `$2116` (VRAM address) |
| 2 | Source = `$3E + $0664`; size = `$0666 - $0664` |
| 3 | Configure DMA channel 0: word mode, VRAM dest |
| 4 | Trigger `$420B`; restore flags; return |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0664`/`$0666` | In | Source range |
| `$0668` | In | VRAM destination |
| `$3E`/`$40` | In | Data source pointer |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SceneDmaTileShim` | Entry via branch |
| `DmaWordToVram` | Equivalent register pattern |
| `SceneCmd_LoadBgTiles` | Parent command |

### Load4bppPage

Loads a full 4bpp tile page (4096 bytes) to VRAM address `$2000`. If the source size word is non-zero, decompresses to `$7E:7000` first; otherwise uses raw data at the source pointer. Uses **byte-mode** DMA (`$DMAP0 = $00`, `$BBAD0 = $19`) rather than word mode, which is required for Mode 7 tile uploads. Called from `SceneCmd_LoadBgTiles` mode 2 and from the full-graphics path via `DmaLowVramTileset`.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Read size word; if non-zero → decompress to `$7E:7000` |
| 2 | Set VRAM address to `$2000` |
| 3 | Byte-mode DMA 4096 bytes from source to VRAM |
| 4 | Return |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$78` | In | Compressed size (0 = raw) |
| `$7A` | Out | Decompression destination |
| `$2116` | Out | VRAM addr `$2000` |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `QuintetLzDecompress` | Decompression backend |
| `SceneCmd_LoadBgTiles` | Mode 2 caller |
| `DmaLowVramTileset` | Related low-VRAM path |

### DeinterleavePlanarTiles

Converts interleaved 2bpp+2bpp planar tile data to SNES 4bpp format. The entry label decompresses data to `$7E:7000`; the main loop in `InterleaveTilesPriority` reads 16×2-byte rows from the decompressed buffer, interleaves bitplanes via rotate/or operations, and writes 8 bytes per tile row to `$7E:A000`. After processing 8192 source bytes (4096 output bytes), byte-mode DMA uploads the result to VRAM address `$0000` with `$VMAIN = $80` (increment high word). `BuildAttributeTable` is called first to prepare palette attribute mapping.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Decompress to `$7E:7000` |
| 2 | `BuildAttributeTable` — map palette indices |
| 3 | For each 16-byte source row: interleave 8 bitplane pairs → 8 output bytes |
| 4 | Repeat until 8192 bytes processed |
| 5 | Byte-mode DMA `$7E:A000` → VRAM `$0000` |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$7E:7000` | In | Decompressed planar input |
| `$7E:A000` | Out | Interleaved 4bpp output |
| `$06EE` | In | Bit `$0800` triggers this path |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `BuildAttributeTable` | Called before interleave loop |
| `CheckInterleavedFlag` | Branch entry |
| `SceneCmd_ConfigDisplay` | Sets interleave flag |

### BuildAttributeTable

Builds a 256-byte palette-to-attribute lookup table at `$7E:2800` from tilemap metadata at `$7E:2000`. First zeroes 256 bytes at `$2800`, then for each word in the tilemap buffer (`$2000`–`$27FF`), extracts the palette index (bits 10–12), scales by 4, and stores at the corresponding attribute table offset. This table is used by `DeinterleavePlanarTiles` and `RenderPaletteTiles` to map palette-indexed tile data to SNES attribute format during Mode 7 palette rendering.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Zero 256 bytes at `$7E:2800` (128 words) |
| 2 | For Y = 0..2047 step 2: read `$2000,Y` |
| 3 | Extract palette bits; `×4` → store at `$2800 + index` |
| 4 | Return |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$7E:2000` | In | Tilemap metadata source |
| `$7E:2800` | Out | 256-byte attribute table |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `DeinterleavePlanarTiles` | Caller |
| `RenderPaletteTiles` | Uses same attribute concept |
| `BuildMetatileFlagTable` | Related attribute manipulation |

#### Tilemap Loading

### SceneCmd_LoadPalette

Command `$04` loads palette colour data into **`cgramPalette`** staging at `$7F:0A00`. Three script bytes (start, end, destination colour index) are each **`ASL`** (×2 byte offset) into `$0664`/`$0666`/`0668`. `LoadScriptPointer` + `DmaRomToWram` copy `[start,end)` from the source to `$7F:0A00 + dest`. **Special case:** when destination word = `$0020` (colour index `$10`), after DMA copies **`$7F0A20` → `cgramPalette`** (colour 0 / backdrop slot per asm comment).

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Read start/end/dest bytes; each `ASL` → `$0664`/`$0666`/`$0668` |
| 2 | `LoadScriptPointer`; dest `$42`=`$0A00`, bank `$7F` |
| 3 | `DmaRomToWram` |
| 4 | If dest was `$0020`: `LDA $7F0A20` / `STA cgramPalette` |
| 5 | `RTS` |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0664`/`$0666`/`$0668` | Out | Source range and VRAM offset |
| `$7F:0A00` | Out | `cgramPalette` buffer |
| `$42`/`$44` | Out | DMA destination addr/bank |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `DmaRomToWram` | Transfer primitive |
| `LoadScriptPointer` | Reads 3-byte source |
| `FillCollisionFromLayer0` | Uses cached map data at reload |

### SceneCmd_LoadMetatileSets

Command `$05` loads metatile definition data for layer 0 and/or 1 from one compressed blob. Three script bytes use **`XBA` + `LSR` + `LSR`** (× `$40` scaling) into `$0664`/`$0666`/`0668`, then layer flags → `$066A`, then the source pointer. Performs independent cache checks for layer 0 (slot `$0678`) and layer 1 (slot `$067B`), clearing bits in `$066A` for layers that hit cache. On cache miss, decompresses the combined blob to `$7E:7000`, then copies layer 0 to `$7E:2000` and layer 1 to `$7E:2800` via `DmaRomToWram`, calling `BuildMetatileFlagTable` for each loaded layer to apply priority bits from `$06A2`/`06A4`.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Read BG1/BG2 offsets, layer flags, source pointer |
| 2 | Cache-check layer 0 (`$0678`); clear bit 0 on hit |
| 3 | Cache-check layer 1 (`$067B`); clear bit 1 on hit |
| 4 | If `$066A = 0`: return (both cached) |
| 5 | Decompress if needed; copy layers per remaining flags |
| 6 | `BuildMetatileFlagTable` per loaded layer |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$066A` | In/Out | Layer reload flags (bits 0/1) |
| `$0678`/`$067B` | Out | Per-layer source cache |
| `$7E:2000`/`$7E:2800` | Out | Layer 0/1 tilemap buffers |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `CheckSourceCacheHit` | Per-layer cache |
| `BuildMetatileFlagTable` | Priority bit application |
| `SceneCmd_LoadLayerMaps` | Shares layer flag pattern |

### SceneCmd_LoadLayerMaps

Command `$06` is the comprehensive scene graphics loader — map geometry, tileset, and tilemap in one command. Reads a layer flag byte to `$066A` and a 3-byte source pointer. When layer flags are non-zero, performs per-layer cache checks at `$067E` (layer 0) and `$0681` (layer 1), with a Mode 7 palette bypass when `$06EF` bit `$08` is set. Reads inline geometry bytes (width/height) from the source stream. If no layers are flagged (`$066A AND #$7F = 0`), jumps to `DmaLowVramTileset` for tileset-only load. Otherwise calls `StoreMapAndDecompress` per layer to decompress tile data and store map bounds, with `HandleEmptyGeometry` for zero-size geometry blobs.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Read layer flags + source pointer |
| 2 | Per-layer cache check; clear satisfied bits |
| 3 | Read inline width/height bytes |
| 4 | If no layers: `DmaLowVramTileset` |
| 5 | If size = 0: `HandleEmptyGeometry` |
| 6 | Else: `StoreMapAndDecompress` per flagged layer |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$066A` | In/Out | Layer flags + geometry mode |
| `$067E`/`$0681` | Out | Full-graphics cache slots |
| `$0692`–`$069D` | Out | Map bounds (width, height, products) |
| `$06EF` | In | Bit `$08` = Mode 7 palette path |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `StoreMapAndDecompress` | Per-layer tileset+map |
| `HandleEmptyGeometry` | Zero-size geometry path |
| `DmaLowVramTileset` | Tileset-only fallback |
| `RenderPaletteTiles` | Post-load Mode 7 render |

### StoreMapAndDecompress

Stores map dimensions from inline geometry bytes (`$00`/`$02` = width/height) into the map bounds array at `$0693,X` / `$0697,X`, computes the tile count via `Multiply8x8Unsigned`, and decompresses the tileset blob pointed to by `$069E,X` into `$7E:7000` (via `$7A`). The `X` register selects the layer index (0 or 2 for layer 0/1), indexing into parallel arrays for dual-layer scenes.

### HandleEmptyGeometry

Handles the case where the geometry size word read from the source stream is zero — meaning no compressed tileset follows inline. Computes tileset size from width×height via `Multiply8x8Unsigned`, then DMAs raw tileset data and writes map bounds. For layer 0 (bit `$01` in `$066A`): DMA tileset to `$7E:A000`, call `WriteMapBounds` with `$0000` index, then copy map row to `$7E:C000`. For layer 1 only: uses index `$0002` for `WriteMapBounds` with destination `$7E:C000`.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `Multiply8x8Unsigned` width×height → `$0667` |
| 2 | If layer 0 flagged: DMA tileset → `$7E:A000`; `WriteMapBounds` index 0 |
| 3 | If layer 1 flagged: copy map to `$7E:C000`; store bounds |
| 4 | Return |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$066A` | In | Layer flags |
| `$0666`/`$0667` | Out | Tileset size |
| `$7E:A000`/`$7E:C000` | Out | Tileset/map buffers |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `WriteMapBounds` | Bounds + first row DMA |
| `SceneCmd_LoadLayerMaps` | Entry when size word = 0 |
| `DmaRomToWram` | Raw tileset copy |

### DmaLowVramTileset

Uploads a tileset to low VRAM at address `$2000` using byte-write mode, required for Mode 0 BG tile uploads. Reads the size word from the source stream; if non-zero, decompresses to `$7E:A000` before DMA. Temporarily sets `$2115` (`VMAIN`) to `$00` for byte increment, then restores `$80` after the transfer. Called from `SceneCmd_LoadLayerMaps` when no layer flags are set (tileset-only reload).

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Read size word; decompress to `$7E:A000` if compressed |
| 2 | Set VRAM addr `$2000`; `$VMAIN = $00` |
| 3 | Byte-mode DMA 4096 bytes to VRAM |
| 4 | Restore `$VMAIN = $80` |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$78` | In | Compressed size |
| `$2115`/`$2116` | Out | VRAM control |
| `$7E:A000` | Out | Decompression buffer |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SceneCmd_LoadLayerMaps` | Tileset-only path |
| `Load4bppPage` | Similar full-page upload |
| `QuintetLzDecompress` | Decompression |

#### Display & Character Graphics

### RenderPaletteTiles

Converts palette-indexed map data at `$7E:A000` into SNES 4bpp tile format at `$7E:B000`, then DMAs 4096 bytes to VRAM address `$0000`. Used when `scrollModeFlags` (`$06EF`) bit `$08` is set. Zeroes `$7E:B000`, iterates map at `$7E:A000` using metatile words at `$7E:2000`, assembles 4bpp rows to `$7E:B000`, byte-mode DMA 4096 bytes to VRAM `$0000`. Called from `ClearSceneState` in `scene_lifecycle.asm` (not a separate bank `$03` chunk file).

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Zero `$7E:B000`–`$7E:B000+$4000` |
| 2 | For each map row (0..width): for each column (0..4) |
| 3 | Read palette index from `$A000`; lookup `$2000,Y` tile data |
| 4 | Write 4 bitplanes to `$B000,X` (offset `$00`, `$80` per plane) |
| 5 | Byte-mode DMA `$7E:B000` → VRAM `$0000` |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0693`/`$0697` | In | Map width/height |
| `$7E:A000` | In | Palette-indexed map |
| `$7E:2000` | In | Tile definition lookup |
| `$7E:B000` | Out | SNES 4bpp output |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `scene_lifecycle.asm` | Post-`SceneScriptMain` caller |
| `BuildAttributeTable` | Related attribute mapping |
| `SceneCmd_ConfigDisplay` | Sets Mode 7 flag `$06EF` bit `$08` |

### SceneCmd_ConfigDisplay

Command `$02` reads a preset index, indexes `display_preset_table` (10-byte records), writes TM/TS/TMW/TSW, CGWSEL/CGADSUB, BGMODE, BG1SC/BG2SC, stores **`layerPriorityFlag`** (`$06EE`) from record byte +5 and **`scrollModeFlags`** (`$06EF`, low 5 bits of record byte +7). Derives `$06A2`/`$06A4` priority OR masks, `$06EC` visible height, `$06F1`, and invalidates source-cache slots `$0678`/`$067B` when OR masks change. Record byte +7 bit 3 also clears `$066C` cache when set.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Read preset index; compute offset into `display_preset_table` |
| 2 | Write TM/TS/TMW/TSW, CGWSEL/CGADSUB from table |
| 3 | Parse flag byte: priority bits, scroll bases, interleave |
| 4 | Write BGMODE, BG1SC, BG2SC from table bytes 5–7 |
| 5 | Store `$06EE`, `$06EF`; update `$09ED` bit `$40` (HUD off, `displayModeFlags` bit 14): always `TRB #$40` first, then `TSB #$40` only if record byte +7 bit 7 is set. No record of `display_preset_table` has it, so the command only ever **clears** the HUD-off bit (measured, Mesen2 C4: it undoes `OpenInventoryScreen`'s `$4000` store two frames after the inventory opens) |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$06EE` | Out | `layerPriorityFlag` (bit `$0800` → planar deinterleave path) |
| `$06EF` | Out | `scrollModeFlags` (bit `$08` → palette-tile path in lifecycle) |
| `$06A2`/`$06A4` | Out | BG priority OR masks |
| `$212C`–`$2131` | Out | PPU layer registers |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `display_preset_table.asm` | Display preset data |
| `CheckInterleavedFlag` | Reads `$06EE` bit `$0800` |
| `RebuildCollisionLayer` | Gated on `$06EF` bit `$01` |

### SceneCmd_LoadSpriteTiles

Command `$10` loads sprite tile graphics to OBJ VRAM. Reads a 2-byte size word directly from the script stream (not via `ReadScriptByte`), advances `Y` by 3 for the source pointer, loads the pointer via `LoadScriptPointer`, and cache-checks against slot `$0684`. On cache miss: if compressed (size ≠ 0), decompresses to `$7E:4000`; if uncompressed (size = 0), DMAs raw data from source to `$7E:4000` via `DmaRomToWram`. The decompression destination `$7A = $4000` indicates OBJ tile VRAM staging in WRAM before upload.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Read 2-byte size from script; skip to source pointer |
| 2 | `LoadScriptPointer`; cache-check `$0684` |
| 3 | On miss: decompress or raw DMA to `$7E:4000` |
| 4 | Return |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0666` | In | Size word from script |
| `$0684` | Out | Sprite tile source cache |
| `$7E:4000` | Out | Sprite tile staging buffer |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `CheckSourceCacheHit` | Cache at `$0684` |
| `QuintetLzDecompress` | Compressed path |
| `DmaRomToWram` | Uncompressed path |

### SceneCmd_LoadCharTiles

Command `$17` loads character-specific tile data to BG VRAM. Reads a mode byte to `$066A` and a 3-byte source pointer. Reads inline width/height, computes tile data size via `Multiply8x8Unsigned`, and optionally decompresses to `$7E:7000`. Supports three VRAM targets based on mode: negative mode (bit 7 set) uses computed address; bit 0 → BG1 at VRAM `$1000`; bit 1 → BG2 at VRAM `$1800`; both bits can load sequentially via the `code_028CB0` continuation. DMA uses word mode to upload `$0666` bytes from the source buffer.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Read mode, source pointer, inline dimensions |
| 2 | `Multiply8x8Unsigned` → size in `$0666` |
| 3 | Decompress if needed |
| 4 | If mode bit 7: compute VRAM addr from `$066A` |
| 5 | Else if bit 0: VRAM `$1000`; if bit 1: VRAM `$1800` |
| 6 | Word-mode DMA `$0666` bytes to VRAM |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$066A` | In | Mode: bit 7=computed, 0=BG1, 1=BG2 |
| `$0666` | Out | Tile data byte count |
| `$2116` | Out | VRAM destination |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `Multiply8x8Unsigned` | Size computation |
| `QuintetLzDecompress` | Compressed tile data |
| `SceneCmd_LoadBgTiles` | Related BG tile loading |

#### Parsing Helpers

### FindCurrentScene

Linearly scans the script stream at `($3A)` starting from `Y = 0` to find the entry matching `scene_current` at `$0644`. Each scene entry begins with a 2-byte scene ID. On mismatch, the scanner advances past all commands in that scene using hardcoded operand-size rules identical to those in `SkipScriptCommands`. When `$00` is encountered as a command byte during scanning (end-of-scene within a multi-scene block), the scanner wraps to the next scene header. Returns with `Y` positioned at the first command byte of the matching scene.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `Y = 0` |
| 2 | Read 2-byte scene ID; compare to `$0644` |
| 3 | Match → return |
| 4 | Mismatch → read command bytes, skip operands per size table |
| 5 | On command `$00`: goto step 2 (next scene) |
| 6 | Else: continue skipping; goto step 4 |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0644` | In | Target scene ID |
| `$3A`/`Y` | In/Out | Script stream |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SceneScriptMain` | Called at interpreter entry |
| `SkipScriptCommands` | Shares operand-size logic |
| `SceneCmd_Branch` | `$13` handled in skip path |

### SkipScriptCommands

Advances `Y` past N commands in the script stream, where N is read from the first byte via `ReadScriptByte` and stored on the stack. Also serves as command `$15` handler (self-recursive via the jump table). Uses the same operand-size dispatch as `FindCurrentScene` but counts down until the target skip count is reached. Command `$14` (NOP) has special handling: it reads the next byte and compares against the remaining skip count on the stack, allowing `$15` to skip to a specific command index.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Read count byte; push to stack |
| 2 | Loop: read command byte at `[$3A],Y` |
| 3 | Skip operands per command type |
| 4 | On `$14`: compare operand to count; exit if match |
| 5 | Decrement count; repeat until zero |
| 6 | Pop count; return |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$3A`/`Y` | In/Out | Script stream |
| Stack | In | Remaining skip count |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SceneCmd_Branch` | Jumps here on flag clear |
| `scene_script_jump_table` | Entry `$15` |
| `FindCurrentScene` | Parallel skip logic |

### LoadScriptPointer

Reads a 3-byte pointer from `[$3A],Y` into `(X)` (word at `$0000,X`, bank at `$0002,X`) and mirrors it to `$3E`/`$40`. If bank `< $70`, adds `$80` to the bank byte; if result `≥ $A0`, adds another `$20` and clears bit 15 of the address word (`AND #$7F` on high byte).

### CheckSourceCacheHit

Compares the current source pointer at `$3E`/`$40` against a cached `(addr, bank)` pair at `(X)`. Returns **carry clear** if they match (source unchanged — caller should skip reload). Returns **carry set** if they differ, and updates the cache slot with the new pointer values. This is Tier 1 of the cache-and-diff pattern, preventing redundant decompression and DMA when the same ROM data is referenced across scene transitions.

### DmaRomToWram

Transfers data from ROM (or any source at `$3E`/`$40`) to a WRAM destination at `$42`/`$44`. If the source bank is ≥ `$80` and the address is ≥ `$8000`, uses DMA channel 0 to transfer to `$2181` (WRAM bus). Otherwise falls back to the `$0402` MVN block-copy routine for low-memory sources. Transfer size is `$0666 - $0664`; source offset is `$3E + $0664`; destination is `$42 + $0668`. Handles bank `$7F` WRAM destination with proper `$2183` data bank setup.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | If source bank < `$80` or addr < `$8000`: MVN via `$0402` |
| 2 | Else: configure DMA channel 0 to WRAM |
| 3 | Size = `$0666 - $0664`; source = `$3E + $0664` |
| 4 | Trigger `$420B` |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0664`/`$0666`/`$0668` | In | Source range and dest offset |
| `$3E`/`$40` | In | Source pointer |
| `$42`/`$44` | In | Destination pointer |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SceneCmd_LoadPalette` | Palette window to `$7F:0A00` |
| `SceneCmd_LoadMetatileSets` | Layer copy |
| `WriteMapBounds` | First map row |

### GraphicsCacheLookup

Scans 4 cached source pointer slots at `$0084`–`$008F` (each 3 bytes: addr + bank) for a match against the current `$3E`/`$40`. Returns **carry set** on hit (matching slot found), **carry clear** on miss. This is Tier 2 of the cache system — after Tier 1 confirms the source pointer changed, this check determines whether the VRAM content was previously saved to the ring buffer.

### GraphicsCacheStore

Writes the current source pointer `$3E`/`$40` into the round-robin graphics cache at `$0084`–`$008F`. Uses `$0094` as the write index (0–3), incrementing with wrap. Computes the cache slot offset as `index × 3` bytes from `$0084`. Called after a cache miss when new tile data has been decompressed and uploaded, recording the source for future Tier 2 lookups.

### SaveVramToRingBuffer

Reads VRAM content back into the ring buffer at `$7F:4000+` via `DmaVramToRam`, preserving uploaded tile data for future cache hits. If the transfer size exceeds `$2000` bytes, splits into two DMA operations at the VRAM `$2000` boundary, advancing the ring-buffer slot index for the second half. Marks the next slot with `$FFFF`/`$FF` in the source cache to indicate a split span. Updates `$0094` for the second slot assignment.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Set VRAM addr from `$0668`; compute size |
| 2 | If size > `$2000`: first DMA `$2000` bytes; advance slot |
| 3 | `DmaVramToRam` to ring buffer via `ComputeRingBufferAddr` |
| 4 | If remainder: second DMA from VRAM `$0668 + $1000` |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0668`/`$0666` | In | VRAM addr and size |
| `$0094` | In/Out | Ring buffer slot index |
| `$7F:4000+` | Out | Ring buffer storage |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `DmaVramToRam` | VRAM read-back primitive |
| `RestoreCachedVram` | Inverse operation |
| `ComputeRingBufferAddr` | Slot address math |

### DmaVramToRam

Performs a VRAM-to-RAM DMA read-back using DMA channel 0. Transfer size in `A` (set to `$4305`). Destination address computed by `ComputeRingBufferAddr`. Source is VRAM via `$2139` (VRAM read port). Fixed destination bank `$7F` via `$4304`. Uses `$4300 = $81` (reverse direction: VRAM→CPU) and `$4301 = $39` for the VRAM source increment mode.

### RestoreCachedVram

Restores previously saved VRAM tile data from the ring buffer back to VRAM. Looks up the ring-buffer slot via `system_init.cache_slot_indices` indexed by the cache lookup result in `X`. If the span is ≤ `$2000` bytes, performs a single `DmaWramToVram`. For larger spans, splits at the `$2000` boundary across two ring-buffer slots.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Look up slot index from `cache_slot_indices[X]` |
| 2 | Compute ring buffer address |
| 3 | If size ≤ `$2000`: single `DmaWramToVram` |
| 4 | Else: DMA first `$2000`; advance slot; DMA remainder |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `X` | In | Cache lookup index |
| `$0664`/`$0666`/`$0668` | In | Range and VRAM dest |
| `$7F:4000+` | In | Ring buffer source |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `GraphicsCacheLookup` | Provides index on hit |
| `DmaWramToVram` | Upload primitive |
| `SaveVramToRingBuffer` | Inverse operation |

### DmaWramToVram

DMAs data from WRAM bank `$7F` to VRAM. Sets VRAM address from `$0668` to `$2116`, configures channel 0 with source at `X` (WRAM offset), size in `Y`, word mode to VRAM. Used by `RestoreCachedVram` to replay saved tile strips.

### BuildMetatileFlagTable

Rebuilds tilemap attribute bytes for a 4×N tile region. For each group of 4 tile words, reads the priority bit (bit 1) from each, combines into a 4-bit attribute nibble, and writes to the attribute buffer at `[$42]`. Also ORs priority mask bits from `$06A2,X` / `$06A4,X` into each tile word. The `X` register selects the layer (0 or 2), indexing into parallel priority arrays and source pointer arrays at `$06AA,X` / `$06AE,X`.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Load source pointer from `$06AE,X`; attr dest from `$06AA,X` |
| 2 | For each row (4 iterations): process 4 tile words |
| 3 | OR priority mask; extract bit 1 from each → nibble |
| 4 | Write attribute byte; advance pointers |

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$06A2,X`/`$06A4,X` | In | Priority OR masks |
| `$06AA,X`/`$06AE,X` | In | Attr dest / tile source |
| `$42` | Out | Attribute write pointer |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SceneCmd_LoadMetatileSets` | Called per loaded layer |
| `SceneCmd_ConfigDisplay` | Sets priority masks |
| `BuildAttributeTable` | Related attribute logic |

### RebuildCollisionLayer

Always `FillCollisionFromLayer0` (X=0). **`OverlayCollisionFromLayer1`** (X=2) when `scrollModeFlags` bit 0 is set. Called from `SceneScriptMain` on opcode `$00` unless `sceneCurrent = $F7`.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `FillCollisionFromLayer0` (index 0) |
| 2 | If `scrollModeFlags` bit 0: `OverlayCollisionFromLayer1` (X=2) |
| 3 | Return |

**Source:**

```1799:1810:../../../extracted/system/engine/scene_script.asm
RebuildCollisionLayer {
    LDX #$0000
    JSR $&FillCollisionFromLayer0
    LDA $06EF
    BIT #$01
    BEQ loc_029033
    LDX #$0002
    JSR $&OverlayCollisionFromLayer1

  loc_029033:
    RTS
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$06EF` | In | `scrollModeFlags` bit 0 = dual-layer collision overlay |
| `$06AA`/`$06AC` | In | Flag-table page addresses for layer 0 / layer 1 (bank `$7F`) |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SceneScriptMain` | Post-scene caller |
| `FillCollisionFromLayer0` | Layer 0 refresh |
| `OverlayCollisionFromLayer1` | Layer 1 refresh |

### FillCollisionFromLayer0

Builds the layer 0 part of the collision layer (`$7F:C000`). `$3E`/`$40` is set to the flag table whose page address is in `$06AA` (`collisionFlagTableL0`, bank `$7F`, written by `BuildMetatileFlagTable`). The cell count is `$0693` (`mapRowStrideL0`) × `$0697` via `Multiply8x8Unsigned`. For each cell, reads the metatile number from `$7E:A000 + cell`, uses it as the low byte of `$3E`, and stores the flag byte `[$3E]` to `$7F:C000 + cell` (the store is `STA $7F2000,X` with X starting at `$A000`).

**[Runtime-verified, B1]** Each flag byte is a mask of the four 8 × 8 quadrants of the 16 × 16 cell: `BuildMetatileFlagTable` moves bit 9 of each of the four tilemap words of a 2 × 2 metatile into one nibble of the table (first tile in bit 0) and clears bit 9 in the word (`AND #$FDFF`). Over 223 map scenes, the low nibble of collision cell `i` equals the flag-table nibble of the metatile at map index `i` in every cell of 209 of the 214 single-layer scenes (510,976 cells, 0 mismatches), the table pointer is `$7F:0000` with the metatile definitions at `$7E:2000` and the map at `$7E:A000` in all rows, and no metatile word in use keeps bit 9 set. `$F7` skips the rebuild (leftover bytes); `$FB`, `$FD`, `$FF` load no map and `$FE` (world map) does not write the `$36` frame counter. Five single-layer scenes differ after the build (`$55`, `$6B`, `$78`, `$D6`, `$D7`; 2–2,208 cells), so something rewrites the layer later there; the writer is not traced. Full figures: [`wram-memory-map.md` §4.10](../../wram-memory-map.md).

### OverlayCollisionFromLayer1

Overlays layer 1's flags onto the collision layer (`$7F:C000`). Same structure as `FillCollisionFromLayer0`, but the flag table page is in `$06AC` (`collisionFlagTableL1`), the cell count is `$0695` (`mapRowStrideL1`) × `$0699`, the start index is the word at `$0080` (`$C000`), and the store goes through `$7F0000,X`. A zero flag byte is skipped, so layer 0's value stays where layer 1 has nothing. Nine scenes are dual layer (`scrollModeFlags` bit 0: `$0B $30 $5F $60 $61 $62 $64 $65 $67`); eight of them differ from a layer-0-only rebuild (6 to 2,612 cells), `$30` does not. The overlay rule was not checked cell by cell.

## See Also

*Evidence: [XREF]*

### Callers

| Function | Caller | Context |
|----------|--------|---------|
| `SceneScriptMain` | `scene_lifecycle.asm` `ClearSceneState` | After `ClearBg3TilemapBuffer_Full` |
| `SceneScriptNoMusic` | `inventory_overlay.asm` | Scene `$FF` / restore prior scene graphics |
| `RenderPaletteTiles` | `scene_lifecycle.asm` `ClearSceneState` | When `scrollModeFlags` bit `$08` set |
| `DmaWordToVram` | `scene_lifecycle.asm`, inventory overlay | Word DMA to VRAM (`DmaWordToVram.asm`) |

### Dependencies

| Dependency | Role |
|------------|------|
| [`QuintetLzDecompress.asm`](../../../extracted/system/engine/QuintetLzDecompress.asm) | Compressed payloads |
| [`hardware_math.asm`](../../../extracted/system/engine/hardware_math.asm) | `Multiply8x8Unsigned` — map dimension math |
| [`vblank_joypad.asm`](../../../extracted/system/engine/vblank_joypad.asm) | `WaitFrames`, `DisableNmiKeepJoypad`, `EnableNmiAndJoypad` |
| [`flag_helpers.asm`](../../../extracted/system/engine/flag_helpers.asm) | `TestFlagRaw` — conditional load `$13` |
| [`display_preset_table.asm`](../../../extracted/tables/display_preset_table.asm) | Display presets for command `$02` |
| [`system_init.asm`](../../../extracted/system/engine/system_init.asm) | `cache_slot_indices` — ring-buffer mapping |

### Related Documentation

- [spc-transfer.md](spc-transfer.md) — SPC700 music upload protocol (`SpcMusicLoadCmd`, IPL handshake, embedded sound engine)
- [hardware-and-init.md](hardware-and-init.md) — Hardware math, VBlank, decompression, system init
- [README.md](README.md) — Full bank `$02` overview
- [bank00/system-core.md](../bank00/system-core.md) — Main game loop triggering scene loads

---
