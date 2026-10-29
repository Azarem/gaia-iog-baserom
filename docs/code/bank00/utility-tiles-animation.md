# Bank $00 — Tile/Map Helpers, Animation & Sprite Utilities

**Address range:** `$0097EF`–`$00AF8F` (helpers in metatile, sprite, effects, collision, and actor_pool units)  
**Related:** [`cop-dispatch.md`](cop-dispatch.md) (COP `$4B`–`$4E`, `$0D`/`$0E`, `$00`, `$60`, `$80`–`92`)

Shared infrastructure for **layer-0 metatile paint**, **VRAM staging**, **animation index / mirror handling**, **sine HDMA tables**, and **collision offset parsing**. Invoked from COP handlers, not used as standalone game entry points.

## Source of truth

| Area | Extracted file |
|------|----------------|
| Map stream parse, resolve, VRAM gate | `extracted/system/engine/cop_handlers_metatile.asm` |
| Animation flag, staging COPs | `extracted/system/engine/cop_handlers_sprite.asm` |
| Sine HDMA build | `extracted/system/engine/cop_handlers_effects.asm` |
| Body table, move chains | `extracted/system/engine/actor_pool.asm` |
| Signed tile offset for mark/clear | `extracted/system/engine/cop_handlers_collision.asm` |
| Map index / VRAM address | `extracted/system/engine/map_coords.asm` |

**Naming:** `tileQueryResult` is the extracted label for **`$0902`** (VRAM staging flag). **`animScratch` (`$7F0000`)** is the metatile **collision-type table base** in metatile code comments. **`characterForm`** is the extracted name for the player body index (not `$0AD4`).

**Counts:** Metatile COP script site counts are in the `cop_handlers_metatile.asm` block note (e.g. DrawMetatileAbs “24 sites”); sprite COP site counts appear in per-handler comments in `cop_handlers_sprite.asm`.

---

## Tile / map parsing and paint

Layer-0 runtime tile changes: update **`mapLayerTilemap` (`$7EA000`)**, **`collisionLayer` (`$7FC000`)**, and optionally queue a **2×2** BG1 nametable DMA via **`$0902`–`$090C`**. Collision **type bytes** written here come from **`$7F0000 + metatile ID`** (layer-0 table; **`$7F0100`** layer-1 table is unused in these handlers). That is **source data**, separate from **`MarkCollisionRect`** OR **`$F0`** occupancy (see [`direction-collision.md`](direction-collision.md)).

### ParseMapEntry

**Address:** `$97EF` · **Size:** 58 bytes · **Status:** **live** (stream COPs `$4D`/`$4E`, no script sites in current extract)

Decodes a **3-byte** record at stream offset **X** (absolute addressing after caller sets DBR):

| Offset | Field | Meaning |
|--------|-------|---------|
| +0 | Tile X | Bit **7 set** ⇒ end of stream (**SEC**, carry set) |
| +1 | Tile Y | Tile row |
| +2 | ID | Metatile ID → page-0 **`$00`** |

On success: **zero-extends** X/Y into **`$18`/`$1C`**, pixel **`$1A`/`$1E` = tile × 16**, **CLC**. Sets **`TCD #$0000`** itself.

### ResolveTileData

**Address:** `$9829` · **Size:** 128 bytes · **Status:** **live**

1. **`JSL TileCoordsToMapIndex`** (layer 0) → index in **X**.
2. **`LDA $7F0000 + ID`** (via **`animScratch,X`**) → write to **`collisionLayer,X`**; metatile ID to **`mapLayerTilemap,X`**.
3. **On-screen test** (otherwise stop after map writes):
   - Horizontal: **`(pixel X + $10 − bg1ScrollH) < $0111`**
   - Vertical: **`0 ≤ pixel Y − ((mapScrollV − $10) & $FFF0) < $F1`**
4. On-screen: load **8 bytes** from **`metatileMapLayer` (`$7E2000`) + ID×8** → **`$0904`–`$090C`**; **`JSL PixelToVramAddress`** → **`$0902`**, **`$0908 = $0902 + $20`**.

Off-screen tiles **do not** set **`$0902`** (remains zero).

### TileQueryGate

**Address:** `$98A9` · **Size:** 15 bytes · **Status:** **live**

Synchronizes with NMI flush in **`event_blocks`**: **`$0902` (`tileQueryResult`)** holds the pending VRAM word address until NMI writes the 2×2 update and **clears `$0902`**.

| `$0902` | Carry | Behavior |
|---------|-------|----------|
| **Zero** | Clear | Proceed (no pending DMA) |
| **Non-zero** | Set | Rewind script pointer **`$0A − 2`**, store in **`$00`**, abort COP frame (retry next tick) |

**All** DrawMetatile COPs call **`TileQueryGate` first**, then parse operands / stream and call **`ResolveTileData`**.

```text
  DrawMetatile* entry
        │
        ▼
  TileQueryGate ──( $0902 ≠ 0 )──► yield, retry same COP
        │ $0902 = 0
        ▼
  [ParseMapEntry] (stream only)
        ▼
  ResolveTileData ──► map + collision writes; maybe set $0902
        ▼
  (NMI clears $0902 when flushed)
```

---

## Metatile draw call flow

```text
  COP $4B/$4C (absolute / here)
    TileQueryGate → setup $18/$1C/$1A/$1E/$00 → ResolveTileData

  COP $4D/$4E (stream)
    TileQueryGate → ParseMapEntry → (delay byte on $4E) → ResolveTileData
    → rewind $0A, yield until stream sentinel (X byte bit 7)
```

---

## Animation / visibility

### ProcessAnimFlag

**Address:** `$9F5F` · **Size:** 48 bytes · **Status:** **live** (`StageSprite*` `$80`–`87`, `$8D`; movement init in `cop_handlers_movement.asm`)

| Input **A** | Effect |
|-------------|--------|
| **`$FF`** | No change to **`$28`**; still clears **`$2A`** |
| **Bit 7 set** | **`$28 = A & $7F`**; unless **`$12` bit 1** (`BIT #$0002`) set, **set H-flip** in **`$0E`** via **`TSB #$4000`** |
| **Bit 7 clear** | **`$28 = A`**; unless **`$12` bit 1** set, **clear H-flip** via **`TRB #$4000`** |

**`$12` bit 1** is a **mirror lock** (extracted comment): when set, flip bits in **`$0E`** are left unchanged.

**Not used** by **`StagePlayerSprite` (`$8F`–`92`)** — those store the operand **directly in `$28`** and call **`SetActorBody`** instead.

```text
  StageSprite* COP
        │
        ▼
  ProcessAnimFlag (A = anim byte) → $28, $0E flip, STZ $2A
        │
        ▼
  [optional AnimFrameLookup → $2C/$2E chain heads]
        │
        ▼
  AnimOnce / UpdateActorAnimation (separate COPs)
```

### AnimFrameLookup

**Address:** `$B157` · **Size:** 6 bytes · **Status:** **live**

**`A` = movement index** → **`A = move_chain_table[A×2]`** — a **pointer to the head of a movement delta chain**, not a frame duration. Callers store result in **`$2C`** (X) and/or **`$2E`** (Y).

---

## Sprite / body helpers

### BuildSineHdmaTable

**Address:** `$ADCF` · **Status:** **live** (COP `$60` `TickSineHdma`)

Per-frame HDMA displacement buffer fill using **`sine_table_8bit`**, amplitude **`$7F0008,X`**, period **`$7F000E,X`**, phase **`$7F0004,X`**, base offsets page-0 **`$18`/`$1C`**, body buffer base **`$7F0006,X`**. **`$0036` bit 0** selects ping-pong offset **`+$0200`** on the write buffers.

### BuildSineLookupTable

**Address:** `$AEB8` · **Status:** **live** (COP `$00` `GenHdmaSine` path)

Pre-multiplies sine table into **`$7E8900` / `$7E8B00`** when **`$09EC` bit 6** or **`$7F000E,X` bit 0** requests rebuild.

### SetActorBody

**Address:** `$AF6D` · **Size:** 34 bytes · **Status:** **live** (player sprite COPs)

**`characterForm × 6`** → index into **`body_table`**: writes **`spritesetPtr` (`$7F0006`)** and bank **`$7F0008`**, clears **`playerFlags` bit `$8000`**.

```text
  StagePlayerSprite* ($8F–$92, …)
        │
        ▼
  SetActorBody → body_table → $7F0006/$7F0008
        │
        ▼
  (later) BuildSineHdmaTable / sprite composition uses $7F0006+$7F0008
```

### ParseSignedTileOffset

**Address:** `$AF8F` · **Size:** 63 bytes · **Status:** **live** (COP `$0D`/`$0E`)

Reads two **signed bytes** from **`[$0A]`**, ×16, adds actor **`$14`/`$16`**, converts to tile coords in **`$0018`/`$001C`**; Y path subtracts **`$10`** before ÷16 (same grid bias as **`TileCollisionQuery`**). Mark/clear COPs then call **`TileCoordsToMapIndex`** / rectangle helpers (see direction-collision doc).

---

## Collision offset parsing (separate from metatile paint)

```text
  MarkSolidOffset / ClearSolidOffset ($0D / $0E)
        │
        ▼
  ParseSignedTileOffset → $0018/$001C (tile coords)
        │
        ▼
  (handler-specific) single-tile or rect paint on $7FC000
```

---

## See also

- [`direction-collision.md`](direction-collision.md) — `TileCollisionQuery`, mark/clear rectangles
- [`utility-math-movement.md`](utility-math-movement.md) — movement init calling `ProcessAnimFlag`
- [`../../cop/README.md`](../../cop/README.md) — COP operand reference
- [`extracted/system/engine/map_coords.asm`](../../../extracted/system/engine/map_coords.asm) — `TileCoordsToMapIndex`, `PixelToVramAddress`

## Source validation

**Files checked:** `cop_handlers_metatile.asm`, `cop_handlers_sprite.asm`, `cop_handlers_effects.asm`, `cop_handlers_collision.asm`, `actor_pool.asm`, `map_coords.asm`, `body_table.asm` block notes.

**Verified:** `ParseMapEntry` record layout and carry semantics; `ResolveTileData` table sources (`$7F0000`, `$7E2000`, `$7EA000`, `$7FC000`), viewport uses **`bg1ScrollH`** / **`mapScrollV`**; **`TileQueryGate`** carry vs **`$0902`** pending flush (gate runs **before** resolve); `ProcessAnimFlag` **`$FF`**, bit 7 mirror, **`$12` bit 1** lock; **`AnimFrameLookup`** → **`move_chain_table`** chain heads; **`SetActorBody`** uses **`characterForm`**; **`ParseSignedTileOffset`** Y **`−$10`** bias.

**Notes:** Stream COPs **`$4D`/`$4E`** have **no script sites** in the current extract. **`DrawMetatileHere`** treats actor **`$14`/`$16` as tile coords** (callers must pre-convert from pixels). Sine helper register details hedged where only block comments describe buffer layout.
