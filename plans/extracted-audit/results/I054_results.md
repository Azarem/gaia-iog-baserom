# I054 - 2026-10-28 - files: functions/StandardEnemyDefeatHandler.asm, system/boot_logos/boot_logo_palette_enix.asm, system/boot_logos/boot_logo_palette_quintet.asm
Status: COMPLETE (P2 phase end: I025-I054)

Spec: [edits/I054.json](../edits/I054.json). Proposals: [renames/I054_renames.md](../renames/I054_renames.md). Questions: [questions/I054_questions.md](../questions/I054_questions.md).

Conventions: verdicts **P/M/F/NA**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (UNVERIFIED-RUNTIME: Mesen2 is connected but has no ROM loaded). Q1 coverage and verbosity, Q2 value, Q3 accuracy, Q4 mnemonic and variable names, Q5 new mnemonic, Q6 naming, Q7 evidence quality.

### functions/StandardEnemyDefeatHandler.asm (4 entries + 12 inner labels, 210 lines, Bank 00 56202-56816, parts: 20 code / 0 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 7-line header, 3 comments and no part notes; the 15 inner labels had no explanation of the flow | E1 |
| Q2 value | M | The reader could not tell which enemies are counted, what the 3 entry routes are, or when a gem or the stat reward comes | E1, E2 |
| Q3 accuracy | **F** | (a) **Nobody assigns it as the OnDeath callback**: the old header said `ComposeDigitSprites_AtCursor` stores it in `$7F1004` "during enemy setup"; no code there references it. It is the engine's default: `hit_stagger_controller` (`HitStaggerResolveHit`) and two inline paths in `combat_collision` point the victim's entry at it when HP reaches zero and `$7F1004` is empty. (b) **13 enemy scripts, not "~20"**, JumpFar into it (the 13 names are in the block note), plus `EnemyDefeatDispatch`, two statues that enter `EnemyDefeatFlashAndDrop` directly, and the 3 engine sites. (c) **Size ~614 bytes, not ~360**; the call is `ClearSolidHere`, not `ClearLowHere`. (d) **`$12 |= $1000` on the children is not a "priority boost"**: `CopyActorState` clears the bit and the flash, the reveal effect and the reward pickup need it to keep running in display-filter actor mode (`displayModeFlags $0080`, set by `EnemyStatBonusReward`). (e) **The gem condition was inverted**: gems drop when scene flag `$0300 + scene` is SET (the reward was already claimed) or enemies remain; the last enemy of an unclaimed scene gets no gem because the stat reward replaces it (the same inversion is in `EnemyDropSystem.asm` line 5). (f) **`orbitAngle` is the remaining-enemy count** written by the kill counter; 0 means the last kill. (g) **The no-stats test is `statsPtr == enemy_stats_table`** (first entry, `EnemyInitBasic` actors with HP 1) and, together with the boss bit `$0080` of `extendedFlags`, skips counters, kill flag, drop and reward and goes to `EnemyDefeatBossCleanup`. (h) **Reward tiers**: `enemy_clear_reward_table[scene]` 0 none, 1 HP, 2 STR, 3 or more DEF; the flag is set later by `RewardActorVFX`, which also clears the display filter. One comment (56323, on `LDA $statsPtr` in the gem path) was wrong and is removed | E1 (the file; `EnemyDefeatDispatch`, `EnemyDropSystem`, `reward_actors` lines 3 and 109-114, `flag_helpers`, `combat_collision` and `hit_stagger_controller` entry-point writes, `sprite_composition` filter test, `enemy_clear_reward_table`), E2 (`rg` of the 13 `JumpFar` sites), E3 (`data-tables-memory.md` lines 565 and 590; `actor-organization-analysis.md` line 230) |
| Q4 mnemonic/var names | M | `orbitAngle` is the remaining count here (a name for other uses, R-I054-2); `$2C` / `$2E` are raw actor fields, `$0003,Y` is the stats byte; `moveScratch1/2` are right | E1 |
| Q5 new mnemonic | NA | Every address used already has a mnemonic | E1 |
| Q6 naming | M | `StandardEnemyDefeatHandler` also does counting, flash, reveal and reward, but it has 14+ referencing files and is a fair "standard" name; 15 `loc_` / `code_` labels are phases of the flow | PROPOSED R-I054-1 |
| Q7 evidence quality | M | E1 + E2 + E3; the counters' initial values and the actual reward / gem / reveal behaviour in play were not run | E1, E2 (UNVERIFIED-RUNTIME: OQ-I054-2, OQ-I054-3, OQ-I054-4, OQ-I054-5) |

Actions taken: block note rewritten (entry routes, flow, corrections); 18 new part notes and 2 updated (all inner labels, `EnemyGemDropRouter`, `EnemyStatBonusReward` and the four reward tiers); inline comments 34 new, 2 updated and 1 removed; no mnemonics added.
Deferred: R-I054-1, R-I054-2, R-I054-3; OQ-I054-2, OQ-I054-3, OQ-I054-4, OQ-I054-5.
Before/after stats: file 210 to 253 lines; inline comments (in notes) 3 before, 37 after; header comment lines 7 before, 15 after; generic labels remaining: 15 (all now have part notes).

### system/boot_logos/boot_logo_palette_enix.asm (1 thinker, 20 lines, Bank 00 47167-47186, parts: 2 code / 0 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 3-line header and no comments; the three bundle IDs and their effect were not mentioned | E1 |
| Q2 value | M | Nobody could tell what the thinker plays or on which palette | E1, E2 |
| Q3 accuracy | **F** | (a) **"The first of three thinkers" that "animates the Enix logo colors" is a reading from the file name**: the thinker list of scene `$FB` (`thinker_spawn_0CEB1D`, slot 0, param `#01`) starts it together with the other two and they run side by side, in both visits of the scene. (b) **It plays palette bundles `$50`, `$52`, `$54`** (`PaletteStart` + `PaletteStep`: the bundle runs to its end) and writes CGRAM colours `$81`-`$8F`, i.e. colours 1-15 of OBJ palette 0. (c) **The param byte `#01` is never read** (`PaletteStart` overwrites `animScratch+2`). (d) **What the bundles hold**: `$50` a black start and a 13-colour ramp from `$2C4B` to white whose white tip moves from colour 1 to 13; `$52` the ramp turns white while colours 14 and 15 brighten; `$54` white fades back to the ramp; 8 one-frame sub-entries each with 1 / 1 / 3 extra ticks. (e) **Which logo uses OBJ palette 0 was not traced** (OQ-I054-1): the "Enix" in the name comes from the spawn order | E1 (the file; `cop_handlers_palette`, `hdma_dma_spc` `LoadPaletteBundle` doc, `palette_bundles` dump of `$50`-`$55`, `scene_thinkers` entry `FB`), E3 (`docs/code/bank00/thinkers-system.md`) |
| Q4 mnemonic/var names | NA | No mnemonics; the one COP operand pair is bundle IDs | E1 |
| Q5 new mnemonic | NA | | E1 |
| Q6 naming | M | The name rests on spawn order, not on the logo that uses the palette | PROPOSED R-I054-4 |
| Q7 evidence quality | M | E1 + E2 + E3; the colour values were read from the table (no screenshot) | E1, E2 (UNVERIFIED-RUNTIME: OQ-I054-1) |

Actions taken: block note rewritten (the bundles, the colour effect, corrections); 2 new part notes; 4 new inline comments; no mnemonics added.
Deferred: R-I054-4; OQ-I054-1.
Before/after stats: file 20 to 36 lines; inline comments (in notes) 0 before, 4 after; header comment lines 3 before, 15 after; generic labels remaining: 1 (`code_00B841`, has a part note).

### system/boot_logos/boot_logo_palette_quintet.asm (1 thinker, 20 lines, Bank 00 47187-47206, parts: 2 code / 0 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 3-line header and no comments | E1 |
| Q2 value | M | Nobody could tell what palette it writes or how it relates to the Enix thinker | E1, E2 |
| Q3 accuracy | **F** | (a) **It does not run "after the Enix palette sequence"**: it is slot 1 of the same thinker list and runs in parallel with the other two. (b) **It plays bundles `$51`, `$53`, `$55`**, which hold the same colour frames as `$50`, `$52`, `$54` but write CGRAM colours `$91`-`$9F`, i.e. colours 1-15 of OBJ palette 1; same 1 / 1 / 3 extra ticks. (c) The param byte `#01` is never read. (d) Which of the two logos uses OBJ palette 1 was not traced (OQ-I054-1) | E1 (the file; `palette_bundles` dump, `scene_thinkers`), E2 (the twin file) |
| Q4 mnemonic/var names | NA | | E1 |
| Q5 new mnemonic | NA | | E1 |
| Q6 naming | M | As the Enix thinker | PROPOSED R-I054-4 |
| Q7 evidence quality | M | E1 + E2; as above | E1, E2 (UNVERIFIED-RUNTIME: OQ-I054-1) |

Actions taken: block note rewritten (bundles `$51` / `$53` / `$55`, corrections); 2 new part notes; 3 new inline comments; no mnemonics added.
Deferred: R-I054-4; OQ-I054-1.
Before/after stats: file 20 to 28 lines; inline comments (in notes) 0 before, 3 after; header comment lines 3 before, 7 after; generic labels remaining: 1 (`code_00B855`, has a part note).

### Iteration summary

Totals (from the dry run): 3 block notes updated; 22 part notes added and 2 updated; 41 inline comments added, 2 updated and 1 removed. No mnemonic, name or block change; the ROM is unchanged.

Cross-file notes (not edited here): `docs/code/bank00/data-tables-memory.md` line 565 ("~20 All enemy actors via death callback pointer": 13 JumpFar sites plus the default and the engine sites) and line 590 (`ComposeDigitSprites_AtCursor` is not the setter of the pointer); `docs/actor-organization-analysis.md` line 230 ("Standard actor slot initialization": it is the standard defeat sequence); `docs/code/bank00/actors-player-rewards.md` line 111 ("individual drops": the stat reward belongs to the LAST enemy of a scene); `extracted/functions/EnemyDropSystem.asm` line 5 repeats the inverted gem condition (fix through a notes spec of its own).

Gate: `npm run merge -- plans/extracted-audit/edits/I054.json --dry-run` reported 3 files (all bank00); after the real merge, `npm run extract:lt` and second dry runs of I053 and I054 reported 0 notes files to change. `npm run rebuild` succeeded and `artifacts/crc.json` reads checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged). Note: `notes/*/bank0A.json` show changes in the working tree from the I051 / I052 results (which exist and were included in the roll-up below); they are not part of this iteration.

Spec: `edits/I054.json`.

## P2 phase roll-up (I025 to I054, 30 iterations, 91 file tables)

Scope: shared runtime code (player, inventory, functions, thinkers, actors). Every iteration I025-I054 has a results file (I051 and I052 were done in a separate pass on 2026-10-28). Parsed rows: 91 per question, except Q4 / Q5 where one earlier table uses a free-form row (counts there are 90).

### Verdict distribution (counts of file tables)

| Q | P | M | F | NA |
|---|---|---|---|----|
| Q1 coverage/verbosity | 1 | 86 | 4 | 0 |
| Q2 value | 1 | 85 | 4 | 0 |
| Q3 accuracy | 1 | 7 | **83** | 0 |
| Q4 mnemonic/var names | 9 | 67 | 0 | 14 |
| Q5 new mnemonic | 0 | 17 | 0 | 73 |
| Q6 naming | 9 | 72 | 10 | 0 |
| Q7 evidence quality | 1 | 90 | 0 | 0 |

Reading: the extracted comments were rarely absent (Q1 F only where a file had none) but **91% of the files carried at least one factual error in the header, a part note or an inline comment (Q3 F)**; Q7 is M almost everywhere because no runtime (E5) check was run in this campaign (Mesen2 is connected but has no ROM loaded), so every behavioural claim is E1 / E2 / E3 and the audits finish with questions marked UNVERIFIED-RUNTIME. A "P" in any question was rare (9 of 91 for Q4 and Q6; 1 for the others).

### Most common failures (Q3), by frequency of the pattern

1. **Wrong flag-bit meanings**: the same bit explained by the wrong system, e.g. `$10 $4000` (off-screen flag from `SortActorsByDepth`, called a kill / arrival flag), `$10 $2000` (hidden, called frozen / walk-through / ability lock), `$12 $0004` (pause-filter immunity, called a collision layer), `$12 $1000` (display-filter qualifier, called priority boost), `displayModeFlags $0080` (display-filter actor mode, called a screen transition), `extendedFlags $0080` (boss bit), `playerFlags` bits.
2. **Names and headers that describe the intended behaviour, not the code**: "chase" / "homing" for a one-shot aim, "drift" for a curve, "OnDeath callback assigned during setup" for an engine default, "first thinker animates the Enix logo" from a file name; handler labels naming the wrong direction (`East*` for south-south-east, `SouthPrimary` for north-north-west).
3. **Comments on the wrong instruction or about the next block**: shifted by one or two instructions, duplicated, or describing the following branch; several first-instruction comments of a block described the block, not the instruction.
4. **Inverted conditions**: carry-set vs carry-clear and flag-set vs flag-clear tests (the gem rule, `TestFlag_0300`, `BCS` / `BCC` meaning), and "skip when" vs "run when".
5. **Numeric and unit errors**: byte counts and sizes (360 vs 614), caller counts ("~20" vs 13 + engine sites), tile vs pixel units, decimal vs hexadecimal literals, `$FFF0` quoted from the ROM where `transforms.json` widens it to `$FFFC` in the extracted asm.
6. **Hidden side effects missing**: a routine documented for its main effect that also hides the player, sets transition words, clears save flags, pays 100 gems or overwrites scratch (`$0000` / `$0002` / `$0018` / `$001C`); and callers of shared helpers not listed.
7. **Vanilla vs transformed values**: comments quoting values that `transforms.json` changes (button masks).
8. **Cross-document staleness**: the same wrong reading repeated in docs (`docs/code/**`), in the `extracted` headers of neighbour files (`EnemyDropSystem.asm` line 5) and in the WRAM map, so a correction in one file leaves 3 to 6 stale copies (the cross-file notes of every iteration list them).

### Recurring naming patterns (Q4, Q5, Q6; all logged, none applied)

- **Raw operands for DP scratch**: `$0000` / `$0002` / `$0018` / `$001C` and per-actor fields `$04` (prev-link), `$24` (target / spawn parameter), `$2A`, `$2C`, `$2E` stay unnamed; the convention (documented in the notes) is to explain them in comments rather than add global mnemonics, because the same field carries different roles per actor.
- **Mnemonics reused with another meaning** (`orbitAngle` as a fade counter, a remaining-enemy count or an angle; `orbitDiameter`, `currentHp`, `loopCounter`, `layerPriorityFlag`, `globalScriptIndex`): the recommendation is file-local aliases (R-I050-2, R-I054-2, R-I053-5) or a comment on the mnemonic, not a rename of the global name.
- **Auto labels as phase names**: every audited file with branches carries `loc_` / `code_` labels that are really phases or tails (8 to 15 per file in I053 and I054); each now has a part note and a proposed name (R-I053-1 to R-I053-6, R-I054-1).
- **Direction and axis labels** that are wrong or ambiguous (cardinal vs diagonal headings, primary / secondary axis names).
- **Names that say what the old author guessed** (Enix / Quintet thinkers by spawn order, `Drift`, `DarkGem*`): proposals wait for the runtime answers (OQ-I054-1).
- **Duplicated stubs with different constants** (`dark_space` vs `dark_space2`, the stat reward actors, the Enix / Quintet thinker twins): suggest display names in part notes, keep the actor names because scene tables use them.

### Phase conclusions

- P2 is complete at the notes level for 91 file tables; `npm run rebuild` after every iteration kept the CRC at checksum 223006080, crc 2083230829, totalSize 3062204 (the final run is above).
- Open items carried to the final consolidation: the rename ledger (R-I025 to R-I054, frozen ledgers not edited), the UNVERIFIED-RUNTIME questions (OQ-I025 to OQ-I054; a Mesen2 session with a loaded ROM would close most of them), and the stale-doc corrections listed in the cross-file notes.
- Next iteration (not started): I055 (`system/boot_logos/boot_logo_palette_third.asm`, `sFB_boot_logo.asm`, `spm_boot_logos.sprite.asm`), which also answers OQ-I054-1.

Suggested commit message: `audit(I053-I054): document smooth_follow_child, dark_space, game_over_sequence, StandardEnemyDefeatHandler and the boot-logo palette thinkers; P2 roll-up`

Please commit when you're ready.
