# Rename and doc-correction proposals — sanity check I041–I050

No new rename proposals. Names are not changed in audit iterations, and the sanity pass found no wrong or misleading identifier beyond those already recorded in `I041_renames.md` … `I050_renames.md`.

## Doc / comment corrections found (not applied)

| ID | Where | Statement | Correct reading |
|----|-------|-----------|-----------------|
| D-S4150-1 | `extracted/system/dark_space/sE6_gaia.asm` ~1774, ~1789 (`ORA #$0008`) | "grounded/collision" | Flags10 bit `$0008` is collision-checked movement (see `player_move_controller`, `player_move_main`); the vine, ladder and shimmy states clear it |
| D-S4150-2 | any doc that calls Flags10 `$0008` "grounded" or "airborne frames skip it" | grounded flag | same as above; `player_move_main` was the one instance found in `extracted/` |

Previously recorded and still open: see the "Doc corrections still pending" list in `results/I041-I050_sanity-check.md`.
