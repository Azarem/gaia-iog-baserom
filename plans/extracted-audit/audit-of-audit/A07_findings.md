# A07 findings: sanity-style re-verification of I065–I068

Step: A07 of the audit of the audit. Inputs: `digest_I041-I072.md` (I065..I068 sections), `report.md` §3, §4.4, §8, the I065–I068 results, renames and edit specs, and the live files under `extracted/`.
Nothing was edited except this file and the A07 row of `PLAN.md`.

**Evidence level.** Every behavioural statement below is static (E1 code trace or E2 cross-reference). There is no Mesen2 ROM or save state, so nothing is E5. Where a claim needs runtime proof it is in "Not verified / needs Mesen2".
**Tags.** VERIFIED = checked in the live files this session, with file:line. REPORTED = taken from a ledger or the report, not re-checked.
**File names.** The step prompt uses retired names. The live files are: `item_get_dialog_table` → `item_pickup_text_table` (`db-us/blocks.json:1042`); `spriteset_will_projectile` → `spriteset_darkgaia_projectile` (`db-us/blocks.json:1063`); `spriteset_ability_fx` → `spriteset_transform_poses` (`db-us/blocks.json:1050`). All paths below are under `extracted/` unless stated. The block patch `baserom/equipped-icon/spriteset_darkgaia_projectile.asm` exists (it changes the palette bits of the tile words, for example `$0440` to `$0240`); it was not audited (note text and groups not compared).
**Working tree.** `git status` shows many files under `extracted/` as modified (not by this step), and `rg` finds `; {n}` line-tracking markers on the instruction lines of the code files (for example `system/engine/scene_script.asm:1303`). The files under `extracted/tables/` carry no markers. Line numbers below are those of the current checkout; no marker was touched.

---

## 1. Scope and files read

### 1.1 Files checked (12)

| # | Live file | Lines | What was read |
|---|-----------|-------|---------------|
| 1 | `tables/dialog_template_table.asm` | 170 | whole file |
| 2 | `tables/parallax_scroll_table.asm` | 232 | whole file (block note, table note, 22 type notes, the decode of each band list) |
| 3 | `tables/scene_meta.asm` | 3132 | block note (1–35), table notes (40, 3065), the 6 sample-record notes and records (302, 311, 343, 378, 2213, 3052), whole-file counts by rg; the other 225 records by counts only |
| 4 | `tables/enemy_stats_table.asm` | 143 | whole file |
| 5 | `tables/spriteset_aura.asm` | 153 | whole file |
| 6 | `tables/spriteset_shadow.asm` | 2706 | block note, table note, pointer table, anim `$00-$0A`, `$10`, `$18`, `$1C`, `$36`, `$3A`, `$3E-$42`, `$44`, `$4A`, example group; whole-file counts by rg |
| 7 | `tables/item_pickup_text_table.asm` | 198 | whole file |
| 8 | `tables/spriteset_darkgaia_projectile.asm` | 265 | whole file, and the block patch `baserom/equipped-icon/spriteset_darkgaia_projectile.asm` |
| 9 | `tables/spriteset_transform_poses.asm` | 2526 | block note, table note, `transform_pose_00` head, the two hidden-group notes and rows (1008–1040, 1352–1392), counts by rg; the other frame lists by counts only |
| 10 | `tables/spriteset_npc_props.asm` | 263 | whole file |
| 11 | `tables/display_preset_table.asm` | 268 | whole file |
| 12 | `tables/scene_warps.asm` | 2237 | block note, pointer table head, `warp_def_empty`, `warp_def_01-06`, `warp_def_E3`, `E6`; whole-file counts of every field by rg |

### 1.2 Code and docs read to check the claims

`system/engine/`: `scene_script.asm` (lines 1–260, 1130–1410), `DialogStringRenderer.asm` (lines 1–300, 440–500, 698–730, 890–960, 1066–1105), `warps_interaction.asm` (636–1020), `forced_walk.asm` (1–150), `combat_collision.asm`, `actor_execution.asm` (`InitActorFromSceneData`), `cop_handlers_inventory.asm`, `cop_handlers_player_sprite.asm`; `system/inventory/inventory_mgmt.asm`, `system/inventory/inventory_overlay.asm`; `functions/EnemyDefeatDispatch.asm` (whole), `StandardEnemyDefeatHandler.asm`, `EnemyDropSystem.asm`, `EnemyInitBasic.asm`; `actors/field_reveal_object.asm`, `actors/town_door.asm`, `actors/player/attack_ability_system.asm` (Aura block and `AuraBarrierPaletteFX`), `actors/player/player_character.asm` (Projectile* actors, Psycho Slider staging), `system/dark_space/sE6_gaia.asm` (the seven `Transform_*` scripts), `tables/palette_bundles.asm` (bundle `$5B`), `tables/body_table.asm`; the 25 actor files that name `spriteset_npc_props` (the stage operands after each `SetMetasprite`); `baserom/equipped-icon/EquippedIcon.patch.asm`; `docs/ram_map.txt`; `db-us/blocks.json` (1000–1066).

### 1.3 Ledgers read

`audit-of-audit/PLAN.md`, `report.md`, `digest_I041-I072.md`, `A06_findings.md` (format); `results/I065..I068_results.md`.

### 1.4 Coverage of "check every note line by line" (≥ 60 %)

Unit = a comment paragraph in the extracted file. 12 block notes, plus part notes counted by their position (94: dialog template 23, parallax 23, scene_meta 8, enemy_stats 1, aura 5, shadow 2, item pickup 8, Dark Gaia projectile 9, transform poses 6, npc props 3, display preset 3, scene_warps 3).

| Group | Read | Claims checked against code or data | Not checked |
|-------|------|-------------------------------------|-------------|
| Block notes | 12 of 12 | 12 of 12, with the exceptions listed below | see below |
| Part notes | 94 of 94 | about 80 of 94 (85 %) | about 14, listed below |

**Not checked (listed as required):**
1. `dialog_template_table` "Seen before" speaker columns (templates `$00`–`$07`, `$10`, `$14`: 9 notes) were read but the strings were not re-counted per speaker. The colour words were decoded for 3 of 14 (`$6FDF`, `$0B1E`, `$777F`; all match).
2. `enemy_stats_table.asm:21` ("16 rows with stats are neither used by a scene spawn record nor named by code") was not recomputed over `scene_actors` (REPORTED, A07-23).
3. `scene_meta` records other than the six sample records were verified by counts only (225 records).
4. `spriteset_shadow`, `spriteset_transform_poses`: the frame lists and sprite groups other than those named in §1.1 were verified by counts and byte arithmetic only (not row by row).
5. `scene_warps` list bodies other than the ones named in §1.1 were verified by whole-file counts (every field), not read row by row. The note itself says "Sampled about 18 %" (A07-20).
6. `scene_warps` "Which warp uses which list was still not mapped" is an open fact, not checked.

---

## 2. Findings

Severity: H = wrong fact a reader would act on; M = wrong or stale fact, limited effect; L = imprecision or hygiene. Defect class numbers are from PLAN.md (n/a = no class fits, a plain counting or census error).

### 2.1 Wrong or incomplete facts

**A07-01 · VERIFIED · H · class 6**
`system/engine/scene_script.asm:1303`, inline comment of `SpcMusicLoadCmd`: "Compare current musicRoomGroup — same group means music is already loaded".
Code (lines 1302–1308): `LDA $musicRoomGroup; CMP $06F4; BEQ loc_028B88; RTS`. **Equal** groups continue to the source-cache check (line 1310) and the load; **different** groups return. The comment is inverted. The routine's own header (line 1294: "compares musicRoomGroup to script group — mismatch exits") and `scene_meta.asm:25` ("the SPC transfer runs only when the group equals musicRoomGroup") are right; the block note `scene_script.asm:75` ("gates loading to prevent redundant transfers when re-entering the same music region") is a loose paraphrase of the same behaviour.
Fix: "Group equal to the script's group: continue (the load still skips when the source cache hits); different group: return". Spec: F01 (the `SpcMusicLoadCmd` item).

**A07-02 · VERIFIED · M · class 11**
`tables/spriteset_aura.asm:15`: "AuraBarrierMain copies 7 colours of fx_palette_198090 to CGRAM $A9 ($A9-$AF); AuraBarrierPaletteFX cycles them."
The copy is right (`attack_ability_system.asm:401`, `CopyPalette ( @fx_palette_198090, #00, #A9, #07 )` = colours `$A9–$AF`). The cycling is not of those colours. `AuraBarrierPaletteFX` runs bundle `#5B` (`attack_ability_system.asm:1610–1612`, comment "8 strips of 8 colors at CGRAM $A1–$A8"). The bundle itself (`tables/palette_bundles.asm:8221–8230`, entry `;5B` = `palette_bundle_16C1BD`) is 8 sub-entries `palette-bundle < #01, &frames, #A1, #0F, #01 >`: one frame each, destination colour `$A1`, size `$0F` (= 8 colours, per `palette_bundles.asm:6`), wait 1. So the actor cycles colours `$A1–$A8` and leaves `$A9–$AF` as copied. Both ranges are inside sprite palette 2 (`$A0–$AF`), so the Aura sprites show a static part and a cycling part of one palette.
Fix: "…copies 7 colours of fx_palette_198090 to CGRAM $A9-$AF; AuraBarrierPaletteFX cycles bundle #5B over colours $A1-$A8 of the same palette." Spec: F08.

**A07-03 · VERIFIED · M · class 11 (same as A06-09)**
`tables/spriteset_shadow.asm:7`: "The player scripts stage $10-$13 for Shadow only".
`#10–#13` are staged by `StagePlayerSprite` for Shadow idle (`player_character.asm:238, 249, 260, 271`, `actors/player_transition_handlers.asm:59`, `ending/ending_credits/sF7_credits_player.asm:103, 108`) and also by the Psycho Slider code under `SetPlayerSpriteDirect #04` (`player_character.asm:1397 StageSpriteLoopMoveY #10`, `1399 StageSpriteFrame #11`, `1413 #12`, `1418 StageSpriteLoopMoveX #13`), i.e. against `spriteset_will_abilities`, not Shadow. The sentence is true only for the `StagePlayerSprite` family (which picks the body from `characterForm`).
Fix: "The `StagePlayerSprite` scripts stage `$10-$13` as Shadow's idle poses; the Psycho Slider also stages `#10-#13`, against `spriteset_will_abilities`". Spec: F08 (and the sibling claim in `spriteset_freedan`/`spriteset_will` notes belongs to F07).

**A07-04 · VERIFIED · M · class 5**
`tables/spriteset_transform_poses.asm:14` (table part note): "Unused: $04 (transform_pose_04), $0C (transform_pose_0B), $11 (transform_pose_11)."
The pointer table (lines 17–36) maps index `$0C` to `transform_pose_0C`, not `transform_pose_0B` (`&transform_pose_0B ;0B`, `&transform_pose_0C ;0C`). The part note at line 539 ("Animation $0C: not referenced ...") sits above `transform_pose_0C`, so the note at line 14 has the wrong label.
The unused set itself is right (static): the seven `Transform_*` scripts stage `$00-$03, $05-$0B, $0D-$10, $12` and nothing else (`sE6_gaia.asm:1657–2013`; union of the `StageSpriteFrame` / `StageSpriteLoop` operands), and `rg -n "SetPlayerSpriteDirect\] \( #05" extracted` has no hit outside `sE6_gaia.asm`.
Fix: `$0C (transform_pose_0C)`. Spec: F08.

**A07-05 · VERIFIED · M · class 5 (incomplete census)**
`tables/spriteset_npc_props.asm:6–17`, "Users" column. The note says users were found "by searching for SetMetasprite ( @spriteset_npc_props )". Three actors that select the set are missing from the table:
- `freejia/freejia/fr32_locked_door.asm:20` (`SetMetasprite`), stages `#01` (line 25) and `#00` (line 35): the Freejia locked door uses `$00` and `$01`, as `town_door` does.
- `freejia/freejia/fr32_kidnapper.asm:45`, stages `#01` (line 49): the closed-door frame.
- `mu/mu_prayer_room/mu63_spirits.asm:157`, `SetMetasprite` followed by `PlaySoundBoth`, stages `#06` (line 161): the flame animation, not a spirit (the file name misleads).
`rg -l spriteset_npc_props extracted` lists 26 files: the spriteset file itself and 25 actors. The table names 22 of the 25 (`town_door`, `fr32_guide`, `gs2B_bones`, `nvAC_bones`, `eu9D_bones`, `btDE_olman`, `pyCD_jackal`, `awBF_spirit_guide`, `btDF_spirits`, `btE3_dao_travel_spirit`, `btE4_olman`, `daC3_babel_travel_spirit`, `ec10_dp_hint_spirit`, `mu66_rama_spirits`, `sE5_epilogue`, `av69_signs`, `av6B_flame`, `ec0A_torch1`, `ec0A_torch2`, `freejia_street_prop`, `st68_campfire`, `btE4_kara`); the three above are the rest. The frame numbers of the 22 named users matched their `Stage*` operands. `$03` and `$09` stay unused: no `Stage*` operand `#03` / `#09` follows an `npc_props` metasprite in any of the 25 users (static negative).
Fix: add the three actors to rows `$00`, `$01`, `$06`. Spec: F08.

**A07-06 · VERIFIED · M · class 5 (missing reader)**
`tables/enemy_stats_table.asm:6–10`, field table: byte `+3` "gemDropType" lists one reader, `EnemyGemDropRouter in StandardEnemyDefeatHandler`. A second reader exists: `actors/field_reveal_object.asm:100–104` (`FieldRevealFromActorStats`: `LDA $0003,Y; AND #$0003; SwitchCase` → 0 `FieldRevealDieEmpty`, 1/2/3 gem pickups worth 1 / 2 / 5 gems), reached from `EnemyDefeatDispatch` for every kill but the last (`functions/EnemyDefeatDispatch.asm:7, 10`). That is the I051 correction (the byte is a gem type, not HP/STR/DEF), and it is the only place where `$03` has its own meaning (the router sends every value ≥ 3 to the weighted picker).
What is right: the router side (`StandardEnemyDefeatHandler.asm:9, 98–103, 170–194`: 0 = no gem, 1 → `SpawnDropGem1` ($83), 2 → `SpawnDropGem2` ($84), other → `SpawnDropByHpTier`), the rows "gemDropType 0 in 37, 1 in 21, 2 in 21, 3 in 13" (92 rows with stats, values 0–3 only), and "the last enemy gives the stat reward instead".
Fix: add `FieldRevealFromActorStats (field_reveal_object)` as a second reader, with the `& 3` meaning. Spec: F08.

**A07-07 · VERIFIED · L · class 11**
`tables/enemy_stats_table.asm:12`: "Damage and stagger immunity are bits $0010 / $0020 of the actor's $12 flags (EnemyInitBasic sets both)".
`functions/EnemyInitBasic.asm:3, 17`: `$12 |= $0030`, "bit $0010 = damage / stagger immune, bit $0020 = boss (combat_collision readers)": `$0020` is the boss bit (damage digits and the player-attack hit test are skipped), not an immunity bit. The conclusion of the sentence (immunity is flag data, not table data) stands.
Fix: "bit `$0010` of `$12` is damage / stagger immunity and `$0020` the boss bit (EnemyInitBasic sets both)". Spec: F08.

**A07-08 · VERIFIED · M · class 6**
`tables/dialog_template_table.asm:1`: "afterwards it restores the cursor ($0998), the string pointer and the bank, so the caller's string continues where it stopped." The same wording is in the handler header, `system/engine/DialogStringRenderer.asm:242–244` ("Restores the VRAM cursor, string pointer, bank, and processor state on return").
Code (`DialogStringRenderer.asm:245–266`): `STX $0998; JSL DialogStringRenderer; LDX $0998; PLY; INY; PLB; PLP`. The callee ends with `DialogCmd_Return` (`STX $0998 ... RTL`, lines 196–206, whose header says "The updated cursor is handed back only through $0998"). So the caller does not get its **old** cursor back: X is reloaded from `$0998`, which holds the cursor **after** the template's output. Only the string pointer (Y), the bank (`PLB`) and flags are restored. That is why the box templates (`[DLG:..][SIZ:..]`) move the cursor for the text that follows, and the speaker templates (colour and SFX tags only) leave it where it was.
Fix: "afterwards the caller's string pointer, bank and flags are restored, and the cursor is reloaded from `$0998`, where the template's last character left it (a `[DLG]` template therefore positions the text that follows)". Also correct the handler header (`DialogStringRenderer.asm:242–244`). Spec: F08 for the table note; the handler header is `merge` of the `DialogStringRenderer` part note (add to F08 as a second target).

**A07-09 · VERIFIED · M · n/a (counting)**
`tables/dialog_template_table.asm:18`: template `$11` "49" uses. The table header says "uses = occurrences of [TPL:nn] in the extracted strings, whole-file count".
Real uses in strings: **37**. A whole-file `rg` count gives 51 because 14 comment lines mention the tag: 12 in `system/world_map/world_map_options.asm` (for example lines 34, 635, 643, 651: "prints an empty [TPL:11]") and 2 in the template file itself (lines 18, 148). The note's 49 is 51 minus the 2 own mentions, so it still contains the 12. The other 21 rows match the string-only count exactly (see §3, row "template uses"). Total real uses: 1501.
Fix: `$11` row 37; header wording "occurrences in the extracted strings (comment lines excluded)". Spec: F08.

**A07-10 · VERIFIED · M · class 3 (N-1 result, check (a))**
Report N-1 asked whether the `SceneCmd_*` handler names agree with the opcodes. Result: **the names in the jump table are right**; the text around them is not.
- Jump table (`scene_script.asm:229–254`) against the opcode table of `scene_meta.asm:15–27` (the handler column): `$02` ConfigDisplay, `$03` LoadBgTiles, `$04` LoadPalette, `$05` LoadMetatileSets, `$06` LoadLayerMaps, `$0E` Skip3, `$10` LoadSpriteTiles, `$11` SpcMusicLoadCmd, `$13` Branch, `$14` Label, `$15` SkipScriptCommands, `$17` LoadCharTiles. 12 of 12 pairs agree; the 12 unused slots (`$00 $01 $07–$0D $0F $12 $16`) are `SceneCmd_Default` in both. The semantic of each opcode (palette colours, metatile sets, a layer map, ...) agrees with what the handlers do (`scene_script.asm:646–648, 687–689, 774–776`, handler headers).
- Stale text in `scene_script.asm`: the part note of the jump table (line 227: `$04=LoadTilemap, $05=LoadDualTilemap, $06=FullGraphics, $13=ConditionalLoad, $14=Nop`) uses five retired handler names; the block note rows (lines 17–19) describe `$04` as "Load single-layer tilemap data to WRAM", `$05` as "Load dual-layer tilemaps ..." and `$06` as "tiles + tilemaps + map geometry" although `$04` loads palette colours into the CGRAM buffer (`scene_meta.asm:19`) and `$05` loads metatile sets; the handler headers at line 646 ("Load tilemap data from ROM to WRAM ... palette tilemap") and line 687 ("Load tilemaps for both BG layers") repeat the old words.
Fix: rewrite the part note (line 227) with the live names, the block note rows 17–19 and the two headers with palette / metatile-set wording from `scene_meta.asm:19–21`. Spec: F01 (extend: it lists "opcode table, four part notes").

**A07-11 · VERIFIED · L · class 6**
`system/engine/scene_script.asm:1378`: "Compressed: store size, decompress to VRAM $4000 (sprite tile area)". The destination is WRAM: `LDX #$4000; STX $7A; JSL QuintetLzDecompress` (lines 1379–1382) and the uncompressed path DMAs to `$7E:4000` (lines 1390–1396); the handler header (line 1356) says "decompresses to $4000 ... $7E:4000 (uncompressed sprite tile staging)" and `scene_meta.asm:23` says "decompressed to $4000 in WRAM".
Fix: "decompress to WRAM $7E:4000". Spec: F01.

**A07-12 · VERIFIED · L · class 5**
`system/engine/scene_script.asm:277` (header of `SceneCmd_Label`): "Used as a placeholder or padding byte in command streams." The byte the handler skips (`INY`) is the label id, and the label position is what `SkipScriptCommands` finds through `meta_label_list` (`scene_meta.asm:26`: "defines label NN; executed as a no-op that skips its id byte"; 56 definitions, §3).
Fix: "No-op: skips the label id operand; the position is what `jump` and `branch` target". Spec: F01.

**A07-13 · VERIFIED · L · class 6**
`tables/scene_meta.asm:21` (`$06 tilemap` row): "the map of layer 1 or 2 (operand $01 225 times, $02 158 times) decompressed to mapTilemapBaseA $A000 / mapTilemapBaseB $C000". The `$05 tileset` row in the line above numbers the same two layers 0 and 1 ("layers bit 0 = layer 0, bit 1 = layer 1"), and the handler does too (`scene_script.asm:774`: "$067E layer 0, $0681 layer 1"; block note line 63: "flag bit 0 selects layer 0 (primary tilemap at $7E:A000), flag bit 1 selects layer 1 (overlay at $7E:C000)"). Operand `$01` is layer 0 (`$A000`), `$02` layer 1 (`$C000`). The counts 225 / 158 are right (§3).
Fix: "operand $01 = layer 0 (225 uses), $02 = layer 1 (158)". Spec: F08.

**A07-14 · VERIFIED · L · class 6**
`system/engine/warps_interaction.asm:647` (header of `InitWarpTable`): "each entry starts with a non-$FF byte". The loop (lines 658–661) uses `LDA $0000,X; BMI`: any byte `≥ $80` ends the list, not only `$FF`. `CheckWarpRectangles` (lines 696–697, 738–740) compares with `#$FF`. `scene_warps.asm:5` states this difference correctly. No data exposes it: no entry of the 743 has an X tile byte `≥ $80` (§3, row "X tile ≥ $80").
Fix: "ends at the first byte with bit 7 set (all lists use `$FF`)". Spec: F02 (the `warps_interaction` target already in F02).

### 2.2 Stale names and descriptions outside the twelve files

**A07-15 · VERIFIED · L · class 3**
`tables/spriteset_darkgaia_projectile.asm:11`: row `| $04-$07 | projectile_travel_south, 17D04E, 17D054, 17D05A |`. `17D04E`, `17D054`, `17D05A` are the retired offset names of the lists; the live labels (lines 29–32, 75–97) are `projectile_travel_north`, `projectile_travel_west`, `projectile_travel_east`.
Fix: use the live names. Spec: F08.

**A07-16 · VERIFIED · L · class 3 (with 6 and 11 on three lines)**
- `actors/player/player_character.asm:1850`: "metasprite from table_17D000" (live name `spriteset_darkgaia_projectile`).
- `actors/player/attack_ability_system.asm:552`: "Set metasprite table to table_179000" (live name `spriteset_aura`).
- `actors/player/attack_ability_system.asm:114` (class 6): "AuraProjectileChild is the individual orbiting sprite with 3-frame animation". The set has 3 animations of 4 frames (`spriteset_aura.asm:1`, and the actor stages `#00`, `#01`, `#02`, lines 553–561).
- `tables/body_table.asm:32` (class 11): row `$05` "Ability poses and effects". The set is `spriteset_transform_poses`, selected only by the seven `Transform_*` scripts of `sE6_gaia` (see A07-04); the I067 note is right, the row text is the old description. Same family as A06-15 (`body_table.asm:37`, `will_alt`/`ability_fx` nicknames).
- `docs/code/bank02/README.md:169`: `table_17D000.asm` (spritemap data).
Fix: replace the names; change `body_table.asm:32` with the F03 edit of `body_table` (F03 lists "row-5 drift"). Spec: F08 (the two actor comments, via `merge` comments), F03 (`body_table`), F05 (docs).

**A07-17 · VERIFIED · L · class 3**
Retired name `table_018000` (now `display_preset_table`) is still in: `system/engine/scene_script.asm:15, 71, 1159, 1161`; `baserom/equipped-icon/EquippedIcon.patch.asm:474` (`?INCLUDE 'table_018000'`; the labels it overrides on lines 478 and 482 already use the live name `display_preset_00!` / `display_preset_25!`); and 13 doc lines in 4 docs: `docs/bank01-data-tables.md:46, 662`, `docs/structs-reference.md:362, 833, 841, 843`, `docs/code/bank0D-scene-meta.md:105`, `docs/code/bank02/scene-script.md:99, 215, 733, 739, 758, 1095`. Lines `docs/bank01-data-tables.md:688, 712` are rename-map rows and are meant to name the old identifiers. The old name `itemget_table_01FD24` (now `item_pickup_text_table`; it predates `item_get_dialog_table`) is in `docs/code/bank03/text-and-menus.md:346`, `docs/code/bank03/field-input-and-items.md:401` and `docs/code/bank02/game-systems.md:570`. Report §4.4's retired-name grep did not list `table_018000`, `itemget_table_01FD24`, `table_179000` or `table_17D000`, so it did not see these.
Whether the loader resolves or ignores the stale `?INCLUDE` in `EquippedIcon.patch.asm` was not tested (other `?INCLUDE` names in that file, such as `chunk_*` and `table_17A000`, are not in `blocks.json` either; no rebuild was run in this step, so tolerance of unknown names is not shown).
Fix: `scene_script.asm` lines 15, 71, 1159, 1161 → F01 ("`table_018000` mentions" is already its item); the patch line and docs → F05 (docs list) and a patch edit decided by the user. Spec: F01, F05.

### 2.3 Hygiene sweeps (defect classes 4, 7, 9, 10)

**A07-18 · VERIFIED · L · class 4. History narration, 11 of 12 files.**
`rg -n -o -i "(the )?old (note|header|description)|was (wrong|too broad)|first audit pass" <12 files>`:

| File:line | Text (as the rg hit prints it, cut) |
|-----------|-------------|
| `dialog_template_table.asm:1` | "The old note ('Dark Space transforms', 'templates $08-$11 are size presets', '$12 ..." |
| `scene_meta.asm:1` | "The old note ('tileset, tilemap, palette bundle, music track, collision layer and ..." |
| `enemy_stats_table.asm:1` | "The old note was wrong about the fourth byte ('Type 0-3, affects damage calculatio..." |
| `spriteset_aura.asm:1` | "The old note said '4 animation frames for the rotating barrier sprites': the table..." |
| `spriteset_shadow.asm:3` | "The old header ('walking, idle, attack and liquify animation frames', 'Shadow's uniq..." |
| `item_pickup_text_table.asm:1` | "The old note ('item acquisition dialog messages', 'stat increases', 'inventory-ful..." ... "was wrong" |
| `spriteset_darkgaia_projectile.asm:1` | "The old note ('Will's Psycho Dash and Psycho Slide projectile sprites', 'ranged ab..." ... "was wrong" |
| `spriteset_transform_poses.asm:1` | "The old note ('Psycho Dash, Psycho Slide, Dark Friar cast, Aura Barrier, Earthquak..." ... "was wrong" |
| `spriteset_npc_props.asm:1` | "The old note ('town furniture, signs, chests, and decorative elements') was too broad" |
| `display_preset_table.asm:1, 15` | "the old note said 'selected by scene metadata', which is not what the code does"; "first audit pass" |
| `scene_warps.asm:1` | "The old note described the second list as 'staircase warps with climb-animation of..." |

That is 12 lines in 11 files.

`parallax_scroll_table.asm` is clean. Fix: delete each sentence and keep only the current fact. Spec: F08.

**A07-19 · VERIFIED · L · class 7. Ids in note text, in all 11 files that have any (every audited file except `parallax_scroll_table`).**
`rg -n -o "OQ-[A-Za-z0-9-]+|R-I[0-9]+-[0-9]+" <12 files>`:
`dialog_template_table.asm:28` (OQ-I065-1); `scene_meta.asm:19` (R-I065-6, "see R-I065-6" in the `$04` row); `enemy_stats_table.asm:12, 21` (OQ-I066-2, OQ-I066-1); `spriteset_aura.asm:15` (OQ-I066-3); `spriteset_shadow.asm:1` (OQ-I061-1); `item_pickup_text_table.asm:23, 24, 148` (OQ-I067-1, -2, -2); `spriteset_darkgaia_projectile.asm:15` (OQ-I067-3); `spriteset_transform_poses.asm:5, 263, 539, 721, 1358` (OQ-I067-4 ×4, OQ-I067-5); `spriteset_npc_props.asm:19 (×2), 55, 91` (OQ-I068-1, -2 ×3); `display_preset_table.asm:15, 17` (OQ-5, OQ-I068-3); `scene_warps.asm:19, 23` (OQ-I064-1, OQ-I068-4).
Fix: remove the ids; state the open fact in words ("not traced", "not viewed"). Spec: F08; A12 holds the OQ registry.

**A07-20 · VERIFIED · L · class 4. Process narration and hard-coded line numbers.**
- `scene_warps.asm:23`: "Sampled about 18 % by reading (header and pointer table, lists $00-$05, $61-$64, $E1-$E3 and the tail); the counts above were computed over the whole file." (Audit-process narration. The counts are right, §3.)
- `item_pickup_text_table.asm:10`: "the item-pickup code of combat_collision (line 1563)". The line is right today (`combat_collision.asm:1563`) but a line number in a note decays; name the routine instead.
- `scene_warps.asm:19`: "(answers part of OQ-I064-1)" is class 7 and also narration.
- `UNVERIFIED-RUNTIME` and `Checked:` paragraphs: 0 hits in the 12 files (`rg -n "UNVERIFIED|Checked:"`).
Fix: delete / replace. Spec: F08.

**A07-21 · VERIFIED · L · class 10. Retired reading kept in a type name.**
`tables/scene_warps.asm` prints the forced-walk entries as `stair-warp < ... >` (200 rows; the note at line 15 says "the extractor type is `stair-warp`" and explains that these are forced walks, all vertical). The type is defined in `db-us/structs.json` (also `docs/structs-reference.md`, `docs/bank01-data-tables.md`, `notes/blockNotes/bank01.json`). "Stair" is the old, wrong reading ("staircase warps with climb-animation offsets").
Fix: needs a decision by the user: rename the struct (for example `forced-walk-warp`) in `structs.json`, re-extract, and update the three doc and note mentions. Not a `merge` change. Spec: F06 / A14 (user-owned `structs.json`).

**A07-22 · VERIFIED · L · class 9. Unnamed fixed-address operands.**
`scene_warps.asm:23` writes `$0AF4`, which has the symbol `reviveWarpPtr` (`!reviveWarpPtr 0AF4` at `system/engine/warps_interaction.asm:116`, `functions/game_over_sequence.asm:49`; stored at `warps_interaction.asm:852`); `scene_warps.asm:30` writes `$00D4` and `$00D6`; `item_pickup_text_table.asm:5, 176, 181` use `$0DB8`; `dialog_template_table.asm:1` uses `$0998` and line 7 `$0996`. For `$00D4`, `$00D6`, `$0DB8`, `$0998` and `$0996` no `!` declaration was found by `rg -n "^!\w+\s+(00D4|00D6|0DB8|0998|0996)" extracted` (the `[ADR:...,DB8]` tag operand is raw by syntax). 
Fix: use `reviveWarpPtr` where the name exists; the other four need a names decision (A13). Spec: F08 for the text; A13 for new names.

### 2.4 Checks that came out right (recorded so they are not re-opened)

- **(a) scene_meta handler names:** see A07-10 (12 of 12 pairs agree, names right, surrounding text stale).
- **(b) scene_warps second list, by reading the handlers.** All of the note's claims hold (static):
  - Layout `[scene-warps] $FF [forced-walk warps] $FF`, strides 12 and 13: `InitWarpTable` (`warps_interaction.asm:649–670`) walks 12-byte entries (`ADC #$000C`) until a byte with bit 7 set, then stores the byte after the terminator in `$00D6`; `CheckWarpRectangles` (688–781) walks `$00D4` with stride `$0C` and `$00D6` with stride `$0D`, each ended by `CMP #$FF`. `warp_def_empty` is two `$FF` bytes (`scene_warps.asm:293–297`).
  - Trigger test: tile AABB then the pixel test of `ConvertWarpToPixels` (795–829: `size × 16 − 15`); the first `16 × size − 15` pixels trigger. Matches the block note (lines 7–8).
  - Scene warp (`ExecuteWarp`, 847–915): `+4` `sceneNext`, `+5` `warpDestX`, `+7` `warpDestY`, `+9` `warpFacing` (bit 7 = save warp: cleared in `warpFacing`, entry `+4` pointer and bank stored in `sceneSaveData`), `+10` `warpScrollParams`; `$0AF4/$0AF6` = pointer to entry `+4` and the bank (GameOverSequence revive point). Matches block note lines 11 and 23.
  - Forced walk (`ExecuteForcedWalkWarp`, 931–954): the pointer to entry `+7` goes to `warpFacing` (`$0650`), entry `+4/+5` to `warpScrollParams`, entry `+6` to `scrollStepTableBase`; `InitCameraBounds` then `StartForcedWalk` (968–1022): bit 5 west, bit 4 east, bit 7 north, otherwise south (bit 6 not decoded); low nibble = pan list index into `forced_walk_pan_table`. Stream of 6 bytes `[direction][X word][Y word][direction]`: `forced_walk.asm:4, 54–60` (`ApplyScrollOffset` advances the pointer by 4 between the two direction reads).
  - Data: 200 `stair-warp` rows; byte `+6` has bit 7 set in **100** rows (`$80–$8F`) and is `$40–$4F` in **100** (bits 4/5 never set, so `ForcedWalkEast/West` are unreachable from this table, static); pan nibble `$00` 143, `$03` 11, `$02` 10, `$01` 5, `$0D` 5, `$0E` 5, 21 others. Byte `+7` (first stream direction) is `$00` in all 100 north rows and `$02` in 98 south rows; `$04` and `$05` occur once each, both in `warp_def_03` (lines 326, 327), as the note says. Example `warp_def_E3` (2204: window `$4430`, south, stream `02 / 0000 / $0108 / 03`, 264 px) and entry `;01` (2205: `$80` north, Y offset `$FF10` = −240 px) match the decode.
- **(c) scene_meta group counts:** `music < track, group, @bgm >` has 234 uses, group `$00` ×225, `$01` ×5, `$02` ×4 (§3). Also: 231 records, 231 `display-mode`, 2052 commands (231 + 319 + 278 + 300 + 383 + 56 + 234 + 18 + 56 + 176 + 1), 56 label definitions and the 8 unused ids `$00 $0A $12 $13 $14 $21 $34 $35`, 25 + 8 = 33 null pointers in the two lists, the top jump targets `$22` 18, `$31` 14, `$18` 14, `$2C` 11, `$29` 9, and the six sample-record notes.
- **(d) enemy_stats_table byte 3:** see A07-06. `EnemyDefeatDispatch.asm:1–10` carries the I051 correction (gem pickup, not HP/STR/DEF) and agrees with `StandardEnemyDefeatHandler.asm:170` ("not, as the old note said, when the flag is clear"). The table: 110 rows (`109992 − 109552 = 440 = 110 × 4`), 18 all-zero rows, 92 with stats, DEF `$7F` ×21, DEF `$FF` row `$46`, HP `$FF` rows `$21`, `$22`, the rows named by code (verified against the `statsPtr` operands), and the damage formulas in the field table (`max(1, ATK − playerDef)`, 60 frames of invulnerability, `rawDamage = max(1, totalStr − DEF)` plus `characterForm`, `PlayerAttackHitTest` does not read DEF) agree with `combat_collision.asm`.
- **(e) blocks.json block names:** the two blocks in `db-us/blocks.json:1002–1042` are `display_preset_table` (line 1002, `98304–98868`, `&display-preset`) and `item_pickup_text_table` (line 1042, `130340–130924`, `&DialogString`). Each has an extracted file of the same name and the same range in its header (`display_preset_table.asm:1`, `item_pickup_text_table.asm:1`). All other blocks in the `tables` group of the 12 files match their file names too (`scene_warps` `98868–108894`, `enemy_stats_table` `109552–109992`, `dialog_template_table` `117397–117670`, `parallax_scroll_table` `117760–119758`, `scene_meta` `884736–897023`, `spriteset_npc_props` `973312–974144`, `spriteset_transform_poses` `1032192–1043845`, `spriteset_shadow` `1343488–1355931`, `spriteset_aura` `1544192–1544618`, `spriteset_darkgaia_projectile` `1560576–1561584`). `extracted/tables/` holds 37 files; no block lacks a file.
- **`parallax_scroll_table`:** 37 pointers = 22 blobs (`$00–$08`, `$0A`, `$0B`, `$0E`, `$1B–$24`) + 15 pointers to 14 shared `$FFFF` words (`$09` and `$19` share one); band decodes recomputed from the bytes; the reader thinker was not re-read in this step. No finding.
- **`spriteset_shadow`:** 76 animations, 261 frame records, 168 groups (all referenced: 168 distinct group labels in the frame lists), 1273 sub-sprites, max 14 per group, all 168 groups have the default attack box, and the byte budget 152 + 4 × 261 + 2 × 76 + 13 × 168 + 7 × 1273 = 12443 = `1355931 − 1343488`. Holds of `$18` (9, 6, 4, 9), `$1C` (11 frames, 0 1 2 3 4 1 2 3 2 1 0), `$3E` (7 frames, 3 1 8 4 3 3 8), melee `$36` (3 2 1 0 0 1 2 = 16 ticks), guard `$3A` (8 frames of 0), `$44–$46`, `$4A`, `$4B` (one frame of 0), and the example group `148544` all match. "`$3E-$41` not staged by the player scripts" holds (0 hits, §3). No hidden group (class 8): the budget closes without extra bytes.
- **`spriteset_aura`:** 3 animations, 12 records, 12 groups, 30 sub-sprites (all 12 with the default attack box), every tile word in `$0440–$046F` (0 outside), bytes 6 + 3 × 18 + 12 × 13 + 30 × 7 = 426; art DMA `$0600` bytes (48 tiles) from `misc_fx_1CC480` to `$4400` (`attack_ability_system.asm:430`); `AuraOrbitalSpawner` spawns 2 or 4 (`$0B1E`, lines 439–448); stage order of `AuraProjectileChild` / `AuraProjectileShrink` (lines 552–569) matches the note. (Palette cycling: A07-02.)
- **`spriteset_darkgaia_projectile`:** 8 animations, 12 groups of 9 sub-sprites (all with the default attack box), 16 + 80 + 912 = 1008 bytes; the four `Projectile*` actors stage launch `#00–#03` with `MoveY #09 / #0A`, `MoveX #0A / #09` and travel `#04–#07` with `#0F / #10 / #10 / #0F` (`player_character.asm:1850–1904`); each travel list is the last group of its launch list; they are spawned only through `SpawnListAppend ( @Projectile*, ..., #$0602 )` (lines 1513, 1576, 1638, 1700). The statement "only in scene `$E8`" belongs to the `Attack*` pieces (REPORTED from I025, A07-24).
- **`spriteset_transform_poses`:** 19 animations, 697 records, 148 printed groups, 981 sub-sprites; budget 38 + 2788 + 38 + 8789 = 11653 = `1043845 − 1032192`, where the printed rows give 8791 and the two hidden-group artefacts (rows `;07–;10` of `0FCF27` and `0FD5AA`, one byte too long each: 17 printed rows − 7 real = 10 rows = 70 bytes for a 69-byte group) account for the difference of 2. Hidden-group header `0FCF65` / `0FD5E8` addresses are right (`0FCF27 + 62`, `0FD5AA + 62`), and neither name is referenced anywhere (`rg "0FCF65|0FD5E8"` = notes only). Class 8 is therefore documented, not hidden.
- **`item_pickup_text_table`:** 64 pointers, strings and the five wrappers sum to 584 bytes (`130924 − 130340`); blank entries `$00 $0B $0C $0D $0F $11 $12` and 29 ids `$1B–$37`; `$15–$19` share the Teapot string; consumers: `inventory_mgmt.asm:216, 235`, `combat_collision.asm:1563`, `warps_interaction.asm:328, 347, 356, 379`; `[ADR:...,DB8]` = `DialogCmd_IndirectString` (`DialogStringRenderer.asm:302–321`); `[DLY:n]` = n + 2 frames per character (`:953–961`, `WaitNFrames_Loop` 1088–1096), `[PAU:FF]` = 255 ticks (`WaitFrames` → `WaitNFrames_Entry`; the loop decrements first, so `$FF` = 255 ticks, **not** n + 1); `COP #D4` ignores Y (`cop_handlers_inventory.asm:21`); item names `$01–$28` agree with `docs/ram_map.txt:155–194`.
- **`display_preset_table`:** 47 records of 10 bytes (`98868 − 98304 = 564 = 94 + 470`), every value histogram of the note recomputed from the file (bytes `+0` to `+9`, 18 distinct `+3` values, 21 records with `+4` bit 6, 20 with bit 7 clear), the two mode-7 presets (`$19`, `$2D`), and the byte meanings against `SceneCmd_ConfigDisplay` (`scene_script.asm:1156–1280`, including "bit 7 of `+7` sets `hudDisableFlag` `$40`" and "`+8` / `+9` loaded and discarded").
- **Single-user claims:** `spriteset_aura` (only `AuraProjectileChild`, `rg -n "spriteset_aura" extracted baserom --glob "*.asm"` = 1 user), `spriteset_darkgaia_projectile` (only the four `Projectile*` actors), `spriteset_transform_poses` (only `body_table` row `$05`, selected only by `sE6_gaia`).
- **Class sweeps.** Class 2: `WaitByte` / `WaitWord` / `WaitFrames` text in the 12 files: 1 hit, `item_pickup_text_table.asm:181` (`[PAU:FF]` = 255 frames, correct). Class 12: none (no transform concerns these files). Class 13: no button vocabulary (the one hit, `item_pickup_text_table.asm:186`, is "waits for a button", generic). Class 8: handled (above).

### 2.5 Reported, not re-checked

**A07-23 · REPORTED · L.** `tables/enemy_stats_table.asm:21`: "16 rows with stats are neither used by a scene spawn record nor named by code ($06 $07 $09 $1F $20 $21 $22 $38 $39 $3B $40 $41 $4B $52 $53 $59)". It needs a census of byte 6 over all enemy-spawn records of `scene_actors` (about 3,100 records) and was not recomputed. Source: `results/I066_results.md`.

**A07-24 · REPORTED · L.** "Only in scene `$E8`" for the `Projectile*` actors (`spriteset_darkgaia_projectile.asm:1`, `player_character.asm:40, 1845`): the `SpawnListAppend` sites and flags `$0602` were seen (§2.4), the restriction to the Dark Gaia scene is the claim of the `Attack*` pieces from I025 and was not re-traced. Source: `edits/I025.json`.

---

## 3. Not verified / needs Mesen2

1. **Aura palette (A07-02):** which of `$A1–$A8` and `$A9–$AF` the 30 sub-sprites actually use per frame, and what the cycle looks like on screen. Static only: the tile words say palette 2, the colour numbers inside the 4bpp tiles were not decoded.
2. **Dialog cursor (A07-08):** the visible effect of the cursor reload after `[TPL:08]`–`[TPL:11]` (the box templates) versus the speaker templates; static only.
3. **Stale `?INCLUDE 'table_018000'` (A07-17):** whether the build resolves it, ignores it, or would fail without it. Needs `npm run rebuild` in a state where the include is removed, which this step may not do.
4. **Dialog colours:** which of the two colour words is glyph and which is outline (`dialog_template_table.asm:28`); how the template colours look in game.
5. **Art and tiles:** tile graphics of the Aura set (OBSEL name base, OQ-I066-3), of the Dark Gaia projectiles (OQ-I067-3) and the look of the `npc_props` images (OQ-I068-1). The VRAM `$4400` = tile `$40` statement in `spriteset_aura.asm:15` assumes name base `$4000`.
6. **`warp_def_03`** with first stream bytes `$04` and `$05` (OQ-I068-4): what the walk does.
7. **Display presets per scene** (OQ-I068-3), **which warp uses which pan list** (OQ-I064-1) and **template `$07`/`$10` strings** (whether the two pink-colour uses and the "house description" strings are all of them): static counts only.
8. **Hold timing** of the `sprite-set` records: "hold n = n + 1 ticks" (used in six of these files) was taken from the A06 check of `cop_handlers_sprite.asm`, not re-traced here.
9. **Group selector `[SFX:0]` = silent** (`dialog_template_table.asm:6`): the renderer ORs `$0996` into `sfxQueueCh1` (`DialogStringRenderer.asm:148–150`); whether `0` produces no sound depends on the queue consumer (not traced).

Negative-proof and count commands run (all static; none is runtime):

| Claim | Command (from `gaia-iog-baserom`) | Result |
|-------|-----------------------------------|--------|
| template uses per id | `rg -P -o --no-filename "(?:^(?!\s*;)\|\G(?!^))(?:(?!\[TPL:X\]).)*?\K\[TPL:X\]" extracted \| rg -c "TPL"` for X = `0`–`F`, `10`–`15`, against `rg --stats --count-matches "\[TPL:X\]" extracted` | 21 ids equal the note; `$11`: 37 vs whole-file 51 (note 49) |
| comment mentions of `[TPL:11]` | `rg -c "^\s*;.*\[TPL:11\]" extracted` | 12 (`world_map_options.asm`) + 2 (`dialog_template_table.asm`) |
| scene_meta command counts | `rg --stats --count-matches "^\s+<mnemonic> < " extracted/tables/scene_meta.asm` for the 10 mnemonics, `^\s*meta_label_[0-9A-F]+:`, `^scene_meta_[0-9A-F]{4} \[` | 231 / 319 / 278 / 300 / 383 / 56 / 234 / 18 / 176 / 1; 56 labels; 231 records |
| scene_meta music groups | `rg -o '^\s+music < #[0-9A-F]{2}, #([0-9A-F]{2}),' -r '$1' extracted/tables/scene_meta.asm \| sort \| uniq -c` | `00` 225, `01` 5, `02` 4 |
| scene_meta tilemap operands | `rg -o '^\s+tilemap < #([0-9A-F]{2})' ...` | `01` 225, `02` 158 (sum 383, the `tilemap` total above) |
| jump / branch targets | `rg -o --no-filename '^\s+jump < #([0-9A-F]{2}) >' -r '$1' ... \| sort \| uniq -c \| sort -rn` | `22` 18, `31` 14, `18` 14, `2C` 11, `29` 9 |
| unused label ids | `rg -q "^\s*meta_label_$h:"` for h = `00`–`3F` | `00 0A 12 13 14 21 34 35` have no definition |
| null pointers in the two lists | `rg -c '#\$0000   ;' extracted/tables/scene_meta.asm` | 33 = 25 + 8 |
| `SceneScriptNoMusic` users | `rg -n "SceneScriptNoMusic" extracted` | `inventory_overlay.asm:151, 232` (+ comments) |
| display preset values | `rg -o --no-filename "display-preset < (?:#[0-9A-F]{2}, ){k}#([0-9A-F]{2})" -r '$1' ... \| sort \| uniq -c` for k = 0–9 | every histogram of the note; 21 / 20 bit counts |
| `scene_warps` fields | `rg -o '^\s+stair-warp < ...' -r '$1'` etc. (byte `+6`, `+7`; scene-warp facing byte, window, destination `E6`) | 543 scene-warps, 200 forced-walk; facing `03` 229, `00` 225, `06` 32, `07` 32, `01` 2, bit 7 on 23 (`80` 11, `83` 9, `87` 2, `86` 1); 61 distinct windows (`1100` 86, `4400` 84); window `$0000`: 0; 36 to scene `$E6` all `(120,192) 0 $1100`; 71 + 9 + ... = 100 with bit 7 (`$8x`), 100 with `$4x`; `+7`: `02` ×98 south, `00` ×100 north, `04` ×1, `05` ×1 (the first `rg` without the `^\s+` anchor also matches the example in the block note, line 19, which is why the unanchored counts read +1) |
| 8 empty lists, 51 shared | `rg -U -c '^warp_def_\w+ \[\r?\n  warp-def < \[\r?\n  \], \[\r?\n  \] >'`, `rg -c "^\s+&warp_def_empty "` | 8 (`empty 02 09 14 2F EA EB FE`); 51 |
| X tile ≥ `$80` | `rg -c '^\s+(scene\|stair)-warp < #[89A-F][0-9A-F],' extracted/tables/scene_warps.asm` | 0 hits |
| shadow structure | `rg --stats --count-matches` of `^\s+sprite-set <`, `^sprite_group_[0-9A-F]+ \[`, `^\s+sprite-part <`, `^shadow_anim_...`; `rg -o '^\s+sprite-set < ... &(sprite_group_[0-9A-F]+) >' \| sort -u \| rg -c ""` | 261, 168, 1273, 76; 168 distinct referenced groups |
| shadow `$3E–$41` not staged | `rg -c "COP \[(StagePlayer[A-Za-z]*\|RunPlayerAnim)\] \( #(3[EF]\|4[01])[,) ]" extracted --glob "*.asm"` | 0 hits |
| `$10–$13` staged by the player | `rg -n "COP \[(StagePlayer[A-Za-z]*\|RunPlayerAnim)\] \( #1[0-3][,) ]" extracted --glob "*.asm"` and `rg -n "\( #1[0-3][,) ]" extracted/actors/player/player_character.asm` | 7 `StagePlayerSprite` sites; plus `StageSpriteLoopMoveY/X` and `StageSpriteFrame` at 1397–1418 (A07-03) |
| row `$05` selectors | `rg -n "SetPlayerSpriteDirect\] \( #05" extracted \| rg -v sE6_gaia` | 0 hits |
| transform-pose hidden groups unreferenced | `rg -n "0FCF65\|0FD5E8" extracted baserom db-us docs` | 2 hits, both in the two notes of `spriteset_transform_poses.asm` |
| `npc_props` users | `rg -n -A 3 "spriteset_npc_props" extracted` and per file `rg -n "Stage[A-Za-z]*\]\|SetMetasprite\|SetSpritePriority"` for `fr32_locked_door`, `fr32_kidnapper`, `mu63_spirits`, `btE4_olman`, `fr32_guide` | 25 actor files name the set; 3 missing from the table (A07-05); no `#03` / `#09` operand under the set |
| Dark Gaia projectile spawn sites | `rg -n "@Projectile(South\|North\|West\|East)" extracted` | 4 sites, flags `$0602` |
| retired names `table_018000` etc. | `rg -n -i "item_get_dialog_table\|itemget_table\|spriteset_will_projectile\|spriteset_ability_fx\|table_018000\|table_179000\|table_17D000\|..." extracted baserom src db-us docs` | A07-16, A07-17 (the three renamed blocks themselves: no hit outside the plan files and `renames/`) |
| history / ids sweep | `rg -n -o -i "(the )?old (note\|header\|description)[^.]{0,60}\|was (wrong\|too broad)\|OQ-[A-Za-z0-9-]+\|R-I[0-9]+-[0-9]+\|UNVERIFIED[-A-Z]*\|first audit pass\|Checked:" <12 files>` | A07-18, A07-19; 0 for `UNVERIFIED` / `Checked:` |
| class 2 / 10 / 13 sweeps | `rg -n "WaitByte\|WaitFrames\|WaitNFrames"`, `rg -n -i "stair\|liquify\|psycho\|ability_fx\|will_alt\|shadow_mode\|table_[0-9A-F]{6}\|chunk_\|func_0\|actor_0\|thinker_0"`, buttons | 1 hit (correct); `stair-warp` and the 3 history mentions of `Psycho`; 0 buttons |
| unnamed operands | `rg -n "^!\w+\s+(0DB8\|0998\|00D4\|00D6\|0AF4\|7F0020)" extracted` | only `reviveWarpPtr` (`0AF4`) and `statsPtr` (`7F0020`) exist |

Process deviations (disclosed): the counting commands above use shell pipes (`sort`, `uniq`, `tr`, `head`, `cut`) and `for` loops around `rg`, as A06 did; one `wc -l` and one `sed -n` (to print scene_meta lines 343–376 and the `scene_meta_0004/0005/0007` jumps) were run early on in the step and `head -c` / `cut` to print the first line of five files. All are read-only, none touches names, notes, comments, `blocks.json`, `files.json` or docs. No script was written and no sub-agent was used.

---

## 4. Items for the fix specs

| F-step | Findings | Notes |
|--------|----------|-------|
| **F01** (existing, `scene_script.asm` notes) | A07-01, 10, 11, 12, 17 (the four `table_018000` lines 15, 71, 1159, 1161) | Add to F01's list: the inverted comment at 1303 (also the `SpcMusicLoadCmd` item), the part note at 227 (five retired handler names), block note rows 17–19, headers at 646 and 687, line 1378 (VRAM → WRAM), the `SceneCmd_Label` header at 277. All are comments / part notes of the same file, so one `merge` spec fixes them. |
| **F02** (existing, WaitByte n + 1 and `warps_interaction`) | A07-14 | `InitWarpTable` header "non-$FF byte"; same file as the existing F02 target. `[PAU:FF]` (255 ticks) is correct and needs no change. |
| **F03** (existing, row-5 drift) | A07-16 (`body_table.asm:32`) | One more line in the `body_table` edit; A06-15 and A06-01 are on `body_table.asm:37`. |
| **F05** (existing, docs) | A07-17, A07-16 (docs part) | Stale `table_018000` (14 lines in 5 docs), `itemget_table_01FD24` (3 docs), `table_179000` (`bank02/player-character.md:93`), `table_17D000` (`bank02/README.md:169`). Also extend report §4.4's retired-name list with these names. |
| **F06 / A14** | A07-21 | `stair-warp` struct name in user-owned `db-us/structs.json`. |
| **F07** (proposed in A06) | A07-03 (sibling claims in `spriteset_freedan` and `spriteset_will`) | Check the same "Shadow only" wording in the other two player spritesets when F07 is written. |
| **F08 (proposed, new)**: "I065–I068 note corrections" (`merge` spec) | A07-02, 03, 04, 05, 06, 07, 08, 09, 13, 15, 16 (the two actor comments), 18, 19, 20, 22 | Target files: `dialog_template_table`, `scene_meta` (`$06` row, `$04` row id), `enemy_stats_table`, `spriteset_aura`, `spriteset_shadow`, `item_pickup_text_table`, `spriteset_darkgaia_projectile`, `spriteset_transform_poses`, `spriteset_npc_props`, `display_preset_table`, `scene_warps`, plus the `DialogStringRenderer` `DialogCmd_InsertTemplate` header, and two inline comments in `attack_ability_system` (lines 114, 552) and one in `player_character` (line 1850). Remove history, ids and process narration in the same pass as the factual fixes so each note is edited once. Rebuild gate after the merge. |
| **A12** | A07-19, 23, 24 | The OQ ids `OQ-I065-1`, `OQ-I066-1..3`, `OQ-I067-1..5`, `OQ-I068-1..4` stay in the registry; the note text drops them. |
| **A13** | A07-22 | Name candidates for `$00D4`, `$00D6`, `$0DB8`, `$0998`, `$0996`. |
| Plan-level | none | `PLAN.md` has no F08 row; this step does not add one (only the A07 row is edited). |

---

## 5. Counts

| Item | Count |
|------|-------|
| Files checked | 12 |
| Block notes checked | 12 of 12 |
| Part notes read / checked against code or data | 94 of 94 read; about 80 (85 %) checked, 14 listed in §1.4 |
| Findings | 24: 22 VERIFIED, 2 REPORTED |
| By severity | H 1 (A07-01), M 8 (A07-02, 03, 04, 05, 06, 08, 09, 10), L 15 |
| By class | 3: 4 (A07-10, 15, 16, 17); 4: 2 (A07-18, 20); 5: 4 (A07-04, 05, 06, 12); 6: 5 (A07-01, 08, 11, 13, 14); 7: 1 (A07-19); 9: 1 (A07-22); 10: 1 (A07-21); 11: 3 (A07-02, 03, 07); n/a: 3 (A07-09, 23, 24) |
| Hygiene sites | history narration 12 lines in 11 files; ids in the lines listed in A07-19; process narration 2 lines; `UNVERIFIED` / `Checked:` 0; retired-name lines: 4 in `scene_script.asm`, 1 in a patch, 13 + 3 + 2 in docs |
| Negative-proof / count rg commands recorded | 23 (§3 table) |
| Check (a) scene_meta handler names | 12 of 12 pairs agree; stale text in 7 places (A07-10) |
| Check (b) scene_warps second list | all claims hold: 200 vertical, 100 / 100, strides 12 / 13, terminators, stream layout; 1 handler-comment imprecision (A07-14) |
| Check (c) scene_meta groups | 225 / 5 / 4 = 234 (confirmed) |
| Check (d) byte 3 gemDropType | router side right; second reader missing from the note (A07-06); I051 correction confirmed |
| Check (e) block names | both match (`display_preset_table`, `item_pickup_text_table`); 12 of 12 ranges match the file headers |
| Defect-class sweep | class 2: 1 hit, correct; class 8: documented in `spriteset_transform_poses`, none hidden elsewhere; class 12: none; class 13: 0 |
| Wrong hardware reading | 0 found (the BGR555 colour words recomputed in §1.4 match; no other hardware register claim is made in these 12 files except the VRAM/CGRAM destinations checked in A07-02 and the display-preset bytes) |
| Edits made | none (this file and the A07 row in `PLAN.md` only) |
