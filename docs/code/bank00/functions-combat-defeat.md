# Bank $00 — Functions: Enemy Defeat Pipeline

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00DB8A`–`$00DFFF`  
**Source files:** `extracted/functions/StandardEnemyDefeatHandler.asm`, `NpcDespawnStub.asm`, `SpawnDamageNumberEffect.asm`, `SpawnItemSparkleEffect.asm`, `SpawnFieldRevealEffect.asm`, `EnemyDeathFlash.asm`, `EnemyDropSystem.asm`  
**Block:** enemy defeat pipeline (`StandardEnemyDefeatHandler` multi-part block + standalone VFX)

This region implements the complete enemy death resolution pipeline: kill tracking, visual feedback, field tile reveals, gem/heal pickup drops, and stat bonus rewards. Every standard field enemy routes through `StandardEnemyDefeatHandler` via the `$7F1004` OnDeath callback assigned in `ComposeDigitSprites_AtCursor`.

**Related:** [`actors-combat-interaction.md`](actors-combat-interaction.md) (stat reward actors, hit stagger) · [`README.md`](README.md)

---

## Pipeline Overview

```
Enemy OnDeath callback
    └─► StandardEnemyDefeatHandler ($DB8A)
            ├─► Increment kill counters / scene flags
            ├─► EnemyDeathFlash ($DF15)          [COP SpawnLastRel]
            ├─► SpawnFieldRevealEffect ($DDF2)  [optional, event block trigger]
            └─► Reward dispatch:
                    ├─► EnemyGemDropRouter ($DD5B) → EnemyDropSystem ($DF29)
                    └─► EnemyStatBonusReward ($DD87) → e_hp/str/def_increase actors
```

| Function | Address | Size | Movable | Call Type | Priority |
|----------|---------|------|---------|-----------|----------|
| `StandardEnemyDefeatHandler` | `$DB8A` | 237 B | **No** | `$&` pointer / COP `JumpScript` | **High** |
| `EnemyGemDropRouter` | `$DD5B` | 44 B | **No** | Internal JSR `$&` | Medium |
| `EnemyStatBonusReward` | `$DD87` | 107 B | **No** | Internal JSR `$&` | Medium |
| `SpawnFieldRevealEffect` | `$DDF2` | 291 B | ✓ | COP `SpawnLastRel` | **High** |
| `EnemyDeathFlash` | `$DF15` | 20 B | ✓ | COP `SpawnLastRel` | Medium |
| `EnemyDropSystem` | `$DF29`–`$DFFF` | 260 B | ✓ | COP `SpawnLastRel` | **High** |
| `NpcDespawnStub` | `$DC77` | 2 B | **No** | `$&` from `InteractionDamage_NPCChat` | Medium |
| `SpawnDamageNumberEffect` | `$DCB4` | 79 B | ✓ | COP `SpawnLastRel` | Medium |
| `SpawnItemSparkleEffect` | `$DD03` | 88 B | ✓ | COP `SpawnLastRel` | Medium |

---

## StandardEnemyDefeatHandler

**Address:** `$DB8A` · **Size:** 237 bytes · **Movable:** No (inbound `$&StandardEnemyDefeatHandler` from `hit_stagger_controller`, `combat_collision`)

### Description

Central enemy death handler invoked when any standard enemy's HP reaches zero. It is the engine default: `hit_stagger_controller` (`HitStaggerResolveHit`) and two inline paths in `combat_collision` point the victim at it when HP reaches zero and `$7F1004` is empty, and 13 enemy scripts `JumpFar` into it. `ComposeDigitSprites_AtCursor` does not assign it.

The handler performs four coordinated tasks before the enemy actor dies:

1. **Kill accounting** — increments dungeon/scene kill counters stored in WRAM (`$7F0022,X` monster ID → flag tables), updates `$0AF0`–`$0AF8` scene persistence data where applicable
2. **Death VFX** — spawns `EnemyDeathFlash` at the enemy's `$14`/`$16` position via `COP [SpawnLastRel]`
3. **Field tile reveal** — if the enemy has a `deathActionIdx` (event block ID) and it hasn't been triggered yet, spawns `SpawnFieldRevealEffect` which animates sparkles at the reveal area then swaps hidden tilemap tiles to their visible destination via `StageBgChangeFromDeathIdx`/`ApplyBgChange`
4. **Reward routing** — reads the enemy's `gemDropType` byte (field 4 of `enemy-stats`) and dispatches to either `EnemyGemDropRouter` (JSR `$&EnemyGemDropRouter`) for gem/heal pickup types 1/2/weighted, or `EnemyStatBonusReward` (JSR `$&EnemyStatBonusReward`) for HP/STR/DEF stat bonuses

Because `EnemyGemDropRouter` and `EnemyStatBonusReward` are embedded in the same block file with internal `$&` references, this entire three-part block must remain co-located in bank `$00`.

### Algorithm

```
1. Read enemy reward type from actor metadata / WRAM fields
2. SetWramFlag for dungeon kill tracking ($7F0022 monster ID)
3. COP [SpawnLastRel] @EnemyDeathFlash — white flash at death position
4. If deathActionIdx set (event block trigger):
     COP [SpawnLastRel] @SpawnFieldRevealEffect with event block ID
5. Switch on gemDropType (enemy-stats byte 3):
     Type 1/2/3+ → JSR $&EnemyGemDropRouter (gem/heal pickup)
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
| Installed by | `hit_stagger_controller`, `combat_collision` | Default enemy death entry when `$7F1004` is empty |
| Called from | `hit_stagger_controller` | When enemy has no saved script ptr |
| Calls | `EnemyGemDropRouter`, `EnemyStatBonusReward` | Internal JSR `$&` |
| Spawns | `EnemyDeathFlash`, `SpawnFieldRevealEffect` | COP `SpawnLastRel` |

---

## EnemyGemDropRouter

**Address:** `$DD5B` · **Size:** 44 bytes · **Movable:** No (only reachable via `$&` from `StandardEnemyDefeatHandler`)

### Description

Routes the enemy's `gemDropType` (byte 3 of `enemy-stats`) to the appropriate pickup spawner within `EnemyDropSystem`. The router reads the stat byte at +3 (`AND #$00FF`) and decrements to dispatch:

- **Type 1** → `SpawnDropGem1` (`$DF29`) — fixed item `$83` (1 gem)
- **Type 2** → `SpawnDropGem2` (`$DF52`) — fixed item `$84` (2 gems)
- **Type 3+** → `SpawnDropByHpTier` (`$DF7B`) — HP-tier weighted roll among items `$83`–`$86`

> ⚠ This system was previously misnamed "EnemyRewardChestRouter" — enemies do **not** spawn chests on death. They spawn animated pickups whose `chatPtr` holds a `GiveItemToPlayer` item id (`$83`–`$86`: 1, 2, or 5 gems, or a 5 HP heal).

### Algorithm

```
1. LDA gemDropType (from enemy-stats byte 3, via caller)
2. DEC; BEQ → SpawnDropGem1 ($DF29)   [type 1: fixed gem A]
3. DEC; BEQ → SpawnDropGem2 ($DF52)          [type 2: fixed gem B]
4. BRA → SpawnDropByHpTier ($DF7B)               [type 3+: random weighted]
5. COP [SpawnLastRel] @selected_handler
6. JMP $&DefeatHideAndRelease
```

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Caller | `StandardEnemyDefeatHandler` | JSR `$&EnemyGemDropRouter` |
| Targets | `SpawnDropGem1`–`DropBodyHeal5` | `$DF29`–`$DFE3` via `EnemyDropSystem` |

---

## EnemyStatBonusReward

**Address:** `$DD87` · **Size:** 107 bytes · **Movable:** No (only reachable via `$&` from `StandardEnemyDefeatHandler`)

### Description

Scene-indexed HP/STR/DEF reward spawner. Looks up the current `$scene_current` in an embedded scene→stat-type table, then spawns the appropriate stat reward actor (`e_hp_increase`, `e_str_increase`, or `e_def_increase` at `$E02D`–`$E0C6`) via `COP [SpawnLastRel]`.

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
| Caller | `StandardEnemyDefeatHandler` | JSR `$&EnemyStatBonusReward` |
| Spawns | `e_hp_increase`, `e_str_increase`, `e_def_increase` | Via `SpawnLastRel` |
| Shared VFX | `RewardActorVFX` (`$E110`) | Called by all stat actors |

---

## SpawnFieldRevealEffect

**Address:** `$DDF2` · **Size:** 291 bytes

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
| Spawned by | `EnemyDefeatDispatch.asm` (bank `$0A`) | Non-final kills in counter arenas: spawns `field_reveal_object` with remaining enemy count in `$26` (last enemy uses `StandardEnemyDefeatHandler` instead) |
| Reads | `event_block_table` | Event block definitions (dimensions + coordinates) |
| Triggers | `StageBgChangeFromDeathIdx` / `ApplyBgChange` | Actual tile swap COP commands |

---

## EnemyDeathFlash

**Address:** `$DF15` · **Size:** 20 bytes

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

---

## EnemyDropSystem

**Address:** `$DF29`–`$DFFF` · **Size:** 260 bytes (7 handlers + data)

> ⚠ Previously misnamed `DarkGemDropSystem` / `EnemyRewardChestSystem`. Enemies do **not** spawn chests — they spawn gem or heal pickups (item ids `$83`–`$86` via `GiveItemToPlayer`).

### Description

Enemy drop spawner with fixed-type entries plus an HP-tier weighted picker. Each handler:
1. Sets up a metasprite from `table_0EE000`
2. Spawns a friendly pickup actor (`$10` bit `$0020`) at the death position via `SpawnListAppend`
3. Writes the item id to `$chatPtr,X` for `InteractionDamage_NPCChat` → `GiveItemToPlayer`
4. Runs a shimmer/blink animation, then dies (`collect_handler_gem` only nudges gems toward the player)

Item ids on collection:
- `$0083` → 1 gem (sprite frames `#04` / `#09`)
- `$0084` → 2 gems (sprite frames `#05` / `#0A`)
- `$0085` → 5 gems (sprite frames `#06` / `#0B`)
- `$0086` → 5 HP heal (sprite frames `#22` / `#35`; triggers `SpawnItemSparkleEffect` in `GiveItemToPlayer`)

`drop_threshold_by_hp` holds weighted probability thresholds for the random selection path.

### Parts

| Part | Name | Address | Size | Purpose |
|------|------|---------|------|---------|
| Type 1 entry | `SpawnDropGem1` | `$DF29` | 15 B | Fixed gem type A: setup metasprite + spawn collect handler |
| Type 1 display | `DropBodyGem1` | `$DF38` | 26 B | chatPtr `$0083` (HP gem), frames `#04`/`#09` |
| Type 2 entry | `SpawnDropGem2` | `$DF52` | 15 B | Fixed gem type B: setup metasprite + spawn collect handler |
| Type 2 display | `DropBodyGem2` | `$DF61` | 26 B | chatPtr `$0084` (STR gem), frames `#05`/`#0A` |
| Weighted | `SpawnDropByHpTier` | `$DF7B` | 78 B | RNG tier selection → weighted table lookup → PHA/RTS dispatch |
| DEF gem | `DropBodyGem5` | `$DFC9` | 26 B | chatPtr `$0085` (DEF gem), frames `#06`/`#0B` |
| Special gem | `DropBodyHeal5` | `$DFE3` | 26 B | chatPtr `$0086` (special gem), frames `#22`/`#35` |
| Data | `drop_threshold_by_hp` | `$DFFD` | 48 B | `gem-drop-threshold` weighted probability table (3 tiers × 4 entries) |

### Algorithm (SpawnDropByHpTier)

```
1. Setup: SetMetasprite, SetSpritePalette, SpawnAfterMarked @collect_handler_gem
2. Compare playerMaxHp to playerHp for tier selection:
     maxHp/4 ≥ currentHp → tier 2 (strong, offset $20)
     maxHp/2 ≥ currentHp → tier 1 (medium, offset $10)
     else                  → tier 0 (weak, offset $00)
3. COP [RngByte] → random value $00-$FF
4. Walk drop_threshold_by_hp[tier_offset]:
     Compare RNG against each entry's threshold
     First entry whose threshold > RNG wins
5. Load handler address from winning entry
6. DEC; PHA; RTS → dispatch to selected gem display handler
```

### Weighted Distribution (drop_threshold_by_hp)

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
| Data | `drop_threshold_by_hp` | Must move with block |

---

## NpcDespawnStub

**Address:** `$DC77` · **Size:** 2 bytes · **Movable:** No (inbound `$&NpcDespawnStub` from `InteractionDamage_NPCChat`)

### Description

Immediate `COP [Die]` — one-tick despawn script. After a successful item give or dialogue interaction, `InteractionDamage_NPCChat` in `combat_collision` overwrites the NPC's entry pointer with `#$&NpcDespawnStub` / `#$*NpcDespawnStub`, zeroes its wait counter, and sets `$0700` in `$10` to block re-interaction. The NPC runs this stub on its next tick and is removed from the actor list.

### Algorithm

```
COP [Die]
```

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Assigned by | `InteractionDamage_NPCChat` | Post-interaction NPC despawn |

---

## SpawnDamageNumberEffect

**Address:** `$DCB4` · **Size:** 79 bytes

### Description

Floating damage-number actor: one 16-frame loop that draws packed-BCD damage digits via `$@ComposeDigitSprites` (bank `$03`) 16 pixels above the victim, rising 1 pixel per frame while tracking the victim's movement. No weapon trail, ghost copies, or afterimages.

Spawned only from the two damage paths in `combat_collision` via `COP [SpawnListAppend]` (`PlayerAttackHitTest` with flags `$2F00`, `ApplyHitDamageToVictim_DamagePath` with `$2B00`). The caller writes the digit value into the child's `$28` after spawn. Skipped for bosses (`$12` bit `$0020`) and damage ≥ 1000.

### Algorithm

```
1. Stage OAM attribute $3200; start Y = victim Y − 16
2. Remember victim slot in $24 and prior position in $20/$22
3. Loop 16 iterations (LoopStart #10):
     a. Add victim delta to position; Y −= 1 each frame
     b. Copy damage value from $28 to absolute scratch $0000
     c. JSL $@ComposeDigitSprites — append digit tiles to compose buffer
4. COP [Die]
```

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Spawned by | `combat_collision` | Two `SpawnListAppend` sites only |
| External | `ComposeDigitSprites` | Bank `$03` digit sprite factory |
| Unused | `DamageNumberShort_unused` (`$DC79`) | 4 rising frames + 32 more (not referenced) |

---

## SpawnItemSparkleEffect

**Address:** `$DD03` · **Size:** 88 bytes

### Description

Item-effect sparkle actor: writes **two** compose-buffer tile entries per frame (tiles `$327A` / `$327B`, offset ±4 px on X) at the spawning actor's position — 8 frames still, then 16 frames rising 1 pixel per frame (24 frames total). Not critical-hit feedback; no randomized scatter.

Spawned only by `GiveItemToPlayer` when the item effect index is ≥ 6 (item id `$86` and up, which also adds 5 to `hpToHeal` and plays sound `#22`) via `COP [SpawnListAppend]` with flags `$2F00`.

### Algorithm

```
1. Loop 24 frames:
     a. JSR AppendSparkleOamEntries — two tiles at Y = $16, X ± 4
     b. After 8 frames, decrement Y each frame (rise)
2. COP [Die]
```

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Embedded sub | `AppendSparkleOamEntries` | OAM entry builder |

---

## Statistics

| Metric | Value |
|--------|-------|
| Total functions documented | 9 (+ 7 gem sub-handlers) |
| Address span | `$DB8A`–`$DFFF` (~1,397 bytes) |
| Immovable entries | 4 (`StandardEnemyDefeatHandler` block parts + stub) |
| External `$&` inbound refs | 2 (`StandardEnemyDefeatHandler`, `NpcDespawnStub`) |
| COP spawn pattern | 6 functions use `SpawnLastRel` |

---

*Source: `extracted/functions/StandardEnemyDefeatHandler.asm`, `extracted/functions/SpawnFieldRevealEffect.asm`, `extracted/functions/EnemyDeathFlash.asm`, `extracted/functions/EnemyDropSystem.asm`, `extracted/functions/SpawnDamageNumberEffect.asm`, `extracted/functions/SpawnItemSparkleEffect.asm`, `extracted/functions/NpcDespawnStub.asm`, `docs/code/bank00/actors-combat-interaction.md`.*
