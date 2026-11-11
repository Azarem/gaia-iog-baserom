# A06 findings: sanity-style re-verification of I061–I064 and B001

Step: A06 of the audit of the audit. Inputs: `digest_I041-I072.md` (I061..I064 and B001 sections), `report.md` §3, §7, §8, the I061–I064 and B001 results, renames and edit specs, and the live files under `extracted/`.
Nothing was edited except this file and the A06 row of `PLAN.md`.

**Evidence level.** Every behavioural statement below is static (E1 code trace or E2 cross-reference). There is no Mesen2 ROM or save state, so nothing is E5. Where a claim needs runtime proof it is in "Not verified / needs Mesen2".
**Tags.** VERIFIED = checked in the live files this session, with file:line. REPORTED = taken from a ledger or the report, not re-checked.
**File names.** The step prompt uses retired names. The live files are: `direction_velocity_table` → `walk_step_table`; `forced_walk_sequence_table` → `forced_walk_pan_table`; `ability_anim_tables` → `ability_damage_tables`; `movement_delta_table` → `move_chain_table`; `spriteset_field_fx` (Bank 14 `14C0CA`, I062) → `spriteset_adrift_wave`; `spriteset_particle_fx` (`1360172-1360280`, I063) → `spriteset_snake_pit_fx`; `spriteset_town_objects` (`1359872-1360072`, I064) → `spriteset_freejia_tilefx`. The mapping comes from the file headers of `results/I062..I064_results.md` and the `blocks.json` ranges (`db-us/blocks.json:1053-1055`). All paths below are under `extracted/` unless stated.

---

## 1. Scope and files read

### 1.1 Files checked (16)

| # | Live file | What was read |
|---|-----------|---------------|
| 1 | `tables/walk_step_table.asm` | whole file |
| 2 | `tables/body_table.asm` | whole file |
| 3 | `tables/scene_actors.asm` | block note (lines 1–27), the default list, scenes `$91`, `$A7`, `$FF`, and whole-file counts by rg |
| 4 | `tables/ability_damage_tables.asm` | whole file |
| 5 | `tables/forced_walk_pan_table.asm` | whole file (all 16 lists recomputed) |
| 6 | `tables/move_chain_table.asm` | block note, pointer table, node and chain counts by rg; chain content only partly |
| 7 | `tables/shared_word_table.asm` | whole file |
| 8 | `tables/spriteset_freedan.asm` | block note (1–19), part note (26–47), example group; staging proofs |
| 9 | `tables/spriteset_will.asm` | block note (1–14), part note (21–35), example group |
| 10 | `tables/spriteset_adrift_wave.asm` | whole file |
| 11 | `tables/spriteset_snake_pit_fx.asm` | whole file |
| 12 | `tables/spriteset_freejia_tilefx.asm` | whole file and its user `freejia/freejia/fr32_laborer_npc.asm` |
| 13 | `system/boot_logos/spm_boot_logos.sprite.asm` | block note, part count, holds |
| 14 | `system/title_screen/spm_title_actors.sprite.asm` | block note, 48 parts, `sFC_title_intro.asm:59-67` |
| 15 | `system/dark_space/spm_darkspace_sprites.sprite.asm` | block note, holds, frame counts, `#0A` |
| 16 | `system/world_map/spm_overworld_sprites.sprite.asm` | block note, 6 of the animation bullets |

### 1.2 Code and docs read to check the claims

`system/engine/`: `combat_collision.asm`, `tile_collision_physics.asm`, `cop_handlers_collision.asm`, `cop_handlers_sprite.asm`, `cop_handlers_player_sprite.asm`, `cop_handlers_effects.asm`, `cop_handlers_movement.asm`, `sprite_composition.asm`, `GetPlayerFacingDirection.asm`, `forced_walk.asm`, `actor_pool.asm`, `slider_glide.asm`; `actors/actor_execution.asm` (`InitActorFromSceneData`), `actors/player/attack_ability_system.asm`, `actors/player/player_character.asm`, `actors/player_transition_handlers.asm`, `actors/jeweler_gem.asm`, `euro/flea_market/eu97_dark_medicine.asm`, `system/dark_space/sE6_gaia.asm`; `docs/structs-reference.md`; `db-us/blocks.json`; the retranslation modules (`IOGRXLT/IOGRetranslation/modules`, read-only rg).

### 1.3 Ledgers read

`audit-of-audit/PLAN.md`, `report.md`, `digest_I041-I072.md`; `results/I061..I064_results.md`, `B001_results.md`; `renames/I063_renames.md`; `edits/B001.json`, `edits/I063.json`.

### 1.4 Coverage of "check every note line by line" (≥ 60 %)

Unit = a comment paragraph in the extracted file: 16 block notes, plus part notes counted by their `-----` separators (88).

| Group | Checked line by line | Not checked |
|-------|----------------------|-------------|
| Block notes | 16 of 16. Partial for `move_chain_table` (counts and chain lengths yes, 50 of 85 chains' content no) and `spm_overworld_sprites` (6 of its animation bullets). | see below |
| Part notes | about 78 of 88 (89 %) | about 10, listed below |

**Not checked (listed as required):**
1. `move_chain_table` part notes for chains after `$17` (about 8 notes) and the node values inside them. Only the counts, the family lengths and the callers were checked.
2. `scene_actors` part notes for the individual scene lists other than the default list, `$91`, `$A7`, `$FF` and the extract table (2 notes). The list body (about 4,700 lines) was checked by counts only.
3. `spm_overworld_sprites` animation bullets other than `#00`, `#06`, `#07`, `#0B`, `#0C`, `#0D` (the box sizes and part counts).
4. `spriteset_freedan` and `spriteset_will` per-index table rows (frame counts and holds per index); only the idle, walk and moving rows were checked.
5. The citation "attack_ability_system lines 1628-1672" in `ability_damage_tables` was read (1628–1672 are the two loaders) but the other lines of that file that the note's table cites were not.
6. The 58 / 26 split of chain endings in `move_chain_table` (see A06-20).

---

## 2. Findings

Severity: H = wrong fact a reader would act on; M = wrong or stale fact, limited effect; L = imprecision or hygiene. Defect class numbers are from PLAN.md (n/a = no class fits, a plain counting or reading error).

### 2.1 Wrong or incomplete facts

**A06-01 · VERIFIED · H · class 11**
`tables/body_table.asm:37`: "rows 0-3 and 8 use FacingDirectionLookup" is wrong for row 8.
Code (`system/engine/GetPlayerFacingDirection.asm:66-83`): with playerFlags bit 15 set, `$0AC8` = 8 gives `8 − 4 = 4`, which is not negative, so the `BMI` fallback is not taken. `ASL` makes X = 8 and the code reads `FacingFormOffsetTable + 8`. That table has only 4 pointers (8 bytes, lines 95–99), so offset 8 is the first data bytes of `FacingData_WillAlt` (`$00 $01`, line 102), read as a pointer. The code then indexes with `pointer − table base + animation frame`: an out-of-range read, not a lookup in `FacingDirectionLookup`.
Row 8 is set by `SetPlayerSpriteDirect #08` (`actors/player_transition_handlers.asm:222`, Aura transform). Whether `GetPlayerFacingDirection` runs while row 8 is active is not shown (static only).
Fix: state that rows 4-7 index `FacingFormOffsetTable` (`$0AC8 − 4`), rows 0-3 fall back, and row 8 is not covered by either (index 4 is past the end of the 4-entry table). Keep it as a fact; the runtime question goes to the OQ document. Spec: F03 part 1 (same line is already a target) plus F07.

**A06-02 · VERIFIED · H · class 11**
B001's "four readers" of group-header bytes 4–7 (the box read at `metaspritePtr+0..3`) is incomplete. `system/engine/tile_collision_physics.asm` reads the same four bytes at 8 sites (`LDA $0003, Y` at line 393, and the sites at 481, 598, 621, 703, 788, 891, 914). Its own header documents them (lines 34–42, "HITBOX DATA ... `[metaspritePtr]`": X offset, Y offset, width and height in tiles, `ORA #$FF00`). That is the movement/wall collision, the most frequently run reader.
The block notes name only "PlayerAttackHitTest and the solid-rectangle COP handlers":
- `tables/spriteset_freedan.asm:9`
- `system/boot_logos/spm_boot_logos.sprite.asm:13`
- `system/title_screen/spm_title_actors.sprite.asm:13`
- `system/dark_space/spm_darkspace_sprites.sprite.asm:20`
- `system/world_map/spm_overworld_sprites.sprite.asm:23`
The four readers B001 named are all confirmed (see §2.4); the list is just not complete.
Fix: add "and by the tile collision code (tile_collision_physics, the player and actor wall tests)" in the five places. Spec: F07.

**A06-03 · VERIFIED · M · class 2**
Hold `$63` is 99, so the frame lasts 100 ticks. Two notes say 101:
- `tables/spriteset_freedan.asm:30`: "1 frame, hold $63 (101 ticks)"
- `tables/spriteset_will.asm:6`: "Freedan's idle is a single frame held 101 ticks"
`spm_darkspace_sprites.sprite.asm` states the same `$63` as 100 ticks (correct). `rg -c "sprite-set < #\$0063" tables/spriteset_freedan.asm` = 8 holds of `$0063`. The rule (hold n = n+1 ticks) is stated correctly on `spriteset_freedan.asm:6`. All other tick figures in the 16 files check out (`$77` = 120, 4 = 5, 5 = 6, 7 = 8, 9 = 10, snake pit 6 × 6 = 36, adrift 4 × 8 = 32, freejia 4 × 8 = 32 and 4 × 7 = 28, boot logo `$3B` = 60, title `WaitByte #B3/#77/#3B` = 180/120/60).
Fix: 101 → 100 in both. Spec: F07 (or F02, which is the WaitByte n+1 spec).

**A06-04 · VERIFIED · M · n/a (count)**
`tables/scene_actors.asm:25`: "16 lists do not start with the player", but the sentence lists 17 ids: `$00 $9F $59 $89 $8C $8D $8F $90 $C0 $F0 $F7 $FA $FB $FC $FD $FE $FF`. The count is also inconsistent with line 23: 241 records − 224 starting with the player = 17. (`rg -c "PlayerCharacterDef.*;00"` over the file gives 224, which includes the default list, so own lists with a player are 223, not "224 of 240".)
The I061 ledger text "224 of 240 own lists; 14 + 2" is the origin (REPORTED there, wrong).
Fix: 16 → 17 on line 25; line 23 can stay (224 includes the default list: say so). Spec: F07.

**A06-05 · VERIFIED · L · n/a**
`tables/scene_actors.asm:4734`: "three inventory_statue_slot actors". The record has six (lines 4738–4743, records `;01`–`;06`, attributes `$21 $03 $05 $27 $09 $0B`). Fix: three → six, and list the six parameters `$10 / 1 / 2 / $13 / 4 / 5` (attribute `>> 1`: `$21`→`$10`, `$03`→1, `$05`→2, `$27`→`$13`, `$09`→4, `$0B`→5). Spec: F07.

**A06-06 · VERIFIED · M · class 3**
`tables/scene_actors.asm` block note uses retired or never-existing names:
- line 5: `scene_event_0CXXXX` (live labels: `scene_NN_actors`, `scene_default_actors`, `scene_NN_actors_value`; `rg -c "scene_event_0C"` = 1 line)
- lines 5 and 16: `0C8200` (the live label is `scene_default_actors`, line 896)
- line 17: `0CC7A1` and `0CBDC4` (live: `scene_A7_actors` line 3582, `scene_91_actors` line 3207)
Fix: replace each with the live label. Spec: F07.

**A06-07 · VERIFIED · M · class 11**
`tables/ability_damage_tables.asm:14`: "The level word is written by the jeweler_gem rewards (Psycho Dash level 1 at 20 jewels, Dark Friar level 2 at 30)". Incomplete:
- `rg -n -e 'STA \$0B16' -e 'STA \$0B18' -e 'STA \$0B1A' -e 'STA \$0B1C' -e 'STA \$0B1E' -e 'STA \$0B20' extracted --glob "*.asm"` returns three stores: `actors/jeweler_gem.asm:312` (`$0B16`), `jeweler_gem.asm:323` (`$0B1C` = 2) and `euro/flea_market/eu97_dark_medicine.asm:44` (`$0B1C` = 1, with `SetFlagByte #F1`).
- So Dark Friar level 1 is set by the dark medicine, which the note does not mention.
- `$0B18`, `$0B1A`, `$0B1E`, `$0B20` have no direct `STA` anywhere in `extracted/`; how those four reach the loaders is not stated in the note and not found (flag COPs or another store form: needs a wider search or runtime).
Verified OK in the same note: the six records byte by byte against `LoadAbilityDamageA/B` (`attack_ability_system.asm:1628-1672`: record+2 = level-word pointer, record+4+level = damage; record+0 never read), the `$09E0`/`$09E2` stores (lines 1647, 1671), and the `combat_collision.asm:39, 766-780` use.
Fix: name `eu97_dark_medicine` as the second writer of `$0B1C`, and say the other four level words have no direct store in the extracted code. Spec: F07.

**A06-08 · VERIFIED · L · n/a**
Range headers use two different end conventions.
- `tables/ability_damage_tables.asm:1`: "121255-121278" is Will's part only (24 bytes). The block runs 121255–121303 (`db-us/blocks.json:1014-1018`: parts end at 121279 and 121304, exclusive).
- Inclusive end (last byte): `walk_step_table` 109551, `body_table` 121254, `move_chain_table` 115587.
- Exclusive end (`blocks.json` value): `forced_walk_pan_table` 109278 (`:1`), `shared_word_table` 125864 (`:1`, blocks.json:1034), `scene_actors` 845285 (`:1`).
Fix: use one convention (inclusive last byte) and fix the ability range to 121255-121303. Spec: F07.

**A06-09 · VERIFIED · M · class 11 (imprecision)**
`tables/spriteset_freedan.asm:47` and `tables/spriteset_will.asm:35`: "Not staged by the player scripts: $14-$17, $1C-$29, $3E-$41 (, $4A, $4B)". The sentence contradicts itself and the code:
- `$14–$17` are staged: `actors/player/player_character.asm:1420, 1427, 1432, 1434` and `system/engine/slider_glide.asm:298, 326` (`StageSpriteFrame #14/#17`). These run under body row 4 (`SetPlayerSpriteDirect #04` at `player_character.asm:1373, 1408`), so the animation index is read from `spriteset_will_abilities`, not from the Will or Freedan table. The claim is therefore true for these two tables only, and the note does not say so.
- `$1C, $1E, $1F, $21, $24, $26–$29` are staged at: `player_transition_handlers.asm:145, 193–200, 308`, `player_character.asm:554, 731, 747, 840, 850`, `sF7_credits_player.asm:123–133`, `sE8_dark_gaia.asm:883`, `sE5_epilogue.asm:173`, `btE4_kara.asm:184`, and the ramps code. The Freedan note's own second sentence admits "several of $1C-$29 are staged"; which body row is active at each site was not resolved (OQ-I063-2).
- `$10–$13` "staged for Shadow only" (`spriteset_will.asm:29`, `spriteset_freedan.asm:34`): `StagePlayerSprite #10–#13` are at `player_character.asm:238-271` (Shadow idle) and `player_transition_handlers.asm:59`, `sF7_credits_player.asm:103, 108` (all under the Shadow body); the Psycho Slider code at about `player_character.asm:1396–1417` also uses `$10–$13`, under body row 4. "Shadow only" is therefore also a body-row statement, not a statement about these tables.
- "`$04–$07` nothing found stages them" holds: `rg -n "COP \[(StagePlayer[A-Za-z]*|RunPlayerAnim)\] \( #0[4-7][,) ]" extracted --glob "*.asm"` = 0 hits. The Psycho Dash stages `#04–#07` with `StageSpriteMoveY/X` (`attack_ability_system.asm:1033, 1042, 1051, 1059`) right after `SetPlayerSpriteDirect #04` (lines 1032, 1041, 1050, 1058), i.e. against `spriteset_will_abilities`. The projectile actors at `player_character.asm:1855-1897` (`#04`–`#07`) use `spriteset_darkgaia_projectile`.
Fix: reword both lists as "staged only under another body row (`spriteset_will_abilities`) or not found", and drop the contradictory second sentence. Spec: F07. The runtime check of the active body row per site goes to Mesen2.

**A06-10 · VERIFIED · L · class 11**
`tables/body_table.asm:5`: "While bit 15 is set, DecomposePlayerSprites reads row +3 / +5". The code reads them always: `system/engine/sprite_composition.asm:690-711` takes the row index from `animScratch2` when bit 15 is set and from `characterForm × 6` otherwise, then reads `body_table+3` and `+5` in both cases. Bit 15 changes only where the row number comes from.
Fix: "DecomposePlayerSprites reads row +3 / +5 for the player's tile DMA list; with bit 15 set the row comes from `animScratch2`, otherwise from `characterForm × 6`". Spec: F07.

**A06-11 · VERIFIED · L · class 11 (omission)**
`tables/body_table.asm:30-37`: the row table does not say which rows are selected by number. `rg -n "SetPlayerSpriteDirect\] \( #0[0-9A-F]" extracted --glob "*.asm"` (24 sites, matches the count in `cop_handlers_player_sprite.asm:3`) gives only the operands `04, 05, 06, 08`:
- `#04`: `player_transition_handlers.asm:73, 98, 116`, `player_character.asm:1373, 1408`, `attack_ability_system.asm:1032-1058, 1270`, `sF7_credits_player.asm:173, 186, 204, 227` (confirms the row-4 list: flute, hold pose, slider, dash, credits)
- `#05`: `sE6_gaia.asm:1658, 1683, 1708, 1815, 1840, 1967, 1995`, the only user of row 5
- `#06`: `player_character.asm:603`, `attack_ability_system.asm:402`
- `#08`: `player_transition_handlers.asm:222`
- rows `$03` and `$07`: no site. The note says this for `$03` and is silent about `$07`.
Fix: add "row $07 is not selected by any SetPlayerSpriteDirect operand" and name `sE6_gaia` as the only user of row $05. Spec: F07.

**A06-17 · VERIFIED · L · n/a**
`tables/spriteset_freejia_tilefx.asm:15`: "the actors have no movement code". True for the two tile-animation actors, but `code_05B021` (`freejia/freejia/fr32_laborer_npc.asm:16-18`) also stores `$0420` in `cameraBoundsY` (`$06DC`) before `SpawnAfter`. The note's "only user" paragraph (line 3) lists the COPs but not that store.
Fix: add the `cameraBoundsY` store to line 3, or say the actors run no sprite movement. Spec: F07.

### 2.2 Cross-file and docs

**A06-18 · VERIFIED · M · class 5 (doc row for a different struct)**
`docs/structs-reference.md` contradicts the live notes:
- lines 670-683, `direction-velocity`: "xVelIdx / yVelIdx ... into the `delta-node` table ... 9 entries cover all cardinal and diagonal directions". Live: byte 0 = animation index, byte 1 = move_chain index; the nine entries are step codes, left and right carry no chain (`walk_step_table.asm:1-30`; `forced_walk.asm:189-225`).
- lines 1181-1200, `sprite-set`: field `frameCount`, "Terminator: `frameCount = $0000` (null word, not `$FFFF`)", "sprite-group ... 13-byte header ... bounds, flags, tile counts". Live: 4-byte records `< hold, &group >` ended by a hidden `$FFFF` (`spriteset_freedan.asm:6`, which itself says the doc is wrong), header = 4 extents + two 4-byte boxes + count.
- line 1214: block names `table_0E8000`, `table_0EDA00`, `table_0EE000`, `table_0F8000`, `table_0FC000` (retired).
- `body-entry` (1080-1094) is consistent with the live note.
Fix: edit the three doc passages. Spec: F05 (docs), by hand.

**A06-19 · VERIFIED · L · n/a**
`digest_I041-I072.md:73` says the I063 `spriteset_freedan` spec had "8 'unread' bytes". `edits/I063.json` says "Bytes 4-7 and 8-11: two 4-byte boxes for the collision code"; the word "unread" is in the I055/I058 results and the I059 draft (line 68 of the same digest names those correctly). Plan-level correction only; no note changes.

### 2.3 Hygiene sweeps (defect classes 3, 4, 7, 10)

**A06-12 · VERIFIED · L · class 4. History narration, 12 lines in 11 files.**
`rg -n -i "previously|formerly|old header|old note|previous header|previous note|the old |first audit|was wrong|was misnamed|used to |is wrong|were wrong|claimed|older" <16 files>`:

| File:line | Text starts |
|-----------|-------------|
| `walk_step_table.asm:7` | "The old header called byte 0 a 'base sprite frame' ..." |
| `body_table.asm:7` | "The old header listed the rows as ..." |
| `ability_damage_tables.asm:1` | "Despite the old name and header ..." |
| `forced_walk_pan_table.asm:1` | "The old note ('animation frame sequences' ...) was wrong" |
| `move_chain_table.asm:28` | "The old header said 'simple entries ($00-$11) ...'" |
| `spriteset_adrift_wave.asm:1` | "The old header called it a set of non-combat ... particles" |
| `spriteset_snake_pit_fx.asm:15` | "The previous note (...) was a guess" |
| `spriteset_freejia_tilefx.asm:1` | "(the old note was a guess from the name)" |
| `spriteset_will.asm:14` | "The previous header said 'flute-play' frames" |
| `spriteset_freedan.asm:6` | "docs/structs-reference.md says the terminator is $0000: that is wrong" |
| `spriteset_freedan.asm:19` | "The previous header claimed 'Dark Friar cast poses'" |
| `spm_boot_logos.sprite.asm:18` | "The first audit of this file (I055) called these eight bytes 'nothing reads'" |

Fix: delete each sentence and keep only the current fact. Spec: F07.

**A06-13 · VERIFIED · L · class 7. Ids in note text, 15 lines in 13 files.**
`rg -n -o "OQ-[A-Z0-9-]+|\(I0[0-9]{2}\)"`:
`ability_damage_tables.asm:14` (OQ-I062-2), `body_table.asm:30, 37` (OQ-I061-1), `walk_step_table.asm:30` (OQ-I061-2), `scene_actors.asm:894` (OQ-I061-3), `forced_walk_pan_table.asm:24` (OQ-I064-1), `shared_word_table.asm:30` (OQ-I063-1), `spriteset_adrift_wave.asm:3` (OQ-I062-1), `spriteset_freejia_tilefx.asm:15` (OQ-I064-2), `spriteset_will.asm:14, 35` (OQ-I064-3, OQ-I064-4), `spriteset_freedan.asm:47` (OQ-I063-2), `spm_darkspace_sprites.sprite.asm:13` (OQ-B001-1), `spm_overworld_sprites.sprite.asm:11` (OQ-B001-2), and `spm_boot_logos.sprite.asm:18` (I055).
Fix: remove the ids, keep the open fact in words ("not traced"). Spec: F07, and A12 holds the OQ registry.

**A06-14 · VERIFIED · L · class 4. Audit-process narration and hedge tags.**
- `^; Checked:` paragraphs in 6 files: `ability_damage_tables.asm:16`, `body_table.asm:9`, `walk_step_table.asm:9`, `scene_actors.asm:27` (also "SAMPLED about 12 %"), `spriteset_adrift_wave.asm:5`, `move_chain_table.asm:30` ("SAMPLED 50 of the 85 chains").
- `UNVERIFIED-RUNTIME` in 7 notes (the six above plus `spm_overworld_sprites.sprite.asm:11` "not checked at runtime"), and `scene_actors.asm:12` "inferred from the field name".
- `forced_walk_pan_table.asm:24`: "The sums are hand-computed from the bytes" (true, and I re-verified every sum, see §2.4, but it is process narration).
Fix: delete the `Checked:` paragraphs and the tags; the open runtime questions belong to the OQ document. Spec: F07.

**A06-15 · VERIFIED · L · class 3 / 10. Retired nicknames, 22 lines in 4 files.**
`rg -c -i "will_alt|ability_fx|shadow_mode|WillAlt|AbilityFx|FacingData_(FreedanFx|ShadowFx)" extracted --glob "*.asm"`: `body_table.asm` 1 (line 37: "will_alt, ability_fx, freedan_fx, shadow_fx"), `cop_handlers_player_sprite.asm` 4, `GetPlayerFacingDirection.asm` 10 (including the `FacingData_*` labels), `slider_glide.asm` 7. (`inventory_overlay.asm`'s 4 hits are `ReloadAbilityFX`, a false hit.) `shadow_fx_NN` / `freedan_fx_NN` in the spriteset tables are current label names, not nicknames.
Fix: already the F03 target list; add `body_table.asm:37` to F03 part 1 (it is there) and keep A06-01 on the same line so one edit fixes both. Spec: F03.

**A06-16 · VERIFIED · L · class 3. Stale or unprefixed names in part and block notes.**
- `spriteset_adrift_wave.asm:19`: "sprite_group_adrift_wave_0, 14C0F0, 14C104, 14C118" (live labels `sprite_group_adrift_wave_1..3`, lines 40, 49, 58).
- `spriteset_snake_pit_fx.asm:29, 41`: "groups 14C148, 14C15C, ...", "Groups 14C15C, 14C170 and 14C184" (live labels `snake_pit_fx_frame_0..3`, lines 43–61).
- `spm_overworld_sprites.sprite.asm:13-14` and the other spm block notes name groups `sprite_set_000100`, `sprite_set_00010E` (live labels carry the file prefix, e.g. `spm_overworld_sprites_sprite_set_00001C`, line 49); `spm_boot_logos.sprite.asm:18` names `sprite_set_000004` / `sprite_group_000010` the same way.
- `freejia_tilefx` still names its groups `sprite_group_14C028`, etc., in both labels and note: consistent, but the labels themselves are offset names (A13 backlog).
Fix: replace the offset or unprefixed names with the live labels. Spec: F07.

### 2.4 Checks that came out right (recorded so they are not re-opened)

- **Item 2: the four B001 readers are real** (static): `PlayerAttackHitTest` reads `+0..+3` (`combat_collision.asm:432`); `RunCombatCollision` reads `+4..+7` (`$0004,Y`, line 193); `RunInteractionCollision` reads `+4..` (lines 1233, 1358); the solid-rect COPs are in `cop_handlers_collision.asm` (lines 611, 794, 902). `UpdateActorAnimation` reads `+0..+3` into `$18/$1A/$1C/$1E` (`sprite_composition.asm:885-940`). `DecomposeActorMetasprites` skips the eight bytes (`sprite_composition.asm:592`). A fifth reader exists (A06-02).
- **Item 2: no stale "unread" claim survives.** `rg -n -i "nothing reads|unread|never read|no code reads|not read\b"` over `tables/` and the four spm directories: the only live "nothing reads" is the quotation in `spm_boot_logos.sprite.asm:18` (A06-12). The other hits are scoped ("not read on this path", `spriteset_snake_pit_fx.asm:7, 11`, `spriteset_freejia_tilefx.asm:7, 12`), `ability_damage_tables.asm:14` (verified), `enemy_stats_table.asm`, `WorldMapController.asm:18` and the boot-logo palette files (out of scope).
- **Item 2: all 85 groups of the four spm files carry the default boxes** (`$F8 $F0 $01 $01` and `$F8 $10 $F0 $10`): rg counts 2 + 1 + 34 + 48 = 85.
- **Item 3: live `spriteset_freedan` note = B001 version.** The block note (`spriteset_freedan.asm:1-19`) is identical to the text in `edits/B001.json` (bytes 4–7 read at `metaspritePtr+0..3`, bytes 8–11 at `+4..+7`, the readers named). It is not the `edits/I063.json` text ("two 4-byte boxes for the collision code"). The B001 text is incomplete in the way A06-02 describes; the I063 text is not live.
- **`forced_walk_pan_table`**: all 16 lists recomputed from the bytes (word = delay D low byte, step S high byte; moves S × (D + 1)): cruise counts 19, 22, 17, 21, 23, 86, 25, 27, 29, 31, 42, 35, 47, 49, 53 and the `$0F` profile (6 × 8, 4 × 10, 42 × 12) and totals 256, 512, 240, 272, 288, 1280, 304, 320, 336, 352, 752, 384, 480, 496, 528, 784 all match; list sizes 12 × 20 + 4 × 28 = 352 and 32 + 352 = 384 = 109278 − 108894. The four `ForcedWalk*` actors read the table at `forced_walk.asm:50, 89, 128, 167`; `cop_handlers_effects.asm:9, 375-390` confirms the "step in the low nibble of `$2B`, `$2A` calls left" behaviour.
- **`walk_step_table`**: the nine entries, the three identical-row pairs, the two readers (`forced_walk.asm:189-225`, `actor_execution.asm:1090-1095`), and `move_chain` indices `$11–$14` all match.
- **`move_chain_table`** (counts only): 1,173 nodes, 85 pointers, 4,692 bytes, value histogram 302 / 183 / 156 / 126, range −8 to +12, 19 single-node self-linked chains, `AnimFrameLookup` callers only in `cop_handlers_force_move`, `cop_handlers_player_sprite`, `cop_handlers_sprite`; `unused_particle_rain_spawner` uses indices 3–10.
- **`shared_word_table`**: `rg -o "\[LU:[0-9A-Fa-f]+\]" tables/system_strings.asm | sort | uniq -c` gives 1:2, 2:9, 4:3, 5:8, 6:3, 7:6, 8:4, 9:3, A:2, B:3, C:18, E:7 = 68 tags; `rg -c "\[LU:" tables/system_strings.asm` = 64 lines, minus one comment line (line 1) = 63 data lines, as the note says. Indices `$00`, `$03`, `$0D`: 0 hits in `system_strings` and 0 in the retranslation modules (`rg -o --no-filename "\[LU:[0-9A-Fa-f]+\]" IOGRXLT/IOGRetranslation/modules --glob "*.asm"` gives only `2, 4, 7 ×6, B, C ×2`). The note's closing hedge ("the retranslation patches may use other indices") can become a fact.
- **`body_table`**: rows, banks (`$95 $8E $94 $8F $8F $97 $97 $97 $97`, matching the `spriteset_*` block banks), `$7F0006/$7F0008/$7F000E/$0AC8` stores, the bit-15 clear in `actor_pool.asm:74-87`, and the identical rows `$02 = $03` all match.
- **`scene_actors`**: 256 entries → 241 records, the 16 unused ids (exact list match), 1,798 + 1,317 spawn records, 240 own lists, 64 titles (63 + default) and 177 empty, 220 camera controllers (219 at `;01`, scene `$89` at `;00`), player attributes `$02` ×88 and `$32` ×6, `$A7` = 62 records, `$91` = 58 records. The record parse matches `InitActorFromSceneData` (`actor_execution.asm:941-1060`).
- **spm maps**: holds, frame counts, part counts of the sampled animations, `TitleCometSpriteActor` loop cycles 240 and 64 (`sFC_title_intro.asm:59-67`), `scene_meta.asm:502, 2829` loading `spm_darkspace_sprites`.
- **Single-user claims** for `spriteset_adrift_wave` (`dc2F_adrift_fx.asm:16-19`), `spriteset_snake_pit_fx` (`awB4_snake_pit_fx.asm:15-18`) and `spriteset_freejia_tilefx` (`fr32_laborer_npc.asm`): confirmed, no other file in `gaia-iog-baserom` names the three sets.
- **Flute claim** (`spriteset_will.asm:14`): `PlayerStaticBodyPose` (`player_transition_handlers.asm:8, 70-82`, `SetPlayerSpriteDirect #04` + `StageSpriteFrame #1F`) and `spriteset_will_abilities.asm:15`; `FluteMusicActorController` (`item_use_system.asm:23, 582-616`).
- **Hardware wording.** The OAM attribute bits in the freedan note (bit 8 name table, bits 9–11 palette, 12–13 priority, `$4000` H flip, `$8000` V flip) agree with the standard OAM layout (`corpus/sfcwiki`, E4). The data-size flag (`+$0D`: 0 = 32 bytes, nonzero = 128 bytes) and the tile byte at `+$12` match `cop_handlers_sprite.asm:12-13`. No wrong hardware reading found in the 16 files. No `WaitByte`/`WaitWord` text exists in any of them (`rg -c "WaitByte|WaitWord"` = 0 hits), and no button vocabulary.

### 2.5 Reported, not re-checked

**A06-20 · REPORTED · L.** `tables/move_chain_table.asm:7-10`: the 58 self-link / 26 back-link split of chain endings (only 1 + 58 + 26 = 85 and the 19 single-node self-links were checked). Source: `results/I062_results.md`.

**A06-21 · REPORTED · L.** `report.md` §3.2: `db-us/blocks.json:1005` types `forced_walk_pan_table` as `&Binary` (the extraction prints the lists as hex strings, not word fields) and `:1007` keeps `walk_step_table` as `direction-velocity` while the doc describes it wrongly (A06-18). `blocks.json` is user-owned; belongs to A14 / F06.

---

## 3. Not verified / needs Mesen2

1. Loop lengths in tick form: 36 / 32 / 28 (snake pit, adrift, freejia) and 240 / 64 (title comet). `cop_handlers_sprite.asm` ends the list with a separate pass (`STZ $2A`, `RTI`, script `RTL`); whether the end-of-list pass costs a tick is not shown. The per-frame figures (hold + 1) are verified; the loop totals are nominal.
2. Row 8 facing read (A06-01): does `GetPlayerFacingDirection` run while body row 8 is active, and what value does the out-of-range read produce?
3. The body row active at each `$14–$17` / `$1C–$29` / `$10–$13` staging site (A06-09, OQ-I063-2, OQ-I064-4).
4. How `$0B18`, `$0B1A`, `$0B1E`, `$0B20` get their values (A06-07); and the damage figures as in-game numbers.
5. `characterForm 3` reachability and what selects body row `$03` (OQ-I061-1).
6. That `ApplyMovement` consumes exactly one node per frame (the `move_chain` and `walk_step` "per frame" speeds), and what the long curves look like in motion.
7. Which warp uses which pan list (OQ-I064-1); what the Freejia tile animations show (OQ-I064-2); whether the 16 unused scene ids are ever loaded (OQ-I061-3, static negative only: `rg -i "QueueMapChange\] \( #(48|57|76|77|80|81|9E|AA|AB|AF|C1|C2|CA|CB|F8|F9)\b"` = 0 hits over 82 `QueueMapChange` sites, and no `scene_warps` destination byte names them).
8. `spm_darkspace_sprites` `#04–#09` never selected and `spm_overworld_sprites` `#0C` having no writer (OQ-B001-1, OQ-B001-2): static negatives. `sE6_gaia` stages only `#0A`, `#00–#03` and the player body after `SetPlayerSpriteDirect #05`; the `SetMetasprite` targets in `system/dark_space` are `spriteset_pickups_effects`; `scene_10_actors` uses `ec10_dp_hint_spirit` (`spriteset_npc_props`). Party-array writers: `av6A_neil` 0–5, `wa79_neil` 7–A, `daC8_neil` B, `wa78_men` D, none for C.

Negative-proof commands run for item 2 (all static; none of them is runtime):

| Claim | Command (from `gaia-iog-baserom` unless noted) | Result |
|-------|-----------------------------------------------|--------|
| 16 scene ids not used as map targets | `rg -i "QueueMapChange\] \( #(48\|57\|76\|77\|80\|81\|9E\|AA\|AB\|AF\|C1\|C2\|CA\|CB\|F8\|F9)\b" extracted` and the same ids as `scene_warps` destination byte | 0 hits |
| body rows `$03`, `$07` never selected by operand | `rg -n "SetPlayerSpriteDirect\] \( #0[0-9A-F]" extracted --glob "*.asm"` | 24 sites; operands 04, 05, 06, 08 only |
| Will/Freedan `$04–$07` not staged on the player | `rg -n "COP \[(StagePlayer[A-Za-z]*\|RunPlayerAnim)\] \( #0[4-7][,) ]" extracted --glob "*.asm"` | 0 hits (the broad `Stage[A-Za-z]*` form gives hundreds of hits for other actors, so it cannot prove this; the player-scoped form was used) |
| `shared_word_table` `$00 $03 $0D` unused | `rg -o "\[LU:[0-9A-Fa-f]+\]" extracted/tables/system_strings.asm` and the same over `IOGRXLT/IOGRetranslation/modules` | 0 hits for `0`, `3`, `D` in both |
| `ability_damage_tables` record word 0 never read | read of `LoadAbilityDamageA/B` (`attack_ability_system.asm:1628-1672`): offsets used are +2 and +4+level | none read |
| writers of the six level words | `rg -n -e 'STA \$0B16' ... -e 'STA \$0B20' extracted --glob "*.asm"` | 3 stores (A06-07) |
| `AnimFrameLookup` callers | `rg -n "AnimFrameLookup" extracted --glob "*.asm"` | 3 handler files only |
| `ability_damage_tables`, `spriteset_adrift_wave`, `spriteset_snake_pit_fx`, `spriteset_freejia_tilefx` single users | `rg -n "<label>" extracted baserom --glob "*.asm"` | one user each |
| stale "unread" wording | `rg -n -i "nothing reads\|unread\|never read\|no code reads\|not read\b" extracted/tables extracted/system/{boot_logos,title_screen,dark_space,world_map}` | only `spm_boot_logos.sprite.asm:18` (quotation) |
| `[LU:n]` tag counts | `rg -o "\[LU:[0-9A-Fa-f]+\]" extracted/tables/system_strings.asm \| sort \| uniq -c` | 68 tags, as the note states |

---

## 4. Items for the fix specs

| F-step | Findings | Notes |
|--------|----------|-------|
| **F03** (existing) | A06-15, and A06-01 on the same line (`body_table.asm:37`) | One edit of `body_table.asm:37` should fix the nickname list and the row-8 claim together. Part 2 (names): `FacingData_WillAlt` / `FacingData_AbilityFx` renames unchanged. |
| **F02** (existing, WaitByte n+1) | A06-03 | Or fold into F07; the same n+1 rule. |
| **F05** (existing, docs) | A06-18 | `docs/structs-reference.md` 670-683, 1181-1214. Also `report.md` §5 stays as is. |
| **F06 / A14** | A06-21 | User-owned `blocks.json` types; not an agent edit. |
| **F07 (proposed, new)**: "I061–I064 / B001 note corrections" (`merge` spec) | A06-02, 04, 05, 06, 07, 08, 09, 10, 11, 12, 13, 14, 16, 17 | Target files: `walk_step_table`, `body_table`, `scene_actors`, `ability_damage_tables`, `forced_walk_pan_table`, `move_chain_table`, `shared_word_table`, `spriteset_adrift_wave`, `spriteset_snake_pit_fx`, `spriteset_freejia_tilefx`, `spriteset_will`, `spriteset_freedan`, the four spm maps. Remove history, ids and `Checked:` paragraphs in the same pass as the factual fixes so each note is edited once. Rebuild gate after the merge. |
| Plan-level | A06-19 | Correct digest line 73 if the digest is re-issued. |

PLAN.md does not yet have an F07 row; this step does not add one (only the A06 row is edited).

---

## 5. Counts

| Item | Count |
|------|-------|
| Files checked | 16 |
| Block notes checked | 16 of 16 (2 partial) |
| Part notes checked (separator count) | about 78 of 88 (89 %); about 10 not checked, listed in §1.4 |
| Findings | 21: 19 VERIFIED, 2 REPORTED |
| By severity | H 2 (A06-01, 02), M 6 (A06-03, 04, 06, 07, 09, 18), L 13 |
| By class | 2: 1 (A06-03); 3: 3 (A06-06, 15, 16; A06-15 is also class 10); 4: 2 (A06-12, 14); 5: 1 (A06-18); 7: 1 (A06-13); 11: 6 (A06-01, 02, 07, 09, 10, 11); n/a: 7 (A06-04, 05, 08, 17, 19, 20, 21) |
| Hygiene sites | history narration 12 lines / 11 files; ids 15 lines / 13 files; `Checked:` paragraphs 6; `UNVERIFIED-RUNTIME` 7; nickname lines 22 in 4 files |
| Negative-proof rg commands recorded | 10 (§3 table), plus the 5 spm and 3 single-user checks |
| Earlier "unread" notes corrected? | yes: 0 stale claims in `tables/` and the spm files; one quotation remains (`spm_boot_logos.sprite.asm:18`) |
| B001 readers confirmed | 4 of 4, plus 1 missing (`tile_collision_physics`) |
| Live `spriteset_freedan` note = B001 text | yes (not the I063 spec) |
| Defect-class sweep | class 2: 1 hit (A06-03); `WaitByte` text: 0; wrong hardware reading: 0; button vocabulary: 0 |
| Edits made | none (this file and the A06 row in `PLAN.md` only) |
