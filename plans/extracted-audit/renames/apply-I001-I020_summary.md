# Summary: I001–I020 rename proposals applied to `db-us/names/`

Plan: `apply-I001-I020_plan.md` (same folder). Frozen ledgers (`results/`, `renames/I0*_renames.md`, `questions/`, `edits/I0*.json`) and `artifacts/` were not edited.

## Result

| Check | Result |
|---|---|
| `npm run extract:lt` | OK; no old name is left anywhere in `extracted/` |
| `npm run ingest:dry` | Only the known `MenuSelectionHandler` noise (OQ-59) |
| `npm run rebuild` | OK; `artifacts/crc.json` = checksum 223006080 / crc 2083230829 / totalSize 3062204 (unchanged) |

Scope: 92 old→new pairs applied (77 pure renames plus the 15 new names below). Each pair was checked as unused in `db-us`, `extracted`, `baserom` and the IOGRetranslation modules. The only collisions are with `copdef.json` COP names, which live in a separate namespace and are harmless.

## 1. Renames in names files only (bank00–bank03)

**Collision / metatile (bank02):** RebuildTilemapAttrs→BuildMetatileFlagTable, ReloadMapData→RebuildCollisionLayer, ReloadMapLayer0→FillCollisionFromLayer0, ReloadMapLayer1→OverlayCollisionFromLayer1

**Tile offsets (bank03):** AdvanceTileOffsetRight→AdvanceTileOffsetY, AdvanceTileOffsetDown→AdvanceTileOffsetX

**COP handler labels aligned with `copdef.json` (bank00):**
BranchIfType{Here,North,South,West,East}→BranchIfSolidType{,North,South,West,East}; StageSpr→StageSpriteFrame; StageSprX/Y/XY→StageSpriteMoveX/MoveY/MoveXY; StageSprLoop→StageSpriteLoop; StageSprLoopX/Y/XY→StageSpriteLoopMoveX/MoveY/MoveXY; StagePlayerSpr→StagePlayerSprite; StagePlayerSprX/Y/XY→StagePlayerSpriteMoveX/MoveY/MoveXY; SetOamPriority→SetSpritePriority; SetOamPalette→SetSpritePalette

**Facing (bank03):** GetPlayerFacing_AltEntry→GetPlayerFacing_BaseBodyFallback, FacingData_Will→FacingData_WillAlt, FacingData_Freedan→FacingData_AbilityFx, FacingData_Shadow_A→FacingData_FreedanFx, FacingData_Shadow_B→FacingData_ShadowFx

**Chest / console (bank02, bank03):** PlaceBarrierTiles→PlaceOpenedChestTiles, ConsoleCmd_AdvanceRow2→ConsoleCmd_NewLine, ConsoleCmd_AdvanceRow4→ConsoleCmd_DoubleNewLine, ConsoleCmd_InsertItemName→ConsoleCmd_InsertSharedWord, ComposeDigits_Continuation→ComposeDigitSprites_AtCursor

**Camera / DMA strips (bank02):** RenderScrollRow→RenderColumnStrip, RenderScrollColumn→RenderRowStrip, DmaHorizontalStrip→DmaColumnStrip, DmaVerticalStrip→DmaRowStrip, SpriteVramDma→Bg3TilemapVramDma

**Follow / chase (bank00):** SmoothFollowLookup→FollowSlopeDitherTable; FollowChaseMove{West,East,North,South,DiagNE,DiagSE,DiagSW,DiagNW}→FollowChaseHead{ESE,SSE,SSW,WSW,WNW,NNW,NNE,ENE}; FollowChaseApply{West,East,North,South,DiagNE,DiagSE}→FollowChaseApply{ESE,SSE,SSW,WSW,WNW,NNW}; FollowChaseYDiffNegative→FollowChaseDxNegative; FollowChaseXDiffNegativePrimary/Secondary→FollowChaseDyNegativePrimary/Secondary

**Music / actors / misc:** MusicPlaybackActor→MusicJingleActor, DieNow_UnlinkChildren→DieExit, FillWramBlock→OamFillE0_unused, WramFillConstant→OamFillConstant_unused, SwapEventBlockTiles→CopyEventBlockTiles, IncrementCounter_Unused→RngStep_Unused, RadarBorderTileTable→RadarBorderColorTable, EnemyHitPlayerHandler→ApplyHitDamageToVictim, InvinciblePlayerHit→HitInvincibleVictim, EnemyHitPlayer_Epilogue→ApplyHitDamageToVictim_DamagePath

## 2. Renames that also changed `blocks.json` (part or block key)

| Old | New | Kind |
|---|---|---|
| SignedMultiply | Multiply8x8Unsigned | part (+ names) |
| scene_flag_table | slope_curve_table | part (+ names) |
| signed_sine_table | signed_cosine_table_8bit | part (+ names) |
| signed_sine_table_16bit | neg_sine_halfwave_16bit | part (+ names) |
| sine_table_16bit_quarter | cosine_table_16bit_tail | part (+ names) |
| scene_barrier_chest_table | scene_chest_table | block; file is now `extracted/.../scene_chest_table.asm` |
| item_component_table | shared_word_table | block; also the `transforms.json` key; file is now `shared_word_table.asm` |

## 3. New names (all with part notes)

Names added in numeric order to the bank file. The part notes for the first group already existed under the auto-label and were carried over by the key rename. The rest were written in `edits/rename-pass-I001-I020.json` and applied with `npm run annotate`.

| Old auto-label | New name | Part note |
|---|---|---|
| code_02845C | SceneCmd_Default | carried over |
| code_0285F3 | InterleaveTilesPriority | carried over |
| code_02AAF2 | ExecuteForcedWalkWarp | carried over |
| code_009230 | CardinalToPlayer_Exit | carried over |
| loc_0080B5 | MainLoop | new |
| loc_00820E | UpdateHUD_Active | new |
| loc_00ACC9 | WaitStoreAndYield | new |
| loc_00A60E | UnlinkChildrenCascade | new |
| loc_02A056 | MusicJingleAfterSpawn | new |
| loc_02A07D | MusicJingleRenderSync | new |
| loc_02A0A9 | MusicJingleSpcReady | new |
| loc_02A0DA | MusicJingleWaitFinal | new |
| loc_02A119 | IsMusicPlayingYes | new |
| binary_01D911 | ramp_curve_arc_64 | new |
| binary_01D951 | ramp_curve_arc_32 | new |

Deviation from the proposal: `SceneCmd_Noop` became **`SceneCmd_Default`**. `SceneCmd_Noop` was too close to the existing `SceneCmd_Nop` (INY then RTS), and this label is the shared RTS handler for the unimplemented opcodes.

## 4. Part notes, block notes and comments

- Part-note keys, block-note keys and the text of part/block notes and comments in `notes/{blockNotes,partNotes,comments}/bank*.json` were updated for every pair above.
- Sentences that said a name was misnamed, a misnomer, "despite the name" or "pending rename" were removed or rewritten (for example `ApplyHitDamageToVictim_DamagePath`: it begins with the TXY/RTS landing pad of the PEA label−1 RTS trick; comment 245591 describes the same).
- Bare-token names also corrected in text: AdvanceRow4→DoubleNewLine, AdvanceRow2→NewLine, InsertItemName→InsertSharedWord, itemcomp_table→shared_word_table.

## 5. Documentation corrected

- `docs/**` (34 files under `docs/code`, plus `bank01-data-tables.md` and others): old names replaced. Descriptions that contradicted the new meaning were rewritten:
  - `camera-scrolling.md`, `nmi-handler.md`: Bg3TilemapVramDma uploads the BG3 tilemap staging buffer (`$7F0200`) to VRAM `$7800`, not sprite tiles.
  - `hardware-and-init.md`: Multiply8x8Unsigned is an unsigned multiply.
  - `game-systems.md`, `scene-and-hardware.md`: PlaceOpenedChestTiles redraws opened chests (not barriers); CopyEventBlockTiles copies source over destination (not a swap).
  - `bank03/text-and-menus.md`: console rows are NewLine = 1 row, DoubleNewLine = 2 rows, shared word, `shared_word_table`.
  - `bank01-data-tables.md`: the sine/cosine mapping rows now describe the tables correctly.
- `gaia-core/docs/patch-development.md`: the RenderScrollRow/DmaHorizontalStrip example lines.
- `gaia-knowledge`: `curated/gaialabs/mode7-vram-analysis.md` and 56 derived copies under `corpus/games/iog/project-docs`.

## 6. Code that referenced the old labels

- Baserom patches: `baserom/scene-load/{MenuBGLoad,TilemapLoad,BitmapLoad}.patch.asm`, `baserom/options-menu/MinimalHudOption.patch.asm`, `baserom/patches/APUWaitFixes.patch.asm`.
- `db-us/transforms.json`: the `item_component_table` key.
- IOGRetranslation: `modules/dungeon-map/dungeon_map_core.asm`, `modules/dungeon-map/VRAM-LAYOUT.md`, `modules/minimap-v2/minimap_v2_core.asm`, `modules/widescreen/Widescreen.patch.asm`, `WidescreenBG3.patch.asm`, `modules/apocalypse-gaia/README.md`.

## 7. Not applied (still in the ledgers)

- Mnemonic renames (`mnemonics.json`) and `copdef.json` operand/opcode names.
- Block renames that change `blocks.json` structure beyond a key.
- Rows that depend on open questions (OQ-63, OQ-67, OQ-68, including ledger rows 89 and 95), row 96 and row 24.
- `FollowChaseDiagQuadrant*` and `ResolveFollowDir*`.
- Proposals that need code changes, and doc-fact-only corrections that involve no name.

## 8. Caveats

- `baserom/**/*.patch.asm` and IOGRetranslation modules are not built by `npm run rebuild`. Rebuild or dist the baserom (IOGRetranslation links it with `file:../../gaia-iog-baserom`) and test them before relying on the edits.
- Patches that reference auto-labels (`loc_02A07D!`, `code_0285F3!`, `loc_00820E`) were updated to the new names.
- The renames were done with sed using a reviewed old→new map, not hand edits. The notes JSON, names files and extracted output were validated afterwards.
- `extracted/` is in line-tracked form (`extract:lt`). Run `npm run extract` if you do not want the `; {address}` annotations committed.
- Not touched: `IOGRXLT/release/base`, GaiaLabs `database.json`.
- `npm run ingest:all` would regenerate the gaia-knowledge corpus copies (optional).

## Suggested commit message (baserom)

```
Apply I001–I020 rename proposals: names, blocks, notes, docs, patches

- Rename ~77 labels/parts/blocks across db-us/names, blocks.json, transforms.json
- Name 15 auto-labels (MainLoop, WaitStoreAndYield, MusicJingle*, ramp_curve_arc_*, ...) with part notes
- Propagate to notes/, docs/, baserom patches
```

Please commit when you're ready (this repo, IOGRetranslation, gaia-knowledge, gaia-core).
