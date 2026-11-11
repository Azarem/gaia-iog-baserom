# IT-14 apply: docs part 1, scene and table names

Mechanism: D (docs by hand, `StrReplace`). No spec, no dry-run, no gate run. `npm run extract:lt` was run once before the edits so that every fact was re-derived from the live `extracted/` text. Finish check: `npm run names -- --check` -> `Names check: OK (3510 names)`.

Counts: applied 40 rows (one row per doc line group), disputed 1 (row 6c, `text-and-menus.md`), skipped 1 (row 1n, rename-map rows, by instruction), blocked 0. Same-fault rows the prompt did not list: 5 (marked `+`: 2i, 2k, 3e, 6e, 6f).

Code re-read before editing (all in `extracted/`):
- `system/engine/scene_script.asm`: `SceneCmd_ConfigDisplay` (1154), `SceneCmd_LoadPalette` (648), `SceneCmd_LoadMetatileSets` (689), `SceneCmd_LoadLayerMaps` (776), `SpcMusicLoadCmd` (1296), `SceneCmd_Label` (279), `SkipScriptCommands` (1589), `CheckSourceCacheHit` (1700), `RebuildCollisionLayer` / `FillCollisionFromLayer0` / `OverlayCollisionFromLayer1` (2099-2171), `BuildMetatileFlagTable` note (2041), the `!collisionFlagTableL0 06AA` / `L1 06AC` mnemonics (116-117).
- `tables/scene_meta.asm` block note (opcode table with operands and counts), `scene_meta_0006`.
- `tables/scene_chest_table.asm`, `system/engine/warps_interaction.asm` (`PlaceOpenedChestTiles` 157, `HandleChestInteraction` 229), `system/engine/radar_map_screen.asm` (`RadarPlotSceneMarkers` 257-320).
- `tables/dialog_template_table.asm` (block note and the 22 templates).
- `system/music_pointer_array.asm`, `system/engine/hdma_dma_spc.asm` (`LoadMusicFromTransitionState` 440-470).
- `system/inventory/inventory_mgmt.asm` (`GiveItem_StoreInSlot` 210, `GiveItem_InventoryFull` 230), `tables/item_pickup_text_table.asm`, `system/engine/ConsoleStringRenderer.asm` (includes, `ConsoleCmd_PrintEquipIcons` 995), `actors/player/player_character.asm` and `attack_ability_system.asm` (`?INCLUDE` lists, Projectile* actors).

## Status table

Line numbers are the lines after the edit.

| id | file:line | status | note |
|---|---|---|---|
| 1a | `docs/structs-reference.md:362` | APPLIED | `table_018000.asm` -> `display_preset_table.asm` |
| 1b | `docs/structs-reference.md:833` | APPLIED | `via table_018000` -> `via display_preset_table` |
| 1c | `docs/structs-reference.md:841` | APPLIED | `Files: table_018000.asm` -> `display_preset_table.asm` |
| 1d | `docs/structs-reference.md:843` | APPLIED | `blocks.json: table_018000` -> `display_preset_table` (block `db-us/blocks.json` "tables.display_preset_table", 98304-98868) |
| 1e | `docs/bank01-data-tables.md:46` | APPLIED | "Current name" line now `display_preset_table` (the "Proposed name" line under it is the same word; the whole Current/Proposed header format of this file is left for IT-49) |
| 1f | `docs/bank01-data-tables.md:660` | APPLIED | the A07-17 "662" is the `itemget_table_01FD24` line, not `table_018000`: "Current name" -> `item_pickup_text_table` |
| 1g | `docs/code/bank0D-scene-meta.md:105` | APPLIED | `display_preset_table` (Bank $02, `table_018000`) -> `display_preset_table` (Bank $01); `scene_script.asm` says `?BANK 01` for the table, the old text said bank 02 |
| 1h | `docs/code/bank02/scene-script.md:99` | APPLIED | `Read table_018000 entry` -> `Read the display_preset_table record` |
| 1i | `docs/code/bank02/scene-script.md:215` | APPLIED | name only |
| 1j | `docs/code/bank02/scene-script.md:733` | APPLIED | name only (the sentence's `$06EE` "display flags" / `$06EF` "system flags" is left, see outside scope) |
| 1k | `docs/code/bank02/scene-script.md:739` | APPLIED | name only |
| 1l | `docs/code/bank02/scene-script.md:758` | APPLIED | `table_018000.asm` -> `display_preset_table.asm` |
| 1m | `docs/code/bank02/scene-script.md:1095` | APPLIED | link text and target `../../../extracted/tables/display_preset_table.asm` |
| 1n | `docs/bank01-data-tables.md:686, 710` | SKIPPED (by instruction) | rename-map rows `table_018000` / `itemget_table_01FD24` keep the old identifiers (the 688 / 712 of the prompt) |
| 2a | `docs/code/bank0D-scene-meta.md:161` | APPLIED | music sentence: the transfer runs when `group` EQUALS `musicRoomGroup` (code: `LDA $musicRoomGroup; CMP $06F4; BEQ load; RTS`). The old operand order was also wrong: the code stores the FIRST byte in `musicParentActor` ($06F2) and the SECOND in $06F4 (group). `$11 <track> <group> <source>`; `scene_meta_0006` has `music < #1C, #00 ...>` and `music < #1B, #01 ...>`. Adds who writes / clears `musicRoomGroup` (three `gs*` actor files; `ClearSceneState` after `SceneScriptMain`), the group counts (225 / 5 / 4) and the play / stop write |
| 2b | `docs/code/bank0D-scene-meta.md:86-88` | APPLIED | rows `$04`, `$05`, `$06`: palette colours / metatile sets / layer map |
| 2c | `docs/code/bank0D-scene-meta.md:126-129` | APPLIED | `$04 <start> <end> <dest>` (each a colour index doubled to a byte offset), window `[start, end)` to palette buffer `$7F:0A00 + dest x 2`; `dest = $10` also copies the first loaded colour to colour 0 (code 648-690). The old `count` and `cgram_offset` were wrong |
| 2d | `docs/code/bank0D-scene-meta.md:134-137` | APPLIED | `$05 <start> <end> <dest> <layers> <source>`; operands in units of $40 (`XBA` + `LSR` x2 on a clean byte); window to `$7E:2000` / `$7E:2800` + dest x $40; `layers` bit 0 / bit 1, both allowed; cache-hit layer skipped; `BuildMetatileFlagTable` per layer (code 689-770). The old text said the layer byte selects one layer |
| 2e | `docs/code/bank0D-scene-meta.md:142-145` | APPLIED | `$06 <layers> <source>`; bit 0 = map at `$7E:A000`, bit 1 = `$7E:C000`; `scene_meta` uses `$01` (225) and `$02` (158); source = width byte, height byte, then compressed map; both bits = layer 1 gets a copy of layer 0; no bit = `DmaLowVramTileset`. The old "attributes are rebuilt" belongs to `$05` |
| 2f | `docs/code/bank02/scene-script.md:101-103` | APPLIED | opcode table rows `$04` / `$05` / `$06`, same facts |
| 2g | `docs/code/bank02/scene-script.md:108` | APPLIED | row `$11`: "(in `spc_transfer.asm`)" removed (`SpcMusicLoadCmd` is in `scene_script.asm`; `rg` finds it nowhere else), group-equals-`musicRoomGroup` rule added |
| 2h | `docs/code/bank02/scene-script.md:126, 127, 131` | APPLIED | operand-size table: `$04` start, end, dest colour; `$05` start, end, dest, layer flags; `$11` "Track ID + cache key" -> track id (`musicParentActor`) + group ($06F4) |
| 2i | `docs/code/bank02/scene-script.md:207-209` (+) | APPLIED | address table descriptions of `$04` / `$05` / `$06` carried the same wrong facts ("single-layer tilemap", "tilemap data for both BG layers") |
| 2j | `docs/code/bank02/scene-script.md:233-235` (A01 row 11) | APPLIED | `$06AA` is the correct ADDRESS but not a "cached source pointer": it is `collisionFlagTableL0`, the page address (bank $7F) of the per-metatile flag table written by `BuildMetatileFlagTable`. `FillCollisionFromLayer0` reads the metatile number from `$7E:A000 + cell` and stores the flag byte at `$7F:C000 + cell`; `$06AC` / layer 1 likewise with zero bytes skipped. Rows 233 (`RebuildCollisionLayer`), 234, 235 rewritten. The source-cache slots are `$066C`-`$0689` (`CheckSourceCacheHit`) |
| 2k | `docs/code/bank02/scene-script.md:1058, 1070, 1074` (+) | APPLIED | same fact in the `RebuildCollisionLayer` variable row and the `FillCollisionFromLayer0` / `OverlayCollisionFromLayer1` sections (the "Starts indexing at `$0080` in the source pointer table" was also wrong: `LDX $0080` loads the start index, word `$C000`) |
| 3a | `docs/bank01-data-tables.md:21` | APPLIED | TOC row: "Per-scene barrier/chest placement data" -> "Per-scene treasure chest records" |
| 3b | `docs/bank01-data-tables.md:199-213` | APPLIED | description, record table and usage rewritten from `scene_chest_table.asm`: 255-word pointer table, 39 scenes / 46 records, `chest_list_none`, byte 0 bit 7 ends a list (old table put the sentinel on byte 3), Y = bottom row, byte 2 = item id / 0 flag-only, byte 3 = flag bits 0-6 and fanfare bit 7. Old text had "barrier tiles" and "tile index for barriers", "binary_01AFA6" and "transition markers" for the radar (it plots unopened chests). Readers: `PlaceOpenedChestTiles`, `HandleChestInteraction`, `RadarPlotSceneMarkers` |
| 3c | `docs/bank01-data-tables.md:690` | APPLIED | rename-map rationale "Per-scene barrier/chest placement data" -> "Per-scene treasure chest records" (old identifier column kept) |
| 3d | `docs/code/README.md:241` | APPLIED | "Per-scene barrier/chest placement" -> "Per-scene treasure chest records" |
| 3e | `docs/code/bank02/game-systems.md:500, 509, 525, 527, 879` (+) | APPLIED | same fault: "boulder/barrier state", "barrier tiles", "restore barriers", "chest/barrier entry table", heading "Chest and Barrier Tables" -> open chests / chest records / "Chest Tables" (no inbound anchor links exist). Row 509 now says top row at (X, Y-1), bottom row at (X, Y) as in `PlaceOpenedChestTiles` |
| 4a | `docs/bank01-data-tables.md:319-324` | APPLIED | templates re-read from `dialog_template_table.asm`: `$00`-`$07` speaker colour + SFX presets (`[SEP:ii,cccc]` = BGR555 palette-buffer colour, `[PAL:4]`, `[SFX:ss]`; `$07` pink/red, no SFX); `$08`-`$10` box presets (`[DLG:col,row]`, `[SIZ:w,h]`, 13 columns x 1-4 rows at row 6 / row $11, `$10` duplicates `$0F`); `$11` "Where do you go?" (the old text put this on `$12`); `$12`-`$15` silent variants of `$00`, `$01`, `$02`, `$04` (the old text said `$13`-`$15` and `$00`-`$04`). "Dark Space transformations" and "palette shifts" removed |
| 4b | `docs/bank01-data-tables.md:24` | APPLIED | TOC row: "Dialog box/screen-effect templates" -> "Dialog speaker colour/sound presets and box presets" |
| 4c | `docs/bank01-data-tables.md:699` | APPLIED | rename-map rationale "Dialog box/FX template strings" -> "Dialog speaker colour/sound and box template strings" |
| 4d | `docs/code/README.md:244` | APPLIED | "Reusable dialog box templates" -> "Dialog speaker colour/sound and box presets" (README had no "screen-effect" text; the finding's words are in `bank01-data-tables.md`) |
| 5 | `docs/bank01-data-tables.md:339-341, 371` (A01 row 15) | APPLIED | `LoadMusicFromTransitionState` reads entry `(ID - 1) x 3` (`music_pointer_array-3 + 3n`), so the stored id is entry + 1 (`music < #1C, ... @bgm_lively_city_by_the_sea >` = entry `$1B`). Column header "ID" -> "Entry", a sentence states the +1 rule, "scene music IDs" -> "music IDs". The Usage line said "`musicTransitionState x 3` ... into the DMA transfer registers"; the code loads DP `$46`-`$48` and the `srcCacheMusic` shadow ($0687) and calls `SpcBlockTransfer` (IPL byte-stream upload, not DMA) |
| 6a | `docs/code/bank03/field-input-and-items.md:401` | APPLIED | `itemget_table_01FD24.dialog_item_found` -> `item_pickup_text_table.dialog_item_found` (matches `LDY #$&item_pickup_text_table.dialog_item_found` in `GiveItem_StoreInSlot`) |
| 6b | `docs/code/bank02/game-systems.md:570` | APPLIED | `itemget_table_01FD24` "Item name wide strings" -> `item_pickup_text_table`: chest dialogue strings used by `HandleChestInteraction` (`dialog_chest_locked`, `dialog_chest_empty`, `dialog_item_chest`) and the item-name strings indexed by item id |
| 6c | `docs/code/bank03/text-and-menus.md:345-346` | DISPUTED | finding: rename to `item_pickup_text_table`. Live code: `ConsoleStringRenderer.asm` includes only `shared_word_table`; `rg item_pickup_text_table extracted/` finds no use in the console renderer, and `ConsoleCmd_PrintEquipIcons` (995) computes icon tiles from the item index (`$01E0` / `$02E0` + 2 x index) with no table read. The renamed bullet "item data for equipment icons" would state a false dependency, so the new name was NOT written; the unsupported bullet was removed instead. Veto if you want it kept as a rename |
| 6d | `docs/code/bank02/player-character.md:93` | APPLIED | `?INCLUDE 'table_179000'` -> `'spriteset_aura'` (`attack_ability_system.asm:69`) |
| 6e | `docs/code/bank02/player-character.md:99` (+) | APPLIED | `?INCLUDE 'table_17D000' - ranged weapon spritemap` -> `'spriteset_darkgaia_projectile' - Dark Gaia projectile spritemap` (`player_character.asm:51`; the `Projectile*` actors use it) |
| 6f | `docs/code/bank02/player-character.md:377` (+) | APPLIED | `Spritemap table_17D000` -> `spriteset_darkgaia_projectile` |
| 6g | `docs/code/bank02/README.md:169` | APPLIED | `table_17D000.asm` -> `spriteset_darkgaia_projectile.asm` |

## Before / after of the long edits

The one-line renames are in the table. Long rewrites are in `git diff -- docs` (10 files). Key before texts:

- `bank0D-scene-meta.md` music: "The `room_group` byte gates loading - if the current `musicRoomGroup` already matches, the transfer is skipped entirely ... The `parent_actor` byte controls whether playback starts" -> `$11 <track> <group> <source>`; transfer runs only when `group` equals `musicRoomGroup`.
- `scene-script.md:234`: "Reloads layer 0 map strip from the cached source pointer at `$06AA` into `$7F:2000`." -> "Fills the collision layer (`$7F:C000`) from the layer 0 map (`$7E:A000`): each cell's metatile number indexes the flag table whose page address is in `$06AA` (`collisionFlagTableL0`, bank `$7F`)."
- `bank01-data-tables.md` chest record table: byte 3 "Event flag ID (bit 7 = end-of-list sentinel)" -> byte 0 bit 7 ends the list; byte 3 bits 0-6 flag, bit 7 fanfare.

## Dry-run, spec, gate

No spec and no dry-run (D iteration). No gate (docs only). `npm run names -- --check`: OK (3510 names). `git status --short -- docs`: only the 10 doc files above are modified by this iteration.

## Outside scope (not edited; for IT-16 / IT-49 / IT-51)

- `docs/bank01-data-tables.md` section 1 (about 54-65): the byte table for `display-preset` ("0 BG mode and tile size flags, 1 tilemap base addresses ...") does not match `SceneCmd_ConfigDisplay` (+0 TM/TMW, +1 TS/TSW, +2 CGWSEL, +3 CGADSUB, +4 layer flags, +5 layer priority/size, +6 BGMODE, +7 scroll/HUD flags). Same for the field names in `docs/structs-reference.md` 362-830 (`tilemapAddr`, `bgMode` at +6 etc.).
- `docs/bank01-data-tables.md` Current/Proposed name headers: nearly every section still lists the retired identifier as "Current name" (e.g. `table_01ADA8`, `templates_01CA95`, `music_array_01CBA6`); also rows 7 and others show type `&Binary` where `db-us/blocks.json` has `&chest-entry` for `scene_chest_table`.
- `docs/code/bank02/scene-script.md`: the prose sections of `SceneCmd_LoadPalette` (543), `SceneCmd_LoadMetatileSets` (572), `SceneCmd_LoadLayerMaps` (603) still say "single-layer tilemap", "row copy `$0A20` -> `$0A00`", "tilemap data for both BG layers"; `BuildMetatileFlagTable` section (997-1013: "source pointer arrays at `$06AA,X` / `$06AE,X`", "attr dest"), `RebuildCollisionLayer` prose (1028 "refreshes both map layers from cached source pointers"), the intro lines 88 and 242 ("refresh both map layers from cached source pointers"), line 733 (`$06EE` "display flags" / `$06EF` "system flags"; live names `layerPriorityFlag` / `scrollModeFlags`), line 60 (`SpcMusicLoadCmd` in "spc_transfer (part 1)"), line 150 (`$10` operand "flags": the code skips that byte, $00 in all 56), `FindCurrentScene` described as the live routine (the rebuilt tree uses the indexed version).
- `docs/code/bank0D-scene-meta.md`: the `branch` example comments (about 405-407: "if flag $4C set, jump to label $07" with operand `#01`), the `$10` operand name `flags`, the section on `Original Layout` (describes `SkipScriptCommands` as a label-opcode scan; the extracted version reads a count byte and compares nested `$15` counts), `SceneLoadPatch.patch.asm` path (the file is `baserom/scene-load/SceneMetaLoad.patch.asm`).
- `docs/code/bank02/player-character.md` include tree (about 85-99): `table_01D9A7`, `table_01D9BF`, `table_0EE000`, `table_178000` are retired names too; the live includes of `attack_ability_system.asm` are `ability_damage_tables`, `spriteset_dark_friar`, `spriteset_pickups_effects`, `spriteset_aura`.
- `docs/code/bank02/game-systems.md` 498-510 and 879-890: `table_01ADA8` (retired name of `scene_chest_table`) still used throughout; 531-532 `HandleChestInteraction` guard text ("A button", `$06EE`) differs from the code (D-pad up, `layerPriorityFlag`).
- `extracted/tables/scene_chest_table.asm` / `warps_interaction.asm` note line 61 ("The earlier 'closed door/barrier' reading is not supported by the code") is history narration (IT-12 / IT-47 class).
- `EquippedIcon.patch.asm:474` stale `?INCLUDE 'table_018000'` stays BLOCKED for the user (U4), unchanged by this iteration.
