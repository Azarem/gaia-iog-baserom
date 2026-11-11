# A05 findings — iterations I051..I060

Step A05 of the audit of the audit (`PLAN.md`). Scope: the results, renames, questions and edits of I051..I060, `renames/apply-I051-I060_summary.md`, `I051-I060_sanity-check.md` and `renames/sanity-I051-I060_renames.md`. Read first: `PLAN.md`, `report.md` (v2, AP-01..AP-23), `digest_I041-I072.md` (I051..I060 sections). `gaia-core/docs/notes-and-comments.md` was not needed (no edits in this step).

**Evidence rules.** Tags: **VERIFIED** = checked in the live files this session (file:line given). **REPORTED** = taken from a ledger, a doc or the digest and not re-checked here. No Mesen2 ROM or state exists, so every behavioural claim below is static (E1 code trace, E2 cross-reference, E3 docs). Nothing was run on the emulator (E5 is empty).

**Live tree.** `extracted/` is the plain build (no `; {n}` tags), so its line numbers are not the "after" counts quoted in the ledgers (G-1, `report.md:44`). All `file:line` below are the live plain tree unless stated.

**Process disclosure.** Reading used Grep, Glob and Read plus `rg` (counts and `-o` extracts). The first part of the step (before a context reset) also used read-only shell helpers for listing and sizing files and wrote a one-line temp list of the 30 file names outside the repo. No script was written to read, edit or analyse names, notes, comments, `blocks.json`, `files.json` or docs. `git status` shows nothing changed by this step except this file and the A05 row of `PLAN.md`. No sub-agent was used. No git history command was run.

---

## 1. Scope and files read

**Ledgers read (frozen, not edited):**
`renames/I051..I060_renames.md`, `renames/apply-I051-I060_summary.md`, `renames/sanity-I051-I060_renames.md`, `questions/I051..I060_questions.md`, `results/I051..I060_results.md` (Q5 lines and rows), `I051-I060_sanity-check.md`, `mesen2-question-inventory.md`, `mesen2-investigation-plan.md`, `audit-of-audit/report.md`, `audit-of-audit/PLAN.md`, `audit-of-audit/A04_findings.md` (format), `digest_I041-I072.md`.
Not read: `edits/*.json`, `renames/apply-I051-I060_map.json` (the rows were checked against the live tree instead).

**Live files read (30 audited files plus the files they depend on):**

| Iter | Audited file(s) | Read |
|---|---|---|
| I051 | `extracted/actors/field_reveal_object.asm`, `layer1_scroll_actors.asm`, `boss_clear_reward_handler.asm`, `interaction_handlers.asm` (gem mask only), `functions/SpawnFieldRevealEffect.asm` | yes |
| I052 | `functions/StandardEnemyDefeatHandler.asm`, `EscortFollowPathTracker.asm`, `actors/player_transition_handlers.asm` | yes |
| I053 | `system/dark_space/sE6_gaia.asm`, `actors/dark_space.asm`, `functions/game_over_sequence.asm` | yes |
| I054 | `actors/boot_logo_enix_palette_obj0/1/2.asm` | yes |
| I055 | `system/boot_logos/sFB_boot_logo.asm`, `spm_boot_logos.sprite.asm`, `baserom/boot-logo/spm_boot_logos.sprite.asm` | yes |
| I056 | `system/title_screen/sFC_title_intro.asm`, `sFC_title_start_handler.asm` | yes |
| I057 | `system/diary_menu/sFA_diary_menu.asm`, `diary_menu_window_dma.asm` | yes |
| I058 | `system/world_map/WorldMapSplitEffect.asm` | yes |
| I059 | `system/world_map/WorldMapController.asm` | yes |
| I060 | `system/world_map/world_map_options.asm`, `world_map_route_table.asm`, `spm_overworld_sprites.sprite.asm`, `palette_bundles` (bank 16 names) | yes |

**Dependencies read:** `system/engine/cop_handlers_input.asm`, `cop_handlers_script_control.asm`, `cop_handlers_wait.asm`, `cop_handlers_effects.asm`, `scene_lifecycle.asm`, `camera_scroll.asm`; `db-us/transforms.json`, `db-us/mnemonics.json`, `db-us/names/bank00/08/0B/16.json`, `db-us/blocks.json`, `db-us/files.json`; `notes/comments/bank03.json`, `notes/partNotes/bank00.json`, `notes/partNotes/bank03.json`, `notes/blockNotes/bank00.json`, `notes/blockNotes/bank03.json`; `docs/code/bank03/radar-and-world-map.md`, `docs/cop/families/wait.md`; `baserom/patches/APUWaitFixes.patch.asm`, `baserom/fixes-tweaks/Utils.patch.asm`.

---

## 2. Per-row status

Status values: APPLIED (live names/text carry the change), PARTIAL (some of the row's sub-items live), PROPOSED (still in the ledger only), SUPERSEDED (replaced by a later row/decision), DROPPED (rejected). Every APPLIED/PARTIAL row was checked in the live tree (`db-us/names/*.json` and the extracted labels) unless marked REPORTED.

### 2.1 Rename rows (59 rows)

| Row | Status | Note |
|---|---|---|
| R-I051-1 | APPLIED | |
| R-I051-2 | PROPOSED | |
| R-I051-3 | APPLIED | |
| R-I051-4 | APPLIED | |
| R-I051-5 | PROPOSED | |
| R-I052-1 | APPLIED | |
| R-I052-2 | PARTIAL | two of the sub-names applied, the third kept as is (apply summary) |
| R-I052-3 | PROPOSED | |
| R-I052-4 | APPLIED | display names only partly checked (§10) |
| R-I052-5 | APPLIED | |
| R-I052-6 | PROPOSED | |
| R-I053-1 | APPLIED | |
| R-I053-2 | APPLIED | display names only partly checked (§10) |
| R-I053-3 | APPLIED | |
| R-I053-4 | APPLIED | display names only partly checked (§10) |
| R-I053-5 | PROPOSED | |
| R-I053-6 | APPLIED | |
| R-I053-7 | APPLIED | doc rows; REPORTED |
| R-I054-1 | APPLIED | `BootLogoEnixObj0/1/2Entry` in `bank00.json:341-345` |
| R-I054-2 | PROPOSED | |
| R-I054-3 | APPLIED | doc rows; REPORTED |
| R-I054-4 | SUPERSEDED | by R-I055-1 (user decision: one palette cycle) |
| R-I055-1 | APPLIED | applied with a deviation from the row text (user decision) |
| R-I055-2 | APPLIED | applied with a deviation from the row text |
| R-I055-3 | APPLIED | `Utils.patch.asm:75-76` already uses `BootLogoPalLockout!` / `BootLogoNtsc`, so the patch sweep worked |
| R-I055-4 | PROPOSED | still PROPOSED for the baserom copy of the spritemap (§10) |
| R-I055-5 | SUPERSEDED | by the B001 sprite-map merge fix |
| R-I055-6 | APPLIED | |
| R-I056-1 | APPLIED | |
| R-I056-2 | APPLIED | |
| R-I056-3 | APPLIED | |
| R-I056-4 | PROPOSED | |
| R-I056-5 | PROPOSED | |
| R-I056-6 | PROPOSED | |
| R-I056-7 | APPLIED | spelling mix "Ankor Wat" / "Angkor Wat" (A05-12) |
| R-I056-8 | PROPOSED | **blocked, and its evidence is wrong** (A05-03) |
| R-I056-9 | APPLIED | |
| R-I057-1 | PROPOSED | |
| R-I057-2 | PARTIAL | |
| R-I057-3 | APPLIED | |
| R-I057-4 | PROPOSED | |
| R-I057-5 | APPLIED | |
| R-I057-6 | APPLIED | doc rows; REPORTED |
| R-I057-7 | APPLIED | |
| R-I058-1 | PARTIAL | (a), (d) live; (b) dropped by decision; (c) still proposed |
| R-I058-2 | PROPOSED | |
| R-I058-3 | APPLIED | doc rows; REPORTED |
| R-I059-1 | APPLIED | |
| R-I059-2 | APPLIED | |
| R-I059-3 | PROPOSED | `$0D6E` / `$0D6C` / `$0D6F` / `$0D60` still raw in `WorldMapController.asm` (A05-06) |
| R-I059-4 | PARTIAL | |
| R-I059-5 | APPLIED | doc rows; REPORTED |
| R-I060-1 | APPLIED | |
| R-I060-2 | APPLIED | |
| R-I060-3 | APPLIED | |
| R-I060-4 | APPLIED | the shipped text cites the row id four times (A05-05) |
| R-I060-5 | PARTIAL | `worldMapChoiceId`, `worldMapRouteId`, `worldMapRouteReturnPtr` exist live in `mnemonics.json` (lines 201-206 area); `worldMapPartyArray` does not. The apply summary still says "not applied": stale (A05-09) |
| R-I060-6 | PARTIAL | (a) applied; (b) types and (c) tooling not applied |
| R-I060-7 | APPLIED | doc rows; REPORTED |

**Totals (59 rows):** APPLIED 35, PARTIAL 6, PROPOSED 16, SUPERSEDED 2, DROPPED 0.

**Sanity rows (`renames/sanity-I051-I060_renames.md`, 4 rows):**

| Row | Status | Evidence |
|---|---|---|
| D-S5160-1 | APPLIED | live note `world_map_options.asm:723` says the blank row is `[TPL:11]`; ledger text still wrong (frozen) — VERIFIED |
| D-S5160-2 | APPLIED | orphan note key `loc_03B928` is gone from `notes/`, `db-us/`, `extracted/`, `docs/`, `baserom/` (0 hits) — VERIFIED |
| D-S5160-3 | APPLIED | `world_map_route_table.asm:11-16` states the n + 1 rule; the table is called `move_chain_table` live (`WorldMapController.asm:430`, the sanity row says `movement_delta_table`) — VERIFIED |
| D-S5160-4 | APPLIED | `docs/cop/families/wait.md:9,16` say operand N waits N + 1 ticks — VERIFIED; the three other docs REPORTED |

### 2.2 Q5 rows (30 rows, one per audited file)

Q5 = "does the file still carry an unresolved mismatch between a note and the code?" Re-checked here against the live notes for the 9 rows whose files were read in full. Result: 28 NA, 2 M (I057 `sFA_diary_menu`, I059 `WorldMapController`), unchanged from the ledgers. Two of the NA rows hold a defect this step found, so NA is too generous for them: `WorldMapController` (M already) and `sE6_gaia` (NA, but `:30` carries the false "no reference" claim, A05-03).

---

## 3. Open questions (OQ) — answered later?

64 OQ ids were raised in I051..I060 (`questions/I051..I060_questions.md`). All 64 are registered in `mesen2-question-inventory.md`. None is cited by any I061..I072 ledger. "Answered later" = a later ledger or iteration settled it.

| Iter | Ids | Answered later? | Remarks |
|---|---|---|---|
| I051 | OQ-I051-1 | no | static-answerable now: `cop_handlers_wait.asm` keeps the wait entry in `$00` and resumes there (E1) |
| | OQ-I051-2..7 | no | `forcedScrollOverride` readers: only stores and a MVN save copy found (`scene_lifecycle.asm:805`, `inventory_overlay.asm:176`, `camera_scroll.asm:65`), consistent with "no reader" (E1, partial) |
| I052 | OQ-I052-1..6, 9 | no | |
| | OQ-I052-7 | no | the shipped note already states "carry set and A >= 4" for an unknown facing (`EscortFollowPathTracker.asm:17`); REPORTED against the engine code |
| | OQ-I052-8 | no | first half answered in the file: ring entry 9 is unreachable under `AND #$003F`-style masking — VERIFIED; the reason for the seed 4 is open |
| I053 | OQ-I053-1..7 | no | |
| I054 | OQ-I054-1 | **yes, I055** | VERIFIED in `boot_logo_enix_palette_obj0.asm:19` and `obj1.asm:8`; the inventory still lists it as open (A05-08) |
| | OQ-I054-2..5 | no | |
| I055 | OQ-I055-4 | **yes, B001** | VERIFIED text at `spm_boot_logos.sprite.asm:18-19` (two collision boxes); the four readers REPORTED (A06); inventory still lists it open (A05-08) |
| | OQ-I055-1 | no | partly settled by the sprite tables; still cited in notes |
| | OQ-I055-2, 3, 5 | no | |
| I056 | OQ-I056-1..8 | no | |
| | OQ-I056-9 | no | tracked as AP-23 (`CrystalBallAutoUse` error); G-1 explains the numbers part only |
| I057 | OQ-I057-1..6 | no | OQ-I057-5 (`_noref` palette fade step) stays open |
| I058 | OQ-I058-1, 2 | no | |
| I059 | OQ-I059-1..8 | no | OQ-I059-1, 4 and 6 repeat the wrong "44-tick" zoom-out (A05-01) |
| I060 | OQ-I060-1..5 | no | OQ-I060-2: the engine applies n + 1 deltas (static half VERIFIED); OQ-I060-3: staged id is masked by `AND #$001F` (`WorldMapController.asm:121`, VERIFIED) |
| | OQ-I060-6 | no | the shipped text already asserts "padding" (A05-11) |

**Counts:** answered later 2 (OQ-I054-1, OQ-I055-4). Settled in shipped text or by static reading but not by a later ledger: 5 (OQ-I052-7, OQ-I052-8 first half, OQ-I060-2 half, OQ-I060-3 half, OQ-I060-6 asserted). Still open: 57. This step does not answer OQs; the static-answerable ones are listed for the owning step.

---

## 4. Re-verified facts (26 sampled, 25 files)

| # | Fact (ledger / note claim) | Live check | Result |
|---|---|---|---|
| 1 | `sE6_gaia` AbilitySceneTable maps the scene byte to an ability form | `sE6_gaia.asm` ~1340-1385, table bytes and lookup | CORRECT |
| 2 | Continue-prompt answers (save / continue / don't record) | `sE6_gaia.asm` ~680-765, answer indexes and branch targets | CORRECT |
| 3 | `DS_AuraItemRoom` cluster has "no reference in `extracted/`, `baserom/` or `db-us/`" | `baserom/patches/APUWaitFixes.patch.asm:392` (`AuraItemGrant! {`), `:396` (`COP [D4] ( #24, &AuraItemInventoryFull )`), `:416` (`COP [19] ( #17, @dialogstring_08EFEF )`) | **WRONG** for `baserom/` (A05-03); true for `extracted/` |
| 4 | `sFA_diary_menu` state table order is STR then DEF | `sFA_diary_menu.asm` ~897-920 and ~1792-1872; `mnemonics.json` `playerStr` / `playerDef` | CORRECT |
| 5 | `sFA_diary_menu` SRAM checksum arithmetic | `sFA_diary_menu.asm` ~2216-2258 against `save_system.asm` | CORRECT |
| 6 | `COP [BranchIfPressed] ( #$1001, &TitleToDiaryTransition )`: bit 0 selects `joypadRaw`, `$1000` = Start | `sFC_title_start_handler.asm:46`; `cop_handlers_input.asm:85-113` (`BIT #$0001` then `BNE` to `BIT $joypadRaw`) | CORRECT |
| 7 | `LDA #$FFFC` + `TSB $joypadMaskStd` leaves Select and Start unmasked | `sFC_title_start_handler.asm:26,39` | CORRECT |
| 8 | `WaitWord #$021B` = 540 ticks | `sFC_title_start_handler.asm`; `cop_handlers_wait.asm` (n + 1 rule, 0x21B + 1 = 540) | CORRECT |
| 9 | `WorldMapSplitEffect`: `#05` = BGMODE `$2105`, `#32` = COLDATA `$2132`, `#26` = WH0/WH1, templates and offsets, `InitSplitFill` writes 76 words | full read of `WorldMapSplitEffect.asm` (`CPY #$0098` = 152 bytes = 76 words) | CORRECT |
| 10 | `LDA $0036` in `WorldMapSplitEffect.asm:94` is the frame parity counter | AGENTS.md DP table (`$36`) | CORRECT (raw operand, A05-06) |
| 11 | Zoom-out is **44 ticks** | `WorldMapController.asm:~150-171`: `LoopStart ( #2C )` around a body that ends in `SetEntryHereAndYield` then `LoopEnd`; `cop_handlers_script_control.asm:52-60` (yields), `:260-285` (non-final `LoopEnd` restores the head and returns with RTL) | **WRONG**: two yields per pass, about 88 ticks (A05-01) |
| 12 | `InitGravity ( #20, #05, #00 )` plus `TickGravity` over 44 passes ends at `$34` (sum about -972) | `cop_handlers_effects.asm:228-311` (t is incremented before use; `((t*(t>>1))>>f) - v0`) | CORRECT (the pass count is 44, not the tick count) |
| 13 | Tilt phase is 93 ticks | `WorldMapController.asm` tilt loop, `docs/code/bank03/radar-and-world-map.md:202` | CORRECT |
| 14 | `WaitByte #0F` = 16 ticks and `WaitByte #3B` = 60 ticks | `WorldMapController.asm`; n + 1 rule | CORRECT |
| 15 | Route-step comments (`SetEntryHere` "yields", "Z movement", byte 2/3/4) | `WorldMapController.asm:425,428,432,439,446,450` against `cop_handlers_script_control.asm:36-47` | **WRONG / stale** (A05-02) |
| 16 | `world_map_options` part notes `$1C-$26`: `WorldMapMenu_Empty1C..25`, `WorldMapMenu_Nothing26`, "never staged" | `world_map_options.asm:13,34,67`; `WorldMapController.asm:121` (`AND #$001F`) | content CORRECT, reachability imprecise (A05-07) |
| 17 | `dialogstring_03B928` is not referenced | 0 hits for `03B928` outside its definition in `extracted/`, `baserom/`, `db-us/`, `notes/` | CORRECT |
| 18 | Route step n means n + 1 deltas | `world_map_route_table.asm:11-16`; `WorldMapController.asm` `RouteCountTick` | CORRECT |
| 19 | `SpawnFieldRevealEffect` 5-tick delay | `SpawnFieldRevealEffect.asm:13,86,100` | CORRECT |
| 20 | Gem decision in `StandardEnemyDefeatHandler`, collect mask `$0031` | `StandardEnemyDefeatHandler.asm:6-15,87-106`; `interaction_handlers.asm:34-40` | CORRECT |
| 21 | `EscortFollowPathTracker` 8-entry ring and facing table | `EscortFollowPathTracker.asm:9-17,87,114,151,175,183` | CORRECT |
| 22 | `game_over_sequence` wait timings | `game_over_sequence.asm` waits against n + 1 | CORRECT |
| 23 | `sFB_boot_logo` TM values `$10` / `$04` and first-phase timings | `sFB_boot_logo.asm:5,29,46-59,94,104` (TM bits `---o4321`) | CORRECT |
| 24 | `sFC_title_intro` idle wait `WaitWord $09D3` = 2516 ticks, "about 42 seconds" | `sFC_title_intro.asm` | CORRECT |
| 25 | `spm_boot_logos`: 85 groups, B001 header text; `spm_overworld_sprites`: 14 animations, 48 groups | `spm_boot_logos.sprite.asm`, `spm_overworld_sprites.sprite.asm` (group counts by `rg -c`) | CORRECT |
| 26 | `sE6_gaia` wait operands (for example `WaitByte #59`) and the `$FFFC` mask sites | `sE6_gaia.asm` | CORRECT |

**Result:** 22 CORRECT, 3 WRONG (#3, #11, #15), 1 correct-but-imprecise (#16). 25 distinct files checked (≥ 8 required).

---

## 5. Findings

Class numbers are `PLAN.md` classes 1-13; "P" = a process finding outside the 13 classes.

| id | tag | file:line | what is wrong | proposed fix | class | F-step |
|---|---|---|---|---|---|---|
| A05-01 | VERIFIED | `WorldMapController.asm:37,39,150,163-164,170-171`; `notes/comments/bank03.json:315-316,333-334`; `notes/partNotes/bank03.json:11,300`; `notes/blockNotes/bank03.json:27`; `docs/code/bank03/radar-and-world-map.md:164` and the phase table near `:202` | The zoom-out is called "44 ticks". The loop is 44 passes, but each pass runs `SetEntryHereAndYield` and then a non-final `LoopEnd`, which yields again: 2 ticks per pass, about 88 ticks. The `$B8` arithmetic (sum about -972, final `$34`) is right because it counts passes. The wrong figure is also in the I059 OQs (OQ-I059-1, 4, 6) | Say "44 passes, 2 ticks per pass, about 88 ticks"; keep the `$34` arithmetic. Fix extracted text through `merge` and the doc line by hand-in-spec. Mesen2 can confirm the 88 | 2, 6 | F02 (+ F05 for the doc) |
| A05-02 | VERIFIED | `WorldMapController.asm:425,428,432,439,446,450` | Stale or wrong inline comments: `:425` and `:450` say `SetEntryHere` yields a frame per tick, but `SetEntryHere` does not yield (`cop_handlers_script_control.asm:36-47`); the yield is the RTL at about `:501`. `:432/:439/:446` number the route bytes 2/3/4 while `world_map_route_table.asm:11-16` numbers them differently (byte 3 = tick count n): two numbering schemes in one feature; `:439` says "Z movement", which does not match the route-table note's description of that index (not re-derived from the table consumers here) | Rewrite the comments once, using one byte numbering that matches the route-table block note; re-derive the third index meaning from `RouteDeltaTables` first | 3, 6 | F07 |
| A05-03 | VERIFIED | `sE6_gaia.asm:30,519-530,1441-1545`; `baserom/patches/APUWaitFixes.patch.asm:392,396,416` | R-I056-8 and the sE6_gaia notes say the `DS_AuraItemRoom` cluster (`AuraItemInventoryFull`, `dialogstring_08EFEF`) has no reference in `extracted/`, `baserom/` or `db-us/`. The baserom patch rewrites `AuraItemGrant!` and references both labels. Removing or renaming the cluster as "dead" would orphan the patch rewrite. The cluster is unreachable from extracted code only; the patch can reach it | Replace "no reference anywhere" by "no reference in extracted code; `APUWaitFixes.patch.asm` rewrites `AuraItemGrant` and uses these labels". Use the AP-19 "Dead:" marker only after the patch is checked. R-I056-8 stays blocked; ask the user how the patch should be treated | 1, 11 | F07 (+ user decision) |
| A05-04 | VERIFIED | 17 of the 30 files (`sFB_boot_logo`, `sE6_gaia` 3 lines, `dark_space`, `world_map_options`, `world_map_route_table`, `layer1_scroll_actors`, `interaction_handlers`, `SpawnFieldRevealEffect`, `StandardEnemyDefeatHandler`, `field_reveal_object`, `game_over_sequence`, `EscortFollowPathTracker`, `player_transition_handlers`, `boss_clear_reward_handler`, `boot_logo_enix_palette_obj0/1/2`; 1 line each unless stated) | History narration is still in the shipped text ("old header", "header said", "was called", "previously", "formerly" style). Re-count this session with a fixed narrow pattern: 19 lines in 17 files. The sanity check counted 18 of 30 block notes (REPORTED); the two counts agree, so no clean-up has happened since. Same text sits in `notes/blockNotes/`, `notes/partNotes/` and `notes/comments/` | Strip narration through one `merge` spec per file group (dry-run first); keep the current facts only | 4 | F07 (notes JSON counts: A09/A10) |
| A05-05 | VERIFIED | 19 of the 30 files (`player_transition_handlers.asm` 9 lines, `WorldMapController.asm` 5, `layer1_scroll_actors.asm` 5, `sFA_diary_menu.asm` 4, `palette_bundles.asm` 4, `field_reveal_object.asm` 4, two lines each in `sFB_boot_logo`, `sE6_gaia`, `dark_space`, `world_map_options`, `boss_clear_reward_handler`; one line each in the other 8); `world_map_options.asm:723`; `sFA_diary_menu.asm:2058` | Ledger ids in shipped text: 49 lines in 19 files match `OQ-*` / `R-*` ids (for example `(R-I060-3)`, `(R-I060-4)` four times, `(renames ledger R-I057-4)`; `OQ-B001` appears in `spm_overworld_sprites.sprite.asm`, and also in `spm_darkspace_sprites.sprite.asm`, outside this range). Iteration ids such as `I054` / `I055` also appear in prose. The ids point into frozen ledgers that are not shipped | Remove the ids; keep the fact, and where a question is still open write "not checked" in words (AP-xx wording) | 7 | F07 (`spm_darkspace_sprites`: A08) |
| A05-06 | VERIFIED | `WorldMapController.asm` (49 lines with `$00B6/B8/BC/CA/CC/DA`, `$0D6C/6E/6F/60`), `sFA_diary_menu.asm` (136 lines), `diary_menu_window_dma.asm` (11), `world_map_options.asm` (5), `WorldMapSplitEffect.asm:94` (`$0036`) | Unnamed fixed-address operands. R-I059-3 and R-I060-5 are the intended fix, and three of the four R-I060-5 mnemonics already exist (`mnemonics.json:201-206`) but the controller still prints the raw words; `worldMapPartyArray` (`$0D60`) is missing. The Mode 7 words `$B6/$B8/$BC/$CA/$CC` and the `sFA` remap words have no mnemonics | Add the missing mnemonics (extend `db-us/mnemonics.json`, then extract); R-I059-3 can then be applied | 9 | F06 |
| A05-07 | VERIFIED | `world_map_options.asm:13,34,67`; `WorldMapController.asm:121` | The notes say `$1C-$26` are "never staged". The controller masks the staged id with `AND #$001F`, so `$20-$26` cannot be staged at all, and `$26` would run menu `$06`. `WorldMapMenu_Empty20..25` and `WorldMapMenu_Nothing26` are therefore not "empty menus never chosen" but entries that no staged id can reach | Reword: ids `$1C-$1F` are unused but reachable by a stage; `$20-$26` are unreachable because of the mask | 11 | F07 |
| A05-08 | VERIFIED | `mesen2-question-inventory.md` (rows for OQ-I054-1 and OQ-I055-4); `mesen2-investigation-plan.md` | Registry is stale: both ids are answered (I055 and B001) but still listed as open for Mesen2 | Mark both as answered in the next registry rewrite (new file; ledgers are frozen) | P | A12 |
| A05-09 | VERIFIED | `renames/apply-I051-I060_summary.md` (R-I060-4, R-I060-5) | The apply summary says R-I060-5 was not applied, but three of its four mnemonics exist live. R-I060-4 is listed as applied while four notes still cite its id | Correct the status in the new registry file, not in the frozen summary | P | A12 |
| A05-10 | VERIFIED | `sFB_boot_logo.asm` notes on `BootLogoPalLockout`; `baserom/fixes-tweaks/Utils.patch.asm:75-76` | The notes describe the PAL lockout screen of the vanilla game. The shipped baserom patches `BootLogoPalLockout!` to `BRA BootLogoNtsc`, so a PAL console takes the NTSC path (static reading of the patch). The note does not say so | Add one sentence: the baserom skips the lockout (`Utils.patch.asm`). Confirm with Mesen2 on a PAL region run | 3, 11 | F07 |
| A05-11 | VERIFIED | `palette_bundles.asm` (padding notes near `:10105-10260`, ids R-I060-4) | The notes state that the empty one-byte bundles are "padding", but OQ-I060-6 (are they padding?) is open and the only evidence is "nothing references them" (E1) | Hedge ("nothing references them") or settle OQ-I060-6 by a static byte comparison | 1 | F07 |
| A05-12 | VERIFIED | `world_map_options.asm:13,23,29,52-53,464,481,577,595,1000,1015` (mixed "Ankor Wat" / "Angkor Wat"; labels use `AngkorWat`); `diary_entry_table.asm:404,411,414`; `world_map_scene_names.asm:125` | Spelling mix inside one feature. The in-game strings say "Ankor Wat" (`dialogstring_03B753`, `spritestring_03B3AF`), the labels and some notes say "Angkor Wat" | Use "Ankor Wat" for quoted game text and one spelling for prose; decide the label spelling once | 3, 10 | F07 (label decision: F06) |
| A05-13 | VERIFIED | `world_map_options.asm:38,40` against `world_map_route_table.asm:11` | `:38,40` say "a tick count n" and "n ticks per step" while the route-table note says n + 1; both are consistent only if read carefully | Use the n + 1 wording in both places | 2 | F02 |
| A05-14 | VERIFIED | `StandardEnemyDefeatHandler.asm:6,7,66`; `layer1_scroll_actors.asm:44` | Wait operands quoted without a tick count ("WaitByte 2/5", "WaitByte 1"), so the reader cannot tell n from n + 1 | Quote operand and ticks ("WaitByte #05, 6 ticks") | 2 | F02 |
| A05-15 | VERIFIED | `temp/apply-rename-I051-I060.mjs`, `temp/mkspec-I051-I060.mjs`, `temp/mkmap-I051-I060.mjs`, `temp/edits-I051-I060.mjs` (also `temp/apply-rename-I041-I050.mjs`, `temp/edits-I041-I050.json`, `temp/docedit.mjs`, `temp/docs1..14.mjs`, `temp/fix-routenote.mjs`) | **Process rule broken.** Throwaway `.mjs` scripts exist (untracked) for I051..I060: `apply-rename-I051-I060.mjs` reads `db-us/names/*.json` and applies renames; `edits-I051-I060.mjs` holds the note edit list. `no-adhoc-scripts.mdc` forbids exactly this. Whether the live names and notes came from them or from `names` / `merge` could not be established here (not run, only read the first lines) | Do not run them. Ask the user whether to delete them or to extend `names` / `merge` (the rule's remedy). Record the answer in the F-step | P | T-step (user decision) |
| A05-16 | REPORTED | `spm_*.sprite.asm` (hidden sprite groups, class 8) | Hidden-group extraction (a group count byte larger than the visible groups) cannot be checked without the ROM bytes. The group counts in the three spm files match their headers (85 in `spm_boot_logos`, 14 animations / 48 groups in `spm_overworld_sprites`) | Leave to A08 and the Mesen2 / byte check | 8 | A08 |

---

## 6. WaitByte / LoopEnd sweep (class 2)

Rule used: `WaitByte(n)` / `WaitWord(n)` wait n + 1 ticks (`cop_handlers_wait.asm`, `docs/cop/families/wait.md:9`). A non-final `LoopEnd` yields; `SetEntryHereAndYield` yields; `SetEntryHere` does not.

| File | Result |
|---|---|
| `WorldMapController.asm` | 44-pass zoom-out is 88 ticks (A05-01); 16-tick and 60-tick waits correct; tilt phase 93 correct |
| `sFC_title_start_handler.asm` | `WaitWord #$021B` = 540 ticks correct |
| `sFC_title_intro.asm` | `$09D3` = 2516 ticks, "about 42 s" correct |
| `sFB_boot_logo.asm`, `sE6_gaia.asm`, `game_over_sequence.asm` | all quoted tick counts follow n + 1 |
| `SpawnFieldRevealEffect.asm` | 5 ticks correct |
| `StandardEnemyDefeatHandler.asm`, `layer1_scroll_actors.asm` | operands quoted without ticks (A05-14) |
| `world_map_options.asm`, `world_map_route_table.asm` | n vs n + 1 wording mixed (A05-13) |

No wrong n vs n + 1 count other than A05-01 was found in the 30 files.

---

## 7. Narration and id counts (task 5)

- **Narration, block notes:** the sanity check counted 18 of 30 (REPORTED). This session's fixed narrow pattern (`old header|header said|was called|used to be|formerly|previously|renamed from|I05n/I060 left|noted|called|said`) finds 19 lines in 17 of the 30 files (VERIFIED). A wider pattern used earlier in this step gave 33 lines in 20 files, but that pattern was not kept, so only the narrow count is a checked figure. The sanity-check figure and the narrow count agree closely: no clean-up has happened.
- **Ledger ids (class 7):** pattern `\b(OQ|R)-(Innn|Bnnn|n)(-n)?\b` finds 49 lines in 19 of the 30 files (VERIFIED, per-file figures in A05-05); iteration ids `I054` / `I055` also occur in prose (`boot_logo_enix_palette_obj0/1/2.asm`).
- **Retired nicknames (class 10):** none remain as labels in `db-us/`, `us/`, `baserom/` or `src/` (0 hits for the old `boot_logo_palette_*`, `HdmaWindow*`, `PlayerItemRevealSpawn`, `PlayerFreedanReveal*`, `visual_effect_pipeline`, `world_map_names` names). Some remain as prose in the extracted files (`rg -c` this session: `WorldMapSplitEffect.asm` 1 line, `layer1_scroll_actors.asm` 1, `player_transition_handlers.asm` 2, `boot_logo_enix_palette_obj0/1/2.asm` 1 each).

---

## 8. Defect-class sweep (PLAN.md classes 1-13)

| Class | Result in I051..I060 |
|---|---|
| 1 purpose guessed from label | A05-03, A05-11 |
| 2 WaitByte n vs n + 1 | A05-01, A05-13, A05-14 |
| 3 stale comment after rename | A05-02, A05-10, A05-12 |
| 4 history narration | A05-04 |
| 5 opcode table of another row | none found in the 30 files |
| 6 comment contradicts code | A05-01, A05-02 |
| 7 OQ / R ids in text | A05-05 |
| 8 hidden sprite groups as sub-sprites | A05-16 (not checkable here) |
| 9 unnamed fixed-address operands | A05-06 |
| 10 retired nickname in names | none as labels; prose only (§7) |
| 11 wrong flag / hardware / branch meaning | A05-03, A05-07, A05-10 |
| 12 transform adjacency | safe in all 9 blocks (§9) |
| 13 button vocabulary | no violation: `field_reveal_object.asm:14` "L / R" matches mask `$0031` on `joypadRaw`; `sFA_diary_menu.asm:33,2058` keep raw (physical) and remapped bits apart |

---

## 9. Transform-adjacency inventory (task 4)

`db-us/transforms.json` rules touching the A05 blocks (lines 113, 179-184, 203-205, 236, 383, 505-520, 538-549):

| Block | Rule shape | Needs adjacent | State |
|---|---|---|---|
| `sE6_gaia` | `LDA #$FFF0([^\r\n]*\s+T[SR]B $joypadMaskStd)` → `$FFFC` (21 sites) | `LDA` then `TSB` / `TRB` on the next line; a trailing comment on the LDA line is tolerated | SAFE: no note sits between them, no `$FFF0` left in the live text |
| `sFC_title_start_handler` | same shape, sites at `:26`, `:39` | same | SAFE |
| `player_transition_handlers`, `field_reveal_object`, `boss_clear_reward_handler`, `interaction_handlers`, `layer1_scroll_actors` | same shape (mask widening) | same | SAFE |
| `sFA_diary_menu` | `diary_menu_window_dma` rule and stub-strip rules (505-520) | `diary_band_empty [ ]` and `diary_band_slot1 [...]` adjacent; the five-instruction remap sequences adjacent | SAFE: `diary_menu_window_dma.asm:144` (`diary_band_slot1`) and `:150` (`diary_band_empty`) are in the order the rule needs, no note between them. In the plain tree the stubs are stripped; under `extract:lt` the multi-line stub rules do not apply (`sFA_diary_menu.asm:34`, G-1), and the note says so |

No inline note in the 9 blocks breaks a multi-line rule. The hazard stays AP-18: a new note between these instructions would silently skip the transform. A guard check is the T-step.

---

## 10. Not verified / needs Mesen2

- All runtime behaviour: tick counts (the 88-tick zoom-out, the 93-tick tilt, boot-logo and title timings), visual results, PAL path through `BootLogoPalLockout` (A05-10). No Mesen2 ROM or state exists.
- `baserom/boot-logo/spm_boot_logos.sprite.asm`: the first sprite group matches the extracted copy, but the file uses an older spelling (`sprite_group <`, `sprite_set_list_*`). Whether `rebuild` consumes it, and whether it is the shipped spritemap, was not established (R-I055-4 stays PROPOSED).
- Docs not re-read: R-I053-7, R-I054-3, R-I055-6, R-I056-9, R-I057-6, R-I058-3, R-I059-5 and R-I060-7 (only the `radar-and-world-map.md:164,202` lines were read).
- R-I052-4, R-I053-2 and R-I053-4 display names: only partly checked against the live strings.
- The `$B6` value at the end of the tilt phase: approximated only.
- `edits/*.json` and `apply-I051-I060_map.json`: not read.
- Whether the `temp/*.mjs` scripts were run to produce the live names and notes (A05-15).
- Hidden sprite groups (class 8) in the `spm_*` files: needs a byte check.

---

## 11. Items for the fix specs (F-step ids)

| F-step | Items from A05 |
|---|---|
| F02 (timing wording) | A05-01 (44 passes, 88 ticks), A05-13, A05-14 |
| F05 (docs) | `radar-and-world-map.md:164` and the phase table near `:202` (A05-01) |
| F06 (names / mnemonics) | A05-06 (missing mnemonics, R-I059-3), A05-12 label spelling |
| F07 (batch note clean-up) | A05-02, A05-03, A05-04, A05-05, A05-07, A05-10, A05-11, A05-12 |
| A08 | A05-16 |
| A12 (registry rewrite) | A05-08, A05-09 |
| T-steps | AP-18 guard (§9); A05-15 (user decision on `temp/*.mjs`) |
| User decision | R-I056-8 (blocked: the patch references the cluster), A05-15 |

---

## 12. Counts

| Item | Count |
|---|---|
| Rename rows | 59: APPLIED 35, PARTIAL 6, PROPOSED 16, SUPERSEDED 2, DROPPED 0 |
| Sanity rows | 4 (all APPLIED) |
| Q5 rows | 30: NA 28, M 2 (two NA rows hide a defect) |
| OQ ids | 64: answered later 2, settled in shipped text 5, open 57 |
| Facts re-verified | 26 (22 correct, 3 wrong, 1 imprecise) across 25 files |
| Findings | 16: VERIFIED 15, REPORTED 1 |
| Narration | sanity check 18 of 30 block notes (REPORTED); re-count 19 lines in 17 of 30 files (VERIFIED, narrow pattern) |
| Ledger ids in shipped text | 49 lines in 19 of 30 files (VERIFIED) |
| Transform adjacency | 9 blocks, 0 hazards |
| Edits made | 0 (this file and the A05 row of `PLAN.md` only) |
