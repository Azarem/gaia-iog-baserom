# Bank $00 — Functions: Player State, NPC AI & Escort

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00C397`–`$00C806`, `$00C98E`  
**Source files:** [`extracted/functions/ApplyPlayerHitstun.asm`](../../../extracted/functions/ApplyPlayerHitstun.asm), [`InitPlayerScriptVariant.asm`](../../../extracted/functions/InitPlayerScriptVariant.asm), [`npc_wander_ai.asm`](../../../extracted/functions/npc_wander_ai.asm) (contains `SyncActorPosFromDP`, `NpcRandomWanderAI`), [`ToggleActorVisibilityFlag.asm`](../../../extracted/functions/ToggleActorVisibilityFlag.asm), [`EscortFollowPathTracker.asm`](../../../extracted/functions/EscortFollowPathTracker.asm), [`f_inventory_full.asm`](../../../extracted/functions/f_inventory_full.asm)

These routines manage player damage response, COP script variant selection, town NPC wander behavior, party escort path tracking, actor visibility toggling, and the inventory-full message utility.

**Related:** [`actors-combat-interaction.md`](actors-combat-interaction.md) (`hit_stagger_controller` spawned by hitstun) · [`readme.md`](readme.md)

---

## Overview

| Function | Address | Size | Movable | Call Type | Priority |
|----------|---------|------|---------|-----------|----------|
| `ApplyPlayerHitstun` | `$C397` | 129 B | ✓ | JSL (~12 callers) | **High** |
| `InitPlayerScriptVariant` | `$C6E4` | 44 B + table | ✓ (with table) | JSL (~15 scenes) | **High** |
| `SyncActorPosFromDP` | `$C718` | 13 B | ✓ | JSL | Medium |
| `NpcRandomWanderAI` | `$C725` | 213 B | ✓ (with codes) | JSL (~12 callers) | **High** |
| `ToggleActorVisibilityFlag` | `$C7FA` | 12 B | ✓ | COP `SpawnAfterAbsFlags` | Medium |
| `EscortFollowPathTracker` | `$C806` | 317 B + array | ✓ (with array) | COP `SpawnAfterFlags` | **High** |
| `InventoryFullMessage` | `$C98E` | 42 B | ✓ | JML (10+ scenes) | Medium |

---

## ApplyPlayerHitstun

**Address:** `$C397` · **Size:** 129 bytes · **Movable:** Yes · **Priority:** **High** (~12 enemy callers)

### Description

Damage knockback entry point called when the player takes a hit from an enemy attack. Sets a stun timer on the player actor, spawns the `hit_stagger_controller` actor (`$D877`) for directional knockback animation, and masks joypad input during the stun window.

Approximately 12 enemy types call this via JSL with the knockback direction pushed on the stack. The function preserves the player's current script pointer so control can be restored after the stagger completes.

### Algorithm

```
1. LDX $player_actor
2. Store stun duration to $7F0028,X (from parameter)
3. Mask joypad: ORA #$FFFF → $joypad_mask_std
4. Save current player script pointer
5. Push knockback direction (0–3) on stack
6. COP [SpawnLastRel] @HitStaggerMain with flags #$2400
7. Set $12 bit $0008 (stagger active on player)
8. RTL
```

### Variables

| Symbol | Role |
|--------|------|
| `$player_actor` | Player slot index |
| `$7F0028,X` | Stun timer duration |
| `$joypad_mask_std` | Blocked during stagger |
| `$12,X` bit `$0008` | Stagger-active flag |
| Stack param | Knockback direction (N/S/E/W) |

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Spawns | `hit_stagger_controller` | `SpawnLastRel @HitStaggerMain` |
| Called from | ~12 enemy attack scripts | JSL |
| Returns to | `PlayerIdleEntry` | Via stagger controller on completion |

---

## InitPlayerScriptVariant

**Address:** `$C6E4` · **Size:** 44 bytes + 8-byte table · **Movable:** Yes (must move with `table_00C710`) · **Priority:** **High** (~15 scenes)

### Description

Selects the appropriate player COP script variant from a 4-entry pointer table (`table_00C710`) based on the current scene context or player state. Used when entering scenes that require a modified player behavior — cutscene walking, forced movement, swimming, or combat-specific control schemes.

Each table entry is a 2-byte `$&` pointer to a player script entry point in bank `$00`. The selection index is passed in A on entry (typically derived from scene metadata or event flags).

### Algorithm

```
1. Transfer index to X (0–3)
2. LDA table_00C710,X  ; Load 2-byte script pointer
3. STA $7F0000,X       ; Write to player actor entry pointer
4. RTL
```

### Table: `table_00C710`

| Index | Purpose | Typical Scene |
|-------|---------|---------------|
| 0 | Normal field control | Default overworld |
| 1 | Cutscene walk variant | Story sequences |
| 2 | Restricted movement | Dungeons with locks |
| 3 | Special form control | Freedan/Shadow areas |

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Co-located | `table_00C710` | 4 × 2-byte `$&Code$2` pointers |
| Called from | ~15 scene init scripts | JSL |

---

## SyncActorPosFromDP

**Address:** `$C718` · **Size:** 13 bytes · **Movable:** Yes

### Description

Copies the actor's direct-page position variables `$14` (X) and `$16` (Y) into the actor's WRAM extended fields at `$7F0010,X` and `$7F0012,X`. Called at the start of `NpcRandomWanderAI` to ensure the wander loop operates on the actor's actual pixel position rather than stale WRAM values.

Minimal leaf function — always paired with `NpcRandomWanderAI` in practice.

### Algorithm

```
1. LDA $14        ; DP position X
2. STA $7F0010,X  ; WRAM position X
3. LDA $16        ; DP position Y
4. STA $7F0012,X  ; WRAM position Y
5. RTL (falls through to NpcRandomWanderAI when JSR'd in sequence)
```

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Paired with | `NpcRandomWanderAI` | Always called first |

---

## NpcRandomWanderAI

**Address:** `$C725` · **Size:** 213 bytes · **Movable:** Yes (move with embedded direction codes) · **Priority:** **High** (~12 town NPC callers)

### Description

RNG-driven 8-direction random walk with tile collision checking. Used by town NPCs that patrol without a fixed path — they periodically pick a random direction, attempt to move one tile, and reverse if blocked by a solid tile or map boundary.

The function contains eight direction handler blocks (N, NE, E, SE, S, SW, W, NW) dispatched via `code_list_00C733` (8-entry jump table). Each handler:

1. Computes target tile from current position + direction delta
2. Calls `$@CalcTileMapOffset` (bank `$03` tile collision query)
3. If passable: update position, stage walking sprite, animate one step
4. If blocked: pick new random direction or wait

### Algorithm

```
1. (Caller JSR SyncActorPosFromDP first)
2. Decrement wander timer at $7F0008,X
3. If timer > 0: RTL (still walking current direction)
4. JSR random → AND #$07 → direction index 0–7
5. Jump via code_list_00C733 to direction handler
6. Direction handler:
     a. Compute target coords
     b. JSL $@CalcTileMapOffset — tile collision
     c. If blocked: reset timer, RTL
     d. If clear: move 8 pixels, stage sprite, AnimOnce
7. Set wander timer (random 30–120 frames)
8. RTL
```

### Variables

| Symbol | Role |
|--------|------|
| `$14`, `$16` | Current pixel position |
| `$7F0008,X` | Wander timer / step counter |
| `$7F0010,X`, `$7F0012,X` | WRAM position copy |
| `$28` | Sprite frame index |
| `code_list_00C733` | 8-entry direction dispatch table |

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Preceded by | `SyncActorPosFromDP` | Position sync |
| External | `CalcTileMapOffset` | Bank `$03` tile collision |
| Called from | ~12 town NPC scripts | JSL |

---

## ToggleActorVisibilityFlag

**Address:** `$C7FA` · **Size:** 12 bytes · **Movable:** Yes

### Description

Toggles visibility on a referenced actor by XOR-ing `$12` bit `$2000` (marked/visible flag). The target actor index is passed in `$0000` (direct page). Used by palace room scripts and cutscene logic to show/hide NPCs without destroying and respawning them.

Invoked via `COP [SpawnAfterAbsFlags]` from scene scripts that need timed visibility changes (e.g., a character appearing when the player enters a trigger zone).

### Algorithm

```
1. LDY $0000       ; Target actor index
2. LDA $12,Y
3. EOR #$2000      ; Toggle visibility bit
4. STA $12,Y
5. RTL
```

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Invoked via | COP `SpawnAfterAbsFlags` | Scene scripts |

---

## EscortFollowPathTracker

**Address:** `$C806` · **Size:** 317 bytes + 32-byte array · **Movable:** Yes (move with `array_00C943`) · **Priority:** **High**

### Description

Ring buffer of 9 XY waypoint pairs recording the player's recent path for party escort NPCs (Kara, Lily, etc.). Each frame, the player's `$14`/`$16` position is written to the next slot in the ring; escort NPCs read from trailing slots to follow the player's exact path with a delay.

The direction delta table `array_00C943` maps movement direction indices to X/Y offset pairs for step computation. Escort NPCs call `$@GetPlayerFacingDirection` (bank `$03` layer lookup) to ensure they stay on the same map layer as the player.

### Algorithm

```
1. Read player position ($14/$16 via $player_actor)
2. Write to ring buffer slot [write_index]:
     buffer[write_index].x = player_x
     buffer[write_index].y = player_y
3. write_index = (write_index + 1) % 9
4. For escort actor (via $0000):
     a. read_index = (write_index - delay) % 9
     b. Load target from buffer[read_index]
     c. Compute direction via array_00C943 deltas
     d. Move escort toward target (8px steps)
     e. JSL $@GetPlayerFacingDirection — layer check
5. RTL
```

### Ring Buffer Layout

| Slot | Offset in buffer | Content |
|------|------------------|---------|
| 0–8 | 9 × 4 bytes | X word + Y word per waypoint |

### Variables

| Symbol | Role |
|--------|------|
| `$player_actor` | Player slot for position reads |
| `$0000` | Escort actor index |
| `$14`, `$16` | Current player position |
| `array_00C943` | Direction delta table (16 × 2-byte X/Y pairs) |
| Ring buffer | 9 × 4-byte XY entries in actor WRAM |

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Co-located | `array_00C943` | Direction delta Word array |
| External | `GetPlayerFacingDirection` | Bank `$03` layer lookup |
| Invoked via | COP `SpawnAfterFlags` | Escort scene scripts |
| Used by | Kara escort, party follow sequences | Multiple story scenes |

---

## InventoryFullMessage

**Address:** `$C98E` · **Size:** 42 bytes · **Movable:** Yes

### Description

Prints the message *"Your inventory is full. You can't carry more."* when a scene script or item pickup attempts to grant an item but the inventory has no free slots. Pure text utility with no `?INCLUDE` dependencies — a self-contained `PrintDialogString` call followed by `RTL`.

Jumped to via JML from 10+ scene scripts (shop purchases, NPC gifts, hidden item reveals).

### Algorithm

```
1. COP [PrintDialogString] dialogstring_00C993
2. RTL
```

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| JML from | 10+ scene scripts | Shop/gift/item scenes |
| JML from | Various scene scripts | Item grant overflow |
| Embedded string | `dialogstring_00C993` | Full inventory message text |

---

## Call Reference Matrix

| Caller Context | Function | Mechanism |
|----------------|----------|-----------|
| Enemy attack scripts (~12) | `ApplyPlayerHitstun` | JSL |
| Scene init scripts (~15) | `InitPlayerScriptVariant` | JSL |
| Town NPC scripts (~12) | `SyncActorPosFromDP` → `NpcRandomWanderAI` | JSL chain |
| Palace / cutscene scripts | `ToggleActorVisibilityFlag` | COP `SpawnAfterAbsFlags` |
| Escort sequences | `EscortFollowPathTracker` | COP `SpawnAfterFlags` |
| Shop / item scripts (10+) | `InventoryFullMessage` | JML |

---

## Statistics

| Metric | Value |
|--------|-------|
| Functions documented | 7 |
| Address span | `$C397`–`$C9B8` (~1,569 bytes) |
| High-priority entries | 4 |
| Multi-part blocks | 3 (`InitPlayerScriptVariant`, `npc_wander_ai`, `EscortFollowPathTracker`) |
| External bank deps | `$03` (`CalcTileMapOffset`, `GetPlayerFacingDirection`) |

---

*Source: `extracted/functions/*.asm`, `docs/code/bank00/actors-combat-interaction.md`.*
