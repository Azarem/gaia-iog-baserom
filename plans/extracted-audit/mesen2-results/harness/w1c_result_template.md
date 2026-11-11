# W1-c Address census, batch c: event and flag bytes (`$0A00` bit 0, `$0A80-$0AA7`, `$0AEC/$0AEE`)

ROM: O (original US ROM, vanilla; not a rebuilt ROM)
File: `c:\Work\gaia-iog-baserom\rebuilt\Illusion of Gaia.smc`
SHA-1: `38de0c84dd2bc3bdfc0a3d7ab0220c79b70887c3`   CRC-32: `1c3848c0`   file size: 2,097,152 bytes
crc.json: `artifacts/crc.json` describes the last REBUILT ROM, not ROM O, so it does not apply to this run (same situation as W1-a and W1-b). Every run returned `fileSha1` and `fileSizeBytes` from `get_rom_info` equal to the values above (108 of 108 result files).
Mode source: `get_rom_info` of the server; ROM O is loaded by `harness/a_common.py open_session` (no build mode: the file is the original cartridge dump).
Server: Mesen2 MCP `user-mesen2-mcp-dev` 0.6.0 (flags `--mcp-lib-dir=...\mesen2-results\kit\lib`, `--mcp-results-dir=...\mesen2-results\raw`), driven by `harness/w1c_session.py` (own server process per run, same session table as W1-a / W1-b plus the sessions listed below).
Date: 2026-11-07
Ids: OQ-I030-1, OQ-I052-1, OQ-I048-1 (the three are the same flag `#00`), OQ-67, OQ-68, OQ-I042-7, OQ-I054-2

## State

108 runs, 131,278 session frames (sum of the per-session frame counters; the natural replay counted at its single publication). Every run loaded its state, passed the H1 test (load, `advance_frame` 120, `cpu.k` in `$80-$BF` / `$C0-$CF`, `cpu.sp` in `$0100-$01FF`, scene) and was run with the ROM SHA-1 equal on its result file: 108 of 108 H1 `ok`. No state was created or changed (`states-index.md` untouched; the trial sessions poke WRAM after the state load).

| Session group | State (`rebuilt/states/`) | Frames each | Driver |
|---|---|---|---|
| the W1-a / W1-b table (`sc_bot`, `castoth_melee`, `mine_melee`, `n01_bot`-`n03_bot`, `p00_08` ... `p18s_E8`, `slope_s13` ... `slope_s14i`, `menu_inventory`, `menu_diary`, `chest_0E`, `chest_1D`, `warp_chain`, `warp_credits`, `warp_misc`, `warp_b`, `warp_b2`, `warp_l1`) | same states and drivers as W1-b | 600-7,702 | seeded bot / pattern / timeline / quick warps |
| `boot_power` | cold boot | 700 | none |
| `natural_fr10` | `orig_S06_title` | 20,079 input frames | recorded input `FR10_early_game.input` |
| `f0_XX` (26 sessions) | `orig_S01r_south-cape-ready` + quick warp (`$0642`) to one of the 26 scenes whose actor list holds `scene_flag_init`: `$15 $1A $1D $2B $2C $2F $30 $32 $43 $4C-$55 $6D-$72 $78` | 460 | A-tapping bot, no walking |
| `f0s_XX` (26 sessions) | same, with `characterForm` (`$0AD4`) poked to 2 (Shadow) at load | 460 | same |
| `t_kill_a` / `t_kill_b` | `orig_S01r` + warp to `$3F` / `$3E` (Diamond Mine rooms) | 2,100 | A-tapper; two induced kills; leave and return |
| `t_kill_c` | `orig_S01r` + warp to `$1B` (Moon Tribe cave), leave to `$1C` | 2,100 | same |
| `t_kill_d` | `orig_S01r` + warp to `$29` (Castoth lair), leave to `$28` | 2,100 | same |
| `t_boss_reward` | `orig_S01r` + warp to `$29`; `playerFlags` bit `$0020` forced at frame +400 | 1,700 | A-tapper |
| `t_flag01` | `orig_S01r`; flags `#01` and `#08` forced in `$01`, warp to `$15` | 700 | A-tapping bot that also walks |
| `t_wmclear` | `orig_S01r`; `$0A80-$0A9F` := `$FF`, `$0AA0-$0AA2` := `$01 $02 $04`, warp to `$FE` | 900 | A-tapper |
| `t_gameover_lt100` / `t_gameover_ge100` | `orig_N01_sc_first_free`; `$0A80`, `$0A9F`, `$0AA0` poked, gems 0 / 150, `playerHp` := 0 | 900 each | seeded bot |

Buttons (logical bit / physical button): attack and interact `$0080` / physical A, cancel `$4000` / physical B; the A-tapper presses A (3 ticks) at random, the seeded bots press A / B and directions as in W1-b. Forms: Will unless the session name ends in `s` (Shadow, `$0AD4` = 2) or the preset state holds another form (`p17_E7` and `p18s_E8` ran the shimmer actor, so they are Shadow; the other presets as in W1-b State).

The kill trials make the victim die by the engine's own route: the victim's entry word (slot + 0) is replaced with `StandardEnemyDefeatHandler` (`$DB8A`, offset 56202) and the bank byte (slot + 2) with `$80`, exactly what `hit_stagger_controller` stores when HP reaches zero. No bot killed an enemy by melee in any W1-c run (A, B, Y presses, walking or still), so every kill in this file is induced. The boss-reward trial forces `playerFlags` bit `$0020` (boss defeated), the condition `boss_clear_reward_handler` waits for; the boss is not fought.

## Static prelude

Method: `rg` of every operand that names a watched byte in `extracted/`, by address and by name (`eventFlags`, `wramFlags`, `L_wramFlags`, `abilityBitmask`, `enemiesRemaining`, `enemiesRemainingBcd`, `$0AA6`, `$0A9F`), tagged with the ROM offset (`; {n}`); the routine is the nearest label above plus the byte offset. The compact static list with the runtime count of each site is in `raw/W1c_report.md` ("Static census"). `$cgramPalette` operands (`$7F0A00`, another bank) appear in the raw list and are not sites of `$0A00` (12 of the 25 listed `$0A00` sites); the counts below leave them out.

Findings that shaped the instruments:

- `$0A00` (event flags `$00-$07`): 13 sites. The helpers `SetEventFlag` (45258 / 45265), `ClearEventFlag` (45297 / 45300) and `TestEventFlag` (45330) take the flag index; `ClearSceneState+21` (253291, `STX $eventFlags`) zeroes the word; `OpenInventoryScreen` reads (191788), zeroes (191792) and restores (192094) the word; `SaveGameState_Scene` / `LoadGameState_Scene` (252204 / 252285) copy it; `mu66_rama_spirits` (433951) and `ir1F_plate_gate_opener` (640148) read it directly. Flag `#00` is set by the COP `SetFlagByte ( #00 )` of `scene_flag_init` (50794, 26 scene actor lists) and by `sc01_fisherman` (295903, cleared at 295907) and `inventory_menu` (191678); it is read by `ShadowShimmerIdle` (176698), `ShadowShimmerActive` (176733), `PlayerIdleAnimLoop` (50226), `IdleStandSouth / North / West / East` (181375, 181391, 181407, 181423) and the inventory overlay loop (192033).
- `$0A80-$0A9F` (`wramFlags`): direct operands only in `SetWramFlag` (45191 / 45198), `TestWramFlag` (45228), `ClearAllWramFlags` (46291, long), `GameOverClearFlagsLoop` (54994) and `CheckEnemyDefeatedFlag+24` (250099); one more direct reader is `LDA $0A9F` in `gw88_tomb_dark_space` (507380: it waits for the byte to equal `$3F`, then changes the background and sets flag word `$0174`). The writers by helper are the COP `SetDungeonKillFlag` (44172, via `StandardEnemyDefeatHandler`, 56306) and `SetWramFlag_Offset100` (45165, one caller: `boss_clear_reward_handler`, 49928). No COP flag operand in `$0400-$053F` exists in `plans/flags/inventory.json`; `$0500-$0507` is reached only through the 7 `TestWramFlag_Offset100` callers (`boss_clear_reward_handler`, Castoth, Viper, the two vampire callbacks, Sand Fanger, Mummy Queen) and the one `SetWramFlag_Offset100` caller.
- `$0AA0` (event flags `$0500-$0507`) is outside `ClearAllWramFlags` (`$0A80-$0A9F`, 16 word stores) and outside the `GameOverClearFlagsLoop`; `$0AA2/$0AA3` is `abilityBitmask` (31 static operand sites) and `$0AA6` is a script scratch byte read and written by the `sp58_*` scripts.
- `$0AEC` / `$0AEE` (`enemiesRemaining` / `enemiesRemainingBcd`): 49 sites. Writers: `ClearSceneState+75 / +78` (253345 / 253348, `STX`), `InitActorFromSceneData+123 / +134` (249750 / 249761), `StandardEnemyDefeatHandler` (56231 / 56239), the boss and mini-boss scripts that `STZ` both (`ir29_castoth` 695055 / 695058, `sg55_viper`, `pyDD_mummy_queen`, `mu67_vampires`, `gw8A_sand_fanger`) and the counting copies in `EnemyDefeatDispatch` and `pyCC_mystic_ball` / `awB1_wall_walker`; readers: the last-enemy tests of the lair scripts and statues (`it1B_trial`, `mu67_bomb`, `pyDD_mystic_statue`, `ir29_transform`, `sg55_mystic_statue`, ...) and the radar screen.
- The enemy-skip path: `InitActorFromSceneData` calls `CheckEnemyDefeatedFlag` (249721) for a nonzero enemyNum and jumps over the record when the bit is set (249726), before it reaches the counter increment (249750).

| Address | Static sites that ran (offset, routine) and never-ran sites |
|---|---|
| `0A00` | ran: 45258, 45265, 45297, 45300, 45330, 191788, 191792, 192094, 253291. Never ran: 252204 `SaveGameState_Scene`, 252285 `LoadGameState_Scene`, 433951 `mu66_rama_spirits`, 640148 `ir1F_plate_gate_opener` |
| `0A80-0AA7` | wramFlags operands: 6 of 7 ran (45191, 45198, 45228, 46291, 54994, 250099); never ran: 507380 `gw88_tomb_dark_space` (`LDA $0A9F`). `abilityBitmask`: 3 of 31 sites ran (178162, 183198, 32946); `$0AA6`: 6 of 81 sites ran (the `sp58_*` scripts in scene `$58`) |
| `0AEC-0AEF` | 16 of 49 sites ran: 56224, 56231, 56235, 56239, 249750, 249754, 249761, 253345, 253348, 325831, 435254, 577047, 642962, 695055, 695058, 708153 |

## Script

Verbatim Lua. The census module `kit/lib/w1c_kit.lua` is attached in full; it needs `gaia_kit`, `a_census` (`acen`) and `a_actors` (`aact`), unchanged shared modules of `kit/lib/`. Python side: `harness/w1c_session.py` (H1 test, state load, `run_script` with `includes=["gaia_kit","a_census","a_actors","w1c_kit"]`, `turbo`; the session table of W1-a / W1-b is reused through `w1a_session` / `w1b_session`), `harness/w1c_merge.py` (merge, mapping of each K:PC to the instruction that ends there, caller decoding through `plans/flags/inventory.json`), `harness/w1c_tables.py` (the per-address tables below). Every driver text is stored in the `lua` field of its `raw/W1c_<name>_20261107.json`.

Cold boot driver (`boot_power`):

```lua
@@DRIVER:boot_power@@
```

Scene-flag driver (`f0s_15`; `f0_XX` is the same with the warp target and no form poke, `f0s_XX` pokes `$0AD4` := 2 before the load, in the harness `pokes`):

```lua
@@DRIVER:f0s_15@@
```

Induced-kill driver (`t_kill_c`; `t_kill_a`, `t_kill_b`, `t_kill_d` differ in the warp ids):

```lua
@@DRIVER:t_kill_c@@
```

Boss-reward driver (`t_boss_reward`):

```lua
@@DRIVER:t_boss_reward@@
```

Flag `#01` driver (`t_flag01`):

```lua
@@DRIVER:t_flag01@@
```

World-map clear driver (`t_wmclear`):

```lua
@@DRIVER:t_wmclear@@
```

Game-over driver (`t_gameover_lt100`; `t_gameover_ge100` pokes gems 150 instead of 0):

```lua
@@DRIVER:t_gameover_lt100@@
```

The W1-a / W1-b bot, pattern, timeline and warp drivers are unchanged except for `w1c.startC` instead of `w1b.startB`. Census module `kit/lib/w1c_kit.lua`:

```lua
@@KIT@@
```

## Positive control

Write watch on `$36` (the `INC $36` of the NMI handler, 80:8381) and exec callback on the NMI control offset 33528 (80:82F8) in every run: 103,533 `$36` writes against 103,527 NMI executions over the 108 runs; per run the two differ by at most 1 (`boot_power` 439 / 438, `chest_0E` 700 / 699, `chest_1D` 900 / 899, `n01_bot` and others). The natural replay alone: 18,847 / 18,847. Both mechanisms fire with the game's frame counter, so callbacks, the PC mapping (callback PC = address after the accessing instruction, mapped to the instruction that ends there) and frame counting work for this ROM. Second control inside the census: every watched byte with a known writer was seen from it (`$0A00` word at `ClearSceneState+21` in 164 of 164 scene setups, `$0AEC/$0AEE` at `ClearSceneState+75 / +78`, `$0A80-$0A9F` at `ClearAllWramFlags+7` and `GameOverClearFlagsLoop`).

Cold boot control (`boot_power`, 700 frames): the WRAM clear of the boot (`DmaFixedByteFill+32`, 82:9F30 region) shows as the only writer of `$0A00`, `$0A80-$0A9F` (40 byte callbacks) and `$0AEC-$0AEF` before the game writes them; its callbacks carry the PC of the `PLP` after the DMA and are not counted as code writers.

Bit-change variant (flag bytes): `0A00 bit0 change` (write, records only a write that changes bit 0 of `$0A00`, mask `0x01`) and `0A80-0AA7 change`, `0AEC-0AEF change` (write, record only a write that changes the byte; the old and new values are in the "changes" column of `raw/W1c_report.md`). Value probes record the value of the flag byte or word at the execution of an instruction (`flags00_at_ShadowIdle`, `flags00_at_ShadowActive`, `flags00_at_PlayerIdleAnimLoop`, `flags00_at_scene_flag_init`, `flags00_at_inventory_exit_set`, `flags00_at_ClearSceneState`, `enemies_at_spawn_INC`, `enemies_at_StdDefeat`). Callers of the shared flag helpers are attributed by the descriptor `i=<flag index in WRAM $0000> s=<SP+3 word>,<SP+5 word>,<SP+7 byte>`: the COP site is found in `plans/flags/inventory.json` within 9 bytes below the stacked return address of the COP handler.

## Coverage

- Census: 108 runs, 131,278 session frames, 85 distinct scenes visited, scene ids (hex, frames summed over the runs): @@SCENES@@
- Situations: all 26 `scene_flag_init` scenes for 460 frames each as Will and as Shadow (the idle poses, the shimmer and the setter on its first tick); Shadow in the two scenes that do not set the flag (`$E7`, `$E8`: `p17_E7`, `p18s_E8`); towns, dungeons with enemies (Diamond Mine `$3E/$3F`, Castoth `$29`, Moon Tribe cave `$1B`, Viper lair `$55`, the preset scenes of every chapter), the inventory overlay (`menu_inventory`, 281 loop tests, 2 exits), chests, the real world-map trip (`natural_fr10`), the cold boot, game over twice (gems below and above 100), the world-map clear, the induced kills with leave and return in four dungeon scenes, the boss-reward latch in Castoth's lair with leave and return.
- Not reached: the clears of `ClearAllWramFlags` by `st68_kara` / `sp58_red_eye` (scene `$58` ran in `p05_58` for 1,200 frames without the script reaching the call), `SetWramFlag_Offset100` by a real boss defeat (the latch was forced), `gw88_tomb_dark_space` (`LDA $0A9F`), `SaveGameState_Scene` / `LoadGameState_Scene`, `mu66_rama_spirits`, `ir1F_plate_gate_opener`, `EnemyDefeatDispatch` (0 executions of its entry, count and flag paths), the boss-script `STZ` pairs of Viper, the vampires, Sand Fanger and the Mummy Queen, an idle dispatch in the flag scenes `$15`, `$32`, `$78` (460 frames each), ladder-idle and shimmy-detach poses (no exec mark).
- Per-watch coverage statements are in the verdict table and in "Per-address census".

## Per-address census

Rows: kind (read / write of the watched byte, word accesses count once per byte), ROM offset of the instruction that ends at the callback PC (decimal), routine = nearest label + byte offset, file:line of the instruction in `extracted/`, callback count, number of scenes in which it fired. The callers of `SetEventFlag`, `ClearEventFlag`, `TestEventFlag`, `SetWramFlag`, `TestWramFlag` and `CheckEnemyDefeatedFlag` are the COP sites (or `cop?` rows where the flag index varies and the inventory has no single site) behind the shared helper.

@@TABLES@@

### Runtime versus static list

- `$0A00`: the runtime found no instruction that the static list lacks (the only extra is the boot WRAM clear). 9 of 13 static sites ran; the 4 that did not are the save / load copies and two direct readers (`mu66_rama_spirits`, `ir1F_plate_gate_opener`).
- `$0A80-$0AA7`: new compared with the static list: `SwitchCase+7` (44187, reads `$0AA6/$0AA7` through `LDA $0000,X`, 4 hits in scene `$2F`), `TestEventFlag+23` (45330, reads `$0AA2` for the COP `TestFlag_0510`, 3 hits in `menu_inventory`) and the boot clear. The wramFlags writers seen at run time are exactly `SetWramFlag+26` (16), `ClearAllWramFlags+7` (288 byte callbacks), `GameOverClearFlagsLoop` (224).
- `$0AEC-$0AEF`: new compared with the static list: only the boot clear. 16 of 49 static sites ran.

### Last-writer pairing

`raw/W1c_report.md` section "Read <- last writer pairs" pairs every read with the PC of the last write seen on the byte. The pairs that matter for the verdicts: the `CheckEnemyDefeatedFlag` read (250099) <- `SetWramFlag+26` for the enemy numbers killed before (scenes `$29 $3E $3F`, 11 skips), `TestWramFlag` (45228) at `$0AA0` <- `SetWramFlag+26` after the latch (value `$01`), the `ir29_castoth.asm` boss flag test <- the same writer, `$0AEC/$0AEE` reads of the last-enemy tests <- `InitActorFromSceneData+123 / +134` and `StandardEnemyDefeatHandler`.

## Observations

Raw log lines (trimmed to @@LOGN@@; format `<watch> <kind> <K:PC after the instruction> f=<frame> sc=<scene> a=<byte> v=<value> D=<direct page>`):

```
@@LOG@@
```

Measured tables (from `raw/W1c_report.md`, "Snapshots" and "Value probes"):

1. Flag `#00` in the 26 scenes: `scene_flag_init_set` (50794) ran 62 times in 26 scenes, and the byte was 0 before the `SetFlagByte` every time (`00@15:4 00@2B:4 00@71:4 ...`); `ClearSceneState` saw the word nonzero in 95 of its 164 executions (mostly `$0004`, flag `#02` left by South Cape, and `$0001` = `#00` of the previous scene) and wrote 0 each time (164 of 164 zeros afterwards).
2. Shimmer: `ShadowShimmerIdle` tested the flag as 1 in all 26 scenes (27 passes: once each at scene start, two in `$71`) and as 0 in `$E7` (966 tests) and `$E8` (678); `ShadowShimmerActive` tested it 6,585 times in the 26 scenes as Shadow and found bit 0 set every time (`01@71:440 01@30:340 ... 05@32:168` the value `05` has bit 0 set); it never went back to Idle.
3. Idle poses: `IdleSouth/North/West/East_flagSet` ran 116 times and `_normal` 432 times. In the 23 flag scenes that reached an idle dispatch (`$1A $1D $2B $2C $2F $30 $43 $4C-$55 $6D-$72`) the same 23 scenes show `_flagSet` in the Will sessions (`f0_XX`) and in the Shadow sessions (`f0s_XX`); `$15`, `$32` and `$78` did not reach one in 460 frames. Shadow in `$E8` (`p18s_E8`) took `IdleSouth_normal` twice and `IdleEast_normal` once with the flag clear.
4. Kills (`t_kill_a/b/c/d`): after 5 induced kills in `$3E` `$0A82` = `$1F`; in `$3F` `$0A84` = `$3E`; the counters fall 7 -> 2 (`$3E`) and 24 -> 19 (`$3F`); after leaving to the neighbour room and returning, `$3E` has 2 enemies (7 expected without the skip) and `$3F` 19 (24), `Init_DefeatedSkip_JMP` ran 11 times, and the second kills raise the bits to `$7F` / `$FE`. In `$1B` the kills ran `StdDefeat_SetDungeonKillFlag` 7 times but `SetDungeonKillFlag_handler_JSR` 0 times, `$0A80-$0AA7` stayed all zero, and the room came back with 6 enemies after 5 kills. In `$29` (Castoth) kill 1 set `$0A91` bit 0 (enemy number `$88`).
5. Clears: `t_wmclear` forced `$FF` into `$0A80-$0A9F` and `$01 $02 $04` into `$0AA0-$0AA2`; after the world-map entry `$0A80-$0A9F` = 0 (32 byte stores by `ClearAllWramFlags+7`) and `$0AA0-$0AA2` = `$01 $02 $04` (unchanged). `t_gameover_lt100` (gems 0): `GameOverClearFlagsLoop` ran 16 iterations (2 changes: `$0A80` FF -> 0, `$0A9F` 80 -> 0), `$0AA0` stayed `$01`. `t_gameover_ge100` (gems 150): the loop did not run, `$0A80 = $FF`, `$0A9F = $80` after the revive.
6. Counters: `ClearSceneState+75 / +78` wrote 0 in 164 of 164 setups (33 of them over a nonzero value); `InitActorFromSceneData+123 / +134` incremented 830 times (the counters reach 24 = `$0018` and BCD `$24` in `$3F`), and the same counts reappear after every re-entry minus the skipped records; `StandardEnemyDefeatHandler` decremented both 22 times (`0005 -> 0004 ...` in the value probe).
7. Flag `#01` (`t_flag01`): in `$01` the word read `$0004`, then `$0106` after the force; `ClearSceneState` (`0A00 write 83:DD6E`) wrote 0 at the setup of `$15`; in `$15` `TestEventFlag` read the byte 50 times, always with bit 1 (flag `#01`) clear (`$00` once, `$01` 49 times: bit 0 is `#00`, set by `scene_flag_init` at `80:B0D4`), and the scene sequence is `$01` -> `$15` -> `$FE` -> `$15`: the Itory exit fired 253 frames after the entry.
8. Boss flag (`t_boss_reward`): `TestWramFlag_Offset100` at the Castoth entry read `$0AA0` = 0 at the scene start; after the latch `boss_clear_reward_handler` (D = `$10F0`) called `SetWramFlag+26` and `$0AA0` went 00 -> 01; the bit stayed 1 in `$28` and after the return to `$29`; after the latch `STZ $enemiesRemaining` / `STZ $enemiesRemainingBcd` of the Castoth entry (695055 / 695058) ran twice (one changed the counter, 01 -> 00).

## Verdicts

Grade key: VERIFIED-RUNTIME = the census measured it; VERIFIED-STATIC = read from the code, no run needed or possible; CONTRADICTED = the census measured the opposite of a shipped sentence; INCONCLUSIVE = no hit and the coverage does not reach the path (the path is named).

| ID | Verdict (plain sentence) | Grade | Note shipped today (file:line, if any) | Action |
|----|--------------------------|-------|----------------------------------------|--------|
| OQ-I030-1 (a) | Event flag `#00` does not follow the character form. It selects the idle sprite family: with it set the player idle handlers stage sprite `#10`-`#13` (animation `$11` in `PlayerIdleAnimLoop`), with it clear `#00`-`#03` (`$01`). In the 23 flag scenes that reached an idle dispatch both Will (`f0_XX`) and Shadow (`f0s_XX`) took the set path (`IdleSouth/North/West/East_flagSet`, 116 runs in all); Shadow with the flag clear (`$E8`, `p18s_E8`) took `IdleSouth_normal` twice and `IdleEast_normal` once. Not reached: an idle dispatch in `$15`, `$32` and `$78` within 460 frames. | CONTRADICTED | `player_character.asm:232` "South idle: check Shadow flag byte → select normal (#00) or Shadow (#10) sprite" (also `:238`, `:244`, `:250`, `:256`, `:262`, `:268`, `:274`), `SetPlayerIdleFacing.asm:5` "the IdleStand* handlers themselves branch on the Shadow flag byte #00", `player_character.asm` block note "IdleStand* (8 directional × Shadow variants)"; the names `IdleStand*Shadow`, `PlayerIdleUseShadowSprite` | merge: `specs/W1-c_notes.json`; names: `specs/W1-c_names.json` |
| OQ-I030-1 (b) | Setters and readers of flag `#00` at run time: `scene_flag_init` sets it on its first tick in all 26 scenes (62 of 62 over a clear byte); `sc01_fisherman` sets (13) and clears (14) it in `$01`; `inventory_menu` sets it (2, scene `$FF`); `ClearSceneState` clears it with the whole word at every scene setup (164 of 164). The inventory overlay clears the word on opening (`OpenInventoryScreen+46`), loops on flag `#00` (281 tests) and restores the saved word on closing (`+348`, values 0 and 4). Not reached: the other script setters (`dm3D_breakable_wall`, `ir1E_cliff_slide_trigger`, `eu9D_altar`, `dm40_trapped_slave`, `av73_waterfall_sound`, `btE1_light_elevator`, `av75_apprentice`). | VERIFIED-RUNTIME | `scene_flag_init.asm:7` lists the setters and "inventory_overlay (loops until it is nonzero)" agree | none |
| OQ-I030-1 (c) | Why the 26 scenes set the flag (the pose the indexes `#10`-`#13` show in Will's body table; whether it is an intended "weapon holstered" idle) is not determined: the mechanism is measured, no screenshot of the pose was taken. Not reached: a visual comparison of the idle pose with the flag set and clear. | INCONCLUSIVE | `scene_flag_init.asm:7` "What the set flag means is not traced" | merge states the measured effect (spec); purpose stays open |
| OQ-I052-1 | `PlayerIdleAnimLoop` stages anim `$11` when flag `#00` is set and `$01` when it is clear and tests nothing else: scene `$1D` (`chest_1D`) took the set branch (`PlayerIdleAnimLoop_flagSet`, flag 1) and scene `$29` (`castoth_melee`, `t_boss_reward`, `t_kill_d`) the clear branch (3 runs, flag 0). The meaning of the flag is OQ-I030-1 (a). | VERIFIED-RUNTIME | `player_transition_handlers.asm:45` "What flag #00 means is not traced." ; comment 50226 agrees | merge: part note `PlayerIdleAnimLoop` |
| OQ-I048-1 (a) | In all 26 `scene_flag_init` scenes, as Shadow, the shimmer goes to Active at the scene start and stays there: `ShadowShimmerIdle` read flag `#00` = 1 in each of the 26 scenes (27 passes), `ShadowShimmerActive` read it 6,585 times and saw bit 0 set every time (`$05` in `$32` has bit 0 set); no return to Idle in any of the 26 scenes (460 frames each). Scenes `$E7` / `$E8`, which do not set the flag, read 0 in Idle (966 and 678 passes). | VERIFIED-RUNTIME | `shadow_shimmer.asm:68` comment "Flag byte #00 == 0: back to Idle"; part notes `ShadowShimmerIdle` / `ShadowShimmerActive` agree | none |
| OQ-I048-1 (b) | Shadow takes the alternate idle handlers in the flag scenes: `IdleSouth/North/West/East_flagSet` ran in the `f0s_XX` sessions of the same 23 scenes as in the Will sessions. Not reached: the idle dispatch in `$15`, `$32`, `$78` within 460 frames, and the visual check of the sprite. | VERIFIED-RUNTIME | `player_character.asm:232` (see OQ-I030-1 (a)) | merge: same edit |
| OQ-67 (a) | A kill with a nonzero enemy number stays: after induced kills in `$3E`, `$3F` and `$29` the bit is set in `$0A80+`, survives leaving to the neighbour room and returning (values unchanged), and on re-entry `CheckEnemyDefeatedFlag` skipped the record 11 times (`Init_DefeatedSkip_JMP`): `$3E` returned with 2 enemies, `$3F` with 19 of 24. | VERIFIED-RUNTIME | `flag_helpers.asm:11`, `CheckEnemyDefeatedFlag` part note, `cop_handlers_dungeon_switch` block note ("a kill can outlive the room") agree | none |
| OQ-67 (b) | `wramFlags` is cleared on entering the world map: forced `$FF` in `$0A80-$0A9F` became 0 by 32 byte stores of `ClearAllWramFlags+7` in `$FE` (16 word iterations). | VERIFIED-RUNTIME | `flag_helpers.asm:11` agrees | none |
| OQ-67 (c) | `wramFlags` is cleared by a real game over (gems below 100): `GameOverClearFlagsLoop` (54994) zeroed `$0A80` and `$0A9F`; with 100 or more gems (revive) the loop did not run and the flags stayed. | VERIFIED-RUNTIME | `game_over_sequence.asm` block note "gemCount >= 100 (revive): ... Form and wramFlags are kept" agrees | none |
| OQ-67 (d) | The clears by `st68_kara` and `sp58_red_eye` (the two COP `ClearAllWramFlags` callers) did not run. Not reached: those scripts (scene `$58` ran 1,200 frames in `p05_58` without reaching the call; `st68_kara` was not visited). | INCONCLUSIVE | `flag_helpers.asm:11`, `ClearAllWramFlags` part note name both callers | none; confirm in a scene `$58` / `st68` playthrough |
| OQ-67 (e) | An enemy with enemyNum 0 sets no bit and is spawned again on every entry: in `$1B` 5 induced kills ran `StdDefeat_SetDungeonKillFlag` 7 times, the COP handler's `JSR SetWramFlag` (44172) 0 times, `$0A80-$0AA7` stayed all zero, and the room came back with 6 enemies. | CONTRADICTED | `StandardEnemyDefeatHandler.asm` block note "SetDungeonKillFlag (the enemyNum bit in wramFlags, so the enemy stays dead on re-entry)" and comment 56306 "Set this enemy's bit in wramFlags (it stays dead on re-entry)" | merge: block note, comment 56306 |
| OQ-68 (a) | `$0AA0` is outside the block both clears wipe: after the world-map clear and after a real game over `$0AA0` kept `$01` (the world-map clear also left `$0AA1-$0AA2` = `$02 $04`). | VERIFIED-RUNTIME | `TestWramFlag_Offset100` / `SetWramFlag_Offset100` part notes, comment 45154 agree | none |
| OQ-68 (b) | `$0500-$050F` are not used by any other COP flag operand: `plans/flags/inventory.json` has no `SetFlagByte/Word` or `BranchOnFlag*` operand in `$0400-$053F` other than the six lair `TestWramFlag_Offset100` sites (indices `$0500-$0504`); no instruction names `$0AA0` or `$0AA1` apart from the `Offset100` helpers and `boss_clear_reward_handler`; the COP `TestFlag_0510` reads `$0510` (byte `$0AA2` bit 0, an ability bit) just above the range. | VERIFIED-STATIC | `flag_helpers.asm:28-42` agree | none |
| OQ-68 (c) | The write happens: with `playerFlags` bit `$0020` forced in Castoth's lair, `boss_clear_reward_handler` called `SetWramFlag+26` (45198) once (D = `$10F0`, caller descriptor `s=B072,C30B,80`) and `$0AA0` went 00 -> 01; the bit survived the scene change to `$28` and back; the `STZ` pair of the Castoth entry code (695055 / 695058, after `TestWramFlag_Offset100` with index 0) ran after the latch and zeroed both enemy counters. The readers ran only in scenes `$29` and `$55` (the boss-reward actor and Castoth: `$0AA0` read as 0 before the latch); the lair scripts of Viper, the vampires, Sand Fanger and the Mummy Queen did not run their tests. Not reached: a real boss defeat (the latch was forced) and the other four bosses. | VERIFIED-RUNTIME | `SetWramFlag_Offset100` part note ("the only caller is boss_clear_reward_handler") agrees; `ir29_castoth.asm` block note has no sentence on the entry test | merge: block note `ir29_castoth` |
| OQ-I042-7 | Flag `$01` is never left set when scene `$15` starts: `ClearSceneState` zeroes flags `$00-$0F` with the word at every scene setup (164 of 164); with flags `#01` and `#08` forced in `$01` (`$0106`), the word was written 0 at the setup of `$15` and the Itory exit fired (`$15` -> `$FE`). Inside `$15` only `it15_lily` sets `#01` (320263, after the palette flash) and clears it (320308); `it15_kara` waits for it. Not reached: the `it15_lily` setter at run time (the cutscene was not triggered), so the in-scene window (exit disabled) is read from the code. | CONTRADICTED | `overworld_exit.asm:210` "Flag $01 set (set by many unrelated scripts): exit disabled"; block note QUIRKS "$01 is set by unrelated scripts (angel_village, undersea_tunnel, great_wall floor buttons); whether it is cleared on scene load was not traced." | merge: block note, comment 52010 |
| OQ-I054-2 (a) | The counters are initialised in two steps: `ClearSceneState+75 / +78` zero both at every scene setup (164 of 164), then `InitActorFromSceneData+123 / +134` add one to each per spawned enemy with stats (830 runs; e.g. 24 / `$24` in `$3F`). | VERIFIED-RUNTIME | `InitActorFromSceneData` part note agrees; `ClearSceneState` part note does not name the counters | merge: part note `ClearSceneState` |
| OQ-I054-2 (b) | Enemies that stay dead are not counted on re-entry: the skip (`Init_DefeatedSkip_JMP`, 11 times) runs before the increment, so `$3E` returned with 2 (not 7) and `$3F` with 19 (not 24) enemies, and the last-enemy path is reached after the remaining ones die. Enemies with enemyNum 0 come back and are counted again (`$1B`: 6 after 5 kills). | VERIFIED-RUNTIME | `CheckEnemyDefeatedFlag` / `InitActorFromSceneData` part notes agree | none |

Counts: 11 VERIFIED-RUNTIME, 1 VERIFIED-STATIC, 3 CONTRADICTED (OQ-I030-1 (a), OQ-67 (e), OQ-I042-7), 2 INCONCLUSIVE (OQ-I030-1 (c), OQ-67 (d)); 17 rows for 7 ids. Ids with every half VERIFIED-RUNTIME, VERIFIED-STATIC or CONTRADICTED and no INCONCLUSIVE half: OQ-I052-1, OQ-I048-1, OQ-68, OQ-I042-7, OQ-I054-2. Ids with an INCONCLUSIVE half: OQ-I030-1 (purpose of the flag scenes) and OQ-67 (the two script clears).

Pass criterion (every watched address has a reader / writer table, a coverage statement, and every id a verdict with the INCONCLUSIVE rows naming the unreached path): met; two ids stay partly open.

## Tool issues

None. The `run_script` / `load_script` / `play_input` / `get_script_result` / memory callbacks behaved as documented and the positive controls agree. Nothing was added to `tool-issues.md`.

## Notes spec

`plans/extracted-audit/mesen2-results/specs/W1-c_notes.json` (merge spec, 8 files). Dry run: `npm run merge -- plans/extracted-audit/mesen2-results/specs/W1-c_notes.json --dry-run` prints `OK`, 7 notes files would change (`notes/blockNotes/bank00.json`, `bank02.json`, `bank0A.json`, `notes/partNotes/bank00.json`, `bank03.json`, `notes/comments/bank00.json`, `bank02.json`). Edits: `overworld_exit.asm` block note + comment 52010; `scene_flag_init.asm` block note (two sentences); `player_character.asm` block note + comments 181375, 181386, 181391, 181402, 181407, 181418, 181423, 181434; `SetPlayerIdleFacing.asm` block note; `player_transition_handlers.asm` part note `PlayerIdleAnimLoop`; `StandardEnemyDefeatHandler.asm` block note + comment 56306; `scene_lifecycle.asm` part note `ClearSceneState`; `ir29_castoth.asm` block note.

`plans/extracted-audit/mesen2-results/specs/W1-c_names.json` (names spec, 5 renames: `IdleStandSouth/North/West/EastShadow` -> `IdleStand*Flagged`, `PlayerIdleUseShadowSprite` -> `PlayerIdleFlaggedAnim`). Dry run: `npm run names -- plans/extracted-audit/mesen2-results/specs/W1-c_names.json --dry-run` prints 5 renames, 7 files would change (references in `docs/code/bank02/player-character.md`, `notes/blockNotes/bank14.json`, `notes/partNotes/bank00.json`, `bank0E.json`, `bank15.json`). The `ShadowShimmerIdle` / `ShadowShimmerActive` names stay: they name the states of the shimmer actor of Shadow, which the census confirms.

Docs outside `extracted/` and `notes/` that repeat the wrong sentences (not edited, outside the allowed write set; list them for the apply pass): `docs/cop/families/player_sprite.md:127-135` ("idle row selection by form", "Shadow `#10`-`#12`", the example with `ShadowSouthIdle`), `docs/code/bank02/player-character.md` (the `IdleStand*Shadow` labels, 4 references), and any doc that says the Itory exit flag `$01` is set by other scenes' scripts.

## New questions

(text only; ids are assigned by Z1)

1. What do the idle sprites `#10`-`#13` and anim `$11` show for Will and for Freedan in the 26 `scene_flag_init` scenes (a pose from the form's body table, or a Shadow-set index that Will reuses), and which design reason puts them in those 26 scenes (towns and cutscene rooms)?
2. `gw88_tomb_dark_space` reads `$0A9F` directly and acts when it equals `$3F` (enemy numbers `$F8`-`$FD` defeated): does the Great Wall tomb room need those six kills in one visit or across visits, and is the kill flag cleared by a world-map entry before the player gets there?
3. Which enemies have enemyNum 0 (they return on every entry, e.g. the Moon Tribe cave `$1B` group): is the list the same as the enemies the design wants to respawn, and does the room's last-enemy reward still work for them?
4. A boss with the reward flag set is removed on entry (Castoth: counters zeroed and `Die`): does the same entry test exist in Viper, the vampires, Sand Fanger and the Mummy Queen (their `STZ` pairs did not run), and what happens to the boss arena exit and the next-scene triggers in that case?
5. `ClearAllWramFlags` from `st68_kara` and `sp58_red_eye`: in which story state do they run, and do they wipe kill flags the player still needs (Viper, Dark Space)?
6. The ladder-idle (`LadderIdle*Shadow`, sprites `#2E` / `#2F`) and shimmy-detach variants test the same flag `#00`: do they also take the flag-set branch for Will in the 26 scenes (ladders exist only in a few of them)?

## Next step

Z1 for the CONTRADICTED and VERIFIED rows: apply `specs/W1-c_names.json` first (`npm run names`), then `specs/W1-c_notes.json` (`npm run merge`) after review, then `extract:lt` and `rebuild`; a scene `$58` / `st68` playthrough or a forced run of the two `ClearAllWramFlags` script callers for OQ-67 (d); a screenshot pair of the idle pose with flag `#00` set and clear (W2 visual) for OQ-I030-1 (c).
