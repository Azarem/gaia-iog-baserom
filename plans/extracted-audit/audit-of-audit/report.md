# Audit of the audit — report A00 (version 2, complete read)

Date: 2026-10-28. Scope: `plans/extracted-audit/` (iterations I001–I072, B001), the notes, names and docs they changed, and the tooling around them.
This is an action-plan document. Nothing here was fixed: no notes, names, docs or db files were edited by this pass. Open questions (OQ-*) are only triaged (§10); answering them is a separate pass.
Version 2 replaces version 1 of the same day. It is based on reading **every** results file, every apply summary and the four sanity checks (digests in this folder), and it corrects four errors in version 1 (§0.3).
Companions: `digest_I001-I020.md`, `digest_I021-I040.md`, `digest_I041-I072.md` (per-iteration facts, one section per range) and `PLAN.md` (what is left).

---

## 0. Method, coverage and limits

### 0.1 Evidence tags
- **VERIFIED** = checked this pass against the live files (extracted `.asm`, `db-us/*`, notes JSON, docs, `git`, directory listings), with file and line where the item is a line.
- **REPORTED** = taken from a ledger (results, apply summary, sanity check) and not re-checked.
- **UNVERIFIED-RUNTIME** = needs Mesen2. No matching ROM or state was ever loaded in any iteration, so **every behavioural claim in the whole campaign is static** (evidence E1–E4, never E5).

### 0.2 What was read
| Source | Coverage |
|---|---|
| `results/` (58 files: `I001-I020_results.md`, I021–I072, B001) | **all read in full** |
| Apply summaries (5), apply plans (3 present), sanity checks (4) and `renames/sanity-I051-I060_renames.md` | all read |
| `renames/I061`–`I072_renames.md`, `questions/I061, I065, I066, I067, I069, I072` | read; the other rename and question files, and all `edits/` specs (1.8 MB), were **not** read file by file. Their content is represented in the results files (every results file lists its rows, OQs and edits) |
| `gaia-core/docs/notes-and-comments.md`, plan, `checklist.md` | read |
| Live files | spot-verified (§4); a full live re-verification is A06–A10 |

Inventory (VERIFIED by directory listing): `results/` 58, `renames/` 82, `questions/` 57, `edits/` 75, plus `checklist.md`; `temp/` in the baserom holds **54 entries, 40 of them scripts**.
"Run I071 and I072" was asked earlier and was already done; nothing was re-run.

### 0.3 Corrections to version 1 of this report
| Version 1 said | Correct |
|---|---|
| "the first sanity check reported 1,182 sentence-level fixes" (P-5) | The 1,182 are the **I041–I050** sanity check (comment-per-instruction noise removed). I001–I020 and I021–I040 counts are in their own digests. |
| `OQ-I065-3` is a "newly answered" question | It repeats the answer registered earlier (mnemonic row 67, I009/I013: `$06F2` is the track id). Duplicate rediscovery, see P-9 |
| "about 45 throwaway `.mjs` scripts" | 54 entries in `temp/`, 40 scripts (a mix of `.mjs`, `.py`, `.js`, `.sh`) |
| rename backlog (§3) | The apply summaries show the I001–I072 rename rows **applied** through the `names` tool; the unapplied remainder is what §3 now lists |

---

## 1. Executive summary

The campaign is structurally sound. Renames propagate cleanly (no retired block name survives in `docs/`, `baserom/`, `src/`, `db-us/`, `us/`; VERIFIED), later iterations cite code evidence and the sanity passes keep finding and fixing real defects. The problems are what the process did *not* cover and how it validated itself.

### 1.1 The ten findings that matter most
1. **The gate does not cover the `extract` (plain) build.** 3,062,204 bytes (`extract:lt`) vs 3,062,189 (`extract`); five multi-line transforms fail when `; {addr}` tags intervene (G-1). Every "gate unchanged" since I026 is for the tagged build only.
2. **Notes are fragile next to transforms.** A part note placed between two labels a multi-line transform regex needs adjacent changed the ROM by 1 byte (I057, `diary_band_*`; VERIFIED live in `transforms.json`). Nothing prevents repeating it (G-6).
3. **Shipped notes that contradict their code still exist** in `scene_script.asm` (lines 75 and 1303), plus an opcode table whose descriptions belong to the old handler names (N-1, N-2, VERIFIED).
4. **Quality of first-pass notes is poor at scale:** Q3 (purpose) failed in **83 of 91** file tables in I025–I054, 14 of 18 in I055–I060 and **35 of 36** in I061–I072; Q2 (operands) failed in 28 of 36 tables. The original annotations were largely guessed from labels (§7).
5. **Frozen ledgers contradict one another**: ten facts stated in an earlier results file are falsified by a later one (digest I041–I072 §3). The most dangerous: "8 header bytes of a sprite group are not read by anything" (B001: hitbox/hurtbox, read by four systems) and the I063 `spriteset_freedan` note text (do not replay that spec).
6. **`WaitByte(n)` n vs n+1 keeps recurring** and 10 lines in 5 audited files are still wrong; no sweep is reported for I001–I020 or I041–I050 (N-4).
7. **Mnemonics: 9 clearly wrong names are used on about 107 operand lines in 37 files** and a further 12 names carry several different meanings (§8.1). Nothing has renamed any of them; this is the cheapest accuracy gain left because a mnemonic rename changes no bytes.
8. **Stale docs repeat claims the notes already fixed**: e.g. `$0B22` "Damage flash timer" in `system-core.md:421, 457` and `data-tables-memory.md:381` against the correct `hpToHeal` in `wram-memory-map.md:378` (N-10, VERIFIED).
9. **Process drift**: scripts changed names, notes and docs (40 in `temp/`); `ingest` and `annotate` were actually run by mistake in two passes; `plans/` is untracked; status per rename row exists only in prose (P-1…P-4).
10. **No sanity pass for I061–I072 and B001**, and no runtime validation of anything. Expect the same defect classes the other ranges had (P-5).

### 1.2 Counts
Done: 72 iterations + B001 of 303 planned (24%). 5 ledger files per iteration; at that rate the remaining 231 iterations would add about 1,150 files (see §12).
Backlog sizes: mnemonic/struct rows ≈ 100 (§8.1), `blocks.json`/`overrides.json` proposals ≈ 20, extractor cases 1 bug in 4 files, dialog-string collisions 3, docs corrections ≈ 25 lines in ≈ 10 files (§5), 745 extracted files still contain generic labels (§8.4), unnoted `.sprite.asm` files (§8.6).

---

## 2. Process and structure findings

### P-1 Rule violations: scratch scripts, `ingest`, `annotate` (REPORTED, partly VERIFIED)
- `temp/` has 54 entries, 40 scripts (VERIFIED): per-range rename appliers (`apply-rename-I041-I050.mjs`, `-I051-I060.mjs`), spec builders (`mkspec*`, `mkmap*`), note checkers (`chk.mjs`, `chknotes.mjs`), doc editors (`docs1…docs14.mjs`, `docedit.mjs`), prose scanners and fixers.
- Admissions in the ledgers: I021–I040 apply used `sed`; I041–I050 and I051–I060 used `.mjs` appliers; the I045/I046 note specs were generated by a scratch builder (admitted in I049); B001 created and deleted `temp/bankscan.mjs`, `notebank.mjs`, `build_B001.py`.
- **`npm run annotate` was used by the I001–I020 apply pass; `npm run ingest:verbose` was run for real by mistake in the I021–I040 apply pass ("restored"), and the I051–I060 sanity check ran a real ingest in a temp copy.** Both commands are now retired (`src/*.donotuse`).
- Sub-agent pass in the I021–I040 sanity check (the rule in this audit-of-audit forbids it; the earlier plan allowed it).
- Impact: doc edits made by scripts can only be reviewed through `git diff`. Hand edits of notes JSON that bypassed `merge` (route note, `MenuSelection_*`, an orphan line) are likewise unrecorded.
- **AP-09:** review the diffs once; delete `temp/` or move it out of the repo. Do not extend the habit.

### P-2 `plans/` and `temp/` untracked (VERIFIED, `git status`)
`?? plans/`, 55 untracked scratch files, modified `artifacts/*`. `git log`: HEAD `694ddb2 More asm audit`, `eb70fc6 I051 - I060`, `06eaa53 I041 - I050`, `d52906a Audit I021 - I040, name changes`. The ledgers exist only on disk. **Action:** commit `plans/` (user); inspect the `artifacts/*` diffs (crc.json = the gate, see G-1).

### P-3 Edit specs are not a replayable record (REPORTED)
`edit` entries (`find`/`until`/`with`) match once and are not idempotent; I001–I014 have no specs; I041–I048, I051–I060, I063 specs were superseded by later hand or scripted fixes; the I061/I062 names specs use **hex addresses** (not replayable under the current rule). The notes JSON snapshot is the truth; `edits/` is an audit trail. **Action:** one sentence in the plan README so nobody replays it.

### P-4 Row status exists only in prose (VERIFIED for I065/I066)
Rename ledgers read "not applied" (written at audit time); apply summaries applied most rows. The I065/I066 ledgers still read "not applied" although `apply-I061-I072_summary.md` applied them. **Action:** one registry file (rows × status) built in A01–A08.

### P-5 Sanity passes: coverage and what they found
| Sanity check | Findings (REPORTED) |
|---|---|
| I001–I020 | large (see digest) |
| I021–I040 | included a sub-agent pass; found orphan comment key, transform collisions |
| I041–I050 | **1,182 comments removed, about 245 rewritten**, 3 stale originals, 1 block note and 1 part note corrected |
| I051–I060 | `WaitByte` n vs n+1 in **12 files** (28 comments, 23 part notes, 7 block notes), derived timings, 3 stale words; 18 of 30 block notes carry a "the old header said…" paragraph; orphan note `loc_03B928` (now deleted, VERIFIED) |
| I061–I072, B001 | **none** |

The live samples in §4 show the same defect classes still present in files from I001–I013, which had a sanity pass, so sanity is not exhaustive either.

### P-6 Checklist and ledgers use retired names (VERIFIED partly)
Appendix A collects retired → current names. **Action:** keep it next to the checklist.

### P-7 Id schemes are inconsistent (VERIFIED)
`R-I065-1`, `R-I071-1a`, `R-SAN2-1`, `R-B001-1`, `D-S5160-n`, legacy `OQ-49/51/57/59/63/67/68` (no iteration prefix), `OQ-I065-3`, `OQ-SAN2-1`; plus `R-` row numbers in `I001-I020_rename-proposals.md` (1–90, a different scheme again). Shipped notes cite some of these ("(OQ-51)"). **Action:** question registry (A12), strip ids from note text (H-3).

### P-8 Out-of-order execution (REPORTED)
I035/I036 ran after I037; I055/I056 ran after I057 (I057's results say "I055 and I056 were skipped at the user's request" yet both have results); I061/I062 ran after I063 (I063 says "I061 and I062 have no results files yet"). Checklist order ≠ time order, which made some "see I0nn" cross-references point forward. Not a defect in itself but a reader needs the real order: I057 → I055/I056; I063 → I061/I062; I037 → I035/I036.

### P-9 Duplicate rediscovery (REPORTED)
The same fact was discovered more than once and logged as new: `$06F2` track id (I009/I013 row 67 → I065 OQ-I065-3 → warps_interaction line 52), the `$80`-prefixed flag semantics, the hidden sprite group count byte (I067, I069, I071, I072 each log it as new). Cost: 4 rows for one extractor bug. **Action:** registry with "answered in" links.

### P-10 Gate flakiness (REPORTED)
- `extract:lt` begins `rm -rf extracted/*`, which failed (open handle on Windows) in I011/I012, I069, I071, I072; workaround was running extract and rebuild by hand.
- I056: first rebuild failed `Patch CrystalBallAutoUse contains a rewrite that does not exist: CODE_05F522`; a second run gave 3,062,189; cause **not investigated** (OQ-I056-9).
- I058: a transient missing `extracted/` left `artifacts/crc.json` holding a bad checksum until both steps were rerun.
- I057: first gate failed 223006106 / 643346720 / 3062203 (the transform-adjacency hazard, resolved by moving the note).
- The 3,062,189 reading in I056 is the **plain** size; it is the gate only if G-1 is decided that way. The rule "gate = 223006080 / 2083230829 / 3062204" holds only for `extract:lt` immediately followed by `rebuild`.

### P-11 Mesen2 never used for evidence (REPORTED)
Connected in several iterations; a save state from another build prevented any use (apply I021–I040). Consequence: Q7 never above M. Any "when / how long / what it looks like" claim (timings, visuals) is static. See §10.

### P-12 Inconsistent iteration products
I041–I048 write one comment per instruction; I049+ write aggregated notes and use the "Status: COMPLETE / Actions taken" header; I061+ add no inline comments (data). The notes in different ranges therefore have very different density, and the sanity checks measure different things. **Action:** a one-page style reference in the plan (policy H-1…H-3 plus "comments only on non-obvious lines").

---

## 3. Rename / structural backlog reconciliation

### 3.1 Applied (REPORTED; spot-checked VERIFIED)
- Name renames in the five apply summaries. `blocks.json` lines 1003–1042 hold `display_preset_table`, `forced_walk_pan_table`, `walk_step_table`, `scene_chest_table`, `ability_damage_tables`, `boot_title_strings`, `item_name_line_table`, `shared_word_table`, `item_pickup_text_table`; the matching `extracted/tables/*.asm` exist.
- Other applied examples (VERIFIED earlier): `SpawnHitSparkSprites` → `SpawnItemSparkleEffect`, `floor_button` → `hit_switch`, `spriteset_will_alt` → `spriteset_will_abilities`, the `diary_band_*` labels, `scene_chest_table`.
- `npm run names -- --check` passed at the end of I066 (2,459 names).
- Retired-name grep over `docs/ baserom/ src/ db-us/ us/`: no matches (VERIFIED, §4.4).

### 3.2 Proposed, not applied (REPORTED)
| Owner | Rows | Examples |
|---|---|---|
| `blocks.json` (user) | ≈ 8 | `forced_walk_pan_table` type `&Binary` → word array (R-I064-1; still `&Binary` at `blocks.json:1005`, VERIFIED); `walk_step_table` struct `direction-velocity` → `walk-step` (still `direction-velocity` at 1007, VERIFIED); sprite-map pointer types |
| `overrides.json` / struct definitions (user) | ≈ 12 | struct field renames R-I064-4, R-I065-8 (`scene_meta`), R-I068-2/3, R-I069-4 |
| `mnemonics.json` (user) | ≈ 100 rows (see §8.1) | `$06F4` music group, `$06F2` track id, the nine wrong names, 12 multi-meaning names |
| Extractor (`gaia-core`) | 1 bug, 4 rows | hidden or unreferenced sprite groups printed as sub-sprites (R-I067-4, R-I069-3, R-I071-3, R-I072-6); the 13th header byte is the count |
| Dialog strings | 3 | name collisions that cannot be 1:1 renamed until the extractor's uniqueness rule is known |
| Sprite maps `spm_*` | 4 files, label scheme | `spm_boot_logos` labels remain `sprite_set_000004`-style offset names; the 8 hit bytes now documented only in notes |
| Docs (user) | many | §5 |

### 3.3 Applied but a decision dangles
- Labels embedding a retired nickname: `FacingData_WillAlt` (`names/bank03.json:473`, address 258431) and `FacingData_AbilityFx` (`:474`, 258458) (VERIFIED). `FacingData_FreedanFx` / `ShadowFx` (`:475–476`) still match their blocks. **AP-04.**
- `walk_step_table` block vs struct `direction-velocity` mismatch.

### 3.4 Rows gated by G-1
Anything touching `sEA_solid_arm`, `pyDD_teleporter`, `pyD7_sliding_wall`, `sFA_diary_menu`, `item_use_system` was verified only in tagged mode (AP-01).

---

## 4. Notes, comments and docs integrity (live findings, VERIFIED unless marked)

### N-1 `scene_script.asm` opcode table: descriptions belong to the old names
`extracted/system/engine/scene_script.asm` block note (lines 15–24):
- `$04 SceneCmd_LoadPalette — "Load single-layer tilemap data to WRAM"`; `$05` "Load dual-layer tilemaps"; `$06` "Full scene graphics: tiles + tilemaps + map geometry"; `$14 SceneCmd_Label — "No operation"`.
- Part notes carry the same drift (`SceneCmd_LoadPalette` "Load tilemap data … palette tilemap", `SceneCmd_Label` "placeholder or padding byte").
- From I065 (E1 trace): `$04` loads palette colours (`< start, end, dest >`); `$05` loads metatile sets; `$06` loads layer maps; `$14` records a label for `scene_meta` (the extractor builds `meta_label_list` from it). The block note's `[scene_id:u16, command_stream…]` / `FindCurrentScene` description is the original ROM; the rebuilt tree indexes `scene_meta_list` via `baserom/scene-load/SceneMetaLoad.patch.asm`.
**Fix F01.**

### N-2 `SpcMusicLoadCmd` comments contradict the code
```
1300:    STA $06F4
1303:    LDA $musicRoomGroup   ; Compare current musicRoomGroup — same group means music is already loaded
1304:    CMP $06F4
```
The next instruction is `BEQ loc_028B88` (the load path); a mismatch hits `RTS`. **Equal → load.** The block note (line 75) "gates loading to prevent redundant transfers when re-entering the same music region" is wrong in the same way; the part note near line 1294 is right; `scene_meta.asm:23` (I065) is right. `musicRoomGroup` (`$06F6`) is a per-scene selector: cleared in `scene_lifecycle.asm:912` and set by scene scripts (`gs2D_lily.asm:98`, `gs2E_sleep.asm:30,64`, `gs2C_crow_crew.asm:71`). Redundant-load prevention is `CheckSourceCacheHit` on `$0687`. `$06F4` (the script's group operand) is unnamed (candidate `sceneMusicGroup`). `docs/code/bank0D-scene-meta.md` repeats the wrong reading (REPORTED). **Fix F01 + doc.**

### N-3 `table_018000` still in prose
`display_preset_table` since I065. Prose remains in `scene_script.asm` (about lines 15, 71, 1159, 1161), `notes/comments/bank02.json` (about 283–284), `docs/structs-reference.md` (362, 833, 841, 843), `docs/bank01-data-tables.md` (46, 688), `docs/code/bank02/scene-script.md` (doc lines REPORTED).

### N-4 `WaitByte(n)` n vs n+1 leftovers
Rule since I011: the runner skips n passes, so `WaitByte #n` = n+1 ticks.
- `warps_interaction.asm:52` ("11 frames"), `:509` (`#0B`), `:522` (`$48`, "72 frames"), `:529` (`#48`). Correct: 12 and 73.
- `music_actors.asm:122, 125` (`#01`, "wait 1 frame" → 2).
- `item_use_system.asm:1826`.
- `future_vision_cutscene.asm:82, 136` (`#77` → 120, not 119); not yet audited, carry to I285.
- Correct model: `SpawnDebrisBurst.asm:1,16`.
The sweep covered files outside the 25 area directories. No n+1 sweep is reported for I001–I020 or I041–I050; those ranges deserve a grep pass (A09/A10). **Fix F02.**

### N-5 `body_table` and the `slider_glide` text
`body_table.asm` was fixed by I071 (row `$08` selected by `PlayerAuraTransformEntry`; only row `$03` unexplained, OQ-I061-1; VERIFIED live). Still stale: `body_table.asm:37` names the `FacingFormOffsetTable` forms "will_alt, ability_fx, …" and `slider_glide.asm` (about line 263) says "4 = Psycho Slider poses, 5 = ability poses". **Fix F03.**

### N-6 Nicknames of retired block names
- `will_alt`: `slider_glide.asm` 4, 5, 59, 256, 263, 267, 298; `cop_handlers_player_sprite.asm` 6, 33, 38, 52; `GetPlayerFacingDirection.asm` 16; `body_table.asm` 37; docs `stair-climb-system.md` (5), `docs/code/bank00/README.md` 740, `data-tables-memory.md` 250 (docs REPORTED).
- `ability_fx` / `shadow_mode`: `cop_handlers_player_sprite.asm` 6, 38. Labels: §3.3. **F03 + AP-04.**

### N-7 `scene_lifecycle` "barrier" wording
`scene_lifecycle.asm` 32, 767, 864; `docs/bank01-data-tables.md` 21, 199–209, 692; `docs/code/README.md` 241 ("Per-scene barrier/chest placement data", VERIFIED at the doc lines). The table holds chest entries only. **F04 + doc.**

### N-8 `$06F2` is the track id
`warps_interaction.asm:52`: the second `SpcTransferMusicData` uses the saved `$06F2` ("restoring the scene music"). The mnemonic `musicParentActor` (row 67 in the I001–I020 proposals: rename to `currentMusicIndex`) is a misnomer. Already answered at I013; I065 rediscovered it (P-9).

### N-9 Consistent, no action
Block names in `blocks.json` vs `extracted/tables/*`; `scene_meta.asm:23`; `SpawnDebrisBurst.asm`. `gaia-knowledge/corpus`: only `corpus/games/iog/project-docs/cop/families/sprite_anim.md` (2 hits) and one old plan under `.cursor/plans/` mention retired names. `IOGRetranslation/artifacts/file-layout.json` has 4 hits (generated; regenerate).

### N-10 `$0B22` is not a "damage flash timer" (docs only)
`docs/code/bank00/system-core.md:421` ("Damage flash — … animates **DEF display** `$0ACE` toward max `$0ACA`"), `:457` ("Damage flash timer"), `:522` ("Damage/save metadata"), `docs/code/bank00/data-tables-memory.md:381` ("Damage flash timer"). Correct per code, I035/I042/I050/I051 and `docs/wram-memory-map.md:378`: `hpToHeal`, the HP-recovery counter; `$0ACE` is current HP and `$0ACA` max HP (also `actors-player-rewards.md:58,73` says "HP bar display delta"). Three docs contradict a fourth and the code.

### N-11 Transform-adjacency hazard (live)
`db-us/transforms.json` (around lines 170–200) has a multi-line regex for the `diary_menu_window_dma` block requiring `diary_band_empty` followed directly by `diary_band_slot1`. Any note on either label changes the ROM. The same hazard applies to every multi-line transform (§6, G-6). Notes cannot detect it; only a build can.

### N-12 Orphan and bank-key quirks (REPORTED)
Orphan comment key 47052 (I021–I040), orphan `loc_03B928` (fixed). `merge` bank detection: first `code_` label rule (fixed in B001); `visual_effect_pipeline` (bank 00 code with `?BANK 0A`) needs the blocks.json rule.

### 4.4 Name propagation sweep (VERIFIED)
Grep for `spriteset_will_alt`, `spriteset_shadow_mode`, `spriteset_ability_fx`, `spriteset_will_projectile`, `spriteset_town_objects`, `spriteset_particle_fx`, `spriteset_field_fx`, `spriteset_enemies`, `direction_velocity_table`, `scene_barrier_chest_table`, `item_get_dialog_table`, `forced_walk_sequence_table`, `ability_anim_tables`, `dialogstring_01CA`: no matches in the five trees. The one intentional history hit (`functions-combat-defeat.md:256`) is narration (H-1).

---

## 5. Docs backlog (user-owned)

| Doc | Stale item | Ref |
|---|---|---|
| `docs/code/bank0D-scene-meta.md` | music group "already matches → skipped"; `$04/$05/$06` operand descriptions | N-1, N-2 |
| `docs/structs-reference.md` (362, 833, 841, 843), `docs/bank01-data-tables.md` (46, 688) | `table_018000` | N-3 |
| `docs/code/bank02/scene-script.md` | `table_018000`, opcode table | N-1, N-3 |
| `docs/bank01-data-tables.md` (21, 199–209, 692), `docs/code/README.md` (241) | "barrier" | N-7 |
| `docs/bank01-data-tables.md` (323, 326), `docs/code/README.md` | `dialog_template_table` "screen-effect presets" wording; re-verify against I065 | R-I065 |
| `docs/code/bank00/system-core.md` (421, 457, 522), `data-tables-memory.md` (381) | `$0B22` | N-10 |
| stair-climb docs, `docs/code/bank00/README.md` 740, `data-tables-memory.md` 250 | `will_alt` nickname | N-6 |
| `docs/wram-memory-map.md` | `deathFlag` documented where nothing uses it (row 54, `:170`); `gfxLoadParams` names (row 9); `collisionLayerBase` (row 8) | digest I001–I020 |
| `docs/cop/families/audio.md`, `item_use_system` text | "spawned by scene transition" (row 67) | N-8 |
| `docs/cop/families/sine_hdma.md`, `gravity.md`, `camera.md` | old operand descriptions (row 70) | digest I001–I020 |
| `gaia-core/docs/notes-and-comments.md` ("Rename propagation checklist", about 596–660) | no orphan-note sweep, no doc grep list, no plain-vs-tagged gate, no transform-adjacency warning, no `edit` entry limits | G-3, G-6 |
| `gaia-knowledge/corpus/.../cop/families/sprite_anim.md` | retired spriteset names | N-9 |
| `IOGRetranslation/artifacts/file-layout.json` | 4 retired names | regenerate |
| Retranslation modules and baserom patches | not audited; comments there are old-style | §8.5 |
| JP side (`extracted-jp`, `db-jp`) | untouched | out of scope |
The full list of doc corrections per iteration is in the "docs not edited" paragraphs of each results file (digests list the biggest ones).

---

## 6. Tooling and gate findings

### G-1 Plain vs line-tracked build (OQ-49 / OQ-I026-1)
- `extract:lt` + `rebuild`: 3,062,204, checksum 223006080, crc 2083230829 (recorded gate).
- plain `extract` + `rebuild`: 3,062,189, checksum 222967024, crc −1004081563 (REPORTED, I026).
- Cause: five multi-line regexes in `transforms.json` do not match when `; {addr}` lines intervene (`sEA_solid_arm`, `pyDD_teleporter`, `pyD7_sliding_wall`, `sFA_diary_menu`, `item_use_system`).
- Exposure: `sFA_diary_menu` (I057 rewrote its transform; the file grew from 2,084 to 2,455 lines with the new notes) and `item_use_system` (I026 renamed labels used in transforms).
- **AP-01:** decide the product mode; make the transforms tolerant (the `cop_handlers_*` regexes already carry an optional tag group) or gate both modes; run plain once for every state since I026.

### G-2 `rm -rf extracted/*` (P-10). **AP-14**: retry or fail loudly; note it in the checklist.

### G-3 No orphan check in `merge` / `names`
`names` rewrites references (name sweep VERIFIED) but nothing reports keys that match no label after manual edits. Two orphans were already found by hand. **AP-15:** `merge --check`.

### G-4 Docs are outside both tools (this is why scripts crept in, P-1). **AP-16.**

### G-5 Extractor hidden sprite groups: 1 bug (header byte 13 = count), 4 rows (§3.2). **AP-12.**

### G-6 Transform interaction with notes
- Multi-line transform regexes are not visible to `merge`. A note between required-adjacent labels breaks the ROM (N-11).
- **AP-18 (new):** list every multi-line transform (`transforms.json`), the labels it spans, and either (a) add a check to `merge` that refuses notes on those labels or (b) rewrite the regexes to allow comment lines between labels.

### G-7 `merge` `edit` entries
Added in B001 (`find`/`until`/`with`; `find` must match exactly once). Not idempotent: a re-run after the first fails; spec files that contain `edit` are single-use. State it in `notes-and-comments.md` (AP-17).

### G-8 Names spec replay
I061/I062 specs use hex addresses; I063+ use decimal integers. Replaying an old spec against the current tree is unsafe: addresses and `old` labels have moved (I063 `spriteset_freedan` note superseded by B001). Treat all specs as archives (P-3).

### G-9 `detectBank` first-label quirk (REPORTED)
Fixed in B001 for sprite maps and movable blocks; earlier notes for `visual_effect_pipeline` and the `?BANK 0A` case rely on `blocks.json`. One regression test per rule would be cheap (AP-15).

---

## 7. Quality statistics (what the audit says about the original annotations)

Source: roll-ups in I054, I060, I072 (REPORTED, counts are file tables, not re-counted).

| Range | Files | Q3 purpose F | Q2 operands F | Notes |
|---|---|---|---|---|
| I025–I054 (P2) | 91 tables | **83 (91%)**, 7 M, 1 P | not summarised | |
| I055–I060 | 18 | 14 (4 NA: sprite files without notes) | | |
| I061–I072 (P4 tables) | 36 | **35**, 1 P | **28** | 237 part notes written in I061–I072 (+36 in B001); each original error was one search away from the right answer |
| I001–I020 | 60 files | "about half" (softened in digest) | | different rubric era |

Dominant causes (each recurs in several ranges; digest I041–I072 §4):
1. Purpose guessed from a label (names like `scene_barrier`, `body_table`, `*_fx`, `dark_space`).
2. Wrong flag-bit meanings — Flags10 `$4000/$2000/$0008/$0080/$0200/$0400`, Flags12 `$0004/$1000/$0200`, `displayModeFlags $0080`, `extendedFlags $0080`; **the same bits were misread in several files by the same wrong system**.
3. Hardware misreads — `TM` bits (`---o4321`), `CGWSEL/CGADSUB`, the B-bus operand of `QueueDma` read as size or channel (I041 `#1B–#1E`, I057 `#26`, I058 `#05/#32`), `#$1001` bit 0 read as the R button (I058: raw source, no R).
4. Inverted conditions, swapped answers, direction/axis errors — gem rule (I054), pointer test (I048), menu wait (I059), continue prompt (I056), route active (I058).
5. Comment on the wrong instruction, or comments belonging to another routine (I051: all 18 old comments of `visual_effect_pipeline`).
6. Vanilla vs transformed constants: button masks (`transforms.json` remaps; notes say "B" for the interact bit, but A feeds it in this build) — see §9 H-6.
7. Extractor artefacts presented as ROM structure (§8.3).
8. `WaitByte` n vs n+1.
9. Comment-per-instruction noise (I041–I048, 1,182 removed).
10. History narration, hedges, ids in shipped text (§9).

**Implication:** for any block not yet audited, assume the notes are guesses. For every audited block, assume the notes are probably right on *what* but unproven on *when/how long* (all static).

---

## 8. Backlogs and what was overlooked

### 8.1 Mnemonic backlog (never applied)
Full row list: `renames/I001-I020_rename-proposals.md` (90 rows), `digest_I001-I020.md` (nine clearly wrong names, about 107 operand lines in 37 non-sprite files; largest: `sF0_class_dismissed` 22, `actor_execution` 13, `combat_collision` 8, `sprite_composition` 6, `sF7_credits` 6) and the Q5 columns of I021–I072.

Clearly wrong (the name contradicts the code): `deathFlag` (depth bucket array), `actorLimitThreshold` (credits timeline counter), `musicParentActor` (current track index), `sceneStateHelper` (console attribute high byte), `deathActionIdx` (event block index), `iframeCounter` (hit-stun counter), `scratch1010+6` (custom callback), `loopStartPcActor`/`loopCounterActor` (thinker slots), `playerStateByte` (high byte of `playerFlags`), `tileQueryResult` (pending tile VRAM address), `animScratch` (collision flag tables at `$7F:0000+`), `gfxCacheIdxA/B` (transition type/speed), `effectScrollH/mapScrollV/effectScrollV` (BG2 H / BG1 V / BG2 V), `climbStateData` (ability damage bonus), `invincibilityTimer` (a run window; `player_character.asm:12` itself calls the name stale), `rngState` base.
Multi-meaning mnemonics (do not rename, document or alias): `orbitAngle` / `orbitDiameter` (at least 4 meanings: angle, remaining-enemy count, fade counter, ring head, half width/height, home X/Y, start X/Y), `currentHp` (animation base), `chatPtr` (item id, animation base), `loopCounter` (speed), `layerPriorityFlag`, `globalScriptIndex` (4 meanings in `sE6_gaia`), `free101C` (knockback tier / pan steps), `cameraDeltaX/Y` (layer-1 scroll **position**; the ledger said delta until I051), `effectRenderDeltaX/Y`, `moveXAlt/moveYAlt` (index vs target position), `hpToHeal`.
Candidates to append: `$069A` (`mapDataSize`), the three strip buffers, `$06F4`, bit aliases for `displayModeFlags`.
**AP-11 / A14:** consolidate row by row into one file with a decision per row (rename, alias, leave). The 9 clear-cut ones first.

### 8.2 Dead / unreferenced code and data documented but never marked in the code
(REPORTED in the iteration that found it; not re-verified.) `DS_AuraItemRoom` cluster, `DarkSpaceAmbientParticle`, 8 hint strings (`sE6_gaia`, I056), `particle_rain_spawner` (unreferenced, I045), `camera_scroll_controller` labels `loc_00EB48/74` (I049), `reward_actors` overflow clamp (I047, dead), `shadow_shimmer` dead bit (I048), `spriteset_shadow_fx` body row `$07` never selected (I069), 3 never-selected words in `shared_word_table` (I063), unused `scene_actors` lists, 28 + 10 sprite animation indices with no caller (OQ-I063-2, OQ-I072-4/5/6), jeweler 50-jewel tier (unreachable menu, I043), `$0D5E` world-map slot (no reader, I005), `$7F` clamp in `inventory_mgmt` that only `debug_man` triggers. Policy needed: one line "Dead: …" at the head of the note, so it can be found by grep (AP-19, new).

### 8.3 Extractor artefacts that the notes had to explain away
Hidden sprite groups (G-5), `scene_actors_extract_table`, `meta_label_NN`, the forced-walk record printed as a "stair warp" struct (`scene_warps` second list: **forced-walk warps, not stairs; all 200 vertical**), handler names `SceneCmd_*` that do not match opcodes (N-1), `loc_03B928` decoded as code although it is a string, `dialogstring_03B928` after the user changed `types.json` entry 244008.

### 8.4 Generic labels
745 extracted files still contain `loc_/code_/sub_/data_/table_/func_/label_` style labels (VERIFIED by grep earlier), concentrated in the area directories (`great_wall`, `sky_garden`, `incan_ruins`, `edward_castle`, `babel_tower`, `pyramid`, `ending`, `dao`, `native_village`, `euro`, `unused`). `spm_boot_logos` and the other `spm_*` maps still carry offset names (§3.2). A13 triages these.

### 8.5 Not touched by any iteration
JP extraction/db; the `baserom/` patch sources' own comments (the audit covered `extracted/`); `IOGRetranslation` modules; the gaia-knowledge corpus refresh after docs change (`npm run ingest:all` is the user's step); `.sprite.asm` files other than the four B001 maps (45 per the plan, skipped by instruction).

### 8.6 Area directories (about 25, roughly 230 actor files) are unaudited
They contain every known pattern (n+1, narration, generic labels, wrong flag meanings). Findings from audited ranges predict a Q3 failure rate above 80% there.

### 8.7 No cross-iteration consistency check
The same constant or flag is explained differently by different iterations (the `$06F2/$06F4/$06F6` trio; `body_table` rows 3 and 8; `cameraDeltaX/Y`; the 8 sprite-header bytes). **A12:** "reconcile per mnemonic and per flag bit" with a table of every flag bit and which files explain it; it is the best defence against the cause-2 failures in §7.

### 8.8 Game-level facts that deserve a single home (REPORTED; not in any doc index)
These are discoveries the audit made that are more valuable than the comments themselves and currently exist only in results files and scattered notes:
- Jeweler (`jeweler_gem`): at 8 jewels the **text says Strength +1 but the code raises max HP**; the 50-jewel tier has no flag, so its menu is unreachable (I043).
- `inventory_mgmt`: the `$55` is a **reset at signed overflow `$7F`**, not a cap; the debug menu sets STR/DEF `$7F` (I050).
- `reward_actors`: overflow clamp is dead (I047).
- `DarkGemDropSystem`: item ids `$83–$86`, HP-tier weighted table, nine drop percentages recomputed (I049); `StandardEnemyDefeatHandler` gem condition (I054); stat table byte 3 is `gemDropType` and DEF `$7F` is not immunity (I066).
- Revive costs 100 gems (`game_over_sequence`, I053); continue prompt answers (I056).
- `hit_stagger_controller`: stun shortens to about 17 ticks; `$0400` = victim is the player (I046).
- `dialog_string_scanner` scans for opcode word `02 BF` and its pointer test is reversed; 16-bit bank counter wraps through `$FFFF` (I048).
- `scene_warps` forced-walk warps; `scene_actors` 16 scene ids share one default list, 14 lists have no player (I061).
- `system_strings`: 7 of 10 original part notes were wrong (I072).
- `Mode 7`: `M7SEL=$80` = transparent outside; `$B6` divisor increment, `$BC` rotation (I041).
**AP-20 (new):** a `docs/findings/` or a section in the relevant doc with these (user decision), each item with its evidence level.

---

## 9. Hard to understand at face value

### H-1 History narration in shipped notes
"Previously misnamed …", "the old header listed …", "formerly …". I051–I060 sanity: 18 of 30 block notes carry a "the old header said…" paragraph; `body_table.asm:7` is a live example ("The old header listed the rows as …"). Notes should state what the code does now; history belongs in git and the ledgers. **Strip during A09/A10.**

### H-2 Hedging tags
`(inferred)`, `(static reading, UNVERIFIED-RUNTIME)`, `Not traced at runtime (UNVERIFIED-RUNTIME)` (live in `body_table.asm:9`). Rule: keep a hedge only on claims that were not code-traced. Since *everything* is static (P-11), a blanket tag has no information; remove the blanket tag, keep specific uncertainty ("not traced: X").

### H-3 Ids in shipped text
`(OQ-51)`, `(R-I071-4)`, `OQ-I061-1` (live in `body_table.asm:30,37`) are unresolvable for a reader. Replace with one sentence of the unknown itself.

### H-4 Frozen ledgers read as if current
Retired names, "not applied", reversed rows (I063 vs B001), and ten falsified statements sit beside correct text. Banner per folder + Appendix A + row registry.

### H-5 Specific confusing items
- `OQ-I065-2`: "15 of the 16 … other 10" arithmetic.
- `scene_script.asm:1303` reads as the opposite of what the code does (N-2).
- Labels implying a purpose the code does not show (`musicParentActor`, `FacingData_WillAlt`, `deathFlag`).
- `scene_meta` records are `[scene id][commands][$00]` in the original ROM, `scene_meta_list` index lookups in the rebuilt one; explained only in the I065 block note.
- `heiroglyph_room` is the real directory spelling.
- `WaitByte(n)` is n+1 ticks everywhere, but opcode names read as n.

### H-6 Button vocabulary
`db-us/transforms.json` remaps button masks, so "B" in a note may mean "the interact bit, fed by A in this build" or the vanilla B. Notes of I041–I060 are not consistent. **Policy needed:** name the bit (`$0080`) or the mnemonic, then say which physical button in this build. Check `player_character.asm`, `sF*` menus, `diary_menu`.

### H-7 Same word, different thing
"slot" (actor slot vs thinker slot vs palette slot vs VRAM slot), "group" (music room group, sprite header group, hidden group, drop group), "frame" (animation frame vs ticks vs NMI frame; `WaitByte`), "state" (playerFlags bits vs `climbStateData`). A glossary of five lines in `notes-and-comments.md` would remove a lot of reader friction.

---

## 10. Open-question triage (for the later pass)

Registry = A12. From what this pass touched:
- **Answerable statically now:** OQ-I065-3 (answered in I009/I013, N-8); OQ-49 / OQ-I026-1 (cause known, decision pending); the four hidden-group questions (same bug); the `table_018000` questions (done I065); OQ-I061-1 for body row `$03` is open.
- **Needs Mesen2:** timing in frames, visuals, "when does this fire" (most `UNVERIFIED-RUNTIME` rows), the I056 `CrystalBallAutoUse` rebuild error (OQ-I056-9) and sprite indices passed by variable (OQ-I063-2, OQ-I072-4/5/6).
- **Duplicates:** hidden-group rows; the `$06F2` question.
- **Wording to fix first:** OQ-I065-2.
- **Reachability questions** (is code X ever executed?) need an "xref complete?" check: all callers found by `rg` of `SetMetasprite ( @… )` and operand tally would miss indices passed through variables (digest I041–I072 §6).

---

## 11. Prioritised action plan

Type: **M** notes via `merge`; **N** names via `names`; **U** user-owned file; **T** tool change; **P** process; **A** further audit iteration.

### Priority 1 — correctness
| ID | Action | Type | Ref |
|---|---|---|---|
| AP-01 | Decide the product build mode; make the five multi-line transforms tolerant or gate both; run plain mode over the post-I026 state | U + T | G-1 |
| AP-02 | `scene_script.asm`: opcode table, four part notes, `SpcMusicLoadCmd` comment, block-note sentence, `table_018000` (F01) | M | N-1, N-2, N-3 |
| AP-03 | n+1: `warps_interaction` ×4, `music_actors` ×2, `item_use_system` ×1, `future_vision_cutscene` ×2 later; grep sweep for I001–I020 and I041–I050 (F02) | M + A | N-4 |
| AP-04 | Nickname drift (`slider_glide`, `cop_handlers_player_sprite`, `GetPlayerFacingDirection`, `body_table:37`); rename `FacingData_WillAlt` / `FacingData_AbilityFx` (F03) | M + N | N-5, N-6, §3.3 |
| AP-05 | `scene_lifecycle` barrier wording (F04) | M | N-7 |
| AP-06 | Docs list (§5), incl. `$0B22` (N-10) | U | §5 |
| AP-07 | Sanity-style passes for I061–I072 + B001 (A06–A08) | A | P-5 |
| AP-18 | Transform inventory and `merge` guard (or loosen regexes) | T | G-6 |
| AP-21 | Rename the 9–16 clearly wrong mnemonics (zero byte change; run both gates) | U + N | §8.1 |

### Priority 2 — integrity and traceability
| ID | Action | Type | Ref |
|---|---|---|---|
| AP-08 | Policy for narration, hedges, ids, buttons, glossary (H-1…H-3, H-6, H-7); strip during sweeps | P + M | §9 |
| AP-09 | Commit `plans/`; review script-made doc diffs; delete `temp/`; inspect `artifacts/*` | P | P-1, P-2 |
| AP-10 | Row-status registry; question registry; Appendix A next to the checklist | A + P | P-4, P-6, P-7 |
| AP-11 | Consolidate and decide every mnemonic/struct/copdef row | U | §8.1 |
| AP-12 | One extractor fix for hidden sprite groups; gate | T | G-5 |
| AP-13 | Generic-label triage for audited ranges (A13) | A | §8.4 |
| AP-19 | "Dead:" marker line in notes of dead code; apply to the §8.2 list | M | §8.2 |
| AP-20 | A single home for the game-level facts (§8.8) | U / P | §8.8 |
| AP-22 | Reconcile the ten falsified ledger statements (add errata to ledger folder README, do not edit frozen ledgers) | P | digest I041–I072 §3 |

### Priority 3 — tooling hygiene
| ID | Action | Type | Ref |
|---|---|---|---|
| AP-14 | `extract:lt` `rm -rf` retry/fail loudly | T | G-2 |
| AP-15 | Orphan-note check; regression tests for `detectBank` rules | T | G-3, G-9 |
| AP-16 | Doc-edit capability or agreed manual doc policy | T / P | G-4 |
| AP-17 | Update `notes-and-comments.md`: orphan sweep, doc grep list, both-mode gate, `edit` limits, transform-adjacency, spec replay | U | G-6…G-8, §5 |
| AP-23 | Investigate OQ-I056-9 (`CrystalBallAutoUse` rewrite error after `extract:lt`) | T | P-10 |

### Fix specs
F01–F06 as in `PLAN.md`. Each: dry-run, merge, `npm run extract:lt`, `npm run rebuild`, and (after AP-01) the plain-mode gate.

---

## 12. Recommendation for I073 and later
- **Do not start I073 before AP-01, AP-18 and AP-07.** The gate does not cover the shipped build, and notes next to transforms can break it silently.
- Re-batch by scene directory (the area directories are repetitive and share flags/helpers); cross-file facts are then checked once per scene.
- Replace per-iteration `questions/` files by one registry; add a 10-line sanity step (the §7 defect classes) before closing an iteration.
- For the area audits, start from the §7 defect-class checklist and from `digest_*` "misleading names" tables rather than from the extracted comments, which are likely wrong.
- Try again to get Mesen2 evidence (a ROM + state for this build) for the top-10 behavioural claims (§8.8): a few E5 confirmations would raise confidence in the whole static record.

---

## Appendix A — retired → current names
(R) = rests on ledgers, not re-checked in `blocks.json` this pass.

| Retired | Current |
|---|---|
| `table_018000` | `display_preset_table` |
| `scene_barrier_chest_table` / `table_01ADA8` | `scene_chest_table` |
| `item_component_table` / `itemcomp_table_01EB0F` | `shared_word_table` |
| `direction_velocity_table` | `walk_step_table` (struct still `direction-velocity`) |
| `ability_anim_tables` | `ability_damage_tables` (R) |
| `item_get_dialog_table` / `itemget_table_01FD24` | `item_pickup_text_table` |
| `forced_walk_sequence_table` | `forced_walk_pan_table` |
| `consolestring_01D9D8` and boot strings | `boot_title_strings` |
| item menu table | `item_name_line_table` |
| `spriteset_will_alt` | `spriteset_will_abilities` |
| `spriteset_ability_fx` | `spriteset_transform_poses` (R) |
| `spriteset_shadow_mode` | shadow aura body spriteset (R; I067 renames) |
| `spriteset_will_projectile`, `spriteset_town_objects`, `spriteset_particle_fx`, `spriteset_field_fx`, `spriteset_enemies` | renamed I063–I067 (R) |
| `SpawnHitSparkSprites` | `SpawnItemSparkleEffect` |
| `floor_button` | `hit_switch` |
| `DarkGemDropSystem` | enemy drop system (R; history at `functions-combat-defeat.md:256`) |

## Appendix B — evidence index
- `extracted/system/engine/scene_script.asm`: 15–24, 75, 1294–1304.
- `extracted/tables/scene_meta.asm:23`; `extracted/tables/body_table.asm:1–37`.
- `extracted/system/engine/scene_lifecycle.asm:93, 789, 912`.
- `extracted/gold_ship/**/gs2D_lily.asm:98`, `gs2E_sleep.asm:4,30,64`, `gs2C_crow_crew.asm:71`.
- `extracted/system/engine/warps_interaction.asm:52, 509, 522, 529`; `music_actors.asm:122, 125`; `item_use_system.asm:1826`; `future_vision_cutscene.asm:82, 136`; `SpawnDebrisBurst.asm:1, 16`.
- `db-us/blocks.json:1003–1042`; `db-us/names/bank03.json:473–476`; `db-us/transforms.json` ≈170–200.
- `docs/wram-memory-map.md:378`; `docs/code/bank00/system-core.md:421, 457, 522`; `docs/code/bank00/data-tables-memory.md:381`; `docs/code/bank00/actors-player-rewards.md:58, 73`.
- `docs/bank01-data-tables.md:21, 692`; `docs/code/README.md:241`; `docs/code/bank00/functions-combat-defeat.md:256`.
- `git log` (HEAD `694ddb2`), `git status` (`?? plans/`), `temp/` listing (54 entries).
- Ledger sources: results I001–I072, B001; apply summaries; sanity checks I001–I060.
