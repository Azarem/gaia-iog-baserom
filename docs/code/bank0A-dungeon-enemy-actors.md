# Bank $0A — Dungeon Enemy & Puzzle Actors

> ROM bank `$0A` (`$0A8000`–`$0AFFFF`, 32,768 bytes) contains **enemy and puzzle
> actor definitions spanning five major dungeon regions and two late-game areas**.
> This is a dense actor bank — nearly every block is an `actor-def` for a dungeon
> enemy, boss, puzzle element, or environmental hazard. The bank covers enemies
> from Edward Castle's underground aqueduct through to the Mu vampire boss fight.
>
> The bank holds **114 mapped pieces** across 64 parent blocks and 9 scene
> clusters. Coverage is **98.1%** mapped.

---

## 1. Coverage Summary

| Metric | Value |
|--------|-------|
| Bank range | `$0A8000`–`$0AFFFF` (688,128–720,895) |
| Total bank size | 32,768 bytes |
| Mapped | 32,135 bytes (98.1%) |
| Unmapped tail | 633 bytes at `$0AFD87`–`$0AFFFF` |
| Parent blocks | 64 distinct blocks in `blocks.json` |
| Total pieces | 114 |
| Piece types | 61 × `actor-def`, 43 × `Code`, 3 × `screen-pos`, 2 × `Binary`, 2 × `Word`, 1 × `DialogString`, 1 × `conveyor-index`, 1 × `conveyor-zone` |
| Named scenes | 11 distinct scene tags |
| All blocks movable | Yes (every block has `movable: true`) |

---

## 2. Scene Group Summary

| Scene Group | Bytes | % of Bank | Blocks | Primary Content |
|-------------|-------|-----------|--------|-----------------|
| Sky Garden | 9,912 | 30.2% | 11 | Cyber, Knight Armor, Dynapede, Nitropede, Plasma Snake, Viper boss |
| Incan Ruins | 6,426 | 19.6% | 13 | Mudpit, Four Way, Slugger, Scuttlebug, Stone Guard/Lord, Castoth boss |
| Mu | 5,026 | 15.3% | 4 | Cyclops, Flasher, Plasma Chain, Male/Female Vampire boss |
| Diamond Mine | 4,360 | 13.3% | 8 | Laborer NPCs, Flayzer, Grundit, Eye Stalker, elevator, breakable walls |
| Edward Castle (Aqueduct) | 2,688 | 8.2% | 11 | Canal Worm, Ribber, Skull Chaser, King Bat, Bat, Spear, switches, barriers |
| Angel Village | 1,834 | 5.6% | 4 | Steelbones, Dive Bat, Draco, Ramskull |
| Seaside Palace | 1,255 | 3.8% | 2 | Slipper, Skuddle |
| Babel Tower / Mansion | 201 | 0.6% | 1 | Solid Arm conveyor zone actor |
| Shared / Utility | 433 | 1.3% | 10 | Common subroutines, unreferenced stubs |

---

## 3. Memory Map

### 3.1 Full Address Map

| Address | End | Size | Block / Part | Type | Scene Group |
|---------|-----|------|--------------|------|-------------|
| `$0A8000` | `$0A826C` | 620 | `ec0D_canal_worm` | actor-def | Edward Castle |
| `$0A826C` | `$0A8476` | 522 | `ec0C_ribber` | actor-def | Edward Castle |
| `$0A8476` | `$0A85F7` | 385 | `ec12_skull_chaser` | actor-def | Edward Castle |
| `$0A85F7` | `$0A8755` | 350 | `ec0F_king_bat` | actor-def | Edward Castle |
| `$0A8755` | `$0A87C3` | 110 | `ec0C_bat` | actor-def | Edward Castle |
| `$0A87C3` | `$0A8835` | 114 | `ec0F_spear` | actor-def | Edward Castle |
| `$0A8835` | `$0A8896` | 97 | `ec0E_statue` | actor-def | Edward Castle |
| `$0A8896` | `$0A88DE` | 72 | `ir26_statue` | actor-def | Incan Ruins |
| `$0A88DE` | `$0A8931` | 83 | `ir20_statue` | actor-def | Incan Ruins |
| `$0A8931` | `$0A8971` | 64 | `ec0E_switch` | actor-def | Edward Castle |
| `$0A8971` | `$0A89DE` | 109 | `ec0F_rusty_switch` | actor-def | Edward Castle |
| `$0A89DE` | `$0A8AAE` | 208 | `ec0E_barrier` | actor-def | Edward Castle |
| `$0A8AAE` | `$0A8B1B` | 109 | `ec0E_spiney` | actor-def | Edward Castle |
| `$0A8B1B` | `$0A8C70` | 341 | `ir1D_mudpit` | actor-def | Incan Ruins |
| `$0A8C70` | `$0A8DB7` | 327 | `ir1D_four_way` | actor-def | Incan Ruins |
| `$0A8DB7` | `$0A8EB6` | 255 | `ir1B_slugger` | actor-def | Incan Ruins |
| `$0A8EB6` | `$0A9026` | 368 | `ir1D_scuttlebug` | actor-def | Incan Ruins |
| `$0A9026` | `$0A9061` | 59 | `ir21_switch` | actor-def | Incan Ruins |
| `$0A9061` | `$0A9066` | 5 | `ir1F_stone_guard` / `ir1F_stone_guard1` | actor-def | Incan Ruins |
| `$0A9066` | `$0A906B` | 5 | `ir1F_stone_guard` / `ir1F_stone_guard2` | actor-def | Incan Ruins |
| `$0A906B` | `$0A9070` | 5 | `ir1F_stone_guard` / `ir1F_stone_guard3` | actor-def | Incan Ruins |
| `$0A9070` | `$0A9101` | 145 | `ir1F_stone_guard` / `ir1F_stone_guard4` | actor-def | Incan Ruins |
| `$0A9101` | `$0A95B3` | 1,202 | `ir1F_stone_guard` / `ir1F_stone_guard5` | actor-def | Incan Ruins |
| `$0A95B3` | `$0A97EE` | 571 | `ir1F_stone_lord` | actor-def | Incan Ruins |
| `$0A97EE` | `$0A98BC` | 206 | `ir21_splop` | actor-def | Incan Ruins |
| `$0A98BC` | `$0A99C3` | 263 | `ir21_whirligig` | actor-def | Incan Ruins |
| `$0A99C3` | `$0A99D7` | 20 | `ir21_frozen_whirligig` | actor-def | Incan Ruins |
| `$0A99D7` | `$0A9B03` | 300 | `ir29_castoth` / `btF2_neo_castoth` | actor-def | Incan Ruins |
| `$0A9B03` | `$0A9BC2` | 191 | `ir29_castoth` / `ir29_castoth` | actor-def | Incan Ruins |
| `$0A9BC2` | `$0A9C0F` | 77 | `ir29_castoth` / `func_0A9BC2` | Code | Incan Ruins |
| `$0A9C0F` | `$0A9C17` | 8 | `ir29_castoth` / `binary_0A9C0F` | Binary | Incan Ruins |
| `$0A9C17` | `$0A9C1E` | 7 | `ir29_castoth` / `func_0A9C17` | Code | Incan Ruins |
| `$0A9C1E` | `$0A9CB2` | 148 | `ir29_castoth` / `func_0A9C1E` | Code | Incan Ruins |
| `$0A9CB2` | `$0A9CFE` | 76 | `ir29_castoth` / `func_0A9CB2` | Code | Incan Ruins |
| `$0A9CFE` | `$0A9D25` | 39 | `ir29_castoth` / `sub_0A9CFE` | Code | Incan Ruins |
| `$0A9D25` | `$0A9EA3` | 382 | `ir29_castoth` / `func_0A9D25` | Code | Incan Ruins |
| `$0A9EA3` | `$0A9EBB` | 24 | `ir29_castoth` / `array_0A9EA3` | screen-pos | Incan Ruins |
| `$0A9EBB` | `$0A9ED3` | 24 | `ir29_castoth` / `array_0A9EBB` | screen-pos | Incan Ruins |
| `$0A9ED3` | `$0A9EEB` | 24 | `ir29_castoth` / `array_0A9ED3` | screen-pos | Incan Ruins |
| `$0A9EEB` | `$0AA36E` | 1,155 | `ir29_castoth` / `func_0A9EEB` | Code | Incan Ruins |
| `$0AA36E` | `$0AA37B` | 13 | `SetPlayerGameOverFlag` | Code | Shared |
| `$0AA37B` | `$0AA391` | 22 | `ir29_castoth` / `func_0AA37B` | Code | Incan Ruins |
| `$0AA391` | `$0AA3A7` | 22 | `ir29_castoth` / `func_0AA391` | Code | Incan Ruins |
| `$0AA3A7` | `$0AA3FD` | 86 | `EnemyPositionSnap` | Code | Shared |
| `$0AA3FD` | `$0AA41C` | 31 | `EnemyInitBasic` | Code | Shared |
| `$0AA41C` | `$0AA43F` | 35 | `ActorMidpointCalc` | Code | Shared |
| `$0AA43F` | `$0AA4E2` | 163 | `EnemyDefeatDispatch` | Code | Shared |
| `$0AA4E2` | `$0AA5A6` | 196 | `dm41_actor_0AA4E2` | actor-def | Diamond Mine |
| `$0AA5A6` | `$0AA6B6` | 272 | `dm43_elevator` | actor-def | Diamond Mine |
| `$0AA6B6` | `$0AA9EC` | 822 | `dm3F_laborer` | actor-def | Diamond Mine |
| `$0AA9EC` | `$0AAA54` | 104 | `dm3D_breakable_wall` | actor-def | Diamond Mine |
| `$0AAA54` | `$0AAFF5` | 1,441 | `dm3D_flayzer` | actor-def | Diamond Mine |
| `$0AAFF5` | `$0AB0B3` | 190 | `dm3D_grundit` | actor-def | Diamond Mine |
| `$0AB0B3` | `$0AB496` | 995 | `dm3D_eye_stalker` / `dm3D_eye_stalker1` | actor-def | Diamond Mine |
| `$0AB496` | `$0AB4B0` | 26 | `sg4C_actor_0AB496` | actor-def | Sky Garden |
| `$0AB4B0` | `$0AC0FE` | 3,150 | `sg4D_cyber` / `sg4D_blue_cyber` | actor-def | Sky Garden |
| `$0AC0FE` | `$0AC520` | 1,058 | `sg4D_knight_armor` / `sg4D_knight_armor1` | actor-def | Sky Garden |
| `$0AC520` | `$0AC816` | 758 | `sg4D_dynapede` | actor-def | Sky Garden |
| `$0AC816` | `$0AC82F` | 25 | `sg4E_nitropede` / `sg4E_nitropede1` | actor-def | Sky Garden |
| `$0AC82F` | `$0ACCD4` | 1,189 | `sg4E_nitropede` / `sg4E_nitropede2` | actor-def | Sky Garden |
| `$0ACCD4` | `$0ACE34` | 352 | `sg4E_plasma_snake` | actor-def | Sky Garden |
| `$0ACE34` | `$0ACFE5` | 433 | `sg55_mystic_statue` | actor-def | Sky Garden |
| `$0ACFE5` | `$0AD000` | 27 | `sg55_falling_tile` | actor-def | Sky Garden |
| `$0AD000` | `$0AD0D5` | 213 | `sg55_actor_0AD000` | Code | Sky Garden |
| `$0AD0D5` | `$0AD9D2` | 2,301 | `sg55_viper` | actor-def | Sky Garden |
| `$0AD9D2` | `$0ADA52` | 128 | `sg4D_knight_armor` / `code_0AD9D2` | Code | Sky Garden |
| `$0ADA52` | `$0ADB38` | 230 | `sg_actors_0ADA52` | Code | Sky Garden |
| `$0ADB38` | `$0ADB45` | 13 | `unused_window_config` | actor-def | Shared |
| `$0ADB45` | `$0ADB6B` | 38 | `unused_follow_chain` | Code | Shared |
| `$0ADB6B` | `$0ADC55` | 234 | `dm_dm_follower_behavior` / `dm_dm_follower_behavior` | Code | Diamond Mine |
| `$0ADC55` | `$0ADCFE` | 169 | `btEA_actor_0ADC55` / `btEA_actor_0ADC55` | actor-def | Babel Tower |
| `$0ADCFE` | `$0ADD05` | 7 | `btEA_actor_0ADC55` / `sc_ix_0ADCFE` | conveyor-index | Babel Tower |
| `$0ADD05` | `$0ADD1E` | 25 | `btEA_actor_0ADC55` / `sc_data_0ADD05` | conveyor-zone | Babel Tower |
| `$0ADD1E` | `$0ADD27` | 9 | `sg4D_cyber` / `sub_0ADD1E` | Code | Sky Garden |
| `$0ADD27` | `$0ADD59` | 50 | `dm_dm_follower_behavior` / `dm_sub_0ADD27` | Code | Diamond Mine |
| `$0ADD59` | `$0ADD66` | 13 | `sg4D_knight_armor` / `sub_0ADD59` | Code | Sky Garden |
| `$0ADD66` | `$0ADD9E` | 56 | `dm3D_eye_stalker` / `code_0ADD66` | Code | Diamond Mine |
| `$0ADD9E` | `$0AE26E` | 1,232 | `mu5F_cyclops` | actor-def | Mu |
| `$0AE26E` | `$0AE45C` | 494 | `mu5F_flasher` | actor-def | Mu |
| `$0AE45C` | `$0AE6CC` | 624 | `sp5C_slipper` | actor-def | Seaside Palace |
| `$0AE6CC` | `$0AE943` | 631 | `sp5C_skuddle` | actor-def | Seaside Palace |
| `$0AE943` | `$0AEA51` | 270 | `mu60_plasma_chain` | actor-def | Mu |
| `$0AEA51` | `$0AEE96` | 1,093 | `av6D_steelbones` | actor-def | Angel Village |
| `$0AEE96` | `$0AEE9F` | 9 | `unused_proximity_check_noref_noref` | Code | Unused |
| `$0AEE9F` | `$0AEF33` | 148 | `av6D_dive_bat` | actor-def | Angel Village |
| `$0AEF33` | `$0AF0C7` | 404 | `av6E_draco` / `av6E_draco` | actor-def | Angel Village |
| `$0AF0C7` | `$0AF150` | 137 | `av70_ramskull` | actor-def | Angel Village |
| `$0AF150` | `$0AF19C` | 76 | `mu67_vampires` / `btF4_neo_male_vampire` | actor-def | Mu |
| `$0AF19C` | `$0AF1F7` | 91 | `mu67_vampires` / `btF4_neo_female_vampire` | actor-def | Mu |
| `$0AF1F7` | `$0AF3C8` | 465 | `mu67_vampires` / `mu67_male_vampire` | actor-def | Mu |
| `$0AF3C8` | `$0AF426` | 94 | `mu67_vampires` / `mu67_female_vampire` | actor-def | Mu |
| `$0AF426` | `$0AF4C7` | 161 | `mu67_vampires` / `func_0AF426` | Code | Mu |
| `$0AF4C7` | `$0AF4D9` | 18 | `mu67_vampires` / `func_0AF4C7` | Code | Mu |
| `$0AF4D9` | `$0AF4EB` | 18 | `mu67_vampires` / `func_0AF4D9` | Code | Mu |
| `$0AF4EB` | `$0AF4FD` | 18 | `mu67_vampires` / `func_0AF4EB` | Code | Mu |
| `$0AF4FD` | `$0AF50F` | 18 | `mu67_vampires` / `func_0AF4FD` | Code | Mu |
| `$0AF50F` | `$0AF6AA` | 411 | `mu67_vampires` / `func_0AF50F` | Code | Mu |
| `$0AF6AA` | `$0AF6D7` | 45 | `mu67_vampires` / `sub_0AF6AA` | Code | Mu |
| `$0AF6D7` | `$0AF6E6` | 15 | `mu67_vampires` / `sub_0AF6D7` | Code | Mu |
| `$0AF6E6` | `$0AF872` | 396 | `mu67_vampires` / `func_0AF6E6` | Code | Mu |
| `$0AF872` | `$0AF961` | 239 | `mu67_vampires` / `func_0AF872_noref` | Code | Mu |
| `$0AF961` | `$0AF9A8` | 71 | `mu67_vampires` / `sub_0AF961` | Code | Mu |
| `$0AF9A8` | `$0AFA17` | 111 | `mu67_vampires` / `sub_0AF9A8` | Code | Mu |
| `$0AFA17` | `$0AFA38` | 33 | `mu67_vampires` / `sub_0AFA17` | Code | Mu |
| `$0AFA38` | `$0AFA40` | 8 | `mu67_vampires` / `word_0AFA38` | Word | Mu |
| `$0AFA40` | `$0AFA48` | 8 | `mu67_vampires` / `word_0AFA40` | Word | Mu |
| `$0AFA48` | `$0AFA51` | 9 | `mu67_vampires` / `func_0AFA48` | Code | Mu |
| `$0AFA51` | `$0AFA59` | 8 | `mu67_vampires` / `binary_0AFA51` | Binary | Mu |
| `$0AFA59` | `$0AFB28` | 207 | `mu67_vampires` / `func_0AFA59` | Code | Mu |
| `$0AFB28` | `$0AFB45` | 29 | `mu67_vampires` / `sub_0AFB28` | Code | Mu |
| `$0AFB45` | `$0AFD26` | 481 | `mu67_vampires` / `dialogstring_0AFB45` | DialogString | Mu |
| `$0AFD26` | `$0AFD5A` | 52 | `av6E_draco` / `sub_0AFD26` | Code | Angel Village |
| `$0AFD5A` | `$0AFD69` | 15 | `unused_random_position_noref_noref` | Code | Unused |
| `$0AFD69` | `$0AFD87` | 30 | `RandomPlayerOffset` | Code | Shared |
| `$0AFD87` | `$0B0000` | 633 | *(unmapped tail)* | — | — |

### 3.2 Visual Layout

```
$0A8000 ┌──────────────────────────────────────────────────────────────┐
        │  EDWARD CASTLE — AQUEDUCT ENEMIES                           │
        │  Canal Worm, Ribber, Skull Chaser, King Bat, Bat,           │
        │  Spear trap, statues, switches, barriers, Spiney            │
$0A8896 ├─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┤
        │  INCAN RUINS — ENEMIES & PUZZLES                            │
        │  Statues, Mudpit, Four Way, Slugger, Scuttlebug, switch,    │
        │  Stone Guard (5 variants), Stone Lord mini-boss,            │
        │  Splop, Whirligig, Frozen Whirligig                         │
$0A99D7 ├──────────────────────────────────────────────────────────────┤
        │  CASTOTH BOSS FIGHT (ir29 + btF2 Neo)                       │
        │  Actor defs, AI code, screen-pos arrays, attack logic       │
$0AA36E ├──────────────────────────────────────────────────────────────┤
        │  SHARED UTILITY CODE                                        │
        │  SetPlayerGameOverFlag through EnemyDefeatDispatch                            │
$0AA4E2 ├──────────────────────────────────────────────────────────────┤
        │  DIAMOND MINE — ACTORS & ENEMIES                            │
        │  Mine NPC laborer, elevator, breakable wall, Flayzer,       │
        │  Grundit, Eye Stalker                                       │
$0AB496 ├──────────────────────────────────────────────────────────────┤
        │  SKY GARDEN — ENEMIES & VIPER BOSS                          │
        │  Blue/Red Cyber, Knight Armor, Dynapede, Nitropede,         │
        │  Plasma Snake, Mystic Statue, Falling Tile, Viper boss      │
$0ADB38 ├──────────────────────────────────────────────────────────────┤
        │  MISCELLANEOUS                                              │
        │  Shared actor stubs, DM utility code, Solid Arm conveyor    │
$0ADD9E ├──────────────────────────────────────────────────────────────┤
        │  MU — ENEMIES                                               │
        │  Cyclops, Flasher                                           │
$0AE45C ├──────────────────────────────────────────────────────────────┤
        │  SEASIDE PALACE — ENEMIES                                   │
        │  Slipper, Skuddle                                           │
$0AE943 ├──────────────────────────────────────────────────────────────┤
        │  MU — PLASMA CHAIN                                          │
$0AEA51 ├──────────────────────────────────────────────────────────────┤
        │  ANGEL VILLAGE — TUNNEL ENEMIES                              │
        │  Steelbones, Dive Bat, Draco, Ramskull                      │
$0AF150 ├──────────────────────────────────────────────────────────────┤
        │  MU — VAMPIRE BOSS FIGHT                                    │
        │  Neo Male/Female Vampire, normal Male/Female Vampire,       │
        │  extensive AI code, attack patterns, dialogue               │
$0AFD69 ├──────────────────────────────────────────────────────────────┤
        │  TAIL                                                       │
        │  RandomPlayerOffset (30 bytes) + unmapped (633 bytes)              │
$0B0000 └──────────────────────────────────────────────────────────────┘
```

---

## 4. Scene Group Analysis

### 4.1 Edward Castle — Aqueduct Enemies (2,688 bytes — 8.2%)

The aqueduct is the underground waterway beneath Edward Castle, consisting of
scenes `$0C`–`$0F` and `$12`. This cluster contains all the enemy and puzzle
actors for the area.

**Files:**
- `extracted/edward_castle/ec0D_canal_worm.asm`
- `extracted/edward_castle/ec0C_ribber.asm`
- `extracted/edward_castle/ec12_skull_chaser.asm`
- `extracted/edward_castle/ec0F_king_bat.asm`
- `extracted/edward_castle/ec0C_bat.asm`
- `extracted/edward_castle/aqueduct_hall/ec0F_spear.asm`
- `extracted/edward_castle/aqueduct_lockway/ec0E_statue.asm`
- `extracted/edward_castle/aqueduct_lockway/ec0E_switch.asm`
- `extracted/edward_castle/aqueduct_hall/ec0F_rusty_switch.asm`
- `extracted/edward_castle/aqueduct_lockway/ec0E_barrier.asm`
- `extracted/edward_castle/ec0E_spiney.asm`

#### Enemies

| Block | Size | Description |
|-------|------|-------------|
| `ec0D_canal_worm` | 620 | **Canal Worm** — Segmented worm that erupts from castle canals. Uses `WaitWhileOffscreen` to activate, then cycles emergence → aim → fire. Turns toward the player across 8 facings via `BranchIfDirToPlayerFrom`, cycling through frames `#22`–`#2A`/`#B0`–`#B2`. Fires directional projectile segments (`SpawnLastRel` → `ForceMoveLastChild`) that set enemy flag, play SFX `#1E`, spawn two trailing body pieces (`$2200`), and die on wall collision (`$4000` on `$10`). Short-lived VFX children handle splash/retract effects. |
| `ec0C_ribber` | 522 | **Ribber** — Hopping waterway enemy. Patrols randomly using `BranchNearerAxis` + cardinal `BranchIfSolid*` for wall-bounce rerolling. Aggro triggered by `SetHitCallback` or `BranchIfPlayerNear` (#04) → `SnapToGrid` into chase mode. When aligned on `orbitAngle & 1` and player within 2 tiles, performs a direction-specific lunge that spawns a homing projectile via `smooth_follow_child` (tracks `$playerActor`). SFX `#1E` on fire. At `orbitDiameter == 0`, holds directional idle for 2 loops watching for re-aggro range. |
| `ec12_skull_chaser` | 385 | **Skull Chaser** — Two-phase enemy. Phase 1: harmless skull that patrols via `BranchNearerAxis` → `BranchOnPlayerX/Y` with 2-step forced moves per axis and solid-wall reroll via RNG `SwitchCase`. On death, spawns VFX (`$0300`), then `SetEntryDelayExit` to revival routine. Phase 2: loads `enemy_stats_table+44` (30 HP, 22 ATK, 12 DEF), offsets upward (`AddPosition #00, #E0`), then executes diagonal `StageSpriteMoveXY` lunges toward the player across 4 quadrant patterns with frame `#0C` loop. |
| `ec0F_king_bat` | 350 | **King Bat** (+4 sub-bats) — Large bat with 4 smaller variants sharing helpers `code_0A8733`/`code_0A8743`. All set `$0010` (enemy). Activation gated by `|actorY − playerY| ≤ 0x3C`; dormant otherwise. King flies vertical bob → horizontal sweep loops (frames `#1F`–`#21`, `#A0`/`#A1`). Sub-bats (`ec0F_sub_bat1`–`sub_bat4`) start from different positions with variant flight paths, all looping infinitely. Contact hazards only — no hit/death callbacks. |
| `ec0C_bat` | 110 | **Bat** — Small ambient bat that drifts in random cardinal directions. Each step uses RNG direction 0–3, checks `BranchIfSolid*` plus map bounds (`mapBoundsX/Y`, min `#10` margin). Pure ambient wanderer — no combat callbacks, spawning, flags, or dialogue. |
| `ec0E_spiney` | 109 | **Spiney** — Spiked patrol enemy using `enemy_stats_table+20` (5 HP, 1 ATK, 0 DEF). Spawn direction from `$0E` high bits: `$4000` = south-first, `$8000` = east-first, `$C000` = north-first, default = west-first. Marches a rectangular patrol path via cardinal bounce loop with `BranchIfSolid*` chain. Independent of switch/barrier puzzle. |

#### Puzzle Actors

| Block | Size | Description |
|-------|------|-------------|
| `ec0F_spear` | 114 | **Spear Trap** — Wall-mounted spears that fire downward when the player approaches. Two variants: `ec0F_spear` (range 3 tiles) and `ec0F_spear2` (range 1 tile). Trigger via `BranchIfPlayerNear` → RNG delay 0–63 frames → warning sprite (`SpawnMarkedAfter`, frame `#3B`) → Y−=`$0100` → SFX `#13` (extend) + `#1E` (impact) → `SolidHighHere` (blocking) → wait `#EF` frames → 32-frame blink loop → `ClearLowHere` → `Die`. Timed hazard with telegraph sprite. |
| `ec0E_statue` | 97 | **Aqueduct Statue** — Dual-mode puzzle prop gated by story flag `#21`. If flag clear: sets `$0200` on `$12` (pushable), `SolidHighHere`, spawns push handler (`push_handler_solid`, `$2300`). If flag set (Kara escape complete): `SetOnInteract` for dialogue — *"This has the same shape as the statue from the seaside cave..."* Scene: `aqueduct_lockway`. |
| `ec0E_switch` | 64 | **Floor Switch** — Sword-toggle controlling barriers. Sets `$0031` on `$12` (solid + hittable), HP `$FF` via `enemy_stats_table+118`. Init clears flag byte `#01`. Hit callback alternates: press → `SetFlagByte(#01)`, frame `#10`; release → `ClearFlagByte(#01)`, frame `#0F`. Binary ON/OFF driving `ec0E_barrier` behavior. Scene: `aqueduct_lockway`. |
| `ec0F_rusty_switch` | 109 | **Rusty Switch** — One-way puzzle switch in the aqueduct hall. Near player (1 tile) → dialogue: *"It won't go in! Maybe it's rusty..."* Activation: `BranchIfPlayerAt($D8,$0298)` → press anim (frame `#10`) → if word flag `$0104` unset: SFX `$0E0E`, `StageBgChange(#04)`, `SetFlagWord($0104)`. Permanent gate opener. Scene: `aqueduct_hall`. |
| `ec0E_barrier` | 208 | **Moving Barrier** (4 variants: `ec0E_barrier`–`barrier4`) — Spike-barriers that oscillate on fixed paths when the switch is OFF, freeze as solid walls when flag byte `#01` is set. `ExitIfFlagByte(#01, #01)` → frozen: `SolidHighHere`. OFF: `ClearLowHere` + movement loop using frame `#3E` loop-moves on X/Y axes. Variants differ in speed (#04 vs #02) and axis order; `barrier2`/`3` add `#1F`-frame pauses between legs. Alternates `SolidHighHere`/`ClearLowHere` each cycle for timing-based passage. Scene: `aqueduct_lockway`. |

#### Puzzle Chain Summary

| Actor | Role |
|-------|------|
| `ec0E_switch` | Sword-toggle → flag byte `#01` |
| `ec0E_barrier` (×4) | Moving hazards when `#01` = 0; frozen solids when `#01` = 1 |
| `ec0F_rusty_switch` | Stand-on activation → flag word `$0104` + BG change `#04` |
| `ec0E_statue` | Pushable if flag `#21` clear; lore inspect if set |

---

### 4.2 Incan Ruins — Enemies & Puzzles (6,426 bytes — 19.6%)

The Incan Ruins span scenes `$1C`–`$29`, covering the ruins entrance, Larai Cliff,
the Inca maze, the Stone Lord mini-boss chambers, and the Castoth boss lair.
Note: `ir1B_slugger` uses scene `$1B` (Moon Tribe Cave, in the `itory` group)
but is categorized under `incan_ruins` in `blocks.json` since Moon Tribe Cave
connects directly to the ruins.

**Files:**
- `extracted/incan_ruins/ir29_castoth.asm`
- `extracted/incan_ruins/ir1F_stone_guard.asm`
- `extracted/incan_ruins/ir1F_stone_lord.asm`
- Various `extracted/incan_ruins/ir*.asm` files

#### Regular Enemies & Puzzles

| Block | Size | Description |
|-------|------|-------------|
| `ir26_statue` | 72 | **Breakable Statue** (treasure room) — Solid obstacle with sprite `#1E`, `$0031` flags (solid+enemy), HP `$FF`. Hit processing checks `playerFlags` bit `$0002` (attack capability); without it, only visual flash. With proper state, jumps to `StandardEnemyDefeatHandler`. No persistence flag — respawns on re-entry. Scene: `inca_treasure_room`. |
| `ir20_statue` | 83 | **Breakable Statue** (secret hallway) — Same mechanics as `ir26_statue` but with persistent room state. Checks `BranchIfFlagByte(#B9, #01)` at start → if set, `Die` (already cleared). On defeat: `SetFlagByte(#B9)` then `StandardEnemyDefeatHandler`. Scene: `inca_secret_hallway`. |
| `ir1D_mudpit` | 341 | **Mudpit** — Environmental mud hazard that patrols on cardinal axes using `BranchNearerAxis` (closer X vs Y to player). Two-step moves per direction with `BranchIfSolid*` collision; on block, random new direction via `RngByte`. Grab attack: `BranchIfPlayerNear(#03)` triggers lunge with `$10` bit `$0008`, extended move + loop anim, then returns to patrol. Hazard/trap type — not a standard hittable enemy. |
| `ir1D_four_way` | 327 | **Four Way Arrow Trap** — Solid ceiling/floor trap (sprite `#09`, `$0011` solid+enemy, `SolidHighHere`). Waits until `$10` bit `$4000` clear, idles anim `#28`. Aiming via `DirToPlayer` → horizontal vs vertical branch. Horizontal: 4 diagonal spawns (NE/NW/SE/SW). Vertical: 4 cardinal spawns (up/down/left/right). Projectiles are short-lived sub-actors with enemy flag that move until solid or `$4000`, then `Die`. Sound `#1E` on fire. |
| `ir1B_slugger` | 255 | **Slugger** — Standard patrolling enemy that charges when aligned with the player on a cardinal direction. `DirToPlayer` → if aligned (N/S/E/W), charge at speed `#04`/`#03` until `BranchIfSolid*` blocked. Otherwise random 2-step walk in one of four directions at speed `#02`. Then idle loop anim (~10 frames) and repeat. Pure movement AI — no projectiles, flags, or dialogue. |
| `ir1D_scuttlebug` | 368 | **Scuttlebug** — Faster palette `#0A` upgrade of Slugger with same AI skeleton but added proximity leap. During charge, `BranchIfPlayerNear(#02)` → leap with `BranchIfSolidOffset` checks and long arc anim (frames `#20`–`#3A`). Faster steps (`#12`/`#11`) than Slugger. Returns to patrol via `SetEntryExit` after leap. |
| `ir21_switch` | 59 | **Puzzle Switch** — Attack-activated floor switch that enables Stone Guard encounters. Sprite `#0F`, hitbox `#01`, `enemy_stats_table+118`, HP `$FF`. Hit callback: frame `#10` → `SetFlagByte(#0F)` → wait `#3B` → reset frame `#0F`. Loops indefinitely. Flag `#0F` is the puzzle gate for `ir1F_stone_guard`/`ir1F_stone_lord`. |
| `ir21_splop` | 206 | **Splop** — Slime hazard that activates when the player is within 8 tiles. Sprite `#1D`, `$0080` priority. Uses 15-frame countdown (`chatPtr`); sound `#26` on first wake. Slow creep toward player via random axis bias (`BranchNearerAxis`/`BranchOnPlayerX/Y`) with collision checks. Every 6 frames, brief extend anim (`#1E`) with solid+enemy re-enabled. Area-denial pressure enemy. |
| `ir21_whirligig` | 263 | **Whirligig** — Spinning blade trap that drops from above and tracks the player with sinusoidal motion. Activates via `BranchIfPlayerNear(#06)` → drop (`StageSpriteLoopMoveY #1B, #40, #14`). Parent handles visuals (max collision priority, idle spin loop `#1C`). Sub-actor (`code_0A98E9`) stores player-relative offset and advances angle in `chatPtr`, using `sine_table_8bit`/`signed_sine_table` for wobble/orbit around a tracking point. Adjusts base position by player X/Y quadrant before applying sine offset. |
| `ir21_frozen_whirligig` | 20 | **Frozen Whirligig** — Inert, static variant. Enemy flag `$0010` only. Static frame `#1B`, `SetEntryContinue`, `RTL`. No movement, sub-actors, or activation. Placeholder/disabled whirligig — likely activated by another actor or room event. |

#### Stone Guard / Stone Lord (1,933 bytes)

The Stone Guard is a multi-phase enemy: dormant statue → activation → directional melee
with hitboxes and player knockback. Five variants share one parent block.

| Part | Size | Description |
|------|------|-------------|
| `ir1F_stone_guard1`–`3` | 5 ea. | Sprite variants `#00`, `#01`, `#02` — redirect stubs to shared AI. |
| `ir1F_stone_guard4` | 145 | Variant `#02` + horizontal flip. |
| `ir1F_stone_guard5` | 1,202 | Full primary implementation. |

**Activation:** Enemy+solid, palette `#0E`, priority `#20`. `orbitAngle` from spawn param `$0F` bit `$0004`. If `orbitAngle = 0`: activates on `BranchIfPlayerNear(#02)`. If `orbitAngle ≠ 0`: requires flag `#0F` (switch); else `ExitIfFlagByte`. Wake sequence: `KillNext`, palette flash (30 + 15 frames), clears enemy/solid, `ClearLowHere` → combat AI.

**Combat AI:** Axis-priority patrol. `BranchIfPlayerNear(#04)` + `BranchIfPlayerInRelTiles` for directional attacks. Each attack direction: wind-up → spawn marked hurtbox sub-actor → looping strike anim → sound `#1E` → spawn moving knockback hazard. Knockback sub-actors check player invuln/dash; distance thresholds; `ApplyPlayerHitstun` with direction-specific force and joypad mask `$0F00`. At HP `$000A`, brief pause (`$0200` on `$10`).

**Stone Lord** (571 bytes) — Elite stone guardian using same wake/activation as Stone Guard but fires lingering projectile trails instead of knockback boxes. Palette `#02`. On valid tile alignment: sound `#1F` (wind-up) + `#21` (release), spawns trail projectile that moves until `BranchIfSolid`, recursively spawns trailing copies (`SpawnLastRel` on self), dies at collision. 4 additional named spawn references (`ir1F_stone_lord2`–`ir1F_stone_lord5`).

| Flag | Set by | Purpose |
|------|--------|---------|
| `#0F` | `ir21_switch` hit | Enables some stone guard spawns |
| `#B9` | `ir20_statue` defeat | Secret hallway statue destroyed |

#### Castoth Boss (2,499 bytes)

The Castoth boss fight is the largest single block in this bank. It includes the
original Castoth and the Neo Castoth rematch (for the Babel Tower boss rush).

**File:** `extracted/incan_ruins/ir29_castoth.asm`

**Normal Castoth (`ir29_castoth`):**
- **Intro:** Checks WRAM flag (already beaten → die). Locks input (`$EFF0`), BG change, boss music `#0F`, camera drift. Wing totems spawn at fixed positions with entrance animation. Boss descends via `MoveToward`.
- **Main loop (`code_0A9BF6`):** Timed phases via `$00F0`/`$00F2`. When `$00F0 = 3` → special lunge phase.
- **Attacks (`func_0A9EEB`):** Monitors player screen zones via `BranchIfPlayerInAbsTiles`. Random selection: horizontal swipe, vertical swipe, or corner attacks. Each telegraph (frame `#27` loop) then spawns sliding hitbox projectiles. Additional attack types:
  - **Homing fireball:** Telegraph `#25`/`#26` → `code_0A9FDB` accelerating toward player.
  - **Orbiting sub-projectiles:** 3 projectiles (phases `$00`, `$55`, `$AA`) bouncing off screen edges (`$4000`/`$2000` on `$12`).
  - **Charge hitbox:** 5-frame telegraph → charge at player.
- **Wing totems:** Separate HP from `enemy_stats_table+190`. Death callback rolls bits into `$00F0`; both wings down enables main body damage phases. Individual wing AI: track player X, attack sequences, return to perch.
- **Dodge counter:** On successful dodge (angle/distance tables), boss counter-attacks with screen-positioned strike using `array_0A9EA3`/`0A9EBB`/`0A9ED3`.
- **Death (`func_0A9C1E`):** Wing cleanup, palette effects, debris spawn, `StandardEnemyDefeatHandler`. Sets `playerFlags` bit `$0200`.

**Neo Castoth (`btF2_neo_castoth`):**
- Skips full intro; shorter setup. If not Shadow form (`characterForm ≠ 2`): forces Gaia transformation via `sE6_gaia.Transform_WillToShadow`, waits on `playerFlags` `$0800`. Spawns totems at different absolute positions. Monitor: if `$0AEC` set → `SetFlagWord(#$0175)`, queue map change to `#$4830`. Reuses main fight loop and death logic.

---

### 4.3 Diamond Mine — Actors & Enemies (4,360 bytes — 13.3%)

The Diamond Mine spans scenes `$3D`–`$43`, the slave labor mine where Will
searches for the laborers. Includes NPCs, enemies, and environmental actors.

**Files:**
- `extracted/diamond_mine/mine_main/dm3F_laborer.asm`
- `extracted/diamond_mine/mine_zigzag/dm41_actor_0AA4E2.asm`
- `extracted/diamond_mine/mine_elevator/dm43_elevator.asm`
- `extracted/diamond_mine/mine_promise_passage/dm3D_breakable_wall.asm`
- `extracted/diamond_mine/dm3D_flayzer.asm`
- `extracted/diamond_mine/dm3D_grundit.asm`
- `extracted/diamond_mine/dm3D_eye_stalker.asm`
- `extracted/diamond_mine/dm_dm_follower_behavior.asm`

| Block | Size | Description |
|-------|------|-------------|
| `dm41_actor_0AA4E2` | 196 | **Bouncing Hazards** (×3 variants) — Camera-aware orbiting projectiles in the zigzag mine room. Flagged as enemies (`$0010`) with sprite `#34`/hitbox `#02`. Each variant sets different velocity vectors in `$moveXAlt`/`$moveYAlt`: variant 1 = `(2,1)` diagonal drift, variant 2 = `(0,1)` vertical after horizontal nudge, variant 3 = `(1,0)` horizontal only. Bounce AI: if position exceeds `$effectBoundsX`/`$effectBoundsY`, negate velocity component (pinball bounce). Motion stays camera-relative via `$cameraTargetX/Y` and `$cameraDeltaX/Y` reconciliation. Pure ambient hazards — no hit callbacks or player interaction. Scene: `mine_zigzag`. |
| `dm43_elevator` | 272 | **Mine Elevator** — Cutscene controller that moves the elevator platform and force-carries the player between landings. Tweaks `$COLDATA` for dim tint. Branches on `playerXPos < 0x30` for lower vs upper shaft. Lower ride: waits at `(0x48, 0x80)`, masks joypad `$CFF0`, animates down (`StageSpriteMoveXY #34,#03,#01`), syncs player Y each frame until `Y = 0x340`. Upper ride: reverse. Helper plays sound `#0C` every 16 frames and updates player facing via `InitPlayerScriptVariant`. Sub-actors `dm43_elevator_stop_y`/`stop_x` ping-pong stage scroll between map bounds. Scene: `mine_elevator`. |
| `dm3F_laborer` | 822 | **Rescuable Laborer NPCs** (8 instances) — Each instance indexed by spawn variant (`$0E` → `$24`), tied to persistent flags (`$A0`–`$A3`). If flag set → `Die`. While chained: sets interactable (`$1000`), `SolidHighHere`, spawns breakable chain sub-actor (1 HP destructible via `EnemyInitBasic`). First talk: *"I beg you! Cut this chain!!"* Chain break animates laborer stepping down, sets per-laborer flag. Post-rescue dialogue via `SwitchCase` on index: index 0 = generic plea; index 1 = **Mine Key** (item `#0C`) + jingle; index 2 = **Elevator Key** (item `#0F`) + hint; index 3 = secret-room hint about wind cracks. Inventory full → *"But your inventory is full!"* Scene: `mine_main`. |
| `dm3D_breakable_wall` | 104 | **Promise Passage Wall** — Secret destructible wall. Word flag `$0133` bit 1 → die if already broken. Offset `(+8,+8)`, `$0031` on `$12` (solid+enemy), HP 255. Wind detection: while HP = 255, if player enters tile rect `(5,3)–(7,7)` → sets flag byte `#00` (crack/wind hint active). Breaking requires Tornado Psycho Slider (`$playerFlags` bit 2): spawns debris burst, BG tile change `#33`, clears flag `#00`, sets word flag `$0133`. Two-step puzzle: proximity detects the secret, Tornado delivers the break. Scene: `mine_promise_passage`. |
| `dm3D_flayzer` | 1,441 | **Flayzer** — Flame-thrower enemy with wall-following patrol. Patrols south → north → west → east with `BranchIfSolid*` collision, idle/wiggle loops on blocked paths. Aggro at 4 tiles via `BranchIfPlayerNear`: sets enemy `$0001`, picks axis via `BranchNearerAxis`. Four directional flamethrower attacks (all play sound `#23`): aligns to player, spawns leading flame head (`MoveToward` player) plus multiple static flame segments via `ActorMidpointCalc`. Cleanup after `WaitByte #4F`: clears enemy flag, `KillNext` ×6, returns to patrol. Hit callback disables, clears `$0002`, re-triggers aggro. Three variants: `flayzer` starts with `SetHFlip`, `flayzer2` is identical, `flayzer3` adds random initial delay. |
| `dm3D_grundit` | 190 | **Grundit** — Burrowing ground enemy. Sets `$0011` (solid+enemy). Activates when player within 4 tiles. Telegraphs: 5-frame loop, sound `#2C`, warning frame `#2D`. Spawns: two horizontal crack strips (animated fissures, die after move), two "behind wall" variants (`$4000` on `$12`), flash marker (frame `#2E`, long wait, die). Main body spawned via `SpawnLastRel` → `dm_dm_follower_behavior` at relative offset `(0, 0xCE)`. Emerge anim: frames `#2F` → `#30` → `#31`, loops. All telegraph VFX delegated to short-lived sub-actors. |
| `dm3D_eye_stalker` | 1,051 | **Eye Stalker** — Floating eye with patrol, charge, and beam attacks. Three variants: **stalker1** = sentinel (solid-high closed eye `#1A` until player within 3 tiles → opens, clears solid, enters AI); **sE9_eye_stalker2** = scene `$E9` copy with palette `#04` while closed; **eye_stalker3** = active hunter (waits offscreen, monitors distance). Patrol: 4-direction wall follower, direction from `$28 − 0x16` mod 4. Two-tier threat radius: 5 tiles = ranged beam (aligns on grid via `code_0ADD66`/`0ADD83`, spawns directional beam projectile that moves until owner `$10.$4000` set, frames `#24`/`#A4` horizontal or `#23`/`#22` vertical, sound `#20`); 3 tiles = charge (solid-high, pulsing eye for 12 loops). Aggro variant: `$0E.$4000` uses alternate sprites `#9F`/`#A0`/`#A1`. |
| `dm_dm_follower_behavior` | 284 | **Ground Popup Body** — Shared "pop up from ground" enemy behavior used by Grundit. Emerges with burst VFX (`code_0ADC25`), spawns `smooth_follow.InitFollowAndChase` targeting player. 30-frame emerge loop checks tile-grid alignment (XOR on `$0010` boundary bits); if movement crosses 16px boundary → wall collision → kill follower or die with frame `#2A`. Post-emerge: stores movement scratch in orbit vars, animates in place; dies when parent hit flag `$10.$4000` set. |

| Flag | Set by | Purpose |
|------|--------|---------|
| `$A0`–`$A3` | `dm3F_laborer` | Per-laborer rescued state |
| `#00` byte | `dm3D_breakable_wall` | Wind crack detected near wall |
| `$0133` word | `dm3D_breakable_wall` | Wall permanently destroyed |

---

### 4.4 Sky Garden — Enemies & Viper Boss (9,912 bytes — 30.2%)

The largest scene group in this bank. Sky Garden (scenes `$4C`–`$55`) is a
late-midgame dungeon with mechanized enemies. The Viper boss fight alone takes
2,301 bytes.

**Files:**
- `extracted/sky_garden/sg4D_cyber.asm`
- `extracted/sky_garden/sg4D_knight_armor.asm`
- `extracted/sky_garden/sg4D_dynapede.asm`
- `extracted/sky_garden/sg4E_nitropede.asm`
- `extracted/sky_garden/sg4E_plasma_snake.asm`
- `extracted/sky_garden/sg4C_actor_0AB496.asm`
- `extracted/sky_garden/viper_lair/sg55_mystic_statue.asm`
- `extracted/sky_garden/viper_lair/sg55_falling_tile.asm`
- `extracted/sky_garden/viper_lair/sg55_actor_0AD000.asm`
- `extracted/sky_garden/viper_lair/sg55_viper.asm`
- `extracted/sky_garden/sg_actors_0ADA52.asm`

#### Regular Enemies

| Block | Size | Description |
|-------|------|-------------|
| `sg4C_actor_0AB496` | 26 | **Input Gate** — Scene utility actor placed on every Sky Garden map. Not an enemy — gates player input at room load, waits on `$00B4`, writes `$FFFF` to `joypadInject` when ready, then `Die`. Bootstrap/initialization actor. |
| `sg4D_cyber` | 3,159 | **Blue/Red Cyber** — Signature Sky Garden enemy and the single largest actor in the bank. **Blue Cyber** (`sg4D_blue_cyber`): 8-segment snake body with `$0011` (solid+enemy). Each orientation runs a segment script that may spawn `sg_actors_0ADA52` projectiles on specific RNG values. Patrol via `BranchNearerAxis` + wall-following with random detours. On hit: snap to grid, `DirToPlayer`, spawn 2 linear enemy projectiles per facing. **Red Cyber** (`sg4D_red_cyber`): adds `SetDeathCallback` for segment cleanup. Continuous segment animation with `DirToPlayerFrom` per segment. Chase AI when player near. On hit: spawns **homing** projectiles (`$2200` flags) with `SetCollideCallback`/`SetExtraCallback` that track parent via `orbitDiameter`/`orbitAngle` linkage and `MoveToward` player offset. On parent death, projectiles converge and die. |
| `sg4D_knight_armor` | 1,199 | **Knight Armor** — Animated suit of armor (sprite `#17`) that "wakes up" when player approaches. Four map-placed variants with different activation triggers. Dual-actor design: parent statue + spawned combat puppet linked via WRAM fields. Parent: `SolidHighHere`, idle frame `#17`, `WaitWhileOffscreen`. Activation spawns combat entity at Y−36. **Combat entity** (`code_0AC1B4`): patrol `#1A`/`#22`; when player near, 8-way directional lunge via `SwitchCase` on `DirToPlayer` with unique move patterns per direction. 3 hits to kill — each hit spawns cardinal knockback shard; at 3 hits, parent notified via `orbitAngle = $FFFF`. Palette flash (`code_0AD9D2`) signals activation. Variants 2/4: if blocked spawn location, armor stays at frame `#18` and becomes pushable solid (`push_handler_solid`). Variant 3: uses `smooth_follow.InitFollowAndChase` to pursue for 48 frames before attack. |
| `sg4D_dynapede` | 758 | **Dynapede** — Centipede-like enemy with two sprite variants (`sg4D_dynapede` sprite `#25`, `sg4D_dynapede2` sprite `#23`). `$0080` on `$12`, `SetDeathCallback`. Navigates along solid tiles via player-relative branching and RNG, extensive `BranchIfSolid*`/`BranchIfSolidOffset` maze-following. Horizontal lunge: `StageSpriteMoveX` frame `#28`, toggles `$4000` on `$12`. Vertical lunge: frames `#26`/`#27` with `StageForceMoveY`. **Death**: orientation-dependent anim from lookup table `byte_0AC79A` indexed by sprite ID; spawns up to 7 gravity-driven body-part projectiles with varied X velocity; sound `$0E0E`; `StandardEnemyDefeatHandler`. |
| `sg4E_nitropede` | 1,214 | **Nitropede** — Explosive palette `#04` upgrade of Dynapede. Inherits pathfinding with extra RNG branches. New **vertical nitro boost**: detects open space via multiple `BranchIfSolidOffset` checks at Y=`#$FC`/`#$04`, plays frames `#2F`→`#30`, `$0300` on `$10` (invuln/ghost), `StageSpriteLoopMoveY`, recovery frame `#39`. **Multi-phase death**: flashes → body burst → 7 fire fragments with RNG spread → fragments hit ground, become scorch marks (frame `#31` loop) or die on solid collision. Sound `$0505`. |
| `sg4E_plasma_snake` | 352 | **Plasma Snake** — Three-segment chain enemy (head + 2 tail pieces spawned at init). Two map variants: variant 0 = faster (`StageSpriteLoopMoveXY` speed `#12,#11`), variant 1 = slower (`#02,#01`). Head patrols along walls in closed loop via `BranchIfSolidOffset` corner checks. Tail segments copy head's movement state each frame, chain `$24` links. Environment hazard — damage via `$02` flag contact. No hit/death callbacks. |
| `sg_actors_0ADA52` | 230 | **Directional Burst Debris** — Shared projectile/shrapnel library (8 entry points) spawned by Cyber body segments. Each plays metasprite explosion (`table_0EE000`), force-moves in a specific direction with flips, loops until wall hit (`$10` bit `$4000`), then dies. Directions: vertical drop, diagonal up-right (×2 w/ flips), right (×2 w/ flips), diagonal down-right (×2 w/ flips), down. Also referenced by `pyCC_mystic_ball`. |

#### Viper Boss Fight (2,974 bytes)

The Viper (Huge Demon) is the boss of Sky Garden, fought in scene `$55` (`viper_lair`).

**File:** `extracted/sky_garden/viper_lair/sg55_viper.asm`

| Block | Size | Type | Description |
|-------|------|------|-------------|
| `sg55_mystic_statue` | 433 | actor-def | **Mystic Statue Cutscene** — Post-Viper narrative controller. Guards exit if `$0AEC` (boss-active) set. **First visit** (flag `#F9` clear): masks joypad `$FFF0`, prints *"You have defeated the huge demon! Look! A Mystic Statue!!"*, sets `$0AAC`, `$0B12=$55`, queues map change `#FD`. **Return visit** (flag `#F9` set): spawns `sg55_actor_0AD000` debris, swaps to Gaia form if needed (`Transform_FreedanToWill`, `$0800`), Neil dialogue *"Will! You're falling to the ground!!!! Grab the airplane…"*, scrolls camera down 48 frames, waits for player Y tile `$18`, queues map change `#58` (falling sequence). |
| `sg55_falling_tile` | 27 | actor-def | **Collapsing Floor** — One-shot trap tile. `ClearAllHere` on init, only activates when player Y ≥ `$20`. Then: `SolidHighHere`, frame `#0B`, `AnimOnce`, `Die`. Creates collapsing floor during boss intro. 18 instances placed at X=7, Y=`$0D`–`$20`. |
| `sg55_actor_0AD000` | 213 | Code | **Debris Spawner** — Camera-scroll-linked rubble spawner for Viper fight intro. Spawns visual effect, gravity tick synced to `moveScratch2`. At Y≥`$0C` triggers spawn phase: spawns standard actor + loops 4× spawning random debris (fast-falling sprite `#06`, medium `#07`, slow `#08` based on `$0036` bit 0). Position derived from BG scroll + RNG offset. |
| `sg55_viper` | 2,301 | actor-def | **Viper Boss** — Full boss AI. `$0011` solid+enemy. Checks WRAM flag → die if beaten. Intro: `$EFF0` joypad mask, music `#0F`, camera pans from `$0130` down 48 frames, spawns debris. **Main loop**: spawns collision handler applying knockback when overlapping. **Attack cycle**: (1) jump slam — RNG-scaled hop toward player with gravity; (2) reposition toward random X near player; (3) roar/wind-up → spawns homing fireball (`MoveToward` player with palette flash) that splits into 4 directional flame waves; (4) spawns 6 serpent projectiles with easing toward player, sprites grow over `$1E` frames. **Directional body attacks**: `BranchOnPlayerX` → timed bite/lunge patterns with `$24` frame counters. **Projectile drops**: RNG velocity fire with gravity. **Death**: sets `$0020` player flag, spawns defeat sequence + explosion particles, `StandardEnemyDefeatHandler`. **Neo Viper** (`btF3_neo_viper`): `$0011`, fixed camera Y=`$0100`. If player not Freedan: swaps via `Transform_WillToShadow`. Spawns helper locking control → flag word `$0176` → map change `#E0`. Same combat/death scripts, no intro camera pan or debris. Boss uses `$0AEC` as active flag; `$0AF4`/`$0AF6` point to attack timing data. |

---

### 4.5 Mu — Enemies & Vampire Boss (5,026 bytes — 15.3%)

Mu (scenes `$5F`–`$67`) is a sunken continent dungeon. This bank contains
the area's regular enemies and the climactic Vampire boss fight.

**Files:**
- `extracted/mu/mu5F_cyclops.asm`
- `extracted/mu/mu5F_flasher.asm`
- `extracted/mu/mu60_plasma_chain.asm`
- `extracted/mu/mu_vampire_lair/mu67_vampires.asm`

#### Regular Enemies

| Block | Size | Description |
|-------|------|-------------|
| `mu5F_cyclops` | 1,232 | **Cyclops** — One-eyed enemy with two actor-def variants. Patrols via 4-way `SwitchCase` on RNG (east/west/north/south) with solid checks and player-axis branching. When player within 5 tiles, picks attack direction and executes directional lunge spawning 1–N projectiles (`SpawnAfterRelFlags`) with force-move patterns. Burst count in `$24` is RNG-weighted (25% chance of 4 extra shots via `$0B02`). **On hit**: hurt frame `#2E`, sound `#1E`, spawns 8 radial projectiles, then re-enters attack selection. Projectiles: force-move, looping anim `#1F`, die on wall hit. Flags: `$0008` (high collision), toggles `$0110` on `$10` during attacks; projectiles get `$0010`+`$0080` on `$12`. |
| `mu5F_flasher` | 494 | **Flasher** — Teleporting ambush enemy. Stores spawn position, each cycle waits 59 frames, picks random 16×16-aligned point within ~256px of player, validates line-of-sight/proximity. On trigger: picks nearest axis, plays 3-frame windup dash. Spawns projectile (`$0202` flags) with force-move, then attaches `smooth_follow.CopySiblingFollowState` for homing. Parent stores velocity in scratch RAM and dies (`KillNext`) while child persists. Flags: `$0011` (solid+enemy) when active; `$2000` on `$10` when solid-blocked. Hit callback: recovery frame + `RestoreSavedPtr`. |
| `mu60_plasma_chain` | 270 | **Plasma Chain** — Segment-chain enemy: head node + 3 follower segments. Followers set `$0100` on `$12`. On init, loads `enemy_stats_table`, spawns 1 leader + 3 followers. Dies immediately if spawned inside solid tile. **Leader AI**: stores spawn as orbit center; when player far: RNG-offset wander toward random point, idle loop anim `#2C`. When player within 5 tiles: chases player position, returns to orbit center, repeats. **Followers**: infinite loop copies midpoint of parent+grandparent positions (via `ActorMidpointCalc`), mirrors parent sprite/hitbox. Creates visual chain trailing effect. Damage via contact hitbox. |

#### Vampire Boss Fight (3,030 bytes)

The Vampire duo is the boss of Mu, fought in scene `$67` (`mu_vampire_lair`).
This is the second-largest block in the bank, with 24 individual parts.

**File:** `extracted/mu/mu_vampire_lair/mu67_vampires.asm`

| Part | Size | Type | Description |
|------|------|------|-------------|
| `btF4_neo_male_vampire` | 76 | actor-def | Neo Male Vampire — boss rush variant. `$8011` flags. Spawns orbital companion, checks `$characterForm` for Shadow form branch. If not Shadow: hijacks player script, may queue map change to `$E0`. |
| `btF4_neo_female_vampire` | 91 | actor-def | Neo Female Vampire — joins male's battle loop. |
| `mu67_male_vampire` | 465 | actor-def | **Male Vampire** — Primary boss. Disables input (`$EFF0`), BG swap (`#92`/`#91`), boss music `#0F`. Grid-snaps to 4×4 positions via `word_0AFA38`/`word_0AFA40` tables. Attacks: spawns 4 directional bat swarms that tile-spawn enemies along a line; hit callback fires 4 spiral projectiles (`InitSpiral` + `SpiralStep`). |
| `mu67_female_vampire` | 94 | actor-def | **Female Vampire** — Mirror AI on separate grid columns. Hit spawns 4 spiral projectiles (variant `#2C`). Position director picks attack scripts based on player alignment at grid nodes. |
| `func_0AF426`–`func_0AF4FD` | 233 | Code | Attack pattern dispatch — 4 × 18-byte directional handlers + 161-byte router. |
| `func_0AF50F` | 411 | Code | Main vampire combat loop — coordinates male/female attacks via timed phases. |
| `sub_0AF6AA`–`sub_0AF6D7` | 60 | Code | Phase transition helpers. |
| `func_0AF6E6` | 396 | Code | **Shared attack timer thinker** — Random countdown (`$00F2`) controlling phase transitions for both bosses. Also handles vampire visual effects and PPU register manipulation (`WOBJSEL`, `CGWSEL`, `CGADSUB`) for color math effects. |
| `func_0AF872_noref` | 239 | Code | Unreferenced code — possibly cut attack pattern or earlier revision. |
| `sub_0AF961`–`sub_0AFA17` | 215 | Code | Damage handling and HP check routines. |
| `word_0AFA38`–`word_0AFA40` | 16 | Word | Grid position lookup tables (8 bytes each). |
| `func_0AFA48`–`binary_0AFA51` | 17 | Code+Binary | Remaining combat support code and data. |
| `func_0AFA59`–`sub_0AFB28` | 236 | Code | Male death callback (`func_0AFA59`), female death callback (`code_0AFAA0`). First kill: defeat dialogue. Second kill: spawns `SetPlayerGameOverFlag` (invuln flash) + defeat effect → `StandardEnemyDefeatHandler`. |
| `dialogstring_0AFB45` | 481 | DialogString | Vampire encounter dialogue — intro argument about Mystic Statue, female taunt on male death, male rage on female death. |

**Phase structure:** Phase 1 = grid-based bat swarm attacks + spiral projectiles. Phase 2 (`$00F2` timer): transform anim → bat form (`$0202` flags) with erratic bouncing movement, palette thinker, directional sprite swaps. Dies off-screen or at boundaries. Flags: byte `#86`, `#87`, `#02`; word `#0177` for Neo transition.

---

### 4.6 Seaside Palace — Enemies (1,255 bytes — 3.8%)

Seaside Palace (scene `$5C`) contributes two enemy types to this bank.

**Files:**
- `extracted/seaside_palace/sp5C_slipper.asm`
- `extracted/seaside_palace/sp5C_skuddle.asm`

| Block | Size | Description |
|-------|------|-------------|
| `sp5C_slipper` | 624 | **Slipper** — Fast floor enemy with dodge mechanics. In scene `$005C`, dies if byte flag `#70` set. Adjusts Y by `#F8`, waits offscreen. Idle anim `#1A→1B`. When player within 6 tiles, enables `SetDodgeCallback` and picks random attack direction (4-way `SwitchCase`). **Dodge**: if player closes to 4 tiles during windup, reads cardinal direction to player and force-lunges away (2-tile burst), then counter-attacks with extended hitbox `#27`. Four directional force-move scripts with solid checks and `$24` retry counter. At distance 3, switches to looping run anim `#20` with hitbox `#27`. On hit: frame `#1C`, `$0300` on `$10`, exits to idle. Flags: `$0080` on `$12`; `$0300` on `$10` during windup. |
| `sp5C_skuddle` | 631 | **Skuddle** — Two-variant ceiling/floor bug. **Floor variant** (`sp5C_skuddle`, sprite `#1D`, hitbox `#00`): patrol → drops ceiling spawn when player far. **Ceiling variant** (`sp5C_ceiling_skuddle`, sprite `#1D`, hitbox `#02`, flag `#23`): ceiling ambush — spawns shadow marker (metasprite `#31` loop), descends pixel-by-pixel to stored Y, then `KillNext` and handoff to floor AI. **Floor AI**: clears `$6000` on `$12`, tracks `$24` attempt counter. Picks direction via nearest-axis + solid checks. After 4 blocked attempts, aborts and re-spawns ceiling drop. **Attack**: directional leap with force-move `#42`, hitbox swap to `#1E`, `$0301` on `$10`. Both variants check scene `$005C`/`$005D` + flag `#70`. |

| Flag | Used by | Purpose |
|------|---------|---------|
| `#70` byte | `sp5C_slipper`, `sp5C_skuddle` | Seaside Palace enemy gating |

---

### 4.7 Angel Village — Tunnel Enemies (1,834 bytes — 5.6%)

Angel Village (prefix `av`, scenes `$68`–`$75`) is a late-game hub area with
underground tunnels leading to Ishtar's studio. The four enemy types in
this bank appear in the village tunnel scenes: `$6D` (Entrance Tunnel), `$6E`
(Draco Tunnel), and `$70` (River Tunnel).

**Files:**
- `extracted/angel_village/av6D_steelbones.asm`
- `extracted/angel_village/av6D_dive_bat.asm`
- `extracted/angel_village/av6E_draco.asm`
- `extracted/angel_village/av70_ramskull.asm`

| Block | Size | Description |
|-------|------|-------------|
| `av6D_steelbones` | 1,093 | **Steelbones** — Skeleton archer with dual-range combat. **Far AI**: random 4-way patrol (`SwitchCase`) with long idle loops (frames `#00`–`#02`, `#82`) and short alert loops (`#09`–`#0B`). Hit callbacks during idle detect player in directional tile zones. **Near AI** (6 tiles): aggressive mode with shorter move counter (`$24=2`), cardinal direction charge attacks — four directional force-lunge scripts with 2-iteration burst and solid checks. **Ranged (on hit)**: snap to grid, throw anim (`#0C`/`#8C`), wait 29 frames, spawn bone projectile that moves toward computed point offset from player (RNG spread), tracks parent actor position, bounces subtly, dies after ~6 convergence frames or timeout. |
| `av6D_dive_bat` | 148 | **Dive Bat** — Ceiling bat that swoops when player passes below within range. `$2000` on `$12`; `$0020` flag (flyer). Requires player Y ≥ bat Y, vertical gap < 256px, horizontal gap < 64px. Dive: flips sprite toward player (`#11`/`#91` + `$4000`), gravity init `(4, 9, 0)`, force-moves X at speed 2 while ticking gravity until reaching original Y (`$26`). Return: clears `$4000`, snaps Y to roost, loops to offscreen wait. Death jumps to `EnemyDefeatDispatch`. |
| `av6E_draco` | 456 | **Draco** — Dragon head with three tail segments (via `ActorMidpointCalc` midpoint interpolation). Records home position, spawns tail controller + 3 segments. **Idle**: frame `#12` at nest. When player within 4 tiles, enters attack: faces player (optional HFlip), frame `#16`, computes semi-random target near player (`sub_0AFD26` — Y biased, X RNG ±31), fires twice via `MoveToward` lunge anim `#17`. If player still near, direct chase; otherwise returns to nest via `MoveToward` speed 12 until exact home match. **Death**: sets 4 tail segments to staggered explosion anims, clears low collision, `StandardEnemyDefeatHandler`. Flags: `$0001` solid, `$0002` enemy, `$0020` flyer. |
| `av70_ramskull` | 137 | **Ramskull** — Charging skull with lateral projectiles. `$0011` (solid+enemy), `$0008` actor flag. Infinite loop: idle `#1A` → charge loop `#1B` → spawns two lateral projectiles at `(#FC,#F4)` and `(#04,#F4)` → recovery `#1A`. Projectiles: enemy `$0010`, spawn two trailing sparks (`$2200` flags), force-move X at speed 8 until wall hit → die. Spark trail: metasprite effect, force-move X speed 4, loops frame `#26` until parent dies. |

---

### 4.8 Mansion — Solid Arm Conveyor (201 bytes — 0.6%)

A single actor from the Solid Arm boss arena. Despite the `bt` (Babel Tower)
prefix in its block name, this scene belongs to the `mansion` group in
`groups.json` (scene `$EA`, Solid Arm's Lair). The conveyor system is shared
with Sky Garden's Viper Lair (scene `$55`).

**File:** `extracted/mansion/solid_arm_lair/btEA_actor_0ADC55.asm`

| Part | Size | Type | Description |
|------|------|------|-------------|
| `btEA_actor_0ADC55` | 169 | actor-def | **Conveyor Belt Zone** — Background physics actor (not visible). Actor flag `#20` (non-solid effect). Indexes `sc_ix_0ADCFE` for scenes `#55` and `#EA`; dies if scene not found. Each frame: builds 2×2 tile AABB around player position, tests against `conveyor-zone` records (6 bytes: min/max tile bounds + X/Y velocity deltas). On match: adds signed velocity to `$extVelocityX`/`$extVelocityY`. |
| `sc_ix_0ADCFE` | 7 | conveyor-index | Scene → conveyor data index lookup. |
| `sc_data_0ADD05` | 25 | conveyor-zone | 3 conveyor zones for scene `$EA`: zone 1 = tiles `(3,7)–(8,8)`, push `(0, +4)`; zone 2 = tiles `(7,6)–(8,8)`, push `(0, −4)` (reverse); zone 3 = tiles `(11,7)–(12,9)`, push `(0, +4)`. Data-driven conveyor system — no sprites or COP beyond wait-and-scan. |

---

### 4.9 Shared / Utility Code (433 bytes — 1.3%)

Small utility functions and stubs shared across multiple actors or unreferenced.

| Block | Size | Description |
|-------|------|-------------|
| `SetPlayerGameOverFlag` | 13 | **Boss Kill Invuln Flash** — Sets `$0200` on the player actor's `$10` flags (brief post-hit invulnerability). Referenced by: `mu67_vampires` (both death callbacks), `sg55_viper`, `ir29_castoth`, `pyDD_mummy_queen`, `gw8A_sand_fanger`. |
| `EnemyPositionSnap` | 86 | **Grid-Snap Movement** — Clears hit/dodge callbacks, computes nearest 16×16 grid position, `MoveToward` at speed `$FF`/1 frame, repeats until aligned, then `ResumeAfterSnap`. Installed as deferred resume target by `cop_handlers_movement` when movement is interrupted mid-tile. Not called directly by actor scripts. |
| `EnemyInitBasic` | 31 | **Chain Destructible Setup** — Turns the laborer's chain into a 1-HP destructible: sets `$0030` (solid+enemy) on `$12`, attaches `enemy_stats_table`, HP = 1, extended flag `$0080`. Used exclusively by `dm3F_laborer` chain spawn. |
| `ActorMidpointCalc` | 35 | **Midpoint Position Calculator** — Averages parent (`$04`) and grandparent (`$06`) actor X/Y into current actor's `$14`/`$16`. Used for chain/tail following by: `av6E_draco` (tail segments), `mu60_plasma_chain` (chain followers), `dm3D_flayzer` (flame segments). |
| `EnemyDefeatDispatch` | 163 | **Standard Enemy Death** — Two-path handler: if `$0AEC==1`, skip loot → defeat anim. Otherwise: death sound, decrement `$0AEC`/`$0AEE` counters, spawn `EnemyDeathFlash`, set dungeon kill flag, optionally spawn field-reveal effect if `deathActionIdx` set, then die. Referenced by: `av6D_dive_bat`, `gw82_fire_bug`, `gw8A_sand_fanger`. |
| `unused_window_config` | 13 | **Unused Window Setup** — Sets SNES `$WOBJSEL` to `$A0` (window/object layer selection), immediately returns. Likely discarded color-window or compositing setup. Unreferenced. |
| `unused_follow_chain` | 38 | **Unused Projectile Wrapper** — Marks enemy `$0010`, calls `dm_dm_follower_behavior.code_0ADC25` (burst effect), stores player actor ID, sets loop counter, tail-calls `smooth_follow_child`. Closely related to live `dm_dm_follower_behavior` but unreferenced. |
| `unused_proximity_check_noref_noref` | 9 | **Unused Proximity Test** — Runs `BranchIfPlayerNear(7)`, returns SEC if far / CLC if near. Designed as JSR helper, never referenced. Dead code. |
| `unused_random_position_noref_noref` | 15 | **Unused Random Pos Setter** — Sets `$14` from RNG byte, `$16` from RNG×2, `$08=#3C`. Simpler/less-centered variant of `RandomPlayerOffset`. Unreferenced. Dead code. |
| `RandomPlayerOffset` | 30 | **Random Position Near Player** — Sets actor `$14`/`$16` to player position ± RNG (centered ±128), sets `$08=#3C` wait timer. One-shot spawn initializer for effects near the player. Referenced by: `awB1_goldcap`, `pyDD_mummy_queen`. |

---

## 5. Observations

### 5.1 Bank Organization Pattern

Bank `$0A` follows the game's general pattern of grouping dungeon enemy actors
roughly in story/progression order:

1. **Early dungeons first** — Edward Castle aqueduct (`$0A8000`) and Incan Ruins (`$0A8896`)
2. **Mid-game dungeons** — Diamond Mine (`$0AA4E2`) and Sky Garden (`$0AB496`)
3. **Late-game dungeons** — Mu (`$0ADD9E`), Seaside Palace (`$0AE45C`), Angel Village (`$0AEA51`)
4. **Boss rush variants** (Neo Castoth, Neo Viper, Neo Vampires) are co-located with their original boss definitions rather than grouped separately

### 5.2 Boss Concentration

Three major boss fights reside in this bank:
- **Castoth** (2,499 bytes) — First dungeon boss. Dual-HP structure (wings + body), phase state in `$00F0`/`$00F2`, player-position-driven attack selection. Dodge counter-attack mechanic.
- **Viper** (2,974 bytes including arena actors) — Sky Garden boss. Jump slams, homing fireballs splitting into flame waves, 6-serpent easing projectiles, directional body attacks.
- **Vampire duo** (3,030 bytes) — Mu boss. Grid-based dual movement, bat swarm tile-line attacks, spiral projectiles, bat-form phase transformation, extensive dialogue.

Each boss includes both its normal and Neo (boss rush) variant in a single
parent block, with the Neo variant typically placed first.

### 5.3 Shared AI Patterns

Several common AI patterns recur across actors in this bank:

| Pattern | Used by |
|---------|---------|
| `BranchNearerAxis` → cardinal patrol | Ribber, Mudpit, Slugger, Scuttlebug, Flayzer, Eye Stalker, Cyclops |
| `BranchIfPlayerNear` → aggro transition | Ribber, Stone Guard, Splop, Whirligig, Flasher, Slipper, Dive Bat, Draco |
| `smooth_follow_child` homing | Ribber (projectile), Flasher (projectile), dm_dm_follower_behavior (popup body) |
| `ActorMidpointCalc` midpoint following | Draco (tail), Plasma Chain (segments), Flayzer (flame segments) |
| `EnemyDefeatDispatch` standard death | Dive Bat, and cross-bank enemies |
| `SetPlayerGameOverFlag` boss kill flash | Castoth, Viper, Vampires (all 3 bosses) |
| `InitSpiral`/`SpiralStep` | Vampires (spiral projectiles) |
| Wall-following patrol | Eye Stalker, Plasma Snake, Dynapede, Nitropede |
| Two-phase activation | Skull Chaser (harmless→revived), Knight Armor (statue→combat), Stone Guard (dormant→awake), Eye Stalker (closed→open) |

### 5.4 Coverage

At 98.1% mapped with only a 633-byte unmapped tail, this is one of the most
thoroughly documented actor banks. All blocks are marked `movable: true`,
indicating they can be relocated during rebuild without breaking references.

### 5.5 Cross-Bank References

Many actors in this bank reference shared engine code:
- `StandardEnemyDefeatHandler` — standard defeat animation/reward
- `sE6_gaia` — Dark Space form-change system (bosses only)
- `enemy_stats_table` — HP/ATK/DEF/EXP lookup
- `table_0EE000` — metasprite frame definitions
- `smooth_follow` — homing projectile/follower system
- `SetPlayerGameOverFlag` — boss-kill invulnerability flash (shared within this bank)
- `ActorMidpointCalc` — chain/tail midpoint following (shared within this bank)
- `EnemyDefeatDispatch` — standard enemy death pipeline (shared within this bank)
