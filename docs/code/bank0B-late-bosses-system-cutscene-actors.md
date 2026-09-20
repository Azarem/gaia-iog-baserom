# Bank $0B — Late Bosses, System & Cutscene Actors

> ROM bank `$0B` (`$0B8000`–`$0BFFFF`, 32,768 bytes) is a **mixed-content bank**
> containing dungeon enemy actors from four late-game regions, two major boss
> complexes (Sand Fanger, Mummy Queen), system UI actors (boot logos, title
> screen, diary menu), prologue and ending cutscene sequences, and the debug man
> actor. Unlike the purely dungeon-focused banks $08–$0A, bank $0B serves as a
> catch-all for late-game enemies that didn't fit into earlier banks and several
> core system actors.
>
> The bank holds **104 mapped pieces** across 51 parent blocks and 11 scene
> clusters. Coverage is **95.7%** mapped.

---

## 1. Coverage Summary

| Metric | Value |
|--------|-------|
| Bank range | `$0B8000`–`$0BFFFF` (753,664–786,431) |
| Total bank size | 32,768 bytes |
| Mapped | 31,346 bytes (95.7%) |
| Unmapped gap | 2 bytes at `$0BC8B8`–`$0BC8B9` |
| Unmapped tail | 1,420 bytes at `$0BFA74`–`$0BFFFF` |
| Parent blocks | 51 distinct blocks in `blocks.json` |
| Total pieces | 104 |
| Piece types | ~40 × `actor-def`, ~40 × `Code`, 5 × `SpriteString`, 4 × `DialogString`, 5 × `&DialogString`, 1 × `&Word`, 1 × `Binary`, 1 × `&diary-entry` |
| Named scenes | 15 distinct scene tags |
| Pinned blocks | 9 blocks with `movable: false` |

---

## 2. Scene Group Summary

| Scene Group | Bytes | % of Bank | Blocks | Primary Content |
|-------------|------:|----------:|-------:|-----------------|
| Great Wall | 6,203 | 18.9% | 7 | Sand Fanger / Neo Fanger boss, Fire Bug, Eyesore, Archer, Asp, Wall Spear |
| Angkor Wat | 4,661 | 14.2% | 7 | Zip Fly, Shrubber, Zombie, Gorgon, Wall Walker, Goldcap |
| Mountain Temple | 3,492 | 10.7% | 5 | Fire Sprite, Skulker, Yorrick, Acid Spider |
| Diary Menu | 5,320 | 16.2% | 2 | Full diary menu system, diary entry string table |
| Ending Cutscenes | 3,775 | 11.5% | 3 | Epilogue (Comet), Changed World, New Babel |
| Pyramid — Mummy Queen | 2,416 | 7.4% | 9 | Mummy Queen / Neo Queen boss, support actors, teleporter |
| Prologue Cutscenes | 2,217 | 6.8% | 7 | Prologue cutscene actors 1–5, sprite strings, thinkers |
| Pyramid — Enemies | 1,810 | 5.5% | 4 | Haunt, Tuts, Mystic Ball, Blaster |
| Debug | 856 | 2.6% | 1 | Debug man actor |
| System (Boot/Title) | 362 | 1.1% | 3 | Boot logo actor, title screen actors |
| Generic / Shared | 234 | 0.7% | 3 | Unscened utility actors |
| **Unmapped** | **1,422** | **4.3%** | — | Tail pad `$0BFA74`–`$0BFFFF` + 2-byte gap |

---

## 3. Memory Map

### 3.1 Full Address Map

| Address | End | Size | Block / Part | Type | Scene Group |
|---------|-----|-----:|--------------|------|-------------|
| `$0B8000` | `$0B8BF8` | 3,064 | `gw8A_sand_fanger` / `btF5_neo_fanger` | actor-def | Great Wall |
| `$0B8BF8` | `$0B8C30` | 56 | `gw88_short_wall_spear` | actor-def | Great Wall |
| `$0B8C30` | `$0B8C70` | 64 | `gw82_wall_spear` | actor-def | Great Wall |
| `$0B8C70` | `$0B8DBE` | 334 | `gw82_fire_bug` | actor-def | Great Wall |
| `$0B8DBE` | `$0B8EF2` | 308 | `gw82_eyesore` | actor-def | Great Wall |
| `$0B8EF2` | `$0B9423` | 1,329 | `gw82_archer` | actor-def | Great Wall |
| `$0B9423` | `$0B983B` | 1,048 | `gw83_asp` | actor-def | Great Wall |
| `$0B983B` | `$0B9BA2` | 871 | `mtA1_fire_sprite` / `mtA1_fire_sprite` | actor-def | Mountain Temple |
| `$0B9BA2` | `$0B9BAC` | 10 | `mtA0_skulker` / `mtA0_skulker1` | actor-def | Mountain Temple |
| `$0B9BAC` | `$0B9C44` | 152 | `mtA0_skulker` / `mtA0_skulker_ns` | actor-def | Mountain Temple |
| `$0B9C44` | `$0B9C4E` | 10 | `mtA0_skulker` / `mtA0_skulker2` | actor-def | Mountain Temple |
| `$0B9C4E` | `$0B9D0F` | 193 | `mtA0_skulker` / `mtA0_skulker_ew` | actor-def | Mountain Temple |
| ↳ `$0B9CE8` | `$0B9D0F` | 39 | `gw8A_sand_fanger` / `sub_0B9CE8` *(shared)* | Code | Great Wall |
| `$0B9D0F` | `$0B9DCD` | 190 | `mtA1_yorrick_ns` / `mtA1_yorrick_1` | actor-def | Mountain Temple |
| `$0B9DCD` | `$0B9E8B` | 190 | `mtA1_yorrick_ns` / `mtA1_yorrick_2` | actor-def | Mountain Temple |
| `$0B9E8B` | `$0B9F53` | 200 | `mtA1_yorrick_ew` / `mtA1_yorrick_3` | actor-def | Mountain Temple |
| `$0B9F53` | `$0BA01D` | 202 | `mtA1_yorrick_ew` / `mtA1_yorrick_4` | actor-def | Mountain Temple |
| `$0BA01D` | `$0BA049` | 44 | `mtA0_acid_spider` / `mtA0_acid_spider1` | actor-def | Mountain Temple |
| `$0BA049` | `$0BA075` | 44 | `mtA0_acid_spider` / `mtA0_acid_spider2` | actor-def | Mountain Temple |
| `$0BA075` | `$0BA0A1` | 44 | `mtA0_acid_spider` / `mtA0_acid_spider3` | actor-def | Mountain Temple |
| `$0BA0A1` | `$0BA0CF` | 46 | `mtA0_acid_spider` / `mtA0_acid_spider4` | actor-def | Mountain Temple |
| `$0BA0CF` | `$0BA5D5` | 1,286 | `mtA0_acid_spider` / `mtA0_acid_spider5` | actor-def | Mountain Temple |
| `$0BA5D5` | `$0BA5DF` | 10 | `mtA1_fire_sprite` / `sub_0BA5D5` | Code | Mountain Temple |
| `$0BA5DF` | `$0BA61A` | 59 | `pyDD_actor_0BA5DF` | actor-def | Pyramid (Queen) |
| `$0BA61A` | `$0BAAAA` | 1,168 | `pyDD_mummy_queen` / `btF6_neo_queen` | actor-def | Pyramid (Queen) |
| `$0BAAAA` | `$0BABB3` | 265 | `py_queen_actor_0BAAAA` | Code | Pyramid (Queen) |
| `$0BABB3` | `$0BAC7D` | 202 | `py_queen_actor_0BABB3` | Code | Pyramid (Queen) |
| `$0BAC7D` | `$0BACB4` | 55 | `pyDD_mummy_queen` / `code_0BAC7D` | Code | Pyramid (Queen) |
| `$0BACB4` | `$0BACBC` | 8 | `mummy_queen_angle_table` | Binary | Pyramid (Queen) |
| `$0BACBC` | `$0BAD6B` | 175 | `py_queen_actor_0BACBC` | Code | Pyramid (Queen) |
| `$0BAD6B` | `$0BADBE` | 83 | `py_queen_actor_0BAD6B` | Code | Pyramid (Queen) |
| `$0BADBE` | `$0BADC7` | 9 | `pyDD_actor_0BADBE` | actor-def | Pyramid (Queen) |
| `$0BADC7` | `$0BAF4F` | 392 | `pyDD_teleporter` | actor-def | Pyramid (Queen) |
| `$0BAF4F` | `$0BB1B4` | 613 | `awB0_zip_fly` | actor-def | Angkor Wat |
| `$0BB1B4` | `$0BB275` | 193 | `awB0_shrubber` | actor-def | Angkor Wat |
| `$0BB275` | `$0BB817` | 1,442 | `awB0_zombie` | actor-def | Angkor Wat |
| `$0BB817` | `$0BBB5C` | 837 | `awB1_gorgon` | actor-def | Angkor Wat |
| `$0BBB5C` | `$0BBD8D` | 561 | `awB1_wall_walker` / `awB1_wall_walker1` | actor-def | Angkor Wat |
| `$0BBD8D` | `$0BBEE9` | 348 | `awB1_goldcap` / `awB1_goldcap` | actor-def | Angkor Wat |
| `$0BBEE9` | `$0BBF8C` | 163 | `aw_actor_0BBEE9` | Code | Angkor Wat |
| `$0BBF8C` | `$0BBFBB` | 47 | `awB1_goldcap` / `code_0BBF8C` | Code | Angkor Wat |
| `$0BBFBB` | `$0BC184` | 457 | `awB1_wall_walker` / `awB1_wall_walker3` | actor-def | Angkor Wat |
| `$0BC184` | `$0BC39D` | 537 | `pyD2_haunt` | actor-def | Pyramid (Enemies) |
| `$0BC39D` | `$0BC5A3` | 518 | `pyCE_tuts` | actor-def | Pyramid (Enemies) |
| `$0BC5A3` | `$0BC798` | 501 | `pyCC_mystic_ball` | actor-def | Pyramid (Enemies) |
| `$0BC798` | `$0BC896` | 254 | `pyCC_blaster` | actor-def | Pyramid (Enemies) |
| `$0BC896` | `$0BC8B8` | 34 | `sFB_boot_logo` / `BootLogoPalTextFallback` | Code | System (Boot) |
| `$0BC8B8` | `$0BC8BA` | 2 | *(unmapped gap)* | — | — |
| `$0BC8BA` | `$0BC924` | 106 | `sFB_boot_logo` / `sFB_boot_logo` | actor-def | System (Boot) |
| `$0BC924` | `$0BC9AE` | 138 | `sFC_title_intro` | actor-def | System (Title) |
| `$0BC9AE` | `$0BCA02` | 84 | `sFC_title_start_handler` | actor-def | System (Title) |
| `$0BCA02` | `$0BCB4E` | 332 | `pr8C_prologue1` / `pr8C_prologue1` | actor-def | Prologue |
| `$0BCB4E` | `$0BCD4B` | 509 | `pr8D_prologue2` / `pr8D_prologue2` | actor-def | Prologue |
| `$0BCD4B` | `$0BCE33` | 232 | `pr8E_prologue3` / `pr8E_prologue3` | actor-def | Prologue |
| `$0BCE33` | `$0BCE79` | 70 | `pr8F_prologue4` / `pr8F_prologue4` | actor-def | Prologue |
| `$0BCE79` | `$0BCF52` | 217 | `pr8C_prologue5` / `pr8C_prologue5` | actor-def | Prologue |
| `$0BCF52` | `$0BD031` | 223 | `pr_actor_0BCF52` | Code | Prologue |
| `$0BD031` | `$0BD039` | 8 | `pr_thinkers` / `e_pr_thinker_0BD031` | Code | Prologue |
| `$0BD039` | `$0BD044` | 11 | `pr_thinkers` / `e_pr_thinker_0BD039` | Code | Prologue |
| `$0BD044` | `$0BD0B2` | 110 | `pr8C_prologue1` / `spritestring_0BD044` | SpriteString | Prologue |
| `$0BD0B2` | `$0BD1CA` | 280 | `pr8D_prologue2` / `spritestring_0BD0B2` | SpriteString | Prologue |
| `$0BD1CA` | `$0BD222` | 88 | `pr8E_prologue3` / `spritestring_0BD1CA` | SpriteString | Prologue |
| `$0BD222` | `$0BD272` | 80 | `pr8F_prologue4` / `spritestring_0BD222` | SpriteString | Prologue |
| `$0BD272` | `$0BD2AB` | 57 | `pr8C_prologue5` / `spritestring_0BD272` | SpriteString | Prologue |
| `$0BD2AB` | `$0BD306` | 91 | `particle_rain_spawner` | actor-def | Generic |
| `$0BD306` | `$0BDE40` | 2,874 | `sE5_epilogue` | actor-def | Ending |
| `$0BDE40` | `$0BE029` | 489 | `s90_changed_world` | actor-def | Ending |
| `$0BE029` | `$0BE1C5` | 412 | `s89_new_babel` | actor-def | Ending |
| `$0BE1C5` | `$0BE237` | 114 | `dialog_string_scanner` | actor-def | Generic |
| `$0BE237` | `$0BE2CC` | 149 | `sFA_diary_menu` / `sFA_diary_menu` | actor-def | Diary Menu |
| `$0BE2CC` | `$0BE673` | 935 | `sFA_diary_menu` / `DiaryMainMenuEntry` | Code | Diary Menu |
| `$0BE673` | `$0BE6BA` | 71 | `sFA_diary_menu` / `ApplySoundAndRemap` | Code | Diary Menu |
| `$0BE6BA` | `$0BE840` | 390 | `sFA_diary_menu` / `DiarySndBtnTab` | Code | Diary Menu |
| `$0BE840` | `$0BE87C` | 60 | `sFA_diary_menu` / `ReadSramSettings` | Code | Diary Menu |
| `$0BE87C` | `$0BE8A8` | 44 | `sFA_diary_menu` / `WriteSramSettings` | Code | Diary Menu |
| `$0BE8A8` | `$0BEBF9` | 849 | `sFA_diary_menu` / `DiaryCopyTab` | Code | Diary Menu |
| `$0BEBF9` | `$0BEC06` | 13 | `sFA_diary_menu` / `DiaryMenuClearVram` | Code | Diary Menu |
| `$0BEC06` | `$0BEC3E` | 56 | `sFA_diary_menu` / `func_0BEC06_noref` | Code | Diary Menu |
| `$0BEC3E` | `$0BECB1` | 115 | `sFA_diary_menu` / `DiaryCursorApplyMove` | Code | Diary Menu |
| `$0BECB1` | `$0BECD9` | 40 | `sFA_diary_menu` / `DiaryDrawCursorHighlight` | Code | Diary Menu |
| `$0BECD9` | `$0BECFB` | 34 | `sFA_diary_menu` / `DiaryClearCursor` | Code | Diary Menu |
| `$0BECFB` | `$0BED3C` | 65 | `sFA_diary_menu` / `DiaryClearAllCursors` | Code | Diary Menu |
| `$0BED3C` | `$0BED64` | 40 | `sFA_diary_menu` / `table_0BED3C` | &Word | Diary Menu |
| `$0BED64` | `$0BEE20` | 188 | `sFA_diary_menu` / `DiaryScanSramSlots` | Code | Diary Menu |
| `$0BEE20` | `$0BF178` | 856 | `debug_man` | actor-def | Debug |
| `$0BF178` | `$0BF1A2` | 42 | `sFA_diary_menu` / `func_0BF178_noref` | Code | Diary Menu |
| `$0BF1A2` | `$0BF1A6` | 4 | `sFA_diary_menu` / `func_0BF1A2_noref` | Code | Diary Menu |
| `$0BF1A6` | `$0BF1AA` | 4 | `sFA_diary_menu` / `func_0BF1A6_noref` | Code | Diary Menu |
| `$0BF1AA` | `$0BF1DB` | 49 | `sFA_diary_menu` / `func_0BF1AA_noref` | Code | Diary Menu |
| `$0BF1DB` | `$0BF24B` | 112 | `sFA_diary_menu` / `FormatBcdNumber` | Code | Diary Menu |
| `$0BF24B` | `$0BF259` | 14 | `sFA_diary_menu` / `func_0BF24B_noref` | Code | Diary Menu |
| `$0BF259` | `$0BF260` | 7 | `sFA_diary_menu` / `func_0BF259_noref` | Code | Diary Menu |
| `$0BF260` | `$0BF261` | 1 | `sFA_diary_menu` / `func_0BF260_noref` | Code | Diary Menu |
| `$0BF261` | `$0BF2A6` | 69 | `sFA_diary_menu` / `func_0BF261_noref` | Code | Diary Menu |
| `$0BF2A6` | `$0BF3F4` | 334 | `sFA_diary_menu` / `DiaryMenuVBlankHandler` | Code | Diary Menu |
| `$0BF3F4` | `$0BF63B` | 583 | `sFA_diary_menu` / `dialogstring_0BF3F4` | DialogString | Diary Menu |
| `$0BF63B` | `$0BF667` | 44 | `sFA_diary_menu` / `table_0BF63B` | &DialogString | Diary Menu |
| `$0BF667` | `$0BF679` | 18 | `sFA_diary_menu` / `table_0BF667` | &DialogString | Diary Menu |
| `$0BF679` | `$0BF6A4` | 43 | `sFA_diary_menu` / `dialogstring_0BF679` | DialogString | Diary Menu |
| `$0BF6A4` | `$0BF6AD` | 9 | `sFA_diary_menu` / `dialogstring_0BF6A4` | DialogString | Diary Menu |
| `$0BF6AD` | `$0BF6B3` | 6 | `sFA_diary_menu` / `table_0BF6AD` | &DialogString | Diary Menu |
| `$0BF6B3` | `$0BF6D9` | 38 | `sFA_diary_menu` / `dialogstring_0BF6B3` | DialogString | Diary Menu |
| `$0BF6D9` | `$0BF706` | 45 | `sFA_diary_menu` / `table_0BF6D9` | &DialogString | Diary Menu |
| `$0BF706` | `$0BFA57` | 849 | `strings_0BF706` | &diary-entry | Diary Menu |
| `$0BFA57` | `$0BFA74` | 29 | `debug_stat_setter` | actor-def | Generic |
| `$0BFA74` | `$0BFFFF` | 1,420 | *(unmapped tail)* | — | — |

---

## 4. Block Overview by Scene Group

### 4.1 Great Wall — Enemies & Sand Fanger Boss

**Address range:** `$0B8000`–`$0B983B` (6,203 bytes)
**Validated scenes:** `$82` Entrance, `$83` Long Dive, `$85` Rampway, `$86` Blind Pit, `$87` Switchback, `$88` Tomb, `$8A` Sand Fanger Lair, `$F5` Dark Fanger Lair (Babel Tower)
**Extracted files:** `great_wall/sand_fanger_lair/`, `great_wall/wall_tomb/`, `great_wall/`

#### `gw8A_sand_fanger` / `btF5_neo_fanger` — Sand Fanger Boss (3,064 bytes)

Multi-phase boss actor spawned in scene `$8A` (Sand Fanger Lair) and scene `$F5` (Dark Fanger Lair — Babel Tower rematch). The arena setup creates `SolidHighAbs` barrier tiles and triggers the fight when the player enters specific tile zones, playing music `#0F`. The boss cycles through RNG-weighted attack patterns including orbital swoops (`ApplyOrbitalOffsetXY`), horizontal sweeps toward the player, and minion spawns when the active actor count drops below threshold. The `btF5_neo_fanger` entry point provides an alternate intro for the Babel Tower rematch, hijacking the player script with different post-fight flow. On defeat, the standard boss reward sequence clears spawned helpers, prints *"You've defeated the Sand Fanger!"*, and transitions to scene `$FD`. A shared subroutine `sub_0B9CE8` at `$0B9CE8` (physically within the Skulker's address range) provides sine-scaled offset calculations used by the boss.

Key sub-actors:
- **Orbiting eye minions** — 4 attack modes each, flag-driven
- **Burrowing sand worm** — HP from `enemy_stats_table+DC`, gravity movement, homing projectiles via `smooth_follow_child`
- **Directional leap/projectile** sub-actors spawned from attack animations

#### `gw88_short_wall_spear` — Short Wall Spear Trap (56 bytes)

**Scene:** `$88` (Tomb) only. A single-tile retractable spear trap that loops: waits `$3B` frames, plays sound `#1E`, extends with sprite `#1D` + `SolidHighHere`, then retracts. Shorter reach than the standard variant — no adjacent-tile collision.

#### `gw82_wall_spear` — Standard Wall Spear Trap (64 bytes)

**Scenes:** `$82`, `$83`, `$85`, `$87`, `$88`. Same extend/retract cycle as the short variant but **2 tiles tall**: extends with sprite `#1F`, sets `SolidHighHere` plus `SolidHighOffset(#00,#03)`, then retracts with matching clears.

#### `gw82_fire_bug` — Fire Bug Enemy (334 bytes)

**Scenes:** `$82`, `$83`, `$85`, `$87`. Ground enemy (body `#18`) that patrols horizontally between spawn-point bounds via `MoveToward`, using `BranchOnPlayerX` for targeting. When the player is centered on X, performs a gravity leap: sets facing sprite, `InitGravity`, falls while moving horizontally, and on landing spawns a fire debris child that bounces along the ground with sound `#21`.

#### `gw82_eyesore` — Eyesore Enemy (308 bytes)

**Scenes:** `$82`, `$83`, `$85`, `$88`. Floating eye enemy (body `#00`) that waits offscreen, peeks briefly, then `MoveToward` a random offset from its position. When the player is within 4 tiles, enters attack mode: spawns **two** gravity projectiles with randomized horizontal velocity. Projectiles fall with gravity and stick as looping hazards or die if behind a wall.

#### `gw82_archer` — Archer Enemy Family (1,329 bytes)

**Scenes:** `$82`, `$83`, `$85`, `$86`, `$87`, `$88`. The largest enemy block in the bank — a shared codebase containing **8 named entry points** for distinct archer subtypes:

| Entry | Scenes | Behavior |
|-------|--------|----------|
| `gw82_archer1` | `$82`–`$88` | Right-facing shooter, fires repeatedly from fixed position |
| `gw82_archer2` | `$82`–`$88` | Left-facing shooter (H-flipped) |
| `gw82_archer3` | `$82`–`$88` | Omnidirectional — aims by player position, dodge-steps vertically, lunges when close |
| `gw83_stone_archer1`/`2` | `$83`, `$86`, `$88` | Sleeping stone statues sharing wake logic |
| `gw83_stone_archer3` | `$83`, `$86`, `$88` | Stone statue; wakes on proximity + gridline alignment |
| `gw83_stone_archer4` | `$88` | Stone statue; wakes when **hit** (`SetHitCallback`) |
| `gw87_statue_archer` | `$87` | Pushable puzzle — player shoves one tile when facing; activates as living archer when flag `#0F` is set |

Arrow projectiles travel until blocked and apply `ApplyPlayerHitstun` on impact.

#### `gw83_asp` — Asp (Snake) Enemy (1,048 bytes)

**Scenes:** `$83`, `$85`, `$86`, `$88`. Snake enemy (body `#13`) that tracks the player's horizontal position to pick facing frames. When the player crosses in front, it strikes with an attack animation + sound `#1D` and launches a **bite grapple**: joypad is masked and the player must mash buttons to pull free in a tug-of-war minigame. Prolonged grapple applies heavier hitstun. After release, the asp returns to patrol.

### 4.2 Mountain Temple — Enemies

**Address range:** `$0B983B`–`$0BA5DF` (3,492 bytes)
**Validated scenes:** `$A0` Entrance, `$A1` Twisted Paths, `$A2` Crossroads, `$A3` Treasure Gauntlet, `$A4` Western Loop, `$A5` Broken Vines, `$A6` Mushroom Field, `$A7` Vine Maze, `$A8` Detour
**Extracted files:** `mountain_temple/`

#### `mtA1_fire_sprite` — Fire Sprite Enemy (881 bytes)

**Scenes:** `$A1`, `$A5`, `$A6`, `$A7`, `$A8`. Floating fire enemy that idles offscreen until `BranchIfPlayerNear` triggers combat. On aggro, spawns **four orbiting fire orbs** via `SpawnMarkedAfter` that orbit the parent with `ApplyOrbitalOffsetFromRef`, spiral inward/outward by adjusting orbit diameter, then home in on the player and self-destruct. The parent `MoveToward`s the player during combat and wanders randomly when not aggroed. Helper `sub_0BA5D5` provides a −31…+31 RNG offset.

#### `mtA0_skulker` — Skulker Enemy (365 bytes, 4 variants)

**Scenes:** `$A0`–`$A7` (all Mt. Temple combat rooms). Patrolling corridor enemy that oscillates along one axis using sine-table math (`sub_0B9CE8`). **Four entry points** provide orientation stubs:

| Entry | Behavior |
|-------|----------|
| `mtA0_skulker1` | Stub → N/S patrol (forces vertical movement, wobbles X) |
| `mtA0_skulker_ns` | Full N/S patrol body |
| `mtA0_skulker2` | Stub → E/W patrol (forces horizontal movement, wobbles Y) |
| `mtA0_skulker_ew` | Full E/W patrol body; optional `SetHFlip` entry |

Reverses direction when travel distance hits threshold `$0150`.

#### `mtA1_yorrick_ns` — Yorrick N/S Enemy (380 bytes)

**Scenes:** `$A1`, `$A3`–`$A8`. Skull-throwing enemy for N/S corridors. Uses `BranchOnPlayerY` to detect alignment and `BranchIfPlayerInRelTiles` for adjacency. In range: windup animation, then `SpawnAfterRelFlags` launches two skull projectiles that rise via `StageSpriteMoveY` and die offscreen. Out of range: patrols horizontally.

| Entry | Behavior |
|-------|----------|
| `mtA1_yorrick_1` | Standard N/S; patrol frame `#02`, attack `#1A` |
| `mtA1_yorrick_2` | Inverted routing for opposite map layouts; patrol `#03`, attack `#1B` |

#### `mtA1_yorrick_ew` — Yorrick E/W Enemy (402 bytes)

**Scenes:** `$A1`–`$A7`. E/W counterpart — uses `BranchOnPlayerX`, patrols vertically when player not adjacent, throws skulls horizontally.

| Entry | Behavior |
|-------|----------|
| `mtA1_yorrick_3` | Standard E/W; patrol/attack frame `#04`, windup `#1C` |
| `mtA1_yorrick_4` | H-flipped variant; flipped frame `#84`, attack loop `#9C` |

#### `mtA0_acid_spider` — Acid Spider Enemy (1,464 bytes, 5 variants)

**Scenes:** `$A0`–`$A7` (most common enemy in the dungeon). Multi-part spider with 4 directional sentry stubs + 1 main combat body:

| Entry | Behavior |
|-------|----------|
| `mtA0_acid_spider1` | North-facing sentry; triggers on player to the north |
| `mtA0_acid_spider2` | East-facing sentry |
| `mtA0_acid_spider3` | West-facing sentry |
| `mtA0_acid_spider4` | East-facing flipped sentry |
| `mtA0_acid_spider5` | **Main AI** (1,286 bytes) — chases via `BranchNearerAxis`, 50% RNG branch to spit vs lunge |

When blocked, the main body performs a **leap attack**: spawns marker + 4 trail hitboxes, lands with `MoveToward`, then `KillNext` clears trail actors. Acid spit projectiles arc via `AddPosition` + `MoveToward`, play sound `#1E`, and explode on contact.

### 4.3 Pyramid — Mummy Queen Boss Complex

**Address range:** `$0BA5DF`–`$0BAF4F` (2,416 bytes)
**Validated scenes:** `$DD` Mummy Queen's Lair (scene 221), `$F6` Dark Queen's Lair (Babel Tower, scene 246)
**Extracted files:** `pyramid/mummy_queen_lair/`

#### `pyDD_actor_0BA5DF` — Arena Side Tracker (59 bytes)

Invisible helper actor in scenes `$DD`/`$F6` that tracks which side of the room the player is on. Uses `BranchIfPlayerInAbsTiles` on two tile rectangles (left/right halves) to set/clear bit 0 of the player's `$0010` flags, and loops while the player is at the entrance row (Y = `$01B0`).

#### `pyDD_mummy_queen` / `btF6_neo_queen` — Mummy Queen Boss (1,168 bytes)

Main boss controller with a **random 8-way action loop** (`SwitchCase` + `RngByte`):
- **Random repositioning** — `StageMove` to random arena positions
- **Charge attack** — spawns a homing follower via `smooth_follow_child`
- **Roar attack** — spawns camera shake controller (`py_queen_actor_0BACBC`)

Hit handling is **phase-based** (`orbitAngle` counter):
- **Phase 1** (orbitAngle < 2): spawns 7 orbiting eye projectiles (`py_queen_actor_0BAAAA`)
- **Phase 2** (orbitAngle ≥ 2): spawns 7 player-tracking homing orbs (`py_queen_actor_0BABB3`)

HP thresholds at `$0014`/`$001E` trigger palette thinkers `#5C`/`#5D`. Death runs a particle burst and `StandardEnemyDefeatHandler`. The `btF6_neo_queen` entry provides the Dark Queen intro for the Babel Tower rematch, swapping the player handler. On defeat, transitions to scene `$E3` (Babel Upper Floors).

#### `py_queen_actor_0BAAAA` — Phase 1 Orbiting Eye (265 bytes)

Runtime spawn from Queen phase-1 hit callback. Picks an orbit angle from `mummy_queen_angle_table` (evenly spaced at `$20` intervals), expands orbit diameter, then orbits the Queen via `ApplyOrbitalOffsetFromRef`. Death callback clears the parent's projectile counter to re-enable attacks.

#### `py_queen_actor_0BABB3` — Phase 2 Homing Orb (202 bytes)

Runtime spawn from Queen phase-2 hit callback. Starts with a short expanding orbit, then switches to `smooth_follow.InitFollowAndChase` targeting the player. Calls `aw_actor_0BBEE9.code_0BBF64` each frame for animation stepping.

#### `mummy_queen_angle_table` — Orbit Angle Lookup (8 bytes)

Data table: `$00, $20, $40, $60, $80, $A0, $C0, $E0` — orbit angle offsets indexed by spawn order (1–7) for the Queen's projectile ring.

#### `py_queen_actor_0BACBC` — Camera Shake Controller (175 bytes)

Spawned by the Queen's roar attack. Runs palette flash (`PaletteStart #5F`), then jitters `cameraTargetX/Y` randomly. After 32 ticks, spawns falling debris (`py_queen_actor_0BAD6B`). A second mode loops 120 frames for sustained shake.

#### `py_queen_actor_0BAD6B` — Falling Rubble (83 bytes)

Gravity-based rubble projectile spawned during roar/shake sequences. Random X/Y spawn, horizontal drift with occasional H-flip, sound `#15` on ground impact with camera Y nudge. Dies when Y ≥ `$0200`.

#### `pyDD_actor_0BADBE` — Corner Marker Stub (9 bytes)

Minimal actor at tile positions `(4,12)` and `(27,12)` — flanks the teleporter columns. Sets `$08` to `$7FFF` and exits. Initializes max interaction range for the teleporter pair.

#### `pyDD_teleporter` — Boss Room Teleporter Pads (392 bytes)

Pair of floor teleporter pads linking the room's left (`$04,27`) and right (`$27,27`) sides. When the player is near and not already warping, disables input, runs warp animation with metasprite swaps and sound `#0C`, swaps player/pad positions, toggles facing, and restores control. Uses flag byte `#01` as a re-entry lock.

### 4.4 Angkor Wat — Enemies

**Address range:** `$0BAF4F`–`$0BC184` (4,661 bytes)
**Validated scenes:** `$B0` Entrance, `$B1` Outer Gate, `$B2` Outer East, `$B3` Outer North, `$B4` Snake Pit, `$B5` Outer West, `$B6` Outer Courtyard, `$B7` Inner Gate, `$B8` Inner East, `$B9` Inner West, `$BA` Inner Courtyard, `$BB`–`$BE` Shrine rooms
**Extracted files:** `angkor_wat/`

#### `awB0_zip_fly` — Zip Fly (613 bytes)

**Scenes:** `$B0`, `$B6`. Ambient flying insect that patrols within ~64 px of its spawn point using RNG-selected cardinal/diagonal `StageSpriteLoopMove` paths. When the player enters a 4-tile radius, uses `DirToPlayer` to lunge via 8-way `SwitchCase`, then returns to patrol. Contact-damage only — no hit/death callbacks. Anchor position stored in `$7F100C`/`$7F100E`.

#### `awB0_shrubber` — Shrubber (193 bytes)

**Scenes:** `$B0` (`shrubber2`), `$B6` (both), `$BA` (`shrubber`). Bush enemy with two roles:
- **`awB0_shrubber`** — static solid bush (`SolidHighHere`, `SetHitCallback`); when hit, clears solidity and jumps into chase AI
- **`awB0_shrubber2`** — ambush variant; hides as bush until `BranchIfPlayerNear`, reveals with animation, then chases along nearer axis with wall-bounce via `BranchIfSolid*` checks and `StageSpriteMoveXY` lunges

#### `awB0_zombie` — Zombie (1,442 bytes)

**Scenes:** `$B0`, `$B6`, `$BA`. Largest Angkor Wat actor. Slow undead that patrols toward the player on the nearer axis in 2-step walk loops, pausing to face when close. Within 5 tiles: launches one of **four directional attack sequences** spawning moving hitbox child actors via `SpawnMarkedAfterRel`/`SpawnMarkedBefore`. On death, reloads lower HP stats from `enemy_stats_table+11C` and enters a **faster, more aggressive enraged chase** — a second-life mechanic.

#### `awB1_gorgon` — Gorgon (837 bytes)

**Scenes:** `$B1`, `$B2`, `$B5`, `$B7`–`$B9`, `$BE`. Snake enemy with two entry points:
- **`awB1_gorgon`** — floor crawler; RNG 4-direction patrol with solid checks; proximity triggers drop attack through tiles with sound `#15`, spawning petrify blinker and camera-drift death FX
- **`awB1_gorgon2`** — trigger variant; sequentially spawns 9 attack segments with `WaitByte` delays for a multi-segment falling-strike sequence, then `KillNext` ×9 and resumes patrol

#### `awB1_wall_walker` — Wall Walker (1,018 bytes, split)

**Scenes:** `$B1`–`$B5`, `$B7`–`$BA`, `$BB`–`$BE` (widespread). Wall/ceiling spider family with ground and ceiling variants:

| Entry | Behavior |
|-------|----------|
| `awB1_wall_walker1` | Ground; horizontal baby-spider mode; `$26=1` |
| `awB1_wall_walker2` | Ground; vertical baby-spider mode; `$26=0` |
| `awB1_wall_walker3` | Ceiling patroller; palette `#0A`; direction from spawn byte |
| `awB1_wall_walker4` | Ceiling patroller with alternate `$26`/`$24` init |

**Ground behavior:** On hit, spawns 3 baby spiders (crawl west/east or north/south). `BranchIfPlayerNear` drops a pod that becomes a `smooth_follow` child chasing the player.
**Ceiling behavior:** 4-direction perimeter patrol via `SwitchCase` on `orbitAngle`; a monitor child increments parent `$0024` per hit until 8 → `Die`.
**Death:** `StandardEnemyDefeatHandler`; decrements `$0AEC`/`$0AEE`, `SetDungeonKillFlag`, may spawn `field_reveal_object` + `SpawnFieldRevealEffect`.

#### `awB1_goldcap` — Goldcap (395 bytes)

**Scenes:** `$B1`–`$B5`, `$B7`, `$B9`–`$BE` (most Angkor Wat rooms). Floating mushroom enemy that orbits its spawn point via `ApplyOrbitalOffsetXY`, expanding its path over time. When the player closes in, launches two flanking spore minions (`aw_actor_0BBEE9` left/right ±$20) and waits for them to be defeated before resuming orbit. Spore minions use `smooth_follow.InitFollowAndChase` to home on the player.

#### `aw_actor_0BBEE9` — Goldcap Spore Helper Code (163 bytes)

**Scenes:** Not directly spawned — runtime code called by `awB1_goldcap` and also reused by `py_queen_actor_0BABB3` (Mummy Queen fight). Two entry points offset ±$20 from parent X, each moving toward a randomized target at the player's Y level. Includes `code_0BBF64` — a reusable RNG animation-step helper called by multiple boss projectiles.

### 4.5 Pyramid — Dungeon Enemies

**Address range:** `$0BC184`–`$0BC896` (1,810 bytes)
**Validated scenes:** `$CC` Main Chamber, `$CE`–`$CF` Ramptastic A/B, `$D0`–`$D1` Meltdown A/B, `$D2`–`$D3` Focus A/B, `$D4`–`$D5` Trickle A/B, `$D6`–`$D7` Vader A/B, `$D8`–`$D9` Dangerslide A/B, `$DB` Dangerslide C
**Extracted files:** `pyramid/`

#### `pyD2_haunt` — Haunt (537 bytes)

**Scenes:** `$D2`–`$D3` (Focus), `$D5` (Trickle B), `$D8`–`$D9` (Dangerslide). Floating ghost with two-phase lifecycle:
- **`pyD2_haunt`** — dormant trigger; waits until `BranchIfPlayerNear`, then activates
- **`pyD5_haunt2`** — active chaser; pathfinds along nearer axis with solid-tile checks, picks random direction when blocked

On death, spawns a **smaller secondary ghost** with its own HP (`enemy_stats_table+134`), bounce-down entrance, and homing pursuit toward a randomized point near the player.

#### `pyCE_tuts` — Tuts / Mummy (518 bytes)

**Scenes:** `$CE`–`$D9`, `$DB` (most Pyramid rooms after entrance). Mummy enemy that patrols like the haunt when distant (`BranchNearerAxis`, solid-aware cardinal steps). Within 4 tiles: performs a **directional lunge** — windup frames, then `MoveToward` on X or Y. On init, spawns a marked callback that tags nearby actors for coordinated facing checks (group attack coordination via `$0010` flag).

#### `pyCC_mystic_ball` — Mystic Ball (501 bytes, 3 variants)

**Scenes:** `$CC`, `$CE`–`$D9`, `$DB` (all Pyramid combat rooms). Magical orb with axis-specific patrol variants:
- **`pyCC_mystic_ball`** — horizontal patroller
- **`pyCC_mystic_ball2`** — vertical patroller
- **`pyCC_mystic_ball3`** — idler that fires a burst of 5 projectiles via `SpawnAfterRelFlags` when player is south

**Death handler** is significant: if global counter `$0AEC` = 1, uses standard defeat; otherwise decrements counter, plays sound, sets `SetDungeonKillFlag`, and may spawn `field_reveal_object` + `SpawnFieldRevealEffect` (Pyramid statue reveal mechanic).

#### `pyCC_blaster` — Blaster (254 bytes)

**Scenes:** `$D2`–`$D9`, `$DB`. Stationary turret that periodically fires homing projectiles via `smooth_follow_child`. Spawns projectiles offset left/right of the player based on `BranchOnPlayerX`. When hit (`SetHitCallback`), reorients and enters a **rapid-fire burst mode** (`LoopInit #1E`) spawning projectiles every frame while onscreen.

### 4.6 System — Boot Logo & Title Screen Actors

**Address range:** `$0BC896`–`$0BCA02` (362 bytes + 2-byte gap)
**Validated scenes:** `$FB` Boot Logos (scene 251), `$FC` Title Screen (scene 252)
**Extracted files:** `system/boot_logos/`, `system/title_screen/`

#### `sFB_boot_logo` — Boot Sequence Controller (140 bytes)

**Scene:** `$FB`. Sets fast-ROM mode (`MEMSEL`), display flags, and joypad mask. Checks `STAT78` bit 4 for ROM configuration. On standard path: animates the Enix logo sprite (`StageSpriteLoop`), toggles flag byte `#10`, and queues map change to `$FC` (title). Alternate path (`BootLogoPalTextFallback`): loads ending comet palette, runs BG3 boot text via `RunBg3Script` with `boot_screen_strings`.

#### `sFC_title_intro` — Title Screen Orchestrator (138 bytes)

**Scene:** `$FC`. Primary title-screen director. Sets display mode and palettes, spawns a logo animation actor that slides in horizontally (`StageSpriteLoopMoveX`), displays two copyright strings with timed waits, sets flag `#F4`, then transitions to scene `$8C` (prologue start) via `QueueMapChange`.

#### `sFC_title_start_handler` — Start Button / Skip Handler (84 bytes)

**Scenes:** `$FC` (title screen), `$8C`–`$8F` (prologue scenes, spawned as `sFC_sFC_title_start_handler` variant). Masks joypad, polls for Start button (`$1001`). On press: clears gfx cache, queues map change to `$FA` (diary/save menu), waits through vblank, and blanks screen. On title screen this opens the diary menu; during prologue it acts as a skip gate.

### 4.7 Prologue — Cutscene Actors

**Address range:** `$0BCA02`–`$0BD2AB` (2,217 bytes)
**Validated scenes:** `$8C` Prologue — Prophecy (scene 140), `$8D` Prologue — Legends (141), `$8E` Prologue — Missing (142), `$8F` Prologue — Mishap (143)
**Extracted files:** `prologue/`

**Scene flow:** `$8C₁` → `$8D` → `$8E` → `$8F` → `$8C₅` → `$FC` (title)

#### `pr8C_prologue1` — Prologue: The Prophecy, Part 1 (332 + 110 bytes)

**Scene:** `$8C`. Opening prologue director. Spawns five decorative sprites that slide in with `StageSpriteMoveX` + `AnimOnce`, then runs a Mode 7 camera pan while narration text is shown through the shared text renderer. Uses palette thinkers for text fade-in/out. Transitions to `$8D`. Early exit if flag `#F4` is set (skip mode).

#### `pr8D_prologue2` — Prologue: The Legends (509 + 280 bytes)

**Scene:** `$8D`. Sequential legends montage driven by save-flag words (`#017C`–`#017F`). Each of four legend segments sets a flag, runs a camera-scroll variant, spawns narration text via `pr_actor_0BCF52`, and fades with `e_pr_thinker_0BD031`. After all beats play, advances to `$8E`.

#### `pr8E_prologue3` — Prologue: The Missing (232 + 88 bytes)

**Scene:** `$8E`. *"People who never returned"* segment. Sets additive blending and palette fade, auto-advances the player downward, then continuously spawns random drifting ghost/explorer sprites (`StageSpriteLoopMoveX`) that drift horizontally while narration plays. Transitions to `$8F`.

#### `pr8F_prologue4` — Prologue: The Mishap (70 + 80 bytes)

**Scene:** `$8F`. Short static narration about traps and curses. Displays one text block with palette fade thinkers, waits, then returns to scene `$8C` for the final prologue beat.

#### `pr8C_prologue5` — Prologue: Prophecy Finale (217 + 57 bytes)

**Scene:** `$8C` (second visit). Final narration (*"disaster…"*) over a Mode 7 downward camera pan. After text fade-out, camera continues scrolling, waits, then transitions to `$FC` (title/attract). Skip path via flag `#F4`.

#### `pr_actor_0BCF52` — Prologue Text Renderer (223 bytes)

Not scene-bound — shared utility. Parses `spritestring_*` data (character codes, line breaks) and builds OAM/tile entries for multi-line narration sprites. Computes horizontal centering from string width, lays out glyph tiles into WRAM (`$7F0600`), then dies. Called by all prologue scene actors.

#### `pr_thinkers` — Prologue Palette Thinkers (19 bytes)

Not scene-bound — shared palette-effect thinkers:
- **`e_pr_thinker_0BD031`** — text fade-in (palette `#75`)
- **`e_pr_thinker_0BD039`** — text fade-out (palette `#76`); also sets flag byte `#0F`

### 4.8 Generic / Shared Actors

**Scattered across bank** (234 bytes total)

#### `particle_rain_spawner` — Particle Effect Spawner (91 bytes)

**Scenes:** None (no spawn table entry; unreferenced). Visual-effect spawner that runs a countdown (120 → 4 frames) and repeatedly spawns short-lived metasprite particles that start at screen top (Y = `$FFE0`), get randomized X position and velocity, rise via `ReloadForceMove` until Y ≥ `$0200`, then die. Likely intended for ending/comet particle effects but appears orphaned in the final ROM.

#### `dialog_string_scanner` — Dialog String Streamer (114 bytes)

**Scenes:** None (no spawn table entry; unreferenced). Waits until `worldReadyFlag` is set, then iterates banks `$85`–`$8C` searching for dialog markers (`$BF02`). When found, calls `DialogStringRenderer` to render each string with `UpdateFrameRender`. The infinite loop suggests a **dev/test harness** or orphaned credits-text driver rather than a normal gameplay actor.

#### `debug_stat_setter` — Stat Init Bootstrap (29 bytes)

**Scenes:** None (no spawn table entry). One-shot stub that sets all player combat stats to `$0040` (64): `playerStr`, `playerDef`, `playerMaxHp`, and `damageFlashTimer`, then immediately dies. **Development/testing actor** for stat initialization.

### 4.9 Ending — Cutscene Actors

**Address range:** `$0BD306`–`$0BE1C5` (3,775 bytes)
**Validated scenes:** `$E5` Ending — Comet (scene 229), `$90` Ending — Changed World (scene 144), `$89` Ending — New Babel (scene 137)
**Extracted files:** `ending/`

**Scene flow:** `$E5` ⇄ `$90` → `$E5` → `$89` → `$F7` (credits)

#### `sE5_epilogue` — Comet Epilogue (2,874 bytes)

**Scene:** `$E5`. Main ending cutscene on the comet — the largest actor in the ending group. Disables input and runs an extended dialogue sequence between Will, Kara, his parents, and a "Strange Voice". Spawns spirit sprite actors (looping Y-bob animation, idle bob vs active drift variants), hijacks the player script for embrace/walk animations, moves Will toward Kara. Branches on flag `#DB`: first playthrough transitions to `$90` (Changed World); repeat path shows an extended parents-visible dialogue chain, then transitions to `$89` (New Babel). Contains 8 embedded dialog string blocks.

#### `s90_changed_world` — Changed World Interlude (489 bytes)

**Scene:** `$90`. "Map of the changed world" montage. Cycles through five background layers (`StageBgChange #80`–`#84`) with palette crossfades, then shows Will/father/Kara dialog explaining the new world geography before returning to `$E5`.

#### `s89_new_babel` — New Babel Finale (412 bytes)

**Scene:** `$89`. Final narration montage after the epilogue. Sets layered BG/subscreen registers, plays closing prose about the changed Earth and Tower of Babel (*"Tomorrow morning Kara and I…"*), starts ending music (`FadeThenStartMusic #14`), then exits to `$F7` (credits).

### 4.10 Diary Menu System

**Address range:** `$0BE237`–`$0BFA57` (5,320 bytes including diary strings)
**Validated scene:** `$FA` Diary Menu (scene 250)
**Extracted files:** `system/diary_menu/`

#### `sFA_diary_menu` — Trip Diary / Save Menu (4,471 bytes)

**Scene:** `$FA`. Full save/load/options UI actor. Initializes display layers and joypad remapping, then presents a **four-option main menu**:
1. **Start Journey** — slot picker with checksum validation + load confirmation; on success sets `$sceneNext` from save data
2. **Erase Trip Diary** — slot deletion with confirmation prompt
3. **Copy Trip Diary** — source → destination slot copy
4. **Change Sound + Buttons** — stereo/mono toggle and button remap submenu

Save slots display HP/STR/DEF stats via a BCD digit formatter (`FormatBcdNumber`). Selecting a diary slot triggers an animated camera pan to the saved location on the world map (`DiaryCameraPan`). New game starts at scene `$08` (South Cape church).

The block is **pinned** (`movable: false`). Several functions after the `debug_man` insertion are tagged `_noref` (unreferenced/orphaned code).

#### `strings_0BF706` — Diary Location Name Table (849 bytes)

Pointer table mapping progress indices to named save-resume points. Each entry embeds a target scene ID and coordinate for the world map camera. Referenced by `sFA_diary_menu` for slot display and camera positioning. Covers all major game locations from South Cape through Babel Tower, with a default *"Start from beginning"* fallback.

### 4.11 Debug Man

**Address:** `$0BEE20`–`$0BF178` (856 bytes)
**Scenes:** None (no spawn table entry)
**Extracted file:** `actors/debug_man.asm`

Developer debug NPC physically interleaved within the diary menu's address range. Sets `SolidHighHere` and `SetOnInteract`. On talk: **maxes player stats** (HP 40, STR/DEF 127, all abilities via `abilityBitmask = $FF`), then presents a **nested warp menu** via `DialogueOptions`. Six nested dialogue menus with 5 options each provide 20+ warp destinations across the game world (Great Wall `$82`, Pyramid `$CC`, Watermia `$78`, Babel `$B0`, Euro, Inca, Sky Garden, and more). Contains embedded dialog strings with location names in an English/Japanese mix.

---

## 5. Extracted File Index

### Great Wall
| File | Block |
|------|-------|
| `extracted/great_wall/sand_fanger_lair/gw8A_sand_fanger.asm` | `gw8A_sand_fanger` |
| `extracted/great_wall/wall_tomb/gw88_short_wall_spear.asm` | `gw88_short_wall_spear` |
| `extracted/great_wall/gw82_wall_spear.asm` | `gw82_wall_spear` |
| `extracted/great_wall/gw82_fire_bug.asm` | `gw82_fire_bug` |
| `extracted/great_wall/gw82_eyesore.asm` | `gw82_eyesore` |
| `extracted/great_wall/gw82_archer.asm` | `gw82_archer` |
| `extracted/great_wall/gw83_asp.asm` | `gw83_asp` |

### Mountain Temple
| File | Block |
|------|-------|
| `extracted/mountain_temple/mtA1_fire_sprite.asm` | `mtA1_fire_sprite` |
| `extracted/mountain_temple/mtA0_skulker.asm` | `mtA0_skulker` |
| `extracted/mountain_temple/mtA1_yorrick_ns.asm` | `mtA1_yorrick_ns` |
| `extracted/mountain_temple/mtA1_yorrick_ew.asm` | `mtA1_yorrick_ew` |
| `extracted/mountain_temple/mtA0_acid_spider.asm` | `mtA0_acid_spider` |

### Pyramid — Mummy Queen Lair
| File | Block |
|------|-------|
| `extracted/pyramid/mummy_queen_lair/pyDD_actor_0BA5DF.asm` | `pyDD_actor_0BA5DF` |
| `extracted/pyramid/mummy_queen_lair/pyDD_mummy_queen.asm` | `pyDD_mummy_queen` |
| `extracted/pyramid/mummy_queen_lair/py_queen_actor_0BAAAA.asm` | `py_queen_actor_0BAAAA` |
| `extracted/pyramid/mummy_queen_lair/py_queen_actor_0BABB3.asm` | `py_queen_actor_0BABB3` |
| `extracted/pyramid/mummy_queen_lair/mummy_queen_angle_table.asm` | `mummy_queen_angle_table` |
| `extracted/pyramid/mummy_queen_lair/py_queen_actor_0BACBC.asm` | `py_queen_actor_0BACBC` |
| `extracted/pyramid/mummy_queen_lair/py_queen_actor_0BAD6B.asm` | `py_queen_actor_0BAD6B` |
| `extracted/pyramid/mummy_queen_lair/pyDD_actor_0BADBE.asm` | `pyDD_actor_0BADBE` |
| `extracted/pyramid/mummy_queen_lair/pyDD_teleporter.asm` | `pyDD_teleporter` |

### Angkor Wat
| File | Block |
|------|-------|
| `extracted/angkor_wat/awB0_zip_fly.asm` | `awB0_zip_fly` |
| `extracted/angkor_wat/awB0_shrubber.asm` | `awB0_shrubber` |
| `extracted/angkor_wat/awB0_zombie.asm` | `awB0_zombie` |
| `extracted/angkor_wat/awB1_gorgon.asm` | `awB1_gorgon` |
| `extracted/angkor_wat/awB1_wall_walker.asm` | `awB1_wall_walker` |
| `extracted/angkor_wat/awB1_goldcap.asm` | `awB1_goldcap` |
| `extracted/angkor_wat/aw_actor_0BBEE9.asm` | `aw_actor_0BBEE9` |

### Pyramid — Dungeon Enemies
| File | Block |
|------|-------|
| `extracted/pyramid/pyD2_haunt.asm` | `pyD2_haunt` |
| `extracted/pyramid/pyCE_tuts.asm` | `pyCE_tuts` |
| `extracted/pyramid/pyCC_mystic_ball.asm` | `pyCC_mystic_ball` |
| `extracted/pyramid/pyCC_blaster.asm` | `pyCC_blaster` |

### System — Boot / Title
| File | Block |
|------|-------|
| `extracted/system/boot_logos/sFB_boot_logo.asm` | `sFB_boot_logo` |
| `extracted/system/title_screen/sFC_title_intro.asm` | `sFC_title_intro` |
| `extracted/system/title_screen/sFC_title_start_handler.asm` | `sFC_title_start_handler` |

### Prologue
| File | Block |
|------|-------|
| `extracted/prologue/prologue_prophecy/pr8C_prologue1.asm` | `pr8C_prologue1` |
| `extracted/prologue/prologue_legends/pr8D_prologue2.asm` | `pr8D_prologue2` |
| `extracted/prologue/prologue_missing/pr8E_prologue3.asm` | `pr8E_prologue3` |
| `extracted/prologue/prologue_mishap/pr8F_prologue4.asm` | `pr8F_prologue4` |
| `extracted/prologue/prologue_prophecy/pr8C_prologue5.asm` | `pr8C_prologue5` |
| `extracted/prologue/pr_actor_0BCF52.asm` | `pr_actor_0BCF52` |
| `extracted/prologue/pr_thinkers.asm` | `pr_thinkers` |

### Ending
| File | Block |
|------|-------|
| `extracted/ending/ending_comet/sE5_epilogue.asm` | `sE5_epilogue` |
| `extracted/ending/ending_changed_world/s90_changed_world.asm` | `s90_changed_world` |
| `extracted/ending/ending_new_babel/s89_new_babel.asm` | `s89_new_babel` |

### Diary Menu & Debug
| File | Block |
|------|-------|
| `extracted/system/diary_menu/sFA_diary_menu.asm` | `sFA_diary_menu` |
| `extracted/system/diary_menu/strings_0BF706.asm` | `strings_0BF706` |
| `extracted/actors/debug_man.asm` | `debug_man` |

### Generic Actors
| File | Block |
|------|-------|
| `extracted/actors/particle_rain_spawner.asm` | `particle_rain_spawner` |
| `extracted/actors/dialog_string_scanner.asm` | `dialog_string_scanner` |
| `extracted/actors/debug_stat_setter.asm` | `debug_stat_setter` |

---

## 6. Scene Validation Cross-Reference

All scene assignments validated against `groups.json` and `scene_actors` spawn data.

### Great Wall Scenes (group prefix `gw`)
| ID | Decimal | Name | Enemies from Bank $0B |
|----|---------|------|-----------------------|
| `$82` | 130 | Wall Entrance | archer 1/2/3, fire_bug, eyesore, wall_spear |
| `$83` | 131 | Long Dive | archer 1/2/3, stone_archer 1–3, fire_bug, eyesore, asp, wall_spear |
| `$85` | 133 | Rampway | archer 2, fire_bug, eyesore, asp, wall_spear |
| `$86` | 134 | Blind Pit | stone_archer 3, asp |
| `$87` | 135 | Switchback | archer 2, statue_archer, fire_bug, wall_spear |
| `$88` | 136 | Tomb | archer 1/2/3, stone_archer 3/4, eyesore, asp, wall_spear, short_wall_spear |
| `$8A` | 138 | Sand Fanger Lair | sand_fanger (boss) |
| `$F5` | 245 | Dark Fanger Lair | btF5_neo_fanger (Babel rematch) |

### Mountain Temple Scenes (group prefix `mt`)
| ID | Decimal | Name | Enemies from Bank $0B |
|----|---------|------|-----------------------|
| `$A0` | 160 | Entrance | skulker, acid_spider |
| `$A1` | 161 | Twisted Paths | fire_sprite, skulker, yorrick_ns, yorrick_ew, acid_spider |
| `$A2` | 162 | Crossroads | skulker, yorrick_ew, acid_spider |
| `$A3` | 163 | Treasure Gauntlet | skulker, yorrick_ns, yorrick_ew, acid_spider |
| `$A4` | 164 | Western Loop | skulker, yorrick_ns, yorrick_ew, acid_spider |
| `$A5` | 165 | Broken Vines | fire_sprite, skulker, yorrick_ns, yorrick_ew, acid_spider |
| `$A6` | 166 | Mushroom Field | fire_sprite, skulker, yorrick_ns, yorrick_ew, acid_spider |
| `$A7` | 167 | Vine Maze | fire_sprite, skulker, yorrick_ns, yorrick_ew, acid_spider |
| `$A8` | 168 | Detour | fire_sprite, yorrick_ns |

### Pyramid Scenes (group prefix `py`)
| ID | Decimal | Name | Enemies from Bank $0B |
|----|---------|------|-----------------------|
| `$CC` | 204 | Main Chamber | mystic_ball |
| `$CE` | 206 | Ramptastic A | tuts, mystic_ball |
| `$CF` | 207 | Ramptastic B | tuts, mystic_ball |
| `$D0` | 208 | Meltdown A | tuts, mystic_ball |
| `$D1` | 209 | Meltdown B | tuts, mystic_ball |
| `$D2` | 210 | Focus A | haunt, tuts, mystic_ball, blaster |
| `$D3` | 211 | Focus B | haunt, tuts, mystic_ball, blaster |
| `$D4` | 212 | Trickle A | tuts, mystic_ball, blaster |
| `$D5` | 213 | Trickle B | haunt, tuts, mystic_ball, blaster |
| `$D6` | 214 | Vader A | tuts, mystic_ball, blaster |
| `$D7` | 215 | Vader B | tuts, mystic_ball, blaster |
| `$D8` | 216 | Dangerslide A | haunt, tuts, mystic_ball, blaster |
| `$D9` | 217 | Dangerslide B | haunt, tuts, mystic_ball, blaster |
| `$DB` | 219 | Dangerslide C | tuts, mystic_ball, blaster |
| `$DD` | 221 | Mummy Queen Lair | queen boss, teleporter, arena helpers |
| `$F6` | 246 | Dark Queen Lair | btF6_neo_queen (Babel rematch) |

### Angkor Wat Scenes (group prefix `aw`)
| ID | Decimal | Name | Enemies from Bank $0B |
|----|---------|------|-----------------------|
| `$B0` | 176 | Entrance | zip_fly, shrubber, zombie |
| `$B1` | 177 | Outer Gate | gorgon, wall_walker, goldcap |
| `$B2` | 178 | Outer East | gorgon, wall_walker, goldcap |
| `$B3` | 179 | Outer North | wall_walker, goldcap |
| `$B4` | 180 | Snake Pit | wall_walker, goldcap |
| `$B5` | 181 | Outer West | gorgon, wall_walker, goldcap |
| `$B6` | 182 | Outer Courtyard | zip_fly, shrubber, zombie |
| `$B7` | 183 | Inner Gate | gorgon, wall_walker, goldcap |
| `$B8` | 184 | Inner East | gorgon, wall_walker |
| `$B9` | 185 | Inner West | gorgon, wall_walker, goldcap |
| `$BA` | 186 | Inner Courtyard | shrubber, zombie, wall_walker |
| `$BB` | 187 | Shrine Main | wall_walker, goldcap |
| `$BC` | 188 | Shrine Crystal | wall_walker, goldcap |
| `$BD` | 189 | Shrine Deja Vu | wall_walker, goldcap |
| `$BE` | 190 | Shrine Upper | gorgon, wall_walker, goldcap |

### System / Cutscene Scenes
| ID | Decimal | Name | Actors from Bank $0B |
|----|---------|------|-----------------------|
| `$8C` | 140 | Prologue — Prophecy | pr8C_prologue1, pr8C_prologue5, sFC_sFC_title_start_handler (skip) |
| `$8D` | 141 | Prologue — Legends | pr8D_prologue2, sFC_sFC_title_start_handler |
| `$8E` | 142 | Prologue — Missing | pr8E_prologue3, sFC_sFC_title_start_handler |
| `$8F` | 143 | Prologue — Mishap | pr8F_prologue4, sFC_sFC_title_start_handler |
| `$89` | 137 | Ending — New Babel | s89_new_babel |
| `$90` | 144 | Ending — Changed World | s90_changed_world |
| `$E5` | 229 | Ending — Comet | sE5_epilogue |
| `$FA` | 250 | Diary Menu | sFA_diary_menu |
| `$FB` | 251 | Boot Logos | sFB_boot_logo |
| `$FC` | 252 | Title Screen | sFC_title_intro, sFC_title_start_handler |

---

## 7. Observations & Notes

### Mixed-purpose bank
Unlike banks $04–$0A which are themed (NPC actors, dungeon enemies, etc.), bank
$0B is a **spillover bank** collecting content that didn't fit into earlier
allocations. It mixes late-game dungeon enemies, two boss complexes, system UI,
cutscene scripts, and debug code.

### Boss dual-variants
Both boss actors use the **Neo/Dark pattern**: `btF5_neo_fanger` and
`btF6_neo_queen` serve as both the original dungeon boss and the Babel Tower
dark rematch. The Queen boss has a **phase-based hit system** with orbiting eyes
(phase 1) and homing orbs (phase 2).

### Orientation-split enemies
Skulker and Yorrick (Mountain Temple) use **separate actor-defs per axis**
rather than a unified multi-directional actor. The Acid Spider goes further with
**4 directional sentries** + 1 full combat body.

### Second-life mechanic
The Zombie (`awB0_zombie`) and Haunt (`pyD2_haunt`) both feature **death respawn
mechanics**: the Zombie reloads with lower HP stats and enters enraged chase;
the Haunt spawns a smaller secondary ghost that continues pursuing the player.

### Cross-block code sharing
- `aw_actor_0BBEE9.code_0BBF64` is reused by both the Goldcap spore system and
  the Mummy Queen's phase-2 homing orbs
- `sub_0B9CE8` (Sand Fanger) physically lives within the Skulker's range
- `sub_0BA5D5` (Fire Sprite) lives at the end of the Acid Spider's range

### Development remnants
Three unscened actors (`particle_rain_spawner`, `dialog_string_scanner`, `debug_stat_setter`) are
orphaned dev/test code. The `debug_man` provides a full debug warp menu with
stat maxing. Several diary menu functions are tagged `_noref`.

### Interleaved diary menu
The `sFA_diary_menu` block's code is split around the `debug_man` actor at
`$0BEE20`–`$0BF178`. The menu implements save slot management with checksum
validation, animated world-map camera pans, BCD stat formatting, and sound/button
configuration submenus.
