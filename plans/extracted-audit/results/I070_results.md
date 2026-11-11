# I070 - 2026-10-28 - files: tables/enemy_clear_reward_table.asm, tables/spriteset_dark_friar.asm, tables/dialog_dictionaries.asm
Status: COMPLETE

Spec: [edits/I070.json](../edits/I070.json). Proposals: [renames/I070_renames.md](../renames/I070_renames.md). Questions: [questions/I070_questions.md](../questions/I070_questions.md).

Conventions: verdicts **P/M/F/NA**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 coverage and verbosity, Q2 value, Q3 accuracy, Q4 mnemonic and variable names, Q5 new mnemonic, Q6 naming, Q7 evidence quality. Annotation style as in I049 to I069. `dialog_dictionaries.asm` is **SAMPLED ~6%** for line-by-line review (both pointer tables' first rows, the first and last words of each table and the capital/lowercase boundaries `A $69-$6B`, `B $43-$45`); every count (256 + 200 pointers, 456 words, byte budgets, absence of `[LU1]` / `[LU2]` in extracted/) was computed over the whole file. The sprite-set struct is documented once, in the `spriteset_freedan` block note of I063.

### tables/enemy_clear_reward_table.asm (256 one-byte tiers, 266 lines before / 277 after, Bank 01 109278-109534, parts: 0 code / 1 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | Header and part note both say the same sentence; no distribution | E1 |
| Q2 value | M | Gave no scene list and no tier meanings | E1, E2 |
| Q3 accuracy | **F** | (a) **"When all enemies in a Dark Space room are defeated"**: any scene with a nonzero tier pays on the last enemy of that scene, and a boss clear pays all unclaimed tiers of a scene range. (b) **"Minor/medium/major stat boosts or items"**: the tiers are three different stats (1 Max HP, 2 STR, 3 DEF, each +1; items `$80`-`$82`), not magnitudes. (c) **"radar_map_screen (draws chest icons)"**: it draws the reward frame and icon while flag `$0300 + scene` is clear; chests come from another list. (d) the consumers `boss_clear_reward_handler` and `reward_actors` were not named | E1 (`EnemyStatBonusReward`, `BossClearApplyStatReward`, `field_reveal_object`, `radar_map_screen`), E2 (counts over all 256 bytes: 169 / 29 / 27 / 31) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | P | `enemy_clear_reward_table` is accurate | none |
| Q7 evidence quality | P | Whole file read; all four counts and scene lists computed from the extract; readers and their tier mapping read in code (three agree) | E1, E2 |

Actions taken: block note rewritten (tier table with scene lists, flag, four readers); part note rewritten; no inline comments (data); no mnemonics added.
Deferred: OQ-I070-3.
Before/after stats: 266 to 277 lines; generic labels remaining: 0.

### tables/spriteset_dark_friar.asm (1 table of 7 pointers, 7 frame lists, 23 groups, 270 lines before / 303 after, Bank 17 1540096-1541149, parts: 0 code / 31 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 3-line header; no part notes | E1 |
| Q2 value | F | No index-to-user mapping | E1 |
| Q3 accuracy | **F** | **"Fireball travel frames and hit splash"**: there is no splash. `$00` is the cast flash (9 frames), `$01`-`$03` the three trail stages, `$04` the fragment and `$05`/`$06` the trail followers `TrailFollowerSprA/B` | E1 (`DarkFriarProjectile`, `DarkFriarTrailSouth`, `DarkFriarTrailEastWest`, `DarkFriarFragmentInit`, `TrailFollowerSprA/B`) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | Same as R-I069-1 | PROPOSED R-I070-1 |
| Q7 evidence quality | M | Whole file read; byte arithmetic reconciles (14 + 138 + 901 = 1053); the art and the VRAM tile mapping were not viewed | E1, E2 (UNVERIFIED-RUNTIME: OQ-I070-2) |

Actions taken: block note rewritten (index-to-user table, byte budget, shared groups); table part note (new); 7 set part notes (new); no inline comments (data); no mnemonics added.
Deferred: R-I070-1; OQ-I070-2.
Before/after stats: 270 to 303 lines; generic labels remaining: 30.

### tables/dialog_dictionaries.asm (2 pointer tables of 256 and 200, 456 words, 1382 lines before / 1393 after, Bank 01 125864-130340, parts: 0 code / 458 data) SAMPLED ~6%

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A header and two part notes that repeat each other | E1 |
| Q2 value | F | Did not say the word format, the sizes or the table addresses | E1 |
| Q3 accuracy | **F** | (a) **"Dictionary B: 256 extended words", "~512 compressed word slots"**: B has 200 entries (last index `$C7`), 456 words in all. (b) **"Contains the most frequently used words (the, you, have, etc.)"**: not checked, and the sampled words are mostly names and capitalised starts ('Attack ', 'Eric: ') followed by a lowercase section. (c) The role of the file in `DisplaySceneTitle` (character counting) was not mentioned | E1 (`DialogCmd_DictionaryA/B`, `DisplaySceneTitle`), E2 (counts), E3 (`stringTypes.json`) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | 456 `dialogstring_XXXXXX` labels; index-based names would help | PROPOSED R-I070-2 |
| Q7 evidence quality | M | Pointer table heads, boundaries and ends read; byte budgets reconcile (512 + 1957 and 400 + 1607 = 4476); how the compressor chooses words not traced | E1, E2 (UNVERIFIED-RUNTIME: OQ-I070-1) |

Actions taken: block note rewritten (word format, tags, sizes, table and word ranges, section boundaries, extraction behaviour); both part notes rewritten; no inline comments (data); no mnemonics added.
Deferred: R-I070-2; OQ-I070-1.
Before/after stats: 1382 to 1393 lines; generic labels remaining: 456.

### Iteration summary

- Files: 3 audited (1 sampled). Q3: 3 F. Notes written: 3 block notes, 11 part notes (8 new, 3 replaced: `enemy_clear_reward_table`, `dialog_dictionary_a`, `dialog_dictionary_b`), 0 inline comments.
- Patterns: (1) a mechanism attributed to a narrower context than the code ('Dark Space room'); (2) a magnitude where the table holds a category ('minor/medium/major'); (3) a size copied from a sibling ('256 words' for both dictionaries); (4) an effect described by guess ('hit splash').
- Docs repeating old claims: `docs/bank01-data-tables.md`, `docs/code/bank00/actors-player-rewards.md`, `docs/structs-reference.md` (enemy_clear_reward_table and dictionary sections). Logged under R-I070-3.
- Gate: see I069 (shared). Checksum 223006080, crc 2083230829, totalSize 3062204 unchanged.
- Spec: `plans/extracted-audit/edits/I070.json`.
- Suggested commit message: `Audit I070: clear reward tiers, Dark Friar spriteset, dialog dictionaries`

Please commit when you're ready.
