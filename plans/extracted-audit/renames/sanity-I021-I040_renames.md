# Rename proposals from the I021–I040 sanity check (not applied)

Earlier sanity proposals: [sanity-I001-I020_renames.md](sanity-I001-I020_renames.md) (`R-SAN-`). IDs here use the prefix `R-SAN2-`. Per-iteration rows are in `I0nn_renames.md`.

| ID | Target (current) | Proposal | Reason / evidence | Blast radius |
|----|------------------|----------|-------------------|--------------|
| R-SAN2-1 | `ProbeLeftTiles` / `ProbeRightTiles` (`map_coords`, tags 176571 / 176488) | `FindSlopeForEastMove` / `FindSlopeForDiagDownLeft` (or any name that states the caller; to be decided together with the east/west dispatcher renames of R-I040-2) | E1: `ProbeLeftTiles` is called only by `DispatchEastMove`, `ProbeRightTiles` only by `DispatchDiagDownLeft`; both borrow the `tile_collision` probes and sample the centre column or one half tile offset, so "Left" and "Right" describe neither the movement direction nor the sample side. The wrong "(left/right movement)" inline comments are already fixed by `sanity-I021-I040.json` | `names/bank02.json` (2 entries), call sites in `player_move_east` and `player_move_diag`, notes that cite the names (`player_move_east`, `player_move_ramps`, `map_coords`), `docs/` mentions |

Corrections that need no rename (done in `sanity-I021-I040.json`, listed for traceability):

- R-I039-4 item 5 (`ProbeLeftTiles` / `ProbeRightTiles` inline "left movement" / "right movement" comments): DONE; the same item's wording "used by both horizontal dispatchers" is superseded by the one-caller-each fact above.
- Doc-only follow-ups for files that later iterations will audit (not edited here, see the sanity results, "Observations"): the `system_core` block note item 3 and the `STA $MEMSEL` comment (boot leaves SlowROM until `sFB_boot_logo`), the `dm3F_laborer` line-3 `displayModeFlags ($0E)` (that is the actor DP field), and the `player_move_main` {184936} carry wording.
