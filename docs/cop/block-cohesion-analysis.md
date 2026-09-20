# COP Handler Block Cohesion Analysis

_Analysis of how the 14 physical `cop_handlers_*.asm` files align with the 39 logical COP documentation families._

> **Method:** Addresses obtained via `npm run extract:lt` (line-tracked extraction), which emits `; {decimal_address}` on every instruction line — no `names.json` cross-reference needed.

---

## Summary

Of the 14 physical block files, only **4 are cohesive** (audio, player_sprite, spawn, sprite). The remaining **10 contain handlers from multiple unrelated families**, with `cop_handlers_lifecycle.asm` being the worst offender (12+ logical families in one file).

| Rating | File | Families mixed | Problem |
|--------|------|----------------|---------|
| ✅ | `cop_handlers_audio` | 1 | Perfect: all 8 ops are audio |
| ✅ | `cop_handlers_player_sprite` | 1 | Perfect: all 11 ops are player sprite |
| ✅ | `cop_handlers_spawn` | 1 | Perfect: all 14 ops are actor spawn |
| ✅ | `cop_handlers_sprite` | 3 related | Cohesive: sprite_staging + sprite_anim + sprite_state |
| ⚠️ | `cop_handlers_spatial` | 4 | Mixes position, map_transition, offscreen, player_query |
| ⚠️ | `cop_handlers_effects` | 4 | Mixes sine_hdma, gravity, spiral, camera |
| ⚠️ | `cop_handlers_movement` | 3 | Mixes movement, proximity, rng |
| ❌ | `cop_handlers_solid` | 3 | HDMA/DMA ops (`$00`–`$03`) in "solid" file |
| ❌ | `cop_handlers_palette` | 3 | BG rearrange + thinkers lumped with palette |
| ❌ | `cop_handlers_input` | 3 | World map + dialog ops in "input" file |
| ❌ | `cop_handlers_map` | 5 | VRAM/memory, actor_flags, collision_branch, offscreen mixed in |
| ❌ | `cop_handlers_flow` | 5 | Scene flags, inventory, dungeon/switch, wait lumped with script control |
| ❌ | `cop_handlers_lifecycle` | 12+ | Kitchen sink: callbacks, actor_flags, force_move, oam_attribs, position, proximity, player_query, linked_actor, actor_death all mixed |
| — | `cop_handlers_flags` | 0 COP ops | Pure utility: flag helper subroutines (no COP entry points) |

---

## Detailed file-by-file audit

### ✅ `cop_handlers_audio.asm` — PERFECT

All handlers belong to the **audio** family. Contiguous range `$8714`–`$8876`.

| Address | Handler | Doc family |
|---------|---------|------------|
| `$8714` | `StartMusic` | audio |
| `$8749` | `FadeThenStartMusic` | audio |
| `$877E` | `PlaySoundCh2` | audio |
| `$8792` | `PlaySoundCh1` | audio |
| `$87A6` | `PlaySoundBoth` | audio |
| `$87B5` | `WriteApuIo1` | audio |
| `$87C9` | `WriteApuIo0` | audio |
| `$87DD` | `MusicAndText` | audio |

**Verdict:** No changes needed.

---

### ❌ `cop_handlers_solid.asm` — INCOHERENT

Contains 3 distinct logical families plus utility helpers. The first 4 handlers are HDMA/DMA ops that have nothing to do with collision/solidity.

| Address | Handler | Doc family | Belongs here? |
|---------|---------|------------|---------------|
| `$864E` | `GenHdmaSine` | **hdma_dma** | ❌ |
| `$8689` | `QueueHdma` | **hdma_dma** | ❌ |
| `$86A0` | `QueueDma` | **hdma_dma** | ❌ |
| `$86B7` | `QueueHdmaChannel` | **hdma_dma** | ❌ |
| `$8876` | `MarkSolidHere` | collision_paint | ✅ |
| `$888C` | `ClearSolidHere` | collision_paint | ✅ |
| `$88A2` | `MarkSolidOffset` | collision_paint | ✅ |
| `$88C8` | `ClearSolidOffset` | collision_paint | ✅ |
| `$88EE` | `MarkSolidAbs` | collision_paint | ✅ |
| `$8925` | `ClearSolidAbs` | collision_paint | ✅ |
| `$895C` | `ClearCollisionHere` | collision_paint | ✅ |
| `$8975` | `ClearTypeAbs` | collision_paint | ✅ |
| `$89AC` | `BranchIfSolidHere` | collision_branch | ⚠️ related |
| `$89D3` | `BranchIfSolidOffset` | collision_branch | ⚠️ related |
| `$8A22` | `BranchIfSolidNorth` | collision_branch | ⚠️ related |
| `$8A4D` | `BranchIfSolidSouth` | collision_branch | ⚠️ related |
| `$8A78` | `BranchIfSolidWest` | collision_branch | ⚠️ related |
| `$8AA3` | `BranchIfSolidEast` | collision_branch | ⚠️ related |
| `$8ACE` | `BranchIfTypeHere` | collision_branch | ⚠️ related |
| `$8B01` | `BranchIfTypeNorth` | collision_branch | ⚠️ related |
| `$8B38` | `BranchIfTypeSouth` | collision_branch | ⚠️ related |
| `$8B6F` | `BranchIfTypeWest` | collision_branch | ⚠️ related |
| `$8BA6` | `BranchIfTypeEast` | collision_branch | ⚠️ related |
| `$8BDD` | `BranchIfNotOnGridline` | proximity | ⚠️ related |
| `$952F` | `SetCollisionAbs` | collision_paint | ✅ (gap: isolated at `$952F`) |
| `$AF8F` | `ParseSignedTileOffset` | (helper) | ✅ utility |
| `$AFCE` | `ComputeDirectionToPlayer` | (helper) | ⚠️ player-related |
| `$B29F` | `MarkCollisionRect` | (helper) | ✅ utility |
| `$B32B` | `AdvanceMapY` | (helper) | ⚠️ map-related |
| `$B345` | `ClearCollisionRect` | (helper) | ✅ utility |
| `$B3EF` | `ClearCollisionRectFull` | (helper) | ✅ utility |
| `$B43B` | `TileCollisionQuery` | (helper) | ✅ utility |

**Key problem:** `GenHdmaSine` through `QueueHdmaChannel` (`$864E`–`$86D8`) are DMA/HDMA ops that share no logic with collision. They are contiguous and immediately precede the audio block — they were likely placed here because the ROM author compiled them first in this source unit.

**Proposed rename:** `cop_handlers_collision` (collision_paint + collision_branch are closely related and share helpers)

**Proposed relocation:** Move `$864E`–`$86D8` (HDMA/DMA ops) out. Since they sit between `cop_dispatch` end (`$864E`) and `cop_handlers_audio` start (`$8714`), they could become their own block `cop_handlers_hdma_dma`.

---

### ⚠️ `cop_handlers_movement.asm` — MODERATE MISMATCH

| Address | Handler | Doc family | Belongs here? |
|---------|---------|------------|---------------|
| `$8C19` | `BranchIfActorNear` | **proximity** | ❌ |
| `$8C26` | `BranchIfPlayerNear` | **proximity** | ❌ |
| `$8C6F` | `MoveToward` | movement | ✅ |
| `$8D11` | `MoveTowardFinish` | (helper) | ✅ |
| `$8D25` | `ReadMultiplyResult` | (helper) | ✅ |
| `$8D2A` | `ReadDivideResult` | (helper) | ✅ |
| `$8D33` | `MultiplyThenDivide` | (helper) | ✅ |
| `$8D4D` | `InitSmoothMovement` | (helper) | ✅ |
| `$8DE6` | `SnapToGrid` | movement | ✅ |
| `$8E19` | `ResumeAfterSnap` | movement | ✅ |
| `$8E36` | `StageMove` | movement | ✅ |
| `$8EF1` | `HalveMovementDistance` | (helper) | ✅ |
| `$8F0D` | `TickMove` | movement | ✅ |
| `$8FBC` | `TickMoveComplete` | (helper) | ✅ |
| `$8FDC` | `MovementVelocityCompute` | (helper) | ✅ |
| `$8FFC` | `RngByte` | **rng** | ❌ |
| `$902B` | `RngMod` | **rng** | ❌ |
| `$B125` | `ResolveActorIndex` | (helper) | ✅ |
| `$B136` | `CameraScrollStepLookup` | (helper) | ⚠️ camera-related |

**Key problems:**
- `BranchIfActorNear` / `BranchIfPlayerNear` are proximity checks, not movement
- `RngByte` / `RngMod` are RNG generation, not movement
- All 4 misplaced ops are at file boundaries (first 2 and last 2 COP handlers)

**Proposed:** Keep name `cop_handlers_movement`. The proximity and RNG ops are contiguous with the movement block at ROM boundaries — they can't be split without fragmenting. Accept as minor mismatch and document.

---

### ⚠️ `cop_handlers_spatial.asm` — MODERATE MISMATCH

| Address | Handler | Doc family | Belongs here? |
|---------|---------|------------|---------------|
| `$904E` | `SetTilePos` | **position** | ⚠️ |
| `$9072` | `QueueMapChange` | **map_transition** | ❌ |
| `$90CE` | `WaitWhileOffscreen` | **offscreen** | ❌ |
| `$90F4` | `BranchIfPlayerAt` | player_query | ✅ |
| `$90FA` | `BranchIfActorAt` | player_query | ✅ |
| `$9135` | `BranchOnPlayerX` | player_query | ✅ |
| `$915F` | `BranchOnPlayerY` | player_query | ✅ |
| `$9189` | `BranchNearerAxis` | player_query | ✅ |
| `$91B8` | `DirToPlayer` | player_query | ✅ |
| `$91CC` | `CardinalToPlayer` | player_query | ✅ |
| `$9230` | `code_009230` | (helper) | ✅ |
| `$9236` | `DirToPlayerFrom` | player_query | ✅ |
| `$926A` | `BranchIfDirToPlayer` | player_query | ✅ |
| `$9299` | `BranchIfDirToPlayerFrom` | player_query | ✅ |
| `$92E8` | `BranchOnPlayerFacing` | player_query | ✅ |

**Key problem:** First 3 ops (`SetTilePos`, `QueueMapChange`, `WaitWhileOffscreen`) belong to 3 different families, but the remaining 12 are all player_query.

**Proposed rename:** `cop_handlers_player_query` — the dominant family. The 3 leading outliers are contiguous at the file start and can't be cleanly split without fragmenting.

---

### ❌ `cop_handlers_palette.asm` — INCOHERENT

| Address | Handler | Doc family | Belongs here? |
|---------|---------|------------|---------------|
| `$9317` | `StageBgChange` | **bg_rearrange** | ❌ |
| `$9328` | `ApplyBgChange` | **bg_rearrange** | ❌ |
| `$9352` | `StageBgChangeFromDeathIdx` | **bg_rearrange** | ❌ |
| `$9361` | `PaletteRestart` | palette | ✅ |
| `$9364` | `PaletteStart` | palette | ✅ |
| `$9381` | `PaletteStartLoop` | palette | ✅ |
| `$93AA` | `PaletteStep` | palette | ✅ |
| `$93CE` | `PaletteStepLoop` | palette | ✅ |
| `$9400` | `SpawnThinkerParam` | **thinkers** | ❌ |
| `$943C` | `SpawnThinker` | **thinkers** | ❌ |
| `$9443` | `KillThinker` | **thinkers** | ❌ |

**Key problem:** BG rearrange (3 ops at start) and thinker management (3 ops at end) sandwich the 5 palette ops.

**Proposed rename:** `cop_handlers_palette_bg_thinker` or accept the name `cop_handlers_palette` with documented outliers. The groups are contiguous with no gaps — splitting requires block boundary changes.

---

### ❌ `cop_handlers_input.asm` — INCOHERENT

| Address | Handler | Doc family | Belongs here? |
|---------|---------|------------|---------------|
| `$9485` | `WaitForButton` | input | ✅ |
| `$94AD` | `WaitForRelease` | input | ✅ |
| `$94D5` | `BranchIfPressed` | input | ✅ |
| `$9501` | `BranchIfNotPressed` | input | ✅ |
| — | — | **GAP: `$952F`–`$9D51`** | — |
| `$9D52` | `StageWorldMapMove` | **map_transition** | ❌ |
| `$9D81` | `StageWorldMapChoice` | **map_transition** | ❌ |
| `$9DA3` | `StageWorldMapMoveIds` | **map_transition** | ❌ |
| — | — | **GAP: `$9DBC`–`$A866`** | — |
| `$A867` | `RunBg3Script` | **dialog** | ❌ |
| `$A894` | `DialogueOptions` | **dialog** | ❌ |
| `$A8FB` | `PrintDialogString` | **dialog** | ❌ |
| `$A958` | `PrintDialogStringAlt` | **dialog** | ❌ |

**Key problem:** The file spans a massive 5,331-byte range with two large gaps. The 3 world map ops and 4 dialog ops are at completely different ROM locations from the 4 input ops. The block has 3 non-contiguous fragments.

**Proposed:** Split into 3 blocks:
- `cop_handlers_input` → `$9485`–`$952E` (input family only)
- World map ops (`$9D52`–`$9DBB`) → move to `cop_handlers_map` or new `cop_handlers_world_map`
- Dialog ops (`$A867`–`$A991`) → new `cop_handlers_dialog`

---

### ❌ `cop_handlers_lifecycle.asm` — SEVERELY INCOHERENT (kitchen sink)

This is the worst offender: **39 labels spanning 12+ logical families** across a 4,814-byte range.

| Address | Handler | Doc family | Belongs here? |
|---------|---------|------------|---------------|
| `$956B` | `BranchIfPlayerInRelTiles` | **proximity** | ❌ |
| `$95EA` | `BranchIfPlayerInAbsTiles` | **proximity** | ❌ |
| `$9647` | `CopyPosToPrev` | **position** | ❌ |
| `$964C` | `CopyPosToNext` | **position** | ❌ |
| `$965E` | `GetPlayerFacing` | **player_query** | ❌ |
| `$9668` | `BranchIfBodyNe` | **player_query** | ❌ |
| — | — | **GAP: `$9684`–`$9A66`** | — |
| `$9A67` | `SetDeathCallback` | callbacks | ⚠️ lifecycle-adjacent |
| `$9A82` | `SetHitCallback` | callbacks | ⚠️ |
| `$9A92` | `SetDodgeCallback` | callbacks | ⚠️ |
| `$9AA2` | `SetCollideCallback` | callbacks | ⚠️ |
| `$9AB2` | `SetCustomCallback` | callbacks | ⚠️ |
| `$9AC2` | `OrExtraFlags` | **actor_flags** | ❌ |
| `$9AD6` | `AndExtraFlags` | **actor_flags** | ❌ |
| — | — | **GAP: `$9AEA`–`$9E05`** | — |
| `$9E06` | `SetLinkedEntryPtr` | **linked_actor** | ❌ |
| — | — | **GAP: `$9E22`–`$A5DD`** | — |
| `$A5DE` | `MarkDeath` | actor_death | ✅ |
| `$A5EF` | `MarkDeathResumeHandler` | (helper) | ✅ |
| `$A5F7` | `Die` | actor_death | ✅ |
| `$A608` | `DieNow_UnlinkChildren` | (helper) | ✅ |
| `$A6A1` | `KillPrev` | actor_death | ✅ |
| `$A6B1` | `KillNext` | actor_death | ✅ |
| `$A6C1` | `StageMoveX` | **force_move** | ❌ |
| `$A6D7` | `StageMoveY` | **force_move** | ❌ |
| `$A6ED` | `StageMoveXY` | **force_move** | ❌ |
| `$A713` | `ForceDirSW` | **force_move** | ❌ |
| `$A731` | `ForceDirNE` | **force_move** | ❌ |
| `$A74F` | `ForceDirBoth` | **force_move** | ❌ |
| `$A76D` | `ApplyMoveToChild` | **force_move** | ❌ |
| `$A799` | `ReloadMoveDurations` | **force_move** | ❌ |
| `$A7B3` | `SetPriorityMax` | **oam_attribs** | ❌ |
| `$A7BE` | `SetPriorityMin` | **oam_attribs** | ❌ |
| `$A7C9` | `ClearPriorityMax` | **oam_attribs** | ❌ |
| `$A7D4` | `ClearPriorityMin` | **oam_attribs** | ❌ |
| `$A7DF` | `SetOamPriority` | **oam_attribs** | ❌ |
| `$A7F4` | `SetOamPalette` | **oam_attribs** | ❌ |
| `$A809` | `ToggleHMirror` | **oam_attribs** | ❌ |
| `$A816` | `ToggleVMirror` | **oam_attribs** | ❌ |
| `$A823` | `ClearHMirror` | **oam_attribs** | ❌ |
| `$A82E` | `SetHMirror` | **oam_attribs** | ❌ |
| `$A839` | `NudgePosition` | **position** | ❌ |

**Families present:** proximity (2), position (3), player_query (2), callbacks (5), actor_flags (2), linked_actor (1), actor_death (4+2 helpers), force_move (8), oam_attribs (10), = 12 families across 3 non-contiguous fragments with large gaps.

**Proposed:** Split into multiple blocks by contiguous address range:
- `$956B`–`$9684`: proximity/position/player_query mix (6 ops) → `cop_handlers_actor_query`
- `$9A67`–`$9AEA`: callbacks + actor_flags (7 ops) → `cop_handlers_callbacks`
- `$9E06`–`$9E22`: linked_actor (1 op) → small, can join `cop_handlers_callbacks` or keep solo
- `$A5DE`–`$A6C0`: actor_death (4 ops + 2 helpers) → `cop_handlers_actor_death`
- `$A6C1`–`$A7B2`: force_move (8 ops) → `cop_handlers_force_move`
- `$A7B3`–`$A839`: oam_attribs (10 ops) → `cop_handlers_oam_attribs`
- `$A839`–`$A866`: NudgePosition (1 op) → `cop_handlers_position` or append to oam_attribs

---

### ❌ `cop_handlers_map.asm` — INCOHERENT

| Address | Handler | Doc family | Belongs here? |
|---------|---------|------------|---------------|
| `$9685` | `DrawMetatileAbs` | metatile | ✅ |
| `$96CA` | `DrawMetatileHere` | metatile | ✅ |
| `$9703` | `WorldMapStream3` | metatile | ✅ |
| `$9774` | `WorldMapStream4` | metatile | ✅ |
| `$97EF` | `ParseMapEntry` | (helper) | ✅ |
| `$9829` | `ResolveTileData` | (helper) | ✅ |
| `$98A9` | `TileQueryGate` | (helper) | ✅ |
| `$98B8` | `AdhocVramDma` | **vram_memory** | ❌ |
| `$9930` | `CopyPalette` | **vram_memory** | ❌ |
| `$997B` | `Decompress` | **vram_memory** | ❌ |
| `$99BF` | `SetScratchPointer` | **vram_memory** | ❌ |
| `$9AEA` | `BranchIfBehindWall` | **actor_flags** | ❌ |
| `$9B41` | `BranchIfCollisionTypeNe` | **collision_branch** | ❌ |
| `$9DBD` | `BranchIfOffCamera` | **offscreen** | ❌ |
| `$9DEA` | `HaltIfMaxFrames` | **offscreen** | ❌ |

**Key problem:** After the metatile handlers and their helpers (`$9685`–`$98A8`), 4 unrelated VRAM/memory ops appear, followed by isolated actor_flags, collision_branch, and offscreen ops scattered across 1,893 bytes with gaps.

**Proposed rename:** `cop_handlers_metatile_vram` or split:
- `$9685`–`$98A8`: metatile + helpers → `cop_handlers_metatile`
- `$98B8`–`$99DA`: VRAM/memory ops → `cop_handlers_vram`
- `$9AEA`: BranchIfBehindWall → move to callbacks/actor_flags block
- `$9B41`: BranchIfCollisionTypeNe → move to collision block
- `$9DBD`–`$9E05`: offscreen ops → `cop_handlers_offscreen`

---

### ⚠️ `cop_handlers_effects.asm` — MODERATE MISMATCH

| Address | Handler | Doc family | Belongs here? |
|---------|---------|------------|---------------|
| `$9B89` | `InitSineHdma` | sine_hdma | ✅ |
| `$9C3A` | `TickSineHdma` | sine_hdma | ✅ |
| `$9C91` | `BindSineHdma` | sine_hdma | ✅ |
| `$9CB4` | `InitGravity` | gravity | ⚠️ |
| `$9CFA` | `TickGravity` | gravity | ⚠️ |
| — | — | **GAP: `$9D51`** | — |
| `$A992` | `InitSpiral` | spiral | ⚠️ |
| `$A9AE` | `SpiralStep` | spiral | ⚠️ |
| — | — | **GAP** | — |
| `$ACDF` | `CameraPanDown` | camera | ⚠️ |
| `$AD17` | `CameraPanUp` | camera | ⚠️ |
| `$AD57` | `CameraPanRight` | camera | ⚠️ |
| `$AD8F` | `CameraPanLeft` | camera | ⚠️ |
| `$ADCF` | `BuildSineHdmaTable` | (helper) | ✅ |
| `$AEB8` | `BuildSineLookupTable` | (helper) | ✅ |

**Key problem:** 4 separate mini-families (sine_hdma, gravity, spiral, camera) across a 4,911-byte span with large gaps. "Effects" is a loose umbrella.

**Proposed:** The name is acceptable as an umbrella, but the gaps suggest the ROM has other code interleaved. If splitting:
- `$9B89`–`$9D51`: sine_hdma + gravity → `cop_handlers_sine_gravity`
- `$A992`–`$A9EA`: spiral → `cop_handlers_spiral`
- `$ACDF`–`$AEB8`: camera + sine helpers → `cop_handlers_camera`

---

### ❌ `cop_handlers_flow.asm` — INCOHERENT

| Address | Handler | Doc family | Belongs here? |
|---------|---------|------------|---------------|
| `$A9EB` | `SetInteractHandler` | script_control | ✅ |
| `$A9FB` | `SetEntryHere` | script_control | ✅ |
| `$AA07` | `SetEntryHereAndYield` | script_control | ✅ |
| `$AA13` | `JumpAfterDelay` | script_control | ✅ |
| `$AA30` | `JumpNextFrame` | script_control | ✅ |
| `$AA47` | `SetEntryFar` | script_control | ✅ |
| `$AA60` | `RestoreSavedPtr` | script_control | ✅ |
| `$AA74` | `ReturnWithSignal` | script_control | ✅ |
| `$AA8B` | `SetSavedPtr` | script_control | ✅ |
| `$AA9B` | `JumpFar` | script_control | ✅ |
| `$AAB6` | `CallNear` | script_control | ✅ |
| `$AAC6` | `CallNearDeferred` | script_control | ✅ |
| `$AAD8` | `LoopStart` | script_control | ✅ |
| `$AB0E` | `LoopEnd` | script_control | ✅ |
| `$AB41` | `SetFlagByte` | **scene_flags** | ❌ |
| `$AB51` | `SetFlagWord` | **scene_flags** | ❌ |
| `$AB60` | `ClearFlagByte` | **scene_flags** | ❌ |
| `$AB70` | `ClearFlagWord` | **scene_flags** | ❌ |
| `$AB7F` | `BranchOnFlagByte` | **scene_flags** | ❌ |
| `$AB8E` | `BranchOnFlagWord` | **scene_flags** | ❌ |
| `$ABC2` | `WaitOnFlagByte` | **scene_flags** | ❌ |
| `$ABD7` | `WaitOnFlagWord` | **scene_flags** | ❌ |
| `$AC05` | `GiveItem` | **inventory** | ❌ |
| `$AC27` | `RemoveItem` | **inventory** | ❌ |
| `$AC38` | `BranchIfMissingItem` | **inventory** | ❌ |
| `$AC5A` | `BranchIfItemEquipped` | **inventory** | ❌ |
| `$AC82` | `SetDungeonKillFlag` | **dungeon_switch** | ❌ |
| `$AC94` | `SwitchCase` | **dungeon_switch** | ❌ |
| `$ACC1` | `WaitByte` | **wait** | ❌ |
| `$ACD6` | `WaitWord` | **wait** | ❌ |

**Key problem:** The first 14 ops are script_control ✅, but then 16 more ops from 4 different families are appended. The entire block is contiguous (`$A9EB`–`$ACF6`, ~780 bytes) so splitting requires block boundary inserts.

**Proposed:** Split by contiguous sub-ranges:
- `$A9EB`–`$AB40`: script_control (14 ops) → rename to `cop_handlers_script_control`
- `$AB41`–`$ABC1`: scene_flags (8 ops) → `cop_handlers_scene_flags`
- `$ABC2`–`$AC04`: scene_flags waiters (2 ops) → keep with scene_flags
- `$AC05`–`$AC81`: inventory (4 ops) → `cop_handlers_inventory`
- `$AC82`–`$ACC0`: dungeon_switch (2 ops) → `cop_handlers_dungeon_switch`
- `$ACC1`–`$ACDE`: wait (2 ops) → `cop_handlers_wait`

---

### ✅ `cop_handlers_sprite.asm` — COHESIVE

| Address | Handler | Doc family |
|---------|---------|------------|
| `$99DA` | `ResetSpriteState` | sprite_state |
| `$99F5` | `AdvanceSpriteAnim` | sprite_state |
| `$9E23`–`$9F5E` | `StageSpr` through `StageSprLoopXY` | sprite_staging |
| `$9F5F` | `ProcessAnimFlag` | (helper) |
| `$9F8F`–`$9FF0` | `SetMetasprite` through `WaitForAnimFrame` | sprite_anim |
| `$A01E` | `StageSprAndHitbox` | sprite_staging |

All 3 doc families (sprite_state, sprite_staging, sprite_anim) are tightly related sprite subsystems. Cohesive as-is.

**Verdict:** No changes needed. The 3 doc families are logical sub-groupings of one physical theme.

---

### ✅ `cop_handlers_player_sprite.asm` — PERFECT

All 11 handlers belong to the **player_sprite** family. Contiguous `$A036`–`$A24A`.

**Verdict:** No changes needed.

---

### ✅ `cop_handlers_spawn.asm` — PERFECT

All 14 handlers belong to the **actor_spawn** family. Contiguous `$A24B`–`$A5DD`.

**Verdict:** No changes needed.

---

### — `cop_handlers_flags.asm` — UTILITY (no COP entry points)

This file contains only flag helper subroutines (`TestWramFlag`, `SetEventFlag`, `ClearEventFlag`, etc.) called by the scene_flags COP handlers in `cop_handlers_flow.asm`. It has **zero COP opcode entry points**.

**Verdict:** Not a COP handler block per se. Rename to `flag_helpers` or `wram_flag_utils` for clarity. Currently serves as a shared utility library.

---

## ROM address layout (visual)

The COP handlers occupy `$864E`–`$B500` in bank `$00`. Here's the physical layout showing how logical families interleave:

```
$864E  ┌─ cop_handlers_solid ───────────────────────────
       │  $864E-$86D8  HDMA/DMA (4 ops)          ← MISPLACED
$8714  │  ─ audio block boundary ─
       │  $8714-$8876  Audio (8 ops)              ← own file ✓
$8876  │  $8876-$8C18  Collision paint+branch (21 ops) ✅
$8C19  ├─ cop_handlers_movement ────────────────────────
       │  $8C19-$8C6E  Proximity (2 ops)          ← MISPLACED
       │  $8C6F-$9040  Movement (5 ops + helpers)  ✅
       │  $8FFC-$9048  RNG (2 ops)                ← MISPLACED
$904E  ├─ cop_handlers_spatial ─────────────────────────
       │  $904E        Position (1 op)             ← outlier
       │  $9072        MapTransition (1 op)        ← outlier
       │  $90CE        Offscreen (1 op)            ← outlier
       │  $90F4-$9316  Player query (12 ops)       ✅ dominant
$9317  ├─ cop_handlers_palette ─────────────────────────
       │  $9317-$9360  BG rearrange (3 ops)        ← MISPLACED
       │  $9361-$93FF  Palette (5 ops)             ✅
       │  $9400-$9484  Thinkers (3 ops)            ← MISPLACED
$9485  ├─ cop_handlers_input ───────────────────────────
       │  $9485-$952E  Input (4 ops)               ✅
       │  $952F        SetCollisionAbs             (solid file, gap piece)
$956B  ├─ cop_handlers_lifecycle ───────────────────────
       │  $956B-$9684  Proximity+Position+PlayerQ (6 ops) ← MISPLACED
$9685  ├─ cop_handlers_map ─────────────────────────────
       │  $9685-$98A8  Metatile (4 ops + helpers)  ✅
       │  $98B8-$99D9  VRAM/memory (4 ops)         ← MISPLACED
$99DA  ├─ cop_handlers_sprite ──────────────────────────
       │  $99DA-$9A66  Sprite state (2 ops)        ✅
$9A67  │  ─ lifecycle resumes ─
       │  $9A67-$9AE9  Callbacks+ActorFlags (7 ops) ← MISPLACED in lifecycle
$9AEA  │  ─ map resumes ─
       │  $9AEA        BranchIfBehindWall          ← MISPLACED in map
       │  $9B41        BranchIfCollisionTypeNe      ← MISPLACED in map
$9B89  ├─ cop_handlers_effects ─────────────────────────
       │  $9B89-$9D51  Sine HDMA + Gravity (5 ops) ✅
$9D52  │  ─ input resumes ─
       │  $9D52-$9DBC  World map (3 ops)           ← MISPLACED in input
$9DBD  │  ─ map resumes ─
       │  $9DBD-$9E05  Offscreen (2 ops)           ← MISPLACED in map
$9E06  │  ─ lifecycle resumes ─
       │  $9E06        SetLinkedEntryPtr            ← MISPLACED in lifecycle
$9E23  │  ─ sprite resumes ─
       │  $9E23-$A035  Sprite staging+anim (15 ops) ✅
$A036  ├─ cop_handlers_player_sprite ───────────────────
       │  $A036-$A24A  Player sprite (11 ops)      ✅
$A24B  ├─ cop_handlers_spawn ───────────────────────────
       │  $A24B-$A5DD  Actor spawn (14 ops)        ✅
$A5DE  │  ─ lifecycle resumes ─
       │  $A5DE-$A6C0  Actor death (4 ops)         ✅
       │  $A6C1-$A7B2  Force move (8 ops)          ← MISPLACED in lifecycle
       │  $A7B3-$A838  OAM attribs (10 ops)        ← MISPLACED in lifecycle
       │  $A839-$A866  NudgePosition (1 op)        ← MISPLACED in lifecycle
$A867  │  ─ input resumes ─
       │  $A867-$A991  Dialog (4 ops)              ← MISPLACED in input
$A992  │  ─ effects resumes ─
       │  $A992-$A9EA  Spiral (2 ops)              effects umbrella
$A9EB  ├─ cop_handlers_flow ────────────────────────────
       │  $A9EB-$AB40  Script control (14 ops)     ✅
       │  $AB41-$ABD7  Scene flags (8 ops)         ← MISPLACED in flow
       │  $AC05-$AC81  Inventory (4 ops)           ← MISPLACED in flow
       │  $AC82-$ACC0  Dungeon/switch (2 ops)      ← MISPLACED in flow
       │  $ACC1-$ACDE  Wait (2 ops)                ← MISPLACED in flow
$ACDF  │  ─ effects resumes ─
       │  $ACDF-$AEB8  Camera (4 ops) + sine helpers  effects umbrella
$AF8F  │  ─ solid resumes ─
       │  $AF8F-$B05D  Collision helpers           utility
$B05E  ├─ cop_handlers_flags ───────────────────────────
       │  $B05E-$B124  Flag helpers (no COP ops)   utility
$B125  │  ─ movement resumes ─
       │  $B125-$B156  ResolveActorIndex + helper  utility
$B29F  │  ─ solid resumes ─
       │  $B29F-$B500  Collision rect helpers      utility
$B481  │  ─ flags resumes ─
       │  $B481-$B500  Flag helpers (contd.)       utility
```

---

## Proposed block restructuring

### Principle

Where handlers from different families are **contiguous** in ROM (no gap between them), we should keep them in one block but **rename the block** to reflect the dominant or combined theme. Where handlers are **non-contiguous** (separated by code from other files), we **split into separate blocks**.

### Proposed changes to `blocks.json`

#### 1. Split `cop_handlers_solid` → `cop_handlers_hdma_dma` + `cop_handlers_collision`

| New block | Address range | Contains |
|-----------|---------------|----------|
| `cop_handlers_hdma_dma` | `$864E`–`$8713` | GenHdmaSine, QueueHdma, QueueDma, QueueHdmaChannel |
| `cop_handlers_collision` | `$8876`–`$8C18`, `$952F`, `$AF8F`–`$B500` | All collision paint/branch ops + helpers |

#### 2. Rename `cop_handlers_spatial` → `cop_handlers_player_query`

Keep all handlers together (dominant family is player_query at 12/15 ops). Document the 3 leading outliers.

#### 3. Rename `cop_handlers_palette` → `cop_handlers_palette_bg_thinker`

Or split if possible:

| New block | Address range | Contains |
|-----------|---------------|----------|
| `cop_handlers_bg_rearrange` | `$9317`–`$9360` | StageBgChange, ApplyBgChange, StageBgChangeFromDeathIdx |
| `cop_handlers_palette` | `$9361`–`$93FF` | PaletteRestart through PaletteStepLoop |
| `cop_handlers_thinker` | `$9400`–`$9484` | SpawnThinkerParam, SpawnThinker, KillThinker |

#### 4. Split `cop_handlers_input` → input + dialog (world map stays where it is)

| New block | Address range | Contains |
|-----------|---------------|----------|
| `cop_handlers_input` | `$9485`–`$952E` | WaitForButton, WaitForRelease, BranchIfPressed, BranchIfNotPressed |
| `cop_handlers_world_map` | `$9D52`–`$9DBC` | StageWorldMapMove, StageWorldMapChoice, StageWorldMapMoveIds |
| `cop_handlers_dialog` | `$A867`–`$A991` | RunBg3Script, DialogueOptions, PrintDialogString, PrintDialogStringAlt |

#### 5. Split `cop_handlers_lifecycle` (most impactful change)

| New block | Address range | Contains |
|-----------|---------------|----------|
| `cop_handlers_actor_query` | `$956B`–`$9684` | BranchIfPlayerInRelTiles, BranchIfPlayerInAbsTiles, CopyPosToPrev, CopyPosToNext, GetPlayerFacing, BranchIfBodyNe |
| `cop_handlers_callbacks` | `$9A67`–`$9AE9` | SetDeathCallback through SetCustomCallback, OrExtraFlags, AndExtraFlags |
| `cop_handlers_linked_actor` | `$9E06`–`$9E22` | SetLinkedEntryPtr (1 op; may merge with callbacks) |
| `cop_handlers_actor_death` | `$A5DE`–`$A6C0` | MarkDeath, Die, DieNow_UnlinkChildren, KillPrev, KillNext |
| `cop_handlers_force_move` | `$A6C1`–`$A7B2` | StageMoveX through ReloadMoveDurations |
| `cop_handlers_oam_attribs` | `$A7B3`–`$A866` | SetPriorityMax through SetHMirror, NudgePosition |

#### 6. Split `cop_handlers_map` → metatile + vram + isolated ops

| New block | Address range | Contains |
|-----------|---------------|----------|
| `cop_handlers_metatile` | `$9685`–`$98A8` | DrawMetatileAbs through TileQueryGate |
| `cop_handlers_vram` | `$98B8`–`$99D9` | AdhocVramDma, CopyPalette, Decompress, SetScratchPointer |
| (offscreen ops at `$9DBD`) | `$9DBD`–`$9E05` | BranchIfOffCamera, HaltIfMaxFrames → `cop_handlers_offscreen` |

#### 7. Split `cop_handlers_flow` → script_control + sub-blocks

| New block | Address range | Contains |
|-----------|---------------|----------|
| `cop_handlers_script_control` | `$A9EB`–`$AB40` | SetInteractHandler through LoopEnd (14 ops) |
| `cop_handlers_scene_flags` | `$AB41`–`$AC04` | SetFlagByte through WaitOnFlagWord (8 ops) |
| `cop_handlers_inventory` | `$AC05`–`$AC81` | GiveItem through BranchIfItemEquipped (4 ops) |
| `cop_handlers_dungeon_switch` | `$AC82`–`$ACC0` | SetDungeonKillFlag, SwitchCase (2 ops) |
| `cop_handlers_wait` | `$ACC1`–`$ACDE` | WaitByte, WaitWord (2 ops) |

#### 8. Rename `cop_handlers_flags` → `flag_helpers`

This file contains zero COP entry points — only shared subroutines for the scene_flags handlers.

### No changes needed

| Block | Reason |
|-------|--------|
| `cop_handlers_audio` | Perfect alignment (8 ops, 1 family) |
| `cop_handlers_sprite` | Cohesive (3 related sprite families) |
| `cop_handlers_player_sprite` | Perfect alignment (11 ops, 1 family) |
| `cop_handlers_spawn` | Perfect alignment (14 ops, 1 family) |
| `cop_handlers_movement` | Minor mismatches at boundaries; name is acceptable |

---

## Impact summary

| Metric | Before | After |
|--------|--------|-------|
| Physical block files | 14 | ~26 |
| Blocks with mixed families | 10 | ~3 (minor boundary outliers) |
| Families matching block name | 4/14 (29%) | ~23/26 (88%) |
| Largest mismatch | `cop_handlers_lifecycle` (12 families) | Eliminated |

### Execution priority

1. **High:** Split `cop_handlers_lifecycle` (biggest source of confusion)
2. **High:** Split `cop_handlers_flow` (5 families → 5 blocks)
3. **Medium:** Split `cop_handlers_input` (3 non-contiguous fragments)
4. **Medium:** Split `cop_handlers_solid` (extract HDMA/DMA)
5. **Medium:** Split `cop_handlers_map` (extract VRAM ops)
6. **Low:** Rename `cop_handlers_spatial` → `cop_handlers_player_query`
7. **Low:** Split/rename `cop_handlers_palette`
8. **Low:** Rename `cop_handlers_flags` → `flag_helpers`
