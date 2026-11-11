# I026 results

Files: `system/inventory/item_use_system.asm` (Bank 03), `functions/ToggleActorVisibilityFlag.asm` (Bank 00), `functions/DeathPaletteFadeThinker.asm` (Bank 00).
Spec: [edits/I026.json](../edits/I026.json). New proposals: [renames/I026_renames.md](../renames/I026_renames.md). New questions: [questions/I026_questions.md](../questions/I026_questions.md).

Conventions (unchanged): verdicts **P/M/F/NA**; dispositions **FIXED / PROPOSED / DEFERRED-EVIDENCE / NOFIX**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 comment density, Q2 value, Q3 accuracy, Q4 mnemonic/address accuracy, Q5 mnemonic opportunity, Q6 part naming, Q7 evidence quality.

### File 1: system/inventory/item_use_system.asm (Bank 03)

Evidence: E1 (dispatch and epilogue, the jump table, the Red Jewel, Inca Statue A/B and their CheckAlt routines, Wind/Lola/Memory melody handlers and effects, `FluteMusicActorController` with all three phases and the cleanup, `RemoveEquippedItem`, `SetPlayerTransition`; `db-us/transforms.json` for `item_use_system`, applied by hand to the A/B routines and confirmed against a normal `npm run extract`), E2 (`actor_execution` display-filter mode, `CopyActorState` and `sprite_composition` for the `$2000` spawn flag, `camera`/`actor` readers of `displayModeFlags`, `cop_handlers_input` for the button model, `docs/bank01-data-tables.md` for the BGM names, `system_init` remap constants), E3 (`docs/ram_map.txt` item list).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Good per-handler notes; the shared mechanics (button consumption, display-filter mode, the Inca transforms) were stated wrongly or not at all | FIXED (block note rewritten with a conventions section and the Inca paragraph, 10 part notes, 19 comments: 7 new, 12 updated) |
| Q2 | M | A reader could not tell what the `$0008`/`$CFFC` constants do or why the melody handlers freeze the world | FIXED |
| Q3 | **F** | (a) **The "Start button ($4000)" wording is wrong** in the block note, the `ItemUseDispatch`/`ItemUseEpilogue` notes and a comment: the code stores `$0008` in `joypadHeld`, the logical use-item button (the vanilla `$4000` is rewritten by `transforms.json`), to consume it. Start is untouched. (b) **`$CFF0` in five notes/comments is stale**: the code stores `$CFFC` (hides everything except Start/Select and bits 0-1, D-pad included); "everything except D-pad and Select" was also wrong. (c) **"Suppress rendering" is wrong**: `displayModeFlags $0080` is the display-filter mode of `actor_execution`; only actors with `$1000` in `$10`/`$12` run, which is why the controller, the SPC transfer actors and the player get `$1000`. (d) **`$2000` in the spawn flags is not "display-filtered actor flags"** (that is `$1000`); `CopyActorState` forces `$2000` on every spawned actor and `SortActorsByDepth` skips actors with it set (OQ-I026-6). (e) **Inca Statues A/B**: "Falls through to CheckAlt" was wrong (a branch); `transforms.json` repairs four branches that jumped into the middle of CheckAlt past its Y test, and two `BNE` whose target was the next instruction (X = `$27` in A, X = `$38` in B never reported the mismatch); the second pair does not apply to `extract:lt` text (OQ-I026-1). (f) **`code_03A098` is also the normal end of the controller**: after the Phase 3 `WaitByte` the code falls through into it; the header called it a spawn-failure cleanup only. (g) Wind Melody track `$19` is `bgm_lost_incan_melody` (the "Wind Melody SPC module" label was an alias); Lola `$18` and Memory `$1D` match `docs/bank01-data-tables.md`. | FIXED (all of the above in the notes and comments) |
| Q4 | NA | Operands are named; `jewelsCollected` etc. are correct | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | Auto names `code_0389D9`, `loc_03A029`, `code_03A06E`, `code_03A098` and the shared mismatch message `code_03876D` carry roles documented in the notes | PROPOSED (R-I026-2, R-I026-3) |
| Q7 | M | E1 + E2; the Itory replay path of Lola's melody, the pool-full path of the Wind Melody and the build discrepancy are static conclusions | DEFERRED-EVIDENCE (OQ-I026-1 to OQ-I026-3, OQ-I026-6) |

### File 2: functions/ToggleActorVisibilityFlag.asm (Bank 00)

Evidence: E1 (`LDY $24`, `EOR #$2000`, `RTL`), E2 (the five spawn sites `sp5B_neil`, `sp5B_lance`, `sp5B_kara`, `sp5B_erik`, `sp5A_phantom_ribber`, all `SpawnAfterAbsFlags ( @ToggleActorVisibilityFlag, #$0000, #$0000, #$2800 )`; `CopyActorState` stores the spawner's slot in `$24`; `SortActorsByDepth` skips `$2000` actors; `RunActors_Normal` runs script actors every tick), E3 (`docs/code/bank06-late-midgame-actors.md` section 3.3: "hidden until #70 set, spawn ToggleActorVisibilityFlag").

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A two-line note and no comments | FIXED (block note, 3 comments) |
| Q2 | M | The note said the helper shows/hides characters during palace events | FIXED |
| Q3 | **F** | (a) It is **not a one-shot toggle**: the routine ends with `RTL` without `COP [Die]` or a new entry point, so the helper runs again every tick and flips bit `$2000` of the parent's `$10` every tick; because the sprite sort skips `$2000` actors, the parent is drawn on alternate frames (a flicker, probably a ghost look; UNVERIFIED-RUNTIME). (b) "Reference actor (from $24)" is correct but unexplained: `CopyActorState` stores the spawner's slot there. (c) The helper is not a marked child, so it outlives its parent (OQ-I026-5) | FIXED |
| Q4 | NA | No mnemonic operands | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | `ToggleActorVisibilityFlag` suggests a one-time toggle | PROPOSED (R-I026-1) |
| Q7 | M | E1 + E2 + E3; the visual result and the effect on the parent's script path when `$2000` flips each tick are static readings | DEFERRED-EVIDENCE (OQ-I026-5, OQ-I026-6) |

### File 3: functions/DeathPaletteFadeThinker.asm (Bank 00)

Evidence: E1 (`PaletteStart #10`, `PaletteStep`, `PaletteStart #0E`, `PaletteStep`, `KillThinker`), E2 (`cop_handlers_palette` header and the `PaletteStart`/`PaletteStep` handler notes: one bundle per pair; `game_over_sequence` spawns it with `SpawnThinker`; `combat_collision` assigns `GameOverSequence` to the player at HP zero), E3 none.

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A two-line note and no comments | FIXED (block note, 5 comments) |
| Q2 | M | "Steps palette animations" hid that each `PaletteStep` runs the whole bundle | FIXED |
| Q3 | M | "Always invoked when the player dies and combat_collision assigns GameOverSequence" skipped the actual spawner (`GameOverSequence`); "desaturated death-screen palette fade" was not backed by a decoded bundle | FIXED (reworded; OQ-I026-4 for the contents) |
| Q4 | NA | Bundle IDs are literals | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | P | `DeathPaletteFadeThinker` is accurate | NOFIX |
| Q7 | M | E1 + E2; the colors of bundles `$10` and `$0E` were not decoded | DEFERRED-EVIDENCE (OQ-I026-4) |

### Shared gate (I026)

`npm run merge -- edits/I026.json --dry-run` first reported four warnings (comment texts containing `BNE loc_0386EA` / `BNE loc_038800`, which `transforms.json` would rewrite); the texts were reworded, the dry run is clean, the merge applied. Spec: 3 block notes, 10 part notes, 27 comment entries (12 new, 12 updated, 3 unchanged: the Toggle comments were already in place from the first, misplaced merge of `edits/I025.json`). `npm run extract:lt` OK and the new notes render in `extracted/`. `npm run rebuild` (after I025 and I026 together): success, `artifacts/crc.json` = checksum 223006080, crc 2083230829, totalSize 3062204.

Tooling finding for the owner (details in OQ-I026-1): `extract:lt` text differs from the normal `extract` text in five files because multi-line `transforms.json` rules do not apply when address tags sit between the lines (`mansion/solid_arm_lair/sEA_solid_arm.asm`, `pyramid/mummy_queen_lair/pyDD_teleporter.asm`, `pyramid/pyramid_vader_b/pyD7_sliding_wall.asm`, `system/diary_menu/sFA_diary_menu.asm`, `system/inventory/item_use_system.asm`). A rebuild from a normal extract is 3062189 bytes (crc -1004081563), 15 bytes smaller than the line-tracked baseline that this gate checks. The audit's gate cannot see the difference; no file outside `plans/extracted-audit/` was touched to address it.

Suggested commit message: `audit(I026): correct item_use_system button/display-filter semantics and Inca statue transform notes; document ToggleActorVisibilityFlag flicker and DeathPaletteFadeThinker bundles`

Please commit when you're ready.
