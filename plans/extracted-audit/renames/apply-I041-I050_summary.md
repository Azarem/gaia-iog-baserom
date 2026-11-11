# Summary: I041–I050 rename proposals applied to `db-us/names/`, `blocks.json`, notes and docs

Plan: `apply-I041-I050_plan.md`; reviewed map: `apply-I041-I050_map.json` (164 old→new pairs with the ledger row of each; 105 of them were auto labels that gained a names entry at the decimal address parsed from the label suffix, 59 renamed an existing name or block key). Frozen ledgers (`results/`, `renames/I0*_renames.md`, `questions/`, `edits/I0*.json`) and `artifacts/` were not edited by hand. Merge spec: `edits/rename-pass-I041-I050.json` (62 entries).

## Result

| Check | Result |
|---|---|
| `npm run extract:lt` | OK. The only occurrences of old names left in `extracted/` are the intentional "formerly …" mentions inside notes; every new name is present |
| `npm run rebuild` | OK; `artifacts/crc.json` = checksum 223006080 / crc 2083230829 / totalSize 3062204 (unchanged, names do not change bytes) |
| `npm run ingest:dry` | Only the known baseline (`MenuSelectionHandler` transform artifacts and the two bank-key quirks in bank0B / bank09) |
| `npm run merge -- edits/rename-pass-I041-I050.json` | OK (17 asm files: 9 block notes, 45 part notes of which 28 are new, 8 comments) |
| Plain `npm run extract` | OK; renamed block files regenerated (`hit_switch`, `unused_particle_rain_spawner`, `gold_ship_wreck_palette`, `DamageNumberShort_unused`, `SpawnDamageNumberEffect`, `SpawnItemSparkleEffect`, `EnemyDropSystem`), the old ones are deleted |

## 1. Applied renames (names files, `blocks.json`)

| Ledger rows | Change |
|---|---|
| R-I041-1, -2 | `SpawnAttackTrailEffect`→`SpawnDamageNumberEffect`, `AttackTrailShort_unused`→`DamageNumberShort_unused`; Mode7 quadrant labels; hidden red jewel labels |
| R-I042-1, -2, -3 | item sparkle effect; `floor_button`→`hit_switch` (+ labels); 15 `OverworldExit*Stage` / `SouthCapeEdge` labels |
| R-I043-1, -2 | town door and jeweler labels |
| R-I044-1, -2 | `incan_ruins_transform_palette`→`gold_ship_wreck_palette`; 11 `GlobalAmbient*` labels |
| R-I045-1, -2, -4, -5, -6 | AutoAlign, Nudge, PlayerMovementTick, ApplyOrbitalOffset; `particle_rain_spawner`→`unused_particle_rain_spawner` |
| R-I046-1, -2, -3, -6 | `HitStagger*`, `EnemyDefeatDispatch` |
| R-I047-1, -2, -4, -5 | `PlayerMove*` (10), `JoypadVelocity*` (10), `InventoryStatueSlot*` (4), `*IncreaseStore` (3) |
| R-I048-1, -2 | `StatueReward*`, `IsNotLoromAddress`, ShadowShimmer strip labels (subset) |
| R-I049-1, -2, -3, -4 | `DarkGemDropSystem`→`EnemyDropSystem`, `SpawnDarkGemType1`→`SpawnDropGem1` and the other drop labels; 35 `DebugMenu*` / `DebugWarp*` / `DebugManEntry` labels; `CameraDeadBounds*` |
| R-I050-3, -4 | `NpcWander*`; `camera_drift_offsets`, `CameraDriftShipPassEnd` |

### Deliberate deviations from the ledgers

- `SouthStep` and `PlayerMoveCollisionTick`: names chosen to match the sibling families already in `db-us` rather than the ledger's wording.
- Pure up/down joypad handlers are `JoypadVelocityPureUp` / `JoypadVelocityPureDown` (not `…North` / `…South`), so they cannot be confused with the facing-based names (facing 0/1/2/3 = down/up/left/right).
- R-I048-2: only the subset whose role was confirmed from code was renamed.
- No R-I044-3 and no `overrides.json` retype (out of scope).
- `CameraDeadBounds*` renamed but not removed.

## 2. Not applied

- Mnemonics / `copdef.json` rows: R-I041-3, R-I042-4, R-I043-3, R-I044-4, R-I045-3, R-I046-4/5, R-I047-3, R-I048-3/4, R-I050-1/2.
- Structs: R-I041-4 (`structs-reference.md` text corrected only, `structs.json` untouched).
- R-I043-4: keep as is.

## 3. Notes and comments

- `notes/{blockNotes,partNotes,comments}/bank*.json` re-keyed with the same single-pass map (word-boundary, longest first, also after `\n` escapes). All 136 notes keyed by an old label were re-keyed.
- Prose rewritten where the note called the old name wrong or inverted: block notes `SpawnDamageNumberEffect`, `DamageNumberShort_unused`, `hit_switch`, `EnemyDropSystem`, `global_ambient_dispatcher`, `gold_ship_wreck_palette`, `hit_stagger_controller`, `shadow_shimmer`, `slope_ramp_physics`; part notes for `GlobalAmbient*`, `HitStagger*`, `StatueRewardNotThisStatue`, `ShadowShimmer*`, `DarkSpaceRestoreControl`, `EnemyGemDropRouter` (A = stat byte +3), `CompanionDotMovement`; comments 49112, 49359, 49544, 56667, 176664, 181183, 587509, 238733.
- 28 new part notes for labels that had none: 10 `PlayerMove*`, 10 `JoypadVelocity*`, 4 `InventoryStatueSlot*`, 3 `*IncreaseStore`, `StatueRewardEntry`.

## 4. Documentation and consumers

- `docs/**`: names replaced across `docs/code/bank00`–`bank0C`, `docs/cop/families/*`, `docs/structs-reference.md`, `docs/wram-memory-map.md`, `docs/unused-mode7-boss-analysis.md`, `docs/actor-organization-analysis.md`; fact corrections by ledger row (facing directions, Flags10 `$0008` collision-checked movement, `COP QueueDma` B-bus registers, `SpawnLastRel` = `SpawnListAppend` alias, `M7SEL $80`, `$B6`/`$B8`/`$BC` globals, `$0D60` companion array, warmup flag `$4D` / final flag `$52`).
- Baserom patches renamed: `baserom/fonts/EnhancedOverworldText.patch.asm`, `baserom/player-input/MergeInputFlags.patch.asm`, `baserom/red-jewels/RedJewelSparkle.patch.asm`.
- IOGRetranslation modules renamed: `modules/base/patches/chapter01.patch.asm`, `modules/ichagas/patches/chapter01.patch.asm`, `modules/base/patches/ExpandedOverworldRoutes.patch.asm`, `modules/widescreen/scene_actors.asm` (8 `floor_button` → `hit_switch` references).
- `gaia-core/docs/rom-mapping-guide.md` and gaia-knowledge `curated/gaialabs/rom-mapping-guide.md` (tree comment for `hit_switch.asm`), `curated/gaialabs/asm-patterns.md`, `corpus/games/iog/project-docs/*`.

## 5. Caveats

- Baserom patches and retranslation modules are compiled by the external retranslation build, not by `npm run rebuild`; they were renamed consistently but not compiled here.
- gaia-knowledge semantic copies were name-replaced only; `npm run ingest:all` there would refresh them (never run `ingest` for real from this repo).
- Not touched: `extracted-jp`, `db-jp`, `IOGRetranslation/release/`, `IOGRetranslation/artifacts/file-layout.json`, generated `gaia-docs` JSON.
- No Mesen runtime check for this pass; the label roles were verified statically against the code.
- `docs/code/bank00/actors-player-rewards.md` still says `SpawnSparkleEffect` spawns "via `SpawnLastRel`" (documented alias of `SpawnListAppend`, left as is).
- Scratch scripts used for the pass are in `temp/` (`mkmap.mjs`, `apply-rename-I041-I050.mjs`, `chk.mjs`, `mkspec.mjs`, …); they are not part of the deliverable.

## Suggested commit message

```
IOG: apply I041-I050 renames (names, blocks, notes, docs)

- 164 label/block renames across db-us/names, blocks.json, notes, docs
- 62 note edits (28 new part notes) via merge
- patches/modules updated for hit_switch, GlobalAmbient*, Mode7 and jewel labels
ROM bytes unchanged (CRC 2083230829).
```

Please commit when you're ready.
