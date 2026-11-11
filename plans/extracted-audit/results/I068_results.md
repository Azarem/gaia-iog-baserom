# I068 - 2026-10-28 - files: tables/spriteset_npc_props.asm, tables/display_preset_table.asm, tables/scene_warps.asm
Status: COMPLETE

Spec: [edits/I068.json](../edits/I068.json). Proposals: [renames/I068_renames.md](../renames/I068_renames.md). Questions: [questions/I068_questions.md](../questions/I068_questions.md).

Conventions: verdicts **P/M/F/NA**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 coverage and verbosity, Q2 value, Q3 accuracy, Q4 mnemonic and variable names, Q5 new mnemonic, Q6 naming, Q7 evidence quality. Annotation style as in I049 to I067. `scene_warps.asm` is **SAMPLED ~18%** for line-by-line review (header and pointer table, lists `$00`-`$05`, `$61`-`$64`, `$E1`-`$E3` and the tail); every count (lists, entries, byte budget, value distributions) was computed over the whole file. The sprite-set struct is documented once, in the `spriteset_freedan` block note of I063.

### tables/spriteset_npc_props.asm (1 table of 11 pointers, 11 frame lists, 20 groups, 239 lines before / 262 after, Bank 0E 973312-974144, parts: 0 code / 32 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 3-line header; no part notes | E1 |
| Q2 value | F | No index-to-user mapping, which is the one thing a reader of an actor needs | E1, E2 |
| Q3 accuracy | **F** | **"Town furniture, signs, chests, and decorative elements used across multiple scene types"**: no chest uses it (chests are map tiles drawn by `warps_interaction`), there is no furniture; the users are the town door (`$00` open, `$01` closed), bone piles (`$02`), spirits (`$04`, 9 actors), a sign (`$05`), flames (`$06`: `av6B_flame`, `ec0A_torch1/2`), `freejia_street_prop` (`$07`), `st68_campfire` (`$08`) and `btE4_kara` (`$0A`); `$03` and `$09` have no user | E1 (actor files), E2 (grep of `SetMetasprite ( @spriteset_npc_props )` and the following `Stage*` operand) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | The name is acceptable for a prop set; the offset-named sets are told apart only by index | PROPOSED R-I068-1 |
| Q7 evidence quality | M | Whole file read (239 lines); byte arithmetic reconciles (22 + 102 + 708); the sprites were not viewed, so the appearance of `$02`, `$05`, `$07`, `$0A` comes from actor names | E1, E2 (UNVERIFIED-RUNTIME: OQ-I068-1, OQ-I068-2) |

Actions taken: block note rewritten (index-to-user table, byte budget); table part note (new); 2 part notes for the unused animations (new); no inline comments (data); no mnemonics added.
Deferred: R-I068-1; OQ-I068-1, OQ-I068-2.
Before/after stats: 239 to 262 lines; generic labels remaining: 31.

### tables/display_preset_table.asm (1 table of 47 pointers, 47 records of 10 bytes, 246 lines before / 267 after, Bank 01 98304-98868, parts: 0 code / 48 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | Two headers that repeat each other; nothing about the contents of the 47 records | E1 |
| Q2 value | F | Did not say what each byte is, nor the value distribution | E1 |
| Q3 accuracy | **F** | (a) **"Selected by scene metadata"**: scene command `$02` (`SceneCmd_ConfigDisplay`) of the scene script, operand = index. (b) **"BG mode/tile size ... and special flags", "every playable area references one of these presets"**: byte `+6` is only BGMODE (no tile-size bits are ever set: `$09` x45, `$07` x2); `+8/+9` are `$00` in all 47 records and unused (closes the old OQ-5); the second claim cannot be verified from the table | E1 (`SceneCmd_ConfigDisplay`), E2 (value counts over the 47 records) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | P | `display_preset_table` and `display_preset_XXXXXX` are accurate; offset names for records could be index names | PROPOSED R-I068-2 |
| Q7 evidence quality | M | Whole file read (246 lines); all field distributions computed over the 47 records with a read-only awk; the mode-7 presets confirmed through the pointer table (`$19` = `018158`, `$2D` = `018220`); which scenes use which preset not traced | E1, E2, E4 (CGWSEL/CGADSUB bit layout, nesdev) (UNVERIFIED-RUNTIME: OQ-I068-3) |

Actions taken: block note rewritten (record layout, value table, pointer order); table part note rewritten; 2 part notes for the mode-7 records (new); no inline comments (data); no mnemonics added.
Deferred: R-I068-2; OQ-I068-3.
Before/after stats: 246 to 267 lines; generic labels remaining: 47.

### tables/scene_warps.asm (1 table of 255 pointers, 200 lists, 543 scene-warps, 200 forced-walk warps, 2209 lines before / 2236 after, Bank 01 98868-108894, parts: 0 code / 201 data) SAMPLED ~18%

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | Header and part note repeat each other; no field layout, no counts | E1 |
| Q2 value | F | No field meaning, no flags, no mention that the pointers share lists | E1 |
| Q3 accuracy | **F** | (a) **"staircase warps with climb-animation offsets / stair-specific coordinate offsets"**: the second list holds forced-walk warps (no scene change): bytes `+4/+5` camera window, `+6` direction and pan list, `+7..+12` a walk stream `[dir][X word][Y word][dir]`; all 200 are vertical (100 north, 100 south), none east/west. (b) **"Both sub-types use $FF as list terminator"** is right, but the lists are concatenated (`[scene-warps] $FF [forced-walk] $FF`), so even an empty `warp-def` is 2 bytes. (c) the scene-warp byte `+9` is facing with bit 7 = save warp, `+10` the camera window; `docs/code/bank02/game-systems.md` has them swapped (flags / facing). (d) `docs/structs-reference.md` types the forced-walk entry as destScene/destX/destY/facing/flags, which is wrong (it follows the extractor's `stair-warp` struct) | E1 (`InitWarpTable`, `CheckWarpRectangles`, `ConvertWarpToPixels`, `ExecuteWarp`, `ExecuteForcedWalkWarp`, `StartForcedWalk`, `forced_walk`, `InitCameraBounds`), E2 (counts over the whole file), E3 (docs) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | The `stair-warp` struct and its fields hide the real layout; `warp_def_XXXXXX` fine | PROPOSED R-I068-3, R-I068-4 |
| Q7 evidence quality | M | Pointer table, 3 sampled windows and the tail read; byte budget reconciles exactly (510 + 543 x 12 + 200 x 13 + 400 = 10026); the layout comes from the code, spot-checked on 4 scene-warps and 3 forced-walk entries by hand; no run | E1, E2 (UNVERIFIED-RUNTIME: OQ-I068-4) |

Actions taken: block note rewritten (format, both layouts with examples, data facts, pan list statistics); table part note rewritten; 2 part notes for shared lists (new); no inline comments (data); no mnemonics added.
Deferred: R-I068-3, R-I068-4; OQ-I068-4; the pan list usage answers part of OQ-I064-1 (counts per list are in the block note).
Before/after stats: 2209 to 2236 lines; generic labels remaining: 200.

### Iteration summary

- Files: 3 audited (1 sampled). Q3: 3 F. Notes written: 3 block notes, 9 part notes (7 new, 2 updated: the old `display_preset_table` and `scene_warps` part notes), 0 inline comments.
- Patterns: (1) a purpose guessed from the file name ('furniture', 'chests', 'stair'); (2) a struct mislabelled by the extractor and then documented as labelled (the forced-walk warp is not a staircase warp); (3) a mechanism attributed to the wrong subsystem ('scene metadata' instead of scene command `$02`).
- Docs repeating old claims: `docs/bank01-data-tables.md` section 2 (stair-warp), `docs/code/bank02/game-systems.md` lines 820-880 (flags/facing swap; "walk completes -> ExecuteWarp path"), `docs/structs-reference.md` lines 1273-1340 (`stair-warp` fields), `docs/code/bank0D-scene-meta.md` line 105 (stale "Bank $02, table_018000"). Logged under R-I068-3 and R-I068-5.
- Gate: shared with I067: both specs merged, `npm run extract:lt`, both spec dry-runs to 0 files to change, `npm run names -- --check` OK, `npm run rebuild`: checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged).
- Spec: `plans/extracted-audit/edits/I068.json`.
- Suggested commit message: `Audit I068: NPC prop spriteset, display presets, scene and forced-walk warp table`

Please commit when you're ready.
