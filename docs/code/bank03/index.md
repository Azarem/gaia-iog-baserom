# Bank 03 — `chunk_038000` Deep Analysis

> Complete reference for the overworld input handler, radar map screen,
> and item use system in IOG's ROM bank `$03`.
>
> **Source:** `extracted/system/chunk_038000.asm`

---

## 1. Chunk Overview

| Metric | Value |
|--------|-------|
| **Address range** | `$038000`–`$03A0A7` |
| **Total size** | 8,360 bytes |
| **Named parts** | 54 (in `blocks.json`) |
| **External entry point** | 1 — `func_038000` called from `system_core` main loop |
| **Compilation unit** | `chunk_038000` (Bank 03, `?BANK 03`) |

This chunk implements the **overworld player interaction layer** — everything
that happens when the player presses a button on the field (outside menus,
battles, and cutscenes). It contains three major functional areas:

1. **Overworld Input Handler** — button dispatch gate
2. **Radar Map Screen** — Start button minimap overlay
3. **Item Use System** — Y button item dispatcher + 41 item handlers

---

## 2. Functional Areas & Size Breakdown

| Area | Address Range | Size | % | Parts | Doc |
|------|---------------|------|---|-------|-----|
| Overworld Input Handler | `$038000`–`$03808E` | 191 B | 2.3% | 1 | [overworld-input.md](overworld-input.md) |
| Radar Map Screen | `$0380BF`–`$03840F` | 849 B | 10.2% | 7 | [overworld-input.md](overworld-input.md) |
| Item Dispatcher | `$038410`–`$0384BE` | 175 B | 2.1% | 3 | [item-use-system.md](item-use-system.md) |
| Item Handlers (code + strings) | `$0384BF`–`$039FB1` | 6,899 B | 82.5% | 39 | [item-use-system.md](item-use-system.md) |
| Item Utilities | `$039FB2`–`$03A0A7` | 246 B | 2.9% | 3 | [item-use-system.md](item-use-system.md) |

---

## 3. Proposed Code Splits

The chunk should be split into **three logical files**, minimizing cross-
references between them:

### Split A: `overworld_input_handler.asm`

**Contains:** The main button dispatcher (`func_038000` only).

| Current Part | Proposed Name |
|-------------|---------------|
| `func_038000` | `OverworldInputHandler` |

**Cross-references OUT:**
- `JSR` to `RadarScreenSetup` (Split B)
- `JSR` to `RadarBorderAnimate` (Split B)
- `JMP` to `ItemUseDispatch` (Split C)
- `JSL` to external: `IsMusicPlaying`, `VBlankWait`, `OpenInventoryScreen`, etc.

**Cross-references IN:**
- `JSL` from `system_core` (1 external caller)

**Rationale:** This is the sole entry point into the chunk. It's a clean
dispatch gate with no data and no internal callers. Separating it makes
the entry contract clear.

### Split B: `radar_map_screen.asm`

**Contains:** All radar/map screen code and data.

| Current Part | Proposed Name |
|-------------|---------------|
| `sub_0380BF` | `RadarScreenSetup` |
| `sub_038259` | `RadarBorderAnimate` |
| `sub_03827C` | `RadarPlotSceneMarkers` |
| `sub_03830E` | `RadarPlotActors` |
| `sub_03832F` | `RadarPlotFriendlyActor` |
| `sub_038379` | `RadarPlotEnemyActor` |
| `word_0383D6` | `RadarBorderTileTable` |

**Cross-references OUT:**
- `JSL` to external: `VBlankWait`, `ClearVramBuffer`, `TestEventFlag`, `TestFlag`

**Cross-references IN:**
- `JSR` from `OverworldInputHandler` (Split A only — 2 calls)

**Rationale:** The radar system is completely self-contained. No item handlers
or utilities reference it. Only the input handler calls into it. This is the
cleanest split boundary.

### Split C: `item_use_system.asm`

**Contains:** Item dispatcher, all handlers, all embedded strings, and shared
utilities.

| Current Part | Proposed Name |
|-------------|---------------|
| `sub_038410` | `ItemUseDispatch` |
| `sub_03842F` | `ItemUseEpilogue` |
| `table_03843F` | `ItemHandlerJumpTable` |
| `func_0384BF`–`func_039FB1` | `UseItem_*` (see full table below) |
| `sub_039FB2` | `RemoveEquippedItem` |
| `func_039FCA` | `FluteMusicActorController` |
| `sub_03A0A0` | `SetPlayerTransition` |

**Cross-references OUT:**
- `JSL` to external: `UpdateFrameDialogue`, `IsMusicPlaying`, various COP handlers
- `JSL` to `chunk_03BAE1`: `func_03E1D6` (music actor), `func_03EF97` (plate exchange)

**Cross-references IN:**
- `JMP` from `OverworldInputHandler` (Split A only — 1 call)

**Rationale:** The item handlers form a tightly coupled web: the dispatch
table points to all 41 handlers, the flute controller dispatches to 3
callbacks, many handlers share utility routines (`RemoveEquippedItem`,
`SetPlayerTransition`) and even share string data. Splitting handlers apart
would create dozens of cross-references with no benefit.

### Cross-Reference Summary

```
                  ┌──────────────────────────┐
                  │  system_core (external)   │
                  └──────────┬───────────────┘
                             │ JSL (1 call)
                             ▼
              ┌─────────────────────────────────┐
              │  Split A: overworld_input_handler│
              │  (OverworldInputHandler)         │
              └──┬──────────────────┬───────────┘
         JSR (2) │                  │ JMP (1)
                 ▼                  ▼
  ┌──────────────────────┐  ┌───────────────────────┐
  │ Split B: radar_map   │  │ Split C: item_use     │
  │  (7 pieces)          │  │  (44 pieces)          │
  │  Self-contained      │  │  Self-contained       │
  └──────────────────────┘  └───────────────────────┘
         ↕ 0 calls              ↕ 0 calls
```

**Total cross-calls between splits: 3** (all from A → B/C, none between B ↔ C)

---

## 4. Complete Name Mapping

### Overworld Input Handler (Split A)

| Address | Current Name | Proposed Name |
|---------|-------------|---------------|
| `$038000` | `func_038000` | `OverworldInputHandler` |

### Radar Map Screen (Split B)

| Address | Current Name | Proposed Name |
|---------|-------------|---------------|
| `$0380BF` | `sub_0380BF` | `RadarScreenSetup` |
| `$038259` | `sub_038259` | `RadarBorderAnimate` |
| `$03827C` | `sub_03827C` | `RadarPlotSceneMarkers` |
| `$03830E` | `sub_03830E` | `RadarPlotActors` |
| `$03832F` | `sub_03832F` | `RadarPlotFriendlyActor` |
| `$038379` | `sub_038379` | `RadarPlotEnemyActor` |
| `$0383D6` | `word_0383D6` | `RadarBorderTileTable` |

### Item Use System (Split C)

#### Infrastructure

| Address | Current Name | Proposed Name |
|---------|-------------|---------------|
| `$038410` | `sub_038410` | `ItemUseDispatch` |
| `$03842F` | `sub_03842F` | `ItemUseEpilogue` |
| `$03843F` | `table_03843F` | `ItemHandlerJumpTable` |

#### Item Handlers

| Address | Current Name | Proposed Name | Item |
|---------|-------------|---------------|------|
| `$0384BF` | `func_0384BF` | `UseItem_None` | *(no item equipped)* |
| `$0384D5` | `func_0384D5` | `UseItem_RedJewel` | Red Jewel |
| `$0385C2` | `func_0385C2` | `UseItem_PrisonKey` | Prison Key |
| `$038691` | `func_038691` | `UseItem_IncaStatueA` | Inca Statue A |
| `$0386DD` | `func_0386DD` | `UseItem_IncaStatueA_CheckAlt` | *(cont.)* |
| `$0387A7` | `func_0387A7` | `UseItem_IncaStatueB` | Inca Statue B |
| `$0387F3` | `func_0387F3` | `UseItem_IncaStatueB_CheckAlt` | *(cont.)* |
| `$03881D` | `func_03881D` | `UseItem_IncanMelody` | Incan Melody |
| `$03888A` | `func_03888A` | `UseItem_Herb` | Herb |
| `$038917` | `func_038917` | `UseItem_DiamondBlock` | Diamond Block |
| `$038971` | `func_038971` | `UseItem_DiamondBlock_Place` | *(cont.)* |
| `$03899A` | `func_03899A` | `UseItem_WindFlute` | Flute (Wind Melody) |
| `$038A16` | `func_038A16` | `UseItem_WindFlute_Effect` | *(callback)* |
| `$038BA4` | `func_038BA4` | `UseItem_LolaMelody` | Lola's Melody |
| `$038C35` | `func_038C35` | `UseItem_LolaMelody_Effect` | *(callback)* |
| `$038D67` | `func_038D67` | `UseItem_SmokedMeat` | Smoked Meat |
| `$038E15` | `func_038E15` | `UseItem_MineKeyA` | Mine Key A |
| `$038E96` | `func_038E96` | `UseItem_MineKeyB` | Mine Key B |
| `$038F17` | `func_038F17` | `UseItem_MemoryMelody` | Memory Melody |
| `$038F6F` | `func_038F6F` | `UseItem_MemoryMelody_Effect` | *(callback)* |
| `$038FF3` | `func_038FF3` | `UseItem_CrystalBall` | Crystal Ball |
| `$0390CE` | `func_0390CE` | `UseItem_ElevatorKey` | Elevator Key |
| `$039144` | `func_039144` | `UseItem_SeasidePalaceKey` | Seaside Palace Key |
| `$03921A` | `func_03921A` | `UseItem_PurificationStone` | Purification Stone |
| `$039299` | `func_039299` | `UseItem_StatueOfHope` | Statue of Hope |
| `$03932B` | `func_03932B` | `UseItem_RamaStatue` | Rama Statue |
| `$0393A1` | `func_0393A1` | `UseItem_MagicPowder` | Magic Powder |
| `$039427` | `func_039427` | `UseItem_Journal` | Lance's Journal |
| `$03950C` | `func_03950C` | `UseItem_LanceLetter` | Lance's Letter |
| `$03966A` | `func_03966A` | `UseItem_LillyNecklace` | Lilly's Necklace |
| `$039691` | `func_039691` | `UseItem_Will` | Will (testament) |
| `$03983D` | `func_03983D` | `UseItem_Teapot` | Teapot |
| `$0398B2` | `func_0398B2` | `UseItem_MushroomWater` | Mushroom Water |
| `$0398DA` | `func_0398DA` | `UseItem_MushroomWater_Alt` | *(scene $A5 cont.)* |
| `$03995C` | `func_03995C` | `UseItem_PrizeMoney` | Prize Money |
| `$03997F` | `func_03997F` | `UseItem_BlackGlasses` | Black Glasses |
| `$0399CD` | `func_0399CD` | `UseItem_GorgonFlower` | Gorgon Flower |
| `$039AA0` | `func_039AA0` | `UseItem_HieroglyphPlate` | Hieroglyph Plates |
| `$039AAD` | `func_039AAD` | `UseItem_HieroglyphPlate_Detail` | *(puzzle logic)* |
| `$039CAF` | `func_039CAF` | `UseItem_Aura` | Aura (transformation) |
| `$039D09` | `func_039D09` | `UseItem_BillLolaLetter` | Letter (Bill & Lola) |
| `$039E15` | `func_039E15` | `UseItem_FatherJournal` | Father's Journal |
| `$039F30` | `func_039F30` | `UseItem_CrystalRing` | Crystal Ring |
| `$039F5D` | `func_039F5D` | `UseItem_Apple` | Apple |
| `$039FB1` | `func_039FB1` | `UseItem_Unused` | *(stub)* |

#### Utilities

| Address | Current Name | Proposed Name |
|---------|-------------|---------------|
| `$039FB2` | `sub_039FB2` | `RemoveEquippedItem` |
| `$039FCA` | `func_039FCA` | `FluteMusicActorController` |
| `$03A0A0` | `sub_03A0A0` | `SetPlayerTransition` |

---

## 5. Key Architectural Insights

### 5.1 The Stacked-Return Epilogue Pattern

The item dispatcher uses a clever `PEA` trick: before jumping to a handler,
it pushes `ItemUseEpilogue - 1` onto the stack. Every handler ends with a
plain `RTS`, which pops this address and "returns" to the epilogue. This
avoids every handler needing to explicitly call the epilogue, saving code
space across 41 handlers.

### 5.2 Flute Actor State Machine

The three melody instruments (IDs 08, 09, 0D) all share a single actor
controller (`FluteMusicActorController`) that manages the full playback
cutscene: lock player → spawn music → wait for completion → unlock →
dispatch to instrument-specific callback. The callback index (0/1/2) is
stored in the actor's `$0020` field at spawn time.

### 5.3 Handler Continuations

Several items span multiple `blocks.json` parts because they have fall-
through logic:
- Inca Statue A: `func_038691` → `func_0386DD` (two position checks)
- Inca Statue B: `func_0387A7` → `func_0387F3` (two position checks)
- Diamond Block: `func_038917` → `func_038971` (check → place)
- Mushroom Water: `func_0398B2` → `func_0398DA` (two scene checks)
- Hieroglyph Plates: `func_039AA0` → `func_039AAD` (entry → puzzle)

These are not independent routines — they are contiguous code that falls
through. A split should keep each continuation pair together.

### 5.4 Scene-Gating Pattern

Nearly every placement/key item follows the same structure:
```
1. LDA $sceneCurrent / CMP #$xxxx / BNE fail
2. COP [BranchIfPlayerInAbsTiles] (x1, y1, x2, y2, &success)
3. fail: COP [PrintWideString] (&fail_msg) / RTS
4. success: COP [PrintWideString] (&ok_msg) / COP [RemoveItem] / COP [SetFlagByte] / RTS
```

This could potentially be refactored into a generic handler with a data
table, but the current code embeds all logic inline.

---

## 6. Detailed Documentation Index

| Document | Contents |
|----------|----------|
| [overworld-input.md](overworld-input.md) | Input handler, radar screen, all 8 radar pieces |
| [item-use-system.md](item-use-system.md) | Dispatcher, all 41 item handlers, 3 utilities |

---

## 7. `blocks.json` Part Count

The chunk currently has **54 parts** in `blocks.json`. The proposed split
maps them to 3 logical files:

| Split | Parts | Files |
|-------|-------|-------|
| A: `overworld_input_handler` | 1 | 1 |
| B: `radar_map_screen` | 7 | 1 |
| C: `item_use_system` | 46 | 1 |
| **Total** | **54** | **3** |
