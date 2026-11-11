# I039 rename and documentation proposals

Proposals only. Nothing here has been applied; renames need an explicit go-ahead because names live in `db-us/names/bankNN.json`, `us/blocks.json` and many `.asm` files, and the notes in `plans/extracted-audit` cite them by label.

| # | Iter | Target | Address | Proposal | Reason / evidence | Blast radius |
|---|------|--------|---------|----------|-------------------|--------------|
| R-I039-1 | I039 | `InitPlayerScriptVariant` | $00C6E4 (50916) | `SetPlayerIdleFacing` | The routine takes a direction in A (0..3), zeroes the wait counter `$0008`, writes `$7F002C` / `$7F002E` and jumps to one of four `IdleStand*` handlers; nothing about it is a "script variant" (`player_move_ns`, `GetPlayerFacingDirection` and the callers confirm the index is a facing) | 15 files in `extracted/` (17 `JSL` sites in 14 actor files), 8 doc files, `db-us/blocks.json`, `db-us/names/bank00.json` |
| R-I039-2 | I039 | `NorthProbeRedirect` | Bank 02 (`player_move_ns`) | `NorthWallGapRetry` | It only re-enters the gap chain for the `$09` / `$06` redirect probes (its `MapCellDown` + `ReadCollisionNibble` pair is dead, OQ-I039-4); "probe redirect" suggests a probe is redirected. Apply after OQ-I039-4 is decided | 1 file in `extracted/`, 1 doc file, `db-us/names/bank02.json` |
| R-I039-3 | I039 | `NorthSlopeRight` / `NorthSlopeLeft` | Bank 02 (`player_move_ns`) | `NorthSlope03` / `NorthSlope0C` | The diagonal direction of types `$03` / `$0C` is not decoded (OQ-I033-3), so a direction in the name is a guess; the tile type is a fact. Consistent with R-I038-1. Apply together with the south-side equivalents | Two labels in `player_move_ns` and their callers in the dispatcher; `db-us/names/bank02.json`; docs section headers |
| R-I039-4 | I039 | Documentation / comment corrections (no rename) | several | See list below | Found while auditing the three files | Doc text only, except item 1 which is a `player_move_main` block-note edit |

Corrections for R-I039-4 (to apply in a later iteration that touches those files):

1. `player_move_main` block / part note for `ComputeYSnapOffset`: the header says the result is 0 when Y is flush; the code returns 16 (the range is 1..16).
2. `docs/code/bank00/functions-camera-motion.md` `SpawnDebrisBurst` section (line 128): the code is a COP `LoopStart` / `LoopEnd` script, not a `LDX #8` loop; offsets are -16..+15 px, not +-$10..+-$30; add the 4-frame wait per particle and the two-channel sound `#$0F`; the callers are four, not two.
3. `docs/code/bank00/data-tables-memory.md` line 105: `InitPlayerScriptVariant` does not select "based on body form and scene context"; only A is used.
4. `docs/code/bank02/player-movement.md`: `DispatchNorthMove` step 4 ("sub-tile X check") describes the straddling case; `NorthWallHandler` (line 366) says the player slides east, and `SouthWallHandler` (line 335) west; the code slides west and east respectively (`FineAdjustXEast` moves X west). `NorthSlopeLeft` says "adjusts `$24` for partial movement" without the replace-not-subtract filter.
5. `map_coords` `ProbeLeftTiles` / `ProbeRightTiles` inline "left movement" comments: the routine is the centre-column slope search used by both horizontal dispatchers.
