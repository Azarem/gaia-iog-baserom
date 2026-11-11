# I056 - 2026-10-28 - files: system/dark_space/sE6_gaia.asm, system/dark_space/spm_darkspace_sprites.sprite.asm, system/diary_menu/diary_entry_table.asm
Status: COMPLETE

Spec: [edits/I056.json](../edits/I056.json). Proposals: [renames/I056_renames.md](../renames/I056_renames.md). Questions: [questions/I056_questions.md](../questions/I056_questions.md).

Conventions: verdicts **P/M/F/NA**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 coverage and verbosity, Q2 value, Q3 accuracy, Q4 mnemonic and variable names, Q5 new mnemonic, Q6 naming, Q7 evidence quality. Annotation style as in I049 to I052: aggregated notes, a part note for every label, inline comments only for operands and non-obvious steps.

### system/dark_space/sE6_gaia.asm (1 actor + 3 spawned actors + ~110 labelled code blocks, 6 jump tables, strings and tables; 1853 lines before, 2166 after; Bank 08 579499-587528, Bank 09 630928-630997; 177 noted parts)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 59-line header, inline comments on most instructions and 35 part notes, but 142 labels had none (the `GaiaHint_*` handlers, the room wait / active states, the `loc_` labels, the tables, the `Transform_*` library); the ability, form and exit text sat in one long header | E1 |
| Q2 value | M | The overall flow (greeting, heal, hint, save, forms, abilities) was described; which scene each hint belongs to, how a room is organised (wait state, active state, zones), who else enters the `Transform_*` routines and what is dead were not | E1, E2 |
| Q3 accuracy | **F** | (a) **`AbilitySceneTable` byte 1 is an ability bit, not "index + statue type"**: `$15` Psycho Dash `$01`, `$62` Psycho Slider `$02`, `$86` Spin Dash `$04`, `$42` Dark Friar `$10`, `$A7` Aura Barrier `$20`, `$B8` Earthquaker `$40`; low nibble = Will ability, high nibble = Freedan ability; the table position is the ability index for the name and description tables. `LookupStatueType` returns 0 for a Will ability, 1 for a Freedan ability. (b) **The two continue-prompt answers are swapped in the old text**: Yes (entry 1) is `GaiaDontRecord` ("Then go.", back to the room), No (entry 2) is `GaiaContinueJourney` ("Then rest a while.", the actor yields forever). (c) **`$06` is the voice sparkle, not "the Gaia NPC"**: `SpawnAfter` inserts each child after the parent, so the last child spawned (`GaiaVoiceSparkle`) is the parent's next link; `$24 = $FFFF` / `0` is its on / off switch, not "disable / re-enable NPC interaction" (the orb copies the link into its own `$26`). (d) **`DarkSpaceExit` writes the player spawn, not a camera**: X = `$0B08` x 16, Y = (`$0B0C` + 2) x 16, facing 3, the packed camera window from `$0B10` / `$0B11`; `$0101` is the transition speed and `$0002` the exit effect (mosaic), not a "brightness fade". (e) **`hpToHeal` 40 is a heal request**: `UpdateHUD` adds 1 HP every 8 frames (SFX `$0D`) until HP is full. (f) **`$0F00` unmasks the D-pad only**. (g) **Event flag `$B4` is set only by `daC8_neil`** (the Neil reunion in the Dao dormitory); "unlocked at Ankor Wat" has no support. (h) **`GaiaNpcSprite` is an idle loop** (animation `#00`: 100 + 13 + 13 + 13 ticks, re-run each frame), not "a single frame". (i) **"Transformation spriteset" is `spriteset_enemies`**: animation `$1C` is the dissolve effect, also used by the portal. (j) **`Transform_ShadowToFreedan` uses `SetEntryHereAndYield`**, not "SetEntryExit". (k) **`FireflyParticle` does not rise**: it starts at Y = 0 and ends at Y >= `$FF`, so the Y step must be positive (OQ-I056-2); the "speeds" are movement-chain indexes 4/6/8/10. (l) **21 of the 34 hint handlers have no text** (they go straight to the save prompt); the old text did not say so. (m) **Dead code**: `DS_AuraItemRoom` with the whole `AuraItemInteraction` cluster and 3 strings, `DarkSpaceAmbientParticle`, `loc_08DA6B` / `loc_08DA77` (after a `BRA`) and 8 hint strings (`08DEC6` "Hint Test", `08E066`, `08E0C7`, `08E109`, `08E19C`, `08E261`, `08E2B9`, `08E615`). (n) **`Transform_*` is a shared library**: entered from 13 other files (boss, ending and statue scripts) | E1 (the file read line by line; `UpdateHUD`, `ExecuteWarp`, `vblank_joypad`, `cop_handlers_sprite` / `_dialog`, `actors/dark_space` portal, `sFA_diary_menu` load, `statue_inventory_reward`, `daC8_neil`), E2 (`rg` for `Transform_*` and flag `#B4`; `scene_actors`, `scene_meta_00E6` / `00E0`), E3 (the old header; `docs/code/bank08-native-dao-pyramid-actors.md` lines 282-307) |
| Q4 mnemonic/var names | M | `warpDestX` / `warpDestY` are the player spawn (name fits the use in `ExecuteWarp` poorly, see R-I056-6); `globalScriptIndex` ($0AAC) carries four different meanings in this file (variant, special flag, ability index, scratch); `$0AB2`, `$0B08`-`$0B12` and `$0D8C` have no names | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | The continue-prompt labels are inverted (R-I056-1); `LookupStatueType` returns a Will / Freedan ability class (R-I056-2); 21 `GaiaHint_xx` handlers are numbered although their scene is known (R-I056-3); the `Transform_*` library lives in a scene file (R-I056-5) | PROPOSED R-I056-1 to R-I056-6 |
| Q7 evidence quality | M | E1 + E2 + E3; everything visual (the BG changes `$86`-`$8F`, the firefly direction, the music at rest) was not run | E1, E2 (UNVERIFIED-RUNTIME: OQ-I056-1 to OQ-I056-6) |

Actions taken: block note rewritten (structure, exit, dialogue, forms and abilities, sprites, unreferenced code, corrections); 142 new and 35 rewritten part notes; inline comments 21 new and 39 updated; no mnemonics added.
Deferred: R-I056-1 to R-I056-6, R-I056-8, R-I056-9; OQ-I056-1 to OQ-I056-6.
Before/after stats: file 1853 to 2166 lines (`wc -l`); header comment 59 lines before, 34 after; inline comments 60 touched; generic labels remaining: 21 `GaiaHint_xx` and about 40 `loc_` labels, all documented.

### system/dark_space/spm_darkspace_sprites.sprite.asm (11 sprite-sets, about 30 sprite-groups, 379 lines; data loaded by `scene_meta_00E6` / `scene_meta_0010`, size `$0579`; parts: 0 code / ~41 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | F | No block note and no part notes | E1 |
| Q2 value | F | Nothing said which animation belongs to which actor or what the groups draw | E1, E2 |
| Q3 accuracy | NA | There was nothing to check | E1 |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | `sprite_set_*` / `sprite_group_*` are offset names | PROPOSED R-I056-4 |
| Q7 evidence quality | M | E1 + E2; what the tiles draw was not run | E1, E2 (UNVERIFIED-RUNTIME: OQ-I056-7) |

Findings (documented in the `sE6_gaia` block note, see the deferred tooling item R-I055-5): animation `#00` = `sprite_set_000016` is `GaiaNpcSprite` (hold `$63`, then `$0C` three times); `#01` to `#03` (`sprite_set_000028`, `3A`, `4C`) are the three voice sparkles (`StageSprAndHitbox #01`, `StageSpriteFrame #01` to `#03`); `#0A` (`sprite_set_0000CE`) is the ability orb used by `AbilityOrbActor` and the unreferenced `AuraItemInteraction` (32 frames of hold 0 that alternate a 16 x 16 spark, tile words `$09E0`-`$09EE`, with an 8 x 8 tile `$0BD0`); `#04` to `#09` are 8 x 8 effects (tiles `$0350`-`$0380`) that nothing in `sE6_gaia` selects. `FireflyParticle` and `DarkSpaceExit` use `spriteset_enemies` (animations `#02` and `$1C`).
Actions taken: none in this file: **the merge script cannot attach notes to `.sprite.asm` files** (same limitation as R-I055-5). The content is carried by the `sE6_gaia` block note.
Deferred: R-I055-5 (tooling), R-I056-4; OQ-I056-7.
Before/after stats: file unchanged (379 lines by `wc -l`); inline comments 0 before, 0 after; header comment lines 0 before, 0 after; generic labels remaining: 11 `sprite_set_*` and about 30 `sprite_group_*`.

### system/diary_menu/diary_entry_table.asm (1 table of 256 words + 23 diary-entry records, 361 lines before, 435 after; Bank 0B; parts: 0 code / 24 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 6-line header, no part notes: nothing said which scenes use which entry or what the 4 bytes are | E1 |
| Q2 value | M | The header named the consumer but not the data meaning | E1, E2 |
| Q3 accuracy | **F** | (a) **The 4 bytes after the name are two words, camera target X then Y**, not a "packed camera position" (`DiaryCameraPan` reads word 1 and word 2 and moves `cameraTargetX` / `cameraTargetY` toward them). (b) **The default is not "start" metadata only**: its camera ($0080, $0300) is the diary menu's start position. (c) **221 scenes map to the default**, 35 to 22 named locations; scenes sharing a location share the record (Garden and Ankor Wat the same camera, Underground Tunnel the same as Edward Prison, Incan ruins the same as Larai Cliff). (d) **`docs/structs-reference.md` calls `diary-entry` a "warp destination" with a packed scene ID + X/Y**: wrong, the scene is the table index and nothing warps with the record (the load goes to scene `$E6`). (e) Three names carry a trailing space in the ROM (`Itory Village `, `City of Euro `, `Natives' Village `) | E1 (the file; `sFA_diary_menu` lines 267-370 and `DiaryCameraPan`), E2 (`$0D74` slot scene IDs), E3 (`docs/structs-reference.md`) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | `diary_entry_0BFxxx` are address names; the 22 locations are known | PROPOSED R-I056-7 |
| Q7 evidence quality | M | E1 + E2 + E3; the pan on screen was not run | E1, E2 (UNVERIFIED-RUNTIME: OQ-I056-8) |

Actions taken: block note rewritten; 24 new part notes (the table, the default and the 22 named entries with scene IDs and camera X, Y); no inline comments (the data has none); no mnemonics added.
Deferred: R-I056-7; OQ-I056-8.
Before/after stats: file 361 to 435 lines (`wc -l`); inline comments 0 before, 0 after; header comment lines 6 before, 9 after; generic labels remaining: 23 `diary_entry_0BFxxx` (documented).

### Iteration summary

- Files: 3 audited (1 not editable by the tool). Q3: 2 F, 1 NA. Notes written: 2 block notes, 166 new and 35 rewritten part notes, 21 new and 39 updated inline comments, none removed.
- Patterns: (1) a header that guesses a field meaning from one use (ability byte as "index + statue type", camera as "packed position"); (2) yes / no answers reversed by assuming the prompt order; (3) a link field (`$06`) read as a different actor than the one it points to; (4) names of a movement field read as speeds; (5) dead code kept next to live code in the same block (Aura item room, 8 hint strings); (6) a shared library placed in a scene file; (7) a data file the tooling cannot reach (again).
- Docs repeating old claims: `docs/structs-reference.md` (`diary-entry` as warp destination); `docs/code/bank08-native-dao-pyramid-actors.md` lines 282-307 (`Transform_WillToShadow` called "Exit portal config A" and the Dark Space actor described without the corrections above); possibly `docs/actor-organization-analysis.md` line 187 and `bank0A-dungeon-enemy-actors.md` line 343 (not re-checked).
- Corrections to other files: none in this iteration.
- Gate: `npm run extract:lt` re-run, the spec dry-run to 0 files to change, `npm run rebuild` reports checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged). Note: one rebuild directly after the first `extract:lt` failed with `Patch CrystalBallAutoUse contains a rewrite that does not exist: CODE_05F522` and a second run after a plain `extract` produced a different size (3062189); after a fresh `extract:lt` the rebuild passes with the numbers above. Cause not investigated (OQ-I056-9).
- Spec: `plans/extracted-audit/edits/I056.json`.
- Suggested commit message: `Audit I056: Dark Space Gaia scene, diary entry table, correct ability table and prompt semantics`

Please commit when you're ready.
