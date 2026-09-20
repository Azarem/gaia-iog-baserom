# IOG COP Documentation Plan

## Goal

Split the monolithic `cop-commands-reference.md` into focused family docs under `docs/cop/families/`, create an index overview at `docs/cop/index.md`, and fix naming inconsistencies in `copdef.json`. Use Robotrek's `docs/cop/` as the structural template.

## Source files (ASM families)

The 14 existing handler files under `extracted/system/engine/`:

| ASM file | Handlers | COP ops |
|----------|----------|---------|
| `cop_handlers_solid.asm` | 25 | $00–$03 (HDMA/DMA), $0B–$18 + $1A–$1E + $42 + $62 (collision) |
| `cop_handlers_audio.asm` | 8 | $04–$0A, $19 |
| `cop_handlers_movement.asm` | 9 | $1F–$24, $43, $4A, $52–$53 |
| `cop_handlers_spatial.asm` | 14 | $25–$31, $35 |
| `cop_handlers_palette.asm` | 11 | $32–$34, $36–$3A, $3B–$3D |
| `cop_handlers_input.asm` | 11 | $3E–$41, $65–$67, $6B, $BD–$BF |
| `cop_handlers_lifecycle.asm` | 37 | $44–$49, $55–$5E, $68–$6A, $A7–$B1, $B2–$BC |
| `cop_handlers_map.asm` | 12 | $4B–$4E, $4F–$51, $54 |
| `cop_handlers_effects.asm` | 11 | $5F–$61, $63–$64, $6C–$6D, $DC–$DF |
| `cop_handlers_sprite.asm` | 16 | $80–$8D |
| `cop_handlers_player_sprite.asm` | 11 | $8E–$98 |
| `cop_handlers_spawn.asm` | 14 | $99–$A6 |
| `cop_handlers_flow.asm` | 30 | $C0–$CB, $CC–$D3, $D4–$D7, $D8–$DB, $E0–$E2 |
| `flag_helpers.asm` | — | (flag library, not COP handlers) |

## Documentation family split (38 doc files)

More focused than the ASM split — large ASM files become multiple doc families:

| # | Doc file | Ops | Count | Source ASM | Description |
|---|----------|-----|------:|------------|-------------|
| 1 | `hdma_dma.md` | $00–$03 | 4 | solid | HDMA/DMA channel setup |
| 2 | `audio.md` | $04–$0A, $19 | 8 | audio | Music, SFX, APU |
| 3 | `collision_paint.md` | $0B–$12, $42 | 9 | solid | Solidity/collision painting & clearing |
| 4 | `collision_branch.md` | $13–$18, $1A–$1E, $62 | 12 | solid | Collision/solid branch tests |
| 5 | `proximity.md` | $1F–$21, $44–$45 | 5 | movement + lifecycle | Grid, distance, area branches |
| 6 | `movement.md` | $22, $43, $4A, $52–$53 | 5 | movement | MoveToward, snap, staged moves |
| 7 | `rng.md` | $23–$24 | 2 | movement | Random number generation |
| 8 | `position.md` | $25, $46–$47, $BC | 4 | spatial + lifecycle | Position set/copy/nudge |
| 9 | `map_transition.md` | $26, $65–$67 | 4 | spatial + input | Map/world map transitions |
| 10 | `offscreen.md` | $27, $68–$69 | 3 | spatial + lifecycle | Offscreen wait/branch/halt |
| 11 | `player_query.md` | $28–$31, $35, $48–$49 | 13 | spatial + lifecycle | Player position/direction/facing/body |
| 12 | `bg_rearrange.md` | $32–$34 | 3 | palette | BG tilemap rearrange |
| 13 | `palette.md` | $36–$3A | 5 | palette | Palette bundle animation |
| 14 | `thinkers.md` | $3B–$3D | 3 | palette | Thinker lifecycle |
| 15 | `input.md` | $3E–$41 | 4 | input | Button wait/branch |
| 16 | `metatile.md` | $4B–$4E | 4 | map | Metatile draw + world map streams |
| 17 | `vram_memory.md` | $4F–$51, $54 | 4 | map | VRAM DMA, palette copy, decompress |
| 18 | `sprite_state.md` | $55–$56 | 2 | lifecycle | Sprite reset/advance |
| 19 | `callbacks.md` | $57–$5A, $5E | 5 | lifecycle | Combat/interaction callbacks |
| 20 | `actor_flags.md` | $5B–$5D | 3 | lifecycle | Extra flag manipulation + wall occlusion |
| 21 | `sine_hdma.md` | $5F–$61 | 3 | effects | Sine wave HDMA effects |
| 22 | `gravity.md` | $63–$64 | 2 | effects | Gravity physics |
| 23 | `dialog.md` | $6B, $BD–$BF | 4 | input | Text/dialogue, BG3 script, choices |
| 24 | `linked_actor.md` | $6A | 1 | lifecycle | Linked actor entry ptr |
| 25 | `spiral.md` | $6C–$6D | 2 | effects | Orbital/spiral motion |
| 26 | `sprite_staging.md` | $80–$87, $8D | 9 | sprite | Sprite frame staging |
| 27 | `sprite_anim.md` | $88–$8C | 5 | sprite | Animation execution/wait |
| 28 | `player_sprite.md` | $8E–$98 | 11 | player_sprite | Player body sprites + wall checks |
| 29 | `actor_spawn.md` | $99–$A6 | 14 | spawn | Actor allocation |
| 30 | `actor_death.md` | $A7–$A9, $E0 | 4 | lifecycle + flow | Actor death/removal |
| 31 | `force_move.md` | $AA–$B1 | 8 | lifecycle | Force-move staging |
| 32 | `oam_attribs.md` | $B2–$BB | 10 | lifecycle | OAM priority/palette/mirror |
| 33 | `script_control.md` | $C0–$CB, $E1–$E2 | 14 | flow | Script VM control flow |
| 34 | `scene_flags.md` | $CC–$D3 | 8 | flow | Story flag operations |
| 35 | `inventory.md` | $D4–$D7 | 4 | flow | Item give/remove/branch |
| 36 | `dungeon_switch.md` | $D8–$D9 | 2 | flow | Dungeon kill flag + switch case |
| 37 | `wait.md` | $DA–$DB | 2 | flow | Frame delays |
| 38 | `camera.md` | $DC–$DF | 4 | effects | Camera panning |
| — | `invalid_ops.md` | $6E–$7F, $E3 | 19 | — | Invalid/phantom opcodes |

**Total valid opcodes documented: 209**

## copdef.json naming corrections

These copdef names are inaccurate or inconsistent with the ASM labels and monolith analysis. **Proposed renames** (copdef → corrected):

### Collision naming
| Current | Proposed | Reason |
|---------|----------|--------|
| `SolidHighHere` | `MarkSolidHere` | Matches Robotrek `solid_on`; "high" is implementation detail |
| `ClearLowHere` | `ClearSolidHere` | Matches Robotrek `solid_off` |
| `SolidHighOffset` | `MarkSolidOffset` | Consistency |
| `ClearLowOffset` | `ClearSolidOffset` | Consistency |
| `SolidHighAbs` | `MarkSolidAbs` | Consistency |
| `ClearLowAbs` | `ClearSolidAbs` | Consistency |
| `ClearAllHere` | `ClearCollisionHere` | Clears both nibbles |
| `ClearHighAbs` | `ClearTypeAbs` | Clears type nibble (low), not high |
| `BranchIfSolid` | `BranchIfSolidHere` | Missing positional suffix |
| `SetSolidAbs` | `SetCollisionAbs` | Sets full byte, not just solid |
| `BranchIfSolidNibbleNe` | `BranchIfCollisionTypeNe` | Clearer |

### Input naming
| Current | Proposed | Reason |
|---------|----------|--------|
| `WaitUntilButton` | `WaitForButton` | Simpler |
| `WaitUntilNoButton` | `WaitForRelease` | Describes what it waits for |
| `BranchIfButton` | `BranchIfPressed` | Clearer |
| `BranchIfNoButton` | `BranchIfNotPressed` | Clearer |

### Actor flags / misc
| Current | Proposed | Reason |
|---------|----------|--------|
| `SetAnimScratch` | `SetScratchPointer` | Generic far pointer, not anim-specific |
| `ResetSpriteInit` | `ResetSpriteState` | More accurate |
| `LoadSpriteAnimGlobal` | `AdvanceSpriteAnim` | Advances, doesn't load |
| `OrActorFlags` | `OrExtraFlags` | Writes `$7F002A`, not actor `$10` |
| `AndActorFlags` | `AndExtraFlags` | Same |
| `SetExtraCallback` | `SetCustomCallback` | Consistent with monolith |
| `BranchIfOffscreen` | `BranchIfOffCamera` | Tests camera bounds, not render cull |
| `HaltIfCounterGte` | `HaltIfMaxFrames` | Clearer purpose |
| `SetLinkedActorScript` | `SetLinkedEntryPtr` | Sets entry ptr, not script |

### Sprite naming
| Current | Proposed | Reason |
|---------|----------|--------|
| `ContinueIfFrame` | `WaitForAnimFrame` | It halts/waits, doesn't continue |
| `SetPlayerBodySprite` | `SetPlayerSpriteDirect` | Direct write, not body-table |
| `AnimPlayerOnce` | `RunPlayerAnim` | Consistency with generic `AnimOnce` |
| `StagePlayerMoveXYWall` | `StagePlayerSprWall` | It's a sprite staging op |
| `StagePlayerSpriteFromBank` | `StagePlayerSprFromDP` | Reads from DP $0000, not "bank" |
| `WallCheckCurrent/North/South` | `WallAnimHere/North/South` | Runs wall-gated animation, not just a check |

### Spawn naming
| Current | Proposed | Reason |
|---------|----------|--------|
| `SpawnAfterRel` | `SpawnAfterOffset` | "Offset" matches Robotrek; "Rel" ambiguous |
| `SpawnAfterRelFlags` | `SpawnAfterOffsetFlags` | Consistency |
| `SpawnMarkedBefore` | `SpawnBeforeMarked` | Put link-type first, modifier last |
| `SpawnMarkedAfter` | `SpawnAfterMarked` | Consistency |
| `SpawnMarkedAfterAbs` | `SpawnAfterAbsMarked` | Consistency |
| `SpawnMarkedAfterRel` | `SpawnAfterOffsetMarked` | Consistency |
| `SpawnLastRel` | `SpawnListAppend` | "List append" is what it does |
| `SpawnLastRelSpr` | `SpawnListAppendSpr` | Consistency |

### Force-move / OAM naming
| Current | Proposed | Reason |
|---------|----------|--------|
| `StageForceMoveX/Y/XY` | `StageMoveX/Y/XY` | Clearer without redundant "Force" |
| `SetForceSW/NE/Both` | `ForceDirSW/NE/Both` | Sets direction, not force itself |
| `ForceMoveLastChild` | `ApplyMoveToChild` | Clearer |
| `ReloadForceMove` | `ReloadMoveDurations` | More specific |
| `CollPrioritySetMax/Min` | `SetPriorityMax/Min` | Simpler |
| `CollPriorityClearMax/Min` | `ClearPriorityMax/Min` | Simpler |
| `ToggleHFlip/VFlip` | `ToggleHMirror/VMirror` | "Mirror" matches OAM terminology |
| `ClearHFlip/SetHFlip` | `ClearHMirror/SetHMirror` | Consistency |
| `AddPosition` | `NudgePosition` | More descriptive |

### Script control naming
| Current | Proposed | Reason |
|---------|----------|--------|
| `SetOnInteract` | `SetInteractHandler` | It installs a handler |
| `SetEntryContinue` | `SetEntryHere` | Sets entry to current PC |
| `SetEntryExit` | `SetEntryHereAndYield` | Also yields |
| `SetEntryDelayExit` | `JumpAfterDelay` | It jumps, not just sets entry |
| `SetEntryExitNow` | `JumpNextFrame` | Jumps next frame |
| `JumpScript` | `JumpFar` | Simpler; matches Robotrek `goto_far` |
| `CallScript` | `CallNear` | Matches Robotrek pattern |
| `CallScriptDeferred` | `CallNearDeferred` | Consistency |
| `LoopInit` | `LoopStart` | Matches Robotrek `repeat_begin` |
| `LoopNext` | `LoopEnd` | Matches Robotrek `repeat_yield` |
| `RestoreSavedPtrFFFF` | `ReturnWithSignal` | It returns and sets A=$FFFF |
| `SetEntryContinueDeferred` | `SetEntryFar` | Far version of SetEntryHere |

### Flag / inventory naming
| Current | Proposed | Reason |
|---------|----------|--------|
| `BranchIfFlagByte/Word` | `BranchOnFlagByte/Word` | Branches on a value (0 or 1) |
| `ExitIfFlagByte/Word` | `WaitOnFlagByte/Word` | Yields/waits, not exits |
| `BranchIfNoItem` | `BranchIfMissingItem` | Clearer polarity |
| `BranchIfEquipped` | `BranchIfItemEquipped` | More specific |

### Camera naming
| Current | Proposed | Reason |
|---------|----------|--------|
| `PanCameraDown/Up/Right/Left` | `CameraPanDown/Up/Right/Left` | Noun-verb order matches Robotrek |

## copdef.json structural fixes

| Opcode | Issue | Fix |
|--------|-------|-----|
| `$03` (`QueueHdmaChannel`) | Parts `["Byte","Word","Word"]` → should be `["Byte","Address","Byte"]` | Fix part types |
| `$31` (`BranchOnPlayerFacing`) | `size:10` / 5 `&Code` → only 4 targets used (ASM reads 4 words) | Change to 4 `&Code`s, size:8 |
| `$A6` (`SpawnListAppendSpr`) | Part order wrong vs ROM layout | Fix order |
| `$9D`/`$9F`/`$A0`/`$A3`/`$A4`/`$A5`/`$A6` | Far ptrs listed as Word+Byte instead of @Code | Fix to `@Code` |

## Document template

Each family doc follows this structure (from Robotrek):

```markdown
# COP family: <Family Name>

_Ops: `[XX]`, `[YY]`, ..._ · _Source: `cop_handlers_<name>.asm`_

[← COP index](../index.md)

## Overview
<1-2 paragraph summary>

## Shared state
<WRAM addresses and helper functions used by multiple ops>

## Family notes
<Cross-references, gotchas, false neighbors>

## Usage statistics
| Op | Name | Params | Handler | Outcome |
|----|------|--------|---------|---------|
<table rows>

## Opcodes

#### COP [XX] — `Name` (<short description>)
- **Handler:** `label` @ `path:lines`
- **Parameters:** <type list>
- **Outcome:** Continue / Branch / Halt
- **What it does:** <ASM excerpt + explanation>
- **Usage:** <common patterns, example code>
```

## Execution order

### Phase 1: Infrastructure
- [x] Create `docs/cop/` and `docs/cop/families/` directories
- [x] Create `docs/cop/index.md` — high-level overview with family table, opcode roster, top opcodes

### Phase 2: Family docs (create all 38 + invalid) — ✅ COMPLETE
All 39 family documents created:
1. [x] `script_control.md` — $C0–$CB, $E1–$E2 (14 ops)
2. [x] `scene_flags.md` — $CC–$D3 (8 ops)
3. [x] `collision_paint.md` — $0B–$12, $42 (9 ops)
4. [x] `collision_branch.md` — $13–$18, $1A–$1E, $62 (12 ops)
5. [x] `audio.md` — $04–$0A, $19 (8 ops)
6. [x] `actor_spawn.md` — $99–$A6 (14 ops)
7. [x] `sprite_staging.md` — $80–$87, $8D (9 ops)
8. [x] `sprite_anim.md` — $88–$8C (5 ops)
9. [x] `player_sprite.md` — $8E–$98 (11 ops)
10. [x] `player_query.md` — $28–$31, $35, $48–$49 (13 ops)
11. [x] `dialog.md` — $6B, $BD–$BF (4 ops)
12. [x] `oam_attribs.md` — $B2–$BB (10 ops)
13. [x] `actor_death.md` — $A7–$A9, $E0 (4 ops)
14. [x] `force_move.md` — $AA–$B1 (8 ops)
15. [x] `movement.md` — $22, $43, $4A, $52–$53 (5 ops)
16. [x] `proximity.md` — $1F–$21, $44–$45 (5 ops)
17. [x] `callbacks.md` — $57–$5A, $5E (5 ops)
18. [x] `hdma_dma.md` — $00–$03 (4 ops)
19. [x] `input.md` — $3E–$41 (4 ops)
20. [x] `inventory.md` — $D4–$D7 (4 ops)
21. [x] `map_transition.md` — $26, $65–$67 (4 ops)
22. [x] `palette.md` — $36–$3A (5 ops)
23. [x] `vram_memory.md` — $4F–$51, $54 (4 ops)
24. [x] `metatile.md` — $4B–$4E (4 ops)
25. [x] `camera.md` — $DC–$DF (4 ops)
26. [x] `position.md` — $25, $46–$47, $BC (4 ops)
27. [x] `bg_rearrange.md` — $32–$34 (3 ops)
28. [x] `thinkers.md` — $3B–$3D (3 ops)
29. [x] `offscreen.md` — $27, $68–$69 (3 ops)
30. [x] `actor_flags.md` — $5B–$5D (3 ops)
31. [x] `sine_hdma.md` — $5F–$61 (3 ops)
32. [x] `rng.md` — $23–$24 (2 ops)
33. [x] `gravity.md` — $63–$64 (2 ops)
34. [x] `spiral.md` — $6C–$6D (2 ops)
35. [x] `wait.md` — $DA–$DB (2 ops)
36. [x] `dungeon_switch.md` — $D8–$D9 (2 ops)
37. [x] `sprite_state.md` — $55–$56 (2 ops)
38. [x] `linked_actor.md` — $6A (1 op)
39. [x] `invalid_ops.md` — $6E–$7F, $E3 (19 phantom)

### Phase 3: copdef.json updates — ✅ COMPLETE
- [x] Apply all naming corrections (82 lines changed, ~75 renames)
- [x] Fix structural issues:
  - $03 QueueHdmaChannel: `["Byte","Word","Word"]` → `["Byte","Address","Byte"]`
  - $31 BranchOnPlayerFacing: 5 `&Code` / size:10 → 4 `&Code` / size:8
  - $9D SpawnAfterOffset: `["Word","Byte","Word","Word"]` → `["@Code","Word","Word"]`
  - $9F SpawnAfterAbs: `["Word","Byte","Word","Word"]` → `["@Code","Word","Word"]`
  - $A6 SpawnListAppendSpr: `["Word","Byte","Byte","Byte","Byte","Word"]` → `["@Code","Byte","Byte","Byte","Word"]`

**Note:** ~6,968 COP references across 686 extracted ASM files still use old names. A re-extract (`node src/index.ts extract`) is needed to regenerate ASM with updated names. 1 reference in IOGRetranslation modules will also need updating.

### Phase 4: Monolith retirement — ✅ COMPLETE
- [x] Added deprecation notice to `cop-commands-reference.md` (now archived, points to `cop/index.md`)
- [x] Updated `.cursor/rules/snes-knowledge.mdc` (IOG baserom)
- [x] Updated `gaia-knowledge/AGENTS.md` task routing table
- [x] Updated `gaia-knowledge/manifest.json` (both entries marked ARCHIVED)
- [x] Updated `gaia-knowledge/curated/gaialabs/assembler-syntax.md`
- [x] Updated `gaia-knowledge/curated/gaialabs/rom-mapping-guide.md`
- [ ] Remaining: ~20 `docs/code/` files still cross-reference the monolith (contextual links, low priority — monolith still exists with redirect)

### Phase 5: Knowledge corpus update — ✅ COMPLETE
- [x] Created `gaia-knowledge/corpus/games/iog/project-docs/cop/` with index + 39 family docs
- [x] Updated `corpus/games/iog/project-docs/index.md` to link to new COP index
- [ ] Re-ingest when ready: `npm run ingest:all` (in gaia-knowledge)
