# Attack & Ability System

*Part of the [Bank $02 Documentation Suite](index.md)*

> Special attacks, abilities, and projectile actors for Will and Freedan

**Source:** [`attack_ability_system.asm`](../../../extracted/actors/player/attack_ability_system.asm)

---

## Overview

The attack system is a **companion actor** that runs **before** the movement controller (`SpawnBefore`). Each frame `AttackSystemEntry` checks whether the player is alive and movement is allowed; if `characterForm` (`$0AD4`) is **≥ 2** (Shadow and other late forms), the routine returns immediately — those forms **cannot attack through this code path**. For Will (`0`) or Freedan (`1`), an attack-button press enters `WillAttackDispatch`, which branches to `FreedanAttackDispatch` when form = 1. During any special ability, the player actor function pointer is hijacked via `SetPlayerActorFunc` until `AttackCleanup` restores idle.

```
AttackSystemEntry
  └─ form ≥ 2 → RTL (no attack)
  └─ form 0 → WillAttackDispatch
  └─ form 1 → FreedanAttackDispatch
       │
       ├─ Tap / short hold → basic attack (if $0AA2 bit 0 or 6)
       └─ Charge hold → extended charge → release or L/R selects special
            Will:   release → Psycho Dash    |  L/R → Psycho Slider
            Freedan: release → Dark Friar     |  L/R → Aura Barrier
```

| `$0AD4` | Form | Attack path | Special abilities (charge release / L·R) |
|---------|------|-------------|-------------------------------------------|
| `0` | Will | `WillAttackDispatch` | Psycho Dash / Psycho Slider |
| `1` | Freedan | `FreedanAttackDispatch` | Dark Friar / Aura Barrier |
| `2+` | Shadow | *(immediate RTL)* | — |

Ability availability is gated by `$0AA2`: Will needs bit 0 (`$0001`) for basic attack and bit 2 (`$0004`) for Slider; Freedan needs bit 6 (`$0040`) for basic attack, bit 4 (`$0010`) for Dark Friar, and bit 5 (`$0020`) for Aura Barrier.

**Two-phase charge model:** Both characters share a **40-frame initial hold** (`LoopInit #28`). Only after that threshold does the extended-charge window open — **120 frames** (`$0078`) for Will, **100 frames** (`$0064`) for Freedan. During extended charge, L/R shoulder input selects the alternate special; releasing the attack button fires the default special (Dash or Dark Friar). Validation helpers (`ValidateAttackReady`, `CheckAttackChargeable`) block charging during hitstun, death, or mid-combo.

**Trail followers:** Psycho Dash and Dark Friar spawn companion trail actors that lag behind the parent projectile. Each follower maintains a **3-slot position FIFO** (`TrailPositionCascade`): each frame the parent's `$14`/`$16` shifts through slot 0 → slot 1 → slot 2, and the follower renders at the oldest slot — producing a smooth motion trail without re-simulating physics. Parent offset helpers (`ComputeParentOffset` / `ApplyParentOffset`) keep fragments and trails aligned when the player moves during an ability.

**Related:** [`player-character.md`](player-character.md) · [`../../cop-commands-reference.md`](../../cop-commands-reference.md)

---

## attack_ability_system.asm

Attack/ability companion actor — runs **before** movement controller via `SpawnBefore`.

| Address | Name | Description |
|---------|------|-------------|
| `$02B7B3` | AttackSystemEntry | Entry. Check dead → die. Each frame check `$2A00` → skip. Check `$0AD4 < 2` → listen for attack (`$8001`). |
| `$02B7DE` | WillAttackDispatch | Will's attack. Check `$0AA2` bits `$0005` (0+2). 40-frame hold, 120-frame charge. L/R → Slider, release → Dash. |
| `$02B855` | LaunchPsychoDash | Validate facing, set func to `PsychoDashMain`. |
| `$02B861` | LaunchPsychoSlider | Set func to `PsychoSliderMain`. |
| `$02B86D` | FreedanAttackDispatch | Freedan attack. Check `$0AA2` bits `$0050` (4+6). 40-frame hold, 100-frame charge. Release → Dark Friar; L/R → Aura Barrier. |
| `$02B8D6` | LaunchDarkFriar | Set `$00EA=1`, func to `DarkFriarMain`. |
| `$02B8E7` | LaunchAuraBarrier | Require stopped. Set `$00EA=2`, func to `AuraBarrierMain`. |
| `$02B901` | AttackCleanup | Kill spawned FX, play palette effect, return to idle. |
| `$02B926` | SetPlayerActorFunc | Write func pointer A to player actor slot. |
| `$02B933` | ValidateAttackReady | Check `$3A00` and facing < 4. |
| `$02B946` | ValidateAttackContinue | Check `$2B00`. |
| `$02B94F` | SavePlayerPosition | Copy position to `$14`/`$16`. |
| `$02B95D` | CheckAttackChargeable | Check hitstun, death, mid-combo. |
| `$02B97F` | AuraBarrierMain | Set `$0200`+`$0800`. Spawn VRAM DMA. Load FX palette. Spawn rotating children. |
| `$02B9FC` | AuraBarrierEnd | Clear `$0200`. Restore state. |
| `$02BA0C` | AuraVramDmaLoader | DMA `misc_fx_1CC480` to VRAM `$4400`. |
| `$02BA17` | AuraOrbitalSpawner | Spawn 2–4 orbital children. Manage orbit rotation. |
| `$02BABD` | UpdateOrbitalPositions | Iterate orbital children, compute position. |
| `$02BAFE` | AuraProjectileChild | Individual orbiting sprite. 3-frame animation. |
| `$02BB29` | AuraProjectileShrink | Shrink animation. |
| `$02BB3B` | DarkFriarMain | Set `$2000`. Spawn VRAM DMA. Palette thinker `#4A`. 4-directional dispatch. |
| `$02BB93` | DarkFriarDirTable | Switch table: S/N/W/E. |
| `$02BB9B` | DarkFriarSouth | Spawn at (−2, +26), sprite `#36`. |
| `$02BBB4` | DarkFriarNorth | Spawn at (0, −64), sprite `#37`. |
| `$02BBCD` | DarkFriarWest | Spawn at (−52, −22), sprite `#38`. |
| `$02BBE6` | DarkFriarEast | Spawn at (+52, −22), sprite `#39`. |
| `$02BBFD` | DarkFriarFinish | Wait 7 frames, restore. |
| `$02BC02` | DarkFriarVramDma | DMA `misc_fx_1CC000` to VRAM `$4400`. |
| `$02BC0D` | DarkFriarProjectile | Main projectile sprite, `table_178000`. Wait 7 frames. |
| `$02BC27` | DarkFriarTrailSouthInit | Set `$2000` in `$12` (south). |
| `$02BC2C` | DarkFriarTrailSouth | South trail with collision if upgraded. |
| `$02BC74` | DarkFriarTrailWestInit | Set `$4000` in `$12` (west). |
| `$02BC79` | DarkFriarTrailEastWest | EW trail with X-axis movement. |
| `$02BCC1` | DarkFriarBounceLoop | Bounce animation. If fully upgraded, allows redirect. |
| `$02BCEE` | DarkFriarDisableCollide | Clear collision callback. |
| `$02BCF2` | DarkFriarOnHit | Spawn 4 fragments at 0°/64°/128°/192°. |
| `$02BD0C` | DarkFriarFragment1 | Angle `$40`. |
| `$02BD11` | DarkFriarFragment2 | Angle `$80`. |
| `$02BD16` | DarkFriarFragment3 | Angle `$C0`. |
| `$02BD19` | DarkFriarFragmentInit | Set angle, load anim, spawn trails, enable hitbox. |
| `$02BDC9` | DarkFriarFragmentLoop | Fragment animation with wall-hit velocity. |
| `$02BE72` | ComputeParentOffset | Store offset from parent actor to current position. |
| `$02BE89` | ApplyParentOffset | Add stored offset back to parent position. |
| `$02BEA0` | PsychoDashMain | Load anim table 0, disable status, 4-directional dispatch. |
| `$02BEB7` | PsychoDashDirTable | Switch S/N/W/E. |
| `$02BEBF` | PsychoDashSouth | Spawn trail, sprite `#04`, move Y +54. |
| `$02BECF` | PsychoDashNorth | Set force NE, sprite `#04`, move Y −54. |
| `$02BEE2` | PsychoDashWest | Set force both, sprite `#04`, move X −54. |
| `$02BEF5` | PsychoDashEast | Sprite `#04`, move X +54. |
| `$02BF09` | PsychoDashTrailSouth | Record 8 Y-position deltas, replay in reverse. |
| `$02BF71` | PsychoDashTrailNorth | Inverted Y deltas. |
| `$02BFD9` | PsychoDashTrailWest | X-axis deltas. |
| `$02C041` | PsychoDashTrailEast | Inverted X deltas. |
| `$02C0A9` | PsychoSliderMain | Set `$2002`, spawn guided projectile. Charge loop, L/R direction. |
| `$02C17C` | PsychoSliderRelease | Clear `$2800`. Check `$0B1A`: return 12 or 24 frames. |
| `$02C199` | PsychoSliderLaunch | Set sprite timer, anim set 1. Check joypad for direction. |
| `$02C1BE` | PsychoSliderDirEW | Horizontal launch. |
| `$02C1D0` | PsychoSliderDirNS | Vertical launch. |
| `$02C1E4` | PsychoSliderAbort | Clear `$0200`, restore. |
| `$02C1EB` | PsychoSliderChargeTick | Per-frame: alternate L/R shoulder check. |
| `$02C21C` | KillSpawnedProjectile | Read stored actor ID, `COP [MarkDeath]`. |
| `$02C232` | GuidedProjectileActor | Sprite priority `#30`, joypad-directed. 4 directions with hitbox. |
| `$02C288` | ProjectileMoveRight | Right: sprite `#3D`. |
| `$02C2A8` | ProjectileMoveLeft | Left: `#3C`. |
| `$02C2C8` | ProjectileMoveUp | Up: `#3B`. |
| `$02C2E8` | ProjectileMoveDown | Down: `#3A`. |
| `$02C308` | WillAttackPaletteFX | Loop palettes `#2A` then `#2B`. |
| `$02C315` | FreedanAttackPaletteFX | Loop `#4B` then `#2C`. |
| `$02C322` | AuraBarrierPaletteFX | Loop `#5B` infinite. |
| `$02C329` | RecomputeProjectilePos | Add stored offsets to player position. |
| `$02C33E` | LoadAbilityAnimTableA | Read `table_01D9A7` by index. |
| `$02C365` | LoadAbilityAnimTableB | Read `table_01D9BF` by index. |

### Shared WRAM Variables

Most routines in this file read and write the player actor slot and shared state bitmask:

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |

#### Attack Dispatch & Entry

### AttackSystemEntry

Entry. Check dead → die. Each frame check `$2A00` → skip. Check `$0AD4 < 2` → listen for attack (`$8001`).

**Algorithm:**
- Die if player dead (`$0008` in flags)
- Clear attack lock bit, set continue
- Skip if movement blocked (`$2A00`)
- If `characterForm >= 2`: return (Shadow and other forms cannot attack here)
- Else listen for attack button → `WillAttackDispatch` (form 1 jumps to `FreedanAttackDispatch`)


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `WillAttackDispatch` | Will form attack path |
| `FreedanAttackDispatch` | Freedan attack path (form 1 only) |
| `SetPlayerActorFunc` | Hijacks player actor function pointer |

### WillAttackDispatch

Will's attack. Check `$0AA2` bits `$0005` (basic attack or Psycho Slider). 40-frame hold (`#28`), then 120-frame extended charge (`$0078`). L/R → Slider, release → Dash.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### FreedanAttackDispatch

Freedan attack. Check `$0AA2` bits `$0050` (Dark Friar or basic attack). 40-frame hold (`#28`), then 100-frame extended charge (`$0064`). Release → Dark Friar; L/R → Aura Barrier.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### AttackCleanup

Kill spawned FX, play palette effect, return to idle.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

#### Attack Validation Helpers

### ValidateAttackReady

Check `$3A00` and facing < 4.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### CheckAttackChargeable

Check hitstun, death, mid-combo.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

#### Aura Barrier Orbitals

### AuraBarrierMain

Set `$0200`+`$0800`. Spawn VRAM DMA. Load FX palette. Spawn rotating children.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### AuraOrbitalSpawner

Spawn 2–4 orbital children. Manage orbit rotation.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### UpdateOrbitalPositions

Iterate orbital children, compute position.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### AuraProjectileChild

Individual orbiting sprite. 3-frame animation.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

#### Dark Friar Chain

### DarkFriarMain

Set `$2000`. Spawn VRAM DMA. Palette thinker `#4A`. 4-directional dispatch.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### DarkFriarProjectile

Main projectile sprite, `table_178000`. Wait 7 frames.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### DarkFriarTrailSouth

South trail with collision if upgraded.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### DarkFriarTrailEastWest

EW trail with X-axis movement.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

#### Dark Friar Bounce & Fragments

### DarkFriarBounceLoop

Bounce animation. If fully upgraded, allows redirect.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### DarkFriarOnHit

Spawn 4 fragments at 0°/64°/128°/192°.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### DarkFriarFragmentInit

Set angle, load anim, spawn trails, enable hitbox.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### DarkFriarFragmentLoop

Fragment animation with wall-hit velocity.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

#### Parent Offset Helpers

### ComputeParentOffset

Store offset from parent actor to current position.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### ApplyParentOffset

Add stored offset back to parent position.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

#### Psycho Dash Trails

### PsychoDashTrailSouth

Record 8 Y-position deltas, replay in reverse.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### PsychoDashTrailNorth

Inverted Y deltas.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### PsychoDashTrailWest

X-axis deltas.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### PsychoDashTrailEast

Inverted X deltas.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

#### Psycho Slider

### PsychoSliderMain

Set `$2002`, spawn guided projectile. Charge loop, L/R direction.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### PsychoSliderRelease

Clear `$2800`. Check `$0B1A`: return 12 or 24 frames.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### PsychoSliderLaunch

Set sprite timer, anim set 1. Check joypad for direction.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### PsychoSliderDirNS

Vertical launch.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### PsychoSliderChargeTick

Per-frame: alternate L/R shoulder check.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

#### Guided Projectile & Palette FX

### GuidedProjectileActor

Sprite priority `#30`, joypad-directed. 4 directions with hitbox.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### RecomputeProjectilePos

Add stored offsets to player position.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### LoadAbilityAnimTableA

Read `table_01D9A7` by index.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### LoadAbilityAnimTableB

Read `table_01D9BF` by index.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

---

#### Attack Trail Followers

Dark Friar fragment trail follower actors and the 3-stage position FIFO, at ROM `$02BDF6`–`$02BE72` in [`attack_ability_system.asm`](../../../extracted/actors/player/attack_ability_system.asm).

| Address | Name | Description |
|---------|------|-------------|
| `$02BDF6` | TrailFollowerSprA | Trail sprite with hitbox `#05`. |
| `$02BDFB` | TrailFollowerSprB | Trail sprite with hitbox `#06`. Init position queue, enter follow loop. |
| `$02BE1A` | TrailPositionCascade | 3-frame position queue cascade: current→slot0→slot1→slot2→render. |
| `$02BE55` | TrailPositionInit | Initialize 3 position queue slots to current `$14`/`$16`. |
| `$02BE72` | ComputeParentOffset | Store offset from parent actor to current position. |
| `$02BE89` | ApplyParentOffset | Add stored offset back to parent position. |

### TrailFollowerSprB

Trail sprite with hitbox `#06`. Init position queue, enter follow loop.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### TrailPositionCascade

3-frame position queue cascade: current→slot0→slot1→slot2→render.


**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$7F0000,X`–`$7F000E,X` | R/W | 3-frame X position queue |
| `$7F0018,X`–`$7F0004,X` | R/W | 3-frame Y position queue |
| `$0014,Y` / `$0016,Y` | R | Parent actor position |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### TrailPositionInit

Initialize 3 position queue slots to current `$14`/`$16`.


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

## See Also

- [`player-movement.md`](player-movement.md) — `PlayerMovementTick` (`$02CFD0`), tile collision (`$02E102`)
- [`tile-collision.md`](tile-collision.md) — tile probing for slopes and shimmy
- [`../../cop-commands-reference.md`](../../cop-commands-reference.md) — COP command semantics
- [`../../actor-organization-analysis.md`](../../actor-organization-analysis.md) — global actor linked list
