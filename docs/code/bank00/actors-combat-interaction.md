# Bank $00 — Actors: Combat, Interaction & Effects

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00D877`–`$00E4DB` (this document)  
**Scope:** Hit stagger/knockback, stat reward actors, push interaction handlers, smooth follow homing, and the visual effect scroll pipeline

These actors are spawned at runtime rather than placed in most scenes. They implement combat feedback, object pushing, homing projectiles, and the camera scroll integration chain.

**Related:** [`actors-infrastructure.md`](actors-infrastructure.md) (`camera_scroll_controller` feeds effect pipeline) · [`utility-math-movement.md`](utility-math-movement.md) (`MulDivide` used by effect math)

---

## Overview

| Actor / Block | Old Name | Address | Movable | Invocation |
|---------------|----------|---------|---------|------------|
| `hit_stagger_controller` | `actor_00D877` | `$D877`–`$DA66` | ✓ (parts block) | `ApplyPlayerHitstun`, enemy hit |
| `e_hp_increase` | part of `reward_actors` | `$E02D` | ✓ | `StandardEnemyDefeatHandler` |
| `e_str_increase` | part of `reward_actors` | `$E06B` | ✓ | `StandardEnemyDefeatHandler` |
| `e_def_increase` | part of `reward_actors` | `$E0A6` | ✓ | `StandardEnemyDefeatHandler` |
| `RewardActorVFX` | `func_00E110` | `$E110` | ✓ | All reward actors |
| `push_handler_light` | `actor_00E155` | `$E155` | ✓ | ~12 spawn sites |
| `push_handler_solid` | `actor_00E256` | `$E256` | ✓ | ~11 spawn sites |
| `push_handler_forceball` | `actor_00E3BA` | `$E3BA` | ✓ | Force ball puzzles |
| `smooth_follow_child` | `actor_00E4DB` | `$E4DB` | **No** | Boss/projectile scripts |
| `effect_velocity_init` | `actor_00E8D7` | `$E8D7` | ✓ | 22+ scene slots |
| `effect_subpixel_math` | `actor_00E98B` | `$E98B` | ✓ | Paired with pipeline |
| `effect_position_update` | `actor_00E9EC` | `$E9EC` | ✓ | Paired with pipeline |

**Pipeline order:** `camera_scroll_controller` → `effect_velocity_init` → `effect_position_update` → `effect_subpixel_math`

---

## Combat / Knockback

### hit_stagger_controller

| Property | Value |
|----------|-------|
| **Old Name** | `actor_00D877` |
| **New Name** | `hit_stagger_controller` |
| **Hex Address** | `$00D877`–`$00DA66` |
| **Decimal Address** | 55415–55928 |
| **Size** | 513 bytes (7 parts) |
| **Type** | Multi-part block |
| **ASM File** | `extracted/actors/hit_stagger_controller.asm` |
| **Movable** | Yes (as parts block) |
| **Priority** | High — combat-critical |

#### Description

Spawned when the player or an enemy takes a hit. Applies directional knockback, manages stun timer, and on completion either restores the target's AI script or returns the player to normal control (`code_02C3C8`). Spawned by `ApplyPlayerHitstun` (`$C397`) via `SpawnLastRel @HitStaggerMain` with flags `$2400`.

The block spans 7 linked parts with internal `$&` references. Entry point `HitStaggerMain` reads knockback direction from a 3-deep stack (`PEA` chain), selects animation via `table_01B086`, and delegates to `HitStaggerDirection` for the movement loop.

#### Parts

| Part | Address | Old Name | New Name (ASM) | Role |
|------|---------|----------|----------------|------|
| Entry | `$D877` | `e_actor_00D877` | `HitStaggerMain` | Init: copy victim pos, read direction stack, start knockback |
| Loop | `$D904` | `func_00D904` | `HitStaggerDirection` | 16-frame position sync loop; collision probe via `sub_00DA13` |
| Return | `$D9EB` | `func_00D9EB` | `HitStaggerReturnAI` | Restore player AI or `$FFF4` stun timer; clear joypad mask |
| Probe | `$DA13` | `sub_00DA13` | `sub_00DA13` | Distance threshold check ($30/$20/$40 based on `$7F101C`) |
| Flag | `$DA41` | `sub_00DA41` | `sub_00DA41` | Carry set/clear from compare result |
| Dir | `$DA47` | `sub_00DA47` | `sub_00DA47` | Map direction index → `table_01B086` offset |
| Apply | `$DA66` | `sub_00DA66` | `sub_00DA66` | Write `$2C`/`$2E` velocity; set axis flag `$26` |

#### Algorithm (HitStaggerMain)

```
1. If victim $7F002A bit $0020: skip $10 bit $0008 set
2. Set $12 bit $0008 (stagger active)
3. If $12 bit $0010 (already in stagger): WaitByte #$0F, check $10 bit $0400
     → AI restore path or player return path
4. Copy victim $14/$16 to stagger actor; save $7F101C
5. Pop direction from 3-deep stack (0=N, 1=S, 2=E, 3=W variants)
6. JSR sub_00DA47 → load velocity from table_01B086
7. Enter HitStaggerDirection loop
```

#### Algorithm (HitStaggerDirection)

```
1. SetEntryExit; 16-frame LoopInit syncing victim position
2. If $10 bit $0400 (enemy hit): restore AI via saved script ptr
3. If $10 bit $0008 (player hit): probe distance via sub_00DA13
4. On axis alignment: zero victim $0008, set stun $0028 ← $FFF4
5. On timeout: restore saved script ptr or StandardEnemyDefeatHandler
6. Die
```

#### Variables

| Symbol | Role |
|--------|------|
| `$24` | Victim actor index |
| `$7F0010/12` | Saved victim position |
| `$7F101C` | Hit type / knockback strength selector |
| `$7F0028` | Stun timer on victim |
| `$7F002A` | Victim flags (bit `$0020` = special case) |
| `$10` | Bits `$0008` (player hit), `$0400` (enemy hit) |
| `$2C`, `$2E` | Knockback velocity components |
| `$26` | Axis selector (0=X, 1=Y) |
| `table_01B086` | Direction → velocity lookup |

#### Scene Usage

Never scene-placed. Spawned at runtime from:

| Caller | Context |
|--------|---------|
| `ApplyPlayerHitstun` | Player damage (~12 enemy types) |
| `chunk_03BAE1` | Engine hit dispatch |
| Enemy attack scripts | Via hit callback chain |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Spawned by | `ApplyPlayerHitstun` (`$C397`) | `SpawnLastRel @HitStaggerMain` |
| Returns to | `code_02C3C8` | Player normal AI (bank `$02`) |
| Falls through to | `StandardEnemyDefeatHandler` | When enemy has no saved script |
| Includes | `player_character`, `StandardEnemyDefeatHandler`, `table_01B086` | |

---

## Stat Reward Actors

Spawned from `StandardEnemyDefeatHandler` (`func_00DB8A`) via `COP [SpawnLastRel]` after combat victories. Never placed directly in `scene_actors.asm`. All three stat actors call shared `RewardActorVFX` before printing their message and dying.

### e_hp_increase

| Property | Value |
|----------|-------|
| **Old Name** | part of `reward_actors` |
| **New Name** | `e_hp_increase` |
| **Hex Address** | `$00E02D` |
| **Decimal Address** | 57389 |
| **Size** | 78 bytes |
| **ASM File** | `extracted/actors/reward_actors.asm` |

#### Description

Increments `$0ACA` (HP) by 1, clamping at `$0255` (597 decimal — max HP cap). Updates display delta `$0B22 ← $0ACA − $0ACE`. Hitbox stage `#0C`. Prints *"Your HP (Power) has increased!"*

#### Variables

| Symbol | Role |
|--------|------|
| `$0ACA` | Current HP |
| `$0ACE` | Base HP |
| `$0B22` | HP bar delta for UI refresh |

---

### e_str_increase

| Property | Value |
|----------|-------|
| **Old Name** | part of `reward_actors` |
| **New Name** | `e_str_increase` |
| **Hex Address** | `$00E06B` |
| **Decimal Address** | 57467 |
| **Size** | 75 bytes |
| **ASM File** | `extracted/actors/reward_actors.asm` |

#### Description

Increments `$0ADE` (STR) by 1 with `$0255` overflow clamp. Hitbox stage `#0D`. Prints *"Your STR (Strength) has increased!"*

---

### e_def_increase

| Property | Value |
|----------|-------|
| **Old Name** | part of `reward_actors` |
| **New Name** | `e_def_increase` |
| **Hex Address** | `$00E0A6` |
| **Decimal Address** | 57542 |
| **Size** | 74 bytes |
| **ASM File** | `extracted/actors/reward_actors.asm` |

#### Description

Increments `$0ADC` (DEF) by 1 with `$0255` overflow clamp. Hitbox stage `#0E`. Prints *"Your DEF (Defense) has increased!"*

---

### RewardActorVFX

| Property | Value |
|----------|-------|
| **Old Name** | `func_00E110` |
| **New Name** | `RewardActorVFX` |
| **Hex Address** | `$00E110` |
| **Decimal Address** | 57616 |
| **Size** | 69 bytes |
| **ASM File** | `extracted/actors/reward_actors.asm` |

#### Description

Shared reward visual effect called by all three stat actors via `COP [CallScript]`. Sequence:

1. Clear `$12` bit `$6000` (sprite visibility)
2. Bounce sprite toward player (`StageSpriteLoopMoveY`, `$FF`×4 then `$FF`×3 loops)
3. Snap sprite to player position (Y − 8)
4. `StageMove` toward player
5. Play sound `$25` on channel 2
6. `SetFlag_0300` for current scene (marks reward collected)
7. `RestoreSavedPtr`

All reward actors converge here — the VFX + flag set is identical regardless of stat type.

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | `e_hp_increase`, `e_str_increase`, `e_def_increase` | `CallScript &RewardActorVFX` |
| Spawned from | `StandardEnemyDefeatHandler` | Via `EnemyStatBonusReward` |
| Also spawned from | `EnemyRewardChestSystem` | Chest variant rewards |
| Uses | `table_0EE000` | Generic reward metasprite |

---

## Push / Interaction Handlers

Three variants sharing `$@func_03F0CA` (player direction probe) and `chunk_03BAE1`. All use button `$0031` (A) and proximity radius `$0F`. Parent actor index stored in `$04` links the pushed object.

### push_handler_light

| Property | Value |
|----------|-------|
| **Old Name** | `actor_00E155` |
| **New Name** | `push_handler_light` |
| **Hex Address** | `$00E155` (script `$E155`) |
| **Decimal Address** | 57685 |
| **Size** | 257 bytes |
| **ASM File** | `extracted/actors/push_interaction_handlers.asm` |
| **Movable** | Yes |

#### Description

Lightweight push: nudges linked actor ±2 pixels per frame without modifying solid tiles. Requires player facing the object (`func_03F0CA` direction match). Uses half-distance (`LSR`) from player to object as repeat count stored in `$7F0010`.

No minimum offset threshold — any facing-aligned press nudges. Used for collectible reveals and light objects.

#### Algorithm

```
1. SetSavedPtr; SetEntryExit
2. BranchIfButton ($0031) — require A button
3. BranchIfPlayerNear ($0F)
4. BranchOnPlayerX/Y to select axis
5. Compute distance >> 1 → repeat count
6. func_03F0CA: verify player facing
7. Move linked actor ($04) ±2 px on matched axis
8. Dec repeat count; loop or RestoreSavedPtr
```

#### Scene Usage

Spawned at runtime (~12 sites including `field_reveal_object`, `EnemyRewardChestSystem`).

---

### push_handler_solid

| Property | Value |
|----------|-------|
| **Old Name** | `actor_00E256` |
| **New Name** | `push_handler_solid` |
| **Hex Address** | `$00E256` (script `$E256`) |
| **Decimal Address** | 57942 |
| **Size** | 356 bytes |
| **ASM File** | `extracted/actors/push_interaction_handlers.asm` |
| **Movable** | Yes |

#### Description

Heavy push for statues and blocks. Requires **≥32 pixel** (`$0020`) offset between player and object. On successful push:

1. `BranchIfSolidOffset` — verify destination clear
2. `ClearLowHere` at old position, move anchor ±16 px
3. `SolidHighHere` at new position
4. Sound `$2C` on channel 1
5. 16-frame animated slide (`LoopInit #$10`)
6. Toggle `$0012` bit `$0010` on linked actor (push-in-progress flag)

Most-used push handler (~11 spawn sites: archers, knight armor, statues, Seth boulder).

#### Variables

| Symbol | Role |
|--------|------|
| `$04` | Linked actor to push |
| `$0012` bit `$0010` | Push animation in-progress |
| `$0010` bit `$0080` | Blocks push if set (unless `$0012` bit `$0010` already active) |
| `$24` | Saved push-state for restore |

#### Scene Usage

| Caller | Context |
|--------|---------|
| `gw82_archer` | Great Wall archer statue |
| `sg4D_knight_armor` | Sky Garden armor |
| `ir1F_stone_lord/guard` | Incan Ruins statues |
| `ir20_statue`, `ir26_statue` | Incan treasure/statue rooms |
| `ec0E_statue`, `ec0B_cell` | Edward Castle |
| `sg51_statue`, `sc02_seth` | Garden / South Cape |

---

### push_handler_forceball

| Property | Value |
|----------|-------|
| **Old Name** | `actor_00E3BA` |
| **New Name** | `push_handler_forceball` |
| **Hex Address** | `$00E3BA` (script `$E3BA`) |
| **Decimal Address** | 58298 |
| **Size** | 289 bytes |
| **ASM File** | `extracted/actors/push_interaction_handlers.asm` |
| **Movable** | Yes |

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
| Shared | `func_03F0CA` | Player facing probe (bank `$03`) |
| Shared | `chunk_03BAE1` | Engine interaction helpers |

---

## Smooth Follow (Homing)

### smooth_follow_child

| Property | Value |
|----------|-------|
| **Old Name** | `actor_00E4DB` |
| **New Name** | `smooth_follow_child` |
| **Hex Address** | `$00E4DB` (entry `$E4DB`, child `$E4FC`, helpers `$E5C1`–`$E644`) |
| **Decimal Address** | 58587 |
| **Size** | 378 bytes |
| **ASM File** | `extracted/actors/smooth_follow_child.asm` |
| **Movable** | **No** (`$&` refs to `smooth_follow` system) |

#### Description

Spawns a child actor that homes toward a target using angle/step math from the `smooth_follow` include block. Parent script zeros `$002A`, spawns child at `@code_00E4FC` with flags `$2000`, copies `$24` (target actor index) to child, then loops `AnimOnce` until `$10` bit `$4000` (arrival flag) before dying.

Child script (`code_00E4FC`) computes delta-X and delta-Y to target (target Y − 8 for sprite anchor), compares magnitudes to pick dominant axis, then dispatches to one of 8 movement paths that call `ComputeFollowAngle` / `ComputeFollowAngleAlt` and `ComputeFollowStep` from `smooth_follow.asm`.

#### Algorithm

```
Parent:
  1. STZ $002A
  2. SpawnMarkedAfter @code_00E4FC (#$2000)
  3. Copy $24 → child $0024
  4. AnimOnce loop until $10 bit $4000
  5. Die

Child:
  1. Copy parent $7F0014 → self
  2. ΔX = target.$14 − self.$14; ΔY = target.$16 − $08 − self.$16
  3. Compare |ΔX| vs |ΔY| → select octant path
  4. ComputeFollowAngle(Alt) + ComputeFollowStep
  5. Apply $0000/$0002 step to $14/$16
  6. Sync position back to parent actor ($0004 link)
  7. RTL (re-entered each frame via SetEntryContinue)
```

#### Variables

| Symbol | Role |
|--------|------|
| `$24` | Target actor index |
| `$0004` | Parent actor link |
| `$0018`, `$001C` | Computed delta magnitudes |
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
| Included by | `chunk_03BAE1` | Engine-level access |
| Pointer refs | `$&smooth_follow_child-1` | Direct `$&` addressing |

---

## Visual Effect Pipeline

Three actors forming a camera/scroll effect subsystem. Placed together in 22+ scenes that need smooth sub-pixel scrolling (Viper Lair, mystic statues, etc.). **`camera_scroll_controller`** writes deltas to `$06E4`/`$06E6`; this pipeline integrates them into `$06C8`/`$06C4` scroll registers with sub-pixel precision.

```
camera_scroll_controller
    │  writes $06E4, $06E6
    ▼
effect_velocity_init
    │  seeds $06C8, $06C4, $06E8, $06EA
    ▼
effect_position_update
    │  integrates velocity, clamps to $effect_bounds_x/y
    ▼
effect_subpixel_math
    │  MulDivide for sub-pixel scroll
    └──► final $06C8, $06C4
```

### effect_velocity_init

| Property | Value |
|----------|-------|
| **Old Name** | `actor_00E8D7` |
| **New Name** | `effect_velocity_init` |
| **Hex Address** | `$00E8D7` (script `$E8DA`) |
| **Decimal Address** | 59607 |
| **Size** | 118 bytes |
| **Type** | `actor_def` (priority `#2C`) |
| **ASM File** | `extracted/actors/visual_effect_pipeline.asm` |
| **Movable** | Yes |

#### Description

First stage of scroll effect integration. Converts actor spawn coordinates to signed velocity values in `$2C`/`$2E` (tile-relative, with Y − 1 bias). Zeros position registers and scroll accumulators, waits 1 frame, then adds velocity + camera deltas (`$06E4`/`$06E6`) to produce initial scroll values.

Sets `$06C8` with `$8000` OR — the high bit marks sub-pixel overflow pending in `effect_subpixel_math`.

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

### effect_subpixel_math

| Property | Value |
|----------|-------|
| **Old Name** | `actor_00E98B` |
| **New Name** | `effect_subpixel_math` |
| **Decimal Address** | 59787 |
| **Hex Address** | `$00E98B` (entry `$E98B`, X-path `$E9CA`) |
| **Size** | 97 bytes |
| **Type** | `Code` (not actor_def — called each frame) |
| **ASM File** | `extracted/actors/visual_effect_pipeline.asm` |
| **Movable** | Yes |

#### Description

Multiply/divide helper for sub-pixel scroll values. Uses `$@MulDivide` from `hardware_math` (bank `$02`). For X: if `$14` bit `$8000` (negative sub-pixel), sign-extends and adds to `$06C8`; otherwise if high byte non-zero, multiplies by `$06BE` (target scroll). Y path at `$E9CA` mirrors for `$16`/`$06C4`/`$06C2`.

`SetEntryContinue` + `PEA $&code_00E9CA-1` structure allows X and Y passes in one actor tick.

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

### effect_position_update

| Property | Value |
|----------|-------|
| **Old Name** | `actor_00E9EC` |
| **New Name** | `effect_position_update` |
| **Hex Address** | `$00E9EC` (script `$E9EF`) |
| **Decimal Address** | 59884 |
| **Size** | 170 bytes |
| **Type** | `actor_def` (priority `#2C`) |
| **ASM File** | `extracted/actors/visual_effect_pipeline.asm` |
| **Movable** | Yes |

#### Description

Integrates velocity each frame and clamps to effect bounds. Mirrors `effect_velocity_init` coordinate conversion, then in the `SetEntryContinue` loop:

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

Paired with `effect_velocity_init` in the same 22+ scenes.

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Fed by | `camera_scroll_controller` | `$06E4`/`$06E6` deltas |
| Followed by | `effect_subpixel_math` | Sub-pixel refinement |
| Block | `visual_effect_pipeline` | Grouped in `us/blocks.json` |

---

*Source: `extracted/actors/*.asm`, `extracted/functions/ApplyPlayerHitstun.asm`, `extracted/functions/StandardEnemyDefeatHandler.asm`, `us/blocks.json`, `extracted/tables/scene_actors.asm`.*
