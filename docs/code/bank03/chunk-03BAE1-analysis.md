# Bank 03 — `chunk_03BAE1` Deep Analysis

> Complete reference for the engine's core runtime systems in IOG's ROM bank `$03`.
>
> **Source:** `extracted/system/chunk_03BAE1.asm`

---

## 1. Chunk Overview

| Metric | Value |
|--------|-------|
| **Address range** | `$03BAE1`–`$03F203` |
| **Total size** | ~14,082 bytes |
| **Named parts** | 170 |
| **External callers** | 49 unique symbols referenced from outside |
| **Compilation unit** | `chunk_03BAE1` (Bank 03, `?BANK 03`) |

This chunk is the **engine heart** — it contains nearly every critical runtime
system: collision detection, damage calculation, actor execution, OAM sprite
composition, tile collision physics, scene transitions, dialogue rendering,
the HUD, music transfer, save/load, palette/VRAM management, inventory logic,
and the player-facing direction lookup system.

---

## 2. Functional Areas

After thorough analysis, the 170 parts organize into **10 functional areas**:

| # | Area | Address Range | Parts | Description |
|---|------|---------------|-------|-------------|
| A | **OAM Digit Composer** | `$03BAE1`–`$03BB84` | 3 | Composes BCD digit sprites into OAM buffer |
| B | **Dodge Callback System** | `$03BB85`–`$03BBB3` | 1 | Scans actors for B-button dodge callbacks |
| C | **Combat & Collision** | `$03BBB4`–`$03C5FE` | 18 | Death check, hitbox testing, damage calc, knockback |
| D | **OAM & Sprite Composition** | `$03C5FF`–`$03CA54` | 11 | Actor-to-OAM pipeline, z-sort, player body rendering |
| E | **Actor Execution Loop** | `$03CAF5`–`$03D1F4` | 27 | `run_actors` variants, thinker tick loops, movement apply |
| F | **Tile Collision Physics** | `$03D1F5`–`$03D869` | 26 | Tilemap collision for X/Y movement, slope support |
| G | **Scene Lifecycle** | `$03D86A`–`$03E0AF` | 22 | Scene init, transitions, save/load, palette/VRAM setup |
| H | **HDMA & DMA Utilities** | `$03E0B0`–`$03E21D` | 8 | Palette bundles, GFX loads, HDMA setup, SPC comms |
| I | **Wide String / Dialogue Engine** | `$03E21E`–`$03EA61` | 36 | Dialogue box renderer, text commands, menu selection |
| J | **HUD & Inventory** | `$03EA62`–`$03F203` | 18 | ASCII string engine, HP bars, item pickup, inventory ops |

---

## 3. Detailed Part Analysis

### Area A — OAM Digit Composer (3 parts)

Composes multi-digit damage/gem count numbers into the OAM compose buffer.
Called by the hit-spark and damage display systems.

| Address | Current Name | Proposed Name | Role |
|---------|-------------|---------------|------|
| `$03BAE1` | `func_03BAE1` | `ComposeDigits_Continuation` | Alternate entry: re-uses existing scratch, advances OAM pointer |
| `$03BAF1` | `func_03BAF1` | `ComposeDigitSprites` | Main entry: decomposes a number into digit OAM tiles (hundreds/tens/ones) |
| `$03BB5E` | `func_03BB5E` | `EmitDigitOamEntry` | Writes one 6-byte OAM sprite entry for a single digit |

**Internal calls:** `ComposeDigitSprites` → `EmitDigitOamEntry` (3× JSR).
**External callers:** 10 files reference `func_03BAF1`.

---

### Area B — Dodge Callback System (1 part)

| Address | Current Name | Proposed Name | Role |
|---------|-------------|---------------|------|
| `$03BB85` | `func_03BB85` | `ProcessDodgeCallbacks` | On B-press, scans actor list for `onDodgeCallback`; if set, replaces the actor's script pointer with the callback, clearing it after one use |

**External callers:** 1 (from `func_03BB85` references).

---

### Area C — Combat & Collision (18 parts)

The largest and most complex area. Handles player death detection, actor-vs-actor
hitbox overlap testing, damage calculation (both enemy→player and player→enemy),
knockback direction, invincibility frame management, and death/defeat dispatch.

| Address | Current Name | Proposed Name | Role |
|---------|-------------|---------------|------|
| `$03BBB4` | `func_03BBB4` | `CheckPlayerDeath` | If HP=0 and not already dead, assigns GameOverSequence to player actor |
| `$03BBE4` | `func_03BBE4` | `RunCombatCollision` | **Main entry.** Iterates actor pool checking hitbox overlaps between player and enemies. Dispatches to damage handlers |
| `$03BBF9` | `code_03BBF9` | `CombatCollision_EnemyLoop` | Inner loop: tests each actor pair for collision flags |
| `$03BD5A` | `code_03BD5A` | `CombatCollision_Exit` | Epilogue: restores DBR + processor state |
| `$03BD5D` | `func_03BD5D` | `PlayerAttackHitTest` | Tests player's attack hitbox against enemy bounding boxes; on hit, calls damage calc |
| `$03BF22` | `code_03BF22` | `PlayerAttackHitTest_End` | Cleanup: restores direct page to 0 |
| `$03BF27` | `func_03BF27` | `EnemyHitPlayerHandler` | When an enemy hits the player: subtracts defense, applies damage, spawns stagger, sets iframe timer |
| `$03BF84` | `code_03BF84` | `EnemyHitPlayer_Epilogue` | Post-handler return trampoline |
| `$03C116` | `code_03C116` | `InvinciblePlayerHit` | Player has invincibility flag — only sets iframe and clears onHitCallback |
| `$03C142` | `func_03C142` | `CalcKnockbackDirection` | Computes knockback direction (0–3) from hitbox centers of attacker vs target. Used by both damage paths |
| `$03C25B` | `func_03C25B` | `InteractionCollision_Exit` | Early-exit epilogue for interaction collision |
| `$03C25E` | `code_03C25E` | `RunInteractionCollision` | Scans actor pool for interaction (talk/touch) collisions with player. Triggers `onCollideCallback` or `smooth_follow_child` redirect |
| `$03C362` | `code_03C362` | `InteractionCollision_FriendlyMode` | Variant: only checks actors with `$0020` (friendly) flag for interaction during player invincibility/special states |
| `$03C3E0` | `func_03C3E0` | `ApplyInteractionDamage` | Handles the actual effect when player touches an enemy interactible — computes damage from stats, depletes HP, spawns stagger or triggers NPC dialogue via `func_03EF97` |
| `$03C4D5` | `code_03C4D5` | `InteractionDamage_NPCChat` | Branch: touched actor is an NPC — loads chat pointer, shows dialogue, deactivates actor |
| `$03C524` | `func_03C524` | `CalcKnockbackFromActorCenters` | Secondary knockback direction calculator (used for interaction collisions) |
| `$03C58F` | `func_03C58F` | `FormatDamageDigits` | Converts a 16-bit damage value into BCD digit pairs for OAM display. Returns carry set if >= 1000 (overflow) |

**Key insight:** The combat system has two parallel paths:
1. **`PlayerAttackHitTest`** (player attacks enemy) → uses `chainDamage` and `playerStr`
2. **`EnemyHitPlayerHandler`** / **`ApplyInteractionDamage`** (enemy attacks player) → uses enemy stats minus `playerDef`

Both paths share `CalcKnockbackDirection` and `FormatDamageDigits`.

---

### Area D — OAM & Sprite Composition (11 parts)

Transforms the actor pool into the hardware OAM table ($0422+). Includes
actor z-sorting, per-actor metasprite decomposition, and the player's
special body-table rendering pipeline.

| Address | Current Name | Proposed Name | Role |
|---------|-------------|---------------|------|
| `$03C5FF` | `func_03C5FF` | `SortActorsByDepth` | Bucket-sorts all actors by screen Y into priority lists using the stack as scratch. Produces the sorted $0C00 render list |
| `$03C691` | `code_03C691` | `SortActors_OffScreen` | Marks off-screen actors with $4000 flag |
| `$03C69B` | `code_03C69B` | `SortActors_BuildFinalList` | Second pass: walks sorted buckets to build the final $0C00 linked list |
| `$03C714` | `func_03C714` | `ComposeAllSprites` | **Main OAM composition entry.** Initializes OAM state, renders compose-buffer entries, then iterates sorted actor list calling per-actor metasprite decomposer |
| `$03C78B` | `func_03C78B` | `RenderComposeBuffer` | Copies pre-composed OAM entries (effects, digits) from $7F3100 buffer to hardware OAM. Also handles alternate path for pre-built OAM data ($00DA) |
| `$03C849` | `func_03C849` | `DecomposeActorMetasprites` | Per-actor: reads metasprite data, decomposes each tile into OAM entries with scroll offset, flipping, and hi-table bits |
| `$03C928` | `code_03C928` | `DecomposePlayerSprites` | Special path for the player actor: uses body_table lookup, writes character tile table and extra DMA metadata |
| `$03CA05` | `code_03CA05` | `PlayerSprite_OffScreen` | Handles case when player sprite is off-screen — sets display mode flags |
| `$03CA19` | `func_03CA19` | `CheckPlayerSpriteCache` | Checks if player's spriteset pointer changed since last frame; if so, marks for re-DMA |
| `$03CA55` | `func_03CA55` | `UpdateActorAnimation` | Reads the next animation frame from spriteset data, updates metasprite pointer, hitbox offsets, and animation counter. Returns carry when animation sequence wraps |
| `binary_03C841` | `binary_03C841` | `OamHiTableMasks` | 8-byte lookup for OAM high-table bit packing |

**External callers:** `func_03CA55` is called by 20 external files (most-referenced part), `func_03C714` by 5, `func_03C5FF` by 5.

---

### Area E — Actor Execution Loop (27 parts)

The actor tick system. Multiple variants of `run_actors` handle different
game states (normal, pause-filtered, cutscene-only, thinker-only).

| Address | Current Name | Proposed Name | Role |
|---------|-------------|---------------|------|
| `$03CAF5` | `run_actors_03CAF5` | `RunActors_Normal` | Main actor tick loop. Walks linked list, decrements iframe, dispatches to actor script via stack trampoline (PHK/PEA/PHA/RTL pattern) |
| `$03CB78` | `code_03CB78` | `RunActors_PostTick` | After actor script returns: clears stale flags, calls movement apply (`ApplyMovement` or `ApplyMovementWithCollision`) |
| `$03CB93` | `code_03CB93` | `RunActors_CopScriptPostTick` | Variant post-tick for COP-scripted actors |
| `$03CBA3` | `code_03CBA3` | `RunActors_DisplayFiltered` | Display-mode-filtered variant: only ticks actors with $1000 flag |
| `$03CC12` | `code_03CC12` | `RunActors_DisplayFiltered_PostTick` | Post-tick for display-filtered mode |
| `$03CC2A` | `code_03CC2A` | `RunActors_DisplayFiltered_Exit` | Exit epilogue |
| `$03CC2D` | `code_03CC2D` | `RunActors_DisplayFiltered_CopPostTick` | COP-script post-tick variant |
| `$03CC3D` | `code_03CC3D` | `RunActors_PauseFiltered` | Pause-state variant: only ticks actors with cutscene/priority flags ($1400) |
| `$03CCAD` | `code_03CCAD` | `RunActors_PauseFiltered_PostTick` | Post-tick for pause-filtered mode |
| `$03CCCA` | `code_03CCCA` | `RunActors_PauseFiltered_Exit` | Exit epilogue |
| `$03CCEF` | `code_03CCEF` | `RunActors_PauseFiltered_CopPostTick` | COP-script post-tick variant |
| `$03CCFF` | `func_03CCFF` | `RunActors_CutsceneOnly` | Cutscene variant: only ticks actors with $0800 flag |
| `$03CD48` | `code_03CD48` | `RunActors_CutsceneOnly_PostTick` | Post-tick |
| `$03CD5E` | `code_03CD5E` | `RunActors_CutsceneOnly_CopPostTick` | COP variant |
| `$03CD6E` | `func_03CD6E` | `RunActors_OverlayOnly` | Overlay variant: ticks only actors with $1000 flag in `$12` |
| `$03CDC2` | `code_03CDC2` | `RunActors_OverlayOnly_PostTick` | Post-tick (just calls `ApplyMovement`) |
| `$03CDCC` | `func_03CDCC` | `RunActors_OverlayOnly_CopPostTick` | COP variant |
| `$03CDDC` | `func_03CDDC` | `InitActorPool` | Initializes the actor pool memory ($0E00 linked list headers, $1000+ actor slots, $7F1000+ extended data, $7E3000 thinker pool) |
| `$03CE8F` | `func_03CE8F` | `ThinkerPoolAlloc` | Allocates a thinker slot from the thinker pool ($7E3000+) |
| `$03CEA1` | `func_03CEA1` | `SpawnSceneActors` | Reads scene actor table, allocates actors from pool, calls `InitActorFromSceneData` for each |
| `$03CEF4` | `func_03CEF4` | `AdvanceSceneDataAndFree` | Advances the scene data pointer past one actor entry and frees the actor slot |
| `$03CF1B` | `func_03CF1B` | `InitActorFromSceneData` | Parses a single scene actor entry: sets position, flags, facing, stats, spriteset, script pointer, and player-specific init |
| `$03D0DB` | `func_03D0DB` | `CheckEnemyDefeatedFlag` | Checks WRAM flags to see if this enemy was already defeated (won't re-spawn). Also handles event block tile swaps |
| `$03D12D` | `func_03D12D` | `RunThinkers_TypeA` | Thinker tick loop variant A: ticks thinkers without `$0004` flag |
| `$03D15D` | `func_03D15D` | `RunThinkers_TypeB` | Thinker tick loop variant B: ticks thinkers with `$0004` flag |
| `$03D18D` | `func_03D18D` | `RunThinkers_TypeC` | Thinker tick loop variant C: ticks thinkers with `$0800` flag and without `$0004` |
| `$03D1C2` | `func_03D1C2` | `RunThinkers_TypeD` | Thinker tick loop variant D: ticks thinkers with both `$0800` and `$0004` flags |

**Data tables:**
| Address | Current Name | Proposed Name |
|---------|-------------|---------------|
| `$03D125` | `binary_03D125` | `BitMaskTable` |

---

### Area F — Tile Collision Physics (26 parts)

Handles movement with tilemap collision detection. When an actor moves,
these routines check the destination tile in the map data ($80 pointer)
and either allow the move, block it (align to tile edge), or handle
slope tiles.

| Address | Current Name | Proposed Name | Role |
|---------|-------------|---------------|------|
| `$03D1F5` | `func_03D1F5` | `ApplyMovement` | Applies X/Y velocity to actor position without collision checking (reads from velocity chain or `moveScratch` direct page) |
| `$03D276` | `func_03D276` | `ApplyMovementWithCollision` | **Main collision movement.** Applies X velocity with horizontal tile check, then Y velocity with vertical tile check. Also handles direction flip flags |
| `$03D2B9` | `code_03D2B9` | `CollisionX_PostMove` | After X-move resolves: applies remaining velocity from chain |
| `$03D337` | `code_03D337` | `CollisionY_Setup` | Sets up and dispatches Y-direction tile collision |
| `$03D39C` | `code_03D39C` | `TileCollision_MoveLeft` | X-axis collision check moving left (negative X velocity) |
| `$03D41F` | `code_03D41F` | `TileCollision_MoveRight` | X-axis collision check moving right (positive X velocity) |
| `$03D4AD` | `func_03D4AD` | `TileTypeJumpTable_Horizontal` | Jump table for horizontal tile type handlers (16 entries) |
| `$03D4CD` | `code_03D4CD` | `TileCollision_SolidH` | Solid tile hit: blocks horizontal movement, aligns to tile boundary |
| `$03D4CE` | `code_03D4CE` | `TileCollision_BlockH` | General block: sets collision flag `$0004`, snaps position to tile edge |
| `$03D53B` | `code_03D53B` | `TileCollision_PassH` | Passable tile: allows movement through |
| `$03D541` | `code_03D541` | `TileCollision_CheckAdjacentH` | Tile type 0 on non-aligned position: checks adjacent tile for real collision |
| `$03D556` | `code_03D556` | `TileCollision_MoveUp` | Y-axis collision check moving up (negative Y velocity) |
| `$03D5D7` | `code_03D5D7` | `TileCollision_MoveDown` | Y-axis collision check moving down (positive Y velocity) |
| `$03D65C` | `func_03D65C` | `TileTypeJumpTable_Vertical` | Jump table for vertical tile type handlers (16 entries) |
| `$03D67C` | `func_03D67C` | `TileCollision_BlockV` | Solid tile hit vertically: snaps Y to tile boundary |
| `$03D6E9` | `code_03D6E9` | `TileCollision_PassV` | Passable tile vertically |
| `$03D6EF` | `func_03D6EF` | `TileCollision_CheckAdjacentV` | Tile type 0 on non-aligned: checks adjacent vertical tile |
| `$03D704` | `func_03D704` | `TileCollision_SolidV` | Redirects to `TileCollision_BlockV` |
| `$03D708` | `func_03D708` | `CheckActorOnSpecialTile` | Pre-move check: tests if actor is currently standing on a special tile (pit = type 6, warp = type 9). Returns carry set if so |
| `$03D78A` | `func_03D78A` | `CalcTileMapOffset` | Converts (tileX, tileY) to a tilemap data offset using `mapRowStrideL0` via hardware multiply |
| `$03D7B4` | `func_03D7B4` | `AdvanceTileOffsetRight` | Advances tile offset one column to the right (handles row wrap) |
| `$03D7CA` | `sub_03D7CA` | `AdvanceTileOffsetDown` | Advances tile offset one row down (handles column wrap) |
| `$03D7E7` | `func_03D7E7` | `SpawnSceneThinkers` | Reads scene thinker table, allocates thinker slots, calls `InitThinkerFromSceneData` |
| `$03D831` | `sub_03D831` | `InitThinkerFromSceneData` | Parses a thinker entry from scene data into a thinker slot |
| `$03D86A` | `zero_bytes_03D86A` | `ClearActorRenderList` | Zeros the $0200 actor render list and terminates with $FFFF |

---

### Area G — Scene Lifecycle (22 parts)

Handles everything involved in loading a new scene: clearing state,
setting up camera, loading graphics, running the scene script, managing
screen transitions (fade/mosaic/scroll), and the save/load system.

| Address | Current Name | Proposed Name | Role |
|---------|-------------|---------------|------|
| `$03D881` | `func_03D881` | `DmaPlayerTilesToVram` | DMA-transfers the player character's tile data to VRAM ($4000–$4300) |
| `$03D8D8` | `sub_03D8D8` | `DmaPlayerTiles_UpperHalf` | Sub: DMA loop for upper tile rows |
| `$03D8F2` | `sub_03D8F2` | `DmaPlayerTiles_LowerHalf` | Sub: DMA loop for lower tile rows (offset by +$200) |
| `$03D916` | `func_03D916` | `SaveGameState` | Saves event flags + player position to SRAM slot (4 slots, $306200+) with integrity checksum |
| `$03D954` | `func_03D954` | `LoadGameState` | Loads event flags from SRAM slot; verifies checksum before restoring |
| `$03D994` | `func_03D994` | `ClearSaveSlot` | Zeros an SRAM save slot |
| `$03D9B8` | `func_03D9B8` | `ComputeSaveChecksum` | Computes a 32-bit additive + XOR checksum over a save block |
| `$03D9E8` | `func_03D9E8` | `CheckSceneTransition` | Checks if a scene transition is pending (`sceneNext` or `$0D52`). If so, calls `ExecuteSceneTransition` |
| `$03D9F6` | `func_03D9F6` | `ExecuteSceneTransition` | **The big one.** Handles the full scene change: exit transition, state clear, scene init, enter transition. Calls nearly every other init function |
| `$03DABB` | `sub_03DABB` | `ScreenExitTransition` | Exit transition effect dispatcher (5 modes: fade, instant, mosaic, scroll-wave, scroll-wave-alt) |
| `$03DBA4` | `code_03DBA4` | `ScreenExitTransition_WaveAlt` | Scroll-wave exit transition with per-frame UpdateFrameDialogue |
| `$03DBF6` | `sub_03DBF6` | `ApplyScrollWaveEffect` | Computes and applies a sine-based HDMA scroll wave for transition effects |
| `$03DC39` | `sub_03DC39` | `ComputeSineScrollTable` | Fills the sine scroll table ($7E8900) using hardware multiply for the wave effect |
| `$03DC92` | `sub_03DC92` | `ScreenEnterTransition` | Enter transition effect dispatcher (4 modes: fade-in, instant, mosaic-in, wave-in) |
| `$03DD56` | `func_03DD56` | `ClearSceneState` | Zeros all scene-specific state: camera, flags, player speed, velocities, HDMA, iframe, etc. Then calls scene script and init chain |
| `$03DECD` | `func_03DECD` | `LoadHudTilemap` | Loads the fixed HUD tilemap pattern (hearts, borders) into VRAM buffer with skip-offsets for BG3 layout |
| `$03DFA0` | `func_03DFA0` | `LoadScenePalettes` | Loads default scene palettes (FX palette, player palette) unless scene is a special screen (title, menu, etc.) |
| `$03DFF8` | `func_03DFF8` | `LoadPlayerGraphics` | DMA-transfers player character graphics to VRAM. Has special-case branches for title/menu scenes and boss scenes with alternate FX tiles |
| `$03E050` | `func_03E050` | `InitCameraBounds` | Sets camera bounds from map dimensions or from explicit override values in `$0652`/`$0653` |

**Data tables:**
| Address | Current Name | Proposed Name |
|---------|-------------|---------------|
| `$03DF0A` | `word_03DF0A` | `HudTilemapData` |
| `fx_palette_*` | *(external refs)* | *(palette data in other banks)* |

---

### Area H — HDMA & DMA Utilities (8 parts)

Low-level DMA/HDMA channel management, palette bundle loading,
graphics decompression support, and SPC-700 communication.

| Address | Current Name | Proposed Name | Role |
|---------|-------------|---------------|------|
| `$03E0B0` | `func_03E0B0` | `LoadPaletteBundle` | Reads a palette bundle entry: sets spriteset, chat, metasprite pointers, CGRAM palette slot, and bank byte. Returns carry when bundle exhausted |
| `$03E125` | `func_03E125` | `DecompressGfxToVram` | Decompresses graphics data (via $0402 callback) into the CGRAM/VRAM target for an actor |
| `$03E146` | `func_03E146` | `ResetHdmaState` | Resets HDMA channel allocation state ($66/$68/$6A) for a new frame. Called 6× internally, 5× externally |
| `$03E157` | `func_03E157` | `SetupHdmaChannel_Indirect` | Configures an HDMA channel with indirect (double-indirect) table mode |
| `$03E173` | `func_03E173` | `SetupHdmaChannel_Direct` | Configures an HDMA channel with direct table mode. Both HDMA setup routines share the tail at `$03E186` |
| `$03E1AA` | `func_03E1AA` | `SpcCheckMusicReady` | Checks if SPC-700 is ready for music transfer by probing APUIO0 |
| `$03E1D6` | `func_03E1D6` | `SpcTransferMusicData` | Transfers music data to SPC-700 via APUIO0 handshake protocol. Spawned as an actor that waits for completion then dies |
| `$03E21E` | `func_03E21E` | `LoadMusicFromTransitionState` | Looks up music track from `musicTransitionState`, loads from `music_array`, initiates SPC block transfer |

---

### Area I — Wide String / Dialogue Engine (36 parts)

The complete dialogue rendering system. Parses "wide strings" (16-bit
tile-based text), handles dialogue box creation/scrolling, template
expansion, dictionary lookup, number formatting, and button-wait logic.

| Address | Current Name | Proposed Name | Role |
|---------|-------------|---------------|------|
| `$03E255` | `sub_03E255` | `WideStringRenderer` | **Core entry.** Parses a wide-string byte stream: <$C0 = literal tile, ≥$C0 = command. Writes tiles to $7F0200 VRAM buffer with row stride |
| `$03E2C3` | `wide_cmd_table_03E2C3` | `WideStringCommandTable` | Jump table for 25 wide-string commands ($C0–$D8) |
| `$03E2F5` | `cmd_c0_03E2F5` | `WideCmd_EndAndWait` | $C0: Clears input lock, waits for button, saves cursor position |
| `$03E307` | `code_03E307` | `WideCmd_Return` | $CA / exit: Restores stack and returns from `WideStringRenderer` |
| `$03E30F` | `cmd_c1_03E30F` | `WideCmd_SetPosition` | $C1: Sets text cursor row/column from 2-byte argument |
| `$03E335` | `cmd_c2_03E335` | `WideCmd_InsertTemplate` | $C2: Inserts a template string by index from `templates_01CA95` |
| `$03E35B` | `cmd_c3_03E35B` | `WideCmd_SetPalette` | $C3: Sets tile palette bits for subsequent characters |
| `$03E36B` | `cmd_c4_03E36B` | `WideCmd_InfiniteLoop` | $C4: Infinite loop (halt/debug) |
| `$03E36F` | `cmd_c5_03E36F` | `WideCmd_IndirectString` | $C5: Indirect string lookup — reads pointer-to-pointer and recursively renders |
| `$03E393` | `cmd_c6_03E393` | `WideCmd_PrintNumber` | $C6: Formats and prints a multi-digit number (with leading-zero suppression) |
| `$03E43F` | `cmd_c7_03E43F` | `WideCmd_OpenDialogueBox` | $C7: Opens a dialogue box — creates border tiles, initializes position/size state |
| `$03E4CE` | `dlg_borders_03E4CE` | `DialogueBorderTiles` | 16-byte border tile pattern data |
| `$03E4DE` | `sub_03E4DE` | `DrawDialogueBorderRow` | Draws one horizontal border row (corner + fill + corner) |
| `$03E505` | `sub_03E505` | `DrawDialogueBodyRows` | Draws the dialogue box interior rows (left border + space + right border) plus optional bottom row |
| `$03E579` | `cmd_c8_03E579` | `WideCmd_ClearDialogueBox` | $C8: Clears the interior of the dialogue box, resets cursor |
| `$03E5EB` | `cmd_c9_03E5EB` | `WideCmd_WaitFrames` | $C9: Waits N frames before continuing text |
| `$03E5F8` | `cmd_cb_03E5F8` | `WideCmd_NewLine` | $CB: Advances to next line; scrolls dialogue if at bottom |
| `$03E61E` | `cmd_cc_03E61E` | `WideCmd_AdvanceCursor` | $CC: Advances cursor by N columns |
| `$03E636` | `cmd_cd_03E636` | `WideCmd_InsertRemoteString` | $CD: Inserts a string from another bank (3-byte pointer) |
| `$03E656` | `cmd_ce_03E656` | `WideCmd_ClearBox` | $CE: Clears the dialogue box interior (fills with space tiles) |
| `$03E6A4` | `cmd_cf_03E6A4` | `WideCmd_WaitForButton` | $CF: Waits for any button press with flashing cursor indicator |
| `$03E6D2` | `cmd_d0_03E6D2` | `WideCmd_WaitForAnyInput` | $D0: Waits for any joypad input (including d-pad) |
| `$03E6E7` | `cmd_d1_03E6E7` | `WideCmd_JumpToAddress` | $D1: Sets string pointer to absolute address |
| `$03E6EC` | `cmd_d2_03E6EC` | `WideCmd_SetSfx` | $D2: Sets the sound effect played per character |
| `$03E6F7` | `cmd_d3_03E6F7` | `WideCmd_OpenDefaultBox` | $D3: Opens a standard-sized dialogue box (13×4 at row 3, col 17) |
| `$03E721` | `cmd_d4_03E721` | `WideCmd_SetPaletteColor` | $D4: Writes a color to CGRAM buffer directly |
| `$03E736` | `cmd_d5_03E736` | `WideCmd_SetFrameDelay` | $D5: Sets the per-character frame delay counter |
| `$03E743` | `cmd_d6_03E743` | `WideCmd_DictionaryA` | $D6: Inserts word from dictionary A (`dictionary_01EBA8`) |
| `$03E769` | `cmd_d7_03E769` | `WideCmd_DictionaryB` | $D7: Inserts word from dictionary B (`dictionary_01F54D`) |
| `$03E78F` | `cmd_d8_03E78F` | `WideCmd_PrintRawTiles` | $D8: Prints raw tile bytes until a zero terminator |
| `$03E7B2` | `sub_03E7B2` | `WaitOneFrame` | Waits one frame (calls `UpdateFrameDialogue`) |
| `$03E7B5` | `code_03E7B5` | `WaitNFrames_Entry` | Waits N frames where N is parameter |
| `$03E7BA` | `code_03E7BA` | `WaitNFrames_PerChar` | Waits `$007E` frames (per-character delay); skips if `worldReadyFlag` is 0 |
| `$03E7CB` | `code_03E7CB` | `WaitNFrames_Loop` | Frame-wait inner loop body |
| `$03E7D6` | `sub_03E7D6` | `ScrollDialogueUp` | Scrolls dialogue box content up by one row (copies $0240→$0200 per row) |
| `$03E80C` | `sub_03E80C` | `DrawDialogueCursor` | Draws or erases the flashing text cursor at the current dialogue position |
| `$03E849` | `func_03E849` | `MenuSelectionHandler` | Full menu selection UI: handles d-pad navigation, A/B/L/R button dispatch, cursor blinking, wrapping. Returns selected index |
| `$03E8FC` | `code_03E8FC` | `MenuSelection_Down` | Down-press handler for menu |
| `$03E93C` | `code_03E93C` | `MenuSelection_LeftRight` | Left/Right handler: jumps by column count |
| `$03E983` | `sub_03E983` | `DrawMenuCursor` | Draws the menu selection cursor with blink animation |
| `$03EA2A` | `sub_03EA2A` | `ReadMenuSelection` | Reads the tile under the current cursor for the "preview" feature of certain menus |

**Data tables:**
| Address | Current Name | Proposed Name |
|---------|-------------|---------------|
| `$03E42F` | `binary_03E42F` | `HexDigitTileTable` |

---

### Area J — HUD & Inventory (18 parts)

The ASCII-string rendering engine (used for HUD overlays like HP bars,
stat labels, item names), inventory pickup/removal logic, and the
player facing-direction lookup table.

| Address | Current Name | Proposed Name | Role |
|---------|-------------|---------------|------|
| `$03EA62` | `func_03EA62` | `AsciiStringRenderer` | Renders an ASCII-like string command stream to the VRAM tile buffer. Supports 18 commands ($00–$11) |
| `$03EA8C` | `asciistring_cmd_table_03EA8C` | `AsciiStringCommandTable` | Jump table for 18 ASCII-string commands |
| `$03EAB0` | `cmd_11_03EAB0` | `AsciiCmd_AdvanceRow2` | Advances VRAM pointer by 2 rows ($80 bytes) |
| `$03EABD` | `cmd_10_03EABD` | `AsciiCmd_InsertItemName` | Inserts an item name from `itemcomp_table_01EB0F` |
| `$03EAE2` | `cmd_0F_03EAE2` | `AsciiCmd_ClearRect` | Clears a rectangular region of the VRAM tile buffer |
| `$03EB1B` | `cmd_0A_03EB1B` | `AsciiCmd_DrawPlayerHpBar` | Draws the player HP bar (filled/half/empty hearts) in 2 rows |
| `$03EB71` | `sub_03EB71` | `DrawHpBar` | Shared HP bar renderer: draws full/half/empty segments using palette-shifted tiles |
| `$03EBE6` | `sub_03EBE6` | `HpBar_AdvanceRow` | Advances to next VRAM row during HP bar drawing; terminates if past limit |
| `$03EBFC` | `cmd_0B_03EBFC` | `AsciiCmd_DrawEnemyHpBar` | Draws the enemy HP bar (similar to player but with different palette) |
| `$03EC52` | `cmd_00_03EC52` | `AsciiCmd_End` | Terminates the ASCII string renderer |
| `$03EC57` | `cmd_0D_03EC57` | `AsciiCmd_AdvanceRow4` | Advances VRAM pointer by 4 rows ($100 bytes) |
| `$03EC64` | `cmd_0E_03EC64` | `AsciiCmd_Print3DigitNumber` | Prints a 3-digit decimal number with leading-space suppression |
| `$03ED00` | `cmd_01_03ED00` | `AsciiCmd_SetVramAddr` | Sets the VRAM target address directly |
| `$03ED0B` | `cmd_02_03ED0B` | `AsciiCmd_InsertRemoteString` | Inserts an ASCII string from another bank |
| `$03ED2B` | `cmd_03_03ED2B` | `AsciiCmd_SetPalette` | Sets the palette bits for subsequent tiles |
| `$03ED3C` | `cmd_04_03ED3C` | `AsciiCmd_IndirectString` | Indirect string lookup — reads pointer-to-pointer |
| `$03ED6F` | `cmd_05_03ED6F` | `AsciiCmd_PrintBcdNumber` | Prints a packed BCD number (nibble-per-digit, right-to-left) |
| `$03EDE3` | `cmd_06_03EDE3` | `AsciiCmd_DrawBox` | Draws a bordered rectangle (window frame) with configurable size |
| `$03EEA5` | `cmd_07_03EEA5` | `AsciiCmd_ClearColumn` | Clears a column of tiles from a starting address |
| `$03EEF5` | `cmd_08_03EEF5` | `AsciiCmd_FillTile` | Fills N tile slots with a single tile value |
| `$03EF1F` | `cmd_0C_03EF1F` | `AsciiCmd_PrintRawBytes` | Prints raw tile bytes until $FF terminator |
| `$03EF3E` | `cmd_09_03EF3E` | `AsciiCmd_PrintEquipIcons` | Prints equipped item icons (weapon/armor) with 2×2 tile layout |
| `$03EF97` | `func_03EF97` | `GiveItemToPlayer` | Adds item to inventory; handles stat-up items (HP+, STR+, DEF+), gem pickups, and full-inventory overflow. Returns carry if inventory full |
| `$03F051` | `code_03F051` | `GiveItem_DefUp` | DEF stat-up branch |
| `$03F070` | `code_03F070` | `GiveItem_StoreInSlot` | Stores item in first empty inventory slot |
| `$03F07D` | `code_03F07D` | `GiveItem_Success` | Success epilogue |
| `$03F080` | `code_03F080` | `GiveItem_InventoryFull` | Inventory-full epilogue: shows "full" message |
| `$03F08D` | `func_03F08D` | `RemoveItemFromInventory` | Removes a specific item from inventory by ID |
| `$03F0B3` | `func_03F0B3` | `CheckInventoryForItem` | Checks if player has a specific item. Returns carry clear if found |
| `$03F0CA` | `func_03F0CA` | `GetPlayerFacingFromAnim` | Looks up the player's facing direction (0–3) from current animation frame index. Handles form-specific lookup tables for Freedan/Shadow |
| `$03F0EE` | `code_03F0EE` | `GetPlayerFacing_AltEntry` | Alternate entry for facing lookup during transformation |
| `$03F1D0` | `func_03F1D0` | `DmaAdhocVramBlock` | Executes a one-shot DMA transfer from `adhocVramDma` scratch to VRAM |

**Data tables:**
| Address | Current Name | Proposed Name |
|---------|-------------|---------------|
| `$03F11F` | `binary_03F11F` | `FacingDirectionLookup` |
| `$03F177` | `table_03F177` | `FacingFormOffsetTable` |
| `$03F17F` | `binary_03F17F` | `FacingData_Will` |
| `$03F19A` | `binary_03F19A` | `FacingData_Freedan` |
| `$03F1C6` | `binary_03F1C6` | `FacingData_Shadow_A` |
| `$03F1CA` | `binary_03F1CA` | `FacingData_Shadow_B` |

---

## 4. Proposed Code Splits

### Split Strategy

The goal is to divide this 8,518-line file into self-contained units that:
1. **Minimize cross-split `JSR` / `JMP` / `JSL` calls**
2. **Group tightly coupled routines** (shared locals, fall-through, same-bank JSR chains)
3. **Create files of manageable size** (~500–2000 lines each)
4. **Have clear, descriptive filenames** reflecting their functional role

### Proposed 8-File Split

| # | Proposed Filename | Areas | Lines | Parts | Key Entry Points |
|---|-------------------|-------|-------|-------|-----------------|
| 1 | `oam_digit_compose.asm` | A | ~80 | 3 | `ComposeDigitSprites` |
| 2 | `combat_collision.asm` | B + C | ~700 | 19 | `CheckPlayerDeath`, `RunCombatCollision`, `RunInteractionCollision` |
| 3 | `sprite_composition.asm` | D | ~590 | 11 | `SortActorsByDepth`, `ComposeAllSprites`, `UpdateActorAnimation` |
| 4 | `actor_execution.asm` | E | ~900 | 27 | `RunActors_Normal`, `InitActorPool`, `SpawnSceneActors`, `RunThinkers_*` |
| 5 | `tile_collision.asm` | F | ~650 | 26 | `ApplyMovement`, `ApplyMovementWithCollision`, `CalcTileMapOffset` |
| 6 | `scene_lifecycle.asm` | G | ~1,100 | 22 | `ExecuteSceneTransition`, `ClearSceneState`, `SaveGameState`, `LoadGameState` |
| 7 | `dialogue_engine.asm` | H + I | ~1,400 | 44 | `WideStringRenderer`, `MenuSelectionHandler`, `LoadPaletteBundle`, `SpcTransferMusicData` |
| 8 | `hud_inventory.asm` | J | ~750 | 18 | `AsciiStringRenderer`, `GiveItemToPlayer`, `GetPlayerFacingFromAnim` |

### Cross-Reference Analysis Between Proposed Splits

```
                        ┌────────────────────────────┐
                        │  External callers (49 refs) │
                        └────────────┬───────────────┘
                                     │
         ┌───────────────────────────┼───────────────────────────┐
         ▼                           ▼                           ▼
  ┌─────────────┐    ┌──────────────────────┐    ┌──────────────────────┐
  │ 1. oam_digit│    │ 6. scene_lifecycle   │    │ 7. dialogue_engine   │
  │  (3 parts)  │    │  (22 parts)          │    │  (44 parts)          │
  └─────────────┘    │  Orchestrates all:   │    └──────────────────────┘
         ▲           │  calls 3,4,5,7,8     │              ▲
         │           └──────────┬───────────┘              │
         │                      │                          │
  ┌──────┴──────┐    ┌─────────┴──────────┐    ┌──────────┴─────────┐
  │ 2. combat   │    │ 4. actor_execution │    │ 8. hud_inventory   │
  │  (19 parts) │    │  (27 parts)        │    │  (18 parts)        │
  └──────┬──────┘    └─────────┬──────────┘    └────────────────────┘
         │                     │
  ┌──────┴──────┐    ┌────────┴──────────┐
  │ 3. sprites  │    │ 5. tile_collision │
  │  (11 parts) │    │  (26 parts)       │
  └─────────────┘    └──────────────────┘
```

### Detailed Cross-Calls Between Splits

| From → To | Calls | Details |
|-----------|-------|---------|
| 2 (combat) → 1 (digits) | 1 JSR | `FormatDamageDigits` → `ComposeDigitSprites` (called by damage display) |
| 2 (combat) → 8 (hud) | 1 JSL | `InteractionDamage_NPCChat` → `GiveItemToPlayer` |
| 2 (combat) → 8 (hud) | 1 JSL | `EnemyHitPlayerHandler` → `GetPlayerFacingFromAnim` |
| 4 (actors) → 3 (sprites) | 2 JSL | `InitActorFromSceneData` → `UpdateActorAnimation` |
| 4 (actors) → 5 (collision) | 4 JSR | `RunActors_*_PostTick` → `ApplyMovement` / `ApplyMovementWithCollision` |
| 5 (collision) → 5 (self) | many | All internal |
| 6 (scene) → 3 (sprites) | 2 JSL | `ClearSceneState` → `SortActorsByDepth`, `ComposeAllSprites` |
| 6 (scene) → 4 (actors) | 6 JSL | `ClearSceneState` → `InitActorPool`, `SpawnSceneActors`, `RunActors_Normal`, `RunThinkers_*`, etc. |
| 6 (scene) → 5 (collision) | 3 JSL | `ClearSceneState` → `SpawnSceneThinkers`, `CalcTileMapOffset`, `ClearActorRenderList` |
| 6 (scene) → 7 (dialogue) | 2 JSL | `ClearSceneState` → `ResetHdmaState`; `ScreenExitTransition` → `ResetHdmaState` |
| 6 (scene) → 6 (self) | many | Scene init calls other scene functions |
| 7 (dialogue) → 7 (self) | many | Wide-string commands call each other heavily |
| 8 (hud) → 7 (dialogue) | 3 JSL | `AsciiStringRenderer` → `WideStringRenderer` (for inline rendering) |

**Total cross-split calls: ~25** (down from ~200+ internal calls in the monolithic file).
The heaviest coupling is `scene_lifecycle` → `actor_execution` (6 calls), which is
unavoidable as scene init must spawn actors. All other cross-splits have ≤4 calls.

---

## 5. Key Architectural Insights

### 5.1 The Stack-Trampoline Actor Dispatch

The actor execution loop uses an ingenious dispatch pattern:
```
PHK             ; push current bank
PEA &PostTick-1 ; push return address (post-tick handler)
SEP #$20
LDA $02         ; actor script bank
PHA
REP #$20
LDA $00         ; actor script address
DEC
PHA
RTL             ; "calls" the actor script; RTS returns to PostTick
```
This avoids storing a return address — the actor script just does `RTS`/`RTL`
and automatically returns to the post-tick handler. The `DEC` compensates for
`RTL`'s `+1` behavior.

### 5.2 Dual Movement Paths

Every actor tick ends with one of two movement functions:
- **`ApplyMovement`** (flag `$0008` clear): simple position += velocity
- **`ApplyMovementWithCollision`** (flag `$0008` set): checks tilemap before moving

The collision path is the most complex code in the chunk (~650 lines),
handling horizontal/vertical independently with separate tile-type jump tables.

### 5.3 Scene Lifecycle Orchestration

`ClearSceneState` at `$03DD56` is the central orchestrator, calling **17 JSL**
destinations in sequence. This is the only function that directly touches
almost every subsystem. Splitting the monolith doesn't increase its call count
because it already uses `JSL` (cross-bank capable) for most calls.

### 5.4 Two Independent Text Engines

The game has **two separate text rendering systems**:
1. **Wide String Engine** (`$03E255`): 16-bit tiles for dialogue boxes, cutscene text
2. **ASCII String Engine** (`$03EA62`): 8-bit tile commands for HUD overlays, menus

They share no code but both write to the same `$7F0200` VRAM buffer.
The ASCII engine can recursively call the wide-string engine via `cmd_02`/`cmd_04`.

### 5.5 Save System Integrity

The save system uses dual integrity checks:
- **Additive checksum** (cumulative ADC)
- **XOR checksum** (cumulative EOR)

Both must match on load or the save slot is rejected. This protects against
both zeroed-out SRAM and bit-flipped corruption.

---

## 6. Complete Name Mapping (All 170 Parts)

### Split 1: `oam_digit_compose.asm`

| Address | Current Name | Proposed Name |
|---------|-------------|---------------|
| `$03BAE1` | `func_03BAE1` | `ComposeDigits_Continuation` |
| `$03BAF1` | `func_03BAF1` | `ComposeDigitSprites` |
| `$03BB5E` | `func_03BB5E` | `EmitDigitOamEntry` |

### Split 2: `combat_collision.asm`

| Address | Current Name | Proposed Name |
|---------|-------------|---------------|
| `$03BB85` | `func_03BB85` | `ProcessDodgeCallbacks` |
| `$03BBB4` | `func_03BBB4` | `CheckPlayerDeath` |
| `$03BBE4` | `func_03BBE4` | `RunCombatCollision` |
| `$03BBF9` | `code_03BBF9` | `CombatCollision_EnemyLoop` |
| `$03BD5A` | `code_03BD5A` | `CombatCollision_Exit` |
| `$03BD5D` | `func_03BD5D` | `PlayerAttackHitTest` |
| `$03BF22` | `code_03BF22` | `PlayerAttackHitTest_End` |
| `$03BF27` | `func_03BF27` | `EnemyHitPlayerHandler` |
| `$03BF84` | `code_03BF84` | `EnemyHitPlayer_Epilogue` |
| `$03C116` | `code_03C116` | `InvinciblePlayerHit` |
| `$03C142` | `func_03C142` | `CalcKnockbackDirection` |
| `$03C25B` | `func_03C25B` | `InteractionCollision_Exit` |
| `$03C25E` | `code_03C25E` | `RunInteractionCollision` |
| `$03C362` | `code_03C362` | `InteractionCollision_FriendlyMode` |
| `$03C3E0` | `func_03C3E0` | `ApplyInteractionDamage` |
| `$03C4D5` | `code_03C4D5` | `InteractionDamage_NPCChat` |
| `$03C524` | `func_03C524` | `CalcKnockbackFromActorCenters` |
| `$03C58F` | `func_03C58F` | `FormatDamageDigits` |

### Split 3: `sprite_composition.asm`

| Address | Current Name | Proposed Name |
|---------|-------------|---------------|
| `$03C5FF` | `func_03C5FF` | `SortActorsByDepth` |
| `$03C691` | `code_03C691` | `SortActors_OffScreen` |
| `$03C69B` | `code_03C69B` | `SortActors_BuildFinalList` |
| `$03C714` | `func_03C714` | `ComposeAllSprites` |
| `$03C78B` | `func_03C78B` | `RenderComposeBuffer` |
| `$03C841` | `binary_03C841` | `OamHiTableMasks` |
| `$03C849` | `func_03C849` | `DecomposeActorMetasprites` |
| `$03C928` | `code_03C928` | `DecomposePlayerSprites` |
| `$03CA05` | `code_03CA05` | `PlayerSprite_OffScreen` |
| `$03CA19` | `func_03CA19` | `CheckPlayerSpriteCache` |
| `$03CA55` | `func_03CA55` | `UpdateActorAnimation` |

### Split 4: `actor_execution.asm`

| Address | Current Name | Proposed Name |
|---------|-------------|---------------|
| `$03CAF5` | `run_actors_03CAF5` | `RunActors_Normal` |
| `$03CB78` | `code_03CB78` | `RunActors_PostTick` |
| `$03CB93` | `code_03CB93` | `RunActors_CopScriptPostTick` |
| `$03CBA3` | `code_03CBA3` | `RunActors_DisplayFiltered` |
| `$03CC12` | `code_03CC12` | `RunActors_DisplayFiltered_PostTick` |
| `$03CC2A` | `code_03CC2A` | `RunActors_DisplayFiltered_Exit` |
| `$03CC2D` | `code_03CC2D` | `RunActors_DisplayFiltered_CopPostTick` |
| `$03CC3D` | `code_03CC3D` | `RunActors_PauseFiltered` |
| `$03CCAD` | `code_03CCAD` | `RunActors_PauseFiltered_PostTick` |
| `$03CCCA` | `code_03CCCA` | `RunActors_PauseFiltered_Exit` |
| `$03CCEF` | `code_03CCEF` | `RunActors_PauseFiltered_CopPostTick` |
| `$03CCFF` | `func_03CCFF` | `RunActors_CutsceneOnly` |
| `$03CD48` | `code_03CD48` | `RunActors_CutsceneOnly_PostTick` |
| `$03CD5E` | `code_03CD5E` | `RunActors_CutsceneOnly_CopPostTick` |
| `$03CD6E` | `func_03CD6E` | `RunActors_OverlayOnly` |
| `$03CDC2` | `code_03CDC2` | `RunActors_OverlayOnly_PostTick` |
| `$03CDCC` | `func_03CDCC` | `RunActors_OverlayOnly_CopPostTick` |
| `$03CDDC` | `func_03CDDC` | `InitActorPool` |
| `$03CE8F` | `func_03CE8F` | `ThinkerPoolAlloc` |
| `$03CEA1` | `func_03CEA1` | `SpawnSceneActors` |
| `$03CEF4` | `func_03CEF4` | `AdvanceSceneDataAndFree` |
| `$03CF1B` | `func_03CF1B` | `InitActorFromSceneData` |
| `$03D0DB` | `func_03D0DB` | `CheckEnemyDefeatedFlag` |
| `$03D125` | `binary_03D125` | `BitMaskTable` |
| `$03D12D` | `func_03D12D` | `RunThinkers_TypeA` |
| `$03D156` | `code_03D156` | `RunThinkers_TypeA_Next` |
| `$03D15D` | `func_03D15D` | `RunThinkers_TypeB` |
| `$03D186` | `code_03D186` | `RunThinkers_TypeB_Next` |
| `$03D18D` | `func_03D18D` | `RunThinkers_TypeC` |
| `$03D1BB` | `code_03D1BB` | `RunThinkers_TypeC_Next` |
| `$03D1C2` | `func_03D1C2` | `RunThinkers_TypeD` |
| `$03D1EE` | `code_03D1EE` | `RunThinkers_TypeD_Next` |

### Split 5: `tile_collision.asm`

| Address | Current Name | Proposed Name |
|---------|-------------|---------------|
| `$03D1F5` | `func_03D1F5` | `ApplyMovement` |
| `$03D276` | `func_03D276` | `ApplyMovementWithCollision` |
| `$03D2B9` | `code_03D2B9` | `CollisionX_PostMove` |
| `$03D337` | `code_03D337` | `CollisionY_Setup` |
| `$03D39C` | `code_03D39C` | `TileCollision_MoveLeft` |
| `$03D41F` | `code_03D41F` | `TileCollision_MoveRight` |
| `$03D4AD` | `func_03D4AD` | `TileTypeJumpTable_Horizontal` |
| `$03D4CD` | `code_03D4CD` | `TileCollision_SolidH` |
| `$03D4CE` | `code_03D4CE` | `TileCollision_BlockH` |
| `$03D53B` | `code_03D53B` | `TileCollision_PassH` |
| `$03D541` | `code_03D541` | `TileCollision_CheckAdjacentH` |
| `$03D556` | `code_03D556` | `TileCollision_MoveUp` |
| `$03D5D7` | `code_03D5D7` | `TileCollision_MoveDown` |
| `$03D65C` | `func_03D65C` | `TileTypeJumpTable_Vertical` |
| `$03D67C` | `func_03D67C` | `TileCollision_BlockV` |
| `$03D6E9` | `code_03D6E9` | `TileCollision_PassV` |
| `$03D6EF` | `func_03D6EF` | `TileCollision_CheckAdjacentV` |
| `$03D704` | `func_03D704` | `TileCollision_SolidV` |
| `$03D708` | `func_03D708` | `CheckActorOnSpecialTile` |
| `$03D78A` | `func_03D78A` | `CalcTileMapOffset` |
| `$03D7B4` | `func_03D7B4` | `AdvanceTileOffsetRight` |
| `$03D7CA` | `sub_03D7CA` | `AdvanceTileOffsetDown` |
| `$03D7E7` | `func_03D7E7` | `SpawnSceneThinkers` |
| `$03D831` | `sub_03D831` | `InitThinkerFromSceneData` |
| `$03D86A` | `zero_bytes_03D86A` | `ClearActorRenderList` |

### Split 6: `scene_lifecycle.asm`

| Address | Current Name | Proposed Name |
|---------|-------------|---------------|
| `$03D881` | `func_03D881` | `DmaPlayerTilesToVram` |
| `$03D8D8` | `sub_03D8D8` | `DmaPlayerTiles_UpperHalf` |
| `$03D8F2` | `sub_03D8F2` | `DmaPlayerTiles_LowerHalf` |
| `$03D916` | `func_03D916` | `SaveGameState` |
| `$03D954` | `func_03D954` | `LoadGameState` |
| `$03D994` | `func_03D994` | `ClearSaveSlot` |
| `$03D9B8` | `func_03D9B8` | `ComputeSaveChecksum` |
| `$03D9E8` | `func_03D9E8` | `CheckSceneTransition` |
| `$03D9F6` | `func_03D9F6` | `ExecuteSceneTransition` |
| `$03DABB` | `sub_03DABB` | `ScreenExitTransition` |
| `$03DBA4` | `code_03DBA4` | `ScreenExitTransition_WaveAlt` |
| `$03DBF6` | `sub_03DBF6` | `ApplyScrollWaveEffect` |
| `$03DC39` | `sub_03DC39` | `ComputeSineScrollTable` |
| `$03DC92` | `sub_03DC92` | `ScreenEnterTransition` |
| `$03DD56` | `func_03DD56` | `ClearSceneState` |
| `$03DECD` | `func_03DECD` | `LoadHudTilemap` |
| `$03DF0A` | `word_03DF0A` | `HudTilemapData` |
| `$03DFA0` | `func_03DFA0` | `LoadScenePalettes` |
| `$03DFF8` | `func_03DFF8` | `LoadPlayerGraphics` |
| `$03E050` | `func_03E050` | `InitCameraBounds` |

### Split 7: `dialogue_engine.asm`

| Address | Current Name | Proposed Name |
|---------|-------------|---------------|
| `$03E0B0` | `func_03E0B0` | `LoadPaletteBundle` |
| `$03E125` | `func_03E125` | `DecompressGfxToVram` |
| `$03E146` | `func_03E146` | `ResetHdmaState` |
| `$03E157` | `func_03E157` | `SetupHdmaChannel_Indirect` |
| `$03E173` | `func_03E173` | `SetupHdmaChannel_Direct` |
| `$03E1AA` | `func_03E1AA` | `SpcCheckMusicReady` |
| `$03E1D6` | `func_03E1D6` | `SpcTransferMusicData` |
| `$03E21E` | `func_03E21E` | `LoadMusicFromTransitionState` |
| `$03E255` | `sub_03E255` | `WideStringRenderer` |
| `$03E2C3` | `wide_cmd_table_03E2C3` | `WideStringCommandTable` |
| `$03E2F5` | `cmd_c0_03E2F5` | `WideCmd_EndAndWait` |
| `$03E307` | `code_03E307` | `WideCmd_Return` |
| `$03E30F` | `cmd_c1_03E30F` | `WideCmd_SetPosition` |
| `$03E335` | `cmd_c2_03E335` | `WideCmd_InsertTemplate` |
| `$03E35B` | `cmd_c3_03E35B` | `WideCmd_SetPalette` |
| `$03E36B` | `cmd_c4_03E36B` | `WideCmd_InfiniteLoop` |
| `$03E36F` | `cmd_c5_03E36F` | `WideCmd_IndirectString` |
| `$03E393` | `cmd_c6_03E393` | `WideCmd_PrintNumber` |
| `$03E42F` | `binary_03E42F` | `HexDigitTileTable` |
| `$03E43F` | `cmd_c7_03E43F` | `WideCmd_OpenDialogueBox` |
| `$03E4CE` | `dlg_borders_03E4CE` | `DialogueBorderTiles` |
| `$03E4DE` | `sub_03E4DE` | `DrawDialogueBorderRow` |
| `$03E505` | `sub_03E505` | `DrawDialogueBodyRows` |
| `$03E579` | `cmd_c8_03E579` | `WideCmd_ClearDialogueBox` |
| `$03E5EB` | `cmd_c9_03E5EB` | `WideCmd_WaitFrames` |
| `$03E5F8` | `cmd_cb_03E5F8` | `WideCmd_NewLine` |
| `$03E61E` | `cmd_cc_03E61E` | `WideCmd_AdvanceCursor` |
| `$03E636` | `cmd_cd_03E636` | `WideCmd_InsertRemoteString` |
| `$03E656` | `cmd_ce_03E656` | `WideCmd_ClearBox` |
| `$03E6A4` | `cmd_cf_03E6A4` | `WideCmd_WaitForButton` |
| `$03E6D2` | `cmd_d0_03E6D2` | `WideCmd_WaitForAnyInput` |
| `$03E6E7` | `cmd_d1_03E6E7` | `WideCmd_JumpToAddress` |
| `$03E6EC` | `cmd_d2_03E6EC` | `WideCmd_SetSfx` |
| `$03E6F7` | `cmd_d3_03E6F7` | `WideCmd_OpenDefaultBox` |
| `$03E721` | `cmd_d4_03E721` | `WideCmd_SetPaletteColor` |
| `$03E736` | `cmd_d5_03E736` | `WideCmd_SetFrameDelay` |
| `$03E743` | `cmd_d6_03E743` | `WideCmd_DictionaryA` |
| `$03E769` | `cmd_d7_03E769` | `WideCmd_DictionaryB` |
| `$03E78F` | `cmd_d8_03E78F` | `WideCmd_PrintRawTiles` |
| `$03E7B2` | `sub_03E7B2` | `WaitOneFrame` |
| `$03E7B5` | `code_03E7B5` | `WaitNFrames_Entry` |
| `$03E7BA` | `code_03E7BA` | `WaitNFrames_PerChar` |
| `$03E7CB` | `code_03E7CB` | `WaitNFrames_Loop` |
| `$03E7D6` | `sub_03E7D6` | `ScrollDialogueUp` |
| `$03E80C` | `sub_03E80C` | `DrawDialogueCursor` |
| `$03E849` | `func_03E849` | `MenuSelectionHandler` |
| `$03E8FC` | `code_03E8FC` | `MenuSelection_Down` |
| `$03E93C` | `code_03E93C` | `MenuSelection_LeftRight` |
| `$03E983` | `sub_03E983` | `DrawMenuCursor` |
| `$03EA2A` | `sub_03EA2A` | `ReadMenuSelection` |

### Split 8: `hud_inventory.asm`

| Address | Current Name | Proposed Name |
|---------|-------------|---------------|
| `$03EA62` | `func_03EA62` | `AsciiStringRenderer` |
| `$03EA8C` | `asciistring_cmd_table_03EA8C` | `AsciiStringCommandTable` |
| `$03EAB0` | `cmd_11_03EAB0` | `AsciiCmd_AdvanceRow2` |
| `$03EABD` | `cmd_10_03EABD` | `AsciiCmd_InsertItemName` |
| `$03EAE2` | `cmd_0F_03EAE2` | `AsciiCmd_ClearRect` |
| `$03EB1B` | `cmd_0A_03EB1B` | `AsciiCmd_DrawPlayerHpBar` |
| `$03EB71` | `sub_03EB71` | `DrawHpBar` |
| `$03EBE6` | `sub_03EBE6` | `HpBar_AdvanceRow` |
| `$03EBFC` | `cmd_0B_03EBFC` | `AsciiCmd_DrawEnemyHpBar` |
| `$03EC52` | `cmd_00_03EC52` | `AsciiCmd_End` |
| `$03EC57` | `cmd_0D_03EC57` | `AsciiCmd_AdvanceRow4` |
| `$03EC64` | `cmd_0E_03EC64` | `AsciiCmd_Print3DigitNumber` |
| `$03ED00` | `cmd_01_03ED00` | `AsciiCmd_SetVramAddr` |
| `$03ED0B` | `cmd_02_03ED0B` | `AsciiCmd_InsertRemoteString` |
| `$03ED2B` | `cmd_03_03ED2B` | `AsciiCmd_SetPalette` |
| `$03ED3C` | `cmd_04_03ED3C` | `AsciiCmd_IndirectString` |
| `$03ED6F` | `cmd_05_03ED6F` | `AsciiCmd_PrintBcdNumber` |
| `$03EDE3` | `cmd_06_03EDE3` | `AsciiCmd_DrawBox` |
| `$03EEA5` | `cmd_07_03EEA5` | `AsciiCmd_ClearColumn` |
| `$03EEF5` | `cmd_08_03EEF5` | `AsciiCmd_FillTile` |
| `$03EF1F` | `cmd_0C_03EF1F` | `AsciiCmd_PrintRawBytes` |
| `$03EF3E` | `cmd_09_03EF3E` | `AsciiCmd_PrintEquipIcons` |
| `$03EF97` | `func_03EF97` | `GiveItemToPlayer` |
| `$03F051` | `code_03F051` | `GiveItem_DefUp` |
| `$03F070` | `code_03F070` | `GiveItem_StoreInSlot` |
| `$03F07D` | `code_03F07D` | `GiveItem_Success` |
| `$03F080` | `code_03F080` | `GiveItem_InventoryFull` |
| `$03F08D` | `func_03F08D` | `RemoveItemFromInventory` |
| `$03F0B3` | `func_03F0B3` | `CheckInventoryForItem` |
| `$03F0CA` | `func_03F0CA` | `GetPlayerFacingFromAnim` |
| `$03F0EE` | `code_03F0EE` | `GetPlayerFacing_AltEntry` |
| `$03F11F` | `binary_03F11F` | `FacingDirectionLookup` |
| `$03F177` | `table_03F177` | `FacingFormOffsetTable` |
| `$03F17F` | `binary_03F17F` | `FacingData_Will` |
| `$03F19A` | `binary_03F19A` | `FacingData_Freedan` |
| `$03F1C6` | `binary_03F1C6` | `FacingData_Shadow_A` |
| `$03F1CA` | `binary_03F1CA` | `FacingData_Shadow_B` |
| `$03F1D0` | `func_03F1D0` | `DmaAdhocVramBlock` |

---

## 7. Statistics

| Metric | Value |
|--------|-------|
| Total parts | 170 |
| Proposed splits | 8 files |
| Cross-split calls | ~25 |
| Internal calls (within splits) | ~175+ |
| External callers | 49 unique symbols from 20 files |
| Most-referenced externally | `func_03CA55` (20 files), `func_03F0CA` (24 refs) |
| Largest proposed split | dialogue_engine.asm (~44 parts, ~1400 lines) |
| Smallest proposed split | oam_digit_compose.asm (~3 parts, ~80 lines) |
