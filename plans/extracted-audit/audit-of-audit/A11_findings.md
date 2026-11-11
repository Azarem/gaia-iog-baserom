# A11 findings: docs reconciliation

Step A11 of the audit of the audit. Nothing was edited in this step: no doc, no names, no notes, no gate run, no `npm run ingest:all`. Docs corrections are step F05. Every behavioural claim below is static (no Mesen2 ROM or save state exists). Tags: **VERIFIED** = I read the live doc line and the cited code line in this step. **REPORTED** = the claim comes from a frozen ledger or the report and I did not re-read the code (or the doc line) in this step.

Status words used in the tables:

| Status | Meaning |
|---|---|
| DONE | the stale text is gone and the corrected text is in the live doc (line given) |
| OPEN | the stale text is still in the live doc |
| PARTIAL | the main claim is corrected, a residue is left (named in the row) |
| SUPERSEDED | the doc row no longer exists, or a later row replaces it |
| UNCHECKED | not re-read in this step; stays REPORTED (listed again in section 3) |

Doc line numbers in the ledgers have drifted. Every status below was decided by searching for the stale phrase and the corrected phrase, not by trusting the ledger line number. Live line numbers are given.

## 1. Scope and files read

- `plans/extracted-audit/audit-of-audit/PLAN.md`, `report.md` (section 5 docs backlog, N-3, N-6, N-7, N-9, N-10, Appendix A).
- `plans/extracted-audit/results/*` docs paragraphs and `renames/I001-I020_rename-proposals.md` .. `renames/I061-I072_*` doc rows; `renames/apply-*_summary.md` docs sections.
- Live docs (read or searched): `docs/wram-memory-map.md`, `docs/structs-reference.md`, `docs/bank01-data-tables.md`, `docs/actor-organization-analysis.md`, `docs/unused-mode7-boss-analysis.md`, `docs/cop/families/*.md`, `docs/cop/cop-commands-reference.md`, `docs/code/README.md`, `docs/code/bank00/*.md`, `docs/code/bank02/*.md`, `docs/code/bank03/*.md`, `docs/code/bank04..bank0D*.md`.
- Live code and notes used as evidence: `extracted/system/engine/combat_collision.asm`, `system_core.asm`, `scene_script.asm`, `warps_interaction.asm`, `attack_ability_system.asm`, `actor_pool.asm`, `cop_handlers_hdma_dma.asm`, `cop_handlers_player_query.asm`, `camera_scroll.asm`, `layer1_scroll_actors.asm`, `extracted/system/math_lookup_tables.asm`, `extracted/tables/*.asm` (display_preset_table, body_table, forced_walk_pan_table, shared_word_table, item_pickup_text_table, enemy_clear_reward_table, dialog_dictionaries, dialog_template_table, scene_warps), `extracted/thinkers/sine_hdma_slow_wave.asm`, `extracted/functions/EscortFollowPathTracker.asm`, `db-us/mnemonics.json`, `db-us/names/bank00.json`.
- `gaia-core/docs/notes-and-comments.md` (whole), `gaia-core/src/index.ts` and `src/merge.ts`, `src/names-merge.ts` (only for the `--check` / `--dry-run` options).
- `c:/Work/gaia-knowledge`: `rg` over `corpus/`, `curated/`, `manifest.json`, `AGENTS.md`.

## 2. Findings

### 2.1 Ledger doc corrections versus the live docs (table T1)

Class column: 3 = stale after rename, 10 = retired nickname, 11 = wrong flag / register / hardware meaning, 2 = WaitByte n+1, 13 = button vocabulary, `-` = wrong description with no class number.

| ID | Ledger id | Live doc and line | What the ledger asks for | Status | Evidence | Tag | Class |
|---|---|---|---|---|---|---|---|
| D01 | R-I001-9 | `docs/wram-memory-map.md:207` | `$0664-$066A` is not one `gfxLoadParams` block; four fields gfxSrcStart, gfxSrcEnd, gfxDestPage, gfxLayerFlags | OPEN | row still says `gfxLoadParams`; `db-us/mnemonics.json:41-44` has the four names | VERIFIED | 3 |
| D02 | R-I001-10 | `docs/structs-reference.md:812-843`, `:362` | display-preset field map (+0 TM/TMW, +1 TS/TSW, +2 CGWSEL, +3 CGADSUB, +4 layer flags, +5 layerPriorityFlag, +6 BGMODE, +7 scroll/HUD flags) | OPEN | doc still has the old field map and `table_018000`; live note `extracted/tables/display_preset_table.asm:3` | VERIFIED | 3 |
| D03 | R-I001-11 | `docs/code/bank02/scene-script.md:234,1003,1070` | `$06AA` is the 1-byte flag table pointer, not a cached source pointer | OPEN | the three lines still say "cached source pointer at `$06AA`" / "attr dest from `$06AA,X`"; code meaning REPORTED | VERIFIED (doc) / REPORTED (code) | -
| D04 | R-I001-1 | `docs/code/bank02/scene-script.md:232,539,585,600,995-1003` | `BuildMetatileFlagTable` lifts a tilemap-word bit into a 1-byte flag table | OPEN | name is applied, description still "Rebuilds tilemap attribute bytes for a 4xN tile region" (`:232`) | VERIFIED (doc) | 3 |
| D05 | R-I001-13 | `docs/code/bank03/movement-and-collision.md:250,269` | `ApplyHitDamageToVictim` is the player-hits-actor routine, not "enemy to player contact" | OPEN | `:250` "Enemy attacks player (`ApplyHitDamageToVictim`)", `:269` "process enemy->player contact"; code header `extracted/system/engine/combat_collision.asm:36-40`: "uses the PLAYER's strength and reduces the overlapped actor's HP" | VERIFIED | 11 |
| D06 | R-I001-16 | `docs/code/bank03/movement-and-collision.md:251-254` | formula: `rawDamage = max(1, totalStr - victim DEF)`, `netDamage = rawDamage + characterForm`, `totalStr = playerStr + bonus + climbStateData` | OPEN | doc says `rawDamage = max(1, enemyAtk - totalStr)`; code `combat_collision.asm:38-40` and `:683,749,766-780`. The following section `:311-318` is DONE (see D07) | VERIFIED | 11 |
| D07 | R-I025-6 | `docs/code/bank03/movement-and-collision.md:311-318` | `$09E0` = Will ability byte, `$09E2` = Freedan table byte | PARTIAL | `:316-318` correct, but `:314` still writes `previousDamage($09E2)` and `climbStateData($09E0)`; `:315` "previousDamage" omitted when `$08 == $1000`. Code: `combat_collision.asm:39`, `attack_ability_system.asm:1647,1671` | VERIFIED | 3 |
| D08 | R-I001-15 | `docs/bank01-data-tables.md` music_pointer_array section (~332-345) | music ids off by one | UNCHECKED | not re-read | REPORTED | - |
| D09 | R-I001-17 | `docs/wram-memory-map.md` actor flag `$0080` / `$0400` rows | resolve after OQ-8 | UNCHECKED | depends on OQ-8, which this step does not answer | REPORTED | 11 |
| D10 | R-I001-18, R-I001-25 | `docs/code/bank00/data-tables-memory.md:39,125,158` | `slope_curve_table` is not a sine/cosine HUD table; first 64 bytes are the default slope acceleration and deceleration curves | OPEN | the three lines say "Sine/cosine lookup data (HUD pointer init in `SystemInit`)"; live note `extracted/system/math_lookup_tables.asm:9` "is not a flag table: its first 64 bytes are the default slope acceleration and deceleration curves" | VERIFIED | - |
| D11 | R-I001-30 | `docs/wram-memory-map.md` `$0D52-$0D5E` descriptions | wrong descriptions | SUPERSEDED | no `$0D52`..`$0D5E` row exists in the live file | VERIFIED (absence) | - |
| D12 | R-I001-31 | `docs/wram-memory-map.md:358` | `inventorySlots` is 16 bytes (`$0AB4-$0AC3`), not 31 bytes / "16 item words" | OPEN | the row says size 31 and "16 item words"; code stride is REPORTED | VERIFIED (doc) / REPORTED (code) | 11 |
| D13 | R-I001-45 | `docs/cop/families/palette.md:25` | "bundle ID forced to 0" is wrong | OPEN | `[36]` is still described "with bundle ID forced to 0"; code REPORTED | VERIFIED (doc) / REPORTED (code) | - |
| D14 | R-I001-45 (hdma) / R-I009-45 | `docs/cop/families/hdma_dma.md:9,22,70,147` | `QueueDma`: not "linear DMA", `#0F` is `$210F` BG2HOFS (B-bus index), not CGRAM | OPEN | doc still has "linear DMA" and `#0F` as CGRAM/palette; code `extracted/system/engine/cop_handlers_hdma_dma.asm:3,55,73` (`QueueDma` is a direct-table HDMA channel; `#0F` is BG2HOFS) | VERIFIED | 11 |
| D15 | R-I001-45 (hdma, ctd.) | `docs/cop/families/hdma_dma.md:171-172,207` | `QueueDma ... #12` and "B-bus register index" | DONE | the corrected text is at these lines | VERIFIED | - |
| D16 | R-I001-50 | `docs/code/bank03/text-and-menus.md:303-307,322,329` | NewLine / DoubleNewLine rows | DONE | corrected rows present. The `$09A0` line-start addition from the ledger is not present (`rg 09A0` has no hit) | VERIFIED | - |
| D17 | R-I001-51 | `docs/cop/families/input.md:9,29,36` | `$0001` is not a button; bit 0 is the raw source | DONE | corrected text at `:29,36` | VERIFIED | 13 |
| D18 | R-I001-51 (ctd.) | `docs/cop/cop-commands-reference.md` joypad rows | same vocabulary | UNCHECKED | not re-read | REPORTED | 13 |
| D19 | R-I001-54, R-I021-R7, R-I032-5 | `docs/wram-memory-map.md`, `docs/code/bank03/sprite-rendering.md:30,46` | `deathFlag` is not a flag; bucket array | DONE | `deathFlag` has no hit in `docs/`; sprite-rendering describes the bucket array. The name `deathFlag` is still in `db-us/mnemonics.json:9` (AP-21, user-owned) | VERIFIED | 3 |
| D20 | R-I001-58 | `docs/code/bank03/sprite-rendering.md:53,62` | priority direction, `ClearActorRenderList` per scene | UNCHECKED | not re-read | REPORTED | 11 |
| D21 | R-I001-60 | `docs/code/bank03/camera-scrolling.md`, `docs/code/bank03/nmi-handler.md:177` | `SpriteVramDma` renamed `Bg3TilemapVramDma` and described as a BG3 tilemap DMA | PARTIAL | no stale name in camera-scrolling or README; `nmi-handler.md:177` still says "Sprite VRAM DMA ... queued sprite tile transfers" | VERIFIED | 3 |
| D22 | R-I001-66 | `docs/code/bank00/*` follow sine table wording | follow does not use the sine table | DONE | no "follow ... sine" text left in `docs/code/bank00` | VERIFIED (absence) | - |
| D23 | R-I001-67 | `docs/cop/families/audio.md` | "spawned by scene transition" | DONE | only a legitimate sentence remains (`:132`) | VERIFIED | - |
| D24 | R-I001-67 / N-8 | `docs/wram-memory-map.md:248` | `$06F2` stores the track id, not a parent actor id | OPEN | row says `musicParentActor` "Music parent actor ID"; code `scene_script.asm:1297-1298` (`STA $musicParentActor` right after "Read music parent actor ID from script") and `warps_interaction.asm:52` (restores scene music). The mnemonic is still `musicParentActor` (`db-us/mnemonics.json:121`, AP-21) | VERIFIED | 3 |
| D25 | R-I001-69, R-I022-6, R-I045 | `docs/cop/families/force_move.md:9,19`, `player_sprite.md:20,238`, `sprite_staging.md:21`, `docs/cop/cop-commands-reference.md:829`, `docs/code/bank00/utility-tiles-animation.md:294` | `$2C/$2E` are delta-chain head pointers, not "frame durations" | OPEN | all six places still say "frame durations"; code `extracted/system/engine/actor_pool.asm:98,103` (chain head pointers from `move_chain_table`) | VERIFIED | 11 |
| D26 | R-I001-70 | `docs/cop/families/sine_hdma.md`, `gravity.md`, `camera.md` operand descriptions | corrected operands | UNCHECKED | not re-read | REPORTED | - |
| D27 | R-I001-71 | `docs/cop/families/vram_memory.md:111` | "Source bank forced to `$7F`" | OPEN | the sentence is still present at `:111`; code REPORTED | VERIFIED (doc) / REPORTED (code) | - |
| D28 | R-I001-77 | `docs/code/bank00/system-core.md:36` | `UpdateFrameFull` "music handshake from NMI" | OPEN | line 36 still has the phrase; code REPORTED | VERIFIED (doc) / REPORTED (code) | - |
| D29 | R-I001-77 (dialog) | `docs/cop/families/dialog.md:119` | "dialogue mode `$2000`, masks inventory input `$0F00`, saves/restores status bar bit `$0800`" | OPEN | line present; code REPORTED | VERIFIED (doc) / REPORTED (code) | 11 |
| D30 | R-I001-78 | `docs/cop/families/movement.md:34` | `MoveToward` operands: two bytes, the second is speed | OPEN | `copdef.json:36` shows two Byte operands; doc text REPORTED against the ledger | REPORTED | - |
| D31 | R-I001-86 | `docs/code/bank02/game-systems.md`, `proximity.md:140` | `SwapEventBlockTiles` removed; box order minX,minY,maxX,maxY | DONE | no stale name; `proximity.md:140` has the order | VERIFIED | 3 |
| D32 | R-I001-93 | `docs/code/bank00/actors-player-rewards.md:329`, `bank08-native-dao-pyramid-actors.md:124,127,193`, `bank0A-dungeon-enemy-actors.md` (~257) | `SetOnInteract` is not a copdef name; copdef id 192 is `SetInteractHandler` | OPEN | `copdef.json:176` has `SetInteractHandler`; `docs/cop/families/script_control.md:53,65,103` documents `SetOnInteract` as a legacy alias (acceptable there, not elsewhere) | VERIFIED | 10 |
| D33 | R-I001-94 | `docs/wram-memory-map.md:347` | `wramFlags` "Cleared by ClearAllWramFlags at scene boundaries" is wrong | OPEN | `ClearAllWramFlags` callers: st68_kara, WorldMapController, sp58_red_eye, flag_helpers (`docs/code/bank00/event-flags.md:191,377,393` documents it correctly as clearing `$0A80` only) | VERIFIED | 11 |
| D34 | apply-I001-I020 s.5 | `docs/code/bank02/game-systems.md:509,525,527` (and `docs/bank01-data-tables.md`, see D100) | `PlaceOpenedChestTiles`: chests, not barriers | OPEN | "barrier/chest" wording still present | VERIFIED | 10 |
| D35 | R-I021-4 | `docs/code/bank03/actor-thinker-runtime.md:282-283` | bit-11 `_Light` routines are not "cutscene overlay" / "cutscene deferred" | OPEN | both phrases still present; code REPORTED (I021) | VERIFIED (doc) / REPORTED (code) | 11 |
| D36 | R-I021-5, R-I021-6 | compressed palette wording | corrected | DONE | no stale phrase left | VERIFIED (absence) | - |
| D37 | R-I022-5 | `EnableNmiOnly` | retired name | DONE | no hit in `docs/` | VERIFIED (absence) | 3 |
| D38 | R-I023-4 | `docs/cop/families/player_sprite.md:31`, `cop-commands-reference.md:763` | `RunPlayerAnim` alias (like `$89`) | DONE | corrected text present | VERIFIED | - |
| D39 | R-I025-5 | `docs/code/bank00/system-core.md:477` | `$040C` is a run-window timer, not an invincibility timer | DONE | `:477` corrected; wram-memory-map and data-tables-memory rows no longer say invincibility | VERIFIED | 11 |
| D40 | R-I025-5 (README) | `docs/code/bank00/README.md:316` | same | OPEN | line 316 still says "Decrement invincibility timer" | VERIFIED | 11 |
| D41 | R-I025-7 | `NullActorScriptStub` rows | removed | DONE | no hit | VERIFIED (absence) | 3 |
| D42 | R-I026-1 | `docs/code/bank00/functions-player-npc.md:190`, `bank06:87`, `README.md:704` | `FlickerParentActor` flips the parent's bit | DONE | label and wording present | VERIFIED | - |
| D43 | R-I027-1 | `docs/code/bank02/attack-ability-system.md:78` | `DarkFriarTrailNorthInit` | DONE | present | VERIFIED | 3 |
| D44 | R-I027-2, R-I028-4 | oneshot / backdrop-fade names | no retired `oneshot_palette_flash_1B/1C` | DONE | none in `docs/`; the renamed files exist in `extracted/thinkers` | VERIFIED | 3 |
| D45 | R-I028-1 | `docs/bank01-data-tables.md:566`, `inventory-menu.md:104,698,715` | `non_discardable_item_bits` | DONE | present | VERIFIED | 3 |
| D46 | R-I028-2 | `docs/code/bank02/inventory-menu.md:93-95` | `StatusAbilityRow*` | DONE | present | VERIFIED | 3 |
| D47 | R-I029-5 | `docs/code/bank00/thinkers-palette.md`, `docs/unused-mode7-boss-analysis.md:477,736,788` | does not spawn `oneshot_palette_flash_19`; flash wording | DONE | corrected; possible residue "Warm interior" at `thinkers-palette.md:105` | VERIFIED | - |
| D48 | R-I029 (ramps) | `DiagRamp*` names in docs | no stale names | DONE | no hit | VERIFIED (absence) | 3 |
| D49 | R-I030-1 | `docs/code/bank0A-dungeon-enemy-actors.md:92,185,538,584,603`, `bank0C-scene-spawn-tables-comet.md:685,722,895,1035` | `SetPlayerGameOverFlag` wording: post-boss combat skip, not game over | DONE (wording) | wording says "combat skip after boss defeat" at all places; the name is still `SetPlayerGameOverFlag` in `names/bank0A.json` because the rename depends on OQ-I030-2 | VERIFIED | 11 |
| D50 | R-I030-3(a) | `docs/code/bank02/tile-collision.md:77-78,512-514` | `MapCellDown` / `MapCellUp` direction | UNCHECKED | text describes "one row down/up"; code not re-read | REPORTED | 11 |
| D51 | R-I031 (ambient) | `docs/code/bank0C-scene-spawn-tables-comet.md:432`, `docs/code/bank00/thinkers-palette.md:56`, `docs/structs-reference.md:1171` | "water shimmer, lava glow, torch flicker" is a guess | OPEN | guess still present | VERIFIED (doc) / REPORTED (code) | - |
| D52 | R-I031/I032 | `docs/code/README.md:204` ("18 thinkers"), `docs/code/bank0C-scene-spawn-tables-comet.md:441` ("Gold Ship, Babel Tower") | `sine_hdma_slow_wave` is spawned in scenes `$32` and `$E9/$EA` only, 2 spawn entries | OPEN | `extracted/thinkers/sine_hdma_slow_wave.asm:3`; `extracted/tables/scene_thinkers.asm:433,724` | VERIFIED | - |
| D53 | R-I031 (bank05) | `docs/code/bank05-midgame-actors.md:496` | "not a brightness gradient" | DONE | corrected | VERIFIED | - |
| D54 | R-I032-? | `docs/wram-memory-map.md:285` | `slopeCurvePtrs` "(ascending/descending)" | OPEN | text still present; code REPORTED | VERIFIED (doc) / REPORTED (code) | - |
| D55 | R-I033-4(a,b) | `docs/code/bank0C-scene-spawn-tables-comet.md:445,464`, `thinkers-palette.md`, `bank00/README.md:134,136,494,495` | scene names and descriptions for palette thinkers | PARTIAL | `bank0C:445,464` still describe `palette_parent_child` and `flag_gated_palette_warm` with the old wording ("Parent-child palette linking", "Flag-conditional warm palette (South Cape)"); thinkers-palette.md rewritten | VERIFIED (doc) / REPORTED (code) | - |
| D56 | R-I033-4(c..e) | `docs/code/bank02/player-movement.md`, `bank06` | "diagonal down-left", "64px grid", "actor class bits" | DONE | none left | VERIFIED (absence) | - |
| D57 | R-I034-4 | `docs/code/bank02/inventory-overlay.md`, `docs/wram-memory-map.md` (`invBackupSystem`) | `DrainActorQueue`, backup system names | DONE | no hit in `docs/`; `inventory-overlay.md` not re-read in full | VERIFIED (absence) | 3 |
| D58 | R-I035 | `docs/bank01-data-tables.md:377-392` | `parallax_scroll_table` header bytes and "`$0D`-`$1A` are terminators" | OPEN | the section description was updated, the bullet lines were not | VERIFIED (doc) / REPORTED (code) | - |
| D59 | R-I035 | `docs/code/README.md:246` | row says "HDMA scroll configs" | PARTIAL | wording not aligned with "band templates" | VERIFIED | - |
| D60 | R-I035 | `docs/code/bank03/thinkers-system.md:158`, `hdma_dma.md:172` | `inventory_dma_setup` "7 DMA writes" | DONE | no hit | VERIFIED (absence) | - |
| D61 | R-I036 | `docs/code/bank0C:329`, `actors-infrastructure:270,305`, `bank01-data-tables.md:706`, `bank00/README.md:131-132,481-482` | jump-launcher / ramp wording | DONE | corrected (`bank01:706` "Jump-launcher arc Y-delta tables"; infra "not tile slope physics") | VERIFIED | - |
| D62 | R-I037-5(a,b) | `docs/code/bank00/actors-combat-interaction.md:190` | corrected | DONE | present | VERIFIED | - |
| D63 | R-I037-5(c) | `docs/cop/families/player_query.md:45-46` | operand order west/center/east, north/south/center | OPEN | doc has `W,E,Here` and `N,S,Here` in the table but its own body (`:142,179`) and `docs/cop/README.md:204-205` have the right order; code header of `cop_handlers_player_query.asm` plus `copdef.json:44-45` | VERIFIED | - |
| D64 | R-I038-4(b,c) | `docs/code/bank02/player-movement.md:679-683`, `bank08:249` | West ramps, no stale text | DONE | present | VERIFIED | - |
| D65 | R-I041-5 | `docs/code/bank03/mode7-and-cutscenes.md:54,99`, `docs/unused-mode7-boss-analysis.md:477,619` | `M7SEL=$80`: transparent outside | DONE | corrected | VERIFIED | - |
| D66 | R-I041-5 | `docs/code/bank00/functions-combat-defeat.md:349`, `README.md:671`, `sprite-rendering.md:247` | damage-number actor, no "hit trail", no "weapon trail" | DONE | corrected / no hit | VERIFIED | - |
| D67 | R-I042-5 | `docs/code/bank00/actors-player-rewards.md:368`, `docs/code/bank03/field-input-and-items.md:392` | floor_button is a hit-triggered switch; item heal 5 HP, `SpawnItemSparkleEffect` | DONE | corrected | VERIFIED | - |
| D68 | R-I043 | `docs/cop/families/movement.md:81` | `EnemyPositionSnap`, `#FF` | DONE | corrected | VERIFIED | - |
| D69 | R-I044-1 | `docs/code/bank00/thinkers-palette.md`, `README.md`, `bank0C` | `incan_ruins_transform_palette` renamed `gold_ship_wreck_palette` | DONE | no old name in `docs/`; `extracted/thinkers/gold_ship_wreck_palette.asm` exists | VERIFIED | 3 |
| D70 | R-I044-3 | `docs/code/bank00/functions-camera-motion.md:203-228` | `ApplyOrbitalOffsetXY` field layout (+0 X angle, +1 Y angle, +2 X diameter, +3 Y diameter), 3 call sites | UNCHECKED | the grep for the old addresses failed in the shell; not re-read | REPORTED | - |
| D71 | R-I045 | `docs/code/bank02/player-movement.md:17,68,106` | `$AA` corrected | PARTIAL | `:17,68,106` corrected; `:116,138` still say "direction not suppressed" | VERIFIED | 11 |
| D72 | R-I045 | `docs/code/bank00/README.md:722,869`, `oam_attribs.md:199` | "15+ refs" / weather wording | DONE | no hit | VERIFIED (absence) | - |
| D73 | R-I047 | `docs/cop/families/actor_spawn.md:639`, `actors-player-rewards.md:133` | `SpawnLastRel` is a documented alias | DONE | kept on purpose | VERIFIED | - |
| D74 | R-I049 | `docs/wram-memory-map.md:224`, `bank0B` section 4.11, `dialog.md` | "no separate dead zone", dark gem weighted spawn | DONE | `wram-memory-map.md:224` corrected | VERIFIED | - |
| D75 | R-I050 | `docs/code/bank04-npc-actors.md:402` | 13 NPCs use `NpcRandomWanderAI` | DONE | `:402` corrected. `bank00/README.md:703,870` still say "~12" (minor, consistent enough) | VERIFIED | - |
| D76 | R-I050 | `docs/code/bank03/field-input-and-items.md:360-364` | "cap at `$55`" | DONE | text now says "only overflow from `$7F` stores `$55`" | VERIFIED | 11 |
| D77 | R-I051-2 | `docs/code/bank00/actors-combat-interaction.md:382` | `$06C8` is `forcedScrollOverride`, not "sub-pixel overflow pending in Layer1ParallaxRatio" | OPEN | code `camera_scroll.asm:38,65`, `layer1_scroll_actors.asm:115` (no reader found; OQ-I051-2 stays open) | VERIFIED | 11 |
| D78 | R-I052-? | `docs/code/bank00/data-tables-memory.md:113`, `functions-player-npc.md:224`, `README.md:705` | "9 XY waypoint pairs ring buffer", `array_00C943` | OPEN | `extracted/functions/EscortFollowPathTracker.asm:7`: 9 entries written, only 8 read; the table is the facing delta table | VERIFIED | 3 |
| D79 | R-I052-? | `docs/code/bank00/actors-player-rewards.md:133,155`, `README.md:192,619` | `SpawnSparkleEffect` at `$C418` | OPEN | the name is absent from `extracted/` and `db-us`; `$C418` = 50200 = `SpawnImpactSparkAndDie` (`names/bank00.json:448`); the item sparkle is `SpawnItemSparkleEffect` (56579) | VERIFIED | 10 |
| D80 | R-I053 | `docs/code/bank08-native-dao-pyramid-actors.md:258,307`, `wram-memory-map.md:374,378` | Will-to-Shadow wording, `sceneSaveData`, `hpToHeal` | DONE | corrected | VERIFIED | - |
| D81 | R-I053-7 | `docs/code/bank0C-scene-spawn-tables-comet.md:850-865,1013` | smooth follow "aims once, flies straight", not homing | PARTIAL | `bank0C:854` still says "Spawns smooth_follow ... for player-tracking homing"; bank0A, bank0B and actors-combat-interaction are clean; code REPORTED | VERIFIED (doc) / REPORTED (code) | - |
| D82 | R-I054 | `docs/code/bank00/data-tables-memory.md:565,590`, `actor-organization-analysis.md:230`, `actors-player-rewards.md:111` | `EnemyDropSystem` wording | DONE | no stale phrase | VERIFIED (absence) | - |
| D83 | R-I055 | `docs/structs-reference.md:1205` | 7-byte sprite-part | DONE | corrected | VERIFIED | - |
| D84 | R-I056 | `docs/structs-reference.md:1220-1239`, `bank08:282-307` | diary entry layout, `Transform_WillToShadow` | DONE | corrected | VERIFIED | - |
| D85 | R-I057 | `docs/wram-memory-map.md` section 2.9 remap table, `bank0B` diary rows | corrected | UNCHECKED | not individually verified | REPORTED | - |
| D86 | R-I058..I060 | `docs/code/bank03/radar-and-world-map.md:31,224,355`, `docs/structs-reference.md:644-660` | route array wording | DONE | corrected | VERIFIED | - |
| D87 | D-S5160-4 | `docs/cop/families/wait.md:40`, `radar-and-world-map.md:169,203`, `functions-camera-motion.md:129` | `WaitByte(n)` waits n+1 ticks | DONE | corrected at all three | VERIFIED | 2 |
| D88 | R-I063 | `docs/bank01-data-tables.md:33,600,709`, `docs/code/README.md:253` | `shared_word_table` is shared strings, not only item prefixes | OPEN | live note `extracted/tables/shared_word_table.asm:1`; docs still say "item name prefix components" | VERIFIED | - |
| D89 | R-I064 | `docs/bank01-data-tables.md:17,99`, `docs/code/README.md:237` | `forced_walk_pan_table` is camera pan step lists | OPEN | `forced_walk_pan_table.asm:1`; docs still say "animation frame sequences". `docs/cop/families/camera.md` is clean | VERIFIED | - |
| D90 | R-I065 | `docs/bank01-data-tables.md:24,323-326` | `dialog_template_table` has 22 templates; ranges shifted by one; mostly speaker colour templates | OPEN | `dialog_template_table.asm:1`; docs still say "Screen-effect presets / Dark Space / size presets" | VERIFIED | - |
| D91 | R-I065 / N-2 | `docs/code/bank0D-scene-meta.md:161` | if the music room group already matches, the load is NOT skipped; equal means the load path | OPEN | doc says "the transfer is skipped". Code `scene_script.asm:1303-1306` (`LDA $musicRoomGroup; CMP $06F4; BEQ loc_028B88; RTS`) | VERIFIED | 11 |
| D92 | R-I065 | `docs/code/bank02/scene-script.md:99,101-104` | `SpcMusicLoadCmd` is in `scene_script.asm`, not `spc_transfer.asm` | OPEN | `:104` says "in spc_transfer.asm"; the label is at `scene_script.asm:1296` | VERIFIED | - |
| D93 | R-I067 | `docs/bank01-data-tables.md:36,561,679,712`, `docs/code/README.md:256` | `item_pickup_text_table` = 64 item names plus 5 wrappers, not "item acquisition dialog" | OPEN | `item_pickup_text_table.asm:1`; docs still say "item acquisition dialog" | VERIFIED | - |
| D94 | R-I068 | `docs/bank01-data-tables.md:82`, `docs/structs-reference.md:1275-1340`, `docs/code/bank02/game-systems.md:820-880` | second warp list is forced-walk warps, all vertical; not "stair-warp" | OPEN (game-systems.md REPORTED) | `extracted/tables/scene_warps.asm:1`; `game-systems.md:820-880` not re-read | VERIFIED (bank01, structs) / REPORTED (game-systems) | - |
| D95 | R-I068 | `docs/code/bank0D-scene-meta.md:105`, `bank02/scene-script.md:99,215,733,739,758,1095` | `table_018000` retired; the block is `display_preset_table` | OPEN | all hits present, plus `structs-reference.md:362,833,841,843` and `bank01-data-tables.md:46,688` (24 lines in all, see section 2.3) | VERIFIED | 3 |
| D96 | R-I068 | `docs/code/bank02/scene-script.md` opcode `$04`/`$05`/`$06`/`$14` descriptions | handler names were renamed ("Single-layer tilemap DMA", "Skip 1 script byte") | OPEN | descriptions are still the old ones | VERIFIED (doc) | 3 |
| D97 | R-I069 | `docs/bank01-data-tables.md:494-498`, `docs/structs-reference.md:1104-1108` | body-table row names ("Will (alternate)", "Ability FX", "Will FX", "Shadow FX", "Shadow (mode)", `table_*`) | OPEN | live names `extracted/tables/body_table.asm:27-35`, e.g. `spriteset_will_abilities ($8F)` at `:31` | VERIFIED | 10 |
| D98 | R-I070 | `docs/bank01-data-tables.md:118-122` | `enemy_clear_reward_table` tiers select the stat; any scene with a nonzero entry; not "Dark Space room" | OPEN | `enemy_clear_reward_table.asm:1` | VERIFIED | - |
| D99 | R-I070 | `docs/bank01-data-tables.md:654` | dictionaries "256 per dictionary" | OPEN | `dialog_dictionaries.asm:1`: dictionary A has 256, B has 200. The counts are not recounted here | VERIFIED (doc) / REPORTED (count) | - |
| D100 | R-I071 | `docs/bank01-data-tables.md:21,199,203,205,208,692`, `docs/code/README.md:241`, `docs/code/bank02/game-systems.md:509,525,527` | `scene_chest_table` is chests, not barriers | OPEN | legitimate "barrier" hits (`ec0E_barrier`, Kress barriers, `MarkSolidAbs barrier`) excluded | VERIFIED | 10 |
| D101 | R-I072 | `docs/bank01-data-tables.md:564,582,585,673` and the section 18c heading | item menu table descriptions | OPEN | lines present; ledger code claim REPORTED | VERIFIED (doc) / REPORTED (code) | - |
| D102 | R-I073 (report s.5) | `docs/code/bank00/system-core.md:421,457,522`, `data-tables-memory.md:381` | `$0B22` is `hpToHeal`, not a "Damage flash" timer | OPEN | the four places say "Damage flash" / "Damage flash timer"; the same file's `:433`, `wram-memory-map.md:378`, `field-input-and-items.md:234,365` and `ram_map.txt:238` say hpToHeal; code `system_core.asm:382-383,416-423` ($0ACE current HP, $0ACA max HP) | VERIFIED | 11 |
| D103 | N-10 | `docs/code/bank08-native-dao-pyramid-actors.md:417` | "damage flash" for item `#EB` | OPEN | same family as D102 | VERIFIED | 11 |
| D104 | N-10 | `docs/code/bank00/actors-combat-interaction.md:134`, `actors-player-rewards.md:58,73` | "HP bar delta" | PARTIAL | `:58` is correct; `:134` and `:73` vague | VERIFIED | - |
| D105 | N-9 | `docs/code/bank00/stair-climb-system.md:8,33,117,127,288`, `bank00/README.md:740`, `data-tables-memory.md:250` | `will_alt` for `$8F` | OPEN | live `body_table.asm:31` shows `spriteset_will_abilities ($8F)` | VERIFIED | 10 |
| D106 | N-9 | `docs/cop/families/sprite_anim.md` (3 lines), `sprite_state.md` (1 line) | `spriteset_particle_fx`, `spriteset_enemies` retired | OPEN | the report named only `sprite_anim.md`; `sprite_state.md` also has it | VERIFIED | 10 |
| D107 | N-9 | `docs/cop/families/camera.md` | `forced_walk_sequence_table` retired | DONE (live) | the live doc is clean; the `gaia-knowledge/corpus` copy of `camera.md` still has 2 hits (section 2.5) | VERIFIED | 3 |
| D108 | N-9 | `docs/code/chunk-03BAE1-analysis.md` | `RunThinkers_TypeA/B/C/D` | DONE (live) | no hit in live `docs/`; 4 hits remain in the corpus copy | VERIFIED | 3 |
| D109 | N-9 | `.cursor/plans` mention of a retired block name | retired name in a plan file | SUPERSEDED | the file no longer holds the name | VERIFIED (absence) | - |
| D110 | N-9 | `IOGRetranslation/artifacts/file-layout.json:779-780` | `spriteset_ability_fx`, `spriteset_will_alt` | OPEN | generated file, 2 hits now (report said 4); regenerate, do not edit by hand | VERIFIED | 10 |
| D111 | N-3 | `docs/code/bank0D-scene-meta.md:105` | "Bank $02, table_018000" | OPEN | see D95 | VERIFIED | 3 |
| D112 | N-6 | `docs/code/bank01-data-tables.md`, `bank0D-scene-meta.md` | dialog_template_table wording | OPEN | see D90 | VERIFIED | - |
| D113 | N-7 | `docs/wram-memory-map.md:207` (gfxLoadParams) | see D01 | OPEN | see D01 | VERIFIED | 3 |
| D114 | B-001 | `AGENTS.md`, `.cursor/rules/snes-knowledge.mdc` | merge / names commands described and `ingest` / `annotate` removed | DONE | both mention `npm run merge` and `npm run names`; `ingest` / `annotate` are marked removed | VERIFIED | - |

Rows D107..D113 repeat report numbers N-3, N-6, N-7, N-9 and are kept so every report item has a row. No docs change fixes only one of them.

### 2.2 New findings not in any ledger

These came up while re-verifying. None is recorded in a frozen ledger.

| ID | File:line | What is wrong | Proposed fix | Tag | Class |
|---|---|---|---|---|---|
| N-A11-01 | `docs/code/bank03/movement-and-collision.md:251-254` | the damage formula is inverted: the doc has `rawDamage = max(1, enemyAtk - totalStr)`; code is `max(1, totalStr - victimStats[2])` and `+ characterForm`. The doc also says the routine is the enemy-hits-player path (D05) | rewrite the bullet from `combat_collision.asm:36-40` | VERIFIED | 11 |
| N-A11-02 | `docs/wram-memory-map.md:290`, `docs/code/bank03/movement-and-collision.md:251,314`, `docs/code/bank00/data-tables-memory.md:336` | `climbStateData` / `previousDamage` are the stale mnemonics for `$09E0` (Will ability damage bonus) and `$09E2` (Freedan's); `stair-climb-system.md:95,293` and `attack-ability-system.md:281,285` already say "Will ability bonus byte" | one wording for the two bytes in all three docs; rename in `mnemonics.json` is AP-21 | VERIFIED | 3 |
| N-A11-03 | `docs/code/bank02/scene-script.md:104` and `docs/code/bank0D-scene-meta.md:161` | the same SPC music load path described wrongly in two docs (file location, and equal-group skip) | fix both together from `scene_script.asm:1296-1306` | VERIFIED | 11 |
| N-A11-04 | `docs/code/bank00/data-tables-memory.md:39,125,158` | `slope_curve_table` described as a sine/cosine HUD table, contradicted by the live part note | rewrite the three rows from `math_lookup_tables.asm:9` | VERIFIED | - |
| N-A11-05 | `docs/code/bank02/game-systems.md:498,506,516,527,533,543,611,629,881`, `docs/code/bank03/radar-and-world-map.md:54,80` | retired auto-name `table_01ADA8` | use the live block name from `db-us/blocks.json` | VERIFIED | 3 |
| N-A11-06 | `docs/code/bank02/game-systems.md:570`, `docs/code/bank03/text-and-menus.md:346`, `docs/code/bank03/field-input-and-items.md:401`, `docs/code/bank03/README.md:302` | retired auto-names `itemget_table_01FD24` and `itemcomp_table_01EB0F` | use the live block names | VERIFIED | 3 |
| N-A11-07 | `docs/code/bank00/data-tables-memory.md` and others | generic auto-names `table_0F8000`, `table_0FC000`, `table_17A000` still in the body-table rows | same fix as D97 | VERIFIED | 10 |
| N-A11-08 | `docs/code/bank00/actors-player-rewards.md:133,155`, `bank00/README.md:192,619` | `SpawnSparkleEffect` does not exist (D79) | `SpawnImpactSparkAndDie` or `SpawnItemSparkleEffect` per call site | VERIFIED | 10 |
| N-A11-09 | `docs/cop/families/player_query.md:45-46` | operand order contradicts its own body | align to `:142,179` | VERIFIED | - |
| N-A11-10 | report N-9 and section 4.4 | "no retired block name in docs" is true only for the spriteset / table names the report grepped. It is false for the address-style auto-names in N-A11-05..07 | correct the claim in the final report | VERIFIED | 3 |

### 2.3 Sweeps over `docs/` (step 3)

Counts are lines in live `docs/` (excluding `docs/` copies elsewhere). "Legit" means the use is correct.

| Term | Result | Classification |
|---|---|---|
| Appendix A retired names | all spriteset / thinker / function names in Appendix A: no hit in live `docs/` except D105/D106 (`will_alt`, `spriteset_particle_fx`, `spriteset_enemies`) | OPEN: D105, D106 |
| address-style auto-names (beyond Appendix A) | `table_018000` (24 lines), `table_01ADA8`, `itemget_table_01FD24`, `itemcomp_table_01EB0F`, `SpawnSparkleEffect`, body-table `table_*` rows | OPEN: D95, N-A11-05..08 |
| "Damage flash" | `system-core.md:421,457,522`, `data-tables-memory.md:381`, `bank08-native-dao-pyramid-actors.md:417` (lower case) | OPEN: D102, D103 |
| `table_018000` | `bank0D-scene-meta.md:105`; `bank02/scene-script.md:99,215,733,739,758,1095`; `structs-reference.md:362,833,841,843`; `bank01-data-tables.md:46,688`; more in `bank02/` code-analysis lines | OPEN: D95. The Robotrek `unk17_table_018000` in the corpus is a different name |
| barrier | `bank01-data-tables.md:21,199,203,205,208,692`, `code/README.md:241`, `game-systems.md:509,525,527`; the rest (`ec0E_barrier`, Kress barriers, `MarkSolidAbs barrier`) are legit | OPEN: D100 |
| `will_alt` | 7 lines in `stair-climb-system.md`, `bank00/README.md`, `data-tables-memory.md` | OPEN: D105 |
| `deathFlag` | no hit in `docs/` | DONE (D19). The mnemonic is still in `mnemonics.json:9` (AP-21) |
| `musicParentActor` | `wram-memory-map.md:248`, `docs/code/bank03/item-use-system.md` | OPEN: D24 |
| `climbStateData` | `wram-memory-map.md:290`, `movement-and-collision.md:251,314`, `data-tables-memory.md:336`; mnemonic key 2528 still has it (`mnemonics.json:156-157`) | OPEN: N-A11-02 |
| `invincibilityTimer` | no hit in `docs/`; `ram_map.txt` correct. `bank00/README.md:316` still says "Decrement invincibility timer" | DONE (D39) / OPEN (D40) |

### 2.4 `gaia-core/docs/notes-and-comments.md` changes needed (AP-17)

All verified against the file and against `gaia-core/src`.

| ID | Where | Problem | Proposed change | Tag |
|---|---|---|---|---|
| AP17-01 | "Rename propagation checklist" `:599-700` | still a manual checklist and contains two embedded Python scripts (orphan check `:630-671`, stale reference scan `:679-697`); this conflicts with the "no scripts, use `npm run names`" rule and duplicates what `npm run names` does | replace by a short pointer to the Names Merge section; delete the two scripts | VERIFIED |
| AP17-02 | `src/index.ts:233`, `src/merge.ts:17` | `merge` has `--dry-run` only; `names --check` exists (`src/names-merge.ts:86`) but the orphan sweep that the Python scripts did has no tool | extend the tool (a `merge --check` or the equivalent in `names --check`) and document it. Do not keep the scripts | VERIFIED |
| AP17-03 | `:1315`, `:1358` | specs are called a "replayable record"; `edit` entries are not repeatable (the doc says so at `:1288`) and the I061/I062 specs use hex addresses (G-7, G-8) | reword: a spec is a record of one run; say which entry types replay | VERIFIED |
| AP17-04 | no section | no policy on history narration, hedges / UNVERIFIED-RUNTIME, or OQ / R ids in note text (H-1..H-3) | add a "Note text rules" section; ledger ids and OQ ids stay in plans, not in notes | VERIFIED (absence) |
| AP17-05 | no section | no policy on the `Dead:` marker (AP-19) | add the marker format and when to use it | VERIFIED (absence) |
| AP17-06 | no section | no button vocabulary rule (H-6): `$0001` is not a button, raw source bit | add the vocabulary table | VERIFIED (absence) |
| AP17-07 | no section | no glossary rule (H-7) | add a pointer to the glossary file when it exists (F-step) | VERIFIED (absence) |
| AP17-08 | no section | no `WaitByte` n+1 rule (class 2) | add one line: `WaitByte(n)` = n+1 ticks | VERIFIED (absence) |
| AP17-09 | no section | no post-rename `docs/` grep list: after a rename, `rg` the old name in `docs/`, `gaia-knowledge/corpus`, `IOGRetranslation/artifacts` | add the list (see section 2.5) | VERIFIED (absence) |
| AP17-10 | transform-adjacency / gate text | the doc says only that sizes differ; it does not say that the plain and the tagged gate fail for five multi-line transforms | add one sentence | REPORTED |
| AP17-11 | already done | transform-adjacency hazard (`:1319`), same-mode CRC baseline (`:1386`), bank detection with 6 strategies (`:1388-1403`), note that `extract:lt` deletes `extracted/`, Names Merge section (`:1405-1470`) | none | VERIFIED |

### 2.5 `gaia-knowledge/corpus` files that mention retired names

All are stale copies under `corpus/games/iog/project-docs/` (the corpus copy of `gaia-iog-baserom/docs`). The fix is `npm run ingest:all` after F05; I did not run it.

| Term | Hits | Files |
|---|---|---|
| `table_018000` | 24 | `bank0D-scene-meta.md` (1), `bank2-code-analysis.md` (2), `bank01-data-tables.md` (2), `scene-engine.md` (6), `scene-script.md` (6), `structs-reference.md` (4). `corpus/games/robotrek/overview.md:363` `unk17_table_018000` is Robotrek, not a retired IOG name |
| `table_01ADA8` | 20 | `bank01-data-tables.md` (2), `bank2-code-analysis.md` (3), `game-systems.md` (9), `overworld-input.md` (3), `radar-and-world-map.md` (2) |
| `will_alt` | 6 | `data-tables-memory.md` (1), `stair-climb-system.md` (5) |
| `itemget_table` / `itemcomp_table` | 9 | `bank2-code-analysis.md`, `bank01-data-tables.md` (4), `chunk-03BAE1-analysis.md`, `field-input-and-items.md`, `game-systems.md`, `text-and-menus.md` |
| "Damage flash" | 4 | `bank08-native-dao-pyramid-actors.md`, `data-tables-memory.md`, `system-core.md` (2) |
| `musicParentActor` | 2 | `item-use-system.md`, `wram-memory-map.md` |
| `spriteset_particle_fx` / `spriteset_enemies` | 4 lines, 2 files | `cop/families/sprite_anim.md` (3), `cop/families/sprite_state.md` (1) |
| `forced_walk_sequence_table` | 2 | `cop/families/camera.md` |
| `RunThinkers_TypeA/B/C/D` | 4 | `chunk-03BAE1-analysis.md` |
| `SpawnSparkleEffect` | 2 | `actors-player-rewards.md` |
| `DarkGemDropSystem` | 1 | `functions-combat-defeat.md` (the live doc keeps it on purpose as a history line, H-1; the corpus copy will follow) |

Also: `IOGRetranslation/artifacts/file-layout.json:779-780` (D110) is generated; regenerate it. `curated/`, `manifest.json` and `AGENTS.md` have no retired name.

## 3. Not verified / needs Mesen2

- Every status above is static. No row needs a Mesen2 run to be closed, but these code-side claims stay REPORTED because I did not re-read the cited code: D03, D08, D09, D12, D13, D20, D26, D27, D28, D29, D30, D35, D50, D51, D54, D55, D58, D70, D81, D85, D94 (game-systems.md part), D99 (counts), D101.
- D09 and D77 depend on open questions (OQ-8, OQ-I051-2). This step does not answer them.
- D70 grep failed in the shell (escape error), so the `ApplyOrbitalOffsetXY` doc lines are UNCHECKED, not DONE.
- `docs/code/bank02/inventory-overlay.md` was only searched for names, not read.
- Which docs a user already edited by hand after the apply summaries is shown by the DONE rows; I could not tell who edited them.

## 4. Items for the fix specs

F05 is a manual `StrReplace` job (docs are outside `merge` and `names`, G-4). The list below is by file so each file is opened once.

| File | Rows to fix |
|---|---|
| `docs/wram-memory-map.md` | D01, D12, D24, D33, D54, N-A11-02 (`:290`) |
| `docs/structs-reference.md` | D02, D95, D97 (`:1104-1108`), D94 (`:1275-1340`), D51 (`:1171`) |
| `docs/bank01-data-tables.md` | D58, D88, D89, D90, D93, D94, D95, D97, D98, D99, D100, D101 |
| `docs/code/README.md` | D52, D88, D89, D93, D100, D59 |
| `docs/code/bank00/system-core.md` | D102, D28 |
| `docs/code/bank00/data-tables-memory.md` | D10, D78, D102, D105, N-A11-02, N-A11-07 |
| `docs/code/bank00/README.md` | D40, D78, D79, D105 |
| `docs/code/bank00/stair-climb-system.md` | D105 |
| `docs/code/bank00/actors-player-rewards.md` | D32, D79, D104 |
| `docs/code/bank00/actors-combat-interaction.md` | D77, D104 |
| `docs/code/bank00/functions-player-npc.md` | D78 |
| `docs/code/bank00/utility-tiles-animation.md` | D25 |
| `docs/code/bank02/scene-script.md` | D03, D04, D92, D95, D96 |
| `docs/code/bank02/game-systems.md` | D34, D94, D100, N-A11-05, N-A11-06 |
| `docs/code/bank03/movement-and-collision.md` | D05, D06, D07 |
| `docs/code/bank03/actor-thinker-runtime.md` | D35 |
| `docs/code/bank03/nmi-handler.md` | D21 |
| `docs/code/bank03/radar-and-world-map.md`, `text-and-menus.md`, `field-input-and-items.md`, `README.md` | N-A11-05, N-A11-06 |
| `docs/code/bank0C-scene-spawn-tables-comet.md` | D51, D52, D55, D81 |
| `docs/code/bank0D-scene-meta.md` | D91, D95 |
| `docs/code/bank08-native-dao-pyramid-actors.md` | D32, D103 |
| `docs/code/bank0A-dungeon-enemy-actors.md` | D32 |
| `docs/cop/families/` | D13 (`palette.md`), D14 (`hdma_dma.md`), D25 (`force_move.md`, `player_sprite.md`, `sprite_staging.md`), D27 (`vram_memory.md`), D29 (`dialog.md`), D63 (`player_query.md`), D106 (`sprite_anim.md`, `sprite_state.md`) |
| `docs/cop/cop-commands-reference.md` | D25 (`:829`), D18 |
| `gaia-core/docs/notes-and-comments.md` | AP17-01 .. AP17-10 (AP-17) |
| `IOGRetranslation/artifacts/file-layout.json` | D110, regenerate |
| `gaia-knowledge/corpus` | section 2.5, refresh with `npm run ingest:all` once F05 is committed (not now) |

Out of F05 (other steps): the `mnemonics.json` renames behind N-A11-02, D19, D24 (AP-21); `names` renames behind D49 (OQ-I030-2); note text changes behind D03, D13, D27 etc. (F-steps for `merge`).

## 5. Counts

Status counts for table T1 (D01..D114):

| Status | Rows |
|---|---|
| DONE (includes "DONE (wording)" D49 and "DONE (live)" D107, D108) | 46 |
| OPEN (includes D94 with its game-systems part REPORTED) | 51 |
| PARTIAL | 7 |
| SUPERSEDED | 2 |
| UNCHECKED | 8 |
| **Total** | **114** |

Other counts:

- New findings (section 2.2): 10 (N-A11-01 .. N-A11-10), all VERIFIED.
- AP-17 items (section 2.4): 11 rows (10 changes, 1 already done).
- Corpus term groups with hits (section 2.5): 11 (about 70 lines in 12 corpus files).
- Sweep terms (section 2.3): 10 rows; 4 of the 9 requested terms are fully DONE or absent (`deathFlag`, `invincibilityTimer` mostly, Appendix A names mostly); `Damage flash`, `table_018000`, `barrier`, `will_alt`, `musicParentActor`, `climbStateData` are OPEN.
- Docs edited in this step: 0. Gate run: no (nothing changed). `npm run ingest:all`: not run.
