# IT-15 apply: docs part 2, `hpToHeal`, nicknames, WRAM rows

Mechanism: D (docs by hand, `StrReplace`). No spec, no dry-run, no gate run. `npm run extract:lt` was run once before the edits so that every fact was re-derived from the live `extracted/` text and `db-us/mnemonics.json`. Finish check: `npm run names -- --check` -> `Names check: OK (3510 names)`.

Counts: applied 36 rows, disputed 0, skipped 1 (row 6g, by instruction), blocked 0, checked with no edit 4 (rows 1h, 2d, 3f, 3g). Same-fault rows the prompt did not list are marked `+` (14 of the 36, one of them partial: row 1a, line 422).

Code re-read before editing (all in `extracted/`):
- `system/engine/system_core.asm`: `UpdateHUD` / `UpdateHUD_Active` (HP recovery 410-428; stat change detection 430-458; enemy bar 460-483), `UpdateFrameFull` (347-370), `NmiHandler` gate (`musicTransitionState`: `BEQ` skips on 0, `BMI` skips on `$FFFF`, so only a positive value runs `UpdateFrameFull`), `SystemInit` plate-slot clear (208-214), mnemonics `hpToHeal` `$0B22`, `hieroglyphSlots` `$0B28`.
- `actors/boss_clear_reward_handler.asm` (`BossRewardGrant`: `hpToHeal := playerMaxHp - playerHp`), `actors/reward_actors.asm` (`hpToHeal` 42-44), `actors/jeweler_gem.asm` (`JewelerRewardHp`: `hpToHeal = 1`, "not an HP-bar flash"), `actors/hidden_red_jewel.asm` and the five actors named in row 6 (`COP [SetInteractHandler]`; `db-us/copdef.json:176` id 192).
- `system/engine/slider_glide.asm` (`IsPlayerSliderSpriteBank`, note on bank `$8F`), `tables/body_table.asm` (rows 4 and 5 share bank `$8F`; `SetPlayerSpriteDirect #04` selects `spriteset_will_abilities`).
- `system/engine/scene_script.asm` (`SceneCmd_LoadPalette`, `SceneCmd_LoadMetatileSets`, `SceneCmd_LoadCharTiles`, graphics command at 299: `gfxSrcStart` / `gfxSrcEnd` / `gfxDestPage` / `gfxLayerFlags`, all word stores under `REP #$20`), `db-us/mnemonics.json` keys 1636-1642.
- `system/engine/flag_helpers.asm` (`ClearAllWramFlags` and its caller list), `functions/game_over_sequence.asm` (inline clear), `system/world_map/WorldMapController.asm`.
- `system/inventory/inventory_mgmt.asm`, `inventory_menu.asm:70`, `cop_handlers_inventory.asm:85` (`inventorySlots` = 16 bytes, `$0AB4`-`$0AC3`).
- `system/engine/save_system.asm` (saved range `$0A00`-`$0BFB`), `system/inventory/item_use_system.asm` (plate placement 1537-1572), `pyramid/puzzle_room/pyCD_puzzle.asm`.
- `functions/EnemyDropSystem.asm`, `functions/SpawnFieldRevealEffect.asm` (row 5).

## Status table

Line numbers are the lines after the edit.

| id | file:line | status | note |
|---|---|---|---|
| 1a | `docs/code/bank00/system-core.md:421-422` | APPLIED | "**Damage flash** — when `$0B22 ≠ 0`, every 8 frames ... animates DEF display `$0ACE` toward max `$0ACA`" -> "**HP recovery**": when `hpToHeal` (`$0B22`) is nonzero, the frame counter `$0036` is a multiple of 8 and `playerStateByte` bit 1 is clear, decrement `hpToHeal`, then clear it if `playerHp` (`$0ACE`) equals `playerMaxHp` (`$0ACA`) or else `playerHp` + 1 and sound `#0D`. `$0ACE` is current HP, not DEF. Line 422 said "DEF/HP/gems change"; the code compares HP, max HP and gems (+ same fault) |
| 1b | `docs/code/bank00/system-core.md:433` | APPLIED | algorithm step 3 rewritten from the code: skip conditions (game over bit, 8-frame boundary, `hpToHeal` = 0), `hpToHeal` - 1, then clear or `playerHp` + 1 and sound. The old text had "cap at playerMaxHp", which is the clear-on-equal test |
| 1c | `docs/code/bank00/system-core.md:446` | APPLIED (+) | `$0036` role "flash timing" -> "HP recovery step every 8 frames" |
| 1d | `docs/code/bank00/system-core.md:457` | APPLIED | "Damage flash timer / R" -> `hpToHeal`: HP recovery counter, `UpdateHUD` reads and writes only the low byte (`SEP #$20` before the `LDA` / `DEC` / `STA`), R/W |
| 1e | `docs/code/bank00/system-core.md:465` | APPLIED (+) | cross-reference "Damage tick sound" -> "HP recovery tick sound" |
| 1f | `docs/code/bank00/system-core.md:522-523` | APPLIED | one row "`$0B22`-`$0B32` Damage/save metadata" split into `$0B22` `hpToHeal` (reader `UpdateHUD`, writers item and reward actors) and `$0B28`-`$0B33` `hieroglyphSlots` (see 4b) |
| 1g | `docs/code/bank00/data-tables-memory.md:381` | APPLIED | "Damage flash timer / HUD (every 8 frames)" -> `hpToHeal`: HP recovery counter, `UpdateHUD` (one step every 8 frames) |
| 1h | `docs/wram-memory-map.md:381` | NO EDIT | `hpToHeal` row already correct ("Non-zero triggers HP recovery animation every 8 frames") |
| 1i | `docs/code/bank00/actors-player-rewards.md:58` | APPLIED | the step said "Update $0B22 (HP recovery delta = playerMaxHp − playerHp)". The arithmetic is right (`BossRewardGrant`: `LDA playerMaxHp; SEC; SBC playerHp; STA hpToHeal`); the wording is now "hpToHeal ($0B22) := playerMaxHp − playerHp (UpdateHUD then refills one HP per 8 frames)" |
| 1j | `docs/code/bank00/actors-player-rewards.md:73` | APPLIED | "HP bar display delta" -> `hpToHeal`: HP still to recover (the handler sets it to max HP − current HP) |
| 1k | `docs/code/bank00/actors-combat-interaction.md:134` | APPLIED (+) | "HP bar delta for UI refresh" -> `hpToHeal`: HP still to recover (set to new max HP − current HP); the sentence at line 126 already says `hpToHeal` |
| 1l | `docs/code/bank08-native-dao-pyramid-actors.md:417` | APPLIED (+) | jeweler tier `#EB`: "damage flash" -> "`$hpToHeal = 1` (`UpdateHUD` adds one current HP)"; `JewelerRewardHp` and the actor note say "not an HP-bar flash" |
| 2a | `docs/code/bank00/stair-climb-system.md:8, 33, 117, 127, 288` | APPLIED | `will_alt` (5 places; the finding's "about line 5" is line 8) -> bank `$8F` = the bank of `spriteset_will_abilities`; line 117 adds that `spriteset_transform_poses` (body table row `$05`, `sE6_gaia` only) is also bank `$8F`, so the test does not tell the two apart (as in the `slider_glide.asm` note); the algorithm comment reads "CC = bank $8F (spriteset_will_abilities), CS = any other bank" |
| 2b | `docs/code/bank00/README.md:740` | APPLIED | `IsPlayerSliderSpriteBank` row: "`will_alt` sprite bank `$8F`" -> sprite bank `$8F` (bank of `spriteset_will_abilities`) |
| 2c | `docs/code/bank00/data-tables-memory.md:250` | APPLIED | "`$8F` = `will_alt`" -> "`$8F` = bank of `spriteset_will_abilities`" |
| 2d | `docs/` search for `will_alt`, `ability_fx`, `shadow_mode`, `WillAlt` | CHECKED | no other hit in `docs/`, `extracted/` or `db-us/*.json` |
| 3a | `docs/wram-memory-map.md:207-210` | APPLIED | the row `$0664`-`$066A` "gfxLoadParams" (7 bytes, "source pointers, cache flags, layer bits") replaced by four word rows with the live mnemonic names: `gfxSrcStart` `$0664`, `gfxSrcEnd` `$0666`, `gfxDestPage` `$0668`, `gfxLayerFlags` `$066A` (the last is a word, `STA` under `REP #$20`, so the block ends at `$066B`). Operand scaling from the three commands (palette ×2, graphics ×`$200`, metatile sets ×`$40`); `gfxLayerFlags` bit 0 / bit 1 = layer 0 / 1 for the metatile-set and layer-map commands, a source-cache hit clears the bit; VRAM target flags for `SceneCmd_LoadCharTiles` |
| 3b | `docs/wram-memory-map.md:361` | APPLIED | `$0AB4`-`$0AD2` "31 / 16 item words" -> `$0AB4`-`$0AC3`, 16 bytes, one item ID per byte, no per-slot flags, some code reads a slot as a word and masks it with `$00FF`; the old range ran over the rows below it (`inventoryEquippedIndex` at `$0AC4`, `playerMaxHp` at `$0ACA`) |
| 3c | `docs/wram-memory-map.md:362` | APPLIED (+) | row name `inventoryEquippedIdx` -> the live mnemonic `inventoryEquippedIndex` |
| 3d | `docs/wram-memory-map.md:350` | APPLIED | `wramFlags` "Scene-local scratch flags ... Cleared by `ClearAllWramFlags` at scene boundaries" -> dungeon kill and puzzle flags indexed by enemy number; zeroed by `ClearAllWramFlags` (called when the world map is entered and by `st68_kara` and `sp58_red_eye`) and inline by `game_over_sequence` on a real game over; no reset at ordinary scene changes was found |
| 3e | `docs/code/bank00/event-flags.md:197, 377` | APPLIED (+) | same fault: "Invoked at scene boundaries or puzzle resets" -> the three callers plus the inline clear in `game_over_sequence`; "WRAM flags are scratch" -> zeroed only by those callers |
| 3f | `docs/wram-memory-map.md` `deathFlag` | NO EDIT (clean) | `rg deathFlag docs/` has no hit; the name stays in `mnemonics.json:9` (`$0200`, the depth-sort bucket page used by `sprite_composition`), which is Part 2 (IT-41 and later) |
| 3g | `docs/wram-memory-map.md:142, 625` `collisionLayerBase` | NO EDIT (A01 row 8, dropped) | not in `mnemonics.json`; the extractor does not substitute DP operands, so it is a doc-only name for `$0080`-`$0082`, as row 8 says; the `scene_script.asm:2159` comment uses it the same way |
| 3h | `docs/wram-memory-map.md:382` | APPLIED (+) | row `$0B28`-`$0B32` "11 / saveWarpMetadata / Save and warp state metadata" -> `$0B28`-`$0B33`, 12, `hieroglyphSlots`: six hieroglyph plate slots (words, `$FFFF` = empty), saved with the `$0A00`-`$0BFB` range; users `SystemInit` (clears), `pyCD_puzzle`, `item_use_system` |
| 4a | `docs/code/bank00/system-core.md:36` | APPLIED | "UpdateFrameFull — music handshake from NMI" -> "run by the NMI while the main loop is blocked in the SPC music upload". Derived: `NmiHandler` calls it only when `musicTransitionState` is positive; `LoadMusicFromTransitionState` runs the blocking `SpcBlockTransfer` meanwhile |
| 4b | `docs/code/bank00/system-core.md:371-373, 400, 407` | APPLIED (+) | `UpdateFrameFull` section: the description said "including collision and actor movement ... during music transition handshake (`$06FA ≠ 0`) ... waiting for APU acknowledgment" and "covers ... collision". The code calls `RunThinkers_General_Light`, `RunActors_OverlayOnly`, depth sort, `CameraSmoothScroll` ×2, `ResetHdmaState`, `RunThinkers_Hdma_Light`, `ComposeAllSprites`; the gate is "positive" (0 and `$FFFF` skip it). Rewritten; the `$06FA` variable row and the "Called by" row say positive |
| 4c | `docs/code/bank00/README.md:314` | APPLIED (+) | `UpdateFrameFull` row "Full frame with collision (NMI music handshake)" -> the same fact as 4a |
| 4d | `docs/code/bank00/data-tables-memory.md:344` | APPLIED (+) | `$06FA` row "triggers `UpdateFrameFull` when ≠ 0" -> "while positive (SPC upload in progress; `$FFFF` = finished)" |
| 4e | `docs/code/bank00/data-tables-memory.md:415` | APPLIED | `$0B28`-`$0B32` "11 / Save/warp metadata / System init" -> `$0B28`-`$0B33`, 12, `hieroglyphSlots` (six plate words, `$FFFF` = empty; saved range; users as in 3h). Derived: `SystemInit` writes `$FFFF` to `$0B28`, `$0B2A`, `$0B2C`, `$0B2E`, `$0B30`, `$0B32`; `pyCD_puzzle` and `item_use_system` read and write them (`LDA` / `STA $hieroglyphSlots, Y`); nothing in `extracted/` reads `$0B28`-`$0B32` as save or warp data |
| 4f | `docs/code/bank00/system-core.md:258` | APPLIED (+) | the init-variable table row "Save/warp metadata region / Init context" -> `hieroglyphSlots` |
| 5a | `docs/code/bank00/functions-combat-defeat.md:256` | APPLIED | "Previously misnamed `DarkGemDropSystem` / `EnemyRewardChestSystem`. Enemies do not spawn chests ..." -> "Enemies do **not** spawn chests — they spawn gem or heal pickups (item ids `$83`–`$86` via `GiveItemToPlayer`)." (checked against the `EnemyDropSystem.asm` block note) |
| 5b | `docs/code/bank00/functions-combat-defeat.md:105` | APPLIED (+) | "previously misnamed `EnemyRewardChestRouter`" removed, current fact kept |
| 5c | `docs/code/bank00/functions-combat-defeat.md:171` | APPLIED (+) | "previously named `SpawnItemDropPickup` but contains no item/inventory logic" -> "contains no item/inventory logic whatsoever" (checked against the `SpawnFieldRevealEffect.asm` block note: room-reveal effect) |
| 6a | `docs/code/bank08-native-dao-pyramid-actors.md:124` | APPLIED | `SetOnInteract → code_089B6D` -> `SetInteractHandler → code_089B6D` (`awBF_spirit_guide.asm:34`) |
| 6b | `docs/code/bank08-native-dao-pyramid-actors.md:127` | APPLIED | `awB6_bones` `SetOnInteract` -> `SetInteractHandler` (`awB6_bones.asm:17`) |
| 6c | `docs/code/bank08-native-dao-pyramid-actors.md:193` | APPLIED | `pyCC_entrance_portal` (`pyCC_entrance_portal.asm:23`) |
| 6d | `docs/code/bank08-native-dao-pyramid-actors.md:250` | APPLIED | `jeweler_gem` (`jeweler_gem.asm:55`) |
| 6e | `docs/code/bank0A-dungeon-enemy-actors.md:257` | APPLIED | `ec0E_statue` (`ec0E_statue.asm:18`) |
| 6f | `docs/code/bank00/actors-player-rewards.md:329` | APPLIED | `hidden_red_jewel`: "`SetOnInteract` callback" -> "`SetInteractHandler` callback (`HiddenRedJewelInteract`)" (`hidden_red_jewel.asm:50`) |
| 6g | `docs/cop/families/script_control.md:53, 65, 103` | SKIPPED (by instruction) | labelled legacy alias; the only `SetOnInteract` hits left in `docs/` |
| 7a | `docs/code/bank02/inventory-menu.md:39, 154, 979` | APPLIED (+) | same fault as 3b: "16 item words" / `$0AB4`-`$0AD2` -> 16 byte slots, `$0AB4`-`$0AC3` |

(Rows 1a-1g, 1i-1l, 2a-2c, 3a-3e, 3h, 4a-4f, 5a-5c, 6a-6f and 7a are the 36 APPLIED rows; 1h, 2d, 3f, 3g are no-edit checks and 6g is the skip. No DISPUTED, no BLOCKED.)

## Before / after of the long edits

One-line renames are in the table. `git diff -- docs` has the full text. Key before texts:

- `system-core.md` 421: "**Damage flash** — when `$0B22 ≠ 0`, every 8 frames (`$0036` AND `$07`) animates DEF display `$0ACE` toward max `$0ACA` and plays sound effect via inline COP `PlaySoundCh2 #0D`."
- `system-core.md` 371: "Near-complete single-frame update **including collision and actor movement**, but invoked from **NMI** during **music transition handshake** (`$06FA ≠ 0`). Allows the game simulation to advance while the main CPU thread is blocked waiting for APU acknowledgment."
- `wram-memory-map.md` 207: "`$0664`–`$066A` | 7 | `gfxLoadParams` | Scene graphics loading scratch (source pointers, cache flags, layer bits)".
- `wram-memory-map.md` 347: "**Scene-local scratch flags** — dungeon kill tracking, puzzle state, per-room logic. Cleared by `ClearAllWramFlags` at scene boundaries."

## Dry-run, spec, gate

No spec and no dry-run (D iteration). No gate (docs only). `npm run names -- --check`: OK (3510 names). Files modified by this iteration (12): `docs/wram-memory-map.md`, `docs/code/bank00/{README,actors-combat-interaction,actors-player-rewards,data-tables-memory,event-flags,functions-combat-defeat,stair-climb-system,system-core}.md`, `docs/code/bank02/inventory-menu.md`, `docs/code/bank08-native-dao-pyramid-actors.md`, `docs/code/bank0A-dungeon-enemy-actors.md`.

## Outside scope (not edited; for IT-16 / IT-49 / IT-50 / IT-51)

- `system-core.md` `UpdateHUD`: algorithm step 6 and the "Experience popup" paragraph (about 423 and 436) say the enemy-bar timer `$0AE4` is set to `$001E`; the code sets it to `$3C` (60 frames; the `$19` and `$1E` stores are overwritten). `data-tables-memory.md:380` and `wram-memory-map.md` (`enemyHealthTimer`) repeat "`$001E` frames". The "experience popup" label is also wrong: the trigger is `enemyHpPending` and the script draws the enemy HP bar.
- `system-core.md` `UpdateFrameCounters` (about 470-495): "`$040C` run-window timer (13-frame D-pad run allowance)" and the Variables table; the live code names `$040C` `invincibilityTimer` and describes it as "Decrements the invincibility timer if non-negative". Hit-blink and run-window claims need a code check (IT-50).
- `system-core.md` `UpdateHUD` summary and `bank00/README.md:315` list "DEF, STR" among the HUD values; `UpdateHUD` compares and redraws HP, max HP, gems and the enemy bar only.
- `stair-climb-system.md` `IsPlayerSliderSpriteBank` algorithm (about 124-127) writes `LDX $player_actor`; the code does `PHX; TYX` with `Y` = the player actor passed by the trigger.
- `docs/code/bank00/nmi-handler.md` (68, 81, 91, 179, 198-199) and `docs/cop-commands-reference.md` still describe the `UpdateFrameFull` gate as "`$06FA ≠ 0`" / "music crossfade"; same fault as 4b-4d.
- `docs/code/bank00/README.md:420` `ClearAllWramFlags` "Zero $0A80–$0A9E (16 words)": the block is `$0A80`-`$0A9F` (32 bytes, 16 words).
- `bank02/inventory-menu.md` other lines about "item words" (141, 322 "Swaps low bytes of two ...") were not re-read; the live note says the swap is an 8-bit byte swap.
- `docs/code/bank03/field-input-and-items.md:360` says `playerMaxHp` is "8-bit; only overflow from `$7F` stores `$55`" while `reward_actors.asm` says the clamp value is `$0255`: the two texts differ and were not reconciled.
