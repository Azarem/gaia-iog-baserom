# Bank $00 — Actors: Combat, Interaction & Effects

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00D877`–`$00E4DB` (this document)  
**Source files:** `extracted/actors/hit_stagger_controller.asm`, `extracted/actors/reward_actors.asm`, `extracted/actors/interaction_handlers.asm`, `extracted/actors/smooth_follow_child.asm`, `extracted/actors/layer1_scroll_actors.asm`, `extracted/functions/ApplyPlayerHitstun.asm`, `extracted/functions/StandardEnemyDefeatHandler.asm`, `extracted/tables/scene_actors.asm`  
**Scope:** Hit stagger/knockback, stat reward actors, push interaction handlers, smooth follow homing, and the visual effect scroll pipeline

These actors are spawned at runtime rather than placed in most scenes. They implement combat feedback, object pushing, homing projectiles, and the camera scroll integration chain.

**Related:** [`actors-infrastructure.md`](actors-infrastructure.md) (`camera_scroll_controller` feeds effect pipeline) · [`utility-math-movement.md`](utility-math-movement.md) (`MulDivide` used by effect math)

---

## Overview

| Actor / Block | Address | Movable | Invocation |
|---------------|---------|---------|------------|
| `hit_stagger_controller` | `$D877`–`$DA66` | ✓ (parts block) | `ApplyPlayerHitstun`, enemy hit |
| `e_hp_increase` | `$E02D` | ✓ | `StandardEnemyDefeatHandler` |
| `e_str_increase` | `$E07B` | ✓ | `StandardEnemyDefeatHandler` |
| `e_def_increase` | `$E0C6` | ✓ | `StandardEnemyDefeatHandler` |
| `RewardActorVFX` | `$E110` | ✓ | All reward actors |
| `collect_handler_gem` | `$E155` | ✓ | ~12 spawn sites |
| `push_handler_solid` | `$E256` | ✓ | ~11 spawn sites |
| `push_handler_forceball` | `$E3BA` | ✓ | Force ball puzzles |
| `smooth_follow_child` | `$E4DB` | **No** | Boss/projectile scripts |
| `Layer1DriftUnbounded` | `$E8D7` | ✓ | 22+ scene slots |
| `Layer1ParallaxRatio` | `$E98B` | ✓ | Paired with pipeline |
| `Layer1DriftWrapped` | `$E9EC` | ✓ | Paired with pipeline |

**Pipeline order:** `camera_scroll_controller` → `Layer1DriftUnbounded` → `Layer1DriftWrapped` → `Layer1ParallaxRatio`

---

## Combat / Knockback

### hit_stagger_controller

**Address:** `$D877`–`$DA66` · **Size:** 513 bytes (7 parts)

#### Description

Spawned when the player or an enemy takes a hit. Applies one-axis knockback for 16 frames by moving the controller actor (collision-checked) and syncing the victim's position, then either returns the **player** to `PlayerIdleEntry` (`HitStaggerReleasePlayer`) or resolves the **enemy** hit/death callbacks (`HitStaggerResolveHit`). Spawned by `ApplyPlayerHitstun` via `SpawnListAppend @HitStaggerMain` with flags `$2400` (`$2000` script-driven + `$0400` player victim).

The block spans 7 linked parts with internal `$&` references. Entry point `HitStaggerMain` decodes the direction code in `$28` (from the spawner; not a stack) and loads a `move_chain_table` curve from knockback tier `free101C`, then enters `HitStaggerSlideLoop`.

#### Parts

| Part | Address | Name (ASM) | Role |
|------|---------|------------|------|
| Entry | `$D877` | `HitStaggerMain` | Init: copy victim pos, read direction stack, start knockback |
| Loop | `$D904` | `HitStaggerSlideLoop` | 16-frame position sync loop; collision probe via `HitStaggerCheckKnockbackDistance` |
| Return | `$D9EB` | `HitStaggerReleasePlayer` | Player only: `PlayerIdleEntry`, shorten iframe counter, reveal D-pad |
| Probe | `$DA13` | `HitStaggerCheckKnockbackDistance` | Distance threshold check ($30/$20/$40 based on `$7F101C`) |
| Flag | `$DA41` | `HitStaggerZeroToCarry` | Carry set/clear from compare result |
| Dir | `$DA47` | `HitStaggerApplyKnockbackDelta` | Map direction index → `move_chain_table` offset |
| Apply | `$DA66` | `HitStaggerStoreMovementDelta` | Write `$2C`/`$2E` velocity; set axis flag `$26` |

#### Algorithm (HitStaggerMain)

```
1. Set $10 bit $0008 (collision-checked movement) unless victim extendedFlags $0020
2. Set $12 bit $0008 (movement request)
3. If $12 bit $0010 (stagger-immune) or direction code >= 4: WaitByte #$0F → ReleasePlayer or ResolveHit
4. Save victim start X/Y in orbitAngle/orbitDiameter; copy knockback tier free101C
5. Decode direction code in $28 (0=south … 3=east) → vertical or horizontal delta chain
6. JSR HitStaggerApplyKnockbackDelta (tier 0 → curve $22 / 48 px, tier 1+ → curve $23 / 32 px)
7. Enter HitStaggerSlideLoop
```

#### Algorithm (HitStaggerSlideLoop)

```
1. SetEntryHereAndYield; LoopStart #$10 — copy child $14/$16 to victim each frame
2. If $10 bit $0400 (player victim): HitStaggerReleasePlayer
3. Else if victim lacks $10 bit $0008: HitStaggerResolveHit
4. Else compare slide distance d to tier threshold ($30 / $20 / $40); full slide or wall cut-short cleanup
5. HitStaggerResolveHit: onHitCallback or death path (or StandardEnemyDefeatHandler); Die
```

#### Variables

| Symbol | Role |
|--------|------|
| `$24` | Victim actor index |
| `$7F0010/12` | Saved victim position |
| `$7F101C` | Hit type / knockback strength selector |
| `$7F0028` | Stun timer on victim |
| `$7F002A` | Victim flags (bit `$0020` = special case) |
| `$10` | Bit `$0008` on victim (collision movement); bit `$0400` = player victim |
| `$2C`, `$2E` | Knockback velocity components |
| `$26` | Axis selector (0=X, 1=Y) |
| `move_chain_table` | Direction → velocity lookup |

#### Scene Usage

Never scene-placed. Spawned at runtime from:

| Caller | Context |
|--------|---------|
| `ApplyPlayerHitstun` | Player damage (9 call sites in 3 enemy scripts) |
| `ComposeDigitSprites_AtCursor` | Engine hit dispatch |
| Enemy attack scripts | Via hit callback chain |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Spawned by | `ApplyPlayerHitstun`, `combat_collision` | `SpawnListAppend @HitStaggerMain`; flags `$2400` or `$2000` |
| Returns to | `PlayerIdleEntry` | Via `HitStaggerReleasePlayer` only |
| Falls through to | `StandardEnemyDefeatHandler` | Enemy death with no death callback |
| Includes | `player_character`, `StandardEnemyDefeatHandler`, `move_chain_table` | |

---

## Stat Reward Actors

Spawned from `StandardEnemyDefeatHandler.EnemyStatBonusReward` when the **last** enemy of a scene is defeated (`SpawnListAppend`, flags `$1000` after `displayModeFlags` `$0080` display filter). Never placed in `scene_actors.asm`. Each actor calls `RewardActorVFX` via `CallNear` before applying its stat change and message.

### e_hp_increase

**Address:** `$E02D` · **Size:** 78 bytes

#### Description

Adds 1 to max HP (`$0ACA`) and sets `hpToHeal` to new max minus current HP (`$0ACE`), refilling missing HP via `UpdateHUD`. The signed-overflow clamp at `$0255` is dead code (`BVC` skips it). Hitbox stage `#0C`. Prints *"Your HP (Power) has increased!"*

#### Variables

| Symbol | Role |
|--------|------|
| `$0ACA` | Max HP |
| `$0ACE` | Current HP |
| `$0B22` | `hpToHeal`: HP still to recover (set to new max HP − current HP) |

---

### e_str_increase

**Address:** `$E07B` · **Size:** 75 bytes

#### Description

Increments `$0ADE` (STR) by 1 (same dead `$0255` overflow check as HP). Hitbox stage `#0D`. Prints *"Your STR (Strength) has increased!"*

---

### e_def_increase

**Address:** `$E0C6` · **Size:** 74 bytes

#### Description

Increments `$0ADC` (DEF) by 1 (same dead `$0255` overflow check). Hitbox stage `#0E`. Prints *"Your DEF (Defense) has increased!"*

---

### RewardActorVFX

**Address:** `$E110` · **Size:** 69 bytes

#### Description

Shared reward visual called by all three stat actors via `CallNear` (returns with `RestoreSavedPtr`). Sequence:

1. Clear `$12` bits `$4000` / `$2000`
2. Rise along chain `#12` (−1 px every second tick) for 4 animation passes, hover 3 passes
3. `StageMove` / `TickMove` fly toward player (target X, player Y − 8)
4. Set hidden bit; clear `displayModeFlags` `$0080` (unfreeze world)
5. Play sound `$25` on channel 2
6. `SetFlag_0300` for current scene (marks reward collected)

All reward actors converge here — the VFX + flag set is identical regardless of stat type.

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | `e_hp_increase`, `e_str_increase`, `e_def_increase` | `CallNear &RewardActorVFX` |
| Spawned from | `StandardEnemyDefeatHandler` | Via `EnemyStatBonusReward` |
| Related | `EnemyDropSystem` | Separate gem/heal pickups (`$chatPtr` `$83`–`$86`), not stat rewards |
| Uses | `table_0EE000` | Generic reward metasprite |

---

## Interaction Handlers

Three handlers sharing `$@GetPlayerFacingDirection` (player direction probe). All poll **L / R shoulders** via `BranchIfPressed` mask `#$0031` (bit 0 → `joypadRaw`; the tested buttons are `#$0030`, not A/`#$0080`) and proximity radius `$0F`. Parent actor index in `$04` is the object being moved.

> ⚠ Block `interaction_handlers`: `collect_handler_gem` nudges gems toward the player; `push_handler_solid` and `push_handler_forceball` **pull** their parent one tile toward the player (legacy names say "push").

### collect_handler_gem

**Address:** `$E155` · **Size:** 257 bytes

#### Description

Gem/heal pickup interaction handler. When the player is near a dropped pickup and presses L/R shoulders, this handler nudges the parent actor toward the player at ±2 pixels per frame. **Not a push handler** — the pickup drifts toward the player rather than being pushed away.

Spawned as a child by `EnemyDropSystem` (item ids `$83`–`$86`: 1/2/5 gems and 5 HP heal) and `field_reveal_object` (scene-clear stat gems). The parent handles the sprite and `chatPtr` item id; this handler manages only the pull interaction.

Uses `GetPlayerFacingDirection` for player facing verification and half-distance (`LSR`) from player to gem as the repeat count stored in `$7F0010`. No minimum offset threshold — any facing-aligned press nudges.

#### Algorithm

```
1. SetSavedPtr; SetEntryExit
2. BranchIfPressed (#$0031) — require L or R shoulder (#$0030 in `joypadRaw`)
3. BranchIfPlayerNear ($0F)
4. BranchOnPlayerX/Y to select axis
5. Compute distance >> 1 → repeat count
6. GetPlayerFacingDirection: verify player facing
7. Move linked gem actor ($04) ±2 px toward player on matched axis
8. Dec repeat count; loop or RestoreSavedPtr
```

#### Scene Usage

Spawned at runtime (~12 sites including `field_reveal_object`, `EnemyDropSystem`).

---

### push_handler_solid

**Address:** `$E256` · **Size:** 356 bytes

#### Description

Pull for statues and blocks (object moves **toward** the player). Requires **≥32 pixel** (`$0020`) separation and matching facing. On success:

1. `BranchIfSolidOffset` — verify tile one step toward player is clear
2. `ClearSolidHere` at old position; anchor moves ±16 px toward player
3. `MarkSolidHere` at new position
4. Sound `$2C` on channel 1
5. 16-frame 1 px/frame slide (`LoopInit #$10`)
6. OR `$0012` bit `$0010` on parent (saved in handler `$24`), restored after slide

Most-used push handler (~11 spawn sites: archers, knight armor, statues, Seth boulder).

#### Variables

| Symbol | Role |
|--------|------|
| `$04` | Linked actor to push |
| `$0012` bit `$0010` | Slide in-progress (OR-ed, then restored from `$24`) |
| `$0010` bit `$0080` | Blocks push if set (unless `$0012` bit `$0010` already active) |
| `$24` | Saved push-state for restore |

#### Scene Usage

| Caller | Context |
|--------|---------|
| `gw82_archer` | Great Wall archer statue |
| `sg4D_knight_armor` | Sky Garden armor |
| `ir1F_stone_lord/guard` | Incan Ruins statues |
| `ir20_statue`, `ir26_statue` | Incan treasure/statue rooms |
| `ec0E_statue` | Edward Castle aqueduct statue |
| `ec0B_cell` | *(none — spawns `collect_handler_gem`)* |
| `sg51_statue`, `sc02_seth` | Garden / South Cape |

---

### push_handler_forceball

**Address:** `$E3BA` · **Size:** 289 bytes

#### Description

Force ball puzzle push handler. Requires player animation `$0028` in range `$003A`–`$003D` (forceball attack frames) **and** ≥32 px offset. Uses `AddPosition` COP instead of manual coordinate math — applies `#F0`/`#10` pixel shifts on the matched axis.

| Direction | Required Anim | AddPosition |
|-----------|---------------|-------------|
| North | `$003A` | `#00, #F0` |
| South | `$003B` | `#00, #10` |
| West | `$003D` | `#F0, #00` |
| East | `$003C` | `#10, #00` |

#### Scene Usage

`mu60_force_ball.asm` (Mu force ball puzzle).

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Shared | `GetPlayerFacingDirection` | Player facing probe (bank `$03`) |
| Shared | `ComposeDigitSprites_AtCursor` | Engine interaction helpers |

---

## Smooth Follow (aimed projectile)

### smooth_follow_child

**Address:** `$E4DB`–`$E644` · **Size:** 378 bytes · **Movable:** No (`$&` refs to `smooth_follow` system)

#### Description

Spawns a child actor that aims once at a target and then flies straight (it does not chase), using angle/step math from the `smooth_follow` include block. Parent script zeros `$002A`, spawns child at `@SmoothFollowChildTick` with flags `$2000`, copies `$24` (target actor index) to child, then loops `AnimOnce` until its own `$10` bit `$4000` (the off-screen flag set by `SortActorsByDepth`; no parent sets it) is set, then dies. The child is the only mover: it writes its position to the visible body every frame.

Child script (`SmoothFollowChildTick`) computes delta-X and delta-Y to target once (target Y − 8 for sprite anchor), compares magnitudes to pick dominant axis, then dispatches to one of 8 heading handlers (`SmoothFollowApplySSE`, `ESE`, `NNE`, `ENE`, `SSW`, `WSW`, `NNW`, `WNW`; the letters are the heading, the first is the dominant axis). The handler calls `ComputeFollowAngle` / `ComputeFollowAngleAlt` once; `SetEntryHere` then resumes after the aim, so every later frame only applies `ComputeFollowStep` (fixed heading, target ignored).

#### Algorithm

```
Parent:
  1. STZ $002A
  2. SpawnAfterMarked @SmoothFollowChildTick (#$2000)
  3. Copy $24 → child $0024
  4. AnimOnce loop until $10 bit $4000
  5. Die

Child:
  1. Copy parent $7F0014 → self
  2. ΔX = target.$14 − self.$14; ΔY = target.$16 − $08 − self.$16
  3. Compare |ΔX| vs |ΔY| → select the heading handler (first frame only)
  4. ComputeFollowAngle(Alt) once, then SetEntryHere
  5. Every frame: ComputeFollowStep, apply $0000 (major axis) / $0002 (minor axis, 0 or 1) to $14/$16 with the handler's fixed signs
  6. SmoothFollowWriteParentPos copies X/Y to the body ($0004 link)
  7. RTL (re-entered each frame via SetEntryHere)
```

#### Variables

| Symbol | Role |
|--------|------|
| `$24` | Target actor index |
| `$0004` | Parent actor link |
| `$0018`, `$001C` | Computed delta magnitudes (global scratch words, not actor fields) |
| `$0000`, `$0002` | Step X/Y from `ComputeFollowStep` |
| `$10` bit `$4000` | Arrival/completion flag |

#### Scene Usage

Runtime spawn from boss/projectile scripts:

| Caller | Context |
|--------|---------|
| `pyCC_blaster` | Pyramid blaster projectile |
| `awB1_wall_walker` | Angkor wall walker |
| `gw8A_sand_fanger` | Sand Fanger boss |
| `ec0C_ribber` | Ribber enemy |
| `pyDD_mummy_queen` | Mummy Queen |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Includes | `smooth_follow` | `ComputeFollowAngle`, `ComputeFollowStep` |
| Included by | `ComposeDigitSprites_AtCursor` | Engine-level access |
| Pointer refs | `$&smooth_follow_child-1` | Direct `$&` addressing |

---

## Visual Effect Pipeline

Three actors forming a camera/scroll effect subsystem. Placed together in 22+ scenes that need smooth sub-pixel scrolling (Viper Lair, mystic statues, etc.). **`camera_scroll_controller`** writes deltas to `$06E4`/`$06E6`; this pipeline integrates them into `$06C8`/`$06C4` scroll registers with sub-pixel precision.

```
camera_scroll_controller
    │  writes $06E4, $06E6
    ▼
Layer1DriftUnbounded
    │  seeds $06C8, $06C4, $06E8, $06EA
    ▼
Layer1DriftWrapped
    │  integrates velocity, clamps to $effect_bounds_x/y
    ▼
Layer1ParallaxRatio
    │  MulDivide for sub-pixel scroll
    └──► final $06C8, $06C4
```

### Layer1DriftUnbounded

**Address:** `$E8D7` · **Size:** 118 bytes

#### Description

First stage of scroll effect integration. Converts actor spawn coordinates to signed velocity values in `$2C`/`$2E` (tile-relative, with Y − 1 bias). Zeros position registers and scroll accumulators, waits 1 frame, then adds velocity + camera deltas (`$06E4`/`$06E6`) to produce initial scroll values.

Sets `$06C8` with `$8000` OR — the high bit marks sub-pixel overflow pending in `Layer1ParallaxRatio`.

#### Variables

| Symbol | Role |
|--------|------|
| `$2C`, `$2E` | Signed tile velocity |
| `$06C8`, `$06C4` | Scroll position (output) |
| `$06E4`, `$06E6` | Input deltas from camera_scroll_controller |
| `$06E8`, `$06EA` | Velocity accumulators |
| `$068C`, `$0690` | Previous scroll snapshot |
| `$14`, `$16` | Working position (zeroed then re-seeded) |

#### Scene Usage

**22** placements in `scene_actors.asm` (Viper Lair, effect-heavy dungeons).

---

### Layer1ParallaxRatio

**Address:** `$E98B` · **Size:** 97 bytes

#### Description

Multiply/divide helper for sub-pixel scroll values. Uses `$@MulDivide` from `hardware_math` (bank `$02`). For X: if `$14` bit `$8000` (negative sub-pixel), sign-extends and adds to `$06C8`; otherwise if high byte non-zero, multiplies by `$06BE` (target scroll). Y path at `$E9CA` mirrors for `$16`/`$06C4`/`$06C2`.

`SetEntryHere` + `PEA $&Layer1ParallaxRatioY-1` structure allows X and Y passes in one actor tick.

#### Variables

| Symbol | Role |
|--------|------|
| `$14`, `$16` | Sub-pixel remainder |
| `$06C8`, `$06C4` | Scroll output |
| `$06BE`, `$06C2` | Scale factors (from camera_scroll_controller) |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Calls | `MulDivide` | SNES hardware math (bank `$02`) |
| Includes | `hardware_math` | |

---

### Layer1DriftWrapped

**Address:** `$E9EC` · **Size:** 170 bytes

#### Description

Integrates velocity each frame and clamps to effect bounds. Mirrors `Layer1DriftUnbounded` coordinate conversion, then in the `SetEntryHere` loop:

- X: add `$2C` + `$06E4` to `$14`; clamp to `[$0000, $effect_bounds_x]`
- Y: add `$2E` + `$06E6` to `$16`; clamp to `[$0000, $effect_bounds_y − 1]`
- Write `$06C0`/`$06C4` scroll registers
- Compute delta accumulators `$06E8 ← $06C0 − $068C`, `$06EA ← $06C4 − $0690`

Negative clamp paths snap to `$effect_bounds` maximum; overflow paths snap to zero.

#### Variables

| Symbol | Role |
|--------|------|
| `$effect_bounds_x` | Maximum scroll X |
| `$effect_bounds_y` | Maximum scroll Y |
| `$06C0`, `$06C4` | Integrated scroll position |
| `$068C`, `$0690` | Previous frame scroll |
| `$06E8`, `$06EA` | Frame deltas |

#### Scene Usage

Paired with `Layer1DriftUnbounded` in the same 22+ scenes.

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Fed by | `camera_scroll_controller` | `$06E4`/`$06E6` deltas |
| Followed by | `Layer1ParallaxRatio` | Sub-pixel refinement |
| Block | `layer1_scroll_actors` | Grouped with velocity init + subpixel math |

---

*Source: `extracted/actors/*.asm`, `extracted/functions/ApplyPlayerHitstun.asm`, `extracted/functions/StandardEnemyDefeatHandler.asm`, `extracted/tables/scene_actors.asm`.*
