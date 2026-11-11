# I040 results

Files: `system/player/player_move_east.asm` (Bank 02), `thinkers/palette_parent_child.asm` (Bank 00), `actors/large_ramps.asm` (Bank 00).
Spec: [edits/I040.json](../edits/I040.json). New proposals: [renames/I040_renames.md](../renames/I040_renames.md). New questions: [questions/I040_questions.md](../questions/I040_questions.md).

Conventions as in [I029_results.md](I029_results.md).

### File 1: system/player/player_move_east.asm (Bank 02)

Evidence: E1 (all 445 lines read with `extract:lt` addresses; the dispatcher order, both gap chains, the Y auto-align ranges and `ComputeEastSnapOffset` traced by hand, including the stack depth that makes `$06,S` the parked vertical velocity), E2 (`map_coords` `ProbeLeftTiles` (the dispatcher's slope search, centre column), `tile_collision` probes / `MapCell*` / `CheckSubTileAlign*` / `ReadCollisionNibble` (actor solid mark in the high nibble), `player_move_diag` mirror code, `DiagPushRight` / `DiagPushLeft` / `ComputeDiagSnapOffset`, `player_move_main` `NudgeToLowerGrid` / `NudgeToUpperGrid`, `player_move_ramps` callers of the `EastWall*Diag` entries, `player_move_ns` and `player_move_south` callers of `SnapXEastCollision`), E3 (`docs/code/bank02/player-movement.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Every line had a comment, but the header, five handler notes and about 15 inline notes disagreed with the code | FIXED (block note rewritten: conventions, dispatch order, wall-slide handlers, auto-align and snap offset; 13 part notes replaced; 48 comment entries, 11 new and 37 replaced) |
| Q2 | M | The reader could not tell which case runs the gap chains, which way the slides push, or what the auto-align gates are | FIXED |
| Q3 | **F** | (a) **Slope entry names**: the header (and three inline comments) sent the `$05` `ProbeLeftTiles` result to `WestRampDown`; the code jumps to `WestRampUp` (carry set), and the late `ProbeCurrentBL` `$05` goes to `WestRampDown`, not `WestRampUp`. ProbeLeftTiles samples the centre column, not "8 px to the left". (b) **Aligned / straddling inverted**: the `MapCellDown` read in the dispatcher runs when Y straddles two rows; in the wall handlers the gap chain runs when X straddles and the corner type matches, and the `SnapY*Collision` re-probe path runs when X is flush or the type differs. The header said the opposite twice. (c) **Push directions inverted**: `DiagPushRight` (north handler, TR `$09`) stores a positive `$24` and pushes Y DOWN; `DiagPushLeft` (south handler, BR `$06`) pushes UP. The header, the handler notes and four inline comments said up and down respectively (this answers the east side of [OQ-I029-4](../questions/I029_questions.md) statically). (d) **`AutoAlignNS_East`'s stack guard** reads the parked VERTICAL velocity at `$06,S` (PHP plus two return addresses above it), not an "EW velocity"; the collision-byte gate is the actor solid mark (high nibble), not an "overlay / special layer". The nudge ranges: n = 1..3 north only, 4..10 south preferred, 11..15 south only, with 2 px per call. (e) **`SnapXEastCollision`**: the formula `($20+$22-$20)` hid that the second `$20` is the constant 32; the result is the centred column of the stepped left edge, right edge flush to the wall; it only moves X west when `$20` is 0. (f) **`SnapYNorthCollision` in `EastWallNorthHandler`** runs with `$24 = 0`, so it pushes the player DOWN to the next row line (1..16 px). (g) **`ComputeEastSnapOffset`**: "right-half alignment" was wrong; carry set (Y straddling) reads the cell below the current TR. (h) `$AB` bits 7 / 2 / 3 are set here and never read (OQ-I029-3). (i) `EastLadderTile`'s "West prefix" remark refers to a former name; the routine is the east case with `ShimmyRightEntry` | FIXED (all as note text) |
| Q4 | M | Operands correct; the stack-slot and axis descriptions were wrong as above | FIXED |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | The `North` / `South` in the handler names read as directions; the pushes go the other way | PROPOSED (R-I040-2) |
| Q7 | M | E1 + E2; slide directions, the `$06` / `$09` meanings and the auto-align feel have no runtime check | DEFERRED-EVIDENCE (OQ-I040-4, OQ-I029-4, OQ-I029-5) |

### File 2: thinkers/palette_parent_child.asm (Bank 00)

Evidence: E1 (all 19 script lines), E2 (`cop_handlers_palette` `PaletteStart` / `PaletteStep`, `cop_handlers_thinker` `SpawnThinker` / `KillThinker`, `thinker_execution` runner filters, `cop_handlers_scene_flags` flag-sense table, `scene_thinkers.asm` spawn records, `rg` for other `PHD` / `TCD` / `KillThinker` sites), E3 (`docs/code/bank0C-scene-spawn-tables-comet.md:444`, `docs/code/bank00/README.md:483`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A three-line header and 8 sparse inline comments | FIXED (block note, 2 part notes, 18 comment entries) |
| Q2 | M | The header did not explain the kill sequence, the filter word or the polling | FIXED |
| Q3 | M | (a) The header is broadly right (parent starts bundle #03, flag `$01` spawns a stepping child). (b) Added: `thinker-def <#00,#08>` = filter word `$0800` (TypeA / TypeC); the child inherits it; the kill works by setting X = D = the child slot (the only other site is the unused `SceneTransPaletteThinker_unused`); the parent restarts bundle #03 at sub-entry 0 after each kill; parent and child keep separate bundle IDs. (c) The spawn records pass parameter `#03`, which the script overwrites with the same number. (d) The doc says "World Map, Inventory"; the records show scenes `$FD` and `$FF` only | FIXED |
| Q4 | M | Operands correct | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | Names are descriptive enough | NOFIX |
| Q7 | M | E1 + E2; which scripts set / clear flag `#01` in scenes `$FD` / `$FF`, and what bundle `#03` contains, were not traced | DEFERRED-EVIDENCE (OQ-I040-3) |

### File 3: actors/large_ramps.asm (Bank 00)

Evidence: E1 (all 17 instructions), E2 (`BranchIfPlayerNear` handler (radius r gives a box of r * 16 + 1 px on both axes), `actor_execution` re-entry semantics, `scene_actors.asm` spawn records for `ir21` and `dm41`), E3 (`docs/code/bank00/actors-infrastructure.md:262-292`, `docs/code/bank00/README.md:592`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A two-line header and no inline comments | FIXED (block note, 3 part notes, 11 comment entries) |
| Q2 | M | The control flow (which test runs after which `SetEntryHere`) was undocumented | FIXED |
| Q3 | **F** | (a) **The boost is applied once per approach, not each frame**: after `LargeRampBoostEastWest` the entry is the radius-3 test, whose target is a bare `RTL`, so the actor idles until the player is farther than 48 px, then the speed gate and the radius-2 test run again. (b) **`playerSpeedNs` is never changed** (only read for the gate); the header ("increments playerSpeedEw or playerSpeedNs") and the docs ("also adjusted", "repeats while player remains near") are wrong. `LargeRampBoostNorthSouth` is an empty `RTL`. (c) A zero EW speed is incremented to `+1` (east) even when only the NS speed was nonzero. (d) The speed gate is only re-checked after the player has been farther than 48 px (the first `SetEntryHere` moves the entry past it). (e) Radius `#02` is a 32-px box and `#03` a 48-px box, not "2-tile proximity" | FIXED (as note text) |
| Q4 | M | Operands correct | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | `LargeRampBoostNorthSouth` has no north-south behaviour | PROPOSED (R-I040-1) |
| Q7 | M | E1 + E2; the real feel (a one-time +/-1 per approach) has no runtime check | DEFERRED-EVIDENCE (OQ-I040-1, OQ-I040-2) |

### Shared gate (I040)

`npm run merge -- edits/I040.json --dry-run` was clean. Merge applied: 3 block notes, 13 part notes replaced and 7 added (the 13 are the `player_move_east` labels), 77 comment entries (48 in `player_move_east`, 18 in `palette_parent_child`, 11 in `large_ramps`). `npm run extract:lt` then `npm run rebuild` (one run for I039 + I040): `artifacts/crc.json` = checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged). With comments and tags stripped the code of all six files is identical to HEAD; `player_move_east` and `player_move_ns` are line-for-line identical, the four small files differ only by `---` separator lines in front of newly added part notes.

Suggested commit message: `audit(I040): player_move_east dispatch order, slide directions and auto-align, palette_parent_child kill sequence, large_ramp_booster one-shot boost`

Please commit when you're ready.
