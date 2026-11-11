# I033 results

Files: `system/player/player_move_south.asm` (Bank 02), `functions/ActorDisplayModeSwap.asm` (Bank 06), `thinkers/oneshot_coldata_warm_flash.asm` (Bank 00).
Spec: [edits/I033.json](../edits/I033.json). New proposals: [renames/I033_renames.md](../renames/I033_renames.md). New questions: [questions/I033_questions.md](../questions/I033_questions.md).

Conventions as in [I029_results.md](I029_results.md).

### File 1: system/player/player_move_south.asm (Bank 02)

Evidence: E1 (every routine read; the aligned / misaligned branches, the MapCell steps and both FineAdjustX routines worked through with sample values), E2 (`tile_collision` return conventions, `player_move_ns` DispatchNorthMove for the vine / ladder asymmetry, `player_move_diag` SnapXDiagCollision, `player_move_east` SnapXEastCollision, `player_move_main` PlayerMovementTick and the Nudge helpers, `player_character` LadderClimbNorth / LadderClimbSouth / ClimbVineEntry), E3 (`wram-memory-map.md` Player Flags Reference, `docs/code/bank02/tile-collision.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Probe names carried most lines, but the part notes were short and the data conventions (units, carry meaning, which phase calls this) were missing | FIXED (block note with 6 sections, 17 part notes, 146 comment entries) |
| Q2 | M | The reader could not tell what "aligned" meant for the callers or how the two `FineAdjustX` routines move the player | FIXED |
| Q3 | **F** | (a) **Slope header reversed**: `SouthSlopeRight` / `SouthSlopeLeft` set the slope flag (`playerFlags $1000`) when the feet are on a row line, when the cell above is the same type, or when the row offset is >= 8; they move plain only for misaligned + different cell above + offset < 8. The header said the first two cases "apply movement deltas directly". (b) **`playerStateByte` is the high byte of `playerFlags`**: `TSB #$08` sets `playerFlags $0800` (script / ability lock), not a "stair flag"; `TSB #$10` sets `$1000` (on slope / ramp), not a "snap flag". (c) **"64px grid"**: `AND #$FFC0` on sub-pixels is a 16-pixel row line. (d) **`SouthStairsTile`**: a straddling player checks the cell to the RIGHT (`MapCellRight`), not "the cell below". (e) **Ladder state**: `LadderClimbNorth` is the entry used when stepping onto a ladder from above (it reads Down before Up and falls to `LadderIdleSouth`); the `$0008,Y` store is the wait counter, not a "movement sub-state". (f) **`AutoAlignEW_South` ranges**: the east nudge is n >= 6 (not "6-8") and the west nudge n <= 8 (not "1-5"); `$AA` bit `$0040` means the horizontal phase ran, not "diagonal active"; the high nibble of the collision byte is the actor solid mark, not an "overlay layer". (g) **`FineAdjustXEast` / `West` direction**: by the arithmetic East moves X WEST by n + $02 - 16 and West moves X EAST by $02 - n; the names refer to the wall side, and the headers' "slide east along a south wall" is wrong. (h) **`FineAdjustXEast` has no overflow handling for `$02` > 16** where `FineAdjustXWest` does. (i) `SouthWallSouthInteract` ends in `SnapYNorthCollision` (floor + `$40`), unlike the south snap. (j) The "right-descending / left-descending" slope wording is unverified. (k) `$06` / `$09` "south / north wall" names describe the type, not a direction | FIXED in comments and notes; open points in OQ-I033-1..4 |
| Q4 | M | The `CheckSubTileAlignY` / `X` carry meaning was inverted in several comments; the `CMP` operand comments were right | FIXED |
| Q5 | NA | No mnemonic simplification available | NOFIX |
| Q6 | M | `FineAdjustXEast` / `West` name the wall side while the movement is the opposite way; `SouthWallNorth*` / `SouthWallSouth*` name the type | PROPOSED (R-I033-1) |
| Q7 | M | E1 + E2 for every claim; slope geometry, the penetration measure's units and the `$06` / `$09` collision types stay undecoded | DEFERRED-EVIDENCE (OQ-I033-1..4) |

### File 2: functions/ActorDisplayModeSwap.asm (Bank 06)

Evidence: E1 (10 instructions), E2 (all 23 call sites, the `actor-def` header flags of every caller, `InitActorFromSceneData` for the `$0E` / `$10` / `$24` sources, `actor_execution` and `sprite_composition` for the `$1000` / `$2000` meanings, `wa78_water_kid` for the `$24` consumer), E3 (`docs/code/bank06-late-midgame-actors.md` line 246).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A header paragraph and a few comments, none naming the real fields | FIXED (block note, 6 comments) |
| Q2 | M | The header did not say what the saved nibble is or who reads `$24` later | FIXED |
| Q3 | **F** | (a) **`$0E` is the actor's OAM attribute XOR word, not "displayModeFlags"** (that is the global `$09EC`); `$10` is actor flags 1, not a "statusWord". (b) **Not a general "swap"**: of the 25 `actor-def` headers in the 22 caller files, 24 start with flags word `$1000` or `$1800`, so bit `$2000` is already clear and `$1000` already set; only `eu91_shop_queue` starts with `$3000`. For the others the effective work is `$0E = $2000` plus the `$24` save. (c) The saved nibble is the variant index from the scene's actor list; `wa78_water_kid` feeds `$24` to `SwitchCase` | FIXED; the effect on drawing / priority is OQ-I033-6 |
| Q4 | M | `AND #$000F` / `STA $24` comments named the wrong source | FIXED |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | The name says "display mode" but the code works on `$0E` / `$10` actor fields | PROPOSED (R-I033-2) |
| Q7 | M | E1 + E2; the runtime effect of priority 2 on those NPCs is not checked | DEFERRED-EVIDENCE (OQ-I033-6) |

### File 3: thinkers/oneshot_coldata_warm_flash.asm (Bank 00)

Evidence: E1 (two COLDATA stores decoded by channel bit), E2 (`tables/scene_thinkers.asm` placements and the scene index tags, `system_init` `UploadCgramPalette`, `scene_lifecycle` backdropColors zeroing, `thinker_execution` filter-word meanings), E3 (`docs/code/bank00/thinkers-palette.md`, `bank00/README.md`, `bank0C-scene-spawn-tables-comet.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | One header paragraph, no comments | FIXED (block note, 7 comments) |
| Q2 | M | The header did not say what `$66` / `$82` mean as COLDATA bytes | FIXED |
| Q3 | **F** | (a) **Values**: `$66` sets red and green to 6, `$82` sets blue to 2, so the fixed colour is R6 G6 B2 (add / subtract is decided by CGADSUB, not here). (b) **Placement**: the header says "Larai Cliff and related overworld scenes"; the table places it in lists `$0CE850` (scene `$23`, slot 2) and `$0CE872` (scene `$27`, slot 0). `thinkers-palette.md` says one-shot thinkers "are not placed in scene thinker tables" and gives indices 34 / 29, neither true for the table tags. (c) **Not a flash**: nothing reverts the colour, it persists until another COLDATA write | FIXED in the asm; docs in R-I033-3 |
| Q4 | M | Operands correct | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | "warm flash" implies a transient | PROPOSED (R-I033-3) |
| Q7 | M | E1 + E2; scene identities and the colour-math mode are not decoded | DEFERRED-EVIDENCE (OQ-I033-5) |

### Shared gate (I033)

`npm run merge -- edits/I033.json --dry-run` reported one length warning (comment `{185341}` 163 characters), the comment was shortened and the dry run was then clean. The `ActorDisplayModeSwap` block note was extended once after the caller-header check and the spec re-merged (idempotent). Merge applied: 3 block notes, 17 part notes, 159 comment entries (146 in `player_move_south`, 6 in `ActorDisplayModeSwap`, 7 in `oneshot_coldata_warm_flash`). The code lines of all three files are identical before and after (comments only). Gate checked once after both I033 and I034: `npm run extract:lt` OK, `npm run rebuild` OK, `artifacts/crc.json` = checksum 223006080, crc 2083230829, totalSize 3062204. OQ-I026-1 (extract:lt + rebuild differs from a plain extract + rebuild) still applies.

Suggested commit message: `audit(I033): player_move_south align/slope/FineAdjust directions, playerStateByte high byte and units; ActorDisplayModeSwap works on $0E/$10 actor fields; warm flash COLDATA R6 G6 B2 placements`

Please commit when you're ready.
