# Bank $00 — Functions: Player State, NPC AI & Escort

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00C397`–`$00C806`, `$00C98E`  
**Source files:** [`extracted/functions/ApplyPlayerHitstun.asm`](../../../extracted/functions/ApplyPlayerHitstun.asm), [`SetPlayerIdleFacing.asm`](../../../extracted/functions/SetPlayerIdleFacing.asm), [`npc_wander_ai.asm`](../../../extracted/functions/npc_wander_ai.asm) (contains `SyncActorPosFromDP`, `NpcRandomWanderAI`), [`FlickerParentActor.asm`](../../../extracted/functions/FlickerParentActor.asm), [`EscortFollowPathTracker.asm`](../../../extracted/functions/EscortFollowPathTracker.asm), [`f_inventory_full.asm`](../../../extracted/functions/f_inventory_full.asm)

These routines manage player damage response, COP script variant selection, town NPC wander behavior, party escort path tracking, actor visibility toggling, and the inventory-full message utility.

**Related:** [`actors-combat-interaction.md`](actors-combat-interaction.md) (`hit_stagger_controller` spawned by hitstun) · [`README.md`](README.md)

---

## Overview

| Function | Address | Size | Movable | Call Type | Priority |
|----------|---------|------|---------|-----------|----------|
| `ApplyPlayerHitstun` | `$C397` | 129 B | ✓ | JSL (9 callers) | **High** |
| `SetPlayerIdleFacing` | `$C6E4` | 44 B + table | ✓ (with table) | JSL (~15 scenes) | **High** |
| `SyncActorPosFromDP` | `$C718` | 13 B | ✓ | JSL | Medium |
| `NpcRandomWanderAI` | `$C725` | 213 B | ✓ (with codes) | JSL (13 NPC actors) | **High** |
| `FlickerParentActor` | `$C7FA` | 12 B | ✓ | COP `SpawnAfterAbsFlags` | Medium |
| `EscortFollowPathTracker` | `$C806` | 317 B + array | ✓ (with array) | COP `SpawnAfterFlags` | **High** |
| `InventoryFullMessage` | `$C98E` | 42 B | ✓ | JML (10+ scenes) | Medium |

---

## ApplyPlayerHitstun

**Address:** `$C397` · **Size:** 129 bytes · **Movable:** Yes · **Priority:** **High** (9 JSL call sites in 3 enemy scripts)

### Description

Player damage and knockback entry. **A** = damage with bit 15 as a heavy-hit flag; **Y** = knockback direction (0 south, 1 north, 2 west, 3 east, 4+ = none). Damage is applied in full (ASL/LSR only tests bit 15, not a halving step). Spawns `hit_stagger_controller` at `HitStaggerMain` unless `playerFlags` bit `$0800` (script lock) is set.

The routine does **not** hide the D-pad — callers such as `gw82_archer` mask `$0F00` in `joypadMaskStd` before the JSL, and `HitStaggerReleasePlayer` clears the mask when the slide ends. On failed spawn (Y = `$1FC0`) it still clears D-pad bits `$0F00`. The `$003C` iframe counter written here is shortened to ~17 ticks when `HitStaggerReleasePlayer` runs.

### Algorithm

```
1. Save Y → absolute $0000; if A bit 15 set, $0002 := $FFC4 (heavy iframe path)
2. LSR A (bit 15 cleared); subtract from playerHp
3. Player $10 |= $0080; $7F0028 := $0002 or $003C from $0002
4. If playerFlags $0800: TRB #$0F00 on joypadMaskStd → RTL (no stagger)
5. COP SpawnListAppend @HitStaggerMain, #$2400 ($2000 script-driven + $0400 player victim)
6. If spawn failed (Y = $1FC0): TRB #$0F00 on joypadMaskStd
7. Copy player extendedFlags $0020 to child; direction $0000 → child $28; zero child $2C/$2E
8. PlaySoundCh2 #07; RTL
```

### Variables

| Symbol | Role |
|--------|------|
| `$player_actor` | Player slot after damage apply |
| `$7F0028,X` | Iframe / stun counter (shortened by stagger release) |
| `$joypad_mask_std` | D-pad bits `$0F00` cleared on lock/failed-spawn paths only |
| `$0000` / `$0002` | Absolute scratch: direction code, heavy-hit counter |
| A / Y (entry) | Damage (+ bit 15) / knockback direction |

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Spawns | `hit_stagger_controller` | `SpawnListAppend @HitStaggerMain` |
| Called from | 9 sites: `gw82_archer`, `gw83_asp`, `ir1F_stone_guard` | JSL |
| Returns to | `PlayerIdleEntry` | Via stagger controller on completion |

---

## SetPlayerIdleFacing

**Address:** `$C6E4` · **Size:** 44 bytes + 8-byte table · **Movable:** Yes (must move with `table_00C710`) · **Priority:** **High** (~15 scenes)

### Description

Forces the player into an **idle stand pose** facing the direction in **A** (0 = south, 1 = north, 2 = west, 3 = east). Writes the matching `IdleStand*` entry pointer from `player_idle_entry_table`, clears wait counter `$0008` and movement scratch `$002C`/`$002E` (DP and `$7F002C`/`$7F002E`).

Used by cutscene actors before scripted walks (~17 JSL sites). **A is the only input** — no scene-index lookup.

### Algorithm

```
1. `ASL` A → word index; `TAX`
2. Load `player_idle_entry_table,X` → player `$0000`/`$0002`
3. Zero `$0008`, `$002C`, `$002E` (and extended scratch)
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

**Address:** `$C725` · **Size:** 213 bytes · **Movable:** Yes (move with embedded direction codes) · **Priority:** **High** (13 ambient NPC actors)

### Description

RNG-driven stand/walk chooser for town NPCs. **13** actors use it (Dao, Watermia, Angel Village, Euro, Seaside Palace, South Cape — see block note for the full list). Init stores the base animation index in `$7F0026` and calls `SyncActorPosFromDP`; the NPC loop is `JSL NpcRandomWanderAI` → `AnimOnce` until the staged walk animation finishes.

`npc_wander_case_table` (8 entries via `SwitchCase` on scratch `$0000`):

| Case | Action |
|------|--------|
| 0 | Stand north (`base+0`) |
| 1 | Stand south (`base+1`) |
| 2 | Stand west (`base+2`) |
| 3 | Stand east (`base+3`) |
| 4 | Step north (`base+4`, delta chain `$12`) |
| 5 | Step south (`base+5`, chain `$11`) |
| 6 | Step west (`base+6`, chain `$12`) |
| 7 | Step east (`base+7`, chain `$11`) |

Steps move ±1 pixel every second frame (half a pixel per frame) for one walk-animation pass; blocked steps or moves beyond `$30` px from home become a stand facing that direction. Standing calls `MarkSolidHere`; walking calls `ClearSolidHere`.

### Algorithm

```
1. RngByte AND #7 → case index in $0000
2. SwitchCase → stand or step handler
3. Stand: set $28/$2A, UpdateActorAnimation, wait $78 frames, MarkSolidHere
4. Step: if >$30 from home or BranchIfSolid* → stand facing instead
     else StageMoveX/Y (#$11/+1 or #$12/−1 per frame), walk anim, ClearSolidHere
5. RTL (caller AnimOnce executes the staged move)
```

### Variables

| Symbol | Role |
|--------|------|
| `$14`, `$16` | Current pixel position |
| `$7F0010,X`, `$7F0012,X` | Home X/Y (from init `SyncActorPosFromDP`) |
| `$7F0026,X` | Base animation index |
| `$7F0008,X` | Stand wait counter (`$78` after a stand) |
| `$28` | Sprite frame index |
| `npc_wander_case_table` | 8-entry direction dispatch table |

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Preceded by | `SyncActorPosFromDP` | Position sync |
| External | `BranchIfSolid*` COPs | Per-direction solidity tests |
| Called from | 13 town NPC actor scripts | JSL |

---

## FlickerParentActor

**Address:** `$C7FA` · **Size:** 12 bytes · **Movable:** Yes

### Description

Every tick, XORs parent actor `$10` bit `$2000` on the actor index in `$0000` (direct page) — a **flicker** effect, not a one-shot show/hide. The thinker does not change its own entry point or die.

Invoked via `COP [SpawnAfterAbsFlags]` (e.g. Phantom Ribber hit callback, palace companion reveal when flag `#70` is set).

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
| Enemy attack scripts (9 sites) | `ApplyPlayerHitstun` | JSL |
| Scene init scripts (~15) | `SetPlayerIdleFacing` | JSL |
| Town NPC scripts (13) | `SyncActorPosFromDP` → `NpcRandomWanderAI` | JSL chain |
| Palace / cutscene scripts | `FlickerParentActor` | COP `SpawnAfterAbsFlags` |
| Escort sequences | `EscortFollowPathTracker` | COP `SpawnAfterFlags` |
| Shop / item scripts (10+) | `InventoryFullMessage` | JML |

---

## Statistics

| Metric | Value |
|--------|-------|
| Functions documented | 7 |
| Address span | `$C397`–`$C9B8` (~1,569 bytes) |
| High-priority entries | 4 |
| Multi-part blocks | 3 (`SetPlayerIdleFacing`, `npc_wander_ai`, `EscortFollowPathTracker`) |
| External bank deps | `$03` (`CalcTileMapOffset`, `GetPlayerFacingDirection`) |

---

*Source: `extracted/functions/*.asm`, `docs/code/bank00/actors-combat-interaction.md`.*
