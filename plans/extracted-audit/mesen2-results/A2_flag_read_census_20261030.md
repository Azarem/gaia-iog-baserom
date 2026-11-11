# A2: census of every read of actor Flags10 / Flags12, and the `$0200` confirmation (Campaign A, step A2)

ROM: O (original)

| Tag | File | Size | SHA-1 | CRC-32 | Mode source |
|-----|------|-----:|-------|--------|-------------|
| O | `rebuilt/Illusion of Gaia.smc` | 2,097,152 | `38de0c84dd2bc3bdfc0a3d7ab0220c79b70887c3` | `1c3848c0` | vanilla ROM |

Server: Mesen2 MCP 0.5.0 (see `tool-issues.md`).

State: `rebuilt/states/orig_S01r_south-cape-ready.mss` (South Cape, Will, scene `$01`), loaded by every session; set-up per session as in the A1 file. The confirmation runs (A3 X4, X4c) load the same state and write `$0642 = $3F` (Diamond Mine) and `$0AA2/$0AA3 = $77`.

## Static prelude

- A read of a slot field is any memory read of `0x1000-0x1FBF` at `+10..+13` (the read callback sees `LDA`, `BIT`, `TSB`/`TRB` (read half), `AND`, `ORA`, `CMP`). For each distinct K:PC, `harness/decode_flag_census.py` decodes the instruction, the three following instructions (`next`) and the nearest label. The tested mask is the immediate of the first `BIT`/`AND`/`CMP` after the load. A test more than 3 instructions after the load, or after a `JSR`, would be missed: this is a limit of "the reader list is complete".
- The merged table is `raw/A2_merged_20261030.json` (1,716 `(session, field, PC)` rows). `harness/view_reads.py 20261030 10` prints the field-10 view (this file's numbers).
- Slot geometry is `$30` per slot (see the A1 file).
- Counts are executions in all 12 sessions; `pl` is the number of those where the slot was the player.

## Script

`harness/scenario_a1_flag_census.py --reads` (same session list as A1, minus `sc_npc_talk_clear0200` and `mine_exit_warp`; read callbacks on, write callbacks on) and `harness/scenario_a3_forced_bits.py` (X4, X4c). Verbatim Lua: `raw/A1_A2_scripts_20261030.lua.txt` (census sessions) and `raw/A3_scripts_20261030.lua.txt` (X4, X4c). Library: `kit/lib/a_census.lua`.

The first A2 attempt hit the client's 300 s RPC timeout (`TimeoutError`) on a 3,317-frame session with read callbacks (about 570,000 reads); `harness/mcp_client.py` `_rpc` timeout was raised to 1800 s and the remaining sessions were re-run one by one (`--only`), logs in `raw/A2_run_log_20261030.txt` and `raw/A2_run_log2_20261030.txt`. Data of the sessions that had finished is the same run (deterministic).

## Positive control

- `control36Writes` is 1,099 to 3,136 and about equal to the frame count in all 12 sessions.
- Read callbacks alive: 149,296 to 939,436 reads per session; the player's own reads (`PlayerMoveController+21`, 18,511; `RunActors_Normal+45`, 18,511 player reads) are present in every session that has the player.
- Every reader that A1's sources list as known (`SortActorsByDepth+82`, `RunActors_Normal+45`, `PlayerMoveCollisionStage+10`, `GlobalAmbientTargetInRange+16` for `$12` bit 9) shows up with a non-zero count.
- `$0200` confirmation: the forced run and the control run give different HP in the same input (see A3 X4); the control proves the contact would have hurt.

## Coverage

12 sessions, 22,018 frames, ROM O, scenes `$01`, `$02`, `$08`, `$29`, `$3F`, `$3E`; Will, Freedan, Shadow. Not reached: see the A1 file (no enemy kill, no Dark Space warp, no forced walk, no ramp, no glide, no chest / sign / door interaction, no `ToggleActorVisibilityFlag`, no NPC-chat damage, no pause menu with a number child alive).

## Observations (Flags10 readers, field 10; `n` = executions, `pl` = player)

Readers that test a bit this campaign asks about:

| Bit | Reader (PC, label) | Test | n / pl | What the branch does |
|-----|--------------------|------|--------|----------------------|
| `$0200` | `83:BCCD` `CombatCollision_InnerLoop+17` | `BIT #$76E0` | 11,022 / 3,412 | non-friendly pass: target with any of `$76E0` is skipped (`$0200` included) |
| `$0200` | `83:C286` `RunInteractionCollision+40` | `BIT #$2040`, then `BIT #$0280` | 18,477 / 18,477 | `$0200` or `$0080` on the player: interaction pass is `InteractionCollision_FriendlyMode` (friendly NPCs only) |
| `$0200` | `83:BCD9` `CombatCollision_InnerLoop+29` | `BIT #$74E0` | 1,557 / 384 | friendly pass: the mask has no `$0200`, so a `$0200` actor is **not** skipped here (the code comment says the same) |
| `$0100` | `83:BC33` `CombatCollision_NextTarget+19` | `BIT #$0400`, `BIT #$0140` | 61,621 / 18,316 | an actor with `$0400` and (`$0040` or `$0100`) is skipped as outer-loop source |
| `$0100` | `83:C2A4` `InteractionCollision_LoopBody+12`, `83:C373` `InteractionCollision_FriendlyMode+17` | `BIT #$35C0` / `BIT #$3540` | 54,210 / 16,846 and 7,347 / 1,458 | skipped as interaction target |
| `$0400` | the same four sites, `ProcessDodgeCallbacks+24` (`$D460`), `HitStaggerSlideLoop+21` | | 18 to 61,621 | exclusion / route tests; no enemy with `$0400` set by a defeat was ever tested (no kill) |
| `$2000` | `RunActors_Normal+45` (528,648 / 18,511), `RunActors_CopScriptPostTick+2`, `SortActorsByDepth+82` (116,438 / 20,363), `RunActors_CutsceneOnly+24`, `RunActors_OverlayOnly+30`, `PlayerIdleEntry+32` (738 / 738) | `BIT #$2000` | | script-driven path / not drawn / idle returns at once |
| `$0010` | `DecomposeActorMetasprites+45` (69,375 / 20,363, then `BIT #$0010`), `ApplyHitDamageToVictim_DamagePath+8` (10 / 0), `BranchIfBehindWall+36` | | | blink gate; invincible route to `HitInvincibleVictim` |
| `$0800` | `RunActors_CutsceneOnly+12` (34,588 / 1,933), `PrintDialogString+29/+38/+88` (12 each, 0 player) | | | cutscene-only pass; dialog save, clear, restore |
| `$0003` | `SortActorsByDepth+82` only (`BIT #$0003`) | | 116,438 | depth key |
| `$1000` (`$12`) | `RunActors_OverlayOnly+23` (550 / 50), `GlobalAmbientScanLoop+6` for `$10` bit 12 (10,851 / 344) | | | overlay / display-filter pass; target scan |

In **no** executed read was bit 0 or 1 of `$10` tested together with a collision, tile or hitbox routine (only `SortActorsByDepth`). `StartMusic+30` clears `$10` bit 12 (`AND #$EFFF`, 2 executions, not the player).

`$12` readers worth keeping: `ProcessAnimFlag+20/+36` (bit 1, 367 and 2,627 reads, 22 on the player, bit clear), `ApplyMovement` (`$4000`, `$2000`), `CollisionX/Y` (`$2000` `$4000`), `GlobalAmbientTargetInRange+16` (`BIT #$0200`, 4), `ApplyHitDamageToVictim_DamagePath+300` (`BIT #$0001`, 9, none on the player), `+169` (`BIT #$0010`, 10), `+326` (`BIT #$0020`, 10), `CombatCollision_EnemyLoop+13` (`BIT #$0010`, 152), `HitStaggerMain+21` (19).

## Verdicts

The five ids marked in the plan with a dagger are the same question for the player's `$10` bit 9 (`$0200`): who reads it.

| ID | Verdict | Grade | Shipped note (file:line) | Action |
|----|---------|-------|--------------------------|--------|
| OQ-I023-3 | The reader is the contact test: `CombatCollision_InnerLoop+17` (`BIT #$76E0`) and `RunInteractionCollision+40` (`BIT #$0280`). With `$0200` forced on the player, an enemy standing on Will for 120 frames did **no** damage (HP 8 -> 8); in the control run HP went 8 -> 1 at frame 372 and 0 at frame 436 (death, `playerFlags $0200`). Bit `$0200` of `$10` = "ignores enemy contact" (not "glide marker"). | VERIFIED-RUNTIME | `extracted/actors/player/attack_ability_system.asm:372`, `:419`, `:1305`, `:1418`; `extracted/actors/player_transition_handlers.asm:16`, `:70` ("scripted-motion marker"); `extracted/actors/player/player_character.asm:7`; `extracted/actors/ramps.asm:440`, `:459`, `:476`, `:506` ("reader unknown"); `extracted/system/engine/slider_glide.asm:280` ("reader unknown"); `extracted/functions/StopPlayerOnDeath.asm:21` ("no reader found"); `extracted/system/dark_space/sE6_gaia.asm:2095` | rewrite all as "ignore enemy contact (`CombatCollision_InnerLoop` mask `$76E0`, interaction friendly-only branch `$0280`)" |
| OQ-I027-2 | Same readers; `AuraBarrierMain+5` sets the bit (2 runs) and `AuraBarrierEnd+5` clears it (2), `SpinDashMain+98` sets it (1) and `SpinDashAbort+5` clears it (1). So the Aura Barrier and the Spin Dash projectile make Will ignore enemy contact while active; they are not "ability FX active" / "guided projectile active". | VERIFIED-RUNTIME | `attack_ability_system.asm:372`, `:419` ("ability FX active"), `:1305`, `:1418` ("guided projectile") | rewrite |
| OQ-I030-2 | The mechanism holds: `$76E0` skips `$0200` actors in the normal pass, and the interaction pass drops to friendly-only; the friendly pass (`$74E0`) lets a `$0200` actor through. In the control a contact kills Will; with the bit forced no contact damage. **Not shown:** the boss-defeat sequence (no boss was beaten), whether anything clears the bit after a defeat helper, and whether it persists across the two `mu67_vampires` callbacks. | VERIFIED-RUNTIME (mechanism); the defeat context is INCONCLUSIVE | `extracted/system/engine/combat_collision.asm` (mask comments, correct) | the two open halves go to a new question |
| OQ-I032-5 | Same readers. `StopPlayerOnDeath+21` sets the bit (3 deaths: `f10 = $87C8` after death, bit 9 set with `$0040`), so the dead player also ignores contact. Psycho Slider set / clear: `RunAttackFlagSetup+5` / `RunAttackCleanup+5` (1 each) ran. | VERIFIED-RUNTIME | `StopPlayerOnDeath.asm:21` ("no reader of this actor bit found"), `player_character.asm:7` | rewrite |
| OQ-I036-4 | Same two readers; no other executed instruction tests bit 9 of the player `$10`. The ramp writers did not run (no ramp in the 12 sessions), so the ramp use of the bit is by the same readers only by code identity. | VERIFIED-RUNTIME (readers); ramp writers not run | `ramps.asm:440`, `:459`, `:476`, `:506` | rewrite the comments; ramp run still open |
| OQ-8 | `$0080`: reader sites `PlayerMoveController+21` (`BIT #$0080`, stunned: 18,511 / 18,511), `DecomposeActorMetasprites+45` (blink gate), `RunInteractionCollision+40` (`$0280`), `CheckRunAttack+2`, `SpinDashMain+46`; set on the player by `ApplyInteractionDamage+168` together with the 60-frame iframe counter (`$7F0028 = $003C`, 19 hits). `$0400`: readers exist (see table) but no enemy was defeated, so what a defeat does with it was not seen. | INCONCLUSIVE (`$0400` half; `$0080` half VERIFIED-RUNTIME) | `combat_collision.asm` Phase-1 comment ("role unresolved") | `$0080` = "hit-reaction active, iframe counter running"; update the comment |
| OQ-40 | No executed instruction tested bit 0 or bit 1 of `$10` against a collision, tile or hitbox routine; the only reader with a `$0003` mask is `SortActorsByDepth+82` (depth key). Coverage: 22,018 frames, 12 sessions. The `STZ $070F` half was not examined (A2 watches actor slots only). | VERIFIED-RUNTIME (first half, coverage-limited) | `sprite_composition.asm` | none for bits 0/1; `STZ $070F` still open |
| OQ-I037-4 | Part answered: `EnemyInitBasic+5` ran 12 times (all scene `$3F`) and writes `$12` bits 4 and 5; the readers of those bits (`CombatCollision_EnemyLoop+13`, `ApplyHitDamageToVictim_DamagePath+169` and `+326`) ran, which fits "bit 4 = immune, bit 5 = boss". The laborer / kidnapper was never hit, so the `currentHp = 1` replacement was not seen. | INCONCLUSIVE | - | needs a hit on the laborer |
| OQ-I041-6 | No damage number child was inspected while pausing. | INCONCLUSIVE | - | pause test |
| OQ-I047-2 | No stat pickup. | INCONCLUSIVE | - | Dark Space room kill |
| OQ-I054-3 | No last-enemy kill. `RunActors_OverlayOnly+23` (`BIT #$1000`, 550 reads) shows the filtered pass exists and runs for overlay frames. | INCONCLUSIVE | - | kill run |

## Tool issues

See `tool-issues.md` T-31 to T-37.

## New questions

1. Does bit `$0100` of the player `$10` (set by `PlayerIdleEntry` every idle entry, cleared by block / attack) really make the player skip the outer phase-2 loop (`BIT #$0140` in `CombatCollision_NextTarget`)? The player also spawns with `$0400`. A forced run next to an enemy would show it.
2. After a boss defeat, who clears the player's `$0200`, and does it survive the two `mu67_vampires` death callbacks (OQ-I030-2, second half)?
3. The comment at `combat_collision.asm` (`$0280`: "`$0200` game-over / `$0080` iframe-active") calls bit 9 "game over", which matches `StopPlayerOnDeath` but not the Aura Barrier or the ramps: rename to "ignore contact" and say that death uses it.
4. `ApplyInteractionDamage+168` sets `$0080` and stores 60 in `$7F0028`, while `ApplyHitDamageToVictim_DamagePath` uses `$FFEF` / `$0011` for victims: is the player's 60-frame counter positive (hit-stun) or does `$12` bit 0 (`$0001`, set at init) route the player somewhere else? No reader of `$12` bit 0 ran on the player.
