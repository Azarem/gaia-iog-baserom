# I038 results

Files: `system/player/player_move_ramps.asm` (Bank 02), `actors/camera_delta_oscillator.asm` (Bank 08), `functions/ActorMidpointCalc.asm` (Bank 0A).
Spec: [edits/I038.json](../edits/I038.json). New proposals: [renames/I038_renames.md](../renames/I038_renames.md). New questions: [questions/I038_questions.md](../questions/I038_questions.md).

Conventions as in [I029_results.md](I029_results.md).

### File 1: system/player/player_move_ramps.asm (Bank 02)

Evidence: E1 (all 453 lines read with `extract:lt` addresses; every probe, branch and arithmetic sequence traced including the stack frame of `DiagClearReturnFlags`), E2 (`tile_collision` probe conventions, `map_coords` `ProbeLeftTiles`, `player_move_east` dispatcher and its two ramp entry points, `player_move_diag` `DiagClearReturnFlags`, `rg` over `extracted/` and `docs/` for every caller), E3 (`docs/code/bank02/player-movement.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Every line had a comment, but the block header, the four routine headers and most inline notes disagreed with the code | FIXED (block note with entry map, coordinates and common flow; 4 part notes replaced; 52 comment entries) |
| Q2 | M | The reader could not tell how the four handlers are reached, what `$1A` is, or what the Y maths computes | FIXED |
| Q3 | **F** | (a) **`$1A` is the probe pixel X**, so "Shift probe Y up 8px", "Raise probe Y +8px", "$1A -= 9 ... Y raised 9px" and similar (six inline comments) were wrong: the probe moves 8 or 9 px west, onto the centre column. (b) **"Shared between east and diagonal dispatchers"**: only `DispatchEastMove` calls the four handlers. (c) **`code_02D92F` / `code_02DA7A`** are reached when TR is open and BR solid and call `SnapYSouthCollision` (the comment said "TR-only wall hit -> SnapXEastCollision"); **`code_02D937` / `code_02DA82`** are reached when TR is solid and BR open and call `SnapYNorthCollision` (the comment said "BR-only"). (d) **"$26 += $20 (8px NS velocity contribution)"**: `$20` is the X velocity, copied 1:1 into Y; and the direct path is taken when the sample cell itself is the slope, not "no boundary cross". (e) **"Y from mean X sub-tile position"**: n is the pixel offset past the column line after the step, and `+$0004` is one pixel (positions are quarter pixels), not a half-pixel. (f) **Header "Despite the 'West' prefix"** sits above `EastRampDown`. (g) **`WestRampDown` header** "positive, producing upward displacement": `$24 = 4n - $20` is negative while `4n < $20`, and positive `$24` is downward. (h) **"Round X to 8px grid"**: the corner snap floors the post-step left edge to a 16-px line and adds 8, so it only moves west. (i) "DiagClearReturnFlags ... reset collision state": it zeroes the parked vertical velocity at `$05,S` | FIXED |
| Q4 | M | Operands are correct; the register / axis descriptions were wrong as above | FIXED |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | `EastRampUp` descends along `$0A` on its direct path, so Up / Down does not describe the motion; the `code_02D92F`-style names hide their role | PROPOSED (R-I038-1, R-I038-2) |
| Q7 | M | E1 + E2 for control flow and arithmetic; the odd `+4` bias test (sum of a Y position and X values), the identical Y sign in both corner snaps and the top-row versus bottom-row sample asymmetry have no runtime check | DEFERRED-EVIDENCE (OQ-I038-1, -2, -5) |

### File 2: actors/camera_delta_oscillator.asm (Bank 08)

Evidence: E1 (13 instructions), E2 (`camera_tilemap` layer-1 delta mode, `camera_scroll` delta computation, `rg` for any spawn or entry reference: none), E3 (`docs/code/bank08-native-dao-pyramid-actors.md:249`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Three-line header, five short comments | FIXED (block note, 3 comment entries) |
| Q2 | M | The header called the effect a "subtle wobble" | FIXED |
| Q3 | **F** | (a) Bit 9 of `$0036` flips every 512 frames and the actor steps `cameraDeltaY` by 1 per frame, so it ramps 512 and back: a slow drift, not a wobble. (b) `cameraDeltaX/Y` are the layer-1 / effect scroll delta words, not the camera; the "nudge camera down / up" comments overstate it. (c) "Used during pyramid scroll sequences" (docs): no extracted script references the actor | FIXED; usage DEFERRED-EVIDENCE (OQ-I038-4) |
| Q4 | M | Operands correct | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | `camera_delta_oscillator` implies an oscillation; it is a triangle drift of a scroll delta | PROPOSED (R-I038-3) |
| Q7 | M | E1 + E2; no reference means no runtime context | DEFERRED-EVIDENCE (OQ-I038-4) |

### File 3: functions/ActorMidpointCalc.asm (Bank 0A)

Evidence: E1 (21 instructions), E2 (`rg`: callers `mtA0_acid_spider` x2, `awB0_zombie`, `av6E_draco` x2, `dm3D_flayzer`, `unused_mode7_boss`; none in `combat_collision`; the acid spider and zombie loops do not set `$04` / `$06`), E3 (`docs/wram-memory-map.md` `$04` / `$06` links, `docs/unused-mode7-boss-analysis.md:198` "midpoint of its prev/next neighbors").

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A six-line header and short comments | FIXED (block note, 2 comment entries) |
| Q2 | M | The header did not say what `$04` / `$06` are or who calls it | FIXED |
| Q3 | **F** | (a) "Used by combat collision to find the hit point": no such caller. (b) "two actors referenced by DP pointers": these are the actor's own prevActorLink / nextActorLink unless a caller overrides them. (c) The header omits that Y is clobbered and that 16-bit registers are required | FIXED |
| Q4 | M | Operands correct | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | Name matches the behaviour | NOFIX |
| Q7 | M | E1 + E2 + E3; the case `$06 = 0` is untraced | DEFERRED-EVIDENCE (OQ-I038-3) |

### Shared gate (I038)

`npm run merge -- edits/I038.json --dry-run` was clean. Merge applied: 3 block notes, 4 part notes (all replacements of existing headers), 57 comment entries (52 in `player_move_ramps`, 3 in `camera_delta_oscillator`, 2 in `ActorMidpointCalc`). `npm run extract:lt` then `npm run rebuild`: `artifacts/crc.json` = checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged). With comments and tags stripped the code of all three files is identical to HEAD.

Suggested commit message: `audit(I038): player_move_ramps probe axes and snap roles, ActorMidpointCalc callers, camera_delta_oscillator drift`

Please commit when you're ready.
