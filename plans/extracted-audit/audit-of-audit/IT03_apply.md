# IT-03 apply: "barrier" wording and the chest table (PLAN F04)

Mechanism: `npm run merge` only. Spec: `plans/extracted-audit/audit-of-audit/IT03_spec.json` (one spec; 3 files; block and part notes by `edit` ops, comments with `expect` guards). Because the notes use `edit` ops, re-running the spec reports an error instead of `=unchanged`.

## Facts re-derived before editing

- `scene_chest_table.asm` holds a 255-word pointer table plus the chest lists; every record is `chest-entry < X, Y, contents, flag >`. Counted again from the live extract: 39 non-empty lists, 5 lists with 2 records and `chest_list_scene_4D` with 3, so 39 + 5 + 2 = 46 records. Only chest records are in it.
- Readers (rg `scene_chest_table` / `PlaceOpenedChestTiles`): `PlaceOpenedChestTiles` and `HandleChestInteraction` in `warps_interaction.asm`, and the radar. `PlaceOpenedChestTiles` (`warps_interaction.asm:157-210`) walks the scene's records (`LDX $&scene_chest_table, Y`), ends on a record whose byte 0 has bit 7 set (`BIT #$0080` / `BNE`), tests the event flag (`AND #$007F`, `TestEventFlag_0200`) and, for a set flag, stores `$FE`, `$FF` (row Y-1) and `$FC`, `$FD` (row Y) into `mapLayerTilemap`. It writes open-chest tile ids and nothing else; no barrier and no collision-specific write.
- So the live wording in `scene_lifecycle.asm` ("place barrier collision tiles", "write barrier collision tiles to map", "place barriers") is wrong for two reasons: the records are chests, and the routine writes tile ids to `mapLayerTilemap`, not a collision map. The finding quotes "barrier/chest"; the live text says "barrier collision tiles" / "place barriers". The wording written is derived from the code, not copied from the finding.

## `rg -n -i barrier extracted/`, decided hit by hit

| hit group | decision |
|---|---|
| `scene_lifecycle.asm:32, 767, 864` | **Fixed** (rows below). |
| `scene_chest_table.asm:1` | **Fixed** (row below): the sentence quoted 'barrier/chest placement' as history. |
| `warps_interaction.asm:180` (inline, tag 173599) "top-left barrier cell" | **Fixed**: the cell is the chest's top-left tile (`X`, `Y-1` stored in `$18` / `$1C` just above). Same fault, not listed in the finding. |
| `warps_interaction.asm:61` ("The earlier "closed door/barrier" reading is not supported by the code") | Not changed: history narration, hygiene sweep IT-12 (A01 F8). |
| `inventory_overlay.asm:31` ("the older note said 'warp / barrier markers'") | Not changed: history narration, hygiene sweep IT-12. |
| `spriteset_aura.asm:1` ("The old note said '4 animation frames for the rotating barrier sprites'") | Not changed: the word is the Aura Barrier; the sentence is history narration for a table iteration (IT-10/IT-11 or the sweeps). |
| Aura Barrier (`attack_ability_system`, `ability_damage_tables`, `system_strings`, `sE6_gaia`, `spriteset_freedan_fx`, `spriteset_aura`, `slope_ramp_physics:30`, `dark_rewards`, `LaunchAuraBarrier` and the other `AuraBarrier*` labels) | Genuine, left. |
| Actors and scenes that really are barriers (`ec0E_barrier*`, `ec0E_switch:3`, `ec11_aqueduct_blocker:3`, `pyD6_vader_barrier_lower/upper`, `pyD0_breakable_wall:1`, `pyDD_queen_arena_boundary:4`, `scene_actors` includes and spawn rows, `enemy_stats_table:20`) | Genuine, left. |
| `event_block_table.asm:1, 8`, `event_blocks.asm:1`, `actor_execution.asm:1178` (event-block "barriers" appearing or disappearing) | Genuine (event blocks swap tiles for doors, bridges and barriers), left. |
| Dialogue strings and game text ("language barrier", Lilly's village barrier, the Aura Barrier text) | Game text and story prose, left. |

## Items

| finding id | file:line (live, after merge) | status | note |
|---|---|---|---|
| N-7 | `scene_lifecycle.asm:32` (block note) | APPLIED | "PlaceOpenedChestTiles: redraw the chests of scene_chest_table whose event flag is set as open chests in the map". |
| N-7 | `scene_lifecycle.asm:767` (`ClearSceneState` part note, step 5) | APPLIED | "write the open-chest tiles of every chest whose event flag is set (records of scene_chest_table) to the map". |
| N-7 | `scene_lifecycle.asm:864` (inline, tag 253481, guard `InitCameraBounds`) | APPLIED | "... apply event blocks, redraw opened chests". The comment on the `InitCameraBounds` line summarises the next two `JSL`s (`ApplyAllEventBlocks`, `PlaceOpenedChestTiles`); only the last words changed. |
| A01 F8 / row 42 / row 87 (`scene_lifecycle`) | `scene_lifecycle.asm:17` (block note) | APPLIED | "(rename proposed in the audit log)" removed; the sentence now ends "not graphics-cache indices:". Every other fact kept. |
| A01 F8 / row 42 / row 87 (`scene_chest_table`) | `scene_chest_table.asm:1` (block note) | APPLIED | The "old note ... was wrong" sentence replaced by "The table holds chest records only; a list ends at a record whose first (X) byte has bit 7 set." The rest of line 1 unchanged. The code agrees (`BIT #$0080` on byte 0). |
| N-7 (same fault, not listed) | `warps_interaction.asm:180` (inline, tag 173599, guard `LDX`) | APPLIED | "TileCoordsToMapIndex — map index for the chest's top-left cell (X, Y-1)". |
| (instructed) | `scene_lifecycle.asm:828` ("invincibility timer disabled") | SKIPPED | Waits for the mnemonic decision in Part 2, as instructed. |
| (instructed) | `scene_lifecycle.asm:237` ("previously ready") | SKIPPED | Runtime sense, not narration, as instructed. |
| docs | `bank01-data-tables.md`, `docs/code/README.md` | BLOCKED (IT-14) | Docs belong to IT-14. |

Applied: 6 rows (5 notes and comments in 3 files: 2 block notes, 1 part note, 2 comments; the `scene_lifecycle` block note takes two edit ops). DISPUTED: 0. SKIPPED: 2 (both by instruction). BLOCKED: 1 (docs, IT-14).

## Dry-run summary

```
system/engine/scene_lifecycle.asm: block +0 ~1 -0 =0, parts +0 ~1 -0 =0, comments +0 ~1 -0 =0   (+new ~updated -removed =unchanged)
tables/scene_chest_table.asm: block +0 ~1 -0 =0, parts +0 ~0 -0 =0, comments +0 ~0 -0 =0   (+new ~updated -removed =unchanged)
system/engine/warps_interaction.asm: block +0 ~0 -0 =0, parts +0 ~0 -0 =0, comments +0 ~1 -0 =0   (+new ~updated -removed =unchanged)
[DRY RUN] 5 notes file(s) would change; nothing written.
OK
```

No warnings. The real run reported the same counts and wrote `notes/blockNotes/bank01.json`, `notes/blockNotes/bank03.json`, `notes/partNotes/bank03.json`, `notes/comments/bank02.json`, `notes/comments/bank03.json`.

## Gate

`npm run extract:lt`, then `npm run rebuild` (separate commands): `artifacts/crc.json` = checksum 223006080, crc 2083230829, totalSize 3062204. Equal to the baseline. Every changed line was read back in the re-extracted files: `scene_lifecycle.asm:17, 32, 767, 864`, `scene_chest_table.asm:1`, `warps_interaction.asm:180`. `rg -n -i barrier` over those three files now hits only `warps_interaction.asm:61` (IT-12).

## Found outside scope (not changed)

- `warps_interaction.asm:61`: "The earlier "closed door/barrier" reading is not supported by the code." History narration; IT-12.
- `inventory_overlay.asm:31`: "the older note said 'warp / barrier markers'". History narration; IT-12.
- `spriteset_aura.asm:1`: "The old note said '4 animation frames ...'". History narration (not a chest or barrier-wording issue).
- `walk_step_table.asm:7`, `SpawnFieldRevealEffect.asm:15`, `StandardEnemyDefeatHandler.asm:15` ("The old header ..."): the A01 F8 out-of-scope-file narration hits, still unchanged; IT-12.