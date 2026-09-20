# Attack & Ability System

*Part of the [Bank $02 Documentation Suite](readme.md)*

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

Ability availability is gated by `$0AA2`: Will's dispatch requires bit 0 (`$0001`, basic attack) or bit 2 (`$0004`, Psycho Slider); Freedan's dispatch requires bit 4 (`$0010`, Dark Friar) or bit 6 (`$0040`, Earthquaker) — without either, the dispatch returns immediately without attacking. Aura Barrier additionally requires bit 5 (`$0020`).

**Two-phase charge model:** Both characters share a **40-frame initial hold** (`LoopInit #28`). Only after that threshold does the extended-charge window open — **120 frames** (`$0078`) for Will, **100 frames** (`$0064`) for Freedan. During extended charge, L/R shoulder input selects the alternate special; releasing the attack button fires the default special (Dash or Dark Friar). Validation helpers (`ValidateAttackReady`, `CheckAttackChargeable`) block charging during hitstun, death, or mid-combo.

**Trail followers:** Psycho Dash and Dark Friar spawn companion trail actors that lag behind the parent projectile. Each follower maintains a **3-slot position FIFO** (`TrailPositionCascade`): each frame the parent's `$14`/`$16` shifts through slot 0 → slot 1 → slot 2, and the follower renders at the oldest slot — producing a smooth motion trail without re-simulating physics. Parent offset helpers (`ComputeParentOffset` / `ApplyParentOffset`) keep fragments and trails aligned when the player moves during an ability.

**Related:** [`player-character.md`](player-character.md) · [`../../cop/index.md`](../../cop/index.md)

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

#### Attack Dispatch & Entry

### AttackSystemEntry

Companion actor entry point that runs every frame before the movement controller. If the player is dead, the companion dies with them; otherwise it clears the attack-in-progress bit and polls for a valid attack-button press. Shadow and other late forms (`characterForm ≥ 2`) are excluded entirely — only Will and Freedan can enter the charge-and-launch flow from here.

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

Entered from `AttackSystemEntry` when Will presses attack and `$0AA2` has basic attack or Psycho Slider unlocked. Sets the attack-in-progress flag, enforces a 40-frame hold commitment, then opens a 120-frame extended charge window with palette FX. Releasing attack fires Psycho Dash; if Psycho Slider is unlocked, `CheckAttackChargeable` gates continued charging and L/R shoulder input launches the steerable Slider instead.

### FreedanAttackDispatch

Branched from `WillAttackDispatch` when `characterForm` is 1. Requires Dark Friar or basic-attack bits in `$0AA2`, then runs the same 40-frame hold followed by a shorter 100-frame charge. Pressing Y, A, or shoulders during charge aborts to prevent accidental inputs. Without Aura Barrier unlocked, releasing attack fires Dark Friar; with it, D-pad input cancels selection, L/R launches the stationary Aura Barrier, and release still defaults to Dark Friar.

### AttackCleanup

Called by all launch routines and by `ValidateAttackReady` on abort. Kills the charge-up palette FX actor stored during the hold phase, restores the character's normal palette bundle (Will #0B, Freedan #0C), and returns the companion actor to its idle polling loop at `code_02B7BD`. This is the universal teardown path after any attack attempt completes or fails validation.

#### Attack Validation Helpers

### ValidateAttackReady

Gate called by `LaunchPsychoDash`, `LaunchPsychoSlider`, `LaunchDarkFriar`, and `LaunchAuraBarrier` immediately before hijacking the player actor. Blocks launch if the player is hurt, in knockback, transforming, or in a dialogue transition, or if facing is not a cardinal direction. On failure it pops the return address and falls through to `AttackCleanup` rather than starting the ability.

### CheckAttackChargeable

Called each frame during Will's extended charge when Psycho Slider is unlocked. Returns carry set (not chargeable) if the player is recovering from hitstun, locked in a special animation, or mid-combo — preventing indefinite charge farming. When carry is clear, charge continues and the L/R shoulder check for Psycho Slider can proceed.

#### Aura Barrier Orbitals

### AuraBarrierMain

Player-actor entry point after `LaunchAuraBarrier` confirms Freedan is standing still. Uploads Aura Barrier tile graphics via VRAM DMA, applies the FX palette and casting pose, and spawns a palette-cycling FX actor. After the cast animation completes, it clears the attack lock so Will can move, spawns `AuraOrbitalSpawner` above the player's head, and runs the sustain animation until the orbital phase ends.

### AuraOrbitalSpawner

Spawned 16 pixels above Freedan during Aura Barrier cast. Creates two base orbital children plus two more if the Aura upgrade flag (`$0B1E`) is set. Over 240 frames the orbit expands from diameter 0 to 64 pixels while rotating at 2 units per frame; when the timer expires or the player holds attack, all children switch to `AuraProjectileShrink` and a 30-frame contraction loop runs before the spawner dies.

### UpdateOrbitalPositions

Called each frame by `AuraOrbitalSpawner` during both expand and shrink phases. Walks the linked list of orbital child actors, computing each one's position via `ApplyOrbitalOffsetFromRef` from the player's center at the current angle and diameter. Angle spacing alternates between 180° (two orbitals) and 90° (four orbitals) depending on child count.

### AuraProjectileChild

Individual orbiting energy sprite spawned by `AuraOrbitalSpawner`. Plays a two-frame spawn-in sequence then loops frame #02 while the parent updates its world position each frame. In scene `$DD` (Mummy Queen's Lair) it adjusts sprite priority for correct layering. The `AuraProjectileShrink` entry point plays the spawn sequence in reverse and marks the actor for deferred removal when the barrier ends.

#### Dark Friar Chain

### DarkFriarMain

Freedan's default charged attack entry point, reached from `LaunchDarkFriar`. Sets the Dark Friar active flag, DMAs projectile graphics to VRAM, copies the FX palette, and spawns a palette-reset thinker so colors restore automatically when the ability ends. Dispatches to one of four directional handlers based on facing — each spawns a brief projectile flash and a growing trail at a direction-specific offset while Freedan plays the matching cast animation.

### DarkFriarProjectile

Short-lived visual flash spawned at the cast offset before the trail appears. Computes its offset from Freedan via `ComputeParentOffset`, waits 7 frames to stay synced with the casting animation, then reveals its sprite and self-destructs. The actual damage and travel behavior belong to the trail actor spawned alongside it — this actor is purely the initial energy burst visual.

### DarkFriarTrailSouth

South-facing Dark Friar energy wave, spawned by `DarkFriarSouth` at offset (−2, +26). After the 7-frame cast sync delay it grows southward through animated trail sprites with constant downward force. If Dark Friar is upgraded (`$0B1C`), it gains collision damage and registers `DarkFriarOnHit` for the fragment burst on enemy contact. Shares the `DarkFriarBounceLoop` travel logic with other directions for wall bounce and level-2 redirect.

### DarkFriarTrailEastWest

Horizontal trail variant used for both east and west casts. Uses X-axis growing animation and constant horizontal force (+5 X) instead of the south trail's Y movement. West entries pass through `DarkFriarTrailWestInit` to set a horizontal direction flag; east enters directly. Otherwise identical to the south trail — same upgrade-gated collision, `DarkFriarOnHit` callback, and shared bounce/redirect loop.

#### Dark Friar Bounce & Fragments

### DarkFriarBounceLoop

Main travel loop for the Dark Friar trail after its initial growth animation completes. Reloads force-movement parameters each frame until a wall collision flag ($4000) kills the trail. At upgrade level 2 (`$0B1C = 2`), holding attack during the post-collision timing window calls `DarkFriarDisableCollide`, letting the player redirect the trail without triggering the fragment burst — the fully upgraded Dark Friar's manual aim feature.

### DarkFriarOnHit

Collision callback registered on upgraded Dark Friar trails when they contact an enemy. Spawns three new fragment actors at 64°, 128°, and 192° and converts the hitting trail itself into a fourth fragment at 0°. All four enter `DarkFriarFragmentInit` for an outward spiral burst — the upgraded Dark Friar's area-of-effect payoff that turns a single hit into a four-way energy explosion.

### DarkFriarFragmentInit

Shared setup for all four post-collision fragments. Stores the fragment's initial orbit angle, loads Freedan animation table B for sprite configuration, and spawns two trail followers (`TrailFollowerSprB` then `TrailFollowerSprA`) for a cascading afterimage. Enables hitbox sprite #04, then spirals outward from the impact point (angle +2, diameter +4 per frame) until max range triggers velocity reversal into `DarkFriarFragmentLoop`.

### DarkFriarFragmentLoop

Return phase after a fragment reaches maximum spiral radius in `DarkFriarFragmentInit`. Applies the stored reversed velocity each frame via `moveScratch1`/`moveScratch2` until a wall collision dissolves the fragment. Completes the expand-then-contract lifecycle that makes upgraded Dark Friar hits feel like ricocheting energy shards rather than simple projectiles.

#### Parent Offset Helpers

### ComputeParentOffset

Called when Dark Friar projectile and trail actors spawn. Stores the XY delta between the child actor's current position and its parent actor (in `$7F100C`/`$7F100E`) so the child can maintain its spawn offset even if Freedan moves during the 7-frame casting delay.

### ApplyParentOffset

Called after the 7-frame cast sync delay on Dark Friar projectile and trail actors. Adds the stored offset from `ComputeParentOffset` to the parent's current position, repositioning the child so it stays at the original spawn point relative to Freedan even if he shifted during the animation.

#### Psycho Dash Trails

### PsychoDashTrailSouth

Spawned by `PsychoDashSouth` at the start of Will's charged dash. Records 8 frames of Y-position deltas during the ~54-pixel southward dash, then replays them in reverse at half speed by writing to the parent's `moveScratch2`. The result is a ghost afterimage that retraces the dash path behind Will, creating his signature southern blur trail.

### PsychoDashTrailNorth

North mirror of `PsychoDashTrailSouth`, spawned by `PsychoDashNorth`. Inverts the Y delta calculation (current minus baseline instead of baseline minus current) to correctly capture northward motion. Uses the same 8-frame record and reverse-playback pattern, producing a northern afterimage that lags behind the upward dash.

### PsychoDashTrailWest

West variant spawned by `PsychoDashWest`. Records 8 frames of X-position deltas during the horizontal dash and replays them in reverse via the parent's `moveScratch1` instead of `moveScratch2`. Creates a horizontal ghost trail that follows Will's westward Psycho Dash path.

### PsychoDashTrailEast

East mirror of `PsychoDashTrailWest`, spawned by `PsychoDashEast`. Inverts the X delta subtraction (baseline minus current instead of current minus baseline) to match eastward motion direction. Same 8-frame record and reverse-playback lifecycle as the west trail.

#### Psycho Slider

### PsychoSliderMain

Will's alternate charged ability, reached from `LaunchPsychoSlider`. Sets Psycho Slider state flags, runs a contact-damage charge animation loop, and aborts via `PsychoSliderAbort` on wall collision. When charge completes, spawns `GuidedProjectileActor` for D-pad steering during the hold phase, then uses an RTS trick to chain into directional speed setup and the launch sequence. Enters the L/R charge-tick phase when charge level reaches 12 or higher.

### PsychoSliderRelease

Intermediate hop in the launch chain, reached via RTS trick after the guided projectile phase ends. Clears Psycho Slider state flags from `$playerFlags` and sets up `PsychoSliderLaunchLoop` as the return target. Returns a frame count for the launch animation delay: 12 frames at base level, 24 frames if the Slider upgrade flag (`$0B1A`) is set.

### PsychoSliderLaunch

Runs the launch animation loop stored in `retPtr2`, then checks D-pad input for direction. Routes to `PsychoSliderDirEW` or `PsychoSliderDirNS` for facing-specific player sprites; if no direction is held, aborts via `PsychoSliderAbort`. Clears the charge state flag when the launch animation completes.

### PsychoSliderDirNS

Vertical launch sprite selection called from `PsychoSliderLaunch` when up or down is held on the D-pad. Up selects player sprite #01 (north launch pose), down selects sprite #00 (south launch pose), then animates one frame before returning to the caller chain.

### PsychoSliderChargeTick

Called each frame during Will's extended charge when charge level is 12 or above. Checks L shoulder on odd frames and R shoulder on even frames — each press decrements the charge level for intensity tuning. Merges consumed shoulder button state into `joypadHeld` to prevent the same press from triggering again next frame.

#### Guided Projectile & Palette FX

### GuidedProjectileActor

Steerable Psycho Slider orb spawned at Will's position during the charge phase. Stores its offset from the player and responds to D-pad input, switching among directional sprites (#3A–#3D) each with an active hitbox. Calls `RecomputeProjectilePos` each steering frame to stay relative to Will's position; shows neutral sprite #39 when no direction is held.

### RecomputeProjectilePos

Called each steering frame by `GuidedProjectileActor` and the four `ProjectileMove*` routines. Adds the stored spawn offset to Will's current world position so the slider orb maintains its relative placement even while Will animates during charge and release.

### LoadAbilityAnimTableA

Indexes Will's ability animation table (`table_01D9A7`) by the value in A. Resolves the pointer chain and stores a configuration byte to `climbStateData` (`$09E0`) for the engine's sprite and hitbox setup. Called by `PsychoDashMain` and `PsychoSliderMain` to load the correct ability visuals before dispatch.

### LoadAbilityAnimTableB

Freedan equivalent of `LoadAbilityAnimTableA`, indexing `table_01D9BF` and storing the config byte to `$09E2`. Called by Dark Friar trail and fragment actors to configure their sprite sets and hitboxes from Freedan's ability animation data.

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

First trail segment spawned directly behind each Dark Friar fragment (sprite #06, the larger segment). Calls `TrailPositionInit` to seed the position FIFO, then enters the shared follower loop that displays a position lagging three frames behind the parent fragment — the inner ring of the cascading energy trail.

### TrailPositionCascade

Shifts the parent fragment's current XY position through a three-slot FIFO each update cycle. The newest position enters stage 0, older values advance one slot, and the trail actor renders at stage 1 (the oldest buffered value). Called repeatedly from the trail follower loop to produce smooth motion trails without simulating physics.

**Variables:**

| Location | Direction | Role |
|----------|-----------|------|
| `$7F0000,X`–`$7F000E,X` | R/W | 3-frame X position queue |
| `$7F0018,X`–`$7F0004,X` | R/W | 3-frame Y position queue |
| `$0014,Y` / `$0016,Y` | R | Parent actor position |

### TrailPositionInit

Called once when a trail follower actor spawns in `TrailFollowerSprA`/`TrailFollowerSprB`. Seeds all three FIFO stages with the fragment's current position so the trail starts co-located with its parent rather than at the origin, preventing a visible snap on the first frame.

## See Also

- [`player-movement.md`](player-movement.md) — `PlayerMovementTick` (`$02CFD0`), tile collision (`$02E102`)
- [`tile-collision.md`](tile-collision.md) — tile probing for slopes and shimmy
- [`../../cop/index.md`](../../cop/index.md) — COP command semantics
- [`../../actor-organization-analysis.md`](../../actor-organization-analysis.md) — global actor linked list
