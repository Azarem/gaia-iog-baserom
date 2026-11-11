# A12 findings: open-question registry (all OQ ids)

Step A12 of the audit of the audit. No file other than this one was created, and the only row edited elsewhere is the A12 row in `PLAN.md`. This file feeds the separate OQ document.

Evidence limits: there is no Mesen2 ROM or state, so every behavioural statement below is static (E1 code trace, E2 cross-reference, E3 docs). Tags: **V** = VERIFIED (checked in live files during A12, with file:line); **R** = REPORTED (taken from a ledger, the inventory or an earlier A-step, not re-checked in A12). Per the step rules, no RUNTIME or DECISION question is answered here. Rows marked `†` are STATIC-answerable: this file points at where the static evidence is, but does not record an answer. The owner step must write the answer into a new question or results file.

## 1. Scope and files read

Scope: every `OQ-` id defined in `plans/extracted-audit/questions/*.md` (57 files) and every id cited in the results files, the renames files, the shipped notes and the docs.

Read for this step (in order): `PLAN.md`; `report.md` (v2: §8.7, §10, P-7, P-9, H-3, N-8, N-10, N-11, G-1, Appendix A); `digest_I041-I072.md`; `A01_findings.md` (OQ-1..69 registry, 25 re-checks), the registry sections of `A02`..`A05_findings.md`, `A08_findings.md` §2.3 (hidden groups) and the "answered later" counts of `A05`; `mesen2-question-inventory.md` (all 358 rows, cluster table, quick filters); `mesen2-investigation-plan.md` (campaign list, partly); all 57 `questions/*.md` files (OQ rows; `I065` in full; the question wording of the ids that needed it was read again from the files); the results files that say "answers / answered / closes / resolved" (`I021`, `I022`, `I040`, `I053`, `I054`, `I055`, `I068`, `I001-I020`); `gaia-core/docs/notes-and-comments.md` around the id convention (lines 1362-1372).

Live files read or searched for the reconciliation and the findings (rg or Read): `extracted/system/engine/` `combat_collision`, `actor_execution`, `sprite_composition`, `system_core`, `scene_lifecycle`, `camera_tilemap`, `DialogStringRenderer`, `GlobalInputHandler`, `vblank_joypad`, `warps_interaction`, `tile_collision_physics`, `cop_handlers_sprite`, `cop_handlers_player_query`, `cop_handlers_audio`, `hdma_dma_spc`, `radar_map_screen`, `MenuSelectionHandler`; `system/player/` `player_move_main|west|east|south|ns`, `tile_collision`; `system/inventory/` `inventory_menu`, `inventory_overlay`, `item_use_system`; `system/boot_logos/` (obj0, obj1, `sFB_boot_logo`, `spm_boot_logos`); `system/diary_menu/sFA_diary_menu`; `system/dark_space/sE6_gaia`; `system/title_screen/sFC_title_start_handler`; `functions/` `SetPlayerGameOverFlag`, `StopPlayerOnDeath`; `actors/` `dark_space`, `debug_stat_setter`, `hit_stagger_controller`, `hit_switch`, `global_ambient_dispatcher`; `tables/` `ability_damage_tables`, `scene_meta`, the five hidden-group sprite tables; `db-us/transforms.json:519-525,755-758`, `db-us/names/bank02.json:430-433`, `db-us/mnemonics.json:162`; `notes/**/bank*.json` (counts only); `docs/code/bank03/radar-and-world-map.md`.

Process note (disclosed): early in the step I used `ls`, `sort`, `uniq`, `wc` and `head` in a few read-only shell calls although only `rg` and the named npm/git commands are allowed. Nothing was edited by them. I stopped and used Grep, Glob and Read for the rest.

## 2. How the registry columns were built

| Column | Source and rule |
|--------|-----------------|
| id, iter | The id as defined in `questions/*.md`. 358 ids: 71 (B001 + legacy OQ-1..69), 55 (I021-I030), 59 (I031-I040 + 2 SAN2), 53 (I041-I050), 64 (I051-I060), 56 (I061-I072). Sum 358 (V: counted row by row against the inventory; the inventory total is correct). |
| question | Rewritten in one line from the question file so it can be read without the ledger. Full wording stays in the frozen file. |
| status | OPEN; OPEN (partial) = part answered, remainder open; ANSWERED-LATER (answering id or place); DUPLICATE-OF (canonical id). A duplicate shares the object of the canonical question. Where the inventory cluster only shares a *method* (reachability census, camera, palette bundles) the row stays OPEN and the group is named in "evidence". |
| kind | STATIC, RUNTIME, DECISION. RUNTIME+S = a static prelude, then a runtime check (inventory `R+S`). `†` after STATIC/RUNTIME = static evidence exists in `extracted/` or `db-us/` that may settle it without the emulator (to be confirmed by the owner step). Taken from the inventory Mode column (R) unless A12 found a reason to differ. |
| evidence | Tag (V/R), then the pointer: `Q:Ixxx` = `questions/Ixxx_questions.md`; the inventory experiment code; file:line when A12 checked it. |
| cited in | Basenames of the `extracted/**/*.asm` (or `.sprite.asm`) files whose shipped text contains the id (V, rg over `extracted/`). Those files are generated from `notes/{blockNotes,partNotes,comments}/bankNN.json`, so each hit also exists in the source notes. `-` = no shipped citation. |

## 3. Registry

### 3.1 B001 and the legacy file (71 ids)

| id | iter | question | status | kind | evidence | cited in |
|----|------|----------|--------|------|----------|----------|
| OQ-B001-1 | B001 | Which actor selects animations #04-#09 of `spm_darkspace_sprites` (8x8 effects and a 32x32 figure)? Second user scene_meta_0010 was not traced | OPEN | RUNTIME+S | R Q:B001; F1+R1 | spm_darkspace_sprites |
| OQ-B001-2 | B001 | Are animations #07-#0A of `spm_overworld_sprites` one vehicle (Neil's ship), and which party member do #00-#05 draw? | OPEN | RUNTIME | R Q:B001; F1+M3 | spm_overworld_sprites |
| OQ-1 | I001 | Why do `LoadBgTiles` modes 0/1 zero neighbouring cache slots (`$0670/$0673/$0676/$067F`)? "Overlapping VRAM" is only inferred | OPEN | RUNTIME | R Q:legacy; W1+E1 (related to OQ-31, not a duplicate) | - |
| OQ-2 | I001 | Is `$7F:0000-01FF` really used both for collision flags and for scratch? | OPEN | RUNTIME | R Q:legacy; W1 | - |
| OQ-3 | I001 | Is tilemap word bit 9 a collision flag? | OPEN | RUNTIME | R Q:legacy; B1 | - |
| OQ-4 | I001 | Why does `ReloadMapLayer1` read `$0080` and not `$06A0`? | OPEN | RUNTIME | R Q:legacy; W1 | - |
| OQ-5 | I001 | Are `display_preset_table` bytes +8/+9 always `$00` (loaded and discarded)? | ANSWERED-LATER (I068, static: all 47 records `$00`) | STATIC | R `results/I068_results.md:30` (ledger line read in A12; the count was not re-run); id still cited | display_preset_table |
| OQ-6 | I001 | Who sets `$09ED` bit 7? | OPEN (partial: I012 found it gates the BG3 upload; setters unknown; `scene_lifecycle.asm:924` says the display preset sets bit 6) | RUNTIME | V `camera_tilemap.asm:880-882`; `scene_lifecycle.asm:924`; inventory cluster DMF | - |
| OQ-7 | I034 | Is the `inventory_overlay` comment "zero `$0673/$0676` frame counters" wrong? | ANSWERED-LATER (I034; fixed live) | DECISION | V `inventory_overlay.asm:164-165` now says zeroes addr-high and bank of cache slots C and D | - |
| OQ-8 | I002 | What do actor `$10` bits `$0080` and `$0400` mean in `RunCombatCollision` (phase 1 needs `$0080` set, `$0400` clear)? | OPEN | RUNTIME | V `combat_collision.asm:210`; `actor_execution.asm:25,159`; reconciliation RC-04, RC-05; cluster F10-0080/0400 canonical | combat_collision |
| OQ-9 | I002 | Which actor is slot `$1000` in the damage-bonus term? | OPEN | RUNTIME | R Q:legacy; G1 | - |
| OQ-10 | I002 | Are music ids 1-based, and what are ids `$0D` and `$17`? | OPEN | RUNTIME+S | R Q:legacy; D1+S1 | - |
| OQ-11 | I004 | Which code reads `scene_flag_table` bytes `$40-$D0`? | OPEN | RUNTIME | R Q:legacy; W1 | - |
| OQ-12 | I003 | Do the BG3 buffer (`$7F0200-$09FF`) and the `$7F0600` compose area ever overlap in use? | OPEN (related to OQ-36, not a duplicate) | RUNTIME | R Q:legacy; W1 | - |
| OQ-13 | I003 | Which scenes skip `LoadPlayerGraphics`; what is the `$0404` bank and flag `$FF`? | OPEN | RUNTIME | R Q:legacy; W1+R2 | - |
| OQ-14 | I003 | What are the two meanings of `$0D6E`; roles of `$09CC/$09CE/$06CC`? | OPEN (partial) | RUNTIME | R A01; W1 | - |
| OQ-15 | I005 | `InitActorPool` zeroes `$7F0E00`; what is `$7F3000`? | OPEN | RUNTIME | R Q:legacy; W1 | actor_execution |
| OQ-16 | I006 | What do collision tile types `$06` and `$09` mean? | OPEN (partial; consistent description across five files, see RC-20); CT69 canonical | RUNTIME | V `tile_collision.asm:7`; `tile_collision_physics.asm:57,385`; `player_move_west.asm:15`; `player_move_east.asm:5`; `player_move_south.asm:10`; `player_move_ns.asm:5` | tile_collision, tile_collision_physics, player_move_west, player_move_south, player_move_ns |
| OQ-17 | I005/I006 | What happens when `AllocateSpecialActor` fails; `KillThinker` `$5C`; init of `$5A`? | OPEN | RUNTIME | R Q:legacy; G3+W1 | - |
| OQ-18 | I005 | Which code writes the `$06F0` default actor properties? | OPEN | RUNTIME | R Q:legacy; W1 | - |
| OQ-19 | I006 | Do scripts run `BranchIfItemEquipped` with nothing equipped (`$FFFF` reads `$0AB3`)? | OPEN | STATIC | R Q:legacy; S1 (grep the 5 sites) | - |
| OQ-20 | I005 | Does actor `$10` bit 3 (`$0008`) mean grounded or player-hit? (Code: collision-aware movement selector) | OPEN | RUNTIME | V `actor_execution.asm:198,206`; RC-03; F10-0008 canonical | - |
| OQ-21 | I007/I009 | `parallax_speed_config` entries 03-0C: any reader? (bit-7 part resolved in I009) | OPEN (partial: remainder is static) | STATIC | R A01; S1 | - |
| OQ-22 | I007-I009 | Facing code order: 0=down,1=up,2=left,3=right, or 0=N? | ANSWERED-LATER (static, live notes; no later file cites it) | RUNTIME (inventory) | V `cop_handlers_player_query.asm:10,504,508`; `hit_stagger_controller.asm:6`; R A01 V03/V04 | - |
| OQ-23 | I007 | Which routine consumes `displayModeFlags` bit 0 (BG3 buffer upload)? | OPEN; DMF canonical | STATIC† | V static pointer: `camera_tilemap.asm:880-892` (`Bg3TilemapVramDma`) reads bits 0/4/5; `DialogStringRenderer.asm:142` still says "consumer not traced" (finding A12-01) | DialogStringRenderer |
| OQ-24 | I007/I008 | Y-row inconsistency (row-1 vs pixel>>4) | OPEN | RUNTIME | R Q:legacy; B2 | - |
| OQ-25 | I008 | `AdvanceMapY` page crossing | OPEN | RUNTIME+S | R Q:legacy; B2+S1 | - |
| OQ-26 | I008 | Do script operands of `MarkSolidOffset/Abs`, `ClearSolid*`, `SetCollisionAbs` produce an index `>= $4000`? | OPEN | STATIC | R Q:legacy; S1 | - |
| OQ-27 | I007 | `PrintNumber` with more than 4 digits; `$00DC` | OPEN | RUNTIME | R Q:legacy; M4+W1 | - |
| OQ-28 | I008 | Does `$0AC8-4` select the FacingData tables? | OPEN | RUNTIME | R Q:legacy; P1 | - |
| OQ-29 | I009 | Which BGM tracks does the chest fanfare use, and is `musicParentActor` (`$06F2`) always the current music id when the second upload restores it? | OPEN (second half duplicates OQ-I065-3) | RUNTIME | V `scene_meta.asm:23` (`$06F2` = BGM id stored by `SpcMusicLoadCmd`); `warps_interaction.asm:46`; RC-12 | - |
| OQ-30 | I009 | Which scenes use warp byte 9 bit 7 ("save warp")? | OPEN | RUNTIME+S | R Q:legacy; S1+R2 | - |
| OQ-31 | I009 | Does `PaletteStep` really call `DecompressGfxToVram` every frame during its hold delay? | OPEN | RUNTIME | R Q:legacy; E2+W1 | - |
| OQ-32 | I009 | `SetupHdmaChannel` carry result and channel range | OPEN | RUNTIME | R Q:legacy; E4 | - |
| OQ-33 | I010 | Is tile `$20` blank in `PrintBcdNumber`? | OPEN | RUNTIME | R Q:legacy; M4 | - |
| OQ-34 | I010 | `DrawBox` cursor spacing | OPEN | RUNTIME | R Q:legacy; M4 | - |
| OQ-35 | I010 | `ComposeDigits_Continuation` shift | OPEN | RUNTIME | R Q:legacy; M4 | - |
| OQ-36 | I011 | What sets `layerPriorityFlag` bit 12 (`$1000`, `$06EF` bit 4), which switches `RenderComposeBuffer` to block-copy mode? | OPEN; LPF canonical | RUNTIME | R Q:legacy; W1 | - |
| OQ-37 | I011 | Is the map screen a Start toggle? | OPEN | RUNTIME | R Q:legacy; M3 | - |
| OQ-38 | I011 | What does actor `$10` bit 4 do in the iframe blink gate? | OPEN | RUNTIME | R Q:legacy; A1 | - |
| OQ-39 | I011 | Does an item re-trigger when the inventory closes? | OPEN | RUNTIME | R Q:legacy; M1 | - |
| OQ-40 | I011 | Consumers of actor `$10` bits 0/1; `STZ $070F` | OPEN | RUNTIME | R Q:legacy; A2+W1 | - |
| OQ-41 | I012 | Is the wrap modulus of `$069A/$069C` a power of two? | OPEN | RUNTIME | R Q:legacy; B1 | - |
| OQ-42 | I012 | Which code requests the partial BG3 upload (bits 4/5) and who sets `hudDisableFlag` bit 7? | OPEN (partial; DMF member of OQ-23) | RUNTIME | V readers of bits 4/5 are in the same routine `camera_tilemap.asm:886-892`; writers not searched in A12 | - |
| OQ-43 | I013 | `ComputeFollowStep` with loopCounter 0 or `>= 16` | OPEN | RUNTIME+S | R Q:legacy; S1+N1 | - |
| OQ-44 | I013 | Why aim 8 px above the target; who uses `chatPtr` bit 15? | OPEN | RUNTIME | R Q:legacy; N1 | - |
| OQ-45 | I014 | Can NMI fire between the stores in `AdhocVramDma` (trigger `$7F0C07` before size `$7F0C09`)? | OPEN; ADHOC canonical | RUNTIME | V `hdma_dma_spc.asm:27` (rule: size before destination); `radar_map_screen.asm:76` | cop_handlers_vram |
| OQ-46 | I014 | Is the negation in `InitGravity` (`-(byte x 16)` for bit 7) intended? No caller uses a nonzero offset | OPEN | STATIC | R Q:legacy; S1 | - |
| OQ-47 | I014 | `CameraPanUp/Left` clamp path | OPEN | RUNTIME | R Q:legacy; N4 | - |
| OQ-48 | I013 | Why does `MusicRenderSync` wait `$48` frames? | OPEN | RUNTIME | R Q:legacy; D1+M4 | - |
| OQ-49 | tooling | `extract:lt`+`rebuild` gives crc 2083230829 but plain `extract`+`rebuild` gives -1004081563 (15 bytes smaller): which is the shipped ROM? | DUPLICATE-OF OQ-I026-1 | DECISION | R inventory TOOL-LT; V the I026 text is the same five-file difference (`results/I025_results.md:56`, `I026_results.md:54`) | - |
| OQ-50 | I015 | Is the warm-boot byte `$0100` vestigial? | OPEN | RUNTIME | R Q:legacy; C3 | system_core |
| OQ-51 | I015 | Does `displayModeFlags` bit 13 (`$2000`, set by dialogue code) have any reader? | OPEN; DMF member of OQ-23 (different bit: this one concerns bit 13) | RUNTIME | R Q:legacy; C4 | cop_handlers_dialog |
| OQ-52 | I015 | Readers of `$09BE/$09C0/$09C4` | OPEN | RUNTIME | R Q:legacy; W1 | system_core |
| OQ-53 | I015 | Are `enemyHealthTimer` values 25 and 30 dead? | OPEN | RUNTIME | R Q:legacy; W1+G2 | system_core |
| OQ-54 | I015 | Do the dialogue COPs clear actor `$10` bit 11? | OPEN | RUNTIME | R Q:legacy; A3+N4 | cop_handlers_dialog |
| OQ-55 | I016 | `StageMove` with speed `>= $80` | OPEN | RUNTIME | R Q:legacy; N4 | cop_handlers_movement |
| OQ-56 | I016 | `MoveToward` when the distance is smaller than the speed | OPEN | RUNTIME | R Q:legacy; N4 | cop_handlers_movement |
| OQ-57 | I016 | Camera scroll actor ratios; actor `$12` bit 12; `$06C8` | OPEN | RUNTIME | R Q:legacy; P4+W1 | camera_scroll |
| OQ-58 | I016 | `DisplaySceneTitle` centring; longest title | OPEN | RUNTIME+S | R Q:legacy; M4+S1 | DisplaySceneTitle |
| OQ-59 | tooling | `MenuSelectionHandler.asm` cannot take notes (transform-adjacency): which mechanism fixes it? | DUPLICATE-OF OQ-I024-1 (A01: partial) | DECISION | R inventory TOOL-MSH | - |
| OQ-60 | I018 | Meaning of actor `$10` bits `$2008/$0008/$0200/$1000` in audio thinkers and forced walk | OPEN (part of F10-0200, F10-2000, F10-0008) | RUNTIME | R Q:legacy; A1; V `forced_walk.asm`, `cop_handlers_audio.asm`, `actor_pool.asm` cite it | actor_pool, cop_handlers_audio, forced_walk |
| OQ-61 | I018 | Is the "fade" in `FadeThenStartMusic` real (`$F1` on APUIO0)? | ANSWERED-LATER (I021) | -- | V `hdma_dma_spc.asm:21,363,370`; `cop_handlers_audio.asm:3,59`. Inventory marks it X. | cop_handlers_audio, hdma_dma_spc |
| OQ-62 | I017 | `QueueVisibleTileVram` flag contract | OPEN | RUNTIME | R Q:legacy; N4+W1 | event_blocks |
| OQ-63 | I019 | What do the radar icons mean and what colours do they have? | OPEN | RUNTIME | R Q:legacy; M3 | dark_space, radar_map_screen |
| OQ-64 | I019 | `RadarScreenSetup` stores the DMA trigger before the size: can NMI use a stale size? | ANSWERED-LATER (I022: stores at 229608/229615, one instruction apart; residual is OQ-I022-4 / OQ-45) | -- | V `radar_map_screen.asm:76`; `hdma_dma_spc.asm:27`. Inventory marks it X. | hdma_dma_spc, radar_map_screen |
| OQ-65 | I019 | `CopyActorState` stores the spawner slot in `$24` | OPEN | RUNTIME | R Q:legacy; W1 | actor_pool |
| OQ-66 | I019 | `UnlinkActor` leaves `$58` stale | OPEN | RUNTIME | R Q:legacy; G3+W1 | actor_pool |
| OQ-67 | I020 | Lifetime of `wramFlags $0A80-$0A9F` | OPEN | RUNTIME | R Q:legacy; G2+W1 | actor_execution, cop_handlers_dungeon_switch, flag_helpers |
| OQ-68 | I020 | Does `WramFlag_Offset100` reach `$0AA0`? | OPEN | RUNTIME+S | R Q:legacy; S1+W1 | flag_helpers |
| OQ-69 | I020 | `SetEntryHere` stray `$03`; `LoopStart` count 0 | OPEN | RUNTIME+S | R Q:legacy; N4+S1 | cop_handlers_script_control |

### 3.2 I021 to I030 (55 ids)

| id | iter | question | status | kind | evidence | cited in |
|----|------|----------|--------|------|----------|----------|
| OQ-I021-1 | I021 | Does every caller of `QuintetLzDecompress` avoid using `$7E:0200-02FF` (its dictionary, first half of the depth-sort buckets) while it runs? | OPEN | RUNTIME | R Q:I021; W1 | - |
| OQ-I021-2 | I021 | Is the `$F1` fade (then `$01`, then `$F0`) audible before the music change? | OPEN | RUNTIME | R Q:I021; D2 | cop_handlers_audio, hdma_dma_spc |
| OQ-I021-3 | I021 | Are `$F2` and `$F0` in `SpcMusicLoadCmd` correctly named (engine: `$F0` stop, `$F2` stores `$FF`)? | OPEN | RUNTIME+S | R Q:I021; D2+S1 | - |
| OQ-I021-4 | I021 | Which runtime-spawned thinkers lack `animScratch2` bit 11 and therefore pause during dialogue/upload? | OPEN | RUNTIME+S | R Q:I021; W1+S1 | - |
| OQ-I022-1 | I022 | Who sets and clears `$12` bit 1 (mirror lock in `ProcessAnimFlag`)? | OPEN | RUNTIME | V `cop_handlers_sprite.asm:329-331,344`; RC-06; R Q:I022; A1 | cop_handlers_sprite |
| OQ-I022-2 | I022 | Is the first sample-chunk destination of `SpcBlockTransfer` always the first free ARAM address after the song? | OPEN | STATIC | R Q:I022; D3 | - |
| OQ-I022-3 | I022 | Does the resident SPC loader reset DSP/echo before the sample upload? | OPEN | RUNTIME | R Q:I022; D2 | - |
| OQ-I022-4 | I022 | Do other `adhocVramDma*` writers run with NMI on and store trigger before size? | DUPLICATE-OF OQ-45 (residual of OQ-64) | RUNTIME | R inventory ADHOC | - |
| OQ-I023-1 | I023 | What do the 29 Psycho Slider glide triggers do (which obstacle, which scenes; is "stair" the right name)? | OPEN | RUNTIME | R Q:I023; B4 | - |
| OQ-I023-2 | I023 | Does anything read the player `statsPtr` (`$7F0020`) after a glide leaves it at 1? | OPEN | RUNTIME | R Q:I023; W1 | - |
| OQ-I023-3 | I023 | Who reads player actor `$10` bit `$0200`? | OPEN; F10-0200 canonical | STATIC† | V readers exist: `combat_collision.asm:333` (`$76E0` skip), `:340` (`$74E0`), `:1207` (`BIT #$0280`); RC-01 | - |
| OQ-I023-4 | I023 | Who places the actor for the six `item_use_system` `DrawMetatileHere` sites (coordinates are tiles)? | OPEN | RUNTIME | R Q:I023; M1 | - |
| OQ-I023-5 | I023 | Are `WorldMapStream3/4` (#4D/#4E) dead; does anything set `extendedFlags` bit 2? | OPEN (UNREF method group) | RUNTIME+S | R Q:I023; R1+S1 | - |
| OQ-I023-6 | I023 | Does clearing `$10` bit `$0008` in `ClimbX` matter while `$2000` is set? | DUPLICATE-OF OQ-20 | RUNTIME | R inventory F10-0008 | - |
| OQ-I024-1 | I024 | `MenuSelectionHandler.asm` cannot take notes and its stored notes are wrong: which mechanism fixes this? | OPEN; TOOL-MSH canonical | DECISION | V `MenuSelectionHandler.asm:12,43` still carries the old button labels (RC-18) | - |
| OQ-I024-2 | I024 | Who reads init values `$0B14`=`$003C`, DP `$5E/$60/$62`, `$0648`? | OPEN | RUNTIME | R Q:I024; W1 | - |
| OQ-I024-3 | I024 | Who reads `$090E/$0910` (written by `ReadMenuSelection`; 13 sprite files use `$090E` as a sprite-part word)? | OPEN | RUNTIME | R Q:I024; W1 | - |
| OQ-I024-4 | I024 | `MEMSEL` set then reset: does the SPC upload really run at slow-ROM speed? | OPEN | RUNTIME | R Q:I024; C3 | - |
| OQ-I024-5 | I024 | Why does `DispatchEastMove` call `ProbeLeftTiles` (naming: trailing/leading corner)? | OPEN | RUNTIME | R Q:I024; B3 | - |
| OQ-I024-6 | I024 | Who writes `$7F0C00-02` (COLDATA bytes) and in what format? | OPEN | RUNTIME | R Q:I024; W1+E1 | - |
| OQ-I025-1 | I025 | Meaning of player `$10` bit `$0100` and `$12` bit `$0001` | OPEN (`$12 $0001` half: V `combat_collision.asm:53`, `hit_switch.asm:5`) | RUNTIME | V; A1+A2; RC-06 | player_character |
| OQ-I025-2 | I025 | Who sets player `$10` bit `$2000` (`PlayerIdleEntry` returns at once)? | DUPLICATE-OF OQ-I026-6 (partial: I053 answered the `DarkSpace` setter) | RUNTIME | V `dark_space.asm:14`; RC-02 | player_character, player_transition_handlers, dark_space |
| OQ-I025-3 | I025 | Does a second press within 13 frames start the run (`$040C` window)? | OPEN | RUNTIME | R Q:I025; P1 | - |
| OQ-I025-4 | I025 | Is `AttackNorth` testing `BranchIfSolidSouth` original behaviour? | OPEN | RUNTIME | R Q:I025; P2 | player_character |
| OQ-I025-5 | I025 | What is the lunge (`Ranged*`) and what are the `Projectile*` actors of scene `$E8`? | OPEN | RUNTIME | R Q:I025; P2+N2 | player_character |
| OQ-I025-6 | I025 | What do the `$0700` bits ORed into an interacted NPC's `$10` do before `NullActorScriptStub` kills it? | OPEN | RUNTIME | R Q:I025; A3+N1 | NpcDespawnStub |
| OQ-I025-7 | I025 | Is the camera target re-derived from the player every frame, so the +0.5 px/frame shake drift does not accumulate? | OPEN (CAM method group; missing from A02's 54-row registry, finding A12-10) | RUNTIME | R Q:I025; P4 | - |
| OQ-I026-1 | I026 | `extract:lt` and plain `extract` differ in five files, so `extract:lt`+`rebuild` (3062204 B) is not the same ROM as `extract`+`rebuild` (3062189 B): which is canonical? | OPEN; TOOL-LT canonical | DECISION | V `results/I025_results.md:56`; `I026_results.md:54`; `I021-I040_sanity-check.md:16` | sFA_diary_menu, item_use_system |
| OQ-I026-2 | I026 | Is replaying Lola's Melody in Itory (scene `$15`, flag `$40` set) intended? | OPEN | RUNTIME | R Q:I026; M1+W1 | item_use_system |
| OQ-I026-3 | I026 | What does `UseItem_WindFlute` do with a full actor pool (jumps into `code_0389D9`)? | OPEN | RUNTIME | R Q:I026; G3+M1 | item_use_system |
| OQ-I026-4 | I026 | What do palette bundles `$10` and `$0E` (death fade) look like? | OPEN (PBUNDLE; I029 questions file gives a partial answer) | RUNTIME | R Q:I026; E2 | game_over_sequence, DeathPaletteFadeThinker |
| OQ-I026-5 | I026 | Does `ToggleActorVisibilityFlag` give a 50 % flicker on Neil, Lance, Erik, Kara and the phantom Ribber; what happens to the helper? | OPEN | RUNTIME | R Q:I026; A3+N1 | FlickerParentActor |
| OQ-I026-6 | I026 | Actor `$10` bit `$2000` has two readers (depth sort "hidden", actor runner "script-driven"): consistent? | OPEN; F10-2000 canonical | RUNTIME | V `actor_execution.asm:105,142`; `attack_ability_system.asm:57`; RC-02 | FlickerParentActor |
| OQ-I027-1 | I027 | Why do `AuraBarrierMain`/`DarkFriarMain` split the DMA wait on `$16 == $0020` (8-frame wait vs yield until `$7F0C07` clears)? | OPEN | RUNTIME | R Q:I027; P2 | - |
| OQ-I027-2 | I027 | Who reads bit 9 (`$0200`) of the player `$10`? | DUPLICATE-OF OQ-I023-3 | STATIC† | V see OQ-I023-3 | - |
| OQ-I027-3 | I027 | Which compass direction does each Dark Friar fragment start in? | OPEN | RUNTIME | R Q:I027; P2 | - |
| OQ-I027-4 | I027 | How far does Psycho Dash move the player? | OPEN | RUNTIME | R Q:I027; P2 | - |
| OQ-I027-5 | I027 | Should the `ability_anim_tables` block note be rewritten with the record layout `{word, level-word pointer, damage bytes}`? | ANSWERED-LATER (I062 renamed the table and rewrote the note) | DECISION | V `ability_damage_tables.asm:3`; `attack_ability_system.asm:38`; inventory still lists it open | - |
| OQ-I027-6 | I027 | What does bundle `#1F` recolour in the Moon Tribe camp; do the two `#40` flashes in Kara's room and the Seaside fountain look alike? | DUPLICATE-OF OQ-I060-5 | RUNTIME | R inventory PBUNDLE | - |
| OQ-I028-1 | I028 | Why does `transforms.json` widen the Arrange target-confirm mask to `$8044` (X and Y also confirm in the target phase)? | OPEN | RUNTIME | V `inventory_menu.asm:359`; R Q:I028; M1 | inventory_menu |
| OQ-I028-2 | I028 | After `ArrangePerformSwap`, does the equip cursor stay on the wrong slot when the target slot was equipped? | OPEN | RUNTIME | R Q:I028; M1 | inventory_menu |
| OQ-I028-3 | I028 | Can the Use tab end without `UseItemConfirm`, leaving `inventoryEquippedIndex = 0`? | OPEN | RUNTIME | R Q:I028; M1 | - |
| OQ-I028-4 | I028 | What is tile `$2060` (blank after the transform) and why is it used instead of the vanilla blank? | OPEN | RUNTIME | R Q:I028; M4 | - |
| OQ-I028-5 | I028 | Does the "+1" in `ComputeAbilityIndex` skip a reserved entry 0? | OPEN | RUNTIME+S | R Q:I028; M1+S1 | - |
| OQ-I028-6 | I028 | What do the fixed-colour ramps `#1B`/`#1C` look like (Mu, Edward prison, Angkor, Gold Ship, crow crew)? | DUPLICATE-OF OQ-I060-5 (appearance family) | RUNTIME | R inventory PBUNDLE | - |
| OQ-I029-1 | I029 | Are `DiagRampUpLeft`/`DiagRampDownRight` named backwards (`$05` goes down-left)? | ANSWERED-LATER (R-I029-1, applied: `WestRampDescend`/`WestRampAscend`) | RUNTIME (inventory) | V `db-us/names/bank02.json:430,433`; inventory still lists it | - |
| OQ-I029-2 | I029 | Is the word at `$05,S` in `DiagClearReturnFlags` the parked vertical velocity? | OPEN | RUNTIME | R Q:I029; B3 | - |
| OQ-I029-3 | I029 | `$AA` bits `$0800/$0400` are tested but never set; `$AB` bits 2/3/7 set but never read: dead or set elsewhere? | OPEN; AA-BITS canonical | RUNTIME | V `player_move_main.asm:14`; `player_move_west.asm:7,893,952`; `player_move_south.asm:3`; RC-19 | player_move_west, player_move_east |
| OQ-I029-4 | I029 | Does `DiagPushRight` push the player down (positive `$24`) or up (as the old header said)? | ANSWERED-LATER (I040, static: down) | RUNTIME (inventory) | V `player_move_east.asm:26`; R `results/I040_results.md:16`; the id is still cited as if open | player_move_west, player_move_east |
| OQ-I029-5 | I029 | What do collision types `$06`/`$09` mean (north/south wall naming is opposite in west and east files)? | DUPLICATE-OF OQ-16 | RUNTIME | V RC-20 | player_move_east, player_move_ns |
| OQ-I029-6 | I029 | What colours do the flash `#18`/`#19` spawners show at their 7 sites? | DUPLICATE-OF OQ-I060-5 (appearance family) | RUNTIME | R inventory PBUNDLE | - |
| OQ-I030-1 | I030 | What does event flag `#00` mean (set unconditionally at the start of 26 scene actor lists)? | OPEN; FLAG00 canonical | RUNTIME | R Q:I030; W1+N1; RC-21 | scene_flag_init, shadow_shimmer |
| OQ-I030-2 | I030 | Is player actor `$10` bit `$0200` an "ignore enemy hits" bit during boss-defeat sequences? | DUPLICATE-OF OQ-I023-3 | STATIC† | V `SetPlayerGameOverFlag.asm:3`; `combat_collision.asm:333,340,1207`; RC-01 | SpawnDebrisBurst, SetPlayerGameOverFlag |
| OQ-I030-3 | I030 | Which probe results reach the `$06`/`$09` handlers on real maps? | DUPLICATE-OF OQ-16 | RUNTIME | R inventory CT69 | - |
| OQ-I030-4 | I030 | Does `slope_ramp_physics` reuse the map index in `$00` so that "left/right" probe names hold? | OPEN | RUNTIME | R Q:I030; B4 | - |

### 3.3 I031 to I040 and the sanity rows (59 ids)

| id | iter | question | status | kind | evidence | cited in |
|----|------|----------|--------|------|----------|----------|
| OQ-I031-1 | I031 | How does the credits window variant 1 look? | OPEN | RUNTIME | R Q:I031; E4 | - |
| OQ-I031-2 | I031 | Is window 1 enabled in the Mu lair (scene 67)? | OPEN | RUNTIME | R Q:I031; E4+W1 | - |
| OQ-I031-3 | I031 | What do `W12SEL $33` / `WOBJSEL $03` select? | OPEN | RUNTIME+S | R Q:I031; E4+S1 | - |
| OQ-I031-4 | I031 | What do the `ambient_palette_cycler` bundles look like? | DUPLICATE-OF OQ-I060-5 | RUNTIME | R inventory PBUNDLE | - |
| OQ-I031-5 | I031 | Does `EnemyDeathFlash` animation #01 with `$2000` look as intended? | OPEN | RUNTIME | R Q:I031; F1+G2 | - |
| OQ-I032-1 | I032 | Does `DecelerateNS` reset `slopeStepCounter`? | OPEN | RUNTIME | R Q:I032; B3 | - |
| OQ-I032-2 | I032 | Why does `ClampSpeeds` clamp NS only when EW is zero? | OPEN | RUNTIME | R Q:I032; B3 | - |
| OQ-I032-3 | I032 | Moving versus stopped slope probe points | OPEN | RUNTIME | R Q:I032; B3 | - |
| OQ-I032-4 | I032 | What is under the cell below/above for `$06`/`$09`? | DUPLICATE-OF OQ-16 | RUNTIME | R inventory CT69 | - |
| OQ-I032-5 | I032 | Who reads player `$10` bit `$0200`? | DUPLICATE-OF OQ-I023-3 | STATIC† | V see OQ-I023-3 | ramps |
| OQ-I032-6 | I032 | In which scenes does `sine_hdma_slow_wave` run (`$32`, `$E9/$EA`)? | OPEN | RUNTIME | R Q:I032; E4 | - |
| OQ-I033-1 | I033 | `FineAdjustXEast` when `$02 > 16` | OPEN | RUNTIME | R Q:I033; B2 | player_move_south |
| OQ-I033-2 | I033 | `SouthWallSouthInteract` snap adds one row | OPEN | RUNTIME | R Q:I033; B2 | player_move_south |
| OQ-I033-3 | I033 | Slope types `$03`/`$0C`: diagonal geometry | OPEN | RUNTIME | R Q:I033; B2 | player_move_south, player_move_ns |
| OQ-I033-4 | I033 | `$06`/`$09` diagonal wall pieces | DUPLICATE-OF OQ-16 | RUNTIME | R inventory CT69 | player_move_south |
| OQ-I033-5 | I033 | What is fixed colour in scenes `$23` and `$27` (warm flash)? | OPEN | RUNTIME | R Q:I033; E1 | oneshot_coldata_warm_flash |
| OQ-I033-6 | I033 | Does `$0E = $2000` (OAM attribute priority word, not actor `$10`) change the draw priority of the 22 caller NPCs? | OPEN (not a duplicate of OQ-I026-6; inventory cluster F10-2000 is wrong, finding A12-09) | RUNTIME | V `ActorDisplayModeSwap` and `hit_switch.asm:5` treat `$0E $2000` as priority bits; A3+F1 | - |
| OQ-I034-1 | I034 | What does `displayModeFlags` bit 14 do (`OpenInventoryScreen` forces `$4000`)? "No reader found" | DUPLICATE-OF OQ-23 (DMF) | STATIC† | V reader exists: `system_core.asm:396-401` and `scene_lifecycle.asm:924-936` (`hudDisableFlag` `$09ED` bit 6 = displayModeFlags bit 14); shipped text still says no reader (A12-02) | sFB_boot_logo, inventory_overlay |
| OQ-I034-2 | I034 | Does scene `$30` tint add or subtract? | OPEN | RUNTIME | R Q:I034; E1 | oneshot_coldata_r11g4b2 |
| OQ-I034-3 | I034 | Is `idle_sprite_display` (5 gems) ever spawned? | OPEN (UNREF method group) | RUNTIME+S | R Q:I034; R1+R3 | idle_sprite_display |
| OQ-I034-4 | I034 | Inventory cache slots and zeroed words (what each zeroed word does) | OPEN | RUNTIME | R Q:I034; W1+M1 | inventory_overlay |
| OQ-I034-5 | I034 | Does the inventory scene overwrite the sine tables? | OPEN | RUNTIME | R Q:I034; M1+W1 | - |
| OQ-I034-6 | I034 | Are thinker wait counters zeroed when the inventory closes? | OPEN | RUNTIME | R Q:I034; M1 | - |
| OQ-I035-1 | I035 | Which parallax table types appear on screen? | OPEN | RUNTIME | R Q:I035; E4 | - |
| OQ-I035-2 | I035 | Why are `$0060 = 1` and `$005E = 0` left behind? | OPEN | RUNTIME | R Q:I035; W1 | - |
| OQ-I035-3 | I035 | Parallax accumulator clear range | OPEN | RUNTIME | R Q:I035; E4+W1 | - |
| OQ-I035-4 | I035 | Table type `$20` window (scene `$C3`) | OPEN | RUNTIME | R Q:I035; E4 | - |
| OQ-I035-5 | I035 | BG3 vertical scroll steps in the inventory | OPEN | RUNTIME | R Q:I035; M1+E1 | - |
| OQ-I035-6 | I035 | Who reads `hpToHeal` (`$0B22`)? | OPEN | STATIC† | V reader exists: `system_core.asm:416-423` (`UpdateHUD` recovery animation); `debug_stat_setter.asm:5` says none (A12-06) | - |
| OQ-I035-7 | I035 | `parallax_scroll_table` entries no scene selects | OPEN | RUNTIME+S | R Q:I035; R2+S1 | - |
| OQ-I036-1 | I036 | Ramp exact-equality trigger | OPEN | RUNTIME | R Q:I036; B4 | - |
| OQ-I036-2 | I036 | Ramp launch distance and landing | OPEN | RUNTIME | R Q:I036; B4 | - |
| OQ-I036-3 | I036 | `StagePlayerMoveXY` animation indices | OPEN | RUNTIME | R Q:I036; F1+B4 | - |
| OQ-I036-4 | I036 | Who reads player `$10` bit `$0200`? | DUPLICATE-OF OQ-I023-3 | STATIC† | V see OQ-I023-3 | - |
| OQ-I036-5 | I036 | Does `flag_gated_palette` replay? | OPEN | RUNTIME | R Q:I036; E2+N1 | - |
| OQ-I036-6 | I036 | What do bundles `$02` and `$4C` look like? | DUPLICATE-OF OQ-I060-5 | RUNTIME | R inventory PBUNDLE | - |
| OQ-I036-7 | I036 | Does a full actor pool break east/west climb? | OPEN | RUNTIME | R Q:I036; G3 | - |
| OQ-I037-1 | I037 | Does the statue/block pull toward the player? | OPEN | RUNTIME | R Q:I037; N1 | - |
| OQ-I037-2 | I037 | Does `COP LoopEnd` yield once per pass (16-pass slide = 16 frames)? | OPEN | RUNTIME† | R Q:I037; N4 (handler is readable) | - |
| OQ-I037-3 | I037 | Is the operand order of `BranchOnPlayerX/Y` West/Here/East as the handler says (copdef labels wrong)? | OPEN | RUNTIME+S† | R Q:I037; N4+S1 | interaction_handlers |
| OQ-I037-4 | I037 | What do `$12 OR $0030` and `extendedFlags $0080` do for the laborer and kidnapper? | OPEN | RUNTIME | R Q:I037; G1+A2; RC-06 | - |
| OQ-I037-5 | I037 | `RandomPlayerOffset` rerun after the wait | OPEN | RUNTIME | R Q:I037; N1 | - |
| OQ-I038-1 | I038 | Column-crossing Y formulas | OPEN | RUNTIME | R Q:I038; B2 | - |
| OQ-I038-2 | I038 | Corner-snap Y compensation | OPEN | RUNTIME | R Q:I038; B2 | player_move_ramps |
| OQ-I038-3 | I038 | `ActorMidpointCalc` with `$06 = 0` (no successor) | OPEN | RUNTIME | R Q:I038; N4 | ActorMidpointCalc |
| OQ-I038-4 | I038 | Is `camera_delta_oscillator` ever spawned? | OPEN (UNREF method group) | RUNTIME+S | R Q:I038; R1+R3 | camera_delta_oscillator |
| OQ-I038-5 | I038 | `EastRampDown` samples the top row | OPEN | RUNTIME | R Q:I038; B2 | - |
| OQ-I039-1 | I039 | `slopeFracAccum` slowdown of about 56 % | OPEN | RUNTIME | R Q:I039; B2 | - |
| OQ-I039-2 | I039 | `SouthWallNudge` conditions | DUPLICATE-OF OQ-16 (partial: also geometry) | RUNTIME | R inventory CT69 | - |
| OQ-I039-3 | I039 | `SnapYNorthCollision` pushes 1..16 px | DUPLICATE-OF OQ-16 (partial) | RUNTIME | R inventory CT69 | - |
| OQ-I039-4 | I039 | Is the `NorthProbeRedirect` pair dead? | OPEN (UNREF method group) | RUNTIME | R Q:I039; R1 | player_move_ns |
| OQ-I039-5 | I039 | What does flag `$09AF` bit `$10` change on the next tick? | OPEN | RUNTIME | R Q:I039; B2 | - |
| OQ-I039-6 | I039 | `SpawnDebrisBurst` count and `$0302` | OPEN | RUNTIME | R Q:I039; N1 | - |
| OQ-I040-1 | I040 | Does `large_ramp_booster` fire once per approach? | OPEN | RUNTIME | R Q:I040; B4 | large_ramps |
| OQ-I040-2 | I040 | The booster's NS-only gate increments EW | OPEN | RUNTIME | R Q:I040; B4 | - |
| OQ-I040-3 | I040 | Which scripts set palette flag `#01` in scenes `$FD/$FF`; what is bundle `#03`? | DUPLICATE-OF OQ-I060-5 | RUNTIME | R inventory PBUNDLE | palette_parent_child |
| OQ-I040-4 | I040 | Which way does the east wall-slide push (CT69)? | DUPLICATE-OF OQ-16 (direction half ANSWERED-LATER by I040 itself, see OQ-I029-4) | RUNTIME | V `player_move_east.asm:26` | - |
| OQ-SAN2-1 | I025 | Is sound `#15` in `CameraShakeActor` queued once or every tick (no `SetEntryHere`)? | OPEN | RUNTIME | R Q:sanity-I021-I040; P4+D1 (CAM family, not a duplicate: sound, not drift) | - |
| OQ-SAN2-2 | I033 | After the `FineAdjustXWest/East` fixes, does the north-wall slide move the player EAST by `$02 - n` px with `$09` under the left foot? | DUPLICATE-OF OQ-16 (direction half) | RUNTIME | R inventory CT69 | - |

### 3.4 I041 to I050 (53 ids)

| id | iter | question | status | kind | evidence | cited in |
|----|------|----------|--------|------|----------|----------|
| OQ-I041-1 | I041 | What are `$7F0B22` and `$7F0B24` set to `$FFFF` by `Mode7PerspectiveInit`? (Not the same word as `$0B22` `hpToHeal`) | OPEN | RUNTIME | R Q:I041; W1 | mode7_perspective |
| OQ-I041-2 | I041 | Do the Mode 7 maths match the picture? | OPEN | RUNTIME | R Q:I041; E3 | - |
| OQ-I041-3 | I041 | Do the Mode 7 HDMA tables collide with the staging buffers? | OPEN | RUNTIME | R Q:I041; E3+W1 | mode7_perspective |
| OQ-I041-4 | I041 | Is the divisor-overflow path ever taken? | OPEN | RUNTIME | R Q:I041; E3 | - |
| OQ-I041-5 | I041 | What does the damage number show after the victim slot is reused? | OPEN | RUNTIME | R Q:I041; G1+G3 | SpawnDamageNumberEffect |
| OQ-I041-6 | I041 | Child flags `$0400`; `$1000` set only on the second path | DUPLICATE-OF OQ-8 | RUNTIME | R inventory F10-0080/0400; V `hit_stagger_controller.asm:5` | - |
| OQ-I041-7 | I041 | How does the hidden jewel look; is it hidden after pickup? | OPEN | RUNTIME | R Q:I041; F1+N1 | hidden_red_jewel |
| OQ-I042-1 | I042 | Is the hit sparkle (`SpawnHitSparkSprites`) reachable in the shipped game? | OPEN | RUNTIME+S† | R Q:I042; G2+R1 | SpawnItemSparkleEffect |
| OQ-I042-2 | I042 | How do tiles `$7A/$7B` look? | OPEN | RUNTIME | R Q:I042; F1 | SpawnItemSparkleEffect |
| OQ-I042-3 | I042 | Who consumes `floor_button` flag `$0F` (scene 87)? | OPEN | RUNTIME | R Q:I042; N1+W1 | hit_switch |
| OQ-I042-4 | I042 | Which post-hit iframe mode does `$12` bit `$0001` select; what does the enemy HUD bar show for HP `$FF` against maximum `$14`? | OPEN (the `$12 $0001` half overlaps OQ-I025-1; the inventory topic says "bit 1" but the question is bit `$0001`, A12-09) | RUNTIME | V `combat_collision.asm:53`; `hit_switch.asm:5`; G1 | - |
| OQ-I042-5 | I042 | Is the Edward's Castle exit test `Y == $2D0` correct? | OPEN | RUNTIME | R Q:I042; M3 | overworld_exit |
| OQ-I042-6 | I042 | Exit side effects `$0D60` and `gfxCacheIdxB` | OPEN (RC-15) | RUNTIME | R Q:I042; M3+W1 | overworld_exit |
| OQ-I042-7 | I042 | Is flag `$01` left set at Itory? | OPEN | RUNTIME | R Q:I042; W1+R2 | overworld_exit |
| OQ-I042-8 | I042 | Are the "quit only" menus reachable? | OPEN | RUNTIME | R Q:I042; M3 | - |
| OQ-I043-1 | I043 | `town_door` first pass uses `AnimOnce` | OPEN | RUNTIME | R Q:I043; N1 | town_door |
| OQ-I044-1 | I044 | Gold Ship flags `$4D/$52` and palette phases | DUPLICATE-OF OQ-I060-5 | RUNTIME | R inventory PBUNDLE | gold_ship_wreck_palette |
| OQ-I044-2 | I044 | What does `Flags12` bit `$0200` mean (over 150 NPC, sign, book, door scripts set it)? | OPEN | RUNTIME | V `global_ambient_dispatcher.asm:19,223,233` (reader skips snapshot and turn); A1+A3; RC-06 | - |
| OQ-I044-3 | I044 | Does the yielding chat routine restore correctly? | OPEN | RUNTIME | R Q:I044; N4 | - |
| OQ-I044-4 | I044 | Does the A button feed the interact bit (`$8000`) in this build (`remapA = $8080`, `remapB = $4008`)? | OPEN | STATIC† | V `db-us/transforms.json:755-758`; `global_ambient_dispatcher.asm:13,105`; RC-18 | - |
| OQ-I045-1 | I045 | Are `$AA` bits `$0800/$0400` ever set? | DUPLICATE-OF OQ-I029-3 | RUNTIME | V `player_move_main.asm:14` | player_move_main |
| OQ-I045-2 | I045 | Does a rain drop survive its first death test; what is its lifetime? | OPEN | RUNTIME | R Q:I045; N1 | unused_particle_rain_spawner |
| OQ-I045-3 | I045 | Position publish between movement phases | OPEN | RUNTIME | R Q:I045; B3 | - |
| OQ-I045-4 | I045 | Is `particle_rain_spawner` reachable? | OPEN (UNREF method group) | RUNTIME+S | R Q:I045; R1+R3 | - |
| OQ-I045-5 | I045 | Is orbit angle `$40` east? | OPEN | RUNTIME | R Q:I045; N4 | - |
| OQ-I046-1 | I046 | Hitstun sound `#07` or `#08`? | OPEN | RUNTIME | R Q:I046; G3+D1 | - |
| OQ-I046-2 | I046 | Hitstun with a full actor pool | OPEN | RUNTIME | R Q:I046; G3 | ApplyPlayerHitstun |
| OQ-I046-3 | I046 | Does a cut-short slide zero the chain? | OPEN | RUNTIME | R Q:I046; G3 | hit_stagger_controller |
| OQ-I046-4 | I046 | `EnemyDefeatDispatch` with `$0AEC = 0` wraps the counters | OPEN | RUNTIME | R Q:I046; G2 | EnemyDefeatDispatch |
| OQ-I046-5 | I046 | Which actors have knockback tier >= 2? | OPEN | RUNTIME+S | R Q:I046; G4+S1 | - |
| OQ-I046-6 | I046 | Three-enemy gem drop sequence | OPEN | RUNTIME | R Q:I046; G2 | - |
| OQ-I047-1 | I047 | Does a non-zero `iframeCounter` stop movement? | OPEN | RUNTIME | V `actor_execution.asm:25,159-165` states it (freeze of non-player actors); RC-07 | - |
| OQ-I047-2 | I047 | Do the player and companions keep running in the pickup pass? | OPEN | RUNTIME | R Q:I047; G2+A2 | - |
| OQ-I047-3 | I047 | Statue sprite pedestal pixels | OPEN | RUNTIME | R Q:I047; M1 | - |
| OQ-I048-1 | I048 | Does the shimmer fast cycle happen in 26 scenes? | DUPLICATE-OF OQ-I030-1 | RUNTIME | R inventory FLAG00 | shadow_shimmer |
| OQ-I048-2 | I048 | Do the statue ceremony PPU writes persist? | OPEN | RUNTIME | R Q:I048; E1+N2 | - |
| OQ-I048-3 | I048 | Confetti burst count | OPEN | RUNTIME | R Q:I048; N2 | - |
| OQ-I048-4 | I048 | Is `dialog_string_scanner` reachable? | OPEN (UNREF method group) | RUNTIME+S | R Q:I048; R1+R3 | - |
| OQ-I048-5 | I048 | Are `playerSpeedEw/Ns` zero while walking? | OPEN (the inventory puts it in FLAG00 by mistake, A12-09) | RUNTIME | R Q:I048; B3 | - |
| OQ-I049-1 | I049 | Is `debug_man` ever spawned? | OPEN (UNREF method group) | RUNTIME+S | R Q:I049; R1+R3 | - |
| OQ-I049-2 | I049 | Do the 21 `debug_man` destinations load? | OPEN | RUNTIME | R Q:I049; N2+H3 | - |
| OQ-I049-3 | I049 | What does `$10` bit `$0400` mean on a drop pickup? | DUPLICATE-OF OQ-8 | RUNTIME | R inventory F10-0080/0400 | EnemyDropSystem |
| OQ-I049-4 | I049 | Is the camera vertical target `Y - $80` right (player 16 lines below centre)? | OPEN (CAM method group) | RUNTIME | R Q:I049; P4 | camera_scroll_controller |
| OQ-I049-5 | I049 | Does the gem pickup blink as the code reads? | OPEN; GEM canonical | RUNTIME | R Q:I049; F1+G2 | - |
| OQ-I049-6 | I049 | Do the weighted drop probabilities match the table; where does the heal sparkle spawn? | OPEN | RUNTIME† (probability arithmetic is static; spawn position is runtime) | R Q:I049; G2 | - |
| OQ-I049-7 | I049 | Are `$EB48/$EB74` of `camera_scroll_controller` executed? | OPEN (UNREF method group) | RUNTIME | R Q:I049; R1 | - |
| OQ-I050-1 | I050 | Does the stat-up reset `$7F` to `$55` happen in play? | OPEN | RUNTIME | R Q:I050; G2+M1 | inventory_mgmt |
| OQ-I050-2 | I050 | Do the `camera_drift` offsets survive (target recomputed)? | OPEN; CAM canonical | RUNTIME | R Q:I050; P4 | camera_drift |
| OQ-I050-3 | I050 | NPC wander step length | OPEN | RUNTIME | R Q:I050; N1 | - |
| OQ-I050-4 | I050 | Is `$24 = $FFFF` ever true in `CameraDriftPatterned`? | OPEN (CAM method group) | RUNTIME | R Q:I050; P4 | camera_drift |
| OQ-I050-5 | I050 | Are the last 8 words of `binary_00D068` used by any code or another spawn variant? | OPEN (UNREF method group) | RUNTIME+S† | R Q:I050; R1+R3 | - |
| OQ-I050-6 | I050 | Heal sparkle position per `GiveItemToPlayer` caller | OPEN | RUNTIME | R Q:I050; G2+M1 | - |
| OQ-I050-7 | I050 | NPC skips the 120-frame wait | OPEN | RUNTIME | R Q:I050; N1 | - |

### 3.5 I051 to I060 (64 ids)

| id | iter | question | status | kind | evidence | cited in |
|----|------|----------|--------|------|----------|----------|
| OQ-I051-1 | I051 | Does `effect_velocity_init` run its integration tail every frame after `WaitByte` (no own `SetEntryHere`)? | OPEN | RUNTIME† | R Q:I051; N4+P4 | layer1_scroll_actors |
| OQ-I051-2 | I051 | Does anything read `forcedScrollOverride` (`$06C8`)? | OPEN | RUNTIME (static negative result reported) | R Q:I051; W1; RC-21 | layer1_scroll_actors |
| OQ-I051-3 | I051 | `boss_clear_reward_handler` uses `$04` as scratch | OPEN | RUNTIME | R Q:I051; W1+G2 | boss_clear_reward_handler |
| OQ-I051-4 | I051 | Reader of `$7F0010 = $FFFF` | OPEN | RUNTIME | R Q:I051; W1 | field_reveal_object |
| OQ-I051-5 | I051 | Is the room-tier stat item scene flag ever set? | OPEN | RUNTIME | R Q:I051; G2 | field_reveal_object |
| OQ-I051-6 | I051 | Collision byte `$0E` in the drop probe | OPEN | RUNTIME | R Q:I051; B1 | field_reveal_object |
| OQ-I051-7 | I051 | Gem animations `$09/$0A/$0B` and their lifetime | DUPLICATE-OF OQ-I049-5 | RUNTIME | R inventory GEM | field_reveal_object |
| OQ-I052-1 | I052 | Flag `#00` in `PlayerIdleAnimLoop` | DUPLICATE-OF OQ-I030-1 | RUNTIME | R inventory FLAG00 | player_transition_handlers |
| OQ-I052-2 | I052 | Body table entry 4 frame `$20` | OPEN | RUNTIME | R Q:I052; F1 | player_transition_handlers |
| OQ-I052-3 | I052 | Fall landing position | OPEN | RUNTIME | R Q:I052; N2+B3 | player_transition_handlers |
| OQ-I052-4 | I052 | Terrain type `$04`; does the scan terminate? | OPEN | RUNTIME | R Q:I052; B1 | player_transition_handlers |
| OQ-I052-5 | I052 | What is player `$10` bit `$0002` (set by fall and jump)? | OPEN | RUNTIME | R Q:I052; A1 | player_transition_handlers |
| OQ-I052-6 | I052 | `SpawnFieldRevealEffect` rise and `dstX` | OPEN | RUNTIME | R Q:I052; N1+G2 | - |
| OQ-I052-7 | I052 | `GetPlayerFacingDirection` returning `>= 4` | OPEN (static-settled in shipped text per A05) | RUNTIME | R A05 line 148; `cop_handlers_player_query.asm:504` handles carry | EscortFollowPathTracker |
| OQ-I052-8 | I052 | Ring entry 9 (`$7EDF40`) read | OPEN (first half static-settled per A05) | RUNTIME | R Q:I052; W1+N1 | - |
| OQ-I052-9 | I052 | Spark frame `$2A` | OPEN | RUNTIME | R Q:I052; F1 | player_transition_handlers |
| OQ-I053-1 | I053 | Does `smooth_follow_child` keep its heading? | OPEN | RUNTIME | R Q:I053; N1 | - |
| OQ-I053-2 | I053 | Callers' speeds and `$0B02` | OPEN | RUNTIME | R Q:I053; N1+W1 | - |
| OQ-I053-3 | I053 | Is the player hidden after `DarkSpaceEnterWarp`? | DUPLICATE-OF OQ-I026-6 (partial: reader known, visible effect is runtime) | RUNTIME | V `dark_space.asm:14`; RC-02 | - |
| OQ-I053-4 | I053 | Dao portal priority versus walls | OPEN | RUNTIME | R Q:I053; F1+E1 | - |
| OQ-I053-5 | I053 | Is animation `#1C` the same picture in two places? | OPEN | RUNTIME | R Q:I053; F1 | - |
| OQ-I053-6 | I053 | Game-over sparkle spiral | OPEN | RUNTIME | R Q:I053; N2+F1 | - |
| OQ-I053-7 | I053 | Does game over in scene `$E8` respawn as Shadow? | OPEN | RUNTIME | R Q:I053; N2+G2 | - |
| OQ-I054-1 | I054 | Which OBJ palette does each boot logo use? | ANSWERED-LATER (I055, from the sprite tables) | RUNTIME (inventory) | V `boot_logo_enix_palette_obj0.asm:19`; `obj1.asm:8`; both still cite the id | boot_logo_enix_palette_obj0, boot_logo_enix_palette_obj1 |
| OQ-I054-2 | I054 | Init of `$0AEC`/`$0AEE` | OPEN | RUNTIME | R Q:I054; G2+W1 | - |
| OQ-I054-3 | I054 | Do effects need `$12 $1000` with `displayModeFlags $0080`? | OPEN | RUNTIME | V `actor_execution.asm:11,242,255-258`; RC-06; G2+A2 | - |
| OQ-I054-4 | I054 | `SetSpritePalette #00` at the head of `EnemyStatBonusReward` | OPEN | RUNTIME | R Q:I054; G2 | - |
| OQ-I054-5 | I054 | Which enemies give which gem type; real drop rates | OPEN | RUNTIME+S | R Q:I054; G4+G2 | - |
| OQ-I055-1 | I055 | Boot-logo sprite groups and palette-4 parts | OPEN | RUNTIME | R Q:I055; M2+F1 | - |
| OQ-I055-2 | I055 | Does the colour effect finish while the logo is visible? | OPEN | RUNTIME | R Q:I055; M2 | - |
| OQ-I055-3 | I055 | Is event flag `$10` cleared by a soft reset? | OPEN | RUNTIME | R Q:I055; M2+C3 | - |
| OQ-I055-4 | I055 | Are header bytes 4-11 of a sprite group read by any code? | ANSWERED-LATER (B001: two collision boxes read by `PlayerAttackHitTest` and `CombatCollision`) | RUNTIME (inventory) | V `spm_boot_logos.sprite.asm:13,18`; readers R (A06); HDR411 canonical | - |
| OQ-I055-5 | I055 | Does `AnimLoop` end after exactly 120 ticks? | OPEN | RUNTIME | R Q:I055; M2 | - |
| OQ-I056-1 | I056 | Does the Will ability transform work when the player is Shadow? | OPEN | RUNTIME | R Q:I056; N3 | - |
| OQ-I056-2 | I056 | Firefly particle direction and X range | OPEN | RUNTIME | V `sE6_gaia.asm:2047`; N3 | sE6_gaia |
| OQ-I056-3 | I056 | What do BG changes `$86-$8F` draw? | OPEN | RUNTIME | V `sE6_gaia.asm:204`; N3+F1 | sE6_gaia |
| OQ-I056-4 | I056 | Is `globalScriptIndex = 1` only set in the pyramid? | OPEN | RUNTIME | V `sE6_gaia.asm:6`; `dark_space.asm:17`; RC-16 | - |
| OQ-I056-5 | I056 | `GaiaContinueJourney` fades to `$0E` while the room plays `$16` | OPEN | RUNTIME | R Q:I056; N3+D1 | - |
| OQ-I056-6 | I056 | Is scene `$09` reachable? | OPEN | RUNTIME | R Q:I056; R2 | - |
| OQ-I056-7 | I056 | What do Dark Space animations #04-#09 look like (tiles `$0350-$0380`)? | DUPLICATE-OF OQ-B001-1 | RUNTIME | R inventory topic "(B001-1)" | - |
| OQ-I056-8 | I056 | `diary_entry_table`: camera or map position? | OPEN | RUNTIME | R Q:I056; M2+E3 | - |
| OQ-I056-9 | I056 | Why did `rebuild` fail once with `Patch CrystalBallAutoUse contains a rewrite that does not exist: CODE_05F522` right after the first `extract:lt`? | OPEN (tooling; related to OQ-I026-1, different failure) | DECISION | R Q:I056; T1 | - |
| OQ-I057-1 | I057 | What do button Type 1 and Type 2 do in this baserom (remaps `$4008/$8080/$0040/$0004`; menu tests `$8000/$4000`)? | OPEN | RUNTIME | V `sFA_diary_menu.asm:33`; `transforms.json:755-758`; RC-18 | sFA_diary_menu |
| OQ-I057-2 | I057 | Which debug routines are unreferenced? | OPEN (UNREF method group) | RUNTIME+S | R Q:I057; R1+R3 | - |
| OQ-I057-3 | I057 | How do the highlight bands look (window registers)? | OPEN | RUNTIME | V `sFA_diary_menu.asm:7`; E4+M2 | sFA_diary_menu, diary_menu_window_dma |
| OQ-I057-4 | I057 | What does `displayModeFlags` bit 14 (HUD off) change in scene `$FA`; is bit 0 consumed once or every frame? | DUPLICATE-OF OQ-23 (DMF) | STATIC† | V `camera_tilemap.asm:892-900` (bit 0 cleared by TRB after the transfer, with bits 4/5); `system_core.asm:379` | - |
| OQ-I057-5 | I057 | Is `TitlePaletteFadeStep` reachable? | OPEN (UNREF method group) | RUNTIME+S | R Q:I057; R1+R3 | - |
| OQ-I057-6 | I057 | `DiaryEraseExecute` `$1C -> $1A` | OPEN | RUNTIME | R Q:I057; M2 | - |
| OQ-I058-1 | I058 | What does the world map draw below the boundary row? | OPEN | RUNTIME | V cited in `docs/code/bank03/radar-and-world-map.md` and the corpus copy; E3+M3 | WorldMapSplitEffect |
| OQ-I058-2 | I058 | `sprite_group_000008` comet | OPEN | RUNTIME | R Q:I058; M2+F1 | - |
| OQ-I059-1 | I059 | `animScratch2` ORed with `$0804` on the child | OPEN | RUNTIME | R Q:I059; M3 | WorldMapController |
| OQ-I059-2 | I059 | Is the palette reset thinker spawned twice? | OPEN | RUNTIME | R Q:I059; M3+E2 | WorldMapController |
| OQ-I059-3 | I059 | World-map animations 1-5 and 7-D | OPEN | RUNTIME | R Q:I059; M3+F1 | - |
| OQ-I059-4 | I059 | `$B8` at the start of the zoom-out | OPEN | RUNTIME | R Q:I059; E3+M3 | WorldMapController |
| OQ-I059-5 | I059 | Name text path in scene `$FE` (sets `layerPriorityFlag` bit 12?) | DUPLICATE-OF OQ-36 | RUNTIME | R inventory LPF | - |
| OQ-I059-6 | I059 | Leader dot animation during zoom-out | OPEN | RUNTIME | R Q:I059; M3 | - |
| OQ-I059-7 | I059 | `LookupMapName` miss | OPEN | RUNTIME+S | R Q:I059; M3+S1 | world_map_scene_names, WorldMapController |
| OQ-I059-8 | I059 | `$FE` second route path (`$0D5C`, `$0D5E`) | OPEN | RUNTIME | R Q:I059; M3+W1 | - |
| OQ-I060-1 | I060 | Menu ids `$00`, `$1C-$26` never staged | OPEN | RUNTIME | R Q:I060; R2+W1 | - |
| OQ-I060-2 | I060 | Does a route step last n or n+1 ticks? | OPEN (half static-settled per A05; WaitByte = n+1) | RUNTIME | R A05 line 148 | world_map_options |
| OQ-I060-3 | I060 | Is the choice id masked with `$1F` anywhere that matters? | OPEN | RUNTIME† | R A05 line 148 (half settled) | - |
| OQ-I060-4 | I060 | Is the instruction after `DialogueOptions` reached? | OPEN | RUNTIME | R Q:I060; M3+N4 | - |
| OQ-I060-5 | I060 | What do the remaining ~120 palette bundles contain, and which are never referenced? | OPEN; PBUNDLE canonical | RUNTIME+S | R Q:I060; E2+R1 | - |
| OQ-I060-6 | I060 | Are the four empty one-byte bundles (`16D210`, `16D211`, `16D317`, `16D318`) padding? | OPEN (not an appearance question; the PBUNDLE membership is a mistake) | STATIC | R Q:I060; S1 | - |

### 3.6 I061 to I072 (56 ids)

| id | iter | question | status | kind | evidence | cited in |
|----|------|----------|--------|------|----------|----------|
| OQ-I061-1 | I061 | Who reaches `body_table` rows `$03` and `$08` (row `$03` is a copy)? | OPEN | RUNTIME | R Q:I061; W1+P2 | body_table, spriteset_shadow |
| OQ-I061-2 | I061 | `direction_velocity_table` repeats; step codes | OPEN | RUNTIME+S | R Q:I061; N4+S1 | walk_step_table |
| OQ-I061-3 | I061 | Are the 16 scene ids sharing `scene_event_0C8200` loadable? | OPEN | RUNTIME | R Q:I061; R2 | scene_actors |
| OQ-I062-1 | I062 | Tile-streaming sprite-part high byte `$0A` | OPEN | RUNTIME | V `spriteset_adrift_wave.asm:3`; F1+N1 | spriteset_adrift_wave |
| OQ-I062-2 | I062 | Ability damage record word 0; climb damage byte | OPEN | RUNTIME | V `ability_damage_tables.asm`; RC-13; G1+P2 | ability_damage_tables |
| OQ-I062-3 | I062 | `ApplyMovementWithCollision` chain advance | OPEN | RUNTIME | R Q:I062; N4 | - |
| OQ-I062-4 | I062 | Which of the 85 movement chains are used? | OPEN | RUNTIME+S | R Q:I062; R1+S1 | - |
| OQ-I063-1 | I063 | Shared words `$00`, `$03`, `$0D` never selected | OPEN | RUNTIME | R Q:I063; M4+R1 | shared_word_table |
| OQ-I063-2 | I063 | Freedan table animation indices | OPEN | RUNTIME | V `spriteset_freedan.asm:47`; F1+R1 | spriteset_freedan |
| OQ-I063-3 | I063 | Does `snake_pit_fx` also put an OAM sprite? | OPEN | RUNTIME | R Q:I063; F1 | - |
| OQ-I063-4 | I063 | What is the role of header bytes 4-7 and 8-11 of a sprite group? | DUPLICATE-OF OQ-I055-4 (answered by B001) | RUNTIME | V `spm_boot_logos.sprite.asm:13` | - |
| OQ-I063-5 | I063 | Lone set `0E86AE` | OPEN | RUNTIME+S | R Q:I063; F2+S1 | - |
| OQ-I064-1 | I064 | Extended warp pan lists per warp | OPEN (partial: pan list usage by I068) | RUNTIME+S | R `results/I068_results.md:53`; R2+S1 | forced_walk_pan_table, scene_warps |
| OQ-I064-2 | I064 | What do the Freejia tile streams `$3FE0/$3FF0` show? | OPEN | RUNTIME | V `spriteset_freejia_tilefx.asm:15`; F1+W1 | spriteset_freejia_tilefx |
| OQ-I064-3 | I064 | Will flute frames | OPEN | RUNTIME | V `spriteset_will.asm:14`; M1+F1 | spriteset_will |
| OQ-I064-4 | I064 | Will table animations `$04-$07`, `$14-$17` | OPEN | RUNTIME | V `spriteset_will.asm:35`; F1+R1 | spriteset_will |
| OQ-I065-1 | I065 | Speaker template glyph versus outline colour | OPEN | RUNTIME | R Q:I065; M4 | dialog_template_table |
| OQ-I065-2 | I065 | Are scenes without a `scene_meta` record loadable? | OPEN | RUNTIME | R Q:I065; R2 | - |
| OQ-I065-3 | I065 | Is `musicParentActor` (`$06F2`) the BGM id (the name suggests a parent actor)? | DUPLICATE-OF OQ-29 (second half) | RUNTIME | V `scene_meta.asm:23`; `warps_interaction.asm:46`; RC-12 | - |
| OQ-I065-4 | I065 | Unused `LoadBgTiles` mode 3 and FullGraphics paths | OPEN | RUNTIME | R Q:I065; R2+R1 | - |
| OQ-I065-5 | I065 | Spritemap second operand and size word | OPEN | RUNTIME+S | R Q:I065; S1+F1 | - |
| OQ-I065-6 | I065 | Template `$10` duplicates `$0F` | OPEN | RUNTIME | R Q:I065; M4 | - |
| OQ-I066-1 | I066 | Are the 16 unreferenced enemy stats rows used? | OPEN | RUNTIME+S | R Q:I066; G4+W1 | enemy_stats_table |
| OQ-I066-2 | I066 | Which attacks use which hit path? | OPEN | RUNTIME | R Q:I066; G1 | enemy_stats_table |
| OQ-I066-3 | I066 | Is the OBSEL name base `$4000`? | OPEN | RUNTIME | V `spriteset_aura.asm:15`; E1+F1 | spriteset_aura |
| OQ-I066-4 | I066 | Do the Aura orbital body boxes hurt enemies; which routine reads the default attack box? | OPEN (HDR411: the reader half is answered by B001, the damage half is runtime) | RUNTIME | V `spm_boot_logos.sprite.asm:13`; F3+G1 | - |
| OQ-I066-5 | I066 | Shadow one-frame lists `$19-$1B` | OPEN | RUNTIME | R Q:I066; F1+R1 | - |
| OQ-I067-1 | I067 | Are blank-name items shown through `GiveItemToPlayer`? | OPEN | RUNTIME | R Q:I067; M1+M4 | item_pickup_text_table |
| OQ-I067-2 | I067 | Items `$15-$19` are all "Teapot": intended? | OPEN | RUNTIME+S | R Q:I067; M1+S1 | item_pickup_text_table |
| OQ-I067-3 | I067 | What do the tiles of `spriteset_will_projectile` (scene `$E8`) show? | OPEN | RUNTIME | V `spriteset_darkgaia_projectile.asm:15`; F1+N3 | spriteset_darkgaia_projectile |
| OQ-I067-4 | I067 | `spriteset_ability_fx` animations `$04`, `$0C`, `$11` unused | OPEN (UNREF method group) | RUNTIME | V `spriteset_transform_poses.asm:5,263,539,721`; F1+R1 | spriteset_transform_poses |
| OQ-I067-5 | I067 | Orphan groups `0FCF65` and `0FD5E8` (extractor prints them as sub-sprites) | OPEN; HIDDEN-SPRITE canonical | STATIC | V `spriteset_transform_poses.asm:7,1013,1358`; `spriteset_will_abilities.asm:25`; `A08_findings.md` §2.3 | spriteset_transform_poses, spriteset_will_abilities |
| OQ-I068-1 | I068 | `npc_props` animations `$02,$05,$07,$0A` | OPEN | RUNTIME | V `spriteset_npc_props.asm:19`; F1 | spriteset_npc_props |
| OQ-I068-2 | I068 | `npc_props` animations `$03` and `$09` unused | OPEN (UNREF method group) | RUNTIME | V `spriteset_npc_props.asm:19,55,91`; R1 | spriteset_npc_props |
| OQ-I068-3 | I068 | Which scenes use which display preset; the mode-7 presets | OPEN | RUNTIME+S | R Q:I068; R2+S1 | display_preset_table |
| OQ-I068-4 | I068 | Forced-walk stream bytes `$04/$05` | OPEN | RUNTIME | R Q:I068; R2+N4 | scene_warps |
| OQ-I068-5 | I068 | Are `ForcedWalkEast/West` reachable? | OPEN | RUNTIME | R Q:I068; R1+W1 | - |
| OQ-I069-1 | I069 | Is body row `$07` (`spriteset_shadow_fx`) ever selected? | OPEN | RUNTIME | V `spriteset_shadow_fx.asm:1,13`; W1+R1 | spriteset_shadow_fx |
| OQ-I069-2 | I069 | Which other `spriteset_enemies` animations exist? | OPEN | RUNTIME | V `spriteset_pickups_effects.asm:18`; F1+R1 | spriteset_pickups_effects |
| OQ-I069-3 | I069 | `spriteset_freedan_fx` groups | OPEN | RUNTIME | V `spriteset_freedan_fx.asm:10`; F1+P2 | spriteset_freedan_fx |
| OQ-I069-4 | I069 | Is the group at `0EEEB8` staged (printed as three rows)? | DUPLICATE-OF OQ-I067-5 | STATIC | V `spriteset_pickups_effects.asm:1135`; `A08_findings.md` §2.3 | spriteset_pickups_effects |
| OQ-I070-1 | I070 | How does the rebuild pick words for `$D6/$D7` dictionary references (all, a fixed list, longest match)? | OPEN | STATIC† | V cited in `dialog_dictionaries`; S1+T1 | dialog_dictionaries |
| OQ-I070-2 | I070 | `spriteset_dark_friar` groups and VRAM layout | OPEN | RUNTIME | R Q:I070; P2+F1 | - |
| OQ-I070-3 | I070 | Are the 87 reward-tier scenes reachable; boss ranges | OPEN | RUNTIME+S | R Q:I070; G2+S1 | - |
| OQ-I071-1 | I071 | Shadow Aura animations | OPEN | RUNTIME | V `spriteset_shadow_aura_body.asm:13`; F1+P2 | spriteset_shadow_aura_body |
| OQ-I071-2 | I071 | Aura palette and exit | OPEN | RUNTIME | R Q:I071; F1+P2 | - |
| OQ-I071-3 | I071 | Flag-only chests in scenes `$60/$61`, flag `$2E` | OPEN | RUNTIME | R Q:I071; M1+W1 | - |
| OQ-I071-4 | I071 | Inventory sprite sets `$40-$43` | OPEN | RUNTIME | R Q:I071; M1+F1 | - |
| OQ-I071-5 | I071 | Five hidden groups at `$10:8B82...` in `inventory_spritemap` | DUPLICATE-OF OQ-I067-5 | STATIC | V `inventory_spritemap.asm:1064,1080`; `A08_findings.md` §2.3 (the file's text names no id) | - |
| OQ-I071-6 | I071 | Does `$37` share a group with the statues `$38/$39`? | OPEN | RUNTIME | R Q:I071; M1 | - |
| OQ-I072-1 | I072 | Is index `$38-$3F` the Mystic Statue or the Mystery Doll? | OPEN | RUNTIME | R Q:I072; M1+M4 | system_strings |
| OQ-I072-2 | I072 | Are `$18` Will and `$25` Lola's Letter discardable? | OPEN | RUNTIME | R Q:I072; M1 | system_strings |
| OQ-I072-3 | I072 | Which strings and thinker lists are unreferenced (reachability census)? | OPEN; UNREF canonical (method group only) | RUNTIME+S | R Q:I072; R1+R3 | scene_thinkers, system_strings |
| OQ-I072-4 | I072 | Does the Spin Dash `StagePlayerSprite` override resolve to the `spriteset_will_abilities` pose? | OPEN | RUNTIME | V `spriteset_will_abilities.asm:7`; P2 | spriteset_will_abilities |
| OQ-I072-5 | I072 | Is the `$20` hold pose a real pose (all groups hold the same two sub-sprites)? | OPEN | RUNTIME | V `spriteset_will_abilities.asm:16`; F1+N2 | spriteset_will_abilities |
| OQ-I072-6 | I072 | Untraced `spriteset_will_alt` indices | OPEN | RUNTIME | R Q:I072; R1+P2 | - |

## 4. Duplicate groups

"Answers every member" holds only where the table says so. Method groups (same experiment, different object) are marked "method only".

| Group | Canonical | Members | Verdict |
|-------|-----------|---------|---------|
| **Hidden sprite groups** (extractor artefact AP-12) | OQ-I067-5 | OQ-I069-4, OQ-I071-5 | **True duplicates by object.** 9 hidden groups in 4 files: `spriteset_transform_poses` 2 (`0FCF65`, `0FD5E8`), `spriteset_will_abilities` 1 (`0F8BF5`), `spriteset_pickups_effects` 1 (`0EEEB8`), `inventory_spritemap` 5 (`108B82`...). V: the three files' notes say "extractor artefact / unreferenced group" (`spriteset_transform_poses.asm:7,1013,1358`; `spriteset_will_abilities.asm:25`; `spriteset_pickups_effects.asm:1135`; `inventory_spritemap.asm:1064,1080`). Their reachability is already settled statically (no frame list points at them); what remains is the extractor fix (T02/A15). Kind: STATIC plus a tooling decision, not RUNTIME. The inventory lists all three under UNREF as RUNTIME+S, which overstates the work. |
| **`$06F2` / `musicParentActor`** | OQ-29 (second half) | OQ-I065-3 | **True duplicate.** Not in the inventory cluster table. V `scene_meta.asm:23` (the first byte of `SpcMusicLoadCmd` is the BGM id and is stored in `$06F2`); `warps_interaction.asm:46` calls the name a misnomer; `item_use_system.asm:1741,1752` calls the same word "the original music ID". The first half of OQ-29 (chest fanfare tracks) stays separate. |
| **Plain versus tagged build** | OQ-I026-1 | OQ-49 | **True duplicate** (same five-file `transforms.json` multi-line effect). V `results/I025_results.md:56`; `I026_results.md:54`; `I021-I040_sanity-check.md:16`. OQ-I056-9 is *related* (a rebuild failure after the first `extract:lt`) but names a different failure (`CrystalBallAutoUse`, `CODE_05F522`); keep it separate and link it. Kind: DECISION (tooling). |
| CT69 collision types `$06/$09` | OQ-16 | OQ-I029-5, I030-3, I032-4, I033-4, I040-4, SAN2-2, I039-2, I039-3 | Duplicates; the last three also carry geometry questions (partial). The *direction* half of OQ-I040-4 and OQ-SAN2-2 is answered statically (`player_move_east.asm:26`). RC-20. |
| ADHOC | OQ-45 | OQ-64 (answered), OQ-I022-4 | Duplicates. |
| F10-0200 (player `$10` `$0200`) | OQ-I023-3 | OQ-I027-2, I030-2, I032-5, I036-4; OQ-60 (part) | Duplicates; static readers exist (RC-01). |
| F10-2000 (actor `$10` `$2000`) | OQ-I026-6 | OQ-I025-2, OQ-I053-3; OQ-60 (part) | Duplicates (partial for the two: setter/hidden effect). **OQ-I033-6 does not belong:** it asks about `$0E = $2000` (OAM attribute priority bits), a different word. |
| F10-0008 | OQ-20 | OQ-I023-6; OQ-60 (part) | Duplicates. |
| F10-0080/0400 | OQ-8 | OQ-I041-6, OQ-I049-3 | Duplicates (RC-04, RC-05). |
| FLAG00 (event flag `#00`) | OQ-I030-1 | OQ-I048-1, OQ-I052-1 | Duplicates. **OQ-I048-5 does not belong** (playerSpeedEw/Ns, experiment B3). |
| AA-BITS | OQ-I029-3 | OQ-I045-1 | Duplicates (RC-19). |
| DMF (displayModeFlags consumers) | OQ-23 | OQ-42, OQ-51, OQ-I034-1, OQ-I057-4; OQ-6 (remainder) | Duplicates by object but different bits (0, 4/5, 13, 14). OQ-23/I034-1/I057-4 have static readers (RC-08, RC-09). OQ-51 (bit 13) was not re-checked. |
| LPF | OQ-36 | OQ-I059-5 | Duplicate. OQ-12 is related (buffer overlap), not the same question. |
| HDR411 | OQ-I055-4 (**answered by B001**) | OQ-I063-4 | Duplicate, answered. OQ-I066-4 splits: reader half answered, damage half runtime. |
| PBUNDLE (appearance of palette and fixed-colour effects) | OQ-I060-5 | OQ-I027-6, I028-6, I029-6, I031-4, I036-6, I040-3, I044-1 (OQ-I026-4 is a member of the inventory cluster but stays OPEN here: the I029 questions file gives a partial answer) | Same experiment (E2), different bundles: one run of E2 answers all. **OQ-I060-6 does not belong** (static padding question). |
| TOOL-MSH | OQ-I024-1 | OQ-59 | Duplicate. |
| GEM | OQ-I049-5 | OQ-I051-7 | Duplicate. |
| Dark Space animations | OQ-B001-1 | OQ-I056-7 | Duplicate (the inventory topic says so; not in the cluster table). |
| UNREF reachability census | OQ-I072-3 | OQ-I023-5, I034-3, I038-4, I039-4, I045-4, I048-4, I049-1, I049-7, I050-5, I057-2, I057-5, I067-4, I068-2 | **Method only.** Each member is its own object; the census must be run once but the result is recorded per member. The inventory claim that answering the canonical row answers every member is wrong here. (I067-5, I069-4, I071-5 leave this group, see the hidden-group row.) |
| CAM | OQ-I050-2 | OQ-I049-4, I050-4, I025-7 | Method only (camera target recomputation); OQ-SAN2-1 (shake sound) is not a camera question. |
| UPLOAD | OQ-31 | OQ-1 | Not duplicates: OQ-1 is slot invalidation in `LoadBgTiles`, OQ-31 is `PaletteStep` re-calling `DecompressGfxToVram`. |

Duplicates counted in the registry: 39 rows are `DUPLICATE-OF` (V: rg count; CT69 8, ADHOC 1, F10-0200 4, F10-2000 2, F10-0008 1, F10-0080/0400 2, FLAG00 2, AA-BITS 1, DMF 2 (OQ-I034-1, OQ-I057-4; OQ-42 and OQ-51 stay OPEN, they concern other bits), LPF 1, HDR411 1, PBUNDLE 7 (OQ-I026-4 stays OPEN, partly answered), TOOL-LT 1 (OQ-49), TOOL-MSH 1 (OQ-59), GEM 1, `$06F2` 1, hidden groups 2, Dark Space 1).

## 5. Cross-file reconciliation (report §8.7)

Every flag bit or shared mnemonic that more than one iteration (or more than one file) explained. "Code supports" names the explanation the live code backs. All rows are static; where a reader exists the claim is E1, where only a documentation statement exists it is E3.

| RC | Item | Explanations found (file:line, iteration) | Code supports | Tag |
|----|------|-------------------------------------------|---------------|-----|
| RC-01 | Actor `$10` bit 9 `$0200` | (a) "game over": old name `SetPlayerGameOverFlag`, comment at `combat_collision.asm:1207` ("`$0200` game-over / `$0080` iframe-active"). (b) "no reader found": `StopPlayerOnDeath.asm:5,21`. (c) "player must not be hit, excluded from the normal enemy-hits-player pass": `SetPlayerGameOverFlag.asm:3`. (d) "slide-active, reader unknown": I023/I027 notes. | (c). Readers exist: `combat_collision.asm:333` (skip mask `$76E0`), `:340` (friendly pass `$74E0` allows it), `:1207` (`BIT #$0280` sends the actor to the friendly-only pass). (a) confuses it with `playerFlags $0200` (`combat_collision.asm:162,170,174`). (b) is contradicted by (c) in the sibling file. | V |
| RC-02 | Actor `$10` bit 13 `$2000` | (a) hidden for `SortActorsByDepth` and script-driven path of the runner: `actor_execution.asm:105,142`, `attack_ability_system.asm:57`, `dark_space.asm:14`. (b) "ability-hijacked state" (I025), "frozen flag" (I053 corrected it). (c) "display flags variant 1/2" for `$3000/$2000` (corrected in I053: they are OAM priority bits of `$0E`, `hit_switch.asm:5`). | (a): two readers, both consistent. `$0E` `$2000/$3000` is a different word (attribute priority); OQ-I033-6 concerns that word. | V |
| RC-03 | `$0008` in three words | actor `$10` bit 3 (collision-aware movement, `actor_execution.asm:198,206`; "grounded or player-hit" is the open question OQ-20); `playerFlags` bit 3 combat lock (`actor_execution.asm:9`); logical use-item button `joypadHeld $0008` (`item_use_system.asm:16`, `transforms.json`). | Three unrelated words. The notes name the word in each case; OQ-20 only concerns the first. | V |
| RC-04 | `$0080` in four words | actor `$10` bit 7 hit marker with signed `iframeCounter` (`actor_execution.asm:25,159`; `sprite_composition.asm:532,568`); required in the phase-1 test "role unresolved, OQ-8" (`combat_collision.asm:210`); `displayModeFlags` bit 7 display filter (`actor_execution.asm:9,11,242`; set by `item_use_system.asm:1741`); logical attack bit from `remapA $8080` (`transforms.json:756`; `actor_execution.asm:9` strips it); `playerFlags $0080` (spawn flag path). | The actor bit is a hit/recovery marker (RC-07). The phase-1 test is the part still open (OQ-8). | V |
| RC-05 | Actor `$10` bit 10 `$0400` | "defeated enemy": `combat_collision.asm:210`; "victim is the player": `hit_stagger_controller.asm:5` (old note said enemy); no-op test `sprite_composition.asm:572`; drop pickup (OQ-I049-3, `EnemyDropSystem`). | Not unified. At least two different roles; one id (OQ-8) covers all. | V |
| RC-06 | Actor `$12` bits | `$0001` post-hit mode (`$FFEF` recovery vs `$0011`): `combat_collision.asm:53`, `hit_switch.asm:5`. `$0002` mirror lock: `cop_handlers_sprite.asm:329-331,344`. `$0004` pause-filter immunity: `dark_space.asm:9,76`; `actor_execution.asm:13`. `$0008` movement request of script-driven actors: `actor_execution.asm:346,495,586,676`; `hit_stagger_controller.asm:62`. `$0010` stagger/damage immunity: `combat_collision.asm:210`; `hit_switch.asm:5` (wram map said "push in progress"). `$0020` boss, no damage digits: `combat_collision.asm:751`. `$0200` skip snapshot/turn in the chat routine: `global_ambient_dispatcher.asm:19,233`. `$1000` display or overlay active: `actor_execution.asm:11,17,242,255-258,622`. `$2000/$4000` Y/X flip of the movement delta: `tile_collision_physics.asm:78,80,93`. | The 8 explanations do not collide with each other (each bit one meaning). The `$1000` bit qualifies in `$10` or `$12` for the display-filtered pass but only in `$12` for the overlay pass. The meaning of `$0200` (OQ-I044-2) is described by its reader, not explained. | V |
| RC-07 | `iframeCounter` (`$7F0028`) sign | `actor_execution.asm:25,106,159`: positive = hit-stun (non-player actors skip their tick, so victims freeze); negative = recovery/invincibility; `combat_collision.asm` skips victims with a negative counter. `combat_collision.asm:53`: "set: negative `$FFEF` (recovery/stagger phase); clear: positive `$0011` (17 frames of invincibility)". `sprite_composition.asm:532`: flash from the counter. | `actor_execution.asm:25` (the reader of the counter). `combat_collision.asm:53` has the sign meaning reversed (finding A12-03). | V |
| RC-08 | `displayModeFlags` bits 0, 4, 5 | "BG3 tilemap dirty" (`inventory_menu`), "status bar visibility" (a `system_core` HUD routine, per OQ-23), "consumer not traced" (`DialogStringRenderer.asm:142`), "full BG3 upload" (`sFA_diary_menu.asm:7`; `system_core.asm:379`). | `camera_tilemap.asm:880-892`: `Bg3TilemapVramDma` tests mask `$31`; bit 0 = full upload of `$0800` bytes, bits 4/5 = partial `$0140` bytes; bits cleared after the transfer. "Not traced" is stale (A12-01). | V |
| RC-09 | `$09ED` bits (= `displayModeFlags` high byte) | `displayModeFlags` bit 14 "no reader found" (`sFB_boot_logo.asm:5,49`, OQ-I034-1, `inventory_overlay` cites it too); "HUD off" (`sFA_diary_menu.asm:7`; `system_core.asm:379,401`); bit 6 of `hudDisableFlag` (`scene_lifecycle.asm:924,936`); bit 7 of the same byte suppresses the BG3 upload (`camera_tilemap.asm:880-882`). `db-us/mnemonics.json:162` `"2541": "hudDisableFlag"`. | Bit 14 = `hudDisableFlag` bit 6 = HUD off, read by `UpdateHUD` (`system_core.asm:396`) and the HUD routine (`scene_lifecycle.asm:936`). Bit 15 = BG3 upload gate. "No reader found" is wrong (A12-02). | V |
| RC-10 | `playerFlags` bits | `$0008` combat lock (`actor_execution.asm:9`); `$0010` terrain shake (`actor_execution.asm:9,13`); `$0020` boss-defeat latch and `$0200` game over (`combat_collision.asm:162,170,174`); `$0800` script lock (`item_use_system.asm:1741`); `$2000` guard stance (`sFA_diary_menu.asm:7`: `$2800` = lock + guard). | Consistent with the `AGENTS.md` table. Only the *actor* `$0200` is repeatedly confused with this word (RC-01). | V |
| RC-11 | Facing numbering | 0 = S, 1 = N, 2 = W, 3 = E: `cop_handlers_player_query.asm:10,504,508`; `hit_stagger_controller.asm:6`. Old: "0=N,1=E,2=S,3=W" for `BranchOnPlayerFacing`; `CardinalToPlayer` uses N/E/S/W. | 0 = down, 1 = up, 2 = left, 3 = right (consistent in live notes; OQ-22 answered statically). | V |
| RC-12 | `$06F2` / `$06F4` / `$06F6` | `$06F2` named `musicParentActor`; notes call it "the BGM id" (`scene_meta.asm:23`), "the original music ID" (`item_use_system.asm:1741,1752`), "misnomer, see the audit rename proposals" (`warps_interaction.asm:46`). `$06F6` `musicRoomGroup`: the SPC transfer runs only when the group matches (`scene_meta.asm:23`). `item_use_system.asm:920` writes `$0E` into `$06F2` for the Memory Melody. | `$06F2` = BGM id (stored by `SpcMusicLoadCmd`); the name is wrong; a shipped note points at the audit's rename proposals (A12-15). | V |
| RC-13 | `climbStateData` (`$09E0`, `$09E2`) | Name suggests climb state; code: added to hit strength (`combat_collision.asm:39,683,749,766-780`), set from the ability damage tables (`attack_ability_system.asm:38,1647,1671`); noted in `player_character.asm:40,131,1835`, `slider_glide.asm:13,411-414`. | It is the ability damage bonus (`$09E0` Will, `$09E2` Freedan). The mnemonic name is the defect (A12-16). | V |
| RC-14 | `hpToHeal` (`$0B22`) | "heal request played out as the HUD HP recovery animation" (WRAM map; `debug_stat_setter.asm:28`); "no reader found" (`debug_stat_setter.asm:5`, OQ-I035-6). | The reader exists: `system_core.asm:416-423` (decrements it, raises `playerHp`, sound `$0D`; `:382-383`). Note at `debug_stat_setter.asm:5` is wrong (A12-06). `$7F0B22` in `Mode7PerspectiveInit` (OQ-I041-1) is a different word. | V |
| RC-15 | `gfxCacheIdxA/B` (`$0648/$064A`) | Names suggest graphics cache indices; notes call them scene-transition parameters: `sFC_title_start_handler.asm:7` (`B` = speed, `A` = exit/enter type), `dark_space.asm:17` (`B := $0101` speeds, `A := $0200` effects). Used with `QueueMapChange`/warps (OQ-I042-6). | Transition parameters (static: both files store them before the scene change). The mnemonic name is misleading (A12-14). Where else the two words act as cache indices was not checked. | V (2 sites) |
| RC-16 | `globalScriptIndex` (`$0AAC`) | Dark Space room variant 0-3 (`sE6_gaia.asm:6`); also the ability index into the name/description tables (`sE6_gaia.asm:22`); `GaiaHint_AuraItem` tests it (`:87`); saved in `$0AB2` and restored by the diary menu (`sFA_diary_menu.asm:365`). | One byte with two roles inside Dark Space (variant, then ability index). The name does not say either. OQ-I056-4 (value 1 only in the pyramid) is consistent with `DS_LayoutSpecial`. | V |
| RC-17 | `$1000` of actor `$10` versus `$12` | Display-active: `$10` or `$12` qualifies in `RunActors_DisplayFiltered`; only `$12` in the overlay pass (`actor_execution.asm:11,17,242,255-258,622`). | Consistent across the pass descriptions. | V |
| RC-18 | Button vocabulary | Physical bits: `vblank_joypad.asm:20,189` (B `$8000`, Y `$4000`, Start `$1000`, Select `$2000`); `WorldMapController.asm:566` (Start `$1000` raw). Logical bits of this build (`transforms.json:755-758`: `remapB $4008`, `remapA $8080`, `remapY $0040`, `remapX $0004`): `MenuSelectionHandler.asm:12,43` ("B ($4000) cancel"), `inventory_menu.asm:326,359,473` ("B ($4000), A ($8000)"), `global_ambient_dispatcher.asm:13,105` (`$8000` interact: B in vanilla, A here), `item_use_system.asm:16` (use-item `$0008`), `GlobalInputHandler.asm:34` ("vanilla Y $4000"). | The three vocabularies are each internally consistent but one file's "B ($4000)" is another's "Y ($4000)". The labels in the menu files are right only for the transformed ROM (A12-13, class 13). OQ-I057-1 and OQ-I044-4 depend on this. | V |
| RC-19 | `$AA` / `$AB` | `$AA` bits `$0800/$0400` tested, never set: `player_move_main.asm:14`, `player_move_west.asm:7,893,952`, `player_move_south.asm:3`. `$AB` bit 1 read by `player_move_ns`; bits 2/3/7 set, never read (`player_move_west.asm:7`). Old comments called them "south wall / east wall contact". | Consistent in the four files. The negative claim ("no setter in `extracted/`") is E1 over the extracted text only. OQ-I029-3 = OQ-I045-1. | V |
| RC-20 | Collision types `$06`/`$09` | Same description in `tile_collision.asm:7`, `tile_collision_physics.asm:57`, `player_move_west.asm:15`, `player_move_east.asm:5`, `player_move_south.asm:10`, `player_move_ns.asm:5`: "wall-like, undecoded", with "north/south" read as handler names. Push direction: `player_move_east.asm:26` (`$09` pushes south, `$06` north), from `I040_results.md:16`. | Consistent. No file claims a decoded meaning. OQ-16 stays open (runtime). | V |
| RC-21 | Event flag `#00`; `cameraDeltaX/Y`; `forcedScrollOverride` (`$06C8`); `orbitAngle`; `chatPtr` bit 15; `$12 $0001` target | Event flag `#00` (`scene_flag_init`, `shadow_shimmer`, `player_character`); `cameraDeltaX/Y` named as deltas but hold positions (A05/A06 reports); no reader for `$06C8` (OQ-I051-2); `orbitAngle $40` east (OQ-I045-5). | Not re-checked in A12. | R |

## 6. Ids cited in shipped text (feed A09/A10)

Counts (V, rg line counts): `notes/partNotes` 64 lines (banks 00:17, 01:6, 02:14, 03:12, 08:2, 0C:4, 0E:4, 0F:4, 15:1), `notes/blockNotes` 93 lines (00:38, 01:9, 02:12, 03:10, 08:3, 0A:3, 0B:3, 0E:2, 0F:2, 14:4, 15:1, 17:5, 1D:1), `notes/comments` 79 lines (00:29, 02:30, 03:16, 08:1, 0A:2, 0B:1). Banks 00-01 total 99 lines, which matches A09's "99 notes". Docs: `docs/code/bank03/radar-and-world-map.md` and the corpus copy `gaia-knowledge/corpus/games/iog/project-docs/radar-and-world-map.md` cite OQ-I058-1. `gaia-core/docs/notes-and-comments.md` cites OQ-I021-1, OQ-I021-2, OQ-1, OQ-69 as examples only.

**147 of the 358 ids are cited in shipped extracted text** (25 legacy ids, B001-1 and B001-2, 120 iteration ids; V by rg). All 147 are defined in `questions/*.md` (no undefined id is cited). 211 ids are never cited.

Cited ids by status:

| Class | Ids (cited in shipped text) | Action for A09/A10/F09 |
|-------|-----------------------------|------------------------|
| Answered or closed, id still cited (class 7 with history) | OQ-5 (`display_preset_table`), OQ-61 (`cop_handlers_audio`, `hdma_dma_spc`), OQ-64 (`hdma_dma_spc`, `radar_map_screen`), OQ-I029-4 (`player_move_west`, `player_move_east`), OQ-I054-1 (obj0, obj1), OQ-I025-2 (partly answered; `dark_space.asm:14` says "answers part of OQ-I025-2") | Rewrite as plain statements; drop the id (F09) |
| Duplicate ids cited (several ids for one question) | OQ-I029-3 + OQ-I045-1 (`player_move_west/east/main`), OQ-16 + OQ-I029-5 + OQ-I033-4 (`player_move_*`, `tile_collision*`), OQ-I023-3 family (`ramps` cites OQ-I032-5; `SpawnDebrisBurst`, `SetPlayerGameOverFlag` cite OQ-I030-2), OQ-I034-1 (+ OQ-23 in `DialogStringRenderer`) | Keep one id per object if the policy keeps ids, otherwise plain sentences |
| Static-answerable and the shipped text claims "none found" | OQ-I034-1 (`sFB_boot_logo.asm:5,49`; `inventory_overlay`), OQ-23 (`DialogStringRenderer.asm:142`), OQ-I035-6 (not id-cited; `debug_stat_setter.asm:5` states it) | Correct the text first (A12-01, -02, -06) |
| Open, runtime | all other cited ids | Id may stay only if the policy decision of A12-11 allows it |

Files with the most id occurrences (V, read off the rg list, not an exact count): `player_move_east`, `player_move_south`, `player_move_ns`, `player_character`, `player_transition_handlers`, `item_use_system`, `radar_map_screen`, `inventory_overlay`, `field_reveal_object`, `WorldMapController`. The sprite-set files carry one to four each.

## 7. Findings

Defect classes are the numbers of `PLAN.md` (3 stale after a finding, 4 history narration, 6 inline comment contradicts code, 7 OQ/R id in text, 8 hidden groups, 9 mnemonic candidate, 11 wrong flag-bit meaning, 13 button names).

| ID | Tag | File:line | What is wrong | Proposed fix | Class |
|----|-----|-----------|---------------|--------------|-------|
| A12-01 | V | `DialogStringRenderer.asm:142` | Comment: "consumer not traced; see audit OQ-23". The consumer is `Bg3TilemapVramDma` (`camera_tilemap.asm:880-892`, mask `$31`, bit 0 = full upload). The comment cites an audit id, too. | Note correction in the `merge` spec (name the consumer; drop the id). OQ-23 and its DMF duplicates are static-answerable; record the answer in a new results file. | 3, 7, 11 |
| A12-02 | V | `sFB_boot_logo.asm:5,49`; `inventory_overlay.asm` (cites OQ-I034-1) | "displayModeFlags bit 14: no reader found". Bit 14 is `hudDisableFlag` bit 6, read by `UpdateHUD` (`system_core.asm:396-401`) and the HUD routine (`scene_lifecycle.asm:924-936`, `scene command $02` sets it per scene). | Rewrite both notes: "bit 14 hides the HUD (read by UpdateHUD)". The diary note (`sFA_diary_menu.asm:7`, "bit 14 = HUD off") already says so. | 3, 11 |
| A12-03 | V | `combat_collision.asm:53` | The sign meaning of the iframe counter is reversed: it calls positive `$0011` "17 frames of invincibility" and negative `$FFEF` "recovery/stagger". `actor_execution.asm:25,159-165` (the reader) says positive = hit-stun (non-player actors freeze), negative = recovery/invincibility, and `combat_collision` skips victims with a negative counter. | Fix the sentence at `combat_collision.asm:53` and the matching phrase at `:751` ("sets the iframe counter ($FFEF or $0011)") to the actor_execution convention. | 6, 11 |
| A12-04 | V | `combat_collision.asm:1207` | Inline comment "`$0200` game-over / `$0080` iframe-active" on `BIT #$0280` of the actor's `$10`. `$0200` of the actor word is "must not be hit" (RC-01); game over is `playerFlags $0200`. | Replace the comment: "`$0200` player not hittable, `$0080` hit/recovery marker: friendly pass only". | 6, 11 |
| A12-05 | V | `StopPlayerOnDeath.asm:5,21` | Says no reader of actor `$10` `$0200` was found, while `SetPlayerGameOverFlag.asm:3` and `combat_collision.asm:333,340,1207` show the reader. Two files of the same area contradict each other. | Same pass as A12-04: cite the skip masks; mark OQ-I023-3 family static-answerable. | 3, 11 |
| A12-06 | V | `debug_stat_setter.asm:5` | "no reader of `$0B22` was found in extracted/". `system_core.asm:416-423` (`UpdateHUD`) reads, decrements it and raises `playerHp`. | Correct the note; OQ-I035-6 is static-answerable. | 3, 11 |
| A12-07 | V | `hdma_dma_spc.asm:21,27,363,370`; `cop_handlers_audio.asm:3,59`; `radar_map_screen.asm:76`; `display_preset_table`; `player_move_east.asm:26`; `boot_logo_enix_palette_obj0.asm:19`; `obj1.asm:8`; `dark_space.asm:14` | Notes cite the ids of questions that are answered (OQ-5, 61, 64, I029-4, I054-1, partly I025-2). The text narrates the answer ("answers OQ-61", "was left open") instead of stating the fact. | F09 id-citation spec; remove the ids and the history phrases. | 4, 7 |
| A12-08 | V | `mesen2-question-inventory.md` | The inventory is stale for 8 answered ids and lists them as open: OQ-5 (S), OQ-7 (D), OQ-22 (R), OQ-I027-5 (D), OQ-I029-1 (R), OQ-I029-4 (R), OQ-I054-1 (R), OQ-I055-4 (R). A05-08 covers only the last two. | The OQ document built from this registry replaces the inventory rows. | - |
| A12-09 | V | `mesen2-question-inventory.md` cluster table and topics | (a) OQ-I033-6 is in F10-2000 but asks about `$0E` priority, not actor `$10`. (b) OQ-I048-5 is in FLAG00 but asks about `playerSpeedEw/Ns`. (c) OQ-I060-6 is in PBUNDLE but is a static padding question. (d) UPLOAD pairs OQ-1 and OQ-31, which are different questions. (e) The inventory says "answering the canonical row answers every member", which is false for UNREF, CAM and PBUNDLE (method only). (f) OQ-I042-4's topic says "`$12` bit 1 iframe mode", but the question and the code are bit `$0001`. (g) The hidden-group trio is classed RUNTIME+S although it is static (STATIC + tooling). (h) The OQ-29 / OQ-I065-3 duplicate and the OQ-B001-1 / OQ-I056-7 duplicate are missing from the cluster table. | New OQ document uses the groups of §4. | - |
| A12-10 | V | `mesen2-question-inventory.md` headings; `A02_findings.md` registry | Section headings give 56 / 53+2 / 63 / 60 ids for I021-I030 / I031-I040 / I051-I060 / I061-I072; the rows are 55 / 57+2 / 64 / 56. The total 358 is right. A02's registry has 54 rows and omits OQ-I025-7 (55 ids defined). | Note in the OQ document; A02 stays frozen. | - |
| A12-11 | V | `gaia-core/docs/notes-and-comments.md:1370-1372` | The id convention says the legacy numbers "are cited from asm notes and remain valid", which encourages ids in note text, while the audit (H-3, class 7) treats ids in notes as a defect and A11 AP17-04 records that no policy exists. | DECISION for the owner: either keep ids out of notes (then update this doc and run F09 on 147 cited ids) or define when an id may stay. Do not remove ids before that. | 7 |
| A12-12 | V | `spriteset_transform_poses.asm:7,1013,1358`; `spriteset_will_abilities.asm:25`; `spriteset_pickups_effects.asm:1135`; `inventory_spritemap.asm:1064,1080` | 9 hidden groups in 4 files described as extractor artefacts; three ids (OQ-I067-5, I069-4, I071-5) ask one question. | The extractor fix (T02/A15) solves all nine; rewrite the four notes after it; close the three ids together. | 8 |
| A12-13 | V | `inventory_menu.asm:326,359,473`; `MenuSelectionHandler.asm:12,43` versus `vblank_joypad.asm:20,189` | "B ($4000)" and "A ($8000)" are logical bits of the transformed build; the physical map in `vblank_joypad.asm` has B = `$8000`, Y = `$4000`. Both are right in their own vocabulary but the files do not say which one they use. | One header line per file (physical or logical, plus the `transforms.json:755-758` remap). | 13 |
| A12-14 | V (2 sites) | `sFC_title_start_handler.asm:7`; `dark_space.asm:17`; mnemonic `gfxCacheIdxA/B` | The mnemonic says "cache index" but two files use the words as scene-transition speed and type. | A14 mnemonic backlog: rename or document (runtime check of other uses first). | 9 |
| A12-15 | V | `warps_interaction.asm:46` | A shipped note says "(see the audit rename proposals)", pointing at a ledger. `$06F2` `musicParentActor` is the BGM id (`scene_meta.asm:23`). | Rename the mnemonic (A14), drop the pointer. | 4, 7, 9 |
| A12-16 | V | `combat_collision.asm:39,683,749`; `attack_ability_system.asm:38`; mnemonic `climbStateData` | The mnemonic names a climb state; the word is the ability damage bonus. | A14: rename (`abilityDamageBonus` or similar) and update the notes in the same pass. | 3, 9 |

## 8. Not verified / needs Mesen2

- Every RUNTIME row in §3 (about 300 ids): no Mesen2 ROM or state exists, so none could be observed. The registry only classifies them.
- Rows flagged `†` (STATIC-answerable) are pointers, not answers: OQ-23, OQ-I034-1, OQ-I057-4, OQ-I035-6, OQ-I023-3 and its four duplicates, OQ-I044-4 (confirmation of the remap effect still needs a rebuilt ROM), OQ-I037-2, OQ-I037-3, OQ-I051-1, OQ-I042-1, OQ-I049-6 (half), OQ-I050-5, OQ-I060-3, OQ-I070-1, plus the inventory's static rows OQ-19, OQ-21 (remainder), OQ-26, OQ-46, OQ-I022-2, OQ-I060-6. Only the first six were checked in A12 (V); the rest are R (earlier steps or the inventory).
- RC-21 items (event flag `#00`, `cameraDeltaX/Y`, `forcedScrollOverride`, `orbitAngle`, `chatPtr` bit 15) and the `$12` bit setters were not re-searched in A12.
- OQ-42's writers of `displayModeFlags` bits 4/5, and OQ-51 (bit 13) were not searched.
- The negative claims ("no setter of `$AA` `$0800/$0400`", "no reader of `$06C8`") are static over `extracted/`; code reached only through data or runtime-built pointers is not excluded.
- The results-file lines for OQ-5 (I068), OQ-I029-4 (I040) and OQ-I054-1 (I055) were read as ledger text. The values behind them (47 records `$00`, push direction) were not recomputed.
- Evidence of the answered-later rows from A02-A04: I used the registry sections' status; I did not re-open the I021-I050 results files beyond the "answers / resolved" search of §1, so an answered-later id that no file says explicitly could be missing.

## 9. Items for the fix specs

| F-step / owner | Items |
|----------------|-------|
| **New F-step "F12 note corrections" (merge spec)** | A12-01, A12-02, A12-03, A12-04, A12-05, A12-06 (six notes or comments whose claim contradicts live code). Rebuild gate after the merge. |
| **F09 (id citations)** | A12-07 (ids of answered questions), A12-15. Blocked on the decision A12-11. Input: §6, the 147 cited ids, split by class. |
| **Separate OQ document** | The registry of §3, the groups of §4, A12-08, A12-09, A12-10. One row per group for experiments; record RC-01..RC-20 evidence under the canonical ids. |
| **T02 / A15 (extractor)** | A12-12 (9 hidden groups, 4 files). |
| **A14 (mnemonics)** | A12-14, A12-15, A12-16. |
| **Style rule (one header line)** | A12-13 (button vocabulary). |
| **Decision for the owner** | A12-11 (ids in notes: keep or remove). |
| **Static answers to record (new question or results file, not here)** | OQ-23 (with OQ-42 partial, OQ-I034-1, OQ-I057-4), OQ-I035-6, OQ-I023-3 family, OQ-I044-4; mark answered: OQ-5, OQ-7, OQ-22, OQ-I027-5, OQ-I029-1, OQ-I029-4, OQ-I054-1, OQ-I055-4 (and its duplicate OQ-I063-4). |

## 10. Counts

| Item | Count |
|------|------:|
| OQ ids defined (B001 71-id file + I021..I072) | 358 (V) |
| Status OPEN (including partial and static-answerable) | 309 (V: rg count of the registry rows) |
| Status ANSWERED-LATER | 10 (OQ-5, 7, 22, 61, 64, I027-5, I029-1, I029-4, I054-1, I055-4) |
| Status DUPLICATE-OF | 39 (V: rg count; DMF members OQ-42 and OQ-51 and PBUNDLE member OQ-I026-4 stay OPEN because they differ from the canonical row) |
| Kind STATIC | 10 (OQ-5 closed, OQ-19, 21, 26, 46, I022-2, I060-6, I067-5, I069-4, I071-5) |
| Kind STATIC† (static evidence pointer, not answered) | 11 (OQ-23, I023-3, I027-2, I030-2, I032-5, I036-4, I034-1, I035-6, I057-4, I044-4, I070-1) |
| Kind RUNTIME† / RUNTIME+S† (static evidence or static prelude may settle it) | 4 + 3 (OQ-I037-2, I049-6, I051-1, I060-3; I037-3, I042-1, I050-5) |
| Kind DECISION | 7 (OQ-7, 49, 59, I024-1, I026-1, I027-5, I056-9) |
| Kind RUNTIME+S | 35 |
| Kind RUNTIME (plain, plus 5 answered rows marked "inventory" and 1 with a static negative result) | 286 |
| Kind none (inventory X) | 2 (OQ-61, 64) |
| Check: 10 + 11 + 7 + 7 + 35 + 286 + 2 | 358 |
| Ids cited in shipped extracted text | 147 (25 legacy, 2 B001, 120 iteration ids) |
| Cited ids that are answered or closed | 6 (OQ-5, 61, 64, I029-4, I054-1, I025-2 partly) |
| Duplicate groups with a true object duplicate | 18 (see §4), plus 3 method-only groups (UNREF, CAM, PBUNDLE) |
| Reconciliation rows | 21 (all V except RC-21) |
| Findings | 16 (all V) |
| Inventory rows stale (answered but listed open) | 8 |
| Inventory cluster errors | 8 (A12-09 a-h) |
| Static OQ-answerable pointers found in A12 (V) | 6 groups (OQ-23 + DMF, OQ-I035-6, OQ-I023-3 family, OQ-I044-4, OQ-I034-1, OQ-I057-4) |
