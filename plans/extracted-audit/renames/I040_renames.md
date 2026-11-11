# I040 rename and documentation proposals

Proposals only. Nothing here has been applied; renames need an explicit go-ahead because names live in `db-us/names/bankNN.json`, `us/blocks.json` and `.asm` files, and the notes in `plans/extracted-audit` cite them by label.

| # | Iter | Target | Address | Proposal | Reason / evidence | Blast radius |
|---|------|--------|---------|----------|-------------------|--------------|
| R-I040-1 | I040 | `LargeRampBoostNorthSouth` | $00C98D (51597) | `LargeRampIdleHold` | The routine is a bare `RTL`: it is the target of the radius-3 `BranchIfPlayerNear`, so the actor idles while the player stays within 48 px after a boost. It boosts nothing and never touches `playerSpeedNs` | 1 file in `extracted/` (`large_ramps.asm`), `db-us/names/bank00.json` |
| R-I040-2 | I040 | `EastWallNorthHandler` / `EastWallSouthHandler` | Bank 02 (`player_move_east`) | `EastWallPushDown` / `EastWallPushUp` | The names read as the wall's direction, but the routines are entered for TR `$09` and BR `$06` and end in `DiagPushRight` (pushes the player DOWN) and `DiagPushLeft` (pushes UP); the push direction is what a reader needs. Apply together with the west-file equivalents and after OQ-I029-4 / OQ-I029-5 | 1 file in `extracted/` each, 1 doc file each, `db-us/names/bank02.json` |
| R-I040-3 | I040 | `PaletteParentChildSpawnWave` | Bank 00 (`palette_parent_child`) | keep | Checked: the name matches the behaviour (spawn a child, step the palette, kill, repeat). Listed so the next audit does not revisit it | none |
| R-I040-4 | I040 | Documentation / comment corrections (no rename) | several | See list below | Found while auditing the three files | Doc text only |

Corrections for R-I040-4 (to apply in a later iteration that touches those files):

1. `docs/code/bank00/actors-infrastructure.md` `large_ramp_booster` (lines 262-292): the actor never changes `playerSpeedNs` and does not repeat while the player stays near; it adds +/-1 to `playerSpeedEw` once per approach (idle while within 48 px).
2. `docs/code/bank00/README.md` line 592: same description of `large_ramp_booster`.
3. `docs/code/bank0C-scene-spawn-tables-comet.md` line 444 and `docs/code/bank00/README.md` line 483: `palette_parent_child` "World Map, Inventory" / "Inventory"; the spawn records place it in scenes `$FD` and `$FF` only (OQ-I040-3).
4. `docs/code/bank02/player-movement.md` `EastWallNorthHandler` / `EastWallSouthHandler`: the sections say "Resolves via ... `DiagPushRight`" without the push direction; add down / up. Add the actor-solid-mark gate and the parked-velocity stack slot to the auto-align description.
5. `player_move_main` part notes for `NudgeToLowerGrid` / `NudgeToUpperGrid`: add the 2-px step and the n = 1..3 / 4..10 / 11..15 selection that the east file now documents.
