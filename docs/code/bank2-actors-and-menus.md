# Bank 2 Continuation — Actors, Player Character, Inventory & Utility Functions

> Continuation of bank 02 analysis covering the **unanalyzed** portions:
> actor blocks ($02B20E–$02C38B), the player character state machine ($02C38C–$02CFD0),
> the inventory menu system ($02E396–$02ED02), and utility functions ($02ED02–$02F08C).
>
> **Prerequisite:** [bank2-code-analysis.md](bank2-code-analysis.md) covers Groups 1–14 (system
> engine: $028000–$02B20C) and Groups A–J (player movement physics: $02CFD0–$02E395).

---

## 1. Coverage Summary

| Range | Hex | File(s) | Category | Status |
|-------|-----|---------|----------|--------|
| 163840–176652 | $028000–$02B20C | `chunk_028000.asm` | System engine | ✅ Previously analyzed |
| **176654–176798** | **$02B20E–$02B29E** | **`actor_02B20E.asm`** | **Shadow shimmer actor** | 🆕 This document |
| **176798–177195** | **$02B29E–$02B42B** | **`actor_02B29E.asm`** | **Player movement controller** | 🆕 This document |
| **177195–178099** | **$02B42B–$02B7B3** | **`actor_02B42B.asm`** | **Slope/ramp physics controller** | 🆕 This document |
| **178099–179702** | **$02B7B3–$02BDF6** | **`actor_02B7B3.asm`** | **Player attack/ability system** | 🆕 This document |
| **179702–179826** | **$02BDF6–$02BE72** | **`actor_02BDF6.asm`** | **Attack trail followers** | 🆕 This document |
| **179826–181132** | **$02BE72–$02C38C** | **(in actor_02B7B3.asm)** | **Attack implementations (cont.)** | 🆕 This document |
| **181132–184272** | **$02C38C–$02CFD0** | **`player_character.asm`** | **Player character state machine** | 🆕 This document |
| 184272–189333 | $02CFD0–$02E395 | `chunk_02CFD0.asm` | Player movement physics | ✅ Previously analyzed |
| **189334–191746** | **$02E396–$02ED02** | **`inventory_menu.asm`** | **Inventory menu system** | 🆕 This document |
| **191746–192584** | **$02ED02–$02F048** | **`func_02ED02.asm`** | **Inventory screen overlay** | 🆕 This document |
| **192584–192618** | **$02F048–$02F06A** | **`func_02F048.asm`** | **Dialogue display wrapper** | 🆕 This document |
| **192618–192652** | **$02F06A–$02F08C** | **`func_02F06A.asm`** | **VRAM buffer clear** | 🆕 This document |

**New analysis:** ~16,018 bytes, ~200+ code/data pieces across 10 blocks.

**Bank 2 total (combined with previous):** ~33,892 bytes, ~400+ named parts.

---

## 2. Compilation Relationships

All code in this document resides in `?BANK 02` and shares the same compilation
unit rooted at `player_character.asm`:

```
player_character.asm
  ?INCLUDE 'actor_02B20E'      — shadow shimmer cycling
  ?INCLUDE 'actor_02B29E'      — player movement controller
  ?INCLUDE 'actor_02B42B'      — slope/ramp physics controller
  ?INCLUDE 'actor_02B7B3'      — attack/ability system
    ?INCLUDE 'actor_02BDF6'    — attack trail followers
    ?INCLUDE 'ApplyOrbitalOffsetFromRef'
    ?INCLUDE 'cop_handlers_actors'
    ?INCLUDE 'table_01D9A7'    — ability animation data A
    ?INCLUDE 'table_01D9BF'    — ability animation data B
    ?INCLUDE 'table_0EE000'    — Dark Friar spritemap
    ?INCLUDE 'table_178000'    — attack FX spritemap
    ?INCLUDE 'table_179000'    — Aura projectile spritemap
  ?INCLUDE 'game_over_sequence'
  ?INCLUDE 'hardware_math'
  ?INCLUDE 'table_17D000'      — ranged weapon spritemap
```

`inventory_menu.asm` is a separate compilation unit within `system/inventory/`:
```
inventory_menu.asm
  ?INCLUDE 'cop_handlers_script'
  ?INCLUDE 'inventory_spritemap'
  ?INCLUDE 'system_strings'
```

`func_02ED02.asm`, `func_02F048.asm`, and `func_02F06A.asm` are standalone
functions included from the system engine compilation unit.

---

## 3. Player Actor Architecture

The player character is composed of **five cooperating actors** spawned at
initialization. Each handles a distinct aspect of player behavior:

```
player_character (actor_def @ $02C38C)
  │
  ├─ SpawnBefore → e_actor_02B7B3   [Attack/Ability System]
  ├─ SpawnAfter  → actor_02B29E     [Movement Controller]
  ├─ SpawnAfter  → e_actor_02B42B   [Slope/Ramp Physics]
  └─ SpawnLastRel → e_actor_02B20E  [Shadow Shimmer FX]
```

All five actors share the player's actor slot context via `$player_actor` and
communicate through:
- `$player_flags` — shared state bitmask
- `$player_speed_ew` / `$player_speed_ns` — movement velocity
- `$0AD4` — current character form (0=Will, 1=Freedan, 2=Shadow)
- `$0AA2` — ability availability bitmask
- `$00EA` — active special ability type for graphics reload

### Player Flags Reference ($player_flags)

| Bit | Hex | Meaning |
|-----|-----|---------|
| 0 | $0001 | Attack system active / attack lock |
| 1 | $0002 | Attack in progress (combo state) |
| 3 | $0008 | Player disabled / dead |
| 4 | $0010 | Terrain shake active |
| 8 | $0800 | Ability FX active (Aura/charge) |
| 9 | $0200 | Blocked movement flag |
| 10 | $0A00 | Combined blocked flags |
| 11 | $2000 | Special action lock (ability/climb) |
| 12 | $1000 | On-slope flag (set by ramp physics) |
| 13 | $2000 | Climbing/ability lock |
| 14 | $8000 | Damage state / hitstun |
| combo | $2A00 | Movement-blocking composite |
| combo | $2B00 | Movement+action blocking composite |
| combo | $3000 | Both movement blocks |
| combo | $3A00 | Extended movement block |

---

## 4. Functional Group Analysis — Actor Blocks

### Group 15: Shadow Shimmer Cycling ($02B20E–$02B29E)

**File:** `extracted/actors/actor_02B20E.asm`
**Purpose:** Manages palette cycling effects when the player stands in a Dark Space
area. Only active when `$0AD4 == 2` (Shadow form).

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `e_actor_02B20E` | `ShadowShimmerInit` | $02B20E | 51 B | Code | Entry point. Checks `$0AD4 == 2` (Shadow form), otherwise dies. Spawns palette marker, enters idle state. |
| `code_02B21F` | `ShadowShimmerIdle` | $02B21F | 34 B | Code | Wait state: monitors `player_speed_ew \| player_speed_ns`. If player moves, branch to active. Checks flag byte for state toggle. |
| `code_02B241` | `ShadowShimmerActive` | $02B241 | 35 B | Code | Active state: palette #24 cycling while player moves. If player stops, checks flag to return to idle. |
| `sub_02B264` | `ShadowShimmerGuard` | $02B264 | 41 B | Code | Validates that `$0AD4` still == 2 and player isn't flagged $0040 (form changed or locked). If invalid, aborts actor via `PLA; COP [Die]`. |
| `func_02B28D` | `ShadowShimmerCycleA` | $02B28D | 7 B | Code | Infinite palette #23 cycle loop (idle glow). |
| `func_02B294` | `ShadowShimmerCycleB` | $02B294 | 7 B | Code | Infinite palette #24 cycle loop (active glow). |
| `func_02B29B` | `ShadowShimmerNop` | $02B29B | 3 B | Code | No-op entry: `COP [SetEntryContinue]; RTL`. Used as "dead" state. |

**Pattern:** Two-state palette toggle. Idle = palette #23 (dim glow), Active =
palette #24 (bright glow). Transitions are driven by player movement velocity.

---

### Group 16: Player Movement Controller ($02B29E–$02B42B)

**File:** `extracted/actors/actor_02B29E.asm`
**Purpose:** The central per-frame movement pipeline. Reads joypad input, converts
to velocity, applies positional deltas, and dispatches to `PlayerMovementTick`
for collision-checked movement.

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `actor_02B29E` | `PlayerMoveController` | $02B29E | 396 B | Code | Main entry. Scales positions to ×4 sub-pixel. Each frame: reads player actor slot, checks paralysis ($0080) and death flags ($7F0028,X BMI). If player_flags has $0A00 (movement blocked), zeroes velocity accumulators. Otherwise, reads joypad via `code_02B3C6`, combines with `player_speed_ew`/`player_speed_ns`, accounts for slope flag ($1000), applies velocity. If actor flags $0008 clear, calls `JSL $@PlayerMovementTick` for collision. Writes back to actor position registers. |
| `code_02B3C6` | `JoypadToVelocity` | $02B3C6 | 94 B | Code | Converts joypad button state ($0657) to 2D velocity packed as two signed bytes in A (high=X, low=Y). Handles 8 directions: pure cardinal and diagonal. Returns movement vector: pure directions = ±8, diagonals = (±6, ±6) or (6, ±10). |

**Register conventions:**
- `$14/$16` — Player position (sub-pixel, ×4 scale) — read/write
- `$0022` — X position for collision engine
- `$0026` — Y position for collision engine
- `$0020` — X delta (speed + joypad + slope adjustment)
- `$0024` — Y delta
- `$0408/$040A` — External velocity accumulators (knockback, conveyors, etc.)
- `$09C6` — Slope fractional accumulator

**Movement pipeline per frame:**
```
1. Read joypad → JoypadToVelocity → packed velocity byte pair
2. If player_speed_ew != 0: use it directly (× 4), clear $1000 slope flag
3. Else: use joypad X component + $0408 accumulator
4. Same for vertical: player_speed_ns or joypad Y + $040A
5. If actor collision flag ($0008) set → call PlayerMovementTick
6. Else: direct position addition (no collision)
7. Write back sub-pixel and pixel positions to actor slot
```

---

### Group 17: Slope/Ramp Physics Controller ($02B42B–$02B7B3)

**File:** `extracted/actors/actor_02B42B.asm`
**Purpose:** Runs every frame to detect slope/ramp tiles under the player and apply
terrain-following physics: speed curves, auto-deceleration, and maximum speed
clamping.

#### Subgroup 17A: Slope Detection & Dispatch

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `e_actor_02B42B` | `SlopePhysicsEntry` | $02B42B | 301 B | Code | Main entry. Checks paralysis/death. If player moving: probes tile at player feet via `TileProbeMain`, dispatches through `table_02B57C` for slope types ($03, $05, $0A, $0C). If not moving but $1000 flag set: probes 4 adjacent tiles for ramp exit. Falls through to flat-ground deceleration. |
| `table_02B57C` | `SlopeTileDispatch` | $02B57C | 32 B | &Code | 16-entry lookup table indexed by collision tile type. Non-zero entries: $03→`func_02B538`, $05→`code_02B53D`, $0A→`code_02B542`, $0C→`code_02B547`. |
| `func_02B538` | `SlopeType03Handler` | $02B538 | 5 B | Code | Slope type $03 (right ascending): calls `sub_02B5E2` (add NS speed from curve). |
| `code_02B53D` | `SlopeType05Handler` | $02B53D | 5 B | Code | Slope type $05 (semi-solid ramp): calls `sub_02B59C` (subtract EW speed from curve). |
| `code_02B542` | `SlopeType0AHandler` | $02B542 | 5 B | Code | Slope type $0A (passable ramp): calls `code_02B5BC` (add EW speed from curve). |
| `code_02B547` | `SlopeType0CHandler` | $02B547 | 3 B | Code | Slope type $0C (left ascending): calls `sub_02B5FE` (subtract NS speed from curve). |
| `code_02B550` | `SlopeFlatExit` | $02B550 | 11 B | Code | No slope detected: clamp speed, clear slope accumulator ($09C6) and step counter ($09B6). |
| `code_02B55B` | `SlopeFlatDecelerate` | $02B55B | 27 B | Code | Flat ground: if EW speed active → `sub_02B675` (decelerate EW). If slope flag $1000 → clear it. If NS speed active → `sub_02B714` (decelerate NS). |

#### Subgroup 17B: Speed Curve Application

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `sub_02B59C` | `ApplySlopeCurveNegEW` | $02B59C | 32 B | Code | Reads deceleration curve table at `$09BA` indexed by `$09B6 & $0F`. Negates value, adds to `player_speed_ew`. If speed reaches zero, sets $1000 slope flag. |
| `code_02B5BC` | `ApplySlopeCurvePosEW` | $02B5BC | 28 B | Code | Same but positive addition to EW speed. |
| `sub_02B5E2` | `ApplySlopeCurvePosNS` | $02B5E2 | 28 B | Code | Reads curve table at `$09BC`, adds to `player_speed_ns`. |
| `sub_02B5FE` | `ApplySlopeCurveNegNS` | $02B5FE | 32 B | Code | Same but negated addition to NS speed. |

**Speed curve system:** Variables `$09BA` and `$09BC` point to 16-entry signed
speed delta tables. `$09B6` is a step counter (incremented each frame on slope).
The counter wraps at 16 entries (`AND #$000F`), creating periodic speed
oscillation for natural slope traversal feel.

#### Subgroup 17C: Speed Clamping

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `sub_02B61E` | `ClampSpeeds` | $02B61E | 87 B | Code | Clamps `player_speed_ew` to ±`$09C8` and `player_speed_ns` to ±`$09CA`. Uses absolute value comparison. |

#### Subgroup 17D: Flat-Ground Deceleration

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `sub_02B675` | `DecelerateEW` | $02B675 | 140 B | Code | If slope flag $1000 set, skip. If |speed| < 3, snap to zero. Otherwise: checks opposing joypad direction — if pressed, apply deceleration from curve table (`sub_02B701`). Handles both positive and negative speeds with symmetric logic. |
| `sub_02B701` | `ReadDecelerationStep` | $02B701 | 19 B | Code | Reads deceleration delta from table at `$09C2`, indexed by `$09B8 & $0F`. Increments step counter. |
| `sub_02B714` | `DecelerateNS` | $02B714 | 140 B | Code | Mirror of `sub_02B675` for north-south axis. Same minimum speed threshold (3), same curve-table deceleration. Uses `sub_02B7A0`. |
| `sub_02B7A0` | `ReadDecelerationStepNS` | $02B7A0 | 19 B | Code | Mirror of `sub_02B701` — reads from same table but separate counter. |

**Deceleration model:** When the player releases a direction key, speed doesn't
snap to zero. Instead, a curve table at `$09C2` provides per-frame deceleration
deltas. Speed below ±3 snaps to zero immediately. If the player presses the
*opposing* direction, deceleration is doubled (applied from both sides).

---

### Group 18: Player Attack & Ability System ($02B7B3–$02BDF6)

**File:** `extracted/actors/actor_02B7B3.asm`
**Purpose:** Manages all player attack and special ability execution. This actor
runs before the main movement controller and intercepts the attack button to
execute context-appropriate abilities.

#### Subgroup 18A: Attack Dispatcher

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `e_actor_02B7B3` | `AttackSystemEntry` | $02B7B3 | 42 B | Code | Entry: if player_flags $0008 (dead) → die. Clear $0001 (attack lock). Each frame: check $2A00 (blocked) → skip. Check `$0AD4 < 2` → listen for attack button ($8001). |
| `code_02B7DE` | `WillAttackDispatch` | $02B7DE | 109 B | Code | Will's attack ($0AD4==0). Sets attack lock. Checks `$0AA2` bits $01+$04 (has Psycho Dash/Slider). Charges with `COP [LoopInit]` (28 frames). On charge complete: checks for L/R buttons → Psycho Slider, else → Psycho Dash. |
| `func_02B86D` | `FreedanAttackDispatch` | $02B86D | 150 B | Code | Freedan/Shadow attack ($0AD4≠0). Checks `$0AA2` bits $10+$40 (Dark Friar/Earthquaker). Charges 40 frames. On release → Dark Friar. On L/R + direction → Aura Barrier/Spin Dash. |
| `code_02B855` | `LaunchPsychoDash` | $02B855 | 12 B | Code | Validates facing direction, sets player function to `func_02BEA0` (Psycho Dash). |
| `code_02B861` | `LaunchPsychoSlider` | $02B861 | 12 B | Code | Validates facing, sets player function to `func_02C0A9` (Psycho Slider). |
| `code_02B8D6` | `LaunchDarkFriar` | $02B8D6 | 17 B | Code | Sets `$00EA=1`, sets player function to `func_02BB3B` (Dark Friar). |
| `code_02B8E7` | `LaunchAuraBarrier` | $02B8E7 | 26 B | Code | Requires player stopped. Sets `$00EA=2`, sets player function to `func_02B97F` (Aura Barrier). |
| `code_02B901` | `AttackCleanup` | $02B901 | 37 B | Code | Post-attack cleanup: kills spawned FX actor, plays palette effect (#0B for Will, #0C for Freedan), returns to idle state via `code_02B7BD`. |

#### Subgroup 18B: Helper Subroutines

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `sub_02B926` | `SetPlayerActorFunc` | $02B926 | 13 B | Code | Writes function pointer A to player actor slot $0000,Y and clears frame counter $0008,Y. |
| `sub_02B933` | `ValidateAttackReady` | $02B933 | 22 B | Code | Checks player_flags $3A00 (any blocking state). Checks facing direction < 4 (cardinal). If invalid, aborts to `AttackCleanup`. |
| `sub_02B946` | `ValidateAttackContinue` | $02B946 | 9 B | Code | Checks player_flags $2B00 (movement/action block). If set, aborts. |
| `sub_02B94F` | `SavePlayerPosition` | $02B94F | 14 B | Code | Copies player actor position ($0014,Y / $0016,Y) to $14/$16 scratch. |
| `sub_02B95D` | `CheckAttackChargeable` | $02B95D | 32 B | Code | Returns carry set (blocked) if: player_flags $8000 (hitstun), or actor $0028,Y is negative (death animation), or animation frame >= 4 (mid-combo). Used for Freedan's extended charge check. |

#### Subgroup 18C: Aura Barrier — Spinning Shield ($02B97F–$02BABD)

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `func_02B97F` | `AuraBarrierMain` | $02B97F | 125 B | Code | Sets actor $0200 (special attack) + player_flags $0800 (ability FX). Spawns VRAM DMA actor (`code_02BA0C`). Handles edge case: if spawn failed (Y=$1FC0), abort. Scene $0020 special: entry-exit loop waiting for VRAM $4400 ready. Loads FX palette (#198090), enters attack sprite sequence (#06→#02→#03 loop). Spawns rotating projectile children and orbiting trail (`code_02BA17`). |
| `code_02B9FC` | `AuraBarrierEnd` | $02B9FC | 16 B | Code | Clears $0200 flag. If restore pointer exists, restores saved state. Jumps to `code_02C3C8` (idle). |
| `code_02BA0C` | `AuraVramDmaLoader` | $02BA0C | 11 B | Code | DMA uploads `misc_fx_1CC480` to VRAM $4400 ($0600 bytes) for Aura FX tiles. Dies immediately. |
| `code_02BA17` | `AuraOrbitalSpawner` | $02BA17 | 150 B | Code | Spawns 2–4 orbital children (`func_02BAFE`) depending on `$0B1E` (ability level). Manages orbit rotation: increments angle ($26) by 2 each frame, grows radius ($7F0012,X) up to $40. Calls `sub_02BABD` for position updates. After $F0 frames, transitions children to shrink phase (`func_02BB29`). |
| `sub_02BABD` | `UpdateOrbitalPositions` | $02BABD | 65 B | Code | Iterates through all orbital children via direct page chain. For each: calls `ApplyOrbitalOffsetFromRef` to compute position from parent, advances angle by phase offset ($40 or $80 per child). |
| `func_02BAFE` | `AuraProjectileChild` | $02BAFE | 43 B | Code | Individual orbiting projectile sprite. Scene $DD special: forces priority $2000. Uses spritemap `table_179000`. Loops through 3-frame animation. |
| `func_02BB29` | `AuraProjectileShrink` | $02BB29 | 18 B | Code | Shrink animation for orbital projectile: plays frames #01→#00, then hides (TSB $2000 to flags $10). |

#### Subgroup 18D: Dark Friar — Directional Projectile ($02BB3B–$02BC79)

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `func_02BB3B` | `DarkFriarMain` | $02BB3B | 88 B | Code | Sets player_flags $2000 (special lock). Spawns VRAM DMA (`code_02BC02`). Waits for VRAM ready ($4400). Loads FX palette (#198070). Spawns palette thinker (#4A). Gets facing direction → `COP [SwitchCase]` → 4 directional handlers. |
| `code_list_02BB93` | `DarkFriarDirTable` | $02BB93 | 8 B | &Code | Switch table: [South, North, West, East]. |
| `code_02BB9B` | `DarkFriarSouth` | $02BB9B | 25 B | Code | South: spawns projectile (`code_02BC0D`) + trail (`code_02BC2C`) at offset (−2, +26). Player sprite #36. |
| `code_02BBB4` | `DarkFriarNorth` | $02BBB4 | 25 B | Code | North: spawns at (0, −64). Player sprite #37. |
| `code_02BBCD` | `DarkFriarWest` | $02BBCD | 25 B | Code | West: spawns at (−52, −22). Trail uses `code_02BC74`. Player sprite #38. |
| `code_02BBE6` | `DarkFriarEast` | $02BBE6 | 17 B | Code | East: spawns at (+52, −22). Trail uses `code_02BC79`. Player sprite #39. |
| `code_02BBFD` | `DarkFriarFinish` | $02BBFD | 5 B | Code | Wait 7 frames, restore saved state. |
| `code_02BC02` | `DarkFriarVramDma` | $02BC02 | 11 B | Code | DMA uploads `misc_fx_1CC000` to VRAM $4400 ($0480 bytes). Dies. |
| `code_02BC0D` | `DarkFriarProjectile` | $02BC0D | 26 B | Code | Main projectile sprite: uses spritemap `table_178000`. Calculates offset from parent, waits 7 frames, then plays frame #00 and dies. |
| `code_02BC27` | `DarkFriarTrailSouthInit` | $02BC27 | 5 B | Code | Sets $2000 in $12 (south facing modifier), falls through to trail. |
| `code_02BC2C` | `DarkFriarTrailSouth` | $02BC2C | 72 B | Code | South/default trail: calculates offset from player. If `$0B1C` (upgrade level) ≥ 1, enables collision. Animates forward with Y movement (sprites #01→#02→#03, hitbox enabled). |
| `code_02BC74` | `DarkFriarTrailWestInit` | $02BC74 | 5 B | Code | Sets $4000 in $12 (west facing modifier). |
| `code_02BC79` | `DarkFriarTrailEastWest` | $02BC79 | 72 B | Code | East/West trail: same as south but with X-axis movement. |

#### Subgroup 18E: Dark Friar — Collision & Bounce ($02BCC1–$02BDF4)

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `func_02BCC1` | `DarkFriarBounceLoop` | $02BCC1 | 52 B | Code | Main bounce animation loop. If $4000 set in flags → die (off-screen). Calls `COP [ReloadForceMove]` for movement. On wall hit ($2A): if `$0B1C == 2` (fully upgraded), allows button press to redirect. |
| `code_02BCEE` | `DarkFriarDisableCollide` | $02BCEE | 4 B | Code | Clears collision callback. |
| `code_02BCF2` | `DarkFriarOnHit` | $02BCF2 | 26 B | Code | Collision callback: spawns 4 fragment actors at 0°/64°/128°/192° offsets. Each fragment orbits and fades. |
| `code_02BD0C` | `DarkFriarFragment1` | $02BD0C | 5 B | Code | Fragment at angle $40. |
| `code_02BD11` | `DarkFriarFragment2` | $02BD11 | 5 B | Code | Fragment at angle $80. |
| `code_02BD16` | `DarkFriarFragment3` | $02BD16 | 3 B | Code | Fragment at angle $C0. |
| `(loc_02BD19)` | `DarkFriarFragmentInit` | $02BD19 | 87 B | Code | Shared fragment initialization: sets orbital angle, loads animation data from `table_01D9BF`, saves parent position, spawns trail children, enables hitbox (#04). |
| `func_02BDC9` | `DarkFriarFragmentLoop` | $02BDC9 | 43 B | Code | Fragment animation loop: plays frame, on wall hit applies velocity from stored deltas (`$7F100C,X` / `$7F100E,X`). If $4000 → die (off-screen). |

#### Subgroup 18F: Attack Trail Followers ($02BDF6–$02BE89)

**File:** `extracted/actors/actor_02BDF6.asm`

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `e_actor_02BDF6` | `TrailFollowerSprA` | $02BDF6 | 5 B | Code | Trail sprite with hitbox #05 (smaller). Falls through to shared loop. |
| `e_actor_02BDFB` | `TrailFollowerSprB` | $02BDFB | 33 B | Code | Trail sprite with hitbox #06 (larger). Calls `sub_02BE55` to initialize position queue, then enters follow loop: each frame calls `sub_02BE1A` to cascade position history. |
| `sub_02BE1A` | `TrailPositionCascade` | $02BE1A | 59 B | Code | 3-frame position queue cascade: shifts $7F0000→$14, $7F0002→$7F0000, $7F000E→$7F0002, parent→$7F000E. Same for Y axis. Creates smooth trailing effect. |
| `sub_02BE55` | `TrailPositionInit` | $02BE55 | 29 B | Code | Initializes all 3 position queue slots (X: $7F0000/0002/000E, Y: $7F0018/001A/0004) to current $14/$16. |
| `sub_02BE72` | `ComputeParentOffset` | $02BE72 | 23 B | Code | Stores offset from parent actor ($24 = parent slot) to current position as signed delta in `$7F100C,X` / `$7F100E,X`. |
| `sub_02BE89` | `ApplyParentOffset` | $02BE89 | 23 B | Code | Inverse of above: adds stored offset back to parent position to reposition this actor. |

#### Subgroup 18G: Psycho Dash — Directional Charge ($02BEA0–$02C0A9)

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `func_02BEA0` | `PsychoDashMain` | $02BEA0 | 9 B | Code | Loads animation table 0 from `table_01D9A7`, calls `code_02CCA5` (disable status effects), gets player facing → switch-case dispatch. |
| `code_list_02BEB7` | `PsychoDashDirTable` | $02BEB7 | 8 B | &Code | Switch: [South, North, West, East]. |
| `code_02BEBF` | `PsychoDashSouth` | $02BEBF | 16 B | Code | South: spawn trail (`code_02BF09`), set body sprite #04, move Y +54. |
| `code_02BECF` | `PsychoDashNorth` | $02BECF | 19 B | Code | North: set force NE, sprite #04, move Y −54. |
| `code_02BEE2` | `PsychoDashWest` | $02BEE2 | 19 B | Code | West: set force both, sprite #04, move X −54. |
| `code_02BEF5` | `PsychoDashEast` | $02BEF5 | 14 B | Code | East: sprite #04, move X +54. |
| `code_02BF09` | `PsychoDashTrailSouth` | $02BF09 | 104 B | Code | Trail recorder for south: samples 8 Y-position deltas into buffer at $09D0, then replays them in reverse as forced movements. |
| `code_02BF71` | `PsychoDashTrailNorth` | $02BF71 | 104 B | Code | Same for north (inverted deltas). |
| `code_02BFD9` | `PsychoDashTrailWest` | $02BFD9 | 104 B | Code | Same for west (X-axis deltas). |
| `code_02C041` | `PsychoDashTrailEast` | $02C041 | 104 B | Code | Same for east (inverted X deltas). |

**Psycho Dash trail system:** Records 8 frames of positional deltas during the
dash in a buffer at `$09D0`. Then replays these deltas in reverse to create a
"rubber-band" return trail effect. Frame timing: 6 ticks recording, 3 ticks
replay per sample.

#### Subgroup 18H: Psycho Slider — Guided Energy Ball ($02C0A9–$02C232)

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `func_02C0A9` | `PsychoSliderMain` | $02C0A9 | 211 B | Code | Sets $2002 (player lock + attack), $player_flags. Spawns guided projectile (`func_02C232`). Enters charge loop: sprite #22, animate. On contact ($0080): abort. If charge >= 12: allow L/R charge direction. On expire: loads animation set 2, enters launch sequence with forced movement, joypad → launch direction. |
| `func_02C17C` | `PsychoSliderRelease` | $02C17C | 29 B | Code | Clears $2800 player_flags. Loads animation table. Checks `$0B1A` (upgrade level): returns frame count 12 (base) or 24 (upgraded). |
| `func_02C199` | `PsychoSliderLaunch` | $02C199 | 37 B | Code | Sets sprite timer, loads animation set 1. Animates one frame (#1D). Clears $0002 player_flags. Checks joypad for EW → `func_02C1BE`, NS → `func_02C1D0`. If neither, abort. |
| `func_02C1BE` | `PsychoSliderDirEW` | $02C1BE | 18 B | Code | Horizontal launch: checks $0200 (left) vs $0100 (right) → stages player sprite #02 or #03. |
| `func_02C1D0` | `PsychoSliderDirNS` | $02C1D0 | 20 B | Code | Vertical launch: checks $0800 (up) vs $0400 (down) → stages sprite #00 or #01. |
| `code_02C1E4` | `PsychoSliderAbort` | $02C1E4 | 7 B | Code | Clears $0200, restores saved pointer. |
| `sub_02C1EB` | `PsychoSliderChargeTick` | $02C1EB | 49 B | Code | Per-frame charge handler: alternating frames check L or R shoulder button ($0020/$0010). If pressed, decrements charge counter $26. Also merges shoulder bits into joypad mask $0658. |
| `sub_02C21C` | `KillSpawnedProjectile` | $02C21C | 19 B | Code | Reads stored actor ID from `$7F0012,X`. If non-zero, sets direct page + calls `COP [MarkDeath]` to kill the projectile child. |

#### Subgroup 18I: Guided Projectile Actor ($02C232–$02C38C)

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `func_02C232` | `GuidedProjectileActor` | $02C232 | 214 B | Code | Sprite priority #30. Computes offset from player. Uses spritemap `table_0EE000`. Main loop: checks 4 joypad directions → stages appropriate sprite (#39 neutral, #3D right, #3C left, #3B up, #3A down). Enables hitbox per direction. On animation frame complete + joypad change → redirect. Calls `sub_02C329` to recompute position. |
| `code_02C288` | `ProjectileMoveRight` | $02C288 | 32 B | Code | Right-facing projectile: sprite #3D, loops until button released. |
| `code_02C2A8` | `ProjectileMoveLeft` | $02C2A8 | 32 B | Code | Left: sprite #3C. |
| `code_02C2C8` | `ProjectileMoveUp` | $02C2C8 | 32 B | Code | Up: sprite #3B. |
| `code_02C2E8` | `ProjectileMoveDown` | $02C2E8 | 32 B | Code | Down: sprite #3A. |
| `func_02C308` | `WillAttackPaletteFX` | $02C308 | 13 B | Code | Will's attack palette FX: loop palettes #2A (×2), then #2B infinite. |
| `func_02C315` | `FreedanAttackPaletteFX` | $02C315 | 13 B | Code | Freedan: loop #4B (×2), then #2C infinite. |
| `func_02C322` | `AuraBarrierPaletteFX` | $02C322 | 7 B | Code | Aura: loop #5B infinite. |
| `sub_02C329` | `RecomputeProjectilePos` | $02C329 | 21 B | Code | Adds stored offset deltas ($7F100C/100E,X) to current player position → updates $14/$16. |
| `sub_02C33E` | `LoadAbilityAnimTableA` | $02C33E | 39 B | Code | Reads animation table A (`table_01D9A7`) by index. Stores animation limit to `$09E0`. |
| `sub_02C365` | `LoadAbilityAnimTableB` | $02C365 | 39 B | Code | Reads animation table B (`table_01D9BF`) by index. Stores to `$09E2`. |

---

### Group 19: Player Character State Machine ($02C38C–$02CFD0)

**File:** `extracted/actors/player_character.asm`
**Purpose:** The master actor definition for the playable character. Manages the
complete idle/walk/run/attack/climb/swim state machine, animation dispatch, and
directional input processing.

#### Subgroup 19A: Actor Definition & Initialization

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `player_character` | `PlayerCharacterDef` | $02C38C | 60 B | actor_def | Actor definition header (type $00, priority $08, flags $85). Init code: sets $0100 (visible) + $0001 (active). Stores X to `$player_actor`. Sets $7F101C=1. If `$0AF8` (death flag), spawns `DeathWakeupMessage`. Spawns 4 companion actors: attack system, movement controller, slope physics, palette FX. |

#### Subgroup 19B: Idle State Machine

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `code_02C3C8` | `PlayerIdleEntry` | $02C3C8 | 61 B | Code | Main idle state. Clears joypad directional mask from $0658. Clears $2800 player_flags. Sets $0100 (visible), clears $0020. Zeroes `$09E0` (ability anim counter). If $2000 in $10 set (special lock), return. Else: sets saved pointer to self, clears force-move. Checks speed: if EW → walking, if NS → walking. Otherwise → directional idle dispatch. |
| `code_list_02C447` | `PlayerIdleDispatchTable` | $02C447 | 56 B | &Code | 28-entry table (7 per facing direction × 4 directions). For each facing: [attack, idle_right, idle_left, idle_south, idle_north, idle_run_start, idle_stand, ...]. Selected by combining facing direction ($24) with joypad/action button state. |

#### Subgroup 19C: Standing Idle Animations

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `code_02C47F` | `IdleStandSouth` | $02C47F | 16 B | Code | South-facing idle. Checks flag byte 0 for Shadow variant → sprite #00 or #10. |
| `code_02C48A` | `IdleStandSouthShadow` | $02C48A | 5 B | Code | Shadow variant: sprite #10. |
| `code_02C48F` | `IdleStandNorth` | $02C48F | 16 B | Code | North: sprite #01 / #11 (Shadow). |
| `code_02C49A` | `IdleStandNorthShadow` | $02C49A | 5 B | Code | Shadow: #11. |
| `code_02C49F` | `IdleStandWest` | $02C49F | 16 B | Code | West: sprite #02 / #12. |
| `code_02C4AA` | `IdleStandWestShadow` | $02C4AA | 5 B | Code | Shadow: #12. |
| `code_02C4AF` | `IdleStandEast` | $02C4AF | 16 B | Code | East: sprite #03 / #13. |
| `code_02C4BA` | `IdleStandEastShadow` | $02C4BA | 15 B | Code | Shadow: #13. Shared idle animation loop: animate frame, check for button press or movement → restore saved pointer. |

#### Subgroup 19D: Walking Animations

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `code_02C4DD` | `WalkSouth` | $02C4DD | 71 B | Code | Walking south. Sets `$040C` (auto-walk timer) if facing == current. Sprite #08. On direction released → stop. Checks L/R for attack → `code_02CA28`. |
| `code_02C524` | `WalkNorth` | $02C524 | 72 B | Code | Walking north. Same pattern with sprite #09. |
| `code_02C56C` | `WalkWest` | $02C56C | 73 B | Code | Walking west. Sprite #0A. |
| `code_02C5B5` | `WalkEast` | $02C5B5 | 74 B | Code | Walking east. Sprite #0B. |
| `code_02C5FF` | `CheckAttackWhileWalking` | $02C5FF | 21 B | Code | Checks for attack button ($8000) or movement cessation. Checks slope flag ($1000). Returns zero flag for continue/stop decision. |
| `code_02C614` | `WalkAbortToIdle` | $02C614 | 1 B | Code | PLA (drops return address). |
| `code_02C615` | `WalkRestoreSaved` | $02C615 | 2 B | Code | `COP [RestoreSavedPtr]` — returns to idle. |
| `code_02C617` | `SetAutoWalkTimer` | $02C617 | 7 B | Code | Sets `$040C = $000D` (13-frame auto-walk timer for momentum). |

#### Subgroup 19E: Vine/Rope Climbing ($02C61E–$02C6FA)

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `code_02C61E` | `ClimbVineEntry` | $02C61E | 116 B | Code | Clears $0008, sets $0200 (special state). Blocks joypad $4000. Entry animation: sprites #18→#19. Main loop: checks `BranchIfSolidType` for ground contact → `code_02C692` (land). 3-phase climbing cycle: sprites #1A→#1B→#19, each with force-move Y +7 (downward). |
| `code_02C692` | `ClimbVineLand` | $02C692 | 28 B | Code | Landing from vine: plays sound #2C, sprite #1C. Clears $0200, sets $0008, unblocks $4000 joypad. Returns to idle. |
| `code_02C6AE` | `CheckClimbFrame` | $02C6AE | 14 B | Code | Animation frame check: returns carry clear if animation frame complete (sets $24 = frame time), carry set if still animating. |
| `code_02C6BC` | `CheckClimbAttack` | $02C6BC | 25 B | Code | While climbing: if `$0AD4==1` (Freedan) and ability $0040 (Earthquaker), checks attack button → `code_02C6D5` (drop attack). |
| `code_02C6D5` | `ClimbDropAttack` | $02C6D5 | 37 B | Code | Freedan's drop-attack from vine: set body sprite #06, hitbox #00. Falls with force-move Y +7 each frame. Checks for ground contact with tile alignment. |
| `code_02C6FA` | `ClimbDropLand` | $02C6FA | 69 B | Code | Drop-attack landing: loads animation table 2 from `table_01D9BF`. Scene $DD special: spawns `code_02C73F` (impact shake). Spawns camera shake (`code_02C751`). Landing animation: sprite #01 move Y. Wait 39 frames. Returns to idle. |

#### Subgroup 19F: Landing Effects ($02C73F–$02C7B6)

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `code_02C73F` | `ImpactTerrainShake` | $02C73F | 18 B | Code | Sets player_flags $0010 (terrain shake). Waits $01DF frames. Clears flag. Dies. |
| `code_02C751` | `CameraShakeActor` | $02C751 | 13 B | Code | Plays sound #15. Calls `code_02C75E` per frame. Decrements counter $26 → dies. |
| `code_02C75E` | `CameraShakeFrame` | $02C75E | 88 B | Code | Applies random camera offset: if display flag $0200 not set, adds ±1 random delta to camera positions `$06BE`/`$06C2` each frame. If $0200 set (restore mode), restores original positions from `$7F100C/100E,X`. |

#### Subgroup 19G: Ladder Climbing ($02C7B6–$02C8AA)

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `code_02C7B6` | `LadderClimbSouth` | $02C7B6 | 44 B | Code | South-facing ladder. Clears $0028, sets $0100+$0800. Blocks joypad $CFF0. Entry animation: sprite #26 with XY move. Checks for up/down input → climb or idle. |
| `code_02C7E2` | `LadderClimbNorth` | $02C7E2 | 43 B | Code | North-facing ladder entry. Same pattern, sprite #28. |
| `code_02C80D` | `LadderMoveDown` | $02C80D | 36 B | Code | Moving down: sprite #2D, force-move Y +29. Checks tile alignment + `BranchIfSolidTypeSouth` → land (`code_02C897`). |
| `code_02C831` | `LadderMoveUp` | $02C831 | 36 B | Code | Moving up: sprite #2C, force-move Y −30. Checks `BranchIfSolidTypeNorth` → top (`code_02C8AA`). |
| `code_02C855` | `LadderIdleSouth` | $02C855 | 16 B | Code | Idle on ladder facing south: sprite #2B / #2F (Shadow). |
| `code_02C860` | `LadderIdleSouthShadow` | $02C860 | 5 B | Code | Shadow: #2F. |
| `code_02C865` | `LadderIdleNorth` | $02C865 | 11 B | Code | Idle facing north: sprite #2A / #2E (Shadow). |
| `code_02C870` | `LadderIdleNorthShadow` | $02C870 | 3 B | Code | Shadow: #2E. Idle animation loop checks for up/down input. |
| `code_02C897` | `LadderLandBottom` | $02C897 | 19 B | Code | Landing at bottom: sprite #29 move Y. Unblocks joypad $CFF0. Sets $0008. Restores saved pointer. |
| `code_02C8AA` | `LadderReachTop` | $02C8AA | 19 B | Code | Reaching top: sprite #27 move Y. Unblocks $CFF0. Sets $0008. Restores. |

#### Subgroup 19H: Horizontal Traversal — Wall Shimmy ($02C8BD–$02CA19)

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `loc_02C8BD` | `ShimmyRightEntry` | $02C8BD | 23 B | Code | Right-facing shimmy. Clears $0028, sets $0100+$0800. Blocks $CFF0. Sprite #33, force-move X $51 (right). |
| `code_02C8D4` | `ShimmyRightCheckWall` | $02C8D4 | 24 B | Code | Checks tile X+8 alignment, probes east for solid ($07 or $00) → detach (`code_02C9B7`). |
| `code_02C8EC` | `ShimmyRightLoop` | $02C8EC | 47 B | Code | Main shimmy-right loop: force-move, check ground below, check up/down buttons → redirect to `code_02C92D`/`code_02C934`. Check east wall → detach. |
| `loc_02C93B` | `ShimmyLeftEntry` | $02C93B | 23 B | Code | Left-facing shimmy. Same setup, sprite #32, force-move X $52. |
| `code_02C952` | `ShimmyLeftCheckWall` | $02C952 | 23 B | Code | Checks west for solid → detach (`code_02C9CA`). |
| `code_02C969` | `ShimmyLeftLoop` | $02C969 | 46 B | Code | Main shimmy-left loop. |
| `code_02C92D` | `ShimmyRightUpCheck` | $02C92D | 7 B | Code | While shimmying right: probe north → corner, else continue. |
| `code_02C934` | `ShimmyRightDownCheck` | $02C934 | 7 B | Code | Probe south → corner. |
| `code_02C9A9` | `ShimmyLeftUpCheck` | $02C9A9 | 7 B | Code | Left: probe north. |
| `code_02C9B0` | `ShimmyLeftDownCheck` | $02C9B0 | 7 B | Code | Left: probe south. |
| `code_02C9B7` | `ShimmyDetachRight` | $02C9B7 | 19 B | Code | Detach from right wall: clear force-move. Sprite #31 / #35 (Shadow). |
| `code_02C9C5` | `ShimmyDetachRightShadow` | $02C9C5 | 5 B | Code | Shadow: #35. |
| `code_02C9CA` | `ShimmyDetachLeft` | $02C9CA | 14 B | Code | Detach from left wall: sprite #30 / #34 (Shadow). |
| `code_02C9D8` | `ShimmyDetachLeftShadow` | $02C9D8 | 3 B | Code | Shadow: #34. Shared idle-on-wall loop: checks up/down, left/right buttons for re-engage. |
| `code_02CA19` | `ShimmyTopCorner` | $02CA19 | 9 B | Code | Reached corner: clear $2C, set $0008. Restore saved pointer. |

#### Subgroup 19I: Running / Attack-from-Walk ($02CA22–$02CB0C)

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `code_02CA22` | `AttackFromWalkSouth` | $02CA22 | 6 B | Code | Merges $0400 into joypad mask. Falls through. |
| `code_02CA28` | `RunSouth` | $02CA28 | 14 B | Code | Running south: clears $040C, stages sprite #3A. |
| `code_02CA30` | `AttackFromWalkNorth` | $02CA30 | 6 B | Code | Merges $0800. |
| `code_02CA36` | `RunNorth` | $02CA36 | 14 B | Code | Running north: sprite #3B. |
| `code_02CA3E` | `AttackFromWalkWest` | $02CA3E | 6 B | Code | Merges $0200. |
| `code_02CA44` | `RunWest` | $02CA44 | 14 B | Code | Running west: sprite #3C. |
| `code_02CA4C` | `AttackFromWalkEast` | $02CA4C | 6 B | Code | Merges $0100. |
| `code_02CA52` | `RunEast` | $02CA52 | 42 B | Code | Running east: sprite #3D. Sets $2000 player_flags, $0020 in $10, clears $0100. Loops: animate, check for L/R release → `code_02CA82` (stop running). |
| `code_02CA82` | `RunStopToIdle` | $02CA82 | 2 B | Code | `COP [RestoreSavedPtr]`. |

#### Subgroup 19J: Moving East/West Animations ($02CA84–$02CB0C)

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `code_02CA84` | `MovingEastWest` | $02CA84 | 136 B | Code | East-west walking with full animation and state machine. Checks joypad for left/right, uses current speed sign for default direction. Sprite #0F (right) / #0E (left). Checks attack button ($8000) → run attack entries (`code_02CE5A` / `code_02CDDC`). Checks L/R for running (`code_02CA4C` / `code_02CA3E`). When speed reaches zero → restore to idle. |
| `code_02CB0C` | `MovingNorthSouth` | $02CB0C | 136 B | Code | Same for north-south. Sprite #0D (north) / #0C (south). Attack triggers: `code_02CD5B` / `code_02CCDA`. Running: `code_02CA30` / `code_02CA22`. |

#### Subgroup 19K: Running Attack Check ($02CB92–$02CBFD)

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `code_02CB92` | `CheckRunAttack` | $02CB92 | 35 B | Code | Checks conditions for running attack: not flagged $0080 (hitstun), `$0AD4 == 0` (Will only), has ability $0002 (run attack), not on slope. If attack button pressed → branch to running attack. |
| `code_02CBB5` | `RunAttackSpeedCheck` | $02CBB5 | 36 B | Code | Checks |speed| >= 3 on primary axis → full running attack. Checks secondary axis → charging attack (`code_02CBFF` / `code_02CC52`). Below threshold: cancel. |
| `code_02CBD9` | `SpeedThresholdEW` | $02CBD9 | 11 B | Code | Checks |EW speed| >= 4, else tests slope flag. Returns carry = blocked. |
| `code_02CBE4` | `SpeedThresholdNS` | $02CBE4 | 25 B | Code | Same for NS. |

#### Subgroup 19L: Running Attacks ($02CBFF–$02CCA5)

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `code_02CBFF` | `RunAttackNS` | $02CBFF | 83 B | Code | North-south running attack. Loads animation set 1 from `table_01D9A7`. Sets body sprite #04. If NS speed positive (going south): `code_02CCB0` setup, sprite #0C → loop with move Y → #0E finish. If negative (north): force NE, sprite #0F → loop → #11. Calls `code_02CCC8` to clean up. |
| `code_02CC52` | `RunAttackEW` | $02CC52 | 83 B | Code | East-west running attack. Speed positive (east): sprite #15 → loop with move X → #17. Speed negative (west): force SW, sprite #12 → loop → #14. |
| `code_02CCA5` | `DisableStatusForAttack` | $02CCA5 | 11 B | Code | Clears $0100, sets $0200 in display flags $06EE. Used to hide status indicators during attacks. |
| `code_02CCB0` | `RunAttackFlagSetup` | $02CCB0 | 18 B | Code | Sets $0200 (attack active) in $10, $8000 in $0658 (block joypad), $0802 in player_flags (attack+combo). |
| `code_02CCC2` | `RestoreStatusDisplay` | $02CCC2 | 6 B | Code | Clears $0200 from $06EE (re-enable status). |
| `code_02CCC8` | `RunAttackCleanup` | $02CCC8 | 18 B | Code | Clears $0200, $8000 from joypad mask, clears $0002 from player_flags. |

#### Subgroup 19M: Directional Attacks ($02CCDA–$02CEEE)

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `code_02CCDA` | `AttackSouth` | $02CCDA | 129 B | Code | South-facing attack. Calls `code_02CEEE` (init). Sets joypad mask $0400. Freedan: checks ground tile for wall-slash variant → sprite #48, else #36. Scene $E8 special: spawns projectile `code_02CF68`. Two-phase animation: charge (#SetEntryContinue → #AnimOneFrame → #SetEntryExit), then active (checks directional input for combo / ranged launch). |
| `code_02CD5B` | `AttackNorth` | $02CD5B | 129 B | Code | North: joypad $0800. Sprite #49/#37. Scene $E8: `code_02CF82`. |
| `code_02CDDC` | `AttackWest` | $02CDDC | 126 B | Code | West: joypad $0200. Checks `$0AD4 != 2` for wall-hit sprite #42, else #38. Scene $E8: `code_02CF9C`. |
| `code_02CE5A` | `AttackEast` | $02CE5A | 126 B | Code | East: joypad $0100. Sprite #43/#39. Scene $E8: `code_02CFB6`. |
| `code_02CED8` | `AttackRedirect` | $02CED8 | 14 B | Code | During attack: if joypad $0F00 (any direction pressed), clears $8000 from joypad mask (allow movement). |
| `code_02CEE6` | `AttackFinish` | $02CEE6 | 8 B | Code | Clears $0F00 from joypad mask. Restores saved pointer (idle). |
| `code_02CEEE` | `AttackInit` | $02CEEE | 33 B | Code | Masks joypad to direction only ($0F00). Sets $8000. Clears $0100. If `$0AD4 != 0`: play sound #02 (weapon swing). Else: #01 (punch). |

#### Subgroup 19N: Ranged Weapon Launch ($02CF0F–$02CF67)

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `code_02CF0F` | `RangedAttackSouth` | $02CF0F | 10 B | Code | Calls `code_02CF4F` (Y force-move). Sprite #44. |
| `code_02CF19` | `RangedAttackNorth` | $02CF19 | 15 B | Code | Calls `code_02CF4F`. Sets $2000 in $12 (flip). Sprite #45. |
| `code_02CF28` | `RangedAttackWest` | $02CF28 | 15 B | Code | Calls `code_02CF4A` (X force-move). Sets $4000 in $12 (mirror). Sprite #46. |
| `code_02CF37` | `RangedAttackEast` | $02CF37 | 13 B | Code | Calls `code_02CF4A`. Sprite #47. |
| `code_02CF4A` | `RangedSetForceX` | $02CF4A | 5 B | Code | `COP [StageForceMoveX]` ($46 = 70 pixels). |
| `code_02CF4F` | `RangedSetForceY` | $02CF4F | 18 B | Code | `COP [StageForceMoveY]` ($46). Sets $0800 player_flags, `$09E0 = 1`, $0200 in $10. Enables hitbox ($0040). |

#### Subgroup 19O: Ranged Weapon Projectile Sprites ($02CF68–$02CFD0)

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `code_02CF68` | `ProjectileSouth` | $02CF68 | 26 B | Code | South projectile: spritemap `table_17D000`. Moves Y with sprite #00→#04 loop. Dies when $4000 set. |
| `code_02CF82` | `ProjectileNorth` | $02CF82 | 26 B | Code | North: sprites #01→#05. |
| `code_02CF9C` | `ProjectileWest` | $02CF9C | 26 B | Code | West: sprites #02→#06 (X-axis). |
| `code_02CFB6` | `ProjectileEast` | $02CFB6 | 26 B | Code | East: sprites #03→#07. |

---

### Group 20: Inventory Menu System ($02E396–$02ED02)

**File:** `extracted/system/inventory/inventory_menu.asm`
**Purpose:** Complete in-game inventory menu with 4 tabs: Use, Arrange, Discard,
and Status. Manages 16 item slots, equipment, and character-specific displays.

#### Subgroup 20A: Initialization & Main Loop

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `inventory_menu` | `InventoryMenuDef` | $02E396 | 3 B | actor_def | Actor definition: type $00, priority $00, flags $28. |
| `code_02E399` | `InventoryMenuInit` | $02E399 | 115 B | Code | Sets spritemap. Runs BG3 script for background text. Spawns 16 item slot actors (`code_02E8C7`), each assigned an item from `inventory_slots`. Spawns cursor actor (`code_02E8E7`), equipped-item display (`code_02E8FF`), and 3 character stat rows (`code_02E953`/`code_02E934`/`code_02E915`). Enters main tab dispatch loop. |
| `code_02E40C` | `InventoryMainLoop` | $02E40C | 57 B | Code | Runs BG3 scripts for header/footer. Resets state. Calls `code_02EC58` (tab selection input). On confirm: dispatches to tab handler via `code_list_02E43D`. |
| `code_list_02E43D` | `TabHoverDispatch` | $02E43D | 8 B | &Code | Hover state table: [Use, Arrange, Discard, Status]. |
| `loc_02E445` | `TabConfirmDispatch` | $02E445 | 25 B | Code | Plays sound #0D. Gets current tab → dispatches via `code_list_02E456`. |
| `code_list_02E456` | `TabActionDispatch` | $02E456 | 8 B | &Code | Active tab table: [UseItem, ArrangeItems, DiscardItem, StatusView]. |

#### Subgroup 20B: Use Item Tab

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `code_02E45E` | `UseItemTab` | $02E45E | 129 B | Code | Sets `$0AE6 = 4`. Draws "USE" header. Clears equipped index display. Enters item selection with cursor. Shows item name at `$0AE8`. Handles 4-direction cursor navigation (up/down/left/right in 4×4 grid, wrapping with AND $0F). |
| `code_02E4B8` | `UseItemCursorUp` | $02E4B8 | 22 B | Code | Move cursor up (−4, wrap). Plays sound #10. |
| `code_02E4CE` | `UseItemCursorDown` | $02E4CE | 22 B | Code | Move cursor down (+4, wrap). |
| `code_02E4E4` | `UseItemCursorLeft` | $02E4E4 | 19 B | Code | Move cursor left (−1, wrap). |
| `code_02E4F7` | `UseItemCursorRight` | $02E4F7 | 20 B | Code | Move cursor right (+1, wrap). |
| `code_02E50B` | `UseItemConfirm` | $02E50B | 43 B | Code | On confirm: reads item at cursor. If empty → clears equipped. If valid → sets `inventory_equipped_index` and `inventory_equipped_type`. Returns to main loop. |

#### Subgroup 20C: Arrange Items Tab

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `code_02E536` | `ArrangeItemsTab` | $02E536 | 77 B | Code | Shows "ARRANGE" header. Spawns source-cursor actor (`code_02E8F1`). First pick: navigate 4×4 grid to select source item. |
| `code_02E583` | `ArrangePickTarget` | $02E583 | 87 B | Code | Second pick: shows "SWAP" prompt. Navigate to select target slot. On confirm → `code_02E5DA` (perform swap). |
| `code_02E5DA` | `ArrangePerformSwap` | $02E5DA | 112 B | Code | Byte-swaps two inventory slots (SEP #$20 for 8-bit swap). Updates slot actor sprites. Fixes `inventory_equipped_index` if swapped item was equipped. Kills source cursor, restarts. |
| `code_02E64A` | `ArrangeCancelTarget` | $02E64A | 2 B | Code | Kills cursor on cancel. |
| `code_02E64C` | `ArrangeCancelTab` | $02E64C | 11 B | Code | Kills cursor, returns to main loop. |

#### Subgroup 20D: Discard Item Tab

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `code_02E657` | `DiscardItemTab` | $02E657 | 180 B | Code | "DISCARD" header. Navigation cursor. On confirm: reads item, validates non-empty. Checks if item is discardable via `code_02EA13` (bit array check against `binary_01E12A`). Shows "DISCARD?" yes/no prompt (`code_02EBC6`). If yes: zeros slot, updates sprites, fixes equipped index, plays sound #13. If no or blocked: plays #12 (error). |
| `code_02E70B` | `DiscardCancelTab` | $02E70B | 14 B | Code | Cancel: kills cursor, refreshes display, returns to main loop. |

#### Subgroup 20E: Status View Tab

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `code_02E719` | `StatusViewTab` | $02E719 | 138 B | Code | Shows character status info. Displays 3 rows (one per ability tier for current form). For each: checks `$0AD4` and calls `code_02E9DC` (test game flag). If ability unlocked, shows ability name via `code_02E972`. Up/down navigation between rows. |
| `code_02E768` | `StatusCursorUp` | $02E768 | 21 B | Code | Move status cursor up (wraps at 3). |
| `code_02E77D` | `StatusCursorDown` | $02E77D | 20 B | Code | Move down (wraps at 3). |
| `code_02E795` | `StatusConfirmExit` | $02E795 | 14 B | Code | Exit status view: kills cursor, returns to main loop. |
| `code_02E7A3` | `StatusPositionCursor` | $02E7A3 | 24 B | Code | Positions status cursor actor using `unk10_02E7BB` lookup table. |
| `unk10_02E7BB` | `StatusCursorPositions` | $02E7BB | 12 B | unk10 | 3 cursor positions: ($98,$48), ($98,$60), ($98,$78). |

#### Subgroup 20F: Tab Hover Display Updates

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `code_02E7C7` | `TabHoverUse` | $02E7C7 | 31 B | Code | Hover on Use: hides item grid icons, refreshes equipped display, shows item list + description + hint. Sets `$0AE6 = 4`. |
| `code_02E7E6` | `TabHoverArrange` | $02E7E6 | 17 B | Code | Hover on Arrange: refreshes equipped, shows grid. |
| `code_02E7F7` | `TabHoverDiscard` | $02E7F7 | 31 B | Code | Hover on Discard: hides icons, shows item list + description. Sets `$0AE6 = 4`. |
| `code_02E816` | `TabHoverStatus` | $02E816 | 177 B | Code | Hover on Status: shows all item grid icons. Shows equipped-item sprite. Checks each ability flag and displays unlock text. Complex: iterates through 3 ability slots, tests flags via `code_02E9DC`, displays names. |

#### Subgroup 20G: Slot Actors & Cursor

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `code_02E8C7` | `InventorySlotActor` | $02E8C7 | 32 B | Code | Individual item slot sprite. Increments `$0AFA` for sequential positioning via `code_02EB70`. If $28 (item type) is non-zero: animate visible. If zero: hide ($2000 TSB). |
| `code_02E8E7` | `EquipCursorActor` | $02E8E7 | 24 B | Code | Equipment cursor: shows at equipped index position if valid, else hides. Animates with hitbox #40. |
| `code_02E8F1` | `SelectionCursorActor` | $02E8F1 | 14 B | Code | Generic selection cursor: hitbox #40 with animation loop. |
| `code_02E8FF` | `EquippedItemDisplay` | $02E8FF | 16 B | Code | Shows equipped item sprite at position ($28, $78). |
| `code_02E915` | `StatusCharRow3` | $02E915 | 31 B | Code | Third ability row display. Position ($98, $48). Sprite computed from `$0AD4 * 3 + $44`. |
| `code_02E934` | `StatusCharRow2` | $02E934 | 31 B | Code | Second row. Position ($98, $60). Sprite `$0AD4 * 3 + $45`. |
| `code_02E953` | `StatusCharRow1` | $02E953 | 31 B | Code | First row. Position ($98, $78). Sprite `$0AD4 * 3 + $46`. |

#### Subgroup 20H: Grid Navigation Subroutines

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `code_02E972` | `ComputeAbilityIndex` | $02E972 | 15 B | Code | Converts ability slot + character form to `$0AE8` index for string lookup. |
| `code_02E981` | `GridCursorUp` | $02E981 | 21 B | Code | Grid cursor up: `$22 -= 4 & $0F`. Plays #10. |
| `code_02E996` | `GridCursorDown` | $02E996 | 21 B | Code | Down: `$22 += 4 & $0F`. |
| `code_02E9AB` | `GridCursorLeft` | $02E9AB | 17 B | Code | Left: `$22 -= 1 & $0F`. |
| `code_02E9BD` | `GridCursorRight` | $02E9BD | 17 B | Code | Right: `$22 += 1 & $0F`. |
| `code_02E9CF` | `SetSlotSprite` | $02E9CF | 11 B | Code | Writes item type to slot actor $0028 and clears animation state. |
| `code_02E9DC` | `TestAbilityFlag` | $02E9DC | 17 B | Code | Tests game flag for ability unlock. Computes flag index from `$0AD4 * 4 + slot`. Calls `TestFlag_0510`. |
| `code_02E9ED` | `UpdateSlotActorSprite` | $02E9ED | 35 B | Code | Navigates actor linked list from `$7F0010,X` to find slot #$000E, resets its function pointer and sprite. |
| `code_02EA13` | `CheckItemDiscardable` | $02EA13 | 34 B | Code | Tests item ID against bit array at `binary_01E12A`. Returns carry set = discardable. Uses `byte_02EA35` bitmask table. |
| `byte_02EA35` | `BitMaskTable` | $02EA35 | 8 B | Byte | Bitmasks: [01, 02, 04, 08, 10, 20, 40, 80]. |

#### Subgroup 20I: Cursor Positioning

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `code_02EA3D` | `PositionGridCursor` | $02EA3D | 54 B | Code | Computes cursor position from slot index $22. Column = `($22 & 3) * 4`, row = `$22 & $30`. Looks up pixel coordinates from `unk10_02EAB0`. |
| `code_02EA73` | `PositionEquipCursor` | $02EA73 | 46 B | Code | Positions equip cursor at equipped slot. If index is −1 (nothing equipped), hides cursor. |
| `unk10_02EAB0` | `GridColumnPositions` | $02EAB0 | 16 B | unk10 | 4 column X/Y base positions: ($5C,$30), ($74,$30), ($8C,$30), ($A4,$30). |

#### Subgroup 20J: Item Grid Visibility Management

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `code_02EAC0` | `HideStatusActors` | $02EAC0 | 55 B | Code | Hides equipped item display + all 4 status row actors by OR'ing $2000 into their flags. |
| `code_02EAF7` | `ShowEquipCursor` | $02EAF7 | 20 B | Code | If equipped index valid: shows equip cursor (AND $DFFF). |
| `code_02EB0B` | `HideEquipCursor` | $02EB0B | 15 B | Code | Hides equip cursor (OR $2000). |
| `code_02EB1A` | `HideAllItemSlots` | $02EB1A | 43 B | Code | If not already hidden ($1000 test): hides all 16 slot actors by walking linked list and OR'ing $2000. Sets $1000 marker. |
| `code_02EB45` | `ShowAllItemSlots` | $02EB45 | 32 B | Code | Inverse: shows all 16 slot actors (AND $DFFF). Clears $1000. |
| `code_02EB70` | `ComputeSlotPosition` | $02EB70 | 22 B | Code | Computes slot actor position from `$0AFA` (sequential counter). Looks up in `unk10_02EB86`. |
| `unk10_02EB86` | `SlotPositionTable` | $02EB86 | 64 B | unk10 | 16 slot pixel positions in 4×4 grid: row 0 at Y=$31, row 1 at $41, row 2 at $51, row 3 at $61. X columns: $5C, $74, $8C, $A4. |

#### Subgroup 20K: Yes/No Prompt & Tab Selection

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `code_02EBC6` | `YesNoPromptLoop` | $02EBC6 | 44 B | Code | Yes/No confirmation dialog. Checks joypad: confirm ($8000) → accept. Up/Down → toggle selection. Blink cursor every 16 frames alternating `code_02EC2D`/`code_02EC46`. Returns carry set on confirm. |
| `code_02EBF2` | `YesNoSelectUp` | $02EBF2 | 24 B | Code | Toggle up: `$28 = ($28 - 1) & 1`. Sound #10. |
| `code_02EC0A` | `YesNoSelectDown` | $02EC0A | 24 B | Code | Toggle down. |
| `code_02EC22` | `YesNoConfirm` | $02EC22 | 11 B | Code | Confirm: redraw cursor, return carry set. |
| `code_02EC2D` | `YesNoDrawCursor` | $02EC2D | 25 B | Code | Draws yes/no selection cursor: writes $202B tile to VRAM buffer at computed position (row based on $28). |
| `code_02EC46` | `YesNoClearCursor` | $02EC46 | 18 B | Code | Clears cursor: writes $2040 (blank) to both row positions in VRAM. |
| `code_02EC58` | `TabSelectionLoop` | $02EC58 | 50 B | Code | Main tab selection input: 4-way cursor on tab bar. Confirm/cancel/up/down. Blink cursor. `$0AFA` = current tab index (0–3). |
| `code_02EC8A` | `TabSelectUp` | $02EC8A | 26 B | Code | Tab up: `$0AFA = ($0AFA - 1) & 3`. |
| `code_02ECA4` | `TabSelectDown` | $02ECA4 | 26 B | Code | Tab down: `$0AFA = ($0AFA + 1) & 3`. |
| `code_02ECBE` | `TabCancel` | $02ECBE | 5 B | Code | `COP [SetFlagByte]` (#00) — closes inventory. |
| `code_02ECC3` | `TabConfirm` | $02ECC3 | 11 B | Code | Merges $8000, redraws, returns carry set. |
| `code_02ECCE` | `TabDrawCursor` | $02ECCE | 26 B | Code | Draws tab cursor: $202B at VRAM offset `$0584 + ($0AFA * $100)`. |
| `code_02ECE8` | `TabClearCursor` | $02ECE8 | 26 B | Code | Clears all 4 tab cursor positions with $2040. |

---

### Group 21: Inventory Screen Overlay ($02ED02–$02F048)

**File:** `extracted/functions/func_02ED02.asm`
**Purpose:** Opens the inventory as a full-screen overlay. Saves all game state
(VRAM, WRAM, registers, camera), runs the inventory scene, then restores
everything exactly.

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `func_02ED02` | `OpenInventoryScreen` | $02ED02 | 389 B | Code | Master inventory orchestrator. Saves processor flags. Enables NMI+display. Calls `code_02EF1D` (save state). Stores scene, joypad masks, display flags. Sets scene to $FF (inventory). Configures BG3 for text overlay. Runs scene script (no music). Configures BG1/BG2 nametable addresses. Initializes palette, camera, map bounds to zero. Calls multiple engine functions: `func_03DFA0`, `UploadCgramPalette`, `code_02F076`, `func_03CDDC`, `func_03CEA1`, `func_03D7E7`. Runs actors twice. Enters main inventory loop (`code_02EE17`). On exit: restores scene, re-runs scene script, applies event blocks, places barriers, refreshes display. Clears all joypad masks. Runs BG3 clear script. Renders 2 frames. Restores display brightness. |
| `code_02EECC` | `ReloadAbilityFX` | $02EECC | 63 B | Code | After inventory closes: checks `$00EA` for active ability. If 1: reloads Dark Friar FX tiles + palette. If 2: reloads Aura FX tiles + palette. Ensures ability visuals survive the inventory overlay. |
| `code_02EF0B` | `DrainActorQueue` | $02EF0B | 15 B | Code | Walks actor linked list from `$5A`. For each: clears frame counter $08, follows $06 chain until null. Ensures all spawned actors are in clean state. |
| `code_02EF1D` | `SaveGameState` | $02EF1D | 149 B | Code | Saves joypad state ($0656/$0658), joypad mask, repeat timer, direct-page variables ($4E–$5D), camera positions ($06BE–$06C9). Block-copies: $0E00→$7E:3490 (256B), $7E:3000→self (256B), $1000→$7F:E000 (4KB), $7F:1000→self (4KB), $0F00→$7E:3690 (256B), $7F:0F00→self (256B), $7F:0A00→$7E:38B4 (515B). |
| `code_02EFB2` | `RestoreGameState` | $02EFB2 | 131 B | Code | Inverse of `SaveGameState`: restores all saved memory regions, joypad state, camera, and direct-page variables. |
| `code_02F035` | `RestorePaletteBuffer` | $02F035 | 19 B | Code | Restores palette buffer: copies $7E:38B4 → $7F:0A00 (515B). |

**State preservation map:**
```
Saved Region          | Size   | Source → Temp Location
─────────────────────────────────────────────────────
Joypad state          | 6 B    | $0656/$0658 → $7E:38AC/38AE
Joypad mask           | 2 B    | $joypad_mask_std → $7E:38B0
Direct-page vars      | 16 B   | $004E–$005D → $7E:389C
Camera positions      | 12 B   | $06BE–$06C9 → $7E:3890
WRAM page $0E00       | 256 B  | $00:0E00 → $7E:3490
WRAM $7E:3000         | 256 B  | → $7E:3000 (self-swap)
WRAM $00:1000         | 4 KB   | → $7F:E000
WRAM $7F:1000         | 4 KB   | → $7F:1000 (self-swap)
WRAM $00:0F00         | 256 B  | → $7E:3690
WRAM $7F:0F00         | 256 B  | → self-swap
Palette buffer        | 515 B  | $7F:0A00 → $7E:38B4
```

---

### Group 22: Dialogue Display Wrapper ($02F048–$02F06A)

**File:** `extracted/functions/func_02F048.asm`

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `func_02F048` | `ShowDialogueFrame` | $02F048 | 34 B | Code | Saves joypad mask, sets DBR to $81, calls `UpdateFrame_Render` + `sub_03E255` (dialogue box update), restores joypad mask. Used as a JSL entry point for any code that needs to display a single dialogue frame with proper rendering. |

---

### Group 23: VRAM Tilemap Buffer Clear ($02F06A–$02F08C)

**File:** `extracted/functions/func_02F06A.asm`

| Old Name | New Name | Hex | Size | Type | Description |
|----------|----------|-----|------|------|-------------|
| `func_02F06A` | `ClearVramBufferPartial` | $02F06A | 12 B | Code | Clears VRAM tilemap buffer from offset $0140 to $0800 with zero words. Entry point for partial clear (preserves first 320 bytes). |
| `code_02F076` | `ClearVramBufferFull` | $02F076 | 22 B | Code | Clears entire VRAM tilemap buffer `$7F:0200`–`$7F:0800` with zero words (2048 bytes = 1024 tile entries). |

---

## 5. Cross-File Call Graph

```
player_character.asm (actor_def)
  ├─ Spawns: actor_02B20E, actor_02B29E, actor_02B42B, actor_02B7B3
  ├─ JSR → JoypadToVelocity, ClampSpeeds, DecelerateEW/NS (in actor_02B42B)
  ├─ JSR → LoadAbilityAnimTableA/B, sub_02C33E/C365 (in actor_02B7B3)
  ├─ JSL → PlayerMovementTick ($02CFD0, analyzed in bank2-code-analysis)
  ├─ JSL → ApplyOrbitalOffsetFromRef (external)
  ├─ JSL → UpdateFrame_Render, UpdateFrame_Dialogue (bank 03)
  └─ COP → extensive use of actor/animation/collision COP commands

actor_02B7B3.asm (attack system)
  ├─ JSR → SetPlayerActorFunc, SavePlayerPosition (internal)
  ├─ JSR → ComputeParentOffset, ApplyParentOffset (in actor_02BDF6)
  ├─ JSR → KillSpawnedProjectile, RecomputeProjectilePos (internal)
  └─ COP → SpawnLastRel, SpawnAfter, SpawnMarkedAfter for projectile/FX actors

actor_02B42B.asm (slope physics)
  ├─ JSR → TileProbeMain, ReadCollisionNibble, MapCellRight/Left/Down
  │         (in tile_collision, analyzed in bank2-code-analysis)
  └─ table_02B57C → dispatches to slope handlers (internal)

inventory_menu.asm
  ├─ JSL → TestFlag_0510 (flag system)
  ├─ JSL → func_03CA55 (actor management)
  └─ COP → RunBg3Script, SpawnAfterFlags, SwitchCase, etc.

func_02ED02.asm (inventory overlay)
  ├─ JSL → EnableNmiOnly, EnableDisplay, VBlankWaitAndJoypad
  ├─ JSL → SceneScriptNoMusic, ApplyAllEventBlocks, PlaceBarrierTiles
  ├─ JSL → UpdateFrame_Render, UpdateFrame_Dialogue
  ├─ JSL → UploadCgramPalette, DmaWordToVram
  ├─ JSL → func_03DFA0, func_03CDDC, func_03CEA1, func_03D7E7
  ├─ JSL → func_03C5FF, func_03C714, func_03DECD, func_03E146
  ├─ JSL → code_02F076 (ClearVramBufferFull)
  └─ MVN → bulk memory transfers for state save/restore
```

---

## 6. Size Distribution

### By functional group:

| Group | Block | Bytes | % of New Analysis |
|-------|-------|-------|-------------------|
| 15: Shadow Shimmer | actor_02B20E | 144 | 0.9% |
| 16: Movement Controller | actor_02B29E | 397 | 2.5% |
| 17: Slope/Ramp Physics | actor_02B42B | 904 | 5.6% |
| 18: Attack/Ability System | actor_02B7B3 + actor_02BDF6 | 3,033 | 18.9% |
| 19: Player Character FSM | player_character | 3,140 | 19.6% |
| 20: Inventory Menu | inventory_menu | 2,412 | 15.1% |
| 21: Inventory Overlay | func_02ED02 | 838 | 5.2% |
| 22: Dialogue Wrapper | func_02F048 | 34 | 0.2% |
| 23: VRAM Buffer Clear | func_02F06A | 34 | 0.2% |
| **Total new** | | **~10,936** | **100%** |

### Combined bank 2 summary:

| Category | Range | Bytes | % of Bank |
|----------|-------|-------|-----------|
| System Engine (Groups 1–14) | $028000–$02B20C | ~12,812 | 39.2% |
| Player Actors (Groups 15–19) | $02B20E–$02CFD0 | ~7,618 | 23.3% |
| Player Movement Physics (A–J) | $02CFD0–$02E395 | ~5,062 | 15.5% |
| Inventory System (Groups 20–21) | $02E396–$02F048 | ~3,250 | 9.9% |
| Utility Functions (Groups 22–23) | $02F048–$02F08C | ~68 | 0.2% |
| **Unmapped / padding** | various gaps | ~3,862 | 11.8% |
| **Bank 2 total (32 KB)** | $028000–$02FFFF | **32,768** | **100%** |

---

## 7. Naming Convention Summary

### Actor naming:
- Entry points: `{Purpose}Entry`, `{Purpose}Init`
- State functions: `{State}Idle`, `{State}Active`, `{State}Loop`
- Dispatchers: `{System}Dispatch`, `{Direction}Dispatch`
- Attack abilities: `{AbilityName}Main`, `{AbilityName}End`
- Direction variants: `{Base}South`, `{Base}North`, `{Base}West`, `{Base}East`
- Sub-actors: `{Parent}Child`, `{Effect}Actor`, `{FX}Spawner`

### Palette effects: `{Context}PaletteFX`, `{Context}PaletteCycle{A/B}`

### Movement: `{Direction}Handler`, `Snap{Axis}{Direction}`, `Decelerate{Axis}`

### Inventory: `{Tab}Tab`, `{Tab}Cursor{Dir}`, `{Tab}Confirm`, `Grid{Action}`

### Utility: `{Action}{Target}` (e.g., `ClearVramBufferFull`, `ShowDialogueFrame`)

---

## 8. Notable Patterns

### 8.1 Five-Actor Player Architecture

The player character uses a modular multi-actor design:
1. **player_character** — state machine (idle/walk/attack/climb)
2. **actor_02B29E** — physics pipeline (joypad → velocity → collision)
3. **actor_02B42B** — terrain physics (slopes, deceleration)
4. **actor_02B7B3** — special abilities (charge, projectiles)
5. **actor_02B20E** — visual effects (palette cycling)

This separation keeps each file focused and avoids a single monolithic actor.
Inter-actor communication uses shared WRAM variables rather than direct calls.

### 8.2 Ability System via $0AD4 + $0AA2

Character form (`$0AD4`: 0=Will, 1=Freedan, 2=Shadow) determines which ability
set is available. The ability bitmask `$0AA2` gates specific moves:

| Bit | Character | Ability |
|-----|-----------|---------|
| $01 | All | Basic attack |
| $02 | Will | Psycho Dash |
| $04 | Will | Psycho Slider |
| $10 | Freedan | Dark Friar |
| $20 | Freedan | Aura Barrier |
| $40 | Shadow | Earthquaker (drop attack from vine) |

### 8.3 Trail Position Queue

Attack trail effects (`actor_02BDF6`) use a 3-frame position queue that
cascades each frame: `current → slot0 → slot1 → slot2 → render`. This creates
smooth trailing without interpolation, using discrete position history.

### 8.4 Speed Curve Tables

Both slope physics and deceleration use the same pattern: a table of signed
16-bit deltas indexed by a frame counter (`AND #$000F` for 16-entry wrap).
The tables are pointed to by `$09BA`/`$09BC` (slope) and `$09C2` (deceleration),
allowing different curves per terrain type.

### 8.5 Inventory State Sandwich

The inventory overlay (`func_02ED02`) uses a complete state save/restore
sandwich: ~5.5 KB of WRAM is preserved using MVN block moves before entering
the inventory scene, then restored byte-for-byte afterward. This allows the
inventory to freely use WRAM without corrupting the overworld state.

### 8.6 Shadow Form Sprite Variants

Standing idle animations have explicit Shadow-form variants (sprites #10–#13
vs #00–#03) selected by `COP [BranchIfFlagByte]` (#00, #01). Shadow also has
ladder idle variants (#2E/#2F) and wall shimmy variants (#34/#35). All other
animations (walking, attacking, climbing) use shared sprites regardless of form.

---

## 9. Applied Name Updates (names.json) ✅

**271 names** from this document have been added to `us/names.json`. This includes
every code/data piece identified in Sections 4 and 5 (Groups 15–23), covering
all sub-functions, dispatch tables, data tables, and helper routines.

Key entry points (subset — full list is in `us/names.json`):

| Address | Hex | Applied Name | Group |
|---------|-----|-------------|-------|
| 176654 | $02B20E | `ShadowShimmerInit` | 15: Shadow Shimmer |
| 176798 | $02B29E | `PlayerMoveController` | 16: Movement Controller |
| 177094 | $02B3C6 | `JoypadToVelocity` | 16: Movement Controller |
| 177195 | $02B42B | `SlopePhysicsEntry` | 17: Slope Physics |
| 178099 | $02B7B3 | `AttackSystemEntry` | 18: Attack System |
| 178559 | $02B97F | `AuraBarrierMain` | 18C: Aura Barrier |
| 179003 | $02BB3B | `DarkFriarMain` | 18D: Dark Friar |
| 179702 | $02BDF6 | `TrailFollowerSprA` | 18F: Trail Followers |
| 179872 | $02BEA0 | `PsychoDashMain` | 18G: Psycho Dash |
| 180393 | $02C0A9 | `PsychoSliderMain` | 18H: Psycho Slider |
| 180786 | $02C232 | `GuidedProjectileActor` | 18I: Guided Projectile |
| 181132 | $02C38C | `PlayerCharacterDef` | 19: Player Character |
| 189334 | $02E396 | `InventoryMenuDef` | 20: Inventory Menu |
| 191746 | $02ED02 | `OpenInventoryScreen` | 21: Inventory Overlay |
| 192584 | $02F048 | `ShowDialogueFrame` | 22: Dialogue Wrapper |
| 192618 | $02F06A | `ClearVramBufferPartial` | 23: VRAM Buffer Clear |
| 192630 | $02F076 | `ClearVramBufferFull` | 23: VRAM Buffer Clear |

**Bank 2 total named addresses:** 477 (206 from bank2-code-analysis + 271 from this document).

---

## 10. Applied blocks.json Updates ✅

The following blocks in `us/blocks.json` have been renamed and given scene metadata:

| Old Block Key | New Block Key | Scene | Notes |
|---------------|---------------|-------|-------|
| `actor_02B20E` | `shadow_shimmer` | `player` | 5 parts renamed to descriptive names |
| `actor_02B29E` | `player_move_controller` | `player` | Flat part (single Code block) |
| `actor_02B42B` | `slope_ramp_physics` | `player` | Flat part |
| `actor_02B7B3` | `attack_ability_system` | `player` | 2 parts: `AttackSystemEntry`, `attack_abilities_ext` |
| `actor_02BDF6` | `attack_trail_followers` | `player` | Flat part |
| `player_character` | `player_character` | `player` | Added scene (name unchanged) |
| `inventory_menu` | `inventory_menu` | `inventory` | Already had scene (no change) |
| `func_02ED02` | `inventory_overlay` | `inventory` | Renamed |
| `func_02F048` | `dialogue_display` | — | Renamed |
| `func_02F06A` | `vram_buffer_clear` | — | Renamed |

### Boundary Verification

All block boundaries in bank 2 are contiguous with no gaps or overlaps:

```
$028000 ─────────── System Engine (Groups 1–14) ───────── $02B20E
$02B20E ─ shadow_shimmer (5 parts) ────────────────── $02B29E
$02B29E ─ player_move_controller ──────────────────────── $02B42B
$02B42B ─ slope_ramp_physics ──────────────────────────── $02B7B3
$02B7B3 ─ attack_ability_system [part 1: AttackSysEntry]─ $02BDF6
$02BDF6 ─ attack_trail_followers ──────────────────────── $02BE72
$02BE72 ─ attack_ability_system [part 2: abilities ext] ─ $02C38C
$02C38C ─ player_character ────────────────────────────── $02CFD0
$02CFD0 ─────────── Player Movement Physics (A–J) ─────── $02E396
$02E396 ─ inventory_menu ─────────────────────────────── $02ED02
$02ED02 ─ inventory_overlay ──────────────────────────── $02F048
$02F048 ─ dialogue_display ───────────────────────────── $02F06A
$02F06A ─ vram_buffer_clear ──────────────────────────── $02F08C
$02F08C ─────────── Free space / padding ──────────────── $02FFFF
```

---

## 11. Unmapped Regions

| Range | Hex | Size | Content |
|-------|-----|------|---------|
| 192652–196607 | $02F08C–$02FFFF | 3,955 B | Free space / bank 2 padding |

The gap at $02F08C–$02FFFF (end of bank 2) is significant — nearly 4 KB of
unused space. This represents potential room for patch code expansion.
