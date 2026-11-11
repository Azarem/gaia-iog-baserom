# A02 findings: iterations I021–I030

Step A02 of the audit of the audit. Scope: results, renames, questions and edits of I021..I030, checked against the live tree. Nothing was edited except the A02 row of `PLAN.md`. All evidence is static (E1–E4). There is no Mesen2 ROM or save state, so no E5 claim appears below.

Tags: **VERIFIED** = checked in the live files in this session (file:line given). **REPORTED** = taken from a ledger and not re-checked.

## 1. Scope and files read

Ledgers, read in full unless noted:
- `results/I021..I030_results.md`, `results/I021-I040_sanity-check.md`.
- `renames/I021..I030_renames.md`, `renames/apply-I021-I040_summary.md`, `apply-I021-I040_plan.md`. `apply-I021-I040_map.json` (191 pairs) was **not** read.
- `questions/I021..I030_questions.md`. `edits/I024_MenuSelectionHandler_PROPOSED.json` (the other `edits/I0nn.json` files were searched, not read).
- `digest_I021-I040.md`, `report.md` v2, `PLAN.md`.

Live files read or searched (32-file sweep set; the files I021..I030 audited plus the cross-file edits): `hdma_dma_spc`, `QuintetLzDecompress`, `thinker_execution`, `cop_handlers_sprite`, `spc_transfer`, `vblank_joypad`, `slider_glide`, `cop_handlers_player_sprite`, `cop_handlers_metatile`, `system_init`, `MenuSelectionHandler`, `map_coords`, `player_character`, `NpcDespawnStub`, `f_inventory_full`, `item_use_system`, `FlickerParentActor`, `DeathPaletteFadeThinker`, `attack_ability_system`, `oneshot_palette15_grey_fade_in_1F`, `oneshot_backdrop_fade_out_fast_40`, `oneshot_backdrop_fade_in_1B`, `oneshot_backdrop_fade_out_1C`, `oneshot_palette_flash_19`, `oneshot_palette_flash_18`, `inventory_menu`, `player_move_west` (`extracted/system/player/`), `tile_collision`, `SetPlayerGameOverFlag`, `scene_flag_init`, `cop_handlers_audio`, `cop_handlers_palette`. Also read: `awB2_stair_climb`, `body_table`, `cop_handlers_wait`, `cop_handlers_vram`, `system_core`, `scene_lifecycle`, `sprite_composition` (grep), `GetPlayerFacingDirection` (grep), `tables/scene_actors`, `thinkers/mode7_perspective` (grep).
Databases: `db-us/names/bank00..03.json`, `bank0A.json`, `bank01.json`, `mnemonics.json`, `copdef.json`, `transforms.json` (grep, with blocks read for `inventory_menu`, `slider_glide`, `MenuSelectionHandler`, `item_use_system`, `attack_ability_system`), `notes/comments/bank00.json` (key 47052). Tooling: `src/merge.ts:248`, `gaia-core/docs/notes-and-comments.md` §merge validation (1296–1320).

Procedure slip, disclosed: I ran `wc -c` once for file sizes early in the step. It is read-only and outside the permitted shell list. Everything else used Grep, Glob and Read.

## 2. Per-row status table (rename rows and Q5 rows)

Statuses: APPLIED (verified live), DOCS (documentation-only row), PROPOSED (not applied; evidence given), SUPERSEDED, DROPPED. No row is SUPERSEDED or DROPPED. "Q5" marks mnemonic, copdef and struct rows.

| Row | Subject | Status | Live evidence |
|---|---|---|---|
| R-I021-1 | `DecompressGfxToVram` → `CopyPaletteBundleFrame` | APPLIED | `names/bank03.json:384`; no old name in `extracted/` (rg) |
| R-I021-2 | `LzReadBackRef` → `LzReadNibble` | APPLIED | `names/bank02.json:16` |
| R-I021-3 (Q5) | new mnemonics `blockMoveStub`, `vramDmaSrc/…Size` | PROPOSED | no such key in `mnemonics.json`; `$0402`, `$AC..$B2` still bare operands |
| R-I021-4 | `RunThinkers_TypeA..D` → `General/Hdma/General_Light/Hdma_Light` | APPLIED, **incomplete** | `names/bank03.json:330,332,334,336`; the four `…_Next` sub-labels still carry `TypeA..D` (331,333,335,337), see A02-02 |
| R-I021-5 | `SpcCheckMusicReady` → `SpcFadeOutHandshake` | APPLIED | `names/bank03.json:388` |
| R-I021-6 | palette-bundle docs/header ("compressed") | DOCS, header APPLIED | `extracted/tables/palette_bundles.asm:1` corrected; `docs/structs-reference.md:1143` uses the new name; the other three docs REPORTED |
| R-I021-7 (Q5) | `deathFlag` → `depthBucketArray` | PROPOSED | `mnemonics.json:9`; `sprite_composition.asm:62,94,100,247,250,264` use `$deathFlag` |
| R-I022-1 | `EnableNmiOnly` → `DisableNmiKeepJoypad` | APPLIED | `names/bank02.json:6`; `scene_lifecycle.asm:195` |
| R-I022-2 (Q5) | COP `ResetSpriteState`, `SetMetasprite` renames | PROPOSED | `copdef.json:87,120` unchanged |
| R-I022-3 (Q5) | `moveXAlt/moveYAlt` → `moveXIndex/moveYIndex` | PROPOSED | `mnemonics.json:245-246`; `attack_ability_system.asm:931` uses both as a position queue (repurposed field), so the proposal needs a per-site check |
| R-I022-4 | six SPC auto labels | APPLIED | `names/bank02.json:64-70` (6 entries) |
| R-I022-5 | docs rows (`EnableNmiOnly` text) | DOCS | REPORTED (docs not opened; belongs to A11) |
| R-I022-6 | docs rows (movement durations) | DOCS | REPORTED |
| R-I023-1 | `stair_climb` / `StairTrigger*` → `slider_glide` / `SliderGlide*` | APPLIED | `names/bank00.json:600-610`; no `StairTrigger`/`ClimbSouth` in `extracted/`; the actor label `awB2_stair_climb` remains (A02-06) |
| R-I023-2 | `CheckMoveState` → `IsPlayerSliderSpriteBank` | APPLIED | `names/bank00.json:607`; `slider_glide.asm:259-273` |
| R-I023-3 (Q5) | `climbStateData` → `abilityDamageBonus` | PROPOSED | `mnemonics.json:156-157`; 25 live lines (counts in §6) |
| R-I023-4 (Q5) | COP `RunPlayerAnim` documented as alias of `AnimOnce` | PROPOSED | `copdef.json:131` has no alias marker |
| R-I023-5 (Q5) | `tileQueryResult` → `pendingMetatileVram`, five unnamed words | PROPOSED | `mnemonics.json:131`; `cop_handlers_metatile.asm:6` calls the live name "a misnomer" |
| R-I023-6 (Q5) | COP `WorldMapStream3/4` → `PaintTileStream3/4` | PROPOSED | `copdef.json:79-80` |
| R-I024-1 (Q5) | `$06B0` → `metatileDefBase+2` | PROPOSED | `system_init.asm:212` still `wram-init < $06B0, … >` |
| R-I024-2 (Q5) | `$0B04` → `savedDialogFrameDelay` | PROPOSED | `system_init.asm:237` still `$0B04` |
| R-I024-3 | move `UploadCgramPalette/UploadOamTable` out of `system_init` | PROPOSED | callers still use `@system_init.UploadCgramPalette` (`system_core.asm:561-562`, `camera_tilemap.asm:142`, `inventory_overlay.asm:162`) |
| R-I024-4 | four `MenuSelectionHandler` auto labels | APPLIED | `names/bank03.json:432-435` |
| R-I024-5 (Q5) | eight menu-state mnemonics | PROPOSED | 0 hits in `mnemonics.json`; `MenuSelectionHandler.asm:14,36,54,87,102,113` still use bare `$0990/$0992/$0994` |
| R-I024-6 | anchor `MenuSelectionHandler` transforms, drop the merge guard | PROPOSED (gating OQ-I024-1) | `transforms.json:522-526` unchanged; guard live at `src/merge.ts:248-249` |
| R-I025-1 (Q5) | `invincibilityTimer` → `walkRunWindowTimer` | PROPOSED | `mnemonics.json:12`; 20 live lines (§6) |
| R-I025-2 | `RangedAttack*` / `RangedSetForce*` → `Lunge*` | PROPOSED | `names/bank02.json:355-358` unchanged; 17 lines in `player_character.asm` |
| R-I025-3 | `NullActorScriptStub` → `NpcDespawnStub` | APPLIED | `names/bank00.json:690` |
| R-I025-4 | `DisableStatusForAttack/RestoreStatusDisplay` | APPLIED | `names/bank02.json:340,342` |
| R-I025-5 | docs rows (`$040C`, camera shake, `Ranged*`) | DOCS | digest: `hit-blink immunity` no longer matches (REPORTED) |
| R-I025-6 (Q5) | `climbStateData` → `willAbilityBonus/freedanAbilityBonus` | PROPOSED | same keys as R-I023-3 (two rows, one mnemonic: **conflicting targets**, see A02-01) |
| R-I025-7 | docs rows (`NullActorScriptStub` section) | DOCS | REPORTED |
| R-I026-1 | `ToggleActorVisibilityFlag` → `FlickerParentActor` | APPLIED | `names/bank00.json:502` |
| R-I026-2 | three Inca mantel labels | APPLIED | `names/bank03.json:18,19,22`; `transforms.json:532-533` use the new names |
| R-I026-3 | four Flute labels | APPLIED | `names/bank03.json:28,64-66` |
| R-I027-1 | `DarkFriarTrailSouthInit` → `…NorthInit` | APPLIED | `names/bank02.json:213` |
| R-I027-2 | `oneshot_palette_flash_40/1F` → `…fade_out_fast_40`, `…palette15_grey_fade_in_1F` | APPLIED | both files exist under `extracted/thinkers/` |
| R-I028-1 | `item_table_separator` → `non_discardable_item_bits` | APPLIED | `names/bank01.json:484` |
| R-I028-2 | `StatusCharRow3/2/1` → `StatusAbilityRow0/1/2` | APPLIED, **stale text left** | `names/bank02.json:503-505`; old name still in `inventory_menu.asm:113,143` (A02-05) |
| R-I028-3 | eight `inventory_menu` labels | APPLIED | `names/bank02.json:469,476,477,479,484-486,499` (all eight names present) |
| R-I028-4 | `oneshot_palette_flash_1B/1C` → `…backdrop_fade_in_1B`, `…out_1C` | APPLIED | both files exist |
| R-I029-1 | `DiagRamp*` → `WestRampDescend/Ascend` and edges | APPLIED | `names/bank02.json:430-434` |
| R-I029-2 | `player_move_diag` → `player_move_west`, `DispatchWestMove`, … | APPLIED | `names/bank02.json:425-426,437`; file `system/player/player_move_west.asm` |
| R-I029-3 | `DiagPush*`, `DiagClearReturnFlags`, `DiagAutoAlignNS` | APPLIED | `names/bank02.json:436,438-440` |
| R-I029-4 | optional `oneshot_palette_flash_18/19` rename | PROPOSED (optional) | block names unchanged |
| R-I029-5 | docs statements | DOCS | REPORTED |
| R-I030-1 | `SetPlayerGameOverFlag` → `SetPlayerHitImmuneFlag` | PROPOSED (gated on OQ-I030-2) | `names/bank0A.json:14` unchanged |
| R-I030-2 | `scene_flag_init` → `scene_set_flag_00` | PROPOSED (gated on OQ-I030-1) | `names/bank00.json:481` unchanged |
| R-I030-3 | docs and caller comments | DOCS | REPORTED |

**Counts (49 rows):** APPLIED 23 (names/blocks), DOCS 7, PROPOSED 19, SUPERSEDED 0, DROPPED 0.
**Q5 rows: 13 of 13 PROPOSED, none applied** (R-I021-3, -7; R-I022-2, -3; R-I023-3, -4, -5, -6; R-I024-1, -2, -5; R-I025-1, -6). VERIFIED against `mnemonics.json` and `copdef.json`. This feeds A14.

## 3. Open questions of I021..I030 (54 questions)

"Answered later" means a later ledger row, note or live code gives the answer. None is answered by a runtime check. I do not answer any OQ here; the evidence column only locates what exists.

| OQ | Question (short) | Answered later? Where |
|---|---|---|
| I021-1 | Do all `QuintetLzDecompress` callers reach `ClearActorRenderList`? | Not in a ledger. Half visible in code: the Decompress COP clears right after (`cop_handlers_vram.asm:164-165`, VERIFIED). The 8 `scene_script` sites are not traced. Open for them |
| I021-2 | Does `$01` reset the SPC fade counters (fade inaudible)? | No (runtime) |
| I021-3 | Are `$F0/$F2` labels in `scene_script` wrong? | No; assigned to a `scene_script` revisit (F01) |
| I021-4 | Which spawned thinkers lack bit 11? | No (77 spawn sites unenumerated) |
| I022-1 | Who sets/clears `$12` bit 1 (mirror lock)? | No |
| I022-2 | Is the first sample chunk destination always the next free ARAM word? | No (only first track parsed) |
| I022-3 | Does the SPC loader reset DSP/echo before upload? | No (runtime) |
| I022-4 | Which `VBlankWaitAndJoypad` callers run with NMI off? | No |
| I023-1 | What do the 29 glide triggers do in the game? | No; `awB2_stair_climb` header still says "stair" (A02-06) |
| I023-2 | Does anything read the player's `statsPtr` after a glide? | No |
| I023-3 | Who reads actor `$10` bit `$0200`? | Re-asked as OQ-I027-2 and OQ-I030-2 (same bit); not answered |
| I023-4 | Who places the six `item_use_system` metatile actors? | No |
| I023-5 | Are `WorldMapStream3/4` dead; does anything set `extendedFlags` bit 2? | No |
| I023-6 | Does clearing `$10` bit `$0008` change anything while `$2000` is set? | No (runtime) |
| I024-1 | How to let `MenuSelectionHandler` take notes? | No; gate still live (`src/merge.ts:248`), proposed notes unmerged (A02-03) |
| I024-2 | Readers of `$0B14`, `$5E/$60/$62`, `gfxCacheIdxA`? | No |
| I024-3 | Who reads `$090E/$0910`; who consumes `displayModeFlags` bit 0? | No |
| I024-4 | Is the first `MEMSEL = 1` dead on purpose? | Partly: the notes now state the sequence (`system_core.asm:141,169`; `system_init.asm:14,371`, VERIFIED). Intent still open |
| I024-5 | Why do `DispatchEastMove`/`DiagDownLeft` call `ProbeLeft/RightTiles`? | Partly via the I029 rewrite (west/east files); not stated as an answer |
| I024-6 | Who writes `$7F0C00-02` and in what format? | No |
| I025-1 | Meaning of `$10` bit `$0100`, `$12` bit `$0001`? | No |
| I025-2 | Who sets `$10` bit `$2000` of the player? | Overlaps OQ-I026-6; not answered |
| I025-3 | Does a second press within 13 frames start a run? | Static reading in `player_character.asm:12,294-308,475-477` (VERIFIED); window length ±1 untested (§5, F13) |
| I025-4 | `AttackNorth` tests `BranchIfSolidSouth`: bug or mirror? | No |
| I025-5 | What is the lunge (`Ranged*`)? | No; the rename is proposed (R-I025-2) |
| I025-6 | What do `$0700` bits do before `NullActorScriptStub` dies? | No |
| I026-1 | Which build (plain or tagged) is the product? | No; now report.md G-1 / AP-01. Evidence: `item_use_system.asm:37,368,450` still document the divergence |
| I026-2 | Lola's Melody replay in scene `$15`? | No |
| I026-3 | Can the pool be full in the Wind Flute path? | No |
| I026-4 | What do bundles `$10` and `$0E` look like? | **Partly answered** in `I029_questions.md:14-18` (decoded with a throwaway decoder: blue-white tint end state). `DeathPaletteFadeThinker.asm:3` still says "not decoded" (A02-08) |
| I026-5 | Does `FlickerParentActor` flicker as intended; what happens to the helper? | No |
| I026-6 | Meaning of `$10` bit `$2000` | No (three descriptions in three files) |
| I027-1 | Why is Y = `$0020` special for the VRAM DMA wait? | No |
| I027-2 | Who reads `$10` bit 9? | See I023-3 |
| I027-3 | Dark Friar fragment start directions? | No |
| I027-4 | How far does Psycho Dash move the player? | No |
| I027-5 | Rewrite `ability_anim_tables` block note? | No (`ability_damage_tables.asm` has 1 `climbStateData` line; not audited here) |
| I027-6 | What do `#1F` and the two `#40` flashes look like? | No (runtime) |
| I028-1 | Why does the transform widen the Arrange mask to `$8044`? | No |
| I028-2 | Dead "target was equipped" branch after the swap | Static reading **confirmed** in live code (`inventory_menu.asm:429-431`, VERIFIED); impact open |
| I028-3 | Can the Use tab end leaving slot 0 marked equipped? | No |
| I028-4 | What is tile `$2060`? | No |
| I028-5 | Is the `+1` in `ComputeAbilityIndex` a reserved entry? | No; `inventory_menu.asm:919` still hedges |
| I028-6 | What do the `#1B/#1C` ramps look like? | No (runtime) |
| I029-1 | Are the `$05`/`$0A` ramp directions backwards? | **Answered by the rename** R-I029-1 (names applied; arithmetic only) |
| I029-2 | Is `$05,S` the parked vertical velocity? | Stack counting only; no |
| I029-3 | Are `$AA`/`$AB` bits dead? | No; notes cite it (`player_move_west.asm:363,583`) |
| I029-4 | Which way does `DiagPushRight` move the player? | **Answered statically** in the east/west notes: pushes SOUTH (`player_move_east.asm:26,186,225`; `player_move_west.asm:916`); runtime unverified |
| I029-5 | What are collision types `$06`/`$09`? | No. Same item as audit OQ-16, OQ-I030-3, OQ-I033-4 |
| I029-6 | What colours do flash #18/#19 show on screen? | No (runtime) |
| I030-1 | What does event flag `#00` mean? | No. Re-asked as OQ-I048-1 and OQ-I052-1 |
| I030-2 | Is `$0200` of the player's `$10` an "ignore hits" bit? | Re-asked as OQ-I039-6 (flags `$0302`); not answered |
| I030-3 | Which probe results reach the `$06/$09` handlers? | Same as I029-5 |
| I030-4 | Is `slope_ramp_physics` geometry consistent with `MapCellDown/Up`? | No; assigned to its own iteration |

**Counts:** 54 questions. Answered (static, in code or ledger): I024-4 (partly), I025-3 (reading only), I026-4 (partly), I028-2 (reading confirmed), I029-1, I029-4 = 6, of which none runtime-confirmed. Duplicates: I029-5 = I030-3 = OQ-I033-4 = audit OQ-16; I023-3 ~ I027-2 ~ I030-2; I025-2 ~ I026-6. Runtime-only: about 30 (every question whose "How to settle" column names Mesen2 only).

## 4. Re-verified facts from the results files (23 checks)

Result: **21 correct, 1 wrong, 1 partly wrong.** 16 files, defect classes 1, 2, 3, 6, 9, 11, 13 touched.

| # | Claim (ledger) | Live check | Verdict |
|---|---|---|---|
| 1 | `TileProbeMain` returns the raw terrain type, carry set for non-zero | `tile_collision.asm:437-565` | correct |
| 2 | `MapCellDown/Up` step one map row, not a column | same file, `ReadCollisionNibble` and `MapCell*` bodies | correct |
| 3 | `DisableNmiKeepJoypad` writes `NMITIMEN = $01` (NMI off, joypad on) | `vblank_joypad.asm:288-293,336-340` | correct (E1/E4) |
| 4 | SPC transfer turns NMI back on only when `worldReadyFlag = $0F` | `spc_transfer.asm:205-232,237` | correct |
| 5 | `WaitByte(n)`/`WaitWord(n)` give n+1 ticks | `cop_handlers_wait.asm:3,14-27,38-46` | correct |
| 6 | `SetPlayerGameOverFlag` sets actor `$10` bit `$0200`, not playerFlags bit 9 | `SetPlayerGameOverFlag.asm`; `combat_collision.asm:333,340,1207` | correct |
| 7 | `scene_flag_init` is placed 26 times (slots `#03`×13, `#04`×6, `#02`×4, `#14`, `#1A`, `#1C`) | `tables/scene_actors.asm` (26 `actor-spawn` lines at 1249…2834 counted); `scene_flag_init.asm` | correct |
| 8 | `oneshot_palette_flash_18` is a 32-frame backdrop strip, lives the whole bundle | `oneshot_palette_flash_18.asm`; `av74_kara.asm:47-52` | correct |
| 9 | Glide lateral window is trigger−7..trigger+$18 | `slider_glide.asm:9`, trigger code | correct |
| 10 | `IsPlayerSliderSpriteBank` accepts only bank `$8F` | `slider_glide.asm:256-273` | correct |
| 11 | West glide: X −4 per frame, countdown in `statsPtr`, finish frame `$14`; `LockPlayerForClimb` stores `$0E`×4 | `slider_glide.asm:277-300,391-405` | correct |
| 12 | `CameraShakeFrame` offsets `(RNG&3)−1`, `((RNG>>2)&3)−1` = −1..+2 | `player_character.asm:679-720` | correct |
| 13 | `SetAutoWalkTimer` stores 13 into `$040C`; decrement while non-negative | `player_character.asm:475-477`; `system_core.asm:510-513` | correct for the value; window length is 13 or 14 states (see §5) |
| 14 | All 59 scene thinker-defs: 32 with `#04,#08`, 27 with `#00,#08` | rg over `extracted/` (counts 32 and 27; no other header bytes) | correct |
| 15 | Metatile repaint window: `(X+16−bg1ScrollH) < $0111`, `0 <= Y−((mapScrollV−$10)&$FFF0) < $F1` | `cop_handlers_metatile.asm:324-338` | correct |
| 16 | `SystemInitConstants` 34 words (`;00-;21`), `PpuRegisterInitTable` 76 writes, last entry `MEMSEL = 0` | `system_init.asm:10,13,371` | correct |
| 17 | `QuintetLzDecompress`: dictionary `$7E:0200-02FF`, size 0 → 65,536 bytes, X/Y/P/DBR preserved | `QuintetLzDecompress.asm:50-123` | correct |
| 18 | The Decompress COP clears the render list after decompressing | `cop_handlers_vram.asm:164-165` | correct |
| 19 | After `ArrangePerformSwap` the `TYA; CMP inventoryEquippedIndex` test compares an actor address (dead branch) | `inventory_menu.asm:429-431` | correct (but see A02-05: two inline comments above it name source and target the wrong way round) |
| 20 | Use-item button is `$0008`, hide mask is `$CFFC` | `item_use_system.asm:16,101,113,611,1782` | correct |
| 21 | `SystemInit` writes `MEMSEL=1` and `InitHardwareRegisters` resets it (boot stays slow ROM) | `system_core.asm:141,169`; `system_init.asm:371` | correct; the older "stale" system_core text was fixed |
| 22 | apply summary: "none of the old names is left anywhere in `extracted/`" | `thinker_execution.asm:168-316` still has `RunThinkers_TypeA..D_Next`; `thinkers/mode7_perspective.asm:5` says `RunThinkers_TypeB` | **wrong** (A02-02) |
| 23 | I023: `slider_glide` block note fully corrected | `slider_glide.asm:4,5,9,59,256,263,267,298`: right facts, but retired nickname `will_alt` (7 lines) and history narration | **partly** (A02-07) |

## 5. Findings

Fields: id, tag, location, what is wrong, proposed fix, defect class (PLAN.md numbering), fix step.

**A02-01** (VERIFIED, class 10). Thirteen of thirteen Q5 rows of I021..I030 are not applied, so misleading mnemonic and COP names are still live. Where: `db-us/mnemonics.json:9` (`deathFlag`, the depth bucket array), `:12` (`invincibilityTimer`, a run window), `:67-69` (`effectScrollH/mapScrollV/effectScrollV`), `:131` (`tileQueryResult`), `:156-157` (`climbStateData`, the ability damage bonus), `:241-242` (`orbitAngle/orbitDiameter`), `:245-246` (`moveXAlt/moveYAlt`); `db-us/copdef.json:79-80,87,120,131`. Live counts (rg, lines, not sites): `invincibilityTimer` 20 lines in 3 files (`player_character` 15, `system_core` 3, `scene_lifecycle` 2); the digest says "29+ operand sites in `player_character.asm`", which is an overcount. `climbStateData` 25 lines in 6 files (`combat_collision` 7, `player_character` 6 (digest says 9), `attack_ability_system` 5, `slider_glide` 4, `scene_lifecycle` 2, `ability_damage_tables` 1). `deathFlag` 8 lines in 3 files (`sprite_composition` 6, `QuintetLzDecompress` 1, `StopPlayerOnDeath` 1). Two stale comments on live names in files outside the range: `system_core.asm:510` ("Decrement invincibility timer") and `scene_lifecycle.asm:828` ("invincibility timer disabled"). Notes apologising for live names: `player_character.asm:12`, `QuintetLzDecompress.asm:24`, `cop_handlers_metatile.asm:6`, `slider_glide.asm:411`. Rows R-I023-3 and R-I025-6 propose **different targets** for the same key (`abilityDamageBonus` vs `willAbilityBonus/freedanAbilityBonus`); they must be reconciled before anyone applies either. Fix: user decision on `mnemonics.json` / `copdef.json`, then a names/mnemonic spec. Step: A14, F06.

**A02-02** (VERIFIED, class 10 and 3). The thinker runner rename is incomplete. `names/bank03.json:331,333,335,337` still name `RunThinkers_TypeA_Next`, `TypeB_Next`, `TypeC_Next`, `TypeD_Next`; `thinker_execution.asm:168-316` uses them on 17 lines (labels at 184, 227, 272, 316); prose at 167 and 197 still says "TypeA" (REPORTED from an earlier read). `thinkers/mode7_perspective.asm:5` and `notes/blockNotes/bank03.json:15` say "RunThinkers_TypeB" (the live name is `RunThinkers_Hdma`). The apply summary claim that none of the old names remains is false. Fix: `names` spec for four sub-labels (`RunThinkers_General_Next` … `RunThinkers_Hdma_Light_Next`), then a `merge` spec for the two prose fixes. Step: new (no F step yet; propose F07).

**A02-03** (VERIFIED, class 6, 11, 13). `MenuSelectionHandler.asm` still carries the stale notes; the corrected set cannot be merged. `src/merge.ts:248-249` refuses the file as a "transforms artifact". The corrected block note, 5 part notes and 26 comments exist only in `edits/I024_MenuSelectionHandler_PROPOSED.json` (unmerged). Live examples: `MenuSelectionHandler.asm:11,42` say "A/Start ($8000)" confirms, but the transform rewrites `$8080` to `$8000` (`transforms.json:525`), so after the remap `$8000` is A only and the code at `:78` tests `BIT #$8000`. The three transform rules are unanchored and apply to any text in the file, so a note containing `$CF80`, `$CFF0` or `$8080` would be rewritten too. Fix: needs the user decision in OQ-I024-1 (anchor the three patterns, R-I024-6, then drop the guard) or an extension of `merge`. I cannot do either here. Step: F06 and A15 (tooling backlog).

**A02-04** (VERIFIED, class 2). Two live wait-count errors, both an off-by-one against `cop_handlers_wait.asm`. `player_character.asm:653-655`: comment "wait 479 frames ($01DF)"; `WaitWord #$01DF` gives 480 ticks. `item_use_system.asm:1826`: block note "WaitByte one frame"; the code at `:1848` is `WaitByte #01` = 2 actor ticks, and the same file's `:1745` and `:1848` say so correctly. Fix: `merge` spec for the two texts. Step: F02.

**A02-05** (VERIFIED, class 3 and 6). `inventory_menu.asm` stale text after R-I028-2/-3. `:7` "StatusAbilityRow2/2/3" (typo for 0/1/2); `:113` and `:143` still say "StatusCharRow actors"; `:508` "(label is an auto name)" although the label is now `DiscardAttempt` (`names/bank02.json:190122`); `:919` hedges "inferred from the earlier note" (narration plus an unresolved OQ-I028-5). New defect: `:413` `LDY $2E ; Refresh target slot actor sprite` and `:421` `LDY $22 ; Refresh source slot actor sprite`. The header at `:392` and the save at `:359` define `$2E` = source and `$22` = target, so the two inline comments are swapped. `notes/partNotes/bank02.json:85` and `:337-339` carry the old text (REPORTED, earlier read). Fix: `merge` spec (notes and two comments). Step: new (propose F07).

**A02-06** (VERIFIED, class 3 and 1). `awB2_stair_climb.asm:1-5` still describes a "stair-climbing actor that forces the player into a scripted ascending movement". The code waits for flag word `$016B`, stores `$000A` into `$0E` and `COP [JumpFar]`s to `SliderGlideTriggerNorthMain` (a north Psycho Slider glide, `:12-20`). `slider_glide.asm:1` already describes it correctly. The actor label `awB2_stair_climb` stays (OQ-I023-1 open). Fix: block-note `merge` spec; the label rename waits for the question. Step: new (propose F07).

**A02-07** (VERIFIED, class 10, 5 and 4). Retired nicknames and narration remain in the player-sprite notes: `will_alt` in `slider_glide.asm:4,5,59,256,263,267,298`; `will_alt`, `ability_fx`, `freedan_fx`, `shadow_fx`, `shadow_mode` in `cop_handlers_player_sprite.asm:6,33,38,52` and `GetPlayerFacingDirection.asm:16`. The `body_table` names are `spriteset_will_abilities` (row 4), `spriteset_transform_poses` (row 5), `spriteset_shadow_aura_body` (row 8). `slider_glide.asm:263` says "4 = Psycho Slider poses, 5 = ability poses"; `body_table.asm:31-32` says row 4 also holds Psycho Dash, Spin Dash charge, the flute pose, the hold pose and the credits. Narration: `slider_glide.asm:5` ("The old comments called these 'walk frames' …"), `:9` ("the old '+/-$20' wording is wrong"). Fix: `merge` spec; the `FacingData_*` rename needs a decision. Step: F03.

**A02-08** (VERIFIED, class 3). Stale "not decoded" and orphan comment key. `DeathPaletteFadeThinker.asm:3` says the two bundles "were not decoded (OQ-I026-4)", but `I029_questions.md:14-18` records the decoding (8-frame fade of 16 words to a pale blue/lavender tint; `$0E` is the instant end state). `notes/comments/bank00.json:1791` has key `"47052"` = "One-shot PaletteStart #18 + PaletteStep then immediate KillThinker". Address 47052 is the `thinker-def` header of `oneshot_palette_flash_18`, which has no instruction line, so the key attaches to nothing (the live inline comment on the `PaletteStart` line is different), and its text contradicts the live block note ("not 'a single PaletteStep'"). Fix: `merge` spec removing the key (the tool supports removals) and updating the thinker note. Step: new (propose F07), tooling check in A15.

**A02-09** (VERIFIED, class 4). History narration in 17 lines of 11 files of the sweep set: `tile_collision.asm:7,129`; `map_coords.asm:10,11`; `system_init.asm:8,253`; `slider_glide.asm:5,9`; `scene_flag_init.asm:3`; `inventory_menu.asm:17,919`; `player_move_west.asm:916` ("the east notes now agree"); `SetPlayerGameOverFlag.asm:3`; `oneshot_palette_flash_18.asm:3,7`; `oneshot_palette_flash_19.asm:3`; `DeathPaletteFadeThinker.asm:3`. Also tool narration in `item_use_system.asm:37,368,450` ("extract:lt text still shows the vanilla BNE"; a note about the build, not the code). Same pattern in files outside this range (`player_move_east.asm`, `player_move_ramps.asm:183,192,391,400`, `sE6_gaia.asm:20`, `body_table.asm`): A04+ sweeps. Fix: `merge` specs removing the narration clauses; keep the technical content. Step: new (propose F07).

**A02-10** (VERIFIED, class 7). OQ / R / AP ids in extracted note text: 45 lines in 13 files (`player_character` 10, `item_use_system` 8, `player_move_west` 6, `hdma_dma_spc` 5, `inventory_menu` 4, `cop_handlers_audio` 3, `SetPlayerGameOverFlag` 2, `cop_handlers_sprite` 2, `tile_collision` 1, `NpcDespawnStub` 1, `FlickerParentActor` 1, `scene_flag_init` 1, `DeathPaletteFadeThinker` 1). Fix: `merge` specs replacing the ids by the plain open-question statement (the OQ document keeps the id). Step: new (propose F07); policy in report.md N-series.

**A02-11** (VERIFIED, class 9). `system_init.asm` names no fixed-address operand of its `wram-init` table: `:207-208` `$0080`/`$0082` (these two words are the collision tile map long pointer to `$7F:C000`; AGENTS.md "Persistent Engine DP State"), `:212` `$06B0`, `:219-220` `$003A/$003C`, `:221-222` `$0402/$0406`, `:223-225` `$005E/$0060/$0062`, `:236-237` `$0B14/$0B04`. Twelve unnamed operands. Fix: part of the A14 mnemonic backlog (R-I024-1/-2 cover two). Step: A14.

**A02-12** (VERIFIED, class 4 and 12). `item_use_system.asm:37,368,450` document that `extract:lt` text differs from the plain build for the two Inca statue rewrites. True and consistent with report.md G-1. Not a defect in the notes, but a reminder that these notes must change when AP-01 is decided. Step: AP-01.

**A02-13** (not a defect, for the fix specs). Sampled constants and masks in `inventory_menu` and `item_use_system` use the post-transform values consistently (`$8000`, `$4000`, `$C000`, `$6000`, `$8044`, `$0008`, `$CFFC`). Class 13: `inventory_menu.asm:17` states the model. `MenuSelectionHandler.asm:11,42` is the only class-13 error found in the sweep set (A02-03).

## 6. "Misleading names still live": digest re-check (item 4)

| Digest row | Verdict | Evidence |
|---|---|---|
| `invincibilityTimer` | still true; digest count wrong | `mnemonics.json:12`; 20 lines in 3 files (digest says "29+" in `player_character`; live 15 there) |
| `climbStateData` | still true | `mnemonics.json:156-157`; 25 lines in 6 files (`player_character` 6, not 9) |
| `deathFlag` | still true | `mnemonics.json:9`; `sprite_composition.asm:62,94,100,247,250,264` |
| `effectScrollH/mapScrollV/effectScrollV` | still true | `mnemonics.json:67-69` |
| `moveXAlt/moveYAlt`, `orbitAngle/orbitDiameter` | still true | `mnemonics.json:241-242,245-246`; `inventory_menu.asm:113` still uses them as child-actor handles |
| `StairTrigger*`, `stair_climb` | renamed; actor label remains | no hits for `StairTrigger`/`ClimbSouth`; `awB2_stair_climb.asm:12` |
| `EnableNmiOnly` | renamed | `scene_lifecycle.asm:195` `DisableNmiKeepJoypad` |
| `DecompressGfxToVram`, `LzReadBackRef`, `SpcCheckMusicReady`, `NullActorScriptStub` | gone from `extracted/` | rg: no match |
| `RangedAttack*` | still true | `names/bank02.json:355-358`; 17 lines in `player_character.asm` |
| `DisableStatusForAttack` | renamed | `names/bank02.json:340` `FreezeCameraForAttack` |

## 7. Defect-class sweep over the 32-file set

Class numbers follow PLAN.md.

| Class | Result |
|---|---|
| 1 purpose guessed from label | no new case found; A02-06 is the one stale-purpose header; `SetPlayerGameOverFlag.asm:3` hedges correctly ("most likely", with the OQ) |
| 2 WaitByte n vs n+1 | 2 live errors (A02-04); `SetAutoWalkTimer` window length unverified (13 or 14 states, §8) |
| 3 stale comment after rename | `inventory_menu` (5 lines), `awB2_stair_climb`, `DeathPaletteFadeThinker`, `system_core.asm:510`, `scene_lifecycle.asm:828`, `thinker_execution` prose, `mode7_perspective.asm:5` |
| 4 history narration | 17 lines in 11 files (A02-09) |
| 5 opcode table of a different row | 1 case: `slider_glide.asm:263` row 4/5 wording vs `body_table`; 0 other in this set (the set has no opcode tables) |
| 6 comment contradicting code | `inventory_menu.asm:413,421`; `MenuSelectionHandler.asm:11,42` (class 13 too) |
| 7 OQ/R ids in note text | 45 lines in 13 files (A02-10) |
| 8 hidden sprite groups | not applicable: no `.sprite` file belongs to I021..I030 |
| 9 unnamed fixed-address operands | `system_init` 12 (A02-11); `hdma_dma_spc` `$0402`, `$AC..$B2` (R-I021-3) |
| 10 retired nickname in a name | `will_alt/ability_fx/shadow_mode` (A02-07), `Ranged*` (17 lines), `StatusCharRow` (2), `_Next` labels (A02-02), `diag` in `tile_collision.asm:3` callers list |
| 11 wrong flag/hardware/branch/answer | none found in the 23 checks beyond A02-03; hardware claims in `vblank_joypad`, `spc_transfer`, `system_init` all hold |
| 12 transform adjacency | see §9 |
| 13 button vocabulary | 1 error (`MenuSelectionHandler`); `inventory_menu`, `item_use_system`, `slider_glide` consistent |

Hedge words ("probably", "likely", "inferred", "unclear") occur in 7 files (`inventory_menu`, `SetPlayerGameOverFlag`, `hdma_dma_spc`, `item_use_system`, `player_move_west`, `system_init`, `FlickerParentActor`). I did not classify them one by one. REPORTED.

## 8. Not verified / needs Mesen2

- Every behavioural claim is static. No Mesen2 ROM or state exists. Runtime-only: all `OQ` rows whose "How to settle" is Mesen2 (about 30 of 54), including the on-screen look of the palette bundles (`#18/#19/#1B/#1C/#1F/#40/$0E/$10`).
- `SetAutoWalkTimer` window: the stored value 13 is verified (`player_character.asm:475-477`). Whether the run window lasts 13 or 14 frames depends on whether `UpdateFrameCounters` (`system_core.asm:510-513`, DEC while ≥ 0) runs before or after the player actor's test each frame. The note says "13 frames". Needs a tick-order trace or a watch on `$040C`. Possible class 2.
- OQ-I021-1 for the 8 `scene_script` call sites (sort-order trace).
- R-I022-5/-6, R-I025-5/-7, R-I029-5 and R-I030-3 (documentation rows) were not re-opened here; A11 owns them.
- `names` merge behaviour on `transforms.json`: `notes-and-comments.md:1454` says `db-us/*.json` get a raw whole-word replacement, so renaming `loc_0386EA/loc_038800/loc_0386FA/loc_03880D` would also rewrite the transform keys. REPORTED, not tested.
- `apply-I021-I040_map.json` (191 pairs) not read; the 23 APPLIED rows were verified against `names/*.json` and `extracted/`, not against that map.
- The 14 note files outside this range cited as same-pattern evidence were only grepped.

## 9. Transform-adjacency inventory (class 12)

Multi-line or adjacency-sensitive rules that affect files of I021..I030 (`db-us/transforms.json`):

| Block (file) | Rule | What a note or comment could break | Live state |
|---|---|---|---|
| `item_use_system` (`:530-533`) | `(CMP #\$0027[\s]+)BNE loc_0386FA` and `(CMP #\$0038[\s]+)BNE loc_03880D` | any inline comment on the `CMP` line, or a label or note line between `CMP` and `BNE`, stops the rewrite and changes the ROM; also fails in the tagged build (G-1) | `CMP #$0027` at `item_use_system.asm:388` and `CMP #$0038` at `:463` carry no comment (VERIFIED); the rewritten `BEQ` lines `:389,:464` carry the comment, which is safe |
| `item_use_system` (`:530-531`) | `BNE loc_0386EA`, `BNE loc_038800` (single line) | renaming those labels breaks the rule | labels still `loc_0386EA`, `loc_038800` |
| `item_use_system`, `slider_glide`, `attack_ability_system`, `inventory_menu`-adjacent callers, and the other blocks | `LDA #\$XXXX([^\r\n]*\s+T[SR]B \$joypadMaskStd)` and `…TSB \$joypadHeld` | a comment-only line or label between the `LDA` and the `TSB/TRB` breaks it | none: a multiline rg over all of `extracted/` for `LDA/ORA #$xxxx` followed by comment, blank or label lines and then `T[SR]B/STA $joypadMaskStd/joypadHeld` returns 0 matches (VERIFIED) |
| `MenuSelectionHandler` (`:522-526`) | unanchored `\$CF80`, `\$CFF0`, `\$8080` anywhere in the file | rewrites notes too (A02-03) | notes are stale; no note contains those literals today |
| `inventory_menu` (`:501-507`) | `#\$4040`, `#\$6040, &TabCancel`, `#\$C040`, `#\$8000, &ArrangePerformSwap`, `LDA #\$2040` | single-line; renaming `TabCancel` or `ArrangePerformSwap` breaks the rule | no note contains the pre-transform literals |
| `LDA \$0A…STA \$00…STA \$02, S` (13 blocks, `:18-84`) | tolerates one `; …` comment per gap | not in the I021..I030 file set | not checked |

**No note on a label inside a multi-line regex was found in the I021..I030 files.** The documented guard (`notes-and-comments.md:1306,1319`: `merge` warns about transform-pattern text and the doc has the adjacency paragraph) is present in the live doc (VERIFIED), which closes part of report.md G-6; the `CMP/BNE` pair is the one rule where a future note on the `CMP` line would silently change the ROM. Tooling decision goes to A15.

## 10. Items for the fix specs

| Item | Content | Step |
|---|---|---|
| I-1 | A02-04: two `merge` text fixes (`player_character.asm:653`, `item_use_system.asm:1826`) | F02 |
| I-2 | A02-07: `will_alt` / `ability_fx` / `shadow_mode` / row 4–5 wording in `slider_glide`, `cop_handlers_player_sprite`, `GetPlayerFacingDirection`, plus the `FacingData_*` decision | F03 |
| I-3 | A02-01: 13 Q5 rows, including the R-I023-3 / R-I025-6 target conflict and the `moveXAlt` repurposed-field caveat | F06 (after A14) |
| I-4 | A02-03: unblock `MenuSelectionHandler.asm` (decision on R-I024-6), then merge `edits/I024_MenuSelectionHandler_PROPOSED.json` | F06 + A15 |
| I-5 | A02-02: four `_Next` renames, then prose in `thinker_execution`, `mode7_perspective`, `blockNotes/bank03.json:15` | NEW: propose F07 (names + merge) |
| I-6 | A02-05, A02-06, A02-08: `inventory_menu` text (incl. swapped source/target comments), `awB2_stair_climb` header, `DeathPaletteFadeThinker` note, orphan key `47052` | NEW: propose F07 |
| I-7 | A02-09, A02-10: remove narration clauses and OQ/R ids from the 11 and 13 files | NEW: propose F07 |
| I-8 | A02-11: unnamed `system_init` operands | A14 |
| I-9 | §9: protect the `CMP #$0027 / #$0038` lines; decide on a transform-guard in `merge` | A15, AP-18 |
| I-10 | Digest corrections: `invincibilityTimer` count (20 lines, not 29+), `climbStateData` in `player_character` (6, not 9), the "none of the old names is left" claim | A12 / digest erratum |

## 11. Counts

- Rename rows: 49 = 23 APPLIED, 7 DOCS, 19 PROPOSED, 0 SUPERSEDED, 0 DROPPED. Q5 rows: 13, all PROPOSED.
- Open questions: 54. Answered statically: 6 (two partly; none runtime). Runtime-only: about 30.
- Fact checks: 23 (21 correct, 1 wrong, 1 partly wrong) in 16 files, 7 defect classes.
- Findings: 13 entries (A02-01 … A02-13): 11 are defects (A02-01 … A02-11), 1 is informational (A02-12), 1 is a consistency note (A02-13). New live defects not in any ledger: A02-02 (`_Next`, `mode7_perspective`), A02-05 (swapped comments at `inventory_menu.asm:413,421`, "auto name", `StatusAbilityRow2/2/3`), A02-06, A02-08 (orphan key and stale "not decoded").
- Sweep: class 4 narration 17 lines in 11 files; class 7 ids 45 lines in 13 files; class 2 live errors 2; class 13 errors 1; class 12 live hazards 0 (1 latent: `CMP` lines of the two Inca rewrites).
