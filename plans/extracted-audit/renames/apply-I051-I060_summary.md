# Summary: I051–I060 (+ sanity-I051-I060) rename proposals applied to `db-us/names/`, `blocks.json`, notes and docs

Plan: `apply-I051-I060_plan.md`; reviewed map: `apply-I051-I060_map.json` (347 old→new pairs with the ledger row of each; the auto labels got a names entry at the decimal address parsed from the label suffix). Notes spec: `../edits/rename-pass-I051-I060.json` (50 entries, 15 files), applied with `npm run merge`.

## Result

| Check | Result |
|---|---|
| `npm run extract:lt` | OK. The only occurrences of old names left in `extracted/` are the intentional "first called …" mentions inside notes; every new name is present |
| `npm run rebuild` | OK; `artifacts/crc.json` = checksum 223006080 / crc 2083230829 / totalSize 3062204 (unchanged; names do not change bytes, and the `diary_menu_window_dma` transform still matches) |
| `npm run merge -- edits/rename-pass-I051-I060.json` | OK; a second dry run after `extract:lt` reports 0 notes files to change |
| `npm run ingest:dry` | Dry-run only, never run for real. Reports `MenuSelectionHandler` plus bank-key quirks for multi-bank files (`layer1_scroll_actors`, `EnemyDefeatDispatch`, `ActorMidpointCalc`, `oneshot_palette15_grey_fade_in_1F`); nothing was written |
| Plain `npm run extract` | OK; renamed block files regenerated |

## 1. Applied renames

| Ledger rows | Change |
|---|---|
| R-I051 | `visual_effect_pipeline` → `layer1_scroll_actors` with parts `Layer1DriftUnbounded` / `Layer1ParallaxRatio` / `Layer1DriftWrapped`, and their inner labels |
| R-I052 | `player_transition_handlers` pose / spark labels (`PlayerItemRevealSpawn` → spark spawner; neutral `PlayerFreedanReveal*` pose names); manual `50200` → `SpawnImpactSparkAndDie` (not in the map JSON; the block keeps its file name) |
| R-I053 | `smooth_follow_child` heading handlers (`SmoothFollowApplySSE` … `WNW`), body / tick phase labels, game-over labels (`GameOverSparkleOrbitA/B`, `GameOverFadeLoop`, …) |
| R-I054 | `StandardEnemyDefeatHandler` phase labels |
| R-I054-4 / R-I055-1 / R-I055-2 | Boot logo thinkers → `boot_logo_enix_palette_obj0/1/2` (one Enix logo palette cycle, one thinker per OBJ palette, as requested); bundles `$50`–`$58` → `palette_bundle_enix_obj{0,1,2}_*`; new `db-us/names/bank16.json` (imported in `src/names.ts`) |
| R-I056 | Dark Space / Gaia labels (`GaiaThenGo`, `GaiaThenRest`), `LookupStatueType` → `LookupAbilityForm`, diary entry labels |
| R-I057 | `sFA_diary_menu` labels, `diary_band_*` DMA labels; the `diary_menu_window_dma` transform rewritten on `diary_band_empty` / `diary_band_slot1` |
| R-I058 / R-I059 | `HdmaWindowEffect` family → `WorldMapSplitEffect` labels (BGMODE / COLDATA split), `WorldMapController` phase labels, scene-name lookup labels |
| R-I060 | `world_map_options`: 39 menus (`WorldMapMenu_<id>`), 41 handlers (`WorldMapGo_*` / `WorldMapQuit_*`); `world_map_routes` → `world_map_route_table` with 37 arrays `route_<id>_<origin>_to_<destination>` / `route_unused_<id>` |

### Deviations from the ledgers

- Boot-logo names follow your decision (`boot_logo_enix_palette_obj0/1/2`), not the ledger's `boot_logo_obj_pal*_shine`.
- R-I053-6: ledger names for `loc_00D6C3` … `loc_00D6E6` did not match the code and were replaced by names that do.
- `50200` (`SpawnImpactSparkAndDie`) was added by hand after the map was generated.
- The `world_map_route_table` block note was rewritten by hand in `notes/blockNotes/bank03.json` (`merge` cannot annotate files with no bank information).

## 2. Notes

All block / part / comment notes for renamed blocks, parts and labels were re-keyed or rewritten (stale "old name is wrong" prose, hedges and open-question wording removed); the orphan `loc_03B928` part note was deleted; 26 part notes were added for newly named labels (`WorldMapController`, `palette_bundles`, the three Enix thinkers). Part-note keys that were block-key based (`player_transition_handlers` → `SpawnImpactSparkAndDie`) were re-keyed by hand.

## 3. Docs and tooling docs corrected

R-I053-7 (smooth follow aims once, flies straight; game-over save records), R-I054-3 (defeat handler callers, reward owner), R-I055-6 (sprite part 7 bytes), R-I056-9 (Dark Space / Gaia rows, `diary-entry` is name + camera X/Y, `diary_entry_table` name), R-I057-6 (`BranchIfPressed` bit 0 = raw source, remap table, diary rows), R-I058-3 / R-I059-5 / R-I060-7 (`radar-and-world-map.md` rewritten: split effect, state block, route steps, scene names, menus; `mode7-and-cutscenes.md`), D-S5160-4 (`WaitByte(n)` = n + 1 ticks in `wait.md` and three docs), boot-logo wording (`thinkers-system.md`, `bank00/README.md`, `bank0C` table), and the transforms-adjacency hazard in `gaia-core/docs/notes-and-comments.md` (R-I057-7). Doc edits were mirrored to the `gaia-knowledge` corpus copies.

## 4. Not applied (out of scope)

- Mnemonics: R-I051-2, R-I051-5, R-I052-6, R-I053-5, R-I054-2, R-I056-6, R-I057-1, R-I057-2, R-I058-1 (b, c), R-I059-3, R-I060-5.
- Types / structs: R-I059-4 (b), R-I060-6 (b).
- `overrides.json`: R-I057-4. ROM-changing / structural: R-I052-3, R-I056-5, R-I056-8.
- Tooling gaps: sprite labels (R-I055-4/5, R-I056-4, R-I058-2, R-I059-4 c), `merge` for bank-less files (R-I060-6 c, D-S5160-3: the `world_map_routes` header text itself is now correct via the hand-edited note).

## Suggested commit message

```
Apply I051-I060 renames: names, blocks, notes, docs

- names: 347 renames (new bank16.json), Enix logo palette cycle thinkers boot_logo_enix_palette_obj0/1/2
- blocks.json / transforms.json: layer1_scroll_actors, world_map_route_table, diary_band_* rule
- notes + docs corrected (smooth follow, Dark Space/Gaia, world map split effect, route steps, WaitByte ticks)
```

Please commit when you're ready.
