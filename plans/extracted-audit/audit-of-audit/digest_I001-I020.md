# Digest — results I001–I020 (`results/I001-I020_results.md`, read in full)

Read in full in A00-extended (2026-10-28). Evidence tags: VERIFIED = checked against live files this pass; REPORTED = taken from the ledger.

## Scope and shape
- 20 iterations, 60 files, all `system/engine/*` and `system/*` / `functions/*` support files (banks 00–03). Every iteration used the Q1–Q7 table. Gate unchanged at every step in the line-tracked build (crc 2083230829).
- Q3 (accuracy) was **F** in most files (the small support files were M or P). Typical defect counts per file: 5–15, about 45 inaccurate comments in `sprite_composition`, about 20 in `ConsoleStringRenderer`, about 80 inline comments rewritten in `warps_interaction`. This is the evidence base for "defect density in prose is high even after an author pass": see report §4.
- Edits were made with `ingest` (I001–I014) then `annotate` (I015–I020); both tools were later removed. The specs `edits/I015-I016.json`, `I017-I018.json`, `I019-I020.json` shared one spec per two iterations (I001–I014 have no spec file).

## Process deviations recorded in the ledger itself
- Phase 0: a read-only `node -e` check was used once despite the no-scripts rule.
- Between I001 and I002 and again before I003 the user ran plain `npm run extract`, which strips line-tracking tags; `extract:lt` had to be re-run. (Early evidence that the two modes drift apart; see report G-1.)
- I011/I012 gate: `npm run extract:lt` failed in `rm -rf extracted/*` ("Device or resource busy" on `extracted/system/engine`), aborting the chain after most of `extracted/` was deleted; recovered by running the extractor directly. (The same failure recurred in I071/I072: report G-2.)
- `smooth_follow.asm` line endings had to be normalised to CRLF after a mixed-EOL splice (I013/I014).

## Defect classes seen (all FIXED in notes unless stated)
1. Inverted or wrong branch / compare semantics in notes: `HaltIfMaxFrames` (I004), `BranchIfBehindWall` (I007), `BranchIfCollisionTypeNe` branches on EQUAL (I007), `BranchOnPlayerFacing` direction order (I020), `MulDivide` 24-bit claim (I017).
2. Notes copied from a different file or describing handlers that do not exist: `cop_handlers_palette` block header (I009), `cop_handlers_input` header listing 11 handlers vs 4 (I010), `cop_dispatch` header naming 13 non-existent handler blocks (I020).
3. Purpose guessed from a label: `SpriteVramDma` (uploads BG3 tilemap, not sprites, I012), `deathFlag` (depth bucket array, I011), `PlaceBarrierTiles` (draws OPENED chests, I009), `scene_flag_table` (actually accel/decel curves, I004), `signed_sine_table` (a cosine), `scene_barrier_chest_table` (chest records), `FacingData_*` (I008).
4. Units and widths: tilemap row `$40` bytes not `$80`; `$11` one row not two (I010); 4bpp tile = 32 bytes (I003); 16-byte vs 16-word inventory (I006); `+$20` vs `+$14` (I015).
5. Hardware misstatements: HDMA repeat-mode line counts (I003, I009), DMAP0 direction (I002), B-bus registers called channel config (I009), VMAIN/WRDIV widths (I017).
6. Wrong owner / location references: `scene_script.DmaWordToVram` (I002/I003), cop handler lists (I020), "cop_handlers_solid" referencers (I007).
7. Direction vocabulary clashes: facing 0=down,1=up,2=left,3=right (`GetPlayerFacingDirection`) vs 0=N,1=E,2=S,3=W (`CardinalToPlayer`) vs 0=N,1=S,2=E,3=W in `combat_collision` (I002 defect 3). Comments across the codebase may still use the third order; no sweep was run.
8. WaitByte semantics were verified correctly at I001 (`N+1` ticks) and are the source of the later n+1 rule; no one swept earlier notes written before I011.

## Mnemonics added (append-only `db-us/mnemonics.json`)
About 80 names across I001–I016: source-cache slots, `gfx*`, `tilemapOrMask*`, `collisionFlagTable*`, `metatileDefBase`, `visibleHeight`, `climbStateData+2`, `enemyHpCurrentDisplay`, `hitVictimMaxHp/Hp`, `eventFlagsF8toFF`, `transitionBrightness`, `effectRenderDeltaX/Y`, `bg3TilemapBuffer/Row1`, `sceneTableIndex`, `enemiesRemaining(+Bcd)`, `worldMapStaged*`, `menuModeFlag`, `onDeathCallbackBank`, `sceneSaveDataBank`, `reviveWarp*`, `gameOverWakeupFlag`, `consoleAttrWord`, `consoleLineStart`, `oamComposeBuffer+N`, `oamStaging`, `playerTileSrcBase`, `playerSpriteCache*`, `actorRenderList`, `colStripStagingPtr`, `rowStripStagingPtr`, `bgTilemapVramBase`, `adhocVramDma*`, `hieroglyphSlots`.

## Misnamed mnemonics proposed for rename (rows) but never renamed — VERIFIED still in `db-us/mnemonics.json`
| Mnemonic | Address | Problem recorded in ledger | Row | Live use (VERIFIED) |
|---|---|---|---|---|
| `deathFlag` | `$0200` | is the depth-sort bucket array; nothing reads it as a death flag; `docs/wram-memory-map.md:170` documents a `deathFlag` no code uses | 54 | see total below |
| `actorLimitThreshold` | `$00E4` | ending/credits timeline counter | 22 | |
| `musicParentActor` | `$06F2` | holds the current music (track) index | 67 | |
| `sceneStateHelper` | `$099F` | attribute high byte of the console attribute word | 47-49 | |
| `deathActionIdx` | actor field | is the event-block index | 27/28 | |
| `iframeCounter` | actor field | hides sign convention (positive = hit-stun, negative = recovery) | 27/28 | |
| `scratch1010+6` | `$7F1016`-area | custom push-hit callback | 37 | |
| `loopStartPcActor` / `loopCounterActor` | `$7F2100/02` | these are the thinker variants | 90 | |
| `moveXAlt` / `moveYAlt` | actor fields | dual use (movement index vs target pixel) | 68, 79-80 | |
| `eventFlags` | `$0A00` | start of a mixed state page; used beyond event flags | deferred | |
| `gfxCacheIdxA/B` | `$0648/$064A` | are transition parameters, not cache indices | 3 | |

Live count of operands carrying the nine clearly wrong names (`deathFlag`, `actorLimitThreshold`, `musicParentActor`, `sceneStateHelper`, `deathActionIdx`, `iframeCounter`, `scratch1010+6`, `loopStartPcActor`, `loopCounterActor`): **about 107 operand lines in 37 non-sprite files** (VERIFIED by grep). Largest: `sF0_class_dismissed` 22, `actor_execution` 13, `combat_collision` 8, `sprite_composition` 6, `sF7_credits` 6. Each of these is a name that contradicts the code it labels and was named wrong in the audit by the author's own earlier ledger. A mnemonic rename changes every site at once and bytes do not change, so this is the cheapest accuracy gain in the backlog (AP-11).

Also rediscovered later: `$06F2` as a track index was established in I009 ("`musicParentActor` copy in `orbitAngle` restores the scene music") and I013 (`music_actors`: "holds the scene's current music index, not a parent actor"; row 67). I065 re-asked it as OQ-I065-3. Cross-iteration duplicates are not de-duplicated (report P-9).

## Owed fixes recorded as "fix in a later iteration" — status check
| Owed item | Source | Status (VERIFIED this pass unless stated) |
|---|---|---|
| `system_core.asm` "+$14" curve offset | I004 | fixed in I015 (REPORTED); `+$14 offset` no longer found in `extracted/` |
| `system_init.asm:266` says "scene_flag_table" for `sine_table_8bit` entry 0 | I004 | no `scene_flag_table` string in `extracted/` now (fixed) |
| `camera_tilemap.asm` "sprite tileset staging area" for `$7F0200` | I003 | not found now (fixed) |
| `docs/bank01-data-tables.md` §9f/9g sine/cosine descriptions | I004 | REPORTED docs row 58-60; not re-checked, see A11 |
| `docs/bank01-data-tables.md` music ID off-by-one | I002 | REPORTED; not re-checked |
| `SpawnFieldRevealEffect` inverted comments (byte 3 = width, byte 5 = dest X) | I012 row 61 | REPORTED; to check in A02 |
| `forced_walk_sequence_table` doc "frame + step delta byte pairs" | I018 | REPORTED |
| `MenuSelectionHandler` transforms artefact (row 62, OQ-59) | I012 | later handled (MenuSelection_* notes added by hand, per I051–I060 summary) |
| docs rows 31, 45, 50, 51, 58–60, 81, 87 (doc corrections proposed in I006, I009, I010, I011, I012, I016, I018) | various | docs state not verified here; AP-06 |

## Open questions opened in this range
OQ-1 … OQ-69 (not individually answered here). Static-answerable examples visible in the ledger: OQ-8 (`$0080`/`$0400` roles, E1 conflict), OQ-62 (Z inheritance after PLP, answerable by reading), OQ-69 (`SetEntryHere` stray byte, answerable by trace). Runtime: OQ-21 (resolved I009), OQ-39, OQ-45, OQ-64.

## Not examined in this range (gaps)
- `hdma_dma_spc.asm`, `vblank_joypad.asm`, `system_init.asm`, `thinker_execution.asm` and the other `system/engine` files were touched only indirectly; the plan lists them in later iterations (checked via the plan, REPORTED).
- Direction-order sweep (class 7) and the WaitByte sweep (class 8) were never run across earlier notes.
