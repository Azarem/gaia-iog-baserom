# I069 - 2026-10-28 - files: tables/spriteset_freedan_fx.asm, tables/spriteset_shadow_fx.asm, tables/spriteset_enemies.asm
Status: COMPLETE

Spec: [edits/I069.json](../edits/I069.json). Proposals: [renames/I069_renames.md](../renames/I069_renames.md). Questions: [questions/I069_questions.md](../questions/I069_questions.md).

Conventions: verdicts **P/M/F/NA**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 coverage and verbosity, Q2 value, Q3 accuracy, Q4 mnemonic and variable names, Q5 new mnemonic, Q6 naming, Q7 evidence quality. Annotation style as in I049 to I068. `spriteset_enemies.asm` is **SAMPLED ~25%** for line-by-line review (pointer table, the sets and groups of the traced animations `$00`, `$01`, `$04`-`$06`, `$09`-`$0F`, `$10`, `$22`, `$25`, `$29`, `$35`, and the groups around `0EEE5E`); every count (animations, records, groups, rows, byte budget) was computed over the whole file. The sprite-set struct is documented once, in the `spriteset_freedan` block note of I063.

### tables/spriteset_freedan_fx.asm (1 table of 4 pointers, 4 frame lists, 13 groups, 147 sub-sprites, 251 lines before / 272 after, Bank 17 1548288-1549554, parts: 0 code / 18 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 3-line header; no part notes | E1 |
| Q2 value | F | No index-to-user mapping, no byte budget | E1 |
| Q3 accuracy | **F** | **"Sword trails, charge flashes ... attack trail sprites and Dark Friar launch effects overlaid on Freedan"**: the groups are full body poses of 9 to 14 sub-sprites, and the Dark Friar has its own set (`spriteset_dark_friar`). The set is `body_table` row `$06`, selected only by `SetPlayerSpriteDirect #06` in the Aura Barrier cast (`attack_ability_system`) and in `ClimbDropAttack` (`player_character`); `$00` and `$01` are the vine drop attack fall and landing, `$02` and `$03` the Aura Barrier cast and sustain | E1 (`ClimbDropAttack`, `ClimbDropLand`, the Aura Barrier cast), E2 (every `SetPlayerSpriteDirect` operand in extracted/) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | Offset-named sets are told apart only by index | PROPOSED R-I069-1 |
| Q7 evidence quality | M | Whole file read; byte arithmetic reconciles (8 + 60 + 1198 = 1266); the art was not viewed | E1, E2 (UNVERIFIED-RUNTIME: OQ-I069-3) |

Actions taken: block note rewritten (index-to-user table, byte budget, drop attack context); table part note (new); 4 set part notes (new); no inline comments (data); no mnemonics added.
Deferred: R-I069-1; OQ-I069-3.
Before/after stats: 251 to 272 lines; generic labels remaining: 17.

### tables/spriteset_shadow_fx.asm (1 table of 14 pointers, 14 frame lists, 16 groups, 82 sub-sprites, 252 lines before / 273 after, Bank 17 1552384-1553318, parts: 0 code / 31 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 3-line header; no part notes | E1 |
| Q2 value | F | Did not say that nothing selects this set | E1, E2 |
| Q3 accuracy | **F** | **"Attack trail sprites and liquify transformation overlays"**: unsupported. Body row `$07` is never selected (`SetPlayerSpriteDirect` operands in extracted/ are `$04`, `$05`, `$06`, `$08` only), so no animation of this set is staged by any script; 12 of the 14 animations are a single frame and six of them are the same 32-tick group `17B098` | E1, E2 (all `SetPlayerSpriteDirect` operands) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | As R-I069-1 | PROPOSED R-I069-1 |
| Q7 evidence quality | M | Whole file read; byte arithmetic reconciles (28 + 124 + 782 = 934); nothing was viewed; the reason for an unreferenced row could not be established | E1, E2 (UNVERIFIED-RUNTIME: OQ-I069-1) |

Actions taken: block note rewritten (index table, unused status, byte budget); table part note (new); 3 set part notes (new); no inline comments (data); no mnemonics added.
Deferred: R-I069-1; OQ-I069-1.
Before/after stats: 252 to 273 lines; generic labels remaining: 30.

### tables/spriteset_enemies.asm (1 table of 63 pointers, 63 frame lists, 257 frame records, 144 printed groups, 640 printed sub-sprite rows, 1879 lines before / 1944 after, Bank 0E 974848-982479, parts: 0 code / 208 data) SAMPLED ~25%

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 3-line header; no part notes, no index-to-user mapping | E1 |
| Q2 value | F | The one thing a reader of an actor needs (what each index is) was missing | E1, E2 |
| Q3 accuracy | **F** | (a) **"Shared by all dungeon enemies, boss sub-sprites, dark gem animations and combat VFX"**: 84 actor files select it, and they are pickups, switches, effects and props; the gem animations are `$04`-`$06` and `$09`-`$0B` (`EnemyDropSystem`), the stat pickups `$0C`-`$0E`, the death flash `$01`. (b) **"The largest spriteset file in the game"**: it is 7631 bytes; `spriteset_will` (17441), `spriteset_shadow` (12443) and `spriteset_ability_fx` (11653) are larger. (c) **Undocumented extractor artefact**: group `0EEE5E` prints 14 rows but its header counts 11; rows `;0B`-`;0D` are the unreferenced group at `0EEEB8` | E1 (`EnemyDropSystem`, `EnemyDeathFlash`, `SpawnDebrisBurst`, `SpawnFieldRevealEffect`, `hit_switch`, `reward_actors`, `field_reveal_object`, `idle_sprite_display`), E2 (actor grep, block sizes from `blocks.json`) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | The name suggests enemies; the role is shared effects and pickups | PROPOSED R-I069-2 |
| Q7 evidence quality | M | Pointer table and traced windows read; the count of 63 / 257 / 144 / 640 and the byte budget (126 + 1154 + 6351 = 7631) were computed over the whole file; the other 40-odd animations were not mapped to users | E1, E2 (UNVERIFIED-RUNTIME: OQ-I069-2, OQ-I069-4) |

Actions taken: block note rewritten (corrected scope, structure counts, index-to-user table); table part note (new); 15 animation part notes (new); the hidden-group part note on `sprite_group_0EEE5E` (new); no inline comments (data); no mnemonics added.
Deferred: R-I069-2, R-I069-3, R-I069-4; OQ-I069-2, OQ-I069-4.
Before/after stats: 1879 to 1944 lines; generic labels remaining: 207.

### Iteration summary

- Files: 3 audited (1 sampled). Q3: 3 F. Notes written: 3 block notes, 26 part notes (all new), 0 inline comments.
- Patterns: (1) a purpose guessed from the file name ('shadow effects', 'enemies'); (2) a claim of rank ('largest') never checked against `blocks.json`; (3) an unreferenced row of a table that no code reaches (`body_table` row `$07`); (4) the extractor does not honour a group's count byte.
- Docs repeating old claims: `docs/bank01-data-tables.md` (lines 107-110, 496-497, 629-646, 710-711), `docs/structs-reference.md` (lines 920-927, 1106-1107), `docs/code/bank00/actors-player-rewards.md`, `docs/code/bank00/data-tables-memory.md`. Logged under R-I069-5.
- Gate: shared with I070: both specs merged, extract (see below), both spec dry-runs to 0 files to change, `npm run names -- --check` OK (2459 names), `npm run rebuild`: checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged). `npm run extract:lt` could not delete `extracted/tables` ("Device or resource busy": a handle held by some process), so its two steps were run by hand: `rm -rf extracted/tables/*` and `node --env-file=.env.local src/index.ts extract --linetracking`.
- Spec: `plans/extracted-audit/edits/I069.json`.
- Suggested commit message: `Audit I069: Freedan and Shadow FX spritesets, shared effects and pickups spriteset`

Please commit when you're ready.
