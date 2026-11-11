# IT-04 apply: name renames that are clear now (PLAN F03 part 2 and new)

Mechanism: `npm run names` only. Spec: `plans/extracted-audit/renames/apply-IT04_names.json` (one spec, 37 entries, all renames; the run reported `~37 renamed, +0 added, =0 unchanged`). Decisions: U1 (names approved by the user), U2 (labels renamed to the copdef spelling). The user widened the scope during the iteration: the `copdef.json` renames C01–C08 of A14 (name only, id fixed) are in scope when the name is accurate. They went through the same spec: each handler label has the same word as its copdef key, and `npm run names` rewrites `db-us/*.json`, so `db-us/copdef.json` changed through the tool (9 references), not by hand.

## Facts re-derived before the spec was written

- `body_table` rows 4–7 are `spriteset_will_abilities`, `spriteset_transform_poses`, `spriteset_freedan_fx`, `spriteset_shadow_fx`; `GetPlayerFacingDirection` indexes `FacingFormOffsetTable` with `$0AC8 − 4`, so the four `FacingData_*` tables follow rows 4–7 in that order. The last two names already matched; the first two now do too.
- Thinker runners: `RunThinkers_General` (bit 2 clear), `_Hdma` (bit 2 set), `_General_Light` (bit 11 set, bit 2 clear), `_Hdma_Light` (both set). Each `_Next` sub-label is the continuation of the runner right above it (`thinker_execution.asm` 168–316), which fixes the letter-to-parent mapping A→General, B→Hdma, C→General_Light, D→Hdma_Light.
- Callers of the two facing resolvers: `ResolveFollowDirection` is called with bases 0, 4, 8, `$C` (N, E, S, W); `ResolveFollowDirectionAlt` with 2, 6, `$A`, `$E` (NE, SE, SW, NW). Row 64 of `I001-I020_rename-proposals.md` gives `ResolveFacingFromAxisBase` / `...FromDiagonalBase`, and this is the only mapping the code supports.
- `FollowChaseDiagQuadrantSW/NW` are the front halves (facing turn) of the two up-right octant handlers; `FollowChaseHeadNNE/ENE` were their apply halves (`COP [SetEntryHere]`). The other six handlers are `FollowChaseHeadXXX` (front) plus `FollowChaseApplyXXX` (apply), so the pairs were swapped to the same pattern. `FollowChaseDiagQuadrantNE` is one `JMP $&FollowChaseHeadWNW` (target up-left, X dominant), the same kind of trampoline as `FollowChaseDominantXGreater` / `...Alt`. `follow_fallback_table` entries 0 and 1 still point at the apply halves (now `FollowChaseApplyNNE` / `ENE`); the gate confirms the bytes.
- `ResolveFollowDir*` sub-labels: `...MoveXOnly/Diagonal/MoveYOnly` store the facing offset 0/1/2 in `$0002`; `...AdvanceFrame` stores the desired frame in `$0004` and compares it with the current facing; `...AltDecFrame` / `...AltIncFrame` step the facing counter-clockwise / clockwise; `...AltSnapFrame` sets the facing to the desired frame and `$0000 = $FFFF`; `...AltApplyFrame` writes the spawner animation; `...AltSkipAnimUpdate` is the test before `UpdateActorAnimation`; `...AltUpdateAnim` / `...AltLoadTable` do the `FollowDirectionTable` jump. The `Alt` in these nine names was wrong: they are a tail shared by both entries.
- Copdef rows (handler code read for each): `BranchIfCollisionTypeNe` (`$62`) branches on `BEQ` (and when out of bounds); `QueueDma` (`$02`) calls `SetupHdmaChannel_Direct` (DMAP without `$40`, sets the HDMA enable bit); `ResetSpriteState` (`$55`) only stores animation index, frame counter, VRAM word address and resume pointer; `WorldMapStream3/4` (`$4D`/`$4E`) call the same `ResolveTileData` as `DrawMetatileAbs`, the 4th byte of the `$4E` record is stored in `$08` (wait counter); `ReloadMoveDurations` (`$B1`) re-runs `AnimFrameLookup` for `moveXAlt` / `moveYAlt` and rewinds `$2C` / `$2E`; `ForceDirSW/NE/Both` (`$AD`/`$AE`/`$AF`) set or clear `$12` bits `$4000` / `$2000` / `$6000`, which `tile_collision_physics` reads only to negate the X / Y movement delta.

## Names written

| finding id | address | old → new | status | note |
|---|---|---|---|---|
| A01-36 / U1 | 258431 | `FacingData_WillAlt` → `FacingData_WillAbilities` | APPLIED | row 4 `spriteset_will_abilities` |
| A01-36 / U1 | 258458 | `FacingData_AbilityFx` → `FacingData_TransformPoses` | APPLIED | row 5 `spriteset_transform_poses` |
| A02-02 | 250198 | `RunThinkers_TypeA_Next` → `RunThinkers_General_Next` | APPLIED | |
| A02-02 | 250246 | `RunThinkers_TypeB_Next` → `RunThinkers_Hdma_Next` | APPLIED | |
| A02-02 | 250299 | `RunThinkers_TypeC_Next` → `RunThinkers_General_Light_Next` | APPLIED | |
| A02-02 | 250350 | `RunThinkers_TypeD_Next` → `RunThinkers_Hdma_Light_Next` | APPLIED | |
| A01-F5 / U2 | 41089 | `StagePlayerSpriteMoveX` → `StagePlayerMoveX` | APPLIED | COP `$90`; equals the copdef spelling |
| A01-F5 / U2 | 41127 | `StagePlayerSpriteMoveY` → `StagePlayerMoveY` | APPLIED | COP `$91` |
| A01-F5 / U2 | 41165 | `StagePlayerSpriteMoveXY` → `StagePlayerMoveXY` | APPLIED | COP `$92` |
| A01-64 | 59187 | `FollowChaseDiagQuadrantNE` → `FollowChaseDominantXGreaterUpLeft` | APPLIED | trampoline to `FollowChaseHeadWNW` |
| A01-64 | 59190 | `FollowChaseDiagQuadrantSW` → `FollowChaseHeadNNE` | APPLIED | front half, swap with the next row |
| A01-64 | 59210 | `FollowChaseHeadNNE` → `FollowChaseApplyNNE` | APPLIED | apply half |
| A01-64 | 59235 | `FollowChaseDiagQuadrantNW` → `FollowChaseHeadENE` | APPLIED | front half, swap with the next row |
| A01-64 | 59255 | `FollowChaseHeadENE` → `FollowChaseApplyENE` | APPLIED | apply half |
| A01-64 | 61052 | `ResolveFollowDirection` → `ResolveFacingFromAxisBase` | APPLIED | |
| A01-64 | 61068 | `ResolveFollowDirectionAlt` → `ResolveFacingFromDiagonalBase` | APPLIED | |
| A01-64 | 61082 / 61090 / 61098 | `ResolveFollowDirMoveXOnly` / `MoveDiagonal` / `MoveYOnly` → `ResolveFacingOffset0` / `Offset1` / `Offset2` | APPLIED | the row names no sub-label; names derived from the code (user: "come up with appropriate names") |
| A01-64 | 61104 | `ResolveFollowDirAdvanceFrame` → `ResolveFacingCompare` | APPLIED | |
| A01-64 | 61152 | `ResolveFollowDirAltWrapNeg` → `ResolveFacingCompareNegative` | APPLIED | |
| A01-64 | 61169 / 61195 | `...AltDecFrame` → `ResolveFacingStepCounterclockwise`; `...AltIncFrame` → `ResolveFacingStepClockwise` | APPLIED | |
| A01-64 | 61212 | `ResolveFollowDirAltSnapFrame` → `ResolveFacingSnapToDesired` | APPLIED | |
| A01-64 | 61225 | `ResolveFollowDirAltApplyFrame` → `ResolveFacingSetSpawnerAnim` | APPLIED | |
| A01-64 | 61248 | `ResolveFollowDirAltSkipAnimUpdate` → `ResolveFacingRefreshSpawnerSprite` | APPLIED | |
| A01-64 | 61266 / 61290 | `...AltUpdateAnim` → `ResolveFacingDispatch`; `...AltLoadTable` → `ResolveFacingLoadHandler` | APPLIED | |
| A14-C01 | 39745 | `BranchIfCollisionTypeNe` → `BranchIfCollisionTypeEq` | APPLIED | copdef id `$62` |
| A14-C02 | 34464 | `QueueDma` → `QueueHdmaDirect` | APPLIED | copdef id `$02` |
| A14-C03 | 39386 | `ResetSpriteState` → `SetTileStreamAnim` | APPLIED | copdef id `$55`; **differs from the ledger** (`StartTileStreamAnim`): the handler starts nothing, `AdvanceSpriteAnim` does the streaming. Also the `blocks.json` part key |
| A14-C06 | 38659 / 38772 | `WorldMapStream3` / `4` → `DrawMetatileStream` / `DrawMetatileStreamDelay` | APPLIED | copdef ids `$4D` / `$4E`; **differs from the ledger** (`PaintTileStream3/4`): these draw metatiles through `ResolveTileData`, and `$4E` has a delay byte |
| A14-C07 | 42905 | `ReloadMoveDurations` → `ReloadMoveChains` | APPLIED | copdef id `$B1` |
| A14-C08 | 42771 / 42801 / 42831 | `ForceDirSW` / `NE` / `Both` → `SetMoveNegateX` / `SetMoveNegateY` / `SetMoveNegateXY` | APPLIED | copdef ids `$AD` / `$AE` / `$AF`; **differs from the ledger** (`ForceFlipX/Y/XY`): "flip" reads as a sprite mirror (`ToggleHMirror` exists); the bits only negate the movement delta |
| A14-C04 | `SetMetasprite` (copdef `$88`) | | BLOCKED | `baserom/red-jewels/ChestFlaggedHiddenRedJewel.patch.asm:31`, `baserom/red-jewels/generic_sparkle.asm:13` and `IOGRetranslation/modules/walkable-world-map/walkable_world_map_core.asm:253` use it; patch sources may not be edited. Needs the three sources changed in the same step (user decision) |
| A14-C05 | `RunPlayerAnim` (copdef `$93`) | | SKIPPED | alias note only, no rename |

Applied: 37 name entries (the copdef keys changed with them: 9 references). DISPUTED: 0. SKIPPED: 1 (C05). BLOCKED: C04, plus the rows the iteration excluded, listed below.

## BLOCKED (excluded by the iteration prompt, not touched)

- A03 section 2 rows waiting on an open question: R-I033-1/2/3, R-I034-3, R-I036-6, R-I037-1/3/4, R-I038-1/3, R-I039-2.
- A02: R-I030-1/2. A01 rows 89 and 95 (wait on OQ-63 / OQ-68).
- The actor label `awB2_stair_climb` (OQ-I023-1).
- The "Ankor / Angkor" label spelling (U5).
- Every mnemonic, struct and the other copdef renames (C09 operand names are not expressible: copdef parts are type lists only, A14-F03).

## Dry-run summary

```
Names: 37 entries: +0 added, ~37 renamed, =0 unchanged
[DRY RUN] 35 file(s) would change; nothing written.
```

References rewritten (identical in the dry-run and the real run): `db-us/blocks.json` 1, `db-us/copdef.json` 9, `db-us/names/bank00.json`, `db-us/names/bank03.json`, `notes/blockNotes` (bank00 28, bank03 7, bank0B 1, bank14 4), `notes/comments` (bank00 9, bank02 2, bank03 1), `notes/partNotes` (bank00 36, bank03 2, bank14 2), 21 files under `docs/`, and `IOGRetranslation/modules/apocalypse-gaia/mode7-arena-research.md` (1). No hit in `db-us/transforms.json`, `baserom/`, `src/` or `gaia-core/docs` before the run.

## Gate

`npm run names -- --check`: `Names check: OK (3510 names)`. `npm run extract:lt`, then `npm run rebuild` (separate commands; the rebuild reported `ROM rebuild completed successfully!`): `artifacts/crc.json` = checksum 223006080, crc 2083230829, totalSize 3062204. Equal to the baseline.

Read back in the re-extracted files: `GetPlayerFacingDirection.asm` 96–108, `thinker_execution.asm` 168–316, `smooth_follow.asm` 94–156, 364–365, 517–651, `cop_dispatch.asm` and `cop_handlers_player_sprite.asm` (label and dispatch names), `db-us/copdef.json` keys. `rg -w` of every old name over the baserom repo (outside `plans/`, `temp/`, `artifacts/`, `extracted-jp/`) gives no hit.

## Notes that read wrongly after the rename (for `merge`: IT-05 / IT-06 / IT-47 / IT-48; I did not edit them)

The tool rewrites a name wherever it stands as a whole word, so sentences that called the old name wrong, or listed several old names with a slash, are now garbled or tautological:

- `cop_handlers_player_sprite.asm:1` "The copdef names for #90-#92 are StagePlayerMoveX/Y/XY (the labels here are StagePlayerMoveX/Y/XY)" and the part notes "(copdef StagePlayerMoveX)" (A01 F5). `cop_dispatch.asm:70` and the `cop_dispatch_table` part note still list `StagePlayerSprite/MoveX/MoveY/MoveXY`.
- `cop_handlers_actor_flags.asm:5` ("despite the "Ne" in the COP name (audit rename proposal)") and `:75` ("The COP name BranchIfCollisionTypeEq says "not equal" ...") (A14-F11).
- `cop_handlers_hdma_dma.asm:73` ("The name QueueHdmaDirect is misleading; QueueHdma is the indirect variant").
- `cop_handlers_force_move.asm:5` ("SetMoveNegateX/NE/Both ..."), `:74` and `:97` ("the copdef name says SW / NE"), `actor_pool.asm:98` ("SetMoveNegateX/NE/Both"), and the comments on `attack_ability_system.asm:1040` ("Set NE force direction") and `:1049` ("Set both force directions").
- `cop_handlers_metatile.asm:9` ("DrawMetatileStream/4 stream ..."; the `$4E` op is `DrawMetatileStreamDelay`), and the `#4D` / `#4E` handler notes ("No script sites", "like WorldMapStream3").
- `cop_handlers_sprite.asm:34` ("Despite the name it resets no sprite state") for `SetTileStreamAnim`.
- `smooth_follow.asm:7` ("ResolveFacingFromAxisBase/Alt"), `:51` ("the FollowChaseHeadNNE/NW and FollowChaseApplyNNE/ENE sub-labels": now `FollowChaseHeadNNE/ENE` front halves and `FollowChaseApplyNNE/ENE` apply halves), `:527` ("ResolveFacingOffset0/Diagonal/MoveYOnly describe the normal entry only": should read `ResolveFacingOffset0/1/2`, which are shared by both entries), `:518` ("the Alt entry"), and the `InitFollowAndChase` / `ResolveFacingFromAxisBase` part notes that say the tail sub-labels are "in the Alt block".
- `GetPlayerFacingDirection.asm:16, 18` still say `will_alt, ability_fx` and "(WillAlt, AbilityFx, FreedanFx, ShadowFx)"; `FacingData_WillAbilities` / `FacingData_TransformPoses` are in the text now, but the nickname prose is IT-05. The same file's `FacingData_*` byte-count sentences are correct.
- `thinker_execution.asm` prose ("TypeA/B/C" at 38, 167, 197, 210, 255, 257, 285) and `mode7_perspective` (A03-12 / A04-06) still use the retired letters: IT-06 / IT-07.
- `docs/` (changed by the tool, not reviewed): `docs/code/bank03/field-input-and-items.md:433-434` describes `FacingData_WillAbilities` as "Will's frame→direction map" and `FacingData_TransformPoses` as "Freedan's map"; the second is wrong (row 5 is the transform / ability poses). `docs/cop/families/player_sprite.md:42-44` now shows the same name in the copdef and handler columns. `docs/cop/README.md`, `docs/cop-commands-reference.md` and the other `docs/cop/families/*.md` carry the new names mechanically; their descriptions of the old names (for example "name is misleading") are for IT-16 / IT-43 / IT-51.

## Found outside scope (not changed)

- `extracted-jp/` (the Japanese extraction) still contains the old copdef names (`ResetSpriteState`, `QueueDma`, `WorldMapStream3/4`, `ForceDir*`, ...). It uses its own database (`db-jp`), the tool does not touch it, and it is not part of the US gate. If `db-jp/copdef.json` should follow, that is a separate decision.
- `IOGRetranslation` already has many uncommitted changes of its own; the only file this iteration changed there is `modules/apocalypse-gaia/mode7-arena-research.md` (one reference).
- `artifacts/file-layout.json` and `artifacts/master-lookup.json` show as modified in git after `rebuild --artifacts` (the gate file `crc.json` has the same three values).
- A14 asks that `SetMetasprite` (C04) and the three patch sources change together; not done (see BLOCKED).
