# IOG script-flag series - sanity check and apply plan

Status: **DRAFT for approval** · Written 2026-11-11 · Replaces the per-iteration apply pass (`flag-analysis-prompts.md` §H "FA") for this series. Companion files: [flag-analysis-plan.md](flag-analysis-plan.md) (design), [flag-analysis-prompts.md](flag-analysis-prompts.md) (iteration prompts).

Goal: take every result of the flag series (FL00-FL41 static, FR00-FR50 runtime) and put it in the shipped files, verified, in one controlled pass: `db-us/flags.json`, `db-us/scene-flags.json`, `db-us/flag-presets.json`, `notes/` (block, part, inline notes), `db-us/names/`, `docs/`, `docs/flags/`, `artifacts/`.

**Result of the sanity check in one paragraph.** The analysis is broad and mostly consistent (all 1,693 literal flag sites, 18 scene-meta gates and 1,440 flag-array bits are accounted for; the spot checks I re-derived from `extracted/` agree), but **the registry chain does not apply with the real tool as written**. Five of the 22 registry fragments are rejected outright, three more fail once the earlier ones are applied, and the dry-runs in the FL32 and FL41 reports that say "OK" ran against a scratch registry that had been *sanitised* to hide exactly those rejections. The 311 runtime verdict rows (FR00-FR50) have no consumer in the tool, the FL32 scene-entry and preset drafts were partly contradicted by FR40/FR50, 8 of the 23 note specs (6 of 19 FL, 2 of 4 FR) and the FL30 names spec no longer match the working tree, and no `GATE:` baseline line exists. So the apply needs a **prepare step** (repair and rebase, authored under `plans/flags/results/apply/`) before one **apply-and-verify prompt** can run mechanically. Section 5 has both prompts.

---

## 0. How to use this plan

| Step | Who | What | Section |
|------|-----|------|---------|
| 0 | You | Commit the in-flight work in three commits (isolates the flag diff), run `npm run extract:lt` | §4 Phase 0 |
| 1 | You | Answer or accept the defaults of the decisions | §3 |
| 2 | Agent, new chat | **PREP prompt**: repair and rebase every input, rehearse on a scratch registry, write `apply/apply-manifest.json` | §5.2 |
| 3 | You | Read the PREP report (10 minutes), say go | §4 Phase 2 |
| 4 | Agent, new chat | **APPLY prompt**: one session applies and verifies everything from the manifest, stops at the first surprise | §5.3 |
| 5 | You | Commit (suggested messages in §8) | §8 |
| 6 | Agent, new chat (optional) | **QA prompt**: independent spot check of the shipped registry | §5.4 |

Why two agent sessions and not one: the sanity check found that the inputs need real authoring work (the registry chain rebase, 279 flag verdict rows to turn into patch rows, about 8 note specs to re-anchor). That is analysis and judgement. The apply itself must be mechanical and fully verifiable, so it gets its own prompt that is not allowed to author anything. If you prefer a single chat, paste PREP and then APPLY into the same session; keep the manifest as the hand-off.

---

## 1. Sanity check

### 1.1 What was checked and how

Read-only, on 2026-11-11, working tree at `HEAD 0dcd500` plus the uncommitted work described in SC-09.

| Check | Method | Result |
|-------|--------|--------|
| Inventory of the series | `plans/flags/results/` (22 reports, 22 registry fragments, 22 queues, 19 note specs, 1 names spec, 2 scene-entry/preset specs, coverage matrix, ranked queue) and `plans/extracted-audit/mesen2-results/` (FR00-FR50 reports, 10 verdict files, 4 note specs, 1 scene-flags spec) | all present, all JSON parses |
| Tool health | `node src/index.ts flags --check`; `flags export --out-dir=<temp>` | OK; the only warning is `scene 10: flag 63 not in the registry yet` |
| Real-tool dry-run of **every registry fragment** against the shipped (empty) `db-us/flags.json` | `flags <fragment> --dry-run`, 22 fragments | see SC-01 |
| Real-tool **sequential chain** on a throwaway copy of `db-us` (outside the repo) in plan order | `flags <fragment> --db-dir=<temp copy>`, no sanitising | see SC-01..SC-03 |
| Same chain after a **mechanical repair** (kinds, `$XXXX set` refs, proposal kinds) on temp copies, to see what is left | temp copies outside the repo | 4 fragments still fail; see SC-01 |
| Note specs | `npm run merge -- <spec> --dry-run` for FL10-FL40 (19) and FR20/21/23/24 (4) | see SC-06 |
| Names spec | `npm run names -- FL30_names.json --dry-run` | see SC-07 |
| Source facts | Re-derived from `extracted/`: 1,693 literal COP flag sites (equals the inventory); 18 `branch <` gates in `tables/scene_meta.asm` (9 distinct indices); `ClearSceneState` `STX $eventFlags` with X = `$0000` at `scene_lifecycle.asm:799` (zeroes `$0A00-$0A01`, as FL10 and FR00 say); flag `$3F` sites in `ec0A_left_guard.asm:17, :30, :32` (the guard script sets `$3F` itself, as FR40 found) | agree |
| Runtime verdicts | Counted and cross-referenced the 10 verdict files against the registry chain | see SC-04 |
| Git state | `git status`, `git diff --cached --stat` | see SC-09 |

Nothing was written under `plans/`, `db-us/`, `notes/`, `extracted/`, `docs/` or `artifacts/`. Temp copies went to the OS temp folder and are disposable.

### 1.2 What checks out

- **Coverage is complete as claimed.** FL41: 1,693/1,693 literal COP sites, 18/18 scene-meta gates, 57/57 helper calls, 1,440 bits each with a status; the ROM scan finds no flag COP the inventory missed. The 1,693 count still equals the live tree.
- **Seventeen of the 22 registry fragments are clean against the real tool** when applied alone to the empty registry: FL10-FL15, FL21-FL28, FL30, FL31, FL40. (In sequence, FL25, FL30 and FL40 then fail; see SC-01.)
- **The lifecycle claims were verified at runtime**, not only in code (FR00: `ClearSceneState` clears exactly `$0A00-$0A01`; overlay save/restore), and FR40 corrected the one shipped claim that was wrong (scene `$0A`: the guard script sets `$3F` itself; the lock ends at frame 278 with A pulses).
- **The queue chain is closed.** `ranked_queue.json` has 341 items (P1 110, P2 161, P3 70), every INFERRED/UNKNOWN meaning has a live item, and FR00-FR50 executed 311 verdict rows against it (232 distinct flag/scope pairs).
- **Tool outputs work.** `flags export` writes both artifacts; `--check` runs; docs generation exists.
- **Nothing in the series asks for an unsafe write.** All runtime writes were to disposable states; no verdict asks for a db change outside the files listed in section 2.

### 1.3 Findings

Severity: **BLOCKER** = the apply cannot start or would write wrong data; **HIGH** = would apply but give wrong or incomplete results; MED / LOW = hygiene. "Phase" says where the plan resolves it.

| ID | Sev | Finding | Evidence | Phase |
|----|-----|---------|----------|-------|
| SC-01 | **BLOCKER** | **The registry chain is rejected by the real tool.** Standalone against the empty registry: FL20 (12 rows rejected, 43 errors: refs written as `"$0016 set"`, `"$0002"`, `"$0025 clear"`), FL29 (24 rows rejected, 50 errors: 17 distinct kinds, 44 uses, outside the controlled list such as `cue`, `busy-interlock`, `pickup-claimed`, area `unused`, proposal `kinds` given as text), FL31b (4 patch rows whose targets come from FL20/FL29), FL32 (659 patch rows, all need earlier records), FL41 (9 rows). In sequence, also: FL25 (scene `$64` row of FL22 needs `expectOld`; proposals `$0146/$0147` already have records), FL30 (index `$00` meaning of 34 scenes overlaps meanings in scenes `$1E $3D $40 $73 $75 $78` and others), FL40 (proposal `$B4` already consumed by FL31). After a mechanical repair of kinds and refs, FL20 still fails (duplicate scope in scene `$06`; `$017C-$017E` need `expectOld` against FL11 records), FL25, FL29 proposals, FL30, FL31b, FL40, FL32 and FL41 still fail. | `/tmp` chain runs of 2026-11-11; section 6.1 ledger | PREP P2 |
| SC-02 | **BLOCKER** | **The "dry-run OK" results of FL32 and FL41 are not evidence.** Both reports validate against a scratch registry built by `fl32_scratchdb.mjs` / `fl41_scratchdb.mjs`, which silently rewrites what the checker rejects (FL32 report: "sanitised: kinds 36, refs 39, scope 2, area 1, overlap 5") and drops the broader of two overlapping D1 meanings. The one dry-run of FL32 against the *real* registry (`FL32_20261104_dryrun_realdb_registry.txt`) rejects 659 of 659 rows. Do not reuse the scratch scripts for the apply. | `plans/flags/tools/fl32_scratchdb.mjs` header; `FL32_20261104_dryrun_chain.txt` | PREP P2 |
| SC-03 | HIGH | **Two merge semantics.** The authors' loader (`fl32_lib.loadRegistry`) merges by replacing the meaning of equal scope, last fragment wins. The tool refuses to replace without `expectOld` or `patch: true`. Every cross-fragment override in the chain therefore needs an explicit row (examples: FL25 vs FL22 scene `$64`; FL20 vs FL11 `$017C-$017E`; FL31/FL40/FL41 proposals vs records). The tool's strictness is right; the fragments must be rebased. | `src/flags.ts` `mergeFlags`; `/tmp/chain_FL25.txt` | PREP P2 |
| SC-04 | HIGH | **Runtime results have no path into the registry.** The 9 `FR*_flag_verdicts.json` files hold 279 flag rows (232 distinct flag/scope pairs; 140 VERIFIED-STATIC to VERIFIED-RUNTIME, 31 INFERRED to VERIFIED-RUNTIME, 20 spine-proposal rows to VERIFIED-RUNTIME, 7 CONTRADICTED, 38 INCONCLUSIVE, 13 rows with `flag: null` for mechanisms, 1 row for `$0530`, an alias of the state word `$0AA6`, which has no record); `FR50_presets_verdicts.json` adds 32 preset rows (311 in all). `flags` has no verdict command, so each row must become a patch row with `grade`, `runtime {result, trial, rom}` (VERIFIED-RUNTIME needs `runtime.result`) and the complete `evidence` list. Four proposals were verified at runtime (`$F8` FR21, `$0138` FR22/FR30, `$0185` FR21/FR30, `$0512` FR30): promote them to records. CONTRADICTED flag rows need a corrected meaning, not just a grade: flag 33 `$21` (FR20 FL21-01), flag 47 `$2F` DiamondBlock (FR21 FL22-04), flag 159 `$9F` Teapot and scene 146 (FR23 FL27-05, FL40-05), `$500`/`$501` (FR40; stays VERIFIED-STATIC, effect text added), the M01 `$F4` claim (FR10 FL32-46). | verdict files; `src/flags.ts:460,504` | PREP P3 |
| SC-05 | HIGH | **The FL32 scene-entry and preset drafts are partly contradicted by FR40/FR50.** FR40 reclassified scene `$0A` (and its shipped note) and supplies `FR40_scene-flags.json` (216 entries, VERIFIED-RUNTIME; 12 scenes INCONCLUSIVE stay as drafted; flags `$500`/`$501` for scenes `$29`/`$55` CONTRADICTED). FR50 lists exact corrections: preset 1 lacks flags 16 and 39, preset 18 needs form Shadow, notes of presets 3, 9, 15 and scene entries 41, 88, 232 make claims the runs refuted; presets 3, 5, 15, 18 CONTRADICTED, 11 INCONCLUSIVE. Applying the FL32 spec unchanged would ship refuted claims to a harness that warps with them by default. | `FR40_20261106.md` "Shipped text now shown wrong", `FR50_20261106.md` "Corrections" | PREP P4 |
| SC-06 | HIGH | **Note specs no longer match the tree.** (a) Six specs (FL10, FL12, FL21, FL30, FL31, FR20) contain `{offset}` comment rows and fail with "file has no `; {address}` tags" because `extracted/` is currently untagged: resolved by `npm run extract:lt`. (b) Anchors (`find` text) that no longer exist, because the uncommitted audit work rewrote the same notes: FL13 (1 row, `field_reveal_object`), FL21 (1, `jeweler_gem`), FL30 (5: `player_character`, `scene_flag_init`, `overworld_exit`, `item_use_system` x2), FL31 (2, the two flag-gated palette thinkers), FR20 (2), FR21 (2). (c) FR23 and FR24 specs already show every row as unchanged: they were applied before. The specs overlap each other on the same note keys (for example `jeweler_gem`, `item_use_system`), so they must be applied in a fixed order, each validated after the previous one. | `/tmp/merge_*.txt` of 2026-11-11 | PREP P5 |
| SC-07 | MED | **`FL30_names.json` is half stale.** Rows 1-4 and 9 expect `IdleStand*Shadow` / `PlayerIdleUseShadowSprite`, which the uncommitted audit already renamed to `IdleStand*Flagged` / `PlayerIdleFlaggedAnim` (`db-us/names/bank02.json`, staged). Rows 5-8 (ladder, shimmy) still match, but target `...Alt` where the audit chose `...Flagged`. | `names --dry-run` | PREP P6 |
| SC-08 | MED | **No gate baseline exists.** The FA prompt says "compare with the newest `GATE:` line of `audit-of-audit/ACTION_PLAN.md`", but no `GATE:` line has been written (the plan refers to §6.2: 223006080 / 2083230829 / 3062204, dated 2026-10-29). `artifacts/crc.json` in the tree reads 222965960 / -34152415 / 3062205 (tagged); FR00 records 222990002 / -575332819 / 3062205 (plain). | `ACTION_PLAN.md:592`, `crc.json`, `FR00_20261104.md` | Phase 0 / APPLY S1 |
| SC-09 | MED | **Dirty tree.** 159 staged files (audit notes, names, docs, `extracted/`), 86 unstaged, 4,792 untracked. The flag work itself was never committed: `plans/flags/`, `src/flags.ts`, `src/flag-inventory.ts`, `db-us/flags.json`, `db-us/scene-flags.json`, `artifacts/flags*.json`, `docs/flags/` (staged only). An apply on top mixes three bodies of work in one diff. | `git status` | Phase 0 |
| SC-10 | MED | **Docs fixes cannot go through `merge`.** The series found wrong claims in markdown: `docs/wram-memory-map.md` §2.7 (lines 376, 381, carry convention), `docs/code/bank02/game-systems.md` (188, 285, 308, 523), `docs/code/bank00/event-flags.md:51`, `docs/code/bank00/actors-player-rewards.md` (182, 199-201), `docs/actor-organization-analysis.md:169`, `docs/code/bank05-midgame-actors.md` (66, 91, 96, 113, 200, 216, 301), `docs/code/bank07-watermia-euro-actors.md` (43, 74, 108, 251, 263, 386, 401), `docs/code/bank04-npc-actors.md` (167-168), `docs/code/bank08-native-dao-pyramid-actors.md` (209, 229, 250, 373, 476), `docs/code/bank0C-scene-spawn-tables-comet.md:440`, `docs/code/bank00/README.md` (142, 492), plus rows in the FL20, FL22, FL24-FL26, FL28 reports. Line numbers are as of the report dates; the uncommitted audit (IT-49/IT-50) also edits these files. | reports FL10, FL11, FL13, FL15, FL21, FL23, FL27, FL29 | PREP P7, APPLY S9 |
| SC-11 | MED | **Plan §12 progress log is stale** (every row "TODO"). | `flag-analysis-plan.md` §12 | APPLY S12 |
| SC-12 | LOW | Evidence cites `file:line {offset}`. Inline comments inserted by the apply shift lines; the offset stays valid. The registry therefore stays correct by offset, `file:line` becomes approximate in files that gain comments. Regenerate `plans/flags/inventory.json` after the apply and compare. | plan F4 | APPLY S10 |
| SC-13 | LOW | `npm run type-check` fails repo-wide (no `@types/node`: ~120 TS2584/TS2591 errors in `merge.ts`, `names-merge.ts`, `notes-common.ts`, `index.ts` as well as the flag files). Environmental, not a flag regression. The checks used here are `flags --check [--strict]` and the dry-runs. | `npm run type-check` | note only |
| SC-14 | LOW | Fragment-level contradictions already found by FL41 (section 6 of its report): `FL27_registry.json:5` cites `wa78_glass_game.asm:538 {498241}` but the tag is on line 539; `$0002` scene `$11` cites line 700 where 701 is right (FL41 patch row exists); `$0146/$0147` name conflict (D-A5); `$0138` name conflict `sp_palace_entrance_open` (FL11, FL32) vs `sp_mu_passage_door_open` (FL25, FL30, FL41). Seven name-prefix warnings (`end_` vs area prefix `ed`, `unused_`). | FL41 report §3, §6 | PREP P2 |
| SC-15 | LOW | `D7` in the registry domain list spans `$0510-$059F`, which includes the state words `$0AA4-$0AB3` (FL10 question 2). No record uses that range. Leave as is; mention in `docs/flags`. | FL10 §14 | none |

---

## 2. Inputs and where each one lands

| Input (all under `plans/flags/results/` unless noted) | Count | Lands in | Tool | Needs |
|--------------------------------------------------------|-------|----------|------|-------|
| `registry/FL10..FL15, FL20..FL29, FL30, FL31, FL31b, FL40, FL32, FL41` | 22 fragments, 683 indices, 912 meanings, 4 proposals | `db-us/flags.json` | `npm run flags -- <fragment>` | repair (SC-01..SC-03) |
| `plans/extracted-audit/mesen2-results/specs/FR*_flag_verdicts.json` | 10 files, 311 rows | `db-us/flags.json` (grade, runtime, effects, promotions) | `npm run flags -- <fragment>` (new FRV fragments) | build (SC-04) |
| `specs/FL32_scene-flags.json` + `mesen2-results/specs/FR40_scene-flags.json` | 228 draft + 216 verified | `db-us/scene-flags.json` | `npm run flags -- scene-flags <spec>` | correct (SC-05) |
| `specs/FL32_presets.json` + `FR50_presets_verdicts.json` | 19 presets + 32 rows | `db-us/flag-presets.json` | `npm run flags -- presets <spec>` | correct (SC-05) |
| `specs/FL10..FL15, FL20..FL31, FL40 _notes.json` and `mesen2-results/specs/FR20, FR21, FR23, FR24 _notes.json` | 19 + 4 specs | `notes/blockNotes`, `partNotes`, `comments` | `npm run merge -- <spec>` | re-anchor (SC-06) |
| `specs/FL30_names.json` | 9 rows | `db-us/names/bank02.json`, `bank0?.json` | `npm run names -- <spec>` | rebase (SC-07) |
| Docs rows in the reports | about 45 lines in 14 files | `docs/**.md` | `StrReplace` (hand edit, rule "no ad-hoc scripts") | verify live lines (SC-10) |
| Registry | all | `artifacts/flags.json`, `artifacts/flag-presets.json`, `artifacts/scenes.json`, `docs/flags/*` | `flags -- export`, `flags -- docs`, `npm run export -- scenes` | after the registry is in |
| `queue/ranked_queue.json`, `coverage.md`, reports, `inventory.*` | n/a | stay in `plans/flags/` (reference, not shipped) | n/a | n/a |

Not applied by this plan: the `plans/extracted-audit/mesen2-results/specs/B*,C*,D*,E*_notes.json` specs and `FR30/FR40 *_verdicts` beyond the registry (they belong to the Mesen2 campaign and its own closeout plan).

---

## 3. Decisions (defaults apply if you say nothing)

| ID | Decision | Default and why | Alternative |
|----|----------|-----------------|-------------|
| D-A1 | **Kind vocabulary.** FL29 used 17 kinds outside the 12 controlled ones (`cue`, `busy-interlock`, `reward-gate`, `write-only`, `gather-condition`, `boss-phase`, `boss-attack`, `trap-trigger`, `kill-switch`, `item-gate`, `gather-trigger`, `pickup-claimed`, `puzzle-solved`, `party-state`, `dead-code`, `boss-defeated`, `pose-switch`). | Map to the 12 (table in PREP prompt) and keep the original word in `notes` so nothing is lost. No tool change. | Widen `KINDS` in `src/flags.ts` (a tool change, docs and `--check` update). |
| D-A2 | **Prerequisite sense.** `requires`/`excludes` hold flag indices or names only; FL20 wrote `"$0025 clear"`. | Store the index; put any "clear" or "set" qualifier in `notes` (`requires: $25 clear`). Edges are "set-time prerequisites" by definition, so "set" needs no text. | Teach the tool `{flag, state}` refs. |
| D-A3 | **D1 overlap rule.** The engine meaning `sys_player_alt_idle_active` (index `$00`, 34 scenes, FL30) overlaps scene meanings of the same index in `$1E $3D $40 $73 $75 $78` and others (FL41: 13 overlaps, 9 intended layering). The tool forbids two meanings of one index in one scene. | Scope the engine meaning to the scenes where it is the only meaning; in each layered scene, keep the scene meaning and add a sentence plus `pairsWith` to the engine record. No tool change, no information dropped (the FL41 scratch script dropped the broad meaning). | Add an explicit `layer: "engine"` scope kind to the tool. |
| D-A4 | **Name of `$0138`.** | `sp_mu_passage_door_open` (code: Palace Key opens the passage to Mu, event block `$38`; FL41 settled it). | `sp_palace_entrance_open`. |
| D-A5 | **`$0146/$0147` names** (set right after the vampires die, before the wire answer). | Rename to `mu_lair_gate_a_open` / `mu_lair_gate_b_open` (FL25 proposal); update the 18 uses in FL32 presets and 2 in FL32 registry rows. | Keep `mu_bomb_wire_cut_*` as a story label. |
| D-A6 | **Area prefix of ending names** (`end_` vs group prefix `ed`) and `unused_`. | Accept the 7 warnings (`--check` passes; `--strict` is not required). | Rename 7 names. |
| D-A7 | **Alt-idle asm names** (4 ladder/shimmy labels still `...Shadow`). | Use the audit's wording: `...Flagged`, not `...Alt`. Drop the five rows already renamed. | Keep `...Alt` and rename the 5 audit names too. |
| D-A8 | **Scene entry for the 33 "needs-spawn-position" scenes** (FR40 question 8). | No new field. The warp coordinates stay in the `note` text (as FR40 wrote them). | Add `spawn` to the exporter. |
| D-A9 | **Preset grades.** | A preset ships `VERIFIED-RUNTIME` only if FR50 replayed the *final* content (flags, items, form) and it passed; corrected presets 1, 3, 5, 15, 18 and the INCONCLUSIVE 11 ship `INFERRED` with the FR50 state names in `evidence`. | Re-run FR50 first. |
| D-A10 | **Scenes with INCONCLUSIVE FR40 results** (12). | Keep the FL32 draft, grade `INFERRED`, `note` appended with what FR40 tried. | Leave them out of `scene-flags.json`. |
| D-A11 | **Docs.** | Commit `docs/flags/` (plan D3) and make the doc edits of SC-10 in the same apply. | Postpone doc edits. |
| D-A12 | **Existing audit gate.** | The apply establishes GATE-0 from fresh plain and tagged builds before changing anything (APPLY S1). If plain and tagged differ, stop and tell you. | Use §6.2 of the ACTION_PLAN. |

---

## 4. Phases

Owner column: **U** = you run it, **A** = an agent run.

| Phase | Owner | Work | Exit gate |
|-------|-------|------|-----------|
| **0 Isolate** | U | Three commits so the flag apply diffs alone. (1) the staged audit work (`git commit` of the index: notes, names, docs, `extracted/`, `scripts/`), (2) the flag tooling and analysis: `src/flags.ts`, `src/flag-inventory.ts`, `src/export.ts`, `src/index.ts`, `package.json`, `db-us/flags.json` (empty skeleton), `db-us/scene-flags.json`, `docs/flags/`, `docs/mesen2-exports.md`, `artifacts/flags.json`, `artifacts/flag-presets.json`, `artifacts/scenes.json`, `plans/flags/`, (3) optional: `plans/extracted-audit/` (4,713 files) and the unstaged `artifacts/crc.json`, `file-layout.json`, `master-lookup.json`, `baserom/` line-ending noise. Then `npm run extract:lt` (the specs need tags). Suggested messages in §8. | `git status --short` shows no staged files and no change in `notes/`, `db-us/names/`, `db-us/flags.json` |
| **1 Decide** | U | Read §3, change any default. | Decisions written under §9 "Decision log" |
| **2 Prepare** | A (PREP prompt) | P1 baseline, P2 registry chain repair and rehearsal, P3 runtime verdict fragments, P4 scene entry and presets, P5 note specs, P6 names spec, P7 docs edit list, P8 manifest. Writes only under `plans/flags/results/apply/`. | Rehearsal passes end to end on a scratch registry with 0 rejections; `apply-manifest.json` written; every expected count recorded |
| **3 Review** | U | Read `plans/flags/results/apply/PREP_<date>.md` (counts, every judgement call, every row dropped). | "Go" |
| **4 Apply and verify** | A (APPLY prompt) | S0 preflight, S1 gate baseline, S2 backups, S3 registry (rehearsal repeat then real), S4 scene-flags and presets, S5 notes specs in order, S6 names, S7 `extract:lt` and `rebuild` and gate compare, S8 export and docs generation, S9 hand docs edits, S10 inventory regenerate and compare, S11 final checks, S12 logs and report. Stops at the first unexpected result. | Section 7 verification matrix all green |
| **5 Commit** | U | Commits of §8. | Clean tree |
| **6 QA** | A (QA prompt, optional) | Independent spot check of the shipped registry and presets (FLQA, adapted). | `FLQA_<date>.md` recommends accept |
| **7 Corpus** | U | `npm run ingest:all` in `gaia-knowledge` so the RAG corpus sees `docs/flags/`. | n/a |

---

## 5. Agent prompts

All prompts assume workspace `c:\Work\gaia-iog-baserom` (multi-root `gaia-snes` also works). Open a **new chat** per prompt.

### 5.1 Common block (paste first, above PREP / APPLY / QA)

```text
You are working on the Illusion of Gaia (US) script-flag series, apply stage. Workspace: c:\Work\gaia-iog-baserom. Read, in this order, before anything else: plans/flags/flag-apply-plan.md (this plan: all of it), plans/flags/flag-analysis-plan.md sections 2, 3, 7, 12; gaia-core/docs/notes-and-comments.md sections "Notes Merge" and "Names Merge"; docs/flags/README.md (the tool reference). Standing rules (.cursor/rules): never run a git command that writes (commit, push, tag, merge, rebase, reset, revert, checkout of paths, stash, clean); git status/diff/log only. Notes, comments, names, registry, scene-flags, presets change ONLY through the package scripts: npm run merge -- <spec>, npm run names -- <spec>, npm run flags -- <file>. Never write a throwaway script that edits notes/, db-us/, extracted/, blocks.json/files.json or docs. Docs markdown is edited with StrReplace, one reviewed change at a time. Helper scripts that only READ and print, or that BUILD fragment/spec files under plans/flags/results/apply/ (never anywhere else), are allowed and must live in plans/flags/tools/ with a header saying exactly what they write. Do not use plans/flags/tools/fl32_scratchdb.mjs or fl41_scratchdb.mjs or any "sanitising" step: the real tool must accept the data as is. Do not edit the original analysis files (plans/flags/results/registry|specs|queue|*.md and mesen2-results/): derive new files. Accumulator-implied mnemonics are bare (LSR, not LSR A) in any asm text you quote or draft.
Stop rule: if a step's expected result does not match, stop that step, write what you saw (command, output), and ask me; do not work around the tool, do not drop rows silently, do not fall back to an old method. Every row you drop, change in meaning, or decide yourself goes into the report with the reason.
Flag facts: global index n = WRAM byte 0x0A00 + (n >> 3), bit n & 7; registry keys are decimal global indices; operands in asm text are hex; index conventions of plan section 2.1 (WRAM-relative helper indices add 0x0400); flags 0000-000F are scene scratch; grades are VERIFIED-RUNTIME, VERIFIED-STATIC, INFERRED, UNKNOWN (CONTRADICTED is a verdict, not a grade).
Commands run as: node src/index.ts <cmd> or npm run <cmd> -- ... from the repo root. npm run type-check fails repo-wide for an unrelated reason (missing @types/node): ignore it. Use --db-dir=<dir> to run flags against a scratch copy of db-us (absolute path or relative to the repo root).
```

### 5.2 PREP prompt (one session, authoring)

```text
APPLY-STAGE PREP. Paste the common block above first. Phase 0 of plans/flags/flag-apply-plan.md is done (I committed; extracted/ is line-tagged). Decisions: use the defaults of section 3 except: <list any change here, or "none">.
Goal: make every input of the flag series acceptable to the REAL tools, rehearse the whole apply on a scratch copy, and write a manifest that the APPLY prompt can run without authoring anything. You write ONLY under plans/flags/results/apply/ (create: registry/, scene-flags/, presets/, notes/, names/, docs/, _rehearsal_db/) and plans/flags/tools/ (new read-only or builder helpers, each with a header naming what it writes). Report: plans/flags/results/apply/PREP_<yyyymmdd>.md.

P1 Baseline. git status --short (summarise by folder), confirm the extracted tree is tagged (rg -c "; \{[0-9]+\}" extracted/system/engine/scene_lifecycle.asm > 0) and that notes/, db-us/names/ and db-us/flags.json have no uncommitted change; if not, stop and tell me. Record the HEAD short hash. Re-run the sanity check of plan section 1.1 rows "registry fragment dry-run" and "note specs" and list any difference from section 1.3 (new or fixed findings).

P2 Registry chain. Rebase the 22 fragments in this fixed order: FL10 FL11 FL12 FL13 FL14 FL15 FL20 FL21 FL22 FL23 FL24 FL25 FL26 FL27 FL28 FL29 FL30 FL31 FL31b FL40 FL32 FL41. For each, write plans/flags/results/apply/registry/<NN>_<name>.json (NN = 01..22 in that order) that the real tool accepts when applied in sequence to a scratch registry (npm run flags -- <file> --db-dir=plans/flags/results/apply/_rehearsal_db; start the rehearsal from a copy of db-us/ with the empty flags.json; reset it whenever you re-run the chain from FL10). Allowed edits, all logged:
 (a) kinds outside the 12 controlled kinds: map as in the table below and append the original word to the meaning's notes (decision D-A1);
 (b) requires/excludes/pairsWith entries "$XXXX set|clear|<plain>": convert to the decimal index, put "set"/"clear" qualifiers other than "set" into notes (D-A2);
 (c) proposals whose kinds is text: make it a list; proposals for an index that already has a record by that point in the chain: drop the proposal (the record wins) and say so;
 (d) a meaning that replaces an earlier meaning of the same scope: add expectOld (the stored name, or {field: text} for a nameless row) or "patch": true as the tool requires; a duplicate scope inside one fragment: merge the two meanings (keep every evidence line and queue id);
 (e) D1 overlaps (index 0 engine meaning vs scene meanings): apply decision D-A3 and re-list every scene whose meaning changed;
 (f) area "unused": use "system" and put "dead code (extracted/unused)" in notes; name prefix warnings stay;
 (g) patch rows (FL31b, FL32, FL41) whose expectOld names changed because of (a)-(f), D-A4 or D-A5: re-point them; if a row's target no longer exists, drop it and list it;
 (h) citation fixes found by FL41 (section 6 of the FL41 report): FL27 wa78_glass_game.asm:538 -> :539 {498241}; keep every other evidence string byte for byte.
Forbidden: changing a grade upward, changing a meaning's text beyond what (a)-(h) require, deleting an evidence line, deleting a queue id. Kind map: cue, party-state, boss-phase, boss-attack -> cutscene-stage; pose-switch -> engine; busy-interlock -> handshake; reward-gate, item-gate -> quest-guard; write-only, dead-code -> unknown; gather-condition, gather-trigger, trap-trigger, kill-switch, puzzle-solved -> puzzle-state; pickup-claimed -> reward-claimed; boss-defeated -> quest-done. Anything not in the table: ask me.
Acceptance: all 22 files apply in sequence with 0 rejected and no error; npm run flags -- --check --db-dir=plans/flags/results/apply/_rehearsal_db is OK (warnings listed); 683 indices and 912 meanings (plus the 4 proposals, which P3 promotes) or every difference explained; the number of INFERRED/UNKNOWN meanings without a queue id is 0 or listed. Write a change ledger table to the report: fragment | rows in | rows out | rows changed by rule (a)-(h) | rows dropped | reason.

P3 Runtime verdicts -> registry. Read the 10 files plans/extracted-audit/mesen2-results/specs/FR*_flag_verdicts.json (311 rows; sample keys flag, scope, queueId, verdict, grade, effects, expectGrade, evidence). Write plans/flags/results/apply/registry/30_FRV_<name>.json fragments (one per FR step is fine, numbered 30..39; each must keep the sequence valid) using the REAL stored meaning (read it from the rehearsal registry after step 22) and these rules:
 - verdict VERIFIED-RUNTIME: patch row {scope, expectOld: <stored name>, patch: true, grade: "VERIFIED-RUNTIME", runtime: {result: "<FRxx_yyyymmdd>", trial: "<one line from the row>", rom: "O"}, evidence: <the complete stored list plus the FR result section reference>} and effects only where the row's effects differ from the stored ones (then quote both in the report). Several rows for one (flag, scope): one patch row, all trials in runtime.trial separated by "; ", the earliest FR id in result.
 - verdict INCONCLUSIVE: no grade change; append one line to notes ("FRxx: <what was tried>"); keep the queue id.
 - verdict CONTRADICTED: do not just set a grade. Read the row and the FR report section, correct the meaning (summary, effects, requires/excludes, name only if the name states something false), set the grade the final text deserves (VERIFIED-RUNTIME only if the FR run proved the corrected statement itself; otherwise INFERRED), and list every correction in the report with the old and new text. The seven known: flag 33 FL21-01, 47 FL22-04, 159 FL27-05, scene 146 FL40-05, 1280 and 1281 FL32-23/FL32-27 (these two stay VERIFIED-STATIC; add the effect text), the M01 new_game_start claim FL32-46 (flag null: goes to the milestone note in the registry meaning that carries it, or to the report if none does).
 - verdict rows with flag null (13): mechanism rows. Put each in the report table "mechanism verdicts" with the domain record or doc it belongs to; add them to the matching domain's lifecycle text only through plans/flags/results/apply/registry (a "domains" object in a fragment, see docs/flags/README.md) if the tool accepts it, else to docs-edits (P7).
 - flag 1328 ($0530, alias of word $0AA6): no record exists and the range is a state word: send it to docs-edits (P7), not the registry.
 - promote the four proposals that FR verified (248 $F8, 312 $0138, 389 $0185, 1298 $0512): write full records (text from the FL41 proposal, name per D-A4 for 312, grade VERIFIED-RUNTIME, runtime from the verdict); the tool consumes the proposal when the record merges.
Acceptance: the rehearsal chain including FRV fragments applies with 0 rejections; the count of VERIFIED-RUNTIME meanings equals the number of distinct (flag, scope) pairs whose final verdict is VERIFIED-RUNTIME (print both); no meaning is VERIFIED-RUNTIME without runtime.result (the tool enforces it).

P4 Scene entry and presets. Scene entry: plans/flags/results/apply/scene-flags/01_FL32_scene-flags.json = FL32_scene-flags.json with these corrections: scene 10 (existing shipped entry) as FR40 corrected it (add expectOld exactly as the FR40 spec does); scenes 41, 88, 232 notes per FR50 "Shipped text now shown wrong"; names re-pointed for D-A4/D-A5; every names/flags value must exist in the rehearsal registry. 02_FR40_scene-flags.json = FR40_scene-flags.json minus the 12 INCONCLUSIVE scenes (D-A10: their FL32 entries stay, note appended), with expectOld on every row that overrides an FL32 row. Presets: presets/01_FL32_presets.json = FL32_presets.json with the FR50 corrections (preset 1 flags + 16 and + 39; preset 18 form Shadow; the notes of presets 3, 9, 15, 18 and the evidence lines; the 18 uses of $0146/$0147 names) and grades per D-A9 (list every preset with grade, state file name from states-index.md, reason). Validate: npm run flags -- scene-flags <spec> --db-dir=<rehearsal> and npm run flags -- presets <spec> --db-dir=<rehearsal> (apply for real into the rehearsal copy, in order), then npm run flags -- --check --db-dir=<rehearsal> is OK. Record the final counts per entry class and per preset grade.

P5 Note specs. Order (fixed): FL10 FL11 FL12 FL13 FL14 FL15 FL20 FL21 FL22 FL23 FL24 FL25 FL26 FL27 FL28 FL29 FL30 FL31 FL40, then mesen2-results FR20 FR21 FR23 FR24. For each: copy to plans/flags/results/apply/notes/<NN>_<name>.json, then run npm run merge -- <copy> --dry-run (the tree is tagged now, so comment rows validate). Classify every row: ok / already applied (the note already says it: drop the row) / anchor drifted (the note text changed under the audit: read the live note from notes/, re-derive the row so that it states what the code does now and keeps the flag facts of the finding; never restore text the audit removed on purpose) / target gone (drop, list) / conflicts with an earlier spec in the sequence on the same note key (merge into the later spec so the final text carries both, list). The stale rows are known in plan section 1.3 SC-06 (FL13 x1, FL21 x1, FL30 x5, FL31 x2, FR20 x2, FR21 x2; FR23 and FR24 are already applied). Text rules: present tense, what the code does now, no history and no iteration or question ids, waits as operand and ticks, bare accumulator mnemonics (gaia-core/docs/notes-and-comments.md "Comment Authoring Guide"). Because later specs may anchor on text that earlier specs write, and you may not apply in this session, check each spec's `find` strings against the live notes plus the replace text of the earlier specs in the sequence (state this check in the report) and list the specs that only a real sequential apply can confirm; the APPLY prompt dry-runs each spec right before applying it and stops on a rejection. Report table: spec | rows | ok | dropped (already applied) | re-anchored | merged | notes files touched.

P6 Names. plans/flags/results/apply/names/01_FL30_names.json: regenerate from FL30_names.json for the current names (D-A7): drop rows 1-4 and 9 (renamed by the audit), keep rows 5-8 with the new text "...Flagged" (take address and old label from the line-tracked asm and db-us/names, never from memory); npm run names -- <spec> --dry-run must report 4 renames. Look for any other label the flag series calls wrong (grep the reports for "label" and "name" contradictions) and list, do not add.

P7 Docs. plans/flags/results/apply/docs/docs-edits.md: one entry per wrong line the reports found (SC-10 list plus every docs path in the "Contradictions" / "Shipped text" sections of FL10-FL41 and FR00-FR50): file, the LIVE line number now (read the file), exact old text, exact new text, report and row that proves it, and the check you ran in extracted/ (file:line {offset}). Skip an entry whose text is already right (the audit edited these files) and say so. For docs/wram-memory-map.md section 2.7 take the replacement text from FL10 report section 4; for the mechanism verdicts and flag 1328 of P3 add the entries here. Each entry is something APPLY can do with one StrReplace.

P8 Manifest. plans/flags/results/apply/apply-manifest.json: ordered list of steps {id, command, file, expect: {added, changed, unchanged, rejected, or counts}}, the expected end state (indices, meanings, grades by count, scene entries by class, presets by grade, notes files touched, names renamed, docs entries), the rehearsal command log, and the list of anything APPLY must stop on. Then write the report: P1-P8 results, judgement calls, rows dropped, decisions used, risks, and the exact sentence "PREP complete: the rehearsal applied N fragments with 0 rejections" or the list of what blocks.
Do not apply anything to db-us/, notes/, extracted/, docs/ or artifacts/ in this session. Final message: counts, every judgement call that I should look at, blockers, recommendation to start APPLY.
```

### 5.3 APPLY prompt (one session, mechanical: apply and verify everything)

```text
APPLY ALL FLAG WORK. Paste the common block above first. Inputs: plans/flags/results/apply/apply-manifest.json and the PREP report (read both fully; if the manifest or report is missing or says anything but "PREP complete", stop). I have read the PREP report and say go. You may run npm run extract:lt, npm run rebuild, npm run extract, npm run flags (all forms), npm run merge, npm run names and npm run export in this session; nothing else that writes, and no git write command. You author NOTHING in this session except the progress-log lines and the final report; every spec, fragment and docs entry comes from the manifest. If a command's output does not equal the manifest's expectation, stop at once, show me the command, the output and the expectation, and wait.

S0 Preflight. git status --short: summarise; confirm no staged files and no uncommitted change in notes/, db-us/names/, db-us/flags.json, db-us/scene-flags.json, db-us/flag-presets.json, docs/. Record HEAD. node src/index.ts flags --check must be OK (the warning about scene 10 is expected). Confirm extracted/ is line-tagged.
S1 Gate baseline (GATE-0). npm run rebuild (tagged tree) and record artifacts/crc.json checksum / crc / totalSize / mode / sha1 and the ROM SHA-1; then npm run extract, npm run rebuild (plain), record the same; plain and tagged must be identical in checksum, crc and totalSize (the audit rule). If they differ, or if neither equals ACTION_PLAN section 6.2 (223006080 / 2083230829 / 3062204) AND I have not told you the baseline is different, stop and ask. Then npm run extract:lt again so the tree is tagged for the merges. Write the GATE-0 line to the progress log of this plan (section 9).
S2 Backups. Copy db-us/flags.json, db-us/scene-flags.json, db-us/flag-presets.json (if present), db-us/names/, notes/ and artifacts/ to plans/flags/results/apply/backup_<yyyymmdd-hhmm>/ (a plain copy). This is the only recovery path; tell me its path.
S3 Registry. (a) Rehearse again: copy db-us to plans/flags/results/apply/_rehearsal_db (empty flags.json) and apply registry/01..NN in manifest order; every step must match the manifest's added/changed/unchanged/rejected numbers. (b) Real run, in the same order: for each fragment npm run flags -- <file> --dry-run, compare with the manifest, then without --dry-run, then npm run flags -- --check (errors stop; warnings are listed against the manifest's warning list). Report the running totals (indices, meanings) after each fragment on one line.
S4 Scene entry and presets. npm run flags -- scene-flags <spec> --dry-run then apply, for the manifest's specs in order (FL32 draft, then FR40 overlay); npm run flags -- presets <spec> --dry-run then apply; npm run flags -- --check --strict must show only the warnings that the manifest lists. Print the counts per entry class and per preset grade and compare.
S5 Notes. For each spec of the manifest, in order: npm run merge -- <spec> --dry-run; compare the counts and the rejected list with the manifest (rejections must be 0); then apply; then the next one (each dry-run happens after the previous apply, so anchors chain correctly). After the last: npm run merge -- --check (no orphan key; list each left key with its reason, as the audit's IT-53 does).
S6 Names. npm run names -- <spec> --dry-run (expect the manifest's renames), apply, npm run names -- --check.
S7 Rebuild gate. npm run extract:lt; npm run rebuild (tagged); npm run extract; npm run rebuild (plain). Both must equal GATE-0 (checksum, crc, totalSize). If the plain build differs, a comment landed on a hazard address: find the note that did it (bisect by spec, using the backup), report the address, and do NOT edit transforms.json. End with the tagged tree in place (npm run extract:lt) for step S10.
S8 Exports and generated docs. npm run flags -- export; npm run flags -- docs; npm run export -- scenes. Verify: artifacts/flags.json has one row per record meaning and carries the registry counts of the manifest; artifacts/flag-presets.json has the preset count; artifacts/scenes.json requiredFlags for scene 10 matches the shipped entry (it is NOT "locked until flag 63" any more: check the manifest's text); docs/flags/README.md and the area pages are regenerated and mention every domain. Re-run npm run flags -- --check.
S9 Docs edits. Apply plans/flags/results/apply/docs/docs-edits.md entry by entry with StrReplace; before each, read the live lines and confirm the old text is still there; if not, skip and list it. Never change anything but the entry's text. After all: rg the changed files for the old phrases to prove they are gone.
S10 Inventory regenerate. npm run extract:lt (if not tagged) then npm run flags -- inventory --dry-run --compare=plans/flags/inventory.json: the site counts must be equal (1,693 COP sites, 57 helper calls, 18 scene-meta gates); line-number shifts from the new comments are expected and listed; if counts differ, stop. Apply (npm run flags -- inventory) only if the manifest says so. Run npm run extract at the end so the committed tree is the plain one.
S11 Final checks (record command and result of each): node src/index.ts flags --check --strict (warnings only as listed), npm run merge -- --check, npm run names -- --check, the section 7 verification matrix of plans/flags/flag-apply-plan.md row by row (counts of indices, meanings, grades, scene classes, presets, notes files, names, docs entries), rg sweeps over extracted/ and notes/ for the old wrong phrases the reports quote (counts per sweep), git status --short and git diff --stat summarised by folder (nothing outside db-us/, notes/, extracted/, docs/, artifacts/, plans/flags/ may change).
S12 Logs and report. Fill the progress log of plans/flags/flag-apply-plan.md section 9 (one line per step with the dry-run and apply counts) and section 12 of flag-analysis-plan.md (every FL/FR row: status DONE, date, counts, "Applied" yes with the step). Write plans/flags/results/apply/APPLY_<yyyymmdd>.md (commands, outputs trimmed to the counts, every stop and decision). Final message: what changed by folder, GATE-0 and final gate numbers, verification matrix result, everything skipped and why, and the closing sentence: "Please commit when you're ready", followed by the suggested commit messages of plan section 8. Never commit.
```

### 5.4 QA prompt (optional, independent session)

```text
QUALITY CHECK of the applied flag registry. Paste the common block first. You did not write these records. Read plan sections 3.1, 3.6, 4.3 of flag-analysis-plan.md and docs/flags/README.md. Using only db-us/flags.json, db-us/scene-flags.json, db-us/flag-presets.json and extracted/ (line-tagged: run npm run extract:lt only if the tree is untagged, and npm run extract at the end), pick 16 meanings at random (at least 4 scratch D1, 4 spine, 3 VERIFIED-RUNTIME, 3 INFERRED, 2 CONTRADICTED-then-corrected from the PREP report) and 6 scenes of scene-flags.json and 4 presets. For each flag re-derive the meaning from the asm without reading the record's summary first (find the sites by offset with rg "; \{<n>\}" extracted, read the branch target, apply the sense rule: sense 00 = branch when clear), then compare: name, summary, kinds, grade, requires/excludes, evidence (open every cited file:line and check the {offset} tag on that line; line drift from new comments is expected, offset wins), and for VERIFIED-RUNTIME that runtime.result names an FR report that contains the trial. For scenes and presets check the entry class and the flags against the matching FR40/FR50 rows. Also check: no name is reused across indices; D1 records all have scopes; plans/flags/results/apply/APPLY_<date>.md numbers equal what the files hold now. Write plans/flags/results/FLQA_APPLY_<yyyymmdd>.md: per item agree / disagree / evidence wrong, systematic errors (branch sense reversed, scratch flag without scope, WRAM-relative index not converted, index reuse), recommendation (accept / fix list / redo). Write nothing else; no git write commands.
```

---

## 6. Appendices

### 6.1 Rejection ledger (real tool, 2026-11-11)

"Alone" = fragment dry-run against the shipped empty `db-us/flags.json`. "Chain" = applied in plan order on a temp copy with the earlier fragments applied (failed fragments stay unapplied, so later results are lower bounds). "After mechanical repair" = kinds, refs and proposal kinds fixed on temp copies.

| Fragment | Alone | Chain | After mechanical repair | Cause |
|----------|-------|-------|-------------------------|-------|
| FL10, FL11, FL12, FL13, FL14, FL15 | OK | OK | OK | |
| FL20 | 12 rejected (43 errors) | 15 rejected | 6 rejected | refs `"$0016 set"`, `"$0002"`; duplicate scope scene `$06` actors in one fragment; `$017C-$017E` already have FL11 records (needs `expectOld`) |
| FL21, FL22, FL23, FL24 | OK | OK | OK | |
| FL25 | OK | 3 rejected | 3 rejected | scene `$64` row of FL22 at index 15 needs `expectOld`; proposals `$0146`, `$0147` already records |
| FL26, FL27, FL28 | OK | OK | OK | |
| FL29 | 24 rejected (50 errors) | 24 rejected | 5 rejected | 17 kinds off the list (44 uses), area `unused`; proposals with text `kinds` |
| FL30 | OK | 1 rejected (6+ overlaps) | 1 rejected | index `$00` engine meaning overlaps scene meanings |
| FL31 | OK | OK | OK | |
| FL31b | 4 rejected | 2 rejected | 2 rejected | targets `$8E` and `$0179` live in FL20/FL29 |
| FL40 | OK | 1 rejected | 1 rejected | proposal `$B4` consumed by FL31 |
| FL32 | 659 rejected | 64 rejected | 64 rejected | targets from FL20/FL29/FL31b missing; cascades |
| FL41 | 9 rejected | 7 rejected | 7 rejected | `expectOld` names from FL20/FL29 missing |

The chain total after PREP must be 0 rejections; the PREP report reproduces this table with the new numbers.

### 6.2 Runtime verdict summary (FR00-FR50)

| File | Rows | VERIFIED-RUNTIME | CONTRADICTED | INCONCLUSIVE |
|------|-----:|-----------------:|-------------:|-------------:|
| FR00 | 8 | 5 | 0 | 3 |
| FR10 | 50 | 46 | 1 | 3 |
| FR20 | 24 | 15 | 1 | 8 |
| FR21 | 26 | 24 | 1 | 1 |
| FR22 | 25 | 21 | 0 | 4 |
| FR23 | 25 | 21 | 2 | 2 |
| FR24 | 29 | 28 | 0 | 1 |
| FR30 | 47 | 43 | 0 | 4 |
| FR40 | 45 | 31 | 2 | 12 |
| FR50 (presets) | 32 | 25 | 6 | 1 |
| Total | 311 | 259 | 13 | 39 |

Flag-verdict files only (FR00-FR40): 279 rows, 234 VERIFIED-RUNTIME, 7 CONTRADICTED, 38 INCONCLUSIVE. Grade transitions in them: VERIFIED-STATIC to VERIFIED-RUNTIME 140, INFERRED to VERIFIED-RUNTIME 31, spine proposals to VERIFIED-RUNTIME 20 (4 distinct flags: 248, 312, 389, 1298), UNKNOWN to VERIFIED-RUNTIME 1, INFERRED to CONTRADICTED 1; the remaining rows have no stored grade (mechanism, scratch-row and alias rows) or stay unchanged (INCONCLUSIVE, re-observations).

### 6.3 Note and names spec state (dry-run 2026-11-11, untagged tree)

| Spec | Files | State |
|------|------:|-------|
| FL10 | 5 | 4 comment rows need tags |
| FL11, FL14, FL15, FL20, FL22-FL29, FL40 | 1-20 each | clean |
| FL12 | 2 | 4 comment rows need tags |
| FL13 | 2 | 1 stale anchor (`field_reveal_object`) |
| FL21 | many | 1 comment row needs tag, 1 stale anchor (`jeweler_gem`) |
| FL30 | many | 17 comment rows need tags, 5 stale anchors |
| FL31 | 4+ | 5 comment rows need tags, 2 stale anchors |
| FR20 | 2 | 2 stale anchors, 1 needs tag |
| FR21 | 3 | 2 stale anchors |
| FR23, FR24 | 3, 2 | already applied (all rows unchanged) |
| FL30_names | 9 rows | 4 apply, 5 stale |

---

## 7. Verification matrix (APPLY step S11 fills this in)

| # | Check | Expected | Source |
|---|-------|----------|--------|
| V1 | `flags --check --strict` | OK; warnings = the manifest list (name prefixes, 7) | tool |
| V2 | `db-us/flags.json` indices, meanings | 687 indices (683 + 4 promoted), 916 meanings (912 + 4), 0 proposals left, or the exact numbers the manifest records | manifest |
| V3 | Meanings by grade | VERIFIED-RUNTIME = distinct (flag, scope) pairs with a final VERIFIED-RUNTIME verdict; no UNKNOWN or INFERRED without a `queue` id | manifest, FL41 |
| V4 | Names | 0 duplicates; 0 D1 records with `scope: null` | tool |
| V5 | `db-us/scene-flags.json` | 228 entries; classes per manifest (draft: free 148, cutscene 76, locked-until-flag 1, unknown 3; after FR40: scene `$0A` is `cutscene`, no `locked-until-flag` left) | manifest, FR40 |
| V6 | `db-us/flag-presets.json` | 19 presets; grades per D-A9 | manifest, FR50 |
| V7 | Notes | every spec applied with 0 rejections; `merge --check` clean | manifest |
| V8 | Names | 4 renames; `names --check` clean | manifest |
| V9 | Gate | plain and tagged builds equal GATE-0 (checksum, crc, totalSize) | S1, S7 |
| V10 | Inventory | 1,693 COP sites, 57 helper calls, 18 scene-meta gates | S10 |
| V11 | Exports | `artifacts/flags.json` rows = meanings; `artifacts/scenes.json` carries entry class and names; `docs/flags/` regenerated | S8 |
| V12 | Docs | every docs-edits entry applied or listed as skipped with a reason; old phrases absent | S9 |
| V13 | Scope of change | git diff touches only `db-us/`, `notes/`, `extracted/`, `docs/`, `artifacts/`, `plans/flags/` | S11 |
| V14 | Shipped contradictions closed | `db-us/scene-flags.json` scene 10 note no longer says the guard locks until `$3F` is set; `docs/wram-memory-map.md` §2.7 no longer says `$0A00-$0AFF` is all persistent or that carry is inverted | S9, S4 |

---

## 8. Commits (you run them; agents never commit)

Phase 0 (before PREP):

1. `audit-of-audit: notes, names, docs and extracted updates through IT-5x` (the staged work)
2. `flags: registry tooling, inventory, analysis results and runtime verdicts (FL00-FL41, FR00-FR50)` (tool, skeleton db files, `docs/flags/`, `plans/flags/`; `plans/extracted-audit/mesen2-results/` can go in commit 3)
3. `plans: extracted-audit and mesen2 results` (optional, large)

After APPLY (suggested):

1. `flags: apply the script-flag registry (683 indices, runtime-verified), scene entry classes and checkpoint presets` (`db-us/flags.json`, `db-us/scene-flags.json`, `db-us/flag-presets.json`)
2. `flags: notes, comments and labels from the flag series; docs corrections` (`notes/`, `db-us/names/`, `docs/`, `extracted/`)
3. `flags: generated exports and docs` (`artifacts/`, `docs/flags/`, `plans/flags/` logs and apply report)

---

## 9. Progress log and checklist

Update as steps finish (agents append a line per step; dates in 2026).

### Checklist

- [x] Sanity check run (this document, section 1)
- [ ] Phase 0: three commits, `npm run extract:lt`
- [ ] Phase 1: decisions confirmed (section 3)
- [ ] PREP P1 baseline and recheck of findings
- [ ] PREP P2 registry chain repaired and rehearsed (22 fragments, 0 rejections)
- [ ] PREP P3 runtime verdict fragments, 4 promotions, 6 contradictions corrected
- [ ] PREP P4 scene entry and presets corrected and rehearsed
- [ ] PREP P5 note specs re-anchored (SC-06)
- [ ] PREP P6 names spec rebased
- [ ] PREP P7 docs edit list
- [ ] PREP P8 manifest and report; review "go"
- [ ] APPLY S0 preflight
- [ ] APPLY S1 GATE-0
- [ ] APPLY S2 backups
- [ ] APPLY S3 registry (rehearsal + real)
- [ ] APPLY S4 scene entry and presets
- [ ] APPLY S5 notes
- [ ] APPLY S6 names
- [ ] APPLY S7 rebuild gate
- [ ] APPLY S8 exports and generated docs
- [ ] APPLY S9 docs edits
- [ ] APPLY S10 inventory regenerate
- [ ] APPLY S11 verification matrix
- [ ] APPLY S12 logs and report
- [ ] Commits (section 8)
- [ ] QA (optional)
- [ ] `gaia-knowledge` `npm run ingest:all`

### Decision log

| ID | Decision | Date |
|----|----------|------|
| D-A1 .. D-A12 | defaults, unless changed here | |

### Progress log

| Date | Step | Result |
|------|------|--------|
| 2026-11-11 | Sanity check | 15 findings (2 blockers, 4 high); see section 1.3 |
