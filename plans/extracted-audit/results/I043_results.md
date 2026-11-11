# I043 results

Files: `actors/jeweler_gem.asm` (Bank 08), `actors/town_door.asm` (Bank 00), `functions/EnemyPositionSnap.asm` (Bank 0A).
Spec: [edits/I043.json](../edits/I043.json). New proposals: [renames/I043_renames.md](../renames/I043_renames.md). New questions: [questions/I043_questions.md](../questions/I043_questions.md).

Conventions as in [I029_results.md](I029_results.md). Mesen2 MCP was reachable but no ROM was running; no runtime session was set up, so every claim below is static (E1/E2/E3).

### File 1: actors/jeweler_gem.asm (Bank 08)

Evidence: E1 (all 384 lines with `extract:lt` addresses; the tier cascade, the BCD counter and the menu table traced by hand), E2 (`cop_handlers_script_control` `SetInteractHandler`, `cop_handlers_dialog` `DialogueOptions`, `cop_handlers_inventory` `GiveItem` / `RemoveItem` / `BranchIfHasItem`, `cop_handlers_player_query` `QueueMapChange`, `system_core` `UpdateHUD` (`hpToHeal`), `attack_ability_system` (`$0B16` / `$0B1C` level words and damage tables), `MenuSelectionHandler` header (1-based result, B cancel = 0), `sEA_solid_arm` (sets `$E8`), `sE9_mansion_intro`, `scene_actors.asm` spawn records via a script that maps records to scene ids, `global_ambient_dispatcher` (the talk handler that runs the `chatPtr`)), E3 (`docs/code/bank08-native-dao-pyramid-actors.md:250,324,438,476`, `docs/structs-reference.md:140`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A 16-line header plus inline notes, but the header skipped the spawn, the menu table and the counter, and some inline notes were wrong | FIXED (block note rewritten: spawn, reward tiers, menu and counting; 13 part notes (4 new, 9 replaced); 24 comment entries, 14 new and 10 replaced) |
| Q2 | M | The reader could not tell what the six placements are, why the menu is sometimes unreachable, or where the counter lives | FIXED |
| Q3 | **F** | (a) **Flag `$E8` is not 'game complete'**: it is set by `sEA_solid_arm` (Gem's true form, the optional boss), the doc table at `bank08-native-dao-pyramid-actors.md:250/438/476` is right, the header and the `JewelerDie` part note were wrong. (b) **`hpToHeal` is not an HP-bar flash**: `UpdateHUD` adds one current HP, filling the new max-HP point. (c) **`$28` is an animation index**, group x 8 + 2, not a 'sprite frame'; all six records pass `#01`, so group 0; `$0E = $3000` is the OAM attribute word. (d) **Dialogue / code mismatch at 8 jewels**: the string says 'Your Strength is raised by one', the code raises max HP (the 12-jewel text and code agree). (e) The `DialogueOptions` table is 1-based with cancel = 0, which is why entries 0 and 1 share `code_08CF59`. (f) `code_08D00D` and its string have no reference: dead code. (g) The counter is the absolute word `$0000` (WRAM `$7E:0000`), not the actor's DP `$00` entry pointer. (h) `$0B16` / `$0B1C` are the Psycho Dash / Dark Friar upgrade levels (damage 5 / 10 and 5 / 8 / 12). (i) The 50-jewel tier has no flag: with 50 or more jewels every talk warps again and the menu (including 'give jewels') is unreachable. (j) The warp goes to scene `$E9` (`sE9_mansion_intro`), the entrance to the Solid Arm fight | FIXED |
| Q4 | M | Operands correct; the old BCD comments (`Need >= 12 jewels (BCD)` etc.) are accurate | NOFIX |
| Q5 | M | `$0B16`, `$0B1C` and the scratch word `$0000` are raw addresses | PROPOSED (R-I043-3) |
| Q6 | M | `code_08CF59`, `code_08CF5E`, `code_08D012`, `code_08D00D`, `code_list_08CF51` carry address names for named behaviours | PROPOSED (R-I043-2) |
| Q7 | M | E1 + E2; the tier thresholds, flags, text and the `$E8` link are checked against code and the docs; the live behaviour of the warp and of the `hpToHeal` fill has no runtime check | NOFIX (low risk) |

### File 2: actors/town_door.asm (Bank 00)

Evidence: E1 (all 57 lines), E2 (`cop_handlers_script_control` `LoopStart` / `LoopEnd` / `JumpNextFrame`, `cop_handlers_input` `BranchIfPressed` (tests `joypadCurrent`), `cop_handlers_movement` `BranchIfPlayerNear` header (both |dx| and |dy| within radius x 16 px), `cop_handlers_player_query` `WaitWhileOffscreen`, `cop_handlers_collision` `MarkSolidHere` / `ClearSolidHere`, `cop_handlers_sprite` `StageSpriteFrame` / `AnimOnce`, `actor_execution` `InitActorFromSceneData` (`$4000` set at spawn), `scene_actors.asm` records, `fr32_guide` spawn), E3 (`docs/code/bank00/actors-player-rewards.md:22,346-358`, `docs/code/bank00/README.md:193,610`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A 3-line header, 5 part notes and inline notes | FIXED (block note rewritten; 5 part notes replaced; 10 comment entries, 4 new and 6 replaced) |
| Q2 | M | The loop structure (which op is the loop head, what restarts the 8-frame count) was not explained | FIXED |
| Q3 | **F** | (a) **The header says 'waits for A-button press'**; the code tests Up (`$0800`) held for 8 consecutive frames (`BranchIfPressed` reads `joypadCurrent`). (b) **'If the player walks away (loop expires)' is wrong**: not holding Up does not expire a timer, it jumps to the proximity check, which re-enters the loop and reloads the counter to 8. (c) The solid mark covers the hitbox rectangle (high nibble of the cells), not one tile. (d) **Placement**: 16 records in three scenes (`$01` x5, `$32` x4, `$91` x7) plus one runtime spawn from `fr32_guide`; the docs say '16 scenes' and `bank00/README.md:610` calls it a 'door warp trigger' (it is not a warp). (e) The first `BranchIfPlayerNear` (-> `TownDoorOpenIdle`) is the 'start open if the player is already next to the door' test; `WaitWhileOffscreen` is the loop head of every later frame because the door is off-screen at spawn. A door that is on-screen at its first pass would re-enter at `AnimOnce` and could open without the Up hold | FIXED (a-d); (e) the on-screen case is DEFERRED-EVIDENCE |
| Q4 | M | Operands correct | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | `TownDoorInteractLoop` is a hold-Up counter; `TownDoorOpenAnim` only plays the sound (the frame change is in `TownDoorOpenIdle`) | PROPOSED (R-I043-1) |
| Q7 | M | E1 + E2; the loop-head behaviour of a door that is on-screen at its first pass has no runtime check | DEFERRED-EVIDENCE (OQ-I043-1) |

### File 3: functions/EnemyPositionSnap.asm (Bank 0A)

Evidence: E1 (all 62 lines, target arithmetic worked through for both axes), E2 (`cop_handlers_movement` `SnapToGrid` / `ResumeAfterSnap` / `MoveToward` / `InitSmoothMovement`, the five `SnapToGrid` sites in `av6D_steelbones`, `ec0C_ribber` and `sg4D_cyber`), E3 (`docs/code/bank0A-dungeon-enemy-actors.md:539`, `docs/cop/families/movement.md:27,80-87`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A 7-line header and inline notes | FIXED (block note rewritten; 12 comment entries, 1 new and 11 replaced) |
| Q2 | M | The header did not say how the routine is entered or why the callbacks are cleared | FIXED |
| Q3 | **F** | (a) **It is not 'called after spawning enemies'**: it is the RTI target of COP `SnapToGrid` (#43), which saves the script address in `snapResumePtr` and rewrites the COP return frame; the five script sites are Steelbones, Ribber and Cyber (3). (b) **`MoveToward #FF, #01` is not 'max speed'**: `#FF` keeps the current animation and `#01` is 1 px per frame; the same wording is in `bank0A-dungeon-enemy-actors.md:539`, `docs/cop/families/movement.md:80` and two comments in `WorldMapController.asm` (lines 293 / 317). (c) **Target maths**: X = nearest value that is 8 mod 16 (tile centre), Y = nearest multiple of 16 (tie rounds up); the old 'tile + $18 / + $08 / + $10' notes did not say that. (d) The hit and dodge callbacks are cleared on entry and not restored here; Ribber and Steelbones also write `SetHitCallback #0000` around their snap | FIXED |
| Q4 | M | Operands correct | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | The name matches the behaviour (position snap for enemies) | NOFIX |
| Q7 | M | E1 + E2; the glide has no runtime check | NOFIX (low risk) |

### Shared gate (I043)

`npm run merge -- edits/I043.json --dry-run` was clean. Merge applied: 3 block notes, 18 part notes (4 new, 14 replaced), 46 comment entries (19 new, 27 replaced). `npm run extract:lt` then `npm run rebuild` (one run for I043 + I044): `artifacts/crc.json` = checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged). With comments and `{n}` tags stripped, the code of all three files is identical to HEAD.

Wording note: the jeweler block note and the comment at `577218` say the player 'presses B facing him'. B is the vanilla name of the interact bit; in this build `transforms.json` rewrites the `system_init` remap defaults so the A button feeds it. The precise statement is in the `global_ambient_dispatcher` block note (I044).

Suggested commit message: `audit(I043): jeweler_gem tiers, menu and Solid Arm flag, town_door hold-Up loop, EnemyPositionSnap as the SnapToGrid target`

Please commit when you're ready.
