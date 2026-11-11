# Mesen2 + audit series: close-out plan

Written 2026-11-11 after MS04 (the Z1 closure of E, F, G, M, N, P, R, S, T, V, W1 and FR). It is the result of a read-only final pass over the whole series. It lists what is still open and gives, for each work package, the steps, the pass criteria and a prompt an agent can run.

Nothing in this file changes the baserom. Counts below were computed on 2026-11-11 from `mesen2-results/closures.md`, `mesen2-question-inventory.md`, the result files and the spec drafts. They are good to within a few rows. Work package CO-04 regenerates the question counts exactly before anything relies on them.

Sources: [mesen2-investigation-plan.md](mesen2-investigation-plan.md) (the plan; §11 definition of done, §12 prompts), [mesen2-question-inventory.md](mesen2-question-inventory.md), [mesen2-results/](mesen2-results/) (`closures.md`, `MS01..MS04_apply.md`, `tool-issues.md`, `states-index.md`), [audit-of-audit/ACTION_PLAN.md](audit-of-audit/ACTION_PLAN.md) (IT-17..IT-53 prompts, §11 decisions U7-U19, §15 parked, §16 run order), [../flags/flag-analysis-plan.md](../flags/flag-analysis-plan.md).

---

## 0. How to use this plan

1. Do the work packages (CO-nn) in the order of §5. Each has a checklist, a pass criterion and an agent prompt. Tick the checklist in §8 as you go (the GaiaLabs rule: no work without a checklist).
2. Paste **Block P** (§4.0) before every prompt in §4. Block P carries the rules that every earlier step used (no git writes, no ad-hoc scripts, text style, gate).
3. Run **one writer at a time** against `notes/`, `db-us/names/` and `closures.md`. Reports and specs can be drafted in parallel; applying (merge, names, flags) is sequential, and each apply ends with `npm run extract:lt`, `npm run rebuild` and a gate comparison.
4. Where an item says "ask the user", the answer is in §3 with a recommended default. Agents must not guess those.

---

## 1. Where the series stands

### 1.1 Scorecard against the plan's definition of done (plan §11)

| Criterion | State | Evidence |
|-----------|-------|----------|
| Phase 0 (H0-H4: states, harness, kit) | done | `states-index.md`, `harness/` |
| All 15 P1 questions have a verdict | verdicts exist for 15 of 15; **10 have no closure row** | A and B results, `closures.md` |
| At least 80% of the 113 P2 questions have a verdict | about 90 of 113 have a VERIFIED or CONTRADICTED closure row; the rest have a verdict in a result file or are INCONCLUSIVE | `closures.md` |
| R1 coverage archived, every UNREF member with a verdict | R1 ran; only 1 closure row; 7 ids have a verdict only in `R1_*.md` | §2.1 group R1 |
| V1 cross-checks CL-01..CL-12 each with a status | done (all 12 verdicts in `V1_20261110.md`, closure rows written) | `closures.md` |
| Every shipped note shown wrong is corrected | done for E..FR (MS04) and C, D, B4, E-earlier (MS01-MS03); open for the A/B reports and five T1 sentences | §2.2 |
| `tool-issues.md` complete | T-01..T-81 written; the enhancement-request file is not re-ranked | §2.5 |
| Docs that repeat wrong sentences corrected | **not done** (about 9 docs known, listed in CO-12) | §2.4 |
| Flag registry applied | **not done** (`db-us/flags.json` is an empty skeleton) | §2.2 |

### 1.2 Question state (358 `OQ-` ids; 11 are mode X, "no experiment")

| Group | Ids | Meaning |
|-------|-----|---------|
| Closed with a VERIFIED-RUNTIME, VERIFIED-STATIC or CONTRADICTED closure row | about 262 | done |
| Verdict in a result file but **no closure row** | 51 | bookkeeping: A report 12, B1/B2/B3/B5/`B_addendum` 29, R1 7, F2 hidden groups 3 (a few of these are INCONCLUSIVE in their report, for example `OQ-B001-1` and `OQ-I033-6`) |
| **No evidence in any result file** | 11 | `OQ-11`, `OQ-I021-4`, `OQ-I031-5`, `OQ-I042-2`, `OQ-I051-7`, `OQ-I052-9`, `OQ-I053-5`, `OQ-I063-3`, `OQ-I064-2`, `OQ-I065-5`, `OQ-I068-1` |
| INCONCLUSIVE only (no verified half) | 23 (P2: 4, P3: 19) | needs a decision: run, park or accept |
| INCONCLUSIVE halves of otherwise closed ids | about 50 closure rows carry one | same decision, lower priority |

Priority view of the 62 non-X ids without a closure row: P1 10, P2 19, P3 33.

### 1.3 Audit-of-audit (ACTION_PLAN.md)

Part 1 (IT-01..IT-16) is done. Part 2 (IT-17..IT-53, 37 iterations) is open, with decisions U7-U19 pending. The Mesen2 steps overlapped with some of them (see the disposition table in CO-08), so the ACTION_PLAN prompts must not be pasted unchanged.

### 1.4 Gate

Current gate (MS04): `artifacts/crc.json` checksum 222965960, crc -34152415, totalSize 3062205, sha1 `90a04067dd5b5284bd9e152ad222df0e65d08979`. The plain and tagged builds are identical since the tolerant transform rules are in `db-us/transforms.json`. `extracted/` is **untagged right now** (a plain `npm run extract` was run after MS04: the files have no `; {n}` tags and are newer than `crc.json`, whose `mode` still says `tagged`). The older gate numbers in ACTION_PLAN and `checklist.md` (223006080 / 2083230829 / 3062204) are obsolete. CO-00 re-establishes the gate and writes it down once.

---

## 2. Findings of the final pass

### 2.1 Questions that are inconclusive, unclosed or need clarification

**A. Bookkeeping: verdict exists, closure row missing (51 ids).** The result files carry the verdict; `closures.md` has no row.

| Group | Ids | Source | Note |
|-------|-----|--------|------|
| A (12) | `OQ-20`, `OQ-38`, `OQ-40`, `OQ-60`, `OQ-I022-1`, `OQ-I023-6`, `OQ-I025-1`, `OQ-I025-2`, `OQ-I026-6`, `OQ-I033-6`, `OQ-I044-2`, `OQ-I052-5` | `A_campaign_report_20261030.md` §11 proposes the rows | `OQ-I033-6` is INCONCLUSIVE in A |
| B (29) | `OQ-3`, `OQ-16`, `OQ-24`, `OQ-25`, `OQ-41`, `OQ-I024-5`, `OQ-I029-2`, `OQ-I029-5`, `OQ-I030-3`, `OQ-I032-1..4`, `OQ-I033-1..4`, `OQ-I038-1`, `-2`, `-5`, `OQ-I039-1`, `-2`, `-3`, `-5`, `OQ-I045-3`, `OQ-I048-5`, `OQ-I051-6`, `OQ-I052-3`, `-4` | B1, B2, B3, B5, `B_addendum` reports | `OQ-16`, `OQ-I029-5`, `OQ-I030-3`, `OQ-I032-4`, `OQ-I033-4` are P1 |
| R1 (7) | `OQ-B001-1`, `OQ-I039-4`, `OQ-I056-7`, `OQ-I062-4`, `OQ-I067-4`, `OQ-I068-2`, `OQ-I069-2` | `R1_*.md` | `OQ-B001-1` INCONCLUSIVE |
| F2 (3) | `OQ-I067-5`, `OQ-I069-4`, `OQ-I071-5` (hidden-bit groups) | `F2_20261108.md` (VERIFIED-RUNTIME) | The shipped text depends on IT-33 / IT-34 (hidden group naming) |

**B. No evidence (11 ids).** Listed in §1.2. CO-04 classifies each as RUN (which session), STATIC (answerable with `rg` and Read), PARK or ACCEPT-INCONCLUSIVE, using the inventory rows (mode column) as the starting point.

**C. INCONCLUSIVE-only (23 ids)** and the INCONCLUSIVE halves. They fall into these families; each needs one disposition in CO-04:

| Family | Why inconclusive | Options |
|--------|------------------|---------|
| Natural boss defeat and rewards (G2, N2, W1-c, FR30) | The only way to reach the state was to poke HP or the kill counter (SIMULATED) | one natural-play capture session, or accept SIMULATED as the evidence level and say so in the note |
| Scenes that crash or never load on the harness warp (R2/G4: 23 scenes) | The warp skips the scene setup | accept: record the list as "not reachable by warp" in the registry |
| Collision type `$69` and other special tiles on real maps (B1, B2) | needs a state on the map | one new state per map, or park |
| World map exit hang (M3) | input gating on the title/world map | one session with raw input, or park |
| SPC / music stream questions (D2, D3) | no SPC-side trace | static only (the SPC engine is documented); park |
| HDMA band thinker corners (E4) | 20 band types observed, edge counts not | accept |
| Title / diary input gating (M2, `sFA_diary_menu`) | shipped note already hedged | accept |

**D. New questions with no `OQ-` id.** Each session report ends with "New questions" (about 150 in total across A..FR, S1 and T1). They are not numbered, not deduplicated and not in any registry (`open-questions.md` and `static-answers.md` do not exist; IT-35 owns them). CO-11 triages them: DUPLICATE (of an existing id), WORTH-RUNNING, STATIC, PARK.

**E. Clarifications needed from the user** are in §3.

### 2.2 Notes that are not applied

| # | Item | State | Package |
|---|------|-------|---------|
| N1 | Campaign A, B1, B3, B4, C, D, E, F specs | mostly applied (A 44 of 46 entries found, B1 9 of 11). Unmatched: A `cop_handlers_dialog`, `cop_handlers_sprite`; B1 `camera_tilemap`; B4 `slider_glide`; C4 `cop_handlers_dialog`; E3 `mode7_perspective`. Unknown whether reworded (applied under other text) or never applied | CO-01, CO-02 |
| N2 | B2, B5 and `B_addendum` | no spec was written, or the spec is not in `specs/` | CO-02 |
| N3 | Notes "spec not drafted" in result files (G2 `OQ-53`, `OQ-67`, reward tiers; G1 `OQ-I041-5`; C1 `OQ-45(b)` / `OQ-I022-4`; D1 `OQ-10(c)` and `OQ-I046-1(a)`; E2 counts; M3 icons; N1) | verdicts exist, no shipped-note change yet | CO-06 |
| N4 | `T1_20261110.md`: five shipped notes shown wrong | not changed (owner IT-29) | CO-06 |
| N5 | `MenuSelectionHandler.asm` (W1-e) | `merge` refuses this file | CO-06 (needs the tool fix in CO-07) |
| N6 | Flag-analysis FL10..FL41 notes specs (`plans/flags/results/specs/FL*_notes.json`) | mostly **not applied**; several are superseded by FR specs and by MS04 (FL30 names use `...Alt`, MS04 applied `...Flagged`) | CO-09 |
| N7 | Flag registry: 22 fragments (FL10..FL41, 912 meanings at 683 indices), FR verdict specs (`FR*_flag_verdicts.json`), `FR40_scene-flags.json`, `FR50_presets_verdicts.json`, FL32 presets and scene-flags | **not applied**; `db-us/flags.json` is empty, `db-us/scene-flags.json` has 1 entry; the flags plan progress log (§12) still shows TODO | CO-09 |
| N8 | `docs/flags/*` generated pages | empty because the registry is empty | CO-09 |

### 2.3 Names that are not applied

| # | Item | State | Package |
|---|------|-------|---------|
| M1 | ACTION_PLAN IT-36..IT-40 (A13 name groups) | open | CO-10 |
| M2 | `plans/flags/results/specs/FL30_names.json` (9 renames to `...Alt`) | **conflicts** with the applied `...Flagged` names (MS04, 7 entries). Do not apply; retire it | CO-10 |
| M3 | WRAM mnemonic `musicParentActor` (`$06F2` holds the BGM id, not a parent actor) | not renamed; `npm run names` covers ROM addresses only | CO-10 (U14/U15) |
| M4 | IT-41..IT-46 (`mnemonics.json`, `copdef.json`, structs) | open; `mnemonics_new.json` is user-owned | CO-10 |
| M5 | `npm run names -- --check` reports 11 problems (formatting in untouched bank files) | documented in MS04, not fixed | CO-10 |
| M6 | Block renames and the spm labels in ACTION_PLAN §15 (parked) | parked | user decision |

### 2.4 Documentation gaps

**Docs that still repeat sentences now shown wrong** (from `MS04_apply.md` line 82, `W1-c`, `D3`, `FR20`, `FR23`, `R3`, `T-37`):

- `docs/code/bank0A-dungeon-enemy-actors.md:257,269` (`ec0E_statue` is always a solid push block; `$21` only adds the inspect handler);
- `docs/code/bank07-watermia-euro-actors.md:241` (FR23);
- `docs/code/bank00/data-tables-memory.md:97-99` (R3);
- `docs/wram-memory-map.md:364`, `:438`, and `:423` (actor slot stride is `$30`, not `$40`; T-37);
- `docs/cop/families/player_sprite.md:127-135` (idle row selection by form; flagged idle `#10`-`#13`; W1-c);
- `docs/audio/spc-engine.md` (D3);
- further lines in the same MS04 list that were cut off in the sources read here: read `MS04_apply.md` line 82 and the "Docs" paragraph of every result file listed above in full.

**Docs and plans that are stale:**

- `gaia-core/docs/notes-and-comments.md:1353` (wrong statement, recorded in MS04);
- `mesen2-investigation-plan.md` CL-06 row (`A feeds $0080 interact`): the build maps physical A to `$8080` and B to `$4008`; §2.1 ROM identities (T1 observation 7); line 196 (`0x1000 + 0x40*k` slot stride);
- `mesen2-question-inventory.md`: status column and counts are the plan-time ones;
- `plans/flags/flag-analysis-plan.md` §12 progress log: all TODO although FL10..FL41 and FR20..FR50 ran;
- `audit-of-audit/ACTION_PLAN.md` §2 status, the gate numbers, and the IT prompts that overlap with MS01..MS04;
- `mesen2-mcp-enhancement-requests.md`: MCP-31..MCP-42 open; the 81 entries of `tool-issues.md` are not mapped to them;
- `checklist.md` §0 gate numbers (the file is frozen; the note belongs in a new file).

**Missing documents:**

- Series summaries. Only the C and D series have one (`docs/mesen2-c-series-summary.md`, `docs/mesen2-d-series-summary.md`, with "Rules for patch authors" and "Where the findings live in the docs"). A, B, E, F, G, M, N, P, R, S, V, W1 and FR have none, so the findings live only in 90 result files. CO-13 writes them.
- `plans/extracted-audit/open-questions.md` and `static-answers.md` (IT-35).
- A single "what the runtime investigation established" index for people who never read the reports (CO-13 produces `docs/mesen2-findings-index.md`).
- `states-index.md` and `harness/README`: confirm they list every state created by W1, FR and V1 and say which ROM each one needs.

**Knowledge base (user-run):** `gaia-knowledge` ingests docs only through `npm run ingest:all`. The agent must not run it. After CO-12..CO-14 the user should run it, so that retrieval returns the corrected docs.

### 2.5 Process and tooling gaps

- Gate drift: every MS step had to re-baseline because the gate was never written down after a user-side change. CO-00 writes it once and every prompt compares to it.
- Tool tasks T04 and friends (IT-26, IT-27, IT-30): blocked or not done (see `T1_20261110.md`). `MenuSelectionHandler.asm` still refused by `merge`.
- `npm run names -- --check`: 11 formatting problems.
- Server requests: MCP-31..MCP-42 not re-ranked against T-01..T-81 (CO-14).
- Mesen2 results: 90 report files with no index; only `closures.md` is searchable by id.

### 2.6 Repository hygiene (user decisions)

- `plans/extracted-audit/mesen2-results/raw/` holds 2270 untracked files (2274 with screenshots); `temp/` holds 55 untracked files (ACTION_PLAN U19).
- Reference rewrites by `npm run names` touched `IOGRXLT/IOGRetranslation` (2 patch files in `modules`): that repo needs its own commit and a build check (CO-15).
- `extracted/` is currently the plain tree. Commit the plain tree, never the tagged one.

---

## 3. Decisions needed from the user

Recommended defaults are in bold. Agents treat a missing answer as the default only where the table says so; otherwise they stop and ask.

| ID | Decision | Default | Affects |
|----|----------|---------|---------|
| D1 | Is the plain build the product gate (tagged equal to it)? | **Yes** | CO-00 |
| D2 | Which INCONCLUSIVE families get a runtime session (§2.1 C): boss defeat natural capture, world map exit, CT69 on real maps | **Boss defeat only; accept the rest** | CO-04, CO-05 |
| D3 | `mesen2-results/raw/` and `temp/`: commit, ignore, or delete | **Add `raw/` to `.gitignore`, delete `temp/*.mjs` after a last look** | CO-15 |
| D4 | ACTION_PLAN U7-U19 (see its §11), in particular U14/U15 (`mnemonics.json` renames) and U9 (transform keys) | take the recommended value in §11 of ACTION_PLAN | CO-07, CO-10 |
| D5 | Flag registry decisions D1-D6 of `flag-analysis-plan.md` | take the recommended values in that file | CO-09 |
| D6 | `musicParentActor` rename (needs the mnemonics path) | **Rename to `currentBgmId` through the mnemonics tool once IT-41..46 exists; until then note only** | CO-10 |
| D7 | Retire `FL30_names.json` | **Yes** | CO-10 |
| D8 | New series summaries go in `docs/` (like C and D) | **Yes** | CO-13 |

---

## 4. Work packages

### 4.0 Block P (paste before every prompt)

```text
Workspace: c:\Work\gaia-iog-baserom (US ROM of Illusion of Gaia). Sibling repos: gaia-core, gaia-knowledge, IOGRXLT\IOGRetranslation.
Read first: AGENTS.md of gaia-knowledge, gaia-core/docs/notes-and-comments.md (§"Notes Merge", §"Names Merge", §"Bank detection"), plans/extracted-audit/mesen2-results/MS04_apply.md (it is the model for an apply step), plans/extracted-audit/mesen2-closeout-plan.md (this plan).

Hard rules:
- No git write command (commit, push, tag, merge, rebase, reset, revert, checkout of files, stash). git status, diff, log and add are allowed. Finish with: "Please commit when you're ready." plus a suggested commit message.
- Notes, comments, names, blocks.json, files.json and docs are changed only with `npm run merge -- <spec.json> [--dry-run]`, `npm run names -- <spec.json> [--dry-run]`, `npm run flags -- ...` or, for docs outside notes/, with the edit tools. Never write a throwaway .py/.mjs/.js/.sh/PowerShell script for notes, names, comments or docs in bulk; never recreate `ingest` or `annotate`; never run `npm run ingest:all`; never add ?BANK to extracted files. If a tool cannot do what is needed, say so and stop (extending a tool in src/ is a separate, documented task).
- Do not edit frozen files: checklist.md, the old I0nn results, closures.md rows already written (append only), earlier result files. New facts go in new files.
- A merge spec for extracted/ must be dry-run first. Under `npm run extract:lt` every comment needs `expect` (the instruction text on the tagged line); `expectOld` is refused. Run `npm run extract:lt`, then `npm run rebuild` (separate commands), before and after each apply, and compare artifacts/crc.json to the GATE recorded in mesen2-results/CO00_baseline.md. Notes-only changes must leave the gate unchanged. When an apply is finished and verified, run a plain `npm run extract` so the tree is untagged.
- Hazards: transform keys that must stay empty (sEA_solid_arm, pyDD_teleporter, pyD7_sliding_wall, sFA_diary_menu, item_use_system at 231157 and 231432); no `$8000` text in combat_collision and actor_execution; DP $80-$82 is the collision pointer; X = actor slot before every COP.
- Text rules for shipped notes (extracted comments, block notes, part notes): present tense; no ids (OQ, R, IT, CL, FL, FR), no paths into plans/; waits as operand plus ticks (`WaitByte #n` = n+1 ticks); buttons as the logical bit plus the physical button (physical B = $8000, Y = $4000, Start = $1000, Select = $2000 for the raw pad word; this build maps physical A and B through the logical bits given in the CL-06 row of V1_20261110.md and its closures.md row: read that row before writing any button sentence); state a fact once; hedge only on a specific untraced claim; no blanket UNVERIFIED-RUNTIME.
- Evidence tags in reports: VERIFIED-RUNTIME, VERIFIED-STATIC, CONTRADICTED, INCONCLUSIVE, SIMULATED (poked state). Every claim cites a result file and line or a tagged ROM address.
- Report: write ONE new file under plans/extracted-audit/mesen2-results/ named as the work package says; do not paste long text into chat.
```

---

### CO-00 Baseline and hygiene

Goal: one written gate, a classified `git status`, no surprises.

- [ ] Read `git status --short` in `gaia-iog-baserom`, `gaia-core`, `IOGRXLT/IOGRetranslation`, `gaia-knowledge`; classify every group (notes/extracted/baserom/docs/plans/raw/temp).
- [ ] State whether `extracted/` is tagged or plain (`rg -l "; \{[0-9]+\}" extracted` is empty for a plain tree).
- [ ] `npm run rebuild` on the plain tree, record `artifacts/crc.json`; then `npm run extract:lt`, `npm run rebuild`, record again; compare; then plain `npm run extract`.
- [ ] Run `npm run names -- --check` and `npm run flags -- --check`, record the output.
- [ ] Write `mesen2-results/CO00_baseline.md` with a `GATE:` line (plain and tagged) and the git classification.

Pass: the report has one `GATE:` line; plain and tagged equal or the difference is explained.

```text
[Block P]
STEP CO-00 (baseline). Do exactly the checklist of CO-00 in plans/extracted-audit/mesen2-closeout-plan.md. Write only mesen2-results/CO00_baseline.md. Do not edit any other file. If the plain rebuild gate differs from checksum 222965960 / crc -34152415 / totalSize 3062205, report which commits or working-tree changes explain it (git log, git diff --stat on baserom/, db-us/transforms.json, src/) and stop; the user decides. Report: GATE line, git classification table, names --check and flags --check output, anything unexpected.
```

---

### CO-01 Closure rows for campaign A (12 ids) and the unmatched A/C entries

- [ ] Read `A_campaign_report_20261030.md` §11 (proposed closure rows) and §12 (apply order), the A1..A4 reports, and `closures.md` (append only).
- [ ] For each of the 12 ids, confirm the verdict in the A reports, then append a row to `closures.md` (format of the last MS04 rows).
- [ ] For the unmatched entries `cop_handlers_dialog` and `cop_handlers_sprite` (A) and `cop_handlers_dialog` (C4): open `edits/mesen2-A_notes.json`, `specs/C4_notes.json`, find the sentence in the live notes or extracted file. Result per entry: APPLIED-REWORDED (cite the live text), MISSING (draft the corrected entry into the CO-06 spec list), or SUPERSEDED.
- [ ] Do not change notes in this package.

Pass: 12 new rows; a table of the three unmatched entries with a disposition.

```text
[Block P]
STEP CO-01 (close A). Scope: the 12 campaign-A ids OQ-20, OQ-38, OQ-40, OQ-60, OQ-I022-1, OQ-I023-6, OQ-I025-1, OQ-I025-2, OQ-I026-6, OQ-I033-6, OQ-I044-2, OQ-I052-5 and the unmatched spec entries (A: cop_handlers_dialog, cop_handlers_sprite; C4: cop_handlers_dialog). Method: read A_campaign_report_20261030.md §11-§12 and the A1-A4 result files; confirm each verdict against the cited result line before writing the row; append rows to mesen2-results/closures.md in the format of the MS04 rows (date 2026-11-11). For each unmatched entry, search notes/ and extracted/ for the sentence (rg), and report APPLIED-REWORDED (quote the live text), MISSING (give the corrected entry as JSON, to be merged in CO-06) or SUPERSEDED (say by what). Do not run merge or names. Write mesen2-results/CO01_close_A.md (rows added, table of unmatched entries, anything where the A report disagrees with a later result file).
```

---

### CO-02 Closure rows for B1, B2, B3, B5, `B_addendum` (29 ids) and B-side unmatched entries

- [ ] Read the B reports (B1, B2, B3, B4, B5, `B_addendum`) and `specs/B*_notes.json`.
- [ ] Append closure rows for the 29 ids; the five P1 ids (`OQ-16`, `OQ-I029-5`, `OQ-I030-3`, `OQ-I032-4`, `OQ-I033-4`) first.
- [ ] Unmatched entries: B1 `camera_tilemap`; B4 `slider_glide`; E3 `mode7_perspective`: same disposition table as CO-01.
- [ ] B2, B5, `B_addendum` did not get a spec: list every shipped sentence they show wrong or answerable and write the corrected entries into `specs/CO02_notes.json` (draft only; CO-06 applies it).

Pass: 29 rows (or a stated reason per id), the disposition table, `specs/CO02_notes.json` that passes `npm run merge -- ... --dry-run`.

```text
[Block P]
STEP CO-02 (close B). Scope ids: OQ-3, OQ-16, OQ-24, OQ-25, OQ-41, OQ-I024-5, OQ-I029-2, OQ-I029-5, OQ-I030-3, OQ-I032-1..4, OQ-I033-1..4, OQ-I038-1, OQ-I038-2, OQ-I038-5, OQ-I039-1, OQ-I039-2, OQ-I039-3, OQ-I039-5, OQ-I045-3, OQ-I048-5, OQ-I051-6, OQ-I052-3, OQ-I052-4 (the closure-row gap) plus the unmatched entries B1 camera_tilemap, B4 slider_glide, E3 mode7_perspective. Method as CO-01. For B2, B5 and B_addendum (no spec exists): for each shipped note, comment or part note the report shows wrong or now answerable, find it in the live extracted/notes text and write the corrected entry into mesen2-results/specs/CO02_notes.json (format of gaia-core/docs/notes-and-comments.md §"Notes Merge", shipped-text rules of Block P). Dry-run it with `npm run extract:lt` active (do not apply). Write mesen2-results/CO02_close_B.md. If a B finding is only INCONCLUSIVE or SIMULATED, say so in the row, do not upgrade it.
```

---

### CO-03 Closure rows for R1 and F2, and the hidden-group trio

- [ ] Append rows for `OQ-B001-1` (INCONCLUSIVE), `OQ-I039-4`, `OQ-I056-7`, `OQ-I062-4`, `OQ-I067-4`, `OQ-I068-2`, `OQ-I069-2` from the R1 report; the R1 coverage archive path and the "UNREF members with a verdict" table go into the report (plan §11 criterion).
- [ ] `OQ-I067-5`, `OQ-I069-4`, `OQ-I071-5` (F2): append rows noting that the shipped naming waits for IT-33 / IT-34 (hidden groups); do not change names here.

Pass: rows appended; a one-page table "UNREF member -> verdict".

```text
[Block P]
STEP CO-03 (close R1 and F2). Ids: OQ-B001-1, OQ-I039-4, OQ-I056-7, OQ-I062-4, OQ-I067-4, OQ-I068-2, OQ-I069-2 (R1) and OQ-I067-5, OQ-I069-4, OQ-I071-5 (F2). Read the R1_*.md and F2_20261108.md files. Append closure rows (append only). In the report give the table "UNREF member -> verdict -> source line" so that plan §11 ("every UNREF member with a verdict") can be ticked, and list any R1 member that has none. Write mesen2-results/CO03_close_R1_F2.md. No merge, no names.
```

---

### CO-04 Residual question ledger (no-evidence and INCONCLUSIVE ids)

- [ ] Regenerate the exact counts: for each of the 358 ids the status {CLOSED-V, CLOSED-C, CLOSED-S, INCONCLUSIVE-only, NO-EVIDENCE, X} from `closures.md` after CO-01..CO-03, and the priority.
- [ ] For the 11 NO-EVIDENCE ids and the 23 INCONCLUSIVE-only ids: read the inventory row (mode, experiment), try the STATIC route first (`rg`, Read, `gaia-iog-baserom/docs`), then assign RUN (session name and state needed), STATIC-DONE (write the answer as a VERIFIED-STATIC closure row), PARK (why) or ACCEPT-INCONCLUSIVE (what shipped text, if any, must carry the hedge).
- [ ] Output `mesen2-results/CO04_residual_questions.md` with the ledger and a list of at most 6 recommended runtime sessions (CO-05), each with the ids it would close.

Pass: every non-X id is in exactly one state; no id left without a disposition.

```text
[Block P]
STEP CO-04 (residual ledger). Build the exact status of all 358 OQ ids from mesen2-question-inventory.md and mesen2-results/closures.md (after CO-01..CO-03). For the 11 ids with no evidence (OQ-11, OQ-I021-4, OQ-I031-5, OQ-I042-2, OQ-I051-7, OQ-I052-9, OQ-I053-5, OQ-I063-3, OQ-I064-2, OQ-I065-5, OQ-I068-1) and the INCONCLUSIVE-only ids, first try the static route (rg and Read of the live extracted files, then docs/); if it answers the question, append a VERIFIED-STATIC closure row with the cited lines. Otherwise assign RUN / PARK / ACCEPT-INCONCLUSIVE with a one-line reason, using decision D2 of the close-out plan (default: only a natural boss defeat is worth a session). For ACCEPT rows say which shipped note, if any, must keep a hedge, and quote it. Write mesen2-results/CO04_residual_questions.md: counts table, full ledger of non-closed ids, and the proposed sessions (max 6) with ids, state needed (name an existing file in states-index.md or say "new state") and stop conditions.
```

---

### CO-05 Optional runtime follow-up sessions

Only the sessions CO-04 proposes and the user approves (D2). Each is a normal Mesen2 session run exactly as plan §12.1 (Preamble A), with a new state registered in `states-index.md`. Candidate list (default: only the first):

| Session | Ids (family) | State | Stop condition |
|---------|--------------|-------|----------------|
| Z2-a natural boss defeat | G2 `OQ-53`, `OQ-67`, N2 reward tiers, FR30 | a state in front of an early boss | the defeat reward sequence observed without poking HP; else report SIMULATED only |
| Z2-b CT69 on real maps | B1 / B2 special tiles | one per map | the tile type read at the position and the observed behaviour |
| Z2-c world map exit | M3 | world map state | the exit hang reproduced with raw input |

```text
[Block P]
STEP CO-05 (session Z2-x). Run only the session named below, as in plan §12.1 (Preamble A): load the named state, confirm the ROM SHA-1 against states-index.md, run the experiment of the matching inventory rows, no memory writes unless the row says SIMULATED is acceptable. Session: <Z2-a | Z2-b | Z2-c>. Ids: <from CO04>. Deliver: mesen2-results/<Z2-x>_20261111.md (verdict table with evidence tags, new states in states-index.md, tool-issues.md rows for new tool problems), and, if a shipped note is shown wrong, a draft mesen2-results/specs/<Z2-x>_notes.json (dry-run only). Do not apply anything and do not write closure rows (CO-06 does).
```

---

### CO-06 MS05: the remaining shipped-note changes

Inputs: `specs/CO02_notes.json`, MISSING entries from CO-01/02, the "spec not drafted" items (§2.2 N3), the five T1 sentences (N4), Z2 specs, `MenuSelectionHandler` (N5, only if CO-07 fixed the tool).

- [ ] Draft the missing specs for N3 items. Each entry: read the live text, change only what the verdict contradicts or answers.
- [ ] Merge everything into `edits/MS05.json` (one conflict-free spec; an entry per file part).
- [ ] Dry-run; show the summary to the user; apply after "OK"; `extract:lt`, `rebuild`, compare to GATE (must be unchanged); read back every changed note; plain `extract`.
- [ ] Append closure rows for the ids whose shipped text changed; write `mesen2-results/MS05_apply.md` in the layout of `MS04_apply.md`.

Pass: gate unchanged; read-back table all APPLIED; zero entries SKIPPED without a reason.

```text
[Block P]
STEP CO-06 (MS05). Combine into plans/extracted-audit/edits/MS05.json: mesen2-results/specs/CO02_notes.json, the MISSING entries of CO01_close_A.md and CO02_close_B.md, the Z2 specs if any, the five sentences of T1_20261110.md that are shown wrong, and notes for the "spec not drafted" items in the result files (G2 OQ-53 and OQ-67, G1 OQ-I041-5, C1 OQ-45(b) and OQ-I022-4, D1 OQ-10(c) and OQ-I046-1(a), E2 counts, M3 icons, N1). For each entry read the live text first (extract:lt active), change only what a verdict contradicts or answers, keep neighbours intact. Dry-run `npm run merge -- plans/extracted-audit/edits/MS05.json --dry-run` and show the summary; STOP and wait for the user's "OK" before applying. After OK: apply, `npm run extract:lt`, `npm run rebuild`, compare crc.json to the GATE (it must be unchanged: notes only), read back every changed note, then plain `npm run extract`. Append closure rows (append only) for the ids whose shipped text changed. Write mesen2-results/MS05_apply.md with the layout of MS04_apply.md (spec, preconditions, procedure, result table APPLIED/SKIPPED/REWORDED with reason, tool issues, docs that repeat the changed sentences). MenuSelectionHandler.asm: only if `merge` accepts it now; otherwise list the sentence and its tag in the report.
```

---

### CO-07 Tooling tasks (ACTION_PLAN IT-26..IT-32)

State from `T1_20261110.md`: IT-26, IT-27, IT-30 blocked or not done, five shipped notes shown wrong for IT-29. The prompts for these iterations are in `ACTION_PLAN.md` §12; run them with these updates.

| IT | Update before running |
|----|----------------------|
| IT-26 | Gate = CO00 gate. Keep the `merge` refusal of `MenuSelectionHandler.asm` as the first fix target; add a test that applies one note to it |
| IT-27 | No apply file and no `GATE:` line exist; the tolerant transform rules are already in `db-us/transforms.json` (commit `91d37de`). Reduce to: record plain = tagged in `CO00_baseline.md` and close the iteration |
| IT-28, IT-31, IT-32 | Run as written; re-read the live `db-us/transforms.json` and the transform keys that must stay empty first |
| IT-29 | Replaced by CO-06 (the five sentences); the iteration only needs its report |
| IT-30 | Run as written after IT-26 |

```text
[Block P]
STEP CO-07 (tooling). Run ACTION_PLAN.md §12 iteration IT-<n> for n in this order: 26, 28, 30, 31, 32 (IT-27 and IT-29 are covered by CO-00 and CO-06). Before each, apply the "update before running" row of CO-07 in the close-out plan and read the iteration's section in full. Respect the iteration's own write set. After every iteration: names --check, flags --check if flags were touched, extract:lt, rebuild, compare to GATE. If a src/ change in this repo or gaia-core is needed, make it only if the iteration says so, document it in gaia-core/docs/notes-and-comments.md, and tell the user in the report. One report per iteration under mesen2-results/ named CO07_IT<n>.md.
```

---

### CO-08 Part 2 note sweeps (IT-17..IT-25, IT-33, IT-34)

Disposition (verify each against live text; Mesen2 steps changed many of these files):

| IT | Disposition |
|----|-------------|
| IT-17, IT-18 | Run, but skip items that MS01..MS04 already changed (read the live comment first) |
| IT-19 | Partly answered at runtime (`$0200` reader, `Bg3TilemapVramDma` consumer: C4 and A). Re-read; close the answered rows |
| IT-20, IT-21 | Run after CO-06; sprite tables changed in F1-F3, N2 and MS04 |
| IT-22 | Reduce: the static checks it lists were covered by R1, G4, R3, S1 (enemy census, projectile chain ends, ramp watch, `PaletteStep`); keep only rows with no closure row |
| IT-23, IT-24, IT-25 | Run; add a sweep for ids and `plans/` paths in shipped text (the MS04 text rules) |
| IT-33, IT-34 | Run; they own the hidden-group naming used by `OQ-I067-5`, `OQ-I069-4`, `OQ-I071-5` |

```text
[Block P]
STEP CO-08 (Part 2 sweeps). Run ACTION_PLAN.md §12 iterations IT-17, 18, 19, 20, 21, 22, 23, 24, 25, 33, 34 one at a time in this order (write one merge spec per iteration, edits/IT<n>.json, as the iteration says). Before each: read the iteration prompt in full, apply the disposition row of CO-08 in the close-out plan, and read the live text of every note you are about to change (MS01..MS05 changed many files; do not re-apply text that is already correct and do not revert it). After each: merge dry-run, user OK for the first iteration only (later ones continue if the dry-run is clean and the gate is unchanged), apply, extract:lt, rebuild, compare to GATE, read back, plain extract. Report per iteration: mesen2-results/CO08_IT<n>.md with the table of changed and skipped items.
```

---

### CO-09 Flag registry and flag notes

Facts: `db-us/flags.json` is an empty skeleton; 22 fragments exist under `plans/flags/results/registry/` (FL10..FL41; 912 meanings at 683 indices); FR verdict specs exist in `mesen2-results/specs/` (`FR*_flag_verdicts.json`); presets and scene flags are in `FR40_scene-flags.json`, `FR50_presets_verdicts.json` and the FL32 files. Notes specs FL10..FL41 are partly obsolete.

- [ ] Read `plans/flags/flag-analysis-plan.md` §7 (apply pass) and decisions D1-D6, `gaia-core/docs/` for the `flags` tool, and run `npm run flags -- --help`.
- [ ] Dry-run each fragment in index order; resolve conflicts (same index, two meanings) by the FR verdicts (runtime beats static); write the decisions into `plans/flags/results/CO09_flag_apply.md`.
- [ ] Apply fragments; `npm run flags -- --check`; export and docs (`npm run flags -- export`, `docs`); apply `scene-flags` and presets.
- [ ] Notes: for each `FL*_notes.json` re-dry-run; keep entries that still match the live text and are not contradicted by MS01..MS05; drop the rest with a reason. Merge as `edits/MS06_flags_notes.json`.
- [ ] Update `flag-analysis-plan.md` §12 progress log (new file `plans/flags/results/CO09_progress.md`; the plan is not frozen but do not rewrite history: append a dated block).
- [ ] Gate after flag work: flags and notes do not change the ROM; the gate must be unchanged.

Pass: `flags --check` clean; `docs/flags/` populated; scene-flags and presets applied; gate unchanged.

```text
[Block P]
STEP CO-09 (flags). Apply the flag registry. Read plans/flags/flag-analysis-plan.md (§7, §12, decisions D1-D6: use their recommended values unless the user says otherwise), gaia-core docs for `npm run flags`, and every fragment under plans/flags/results/registry/, plus mesen2-results/specs/FR*_flag_verdicts.json, FR40_scene-flags.json, FR50_presets_verdicts.json. Procedure: (1) `npm run flags -- --check` baseline; (2) dry-run each fragment in order (`npm run flags -- <fragment> --dry-run`), resolve index conflicts with the runtime verdicts (FR beats FL static) and record each decision in plans/flags/results/CO09_flag_apply.md; (3) apply, `flags --check`, `flags -- export`, `flags -- docs`, `scene-flags`, `presets`; (4) re-dry-run the FL*_notes.json specs, keep only entries that still match the live text and are not contradicted by MS01-MS05 (FL30_names.json is retired: do not apply it), merge them as edits/MS06_flags_notes.json with the same user-OK rule as CO-06; (5) append a dated block to plans/flags/flag-analysis-plan.md §12 progress log. Gate: unchanged after every step (flags and notes do not change ROM bytes). Report: plans/flags/results/CO09_flag_apply.md with counts (fragments applied, meanings, indices, conflicts and their resolution).
```

---

### CO-10 Names and mnemonics

- [ ] IT-36..IT-40: run the ACTION_PLAN prompts, each with a names spec under `renames/apply-<range>_names.json`, `address` and `old` taken from `extract:lt` output.
- [ ] `FL30_names.json`: retire (D7). Record in `CO10_names.md` that MS04 applied `...Flagged`.
- [ ] `musicParentActor`: not a ROM name; handled by IT-41..IT-46 or left as a documented note (D6).
- [ ] IT-41..IT-46: only after the user answers D4 (U14/U15). `mnemonics_new.json` stays user-owned.
- [ ] `npm run names -- --check`: fix the 11 formatting problems only if the tool's own rewrite fixes them (a names run touching that bank does); otherwise list them for a tool task.
- [ ] After each: `extract:lt`, `rebuild`, gate unchanged (renames do not change bytes), plain `extract`, and a retranslation build check for any rename that rewrote `IOGRetranslation` references (CO-15).

```text
[Block P]
STEP CO-10 (names). Run ACTION_PLAN.md §12 IT-36, 37, 38, 39, 40 in order (and IT-41..46 only if the user has answered decisions U14/U15 in ACTION_PLAN §11; otherwise skip them and say so). For each: read the prompt and the A13 group it names; take `address` and `old` from the `npm run extract:lt` output, never from blocks.json or files.json; write renames/apply-<range>_names.json; `npm run names -- <spec> --dry-run`, show the summary, apply after the user's OK (first iteration) then continue; `npm run extract:lt`, `npm run rebuild`, gate unchanged, `npm run names -- --check`, plain extract. Do not apply plans/flags/results/specs/FL30_names.json (retired: it conflicts with the applied IdleStand*Flagged names). Do not rename musicParentActor (it is a WRAM mnemonic, not a ROM name). Report per iteration mesen2-results/CO10_IT<n>.md: renames, files touched (including any in IOGRXLT/IOGRetranslation), check output.
```

---

### CO-11 Open-question registry and the new questions (IT-35 redefined)

Goal: one searchable place for what remains, so the series can end with an explicit "not answered" list.

- [ ] Collect every "New questions" section of every result file (A..FR, S1, T1, V1, W1-*); give each a `NQ-nnn` id, a source (file and line), and a disposition: DUPLICATE (of an `OQ-` or another `NQ-`), STATIC (answer now, with citation), WORTH-RUNNING, PARK.
- [ ] Write `plans/extracted-audit/open-questions.md` (every non-closed `OQ-` and `NQ-`, with priority, why open, what would close it) and `plans/extracted-audit/static-answers.md` (STATIC answers, each cited; shipped-note changes among them go into a spec for the user to merge, not applied here).
- [ ] Cap WORTH-RUNNING at 10; the rest PARK with the reason.

```text
[Block P]
STEP CO-11 (open-questions registry). Collect all "New questions" and "Open questions" sections from plans/extracted-audit/mesen2-results/*.md (and mesen2-results/specs and the flags results where they carry questions). Give each unmatched question an id NQ-001... with source file and line. Deduplicate against the OQ inventory and against each other. For each: DUPLICATE (of id), STATIC (answer it now with rg/Read, cite file and line or tag), WORTH-RUNNING (name the experiment and the state), PARK (one-line reason). Cap WORTH-RUNNING at 10. Write plans/extracted-audit/open-questions.md and static-answers.md. If a STATIC answer shows a shipped note wrong, put the corrected entry in mesen2-results/specs/CO11_notes.json (dry-run only; the user decides when to merge it). Do not change notes, names or flags.
```

---

### CO-12 Correct the docs that repeat wrong sentences

Targets are in §2.4. Docs outside `extracted/` and `notes/` are edited with the edit tools (no scripts); `merge` and `names` do not apply to them.

- [ ] For each doc line: read the closure row and result file that shows it wrong, then edit the sentence. Keep the doc's style; no ids or `plans/` paths in the doc text unless the doc already links to plans.
- [ ] Run a sweep with `rg` for the old wording (`game over` for `$10` bit `$0200`, `grounded` for bit 3, `A feeds $0080`, slot stride `$40`, `Shadow` idle rows, `ec0E_statue`) across `docs/`, `baserom/`, `gaia-core/docs/`, `gaia-knowledge/curated/`, and list every remaining hit.
- [ ] Fix `gaia-core/docs/notes-and-comments.md:1353` (read MS04 for the wrong statement) and any `patch-development.md` text about X/`$00` or buttons that the runs contradict.
- [ ] Write the list of corrections in the report only (`mesen2-results/CO12_docs.md`), not as a new doc.

```text
[Block P]
STEP CO-12 (doc corrections). Fix the docs that repeat sentences the runtime investigation shows wrong. Start from: MS04_apply.md line 82, W1-c_20261107.md and W1-c_result_template.md "Docs outside extracted/" paragraphs, FR20_20261105.md line 139, FR23, R3, D3, tool-issues.md T-37, and the list in §2.4 of plans/extracted-audit/mesen2-closeout-plan.md. For every doc line: read the closure row or result line that contradicts it, edit the sentence (Edit tools only; no scripts), keep the doc's style. Then sweep docs/, baserom/, gaia-core/docs/ and gaia-knowledge/curated/ with rg for the old wording ("game over" next to $0200 on $10, "grounded", "A feeds $0080", 0x40 slot stride, Shadow idle rows, ec0E_statue) and fix or list every hit. Also fix gaia-core/docs/notes-and-comments.md:1353. Do not run ingest:all. Report mesen2-results/CO12_docs.md: file, line, old statement, new statement, source row.
```

---

### CO-13 Series summaries and the findings index

Model: `docs/mesen2-c-series-summary.md` (sections: Result in one page; What was run; Findings; Shipped notes corrected; Rules for patch authors; Where the findings live in the docs; Tools, states and files; Tool and method lessons; Open questions; Apply log).

- [ ] One summary per series, each from its result files and closure rows: **A** (flag census, forced bits), **B** (collision, ramps, glide), **E** (display, HDMA, Mode 7), **F** (sprite sets, hidden groups), **G** (combat, rewards), **M** (title, boot, maps, menus), **N** (gems, jeweler, stats), **P** (input, buttons), **R** (coverage), **S** (static), **V** (cross-checks), **W1** (player sprite, watch), **FR** (flag runtime). Group where a series has 1-2 small reports (for example M+N, P+S).
- [ ] `docs/mesen2-findings-index.md`: table from fact to doc section to result file, built from the summaries; list the CL-01..CL-12 rules in one place.
- [ ] Every "Rules for patch authors" item must be checkable against a closure row (cite it in the report, not in the doc).

```text
[Block P]
STEP CO-13 (series summaries). Write the missing series summaries in docs/, one per series (A, B, E, F, G, M+N, P+S, R, V, W1, FR; check docs/ first and skip any that exist), using docs/mesen2-c-series-summary.md as the template (same section list). Source each only from the result files and closures.md rows of the series; do not add facts that are not in them. Content: result in one page, what was run, findings with the evidence tag, shipped notes corrected, rules for patch authors, where the findings live in the docs, tools/states/files, open questions (use open-questions.md from CO-11 if it exists). Then write docs/mesen2-findings-index.md: fact -> doc -> series summary, and the CL-01..CL-12 rules in one table. Keep ids out of prose that patch authors read except in the Open questions and Apply log sections. Write mesen2-results/CO13_summaries.md listing every doc written with the result files it used and any claim you could not source (those claims are removed, not softened).
```

---

### CO-14 Plans, inventory and request files

- [ ] `mesen2-investigation-plan.md`: add a dated "Corrections" block at the top (CL-06 vocabulary, §2.1 ROM identities, slot stride on line 196); do not rewrite history below.
- [ ] `mesen2-question-inventory.md`: add a dated block pointing at `open-questions.md` and `closures.md` as the status source (no 358-row rewrite).
- [ ] `ACTION_PLAN.md`: refresh §2 status table (IT-17..IT-53 with the CO package that did them), the gate numbers, and mark overlaps.
- [ ] `mesen2-mcp-enhancement-requests.md`: new dated section: map T-01..T-81 to MCP-nn, mark landed, re-rank the open ones (P0 first), add new requests for the issues with no MCP row. This file is a request list for the server owner; it changes no code.
- [ ] `states-index.md` and `harness/`: confirm every state file referenced in reports exists and has a ROM SHA-1 column; add a README in `harness/` if missing (what each script does, how to run).

```text
[Block P]
STEP CO-14 (plans and requests). Update the plan files without rewriting history: (1) mesen2-investigation-plan.md: dated "Corrections" block at the top (CL-06 button vocabulary as in V1_20261110.md, ROM identities per T1_20261110.md observation 7, actor slot stride $30); (2) mesen2-question-inventory.md: dated block saying status lives in closures.md and open-questions.md; (3) audit-of-audit/ACTION_PLAN.md §2: status per IT with the CO package that covered it, new gate numbers, overlaps; (4) mesen2-mcp-enhancement-requests.md: new dated section mapping T-01..T-81 of tool-issues.md to MCP-nn, which landed, re-ranked open ones (P0 first), new requests for issues with no MCP row; (5) check states-index.md against the files in rebuilt/states and the state names used in the reports, list mismatches, and add harness/README.md if absent. Edit tools only. Report mesen2-results/CO14_plans.md.
```

---

### CO-15 Final audit and verification

- [ ] Run the checks: `npm run names -- --check`, `npm run flags -- --check`, `npm run extract:lt`, `npm run rebuild` (gate), plain `npm run extract`, `npm run rebuild` again (gate equal), `git status` classification.
- [ ] Read-back audits: `rg` over `extracted/` and `notes/` for `OQ-`, `IT-`, `CL-`, `FR`, `FL`, `plans/`, `UNVERIFIED-RUNTIME`, `$8000` in `combat_collision` and `actor_execution`; the four empty transform keys; the two `item_use_system` addresses.
- [ ] Retranslation: confirm `IOGRXLT/IOGRetranslation` still builds after the `TitleEarthSpriteActor` and `IdleStand*Flagged` / `PlayerIdleFlaggedAnim` renames (build command from its README; report if it needs the user's ROM).
- [ ] Definition of done: tick every row in §6 with evidence; list what is left as accepted.
- [ ] Write `mesen2-results/CO15_final.md` and the user-only action list (§7).

```text
[Block P]
STEP CO-15 (final audit). Run the final verification of plans/extracted-audit/mesen2-closeout-plan.md §6 and §8. Do not edit notes, names, docs or specs. Commands: names --check, flags --check, extract:lt then rebuild (compare to GATE), plain extract then rebuild (compare), git status classification of every repo. Sweeps over extracted/ and notes/: ids (OQ-, IT-, CL-, FR, FL), plans/ paths, UNVERIFIED-RUNTIME, `$8000` in combat_collision and actor_execution, the four empty transform keys, the two item_use_system addresses. Retranslation: build check of IOGRXLT/IOGRetranslation after the title/idle renames, per its README (if it needs a ROM you do not have, say so). Then tick every row of §6 with evidence (file and line) or list it as OPEN with the reason. Write mesen2-results/CO15_final.md and finish with the list of user-only actions and a suggested commit message per repo.
```

---

## 5. Order and parallelism

```
CO-00 baseline
  -> CO-01, CO-02, CO-03 (closure rows; sequential because closures.md is append only; drafts may be parallel)
  -> CO-04 residual ledger  ->  (CO-05 optional runtime sessions)
  -> CO-07 tooling (needed by CO-06 for MenuSelectionHandler)
  -> CO-06 MS05 notes
  -> CO-09 flags (registry, flag notes)
  -> CO-08 Part 2 sweeps
  -> CO-10 names (after notes: names rewrites references in notes)
  -> CO-11 registry of open questions (after all closures)
  -> CO-12 doc corrections, CO-13 summaries, CO-14 plans (documents last: facts are final)
  -> CO-15 final audit  ->  user-only actions (§7)
```

Parallel-safe: CO-12 can start for any doc whose closure row already exists; CO-13 summaries can be drafted per series once its rows exist; CO-14 does not depend on CO-11. Never run two packages that apply merge, names or flags at once.

---

## 6. Definition of done for the whole series

- [ ] `CO00_baseline.md` has one GATE line, and the gate is unchanged after every notes-only, names-only and flags-only apply.
- [ ] Every one of the 358 ids has a closure row, or is listed in `open-questions.md` with a disposition (RUN, PARK, ACCEPT-INCONCLUSIVE) and a reason.
- [ ] All 15 P1 ids have closure rows; at least 80% of P2 have a VERIFIED or CONTRADICTED row.
- [ ] Every shipped note shown wrong by a CONTRADICTED row is corrected (MS01..MS05 read-back tables).
- [ ] The 5 T1 sentences and the unmatched A/B/C/E entries have a recorded disposition.
- [ ] `db-us/flags.json`, `scene-flags.json` and presets are populated; `flags --check` clean; `docs/flags/` generated.
- [ ] ACTION_PLAN Part 2 (IT-17..IT-53) each have a report or a "covered by CO-nn" line; U7-U19 answered.
- [ ] `names --check` clean (or the remaining problems are listed as a tool task).
- [ ] Docs in §2.4 corrected; the `rg` sweep of CO-12 has no remaining hit.
- [ ] Series summaries exist for every series (A, B, C, D, E, F, G, M, N, P, R, S, V, W1, FR); `docs/mesen2-findings-index.md` exists.
- [ ] `open-questions.md` and `static-answers.md` exist; WORTH-RUNNING at most 10.
- [ ] Plan files carry their dated corrections (CO-14); MCP request file re-ranked.
- [ ] Retranslation repo builds after the renames.
- [ ] No ids or `plans/` paths in shipped text (CO-15 sweep).

---

## 7. User-only actions

1. Commit, per repo, after each package (the agents never commit): `gaia-iog-baserom` (suggested messages in each `CO*` report), `IOGRXLT/IOGRetranslation` (the rename references), `gaia-core` (if CO-07 or CO-12 changed it).
2. `npm run ingest:all` in `gaia-knowledge` after CO-12..CO-14.
3. Decide D1-D8 of §3 and U7-U19 of ACTION_PLAN §11.
4. Regenerate `IOGRXLT/IOGRetranslation/artifacts/file-layout.json` and run `npm run flags -- export -- labels` as the ACTION_PLAN §15 lists; `mnemonics_new.json` stays yours.
5. Decide `mesen2-results/raw/` (2270 files) and `temp/` (55 files): ignore, commit, or delete.
6. Keep a plain tree for commits: run `npm run extract` (plain) and not `extract:lt` before committing.

Suggested first commit (after CO-00..CO-04, closure rows only): `Mesen2 close-out: baseline, closure rows for A/B/R1/F2, residual question ledger`.

---

## 8. Progress log

Update this section as packages finish (date, package, result, gate, commit message used).

| Package | Status | Date | Report | Gate after |
|---------|--------|------|--------|------------|
| CO-00 baseline | TODO | | | |
| CO-01 close A | TODO | | | |
| CO-02 close B | TODO | | | |
| CO-03 close R1/F2 | TODO | | | |
| CO-04 residual ledger | TODO | | | |
| CO-05 runtime follow-ups (optional) | TODO | | | |
| CO-06 MS05 notes | TODO | | | |
| CO-07 tooling IT-26..32 | TODO | | | |
| CO-08 Part 2 sweeps | TODO | | | |
| CO-09 flags | TODO | | | |
| CO-10 names and mnemonics | TODO | | | |
| CO-11 open-questions registry | TODO | | | |
| CO-12 doc corrections | TODO | | | |
| CO-13 series summaries | TODO | | | |
| CO-14 plans and requests | TODO | | | |
| CO-15 final audit | TODO | | | |
