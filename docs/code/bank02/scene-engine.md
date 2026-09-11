# Bank $02 — Scene Script Engine & SPC Transfer

**Bank:** `$02` (FastROM; accessed via `$@` long calls from other banks)
**Document scope:** Scene script interpreter, graphics loading commands, VRAM DMA helpers, source-pointer caching, and SPC700 music upload in the `engine` scene.
**ASM sources:** [`scene_script.asm`](../../../extracted/system/engine/scene_script.asm) (block: `scene_script`), [`spc_transfer.asm`](../../../extracted/system/engine/spc_transfer.asm) (block: `spc_transfer`)

Illusion of Gaia's **scene transition pipeline** is implemented by two interleaved compilation units. A bytecode interpreter walks per-scene script streams, dispatching commands to load BG tiles, tilemaps, sprite/character graphics, and display configuration. The SPC700 upload path streams compressed music data to the embedded sound engine. The interpreter is invoked during room loads from bank `$03` ([`chunk_03BAE1.asm`](../../../extracted/system/chunk_03BAE1.asm)); the built-in SPC engine is uploaded once at cold start from [`system_core.asm`](../../../extracted/system/engine/system_core.asm).

These routines sit above the hardware math, decompression, and VBlank layers documented in [hardware-and-init.md](hardware-and-init.md). Quintet-LZ decompression ([`decompress.asm`](../../../extracted/system/engine/decompress.asm)) is the shared backend for all compressed tile/tilemap payloads.

---

## Address Layout

```
$0283A2 ┌─ DmaWordToVram ─────────────────────────────┐
        │  SceneScriptMain / SceneScriptNoMusic       │
        │  scene_script_jump_table + command handlers │
        │  BG tile / tilemap / display loaders        │
        │  DMA, cache, script parsing helpers         │
$028B6D ├─ SpcMusicLoadCmd ────────────────────────────┤  spc_transfer (part 1)
$028BE4 ├─ SceneCmd_LoadSpriteTiles … ReloadMapLayer1│  scene_script (part 2)
$02908E ├─ SpcLoadBuiltinEngine                       │
        │  SpcBlockTransfer / SpcIplHandshake           │  spc_transfer (part 2)
$029210 ├─ spc_sound_engine (embedded SPC700 binary)   │
$029DE2 └─ (system_init continues) ──────────────────┘
```

The `scene_script` and `spc_transfer` blocks are **physically interleaved** in ROM: command `$11` (`SpcMusicLoadCmd`) lives in the middle of the scene-script address range because both files cross-include each other and the linker places their parts in call-order.

| Metric | `scene_script` | `spc_transfer` | Combined |
|--------|---------------|----------------|----------|
| **Parts** | 42 | 5 | **47** |
| **Code parts** | 41 | 4 | 45 |
| **Data parts** | 1 (`scene_script_jump_table`) | 1 (`spc_sound_engine`) | 2 |
| **Total size (bytes)** | 3,189 | 3,531 | **6,720** |
| **Address range** | `$0283A2`–`$02908E` (2 segments) | `$028B6D`–`$029DE2` (2 segments) | `$0283A2`–`$029DE2` |

**Largest routines:** `spc_sound_engine` (3,026 B binary), `SpcBlockTransfer` (256 B), `SceneCmd_ConfigDisplay` (252 B), `SceneCmd_LoadBgTiles` (245 B), `RenderPaletteTiles` (240 B).

---

## Command Dispatch Table

The 24-entry jump table at `$028416` maps command indices `$00`–`$17` to handler addresses. Unimplemented indices fall through to `code_02845C` (immediate `RTS` — no-op).

| Cmd | Hex | Handler | Description |
|-----|-----|---------|-------------|
| `$00`–`01` | — | `code_02845C` | Unimplemented (NOP return) |
| `$02` | `$02` | `SceneCmd_ConfigDisplay` | Read `table_018000` entry; configure TM/TS/TMW/TSW/CGWSEL/CGADSUB/BGMODE/BG1SC/BG2SC and scene flags |
| `$03` | `$03` | `SceneCmd_LoadBgTiles` | Multi-mode BG tile loader (4 modes) |
| `$04` | `$04` | `SceneCmd_LoadTilemap` | Single-layer tilemap DMA |
| `$05` | `$05` | `SceneCmd_LoadDualTilemap` | Dual-layer tilemap with per-layer cache check |
| `$06` | `$06` | `SceneCmd_FullGraphics` | Full scene graphics — map geometry + tileset + tilemap |
| `$07`–`0D` | — | `code_02845C` | Unimplemented (NOP return) |
| `$0E` | `$0E` | `SceneCmd_Skip3` | Skip 3 script bytes (placeholder NOP) |
| `$0F` | — | `code_02845C` | Unimplemented (NOP return) |
| `$10` | `$10` | `SceneCmd_LoadSpriteTiles` | Sprite tile graphics → VRAM `$4000` |
| `$11` | `$11` | `SpcMusicLoadCmd` | SPC music load (in `spc_transfer.asm`) |
| `$12` | — | `code_02845C` | Unimplemented (NOP return) |
| `$13` | `$13` | `SceneCmd_ConditionalLoad` | Test event flag → skip or execute command `$15` |
| `$14` | `$14` | `SceneCmd_Nop` | Skip 1 script byte |
| `$15` | `$15` | `SkipScriptCommands` | Skip N commands of varying sizes |
| `$16` | — | `code_02845C` | Unimplemented (NOP return) |
| `$17` | `$17` | `SceneCmd_LoadCharTiles` | Character-specific tile data to BG1/BG2 VRAM |

**Implemented script commands:** 11 of 24 table entries (`$02`–`$06`, `$0E`, `$10`–`$11`, `$13`–`$15`, `$17`).

### Command Operand Sizes

Used by `FindCurrentScene` and `SkipScriptCommands` when advancing past unknown scenes:

| Cmd | Bytes after opcode | Notes |
|-----|-------------------|-------|
| `$02` | 1 | Display config index |
| `$03` | 7 | VRAM offset, range, mode, 3-byte source pointer |
| `$04` | 6 | start/end/VRAM offsets + 3-byte pointer |
| `$05` | 7 | BG1+BG2 params + 3-byte pointer |
| `$06` | 4+ | Layer flags + 3-byte pointer (+ inline geometry) |
| `$0E` | 3 | Skipped inline |
| `$10` | 5 | 2-byte size + 3-byte pointer |
| `$11` | 5 | Track ID + cache key + 3-byte pointer |
| `$13` | 2 | Flag index + `$15` count |
| `$14` | 1 | NOP skip |
| `$15` | 1+ | Count byte, then N commands |
| `$17` | 4+ | Mode byte + 3-byte pointer (+ inline size) |

---

## Cache-and-Diff Pattern

Graphics loaders avoid redundant VRAM uploads through a two-tier **compare-and-skip** system.

### Tier 1 — Per-Command Source Cache (`CheckSourceCacheHit`)

Most commands store the last-used `(addr, bank)` pair at a dedicated WRAM slot. Before any decompression or DMA:

1. `LoadScriptPointer` fills `($3E,$40)` from the script stream.
2. `CheckSourceCacheHit` compares `($3E,$40)` against `(X)` — the cache slot passed in `X`.
3. **Match (carry clear):** Source unchanged → handler returns immediately (no VRAM touch).
4. **Mismatch (carry set):** Updates the cache slot and proceeds to load.

### Tier 2 — VRAM Content Cache (tile strips)

For `SceneCmd_LoadBgTiles` mode 0 (horizontal strip), an additional content cache prevents re-decompressing identical tile data:

1. `GraphicsCacheLookup` scans 4 slots at `$0084`–`$008F` for a matching `(addr, bank)`.
2. **Hit:** `RestoreCachedVram` DMAs the saved VRAM snapshot from the ring buffer at `$7F:4000+` back to the target VRAM address.
3. **Miss:** Decompress → DMA to VRAM → `GraphicsCacheStore` records the source pointer → `SaveVramToRingBuffer` reads VRAM back into the ring buffer.

The ring-buffer slot index is tracked in `$0094` (round-robin, 4 slots). Slot-to-buffer mapping uses `ComputeRingBufferAddr` and `system_init.cache_slot_indices`.

### Dual-Layer Partial Reload

`SceneCmd_LoadDualTilemap` and `SceneCmd_FullGraphics` use bit flags in `$066A` to independently cache-check each layer. If layer 0 hits cache but layer 1 misses, only layer 1 reloads.

---

## scene_script.asm

| Address | Name | Size | Description |
|---------|------|------|-------------|
| `$0283A2` | DmaWordToVram | 25 B | `DmaWordToVram` is the shared primitive for word-mode DMA transfers from a source address in any bank to VRAM. |
| `$0283BB` | SceneScriptMain | 44 B | `SceneScriptMain` is the primary scene script interpreter invoked during room loads. |
| `$0283E7` | SceneScriptNoMusic | 47 B | `SceneScriptNoMusic` is a variant interpreter identical to `SceneScriptMain` except that command `$11` (`SpcMusicLoadCmd`) is skipped inline. |
| `$028416` | scene_script_jump_table | 48 B | The 24-entry dispatch table maps scene script command indices `$00`–`$17` to handler addresses. |
| `$028446` | SceneCmd_ConditionalLoad | 21 B | Command `$13` implements conditional script execution based on event flags. |
| `$02845B` | SceneCmd_Nop | 2 B | Command `$14` is a minimal no-operation handler. |
| `$02845D` | SceneCmd_LoadBgTiles | 245 B | Command `$03` is the multi-mode BG tile loader — the most complex graphics command in the scene script. |
| `$028552` | SceneDmaTileShim | 3 B | A 3-byte entry shim consisting of `PHP` followed by `BRA DmaTileStripToVram`. |
| `$028555` | CheckInterleavedFlag | 11 B | Checks the interleaved graphics flag at `$06EE` bit `$0800`, set by `SceneCmd_ConfigDisplay` when the scene uses planar 2bpp+2bpp tile encoding instead of standard SNES 4bpp. |
| `$028560` | DmaTileStripToVram | 50 B | DMAs a tile strip from the current source pointer (`$3E`/`$40`) to VRAM. |
| `$028592` | Load4bppPage | 73 B | Loads a full 4bpp tile page (4096 bytes) to VRAM address `$2000`. |
| `$0285DB` | DeinterleavePlanarTiles | 177 B | Converts interleaved 2bpp+2bpp planar tile data to SNES 4bpp format. |
| `$02868C` | BuildAttributeTable | 55 B | Builds a 256-byte palette-to-attribute lookup table at `$7E:2800` from tilemap metadata at `$7E:2000`. |
| `$0286C3` | SceneCmd_LoadTilemap | 79 B | Command `$04` loads a single-layer tilemap from ROM into WRAM buffer `$7F:0A00`. |
| `$028712` | SceneCmd_LoadDualTilemap | 170 B | Command `$05` loads tilemap data for both BG layers from a single compressed blob. |
| `$0287BC` | SceneCmd_FullGraphics | 217 B | Command `$06` is the comprehensive scene graphics loader — map geometry, tileset, and tilemap in one command. |
| `$028895` | StoreMapAndDecompress | 32 B | Stores map dimensions from inline geometry bytes (`$00`/`$02` = width/height) into the map bounds array at `$0693,X` ... |
| `$0288B5` | HandleEmptyGeometry | 95 B | Handles the case where the geometry size word read from the source stream is zero — meaning no compressed tileset follows inline. |
| `$028914` | WriteMapBounds | 18 B | Writes map width and height from `$00`/`$02` into the bounds arrays at `$0692,X` and `$0696,X`, then DMAs the first map row from the current source pointer via `DmaRomToWram`. |
| `$028926` | DmaLowVramTileset | 87 B | Uploads a tileset to low VRAM at address `$2000` using byte-write mode, required for Mode 0 BG tile uploads. |
| `$02897D` | RenderPaletteTiles | 240 B | Converts palette-indexed map data at `$7E:A000` into SNES 4bpp tile format at `$7E:B000`, then DMAs 4096 bytes to VRAM address `$0000`. |
| `$028A6D` | SceneCmd_ConfigDisplay | 252 B | Command `$02` configures the SNES PPU for a scene by reading a 1-byte index into `table_018000` — a preset table of display register values. |
| `$028B69` | SceneCmd_Skip3 | 4 B | Command `$0E` is a placeholder NOP that advances the script index by 3 bytes. |
| `$028BE4` | SceneCmd_LoadSpriteTiles | 76 B | Command `$10` loads sprite tile graphics to OBJ VRAM. |
| `$028C30` | SceneCmd_LoadCharTiles | 183 B | Command `$17` loads character-specific tile data to BG VRAM. |
| `$028CE7` | ReadScriptByte | 11 B | Reads the next byte from the script stream at `[$3A],Y` and advances `Y` by one. |
| `$028CF2` | FindCurrentScene | 75 B | Linearly scans the script stream at `($3A)` starting from `Y = 0` to find the entry matching `scene_current` at `$0644`. |
| `$028D3D` | SkipScriptCommands | 82 B | Advances `Y` past N commands in the script stream, where N is read from the first byte via `ReadScriptByte` and stored on the stack. |
| `$028D8F` | LoadScriptPointer | 50 B | Reads a 3-byte pointer (2-byte address + 1-byte bank) from the script stream at `[$3A],Y` and stores it at `(X)` (address at offset 0, bank at offset 2). |
| `$028DC1` | CheckSourceCacheHit | 41 B | Compares the current source pointer at `$3E`/`$40` against a cached `(addr, bank)` pair at `(X)`. |
| `$028DEA` | DmaRomToWram | 133 B | Transfers data from ROM (or any source at `$3E`/`$40`) to a WRAM destination at `$42`/`$44`. |
| `$028E6F` | GraphicsCacheLookup | 37 B | Scans 4 cached source pointer slots at `$0084`–`$008F` (each 3 bytes: addr + bank) for a match against the current `$3E`/`$40`. |
| `$028E94` | GraphicsCacheStore | 36 B | Writes the current source pointer `$3E`/`$40` into the round-robin graphics cache at `$0084`–`$008F`. |
| `$028EB8` | SaveVramToRingBuffer | 96 B | Reads VRAM content back into the ring buffer at `$7F:4000+` via `DmaVramToRam`, preserving uploaded tile data for future cache hits. |
| `$028F18` | DmaVramToRam | 43 B | Performs a VRAM-to-RAM DMA read-back using HDMA channel 0. |
| `$028F43` | ComputeRingBufferAddr | 16 B | Computes the WRAM ring-buffer address for the current cache slot index in `$0094`. |
| `$028F53` | RestoreCachedVram | 84 B | Restores previously saved VRAM tile data from the ring buffer back to VRAM. |
| `$028FA7` | DmaWramToVram | 38 B | DMAs data from WRAM bank `$7F` to VRAM. |
| `$028FCD` | RebuildTilemapAttrs | 83 B | Rebuilds tilemap attribute bytes for a 4×N tile region. |
| `$029020` | ReloadMapData | 20 B | Refreshes both map layers from their cached source pointers after scene script execution completes. |
| `$029034` | ReloadMapLayer0 | 44 B | Reloads layer 0 map strip from the cached source pointer at `$06AA` into `$7F:2000`. |
| `$029060` | ReloadMapLayer1 | 46 B | Reloads layer 1 map strip from the cached source pointer at `$06AC` into `$7F:0000`. |

#### Script Engine Core

### DmaWordToVram


`DmaWordToVram` is the shared primitive for word-mode DMA transfers from a source address in any bank to VRAM. Callers pass the source address in `A` (bank byte in high byte via `XBA` convention), source offset in `X` (`$A1T0L`), and transfer size in `Y` (`$DAS0L`). The routine configures HDMA channel 0 for VRAM destination (`$BBAD0 = $18`), word increment, and triggers `$420B`. This routine is the foundation for all tile-strip uploads in the scene loader. `DmaWramToVram` wraps it with VRAM address setup from `$0668`. Tile loaders call it indirectly through `SceneDmaTileShim` → `DmaTileStripToVram`, which adds VRAM destination and source offset math before falling through to the same DMA register pattern.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Store source offset to `$A1T0L` (`STX`) |
| 2 | Store source bank to `$A1B0` (`STA`) |
| 3 | Store transfer size to `$DAS0L` (`STY`) |
| 4 | Configure `$DMAP0 = $01` (word, fixed dest), `$BBAD0 = $18` (VRAM) |
| 5 | Trigger DMA via `$MDMAEN = $01` |
| 6 | Return (`RTL`) |

**Source:**

```22:33:../../../extracted/system/engine/scene_script.asm
DmaWordToVram {
    STX $A1T0L
    STA $A1B0
    STY $DAS0L
    LDA #$01
    STA $DMAP0
    LDA #$18
    STA $BBAD0
    LDA #$01
    STA $MDMAEN
    RTL
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `A` (in) | In | Source bank byte |
| `X` (in) | In | Source address offset (`$A1T0L`) |
| `Y` (in) | In | Transfer size in words (`$DAS0L`) |
| `$4300`–`$4305` | Out | DMA channel 0 configuration |
| `$420B` | Out | DMA enable trigger |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `DmaWramToVram` | Wrapper that sets VRAM addr then calls equivalent register setup |
| `DmaTileStripToVram` | Inline equivalent for tile-strip path |
| `SceneCmd_LoadBgTiles` | Indirect caller via decompression → DMA chain |

### SceneScriptMain


`SceneScriptMain` is the primary scene script interpreter invoked during room loads. It saves processor flags, switches to 8-bit accumulator mode, and calls `FindCurrentScene` to position `Y` at the command stream for the current scene ID in `$0644`. The main loop reads bytes via `ReadScriptByte` until `$00` (end-of-scene marker). Non-zero bytes index into `scene_script_jump_table` (`command_id × 2` → word handler address). Handlers are invoked via the **fake return-address jump** pattern: `PEA handler-1` / `RTS`, which pushes a return address pointing one byte before the loop label so execution resumes after the handler returns. When `$00` is encountered, if `scene_current ≠ $F7`, `ReloadMapData` refreshes both map layers from cached source pointers (used when returning to a previously loaded room). Scene `$F7` is a special case that skips the reload.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `PHP`; `SEP #$20` |
| 2 | `JSR FindCurrentScene` — set `Y` to current scene's command stream |
| 3 | Loop: `JSR ReadScriptByte` |
| 4 | If byte = `$00` → goto step 7 |
| 5 | `PEA loop-1`; index jump table; `DEC`/`PHA`/`RTS` to dispatch handler |
| 6 | Handler returns → goto step 3 |
| 7 | If `$0644 ≠ $F7`, `JSR ReloadMapData` |
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
    JSR $&ReloadMapData

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
| `$06EF` | In | Bit `$01` gates layer 1 reload in `ReloadMapData` |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `chunk_03BAE1.asm` | Primary caller during scene load |
| `FindCurrentScene` | Positions `Y` at matching scene entry |
| `scene_script_jump_table` | Command dispatch table |
| `ReloadMapData` | Post-scene map refresh |
| `SceneScriptNoMusic` | Variant that skips music command |

### SceneScriptNoMusic


`SceneScriptNoMusic` is a variant interpreter identical to `SceneScriptMain` except that command `$11` (`SpcMusicLoadCmd`) is skipped inline. When the jump table entry matches `SpcMusicLoadCmd`, the routine advances `Y` by 5 bytes (the full operand size of command `$11`) instead of dispatching to the music handler. This variant is used by the inventory overlay so opening the menu does not restart BGM. Unlike `SceneScriptMain`, it does not call `ReloadMapData` at scene end — it simply restores flags and returns.

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


The 24-entry dispatch table maps scene script command indices `$00`–`$17` to handler addresses. Each entry is a 2-byte same-bank pointer (`&handler`). Unimplemented commands point to `code_02845C`, which is a single `RTS`. Command `$11` points across the compilation unit boundary to `spc_transfer.SpcMusicLoadCmd`, reflecting the physical interleaving of the two ASM files in ROM. The table is indexed by `command_byte × 2` in 16-bit mode during dispatch.

**Algorithm:**

| Index | Handler | Status |
|-------|---------|--------|
| `$00`–`01`, `$07`–`0D`, `$0F`, `$12`, `$16` | `code_02845C` | NOP (RTS) |
| `$02`–`$06`, `$0E`, `$10`–`11`, `$13`–`15`, `$17` | Named handlers | Implemented |

**Source:**

```102:127:../../../extracted/system/engine/scene_script.asm
scene_script_jump_table [
  &code_02845C   ;00
  &code_02845C   ;01
  &SceneCmd_ConfigDisplay   ;02
  &SceneCmd_LoadBgTiles   ;03
  &SceneCmd_LoadTilemap   ;04
  &SceneCmd_LoadDualTilemap   ;05
  &SceneCmd_FullGraphics   ;06
  &code_02845C   ;07
  ...
  &SceneCmd_LoadCharTiles   ;17
]
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| Table at `$028416` | Out | 24 × 2-byte handler pointers |
| `X` (in) | In | Index = `command × 2` |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SceneScriptMain` | Indexes table for dispatch |
| `SceneScriptNoMusic` | Indexes table; special-case for entry `$11` |
| All `SceneCmd_*` handlers | Targets of table entries |

### SceneCmd_ConditionalLoad


Command `$13` implements conditional script execution based on event flags. After reading a flag index byte from the script stream, it calls `TestFlagRaw` from the COP handler module. If the flag is **clear** (carry clear), execution falls through to `SkipScriptCommands`, which skips the next N commands (the count follows in the script stream as part of command `$15` semantics). If the flag is **set** (carry set), the handler advances `Y` by one byte (skipping the skip-count operand) and returns, allowing the guarded commands to execute normally on subsequent loop iterations.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Read flag index byte |
| 2 | `JSL TestFlagRaw` with index on stack |
| 3 | If carry clear → `JMP SkipScriptCommands` |
| 4 | If carry set → `INY`; return |

**Source:**

```129:144:../../../extracted/system/engine/scene_script.asm
SceneCmd_ConditionalLoad {
    PHP
    REP #$20
    JSR $&ReadScriptByte
    PHY
    JSL $@cop_handlers_script.TestFlagRaw
    PLY
    BCC loc_028458
    PLP
    JMP $&SkipScriptCommands

  loc_028458:
    INY
    PLP
    RTS
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| Script byte (in) | In | Event flag index |
| `Y` | Out | Advanced past skip-count on flag-set path |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `TestFlagRaw` | Flag query (`cop_handlers_script.asm`) |
| `SkipScriptCommands` | Skip target when flag clear |
| `FindCurrentScene` | Must understand `$13` operand size when scanning |

### SceneCmd_Nop

Command `$14` is a minimal no-operation handler. After the dispatch loop reads the opcode byte, this handler advances `Y` by one byte — skipping a single script operand — and returns to the interpreter loop without side effects.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `INY` (skip 1 script byte) |
| 2 | Return to interpreter loop |

**Source:**

```157:159:../../../extracted/system/engine/scene_script.asm
SceneCmd_Nop {
    INY 
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `Y` | Out | Advanced by 1 |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `scene_script_jump_table` | Entry `$14` |
| `SkipScriptCommands` | Special `$14` handling during bulk skip |

#### BG Tile Loading

### SceneCmd_LoadBgTiles


Command `$03` is the multi-mode BG tile loader — the most complex graphics command in the scene script. It reads a VRAM destination offset (`×2` stored to `$0664`), a source range end (`×2` → `$0666`), a VRAM base offset (`×2` → `$0668`), a 3-byte source pointer, and a mode byte selecting one of four loading strategies. **Mode 0** (horizontal strip): Applies cache check at slot `$066C`/`$066F`/`$0670` depending on VRAM offset bit `$0010`. Uses Tier 2 VRAM content cache (`GraphicsCacheLookup`/`RestoreCachedVram`) for decompressed data. **Mode 1** (two-row block): Cache slots `$0672`–`$0676`. **Mode 2** (full page): Jumps directly to `Load4bppPage`. **Mode 3** (raw copy): Uncompressed path through `CheckInterleavedFlag`. When compressed (`size word ≠ 0`), data is decompressed to `$7E:7000` via `QuintetLzDecompress`, then DMA'd to VRAM and saved to the ring buffer.

**Algorithm:**

| Mode | Value | Behavior |
|------|-------|----------|
| 0 | `$00` | Strip load + source cache + VRAM ring cache |
| 1 | `$01` | Two-row block load |
| 2 | `$02` | Full 4bpp page via `Load4bppPage` |
| 3 | `$03` | Raw uncompressed copy |

| Step | Action |
|------|--------|
| 1 | Read VRAM offset, range, base, source pointer, mode |
| 2 | Adjust `$0668` base per mode; select cache slot in `X` |
| 3 | `CheckSourceCacheHit` — return if unchanged |
| 4 | Read size word from source; branch compressed/uncompressed |
| 5 | On miss: decompress → `SceneDmaTileShim` → `SaveVramToRingBuffer` |

**Source:**

```154:283:../../../extracted/system/engine/scene_script.asm
SceneCmd_LoadBgTiles {
    PHP
    REP #$20
    JSR $&ReadScriptByte
    XBA
    ASL
    STA $0664
    ...
    PLP
    RTS
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0664` | Out | Source range start (×2) |
| `$0666` | Out | Source range end (×2) |
| `$0668` | Out | VRAM destination base |
| `$0670`–`$0676` | Out | Per-mode cache slot indices |
| `$78` | Out | Compressed size word |
| `$06EE` | In | Bit `$0800` = interleaved planar tiles |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `Load4bppPage` | Mode 2 target |
| `SceneDmaTileShim` | Post-decompress DMA entry |
| `GraphicsCacheLookup` | Tier 2 cache check |
| `DeinterleavePlanarTiles` | Interleaved path from mode 0 |

### SceneDmaTileShim

A 3-byte entry shim consisting of `PHP` followed by `BRA DmaTileStripToVram`. Post-decompression tile uploads call this shim so processor flags are saved before falling through to the shared DMA path in `DmaTileStripToVram`.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `PHP` — save flags |
| 2 | `BRA DmaTileStripToVram` — join tile-strip DMA |

**Source:**

```296:298:../../../extracted/system/engine/scene_script.asm
SceneDmaTileShim {
    PHP 
    BRA DmaTileStripToVram
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$3E`/`$40` | In | Decompressed tile source (set by caller) |
| `$0664`/`$0666`/`$0668` | In | Source range and VRAM destination |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SceneCmd_LoadBgTiles` | Caller after decompression |
| `DmaTileStripToVram` | Branch target |

### CheckInterleavedFlag

Checks the interleaved graphics flag at `$06EE` bit `$0800`, set by `SceneCmd_ConfigDisplay` when the scene uses planar 2bpp+2bpp tile encoding instead of standard SNES 4bpp. On the uncompressed tile path in `SceneCmd_LoadBgTiles`, a set flag redirects to `DeinterleavePlanarTiles` rather than direct DMA.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Test `$06EE` bit `$0800` |
| 2 | If clear → fall through to `DmaTileStripToVram` |
| 3 | If set → `JMP DeinterleavePlanarTiles` |

**Source:**

```300:304:../../../extracted/system/engine/scene_script.asm
  CheckInterleavedFlag:
    LDA $layerPriorityFlag
    BIT #$0800
    BEQ DmaTileStripToVram
    JMP $&code_0285F3
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$06EE` | In | Display flags; bit `$0800` = interleaved planar tiles |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SceneCmd_ConfigDisplay` | Sets interleaved flag |
| `DeinterleavePlanarTiles` | Redirect target |
| `SceneCmd_LoadBgTiles` | Branch entry on uncompressed path |

### DmaTileStripToVram


DMAs a tile strip from the current source pointer (`$3E`/`$40`) to VRAM. Computes the source address as `$3E + $0664`, transfer size as `$0666 - $0664`, and writes the VRAM destination from `$0668` to `$2116` (`VMADDL`). Uses channel 0 word-mode DMA to VRAM. This is the final upload step for uncompressed tile data in modes 0 and 1, and for decompressed data that does not require planar conversion.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Write `$0668` → `$2116` (VRAM address) |
| 2 | Source = `$3E + $0664`; size = `$0666 - $0664` |
| 3 | Configure DMA channel 0: word mode, VRAM dest |
| 4 | Trigger `$420B`; restore flags; return |

**Source:**

```295:318:../../../extracted/system/engine/scene_script.asm
  DmaTileStripToVram:
    LDA $0668
    XBA
    STA $VMADDL
    LDA $3E
    CLC
    ADC $0664
    STA $A1T0L
    LDA $0666
    SEC
    SBC $0664
    STA $DAS0L
    SEP #$20
    LDA #$01
    STA $DMAP0
    ...
    PLP
    RTS
}
```

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

**Source:**

```320:353:../../../extracted/system/engine/scene_script.asm
Load4bppPage {
    LDA [$3E]
    STA $78
    INC $3E
    INC $3E
    CMP #$0000
    BEQ loc_0285B2
    LDX #$7000
    STX $7A
    JSL $@decompress.QuintetLzDecompress
    ...
    PLP
    RTS
}
```

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


Converts interleaved 2bpp+2bpp planar tile data to SNES 4bpp format. The entry label decompresses data to `$7E:7000`; the main loop in `code_0285F3` reads 16×2-byte rows from the decompressed buffer, interleaves bitplanes via rotate/or operations, and writes 8 bytes per tile row to `$7E:A000`. After processing 8192 source bytes (4096 output bytes), byte-mode DMA uploads the result to VRAM address `$0000` with `$VMAIN = $80` (increment high word). `BuildAttributeTable` is called first to prepare palette attribute mapping.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Decompress to `$7E:7000` |
| 2 | `BuildAttributeTable` — map palette indices |
| 3 | For each 16-byte source row: interleave 8 bitplane pairs → 8 output bytes |
| 4 | Repeat until 8192 bytes processed |
| 5 | Byte-mode DMA `$7E:A000` → VRAM `$0000` |

**Source:**

```355:450:../../../extracted/system/engine/scene_script.asm
DeinterleavePlanarTiles {
    STZ $0670
    ...
    JSL $@decompress.QuintetLzDecompress
}

code_0285F3 {
    PHY
    PHB
    ...
    JSR $&BuildAttributeTable
  loc_028608:
    ...
    PLP
    RTS
}
```

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

**Source:**

```452:485:../../../extracted/system/engine/scene_script.asm
BuildAttributeTable {
    PHP
    REP #$20
    LDA #$0000
    TAY

  loc_028693:
    STA $2800, Y
    ...
    PLP
    RTS
}
```

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
| `RebuildTilemapAttrs` | Related attribute manipulation |

#### Tilemap Loading

### SceneCmd_LoadTilemap


Command `$04` loads a single-layer tilemap from ROM into WRAM buffer `$7F:0A00`. Reads three offset bytes (each ×2 for word alignment) into `$0664` (start), `$0666` (end), and `$0668` (VRAM offset). Loads the 3-byte source pointer and DMAs the tilemap slice via `DmaRomToWram`. Special case: when VRAM offset equals `$0020`, after the DMA the routine copies one row from `$7F:0A20` to `$7F:0A00` — a single-row refresh used when only the top map row changed.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Read start/end/VRAM offsets (×2 each) |
| 2 | If VRAM offset ≠ `$0020`: load pointer → DMA to `$7F:0A00` |
| 3 | If VRAM offset = `$0020`: DMA then copy row `$0A20` → `$0A00` |
| 4 | Return |

**Source:**

```487:523:../../../extracted/system/engine/scene_script.asm
SceneCmd_LoadTilemap {
    PHP
    REP #$20
    JSR $&ReadScriptByte
    ASL
    STA $0664
    ...
    PLP
    RTS
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0664`/`$0666`/`$0668` | Out | Source range and VRAM offset |
| `$7F:0A00` | Out | Tilemap WRAM buffer |
| `$42`/`$44` | Out | DMA destination addr/bank |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `DmaRomToWram` | Transfer primitive |
| `LoadScriptPointer` | Reads 3-byte source |
| `ReloadMapLayer0` | Uses cached map data at reload |

### SceneCmd_LoadDualTilemap


Command `$05` loads tilemap data for both BG layers from a single compressed blob. Reads BG1 and BG2 offset parameters (each ÷4 from script bytes), a layer flag byte to `$066A`, and a 3-byte source pointer. Performs independent cache checks for layer 0 (slot `$0678`) and layer 1 (slot `$067B`), clearing bits in `$066A` for layers that hit cache. On cache miss, decompresses the combined blob to `$7E:7000`, then copies layer 0 to `$7E:2000` and layer 1 to `$7E:2800` via `DmaRomToWram`, calling `RebuildTilemapAttrs` for each loaded layer to apply priority bits from `$06A2`/`06A4`.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Read BG1/BG2 offsets, layer flags, source pointer |
| 2 | Cache-check layer 0 (`$0678`); clear bit 0 on hit |
| 3 | Cache-check layer 1 (`$067B`); clear bit 1 on hit |
| 4 | If `$066A = 0`: return (both cached) |
| 5 | Decompress if needed; copy layers per remaining flags |
| 6 | `RebuildTilemapAttrs` per loaded layer |

**Source:**

```525:607:../../../extracted/system/engine/scene_script.asm
SceneCmd_LoadDualTilemap {
    PHP
    REP #$20
    JSR $&ReadScriptByte
    ...
    PLP
    RTS
}
```

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
| `RebuildTilemapAttrs` | Priority bit application |
| `SceneCmd_FullGraphics` | Shares layer flag pattern |

### SceneCmd_FullGraphics


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

**Source:**

```609:719:../../../extracted/system/engine/scene_script.asm
SceneCmd_FullGraphics {
    STZ $0664
    STZ $0665
    JSR $&ReadScriptByte
    STA $066A
    ...
    RTS
}
```

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


Stores map dimensions from inline geometry bytes (`$00`/`$02` = width/height) into the map bounds array at `$0693,X` / `$0697,X`, computes the tile count via `SignedMultiply`, and decompresses the tileset blob pointed to by `$069E,X` into `$7E:7000` (via `$7A`). The `X` register selects the layer index (0 or 2 for layer 0/1), indexing into parallel arrays for dual-layer scenes.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Store width → `$0693,X`; height → `$0697,X` |
| 2 | `SignedMultiply` → tile count at `$069B,X` |
| 3 | Load decompress source from `$069E,X` → `$7A` |
| 4 | `JSL QuintetLzDecompress` |

**Source:**

```721:735:../../../extracted/system/engine/scene_script.asm
StoreMapAndDecompress {
    LDA $01
    STA $0693, X
    XBA
    LDA $03
    STA $0697, X
    JSL $@hardware_math.SignedMultiply
    STA $069B, X
    REP #$20
    LDA $069E, X
    STA $7A
    JSL $@decompress.QuintetLzDecompress
    SEP #$20
    RTS
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$00`/`$02` | In | Width/height from source stream |
| `$0693,X`/`$0697,X` | Out | Map dimensions |
| `$069B,X` | Out | Tile count product |
| `X` | In | Layer index (0 or 2) |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SceneCmd_FullGraphics` | Caller |
| `SignedMultiply` | Dimension math |
| `HandleEmptyGeometry` | Alternate entry in same block |

### HandleEmptyGeometry


Handles the case where the geometry size word read from the source stream is zero — meaning no compressed tileset follows inline. Computes tileset size from width×height via `SignedMultiply`, then DMAs raw tileset data and writes map bounds. For layer 0 (bit `$01` in `$066A`): DMA tileset to `$7E:A000`, call `WriteMapBounds` with `$0000` index, then copy map row to `$7E:C000`. For layer 1 only: uses index `$0002` for `WriteMapBounds` with destination `$7E:C000`.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `SignedMultiply` width×height → `$0667` |
| 2 | If layer 0 flagged: DMA tileset → `$7E:A000`; `WriteMapBounds` index 0 |
| 3 | If layer 1 flagged: copy map to `$7E:C000`; store bounds |
| 4 | Return |

**Source:**

```736:780:../../../extracted/system/engine/scene_script.asm
  HandleEmptyGeometry:
    SEP #$20
    LDA $01
    XBA
    LDA $03
    JSL $@hardware_math.SignedMultiply
    STZ $0666
    STA $0667
    ...
    RTS
```

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
| `SceneCmd_FullGraphics` | Entry when size word = 0 |
| `DmaRomToWram` | Raw tileset copy |

### WriteMapBounds

Writes map width and height from `$00`/`$02` into the bounds arrays at `$0692,X` and `$0696,X`, then DMAs the first map row from the current source pointer via `DmaRomToWram`. The `X` register selects the layer index (0 or 2). Called from `HandleEmptyGeometry` when inline geometry has no compressed tileset blob.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Store width → `$0692,X`; height → `$0696,X` |
| 2 | `JSR DmaRomToWram` — copy first map row |
| 3 | Return |

**Source:**

```794:803:../../../extracted/system/engine/scene_script.asm
WriteMapBounds {
    REP #$20
    LDA $00
    STA $0692, X
    LDA $02
    STA $0696, X
    JSR $&DmaRomToWram
    SEP #$20
    RTS 
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$00`/`$02` | In | Width/height from source stream |
| `$0692,X`/`$0696,X` | Out | Map bounds arrays |
| `X` | In | Layer index |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `HandleEmptyGeometry` | Caller |
| `DmaRomToWram` | First-row DMA |

### DmaLowVramTileset


Uploads a tileset to low VRAM at address `$2000` using byte-write mode, required for Mode 0 BG tile uploads. Reads the size word from the source stream; if non-zero, decompresses to `$7E:A000` before DMA. Temporarily sets `$2115` (`VMAIN`) to `$00` for byte increment, then restores `$80` after the transfer. Called from `SceneCmd_FullGraphics` when no layer flags are set (tileset-only reload).

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Read size word; decompress to `$7E:A000` if compressed |
| 2 | Set VRAM addr `$2000`; `$VMAIN = $00` |
| 3 | Byte-mode DMA 4096 bytes to VRAM |
| 4 | Restore `$VMAIN = $80` |

**Source:**

```794:834:../../../extracted/system/engine/scene_script.asm
DmaLowVramTileset {
    REP #$20
    LDA [$3E]
    INC $3E
    INC $3E
    STA $78
    ...
    RTS
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$78` | In | Compressed size |
| `$2115`/`$2116` | Out | VRAM control |
| `$7E:A000` | Out | Decompression buffer |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SceneCmd_FullGraphics` | Tileset-only path |
| `Load4bppPage` | Similar full-page upload |
| `QuintetLzDecompress` | Decompression |

#### Display & Character Graphics

### RenderPaletteTiles


Converts palette-indexed map data at `$7E:A000` into SNES 4bpp tile format at `$7E:B000`, then DMAs 4096 bytes to VRAM address `$0000`. Used for Mode 7 palette tile rendering when `$06EF` bit `$08` is set. The routine zeroes the output buffer, then iterates map rows and columns, looking up tile definitions from the attribute table at `$7E:2000` and assembling 4 bitplanes into the SNES tile layout. Map width is capped at 4 tiles per row (`$1C` clamped to `$04`). After processing all rows, byte-mode DMA uploads the result. Called from `chunk_03BAE1.asm` after scene load completes.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Zero `$7E:B000`–`$7E:B000+$4000` |
| 2 | For each map row (0..width): for each column (0..4) |
| 3 | Read palette index from `$A000`; lookup `$2000,Y` tile data |
| 4 | Write 4 bitplanes to `$B000,X` (offset `$00`, `$80` per plane) |
| 5 | Byte-mode DMA `$7E:B000` → VRAM `$0000` |

**Source:**

```836:968:../../../extracted/system/engine/scene_script.asm
RenderPaletteTiles {
    PHY
    PHB
    LDA #$7E
    PHA
    PLB
    ...
    RTL
}
```

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
| `chunk_03BAE1.asm` | Post-scene-load caller |
| `BuildAttributeTable` | Related attribute mapping |
| `SceneCmd_ConfigDisplay` | Sets Mode 7 flag `$06EF` bit `$08` |

### SceneCmd_ConfigDisplay


Command `$02` configures the SNES PPU for a scene by reading a 1-byte index into `table_018000` — a preset table of display register values. Writes to `$212C`–`$212F` (TM/TS/TMW/TSW), `$2130`–`$2131` (CGWSEL/CGADSUB), `$2105`–`$2108` (BG mode and screen sizes), and stores derived flags to `$06EE` (display flags) and `$06EF` (system flags). Extracts BG priority bits into `$06A2`/`$06A4` and `$06EC` (BG scroll base). Detects BG2 enable (bit in `$06EF`), Mode 7 palette path (bit `$08`), and interleaved tile flag (bit `$0800` in `$06EE`). Clears tile cache invalidation flags `$0679`/`$067C` when scroll bases change.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Read preset index; compute offset into `table_018000` |
| 2 | Write TM/TS/TMW/TSW, CGWSEL/CGADSUB from table |
| 3 | Parse flag byte: priority bits, scroll bases, interleave |
| 4 | Write BGMODE, BG1SC, BG2SC from table bytes 5–7 |
| 5 | Store `$06EE`, `$06EF`; update `$09ED` bit `$40` for BG3 |

**Source:**

```970:1097:../../../extracted/system/engine/scene_script.asm
SceneCmd_ConfigDisplay {
    JSR $&ReadScriptByte
    PHY
    REP #$20
    ...
    RTS
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$06EE` | Out | Display flags (interleave = bit `$0800`) |
| `$06EF` | Out | System flags (BG2 = bit `$01`, M7 = bit `$08`) |
| `$06A2`/`$06A4` | Out | BG priority OR masks |
| `$212C`–`$2131` | Out | PPU layer registers |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `table_018000.asm` | Display preset data |
| `CheckInterleavedFlag` | Reads `$06EE` bit `$0800` |
| `ReloadMapData` | Gated on `$06EF` bit `$01` |

### SceneCmd_Skip3

Command `$0E` is a placeholder NOP that advances the script index by 3 bytes. Used in scripts to reserve operand space for future commands or alignment padding without performing any graphics or display work.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `INY` × 3 |
| 2 | Return |

**Source:**

```1110:1115:../../../extracted/system/engine/scene_script.asm
SceneCmd_Skip3 {
    INY 
    INY 
    INY 
    RTS 
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `Y` | Out | Advanced by 3 |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `scene_script_jump_table` | Entry `$0E` |
| `FindCurrentScene` | Must skip 3 operand bytes when scanning |

### SceneCmd_LoadSpriteTiles


Command `$10` loads sprite tile graphics to OBJ VRAM. Reads a 2-byte size word directly from the script stream (not via `ReadScriptByte`), advances `Y` by 3 for the source pointer, loads the pointer via `LoadScriptPointer`, and cache-checks against slot `$0684`. On cache miss: if compressed (size ≠ 0), decompresses to `$7E:4000`; if uncompressed (size = 0), DMAs raw data from source to `$7E:4000` via `DmaRomToWram`. The decompression destination `$7A = $4000` indicates OBJ tile VRAM staging in WRAM before upload.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Read 2-byte size from script; skip to source pointer |
| 2 | `LoadScriptPointer`; cache-check `$0684` |
| 3 | On miss: decompress or raw DMA to `$7E:4000` |
| 4 | Return |

**Source:**

```1107:1147:../../../extracted/system/engine/scene_script.asm
SceneCmd_LoadSpriteTiles {
    PHP
    REP #$20
    LDA [$3A], Y
    STA $0666
    ...
    RTS
}
```

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


Command `$17` loads character-specific tile data to BG VRAM. Reads a mode byte to `$066A` and a 3-byte source pointer. Reads inline width/height, computes tile data size via `SignedMultiply`, and optionally decompresses to `$7E:7000`. Supports three VRAM targets based on mode: negative mode (bit 7 set) uses computed address; bit 0 → BG1 at VRAM `$1000`; bit 1 → BG2 at VRAM `$1800`; both bits can load sequentially via the `code_028CB0` continuation. DMA uses word mode to upload `$0666` bytes from the source buffer.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Read mode, source pointer, inline dimensions |
| 2 | `SignedMultiply` → size in `$0666` |
| 3 | Decompress if needed |
| 4 | If mode bit 7: compute VRAM addr from `$066A` |
| 5 | Else if bit 0: VRAM `$1000`; if bit 1: VRAM `$1800` |
| 6 | Word-mode DMA `$0666` bytes to VRAM |

**Source:**

```1149:1247:../../../extracted/system/engine/scene_script.asm
SceneCmd_LoadCharTiles {
    PHP
    JSR $&ReadScriptByte
    STA $066A
    ...
    RTS
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$066A` | In | Mode: bit 7=computed, 0=BG1, 1=BG2 |
| `$0666` | Out | Tile data byte count |
| `$2116` | Out | VRAM destination |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SignedMultiply` | Size computation |
| `QuintetLzDecompress` | Compressed tile data |
| `SceneCmd_LoadBgTiles` | Related BG tile loading |

#### Parsing Helpers

### ReadScriptByte

Reads the next byte from the script stream at `[$3A],Y` and advances `Y` by one. Used by the interpreter loop and by command handlers that consume single-byte operands. Returns the byte in A with the high byte cleared via `XBA`.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `LDA [$3A],Y` |
| 2 | `INY` |
| 3 | Return byte in A |

**Source:**

```1260:1269:../../../extracted/system/engine/scene_script.asm
ReadScriptByte {
    PHP 
    SEP #$20
    LDA #$00
    XBA 
    LDA [$3A], Y
    INY 
    PLP 
    RTS 
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$3A`/`Y` | In/Out | Script stream pointer and index |
| A | Out | Next script byte |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SceneScriptMain` | Called each loop iteration |
| All `SceneCmd_*` handlers | Operand reads |
| `SpcMusicLoadCmd` | Track ID and cache key reads |

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

**Source:**

```1260:1321:../../../extracted/system/engine/scene_script.asm
FindCurrentScene {
    LDY #$0000

  loc_028CF5:
    LDA [$3A], Y
    INY
    INY
    CMP $0644
    BNE loc_028CFF
    RTS
    ...
}
```

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
| `SceneCmd_ConditionalLoad` | `$13` handled in skip path |

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

**Source:**

```1323:1393:../../../extracted/system/engine/scene_script.asm
SkipScriptCommands {
    JSR $&ReadScriptByte
    PHA
    LDY #$0000
    ...
    RTS
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$3A`/`Y` | In/Out | Script stream |
| Stack | In | Remaining skip count |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SceneCmd_ConditionalLoad` | Jumps here on flag clear |
| `scene_script_jump_table` | Entry `$15` |
| `FindCurrentScene` | Parallel skip logic |

### LoadScriptPointer


Reads a 3-byte pointer (2-byte address + 1-byte bank) from the script stream at `[$3A],Y` and stores it at `(X)` (address at offset 0, bank at offset 2). Also copies the pointer to the global `$3E`/`$40` workspace used by all subsequent load operations. Applies bank fixup for the `$70`–`$9F` mirror range: if bank byte < `$A0` after adding `$80`, strips the high bit of the address high byte. This normalizes pointers in the expanded ROM mirror map.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Read 2-byte address → `(X)`; read bank byte → `(X+2)` |
| 2 | Copy to `$3E`/`$40` |
| 3 | If bank < `$70`: add `$80` to bank |
| 4 | If bank < `$A0`: clear address bit 15 |
| 5 | Return |

**Source:**

```1395:1426:../../../extracted/system/engine/scene_script.asm
LoadScriptPointer {
    PHP
    REP #$20
    LDA [$3A], Y
    INY
    INY
    STA $0000, X
    ...
    RTS
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `X` | In | Destination offset for stored pointer |
| `$3E`/`$40` | Out | Global source pointer workspace |
| `Y` | Out | Advanced by 3 |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| All graphics commands | Load source pointers |
| `CheckSourceCacheHit` | Compares `$3E`/`$40` against cache |
| `SpcMusicLoadCmd` | Music data pointer |

### CheckSourceCacheHit


Compares the current source pointer at `$3E`/`$40` against a cached `(addr, bank)` pair at `(X)`. Returns **carry clear** if they match (source unchanged — caller should skip reload). Returns **carry set** if they differ, and updates the cache slot with the new pointer values. This is Tier 1 of the cache-and-diff pattern, preventing redundant decompression and DMA when the same ROM data is referenced across scene transitions.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Compare `$3E` to `(X)` — if unequal, goto update |
| 2 | Compare `$40` to `(X+2)` — if equal, return CLC |
| 3 | Update: store `$3E`/`$40` to `(X)`/`(X+2)` |
| 4 | Return SEC |

**Source:**

```1428:1453:../../../extracted/system/engine/scene_script.asm
CheckSourceCacheHit {
    PHP
    REP #$20
    LDA $3E
    CMP $0000, X
    BNE loc_028DD9
    ...
    SEC
    RTS
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$3E`/`$40` | In | Current source pointer |
| `(X)` | In/Out | Cache slot (addr + bank) |
| Carry | Out | Clear=hit, Set=miss |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SceneCmd_LoadDualTilemap` | Per-layer cache |
| `SceneCmd_FullGraphics` | Full-graphics cache |
| `SpcMusicLoadCmd` | Music cache at `$0687` |
| `SceneCmd_LoadSpriteTiles` | Sprite cache at `$0684` |

#### DMA & Cache

### DmaRomToWram


Transfers data from ROM (or any source at `$3E`/`$40`) to a WRAM destination at `$42`/`$44`. If the source bank is ≥ `$80` and the address is ≥ `$8000`, uses HDMA channel 0 to transfer to `$2181` (WRAM bus). Otherwise falls back to the `$0402` MVN block-copy routine for low-memory sources. Transfer size is `$0666 - $0664`; source offset is `$3E + $0664`; destination is `$42 + $0668`. Handles bank `$7F` WRAM destination with proper `$2183` data bank setup.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | If source bank < `$80` or addr < `$8000`: MVN via `$0402` |
| 2 | Else: configure DMA channel 0 to WRAM |
| 3 | Size = `$0666 - $0664`; source = `$3E + $0664` |
| 4 | Trigger `$420B` |

**Source:**

```1455:1526:../../../extracted/system/engine/scene_script.asm
DmaRomToWram {
    PHP
    PHY
    SEP #$20
    LDA $3E
    CMP #$80
    BCC loc_028E43
    ...
    RTS
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0664`/`$0666`/`$0668` | In | Source range and dest offset |
| `$3E`/`$40` | In | Source pointer |
| `$42`/`$44` | In | Destination pointer |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SceneCmd_LoadTilemap` | Tilemap to `$7F:0A00` |
| `SceneCmd_LoadDualTilemap` | Layer copy |
| `WriteMapBounds` | First map row |

### GraphicsCacheLookup


Scans 4 cached source pointer slots at `$0084`–`$008F` (each 3 bytes: addr + bank) for a match against the current `$3E`/`$40`. Returns **carry set** on hit (matching slot found), **carry clear** on miss. This is Tier 2 of the cache system — after Tier 1 confirms the source pointer changed, this check determines whether the VRAM content was previously saved to the ring buffer.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `X = 0` |
| 2 | Compare `$3E` to `$0084,X` — if match, check bank |
| 3 | If bank matches: return SEC (hit) |
| 4 | `X += 3`; if `X < 12`: goto step 2 |
| 5 | Return CLC (miss) |

**Source:**

```1528:1557:../../../extracted/system/engine/scene_script.asm
GraphicsCacheLookup {
    LDX #$0000

  loc_028E72:
    LDA $3E
    CMP $0084, X
    BEQ loc_028E83
    ...
    SEC
    RTS
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0084`–`$008F` | In | 4-slot source cache |
| `$3E`/`$40` | In | Current source |
| Carry | Out | Set=hit, Clear=miss |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SceneCmd_LoadBgTiles` | Mode 0 strip cache |
| `RestoreCachedVram` | Called on hit |
| `GraphicsCacheStore` | Called on miss |

### GraphicsCacheStore


Writes the current source pointer `$3E`/`$40` into the round-robin graphics cache at `$0084`–`$008F`. Uses `$0094` as the write index (0–3), incrementing with wrap. Computes the cache slot offset as `index × 3` bytes from `$0084`. Called after a cache miss when new tile data has been decompressed and uploaded, recording the source for future Tier 2 lookups.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Read index from `$0094`; increment with `AND #$0003` |
| 2 | Compute offset: `index × 3 + $0084` |
| 3 | Store `$3E` → cache addr; `$40` → cache addr+2 |
| 4 | Return |

**Source:**

```1559:1579:../../../extracted/system/engine/scene_script.asm
GraphicsCacheStore {
    LDX $0094
    TXA
    INC
    AND #$0003
    STA $0094
    ...
    RTS
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0094` | In/Out | Round-robin write index |
| `$0084`–`$008F` | Out | Cache slots |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `GraphicsCacheLookup` | Reader counterpart |
| `SaveVramToRingBuffer` | Follows store on miss path |
| `system_init.cache_slot_indices` | Maps index to ring buffer |

### SaveVramToRingBuffer


Reads VRAM content back into the ring buffer at `$7F:4000+` via `DmaVramToRam`, preserving uploaded tile data for future cache hits. If the transfer size exceeds `$2000` bytes, splits into two DMA operations at the VRAM `$2000` boundary, advancing the ring-buffer slot index for the second half. Marks the next slot with `$FFFF`/`$FF` in the source cache to indicate a split span. Updates `$0094` for the second slot assignment.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Set VRAM addr from `$0668`; compute size |
| 2 | If size > `$2000`: first DMA `$2000` bytes; advance slot |
| 3 | `DmaVramToRam` to ring buffer via `ComputeRingBufferAddr` |
| 4 | If remainder: second DMA from VRAM `$0668 + $1000` |

**Source:**

```1581:1636:../../../extracted/system/engine/scene_script.asm
SaveVramToRingBuffer {
    PHY
    LDA $0668
    ...
    RTS
}
```

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


Performs a VRAM-to-RAM DMA read-back using HDMA channel 0. Transfer size in `A` (set to `$4305`). Destination address computed by `ComputeRingBufferAddr`. Source is VRAM via `$2139` (VRAM read port). Fixed destination bank `$7F` via `$4304`. Uses `$4300 = $81` (reverse direction: VRAM→CPU) and `$4301 = $39` for the VRAM source increment mode.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Store size to `$4305` |
| 2 | `ComputeRingBufferAddr` → destination |
| 3 | Read `$2139` for VRAM data port setup |
| 4 | Configure reverse DMA; trigger `$420B` |

**Source:**

```1638:1658:../../../extracted/system/engine/scene_script.asm
DmaVramToRam {
    PHP
    STA $4305
    JSR $&ComputeRingBufferAddr
    TAY
    LDA $2139
    ...
    RTS
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `A` | In | Transfer size |
| `$4302`/`$4304` | Out | Dest addr/bank |
| `$2139` | In | VRAM read port |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SaveVramToRingBuffer` | Primary caller |
| `ComputeRingBufferAddr` | Destination computation |

### ComputeRingBufferAddr

Computes the WRAM ring-buffer address for the current cache slot index in `$0094`. Decrements the index, rotates it into the high bits, masks to the slot region, and adds base `$4000` in bank `$7F`. Called by `DmaVramToRam` and `RestoreCachedVram` to locate saved VRAM snapshots.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Load index from `$0094`; decrement |
| 2 | Rotate into bits 13–14; mask with `$6000` |
| 3 | Add `$4000`; return address in A |

**Source:**

```1671:1682:../../../extracted/system/engine/scene_script.asm
ComputeRingBufferAddr {
    LDA $0094
    DEC 
    ROR 
    ROR 
    ROR 
    ROR 
    AND #$6000
    CLC 
    ADC #$4000
    RTS 
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$0094` | In | Ring-buffer slot index |
| A | Out | WRAM offset in bank `$7F` |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `DmaVramToRam` | DMA destination computation |
| `RestoreCachedVram` | Cache replay lookup |
| `SaveVramToRingBuffer` | Paired store path |

### RestoreCachedVram


Restores previously saved VRAM tile data from the ring buffer back to VRAM. Looks up the ring-buffer slot via `system_init.cache_slot_indices` indexed by the cache lookup result in `X`. If the span is ≤ `$2000` bytes, performs a single `DmaWramToVram`. For larger spans, splits at the `$2000` boundary across two ring-buffer slots.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Look up slot index from `cache_slot_indices[X]` |
| 2 | Compute ring buffer address |
| 3 | If size ≤ `$2000`: single `DmaWramToVram` |
| 4 | Else: DMA first `$2000`; advance slot; DMA remainder |

**Source:**

```1673:1723:../../../extracted/system/engine/scene_script.asm
RestoreCachedVram {
    PHY
    LDA $@system_init.cache_slot_indices, X
    ...
    RTS
}
```

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

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Write `$0668` → `$2116` |
| 2 | Source `$4302 = X`; size `$4305 = Y`; bank `$4304 = $7F` |
| 3 | Word mode; trigger `$420B` |

**Source:**

```1725:1742:../../../extracted/system/engine/scene_script.asm
DmaWramToVram {
    LDA $0668
    XBA
    STA $2116
    STX $4302
    STY $4305
    ...
    RTS
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `X` | In | WRAM source offset |
| `Y` | In | Transfer size |
| `$0668` | In | VRAM destination |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `RestoreCachedVram` | Primary caller |
| `DmaWordToVram` | Equivalent for non-$7F sources |

### RebuildTilemapAttrs


Rebuilds tilemap attribute bytes for a 4×N tile region. For each group of 4 tile words, reads the priority bit (bit 1) from each, combines into a 4-bit attribute nibble, and writes to the attribute buffer at `[$42]`. Also ORs priority mask bits from `$06A2,X` / `$06A4,X` into each tile word. The `X` register selects the layer (0 or 2), indexing into parallel priority arrays and source pointer arrays at `$06AA,X` / `$06AE,X`.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Load source pointer from `$06AE,X`; attr dest from `$06AA,X` |
| 2 | For each row (4 iterations): process 4 tile words |
| 3 | OR priority mask; extract bit 1 from each → nibble |
| 4 | Write attribute byte; advance pointers |

**Source:**

```1744:1797:../../../extracted/system/engine/scene_script.asm
RebuildTilemapAttrs {
    PHP
    SEP #$20
    PHB
    ...
    RTS
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$06A2,X`/`$06A4,X` | In | Priority OR masks |
| `$06AA,X`/`$06AE,X` | In | Attr dest / tile source |
| `$42` | Out | Attribute write pointer |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SceneCmd_LoadDualTilemap` | Called per loaded layer |
| `SceneCmd_ConfigDisplay` | Sets priority masks |
| `BuildAttributeTable` | Related attribute logic |

### ReloadMapData


Refreshes both map layers from their cached source pointers after scene script execution completes. Calls `ReloadMapLayer0` with index 0, then conditionally calls `ReloadMapLayer1` with index 2 if `$06EF` bit `$01` indicates BG2 is active. Invoked by `SceneScriptMain` when the scene ends (byte `$00`) and `scene_current ≠ $F7`. Used when returning to a previously loaded room where the tilemap data must be refreshed from WRAM-cached pointers.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `ReloadMapLayer0` (index 0) |
| 2 | If `$06EF` bit `$01`: `ReloadMapLayer1` (index 2) |
| 3 | Return |

**Source:**

```1799:1810:../../../extracted/system/engine/scene_script.asm
ReloadMapData {
    LDX #$0000
    JSR $&ReloadMapLayer0
    LDA $06EF
    BIT #$01
    BEQ loc_029033
    LDX #$0002
    JSR $&ReloadMapLayer1

  loc_029033:
    RTS
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$06EF` | In | Bit `$01` = BG2 active |
| `$06AA`/`$06AC` | In | Cached map source pointers |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SceneScriptMain` | Post-scene caller |
| `ReloadMapLayer0` | Layer 0 refresh |
| `ReloadMapLayer1` | Layer 1 refresh |

### ReloadMapLayer0


Reloads layer 0 map strip from the cached source pointer at `$06AA` into `$7F:2000`. Computes the number of map rows from `$0693` (width) × `$0697` (height) via `SignedMultiply`. For each row, reads a pointer from `$7E:0000,X` and dereferences it to copy map data to `$7F:2000,X`.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Set source from `$06AA` → `$3E` (bank `$7F`) |
| 2 | Row count = width × height |
| 3 | For each row: read ptr from `$7E:0000,X`; copy word to `$7F:2000,X` |
| 4 | Return |

**Source:**

```1812:1837:../../../extracted/system/engine/scene_script.asm
ReloadMapLayer0 {
    LDY $06AA
    STY $3E
    LDA #$7F
    STA $40
    ...
    RTS
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$06AA` | In | Map row pointer table |
| `$0693`/`$0697` | In | Map width/height |
| `$7F:2000` | Out | Layer 0 tilemap buffer |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `ReloadMapData` | Caller |
| `SignedMultiply` | Row count |
| `SceneCmd_FullGraphics` | Populates bounds |

### ReloadMapLayer1


Reloads layer 1 map strip from the cached source pointer at `$06AC` into `$7F:0000`. Similar to `ReloadMapLayer0` but uses `$0695`/`$0699` for dimensions and skips zero-valued tiles (overlay transparency). Starts indexing at `$0080` in the source pointer table.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Set source from `$06AC` → `$3E` (bank `$7F`) |
| 2 | Row count = width × height |
| 3 | For each row: read ptr; if non-zero, copy to `$7F:0000,X` |
| 4 | Return |

**Source:**

```1839:1867:../../../extracted/system/engine/scene_script.asm
ReloadMapLayer1 {
    LDY $06AC
    STY $3E
    LDA #$7F
    STA $40
    ...
    RTS
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$06AC` | In | Layer 1 pointer table |
| `$0695`/`$0699` | In | Layer 1 width/height |
| `$7F:0000` | Out | Layer 1 tilemap buffer |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `ReloadMapData` | Caller (if BG2 active) |
| `ReloadMapLayer0` | Parallel layer 0 reload |
| `SceneCmd_LoadDualTilemap` | Populates layer 1 data |

## spc_transfer.asm

| Address | Name | Size | Description |
|---------|------|------|-------------|
| `$028B6D` | SpcMusicLoadCmd | 119 B | Command `$11` handler — the music load orchestrator. |
| `$02908E` | SpcLoadBuiltinEngine | 13 B | Loads the embedded SPC700 sound engine binary (`spc_sound_engine`) to APU RAM at cold start. |
| `$02909B` | SpcBlockTransfer | 256 B | Full SPC700 multi-block upload routine. |
| `$02919B` | SpcIplHandshake | 117 B | Initial IPL (Initial Program Load) upload — the first-stage SPC700 bootstrap transfer. |
| `$029210` | spc_sound_engine | 3,026 B | Embedded SPC700 sound engine binary uploaded to APU RAM at startup via `SpcLoadBuiltinEngine`. |

### SPC Transfer Protocol

Communication uses APU I/O ports `$2140`–`$2143`:

1. **IPL handshake** (`SpcIplHandshake`) — CPU waits for `$BBAA` on `$2140`, sends `$CC`, then streams IPL bootstrap bytes with alternating acknowledge bytes.
2. **Multi-block upload** (`SpcBlockTransfer`) — After IPL, sends `$FF`/`$CC` start sequence, waits for `$BBAA`, then for each block: read 4-byte header (size + destination), stream data through `$2140` with `$C5`-based acknowledge protocol, send block-end marker.
3. **Timing** — `EnableNmiOnly` during upload prevents auto-joypad reads from interfering. Re-enables auto-joypad when `$0654 = $0F`.
4. **Music fade** — `SpcMusicLoadCmd` sends `$F2` (fade) then `$F0` (stop) if music is playing, waits `$1A` frames, then uploads new track data.


### SpcLoadBuiltinEngine

Loads the embedded SPC700 sound engine binary (`spc_sound_engine`) to APU RAM at cold start. Sets the transfer source pointer at `$46`/`$48` to the embedded binary address and invokes `SpcIplHandshake` to bootstrap the APU. Called once from `system_core.asm` during initialization before any scene music loads.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `$46` ← address of `spc_sound_engine` |
| 2 | `$48` ← bank of `spc_sound_engine` |
| 3 | `JSR SpcIplHandshake` |
| 4 | Return |

**Source:**

```75:82:../../../extracted/system/engine/spc_transfer.asm
SpcLoadBuiltinEngine {
    LDX #$&spc_sound_engine
    STX $46
    LDA #$^spc_sound_engine
    STA $48
    JSR $&SpcIplHandshake
    RTL 
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$46`/`$48` | Out | IPL transfer source pointer |
| `spc_sound_engine` | In | Embedded 3,026-byte APU driver |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `system_core.asm` | Cold-start caller |
| `SpcIplHandshake` | Bootstrap upload |
| `spc_sound_engine` | Binary payload |

### SpcMusicLoadCmd


Command `$11` handler — the music load orchestrator. Reads track ID to `$06F2`, cache key to `$06F4`, and a 3-byte source pointer via `LoadScriptPointer`. Fast-path: if cache key matches `$06F6`, returns immediately without touching the APU. On cache miss (`CheckSourceCacheHit` at slot `$0687`): waits `$1A` frames, fades/stops current music via `$2140` (`$F2` fade, `$F0` stop), waits for APU acknowledge, resets APU with `$FF` on `$2140`, uploads new data via `SpcBlockTransfer`, sets `$0D72` (music active flag), waits 3 frames, then sends play command (`$01`) or stop (`$00`) based on track ID.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Read track ID, cache key, source pointer |
| 2 | If cache key = `$06F6`: return (fast skip) |
| 3 | Cache-check `$0687`; return if unchanged |
| 4 | Fade/stop current music; wait for APU idle |
| 5 | Reset APU; `SpcBlockTransfer` from `$46`/`$48` |
| 6 | Send play/stop command on `$2140` |

**Source:**

```12:69:../../../extracted/system/engine/spc_transfer.asm
SpcMusicLoadCmd {
    JSR $&scene_script.ReadScriptByte
    STA $06F2
    JSR $&scene_script.ReadScriptByte
    STA $06F4
    ...
    RTS
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$06F2` | Out | Track ID (`$00` = stop) |
| `$06F4` | Out | Cache key |
| `$06F6` | In | Previous cache key for fast skip |
| `$0687` | Out | Music source cache slot |
| `$0D72` | Out | Music active flag |
| `$46`/`$48` | Out | Transfer source pointer |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `scene_script_jump_table` | Entry `$11` |
| `SpcBlockTransfer` | Data upload |
| `SceneScriptNoMusic` | Bypasses this handler |
| `MusicTransitions.patch.asm` | External caller of `SpcBlockTransfer` |

### SpcBlockTransfer


Full SPC700 multi-block upload routine. Performs IPL handshake first, then enters the main transfer loop. Sends `$FF`/`$CC` start sequence on `$2140`, waits for `$BBAA` acknowledge, then for each data block reads a 4-byte header (2-byte size + 2-byte destination address) and streams bytes through `$2140`. Handles bank-crossing in the source data via `$4A`/`$4C` pointer arithmetic. Each byte is sent with an acknowledge wait loop. Block end is signaled via `$2140`/`$2141`/`$2142` with address and transfer-mode flag. `EnableNmiOnly` is called during each block transfer for timing isolation.

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | `SpcIplHandshake` |
| 2 | Send `$FF`/`$CC`; wait for `$BBAA` |
| 3 | Read 4-byte block header (size + dest addr) |
| 4 | Stream data bytes via `$2140` with ack protocol |
| 5 | Send block-end marker; repeat from step 3 |
| 6 | Exit when size = 0 |

**Source:**

```82:247:../../../extracted/system/engine/spc_transfer.asm
SpcBlockTransfer {
    PHP
    PHY
    JSR $&SpcIplHandshake
    ...
    RTL
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$46`/`$48` | In | Source data pointer |
| `$2E`/`$28` | Out | Block size / dest address |
| `$2140`–`$2142` | Out | APU I/O ports |
| `$0654` | In | Boot state (`$0F` = re-enable joypad) |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SpcMusicLoadCmd` | Music data upload |
| `SpcIplHandshake` | Initial handshake |
| `EnableNmiOnly` | Timing isolation |
| `MusicTransitions.patch.asm` | External caller |

### SpcIplHandshake


Initial IPL (Initial Program Load) upload — the first-stage SPC700 bootstrap transfer. Waits for the `$BBAA` signature on `$2140` (indicating the SPC is ready), sends `$CC` to begin, then streams bootstrap bytes from `[$46],Y` one at a time with alternating acknowledge values on `$2140`. After the bootstrap stream, reads the first block header (size + destination) and sends it via `$2141`/`$2142`. Calls `EnableNmiOnly` during the transfer. Returns when the bootstrap phase completes (signaled by the overflow flag from the `$7F`/`$80` address check in the source stream).

**Algorithm:**

| Step | Action |
|------|--------|
| 1 | Wait for `$BBAA` on `$2140` |
| 2 | Send `$CC` to start bootstrap |
| 3 | Stream bytes from source with ack on `$2140` |
| 4 | Read block header; send addr to `$2141`/`$2142` |
| 5 | `EnableNmiOnly`; wait for completion |
| 6 | Return (or loop if more bootstrap data) |

**Source:**

```250:330:../../../extracted/system/engine/spc_transfer.asm
SpcIplHandshake {
    PHP
    REP #$20
    LDY #$0000
    LDA #$BBAA

  loc_0291A4:
    CMP $APUIO0
    ...
    RTS
}
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$46`/`$48` | In | Bootstrap source pointer |
| `$2140` | In/Out | Handshake port |
| `$2141`/`$2142` | Out | Block address ports |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SpcBlockTransfer` | Called at start of full transfer |
| `SpcLoadBuiltinEngine` | Boot-time caller |
| `EnableNmiOnly` | Timing control |

### spc_sound_engine


Embedded SPC700 sound engine binary uploaded to APU RAM at startup via `SpcLoadBuiltinEngine`. This is the resident music driver that runs on the SPC700 co-processor — it receives commands and data through the `$2140`–`$2143` I/O ports and manages BGM playback, sound effects, and fade transitions. The binary is stored as a single hex-encoded line in the ASM source. It occupies 3,026 bytes of ROM and is the largest single part in the combined scene/SPC block.

**Algorithm:**

N/A — embedded binary data, not executable 65816 code.

**Source:**

Binary blob at `$029210` (3,026 bytes). First bytes: `$CA $0B $00 $04 $20 $CD $CF $BD ...`

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| APU RAM | Out | Upload destination (via IPL) |
| `$2140`–`$2143` | In | Runtime command interface |

**Cross-References:**

| Symbol | Relationship |
|--------|--------------|
| `SpcLoadBuiltinEngine` | Uploads this binary at boot |
| `SpcMusicLoadCmd` | Sends music data to running engine |
| `SpcIplHandshake` | Bootstrap transfer mechanism |

## Global Cross-References

### Callers

| Function | Caller | Context |
|----------|--------|---------|
| `SceneScriptMain` | `chunk_03BAE1.asm` | Primary scene load after VRAM clear |
| `SceneScriptNoMusic` | `inventory_overlay.asm` | Inventory overlay (preserves BGM) |
| `RenderPaletteTiles` | `chunk_03BAE1.asm` | Mode 7 palette upload after scene load |
| `SpcLoadBuiltinEngine` | `system_core.asm` | Cold-start APU initialization |
| `SpcBlockTransfer` | `SpcMusicLoadCmd`, `MusicTransitions.patch.asm` | Music upload |
| `DmaWordToVram` | Internal scene_script callers | Shared VRAM DMA primitive |

### Dependencies

| Dependency | Role |
|------------|------|
| [`decompress.asm`](../../../extracted/system/engine/decompress.asm) | `QuintetLzDecompress` — compressed payloads |
| [`hardware_math.asm`](../../../extracted/system/engine/hardware_math.asm) | `SignedMultiply` — map dimension math |
| [`vblank_joypad.asm`](../../../extracted/system/engine/vblank_joypad.asm) | `WaitFrames`, `EnableNmiOnly`, `EnableNmiAndJoypad` |
| [`cop_handlers_script.asm`](../../../extracted/system/engine/cop_handlers_script.asm) | `TestFlagRaw` — conditional load `$13` |
| [`table_018000.asm`](../../../extracted/tables/table_018000.asm) | Display presets for command `$02` |
| [`system_init.asm`](../../../extracted/system/engine/system_init.asm) | `cache_slot_indices` — ring-buffer mapping |

### Related Documentation

- [hardware-and-init.md](hardware-and-init.md) — Hardware math, VBlank, decompression, system init
- [bank2-code-analysis.md](../bank2-code-analysis.md) — Full bank `$02` overview
- [bank00/system-core.md](../bank00/system-core.md) — Main game loop triggering scene loads

---
