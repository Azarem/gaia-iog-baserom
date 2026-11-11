# I067 - 2026-10-28 - files: tables/item_get_dialog_table.asm, tables/spriteset_will_projectile.asm, tables/spriteset_ability_fx.asm
Status: COMPLETE

Spec: [edits/I067.json](../edits/I067.json). Proposals: [renames/I067_renames.md](../renames/I067_renames.md). Questions: [questions/I067_questions.md](../questions/I067_questions.md).

Conventions: verdicts **P/M/F/NA**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 coverage and verbosity, Q2 value, Q3 accuracy, Q4 mnemonic and variable names, Q5 new mnemonic, Q6 naming, Q7 evidence quality. Annotation style as in I049 to I064. `spriteset_ability_fx.asm` is **SAMPLED ~40%** (lines 1-1000 plus the tail; the whole-file checks, record counts and the byte budget, are in Q7). The sprite-set struct is documented once, in the `spriteset_freedan` block note of I063.

### tables/item_get_dialog_table.asm (1 table of 64 pointers, 37 string labels (the 64 entries share strings), including 5 wrappers, 149 lines before / 197 after, Bank 01 130340-130924, parts: 0 code / 38 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | Two short headers; no per-string information, nothing on the 5 wrappers | E1 |
| Q2 value | F | Did not say how the table is read (`[ADR:&item_get_dialog_table,DB8]`) nor who prints which wrapper | E1, E2 |
| Q3 accuracy | **F** | (a) **"Maps item IDs to the dialog strings displayed when the player obtains each item"**, "formulaic stat-increase strings" ('HP increased by 1!'), "Will got a Red Jewel!": none of these strings exists; the 64 entries are item NAMES or a short found-message ('Prison Key', 'You found an herb!'), the full messages are the five wrappers at the end. (b) "inventory-full messages, and 'nothing found' defaults": inventory-full is wrapper `dialogstring_01FF02`; 'It is empty!' and 'The jewel box is tightly closed.' are chest messages that only live in this block. (c) "Referenced by inventory_mgmt.asm and combat_collision.asm": also `warps_interaction` (chests) and `DialogCmd_IndirectString` reads the table | E1 (`DialogCmd_IndirectString`, `GiveItem_StoreInSlot`, `GiveItem_InventoryFull`, `HandleChestInteraction`), E2 (grep of the five wrappers), E3 (`docs/ram_map.txt` item IDs) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | `item_get_dialog_table` suggests complete dialogue; the content is item names | PROPOSED R-I067-1 |
| Q7 evidence quality | M | Whole file read (149 lines); the ID-to-name mapping was checked against `docs/ram_map.txt` for $00-$28; the 7 blank items and $15-$18 were not looked up in game | E1, E2 (UNVERIFIED-RUNTIME: OQ-I067-1, OQ-I067-2) |

Actions taken: block note rewritten (read path, wrapper table, entry groups); table part note rewritten; 8 part notes (new: 3 shared/blank strings, 5 wrappers); no inline comments (data); no mnemonics added.
Deferred: R-I067-1; OQ-I067-1, OQ-I067-2.
Before/after stats: 149 to 197 lines; generic labels remaining: 37 (`dialogstring_01FDA4` ... `01FF48`).

### tables/spriteset_will_projectile.asm (1 table of 8 pointers, 8 frame lists, 12 groups of 9 sub-sprites, 227 lines before / 264 after, Bank 17 1560576-1561584, parts: 0 code / 21 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 3-line header; no part notes | E1 |
| Q2 value | F | No user, no index-to-direction mapping, no mention of the shared frames | E1, E2 |
| Q3 accuracy | **F** | **"Will's Psycho Dash and Psycho Slide projectile sprites"**, "trail effect frames and impact sprites for Will's ranged abilities": the only user is the four `Projectile*` actors of `player_character` (spawned only in scene `$E8`, the Dark Gaia fight); animations `$00`-`$03` launch (South, North, West, East), `$04`-`$07` single-frame travel loops whose frame is the last group of the launch animation; no impact sprites | E1 (`ProjectileSouth/North/West/East`, `Attack*`), E2 (grep: one user) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | The name keeps "will" although the owner is the Dark Gaia fight; the sets are offset names | PROPOSED R-I067-2 |
| Q7 evidence quality | M | Whole file read (227 lines); byte arithmetic reconciles (16 + 80 + 12 x 76 = 1008); the tile art was not located | E1, E2 (UNVERIFIED-RUNTIME: OQ-I067-3) |

Actions taken: block note rewritten (user, table of 8 animations, shared frames, byte budget); 9 part notes (new: table, 8 sets); no inline comments (data); no mnemonics added.
Deferred: R-I067-2; OQ-I067-3.
Before/after stats: 227 to 264 lines; generic labels remaining: 20 (the 8 `sprite_set_17D...` and 12 `sprite_group_17D...`).

### tables/spriteset_ability_fx.asm (1 table of 19 pointers, 19 frame lists with 697 records, 148 printed groups (2 hide a second group), 2505 lines before / 2525 after, Bank 0F 1032192-1043845, parts: 0 code / 168 data) SAMPLED ~40%

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 3-line header; no part notes | E1 |
| Q2 value | F | No user, no unused animations, no mention of the extractor artefact | E1, E2 |
| Q3 accuracy | **F** | **"Psycho Dash, Psycho Slide, Dark Friar cast, Aura Barrier, Earthquaker"**, "special abilities of all three playable characters": body row `$05` is selected only by the seven `Transform_*` scripts of `sE6_gaia` (`SetPlayerSpriteDirect #05`); the art is `abil_sprites_1B8000`; animations `$04`, `$0C`, `$11` are not staged by any of them | E1 (`Transform_*`, operand tally of `StageSprite*`), E2 (grep of `SetPlayerSpriteDirect ( #05`), E3 (`body_table`) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | `spriteset_ability_fx` names an effect set; the content is body poses of the transformation | PROPOSED R-I067-3 |
| Q7 evidence quality | M | Header, lines 1-1000 and the tail read; counts (697 records = 697 rows, 19 animations) over the whole file; the 8789-byte group area adds up only with two hidden 69-byte groups (checked on the ROM bytes at `0FCF65` and `0FD5E8`); the poses were not viewed | E1, E2 (UNVERIFIED-RUNTIME: OQ-I067-4, OQ-I067-5) |

Actions taken: block note rewritten (users, structure, byte budget, unused animations, extractor artefact); table part note (new); 3 unused-animation part notes (new); 2 extractor-artefact part notes (new); no inline comments (data); no mnemonics added.
Deferred: R-I067-3, R-I067-4; OQ-I067-4, OQ-I067-5.
Before/after stats: 2505 to 2525 lines; generic labels remaining: 167.

### Iteration summary

- Files: 3 audited (1 sampled). Q3: 3 F. Notes written: 3 block notes, 24 part notes (23 new, 1 updated: the old `item_get_dialog_table` part note), 0 inline comments.
- Patterns: (1) a purpose invented from the file name or a guess at "typical" content ('Psycho Dash projectile', 'ability effects', 'acquisition messages' with strings that do not exist); (2) a data table read through a text tag that no earlier note mentioned; (3) a structural extractor artefact hiding unreferenced data.
- Docs repeating old claims: `docs/bank01-data-tables.md` section 22 (item table) and `docs/code/README.md` line 256 still call the table "item acquisition dialog". Logged under R-I067-1.
- Gate: shared with I068: `npm run merge` for both specs, `npm run extract:lt`, both spec dry-runs to 0 files to change, `npm run names -- --check` OK, `npm run rebuild`: checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged).
- Spec: `plans/extracted-audit/edits/I067.json`.
- Suggested commit message: `Audit I067: item name table, Dark Gaia projectile and Dark Space transformation spritesets`

Please commit when you're ready.
