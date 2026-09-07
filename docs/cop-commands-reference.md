# Illusion of Gaia — COP Command Reference

Deep analysis of every actor/thinker COP opcode used by the US ROM, derived primarily from the real handlers in `extracted/system/chunk_008000.asm`, cross-checked against `us/copdef.json` and [Data Crystal — Actor code](https://datacrystal.tcrf.net/wiki/Illusion_of_Gaia/Notes#Actor_code).

Where those sources disagree, **the ASM wins**. Corrections are called out inline and summarized at the end.

---

## 1. Architecture

### 1.1 Dispatch

Native COP (`$02`) vectors to `native_mode_cop_handler_00846D`:

1. Saves actor index in `Y`, restores `X = ActorID`.
2. Sets `ArgPtr` (`$0A`) to the COP opcode byte (`return_PC − 1`), bank context in `$0C`.
3. Reads the opcode byte, advances `$0A` past it, doubles the opcode, and jumps through `cop_table_008485`.

```
JMP ($&cop_table_008485, X)   ; X = opcode × 2
```

| Opcode range | Table | Status |
|---|---|---|
| `$00`–`$6D` | `cop_table_008485` (110 entries) | Valid |
| `$6E`–`$7F` | `cop_junk_008561` | **Invalid** (garbage pointers) |
| `$80`–`$E2` | `cop_table2_008585` (99 entries; reached because `$80×2` lands at table2) | Valid |
| `$E3`+ | Past end / `cop_footer_00864B` | **Invalid** |

`us/copdef.json` lists phantom `$6E`, `$6F`, and `$E3` with empty parts — they have no handlers.

### 1.2 Entrancy state

Safe COP state (same as actor entrancy):

- `m=0, x=0, d=0, i=1`
- `X = D = ActorID`
- `DBR = $81`

`A`, `Y`, and flags are clobbered. Some COPs return useful values in `A`.

### 1.3 Control-flow outcomes

| Outcome | Mechanism | Typical use |
|---|---|---|
| **Continue** | `$0A → $02,S` then `RTI` | Fall through after args |
| **Branch** | Load `&Code` word into `$02,S`, `RTI` | Conditional jump |
| **Halt / yield** | Rewind `$0A` (or set `$00`/`$08`), `PLA PLA RTL` | Wait frames, buttons, animation, DMA |
| **Exit actor** | Unlink + `RTL`/`RTS` | Death (`$E0`), thinker free |

**Branch encoding:** Almost all “branch if …” COPs take a single `&Code`. Taken → jump to that absolute address. Not taken → skip the word and continue. Agents/docs that list a second “else `&Code`” are describing fallthrough, not a second operand.

**`&Code` vs `@Code`:**
- `&Code` — 16-bit address in the current script bank (`$0C`).
- `@Code` / `Address` — far pointer: word + bank byte (3 bytes) unless noted.

### 1.4 Important actor memory (COP-related)

| Addr | Role |
|---|---|
| `$00` / `$02` | EntryPtr + bank (resume target) |
| `$08` | Frame wait counter |
| `$0A` / `$0C` | ArgPtr + script bank while in COP |
| `$0E` | OAM XOR (priority / palette / H/V mirror) |
| `$10` / `$12` | Actor flags |
| `$14` / `$16` | Position X/Y (pixels) |
| `$28` / `$2A` | Sprite set index / frame |
| `$2C` / `$2E` | Movement per frame X/Y |
| `$04` / `$06` | Prev / next actor links |
| `$7F0004,X` | SavedPtr (`$C5`/`$C8`/`$C9`/`$E1`) |
| `$7F000A,X` | OnInteract / music id (context) |
| `$7F001C,X` | Parent id (marked children) |
| `$7F002A,X` | Extra flags (OR/AND via `$5B`/`$5C`) |
| `$7F1000+` | Hit / dodge / die / collide callbacks |

---

## 2. Parameter type legend

| Token | Size | Meaning |
|---|---|---|
| `Byte` | 1 | Unsigned 8-bit (often sign-extended if bit7 set) |
| `Word` | 2 | Unsigned 16-bit |
| `Address` / `@Code` | 3 | Far pointer (word + bank) |
| `&Code` | 2 | Near script address (current bank) |
| `&&Code` | 2 | Pointer to a word table of `&Code`s |
| `@WideString` / `&WideString` | 3 / 2 | Text pointer (far or near) |
| `@dma_data` | 3 | DMA source far pointer |
| `@&sprite_set` | 3 | Metasprite / spriteset far pointer |

Assembler syntax examples:

```asm
COP [D0] ( #8D, #00, &skyd_destroy )
COP [A0] ( @code_0BC988, #$0080, #$0050, #$1800 )
COP [BE] ( #02, #01, &skyd_options )
COP [26] ( #78, #$0160, #$0268, #07, #$4500 )
```

---

## 2.1 Common script idioms

These patterns appear constantly in `extracted/**/*.asm`. Understanding them unlocks most COP usage.

### Idle NPC (register interact, park forever)

```asm
; SouthCapeDeliveryman / most town NPCs
COP [D0] ( #8D, #00, &skyd_destroy )  ; if flag clear → die (already done)
COP [C0] ( &skyd_interact )           ; chat handler
COP [0B]                              ; mark tile solid
COP [C1]                              ; EntryPtr = here
RTL                                   ; yield; engine re-enters at C1 each frame
```

`$C1` + `RTL` is the standard “sleep until something else changes EntryPtr” loop. Chat sets EntryPtr to the `$C0` handler; when that returns (often via `$C5` or another `$C1`), the actor parks again.

### Stage sprite, then run it

```asm
; south_cape/church/sc08_seth.asm
COP [84] ( #14, #22 )   ; stage anim #14, loop $22 times
COP [8A]                ; run until loops done (halts each frame)
COP [85] ( #19, #04, #11 )
COP [8A]                ; stage+run with X movement
```

Rule: `$80`–`$87` / `$8F`–`$92` only **stage**. Something must follow — usually `$89` (once), `$8A` (loop), or `$8B` (one frame, no yield).

### Talk → choices → warp

```asm
; baserom/patches/SouthCapeDeliveryman.patch.asm
skyd_interact:
    COP [BF] ( &skyd_str_intro )           ; print box
    COP [BE] ( #02, #02, &skyd_options )   ; 2 choices, skip 2 lines
skyd_options [
  &skyd_cancel
  &skyd_cancel
  &skyd_confirm
]
skyd_confirm:
    COP [65] ( #$00D4, #$03A4, #00, #23 )  ; stage world-map move
    COP [26] ( #78, #$0160, #$0268, #07, #$4500 )
    RTL
```

`$BF` prints; `$BE` waits for a selection and jumps into the option table (first entry = cancel / B).

### One-shot cutscene actor

```asm
; wa78_intro / many companions
COP [DA] ( #1D )     ; wait ~30 frames
COP [04] ( #1B )     ; start music
COP [DA] ( #3B )
COP [BF] ( &text )
COP [E0]             ; remove self when done
```

### Gate on story flag, then mutate the map

```asm
; itory/moon_tribe_cave/it1B_inca_statue_b.asm
COP [C0] ( &code_04FADF )
COP [D2] ( #48, #01 )   ; wait here until flag $48 is set
COP [32] ( #1D )        ; stage BG rearrange
COP [33]                ; apply it
COP [CD] ( #$011D )
COP [E0]
```

`$D2`/`$D3` are the “block until flag” waits (exit/retry every frame). `$D0`/`$D1` are the non-blocking branches.

### AI switch on RNG

```asm
; seaside_palace/sp5C_slipper.asm
COP [C6] ( &code_0AE4AF )          ; SavedPtr = AI loop head
COP [23]                           ; RNG → A
AND #$0003
STA $0000
COP [D9] ( #$0000, &code_list_0AE4D7 )  ; jump by [ $0000 ]
code_list_0AE4D7 [
  &code_0AE5C8   ;00 walk pattern A
  &code_0AE611   ;01 …
]
```

`$D9` reads a **RAM byte** at the given address and indexes a near jump table — the usual “pick a behavior” switch.

---

## 3. Full opcode catalog

### 3.1 HDMA / DMA (`$00`–`$03`)

#### `$00` — `GenHdmaSine`
- **Handler:** `cop_handler_00_00864E`
- **Params:** none
- **Does:** Builds a scaled 16-bit sine table in `$7E8900`–`$7E8CFF` and an HDMA descriptor at `$7E8800`.
- **How:** `JSR sub_00AEB8` fills the table from `binary_01C455` × amplitude `$7F0008,X`, advances phase `$7F0006,X`, writes channel control bytes. Continues.

#### `$01` — `QueueHdma`
- **Handler:** `cop_handler_01_008689`
- **Params:** `@dma_data Src`, `Byte Reg`
- **Does:** Queue HDMA (indirect) to B-bus register `Reg` on the next free channel.
- **How:** `JSL func_03E157` (sets `DMAP` with `$40`, `A1T`, `BBAD`, advances `$006A`, enables `$0066`).

#### `$02` — `QueueDma`
- **Handler:** `cop_handler_02_0086A0`
- **Params:** `@dma_data Src`, `Byte Reg`
- **Does:** Queue general DMA (not HDMA-indirect).
- **How:** Same layout as `$01`; `JSL func_03E173`.

#### `$03` — `QueueHdmaChannel`
- **Handler:** `cop_handler_03_0086B7`
- **Params:** `Byte Channel`, `Address Src`, `Byte Reg` *(copdef incorrectly lists `Byte, Word, Word`)*
- **Does:** Program a **specific** DMA/HDMA channel immediately.
- **How:** Channel bitmask → `TSB $0066`; write `DMAP0+X` / `A1T0+X` / `BBAD0+X` using `binary_01D8BE`.

---

### 3.2 Music / sound / APU (`$04`–`$0A`, `$19`)

#### `$04` — `StartMusic`
- **Handler:** `cop_handler_04_008714`
- **Params:** `Byte MusicId`
- **Does:** Start (or change) music.
- **How:** Allocates a thinker (`sub_00B189`), points it at `func_03E1D6` (`$F0` APU handshake → write id to `$06FA`), stores `MusicId` in thinker `$7F000A`. Continues asynchronously. Fail-soft if no slot.

#### `$05` — `FadeThenStartMusic`
- **Handler:** `cop_handler_05_008749`
- **Params:** `Byte MusicId`
- **Does:** Fade out, then start music.
- **How:** Same as `$04` but thinker entry is `func_03E1AA` (`$F1` handshake), which falls into `func_03E1D6`.

#### `$06` — `PlaySoundCh2`
- **Handler:** `cop_handler_06_00877E`
- **Params:** `Byte SoundId`
- **Does:** Queue SFX on the second sound channel.
- **How:** `STA $06F9` (8-bit). Engine drains this into the APU.

#### `$07` — `PlaySoundCh1`
- **Handler:** `cop_handler_07_008792`
- **Params:** `Byte SoundId`
- **Does:** Queue SFX on the first sound channel.
- **How:** `STA $06F8` (8-bit).

#### `$08` — `PlaySoundBoth`
- **Handler:** `cop_handler_08_0087A6`
- **Params:** `Word` *(low = ch1, high = ch2)* — wiki “two SoundIds”; copdef `Word`
- **Does:** Queue both channels at once.
- **How:** `STA $06F8` (16-bit).

#### `$09` — `WriteApuIo1`
- **Handler:** `cop_handler_09_0087B5`
- **Params:** `Byte`
- **Does:** Direct `STA $2141` (APUIO1). Wiki “tempo modifier” is a usage pattern, not the primitive.

#### `$0A` — `WriteApuIo0`
- **Handler:** `cop_handler_0A_0087C9`
- **Params:** `Byte`
- **Does:** Direct `STA $2140` (APUIO0).

#### `$19` — `MusicAndText`
- **Handler:** `cop_handler_19_0087DD`
- **Params:** `Byte MusicId`, `@WideString Text`
- **Does:** Start music and show text (combined `$04` + `$BF`-like path).
- **How:** Prefer spawn thinker `func_02A040` with music/text fields; if no slot, run wide-string interpreter inline (`sub_03E255`) with joypad masked.

---

### 3.3 BG solidity / collision map (`$0B`–`$1E`, `$42`, `$62`)

Collision bytes live in WRAM `$7FC000` (indexed via `func_02B0A3` / probes via `sub_00B43B`). High nibble ≈ wall; low nibble ≈ type/dir.

| Op | Name | Handler | Params | Effect |
|---|---|---|---|---|
| `$0B` | `MarkSolidHere` | `$008876` | — | `OR #$F0` under actor footprint (set wall nibble) |
| `$0C` | `ClearSolidHere` | `$00888C` | — | `AND #$0F` under actor (clear wall nibble, keep type) |
| `$0D` | `MarkSolidOffset` | `$0088A2` | `Byte dX, Byte dY` | `OR #$F0` at tile offset (sign-ext) |
| `$0E` | `ClearSolidOffset` | `$0088C8` | `Byte dX, Byte dY` | `AND #$0F` at offset |
| `$0F` | `MarkSolidAbs` | `$0088EE` | `Byte tileX, Byte tileY` | `OR #$F0` absolute |
| `$10` | `ClearSolidAbs` | `$008925` | `Byte tileX, Byte tileY` | `AND #$0F` absolute |
| `$11` | `ClearCollisionHere` | `$00895C` | — | Clear full byte under actor |
| `$12` | `ClearTypeAbs` | `$008975` | `Byte tileX, Byte tileY` | `AND #$F0` absolute (clear type nibble, keep wall) |
| `$42` | `SetCollisionAbs` | `$00952F` | `Byte tileX, Byte tileY, Byte Type` | Write `Type` absolute (full collision byte) |

**Branch-if-solid family** (single `&Code`; taken when low nibble ≠ 0 unless noted):

| Op | Name | Handler | Probe position |
|---|---|---|---|
| `$13` | `BranchIfSolidHere` | `$0089AC` | Actor tile |
| `$14` | `BranchIfSolidOffset` | `$0089D3` | Actor + signed `(dX,dY)×16` pixels |
| `$15` | `BranchIfSolidNorth` | `$008A22` | North (`Y − $10`) |
| `$16` | `BranchIfSolidSouth` | `$008A4D` | South (`Y + $10`) |
| `$17` | `BranchIfSolidWest` | `$008A78` | West (`X − $10`) |
| `$18` | `BranchIfSolidEast` | `$008AA3` | East (`X + $10`) |

**Branch-if-collision-type** (`Byte Type`, `&Code`) — taken when `(probe & $FF) == Type`:

| Op | Name | Handler | Probe |
|---|---|---|---|
| `$1A` | `BranchIfTypeHere` | `$008ACE` | Here |
| `$1B` | `BranchIfTypeNorth` | `$008B01` | North |
| `$1C` | `BranchIfTypeSouth` | `$008B38` | South |
| `$1D` | `BranchIfTypeWest` | `$008B6F` | West |
| `$1E` | `BranchIfTypeEast` | `$008BA6` | East |

#### `$62` — `BranchIfCollisionTypeNe`
- **Handler:** `cop_handler_62_009B41`
- **Params:** `Byte Nibble`, `&Code`
- **Does:** Branch if collision **low nibble ≠ Nibble** (not a duplicate of `$1A`).
- **How:** Tile coords from `$14/$16`; `JSL func_03D78A`; compare `[$80],Y & $0F`. Polarity and helper differ from `$1A`.

---

### 3.4 Proximity / grid / RNG / position (`$1F`–`$27`)

#### `$1F` — `BranchIfNotOnGridline`
- **Handler:** `cop_handler_1F_008BDD`
- **Params:** `&Code`
- **Does:** Branch if not 16px-aligned in Y, or if forward tile (from body table) is solid.

#### `$20` — `BranchIfActorNear`
- **Handler:** `cop_handler_20_008C19`
- **Params:** `Byte AcNum`, `Byte Dist`, `&Code`
- **Does:** Resolve map-list actor `AcNum` (`sub_00B125`), Chebyshev distance test (tile×16), branch if within range.

#### `$21` — `BranchIfPlayerNear`
- **Handler:** `cop_handler_21_008C26`
- **Params:** `Byte Dist`, `&Code`
- **Does:** Same distance test vs `$player_actor`.

#### `$22` — `MoveToward`
- **Handler:** `cop_handler_22_008C6F`
- **Params:** `Byte SpriteId`, `Byte Speed` *(Speed `$FF` → use `$28`)*
- **Does:** Basic movement up to `$FE` pixels toward destination pre-written in `$7F0018/$7F001A`. Multi-frame; **halts** each frame until done. Sets `$7F002A` bit1 while moving.

#### `$23` — `RngByte`
- **Handler:** `cop_handler_23_008FFC`
- **Params:** none
- **Does:** Advance expensive LCG over `$040F`–`$041E`; **returns `A = ($0410 & $FF)`**.

#### `$24` — `RngMod`
- **Handler:** `cop_handler_24_00902B`
- **Params:** `Byte Max`
- **Does:** Store `($0410 & $FF) % Max` into `$0420`.

#### `$25` — `SetTilePos`
- **Handler:** `cop_handler_25_00904E`
- **Params:** `Byte tileX`, `Byte tileY`
- **Does:** `$14 = tileX×16+8`, `$16 = tileY×16`.

#### `$26` — `QueueMapChange`
- **Handler:** `cop_handler_26_009072`
- **Params:** `Byte MapNum`, `Word PosX`, `Word PosY`, `Byte DirAndSave`, `Word CamBounds`
- **Does:** Queue scene transition (`$scene_next`, `$064C`–`$0652`). If `DirAndSave` bit7 set, save resume PC to `$0AF0+` for return-after-load.

#### `$27` — `WaitWhileOffscreen`
- **Handler:** `cop_handler_27_0090CE`
- **Params:** `Byte Delay`
- **Does:** If `$10` bit `$4000` (offscreen), store delay in `$08` and **halt**; else consume byte and continue.

---

### 3.5 Player / actor relation branches (`$28`–`$31`, `$35`, `$44`–`$49`)

#### `$28` — `BranchIfPlayerAt`
- **Handler:** `cop_handler_28_0090F4`
- **Params:** `Word PosX`, `Word PosY`, `&Code`

#### `$29` — `BranchIfActorAt`
- **Handler:** `cop_handler_29_0090FA`
- **Params:** `Byte AcNum`, `Word PosX`, `Word PosY`, `&Code`

#### `$2A` — `BranchOnPlayerX`
- **Handler:** `cop_handler_2A_009135`
- **Params:** `Word Dist`, `&Code West`, `&Code East`, `&Code Here`
- **Does:** 3-way branch on horizontal separation vs player.

#### `$2B` — `BranchOnPlayerY`
- **Handler:** `cop_handler_2B_00915F`
- **Params:** `Word Dist`, `&Code North`, `&Code South`, `&Code Here`

#### `$2C` — `BranchNearerAxis`
- **Handler:** `cop_handler_2C_009189`
- **Params:** `&Code NearY`, `&Code NearX` *(wiki correct; no threshold word)*
- **Does:** If `|ΔY| < |ΔX|` → NearY; else → NearX. Both are absolute jump targets.

#### `$2D` — `DirToPlayer`
- **Handler:** `cop_handler_2D_0091B8`
- **Params:** none
- **Does:** Compute 8-way octant actor→player (`sub_00AFCE`); **`A = 0..7`** (N, NE, E, …).

#### `$2E` — `DirToPlayerFrom`
- **Handler:** `cop_handler_2E_009236`
- **Params:** `Byte OffsX`, `Byte OffsY`
- **Does:** Same from actor+offset; `A = octant`.

#### `$2F` — `BranchIfDirToPlayer`
- **Handler:** `cop_handler_2F_00926A`
- **Params:** `Byte Dir`, `&Code`

#### `$30` — `BranchIfDirToPlayerFrom`
- **Handler:** `cop_handler_30_009299`
- **Params:** `Byte OffsX`, `Byte OffsY`, `Byte Dir`, `&Code`

#### `$31` — `BranchOnPlayerFacing`
- **Handler:** `cop_handler_31_0092E8`
- **Params:** `&Code South`, `&Code North`, `&Code West`, `&Code East` *(4 words; copdef `size:10` / 5 codes overcounts)*
- **Does:** `JSL func_03F0CA` maps player `$0028` through `binary_03F11F` → facing `0..3`; picks matching target. If result ≥4 / SEC path, skip all four and continue.
- **Note:** Same helper as `$48`. Wiki facing order is correct.

#### `$35` — `CardinalToPlayer`
- **Handler:** `cop_handler_35_0091CC`
- **Params:** none
- **Does:** Return `A = 0/1/2/3` = E/S/W/N by comparing `|ΔX|` vs `|ΔY|`.

#### `$44` — `BranchIfPlayerInRelTiles`
- **Handler:** `cop_handler_44_00956B`
- **Params:** `Byte XLeft, YUp, XRight, YDown`, `&Code`
- **Does:** Signed tile offsets ×16; branch if player center inside rectangle.

#### `$45` — `BranchIfPlayerInAbsTiles`
- **Handler:** `cop_handler_45_0095EA`
- **Params:** `Byte XLeft, YTop, XRight, YBot`, `&Code`
- **Does:** Absolute tile rectangle; Y test uses **player Y − 8** (feet).

#### `$46` — `CopyPosToPrev`
- **Handler:** `cop_handler_46_009647`
- **Params:** none — copy `$14/$16` to actor `$04`.

#### `$47` — `CopyPosToNext`
- **Handler:** `cop_handler_47_00964C`
- **Params:** none — copy to actor `$06`.

#### `$48` — `GetPlayerFacing`
- **Handler:** `cop_handler_48_00965E`
- **Params:** none
- **Does:** `JSL func_03F0CA`; leave facing in `A` (does **not** branch).

#### `$49` — `BranchIfBodyNe`
- **Handler:** `cop_handler_49_009668`
- **Params:** `Byte Body`, `&Code`
- **Does:** Branch if `$0AD4 ≠ Body` (0=Will, 1=Freedan, 2=Shadow). Single `&Code`.

---

### 3.6 BG tilemap rearrange (`$32`–`$34`)

#### `$32` — `StageBgChange`
- **Handler:** `cop_handler_32_009317`
- **Params:** `Byte BgChg`
- **Does:** Stage rearrangement from `$81d3ce + 8×BgChg` via `func_02A363` into `$96`–`$A4`.

#### `$33` — `ApplyBgChange`
- **Handler:** `cop_handler_33_009328`
- **Params:** none
- **Does:** Apply staged change (`func_02A3A8`) with VBlank sync until complete.

#### `$34` — `StageBgChangeFromDeathIdx`
- **Handler:** `cop_handler_34_009352`
- **Params:** none
- **Does:** Use `$7F0024,X` as index (monster death rearrange); forces `$06F8=$0F0F` during lookup.

**Usage:** Always `$32` then `$33` (or death path that implies both). Opens doors, caves in walls, reveals stairs after bosses:

```asm
; diamond_mine/…/dm3D_breakable_wall.asm (after flag set)
COP [32] ( #33 )
COP [33]
```

Actor-list `DeathActionIndex` is sugar for “on death: `$32` with that index + `$33`”.

---

### 3.7 Palette bundles (`$36`–`$3A`)

Thinker-friendly. Sequences live in bank `$16`, indexed at `$168000`.

| Op | Name | Handler | Params | Behavior |
|---|---|---|---|---|
| `$36` | `PaletteRestart` | `$009361` | — | Restart bundle sequence 0; apply frame; **halt** |
| `$37` | `PaletteStart` | `$009364` | `Byte Bundle` | Start bundle; **halt** |
| `$38` | `PaletteStartLoop` | `$009381` | `Byte Bundle`, `Byte Iters` | Start + outer loop count; **halt** |
| `$39` | `PaletteStep` | `$0093AA` | — | Advance one frame; halt while more remain; continue when done |
| `$3A` | `PaletteStepLoop` | `$0093CE` | — | Like `$39` but also respects outer `Iters` |

Helpers: `func_03E0B0` (load), `func_03E125` (apply / HDMA CGRAM).

---

### 3.8 Thinkers (`$3B`–`$3D`)

#### `$3B` — `SpawnThinkerParam`
- **Handler:** `cop_handler_3B_009400`
- **Params:** `Byte Param`, `@Code Entry`
- **Does:** Allocate thinker; `Param → $7F0002`; run `Entry`.

#### `$3C` — `SpawnThinker`
- **Handler:** `cop_handler_3C_00943C`
- **Params:** `@Code Entry`

#### `$3D` — `KillThinker`
- **Handler:** `cop_handler_3D_009443`
- **Params:** none
- **Does:** Unlink thinker and push id onto free stack `$52`. Thinkers must call this then `RTL`.

---

### 3.9 Buttons (`$3E`–`$41`)

Mask bit0 selects pad source: clear → `$0656` (filtered), set → `$0660` (include prior / raw).

| Op | Name | Handler | Params | Behavior |
|---|---|---|---|---|
| `$3E` | `WaitForButton` | `$009485` | `Word Mask` | **Wait until** any masked button pressed (rewind+RTL) |
| `$3F` | `WaitForRelease` | `$0094AD` | `Word Mask` | **Wait until** masked buttons released |
| `$40` | `BranchIfPressed` | `$0094D5` | `Word Mask`, `&Code` | Branch if pressed |
| `$41` | `BranchIfNotPressed` | `$009501` | `Word Mask`, `&Code` | Branch if not pressed |

Wiki “exit if …” = yield actor until condition (same as halt/retry).

---

### 3.10 Snap / metatile / world-map draw (`$43`, `$4A`–`$4E`)

#### `$43` — `SnapToGrid`
- **Handler:** `cop_handler_43_008DE6`
- **Params:** none
- **Does:** If not on 8×8 grid (`($14−8)|$16 & $0F`), save resume to `$7F1018/$7F101A` and divert to grid-walk helper (uses `$22` + `$4A`).

#### `$4A` — `ResumeAfterSnap`
- **Handler:** `cop_handler_4A_008E19`
- **Params:** none — restore PC saved by `$43`.

#### `$4B` — `DrawMetatileAbs`
- **Handler:** `cop_handler_4B_009685`
- **Params:** `Byte tileX`, `Byte tileY`, `Byte Metatile`
- **Does:** Queue metatile+collision draw; yields if map engine busy (`$0902`).

#### `$4C` — `DrawMetatileHere`
- **Handler:** `cop_handler_4C_0096CA`
- **Params:** `Byte Metatile`
- **Does:** Same at actor `$14/$16`. *(Wiki “unknown” — resolved.)*

#### `$4D` — `WorldMapStream3`
- **Handler:** `cop_handler_4D_009703`
- **Params:** `Word DataOffset`
- **Does:** Multi-frame 3-byte record stream from script bank; draws via shared `sub_009829`; **halts** between records. Terminal record has MSB set.

#### `$4E` — `WorldMapStream4`
- **Handler:** `cop_handler_4E_009774`
- **Params:** `Word DataOffset`
- **Does:** Like `$4D` with 4-byte records (extra attribute → actor `$08`).

---

### 3.11 Memory / VRAM / decompress (`$4F`–`$51`, `$54`)

#### `$4F` — `AdhocVramDma`
- **Handler:** `cop_handler_4F_0098B8`
- **Params:** `Address Src`, `Word Size`, `Word VramWord`
- **Does:** One-shot VRAM upload; first entry yields until engine accepts; completion skips 7 arg bytes.
- **How:** Stash `$7F0C03`–`$7F0C09`; flag `$7F002A` bit0. *(Wiki swaps Size/Vram order vs ASM.)*

#### `$50` — `CopyPalette`
- **Handler:** `cop_handler_50_009930`
- **Params:** `Address Src`, `Byte OffsW`, `Byte PalWord`, `Byte SizeW`
- **Does:** `MVN` of `(SizeW<<1)+OffsW` words into `$7F0A00+2×PalWord`.

#### `$51` — `Decompress`
- **Handler:** `cop_handler_51_00997B`
- **Params:** `Address Src`, `Address Dest` *(vanilla reads 7 bytes; trailing byte discarded)*
- **Does (vanilla):** Always decompress `[Src]` bitstream into bank `$7E` Dest via `func_028270`.
- **Patch note:** `baserom/patches/Cop51Patch.patch.asm` extends semantics: size>0 decompress; size=0 MVN `$2000`; size<0 raw MVN `|size|−1`.

#### `$54` — `SetScratchPointer`
- **Handler:** `cop_handler_54_0099BF`
- **Params:** `Address` *(stores word + bank byte into actor scratch)*
- **Does:** `$7F0000,X = word`, `$7F0002,X = bank byte` (high byte zeroed by 16-bit AND).

---

### 3.12 Staged movement / gravity / HDMA sine (`$52`–`$53`, `$5F`–`$61`, `$63`–`$64`)

#### `$52` — `StageMove`
- **Handler:** `cop_handler_52_008E36`
- **Params:** `Byte SpriteId`, `Byte Speed`, `Byte MaxTime` *(MaxTime high bit = unlimited)*
- **Does:** Init staged move using dest in `$7F0018/$1A`; pair with `$53`.

#### `$53` — `TickMove`
- **Handler:** `cop_handler_53_008F0D`
- **Params:** none — advance one frame; **halt** until complete.

#### `$5F` — `InitSineHdma`
- **Handler:** `cop_handler_5F_009B89`
- **Params:** `Word Base`, `Byte BytesPerPeriod`
- **Does:** Build sine tables (needs `2×Amplitude` in `$7F0008` beforehand).

#### `$60` — `TickSineHdma`
- **Handler:** `cop_handler_60_009C3A`
- **Params:** `Byte Delay`, `Byte ScrollLayer` *(0=BG1, 2=BG2)*

#### `$61` — `BindSineHdma`
- **Handler:** `cop_handler_61_009C91`
- **Params:** `Address Src`, `Byte Reg` — queue HDMA for sine tables.

#### `$63` — `InitGravity`
- **Handler:** `cop_handler_63_009CB4`
- **Params:** `Byte InitSpeed`, `Byte NegLogA`, `Byte GndTilePos`

#### `$64` — `TickGravity`
- **Handler:** `cop_handler_64_009CFA`
- **Params:** none — one gravity frame; landing returns `A=$FFFF`.

---

### 3.13 Callbacks / flags / misc (`$55`–`$5E`, `$68`–`$6A`)

| Op | Name | Handler | Params | Effect |
|---|---|---|---|---|
| `$55` | `ResetSpriteState` | `$0099DA` | `Byte Spr`, `Word New24` | Reset sprite (`$80`-like) + set `$24`/`$28`/`$2A` scratch |
| `$56` | `AdvanceSpriteAnim` | `$0099F5` | — | Advance global sprite anim table; halt while VRAM busy |
| `$57` | `SetDeathCallback` | `$009A67` | `@Code OnDeath` | `$7F1004` die ptr (+ bank byte) |
| `$58` | `SetHitCallback` | `$009A82` | `&Code OnHit` | `$7F1000` |
| `$59` | `SetDodgeCallback` | `$009A92` | `&Code Dodge` | `$7F1002` |
| `$5A` | `SetCollideCallback` | `$009AA2` | `&Code OnCollide` | `$7F1008` |
| `$5B` | `OrExtraFlags` | `$009AC2` | `Word Mask` | `$7F002A \|= Mask` |
| `$5C` | `AndExtraFlags` | `$009AD6` | `Word Mask` | `$7F002A &= Mask` |
| `$5D` | `BranchIfBehindWall` | `$009AEA` | `&Code` | Branch if low-priority sprite behind wall (`$0E` / solidity `$xE/$xF`) |
| `$5E` | `SetCustomCallback` | `$009AB2` | `&Code` | `$7F1016,X ← ptr` |
| `$68` | `BranchIfOffCamera` | `$009DBD` | `&Code` | Branch if off-camera (`$06D6`–`$06DC` bounds) |
| `$69` | `HaltIfMaxFrames` | `$009DEA` | `Word Min` | **Halt/exit** when `Min ≥ $00E4` (wiki "`$00E4 < Min`" is off-by-one vs `BCC`) |
| `$6A` | `SetLinkedEntryPtr` | `$009E06` | `&Code` | Set EntryPtr of linked actor `$06`; clear its wait/move |

---

### 3.14 World map staging (`$65`–`$67`)

#### `$65` — `StageWorldMapMove`
- **Handler:** `cop_handler_65_009D52`
- **Params:** `Word PosX`, `Word PosY`, `Byte Dummy`, `Byte WMapMoveId`
- **Does:** Write `$0D52`–`$0D5E`; move script indexed at `$83ad77`.

#### `$66` — `StageWorldMapChoice`
- **Handler:** `cop_handler_66_009D81`
- **Params:** `Word PosX`, `Word PosY`, `Byte WMapOptsId`
- **Does:** Choice text ptr indexed at `$83b401`.

#### `$67` — `StageWorldMapMoveIds`
- **Handler:** `cop_handler_67_009DA3`
- **Params:** `Byte Dummy`, `Byte WMapMoveId` — like `$65` without rewriting position (already on world map).

**Usage:** Always followed by `$26` to actually change scenes. Deliveryman / Kara travel:

```asm
COP [65] ( #$00D4, #$03A4, #00, #23 )
COP [26] ( #78, #$0160, #$0268, #07, #$4500 )
```

`$67` is what `overworld_options.asm` uses when picking a destination while already viewing the map.

---

### 3.15 Text alt / spiral (`$6B`–`$6D`)

#### `$6B` — `PrintWideStringAlt`
- **Handler:** `cop_handler_6B_00A958`
- **Params:** `&WideString`
- **Does:** Text without full screen-refresh path of `$BF` (`sub_03E255`, masks `$10` bit `$0800`).

#### `$6C` — `InitSpiral`
- **Handler:** `cop_handler_6C_00A992`
- **Params:** `Byte Angle`, `Byte Diameter` → `$7F0010/$7F0012` (OrbitAng / OrbitDia).

#### `$6D` — `SpiralStep`
- **Handler:** `cop_handler_6D_00A9AE`
- **Params:** `Byte DiameterSpeed`, `Byte AngleSpeed`
- **Does:** Add signed deltas; `JSL func_00F3C9` orbits about actor id in `$0000`.

---

### 3.16 Sprite staging & animation (`$80`–`$8D`)

Staging stores frame in `$28`, optional loop `$7F0016`, move durations `$7F0018/$1A` → `$2C/$2E` via `sub_00B157`. `$FF` frame clears `$2A` (restart current).

**Critical:** `$80`–`$87` only *stage*. A following `$89`/`$8A`/`$8B` actually runs the animation across frames.

| Op | Name | Handler | Params | Stages |
|---|---|---|---|---|
| `$80` | `StageSpr` | `$009E23` | `Byte Spr` | Frame only |
| `$81` | `StageSprX` | `$009E35` | `Byte Spr`, `Byte XMove` | + X |
| `$82` | `StageSprY` | `$009E57` | `Byte Spr`, `Byte YMove` | + Y |
| `$83` | `StageSprXY` | `$009E79` | `Byte Spr`, `Byte XMove`, `Byte YMove` | + XY |
| `$84` | `StageSprLoop` | `$009EAB` | `Byte Spr`, `Byte Iters` | + loop count |
| `$85` | `StageSprLoopX` | `$009EC8` | `Byte Spr`, `Byte Iters`, `Byte XMove` | loop + X |
| `$86` | `StageSprLoopY` | `$009EF5` | `Byte Spr`, `Byte Iters`, `Byte YMove` | loop + Y |
| `$87` | `StageSprLoopXY` | `$009F22` | `Byte Spr`, `Byte Iters`, `Byte XMove`, `Byte YMove` | full |

**Move bytes** are duration/speed indices into `table_01B086` (not raw pixels). Direction comes from `$12` force bits (`$AD`–`$AF`) and H-mirror.

#### `$88` — `SetMetasprite`
- **Handler:** `cop_handler_88_009F8F`
- **Params:** `@&sprite_set` (Word + bank) → `$7F0006/$08`.
- **Usage:** Point at a different spritesheet before staging frames (breakable walls load `table_0EE000`, then `$80`/`$89`).

#### `$89` — `AnimOnce`
- **Handler:** `cop_handler_89_009FAA`
- **Params:** none — `func_03CA55`; **RTL** while animating; clear move on done.
- **Usage:** After `$80`/`$8D` for one full cycle (face player, pose, then continue).

#### `$8A` — `AnimLoop`
- **Handler:** `cop_handler_8A_009FC0`
- **Params:** none — repeat until `$7F0016` hits 0; halt each incomplete frame.
- **Usage:** Always paired with `$84`–`$87`. Walking cutscenes:

```asm
; south_cape/church/sc08_seth.asm
COP [84] ( #14, #22 )
COP [8A]
COP [85] ( #19, #04, #11 )  ; sprite, 4 loops, +X speed index
COP [8A]
```

#### `$8B` — `AnimOneFrame`
- **Handler:** `cop_handler_8B_009FDE`
- **Params:** none — advance one frame without yielding.
- **Usage:** Rare; when the script is already inside a per-frame `$C1` loop and must tick anim without nested RTL.

#### `$8C` — `WaitForAnimFrame`
- **Handler:** `cop_handler_8C_009FF1`
- **Params:** `Byte SprFrame` — halt until `$2A == SprFrame`.
- **Usage:** Sync SFX / hitbox / spawn to a specific animation frame.

#### `$8D` — `StageSprAndHitbox`
- **Handler:** `cop_handler_8D_00A01E`
- **Params:** `Byte Spr` — stage + immediately `func_03CA55` (updates hitbox).
- **Usage:** Combat pose changes that also resize the hurtbox (slipper `COP [8D] ( #27 )`).

---

### 3.17 Player sprites (`$8E`–`$98`)

Same staging model as `$80`+, but body lookup goes through `$0AD4` / `body_table` so Will/Freedan/Shadow share one script.

| Op | Name | Handler | Params | Notes |
|---|---|---|---|---|
| `$8E` | `SetPlayerSpriteDirect` | `$00A036` | `Byte PlayerSpr` | Direct body-table index; sets `$player_flags` `$8000` |
| `$8F` | `StagePlayerSpr` | `$00A06B` | `Byte BodySpr` | Stage normal player sprite for current body |
| `$90` | `StagePlayerSprX` | `$00A081` | + `Byte XMove` | Player walk staging (pair with `$93`) |
| `$91` | `StagePlayerSprY` | `$00A0A7` | + `Byte YMove` | Player walk staging (pair with `$93`) |
| `$92` | `StagePlayerSprXY` | `$00A0CD` | + `Byte XMove`, `Byte YMove` | Player walk staging (pair with `$93`) |
| `$93` | `RunPlayerAnim` | `$00A103` | — | Run player anim once (like `$89`) |
| `$94` | `StagePlayerSprWall` | `$00A119` | `…`, `Byte WallType` | Like `$92`; saves WallType to `$09B0` for `$96`–`$98` |
| `$95` | `StagePlayerSprFromDP` | `$00A159` | — | Like `$8F` using `$0000` low byte as BodySpr |

#### `$96` / `$97` / `$98` — wall-gated player anim
- **Handlers:** `cop_handler_96_00A16E` / `cop_handler_97_00A1B5` / `cop_handler_98_00A200`
- **Params:** `Word` map-context / trigger id
- **Does:** If context matches `$0656` and solidity at the probe equals `$09B0`, set `$10` bit `$0004` and/or run anim.
- **Probes:** `$96` underfoot, `$97` north (`Y−16`), `$98` south (`Y+16`).
- **Usage:** Forced player steps that only “count” when walking into a specific wall type (stairs, ice). Requires a prior `$94`. Wiki “unused” is wrong — handlers are live.

---

### 3.18 Spawn actors (`$99`–`$A6`)

Link helpers:
- `sub_00B15D` — insert **before** this (parent `$04` = child)
- `sub_00B189` — insert **after** this (parent `$06` = child)
- `sub_00B1DA` — copy parent state/sprite
- `sub_00B1CB` — mark child (`$7F001C` = parent; parent `$12` bit `$0040` so `$A7`/`$E0` can cascade)

| Op | Name | Handler | Link | Extras |
|---|---|---|---|---|
| `$99` | `SpawnBefore` | `$00A24B` | Before (`$04`) | `@Code` |
| `$9A` | `SpawnBeforeFlags` | `$00A267` | Before | `@Code`, `Word New10` |
| `$9B` | `SpawnAfter` | `$00A28C` | After (`$06`) | `@Code` |
| `$9C` | `SpawnAfterFlags` | `$00A2A8` | After | `@Code`, `Word New10` |
| `$9D` | `SpawnAfterOffset` | `$00A2CD` | After | `@Code`, `Word OffsX`, `Word OffsY` |
| `$9E` | `SpawnAfterOffsetFlags` | `$00A303` | After | offs + `New10` |
| `$9F` | `SpawnAfterAbs` | `$00A342` | After | `@Code`, `Word AbsX`, `Word AbsY` |
| `$A0` | `SpawnAfterAbsFlags` | `$00A370` | After | abs + `New10` |
| `$A1` | `SpawnBeforeMarked` | `$00A3A7` | Before + **marked child** | `@Code`, `Word New10` |
| `$A2` | `SpawnAfterMarked` | `$00A3D4` | After + marked | `@Code`, `Word New10` |
| `$A3` | `SpawnAfterAbsMarked` | `$00A401` | After + marked | abs + `New10` |
| `$A4` | `SpawnAfterOffsetMarked` | `$00A440` | After + marked | `Byte OffsX/Y` + `New10` |
| `$A5` | `SpawnListAppend` | `$00A499` | Full list splice (last) | `Byte OffsX/Y` + `New10` (no mark) |
| `$A6` | `SpawnListAppendSpr` | `$00A533` | Like `$A5` + `Byte Spr` | Sets child `$28` |

**`$A6` is not broken** — copdef part order is wrong; ROM layout is `@Code, Byte bank, Byte Spr, Byte OffsX, Byte OffsY, Word New10`. New actor id returned in `Y`.

**`New10` flags** (common values from prologue/cutscenes):
- `#$1800` — interactable + continue-during-dialogue
- `#$2000` — disable render/collision (hidden helper / wait-loop actor)
- `#$2800` — `$2000` + `$0800` (hidden + keep acting in dialogue)

```asm
; prologue/prologue_prophecy/pr8C_prologue1.asm — stagger-spawn props
COP [A0] ( @code_0BCAB1, #$016E, #$03E8, #$1800 )
COP [DA] ( #02 )
COP [A0] ( @code_0BCAB1, #$0166, #$041A, #$1800 )
```

After spawn, scripts often write extra fields through `Y` (`STA $0026, Y` for a string ptr, etc.).

---

### 3.19 Death / kill / forced move (`$A7`–`$B1`, `$E0`)

| Op | Name | Handler | Effect | When to use |
|---|---|---|---|---|
| `$A7` | `MarkDeath` | `$00A5DE` | Mark death after **next** `RTL` | Finish current frame / anim, then die |
| `$E0` | `Die` | `$00A5F7` | Kill **now** (unlink via `sub_00AF40`) | Terminal end of cutscene actors, despawn NPCs |
| `$A8` | `KillPrev` | `$00A6A1` | Kill actor linked in `$04` | Parent tears down a specific child |
| `$A9` | `KillNext` | `$00A6B1` | Kill actor linked in `$06` | Parent tears down a specific child |
| `$AA` | `StageMoveX` | `$00A6C1` | Stage X force-move duration | Push/pull without a full `$80` anim stage |
| `$AB` | `StageMoveY` | `$00A6D7` | Stage Y force-move duration | Push/pull without a full `$80` anim stage |
| `$AC` | `StageMoveXY` | `$00A6ED` | Stage X+Y force-move durations | Push/pull without a full `$80` anim stage |
| `$AD` | `ForceDirSW` | `$00A713` | Force SW via `$12` bit `$4000` | Make `$81`–`$87` move the “wrong” way |
| `$AE` | `ForceDirNE` | `$00A731` | Force NE via `$12` bit `$2000` | Make `$81`–`$87` move the “wrong” way |
| `$AF` | `ForceDirBoth` | `$00A74F` | Force both via `$12` bits `$6000` | Make `$81`–`$87` move the “wrong” way |
| `$B0` | `ApplyMoveToChild` | `$00A76D` | Apply durations to last child (`$0058`) | Parent drives child’s slide |
| `$B1` | `ReloadMoveDurations` | `$00A799` | Reload `$2C/$2E` from saved durations | Resume a saved force-move |

`$E0` vs `$A7`: cutscene one-shots almost always `$E0`. Boss pieces that must finish an explosion frame use `$A7`.

---

### 3.20 OAM / priority / position (`$B2`–`$BC`)

| Op | Name | Handler | Effect |
|---|---|---|---|
| `$B2` | `SetPriorityMax` | `$00A7B3` | Set `$10` bit `$0002` (max collision-priority) |
| `$B3` | `SetPriorityMin` | `$00A7BE` | Set `$10` bit `$0001` (min collision-priority) |
| `$B4` | `ClearPriorityMax` | `$00A7C9` | Clear `$10` bit `$0002` |
| `$B5` | `ClearPriorityMin` | `$00A7D4` | Clear `$10` bit `$0001` |
| `$B6` | `SetOamPriority` | `$00A7DF` | `Byte` → `$0E` priority (`$3000`) — draw above/below BG |
| `$B7` | `SetOamPalette` | `$00A7F4` | `Byte` → `$0E` palette (`$0E00`) |
| `$B8` | `ToggleHMirror` | `$00A809` | Toggle H-mirror in `$0E` |
| `$B9` | `ToggleVMirror` | `$00A816` | Toggle V-mirror in `$0E` |
| `$BA` | `ClearHMirror` | `$00A823` | Clear H-mirror |
| `$BB` | `SetHMirror` | `$00A82E` | Set H-mirror |
| `$BC` | `NudgePosition` | `$00A839` | `Byte dX, Byte dY` — nudge `$14/$16` immediately (signed) |

**Usage:** `$BC` is the cheap “stand 8px to the left of the pedestal” adjust (`COP [BC] ( #08, #00 )` on the Incan statue). `$B6`/`$B7` recolor or layer-sort without restaging a sprite. `$B8`/`$BB` face left/right for walk cycles.

---

### 3.21 Dialogue / BG3 (`$BD`–`$BF`)

#### `$BD` — `RunBg3Script`
- **Handler:** `cop_handler_BD_00A867`
- **Params:** `Address Script` (word + bank)
- **Does:** Run a BG3 command stream via `func_03EA62` (ASCII overlays, not wide dialogue).
- **Usage:** Title “PUSH START BUTTON”, credits, inventory HUD labels (`sFC_actor_0BC924`, `inventory_menu.asm`). Distinct from `$BF`.

#### `$BF` — `PrintWideString`
- **Handler:** `cop_handler_BF_00A8FB`
- **Params:** `&WideString` (near ptr to tagged dialogue)
- **Does:** Print a dialogue box (`sub_03E255`); masks joypad; frame-syncs. Continues after the string finishes (no choice menu).
- **Usage:** Every NPC line. Often followed by `$BE` when the text ends with a question.

#### `$BE` — `DialogueOptions` *(halt)*
- **Handler:** `cop_handler_BE_00A894`
- **Params (assembler):** `Byte OptCounts`, `Byte SkipLines`, `&&Code OptionsTable`
- **ASM:** packs the two bytes as a config `Word` for `func_03E849`, then a `Word` jump-table base.
- **Does:**
  1. If `$0654 ≠ $000F` (world not ready), rewind and RTL (retry next frame).
  2. Run the choice UI; player selection index × 2 indexes the table.
  3. `RTI` to the chosen `&Code`.
- **Table layout:**

```asm
COP [BF] ( &intro_text )
COP [BE] ( #02, #02, &options )  ; 2 choices, skip 2 lines of prior text
options [
  &cancel    ; index 0 — also used for B/cancel in many scripts
  &cancel    ; index 1
  &confirm   ; index 2
]
```

Must print the box with `$BF` (or `$19`) first so the option rows line up with `SkipLines`.

---

### 3.22 Script control (`$C0`–`$CB`, `$E1`–`$E2`)

These are the actor “VM” primitives. Think of `$00`/`$02` as the program counter the engine resumes next frame, and `$7F0004` as a return stack slot.

| Op | Name | Handler | Params | Behavior | Typical use |
|---|---|---|---|---|---|
| `$C0` | `SetInteractHandler` | `$00A9EB` | `&Code` | Store interact handler in `$7F000A` | “When player talks, run this” |
| `$C1` | `SetEntryHere` | `$00A9FB` | — | EntryPtr = **here**, continue | Landmark before `RTL` idle loop |
| `$C2` | `SetEntryHereAndYield` | `$00AA07` | — | EntryPtr = here, **RTL** | Same landmark, yield immediately |
| `$C3` | `JumpAfterDelay` | `$00AA13` | `@Code`, `Word Delay` | Jump there after Delay frames | Timed cutscene beat |
| `$C4` | `JumpNextFrame` | `$00AA30` | `@Code` | EntryPtr = there, `$08=0`, RTL | Switch AI state, resume next frame |
| `$C5` | `RestoreSavedPtr` | `$00AA60` | — | Restore SavedPtr (RTL if empty) | Return from `$C8`/`$C9` call |
| `$C6` | `SetSavedPtr` | `$00AA8B` | `&Code` | Set SavedPtr only | Prep return without jumping yet |
| `$C7` | `JumpFar` | `$00AA9B` | `@Code` | Jump there **now** (like `JML`) | Hard goto another bank/label |
| `$C8` | `CallNear` | `$00AAB6` | `&Code` | JSR: SavedPtr=next, jump now | Call a walk subroutine |
| `$C9` | `CallNearDeferred` | `$00AAC6` | `&Code` | Delayed JSR: SavedPtr=next, EntryPtr=sub, RTL | Call next frame |
| `$CA` | `LoopStart` | `$00AAD8` | `Byte` | Start counted loop | Repeat a walk segment N times |
| `$CB` | `LoopEnd` | `$00AB0E` | — | Decrement and loop back | Repeat a walk segment N times |
| `$E1` | `ReturnWithSignal` | `$00AA74` | — | `$C5` + `A=$FFFF` | Return and signal “came from call” |
| `$E2` | `SetEntryFar` | `$00AA47` | `@Code` | Set EntryPtr for later, keep going | Arm a resume point without yielding |

**Idle park:**

```asm
COP [C0] ( &talk )
COP [C1]
RTL          ; every frame: enter at C1, fall to RTL, repeat
```

**Call / return (slipper AI):**

```asm
COP [C8] ( &code_0AE5C8 )  ; “JSR” walk pattern
BRA code_0AE4AF            ; after $C5 inside the callee, resume loop
; …
; inside callee, end with:
COP [C5]                   ; return to SavedPtr
```

**State switch:**

```asm
COP [C4] ( @code_0AE487 )  ; next frame start at chase/idle label
```

**Loop a bit of motion:**

```asm
COP [CA] ( #02 )
  COP [C1]
  ; … one step …
COP [CB]                   ; RTL back to CA body until count=0
```

Loop counters live in `$7F0014/$7F001E` (large actor ids) or `$7F2102/$7F2100` (small).

---

### 3.23 Scene flags (`$CC`–`$D3`)

Persistent story bits in `$0A00` (`sub_00B0B7` set, `sub_00B0D8` clear, `sub_00B0FB` test). Byte ops cover flags `0..$FF`; word ops allow the extended range used by map rearrangements (`#$011D`, etc.).

| Op | Name | Handler | Params | Behavior |
|---|---|---|---|---|
| `$CC` | `SetFlagByte` | `$00AB41` | `Byte Flag` | Set bit |
| `$CD` | `SetFlagWord` | `$00AB51` | `Word Flag` | Set bit |
| `$CE` | `ClearFlagByte` | `$00AB60` | `Byte Flag` | Clear bit |
| `$CF` | `ClearFlagWord` | `$00AB70` | `Word Flag` | Clear bit |
| `$D0` | `BranchOnFlagByte` | `$00AB7F` | `Byte Flag`, `Byte Val`, `&Code` | **Branch** if flag == Val (`0` or `1`) |
| `$D1` | `BranchOnFlagWord` | `$00AB8E` | `Word Flag`, `Byte Val`, `&Code` | **Branch** if flag == Val |
| `$D2` | `WaitOnFlagByte` | `$00ABC2` | `Byte Flag`, `Byte Val` | **Wait/exit** while flag == Val (retry each frame) |
| `$D3` | `WaitOnFlagWord` | `$00ABD7` | `Word Flag`, `Byte Val` | **Wait/exit** while flag == Val |

**Polarity:** `Val=#00` means “branch/wait when flag is **clear**”; `Val=#01` when **set**.

```asm
; Despawn if already done
COP [D0] ( #8D, #00, &already_done )  ; if flag 8D clear → die path
; …
already_done:
    COP [E0]

; Block until another actor sets the flag
COP [D2] ( #48, #01 )   ; spin until flag 48 is set
COP [32] ( #1D )
COP [33]

; Record progress
COP [CC] ( #48 )
```

`$D0` falls into `$D1`’s compare tail; `$D2` into `$D3`.

---

### 3.24 Inventory (`$D4`–`$D7`)

Slots start at `$AB4`; equipped index in `$AC4`. `func_03EF97` handles both normal items and special ids ≥`$80` (gold/HP/herbs/etc.).

| Op | Name | Handler | Params | Behavior |
|---|---|---|---|---|
| `$D4` | `GiveItem` | `$00AC05` | `Byte ItemId`, `&Code OnFail` | Try to **give**; branch on SEC (full / failed) |
| `$D5` | `RemoveItem` | `$00AC27` | `Byte ItemId` | Remove matching slot |
| `$D6` | `BranchIfMissingItem` | `$00AC38` | `Byte ItemId`, `&Code` | Branch if player **does not** have it |
| `$D7` | `BranchIfItemEquipped` | `$00AC5A` | `Byte ItemId`, `&Code` | Branch if that item is **equipped** |

```asm
; it1B_inca_statue_b.asm — give statue or complain
code_04FADF {
    COP [D4] ( #04, &code_04FAF4 )  ; fail → inventory-full text
    COP [CC] ( #48 )                ; success → set story flag
    COP [19] ( #17, @widestring_… ) ; jingle + text
    RTL
}
code_04FAF4 {
    COP [BF] ( &widestring_full )
    RTL
}
```

Note `$D6`’s polarity: it branches when the item is **missing**, so “if has item, skip ahead” is fallthrough.

---

### 3.25 Switch / wait / camera / die (`$D8`–`$E0`)

#### `$D8` — `SetDungeonKillFlag`
- **Handler:** `cop_handler_D8_00AC82`
- **Params:** none
- **Does:** If this actor’s dungeon monster id `$7F0022,X ≠ 0`, set its bit in `$0A80` so it stays dead across room reloads.
- **Usage:** End of enemy death scripts (often automatic via death rearrange; also callable manually).

#### `$D9` — `SwitchCase`
- **Handler:** `cop_handler_D9_00AC94`
- **Params:** `Word IndexAddr`, `&&Code JmpList`
- **Does:** Read byte at `IndexAddr`, then `PC = JmpList[index×2]`.
- **Usage:** AI / dialogue random picks. Slipper stores RNG into `$0000` then:

```asm
STA $0000
COP [D9] ( #$0000, &code_list_0AE4D7 )
code_list_0AE4D7 [
  &walk_a
  &walk_b
  &walk_c
  &walk_d
]
```

`IndexAddr` is a **24-bit bank-0 WRAM/absolute address** as a word (commonly `$0000` DP scratch).

#### `$DA` — `WaitByte` / `$DB` — `WaitWord`
- **Handlers:** `cop_handler_DA_00ACC1` / `cop_handler_DB_00ACD6`
- **Params:** `Byte` or `Word` frame count → `$08`
- **Does:** Set EntryPtr to the byte after the COP, store delay, **RTL**. Runner decrements `$08` each frame; at 0 it resumes.
- **Usage:** Pace cutscenes. `#3B` ≈ 1 second at 60fps; `#$0120` for long holds (boss intros). `$DA ( #00 )` is a one-frame yield (common between spawns).

```asm
COP [DA] ( #1D )
COP [04] ( #1B )
COP [DB] ( #$0120 )
```

#### `$DC`–`$DF` — Camera pan waits

Autoscroll helpers used by the overworld / forced-walk engine (`chunk_00E683.asm`), not by random NPCs.

| Op | Name | Handler | Direction | Updates | Finishes when |
|---|---|---|---|---|---|
| `$DC` | `CameraPanDown` | `$00ACDF` | Down | `$06C2 += step` | `$06C2 ≥ camera_bounds_y` |
| `$DD` | `CameraPanUp` | `$00AD17` | Up | `$06C2 -= step` | `$06C2 ≤ camera_offset_y` |
| `$DE` | `CameraPanRight` | `$00AD57` | Right | `$06BE += step` | `$06BE ≥ camera_bounds_x` |
| `$DF` | `CameraPanLeft` | `$00AD8F` | Left | `$06BE -= step` | `$06BE ≤ camera_offset_x` |

**How they’re driven:**

1. Caller loads a step-speed index into `$06E0` (from `table_01A95E`).
2. Clears actor `$2A`, then `$C1` + one of `$DC`–`$DF`.
3. Each frame: `$2A` countdown; when 0, `sub_00B136` reloads step from `$06E0/$06E2`; accumulate into camera X/Y.
4. RTI while panning; RTL when the bound is reached — script continues (usually restore joypad and `$E0`).

```asm
; chunk_00E683.asm — forced camera scroll south
LDA $&table_01A95E, X
STA $06E0
STZ $2A
COP [C1]
COP [DC]          ; blocks here until camera hits south bound
JSR $&sub_00ED68
COP [E0]
```

#### `$E0` — `Die`
- **Handler:** `cop_handler_E0_00A5F7`
- **Params:** none
- **Does:** Unlink from the actor list and tear down immediately (`cop_handler_E0_00A5F7`). If `$12` bit `$0040` (has marked children), takes the deferral path shared with `$A7`.
- **Usage:** Default end of intro actors, despawn after flag check, kill self when conversation warps away. After `$E0` the script never resumes.

---

## 4. Invalid / phantom opcodes

| Opcode | Why |
|---|---|
| `$6E`, `$6F` | Jump table lands in `cop_junk_008561`; copdef empty phantoms |
| `$70`–`$7F` | Same junk gap; absent from copdef |
| `$E3` | Past `cop_table2` end; copdef empty phantom |

Executing these would jump to garbage and crash.

---

## 5. Corrections vs prior sources

### 5.1 Data Crystal wiki

| Topic | Wiki | ASM |
|---|---|---|
| `$4C`–`$4E` | Unknown | Metatile draw / world-map record streams |
| `$96`–`$98` | Unused | Live wall-type anim gates (need `$94`) |
| `$A6` | Broken | Functional; copdef layout wrong |
| `$DC`–`$DF` | Obscure globals | Camera pan wait loops |
| `$69` | Exit if `$00E4 < Min` | Halt when `Min ≥ $00E4` |
| `$4F` arg order | Vram then Size | Size then VramDest |
| `$3E`/`$3F` | “Exit if …” | Wait-until via rewind+RTL |
| `$09` | Tempo modifier | Raw `APUIO1` write |

### 5.2 `us/copdef.json`

| Opcode | Issue |
|---|---|
| `$03` | Should be `Byte, Address, Byte` |
| `$2C` | Correct as two `&Code` (no leading Word) |
| `$31` | `size:10` / five `&Code` — only **four** targets used |
| `$6E`,`$6F`,`$E3` | Phantom — remove or mark invalid |
| `$88`,`$BD`,`$C3`,`$C4`,`$C7`,`$E2` | Far ptrs need explicit bank byte in parts |
| `$A6` | Wrong part order/types |
| `$BE` | Assembler `Byte,Byte,&&Code` packs to Word+Word — OK for tooling; document both views |
| Dual-`&Code` listings | Most branches are single `&Code` + fallthrough |

### 5.3 Naming note on `$15`/`$16`

Screen Y increases downward: `$15` probes `Y−$10` = **north**, `$16` probes `Y+$10` = **south** (matches wiki).

---

## 6. Complete handler reference

Every valid COP opcode, its canonical name, handler SNES address, and parameter signature.

| Op | Name | Handler | Params |
|---|---|---|---|
| `$00` | `GenHdmaSine` | `$00864E` | — |
| `$01` | `QueueHdma` | `$008689` | `@dma_data Src`, `Byte Reg` |
| `$02` | `QueueDma` | `$0086A0` | `@dma_data Src`, `Byte Reg` |
| `$03` | `QueueHdmaChannel` | `$0086B7` | `Byte Channel`, `Address Src`, `Byte Reg` |
| `$04` | `StartMusic` | `$008714` | `Byte MusicId` |
| `$05` | `FadeThenStartMusic` | `$008749` | `Byte MusicId` |
| `$06` | `PlaySoundCh2` | `$00877E` | `Byte SoundId` |
| `$07` | `PlaySoundCh1` | `$008792` | `Byte SoundId` |
| `$08` | `PlaySoundBoth` | `$0087A6` | `Word` (low=ch1, high=ch2) |
| `$09` | `WriteApuIo1` | `$0087B5` | `Byte` |
| `$0A` | `WriteApuIo0` | `$0087C9` | `Byte` |
| `$0B` | `MarkSolidHere` | `$008876` | — |
| `$0C` | `ClearSolidHere` | `$00888C` | — |
| `$0D` | `MarkSolidOffset` | `$0088A2` | `Byte dX`, `Byte dY` |
| `$0E` | `ClearSolidOffset` | `$0088C8` | `Byte dX`, `Byte dY` |
| `$0F` | `MarkSolidAbs` | `$0088EE` | `Byte tileX`, `Byte tileY` |
| `$10` | `ClearSolidAbs` | `$008925` | `Byte tileX`, `Byte tileY` |
| `$11` | `ClearCollisionHere` | `$00895C` | — |
| `$12` | `ClearTypeAbs` | `$008975` | `Byte tileX`, `Byte tileY` |
| `$13` | `BranchIfSolidHere` | `$0089AC` | `&Code` |
| `$14` | `BranchIfSolidOffset` | `$0089D3` | `Byte dX`, `Byte dY`, `&Code` |
| `$15` | `BranchIfSolidNorth` | `$008A22` | `&Code` |
| `$16` | `BranchIfSolidSouth` | `$008A4D` | `&Code` |
| `$17` | `BranchIfSolidWest` | `$008A78` | `&Code` |
| `$18` | `BranchIfSolidEast` | `$008AA3` | `&Code` |
| `$19` | `MusicAndText` | `$0087DD` | `Byte MusicId`, `@WideString Text` |
| `$1A` | `BranchIfTypeHere` | `$008ACE` | `Byte Type`, `&Code` |
| `$1B` | `BranchIfTypeNorth` | `$008B01` | `Byte Type`, `&Code` |
| `$1C` | `BranchIfTypeSouth` | `$008B38` | `Byte Type`, `&Code` |
| `$1D` | `BranchIfTypeWest` | `$008B6F` | `Byte Type`, `&Code` |
| `$1E` | `BranchIfTypeEast` | `$008BA6` | `Byte Type`, `&Code` |
| `$1F` | `BranchIfNotOnGridline` | `$008BDD` | `&Code` |
| `$20` | `BranchIfActorNear` | `$008C19` | `Byte AcNum`, `Byte Dist`, `&Code` |
| `$21` | `BranchIfPlayerNear` | `$008C26` | `Byte Dist`, `&Code` |
| `$22` | `MoveToward` | `$008C6F` | `Byte SpriteId`, `Byte Speed` |
| `$23` | `RngByte` | `$008FFC` | — |
| `$24` | `RngMod` | `$00902B` | `Byte Max` |
| `$25` | `SetTilePos` | `$00904E` | `Byte tileX`, `Byte tileY` |
| `$26` | `QueueMapChange` | `$009072` | `Byte MapNum`, `Word PosX`, `Word PosY`, `Byte DirAndSave`, `Word CamBounds` |
| `$27` | `WaitWhileOffscreen` | `$0090CE` | `Byte Delay` |
| `$28` | `BranchIfPlayerAt` | `$0090F4` | `Word PosX`, `Word PosY`, `&Code` |
| `$29` | `BranchIfActorAt` | `$0090FA` | `Byte AcNum`, `Word PosX`, `Word PosY`, `&Code` |
| `$2A` | `BranchOnPlayerX` | `$009135` | `Word Dist`, `&Code West`, `&Code East`, `&Code Here` |
| `$2B` | `BranchOnPlayerY` | `$00915F` | `Word Dist`, `&Code North`, `&Code South`, `&Code Here` |
| `$2C` | `BranchNearerAxis` | `$009189` | `&Code NearY`, `&Code NearX` |
| `$2D` | `DirToPlayer` | `$0091B8` | — |
| `$2E` | `DirToPlayerFrom` | `$009236` | `Byte OffsX`, `Byte OffsY` |
| `$2F` | `BranchIfDirToPlayer` | `$00926A` | `Byte Dir`, `&Code` |
| `$30` | `BranchIfDirToPlayerFrom` | `$009299` | `Byte OffsX`, `Byte OffsY`, `Byte Dir`, `&Code` |
| `$31` | `BranchOnPlayerFacing` | `$0092E8` | `&Code S`, `&Code N`, `&Code W`, `&Code E` |
| `$32` | `StageBgChange` | `$009317` | `Byte BgChg` |
| `$33` | `ApplyBgChange` | `$009328` | — |
| `$34` | `StageBgChangeFromDeathIdx` | `$009352` | — |
| `$35` | `CardinalToPlayer` | `$0091CC` | — |
| `$36` | `PaletteRestart` | `$009361` | — |
| `$37` | `PaletteStart` | `$009364` | `Byte Bundle` |
| `$38` | `PaletteStartLoop` | `$009381` | `Byte Bundle`, `Byte Iters` |
| `$39` | `PaletteStep` | `$0093AA` | — |
| `$3A` | `PaletteStepLoop` | `$0093CE` | — |
| `$3B` | `SpawnThinkerParam` | `$009400` | `Byte Param`, `@Code Entry` |
| `$3C` | `SpawnThinker` | `$00943C` | `@Code Entry` |
| `$3D` | `KillThinker` | `$009443` | — |
| `$3E` | `WaitForButton` | `$009485` | `Word Mask` |
| `$3F` | `WaitForRelease` | `$0094AD` | `Word Mask` |
| `$40` | `BranchIfPressed` | `$0094D5` | `Word Mask`, `&Code` |
| `$41` | `BranchIfNotPressed` | `$009501` | `Word Mask`, `&Code` |
| `$42` | `SetCollisionAbs` | `$00952F` | `Byte tileX`, `Byte tileY`, `Byte Type` |
| `$43` | `SnapToGrid` | `$008DE6` | — |
| `$44` | `BranchIfPlayerInRelTiles` | `$00956B` | `Byte XLeft, YUp, XRight, YDown`, `&Code` |
| `$45` | `BranchIfPlayerInAbsTiles` | `$0095EA` | `Byte XLeft, YTop, XRight, YBot`, `&Code` |
| `$46` | `CopyPosToPrev` | `$009647` | — |
| `$47` | `CopyPosToNext` | `$00964C` | — |
| `$48` | `GetPlayerFacing` | `$00965E` | — |
| `$49` | `BranchIfBodyNe` | `$009668` | `Byte Body`, `&Code` |
| `$4A` | `ResumeAfterSnap` | `$008E19` | — |
| `$4B` | `DrawMetatileAbs` | `$009685` | `Byte tileX`, `Byte tileY`, `Byte Metatile` |
| `$4C` | `DrawMetatileHere` | `$0096CA` | `Byte Metatile` |
| `$4D` | `WorldMapStream3` | `$009703` | `Word DataOffset` |
| `$4E` | `WorldMapStream4` | `$009774` | `Word DataOffset` |
| `$4F` | `AdhocVramDma` | `$0098B8` | `Address Src`, `Word Size`, `Word VramWord` |
| `$50` | `CopyPalette` | `$009930` | `Address Src`, `Byte OffsW`, `Byte PalWord`, `Byte SizeW` |
| `$51` | `Decompress` | `$00997B` | `Address Src`, `Address Dest` |
| `$52` | `StageMove` | `$008E36` | `Byte SpriteId`, `Byte Speed`, `Byte MaxTime` |
| `$53` | `TickMove` | `$008F0D` | — |
| `$54` | `SetScratchPointer` | `$0099BF` | `Address` |
| `$55` | `ResetSpriteState` | `$0099DA` | `Byte Spr`, `Word New24` |
| `$56` | `AdvanceSpriteAnim` | `$0099F5` | — |
| `$57` | `SetDeathCallback` | `$009A67` | `@Code OnDeath` |
| `$58` | `SetHitCallback` | `$009A82` | `&Code OnHit` |
| `$59` | `SetDodgeCallback` | `$009A92` | `&Code Dodge` |
| `$5A` | `SetCollideCallback` | `$009AA2` | `&Code OnCollide` |
| `$5B` | `OrExtraFlags` | `$009AC2` | `Word Mask` |
| `$5C` | `AndExtraFlags` | `$009AD6` | `Word Mask` |
| `$5D` | `BranchIfBehindWall` | `$009AEA` | `&Code` |
| `$5E` | `SetCustomCallback` | `$009AB2` | `&Code` |
| `$5F` | `InitSineHdma` | `$009B89` | `Word Base`, `Byte BytesPerPeriod` |
| `$60` | `TickSineHdma` | `$009C3A` | `Byte Delay`, `Byte ScrollLayer` |
| `$61` | `BindSineHdma` | `$009C91` | `Address Src`, `Byte Reg` |
| `$62` | `BranchIfCollisionTypeNe` | `$009B41` | `Byte Nibble`, `&Code` |
| `$63` | `InitGravity` | `$009CB4` | `Byte InitSpeed`, `Byte NegLogA`, `Byte GndTilePos` |
| `$64` | `TickGravity` | `$009CFA` | — |
| `$65` | `StageWorldMapMove` | `$009D52` | `Word PosX`, `Word PosY`, `Byte Dummy`, `Byte WMapMoveId` |
| `$66` | `StageWorldMapChoice` | `$009D81` | `Word PosX`, `Word PosY`, `Byte WMapOptsId` |
| `$67` | `StageWorldMapMoveIds` | `$009DA3` | `Byte Dummy`, `Byte WMapMoveId` |
| `$68` | `BranchIfOffCamera` | `$009DBD` | `&Code` |
| `$69` | `HaltIfMaxFrames` | `$009DEA` | `Word Min` |
| `$6A` | `SetLinkedEntryPtr` | `$009E06` | `&Code` |
| `$6B` | `PrintWideStringAlt` | `$00A958` | `&WideString` |
| `$6C` | `InitSpiral` | `$00A992` | `Byte Angle`, `Byte Diameter` |
| `$6D` | `SpiralStep` | `$00A9AE` | `Byte DiameterSpeed`, `Byte AngleSpeed` |
| | | | |
| `$80` | `StageSpr` | `$009E23` | `Byte Spr` |
| `$81` | `StageSprX` | `$009E35` | `Byte Spr`, `Byte XMove` |
| `$82` | `StageSprY` | `$009E57` | `Byte Spr`, `Byte YMove` |
| `$83` | `StageSprXY` | `$009E79` | `Byte Spr`, `Byte XMove`, `Byte YMove` |
| `$84` | `StageSprLoop` | `$009EAB` | `Byte Spr`, `Byte Iters` |
| `$85` | `StageSprLoopX` | `$009EC8` | `Byte Spr`, `Byte Iters`, `Byte XMove` |
| `$86` | `StageSprLoopY` | `$009EF5` | `Byte Spr`, `Byte Iters`, `Byte YMove` |
| `$87` | `StageSprLoopXY` | `$009F22` | `Byte Spr`, `Byte Iters`, `Byte XMove`, `Byte YMove` |
| `$88` | `SetMetasprite` | `$009F8F` | `@&sprite_set` |
| `$89` | `AnimOnce` | `$009FAA` | — |
| `$8A` | `AnimLoop` | `$009FC0` | — |
| `$8B` | `AnimOneFrame` | `$009FDE` | — |
| `$8C` | `WaitForAnimFrame` | `$009FF1` | `Byte SprFrame` |
| `$8D` | `StageSprAndHitbox` | `$00A01E` | `Byte Spr` |
| `$8E` | `SetPlayerSpriteDirect` | `$00A036` | `Byte PlayerSpr` |
| `$8F` | `StagePlayerSpr` | `$00A06B` | `Byte BodySpr` |
| `$90` | `StagePlayerSprX` | `$00A081` | `Byte BodySpr`, `Byte XMove` |
| `$91` | `StagePlayerSprY` | `$00A0A7` | `Byte BodySpr`, `Byte YMove` |
| `$92` | `StagePlayerSprXY` | `$00A0CD` | `Byte BodySpr`, `Byte XMove`, `Byte YMove` |
| `$93` | `RunPlayerAnim` | `$00A103` | — |
| `$94` | `StagePlayerSprWall` | `$00A119` | `…`, `Byte WallType` |
| `$95` | `StagePlayerSprFromDP` | `$00A159` | — |
| `$96` | `WallAnimHere` | `$00A16E` | `Word` |
| `$97` | `WallAnimNorth` | `$00A1B5` | `Word` |
| `$98` | `WallAnimSouth` | `$00A200` | `Word` |
| `$99` | `SpawnBefore` | `$00A24B` | `@Code` |
| `$9A` | `SpawnBeforeFlags` | `$00A267` | `@Code`, `Word New10` |
| `$9B` | `SpawnAfter` | `$00A28C` | `@Code` |
| `$9C` | `SpawnAfterFlags` | `$00A2A8` | `@Code`, `Word New10` |
| `$9D` | `SpawnAfterOffset` | `$00A2CD` | `@Code`, `Word OffsX`, `Word OffsY` |
| `$9E` | `SpawnAfterOffsetFlags` | `$00A303` | offs + `New10` |
| `$9F` | `SpawnAfterAbs` | `$00A342` | `@Code`, `Word AbsX`, `Word AbsY` |
| `$A0` | `SpawnAfterAbsFlags` | `$00A370` | abs + `New10` |
| `$A1` | `SpawnBeforeMarked` | `$00A3A7` | `@Code`, `Word New10` |
| `$A2` | `SpawnAfterMarked` | `$00A3D4` | `@Code`, `Word New10` |
| `$A3` | `SpawnAfterAbsMarked` | `$00A401` | abs + `New10` |
| `$A4` | `SpawnAfterOffsetMarked` | `$00A440` | `Byte OffsX/Y` + `New10` |
| `$A5` | `SpawnListAppend` | `$00A499` | `Byte OffsX/Y` + `New10` |
| `$A6` | `SpawnListAppendSpr` | `$00A533` | + `Byte Spr` |
| `$A7` | `MarkDeath` | `$00A5DE` | — |
| `$A8` | `KillPrev` | `$00A6A1` | — |
| `$A9` | `KillNext` | `$00A6B1` | — |
| `$AA` | `StageMoveX` | `$00A6C1` | `Byte XMove` |
| `$AB` | `StageMoveY` | `$00A6D7` | `Byte YMove` |
| `$AC` | `StageMoveXY` | `$00A6ED` | `Byte XMove`, `Byte YMove` |
| `$AD` | `ForceDirSW` | `$00A713` | `Byte` |
| `$AE` | `ForceDirNE` | `$00A731` | `Byte` |
| `$AF` | `ForceDirBoth` | `$00A74F` | `Byte` |
| `$B0` | `ApplyMoveToChild` | `$00A76D` | `Byte XMove`, `Byte YMove` |
| `$B1` | `ReloadMoveDurations` | `$00A799` | — |
| `$B2` | `SetPriorityMax` | `$00A7B3` | — |
| `$B3` | `SetPriorityMin` | `$00A7BE` | — |
| `$B4` | `ClearPriorityMax` | `$00A7C9` | — |
| `$B5` | `ClearPriorityMin` | `$00A7D4` | — |
| `$B6` | `SetOamPriority` | `$00A7DF` | `Byte` |
| `$B7` | `SetOamPalette` | `$00A7F4` | `Byte` |
| `$B8` | `ToggleHMirror` | `$00A809` | — |
| `$B9` | `ToggleVMirror` | `$00A816` | — |
| `$BA` | `ClearHMirror` | `$00A823` | — |
| `$BB` | `SetHMirror` | `$00A82E` | — |
| `$BC` | `NudgePosition` | `$00A839` | `Byte dX`, `Byte dY` |
| `$BD` | `RunBg3Script` | `$00A867` | `Address Script` |
| `$BE` | `DialogueOptions` | `$00A894` | `Byte OptCounts`, `Byte SkipLines`, `&&Code` |
| `$BF` | `PrintWideString` | `$00A8FB` | `&WideString` |
| `$C0` | `SetInteractHandler` | `$00A9EB` | `&Code` |
| `$C1` | `SetEntryHere` | `$00A9FB` | — |
| `$C2` | `SetEntryHereAndYield` | `$00AA07` | — |
| `$C3` | `JumpAfterDelay` | `$00AA13` | `@Code`, `Word Delay` |
| `$C4` | `JumpNextFrame` | `$00AA30` | `@Code` |
| `$C5` | `RestoreSavedPtr` | `$00AA60` | — |
| `$C6` | `SetSavedPtr` | `$00AA8B` | `&Code` |
| `$C7` | `JumpFar` | `$00AA9B` | `@Code` |
| `$C8` | `CallNear` | `$00AAB6` | `&Code` |
| `$C9` | `CallNearDeferred` | `$00AAC6` | `&Code` |
| `$CA` | `LoopStart` | `$00AAD8` | `Byte` |
| `$CB` | `LoopEnd` | `$00AB0E` | — |
| `$CC` | `SetFlagByte` | `$00AB41` | `Byte Flag` |
| `$CD` | `SetFlagWord` | `$00AB51` | `Word Flag` |
| `$CE` | `ClearFlagByte` | `$00AB60` | `Byte Flag` |
| `$CF` | `ClearFlagWord` | `$00AB70` | `Word Flag` |
| `$D0` | `BranchOnFlagByte` | `$00AB7F` | `Byte Flag`, `Byte Val`, `&Code` |
| `$D1` | `BranchOnFlagWord` | `$00AB8E` | `Word Flag`, `Byte Val`, `&Code` |
| `$D2` | `WaitOnFlagByte` | `$00ABC2` | `Byte Flag`, `Byte Val` |
| `$D3` | `WaitOnFlagWord` | `$00ABD7` | `Word Flag`, `Byte Val` |
| `$D4` | `GiveItem` | `$00AC05` | `Byte ItemId`, `&Code OnFail` |
| `$D5` | `RemoveItem` | `$00AC27` | `Byte ItemId` |
| `$D6` | `BranchIfMissingItem` | `$00AC38` | `Byte ItemId`, `&Code` |
| `$D7` | `BranchIfItemEquipped` | `$00AC5A` | `Byte ItemId`, `&Code` |
| `$D8` | `SetDungeonKillFlag` | `$00AC82` | — |
| `$D9` | `SwitchCase` | `$00AC94` | `Word IndexAddr`, `&&Code JmpList` |
| `$DA` | `WaitByte` | `$00ACC1` | `Byte` |
| `$DB` | `WaitWord` | `$00ACD6` | `Word` |
| `$DC` | `CameraPanDown` | `$00ACDF` | — |
| `$DD` | `CameraPanUp` | `$00AD17` | — |
| `$DE` | `CameraPanRight` | `$00AD57` | — |
| `$DF` | `CameraPanLeft` | `$00AD8F` | — |
| `$E0` | `Die` | `$00A5F7` | — |
| `$E1` | `ReturnWithSignal` | `$00AA74` | — |
| `$E2` | `SetEntryFar` | `$00AA47` | `@Code` |

---

## 7. Sources

1. **Primary:** `extracted/system/chunk_008000.asm` — `native_mode_cop_handler_00846D`, `cop_table_008485`, `cop_table2_008585`, every `cop_handler_*`
2. **Related:** `extracted/system/chunk_03BAE1.asm` — `func_03E1AA`/`func_03E1D6` (music), `func_03F0CA` (facing), text/DMA helpers
3. **Tooling schema:** `us/copdef.json`
4. **Secondary notes:** [Data Crystal Illusion of Gaia / Notes § Actor code](https://datacrystal.tcrf.net/wiki/Illusion_of_Gaia/Notes#Actor_code)
5. **Patch insight:** `baserom/patches/Cop51Patch.patch.asm` (`$51` extended decompress/copy)

Handler labels follow the pattern `cop_handler_XX_AAAAAA` where `AAAAAA` is the SNES address in bank `$00`/`$80`.
