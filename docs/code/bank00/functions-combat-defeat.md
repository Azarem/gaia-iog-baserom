# Bank $00 — Functions: Enemy Defeat Pipeline

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00DB8A`–`$00DFFF`  
**Source files:** `extracted/functions/StandardEnemyDefeatHandler.asm`, `NullActorScriptStub.asm`, `SpawnAttackTrailEffect.asm`, `SpawnHitSparkSprites.asm`, `SpawnFieldRevealEffect.asm`, `EnemyDeathFlash.asm`, `DarkGemDropSystem.asm`  
**Block:** `functions` section in `us/blocks.json`

This region implements the complete enemy death resolution pipeline: kill tracking, visual feedback, field tile reveals, dark point gem drops, and stat bonus rewards. Every standard field enemy routes through `StandardEnemyDefeatHandler` via the `$7F1004` OnDeath callback assigned in `chunk_03BAE1`.

**Related:** [`actors-combat-interaction.md`](actors-combat-interaction.md) (stat reward actors, hit stagger) · [`index.md`](index.md)

---

## Pipeline Overview

```
Enemy OnDeath callback
    └─► StandardEnemyDefeatHandler ($DB8A)
            ├─► Increment kill counters / scene flags
            ├─► EnemyDeathFlash ($DF15)          [COP SpawnLastRel]
            ├─► SpawnFieldRevealEffect ($DDF2)  [optional, event block trigger]
            └─► Reward dispatch:
                    ├─► EnemyGemDropRouter ($DD5B) → DarkGemDropSystem ($DF29)
                    └─► EnemyStatBonusReward ($DD87) → e_hp/str/def_increase actors
```

| Function | Old Name | Address | Size | Movable | Call Type | Priority |
|----------|----------|---------|------|---------|-----------|----------|
| `StandardEnemyDefeatHandler` | `func_00DB8A` | `$DB8A` | 237 B | **No** | `$&` pointer / COP `JumpScript` | **High** |
| `EnemyGemDropRouter` | `func_00DD5B` | `$DD5B` | 44 B | **No** | Internal JSR `$&` | Medium |
| `EnemyStatBonusReward` | `func_00DD87` | `$DD87` | 107 B | **No** | Internal JSR `$&` | Medium |
| `SpawnFieldRevealEffect` | `func_00DDF2` | `$DDF2` | 291 B | ✓ | COP `SpawnLastRel` | **High** |
| `EnemyDeathFlash` | `func_00DF15` | `$DF15` | 20 B | ✓ | COP `SpawnLastRel` | Medium |
| `DarkGemDropSystem` | `func_00DF29`+ | `$DF29`–`$DFFF` | 260 B | ✓ | COP `SpawnLastRel` | **High** |
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
3. **Field tile reveal** — if the enemy has a `deathActionIdx` (event block ID) and it hasn't been triggered yet, spawns `SpawnFieldRevealEffect` which animates sparkles at the reveal area then swaps hidden tilemap tiles to their visible destination via `StageBgChangeFromDeathIdx`/`ApplyBgChange`
4. **Reward routing** — reads the enemy's `gemDropType` byte (field 4 of `enemy-stats`) and dispatches to either `EnemyGemDropRouter` (JSR `$&func_00DD5B`) for dark gem types 1/2/weighted, or `EnemyStatBonusReward` (JSR `$&func_00DD87`) for HP/STR/DEF stat bonuses

Because parts `func_00DD5B` and `func_00DD87` are embedded in the same block file with internal `$&` references, this entire three-part block must remain co-located in bank `$00`.

### Algorithm

```
1. Read enemy reward type from actor metadata / WRAM fields
2. SetWramFlag for dungeon kill tracking ($7F0022 monster ID)
3. COP [SpawnLastRel] @EnemyDeathFlash — white flash at death position
4. If deathActionIdx set (event block trigger):
     COP [SpawnLastRel] @SpawnFieldRevealEffect with event block ID
5. Switch on gemDropType (enemy-stats byte 3):
     Type 1/2/3+ → JSR $&EnemyGemDropRouter (dark gem drop)
     Type 0      → JSR $&EnemyStatBonusReward (stat bonus only)
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
| Calls | `EnemyGemDropRouter`, `EnemyStatBonusReward` | Internal JSR `$&` |
| Spawns | `EnemyDeathFlash`, `SpawnFieldRevealEffect` | COP `SpawnLastRel` |
| Cataloged in | `us/blocks.json` | Block `StandardEnemyDefeatHandler` |
| Cataloged in | `us/names.json` @ 56202 | |

---

## EnemyGemDropRouter

| Property | Value |
|----------|-------|
| **Old Name** | `func_00DD5B` (formerly `EnemyRewardChestRouter`) |
| **New Name** | `EnemyGemDropRouter` |
| **Hex Address** | `$00DD5B` |
| **Decimal Address** | 56667 |
| **End Address** | `$00DD87` (56711) |
| **Size** | 44 bytes |
| **Type** | Embedded subroutine (part 2 of `StandardEnemyDefeatHandler` block) |
| **Movable** | **No** — only reachable via `$&` from `func_00DB8A` |

### Description

Routes the enemy's `gemDropType` (byte 3 of `enemy-stats`) to the appropriate dark gem spawner within `DarkGemDropSystem`. The `gemDropType` is read from `stats_01ABF0` during the defeat handler and passed via A register. The router decrements and branch-equals to dispatch:

- **Type 1** → `SpawnDarkGemType1` (`$DF29`) — fixed dark gem variant A
- **Type 2** → `code_00DF52` (`$DF52`) — fixed dark gem variant B
- **Type 3+** → `code_00DF7B` (`$DF7B`) — weighted random selection from `gem-drop-threshold` table

> ⚠ This system was previously misnamed "EnemyRewardChestRouter" — enemies do **not** spawn chests on death. They drop dark point gems (animated collectible gems with stat-boosting properties).

### Algorithm

```
1. LDA gemDropType (from enemy-stats byte 3, via caller)
2. DEC; BEQ → SpawnDarkGemType1 ($DF29)   [type 1: fixed gem A]
3. DEC; BEQ → code_00DF52 ($DF52)          [type 2: fixed gem B]
4. BRA → code_00DF7B ($DF7B)               [type 3+: random weighted]
5. COP [SpawnLastRel] @selected_handler
6. JMP $&code_00DC13
```

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Caller | `StandardEnemyDefeatHandler` | JSR `$&func_00DD5B` |
| Targets | `SpawnDarkGemType1`–`code_00DFE3` | `$DF29`–`$DFE3` via `DarkGemDropSystem` |
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

## SpawnFieldRevealEffect

| Property | Value |
|----------|-------|
| **Old Name** | `func_00DDF2` (formerly `SpawnItemDropPickup`) |
| **New Name** | `SpawnFieldRevealEffect` |
| **Hex Address** | `$00DDF2` |
| **Decimal Address** | 56818 |
| **End Address** | `$00DF15` (57109) |
| **Size** | 291 bytes |
| **Type** | Field tile reveal effect actor |
| **ASM File** | `extracted/functions/SpawnFieldRevealEffect.asm` |
| **Movable** | Yes |
| **Priority** | **High** |

> ⚠ This actor was previously named `SpawnItemDropPickup` but contains **no item/inventory logic whatsoever**. It is the visual effect that plays when hidden tilemap tiles are revealed after an enemy defeat triggers an event block change.

### Description

Spawns an animated sparkle/flash effect at the field tile reveal area, then triggers the actual event block tile swap. When an enemy with a `deathActionIdx` (event block ID) is killed, `StandardEnemyDefeatHandler` spawns this actor, passing the event block ID.

The actor reads the event block entry from `event_block_table` to determine the reveal area dimensions and destination coordinates. It computes a movement target (the center of the reveal area), animates a sprite moving toward it, spawns flash and scatter sparkle particles, then triggers `StageBgChangeFromDeathIdx` / `ApplyBgChange` to perform the actual tile swap.

### Sub-functions

| Part | Address | Name | Purpose |
|------|---------|------|---------|
| Main | `$DDF2` | `SpawnFieldRevealEffect` | Orchestrates reveal animation + tile swap |
| Scatter | `$DEB8` | `field_reveal_scatter` | Random sparkle particle offset by reveal area dimensions |
| Flash | `$DF0A` | `field_reveal_flash` | Sound `#$0606` + single flash sprite frame `#25` |

### Algorithm

```
1. Read deathActionIdx (event block ID) from spawning enemy
2. Index into event_block_table: entry = event_block_table[deathActionIdx × 8]
3. Extract width/height (bytes 3/4) and dstX/dstY (bytes 5/6)
4. Compute reveal area center from dimensions
5. Animate sprite frame #29 moving toward reveal center
6. Spawn field_reveal_flash — sound + brief flash VFX
7. Loop 10×: spawn field_reveal_scatter — random sparkle particles
   Each particle gets random X/Y offsets scaled to area width/height
8. COP [StageBgChangeFromDeathIdx] — stage the event block tile swap
9. COP [ApplyBgChange] — execute the swap (hidden tiles → visible area)
10. COP [Die]
```

### `field_reveal_scatter` ($DEB8)

Generates random particle positions scaled to the reveal area dimensions. Uses `COP [RngByte]` and masks based on the width/height passed via `$20`/`$22`:
- Width ≥ 4: scatter range `$003F` (large area)
- Width 2–3: scatter range `$001F` (medium area)
- Width < 2: scatter range `$000F` (narrow area)

Sign-extends randomly via carry flag to produce both positive and negative offsets.

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Spawned by | `StandardEnemyDefeatHandler` | `COP [SpawnLastRel]` when `deathActionIdx` set |
| Spawned by | `pyCC_mystic_ball.asm` | Pyramid mystic ball custom death |
| Spawned by | `awB1_wall_walker.asm` | Angkor wall walker custom death |
| Spawned by | `func_0AA43F.asm` | Generic enemy death with field reveal |
| Reads | `event_block_table` | Event block definitions (dimensions + coordinates) |
| Triggers | `StageBgChangeFromDeathIdx` / `ApplyBgChange` | Actual tile swap COP commands |
| Cataloged in | `us/names.json` @ 56818 | |
| Cataloged in | `us/blocks.json` | Block `SpawnFieldRevealEffect` |

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

## DarkGemDropSystem

| Property | Value |
|----------|-------|
| **Old Name** | `func_00DF29` (formerly `EnemyRewardChestSystem`) |
| **New Name** | `DarkGemDropSystem` |
| **Hex Address** | `$00DF29`–`$00DFFF` |
| **Decimal Address** | 57129–57389 |
| **Size** | 260 bytes (7 handlers + data) |
| **Type** | Multi-part block |
| **ASM File** | `extracted/functions/DarkGemDropSystem.asm` |
| **Movable** | Yes (move with `gem_drop_threshold_00DFFD`) |
| **Priority** | **High** |

> ⚠ Previously misnamed `EnemyRewardChestSystem`. Enemies do **not** spawn chests — they drop animated dark point gems that the player collects for stat increases.

### Description

Dark gem drop system with six variant handlers plus a weighted random selection table. Each handler:
1. Sets up a metasprite from `table_0EE000`
2. Spawns `collect_handler_gem` as a child actor for player pickup interaction
3. Writes the gem type to `$chatPtr,X` (identifies the stat type on collection)
4. Animates the gem through two sprite frame stages, then dies

The `$chatPtr` values identify which stat the gem increases when collected:
- `$0083` → HP gem (sprite frames `#04` / `#09`)
- `$0084` → STR gem (sprite frames `#05` / `#0A`)
- `$0085` → DEF gem (sprite frames `#06` / `#0B`)
- `$0086` → Special gem (sprite frames `#22` / `#35`, rare variant with longer animation)

`gem_drop_threshold_00DFFD` holds weighted probability thresholds for the random selection path.

### Parts

| Part | Old Name | New Name | Address | Size | Purpose |
|------|----------|----------|---------|------|---------|
| Type 1 entry | `func_00DF29` | `SpawnDarkGemType1` | `$DF29` | 15 B | Fixed gem type A: setup metasprite + spawn collect handler |
| Type 1 display | `func_00DF38` | `code_00DF38` | `$DF38` | 26 B | chatPtr `$0083` (HP gem), frames `#04`/`#09` |
| Type 2 entry | `func_00DF52` | `code_00DF52` | `$DF52` | 15 B | Fixed gem type B: setup metasprite + spawn collect handler |
| Type 2 display | `func_00DF61` | `code_00DF61` | `$DF61` | 26 B | chatPtr `$0084` (STR gem), frames `#05`/`#0A` |
| Weighted | `func_00DF7B` | `SpawnDarkGemWeighted` | `$DF7B` | 78 B | RNG tier selection → weighted table lookup → PHA/RTS dispatch |
| DEF gem | `func_00DFC9` | `code_00DFC9` | `$DFC9` | 26 B | chatPtr `$0085` (DEF gem), frames `#06`/`#0B` |
| Special gem | `func_00DFE3` | `code_00DFE3` | `$DFE3` | 26 B | chatPtr `$0086` (special gem), frames `#22`/`#35` |
| Data | `array_00DFFD` | `gem_drop_threshold_00DFFD` | `$DFFD` | 48 B | `gem-drop-threshold` weighted probability table (3 tiers × 4 entries) |

### Algorithm (SpawnDarkGemWeighted)

```
1. Setup: SetMetasprite, SetSpritePalette, SpawnMarkedAfter @collect_handler_gem
2. Compare playerMaxHp to playerHp for tier selection:
     maxHp/4 ≥ currentHp → tier 2 (strong, offset $20)
     maxHp/2 ≥ currentHp → tier 1 (medium, offset $10)
     else                  → tier 0 (weak, offset $00)
3. COP [RngByte] → random value $00-$FF
4. Walk gem_drop_threshold_00DFFD[tier_offset]:
     Compare RNG against each entry's threshold
     First entry whose threshold > RNG wins
5. Load handler address from winning entry
6. DEC; PHA; RTS → dispatch to selected gem display handler
```

### Weighted Distribution (gem_drop_threshold_00DFFD)

| Tier | Entry 0 (rare) | Entry 1 | Entry 2 | Entry 3 (common) |
|------|----------------|---------|---------|-------------------|
| 0 (weak) | `<$0F, &DFE3>` (6% special) | `<$3C, &DFC9>` (18% DEF) | `<$99, &DF61>` (37% STR) | `<$100, &DF38>` (39% HP) |
| 1 (medium) | `<$19, &DFC9>` (10% DEF) | `<$4C, &DF38>` (20% HP) | `<$99, &DFE3>` (31% special) | `<$100, &DF61>` (39% STR) |
| 2 (strong) | `<$0C, &DF61>` (5% STR) | `<$33, &DF38>` (15% HP) | `<$7F, &DFC9>` (31% DEF) | `<$100, &DFE3>` (49% special) |

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Dispatched by | `EnemyGemDropRouter` | `COP [SpawnLastRel]` |
| Child actor | `collect_handler_gem` | Gem collection interaction handler (nudges gem toward player) |
| Data | `gem_drop_threshold_00DFFD` | Must move with block |
| Cataloged in | `us/blocks.json` | Block `DarkGemDropSystem` |

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

*Source: `us/blocks.json`, `us/names.json`, `docs/code/bank00/actors-combat-interaction.md`.*
