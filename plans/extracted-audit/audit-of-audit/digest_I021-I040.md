# Digest — results I021–I040 (`results/I021_results.md` … `I040_results.md` and `I021-I040_sanity-check.md`, read in full)

Read in full in A00-extended (2026-10-28). VERIFIED = checked against live files this pass; REPORTED = from the ledger.

## Scope and shape
- 20 iterations, 60 files (I035 touched 5 including related data notes). Covered: `hdma_dma_spc`, `QuintetLzDecompress`, `thinker_execution`, `cop_handlers_sprite`, `spc_transfer`, `vblank_joypad`, `stair_climb`, `cop_handlers_player_sprite`, `cop_handlers_metatile`, `system_init`, `MenuSelectionHandler`, `map_coords`, `player_character`, `item_use_system`, `attack_ability_system`, `inventory_menu`, `player_move_*` (diag, south, ns, east, ramps), `tile_collision`, `slope_ramp_physics`, `inventory_overlay`, `parallax_thinker`, `ramps`, `interaction_handlers`, the `oneshot_*` / `flag_gated_*` / `palette_*` thinkers, small `functions/*`.
- From I021 on edits went through `npm run merge` (spec per iteration, `edits/I0nn.json`). No mnemonic was added in this range: the I021–I025 gates say "No mnemonic added (spec-only iteration)" and no gate in I026–I040 reports an addition; the Q5 column has only PROPOSED rows from here (R-I021-3, R-I022-3, R-I023-5, R-I024-1/2/5, R-I035-4 …).
- I037 notes "I035 and I036 were skipped at the user's request"; both have result files, so they were done afterwards (out-of-order execution; fine, but the checklist order is not chronological).
- Q3 verdict was **F** (or M with several corrected facts) in almost every file, including the one- and two-line thinkers; typical findings per file 3–15, up to 14 lettered defects in `player_character`, `inventory_menu`, `item_use_system` and `slope_ramp_physics`.

## What the defects were (classes, with iteration examples)
1. **Vocabulary inherited from the vanilla ROM / docs rather than the code**: "stairs" for Psycho-Slider glide triggers (I023), "ramp collision" for jump launchers (I036), "parallax BG header" for a band table (I035), "gradient" for a window-edge circle (I031), "palette flash" for fades (I027–I029, I033, I034).
2. **Button/constant staleness after the baserom's button remap (`transforms.json`)**: comments quote `$8F30`, `$8001`, `$CFF0`, `$4000`, `$40B0`. Fixed in the iteration's own files; live residue (VERIFIED): `dark_space.asm:14`, `game_over_sequence.asm:26`, `item_use_system.asm:16`, `player_transition_handlers.asm:16` quote vanilla constants *on purpose*, each with an explanation. The remaining `$8001` / `$40B0` hits in `gw83_asp`, `av75_voice_rooms`, `sc02_card`, `spriteset_transform_poses` are data, not comments (no action).
3. **Carry / Z sense inversions**: `CheckSubTileAlignX/Y`, `TileProbeMain` (nonzero type, not "blocked"), probe return conventions (`map_coords`), `BCC` = carry clear. Recurred as comments surviving next to rewritten notes (sanity I021–I040 defect groups 2–3).
4. **Direction and axis errors**: `MapCellDown/Up` are row moves, cell "right/left" wording; `FineAdjustXEast` moves X west; `DiagPushRight` direction; ramp "Up/Down" names; `EastRampUp` descends (I029–I040).
5. **n vs n+1** for `WaitByte` (sanity I021–I040 group 1; `warps_interaction` and `music_actors` were not in this range and are still wrong, see N-4).
6. **Mis-attributed callers/spawners**: "Edward Castle" spawn that did not exist (I029), "called by most enemy actors" (2 callers, I037), "used by combat collision" (no caller, I038), docs listing 14 vs 26 placements (I030).
7. **Flag-bit meaning guessed**: `$0200` of actor `$10` vs `playerFlags $0200` (I030, I032), `$0008` "grounded" (corrected in I047 — see I041–I050 digest), `$2000` "display-filtered" vs `$1000` (I026), `$4000` off-screen (I027).
8. **Notes for files that cannot be merged**: `MenuSelectionHandler.asm` (OQ-59): notes prepared in `edits/I024_MenuSelectionHandler_PROPOSED.json` and applied later by hand (`MenuSelection_*` notes were found present in the I051–I060 summary; status REPORTED).

## Cross-iteration / ledger-level problems found while reading
| # | Finding | Evidence |
|---|---|---|
| L-1 | **A question can be answered inside a later iteration while its own ledger row stays "open"** | OQ-61 answered in I021, OQ-64 in I022, OQ-I029-4 "answers the east side statically" in I040 but the I021–I040 sanity check lists it as "unchanged and still open"; OQ-I025-2 partly answered by `dark_space.asm:14`. No registry maps question → answer → iteration. |
| L-2 | **Duplicate rediscovery** | `$06F2` = track index found in I009/I013, re-asked in I065 (OQ-I065-3). `FacingData_*` mislabel found in I008, re-found I067. `ProbeLeftTiles/RightTiles` naming found I024, I033, I039. |
| L-3 | **Orphan comment left in notes** | `notes/comments/bank00.json:1791` key `47052` ("One-shot PaletteStart #18 + PaletteStep then immediate KillThinker"): stale text (PaletteStep plays the whole bundle) that `merge` cannot remove; reported in I029 and I034; still present (VERIFIED). |
| L-4 | **`merge` bank-detection side effects** | I031: `detectBank` takes the first `code_XXXXXX` token anywhere in the file *including notes*, so notes must avoid foreign `code_/loc_` tokens (worked around by rewording). Same quirk is the root of the "bank-key duplicate" noise in the I051–I060 sanity check. Needs a fix in `src/` (A15). |
| L-5 | **Transform-pattern collisions** | merge warns when a note matches a `transforms.json` pattern; many comments were reworded to dodge it (I023, I026, I027, I028, I032). Documentation text is distorted by a tool limitation; a `transforms.json` pattern that can match a comment line is itself a latent bug (the pattern is applied to the whole block text, comments included). |
| L-6 | **Spec idempotence / replay** | Specs of I021–I040 are one-shot: replaying them overwrites the 73 sanity-corrected comments (sanity I021–I040, last paragraph). The sanity spec must be replayed last. Same for I041–I060. (P-3 in the report.) |
| L-7 | **Analysis scripts** | "scratch script/parser/throwaway script" used for ROM decoding, `scene_thinkers` parsing, bundle decoding (I029, I031, I032, I035, I036). These are read-only analyses, not note edits, so the editing rule is not breached, but the decoded tables (palette bundles, parallax entries, spawn lists) exist only as ledger prose and cannot be re-run. |
| L-8 | **Sanity pass used read-only sub-agents** | I021–I040 sanity: 1,708 surviving original comments re-read "by read-only subagents in two rounds"; the report says subagent claims were wrong often and every candidate was re-checked by hand. Contradicts the plan's "no sub-agents" (it is the same constraint the user gave for this audit). |
| L-9 | **Truncated commit-message line** | `I034_results.md` suggested commit message ends mid-sentence ("DrainActorQueue walks the"). Cosmetic. |
| L-10 | **Patches reference generic labels** | I028: `baserom/collectible-system/RelicMenu.patch.asm` and `baserom/options-menu/EnhancedInvItemPicker.patch.asm` reference `code_02E47F` / `StatusCharRow*`; rename R-I028-2/3 must check patches first. No ledger records that this check was ever done. See A13. |

## Misleading names still live in the extracted tree or mnemonics (VERIFIED where noted)
| Name | Where | Problem recorded | Status |
|---|---|---|---|
| `invincibilityTimer` (`$040C`) | `mnemonics.json`, 29+ operand sites in `player_character.asm` | is a run window; `player_character.asm:12` itself says "the invincibilityTimer mnemonic name is stale" | **open** (a note apologising for a live label) |
| `climbStateData` (`$09E0/$09E2`) | `mnemonics.json` (2 entries), 7 in `combat_collision`, 9 `player_character`, 5 `attack_ability_system` (REPORTED + grep) | is the ability damage bonus, not climb state | open (R-I023-3, R-I025-6) |
| `deathFlag` ($0200) | `mnemonics.json:9` | depth bucket array | open |
| `effectScrollH/mapScrollV/effectScrollV` | mnemonics | BG2 H / BG1 V / BG2 V (R-I035-4) | open |
| `moveXAlt/moveYAlt`, `orbitAngle/orbitDiameter` | mnemonics | indices / repurposed (R-I022-3, R-I036-4) | open |
| `StairTrigger*`, `stair_climb` | extracted | rotated labels | **renamed** (`slider_glide`); `awB2_stair_climb` actor label remains (VERIFIED `awB2_stair_climb.asm:12`) |
| `EnableNmiOnly` | | says the opposite | **renamed** `DisableNmiKeepJoypad` (VERIFIED `scene_lifecycle.asm:195`) |
| `DecompressGfxToVram`, `LzReadBackRef`, `SpcCheckMusicReady`, `NullActorScriptStub`, `RangedAttack*`, `DisableStatusForAttack` | | R-I021-1/2/5, R-I025-2/3/4 | no match for the first three and `NullActorScriptStub` in `extracted/` now except `RangedAttack*` in `player_character.asm` and `scene_lifecycle`/`system_core`/`spriteset_will` hits; renamed in part; confirm per row in A02 |

## Docs still stale (VERIFIED by grep this pass; others in the iterations' lists were fixed)
- `docs/bank01-data-tables.md:388` "Header bytes: BG mode, scroll region boundaries, flags" (parallax table, R-I035).
- `docs/code/README.md:204` and `docs/code/bank00/README.md:518` "18 thinkers" for `sine_hdma_slow_wave` (the table has 2 spawn entries, I032).
- `docs/code/bank0C-scene-spawn-tables-comet.md:432` ambient palette cycler "water shimmer, lava glow, torch flicker…" (guess, I031).
- Fixed since the ledgers (VERIFIED: no match): "Eastward ramp collision", "tile-based slope physics", `deathFlag` rows in `wram-memory-map.md`, "hit-blink immunity", "7 DMA writes", `@dma_setup` call line.

## Evidence quality
- E5 (runtime) is unavailable for the entire range; every behavioural conclusion is static. Statements like "flickers", "slow drift", "one-time boost" are marked UNVERIFIED-RUNTIME in the ledger but appear without the tag in several extracted notes (`ToggleActorVisibilityFlag`, `large_ramps`, `camera_delta_oscillator`). Reader cannot tell traced from inferred (H-2).
- Several decoded data claims (palette bundle colours, parallax entries, spawn counts) were produced by ad-hoc scripts and checked by "counts"; none can be re-verified without re-writing the script.

## Questions and renames opened (counts from the results text)
Counts of OQ-I0nn and R-I0nn rows for this range were not re-counted from the question and rename files in this pass (those files are outside "results"); A02–A03 will count them.

## Files in this range with no audit-owned follow-up found
`QuintetLzDecompress` (Q7 P), `f_inventory_full` (P), `ActorMidpointCalc` name (P), `ambient_palette_cycler` name (P).
