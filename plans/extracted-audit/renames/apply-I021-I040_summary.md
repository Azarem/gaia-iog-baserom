# Summary: I021–I040 rename proposals applied to `db-us/names/`, `blocks.json`, notes and docs

Plan: `apply-I021-I040_plan.md`; reviewed map: `apply-I021-I040_map.json` (191 old→new pairs, with the ledger row of each). Frozen ledgers (`results/`, `renames/I0*_renames.md`, `questions/`, `edits/I0*.json`) and `artifacts/` were not edited by hand.

## Result

| Check | Result |
|---|---|
| `npm run extract:lt` | OK; none of the old names is left anywhere in `extracted/`; every new name appears |
| `npm run rebuild` | OK; `artifacts/crc.json` = checksum 223006080 / crc 2083230829 / totalSize 3062204 (unchanged, names do not change bytes) |
| `npm run ingest:dry` | Only the known baseline: `MenuSelectionHandler` transform artifacts and the two bank-key quirks (`ActorMidpointCalc` in bank0B, `oneshot_palette15_grey_fade_in_1F` in bank09) |
| `npm run merge -- edits/rename-pass-I021-I040.json` | OK (63 new part notes); the 4 `MenuSelection_*` notes were added to `notes/partNotes/bank03.json` directly because `merge` rejects `MenuSelectionHandler` (transform artifact, OQ-59) |

Every new name was checked as unused in `db-us`, `extracted`, `baserom` and the IOGRetranslation modules.

## 1. Applied renames (names files, `blocks.json`, `transforms.json`)

| Ledger rows | Change |
|---|---|
| R-I021-1, -2, -4, -5 | `DecompressGfxToVram`→`CopyPaletteBundleFrame`; `LzReadBackRef`→`LzReadNibble`; `RunThinkers_TypeA/B/C/D`→`RunThinkers_General/Hdma/General_Light/Hdma_Light`; `SpcCheckMusicReady`→`SpcFadeOutHandshake` |
| R-I022-1, -4 | `EnableNmiOnly`→`DisableNmiKeepJoypad`; six `SpcBlockTransfer` / `SpcIplHandshake` labels (`SpcNextChunkIndex`, `SpcFindChunk`, `SpcSendChunkData`, `SpcChunkDone`, `SpcSendHeader`, `SpcSendRecord`) |
| R-I023-1, -2 | block `stair_climb`→`slider_glide`; the five triggers and four glide routines renamed with the direction rotation applied in one pass (old South→West, North→East, West→North, East→South; `WestEntry/Main/Offset`→`NorthEntry/Main/Offset`; `ClimbSouth/North/West/East`→`SliderGlideWest/East/North/South`); `CheckMoveState`→`IsPlayerSliderSpriteBank` |
| R-I024-4 | four `MenuSelectionHandler` labels (`MenuSelection_Up`, `_Confirm`, `_Return`, `_UpWrap`) |
| R-I025-3, -4 | `NullActorScriptStub`→`NpcDespawnStub`; `DisableStatusForAttack`/`RestoreStatusDisplay`→`FreezeCameraForAttack`/`UnfreezeCameraAfterAttack` |
| R-I026-1, -2, -3 | `ToggleActorVisibilityFlag`→`FlickerParentActor`; seven `item_use_system` labels (Inca mantel / statue mismatch messages, flute configure / playback / restore / exit). `transforms.json` item_use_system replacement values updated to the new label names (`BEQ UseItem_IncaStatueA_Mismatch` etc.) |
| R-I027-1, -2 | `DarkFriarTrailSouthInit`→`DarkFriarTrailNorthInit`; thinkers `oneshot_palette_flash_40`→`oneshot_backdrop_fade_out_fast_40`, `_1F`→`oneshot_palette15_grey_fade_in_1F` (+ labels) |
| R-I028-1..4 | `item_table_separator`→`non_discardable_item_bits`; `StatusCharRow3/2/1`→`StatusAbilityRow0/1/2`; eight inventory loop/retry labels; thinkers `_1B`→`oneshot_backdrop_fade_in_1B`, `_1C`→`oneshot_backdrop_fade_out_1C` (+ labels) |
| R-I029-1, -2, -3 | `DiagRampUpLeft/DownRight/EdgeUL/EdgeDR`→`WestRampDescend/Ascend/EdgeDescend/EdgeAscend`; block `player_move_diag`→`player_move_west`, `DispatchDiagDownLeft`→`DispatchWestMove`, `SnapXDiagCollision`→`SnapXWestCollision`, `ComputeDiagSnapOffset`→`ComputeWallSlidePush`; `DiagPushLeft/Right`→`WallSlidePushUp/Down`, `DiagClearReturnFlags`→`CancelVerticalPhase`, `DiagAutoAlignNS`→`AutoAlignYToGrid` |
| R-I031-1, -3 | block `hdma_gradient_thinker`→`hdma_circle_window_thinker` with its thinkers, parts and two row labels; `code_00BE1A`→`SineWaveInit` |
| R-I032-1 (3 of 4), -3 | `SlopeSpeedZeroLatch`, `SlopeHandlerExit`, `DecelResetCounterEW`; `StopPlayerOnDeathAssign`→`StopPlayerOnDeath` |
| R-I034-1, -2 | `DrainActorQueue`→`ResetThinkerWaitCounters`; `oneshot_coldata_green_tint`→`oneshot_coldata_r11g4b2` |
| R-I035-1, -2, -3, -5, -6, -7 | `parallax_thinker`→`scanline_band_hdma_thinker`; `ParallaxResolveEntryStride`, `hdma_entry_stride_by_mode`; six `Parallax*` band routines; four auto labels; `inventory_dma_setup`→`inventory_bg3_scroll_hdma` (+ `InventoryBg3HdmaEntry`, `inventory_bg3vofs_table`); 22 `parallax_type_NN` data labels |
| R-I036-1, -2, -3, -5 | ramp labels (`RampPlayerClimbWest/North`, `RampClimbNorthStep/SouthStep`, `RampArcDriver` replaces both `func_00D5C0` and `RampApplyMotionCurve`, `Ramp<Dir>Watch/Armed/Launch`) |
| R-I037-2 | the whole direction family in `push_handler_solid`, `push_handler_forceball` and `collect_handler_gem` (Move/Align, Dist/Nudge, Restore labels) renamed by where the player stands (…PlayerNorth = old West, …PlayerSouth = old East, …PlayerWest = old North, …PlayerEast = old South). The ledger named only the Move/Align labels; the Dist/Nudge/Restore labels of the same direction cases were renamed with them so the families stay consistent |
| R-I038-2 | `code_02D92F/D937/DA7A/DA82`→`RampSnap{East,West}{South,North}{Br,Tr}Wall` |
| R-I039-1, R-I040-1, -2 | `InitPlayerScriptVariant`→`SetPlayerIdleFacing`; `LargeRampBoostNorthSouth`→`LargeRampIdleHold`; `EastWallNorthHandler/SouthHandler`→`EastWallPushDown/Up` |
| R-SAN2-1 | `ProbeLeftTiles`→`FindSlopeForEastMove`, `ProbeRightTiles`→`FindSlopeForWestMove` (the ledger left the name open; the caller-based names follow R-I029-2) |

## 2. Not applied

- Mnemonics and `copdef.json` rows (R-I021-3/7, R-I022-2/3, R-I023-3/4/5/6, R-I024-1/2/5, R-I025-1/6, R-I035-4, R-I036-4): out of scope for this pass.
- Structural rows: R-I024-3 (move two parts out of `system_init`), R-I024-6 (anchor the `MenuSelectionHandler` transforms), R-I032-2 (delete `ReadDecelerationStepNS`), R-I029-4 (optional cosmetic thinker rename).
- Gated on open questions, left unchanged: R-I025-2 (lunge, OQ-I025-5), R-I030-1/2, R-I032-1 (`loc_02B76C`), R-I033-1/2/3, R-I034-3, R-I036-6, R-I037-1/3/4, R-I038-1/3, R-I039-2/3.
- Mesen2 runtime check was attempted for the gated rows and did **not** produce evidence: the available save state (`rebuilt/ws-test-south-cape.mss`) was made with a different ROM build (the CPU state does not match the rebuilt ROM: frame counter frozen, no input response), the relocated rebuilt code needs mapped addresses for exec hooks, a cold boot needs the full title/intro sequence, and the MCP server then dropped into an error state. R-I029-1/3 and R-I040-2 (push and ramp directions) therefore rest on the static evidence of I029 and I040 (E1, two independent iterations agree) and should be confirmed at runtime when a matching save state exists.

## 3. Notes and comments

- `notes/{blockNotes,partNotes,comments}/bank*.json`: keys re-keyed and text updated by the same old→new map (also after `\n` escapes inside the JSON strings).
- Sentences that said a name was wrong ("the name is misleading", "Despite the name", "Rename proposal: R-…", "(R-I0xx-n)" references, "the name is swapped") removed or rewritten for the new names (about 45 edits, e.g. `DisableNmiKeepJoypad`, `ResetThinkerWaitCounters`, `WestRampDescend/Ascend`, `RampClimbNorthStep/SouthStep`, `HdmaEmitHoldSegments`, `LargeRampIdleHold`, `oneshot_coldata_r11g4b2`, `slider_glide` block note).
- `slider_glide` notes and comments re-aligned with the corrected trigger directions (axis words, "normal North check", "South trigger").
- Main-loop prose "type-A/B/C/D thinkers" → "general / HDMA-phase / light general / light HDMA-phase thinkers" to match `RunThinkers_*`.
- Doc-fact corrections that live in notes: `player_move_main` ("diagonal down-left" → west dispatch; the nudge is 8 sub-pixels and snaps to a 16-pixel line, not "64 px"), `NudgeToLowerGrid/UpperGrid`, `SystemInit` MEMSEL boot note and comment 32807, `dm3F_laborer` `$0E` wording.
- 67 new part notes (63 via `edits/rename-pass-I021-I040.json`, 4 `MenuSelection_*` directly).

## 4. Documentation

- `docs/**`: names replaced (about 430 lines in `docs/code`), plus semantic rewrites by ledger row in about 60 files: palette bundles (uncompressed strips, not decompressed), `DisableNmiKeepJoypad`, movement indices, the Psycho Slider glide (`docs/code/bank00/stair-climb-system.md` rewritten for the corrected directions), `$040C` run window, camera shake, lunge vs projectile, `NpcDespawnStub`, backdrop fades, `StatusAbilityRow*`, the west horizontal phase (`player_move_west`) and ramp directions, wall-slide push directions, `scene_flag_init` (26 placements, flag set), `SetPlayerGameOverFlag` wording, `$0200 deathFlag` removal, thinker/inventory-overlay save map, jump-launcher ramps, push/pull handler details (L/R button), `COP [QueueDma]` example (`inventory_bg3vofs_table`, #12).
- `gaia-core/docs/patch-development.md`: renamed labels in examples.
- gaia-knowledge: `corpus/games/*`, `curated/*`, `corpus/retranslation/*` copies had old names replaced (the semantic fixes in `docs/` are not in those copies; `npm run ingest:all` in gaia-knowledge would refresh them).

## 5. Code that referenced the old labels

- Baserom patches: `baserom/collectible-system/*`, `baserom/options-menu/*`, `baserom/scene-load/*`, `baserom/inventory/*`, `baserom/patches/*`, `baserom/player-input/MergeInputFlags.patch.asm`.
- IOGRetranslation: `modules/widescreen`, `modules/minimap-v2`, `modules/dungeon-map`, `modules/debug-menu`, `modules/jp-*`, `modules/title-*`.

## 6. Caveats

- `baserom/**/*.patch.asm` and IOGRetranslation modules are not built by `npm run rebuild`; rebuild/dist the baserom and test them before relying on the edits.
- Not touched: `db-jp/` (the JP database still has its own `parallax_thinker` block key), GaiaLabs legacy patches and `.godot` / `bin` outputs, IOGRetranslation `site/public/data/rom-package.json` (generated, git-ignored), `copdef.json`, `mnemonics.json`.
- `extracted/` is in line-tracked form (`extract:lt`); run `npm run extract` if you do not want the `; {address}` annotations committed.
- One `npm run ingest:verbose` call (which is a real ingest, not a dry run) was run by mistake while checking; it only rewrote the baseline items listed above, and those were restored (the two spurious bank-key blocks removed, the four `MenuSelectionHandler` transform artifacts reverted). `ingest:dry` shows the same baseline as before.

## Suggested commit message (baserom)

```
Apply I021–I040 rename proposals: names, blocks, notes, docs, patches

- Rename ~120 labels/parts/blocks (slider_glide, player_move_west, hdma_circle_window_thinker, DisableNmiKeepJoypad, ...)
- Name 67 auto-labels with part notes; fix the item_use_system transform targets
- Propagate to notes/, docs/, baserom patches; semantic doc corrections from the ledgers
```

Please commit when you're ready (this repo, IOGRetranslation, gaia-knowledge, gaia-core).
