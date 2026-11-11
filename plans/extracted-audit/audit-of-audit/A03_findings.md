# A03 findings: iterations I031–I040

Step A03 of the audit of the audit. Scope: results, renames, questions and edits of I031..I040, checked against the live tree, plus the ordering effects of I035/I036 having run after I037. Nothing was edited except the A03 row of `PLAN.md`. All evidence is static (E1–E4). There is no Mesen2 ROM or save state, so no E5 claim appears below.

Tags: **VERIFIED** = checked in the live files in this session (file:line given). **REPORTED** = taken from a ledger and not re-checked.

## 1. Scope and files read

Ledgers, read in full unless noted:
- `results/I031..I040_results.md`, `results/I021-I040_sanity-check.md`.
- `renames/I031..I040_renames.md`, `renames/sanity-I021-I040_renames.md`, `renames/apply-I021-I040_summary.md`. `apply-I021-I040_plan.md` and `apply-I021-I040_map.json` were **not** read; `edits/*.json` were searched, not read.
- `questions/I031..I040_questions.md`, `questions/sanity-I021-I040_questions.md`.
- `digest_I021-I040.md`, `report.md` v2, `PLAN.md`, `A02_findings.md` (format model).

Live files read or searched (about 45): `thinkers/` `hdma_circle_window_thinker`, `sine_hdma_slow_wave`, `ambient_palette_cycler`, `oneshot_coldata_warm_flash`, `oneshot_coldata_r11g4b2`, `flag_gated_palette_warm`, `flag_gated_palette_cool`, `palette_parent_child`, `scanline_band_hdma_thinker`, `mode7_perspective` (grep); `functions/` `StopPlayerOnDeath`, `EnemyDeathFlash`, `ActorDisplayModeSwap`, `SpawnDebrisBurst`, `RandomPlayerOffset`, `EnemyInitBasic` (grep), `SetPlayerIdleFacing` (grep), `ActorMidpointCalc` (grep), `StandardEnemyDefeatHandler` (grep), `game_over_sequence` (grep); `actors/` `player/slope_ramp_physics`, `ramps`, `interaction_handlers`, `large_ramps`, `debug_stat_setter`, `camera_delta_oscillator`, `idle_sprite_display`; `system/player/` `player_move_south`, `player_move_east`, `player_move_west`, `player_move_ramps` (grep); `system/inventory/inventory_overlay`; `system/hdma_ramp_tables`; `system/boot_logos/sFB_boot_logo` (grep); `system/engine/` `combat_collision`, `cop_handlers_script_control`, `cop_handlers_player_query`, `cop_handlers_movement`, `actor_execution`, `tile_collision_physics`, `actor_pool`, `system_core`, `vblank_joypad`; `tables/scene_thinkers`, `tables/scene_actors` (counts).
Databases: `db-us/names/bank00,01,02,05.json`, `db-us/blocks.json`, `db-us/mnemonics.json`, `db-us/copdef.json`, `db-us/transforms.json`; `notes/blockNotes/bank03.json` (grep); `docs/` (grep); `docs/cop/families/player_query.md`.

Procedure slip, disclosed: early in the step I ran one shell command with `head` (`git status --short | head -20; git log --oneline -3`). It is read-only but `head` is outside the permitted shell list. Everything else used Grep, Glob and Read. Two Grep calls with brace globs returned no result and were repeated with plain paths.

## 2. Per-row status table (rename rows and Q5 rows)

Statuses: APPLIED (verified live), PARTIAL, PROPOSED (not applied; live evidence given), DROPPED, KEEP (ledger says no change), DOCS (documentation-only row). Q5 = mnemonic row. No row is SUPERSEDED.

| Row | Subject | Status | Live evidence |
|---|---|---|---|
| R-I031-1 | `hdma_gradient_thinker` → `hdma_circle_window_thinker` and its parts | APPLIED | `names/bank05.json:10-21`; `blocks.json:303`; no `hdma_gradient` in `extracted/` or `db-us/` (rg) |
| R-I031-2 | name `$7E7000/$7100/$7200` (`circleWindowTable*`) | PROPOSED | no such key in `mnemonics.json`; the thinker still uses `$tileStagingBuffer` and literals (`hdma_circle_window_thinker.asm:3`) |
| R-I031-3 | `code_00BE1A` → `SineWaveInit` | APPLIED | `names/bank00.json:48666`; `sine_hdma_slow_wave.asm` uses it |
| R-I031-4 | keep `EnemyDeathFlash`, `ambient_palette_cycler` | KEEP | both files exist |
| R-I032-1 | four slope auto labels | PARTIAL | 3 of 4: `names/bank02.json:168,174,179` (`SlopeHandlerExit`, `SlopeSpeedZeroLatch`, `DecelResetCounterEW`); `loc_02B76C` (178028) has no entry (gated on OQ-I032-1) |
| R-I032-2 | delete `ReadDecelerationStepNS` | DROPPED | changes ROM bytes; part still live in `slope_ramp_physics.asm` (~673) |
| R-I032-3 | `StopPlayerOnDeathAssign` → `StopPlayerOnDeath` | APPLIED | `names/bank00.json:62387`; no old name in `extracted/`, `db-us/`, `docs/` (rg); one stale copy in `notes/` is not the old name (see A03-08) |
| R-I032-4 | doc entry `$0200 deathFlag` | DOCS, done | `docs/` has no `deathFlag` (rg, 0 hits). The ledger target is gone. `StopPlayerOnDeath.asm:5` still quotes the entry (A03-08) |
| R-I033-1 | `FineAdjustXEast/West` rename | PROPOSED | `names/bank02.json:400-401` unchanged; gated on OQ-I033-1/-4 |
| R-I033-2 | `ActorDisplayModeSwap` → `ActorInitVariantAndPriority` | PROPOSED | `blocks.json:932`; gated on OQ-I033-6 |
| R-I033-3 | `oneshot_coldata_warm_flash` → `…warm_tint` | PROPOSED | `names/bank00.json:46686` unchanged; gated on OQ-I033-5 |
| R-I033-4 | docs and comments in other files | DOCS | REPORTED (A11 owns) |
| R-I034-1 | `DrainActorQueue` → `ResetThinkerWaitCounters` | APPLIED | `names/bank02.json:192267`; `inventory_overlay.asm:253,298` |
| R-I034-2 | `oneshot_coldata_green_tint` → `…r11g4b2` | APPLIED | `names/bank00.json:46821`; file `thinkers/oneshot_coldata_r11g4b2.asm`; `scene_thinkers.asm:60,362` |
| R-I034-3 | `idle_sprite_display` → `static_gem5_pickup` | PROPOSED | live file and block still `idle_sprite_display`; gated on OQ-I034-3 |
| R-I034-4 | docs (inventory overlay, WRAM map) | DOCS | REPORTED |
| R-I035-1 | `parallax_thinker` → `scanline_band_hdma_thinker` | APPLIED, residue | `blocks.json:299`; `scene_thinkers.asm` uses the new name; old name still in `mode7_perspective.asm:52` and `notes/blockNotes/bank03.json:15` (A03-12) |
| R-I035-2 | `ParallaxResolveEntryStride`, `hdma_entry_stride_by_mode` | APPLIED | `names/bank00.json:47802`; `names/bank01.json:121086` |
| R-I035-3 | six `Parallax*` routines | APPLIED | `names/bank00.json:47299,47643,47712,47821,47903,47971` |
| R-I035-4 (Q5) | `effectScrollH/mapScrollV/effectScrollV` → `bg2ScrollH/bg1ScrollV/bg2ScrollV` | PROPOSED | `mnemonics.json:67-69` unchanged |
| R-I035-5 | four auto labels | APPLIED | `names/bank00.json:47245,47462,47502,47539` |
| R-I035-6 | `inventory_dma_setup` → `inventory_bg3_scroll_hdma` (+2 labels) | APPLIED | `names/bank00.json:48014,48016,48023`; `scene_thinkers.asm:53` |
| R-I035-7 | 22 `parallax_type_NN` labels | APPLIED | `names/bank01.json:430-441,456-465` = 22 entries |
| R-I035-8 | doc line `hdma_dma.md:172` | DOCS | REPORTED (`docs/` has no old names) |
| R-I036-1 | `RampPlayerClimbWest/North` | APPLIED | `names/bank00.json:54517,54552` |
| R-I036-2 | swapped `ramp_*_step` labels | APPLIED | `names/bank00.json:54577,54635` (`RampClimbNorthStep`, `RampClimbSouthStep`); no old name in `extracted/` |
| R-I036-3 | `func_00D5C0` → `RampArcDriver` | APPLIED | `names/bank00.json:54720`; `ramps.asm:431,450` |
| R-I036-4 (Q5) | block-local `rampCurveOffset/rampExitSpeed` | PROPOSED | not in `mnemonics.json`; `ramps.asm` still uses `!orbitAngle/!orbitDiameter` |
| R-I036-5 | 12 `Ramp<Dir>Watch/Armed/Launch` labels | APPLIED | `names/bank00.json:53973-54402` (12 entries) |
| R-I036-6 | `flag_gated_palette_*` → `kara_news_palette_*` | PROPOSED (low confidence) | `blocks.json:287-288` unchanged; gated on OQ-I036-6 |
| R-I036-7 | docs (ramps, thinker palette) | DOCS | REPORTED |
| R-I037-1 | `push_handler_*` → `pull_handler_*` | PROPOSED | block names live; gated on OQ-I037-1 |
| R-I037-2 | direction family renamed by where the player stands | APPLIED | `names/bank00.json:734-743` (`CollectGemAlignPlayer*`), `:750-759` (`PushSolidMovePlayer*`); the note in `interaction_handlers.asm:13` was not updated (A03-04) |
| R-I037-3 | `EnemyInitBasic` → `BossInitBasic` | PROPOSED | gated on OQ-I037-4 |
| R-I037-4 | `RandomPlayerOffset` → `RandomPlayerMarkerActor` | PROPOSED | gated on OQ-I037-5 |
| R-I037-5 | docs and comments in other files | DOCS | (c) VERIFIED still open: `player_query.md:45-46` (A03-03). (a), (b), (d) REPORTED |
| R-I038-1 | `EastRampDown/Up`, `WestRampUp/Down` → `EastSlope*` | PROPOSED | `names/bank02.json:413,416,418,421` unchanged; gated on OQ-I038-1 |
| R-I038-2 | four wall-snap labels | APPLIED | `names/bank02.json:186671,186679,187002,187010` (`RampSnap{East,West}{South,North}…Wall`) |
| R-I038-3 | `camera_delta_oscillator` → `camera_delta_drift` | PROPOSED | `blocks.json:276` unchanged; gated on OQ-I038-4 |
| R-I038-4 | docs and comments in other files | DOCS | (a) fixed: `player_move_east.asm:64` now says `WestRampUp`. (b)–(d) REPORTED |
| R-I039-1 | `InitPlayerScriptVariant` → `SetPlayerIdleFacing` | APPLIED | `names/bank00.json:50916`; no old name in `extracted/` |
| R-I039-2 | `NorthProbeRedirect` → `NorthWallGapRetry` | PROPOSED | `names/bank02.json:184888` unchanged; gated on OQ-I039-4 |
| R-I039-3 | `NorthSlopeRight/Left` → `NorthSlope03/0C` | PROPOSED | `names/bank02.json:184558,184610` unchanged |
| R-I039-4 | doc / comment corrections | DOCS | REPORTED |
| R-I040-1 | `LargeRampBoostNorthSouth` → `LargeRampIdleHold` | APPLIED | `names/bank00.json:51597`; `large_ramps.asm` |
| R-I040-2 | `EastWallNorth/SouthHandler` → `EastWallPushDown/Up` | APPLIED | `names/bank02.json:186267,186351` |
| R-I040-3 | keep `PaletteParentChildSpawnWave` | KEEP | label live in `palette_parent_child.asm` |
| R-I040-4 | doc / comment corrections | DOCS | REPORTED |

**Counts (48 rows):** APPLIED 20 (one of them with residue, R-I035-1), PARTIAL 1, PROPOSED 15, DOCS 9, DROPPED 1, KEEP 2, SUPERSEDED 0.
**Q5 rows: 2 of 2 PROPOSED** (R-I035-4, R-I036-4); none applied. The apply summary's "R-I035-1, -2, -3, -5, -6, -7", "R-I036-1, -2, -3, -5", "R-I037-2", "R-I038-2", "R-I039-1", "R-I040-1, -2" lists all check out against `names/*.json`. Open gaps in the summary: it lists R-I032-1 as "3 of 4" (correct) and R-I031-1/-3 (correct).
The gated PROPOSED rows (10 of 15) wait on an OQ: R-I033-1, -2, -3; R-I034-3; R-I036-6; R-I037-1, -3, -4; R-I038-1, -3; R-I039-2.

## 3. Open questions of I031..I040 (57 questions)

"Answered later" means a later ledger row, note or live code gives the answer. None is answered by a runtime check. I do not answer any OQ here; the column only locates what exists.

| OQ | Question (short) | Answered later? Where |
|---|---|---|
| I031-1 | What does credits window V1 look like (one-byte row stride)? | No (runtime) |
| I031-2 | Where does scene 67 enable window 1? | No |
| I031-3 | What do `W12SEL = $33` / `WOBJSEL = $03` select? | No (hardware decode never written down) |
| I031-4 | What does each `ambient_palette_cycler` bundle look like? | No; spawn count 59 re-confirmed in `scene_thinkers.asm` (REPORTED count) |
| I031-5 | What does the `EnemyDeathFlash` animation look like, why `$2000` before `Die`? | No |
| I032-1 | Does `DecelerateNS` reset `slopeStepCounter` instead of `decelStepCounter`? | No; static reading unchanged (`loc_02B76C` still unnamed) |
| I032-2 | Is `ClampSpeeds` NS-only-when-EW-zero intended? | Static reading **confirmed** (`slope_ramp_physics.asm:399-431`, VERIFIED); intent open |
| I032-3 | Why different probe points moving vs stopped? | No |
| I032-4 | What are `$06/$09`; why probe up/down? | Duplicate of I033-4 = I029-5 = I030-3 = audit OQ-16 |
| I032-5 | What reads actor `$10` bit `$0200`? | Duplicate of I036-4, I023-3, I027-2, I030-2 |
| I032-6 | What does `sine_hdma_slow_wave` look like in scenes `$32/$E9/$EA`? | No; scene list re-confirmed (`scene_thinkers.asm:129,312-313`) |
| I033-1 | Can `FineAdjustXEast` be reached with `$02 > 16`? | Asymmetry **confirmed in code** (`player_move_south.asm:546-585` vs `589-621`); reachability open |
| I033-2 | Why `SnapYNorthCollision` in the `$06` south handler? | No |
| I033-3 | Which diagonal do `$03/$0C` follow; slow-down strength? | Duplicate of I039-1 |
| I033-4 | Are `$06/$09` diagonal wall pieces? | Duplicate of I032-4 |
| I033-5 | What are scenes `$23/$27`; does the tint stay? | Partly: slots re-confirmed (`scene_thinkers.asm:114,118,389-392,403-404`); on-screen result open |
| I033-6 | Does `$0E = $2000` change draw priority of the 22 callers? | No; caller count re-confirmed (23 sites, 22 files) |
| I034-1 | What does `displayModeFlags` bit 14 do? | No (re-asked in the `sFB_boot_logo` and `inventory_overlay` notes) |
| I034-2 | CGADSUB add or subtract in scene `$30`? | No; slot layout re-confirmed (`scene_thinkers.asm:361-367`) |
| I034-3 | Is `idle_sprite_display` used? | No; no reference by name (rg) |
| I034-4 | Why only cache slots C and D invalidated; unsaved words? | No |
| I034-5 | Does the inventory scene overwrite the sine tables? | No |
| I034-6 | Does zeroing thinker wait counters restart ambient effects in phase? | No |
| I035-1 | What does each parallax type look like; CGADSUB/TM dependence? | No (runtime) |
| I035-2 | Why `$0060 = 1`, `$005E = 0` after binding? | No |
| I035-3 | Is the `$0720-$074F` clear enough for types `$05/$24`? | No; note repeats it (`scanline_band_hdma_thinker.asm:60`) |
| I035-4 | What is type `$20` (scene `$C3`) for? | No |
| I035-5 | What do the BG3 V-scroll steps do on the inventory screen? | No |
| I035-6 | Who reads `hpToHeal` (`$0B22`)? | **Answered statically, ledger premise wrong**: `UpdateHUD_Active` reads it (`system_core.asm:416-424`, VERIFIED); later notes (`sE6_gaia.asm:16,597`, `jeweler_gem.asm:12`, `inventory_mgmt.asm:14`) already rely on it. See A03-01 |
| I035-7 | Do types `$09,$0C,$0D,$0F-$1A` have no spawn; are `$04/$22` runtime-spawned? | Partly: scene lists spawn no `#04/#22/#FF` record (rg, VERIFIED); the 77 runtime `SpawnThinker*` sites are not enumerated |
| I036-1 | Does the exact-equality trigger always fire? | No (runtime) |
| I036-2 | How far does a launch carry the player? | No (runtime) |
| I036-3 | What are animation indices `$19,$1E,$21,$24`? | No |
| I036-4 | What reads the player's `$10` bit `$0200`? | Duplicate of I032-5 |
| I036-5 | Does the flag-gated thinker replay in the same visit? | No |
| I036-6 | What do bundles `$02/$4C` look like; is Oakton inert? | Partly: setters re-confirmed (`sc02_erik.asm:22` sets `$16`, `sc06_monologue.asm:39` sets `$1C`; no `ClearFlagByte` for either, rg VERIFIED); Oakton flag state and look open |
| I036-7 | Does a full pool break the east/west climb? | No |
| I037-1 | Does a statue move toward the player (a pull)? | No (runtime/ability); static facts re-confirmed |
| I037-2 | Does `LoopEnd` yield once per pass? | **Answerable statically**: `cop_handlers_script_control.asm:7,260` (decrement; until zero set `$00` to the loop head and yield). Second half (walking into the slide) open |
| I037-3 | Is the operand order W/Here/E and are the copdef/doc labels wrong? | **Answered statically**: handler order W/Here/E (`cop_handlers_player_query.asm:193-218`, header `:191`). The premise is half wrong: `copdef.json:44-45` has bare `&Code`; only `docs/cop/families/player_query.md:45-46` shows W/E/Here (A03-02, A03-03). The site scan is not done |
| I037-4 | What do `$12 \|= $0030` and ext `$0080` do for the two callers? | No |
| I037-5 | Does the scheduler rerun `RandomPlayerOffset` after the 60-frame wait? | No (runtime); see A03-09 for the 60/61 count |
| I038-1 | Do the column-crossing Y formulas give a smooth ramp? | No (runtime) |
| I038-2 | Is the corner-snap Y compensation correct for both slope types? | No |
| I038-3 | What does `ActorMidpointCalc` read when `$06` is 0? | No; caller count re-confirmed (7 sites, 5 files) |
| I038-4 | Is `camera_delta_oscillator` ever spawned? | No; still no reference in `extracted/` (rg, VERIFIED, 0 hits outside its own file) |
| I038-5 | Why does `EastRampDown` sample the top row? | No |
| I039-1 | Does the `slopeFracAccum` filter slow `$0C` to about 56 percent? | Duplicate of I033-3 |
| I039-2 | Does `SouthWallNudge` fire as stated? | No |
| I039-3 | Does `SnapYNorthCollision` with `$24 = 0` push south 1..16 px? | No |
| I039-4 | Is the `MapCellDown` + `ReadCollisionNibble` pair in `NorthProbeRedirect` dead? | No |
| I039-5 | What does `$09AF` bit `$10` change? | No |
| I039-6 | Eight particles one per 5 frames; what does `$0302` do? | Partly: timing **confirmed statically** (`SpawnDebrisBurst.asm:12-20`, VERIFIED); bit `$0002` = "in front of every actor" is decoded in `StandardEnemyDefeatHandler.asm:6,75` but `SpawnDebrisBurst.asm:3` still says undecoded (A03-07) |
| I040-1 | Does `large_ramp_booster` boost once per approach? | Static reading **confirmed** (`large_ramps.asm:29-52`, VERIFIED); runtime open |
| I040-2 | Is `playerSpeedEw` incremented to `+1` when only NS is nonzero? | Static reading **confirmed** (`large_ramps.asm:39-45`) |
| I040-3 | Who sets/clears palette flag `#01` in scenes `$FD/$FF`? | No; spawn records re-confirmed (`scene_thinkers.asm:332,334,747-761`) |
| I040-4 | Do the east wall-slide handlers push as the notes now state? | No (runtime); the sign reading is consistent (`player_move_east.asm:26,186,225,252,301`) |

**Counts:** 57 questions. Answered or confirmed statically: I032-2 (reading), I033-1 (asymmetry), I035-6 (answered; **ledger premise wrong**), I037-2 (answerable), I037-3 (answered; premise half wrong), I039-6 (half), I040-1, I040-2 = 8, of which none runtime-confirmed. Partly: I033-5, I035-7, I036-6. Duplicates: I032-4 = I033-4 = I029-5 = I030-3 = audit OQ-16; I032-5 = I036-4 (= I023-3, I027-2, I030-2); I033-3 = I039-1. Runtime-only: about 38.

## 4. Re-verified facts from the results files (35 checks)

Result: **29 correct, 4 partly wrong or stale, 2 wrong.** About 35 files, defect classes 2, 3, 4, 5, 6, 7, 9, 10, 11, 12 touched.

| # | Claim (ledger or live note) | Live check | Verdict |
|---|---|---|---|
| 1 | `sine_hdma_slow_wave` spawned by scenes `$32` and `$E9/$EA` (I031/I032) | `scene_thinkers.asm:129,312-313,432-434,747-749` | correct |
| 2 | Flag `$16` set by `sc02_erik`, `$1C` by `sc06_monologue`, neither cleared (I036) | `sc02_erik.asm:22`, `sc06_monologue.asm:39`; rg for `SetFlagByte/ClearFlagByte/ToggleFlagByte #16/#1C`: 2 hits, both sets | correct (COP sites only) |
| 3 | warm spawned in scenes 01 / 30, cool in scenes 03-08 (I036) | `scene_thinkers.asm:15,80,127,365`; list `0CE7EA` slot 1 | correct |
| 4 | `oneshot_coldata_r11g4b2` in scene `$30` slot 0, scene `$01` enters at +4 (I034) | `scene_thinkers.asm:80,127,361-362` | correct |
| 5 | `oneshot_coldata_warm_flash` in scene `$23` slot 2 and `$27` slot 0 (I033) | `scene_thinkers.asm:114,118,389-392,403-404` | correct |
| 6 | COLDATA `$2B` = R11, `$44` = G4, `$82` = B2 (I034, I033) | bit `$20/$40/$80` select R/G/B, low 5 bits intensity (E4); arithmetic holds | correct |
| 7 | Types `$04`, `$22` and `$FFFF` entries not spawned by any scene list (I035) | rg `thinker-spawn < #04/#22/#FF, @scanline_band…`: 0 hits | correct (runtime spawns open) |
| 8 | 22 `parallax_type_NN` labels (I035) | `names/bank01.json:430-441,456-465` | correct |
| 9 | `hdma_channel_config` `#26` mode 1, `#0D`/`#12` mode 2; stride 2/3 (I035) | `hdma_ramp_tables.asm:1-90`; `scanline_band_hdma_thinker.asm:22-23` | correct |
| 10 | `CheckPlayerDeath` sets `$0200`, installs `GameOverSequence`, then calls `StopPlayerOnDeath` (I032) | `combat_collision.asm:162,181`; `game_over_sequence.asm:1` | correct |
| 11 | `ClampSpeeds` checks NS only when EW is zero (I032) | `slope_ramp_physics.asm:399-431` | correct |
| 12 | `FineAdjustXEast` moves X west by n + `$02` − 16, `FineAdjustXWest` east by `$02` − n, East has no wrap handling (I033) | recomputed from `player_move_south.asm:546-585` (flush case n = 16 gives west by `$02`) and `589-621` (`ORA #$FFF0 / EOR / INC` = 16 − n′) | correct |
| 13 | `ActorDisplayModeSwap`: 23 `JSL` sites in 22 files (I033) | rg: 22 files, `eu91_merchant` twice | correct (24-of-25 header claim REPORTED) |
| 14 | `SetPlayerIdleFacing`: 17 sites in 14 files (I039) | rg: 17 hits in 14 files | correct |
| 15 | `ActorMidpointCalc`: 7 sites in 5 files (I038) | rg: 7 hits, `awB0_zombie`, `mtA0_acid_spider` ×2, `av6E_draco` ×2, `dm3D_flayzer`, `unused_mode7_boss` | correct |
| 16 | `EnemyInitBasic` has two callers (I037) | `dm3F_laborer.asm:169`, `fr32_kidnapper.asm:68` | correct |
| 17 | `RandomPlayerOffset` has no `JSL` caller, two `SpawnAfterMarked` sites, `$08 = $3C`, ±128 px (I037) | `awB1_goldcap.asm:28`, `pyDD_mummy_queen.asm:146`; `RandomPlayerOffset.asm` body | correct (60 vs 61 ticks: A03-09) |
| 18 | `ramps` placements 58 = 26 / 22 / 6 / 4 (I036) | rg counts on `scene_actors.asm`: 58 lines; east 26, west 22, north 6, south 4 | correct |
| 19 | `large_ramps`: radius 2 = 32 px box, radius 3 = 48 px, boost once per approach (I040) | `large_ramps.asm:26-52`; `BranchIfPlayerNear` threshold `r × 16 + 1` (`cop_handlers_movement.asm:72-97`) | correct |
| 20 | `BranchIfPlayerNear( #0F )` = square, \|d\| < 241 px (I037) | same handler, 15 × 16 + 1 = 241 | correct |
| 21 | `BranchOnPlayerX` operand slots: Y = 2 west, 4 centre, 6 east (I037) | `cop_handlers_player_query.asm:193-218` | correct |
| 22 | "outer slot when the player is **more than** 15 px away" (I037 note) | `:200-212`: `CMP [$0A]; BCC centre` means \|Δ\| ≥ threshold takes the outer slot | **partly wrong** (A03-02) |
| 23 | "docs and the **copdef** label the operands West / East / Here" (I037 ledger and note) | `copdef.json:44-45` = bare `&Code`; only `player_query.md:45-46` has labels | **wrong** (A03-02) |
| 24 | No reader of `hpToHeal` / `$0B22` in `extracted/` (I035) | `system_core.asm:416-424`: `LDA $hpToHeal`, `DEC`, `STA`, `INC $playerHp` every 8 frames | **wrong** (A03-01) |
| 25 | `camera_delta_oscillator`: bit 9 of `$0036` picks INC/DEC; no reference anywhere (I038) | `camera_delta_oscillator.asm:20-30`; rg 0 hits | correct |
| 26 | `SpawnDebrisBurst`: `WaitByte(3)` = 4 ticks, +1 `LoopEnd` yield = 5; 8 particles, about 40 frames (I039) | `SpawnDebrisBurst.asm:12-20`; `cop_handlers_script_control.asm:7` | correct |
| 27 | `SpawnDebrisBurst`: flag bit `$0002` "undecoded" (I039) | `StandardEnemyDefeatHandler.asm:6,75`: bit `$0002` = in front of every actor | **stale** (A03-07) |
| 28 | `palette_parent_child` spawned only by scenes `$FD`, `$FF` (I040) | `scene_thinkers.asm:332,334,747-761` | correct |
| 29 | `DisableNmiKeepJoypad` writes NMITIMEN `$01` (NMI off, joypad auto-read on) (I034) | `vblank_joypad.asm:288-297`; `inventory_overlay.asm:16,107` (E4: bit 7 = NMI, bit 0 = auto-read) | correct |
| 30 | The four ramp handlers are reached only from `DispatchEastMove` (I038) | rg for `player_move_ramps.` outside the file: 4 `JMP`, all in `player_move_east.asm:61,64,117,122` | correct |
| 31 | Child `$04` link = spawner / marked actor (I036 and I037) | `actor_pool.asm:5,155-156`; `ramps.asm:24`; `interaction_handlers.asm:3` | correct (marked variant REPORTED) |
| 32 | `circle_window_thinker_v2`: "the first frame always builds" (I031) | `HdmaInitPrevState` zeroes the previous words (`:667-673`); `HdmaCompareParams` reports no change if the current ones are zero too (`:679-693`) | **partly wrong** (A03-06) |
| 33 | `StopPlayerOnDeath` note: docs list "`$0200 deathFlag`" (I032) | `docs/`: 0 hits | **stale** (A03-08) |
| 34 | `$0E` has two modes in `InitActorFromSceneData` (I033 vs I036) | `actor_execution.asm:957-972` | correct |
| 35 | `idle_sprite_display` stores `$0085` into `chatPtr` (I034) | `idle_sprite_display.asm:18-19` (the "+5 gems" effect is REPORTED) | correct |

## 5. Findings

Fields: id, tag, location, what is wrong, proposed fix, defect class (PLAN.md numbering), fix step.

**A03-01** (VERIFIED, class 11 and 7). A negative-search claim is wrong and the note points at a questions file. `debug_stat_setter.asm:5` says "no reader of $0B22 was found in extracted/, so that is documentation only (see the questions file)". `system_core.asm:416-424` (`UpdateHUD_Active`) reads it: `LDA $hpToHeal; BEQ …; DEC; STA $hpToHeal`, then `INC $playerHp` and SFX `$0D` every 8 frames (`BIT #$07` on `frameCounter`), cleared when `playerHp = playerMaxHp`. The other writers (`item_use_system.asm:521,1704`, `jeweler_gem.asm:291`, `sE6_gaia.asm:607`, `inventory_mgmt.asm:95,159`, `reward_actors.asm`, `dc2F_adrift.asm:254`) already describe this. OQ-I035-6 is therefore answered statically and its ledger evidence ("UpdateHUD was not located as a reader") was incomplete. The inline comment at `debug_stat_setter.asm:28` is correct. Fix: `merge` spec rewriting `debug_stat_setter.asm:5` (state the reader, drop the pointer). Step: F07.

**A03-02** (VERIFIED, class 11 and 6). `interaction_handlers.asm:10-11` has two defects. (a) Line 11 says "docs/cop/families/player_query.md **and the copdef** label the three operands West / East / Here". `db-us/copdef.json:44-45` declares both as bare `&Code`; there are no labels in the copdef. The same wrong statement is in OQ-I037-3 and in R-I037-5(c) ("copdef labels (`W, E, Here`) wrong"). (b) Line 10 says the outer slot is taken when the player is "more than 15 px" away. The handler compares `|Δ|` with `CMP [$0A]` and `BCC` to the centre slot (`cop_handlers_player_query.asm:203-212`), so `|Δ| = 15` already takes the outer slot: "15 px or more". Also line 11 cites OQ-I037-3 (class 7). Fix: `merge` spec for the block note: remove "and the copdef", change to "15 px or more", drop the id. Step: F07.

**A03-03** (VERIFIED, class 5 and 3). `docs/cop/families/player_query.md` is still wrong for the two branch rows. `:45-46` list `&Code W, &Code E, &Code Here` / `&Code N, &Code S, &Code Here`, the handler order is W / Here / E and N / Here / S. `:141` cites handler lines `181-206`, the live handler is `193-218`; `:178` cites `211-236` (the Y handler follows the X handler at `:221+`, not re-read). `docs/cop/README.md` rows REPORTED (R-I037-5(c)). Fix: docs edit (A11 owns docs rows). Step: A11.

**A03-04** (VERIFIED, class 3). `interaction_handlers.asm:13` (block-note item 6) describes labels that no longer exist: "`*AlignWest / *MoveWest` and `*AlignEast / *MoveEast` are the vertical blocks…". R-I037-2 renamed the family (`names/bank00.json:734-743,750-759`: `CollectGemAlignPlayerNorth/South/West/East`, `PushSolidMovePlayer*`); rg for `AlignWest|AlignEast|MoveWest|MoveEast|AlignNorth|AlignSouth` in the file hits only line 13. Item 5 (`:12`) also narrates ("the 'push' in the old names and header was a guess") and `:17` ("The old header said it nudges the player"). The note should now state the naming rule (named by where the player stands) and the dead-branch fact, without the old names. Fix: `merge` block-note spec. Step: F07.

**A03-05** (VERIFIED, class 6). An undocumented dead branch in `ramps.asm`. `RampEastWatch` window code: `BMI loc_00D30A` (`:102`), then at the target `BPL loc_00D310` (`:106`) sits right after a taken `BMI`, so N is set and the `BPL` is never taken; the `EOR #$FFFF / INC` (`:107-108`) always runs. `interaction_handlers.asm:13,61` document the same pattern; `ramps.asm` does not. Same pattern in the other three ramp watch blocks (not re-read, REPORTED). Fix: one inline comment per site or one line in the block note. Step: F07.

**A03-06** (VERIFIED, class 6 and 3). `hdma_circle_window_thinker.asm` contradicts itself on the first frame. `:18` ("so the first frame always builds") and `:73` ("so the first frame rebuilds") versus `:667` ("reports a change whenever the scene has set any non-zero parameter"). The code agrees with `:667`: `HdmaInitPrevState` stores zeros (`:669-674`), `HdmaCompareParams` returns carry set when all three words match (`:679-690`), so an all-zero parameter set builds nothing on the first frame. Fix: change `:18` and `:73` to the conditional form. Step: F07.

**A03-07** (VERIFIED, class 3 and 7). `SpawnDebrisBurst.asm:3` says flags `$0302`: "`$0100` and `$0002` are undecoded". `StandardEnemyDefeatHandler.asm:6,75` decodes bit `$0002` as "draws it in front of every actor". The same line cites OQ-I030-2 (class 7). Line 5 narrates ("The older header named only the first two") and compares against a docs file. Fix: `merge` spec: bit `$0002` decoded; drop the id and the narration. Step: F07.

**A03-08** (VERIFIED, class 3 and 4). `StopPlayerOnDeath.asm:5` quotes `docs/wram-memory-map.md` as listing "`$0200 deathFlag, set by StopPlayerOnDeath`". `docs/` has no `deathFlag` (rg, 0 hits), so R-I032-4 was applied and the note quotes a dead entry. The sentence also narrates ("the old claim that it 'freezes movement'"). The same text sits in `notes/blockNotes/bank00.json:138` (REPORTED from the rg line). Root cause still live: mnemonic `deathFlag` = `$0200` (`mnemonics.json:9`) names a depth-bucket array (`sprite_composition.asm:62,94,100,247,250,264`; `QuintetLzDecompress.asm:24`), not a death flag (A02-01, class 10). Fix: `merge` spec for the note and the block note; mnemonic decision in A14. Step: F07, A14.

**A03-09** (REPORTED, class 2). `RandomPlayerOffset.asm:4,18` says `$08 = $3C` makes the actor "sleep 60 frames" and "hops every 60 frames". By the runner semantics established in A02-04 (`WaitByte(n)` = n + 1 ticks) a stored wait counter of `$3C` is 60 skipped passes, so the entry runs again on the 61st tick. Not re-read against the runner in this step; check `cop_handlers_wait.asm` and the actor runner before editing. Fix: `merge` spec (61 ticks) after the check. Step: F02.

**A03-10** (VERIFIED, class 4). History narration remains in the I031..I040 file set: 27 lines in 22 files, plus 39 more lines in `system/player/` that are not split by iteration.
- `thinkers/`: 9 lines in 7 files: `hdma_circle_window_thinker.asm:3,565`; `sine_hdma_slow_wave.asm:3`; `ambient_palette_cycler.asm:5`; `oneshot_coldata_r11g4b2.asm:3,5`; `oneshot_coldata_warm_flash.asm:5`; `flag_gated_palette_warm.asm:14`; `flag_gated_palette_cool.asm:13`.
- `functions/`: 9 lines in 8 files: `RandomPlayerOffset.asm:4`; `ActorMidpointCalc.asm:4`; `EnemyInitBasic.asm:1`; `ActorDisplayModeSwap.asm:10`; `StopPlayerOnDeath.asm:5`; `EnemyDeathFlash.asm:7`; `SpawnDebrisBurst.asm:5`; `SetPlayerIdleFacing.asm:5,29`.
- `actors/`: 8 lines in 6 files: `slope_ramp_physics.asm:34`; `large_ramps.asm:6`; `interaction_handlers.asm:12,13,17`; `idle_sprite_display.asm:3`; `camera_delta_oscillator.asm:3`; `ramps.asm:1`.
- `system/`: `inventory_overlay.asm:16` (1 line); `sFB_boot_logo.asm:29`; `system/player/` regex hits: `player_move_east` 15, `player_move_south` 7, `player_move_ramps` 6, `player_move_main` 6, `player_move_ns` 5 (39 lines, five files; they mix I029, I030, I033, I038-I040).
- Out of range (hits seen, pass to A04/A05): `global_ambient_dispatcher.asm` (11 lines), `gold_ship_wreck_palette.asm` (2), `mode7_perspective.asm` (1), `oneshot_palette_flash_18.asm` (1).
A02-09 listed the same pattern for I021..I030 (17 lines in 11 files). Fix: `merge` specs removing the narration clauses and keeping the technical content, batched with A03-11. Step: F07.

**A03-11** (VERIFIED, class 7). Ids in extracted note and comment text. OQ-I031..I040 ids: 33 lines in 14 files: `inventory_overlay.asm` 7 (`:18,117,166,177,178,179,383`), `player_move_south.asm` 8, `player_move_ns.asm` 6, `sFB_boot_logo.asm` 2 (`:5,49`), and 1 each in `ActorMidpointCalc.asm`, `idle_sprite_display.asm`, `camera_delta_oscillator.asm`, `player_move_ramps.asm`, `interaction_handlers.asm`, `ramps.asm` (`:41`, cites OQ-I032-5), `large_ramps.asm`, `oneshot_coldata_r11g4b2.asm`, `oneshot_coldata_warm_flash.asm`, `palette_parent_child.asm`. Pointers to the ledger: `debug_stat_setter.asm:5` and `scanline_band_hdma_thinker.asm:65` ("see the questions file"). Out of range: `mode7_perspective.asm:52-53,84` (OQ-I041-1/-3). Fix: `merge` specs replacing each id by the plain open-question statement (the OQ document keeps the id). Step: F07; policy in report.md N-series.

**A03-12** (VERIFIED, class 3). Residue of R-I035-1. `mode7_perspective.asm:52` names "buffers of parallax_thinker" and `notes/blockNotes/bank03.json:15` (same block) still says "RunThinkers_TypeB" (live name `RunThinkers_Hdma`, A02-02) and carries the old block name (rg hit on the line). `extracted/`, `db-us/` and `docs/` have no other `parallax_thinker`. The apply summary says all old names are gone; they are not (class 3, ledger errata AP-22). Fix: `merge` spec on the `mode7_perspective` note (A04 owns the file). Step: F07.

**A03-13** (VERIFIED, class 10). 15 PROPOSED rename rows and one partial row are not applied, so these nicknames and misleading names are live: `FineAdjustXEast/West` (names the wall side, reads as direction), `ActorDisplayModeSwap` (does not swap a display mode), `oneshot_coldata_warm_flash`, `idle_sprite_display`, `push_handler_solid/forceball` (they pull), `EnemyInitBasic` (two callers only), `RandomPlayerOffset` (a marker actor), `EastRampDown/Up`, `WestRampUp/Down`, `camera_delta_oscillator`, `NorthProbeRedirect`, `NorthSlopeRight/Left`, `flag_gated_palette_*`, `loc_02B76C`. Ten of them wait on an OQ (§2). R-I032-2 is DROPPED by design (changes ROM bytes), and `slope_ramp_physics.asm` still carries the duplicate `ReadDecelerationStepNS`. Fix: user decision per gated row, then a `names` spec. Step: F06 (after the OQ owner decides).

**A03-14** (VERIFIED, class 9 and 10). Q5 rows R-I035-4 and R-I036-4 are not applied. `mnemonics.json:67-69` still names `$068C/$068E/$0690` `effectScrollH/mapScrollV/effectScrollV` (the live note in `scanline_band_hdma_thinker.asm:22` has to explain that they are BG2 H, BG1 V, BG2 V). `mnemonics.json:241-242` `orbitAngle/orbitDiameter` are used by `ramps.asm` for the arc curve offset and exit speed (R-I036-4) and by `interaction_handlers.asm:17` as a step counter. At least 151 files in `extracted/` carry a `!mnemonic` line for one of the 11 names `deathFlag, effectScrollH, mapScrollV, effectScrollV, orbitAngle, orbitDiameter, moveXAlt, moveYAlt, iframeCounter, chatPtr, playerStateByte` (the rg listing stopped at 60 of at least 151; lower bound, no per-line count). Two more misleading live names found in the A03 files: `playerStateByte` (`system_core.asm:411` comment: "bit 1 = playerFlags bit 9") and `chatPtr` (an item id in `idle_sprite_display.asm:18`, a child slot in `palette_parent_child.asm`). Fix: A14 consolidation, then a mnemonic spec. Step: A14, F06.

**A03-15** (informational). I037 was run before I035/I036 and never cites them (§6). No ledger statement of I035/I036 is contradicted by I037, and no I037 statement is contradicted by them. Two I037 statements are corrected here (A03-02).

**A03-16** (informational, class 12). No note in the I031..I040 files sits next to a multi-line transform regex (§8).

## 6. I035/I036-after-I037 ordering effects

Evidence for the order: `results/I037_results.md:6` says "I035 and I036 were skipped at the user's request"; the I037 ledgers contain no reference to `I035` or `I036` (rg, 0 hits). I035/I036 were written later against the same tree, so each of them could in principle restate or contradict an I037 fact. For each shared fact, the statement that is current in the live tree:

| Fact | I035 / I036 statement | I037 statement | Relation | Current statement (evidence) |
|---|---|---|---|---|
| `LoopEnd` timing | I036: the `LoopEnd` return address is stored in `retPtr2`; the climbs run one `LoopEnd` pass per frame (`ramps.asm:483,513,570`) | OQ-I037-2 asks whether `LoopEnd` yields once per pass | I036 pre-answers I037's question; no contradiction | `LoopEnd` decrements and, until zero, sets `$00` to the loop head and yields, so at least one frame per pass (`cop_handlers_script_control.asm:7,260`, VERIFIED). OQ-I037-2 first half is answered. I036 is current |
| Child `$04` link | I036: the child's `$04` is the player (`ramps.asm:24`, `AllocateActorAfter`) | I037: the child's `$04` is the marked actor (`interaction_handlers.asm:3`) | Agree; one list rule | `$04` = previous, `$06` = next in the actor list (`actor_pool.asm:5,155-156`). Both current |
| `BranchOnPlayerX/Y` slots | I036: not used (the ramps compare coordinates by hand) | I037: W / Here / E; copdef and docs labels wrong | No overlap | Handler order W / Here / E (`cop_handlers_player_query.asm:193-218`). I037's "copdef" part is wrong (`copdef.json:44-45`); the doc is stale (A03-03) |
| Dead `BPL` after `BMI` | I036 `ramps.asm`: not documented (A03-05) | I037 documents the same pattern in `interaction_handlers.asm:13,61` | I037 refines a pattern I036 missed | Both are real: `ramps.asm:102-108`, `interaction_handlers.asm:60-61`. Only I037's is documented |
| Naming scheme for direction | I036: names by the ramp's own side (`RampEastWatch`, `RampClimbNorthStep`) | I037 R-I037-2: names by where the player stands (`…PlayerNorth`) | Different objects, not a contradiction; two conventions in one tree | Both live (`names/bank00.json:54482-54635`, `:734-759`). The two meanings of "North" (movement direction vs player position) are not stated in any note |
| `$0E` meaning | I036: `$0E` derived from the scene-data type byte (`InitActorFromSceneData`) | I033 (before I035): `$0E` is an OAM XOR word | Both true, one per mode | `actor_execution.asm:957-972`: OAM word or `byte2 >> 1`. `ActorDisplayModeSwap.asm` note carries both readings. Both current |
| Player actor `$10` bit `$0200` | I036 (OQ-I036-4): ramps set it, no reader found; also set by `StopPlayerOnDeathAssign` | I037: `$12` bit `$0010` is stagger immunity (a different word) | No overlap | Unchanged: no reader found; `ramps.asm:41` and `StopPlayerOnDeath.asm:5` agree; renamed routine now `StopPlayerOnDeath` (`names/bank00.json:62387`) |
| `$FF` latch | I036: the scene-setup-complete latch cleared by `scene_lifecycle` and the inventory overlay | I037: not mentioned | No overlap | Consistent with I034 (`inventory_overlay.asm:34`) and `flag_gated_palette_warm.asm:10` |
| `hpToHeal` reader | I035: none found | I037: not touched | I035 stands alone | **Wrong** (A03-01). `system_core.asm:416-424` |
| `EnemyInitBasic` / `RandomPlayerOffset` | I035/I036: not touched | I037: two callers, marker actor | No overlap | I037 counts re-verified (§4 checks 16, 17) |

**Result:** no I035/I036 fact is contradicted by I037, and no I037 fact is overturned by I035/I036. Three I037 statements need correction for other reasons (copdef labels, "more than 15 px", item 6 labels). The one case where order mattered is the dead-branch pattern: I037 documented it in `interaction_handlers.asm`, but I036 (later) did not apply the lesson to `ramps.asm`. Because I037 ran first, I036's ledger could have cited the pattern and did not.

## 7. Defect-class sweep over the A03 file set

Class numbers follow PLAN.md.

| Class | Result |
|---|---|
| 1 purpose guessed from label | no new case; the live notes mark the unverified purposes (`EnemyDeathFlash.asm:7` "not verified"); R-I036-6 `kara_news_palette_*` is flagged low confidence by its own row |
| 2 WaitByte n vs n+1 | 0 live errors where `WaitByte` is used (`SpawnDebrisBurst` right, 5 ticks); 1 candidate with a raw wait counter (A03-09, REPORTED) |
| 3 stale comment after rename or finding | 7 cases: `interaction_handlers.asm:13`, `debug_stat_setter.asm:5`, `SpawnDebrisBurst.asm:3`, `StopPlayerOnDeath.asm:5`, `hdma_circle_window_thinker.asm:18,73`, `mode7_perspective.asm:52`, `blockNotes/bank03.json:15` |
| 4 history narration | 27 lines in 22 files in the A03 set, 39 more in `system/player/` (A03-10) |
| 5 table row of a different handler | 1 doc case: `player_query.md:45-46` (A03-03); the extracted files have no opcode tables in this range |
| 6 comment contradicting code | `hdma_circle_window_thinker.asm:18,73`; `interaction_handlers.asm:10` (off by one); dead `BPL` undocumented in `ramps.asm:106` |
| 7 OQ/R ids in note text | 33 lines in 14 files, plus 2 "questions file" pointers (A03-11) |
| 8 hidden sprite groups | not checked: `EnemyDeathFlash` sprite groups (OQ-I031-5) were not opened |
| 9 unnamed fixed-address operands | `$06CC`, `$00B2` in `inventory_overlay.asm:178-179` (documented as unnamed), `$7F0B22/24` in `mode7_perspective` (out of range); mnemonic backlog A03-14 |
| 10 retired nickname in a name | 15 PROPOSED rows (A03-13), `deathFlag`, `chatPtr`, `playerStateByte` (A03-14) |
| 11 wrong flag/hardware/branch/answer | `hpToHeal` no-reader claim (A03-01); the "copdef labels" claim (A03-02); hardware claims (COLDATA, NMITIMEN, HDMA modes) all hold |
| 12 transform adjacency | none live (§8) |
| 13 button names | `interaction_handlers.asm:8` mask `$0031` = joypadRaw + L/R pair is the post-remap reading (REPORTED, not re-derived); no error found |

Hedge words ("probably", "likely", "inferred", "unclear", "UNVERIFIED-RUNTIME") occur in at least 9 files of the set (`large_ramps`, `camera_delta_oscillator`, `idle_sprite_display`, `RandomPlayerOffset`, `SpawnDebrisBurst`, `ActorDisplayModeSwap`, `flag_gated_palette_warm`, `hdma_circle_window_thinker`, `ramps`). I did not classify them one by one. REPORTED.

## 8. Transform-adjacency inventory (class 12)

Rules in `db-us/transforms.json` that apply to files of I031..I040 (block key and line):

| Block (file) | Rule | What a note or comment could break | Live state |
|---|---|---|---|
| `dm43_elevator` (`:287`), `av74_kara` (`:212`, `$FFF0`), `st68_lily` (`:218`), `dc31_kara` (`:377`), `it15_lola` (`:686`), `it15_lily` (`:692`, two rules incl. `LDA #\$6000…→$2008`), `sc02_seth` (`:712`), `sc06_lily` (`:718`), `sc06_kara` (`:736`): 9 of the 14 `SetPlayerIdleFacing` caller files | `LDA #\$XXXX([^\r\n]*\s+T[SR]B \$joypadMaskStd)` | a label or comment-only line between `LDA` and `TSB/TRB` stops the rewrite | not touched by any A03 note I read. rg for `$CFF0/$EFF0/$FFF0` in `extracted/` returns at least 113 lines; I viewed the first 15 only (spawn operands, `AND #$FFF0`, and two notes that quote the literal on purpose: `sFB_boot_logo.asm:29,59`, `sFC_title_start_handler.asm:5`). The rest is REPORTED, not reviewed |
| `sc02_erik` (`:709`), `sc06_monologue` (`:727`), `unused_mode7_boss` (`:559`), `game_over_sequence` (`:383`, `([CF])FF0`) | same joypad-mask rule | same | same |
| `combat_collision` (`:495`), `actor_execution` (`:498`) | `\$8000` → `$0080`, **unanchored and global per block** | every `$8000` in notes or comments of the extracted text is rewritten too | `StopPlayerOnDeath`/`CheckPlayerDeath` notes (`combat_collision.asm:162`) contain no `$8000`. Other notes in these two blocks were not checked (the I001..I020 notes there use `$0080` for bit 7 on purpose, `combat_collision.asm:17,24,126,136`). Same hazard class as A02-03 |

**No A03 note sits next to a multi-line regex.** The one latent hazard is the unanchored `$8000` rule in `combat_collision` and `actor_execution`; an A15 transform guard should cover it.

## 9. Not verified / needs Mesen2

- Every behavioural claim is static. No Mesen2 ROM or state exists. Runtime-only: about 38 of 57 questions, including the on-screen look of the parallax types and bundles, the ramp launch distances, the `$03/$0C` slow-down and every "does it feel like" question.
- `RandomPlayerOffset` 60 vs 61 ticks (A03-09): needs the actor runner and the `WaitByte` handler read together.
- `ActorDisplayModeSwap`: "24 of 25 caller headers start with `$1000/$1800`" was not re-checked; only the site and file counts were.
- Scene counts in the `scanline_band_hdma_thinker` table (53 of 81 scenes use type `$02`) need a list-to-scene map; only the spawn records (3 records of `#02`, 30 spawns in total) were counted.
- The four ramp watch blocks other than `RampEastWatch` were not re-read for the dead `BPL` (A03-05).
- `apply-I021-I040_map.json` and `apply-I021-I040_plan.md` were not read; the 20 APPLIED rows were verified against `names/*.json`, `blocks.json` and `extracted/`.
- Docs rows (R-I033-4, R-I034-4, R-I035-8, R-I036-7, R-I037-5 except (c), R-I038-4 except (a), R-I039-4, R-I040-4) were not re-opened; A11 owns them.
- `notes/blockNotes/bank00.json:138` and `bank03.json:15` were seen only through rg line hits.

## 10. Items for the fix specs

| Item | Content | Step |
|---|---|---|
| I-1 | A03-01: rewrite `debug_stat_setter.asm:5` (reader exists, drop the pointer) | F07 |
| I-2 | A03-02: `interaction_handlers` note, lines 10-11 (copdef claim, "15 px or more", id) | F07 |
| I-3 | A03-04: `interaction_handlers` note, items 5-6 and `:17` (new label rule, no old names) | F07 |
| I-4 | A03-05: document the dead `BPL` in the four `ramps.asm` watch blocks | F07 |
| I-5 | A03-06: `hdma_circle_window_thinker.asm:18,73` first-frame wording | F07 |
| I-6 | A03-07, A03-08: `SpawnDebrisBurst.asm:3,5`, `StopPlayerOnDeath.asm:5` and `blockNotes/bank00.json:138` | F07 |
| I-7 | A03-09: after the runner check, 61-tick wording in `RandomPlayerOffset` | F02 |
| I-8 | A03-10, A03-11: remove narration clauses and ids from 22 + 14 files; batch with I-2..I-6 | F07 |
| I-9 | A03-12: `mode7_perspective.asm:52` and `blockNotes/bank03.json:15` (old block name, `RunThinkers_TypeB`) | F07 (with A02-02) |
| I-10 | A03-13: decisions for the 10 gated PROPOSED rows; then a `names` spec | F06 |
| I-11 | A03-14: R-I035-4 / R-I036-4 mnemonic rows plus `playerStateByte`, `chatPtr` | A14, F06 |
| I-12 | A03-03: `player_query.md:45-46,141,178` and `docs/cop/README.md` | A11 |
| I-13 | §8: guard for the unanchored `\$8000` rules in `combat_collision` and `actor_execution` | A15 (AP-18) |
| I-14 | Ledger errata: OQ-I035-6 premise (reader exists), OQ-I037-3 premise (copdef has no labels), apply summary "all old names gone" (`parallax_thinker` in two places) | A12 / digest erratum (AP-22) |

## 11. Counts

- Rename rows: 48 = 20 APPLIED (1 with residue), 1 PARTIAL, 15 PROPOSED, 9 DOCS, 1 DROPPED, 2 KEEP, 0 SUPERSEDED. Q5 rows: 2, both PROPOSED. Gated rows: 10 of 15 PROPOSED.
- Open questions: 57. Answered or confirmed statically: 8 (two with a wrong ledger premise: I035-6, I037-3); partly: 3; duplicates in 3 clusters; runtime-only about 38.
- Fact checks: 35 (29 correct, 4 partly wrong or stale, 2 wrong) in about 35 files, 10 defect classes.
- Ordering effects: 9 shared facts compared; 0 contradictions; 3 I037 statements corrected for other reasons; 1 pattern not carried over (dead `BPL`).
- Findings: 16 entries (A03-01 … A03-16): 14 defects (A03-01 … A03-14), 2 informational (A03-15, A03-16). New live defects not in any ledger: A03-01 (reader exists), A03-02 (copdef claim, off by one), A03-04 (item 6 stale after the rename), A03-05 (dead `BPL` in `ramps`), A03-06 (circle first frame), A03-07 (`$0002` decoded elsewhere), A03-08 (docs entry gone), A03-12 (`parallax_thinker` residue).
- Sweep: class 3 stale 7 cases; class 4 narration 27 lines in 22 files (+39 in `system/player/`); class 7 ids 33 lines in 14 files (+2 pointers); class 2 live errors 0 (1 candidate); class 12 live hazards 0 (1 latent); class 13 errors 0.
