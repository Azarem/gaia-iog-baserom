# IOG `extracted/` ASM Audit — Results, iterations I001–I020

Legacy combined ledger (frozen; do not edit). From I021 on, every iteration gets its own new file in `results/`, `renames/` and `questions/` (see the process in [checklist.md](../checklist.md)).
Companion files: [checklist.md](../checklist.md), [renames/I001-I020_rename-proposals.md](../renames/I001-I020_rename-proposals.md), [questions/I001-I020_open-questions.md](../questions/I001-I020_open-questions.md).
The sanity pass over I001–I020 is documented in [I001-I020_sanity-check.md](I001-I020_sanity-check.md).
Below, "rename-proposals.md" and "open-questions.md" mean those two moved files; the OQ-1..OQ-69 and rename row 1..96 numbers are unchanged.

## Conventions

- Verdicts: **P** pass, **M** minor issue, **F** fail, **NA** not applicable.
- Dispositions: **FIXED** (edited via .asm + `ingest`, or append-only `mnemonics.json`), **PROPOSED** (logged in rename-proposals.md), **DEFERRED-EVIDENCE** (needs runtime proof; see open-questions.md), **NOFIX**.
- Evidence ladder: **E1** code trace, **E2** cross-reference (Grep, callers, `copdef.json`, `wram-init`), **E3** project docs, **E4** hardware references, **E5** runtime (Mesen2 MCP not available in this session; always UNVERIFIED-RUNTIME).
- Q1 comment density, Q2 value, Q3 accuracy, Q4 mnemonic/address accuracy, Q5 mnemonic opportunity, Q6 part naming, Q7 evidence quality.

## Phase 0 baseline (setup)

| Item | Result |
|------|--------|
| asm files under `extracted/` | 909 (every file carries `; {addr}` tags in line-tracked mode) |
| Extraction mode in use | `npm run extract:lt` (line-tracked). A plain `npm run extract` at campaign end strips tags (final-consolidation step) |
| Baseline `npm run rebuild` | OK. `artifacts/crc.json`: crc 2083230829, checksum 223006080, totalSize 3062204 |
| Working tree | Dirty before the audit (artifacts/*, deleted baserom/asm/*, added baserom/equipped-icon/*, untracked temp/ and scripts/). User chose to proceed; those files are not touched. `extracted/` diff vs HEAD is large only because lt tags are present |
| Mnemonic mechanics (E1: gaia-core `addressing.ts`) | Mnemonic names are applied to non-ROM **absolute/long** memory operands only. Direct-page operands (`$36`, `[$80], Y`) and `#$xxxx` immediates never receive names. Q5 therefore only applies to absolute operands |

Process notes: a read-only `node -e` check (orphan block notes) was used once in Phase 0 despite the "no scripts" rule; no scripts since.

---

## I001 — system/engine/scene_script.asm | cop_handlers_linked_actor.asm | cop_handlers_wait.asm

Gate results: ingest dry-run clean; ingest applied; `extract:lt` re-run after mnemonic additions; `npm run rebuild` OK and CRC unchanged (2083230829), i.e. byte-identical ROM.

### File 1: system/engine/scene_script.asm (2149 lines, Bank 02, 164795-168078)

Parts inventoried (30): SceneScriptMain, SceneScriptNoMusic, scene_script_jump_table, SceneCmd_ConfigDisplay/LoadBgTiles/LoadTilemap/LoadDualTilemap/FullGraphics/LoadSpriteTiles/LoadCharTiles/Skip3/ConditionalLoad/Nop, SpcMusicLoadCmd, SkipScriptCommands, DmaTileStripToVram (+ SceneDmaTileShim/CheckInterleavedFlag), Load4bppPage, DeinterleavePlanarTiles/code_0285F3, BuildAttributeTable, StoreMapAndDecompress/HandleEmptyGeometry, WriteMapBounds, DmaLowVramTileset, RenderPaletteTiles, ReadScriptByte, FindCurrentScene, LoadScriptPointer, CheckSourceCacheHit, DmaRomToWram, GraphicsCacheLookup/Store, SaveVramToRingBuffer, DmaVramToRam, ComputeRingBufferAddr, RestoreCachedVram, DmaWramToVram, RebuildTilemapAttrs, ReloadMapData, ReloadMapLayer0/1.

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 density | M | Block note and part notes thorough; ~1,450 uncommented instruction lines remain, mostly mechanical register shuffles. The ConfigDisplay and cache sections were under-explained relative to their complexity | FIXED (added scratch-triple and source-cache map to block note; per-field comments in ConfigDisplay; collision rebuild pipeline) |
| Q2 value | M | Several comments restated the instruction (e.g. "Load pointer register X=$003E"); the valuable ones explained semantics. Replaced restatements where semantics were wrong anyway | FIXED partially; remainder NOFIX (restatements are harmless) |
| Q3 accuracy | **F** (7 defects) | See defect table below | FIXED |
| Q4 names | M | `$0664-$068x` and `$06A2-$06AE`, `$06EC` were raw hex in 123 operand sites although `docs/wram-memory-map.md` named `$0664-$066A` as `gfxLoadParams` | FIXED (mnemonics added) |
| Q5 mnemonic | FIXED | See mnemonics added below | FIXED |
| Q6 part naming | M | `RebuildTilemapAttrs` and `ReloadMapLayer0/1` describe mechanism, not purpose (they build the metatile collision-flag table and the collision layer). `code_02845C`, `loc_028xxx` sub-labels unnamed | PROPOSED (rename-proposals.md) |
| Q7 evidence | P | Every defect below has E1 + E2 evidence | n/a |

Defects found (all fixed in comments/notes):

| # | Location | Old claim | Corrected claim | Evidence |
|---|----------|-----------|-----------------|----------|
| 1 | SceneCmd_ConfigDisplay, byte labels | "Apply byte 7 / 8 / 9..." with off-by-3 numbering against `display_preset_table+N` | Record offsets +0..+7 used, +8/+9 loaded and discarded | E1 operands `+0..+9`; E3 structs-reference.md |
| 2 | ConfigDisplay `$06A2/$06A4` | "BG tilemap size flag" | `$2000` tile-priority bit OR'd into every layer-0/1 tilemap entry by RebuildTilemapAttrs | E1 `ORA $06A2,X` in RebuildTilemapAttrs; E4 SNES BG entry format (bit 13 = priority) |
| 3 | ConfigDisplay `STZ $066E` | "clear camera following state" | Zeroes bank byte of source-cache slot `$066C` | E1 slot layout `$066C/D/E`; E2 CheckSourceCacheHit reads +0/+1 and +2 |
| 4 | ConfigDisplay `$09ED` | "bit 6 = sprite DMA suppress" | `$09ED` bit 6 is the HUD-disable bit (bit 7 is sprite-upload suppress in camera_tilemap) | E1 `TRB/TSB #$40`; E2 scene_lifecycle.asm:923; E3 wram-memory-map.md:295 |
| 5 | LoadBgTiles | `$0664/$0666` = "VRAM start/end"; modes "double/triple strip"; `STZ $0670` "overflow tracking" | `$0664/$0666` = byte window into decompressed data (DMA size = end - start); mode selects VRAM base `$2000/$4000/$6000`; `STZ $0670/$0673/$0676` invalidate source-cache slots | E1 DmaTileStripToVram (source = `$3E+$0664`, size = `$0666-$0664`, VMADDL = `$0668`<<8) |
| 6 | Block note | "bit 1 loads layer 0, bit 2 loads layer 1" | bit 0 / bit 1 | E1 `LDA #$01 / #$02 ; AND $066A` |
| 7 | RebuildTilemapAttrs / ReloadMapLayer0/1 | "attribute bytes (palette, priority, flip)", "runtime tilemap modification storage", "overlay animation layer" | They build a per-metatile flag table (bit 9 of the four tilemap words) in bank `$7F` and use it to fill the collision layer `$7F:C000` | E1 data flow; E2 `event_blocks.asm` ("collision ... `$06AC` ... bank $7F"), `system_init` `wram-init $06AA=$0000, $06AC=$0100, $06AE=$2000`, camera_tilemap "metatile definition table base `$06AE`"; address math `$7F2000+$A000 = $7FC000 = collisionLayer` |

Smaller fixes: ReloadMapLayer1 `LDX $0080` comment (now notes wram-init sets `$0080` = `$C000`), SaveVramToRingBuffer/GraphicsCache notes verified unchanged, FullGraphics `STZ $067F/$0680` comment, deinterleave slot invalidation list.

Mnemonics added (append-only, `db-us/mnemonics.json`, blast radius grepped across `extracted/`; 123 hits in scene_script plus 19 other files, all same semantics):

- `gfxSrcStart` `$0664`, `gfxSrcEnd` `$0666`, `gfxDestPage` `$0668`, `gfxLayerFlags` `$066A`
- Source-cache slots (3 bytes: addr lo/hi, bank): `srcCacheBgA..D` `$066C/$066F/$0672/$0675`, `srcCacheTilemapL0/L1` `$0678/$067B`, `srcCacheFullGfxL0/L1` `$067E/$0681`, `srcCacheSprites` `$0684`, `srcCacheMusic` `$0687`, plus the `+1`/`+2` addresses code uses to invalidate slots (`STZ slot+1`)
- `tilemapOrMaskL0/L1` `$06A2/$06A4` (+1 bytes), `tilemapOrMaskPrevL0/L1` `$06A6/$06A8`, `collisionFlagTableL0/L1` `$06AA/$06AC`, `metatileDefBase` `$06AE`, `visibleHeight` `$06EC`
- Not added: `collisionLayerBase` (DP `$80`, never named because DP operands are never substituted; the one absolute `$0080` use is also inside `wram-init` data), `$06F1`, `$066E`-style semantic names beyond slot layout, `$0D72`

### File 2: system/engine/cop_handlers_linked_actor.asm (21 lines)

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M -> P | Had no block note; sparse comments | FIXED |
| Q2 | M -> P | Old part note was misleading | FIXED |
| Q3 | F -> P | Old note said "far pointer" and "Credits parade and similar chain actors"; `$08/$2C/$2E` called "movement staging". Real: 2-byte `&Code` operand (E1/E3 copdef), `$08` = waitCounter (E3 wram-memory-map §2.11); all 164 call sites are ending_credits (E2 grep) | FIXED |
| Q4 | P | No mnemonic opportunity (actor DP offsets via `$0000,Y`) | NOFIX |
| Q5 | NA | Operands are DP-relative | NOFIX |
| Q6 | P | `SetLinkedEntryPtr` matches copdef id 106 | NOFIX |
| Q7 | P | E1 + E2 + E3 | n/a |

### File 3: system/engine/cop_handlers_wait.asm (33 lines)

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M -> P | Added block note and two part notes; inline comments for the shared tail | FIXED |
| Q2 | M -> P | Explained the yield mechanism (`PLA PLA` discards 4-byte COP frame; RTL returns to actor loop) | FIXED |
| Q3 | P | Timing verified: `DEC $08` per tick, `BPL` skip, so wait N resumes N+1 ticks later (E1 actor_execution.asm; E3 docs/cop/families/wait.md) | NOFIX |
| Q4 | P | n/a | NOFIX |
| Q5 | NA | DP operands only | NOFIX |
| Q6 | M | No name at 44233 (shared-tail label); `WaitByte`/`WaitWord` fine | PROPOSED |
| Q7 | P | E1 + E3 | n/a |

Cross-file findings from I001 are logged in rename-proposals.md and open-questions.md.

---

## I002 — system/engine/combat_collision.asm | DmaWordToVram.asm | system/music_pointer_array.asm

Gate results: ingest dry-run clean then applied; mnemonics added; `extract:lt` re-run; `npm run rebuild` OK, CRC unchanged (2083230829). Note: between I001 and I002 the user ran a plain `npm run extract` on branch `dev`; `extracted/` had to be re-extracted with `extract:lt` to regain address tags (no un-ingested edits were lost).

### File 1: system/engine/combat_collision.asm (1727 lines lt, Bank 03, 244613-247295)

Parts inventoried (13): ProcessDodgeCallbacks, CheckPlayerDeath, RunCombatCollision, CombatCollision_EnemyLoop (phase 1 and phase 2 inner loops), CombatCollision_Exit, PlayerAttackHitTest(+_End), EnemyHitPlayerHandler(+_Epilogue), InvinciblePlayerHit, CalcKnockbackDirection, RunInteractionCollision(+FriendlyMode), ApplyInteractionDamage, InteractionDamage_NPCChat, CalcKnockbackFromActorCenters, FormatDamageDigits.

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Good block note; inline comments sparse on box setup | FIXED (interaction box edges, damage terms) |
| Q2 | M | Several comments were misplaced by one line (RunInteractionCollision `$2040/$0280`) | FIXED |
| Q3 | **F** (7 defects) | Table below | FIXED (comments) / DEFERRED-EVIDENCE for role of `$0080`/`$0400` |
| Q4 | M | `$0AE0/$0AE2` (victim max HP / HP after hit), `$09E6` (enemy HP shown on HUD), `$09E2` (second word of climbStateData) were raw | FIXED (4 mnemonics; blast radius: `$0AE0/$0AE2` combat_collision only; `$09E6` ConsoleStringRenderer, system_core; `$09E2` attack_ability_system). `$0DB8` not named: item id, render bank and text pointer in different files |
| Q5 | FIXED | see Q4 | FIXED |
| Q6 | **F** | `EnemyHitPlayerHandler` reduces the overlapped actor's HP using the player's strength; contact damage to the player is `ApplyInteractionDamage`. `InvinciblePlayerHit` likewise | PROPOSED |
| Q7 | M | E1 + E2 + E3 for formulas and directions; roles of `$0080`/`$0400` need runtime | DEFERRED-EVIDENCE (OQ-8) |

Defects (comments/notes corrected):

| # | Location | Old claim | Corrected claim | Evidence |
|---|----------|-----------|-----------------|----------|
| 1 | block note + EnemyHitPlayerHandler | `rawDamage = max(1, enemyAtk(stats[2]) − totalStr)` | `max(1, totalStr − stats[2])`: stats[2] is DEF (HP/ATK/DEF/EXP), the code negates `stats[2] − totalStr` | E1 `EOR #$FFFF / INC / CMP #1`; E3 bank0A doc ("30 HP, 22 ATK, 12 DEF") |
| 2 | same | `netDamage = rawDamage + chainDamage($08)` | `$08` was overwritten by `characterForm` at 245669 (DP=0); the later `ADC $0008` is absolute, so the add-on is characterForm | E1 order of `STA $08` / `TXA TCD` / `ADC $0008` |
| 3 | EnemyHitPlayerHandler knockback | "0=N, 1=S, 2=E, 3=W" | player facing is 0=down, 1=up, 2=left, 3=right (GetPlayerFacingDirection) and the velocity is opposite the facing | E1 + E2 GetPlayerFacingDirection.asm |
| 4 | PlayerAttackHitTest 245372 | "terrain shake: any enemy hit dies outright" | shake or stagger-immune victims skip HitStaggerMain and resolve death inline; normal victims are resolved in HitStaggerResolveHit | E1 branch structure; E2 hit_stagger_controller.asm 179-210 |
| 5 | ProcessDodgeCallbacks | `$0080` = "B button" | `$0080` is the "A"-position bit of the remapped pad word (attack/action button); B is `$8000` | E3 docs/cop/families/input.md button table |
| 6 | RunInteractionCollision | `$2040`/`$0280` comments sat on the wrong instructions | realigned; `$0280` = `$0200` game-over / `$0080` iframe-active, friendly NPCs only | E1 |
| 7 | block note, `$0080` as "hittable" | `$0080` is called "hittable" at the phase test and "iframe state" at three `TSB $10` sites | neutral wording; role logged as OQ-8 | E1 + E3 inconsistent |

Observation (not changed): four of five `COP [SpawnListAppend]` sites in this file do not test the `$1FC0` pool-full result; only ApplyInteractionDamage does.

### File 2: system/engine/DmaWordToVram.asm (35 lines)

| Q | Verdict | Findings | Disposition |
|---|---------|----------|-------------|
| Q1 | M | Part note repeated the block note; no register-width contract | FIXED (contract + VMAIN requirement) |
| Q2 | P | n/a | NOFIX |
| Q3 | M | "DMAP0=$01: fixed address, increment after word write" is wrong: A-bus increments, B-bus writes `$2118` then `$2119` | FIXED |
| Q4 | P | hardware register names | NOFIX |
| Q5 | NA | n/a | NOFIX |
| Q6 | P | name matches function | NOFIX |
| Q7 | P | E1 + E2 callers (scene_lifecycle LoadPlayerGraphics, inventory_overlay) | n/a |

Cross-file: scene_lifecycle.asm:1117 says "scene_script.DmaWordToVram"; the routine lives in its own file `DmaWordToVram.asm` (fix in I003).

### File 3: system/music_pointer_array.asm (41 lines)

| Q | Verdict | Findings | Disposition |
|---|---------|----------|-------------|
| Q1 | M | Notes missing the indexing rule | FIXED |
| Q2 | M | "Covers all 30 BGM tracks" is wrong: 30 entries, 27 distinct tracks (`bgm_lively_city` x4) | FIXED |
| Q3 | **F** | Code reads `table−3 + 3n` so the table is 1-based: music ID n selects entry n−1. `docs/bank01-data-tables.md` lists entry indices as IDs (off by one). Confirmed by scene records `music < #1C ... @bgm_lively_city_by_the_sea >` (entry `$1B`) | FIXED (notes); doc fix PROPOSED |
| Q4 | NA | pointer list | NOFIX |
| Q5 | NA | n/a | NOFIX |
| Q6 | P | `music_pointer_array` | NOFIX |
| Q7 | P | E1 (hdma_dma_spc.asm 468-471) + E2 (scene records) + E3 | n/a |

Mnemonics added in I002: `climbStateData+2` (`$09E2`), `enemyHpCurrentDisplay` (`$09E6`), `hitVictimMaxHp` (`$0AE0`), `hitVictimHp` (`$0AE2`).

---

## I003 — scene_lifecycle, vram_buffer_clear, ShowDialogueFrame (done together with I004)

Gate results are shared with I004 (see below). Note: `extracted/` had been re-extracted without tags (user ran plain `extract`) before this pass; `npm run extract:lt` was re-run first (nothing un-ingested was lost).

### File 1: system/engine/scene_lifecycle.asm (1230 lines lt, Bank 03, 252392-254128)

Parts inventoried (14): CheckSceneTransition, ExecuteSceneTransition, ScreenExitTransition (+ _WaveAlt), ApplyScrollWaveEffect, ComputeSineScrollTable, ScreenEnterTransition, ClearSceneState, LoadHudTilemap, HudTilemapData (75 words), LoadScenePalettes, LoadPlayerGraphics, InitCameraBounds.

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Good block/part notes; ClearSceneState lists clears but not their meaning; several raw operands un-annotated (`$66`, `$06CC`, `$0AEC/$0AEE`, `$09CC/$09CE`, `$00B2`, `$0C07`, `$00EA`) | FIXED where meaning is proven (`$66`, TYX/ASL, `$0652` handling); the rest DEFERRED-EVIDENCE (no consumer proves a role) |
| Q2 | M | Several comments restated the opcode or described the wrong thing (see defects) | FIXED |
| Q3 | **F** (15 defects) | Table below | FIXED (comments/notes) |
| Q4 | M | `$0649/$064B/$0653/$06DF/$0A1F/$0DB6/$06E8/$06EA` raw; `gfxCacheIdxA/B` name does not match role | FIXED (11 mnemonics); rename PROPOSED |
| Q5 | FIXED | see Q4 | FIXED |
| Q6 | M | `gfxCacheIdxA/B`, `loc_*` labels inside long routines; `$0D6E/$0D6F` unnamed | PROPOSED |
| Q7 | M | E1 for all code claims; E2 grep for every callers/writers; E3 WorldMapController state block, wram-memory-map; E4 SNES HDMA line-count semantics, BGnHOFS; no E5 | DEFERRED-EVIDENCE for the `$FF` flag consumer list |

Defects (comments/notes corrected):

| # | Location | Old claim | Corrected claim | Evidence |
|---|----------|-----------|-----------------|----------|
| 1 | block note, ExecuteSceneTransition | "Disables NMI, enables display" / `EnableNmiOnly` "Enable NMI-only, then enable display" | `EnableNmiOnly` writes NMITIMEN=$01 (NMI off, joypad auto-read only); `EnterForcedBlank` writes INIDISP=$80 | E1 vblank_joypad.asm 282-327 |
| 2 | ExecuteSceneTransition | `ScreenBlackout` "Force blank before enter transition" | INIDISP=$00: forced blank released, brightness 0 | E1 vblank_joypad.asm 297-311 |
| 3 | block note, ExecuteSceneTransition | negative worldReadyFlag "used for initial boot or forced transitions"; flag cleared | negative skips exit AND enter transition and the flag is left unchanged; no writer stores a negative value (only `$0000`/`$000F`), so the path looks unused | E1 + E2 grep of all writers |
| 4 | block note, ExecuteSceneTransition, CheckSceneTransition | "special transition" `$0D52`; "Records the source scene in `$0D6E`" on the special path | `$0D52` is the world-map destination X staged by the world-map COP handlers; the special path moves it to `$0D54`, saves **sceneNext** (deferred destination) in `$0D6E` and sceneCurrent in `$0D6F` (read as area ID by WorldMapController), target scene `$FE`; the normal path stores the scene being left in `$0D6E` | E2 cop_handlers_world_map.asm, WorldMapController.asm state block, DisplaySceneTitle.asm:56 |
| 5 | block note, exit/enter transitions | transition type read from `gfxCacheIdxA ($0648)` "and $0649"; speed `$064B`; "graphics cache indices" | exit uses the low bytes (`$0648`, `$064A`), enter the high bytes (`$0649`, `$064B`); cutscene scripts write these words before QueueMapChange and the lifecycle clears them: they are transition parameters, not graphics-cache indices | E1 + E2 (pyDD_mummy_queen, pr8D_prologue2, wram-init) |
| 6 | block note, exit type 3/4, enter type 3, ComputeSineScrollTable | `$006E` = wave "phase" | `$006E` is the amplitude (multiplied with the sine sample via WRMPYA); the sine index is Y advanced by `$0070`; time motion comes from NMI counter `$36` in ApplyScrollWaveEffect | E1 |
| 7 | ComputeSineScrollTable | "128 entries per table"; "If `$00` (amplitude parameter) is zero" | 256 entries (`CPX #$0200`, step 2); `$00` is only a nonzero guard (callers store delay/brightness/count there) | E1 |
| 8 | ApplyScrollWaveEffect | HDMA table `$FF` = "256 scanlines", `$E0` = "scanline count"; "$0D/$0F in register $7E"; sineTableB "second table" | line-count bytes are repeat-mode (bit 7) with 127 and 96 lines; B-bus registers `$0D`/`$0F` = BG1HOFS/BG2HOFS, indirect bank `$7E`; table B is a second copy that lets the window run past the end of A (223 lines) | E4 SNES HDMA; E1 handler (cop_handlers_hdma_dma.asm 86-122) |
| 9 | LoadScenePalettes | `$F0/$FD/$FF` skip "standard palettes"; "DMA 31 entries" | `$F0/$FD/$FF` still load the HUD palette `@198040` (only `$F7` skips it); the extra palette is a 32-byte MVN (A=$1F is count−1) to `$7F:0B40` = CGRAM mirror color $A0 via the `$0402` WRAM routine (PHB/MVN/PLB/RTS from wram-init `$548B`/`$60AB`) | E1 + E2 system_init.asm wram-init |
| 10 | LoadPlayerGraphics | "$1C00 = 112 tiles", "$0800 = 32 tiles", "$0600 = 24 tiles" | 4bpp tiles are 32 bytes: 224, 64, 48 tiles; FX tiles at VRAM `$4400` overwrite tiles 32-95 of the main spriteset just uploaded | E1 + E4 |
| 11 | LoadPlayerGraphics | "use scene_script.DmaWordToVram" | routine is in `DmaWordToVram.asm`; interface X/A/Y with VMADDL preset | E1 (fix owed from I002) |
| 12 | ClearSceneState | "COP SetFlagByte $FF — mark all actors for compose"; "Clear bit 7 of scene status `$0A1F`" | `$0A1F` is the flag byte of event flags `$F8-$FF`; bit 7 is event flag **`$FF`**, cleared at the top and set again by this COP; thinkers loop on `BranchOnFlagByte #FF` (inferred: scene-setup-complete signal) | E1 + E2 flag_helpers, scene_flags.md, sE8_comet_display_config |
| 13 | ClearSceneState | `BG12NBA=$22 — char bases $0000/$2000`; "event flags" cleared; "companion words" `$06E8/$06EA`; "layer 2" | both BG1/BG2 bases = word `$2000`; only the first event-flag word `$0A00` (flags `$00-$0F`) is cleared; `$06E8/$06EA` are the visual-effect render deltas; BG2 = layer 1 (X=2) | E1 + E2 visual_effect_pipeline.asm |
| 14 | block note LoadHudTilemap | HUD "set during cutscenes and special scenes"; HudTilemapData "for the HP bar, gem counter, defense/strength" | bit 6 of hudDisableFlag is set/cleared per scene by display_preset record byte +7 bit 7; the glyph mapping is not decoded and was removed; the stream expands to 159 words (16 skips = 118 positions + 41 tiles) = first `$0140` bytes of the staging buffer | E1 count; E2 scene_script.asm 1269-1274 |
| 15 | InitCameraBounds / press-start | `$06DF` anonymous; `$06EC`; "press-start" `$00B4` | `$06DF` = cameraLowerYBound high byte; `$06EC` = visibleHeight; `$00B4` is the scene-title wait flag set to `$E0` by DisplaySceneTitle | E1 + E2 |

Mnemonics added: `gfxCacheIdxA+1`, `gfxCacheIdxB+1`, `warpScrollParams+1`, `cameraLowerYBound+1`, `effectRenderDeltaX/Y` (`$06E8/$06EA`), `eventFlagsF8toFF` (`$0A1F`), `transitionBrightness` (`$0DB6`), `bg3TilemapBuffer` (+1, +2) and `bg3TilemapRow1` (`$7F0200..$7F0240`, also used by dialogue/console/menu/radar/credits/diary renderers). Blast radius verified by grep on the post-extract output (names only, bytes unchanged): `eventFlagsF8toFF` 6 operands (scene_lifecycle 3, inventory_overlay 3); `transitionBrightness` 9 (scene_lifecycle 7, sFC_title_start_handler 2); `effectRenderDeltaX/Y` 10 (visual_effect_pipeline 6, scene_lifecycle 4); `bg3TilemapBuffer`/`bg3TilemapRow1` 89 lines across 9 files (ConsoleStringRenderer 32, DialogStringRenderer 23, MenuSelectionHandler 10, sF7_credits 9, radar_map_screen 4, sFA_diary_menu 4, inventory_menu 3, scene_lifecycle 2, vram_buffer_clear 2). Note: `camera_tilemap.asm:873/896` still calls `$7F0200` a "sprite tileset staging area" (fix in its iteration, see OQ-6/OQ-12).

### File 2: system/functions/vram_buffer_clear.asm (43 lines, Bank 02)

| Q | Verdict | Findings | Disposition |
|---|---------|----------|-------------|
| Q1 | M | Notes did not say what the buffer is; no register contract | FIXED |
| Q2 | M | "accumulates VRAM write commands ... flushed during VBlank" wrongly describes a command queue | FIXED |
| Q3 | **F** | `$7F0200` is a 32x32-word **BG3 tilemap staging buffer** (BG3SC=`$78` → VRAM `$7800`; DMA'd as 2048 bytes when displayModeFlags bit 0 is set; credits `COP AdhocVramDma $7F0200 → $7800`; inventory_menu writes BG3 cursor tiles to it). The partial clear keeps `$0140` bytes because HudTilemapData expands to 159 words | FIXED (notes) |
| Q4 | M | `$7F0200`/`$7F0240` raw in 140+ sites | FIXED (mnemonics above) |
| Q5 | FIXED | see Q4 | FIXED |
| Q6 | M | `loc_02F07E` loop label unnamed; part names fine | PROPOSED |
| Q7 | P | E1 + E2 + E4 | n/a |

### File 3: system/functions/ShowDialogueFrame.asm (47 lines, Bank 02)

| Q | Verdict | Findings | Disposition |
|---|---------|----------|-------------|
| Q1 | M | Input register (Y = string pointer) undocumented | FIXED |
| Q2 | M | Callers list ("NPC scripts, cutscenes") unsupported | FIXED: chest handling (warps_interaction) and item-giving NPC (combat_collision) |
| Q3 | M | "complete game frame" for UpdateFrameRender (it is render-only, saves Y); `PHP` comment claimed it saved the data bank | FIXED |
| Q4 | P | `joypadMaskStd` ok | NOFIX |
| Q5 | NA | n/a | NOFIX |
| Q6 | P | name matches | NOFIX |
| Q7 | P | E1 (UpdateFrameRender PHY/PLY) + E2 callers | n/a |

---

## I004 — math_lookup_tables, cop_handlers_dungeon_switch, cop_handlers_offscreen

### File 1: system/math_lookup_tables.asm (1216 lines, Bank 01, 115588-117397) — SAMPLED ~25%

Structure fully inventoried (7 parts, sizes match `blocks.json` ranges exactly: 209, 64, 256 bytes; 128 words x2; 256 words; 128 words). Data sampled: scene_flag_table all 209 bytes (small); sine_table_8bit all 64; signed_sine_table at indices $00-$05, $3B-$4A, $7C-$95, $F9-$FF; the 16-bit tables at their first/last 10-16 entries and at k=$3C-$40, $7C-$83, $BC-$C1 of signed_sine_table_16bit.

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Block note too thin: nothing about adjacency | FIXED (adjacency contract) |
| Q2 | M | Part notes for the 16-bit tables repeated their names | FIXED |
| Q3 | **F** (5 defects) | Table below | FIXED (notes) |
| Q4 | M | `scene_flag_table` name wrong; `signed_sine_table` is a cosine; `sine_table_16bit_quarter` is not a duplicate | PROPOSED (renames), notes FIXED |
| Q5 | NA | table data (no operand mnemonics possible) | NOFIX |
| Q6 | **F** | see Q4 | PROPOSED (rows 18-21) |
| Q7 | M | E1 value checks (sin/cos at 1.40625° and 0.703125° steps) + E2 consumers (system_core init, slope_ramp_physics, mode7_perspective, ComputeSineScrollTable, ApplyOrbitalOffset*) | consumer of `$40-$D0` bytes of scene_flag_table: DEFERRED-EVIDENCE (OQ-11) |

Defects (notes corrected):

| # | Location | Old claim | Corrected claim | Evidence |
|---|----------|-----------|-----------------|----------|
| 1 | scene_flag_table part note | "scene flag table ... may be a scene-to-region mapping ... not referenced by actor code" | system_core sets slopeCurvePtrA/B to its start and decelCurvePtr to +`$20`; slope_ramp_physics reads 16-bit curve values `(counter & $0F) × 2`: bytes `$00-$1F` accel curve (`$0001` at steps 0,4,8,12), `$20-$3F` decel curve (`$0001` at steps 7,15) | E1 system_core.asm 198-205, slope_ramp_physics.asm 293, 550 |
| 2 | sine_table_8bit | "64 entries" only | indexed 0-255 by consumers; entries 64-255 come from the adjacent signed_sine_table | E1 ComputeSineScrollTable (Y += `$0070` over 256 entries), ApplyOrbitalOffsetXY; blocks.json ranges contiguous (115797+64 = 115861) |
| 3 | signed_sine_table | "full 360° signed sine, peak → 0 → trough" | it is a 256-step signed cosine (`$7F` at k=0, `$00` at `$40`, `$81` at `$80`) and doubles as the continuation of sine_table_8bit | E1 value pattern; used as the second orbit axis |
| 4 | signed_sine_table_16bit | "full-cycle ... positive peak `$7FFF` to trough `$8001`" | negated half-wave only: `$0000`, trough `$8001` at k=`$80`, ends `$FE6E` (never positive) | E1 samples k=$00-$0B, $3C-$43, $7C-$83, $BC-$C1, $F4-$FF |
| 5 | sine_table_16bit_quarter, block note | "Duplicate ... for bank alignment ... separate addressing context"; "512-entry tables" unexplained | mode7_perspective indexes `(BC & $1FF) × 2` into sine_table_16bit and cosine_table_16bit; sizes 128+128+256 = 512 words (sine) and 128+256+128 = 512 words (cosine) — the "duplicate" quarter completes the cosine cycle | E1 mode7_perspective.asm 150-175 + sizes |

Cross-file defects found (fix in later iterations): `system_core.asm:201` comment "(+$14 offset)" should be +`$20`; `system_init.asm:266` comment says the zero byte is "scene_flag_table" but the address is `sine_table_8bit` (entry 0); docs `bank01-data-tables.md` §9f/9g repeat the wrong descriptions.

### File 2: system/engine/cop_handlers_dungeon_switch.asm (53 lines, Bank 00)

| Q | Verdict | Findings | Disposition |
|---|---------|----------|-------------|
| Q1 | M | No block note; handlers lacked register/exit notes | FIXED (block note, TYX/RTI-frame comments) |
| Q2 | M | Comments restated names | FIXED |
| Q3 | M | SwitchCase "one word and one Address" — both operands are words (table base is a script-bank offset); scratch `$0000` reuse and missing range check undocumented | FIXED |
| Q4 | P | `enemyNum` (`$7F0022`) documented in docs/wram-memory-map.md | NOFIX |
| Q5 | NA | n/a | NOFIX |
| Q6 | M | names match COP names | NOFIX |
| Q7 | P | E1 + E2 (zip_fly `SwitchCase(#$0000, ...)`, flag_helpers SetWramFlag, wram-memory-map) | n/a |

### File 3: system/engine/cop_handlers_offscreen.asm (63 lines, Bank 00)

| Q | Verdict | Findings | Disposition |
|---|---------|----------|-------------|
| Q1 | M | No block note | FIXED |
| Q2 | M | "script name BranchIfOffscreen" is a stale alias (no such name in any asm/doc) | FIXED |
| Q3 | **F** | HaltIfMaxFrames semantics were inverted: the code resumes when the counter is **above** the threshold (`CMP` then `BCC`), otherwise it rewinds `$00` to the COP and yields. `$00E4` is the ending/credits timeline counter (`STZ`/`INC`, `$FFFF` = stopped), not an "actor limit" | FIXED (notes); mnemonic rename PROPOSED |
| Q4 | **F** | `actorLimitThreshold` ($00E4) misnamed | PROPOSED (row 22) |
| Q5 | NA | n/a | NOFIX |
| Q6 | M | `BranchIfOffCamera` ok; window is the camera scroll-limit rectangle | NOFIX |
| Q7 | M | E1 + E2 (credits scripts, wram-memory-map); camera-limit semantics from docs only | DEFERRED-EVIDENCE (E5 would confirm) |

### Shared gate (I003 + I004)

Ingest dry-run clean (2 new block notes, 4 updated; 27 part notes; 21 new / 51 updated comments), applied, re-dry-run no-op; `npm run extract:lt` and `npm run rebuild` OK; CRC 2083230829 / checksum 223006080 / totalSize 3062204 unchanged. Mnemonics verified in output (`$bg3TilemapBuffer`, `$eventFlagsF8toFF`, etc.).

---

## I005 — actor_execution, cop_handlers_bg_rearrange, cop_handlers_world_map

### File 1: system/engine/actor_execution.asm (1206 lines lt, Bank 03, 248xxx-250xxx)

Full read of all parts (RunActors_Normal/CutsceneOnly/OverlayOnly, PostTick, CopScriptPostTick, PauseFiltered, InitActorPool, SpawnSceneActors, AdvanceSceneDataAndFree, InitActorFromSceneData, CheckEnemyDefeatedFlag). Evidence: E1 code trace of every branch; E2 greps of callers and of every consumer of the fields named; E3 `docs/wram-memory-map.md` (playerFlags, extended actor data); E2 reads of `ApplyPlayerHitstun`, `hit_stagger_controller`, `combat_collision`, `event_blocks`, `actor_pool`, `sprite_composition`, `inventory_overlay`.

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Block note was missing callers/paths; the part notes were fine in size | FIXED |
| Q2 | M | Several inline comments restated the instruction | FIXED |
| Q3 | **F** | 13 inaccuracies: (1) combat lock `playerFlags $0008` strips the **attack button** (`$0080`), not "B button/input"; (2) iframe counter sign convention inverted: positive = hit-stun (non-player actors skip the entire tick), negative = recovery (keeps running); (3) the script-driven path (`$10` bit 13) skips iframe handling and moves only if `$12` bit 3; (4) `InitActorPool`: `$4E/$50` is a long pointer (bank in `$50`), not a count; the `$7F1000` / `$7F2000` region roles were swapped (extended fields live at `$7F1000-$1FBF`, callbacks at `$7F2000-$2FBF`); (5) scene `$FF` is the inventory screen, not the title; (6) `SpawnSceneActors` carry semantics wrong; (7) record byte 8 is the event-block index, not a "death action"; (8) `$4000` in `$10` is the **off-screen** flag (depth sort), not "visible"; (9) defeat flag is scene-local (`wramFlags`), not permanent; (10) camera formula is pos-`$80`, with X+8 for the sprite origin; (11) `$0E` formula; (12) `$0AEC/$0AEE` are the remaining-enemy counters (binary / BCD); (13) PauseFiltered quirk (A holds `$12` on one path) | FIXED (block note, 10 part notes, 22 inline comments) |
| Q4 | M | `deathActionIdx` is a misnomer for the event-block index; `iframeCounter` hides the sign convention; `$0646`, `$0AEC`, `$0AEE` were unnamed | PROPOSED (rows 27, 28); FIXED (3 mnemonics) |
| Q5 | **F** | `$0646` (scene table index, 7 operands in 6 files), `$0AEC` (`enemiesRemaining`), `$0AEE` (`enemiesRemainingBcd`) repeated across ~18 files | FIXED (mnemonics `sceneTableIndex`, `enemiesRemaining`, `enemiesRemainingBcd`) |
| Q6 | M | Names fine except the two noted above | PROPOSED |
| Q7 | M | E1+E2+E3. Runtime unverified: `$10` bit 3 meaning, `$06F0` default properties, `$7F0E00` vs `$7F0F00` zeroing | DEFERRED-EVIDENCE (OQ-15, OQ-18, OQ-20) |

Observation (analysis only): `AdvanceSceneDataAndFree` writes through `$0006,Y` with Y from the dying actor's `$04`; if the sole actor is freed, Y is 0 and absolute `$0006` is written. Not proven harmful; recorded in OQ-17.

### File 2: system/engine/cop_handlers_bg_rearrange.asm (64 lines, Bank 00, 37655-37728)

| Q | Verdict | Findings | Disposition |
|---|---------|----------|-------------|
| Q1 | M | No block note | FIXED (with 102-site count) |
| Q2 | M | OK after rewrite | FIXED |
| Q3 | **F** | Notes said "queue BG tilemap/palette swap" — `LookupEventBlock` stages tile rectangles (carry ignored); `AnimateEventBlock` carry semantics were mis-stated; the only caller of COP #34 is `SpawnFieldRevealEffect`; usage "ending and Babel Tower" understated (102 sites across many areas) | FIXED |
| Q4 | M | n/a | NOFIX |
| Q5 | NA | n/a | NOFIX |
| Q6 | M | `StageBgChange*` names acceptable (stage then apply) | NOFIX |
| Q7 | P | E1+E2 (`event_blocks`, call-site grep) | n/a |

### File 3: system/engine/cop_handlers_world_map.asm (69 lines, Bank 00, 40274-40380)

| Q | Verdict | Findings | Disposition |
|---|---------|----------|-------------|
| Q1 | M | No block note | FIXED |
| Q2 | M | Inline comments restated | FIXED |
| Q3 | **F** | "companion byte" is the **route ID** (`$0D5A`); the first byte is stored to `$0D5E`, always 0 and never read; storing `$0D52` arms the transition to scene `$FE` (not "destination X"); `StageWorldMapMove` clears the choice ID; "Dao/Itory/Watermia/Freejia" understated: 10 towns (13 sites); selection IDs 1-`$1B` | FIXED |
| Q4 | M | `$0D52-$0D5C` unnamed | FIXED (6 mnemonics); `$0D5E` PROPOSED (rows 29, 30) |
| Q5 | **F** | World-map block `$0D52-$0D5C`: 42 + 6 + 4 + 9 + 10 operands | FIXED (`worldMapStagedX/PlayerX/PlayerY/ChoiceId/RouteId/RouteReturnPtr`) |
| Q6 | M | OK | NOFIX |
| Q7 | P | E1 + E2 (`WorldMapController`, `HdmaWindowEffect`, all 3 handlers' call sites) | n/a |

## I006 — tile_collision_physics, cop_handlers_thinker, cop_handlers_inventory

### File 1: system/engine/tile_collision_physics.asm (1156 lines lt, Bank 03, 250xxx-251xxx)

Full read. Evidence: E1 (pointer arithmetic traced by hand through `CalcTileMapOffset` and the Advance routines), E2 (`map_coords` `MapIndexMoveDown/Right`, `hardware_math` `SignedMultiply`), E3 (`docs/code/bank00/data-tables-memory.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Block note lacked the tile-map format | FIXED |
| Q2 | M | Some inline comments restated; replaced with semantics | FIXED |
| Q3 | **F** | 9 inaccuracies: (1) tile-map offset is page-based (high byte = `(tileY>>4)*stride + (tileX>>4)`, low byte = `(tileY&$F)<<4 | (tileX&$F)`), not a flat row/column; (2) `AdvanceTileOffsetRight` really adds +Y and `...Down` adds +X (names swapped); (3) DBR is switched to the sprite-data bank for hitbox reads, the map is read through `[$80]`; (4) `SolidH/SolidV` TYX wording; (5) CheckAdjacent semantics (next tile right/below); (6) `$0004` is an absolute scratch (not DP); (7) X flip via `$12` bits 14/13; (8) special tiles return carry **set** (axis movement dropped); (9) snap limitations | FIXED (block note, 12 part notes, 20 inline comments) |
| Q4 | **F** | `AdvanceTileOffsetRight/Down` names do not match behavior | PROPOSED (row 26) |
| Q5 | M | `$80-$82` pointer already mnemonic-resistant (DP) | NOFIX |
| Q6 | M | `CalcTileMapOffset`, `SolidH/V` fine | NOFIX |
| Q7 | M | E1+E2+E3; tile types `$06/$09` meaning not proven | DEFERRED-EVIDENCE (OQ-16) |

### File 2: system/engine/cop_handlers_thinker.asm (94 lines, Bank 00, 37888-38020)

| Q | Verdict | Findings | Disposition |
|---|---------|----------|-------------|
| Q1 | M | No block note | FIXED (16-slot pool, `$52/$54` free list, `$5A/$5C` list, site counts 21/56/29) |
| Q2 | M | Comments restated | FIXED |
| Q3 | **F** | KillThinker said "actor"/"free stack": it is a thinker free-list; 8-bit `DEC` of the low byte is safe (list `$7E:3000-$3021`); D is forced to 0 so `$0052`/`[$52]` address the global pointer | FIXED |
| Q4 | M | OK | NOFIX |
| Q5 | NA | n/a | NOFIX |
| Q6 | M | OK | NOFIX |
| Q7 | M | E1+E2 (`actor_pool`); failure paths unverified | DEFERRED-EVIDENCE (OQ-17) |

### File 3: system/engine/cop_handlers_inventory.asm (99 lines, Bank 00, 44037-44161)

| Q | Verdict | Findings | Disposition |
|---|---------|----------|-------------|
| Q1 | M | No block note | FIXED (site counts 49/34/35/5) |
| Q2 | M | OK | FIXED |
| Q3 | **F** | `GiveItem` side effects not documented (`$0DB8` item ID, Y dialogue pointer ignored); `RemoveItem` resets the equipped state; `BranchIfItemEquipped` compares one byte of a 16-**byte** array (docs say "16 item words" — wrong, `CheckInventoryForItem` steps by INY) and index `$FFFF` wraps to `$0AB3` | FIXED (notes); docs fix PROPOSED (row 31); OQ-19 |
| Q4 | M | OK | NOFIX |
| Q5 | NA | n/a | NOFIX |
| Q6 | M | OK | NOFIX |
| Q7 | P | E1 + E2 | n/a |

### Cross-file fix (I002 file)

`combat_collision.asm` `{245488}`: "invincibility ($0011)" corrected to hit-stun (positive counter freezes the victim); recovery = negative `$FFEF`. Re-ingested with this batch.

### Shared gate (I005 + I006)

Ingest dry-run clean (4 new block notes, 2 updated; 30 part notes updated; 5 new / 57 updated comments), applied, re-dry-run no-op; `npm run extract:lt` and `npm run rebuild` OK; CRC 2083230829 / checksum 223006080 / totalSize 3062204 unchanged. 9 mnemonics extracted and applied (`sceneTableIndex` visible in radar_map_screen, thinker_execution, warps_interaction; world-map names in the three handlers).

---

## I007 — DialogStringRenderer, hdma_ramp_tables, cop_handlers_actor_flags

### File 1: system/engine/DialogStringRenderer.asm (1153 lines lt, Bank 03, 254556-256052)

Full read. Evidence: E1 (stack frames, dispatch and box geometry hand-traced), E2 (`vblank_joypad`, `system_core` NMI/`UpdateFrameDialogue`, `sFA_diary_menu`, `interaction_handlers`), E3 (`wram-memory-map.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Block note missing `$00EE`/`$00DC`/DBR facts; several parts had no note (`HexDigitTileTable`, `DialogueBorderTiles`, command table) | FIXED |
| Q2 | M | Some inline comments restated the opcode | FIXED |
| Q3 | **F** | ~14 defects: BG3 row stride is `$40` bytes (not `$80`) and a text line is `$80`; template/dictionary table names; `PrintNumber` operand order (count first, then BCD data address) and stack frame; `$C6`/`$CF`/`$D0` descriptions; wait masks (`$C040` is the logical confirm/cancel/palette mask, `$0F00` = D-pad, not "A/B/Start"); `joypadHeld` is a consumption mask; scene `$FA` is the diary menu (not the title); extra blank row semantics; cursor blink period 32 frames; `ClearDialogueBox` extent; dead load at 255574 | FIXED (block note, 20 part notes, 26 inline comments) |
| Q4 | M | Names accurate; `$00EE` = menu-mode flag proven by `sFA_diary_menu` writes | FIXED (mnemonic `menuModeFlag`, 5 operands) |
| Q5 | M | `$00EE` mnemonic added; `$00DC` only ever zeroed (no mnemonic) | FIXED / NOFIX |
| Q6 | M | `HexDigitTileTable`, `DialogueBorderTiles`, `DialogStringCommandTable` named correctly | NOFIX |
| Q7 | M | E1+E2; digit-count > 4 leading zeros, displayModeFlags bit 0 consumer, `$00DC` reader unproven | DEFERRED-EVIDENCE (OQ-23, OQ-27) |

### File 2: system/hdma_ramp_tables.asm (106 lines lt, Bank 03, 121022-121201)

Evidence: E1 (consumers `SetupHdmaChannel_Direct/Indirect`, `QueueHdmaChannel`, `ParallaxResolveChannelSpeed`, `ramp_motion_curve_step`), E2 grep of referencers.

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | No block note; the three parts are unrelated tables | FIXED |
| Q2 | M | OK after rewrite | FIXED |
| Q3 | **F** | `hdma_channel_config` bits (DMAP mode in the low 3 bits; indirect flag `$40` is OR'd by code); old note cited `cop_handlers_solid.asm` (wrong; real referencers `hdma_dma_spc`, `cop_handlers_hdma_dma`, `parallax_thinker`); `parallax_speed_config` only entries 00-02 reachable (`config & 7`); ramp curves are signed per-frame Y pixel deltas (curve 0: 64 bytes, -16..+16, net 0; curve 1: 32 bytes, -8..+8, net +8), not accelerations | FIXED (block note, 5 part notes) |
| Q4 | M | n/a | NOFIX |
| Q5 | NA | n/a | NOFIX |
| Q6 | **F** | Block name `hdma_ramp_tables` covers three unrelated tables; `binary_01D911/01D951` are unnamed curve data | PROPOSED (rows 38, 39) |
| Q7 | M | E1+E2; bit 7 on entries `$34-$3F` unexplained | DEFERRED-EVIDENCE (OQ-21) |

### File 3: system/engine/cop_handlers_actor_flags.asm (108 lines lt, Bank 00, 39658-39817)

Evidence: E1 (both handlers traced), E2 (`collision_branch.md`, `copdef.json`, 7 script sites).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | No block note | FIXED |
| Q2 | M | OK | FIXED |
| Q3 | **F** | `BranchIfBehindWall` note was inverted (code branches when OCCLUDED); `BranchIfCollisionTypeNe` branches on EQUAL; both use pixel>>4 with no -1 row adjustment (differs from `TileCollisionQuery`); layer-aware path has a redundant BEQ/BRA | FIXED (block note, 2 part notes, 6 inline comments) |
| Q4 | **F** | Block name suggests actor flags but contains collision probes; COP name `...TypeNe` contradicts behavior | PROPOSED (rows 32, 33) |
| Q5 | NA | n/a | NOFIX |
| Q6 | **F** | See Q4 | PROPOSED |
| Q7 | M | E1+E2; layer-aware bit meaning inferred (OAM priority bit) | DEFERRED-EVIDENCE (OQ-24) |

---

## I008 — cop_handlers_collision, GetPlayerFacingDirection, cop_handlers_callbacks

### File 1: system/engine/cop_handlers_collision.asm (1083 lines lt, Bank 00, 34934-46208, non-contiguous)

Full read. Evidence: E1 (probe/paint paths, `TileCollisionQuery`, rectangle loops traced by hand), E2 (`map_coords.TileCoordsToMapIndex`, `tile_collision_physics`, `cop_handlers_player_query/player_sprite`), E3 (`collision_paint.md`, `collision_branch.md`, `copdef.json`, `wram-memory-map.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | No block note; COP ids/site counts missing | FIXED |
| Q2 | M | Several comments restated mnemonics (BIT, LSR chains) | FIXED |
| Q3 | **F** | ~12 defects: "collision type zero" meaningless for `MarkSolidHere` (STZ is only a Clear-path flag); `TileCollisionQuery` return value (word, `$000F` for blocked/out-of-bounds/index>=`$4000`) and "camera viewport" wording; `BranchIfSolid*` branch on any `$000F` bit (also non-zero terrain type), `Type*` ops match `$0F` for solid; `BranchIfNotOnGridline` operand is the hitbox X offset (forced negative), not "width"; `ParseSignedTileOffset` callers list wrong (only MarkSolidOffset/ClearSolidOffset); `ComputeDirectionToPlayer` branch comments at 45064/45075 wrong, rule documented (|dY|<$10 gives pure E/W); `+$F0` column wrap = next page same row; hitbox header layout; `SetCollisionAbs` PHY/PLX; ClearCollisionRect flag word comment | FIXED (block note, ~17 part notes, ~25 inline comments) |
| Q4 | **F** | Handler labels `BranchIfType*` differ from copdef `BranchIfSolidType*` | PROPOSED (row 34) |
| Q5 | NA | WRAM `$0018/$001C` are general scratch in 25+ files; `mapBoundsX`/`mapRowStrideL0` already named | NOFIX |
| Q6 | M | Helper names accurate | NOFIX |
| Q7 | M | E1+E2+E3; `AdvanceMapY` page byte comes from the accumulator hidden byte (not reloaded from `$1C`), unchecked index range in Offset/Abs ops, row-adjust inconsistency | DEFERRED-EVIDENCE (OQ-24, OQ-25, OQ-26) |

### File 2: system/engine/GetPlayerFacingDirection.asm (112 lines lt, Bank 03, 258250-258512)

Evidence: E1 (both paths traced), E2 (`cop_handlers_player_sprite` `SetPlayerSpriteDirect`, `body_table`), E3 (`cop-commands-reference.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | OK after edit | FIXED |
| Q2 | M | Header speculation about Freedan removed | FIXED |
| Q3 | **F** | `playerFlags` bit 15 is the sprite-override flag (not "transformed"); `$0AC8` is the `body_table` index, and indexes 4-7 (will_alt, ability_fx, freedan_fx, shadow_fx) select the tables, so the Will/Freedan/Shadow_A/Shadow_B labels are wrong; `GetPlayerFacing_AltEntry` is only a fallback label (not an alternate entry); last three form tables are all zero | FIXED (header, 2 part notes, 6 inline comments) |
| Q4 | **F** | Labels `FacingData_*`, `AltEntry` misleading | PROPOSED (rows 35, 36) |
| Q5 | NA | n/a | NOFIX |
| Q6 | **F** | See Q4 | PROPOSED |
| Q7 | M | E1+E2; direction code order conflict with `BranchOnPlayerFacing` comments, runtime check of `$0AC8` mapping | DEFERRED-EVIDENCE (OQ-22, OQ-28) |

### File 3: system/engine/cop_handlers_callbacks.asm (113 lines lt, Bank 00, 39527-39657)

Evidence: E1, E2 (consumers `hit_stagger_controller`, `combat_collision`, `actor_pool` init, mummy queen actors), E3 (`copdef.json`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | No block note | FIXED |
| Q2 | M | OK | FIXED |
| Q3 | **F** | `SetDeathCallback` operand is an `@Code` far pointer (word + bank), not "&Code plus a byte"; `AndExtraFlags` operand is a keep-mask; custom callback is read by `combat_collision` as the push-hit interaction handler (and reused by the mummy queen); slot-indexed tables | FIXED (block note, 3 part notes) |
| Q4 | M | `scratch1010+6` is a poor name for the custom callback | PROPOSED (row 37) |
| Q5 | **F** | `$7F1006` death-callback bank repeated in 4 operands | FIXED (mnemonic `onDeathCallbackBank`: hit_stagger_controller, combat_collision x2, cop_handlers_callbacks) |
| Q6 | M | OK | NOFIX |
| Q7 | M | E1+E2 | n/a |

### Shared gate (I007 + I008)

Ingest dry-run clean (3 new block notes, 3 updated; 2 new / 40 updated part notes; 14 new / 56 updated / 1 deleted comments), applied, re-dry-run no-op; `npm run extract:lt` and `npm run rebuild` OK; CRC 2083230829 / checksum 223006080 / totalSize 3062204 unchanged. Mnemonics `menuModeFlag` ($00EE: `DialogStringRenderer` 1, `sFA_diary_menu` 4) and `onDeathCallbackBank` ($7F1006: 4 operands) verified in the extracted output. New `mnemonics.json` keys were inserted in sorted order; no existing key changed.

---

## I009 — warps_interaction | cop_handlers_palette | cop_handlers_hdma_dma

### File 1: system/engine/warps_interaction.asm (1046 lines lt, Bank 02, 173533-174986)

Full read. Evidence: E1 (chest guards, tile search, opening/dialogue actors, warp AABB and ExecuteWarp traced by hand), E2 (`scene_barrier_chest_table`, `game_over_sequence`, `forced_walk`, `scene_lifecycle` `InitCameraBounds`, `cop_handlers_player_query` `QueueMapChange`, `inventory_mgmt`, `item_get_dialog_table`, `vblank_joypad`), E3 (`docs/audio/bgm-track-listing.md`, `wram-memory-map.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Block note existed but described the wrong mechanics; rewritten section by section | FIXED |
| Q2 | M | Several comments restated mnemonics ("Load ...") or guessed purpose | FIXED |
| Q3 | **F** | ~15 defects: `PlaceBarrierTiles` redraws OPENED chests (open tiles `$FC-$FF`), not barriers; chest record byte 3 bit 7 = animated-music-open flag (not an end sentinel), byte 0 bit 7 = end; chest needs Up + facing code 1 (OQ-22 support); `$CFF0` is really `$CFFC` (all buttons except Select/Start); `$20` handed to the dialogue actor is the item ID (restored to `$0DB8`), not a "render bank"; dialogue index is the track number +1; `musicParentActor` copy in `orbitAngle` restores the scene music; `dmaSkipFlag` write is the VRAM queue terminator; `displayModeFlags` bit 7 = display-filter mode; entry Y is the bottom row; `ConvertWarpToPixels` bound is exclusive (`w×16 − 15`); `$0AF4/$0AF6` revive pointer (100+ gems) vs `sceneSaveData` `$0AF0/$0AF2` (bit 7 of entry byte 9, true game over); extended warps: `$0650` = walk-step stream pointer (entry+7), `$0652` = packed camera window for `InitCameraBounds`, `scrollStepTableBase` low nibble = walk sequence index | FIXED (block note, ~12 part notes, ~80 inline comments) |
| Q4 | **F** | Four raw RAM operands (`$0AF2/$0AF4/$0AF6/$0AF8`); `PlaceBarrierTiles`, `code_02AAF2`, `scene_barrier_chest_table` misnamed/unnamed | FIXED (4 mnemonics) / PROPOSED (rows 41-43, 46) |
| Q5 | **F** | `$0AF2/$0AF4/$0AF6/$0AF8` are used in game_over_sequence, warps_interaction, cop_handlers_player_query, player_character and 4 boss-lair actors | FIXED (`sceneSaveDataBank`, `reviveWarpPtr`, `reviveWarpBank`, `gameOverWakeupFlag`). `$0DB8` still unnamed (item id vs render bank in different files) |
| Q6 | **F** | See Q4 | PROPOSED |
| Q7 | M | E1+E2+E3; chest fanfare track numbers and the "save warp" meaning of bit 7 are inferred | DEFERRED-EVIDENCE (OQ-29, OQ-30) |

### File 2: system/engine/cop_handlers_palette.asm (130 lines lt, Bank 00, 37729-37887)

Evidence: E1, E2 (`ambient_palette_cycler`, `actor_pool` `PaletteResetAndKillThinker`, `cop_handlers_thinker` `SpawnThinkerParam`), E3 (`docs/cop/families/palette.md`, `copdef.json`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | **F** | Block header described BG event-block and thinker ops (copy of a different file) | FIXED (rewritten: 5 palette ops #36-#3A, 177 sites, sub-entry model, Start/Step yield contract) |
| Q2 | M | Inline comments mostly restated code | FIXED |
| Q3 | **F** | Bundle sub-entry layout (6 bytes: hold, chatPtr, metasprite index, gfx type/bank, animScratch), bundle ID is the existing `animScratch+2` (not forced 0; `SpawnThinkerParam` seeds it), `PaletteStartLoop` count = total passes, Step ops must directly follow Start ops, carry meaning of `LoadPaletteBundle` | FIXED (block note, 5 part notes, ~25 inline comments) |
| Q4 | M | Names accurate | NOFIX |
| Q5 | NA | Operands already use `animScratch`, `retPtr1`, `spritesetPtr`, `chatPtr`, `metaspritePtr` | NOFIX |
| Q6 | M | OK | NOFIX |
| Q7 | M | E1+E2; per-frame `DecompressGfxToVram` during the hold delay unexplained | DEFERRED-EVIDENCE (OQ-31); docs error in row 45 |

### File 3: system/engine/cop_handlers_hdma_dma.asm (135 lines lt, Bank 00, 34382-34579)

Evidence: E1 (stack tracing of the operand words in all four handlers), E2 (`hdma_dma_spc` `ResetHdmaState`, `hdma_ramp_tables` `hdma_channel_config`, `scene_lifecycle` callers), E3 (`docs/cop/families/{hdma_dma,sine_hdma}.md`, `copdef.json`, SFC wiki B-bus registers).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | **F** | No block note | FIXED (shared operand layout, three HDMA binding variants) |
| Q2 | M | Comments in GenHdmaSine restated opcodes | FIXED |
| Q3 | **F** | Operand model: 3-byte table address then a B-bus register byte; the handler reads A = bank (low) | register (high), which indexes `hdma_channel_config` (earlier note said "channel config word"); `QueueDma` is a direct-table HDMA channel, not DMA; `GenHdmaSine` table is `[$FF, ptr, $E0, ptr+$FE, $00]` = 127 + 96 repeat-mode scanlines (not "224 lines / CGRAM"), phase counter in `spritesetPtr`; `QueueHdmaChannel` has 2 sites (not 3) and pins a channel | FIXED (block note, 4 part notes, ~25 inline comments; 2 obsolete inline comments at 34425/34431 removed and merged into 34423/34429) |
| Q4 | **F** | `QueueDma` misleading; B-bus registers called "channel" in other files | PROPOSED (rows 44, 45) |
| Q5 | NA | Operands use existing names | NOFIX |
| Q6 | **F** | See Q4 | PROPOSED |
| Q7 | M | E1+E2+E3. Consequence for I007: the `hdma_channel_config` note and OQ-21 (bit 7 of `$34-$3F`) were wrong/unnecessary: those are PPU read registers, bit 7 = direction. `hdma_ramp_tables.asm` part note re-edited | FIXED (hdma_ramp_tables note), OQ-21 resolved, OQ-32 opened |

### Shared gate (I009)

Covered by the combined gate at the end of I010.

---

## I010 — ConsoleStringRenderer | oam_digit_compose | cop_handlers_input

### File 1: system/engine/ConsoleStringRenderer.asm (1041 lines lt, Bank 03, 256610-257943)

Full read, every handler traced. Evidence: E1 (stack offsets, `$09A0` flow, each command), E2 (`db-us/stringTypes.json` command ids/tags, `tables/system_strings` text corpus, `sF7_credits` private copy, `system_core` default `$20`, `item_component_table`), E3 (`docs/code/bank03/text-and-menus.md`). Not a sampled file.

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Sized well; added a Tag column and the data-bank/WRAM-mirror note | FIXED |
| Q2 | M | Several inline comments repeated the instruction | FIXED |
| Q3 | **F** | ~20 defects: a tilemap row is `$40` bytes, so `$11` (`[N]`) is ONE row and `$0D` (`[DBL]`) TWO rows (comments and labels said 2 and 4); AdvanceRow ignores the current column and uses the `$09A0` line start; `$10` inserts a shared word (`[LU:C]` = 'Statue ') not an item name; `$099E/$099F` is one attribute word whose low byte is replaced by digit/tile bytes in BCD/FillTile; `PrintBcdNumber` memory order; Print3Digit clamps only the hundreds digit (1005 prints 905); `ClearRect` (RCC) height reads the NEXT string byte as high byte, so it must end the string; `DrawBox` cursor `+$82` is the second interior row; `ClearColumn` width and a dead TAY; HP bars: clamp is written back, HP clamped only if max was clamped, bar blanks second row, HpBar_AdvanceRow early exit pops the return into DrawHpBar (not "DrawHpBar's return"); equipment icon rows; operand addresses are in the current data bank (WRAM mirror) | FIXED (header + command table with tags, ~25 part notes, ~45 inline comments) |
| Q4 | **F** | `AdvanceRow2/4` wrong row counts; `InsertItemName` misnomer; `sceneStateHelper` is the attribute high byte | PROPOSED (rows 47-49) |
| Q5 | **F** | `$099E` (14 operands in this file, 2 in sF7_credits) and `$09A0` (6 + 4) repeated | FIXED (mnemonics `consoleAttrWord`, `consoleLineStart`; all raw operands verified gone from the extracted output) |
| Q6 | **F** | See Q4 | PROPOSED |
| Q7 | M | E1+E2; BCD suppression tile `$20` vs string map '.', DrawBox spacing, line spacing on screen, vanilla use of STR/CLR/CPY/UNK: none found | DEFERRED-EVIDENCE (OQ-33, OQ-34); docs error row 50 |

### File 2: system/engine/oam_digit_compose.asm (139 lines lt, Bank 03, 244449-244613)

Evidence: E1, E2 (callers `SpawnAttackTrailEffect`, `ec11_countdown`, `mu67_bomb`, `it1B_trial`, diary menu, `combat_collision.FormatDamageDigits`, `sprite_composition.RenderComposeBuffer`, `system_core` terminator).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Header sized well; entry conditions clarified | FIXED |
| Q2 | M | OK after edits | FIXED |
| Q3 | **F** | Callers: not only combat damage (countdown digits in 3 scenes, diary counter, unused AttackTrailShort); `ComposeDigits_Continuation` is a second entry for caller-supplied cursor/attribute (not "append digits"); the `$F000` guard cannot trigger from `FormatDamageDigits`; leading-zero suppression rule (tens skipped only if hundreds and tens are zero); entries are in world coordinates and no end marker is written here | FIXED (header, 3 part notes, 7 inline comments) |
| Q4 | M | `ComposeDigits_Continuation` misleading | PROPOSED (row 53) |
| Q5 | **F** | `$7F3101/02/04/06/08/0A` offsets of the compose buffer (entry fields: X +0, Y +2, tile +4) | FIXED (mnemonics `oamComposeBuffer+1/+2/+4/+6/+8/+A`; operands: oam_digit_compose 2, sprite_composition 2, SpawnHitSparkSprites 5, scene_lifecycle 1, inventory_overlay 1, system_core 3) |
| Q6 | M | OK | NOFIX |
| Q7 | M | E1+E2; shift of 6 px and `$001A` store unexplained | DEFERRED-EVIDENCE (OQ-35) |

### File 3: system/engine/cop_handlers_input.asm (148 lines lt, Bank 00, 38021-38190)

Evidence: E1, E2 (`vblank_joypad` pipeline, `player_character` usage, `DialogStringRenderer` wait command, grep of ~190 BranchIf* sites and 0 Wait* sites), E3 (`copdef.json`, `cop-dispatch`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | **F** | Header claimed 11 handlers incl. world-map staging, `RunBg3Script`, dialogue ops; the file has 4 (those live in `cop_handlers_world_map` and `cop_handlers_dialog`) | FIXED |
| Q2 | M | Comments restated code | FIXED |
| Q3 | **F** | `joypadCurrent` = held buttons minus consumed/masked ones, `joypadRaw` = remapped held state without masking (not "latched state"/"held-edge"); bit 0 of the mask is the selector because joypad word bit 0 is never a button; script name is `WaitForButton` (not "WaitUntilButton"); `WaitForButton/WaitForRelease` have no vanilla users; rewind is opcode + word (4 bytes) | FIXED (block note, 4 part notes, ~10 inline comments) |
| Q4 | M | Names match copdef | NOFIX |
| Q5 | NA | Operands already named | NOFIX |
| Q6 | M | OK | NOFIX |
| Q7 | M | E1+E2; `docs/cop/families/input.md` not reviewed | PROPOSED (row 51) |

### Shared gate (I009 + I010)

Ingest dry-run on 7 files (6 audited + `hdma_ramp_tables`): 1 new block note, 5 updated; 49 part notes updated; 10 new / 152 updated / 2 deleted comments (the 2 deletions are the obsolete 34425/34431 entries, intentionally merged); applied, re-dry-run no-op; `npm run extract:lt` and `npm run rebuild` OK; CRC 2083230829 / checksum 223006080 / totalSize 3062204 unchanged. New `mnemonics.json` keys (sorted, nothing existing changed): `consoleAttrWord` (2462), `consoleLineStart` (2464), `sceneSaveDataBank` (2802), `reviveWarpPtr` (2804), `reviveWarpBank` (2806), `gameOverWakeupFlag` (2808), `oamComposeBuffer+1/+2/+4/+6/+8/+A` (8335617-8335626). Blast radius from the post-extract output: `$0AF2/$0AF4/$0AF6/$0AF8` in game_over_sequence, warps_interaction, cop_handlers_player_query, player_character and mu67_vampires, sg55_viper, ir29_castoth, sEA_solid_arm; `$099E/$09A0` only ConsoleStringRenderer and sF7_credits; no raw operands of these addresses remain. The `+A` hex-offset name rebuilt cleanly.

---
## I011 — sprite_composition | GlobalInputHandler | cop_handlers_oam_attribs

### File 1: system/engine/sprite_composition.asm (972 lines lt, Bank 03)

Evidence: E1 (full trace of the depth sort, bucket re-zero, tile-DMA list and mirror handling), E2 (`system_core` `oamWriteOffset`/`$FFFF` terminator, `combat_collision` render-list iteration, `hdma_dma_spc` `DmaPlayerTilesToVram`, `ApplyPlayerHitstun`, `hit_stagger_controller`, `sc01_seagull`, `ir25_ceiling_tile`), E3 (`docs/code/bank03/{actor-thinker-runtime,sprite-rendering}.md`, `docs/wram-memory-map.md`), E4 (OAM Y displays one scanline low; lower OAM index draws in front).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Header and part notes were the right size, but several repeated the same misreading | FIXED (header + part notes tightened) |
| Q2 | M | Roughly a dozen comments restated the instruction | FIXED |
| Q3 | **F** | ~45 inaccurate comments, mostly in these groups: (a) depth sort priority was described backwards (lower OAM index = in front, so front-most actors are written first); (b) `ClearActorRenderList` is called from scene setup/transition paths, not every frame; (c) `$E080` constant bytes are the "hidden sprite" Y/attr values; (d) DP `$08` holds the tile-DMA list pointer, `$06FC/$06FE` the player tile source address and bank, `$06FF-$070F` the 16-entry tile-DMA list; (e) the mirror bits (`$4000`/`$8000` equivalents) are applied to the sub-sprite X offset by negation, not by a table; (f) `-$11`/`-$10` are the sprite-centre offsets for Y/X; (g) off-screen sub-sprites are skipped individually and the carry return only tells the caller whether anything was written; (h) iframe flags blink the actor by skipping the draw; (i) `$00DA` is a byte count; (j) `OamHiTableMasks` selects the 2-bit slot (size+X high) per OAM index; (k) the bucket array is re-zeroed by the sort itself (PHA/PLA pass) | FIXED |
| Q4 | **F** | Raw operands `$0200` (bucket array, mnemonic `deathFlag`), `$0C00/$0C02` (render list), `$0422-$0424` (OAM staging), `$06FE/$06FF/$070F`, `$09CC/$09CE`, `joypad` high bytes | FIXED (mnemonics, see gate) / PROPOSED (row 54) |
| Q5 | **F** | `$0C00` is also iterated by `combat_collision`; `$0422` by `UploadOamTable`; `$09CC/$09CE` proven to be the player sprite cache (metasprite pointer + bank), used by `inventory_overlay` | FIXED (13 mnemonics) |
| Q6 | **F** | Mnemonic `deathFlag` (`$0200`) is wrong: nothing reads it as a death flag; it is the depth bucket array. `docs/wram-memory-map.md:170` documents a `deathFlag` that no code uses. `SetOamPriority`/`SetOamPalette` in `cop_handlers_oam_attribs` disagree with copdef names | PROPOSED (rows 54, 57) |
| Q7 | M | E1+E2+E3+E4; `layerPriorityFlag` bit 12 (`RenderComposeBuffer` block-copy mode) has no setter found, meaning of actor flag `$10` bit 4 in the blink gate, purpose of `STZ $070F` | DEFERRED-EVIDENCE (OQ-36, OQ-38, OQ-40); docs errors in rows 58-59 |

### File 2: system/engine/GlobalInputHandler.asm (164 lines lt, Bank 03)

Evidence: E1 (every branch traced), E2 (`vblank_joypad` pipeline, `system_init` remap defaults, `radar_map_screen`, `item_use_system`, `inventory_overlay`), E3 (`db-us/transforms.json`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | OK | NOFIX |
| Q2 | M | Several comments restated the code | FIXED |
| Q3 | **F** | The map screen is a Start **toggle** (press to open, press again to close), not hold-to-view; the item-use button is logical `$0008` (vanilla Y `$4000`, remapped via `transforms.json`); the `$6000` consume constant is Select+Y (not Select+L); the radar index is kept on the stack, not in a register; `$0657/$0659` roles | FIXED (header, part note, ~10 inline) |
| Q4 | M | Names accurate | NOFIX |
| Q5 | **F** | `$0657/$0659` read/written in several files | FIXED (`joypadCurrent+1`, `joypadHeld+1`) |
| Q6 | M | OK | NOFIX |
| Q7 | M | E1+E2; open: does the `$6000` consume (no `$0008`) let item use re-trigger on closing the inventory, and is the map screen a Start toggle at runtime | DEFERRED-EVIDENCE (OQ-37, OQ-39 UNVERIFIED-RUNTIME) |

### File 3: system/engine/cop_handlers_oam_attribs.asm (166 lines lt, Bank 00)

Evidence: E1, E2 (`sc01_seagull`, `ir25_ceiling_tile`, `ec_proximity_door_toggle`, `ApplyPlayerHitstun`, `sprite_composition` sort), E3 (`copdef.json`, `docs/cop/families/oam_attribs.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | **F** | No block note at all; part notes for B2-B5 were one-liners | FIXED (block note: depth priority, `$0E` XOR mask, NudgePosition; part notes enriched) |
| Q2 | M | Redundant comments such as "ToggleHMirror: EOR $4000 on $0E" | FIXED (removed) |
| Q3 | **F** | The priority commands set the depth-sort priority (which sprites draw in front), not "collision priority" as in the docs | FIXED / docs PROPOSED (row 58) |
| Q4 | M | Operands correct | NOFIX |
| Q5 | NA | Operands already named | NOFIX |
| Q6 | M | `SetOamPriority`/`SetOamPalette` vs copdef `SetSpritePriority`/`SetSpritePalette` | PROPOSED (row 57) |
| Q7 | M | E1+E2+E3 | NOFIX |

## I012 — camera_tilemap | event_block_table | cop_handlers_scene_flags

### File 1: system/engine/camera_tilemap.asm (933 lines lt, Bank 02)

Evidence: E1 (every staging-buffer offset, VMAIN mode and DMA size traced), E2 (`system_init` pointer init `$06B2-$06B8 = $3100/$3288/$3184/$330C`, `system_core` NMI call sites, `scene_lifecycle` BG3SC and `CameraFullRefresh` callers), E3 (`docs/code/bank02/camera-scrolling.md`, `docs/code/bank00/nmi-handler.md`), E4 (VMAIN increment modes, BG3SC tilemap base).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Size reasonable | FIXED (header gets a naming paragraph) |
| Q2 | M | Several comments restated code | FIXED |
| Q3 | **F** | (a) `SpriteVramDma` is not sprite graphics: it uploads the BG3 tilemap `$7F0200` to VRAM `$7800` (BG3SC = `$78`), full (`$0800`, bit 0) or partial (`$0140` from row 2, bits 4/5); "character form changes"/"animation frames" were wrong; bits 4 and 5 are functionally identical (the TRB clears all three anyway); (b) `CameraFullRefresh` iterates 32 metatile **columns** (32×16 px = the 512 px double-nametable width), not rows; (c) `RenderScrollRow`/`DmaHorizontalStrip`/`$06B2,$06B4` handle COLUMN strips, `RenderScrollColumn`/`DmaVerticalStrip`/`$06B6,$06B8` handle ROW strips — the notes mixed both vocabularies; (d) `DmaHorizontalStrip` halves are the left/right tile column (VRAM addr, addr+1), not two nametables; `DmaVerticalStrip` halves are the two nametables (128 bytes = two tile rows each); (e) `RenderScrollColumn` always makes two page passes (not "when crossing the nametable boundary"); (f) the camera wrap is `AND bounds-1` (exact only for power-of-two bounds), not a clamp; negative Y is left unchanged; (g) layer-1 "priority" mode copies `cameraDeltaX/Y` into `effectScrollH/V` (old text named non-existent registers); the flag is `$06EF` bit 2 (bit `$0400` of the `$06EE` word), direct mode is `$06EF` bit 3; (h) `$0693` is the map width in pages (high byte of `mapBoundsX`), `$069F` the base page (high byte of `mapTilemapBaseA`), `$069A` the wrap modulus (map data size), not a "row stride"; (i) `+$44` in `FillVertTilemapSeg` is the right tile column's data area (its VRAM address word is at `+$42`) | FIXED (header, 12 part notes, ~60 inline comments) |
| Q4 | **F** | Raw operands `$06B2-$06B8`, `$06BA`, `$06BC` and the BG3 buffer | FIXED (6 mnemonics) |
| Q5 | **F** | `$06B2-$06BC` are the strip staging pointers and the BG1/BG2 tilemap VRAM bases (`$1000/$1800`, matching BG1SC/BG2SC defaults `$10/$18`); `system_init` wram-init lines now read by name. After `PLB` sets DBR=`$7E` the engine keeps raw operands for the `,X` forms (e.g. `$06B2, X` in `RenderScrollRow`) — expected, not a defect | FIXED (6 mnemonics) |
| Q6 | **F** | `SpriteVramDma` (BG3 tilemap upload); `RenderScrollRow`/`RenderScrollColumn`, `DmaHorizontalStrip`/`DmaVerticalStrip` named after the scroll axis, not the strip shape, while `Update*`/`Fill*` use the geometric meaning | PROPOSED (rows 55-56) |
| Q7 | M | E1+E2+E3+E4; the edge-tile step (last slot overwritten with the row above the strip start) and `$069A` as the wrap modulus are inferred from the arithmetic; the odd `AND #$0100` wrap in the `CameraFullRefresh` loop is left uncommented | DEFERRED-EVIDENCE (OQ-41, OQ-42); docs errors in rows 58, 60 |

### File 2: system/event_block_table.asm (169 lines lt, Bank 01)

Evidence: E1 (`LookupEventBlock` byte-by-byte field map, `SpawnFieldRevealEffect` use), E2 (callers: COP #32/#34 in `cop_handlers_bg_rearrange`, enemy scene-record event byte in `actor_execution`, `deathActionIdx`), data statistics from the table itself (158 entries, 70 distinct scenes, 3 layer-1 entries).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Header and note proportionate | NOFIX |
| Q2 | M | Note adds value | FIXED (added: units are 16×16 metatiles, entry `$07` is an all-zero 1×1 placeholder, only `$06/$14/$20` are layer 1, who supplies the index) |
| Q3 | M | The field order in the note (scene, src X/Y, width, height, dest X/Y, layer) is correct per `LookupEventBlock`. The consumer `SpawnFieldRevealEffect` comments are inverted ("target X tile" for byte 3, "X size" for byte 5): byte 3 = width, byte 5 = destination X, the pixel target is the rectangle centre `(2·destX + width)·8` | NOFIX here / PROPOSED (row 61, fix in the `SpawnFieldRevealEffect` iteration) |
| Q4 | M | Data only | NOFIX |
| Q5 | NA | `event-block-def` entries are immediates | NOFIX |
| Q6 | M | `event_block_table` accurate | NOFIX |
| Q7 | M | E1+E2 + table statistics; the meaning of source rectangles at Y `$40+` (hidden template area in the map) is inferred | NOFIX |

### File 3: system/engine/cop_handlers_scene_flags.asm (169 lines lt, Bank 00)

Evidence: E1 (sense-byte logic and shared tails traced), E2 (`scene_script` flag tables), E3 (`copdef.json`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | **F** | No block note | FIXED (block note) |
| Q2 | **F** | Tautological inline comments on the sense-byte logic, shared tails and rewind | FIXED (rewritten/removed) |
| Q3 | M | Mostly accurate once rewritten | FIXED |
| Q4 | M | Names match copdef | NOFIX |
| Q5 | NA | Operands already named | NOFIX |
| Q6 | M | OK | NOFIX |
| Q7 | M | E1+E2+E3 | NOFIX |

### Shared gate (I011 + I012)

Ingest dry-run on 6 files by explicit path: 2 new / 3 updated block notes, 27 part notes updated, 9 new / 131 updated / 9 deleted comments (the 9 deletions are comments intentionally removed as redundant); applied, re-dry-run "No changes detected"; `npm run extract:lt` was run. Its `rm -rf extracted/*` step failed on `extracted/system/engine` ("Device or resource busy"), which aborted the chained `node` step after the rest of `extracted/` had been deleted; the extractor was then re-run directly (`node --env-file=.env.local src/index.ts extract --linetracking`) and regenerated all 909 `.asm` files (0 deleted in `git status`). `npm run rebuild` OK; CRC 2083230829 / checksum 223006080 / totalSize 3062204 unchanged (diff against the backup copy empty). New `mnemonics.json` keys (sorted, nothing existing changed): I011 `oamStaging`, `+1`, `+2` (1058-1060), `joypadCurrent+1` (1623), `joypadHeld+1` (1625), `playerTileSrcBase` (1788), `playerTileDmaBank`, `+1`, `+11` (1790, 1791, 1807), `playerSpriteCachePtr` (2508), `playerSpriteCacheBank` (2510), `actorRenderList`, `+2` (3072, 3074); I012 `colStripStagingPtr`, `+2` (1714, 1716), `rowStripStagingPtr`, `+2` (1718, 1720), `bgTilemapVramBase`, `+2` (1722, 1724). The I012 names now appear in `system_init` wram-init lines and the DBR=0 routines of `camera_tilemap`; `,X` operands after `PLB` stay raw. Immediates `#$09CC/#$09CE` in `*.sprite.asm` are intentionally untouched. Not ingested: `MenuSelectionHandler.asm` (transforms artifact, see rename-proposals row 62).

---

## I013 — smooth_follow | music_actors | cop_handlers_force_move

### File 1: system/engine/smooth_follow.asm (1053 lines lt after edits, Bank 00)

Evidence: E1 (full trace of the aim → octant → slope row → facing → step flow, every handler's signs and facing base, the dither table's row sums), E2 (`actor_pool` `AllocateActorAfter`/`MarkChildActor`, `cop_handlers_spawn` `SpawnAfterMarked`, `hardware_math` `UnsignedDivide`, `sprite_composition` `UpdateActorAnimation`, callers `mu5F_flasher`, `aw_spirit_follower`, `smooth_follow_child`), E3 (`docs/cop/families/actor_spawn.md`, `db-us/copdef.json`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | **F** | Header was a few lines and the 16 near-identical `FollowDirHandler` blocks and the eight octant handlers had no part notes at all | FIXED (multi-paragraph block note; 36 part notes) |
| Q2 | **F** | Many inline comments restated code or described the wrong thing; 5 redundant ones removed | FIXED |
| Q3 | **F** | (a) The handler names claim a heading that does not match the geometry: `FollowChaseMoveWest` is "target down-right, X dominant" and heads mostly EAST, `...East` heads SOUTH, `...North` SOUTH, `...South` WEST, `...DiagNE` WEST, `...DiagSE` NORTH, `...DiagSW` NORTH, `...DiagNW` EAST; `FollowChaseYDiffNegative` tests dx, `...XDiffNegative*` test dy. (b) `SmoothFollowLookup` is a 17×16 Bresenham dither table (row r has 16−r ones), not a "sine table". (c) `CopySiblingFollowState` copies (not swaps) speed/animation base from the spawner and leaves `animScratch2` alone; `InitFollowAndChase` additionally sets `animScratch2 = $FFFF`. (d) `ComputeFollowAngle` is the Y-dominant slope row, `...Alt` the X-dominant one; `ComputeFollowStep` sums a `loopCounter`-long window of the row starting at `orbitDiameter` and wraps at 16. (e) `ResolveFollowDirection`/`Alt` fold the row to a facing offset and turn one frame per aim (short way round, half-turn counter-clockwise), then restart the spawner's animation unless `chatPtr` bit 15 is set. (f) Each `FollowDirHandler` sets the OAM mirror bits (`$4000` H, `$8000` V) on the spawner. (g) `ApplyFollowMovement` moves both the helper and the spawner and re-aims when the dither phase ≥ 8 | FIXED (comments and notes); names PROPOSED (rows 64-66) |
| Q4 | M | Operands already use shared mnemonics, repurposed here (`orbitAngle` = slope row, `orbitDiameter` = dither phase, `chatPtr` = animation base, `loopCounter` = speed, `animScratch2` = facing) | NOFIX (aliases would collide with their other meanings; documented in the note) |
| Q5 | NA | No repeated raw operands | NOFIX |
| Q6 | **F** | See Q3(a)/(b): handler, quadrant, `Resolve*` sub-label and table names mislead | PROPOSED (rows 64-66) |
| Q7 | M | E1+E2+E3; the 8-pixel aim offset (sprite centre) and the purpose of `chatPtr` bit 15 are inferred | DEFERRED-EVIDENCE (OQ-43, OQ-44) |

### File 2: system/engine/music_actors.asm (172 lines lt, Bank 02)

Evidence: E1 (every spawn, flag and poll traced), E2 (`cop_handlers_audio` `MusicAndText`, 22 call sites all with track `#17`, `hdma_dma_spc` `SpcTransferMusicData`/`DmaAdhocVramBlock`, `actor_execution` display-filter modes, `vblank_joypad` mask use, `warps_interaction` chest actor), E3 (`docs/wram-memory-map.md`, `docs/cop/families/audio.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Header long but structured | FIXED (rewritten, see Q3) |
| Q2 | M | Several comments restated code | FIXED |
| Q3 | **F** | (a) The actor is not "spawned by the scene transition system": it is the thinker created by COP `MusicAndText` (`$26` = track ID, `$20/$22` = dialogue string pointer/bank). It plays a jingle (every observed call uses track `#17`), shows the string through `MusicRenderSync`, then reloads the scene music (second `SpcTransferMusicData` with `chatPtr` = the saved `musicParentActor`). (b) The joypad mask is `$FFFC` (the header and comments said `$FFF0`/"all D-pad + shoulder"). (c) `$20/$22` is the string pointer/bank, not a "render context". (d) `$1000` in `$12` is the display-filter flag: callers set `displayModeFlags` bit 7 first, so only `$1000` actors run while the jingle plays. (e) `MusicLoadCleanup` is reached by falling through after the last `WaitByte`. (f) `musicParentActor` holds the scene's current music index, not a parent actor | FIXED |
| Q4 | M | `joypadMaskStd`, `musicTransitionState`, `displayModeFlags`, `APUIO1` correct; `musicParentActor` ($06F2) is a misnomer: it is the current music index | PROPOSED (row 67) |
| Q5 | NA | All operands named | NOFIX |
| Q6 | **F** | `MusicPlaybackActor` plays a jingle then restores the scene track; the `loc_02A*` sub-labels are unnamed | PROPOSED (row 67) |
| Q7 | M | E1+E2+E3; whether `MusicRenderSync`'s 72-frame wait is meant to let the jingle play, and whether the dialogue renderer blocks, is inferred | DEFERRED-EVIDENCE (OQ-48) |

### File 3: system/engine/cop_handlers_force_move.asm (171 lines lt, Bank 00)

Evidence: E1 (handler bodies), E2 (`tile_collision_physics` `ApplyMovement` and the collision move: `$2C/$2E` are delta-chain pointers consumed one node per frame, `$12` `$4000`/`$2000` negate X/Y; `movement_delta_table` node format; `actor_pool` `AnimFrameLookup`; `cop_handlers_audio`/`cop_handlers_spawn` `$0058`), E3 (`db-us/copdef.json`, `docs/cop/families/force_move.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | **F** | No block note | FIXED (block note) |
| Q2 | M | Per-handler comments adequate | FIXED (reworded) |
| Q3 | **F** | (a) `AnimFrameLookup` returns a pointer to a delta chain in `movement_delta_table`, not a "frame duration"; `$2C`/`$2E` are the X/Y delta-chain pointers (`ApplyMovement` reads `[ptr]` as the delta and `[ptr+2]` as the next link). (b) `ForceDirSW/NE/Both` set `$12` bits `$4000`/`$2000`/`$6000`, which negate the X delta, the Y delta, or both; they do not force a facing. (c) `ReloadMoveDurations` rewinds the chains to their first node | FIXED (comments and notes); names PROPOSED (rows 68-69) |
| Q4 | M | `moveXAlt/moveYAlt` accurate here (movement index) but dual-use elsewhere (target pixel position in `InitGravity`, `SpawnFieldRevealEffect`) | PROPOSED (row 68) |
| Q5 | NA | Operands already named | NOFIX |
| Q6 | **F** | `ForceDirSW/NE`, `ReloadMoveDurations`: effect does not match the names | PROPOSED (row 68) |
| Q7 | M | E1+E2+E3 | NOFIX |

### Shared gate (I013 only, run together with I014)

See the I014 gate below (both iterations were gated together).

---

## I014 — cop_handlers_effects | cop_handlers_vram | cop_handlers_actor_death

### File 1: system/engine/cop_handlers_effects.asm (788 lines lt, Bank 00)

Evidence: E1 (table construction in `InitSineHdma` traced entry by entry; gravity curve; camera pan state), E2 (`SetupHdmaChannel_Indirect`, `CameraScrollStepLookup`, `ApplyMovement`, `ApplyOrbitalOffsetFromRef`, `mu67_vampires` spiral use, 8 sine-effect actors, `GenHdmaSine`, `SetActorBody` for `$7F0008`), E3 (`db-us/copdef.json`, `transforms.json`), E4 (indirect HDMA repeat mode: a line-count byte with bit 7 reads one data word per scanline).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Header adequate but missing the shared model | FIXED (block note rewritten per effect family) |
| Q2 | M | Several comments restated code | FIXED |
| Q3 | **F** | (a) The `InitSineHdma` byte operand is the wave period n (scanlines per HDMA entry and sine samples per cycle), not a scanline count: the tables hold 256/n entries with line count `n \| $80` that all point at the same n data words (`#40` is the "slow" wave). (b) `BindSineHdma` operands are a long Address plus a channel-config byte (`A` = bank \| index << 8), not two words. (c) `TickGravity`: the Y delta is `((t × t/2) >> f) − v0` (v0 never updated); the "invert for upward bounce" / "delta negative → actor above target" comments were wrong (a negative delta means still rising); `moveYAlt` is the target pixel Y here. (d) `InitGravity` does not sign-extend a negative tile offset (it yields `$16 − byte × 16`; no caller uses it). (e) Camera pan: the scroll table word is delay (low byte) + step (high byte); the "speed index in `$2B`" wording was wrong. (f) `SpiralStep` needs the reference actor in `$0000`. (g) `BuildSineLookupTable` fills two 256-word arrays (header said "512-entry"). (h) The `LDA $0C / STA $02 / LDA $0A / STA $00` lines in `InitSineHdma`/others come from `transforms.json`, not the ROM | FIXED |
| Q4 | M | `$7F0008,X` stays raw: it is the spriteset bank field (`SetActorBody`), reused as the sine amplitude by the non-sprite sine actors; a mnemonic would mislabel `wa78_moving_pad`/`pyD0`/`pyD4` uses. `scratch1010+2/+4` are shared with `sg55_viper`/diary menu | NOFIX (row 70) |
| Q5 | M | See Q4 | PROPOSED (row 70) |
| Q6 | M | Names fit except the `loc_00A*` sub-labels | NOFIX |
| Q7 | M | E1+E2+E3+E4; no caller uses a negative gravity offset or `TickSineHdma` operand bit 7, `CameraPanUp/Left` edge case when the step exceeds the target is inferred | DEFERRED-EVIDENCE (OQ-46, OQ-47) |

### File 2: system/engine/cop_handlers_vram.asm (177 lines lt, Bank 00)

Evidence: E1, E2 (`DmaAdhocVramBlock` zeroes `$7F0C07`; `system_init` wram-init writes `$8B 54` / `$AB 60` at `$0402/$0406` = PHB, MVN, PLB, RTS; `QuintetLzDecompress` header; `radar_map_screen`, `attack_ability_system` adhoc callers; `SetActorBody`), E3 (`db-us/copdef.json`: `Decompress` takes two long Addresses; `CopyPalette` source Address), docs `AGENTS.md` adhoc DMA map.

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | **F** | No block note | FIXED |
| Q2 | M | Some restated code | FIXED |
| Q3 | **F** | (a) `AdhocVramDma` polls by comparing the COP's destination operand with `$7F0C07` (the NMI zeroes it), not "against the staged size". (b) `CopyPalette` sets the MVN destination bank `$7F` (`$0404`), not the source bank; destination is `cgramPalette` + 2 × index. (c) `Decompress` writes to a WRAM buffer in bank `$7E` (`$7A`), not VRAM; its destination operand is a long Address whose bank byte is read and discarded; the stream's 2-byte header is the decompressed size, not a "compressed length". (d) `$0402` is a RAM MVN stub | FIXED |
| Q4 | **F** | `$7F0C05/07/09` were raw although `$7F0C03` was named | FIXED (3 mnemonics) |
| Q5 | **F** | `adhocVramDmaBank/Dest/Size` added (blast radius: `cop_handlers_vram`, `hdma_dma_spc`, `radar_map_screen`, `attack_ability_system`, all the same meaning); `$0404/$0405/$0402` are RAM-stub operands, left raw | FIXED |
| Q6 | M | Names fit | NOFIX |
| Q7 | M | E1+E2+E3; the dest-before-size write order (NMI could fire between the two stores) is unverified at runtime | DEFERRED-EVIDENCE (OQ-45) |

### File 3: system/engine/cop_handlers_actor_death.asm (186 lines lt, Bank 00)

Evidence: E1 (cascade walk and the three list-patch cases), E2 (`actor_pool` `UnlinkActor`/`ReturnActorSlot`/`MarkChildActor`, `cop_handlers_spawn` sets `$12` bit `$0040`), E3 (`copdef.json` ids).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | **F** | No block note | FIXED |
| Q2 | M | Comments adequate | FIXED (additions) |
| Q3 | M | Mostly accurate; the cascade note now says the span between the boundaries includes the dying actor itself and that the dying actor's `$06` is repointed past the span so the run loop continues; `KillPrev/KillNext` have no null check | FIXED |
| Q4 | M | `parentId`, `actorListFirst/Last` accurate | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | `DieNow_UnlinkChildren` names the normal exit, not the cascade (`loc_00A60E`) | PROPOSED (row 72) |
| Q7 | M | E1+E2+E3 | NOFIX |

### Shared gate (I013 + I014)

Ingest dry-run on 6 files by explicit path: 3 new / 3 updated block notes, 31 new / 32 updated part notes, 42 new / 160 updated / 5 deleted comments (the 5 deletions are intentionally cleared redundant `smooth_follow` comments); applied by explicit path, re-dry-run "No changes detected". `db-us/mnemonics.json`: 3 entries appended (`adhocVramDmaBank/Dest/Size`). `npm run extract:lt` (909 files) then `npm run rebuild`: success, `artifacts/crc.json` unchanged (checksum 223006080, crc 2083230829, totalSize 3062204). `smooth_follow.asm` line endings normalized to CRLF after a mixed-EOL splice.

---

## I015 — system_core | cop_handlers_dialog | save_system

All edits applied with `npm run annotate` (spec `plans/extracted-audit/edits/I015-I016.json`, shared with I016; a small correction to `hdma_dma_spc.asm` is included).

### File 1: system/engine/system_core.asm (776 lines lt, Bank 00)

Evidence: E1 (NMI/HUD/boot traced instruction by instruction), E2 (`camera_tilemap` `SpriteVramDma`/`CameraSmoothScroll`, `hdma_dma_spc` `DmaPlayerTilesToVram`/`LoadMusicFromTransitionState`, `scene_lifecycle`, `thinker_execution`, `math_lookup_tables`, `pyCD_puzzle`/`item_use_system` for `$0B28`), E3 (`docs/wram-memory-map.md`, `docs/code/bank00/system-core.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Header present but several parts mislabelled; no note on the `UpdateFrame*` variants' differences | FIXED (block note and 8 part notes rewritten) |
| Q2 | M | Duplicate comments ("Scene $FB", "Clear ability bitmask") | FIXED (2 removed) |
| Q3 | **F** | (a) The warmboot check never selects a scene: both outcomes leave Y = 0. (b) `UpdateFrameFull` runs from the NMI while the main loop is blocked in `LoadMusicFromTransitionState` (SPC upload), not during a "music fade"; `musicTransitionState`: 0 idle, > 0 upload in progress, `$FFFF` done. (c) NMI `BIT #$08` is "player-tile DMA pending", not "dialogue mode"; `UpdateFrameDialogue` clears it so the NMI takes the normal path. (d) `dmaSkipFlag` skips adhoc DMA and `ExecuteVramDma` only. (e) The SFX byte goes out on even frames, 0 on odd frames (comment said "odd frames only"). (f) `$0B28-$0B32` are hieroglyph plate slots, not ability slots. (g) The deceleration curve offset `+20` is `+$20` (comment said `+$14`). (h) HUD: `displayModeFlags` bit 0 is the full BG3 upload request (not "status bar visibility"); `playerStateByte` bit 1 is game over; bit 4 requests the partial BG3 upload; the enemy bar is a single 60-frame hold (the 25 and 30 stores are overwritten at once); gem digit is a repeated subtraction. (i) `CameraSmoothScroll` X = 0/2 selects the layer (BG1/BG2), each call handling both axes. (j) `LoadMusicFromTransitionState` is called from the main loop, not the NMI (also fixed in `hdma_dma_spc.asm`). (k) `UpdateFrameRender` runs thinkers and `UpdateHUD`, not "palette/display processing" | FIXED |
| Q4 | **F** | `$0B28` raw, used in three files | FIXED (`hieroglyphSlots`) |
| Q5 | **F** | `hieroglyphSlots` appended (`pyCD_puzzle`, `item_use_system`, `system_core`; all the same meaning). `$09BE/$09C0/$09C4` unreferenced (OQ-52) | FIXED |
| Q6 | M | `FillWramBlock`/`WramFillConstant` unreferenced (no caller), `loc_0080B5` is the main loop, `playerStateByte` is the high byte of `playerFlags` | PROPOSED (rows 73-75) |
| Q7 | M | E1+E2; the warmboot signature, `$2000` reader, dead timer stores and `$09BE/C0/C4` need runtime or wider greps | DEFERRED-EVIDENCE (OQ-50 to OQ-53) |

### File 2: system/engine/cop_handlers_dialog.asm (194 lines lt, Bank 00)

Evidence: E1, E2 (`vblank_joypad` joypad mask semantics, `actor_execution` `RunActors_CutsceneOnly`, `MenuSelectionHandler` parameters, `scene_lifecycle`), E3 (`db-us/copdef.json`; usage tally of `DialogueOptions`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | **F** | No block note | FIXED |
| Q2 | M | Many comments restated code | FIXED |
| Q3 | **F** | (a) Actor `$10` bit 11 (`$0800`) is cutscene-active, not "status bar". (b) `joypadMaskInv = $0F00` is the D-pad auto-repeat set, not "inventory input". (c) `joypadMaskStd` is the suppressed-button set: clearing it lets the renderer see all buttons (comments said input was blocked). (d) `TRB $joypadCurrent` re-applies the restored mask, it does not clear the D-pad (the D-pad clear is the `$0F00` TRB on `joypadHeld`). (e) `RunBg3Script` sets bit 0 = full BG3 upload request, not "console active". (f) `$2000` has no reader (OQ-51). (g) `DialogueOptions`' first word is two byte operands (menu parameters), not a pointer | FIXED |
| Q4 | M | `joypadMaskStd/Inv`, `joypadHeld` names fit | NOFIX |
| Q5 | NA | No new mnemonic | NOFIX |
| Q6 | M | Names fit | NOFIX |
| Q7 | M | E1+E2+E3; the reason for clearing `$10` bit 11 is inferred | DEFERRED-EVIDENCE (OQ-54) |

### File 3: system/engine/save_system.asm (200 lines lt, Bank 03)

Evidence: E1 (checksum algebra, slot layout), E2 (`system_core` uses of `$0A00-$0BFB` stats and `hieroglyphSlots`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Good header | FIXED (additions) |
| Q2 | M | Comments adequate | NOFIX |
| Q3 | **F** | (a) Both checksums are order-independent, so they cannot detect transposed words ("value-preserving transpositions (sum)" was wrong). (b) The saved range is `$0A00-$0BFB` (not `$0BFC`) and includes player stats/inventory state and the plate slots, not just event flags | FIXED |
| Q4 | M | `eventFlags` ($0A00) understates the range (it is the start of a mixed state page) | NOFIX (deferred to the end-of-campaign consolidation, see note below) |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | Names fit | NOFIX |
| Q7 | M | E1; SRAM layout is certain | NOFIX |

Note: `eventFlags` is used well beyond this file; renaming it is deferred to the end-of-campaign consolidation (not added as its own row to avoid a premature name).

### Shared gate (I015 + I016)

See the I016 gate below.

---

## I016 — cop_handlers_movement | camera_scroll | DisplaySceneTitle

### File 1: system/engine/cop_handlers_movement.asm (761 lines lt, Bank 00)

Evidence: E1 (interpolation algebra traced, carry flow in `StageMove`, RNG chain), E2 (`tile_collision_physics` `ApplyMovement`/override chains, `actor_pool` slot size, `hardware_math`, usage tallies over 555 movement COP calls: `MoveToward` 108, `StageMove` 32, `RngMod` operands `$50/$60`, `BranchIfActorNear` 0, `BranchIfPlayerNear` radius 1-`$0F`), E3 (`db-us/copdef.json`, `docs/cop/families/movement.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Good header, errors inside | FIXED (block note and 9 part notes) |
| Q2 | M | Comments restated code | FIXED |
| Q3 | **F** | (a) `MoveToward` operand 2 is speed in px/frame, not a frame count (frames = distance ÷ speed, +1 as tick limit). (b) `MultiplyThenDivide`/`MovementVelocityCompute` return the cumulative offset for the tick, not a per-frame velocity. (c) Proximity is a square box (abs(ΔX) and abs(ΔY) both ≤ radius × 16), not Manhattan; `BranchIfActorNear` has no users. (d) `$0005` stored to `$7F000F` is the direction-sign flags, not an animation delay. (e) `$2C/$2E` are the override-chain pointers, not movement deltas. (f) `StageMove` speed ≥ `$80` also adds a halving pass (carry from `CMP #$80`, comment said "carry from divide"); third operand is a duration cap (`$FF` = none). (g) `RngByte` is an additive generator over `$0410-$041F` plus a ripple counter, not a Galois LFSR. (h) TickMove Y-negative moves up, not south. (i) Distance < speed yields zero movement; distances are capped at `$FE`. (j) `RngMod` with modulus 0 would hang | FIXED |
| Q4 | M | `moveXAlt/moveYAlt` dual-use (target pixel), `chatPtr` is the halving counter here, `rngState` base is off by one | PROPOSED (rows 79-80) |
| Q5 | NA | No new mnemonic | NOFIX |
| Q6 | M | copdef operand name `frames` for `MoveToward` is wrong | PROPOSED (row 78) |
| Q7 | M | E1+E2+E3; the speed ≥ `$80` behaviour and short-distance no-op are traced but not observed | DEFERRED-EVIDENCE (OQ-55, OQ-56) |

### File 2: system/engine/camera_scroll.asm (205 lines lt, Bank 00)

Evidence: E1 (`TileAlignCoord` 8-bit LSR semantics, `MulDivide` contract), E2 (`scene_actors` spawn tally, `actor_execution` spawn conversion, `camera_tilemap`/`visual_effect_pipeline` consumers), E3 (`docs/code/bank00/camera-scroll-system.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Header present but missing the spawn-parameter model | FIXED (block note and 7 part notes) |
| Q2 | M | Comments restated code or were wrong | FIXED |
| Q3 | **F** | (a) The 8-bit `LSR` ×4 shifts only the low byte; the result is page × 256 + tile, not "two independent 4-bit indices of the high and low bytes". (b) `$14/$16` are not speed parameters: after packing they are the `MulDivide` operand (multiplier low byte, divisor high byte) derived from the spawn X/Y bytes. (c) `savedCameraDelta` is `effectScrollV` (`$0690`). (d) The "3-iteration ramp-up" has identical inputs each pass. (e) `forcedScrollOverride` has no engine reader found outside `visual_effect_pipeline` (comment claimed it is applied directly) | FIXED |
| Q4 | M | Names fit | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | Names fit | PROPOSED (row 81, docs only) |
| Q7 | M | E1+E2; actual in-game effect of the X multiplier = low nibble − 1 is unverified | DEFERRED-EVIDENCE (OQ-57) |

### File 3: system/engine/DisplaySceneTitle.asm (208 lines lt, Bank 02)

Evidence: E1, E2 (`scene_lifecycle` `ExecuteSceneTransition` `$0D6E/$00B4` handling and call order, `DialogStringRenderer` `$0998`), E3 (`DialogStringRenderer` header: default box 13 columns).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Good header | FIXED |
| Q2 | M | Some restated code | FIXED |
| Q3 | **F** | (a) The guard compares the scene just left with the new scene: it suppresses the title only for a same-ID reload, not for "returning from a sub-area". (b) The call is before thinker spawning and palette loading (header said palette only). (c) `$00B4` is a nonzero wait flag; `$00B5` "secondary display control" was unsupported. (d) The `18` centering constant and "10-column" wording are inferred (no clamp for N > 18). (e) The first title byte skipped by `INC $3E` is assumed to be a type/length byte | FIXED (inferred items marked) |
| Q4 | M | Names fit | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | Names fit | NOFIX |
| Q7 | M | E1+E2; box width unit and `$00B4` sharing with `sg4C_auto_advance` unverified | DEFERRED-EVIDENCE (OQ-58) |

### Shared gate (I015 + I016)

`npm run annotate` dry-run then apply: 7 files (the six audited plus `hdma_dma_spc.asm`): 7 block notes, 65 part notes, 53 comments; second apply after a `DialogueOptions` wording fix; ingest re-check "No changes detected". `db-us/mnemonics.json`: `hieroglyphSlots` (`$0B28`) added in sorted position. `npm run extract:lt` (substitutions verified in `pyCD_puzzle`, `item_use_system`, `system_core`) then `npm run rebuild`: success, `artifacts/crc.json` unchanged (checksum 223006080, crc 2083230829, totalSize 3062204).

---

## I017 — event_blocks | cop_handlers_actor_query | hardware_math

All edits applied with `npm run annotate` (spec `plans/extracted-audit/edits/I017-I018.json`, shared with I018).

### File 1: system/engine/event_blocks.asm (713 lines lt, Bank 02)

Evidence: E1 (every routine traced, including the queue layout and both AnimateEventBlock paths), E2 (callers: `actor_execution`, `cop_handlers_bg_rearrange` COP #32/#33, `warps_interaction` DrawChestTiles, `system_core` flush calls, `cop_handlers_metatile` `$0902` producer, `map_coords` PLP-preserving index helpers), E3 (`docs/code/bank02/game-systems.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Long header, but errors in it and no mention of the layer 0 / layer 1 difference | FIXED (block note and 6 part notes rewritten) |
| Q2 | M | Several comments contradicted the code | FIXED (14 comments) |
| Q3 | **F** | (a) `SwapEventBlockTiles` copies source over destination and leaves the source unchanged; it is not a swap. (b) `tileQueryResult` (`$0902`) is not an interactive probe result: it is the VRAM address of a pending 2×2 metatile update (written by `cop_handlers_metatile`), flushed in direct mode. (c) The layer 1 viewport test uses `effectScrollH`/`effectScrollV`; the header and two comments said `bg1ScrollV`/`savedCameraDelta`. (d) The queue neighbour addresses are +1, +`$20`, +`$21` (not +`$1F`). (e) The `BCS` and `BEQ` comments after `QueueVisibleTileVram` were swapped: carry = off-screen, Z = queue full. (f) `LDX #0` in the queue-full exit exists to force Z, not to reset X. (g) The "carry clear + NZ on success" claim is wrong: PLP restores the caller's flags, so Z on success is inherited (OQ-62). (h) The block note said `AnimateEventBlock` returns carry clear when interrupted, but that is true only for the layer 1 path: layer 0 flushes inside the routine and loops. (i) The comment "Animation complete ... CLC" at `loc_02A4F9` is the layer 1 queue-full return. (j) `AdvanceEventRow` reloads destination X as well as source X. (k) `SP = $07FF`: the first PLA reads `$0800` = `dmaSkipFlag`, the first queued address (the comment said "top of stack page") | FIXED |
| Q4 | M | `SwapEventBlockTiles` and `tileQueryResult` mislead; `QueueVisibleTileVram` fits | PROPOSED (rows 82, 83) |
| Q5 | NA | No new mnemonic (queue words are addressed relative to `dmaSkipFlag`) | NOFIX |
| Q6 | M | Other names fit | NOFIX |
| Q7 | M | E1 + E2; a full queue with a stale carry on entry (and the Z inheritance) are traced, not observed | DEFERRED-EVIDENCE (OQ-62) |

### File 2: system/engine/cop_handlers_actor_query.asm (214 lines lt, Bank 00)

Evidence: E1 (compare and branch directions traced per instruction), E2 (`copdef.json` ids and operand parts, usage tally, `actor_pool` link fields, example operands in `dark_space` and `overworld_exit`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | No block note; part notes present | FIXED (block note added, 5 part notes) |
| Q2 | M | Two redundant Y−8 comments, direction wording unclear | FIXED |
| Q3 | **F** | (a) Operand order of COP #44 and #45 is minX, minY, maxX, maxY, not minX, maxX, minY, maxY (the second byte is added to `$16`/compared with Y). Example operands `(#06,#1C,#08,#1E)` and `(#12,#3C,#16,#3E)` give plausible 2-4 tile boxes only in this order. (b) The compare directions make the lower bound exclusive and the upper bound inclusive. (c) The absolute variant tests (X, Y−8), the relative variant tests raw Y. (d) `CopyPosToPrev`/`CopyPosToNext` have no null check; `CopyPosToPrev`, `CopyPosToNext`, `BranchIfBodyNe` have no users | FIXED |
| Q4 | M | Names fit | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | Names fit; `copdef.json` operand parts are plain `Byte` (no operand names to correct) | NOFIX |
| Q7 | M | E1 + E2; the reason for the −8 on Y is inferred and not stated in a comment | NOFIX |

### File 3: system/engine/hardware_math.asm (226 lines lt, Bank 02)

Evidence: E1 (register-level trace of MulDivide, bit tracing of both software routines), E2 (`RngByte` in `cop_handlers_movement` for the identical step, no callers of the two `_Unused` routines, caller list for the others), E4 (SNES math registers: `$4202/$4203` multiply is unsigned 8×8, `$4204-$4206` divide is 16÷8 unsigned).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Header present; algorithm descriptions partly wrong | FIXED (block note and 5 part notes rewritten) |
| Q2 | M | Several comments mislabeled the operand or the byte | FIXED (15 comments) |
| Q3 | **F** | (a) `MulDivide` divides only the low 16 bits of A low × Y: the carry and the high byte of the second product are discarded (WRDIV is 16-bit). The notes said "24-bit" and "32-bit intermediate". (b) Its WRMPYB writes are the low and then the high byte of Y (the comments said "= Y"). (c) `SignedMultiply` is an unsigned multiply (the hardware has no signed multiply on `$4202`). (d) `UnsignedDivide` returns the quotient low byte in A low, remainder in A high; the quotient's high byte is dropped. (e) `SoftDivide_Unused` normalizes the divisor (A), not the dividend; the first loop produces the integer part ($06) and the second 16 fraction bits ($04) (inferred 16.16). (f) `IncrementCounter_Unused` adds each state byte into the one below (state[X-1] += state[X]), not "rngState[i] += $0410[i]"; it is the same step as `RngByte` | FIXED (inferred items marked) |
| Q4 | M | `SignedMultiply` misnamed; `IncrementCounter_Unused` hides its identity with `RngByte` | PROPOSED (rows 84, 85) |
| Q5 | NA | No new mnemonic | NOFIX |
| Q6 | M | Other names fit | NOFIX |
| Q7 | M | E1 + E2 + E4 | NOFIX |

### Shared gate (I017 + I018)

See the I018 gate below.

---

## I018 — cop_handlers_spawn | cop_handlers_audio | forced_walk

### File 1: system/engine/cop_handlers_spawn.asm (532 lines lt, Bank 00)

Evidence: E1 (operand consumption traced for all 14 handlers, including both pool-exhaustion skip paths: 7 and 8 bytes), E2 (`copdef.json` ids and operand parts, `actor_pool` AllocateActor*/CopyActorState/MarkChildActor, `cop_handlers_actor_death` `$0040` test in Die, usage tally).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Header present and mostly accurate; lacked the CopyActorState inheritance, what MarkChildActor does and the usage counts | FIXED (block note, 3 part notes) |
| Q2 | M | Handler comments are mostly sparse and correct | FIXED (4 comments) |
| Q3 | M | (a) The Marked comments said both "child flag" and "parent has marked children": `$0040` is set in the spawner's own `$12` (the parent), and Die's `BIT #$0040` on `$12` cascades to children. (b) The `AND #$00FF` after the bank byte was commented as sign-extension of the offset. (c) `$0028` is the animation index, not a "sprite frame". (d) The header said the Marked variants "set actor flag $0040" without saying whose. All operand sizes and the pool-exhaustion skip lengths match `copdef.json` | FIXED |
| Q4 | M | Names fit | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | Names fit | NOFIX |
| Q7 | M | E1 + E2. `SpawnAfterOffset`, `SpawnAfterAbs` and `SpawnListAppendSpr` have no users in extracted/ | NOFIX |

### File 2: system/engine/cop_handlers_audio.asm (239 lines lt, Bank 00)

Evidence: E1, E2 (`copdef.json`, `hdma_dma_spc` `SpcCheckMusicReady`, `music_actors` `MusicPlaybackActor`/`MusicLoadCleanup`, `actor_pool.CopyActorState`, sfx queue users), E3 (`docs/cop/families/audio.md`, `docs/audio/spc-engine.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Good header, with wrong flag description | FIXED (block note and 2 part notes) |
| Q2 | M | Most comments restate the code; a few were wrong | FIXED (6 comments) |
| Q3 | **F** | (a) `AND #$EFFF` clears `$1000` in `$10`; the notes and comment said "clears $0800". The ORA sets `$1000` in `$12` (keeps the thinker running in display-filter mode). (b) `SpcCheckMusicReady` has no fade: it sends `$F1`, waits for the echo, sends `$01` and falls into `SpcTransferMusicData`. "Fade" in the name and docs is unverified (OQ-61). (c) The sfx handlers write WRAM queue slots, not an I/O register. (d) On the pool-exhaustion path of `MusicAndText` the track is dropped and the `TRB #$0080` leaves display-filter mode (set by the calling script); "dialogue overlay complete" was imprecise | FIXED |
| Q4 | M | `FadeThenStartMusic` name rests on an unverified "fade"; no change proposed until OQ-61 is settled | DEFERRED-EVIDENCE (OQ-61) |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | Names fit | NOFIX |
| Q7 | M | E1 + E2; `$F1` on APUIO0 not found in the SPC docs (those list `$F1` only as a music bytecode) | DEFERRED-EVIDENCE (OQ-61) |

### File 3: system/engine/forced_walk.asm (249 lines lt, Bank 00)

Evidence: E1 (stream consumption traced: 1 + 4 + 1 = 6 bytes, matching the warp entry's `entry+7` stream), E2 (`warps_interaction` StartForcedWalk and warp entry layout, `cop_handlers_movement.CameraScrollStepLookup`, `cop_handlers_player_sprite.StagePlayerSprFromDP`, `tables/` movement_delta_table / direction_velocity_table / forced_walk_sequence_table contents, `actor_pool.CopyActorState`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Header present; stream layout and the table roles were missing | FIXED (block note, 8 part notes added or rewritten) |
| Q2 | M | Four copies of the same sequence carry comments only on the first | FIXED (13 comments) |
| Q3 | **F** | (a) `$2E`/`$2C` receive a pointer into `movement_delta_table` (delta-node velocity list), not a "frame duration". (b) The comment on `COP [StagePlayerSprFromDP]` described the later table indexing; the COP only stages the sprite from DP `$0000`. (c) `$0000` is staged by `StagePlayerSprFromDP`, not "StagePlayerSpriteFromBank". (d) `SyncPlayerToCamera` clears `$0200`, not `$0400`. (e) `forced_walk_sequence_table` entries are word scroll-step lists read by `CameraScrollStepLookup` (zero word ends the list); the table's own doc says "frame + step delta byte pairs" (carried to the tables audit). (f) "climb + grounded" for the `$2008` mask is unsupported (OQ-60) | FIXED (inferred items marked) |
| Q4 | M | Names fit; `warpFacing` stream-pointer use already logged (row 46) | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | Names fit | PROPOSED (row 87, docs only) |
| Q7 | M | E1 + E2; bit meanings of `$10` `$2008`/`$0008`/`$0200` unverified | DEFERRED-EVIDENCE (OQ-60) |

### Shared gate (I017 + I018)

`npm run annotate` dry-run then apply: 6 files, 6 block notes, 29 part notes (new or rewritten), 57 comments (plus 1 removal); ingest re-check "No changes detected". No mnemonic added. `npm run extract:lt` then `npm run rebuild`: success, `artifacts/crc.json` unchanged (checksum 223006080, crc 2083230829, totalSize 3062204). Whole-tree `ingest --dry-run`: only the pre-existing `MenuSelectionHandler` noise (OQ-59).

---

## I019 — radar_map_screen | cop_handlers_script_control | actor_pool

### File 1: system/engine/radar_map_screen.asm (519 lines lt, Bank 03)

Evidence: E1 (code trace; BGR555 decode of the border table; tilemap-word decode of the dot/frame tiles), E2 (`warps_interaction` chest record layout, `actor_execution` bit-8 setter, `dark_space.asm` as the only `$0200` setter, `GlobalInputHandler`, `boss_clear_reward_handler` reward types, `StandardEnemyDefeatHandler`), E3 (`GlobalInputHandler` header: Start toggles the map).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Header present but built on wrong premises; most routines had only the generic header | FIXED (block note rewritten, 7 part notes) |
| Q2 | M | A few comments restated code; several were wrong | FIXED (27 comments) |
| Q3 | **F** | (a) The marker table is `scene_barrier_chest_table` (record: X tile with bit 7 = end, Y of the chest's bottom row, contents, event flag with bit 7 = fanfare); the entries are treasure chests and a set flag means opened. The notes said "scene transition markers", "visited" and "table_01ADA8". (b) The routine counts every unopened chest of the scene, drawn or not (the BCD increment is also reached from the out-of-viewport branches). (c) `$0AEE` is `enemiesRemainingBcd`, not an actor count, and the legend icon `$2AE7` beside it is the bit-8 dot, so the bit-8 "friendly/blue" dots are the stat-bearing enemies still alive. The bit-9 "enemy/red" dots are set only by `dark_space.asm`, so they are probably Dark Space entrances (inferred, OQ-63). (d) Both dot tiles use palette 2 (`$2AE7` = tile `$2E7`, `$280D` = tile `$00D`); "palette 0 red" was wrong. (e) `cameraOffset/Bounds` are scene scroll limits, not the current view. (f) `RadarBorderTileTable` holds 29 BGR555 colors (blue, yellow, blue) written to `cgramPalette` color 18 (`$7F0A24`), not tilemap words. (g) The reward block draws a 4×4 frame (corner `$2EE1` with flips, edges `$2EE2`/`$2EE3`) around a 2×2 icon of sequential tiles `$32E8-$32EB`; the notes called it a chest icon plus counter tiles. The reward table value (1=HP, 2=STR, 3=DEF) is only tested for non-zero. (h) `displayModeFlags` bit 0 requests a full BG3 staging upload; "enable radar overlay" was imprecise. (i) `sceneTableIndex` is an index, not a pointer. (j) The adhoc DMA is armed (dest written) before the size word, the opposite of the documented safe order (OQ-64) | FIXED (unverified icon meanings and colors marked) |
| Q4 | M | `RadarBorderTileTable`, `RadarPlotFriendlyActor` and `RadarPlotEnemyActor` are misleading names | PROPOSED (rows 88-89) |
| Q5 | M | No new mnemonic: the `$7F0A24` color slot has a single user | NOFIX |
| Q6 | M | Other names fit | NOFIX |
| Q7 | M | E1 + E2; dot colors, the reward icon and tile `$32E5` are not runtime-verified | DEFERRED-EVIDENCE (OQ-63, OQ-64) |

### File 2: system/engine/cop_handlers_script_control.asm (276 lines lt, Bank 00)

Evidence: E1, E2 (`copdef.json` operand lists for #C0-#CB, #E1, #E2; use counts: `SetInteractHandler` 322, `SetOnInteract` 0), E3 (`docs/wram-memory-map.md` thinker range `$0F00-$0FFF`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | **F** | No block note | FIXED (block note added, 4 part notes) |
| Q2 | M | Comments fine except the loop ones | FIXED (11 comments) |
| Q3 | **F** | (a) The header says the COP script name is `SetOnInteract`; copdef calls it `SetInteractHandler` (the docs repeat the stale name). (b) `LoopStart`/`LoopEnd` say "X ≥ $1000 = player actor"; X ≥ $1000 is any pooled actor and X < $1000 a thinker, so the "Actor" arrays at `$7F2100/$7F2102` are the thinker variants. (c) `SetEntryFar` does not jump, it only sets the entry. (d) `SetEntryHere` stores `$0C` with a 16-bit STA, so `$03` receives a stray byte (OQ-69). (e) Calls do not nest: one `retPtr1` slot. (f) A loop count of 0 wraps to 65536 iterations | FIXED |
| Q4 | M | Mnemonics `loopStartPcActor`/`loopCounterActor` are misleading | PROPOSED (row 90) |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | Handler names match copdef | NOFIX |
| Q7 | M | E1 + E2; the thinker range rests on the wram map | DEFERRED-EVIDENCE (OQ-69 only) |

### File 3: system/engine/actor_pool.asm (296 lines lt, Bank 00)

Evidence: E1, E2 (`cop_handlers_actor_death` KillPrev/KillNext/Die/MarkDeath register setup, `cop_handlers_force_move` AnimFrameLookup callers, `InitActorPool` free list at `$0E00`, `GetPlayerFacingDirection` for the `$8000` sprite-override flag), E3 (`InitActorPool` note on scene `$FF`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Header good in outline; 8 of 11 routines had no part note | FIXED (block note rewritten, 10 part notes) |
| Q2 | M | Several comments misleading; `ActorPoolAllocator` uncommented | FIXED (9 comments) |
| Q3 | **F** | (a) `AnimFrameLookup` returns a movement delta chain head pointer, not a "frame duration"; its callers are the force-move handlers, not `StageSprX/Y/XY`. (b) `CopyActorState`: `ORA #$2000` forces the bit on (not "preserve"); `$12` clears `$1000`, the display-filter run flag (not "render-active"); `$0024` holds the spawner slot (not "parent link", which is `parentId`); scene `$FF` keeps `extendedFlags` and callbacks (inferred, `InitActorPool` note). (c) `ReturnActorSlot` ends with D = X: the freed actor was D on entry, so the "caller's actor base" comment only holds because Die/MarkDeath/KillPrev/KillNext set D = X first. The 8-bit `DEC $004E` is safe because the free list sits in page `$0E`. (d) `UnlinkActor` leaves `actorListLast` stale if it removes the only entry (OQ-66) | FIXED |
| Q4 | M | Names fit | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | Names fit | NOFIX |
| Q7 | M | E1 + E2; `$24` reader and the `$FF` exception are inferences | DEFERRED-EVIDENCE (OQ-65, OQ-66) |

### Shared gate (I019 + I020)

See the I020 section.

---

## I020 — cop_handlers_player_query | flag_helpers | cop_dispatch

### File 1: system/engine/cop_handlers_player_query.asm (518 lines lt, Bank 00)

Evidence: E1 (every handler traced; direction branches re-derived), E2 (`copdef.json` ids and operand lists, `GetPlayerFacingDirection` value order, `warps_interaction` save-warp layout, `game_over_sequence` revive reload).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | **F** | No block note; no part notes beyond the one-line headers | FIXED (block note, 6 part notes) |
| Q2 | M | Several comments wrong or duplicated | FIXED (15 comments, 1 removed) |
| Q3 | **F** | (a) `BranchOnPlayerFacing` comments claim 0=N, 1=E, 2=S, 3=W, but `GetPlayerFacingDirection` returns 0=down, 1=up, 2=left, 3=right (`warps_interaction` tests 1 as north); the operands are indexed by that order. `CardinalToPlayer` really returns 0=N, 1=E, 2=S, 3=W, a different order. (b) `QueueMapChange` with flags bit 7 does not save a resume PC: it stores the address of its own operand block (laid out like a warp record) in `sceneSaveData`/`reviveWarpPtr`, and `game_over_sequence` reloads from it. (c) `BranchOnPlayerX` comment on the positive-delta BCC said "east", but BCC means below threshold → centre. (d) `BranchNearerAxis` operand semantics clarified (operand[0] when horizontal separation dominates). (e) `BranchIfActorAt` shares code whose comments said "player". (f) `WaitWhileOffscreen` re-enters at the COP instruction itself | FIXED |
| Q4 | M | `code_009230` is an unnamed internal exit label | PROPOSED (row 91) |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | Handler names match copdef | NOFIX |
| Q7 | M | E1 + E2; the `$4000` off-screen flag meaning is from the docs only | NOFIX |

### File 2: system/engine/flag_helpers.asm (299 lines lt, Bank 00)

Evidence: E1 (address arithmetic: byte = $0A00 + index÷8), E2 (all callers of every helper; `warps_interaction`, `event_blocks`, `inventory_menu`, `game_over_sequence`, `WorldMapController`, `actor_execution` `CheckEnemyDefeatedFlag`), E3 (`docs/wram-memory-map.md` line 348).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | **F** | No block note; the flag regions and lifetimes were not documented anywhere | FIXED (block note with the region table, 10 part notes) |
| Q2 | M | Per-helper comments repeated wrong region names | FIXED (8 comments) |
| Q3 | **F** | (a) All helpers address one bit array at `$0A00`; the bases map to bytes `$0A20` (`_0100`), `$0A40` (`_0200`), `$0A60` (`_0300`), `$0A80` (wramFlags = flags `$0400+`) and `$0AA0` (`_Offset100`, flags `$0500-$0507`; `TestFlag_0510` = `$0AA2+`). (b) `TestWramFlag_Offset100`/`SetWramFlag_Offset100` land at `$0AA0`, outside the block `ClearAllWramFlags` clears, contrary to the "boss/dungeon `$0100` region" description (OQ-68). (c) `ClearAllWramFlags` is not "called on scene transitions": only `WorldMapController`, `st68_kara`, `sp58_red_eye` and an inline copy in `game_over_sequence` clear it, so the "scene-local flags" description in `docs/wram-memory-map.md` and the `actor_execution` note is doubtful (OQ-67). (d) `TestFlag_0300` is a per-scene "clear reward claimed" flag, `TestFlag_0510` the ability unlock flags, `_0100` event/trigger flags (the `$0A20` field that `ApplyAllEventBlocks` scans), not just boss/dungeon defeat. (e) `TestWramFlag` has no outside caller; `CheckEnemyDefeatedFlag` repeats the logic with a duplicate mask table. `ClearFlag_0100` has no caller. `SetEventFlag_0200` does not mask its index | FIXED |
| Q4 | M | `_Offset100` names hide the target region | PROPOSED (row 95) |
| Q5 | M | Possible helper for `BitMaskTable_Wram` duplication | PROPOSED (row 96) |
| Q6 | M | Other names fit | NOFIX |
| Q7 | M | E1 + E2; flag lifetimes rest on caller absence | DEFERRED-EVIDENCE (OQ-67, OQ-68) |

### File 3: system/engine/cop_dispatch.asm (306 lines lt, Bank 00)

Evidence: E1 (table parsed and compared by id against `copdef.json`: 209 entries, all ids equal; 19 names differ), E2 (handler include list: 30 blocks; stack frame math: pushed PC − 1 = signature byte).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Good header, with a stale target list | FIXED (block note, 3 part notes) |
| Q2 | M | Table entries are self-describing | FIXED (2 comments) |
| Q3 | **F** | (a) The header named 13 handler blocks (including non-existent `cop_handlers_flow/lifecycle/map/solid/spatial`) and a support block `cop_handlers_flags`; the table targets 30 blocks (all `cop_handlers_*` files) and the support blocks are `actor_pool` and `flag_helpers`. (b) 19 handler labels differ from the copdef script names (`BranchIfType*`, `StageSpr*`, `StagePlayerSpr*`, `SetOam*`), ids equal. (c) `cop_table_sentinel` is not a guard: `JMP (table,X)` would read its own bytes (`EA 80` = `$80EA`) as a pointer. (d) The COP signature byte is the opcode (pushed PC − 1) | FIXED |
| Q4 | M | Label/copdef name drift | PROPOSED (row 92) |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | Names fit | NOFIX |
| Q7 | M | E1 (programmatic table check) + E2 | NOFIX |

### Shared gate (I019 + I020)

`npm run annotate` dry-run then apply: 7 files (6 audited plus a one-comment fix in `GlobalInputHandler.asm`), 6 block notes (3 new, 3 rewritten), 40 part notes (9 new, 31 rewritten), 73 comments (10 new, 63 updated; 1 removal); second run "unchanged, Wrote 0 file(s)"; ingest re-check "No changes detected". No mnemonic added. `npm run extract:lt` then `npm run rebuild`: success, `artifacts/crc.json` unchanged (checksum 223006080, crc 2083230829, totalSize 3062204). Whole-tree `ingest --dry-run`: only the pre-existing `MenuSelectionHandler` noise (OQ-59).

---
