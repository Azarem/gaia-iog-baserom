# B2 single-tile sweep: what the player does on one painted collision tile (harness proof run)

ROM: O and R (main file, plain build)

| Tag | File | Size | SHA-1 | CRC-32 | Mode source |
|-----|------|-----:|-------|--------|-------------|
| O | `rebuilt/Illusion of Gaia.smc` | 2,097,152 | `38de0c84dd2bc3bdfc0a3d7ab0220c79b70887c3` | `1c3848c0` | vanilla ROM |
| R-plain | `rebuilt/Illusion of Gaia - Rebuilt.smc` | 3,080,192 | `795c7a8cb8924766d5c378ac1d92364d127e1d2a` | `c426ee65` | `artifacts/crc.json` = `{checksum 222967024, crc -1004081563, totalSize 3062189}`, written at the same time (16:32:01 on 2026-10-29) as the ROM; `extracted/` has no `; {n}` tags. The 3,062,189 total is the plain size of plan 2.1. |

The R file is older than later edits of `extracted/` (for example `tile_collision_physics.asm`, 16:41); this result describes the file as built, which is what the SHA-1 identifies.

State: `rebuilt/states/orig_S01r_south-cape-ready.mss` and `rebuilt/states/R-plain_S01r_south-cape-ready.mss` (each with a `.json` sidecar holding the ROM SHA-1; valid: yes, `load_state_file` accepted it on its own ROM and raised `rom_mismatch` for the other one). Made by: quick warp (`sceneNext $0642 = 1` at frame 100 from the boot logo), 240 frames, banner `$B4` dismissed with A pulses, 30 frames of settling. Scene `$01`, player at (664, 752), HP full, Will, no flags written.

Static prelude:
- The collision layer is WRAM `0x1C000` (`$7F:C000`), 256-byte pages of 16 x 16 cells (a cell is 16 x 16 pixels). Index = `(((ty>>4)*stride + (tx>>4)) << 8) | ((ty&15)<<4) | (tx&15)` with `stride = $0693` (3 in South Cape, a 48 x 64 cell grid). The earlier plan formula `0x1C000 + row*stride + col` was wrong; B1/B2 in the plan now use the paged form. Low nibble = type; a nonzero high nibble is a block mark read first.
- Static reading of the push direction: `player_move_east.asm:26` (`$09` pushes south, `$06` pushes north). Note in OQ-I040-4: "TR `$09` pushes down, BR `$06` pushes up, 2 px per call".
- `CheckActorOnSpecialTile` (`tile_collision_physics.asm`, about line 992) is called by the `TileCollision_Move*` routines of ordinary actors. The player has its own controller (`player_move_*.asm`), so this run does **not** exercise that routine; it exercises the player path only.

Script: `harness/scenario_b2_special_tiles.py` driving `kit/lib/gaia_kit.lua` (`gaia.trial`). Per case the harness injects a `CASE` table; the trial (a) clears a 6 x 4 cell area around the test tile `T` to `$00`, (b) writes the test type into `T` (column 24; row -1, 0 or +1 relative to the player's row), (c) places the player at (344, 176) = cell (21, 10), speeds zeroed, (d) holds `right` for 40 frames, (e) samples `posX $1014`, `posY $1016`, `speedEw $09B2`, `speedNs $09B4`, flags `$1010` each frame. Each case ran twice per ROM and the harness aborted on any difference between the two runs.

Positive control:
- Control case (no painted tile): dx +80, dy 0 (2 px per frame for 40 frames).
- Type `$0F` on the player's row: x stalls at 376 from frame 16 (dx +32, flag `$1010` bit 2 set), so a painted solid tile is seen by the player. Same type one row above or below: dx +80 (no effect).
- Determinism: both runs of every case identical on each ROM; the per-frame samples are identical between O and R.

Coverage: scene `$01` only, Will only, one approach (east, 2 px per frame), cell (24, 10) only, 40-frame trials, no dynamic (high-nibble) marks, the actor routine `CheckActorOnSpecialTile` not exercised.

Observations (dx, dy over 40 frames from (344, 176); `yDev` = first frame where y changes):

| Painted type, row relative to the player | dx | dy | Notes |
|------|---:|---:|-------|
| none (control) | +80 | 0 | |
| `$0F` row 0 | +32 | 0 | stalls at x = 376 from frame 16 |
| `$06` row 0 | +80 | -16 | from frame 16: y falls 2 px per frame for 8 frames (north), then stops |
| `$09` row 0 | +80 | +16 | from frame 16: y increases 2 px per frame for 8 frames (south), then stops |
| `$06` / `$09` row -1 or +1 | +80 | 0 | no effect |
| `$05` row 0 | +52 | -10 | slope wobble, y deviates from frame 20 |
| `$05` row +1 | +80 | -2 | |
| `$0A` row 0 | +76 | +16 | |
| `$0A` row +1 | +74 | +16 | |
| `$0F` / `$05` / `$0A` row -1 | +80 | 0 | no effect |

Identical on O and R-plain (all 16 cases, all samples). Raw: `raw/B2_special_tiles_O_20261029.json`, `raw/B2_special_tiles_R-plain_20261029.json` (per-frame samples).

A second observation from the same session (`compare_runs`, O against R-plain, same 90-frame input from the same South Cape state): positions and `$1010` stayed identical for 90 frames; `displayModeFlags $09EC` was `$0008` on O and `$0000` on R at frame 51 and the reverse at frame 52 (a one-frame timing shift of bit 3 during the `B` press). Not investigated; recorded for the M/C campaigns (button remap).

Verdicts:

| ID | Verdict | Grade | Note shipped today | Action |
|----|---------|-------|--------------------|--------|
| OQ-I040-4 (magnitude half) | A player entering a painted `$06` tile on its own row is moved 16 px north at 2 px per frame for 8 frames; a `$09` tile moves it 16 px south, same rate. The static direction reading is confirmed. The tile must be on the player's row: one row above or below has no effect. | VERIFIED-RUNTIME (single tile, east approach, Will, scene `$01`) | OQ-I040-4 text (2 px per call) | none until the closure step: the 16 px / 8 call total can be stated as "measured" |
| OQ-SAN2-2 | Same as OQ-I040-4 (duplicate group); same verdict. | VERIFIED-RUNTIME | - | same |
| OQ-16, OQ-I029-5, OQ-I033-4 | Behaviour of a **single** `$06` or `$09` tile under the player is now known. The question's pattern (paired `$06` at (x, y) and (x+1, y+1), or the `$09` L shape) belongs to `CheckActorOnSpecialTile`, which the player does not call. | INCONCLUSIVE | - | needs a non-player actor with actor flag `$0008` on the painted pattern (next B2 session) |
| OQ-I040-4 (direction half) | Already answered statically; runtime agrees. | VERIFIED-RUNTIME | `player_move_east.asm:26` | none |

Tool issues: see `tool-issues.md` (T-01 to T-09 of 2026-10-29). Re-run on server 0.5.0 (2026-10-30): all 16 cases and per-frame samples are bit-identical to the 0.4.0 data on both ROMs.

New questions: (1) `$05` on row +1 changes y by -2 and `$0A` on row +1 changes x by -6 and y by +16 although the player stands on row 0. Hypothesis, not tested: the lower hitbox edge overlaps row +1 at y = 176. (2) Why does the `displayModeFlags` bit 3 shift by one frame between O and R on a `B` press? (3) Which actor class calls `CheckActorOnSpecialTile` in South Cape (needed to run the pair patterns)?
