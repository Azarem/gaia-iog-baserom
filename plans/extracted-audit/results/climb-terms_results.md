# climb-terms: ladder / wall shimmy / vine terminology audit

Input: a second agent's audit of vine, climbing and shimmy wording. Each claim was checked against the extracted asm, the notes and the B1 collision census (`mesen2-results/raw/B1_census_merged.json`, scene names from `artifacts/scenes.json`). Applied with `renames/apply-climb-terms_names.json`, `renames/apply-climb-terms2_names.json` and `edits/climb-terms.json`.

Gate: `npm run extract:lt` then `npm run rebuild` before and after; SHA-1 `2e4a88a3de6dd4bdefc23c0dd626b953c18fe808`, CRC `-524441819`, totalSize `3062193` (tagged), unchanged.

## What the code says

| Collision type | Mechanic | Entered by | Scenes (census) |
|----------------|----------|------------|-----------------|
| `$02` | Ladder | `NorthLadderTile` / `SouthLadderTile` (north / south, hitbox over one column) -> `LadderClimbSouth` / `LadderClimbNorth` | Great Wall, Gold Ship, Watermia, Angel Village, Incan Ruins, Freejia, Euro, Sky Garden |
| `$07` | Wall shimmy | `WestShimmyTile` / `EastShimmyTile` (west / east, Y flush) -> `ShimmyLeftEntry` / `ShimmyRightEntry` | Sky Garden, Babel Tower, Angel Village |
| `$08` | Vine descent | `SouthVineTile` (south only; the north handler treats it as a wall) -> `ClimbVineEntry` | 59 scenes: Angkor Wat, Pyramid, Sky Garden, Great Wall, Freejia, Gold Ship, Incan Ruins, South Cape, Edward's Castle, Itory, ... Not Mt. Temple |

`ClimbVineEntry` is also entered by two scene scripts that write its address into the player actor: `awB3_vine_reveal` (Angkor Wat outer north) and `pyD0_breakable_wall` (Pyramid `$D0`, `$D1`).

## Verdicts on the audit's findings

| # | Claim | Verdict | Action |
|---|-------|---------|--------|
| 1 | `ClimbVine*` / "vine climbing" is a scripted state, not a vine tile; rename to `SpecialClimb*` | **Half true, rejected as a rename.** `$08` is a real collision type with its own entry rule (`SouthVineTile`), in 59 scenes. The state is also entered by two scripts, which is why the notes now say it is a state *and* a tile family. | Names kept. Notes say so (`ClimbVineEntry` part note, `SouthVineTile` part note). **Correction the audit missed:** the notes called the state "Freedan-only"; nothing gates the entry by form and Will / Shadow have the vine animations. Only the drop attack is Freedan-only. Fixed. |
| 2 | `awB3_vine_reveal` creates no vine; rename the file | **Partly true.** The old header ("grows vines", "draw the vine tiles") was a guess; BG change #6E was never decoded. The actor does open a map change and put the player into the vine state. | Block name kept (no evidence the art is not a vine). Block note rewritten from the code, with the guess flagged. |
| 3 | `tile_collision`: `$08` is only a label, "$07 ladder/shimmy" | **The real error is different.** The extracted `tile_collision` block note called `$07` a ladder. `$07` is the wall-shimmy tile. The doc line quoted by the audit (`$02` ladder, `$07` shimmy, `$08` vine) was already right. | Block note, `docs/code/bank02/tile-collision.md` and `docs/wram-memory-map.md` §4.10 fixed. |
| 4 | West / East files call `$07` a ladder | **True**, and worse in the labels: `DiagLadderTile` and `EastLadderTile` only ever redirect to `ShimmyLeftEntry` / `ShimmyRightEntry`. | Renamed `WestShimmyTile`, `EastShimmyTile`; comments and notes fixed. |
| 5 | Rename the `*_vine_enter` / `*_vine_climb_N` animation names to `climb_*` | **Rejected.** They are the animations of `ClimbVineEntry`; the state is vine-named for the reasons above. The appearance of the frames was not viewed (OQ-CT-1). | None. |
| 6 | `player_sprite.md`: "vine climb entry" is misleading | **Rejected.** `ClimbVineEntry` is exactly that, and "ladder landings" is correct too (`LadderLandBottom` / `LadderReachTop` use `StagePlayerMoveY`). | Doc example now labels the vine entry, vine landing and a ladder landing separately. |
| 7 | Walkthrough text ("vine bridge", "vine was regrown") is false | **Rejected.** It is a third-party walkthrough describing Mt. Temple, where the Mushroom Drop extends broken vine bridges. The census shows Mt. Temple (`$A0`-`$A9`) holds no `$02`, `$07` or `$08` cell, so those bridges are not the `$08` mechanic, but the text is not wrong. | None (not our text). The `SouthVineTile` note records the Mt. Temple fact. |
| 8 | "stair/ladder/vine climbs" lumps unlike things | **True** for `wram-memory-map.md` (the `$0800` row). `docs/code/bank00/stair-climb-system.md` has no "vine" wording. | Row reworded: ladder, wall-shimmy and vine states plus the slider-glide triggers. |

## Findings the audit did not make

| Item | Fix |
|------|-----|
| `wram-memory-map.md` collision table: `$02` "Interactive tile", `$07` "Ladder / climbable", `$08` "Stairs" | Rewritten as ladder / wall-shimmy / vine with entry rules and scenes. |
| `SouthStairsTile` handled `$08` (vine), not stairs | Renamed `SouthVineTile`. |
| `SouthInteractTile` / `NorthInteractTile` handled `$02` (ladder) | Renamed `SouthLadderTile` / `NorthLadderTile`. |
| `DiagWallSouthFromDL` / `DiagWallNorthFromDL`: "DL" was the old `DiagLadderTile`; they are wall-handler entry shims | Renamed `DiagWallSouthShim` / `DiagWallNorthShim`. |
| `pyD0_breakable_wall` block note claimed hit points, debris and "used extensively"; the code has none of these and only scenes `$D0` / `$D1` place it | Block note rewritten from the code. |
| `docs/code/bank08-native-dao-pyramid-actors.md` called `ClimbVineEntry` "ladder climbing" for both scripts | Reworded to the vine descent state. |

## Renames (names tool)

| Row | Address | Old | New |
|-----|---------|-----|-----|
| CT-1 | 187436 | `DiagLadderTile` | `WestShimmyTile` |
| CT-2 | 186236 | `EastLadderTile` | `EastShimmyTile` |
| CT-3 | 187465 | `DiagWallSouthFromDL` | `DiagWallSouthShim` |
| CT-4 | 185381 | `SouthStairsTile` | `SouthVineTile` |
| CT-5 | 185355 | `SouthInteractTile` | `SouthLadderTile` |
| CT-6 | 184532 | `NorthInteractTile` | `NorthLadderTile` |
| CT-7 | 187549 | `DiagWallNorthFromDL` | `DiagWallNorthShim` |

## Open questions

- **OQ-CT-1.** What do the frames of animations `$18`-`$1B` and the `$08` cells actually look like (vine, rope, ledge)? Only the names say vine. Method: screenshot a `$08` cell in South Cape (`$01`) and Angkor Wat (`$B1`) while the player descends.
- **OQ-CT-2.** What does BG change #6E (`awB3_vine_reveal`) draw, and is the descent that follows on the revealed path?
- **OQ-CT-3.** What do the `$7F0008` byte values `$95` / `$8E` and animation `$1C` gate in `pyD0_breakable_wall` mean?

## Notes

- `npm run names -- --check` reports 17 other bank files as "not sorted / formatted like the tool writes it" (files this change does not touch); `bank02.json` passes. Not addressed here.
- The gaia-knowledge corpus copies still hold the old names until `npm run ingest:all` runs there.

Suggested commit message: `Rename ladder / wall-shimmy / vine tile handlers and correct their notes and docs`
