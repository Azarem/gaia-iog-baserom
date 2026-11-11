# I062 - 2026-10-28 - files: tables/ability_anim_tables.asm, tables/spriteset_field_fx.asm, tables/movement_delta_table.asm
Status: COMPLETE

Spec: [edits/I062.json](../edits/I062.json). Proposals: [renames/I062_renames.md](../renames/I062_renames.md). Questions: [questions/I062_questions.md](../questions/I062_questions.md).

Conventions: verdicts **P/M/F/NA**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 coverage and verbosity, Q2 value, Q3 accuracy, Q4 mnemonic and variable names, Q5 new mnemonic, Q6 naming, Q7 evidence quality. Data tables get block and part notes only, no inline comments. `tables/movement_delta_table.asm` (4,852 lines) is **SAMPLED ~59%** of the chains node by node (50 of 85; the remaining 35 are counted and their lengths and endings checked, not read value by value); the counts in the block note (chain endings, node counts, value histogram, all 85 chain lengths) are whole-file.

### tables/ability_anim_tables.asm (2 pointer tables of 3 entries, 6 records, 67 lines after, Bank 01 121255-121278, parts: 0 code / 8 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | Two short paragraphs, no record decode, no per-record note | E1 |
| Q2 value | M | Gave the right ability order but not what a record holds or where it comes from | E1, E3 |
| Q3 accuracy | **F** | (a) **"Each entry is a sprite frame/hitbox/timing config"** and **"6-byte record with sprite frame indices, hitbox dimensions, and timing data"**: the record is `{ word $0000, word pointer to the upgrade-level word ($0B16-$0B20), one damage byte per level }`; the loaders store `record[4 + level]` in `climbStateData` ($09E0 Will, $09E2 Freedan), the damage bonus. `attack_ability_system` already documented this; the table header contradicted it. (b) **"stored to climbStateData registers ($09E0/$09E2)"** (plural, three fields) is wrong: one byte per call. (c) **"6-byte record"**: Dark Friar is 7 bytes (three levels). (d) the first word of every record is `$0000` and never read | E1 (`LoadAbilityAnimTableA/B`), E2 (`jeweler_gem` rewards, `attack_ability_system` header), E3 |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | `will_ability_anim_table` / `freedan_ability_anim_table` and `binary_01D9..` name animation; the file name too | PROPOSED R-I062-1 |
| Q7 evidence quality | M | E1 + E2; all six records decoded byte by byte; the damage meaning is from the `attack_ability_system` note (the loader ends in `climbStateData`, whose consumer `combat_collision` was not re-read) | E1, E2 (UNVERIFIED-RUNTIME: OQ-I062-2) |

Actions taken: block note rewritten (record format, ability and level table, level-word writers); 8 part notes (2 tables, 6 records); no inline comments; no mnemonics added.
Deferred: R-I062-1, R-I062-4.
Before/after stats: 34 to 67 lines; generic labels remaining: 6 (`binary_01D9AD` ... `binary_01D9D2`, each with a part note).

### tables/spriteset_field_fx.asm (1 animation table, 1 frame list, 4 sprite groups, 61 lines after, Bank 14 14C0CA-14C12B, parts: 0 code / 6 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 3-line header with no consumer and no frame decode | E1 |
| Q2 value | M | "Small set with 4 sprite groups used for non-combat environmental particles" gave no user | E1, E2 |
| Q3 accuracy | **F** | (a) **"miscellaneous field visual effects ... environmental particles"**: the only reference in the extraction is `gold_ship/adrift/dc2F_adrift_fx`, one of four tile-streaming effect actors, whose header calls it ocean waves. (b) **"4 sprite groups"**: it is one animation of four frames (one group per frame, 8 ticks each), and the groups are pictures streamed to VRAM word `$2010` from `misc_fx_1CD180` (offsets 0, 128, 256, 384 bytes), so the last word of the sprite-part is an art offset, not a tile number | E1 (`cop_handlers_sprite` tile-streaming section, `dc2F_adrift_fx`), E2 (whole-extraction search) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | `spriteset_field_fx` suggests a general field effects set | PROPOSED R-I062-2 |
| Q7 evidence quality | M | E1 + E2; the high byte `$0A` of the sprite-part word and the DMA bytes were not traced | E1, E2 (UNVERIFIED-RUNTIME: OQ-I062-1) |

Actions taken: block note rewritten (consumer, tile-streaming mechanism, frame decode); 6 part notes (the index table, the frame list, 4 frames); no inline comments; no mnemonics added.
Deferred: R-I062-2.
Before/after stats: 42 to 61 lines; generic labels remaining: 5 (`sprite_set_14C0CA`, `sprite_group_14C0DC` ... `14C118`, each with a part note).

### tables/movement_delta_table.asm (1 pointer table of 85 entries + 1,173 delta nodes, 4,852 lines after, Bank 01 110726-115587, parts: 0 code / 1,174 data) SAMPLED ~59%

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | Two paragraphs; no family breakdown, no chain-ending rules, no note on any chain | E1 |
| Q2 value | M | The table is the target of nearly every movement operand and the old note did not say how a chain is consumed or how it ends | E1, E2 |
| Q3 accuracy | **F** | (a) **"Simple entries ($00-$11) are single constants"**: `$00` is a null chain (applied once, then the pointer is cleared) and `$11` is a 2-node cycle (+1, 0); the constants are `$01`-`$10` (odd = +n, even = -n, n = 1..8) and `$11`-`$14` are fractional speeds (+/-1/2, +/-1/4). (b) **"Self-referencing next = hold constant"** is right but the 26 back-links (cycles) and the 1 null link were not described: 85 = 1 + 58 + 26. (c) **"camera scrolling"** is not a user (`AnimFrameLookup` is called only by three COP handler files; the world map moves the camera from the route position). (d) **"acceleration ramps, arcs"**: true for the sampled chains, but several are pulses and pauses (`$3C` +8,0,0,0; `$53` 16 still then 16 at -1), and `$16` / `$17` simply duplicate `$01` / `$02` | E1 (`ApplyMovement`, `AnimFrameLookup`, `ReadDirSprite_*`), E2 (50 chains dumped, `hit_stagger_controller`, `ramps`, `attack_ability_system`, `WorldMapController`, `unused_particle_rain_spawner`), E3 |
| Q4 mnemonic/var names | NA | Data only; `$2C` / `$2E` chain pointers already named in other files | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | 1,173 `delta_node_01B...` offset names; the 85 chain heads have no entry names | PROPOSED R-I062-3 |
| Q7 evidence quality | M | **Sampled** (50 of 85 chains node by node, all 85 lengths and endings by search); two curves ($22 / $23 hit stagger, $36 attack) verified against the numbers written in the consuming files' notes, both match | E1, E2 (UNVERIFIED-RUNTIME: OQ-I062-3, OQ-I062-4) |

Actions taken: block note rewritten (node and chain format, chain endings, index families, chain lengths, value histogram, users, old wrong claims); 13 part notes (the table and 12 chain heads: `$00`, `$01`-`$10` group, `$11`-`$14` group, `$15`, `$16`/`$17`, `$18`, `$22`, `$23`, `$36`, `$3C`/`$3F`, `$53`, `$54`); no inline comments; no mnemonics added.
Deferred: R-I062-3, R-I062-4.
Before/after stats: 4,787 to 4,852 lines; generic labels remaining: 1,173 (`delta_node_01B...`; 12 have part notes).

### Iteration summary

- Files: 3 audited. Q3: 3 F. Notes written: 3 block notes, 27 part notes (8 + 6 + 13), no inline comments.
- Verification: `npm run extract:lt` run after each merge; both specs re-run as dry-runs report 0 changes; `npm run rebuild` OK, `artifacts/crc.json` checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged).
- Patterns: (1) a data table described by what its consumer's name suggests (animation config, field particles) when the bytes are damage values and a streamed art offset; (2) a file header that contradicts the consumer's own, already corrected note (`attack_ability_system`); (3) "single constants" for a table whose entries differ in how they end (null, hold, cycle); (4) an unreferenced user (camera) added to a consumer list.

Suggested commit message: `Audit I062: document ability damage tables, adrift wave spriteset and movement delta chains`
