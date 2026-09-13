> **DEPRECATED** — This document has been superseded by the
> [Bank $03 v2 documentation](../code_v2/bank03/field-input-and-items.md).
> Do not update this file; see the v2 suite for current information.

# Item Use System — Dispatcher, Handlers & Utilities

> Analysis of `chunk_038000.asm` §2 — the item use dispatcher, all 41
> individual item handlers, and shared utility routines.
>
> **Address range:** `$038410`–`$03A0A7` (7,320 bytes — ~87% of the chunk)

---

## 1. Overview

When the player presses **Y** on the overworld, the `GlobalInputHandler`
jumps to the item dispatcher, which reads the currently equipped item slot,
extracts the item type ID (6-bit, 0–63), and dispatches through a 64-entry
jump table to the appropriate item handler.

Each handler is responsible for:
- Printing introductory text (item name / action description)
- Checking scene and tile-position prerequisites
- Applying game effects (set flags, remove items, spawn actors)
- Printing result text

A common epilogue routine (`ItemUseEpilogue`) handles post-use frame updates.

---

## 2. Dispatcher & Infrastructure

### 2.1 `sub_038410` — Item Use Dispatcher

**Proposed name:** `ItemUseDispatch`

| Property | Value |
|----------|-------|
| Address | `$038410`–`$03842E` |
| Size | 31 bytes |
| Entry | `JMP` from `GlobalInputHandler` (Y button) |
| Exit | Falls through to handler → `RTS` → `ItemUseEpilogue` |

**Behavior:**

1. Pushes `ItemUseEpilogue - 1` onto the stack as a return address (`PEA`),
   so every handler's `RTS` returns to the epilogue automatically.
2. Reads `inventoryEquippedIndex` — if negative (no item), jumps to
   `UseItem_None`.
3. Loads the equipped slot from `inventorySlots,Y`, masks to 6-bit item ID.
4. Doubles the ID for the word-sized jump table index.
5. Masks Y in `joypadHeld` to prevent re-trigger.
6. Dispatches via indirect jump through `ItemHandlerJumpTable`.

### 2.2 `sub_03842F` — Item Use Epilogue

**Proposed name:** `ItemUseEpilogue`

| Property | Value |
|----------|-------|
| Address | `$03842F`–`$03843E` |
| Size | 16 bytes |

Called implicitly after every item handler returns (via the stacked return
address). Performs:

1. `SEP #$20` — switch to 8-bit accumulator.
2. `JSL UpdateFrameDialogue` — process any pending dialogue frame.
3. `REP #$20` — back to 16-bit.
4. Masks Y in `joypadHeld`.
5. Restores processor state (`PLP`) and returns (`RTL`) to the main loop.

### 2.3 `table_03843F` — Item Handler Jump Table

**Proposed name:** `ItemHandlerJumpTable`

| Property | Value |
|----------|-------|
| Address | `$03843F`–`$0384BE` |
| Size | 128 bytes (64 × 2-byte entries) |
| Type | `&Code` (same-bank pointer table) |

Maps item type ID (0–63) to the handler routine address. Many upper entries
(29–63) point to `UseItem_Unused` (a bare `RTS` stub).

---

## 3. Item Handler Reference

### 3.1 Item Categories

Items naturally group into functional categories:

| Category | Item IDs | Count |
|----------|----------|-------|
| **Keys** (unlock doors/gates) | 02, 0B, 0C, 0F, 10 | 5 |
| **Statues & Placement** (place at specific tiles) | 03, 04, 07, 0E, 11, 12, 13, 14, 1D, 1E–23 | 15 |
| **Music** (play instrument, trigger effect) | 05, 08, 09, 0D | 4 |
| **Consumables** (heal or collect) | 01, 06, 28 | 3 |
| **Story / Readable** (display text only) | 15, 16, 17, 18, 19, 1B, 1C, 25, 26, 27 | 10 |
| **Transformation** (change character form) | 24 | 1 |
| **Quest Triggers** (scene-specific effects) | 0A, 1A | 2 |
| **Unused** | 29–3F | 23 |

### 3.2 Complete Handler Table

| ID | Item | Handler | Proposed Name | Behavior Summary |
|----|------|---------|---------------|-----------------|
| 00 | *(none)* | `func_0384BF` | `UseItem_None` | Prints "You're not equipped." |
| 01 | Red Jewel | `func_0384D5` | `UseItem_RedJewel` | Increments BCD jewel counter, removes item, spawns orbital light animation |
| 02 | Prison Key | `func_0385C2` | `UseItem_PrisonKey` | Scene $0B: checks two door positions, sets flags, clears tiles |
| 03 | Inca Statue A | `func_038691` | `UseItem_IncaStatueA` | Scene $1E: places at Y=$12–13, X=$37–38 |
| 03′ | *(cont.)* | `func_0386DD` | `UseItem_IncaStatueA_CheckAlt` | Checks alternate position Y=$15–16, X=$26–27 |
| 04 | Inca Statue B | `func_0387A7` | `UseItem_IncaStatueB` | Scene $1E: places at Y=$15–16, X=$26–27 |
| 04′ | *(cont.)* | `func_0387F3` | `UseItem_IncaStatueB_CheckAlt` | Checks alternate position Y=$12–13, X=$37–38 |
| 05 | Incan Melody | `func_03881D` | `UseItem_IncanMelody` | Prints melody text; scene $18: sets flag $2E (Mayor's expression) |
| 06 | Herb | `func_03888A` | `UseItem_Herb` | Yes/No dialogue; restores health (sets `damageFlashTimer`), removes item |
| 07 | Diamond Block | `func_038917` | `UseItem_DiamondBlock` | Scene $25: checks Y=$19–1A, X=$0E–0F |
| 07′ | *(cont.)* | `func_038971` | `UseItem_DiamondBlock_Place` | Removes item, sets flag $2F |
| 08 | Flute (Wind) | `func_03899A` | `UseItem_WindFlute` | Will form only; scene $24: spawns flute actor, triggers melody |
| 08′ | *(callback)* | `func_038A16` | `UseItem_WindFlute_Effect` | Sets flag, spawns palette cycler, prints vision text |
| 09 | Lola's Melody | `func_038BA4` | `UseItem_LolaMelody` | Will form only; scenes $15/$11/$CD: spawns flute actor |
| 09′ | *(callback)* | `func_038C35` | `UseItem_LolaMelody_Effect` | Per-scene flag setting, prints result text |
| 0A | Smoked Meat | `func_038D67` | `UseItem_SmokedMeat` | Scene $2F: removes item, sets flag $03 (Itori's cave) |
| 0B | Mine Key A | `func_038E15` | `UseItem_MineKeyA` | Scene $44: checks tile area, removes item, sets flag $5B |
| 0C | Mine Key B | `func_038E96` | `UseItem_MineKeyB` | Scene $44: checks tile area, removes item, sets flag $5C |
| 0D | Memory Melody | `func_038F17` | `UseItem_MemoryMelody` | Will form only; scene $39: spawns flute actor |
| 0D′ | *(callback)* | `func_038F6F` | `UseItem_MemoryMelody_Effect` | Removes item, spawns palette reset thinker, sets flag $0F |
| 0E | Crystal Ball | `func_038FF3` | `UseItem_CrystalBall` | Scene $4C: 4 placement positions, sets flags $60–$63, removes item |
| 0F | Elevator Key | `func_0390CE` | `UseItem_ElevatorKey` | Scene $3F: checks tile area, removes item, sets flag $69 |
| 10 | Seaside Key | `func_039144` | `UseItem_SeasidePalaceKey` | Scene $5A: removes item, applies BG change $38, prints Lilly dialogue |
| 11 | Purification Stone | `func_03921A` | `UseItem_PurificationStone` | Scene $5D: makes tile solid, removes item, sets flag $0E |
| 12 | Statue of Hope | `func_039299` | `UseItem_StatueOfHope` | Scene $63: 2 positions, sets flags $7B/$7E, removes item |
| 13 | Rama Statue | `func_03932B` | `UseItem_RamaStatue` | Scene $66: 2 positions, sets flags $80/$81, removes item |
| 14 | Magic Powder | `func_0393A1` | `UseItem_MagicPowder` | Scene $74: removes item, sets flag (Kara's painting) |
| 15 | Journal | `func_039427` | `UseItem_Journal` | 3-option dialogue: Tower of Babel / Mystic Statues / Great Wall |
| 16 | Lance's Letter | `func_03950C` | `UseItem_LanceLetter` | Sets flag $8E, displays multi-page letter text |
| 17 | Lilly's Necklace | `func_03966A` | `UseItem_LillyNecklace` | Display-only: "Lance made this necklace for Lilly..." |
| 18 | Will (testament) | `func_039691` | `UseItem_Will` | Display-only: multi-page will text (Russian Glass subplot) |
| 19 | Teapot | `func_03983D` | `UseItem_Teapot` | Scene $95: removes item, sets flag $A8 (spirit tears) |
| 1A | Mushroom Water | `func_0398B2` | `UseItem_MushroomWater` | Scene $A2: sets flag (stems); scene $A5 via continuation |
| 1A′ | *(cont.)* | `func_0398DA` | `UseItem_MushroomWater_Alt` | Scene $A5: 2 positions, sets flag $01 or $02 |
| 1B | Prize Money | `func_03995C` | `UseItem_PrizeMoney` | Display-only: "It's the prize money from Russian Glass." |
| 1C | Black Glasses | `func_03997F` | `UseItem_BlackGlasses` | Display-only: "glasses made of black crystal" |
| 1D | Gorgon Flower | `func_0399CD` | `UseItem_GorgonFlower` | Scene $AE: 3 statue positions, sets flags $BF/$C0/$C1; removes when all 3 placed |
| 1E–23 | Hieroglyph Plates | `func_039AA0` | `UseItem_HieroglyphPlate` | Scene $CD: 6-slot placement puzzle with tile exchange logic |
| 24 | Aura | `func_039CAF` | `UseItem_Aura` | Freedan form, not moving → triggers Dark Knight transformation |
| 25 | Letter (Bill/Lola) | `func_039D09` | `UseItem_BillLolaLetter` | Display-only: multi-page letter from Bill & Lola |
| 26 | Father's Journal | `func_039E15` | `UseItem_FatherJournal` | Display-only: hieroglyph decipherment text |
| 27 | Crystal Ring | `func_039F30` | `UseItem_CrystalRing` | Display-only: "Crystal Ring that King Edward is looking for" |
| 28 | Apple | `func_039F5D` | `UseItem_Apple` | Removes item, sets `damageFlashTimer` = 1 (minor heal) |
| 29–3F | *(unused)* | `func_039FB1` | `UseItem_Unused` | Bare `RTS` — no action |

---

## 4. Detailed Handler Analysis

### 4.1 Key Items

All key items follow the same pattern:
1. Print "He tries using the [key]..." intro text.
2. Check `sceneCurrent` for the target scene.
3. Check player tile position via `COP BranchIfPlayerInAbsTiles`.
4. If wrong scene/position → "But there's no keyhole!" / "Nothing happened."
5. If correct → print success text, `COP RemoveItem`, `COP SetFlagByte`.

**Cross-reference of key target scenes:**

| Item | Scene ID | Scene | Tile Region | Flag Set |
|------|----------|-------|-------------|----------|
| Prison Key | $0B | Edward's Prison | Two door areas | $06 (word), $24/$42 (byte) |
| Mine Key A | $44 | Diamond Mine | $0F–11, $16–19 | $5B |
| Mine Key B | $44 | Diamond Mine | $0F–11, $16–19 | $5C |
| Elevator Key | $3F | Mu Passage | $18–1A, $34–37 | $69 |
| Seaside Key | $5A | Seaside Palace | $08–0A, $07–08 | $0138 (word) |

### 4.2 Statue & Placement Items

These items require placing an object at a specific tile location. Most
check 1–2 valid positions and have mutual exclusion logic (e.g., Inca Statues
A and B can only go in the *correct* pedestal).

**Notable mechanics:**

- **Inca Statues A & B** (`func_038691`–`func_0387F3`): Scene $1E (Gold Ship
  interior). Statue A goes at Y=$12–13/X=$37–38, Statue B at Y=$15–16/
  X=$26–27. If you try the wrong position, you get "The shape doesn't match."
  Both share `code_038705` ("Is the Inca secret hidden?") and `dialogstring_03870A`
  (spirits' breath hint). After flag $44 is set, the hint text changes.

- **Crystal Ball** (`func_038FF3`): Scene $4C has 4 holes for crystal balls,
  each with its own flag ($60–$63). All four share a "Crystal Ball set!"
  success message and call `RemoveEquippedItem`.

- **Gorgon Flower** (`func_0399CD`): Scene $AE has 3 statue mouths. Each
  petal placement sets its own flag ($BF/$C0/$C1). After all three are placed,
  the item is automatically removed via `COP RemoveItem`.

- **Hieroglyph Plates** (`func_039AA0`→`func_039AAD`): The most complex
  handler. Scene $CD: presents a 7-option dialogue (6 slots + cancel).
  Choosing a slot spawns an actor that draws a metatile, exchanges the plate
  with any existing one (via `func_03EF97` in `chunk_03BAE1`), and stores the
  plate ID in `$0B28,Y`. Tile IDs $84–$86, $8C–$8E correspond to the 6
  hieroglyph plate tile variants.

### 4.3 Music Items

Three instruments (Flute/Wind, Lola's Melody, Memory Melody) and the Incan
Melody share a flute-playing actor system:

**Common pattern:**
1. Check `characterForm` — most require Will (form 0). Freedan/Shadow get
   "He doesn't have the Flute."
2. Check `IsMusicPlaying` — can't play during music.
3. Check scene prerequisites (specific scene + flag conditions).
4. If valid: set display-mode dim flag (`$0080`), spawn `FluteMusicActorController`
   (`func_039FCA`), which manages the playback cutscene.
5. The flute actor runs a state machine: waits for music to start, plays until
   complete, then dispatches to a per-instrument callback via `SwitchCase`:
   - Index 0 → `UseItem_WindFlute_Effect` (flag + vision text)
   - Index 1 → `UseItem_LolaMelody_Effect` (per-scene flags)
   - Index 2 → `UseItem_MemoryMelody_Effect` (remove item + palette reset)

**Incan Melody** (`func_03881D`) is simpler — no actor spawn, just prints text
and sets flag $2E in scene $18 (the Mayor).

### 4.4 Consumables

| Item | Mechanic |
|------|----------|
| Red Jewel | BCD increment `jewelsCollected`, removes item, spawns orbital light actor (`code_038566`→`code_038576`) that spirals upward and dies |
| Herb | Yes/No dialogue; "Yes" sets `damageFlashTimer` = 8, removes item |
| Apple | Removes item, sets `damageFlashTimer` = 1 (smaller heal) |

**Red Jewel orbital animation detail:**
- `code_038566` spawns a marked child actor with 255-frame lifetime.
- `code_038576` loads a metasprite, plays sound #$25, then enters an orbit
  loop: each frame, `ApplyOrbitalOffsetFromRef` moves the sprite by increasing
  `orbitAngle` (+2/frame) and `orbitDiameter` (up to 255). When diameter
  reaches max, the actor dies.

### 4.5 Transformation Item

**Aura** (`func_039CAF`): Only works when:
- Player is not jumping (`playerFlags` bit 12 clear)
- Player is not attacking (`playerFlags` bit 8 clear)
- Player is standing still (`playerSpeedEw` and `playerSpeedNs` both zero)
- Character form is Freedan (form 2)

If all conditions met, sets the player's code pointer to
`player_transition_handlers.code_00C557` (Dark Knight transformation) and
calls `SetPlayerTransition`.

---

## 5. Utility Routines

### 5.1 `sub_039FB2` — Remove Equipped Item

**Proposed name:** `RemoveEquippedItem`

| Property | Value |
|----------|-------|
| Address | `$039FB2`–`$039FC9` |
| Size | 24 bytes |
| Entry | `JSR` from ~10 item handlers |
| Exit | `RTS` |

**Behavior:**
1. Reads `inventoryEquippedIndex` into Y.
2. Zeros the inventory slot at `inventorySlots,Y`.
3. Clears `inventoryEquippedType` to 0.
4. Sets `inventoryEquippedIndex` to $FFFF (nothing equipped).

**Called by:** Red Jewel, Crystal Ball (×4), Statue of Hope (×2), Rama Statue
(×2), Hieroglyph Plates, and several other handlers that consume items but
use `COP RemoveItem` instead of this direct routine.

### 5.2 `func_039FCA` — Flute Music Actor Controller

**Proposed name:** `FluteMusicActorController`

| Property | Value |
|----------|-------|
| Address | `$039FCA`–`$03A09F` |
| Size | 214 bytes |
| Entry | `COP SpawnLastRel` from Wind Flute / Lola's Melody / Memory Melody |
| Exit | `COP Die` |

**Behavior — full state machine:**

1. **Setup:**
   - Sets display dim flag.
   - Reads `musicParentActor` to identify the music source.
   - Spawns a music playback actor (`func_03E1D6` in `chunk_03BAE1`) using
     `COP SpawnAfterFlags`.
   - If spawn fails (slot full, Y = $1FC0) → jumps to cleanup and dies.

2. **Lock player:**
   - Sets the player's code pointer to `player_transition_handlers.loc_00C446`
     (frozen/playing animation) via `SetPlayerTransition`.
   - Sets `playerFlags` bit 11 (input lock).
   - Masks most joypad buttons (`$CFF0`).

3. **Wait for music end:**
   - Enters a loop with `COP SetEntryContinue`: checks
     `musicTransitionState` for $FFFF (music done).
   - Also checks APU I/O register 1 for $FF (sound driver idle).

4. **Unlock player:**
   - Restores player's code pointer to `loc_00C455` (normal movement).
   - Unmasks joypad.

5. **Dispatch to callback:**
   - Reads `$0020` (stored during spawn as callback index 0/1/2).
   - Uses `COP SwitchCase` to branch:
     - 0 → `UseItem_WindFlute_Effect`
     - 1 → `UseItem_LolaMelody_Effect`
     - 2 → `UseItem_MemoryMelody_Effect`

6. **Post-callback music replay** (`code_03A06E`):
   - Spawns another music actor, waits for completion, then enters a
     `COP WaitByte` idle loop.

7. **Cleanup** (`code_03A098`):
   - Clears display dim flag, actor dies.

### 5.3 `sub_03A0A0` — Set Player Transition

**Proposed name:** `SetPlayerTransition`

| Property | Value |
|----------|-------|
| Address | `$03A0A0`–`$03A0A7` |
| Size | 10 bytes |
| Entry | `JSR` from `FluteMusicActorController` and `UseItem_Aura` |
| Exit | `RTS` |

**Behavior:**
1. Writes A to `$0000,Y` (player's code pointer low byte).
2. Zeros `$0008,Y` (player's horizontal speed).

---

## 6. Shared String Resources

Several handlers share common "failure" strings:

| String Address | Text | Shared By |
|----------------|------|-----------|
| `$038F82` | "He doesn't have the Flute." | Wind Flute (wrong form), Lola's Melody (wrong form), Memory Melody (wrong form) |
| `$03870A` | "He said to dedicate the statues where the breath of the spirits can't reach." | Inca Statue A/B (after flag $44) |
| `$038772` | "The shape of the mantel doesn't match the statue." | Inca Statue A (wrong spot), B (wrong spot) |
| `$038705` → `$038746` | "Is the Inca secret hidden in the statue?" | Inca Statue A/B (before flag $44) |

---

## 7. Call Graph

```
GlobalInputHandler (Y button)
  └─ JMP ItemUseDispatch
       ├─ PEA ItemUseEpilogue-1  (stacked return)
       ├─ JMP (ItemHandlerJumpTable, X)
       │    │
       │    ├── UseItem_None ─── RTS
       │    ├── UseItem_RedJewel ─── RemoveEquippedItem, COP SpawnLastRel
       │    │    └── code_038566/038576 (orbital light actor)
       │    │         └── JSL ApplyOrbitalOffsetFromRef (external)
       │    ├── UseItem_PrisonKey ─── COP StageBgChange/ApplyBgChange
       │    ├── UseItem_Herb ─── COP DialogueOptions, RemoveEquippedItem
       │    ├── UseItem_WindFlute ─── COP SpawnLastRel → FluteMusicActorController
       │    │    └── UseItem_WindFlute_Effect (callback)
       │    ├── UseItem_LolaMelody ─── COP SpawnLastRel → FluteMusicActorController
       │    │    └── UseItem_LolaMelody_Effect (callback)
       │    ├── UseItem_MemoryMelody ─── COP SpawnLastRel → FluteMusicActorController
       │    │    └── UseItem_MemoryMelody_Effect (callback)
       │    ├── UseItem_HieroglyphPlate ─── COP DialogueOptions, COP SpawnLastRel
       │    │    └── code_039B70 → COP DrawMetatileHere (6 variants)
       │    │    └── JSL chunk_03BAE1.func_03EF97 (plate exchange)
       │    ├── UseItem_Aura ─── SetPlayerTransition
       │    └── ... (all other handlers follow key/statue/text patterns)
       │
       └─ (handler RTS)
            └── ItemUseEpilogue ─── JSL UpdateFrameDialogue, RTL
```

---

## 8. External Dependencies (Item Handlers)

| External Symbol | Source | Purpose |
|----------------|--------|---------|
| `system_core.UpdateFrameDialogue` | `system_core.asm` | Epilogue frame update |
| `music_actors.IsMusicPlaying` | `music_actors.asm` | Music guard (flute items) |
| `ApplyOrbitalOffsetFromRef` | `ApplyOrbitalOffsetFromRef.asm` | Red Jewel orbit animation |
| `cop_handlers_script.TestFlag_0300` | `cop_handlers_script.asm` | Scene flag test |
| `cop_handlers_actors.PaletteResetAndKillThinker` | `cop_handlers_actors.asm` | Memory Melody cleanup |
| `chunk_03BAE1.func_03E1D6` | `chunk_03BAE1.asm` | Music playback actor |
| `chunk_03BAE1.func_03EF97` | `chunk_03BAE1.asm` | Hieroglyph plate exchange |
| `ambient_palette_cycler.code_00B522` | `ambient_palette_cycler.asm` | Wind Flute palette effect |
| `player_transition_handlers.*` | `player_transition_handlers.asm` | Player animation states |
| `table_0EE000` | `table_0EE000.asm` | Red Jewel metasprite data |
