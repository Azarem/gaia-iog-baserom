# Attack & Ability System

*Part of the [Bank $02 Documentation Suite](README.md)*

> Special attacks, abilities, and projectile actors for Will and Freedan

**Source:** [`attack_ability_system.asm`](../../../extracted/actors/player/attack_ability_system.asm)
**Related tables:** [`ability_damage_tables.asm`](../../../extracted/tables/ability_damage_tables.asm) (bank `$01`) · [`player_character.asm`](../../../extracted/actors/player/player_character.asm) (`FreezeCameraForAttack`, `UnfreezeCameraAfterAttack`, `PlayerIdleEntry`)

> **Evidence labels.** Each major section is tagged with the kind of claim it makes: **[ASM]** = directly observed in the extracted asm of this block; **[INFERRED]** = interpretation of behavior that is not literally encoded in the file; **[XREF]** = cross-file / engine-wide convention stated elsewhere (not provable from this file alone). Sections that mix kinds split them into separately tagged bullets or paragraphs. The `.asm` files in `extracted/` are authoritative; where prose and asm comments disagree, the asm wins.

> **This ROM's input masks.** The extracted asm already contains this baserom's remapped button masks: [`db-us/transforms.json`](../../../db-us/transforms.json) (`attack_ability_system`) rewrites the vanilla `#$8001` attack mask to `#$0081` and the vanilla `#$40B0` Freedan abort mask to `#$0030`. Bit `$0080` is the *logical* attack bit (physical A here); bit `$0001` of a COP button mask is not a button, it selects `joypadRaw` as the source. Vanilla-ROM mask values must not be assumed.

---

## Overview

*Evidence: [ASM] + [XREF] (input model) + [INFERRED] (explicitly marked)*

**[ASM] Structure.** The attack system is a **companion actor** spawned **before** the movement controller (`SpawnBefore`, per the file header). Its entry label is `AttackSystemEntry` (`$02B7B3`); its idle re-entry label is `code_02B7BD` (`SetEntryHere`). It reads and writes the player actor through `playerActor` (`$09AA`) and hijacks the player actor's entry pointer (`SetPlayerActorFunc`) while an ability runs, until `AttackCleanup` returns the companion to idle.

**[ASM] One dispatch routine serves both forms.** There is no separate top-level entry per form. `AttackSystemEntry` has exactly one attack branch, to `WillAttackDispatch`, and that routine itself selects the form:

```
AttackSystemEntry
  1. one-time, at spawn:  playerFlags & $0008 (combat lock) != 0  ->  COP Die
  2. code_02B7BD:         TRB playerFlags,#$0001   (clear attack-request bit; also the idle/cancel target)
                          COP SetEntryHere
  3. every frame:         playerFlags & $2A00 != 0 -> RTL     (game over / script lock / guard stance)
  4. every frame:         characterForm >= 2       -> RTL     (no attack through this actor)
  5. every frame:         COP BranchIfPressed(#$0081, &WillAttackDispatch)   ; else RTL

WillAttackDispatch                         ; reached for characterForm 0 AND 1
  TSB playerFlags,#$0001                   ; set attack-request bit
  TSB joypadHeld,#$0080                    ; consume the attack bit
  characterForm == 0  -> continue with Will's ability gate (abilityBitmask & $0005)
  characterForm != 0  -> JMP FreedanAttackDispatch  (abilityBitmask & $0050)
```

| `characterForm` (`$0AD4`) | Form | Route actually taken in the asm | Charged abilities (release / L·R) |
|---|---|---|---|
| `0` | Will | `BranchIfPressed` → `WillAttackDispatch`, form test falls through | Psycho Dash / Spin Dash |
| `1` | Freedan | `BranchIfPressed` → `WillAttackDispatch`, then `JMP FreedanAttackDispatch` | Dark Friar / Aura Barrier |
| `2+` | Shadow and others | `RTL` in `AttackSystemEntry` (step 4), the attack button is never tested | — |

**[ASM] Raw vs. consumed input.** The attack test uses mask `$0081`: bit `0` selects **`joypadRaw`** (the remapped physical level, which still reports a button that was consumed through `joypadHeld`), and `$0080` is the logical attack bit. The same raw test (`BranchIfPressed` / `BranchIfNotPressed` with `#$0081`) is used for the hold, the charge and the release tests, so the held button stays visible for the whole flow. `WillAttackDispatch` then marks the attack bit consumed with `TSB $joypadHeld,#$0080`; consumed bits are subtracted from `joypadCurrent` by the joypad routine (see [hardware-and-init.md](hardware-and-init.md)). The L/R tests in this file (`#$0030`, no bit 0) read **`joypadCurrent`**, i.e. they only see a *fresh* L/R press. `SpinDashChargeTick` consumes L/R explicitly through `joypadHeld` so that each decrement needs a new press.

**[ASM] Ability gates test `abilityBitmask` (`$0AA2`).** The bits are event flags `$0510 + characterForm×4 + slot` (file header; the flags the inventory Status tab tests with `TestAbilityFlag`):

| `abilityBitmask` bit | Mask | Ability | Where this file tests it |
|---|---|---|---|
| 0 | `$0001` | Psycho Dash | `WillAttackDispatch`: `BIT #$0005` (bit 0 **or** bit 2 must be set, otherwise `RTL`) |
| 1 | `$0002` | Psycho Slider (Will run attack) | not tested here (handled in `player_character.asm`) |
| 2 | `$0004` | Spin Dash | `WillAttackDispatch`: part of `$0005`; tested alone (`BIT #$0004`) after the charge timer to decide whether L/R may launch Spin Dash |
| 4 | `$0010` | Dark Friar | `FreedanAttackDispatch`: `BIT #$0050` (bit 4 **or** bit 6 must be set, otherwise `RTL`) |
| 5 | `$0020` | Aura Barrier | `FreedanAttackDispatch`: `BIT #$0020` after the charge timer to decide whether L/R/D-pad handling is active |
| 6 | `$0040` | Earthquaker | `FreedanAttackDispatch`: part of `$0050` only |

- **[ASM]** The launch routines (`LaunchPsychoDash`, `LaunchDarkFriar`, …) do not re-test the ability bits. For example, a Will with only bit 2 set passes the gate, and releasing the button fires `LaunchPsychoDash`; a Freedan with only bit 6 set passes the gate and releasing fires `LaunchDarkFriar`.
- **[ASM]** No Earthquaker launch path exists in this file. Bit 6 only opens the gate. The other `extracted/` files that mention Earthquaker are the damage table, string data and `dark_rewards.asm` / `sE6_gaia.asm`.

**[ASM] Hold, charge and release timing.** Both forms share the same three-stage shape:

1. **40-iteration hold** (`COP [LoopStart] ( #28 )`, `$28` hex = 40; `LoopStart`/`LoopEnd` yield once per iteration). Inside the loop the only test is `BranchIfNotPressed(#$0081, &code_02B7BD)`: releasing the attack button cancels back to the idle label. `ValidateAttackContinue` is **not** called during the hold.
2. **Charge timer** in DP `$24`: `$0078` (120) for Will, `$0064` (100) for Freedan. `SavePlayerPosition` runs, the form's charge palette FX actor is spawned (its slot id is stored in DP `$22`), then each frame: `ValidateAttackContinue` (abort → `AttackCleanup`), `BranchIfNotPressed(#$0081, &AttackCleanup)` (**releasing during this stage cancels, no ability fires**), `DEC $24`, `BMI` to the next stage when the counter goes negative (121st / 101st pass). Freedan additionally aborts to `AttackCleanup` if L or R (`#$0030`, `joypadCurrent`) is pressed during this stage.
3. **Selection loop** (after the timer): **release fires the default ability** (`BranchIfNotPressed(#$0081, &LaunchPsychoDash)` for Will, `&LaunchDarkFriar` for Freedan). L/R may select the alternate:
   - Will, bit 2 set: after the release test, `CheckAttackChargeable` must return carry clear, then `BranchIfPressed(#$0030, &LaunchSpinDash)`. Bit 2 clear: release → Psycho Dash is the only exit.
   - Freedan, bit 5 set: after the release test, `BranchIfPressed(#$0F00, &AttackChargeReturn)` (D-pad held → `RTL`, so L/R is not evaluated this frame), then `BranchIfPressed(#$0030, &LaunchAuraBarrier)`. Bit 5 clear: release → Dark Friar is the only exit.

| | Will | Freedan |
|---|---|---|
| Hold | 40 iterations | 40 iterations |
| Charge timer | `$0078` | `$0064` |
| Release before timer ends | `AttackCleanup` (no ability) | `AttackCleanup` (no ability) |
| L/R before timer ends | ignored | abort → `AttackCleanup` |
| Release after timer | Psycho Dash | Dark Friar |
| L/R after timer | Spin Dash (bit 2 + `CheckAttackChargeable`) | Aura Barrier (bit 5, D-pad not held, player stationary) |

**[ASM] Palette FX.** The charge FX actors tint the 15 colors at CGRAM `$81`–`$8F`: `WillAttackPaletteFX` plays bundle `#2A` twice (62 ticks per pass) then `#2B` forever (14 ticks per pass); `FreedanAttackPaletteFX` plays `#4B` twice (50 ticks per pass) then `#2C` forever (16 ticks per pass). `AttackCleanup` kills the actor and restores the colors with the single-frame bundles `#0B` (Will) / `#0C` (Freedan). `AuraBarrierPaletteFX` loops bundle `#5B` (8 colors at CGRAM `$A1`–`$A8`, 16 ticks per cycle).

**[ASM] Ability levels and damage.** `LoadAbilityDamageA/B` do **not** load sprite or hitbox data. Each record in [`ability_damage_tables.asm`](../../../extracted/tables/ability_damage_tables.asm) is `{ word $0000, word pointer to the ability's upgrade-level word, one damage byte per level }`; the loader reads the level from that WRAM word and stores `record[4 + level]` into `climbStateData` (`$09E0`, Will) or `$09E2` (Freedan), the damage bonus that `combat_collision` adds to hit strength (see [LoadAbilityDamageA / B](#loadabilitydamagea)). Level words: `$0B16` Psycho Dash, `$0B18` Psycho Slider, `$0B1A` Spin Dash, `$0B1C` Dark Friar, `$0B1E` Aura Barrier, `$0B20` Earthquaker.

**[INFERRED]** Gameplay-level labels such as "charge-and-launch flow", "Shadow cannot attack" and the player-facing names of abilities come from the file's naming and comments; the asm only shows that form `>= 2` returns before the attack test.

**Related:** [`player-character.md`](player-character.md) · [`../../cop/README.md`](../../cop/README.md)

---

## attack_ability_system.asm

*Evidence: [ASM] (address / name / behavior tables) + [XREF] (COP operand semantics)*

Attack/ability companion actor, spawned before the movement controller via `SpawnBefore`. Addresses are from `db-us/names/bank02.json`. The block has no parts in `blocks.json`; the file's own notes use the decimal ranges `178099–179701` (dispatcher + Freedan abilities), `179702–179825` (trail followers), `179826–179871` (offset helpers), `179872–180391` (Psycho Dash), `180393–180763` (Spin Dash) and `180764–181131` (projectile, palette FX, loaders).

| Address | Name | Description (from the asm) |
|---------|------|-------------|
| `$02B7B3` | AttackSystemEntry | Dies at spawn if `playerFlags` `$0008` is set. Idle label `code_02B7BD` clears `$0001`, then per frame: `$2A00` set → `RTL`; `characterForm >= 2` → `RTL`; `BranchIfPressed(#$0081, &WillAttackDispatch)`. |
| `$02B7DE` | WillAttackDispatch | Sets `$0001` in `playerFlags`, consumes `$0080` in `joypadHeld`, `characterForm != 0` → `JMP FreedanAttackDispatch`. Will: `abilityBitmask & $0005`; 40-iteration hold; `$0078` charge timer; release → Psycho Dash; L/R → Spin Dash. |
| `$02B855` | LaunchPsychoDash | `ValidateAttackReady`, `SetPlayerActorFunc(PsychoDashMain)`, `JMP AttackCleanup`. |
| `$02B861` | LaunchSpinDash | `ValidateAttackReady`, `SetPlayerActorFunc(SpinDashMain)`, `JMP AttackCleanup`. |
| `$02B86D` | FreedanAttackDispatch | `abilityBitmask & $0050`; 40-iteration hold; `$0064` charge timer (L/R aborts); release → Dark Friar; with bit 5, L/R → Aura Barrier. |
| `$02B8D6` | LaunchDarkFriar | Writes `$0001` to `$00EA` (`activeAbilityGfx`, read by `ReloadAbilityFX`), `ValidateAttackReady`, `SetPlayerActorFunc(DarkFriarMain)`, `BRA AttackCleanup`. |
| `$02B8E7` | LaunchAuraBarrier | Returns unless `playerSpeedEw` and `playerSpeedNs` are both zero; writes `$0002` to `$00EA` (`activeAbilityGfx`); `ValidateAttackReady`; `SetPlayerActorFunc(AuraBarrierMain)`; `BRA AttackCleanup`. |
| `$02B901` | AttackCleanup | `MarkDeath` on the actor id in DP `$22` (if any), play palette bundle `#0B` (form 0) or `#0C`, `JumpNextFrame` to `code_02B7BD`. |
| `$02B926` | SetPlayerActorFunc | Writes A to the player actor's `$0000` and zeroes its `$0008` (via `playerActor`). |
| `$02B933` | ValidateAttackReady | `playerFlags & $3A00` or `GetPlayerFacing >= 4` → pop return address, `BRA AttackCleanup`. |
| `$02B946` | ValidateAttackContinue | `playerFlags & $2B00` → same abort path. |
| `$02B94F` | SavePlayerPosition | Copies the player actor's `$14`/`$16` into DP `$14`/`$16`. |
| `$02B95D` | CheckAttackChargeable | Carry set unless `playerFlags` `$8000` is clear **and** the player body animation index at `+$28` is `0`–`3` or `$10`–`$13`. |
| `$02B97F` | AuraBarrierMain | Sets actor `$10` `$0200` (Will ignores enemy contact while the barrier is active; measured: forced on, 120 frames of contact did no damage), `playerFlags` `$0800`; spawns `AuraVramDmaLoader`; waits for the DMA; copies palette; cast pose; spawns `AuraBarrierPaletteFX` and `AuraOrbitalSpawner`. |
| `$02B9FC` | AuraBarrierEnd | Clears actor `$10` `$0200` (Will can be hit again), `RestoreSavedPtr` if `retPtr1` is set, `JMP PlayerIdleEntry`. |
| `$02BA0C` | AuraVramDmaLoader | `AdhocVramDma(misc_fx_1CC480 → VRAM $4400, $0600 bytes)`, `Die`. |
| `$02BA17` | AuraOrbitalSpawner | Spawns 2 (4 if `$0B1E` nonzero) `AuraProjectileChild` actors; orbit loop. |
| `$02BABD` | UpdateOrbitalPositions | Walks the children, `ApplyOrbitalOffsetFromRef` per child. |
| `$02BAFE` | AuraProjectileChild | Metasprite `spriteset_aura`, frames `#00`, `#01`, then loops `#02`. |
| `$02BB29` | AuraProjectileShrink | Frames `#01`, `#00`, sets actor `$10` `$2000`, `SetEntryHere`. |
| `$02BB3B` | DarkFriarMain | Sets `playerFlags` `$2000`; spawns `DarkFriarVramDma`; waits for DMA; palette copy; thinker bundle `#4A`; `SwitchCase` on facing `& 3`. |
| `$02BB93` | DarkFriarDirTable | Switch table: S, N, W, E. |
| `$02BB9B` | DarkFriarSouth | Projectile + `DarkFriarTrailSouth` at (−2, +26); player sprite `#36`. |
| `$02BBB4` | DarkFriarNorth | Projectile + `DarkFriarTrailNorthInit` at (0, −64); player sprite `#37`. |
| `$02BBCD` | DarkFriarWest | Projectile + `DarkFriarTrailWestInit` at (−52, −22); player sprite `#38`. |
| `$02BBE6` | DarkFriarEast | Projectile + `DarkFriarTrailEastWest` at (+52, −22); player sprite `#39`. |
| `$02BBFD` | DarkFriarFinish | `WaitByte #07` (8 ticks), `RestoreSavedPtr`. |
| `$02BC02` | DarkFriarVramDma | `AdhocVramDma(misc_fx_1CC000 → VRAM $4400, $0480 bytes)`, `Die`. |
| `$02BC0D` | DarkFriarProjectile | Metasprite `spriteset_dark_friar`; `WaitByte #07`; un-hides; frame `#00`; `Die`. |
| `$02BC27` | DarkFriarTrailNorthInit | Sets `$2000` in `$12` (negate Y); falls into `DarkFriarTrailSouth`. |
| `$02BC2C` | DarkFriarTrailSouth | Trail growth + travel; collision enabled if `$0B1C` ≠ 0. |
| `$02BC74` | DarkFriarTrailWestInit | Sets `$4000` in `$12` (negate X); falls into `DarkFriarTrailEastWest`. |
| `$02BC79` | DarkFriarTrailEastWest | Same as south trail on the X axis. |
| `$02BCC1` | DarkFriarBounceLoop | Travel loop: off-screen (`$4000` in actor `$10`) → `Die`; level 2 + attack held → `DarkFriarDisableCollide`. |
| `$02BCEE` | DarkFriarDisableCollide | Clears the collide callback, **falls through** into `DarkFriarOnHit`. |
| `$02BCF2` | DarkFriarOnHit | Spawns fragments 1–3, self becomes the fragment at angle `$00`. |
| `$02BD0C` | DarkFriarFragment1 | Angle `$40`. |
| `$02BD11` | DarkFriarFragment2 | Angle `$80`. |
| `$02BD16` | DarkFriarFragment3 | Angle `$C0`; falls into `DarkFriarFragmentInit`. |
| `$02BD19` | DarkFriarFragmentInit | Stores angle, spiral centre, spawns two trail followers, sprite `#04` + hitbox, spiral out. |
| `$02BDC9` | DarkFriarFragmentLoop | Return phase with reversed velocity until off-screen. |
| `$02BDF6` | TrailFollowerSprA | Sprite `#05` + hitbox. |
| `$02BDFB` | TrailFollowerSprB | Sprite `#06` + hitbox. |
| `$02BE1A` | TrailPositionCascade | 3-stage position FIFO step. |
| `$02BE55` | TrailPositionInit | Seeds the 3 stages with the follower's own `$14`/`$16`. |
| `$02BE72` | ComputeParentOffset | Stores (current − actor in DP `$24`) at `$7F100C,X` / `$7F100E,X`. |
| `$02BE89` | ApplyParentOffset | Sets `$14`/`$16` = actor in DP `$24` + stored offset. |
| `$02BEA0` | PsychoDashMain | `LoadAbilityDamageA(0)`, `FreezeCameraForAttack`, `SwitchCase` on facing `& 3`. |
| `$02BEB7` | PsychoDashDirTable | Switch table: S, N, W, E. |
| `$02BEBF` | PsychoDashSouth | `SpawnAfter(PsychoDashTrailSouth)`, body pose `#04`, `StageSpriteMoveY(#04, #36)`. |
| `$02BECF` | PsychoDashNorth | `SpawnAfter(PsychoDashTrailNorth)`, `SetMoveNegateY(#01)`, body pose `#04`, `StageSpriteMoveY(#05, #36)`. |
| `$02BEE2` | PsychoDashWest | `SpawnAfter(PsychoDashTrailWest)`, `SetMoveNegateXY(#01)`, body pose `#04`, `StageSpriteMoveX(#06, #36)`. |
| `$02BEF5` | PsychoDashEast | `SpawnAfter(PsychoDashTrailEast)`, body pose `#04`, `StageSpriteMoveX(#07, #36)`. |
| `$02BF09` | PsychoDashTrailSouth | 8-frame Y-delta record (baseline − current), 8-frame replay in reverse into the parent's `moveScratch2`. |
| `$02BF71` | PsychoDashTrailNorth | Same, delta = current − baseline. |
| `$02BFD9` | PsychoDashTrailWest | X deltas (current − baseline), replay into parent `moveScratch1`. |
| `$02C041` | PsychoDashTrailEast | X deltas (baseline − current), replay into parent `moveScratch1`. |
| `$02C0A9` | SpinDashMain | Sets `playerFlags` `$2002`, charge level `$26 = $0F`, charge loop, guided projectile, launch chain. |
| `$02C17C` | SpinDashRelease | Clears `$2800` in `playerFlags`; returns A = 12 (`$0B1A` = 0) or 24 passes. |
| `$02C199` | SpinDashLaunch | Pass count → `loopCounter`; `LoadAbilityDamageA(1)`; frame `#1D` loop; clears `$0002`; D-pad direction dispatch. |
| `$02C1BE` | SpinDashDirEW | Left (`$0200`) → player sprite `#02`, else `#03`. |
| `$02C1D0` | SpinDashDirNS | Up (`$0800`) → player sprite `#01`, else `#00`. |
| `$02C1E4` | SpinDashAbort | Clears actor `$10` `$0200` (ignore enemy contact, set by `SpinDashMain` while the projectile is guided), `RestoreSavedPtr`. |
| `$02C1EB` | SpinDashChargeTick | One charge-level decrement per fresh L/R press (alternating by parity of `$26`). |
| `$02C21C` | KillSpawnedProjectile | `MarkDeath` on the actor id in `orbitDiameter,X` (then zeroes it). |
| `$02C232` | GuidedProjectileActor | Priority `#30`, metasprite `spriteset_pickups_effects`, D-pad steering with sprites `#3A`–`#3D`, neutral `#39`. |
| `$02C288` | ProjectileMoveRight | Sprite `#3D`. |
| `$02C2A8` | ProjectileMoveLeft | Sprite `#3C`. |
| `$02C2C8` | ProjectileMoveUp | Sprite `#3B`. |
| `$02C2E8` | ProjectileMoveDown | Sprite `#3A`. |
| `$02C308` | WillAttackPaletteFX | Bundle `#2A` ×2, then `#2B` forever. |
| `$02C315` | FreedanAttackPaletteFX | Bundle `#4B` ×2, then `#2C` forever. |
| `$02C322` | AuraBarrierPaletteFX | Bundle `#5B` forever. |
| `$02C329` | RecomputeProjectilePos | `$14`/`$16` = player position + stored `$7F100C/E,X` offset. |
| `$02C33E` | LoadAbilityDamageA | Will: `will_ability_damage_table` → `climbStateData` (`$09E0`). |
| `$02C365` | LoadAbilityDamageB | Freedan: `freedan_ability_damage_table` → `$09E2`. |

### Attack Dispatch & Entry

*Evidence: [ASM]*

#### AttackSystemEntry

Companion actor entry point; runs every frame before the movement controller.

- The combat-lock test (`playerFlags & $0008`) is a **one-time** check before `SetEntryHere`: if set, `COP [Die]` removes the companion. The asm comments identify `$0008` as the combat lock set at spawn in non-combat scenes (see [wram-memory-map.md](../../wram-memory-map.md) §Player Flags Reference). A script that sets `$0008` later does not remove this actor; it only disables the attack button elsewhere.
- `code_02B7BD` clears the **attack-request bit** `$0001` in `playerFlags`. This is the idle label that cancel paths and `AttackCleanup` jump back to, so the bit is cleared again every time the flow returns here.
- Per frame: `playerFlags & $2A00` (bits 9, 11, 13: game over, script/ability lock, guard/channel stance) → `RTL`; `characterForm >= 2` → `RTL`; otherwise the single `BranchIfPressed(#$0081, &WillAttackDispatch)`.

| Symbol | Relationship |
|--------|-------------|
| `WillAttackDispatch` | Only branch target of the attack test, for form 0 **and** form 1 |
| `FreedanAttackDispatch` | Reached by `JMP` from `WillAttackDispatch` when `characterForm != 0` |
| `SetPlayerActorFunc` | Hijacks the player actor's function pointer |

#### WillAttackDispatch

Shared dispatch body. Sets `playerFlags` `$0001`, consumes the attack bit in `joypadHeld` (`TSB #$0080`), and branches on `characterForm`: nonzero jumps to `FreedanAttackDispatch`; zero tests `abilityBitmask & $0005` (return if neither Psycho Dash nor Spin Dash is unlocked), runs the 40-iteration hold (release → idle label), spawns `WillAttackPaletteFX` (id kept in DP `$22`), loads the `$0078` timer and loops with `ValidateAttackContinue` / release → `AttackCleanup` / `DEC $24`.

After the timer, `abilityBitmask & $0004` selects between the two exits described in the Overview: bit 2 clear → release launches Psycho Dash; bit 2 set → release launches Psycho Dash, and (when `CheckAttackChargeable` returns carry clear) a fresh L or R press launches Spin Dash.

Inferred: the early `RTL` on a locked ability leaves `$0001` set and the attack bit consumed; whether that has a visible effect depends on other readers of those bits.

#### FreedanAttackDispatch

Reached from `WillAttackDispatch` by `JMP`. Tests `abilityBitmask & $0050`, runs the same 40-iteration hold, spawns `FreedanAttackPaletteFX`, loads the `$0064` timer. During the timer a fresh L or R press (`#$0030` in this ROM; the vanilla mask also listed the Y and A face bits) aborts to `AttackCleanup`. After the timer: bit 5 clear → release launches Dark Friar; bit 5 set → release launches Dark Friar, a held D-pad direction (`#$0F00`) returns without evaluating L/R (`AttackChargeReturn` is a bare `RTL`), and a fresh L/R launches Aura Barrier (which itself returns unless both speed words are zero).

#### AttackCleanup

Tail-jumped to (`JMP`/`BRA`) by every launch routine, branched to by the release/abort tests, and entered by `ValidateAttackReady` / `ValidateAttackContinue` on abort. It saves `X` and `D`, calls `MarkDeath` on the FX actor whose slot id is in DP `$22` (skipped if zero), restores them, plays palette bundle `#0B` (Will) or `#0C` (Freedan) for one frame (restoring the 15 colors at CGRAM `$81`–`$8F`), and `JumpNextFrame`s to `code_02B7BD`.

### Attack Validation Helpers

*Evidence: [ASM]*

#### ValidateAttackReady

Called by the four `Launch*` routines before hijacking the player actor. If `playerFlags & $3A00` is nonzero (bit 9 game over, bit 11 script/ability lock, bit 12 on a slope/ramp, bit 13 guard/channel stance) or `GetPlayerFacing` returns `>= 4`, it pops its own return address (`PLA`) and `BRA`s to `AttackCleanup`, so the caller's remaining instructions do not run.

#### ValidateAttackContinue

Per-frame check during the charge stages: `playerFlags & $2B00` (bit 8 forced walk, bit 9 game over, bit 11 script lock, bit 13 guard stance) → same abort path as above.

#### CheckAttackChargeable

Carry set means "not now"; carry clear means an L/R press may launch the alternate ability. Carry is set when `playerFlags` `$8000` is set (the body sprite was overridden through `SetPlayerSpriteDirect`), when the player actor's animation index at `+$28` is negative, or when that index is neither `0`–`3` nor `$10`–`$13`. Only the Will dispatch calls it (and only when bit 2 is set).

Inferred: the file's comments describe this as protection against charging during hit-stun, special animations or mid-combo; the code itself only tests the three conditions above.

### Aura Barrier Orbitals

*Evidence: [ASM]*

#### AuraBarrierMain

Player-actor entry after `LaunchAuraBarrier`. Sets actor `$10` `$0200` (**ignore enemy contact**: `CombatCollision_InnerLoop` skips the actor under mask `$76E0`, so the barrier makes Will immune to contact while it is active) and `playerFlags` `$0800` (script/ability lock), spawns `AuraVramDmaLoader`, and exits to `AuraBarrierEnd` if the spawn returned the pool-exhausted sentinel `Y = $1FC0`. It then waits until the adhoc VRAM DMA destination (`$7F0C07`) is no longer `$4400` (a bounded 8-iteration wait if the actor's Y word `$16` is `$0020`, an unbounded per-frame wait otherwise), copies 7 palette words from `fx_palette_198090` to CGRAM `$A9`, sets body sprite `#06`, plays the cast frames, spawns `AuraBarrierPaletteFX` (id stored in `orbitDiameter,X`), plays sprite `#03` twice, **clears the attack-request bit `$0001`** in `playerFlags`, spawns `AuraOrbitalSpawner` at offset (0, −16), plays sprite `#03` ten times and calls `KillSpawnedProjectile` (which kills the palette FX actor). Control then falls into `AuraBarrierEnd`.

#### AuraOrbitalSpawner

Spawns `AuraProjectileChild` actors with `SpawnAfterMarked`: two always, plus two more first if `$0B1E` is nonzero (the DP `$24` child counter ends as *count − 1* and is used as a `BPL` loop bound later). Per-frame loop: if `playerFlags` `$0001` is set, jump to the shrink phase; otherwise add 2 to the orbit angle (`AND #$00FF`), grow `orbitDiameter` by 1 until it reaches `$40`, call `UpdateOrbitalPositions`, and `DEC` the lifetime counter (`$00F0` = 240 frames); when that goes negative the shrink phase starts. The shrink phase rewrites each child's function pointer to `AuraProjectileShrink` (walking the list from DP `$06`), then runs a 30-iteration loop (`LoopStart #1E`) that keeps rotating and decrements the diameter by 1 per iteration (stopping at 0), then `Die`.

- **[ASM]** `$40` is a diameter value, not pixels: the asm comment states that `ApplyOrbitalOffsetFromRef` scales a sine/cosine (max `$7F`) by it and keeps the high byte, so the visible radius is about 32 px. The diameter reaches `$40` after about 64 frames; the remaining frames of the 240 keep orbiting at that size.
- **[ASM]** The spawner reads `playerFlags` `$0001` for the early shrink, and `AuraBarrierMain` clears that bit before spawning the spawner (per its comment so that a later attack press can start the early shrink). The companion's own idle path returns early while `playerFlags` `$0800` (set by `AuraBarrierMain`) is set, so which code sets `$0001` during the orbit is not shown in this file. Inferred: the early shrink is therefore only reachable through some other writer of `$0001`; this has not been traced.

#### UpdateOrbitalPositions

Called every frame during the expand/hold and shrink phases. Walks the child list (child count − 1 in the absolute scratch word WRAM `$0000`, starting at DP `$06`), switches `D` to each child, calls `ApplyOrbitalOffsetFromRef` with `Y = playerActor`, then advances that child's `orbitAngle` by the current spacing. The spacing (absolute scratch word WRAM `$0002`) starts at `$0080` and toggles between `$0080` and `$0040` after every child, producing 180° steps for two orbitals and alternating 180°/90° steps across four.

#### AuraProjectileChild

Metasprite `spriteset_aura`; plays frames `#00` and `#01` once each (`AnimOnce`), then loops frame `#02` indefinitely. In scene `$DD` it replaces the priority bits of actor flag word `$0E` (`AND #$CFFF`, `ORA #$2000`). `artifacts/scenes.json` names scene `$DD` `mummy_queen_lair`; the asm comment on that code calls it "Dark Space visibility", so the comment and the scene table disagree.

`AuraProjectileShrink` (second entry in the same block) plays frames `#01` then `#00`, sets bit 13 (`$2000`) of actor `$10` (hidden for the depth sort and script-only), and re-arms with `SetEntryHere`; the spawner's `COP Die` removes the children (`SpawnAfterMarked`).

### Dark Friar Chain

*Evidence: [ASM]*

#### DarkFriarMain

Reached from `LaunchDarkFriar`. Sets `playerFlags` `$2000` (guard/channel stance), spawns `DarkFriarVramDma`, applies the same bounded/unbounded DMA wait as `AuraBarrierMain`, copies 16 palette words from `fx_palette_198070` to CGRAM `$A0`, spawns the palette-reset thinker with bundle `#4A` (a white flash on CGRAM `$81`–`$8F` fading to Freedan's colors in 36 ticks; it runs at the cast, not at the end of the ability), and `SwitchCase`s on `GetPlayerFacing & 3` through `DarkFriarDirTable` (0 = S, 1 = N, 2 = W, 3 = E). Each direction spawns the projectile and the trail at its offset, plays the matching player sprite (`#36`–`#39`) once, and ends in `DarkFriarFinish` (`WaitByte #07`, which the asm comment counts as 8 actor ticks, then `RestoreSavedPtr`).

| Direction | Spawn offset (X, Y) | Trail entry | Player sprite |
|---|---|---|---|
| South | (−2, +26) | `DarkFriarTrailSouth` | `#36` |
| North | (0, −64) | `DarkFriarTrailNorthInit` | `#37` |
| West | (−52, −22) | `DarkFriarTrailWestInit` | `#38` |
| East | (+52, −22) | `DarkFriarTrailEastWest` | `#39` |

**`$00EA` (`activeAbilityGfx`).** `LaunchDarkFriar` writes `1` and `LaunchAuraBarrier` writes `2` to `$00EA`; nothing in this file clears it. **[XREF]** `ReloadAbilityFX` in [`inventory_overlay.asm`](../../../extracted/system/inventory/inventory_overlay.asm) reads it after the inventory scene closes (`0` = nothing; `1` = re-DMA `misc_fx_1CC000` and palette `fx_palette_198070`; `2+` = `misc_fx_1CC480` and `fx_palette_198090`, the same assets the two `*VramDma` loaders upload here), and `scene_lifecycle.asm` (scene setup) zeroes it.

#### DarkFriarProjectile

Metasprite `spriteset_dark_friar`. It calls `ComputeParentOffset`, waits `WaitByte #07` (8 ticks), calls `ApplyParentOffset`, clears the hidden bit (`$2000` of actor `$10`), plays frame `#00` once and dies. It carries no movement or collision setup; the damaging/travelling actor is the trail spawned next to it.

#### DarkFriarTrailSouth / DarkFriarTrailEastWest

`DarkFriarTrailNorthInit` ORs `$2000` into `$12` (negate-Y) and falls into `DarkFriarTrailSouth`; `DarkFriarTrailWestInit` ORs `$4000` into `$12` (negate-X) and falls into `DarkFriarTrailEastWest`. Both trail bodies: call `LoadAbilityDamageB(0)`, set the metasprite, optionally drop sprite priority to `#30` if `playerFlags` `$0080` is set (the asm notes no shipped scene sets it), `ComputeParentOffset`, `WaitByte #07`, `ApplyParentOffset`, un-hide, then **if `$0B1C` is nonzero** `OrExtraFlags(#$0010)` and `SetCollideCallback(&DarkFriarOnHit)`. They stage two growth loops (sprite `#01` ×2 with movement index 1, sprite `#02` ×3 with index 3), sprite `#03` with hitbox, and `StageMoveXY` with movement index **5 on the travel axis** (south/north: `(#00, #05)`; east/west: `(#05, #00)`), then join `DarkFriarBounceLoop` at `loc_02BCCA`.

Movement operands are indices into `move_chain_table`, not distances: index 1/3/5/7 = constant +1/+2/+3/+4 per frame, 2/4/6 = the negatives (see the file conventions block). So the trail keeps travelling at **+3 per frame** on its axis (negated by the `$12` bits for north/west).

#### DarkFriarBounceLoop

Per frame: if actor `$10` bit 14 (`$4000`) is set → `Die`; otherwise `ReloadMoveChains`, `AnimOneFrame`, and (when the frame was staged) hold-time loop. `$4000` in actor `$10` is the **off-screen flag kept by the depth sort**, not a wall-contact flag. In the hold-time loop, if `$0B1C == 2` and `BranchIfPressed(#$0081, &DarkFriarDisableCollide)` (attack held, `joypadRaw`) the trail is detonated.

#### DarkFriarDisableCollide / DarkFriarOnHit

`DarkFriarDisableCollide` clears the collide callback and **falls through** (no branch, no return) into `DarkFriarOnHit`. So the two ways to reach the fragment burst are (a) an enemy contact on a trail whose callback was set (`$0B1C` ≠ 0), and (b) at `$0B1C == 2`, holding attack while the trail travels; (b) removes the callback first so it cannot fire twice.

`DarkFriarOnHit` spawns `DarkFriarFragment1`–`3` with `SpawnAfterFlags` and turns the current actor into the fourth fragment with angle `$00`. Fragment start angles are `$00`, `$40`, `$80`, `$C0` in the engine's 256-unit-per-turn angle byte (0°, 90°, 180°, 270°).

#### DarkFriarFragmentInit

Shared by all four. Stores the start angle in `orbitAngle,X`, calls `LoadAbilityDamageB(0)`, zeroes `orbitDiameter`, saves the current position as the spiral centre in `moveXAlt`/`moveYAlt`, spawns `TrailFollowerSprB` then `TrailFollowerSprA`, seeds the stored velocity words `$7F100C/E,X` with 1, and stages sprite `#04` with hitbox. Each frame it adds 2 to the angle and 4 to the diameter byte; when the diameter byte carries over it clears `$6000` in `$12`, negates both stored velocities and continues in the shared `loc_02BDD7` return step. The stored velocity (old position minus the new spiral position) is copied to `moveScratch1`/`moveScratch2` each frame.

#### DarkFriarFragmentLoop

Return phase: copies `$7F100C/E,X` to `moveScratch1`/`moveScratch2` every frame until actor `$10` bit 14 (`$4000`, off-screen) is set, then `Die`.

Inferred: the asm comments describe the visual result as a four-way burst that spirals out and ricochets back; the file contains the angle, diameter and velocity arithmetic above but no wall test.

### Parent Offset Helpers

*Evidence: [ASM]*

#### ComputeParentOffset

Reads the actor slot in DP `$24` (stored there by `CopyActorState`, per the file notes) and stores `current − actor` at `$7F100C,X` (X) and `$7F100E,X` (Y). Used by `DarkFriarProjectile` and both trail bodies.

#### ApplyParentOffset

Sets DP `$14`/`$16` to the actor in DP `$24` plus the stored offset. Called after the `WaitByte #07` delay so the child lands at the original relative position even if the player moved.

### Psycho Dash Trails

*Evidence: [ASM] + [INFERRED] (marked)*

#### PsychoDashMain and the directional handlers

`PsychoDashMain` calls `LoadAbilityDamageA(0)` (stores the Psycho Dash damage bonus; not an animation table) and `FreezeCameraForAttack` (in `player_character.asm`: clears actor `$10` `$0100` and sets `layerPriorityFlag` `$0200`, which stops `camera_scroll_controller`; the call-site comment in this file saying "disable status display" is stale), then switches on `GetPlayerFacing & 3`. Each handler spawns its trail actor with `SpawnAfter`, sets body pose `#04` with `SetPlayerSpriteDirect`, stages a movement with **index `$36`** and plays it once, then `loc_02BF03` calls `UnfreezeCameraAfterAttack` and jumps to `PlayerIdleEntry`.

| Facing | Negate op | Staged movement `(sprite, index)` |
|---|---|---|
| South | — | `StageSpriteMoveY(#04, #36)` |
| North | `SetMoveNegateY(#01)` | `StageSpriteMoveY(#05, #36)` |
| West | `SetMoveNegateXY(#01)` | `StageSpriteMoveX(#06, #36)` |
| East | — | `StageSpriteMoveX(#07, #36)` |

`$36` is a **movement-chain index, not a distance**: per the file notes it is 8 frames of 0, then 4, 4, 7, 7, 9, 9, 12, 12, then 0, 0, then eight frames of −8. (`$36` hex = 54 decimal is not a 54-pixel distance.)

#### PsychoDashTrailSouth / North / West / East

Each trail actor works on the actor in DP `$04` (the previous list entry, the player, because the trail was `SpawnAfter`'d). Recording: DP `$08` is set to 6, the baseline coordinate is read, then an 8-iteration `LoopStart` loop stores one delta per iteration at `$09D0,…` (2 bytes per entry). Playback: `$08` is set to 3, the parent's `moveScratch2` (south/north, `$002E`) or `moveScratch1` (west/east, `$002C`) is zeroed, then an 8-iteration loop reads the buffer **backwards** and writes each entry into that scratch word; a final frame writes 0 and the actor dies.

| Trail | Axis / scratch word | Delta recorded |
|---|---|---|
| South | Y → `moveScratch2` | baseline − current |
| North | Y → `moveScratch2` | current − baseline |
| West | X → `moveScratch1` | current − baseline |
| East | X → `moveScratch1` | baseline − current |

- **[ASM]** The trail actors contain no sprite or metasprite staging; they only record and replay movement deltas into the parent's movement scratch.
- **[INFERRED]** Earlier prose called these a "ghost afterimage". The file does not show a visual: the observable effect of the replay is a reversed movement impulse written to the player's own scratch word. The "half speed" wording is also unsupported: `$08` is set to 6 before recording and 3 before playback, and the asm comments call that "frames per segment" without the loops themselves depending on it.

### Spin Dash

*Evidence: [ASM]*

#### SpinDashMain

Reached from `LaunchSpinDash`. Consumes the attack bit (`TSB joypadHeld,#$0080`), sets `playerFlags` `$2002` (bit 1 plus the guard/channel stance), sets the charge level `$26 = $000F` (also copied to `orbitAngle,X`), body pose `#04`, sprite `#22` with hitbox, and loops on `AnimOneFrame`. Per staged frame:

- actor `$10` bit 7 (`$0080`, the **hit/iframe marker**, not a wall flag) set → `SpinDashAbort`;
- charge level `$26` negative or below `$0C` → leave the charge phase;
- otherwise `$24 = $26 >> 1`, then a re-entry loop: attack released (`BranchIfNotPressed(#$0081, &SpinDashAbort)`) aborts; otherwise `SpinDashChargeTick` runs once and `$24` is decremented.

Leaving the charge phase: `LoadAbilityDamageA(2)`, clear actor `$0100`, set actor `$0200`, spawn `GuidedProjectileActor` (flags `$0302`; id kept in `orbitDiameter,X`), play frame `#1C` once and frame `#1D` four times, `KillSpawnedProjectile`, then `PEA SpinDashRelease-1`, zero both speed words, and set `playerSpeedEw`/`playerSpeedNs` to ±7 (`$0007` / `$FFF9`) from the first of Right (`$0100`), Left (`$0200`), Up (`$0800`), Down (`$0400`) found in `joypadCurrent` (clearing `slopeStepCounter` and `decelStepCounter`), and `RTS` into `SpinDashRelease`.

#### SpinDashChargeTick

Starts at `$26 = $0F`. If `$26` is **odd**, a fresh L press (`$0020` in `joypadCurrent`) decrements it; if **even**, a fresh R press (`$0010`). Afterwards it ORs the current L/R bits (`joypadCurrent & $0030`) into `joypadHeld` so they are consumed. The sequence L, R, L, R takes `$0F` to `$0B`; once `$26 < $0C` `SpinDashMain` leaves the charge phase. The odd/even test is on the **charge level**, not on the frame number.

#### SpinDashRelease / SpinDashLaunch

`SpinDashRelease` clears `$2800` in `playerFlags` (bit 13 was set by `SpinDashMain`; bit 11 was not), pushes `SpinDashLaunch-1`, stores `SpinDashLaunchLoop` in `retPtr2,X`, and returns **12** in A (or **24** if `$0B1A`, the Spin Dash level word, is nonzero) as the pass count. `SpinDashLaunch` stores that count in `loopCounter,X`, calls `LoadAbilityDamageA(1)`, and at `SpinDashLaunchLoop` plays frame `#1D` once per pass (`LoopEnd`). It then clears `$0002` in `playerFlags` and branches on `joypadCurrent`: `$0300` (left/right) → `SpinDashDirEW`, `$0C00` (up/down) → `SpinDashDirNS`, otherwise `SpinDashAbort`.

#### SpinDashDirEW / SpinDashDirNS / SpinDashAbort

`SpinDashDirEW`: left (`$0200`) → player sprite `#02`, otherwise `#03`. `SpinDashDirNS`: up (`$0800`) → `#01`, otherwise `#00`. Both play one frame and fall into `SpinDashAbort`, which clears actor `$10` `$0200` (end of "ignore enemy contact") and runs `RestoreSavedPtr`.

### Guided Projectile & Palette FX

*Evidence: [ASM]*

#### GuidedProjectileActor

Priority `#30`, metasprite `spriteset_pickups_effects`. At spawn it stores `(projectile − player)` at `$7F100C/E,X`. It dispatches on `joypadCurrent` (via `BranchIfPressed` masks `$0100` right → `ProjectileMoveRight`, `$0200` left, `$0800` up, `$0400` down); with no direction it stages neutral sprite `#39` with hitbox and loops. Each steering frame calls `RecomputeProjectilePos`. The four `ProjectileMove*` routines stage sprite `#3D` (right), `#3C` (left), `#3B` (up), `#3A` (down) with hitbox and return to the neutral dispatch (`code_02C24E`) when their direction is released.

#### RecomputeProjectilePos

Sets DP `$14`/`$16` to the player position plus the stored `$7F100C/E,X` offset.

#### LoadAbilityDamageA / B

`LoadAbilityDamageA` (Will, `will_ability_damage_table` at ROM `121255`) and `LoadAbilityDamageB` (Freedan, `freedan_ability_damage_table` at `121279`) take the ability index in A, follow the table pointer to the record, read the level from the WRAM word the record points to, and store `record[4 + level]` in `climbStateData` (`$09E0`, Will) or `$09E2` (Freedan). Values by level:

| Index | Will | Level word | Damage by level | Freedan | Level word | Damage by level |
|---|---|---|---|---|---|---|
| 0 | Psycho Dash | `$0B16` | 5 / 10 | Dark Friar | `$0B1C` | 5 / 8 / 12 |
| 1 | Psycho Slider | `$0B18` | 5 / 8 | Aura Barrier | `$0B1E` | 5 / 9 |
| 2 | Spin Dash | `$0B1A` | 4 / 7 | Earthquaker | `$0B20` | 0 / 7 |

`PsychoDashMain` calls it with 0, `SpinDashMain` with 2, `SpinDashLaunch` with 1 (the Psycho Slider entry). Freedan's trails and fragments call `LoadAbilityDamageB(0)`. Convention (other file): `combat_collision` adds these bytes to hit strength (`ability_damage_tables.asm` header). The old names `table_01D9A7` / `table_01D9BF` and the description "animation table" are stale.

#### Attack Trail Followers

*Evidence: [ASM]*

Dark Friar fragment trail followers and the 3-stage position FIFO, at ROM `$02BDF6`–`$02BE72` in [`attack_ability_system.asm`](../../../extracted/actors/player/attack_ability_system.asm).

| Address | Name | Description |
|---------|------|-------------|
| `$02BDF6` | TrailFollowerSprA | Sprite `#05` + hitbox, then the shared follower loop (`loc_02BDFE`). |
| `$02BDFB` | TrailFollowerSprB | Sprite `#06` + hitbox, then the shared loop. |
| `$02BE1A` | TrailPositionCascade | One FIFO step. |
| `$02BE55` | TrailPositionInit | Seeds the 3 stages with the follower's own `$14`/`$16`. |
| `$02BE72` | ComputeParentOffset | See above. |
| `$02BE89` | ApplyParentOffset | See above. |

The position source is **the actor in DP `$04`** (the previous list entry: the actor the follower was inserted after), not a stored parent id. `DarkFriarFragmentInit` spawns B first and A second, so **A sits directly behind the fragment and lags it by 3 frames; B follows A and lags the fragment by about 6** (file notes).

#### TrailPositionCascade

Per call (with `Y` = the source actor, loaded from DP `$04` by the loop): the **oldest** stage is copied to DP `$14`/`$16` (the follower's displayed position) first, the other two stages shift forward, and the source actor's current `$0014,Y`/`$0016,Y` is written into the newest stage.

| Queue | Stage 1 (oldest, displayed) | Stage 2 | Stage 3 (newest) |
|---|---|---|---|
| X | `animScratch` (`$7F0000,X`) | `animScratch+2` (`$7F0002,X`) | `animScratch2` (`$7F000E,X`) |
| Y | `moveXAlt` (`$7F0018,X`) | `moveYAlt` (`$7F001A,X`) | `retPtr1` (`$7F0004,X`) |

#### TrailPositionInit

Called once from the shared follower entry (`loc_02BDFE`) of both followers. Writes the follower's own `$14` into all three X stages and `$16` into all three Y stages, so the trail starts co-located rather than at `(0, 0)`.

Inferred: the "cascading afterimage" and "inner/outer ring" wording used in the asm comments is a visual interpretation; the code only shows the two sprites, their hitboxes and the delayed positions.

## See Also

*Evidence: [XREF]*

- [`player-movement.md`](player-movement.md) — `PlayerMovementTick` (`$02CFD0`), tile collision (`$02E102`)
- [`tile-collision.md`](tile-collision.md) — tile probing for slopes and shimmy
- [`camera-scrolling.md`](camera-scrolling.md) — `layerPriorityFlag` `$0200` camera freeze used by `FreezeCameraForAttack`
- [`../../cop/README.md`](../../cop/README.md) — COP command semantics
- [`../../actor-organization-analysis.md`](../../actor-organization-analysis.md) — global actor linked list
