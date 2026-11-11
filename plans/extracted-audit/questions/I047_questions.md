# I047 open questions

No ROM was running in Mesen2, so everything below is UNVERIFIED-RUNTIME.

| ID | Iter | Question | Static evidence so far | Suggested check |
|----|------|----------|------------------------|-----------------|
| OQ-I047-1 | I047 | Does a non-negative `iframeCounter` with Flags10 `$0080` set really stop all movement for the stun period, and does a negative counter (recovery) let the player move at once? | E1: the controller returns early only for `$0080` set and `iframeCounter >= 0`; the sign convention comes from the `actor_execution` header | Take a hit, then break on `$02B2B8` (the `iframeCounter` read) and log the counter and the player position each frame |
| OQ-I047-2 | I047 | During a stat pickup (`reward_actors`, display filter set, actor flags `$1000`) do the player, its companions and `player_move_controller` still run? The static trace says only actors with `$1000` run in the filtered pass | E1: `EnemyStatBonusReward` sets `displayModeFlags` `$0080` and spawns with `$1000`; the player's own flags word was not traced | Clear the last enemy in a Dark Space room and watch whether the player can walk while the icon flies |
| OQ-I047-3 | I047 | Do the six statue sprites land on the pedestal pixels given in the `inventory_statue_slot` block note (actor X = tile x 16 + 16, Y = tile y 16 + 8, minus 8 for the top row)? | E1: derived from `NudgePosition` (+8, +8) plus the engine's +8 X centring in `InitActorFromSceneData`; not captured from a frame | Open the inventory with all six statues set and read the six actors' `$14` / `$16` |
