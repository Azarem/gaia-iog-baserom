# I055 - 2026-10-28 - files: system/boot_logos/boot_logo_palette_third.asm, system/boot_logos/sFB_boot_logo.asm, system/boot_logos/spm_boot_logos.sprite.asm
Status: COMPLETE

Spec: [edits/I055.json](../edits/I055.json). Proposals: [renames/I055_renames.md](../renames/I055_renames.md). Questions: [questions/I055_questions.md](../questions/I055_questions.md).

Conventions: verdicts **P/M/F/NA**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 coverage and verbosity, Q2 value, Q3 accuracy, Q4 mnemonic and variable names, Q5 new mnemonic, Q6 naming, Q7 evidence quality. Annotation style as in I049 to I052: aggregated notes, a part note for every label, inline comments only for operands and non-obvious steps.

This iteration also answers OQ-I054-1 (which OBJ palette each logo uses) statically and corrects the I054 notes of `boot_logo_palette_enix` and `boot_logo_palette_quintet` and two stale statements in `system_core.asm` (see "Corrections to earlier notes").

### system/boot_logos/boot_logo_palette_third.asm (1 thinker, 21 lines, Bank 00 47207-47226, parts: 1 code / 0 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | F | A 3-line header, no part notes and no inline comments | E1 |
| Q2 value | F | The header gave the bundle numbers and nothing about what the bundles do or which palette they write | E1, E2 |
| Q3 accuracy | **F** | (a) **It is not a later step**: scene `$FB`'s thinker list spawns it together with the other two (slot 2, param `#03`, never read) and all three run in parallel, in BOTH visits of the scene. (b) **`#56` / `#57` / `#58` are palette bundles, not "palette animations"**: they write CGRAM colours `$A1`-`$AF`, colours 1-15 of OBJ palette 2, 8 frames each, 1 extra tick per frame (33 on the last frame of `$58`). (c) **Content**: `$56` and `$57` fill the 15 colours with the flat purple `$68DA` one at a time (1-8, then 9-15); `$58` opens a darker dip around colour 7 that widens and deepens to `$3C4F` (the ends `$64B9`). (d) **Only the second logo can show it**: OBJ palette 2 is used by the 4 x 2 block of 8 parts (`$10`-`$17`) under the emblem of `sprite_group_000010`; the first logo is on palette 3, which no thinker touches. (e) "Completes the boot logo palette rotation before gameplay begins" has no support: the thinker dies after the third bundle | E1 (the file; `palette_bundles` lines 7398-7860 read frame by frame; `hdma_dma_spc.LoadPaletteBundle`; `cop_handlers_palette` headers; `thinker_execution`), E2 (`scene_thinkers` lines 699-703; `spm_boot_logos` palette bits), E3 (`thinkers-system.md` lines 220-280 describe the three thinkers as a sequence) |
| Q4 mnemonic/var names | NA | No variables | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | `boot_logo_palette_third` says nothing about the palette or the effect; `code_00B869` is the entry | PROPOSED R-I055-1, R-I055-2 |
| Q7 evidence quality | M | E1 + E2 + E3; the visual result and the timing against the scene fade-in were not run | E1, E2 (UNVERIFIED-RUNTIME: OQ-I055-2) |

Actions taken: block note rewritten; 2 new part notes; 4 new inline comments; no mnemonics added.
Deferred: R-I055-1, R-I055-2; OQ-I055-2.
Before/after stats: file 21 to 36 lines (`wc -l`); inline comments 0 before, 4 after; header comment lines 3 before, 22 after; generic labels remaining: 1 (`code_00B869`, documented).

### system/boot_logos/sFB_boot_logo.asm (1 actor + 3 labelled blocks, 90 lines, Bank 0B 772246-772386, parts: 4 code / 0 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 14-line header, 22 inline comments and 2 part notes; no note for `BootLogoInit` or `loc_0BC8EA`, none about timing, position or the palette thinkers | E1 |
| Q2 value | M | The two-phase structure was described; why the flag survives the reload, what is on screen and for how long were not | E1 |
| Q3 accuracy | **F** | (a) **`TM = $10` is the OBJ layer** (`TM` bits are `---o4321`), not "BG1 on the main screen": the logos are sprites and no BG is shown. (b) **The shipped joypad mask is `$FFFC`**, not `$FFF0` (`transforms.json` rewrites it for this block); it hides every pad bit, Start and Select included. (c) **"2 ticks" is 2 passes of 60 ticks** (`StageSpriteLoop ( anim, passes )` with the frame hold `$003B`), so each logo lasts 120 ticks. (d) **The flag is not reset "for the next power cycle"**: event flag `$10` is outside the flags the scene load zeroes (`$00`-`$0F`), so it survives the reload, and it is cleared at the end because the South Cape church scripts (`sc08_priest`, `sc08_lance`, `sc08_erik`, `sc08_seth`) use the same flag. (e) **PAL is a lockout, not a text-only boot screen**: only the region warning string (`consolestring_01D9D8`) is drawn and the actor yields forever; the game cannot be started. (f) **The "boot display mode" of `displayModeFlags` bit 14 has no reader** (OQ-I034-1). (g) **The actor ends at X = 128** (tile 7 x 16 + 8 at spawn + 8 from the nudge), the screen centre. (h) The three `boot_logo_palette_*` thinkers run alongside and animate only the second logo | E1 (the file; `StageSpriteLoop`, `AnimLoop`, `UpdateActorAnimation`; `scene_lifecycle` lines 759 and 799-844 for the zeroed flag word; `actor_execution.InitActorFromSceneData`; `QueueMapChange`; `system_strings` boot strings; `db-us/transforms.json`; STAT78 bit 4), E2 (`rg` for flag `#10`: only `sFB_boot_logo` and the four `sc08_*` scripts; `scene_actors` line 4675; `scene_meta_00FB`; `system_core` scene `$FB`), E3 (the old header; `docs/wram-memory-map.md`) |
| Q4 mnemonic/var names | M | `displayModeFlags` bit 14 and `cgramPalette` (colour 0 of the staging buffer) are named; the event flag byte `$10` has no name | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | `BootLogoPalTextFallback` is a lockout; `loc_0BC8EA` is the NTSC path; `sFB_boot_logo`, `BootLogoInit` and `BootLogoSecondPhase` are fine | PROPOSED R-I055-3 |
| Q7 evidence quality | M | E1 + E2 + E3; what the two logos show, the on-screen timing and a soft-reset behaviour of flag `$10` were not run | E1, E2 (UNVERIFIED-RUNTIME: OQ-I055-1, OQ-I055-2, OQ-I055-3) |

Actions taken: block note rewritten (sequence, PAL lockout, position, sprites summary, corrections); 2 new part notes (`BootLogoInit`, `loc_0BC8EA`) and 2 rewritten (`BootLogoSecondPhase`, `BootLogoPalTextFallback`); inline comments 3 new, 14 updated and 1 removed (a duplicate); no mnemonics added.
Deferred: R-I055-3; OQ-I055-1 to OQ-I055-3.
Before/after stats: file 90 to 107 lines (`wc -l`); inline comments 22 before, 24 after; header comment lines 14 before, 36 after; generic labels remaining: 1 (`loc_0BC8EA`, documented).

### system/boot_logos/spm_boot_logos.sprite.asm (1 pointer list, 2 sprite-sets, 2 sprite-groups with 35 + 16 parts, 74 lines, ROM data 1931123-1931462 compressed / `$018F` bytes decompressed, parts: 0 code / 5 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | F | No block note and no part notes | E1 |
| Q2 value | F | Nothing said who loads it, what the two entries are, or what the groups draw | E1, E2 |
| Q3 accuracy | NA | There was nothing to check; `docs/structs-reference.md` calls the sprite-part "6-byte" but lists five bytes and a word (7 bytes), and the extractor struct agrees with the 7 | E1, E3 |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | `sprite_set_*` and `sprite_group_*` are offset names | PROPOSED R-I055-4 |
| Q7 evidence quality | M | E1 + E2; what the tiles draw was not run | E1, E2 (UNVERIFIED-RUNTIME: OQ-I055-1) |

Findings (documented in the `sFB_boot_logo` block note, see the deferred tooling item): the scene's spritemap card (`scene_meta_00FB`, size `$018F`) loads the data to `$7E4000`, the default spriteset of normal actors. Entry `#00` = `sprite_set_000004` (one frame, hold `$003B`) = `sprite_group_000010`: 122 x 156 px, 35 parts: a 4 x 4 block of 16 x 16 parts (OBJ palette 1 for the upper two rows, palette 0 for the lower two), a 4 x 2 block on palette 2 and 11 parts 12 px apart on palette 4. Entry `#01` = `sprite_set_00000A` = `sprite_group_000112`: 96 x 48 px, 16 parts in rows of 6, 6 and 4, all palette 3. Sprite-part = 7 bytes (size flag, X + mirror, Y + mirror, tile word `vhppPPPN`); sprite-group = 12 header bytes (X and Y extents, 8 bytes nothing reads, identical in both groups) + count + parts; sprite-set = 4-byte records closed by a hidden `$FFFF`.
Actions taken: none in this file: **the merge script cannot attach notes to `.sprite.asm` files** (`cannot determine the ROM bank of this file`: no `?BANK`, no `code_` / `loc_` labels, no `{address}` tags, and the file name `spm_boot_logos.sprite` is not in `db-us/names/`). The content is carried by the `sFB_boot_logo` block note instead.
Deferred: R-I055-4, R-I055-5; OQ-I055-1.
Before/after stats: file unchanged (74 lines by `wc -l`); inline comments 0 before, 0 after; header comment lines 0 before, 0 after; generic labels remaining: 4 (`sprite_set_000004`, `sprite_set_00000A`, `sprite_group_000010`, `sprite_group_000112`).

### Corrections to earlier notes (same spec)

- `boot_logo_palette_enix.asm` and `boot_logo_palette_quintet.asm` (I054): block notes rewritten. The Quintet note said "slot 1, param `#01`"; the three slots carry `#01`, `#02`, `#03` (none is read), so slot 1 is `#02`. The statement that the OBJ palette use "was not traced" is replaced by the static answer: palettes 0 and 1 colour the lower and the upper two rows of the second logo's 4 x 4 emblem block; the first logo (palette 3) is never animated. Both notes still say the names come from the spawn order and that the company of the logo was not checked.
- `system/engine/system_core.asm`: the part note of `SystemInit` (item 8) and the comment at 32939 called scene `$FB` the "title screen"; it is the boot-logo scene, which hands over to the title screen `$FC` (`sFB_boot_logo` queues `$FC`).

### Iteration summary

- Files: 3 audited (+ 2 earlier notes and 1 stale statement corrected). Q3: 2 F, 1 NA. Notes written: 4 block notes (third, sFB, and the rewritten enix and quintet notes), 4 new part notes, 3 rewritten part notes (2 in sFB, `SystemInit`), 7 new inline comments, 15 updated and 1 removed.
- Patterns: (1) three parallel thinkers named after an assumed sequence ("first / second / third"); (2) hardware bit read as the wrong layer (`TM = $10` is OBJ); (3) a flag whose reset reason is a different scene's use of the same flag; (4) ticks versus passes in `StageSpriteLoop`; (5) a data file with no bank information, which the note tooling cannot reach; (6) a scene id reused as "title screen" in two notes.
- Docs repeating old claims: `docs/code/bank00/thinkers-system.md` lines 220-280 (the three logo thinkers as a sequence); `docs/code/bank00/README.md` lines 570-572; the bank 0B code doc line 414 (boot logo description); `docs/structs-reference.md` (sprite-part "6-byte", should be 7 bytes). Not re-checked: other docs that call scene `$FB` the title screen.
- Answered: OQ-I054-1 (which OBJ palette each logo uses).
- Gate: `npm run extract:lt` re-run, the spec dry-run to 0 files to change, `npm run rebuild` reports checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged).
- Spec: `plans/extracted-audit/edits/I055.json`.
- Suggested commit message: `Audit I055: boot logo scene, third palette thinker, correct I054 thinker notes`

Please commit when you're ready.
