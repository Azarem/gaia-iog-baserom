# I047 results

Files: `actors/player/player_move_controller.asm` (Bank 02), `system/inventory/inventory_statue_slot.asm` (Bank 00), `actors/reward_actors.asm` (Bank 00).
Spec: [edits/I047.json](../edits/I047.json). New proposals: [renames/I047_renames.md](../renames/I047_renames.md). New questions: [questions/I047_questions.md](../questions/I047_questions.md).

Conventions (unchanged): verdicts **P/M/F/NA**; dispositions **FIXED / PROPOSED / DEFERRED-EVIDENCE / NOFIX**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no ROM was running in Mesen2 in this session). Q1 comment density, Q2 value, Q3 accuracy, Q4 mnemonic/address accuracy, Q5 mnemonic opportunity, Q6 part naming, Q7 evidence quality.

### File 1: actors/player/player_move_controller.asm (Bank 02)

Evidence: E1 (the whole file; `actor_execution` header for the Flags10 bit meanings, the iframe-counter sign convention and the `$0008` collision-checked-movement bit; `actor_pool` `CopyActorState` for the flags a spawned child inherits; `cop_handlers_spawn` for `SpawnAfter`; `player_move_main.PlayerMovementTick` and the I045 block note for the `$20`-`$26` / `$000A` contract; `slope_ramp_physics` header for the speed words and the `$1000` latch; `player_character` for the spawn COPs; `scene_lifecycle` for the clearing of `extVelocityX/Y` and the speed words), E2 (`rg` for every writer of `extVelocityX` / `extVelocityY` and for the callers of `JoypadToVelocity`), E3 (`docs/wram-memory-map.md` playerFlags table lines 310-330, `docs/code/bank02/README.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A three-line header and about 48 inline comments; the six stages, the sub-pixel scaling and the stack use were not explained | FIXED (block note, 2 part notes, 106 comments covering every instruction) |
| Q2 | M | A reader could not tell why the actor keeps its own copy of the position, what `$20`-`$26` hold at the tick call or which lists of flags gate movement | FIXED (spawn order, state, per-frame stages and the external velocity sources in the block note) |
| Q3 | **F** | (a) **Hit-stun check**: Flags10 bit `$0080` is "iframe counter running"; with a non-negative `iframeCounter` the frame is skipped (hit-stun), a negative counter (recovery) lets movement continue. The old header and comments called `$0080` a "freeze" flag. (b) **Lock is OR of two bits** (the old text already had this right): `BIT #$0A00` tests game over (`$0200`) or script / ability lock (`$0800`); either clears `extVelocityX/Y` and skips. (c) **`$0008` is "collision-checked movement"** (the engine bit, set for every actor that uses tile collision), not "grounded" / "airborne" as the old text said; the vine, ladder and shimmy states clear it, so the tick is skipped and the velocity is added directly. (d) **Spawn order**: every `SpawnAfter` inserts directly behind the spawner, and the slope actor is spawned after this controller, so the list reads attack, player, slope, controller: the slope actor edits the speed words before the controller reads them in the same frame. (e) **Sub-pixel units**: the actor's own `$14` / `$16` are 4 per pixel; the player actor keeps plain pixels (write-back `>> 2`); the x4 scaling runs once at spawn, above `SetEntryHere`. (f) **Sync**: if the player's pixel position differs from local `>> 2` the actor adopts the player's position x4 and the fraction is lost. (g) **Speed words**: one speed unit is one pixel per frame (x4 in sub-pixels); a nonzero speed also clears the `$1000` latch. Joypad velocity is +/-8 (2 px per frame); diagonals +/-6 on both axes (about 2.1 px resultant). (h) **Direction priority**: Left over Right, Up over Down. (i) **`$000A`** is the engine scratch word the tick reads X from, not a local variable. (j) **Tick X**: the tick runs with X = this actor's slot; solid contact (`$0004`) is written into this actor's `$10` and copied to the player's `$10`. (k) External velocities are zeroed every frame, so a pusher must write them every frame | FIXED (all comments); the stale doc claims are in R-I047-6 |
| Q4 | M | `$20` / `$22` / `$24` / `$26`, `$000A`, `$01,S`, `#$0A00`, `#$3000` had no unit or meaning | FIXED (comments on every operand) |
| Q5 | M | Scratch words `$20`-`$26` and `$000A` are bare numbers here and in six more files (see R-I045-3) | PROPOSED (R-I047-3) |
| Q6 | M | Eleven `loc_` labels are stage anchors; `JoypadToVelocity` is accurate | PROPOSED (R-I047-1, R-I047-2) |
| Q7 | M | E1 + E2; the hit-stun skip, the effective frame order and the diagonal speed are not runtime-verified | DEFERRED-EVIDENCE (OQ-I047-1, OQ-I047-2) |

### File 2: system/inventory/inventory_statue_slot.asm (Bank 00)

Evidence: E1 (the whole file; `statue_inventory_reward` for the shared table; `flag_helpers.TestFlagRaw` for the carry convention and the flag-to-byte mapping; `NudgePosition` and `InitActorFromSceneData` mode 1 for the parameter encoding and the +8 X centring; `scene_actors` scene `$FF` and `$FD` spawn lists for the six spawn bytes; `inventory_overlay` for the use of `RunActors_CutsceneOnly` and `inventoryTabIndex`), E2 (`rg` for `inventoryTabIndex` writers: tab 3 is the Status tab), E3 (`docs/code/bank00/actors-player-rewards.md` lines 272-300).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | The header was already thorough (parameter encoding, table, behaviour), but the file had only four inline comments and no part note | FIXED (block note kept and extended, 1 part note, 31 comments covering every instruction) |
| Q2 | M | The header gave tile coordinates but not the actor positions, the table's tail byte or the flag-to-byte rule | FIXED (spawn-byte table now has actor X, Y; flag and table layout stated) |
| Q3 | M | The old header was accurate on the tab logic (tabs 0-2 show, tab 3 Status hides) and the parameter encoding. Added or sharpened: (a) **Positions**: actor X = tile x 16 + 8 (engine centring) + 8 (`NudgePosition`), actor Y = tile y 16 + 8, minus 8 for bit 4; these are actor coordinates, not screen pixels. (b) **Table**: 4 bytes per entry (flag, sprite, match, one tail byte); this actor reads `+0` and `+1` only. (c) **Flags `$F8`-`$FD`** are bits 0-5 of the single byte `$0A1F`. (d) The actor overwrites `$0E` with `$2000` (the OAM attribute word) after reading it; the actor-def header gives flags `$3800`. (e) The **doc** says `#$0003` of `$0AFA` is "highlighted / visible" and that the table has 3-byte entries: both are wrong (R-I047-6) | FIXED (comments + block note) |
| Q4 | M | Operands `#$0010`, `#$000F`, `ASL ASL`, `#$2000` unexplained | FIXED |
| Q5 | NA | `inventoryTabIndex` already exists as a mnemonic | NOFIX |
| Q6 | M | `code_00CF2C` is the entry; the two `loc_` labels are branch targets | PROPOSED (R-I047-4) |
| Q7 | M | E1 + E2; the on-screen pixel positions are derived, not captured | DEFERRED-EVIDENCE (OQ-I047-3) |

### File 3: actors/reward_actors.asm (Bank 00)

Evidence: E1 (the whole file; `StandardEnemyDefeatHandler` `EnemyStatBonusReward` and its spawn COPs; `actor_execution` for the display filter (`displayModeFlags` bit 7 / Flags10 `$1000`); `cop_handlers_movement` for `StageMove` / `TickMove` and the `StageSpriteLoopMoveY` chain `#12` in `movement_delta_table`; `flag_helpers.SetFlag_0300`; the HUD `UpdateHUD` use of `hpToHeal`), E2 (`rg` for the three actor names and for `hpToHeal` / `playerMaxHp` / `playerHp` writers), E3 (`docs/code/bank00/actors-combat-interaction.md` lines 120-185, `docs/wram-memory-map.md` line 293).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A three-line header and no inline comments | FIXED (block note, 51 comments) |
| Q2 | M | The spawn trigger, the world freeze and the once-per-scene rule were not stated | FIXED |
| Q3 | **F** | (a) **`$0ACA` is MAX HP and `$0ACE` is CURRENT HP**: the actor adds 1 to max HP and sets `hpToHeal` to new max minus current, so the whole missing HP is refilled; the docs say "increments HP" and call `$0ACE` "base HP". (b) **The overflow clamp is dead**: `BVC` skips the clamp unless the sum overflows signed 16 bits (`$7FFF + 1`), which cannot happen, so `$0255` is never loaded and nothing caps the stats. (c) **The world freeze**: `EnemyStatBonusReward` sets `displayModeFlags` `$0080` (display filter) and spawns the actor with flags `$1000` (`SpawnListAppend`, not `SpawnLastRel`); only actors with `$1000` run in the filtered pass; `RewardActorVFX` clears the filter on arrival. (d) **`RewardActorVFX` is called with `CallNear`** (not `CallScript`) and returns with `RestoreSavedPtr`. (e) **Movement**: the pickup rises along chain `#12` (-1 px every second tick) for 4 passes, hovers for 3, then flies (`StageMove` speed 2, target in `moveXAlt` / `moveYAlt` = player X, player Y - 8); it hides itself on arrival. (f) **Once per scene**: `TestFlag_0300` (flag `$0300 + scene`) is tested by the handler and set by `RewardActorVFX`. (g) **Which actor**: `enemy_clear_reward_table[scene]` selects 1 = HP, 2 = STR, 3+ = DEF, 0 = none. (h) **Trigger**: only when the remaining-enemy count saved in `orbitAngle` is 0 (the last enemy) | FIXED (comments + block note); doc corrections in R-I047-6 |
| Q4 | M | `#$6000` (Flags12 bits), `#$0255`, `#$0080`, `#$2000`, the `moveXAlt` targets had no meaning | FIXED |
| Q5 | NA | Every address already has a mnemonic | NOFIX |
| Q6 | P | `e_hp_increase` / `e_str_increase` / `e_def_increase` / `RewardActorVFX` describe the code | NOFIX |
| Q7 | M | E1 + E2; whether the player and its companions run in the display-filtered pass during the pickup is not verified | DEFERRED-EVIDENCE (OQ-I047-2) |

### Shared gate (I047)

`npm run merge -- plans/extracted-audit/edits/I047.json --dry-run` reported 3 block notes (all updated), 3 part notes (1 new, 2 updated) and 188 comments (136 new, 52 updated; the controller's `176902` was added to the spec after a check found its old comment still in place, so the first dry run counted 58 new / 47 updated for the controller). Per file: `player_move_controller` 2 parts (updated) and 106 comments (58 new, 48 updated); `inventory_statue_slot` 1 part (new) and 31 comments (27 new, 4 updated); `reward_actors` 51 comments (all new). The dry run printed no warnings. After the real merge, `npm run extract:lt` completed and `npm run rebuild` finished successfully. `artifacts/crc.json` = checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged). With comments and `{n}` tags stripped, `player_move_controller.asm` and `reward_actors.asm` are line-identical to HEAD; `inventory_statue_slot.asm` differs from HEAD only by the part-note separator line the new part note adds.

Docs that repeat the old claims are listed in R-I047-6 (not edited: `docs/` is outside the allowed folder).

Suggested commit message: `audit(I047): player_move_controller stages and flag meanings (hit-stun, OR lock, collision-checked move, sub-pixels), inventory_statue_slot positions and tab logic, reward_actors freeze and max-HP reward flow`

Please commit when you're ready.
