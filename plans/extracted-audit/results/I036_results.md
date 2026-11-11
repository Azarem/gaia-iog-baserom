# I036 results

Files: `actors/ramps.asm` (Bank 00), `thinkers/flag_gated_palette_warm.asm` (Bank 00), `thinkers/flag_gated_palette_cool.asm` (Bank 00). Related data notes corrected in the same spec: `system/hdma_ramp_tables.asm` (`ramp_motion_curves`, `ramp_curve_arc_64`, `ramp_curve_arc_32`).
Spec: [edits/I036.json](../edits/I036.json). New proposals: [renames/I036_renames.md](../renames/I036_renames.md). New questions: [questions/I036_questions.md](../questions/I036_questions.md).

Conventions (unchanged): verdicts **P/M/F/NA**; dispositions **FIXED / PROPOSED / DEFERRED-EVIDENCE / NOFIX**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 comment density, Q2 value, Q3 accuracy, Q4 mnemonic/address accuracy, Q5 mnemonic opportunity, Q6 part naming, Q7 evidence quality.

### File 1: actors/ramps.asm (Bank 00)

Evidence: E1 (the whole file read end to end; `stair_climb.RestorePlayerControl`, `StagePlayerMoveXY`, `AnimOnce`, `LoopEnd`, `JumpNextFrame`, `SpawnAfter` and `AllocateActorAfter` for the child link, `InitActorFromSceneData` for the `$0E` derivation, `ApplyMovement`, `movement_delta_table` chains `$0F` / `$10`, the arc curves summed with a script), E2 (all 58 `ramps.*` lines in `scene_actors` extracted per scene with a scratch script; `scene_actors` names the scene list), E3 `docs/code/bank0C-scene-spawn-tables-comet.md` line 329, `docs/code/bank00/actors-infrastructure.md` lines 270 and 305, `docs/bank01-data-tables.md` line 706.

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A two-paragraph header and no comments on about 860 bytes of dense code | FIXED (block note with the two-stage watch, window table, launch, east/west and north/south climbs, placement and quirks; 22 part notes; 223 comments) |
| Q2 | M | A reader could not tell what the ramps are or what the child actor does | FIXED |
| Q3 | **F** | (a) **They are jump launchers, not collision tiles or tile slopes** (the docs say "Eastward ramp collision" and "tile-based slope physics"). The ramp takes the player's script over and moves the player 8 pixels per frame along one axis. (b) **Detection windows**, per ramp: east = player X - ramp X in 2..15 and `|dy| <= $18`; west = -16..-2; north = player Y - ramp Y in 2..15 and `|dx| <= $10`; south = -16..-2. The direction of the speed is not tested, only `|speed| >= 6` and the `$0800` lock being clear. (c) **Two stages**: stage 1 arms, stage 2 launches only on EXACT equality of the axis coordinates and falls back to stage 1 at a distance of `$10`. (d) **The arc child's target is the player** (confirmed: `AllocateActorAfter` sets the child's `$04` link to the spawner), where the old curve note said "inferred". (e) **Arc numbers**: type 1 = 64 frames, peak rise 204 pixels at frame 28, sum 0; type 3 = 32 frames, peak 50 pixels at frame 14, sum +8. (f) **North/south have no child and no arc**: `statsPtr` is a loop count of animation cycles (type `$09` = 4, `$0B` = 5, `$11` = 8, `$03` = 1). (g) **The label pairs are swapped**: `ramp_east_step` is the north loop head, `ramp_north_step` the south one; `loc_00D518` is the north entry and `loc_00D4F5` the west entry. (h) **Scratch**: `$0018` / `$001C` are global WRAM bytes, not the ramp's direct page. (i) **Placement**: 58 spawns, 26 east / 22 west / 6 north / 4 south, in 20 scenes; the docs' counts for east and west agree | FIXED |
| Q4 | M | The ramp names describe the side the ramp is on relative to the player, which the old header did not say; `statsPtr` is reused as the curve index or loop count | FIXED (block note, comments) |
| Q5 | M | `orbitAngle` and `orbitDiameter` are orbit-actor mnemonics reused as curve offset and exit speed | PROPOSED (R-I036-4) |
| Q6 | M | `loc_00D4F5`, `loc_00D518`, the swapped step labels, `func_00D5C0` and twelve stage labels are named by address or by the wrong direction | PROPOSED (R-I036-1, R-I036-2, R-I036-3, R-I036-5) |
| Q7 | M | E1 + E2 for geometry, flow, curves and placement; whether the exact-equality trigger always fires, the animation indices `$19` / `$1E` / `$21` / `$24` and the on-screen distance covered were not verified | DEFERRED-EVIDENCE (OQ-I036-1 to OQ-I036-4) |

### File 2: thinkers/flag_gated_palette_warm.asm (Bank 00)

Evidence: E1 (the six instructions; `BranchOnFlagByte`, `WaitOnFlagByte`, `SetFlagByte`, `PaletteStart`, `PaletteStep`; `scene_lifecycle` and `inventory_overlay` for flag `$FF`), E2 (palette bundle `$02` decoded with the bundle script: 1 frame, 80 colours from index `$30`; `scene_thinkers` lists for scenes `01` and `30`; `sc02_erik` sets `$16`, `sc06_monologue` sets `$1C`; searched for any clear of `$16` / `$1C`: none), E3 `docs/code/bank00/thinkers-palette.md` lines 78-124, `docs/code/bank00/README.md` lines 131 and 481.

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | One-line header, no comments | FIXED (block note, 2 part notes, 8 comments) |
| Q2 | M | The header hid the gate semantics and the flag `$FF` handshake | FIXED |
| Q3 | **F** | (a) **The gate is evaluated once at spawn.** The loop target lies after the gate, so the thinker does not "kill itself when conditions flip". (b) **Flags**: `$16` is set by the Kara-news cutscene (`sc02_erik`), `$1C` by Will's end-of-day narration (`sc06_monologue`); the thinker lives between them. (c) **It sets `$FF` itself** after one palette step and then parks until `$FF` clears (next scene setup or an inventory open). (d) **Spawned in scenes `01` and `30`** (South Cape and Oakton), not "Oakton" only; at Oakton the gate should fail because `$1C` is never cleared (inferred). (e) **The parameter byte is ignored** | FIXED |
| Q4 | P | Mnemonics and operands are as annotated | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | Neither "flag_gated" (the gate is spawn-time only) nor "warm" (not verified visually) is supported | PROPOSED (R-I036-6) |
| Q7 | M | E1 + E2; whether the loop ever replays and what the swap looks like are open | DEFERRED-EVIDENCE (OQ-I036-5, OQ-I036-6) |

### File 3: thinkers/flag_gated_palette_cool.asm (Bank 00)

Evidence: as File 2, plus palette bundle `$4C` decoded (1 frame, 7 colours from index `$19`) and the `scene_thinkers` lists of scenes `03`-`08` (the cool thinker sits next to a `parallax_thinker` type `$02` COLDATA gradient in each).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | One-line header, no comments | FIXED (block note, 2 part notes, 8 comments) |
| Q2 | M | As File 2 | FIXED |
| Q3 | **F** | (a) **Same gate and `$FF` behaviour as the warm thinker.** (b) **Spawned only in scenes `03`-`08`**, the South Cape interiors (Lance's, Eric's, Seth's and Will's houses, Chef's house, the church); the old notes said "many interior and Dark Space scenes" and the docs call it "Overworld". (c) **Bundle `$4C` is a 7-colour step starting at colour `$19`**, not a full-palette change | FIXED |
| Q4 | P | Mnemonics and operands are as annotated | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | As File 2 | PROPOSED (R-I036-6) |
| Q7 | M | As File 2 | DEFERRED-EVIDENCE (OQ-I036-5, OQ-I036-6) |

### Shared gate (I036)

`npm run merge -- plans/extracted-audit/edits/I036.json --dry-run` first showed that the `hdma_ramp_tables` entry (which carried a null block note from the builder) would REMOVE the block note written by I035. The spec was corrected to omit `blockNote` and `comments` for that file and the dry run was clean. Merged totals: 3 block notes (updated), 29 part notes (26 new, 3 updated), 239 comments (all new). A second dry run after `npm run extract:lt` reports 0 files to change. `npm run rebuild` succeeded with `artifacts/crc.json` at checksum 223006080 / crc 2083230829 / totalSize 3062204 (unchanged). No `.asm` file was edited by hand and `ingest` was not run.

Docs that repeat the old claims (not edited, `docs/` is outside the allowed folder): `docs/code/bank0C-scene-spawn-tables-comet.md` line 329 ("Eastward ramp collision"); `docs/code/bank00/actors-infrastructure.md` lines 270 and 305 ("tile-based slope physics"); `docs/bank01-data-tables.md` line 706 ("Acceleration curves for ramp actors"); `docs/code/bank00/thinkers-palette.md` lines 78-124 and `docs/code/bank00/README.md` lines 131-132 and 481-482 (warm "Oakton", cool "Overworld", "Cool-toned" / "blue/cool ambient", "kills itself when conditions flip").

Suggested commit message: `audit(I036): document ramps as two-stage jump launchers (windows, exact-equality trigger, player takeover, east/west arc child vs north/south loop, counts and placement); correct ramp curve notes; fix flag_gated_palette_warm/cool gate, flag $FF handshake, bundles and spawn scenes`

Please commit when you're ready.
