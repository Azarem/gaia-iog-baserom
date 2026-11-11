# I029 results

Files: `system/player/player_move_diag.asm` (Bank 02), `thinkers/oneshot_palette_flash_19.asm` and `thinkers/oneshot_palette_flash_18.asm` (Bank 00).
Spec: [edits/I029.json](../edits/I029.json). New proposals: [renames/I029_renames.md](../renames/I029_renames.md). New questions: [questions/I029_questions.md](../questions/I029_questions.md).

Conventions (unchanged): verdicts **P/M/F/NA**; dispositions **FIXED / PROPOSED / DEFERRED-EVIDENCE / NOFIX**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 comment density, Q2 value, Q3 accuracy, Q4 mnemonic/address accuracy, Q5 mnemonic opportunity, Q6 part naming, Q7 evidence quality.

### File 1: system/player/player_move_diag.asm (Bank 02)

Evidence: E1 (every routine read; stack-depth counting from `PlayerMovementTick` for the `$03,S` / `$05,S` / `$06,S` accesses; arithmetic on `$26` in both ramp handlers; `ApplyMovementDeltas`), E2 (`player_move_main` `PlayerMovementTick`, `player_move_east` `DispatchEastMove` as the mirror, `map_coords` `ProbeRightTiles`, `player_move_ns` `SouthWallNudge` for `$AB`, `tile_collision`, `cop_handlers_collision` for the solid mark), E3 (`docs/code/bank02` and `wram-memory-map.md` descriptions compared; they repeat the old names).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A comment on almost every line, but the block and part notes described a "down-left diagonal" routine that does not exist | FIXED (block note rewritten with velocity/DP, stack-contract, tile-type, ramp and wall-slide sections; 13 part notes; 62 comment entries) |
| Q2 | M | The notes did not say which phase this code belongs to, what the stack offsets address, or that `$24` is a Y velocity | FIXED |
| Q3 | **F** | (a) **The routine is not "down-left diagonal" movement.** `PlayerMovementTick` sends a negative `$20` here and a positive `$20` to `DispatchEastMove`, both after setting `$AA` bit `$0040`; the probes are the left corners TL/BL, the mirror of the east file's TR/BR. It is the west half of the horizontal phase. (b) **`$24` is the Y velocity**, not an "X snap adjustment": `ApplyMovementDeltas` adds `$24` to `$26`. `DiagPushLeft/Right`, `DiagRampEdgeUL/DR` and the block note's DP list all called it an X snap. (c) **`DiagClearReturnFlags` does not clear "return flags"**: with the `JSR` return address on top, `$05,S` is the vertical velocity word that `PlayerMovementTick` parked with `PHA`; zeroing it cancels the vertical phase. `DiagAutoAlignNS` (`$06,S` after its own `PHP`) and the push routines (`$03,S`) read the same word; they were described as an "EW return flag" and a "return threshold". (d) **The slope probes move X, not Y**: the code adds 8 to `$1A` (X pixel) after `ProbeCurrentTL/BL/FutureTL`; the comments said "Y raised +8px" four times, and the edge handlers' "minus 9" is likewise an X offset (the TR probe point moved 9 pixels left, net X - 1). (e) **Ramp direction**: on a `$05` slope the code adds `-$20` (positive, since `$20` is negative going west) to `$26`, so Y grows and the player goes down-left; on `$0A` it adds `$20`, so Y shrinks (up-left). The names `DiagRampUpLeft` ("ascending") and `DiagRampDownRight` say the opposite. (f) **`CheckSubTileAlignY` sense was reversed in two comments**: carry clear means aligned; "Y misaligned + `$09`" and "Y aligned + `$09`" at the two `CMP #$09` after the `BCS` were swapped. (g) `SnapXDiagCollision` "64px grid centre" mixed units: 64 sub-pixels = 16 pixels; the formula is `(((X + $20) - $0020) & $FFC0) + $60`, the nearest tile centre. (h) "+4px" / "-4px" ramp bumps are +4/-4 sub-pixels (1 pixel). (i) `$AA` bits `$0800`/`$0400` are called "south/north-wall collision flags" but nothing in the extracted code sets them (only `$0040` is set); `$AB` bits 2, 3 and 7 are set and never read, bit 1 is read by `SouthWallNudge`. (j) `ComputeDiagSnapOffset` wall path is taken when the Y row is OFF the boundary (carry set) and the cell below is `$06`, not "aligned". (k) `$06`/`$09` are labelled "north"/"south" wall in this file and the opposite way in `player_move_east`; the meaning is undecoded (audit OQ-16), so the notes call them handler names. (l) `player_move_east` header says `DiagPushRight` slides the player upward; the arithmetic (`$24` positive, Y grows) says downward (OQ-I029-4) | FIXED in this file; cross-file items in OQ-I029-4 |
| Q4 | M | Operands correct; the "X snap" and "Y raised" comments pointed at the wrong variable | FIXED |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | **F** | `player_move_diag`, `DispatchDiagDownLeft`, `Diag*` and the `UpLeft` / `DownRight` ramp names describe a diagonal that does not exist | PROPOSED (R-I029-1 to R-I029-3) |
| Q7 | M | E1 + E2; the stack-contract reading and the ramp direction are static conclusions (stack-depth counting, sign of `$26`) | DEFERRED-EVIDENCE (OQ-I029-1 to OQ-I029-5) |

### File 2: thinkers/oneshot_palette_flash_19.asm (Bank 00)

Evidence: E1 (the three COP ops), E2 (`cop_handlers_palette` PaletteStart/PaletteStep notes, `hdma_dma_spc` LoadPaletteBundle / DecompressGfxToVram notes, `system_init` backdrop upload note, the bundle bytes in `tables/palette_bundles.asm` decoded with a throwaway script), spawn sites read in `sE8_dark_gaia`, `awBF_spirit_guide`, `awBC_blinding_light`, `mu66_rama_spirits`, `it15_lily`, `future_vision_cutscene` (all found by grepping `oneshot_palette_flash_1[89]` over `extracted/`); E3 (`docs/code/bank00/thinkers-palette.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A two-paragraph note and no comments | FIXED (block note, 3 comments) |
| Q2 | M | "Runs palette animation #19 for a single step" hid what the thinker does and how long it lives | FIXED |
| Q3 | **F** | (a) **Not a single step**: `PaletteStep` re-runs every tick and only continues the script when the bundle is finished, so the thinker lives for all 32 frames. (b) **Bundle #19 decoded**: one 32-frame strip of 3-byte backdrop triplets (`backdropColors` `$7F0C00`, written verbatim to COLDATA by the NMI), 3 extra ticks per frame; (R,G,B) starts at (27,27,31), moves to (31,16,16) around frames 15-16, then fades to (0,0,0). The docs' "return-to-normal / inverse white" is a guess; it is a red-tinted fade-out to black. (c) "Used immediately after flash #18 in many cutscenes... Comet Lair" is right for the five paired sites; `future_vision_cutscene` spawns it alone, and `awBC_blinding_light` spawns it only when the Black Crystal Glasses are equipped. (d) `docs/unused-mode7-boss-analysis.md` says the unused boss uses it; no spawn exists in `unused_mode7_boss.asm` | FIXED (a to c); (d) as a docs row in R-I029-5 |
| Q4 | NA | Bundle id is a literal | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | `oneshot_palette_flash_19` says nothing about the red fade-out | PROPOSED (R-I029-4) |
| Q7 | M | E1 + E2 for the decode; colour visibility depends on colour-math registers set by the spawners, not traced for every spawner | DEFERRED-EVIDENCE (OQ-I029-6) |

### File 3: thinkers/oneshot_palette_flash_18.asm (Bank 00)

Evidence: as for file 2.

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A two-paragraph note and no comments | FIXED (block note, 3 comments) |
| Q2 | M | Same as file 2 | FIXED |
| Q3 | **F** | (a) Same "single step" error (`PaletteStep` plays the whole bundle). (b) **Bundle #18 decoded**: 32 frames, 3 extra ticks per frame, (R,G,B) from (0,0,0) to (27,27,31): blue rises 2 per frame until it saturates at frame 15, red and green keep rising by about 1 per frame, so the end colour is a bluish white. It is the white ramp-up half of the flash; the old text called the pair "warm-then-cool", which does not match the data (the first half is white-blue, the second half goes through red to black). (c) **The earlier asm note listed an Edward Castle spawn that does not exist** (`thinkers-palette.md` does not claim it); the extracted code spawns it only from `sE8_dark_gaia` (twice), `awBF_spirit_guide`, `awBC_blinding_light`, `mu66_rama_spirits` and `it15_lily`. (d) `mu66_rama_spirits` and `it15_lily` write CGWSEL / CGADSUB right before spawning it (values not decoded here), which is presumably what makes the fixed colour visible | FIXED |
| Q4 | NA | Bundle id is a literal | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | As file 2 | PROPOSED (R-I029-4) |
| Q7 | M | As file 2 | DEFERRED-EVIDENCE (OQ-I029-6) |

### Shared gate (I029)

`npm run merge -- edits/I029.json --dry-run` clean (no transform warnings, all `expect` strings matched), merge applied: 3 block notes, 13 part notes, 68 comment entries (62 in `player_move_diag`, 3 + 3 in the flash thinkers). `npm run extract:lt` OK, `npm run rebuild` OK. `artifacts/crc.json` = checksum 223006080, crc 2083230829, totalSize 3062204 (the gate checked once after I029 and I030 together).

Side findings recorded outside the iteration's files:
- `notes/comments/bank00.json` key `47052` ("One-shot PaletteStart #18 + PaletteStep then immediate KillThinker") is attached to the `thinker-def` header bytes of `oneshot_palette_flash_18`; no output line renders it and the merge script cannot remove it (stale text: "PaletteStep" plays the whole bundle). Needs a manual cleanup by the owner.
- The `extract` text in `extracted/` before this iteration was a normal extract (no `{addr}` tags); `npm run extract:lt` was re-run first, as the process requires.

Suggested commit message: `audit(I029): player_move_diag is the west horizontal-phase dispatcher ($24 is Y, stack-parked vertical velocity, X+8 slope probes, ramp direction); palette flash #18/#19 decoded (COLDATA fade, whole-bundle thinkers)`

Please commit when you're ready.
