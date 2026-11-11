# IT-11 apply: tables I065-I068 and three actor comments (complete clean-up)

Mechanism: `npm run merge` only. Spec: `plans/extracted-audit/audit-of-audit/IT11_spec.json` (one spec, 14 files; partial `edit` pairs, every `find` occurred exactly once; one full-text part note and one removed key in `spriteset_transform_poses`). Needs IT-01 and IT-10 (both DONE).

## Dry-run summary (shown before the apply)

```
tables/dialog_template_table.asm: block ~1, parts ~1
tables/scene_meta.asm: block ~1
tables/enemy_stats_table.asm: block ~1
tables/spriteset_aura.asm: block ~1
tables/spriteset_shadow.asm: block ~1
tables/item_pickup_text_table.asm: block ~1, parts ~1
tables/spriteset_darkgaia_projectile.asm: block ~1
tables/spriteset_transform_poses.asm: block ~1, parts +1 ~4 -1
tables/spriteset_npc_props.asm: block ~1, parts ~2
tables/display_preset_table.asm: block ~1
tables/scene_warps.asm: block ~1
system/engine/DialogStringRenderer.asm: parts ~1, comments ~1
actors/player/attack_ability_system.asm: parts ~1, comments ~1
actors/player/player_character.asm: comments ~1
[DRY RUN] 13 notes files would change: blockNotes bank01, 0D, 0E, 0F, 14, 17; partNotes bank01, 02, 03, 0E, 0F; comments bank02, 03
```

Total: 11 block notes, 10 part notes updated (+1 new, -1 removed), 3 comments. The apply wrote the same 13 files.

## Gate

`npm run extract:lt`, then `npm run rebuild` (separate commands): `artifacts/crc.json` = checksum 223006080, crc 2083230829, totalSize 3062204. Same as the expected gate (no `GATE:` line exists in the Progress log).

## Items

| finding id | file:line (live, after `extract:lt`) | status | note |
|---|---|---|---|
| A07-02 | `spriteset_aura.asm:15` | APPLIED | "copies 7 colours of fx_palette_198090 to CGRAM $A9-$AF; AuraBarrierPaletteFX cycles bundle #5B over colours $A1-$A8 of the same palette (the bundle writes only $A1-$A8)". Re-derived: `CopyPalette ( @fx_palette_198090, #00, #A9, #07 )` (`attack_ability_system.asm:401`); `AuraBarrierPaletteFX` runs `PaletteStart ( #5B )` (line 1610-1612); `palette_bundle_16C1BD` is 8 sub-entries, each `#01 frame, dest #A1, size #0F` (size `$0F` = 16 bytes = 8 colours, `palette_bundles.asm` format note) |
| A07-04 | `spriteset_transform_poses.asm:14` | APPLIED | `$0C (transform_pose_0C)`; the pointer table maps `$0C` to `transform_pose_0C` |
| A07-04 (related) | `spriteset_transform_poses.asm` part note "Animation $0C" | APPLIED (different from the finding) | The finding says the "Animation $0C: not referenced" note sits above `transform_pose_0C`. Live: it was stored under the key `transform_pose_0B` (extracted line 539, above the `$0B` list, which the scripts DO stage). Moved with one spec: key `transform_pose_0B` removed, key `transform_pose_0C` set; the note now sits above `transform_pose_0C` (line 564). Unused set re-derived from the scripts: `$04`, `$0C`, `$11` |
| A07-05 | `spriteset_npc_props.asm:6-17` | APPLIED | `fr32_locked_door` added to rows `$00` and `$01` (`StageSpriteFrame #01` line 25, `#00` line 35), `fr32_kidnapper` to `$01` (line 49), `mu63_spirits` to `$06` (`StageSpriteFrame #06` line 161, "it stages the flame, not a spirit"). Re-derived: `rg -A4 "SetMetasprite\] \( @spriteset_npc_props"` over all 25 actors; no stage operand `#03` or `#09` follows any of them, so "No actor selects animations $03 and $09" stands |
| A07-06 | `enemy_stats_table.asm:6-10` | APPLIED | +3 row names `FieldRevealFromActorStats` (field_reveal_object, `LDA $0003,Y; AND #$0003`; 0 = nothing, 1 / 2 / 3 = gem pickups of 1 / 2 / 5 gems, items `$83` / `$84` / `$85`), "spawned by EnemyDefeatDispatch for every kill but the last" (`EnemyDefeatDispatch.asm:6`); field heading lists field_reveal_object as a reader |
| A07-07 | `enemy_stats_table.asm:12` | APPLIED | "bit `$0010` of the actor's `$12` flags is damage / stagger immunity and bit `$0020` is the boss bit (EnemyInitBasic sets both)". Re-derived: `EnemyInitBasic` `LDA #$0030; TSB $12`; `combat_collision.asm` `LDA $12; BIT #$0020` "boss - skip damage display" |
| A07-08 | `dialog_template_table.asm:1` | APPLIED | caller's string pointer, bank and flags restored; cursor reloaded from `$0998`; a `[DLG]` template positions the text that follows; the speaker templates (`[SEP]`, `[SFX]`, `[PAL]` only) leave it. Re-derived: `DialogCmd_InsertTemplate` is `STX $0998; JSL DialogStringRenderer; LDX $0998; PLY; INY; PLB; PLP`; `DialogCmd_Return` is `STX $0998 ... RTL`; `DialogCmd_SetPosition` sets X and `$0998`; `SetPaletteColor`, `SetSfx` and `SetPalette` do not touch X or `$0998` |
| A07-08 | `DialogStringRenderer.asm:242-244` (`DialogCmd_InsertTemplate` part note) | APPLIED | same wording, "(DialogCmd_Return hands the cursor back only through $0998)" |
| A07-09 | `dialog_template_table.asm:18` and the `$11` part note | APPLIED | `$11` = 37 in the table row and in "Template $11 (37 uses)"; header says "comment lines excluded". Re-derived: `rg -P -c "^(?!\s*;).*\[TPL:11\]"` = 37 (all in `world_map_options.asm`, none with two tags on one line); `rg -c "\[TPL:11\]"` = 49 + 2 whole-file |
| A07-13 | `scene_meta.asm:21` | APPLIED | "layer 0 (operand $01, 225 uses) or layer 1 (operand $02, 158 uses)". Re-derived: `rg -c "tilemap < #01"` 225, `#02` 158, total 383; handler flags bit 0 = layer 0, bit 1 = layer 1 (`scene_script.asm` 61, 707, 774) |
| A07-15 | `spriteset_darkgaia_projectile.asm:11` | APPLIED | `projectile_travel_south, projectile_travel_north, projectile_travel_west, projectile_travel_east` (pointer table lines 25-32) |
| A07-16 | `player_character.asm:1850` (comment `{184168}`) | APPLIED | `table_17D000` replaced by `spriteset_darkgaia_projectile` |
| A07-16 | `attack_ability_system.asm:552` (comment `{178963}`) | APPLIED | `table_179000` replaced by `spriteset_aura` |
| A07-16 | `attack_ability_system.asm:114` | APPLIED | "its set (spriteset_aura) has 3 animations of 4 frames". The text lives in the `AttackSystemEntry` part note (not a block note); edited there |
| A07-16 | `body_table.asm:32`, docs | SKIPPED | `body_table` is IT-05's (DONE); docs are IT-14 / IT-16 |
| A07-18 | 11 files | APPLIED | the 12 history sentences removed (`dialog_template_table:1`, `scene_meta:1`, `enemy_stats_table:1`, `spriteset_aura:1`, `spriteset_shadow:3` (paragraph), `item_pickup_text_table:1`, `spriteset_darkgaia_projectile:1`, `spriteset_transform_poses:1`, `spriteset_npc_props:1`, `display_preset_table:1` and `:15` "first audit pass", `scene_warps:1`); the facts they carried are kept as plain statements. Also `spriteset_shadow` "Checks" section renamed "TOTALS" and "(the label spacing ... was checked by hand)" removed; `spriteset_aura` "Checks:" -> "Byte budget:" |
| A07-19 | 11 files | APPLIED | all OQ / R ids removed (`OQ-I065-1`, `R-I065-6`, `OQ-I066-1/2/3`, `OQ-I061-1`, `OQ-I067-1..5`, `OQ-I068-1..4`, `OQ-5`, `OQ-I064-1`); open facts stated as "Not traced: ..." or removed where the sentence already said it. The DialogStringRenderer comment `{254630}` lost "see audit OQ-23" |
| A07-20 | `scene_warps.asm:23` | APPLIED | the "Sampled about 18%" sentence removed |
| A07-20 | `item_pickup_text_table.asm:10` | APPLIED | "(line 1563)" replaced by the routine: `InteractionDamage_NPCChat` in combat_collision (line 1563 is `LDY #$&item_pickup_text_table.dialog_item_full` inside it) |
| A07-22 | `scene_warps.asm:23` | APPLIED | `$0AF4` written as `reviveWarpPtr ($0AF4; ...)`; `$00D4`, `$00D6`, `$0DB8`, `$0998`, `$0996` stay as they are |
| (range convention, from IT-10) | headers of 11 files | APPLIED | inclusive last byte (`blocks.json` end - 1), as in IT-10: `dialog_template_table` 117397-117669, `scene_meta` 884736-897022, `enemy_stats_table` 109552-109991, `spriteset_aura` 1544192-1544617, `spriteset_shadow` 1343488-1355930 (the item IT-10 left for IT-11), `item_pickup_text_table` 130340-130923, `spriteset_darkgaia_projectile` 1560576-1561583, `spriteset_transform_poses` 1032192-1043844, `spriteset_npc_props` 973312-974143, `display_preset_table` 98304-98867, `scene_warps` 98868-108893 (blocks.json ends are exclusive: adjacent blocks share the boundary, e.g. `scene_warps` end = `forced_walk_pan_table` start). `scene_meta` could not be cross-checked by adjacency or a byte budget, it follows the same rule |
| A07-23 | `enemy_stats_table.asm:21` | APPLIED (id only) | the sentence is kept and `(OQ-I066-1)` removed. The census was re-derived with `rg` (not recomputed in full): none of the 16 rows `$06 $07 $09 $1F $20 $21 $22 $38 $39 $3B $40 $41 $4B $52 $53 $59` is the 5th operand of any `enemy-spawn` record in `scene_actors.asm` (0 matches), and every `enemy_stats_table+offset` operand in `extracted/` maps (offset / 4) to a row of the "named by code" list (`+4 $01`, `+20 $08`, `+44 $11`, `+C4 $31`, `+CC $33`, `+DC $37`, `+118 $46`, `+11C/+120 $47/$48`, `+134 $4D`, `+154..+160 $55-$58`, `+17C/+180 $5F/$60`, `+190 $64`, `+1A4 $69`). Not re-checked: that all 16 rows have non-zero stats |
| A07-21 | `scene_warps.asm` `stair-warp` | SKIPPED | by instruction (Part 2, user-owned `structs.json`) |
| A07-10, 11, 12, 14, 17 | various | SKIPPED | other iterations (IT-01, IT-02, IT-14) |
| parallax_scroll_table | whole file | SKIPPED | read only, as instructed: `rg` for ids, history and narration = 0 hits |

Counts: applied 21 rows (incl. the moved note and the range convention), disputed 0, skipped 4 rows, blocked 0.

## Outside scope / found while working

1. `actors/player/player_character.asm` still carries OQ ids at lines 7, 40, 79, 91, 114, 127, 132, 1551, 1557, 1784 (e.g. `OQ-I025-5` on line 40, next to the `spriteset_darkgaia_projectile` sentence). IT-12 / IT-13.
2. `DialogStringRenderer.asm:156` (the command table part note, "whether any string uses them was not checked") is a hedge on an untraced fact, left as it is.
3. `spriteset_darkgaia_projectile.asm:1` and `player_character.asm:40, 1845` keep "spawned only in scene $E8" (A07-24, reported, not re-traced).
4. `parallax_scroll_table` has no range in its header; other tables outside the A06 / A07 file lists may still print exclusive end addresses.
5. The `scene_warps.asm:5` text "a negative byte 0 ends a list in InitWarpTable" is garbled ("a byte with bit 7 set"); not in this iteration's finding list, left unchanged.
6. Shell deviation (disclosed): the OQ-I066-1 census and the `[TPL:11]` count used `rg` only, but the `enemy_stats_table+offset` listing was piped through `sort`, `uniq` and `head` once. Read-only, nothing written.
