# Bank $00 — Tile/Map Helpers, Animation & Sprite Utilities

**Address range:** `$0097EF`–`$00AF8F`  
**Source files:** `extracted/system/engine/cop_handlers_collision.asm`, `extracted/system/engine/cop_handlers_actors.asm`  
**Related:** [`cop-dispatch.md`](cop-dispatch.md) (COP `$4B`–`$4E`, `$0D`/`$0E`, `$00`, `$60`, `$80`–`92`)

Utility routines supporting metatile drawing, world-map streaming, sprite staging, sine-based HDMA effects, and collision offset computation. These are shared infrastructure called from multiple COP handlers rather than standalone entry points.

---

## Tile / Map Helpers

### ParseMapEntry

| Property | Value |
|----------|-------|
| **Old name** | `sub_0097EF` |
| **New name** | `ParseMapEntry` |
| **Address** | `$0097EF` |
| **Size** | 58 bytes |
| **Type** | Map stream parser |

#### Description

Parses a 3-byte map entry from the world-map stream at index X (direct-page offset). Returns **carry set** if the entry is invalid (end-of-stream marker — high bit of byte 0 set). On success, extracts tile coordinates, sign-extends them to 16-bit, scales by 16 to produce pixel coordinates, and stores the metatile/collision type byte.

Called by COP `$4D` (WorldMapStream3) and `$4E` (WorldMapStream4) for each entry in a compressed map modification stream.

#### Algorithm

```
1. TCD → DP = $0000              ; Direct page at stream pointer
2. SEP #$20                       ; 8-bit mode for byte reads
3. LDA $0000,X                    ; Byte 0: tile X
4. BMI → loc_009827 (carry set)   ; Bit 7 = end-of-stream
5. STA $18                        ; Tile X (8-bit)
6. LDA $0001,X → STA $1C          ; Byte 1: tile Y
7. LDA $0002,X → $00 (type)       ; Byte 2: metatile/collision type
8. REP #$20                       ; 16-bit for scaling
9. Zero-extend $18, ASL×4 → $1A    ; Pixel X = tile X × 16
10. Zero-extend $1C, ASL×4 → $1E   ; Pixel Y = tile Y × 16
11. CLC; RTS                       ; Success
```

#### Record Format

| Offset | Field | Description |
|--------|-------|-------------|
| `+0` | Tile X | 0–127 valid; bit 7 set = stream terminator |
| `+1` | Tile Y | 0–255 tile row |
| `+2` | Type | Metatile ID or collision type for `$7FC000` table |

#### Variables

| Location | Direction | Role |
|----------|-----------|------|
| `X` | Input | Offset into map stream (DP-relative) |
| `$18` | Output | Tile X coordinate (16-bit) |
| `$1C` | Output | Tile Y coordinate (16-bit) |
| `$1A` | Output | Pixel X = tile X × 16 |
| `$1E` | Output | Pixel Y = tile Y × 16 |
| `$00` | Output | Type/metatile byte |
| `C` | Output | Clear = valid entry; Set = end of stream |

#### Cross-References

| Symbol | Relationship |
|--------|--------------|
| `WorldMapStream3` (COP `$4D`) | Caller |
| `WorldMapStream4` (COP `$4E`) | Caller |
| `ResolveTileData` | Called immediately after successful parse |

---

### ResolveTileData

| Property | Value |
|----------|-------|
| **Old name** | `sub_009829` |
| **New name** | `ResolveTileData` |
| **Address** | `$009829` |
| **Size** | 128 bytes |
| **Type** | Tile graphics resolver |

#### Description

Resolves tile graphics and metadata from parsed coordinates in `$18`/`$1C` (tile) and `$1A`/`$1E` (pixel). Writes collision/type data to WRAM tile tables, bounds-checks against the camera viewport, and if on-screen, looks up 8-byte tileset entries from `$7E2000` and computes VRAM destination addresses.

Called by all metatile drawing COPs ($4B–$4E) after coordinates are established. Leaves `$0902` = 0 if off-screen (which triggers `TileQueryGate` to abort and retry).

#### Algorithm

```
1. JSL TileCoordsToMapIndex (Bank $02)
   → X = WRAM map index; $00 = collision/type from $7F0000 table
2. Write collision: $7FC000,X ← type; $7EA000,X ← tile ID
3. Bounds check (camera-relative):
   a. Pixel X + $10 − $068A < $0111 (within horizontal viewport + margin)
   b. Pixel Y − (camera_Y − $10) & $FFF0 ≥ 0 and < $F1
4. If off-screen → RTS (leaves $0902 unset/zero)
5. If on-screen:
   a. Tile ID × 8 → index into $7E2000 tileset
   b. Read 8 bytes → $0904, $0906, $090A, $090C (tile data pointers)
   c. JSL PixelToVramAddress → $0902 (VRAM dest)
   d. $0902 + $0020 → $0908 (second row VRAM dest)
6. RTS
```

#### Variables

| Location | Direction | Role |
|----------|-----------|------|
| `$18` / `$1C` | Input | Tile coordinates |
| `$1A` / `$1E` | Input | Pixel coordinates |
| `$00` | Input | Type byte from parser |
| `$068A` | Read | Camera X position |
| `$068E` | Read | Camera Y position |
| `$7F0000` | Read | Source collision/type table |
| `$7EA000,X` | Write | Tile ID at map index |
| `$7FC000,X` | Write | Collision type at map index |
| `$7E2000,X` | Read | Tileset data (8 bytes per tile) |
| `$0902` | Output | VRAM destination address (0 = off-screen) |
| `$0904`–`$090C` | Output | Tile graphics data pointers |
| `$0908` | Output | Second row VRAM address |

#### Cross-References

| Symbol | Relationship |
|--------|--------------|
| `DrawMetatileAbs` (COP `$4B`) | Caller |
| `DrawMetatileHere` (COP `$4C`) | Caller |
| `WorldMapStream3` (COP `$4D`) | Caller |
| `WorldMapStream4` (COP `$4E`) | Caller |
| `TileCoordsToMapIndex` (Bank $02) | Map coord → WRAM index |
| `PixelToVramAddress` (Bank $02) | Pixel coord → VRAM address |
| `TileQueryGate` | Called after this to check `$0902` |

---

### TileQueryGate

| Property | Value |
|----------|-------|
| **Old name** | `sub_0098A9` |
| **New name** | `TileQueryGate` |
| **Address** | `$0098A9` |
| **Size** | 15 bytes |
| **Type** | Conditional retry gate |

#### Description

Gate function that checks whether a tile query succeeded. If `$0902` is non-zero (VRAM address computed — tile is on-screen and ready for DMA), rewinds `$0A` by 2 bytes and returns **carry set**, causing the calling COP to abort and retry next frame. If `$0902` is zero (off-screen or not yet ready), returns carry clear and the COP continues normally.

This implements a "try again next frame" pattern for metatile operations that depend on camera position or async tile loading.

#### Algorithm

```
1. CLC
2. LDA $0902
3. BNE → loc_0098B0    ; Non-zero = tile pending/on-screen
4. RTS                  ; Carry clear — proceed
   loc_0098B0:
5. LDA $0A; DEC; DEC → $00   ; Rewind arg pointer for retry
6. SEC; RTS                   ; Carry set — abort COP this frame
```

#### Source

```2109:2122:extracted/system/engine/cop_handlers_collision.asm
TileQueryGate {
    CLC 
    LDA $0902
    BNE loc_0098B0
    RTS 

  loc_0098B0:
    LDA $0A
    DEC 
    DEC 
    STA $00
    SEC 
    RTS 
}
```

#### Variables

| Location | Direction | Role |
|----------|-----------|------|
| `$0902` | Input | VRAM query result (0 = skip/off-screen) |
| `$0A` | R/W | Rewound by 2 on retry |
| `$00` | Write | Saved entry pointer for halt/yield |
| `C` | Output | Set = abort and retry; Clear = continue |

#### Cross-References

| Symbol | Relationship |
|--------|--------------|
| `DrawMetatileAbs` (COP `$4B`) | Caller |
| `DrawMetatileHere` (COP `$4C`) | Caller |
| `WorldMapStream3` (COP `$4D`) | Caller |
| `WorldMapStream4` (COP `$4E`) | Caller |
| `ResolveTileData` | Sets `$0902` before gate check |

---

## Animation / Visibility

### ProcessAnimFlag

| Property | Value |
|----------|-------|
| **Old name** | `sub_009F5F` |
| **New name** | `ProcessAnimFlag` |
| **Address** | `$009F5F` |
| **Size** | 48 bytes |
| **Type** | Sprite/animation flag processor |

#### Description

Processes the animation/visibility flag byte passed in A from script operands. Handles three distinct modes based on the flag value and its bit 7 (mirror-aware) encoding. Always clears `$2A` (animation wait frame counter) on entry. Modifies `$28` (sprite set index) and `$0E` (OAM XOR — H-flip flag at bit 14 / `$4000`).

Called by all sprite staging COPs ($80–$87, $8D, $8F–$92), movement initialization (`InitSmoothMovement`), and StageMove (COP `$52`).

#### Algorithm

```
1. STZ $2A                         ; Clear animation wait counter
2. CMP #$FF → RTS if equal         ; $FF = no change (preserve $28)
3. BIT #$0080 (test bit 7):
   
   Bit 7 SET (mirror-aware mode):
   4a. A AND #$FF7F → STA $28      ; Strip bit 7 for sprite index
   5a. LDA $12; BIT #$0002         ; Check actor flag bit 2 (H-flip state)
   6a. BEQ → set H-flip: TSB #$4000 on $0E
   7a. RTS (keep existing flip if bit 2 set)
   
   Bit 7 CLEAR (normal mode):
   4b. STA $28                      ; Set sprite index directly
   5b. LDA $12; BIT #$0002         ; Check actor flag bit 2
   6b. BEQ → clear H-flip: TRB #$4000 on $0E
   7b. RTS (keep existing flip if bit 2 set)
```

#### Flag Modes

| Input A | Behavior |
|---------|----------|
| `$FF` | No change — preserve current `$28`, only clear `$2A` |
| `$00`–`$7F` | Normal: sprite index = A; clear H-flip in `$0E` unless `$12` bit 2 set |
| `$80`–`FE` | Mirror-aware: sprite index = A & `$7F`; set H-flip in `$0E` unless `$12` bit 2 set |

#### Variables

| Location | Direction | Role |
|----------|-----------|------|
| `A` | Input | Animation/sprite flag byte from script |
| `$28` | R/W | Sprite set / animation index |
| `$2A` | Write | Animation wait frame (always cleared) |
| `$0E` | R/W | OAM XOR flags (bit 14 = `$4000` = H-flip) |
| `$12` | Read | Actor flags (bit 2 = existing H-flip override) |

#### Cross-References

| Symbol | Relationship |
|--------|--------------|
| `StageSpr` / `$80`–`87` | Callers — sprite staging COPs |
| `StageSprAndHitbox` (COP `$8D`) | Caller |
| `StagePlayerSpr` / `$8F`–`92` | Callers — player sprite COPs |
| `InitSmoothMovement` | Caller — movement init anim byte |
| `StageMove` (COP `$52`) | Caller |

---

### AnimFrameLookup

| Property | Value |
|----------|-------|
| **Old name** | `sub_00B157` |
| **New name** | `AnimFrameLookup` |
| **Address** | `$00B157` |
| **Size** | 6 bytes |
| **Type** | Table lookup |

#### Description

Looks up animation frame duration/speed from `table_01B086`. Doubles the input index (A << 1) to index into the 16-bit word table and returns the duration value in A. Used by sprite staging COPs to set `$2C`/`$2E` movement duration fields and by force-move COPs to reload animation timing.

#### Algorithm

```
1. ASL A              ; Index × 2 (16-bit table entries)
2. TAY
3. LDA table_01B086,Y ; Load duration word
4. RTS                ; Duration in A
```

#### Source

```2394:2399:extracted/system/engine/cop_handlers_actors.asm
AnimFrameLookup {
    ASL 
    TAY 
    LDA $&table_01B086, Y
    RTS 
}
```

#### Variables

| Location | Direction | Role |
|----------|-----------|------|
| `A` | Input/Output | Animation index in; duration out |
| `table_01B086` | Read | Duration/speed table (16-bit entries) |

#### Cross-References

| Symbol | Relationship |
|--------|--------------|
| `StageSprX/Y/XY` (COP `$81`–`83`) | Callers |
| `StageSprLoopX/Y/XY` (COP `$85`–`87`) | Callers |
| `StagePlayerSprX/Y/XY` (COP `$90`–`92`) | Callers |
| `StageMoveX/Y/XY` (COP `$AA`–`AC`) | Callers — force-move durations |
| `ApplyMoveToChild` (COP `$B0`) | Caller |
| `ReloadMoveDurations` (COP `$B1`) | Caller |

---

## Sprite / Body Helpers

### BuildSineHdmaTable

| Property | Value |
|----------|-------|
| **Old name** | `sub_00ADCF` |
| **New name** | `BuildSineHdmaTable` |
| **Address** | `$00ADCF` |
| **Size** | 233 bytes |
| **Type** | HDMA buffer builder |

#### Description

Builds HDMA displacement data from the 256-byte sine table at `binary_01C455`. Computes write buffer pointers from the actor's body data pointer (`$7F0006,X`), scales each sine sample by the amplitude via hardware multiply, and writes paired horizontal/vertical displacement values to double-buffered HDMA tables.

Double-buffering uses `$0036` bit 0 (frame parity): even frames write to base buffers, odd frames offset by `$0200` to prevent visual tearing during HDMA table updates.

Called by COP `$60` (TickSineHdma) each frame to refresh the oscillation table.

#### Algorithm

```
1. PHX; PHB                          ; Preserve context
2. Compute buffer pointers:
   - $62 ← $7F0006,X + $0100        ; Horizontal HDMA buffer
   - $5E ← $62 + $0400              ; Vertical HDMA buffer
3. If $0036 bit 0 (odd frame):
   - Add $0200 to both $62 and $5E  ; Ping-pong to alternate buffer
4. Set up multiply/divide:
   - $WRMPYA ← $7F0008,X (amplitude)
   - Bank ← $7E; DP ← $0000
   - Step size = $0100 / (period/2) via hardware divide → $00
5. Compute initial sine index:
   - Shift $7F0004,X + $1C left by (8 − period/2) → X index
6. Loop (Y = 0 .. period/2 − 1):
   a. Read sine[X] from binary_01C455
   b. STA $WRMPYB; multiply by amplitude
   c. If sine negative (bit 7):
      - Sign-extend via $FF × high_byte + low_byte
   d. Add base offset ($18 horizontal, $1C vertical)
   e. Store to ($62),Y and ($5E),Y
   f. X ← (X + step_size) & $FF; Y += 2
7. Restore bank, DP, X; RTS
```

#### Variables

| Location | Direction | Role |
|----------|-----------|------|
| `$7F0004,X` | Read | Sine phase offset |
| `$7F0006,X` | Read | Body data pointer (buffer base) |
| `$7F0008,X` | Read | Amplitude scalar |
| `$7F000E,X` | Read | Period (low byte / 2 = loop count) |
| `$0036` | Read | Frame counter (bit 0 = buffer select) |
| `$18` / `$1C` | Read | Base horizontal/vertical offsets |
| `$62` / `$5E` | Temp | HDMA write buffer pointers (DP) |
| `$00` | Temp | Sine table step size |
| `binary_01C455` | Read | 256-byte sine lookup table |
| `($62),Y` | Write | Horizontal displacement buffer |
| `($5E),Y` | Write | Vertical displacement buffer |

#### Cross-References

| Symbol | Relationship |
|--------|--------------|
| `TickSineHdma` (COP `$60`) | Caller — per-frame HDMA refresh |
| `InitSineHdma` (COP `$5F`) | Sets up initial `$7F000E,X` parameters |
| `BuildSineLookupTable` | Precomputes expanded tables at `$7E8900`/`$7E8B00` |
| `binary_01C455` | Source sine data |

---

### BuildSineLookupTable

| Property | Value |
|----------|-------|
| **Old name** | `sub_00AEB8` |
| **New name** | `BuildSineLookupTable` |
| **Address** | `$00AEB8` |
| **Size** | 136 bytes |
| **Type** | Sine table precomputer |

#### Description

Precomputes 512-byte sine lookup tables at WRAM `$7E8900` and `$7E8B00` by multiplying each entry of `binary_01C455` by the actor's amplitude (`$7F0008,X`). Triggered when `$7F000E,X` bit 0 is set (sine HDMA init flag) or when `$09EC` bit 6 is set (global sine rebuild flag).

Called by COP `$00` (GenHdmaSine) during HDMA sine effect initialization. After building, GenHdmaSine configures the HDMA channel table entries at `$7E8800` to point at the computed buffers.

#### Algorithm

```
1. PHP; PHX
2. Check trigger conditions:
   - If $09EC bit 6 → clear bit 6, proceed
   - Else if $7F000E,X bit 0 → clear bit 0, proceed
   - Else → exit (no rebuild needed)
3. SEP #$20
4. $WRMPYA ← $7F0008,X (amplitude)
5. LDX ← 0; LDY ← 0
6. Loop (512 iterations, step X by 2):
   a. LDA binary_01C455,Y → STA $WRMPYB
   b. If negative: sign-extend multiply result
   c. Else: use $RDMPYH (high byte of product)
   d. Store to $7E8900,X and $7E8B00,X
   e. Y ← (Y + period) & $FF; X += 2
7. PLX; PLP; RTS
```

#### Variables

| Location | Direction | Role |
|----------|-----------|------|
| `$7F0008,X` | Read | Amplitude (stored in `$WRMPYA`) |
| `$7F000E,X` | R/W | Bit 0 = rebuild request (cleared after build) |
| `$09EC` | R/W | Bit 6 = global rebuild flag |
| `$7E8900` | Write | 512-byte horizontal sine table |
| `$7E8B00` | Write | 512-byte vertical sine table |
| `binary_01C455` | Read | Source sine data (256 bytes, indexed with wrap) |

#### Cross-References

| Symbol | Relationship |
|--------|--------------|
| `GenHdmaSine` (COP `$00`) | Caller — initial HDMA setup |
| `BuildSineHdmaTable` | Consumer of precomputed tables |
| `InitSineHdma` (COP `$5F`) | Sets `$7F000E,X` bit 0 to trigger rebuild |

---

### SetActorBody

| Property | Value |
|----------|-------|
| **Old name** | `sub_00AF6D` |
| **New name** | `SetActorBody` |
| **Address** | `$00AF6D` |
| **Size** | 34 bytes |
| **Type** | Body/sprite pointer setter |

#### Description

Sets the actor's body/sprite data pointer from the current player body index in `$0AD4`. Computes a 6-byte table offset (`$0AD4 × 6` — three 16-bit words per body entry) into `body_table`, stores the sprite pointer to `$7F0006,X`/`$7F0008,X`, and clears `$player_flags` bit `$8000`.

Called by player sprite COPs ($8F–$92, $94, $95) whenever the player character's body form changes (Will, Freedan, Shadow).

#### Algorithm

```
1. LDA $0AD4                       ; Current body index
2. ASL; CLC; ADC $0AD4; ASL        ; × 6 (three words per entry)
3. TAY                             ; Table offset
4. LDA body_table,Y → $7F0006,X    ; Sprite data pointer (16-bit)
5. LDA body_table+2,Y → $7F0008,X  ; Amplitude/scale byte
6. LDA #$8000; TRB $player_flags   ; Clear body-change-pending flag
7. RTS
```

#### Source

```2375:2390:extracted/system/engine/cop_handlers_actors.asm
SetActorBody {
    LDA $0AD4
    ASL 
    CLC 
    ADC $0AD4
    ASL 
    TAY 
    LDA $&body_table, Y
    STA $7F0006, X
    LDA $&body_table+2, Y
    AND #$00FF
    STA $7F0008, X
    LDA #$8000
    TRB $player_flags
    RTS 
}
```

#### Variables

| Location | Direction | Role |
|----------|-----------|------|
| `$0AD4` | Read | Current player body index (0=Will, 1=Freedan, 2=Shadow) |
| `body_table` | Read | Body definition table (6 bytes × 3 entries) |
| `$7F0006,X` | Write | Sprite/metasprite data pointer |
| `$7F0008,X` | Write | Body scale/amplitude byte |
| `$player_flags` | R/W | Bit `$8000` cleared (body change complete) |

#### Cross-References

| Symbol | Relationship |
|--------|--------------|
| `StagePlayerSpr` (COP `$8F`) | Caller |
| `StagePlayerSprX/Y/XY` (COP `$90`–`92`) | Callers |
| `StagePlayerSprWall` (COP `$94`) | Caller |
| `StagePlayerSprFromDP` (COP `$95`) | Caller |
| `BuildSineHdmaTable` | Consumer of `$7F0006,X`/`$7F0008,X` |
| `BuildSineLookupTable` | Consumer of `$7F0008,X` amplitude |

---

### ParseSignedTileOffset

| Property | Value |
|----------|-------|
| **Old name** | `sub_00AF8F` |
| **New name** | `ParseSignedTileOffset` |
| **Address** | `$00AF8F` |
| **Size** | 63 bytes |
| **Type** | Signed offset parser |

#### Description

Reads two signed byte offsets from script arguments at `$0A`, sign-extends each to 16-bit, scales by 16 (tile-to-pixel conversion), adds to the actor's current pixel position (`$14`/`$16`), then divides by 16 to produce final tile coordinates in `$0018`/`$001C`.

The Y coordinate receives an additional `$10` subtraction before division (tile grid origin offset). Called by COP `$0D` (MarkSolidOffset) and `$0E` (ClearSolidOffset) to compute collision rectangles relative to the actor's position.

#### Algorithm

```
X axis:
1. LDA [$0A]; INC $0A               ; Read signed byte
2. If bit 7 → ORA #$FF00 (sign-extend)
3. ASL×4 (×16)                       ; Tile offset → pixels
4. CLC; ADC $14                      ; Add actor X position
5. LSR×4 (÷16) → STA $0018           ; Back to tile coords

Y axis:
6. LDA [$0A]; INC $0A               ; Read signed byte
7. If bit 7 → ORA #$FF00
8. ASL×4 (×16)
9. CLC; ADC $16                      ; Add actor Y position
10. SEC; SBC #$0010                  ; Subtract 16 (tile grid offset)
11. LSR×4 (÷16) → STA $001C          ; Back to tile coords
12. RTS
```

#### Source

```3125:3167:extracted/system/engine/cop_handlers_collision.asm
ParseSignedTileOffset {
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00AF9E
    ORA #$FF00

  loc_00AF9E:
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $14
    LSR 
    LSR 
    LSR 
    LSR 
    STA $0018
    LDA [$0A]
    INC $0A
    AND #$00FF
    BIT #$0080
    BEQ loc_00AFBB
    ORA #$FF00

  loc_00AFBB:
    ASL 
    ASL 
    ASL 
    ASL 
    CLC 
    ADC $16
    SEC 
    SBC #$0010
    LSR 
    LSR 
    LSR 
    LSR 
    STA $001C
    RTS 
}
```

#### Variables

| Location | Direction | Role |
|----------|-----------|------|
| `$0A` | Read | Script arg pointer (2 signed bytes) |
| `$14` / `$16` | Read | Actor pixel position |
| `$0018` | Output | Computed tile X coordinate |
| `$001C` | Output | Computed tile Y coordinate |

#### Cross-References

| Symbol | Relationship |
|--------|--------------|
| `MarkSolidOffset` (COP `$0D`) | Caller — mark collision at offset |
| `ClearSolidOffset` (COP `$0E`) | Caller — clear collision at offset |
| `TileCoordsToMapIndex` (Bank $02) | Called by COP handlers after this to resolve WRAM index |

---

## Call Flow Summary

```
  Metatile COPs ($4B–$4E)                Sprite COPs ($80–$92)
        │                                       │
        ▼                                       ▼
  ParseMapEntry (stream only)            ProcessAnimFlag
        │                                       │
        ▼                                       ▼
  ResolveTileData                        AnimFrameLookup
        │                                       │
        ▼                                       ▼
  TileQueryGate (retry if pending)       SetActorBody (player only)
                                              │
  Sine HDMA COPs ($00, $5F, $60)              ▼
        │                                  Stage to OAM
        ▼
  BuildSineLookupTable (init)
        │
        ▼
  BuildSineHdmaTable (per-frame)

  Collision COPs ($0D, $0E)
        │
        ▼
  ParseSignedTileOffset
        │
        ▼
  TileCoordsToMapIndex → WRAM write
```

---

## See Also

- [`cop-dispatch.md`](cop-dispatch.md) — COP handler table entries
- [`utility-math-movement.md`](utility-math-movement.md) — `ProcessAnimFlag` in movement init
- [`cop-commands-reference.md`](../../cop-commands-reference.md) — Full COP operand reference
- `extracted/system/engine/map_coords.asm` — `TileCoordsToMapIndex`, `PixelToVramAddress`
- `binary_01C455` — 256-byte sine table source data
