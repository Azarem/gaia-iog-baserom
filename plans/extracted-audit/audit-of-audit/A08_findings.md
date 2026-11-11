# A08 findings: sanity-style re-verification of I069–I072

Step: A08 of the audit of the audit. Inputs: `digest_I041-I072.md` (I069..I072 sections), `PLAN.md` (defect classes 1–13), `A06_findings.md` (style model), `results/I069..I072_results.md`, `renames/I071_renames.md`, and the live files under `extracted/`.
Nothing was edited except this file and the A08 row of `PLAN.md`.

**Evidence level.** Every behavioural statement below is static (E1 code trace or E2 cross-reference). There is no Mesen2 ROM or save state, so nothing is E5. Where a claim needs runtime proof it is in "Not verified / needs Mesen2".
**Tags.** VERIFIED = checked in the live files this session, with file:line. REPORTED = taken from a ledger or an earlier note, not re-checked.
**File names.** The step prompt uses retired names. The live files are: `spriteset_enemies` → `spriteset_pickups_effects`; `spriteset_shadow_mode` → `spriteset_shadow_aura_body`; `spriteset_will_alt` → `spriteset_will_abilities` (the prompt already says `spriteset_will_abilities`); `scene_barrier_chest_table` → `scene_chest_table`. The mapping comes from the file headers of `results/I069..I072_results.md`, `renames/I071_renames.md` and the `blocks.json` ranges (`db-us/blocks.json:1006`, `:1009`, `:1022-1031`, `:1038-1039`, `:1044`, `:1046-1052`, `:1058-1062`). All paths below are under `extracted/` unless stated.
**Shell use.** The method rule allows `rg` only. For a few counts I also piped `rg` output through `sort`, `uniq`, `wc`, `cut` and `awk` (read-only filters, no files written, nothing edited). Every count that carries a finding was repeated with `rg` / the Grep tool or read directly from the file; the one exception is noted in A08-06.

---

## 1. Scope and files read

### 1.1 Files checked (12)

| # | Live file (`tables/`) | Block | What was read |
|---|-----------------------|-------|---------------|
| 1 | `spriteset_freedan_fx.asm` | I069 | whole file: counts, header count bytes of all 13 groups, byte budget (8 + 60 + 1198 = 1266) |
| 2 | `spriteset_shadow_fx.asm` | I069 | whole file: counts, 16 group headers, byte budget, table (lines 1–21) |
| 3 | `spriteset_pickups_effects.asm` | I069 | block note, part notes, the 144 groups by header count, byte budget (126 + 1154 + 6351 = 7631), the group at 0EEE5E and the rows after it, `Stage*` users by rg |
| 4 | `enemy_clear_reward_table.asm` | I070 | whole file: tier counts and all three scene lists compared id by id; the four readers read in code |
| 5 | `spriteset_dark_friar.asm` | I069 | whole file: 23 groups, 31 records, byte budget (1053); users in `attack_ability_system.asm` |
| 6 | `dialog_dictionaries.asm` | I070 | whole file by rg: both pointer tables, 456 words, boundary words, addresses and sizes |
| 7 | `spriteset_shadow_aura_body.asm` | I071 | whole file: 3 animations, 55 records, 23 groups, 80 sub-sprites, byte budget |
| 8 | `scene_chest_table.asm` | I071 | whole file: 255 pointers, 40 lists, 46 records compared one by one with the 46-row content table; counts; byte check |
| 9 | `inventory_spritemap.asm` | I071 | block note, the two regions that hide groups (108B67, 108BAA), animated sets and code claims |
| 10 | `scene_thinkers.asm` | I072 | whole file by rg and Read: 204 records, 70 lists, sharing counts, unreferenced lists |
| 11 | `system_strings.asm` | I072 | whole file: all ten part notes, all ten tables and the loose strings |
| 12 | `spriteset_will_abilities.asm` | I072 | block note, table, the hidden group at 0F8BF5, users, tick wording |

Cross-file reads (not scored as files of this step): `tables/body_table.asm` lines 26–40; `tables/shared_word_table.asm`; `thinkers/global_ambient_dispatcher.asm` lines 1–30.

### 1.2 Code and docs read to check the claims

`actors/player_transition_handlers.asm` (205–322, plus the file header); `actors/player/player_character.asm` (575–650); `actors/player/attack_ability_system.asm` (385–425, rg hits); `system/engine/cop_handlers_player_sprite.asm` (1–34, 105–127); `system/engine/GetPlayerFacingDirection.asm` (28–98); `system/engine/DialogStringRenderer.asm` (965–1022); `system/engine/DisplaySceneTitle.asm` (rg); `system/engine/thinker_execution.asm` (rg); `system/engine/radar_map_screen.asm` (165–215, 257–300 by rg); `system/engine/warps_interaction.asm` (rg); `system/engine/system_core.asm` and `system/inventory/inventory_overlay.asm`, `inventory_menu.asm` (784–934, 1043–1085, rg); `system/diary_menu/sFA_diary_menu.asm` (rg); `system/boot_logos/sFB_boot_logo.asm`, `system/title_screen/sFC_title_intro.asm` (rg); `functions/StandardEnemyDefeatHandler.asm` (185–260); `actors/field_reveal_object.asm` (38–110); `actors/boss_clear_reward_handler.asm` (120–195); `actors/` users of the `Stage*` handlers (`EnemyDropSystem`, `SpawnFieldRevealEffect`, `EnemyDeathFlash`, `SpawnDebrisBurst`, `hit_switch`, `reward_actors`, `field_reveal_object`, `idle_sprite_display`, `hidden_red_jewel`); `baserom/equipped-icon/EquippedIcon.patch.asm:526`; `db-us/blocks.json`, `db-us/copdef.json`, `db-us/stringTypes.json`.

### 1.3 Ledgers read

`audit-of-audit/PLAN.md`, `report.md`, `digest_I041-I072.md`, `A06_findings.md`; `results/I069..I072_results.md`; `renames/I071_renames.md`; `mesen2-question-inventory.md` (to resolve the OQ ids that appear in note text).

### 1.4 Coverage of "check every note line by line" (≥ 60 %)

Unit = a comment paragraph in the extracted file: 12 block notes plus part notes counted by their `-----` separators.

| Group | Checked line by line | Not checked |
|-------|----------------------|-------------|
| Block notes | 12 of 12 | see below |
| `system_strings` part notes | 10 of 10 (the ten table parts) plus 8 of 15 loose-string notes | 7 loose-string notes (HUD digits, panel clears, tab titles) were checked only against the string text, not against their callers |
| `scene_chest_table` part notes | 6 of 6 | none |
| `scene_thinkers` part notes | 5 of 5 | none |
| `dialog_dictionaries` part notes | 2 of 2 | none |
| Sprite-set part notes (the 7 sprite files) | all animation tables and counts; per-animation role notes checked for `spriteset_freedan_fx`, `spriteset_shadow_fx`, `spriteset_dark_friar`, `spriteset_shadow_aura_body`; for `spriteset_pickups_effects` the role notes of the animations with a found caller; for `inventory_spritemap` and `spriteset_will_abilities` the role notes in the block table | see the list below |

**Not checked (listed as required):**
1. `spriteset_pickups_effects`: the role notes of the animations that have no caller (listed as unreferenced in the block note); only "unreferenced" was re-checked by rg, not what the art shows.
2. `inventory_spritemap`: the artwork of the 77 animations; roles come from the callers.
3. `spriteset_will_abilities`: the credits frames (the claim that `sF7_credits_player.asm:173-227` stages them) were not traced beyond the `SetPlayerSpriteDirect #04` sites (A08-17).
4. `scene_chest_table`: the dialogue strings 'It is empty!' / 'The jewel box is tightly closed.' and the chest tile ids were not re-read (A08-18).
5. `system_strings`: the six strings `consolestring_01E82B`..`01E85C` have no caller; their on-screen result was not checked.
6. Patches that redefine tables in this range: `baserom/equipped-icon/spriteset_dark_friar.asm`, `baserom/new-game-plus/NGPEpilogueSwitch.patch.asm` (`?INCLUDE 'scene_thinkers'`, line 34). Not read.

---

## 2. Findings

Severity: H = wrong fact a reader would act on; M = wrong or stale fact, limited effect; L = imprecision or hygiene. Defect class numbers are from `PLAN.md` (n/a = no class fits, a plain counting or reading error).

### 2.1 Wrong or incomplete facts

**A08-01 · VERIFIED · M · class 2**
`tables/spriteset_shadow_aura_body.asm:33`: "thirteen small groups of 2 ticks each". The records `;06`–`;12` (lines 42–54) have hold `#$0002`, which is 3 ticks (a frame shows hold + 1 ticks, `cop_handlers_sprite.asm`). The same sentence converts the first record correctly ("20 ticks" for hold `#$0013`), so the line mixes the two conventions. Line 24 (16 frames, "all hold 0", "one-tick") and line 84 are correct.
Proposed fix: "thirteen small groups of 3 ticks each (hold 2)".

**A08-02 · VERIFIED · M · class 2**
`tables/spriteset_will_abilities.asm:8` and `:101`: "then nine one-tick frames alternating three groups" / "nine one-tick frames alternating 0F852A, 0F855A and 0F858A". The nine records `;01`–`;09` (lines 105–113) all have hold `#$0001`, which is 2 ticks each. The same lines say "the pose (hold 9)" and "10 ticks", so the first frame is converted and the rest are not. The `$22` note at line 357 ("4 one-tick frames", holds `#$0000`) is correct.
Proposed fix: "nine two-tick frames (hold 1)" in both places; the Psycho Dash cycle is then 10 + 9 × 2 = 28 ticks.

**A08-03 · VERIFIED · M · class 11**
`tables/spriteset_pickups_effects.asm:1135`: the part note says "the last byte of row ;0D is the first byte of group 0EEECC, which is printed again below". The listing contradicts it: row `;0D` (line 1152) is `#00, #00, #00, #00, #C0, #$0002`, so its last byte is `$00`, while the printed group 0EEECC (line 1156) starts with `#08`. The hidden group's own bytes also differ from 0EEECC: box 2 reads `F8 0F F1 0E` in rows `;0B`/`;0C` (lines 1150–1151) and `F8 10 F0 10` in 0EEECC (line 1157), so it is not a copy of 0EEECC. What does hold: the real group has 13 + 11 × 7 = 90 bytes (0EEE5E..0EEEB7), and the hidden 20-byte group follows at 0EEEB8; the extractor prints 3 rows (21 bytes) for it, one more than it holds.
Proposed fix: replace the sentence with "the extractor printed the next, unreferenced group (13 B header + 1 sub-sprite = 20 bytes at 0EEEB8, no set points to it) as three rows of 7 bytes, one byte more than the group". Delete the claim about 0EEECC. (The sentence goes away entirely once AP-12 is fixed, see A08-13.)

**A08-04 · VERIFIED · L · class 11 (omission)**
`tables/spriteset_pickups_effects.asm:1`: "It is not the largest: spriteset_will (17441 B), spriteset_shadow (12443 B) and spriteset_transform_poses (11653 B) are bigger." The list is incomplete: `spriteset_freedan` is 19163 B (`db-us/blocks.json:1046`, 969435 − 950272) and is the largest of the four. All four sizes match `blocks.json:1046,1050,1052,1056`.
Proposed fix: add `spriteset_freedan (19163 B)` first.

**A08-05 · VERIFIED · L · class 11**
`tables/enemy_clear_reward_table.asm:10`: "Values above 3 do not occur; the readers treat 3 and above as DEF." True for one reader only. `StandardEnemyDefeatHandler.EnemyStatBonusReward` (`functions/StandardEnemyDefeatHandler.asm:216-220`) sends everything above 2 to DEF. `field_reveal_object` masks with `AND #$0003` (`actors/field_reveal_object.asm:49`), so a tier of 4 would act as 0. `BossClearApplyStatReward` (`actors/boss_clear_reward_handler.asm:176-181`) pays DEF only for exactly 3 and "larger values give nothing". Since no value above 3 exists in the table (tiers 0/1/2/3 = 169/29/27/31, sum 256), there is no effect today.
Proposed fix: "Values above 3 do not occur; the readers would treat them differently (one sends them to DEF, `field_reveal_object` masks with 3, the boss reader gives nothing)", or simply drop the sentence.

**A08-06 · VERIFIED · M · class 11**
`tables/system_strings.asm:11` (block table) says item_description_table has "two to four rows"; `:447` (part note) says "three or four rows". Neither matches the strings. The 41 entries are: `$00` 'Nothing' (no `[DBL]`), one entry with 1 `[DBL]` (`$06`, `consolestring_01E21A`, line 505), 27 entries with 2 `[DBL]` and 12 entries with 3 `[DBL]` (the 12 are the Grep hits at lines 503, 513, 517, 519, 529, 531, 533, 541, 545, 549, 565, 569). No entry has 4. The 12-entry count was confirmed with the Grep tool; the 1 / 27 split comes from an `awk` count of the same range and from 41 = 1 + 1 + 27 + 12.
Proposed fix: "one to three `[DBL]` lines (two in 27 entries, three in 12, one in `$06`)". State the unit once, since the block note defines `[DBL]` as two tilemap rows per line.

**A08-07 · VERIFIED · L · class 11**
`tables/system_strings.asm:717` (part note of `consolestring_01E7F6`): the six small strings are described as "digits 1-3 and raw tiles at (DE,1) / (9E,1)". Strings `01E82B`, `01E834`, `01E83D` (lines 723–727) print the digits 1, 2, 3 at (DE,1); `01E846` and `01E85C` print raw tile `[ESC:0]`; but `01E851` (line 731) is `[POS:9E,1][PAL:14][NUM:8][PAL:0]`, a number from RAM `$08`, not a raw tile.
Proposed fix: "digits 1-3 at (DE,1), a number `[NUM:8]` at (9E,1) and raw tile 0 at (DE,1) / (9E,1)".

**A08-08 · VERIFIED · L · class 11**
`tables/system_strings.asm:9` and `:244`: item_name_line_table holds "the same names on ONE line". Not exactly: `$03`–`$05` use the shared word `[LU:4]` = 'Inca ' (`shared_word_table.asm:64`), which prints 'Inca Statue A' / 'Inca Statue B' / 'Inca Melody' (`consolestring_01DEB0`, `01DEB6`, `01DEBC`, lines 319–323), whereas item_name_table prints 'Incan Statue A' / 'Incan Statue B' / 'Incan Melody' (`consolestring_01DB51`, `01DB5C`, `01DB68`). Other entries checked (`$01`, `$02`, `$06`) are the same text. The block note's item list (line 20, "Incan") follows item_name_table.
Proposed fix: add "(except that `$03`-`$05` read 'Inca' instead of 'Incan')". Both spellings are in the ROM; this is not a rename.

**A08-09 · VERIFIED · M · class 11 (and 3)**
`tables/body_table.asm:32-34` (rows `$05`/`$06`/`$07`) describe the sets generically ("Ability poses and effects", "Freedan effect sprites", "Shadow effect sprites"). Row `$07` is the misleading one: nothing selects it (check (a) below), and `spriteset_shadow_fx.asm:1` already says that no frame list of the set is staged and that the old "Shadow-specific visual effects" is unsupported. Row `$06` is the Aura Barrier cast and vine-drop poses (`spriteset_freedan_fx.asm:1`: complete body poses of 9–14 sub-sprites, not effect sprites). Row `$08` (line 35) is already correct.
This file is owned by A06 / A07; it is listed here because check (a) is the reason the row-`$07` text is wrong. The row-8 and nickname errors of line 37 are A06-01 / A06-15 and are not repeated.
Proposed fix: `$06 | Freedan's body poses for the Aura Barrier cast and the vine drop (SetPlayerSpriteDirect #06)`; `$07 | not selected by any SetPlayerSpriteDirect operand; content not used (see spriteset_shadow_fx)`.

### 2.2 Cross-file and patches

**A08-10 · VERIFIED · L · class 3**
Stale dictionary names after the block rename to `dialog_dictionary_a` / `_b`: `system/engine/DialogStringRenderer.asm:1004` ("reads from dictionary_01F54D"); `system/engine/DisplaySceneTitle.asm:112`, `:113`, `:143`, `:145`, `:171`, `:175` ("dictionary_01EBA8" / "dictionary_01F54D"). `db-us/stringTypes.json:132,394` still use `dictionary_01EBA8` / `dictionary_01F54D` as dictionary ids; that is a real key, not a comment, and is not to be changed by a note edit. The `DialogCmd_DictionaryA` header (lines 965–968) already uses the new names.
Proposed fix: in the six DisplaySceneTitle lines and the one DialogStringRenderer line, write `dialog_dictionaries.dialog_dictionary_a` / `_b`.

**A08-11 · VERIFIED · L · class 3**
Retired `table_17xxxx` names in comments of code that selects the sets of this range: `actors/player/attack_ability_system.asm:659` ("Set metasprite to table_178000" for `spriteset_dark_friar`), `:552` ("table_179000" for `spriteset_aura`), `actors/player/player_character.asm:1850` ("table_17D000" for `spriteset_darkgaia_projectile`).
Proposed fix: replace each with the live label.

**A08-12 · VERIFIED · L · class 9**
`baserom/equipped-icon/EquippedIcon.patch.asm:526` writes the COP raw: `COP [8E] ( #06 )` (a patch copy of the Aura Barrier cast, `loc_02B9C0!`). `[8E]` is `SetPlayerSpriteDirect` (`db-us/copdef.json:126`, id 142). The mnemonic is not used, and it is the 25th site of this COP: `cop_handlers_player_sprite.asm:33` says "24 sites", which is the extracted count only.
Proposed fix: use `[SetPlayerSpriteDirect]` in the patch (the user's call: it is a patch file), and write "24 sites in extracted/, one more in the EquippedIcon patch" in the handler note.

### 2.3 Hidden groups printed as sprites (AP-12)

**A08-13 · VERIFIED · M · class 8**
Seven unreferenced groups are printed as extra sub-sprite rows of the labelled group before them. All other groups in these files have a header count equal to their printed rows (checked for `spriteset_freedan_fx` 13/13, `spriteset_shadow_fx` 16/16, `spriteset_dark_friar` 23/23, `spriteset_shadow_aura_body` 23/23, and by the byte budget for each file).

| File | Labelled group (printed) | Hidden group (address, size) | Rows printed for it | Where described now |
|------|--------------------------|------------------------------|---------------------|---------------------|
| `spriteset_will_abilities` | `sprite_group_0F8BCC` (line 823; real: 4 sub-sprites, 41 B) | 0F8BF5, 69 B (13 + 8 × 7) | 10 (`;04`–`;0D`), one byte too long | block note `:25` (also says it is a byte-identical copy of `sprite_group_0F8D7D`, line 910) |
| `spriteset_pickups_effects` | `sprite_group_0EEE5E` (line 1137; real: 11 sub-sprites, 90 B) | 0EEEB8, 20 B (13 + 1 × 7) | 3 (`;0B`–`;0D`), one byte too long | part note `:1135` (wrong sentence, A08-03) |
| `inventory_spritemap` | `sprite_group_108B67` (line 1066; 67-byte region) | 108B82 and 108B96, 20 B each (the first labelled group is 27 B, 2 sub-sprites) | 8 printed for 6 real, 2 bytes too long | block note `:16` (R-I071-3) |
| `inventory_spritemap` | `sprite_group_108BAA` (line 1082; 80-byte region) | 108BBE, 108BD2 and 108BE6, 20 B each (the first group is 20 B) | 10 printed for 7 real, 3 bytes too long | block note `:16` |

Totals: 7 hidden groups in 3 files (1 + 1 + 5). Arithmetic for `inventory_spritemap`: 13 × 3 + 4 × 7 = 67 and 13 × 4 + 4 × 7 = 80, both match the note; 108B67 + 27 = 108B82, + 20 = 108B96, + 20 = 108BAA; 108BAA + 20 × 4 = 108BFA = 108BAA + 80.
The same artefact exists in `spriteset_transform_poses` (I067, A07's range) and is the reason for R-I067-4 / R-I069-3 / R-I071-3 / R-I072-6.
Not in this range: `spriteset_freedan_fx`, `spriteset_shadow_fx`, `spriteset_dark_friar`, `spriteset_shadow_aura_body`: no hidden group.
Proposed fix: this is the extractor change of AP-12 (T02, designed in A15). After it, the three notes above describe an artefact that no longer prints and have to be rewritten (list in §4).

### 2.4 Hygiene sweeps (defect classes 4, 7, 13)

**A08-14 · VERIFIED · L · class 4. History narration, 17 lines in the 12 files.**
Lines (all in `tables/`): `spriteset_freedan_fx.asm:1`; `spriteset_shadow_fx.asm:1`; `spriteset_pickups_effects.asm:1`; `enemy_clear_reward_table.asm:1`, `:12`; `spriteset_dark_friar.asm:1`; `dialog_dictionaries.asm:3`, `:10`; `spriteset_shadow_aura_body.asm:1`; `scene_chest_table.asm:1`; `inventory_spritemap.asm:1`; `scene_thinkers.asm:1`; `system_strings.asm:1`, `:26`-`:28` (the whole "WHAT WAS WRONG IN THE OLD NOTES" section), `:46`; `spriteset_will_abilities.asm:1`. Typical text: "The old note (...) was wrong", "the old header", "The old part notes of ... were also off".
Proposed fix: delete the history, keep the current facts. `system_strings.asm:26-28` is a whole paragraph block that can go.

**A08-15 · VERIFIED · L · class 7. Ids in note text, 17 lines in 9 files.**
`spriteset_freedan_fx.asm:10` (OQ-I069-3); `spriteset_shadow_fx.asm:1`, `:13` (OQ-I069-1); `spriteset_pickups_effects.asm:18` (OQ-I069-2), `:1135` (OQ-I069-4); `spriteset_shadow_aura_body.asm:13` (OQ-I071-1); `inventory_spritemap.asm:16` (R-I071-3); `spriteset_will_abilities.asm:7` (OQ-I072-4), `:16` (OQ-I072-5), `:25` (OQ-I067-5); `dialog_dictionaries.asm:12` (OQ-I070-1); `system_strings.asm:24`, `:244` (OQ-I072-2, -1), `:717` (OQ-I072-3); `scene_thinkers.asm:455`, `:589`, `:634` (OQ-I072-3 ×3). No file of `enemy_clear_reward_table`, `spriteset_dark_friar`, `scene_chest_table` has one. The ids resolve in `mesen2-question-inventory.md:445-450` (OQ-I072-3 covers both the six unreferenced strings and the three unreferenced thinker lists, so using it twice is consistent).
Proposed fix: remove the id, keep the plain statement of what is open.

**A08-16 · VERIFIED · L · class 4. Audit-process narration and tags, 9 lines in 7 files.**
`dialog_dictionaries.asm:3` ("(E1, counted in the extracted file)"), `:10` ("SAMPLED about 6%: ..."), `:12` ("was not traced", "was not measured"); `spriteset_freedan_fx.asm:10`, `spriteset_shadow_fx.asm:13`, `spriteset_dark_friar.asm:13`, `spriteset_shadow_aura_body.asm:13` ("not viewed"); `spriteset_pickups_effects.asm:242` ("(not viewed)"); `scene_thinkers.asm:21` ("was not traced"). `Checked:` paragraphs: 0. `UNVERIFIED-RUNTIME`: 0. The "not viewed / not traced" sentences are honest limits; the tags `E1` and `SAMPLED about 6%` are audit-process vocabulary.
Proposed fix: keep one plain limit sentence per file ("the art was not viewed"), drop the evidence tags and the sampling percentage.

**Class sweeps with no hit**
- Class 2 (`WaitByte` stated as n ticks) in text: the only hits are A08-01 and A08-02 (hold vs ticks). `WaitByte` / `WaitWord` as words: 0 hits in the 12 files.
- Class 13 (button vocabulary): `spriteset_will_abilities.asm:7` ("held D-pad direction") is a direction, fine. `system_strings.asm:16`, `:751`, `:756` name the letters 'B' (Type 1) and 'Y' (Type 2) as the string contents the game prints; they are the legend, not a claim about the physical button in this build. Type 1 is confirmed in code (`sFA_diary_menu.asm:704-710`: remapA `$8000`, remapB `$4000`); Type 2 in this build is stated unverified by `sFA_diary_menu.asm:33` (OQ-I057-1). No hit.
- Class 1 (purpose guessed from a label): none found in the 12 files. The roles of the sprite animations all cite a caller; where there is none the note says "unreferenced".
- Class 12 (transform adjacency): none of the 12 files carries a transform; not applicable.
- Retired nicknames inside the 12 files: 0 (`spriteset_enemies`, `spriteset_shadow_mode`, `spriteset_will_alt`, `scene_barrier_chest_table`, `table_17…`, `dictionary_01…` do not occur in them). The outside hits are A08-10 and A08-11.

### 2.5 Reported, not re-checked

**A08-17 · REPORTED · L.** `tables/spriteset_will_abilities.asm` block note (the credits frames): the claim that `sF7_credits_player.asm` stages these frames. Only the four `SetPlayerSpriteDirect #04` sites there (`:173`, `:186`, `:204`, `:227`) were seen in the rg log; the frame indices staged after them were not read. Source: `results/I072_results.md`.

**A08-18 · REPORTED · L.** `tables/scene_chest_table.asm:1-12`: the chest tile ids (closed `$FA/$FB` over `$F8/$F9`, open `$FE/$FF` over `$FC/$FD`), the strings 'It is empty!' / 'The jewel box is tightly closed.' and the fanfare path (`ChestOpeningActor`). The readers themselves are confirmed (`warps_interaction.asm:35,58,150,225`, `radar_map_screen.asm:257-300`) and `warps_interaction.asm:554` agrees on `$FC` open / `$F8` closed for the bottom row. Source: `results/I071_results.md`.

### 2.6 Checks that came out right (recorded so they are not re-opened)

- **(a) Row `$07` never selected, row `$08` selected.** Command (from `gaia-iog-baserom`): `rg -n "SetPlayerSpriteDirect\]" extracted baserom --glob "*.asm"` lists 24 sites in `extracted/`, all with an immediate operand: `#04` 14 sites, `#05` 7 sites (`sE6_gaia.asm:1658,1683,1708,1815,1840,1967,1995`), `#06` 2 sites (`player_character.asm:603`, `attack_ability_system.asm:402`), `#08` 1 site (`player_transition_handlers.asm:222`, `PlayerAuraTransformEntry`). `rg -n "SetPlayerSpriteDirect\] \( #07" extracted baserom --glob "*.asm"` = 0 hits. The raw form `rg -n "COP \[8E\]" extracted baserom --glob "*.asm"` = 1 hit, `baserom/equipped-icon/EquippedIcon.patch.asm:526`, operand `#06`. The only writer of `$0AC8` is `cop_handlers_player_sprite.asm:39` (Grep of `\$0AC8` over `extracted` and `baserom`; the other hits are reads or notes), and all 25 operands are immediates, so a variable operand cannot select row 7. Result: row `$07` is not selected by anything in the static code; row `$08` is selected by exactly one site. `spriteset_shadow_fx.asm:1` and `spriteset_shadow_aura_body.asm:1` are right about this. Runtime confirmation is not possible (no ROM state); see §3.
- **(b) `system_strings` part notes (10) re-read against the strings.** `boot_title_strings`: three strings, region lockout (`sFB_boot_logo.asm:14,101`), copyright then 'PUSH START BUTTON' (`sFC_title_intro.asm:45,47`): correct. `item_name_table`: 64 pointers; `$00` empty (shared `01DB3F`, same as `ability_menu_table;00` and `ability_name_table;00`); names `$01`–`$28` match the block note's item list one by one; `$29`–`$37` are 15 blank 8-space strings; `$38`–`$3F` are 8 'Mystic [LU:C]' strings: correct. `item_name_line_table`: ranges and the 'Mystery Doll' strings (`[LU:5]Doll`, lines 425–427 and 8 entries) correct; wording issue A08-08. `non_discardable_item_bits`: `$BC $FF $FF $FE $DF 00 00 00` decoded against `BitMaskTable` (`$01,$02,…,$80`, `inventory_menu.asm:1074-1081`, bit 0 = lowest ID): discardable `$00,$01,$06,$18,$25,$28-$3F` and protected set as stated: correct. `item_description_table`: 41 pointers, `$00` 'Nothing', no entry for `$29-$3F`: correct; row count wrong (A08-06). `ability_menu_table` (12), `ability_name_table` (12): empty at `$04`, `$08`, placeholders DEFENCERK / DARKCOREK / BLACK4K at `$09-$0B`, status-row callers `01EA49/56/63` at lines 790–792: correct. `ability_description_table`: 13 pointers, `$04` and `$08` empty, `$09-$0C` 'Dark 1': correct. `character_name_table`: 4 pointers with the leading space, 15 loose strings `01E7F6`..`01E919` (count = 15): correct except A08-07. `misc_ui_strings`: 'B' / 'Y', `$0B26` button layout (`sFA_diary_menu.asm:19,677-717`), 20 loose strings (count = 20), callers of `01EAC6` (`GlobalInputHandler.asm:131`), `01EAD1` (`radar_map_screen.asm:214`), `01EADC` (`sFA_diary_menu.asm:153` and others): correct. The `HudRedesign.patch.asm:94,96` override of `01E7F6` / `01E818` and the callers of `01E818` (`inventory_overlay.asm:252`, `system_core.asm:464,480`) are correct; the six strings `01E82B`..`01E85C` have no reference in `extracted/` or `baserom/` (rg above). Byte check 4407 = 125711 − 121304: correct; all ten part ranges agree with `blocks.json:1022-1031`. Result: 10 part notes, 3 with a wrong detail (`item_description_table`, `character_name_table`, `item_name_line_table`), 7 correct in fact (4 of them still carry history or ids: A08-14, A08-15).
- **(c) `global_ambient_dispatcher` in 59 of 70 lists.** Counts by rg on `tables/scene_thinkers.asm`: 204 `thinker-spawn` records; 70 list headers; 59 records with `@global_ambient_dispatcher`, 59 with `@ambient_palette_cycler`, 30 with `@scanline_band_hdma_thinker`, so 56 others; 45 `?INCLUDE` lines. A multiline rg (`rg -nUP` with a negative look-ahead) lists the lists that contain no dispatcher: `0CEA5B`, `0CEA9B`, `0CEAB5`, `0CEABA`, `0CEB18`, `0CEB1D`, `0CEB2A`, `0CEB30`, `0CEB3D`, `0CEB46` (10), and Read of lines 636–763 shows the eleventh, `0CEB2F`, is an empty list (`[ ]`, only the `$FF` byte). 70 − 11 = 59 lists with a dispatcher. A second multiline rg for lists with two dispatcher records returned 0. Result: **59 of 70 is correct**. The dispatcher is first in the lists the note names (`0CE8C7` line 439, `0CE959`, `0CE98D`, `0CE99A`, `0CE9A3`, `0CE9AC` each start with it) and the credits list `0CEA5B` has none (line 647). Byte check 512 + 204 × 4 + 70 = 1398 = 846683 − 845285: correct. Sharing counts by rg on the table: 256 pointers; 70 entries to `thinker_spawn_dispatcher_only`; `0CE7EA` plain 2 (scenes `$04`, `$07`), `+4` 4, `+8` 43; `0CE8E1` / `0CE8EF` / `0CE8F4` once each (scenes `$40`, `$4B`, `$4C`); the other shifted entries `0CE80C+4` 1, `0CE843+4` 2, `0CE861+8` 4, `0CE87F+4` 1, `0CE8A1+8` 1, `0CE96F+8` 2, `0CE9E1+4` 8, `0CEA11+4` 6 = 72 shifted entries in total, all named by the note. 67 of 70 lists reached: each of the eight shifted-target lists is also referenced plain once, and the three unreferenced lists (`0CE8E6`, `0CE9EA`, `0CEA45`) have 0 references in `extracted/` or `baserom/` (only the `NGPEpilogueSwitch` patch includes the whole table, see §3). `0CEA45` is a copy of `0CEA2F`: correct. The note that `global_ambient_dispatcher` is the player palette plus the talk interaction matches `thinkers/global_ambient_dispatcher.asm:1`, and `SpawnSceneThinkers` behaviour (zero pointer or bit 7 = no thinkers) matches `thinker_execution.asm:20`.
- **(d) `dialog_dictionaries` B has 200 entries.** `dialog_dictionary_b [` is at line 793 and its `]` at line 994, so the entries are lines 794–993 = 200, indexes `;00`–`;C7` (the last is `;C7` at line 993 → `dialogstring_01FD1E 'you. '`, line 1394). Dictionary A: lines 19–276, entries 20–275 = 256, `;FF` → `01F545` 'you're '. `rg -c "^  &dialogstring_"` = 456 pointers and `rg -c "^dialogstring_[0-9A-F]+ "` = 456 words (256 + 200). Boundaries match the note: A `;6A` = `01F0CF` 'Yes, ', `;6B` = `01F0D5` 'about '; B `;00` 'Actually, ' is `01F6E3` ('1994 ' is `01F6DD`, the first word), `;43` = `01F8EB` 'Watermia. ', `;44` = `01F8F6` 'always '. Addresses: A table 125864 = `01EBA8`, +512 = `01EDA8`; B table 128333 = `01F54D`, +400 = `01F6DD`; B ends 130340 − 1 = `01FD23`; 2469 and 2007 byte totals agree with `blocks.json:1038-1039`. Tags: `stringTypes.json:125-126,134,396` give LU1 = 214 (`$D6`) and LU2 = 215 (`$D7`); `[LU1]`/`[LU2]` occur nowhere in `extracted/` except in the note itself. `DialogCmd_DictionaryA/B` double the index (`DialogStringRenderer.asm:970-993`). Result: **200 entries is correct**; the old "256 extended words" is gone from the file text except as history (A08-14).
- **`enemy_clear_reward_table`.** 256 bytes: tier counts 169 / 29 / 27 / 31 by rg; the three scene lists in the note match the table scene by scene (all 29, 27 and 31 ids compared). Items `$80/$81/$82` and anims `$0C/$0D/$0E` match `field_reveal_object.asm:65-95`; the flag `$0300 + scene` is set by `BossRewardClaimScene` (`boss_clear_reward_handler.asm:158-160`) and read by all four readers; the radar draws the frame only when the flag is clear and the tier is non-zero (`radar_map_screen.asm:175-180`).
- **`scene_chest_table`.** 216 pointers to `chest_list_none` and 39 to scene lists by rg; 40 list headers; 46 `chest-entry` records (the rg count of 47 includes the format line at line 3); the 46-row content table compared against all 46 records (scene, X, Y, item, flag, fanfare bit): all match. Totals recomputed from the records: 21 Red Jewel (`01`), 10 Herb (`06`), 4 Crystal Ball (`0E`), 3 Mushroom Drop (`1A`), 2 Rama Statue (`13`), 1 each of Blue Block (`07`), Mystic Statue (`38`), Magic Dust (`14`), Teapot (`19`) = 44, plus 2 flag-only (`00`) = 46; 13 records with flag ≥ `$80`, exactly the non-Herb/Jewel item chests; flags `$01`–`$2E`, `$2E` out of sequence at scene `$60`. The 39 scene ids in the pointer table equal the 39 scenes in the content table. Byte check 255 × 2 + 1 + 46 × 4 + 39 = 734 = 110726 − 109992. Item names in the content table agree with `system_strings.item_name_table` (`$06` Herb, `$07` Blue Block, `$0E` Crystal Ball, `$13` Rama Statue, `$14` Magic Dust, `$19` Teapot, `$1A` Mushroom Drop, `$38` Mystic Statue).
- **Sprite-set counts and budgets.** `spriteset_freedan_fx` 13 groups / 147 sub-sprites / 1266 B; `spriteset_shadow_fx` 16 / 82 / 934 B; `spriteset_dark_friar` 23 / 86 / 31 records / 1053 B; `spriteset_shadow_aura_body` 23 / 80 / 55 records / 1091 B; `spriteset_pickups_effects` 144 printed groups / 640 sub-sprites / 257 records / 7631 B; the hidden-group arithmetic of `spriteset_will_abilities` (13 + 8 × 7 = 69, 0F8BCC + 41 = 0F8BF5) and `inventory_spritemap` (§2.3). `Stage*` users of `spriteset_pickups_effects` (`$04`/`$05`/`$06` gems of `EnemyDropSystem`, `$09`/`$0A`/`$0B` blink, `$0C`/`$0D`/`$0E` stat items, `$0F` and `$10` of `hit_switch`, `$22`, `$35`): confirmed by rg of the `Stage*` operands in the nine actor files named in the block note. `PlayerPoseHold` users of `spriteset_will_abilities` `$20` (`gs2D_lily`, `gs2E_sleep`, `dc2F_adrift`, `dc31_rescuer`, `dc31_kara`) and `PlayerStaticBodyPose` `$1F` (`item_use_system.asm:1776`) confirmed. The item string behind `spriteset_shadow_aura_body.asm:1` ('Dark Knight Shadow's Body turns to water', `item_description_table` `$24`, line 565) is right.

---

## 3. Not verified / needs Mesen2

1. Row `$07` and the A08-13 hidden groups are static results. Whether any save state, debug path or patch outside `extracted/` / `baserom/` selects body row `$07` cannot be shown without a ROM run (OQ-I069-1).
2. Whether the shadow_fx single-frame 32-tick holds (`17B098`) are placeholders, what the art shows (all sprite files: "not viewed"), and the visual result of the aura body shrink and reversal (OQ-I071-1): tile viewer needed.
3. Frame timing of A08-01 / A08-02 (3-tick and 2-tick frames, 28-tick Psycho Dash cycle) is read from the runner; not measured.
4. Whether the three unreferenced thinker lists (`0CE8E6`, `0CE9EA`, `0CEA45`) are really unreachable: the table has no pointer to them and no code names them, but `baserom/new-game-plus/NGPEpilogueSwitch.patch.asm` (`?INCLUDE 'scene_thinkers'`, line 34) was not read and could redirect entries (OQ-I072-3).
5. Whether `scene_chest_table` records are the only chest source for the radar (OQ: "chests are drawn from a different list", `enemy_clear_reward_table.asm:12`), and the dialogue and fanfare behaviour (A08-18).
6. `consolestring_01E82B`..`01E85C`: no caller found by rg in `extracted/` and `baserom/`; a computed string pointer could still reach them (OQ-I072-3).
7. `$18` Will and `$25` Lola's Letter discardable, and `$38-$3F` Mystic Statue vs Mystery Doll (OQ-I072-2, OQ-I072-1): needs a play-through with those items.
8. `StagePlayerSprite #00-#03` after Spin Dash reaching only this table while the `#04` override is active (OQ-I072-4); the `$20` hold pose being two sub-sprites (OQ-I072-5).
9. `baserom/equipped-icon/spriteset_dark_friar.asm` redefines the Dark Friar set. Which version the rebuilt ROM contains for an EquippedIcon build, and whether the extracted notes still describe it, was not examined.

Negative-proof commands run (all static; none is runtime):

| Claim | Command (from `gaia-iog-baserom`) | Result |
|-------|-----------------------------------|--------|
| body row `$07` never selected | `rg -n "SetPlayerSpriteDirect\] \( #07" extracted baserom --glob "*.asm"` | 0 hits |
| all selectors of body rows | `rg -n "SetPlayerSpriteDirect\]" extracted baserom --glob "*.asm"` | 24 sites; operands `#04`, `#05`, `#06`, `#08` only |
| raw COP form of the same | `rg -n "COP \[8E\]" extracted baserom --glob "*.asm"` | 1 hit (EquippedIcon patch, `#06`) |
| `$0AC8` has one writer | Grep `\$0AC8([^0-9A-Fa-f]\|$)\|\$7E0AC8` over `extracted`, `baserom` | writer only at `cop_handlers_player_sprite.asm:39` |
| 6 strings unreferenced | `rg -n "consolestring_01(E82B\|E834\|E83D\|E846\|E851\|E85C)" extracted baserom --glob "*.asm" --glob "!extracted/tables/system_strings.asm"` | 0 hits |
| 3 thinker lists unreferenced | `rg -n "thinker_spawn_0CE8E6\|thinker_spawn_0CE9EA\|thinker_spawn_0CEA45" extracted baserom --glob "*.asm"` | 0 hits outside `scene_thinkers.asm` |
| dispatcher count per list | `rg -nUP "^(thinker_spawn_\w+) \[\r?\n(?:  thinker-spawn < #[0-9A-F]{2}, @(?!global_ambient_dispatcher )[^\n]*\n)+\]" -o -r '$1' extracted/tables/scene_thinkers.asm` | 10 lists; the 11th (`0CEB2F`) is empty (Read) |
| two dispatchers in one list | multiline rg for two `@global_ambient_dispatcher` records before `]` | 0 hits |
| `[LU1]`/`[LU2]` text tags | `rg -c "\[LU1\]\|\[LU2\]" extracted` | 1 file: `dialog_dictionaries.asm` (the note itself) |
| retired nicknames in the 12 files | `rg -n "spriteset_enemies\|spriteset_shadow_mode\|spriteset_will_alt\|scene_barrier_chest\|table_17[0-9A-F]{4}\|dictionary_01(EBA8\|F54D)" extracted` | 0 hits in the 12 files; hits only in A08-10 and A08-11 files |
| tier / scene counts of the reward table | `rg -c "^  #01   ;" extracted/tables/enemy_clear_reward_table.asm` (and `#00`, `#02`, `#03`) | 29, 169 (`#00`), 27, 31 |

---

## 4. Items for the fix specs

| F-step | Findings | Notes |
|--------|----------|-------|
| **F03** (existing) | A08-09 | One edit of `body_table.asm` rows `$05`–`$07` (lines 32–34) together with the line-37 fix of A06-01 / A06-15, so the file is edited once. |
| **F07 (proposed in A06)**: note corrections for the audited tables | A08-01, 02, 03, 04, 05, 06, 07, 08, 14, 15, 16 | `merge` spec. Target files: `spriteset_shadow_aura_body`, `spriteset_will_abilities`, `spriteset_pickups_effects`, `enemy_clear_reward_table`, `system_strings`, plus history / id / tag removal in all 12 files in the same pass as the facts. Rebuild gate after the merge. If AP-12 (T02) runs first, skip the hidden-group parts of `spriteset_pickups_effects:1135`, `inventory_spritemap:16` and `spriteset_will_abilities:25`. |
| **F07 (same batch), outside `tables/`** | A08-10, A08-11 | `DialogStringRenderer.asm:1004`, `DisplaySceneTitle.asm:112,113,143,145,171,175`, `attack_ability_system.asm:552,659`, `player_character.asm:1850`; comment-only `merge` edits. Do not touch `db-us/stringTypes.json` (the dictionary ids there are keys). |
| **F06 / A13–A14** | A08-12 | `COP [8E]` in the EquippedIcon patch is a patch edit, user-owned; add the "24 + 1 sites" wording to `cop_handlers_player_sprite.asm:33` in F07. |
| **T02 / A15 (AP-12)** | A08-13 | The list of files whose printed output changes when the extractor prints hidden groups with the 13th-byte count: `spriteset_will_abilities.asm` (0F8BCC, 1 group), `spriteset_pickups_effects.asm` (0EEE5E, 1 group), `inventory_spritemap.asm` (108B67 and 108BAA, 5 groups), plus `spriteset_transform_poses.asm` (I067, from A07). After T02, rewrite the three notes named in §2.3. |
| Plan-level | none | The digest's "59 of 70" and "200 entries" statements are right and need no correction. |

PLAN.md does not yet have an F07 row; this step does not add one (only the A08 row is edited).

---

## 5. Counts

| Item | Count |
|------|-------|
| Files checked | 12 (plus body_table, shared_word_table, global_ambient_dispatcher as cross-references) |
| Block notes checked | 12 of 12 |
| Part notes checked | `system_strings` 10 of 10 table parts + 8 of 15 loose-string notes; `scene_chest_table` 6 of 6; `scene_thinkers` 5 of 5; `dialog_dictionaries` 2 of 2; the sprite-set part notes as listed in §1.4 |
| Findings | 18: 16 VERIFIED, 2 REPORTED |
| By severity | H 0, M 6 (A08-01, 02, 03, 06, 09, 13), L 12 |
| By class | 2: 2 (A08-01, 02); 3: 2 (A08-10, 11; A08-09 is also class 3); 4: 2 (A08-14, 16); 7: 1 (A08-15); 8: 1 (A08-13); 9: 1 (A08-12); 11: 7 (A08-03, 04, 05, 06, 07, 08, 09); n/a: 2 (A08-17, 18) |
| Extra check (a) | row `$07`: 0 selectors; row `$08`: 1 selector; 24 immediate sites + 1 raw-form patch site |
| Extra check (b) | 10 part notes re-read; 3 carry a wrong detail (A08-06, 07, 08), 7 correct; the old 7-of-10 errors are fixed in the text |
| Extra check (c) | 59 of 70 lists contain `global_ambient_dispatcher` (11 do not: 10 non-empty and 1 empty); correct |
| Extra check (d) | dictionary B has 200 entries (`;00`–`;C7`); A 256; 456 words; correct |
| Extra check (e) | 7 hidden groups in 3 files (will_abilities 1, pickups_effects 1, inventory_spritemap 5); 0 in the other 4 sprite files |
| Hygiene sites | history narration 17 lines / 12 files; ids 17 lines / 9 files; process tags 9 lines / 7 files; `Checked:` 0; `UNVERIFIED-RUNTIME` 0; stale-name lines outside the 12 files 10 (A08-10: 7, A08-11: 3) |
| Negative-proof rg commands recorded | 11 (§3 table) |
| Reader checks | 4 of 4 readers of `enemy_clear_reward_table` read in code; 3 of 3 readers of `scene_chest_table` confirmed by rg |
| Edits made | none (this file and the A08 row in `PLAN.md` only) |
