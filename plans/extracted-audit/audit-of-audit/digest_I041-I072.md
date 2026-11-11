# Digest — results I041–I072, B001 and the two sanity checks I041–I050 / I051–I060 (all read in full)

Read in full in A00-extended (2026-10-28). VERIFIED = checked against live files in this pass; REPORTED = from the ledger.
Companion digests: `digest_I001-I020.md`, `digest_I021-I040.md`.

## 1. Shape of the range

| Range | Phase | Files per iteration | Style | Q3 verdict |
|---|---|---|---|---|
| I041–I048 | P2 (actors, functions, system) | 3 | one comment per instruction, written for I041, I042, I045, I046 by a scratch spec builder (I049 admits it), I047/I048 by hand | F in every file except 4 (M) |
| I049–I060 | P2 / P3 | 3 | aggregated notes (block note, part note per label, comments only for operands). New header format ("Status: COMPLETE", before/after stats, "Actions taken") | I054 roll-up: **Q3 F in 83 of 91 file tables (91%)** over I025–I054 |
| I055–I060 | boot logos, Dark Space, diary, title, world map | 3 | same | I060 roll-up: Q3 F in 14 of 18 files; 4 NA (sprite files with no prior notes) |
| I061–I072 | P4 `tables/` | 3 (+1 correction in I061) | block note + part notes, no inline comments (data) | I072 roll-up: **Q3 F in 35 of 36 files**; only `parallax_scroll_table` P. Q2 F in 28 of 36 |
| B001 | tooling + 4 sprite files | 4 | merge change `detectBank` and `edit` entries | — |

Notes written in the P4 phase (counts from the iteration summaries): 237 part notes in I061–I072 plus 36 in B001, 12 block notes, no inline comments (data files). "SAMPLED" files (read line by line only in part, whole-file counts by search): `palette_bundles` 3%, `scene_actors` 12%, `movement_delta_table` 59%, `spriteset_freedan` 15%, `spriteset_will` 15%, `scene_meta` 10%, `spriteset_shadow` 10%, `spriteset_ability_fx` 40%, `scene_warps` 18%, `spriteset_enemies` 25%, `dialog_dictionaries` 6%, `inventory_spritemap` 45%, `spriteset_will_alt` 60%. Sampled claims about unread parts rest on counts and byte-budget arithmetic (good) or on nothing (see §6).

## 2. Per-iteration facts that matter later

### I041–I050 (30 files)
- **I041** `mode7_perspective` (Mode 7 `M7SEL = $80` means transparent outside the map, not repeat; `$B6/$B8/$BC` are global words, not actor fields; `$B6` is the divisor increment, `$BC` the rotation), `SpawnAttackTrailEffect` (a damage-number actor, not a weapon trail), `hidden_red_jewel` (flag `$80+`, 16 placements, 7 NPC scripts use its full-inventory path).
- **I042** `overworld_exit` (15 exits, gate flags, 3 "Quit only" menus), `SpawnHitSparkSprites` (item `$86+` sparkle, not a combat spark), `floor_button` (hit-triggered solid switch, Great Wall only).
- **I043** `jeweler_gem` (flag `$E8` = Solid Arm defeated; **game text/code mismatch at 8 jewels**: the string says Strength +1, the code raises max HP; 50-jewel tier has no flag so the menu is unreachable), `town_door` (hold Up 8 frames), `EnemyPositionSnap` (RTI target of COP `SnapToGrid`).
- **I044** `global_ambient_dispatcher` (the "talk to NPC" interaction: probe point, snapshot/restore, Flags12 `$0200` skip), `ApplyOrbitalOffsetXY` (callers: 3 sites, not `statue_inventory_reward`), `incan_ruins_transform_palette` (really Gold Ship, scenes `$2B/$2D/$2F`).
- **I045** `player_move_main` (X at entry is the controller slot, `$AA` bits `$0800/$0400` never set, `ComputeYSnapOffset` 1..16), `ApplyOrbitalOffsetFromRef` (21 JSL sites), `particle_rain_spawner` (unreferenced; diagonal 45° fall, 120→5 tick ramp).
- **I046** `hit_stagger_controller` (`$0400` in child flags = victim is the player; `ReturnAI` shortens the stun to about 17 ticks), `ApplyPlayerHitstun` (9 call sites, A = damage + heavy flag), `EnemyDefeatDispatch` (last-enemy branch, `$26` = remaining count).
- **I047** `player_move_controller` (Flags10 `$0008` = collision-checked movement, not "grounded"), `inventory_statue_slot`, `reward_actors` (`$0ACA` is max HP, `$0ACE` current HP; **dead overflow clamp**).
- **I048** `statue_inventory_reward` (about 15 visible confetti bursts of 60 spawned), `dialog_string_scanner` (scans for the COP `PrintDialogString` opcode word `02 BF`; **pointer test reversed**; 16-bit bank counter wraps through `$FFFF`), `shadow_shimmer` (dead bit freezes palette).
- **I049** `debug_man` (21 warp destinations, 7 menu levels × 3; leaf comments were swapped), `DarkGemDropSystem` (item ids `$83–$86`, HP-tier weighted table; nine drop percentages recomputed), `camera_scroll_controller` (no dead zone; two dead labels `loc_00EB48/74`).
- **I050** `inventory_mgmt` (the `$55` is a reset at the signed overflow `$7F`, not a cap; `debug_man` sets STR/DEF to `$7F` so a STR-up is the one case that triggers it), `npc_wander_ai` (8-case table, half-pixel steps, 13 users), `camera_drift` (three scripts; only the first 8 words of `binary_00D068` used).
- **Sanity I041–I050**: **1,182 comments removed, about 245 rewritten**, 3 stale originals removed, 1 block note + 1 part note corrected. One factual defect: `player_move_main` still said Flags10 `$0008` = "grounded/airborne".

### I051–I060 (30 files)
- **I051** `visual_effect_pipeline` (all 18 old comments belonged to other routines; `cameraDeltaX/Y` is the layer-1 scroll **position**), `boss_clear_reward_handler` (flags per **scene**, boss rows only 5 of 11), `field_reveal_object` (gem vs stat-item families). Corrects I046 (`EnemyDefeatDispatch` stat gem) and I050 (`camera_drift`).
- **I052** `player_transition_handlers` (entered by writing the player actor's entry pointer; "item reveal" is an impact spark; mask `$CFFC`), `SpawnFieldRevealEffect` (4 spawn sites), `EscortFollowPathTracker` (ring of 8 not 9; trail runs opposite to facing).
- **I053** `smooth_follow_child` (aims once, flies straight; 8 handler labels name wrong headings), `dark_space` (monitor entry sequence, variant byte `>>1`), `game_over_sequence` (revive pays 100 gems; two warp records `$0AF0/$0AF4`).
- **I054** `StandardEnemyDefeatHandler` (13 callers; the gem condition was inverted), boot-logo Enix/Quintet thinkers. **P2 phase roll-up (I025–I054, 91 file tables)**: Q3 F 83, M 7, P 1; recurring causes in §4.
- **I055** boot logo scene (`TM = $10` is OBJ; PAL = lockout; flag `$10` reused by South Cape scripts), third palette thinker, `spm_boot_logos` (unnoted; B001 later). **Corrects I054** (the "slot 1, param `#01`" statement, `system_core` "title screen" for scene `$FB`). Answers OQ-I054-1.
- **I056** `sE6_gaia` (1,853→2,166 lines; 142 new + 35 rewritten part notes; `AbilitySceneTable` byte 1 is an ability bit; continue-prompt answers swapped; **dead code**: `DS_AuraItemRoom` cluster, `DarkSpaceAmbientParticle`, 8 hint strings), `diary_entry_table`, `spm_darkspace_sprites`. **Gate anomaly**: first rebuild after extract:lt failed with `Patch CrystalBallAutoUse contains a rewrite that does not exist: CODE_05F522`; a second run produced 3062189; "cause not investigated (OQ-I056-9)".
- **I057** `diary_menu_window_dma` (**transform-adjacency hazard**: `transforms.json` regex needs `diary_band_empty` and `diary_band_slot1` directly adjacent; a part note on either label made the ROM 1 byte shorter and the first gate failed with checksum 223006106 / crc 643346720 / size 3062203), `sFA_diary_menu` (2,084→2,455 lines; STR/DEF were swapped in the state table; SRAM checksum layout), `sFC_title_intro`. Says "I055 and I056 were skipped at the user's request" yet both have results (done later).
- **I058** `sFC_title_start_handler` (`#$1001` bit 0 = raw source, **no R button**), `HdmaWindowEffect` (really a BGMODE/COLDATA split; `#05/#32` are B-bus registers), `spm_title_actors` (blocked). A transient missing `extracted/` left `artifacts/crc.json` with a bad checksum until `extract:lt` + `rebuild` were re-run.
- **I059** `WorldMapController` (Mode 7 zoom/tilt/rotation words, not a falling player; poll condition reversed), `spm_overworld_sprites` (blocked), `world_map_names`.
- **I060** `world_map_options` (82 part notes; `$1C–$26` empty templates; `loc_03B928` is a string decoded as code), `world_map_routes` (blocked; notes parked in the options block note), `palette_bundles` (SAMPLED 3%). I060 phase roll-up: Q3 F 14 of 18.
- **Sanity I051–I060**: fixed `WaitByte(n)` = n stated as n in **12 files** (28 comments, 23 part notes, 7 block notes), derived timings in `game_over_sequence` and `SpawnFieldRevealEffect`, 3 stale words. Observations: orphan note `partNotes/bank03.json` `loc_03B928` (**now deleted**, VERIFIED: no match in `notes/`), "18 of the 30 block notes carry a 'the old header said …' paragraph", `merge` bank-key quirk for `visual_effect_pipeline` (bank 00 code with `?BANK 0A`), the I051–I060 sanity ran a real `ingest` in a temp copy.

### I061–I072 + B001 (36 table files, 4 sprite files)
- **I061** `direction_velocity_table` (a step-code table; byte 1 is a `movement_delta_table` index, **no diagonals**), `body_table` (9 rows; no "Will FX" row), `scene_actors` (16 scene ids share a default list; 14 scene lists without a player). Also corrects `DisplaySceneTitle` ("type/length byte" is the previous record's `$FF`). Tooling stopgap replaced by the blocks.json rule (B001).
- **I062** `ability_anim_tables` (records hold damage bytes → `climbStateData`; file header contradicted `attack_ability_system`), `spriteset_field_fx` (adrift waves, one user), `movement_delta_table` (85 chains = 1 + 58 + 26).
- **I063** `spriteset_particle_fx` (snake pit tile streaming), `shared_word_table` (3 words never selected), `spriteset_freedan` (struct documented once here; **I063's text of this note was later superseded by B001**; the I063 spec must not be replayed).
- **I064** `forced_walk_sequence_table` (camera pan speed lists, not animation frames), `spriteset_town_objects` (one user: Freejia laborer), `spriteset_will` ("flute-play" claim dropped).
- **I065** `dialog_template_table` (speaker colour pairs, ranges were off by one), `parallax_scroll_table` (P), `scene_meta` (a command stream; handler names `SceneCmd_LoadTilemap` etc. do not match their opcodes).
- **I066** `enemy_stats_table` (byte 3 is `gemDropType`, DEF `$7F` is not immunity), `spriteset_aura`, `spriteset_shadow` ("liquify" claim has no support).
- **I067** `item_get_dialog_table` (item names, not messages; 5 wrapper strings), `spriteset_will_projectile` (Dark Gaia fight only), `spriteset_ability_fx` (the seven `Transform_*` scripts of `sE6_gaia`).
- **I068** `spriteset_npc_props` (no chests, no furniture), `display_preset_table` (byte `+6` is BGMODE only; bytes `+8/+9` always 0), `scene_warps` (the second list is **forced-walk warps, not stairs**; all 200 vertical).
- **I069** `spriteset_freedan_fx` (Aura Barrier cast + vine drop attack), `spriteset_shadow_fx` (**body row `$07` never selected**), `spriteset_enemies` (84 actor users; not the largest spriteset). `extract:lt` `rm` failure.
- **I070** `enemy_clear_reward_table` (tiers are stats, not magnitudes), `spriteset_dark_friar` (no hit splash), `dialog_dictionaries` (B has 200 entries not 256).
- **I071** `spriteset_shadow_mode` (the Aura-item "body turns to water" effect; **body row `$08` IS selected** by `PlayerAuraTransformEntry`; contradicts the `body_table` note of I061 and agrees with I069's operand tally), `scene_chest_table` (chests only, no barrier), `inventory_spritemap` (indices `$00–$3F` item icons). Uses a note `edit` entry (not repeatable). `extract:lt` `rm` failure.
- **I072** `scene_thinkers` (`global_ambient_dispatcher` in 59 of 70 lists), `system_strings` (**7 of 10 part notes wrong**), `spriteset_will_alt` (Psycho Dash/Slider/Spin Dash poses). P4 roll-up. `rm` failure again.
- **B001**: `detectBank` order `?BANK` → blocks.json/files.json → labels → tags → names. `merge` gains `edit` entries (`find`/`until`/`with`; `find` must match once). **Admits three helper scripts created and deleted** (`temp/bankscan.mjs`, `notebank.mjs`, `build_B001.py`). Four sprite maps annotated. **Falsifies earlier ledger text**: "8 header bytes after the extents are not read by anything" (I055, I058, I059 draft); the bytes are the hitbox/hurtbox read by `PlayerAttackHitTest`, solid-rect COPs, `RunCombatCollision` and `RunInteractionCollision`. Corrections in 3 earlier block notes.

## 3. Frozen-ledger statements later shown wrong (a reader of the ledger alone is misled)

| Ledger | Statement | Corrected by |
|---|---|---|
| I046 results Q3 | stat table byte +3 gives "a HP / STR / DEF gem" | I051 (gem of 1/2/5 gems; stat items come only from the room tier) |
| I050 results | `cameraDeltaX/Y` are per-frame deltas | I051 |
| I054 results | Quintet thinker slot 1 / param `#01`; Enix "not traced" | I055 |
| I055/I058 results | 8 group-header bytes "nothing reads" | B001 |
| I055 results | `world_map` / `sFB` "title screen" for scene `$FB` | I055 itself (system_core notes) |
| I057 results | "I055 and I056 were skipped" | actual order I057 → I055/I056 (see I063 "I061 and I062 have no results files yet") |
| I061 `body_table` | "nothing selects row 3 or 8" | I069 (tally) and I071 |
| I060 R-I060-3 | bytes after `code_03B922` are "the text Nothing!!" | sanity I051–I060 (empty `[TPL:11]` string) |
| I063 `spriteset_freedan` note | full text including 8 "unread" bytes | B001 (do not replay the I063 spec) |
## 4. Defect classes in this range (counts are file counts from roll-ups, not re-counted)

1. **Purpose guessed from the name** — Q3 F in 35 of 36 table files. Each correction was one search for the reader away.
2. **Wrong flag-bit meaning** — Flags10 `$4000/$2000/$0008/$0080/$0200/$0400`, Flags12 `$0004/$1000/$0200`, `displayModeFlags $0080`, `extendedFlags $0080`.
3. **Hardware misreads** — `TM` bits (`---o4321`), `CGWSEL/CGADSUB`, B-bus operand of `QueueDma` read as a size or channel (I057 `#26`, I058 `#05/#32`, I041 `#1B-#1E`), `#$1001` bit 0 read as R.
4. **Inverted conditions and swapped answers** — gem rule (I054), pointer test (I048), menu wait (I059), continue prompt (I056), "route active" (I058).
5. **`WaitByte(n)` n vs n+1** — recurs: I011 first rule; fixed again in sanity I021–I040 and I051–I060 (12 files). Still wrong in 5 audited files (report N-4). **No n+1 sweep is reported for I001–I020 or I041–I050** (the I041–I050 sanity check does not mention it).
6. **Comment-per-instruction noise** (I041, I042, I045–I048) removed by the sanity pass (1,182). Cost of the style change: the I041–I048 specs are not replayable.
7. **Docs repeat the same wrong claim** — every iteration lists 2–6 doc lines "not edited"; the apply passes corrected most but not all (§5 of report).
8. **Mnemonics reused with different meanings** — `orbitAngle/orbitDiameter` (≥4 meanings: orbit angle, remaining-enemy count, fade counter, ring head, half width/height, home X/Y, start X/Y), `currentHp` (anim base), `chatPtr` (item id), `loopCounter` (speed), `layerPriorityFlag`, `globalScriptIndex` (4 meanings in `sE6_gaia`), `free101C` (knockback tier / pan steps), `cameraDeltaX/Y` (position), `climbStateData` (damage bonus), `invincibilityTimer` (run window), `hpToHeal` (heal counter, still called "damage flash" in 3 docs).
9. **Extractor artefacts presented as ROM structure** — hidden groups printed as sub-sprites (I067, I071, I072, I069), `scene_actors_extract_table`, `meta_label_NN`, `stair-warp` struct for forced-walk warps.
10. **Dead / unreferenced code documented but never marked** — see report §8.

## 5. Process facts from the ledgers (all REPORTED)

- Scratch scripts: I021–I040 apply used `sed`; I041–I050 and I051–I060 used `.mjs` (`mkmap.mjs`, `apply-rename-*.mjs`, `chk.mjs`, `mkspec.mjs`); I045/I046 note specs were generated by a scratch builder (I049 admits it); B001 created and deleted three; `docs1..docs14.mjs`, `docedit.mjs` edited docs. `npm run annotate` was used by the I001–I020 apply pass; `npm run ingest:verbose` was run for real by mistake in the I021–I040 apply pass ("restored"); sanity I051–I060 ran a real ingest in a temp copy. These happened before the rule `no-adhoc-scripts` (I061–I072 use `npm run names`); the rule text says the commands are retired.
- I061/I062 names specs used hex addresses and are **not replayable**; I063+ use decimal integers.
- Out-of-order execution: I035/I036 after I037; I055/I056 after I057; I061/I062 after I063; I065/I066 and I067/I068 etc. paired. Checklist order ≠ time order.
- The rebuild gate is only valid after a fresh `extract:lt` (I056, I057, I058 each saw a bad or transient state); `extract:lt` `rm -rf extracted/*` failed in I011/I012, I069, I071, I072 (handle held; worked around by running the two steps by hand).
- Mesen2 was connected but never had a matching ROM/state; one attempt (apply I021–I040) failed because the save state belonged to another build.
- Files outside the range's scope that were edited: `system_core.asm` (`SystemInit` "title screen" wording), `DisplaySceneTitle.asm` (I061), `EnemyDefeatDispatch`, `camera_drift`, `sFB_boot_logo`, `sE6_gaia`, `WorldMapController` (corrections), docs (apply passes), baserom patches and IOGRetranslation modules (apply passes; not built by `rebuild`).
- The user changed `db-us/types.json` (entry 244008 → `DialogString`) between iterations, turning `loc_03B928` into `dialogstring_03B928`.

## 6. Confidence limits in this range

- Every behavioural claim is static (E1–E4). 100 % of Q7 verdicts are M or P, none higher.
- Sampled data files: claims about the unread parts are count-based. The two largest risks are `palette_bundles` (3 % read; 128 bundles, about 120 without a part note) and `movement_delta_table` (41 % of chains not read value by value).
- `scene_meta`, `scene_warps` and `scene_actors` operand meanings were derived from handler code, which is the right evidence, but the scene-id → place mapping was never decoded for any of the three.
- Sprite-set "who uses animation n" tables were built from `rg` of `SetMetasprite ( @… )` plus the next `Stage*` operand. Indices without a caller are listed as unreferenced; **a caller that passes the index through a variable would be missed** (OQ-I063-2, OQ-I072-4/5/6 list 28 + 10 such indices).
