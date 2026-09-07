# Bank $00 — Functions: Enemy Defeat Pipeline

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00DB8A`–`$00DFFF`  
**Source files:** `extracted/functions/StandardEnemyDefeatHandler.asm`, `NullActorScriptStub.asm`, `SpawnAttackTrailEffect.asm`, `SpawnHitSparkSprites.asm`, `SpawnItemDropPickup.asm`, `EnemyDeathFlash.asm`, `EnemyRewardChestSystem.asm`  
**Block:** `functions` section in `us/blocks.json`

This region implements the complete enemy death resolution pipeline: kill tracking, visual feedback, item drops, treasure chest spawning, and stat bonus rewards. Every standard field enemy routes through `StandardEnemyDefeatHandler` via the `$7F1004` OnDeath callback assigned in `chunk_03BAE1`.

**Related:** [`actors-combat-interaction.md`](actors-combat-interaction.md) (stat reward actors, hit stagger) · [`bank00-upper-analysis.md`](../bank00-upper-analysis.md) §4.2

---

## Pipeline Overview

```
Enemy OnDeath callback
    └─► StandardEnemyDefeatHandler ($DB8A)
            ├─► Increment kill counters / scene flags
            ├─► EnemyDeathFlash ($DF15)          [COP SpawnLastRel]
            ├─► SpawnItemDropPickup ($DDF2)     [optional, enemy drop flag]
            └─► Reward dispatch:
                    ├─► EnemyRewardChestRouter ($DD5B) → EnemyRewardChestSystem ($DF29)
                    └─► EnemyStatBonusReward ($DD87) → e_hp/str/def_increase actors
```

| Function | Old Name | Address | Size | Movable | Call Type | Priority |
|----------|----------|---------|------|---------|-----------|----------|
| `StandardEnemyDefeatHandler` | `func_00DB8A` | `$DB8A` | 237 B | **No** | `$&` pointer / COP `JumpScript` | **High** |
| `EnemyRewardChestRouter` | `func_00DD5B` | `$DD5B` | 44 B | **No** | Internal JSR `$&` | Medium |
| `EnemyStatBonusReward` | `func_00DD87` | `$DD87` | 107 B | **No** | Internal JSR `$&` | Medium |
| `SpawnItemDropPickup` | `func_00DDF2` | `$DDF2` | 291 B | ✓ | COP `SpawnLastRel` | **High** |
| `EnemyDeathFlash` | `func_00DF15` | `$DF15` | 20 B | ✓ | COP `SpawnLastRel` | Medium |
| `EnemyRewardChestSystem` | `func_00DF29`+ | `$DF29`–`$DFFF` | 260 B | ✓ | COP `SpawnLastRel` | **High** |
| `NullActorScriptStub` | `stub_00DC77` | `$DC77` | 2 B | **No** | `$&` default script | Medium |
| `SpawnAttackTrailEffect` | `func_00DCB4` | `$DCB4` | 79 B | ✓ | COP `SpawnLastRel` | Medium |
| `SpawnHitSparkSprites` | `func_00DD03` | `$DD03` | 88 B | ✓ | COP `SpawnLastRel` | Medium |

---

## StandardEnemyDefeatHandler

| Property | Value |
|----------|-------|
| **Old Name** | `func_00DB8A` |
| **New Name** | `StandardEnemyDefeatHandler` |
| **Hex Address** | `$00DB8A` |
| **Decimal Address** | 56202 |
| **End Address** | `$00DC77` (56439) |
| **Size** | 237 bytes |
| **Type** | Multi-part block entry (part 1 of 3) |
| **ASM File** | `extracted/functions/StandardEnemyDefeatHandler.asm` |
| **Movable** | **No** — inbound `$&func_00DB8A` from `chunk_03BAE1`, `hit_stagger_controller` |
| **Priority** | **High** (~20 enemy types) |

### Description

Central enemy death handler invoked when any standard enemy's HP reaches zero. Assigned as the default OnDeath callback via `SetOnDeath` COP in `chunk_03BAE1` (`#$&func_00DB8A`). Also referenced when `hit_stagger_controller` completes with no saved AI script for the victim.

The handler performs four coordinated tasks before the enemy actor dies:

1. **Kill accounting** — increments dungeon/scene kill counters stored in WRAM (`$7F0022,X` monster ID → flag tables), updates `$0AF0`–`$0AF8` scene persistence data where applicable
2. **Death VFX** — spawns `EnemyDeathFlash` at the enemy's `$14`/`$16` position via `COP [SpawnLastRel]`
3. **Item drops** — if the enemy's drop flag is set, spawns `SpawnItemDropPickup` with the item ID from enemy metadata
4. **Reward routing** — reads the enemy's reward byte and dispatches to either `EnemyRewardChestRouter` (JSR `$&func_00DD5B`) for chest types 1/2/weighted, or `EnemyStatBonusReward` (JSR `$&func_00DD87`) for HP/STR/DEF bonuses

Because parts `func_00DD5B` and `func_00DD87` are embedded in the same block file with internal `$&` references, this entire three-part block must remain co-located in bank `$00`.

### Algorithm

```
1. Read enemy reward type from actor metadata / WRAM fields
2. SetWramFlag for dungeon kill tracking ($7F0022 monster ID)
3. COP [SpawnLastRel] @EnemyDeathFlash — white flash at death position
4. If drop flag set:
     COP [SpawnLastRel] @SpawnItemDropPickup with item ID
5. Switch on reward type:
     Type 1/2/other → JSR $&EnemyRewardChestRouter
     Stat bonus     → JSR $&EnemyStatBonusReward
6. COP [Die] — remove enemy actor
```

### Variables

| Symbol | Role |
|--------|------|
| `$14`, `$16` | Enemy death position (passed to flash/drop spawns) |
| `$7F0022,X` | Dungeon monster ID for kill flag |
| `$7F1004,X` | OnDeath callback (this function) |
| `$0AF0`–`$0AF8` | Scene persistence / kill count storage |
| Enemy metadata | Reward type byte, drop item ID, drop enable flag |

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Assigned by | `chunk_03BAE1` | Default enemy OnDeath: `#$&func_00DB8A` |
| Called from | `hit_stagger_controller` | When enemy has no saved script ptr |
| Calls | `EnemyRewardChestRouter`, `EnemyStatBonusReward` | Internal JSR `$&` |
| Spawns | `EnemyDeathFlash`, `SpawnItemDropPickup` | COP `SpawnLastRel` |
| Cataloged in | `us/blocks.json` | Block `StandardEnemyDefeatHandler` |
| Cataloged in | `us/names.json` @ 56202 | |

---

## EnemyRewardChestRouter

| Property | Value |
|----------|-------|
| **Old Name** | `func_00DD5B` |
| **New Name** | `EnemyRewardChestRouter` |
| **Hex Address** | `$00DD5B` |
| **Decimal Address** | 56667 |
| **End Address** | `$00DD87` (56711) |
| **Size** | 44 bytes |
| **Type** | Embedded subroutine (part 2 of `StandardEnemyDefeatHandler` block) |
| **Movable** | **No** — only reachable via `$&` from `func_00DB8A` |

### Description

Routes enemy reward type bytes to the appropriate treasure chest spawner within `EnemyRewardChestSystem`. Compares the reward type against constants 1, 2, and a default bucket, then issues `COP [SpawnLastRel]` targeting the matching chest variant handler at `$DF29`–`$DFE3`.

Chest rewards appear as animated treasure chest actors that the player opens for items or stat boosts. This router is the dispatch layer; the actual spawn logic lives in the seven variant functions below.

### Algorithm

```
1. LDA reward_type (from caller preset)
2. CMP #$01 → SpawnRewardChestType1 ($DF29)
3. CMP #$02 → SpawnRewardChestType2 ($DF52)
4. Default   → SpawnRewardChestWeighted ($DF7B) or HP/DEF variants
5. COP [SpawnLastRel] @selected_handler
6. RTS
```

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Caller | `StandardEnemyDefeatHandler` | JSR `$&func_00DD5B` |
| Targets | `SpawnRewardChestType1`–`SpawnRewardChestDEF` | `$DF29`–`$DFE3` |
| Cataloged in | `us/names.json` @ 56667 | |

---

## EnemyStatBonusReward

| Property | Value |
|----------|-------|
| **Old Name** | `func_00DD87` |
| **New Name** | `EnemyStatBonusReward` |
| **Hex Address** | `$00DD87` |
| **Decimal Address** | 56711 |
| **End Address** | `$00DDF2` (56818) |
| **Size** | 107 bytes |
| **Type** | Embedded subroutine (part 3 of `StandardEnemyDefeatHandler` block) |
| **Movable** | **No** — only reachable via `$&` from `func_00DB8A` |

### Description

Scene-indexed HP/STR/DEF reward spawner. Looks up the current `$scene_current` in an embedded scene→stat-type table, then spawns the appropriate stat reward actor (`e_hp_increase`, `e_str_increase`, or `e_def_increase` at `$E02D`–`$E0A6`) via `COP [SpawnLastRel]`.

These actors bounce toward the player, play fanfare SFX `$25`, set the scene reward flag `$0300`, and print the stat increase message. Never placed directly in `scene_actors.asm` — always spawned dynamically after combat.

### Algorithm

```
1. LDA $scene_current
2. Scan embedded scene index table for match
3. Load stat type (HP=0, STR=1, DEF=2) from table entry
4. Switch stat type:
     0 → COP [SpawnLastRel] @e_hp_increase
     1 → COP [SpawnLastRel] @e_str_increase
     2 → COP [SpawnLastRel] @e_def_increase
5. RTS
```

### Variables

| Symbol | Role |
|--------|------|
| `$scene_current` | Scene index lookup key |
| `$0ACA` / `$0ADE` / `$0ADC` | HP / STR / DEF (modified by spawned actors) |

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Caller | `StandardEnemyDefeatHandler` | JSR `$&func_00DD87` |
| Spawns | `e_hp_increase`, `e_str_increase`, `e_def_increase` | Via `SpawnLastRel` |
| Shared VFX | `RewardActorVFX` (`$E110`) | Called by all stat actors |
| Cataloged in | `us/names.json` @ 56711 | |

---

## SpawnItemDropPickup

| Property | Value |
|----------|-------|
| **Old Name** | `func_00DDF2` |
| **New Name** | `SpawnItemDropPickup` |
| **Hex Address** | `$00DDF2` |
| **Decimal Address** | 56818 |
| **End Address** | `$00DF15` (57109) |
| **Size** | 291 bytes |
| **Type** | Standalone actor spawn script |
| **ASM File** | `extracted/functions/SpawnItemDropPickup.asm` |
| **Movable** | Yes |
| **Priority** | **High** |

### Description

Spawns an animated item pickup actor when an enemy's drop flag is set. The pickup bounces from the enemy death position, displays the item icon via inventory metasprite lookup, and grants the item on player contact. Contains embedded widestring data for the pickup's idle animation loop.

Uses `COP [SpawnLastRel]` invocation pattern — the caller (`StandardEnemyDefeatHandler`) passes the item ID and spawn coordinates. The pickup actor checks inventory capacity before granting; if full, redirects to `InventoryFullMessage` (`$C98E`).

### Algorithm

```
1. Read item ID from spawn parameter / enemy metadata
2. Stage item metasprite from inventory sprite table
3. Bounce animation loop toward ground position
4. Wait for player proximity / collision
5. Check inventory space (func_03EF97)
6. If space: grant item, play pickup SFX, COP [Die]
7. If full: JML InventoryFullMessage
```

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Spawned by | `StandardEnemyDefeatHandler` | `COP [SpawnLastRel]` |
| Inventory check | `func_03EF97` | Bank `$03` give-item |
| Full inventory | `InventoryFullMessage` | `$C98E` JML target |
| Cataloged in | `us/names.json` @ 56818 | |

---

## EnemyDeathFlash

| Property | Value |
|----------|-------|
| **Old Name** | `func_00DF15` |
| **New Name** | `EnemyDeathFlash` |
| **Hex Address** | `$00DF15` |
| **Decimal Address** | 57109 |
| **End Address** | `$00DF29` (57129) |
| **Size** | 20 bytes |
| **Type** | Minimal VFX actor script |
| **ASM File** | `extracted/functions/EnemyDeathFlash.asm` |
| **Movable** | Yes (~10 direct callers) |

### Description

Brief white-flash metasprite displayed at the enemy's death position. Spawns via `COP [SpawnLastRel]`, shows a single bright metasprite frame for a few ticks, then immediately dies. Provides universal visual feedback that an enemy has been defeated regardless of enemy type.

Also called directly from some enemy actor scripts (not only through `StandardEnemyDefeatHandler`) for custom death sequences that bypass the standard handler.

### Algorithm

```
1. Stage white flash metasprite at spawn position
2. COP [AnimOnce] — display single frame
3. COP [Die]
```

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Spawned by | `StandardEnemyDefeatHandler` | Primary caller |
| Also called from | ~10 enemy actor scripts | Direct `SpawnLastRel` |
| Cataloged in | `us/names.json` @ 57109 | |

---

## EnemyRewardChestSystem

| Property | Value |
|----------|-------|
| **Old Name** | `func_00DF29` (block) |
| **New Name** | `EnemyRewardChestSystem` |
| **Hex Address** | `$00DF29`–`$00DFFF` |
| **Decimal Address** | 57129–57389 |
| **Size** | 260 bytes (7 handlers + data) |
| **Type** | Multi-part block |
| **ASM File** | `extracted/functions/EnemyRewardChestSystem.asm` |
| **Movable** | Yes (move with `array_00DFFD`) |
| **Priority** | **High** |

### Description

Treasure chest spawner system with six variant handlers plus a weighted random selection table. Each variant configures chest metasprite, opening animation, and reward contents before spawning via the actor pool. `array_00DFFD` holds weighted probability bytes for the default random chest path.

### Parts

| Part | Old Name | New Name | Address | Size | Purpose |
|------|----------|----------|---------|------|---------|
| Type 1 | `func_00DF29` | `SpawnRewardChestType1` | `$DF29` | 15 B | Standard chest variant A |
| Type 1 alt | `func_00DF38` | `SpawnRewardChestType1Alt` | `$DF38` | 26 B | Alternate type-1 layout |
| Type 2 | `func_00DF52` | `SpawnRewardChestType2` | `$DF52` | 15 B | Standard chest variant B |
| Type 2 alt | `func_00DF61` | `SpawnRewardChestType2Alt` | `$DF61` | 26 B | Alternate type-2 layout |
| Weighted | `func_00DF7B` | `SpawnRewardChestWeighted` | `$DF7B` | 78 B | RNG selection via `array_00DFFD` |
| HP | `func_00DFC9` | `SpawnRewardChestHP` | `$DFC9` | 26 B | Chest granting HP bonus |
| DEF | `func_00DFE3` | `SpawnRewardChestDEF` | `$DFE3` | 26 B | Chest granting DEF bonus |
| Data | `array_00DFFD` | `array_00DFFD` | `$DFFD` | 48 B | Weight table for random chest |

### Algorithm (SpawnRewardChestWeighted)

```
1. JSR random byte
2. Walk array_00DFFD cumulative weights
3. Select chest variant index
4. Configure chest actor: metasprite, item pool, animation
5. COP [SpawnAfter] or [SpawnLastRel] chest actor
6. RTS
```

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Dispatched by | `EnemyRewardChestRouter` | JSR / SpawnLastRel |
| Data | `array_00DFFD` | Must move with block |
| Cataloged in | `us/blocks.json` | Block `EnemyRewardChestSystem` |

---

## NullActorScriptStub

| Property | Value |
|----------|-------|
| **Old Name** | `stub_00DC77` |
| **New Name** | `NullActorScriptStub` |
| **Hex Address** | `$00DC77` |
| **Decimal Address** | 56439 |
| **End Address** | `$00DC79` (56441) |
| **Size** | 2 bytes |
| **Type** | Minimal stub |
| **Movable** | **No** — inbound `$&stub_00DC77` from `chunk_03BAE1` |

### Description

Immediate `COP [Die]` — the default actor script pointer assigned to newly allocated actors that have no custom behavior. Referenced from `func_03C524` in `chunk_03BAE1` as `#$&stub_00DC77`. Any actor spawned without an explicit entry pointer gets this stub and dies on its first frame, preventing runaway execution on uninitialized slots.

### Algorithm

```
COP [Die]
```

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Assigned by | `chunk_03BAE1` | Default actor entry pointer |
| Cataloged in | `us/names.json` @ 56439 | |

---

## SpawnAttackTrailEffect

| Property | Value |
|----------|-------|
| **Old Name** | `func_00DCB4` |
| **New Name** | `SpawnAttackTrailEffect` |
| **Hex Address** | `$00DCB4` |
| **Decimal Address** | 56500 |
| **End Address** | `$00DD03` (56579) |
| **Size** | 79 bytes |
| **Type** | VFX spawn script |
| **ASM File** | `extracted/functions/SpawnAttackTrailEffect.asm` |
| **Movable** | Yes |

### Description

Spawns a 16-frame hit trail effect at the attack impact point. Creates a series of afterimage sprites via `$@func_03BAF1` (bank `$03` sprite factory), spaced across the attack arc. Used by weapon swing animations and certain enemy attack scripts for visual impact feedback.

Invoked via `COP [SpawnLastRel]` from combat actor scripts with the trail origin coordinates preset in direct page.

### Algorithm

```
1. Loop 16 iterations:
     a. Compute trail position along attack arc
     b. JSL $@func_03BAF1 — create afterimage sprite
     c. Decrement frame counter
2. COP [Die]
```

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| External | `func_03BAF1` | Bank `$03` sprite factory |
| Duplicate | `AttackTrailShort_unused` (`$DC79`) | Shorter variant, no refs |
| Cataloged in | `us/names.json` @ 56500 | |

---

## SpawnHitSparkSprites

| Property | Value |
|----------|-------|
| **Old Name** | `func_00DD03` |
| **New Name** | `SpawnHitSparkSprites` |
| **Hex Address** | `$00DD03` |
| **Decimal Address** | 56579 |
| **End Address** | `$00DD5B` (56667) |
| **Size** | 88 bytes |
| **Type** | VFX spawn script (contains embedded sub `code_00DD1D`) |
| **ASM File** | `extracted/functions/SpawnHitSparkSprites.asm` |
| **Movable** | Yes (move with `code_00DD1D` sub) |

### Description

Creates OAM spark entries for critical-hit visual feedback. Writes short-lived sprite entries to the OAM buffer with randomized scatter offsets around the impact point. Contains internal sub-function `code_00DD1D` that builds individual spark OAM entries with priority/mirror bits and 4-frame lifetime.

Used when the player lands a critical hit or when certain enemies take bonus damage. Spawned via `COP [SpawnLastRel]` from combat callback chains.

### Algorithm

```
1. Read impact position from spawn params
2. Loop spark count (typically 4–8):
     a. JSR code_00DD1D — write OAM entry with RNG offset
     b. Set 4-frame lifetime counter
3. Animate sparks (fade priority bits each frame)
4. COP [Die]
```

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Embedded sub | `code_00DD1D` | OAM entry builder |
| Cataloged in | `us/names.json` @ 56579 | |

---

## Statistics

| Metric | Value |
|--------|-------|
| Total functions documented | 9 (+ 7 chest sub-handlers) |
| Address span | `$DB8A`–`$DFFF` (~1,397 bytes) |
| Immovable entries | 4 (`StandardEnemyDefeatHandler` block parts + stub) |
| External `$&` inbound refs | 2 (`func_00DB8A`, `stub_00DC77`) |
| COP spawn pattern | 6 functions use `SpawnLastRel` |

---

*Source: `us/blocks.json`, `us/names.json`, `docs/code/bank00-upper-analysis.md`, `docs/code/bank00/actors-combat-interaction.md`.*
