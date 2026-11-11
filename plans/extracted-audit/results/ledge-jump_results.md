# Ledge jump / ladder / wall-shimmy: results

Supersedes `climb-terms_results.md`, whose verdict ("vine is a real, separate mechanic") was wrong. Specs: `renames/apply-climb-terms_names.json`, `renames/apply-climb-terms2_names.json`, `renames/apply-ledge-jump_names.json`, `renames/apply-glide-ledge2_names.json`, `edits/climb-terms.json` (first pass, partly superseded), `edits/ledge-jump.json`, `edits/glide-ledge2.json`, `edits/glide-ledge3.json`.

## Verdict

| Collision type | What it is | Entry code |
|---|---|---|
| `$02` | Ladder | `NorthLadderTile` / `SouthLadderTile` -> `LadderClimbSouth` / `LadderClimbNorth` |
| `$07` | Wall shimmy (moving west / east) | `WestShimmyTile` / `EastShimmyTile` -> `ShimmyLeftEntry` / `ShimmyRightEntry` |
| `$08` | **Ledge jump**: a gap in a ledge edge, entered only walking south; the player steps off and falls | `SouthLedgeTile` -> `LedgeJumpEntry` |

There are no vines and no "special climb" state in the player code. The audit's `SpecialClimb*` names were not applied. The Mt. Temple vine text (Mushroom Drop, `map_kress_vines`, "Broken Vines", "Vine Maze", the walkthrough) is genuine and untouched.

## Evidence

Mesen2, scene `$01` (South Cape), walking south onto a `$08` cell: entry `C633` -> `C652` -> `C68C` -> `C699` -> idle `C4C8`; animation `$18` -> `$1A` -> `$19` -> `$1C`; y 361 -> 448 (about 87 px); `playerFlags` `$0808`; actor flags `$8700`. The screenshots show the player stepping off a mossy wall edge and dropping to a roof. Probe: `temp/climb_probe.py`, output `mesen2-results/raw/CT_probe.json`.

## Second pass: names that were still wrong

| Old | New | Why |
|---|---|---|
| `pyD0_breakable_wall` (block) | `pyD0_ledge_jump_trigger` | Mesen2, scene `$D0` ("Meltdown A"): with the player next to the actor and animation index `$1C` poked, the actor first draws metatiles `#E8` / `#E9` at (38, 20) and (39, 20) (collision `$00` -> `$0E`, solid); after the player leaves the near zone and lands again it applies BG change `#70` (55 tilemap words changed), and the player's entry word becomes `LedgeJumpEntry` (animation `$18`, actor flags `$8700`), a fall. No HP, no hit test, no debris. Probes: `temp/pyd0_probe.py`, `temp/bgdiff_probe.py`; screenshots `raw/screenshots/PY_sD0_*` |
| `awB2_stair_climb` (block) | `awB2_slider_glide_trigger` | Code: waits for flag `$016B`, sets `$0E = $0A`, `JumpFar` to `SliderGlideTriggerNorthMain` |
| `LockPlayerForClimb` / `UnlockPlayerAfterClimb` | `LockPlayerForGlide` / `UnlockPlayerAfterGlide` | Called only by the Psycho Slider glide triggers / `SliderGlide*` routines |
| mnemonic `$09E0` `climbStateData` | `abilityDamageBonus` | Damage byte: `LoadAbilityDamageA` (Will's table) and the lunge's 1; `docs/ram_map.txt` calls it "Current attack damage bonus" |
| mnemonic `$09E2` `climbStateData+2` | `rangedDamageBonus` | Freedan's table byte (`LoadAbilityDamageB`); `combat_collision` adds it only when the hitter is not slot `$1000`; `docs/ram_map.txt`: "Additional ranged attack damage bonus" |
| doc `stair-climb-system.md` | `slider-glide-system.md` | The doc was already titled "Psycho Slider Glide System"; links in `bank00/README.md`, `code/README.md`, `ramp-launchers.md`, `camera-scroll-system.md` updated |

The mnemonic rename was a direct edit of `db-us/mnemonics.json` (the `names` tool only handles ROM labels), then `extract:lt`; the note and doc mentions went through `merge` and hand edits. ROM unchanged after every step (SHA-1 `2e4a88a3de6dd4bdefc23c0dd626b953c18fe808`).

Kept on purpose: `ec0A_stair_guard` / `ec0A_stair_maid` (real staircase NPCs), `stair-warp` (a real warp-list type), the "stair" wording for ramp geometry in `player-movement.md`, `RampPlayerClimb*` and `WarpClimbAnim` (not checked, not claimed wrong).

## Notes, comments and docs

`edits/ledge-jump.json` rewrote the notes and comments in `player_character`, `player_move_controller`, `player_move_main`, `player_move_ns`, `player_move_south`, `tile_collision`, `sE6_gaia`, `actor_execution`, `awB3_ledge_jump_trigger`, `pyD0_breakable_wall` and the spriteset blocks. `edits/glide-ledge2.json` did the mnemonic / glide / pyD0 rewrite. Two orphaned comment keys (181804 and 184148, no instruction at those addresses) were removed.

## Open questions

- Only South Cape `$01` was watched for `$08`. The other 58 scenes with `$08` are assumed to be ledges.
- `pyD0_ledge_jump_trigger`: only the forced sequence was tested (animation index poked). How the player reaches the gate in normal play, what `#E8` / `#E9` look like, and what BG change `#70` / `#71` draws were not watched.
- awB3 (`awB3_ledge_jump_trigger`): in Mesen2 stepping into the tile box starts the ledge jump within 10 frames; BG change `#6E` changed no cell of the collision map or layer-0 tilemap, so what it draws is unknown, and the jump's end position (x 1400, y 112) was not traced.
- Whether pose `$1C` has other sources that can open the pyD0 gate.
- `npm run names -- --check` reports 12 other bank files as unsorted; unrelated to this work.
