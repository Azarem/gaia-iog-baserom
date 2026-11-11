# I037 results

Files: `actors/interaction_handlers.asm` (Bank 00), `functions/EnemyInitBasic.asm` (Bank 0A), `functions/RandomPlayerOffset.asm` (Bank 0A).
Spec: [edits/I037.json](../edits/I037.json). New proposals: [renames/I037_renames.md](../renames/I037_renames.md). New questions: [questions/I037_questions.md](../questions/I037_questions.md).

Conventions as in [I029_results.md](I029_results.md). I035 and I036 were skipped at the user's request.

### File 1: actors/interaction_handlers.asm (Bank 00)

Evidence: E1 (every instruction of the three handlers read with `extract:lt` addresses; branch targets, the dead second `BPL`, the Y / X axis of every block and the object that moves traced), E2 (`cop_handlers_player_query` `BranchOnPlayerX` / `BranchOnPlayerY` slot order, `BranchIfPlayerNear`, `BranchIfPressed`, `BranchIfSolidOffset`, `MarkSolidHere` / `ClearSolidHere`, `NudgePosition`, `SetSavedPtr` / `RestoreSavedPtr` / `SetEntryHereAndYield`, `GetPlayerFacingDirection`, `combat_collision` for `$12` bits `$0010` / `$0020` and `$10` bit `$0080`, `player_character` `BlockStopToIdle` for the `$0030` mask, `rg` over `extracted/` for every spawn site), E3 (`docs/wram-memory-map.md` actor DP layout, `docs/cop/families/input.md` joypad layout, `docs/code/bank00/actors-combat-interaction.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Header paragraph plus four inline comments, some wrong; no structure explanation for 475 lines of near-identical blocks | FIXED (block note with shared structure, three handler descriptions and the spawn list; 14 part notes; 44 comment entries) |
| Q2 | M | The reader could not tell which axis a block works on, which actor moves, or what the guard conditions mean | FIXED |
| Q3 | **F** | (a) **Header "nudges the player toward the gem"**: the code only reads the player (`$0016,Y` / `$0014,Y`); it moves the parent at `$04` (the gem) and mirrors the value into its own `$14` / `$16`. (b) **Header "AddPosition"** does not exist; the COP is `NudgePosition` (`$BC`). (c) **Button**: mask `$0031` = raw joypad (bit 0) and `$0030` = L / R; the inline comment "BranchIfButton A" is wrong (A is `$0080`). (d) **Axis labels**: `BranchOnPlayerX` loads slot +4 when the player is within `$0F` px (handler order West / Here / East), so `*MoveWest` / `*AlignWest` work on posY (`$0016`) with the player above or below, and `*MoveNorth` / `*AlignNorth` work on posX. The inline comment "Push west: abs delta-Y>=$20, facing north ... nudge -$10 Y" contradicts its own label. (e) **Direction of motion**: with facing 0 = down, 1 = up, 2 = left, 3 = right (`GetPlayerFacingDirection`), every block requires the player to face the object and then moves the object ONE tile toward the player, so the handlers pull rather than push (the forceball pose indices `$3A` / `$3B` / `$3C` / `$3D` line up with down / up / left / right). (f) **"toggling status bit $0010"**: the bit is OR-ed on the parent for the slide and restored from `$24`; in `combat_collision` it is damage / stagger immunity. (g) **Spawn list**: Great Wall archer (2), `field_reveal_object` and the `ec0B_cell` prison gem were missing or mislabelled (`ec0B_cell` spawns `collect_handler_gem`, not a push handler). (h) Dead code: the second `BPL` after each first `BPL` can never be taken (N is unchanged); three `NOP` bytes before one `RTL` | FIXED (comments and notes); direction semantics DEFERRED-EVIDENCE (OQ-I037-1) |
| Q4 | M | All operands correct; the inline notes on `$0016` / `$0014` and the "facing north / west" wording were wrong | FIXED |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | **F** | `push_handler_*` and every `PushSolid*Move{West,East,North,South}` / `CollectGemAlign*` label name the wrong action (pull) and the wrong axis | PROPOSED (R-I037-1, R-I037-2) |
| Q7 | M | E1 + E2 is strong for the control flow; the in-game meaning of the L / R + facing pose, the slide duration and the immunity role are not runtime-checked | DEFERRED-EVIDENCE (OQ-I037-1, -2, -3) |

### File 2: functions/EnemyInitBasic.asm (Bank 0A)

Evidence: E1 (9 instructions), E2 (`rg` found two callers, `dm3F_laborer` `code_0AA9E0` and `fr32_kidnapper`; `combat_collision` readers of `$12` bits `$0010` and `$0020`; `cop_handlers_callbacks` header for `extendedFlags $0080`; `actor_execution` for the `$0100` stats bit), E3 (`docs/code/bank0A-dungeon-enemy-actors.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A four-line header, short inline comments | FIXED (block note, 3 comment entries) |
| Q2 | M | The header gave the wrong population and the wrong bit meanings | FIXED |
| Q3 | **F** | (a) "called by most enemy actors": only two callers (`dm3F_laborer`, `fr32_kidnapper`). (b) "`$0030` solid + interactable": `combat_collision` reads `$12` bit `$0010` as damage / stagger immunity and bit `$0020` as boss (skip damage digits and the attack hit test). (c) "extendedFlags bit `$0080` enemy type": `cop_handlers_callbacks` calls it the boss bit. (d) "currentHp = 1 (replaced on first damage calc)": untraced; `fr32_kidnapper` overwrites it with 5 right after | FIXED (comments); the HP replacement DEFERRED-EVIDENCE (OQ-I037-4) |
| Q4 | M | Operands correct | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | `EnemyInitBasic` suggests a generic enemy; it sets immunity and boss bits for two actors | PROPOSED (R-I037-3) |
| Q7 | M | E1 + E2; the effect in play is not runtime-checked | DEFERRED-EVIDENCE (OQ-I037-4) |

### File 3: functions/RandomPlayerOffset.asm (Bank 0A)

Evidence: E1 (13 instructions), E2 (`rg`: no `JSL` caller; `awB1_goldcap` and `pyDD_mummy_queen` use it as the spawn target of `SpawnAfterMarked( @RandomPlayerOffset, #$2000 )` and store the child slot; `unused_random_position_noref` is its unreferenced sibling), E3 (`docs/wram-memory-map.md` `$08` = wait counter).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A five-line header and short inline comments | FIXED (block note, 1 comment entry) |
| Q2 | M | The header described it as a helper for VFX actors | FIXED |
| Q3 | **F** | (a) It is actor entry code, not a helper, used by two boss actors. (b) `$08 = $3C` is a 60-frame wait before the entry code runs again, not a "60-frame lifetime"; the actor re-rolls its position every 60 frames (assuming the scheduler resumes at the unchanged `$00`). (c) "particle effects, spell visuals" has no caller behind it | FIXED; rerun DEFERRED-EVIDENCE (OQ-I037-5) |
| Q4 | M | Operands correct | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | `RandomPlayerOffset` describes the maths, not that it is a hopping marker actor | PROPOSED (R-I037-4) |
| Q7 | M | E1 + E2; the rerun and the use of the marker by the parents are not traced | DEFERRED-EVIDENCE (OQ-I037-5) |

### Shared gate (I037)

`npm run merge -- edits/I037.json --dry-run` was clean (no length or transform warnings). Merge applied: 3 block notes, 14 new part notes, 48 comment entries (44 in `interaction_handlers`, 3 in `EnemyInitBasic`, 1 in `RandomPlayerOffset`). `npm run extract:lt` then `npm run rebuild`: `artifacts/crc.json` = checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged). With comments and the `; {address}` tags stripped, the code of `EnemyInitBasic` and `RandomPlayerOffset` is identical to HEAD; `interaction_handlers` differs only by the `---` divider lines that the extractor writes before new part notes.

Suggested commit message: `audit(I037): interaction_handlers pull handlers and axis labels, EnemyInitBasic bits, RandomPlayerOffset hopper`

Please commit when you're ready.
