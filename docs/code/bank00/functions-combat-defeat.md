# Bank $00 — Functions: Enemy Defeat Pipeline

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00DB8A`–`$00DFFF` (defeat block + drop/VFX helpers)  
**Related:** [`actors-combat-interaction.md`](actors-combat-interaction.md) (hit stagger → defeat entry, stat reward actors) · [`README.md`](README.md)

## Source of truth

| Piece | `extracted/...` |
|--------|------------------|
| Standard defeat | `functions/StandardEnemyDefeatHandler.asm` |
| Counter-arena variant | `functions/EnemyDefeatDispatch.asm` (bank `$0A`) |
| Field reveal VFX | `functions/SpawnFieldRevealEffect.asm` |
| Death flash / drops | `functions/EnemyDeathFlash.asm`, `functions/EnemyDropSystem.asm` |
| Stat pickups | `actors/reward_actors.asm`, `tables/enemy_clear_reward_table.asm` |
| Stat / drop bytes | `tables/enemy_stats_table.asm` (byte +3 = `gemDropType`) |
| Hit → defeat wiring | `actors/hit_stagger_controller.asm`, `system/engine/combat_collision.asm` |
| Mid-kill reveal pickup | `actors/field_reveal_object.asm` |

**Naming:** All handler labels above are extracted symbols. `field_reveal_object` is a **separate actor** from `SpawnFieldRevealEffect` (tile sparkle + BG swap vs. floating stat/gem pickup).

**Counts:** `JumpFar` / entry-pointer installs to `StandardEnemyDefeatHandler` — 13 enemy scripts plus `EnemyDefeatDispatch` last-kill path (listed in block note). Direct `EnemyDeathFlash` spawns — 8+ call sites beyond the standard handler.

---

## Pipeline overview

Three defeat **paths** (not interchangeable):

| Path | When | Outcome |
|------|------|---------|
| **Standard** | Default death entry: `HitStaggerResolveHit` or inline `combat_collision` when HP = 0 and no `onDeathCallback` (`$7F1004`); or `COP JumpFar` from enemy script | Full handler below |
| **Custom `JumpFar`** | 13 enemies jump directly (same script body) | Same `StandardEnemyDefeatHandler` entry |
| **`EnemyDefeatFlashAndDrop` only** | `ir20_statue`, `ir26_statue` | Flash + gem router, **no** kill counter / stat reward |
| **`EnemyDefeatDispatch`** (bank `$0A`) | Mid-kill in counter arenas | Flash + **`field_reveal_object`** (not `SpawnFieldRevealEffect`); last kill `JumpFar`s to standard handler |

`ComposeDigitSprites_AtCursor` does **not** install `StandardEnemyDefeatHandler`; the engine defaults to it when the death callback slot is empty.

### Standard enemy death (execution order)

```text
Victim runs StandardEnemyDefeatHandler (X = defeated actor)
    1. DefeatCountKill (unless no-stats / boss): $0AEE BCD--, $0AEC--, orbitAngle := remaining count
    2. EnemyDefeatFlashAndDrop: halt move, SFX #06, SpawnListAppend EnemyDeathFlash ($0302), wait 3 ticks
    3. If no-stats or boss → EnemyDefeatBossCleanup → Die (no flag/gem/reward)
    4. SetDungeonKillFlag; gem branch:
           IF scene reward $0300 already claimed OR enemies remain (orbitAngle ≠ 0):
               gemDropType (+3 of enemy_stats_table) ≠ 0 → EnemyGemDropRouter → SpawnListAppend drop ($0420)
           ELSE (last enemy, reward not taken): skip gem → stat reward later
    5. Hide enemy ($10 $2000); ClearSolidHere if extendedFlags $0008
    6. If deathActionIdx ($7F0024) set AND reveal flag $0100+idx clear → SetFlag_0100, SpawnListAppend SpawnFieldRevealEffect ($0342)
    7. orbitAngle ≠ 0 → Die | orbitAngle = 0 → EnemyStatBonusReward → spawn e_hp/str/def_increase
```

| Function | Address | Size | Movable | Reachability |
|----------|---------|------|---------|--------------|
| `StandardEnemyDefeatHandler` | `$DB8A` | ~237 B | **No** | Victim entry / `JumpFar` |
| `EnemyGemDropRouter` | `$DD5B` | ~44 B | **No** | JSR `$&` from handler only |
| `EnemyStatBonusReward` | `$DD87` | ~107 B | **No** | JSR `$&` from handler only |
| `SpawnFieldRevealEffect` | `$DDF2` | ~291 B | ✓ | `SpawnListAppend` from handler + custom deaths |
| `EnemyDeathFlash` | `$DF15` | ~20 B | ✓ | `SpawnListAppend` (not `SpawnLastRel`) |
| `EnemyDropSystem` | `$DF29`–`$DFFF` | ~260 B | ✓ | Via router `SpawnListAppend` |
| `NpcDespawnStub` | `$DC77` | 2 B | **No** | `$&` from `InteractionDamage_NPCChat` |
| `SpawnDamageNumberEffect` | `$DCB4` | 79 B | ✓ | `combat_collision` only |
| `SpawnItemSparkleEffect` | `$DD03` | 88 B | ✓ | `GiveItemToPlayer` (item ≥ `$86`) |

---

## StandardEnemyDefeatHandler

**Address:** `$DB8A` · **Size:** 237 bytes · **Movable:** No (inbound `$&StandardEnemyDefeatHandler` from `hit_stagger_controller`, `combat_collision`)

### Description

**Live** central death script — the defeated actor runs it (`X` = victim slot). Default when HP hits 0 and `onDeathCallback` (`$7F1004`) is zero: `HitStaggerResolveHit` or inline `combat_collision` writes `#$&StandardEnemyDefeatHandler` into the victim's entry pointer. Also reached via `COP [JumpFar]` from 13 enemy scripts and from `EnemyDefeatDispatch` on the **last** kill.

Kill accounting uses `SetDungeonKillFlag` (monster ID in actor data), not a generic `$7F0022` increment in this file. Bosses (`extendedFlags` `$0080`) and **no-stats** actors (`statsPtr` = start of `enemy_stats_table`) skip counters, gems, and stat rewards.

**Measured (Mesen2, Diamond Mine scene `$3F`, one eye stalker and both laborers):**

- **Eye stalker kill** (`currentHp` set to 1, one sword hit): the first hit sets `$10 $0080` (stagger path, `$0040` set by `HitStaggerResolveHit`); the victim runs this handler with `$10 = $00C0`, the kill counter `$0AEC` drops 24 to 23, the flash (`EnemyDeathFlash`, `$10 $0302`, `$12 $1000`) appears one frame later, and the gem takes a freed slot at frame +4 with its marked child in the victim's old slot.
- **`$10 $0400` is not part of the normal death.** It is set on the victim only when the lethal hit resolves inline (`playerFlags $0010` set, or the victim's `$12 $0010` set): `ApplyHitDamageToVictim_DamagePath+223`. The gem is spawned with `$0420` and `DropBodyGem1+12` clears `$0400` one step later; with it forced on the gem could not be picked up (Will stood on it for 88 frames).
- **Diamond Mine laborers** (HP 1 before the hit, `$12 $0230`, extendedFlags `$0080`): one hit kills; no `currentHp` is written. The death is inline (`$10 $05C0`), runs `EnemyDefeatBossCleanup` (flash and damage digits, no gem, `$0AEC` stays 24) and hides the actor. The Freejia kidnapper was not run.
- **Slot reuse:** a freed slot keeps its old contents until it is reused or `InitActorPool` zeroes the pool; walk the list from `$56` to find live actors.

**Gem vs stat reward are separate decisions:**

- **`gemDropType`** (byte +3 of the row at `statsPtr`): `0` = never drop a currency gem; `1` / `2` / `3+` → `EnemyGemDropRouter`. Gems run only if the scene clear flag `$0300` is **already set** *or* other enemies remain (`orbitAngle` ≠ 0 after decrement).
- **Stat reward:** `EnemyStatBonusReward` runs only when `orbitAngle` = 0 (last counted enemy) and flag `$0300` is still clear — **independent** of `gemDropType`.

`EnemyGemDropRouter` and `EnemyStatBonusReward` share the same asm block (internal `$&` only) and must stay co-located in bank `$00`.

### Algorithm

See **Standard enemy death** diagram above; equivalent steps:

```
DefeatCountKill → EnemyDefeatFlashAndDrop → (boss/no-stats cleanup?) →
SetDungeonKillFlag → [optional EnemyGemDropRouter] → hide → [optional SpawnFieldRevealEffect] →
Die OR EnemyStatBonusReward
```

### Variables

| Symbol | Role |
|--------|------|
| `$14`, `$16` | Enemy death position (passed to flash/drop spawns) |
| `$7F0024,X` | `deathActionIdx` — event-block index for field tile reveal |
| `$7F0020,X` | `statsPtr` → `enemy_stats_table` row (byte +3 = `gemDropType`) |
| `$0AEC` / `$0AEE` | Remaining enemy count (hex / BCD); copied to `orbitAngle` on victim |
| `$7F1004,X` | `onDeathCallback` — when set, standard handler is **not** used as default |

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Installed by | `hit_stagger_controller`, `combat_collision` | Default enemy death entry when `$7F1004` is empty |
| Called from | `hit_stagger_controller` | When enemy has no saved script ptr |
| Calls | `EnemyGemDropRouter`, `EnemyStatBonusReward` | Internal JSR `$&` |
| Spawns | `EnemyDeathFlash`, `SpawnFieldRevealEffect` | `COP [SpawnListAppend]` |

---

## Reward routing reference

### Scene stat reward (`enemy_clear_reward_table`)

| Table value | Spawned actor | Player effect |
|-------------|---------------|---------------|
| `0` | *(none)* | No stat pickup |
| `1` | `e_hp_increase` | Max HP +1, refill missing HP via `hpToHeal` |
| `2` | `e_str_increase` | STR +1 |
| `3+` | `e_def_increase` | DEF +1 |

Gated by scene flag `$0300` + `$scene_current` (set in `RewardActorVFX`).

### Currency gem / heal drops (`gemDropType` → `GiveItemToPlayer` id)

| `gemDropType` | Router target | `chatPtr` item | Effect (inventory) |
|---------------|---------------|----------------|---------------------|
| `0` | *(no gem)* | — | Stat path may still run on last kill |
| `1` | `SpawnDropGem1` | `$83` | +1 gem |
| `2` | `SpawnDropGem2` | `$84` | +2 gems |
| `3+` | `SpawnDropByHpTier` | `$83`–`$86` | Weighted 1 / 2 / 5 gems or +5 HP heal (`$86`) |

These ids are **currency/heal pickups**, not the hidden stat items `$80`–`$82` used by `field_reveal_object`.

---

## EnemyGemDropRouter

**Address:** `$DD5B` · **Size:** 44 bytes · **Movable:** No (only reachable via `$&` from `StandardEnemyDefeatHandler`)

### Description

**Live** — reached with `A` = byte +3 (`gemDropType`, already masked) from `StandardEnemyDefeatHandler`. Two `DEC` operations select the spawn:

- **1** → `SpawnDropGem1` — item `$83`
- **2** → `SpawnDropGem2` — item `$84`
- **other nonzero** → `SpawnDropByHpTier` — weighted `$83`–`$86`

Each path uses `COP [SpawnListAppend]` with flags `$0420`, then `JMP DefeatHideAndRelease` (not `SpawnLastRel`).

> Enemies do **not** spawn chests — only animated pickups with `chatPtr` for `GiveItemToPlayer`.

### Algorithm

```
1. DEC; BEQ → SpawnListAppend SpawnDropGem1 → DefeatHideAndRelease
2. DEC; BEQ → SpawnListAppend SpawnDropGem2 → DefeatHideAndRelease
3. BRA → SpawnListAppend SpawnDropByHpTier → DefeatHideAndRelease
```

### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Caller | `StandardEnemyDefeatHandler` | JSR `$&EnemyGemDropRouter` |
| Targets | `SpawnDropGem1`–`DropBodyHeal5` | `$DF29`–`$DFE3` in `EnemyDropSystem.asm` |

---

## EnemyStatBonusReward

**Address:** `$DD87` · **Size:** 107 bytes · **Movable:** No (only reachable via `$&` from `StandardEnemyDefeatHandler`)

### Description

**Live** — last-kill branch only. Loads `enemy_clear_reward_table[sceneCurrent]` (direct indexed byte, not a scan). If flag `$0300` already set or tier = 0, `Die` immediately. Otherwise sets `displayModeFlags` `$0080`, spawns one of `reward_actors.e_hp_increase` / `e_str_increase` / `e_def_increase` via `SpawnListAppend` (`$1000`, child `$12` `$1000`), then `Die`. Fanfare, flag `$0300`, and dialog happen inside the spawned actor / `RewardActorVFX`.

**Measured (STR reward, scene `$3F`, counters forced so the kill was the last):** `displayModeFlags` goes `$0000` to `$0080` 4 frames after the victim's death and stays set for at least 120 frames; the reward actor (`$10 = $1000`, `$12 = $1000`) takes the freed slot. While the filter is on **the player does not run** (Will stayed at the same x with Right held; the entry word stayed fixed) and only 0 to 1 non-`$1000` actors moved per sample, against 0 to 10 in the control. The flash advances only with `$12 $1000` (without it it stays `$0302` until the filter ends); the reward actor runs with bit 12 in `$10` **or** `$12`. At the arrival of the pickup the filter goes from `$0080` to `$2000` (text) and the reward actor `$10` goes `$1000` to `$3000`; the text ends about 120 frames later with `displayModeFlags` back to 0. Companions were not tested (none exist in scene `$3F`).

### Algorithm

```
1. tier := enemy_clear_reward_table[sceneCurrent]
2. TestFlag_0300 → claimed → Die
3. tier = 0 → Die
4. displayModeFlags |= $0080
5. tier 1 → SpawnListAppend e_hp_increase; tier 2 → e_str_increase; else e_def_increase
6. Die (defeated enemy actor)
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
| Spawns | `e_hp_increase`, `e_str_increase`, `e_def_increase` | `SpawnListAppend` |
| Shared VFX | `RewardActorVFX` (`$E110`) | Called by all stat actors |

---

## SpawnFieldRevealEffect

**Address:** `$DDF2` · **Size:** ~291 bytes · **Live**

> No inventory logic — BG tile reveal VFX only. **Not** the same as `field_reveal_object` (stat/gem pickup spawned by `EnemyDefeatDispatch` for non-final kills).

### Description

When `deathActionIdx` (`$7F0024`) on the defeated enemy is nonzero and event flag `$0100` + index is still clear, `StandardEnemyDefeatHandler` sets the flag and spawns this actor (`SpawnListAppend`, `$0342`), copying the index into the child's `deathActionIdx`. Custom deaths (`pyCC_mystic_ball`, `awB1_wall_walker`) and `EnemyDefeatDispatch_CountKill` can also spawn it. **`field_reveal_object` is never spawned from this handler.**

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
| Spawned by | `StandardEnemyDefeatHandler` | When `deathActionIdx` + `$0100` flag gate passes |
| Spawned by | `pyCC_mystic_ball.asm`, `awB1_wall_walker.asm` | Custom death scripts |
| Spawned by | `EnemyDefeatDispatch_CountKill` | Same tile-reveal effect (not `field_reveal_object`) |
| Related | `field_reveal_object` | Separate actor — mid-kill **pickup** from `EnemyDefeatDispatch` only |
| Reads | `event_block_table` | Event block definitions (dimensions + coordinates) |
| Triggers | `StageBgChangeFromDeathIdx` / `ApplyBgChange` | Actual tile swap COP commands |

---

## EnemyDeathFlash

**Address:** `$DF15` · **Size:** 20 bytes

### Description

Brief white-flash metasprite at the enemy position. **`COP [SpawnListAppend]`** with flags `$0302`; child `$12` gets `$1000` so it keeps running during display-filter mode. Single-frame display then `Die`.

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
| Also spawned from | `EnemyDefeatDispatch` and enemy actor scripts | `COP [SpawnListAppend] ( @EnemyDeathFlash, … #$0302 )` — 11 `@EnemyDeathFlash` spawn sites in 9 extracted files in total (counted with `rg`; includes the two engine-side sites) |

---

## EnemyDropSystem

**Address:** `$DF29`–`$DFFF` · **Size:** 260 bytes (7 handlers + data)

> ⚠ Enemies do **not** spawn chests — they spawn gem or heal pickups (item ids `$83`–`$86` via `GiveItemToPlayer`).

### Description

Enemy drop spawner with fixed-type entries plus an HP-tier weighted picker. Each handler:
1. Sets up a metasprite from `spriteset_pickups_effects` (the extracted label for the table formerly called `table_0EE000`)
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
| Type 1 display | `DropBodyGem1` | `$DF38` | 26 B | chatPtr `$0083` (+1 gem), frames `#04`/`#09` |
| Type 2 entry | `SpawnDropGem2` | `$DF52` | 15 B | Fixed 2-gem pickup setup |
| Type 2 display | `DropBodyGem2` | `$DF61` | 26 B | chatPtr `$0084` (+2 gems), frames `#05`/`#0A` |
| Weighted | `SpawnDropByHpTier` | `$DF7B` | 78 B | RNG tier selection → weighted table lookup → PHA/RTS dispatch |
| 5-gem pickup | `DropBodyGem5` | `$DFC9` | 26 B | chatPtr `$0085` (+5 gems), frames `#06`/`#0B` |
| Heal pickup | `DropBodyHeal5` | `$DFE3` | 26 B | chatPtr `$0086` (+5 HP via `hpToHeal`), frames `#22`/`#35` |
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
| Dispatched by | `EnemyGemDropRouter` | `COP [SpawnListAppend]` flags `$0420` |
| Child actor | `collect_handler_gem` | Gem collection interaction handler (nudges gem toward player) |
| Data | `drop_threshold_by_hp` | Must move with block |

---

## NpcDespawnStub

**Address:** `$DC77` · **Size:** 2 bytes · **Movable:** No (inbound `$&NpcDespawnStub` from `InteractionDamage_NPCChat`)

### Description

Immediate `COP [Die]` — one-tick despawn script. After a successful item give or dialogue interaction, `InteractionDamage_NPCChat` in `combat_collision` overwrites the NPC's entry pointer with `#$&NpcDespawnStub` / `#$*NpcDespawnStub`, zeroes its wait counter, and ORs `$0700` into its `$10` (`$0100`, `$0200` and `$0400` are in the interaction, contact and attack masks, so the actor is out of every collision pass and cannot be touched again). The NPC runs this stub on its next tick and is removed from the actor list. Measured on a gem pickup (the only caller seen): the entry becomes `NpcDespawnStub` and `$10` goes `$0020` to `$0720` at the pickup frame; one frame later the gem and its marked child are both out of the list (`Die` ran 6 times and `UnlinkChildrenCascade` once: `Die` cascades to marked children, it does not defer). A chest-like NPC was not run.

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
| Primary spawn COP | `SpawnListAppend` for flash, reveal, drops, stat pickups |

---

## Source validation

**Files checked:** `StandardEnemyDefeatHandler.asm`, `EnemyDropSystem.asm`, `EnemyDeathFlash.asm`, `SpawnFieldRevealEffect.asm`, `EnemyDefeatDispatch.asm`, `NpcDespawnStub.asm`, `SpawnDamageNumberEffect.asm`, `SpawnItemSparkleEffect.asm`; `hit_stagger_controller.asm`, `combat_collision.asm`; `enemy_stats_table.asm`, `enemy_clear_reward_table.asm`, `reward_actors.asm`, `field_reveal_object.asm`.

**Verified:** Defeat step order and gem vs stat gating (`TestFlag_0300`, `orbitAngle`); `deathActionIdx` + `$0100` reveal flags; `EnemyGemDropRouter` DEC dispatch; drop item ids `$83`–`$86`; `SpawnListAppend` vs incorrect `SpawnLastRel` claims; separate `field_reveal_object` path in `EnemyDefeatDispatch`.

**Notes:** Weighted drop percentages in `drop_threshold_by_hp` table match `EnemyDropSystem.asm` block comment. Boss / no-stats cleanup timing uses `WaitByte` `#02` / `#05` as in asm.
