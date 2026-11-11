# B001 - 2026-10-28 - bank-detection fix and the files it had blocked: system/boot_logos/spm_boot_logos.sprite.asm, system/title_screen/spm_title_actors.sprite.asm, system/dark_space/spm_darkspace_sprites.sprite.asm, system/world_map/spm_overworld_sprites.sprite.asm
Status: COMPLETE

Spec: [edits/B001.json](../edits/B001.json) (plus [edits/I061-rebank-scene_actors.json](../edits/I061-rebank-scene_actors.json)). Proposals: [renames/B001_renames.md](../renames/B001_renames.md). Questions: [questions/B001_questions.md](../questions/B001_questions.md).

B001 is not a numbered checklist iteration: it is the follow-up the user asked for after I061 ("`?BANK` is optional, use blocks.json / names.json; check where else this blocked us, then analyze those files"). I065 is still the next checklist iteration.

Conventions: verdicts **P/M/F/NA**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session).

## 1. Tooling change

**Cause.** The extractor writes `?BANK` only for non-movable blocks (`gaia-core/src/rom/extraction/writer.ts`: `block.bank !== undefined`). 743 `blocks.json` entries are `movable`, and every `files.json` entry (sprite maps, tilemaps...) has none, so `merge` could not find a bank for a file made of data only (no `code_` / `loc_` labels, no `{address}` tags, name not in `db-us/names/`).

**Fix (`src/ingest.ts`, `src/merge.ts`).**
- `loadDbBankLookup(db-us)` reads `blocks.json` (group -> block, lowest part start for blocks with `parts`) and `files.json` (group -> scene -> name) into name -> bank = floor(start / 65536).
- `detectBank` order is now: `?BANK`, **blocks.json / files.json**, `code_` / `loc_` labels, `{address}` tags, names file-name lookup, names first label. The `.sprite` suffix of `spm_x.sprite.asm` is stripped (the block is `spm_x`); this was tested: a trial block note on `spm_boot_logos.sprite.asm` landed in `blockNotes/bank1D.json` under `spm_boot_logos` and appeared in the next extraction.
- The earlier I061 stopgap (reuse the bank of an existing block note) is removed.
- New in `merge`: partial note edits (`{ "edit": [ { "find", "until", "with" } ] }`), so a sentence or section of a long existing note can be changed without pasting it again. `find` must match exactly once; tested: edit applied (dry-run), missing text and a second missing text abort with the count.
- Three helper scripts I had written for this (`temp/bankscan.mjs`, `temp/notebank.mjs`, `temp/build_B001.py`) were deleted after use; they should not have been created. B001's four edits of existing notes were applied as full-text entries in `B001.json`; later edits of that kind use `edit`.

**Docs updated.** `gaia-core/docs/notes-and-comments.md` ("Bank detection" now has 6 strategies and says `?BANK` is optional; the "Where each entry lands" table, the block-note layout line, the names/blocks lookup line, merge rule 3 which claimed sprite and route-table files cannot be annotated, and a "Partial edits" paragraph), `gaia-knowledge/AGENTS.md` (task-routing row) and the two `snes-knowledge.mdc` rules (gaia-knowledge, gaia-iog-baserom). `corpus/gaia-core/` in gaia-knowledge is refreshed by `npm run ingest:all`, not by hand.

## 2. Files skipped by the bank problem

Scan of every `extracted/**/*.asm` against the old detection (48 files with no bank, all resolvable through blocks.json / files.json):

| Group | Files | Status |
|-------|-------|--------|
| Audited earlier but not annotated (merge failed) | `spm_boot_logos` (I055), `spm_darkspace_sprites` (I056), `spm_title_actors` (I058), `spm_overworld_sprites` (I059) | **audited again here, notes merged** |
| Annotated by hand instead | `world_map_route_table` (I060, now named; block note present) | no action |
| Hit by the bank error in this session | `scene_actors` (I061) | done; moved to bank 0C |
| Not yet audited, now unblocked | `scene_meta` (I065), `gs_gold_ship_intro_text` (I256; already has a block note), and 41 further `*.sprite.asm` files (iterations I075, I079, I087, I093, I097, I106, I114, I124, I125, I142, I150, I164, I169, I172, I181, I190, I197, I203, I212, I219, I221, I226, I235, I237, I243, I244, I254, I264, I270, I272, I277, I279, I286, I287, I288, I289, I294, I295; the checklist lists each file) | will work as written |

Block notes filed under a bank different from blocks.json (cosmetic only: the key is the file name, extraction ignores the bank): 6 left: `ir1D_monologue` (09 vs 05), `dm_mine_static_prop` (0B vs 05), `gs_gold_ship_intro_text` (0B vs 05), `bt_static_sprite` and `CreditPositionLookup` (13 vs 09), `pr_thinkers` (17 vs 0B). Not moved (no effect); logged as R-B001-3.

## 3. Findings for the four sprite files

Common to all four: a sprite map is a pointer table, frame lists and sprite-groups; the format is documented in `spriteset_freedan` (I063) and now in each file's block note.

### Q3 (accuracy) correction that affects earlier audits

**The 8 header bytes after the extents are not "nothing reads".** I055 (`sFB_boot_logo` block note), I058 and the first draft of I059 said so. `PlayerAttackHitTest` reads group bytes 4-7 at `metaspritePtr+0..3` (X offset and Y offset, `ORA #$FF00`, so always negative; width and height shifted left four times = 16-pixel units), the solid-rectangle COP handlers read the same four bytes (`cop_handlers_collision`), and `RunCombatCollision` / `RunInteractionCollision` read bytes 8-11 at `metaspritePtr+4..7` (X offset, width in pixels, Y offset, height in pixels; X mirrored for an H-flipped actor). `DecomposeActorMetasprites` skips them because it starts at `metaspritePtr+8` (the part count). All 85 groups of the four files carry the default values `$F8 $F0 $01 $01` and `$F8 $10 $F0 $10` (a 16 x 16 box at (-8, -16)). E1. Corrected in the `sFB_boot_logo` and `spriteset_freedan` block notes and written into the four new sprite-map notes.

**Other corrections.**
- `WorldMapController` block note: "B: 3 frames of 24-28 parts" - animation B has 24 parts in every frame, C 27; "6: three 1-part frames" - animation 6 has 4 frames (A B A C) of one 16 x 16 part. Heading "not annotatable with the merge tool" removed.
- `sE6_gaia` block note: "#04 to #09 (8 x 8 effect tiles)" - only #04 to #06 are 8 x 8; #07 to #09 are a 32 x 32 figure of three 16 x 16 parts and one 8 x 8.

### system/boot_logos/spm_boot_logos.sprite.asm (1 table, 2 sets, 2 groups, 74 lines before / 108 after, parts: 0 code / 5 data)
| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage | F | No block note or part notes before | E1 |
| Q2 value | F | Nothing said which animation is which logo | E1 |
| Q3 accuracy | F | The box bytes were reported as unread (see above) | E1 |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | `sprite_set_000004` / `sprite_set_00000A` / `sprite_group_*` are offset names | PROPOSED R-B001-1 |
| Q7 evidence quality | M | E1 + E2; the art was not looked at | E1, E2 (UNVERIFIED-RUNTIME) |

Actions taken: block note (animations, format, boxes) and 5 part notes. Part-box arithmetic checked by hand: x + x' = 58 + 64 - 16 = 106 for part 00 of group 000010 ($2A + $40 = $6A). Before/after: 74 to 108 lines; generic labels remaining 4.

### system/title_screen/spm_title_actors.sprite.asm (1 table, 1 set, 1 group, 61 lines before / 85 after, parts: 0 code / 3 data)
| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage | F | None before | E1 |
| Q2 value | F | None | E1 |
| Q3 accuracy | NA | Nothing to check (I058's "nothing reads" was only in the results file) | E1 |
| Q4-Q5 | NA | Data only | E1 |
| Q6 naming | M | `sprite_set_000002`, `sprite_group_000008` | PROPOSED R-B001-1 |
| Q7 evidence quality | M | E1 + E2; palette not derived because the actor XORs its attribute word into the tile words | E1, E2 (UNVERIFIED-RUNTIME) |

Actions taken: block note and 3 part notes. The comet: 104 x 144 px box, 48 parts (45 of 16 x 16, parts 07, 0F, 2F of 8 x 8), hold 0.

### system/dark_space/spm_darkspace_sprites.sprite.asm (1 table, 11 sets, 34 groups, 379 lines before / 441 after, parts: 0 code / 46 data)
| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage | F | None before | E1 |
| Q2 value | F | Nothing said which animation belongs to which actor | E1, E2 |
| Q3 accuracy | M | I056's `sE6_gaia` text called #04-#09 "8 x 8 effects" (fixed) | E1 |
| Q4-Q5 | NA | Data only | E1 |
| Q6 naming | M | 11 `sprite_set_*` and 34 `sprite_group_*` offset names | PROPOSED R-B001-1, R-B001-2 |
| Q7 evidence quality | M | E1 + E2; nothing run; users of #04-#09 not found | E1, E2 (UNVERIFIED-RUNTIME: OQ-B001-1) |

Actions taken: block note (all 11 animations with frame counts, holds, sizes, tile words) and 13 part notes (the pointer table, the 11 sets, the dot group 000565); `sE6_gaia` block note corrected.

### system/world_map/spm_overworld_sprites.sprite.asm (1 table, 14 sets, 48 groups, 893 lines before / 964 after, parts: 0 code / 63 data)
| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage | F | None before (facts only in the results file and the controller note) | E1 |
| Q2 value | F | None | E1, E2 |
| Q3 accuracy | M | Frame counts and part counts in the `WorldMapController` section were off (fixed) | E1 |
| Q4-Q5 | NA | Data only | E1 |
| Q6 naming | M | 14 `sprite_set_*` named by offset; the animation index is the real key | PROPOSED R-B001-1 |
| Q7 evidence quality | M | E1 + E2; per-animation sizes computed from the group headers, art identity not checked | E1, E2 (UNVERIFIED-RUNTIME: OQ-B001-2) |

Actions taken: block note (14 animations: frame pattern, hold, box, parts, user) and 15 part notes; `WorldMapController` section corrected.

## 4. Verification

- `npm run merge -- edits/B001.json`: 10 notes files written (blockNotes 03, 08, 0B, 0E, 14, 1D, 1E; partNotes 14, 1D, 1E); `npm run extract:lt` re-run: each sprite file now starts with its block note and the part notes sit above their labels; re-run dry-run of B001: 0 changes. Dry-runs of I061, I062, I064: 0 changes. The I063 spec now reports 1 file to change because it carries the old full text of `spriteset_freedan`; do not re-apply I063 (B001 superseded that note).
- `npm run rebuild`: checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged).

## 5. Iteration summary

- Files: 4 re-audited + 3 existing notes corrected (`sFB_boot_logo`, `sE6_gaia`, `WorldMapController`) + `spriteset_freedan` box description.
- Notes written: 4 block notes, 36 part notes (5 + 3 + 13 + 15), 4 block notes corrected. No inline comments.
- Tooling: bank detection from blocks.json / files.json, partial note edits in `merge`.
- Deferred: R-B001-1 to R-B001-3; OQ-B001-1, OQ-B001-2.

Please commit when you're ready. Suggested messages: gaia-iog-baserom `Notes merge: derive the bank from blocks.json / files.json, partial note edits; annotate boot, title, Dark Space and overworld sprite maps (B001)`; gaia-core `docs: bank detection from blocks.json/files.json, merge partial edits`; gaia-knowledge `rules: bank source for notes merge`.
