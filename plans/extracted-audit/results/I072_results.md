# I072 - 2026-10-28 - files: tables/scene_thinkers.asm, tables/system_strings.asm, tables/spriteset_will_alt.asm
Status: COMPLETE

Spec: [edits/I072.json](../edits/I072.json). Proposals: [renames/I072_renames.md](../renames/I072_renames.md). Questions: [questions/I072_questions.md](../questions/I072_questions.md).

Conventions: verdicts **P/M/F/NA**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 coverage and verbosity, Q2 value, Q3 accuracy, Q4 mnemonic and variable names, Q5 new mnemonic, Q6 naming, Q7 evidence quality. Annotation style as in I049 to I071. `spriteset_will_alt.asm` is **SAMPLED ~60%** for line-by-line review (the table, all 39 frame lists, the groups to `0F84EC`, `0F87FD`-`0F8864`, `0F8B51`-`0F8C71`, `0F8D1D`-`0F8D7D` and the last groups); every count and the byte reconciliation were computed over the whole file. The sprite-set struct is documented once, in the `spriteset_freedan` block note of I063.

### tables/scene_thinkers.asm (1 pointer table of 256 words, 70 lists, 204 records, 729 lines before / 763 after, Bank 0C 845285-846683, parts: 0 code / 71 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | 4-line header: no record format, no counts, no sharing rules | E1 |
| Q2 value | F | Did not say what the record fields mean or that table entries may point into the middle of another list | E1 |
| Q3 accuracy | **F** | **"background AI thinkers (palette cyclers, HDMA effects, ambient handlers)"** is only half right: `global_ambient_dispatcher`, which is in 59 of the 70 lists, is the player palette and the talk interaction, not an ambient effect. The note also missed the `$FF` terminator, the spawn parameter (`animScratch+2`) and the `+4` / `+8` table entries | E1 (`SpawnSceneThinkers`, `InitThinkerFromSceneData` in `thinker_execution`; the thinker block notes), E2 (counts over all records: 59 ambient palette cyclers, 59 dispatchers, 30 scanline bands, 56 others) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | `thinker_spawn_0CE7E5` is the bare dispatcher list used by 70 scenes; offset names hide it; the table entries with `+4` / `+8` suffixes look like labels but are hex byte offsets | PROPOSED R-I072-3 |
| Q7 evidence quality | P | Whole file read; every list and the sharing counts computed; byte budget reconciles (1398 = 512 + 204 x 4 + 70); what the bundles and bands look like on screen was not traced | E1, E2 (UNVERIFIED-RUNTIME: OQ-I072-3) |

Actions taken: block note rewritten (table, record format, the sharing and entry offsets, the 70 lists, byte check); table part note rewritten and 5 list part notes (`thinker_spawn_0CE7E5`, `0CE7EA`, `0CE8E6`, `0CE9EA`, `0CEA45`, new); no inline comments (data); no mnemonics added.
Deferred: R-I072-3; OQ-I072-3 (three lists no scene reaches).
Before/after stats: 729 to 763 lines; generic labels remaining: 70.

### tables/system_strings.asm (10 string tables plus loose strings, 767 lines before / 804 after, Bank 01 121304-125711, parts: 10 mapped tables, 247 loose-string labels)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A one-paragraph block note and 10 part notes; no index variables, no readers, no text tags | E1 |
| Q2 value | F | A reader could not tell which RAM variable picks the entry or which table a given screen prints | E1, E2 |
| Q3 accuracy | **F** | Seven of the ten part notes were wrong: **`item_menu_table` "longer descriptions shown when hovering"** is the one-line item NAME (the description is `item_description_table`); **blank range `$2A`-`$38` / statues `$39`-`$3F`** are `$29`-`$37` / `$38`-`$3F`; **`item_description_table` "multi-line descriptions of function and lore"** is 41 entries of short function text; **`non_discardable_item_bits` "padding / alignment"** is read by `CheckItemDiscardable`; **`misc_ui_strings` "status labels, save/load prompts, game over text"** is `'B'` / `'Y'` plus inventory prompts and three screen labels; **`character_name_table` "Will, Kara, Lance, Erik, Seth"** is the three player forms; **`consolestring_01D9D8` "displayed at boot"** is the region warning plus two title strings. The block note's "all game UI text" is also wrong: dialogue text is `DialogString` data elsewhere | E1 (`ConsoleStringRenderer`, `CheckItemDiscardable`, `RunBg3Script`, `ComputeAbilityIndex`, the `[TBL:...]` users in `inventory_menu` and the status screen), E2 (`shared_word_table`: the 8 'Mystery Doll' tags), E3 (`docs/bank01-data-tables.md` lines 564, 582, 585 repeat the old text) |
| Q4 mnemonic/var names | NA | Data only; the index variables (`$0AC6`, `$0AD4`, `$0AE8`, `$0B26`) are given in the block note | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | The block name is fine; `item_menu_table` holds names (one line), so it reads as a description table; `consolestring_01D9D8` and the names-file entry `boot_screen_strings` at the same address disagree; 247 loose strings are offset-named | PROPOSED R-I072-1, R-I072-2 |
| Q7 evidence quality | M | Whole-file counts; every table's index variable and a reader traced; the byte budget reconciles (the ten parts add up to 4407 = 125711 - 121304); the loose strings' callers were not all traced (six at `01E82B`-`01E85C` have none) | E1, E2 (UNVERIFIED-RUNTIME: OQ-I072-1, OQ-I072-2, OQ-I072-3) |

Actions taken: block note rewritten (reading mechanism, table map with index variables, item IDs, ability indices, non-discardable bits, what was wrong); 10 part notes updated; 3 loose-string part notes added (`consolestring_01E7F6`, `01E870`, `01E919`); no inline comments (data); no mnemonics added.
Deferred: R-I072-1, R-I072-2, R-I072-5; OQ-I072-1, OQ-I072-2, OQ-I072-3.
Before/after stats: 767 to 804 lines; generic labels remaining: 247.

### tables/spriteset_will_alt.asm (1 table of 39 pointers, 39 frame lists, 63 labelled groups, 1031 lines before / 1085 after, Bank 0F 1015808-1020133, parts: 0 code / 103 data) SAMPLED ~60%

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 2-line header; no index map | E1 |
| Q2 value | F | No animation, caller or art named | E1 |
| Q3 accuracy | **F** | **"Additional animation frames for Will used in specific cutscene or transformation contexts"**: this is body_table row `$04` (art `will_sprites_1A8000`), selected by `SetPlayerSpriteDirect #04`, and holds the Psycho Dash (`$04`-`$07`), Psycho Slider (`$0C`-`$17`) and Spin Dash (`$1C`, `$1D`, `$22`) poses, the flute pose (`$1F`), the hold pose (`$20`) and the credits frames; no transformation selects it (the transformation poses are `spriteset_ability_fx`) | E1 (`attack_ability_system`, `player_character` `RunAttackNS` / `RunAttackEW`, `PlayerStaticBodyPose`, `PlayerPoseHold`, `sF7_credits_player`), E2 (`body_table`) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | `spriteset_will_alt` hides that the set holds the ability poses; the group `0F8BCC` swallows a hidden group | PROPOSED R-I072-4, R-I072-6 |
| Q7 evidence quality | M | The animation roles are traced for 29 of 39 indices; `$08`-`$0B`, `$1E`, `$21` and `$23`-`$26` have no caller found; the art was not viewed; the byte budget reconciles (4325 = 78 + 78 + 656 + 819 + 2695 - 1) | E1, E2 (UNVERIFIED-RUNTIME: OQ-I072-4, OQ-I072-5, OQ-I072-6) |

Actions taken: block note rewritten (animation roles table, the hidden group, the checks); table part note and 7 set part notes and 2 group part notes (new); no inline comments (data); no mnemonics added.
Deferred: R-I072-4, R-I072-6; OQ-I072-4, OQ-I072-5, OQ-I072-6.
Before/after stats: 1031 to 1085 lines; generic labels remaining: 102.

## Iteration summary

Files audited: 3 (one sampled, ~60%). Q3 verdicts: 3 F. Notes written: 3 block notes and 29 part notes (6 for `scene_thinkers`: the table and five lists; 13 for `system_strings`: 10 updated and 3 new; 10 for `spriteset_will_alt`: the table, seven sets and two groups). Six notes files changed (`blockNotes/bank01.json`, `bank0C.json`, `bank0F.json`; `partNotes/bank01.json`, `bank0C.json`, `bank0F.json`).

Patterns:
- The `system_strings` failure is a different kind from the sprite sets: the old part notes described the table by its name ("menu", "descriptions") and by what a human would expect, not by the index variable that reads it. Seven of the ten were wrong.
- The hidden-group artefact (see I071) is in `spriteset_will_alt` too: `0F8BCC` has 4 real sub-sprites, and the next 69 bytes (an unreferenced group that is a copy of `0F8D7D`) are printed as ten more sub-sprites.
- Three lists in `scene_thinkers`, six strings in `system_strings` and the Shadow placeholder strings are unreferenced; they are logged as questions, not removed.

Docs repeating old claims: `docs/bank01-data-tables.md` line 564 (item menu descriptions "longer text"), 582 (character names), 585 (misc UI strings), 673 (Mystic Statues), and the section 18c heading of `item_menu_table`. `docs/code/bank00/thinkers-system.md` line 313 counts 59 dispatcher entries, which agrees with the count here; its "173 of 184 scenes" figure was not re-checked.

Tooling: `npm run extract:lt` failed in this session (`extracted/tables` busy); the line-tracked extraction was run directly with `node --env-file=.env.local src/index.ts extract --linetracking`. A repeat dry-run of both specs reports `=unchanged`.

Gate: `npm run rebuild` passed: checksum 223006080, crc 2083230829, totalSize 3062204 (`artifacts/crc.json`), identical to the baseline.

Suggested commit message: `Audit I072: scene_thinkers, system_strings, spriteset_will_alt notes`

## Phase roll-up: P4 global data tables (I061-I072, 36 files of `tables/`)

`system/engine/DisplaySceneTitle.asm`, which was also reviewed in I061, is not counted.

| Question | P | M | F | NA |
|----------|---|---|---|----|
| Q1 coverage/verbosity | 0 | 31 | 5 | 0 |
| Q2 value | 0 | 8 | 28 | 0 |
| Q3 accuracy | 1 | 0 | 35 | 0 |
| Q4 mnemonic/var names | 0 | 1 | 0 | 35 |
| Q5 new mnemonic | 0 | 0 | 0 | 36 |
| Q6 naming | 3 | 33 | 0 | 0 |
| Q7 evidence quality | 6 | 30 | 0 | 0 |

Only `parallax_scroll_table` had an accurate purpose statement; the Q6 passes are `body_table`, `display_preset_table` and `enemy_clear_reward_table`; the Q7 passes are `shared_word_table`, `parallax_scroll_table`, `enemy_clear_reward_table` (I061-I070) and `spriteset_shadow_mode`, `scene_chest_table`, `scene_thinkers` (I071-I072). Q4 and Q5 are not applicable to data except for `scene_meta` (Q4 M).

Most common failures:
1. **Purpose guessed from the name (Q3, 35 of 36).** The old note described what the label suggests and not what reads it: `spriteset_shadow_mode` (a "mode"), `scene_chest_table` ("barriers"), `spriteset_dark_friar` ("hit splash"), `enemy_clear_reward_table` ("all enemies in a Dark Space room"), `spriteset_will_alt` ("cutscene or transformation"), `item_menu_table` ("descriptions"). Each correction came from one search for the reader in `extracted/`.
2. **No reader and no index map (Q2, 28 of 36).** Notes did not say which actor, routine or RAM variable selects an entry. The sprite sets (16 `spriteset_*` files plus `inventory_spritemap`) never listed which animation index a caller stages.
3. **Docs repeat the same guesses (Q3 E3).** `docs/bank01-data-tables.md` carries the chest "barrier" text, the item/character/misc-UI string descriptions and the Mystic Statue line; `docs/code/README.md` line 241 and three comments in `scene_lifecycle.asm` repeat the barrier claim.
4. **Extractor artefact, not note errors.** Three sprite sets (`spriteset_ability_fx`, `inventory_spritemap`, `spriteset_will_alt`) print unreferenced groups as extra sub-sprites of the group before them.

Recurring naming patterns:
- Offset-suffixed generic labels dominate: the six files of I071-I072 alone still hold 691 generic labels (102 `sprite_set_` / `sprite_group_` in `spriteset_will_alt`, 26 in `spriteset_shadow_mode`, 206 in `inventory_spritemap`, 40 `chest_entry_`, 70 `thinker_spawn_`, 247 `consolestring_`).
- Block names that carry a guess instead of the role: `spriteset_shadow_mode`, `spriteset_will_alt` and (I067) `spriteset_ability_fx` are named after a misreading; `item_menu_table` names a use it does not have.
- Names file and parts disagree: `boot_screen_strings` (names) and `consolestring_01D9D8` (the part) at `121304`.
- Table entries with `+4` / `+8` suffixes in `scene_thinkers` read like labels but are hex byte offsets into another scene's list.

Proposals made in this phase (not applied) are in `renames/I061_renames.md` to `renames/I072_renames.md`; open questions (all UNVERIFIED-RUNTIME) in `questions/I061_questions.md` to `questions/I072_questions.md`.

Phase gate: `npm run rebuild` after I072: checksum 223006080, crc 2083230829, totalSize 3062204.
