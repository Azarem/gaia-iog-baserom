# IT-10 apply: tables I061-I064 and the four `spm_*` maps, complete clean-up

Mechanism: `npm run merge` only. Spec: `plans/extracted-audit/audit-of-audit/IT10_spec.json` (one spec, 16 files: 16 block notes and 11 part notes; block notes of `scene_actors` and `ability_damage_tables` by full text, all others by partial `edit` pairs whose `find` text had to occur exactly once). No comments were touched.

## Dry-run summary (shown before the apply)

```
tables/walk_step_table.asm: block ~1, parts ~1
tables/scene_actors.asm: block ~1, parts ~2
tables/ability_damage_tables.asm: block ~1
tables/forced_walk_pan_table.asm: block ~1
tables/move_chain_table.asm: block ~1, parts ~2
tables/shared_word_table.asm: block ~1, parts ~1
tables/spriteset_freedan.asm: block ~1, parts ~1
tables/spriteset_will.asm: block ~1, parts ~1
tables/spriteset_shadow.asm: block ~1
tables/spriteset_adrift_wave.asm: block ~1, parts ~1
tables/spriteset_snake_pit_fx.asm: block ~1, parts ~2
tables/spriteset_freejia_tilefx.asm: block ~1
system/boot_logos/spm_boot_logos.sprite.asm: block ~1
system/title_screen/spm_title_actors.sprite.asm: block ~1
system/dark_space/spm_darkspace_sprites.sprite.asm: block ~1
system/world_map/spm_overworld_sprites.sprite.asm: block ~1
[DRY RUN] 12 notes files would change: notes/blockNotes/bank01, 0C, 0E, 14, 15, 1D, 1E; notes/partNotes/bank01, 0C, 0E, 14, 15
```

Total: 16 block notes and 11 part notes updated, 0 new, 0 removed, 0 comments. The apply wrote the same 12 files. The four `spm_*` keys resolved to banks 1D / 1E (the block-note files above) without a bank error.

## Gate

`npm run extract:lt` then `npm run rebuild` (separate commands): `artifacts/crc.json` = checksum 223006080, crc 2083230829, totalSize 3062204. Same as the expected gate. No `GATE:` line exists in the Progress log yet.

## Staging wording (written once, reused)

The A06-09 / A07-03 wording appears in `spriteset_freedan` (table part note, rows `$04-$07`, `$10-$13` and the closing paragraph), `spriteset_will` (same three places) and `spriteset_shadow` (line 7, `$10-$13`). Evidence (static, from `extracted/`):

- `$04-$07`: no `StagePlayerSprite` / `RunPlayerAnim` operand names them; the Psycho Dash stages `#04-#07` (`StageSpriteMoveY` / `StageSpriteMoveX`) after `SetPlayerSpriteDirect #04`, i.e. against `spriteset_will_abilities` (`body_table` row `$04`).
- `$10-$13`: `StagePlayerSprite` stages them only on the `...Shadow` branches of the per-scene flag byte `#00` test (the four `IdleStand*Shadow` labels of `player_character`, `player_transition_handlers.PlayerIdleUseShadowSprite`) and in `sF7_credits_player` (`#11`, `#12`). The branch name says Shadow; the code does not prove that the Shadow body is the active one, so the notes say "branches named Shadow" and do not claim "Shadow only".
- `$14-$17`: only the Psycho Slider (`RunAttackNS` / `RunAttackEW`, `slider_glide`), against `spriteset_will_abilities`.
- `$1C-$29`: staged by `player_transition_handlers`, `player_character`, `ramps`, `sF7_credits_player`, `sE5_epilogue`; the body row active at each site is not traced.
- `$3E-$41`, `$4A`, `$4B`: no player script stages them with an immediate operand.

## Items

| finding id | file:line (live, after `extract:lt`) | status | note |
|---|---|---|---|
| A06-02 | `spriteset_freedan.asm:9` | APPLIED | `tile_collision_physics` added to the readers of bytes 4-7 ("the tile collision code (tile_collision_physics, the movement wall tests)"); 8 reader sites re-derived in `tile_collision_physics` |
| A06-02 | `spm_boot_logos.sprite.asm:13`, `spm_title_actors.sprite.asm:13`, `spm_darkspace_sprites.sprite.asm` (format bullet), `spm_overworld_sprites.sprite.asm:23` | APPLIED | same reader sentence in each |
| A06-02 | `spm_boot_logos.sprite.asm:18` (BOXES) | APPLIED | ends with "the two collision boxes (PlayerAttackHitTest, CombatCollision, tile_collision_physics)"; the unsupported sentence "A logo has no use for them" and the "first audit (I055)" sentence removed |
| A06-03 | `spriteset_freedan.asm:30` | APPLIED | `$63` = 100 ticks (hold n = n + 1) |
| A06-03 | `spriteset_will.asm:6` | APPLIED | "Freedan's idle is a single frame held 100 ticks" |
| A06-04 | `scene_actors.asm:25` (block note) | APPLIED | 17 ids listed (`$00 $9F $59 $89 $8C $8D $8F $90 $C0 $F0 $F7 $FA $FB $FC $FD $FE $FF`); 17 = 241 - 224 |
| A06-04 | `scene_actors.asm:23` (block note) | APPLIED | "224 lists (the 223 scene lists that begin with a player, plus scene_default_actors)" |
| A06-05 | `scene_actors.asm:4732` part note `scene_FF_actors` | APPLIED | six `inventory_statue_slot` actors, records `$01-$06`, attributes `$21 / $03 / $05 / $27 / $09 / $0B` = parameters `$10 / 1 / 2 / $13 / 4 / 5` |
| A06-06 | `scene_actors.asm:1-9` block note | APPLIED | `scene_NN_actors [ ... ]` / `scene_NN_actors_value`, `scene_default_actors` (first record, 819712), `scene_A7_actors`, `scene_91_actors`; retired names removed |
| A06-06 | `walk_step_table.asm:7` | APPLIED | old-header paragraph replaced by one sentence |
| A06-07 | `ability_damage_tables.asm:14` | APPLIED | `eu97_dark_medicine` named as a second writer of `$0B1C`; `$0B18`, `$0B1A`, `$0B1E`, `$0B20` have no direct `STA` in `extracted/` (re-derived with `rg`); "not traced: how they get their values" |
| A06-08 | `ability_damage_tables.asm:1` | APPLIED | 121255-121303 |
| A06-08 | `forced_walk_pan_table.asm:1`, `shared_word_table.asm:1`, `spriteset_freedan.asm:1`, `spriteset_will.asm:1`, `spriteset_adrift_wave.asm:1`, `spriteset_snake_pit_fx.asm:1`, `spriteset_freejia_tilefx.asm:1` | APPLIED | inclusive last byte (108894-109277, 125711-125863, 950272-969434, 1409024-1426464, 1360072-1360171, 1360172-1360279, 1359872-1360071). Goes beyond the four headers A06-08 names: all seven were exclusive and now agree with `ability_damage_tables` |
| A06-08 | `spriteset_adrift_wave.asm:1` | APPLIED | start corrected from 14C0CA to 14C0C8 (the exclusive-to-inclusive pass showed the old start was two bytes off; 1360072 = `$14C0C8`) |
| A06-09 | `spriteset_freedan.asm:31`, `:35`, `:44`, `spriteset_will.asm:26`, `:29`, `:35` | APPLIED | wording above; the claim "Shadow only" is gone |
| A07-03 | `spriteset_shadow.asm:7` | APPLIED | `$10-$13` wording as above, then "These indices use groups of their own (for example ...)"; rest of the file untouched |
| A06-12 | all 15 files | APPLIED | history narration removed ("The old header ...", "previous header", "old note", "Despite the old name", "this was checked ...", "was a guess"); `rg` for `old header\|previous header\|old note\|previous note\|first audit` over the 15 files: 0 hits |
| A06-13 | all 15 files | APPLIED | `OQ-I061-1/2/3`, `OQ-I062-1`, `OQ-I063-1/2`, `OQ-I064-1/2/3/4`, `OQ-B001-1/2`, `I055` removed; `rg 'OQ-\|\(I0\d\d\)'` over the 15 files: 0 hits. Residual `OQ-I061-1` in `spriteset_shadow.asm:1` is IT-11's (see below) |
| A06-14 | `walk_step_table`, `scene_actors`, `ability_damage_tables`, `move_chain_table`, `spriteset_adrift_wave` (+ the "Checked:" blocks of the others) | APPLIED | all "Checked:" paragraphs removed (`rg 'Checked:\|SAMPLED\|UNVERIFIED'`: 0 hits); hedges kept only as "Not traced: ..." (`move_chain_table:30`, `forced_walk_pan_table:24`, `spriteset_freedan:6/12/19`, `spriteset_freejia_tilefx:15`, `spm_*`) |
| A06-16 | `spriteset_adrift_wave.asm:17` | APPLIED | `sprite_group_adrift_wave_0` ... `_3` written out |
| A06-16 | `spriteset_snake_pit_fx.asm:27`, `:39` | APPLIED | `snake_pit_fx_frame_0, _1, _2, _3, _2, _1`; frames 1-3 differ by tile byte `$04, $08, $0C` |
| A06-16 | `spm_boot_logos.sprite.asm:5-6`, `spm_title_actors.sprite.asm:5`, `spm_darkspace_sprites.sprite.asm:5-11`, `spm_overworld_sprites.sprite.asm:6-14` | APPLIED | every `sprite_set_*` / `sprite_group_*` name prefixed with its file (live labels `spm_<file>_sprite_set_NNNNNN` / `_sprite_group_NNNNNN`). `spm_title_actors:5` was not listed by the finding but carried the same fault |
| A06-17 | `spriteset_freejia_tilefx.asm:3` | APPLIED | `code_05B021` first stores `#$0420` in `cameraBoundsY` (`$06DC`) and spawns `code_05B03E` (`SpawnAfter`), then plays animation 0; re-derived in `fr32_laborer_npc.asm` |
| A06-17 | `spriteset_freejia_tilefx.asm:15` | APPLIED | "Not traced: what the tiles show. The two actors run no sprite movement ..." |
| A06-20 | `move_chain_table.asm` (58 / 26 chain-end counts) | SKIPPED | kept as printed, not re-derived (the finding reports it only) |
| A06-21 | `blocks.json` types | BLOCKED | `blocks.json` is not editable here (Part 2) |
| (B001) | hit-box facts | APPLIED | not deleted: bytes 4-7 / 8-11 text kept in the Freedan format section and the four `spm_*` format bullets |

## Outside scope / found while working

1. `spriteset_shadow.asm:1` still gives the exclusive end 1355931 (`1343488-1355931`), the `OQ-I061-1` id, and lines 1-3 carry history narration ("The old header ..."). Belongs to IT-11 (only line 7 is IT-10's).
2. `fr32_laborer_npc.asm` file header describes a "walking laborer"; the actors run no sprite movement. The new `spriteset_freejia_tilefx` note says so, the actor header is not edited here (not in this iteration's file list).
3. Other files still use unprefixed `sprite_set_0000NN` / `sprite_group_0000NN` names for the `spm_*` maps (not searched; e.g. `sFB_boot_logo`, `sFC_title_intro` notes).
4. `spriteset_freejia_tilefx` part notes still print group addresses as `14C028` etc. (the groups have no labels of their own in this note); not changed.
5. `docs/structs-reference.md` says the frame-list terminator is `$0000`; the sentence that said so is gone from `spriteset_freedan`, the doc is IT-16's.
6. A06-08: the header ranges of other tables may still use the exclusive end; only the headers of this iteration's files were converted.
