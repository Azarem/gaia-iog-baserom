# A14 findings: mnemonic / struct / copdef / types backlog consolidation

Step A14 of the audit of the audit. Read-only: no file in `db-us/`, `us/`, `extracted/`, `notes/` or `docs/` was edited. `db-us/mnemonics.json` is user-owned and untouched. No rebuild gate was run because nothing that feeds the extractor or the assembler changed (gate values stay checksum 223006080, crc 2083230829, totalSize 3062204).

All behavioural claims are static (E1 code trace, E2 cross-reference, E3 docs). No Mesen2 ROM or state exists, so nothing here is E5.

Tags: **VERIFIED** = checked in the live files in this step (file:line or `rg` count given). **REPORTED** = taken from a ledger (`renames/`, `results/`, `digest`, `report.md`) and not re-checked.

## 1. Scope and files read

Read for this step:

- `audit-of-audit/PLAN.md`, `report.md` (§3, §8.1, §9-§11), `digest_I001-I020.md`, `A01`, `A07`, `A10`, `A11` findings (operand counts, V-ids).
- `renames/I001-I020_rename-proposals.md` (96 rows); every `renames/I021..I072_renames.md` row that names a mnemonic, raw address, COP, struct, type, override or transform; `B001_renames.md`.
- Q5 ("new mnemonic") lines of `results/I021..I072_results.md`. Rows with an open Q5 (verdict M/F): I050 (R-I050-1, R-I050-2), I057 (R-I057-1, R-I057-2), I059 (R-I059-3); I021..I048 carry the same proposals in their renames files (R-I021-3 ... R-I048-4). All other Q5 lines are NA or "none needed".
- Live databases: `db-us/mnemonics.json`, `structs.json`, `copdef.json`, `types.json`, `overrides.json`, `blocks.json` (lines 996-1047), `mnemonics_new.json`.
- Engine: `gaia-core/src/database/structs.ts`, `mnemonics.ts`, `root.ts`; `src/rom/extraction/writer.ts`, `addressing.ts`; `src/rebuild/assembler.ts`, `assembler-state.ts`.
- Live asm: `extracted/**` (operand counts, evidence lines quoted below); `baserom/` patch sources; `IOGRetranslation/modules/**` and `scripts/generate-package.ts`.

Counting convention: "ops" = `lines/files` of `rg` hits on the old name (as `$name`) or on the raw `$ADDR` (preceded by a space or `(`) in `extracted/`. Comment mentions are included, so counts are upper bounds. "blast" = `notes+docs files` (hits in `notes/`, `docs/`) and `patch/module hits` (hits in `baserom/`, `IOGRetranslation/modules|scripts`).

## 2. Decision legend

| Decision | Meaning |
|---|---|
| RENAME | Change the name of an existing key (mnemonic, COP, struct). Byte-neutral. |
| ADD | Append a new key (new mnemonic, new override). Byte-neutral, but every absolute operand at that address in all files changes text. |
| RETYPE | Change a `types.json` / `blocks.json` part type. Byte-neutral only if the rebuild gate confirms it. |
| SPLIT | Split a block part (blocks.json) into parts. Byte-neutral only if the rebuild gate confirms it. |
| ALIAS-IN-NOTE | Keep the global name; state the per-file meaning in the block note (no key change). |
| LEAVE | No change, with reason (already applied, not expressible, evidence conflict, deferred). |

`ADD`, `RETYPE`, `SPLIT` extend the four requested values (RENAME / ALIAS-IN-NOTE / LEAVE / SPLIT) for rows that are not renames.

## 3. Findings

| Id | Tag | Where | What is wrong | Proposed fix | Class |
|---|---|---|---|---|---|
| A14-F01 | VERIFIED | `writer.ts:195-206`, `317-330`, `120-128`; `addressing.ts:194-196`; `assembler.ts:342`; `assembler-state.ts:372`; `root.ts:278` | A mnemonic is global by address. The extractor replaces every absolute (`Address`) operand at that address in every file, and regenerates the per-file `!name addr` header. Direct-page `Byte` operands are never substituted (`WorldMapSplitEffect.asm:93` prints `LDA $0036` while `:68` prints `LDA $frameCounter`, although key 54 `frameCounter` exists). So "file-local aliases / mnemonics" cannot be implemented in `mnemonics.json`, and a new key for a low address renames every absolute use (`$0020/22/24/26` appear in 284 lines / 84 files, `$0100/$0102` in 114 / 38). | All "file-local alias" ledger rows become ALIAS-IN-NOTE or LEAVE (rows M20-M28, M30, M31, M34, M35, M56, M59-M62, M65). Every ADD row needs a per-file check before it is applied. | none (tooling constraint); adjacent to 9 |
| A14-F02 | VERIFIED | `IOGRetranslation/modules/widescreen/Widescreen.patch.asm:166,170` (`effectDeltaX/Y`), `:169,235,391,447,814` (`mapScrollV`); `modules/apocalypse-gaia/ApocalypseGaia.patch.asm:159,203` (`currentHp`), `:167,168` (`cameraDeltaX/Y`), `:210,211` (`moveXAlt/YAlt`); `scripts/generate-package.ts:212` passes `db.mnemonics` | These patch sources use the old names without a local `!name addr`, so they resolve through `db-us/mnemonics.json` (name to hex fallback, `assembler.ts:342`). Renaming `mapScrollV`, `effectDeltaX/Y` (M13, M16) breaks the Widescreen build. Renaming `currentHp`, `cameraDeltaX/Y`, `moveXAlt/YAlt` would break ApocalypseGaia. Local declarations are safe: `baserom/auto-use-items/HieroglyphPuzzle.patch.asm:6` (`!tileQueryResult 0902`), `minimap_v2_core.asm:111`, `walkable_world_map_core.asm:38`, `WalkableWorldMap.patch.asm:265`. | Edit the two modules in the same change as M13 / M16 (cross-repo, user decision). Keep M18, M20, M28 unrenamed. | none (cross-repo coupling) |
| A14-F03 | VERIFIED | `structs.ts` (`DbStruct`: `types`, `parent`, `delimiter`, `discriminator`, `null`, `tail`); `copdef.json` parts | `DbStruct` has no field-name slot, and a copdef part is a type list only. So struct "field name" proposals (R-I064-4, R-I065-8, R-I066-2, R-I068-2, R-I068-3 `scene-warp`, R-I069-4, R-I060-6b) and COP operand-name proposals (R-I001-78) cannot be expressed. What is expressible: struct renames, `types` retypes, COP renames (id fixed). | Mark all as LEAVE. If field names are wanted, that is a `gaia-core` feature (schema + writer + doc), to be raised with the user; no workaround. | none (tooling gap) |
| A14-F04 | VERIFIED | `blocks.json:1003-1017`; `mnemonics.json` keys 3416, 3418, 3420, 1609, 1611, 1612, 1614 | Several ledger rows are already applied or only half applied: `walk_step_table` (R-I061-1, `blocks.json:1007`, struct still `direction-velocity`); `forced_walk_pan_table` (R-I064-1, `:1005`, type still `&Binary`); `ability_damage_tables` (R-I062-1, `:1014-1017`, parts still `&Binary`); `worldMapChoiceId` / `worldMapRouteId` / `worldMapRouteReturnPtr` (R-I060-5, keys 3416/3418/3420; the ledger spelled the third `worldMapRouteReturn`). | Rows M57, S01, B01, B04 record this. Do not re-propose. | 3 (docs/notes still use old words, see F11) |
| A14-F05 | VERIFIED | `mnemonics.json` (all keys below), `renames/*` | Conflicting proposals for the same address. `$06F2`: `currentMusicIndex` (R-I001-67) vs `musicTrackId`/`currentBgmId` (R-I065-7). `$0902`: `pendingTileVramAddr` (R-I001-83) vs `pendingMetatileVram` (R-I023-5). `$09E0/$09E2`: `abilityDamageBonus` (R-I023-3) vs `willAbilityBonus`/`freedanAbilityBonus` (R-I025-6). `$0D60`: `worldMapCompanion0` (R-I042-4) vs `worldMapPartyArray` (R-I059-3, R-I060-5). `$00BC`: `mode7RotationIndex` (R-I041-3) vs `mode7Rotation` (R-I059-3). `$0648/$064A`: `transitionTypeWord`/`transitionSpeedWord` (R-I001-23) vs the generic reading. `$7F0018/1A`: `moveXIndex` (R-I022-3) vs "dual use" (R-I001-68). `$0AAC`: `scriptVariantIndex` (R-I053-5) vs a three-way split (R-I056-6). | Recommended picks are in the table (later ledger row with the more specific E1, or the name that survives all uses). `$06F2` is a user decision (see M03). | none |
| A14-F06 | VERIFIED | `extracted/system/world_map/WorldMapSplitEffect.asm:1`, `cop_handlers_effects.asm:753-754,776-777`, `scene_lifecycle.asm:588-589`, `cop_handlers_hdma_dma.asm:30` | R-I058-1(b) renames `sineTableA/B` and `S_sineTableB` to BGMODE/COLDATA table names. The same two arrays (`$7E8900`, `$7E8B00`) really are 256-word sine tables in the scroll-wave code (three more files), and the file's own block note already says "keep their names because they are shared with the scroll-wave code". The rename would mislabel those files. | LEAVE (M32). Dual use is already in the note. | 3 (proposal contradicts the live note) |
| A14-F07 | VERIFIED | `camera_scroll.asm:58,66,132,136`; `camera_tilemap.asm:182`; `Widescreen/ApocalypseGaia` (F02) | R-I051-2 calls `cameraDeltaX/Y` a position (`layer1ScrollX/Y`). Live code treats them as a pending offset: `camera_scroll.asm:66` zeroes `cameraDeltaX` after moving it into the override word, `:132-139` adds a running offset to it, and `camera_tilemap.asm:182` copies it to the effect scroll. Both readings fit the static trace. Comments at `:58` and `:132` still say "delta". | LEAVE (M18) until E5; do not edit the "delta" comments without a rename. | 3 if renamed |
| A14-F08 | VERIFIED | `player_transition_handlers.asm:135,152,170,207`; `player_character.asm:680`; `warps_interaction.asm:230`; `scene_script.asm:391,434,1244`; `system_core.asm:636` | `layerPriorityFlag` is a bit field, not one flag: bit `$0200` = camera frozen / field interaction off; bit `$0800` = interleaved-tile mode; bits 0-3 = BG1/BG2 screen base; bit 15 = BG1/BG2 write swap. R-I053-5 only names `$0200`. | ALIAS-IN-NOTE with the four-bit wording in §3.3 (M22). | none |
| A14-F09 | VERIFIED | `sE6_gaia.asm:78,87,144,514,991,1194` | `globalScriptIndex` has at least three roles in one file: Dark Space layout variant (`:78`), "GaiaHint_AuraItem flag" cleared at `:87`, selection state at `:144`. R-I053-5's `scriptVariantIndex` covers only the first; R-I056-6's three-way split is impossible (F01). | ALIAS-IN-NOTE (M21); keep the name. | none |
| A14-F10 | VERIFIED | `system_core.asm:410-423` | `hpToHeal` has one meaning in code: while non-zero it feeds `playerHp` one point at a time (decrement, compare with `playerMaxHp`, clear when full). The "multiple meanings" quoted in `report.md` are a docs problem (`docs/wram-memory-map.md`), not a mnemonic problem. | LEAVE (M29); wording in §3.3. | none |
| A14-F11 | VERIFIED | `cop_handlers_actor_flags.asm:5,75`; `field_reveal_object.asm:70`; `player_character.asm:12`; `warps_interaction.asm:46` | Note/comment text that carries ledger vocabulary or stale names: `cop_handlers_actor_flags.asm:5,75` ("audit rename proposal"; the handler at `:75` branches on EQUAL, so the name `BranchIfCollisionTypeNe` is wrong, C01); `field_reveal_object.asm:70` carries "OQ-I051-4" in an inline comment; `player_character.asm:12` says the `invincibilityTimer` name is stale; `warps_interaction.asm:46` says "so the name is a misnomer (see the audit rename proposals)". | After each rename lands, one `npm run merge` comments spec per touched file (F06 follow-up). OQ/R ids go out of note text. | 7 (OQ / R ids), 3 (stale name) |
| A14-F12 | VERIFIED | `db-us/mnemonics_new.json` (321 lines, no importer found by `rg`) | Dead file: community names from the datacrystal RAM map, not referenced by `src/` or the extractor. It corroborates four proposals (E3, third party, low weight): `$040C` `player_running_timer` (M15), `$00E4` `end_credits_timer` (M02), `$06F2` `current_map_music_track` (M03; also `$06F4` `new_map_music_group`, `$06F6` `current_map_music_group`), `$0902` `bg_single_tile_write_stage` (M11, supports "pending write" over "query result"). It disagrees with the engine on `$0200` (`actor_collision_table`, M01) and `$0B04` (`hp_healing_amount`, M39); E1 code wins (AGENTS.md: prefer handler asm over third-party claims). | None for the file. The user may delete it or keep it as reference. | none |
| A14-F13 | VERIFIED | `rg` counts: `$0404/$0405` 27 / 9 files; `$0402` 23 / 7; `$00AC..$00B2` 22 / 6 | R-I021-3 asked for `$0402` (12 `JSR $0402` lines in 6 files per the ledger) and `$0404/$0405` names. The live raw counts are higher (comments and other uses), and `$0404/$0405` are shared with unrelated uses. A global key would rename all of them. | M36 ADD only after a per-site check; M54 LEAVE. | 9 |
| A14-F14 | REPORTED | R-I043-3 | The `#$0B1C` operands in the four `spm_*` sprite files are sprite-part parameters, not the upgrade-level word. Whether the extractor substitutes immediates (`#$0B1C`) was not checked. | Dry-run `npm run extract:lt` and diff the four `spm_*` files before applying M43. | 9 |
| A14-F15 | VERIFIED | `rg` for `[SL]_<old name>` over the 21 old names of M01-M17 (plus `cameraDeltaX`, `moveXAlt`) in `extracted/`, `baserom/`, `modules/`: 0 hits | The extractor also emits short-form `S_name` aliases (`WorldMapSplitEffect.asm:24`). None of the renamed names has one in use. | No extra work for the RENAME rows. | none |
| A14-F16 | VERIFIED (code search) / REPORTED (tool scope) | `package.json:31-32` (`merge`, `names`); `rg mnemonics src/*.ts` finds only `src/index.ts` (loads the file for extraction) | No sanctioned script edits `db-us/mnemonics.json`, `structs.json`, `copdef.json`, `types.json`, `overrides.json` or `blocks.json`: no file in `src/` other than `index.ts` mentions the mnemonics file. By the docs `npm run names` edits only `db-us/names/bankNN.json` and `npm run merge` only notes (REPORTED, `notes-and-comments.md`; not re-read in this step). | F06 can only deliver a reviewed edit list; the user applies it, or a tool is added in `src/` and documented. Not worked around here. | none |

### 3.1 Consolidation table

One row per ledger proposal. Order = byte-safe cost: pure mnemonic renames first (M01-M17), then mnemonic non-renames and appends (M18-M65), then COP renames (C01-C10, name-only, id fixed), then struct renames and field-name proposals (S01-S11), then blocks / types / overrides (B01-B09).

Columns: Ledger id; Address (decimal / hex); Current name (VERIFIED live in `db-us/*.json` unless noted); Proposed; Evidence ids as in the ledger (REPORTED); Ops (lines/files in `extracted/`); Blast (notes+docs files / patch-module hits); Decision; Reason.

**Mnemonic renames, byte-neutral (existing key)**

| # | Ledger | Addr | Current | Proposed | Ev | Ops | Blast | Decision | Reason |
|---|---|---|---|---|---|---|---|---|---|
| M01 | R-I001-54, R-I032-4 | 512 / `$0200` | `deathFlag` | `depthBucketArray` | E1 | 5/1 (`sprite_composition.asm:94,100,247,250,264`) | 2 / 0 | RENAME | `$0200-$03FE` is the depth-sort bucket array; nothing reads a death flag. Cheapest accuracy gain. Prose in `QuintetLz.asm:24`, `StopPlayerOnDeath.asm:5` mention the old name. |
| M02 | R-I001-22 | 228 / `$00E4` | `actorLimitThreshold` | `creditsTimelineCounter` | E1+E2 (E3: `end_credits_timer`) | 34/10 | 2 / 0 | RENAME | Cleared / incremented by the credits timeline, compared with a frame maximum by `HaltIfMaxFrames` (`cop_handlers_offscreen.asm:50-58`). Largest: `sF0_class_dismissed`. |
| M03 | R-I001-67, R-I065-7 | 1778 / `$06F2` | `musicParentActor` | `musicTrackId` (alt `currentMusicIndex`) | E1+E2 (E3: `current_map_music_track`) | 7/5 | 6 / 0 | RENAME | The first music operand is stored there, one id per BGM pointer in all 234 uses (R-I065-7). Two ledger names conflict; recommend `musicTrackId` (E3 says "track"). **User decision.** Notes in `item_use_system`, `music_actors`, `docs/cop/families/audio.md` say "current music ID". |
| M04 | R-I001-49 | 2463 / `$099F` | `sceneStateHelper` | `consoleAttrHi` | E1 | 6/3 | 6 / 0 | RENAME | High byte of the console tile-attribute word `consoleAttrWord` (`$099E`). |
| M05 | R-I001-75 | 2479 / `$09AF` | `playerStateByte` | `playerFlags+1` | E1 | 6/3 | 5 / 0 | RENAME | High byte of `playerFlags` (key 2478, VERIFIED). `+1` suffix follows `gfxCacheIdxA+1`. |
| M06 | R-I001-27 | 8323108 / `$7F0024` | `deathActionIdx` | `eventBlockIdx` | E1+E2 | 19/7 | 16 / 0 | RENAME | Record byte 8; indexes event blocks. 16 notes/docs files mention it: the largest comment follow-up of the batch. |
| M07 | R-I001-28 | 8323112 / `$7F0028` | `iframeCounter` | `hitStunCounter` | E1+E2 | 26/8 | 4 / 0 | RENAME | Signed: positive = stun, negative = recovery. Not invincibility. |
| M08 | R-I001-37 | 8327190 / `$7F1016` | `scratch1010+6` | `customCallback` | E1+E2 | 5/5 | 6 / 0 | RENAME | Callback pointer slot. Caveat: the mummy queen (`pyDD_mummy_queen`) stores a different value there; say so in its note. |
| M09 | R-I001-90 | 8331520 / `$7F2100` | `loopStartPcActor` | `thinkerLoopStartPc` | E2 | 5/1 (both M09 and M10) | 5 / 0 | RENAME | Used only for thinker slots (X < `$1000`); pooled actors use `retPtr2`/`loopCounter`. |
| M10 | R-I001-90 | 8331522 / `$7F2102` | `loopCounterActor` | `thinkerLoopCounter` | E2 | see M09 | 5 / 0 | RENAME | Pair of M09; rename together. |
| M11 | R-I001-83, R-I023-5 | 2306 / `$0902` | `tileQueryResult` | `pendingMetatileVram` (alt `pendingTileVramAddr`) | E1+E2 (E3: `bg_single_tile_write_stage`) | 4/2 | 6 / 1 | RENAME | VRAM address of the staged 2x2 metatile update; the NMI flush clears it. Patch hit: `baserom/auto-use-items/HieroglyphPuzzle.patch.asm:6` declares `!tileQueryResult 0902` locally; the patch still builds, but its name text is stale. Prefer the R-I023-5 name (later, more specific). |
| M12 | R-I001-23 | 1608-1611 / `$0648-$064B` | `gfxCacheIdxA`, `gfxCacheIdxA+1`, `gfxCacheIdxB`, `gfxCacheIdxB+1` | `transitionTypeWord`, `transitionTypeWord+1`, `transitionSpeedWord`, `transitionSpeedWord+1` | E1+E2 (E3: `map_transition_fade_params`) | 137/81 | 21 / 0 (a local `gfxCacheIdxB_exit` is a different name) | RENAME | Four keys, rename as pairs. Largest text churn of the batch (81 files); do last in batch 1. Low byte = exit, high byte = enter (R-I001-23). |
| M13 | R-I035-4 | 1676, 1678, 1680 / `$068C`, `$068E`, `$0690` | `effectScrollH`, `mapScrollV`, `effectScrollV` | `bg2ScrollH`, `bg1ScrollV`, `bg2ScrollV` (`bg1ScrollH`, key 1674, unchanged) | E1 | 56/18 | 11 / **5 hits in `Widescreen.patch.asm`** | RENAME | `UploadScrollRegisters` writes `$068A` BG1 H, `$068C` BG2 H, `$068E` BG1 V, `$0690` BG2 V. Must be applied together with the Widescreen edits (A14-F02). |
| M14 | R-I025-6 (supersedes R-I023-3) | 2528, 2530 / `$09E0`, `$09E2` | `climbStateData`, `climbStateData+2` | `willAbilityBonus`, `freedanAbilityBonus` | E1+E2 | 8/5 | 12 / 0 | RENAME | `LoadAbilityAnimTableA/B` store the table bytes there; `combat_collision` adds both to the damage strength (`:770-780`, `attack_ability_system.asm:1647,1671`). Nothing climbs. `slider_glide.asm:414` text "(named climbStateData)" must be updated with it (class 3, VERIFIED). |
| M15 | R-I025-1 | 1036 / `$040C` | `invincibilityTimer` | `walkRunWindowTimer` | E1+E2+E3 (`player_running_timer`) | 16/3 | 1 / 0 | RENAME | 13-frame run window. `player_character.asm:12` already calls the name stale (class 3). Hit invincibility is a different counter. |
| M16 | R-I051-2 | 1764, 1766 / `$06E4`, `$06E6` | `effectDeltaX`, `effectDeltaY` | `cameraMoveDeltaX`, `cameraMoveDeltaY` | E1 | 12/5 | n/c / **2 hits in `Widescreen.patch.asm:166,170`** | RENAME | Written by `camera_scroll_controller` as target minus current scroll. Lockstep with the Widescreen edit. |
| M17 | R-I056-6 | 1612, 1614 / `$064C`, `$064E` | `warpDestX`, `warpDestY` | `warpPlayerX`, `warpPlayerY` | E1 | 40 lines / 8 files in total (`scene_warps`, `warps_interaction`, `sE6_gaia`, `sFA_diary_menu`, `actor_execution`, `game_over_sequence`, `statue_inventory_reward`, `cop_handlers_player_query`) | n/c / 0 | RENAME | Hold the player's spawn position after a warp; not a destination. Also each of these files declares a local `!warpDestX` header (regenerated). |

**Mnemonic non-renames on existing keys (alias, leave)**

| # | Ledger | Addr | Current | Proposed | Ev | Ops | Blast | Decision | Reason |
|---|---|---|---|---|---|---|---|---|---|
| M18 | R-I051-2 | 1728, 1732 / `$06C0`, `$06C4` | `cameraDeltaX`, `cameraDeltaY` | `layer1ScrollX/Y` | E1 | 76/16 | n/c / 2 hits in `ApocalypseGaia.patch.asm:167,168` | LEAVE | A14-F07: `camera_scroll.asm:66` zeroes the value after use, so "delta" also fits. Needs Mesen2. |
| M19 | R-I051-2 | 1768, 1770 / `$06E8`, `$06EA` | `effectRenderDeltaX/Y` | `layer1RenderDeltaX/Y` | E1 | 6/2 | n/c / 0 | LEAVE | The ledger shows only that the pipeline actors write them; it does not show the layer. The proposed name adds a claim without evidence. |
| M20 | R-I022-3, R-I001-68 | 8323096, 8323098 / `$7F0018`, `$7F001A` | `moveXAlt`, `moveYAlt` | `moveXIndex/moveYIndex` | E1+E2 | 424/70 | n/c / 2 hits in `ApocalypseGaia.patch.asm:210,211` | ALIAS-IN-NOTE | Dual use (movement index vs target pixel position in `InitGravity`, `SpawnFieldRevealEffect`). A rename is wrong in the second group. |
| M21 | R-I053-5, R-I056-6 | 2732 / `$0AAC` | `globalScriptIndex` | `scriptVariantIndex` / split | E1 | 30/12 | n/c / 0 | ALIAS-IN-NOTE | A14-F09. Both proposals are wrong for part of the uses. |
| M22 | R-I053-5 | 1774 / `$06EE` | `layerPriorityFlag` | keep, note bit `$0200` | E1/E2 | 24/13 | n/c / 0 | ALIAS-IN-NOTE | A14-F08. Wording in §3.3. |
| M23 | R-I057-1, R-I046-4 | 8327196 / `$7F101C` | `free101C` | alias `panStepsPerFrame` (diary) / `knockbackTier` (stagger) | E1 | 14/5 (VERIFIED: `hit_stagger_controller.asm:79,81,331,383`; `sFA_diary_menu.asm:284,586,636`) | n/c / 0 | ALIAS-IN-NOTE | Two roles. Per-file alias is impossible (A14-F01). |
| M24 | R-I013-65, R-I036-4, R-I044-4, R-I050-2, R-I052-6, R-I054-2 | 8323088 / `$7F0010` | `orbitAngle` | per-file aliases | E1 | 350/76 | n/c / 0 | ALIAS-IN-NOTE | At least 6 verified roles (see §3.3). A global rename would mislabel 70+ files. |
| M25 | same | 8323090 / `$7F0012` | `orbitDiameter` | per-file aliases | E1 | 189/49 | n/c / 0 | ALIAS-IN-NOTE | Companion of M24. |
| M26 | R-I013-65, R-I052-6, R-I001-80 | 8323082 / `$7F000A` | `chatPtr` | per-file aliases | E1 | 98/33 | n/c / 0 | ALIAS-IN-NOTE | Item id, animation base, track number + 1, half-width, halving-pass counter. |
| M27 | R-I013-65 | 8323092 / `$7F0014` | `loopCounter` | `step speed` alias in `smooth_follow` | E1 | 33/21 | n/c / 0 | ALIAS-IN-NOTE | COP LoopStart counter in general; speed in `smooth_follow.asm:36`. |
| M28 | R-I050-2 | 8323110 / `$7F0026` | `currentHp` | `npcAnimBase` alias in NPC actors | E1+E2 | 93/53 | n/c / 2 hits in `ApocalypseGaia.patch.asm:159,203` | ALIAS-IN-NOTE | HP for enemies; base animation index for the 13 NPC actors. |
| M29 | R-I001 (report N-10) | 2850 / `$0B22` | `hpToHeal` | - | E1 | 14/9 | n/c / 0 | LEAVE | A14-F10: single meaning in code; docs fix only. |
| M30 | R-I001-7 | 8323072 / `$7F0000` | `animScratch` (+0..3) | "rename or split" | E1 | 111/20 | n/c / 0 | ALIAS-IN-NOTE | `$7F0000-$01FF` is the collision flag tables; `animScratch+N,X` is per-actor scratch. No single name is right; global rename impossible. |
| M31 | R-I001-46 | 1616, 1618 / `$0650`, `$0652` | `warpFacing`, `warpScrollParams` | `warpFlagsOrFacing` | E1 | 35/10 | n/c / 0 | ALIAS-IN-NOTE | Three meanings (facing byte, flags, walk-step stream pointer). `warps_interaction.asm:924,938` and `forced_walk.asm:5,192-193` already say "pointer, not a facing byte". Keep the key. |
| M32 | R-I058-1(b) | 8292608, 8293120 / `$7E8900`, `$7E8B00` | `sineTableA/B` (+`S_sineTableB`) | `bgmodeTableOdd`, `coldataTableOdd` | E1 | 10/3 | n/c / 0 | LEAVE | A14-F06. |
| M33 | R-I001-79 | 1039 / `$040F` | `rngState` | base `$0410` | E1 | 6/2 | n/c / 0 | LEAVE | Needs code edits to re-index (not byte-safe); document in the note. |
| M34 | R-I001-76 | `$09EC` | `displayModeFlags` | bit aliases | E1/E2 | 108/57 | n/c / 0 | ALIAS-IN-NOTE | Bit names go in comments / docs only. |
| M35 | R-I046-5 | `$7F002C`, `$7F002E` | `moveScratch1`, `moveScratch2` | `moveDeltaX/Y` (file-local) | E1 | n/c | n/c / 0 | ALIAS-IN-NOTE | File-local names are not possible (A14-F01); note in `hit_stagger_controller` and `EnemyDefeatDispatch`. |

**Mnemonic appends (new key; every absolute operand at the address changes text)**

| # | Ledger | Addr | Current | Proposed | Ev | Ops | Blast | Decision | Reason |
|---|---|---|---|---|---|---|---|---|---|
| M36 | R-I021-3 | `$0402` | none (raw) | `blockMoveStub` | E1+E2 | 23/7 (12 `JSR $0402` per ledger) | n/c / 0 | ADD | Only after a per-site check: the other 11 lines may be comments or a different use. |
| M37 | R-I021-3 | `$00AC`, `$00AE`, `$00B0`, `$00B2` | none (raw) | `vramDmaSrc`, `vramDmaSrcBank`, `vramDmaDest`, `vramDmaSize` | E1+E2 | 22/6 | n/c / 0 | ADD | Matches the DP table in `AGENTS.md` ("IOG Persistent Engine DP State", `$AC-$B2`). Absolute forms only (DP forms stay raw, F01). |
| M38 | R-I024-1 | 1712 / `$06B0` | none | `metatileDefBase+2` | E1/E2 | 1 operand (REPORTED) | n/c / 0 | ADD | Same pattern as `bgTilemapVramBase+2`. |
| M39 | R-I024-2 | 2820 / `$0B04` | none | `savedDialogFrameDelay` | E1/E2 | 5 (REPORTED) | n/c / 0 | ADD | `DialogStringRenderer` restores `$007E` from it. (E3 `hp_healing_amount` disagrees; E1 wins.) |
| M40 | R-I023-5 | `$0904`, `$0906`, `$0908`, `$090A`, `$090C` | none | `metatileQueueTL`, `metatileQueueTR`, `pendingMetatileVramRow2`, `metatileQueueBL`, `metatileQueueBR` | E1/E2 | 17/4 | n/c / 0 | ADD | Staged by `ResolveTileData`, flushed in the NMI. Pairs with M11. |
| M41 | R-I050-1 | `$0DB8`, `$0DB9` | none | `itemGetId` (word, or `itemGetId` + `itemGetIdHigh`) | E2 | 21/5 | n/c / 0 | ADD | Choose one word key `itemGetId` (high byte is always zero). |
| M42 | R-I061-4 | `$0AC8` | none | `playerBodyIndex` | E1 | 7/3 | n/c / 0 | ADD | Written by COP #8E, read by the facing lookup. |
| M43 | R-I043-3 | `$0B16`, `$0B1C` | none | `psychoDashLevel`, `darkFriarLevel` | E1 | 19/4 | n/c / 0 | ADD | A14-F14: check the four `spm_*` files first. |
| M44 | R-I048-3 | `$0B08`, `$0B0C`, `$0B10` | none | `savedTileX`, `savedTileY`, `savedScroll` | E1 | 40/9 | n/c / 0 | ADD | Return position written by the trigger scripts. |
| M45 | R-I044-4 | `$09EE` | none | `talkFacing` | E1 | 9/1 | n/c / 0 | ADD | One file only. |
| M46 | R-I044-4 | `$7F0A40` | none | `cgramPal2` | E1 | 2/1 | n/c / 0 | ADD | `$label+constant, X` is not supported by the assembler, so a separate name is the only way. |
| M47 | R-I042-4, R-I059-3, R-I060-5 | `$0D60` | none | `worldMapPartyArray` | E1+E2 | within 76/19 for `$0D58/5A/5C/60` | n/c / 0 | ADD | Six-word array `$0D60-$0D6A` (`WorldMapController.asm:19-22`); not `worldMapCompanion0`. Entries `$0D62..$0D6A` stay raw. |
| M48 | R-I041-3, R-I059-3 | `$00B6`, `$00B8`, `$00BC`, `$00CA`, `$00CC` | none | `mode7PerspectiveStep`, `mode7Divisor`, `mode7Rotation`, `mode7CenterX`, `mode7CenterY` | E1/E2 | 114/15 for the six words of M48+M49 | n/c / 0 | ADD | `$00CA/$00CC` are also used by other thinkers (ledger caution): per-file check first. `$00BC`: pick `mode7Rotation` (R-I059-3). |
| M49 | R-I059-3 | `$00DA` | none | `spriteTextByteCount` | E1 | see M48 | n/c / 0 | ADD | Not a mode-7 word; separate name. |
| M50 | R-I059-3 | `$0D6C`, `$0D6E`, `$0D6F` | none | `worldMapDeferredScroll`, `worldMapDestScene`, `worldMapSourceScene` | E1 | 34/4 | n/c / 0 | ADD | Written by `ExecuteSceneTransition` / `DeferSceneTransition`. |
| M51 | R-I057-1, R-I057-2 | `$0D74-$0D9E`, `$0D8E`, `$0D90`, `$0D92`, `$0D94`, `$0D96`, `$0D98`, `$0B24`, `$0B26` | none | `diarySlotCursor`, `diaryEditSlot`, `diaryCopyTarget`, `diaryTabCursor`, `buttonType`, `soundMode`, `soundSetting`, `buttonTypeSetting` | E1 | n/c (`$0D92/96/98` also in `diary_menu_window_dma`) | n/c / 0 | ADD | Other files (`world_map_options`) also use these words; per-file check first. |
| M52 | R-I024-5 | `$097E`, `$0980`, `$098E`, `$0990`, `$0992`, `$0994`, `$090E`, `$0910` | none | `dialogBoxOriginCol/Row`, `menuCursorTileOffset`, `menuSavedTileTop/Bottom`, `uiBlinkCounter`, `menuCancelGlyphTop/Bottom` | E1 | 46/3 | n/c / 0 | ADD | `$090E/$0910` only after OQ-I024-3 (not answered here). |
| M53 | R-I056-6 | `$0AB2`, `$0D8C` | none | `darkSpaceVariantSaved`, `activeSaveSlot` | E1 | n/c | n/c / 0 | ADD | Count the raw uses before applying. |

**Mnemonic proposals that need no key change**

| # | Ledger | Addr | Current | Proposed | Ev | Ops | Blast | Decision | Reason |
|---|---|---|---|---|---|---|---|---|---|
| M54 | R-I021-3 | `$0404`, `$0405` | none | `blockMoveDestBank/SrcBank` | E1 | 27/9 | n/c / 0 | LEAVE | A14-F13: many unrelated uses; global key unsafe. |
| M55 | R-I044-4 | `$7E3410` | none | `talkBackup` | E1 | 0/0 raw operands | n/c / 0 | LEAVE | No raw operand exists to rename. |
| M56 | R-I044-4 | `$7F0011`, `$7F0013` | none (inside `orbitAngle` / `orbitDiameter` words) | `orbitAngleY`, `orbitDiameterY` | E1 | 12/4 | n/c / 0 | ALIAS-IN-NOTE | Mid-word addresses of M24 / M25; a global name would suggest a separate field. |
| M57 | R-I060-5 | 3416, 3418, 3420 / `$0D58`, `$0D5A`, `$0D5C` | `worldMapChoiceId`, `worldMapRouteId`, `worldMapRouteReturnPtr` | `worldMapChoiceId`, `worldMapRouteId`, `worldMapRouteReturn` | E1 | n/c | n/c / 0 | LEAVE | Already named; the live third name (`...Ptr`) is better than the ledger spelling. |
| M58 | R-I001-63 | `$069A`; `$7E3184`, `$7E3288`, `$7E330C` | none | `mapDataSize`; `colStrip1Buf`, `rowStrip0Buf`, `rowStrip1Buf` | E1 (blocked on OQ-41) | `$7E3184/88/0C`: 10/1 | n/c / 0 | LEAVE | Deferred. `$069A` needs OQ-41. |
| M59 | R-I031-2 | `$7E7000`, `$7E7100`, `$7E7200` | `tileStagingBuffer` (shared) | `circleWindowTableA/B`, `circleWindowEmptyWord` | E1 | n/c | n/c / 0 | ALIAS-IN-NOTE | `$7E7000` already has a shared name. |
| M60 | R-I045-3, R-I047-3 | DP `$1A`, `$1E`, `$20-$26`, `$AA`, `$AB`, `$0A`, `$0080`, `$0008`, `$0A00`, `$3000` | none | `moveVelX`, `movePosX`, ..., `probePixelX/Y`, `moveTickFlags*` | E1/E2 | `$0020/22/24/26` abs 284/84 | n/c / 0 | LEAVE | DP operands are not substituted (A14-F01); the absolute uses would rename 84 files. Constants (`hitStunBit` etc.) go in comments. |
| M61 | R-I048-4 | `$0100`, `$0102`; `$0000,Y`, `$0008,Y` | none | `scanResumeOffset`, `scanSavedWord`, `childEntryWord`, `childWaitCounter` | E1 | `$0100/02` 114/38; `$0000/$0008,Y` 18/10 | n/c / 0 | LEAVE | Same hazard as M60. |
| M62 | R-I051-5 | DP `$24`, `$26` | none | `fieldRevealEnemiesLeft` etc. | E1 | DP | n/c / 0 | LEAVE | DP, not expressible. |
| M63 | R-I001-8 | DP `$80-$82` | none | `collisionLayerBase` | E1 | 1 absolute `$0080` site | n/c / 0 | LEAVE | One absolute site would rename; the DP operands (hundreds) would not. Document in the DP table instead. |
| M64 | R-I001-70, R-I021-3 | `$7F0008`; `scratch1010+2/+4` | none / existing | neutral names | E1/E2 | 66/30 (REPORTED) | n/c / 0 | LEAVE | Per-actor roles differ (spriteset bank, sine amplitude, scratch). Ledger itself says do not name. |
| M65 | R-I058-1(c) | `$0036` | `frameCounter` (key 54) | `frameCounter` for the raw `$0036` | E1 | 12/6 raw DP-form lines | n/c / 0 | LEAVE | Key 54 exists; the raw `$0036` lines are DP-form operands (`WorldMapSplitEffect.asm:93`) that the extractor cannot substitute (A14-F01). |

**COP renames (`copdef.json`; name only, id fixed)**

| # | Ledger | Addr | Current | Proposed | Ev | Ops | Blast | Decision | Reason |
|---|---|---|---|---|---|---|---|---|---|
| C01 | R-I001-33 | id `#62` | `BranchIfCollisionTypeNe` (legacy alias `BranchIfSolidNibbleNe`) | `BranchIfCollisionTypeEq` | E1 | 6/3 (`rg -w`) | n/c / 0 | RENAME | `cop_handlers_actor_flags.asm:75` branches on EQUAL (VERIFIED). Notes `:5,75` carry "audit rename proposal" text (F11). |
| C02 | R-I001-44 | id `#02` | `QueueDma` | `QueueHdmaDirect` | E1 | 45/12 | n/c / 0 | RENAME | Binds a direct HDMA table to a B-bus register (`WorldMapSplitEffect.asm:78,79`). Also `docs/cop/families/hdma_dma.md` text. |
| C03 | R-I022-2 | id `#55` | `ResetSpriteState` | `StartTileStreamAnim` | E1 | 17/8 | n/c / 0 | RENAME | Resets no composition state. |
| C04 | R-I022-2 | id `#88` | `SetMetasprite` | `SetSpritesetTable` | E1 | 203/125 | n/c / **3 hits**: `baserom/red-jewels/ChestFlaggedHiddenRedJewel.patch.asm:31`, `baserom/red-jewels/generic_sparkle.asm:13`, `IOGRetranslation/modules/walkable-world-map/walkable_world_map_core.asm:253` | RENAME | Byte-neutral but 125 files change text. Do last; deferrable; the three patch sources must change in the same step. |
| C05 | R-I023-4 | id `#93` | `RunPlayerAnim` | alias of `AnimOnce` (#89) | E1 | 12/3 | n/c / 0 | ALIAS-IN-NOTE | Identical code; keep the id (vanilla script bytes). Note in `copdef` docs only. |
| C06 | R-I023-6 | ids `#4D`, `#4E` | `WorldMapStream3`, `WorldMapStream4` | `PaintTileStream3`, `PaintTileStream4` | E1 | 7/2 | n/c / 0 | RENAME | No script sites; handler + dispatch + docs only. |
| C07 | R-I001-68 | - | `ReloadMoveDurations` | `ReloadMoveChains` | E2 | 30/19 | n/c / 0 | RENAME | `$2C/$2E` are chain pointers, not durations. |
| C08 | R-I001-68 | - | `ForceDirSW`, `ForceDirNE`, `ForceDirBoth` | `ForceFlipX`, `ForceFlipY`, `ForceFlipXY` | E2 | 22/7 | n/c / 0 | RENAME | `ApplyMovement` tests `$12` bits `$4000` / `$2000` to negate the delta. Check the X/Y assignment of SW/NE in the handler before applying. |
| C09 | R-I001-78 | ids 34 and 82 (decimal) | `MoveToward`, `StageMove` | operand names (`anim, speed, durationCap`) | E1/E2 | - | - | LEAVE | A14-F03: copdef parts hold types only. Document in `docs/cop/families/movement.md`. |
| C10 | R-I001-34, -57, -92 | `$1A-$1E`, `$80-$87`, `$8F-$92`, `$B6`, `$B7` | copdef: `BranchIfSolidType*`, `StageSprite*`, `SetSprite*` | handler labels in `names/bankNN.json` | E3 | - | - | LEAVE | The copdef names are right (A01 V23, REPORTED); the label renames belong to the names backlog, not to copdef. |

**Struct renames and field-name proposals (`structs.json`)**

| # | Ledger | Addr | Current | Proposed | Ev | Ops | Blast | Decision | Reason |
|---|---|---|---|---|---|---|---|---|---|
| S01 | R-I061-1 | 109534-109551; `blocks.json:1007` | `direction-velocity` (two `Byte`) | `walk-step` | E1 | 250 lines / 3 files together with S02 and S03 | n/c / 0 | RENAME | Block name `walk_step_table` is already applied (VERIFIED `blocks.json:1007`); the struct name still says direction / velocity. Field names in the ledger (`animIndex`, `moveDeltaIndex`) are not expressible (F03). |
| S02 | R-I068-3 | 98868-108894; `blocks.json:1004` `&warp-def` | `stair-warp`, `warp-def.stairWarps` | `forced-walk-warp`, `forcedWalkWarps` | E1 | see S01 (543 + 200 rows change text in `scene_warps.asm`) | n/c / 0 | RENAME | Also retype the field list so the 6-byte walk stream is not split as word, word, word, byte, word (`types` only). Byte-neutral; gate required (REPORTED). Field names: S04. |
| S03 | R-I059-4(b) | 242132-242689 | `map-label` | `scene-label` | E1 | see S01 | n/c / 0 | RENAME | Lookup key is a scene id. |
| S04 | R-I068-3 | - | `scene-warp` | field names | E1 | - | - | LEAVE | F03. |
| S05 | R-I060-6(b) | 241015-242132 | `route-step` | `xDeltaIndex, yDeltaIndex, rotationDeltaIndex, ticks` | E1 | - | - | LEAVE | F03 (types already four bytes per ledger; not re-checked). |
| S06 | R-I066-2 | 109552-109992 | `enemy-stats` | `hp, atk, def, gemDropType` | E1 | - | - | LEAVE | F03. Row labels for the 18 directly addressed rows need `blocks.json` parts: separate, names owner. |
| S07 | R-I068-2 | 98398-98868 | `display-preset` | `tm, ts, cgwsel, ...` | E1 | - | - | LEAVE | F03. |
| S08 | R-I064-4, R-I069-4 | all `spriteset_*` | `sprite-set`, `sprite-group`, `sprite-part` | field names | E1 | - | - | LEAVE | F03. |
| S09 | R-I065-8 | - | `display-mode`, `bitmap`, `palette`, `tileset`, `tilemap`, `spritemap`, `music`, `branch`, `jump`, `char-tiles` | field names | E1 | - | - | LEAVE | F03. |
| S10 | R-I062-1 | 121255-121278 | `Binary` records | `ability-damage` struct | E1 | - | - | LEAVE | Dark Friar has 3 levels, the others 2, so one fixed struct does not fit (REPORTED); needs a per-record layout check first. |
| S11 | R-I041-4 | 239936 | `thinker-def` `< Byte, Byte >` | word `$0804` documented | E1 | 63/58 | n/c / 0 | ALIAS-IN-NOTE | Retyping to `Word` would change 58 files for a documentation gain. State "word `$0804` = `animScratch2` filter" in the thinker notes; docs field names are a docs fix. |

**Blocks / types / overrides**

| # | Ledger | Addr | Current | Proposed | Ev | Ops | Blast | Decision | Reason |
|---|---|---|---|---|---|---|---|---|---|
| B01 | R-I064-1 | `blocks.json:1005` | `forced_walk_pan_table` `&Binary` | `Word` array ending `$0000` | E1 | 4 operands in `forced_walk.asm` | n/c / 0 | RETYPE | Prints `< delay, step >` pairs instead of raw bytes. Verify the extractor prints `Word` runs with the `$0000` terminator (not checked). |
| B02 | R-I065-2 | 119072-119099 | 14 `binary_01D1xx` parts | `Word` | E1 | - | n/c / 0 | RETYPE | Bare `$FFFF` words. |
| B03 | R-I050-4 | 53352 (`types.json` key) | `Binary` | `Word` (16 signed words) | E1 | - | n/c / 0 | RETYPE | VERIFIED current value `Binary`. |
| B04 | R-I062-1 | `blocks.json:1016-1017` | `will_ability_damage_table`, `freedan_ability_damage_table`, `&Binary` | typed records | E1 | - | n/c / 0 | LEAVE | Block names already applied; retype blocked on S10. |
| B05 | R-I060-3 | 244008 (`types.json`) | `DialogString` | `DialogString` | E1 | - | - | LEAVE | Already applied (REPORTED, A07). |
| B06 | R-I057-4 | 782923 (`overrides.json`) | no entry (VERIFIED) | `{ "M": 1 }` | E1 | 1 site | n/c / 0 | ADD | Bytes unchanged; emitted text changes. Gate required. |
| B07 | R-I067-4, R-I071-3, R-I072-6, R-I069-3 | `$0F:CF65`, `$0F:D5E8`, `$10:8B82`, `$10:8B96`, `$10:8BBE`, `$10:8BD2`, `$10:8BE6`, `$0F:8BF5`, `$0E:EEB8` | hidden groups printed as extra sub-sprites | 9 `blocks.json` parts, or an extractor fix that honours the group count byte | E1/E2 | - | n/c / 0 | SPLIT | The extractor fix (`gaia-core`, one change) solves all four sets at once; parts need repeating per set. User decision; either way a rebuild gate run is required. |
| B08 | R-I060-4(b) | `palette_bundle_16D210`, `16D211`, `16D317`, `16D318` | bundle-looking parts | `Byte` / `Filler` | E1 | - | n/c / 0 | LEAVE | A `Filler` type was not found in `types.json`; names owner. |
| B09 | R-I024-6 | `transforms.json` `MenuSelectionHandler` | unanchored patterns | anchored patterns | E1 | - | - | LEAVE | The ledger names `src/annotate.ts`, which no longer exists (retired). Forward to the merge / transform owner (T-step). |

### 3.2 Step 3: collision and old-name checks (VERIFIED, `rg` this step)

New-name collision check (all proposed names in M01-M17, M36-M53, C01-C08, S01-S03; `rg -w` over `db-us/`, `baserom/`, `extracted/`, `IOGRetranslation/modules/`, `scripts/`, excluding `*.md`): **no identifier hits**. The only hits are prose mentions of the words "walk-step" in `walk_step_table.asm:5`, `forced_walk.asm:5,187,192,193`, `warps_interaction.asm:21,924,938`; they are comments, not names. `db-us/mnemonics_new.json` uses snake_case names only (no collision). `S_` / `L_` forms of the renamed mnemonics: no hits (A14-F15).

Old-name hits in `db-us/transforms.json`, `db-us/overrides.json`, `blocks.json`, `structs.json`, `copdef.json`, `types.json`: **none** for the renamed mnemonics (transforms key block names and regexes do not contain them).

Old-name hits in patch sources (A14-F02):

| Old name | Row | File:line |
|---|---|---|
| `mapScrollV` | M13 | `IOGRetranslation/modules/widescreen/Widescreen.patch.asm:169,235,391,447,814` |
| `effectDeltaX`, `effectDeltaY` | M16 | `Widescreen.patch.asm:166,170` |
| `currentHp` | M28 (kept) | `IOGRetranslation/modules/apocalypse-gaia/ApocalypseGaia.patch.asm:159,203` |
| `cameraDeltaX/Y` | M18 (kept) | `ApocalypseGaia.patch.asm:167,168` |
| `moveXAlt/YAlt` | M20 (kept) | `ApocalypseGaia.patch.asm:210,211` |
| `tileQueryResult` | M11 | `baserom/auto-use-items/HieroglyphPuzzle.patch.asm:6` (local `!tileQueryResult 0902`, safe) |
| `SetMetasprite` | C04 | `baserom/red-jewels/ChestFlaggedHiddenRedJewel.patch.asm:31`, `baserom/red-jewels/generic_sparkle.asm:13`, `IOGRetranslation/modules/walkable-world-map/walkable_world_map_core.asm:253` |

No other renamed name appears in `baserom/` or any IOGRetranslation module or script. Not checked: the `gaia-knowledge/corpus` copies of the docs (they are regenerated by `npm run ingest:all`), `RobotrekRetranslated`, `gaia-blazer-baserom`, `gaia-robotrek-baserom` (they have their own `db`).

`extracted-jp/` is generated with the same mnemonics (`src/index.ts:60,95`, VERIFIED), so a rename also changes its text on the next `extract`.

### 3.3 Step 4: disambiguating note wording for the 12 multi-meaning mnemonics

The names stay. The wording goes into the block note of each file that uses the field differently, in present tense, without ledger or OQ ids. Use the pattern: *"In this file `<name>` (`$addr`, X) is the `<role>`; the global name belongs to `<default users>`."* The mnemonic's default meaning is stated once in the WRAM doc, not in each note.

| # | Mnemonic | Default meaning (global name) | Contextual wording per file (VERIFIED lines unless marked) |
|---|---|---|---|
| 1 | `orbitAngle` (`$7F0010`) | Orbit actors: angle | `hit_stagger_controller.asm:73,207`: "orbitAngle holds the slide's start X." `ramps.asm:542,553`: "orbitAngle is the curve byte offset of the arc child." `smooth_follow.asm:461`: "orbitAngle is the slope row (offset = row × 32 bytes)." `StandardEnemyDefeatHandler.asm:62` and `EnemyDefeatDispatch.asm:50`: "orbitAngle is the number of enemies remaining after this kill (0 = the last one)." `music_actors.asm:51,109`: "orbitAngle holds the saved scene music index." `field_reveal_object.asm:70,81,92`: "orbitAngle is set to $FFFF at spawn and not read again (no reader found)." Others (npc_wander_ai: home X; escort: ring head; gem pickup: step counter) are REPORTED (R-I050-2, R-I052-6): re-read before writing. |
| 2 | `orbitDiameter` (`$7F0012`) | Orbit actors: diameter | `hit_stagger_controller.asm:76,172`: "start Y of the slide." `ramps.asm:435,454,571`: "the player's exit speed given by the climb." `smooth_follow.asm:339,468,482`: "dither phase 0-15 left by ComputeFollowStep." npc_wander_ai: home Y (REPORTED). |
| 3 | `chatPtr` (`$7F000A`) | Chat / music pointer slot | `field_reveal_object.asm:147`: "chatPtr is the item id of the pickup." `smooth_follow.asm:38`: "chatPtr is the animation base id; bit 15 set = leave the animation alone." `music_actors.asm:65,111`: "chatPtr is the scene track number plus one." StageMove / halving code: pass counter (REPORTED, R-I001-80). Escort / reveal half-width (REPORTED). |
| 4 | `loopCounter` (`$7F0014`) | COP `LoopStart` counter | `smooth_follow.asm:36`: "loopCounter is the follow speed in pixels per frame." `ramps.asm:544`: "loopCounter is the frame count of the arc child." |
| 5 | `currentHp` (`$7F0026`) | Hit points of enemies and actors | NPC actors via `npc_wander_ai`: "currentHp is the base animation index stored by the NPC's init, not hit points." `hit_stagger_controller.asm:248`: HP, zero = the victim dies. |
| 6 | `layerPriorityFlag` (`$06EE`) | BG layer priority word | "Bit field: bit 9 (`$0200`) camera frozen and field interaction off (`player_transition_handlers.asm:135`, `warps_interaction.asm:230`); bit 11 (`$0800`) interleaved-tile mode (`scene_script.asm:391,434`); bits 0-3 BG1/BG2 screen base (`scene_script.asm:1244`); bit 15 BG1/BG2 write swap (`system_core.asm:636`)." |
| 7 | `globalScriptIndex` (`$0AAC`) | Cross-script selector | `sE6_gaia.asm:78`: "Dark Space layout variant 0-2." `:87`: "cleared on entry; layout 3 sets it to 1, and `GaiaHint_AuraItem` tests it later." `:144`: "selection state of the item list." Lines `:514,991,1194` not re-read. |
| 8 | `free101C` (`$7F101C`) | Spare actor word | `hit_stagger_controller.asm:79,81`: "knockback tier: 0 for ordinary actors, 1 for the player and the cyclops." `sFA_diary_menu.asm:284,586`: "camera-pan step budget per frame (12 from the slot loop)." |
| 9 | `cameraDeltaX/Y` (`$06C0`, `$06C4`) | Layer-1 scroll offset | `camera_scroll.asm:66`: "cameraDeltaX is cleared after its value is moved into the override word." `camera_tilemap.asm:182`: "copied to effectScrollH/V in layer-1 delta mode." State both readings only after E5; today the note says "pending scroll offset". |
| 10 | `effectRenderDeltaX/Y` (`$06E8`, `$06EA`) | Render scroll adjustment | "Written only by the effect pipeline actors; not the same value as `effectDeltaX/Y` (target minus current scroll)." REPORTED (R-I051-2). |
| 11 | `moveXAlt` / `moveYAlt` (`$7F0018`, `$7F001A`) | Movement index into `movement_delta_table` | `InitGravity`, `SpawnFieldRevealEffect`: "moveXAlt / moveYAlt hold the target pixel position here, not a movement index." REPORTED (R-I001-68): re-read before writing. |
| 12 | `hpToHeal` (`$0B22`) | HP still to be restored | Not a per-file alias. WRAM doc wording: "While non-zero, one point per tick moves from hpToHeal to playerHp; cleared when playerHp equals playerMaxHp (`system_core.asm:410-423`)." |

A thirteenth case outside the list of twelve: `sineTableA/B` (A14-F06). Wording for the three scroll-wave files: "sineTableA/B are the scaled sine tables of this effect"; for `WorldMapSplitEffect.asm`: "On odd frames the same arrays hold the BGMODE and COLDATA tables" (already in its note, `:1,5`).

### 3.4 Ledger rows seen and sent elsewhere

Not mnemonic, struct, copdef or types proposals. These stay with their owners (names backlog A13 / F-name steps, docs F05, comments merge). Listed so no row of `I001-I020_rename-proposals.md` is silently dropped:

- Names / block renames (`names/bankNN.json`, `blocks.json` block keys): rows 1-6, 11-14, 18-21, 24, 26, 32 (`cop_handlers_actor_flags` to `cop_handlers_collision_probe`), 35-36, 38-39, 41-43, 47-48, 53, 55-57, 64, 66, 72-74, 82-85, 88-89, 91, 95-96.
- Docs only: rows 9, 10, 15-17, 25, 29-31, 40, 45, 50-51, 58-60, 69, 71, 77, 86-87, 93-94.
- Comments only: rows 30, 52, 59, 61.
- Rows covered above: 7 (M30), 8 (M63), 22 (M02), 23 (M12), 27-28 (M06, M07), 33 (C01), 34, 57, 92 (C10), 37 (M08), 44 (C02), 46 (M31), 49 (M04), 54 (M01), 63 (M58), 65 (M24-M27), 67 (M03), 68 (M20, C07, C08), 70 (M64), 75 (M05), 76 (M34), 78 (C09), 79 (M33), 80 (M26), 83 (M11), 84 (names owner), 90 (M09, M10).
- From I021-I072, not tabled because they are label / block names: R-I035-1..3, 5..7, R-I036-1..3, R-I042-1..3, R-I043-1..2, R-I051-4, R-I058-1(a, c, d), R-I060-4(a), R-I061-3, R-I062-2..4, R-I063-1..2, R-I064-2, R-I066-1, R-I069-1..2, R-I071-1..2, R-I072-1..4.

## 4. Not verified / needs Mesen2

- All semantics (E1/E2) are static. In particular M18 (camera delta vs position), M19, M20 (`moveXAlt` second use), M21 (`$0AAC` lines `:514,991,1194`), M03 (`$06F2` track id vs index) and M08 (mummy queen value) need E5 or a longer trace before a rename.
- Raw operand counts for M38, M39, M51, M53 were taken from ledgers; not re-counted.
- Whether the extractor substitutes immediate operands (`#$0B1C`, A14-F14), and whether `Word` runs with a `$0000` terminator print as pairs (B01), were not tested (no dry run was allowed in this step).
- `docs/` and `notes/` hit counts (blast) come from `rg -c` on `notes/` and `docs/` only; the `gaia-knowledge/corpus` copies were not counted.
- `RobotrekRetranslated`, `gaia-blazer-baserom`, `gaia-robotrek-baserom` were not searched (separate databases).
- The rebuild gate was not run: no note, name or database file changed in this step.

## 5. Items for the fix specs (F-step ids)

- **F06 (mnemonic / struct / copdef apply)**, in this order, one batch per gate run (`npm run extract:lt`, diff review, `npm run rebuild`):
  1. Batch 1, no patch hits, small blast: M01, M02, M04, M05, M06, M07, M08, M09+M10, M11, M14, M15, M17 (M03 after the user picks the name).
  2. Batch 2: M12 (81 files).
  3. Batch 3, cross-repo lockstep: M13 and M16 with the `Widescreen.patch.asm` edits (7 lines).
  4. Batch 4 (copdef): C01, C02, C03, C06, C07, C08; C04 separately with the three patch sources; C05 note only.
  5. Batch 5 (appends, per-file check each): M37, M38, M39, M40, M41, M42, M43, M44, M45, M46, M47, M48, M49, M50, M51, M52, M53; M36 after the site check.
  6. Batch 6 (structs): S01, S02, S03. Batch 7 (blocks/types/overrides): B01, B02, B03, B06, B07.
  Because no sanctioned script edits these JSON files (A14-F16), F06 can only deliver a reviewed edit list for the user; do not write an ad-hoc script.
- **F06 follow-up (comments)**: after each batch, one `npm run merge` spec per touched file to update old names in notes (class 3) and to remove OQ / R ids (class 7): `cop_handlers_actor_flags.asm:5,75`, `field_reveal_object.asm:70`, `player_character.asm:12`, `warps_interaction.asm:46`, `slider_glide.asm` ("named climbStateData"), `sprite_composition`, `music_actors`, `item_use_system` (musicParentActor wording).
- **F06 note wording**: the §3.3 sentences (items 1-12) go into the block notes of the files named there via `npm run merge`.
- **F05 (docs)**: `docs/wram-memory-map.md` entries for every row with a RENAME, and the single-meaning wording for `hpToHeal`.
- **A13 / names owner**: the §3.4 names list and C10 label spellings.
- **Cross-repo**: `IOGRetranslation` Widescreen edits (M13, M16) and three `SetMetasprite` sources (C04).
- **gaia-core (user decision)**: struct field-name slot (A14-F03); extractor group-count fix (B07).

## 6. Counts

- Table rows: 95 (mnemonic 65, COP 10, struct 11, blocks/types/overrides 9).
- Decisions: RENAME 27 (mnemonic 17, COP 7, struct 3); ADD 19 (mnemonic 18, override 1); RETYPE 3; SPLIT 1; ALIAS-IN-NOTE 17 (mnemonic 15, COP 1, struct 1); LEAVE 28 (mnemonic 15, COP 2, struct 7, blocks/types 4).
- Findings: 16 (VERIFIED 14, REPORTED 1 [F14], mixed 1 [F16]).
- Multi-meaning mnemonics with wording: 12, plus `sineTableA/B`.
- Collision check: 0 identifier hits for all proposed names; old-name patch hits: 7 names in 7 patch/module files (two modules need lockstep edits for 3 renamed names; one rename, `SetMetasprite`, needs three patch sources).
- Files edited by this step: `A14_findings.md` (new), `PLAN.md` (A14 row only). `db-us/mnemonics.json` untouched.

## 7. Process disclosure

Early in the step I ran two shell commands outside the permitted list (one `wc -l` and one `ls -la` to see the size of the mnemonics files) and one multi-name `for` loop that failed (unescaped `$` in double quotes, 0 matches). All three were read-only, produced no file and were not used for any finding; every count in this file comes from the later single `rg` runs with single-quoted patterns. No script file was created. No git history command was run.
