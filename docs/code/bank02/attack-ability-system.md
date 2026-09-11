# Attack & Ability System

> Special attacks, abilities, and projectile actors for Will, Freedan, and Shadow

**Source:** [`attack_ability_system.asm`](../../../extracted/actors/player/attack_ability_system.asm) · [`attack_trail_followers.asm`](../../../extracted/actors/player/attack_trail_followers.asm)

---

## Overview

The attack companion actor runs **before** the movement controller via `SpawnBefore`. It reads `$0AD4` (character form) and `$0AA2` (ability bitmask) to dispatch Will vs Freedan/Shadow attacks, charge timing (28 vs 40 frames), and special abilities. It hijacks the player actor function pointer via `SetPlayerActorFunc` during ability execution.

| `$0AD4` | Form | Attack Dispatcher | Primary Abilities |
|---------|------|-------------------|-------------------|
| `0` | Will | `WillAttackDispatch` | Basic attack, Psycho Dash, Psycho Slider, running attack |
| `1` | Freedan | `FreedanAttackDispatch` | Basic attack, Dark Friar, Aura Barrier, vine drop-attack |
| `2` | Shadow | `FreedanAttackDispatch` + `dark_space_palette` | Same as Freedan + Dark Space palette cycling |

| `$0AA2` Bit | Hex | Character | Ability |
|-------------|-----|-----------|---------|
| 0 | `$0001` | All | Basic attack |
| 1 | `$0002` | Will | Running attack (Psycho Dash prerequisite) |
| 2 | `$0004` | Will | Psycho Slider |
| 4 | `$0010` | Freedan | Dark Friar |
| 5 | `$0020` | Freedan | Aura Barrier |
| 6 | `$0040` | Freedan/Shadow | Earthquaker (vine drop-attack) |

**Charge timing:** Will abilities charge **28 frames**; Freedan/Shadow charge **40 frames**. L/R shoulder buttons during charge select alternate abilities (Slider vs Dash; Aura vs Dark Friar).

**Related:** [`player-character.md`](player-character.md) · [`../../cop-commands-reference.md`](../../cop-commands-reference.md)

---

## attack_ability_system.asm

Attack/ability companion actor — runs **before** movement controller via `SpawnBefore`.

| Address | Name | Size | Description |
|---------|------|------|-------------|
| `$02B7B3` | AttackSystemEntry | 42 B | Entry. Check dead → die. Each frame check `$2A00` → skip. Check `$0AD4 < 2` → listen for attack (`$8001`). |
| `$02B7DE` | WillAttackDispatch | 109 B | Will's attack. Check `$0AA2` bits `$01`+`$04`. Charge 28 frames. L/R → Slider, else → Dash. |
| `$02B855` | LaunchPsychoDash | 12 B | Validate facing, set func to `PsychoDashMain`. |
| `$02B861` | LaunchPsychoSlider | 12 B | Set func to `PsychoSliderMain`. |
| `$02B86D` | FreedanAttackDispatch | 150 B | Freedan/Shadow attack. Check `$0AA2` bits `$10`+`$40`. Charge 40 frames. Dark Friar / Aura / Spin Dash. |
| `$02B8D6` | LaunchDarkFriar | 17 B | Set `$00EA=1`, func to `DarkFriarMain`. |
| `$02B8E7` | LaunchAuraBarrier | 26 B | Require stopped. Set `$00EA=2`, func to `AuraBarrierMain`. |
| `$02B901` | AttackCleanup | 37 B | Kill spawned FX, play palette effect, return to idle. |
| `$02B926` | SetPlayerActorFunc | 13 B | Write func pointer A to player actor slot. |
| `$02B933` | ValidateAttackReady | 22 B | Check `$3A00` and facing < 4. |
| `$02B946` | ValidateAttackContinue | 9 B | Check `$2B00`. |
| `$02B94F` | SavePlayerPosition | 14 B | Copy position to `$14`/`$16`. |
| `$02B95D` | CheckAttackChargeable | 32 B | Check hitstun, death, mid-combo. |
| `$02B97F` | AuraBarrierMain | 125 B | Set `$0200`+`$0800`. Spawn VRAM DMA. Load FX palette. Spawn rotating children. |
| `$02B9FC` | AuraBarrierEnd | 16 B | Clear `$0200`. Restore state. |
| `$02BA0C` | AuraVramDmaLoader | 11 B | DMA `misc_fx_1CC480` to VRAM `$4400`. |
| `$02BA17` | AuraOrbitalSpawner | 150 B | Spawn 2–4 orbital children. Manage orbit rotation. |
| `$02BABD` | UpdateOrbitalPositions | 65 B | Iterate orbital children, compute position. |
| `$02BAFE` | AuraProjectileChild | 43 B | Individual orbiting sprite. 3-frame animation. |
| `$02BB29` | AuraProjectileShrink | 18 B | Shrink animation. |
| `$02BB3B` | DarkFriarMain | 88 B | Set `$2000`. Spawn VRAM DMA. Palette thinker `#4A`. 4-directional dispatch. |
| `$02BB93` | DarkFriarDirTable | 8 B | Switch table: S/N/W/E. |
| `$02BB9B` | DarkFriarSouth | 25 B | Spawn at (−2, +26), sprite `#36`. |
| `$02BBB4` | DarkFriarNorth | 25 B | Spawn at (0, −64), sprite `#37`. |
| `$02BBCD` | DarkFriarWest | 25 B | Spawn at (−52, −22), sprite `#38`. |
| `$02BBE6` | DarkFriarEast | 17 B | Spawn at (+52, −22), sprite `#39`. |
| `$02BBFD` | DarkFriarFinish | 5 B | Wait 7 frames, restore. |
| `$02BC02` | DarkFriarVramDma | 11 B | DMA `misc_fx_1CC000` to VRAM `$4400`. |
| `$02BC0D` | DarkFriarProjectile | 26 B | Main projectile sprite, `table_178000`. Wait 7 frames. |
| `$02BC27` | DarkFriarTrailSouthInit | 5 B | Set `$2000` in `$12` (south). |
| `$02BC2C` | DarkFriarTrailSouth | 72 B | South trail with collision if upgraded. |
| `$02BC74` | DarkFriarTrailWestInit | 5 B | Set `$4000` in `$12` (west). |
| `$02BC79` | DarkFriarTrailEastWest | 72 B | EW trail with X-axis movement. |
| `$02BCC1` | DarkFriarBounceLoop | 52 B | Bounce animation. If fully upgraded, allows redirect. |
| `$02BCEE` | DarkFriarDisableCollide | 4 B | Clear collision callback. |
| `$02BCF2` | DarkFriarOnHit | 26 B | Spawn 4 fragments at 0°/64°/128°/192°. |
| `$02BD0C` | DarkFriarFragment1 | 5 B | Angle `$40`. |
| `$02BD11` | DarkFriarFragment2 | 5 B | Angle `$80`. |
| `$02BD16` | DarkFriarFragment3 | 3 B | Angle `$C0`. |
| `$02BD19` | DarkFriarFragmentInit | 87 B | Set angle, load anim, spawn trails, enable hitbox. |
| `$02BDC9` | DarkFriarFragmentLoop | 43 B | Fragment animation with wall-hit velocity. |
| `$02BE72` | ComputeParentOffset | 23 B | Store offset from parent actor to current position. |
| `$02BE89` | ApplyParentOffset | 23 B | Add stored offset back to parent position. |
| `$02BEA0` | PsychoDashMain | 9 B | Load anim table 0, disable status, 4-directional dispatch. |
| `$02BEB7` | PsychoDashDirTable | 8 B | Switch S/N/W/E. |
| `$02BEBF` | PsychoDashSouth | 16 B | Spawn trail, sprite `#04`, move Y +54. |
| `$02BECF` | PsychoDashNorth | 19 B | Set force NE, sprite `#04`, move Y −54. |
| `$02BEE2` | PsychoDashWest | 19 B | Set force both, sprite `#04`, move X −54. |
| `$02BEF5` | PsychoDashEast | 14 B | Sprite `#04`, move X +54. |
| `$02BF09` | PsychoDashTrailSouth | 104 B | Record 8 Y-position deltas, replay in reverse. |
| `$02BF71` | PsychoDashTrailNorth | 104 B | Inverted Y deltas. |
| `$02BFD9` | PsychoDashTrailWest | 104 B | X-axis deltas. |
| `$02C041` | PsychoDashTrailEast | 104 B | Inverted X deltas. |
| `$02C0A9` | PsychoSliderMain | 211 B | Set `$2002`, spawn guided projectile. Charge loop, L/R direction. |
| `$02C17C` | PsychoSliderRelease | 29 B | Clear `$2800`. Check `$0B1A`: return 12 or 24 frames. |
| `$02C199` | PsychoSliderLaunch | 37 B | Set sprite timer, anim set 1. Check joypad for direction. |
| `$02C1BE` | PsychoSliderDirEW | 18 B | Horizontal launch. |
| `$02C1D0` | PsychoSliderDirNS | 20 B | Vertical launch. |
| `$02C1E4` | PsychoSliderAbort | 7 B | Clear `$0200`, restore. |
| `$02C1EB` | PsychoSliderChargeTick | 49 B | Per-frame: alternate L/R shoulder check. |
| `$02C21C` | KillSpawnedProjectile | 19 B | Read stored actor ID, `COP [MarkDeath]`. |
| `$02C232` | GuidedProjectileActor | 214 B | Sprite priority `#30`, joypad-directed. 4 directions with hitbox. |
| `$02C288` | ProjectileMoveRight | 32 B | Right: sprite `#3D`. |
| `$02C2A8` | ProjectileMoveLeft | 32 B | Left: `#3C`. |
| `$02C2C8` | ProjectileMoveUp | 32 B | Up: `#3B`. |
| `$02C2E8` | ProjectileMoveDown | 32 B | Down: `#3A`. |
| `$02C308` | WillAttackPaletteFX | 13 B | Loop palettes `#2A` then `#2B`. |
| `$02C315` | FreedanAttackPaletteFX | 13 B | Loop `#4B` then `#2C`. |
| `$02C322` | AuraBarrierPaletteFX | 7 B | Loop `#5B` infinite. |
| `$02C329` | RecomputeProjectilePos | 21 B | Add stored offsets to player position. |
| `$02C33E` | LoadAbilityAnimTableA | 39 B | Read `table_01D9A7` by index. |
| `$02C365` | LoadAbilityAnimTableB | 39 B | Read `table_01D9BF` by index. |

#### Subgroup 18A — Attack Dispatcher

### AttackSystemEntry

Entry. Check dead → die. Each frame check `$2A00` → skip. Check `$0AD4 < 2` → listen for attack (`$8001`).

**Algorithm:**
- Die if player dead (`$0008` in flags)
- Clear attack lock bit, set continue
- Skip if movement blocked (`$2A00`)
- If Freedan/Shadow (`$0AD4 >= 2`): return (handled elsewhere)
- Else listen for attack button → `WillAttackDispatch`

**Source:**

```23:48:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `WillAttackDispatch` | Will form attack path |
| `FreedanAttackDispatch` | Freedan/Shadow attack path |
| `SetPlayerActorFunc` | Hijacks player actor function pointer |

### WillAttackDispatch

Will's attack. Check `$0AA2` bits `$01`+`$04`. Charge 28 frames. L/R → Slider, else → Dash.

**Source:**

```49:101:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### FreedanAttackDispatch

Freedan/Shadow attack. Check `$0AA2` bits `$10`+`$40`. Charge 40 frames. Dark Friar / Aura / Spin Dash.

**Source:**

```116:159:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### AttackCleanup

Kill spawned FX, play palette effect, return to idle.

**Source:**

```184:207:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

#### Subgroup 18B — Helpers

### ValidateAttackReady

Check `$3A00` and facing < 4.

**Source:**

```216:229:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### CheckAttackChargeable

Check hitstun, death, mid-combo.

**Source:**

```246:270:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

#### Subgroup 18C — Aura Barrier

### AuraBarrierMain

Set `$0200`+`$0800`. Spawn VRAM DMA. Load FX palette. Spawn rotating children.

**Source:**

```271:317:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### AuraOrbitalSpawner

Spawn 2–4 orbital children. Manage orbit rotation.

**Source:**

```334:405:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### UpdateOrbitalPositions

Iterate orbital children, compute position.

**Source:**

```406:440:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### AuraProjectileChild

Individual orbiting sprite. 3-frame animation.

**Source:**

```441:462:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

#### Subgroup 18D — Dark Friar

### DarkFriarMain

Set `$2000`. Spawn VRAM DMA. Palette thinker `#4A`. 4-directional dispatch.

**Source:**

```474:509:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### DarkFriarProjectile

Main projectile sprite, `table_178000`. Wait 7 frames.

**Source:**

```558:569:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### DarkFriarTrailSouth

South trail with collision if upgraded.

**Source:**

```575:604:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### DarkFriarTrailEastWest

EW trail with X-axis movement.

**Source:**

```610:638:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

#### Subgroup 18E — Dark Friar Bounce

### DarkFriarBounceLoop

Bounce animation. If fully upgraded, allows redirect.

**Source:**

```639:668:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### DarkFriarOnHit

Spawn 4 fragments at 0°/64°/128°/192°.

**Source:**

```673:680:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### DarkFriarFragmentInit

Set angle, load anim, spawn trails, enable hitbox.

**Source:**

```694:766:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### DarkFriarFragmentLoop

Fragment animation with wall-hit velocity.

**Source:**

```767:774:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

#### Subgroup 18F — Parent Offset Helpers

### ComputeParentOffset

Store offset from parent actor to current position.

**Source:**

```795:807:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### ApplyParentOffset

Add stored offset back to parent position.

**Source:**

```808:820:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

#### Subgroup 18G — Psycho Dash

### PsychoDashTrailSouth

Record 8 Y-position deltas, replay in reverse.

**Source:**

```875:923:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### PsychoDashTrailNorth

Inverted Y deltas.

**Source:**

```924:972:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### PsychoDashTrailWest

X-axis deltas.

**Source:**

```973:1021:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### PsychoDashTrailEast

Inverted X deltas.

**Source:**

```1022:1069:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

#### Subgroup 18H — Psycho Slider

### PsychoSliderMain

Set `$2002`, spawn guided projectile. Charge loop, L/R direction.

**Source:**

```1070:1165:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### PsychoSliderRelease

Clear `$2800`. Check `$0B1A`: return 12 or 24 frames.

**Source:**

```1166:1181:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### PsychoSliderLaunch

Set sprite timer, anim set 1. Check joypad for direction.

**Source:**

```1182:1197:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### PsychoSliderDirNS

Vertical launch.

**Source:**

```1210:1224:../../../extracted/actors/player/attack_ability_system.asm
```

**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### PsychoSliderChargeTick

Per-frame: alternate L/R shoulder check.

**Source:**

```1231:1259:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

#### Subgroup 18I — Guided Projectile & Palette FX

### GuidedProjectileActor

Sprite priority `#30`, joypad-directed. 4 directions with hitbox.

**Source:**

```1277:1312:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

#### Subgroup 18I — Guided Projectile & Palette FX

### RecomputeProjectilePos

Add stored offsets to player position.

**Source:**

```1415:1426:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### LoadAbilityAnimTableA

Read `table_01D9A7` by index.

**Source:**

```1427:1450:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

### LoadAbilityAnimTableB

Read `table_01D9BF` by index.

**Source:**

```1451:1471:../../../extracted/actors/player/attack_ability_system.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_ability_system` block | Parent compilation unit |

---

## attack_trail_followers.asm

Trail sprite actors for Psycho Dash, Dark Friar, and other ability FX.

| Address | Name | Size | Description |
|---------|------|------|-------------|
| `$02BDF6` | TrailFollowerSprA | 5 B | Trail sprite with hitbox `#05`. |
| `$02BDFB` | TrailFollowerSprB | 33 B | Trail sprite with hitbox `#06`. Init position queue, enter follow loop. |
| `$02BE1A` | TrailPositionCascade | 59 B | 3-frame position queue cascade: current→slot0→slot1→slot2→render. |
| `$02BE55` | TrailPositionInit | 29 B | Initialize 3 position queue slots to current `$14`/`$16`. |

#### Subgroup 18F — Trail Followers

### TrailFollowerSprB

Trail sprite with hitbox `#06`. Init position queue, enter follow loop.

**Source:**

```8:30:../../../extracted/actors/player/attack_trail_followers.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_trail_followers` block | Parent compilation unit |

### TrailPositionCascade

3-frame position queue cascade: current→slot0→slot1→slot2→render.

**Source:**

```31:50:../../../extracted/actors/player/attack_trail_followers.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$7F0000,X`–`$7F000E,X` | R/W | 3-frame X position queue |
| `$7F0018,X`–`$7F0004,X` | R/W | 3-frame Y position queue |
| `$0014,Y` / `$0016,Y` | R | Parent actor position |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_trail_followers` block | Parent compilation unit |

### TrailPositionInit

Initialize 3 position queue slots to current `$14`/`$16`.

**Source:**

```51:61:../../../extracted/actors/player/attack_trail_followers.asm
```

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$player_flags` | R/W | Shared player state bitmask |
| `$player_actor` | R | Player WRAM slot index |


**Cross-References:**

| Symbol | Relationship |
|--------|-------------|
| `attack_trail_followers` block | Parent compilation unit |

## See Also

- [`../bank2-code-analysis.md`](../bank2-code-analysis.md) — `PlayerMovementTick` (`$02CFD0`), tile collision (`$02E102`)
- [`camera-and-map.md`](camera-and-map.md) — tile probing for slopes and shimmy
- [`../../cop-commands-reference.md`](../../cop-commands-reference.md) — COP command semantics
- [`../../actor-organization-analysis.md`](../../actor-organization-analysis.md) — global actor linked list
