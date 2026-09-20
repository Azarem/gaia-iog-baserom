# Illusion of Gaia — COP system overview

_Canonical docs for all **209 COP opcodes** (`$00`–`$6D`, `$80`–`$E2`). Family pages live under [`families/`](families/)._

## Overview

Illusion of Gaia scene logic is driven by **actors** and **thinkers**: scripted objects that execute 65816 code peppered with **COP** (Coprocessor) instructions. COP opcodes are dispatched through `CopDispatch` at `$00846D` → jump tables `cop_dispatch_table` at `$008485` (primary, 110 entries) and `$008585` (extended, 99 entries). Operand layouts are declared in `db-us/copdef.json`.

- COP opcodes defined: **209** (110 primary + 99 extended)
- Invalid gap: **$6E–$7F** (18 garbage pointers in `cop_junk_008561`)
- Phantom entries: **$6E**, **$6F**, **$E3** (listed in copdef with empty parts)
- Handler source: `extracted/system/engine/cop_handlers_*.asm` (14 files)
- Jump table: `extracted/system/engine/cop_dispatch.asm`

## Dispatch architecture

Native COP (`$02`) vectors to `CopDispatch` at `$00846D`:

1. Saves actor index in `Y`, restores `X = ActorID`, sets DP.
2. Sets `ArgPtr` (`$0A`) to the COP opcode byte, bank context in `$0C`.
3. Reads the opcode byte, advances `$0A` past it, doubles it, and jumps through the dispatch table.

```asm
JMP ($&cop_dispatch_table, X)   ; X = opcode × 2
```

| Opcode range | Table | Status |
|---|---|---|
| `$00`–`$6D` | `cop_dispatch_table` (110 entries) | Valid |
| `$6E`–`$7F` | `cop_junk_008561` | **Invalid** (garbage pointers) |
| `$80`–`$E2` | Extended table at `$008585` (99 entries) | Valid |
| `$E3`+ | Past end | **Invalid** |

### Entrancy state

All COP handlers enter with:

| Register | Value |
|---|---|
| `m=0, x=0, d=0, i=1` | 16-bit A/X/Y, interrupts enabled |
| `X = D = ActorID` | Direct page = actor slot base |
| `DBR = $81` | Script/data bank |
| `$0A` / `$0C` | Arg pointer / script bank |

### Control-flow outcomes

| Outcome | Mechanism | Typical use |
|---|---|---|
| **Continue** | `$0A → $02,S` then `RTI` | Fall through after operand consumption |
| **Branch** | Load `&Code` into `$02,S`, `RTI` | Conditional jump (taken) |
| **Halt / yield** | Rewind `$0A` (or set `$00`/`$08`), `PLA PLA RTL` | Wait frames, buttons, animation, DMA |
| **Exit actor** | Unlink + `RTL`/`RTS` | Death (`$E0`), thinker free |

### Parameter types

| Token | Size | Meaning |
|---|---|---|
| `Byte` | 1 | Unsigned 8-bit |
| `Word` | 2 | Unsigned 16-bit |
| `&Code` | 2 | Near script address (current bank) |
| `&&Code` | 2 | Pointer to a word table of `&Code`s |
| `@Code` / `Address` | 3 | Far pointer (word + bank byte) |
| `@DialogString` / `&DialogString` | 3 / 2 | Text pointer |
| `@dma_data` | 3 | DMA source far pointer |
| `@&sprite_set` | 3 | Metasprite table far pointer |

---

## Instruction families (`$00`–`$E2`)

Families are grouped by **shared handlers / purpose / WRAM**, not by jump-table order. Several false neighbors are called out below.

| Family | Ops | Doc | Handler source |
|--------|-----|-----|----------------|
| **HDMA / DMA** | `00` `01` `02` `03` | [hdma_dma.md](families/hdma_dma.md) | `cop_handlers_solid.asm` |
| **Audio (music + SFX)** | `04` `05` `06` `07` `08` `09` `0A` `19` | [audio.md](families/audio.md) | `cop_handlers_audio.asm` |
| **Collision paint** | `0B` `0C` `0D` `0E` `0F` `10` `11` `12` `42` | [collision_paint.md](families/collision_paint.md) | `cop_handlers_solid.asm` |
| **Collision branch** | `13` `14` `15` `16` `17` `18` `1A` `1B` `1C` `1D` `1E` `62` | [collision_branch.md](families/collision_branch.md) | `cop_handlers_solid.asm` |
| **Proximity / area** | `1F` `20` `21` `44` `45` | [proximity.md](families/proximity.md) | `cop_handlers_movement.asm`, `cop_handlers_lifecycle.asm` |
| **Movement / staged** | `22` `43` `4A` `52` `53` | [movement.md](families/movement.md) | `cop_handlers_movement.asm` |
| **RNG** | `23` `24` | [rng.md](families/rng.md) | `cop_handlers_movement.asm` |
| **Position** | `25` `46` `47` `BC` | [position.md](families/position.md) | `cop_handlers_spatial.asm`, `cop_handlers_lifecycle.asm` |
| **Map transition** | `26` `65` `66` `67` | [map_transition.md](families/map_transition.md) | `cop_handlers_spatial.asm`, `cop_handlers_input.asm` |
| **Offscreen** | `27` `68` `69` | [offscreen.md](families/offscreen.md) | `cop_handlers_spatial.asm`, `cop_handlers_lifecycle.asm` |
| **Player query** | `28` `29` `2A` `2B` `2C` `2D` `2E` `2F` `30` `31` `35` `48` `49` | [player_query.md](families/player_query.md) | `cop_handlers_spatial.asm`, `cop_handlers_lifecycle.asm` |
| **BG rearrange** | `32` `33` `34` | [bg_rearrange.md](families/bg_rearrange.md) | `cop_handlers_palette.asm` |
| **Palette** | `36` `37` `38` `39` `3A` | [palette.md](families/palette.md) | `cop_handlers_palette.asm` |
| **Thinkers** | `3B` `3C` `3D` | [thinkers.md](families/thinkers.md) | `cop_handlers_palette.asm` |
| **Input** | `3E` `3F` `40` `41` | [input.md](families/input.md) | `cop_handlers_input.asm` |
| **Metatile / world map draw** | `4B` `4C` `4D` `4E` | [metatile.md](families/metatile.md) | `cop_handlers_map.asm` |
| **VRAM / memory** | `4F` `50` `51` `54` | [vram_memory.md](families/vram_memory.md) | `cop_handlers_map.asm` |
| **Sprite state** | `55` `56` | [sprite_state.md](families/sprite_state.md) | `cop_handlers_lifecycle.asm` |
| **Callbacks** | `57` `58` `59` `5A` `5E` | [callbacks.md](families/callbacks.md) | `cop_handlers_lifecycle.asm` |
| **Actor flags** | `5B` `5C` `5D` | [actor_flags.md](families/actor_flags.md) | `cop_handlers_lifecycle.asm` |
| **Sine HDMA** | `5F` `60` `61` | [sine_hdma.md](families/sine_hdma.md) | `cop_handlers_effects.asm` |
| **Gravity** | `63` `64` | [gravity.md](families/gravity.md) | `cop_handlers_effects.asm` |
| **Dialog** | `6B` `BD` `BE` `BF` | [dialog.md](families/dialog.md) | `cop_handlers_input.asm` |
| **Linked actor** | `6A` | [linked_actor.md](families/linked_actor.md) | `cop_handlers_lifecycle.asm` |
| **Spiral / orbit** | `6C` `6D` | [spiral.md](families/spiral.md) | `cop_handlers_effects.asm` |
| **Sprite staging** | `80` `81` `82` `83` `84` `85` `86` `87` `8D` | [sprite_staging.md](families/sprite_staging.md) | `cop_handlers_sprite.asm` |
| **Sprite animation** | `88` `89` `8A` `8B` `8C` | [sprite_anim.md](families/sprite_anim.md) | `cop_handlers_sprite.asm` |
| **Player sprite** | `8E` `8F` `90` `91` `92` `93` `94` `95` `96` `97` `98` | [player_sprite.md](families/player_sprite.md) | `cop_handlers_player_sprite.asm` |
| **Actor spawn** | `99` `9A` `9B` `9C` `9D` `9E` `9F` `A0` `A1` `A2` `A3` `A4` `A5` `A6` | [actor_spawn.md](families/actor_spawn.md) | `cop_handlers_spawn.asm` |
| **Actor death** | `A7` `A8` `A9` `E0` | [actor_death.md](families/actor_death.md) | `cop_handlers_lifecycle.asm`, `cop_handlers_flow.asm` |
| **Force move** | `AA` `AB` `AC` `AD` `AE` `AF` `B0` `B1` | [force_move.md](families/force_move.md) | `cop_handlers_lifecycle.asm` |
| **OAM attributes** | `B2` `B3` `B4` `B5` `B6` `B7` `B8` `B9` `BA` `BB` | [oam_attribs.md](families/oam_attribs.md) | `cop_handlers_lifecycle.asm` |
| **Script control** | `C0` `C1` `C2` `C3` `C4` `C5` `C6` `C7` `C8` `C9` `CA` `CB` `E1` `E2` | [script_control.md](families/script_control.md) | `cop_handlers_flow.asm` |
| **Scene flags** | `CC` `CD` `CE` `CF` `D0` `D1` `D2` `D3` | [scene_flags.md](families/scene_flags.md) | `cop_handlers_flow.asm` |
| **Inventory** | `D4` `D5` `D6` `D7` | [inventory.md](families/inventory.md) | `cop_handlers_flow.asm` |
| **Dungeon / switch** | `D8` `D9` | [dungeon_switch.md](families/dungeon_switch.md) | `cop_handlers_flow.asm` |
| **Wait** | `DA` `DB` | [wait.md](families/wait.md) | `cop_handlers_flow.asm` |
| **Camera** | `DC` `DD` `DE` `DF` | [camera.md](families/camera.md) | `cop_handlers_effects.asm` |
| **Invalid ops** | `6E`–`7F`, `E3` | [invalid_ops.md](families/invalid_ops.md) | — |

### False neighbors (do not merge)

| Adjacent opcodes | Why they are different families |
|---|---|
| `$0A` ↔ `$0B` | `WriteApuIo0` (APU port) vs `MarkSolidHere` (collision paint) |
| `$12` ↔ `$13` | `ClearTypeAbs` (collision paint) vs `BranchIfSolidHere` (collision branch) — write vs read |
| `$18` ↔ `$19` | `BranchIfSolidEast` (collision) vs `MusicAndText` (audio) — adjacent opcodes, unrelated systems |
| `$1E` ↔ `$1F` | `BranchIfTypeEast` (collision) vs `BranchIfNotOnGridline` (proximity/grid) |
| `$21` ↔ `$22` | `BranchIfPlayerNear` (proximity test) vs `MoveToward` (movement execution) |
| `$24` ↔ `$25` | `RngMod` (random) vs `SetTilePos` (position) |
| `$27` ↔ `$28` | `WaitWhileOffscreen` (offscreen halt) vs `BranchIfPlayerAt` (player query) |
| `$31` ↔ `$32` | `BranchOnPlayerFacing` (player query) vs `StageBgChange` (BG rearrange) |
| `$3A` ↔ `$3B` | `PaletteStepLoop` (palette) vs `SpawnThinkerParam` (thinker lifecycle) |
| `$3D` ↔ `$3E` | `KillThinker` (thinker) vs `WaitForButton` (input) |
| `$41` ↔ `$42` | `BranchIfNotPressed` (input) vs `SetCollisionAbs` (collision paint) |
| `$49` ↔ `$4A` | `BranchIfBodyNe` (player query) vs `ResumeAfterSnap` (movement) |
| `$4E` ↔ `$4F` | `WorldMapStream4` (metatile) vs `AdhocVramDma` (VRAM) |
| `$56` ↔ `$57` | `AdvanceSpriteAnim` (sprite state) vs `SetDeathCallback` (callbacks) |
| `$5E` ↔ `$5F` | `SetCustomCallback` (callbacks) vs `InitSineHdma` (sine HDMA) |
| `$62` ↔ `$63` | `BranchIfCollisionTypeNe` (collision branch) vs `InitGravity` (gravity) |
| `$67` ↔ `$68` | `StageWorldMapMoveIds` (map transition) vs `BranchIfOffCamera` (offscreen) |
| `$6A` ↔ `$6B` | `SetLinkedEntryPtr` (linked actor) vs `PrintDialogStringAlt` (dialog) |
| `$6D` ↔ `$6E` | `SpiralStep` (spiral) vs garbage jump table entries |
| `$8D` ↔ `$8E` | `StageSprAndHitbox` (sprite staging) vs `SetPlayerSpriteDirect` (player sprite) |
| `$98` ↔ `$99` | `WallAnimSouth` (player sprite) vs `SpawnBefore` (actor spawn) |
| `$A6` ↔ `$A7` | `SpawnListAppendSpr` (spawn) vs `MarkDeath` (death) |
| `$A9` ↔ `$AA` | `KillNext` (death) vs `StageMoveX` (force move) |
| `$B1` ↔ `$B2` | `ReloadMoveDurations` (force move) vs `SetPriorityMax` (OAM) |
| `$BB` ↔ `$BC` | `SetHMirror` (OAM) vs `NudgePosition` (position family) |
| `$BC` ↔ `$BD` | `NudgePosition` (position) vs `RunBg3Script` (dialog) |
| `$BF` ↔ `$C0` | `PrintDialogString` (dialog) vs `SetInteractHandler` (script control) |
| `$CB` ↔ `$CC` | `LoopEnd` (script control) vs `SetFlagByte` (scene flags) |
| `$D3` ↔ `$D4` | `WaitOnFlagWord` (scene flags) vs `GiveItem` (inventory) |
| `$D7` ↔ `$D8` | `BranchIfItemEquipped` (inventory) vs `SetDungeonKillFlag` (dungeon) |
| `$D9` ↔ `$DA` | `SwitchCase` (dungeon/switch) vs `WaitByte` (wait) |
| `$DB` ↔ `$DC` | `WaitWord` (wait) vs `CameraPanDown` (camera) |
| `$DF` ↔ `$E0` | `CameraPanLeft` (camera) vs `Die` (actor death) |
| `$E0` ↔ `$E1` | `Die` (actor death) vs `ReturnWithSignal` (script control) |

---

## Important actor memory (COP-related)

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
| `$7F0004,X` | SavedPtr (return from calls) |
| `$7F000A,X` | OnInteract / music id |
| `$7F001C,X` | Parent id (marked children) |
| `$7F002A,X` | Extra flags |
| `$7F1000+` | Hit / dodge / die / collide callbacks |

---

## Common script idioms

### Idle NPC (register interact, park forever)

```asm
COP [D0] ( #8D, #00, &already_done )  ; if flag clear → die
COP [C0] ( &interact_handler )        ; register chat handler
COP [0B]                              ; mark tile solid
COP [C1]                              ; EntryPtr = here
RTL                                   ; yield; engine re-enters at C1 each frame
```

### Stage sprite, then animate

```asm
COP [84] ( #14, #22 )   ; stage anim #14, loop $22 times
COP [8A]                 ; run until loops done
COP [85] ( #19, #04, #11 )
COP [8A]                 ; stage+run with X movement
```

### Talk → choices → warp

```asm
COP [BF] ( &intro_text )           ; print dialogue box
COP [BE] ( #02, #02, &options )    ; 2 choices, skip 2 lines
options [
  &cancel
  &cancel
  &confirm
]
confirm:
    COP [65] ( #$00D4, #$03A4, #00, #23 )  ; stage world-map move
    COP [26] ( #78, #$0160, #$0268, #07, #$4500 )
    RTL
```

### Gate on story flag

```asm
COP [D0] ( #8D, #00, &done )  ; branch if flag $8D clear
; ... alive path ...
done:
    COP [E0]                   ; die
```

### One-shot cutscene actor

```asm
COP [DA] ( #1D )     ; wait ~30 frames
COP [04] ( #1B )     ; start music
COP [DA] ( #3B )     ; wait ~1 second
COP [BF] ( &text )   ; show dialogue
COP [E0]             ; remove self when done
```

### AI switch on RNG

```asm
COP [C6] ( &ai_loop_head )          ; SavedPtr = loop top
COP [23]                             ; RNG → A
AND #$0003
STA $0000
COP [D9] ( #$0000, &behavior_list ) ; switch on [$0000]
behavior_list [
  &walk_a    ; 00
  &walk_b    ; 01
  &walk_c    ; 02
  &walk_d    ; 03
]
```

`$D9` reads a **RAM byte** at the given address and indexes a near jump table.

---

## Branch encoding

Almost all "branch if …" COPs take a single `&Code`. **Taken** → jump to that absolute address. **Not taken** → skip the 2-byte pointer and continue. Agents/docs that list a second "else `&Code`" are describing fallthrough, not a second operand.

**`&Code` vs `@Code`:**
- `&Code` — 16-bit address in the current script bank (`$0C`). 2 bytes.
- `@Code` / `Address` — far pointer: word + bank byte (3 bytes) unless noted.

---

## Design notes

### Move byte encoding

The `Byte XMove` / `Byte YMove` operands in sprite staging (`$80`–`$87`) and force move (`$AA`–`$AC`) are **speed/duration indices** into `table_01B086`, not raw pixel values. `AnimFrameLookup` maps the index to a frame duration stored in `$2C`/`$2E`. Direction comes from `$12` force bits (`$AD`–`$AF`) and H-mirror.

### `New10` spawn flags

Common `Word New10` values used in spawn ops (`$9A`, `$9C`, `$9E`, `$A0`–`$A4`):

| Value | Meaning |
|-------|---------|
| `#$1800` | Interactable + continue-during-dialogue |
| `#$2000` | Disable render/collision (hidden helper / wait-loop actor) |
| `#$2800` | `$2000` + `$0800` (hidden + keep acting in dialogue) |

### Loop counter locations

`LoopStart` (`$CA`) / `LoopEnd` (`$CB`) store iteration state in `$7F0014/$7F001E` (large actor ids) or `$7F2102/$7F2100` (small ids), not in a dedicated register.

### Flag polarity

`BranchOnFlagByte`/`Word` (`$D0`/`$D1`) and `WaitOnFlagByte`/`Word` (`$D2`/`$D3`): `Val=#00` means "branch/wait when flag is **clear**"; `Val=#01` means "when **set**".

### `Decompress` patch extension

`$51` (`Decompress`) was extended by `baserom/patches/Cop51Patch.patch.asm`: size>0 → decompress via `QuintetLzDecompress`; size=0 → `MVN $2000`; size<0 → raw `MVN |size|−1`.

---

## Corrections vs prior sources

### Data Crystal wiki

| Topic | Wiki claim | ASM reality |
|---|---|---|
| `$4C`–`$4E` | Unknown | Metatile draw / world-map record streams |
| `$96`–`$98` | Unused | Live wall-type anim gates (need `$94`) |
| `$A6` | Broken | Functional; copdef part order was wrong |
| `$DC`–`$DF` | Obscure globals | Camera pan wait loops for forced-walk engine |
| `$69` | Exit if `$00E4 < Min` | Halt when `Min ≥ $00E4` (off-by-one vs `BCC`) |
| `$4F` arg order | VramDest then Size | Size then VramDest |
| `$3E`/`$3F` | "Exit if …" | Wait-until via rewind+RTL |
| `$09` | Tempo modifier | Raw `APUIO1` write |

### copdef.json (corrected)

| Opcode | Issue (now fixed) |
|---|---|
| `$03` | Was `Byte, Word, Word` → corrected to `Byte, Address, Byte` |
| `$31` | Was `size:10` / five `&Code` → corrected to `size:8` / four `&Code` |
| `$6E`/`$6F`/`$E3` | Phantom — empty parts, no handlers |
| `$A6` | Part order corrected to match ROM layout |
| Many ops | Renamed for clarity (see `copdef.json` diff in commit history) |

### `$15`/`$16` naming

Screen Y increases downward: `$15` probes `Y−$10` = **north**, `$16` probes `Y+$10` = **south** (matches wiki naming).

---

## Sources

1. **Primary:** `extracted/system/engine/cop_dispatch.asm` — dispatch tables
2. **Handler ASM:** `extracted/system/engine/cop_handlers_*.asm` (14 files)
3. **Tooling schema:** `db-us/copdef.json`
4. **Secondary:** [Data Crystal — Illusion of Gaia / Notes § Actor code](https://datacrystal.tcrf.net/wiki/Illusion_of_Gaia/Notes#Actor_code)
5. **Patches:** `baserom/patches/Cop51Patch.patch.asm` (`$51` extended decompress/copy)

---

## Opcode roster (`$00`–`$E2`)

| Op | Name | Params | Family |
|----|------|--------|--------|
| `$00` | `GenHdmaSine` | — | [hdma_dma](families/hdma_dma.md) |
| `$01` | `QueueHdma` | `@dma_data, Byte` | [hdma_dma](families/hdma_dma.md) |
| `$02` | `QueueDma` | `@dma_data, Byte` | [hdma_dma](families/hdma_dma.md) |
| `$03` | `QueueHdmaChannel` | `Byte, Address, Byte` | [hdma_dma](families/hdma_dma.md) |
| `$04` | `StartMusic` | `Byte` | [audio](families/audio.md) |
| `$05` | `FadeThenStartMusic` | `Byte` | [audio](families/audio.md) |
| `$06` | `PlaySoundCh2` | `Byte` | [audio](families/audio.md) |
| `$07` | `PlaySoundCh1` | `Byte` | [audio](families/audio.md) |
| `$08` | `PlaySoundBoth` | `Word` | [audio](families/audio.md) |
| `$09` | `WriteApuIo1` | `Byte` | [audio](families/audio.md) |
| `$0A` | `WriteApuIo0` | `Byte` | [audio](families/audio.md) |
| `$0B` | `MarkSolidHere` | — | [collision_paint](families/collision_paint.md) |
| `$0C` | `ClearSolidHere` | — | [collision_paint](families/collision_paint.md) |
| `$0D` | `MarkSolidOffset` | `Byte dX, Byte dY` | [collision_paint](families/collision_paint.md) |
| `$0E` | `ClearSolidOffset` | `Byte dX, Byte dY` | [collision_paint](families/collision_paint.md) |
| `$0F` | `MarkSolidAbs` | `Byte tileX, Byte tileY` | [collision_paint](families/collision_paint.md) |
| `$10` | `ClearSolidAbs` | `Byte tileX, Byte tileY` | [collision_paint](families/collision_paint.md) |
| `$11` | `ClearCollisionHere` | — | [collision_paint](families/collision_paint.md) |
| `$12` | `ClearTypeAbs` | `Byte tileX, Byte tileY` | [collision_paint](families/collision_paint.md) |
| `$13` | `BranchIfSolidHere` | `&Code` | [collision_branch](families/collision_branch.md) |
| `$14` | `BranchIfSolidOffset` | `Byte dX, Byte dY, &Code` | [collision_branch](families/collision_branch.md) |
| `$15` | `BranchIfSolidNorth` | `&Code` | [collision_branch](families/collision_branch.md) |
| `$16` | `BranchIfSolidSouth` | `&Code` | [collision_branch](families/collision_branch.md) |
| `$17` | `BranchIfSolidWest` | `&Code` | [collision_branch](families/collision_branch.md) |
| `$18` | `BranchIfSolidEast` | `&Code` | [collision_branch](families/collision_branch.md) |
| `$19` | `MusicAndText` | `Byte, @DialogString` | [audio](families/audio.md) |
| `$1A` | `BranchIfTypeHere` | `Byte Type, &Code` | [collision_branch](families/collision_branch.md) |
| `$1B` | `BranchIfTypeNorth` | `Byte Type, &Code` | [collision_branch](families/collision_branch.md) |
| `$1C` | `BranchIfTypeSouth` | `Byte Type, &Code` | [collision_branch](families/collision_branch.md) |
| `$1D` | `BranchIfTypeWest` | `Byte Type, &Code` | [collision_branch](families/collision_branch.md) |
| `$1E` | `BranchIfTypeEast` | `Byte Type, &Code` | [collision_branch](families/collision_branch.md) |
| `$1F` | `BranchIfNotOnGridline` | `&Code` | [proximity](families/proximity.md) |
| `$20` | `BranchIfActorNear` | `Byte AcNum, Byte Dist, &Code` | [proximity](families/proximity.md) |
| `$21` | `BranchIfPlayerNear` | `Byte Dist, &Code` | [proximity](families/proximity.md) |
| `$22` | `MoveToward` | `Byte SpriteId, Byte Speed` | [movement](families/movement.md) |
| `$23` | `RngByte` | — | [rng](families/rng.md) |
| `$24` | `RngMod` | `Byte Max` | [rng](families/rng.md) |
| `$25` | `SetTilePos` | `Byte tileX, Byte tileY` | [position](families/position.md) |
| `$26` | `QueueMapChange` | `Byte, Word, Word, Byte, Word` | [map_transition](families/map_transition.md) |
| `$27` | `WaitWhileOffscreen` | `Byte Delay` | [offscreen](families/offscreen.md) |
| `$28` | `BranchIfPlayerAt` | `Word PosX, Word PosY, &Code` | [player_query](families/player_query.md) |
| `$29` | `BranchIfActorAt` | `Byte AcNum, Word PosX, Word PosY, &Code` | [player_query](families/player_query.md) |
| `$2A` | `BranchOnPlayerX` | `Word Dist, &Code W, &Code E, &Code H` | [player_query](families/player_query.md) |
| `$2B` | `BranchOnPlayerY` | `Word Dist, &Code N, &Code S, &Code H` | [player_query](families/player_query.md) |
| `$2C` | `BranchNearerAxis` | `&Code NearY, &Code NearX` | [player_query](families/player_query.md) |
| `$2D` | `DirToPlayer` | — | [player_query](families/player_query.md) |
| `$2E` | `DirToPlayerFrom` | `Byte OffsX, Byte OffsY` | [player_query](families/player_query.md) |
| `$2F` | `BranchIfDirToPlayer` | `Byte Dir, &Code` | [player_query](families/player_query.md) |
| `$30` | `BranchIfDirToPlayerFrom` | `Byte OffsX, Byte OffsY, Byte Dir, &Code` | [player_query](families/player_query.md) |
| `$31` | `BranchOnPlayerFacing` | `&Code S, &Code N, &Code W, &Code E` | [player_query](families/player_query.md) |
| `$32` | `StageBgChange` | `Byte BgChg` | [bg_rearrange](families/bg_rearrange.md) |
| `$33` | `ApplyBgChange` | — | [bg_rearrange](families/bg_rearrange.md) |
| `$34` | `StageBgChangeFromDeathIdx` | — | [bg_rearrange](families/bg_rearrange.md) |
| `$35` | `CardinalToPlayer` | — | [player_query](families/player_query.md) |
| `$36` | `PaletteRestart` | — | [palette](families/palette.md) |
| `$37` | `PaletteStart` | `Byte Bundle` | [palette](families/palette.md) |
| `$38` | `PaletteStartLoop` | `Byte Bundle, Byte Iters` | [palette](families/palette.md) |
| `$39` | `PaletteStep` | — | [palette](families/palette.md) |
| `$3A` | `PaletteStepLoop` | — | [palette](families/palette.md) |
| `$3B` | `SpawnThinkerParam` | `Byte Param, @Code Entry` | [thinkers](families/thinkers.md) |
| `$3C` | `SpawnThinker` | `@Code Entry` | [thinkers](families/thinkers.md) |
| `$3D` | `KillThinker` | — | [thinkers](families/thinkers.md) |
| `$3E` | `WaitForButton` | `Word Mask` | [input](families/input.md) |
| `$3F` | `WaitForRelease` | `Word Mask` | [input](families/input.md) |
| `$40` | `BranchIfPressed` | `Word Mask, &Code` | [input](families/input.md) |
| `$41` | `BranchIfNotPressed` | `Word Mask, &Code` | [input](families/input.md) |
| `$42` | `SetCollisionAbs` | `Byte tileX, Byte tileY, Byte Type` | [collision_paint](families/collision_paint.md) |
| `$43` | `SnapToGrid` | — | [movement](families/movement.md) |
| `$44` | `BranchIfPlayerInRelTiles` | `Byte×4, &Code` | [proximity](families/proximity.md) |
| `$45` | `BranchIfPlayerInAbsTiles` | `Byte×4, &Code` | [proximity](families/proximity.md) |
| `$46` | `CopyPosToPrev` | — | [position](families/position.md) |
| `$47` | `CopyPosToNext` | — | [position](families/position.md) |
| `$48` | `GetPlayerFacing` | — | [player_query](families/player_query.md) |
| `$49` | `BranchIfBodyNe` | `Byte Body, &Code` | [player_query](families/player_query.md) |
| `$4A` | `ResumeAfterSnap` | — | [movement](families/movement.md) |
| `$4B` | `DrawMetatileAbs` | `Byte tileX, Byte tileY, Byte Metatile` | [metatile](families/metatile.md) |
| `$4C` | `DrawMetatileHere` | `Byte Metatile` | [metatile](families/metatile.md) |
| `$4D` | `WorldMapStream3` | `Word DataOffset` | [metatile](families/metatile.md) |
| `$4E` | `WorldMapStream4` | `Word DataOffset` | [metatile](families/metatile.md) |
| `$4F` | `AdhocVramDma` | `Address Src, Word Size, Word VramWord` | [vram_memory](families/vram_memory.md) |
| `$50` | `CopyPalette` | `Address Src, Byte OffsW, Byte PalWord, Byte SizeW` | [vram_memory](families/vram_memory.md) |
| `$51` | `Decompress` | `Address Src, Address Dest` | [vram_memory](families/vram_memory.md) |
| `$52` | `StageMove` | `Byte SpriteId, Byte Speed, Byte MaxTime` | [movement](families/movement.md) |
| `$53` | `TickMove` | — | [movement](families/movement.md) |
| `$54` | `SetScratchPointer` | `Address` | [vram_memory](families/vram_memory.md) |
| `$55` | `ResetSpriteState` | `Byte Spr, Word New24` | [sprite_state](families/sprite_state.md) |
| `$56` | `AdvanceSpriteAnim` | — | [sprite_state](families/sprite_state.md) |
| `$57` | `SetDeathCallback` | `@Code OnDeath` | [callbacks](families/callbacks.md) |
| `$58` | `SetHitCallback` | `&Code OnHit` | [callbacks](families/callbacks.md) |
| `$59` | `SetDodgeCallback` | `&Code Dodge` | [callbacks](families/callbacks.md) |
| `$5A` | `SetCollideCallback` | `&Code OnCollide` | [callbacks](families/callbacks.md) |
| `$5B` | `OrExtraFlags` | `Word Mask` | [actor_flags](families/actor_flags.md) |
| `$5C` | `AndExtraFlags` | `Word Mask` | [actor_flags](families/actor_flags.md) |
| `$5D` | `BranchIfBehindWall` | `&Code` | [actor_flags](families/actor_flags.md) |
| `$5E` | `SetCustomCallback` | `&Code` | [callbacks](families/callbacks.md) |
| `$5F` | `InitSineHdma` | `Word Base, Byte BytesPerPeriod` | [sine_hdma](families/sine_hdma.md) |
| `$60` | `TickSineHdma` | `Byte Delay, Byte ScrollLayer` | [sine_hdma](families/sine_hdma.md) |
| `$61` | `BindSineHdma` | `Address Src, Byte Reg` | [sine_hdma](families/sine_hdma.md) |
| `$62` | `BranchIfCollisionTypeNe` | `Byte Nibble, &Code` | [collision_branch](families/collision_branch.md) |
| `$63` | `InitGravity` | `Byte InitSpeed, Byte NegLogA, Byte GndTilePos` | [gravity](families/gravity.md) |
| `$64` | `TickGravity` | — | [gravity](families/gravity.md) |
| `$65` | `StageWorldMapMove` | `Word PosX, Word PosY, Byte Dummy, Byte WMapMoveId` | [map_transition](families/map_transition.md) |
| `$66` | `StageWorldMapChoice` | `Word PosX, Word PosY, Byte WMapOptsId` | [map_transition](families/map_transition.md) |
| `$67` | `StageWorldMapMoveIds` | `Byte Dummy, Byte WMapMoveId` | [map_transition](families/map_transition.md) |
| `$68` | `BranchIfOffCamera` | `&Code` | [offscreen](families/offscreen.md) |
| `$69` | `HaltIfMaxFrames` | `Word Min` | [offscreen](families/offscreen.md) |
| `$6A` | `SetLinkedEntryPtr` | `&Code` | [linked_actor](families/linked_actor.md) |
| `$6B` | `PrintDialogStringAlt` | `&DialogString` | [dialog](families/dialog.md) |
| `$6C` | `InitSpiral` | `Byte Angle, Byte Diameter` | [spiral](families/spiral.md) |
| `$6D` | `SpiralStep` | `Byte DiameterSpeed, Byte AngleSpeed` | [spiral](families/spiral.md) |
| | | | |
| `$80` | `StageSpr` | `Byte Spr` | [sprite_staging](families/sprite_staging.md) |
| `$81` | `StageSprX` | `Byte Spr, Byte XMove` | [sprite_staging](families/sprite_staging.md) |
| `$82` | `StageSprY` | `Byte Spr, Byte YMove` | [sprite_staging](families/sprite_staging.md) |
| `$83` | `StageSprXY` | `Byte Spr, Byte XMove, Byte YMove` | [sprite_staging](families/sprite_staging.md) |
| `$84` | `StageSprLoop` | `Byte Spr, Byte Iters` | [sprite_staging](families/sprite_staging.md) |
| `$85` | `StageSprLoopX` | `Byte Spr, Byte Iters, Byte XMove` | [sprite_staging](families/sprite_staging.md) |
| `$86` | `StageSprLoopY` | `Byte Spr, Byte Iters, Byte YMove` | [sprite_staging](families/sprite_staging.md) |
| `$87` | `StageSprLoopXY` | `Byte Spr, Byte Iters, Byte XMove, Byte YMove` | [sprite_staging](families/sprite_staging.md) |
| `$88` | `SetMetasprite` | `@&sprite_set` | [sprite_anim](families/sprite_anim.md) |
| `$89` | `AnimOnce` | — | [sprite_anim](families/sprite_anim.md) |
| `$8A` | `AnimLoop` | — | [sprite_anim](families/sprite_anim.md) |
| `$8B` | `AnimOneFrame` | — | [sprite_anim](families/sprite_anim.md) |
| `$8C` | `WaitForAnimFrame` | `Byte SprFrame` | [sprite_anim](families/sprite_anim.md) |
| `$8D` | `StageSprAndHitbox` | `Byte Spr` | [sprite_staging](families/sprite_staging.md) |
| `$8E` | `SetPlayerSpriteDirect` | `Byte PlayerSpr` | [player_sprite](families/player_sprite.md) |
| `$8F` | `StagePlayerSpr` | `Byte BodySpr` | [player_sprite](families/player_sprite.md) |
| `$90` | `StagePlayerSprX` | `Byte BodySpr, Byte XMove` | [player_sprite](families/player_sprite.md) |
| `$91` | `StagePlayerSprY` | `Byte BodySpr, Byte YMove` | [player_sprite](families/player_sprite.md) |
| `$92` | `StagePlayerSprXY` | `Byte BodySpr, Byte XMove, Byte YMove` | [player_sprite](families/player_sprite.md) |
| `$93` | `RunPlayerAnim` | — | [player_sprite](families/player_sprite.md) |
| `$94` | `StagePlayerSprWall` | `…, Byte WallType` | [player_sprite](families/player_sprite.md) |
| `$95` | `StagePlayerSprFromDP` | — | [player_sprite](families/player_sprite.md) |
| `$96` | `WallAnimHere` | `Word` | [player_sprite](families/player_sprite.md) |
| `$97` | `WallAnimNorth` | `Word` | [player_sprite](families/player_sprite.md) |
| `$98` | `WallAnimSouth` | `Word` | [player_sprite](families/player_sprite.md) |
| `$99` | `SpawnBefore` | `@Code` | [actor_spawn](families/actor_spawn.md) |
| `$9A` | `SpawnBeforeFlags` | `@Code, Word New10` | [actor_spawn](families/actor_spawn.md) |
| `$9B` | `SpawnAfter` | `@Code` | [actor_spawn](families/actor_spawn.md) |
| `$9C` | `SpawnAfterFlags` | `@Code, Word New10` | [actor_spawn](families/actor_spawn.md) |
| `$9D` | `SpawnAfterOffset` | `@Code, Word OffsX, Word OffsY` | [actor_spawn](families/actor_spawn.md) |
| `$9E` | `SpawnAfterOffsetFlags` | `@Code, Word OffsX, Word OffsY, Word New10` | [actor_spawn](families/actor_spawn.md) |
| `$9F` | `SpawnAfterAbs` | `@Code, Word AbsX, Word AbsY` | [actor_spawn](families/actor_spawn.md) |
| `$A0` | `SpawnAfterAbsFlags` | `@Code, Word AbsX, Word AbsY, Word New10` | [actor_spawn](families/actor_spawn.md) |
| `$A1` | `SpawnBeforeMarked` | `@Code, Word New10` | [actor_spawn](families/actor_spawn.md) |
| `$A2` | `SpawnAfterMarked` | `@Code, Word New10` | [actor_spawn](families/actor_spawn.md) |
| `$A3` | `SpawnAfterAbsMarked` | `@Code, Word AbsX, Word AbsY, Word New10` | [actor_spawn](families/actor_spawn.md) |
| `$A4` | `SpawnAfterOffsetMarked` | `@Code, Byte OffsX, Byte OffsY, Word New10` | [actor_spawn](families/actor_spawn.md) |
| `$A5` | `SpawnListAppend` | `@Code, Byte OffsX, Byte OffsY, Word New10` | [actor_spawn](families/actor_spawn.md) |
| `$A6` | `SpawnListAppendSpr` | `@Code, Byte bank, Byte Spr, Byte OffsX, Byte OffsY, Word New10` | [actor_spawn](families/actor_spawn.md) |
| `$A7` | `MarkDeath` | — | [actor_death](families/actor_death.md) |
| `$A8` | `KillPrev` | — | [actor_death](families/actor_death.md) |
| `$A9` | `KillNext` | — | [actor_death](families/actor_death.md) |
| `$AA` | `StageMoveX` | `Byte XMove` | [force_move](families/force_move.md) |
| `$AB` | `StageMoveY` | `Byte YMove` | [force_move](families/force_move.md) |
| `$AC` | `StageMoveXY` | `Byte XMove, Byte YMove` | [force_move](families/force_move.md) |
| `$AD` | `ForceDirSW` | `Byte` | [force_move](families/force_move.md) |
| `$AE` | `ForceDirNE` | `Byte` | [force_move](families/force_move.md) |
| `$AF` | `ForceDirBoth` | `Byte` | [force_move](families/force_move.md) |
| `$B0` | `ApplyMoveToChild` | `Byte XMove, Byte YMove` | [force_move](families/force_move.md) |
| `$B1` | `ReloadMoveDurations` | — | [force_move](families/force_move.md) |
| `$B2` | `SetPriorityMax` | — | [oam_attribs](families/oam_attribs.md) |
| `$B3` | `SetPriorityMin` | — | [oam_attribs](families/oam_attribs.md) |
| `$B4` | `ClearPriorityMax` | — | [oam_attribs](families/oam_attribs.md) |
| `$B5` | `ClearPriorityMin` | — | [oam_attribs](families/oam_attribs.md) |
| `$B6` | `SetOamPriority` | `Byte` | [oam_attribs](families/oam_attribs.md) |
| `$B7` | `SetOamPalette` | `Byte` | [oam_attribs](families/oam_attribs.md) |
| `$B8` | `ToggleHMirror` | — | [oam_attribs](families/oam_attribs.md) |
| `$B9` | `ToggleVMirror` | — | [oam_attribs](families/oam_attribs.md) |
| `$BA` | `ClearHMirror` | — | [oam_attribs](families/oam_attribs.md) |
| `$BB` | `SetHMirror` | — | [oam_attribs](families/oam_attribs.md) |
| `$BC` | `NudgePosition` | `Byte dX, Byte dY` | [position](families/position.md) |
| `$BD` | `RunBg3Script` | `Address Script` | [dialog](families/dialog.md) |
| `$BE` | `DialogueOptions` | `Byte OptCounts, Byte SkipLines, &&Code` | [dialog](families/dialog.md) |
| `$BF` | `PrintDialogString` | `&DialogString` | [dialog](families/dialog.md) |
| `$C0` | `SetInteractHandler` | `&Code` | [script_control](families/script_control.md) |
| `$C1` | `SetEntryHere` | — | [script_control](families/script_control.md) |
| `$C2` | `SetEntryHereAndYield` | — | [script_control](families/script_control.md) |
| `$C3` | `JumpAfterDelay` | `@Code, Word Delay` | [script_control](families/script_control.md) |
| `$C4` | `JumpNextFrame` | `@Code` | [script_control](families/script_control.md) |
| `$C5` | `RestoreSavedPtr` | — | [script_control](families/script_control.md) |
| `$C6` | `SetSavedPtr` | `&Code` | [script_control](families/script_control.md) |
| `$C7` | `JumpFar` | `@Code` | [script_control](families/script_control.md) |
| `$C8` | `CallNear` | `&Code` | [script_control](families/script_control.md) |
| `$C9` | `CallNearDeferred` | `&Code` | [script_control](families/script_control.md) |
| `$CA` | `LoopStart` | `Byte` | [script_control](families/script_control.md) |
| `$CB` | `LoopEnd` | — | [script_control](families/script_control.md) |
| `$CC` | `SetFlagByte` | `Byte Flag` | [scene_flags](families/scene_flags.md) |
| `$CD` | `SetFlagWord` | `Word Flag` | [scene_flags](families/scene_flags.md) |
| `$CE` | `ClearFlagByte` | `Byte Flag` | [scene_flags](families/scene_flags.md) |
| `$CF` | `ClearFlagWord` | `Word Flag` | [scene_flags](families/scene_flags.md) |
| `$D0` | `BranchOnFlagByte` | `Byte Flag, Byte Val, &Code` | [scene_flags](families/scene_flags.md) |
| `$D1` | `BranchOnFlagWord` | `Word Flag, Byte Val, &Code` | [scene_flags](families/scene_flags.md) |
| `$D2` | `WaitOnFlagByte` | `Byte Flag, Byte Val` | [scene_flags](families/scene_flags.md) |
| `$D3` | `WaitOnFlagWord` | `Word Flag, Byte Val` | [scene_flags](families/scene_flags.md) |
| `$D4` | `GiveItem` | `Byte ItemId, &Code OnFail` | [inventory](families/inventory.md) |
| `$D5` | `RemoveItem` | `Byte ItemId` | [inventory](families/inventory.md) |
| `$D6` | `BranchIfMissingItem` | `Byte ItemId, &Code` | [inventory](families/inventory.md) |
| `$D7` | `BranchIfItemEquipped` | `Byte ItemId, &Code` | [inventory](families/inventory.md) |
| `$D8` | `SetDungeonKillFlag` | — | [dungeon_switch](families/dungeon_switch.md) |
| `$D9` | `SwitchCase` | `Word IndexAddr, &&Code JmpList` | [dungeon_switch](families/dungeon_switch.md) |
| `$DA` | `WaitByte` | `Byte` | [wait](families/wait.md) |
| `$DB` | `WaitWord` | `Word` | [wait](families/wait.md) |
| `$DC` | `CameraPanDown` | — | [camera](families/camera.md) |
| `$DD` | `CameraPanUp` | — | [camera](families/camera.md) |
| `$DE` | `CameraPanRight` | — | [camera](families/camera.md) |
| `$DF` | `CameraPanLeft` | — | [camera](families/camera.md) |
| `$E0` | `Die` | — | [actor_death](families/actor_death.md) |
| `$E1` | `ReturnWithSignal` | — | [script_control](families/script_control.md) |
| `$E2` | `SetEntryFar` | `@Code` | [script_control](families/script_control.md) |

---

## Related documents

| Doc | Role |
|-----|------|
| [index.md](index.md) | This overview |
| [families/](families/) | Per-family deep dives (39 docs) |
| [`../code/bank00/cop-dispatch.md`](../code/bank00/cop-dispatch.md) | Dispatch engine documentation |
| `db-us/copdef.json` | Operand layouts for assembler |
| `extracted/system/engine/cop_dispatch.asm` | Dispatch + jump tables |
| `extracted/system/engine/cop_handlers_*.asm` | Handler source (14 files) |
