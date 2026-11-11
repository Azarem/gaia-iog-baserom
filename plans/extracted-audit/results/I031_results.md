# I031 results

Files: `thinkers/hdma_gradient_thinker.asm` (Bank 05), `thinkers/ambient_palette_cycler.asm` (Bank 00), `functions/EnemyDeathFlash.asm` (Bank 00).
Spec: [edits/I031.json](../edits/I031.json). New proposals: [renames/I031_renames.md](../renames/I031_renames.md). New questions: [questions/I031_questions.md](../questions/I031_questions.md).

Conventions (unchanged): verdicts **P/M/F/NA**; dispositions **FIXED / PROPOSED / DEFERRED-EVIDENCE / NOFIX**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 comment density, Q2 value, Q3 accuracy, Q4 mnemonic/address accuracy, Q5 mnemonic opportunity, Q6 part naming, Q7 evidence quality.

### File 1: thinkers/hdma_gradient_thinker.asm (Bank 05)

Evidence: E1 (the whole file read end to end; the V2 builder re-implemented in a scratch script and run for radius 8, 10 and 63: it produces a Bresenham-style circle whose top and bottom rows are a few pixels wide), E2 (`hdma_ramp_tables` for `hdma_channel_config` #26 = WH0 with transfer mode 1, `cop_handlers_hdma_dma` / `QueueHdma` usage, `scene_thinkers` spawn lists via a scratch parser, the parameter writers in `sF7_credits`, `gs2A_shira`, `dream_zoom_controller` and `mu67_vampires`, the `W12SEL` / `WOBJSEL` writes in `sF7_credits` and `gs2A_shira`), E3 `docs/code/bank05-midgame-actors.md` (already calls it a "circle/ellipse rasterizer", consistent with the new notes).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A 25-line note and thin comments; the algorithm, the table layout and the parameters were not explained | FIXED (block note rewritten with parameters, writers, thinkers, double buffer and algorithm sections; 11 part notes, 125 comments: 79 new, 46 updated) |
| Q2 | M | A reader could not tell what the file draws or who uses it | FIXED |
| Q3 | **F** | (a) **It is not a diamond brightness gradient.** `QueueHdma ( ..., #26 )` selects `hdma_channel_config` entry `#26` = WH0 (`$2126`) with transfer mode 1, so each scanline writes WH0 (left edge) and WH1 (right edge) of PPU window 1. The stored word is (left = centreX - w, right = centreX + w, each clamped to 0..255); the empty-window word `$00FF` (left > right) fills the lines outside. Nothing here touches brightness. (b) **Parameters**: `$F6` centre X, `$FA` centre Y, `$FE` radius (negative = off); `$F4` / `$F8` / `$FC` are the values of the last build, not "intensity / radius / centre offset"; `$FC` doubles as the decision variable inside the builder. (c) **Users**: scene F7 (credits, variant 1) and scenes 2A (Gold Ship dream) and 67 (Mu vampire lair) (variant 2), not "ending credits only"; writers listed in the block note. (d) **Double buffering** is not per frame: `chatPtr` is incremented only when `HdmaParamChangeCheck` sees a change, bit 0 picks buffer A (`$7E7000`, rows around `$7E7600`) or B (`$7E7100`, rows around `$7E7A00`); `$7E7200` holds the shared empty word, and `$04` is the "brightness value" the old comments mention (it is a pointer to that word). (e) **Helpers**: `HdmaSegmentSplitDown` emits hold entries (count 1-127, one data word per segment) for the lines above the circle, `HdmaSegmentSplitUp` emits repeat-mode entries (count with bit 7 set: HDMA's repeat flag, **not** a direction bit) whose data pointer advances 2 bytes per line. (f) **Default table**: the builder writes "1 line of empty window + end marker" first, so a negative radius leaves a valid table. (g) **V1 vs V2**: V1 uses half-resolution line counts (radius + 1 circle lines, hold lines (2 x centreY - radius) / 2), a one-byte row stride, no "centre above screen" tests and steps x by 2; its credits result is unverified. (h) **Variant 1 never restores `$FC`**, so while the radius is not negative it rebuilds every frame and the buffers alternate every frame; variant 2 restores it with `HdmaCopyCurrentToPrev` and rebuilds only on a change. (i) `HdmaInitPrevState` comments named the wrong fields (the order is centre X, centre Y, radius). (j) The old text "Queue buffer A / B" did not say which register set; now config #26 | FIXED (block note, part notes and all affected comments) |
| Q4 | M | The `$F4`..`$FE` field comments named intensity / radius / centre offset; `HdmaParamChangeCheck` and `HdmaCompareParams` pairs were mislabelled | FIXED |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | `Gradient`, `SegmentSplitDown/Up`, `crF7_thinker_05FB16`, `thinker_def_05FB32`, `code_05FBE5` / `code_05FD26` describe neither the circle window nor the hold / repeat distinction | PROPOSED (R-I031-1) |
| Q7 | M | E1 + E2 for everything except the visual result. V2 was simulated for the shape; the V1 byte layout (one-byte writes read at a two-byte stride) and its effect in the credits, the Mu window setup and the meaning of the `$33` / `$03` window selects are static conclusions | DEFERRED-EVIDENCE (OQ-I031-1 to OQ-I031-3) |

### File 2: thinkers/ambient_palette_cycler.asm (Bank 00)

Evidence: E1 (`PaletteRestart` / `PaletteStep` in `cop_handlers_palette`; the bundle decoder run on bundles `$30`, `$13`, `$32`, `$3F`, `$01`, `$44`), E2 (all 59 spawn entries of `tables/scene_thinkers`, via the scratch parser: about 37 spawn lists, bundle IDs by scene), E3 none.

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | P | Short note and no comments | FIXED (block note rewritten, 1 part note, 3 comments) |
| Q2 | M | The note did not explain that `PaletteStep` runs a whole bundle | FIXED |
| Q3 | M | (a) **Not "PaletteStep every frame forever"**: `PaletteStep` keeps its entry point on itself and yields until the bundle's last strip frame has been shown; then execution reaches `BRA` and `PaletteRestart` starts the bundle again. (b) **Size**: the routine is 6 bytes, not 8 (46370-46375). (c) **Examples were guesses** ("torch flicker, water shimmer, sky gradients"); decoded examples are bundle `$30` (a six-colour ramp from CGRAM colour `$72`, rotated one colour per one-frame strip) and `$13` (four frames of a 16-colour palette from colour `$C0`). (d) "59 spawn entries" is exact; the old "~60" was close | FIXED |
| Q4 | NA | No literals to check | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | P | `ambient_palette_cycler` / `PaletteCycleLoop` are accurate | NOFIX |
| Q7 | M | E1 + E2; only a few bundles were decoded (several share word tables and decode partially) | DEFERRED-EVIDENCE (OQ-I031-4) |

### File 3: functions/EnemyDeathFlash.asm (Bank 00)

Evidence: E1 (`SetMetasprite`, `StageSpriteFrame`, `AnimOnce`, `SetSpritePalette`, `Die` handlers; `cop_handlers_sprite` frame-list model; `tables/spriteset_enemies` list `sprite_set_0EE084`), E2 (all `EnemyDeathFlash` references in `extracted/`), E3 `docs/code/bank0A-dungeon-enemy-actors.md` (mentions the spawn from `EnemyDefeatDispatch`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Two-line note and no comments | FIXED (block note, 1 part note, 7 comments) |
| Q2 | M | The note said what it does but not for how long or from where | FIXED |
| Q3 | M | (a) **"Brief white flash" is unverified**: `SetSpritePalette #00` clears the actor's OAM palette field, so every sprite keeps the palette stored in its sprite group; the animation is list `#01` of `spriteset_enemies` (`sprite_set_0EE084`, eight frames, hold values 2,2,2,1,0,0,2,2 = 19 ticks, sprite group `0EECA9` used twice). (b) **Spawners**: nine `SpawnListAppend` sites (`StandardEnemyDefeatHandler`, `EnemyDefeatDispatch`, `awB0_zombie`, `awB1_wall_walker`, `gw8A_sand_fanger` with Y +$10, `sg4D_dynapede`, `sg4E_nitropede`, `sg4D_knight_armor` twice) with flags `$0302`, plus a `JumpFar` in `sg4D_dynapede`; "combat handlers and boss scripts" was vague. (c) **`TSB $10` with `$2000`** is followed by `Die` in the same run, so it can never be seen by a rendered frame; the reason for it is unknown | FIXED |
| Q4 | P | Operands match the handlers | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | P | `EnemyDeathFlash` is acceptable for a short death effect | NOFIX |
| Q7 | M | E1 + E2; the frames' graphics and palette were not decoded | DEFERRED-EVIDENCE (OQ-I031-5) |

### Shared gate (I031)

`npm run merge -- edits/I031.json --dry-run` was clean (no transform warnings). After the merge a second `extract:lt` showed that the dry run warned "file resolves to bank0A" for `hdma_gradient_thinker`: `detectBank` takes the first `code_XXXXXX` token anywhere in the file, including notes, and a note mentioned `code_0AF633`. The text was reworded (no `code_` / `loc_` tokens of a foreign bank in notes) and the spec re-merged (1 block note rewritten); the final dry run is clean and reports 0 files to change. Merged totals: 3 block notes, 13 part notes (4 new, 9 updated), 135 comments (89 new, 46 updated). `npm run extract:lt` OK. `npm run rebuild` (after I031 and I032): success, `artifacts/crc.json` = checksum 223006080, crc 2083230829, totalSize 3062204.

Docs that repeat the old claims (not edited, `docs/` is outside the allowed folder): `docs/code/bank0C-scene-spawn-tables-comet.md` line 431 (ambient cycler: "water shimmer, lava glow, torch flicker ... parameter selects which palette rows" is a guess) and line 440 (`sine_hdma_slow_wave` is listed for "Gold Ship, Babel Tower"; see I032), `docs/code/bank05-midgame-actors.md` line 496 ("brightness" parameters). `docs/code/bank0A-dungeon-enemy-actors.md` is consistent with the new notes.

Suggested commit message: `audit(I031): rewrite the HDMA circle-window generator notes (WH0/WH1 window edges, parameters, double buffer, Bresenham algorithm, V1/V2 differences), ambient palette cycler loop semantics and EnemyDeathFlash animation/spawner notes`

Please commit when you're ready.
