# I025 results

Files: `actors/player/player_character.asm` (Bank 02), `functions/NullActorScriptStub.asm` (Bank 00), `functions/f_inventory_full.asm` (Bank 00).
Spec: [edits/I025.json](../edits/I025.json). New proposals: [renames/I025_renames.md](../renames/I025_renames.md). New questions: [questions/I025_questions.md](../questions/I025_questions.md).

Conventions (unchanged): verdicts **P/M/F/NA**; dispositions **FIXED / PROPOSED / DEFERRED-EVIDENCE / NOFIX**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 comment density, Q2 value, Q3 accuracy, Q4 mnemonic/address accuracy, Q5 mnemonic opportunity, Q6 part naming, Q7 evidence quality.

Process note: `ToggleActorVisibilityFlag` was first written into `edits/I025.json` by mistake (it belongs to I026). The entry was removed from that spec before this results file was written and is part of `edits/I026.json`; the I026 merge replaced the notes. `edits/I025.json` as it stands covers exactly the three files above.

### File 1: actors/player/player_character.asm (Bank 02)

Evidence: E1 (whole file traced: init, `PlayerIdleEntry` and the dispatch matrix, the four walks, `CheckAttackWhileWalking`, vine climb and drop attack, camera shake, ladder, shimmy, block, the Psycho Slider routines, the four melee attacks, redirect/init, the lunge pieces and the projectiles; `db-us/transforms.json` for `player_character`; the `cop_handlers_input` mask semantics), E2 (`UpdateFrameCounters`, `scene_lifecycle` and `system_core` for `$040C`; `CopyActorState`; `sprite_composition.SortActorsByDepth` and `SortActors_OffScreen`; `actor_execution` header; `tile_collision_physics` for the `$12` direction bits and the `extendedFlags` `$0040` bounce flag; `camera_scroll_controller` for `layerPriorityFlag $0200`; `attack_ability_system` callers of `DisableStatusForAttack`/`RestoreStatusDisplay`; `combat_collision` damage formula for `$09E0`; the force-move curve `#46` decoded from `tables/movement_delta_table.asm`), E3 (`docs/ram_map.txt`, `docs/wram-memory-map.md`, `docs/code/bank02/player-character.md`, now known to be partly off, see R-I025-5).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Dense per-line comments, but many of them restated stale constants or wrong mechanisms (see Q3); several sat on the wrong instruction (the `STZ $slopeStepCounter` comment described the sprite staging two instructions later; the `Attack button pressed` comment sat on `BIT #$1000`) | FIXED (block note rewritten with a button/flag conventions section, 11 part notes, 65 comments: 21 new, 44 updated) |
| Q2 | M | The reader could not tell what `TSB joypadHeld` and `TSB joypadMaskStd` do, how a run starts, or that the "ranged" pieces are a lunge | FIXED |
| Q3 | **F** | (a) **`TSB joypadHeld` consumes, it does not inject**: `joypadCurrent` = held minus `joypadHeld` minus `joypadMaskStd` (`cop_handlers_input` header), so the four `BlockFromWalk*` stores, the `AttackX` direction stores and the `AttackInit` store hide a button; the old text said "inject" (6 places incl. the block note). (b) **Stale constants**: the comments said `$8F30`, `$8000`, `$4000` and `$CFF0`; the extracted code (after `transforms.json`) has `$0FB0` (attack + D-pad + L/R), `$0080`, `$0008` (use-item) and `$CFFC`. (c) **`$040C` is a run window, not an invincibility timer**: `SetAutoWalkTimer` writes 13, `UpdateFrameCounters` decrements it, `$FFFF` = closed (`scene_lifecycle`); a walk entered while already facing that way (`$24` = facing from `PlayerIdleEntry`) with the window open (`BMI` not taken) zeroes it, sets speed ±3 and re-dispatches. `docs/ram_map.txt` ("running-allowed timer, set to #$0D by D-pad input") says the same; `docs/wram-memory-map.md` ("hit-blink immunity") is wrong. Block zeroes it too. (d) `$0020` in `$10` is the **block marker** (set in the block loop, cleared at idle entry), not "Psycho Slider flag" (that is `$0200`, set/cleared by `RunAttackFlagSetup`/`RunAttackCleanup`). (e) **`CheckAttackWhileWalking` Z direction**: `BIT #$1000` leaves Z = 0 when the slope flag is SET, every caller does `BNE` over its L/R block check, so blocking is skipped on slopes; the old note said Z = 0 means "caller should check for block transition". (f) **Camera shake** offsets are `(RNG & 3) - 1` for X and `((RNG >> 2) & 3) - 1` for Y, i.e. -1..+2 each (two `LSR`s, not bits 4-5; not "±1"). (g) **Redirect masks**: `$0B00`/`$0700` = every D-pad direction except the facing one, not "perpendicular". (h) **`Ranged*` is a lunge, not a projectile launch**: force move `#46` (six 0, nineteen 3, four 1, then 0), `playerFlags $0800`, `climbStateData = 1` (the ability damage bonus `combat_collision` adds), actor flag `$0200`, `OrExtraFlags #$0040` = `extendedFlags` bit 6 = the bounce flag of `tile_collision_physics`; `$2000`/`$4000` stored in `$12` are the direction-negate bits (flip Y / flip X), not "mirror flags". (i) **`Projectile*` are spawned only by the `Attack*` pieces in scene `$E8`** (4 sites, flags `$0602`), never by `Ranged*`, and die when bit `$4000` of `$10` (off-screen, set by `SortActors_OffScreen`) is set, not on a wall hit. (j) **`DisableStatusForAttack` / `RestoreStatusDisplay`** set/clear `layerPriorityFlag $0200`, which `camera_scroll_controller` documents as freezing the camera; nothing about a "status overlay". (k) `$0100` labelled "visibility" and "climb mode" has no established meaning (set at init, idle and ladder/shimmy entry; cleared by block, `AttackInit`, run-attack): the labels were removed and the bit is OQ-I025-1. (l) `CheckRunAttack`: `$10` bit `$0080` is the hit-reaction counter flag of `actor_execution`, not "frozen". (m) `AttackInit` keeps only the D-pad bits of `joypadCurrent` and sets `joypadHeld = D-pad | attack`; the old text said it strips the D-pad. (n) `ClimbVineEntry` hides the use-item button (`$0008`), not `$4000`; `LadderClimb*` hides everything but Start/Select and reads Up/Down through raw masks. | FIXED (all of the above in the notes and comments) |
| Q4 | M | `invincibilityTimer` (`$040C`) and `climbStateData` (`$09E0`, `$09E2`) are wrong names for what the code does | PROPOSED (R-I025-1, R-I025-6) |
| Q5 | M | `RangedAttack*`/`RangedSetForce*` name a projectile that is not there; `DisableStatusForAttack`/`RestoreStatusDisplay` name a status overlay that is not there | PROPOSED (R-I025-2, R-I025-4) |
| Q6 | M | Part names otherwise follow the code; `ImpactTerrainShake`, `CameraShakeActor` and the walk/block/attack names are accurate | NOFIX (renames above) |
| Q7 | M | E1 + E2 + E3; the player's `$10` bits `$0100` and `$2000`, the run window at runtime, the north wall-push test and the lunge's in-game identity are static readings only | DEFERRED-EVIDENCE (OQ-I025-1 to OQ-I025-5, OQ-I025-7) |

### File 2: functions/NullActorScriptStub.asm (Bank 00)

Evidence: E1 (one `COP [Die]`), E2 (the only reference in `extracted/` is `combat_collision.InteractionDamage_NPCChat`: stores the stub into `$0000`/`$0002` of the NPC, zeroes `$08`, ORs `$0700` into `$10`; `CopyActorState`, `AllocateActorBefore/After` do not use it), E3 (`docs/code/bank00/functions-combat-defeat.md`, `data-tables-memory.md`: both claim it is the default script of newly allocated actors, which is not supported).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | The note was short but wrong about the effect | FIXED (block note rewritten) |
| Q2 | M | "Inert dead stubs without removing them from the actor list" hid the real behavior | FIXED |
| Q3 | **F** | The stub is not inert and not long-lived: the NPC's next tick executes `COP [Die]`, which unlinks it (one-tick despawn after the item/dialogue interaction). The docs' "default script for newly allocated actors" has no caller in `extracted/` | FIXED (note) / PROPOSED (docs, R-I025-7) |
| Q4 | NA | No operands | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | `NullActorScriptStub` reads as a do-nothing stub | PROPOSED (R-I025-3) |
| Q7 | M | E1 + E2; what `$0700` in `$10` does for the single tick before the death is unknown | DEFERRED-EVIDENCE (OQ-I025-6) |

### File 3: functions/f_inventory_full.asm (Bank 00)

Evidence: E1 (`COP [PrintDialogString]`, `RTL`; the string decoded as "Your inventory is full. You can't carry more."), E2 (eight `JML $@f_inventory_full.InventoryFullMessage` sites, one per file: `gw82_necklace_stone`, `ec0A_barrel_roast`, `ec0B_cell`, `awBA_glasses`, `eu91_merchant_counter`, `dm47_sam`, `sc06_lola`, `pyDA_lithograph1`; `combat_collision.InteractionDamage_NPCChat` has its own overflow path).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | The note was correct but did not list the callers or the control flow | FIXED (block note, 1 comment) |
| Q2 | P | The role (central overflow message) was already stated | NOFIX |
| Q3 | P | Accurate | NOFIX |
| Q4 | NA | No mnemonic operands | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | P | `InventoryFullMessage` is accurate | NOFIX |
| Q7 | P | E1 + E2, complete caller list | NOFIX |

### Shared gate (I025)

`npm run merge -- edits/I025.json` applied without warnings (final replay: every entry unchanged after the second apply). Applied: 3 block notes, 11 part notes, 66 comments (new and updated). `npm run extract:lt` OK and the new notes render in `extracted/`. `npm run rebuild` (after I025 and I026 together): success, `artifacts/crc.json` = checksum 223006080, crc 2083230829, totalSize 3062204 (the baseline).

**Tooling finding (see OQ-I026-1):** a rebuild from a normal `npm run extract` gives totalSize 3062189 / crc -1004081563, 15 bytes smaller than the baseline above, because five files contain `transforms.json` rules that span a line break and do not apply to `extract:lt` text. The gate therefore compares the line-tracked build only.

Suggested commit message: `audit(I025): correct player_character joypad semantics (consume vs inject, $CFFC/$0080/$0008), run window $040C, camera shake range, lunge vs projectile, and NullActorScriptStub/inventory-full notes`

Please commit when you're ready.
