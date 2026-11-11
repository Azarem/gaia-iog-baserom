# IT-05 apply: retired nicknames, `body_table`, `slider_glide`, player-sprite notes (PLAN F03 part 1)

Mechanism: `npm run merge` only. Spec: `plans/extracted-audit/audit-of-audit/IT05_spec.json` (one spec; 4 files). `body_table` takes full-text sets (block note and the `body_table` row-table part note), so re-running those two reports `=unchanged`; the other three files use `edit` ops (block, part notes) and guarded comments, so re-running the whole spec reports an error for the `edit` entries instead of `=unchanged`.

## Facts re-derived before editing (live `extract:lt`)

- `GetPlayerFacingDirection.asm:66-83`: with `playerFlags` bit 15 set, `LDA $0AC8` / `AND #$00FF` / `SBC #$0004` / `BMI GetPlayerFacing_BaseBodyFallback`; for `$0AC8` = 8 the result is 4, not negative, so no fallback; `ASL` gives X = 8 and `LDA $@FacingFormOffsetTable, X` reads offset 8. `FacingFormOffsetTable` has 4 pointers (8 bytes, names file address 258423) and `FacingData_WillAbilities` starts at 258431, so the word read at offset 8 is the first two bytes of `FacingData_WillAbilities`. Whether the routine runs while row 8 is active is not shown statically; the note says "Not traced".
- `sprite_composition.asm:691-710` (`DecomposePlayerSprites`): `LDA $playerFlags` / `BPL loc_03C936`; bit 15 set takes `animScratch2, X`, clear takes `characterForm x 6`; both paths then read `body_table+3` and `body_table+5`. So the rows are read always, bit 15 only changes where the row offset comes from (A06-10).
- `actor_pool.asm:78-92` (`SetActorBody`): `characterForm x 6` into `body_table`, clears `playerFlags` `$8000`.
- A06-11 `rg` re-run over `extracted/*.asm` (`SetPlayerSpriteDirect\] \( #[0-9A-Fa-f]`): 24 sites, operands only `#04` (14: `sF7_credits_player` 173, 186, 204, 227; `player_character` 1373, 1408; `attack_ability_system` 1032, 1041, 1050, 1058, 1270; `player_transition_handlers` 73, 98, 116), `#05` (7, all in `sE6_gaia`: 1658, 1683, 1708, 1815, 1840, 1967, 1995), `#06` (2: `player_character` 603, `attack_ability_system` 402), `#08` (1: `player_transition_handlers` 222). 14 + 7 + 2 + 1 = 24, which matches the "24 sites" in `cop_handlers_player_sprite.asm`. No site for `#03` or `#07`.
- The 7 `#05` sites sit under the labels `Transform_WillToFreedan`, `Transform_WillToFreedanAlt`, `Transform_ShadowToFreedan`, `Transform_FreedanToWill`, `Transform_ShadowToWill`, `Transform_WillToShadow`, `Transform_FreedanToShadow` (`sE6_gaia.asm` 1657-2010): seven `Transform_*` scripts, one site each. Row 5 is `spriteset_transform_poses`.
- Live block names (`blocks.json` 1046-1063): `spriteset_will_abilities` (row 4), `spriteset_transform_poses` (row 5), `spriteset_freedan_fx` (row 6), `spriteset_shadow_fx` (row 7), `spriteset_shadow_aura_body` (row 8). `FacingData_WillAbilities` and `FacingData_TransformPoses` are the IT-04 names.
- `RunAttackNS` / `RunAttackEW` (`player_character.asm` 1370-1426) call `SetPlayerSpriteDirect #04` first, before any slide stage: supports "at the start of every slide".
- `IsPlayerSliderSpriteBank` compares only the bank byte with `#$8F`; rows 4 and 5 are both bank `$8F`, so the test cannot tell them apart (static fact).

## Items

| finding id | file:line (live, after merge) | status | note |
|---|---|---|---|
| A06-15 / N-6 | `body_table.asm:37` (part note `body_table`, paragraph after the table) | APPLIED | Forms listed by the current block names and by the `FacingData_*` labels in row order; paragraph rewritten (part note `body_table`). |
| A06-01 | `body_table.asm:37` (part note `body_table`) | APPLIED | States the row 8 fact: `$0AC8` = 8 gives index 4, no fallback, reads `FacingFormOffsetTable + 8`, past the 4-entry table; the word is the first two bytes of `FacingData_WillAbilities`. "Not traced: whether GetPlayerFacingDirection runs while row 8 is active." No runtime claim. |
| A06-10 | `body_table.asm:5-7` (block note) | APPLIED | `DecomposePlayerSprites` reads row +3 / +5 in both cases; bit 15 only changes the source of the row offset (`animScratch2` vs `characterForm x 6`). Placed in its own paragraph after the two selection bullets. |
| A06-11 | `body_table.asm:39` (part note) | APPLIED | New paragraph: only operands 04, 05, 06, 08 (24 sites); row `$07` not selected by any; `sE6_gaia` the only user of row `$05`. Row `$07` cell in the table also says "not selected by any SetPlayerSpriteDirect operand". |
| A07-16 | `body_table.asm:30` (row `$05` cell) | APPLIED | "The transform poses: selected only by the seven Transform_* scripts of sE6_gaia (SetPlayerSpriteDirect #05)". |
| A06-12 (narration) | `body_table.asm:7` (block note) | APPLIED | "The old header listed the rows as ..." paragraph removed. |
| A06-14 (process narration) | `body_table.asm:9` (block note) | APPLIED | "Checked:" paragraph and `UNVERIFIED-RUNTIME` tag removed. |
| A06-13 (ids) | `body_table.asm:28, 37` | APPLIED | Both `OQ-I061-1` ids removed; the open fact is in words ("nothing found selects this row", "is not traced"). |
| A02-07 / A06-15 | `slider_glide.asm:4` (block note) | APPLIED | "$8F (the bank of spriteset_will_abilities, which RunAttackNS / RunAttackEW select at the start of every slide with SetPlayerSpriteDirect #04)". |
| A02-07 / A02-09 | `slider_glide.asm:5` (block note) | APPLIED | `will_alt` replaced by `spriteset_will_abilities`; the "The old comments called these 'walk frames' ..." sentence removed. |
| A02-09 | `slider_glide.asm:9` (block note) | APPLIED | "; the old '+/-$20' wording is wrong" removed; the window description is unchanged. |
| A02-07 | `slider_glide.asm:59` (comment, tag 53493) | APPLIED | "Player sprite bank must be $8F (body_table rows 4 and 5; the Psycho Slider uses row 4, spriteset_will_abilities); carry set rejects". |
| A02-07 | `slider_glide.asm:256` (part note `IsPlayerSliderSpriteBank`) | APPLIED | Rows 4 and 5 share bank `$8F`, so the test does not tell them apart; slider selects row 4, only `sE6_gaia` selects row 5. "It is not a 'move state'" sentence dropped (denial of an old claim). |
| A02-07 | `slider_glide.asm:263` (comment, tag 53772) | APPLIED | The "4 = Psycho Slider poses, 5 = ability poses" claim replaced by the row-to-block fact; the fuller list of row 4 users is in `body_table`. |
| A02-07 | `slider_glide.asm:267` (comment, tag 53779) | APPLIED | "Carry set = reject (bank is not $8F)". |
| A02-07 | `slider_glide.asm:298` (comment, tag 53821) | APPLIED | `will_alt spriteset` -> `spriteset_will_abilities`. |
| A02-07 / A06-15 | `cop_handlers_player_sprite.asm:6` (block note) | APPLIED | Rows 4-8 by their block names (`spriteset_will_abilities`, `spriteset_transform_poses`, `spriteset_freedan_fx`, `spriteset_shadow_fx`, `spriteset_shadow_aura_body`); `shadow_mode` was the row-8 nickname. |
| A02-07 | `cop_handlers_player_sprite.asm:33` (part note `SetPlayerSpriteDirect`) | APPLIED | "#04 = spriteset_will_abilities". |
| A02-07 | `cop_handlers_player_sprite.asm:38` (comment, tag 41017) | APPLIED | Reduced to "Operand: body_table index 0-8 (row names are listed in the block note, section Body table)" so the names live once (a full list was 191 characters). |
| A02-07 | `cop_handlers_player_sprite.asm:52` (comment, tag 41050) | APPLIED | "$8F rows 4-5 (spriteset_will_abilities, spriteset_transform_poses), ... $97 rows 6-8". |
| A01 V24 / F6 | `GetPlayerFacingDirection.asm:16` (block note) | APPLIED | Block names in table order, and the `FacingData_*` suffixes (`WillAbilities, TransformPoses, FreedanFx, ShadowFx`). |
| (instructed) | `slider_glide.asm` about 411 (note on a live mnemonic name) | SKIPPED | Part 2, as instructed. |
| docs | `docs/code/bank00/README.md:740`, `data-tables-memory.md:250`, `stair-climb-system.md` (8, 33, 117, 127, 288) still say `will_alt` | BLOCKED (IT-15) | Docs belong to IT-15. |

Applied: 21 rows (8 `body_table`, 8 `slider_glide`, 4 `cop_handlers_player_sprite`, 1 `GetPlayerFacingDirection`; in notes terms 4 block notes, 3 part notes, 6 comments; the `body_table` block note and the `body_table` part note are full-text sets). DISPUTED: 0. SKIPPED: 1 (by instruction). BLOCKED: 1 (docs, IT-15).

## Dry-run summary

```
tables/body_table.asm: block +0 ~1 -0 =0, parts +0 ~1 -0 =0, comments +0 ~0 -0 =0   (+new ~updated -removed =unchanged)
system/engine/slider_glide.asm: block +0 ~1 -0 =0, parts +0 ~1 -0 =0, comments +0 ~4 -0 =0
system/engine/cop_handlers_player_sprite.asm: block +0 ~1 -0 =0, parts +0 ~1 -0 =0, comments +0 ~2 -0 =0
system/engine/GetPlayerFacingDirection.asm: block +0 ~1 -0 =0, parts +0 ~0 -0 =0, comments +0 ~0 -0 =0
[DRY RUN] 6 notes file(s) would change; nothing written.
OK
```

The first dry-run printed two length warnings (comments 53772 at 173 characters, 41017 at 191); both comments were shortened, the second dry-run and the real run had no warnings. Files written: `notes/blockNotes/bank00.json`, `bank01.json`, `bank03.json`, `notes/partNotes/bank00.json`, `bank01.json`, `notes/comments/bank00.json`.

## Gate

`npm run extract:lt`, then `npm run rebuild` (separate commands): `artifacts/crc.json` = checksum 223006080, crc 2083230829, totalSize 3062204. Equal to the baseline. Read back in the re-extracted files: `body_table.asm` 1-37, `slider_glide.asm` 4, 5, 9, 59, 256, 263, 267, 298, `cop_handlers_player_sprite.asm` 6, 33, 38, 52, `GetPlayerFacingDirection.asm` 16. `rg` for `OQ-I061`, `UNVERIFIED`, `Checked:`, `old header`, `will_alt` in `body_table.asm` gives 0 hits; `rg` for `will_alt|ability_fx|shadow_mode|WillAlt|AbilityFx` over `extracted/` leaves only the `ReloadAbilityFX` false hits (`inventory_overlay.asm`).

## Found outside scope (not changed)

- `slider_glide.asm:259` (native comment on `PHX`): "Only the sprite BANK is tested, not a move state". Denial of an old claim; hygiene sweep.
- `body_table` row `$06` ("Freedan effect sprites"): `SetPlayerSpriteDirect #06` is used at `player_character.asm:603` and `attack_ability_system.asm:402` ("Aura casting pose"). The row text may not describe those users; this is the Part 2 item IT-20 (`body_table` row `$06`), so the cell is unchanged.
- `GetPlayerFacingDirection.asm` block note step 3 ("If $0AC8 < 4 ... falls back") does not mention that `$0AC8` = 8 reads past `FacingFormOffsetTable`; the fact now lives in the `body_table` part note only. The instruction limited this file to block names, so it is a candidate for a later pass.
- `cop_handlers_player_sprite.asm:1` and the part notes "(copdef StagePlayerMoveX ...)" (IT-04 list) are still IT-06 / IT-47 material.
- `spriteset_shadow.asm:3` ("The old header ('walking, idle, ...') ...") and `spriteset_will_abilities.asm:1` ("The old note ... was wrong"), `spriteset_shadow_aura_body.asm:1` ("The old note ... both were wrong") carry history narration; they belong to IT-10/IT-11/IT-20 and the sweeps. The last also says "the body_table note said that nothing selects row $08", which is history about the note I just rewrote.
- Docs with `will_alt`: `docs/code/bank00/README.md:740`, `docs/code/bank00/data-tables-memory.md:250`, `docs/code/bank00/stair-climb-system.md` (8, 33, 117, 127, 288): IT-15.
- `characterForm` bound: "Only rows 0-3 are reached this way" (block note, unchanged) is a static claim that the range of `characterForm` is 0-3; the code only shows `characterForm x 6` with no bound check. Not in this iteration's findings, left as it was.
