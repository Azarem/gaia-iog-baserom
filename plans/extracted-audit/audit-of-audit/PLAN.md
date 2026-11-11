# Audit of the audit — iteration plan

Scope: everything under `plans/extracted-audit/` (iterations I001–I072 plus B001), the notes, names and docs they changed, and the tooling around them.
Goal: validate facts and name / note / comment integrity, and turn the result into an action plan. Open questions are handled in a separate pass (A12 only builds the registry).

Companions in this folder: `report.md` (version 2, the action plan AP-01…AP-23), `digest_I001-I020.md`, `digest_I021-I040.md`, `digest_I041-I072.md`.

Rules for every audit iteration (A-steps): no sub-agents, no scripts, no edits to the frozen ledgers. Findings go to a NEW file `audit-of-audit/A<NN>_findings.md`, written whole. Evidence is grep / read only. Every finding says whether it was **VERIFIED** against the live files this pass or only **REPORTED** by a ledger.

Fix work is NOT part of the A-steps. Fixes are the F-steps (end of this file), run only after the matching A-step or an explicit user go-ahead.

## Status

| Step | Scope | Status |
|---|---|---|
| A00 | Cross-cutting pass. Output: `report.md` (version 2, after reading **every** results file, all apply summaries and the four sanity checks) | **DONE** |
| A01 | I001–I020: results read in full → `digest_I001-I020.md`; 96-row status table, OQ-1…OQ-69 registry, 25 fact re-checks (18 correct, 7 wrong), mnemonic counts and defect sweep → `A01_findings.md` | **DONE** (`A01_findings.md`) |
| A02 | I021–I030: results read → `digest_I021-I040.md`; 49-row rename and Q5 status table, 54-question registry, 23 fact re-checks, class sweep and transform inventory → `A02_findings.md` | **DONE** (`A02_findings.md`) |
| A03 | I031–I040: results read → `digest_I021-I040.md`; 48-row rename and Q5 status table, 57-question registry, 35 fact re-checks, I035/I036-after-I037 ordering table, class sweep and transform inventory → `A03_findings.md` | **DONE** (`A03_findings.md`) |
| A04 | I041–I050: results and sanity check read → `digest_I041-I072.md`; 56 rename + 2 sanity rows and 30 Q5 rows status, 53-question registry, 34 fact re-checks, WaitByte sweep, class sweep and transform inventory → `A04_findings.md` | **DONE** (`A04_findings.md`) |
| A05 | I051–I060: results and sanity check read → `digest_I041-I072.md`; 59 rename + 4 sanity rows and 30 Q5 rows status, 64-question registry, 26 fact re-checks over 25 files, WaitByte sweep, class sweep and transform inventory → `A05_findings.md` | **DONE** (`A05_findings.md`) |
| A06 | I061–I064 and B001: sanity-style re-verification (this range never had a sanity pass) → 16 files, 21 findings (19 VERIFIED, 2 REPORTED), negative-proof rg log, B001 reader check, class sweep → `A06_findings.md` | **DONE** (`A06_findings.md`) |
| A07 | I065–I068: sanity-style re-verification → 12 files, 24 findings (22 VERIFIED, 2 REPORTED), checks (a)–(e), negative-proof rg log, class sweep → `A07_findings.md` | **DONE** (`A07_findings.md`) |
| A08 | I069–I072: sanity-style re-verification → 12 files, 18 findings (16 VERIFIED, 2 REPORTED), checks (a)–(e), hidden-group list (7 groups), negative-proof rg log → `A08_findings.md` | **DONE** (`A08_findings.md`) |
| A09 | Notes JSON sweep, banks 00–01: `blockNotes` / `partNotes` / `comments`. Orphan keys, history narration, ID citations, hedges, nickname drift | **DONE** (`A09_findings.md`) |
| A10 | Notes JSON sweep, banks 02–0F (including `comments`) | DONE: `A10_findings.md` |
| A11 | Docs reconciliation: every doc row ("R-*-5", "D-*") marked done versus the live docs; `gaia-core/docs/notes-and-comments.md` rename checklist; gaia-knowledge corpus refresh | DONE: `A11_findings.md` |
| A12 | Open-question registry: all OQ ids, classification (static / runtime / duplicate / answered later), links to evidence. Feeds the separate OQ document | DONE: `A12_findings.md` |
| A13 | Generic-label backlog triage for the audited ranges (engine, string labels, sprite labels) into a naming plan | DONE (`A13_findings.md`) |
| A14 | Mnemonic / struct / copdef backlog consolidation (Q5 rows never applied) | DONE: A14_findings.md |
| A15 | Tooling backlog: specs for `merge --check` orphan sweep, plain-mode gate, transform guard, extractor hidden-group fix, doc-script policy | **DONE** (`A15_findings.md`) |

Reading note: A06–A08 are the live-file re-verification of I061–I072 + B001 (results already read in `digest_I041-I072.md`). New action items found in version 2 of the report: AP-18 (transform guard), AP-19 (dead-code marker), AP-20 (findings home), AP-21 (mnemonic renames), AP-22 (ledger errata), AP-23 (`CrystalBallAutoUse` rebuild error).

Order: **A15 decision items AP-01 and AP-18 first** (the gate does not cover the plain build; notes next to multi-line transforms can break the ROM), then A06–A08 (no sanity pass yet), then A01–A05 and A09–A10 in parallel streams, then A11–A14. F-steps follow their A-step.

Size estimates (to keep each step to one sitting):
- Results files are 15–60 KB each, 3 files per iteration. A02–A05 each cover 10 iterations, so about 1 MB of ledger text. Read per iteration, not per file.
- Notes JSON per bank can be large. Read with grep for the defect classes below, then open hits only.

## Defect classes to check in every audit step (checklist for A01–A10)

(Numbers 1–10 are the classes; `report.md` §7 has the statistics.)

1. Purpose guessed from a label name (no code trace cited).
2. `WaitByte(n)` / `WaitWord(n)` stated as n ticks (the runner skips n passes, so n+1 ticks).
3. Comment or note not updated after a rename or after a finding (stale operand names, stale block names, nicknames).
4. History narration in a note ("previously …", "the old header listed …", "was misnamed …").
5. Opcode table or handler list whose descriptions belong to a different row or handler.
6. Inline comment that contradicts the code it sits on (compare branch direction, compare operands).
7. Note citing an OQ / R id with no meaning inline.
8. Hidden or unreferenced sprite groups printed as extra sub-sprites (extractor artefact).
9. Unnamed fixed-address operands that now have an established meaning (mnemonic candidates).
10. Label / block / struct name that encodes a retired nickname.
11. Wrong flag-bit meaning, wrong hardware register or bit, inverted branch condition, swapped answer.
12. A note on a label that a multi-line `transforms.json` regex needs adjacent (transform-adjacency hazard).
13. Button names: vanilla vs the remapped bits in this build.

---

## Agent prompts

### How to use
1. Open a **new chat** in the multi-root workspace (`gaia-snes.code-workspace`) so `gaia-knowledge`, `gaia-core` and `gaia-iog-baserom` are loaded.
2. Paste **the Common preamble** and then **the step prompt** (A-step or F-step) below, as one message. Replace nothing unless a `<…>` placeholder says so.
3. When the agent finishes, check the findings file and the status row, then commit yourself.
4. Do not combine steps in one chat; each prompt is sized for one sitting.

### Common preamble (paste first, every time)

```text
You are continuing the "audit of the audit" for the Illusion of Gaia baserom (workspace folder gaia-iog-baserom, plan folder plans/extracted-audit/audit-of-audit/).

Read these first, in order:
1. plans/extracted-audit/audit-of-audit/PLAN.md (this plan, status table and defect classes)
2. plans/extracted-audit/audit-of-audit/report.md (version 2; the findings and the action plan AP-01..AP-23)
3. The digest file(s) named in the step prompt
4. gaia-core/docs/notes-and-comments.md sections "Notes Merge", "Merge spec format and iteration files" and "Names Merge" (only if the step edits notes or names)

Hard rules:
- Never run git commit, push, tag, merge, rebase, reset, revert or any history-changing git command. git status, diff, log and add are allowed. At the end say "Please commit when you're ready." with a suggested message.
- Do not use sub-agents (no Task tool).
- Do not write or run throwaway scripts (.py .mjs .js .sh PowerShell) to read, edit or analyse names, notes, comments, blocks.json, files.json or docs. Use Grep, Glob, Read, StrReplace, Write. The only shell commands allowed are: rg for searching, npm run extract:lt, npm run rebuild, npm run merge, npm run names, npm run names -- --check, git status/diff/log. Never use the retired ingest or annotate commands, never add ?BANK to extracted files.
- Notes and comments change only through npm run merge -- <spec.json> (dry-run first with --dry-run). Names change only through npm run names -- <spec.json> (dry-run first). If the tool cannot do what is needed, say so and stop; do not work around it.
- Frozen ledgers (results/, renames/, questions/, edits/ files that already exist, checklist.md) are never edited. New files are written whole with the Write tool.
- Be patient: no stubs, no simplifying. If you make a mistake, do not fall back to an older method; stop and ask me.
- Evidence ladder: E1 code trace, E2 cross-reference, E3 docs, E4 hardware docs, E5 runtime (Mesen2). No Mesen2 ROM or state exists, so every behavioural claim is static; say so. Tag each finding VERIFIED (checked in live files this session, with file:line) or REPORTED (from a ledger, not re-checked).
- Cursor rules in the workspace apply: use the GaiaLabs assembler conventions (read gaia-knowledge/curated/gaialabs/assembler-syntax.md before touching .asm text), bare LSR/ASL/INC/DEC/ROL/ROR for accumulator forms, and COP/DP hazards from AGENTS.md if you quote code.
- Rebuild gate (only after a step that changed notes or names): npm run extract:lt then npm run rebuild must give checksum 223006080, crc 2083230829, totalSize 3062204. If the gate differs, stop, report the exact numbers and which file changed last; do not "fix" by editing unrelated files. Re-run extract:lt and rebuild as two separate commands if the first fails with an rm -rf error.
- Open questions (OQ-*) are not answered in these steps unless the step says so.

Deliverable rules:
- Write findings to plans/extracted-audit/audit-of-audit/<STEP>_findings.md as one new whole file. Sections: Scope and files read; Findings (id, tag VERIFIED/REPORTED, file:line, what is wrong, proposed fix, defect class number); Not verified / needs Mesen2; Items for the fix specs (F-step id); Counts.
- Update the step's status row in PLAN.md (StrReplace only that row) to DONE with the findings file name.
- Final message: counts, top 5 findings, anything blocked, "Please commit when you're ready." and a suggested commit message.
```

### Step prompts (A-steps)

#### A01 — I001–I020 row status and fact re-verification
```text
STEP A01. Digest: plans/extracted-audit/audit-of-audit/digest_I001-I020.md.
Read plans/extracted-audit/results/I001-I020_results.md, plans/extracted-audit/renames/I001-I020_rename-proposals.md, apply-I001-I020_summary.md and apply-I001-I020_plan.md, plans/extracted-audit/questions/ files for I001..I020 (open one at a time; there are many), and the I001-I020 sanity check.
Do:
1. Build a table of every rename-proposal row (1..90) with status: APPLIED (verify in db-us/names/bank*.json, blocks.json, mnemonics.json or the extracted tree), PROPOSED (still open), SUPERSEDED (state by which iteration or row), or DROPPED (with the ledger's reason). One row per proposal row.
2. For every OQ id in the questions files, list id, one-line question, and whether a later results file answered it (REPORTED) or not.
3. Re-verify 25 facts from the results file against live code. Choose them across at least 10 distinct files and at least 8 of the 13 defect classes; prefer facts about flag bits, hardware registers, WaitByte and branch directions. For each, read the code at the cited line and record VERIFIED-CORRECT, VERIFIED-WRONG (give the correct reading) or CANNOT-CHECK (why).
4. Grep the extracted tree for the nine clearly wrong mnemonics named in the digest and report the operand line count per name (file counts too).
5. Run the defect-class grep sweep from PLAN.md on the I001-I020 files only: WaitByte/WaitWord wording, "previously/formerly/old header", OQ-/R- ids in note text, retired nicknames.
Output: audit-of-audit/A01_findings.md. Do not edit notes or names.
```

#### A02 — I021–I030
```text
STEP A02. Digest: plans/extracted-audit/audit-of-audit/digest_I021-I040.md.
Scope: results, renames, questions and edits files for iterations I021..I030 (open them in iteration order; read results fully, the others by search for ids and statuses) plus apply-I021-I040_summary.md and the I021-I040 sanity check.
Do:
1. Per-row status table for every rename row and every Q5 (mnemonic/struct/copdef) row of I021..I030: APPLIED (verify live), PROPOSED, SUPERSEDED, DROPPED.
2. Per OQ id: question, answered later? where?
3. Re-verify 20 sampled facts from the results files against live code (at least 8 files; at least 6 defect classes).
4. Verify each "misleading names still live" table row in digest_I021-I040.md is still true (rg the mnemonic or label).
5. Defect-class sweep (PLAN.md list) over the extracted files audited in I021..I030.
6. Note the transform-adjacency hazard (class 12): list any note placed on a label inside a transforms.json multi-line regex.
Output: audit-of-audit/A02_findings.md. No edits to notes, names or docs.
```

#### A03 — I031–I040
```text
STEP A03. Same as A02 but for iterations I031..I040. Digest: digest_I021-I040.md. Additionally verify the I035/I036-after-I037 ordering effects: for each fact in I035/I036 that I037 contradicts or refines, record which ledger statement is current. Output: audit-of-audit/A03_findings.md. No edits to notes, names or docs.
```

#### A04 — I041–I050
```text
STEP A04. Digest: plans/extracted-audit/audit-of-audit/digest_I041-I072.md (sections for I041..I050).
Scope: results, renames, questions and edits files for I041..I050, apply-I041-I050_summary.md, apply-I041-I050_plan.md and I041-I050_sanity-check.md.
Do:
1. Per-row status table for rename and Q5 rows (APPLIED verified live / PROPOSED / SUPERSEDED / DROPPED).
2. Per OQ id: answered later?
3. Re-verify 20 sampled facts against live code, covering at least 8 files. Include: the Flags10 meanings in player_move_controller and player_move_main, the stat-table byte 3 claim (I046, corrected by I051), the dialog_string_scanner pointer test and 02 BF scan, the reward_actors clamp, statue_inventory_reward, hit_stagger_controller $0400.
4. WaitByte n vs n+1 grep sweep over every file audited in I041..I050 (the sanity check for this range did not report one).
5. Check the sanity check's removal of comments: confirm no file in I041..I050 still has the one-comment-per-instruction pattern (rg for runs of consecutive commented instructions in a sample of 10 files).
6. Defect-class sweep for the rest of the list.
Output: audit-of-audit/A04_findings.md. No edits.
```

#### A05 — I051–I060
```text
STEP A05. Digest: digest_I041-I072.md (sections for I051..I060).
Scope: results, renames, questions, edits for I051..I060, apply-I051-I060_summary.md, I051-I060_sanity-check.md, renames/sanity-I051-I060_renames.md.
Do:
1. Per-row status table for rename and Q5 rows.
2. Per OQ id: answered later?
3. Re-verify 20 sampled facts against live code across at least 8 files. Include: sE6_gaia (AbilitySceneTable, continue-prompt answers, DS_AuraItemRoom dead cluster), sFA_diary_menu (state table STR/DEF order, SRAM checksum), sFC_title_start_handler (#$1001 bit 0), HdmaWindowEffect operands, WorldMapController, world_map_options part notes $1C-$26.
4. Verify the transform-adjacency state: read db-us/transforms.json for sFA_diary_menu and check that no note sits between the labels the regex needs adjacent (diary_band_empty / diary_band_slot1).
5. Count notes that still carry "the old header said" narration in I051..I060 files (the sanity check counted 18 of 30 block notes).
6. Sweep for the remaining defect classes.
Output: audit-of-audit/A05_findings.md. No edits.
```

#### A06 — I061–I064 and B001 re-verification
```text
STEP A06. Digest: digest_I041-I072.md (I061..I064 and B001 sections), report.md §3, §7, §8.
Scope: results, renames, questions and edit specs for I061, I062, I063, I064 and B001; files: direction_velocity_table / walk_step_table, body_table, scene_actors, ability_anim_tables / ability_damage_tables, spriteset_field_fx, movement_delta_table, spriteset_particle_fx, shared_word_table, spriteset_freedan, forced_walk_pan_table, spriteset_town_objects, spriteset_will, and the four spm_* sprite maps from B001.
This range never had a sanity pass. Do it now:
1. For every part note and block note in these files, re-check the claim against the live data and code (counts, ranges, byte meanings, who reads the table). At least 60% of notes must be checked line by line; list the ones not checked.
2. For every claim of the form "nothing reads X" or "never selected" or "unused", run the rg that proves it and record the command and result. Include the B001 correction of the 8 sprite-header bytes: confirm the four readers (PlayerAttackHitTest, solid-rect COPs, RunCombatCollision, RunInteractionCollision) and check that every earlier note that said "unread" is corrected (rg "not read|nothing reads" in the sprite and table files).
3. Check the I063 spriteset_freedan note text now live matches B001's version, not the I063 spec.
4. Sweep the defect classes (WaitByte, history narration, ids in text, nicknames, wrong hardware reading).
Output: audit-of-audit/A06_findings.md. No edits.
```

#### A07 — I065–I068
```text
STEP A07. Same method as A06 for I065..I068. Digest: digest_I041-I072.md. Files: dialog_template_table, parallax_scroll_table, scene_meta, enemy_stats_table, spriteset_aura, spriteset_shadow, item_pickup_text_table (was item_get_dialog_table), spriteset_will_projectile, spriteset_transform_poses (was spriteset_ability_fx), spriteset_npc_props, display_preset_table, scene_warps. Extra checks: (a) the scene_meta handler names SceneCmd_* against the real opcodes (report N-1); (b) the scene_warps second list (forced-walk warps, all 200 vertical) by reading the handler; (c) scene_meta group counts (225/5/4) by counting in the extracted file; (d) enemy_stats_table byte 3 gemDropType against EnemyDefeatDispatch and the I051 correction; (e) the two block names in blocks.json 1003-1042 against the extracted files. Output: audit-of-audit/A07_findings.md. No edits.
```

#### A08 — I069–I072
```text
STEP A08. Same method as A06 for I069..I072. Digest: digest_I041-I072.md. Files: spriteset_freedan_fx, spriteset_shadow_fx, spriteset_enemies, enemy_clear_reward_table, spriteset_dark_friar, dialog_dictionaries, spriteset_shadow_mode, scene_chest_table, inventory_spritemap, scene_thinkers, system_strings, spriteset_will_abilities. Extra checks: (a) body row $07 never selected vs row $08 selected (I069 vs I071) with the rg evidence; (b) system_strings: the 10 part notes (7 were wrong originally) re-read against the strings; (c) scene_thinkers: global_ambient_dispatcher in 59 of 70 lists by counting; (d) dialog_dictionaries B has 200 entries; (e) hidden groups printed as sprites in these files: list them (they feed AP-12). Output: audit-of-audit/A08_findings.md. No edits.
```

#### A09 — Notes JSON sweep, banks 00–01
```text
STEP A09. Read plans/extracted-audit/audit-of-audit/report.md §4, §9 and gaia-core/docs/notes-and-comments.md "Notes" sections.
Scope: notes/blockNotes/bank00.json, bank01.json, notes/partNotes/bank00.json, bank01.json, notes/comments/bank00.json, bank01.json. Use rg on these JSON files; open only hits (large files; never read a whole file in one call).
Sweeps (each with the exact rg pattern and the match count in the findings file):
1. Orphan keys: for each partNotes key and each comments key, confirm a matching label or `; {n}` tag exists in the extracted tree. Do this by sampling at least 40 keys per file plus every key that matches the retired names in Appendix A of the report.
2. History narration: previously|formerly|the old header|was named|was misnamed|until I0.
3. Id citations: OQ-|R-I|D-S|(R-.
4. Hedges: UNVERIFIED-RUNTIME|(inferred)|not traced at runtime — decide per hit whether the claim was code-traced (then the hedge is noise) or not.
5. WaitByte / WaitWord n vs n+1 (WaitByte.*frame, wait .* frames).
6. Retired nicknames (Appendix A) and will_alt|ability_fx|shadow_mode|table_018000|barrier.
7. Button vocabulary: notes that say "B button" / "A button" near the $0080 / interact masks; compare with transforms.json for player_character.
8. Transform adjacency: list notes on labels inside multi-line regexes of db-us/transforms.json.
Output: audit-of-audit/A09_findings.md with a table (key, file, class, proposed fix). The fix specs themselves are F-steps; do not write specs here. No edits.
```

#### A10 — Notes JSON sweep, banks 02–0F
```text
STEP A10. Same as A09 for banks 02 through 0F (every notes/blockNotes, partNotes and comments file for those banks; also banks 10 and above if they exist under notes/). Bank 02 holds scene_script (report N-1, N-2, N-3): include a line-by-line check of the scene_script opcode table and SpcMusicLoadCmd against the code. Output: audit-of-audit/A10_findings.md. No edits.
```

#### A11 — Docs reconciliation
```text
STEP A11. Read report.md §5 and §4 (N-3, N-6, N-7, N-10), every "docs" paragraph in the results files for I001..I072 (rg "docs not edited|Docs:|D-" in plans/extracted-audit/results), and the apply summaries' docs sections.
Do:
1. Build a table of every doc correction the ledgers recorded: doc file, line or section, claim, ledger id, status DONE (verify the live doc line) / OPEN (still stale) / SUPERSEDED.
2. Re-verify each OPEN item against the live doc and the cited code (file:line).
3. Extra grep sweeps over docs/: retired block and label names (Appendix A), "Damage flash", table_018000, barrier, will_alt, deathFlag, musicParentActor, climbStateData, invincibilityTimer.
4. List gaia-core/docs/notes-and-comments.md changes needed (AP-17) and gaia-knowledge/corpus files that mention retired names (rg in c:/Work/gaia-knowledge/corpus).
5. Do not run npm run ingest:all.
Output: audit-of-audit/A11_findings.md. Do not edit docs in this step (docs corrections are F05).
```

#### A12 — Open-question registry
```text
STEP A12. Read report.md §10 and PLAN.md. Scope: every OQ id in plans/extracted-audit/questions/*.md and in the results files (rg -o "OQ-[A-Z0-9-]+" across plans/extracted-audit).
Do:
1. Write a registry table: id, question (one line, rewritten so it is understandable without the ledger), iteration, status (OPEN / ANSWERED-LATER with the answering id / DUPLICATE-OF id), kind (STATIC / RUNTIME / DECISION), evidence pointer, and the files that cite the id in shipped text.
2. Group duplicates (hidden sprite groups, $06F2, plain vs tagged build).
3. Build the cross-file reconciliation table promised in report §8.7: every flag bit and every shared mnemonic that more than one iteration explained, with each explanation and which one the code supports (use rg to confirm).
4. List ids cited in shipped notes (feed A09/A10).
Do not answer RUNTIME or DECISION questions. You may mark STATIC ones answerable but do not answer them here.
Output: audit-of-audit/A12_findings.md (the registry; this file feeds the separate OQ document). No edits.
```

#### A13 — Generic-label triage
```text
STEP A13. Scope: the audited ranges (system/engine, tables, strings, the actor files audited in I001..I072, the spm_* sprite maps).
Do:
1. Count generic labels per directory and per file (patterns loc_, code_, sub_, data_, table_, func_, label_, binary_, sprite_set_) with rg --count. Do not use a script; run rg per directory.
2. For audited files only, list each generic label that now has an established purpose (cite the note or results row), propose a name in the names-spec shape { address, old, new, row } (take address from the extract:lt asm `; {n}` tag; do not use hex addresses), and flag name collisions (labels must be unique).
3. Separate three lists: NAME NOW (purpose proven E1/E2), LEAVE GENERIC (purpose unknown), DEAD (unreferenced).
4. Do not write the names spec file yet.
Output: audit-of-audit/A13_findings.md. Run npm run extract:lt first if extracted/ has no line tags. No edits.
```

#### A14 — Mnemonic / struct / copdef consolidation
```text
STEP A14. Read report.md §8.1, digest_I001-I020.md (misnamed mnemonics table) and renames/I001-I020_rename-proposals.md, plus Q5 columns of the I021..I072 results files.
Do:
1. One table, one row per mnemonic, struct, copdef or types proposal: id, address, current name in db-us/mnemonics.json (VERIFY live), proposed name, evidence ids, live operand count (rg), blast radius (file count), decision recommendation (RENAME / ALIAS-IN-NOTE / LEAVE / SPLIT) and reason.
2. Order the table by byte-safe cost: pure mnemonic renames first (no byte change), then struct field renames, then blocks.json type changes.
3. For every RENAME row, check that the new name does not already exist in mnemonics.json and that the transforms/patch sources (baserom/, IOGRetranslation modules) do not reference the old name (rg; list hits).
4. For the 12 multi-meaning mnemonics, propose the note wording that disambiguates (contextual aliases), not a rename.
Output: audit-of-audit/A14_findings.md. db-us/mnemonics.json is user-owned: do not edit it.
```

#### A15 — Tooling backlog
```text
STEP A15. Read report.md §6 (G-1..G-9), AP-01, AP-12, AP-14..AP-18, AP-23 and gaia-iog-baserom/src/merge.ts, names.ts, names-merge.ts, notes-common.ts, plus db-us/transforms.json and package.json scripts.
Do (analysis and specs only; no src/ edits in this step):
1. G-1: list every multi-line regex in db-us/transforms.json, the file it belongs to, the labels it spans, whether it tolerates `; {n}` lines, and what a tolerant version would look like. Read-only; do not edit transforms.json.
2. G-6: for each multi-line regex, name the labels on which notes are forbidden today and write the exact check a merge guard would need (inputs, failure message).
3. G-3/G-9: specify merge --check (orphan keys; bank detection rules) with acceptance cases taken from real orphans in the ledgers (comment key 47052, loc_03B928).
4. AP-12: read gaia-core's sprite extractor for the hidden-group header (13th byte count) and write the minimal change as a design note (file, function, expected output change, which extracted files change: list from A08 and I067/I069/I071/I072 results).
5. AP-14 and AP-23: what the rm -rf step does and why it can fail; hypotheses for the CrystalBallAutoUse "rewrite that does not exist: CODE_05F522" error with the evidence that would settle each.
6. Recommend: which of these changes need a gate run and in which build mode.
Output: audit-of-audit/A15_findings.md. If a change to src/ or gaia-core is needed, describe it; implementing it requires my explicit go-ahead.
```

### Step prompts (F-steps: fixes)

Run an F-step only when the matching A-step is done or when you say "go". Each F-step writes a spec, dry-runs, merges, validates and stops.

Common F-step addendum (paste after the Common preamble):

```text
This is a FIX step, not an audit step. Allowed edits: only through npm run merge / npm run names, plus Write for the new spec file. Spec location: plans/extracted-audit/edits/<ID>.json (notes) and plans/extracted-audit/renames/apply-<ID>_names.json (names; decimal address from the extract:lt `; {n}` tag, old = the label the extracted asm prints now). Procedure: (1) read each target line in the live extracted file and in notes/*.json; (2) write the spec; (3) npm run merge -- <spec> --dry-run (and npm run names -- <spec> --dry-run); show me the dry-run summary; (4) apply; (5) npm run extract:lt then npm run rebuild and compare with the gate numbers; (6) verify each change by reading the extracted file; (7) write plans/extracted-audit/audit-of-audit/<ID>_apply.md (what changed, gate result, anything skipped and why); (8) update the PLAN.md fix table status for this ID. Do not touch transforms.json, overrides.json, blocks.json, mnemonics.json or docs unless the step says so. If a target label sits inside a multi-line transform regex, stop and tell me.
```

#### F01 — scene_script.asm notes
```text
STEP F01 (report N-1, N-2, N-3; AP-02). Targets in extracted/system/engine/scene_script.asm: the block-note opcode table (lines 15-24, opcodes $04 $05 $06 $14), the four part notes that carry the old descriptions (SceneCmd_LoadPalette, SceneCmd_Label and the two others the table pairs wrongly), the block-note sentence at line 75 ("gates loading to prevent redundant transfers"), the inline comment at line 1303 in SpcMusicLoadCmd, and the table_018000 mentions (lines near 15, 71, 1159, 1161; replace with display_preset_table where the text means that table). Facts to write: $04 loads palette colours (< start, end, dest >), $05 loads metatile sets, $06 loads layer maps, $14 records a label for scene_meta; the music command loads when the compared groups are EQUAL (BEQ loc_028B88), musicRoomGroup ($06F6) is a per-scene selector set by scene scripts, redundant loads are prevented by CheckSourceCacheHit on $0687. Re-read the handlers and confirm each fact before writing. Add one sentence that the rebuilt tree uses scene_meta_list via baserom/scene-load/SceneMetaLoad.patch.asm. State what the code does now; no history narration, no OQ ids. Also fix the matching comment in notes/comments/bank02.json lines about 283-284 if it says table_018000.
```

#### F02 — WaitByte n+1
```text
STEP F02 (report N-4; AP-03). Targets: warps_interaction.asm lines 52, 509, 522, 529 (11 -> 12 ticks, 72 -> 73 ticks), music_actors.asm lines 122 and 125 (#01 = 2 ticks), item_use_system.asm line 1826. Do NOT edit future_vision_cutscene.asm (not audited yet; it is carried to I285) unless I say so. Before editing, re-read each line and the WaitByte runner (cop_handlers handler for WaitByte) to confirm the n+1 rule. Keep the change minimal: correct the number and the unit, keep surrounding wording. In the apply file list any additional hits you found with rg "WaitByte" across extracted/ outside the area directories and tell me; fix them only if they are in the audited files named by report.md.
```

#### F03 — nickname and row drift, FacingData names
```text
STEP F03 (report N-5, N-6, section 3.3; AP-04). Part 1 (merge): body_table.asm line 37 (FacingFormOffsetTable list uses will_alt, ability_fx names), slider_glide.asm lines 4, 5, 59, 256, 263, 267, 298, cop_handlers_player_sprite.asm lines 6, 33, 38, 52, GetPlayerFacingDirection.asm line 16: replace retired nicknames with the current block names (spriteset_will_abilities, spriteset_transform_poses, shadow aura spriteset; read blocks.json and Appendix A of report.md for exact names) and fix slider_glide's "5 = ability poses" claim against body_table. Part 2 (names): decide and propose renames for FacingData_WillAlt (names/bank03.json:473, address 258431) and FacingData_AbilityFx (:474, 258458) so they follow the block names; show me the proposed names and wait for my approval before applying the names spec (this is the one place you must ask). Check that the new names are unique and that patches in baserom/ do not reference the old names.
```

#### F04 — scene_lifecycle "barrier"
```text
STEP F04 (report N-7; AP-05). Targets: extracted/system/engine/scene_lifecycle.asm lines 32, 767, 864 (and any other "barrier" mention for the chest table): the table is scene_chest_table and holds chest placement entries only. Re-read each context, replace "barrier/chest" with "chest", keep other facts. Docs are not edited here (F05).
```

#### F05 — Docs corrections
```text
STEP F05 (report section 5, N-1, N-2, N-3, N-6, N-7, N-8, N-10; AP-06 and AP-16). This step edits docs by hand with StrReplace (no scripts), only the lines listed in report.md section 5 and in plans/extracted-audit/audit-of-audit/A11_findings.md (if it exists). Process: for each doc line, re-read the cited code first, edit, then record doc file and line before and after in plans/extracted-audit/audit-of-audit/F05_apply.md. Required items: system-core.md 421, 457, 522 and data-tables-memory.md 381 ($0B22 is hpToHeal, the HP-recovery counter, $0ACE is current HP, $0ACA is max HP; match wram-memory-map.md:378), bank0D-scene-meta.md music-group sentence and opcode descriptions, table_018000 mentions, "barrier" mentions, will_alt mentions. No merge, no names, no gate run needed unless you also changed baserom files; run npm run names -- --check at the end. Do not run npm run ingest:all (I do that).
```

#### F06 — surviving rename / struct / mnemonic proposals
```text
STEP F06 (AP-11, AP-21; needs A13 and A14 done). Input: A13_findings.md and A14_findings.md. Process: (1) names renames from A13 NAME NOW list: write plans/extracted-audit/renames/apply-F06_names.json, dry-run, show me the summary and wait for my approval, apply; (2) mnemonic/struct/blocks.json/overrides.json proposals from A14 are user-owned: write plans/extracted-audit/audit-of-audit/F06_user_edits.md listing the exact JSON edits (file, key, old, new) in the order recommended by A14 (pure mnemonic renames first) and ask me which to apply; apply only those I approve using StrReplace, then run npm run extract:lt and npm run rebuild after EACH group (the bytes must not change; checksum 223006080, crc 2083230829, size 3062204). After any approved mnemonic rename, rg the old name across baserom/, db-us/, docs/ and notes/ and fix remaining references.
```

### Tool / user-owned steps (not agent audit steps)
These come from `report.md` and need a decision from you first; prompts for them are short and only run after you approve the approach.

#### T01 — Decide the product build mode and fix tagged vs plain (AP-01, AP-18)
```text
STEP T01. I decide: <PRODUCT MODE: plain extract | tagged extract:lt | both>. Read audit-of-audit/report.md G-1, G-6 and A15_findings.md (if present). Task: for every multi-line regex in db-us/transforms.json, make it tolerant of `; {n}` tag lines (follow the optional tag group the cop_handlers_* regexes already use) so both builds produce the same bytes. Edit only db-us/transforms.json (user-owned; I approve this task). After each regex change run npm run extract then npm run rebuild, then npm run extract:lt then npm run rebuild, and record both builds' checksum, crc and size. Done when both builds give checksum 223006080, crc 2083230829, size 3062204 (if the plain build legitimately differs for a reason you can show, stop and tell me). Write results to audit-of-audit/T01_apply.md.
```

#### T02 — Extractor hidden sprite groups (AP-12)
```text
STEP T02. Read A15_findings.md section AP-12. Implement the extractor change in gaia-core (I approve this edit), add or extend a test, run the gaia-core tests, then re-extract gaia-iog-baserom with npm run extract:lt and npm run rebuild and report the gate numbers and the list of changed extracted/*.sprite.asm files (git diff --stat). Then list notes that now describe artefact sub-sprites and need fixing (do not edit them).
```

#### T03 — merge/names guards (AP-15, AP-18)
```text
STEP T03. Read A15_findings.md. Implement merge --check (orphan keys) and the transform-adjacency guard in gaia-iog-baserom/src as specified there; document both in gaia-core/docs/notes-and-comments.md (AP-17: orphan sweep, doc grep list, plain-vs-tagged gate, edit-entry limits, spec replay, glossary lines from report H-7). I approve edits to src/ and that doc. Acceptance: the guard rejects a note on diary_band_empty; merge --check reports the real orphans listed in A15. Run the gate afterwards.
```

---

## Fix iterations (after the audit, not part of it)

| ID | Content | Mechanism | Prompt |
|---|---|---|---|
| F01 | `scene_script.asm` notes: opcode table, four part notes, `SpcMusicLoadCmd`, `table_018000` mentions | `merge` spec | F01 above |
| F02 | WaitByte n+1 leftovers (`warps_interaction`, `music_actors`, `item_use_system`) | `merge` spec | F02 above |
| F03 | Nickname and row-5 drift (`body_table`, `slider_glide`, `cop_handlers_player_sprite`, `GetPlayerFacingDirection`) plus `FacingData_*` rename decision | `merge` + `names` spec | F03 above |
| F04 | `scene_lifecycle` barrier wording (R-I071-4) | `merge` spec | F04 above |
| F05 | Docs corrections list (report.md §5) | manual doc edits | F05 above |
| F06 | Open rename / struct / mnemonic proposals that survive A13–A14 | `names` spec, user-owned `blocks.json` / `overrides.json` / `mnemonics.json` | F06 above |
| T01 | Plain vs tagged build; tolerant transforms | user-owned `transforms.json` | T01 above |
| T02 | Extractor hidden sprite groups | `gaia-core` change | T02 above |
| T03 | `merge --check`, transform guard, docs for the tools | `src/` + doc | T03 above |

## Recommendation for I073 and later

Do not start I073 before T01 (AP-01), AP-18 and A06–A08. Then re-batch by scene directory instead of by file count. The 25 area directories (about 230 actor files) are repetitive and share context (same flags, same helpers). Auditing one scene per iteration gives better cross-file checks and removes the per-iteration overhead of 5 ledger files. Keep the evidence ladder and verdict format; drop per-iteration `questions/` files in favour of a single running registry (A12).

Kickoff prompt for the later scene iterations (write it after A12 and T01 are done; it should reuse the Common preamble, the defect classes above and the verdict format of the I0xx results files).
