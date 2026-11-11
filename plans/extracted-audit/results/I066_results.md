# I066 - 2026-10-28 - files: tables/enemy_stats_table.asm, tables/spriteset_aura.asm, tables/spriteset_shadow.asm
Status: COMPLETE

Spec: [edits/I066.json](../edits/I066.json). Proposals: [renames/I066_renames.md](../renames/I066_renames.md). Questions: [questions/I066_questions.md](../questions/I066_questions.md).

Conventions: verdicts **P/M/F/NA**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 coverage and verbosity, Q2 value, Q3 accuracy, Q4 mnemonic and variable names, Q5 new mnemonic, Q6 naming, Q7 evidence quality. Annotation style as in I049 to I065. `spriteset_shadow.asm` is **SAMPLED ~10%** for line-by-line review (the table, the first frame lists and groups); the whole-file checks are in Q7. The struct format is documented once, in the `spriteset_freedan` block note of I063.

### tables/enemy_stats_table.asm (1 table of 110 rows, 121 lines before / 142 after, Bank 01 109552-109992, parts: 0 code / 1 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | Header and part note repeated each other; no per-row information | E1 |
| Q2 value | F | Nothing on who reads each byte, which rows are named by code, or which are all zero | E1, E2 |
| Q3 accuracy | **F** | (a) **"Type (0-3, affects damage calculations)"**: byte 3 is `gemDropType`, read only by `StandardEnemyDefeatHandler` / `EnemyGemDropRouter` (0 none, 1 `SpawnDropGem1`, 2 `SpawnDropGem2`, 3 or more `SpawnDropByHpTier`); 37 / 21 / 21 / 13 rows. (b) **"DEF $7F = immune to normal damage"**: `ApplyHitDamageToVictim` computes `max(1, totalStr - DEF) + characterForm`; `$7F` and `$FF` only pin the hit to its minimum, and the immunity bits are `$0010` / `$0020` of the actor's `$12`. (c) **"HP $7F / $FF = boss-tier"**: only rows `$06` (HP `$7F`) and `$21`, `$22` (HP `$FF`) have those values and nothing marks them as bosses (the boss bit is `extendedFlags $0080`, set by the actor). (d) **"The combat system reads these values for all damage calculations"**: the player's attack box (`PlayerAttackHitTest`) uses `chainDamage / 2 + 1` and never reads the table | E1 (`combat_collision`, `actor_execution` InitActorFromSceneData, `StandardEnemyDefeatHandler`, `EnemyInitBasic`), E2 (whole-file counts, `statsPtr` operand search), E3 (`docs/structs-reference.md` already had the right field names) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | Single table label; the rows have no names (the enemy is named by the actor, not the row) | PROPOSED R-I066-2 |
| Q7 evidence quality | M | Whole file read (121 lines); field readers traced for rows `+0` to `+3`; `statsPtr` users listed by whole-file search (18 rows named by code); 16 rows without a reader found by diffing the scene spawn indices with the code operands; the damage paths were not run (UNVERIFIED-RUNTIME) | E1, E2 (OQ-I066-1, OQ-I066-2) |

Actions taken: block note rewritten (fields and readers, damage paths, gem rule, whole-table facts, rows named by code); table part note rewritten; no inline comments (data); no mnemonics added.
Deferred: R-I066-2; OQ-I066-1, OQ-I066-2.
Before/after stats: 121 to 142 lines; generic labels remaining: 0.

### tables/spriteset_aura.asm (1 table of 3 pointers, 3 frame lists, 12 groups, 30 sub-sprites, 125 lines before / 152 after, Bank 17 1544192-1544618, parts: 0 code / 16 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 3-line header; no part notes | E1 |
| Q2 value | F | No animation roles, no art or palette destination, no user | E1, E2 |
| Q3 accuracy | **F** | **"4 animation frames for the rotating barrier sprites"**: the table has 3 animations of 4 frames; `$00` and `$01` are played once as the orbital grows in, `$02` loops while the orbit runs, and the shrink plays `$01` then `$00`. The orbitals are `AuraProjectileChild` actors (2, or 4 with flag `$0B1E`) moved by `AuraOrbitalSpawner`; the sprites are not "around the player" as a ring sprite | E1 (`AuraProjectileChild`, `AuraProjectileShrink`, `AuraOrbitalSpawner`, `UpdateOrbitalPositions`) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | `sprite_set_17xxxx` / `sprite_group_17xxxx` offset names | PROPOSED R-I066-1 |
| Q7 evidence quality | M | Whole file read (125 lines); byte check `426 = 6 + 3 x 18 + 12 x 13 + 30 x 7`; art and palette destinations read in `AuraVramDmaLoader` and `AuraBarrierMain`; the VRAM tile numbering assumes the sprite name base `$4000` (OBSEL not traced) | E1, E2 (UNVERIFIED-RUNTIME: OQ-I066-3, OQ-I066-4) |

Actions taken: block note rewritten (users, animation roles, art and palette, byte check); 5 part notes (new: the table, the three lists, one group); no inline comments (data); no mnemonics added.
Deferred: R-I066-1; OQ-I066-3, OQ-I066-4.
Before/after stats: 125 to 152 lines; generic labels remaining: 15.

### tables/spriteset_shadow.asm (1 table of 76 pointers, 76 frame lists, 261 records, 168 groups, 1273 sub-sprites, 2689 lines before / 2705 after, Bank 14 1343488-1355931, parts: 0 code / ~245 data) SAMPLED ~10%

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | F | A 3-line header; no index map, no counts, no part notes | E1 |
| Q2 value | F | Nothing on the shapes, the differences from the other two forms, or the shared index space | E1, E2 |
| Q3 accuracy | **F** | **"liquify animation frames", "Shadow's unique morph poses"**: no `liquify` or morph name exists in the player scripts or in any other file but the two Shadow spriteset headers; the table has the same 76 indices as the Freedan table and the other form's data. Shadow's mode body is `spriteset_shadow_mode` (`body_table` row `$08`) | E1 (player scripts, `body_table`), E2 (whole-file `rg liquif`) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | 76 `sprite_set_14xxxx` and 168 `sprite_group_14xxxx` offset names | PROPOSED R-I066-1 |
| Q7 evidence quality | M | **Sampled** for line reading; whole-file lookups: frame counts and holds of all 76 lists listed and compared with the Freedan list shapes, count byte equal to the number of sub-sprites in all 168 groups (at most 14), all 168 groups use the default attack box and are referenced, 75 list spacings equal `4n + 2`, `12443 = 152 + 4 x 261 + 2 x 76 + 13 x 168 + 7 x 1273` | E1, E2 (UNVERIFIED-RUNTIME: OQ-I066-5) |

Actions taken: block note rewritten (differences from Freedan by index, the liquify claim, checks); 2 part notes (the table with the shapes, the first group); no inline comments (data table); no mnemonics added.
Deferred: R-I066-1; OQ-I066-5.
Before/after stats: 2689 to 2705 lines; generic labels remaining: 244.

### Iteration summary

- Files: 3 audited (1 sampled). Q3: 3 F. Notes written: 3 block notes, 8 part notes (1 updated: `enemy_stats_table`; 7 new), 0 inline comments.
- Patterns: (1) a field named from its position instead of its reader (a drop type described as a damage type); (2) a flag value read as a state (`DEF $7F`) when it only saturates a formula; (3) a purpose taken from a file or sprite name ("liquify", "rotating barrier") that the code does not use.
- Docs repeating old claims: none found for the stats table (`docs/structs-reference.md` already names `gemDropType` and the min-1 formulas); the Aura and Shadow headers were the only source of the old claims.
- Gate: shared with I065: `npm run merge` for both specs (dry-run first), `npm run extract:lt`, both spec dry-runs to 0 files to change, `npm run rebuild`: checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged).
- Spec: `plans/extracted-audit/edits/I066.json`.
- Suggested commit message: `Audit I066: enemy stats fields and readers, Aura orbital spriteset, Shadow spriteset`

Please commit when you're ready.
