# I044 results

Files: `thinkers/global_ambient_dispatcher.asm` (Bank 00), `functions/ApplyOrbitalOffsetXY.asm` (Bank 00), `thinkers/incan_ruins_transform_palette.asm` (Bank 00).
Spec: [edits/I044.json](../edits/I044.json). New proposals: [renames/I044_renames.md](../renames/I044_renames.md). New questions: [questions/I044_questions.md](../questions/I044_questions.md).

Conventions as in [I029_results.md](I029_results.md). Mesen2 MCP was reachable but no ROM was running; no runtime session was set up, so every claim below is static (E1/E2/E3).

### File 1: thinkers/global_ambient_dispatcher.asm (Bank 00)

Evidence: E1 (all 356 lines with `extract:lt` addresses; all four probe builders, the scan loop, the snapshot / restore pair and the animation-offset maths traced by hand, including the stack layout of the two `PHK` / `PEA` / `PHA` / `RTL` calls), E2 (`thinker_execution` header (runner filters, `animScratch2` bits 2 and 11), `cop_handlers_thinker`, `cop_handlers_dungeon_switch` `SwitchCase` (no range check), `cop_handlers_palette` `PaletteStart` / `PaletteStep`, `palette_bundles.asm` bundles `#0B` / `#0C` / `#23`, `GetPlayerFacingDirection` header (0 down, 1 up, 2 left, 3 right, carry clear = valid), `cop_handlers_script_control` `SetInteractHandler`, `sprite_composition` `UpdateActorAnimation`, `system_init` (RAM MVN stub at `$0402`, remap defaults), `docs/wram-memory-map.md` (`characterForm`, input remapping), `db-us/transforms.json` (button remaps), `actor_execution` (player header byte `#85`), a grep of Flags12 `$0200` setters (over 150 actor scripts), `scene_thinkers.asm` (59 spawn lists covering 173 of the 184 scenes that have thinkers)), E3 (`docs/code/bank00/thinkers-system.md:282-350`, `docs/code/bank00/README.md:145,176,573,866,910`, `docs/code/bank0C-scene-spawn-tables-comet.md:430`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | An 8-line header and 8 inline notes for 356 lines | FIXED (block note rewritten: palette, filter word, the 8-step talk interaction; 25 part notes added; 62 comment entries, 54 new and 8 replaced) |
| Q2 | M | The talk interaction (probe point, scan limits, in-front vs behind, snapshot / restore, Flags12 `$0200` skip) was undocumented | FIXED |
| Q3 | **F** | (a) **Trigger**: the header says a 'direction press'; the code tests joypadCurrent bit `$8000` (the interact bit: vanilla B; in this build `transforms.json` sets `remapA = $8080` / `remapB = $4008`, so A feeds it). (b) **Scan**: not 'all actors within 16x16 px of the player in the facing direction'; a probe point 1 px in front, nearest actor with |dx| and |dy| both below `$10` and sum below `$20`, Flags10 bit `$1000` required (the player has it clear). (c) **`$2F` is not a sound**: it is the MVN byte count minus one (48 = one actor slot); the code copies the target's actor slot and `$7F` page to `$7E:3410-$346F`, turns the target to face the player, runs its chat routine and writes the copies back. 'Play SFX $2F via $0402 jump table' and the doc's 'DMA sound #002F to APUIO' are wrong. (d) **Bit 11 of `animScratch2`** is the Light-runner filter, not an 'interaction ready flag': clearing it removes the thinker from the Light runners. (e) **Palette**: not 'ambient lighting' / 'colour grading'; it loads the player's OBJ palette 0 colours `$81-$8F`, once, at spawn; case 3 is unreachable (`characterForm` is 0-2). (f) **Inverted labels**: `GlobalAmbientFacingInvalid` is the valid-facing path (BCC, carry clear = valid); `ScanEast` / `ScanWest` / `ScanNorth` / `ScanSouth` are facing 0 down / 1 up / 2 left / 3 right; `AnimFacingVertical` is the left / right branch; `PlayTalkSound` plays no sound. (g) `$09EE` is overwritten with the animation offset by `PickTalkAnimFrame`. (h) Flags12 bit `$0200` (set by over 150 actor scripts: signs, books, doors, scripted NPCs) skips the snapshot, turn and animation. (i) The docs' scene counts disagree (`~40`, `59x`, `9`); the spawn tables show 59 lists covering 173 scenes | FIXED |
| Q4 | M | Operands correct; the raw `$09EE`, `$0402`, `$0404`, `$0405`, `$3410` are readable only with the new notes | PROPOSED (R-I044-4) |
| Q5 | M | Several raw addresses with a clear role (saved facing, RAM MVN stub and its bank bytes, the snapshot area) | PROPOSED (R-I044-4) |
| Q6 | **F** | Eleven labels say the opposite of what they do or mislead (list in the renames file) | PROPOSED (R-I044-2, R-I044-3) |
| Q7 | M | E1 + E2; the snapshot / restore behaviour with a chat routine that yields, the exact meaning of Flags12 `$0200` and the A-button mapping have no runtime check | DEFERRED-EVIDENCE (OQ-I044-2, OQ-I044-3, OQ-I044-4) |

### File 2: functions/ApplyOrbitalOffsetXY.asm (Bank 00)

Evidence: E1 (all 68 lines, sign / carry flow through `Multiply8x8Unsigned` traced), E2 (`hardware_math` `Multiply8x8Unsigned` (preserves carry), `math_lookup_tables` header (256-step sine = quarter table + cosine table, 1.40625 degrees per step, `signed_cosine_table_8bit` peak `$7F` at 0), the three call sites in `gw8A_sand_fanger` (two) and `awB1_goldcap` (one)), E3 (`docs/code/bank00/functions-camera-motion.md:203-228,259`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A 3-line header and no inline notes | FIXED (block note rewritten; 12 comment entries, all new) |
| Q2 | M | The field layout, the 'adds to the current position' contract and the orbit direction were undocumented | FIXED |
| Q3 | **F** | (a) **The old header lists `statue_inventory_reward` as a caller**; it uses `ApplyOrbitalOffsetFromRef`; the real callers are 3 sites (two in `gw8A_sand_fanger`, one in `awB1_goldcap`). (b) **Field layout**: the low byte of `orbitAngle` is the X angle and the high byte (`$7F0011`) the Y angle; the low byte of `orbitDiameter` is the X diameter and the high byte (`$7F0013`) the Y diameter. The doc at `functions-camera-motion.md:203-228` has the layout wrong (Y angle at `$7F0012`, diameters at `$7F1010` / `$7F1012`). (c) **'Around the current position'**: the routine ADDS to `$14` / `$16`, so the caller must write the orbit centre first on every call. (d) X uses `sine_table_8bit`, Y uses `signed_cosine_table_8bit` with its own angle; with equal angles the motion starts below the centre and runs counter-clockwise on screen; the offset peaks at about +/- diameter / 2 | FIXED |
| Q4 | M | Operands correct | NOFIX |
| Q5 | M | `$7F0011,X` and `$7F0013,X` are raw while `orbitAngle` / `orbitDiameter` are named | PROPOSED (R-I044-4) |
| Q6 | M | The name matches the behaviour | NOFIX |
| Q7 | M | E1 + E2; the on-screen direction and the offset peak have no runtime check | NOFIX (low risk) |

### File 3: thinkers/incan_ruins_transform_palette.asm (Bank 00)

Evidence: E1 (all 72 lines), E2 (`cop_handlers_palette` `PaletteStart` / `PaletteStep` (the whole bundle plays inside `PaletteStep`), `cop_handlers_thinker` `KillThinker` (acts on X, uses D only for `$0A`), `actor_execution` thinker pool (free list ascending from `$0F00`), `scene_thinkers.asm` spawn records (scenes `$2B`, `$2D`, `$2F`), `scene_actors.asm` (scene `$2B` / `$2D` / `$2F` actors `gs2B_*`, `gs2D_*`, `dc2F_adrift`), `palette_bundles.asm` bundles `#1A`, `#33`, `#34`, `#36` decoded, `scene_lifecycle` and the I-series notes on the `$FF` latch, `dc2F_adrift`, `gs2B_erik`, `gs2E_sleep` flag sites), E3 (`docs/code/bank00/thinkers-palette.md:211-231`, `docs/code/bank00/README.md:135,485`, `docs/code/bank0C-scene-spawn-tables-comet.md:439`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A 3-line header, 2 part notes and inline notes | FIXED (block note rewritten; 2 part notes replaced; 23 comment entries, 6 new and 17 replaced) |
| Q2 | M | The header did not explain that the flag tests run only at spawn, what the three bundles do, or what the kill sequence targets | FIXED |
| Q3 | **F** | (a) **Wrong place**: it is spawned in Gold Ship scenes `$2B` (ship wreck), `$2D` (ship wreck interior) and `$2F` (adrift), not in the Incan Ruins; flags `$4D` / `$52` are set and cleared by `dc2F_adrift` (also `gs2E_sleep`, `gs2B_erik`). The docs' 'Larai Cliff / Angkor' and scene indexes 34-36 are wrong. (b) **Phase is picked at spawn only**: the loops never return to the flag tests (the 'Transformation starting?' notes read as if they were polled). (c) **`#34` is not alternated with `#33`**: `#34` plays once, then `#33` loops while the `$FF` latch is set, and `#34` plays again after the latch clears. (d) `#1A` and `#33` are the same 12-strip cycle (a 24-byte window sliding one colour per strip on colours `$21-$2C`, wait 2-5), `#34` is a one-shot recolour (16 colours at `$70`, one at `$59`), `#36` a one-shot (17 colours at `$50`, 16 at `$70`). (e) **Kill sequence**: it kills the list head and the next pool slot, which are the first two `scanline_band_hdma_thinker` records in all three lists. (f) The fill writes palette-buffer bytes `$40-$5F`, which are colours `$20-$2F` (the old 'CGRAM entries `$40-$5F`'); `$1421` is a very dark blue (R1 G1 B5) | FIXED |
| Q4 | M | Operands correct; the `$7F0A40` fill is raw | PROPOSED (R-I044-4) |
| Q5 | M | See Q4 | PROPOSED (R-I044-4) |
| Q6 | **F** | The block and part names say 'Incan Ruins' and 'Warmup' for a Gold Ship thinker whose `$4D` phase is not a warm-up | PROPOSED (R-I044-1) |
| Q7 | M | E1 + E2; what `$4D` and `$52` mean in the adrift story and how the colours look were not checked at runtime | DEFERRED-EVIDENCE (OQ-I044-1) |

### Shared gate (I044)

`npm run merge -- edits/I044.json --dry-run` first warned once ("comment {49098}: text matches a transforms.json pattern (`\$8000`...)"); the comment and the other button wording were reworded and the dry run was clean. Merge applied: 3 block notes, 27 part notes (25 new, 2 replaced), 97 comment entries (72 new, 25 replaced). `npm run extract:lt` then `npm run rebuild` (one run for I043 + I044): `artifacts/crc.json` = checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged). With comments and `{n}` tags stripped, the code of all three files is identical to HEAD.

Suggested commit message: `audit(I044): global_ambient_dispatcher talk interaction and snapshot, ApplyOrbitalOffsetXY field layout, Gold Ship wreck palette thinker (not Incan Ruins)`

Please commit when you're ready.
