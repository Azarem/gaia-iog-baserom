# A09 findings: notes JSON sweep, banks 00–01

Step: A09 (audit of the audit). Read-only. No notes, names, comments, docs, `blocks.json`, `transforms.json` or `src/` file was edited. This file is the only new file (plus the single `PLAN.md` status row).

Evidence is static (E1 code trace in the live `extracted/` tree, E2 cross-reference, E3 docs). There is no Mesen2 ROM or save state, so no behavioural claim here is runtime-verified.

Tags: **VERIFIED** = checked in the live files this pass (file:line given). **REPORTED** = taken from a ledger or a pattern hit that I did not read in full.

Defect classes are the numbers in `PLAN.md` ("Defect classes to check"): 2 WaitByte n+1, 3 stale after a rename or move, 4 history narration, 7 OQ / R ids in text, 10 retired nickname, 12 transform adjacency, 13 button vocabulary. The hedge sweep has no class number in `PLAN.md`; I write "H" for it (closest class: 1).

---

## 1. Scope and files read

### Files in scope

| File | Keys | Notes |
|---|---:|---|
| `notes/blockNotes/bank00.json` | 140 | keyed by file name without `.asm` / `.sprite` |
| `notes/blockNotes/bank01.json` | 20 | |
| `notes/partNotes/bank00.json` | 835 | keyed by label |
| `notes/partNotes/bank01.json` | 157 | |
| `notes/comments/bank00.json` | 3380 | keyed by decimal ROM address |
| `notes/comments/bank01.json` | – | **does not exist** (the prompt lists it; `ls notes/comments` shows `bank00.json`, `bank02.json`, `bank03.json`, …) |

Each note is one JSON line, so `rg -c` counts notes. The JSON files were searched with `rg` and only the hits were opened (no whole-file read).

### Other files read for evidence

`PLAN.md`, `report.md` (v2: §4 N-1…N-12, §9 H-1…H-7, Appendix A, AP-01…AP-23), `gaia-core/docs/notes-and-comments.md` (Notes, Merge, bank detection, adjacency paragraph), `src/merge.ts` (lines 245–250 and 360–372), `src/notes-common.ts` (`resolveAsmPath`, line 239), `db-us/transforms.json` (whole), `db-us/blocks.json` (searched), `extracted/system/engine/cop_handlers_wait.asm`, `actor_execution.asm` (`DEC $08`), `smooth_follow.asm`, `combat_collision.asm`, `system_core.asm`, `cop_handlers_script_control.asm`, `cop_handlers_dialog.asm`, `thinkers/oneshot_palette_flash_18.asm`, `babel_tower/babel_light_elevator/babel_elevator_color_add.asm`, `actors/hit_switch.asm`, `actors/town_door.asm`, `functions/camera_drift.asm`, `functions/npc_wander_ai.asm`, `functions/ApplyPlayerHitstun.asm`, `system/diary_menu/diary_menu_window_dma.asm`, and the three `mountain_temple` mushroom-drop-gate files.

### Method note (read this before the pattern lists)

No script was written. Orphan keys were found with `rg` pipelines that read a pattern list from stdin (`-f -`). In the current engine a commented line carries **both** the `; {n}` tag and the comment text, for example `extracted/thinkers/oneshot_palette_flash_18.asm:16`:

```
    COP [PaletteStart] ( #18 ) ; {47054} Start bundle #18 (32-frame COLDATA strip) and yield
```

So a comment key is orphaned exactly when no `; {key}` tag exists anywhere in `extracted/`. The doc claim "commented lines carry no tag" (`gaia-core/docs/notes-and-comments.md`, the line-tracking paragraph) is outdated (AP-17; see A09-26).

`extracted/` had no tags when I started, so I ran the allowed `npm run extract:lt`. **Side effect:** 818 tracked files under `extracted/` now differ from `HEAD` (tags only; `git diff --stat` shows 74458 insertions and 74457 deletions). `artifacts/*` were already modified before this step. `npm run extract` (plain) would restore the untagged tree, but it is not on this step's allowed command list, so I did not run it. Run it yourself before committing, or leave the tagged tree if you want it.

Shell hygiene disclosure: besides `rg` I used `ls`, `sed -n 'Np'`, `sort`, `uniq`, `tr`, `head` and `for` loops to format or loop over `rg` output. They only displayed information. Nothing was edited with them.

---

## 2. Sweep log: exact patterns and match counts

`F` below means the five files above (`notes/blockNotes/bank00.json bank01.json notes/partNotes/bank00.json bank01.json notes/comments/bank00.json`).

### Sweep 1: orphan keys (exhaustive, not sampled)

The prompt asked for at least 40 sampled keys per file plus every Appendix A name. Every key was checked.

| Check | Command (shape) | Keys checked | Orphans |
|---|---|---:|---:|
| part notes, bank 00 | `rg --no-ignore --no-filename -o '^\s*([A-Za-z0-9_]+)\s*(\{\|\[\|#\|\`\|~\|\\\|\|:)' -r '    "$1": ' extracted \| rg -v -F -f - -n notes/partNotes/bank00.json` | 835 | **0** (only the lines `1:{` and `837:}` remain) |
| part notes, bank 01 | same, `bank01.json` | 157 | **0** (only `1:{`, `159:}`) |
| comments, bank 00 | `rg --no-ignore --no-filename -o '; \{([0-9]+)\}' -r '"$1": ' extracted \| rg -v -F -f - -n notes/comments/bank00.json` | 3380 | **53** (55 output lines, 2 are the `{` / `}` lines) |
| block notes, bank 00 | `rg --files extracted \| rg -o '([A-Za-z0-9_]+?)(\.sprite)?\.asm' -r '    "$1": ' \| rg -v -F -f - -n notes/blockNotes/bank00.json` | 140 | **6** |
| block notes, bank 01 | same, `bank01.json` | 20 | **0** |
| duplicate keys across banks | bank00/01 part, block and comment keys against every other `notes/*/bankNN.json` (`rg -F -f -`) | all | **0** (sanity: the bank01 pattern list matches itself 157 times) |
| Appendix A names as **keys** | `rg -n -o '^    "[^"]*(<all Appendix A names>)[^"]*": '` over the four block / part files | – | **0** |
| Appendix A names as **labels** in `extracted/` | `rg --no-ignore -n '^\s*(<names>)\w*\s*([{\[#`~\|]\|:)' extracted` | – | **0** |
| `cop_handlers_(flags\|flow\|lifecycle\|map\|solid\|spatial)` mentioned in notes outside their own orphan notes | `rg -n -o '.{0,60}cop_handlers_(flags\|flow\|lifecycle\|map\|solid\|spatial)\b.{0,60}'` over `F` | – | only inside the orphan notes themselves (`blockNotes/bank00.json:31`, `:32`); also `baserom/scene-load/Cop51Decompress.patch.asm` (1 hit, outside notes) |

Dead transform keys (`db-us/transforms.json`, VERIFIED): `cop_handlers_lifecycle` (:46), `cop_handlers_solid` (:58), `cop_handlers_spatial` (:70), `cop_handlers_map` (:76) name blocks that no longer exist in `db-us/blocks.json` or `extracted/`. Count: **4**.

### Sweep 2: history narration

| Pattern | Case | blockNotes 00 | blockNotes 01 | partNotes 00 | partNotes 01 | comments 00 |
|---|---|---:|---:|---:|---:|---:|
| spec: `previously\|formerly\|the old header\|was named\|was misnamed\|until I0` | `-i`, occurrences | 25 | 3 | 0 | 0 | 0 |
| same, notes (lines) | `-i -c` | 22 | 3 | 0 | 0 | 0 |
| extra P2b: `[Tt]he old \|[Ee]arlier notes?\b\|[Oo]ld (header\|note\|notes\|comment\|comments\|label\|labels\|name\|names\|text\|description\|docs?)\b\|[Ee]arlier (note\|comment)\|WHAT WAS WRONG\|=== CORRECTIONS ===` occurrences | | 75 | 18 | 10 | 1 | 2 |
| same, notes not already in the spec set | | 19 | 11 | 10 | 1 | 2 |
| extra P3: `older (header\|note\|comment\|name)\|used to (be\|say\|read\|call)\|no longer\|originally (named\|called\|said\|labelled)\|renamed from\|corrected (from\|to)\|was wrongly\|wrongly (named\|called\|labelled)\|misread\|mislabel\|the original (header\|note\|comment\|label\|name)` (`-i`) | | 3 | 0 | 0 | 0 | 1 |

Token detail for the spec pattern: `the old header` 26, `formerly` 2 (`blockNotes/bank00.json:58`, `:88`), the other three alternatives 0. I opened the context of all 28 spec hits: all 28 are real narration (none is a false positive).

Section headers: `=== CORRECTIONS ===` at `blockNotes/bank00.json:10, 11, 12, 82, 130, 136` (6) and `WHAT WAS WRONG` at `blockNotes/bank01.json:20` (1). Total 7.

The spec pattern misses `older header` / `older name` (4 hits: A09-08). The P2b hits in part notes and block notes were not read one by one (A09-11 is REPORTED).

### Sweep 3: id citations

Spec pattern `OQ-|R-I|D-S|\(R-`:

| File | Notes with a hit | Tokens |
|---|---:|---:|
| `blockNotes/bank00.json` | 38 | 50 |
| `blockNotes/bank01.json` | 9 | 13 |
| `partNotes/bank00.json` | 17 | 19 |
| `partNotes/bank01.json` | 6 | 7 |
| `comments/bank00.json` | 29 | 29 |
| **Total** | **99** | **118** |

Of the 118 tokens, 35 are legacy `OQ-<n>` (`rg -o 'OQ-[0-9]+\b'`: OQ-60 ×6, OQ-67 ×4, OQ-57 ×4, OQ-68 ×3, OQ-65 ×3, OQ-61, OQ-54, OQ-53 ×2 each, …) and 83 are iteration-prefixed `OQ-I0nn-m`. `R-I`, `D-S` and `(R-` have **0** hits. Broader pattern `OQ-[A-Za-z0-9-]+|\bR-[A-Z]?[0-9]+[A-Za-z0-9-]*|\bI[0-9]{3}\b`: 121 tokens in the same 99 notes, because three bare iteration numbers appear (`partNotes/bank00.json:200` "answered in I021", `blockNotes/bank00.json:10` and `:11` "I054 left…", "The I054 note…").

### Sweep 4: hedges

Pattern `UNVERIFIED-RUNTIME|\(inferred\)|not traced at runtime`: occurrences (case-sensitive) 11 + 2 + 2 = 15; notes (line count, `-i`) = **14** (blockNotes 00: 7, blockNotes 01: 5, partNotes 01: 1, comments 00: 1, partNotes 00: 0). Variants such as "inferred reason" (`extracted/system/engine/cop_handlers_dialog.asm:143`, comment 43295) are not matched by the pattern.

### Sweep 5: WaitByte / WaitWord n versus n+1

| Pattern | blockNotes 00 | partNotes 00 | comments 00 | other files |
|---|---:|---:|---:|---:|
| `WaitByte.*frame` (case-sensitive, notes) | 8 | 7 | 2 | 0 |
| `wait .* frames` (`-i`, notes) | 3 | 3 | 2 | 0 |
| `WaitWord` (`-i -o`, notes mentioning it) | 2 (`:32`, `:55`) | 2 (`:826`, `:828`) | 0 | 0 |

I also searched the comment file with `rg -n -i 'frames?\b'` filtered by `wait|hold|delay|pause|countdown|stall` and read the code behind the candidates (`hit_switch.asm`, `camera_drift.asm`, `npc_wander_ai.asm`, `cop_handlers_script_control.asm`, `town_door.asm`, `ramps.asm`). After reading every hit: **4 wrong-count groups** (A09-16…A09-19), plus correct wording that must be left alone (`comments` 51643 and 59675, `blockNotes/cop_handlers_wait`, `blockNotes/SpawnDebrisBurst`). The rule (VERIFIED): `RunActors` decrements `$08` once per tick and resumes the actor when the result is negative, so a stored N waits N+1 ticks, for both `COP [WaitByte]` / `[WaitWord]` and a direct `STA $08` (`extracted/system/engine/cop_handlers_wait.asm`, `actor_execution.asm` `DEC $08`).

### Sweep 6: retired nicknames

| Pattern | Occurrences in `F` |
|---|---:|
| `will_alt` | 12 |
| `ability_fx` | 4 |
| `shadow_mode` | 2 |
| `table_018000` | 0 |
| `barrier` | 6 (5 legitimate: door barriers, `pyD6_vader_barrier_*` names, `ability_damage_aura_barrier`; 1 history, A09-10) |
| every Appendix A retired name (22 names, the exact list in report Appendix A) | 2 (`blockNotes/bank00.json:72` `DarkGemDropSystem`, `:88` `floor_button`), both inside history sentences |

Current names for comparison: `spriteset_will_abilities` and `spriteset_transform_poses` exist as labels in `extracted/`; `spriteset_will_alt` / `spriteset_ability_fx` do not.

### Sweep 7: button vocabulary

Pattern `\b[ABXY]( |-)button` (`-i`): 7 lines: `partNotes/bank01.json:29`, `partNotes/bank00.json:822`, `comments/bank00.json:34` (key 33009), `comments:2045` (key 49098), `blockNotes/bank00.json:35`, `:84`, `:140`.

Reference (VERIFIED against `db-us/transforms.json` and the extracted code): vanilla layout B `$8000`, Y `$4000`, Select `$2000`, Start `$1000`, D-pad `$0F00`, A `$0080`, X `$0040`, L `$0020`, R `$0010`. This build: `transforms.json` rewrites the `$8000` tests to `$0080` in `player_character` (:193), `combat_collision` (:495), `actor_execution` (:498) and `slider_glide` (:508); `system_init` (:754) sets remapA `$8080`, remapB `$4008`, remapY `$0040`, remapX `$0004`; the `$xFF0` mask constants become `$xFFC`.

### Sweep 8: transform adjacency

Multi-line regexes in `db-us/transforms.json` that bank 00–01 notes could break:

| Regex | Spans | Notes on spanned labels | Result |
|---|---|---|---|
| COP triple `(?<!STA \$02\s+)LDA \$0A\s+(;[^\r\n]+)?\s+STA \$00\s+(;[^\r\n]+)?\s+STA \$02, S` | three consecutive instructions inside one block; no label can sit between them; tolerates an inline comment or a `; {n}` tag on the first two lines | none possible | **no hazard** (VERIFIED) |
| diary `(diary_band_empty\s\[\s*\])[\s]*(diary_band_slot1\s\[[^\]]*\])` (`:181`) | the labels `diary_band_empty` and `diary_band_slot1` | **none**: `rg -n '^\s+"diary_band_\w+": ' notes/partNotes` lists only `diary_band_slot2`, `slot3`, `tab_empty`, `tab0`..`tab3` (`partNotes/bank00.json:164-170`); the block note itself documents the rule (`extracted/system/diary_menu/diary_menu_window_dma.asm:8`) | **no hazard** (VERIFIED). After the transform, `diary_band_slot1` precedes `diary_band_empty` in `extracted` (`:150`) |
| joypad pair `LDA #\$XFF0([^\r\n]*\s+T[SR]B \$joypadMaskStd)` | an `LDA` and the following `TSB` / `TRB` | the check "any non-instruction line between `LDA #$..FC / ..F0` and `TSB/TRB $joypadMaskStd`" returned **no match** (exit 1); 161 pairs are transformed and adjacent | **no hazard** (VERIFIED) |
| sEA_solid_arm, pyDD_teleporter, pyD7_sliding_wall, sFA_diary_menu, scene_meta display-mode, item_use_system, pyDA_lithograph | blocks outside banks 00–01 notes | not in A09's scope | hand to A10 / A15 |

Not a hazard, but found: three files have the vanilla `LDA #$EFF0` + `TSB/TRB $joypadMaskStd` pairs untransformed and no `transforms.json` key: `mountain_temple/kress_crossroads/mtA2_mushroom_drop_gate.asm` (:18–19, :40–41), `kress_circuit/mtA5_mushroom_drop_gate_b.asm` (:17–18, :48–49), `kress_circuit/mtA5_mushroom_drop_gate_a.asm` (:18–19, :40–41). Outside A09's scope: A09-25.

---

## 3. Findings

### 3.1 Orphan keys (class 3)

| ID | Tag | Where | What is wrong | Proposed fix | Class |
|---|---|---|---|---|---|
| A09-01 | VERIFIED | `comments/bank00.json:3171-3281`, 29 keys: 59593, 59622, 59627, 59630, 59651, 59671, 59677, 59686, 59708, 59722, 59856, 59863, 59904, 59966, 59983, 59994, 60000, 60009, 60035, 60045, 60148, 60169, 60195, 60215, 60229, 60236, 60258, 60273, 60294 | No `; {n}` tag exists at any of these addresses. The texts describe the smooth-follow angle / step / direction algorithm (`orbitAngle`, `orbitDiameter`, `UnsignedDivide`, `chatPtr`, `FollowSlopeDitherTable`), which now sits at `ComputeFollowAngle` (60840) and `ComputeFollowStep` (60956) in `extracted/system/engine/smooth_follow.asm`: these are comments keyed to an old address layout. They use stale operand names (class 3). None of the 29 carries an OQ id (the id-bearing comment keys in A09-12 do not overlap this list). | Prune the 29 keys. Before pruning, compare each text with the comment on the instruction at the new address and re-key any fact that the current comment lacks (use `merge` with the new address). | 3 |
| A09-02 | VERIFIED | `comments/bank00.json`: 34145 (:120), 34181 (:121), 46991 (:1790), 47052 (:1791), 48664 (:2027), 49851 (:2099), 52569 (:2355), 52887/52891/52895/52899/52903/52907 (:2397-2402), 53033 (:2415), 53352 (:2453): 15 keys | The addresses are data bytes or actor / thinker header bytes, where the extractor prints no instruction and so no tag (for example 47052 is the two-byte thinker header; the first instruction is `COP [PaletteStart]` at 47054). Comments on data cannot be shown. Per key: 47052 is subsumed by the current comments at 47054–47059; 46991 is the CGADSUB comment for `STA $CGADSUB`, which sits at **46999** (`babel_elevator_color_add.asm:19`) and has no comment there, so that text is **lost** until it is re-keyed; 52887–52907 are data-table entry notes (the table block note / part note should carry them); 52569, 53033, 49851, 48664 describe whole actors whose block notes already say it. | Re-key 46991 → 46999 with `merge` (add the comment first), then prune all 15 orphans. For 52887–52907, check that `statue_inventory_reward` / its part notes carry the entry facts before pruning. | 3 |
| A09-03 | VERIFIED | `comments/bank00.json`: 50105 (:2141), 52676 (:2367), 52692 (:2369), 52728 (:2374), 52877 (:2395), 53048 (:2419), 53086 (:2424), 53105 (:2429), 62455 (:3367): 9 keys | Addresses fall inside an instruction (off by 1–3 bytes), so no tag. Some have a newer duplicate at the right address (50105 → 50112 `Player $10 \|= $0080` exists, `ApplyPlayerHitstun.asm:72`; 52692, 53048, 53105 have neighbours that say the same). Others lost text: 53086 (`JMP InventoryStatueSlotClaimed`, tag 53085, no comment), 52728 ("Music wait countdown: $00B4 (180) frames"), 62455. | For each key decide re-key (text missing at the corrected address) or prune (duplicate), then prune the orphan. Do not re-key blindly: the F-step must read each instruction. | 3 |
| A09-04 | VERIFIED | `blockNotes/bank00.json:31 cop_handlers_flags`, `:32 cop_handlers_flow`, `:37 cop_handlers_lifecycle`, `:39 cop_handlers_map`, `:49 cop_handlers_solid`, `:50 cop_handlers_spatial` | Six block-note keys name `.asm` files that do not exist (`extracted/system/engine/` has `cop_handlers_*` files for the split handlers, none with these names; `blocks.json` has no such blocks). Their text describes handler groups that other notes now cover (for example `:31` points readers to `cop_handlers_flow`, which does not exist). | Prune the six keys; first check that each fact has a home in the successor block notes (`cop_handlers_script_control`, `_inventory`, `_actor_death`, `_world_map`, `_metatile`, `_collision`, `_hdma_dma`, `_movement`, …). | 3 |
| A09-05 | VERIFIED | `db-us/transforms.json:46, 58, 70, 76` | Four transform keys (`cop_handlers_lifecycle`, `_solid`, `_spatial`, `_map`) target blocks that no longer exist, so they can never fire. Related inert keys with zero multi-line COP triples: `cop_handlers_audio` (:16), `_palette` (:22), `_spawn` (:40), `actor_pool` (:52). | `transforms.json` is user-owned: list for T01 / A15, do not edit here. | 12 |
| A09-06 | VERIFIED | `src/merge.ts:245-247` and `:366-370` | `merge` cannot remove an orphan. Comment keys: the address tag must exist in the target `.asm` (`comment {n}: address tag not found`) even when the value is `null`. Block-note keys: the target `.asm` must exist (`file does not exist`, line 247). So A09-01…A09-04 (59 comment keys + 6 block-note keys) cannot be pruned with the allowed tools. This is AP-15 / T03 (`merge --check` and a prune path). | Do not hand-edit the JSON and do not script it. Extend `src/merge.ts` (T03) with an orphan-prune path, document it in `notes-and-comments.md`, then run the prune F-step. | 3 |

### 3.2 History narration (class 4) and retired names (class 10)

| ID | Tag | Where | What is wrong | Proposed fix | Class |
|---|---|---|---|---|---|
| A09-07 | VERIFIED | `blockNotes/bank00.json` (22 notes): `ApplyOrbitalOffsetFromRef` :5, `ApplyOrbitalOffsetXY` :6, `ApplyPlayerHitstun` :7, `boot_logo_enix_palette_obj0` :10, `_obj1` :11, `_obj2` :12, `boss_clear_reward_handler` :13, `DamageNumberShort_unused` :58, `EscortFollowPathTracker` :73, `field_reveal_object` :75, `game_over_sequence` :82, `global_ambient_dispatcher` :84, `hit_switch` :88, `interaction_handlers` :90, `layer1_scroll_actors` :96, `overworld_exit` :111, `player_transition_handlers` :118, `SetPlayerIdleFacing` :124, `smooth_follow_child` :130, `SpawnFieldRevealEffect` :133, `StandardEnemyDefeatHandler` :136, `town_door` :140. `blockNotes/bank01.json` (3): `body_table` :3, `move_chain_table` :14, `walk_step_table` :21 | Each states a rebuttal of a prior header ("The old header said …", "formerly named …"). 25 notes, 28 occurrences. The reader of the shipped note needs the current facts only. | Rewrite each note with `merge` (one `find` / `replace` or a whole `blockNote`), keep the current facts and drop the "old header" sentence and the `=== CORRECTIONS ===` framing (A09-09). | 4 |
| A09-08 | VERIFIED | `blockNotes/bank00.json`: `large_ramps` :95, `oneshot_coldata_r11g4b2` :106, `SpawnDebrisBurst` :132; `comments/bank00.json:2250` (key 50938, "the older header called it a frame counter") | `older header` / `older name` narration, not caught by the spec pattern. | Same fix as A09-07; add `older (header\|name\|note)` to the sweep pattern in the next step prompts. | 4 |
| A09-09 | VERIFIED | `blockNotes/bank00.json`: `boot_logo_enix_palette_obj0` :10, `_obj1` :11, `_obj2` :12, `game_over_sequence` :82, `smooth_follow_child` :130, `StandardEnemyDefeatHandler` :136; `blockNotes/bank01.json`: `system_strings` :20 ("WHAT WAS WRONG") | Seven `=== CORRECTIONS ===` / `WHAT WAS WRONG` sections that are change logs, not descriptions. | Remove the headers and keep the facts they carry in the description. | 4 |
| A09-10 | VERIFIED | `blockNotes/bank00.json`: `boot_logo_enix_palette_obj1` :11 (old name `boot_logo_palette_quintet`), `_obj2` :12 (`boot_logo_palette_third`), `DamageNumberShort_unused` :58 (`AttackTrailShort_unused`), `EnemyDropSystem` :72 (`DarkGemDropSystem`, `SpawnDarkGemType1`), `gold_ship_wreck_palette` :85 (`incan_ruins_transform_palette`), `hit_switch` :88 (`floor_button`), `SpawnDamageNumberEffect` :131 (`SpawnAttackTrailEffect`); `blockNotes/bank01.json:17 scene_chest_table` ("The old note ('barrier/chest placement', 'event-blocking barrier …')") | Retired names preserved in shipped text, always inside a history sentence. Only two (`DarkGemDropSystem`, `floor_button`) are in Appendix A; the rest are older renames found by reading. 8 notes. | Remove with A09-07. The retired names then survive only in the ledgers, which is where they belong. | 4, 10 |
| A09-11 | REPORTED | `blockNotes/bank00.json`: `camera_drift` :14, `camera_scroll_controller` :16, `EnemyDeathFlash` :71, `EnemyDropSystem` :72, `flag_gated_palette_cool` :76, `_warm` :77, `gold_ship_wreck_palette` :85, `hit_stagger_controller` :87, `inventory_bg3_scroll_hdma` :91, `npc_wander_ai` :101, `oneshot_coldata_warm_flash` :107, `oneshot_palette_flash_18` :108, `ramps` :119, `scene_flag_init` :122, `sine_hdma_slow_wave` :127, `slider_glide` :128, `SpawnDamageNumberEffect` :131, `SpawnItemSparkleEffect` :134, `StopPlayerOnDeath` :138; `blockNotes/bank01.json`: `ability_damage_tables` :2, `dialog_dictionaries` :4, `dialog_template_table` :5, `display_preset_table` :6, `enemy_clear_reward_table` :7, `enemy_stats_table` :8, `forced_walk_pan_table` :10, `item_pickup_text_table` :12, `scene_chest_table` :17, `scene_warps` :18, `system_strings` :20; `partNotes/bank00.json`: `EnemyGemDropRouter` :186, `GlobalAmbientAnimFacingHorizontal` :280, `GlobalAmbientFacingValid` :284, `GlobalAmbientOnInteractPress` :289, `GlobalAmbientProbeDown/Left/Right/Up` :295-298, `HitStaggerReleasePlayer` :315, `StatueRewardNotThisStatue` :779; `partNotes/bank01.json`: `item_name_table` :83 | Pattern P2b (`The old …`, `old note/comment/label/name/text/description/docs`, `earlier note`) hit these notes that the spec pattern does not (19 + 11 block notes, 10 + 1 part notes). I read the context of the spec hits only; the P2b hits are candidates. Comments 48002 and 58030 also matched and are false positives (they use "old" for game data). | Read each hit in the F-step, strip real narration, leave game-logic uses of "old". | 4 |

### 3.3 Id citations (class 7)

| ID | Tag | Where | What is wrong | Proposed fix | Class |
|---|---|---|---|---|---|
| A09-12 | VERIFIED | 99 notes, 118 `OQ-` tokens (35 legacy, 83 iteration-prefixed); lists below. | Note text carries ledger ids that mean nothing to a reader of the shipped asm (`OQ-I051-3`, `OQ-60`, `I054`). The ids belong in the open-question registry (A12), not in notes. | Strip the id token, keep the sentence ("not known" / "reader not found") and, where the fact is a genuine open question, say so in plain words. The F-step needs the A12 registry to decide which sentences stay. | 7 |

Keys carrying ids:
- `blockNotes/bank00.json` (38): `actor_pool` :2, `ApplyPlayerHitstun` :7, `boot_logo_enix_palette_obj0` :10, `_obj1` :11, `boss_clear_reward_handler` :13, `camera_drift` :14, `camera_scroll` :15, `camera_scroll_controller` :16, `cop_handlers_audio` :24, `cop_handlers_dungeon_switch` :29, `cop_handlers_movement` :41, `cop_handlers_sprite` :52, `DeathPaletteFadeThinker` :62, `diary_menu_window_dma` :63, `EnemyDropSystem` :72, `EscortFollowPathTracker` :73, `field_reveal_object` :75, `flag_helpers` :78, `FlickerParentActor` :79, `gold_ship_wreck_palette` :85, `hidden_red_jewel` :86, `hit_stagger_controller` :87, `hit_switch` :88, `interaction_handlers` :90, `large_ramps` :95, `layer1_scroll_actors` :96, `NpcDespawnStub` :102, `oneshot_coldata_r11g4b2` :106, `oneshot_coldata_warm_flash` :107, `overworld_exit` :111, `palette_parent_child` :117, `player_transition_handlers` :118, `ramps` :119, `scene_flag_init` :122, `SpawnDamageNumberEffect` :131, `SpawnDebrisBurst` :132, `SpawnItemSparkleEffect` :134, `town_door` :140.
- `blockNotes/bank01.json` (9): `ability_damage_tables` :2, `dialog_dictionaries` :4, `dialog_template_table` :5, `display_preset_table` :6, `enemy_stats_table` :8, `forced_walk_pan_table` :10, `item_pickup_text_table` :12, `scene_warps` :18, `system_strings` :20.
- `partNotes/bank00.json` (17): `AdhocVramDma` :3, `ClearAllWramFlags` :99, `CopyActorState` :140, `FadeThenStartMusic` :200, `Layer1DriftUnbounded` :349, `Layer1ParallaxRatio` :351, `PlayerAuraLandOnSolid` :551, `PlayerAuraTransformEntry` :554, `PlayerFallFromHeight` :556, `PlayerIdleAnimLoop` :558, `ProcessAnimFlag` :572, `ScrollCameraInit` :651, `ScrollCameraVertical` :653, `SetDungeonKillFlag` :661, `SyncPlayerToCamera` :785, `TestWramFlag_Offset100` :794, `UnlinkActor` :810.
- `partNotes/bank01.json` (6): `body_table` :11, `consolestring_01E7F6` :20, `item_name_line_table` :82, `item_pickup_text_15` :85, `shared_word_table` :149, `walk_step_table` :155.
- `comments/bank00.json` (29): keys 32830, 32904, 33408, 33443, 34610, 43174, 43211, 43295, 43518, 45154, 45538, 45576, 49907, 50226, 50633, 51905, 51940, 51988, 53270, 54845, 55986, 56118, 57154, 59675, 59692, 59780, 60252, 60334, 60819. These 29 keys are all valid (each has a `; {n}` tag). The A09-01 orphan list and this id list overlap in zero keys (59675, 59692, 59780, 60252 and 60334 are not in the A09-01 list).

### 3.4 Hedges (H)

Decision per hit: was the claim code-traced (E1)? If yes, the hedge is noise. If it is a runtime-only claim, the hedge is content and should read as plain words, without the tag token.

| ID | Tag | Where | Decision | Proposed fix | Class |
|---|---|---|---|---|---|
| A09-13 | VERIFIED | `blockNotes/bank00.json`: `ApplyOrbitalOffsetFromRef` :5 ("UNVERIFIED-RUNTIME (read from the code and the table headers)"), `ApplyPlayerHitstun` :7 ("Everything here is UNVERIFIED-RUNTIME (no emulator trace); read from the code."), `hit_stagger_controller` :87 (same sentence with "move_chain_table nodes"); `blockNotes/bank01.json`: `body_table` :3 ("Not traced at runtime") | **Noise.** Each note states in the same sentence that the facts were read from the code. A blanket "no emulator trace" says nothing the reader can use. Partial noise: `SpawnDebrisBurst` :132 (the 5-frame and 40-frame figures are arithmetic from the n+1 rule, "static reading" is enough) and `move_chain_table` :14 (first half, "one node is consumed per frame", is code-traceable; the second half, "what the long curves look like in motion", is a real runtime hedge) | Delete the blanket sentences; for the two partial cases drop the token and keep one plain clause. | H |
| A09-14 | VERIFIED | `blockNotes/bank00.json`: `FlickerParentActor` :79, `interaction_handlers` :90, `large_ramps` :95; `blockNotes/bank01.json`: `ability_damage_tables` :2, `enemy_stats_table` :8, `walk_step_table` :21; `partNotes/bank01.json:102 music_pointer_array` ("(inferred)") | **Content.** Each names one specific untested thing (the ghost look, the in-game action behind L / R, extra speed on the ramps, damage bonus use at runtime, which attack uses which damage routine, what step codes look like, whether `$0D` / `$17` are placeholders). | Keep, but write in plain words ("probably", "not checked in play") and drop `UNVERIFIED-RUNTIME` / `(inferred)` and the ids (A09-12). `large_ramps` "whether another path adds speed" can be settled statically by finding writers of `playerSpeedNs`: mark for A12. | H |
| A09-15 | REPORTED | `comments/bank00.json:839` (key 39694): "Bit 4 of byte $0F = OAM priority bit 0 (inferred): set selects the layer-aware path" | The claim is a hardware reading (OAM attribute byte: priority bits are bits 4–5 of the attribute byte, so bit 4 is priority bit 0; E4) combined with a code path claim. I did not re-trace the code at 39694. | Verify against the handler, then drop "(inferred)" if both hold (A10 / Not verified). | H |

### 3.5 WaitByte / WaitWord n versus n+1 (class 2)

| ID | Tag | Where | What is wrong | Proposed fix | Class |
|---|---|---|---|---|---|
| A09-16 | VERIFIED | `extracted/actors/hit_switch.asm:68, 75` (`COP [WaitByte] ( #0F ) ; {51768} Hold for $0F frames`); `comments/bank00.json:2342` (key 51768); `partNotes/bank00.json:322 HitSwitchTriggered` ("wait $0F frames") | `#0F` holds 16 ticks, not 15. | Edit the comment to "Hold for $0F + 1 = 16 ticks (WaitByte runs N + 1 ticks)", the part note likewise. `blockNotes/hit_switch` (:88) says only "WaitByte #0F" and is correct. | 2 |
| A09-17 | VERIFIED | `extracted/functions/camera_drift.asm:170-171` (`LDA #$0003` / `STA $08`, comment "Wait 3 frames before the next run"); `comments/bank00.json:2451` (key 53343); `partNotes/bank00.json:380 loc_00D05B` ("wait 3 frames ($08)") | Direct `STA $08` of 3 waits 4 ticks. | Correct both to 4 ticks. | 2 |
| A09-18 | VERIFIED | `extracted/functions/npc_wander_ai.asm:106-107` (`LDA #$0078` / `STA $08`, comment "the script sleeps 120 frames"); `comments/bank00.json:2258` (key 51059); `partNotes/bank00.json:462 NpcWanderStageStand` ("wait 120 frames ($08 = $78)") | `$78` is 121 ticks. | Correct both to 121 ticks. | 2 |
| A09-19 | VERIFIED | `extracted/system/engine/cop_handlers_script_control.asm:79` (`STA $08 ; {43563} Store delay in timer $08 — actor waits this many frames before resuming`); `comments/bank00.json:1313` (key 43563) | Same wording gap: the stored N waits N + 1 ticks. The sentence says "this many". | "waits N + 1 ticks before resuming". | 2 |

Not wrong, listed so the F-step leaves them alone: `comments` 51643 and 59675 (already state n+1), `comments` 39463 ("a stored n waits n extra ticks"), `partNotes/bank00.json:117 code_00E8DA` ("WaitByte 1", no tick claim), `blockNotes/bank00.json:55 cop_handlers_wait`, `:132 SpawnDebrisBurst`.

### 3.6 Retired nicknames (class 3 and 10)

| ID | Tag | Where | What is wrong | Proposed fix | Class |
|---|---|---|---|---|---|
| A09-20 | VERIFIED | Block: `blockNotes/bank00.json:46 cop_handlers_player_sprite` (`will_alt`, `ability_fx`, `shadow_mode`), `:128 slider_glide` (`will_alt` ×2). Part: `partNotes/bank01.json:11 body_table` ("FacingFormOffsetTable: will_alt, ability_fx, freedan_fx, shadow_fx"), `partNotes/bank00.json:339 IsPlayerSliderSpriteBank`, `:678 SetPlayerSpriteDirect`. Comments: 41017 (:1013), 41050 (:1020), 53493 (:2476), 53772 (:2499), 53779 (:2500), 53821 (:2508) | 11 notes with 18 tokens (`will_alt` 12, `ability_fx` 4, `shadow_mode` 2) use the retired spriteset nicknames. The current labels are `spriteset_will_abilities` and `spriteset_transform_poses` (the third, the shadow aura body spriteset, is `spriteset_shadow_aura_body`). Comment 53772 also says "body_table 4 = Psycho Slider poses"; the "5 = ability poses" claim in `slider_glide` (report N-6) was not re-checked against the `body_table` rows in this step. | F03 (already specified). | 3, 10 |
| A09-21 | VERIFIED | `db-us/names/bank03.json:473` `FacingData_WillAlt`, `:474` `FacingData_AbilityFx` | Names (not notes) still carry the nickname. Out of A09 scope but it is the other half of F03. | F03 part 2 (needs your approval). | 10 |

### 3.7 Button vocabulary (class 13)

| ID | Tag | Where | What is wrong | Proposed fix | Class |
|---|---|---|---|---|---|
| A09-22 | VERIFIED | `comments/bank00.json:34` (key 33009) "Process B-button dodge callbacks" on `extracted/system/engine/system_core.asm:242` | `ProcessDodgeCallbacks` tests `BIT #$0080` on `joypadCurrent` (`combat_collision.asm:136`, comment there: "A"-position bit, the attack / action button). `$0080` is the A position in the remapped build; the comment uses the vanilla B-button word for a bit that is A here. | "Process dodge callbacks (action bit $0080 of joypadCurrent)", or "A button" with the remap sentence the other notes use. | 13 |
| A09-23 | REPORTED | `comments/bank00.json:1273` (key 43300) "Clear it so the text renderer sees every button (A/B to advance)", `extracted/system/engine/cop_handlers_dialog.asm:145` | Names two buttons as the advance keys. Which bits the text renderer reads is not checked here; in this build the advance bit may be the remapped A only. | Verify the text-advance mask in the dialog handler, then reword to the logical bit or the remapped button. | 13 |

Correct (leave alone): `comments` 49098 ("the B button in the vanilla layout, the A button in this build"), `blockNotes/bank00.json:84 global_ambient_dispatcher` and `:35` (state the remap explicitly).

### 3.8 Transform adjacency (class 12) and others found on the way

| ID | Tag | Where | What is wrong | Proposed fix | Class |
|---|---|---|---|---|---|
| A09-24 | VERIFIED | Sweep 8 table above | **No** current adjacency breakage in bank 00–01 notes (diary regex, COP triple, joypad pairs all intact). The only note-text hazard document is `diary_menu_window_dma.asm:8`. | None. Record as a negative result. | 12 |
| A09-25 | VERIFIED | `mountain_temple/kress_crossroads/mtA2_mushroom_drop_gate.asm:18-19, 40-41`; `kress_circuit/mtA5_mushroom_drop_gate_a.asm:18-19, 40-41`; `mtA5_mushroom_drop_gate_b.asm:17-18, 48-49` | Vanilla `LDA #$EFF0` followed by `TSB` / `TRB $joypadMaskStd` with no `transforms.json` key for these three blocks, unlike 161 sibling pairs that become `$EFFC`. Mask values, so ROM bytes may differ from the intended remap (not decided here). | Hand to A10 and A15: confirm whether these three blocks need a `joypadMaskStd` transform key, and whether the plain and tagged builds differ. | 13 |
| A09-26 | VERIFIED | `gaia-core/docs/notes-and-comments.md` (line-tracking paragraph) | Says commented lines carry no `; {n}` tag; `oneshot_palette_flash_18.asm:16` shows tag **and** comment on one line. | AP-17 / F05 doc edit; the corrected statement also makes comment-key orphan checking exact (this step relied on it). | – |

---

## 4. Not verified / needs Mesen2

No ROM or state exists, so nothing here is runtime-checked. Specific gaps:

1. **A09-15** (comment 39694): the OAM priority-bit reading and the "layer-aware path" claim were not re-traced.
2. **A09-23** (comment 43300): which button bits the text renderer accepts for advancing.
3. **A09-11**: the P2b candidate hits (19 + 11 block notes, 10 + 1 part notes) were not read; some "old" uses may be game logic.
4. **A09-02, A09-03**: for each orphan comment I classified it from tags and neighbouring text. Whether a lost fact exists at the corrected address was checked for 46991, 47052, 50105, 53048 and 53086 only; the rest need a per-key read in the F-step.
5. **A09-01**: whether every fact in the 29 smooth-follow orphans is also carried by the current comments at `ComputeFollowAngle` / `ComputeFollowStep` was not compared line by line.
6. **Orphan check limits**: it proves a key has a matching label or tag, not that the note text fits the instruction there. A key can match an address whose instruction changed meaning (displaced but still valid). No sweep in this step detects that.
7. **WaitByte semantics for `LoopStart` / `LoopEnd`**: `extracted/actors/town_door.asm:41` ("8 frames to hold Up") and the other `LoopStart` counts were not traced through `LoopEnd`; I left them out of A09-16…19.
8. **Comments in other banks** (80 orphans over all banks, 53 in bank 00) are A10's.

---

## 5. Items for the fix specs

New F-step ids are proposals; `PLAN.md` currently ends at F06.

| F-step | Findings | Mechanism | Notes |
|---|---|---|---|
| F02 (extend) | A09-16, A09-17, A09-18, A09-19 | `merge` spec: 3 part notes, 4 comments (51768, 53343, 51059, 43563) | The F02 prompt lists only `warps_interaction`, `music_actors`, `item_use_system`; add these four groups. |
| F03 (extend) | A09-20, A09-21 | `merge` for 11 notes; `names` spec only after your approval | Includes the comment 53772 / row-5 check. |
| F05 (extend) | A09-26 | doc edit | Add to the AP-17 list. |
| F07 (new): prune orphans | A09-01…A09-04 | **blocked** until `merge` can prune (A09-06 = T03 / AP-15); then a `merge` spec | Re-key first (46991 → 46999, 53086, 52728, 62455 if text is lost), then prune 53 comment keys and 6 block-note keys. |
| F08 (new): history narration and retired names | A09-07, A09-08, A09-09, A09-10, A09-11 | `merge` spec, one block / part note at a time | 25 + 4 + 8 notes, 7 correction headers; read the P2b candidates. Also resolves A09-10's two Appendix A hits. |
| F09 (new): id citations | A09-12 | `merge` spec | Depends on A12 (which ids stay as plain open-question sentences). 99 notes. |
| F10 (new): hedge wording | A09-13, A09-14, A09-15 | `merge` spec | 4 noise deletions, 2 partial, 7 reworded; A09-15 after verification. |
| F11 (new): button wording | A09-22, A09-23 | `merge` spec | One certain, one after a check. |
| T01 / A15 | A09-05, A09-24, A09-25 | user-owned `transforms.json` | Dead keys, three untransformed mushroom-gate blocks. |
| T03 | A09-06 | `src/` change + doc | Orphan-prune path and `merge --check`. |

Fix steps for notes go through `npm run merge` (dry-run first, then `npm run extract:lt` to verify, then `npm run rebuild`; gate checksum 223006080, crc 2083230829, totalSize 3062204). Do not touch `?BANK`, and do not edit notes by hand.

---

## 6. Counts

| Item | Count |
|---|---:|
| Findings | **26** (A09-01 … A09-26) |
| VERIFIED / REPORTED | 23 / 3 (REPORTED: A09-11, A09-15, A09-23) |
| Keys checked for orphans | 4552 (835 + 157 part, 3380 comments, 140 + 20 block) |
| Orphan part-note keys | 0 |
| Orphan comment keys (bank 00) | 53 (29 + 15 + 9) |
| Orphan block-note keys | 6 |
| Dead transform keys | 4 (plus 4 inert) |
| Block notes with history narration (spec pattern) | 25 (22 + 3), 28 occurrences; part notes 0; comments 0 |
| Extra narration: older header / name | 3 block notes + 1 comment |
| Extra narration: P2b candidates | 30 block notes, 11 part notes (REPORTED) |
| `=== CORRECTIONS ===` / `WHAT WAS WRONG` sections | 7 |
| Notes preserving a retired name inside history | 8 (2 in Appendix A) |
| Notes with ledger ids | 99, 118 `OQ-` tokens (35 legacy, 83 iteration-prefixed), 121 with bare iteration ids |
| Hedge notes | 14 (4 noise, 2 partial, 7 content, 1 unverified) |
| WaitByte / WaitWord count errors | 4 groups (`hit_switch`, `camera_drift`, `npc_wander_ai`, `cop_handlers_script_control`): 3 part notes, 4 comments |
| Retired nickname tokens | 18 in 11 notes (`will_alt` 12, `ability_fx` 4, `shadow_mode` 2) |
| Button findings | 1 verified wrong, 1 candidate |
| Transform adjacency breakage in bank 00–01 | 0 |
