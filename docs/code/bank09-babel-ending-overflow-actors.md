# Bank $09 — Babel Tower, Ending/Credits, and Overflow Actors

> ROM bank `$09` (`$098000`–`$09FFFF`, 32,768 bytes) contains **late-game actor
> definitions for Babel Tower, the ending credits sequence, and overflow actors
> from Edward Castle, Incan Ruins, Itory, Dao, Pyramid, and the Dark Space
> system**. This bank is one of the most content-diverse in the ROM, spanning
> story-critical cutscenes from the Tower of Babel ascent through the final
> credits roll, alongside puzzle actors from early-game dungeons that overflowed
> from their primary banks.
>
> The bank holds **93 mapped pieces** across 27 scene groups and 7 broad
> functional clusters. Coverage is **92.7%** mapped.

---

## 1. Coverage Summary

| Metric | Value |
|--------|-------|
| Bank range | `$098000`–`$09FFFF` (622,592–655,359) |
| Total bank size | 32,768 bytes |
| Mapped | 30,374 bytes (92.7%) |
| Unmapped tail | 2,394 bytes at `$09F6A6`–`$09FFFF` |
| Parent blocks | 27 distinct blocks in `blocks.json` |
| Total pieces | 93 |
| Piece types | ~55 × `actor-def`, ~25 × `Code`, 3 × `thinker-def`, 4 × `Byte`, 2 × `Word`, 2 × `DialogString`, 1 × `&Code` |
| Scene groups | 27 distinct scenes |

---

## 2. Memory Map

### 2.1 Full Address Map

| Address | End | Size | Block / Part | Type | Scene Group |
|---------|-----|------|--------------|------|-------------|
| `$098000` | `$0980C3` | 195 | `babel_tower` / `btE3_dao_travel_spirit` | actor-def | babel_upper_floors |
| `$0980C3` | `$098146` | 131 | `dao` / `daC3_babel_travel_spirit` | actor-def | dao |
| `$098146` | `$098515` | 975 | `babel_tower` / `btDC_plane_jumping` | actor-def | babel_flight |
| `$098515` | `$098620` | 267 | `btE3_kara` / `btE3_kara` | actor-def | babel_upper_floors |
| `$098620` | `$098718` | 248 | `babel_tower` / `btDE_kara_missing` | actor-def | babel_entrance |
| `$0986DF` | `$0986E1` | 2 | `btE3_kara` / `btE3_kara_destroy` | Code | babel_upper_floors |
| `$098718` | `$098748` | 48 | `babel_tower` / `btE0_actor_098718` | actor-def | babel_middle_floors |
| `$098748` | `$098778` | 48 | `babel_tower` / `btE0_actor_098748` | actor-def | babel_middle_floors |
| `$098778` | `$0987A8` | 48 | `babel_tower` / `btE0_actor_098778` | actor-def | babel_middle_floors |
| `$0987A8` | `$0987D8` | 48 | `babel_tower` / `btE0_actor_0987A8` | actor-def | babel_middle_floors |
| `$0987D8` | `$098808` | 48 | `babel_tower` / `btE3_actor_0987D8` | actor-def | babel_upper_floors |
| `$098808` | `$098D18` | 1,296 | `babel_tower` / `btDE_olman` | actor-def | babel_entrance |
| `$098D18` | `$098F92` | 634 | `babel_tower` / `btE4_kara` | actor-def | babel_rooftop |
| `$098F92` | `$099586` | 1,524 | `babel_tower` / `btE4_olman` | actor-def | babel_rooftop |
| `$099586` | `$099634` | 174 | `babel_tower` / `btE1_actor_099586` | actor-def | babel_light_elevator |
| `$099634` | `$0997CC` | 408 | `babel_tower` / `btE1_comet_soon` | actor-def | babel_light_elevator |
| `$0997CC` | `$0998B3` | 231 | `babel_tower` / `btE2_brought_back` | actor-def | babel_exterior |
| `$0998B3` | `$099972` | 191 | `babel_tower` / `btDE_monologue` | actor-def | babel_entrance |
| `$099972` | `$099B1C` | 426 | `babel_tower` / `btDF_crystal_ring` | actor-def | babel_lower_floors |
| `$099B1C` | `$099B2E` | 18 | `babel_tower` / `bt_actor_099B1C` | Code | (shared) |
| `$099B2E` | `$099E8C` | 862 | `babel_tower` / `btDF_spirits` | actor-def | babel_lower_floors |
| `$099E8C` | `$09A090` | 516 | `babel_tower` / `btDF_kara` | actor-def | babel_lower_floors |
| `$09A090` | `$09A0D7` | 71 | `sE6_gaia` / `e_actor_09A090` | Code | dark_space |
| `$09A0D7` | `$09A0E5` | 14 | `hint_npc` / `hint_npc1` | actor-def | (global) |
| `$09A0E5` | `$09A143` | 94 | `hint_npc` / `hint_npc2` | actor-def | (global) |
| `$09A143` | `$09A3DF` | 668 | `hint_npc` / `code_09A143` | Code | (global) |
| `$09A3DF` | `$09A3ED` | 14 | `dark_rewards` / `dark_rewards1` | actor-def | (global) |
| `$09A3ED` | `$09A915` | 1,320 | `dark_rewards` / `dark_rewards2` | actor-def | (global) |
| `$09A915` | `$09AA40` | 299 | `edward_castle` / `ec0E_lily` | actor-def | aqueduct_lockway |
| `$09AA40` | `$09AA6E` | 46 | `edward_castle` / `ec11_actor_09AA40` | actor-def | aqueduct_doorway |
| `$09AA6E` | `$09B25C` | 2,030 | `actor_09AA6E` / `actor_09AA6E` | actor-def | (unused) |
| `$09B25C` | `$09B264` | 8 | `actor_09AA6E` / `byte_09B25C` | Byte | (unused) |
| `$09B264` | `$09B26C` | 8 | `actor_09AA6E` / `byte_09B264` | Byte | (unused) |
| `$09B26C` | `$09B57A` | 782 | `actor_09AA6E` / `byte_09B26C` | Byte | (unused) |
| `$09B57A` | `$09BA80` | 1,286 | `actor_09AA6E` / `byte_09B57A` | Byte | (unused) |
| `$09BA80` | `$09BAE3` | 99 | `unused` / `actor_09BA80` | actor-def | (debug) |
| `$09BAE3` | `$09BB17` | 52 | `unused` / `actor_09BAE3` | actor-def | (debug) |
| `$09BB17` | `$09BBB7` | 160 | `pyramid` / `func_09BB17` | Code | (utility) |
| `$09BBB7` | `$09BC34` | 125 | `unused` / `kara_09BBB7` | actor-def | (debug) |
| `$09BC34` | `$09BC8B` | 87 | `edward_castle` / `ec11_flower` | actor-def | aqueduct_doorway |
| `$09BC8B` | `$09BCD1` | 70 | `edward_castle` / `ec11_actor_09BC8B` | actor-def | aqueduct_doorway |
| `$09BCD1` | `$09BDB5` | 228 | `edward_castle` / `ec11_button_voice` | actor-def | aqueduct_doorway |
| `$09BDB5` | `$09BF0F` | 346 | `edward_castle` / `ec11_countdown` | actor-def | aqueduct_doorway |
| `$09BF0F` | `$09BF6B` | 92 | `edward_castle` / `ec12_actor_09BF0F` | actor-def | aqueduct_back |
| `$09BF6B` | `$09BF90` | 37 | `edward_castle` / `ec12_actor_09BF6B` | actor-def | aqueduct_back |
| `$09BF90` | `$09C26F` | 735 | `edward_castle` / `ec13_lily` | actor-def | aqueduct_exit |
| `$09C26F` | `$09C2D0` | 97 | `incan_ruins` / `ir1D_bones` | actor-def | larai_cliff |
| `$09C2D0` | `$09C33B` | 107 | `edward_castle` / `ec_actor_09C2D0` | actor-def | (shared) |
| `$09C33B` | `$09C39F` | 100 | `incan_ruins` / `ir25_ceiling_tile` | actor-def | inca_entryway |
| `$09C39F` | `$09C3BB` | 28 | `incan_ruins` / `ir25_block_slot` | actor-def | inca_entryway |
| `$09C3BB` | `$09C489` | 206 | `incan_ruins` / `ir1F_gold_tile` | actor-def | stone_lord_plates |
| `$09C489` | `$09C4B2` | 41 | `incan_ruins` / `ir1F_actor_09C489` | actor-def | stone_lord_plates |
| `$09C4B2` | `$09C54D` | 155 | `incan_ruins` / `ir1E_actor_09C4B2` | actor-def | larai_cliff_back |
| `$09C54D` | `$09C563` | 22 | `incan_ruins` / `ir1E_actor_09C54D` | actor-def | larai_cliff_back |
| `$09C563` | `$09C579` | 22 | `incan_ruins` / `ir1E_actor_09C563` | actor-def | larai_cliff_back |
| `$09C579` | `$09C66E` | 245 | `incan_ruins` / `ir1D_wind_melody` | actor-def | larai_cliff |
| `$09C66E` | `$09C6A9` | 59 | `incan_ruins` / `ir24_glowing_tile` | actor-def | inca_plate_room |
| `$09C6A9` | `$09C798` | 239 | `incan_ruins` / `ir28_actor_09C6A9` | actor-def | ceiling_trap_room |
| `$09C798` | `$09C89D` | 261 | `incan_ruins` / `ir26_bones` | actor-def | inca_treasure_room |
| `$09C89D` | `$09C8F7` | 90 | `incan_ruins` / `ir28_bones` | actor-def | ceiling_trap_room |
| `$09C8F7` | `$09C9FF` | 264 | `incan_ruins` / `ir26_journal_bones` | actor-def | inca_treasure_room |
| `$09C9FF` | `$09CEA3` | 1,188 | `incan_ruins` / `ir1C_lily` | actor-def | incan_ruins_entrance |
| `$09CEA3` | `$09CF86` | 227 | `incan_ruins` / `ir1C_kara` | actor-def | incan_ruins_entrance |
| `$09CF86` | `$09D02B` | 165 | `incan_ruins` / `ir29_transform` | actor-def | castoth_lair |
| `$09D02B` | `$09D0F5` | 202 | `ir1D_monologue` / `ir1D_monologue` | actor-def | larai_cliff |
| `$09D0F5` | `$09D64D` | 1,368 | `itory` / `it1A_moon_tribe` | actor-def | moon_tribe_camp |
| `$09D64D` | `$09DB67` | 1,306 | `sF7_credits` / `sF7_credits` | actor-def | ending_credits |
| `$09DB67` | `$09DDA7` | 576 | `ending` / `sF0_class_dismissed` | actor-def | ending_class_dismissed |
| `$09DDA7` | `$09DFF8` | 593 | `sF7_actor_09DFF8` / `e_actor_09DDA7` | Code | ending_credits |
| `$09DFF8` | `$09E14B` | 339 | `sF7_actor_09DFF8` / `sF7_actor_09DFF8` | actor-def | ending_credits |
| `$09E14B` | `$09E26C` | 289 | `sF7_actor_09E26C` / `e_actor_09E14B` | Code | ending_credits |
| `$09E26C` | `$09E31A` | 174 | `sF7_actor_09E26C` / `sF7_actor_09E26C` | actor-def | ending_credits |
| `$09E31A` | `$09E3EB` | 209 | `sF7_actor_09E3EB` / `e_actor_09E31A` | Code | ending_credits |
| `$09E3EB` | `$09E464` | 121 | `sF7_actor_09E3EB` / `sF7_actor_09E3EB` | actor-def | ending_credits |
| `$09E464` | `$09E4DD` | 121 | `sF7_actor_09E4DD` / `e_actor_09E464` | Code | ending_credits |
| `$09E4DD` | `$09E538` | 91 | `sF7_actor_09E4DD` / `sF7_actor_09E4DD` | actor-def | ending_credits |
| `$09E538` | `$09E591` | 89 | `sF7_actor_09E591` / `e_actor_09E538` | Code | ending_credits |
| `$09E591` | `$09E5DE` | 77 | `sF7_actor_09E591` / `sF7_actor_09E591` | actor-def | ending_credits |
| `$09E5DE` | `$09E607` | 41 | `sF7_actor_09E607` / `func_09E5DE` | Code | ending_credits |
| `$09E607` | `$09E62F` | 40 | `sF7_actor_09E607` / `sF7_actor_09E607` | actor-def | ending_credits |
| `$09E62F` | `$09E64B` | 28 | `sF7_credits` / `code_09E62F` | Code | ending_credits |
| `$09E64B` | `$09E8E4` | 665 | `ending` / `misc_actors_09E64B` | Code | ending_credits |
| `$09E8E4` | `$09E901` | 29 | `func_09E8E4` / `func_09E8E4` | Code | ending_credits |
| `$09E901` | `$09E90D` | 12 | `func_09E8E4` / `word_09E901` | Word | ending_credits |
| `$09E90D` | `$09E919` | 12 | `func_09E8E4` / `word_09E90D` | Word | ending_credits |
| `$09E919` | `$09EC74` | 859 | `sF7_credits` / `code_09E919` | Code | ending_credits |
| `$09EC74` | `$09ECBF` | 75 | `sF7_credits` / `table_09EC74` | &Code | ending_credits |
| `$09ECBF` | `$09F330` | 1,649 | `sF7_credits` / `dialogstring_09ECBF` | DialogString! | ending_credits |
| `$09F330` | `$09F360` | 48 | `ending` / `crF7_proc_09F330` | thinker-def | ending_credits |
| `$09F360` | `$09F4AA` | 330 | `ending` / `crF7_proc_09F360` | thinker-def | ending_credits |
| `$09F4AA` | `$09F510` | 102 | `sF7_credits` / `code_09F4AA` | Code | ending_credits |
| `$09F510` | `$09F69F` | 399 | `ending` / `crF7_proc_09F510` | thinker-def | ending_credits |
| `$09F69F` | `$09F6A6` | 7 | `sF7_credits` / `func_09F69F` | Code | ending_credits |
| `$09F6A6` | `$0A0000` | 2,394 | *(unmapped tail)* | — | — |

### 2.2 Visual Layout

```
$098000 ┌──────────────────────────────────────────────────────────────┐
        │  BABEL TOWER ACTORS                                         │
        │  Travel spirits, plane flight, Kara/Olman encounters,       │
        │  door controllers, Crystal Ring, spirit lore NPCs           │
$09A090 ├──────────────────────────────────────────────────────────────┤
        │  GLOBAL SYSTEM ACTORS                                       │
        │  Dark Space Gaia visual, hint NPCs, ability reward NPCs     │
$09A915 ├──────────────────────────────────────────────────────────────┤
        │  EDWARD CASTLE — AQUEDUCT                                   │
        │  Lily encounter + orbiting demon                            │
$09AA6E ├──────────────────────────────────────────────────────────────┤
        │  UNUSED / DEBUG                                             │
        │  Cut boss encounter, debug stat actors, Kara dialog test    │
$09BC34 ├──────────────────────────────────────────────────────────────┤
        │  EDWARD CASTLE — AQUEDUCT (continued)                       │
        │  Flower hint, button switches, countdown, back area, Lily   │
$09C26F ├──────────────────────────────────────────────────────────────┤
        │  INCAN RUINS ACTORS                                         │
        │  Ceiling traps, gold tile puzzle, bones, Wind Melody,       │
        │  Lily/Kara entrance, Castoth post-battle                    │
$09D02B ├──────────────────────────────────────────────────────────────┤
        │  MISCELLANEOUS OVERFLOW                                     │
        │  Larai Cliff monologue, Moon Tribe camp NPCs                │
$09D64D ├──────────────────────────────────────────────────────────────┤
        │  ENDING SEQUENCE                                            │
        │  Credits controller, parade actors (Will + 5 NPCs),         │
        │  crowd extras, HDMA thinkers, class dismissed epilogue,     │
        │  credits text (DialogString), utility code                  │
$09F6A6 ├──────────────────────────────────────────────────────────────┤
        │  UNMAPPED TAIL (2,394 bytes)                                │
$0A0000 └──────────────────────────────────────────────────────────────┘
```

---

## 3. Scene Group Analysis

### 3.1 Babel Tower (10,337 bytes — 31.6%)

The largest cluster in the bank. Babel Tower is the penultimate dungeon, and its
actors span seven sub-scenes covering Will's ascent with Kara through the tower.

#### babel_flight (`$098146`–`$098515`, 975 bytes)

**File:** `extracted/babel_tower/babel_flight/btDC_plane_jumping.asm`

| Part | Description |
|------|-------------|
| `btDC_plane_jumping` | Plane approach cutscene. Locks joypad (`$EFF0`), sets `TM=#$15`, stages player sprite off-screen. Spawns `code_0981E5` (dialogue sub-actor) for Neil/Erik/Kara farewell conversation, then spawns `code_0981EE` for Will's parachute monologue. Fires two `code_098505` sub-actors (falling sprites that animate diagonally and die on screen exit). Concludes with `QueueMapChange` to scene `$DE` at `($0078,$00C0)`. |

| Flag | Set by | Purpose |
|------|--------|---------|
| `#01` | `code_0981E5` | Farewell dialogue complete → triggers parachute phase |

Dialogue: Neil reflects on the journey ("We'll be there soon, Will"), Erik's bathroom joke, Kara is silent. Will jumps over the Tower of Babel.

---

#### babel_entrance (`$098620`–`$098718`, `$098808`–`$098D18`, `$0998B3`–`$099972`, 1,735 bytes)

**Files:** `extracted/babel_tower/babel_entrance/btDE_kara_missing.asm`, `btDE_olman.asm`, `btDE_monologue.asm`

| Part | Description |
|------|-------------|
| `btDE_kara_missing` | Conditional Kara companion. Checks flag `#D4` — if clear (Kara not yet found), dies immediately. If Kara is found, reads player actor position, spawns `EscortFollowPathTracker` with orbit config (`orbitAngle=4`, `orbitDiameter=$1A`), then loops: when player is moving (`$000E & $2000`), spawns `code_09870C` (question-mark sprite using frame `#1C` from `table_0EE000`). Alternates between showing/hiding the `$2000` visibility flag. |
| `btDE_olman` | **Major story cutscene** — Will's father. Uses `table_0EDA00` metasprite. **First visit** (flag `#FD` clear): solid NPC with interact → sets flag `#01` → locks joypad → spawns `code_0988DA` (blinking animation sub-actor). Starts music `#0E`, waits `$B3` frames, prints long exposition about comets/evolution/Knights of Light and Darkness/Mystic Statues. Then starts music `#1B`, waits for music finish via `IsMusicPlaying`. Configures scene params (`$0AAC=#5`, `$0B12=#$DE`, gfx cache `$0104`) → `QueueMapChange` to scene `$FD`. **Return visit** (flag `#FD` set): spawns `code_0988F3` (idle sub-actor), hooks player script via `InitPlayerScriptVariant(#1)`, prints "go to the roof" → `QueueMapChange` to scene `$E4` at `($00F0,$0140)`. |
| `btDE_monologue` | Reads `$sceneCurrent`. On scene `$DE` (entrance): if flag `#D2` clear, sets it, locks joypad, waits `$3B` frames, prints *"The Tower of Babel was deathly quiet. Time stood still..."*. On scene `$DF` (lower floors): if flag `#D3` clear, waits for player in tile region `($3F,$19)–($40,$1D)`, then hooks player via `InitPlayerScriptVariant(#1)`, sets flag `#D3`, prints *"The Flute I had was discovered here."* |

| Flag | Set by | Purpose |
|------|--------|---------|
| `#D4` | `btDF_kara`, `btE3_kara` | Kara found — companion follows |
| `#D2` | `btDE_monologue` | Entrance monologue played |
| `#D3` | `btDE_monologue` | Lower floors monologue played |
| `#FD` | scene system | Olman repeat-visit path |
| `#01` | `code_0988D2` | Olman interact acknowledged |

---

#### babel_middle_floors (`$098718`–`$0987D8`, 192 bytes)

**Files:** `extracted/babel_tower/babel_middle_floors/btE0_actor_098718.asm` (and 3 siblings)

All four actors are identical in structure — **door controllers** that block passage with solid tiles and a visual marker until the corresponding flag word is set by defeating enemies in that room.

| Part | Tiles blocked | Flag word | Marker position |
|------|--------------|-----------|-----------------|
| `btE0_actor_098718` | `($71,$38)`, `($72,$38)` | `$0175` | `($072E,$0384)` / `($072E,$0374)` |
| `btE0_actor_098748` | `($0D,$28)`, `($0E,$28)` | `$0176` | `($00EE,$0284)` / `($00EE,$0274)` |
| `btE0_actor_098778` | `($49,$18)`, `($4A,$18)` | `$0177` | `($04AE,$0184)` / `($04AE,$0174)` |
| `btE0_actor_0987A8` | `($15,$08)`, `($16,$08)` | `$0178` | `($016E,$0084)` / `($016E,$0074)` |

Pattern: `SolidHighAbs` × 2 → `SpawnMarkedAfterAbs` (2× `bt_actor_099B1C`) → `ExitIfFlagWord` → `ClearLowAbs` × 2 → `Die`.

---

#### babel_upper_floors (`$098000`–`$0980C3`, `$098515`–`$098620`, `$0986DF`–`$0986E1`, `$0987D8`–`$098808`, 512 bytes)

**Files:** `extracted/babel_tower/babel_upper_floors/btE3_dao_travel_spirit.asm`, `btE3_kara.asm`, `btE3_actor_0987D8.asm`

| Part | Description |
|------|-------------|
| `btE3_dao_travel_spirit` | Spirit NPC using `table_0EDA00` metasprite (frame `#04`). Solid, interactable. On interact: prints warning *"If you proceed, you will not be able to turn back..."*, then `DialogueOptions(#02,#02)` with Quit / Return to Dao. Both "quit" options close dialog. Return option: clears `$066D`/`$0670`, sets `gfxCacheIdxA=#$0202`, `gfxCacheIdxB=#$0404`, → `QueueMapChange` to scene `$C3` at `($0210,$0090)` with transition `#03`. |
| `btE3_kara` | Kara encounter on upper floors. If flag `#D4` set or player not at `($0080,$01A0)`, destroys self. Otherwise: adds `(+8,0)` position offset, locks joypad, walks right (`StageSpriteMoveX #20,#12`), poses, prints dialogue (*"Kara! Where did you go?!" / "There was talk that the vampire woman had come..."*). Spawns `EscortFollowPathTracker` with orbit config (`angle=4`, `diameter=$1A`). Sets `$10` flags `$0B00` (follower visibility), sets flag `#D4`. |
| `btE3_kara_destroy` | 2-byte stub: `COP [Die]`. Target for kara branch-if-already-found. |
| `btE3_actor_0987D8` | Door controller for tiles `($29,$38)` / `($2A,$38)`. Opens when flag word `$0179` set. Same pattern as middle floor doors, spawns markers at `($02AE,$0384)` / `($02AE,$0374)`. |

---

#### babel_lower_floors (`$099972`–`$09A090`, 1,804 bytes)

**Files:** `extracted/babel_tower/babel_lower_floors/btDF_crystal_ring.asm`, `btDF_spirits.asm`, `btDF_kara.asm`

| Part | Description |
|------|-------------|
| `btDF_crystal_ring` | **Crystal Ring acquisition** (item `#27`). Spawns two `bt_actor_099B1C` markers at `($076E,$017C)` / `($076E,$018C)`. Waits for player in tile region `($75,$17)–($77,$19)`. Checks: if ring already equipped → exit. Plays sound `$1D1D`, sets `playerSpeedNs=#6`. If ring not in inventory → exit. On first entry (flag `#01` clear): sets flag, spawns `code_0999CC` which locks joypad, reads player position, spawns a ring object with `table_0EE000` metasprite (frame `#02`), uses `InitGravity(#02,#06,#00)` physics — ring falls with gravity via `TickGravity` loop, then walks to landing position via `StageSpriteMoveXY(#02,#12,#45)`. Becomes interactable → on interact: prints *"It's King Edward's Crystal Ring!!"*, `GiveItem(#27)` → `MusicAndText(#17)` for acquisition fanfare *"You have the Crystal Ring!"*. Sets `$0080` on `displayModeFlags`. |
| `btDF_spirits` | Six identical lore NPCs. Each uses `table_0EDA00` (frame `#04`), solid+interactable. On interact: stores spawn index from `$0E` → `$24`, `SwitchCase` on `$24` selects one of six dialogues. Topics: (0) comet light + dramatic evolution, (1) time races in Babel / evolved humans, (2) insects→fish→reptiles→mammals→humans evolution, (3) comet as "demon of stars" + Earth evolving, (4) demons in that room — must defeat before ascending, (5) Earth took wrong turn / your battle changes fate. |
| `btDF_kara` | **Kara reunion cutscene.** If flag `#D4` set → die. Waits for player in tile region `($70,$09)–($72,$0D)`. Locks joypad, starts music `#1B`, waits `$3B` frames. Prints *"Wait...."* → hooks player via `InitPlayerScriptVariant(#3)`, teleports to tile `($75,$09)`, walks south (`StageSpriteMoveY #1E,#01`), poses. Long dialogue about the two Crystal Rings (light blue / dark blue). Moves toward player, starts music `#04`, waits `$77` frames. Spawns `EscortFollowPathTracker` (orbit `angle=4`, `diameter=$1A`). Sets flag `#D4`. |

| Flag | Set by | Purpose |
|------|--------|---------|
| `#01` | `btDF_crystal_ring` | Ring drop triggered |
| `#D4` | `btDF_kara` | Kara reunited, following |

---

#### babel_light_elevator (`$099586`–`$0997CC`, 582 bytes)

**Files:** `extracted/babel_tower/babel_light_elevator/btE1_actor_099586.asm`, `btE1_comet_soon.asm`

| Part | Description |
|------|-------------|
| `btE1_actor_099586` | **Light-elevator controller.** If player already at `($0180,$07A0)` → spawns `code_09962C` thinker (palette `#6E` loop) and dies. Otherwise waits for player in tile region `($07,$7B)–($0A,$7D)`. Spawns `code_099618` palette-cycling thinker (`#6D` / `#6F` alternating). Locks joypad, waits `$EF` frames → sets flag `#00`, waits `$167` frames → sets flag `#01`. Spawns `py_actor_08B6F4` (pyramid elevator sprite). Manipulates player position: flips facing direction via `$000E ^ $2000`, adds `$0190` to X position, decrements Y by 4 each frame until Y < `$00B0`. Then subtracts the `$0190` X offset, spawns another elevator sprite, waits, flips facing back, unlocks joypad. |
| `btE1_comet_soon` | **Vampire woman NPC.** If player not at `($0180,$07A0)` → die. Otherwise: locks joypad, decompresses vampire GFX into `$7E7000`, uploads 4× `$0800`-byte chunks to VRAM (`$5000`–`$5C00`), copies palette, decompresses vampire metasprite to `$7E4000`. Sets flag `#0F`. Moves toward player position. Solid + interactable. On interact: prints *"The comet will soon be entering Earth's orbit. We must go to the top of the Tower of Babel..."* → sets flag `#02`. Then: walks toward player, waits, spawns `code_09979D` (syncs player position to vampire Y+10). Hooks player script to `code_0997B7` (player displays frame `#19`, loops until flag `#04`). Walks north until Y < `$00E0`, then walks to `($0178,$00A0)`, waits, sets flag `#04`, kills position sync. Sprite loops diagonally offscreen. Player hook: `StagePlayerSprite(#19)` loop, when flag `#04` set → restores priority `#20`, jumps to `PlayerIdleEntry`. |

| Flag | Set by | Purpose |
|------|--------|---------|
| `#00`/`#01` | `btE1_actor_099586` | Elevator phase gates |
| `#0F` | `btE1_comet_soon` | Vampire GFX loaded |
| `#02` | `btE1_comet_soon` interact | Dialogue acknowledged |
| `#04` | `btE1_comet_soon` | Escort complete → releases player |

---

#### babel_exterior (`$0997CC`–`$0998B3`, 231 bytes)

**File:** `extracted/babel_tower/babel_exterior/btE2_brought_back.asm`

| Part | Description |
|------|-------------|
| `btE2_brought_back` | Spirit NPC. Sets priority `#30`, solid + interactable. On interact: *"You were brought back to save Earth. I'll take you to the top floor."* → sets flag `#01`. Before interact: locks joypad, moves toward player (+8 Y offset), spawns `code_099899` (position sync sub-actor). Hooks player to `btE1_comet_soon.code_0997B7` (same climbing sprite as vampire escort). Walks north until Y < `$0090`, then moves to `($0188,$0110)`, kills sync, sets flag `#04`. Loops south animation offscreen. |

---

#### babel_rooftop (`$098D18`–`$099586`, 2,158 bytes)

**Files:** `extracted/babel_tower/babel_rooftop/btE4_kara.asm`, `btE4_olman.asm`

| Part | Description |
|------|-------------|
| `btE4_kara` | **Rooftop finale — Kara.** Solid + interactable. Before flag `#0E`: prints *"Kara: ................."*. After flag `#0F` set by Olman: prints *"When Will and Kara joined and became one with the Light Knight, a great power was born... The Firebird was released!"* → sets flag `#0E`. Once flag `#0E` set: disables interact, reads player facing direction, spawns **six orbital light orb sub-actors** (`code_098F01`–`098F2E`), each with different `orbitAngle` offsets (0, `$2A`, `$54`, `$80`, `$AA`, `$D4` — evenly spaced around a circle). Each orb uses `table_0EDA00` frame `#0A`, incrementally grows `orbitDiameter` from 1 to `$80`, calls `ApplyOrbitalOffsetFromRef` each frame using `playerActor` as reference. Hooks player to `sE6_gaia.func_08F5F9` (Gaia visual script). Moves toward player, waits for player script to finish. Prints Olman's speech: *"Your battle will change the fate of humanity. Now you must go to the comet!!"* → sets flag `#0A`. Hooks player to `code_098F7E` (falling/climbing animation — `StagePlayerSprite(#1C)`, flips V, loops `StagePlayerMoveY(#1B,#08)` infinitely upward). Sets `gfxCacheIdxB=#$0404` → `QueueMapChange` to scene `$E7` at `($0050,$0090)`. Orbs: when flag `#0A` set, switch to `table_0EE000` frame `#1E` and die. |
| `btE4_olman` | **Rooftop finale — Olman hub.** Uses `table_0EDA00` frame `#04`. Locks joypad, waits, prints long speech about comet as spirit/demon, evolution bringing destruction. Unlocks. Then sequentially spawns **five spirit NPCs** at fixed positions with sound `#1D` between each: (1) Seth at `($00D8,$00F0)` — *"Ah, Will. It's been a long time..."* → flag `#01`. (2) Neil's father at `($0098,$00E0)` — *"Neil... What are you doing!!"* → flag `#02`. (3) Neil's mother at `($00B8,$0160)` — *"Even if I can see the real world, I can't touch it..."* → flag `#03`. (4) Hamlet at `($0148,$0130)` — *"Oink oink!! / No difference between humans and animals..."* → flag `#04`. (5) Vampire woman at `($0158,$00E0)` — *"With my body gone, I became forever young... But is there meaning in eternal life?"* → flag `#05`. Each spirit: spawns with light flash (`table_0EE000` frame `#1E`), becomes solid + interactable with `table_0EDA00` frame `#04`. After flag `#0F` set, each moves toward player and dies. Olman: interactable — if not all 5 flags set, prints *"I need to talk to you"*. When all 5 set: *"At last the time is near. Everyone. Give Will your power!"* → sets flag `#0F`, locks joypad. Main loop: waits for flag `#0F`, clears collision, dies. |

| Flag | Set by | Purpose |
|------|--------|---------|
| `#01`–`#05` | Spirit sub-actors | Each spirit talked to |
| `#0F` | `btE4_olman` | All spirits spoke → power trigger |
| `#0A` | `btE4_kara` | Olman speech done → orbs transform |
| `#0E` | `btE4_kara` | Kara delivers Knight speech |

---

#### Shared helper

**File:** `extracted/babel_tower/bt_actor_099B1C.asm`

| Part | Description |
|------|-------------|
| `bt_actor_099B1C` | Invisible marker sprite. Sets `$1000` on `$12`, loads `table_0EE000`, loops on `StageSpriteFrame(#2C)` + `AnimOnce`. Used by all 5 door controllers as the visual gate decoration. |

---

### 3.2 Ending Sequence (8,281 bytes — 25.3%)

The second largest cluster. Contains the entire ending credits roll and the
post-credits "class dismissed" epilogue.

#### ending_credits (`$09D64D`–`$09DB67`, `$09DDA7`–`$09F6A6`, 7,705 bytes)

**Files:** `extracted/ending/ending_credits/sF7_credits.asm` (main controller + inline code), `sF7_actor_09DFF8.asm`, `sF7_actor_09E26C.asm`, `sF7_actor_09E3EB.asm`, `sF7_actor_09E4DD.asm`, `sF7_actor_09E591.asm`, `sF7_actor_09E607.asm`, `misc_actors_09E64B.asm`, `func_09E8E4.asm`, `crF7_proc_09F330.asm`, `crF7_proc_09F360.asm`, `crF7_proc_09F510.asm`

| Part | Description |
|------|-------------|
| `sF7_credits` | **Main credits controller.** Sets window mask (`W12SEL=#$33`), disables all BG layers, locks joypad fully (`$FFF0`). Decompresses 4 sets of GFX (SC02 main characters, credits actors 1–3, credits scenery, font) using bank-copy MVN routines (`code_09DB4B`/`code_09DB59`). Loads sprite metasprites from `spm_credits` to `$7E6000`. Starts music `#14`. Spawns two persistent sub-actors: `code_09E9D2` (credits text scroller) and `code_09E919` (BCD frame counter incrementing `$00E4`/`$00E6`/`$00E8` each frame). The main timeline uses `HaltIfCounterGte` to sequence events: at `$00C8` enables BG1 (`TM=#$10`), uploads 8× 2KB VRAM DMA chunks for background tiles. Then a long sequence of timed spawns: palette fades (`code_09F4AA`/`code_09F4ED`), scenery DMA swaps at act breaks, BG palette changes via `CopyPalette`, `CallScript` for tilemap swaps, and `SpawnLastRel` for crowd extra actors. **Five distinct "acts"** with different background art/palettes, each separated by darken→DMA swap→brighten. At `$3264` starts spawning text overlay actors (`code_09E62F`/`code_09E637`). Crowd extras from `misc_actors_09E64B` are spawned at precise counter checkpoints from `$37B4` through `$6338`. At `$6400` loads final palette + scenery. Final fade at `$652C`. At `$7068`: clears all GFX cache indices, → `QueueMapChange` to scene `$F0` at `($0090,$0178)` with transition `#06`. |
| `sF7_actor_09DFF8` + `e_actor_09DDA7` | **Will (player character) parade actor.** Init: priority `#30`, X=`$0200`, clears `characterForm`. Linked controller `e_actor_09DDA7` uses ~75 `HaltIfCounterGte`/`SetLinkedActorScript` pairs to switch Will between animation scripts across the full timeline (`$012C`–`$6D38`). Scripts include: walking (`StagePlayerMoveX`), idle player sprites (`#00`–`#44`), body sprite changes (`SetPlayerBodySprite #04`), and individual frame poses (`#02`, `#06`, `#0C`–`#0E`, `#1A`–`#1F`, `#23`–`#26`, `#32`, `#36`, `#38`, `#3A`, `#3C`, `#44`). |
| `sF7_actor_09E26C` + `e_actor_09E14B` | **NPC parade actor #1.** Uses `$7E6000` metasprite (credits actors). Linked controller has ~40 timed script swaps (`$0F00`–`$6E74`). Animations include: static frames `#00`–`#09`/`#11`, directional walks (`StageSpriteMoveX`, `StageSpriteMoveY`). Uses `func_09E8E4` for repositioning (placement `#$0031`, `#$0035`). Long idle/hidden period `$1F70`–`$2F58`. |
| `sF7_actor_09E3EB` + `e_actor_09E31A` | **NPC parade actor #2.** Enters at counter `$1770`. Controller has rapid pose cycling around `$17E8`–`$182A` (frames `#04`→`#05`→`#06`→`#07` repeating). Later: walks with frame `#08`, `#2E`, `#33`. Uses placements `#$0031`, `#$0042`. Active `$1770`–`$4748`. |
| `sF7_actor_09E4DD` + `e_actor_09E464` | **NPC parade actor #3.** First active at `$0438`. Opens with placement `#$0025`, fast walk (`StageSpriteMoveX #00,#12`). Idle at `$0C78`–`$3F0C`. Late act: placement `#$0022`, frames `#1D`/`#1F`/`#20`/`#23`. Active `$0438`–`$4748`. |
| `sF7_actor_09E591` + `e_actor_09E538` | **NPC parade actor #4.** Active from `$04B0`. Placement `#$0042`, walks with frame `#01`. Idle `$0BD0`–`$3FFC`. Late: placement `#$0032`, frame `#2B`/`#27`. Active `$04B0`–`$4748`. |
| `sF7_actor_09E607` + `func_09E5DE` | **NPC parade actor #5.** Shortest lifecycle. Active `$0564`–`$0A74` (only 3 script phases). Placement `#$0035`, walks with frame `#02`, reverses direction, then idles. |
| `misc_actors_09E64B` | **Crowd extras library.** `code_09E65D`: linked walker with placement `#$0041`, frame `#0E` walking. `code_09E67C`: palette flash (`PaletteStart #7C`). `code_09E68D`: linked walker with placement `#$0003`. `code_09E6A5`: `$7E4000` metasprite walker, placement `#$0021`, walks `$C8` frames right then `$68` frames left. `code_09E6C0`–`code_09E8A6`: **16 nearly identical walk-on/walk-off crowd actors**, each using a different frame from `$7E4000` (frames `#09`–`#1C`), all placement `#$0021`, walk `$C8` then `$68`/`$80`/`$88`. `code_09E8C1`: comet/trail actor — placement `#$0032`, walks 4 frames with frame `#13`, loops 85 frames, switches to frame `#12`, waits `$0FEF` frames, dies. |
| `func_09E8E4` | **Placement utility.** Decodes a packed word: low nibble → index into `word_09E90D` (X offsets: `$FFE0`, `$FFF0`, `$0110`, `$0120`, `$FFF8`, `$0108`), high nibble → index into `word_09E901` (Y offsets: `$0080`–`$00D0` in `$10` steps). Stores result in `$14` (X) and `$16` (Y). Called by all parade and crowd actors. |
| `code_09E919` | **BCD frame counter.** Increments `$00E4` each frame, maintains BCD counter in `$00E6`/`$00E8` using SED mode. |
| `code_09E9D2` | **Credits text scroller.** Waits until `$00E4 ≥ $01F4`, then iterates through 30 staff credit strings via `CallScript(&code_09EB64)` / `WaitByte(#4A)` pairs. Each `code_09EB64` call: sets `BG3SC=#$79`, builds scroll animation (128-frame wipe with `$0726`/`$0728` converging, `$074A` incrementing), renders text via `code_09EC23`, DMAs to VRAM, scrolls out. Final entry ("Thank you for playing") uses a different rendering path on `BG3SC=#$79` with permanent VRAM upload. |
| `code_09EC23` | **Text renderer.** Reads dialog string bytes, writes tile indices to `$7F0200` buffer with `$099E` base offset. Control codes dispatched via `table_09EC74` jump table: `#00` = end, `#01` = set position, `#03` = set palette bits, `#0B` = advance base offset by `$80`. |
| `dialogstring_09ECBF` | **Credits text strings** (1,649 bytes). 30 entries including: *"The Illusion of GAIA — STAFF"*, Original Story: MARIKO OHARA, Character Designer: MOTO HAGIO, Game Designer: TOMOYOSHI MIYAZAKI, Program Director/Main Programmer: MASAYA HASHIMOTO, etc. Includes Quintet Staff, ENIX Staff, Enix America Staff (Paul Handelman, Jake Kazdal), and copyright notices (1994 ENIX / QUINTET / MARIKO OHARA / MOTO HAGIO / YASUHIRO KAWASAKI). |
| `crF7_proc_09F330` | **HDMA scroll oscillation thinker.** Increments per-thinker counter at `$7F2104,X`. Even frames: copies `$0720` → `$0722`, queues HDMA channel targeting `$2107`/`$2122`. Odd frames: copies `$0720` → `$0724`, queues alternate channel. Creates subtle vertical scroll oscillation. |
| `crF7_proc_09F360` | **HDMA wave/ripple thinker.** Queues HDMA on `dma_channel_09F3D4` (71-entry sine-like scroll table targeting BG offset registers) + DMA on `dma_channel_09F36F` (29-entry alternating `±5`, `±4`, `±3`, `±2`, `±1` pattern). Creates water/sky parallax effect. |
| `crF7_proc_09F510` | **Screen shake thinker.** Two timed phases. Phase 1 at counter `$2FA8`: 600-frame (`$0258`) HDMA burst via `dma_channel_09F5C6` (66-entry table); toggles `$0762`/`$0764` direction flags every 16 frames. Phase 2 at counter `$3CF0`: rebuilds 128-byte oscillation table at `$0760` with decay/wrap, applies horizontal camera nudge via `cameraDeltaX` on alternating frames, HDMA via `dma_channel_09F5BC`. Ends by zeroing `cameraDeltaX` and `KillThinker`. |
| `code_09F4AA` / `code_09F4ED` | **Palette darken / brighten.** `code_09F4AA`: sets `TM=#$17`, `COLDATA=#$FF`, then decrements COLDATA from `$FF` to `$E0` over `$3F` frames (every other frame), creating a fade-to-dark. `code_09F4ED`: increments COLDATA from `$E0` to `$FF`, creating a fade-from-dark. |
| `func_09F69F` | 7-byte function: `PaletteStart(#65)` → `PaletteStep` → `Die`. Final palette reset. |

---

#### ending_class_dismissed (`$09DB67`–`$09DDA7`, 576 bytes)

**File:** `extracted/ending/ending_class_dismissed/sF0_class_dismissed.asm`

| Part | Description |
|------|-------------|
| `sF0_class_dismissed` | **Post-credits epilogue — South Cape school.** Sets `TM=#$15`, backdrop `#$FF`, locks joypad. Uses `$00E4` as phase counter. Spawns `code_09DC2D` (palette controller) + 6 student actors at fixed positions. Main loop: increments `$00E4` through phases, plays bell sound `$0909` ×6 with `$1E`-frame delays. Then `code_09DBF3`: waits `$3B` frames, prints teacher dialogue: *"Class is over. Please be careful crossing the street. We have had a lot of traffic accidents lately."* Starts music `#02`, increments through phases 3–8. **Palette controller** (`code_09DC2D`): at phase 1 → `PaletteStart(#6A)`, phase 2 → `PaletteStart(#1C)`, phase 7 → `PaletteStart(#70)`. **Student actors**: `code_09DC63` (seated, frame `#08`, waits for phase 7). `code_09DC78`–`code_09DCD5` (4 students, each walks right at their respective phase 3–6). `code_09DCF4` (walks up at phase 8 with `StageSpriteMoveY(#09,#11)`). |

---

### 3.3 Edward Castle — Aqueduct (2,040 bytes — 6.2%)

Overflow actors from the Edward Castle dungeon, all relating to the underground
aqueduct puzzle sequence.

#### aqueduct_lockway (`$09A915`–`$09AA40`, 299 bytes)

**File:** `extracted/edward_castle/aqueduct_lockway/ec0E_lily.asm`

| Part | Description |
|------|-------------|
| `ec0E_lily` | **Lily encounter with demon.** If flag `#DE` set → die. Waits for player proximity (`BranchIfPlayerNear #01`). On trigger: sets flag `#DE`, spawns `code_09A9A1` (orbiting demon) as marked child. Sets countdown `$24=$04B0`. Main loop: `DirToPlayer` → `SwitchCase` (8 directions) → increments position 1px toward player each frame, decrements countdown. At zero: prints *"Come here, or the demon will get you!"*, then moves to position `($0060,$0030)` via `StageMove`. **Demon sub-actor** (`code_09A9A1`): uses `table_0EE000` frame `#33`, loads `enemy_stats_table+190` stats, orbit config (`angle=0`, `diameter=$40`). Orbits around Lily using `ApplyOrbitalOffsetFromRef`. On hit: resets HP to `$FF`, prints *"Hey! What are you doing!!"* — invulnerable. |

| Flag | Set by | Purpose |
|------|--------|---------|
| `#DE` | `ec0E_lily` | Lily demon encounter triggered |

---

#### aqueduct_doorway (`$09AA40`–`$09AA6E`, `$09BC34`–`$09BF0F`, 777 bytes)

**Files:** `extracted/edward_castle/aqueduct_doorway/ec11_actor_09AA40.asm`, `ec11_flower.asm`, `ec11_actor_09BC8B.asm`, `ec11_button_voice.asm`, `ec11_countdown.asm`

| Part | Description |
|------|-------------|
| `ec11_actor_09AA40` | **One-time blocking sprite.** If flag `#DF` set → die. Sets flag `#DF`, loads `table_0EE000`, animates frame `#33` ×2 loop, moves to `($0048,$0050)` via `StageMove(#33,#02,#FF)`. |
| `ec11_flower` | **Interactive flower hint.** Frame `#3F`, positioned +2 Y. Interactable → *"Flower in the corner: Try playing the Flute... Play the melody..."* |
| `ec11_actor_09BC8B` | **Push-button switch #1.** Uses `enemy_stats_table+118` stats. Solid, invulnerable (`HP` reset to `$FF` every hit cycle). On hit: animates press frames `#11` → `#12`, returns to idle frame `#0F`. No direct puzzle logic — works in tandem with `ec11_button_voice`. |
| `ec11_button_voice` | **Push-button switch #2 + validation.** Same stats/frame as switch #1. On hit: checks flag word `$0113` (already solved) → just animate. Checks flag `#02` (success pending) → same. Checks flag `#01` (countdown at "3") → if set: clears flag `#02`, animates press, applies `StageBgChange(#13)` → `ApplyBgChange`, sets flag word `$0113`, plays sound `$0F0F`, prints *"Stop! The door is open!! Go in!!"*, plays sound `#16`. If `#01` not set (wrong timing): prints *"Wait! I told you, you have to push them at the same time!"* → sets flag `#03` (retry signal to countdown). |
| `ec11_countdown` | **Countdown voice controller.** If flag word `$0113` set → idle. If flag `#02` set → idle. Waits for player nearby (`BranchIfPlayerNear #03`). Locks joypad, prints *"Strange Voice: The door won't open unless you push this switch on the count of three..."*. Starts music `#1B`. Main loop: plays sound `#10`, waits `$78` frames, displays digit "1" via `oam_digit_compose.ComposeDigitSprites` (positioned above player via `code_09BEFC`). Waits, displays "2". Then sets flag `#01`, plays sound `#11`, waits `$28` frames displaying "3", checks flag `#02`. If `#02` not set by `ec11_button_voice` in time → clears `#01`, re-prints hint, loops back. If flag `#03` set (retry) → clears `#03`, restarts countdown. |

| Flag | Set by | Purpose |
|------|--------|---------|
| `#DF` | `ec11_actor_09AA40` | Blocking sprite triggered |
| `$0113` | `ec11_button_voice` | Door opened (solved) |
| `#01` | `ec11_countdown` | Countdown at "3" — hit window |
| `#02` | (expected from player timing) | Success — simultaneous push |
| `#03` | `ec11_button_voice` | Wrong timing — retry |

---

#### aqueduct_back (`$09BF0F`–`$09BF90`, 129 bytes)

**Files:** `extracted/edward_castle/aqueduct_back/ec12_actor_09BF0F.asm`, `ec12_actor_09BF6B.asm`

| Part | Description |
|------|-------------|
| `ec12_actor_09BF0F` | **Rear switch.** Uses `enemy_stats_table+118`, invulnerable. If Will is in normal form (`characterForm=0`), sets `$0200` on `$10`. On first hit: plays sound `$0F0F`, applies `StageBgChange(#14)` + `StageBgChange(#15)`, sets flag words `$0114` and `$0115`. Subsequent hits just animate. |
| `ec12_actor_09BF6B` | **Dark Space spawner.** If flag word `$0116` set → spawns `dark_space.code_08D6B5` at absolute `($00A8,$04C0)` with `$0B00` flags, sets `$0024=1` on spawned actor, dies. Otherwise waits on `ExitIfFlagWord($0116)` with `$B3` frame delay. |

| Flag | Set by | Purpose |
|------|--------|---------|
| `$0114`/`$0115` | `ec12_actor_09BF0F` | Rear switches activated |
| `$0116` | (external) | Trigger for Dark Space spawn |

---

#### aqueduct_exit (`$09BF90`–`$09C26F`, 735 bytes)

**File:** `extracted/edward_castle/aqueduct_exit/ec13_lily.asm`

| Part | Description |
|------|-------------|
| `ec13_lily` | **Lily reunion cutscene.** If flag `#3A` set: checks `characterForm` — if demon form, locks joypad, prints *"When the enemies are destroyed, Will can return to his original shape..."*, hooks player to `sE6_gaia.func_08F37D` (Gaia revert), dies. **First visit** (flag `#3A` clear): waits 1 frame, starts music `#1B`, waits, adds position offset. If demon form → same revert message + hook, then waits for player near. On approach: sets flag `#3A`, locks joypad. Long dialogue: Lily reveals she saw Will shape-change, introduces herself as an Itory girl protected by the Flower Spirit, they discuss Grandma Lola's pie and the melody. Plays sound `$1616`, waits `$EF` frames. Lily delivers farewell (*"The Elder is calling... We'll meet again!"*). Exit animation: cycles through frames `#24`→`#23`→`#25`→`#22`→`#36`, then walks offscreen with `StageSpriteLoopMoveY(#36)`. |

| Flag | Set by | Purpose |
|------|--------|---------|
| `#3A` | `ec13_lily` | Lily reunion complete |

---

#### Shared falling-block (`$09C2D0`–`$09C33B`, 107 bytes)

**File:** `extracted/edward_castle/ec_actor_09C2D0.asm`

| Part | Description |
|------|-------------|
| `ec_actor_09C2D0` | **Reusable falling ceiling-block trap.** Entry `code_09C2D3`: waits for player within 2 tiles (`BranchIfPlayerNear #02`). Entry `code_09C2DB`: sets `orbitAngle=0` (solid variant). Entry `code_09C2E4`: sets `orbitAngle=1` (pass-through variant). Core: adds +8 X offset, spawns `code_09C333` (dust animation, frame `#1F` ×3 loop). Teleports block 256px above current Y. Sets max collision priority, falls with `StageSpriteLoopMoveY(#18,#02,#0F)`, plays sound `$1515`. Clears max priority, drops to final Y with `StageSpriteMoveY(#18,#35)`, sets min priority. If `orbitAngle=0`: `SolidHighHere` (becomes solid). If `orbitAngle=1`: `ClearAllHere` (clears collision). |

---

### 3.4 Incan Ruins (3,363 bytes — 10.3%)

Overflow actors from the Incan Ruins dungeon covering puzzles, environmental
hazards, NPC encounters, and lore.

#### incan_ruins_entrance (`$09C9FF`–`$09CF86`, 1,415 bytes)

**Files:** `extracted/incan_ruins/incan_ruins_entrance/ir1C_lily.asm`, `ir1C_kara.asm`

| Part | Description |
|------|-------------|
| `ir1C_lily` | **Lily exposition cutscene.** If flag `#4B` set → positions at tile `($16,$13)`, becomes solid NPC. If demon form → hooks player to `sE6_gaia.func_08F37D` for revert. On interact: repeats Elder's riddle. **First visit**: locks joypad, long dialogue about the Incan Gold Ship legend (*"After being invaded, the Incas decided to leave their native land..."*). Sets solid tiles at `($06,$19)` / `($07,$19)`. Spawns `EscortFollowPathTracker` (orbit `angle=3`, `diameter=$1A`). Loops, checking for flag `#01` (Kara trigger). When Kara arrives: kills escort, clears solid tiles. Hooks player via `InitPlayerScriptVariant(#0)`. Lily reacts: *"Why are you in a place like this! It's dangerous!"* Kara responds: *"Lola told me about this place..."* Sets flag `#02`. Waits, Lily walks away with exit animation (frames `#1E`→`#1A`→`#1C`→`#1B`). Prints Elder's riddle: *"Put the statue on the Larai Cliff below the ruins, where the spirits' breath cannot reach."* Sets flag `#4B`. Walks off screen right. |
| `ir1C_kara` | **Kara confrontation.** If flag `#4B` set → positions at tile `($15,$13)`, becomes solid NPC with repeat dialogue *"Well? Did you find what you were looking for?"*. **First trigger**: waits for player in tile region `($1A,$0F)–($1B,$11)`. Locks joypad, sets flag `#01`, starts music `#1B`. Walks with `StageSpriteMoveX(#19,#01)` then `StageSpriteMoveY(#17,#02)`. Poses frame `#13`. Prints *"Kara: You're so mean!! Leaving me behind!"* Starts music `#02`, sets flag `#03`. Waits for flag `#02`, walks south + right offscreen. |

| Flag | Set by | Purpose |
|------|--------|---------|
| `#01` | `ir1C_kara` | Kara triggered (Lily reacts) |
| `#02` | `ir1C_lily` | Lily spoke → Kara can leave |
| `#03` | `ir1C_kara` | Kara confrontation done |
| `#4B` | `ir1C_lily` | Full cutscene complete |

---

#### larai_cliff (`$09C26F`–`$09C2D0`, `$09C579`–`$09C66E`, `$09D02B`–`$09D0F5`, 544 bytes)

**Files:** `extracted/incan_ruins/larai_cliff/ir1D_bones.asm`, `ir1D_wind_melody.asm`, `ir1D_monologue.asm`

| Part | Description |
|------|-------------|
| `ir1D_bones` | **Interactable skeleton.** Frame `#2E`, solid. On interact: *"There's something on the ground there... If I can move that gold statue, I can pass..."* |
| `ir1D_wind_melody` | **Melody of the Wind acquisition** (item `#08`). If flag `#32` set → die. Waits for player at `($0050,$0170)`. Locks joypad, starts music `#1B`, waits `$77` frames, plays sound `#16`. Prints *"The wind in the valley plays a melody. The statue seems to be singing..."* Starts music `#1A`, waits `$77` frames. Polls `APUIO1` (`$2141`) — loops until it reads `$FF` (music finished). Then `GiveItem(#08)` — if inventory full: prints *"You can hear the Melody of the Wind. But your inventory is full."*. Otherwise: prints *"You've learned the Melody of the Wind!"*, sets flag `#32`. |
| `ir1D_monologue` | **One-time inner monologue.** If flag `#6C` set → die. Sets flag, locks joypad, waits `$1D` frames. Prints: *"Will: There was a tremendous wind at the Larai Cliff. That's probably what the old man meant by the breath of the spirits.... This is the cliff with no wind. My heart beats fast."* |

| Flag | Set by | Purpose |
|------|--------|---------|
| `#32` | `ir1D_wind_melody` | Melody learned |
| `#6C` | `ir1D_monologue` | Monologue played |

---

#### larai_cliff_back (`$09C4B2`–`$09C579`, 199 bytes)

**Files:** `extracted/incan_ruins/larai_cliff_back/ir1E_actor_09C4B2.asm`, `ir1E_actor_09C54D.asm`, `ir1E_actor_09C563.asm`

| Part | Description |
|------|-------------|
| `ir1E_actor_09C4B2` | **Wind scare / rockfall controller.** Continuously monitors `playerYPos`: sets flag `#00` when Y < `$0110`, clears when Y ≥ `$0110`. Waits until both flags `#30` and `#31` are set (both cliff edges cleared). Then sets flag `#00`, plays sound `$1616`. Waits for player at `($01E8,$0120)` or `($01E7,$0120)`. On trigger: locks joypad, plays sound `$1616`. Spawns `code_09C51B` (falling rocks) ×40 frames via `LoopInit(#28)`. **Rock sub-actor** (`code_09C51B`): X fixed at `$02A0`, Y randomized (`RngByte + $0090`). Second `RngByte & $0003` selects one of 3 rock variants: frames `#1A` (speed `$0C`), `#1B` (speed `$0E`), `#1C` (speed `$10`) — all `StageSpriteLoopMoveX` for `$40` frames. After rocks: sets `playerSpeedEw=$FFF8` (push west), unlocks joypad, waits `$3B` frames, loops back. |
| `ir1E_actor_09C54D` | **Left cliff-edge decoration.** Frame `#19`, priority `#30`, Y offset `#FE`. When flag `#30` set: clears `$2000` visibility and idles. |
| `ir1E_actor_09C563` | **Right cliff-edge decoration.** Same as left but watches flag `#31`. |

---

#### stone_lord_plates (`$09C3BB`–`$09C4B2`, 247 bytes)

**Files:** `extracted/incan_ruins/stone_lord_plates/ir1F_gold_tile.asm`, `ir1F_actor_09C489.asm`

| Part | Description |
|------|-------------|
| `ir1F_gold_tile` | **Individual gold pressure plate.** If flag `#3C` set → die. Adds `(+8,+8)` position offset. Checks: player near (`#01`) OR any of actors `#02`–`#05` near (`BranchIfActorNear`). When occupied: calls `cop_handlers_script.SetFlagRaw` with `$0E` (actor event flag). When vacated: calls `ClearFlagRaw`. On first player step: if flag `#0F` not set, prints hint *"Stepping on a gold tile emits a sound. There are four gold tiles. Stand on each of the four tiles at the same time."* → sets `#0F`. |
| `ir1F_actor_09C489` | **Puzzle completion monitor.** If flag `#3C` set → die. Polls `eventFlags & $001E` — when all 4 bits set (all plates pressed simultaneously): plays sound `$0F0F`, `StageBgChange(#08)` → `ApplyBgChange`, sets flag word `$0108` and flag byte `#3C`. |

| Flag | Set by | Purpose |
|------|--------|---------|
| `#0F` | `ir1F_gold_tile` | Hint displayed |
| `#3C` | `ir1F_actor_09C489` | Puzzle solved |
| `$0108` | `ir1F_actor_09C489` | BG change applied |
| `eventFlags & $001E` | `ir1F_gold_tile` instances | Individual plate occupied |

---

#### inca_entryway (`$09C33B`–`$09C3BB`, 128 bytes)

**Files:** `extracted/incan_ruins/inca_entryway/ir25_ceiling_tile.asm`, `ir25_block_slot.asm`

| Part | Description |
|------|-------------|
| `ir25_ceiling_tile` | **Falling ceiling trap.** Adds +8 X. If flag `#2F` set → skip to `code_09C38D` (clear collision + unlock). First visit: locks joypad, waits `$3B` frames, plays sound `$1515`, spawns `CameraDriftLoopSimple`, waits `$B3` frames, random byte → `$08`. Falls block from 256px above (same `StageSpriteLoopMoveY`/sound pattern as `ec_actor_09C2D0`). Ends: clears `$2000` visibility, sets min collision priority, `ClearAllHere`, unlocks joypad. |
| `ir25_block_slot` | **Companion sound actor.** Frame `#1D`, adds +8 X. If flag `#2F` set → clear `$2000` and idle. Otherwise plays sound `#2C` on channel 2 via `PlaySoundCh2`. |

---

#### inca_plate_room (`$09C66E`–`$09C6A9`, 59 bytes)

**File:** `extracted/incan_ruins/inca_plate_room/ir24_glowing_tile.asm`

| Part | Description |
|------|-------------|
| `ir24_glowing_tile` | **Timed step-on puzzle.** If flag word `$0112` set → die. Sets `orbitAngle` = `$0258` (600 frames) as countdown timer. Waits for player in tile region `($14,$17)–($17,$1A)`. While player is standing: decrements `orbitAngle` each frame. If player leaves tile → resets timer to 600. When timer reaches 0: plays sound `$0F0F`, `StageBgChange(#12)` → `ApplyBgChange`, sets flag word `$0112`. |

---

#### ceiling_trap_room (`$09C6A9`–`$09C8F7`, 329 bytes)

**Files:** `extracted/incan_ruins/ceiling_trap_room/ir28_actor_09C6A9.asm`, `ir28_bones.asm`

| Part | Description |
|------|-------------|
| `ir28_actor_09C6A9` | **Multi-zone ceiling trap controller.** Checks 6 tile regions each frame via `BranchIfPlayerInAbsTiles`. **Zone 1** `($1A,$0C)–($1C,$0E)`: flag `#01`, single block at `($01A8,$0130)` via `ec_actor_09C2D0.code_09C2DB`. **Zone 2** `($1A,$16)–($1C,$18)`: flag `#02`, single block at `($01C8,$01C0)`. **Zone 3** `($12,$24)–($14,$26)`: flag `#03`, single block at `($00E8,$0260)`. **Zone 4** `($08,$24)–($0A,$26)`: flag `#04`, double block at `($0088,$0220)` + `($0088,$0200)` (14-frame delay between) via `code_09C2E4`. **Zone 5** `($10,$1C)–($12,$1E)`: flag `#05`, double block at `($0088,$01C0)` + `($0088,$01A0)`. **Zone 6** `($12,$16)–($14,$18)`: flag `#06`, double block at `($0128,$0160)` + `($0128,$0140)`. Each plays sound `$2C2C` on trigger. |
| `ir28_bones` | **Interactable skeleton.** Frame `#2E`, solid. On interact: *"An explorer who sought the Incan Gold Ship...? He lost his life in a trap..."* |

---

#### inca_treasure_room (`$09C798`–`$09C9FF`, 525 bytes)

**Files:** `extracted/incan_ruins/inca_treasure_room/ir26_bones.asm`, `ir26_journal_bones.asm`

| Part | Description |
|------|-------------|
| `ir26_bones` | **Skeleton with family charm.** Frame `#2E`, solid. On interact: *"An explorer who sought the Incan Gold Ship...? In the skeleton's hand is some kind of charm."* Then reads two notes: *"Father, please come back alive. — Nana"* and *"When you find the Gold Ship, buy a Kruk. — Sabas"* |
| `ir26_journal_bones` | **Explorer's journal.** Frame `#2E`, solid. On interact: *"There's some kind of journal..."* → *"Note about the Incas: They have no written language. They've left their legends in sound. I have succeeded in deciphering the Incan Melody of the Wind. 'Chant in the Golden Room.' Does that mean to play the Melody of the Wind...?"* |

---

#### castoth_lair (`$09CF86`–`$09D02B`, 165 bytes)

**File:** `extracted/incan_ruins/castoth_lair/ir29_transform.asm`

| Part | Description |
|------|-------------|
| `ir29_transform` | **Post-Castoth controller.** If flag word `$011F` set → die. Waits until `$0AEC = 0` (boss defeated). Locks joypad, applies `StageBgChange(#1F)` → `ApplyBgChange`, sets flag word `$011F`. Fades and starts music `#1B`, waits `$77` frames. If Will is in demon form: locks additional joypad, waits `$59` frames, prints *"After the demon disappears, Will returns to his original shape..."*, hooks player to `sE6_gaia.func_08F37D` (revert transform), waits for `playerFlags & $0800` to clear. Then unlocks joypad. |

---

### 3.5 Global System Actors (2,167 bytes — 6.6%)

System-wide actors spawned across many scenes throughout the game.

**Files:** `extracted/system/dark_space/sE6_gaia.asm` (bank 9 tail), `extracted/unused/hint_npc.asm`, `extracted/unused/dark_rewards.asm`

| Part | Address | Description |
|------|---------|-------------|
| `e_actor_09A090` | `$09A090`–`$09A0D7` | **Dark Space Gaia visual effect.** Spawned by `sE6_gaia` (bank 8). Plays one sprite animation frame. Idle flicker variant: when `$24` set and SFX queued, randomly cycles frames 1–3 (ambient Gaia glow). |
| `hint_npc1` / `hint_npc2` | `$09A0D7`–`$09A143` | **Dark Space hint NPCs.** Two actor defs (invisible interactable). `hint_npc2` spawns companion sprite actors with animated flicker. |
| `code_09A143` | `$09A143`–`$09A3DF` | **Hint NPC shared code.** Uses `$26` (parent scene index) in a `SwitchCase` to select one of **8 hint strings** covering: jewels, Dark Power, jumping mechanics, pyramid cracks, combat tips, water droplets, etc. |
| `dark_rewards1` / `dark_rewards2` | `$09A3DF`–`$09A915` | **Dark Space ability reward NPCs.** Same visual template as `hint_npc`. Scene ID (`$0B12`) → reward mapping: `$15` → Psycho Crusher (`abilityBitmask` bit 0), `$42` → Psycho Flier (bit 4), `$62` → Psycho Slider (bit 1), `$86` → Spin Dasher (bit 2), `$B8` → Earthquaker (bit 6), `$A7` → Aura Barrier (bit 5), `$CC` → Aura item (`#24`) via `GiveItem`, `$A1` → hint dialog only. Sets bitmask bit on first grant; repeat visits show shortened message. |

---

### 3.6 Overflow: Dao, Itory, Pyramid (1,659 bytes — 5.1%)

**Files:** `extracted/dao/dao/daC3_babel_travel_spirit.asm`, `extracted/itory/moon_tribe_camp/it1A_moon_tribe.asm`, `extracted/pyramid/func_09BB17.asm`

| Part | Address | Scene | Description |
|------|---------|-------|-------------|
| `daC3_babel_travel_spirit` | `$0980C3`–`$098146` | dao | Travel spirit in Dao village. Uses `table_0EDA00` metasprite, solid + interactable. Dialogue: *"Go to Tower of Babel? Quit / Return"*. On confirm: clears `$066D`/`$0670`, sets `gfxCacheIdxA`/`gfxCacheIdxB`, `QueueMapChange` to scene `$E3` at `($0280,$01B0)`. Dies if flag `$D2` set. |
| `it1A_moon_tribe` | `$09D0F5`–`$09D64D` | moon_tribe_camp | **Moon Tribe camp scene.** Clears `$7F0B00` buffer. Intro actor: waits for player nearby, plays "Strange Voice" riddle dialogue — wrong answer reveals Moon Tribe / Shadows. Once flag `$2A` set: becomes solid, plays palette flash, enables interact. Five lore NPCs discuss: shadows/light duality, comet cycle, kidnapped member, Incan statue in cave below. One NPC offers yes/no destination choice (both answers lead to teasing). |
| `func_09BB17` | `$09BB17`–`$09BBB7` | (utility) | **Pyramid collision-layer copier.** Copies SFX/effect tilemap layer (`$7EC000`) into collision layer (`$7FC000`) using camera scroll deltas from `$06BF`–`$06C5`. Iterates viewport region using `$0693`–`$0699` dimensions. For each tile: if effect layer tile nonzero, copies via indirect addressing through `$3E` pointer. Uses `hardware_math.SignedMultiply` for coordinate mapping. Called by pyramid block-puzzle actors (`pyD7_actor_08C4EA`). |

---

### 3.7 Unused / Debug (4,490 bytes — 13.7%)

**Files:** `extracted/unused/actor_09AA6E.asm`, `extracted/unused/actor_09BA80.asm`, `extracted/unused/actor_09BAE3.asm`, `extracted/unused/kara_09BBB7.asm`

| Part | Address | Description |
|------|---------|-------------|
| `actor_09AA6E` | `$09AA6E`–`$09BA80` | **Cut boss encounter** (4,114 bytes including data tables). Multi-phase fight: resets camera, spawns ~10+ marked child actors (turrets, orbiters, palette thinker, spawners). Main loop: repeating attack cycle with spawned effects, hit callbacks, and timed waits. On boss body death (`code_09ABF5`): VRAM DMA from `$7EExxx` buffers, spawns boss body with `enemy_stats_table+15C` stats. Boss AI: random movement toward player, 8-way orbital projectiles via `ApplyOrbitalOffsetFromRef`. On defeat (`code_09B1D5`): spawns celebration effects. `code_09BA38`: resets `characterForm=0`, sets `gfxCacheIdxB=#$0404`, `QueueMapChange` to scene `$E5`. Includes sine lookup helper `code_09BA59` and child actor position propagation `code_09B9CC`. |
| `actor_09BA80` | `$09BA80`–`$09BAE3` | **Debug max-stats actor.** Sets `playerMaxHp=playerHp=$13` (19 HP), `playerStr=$20`, `playerDef=$21`, `MEMSEL=1` (fast ROM), `characterForm=2` (Shadow), `abilityBitmask=$FF` (all abilities). Sets `$0200` on player flags. Loops on Start button (`$0080`): increments frame counter `$28`, wraps at `$42` — likely a hold-to-advance debug gate. |
| `actor_09BAE3` | `$09BAE3`–`$09BB17` | **Debug metasprite viewer.** Loads `table_0EE000`, loops on Start button with frame counter wrapping at `$33` (51 frames). No stat changes — minimal test placeholder. |
| `kara_09BBB7` | `$09BBB7`–`$09BC34` | **Unused Kara dialogue test.** Sets `$0800` on `$10`, `$1000` on `$12`. Spawns `code_09BBCE` child. Child: writes `#00` to `APUIO0`, prints Kara dialogue *"It's terrible! Leave me alone! How far will you go?!"*, starts music `#02`, waits, writes `#00` to `APUIO0`, same dialogue, starts music `#04`, waits. Loops while Start held. Countdown `$24=$78` (unused). |

---

## 4. Cross-Cutting References

### 4.1 Shared code across groups

| Shared resource | Used by |
|----------------|---------|
| `ec_actor_09C2D0` (falling block) | `ir25_ceiling_tile`, `ir28_actor_09C6A9` (via `code_09C2DB` / `code_09C2E4`) |
| `bt_actor_099B1C` (marker sprite) | All 5 door controllers (`btE0_*` × 4, `btE3_actor_0987D8`), `btDF_crystal_ring` |
| `func_09E8E4` (placement utility) | All 6 credits parade actors, `misc_actors_09E64B` (16+ crowd actors), `code_09E62F`/`code_09E637` |
| `sE6_gaia.func_08F37D` (form revert) | `ec13_lily`, `ir1C_lily`, `ir29_transform` |
| `btE1_comet_soon.code_0997B7` (player climb sprite) | `btE1_comet_soon`, `btE2_brought_back` |
| `EscortFollowPathTracker` (follower) | `btDE_kara_missing`, `btE3_kara`, `btDF_kara`, `ir1C_lily` |
| `InitPlayerScriptVariant` (script hook) | `btDE_olman`, `btDE_monologue`, `btDF_kara`, `ir1C_lily` |
| `func_09BB17` (collision copier) | Pyramid block-puzzle actors (bank 8) |
| `oam_digit_compose.ComposeDigitSprites` | `ec11_countdown` |
| `cop_handlers_script.SetFlagRaw/ClearFlagRaw` | `ir1F_gold_tile` |

### 4.2 Key flag words

| Flag | Scene | Purpose |
|------|-------|---------|
| `$0113` | aqueduct_doorway | Door opened (dual-switch puzzle) |
| `$0112` | inca_plate_room | Glowing tile room opened |
| `$0108` | stone_lord_plates | Stone Lord puzzle solved |
| `$0114`/`$0115` | aqueduct_back | Rear switches activated |
| `$0116` | aqueduct_back | Dark Space enemy spawn trigger |
| `$011F` | castoth_lair | Post-Castoth BG change applied |
| `$0175`–`$0179` | babel_middle/upper | Floor door controllers |

### 4.3 Items granted

| Item | Actor | Scene |
|------|-------|-------|
| `#08` Melody of the Wind | `ir1D_wind_melody` | larai_cliff |
| `#27` Crystal Ring | `btDF_crystal_ring` | babel_lower_floors |
| `#24` Aura | `dark_rewards2` | dark_space (scene `$CC`) |

---

## 5. Space Utilization

| Region | Bytes | % |
|--------|-------|---|
| Babel Tower actors | 10,337 | 31.6% |
| Ending credits sequence | 7,705 | 23.5% |
| Unused / debug content | 4,490 | 13.7% |
| Incan Ruins overflow | 3,363 | 10.3% |
| Global system actors | 2,167 | 6.6% |
| Edward Castle aqueduct | 2,040 | 6.2% |
| Miscellaneous overflow | 1,659 | 5.1% |
| Ending class dismissed | 576 | 1.8% |
| **Unmapped tail** | **2,394** | **7.3%** |
| **Total** | **32,768** | **100%** |
