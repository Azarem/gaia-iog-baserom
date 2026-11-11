# I041 results

Files: `thinkers/mode7_perspective.asm` (Bank 03), `functions/SpawnAttackTrailEffect.asm` (Bank 00), `actors/hidden_red_jewel.asm` (Bank 00).
Spec: [edits/I041.json](../edits/I041.json). New proposals: [renames/I041_renames.md](../renames/I041_renames.md). New questions: [questions/I041_questions.md](../questions/I041_questions.md).

Conventions (unchanged): verdicts **P/M/F/NA**; dispositions **FIXED / PROPOSED / DEFERRED-EVIDENCE / NOFIX**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 comment density, Q2 value, Q3 accuracy, Q4 mnemonic/address accuracy, Q5 mnemonic opportunity, Q6 part naming, Q7 evidence quality.

### File 1: thinkers/mode7_perspective.asm (Bank 03)

Evidence: E1 (the whole file read end to end, with every quadrant routine and the byte offsets of all four loops checked against each other; `SpawnThinker` / `SpawnThinkerParam` in `cop_handlers_thinker`; `QueueDma` in `cop_handlers_hdma_dma`; `WriteBgScroll` in `system_core`; the NMI Mode 7 upload in `vblank_joypad`; `WorldMapController` writes to `$B6/$B8/$BC`), E2 (all four spawners read: `pr8C_prologue1`, `pr8C_prologue5`, `garden_crash_cutscene`, `future_vision_cutscene`; `scene_thinkers` master list entry `$FE` = `thinker_spawn_0CEB3D`; `math_lookup_tables` adjacency contract; the unused variant for contrast), E3 (`structs-reference` thinker-def), E4 (nesdev PPU registers for M7SEL; SNES hardware divide timing of 16 cycles).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A long header but only 76 existing comments on a 584-byte file, nothing in the four quadrant loops that explains the table layout or the accumulator | FIXED (rewritten block note, 22 part notes, 265 comments: every instruction of the init, the table fill, the sign dispatch, the queue code, the four scanline loops and `NormalizeDivisor`) |
| Q2 | M | The old text hid what the three global words are, how the divisor grows per scanline and which spawner uses which entry | FIXED |
| Q3 | **F** | (a) **`M7SEL = $80` means transparent outside the 1024x1024 map** (bit 7 = no repeat, bit 6 = 0 = transparent); the old notes said "repeat". The cutscene spawners write `M7SEL = 0`, which does repeat. (b) **`$B6` is the per-scanline divisor increment (8.8), not a rotation angle**; the rotation is `$BC` (`($BC AND $1FF) x 2` indexes the 512-step tables). `$B8` is the starting divisor, `$B6/$B8/$BC` are **global low-RAM words** (the thinker forces D = 0), not actor or thinker fields. (c) **The accumulator is the 16-bit word at `$01/$02`**: `$01` is a fraction byte, `$02` the low byte of the divisor word, so `ADC $01` adds `$B6/256` to the divisor; the carry goes to `$03` and then halves all operands. The old text said "accumulating `$04` into `$01`". (d) **The `#1B`..`#1E` operands of `QueueDma` are B-bus register indices ($211B-$211E), not channel numbers**; `QueueDma` is a direct-table HDMA setup on the next free channel. (e) **`thinker-def <#04,#08>` is the word `$0804`** (bit 2 = `RunThinkers_TypeB`, bit 11 lighter-frame), not "type $04, priority $08"; `SpawnThinker` does not apply that header, which is why the four cutscene spawners store `$0804` themselves. (f) **`Mode7PerspectiveInit` runs only for scene `$FE`** and falls into the update code (no RTL); the other four users spawn `Mode7PerspectiveUpdate` directly and skip Init. (g) **Sign table** for all four quadrants derived and checked: A = D = cos/div, B = sin/div, C = -sin/div. (h) The "Mode 7 configuration flags" at `$7F0B22/$7F0B24` have no reader in `extracted/`. (i) The 4-vs-6 NOP difference is explained by the extra instructions before the `RDDIVL` read in quadrants 3 and 4 | FIXED |
| Q4 | M | `$B6/$B8/$BC` were described as actor fields and the register operands as channels | FIXED (block note, comments); mnemonic proposal R-I041-3 |
| Q5 | M | Three global words and the centre words appear as bare `$00B6`, `$00B8`, `$00BC`, `$00CA`, `$00CC` in this file and in five other scripts | PROPOSED (R-I041-3) |
| Q6 | M | Twelve auto labels in the file (`loc_03A994` ... `loc_03AB7D`) have no meaningful names | PROPOSED (R-I041-2) |
| Q7 | M | E1 + E2 + E4; the visual result, the rotation direction, the exact table timing and the unknown `$7F0B22/24` readers were not verified | DEFERRED-EVIDENCE (OQ-I041-1 to OQ-I041-4) |

### File 2: functions/SpawnAttackTrailEffect.asm (Bank 00)

Evidence: E1 (the whole file; both spawn sites in `combat_collision` read with the surrounding `TCD` / boss test / `FormatDamageDigits` carry test; `SpawnListAppend`, `CopyActorState`, `LoopStart` / `LoopEnd`, `ComposeDigitSprites`), E2 (`rg` for every reference: two spawn sites, one unreferenced variant `AttackTrailShort_unused`), E3 (`functions-combat-defeat.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A three-line header and no comments | FIXED (block note, 1 part note, 36 comments) |
| Q2 | M | A reader could not tell whose position is tracked or where the digits come from | FIXED |
| Q3 | **F** | (a) **It is a damage-number actor with one 16-iteration loop and no ghost copies**; the old text said "16 frames at position then 16 more drifting upward" and "interpolated between the attacker's previous and current position". (b) **It follows the victim** (`$24` = victim slot, the previous position is in `$20/$22`) and rises 1 pixel per frame from 16 pixels above the victim. (c) **Spawn sites**: `PlayerAttackHitTest` with flags `$2F00` and `ApplyHitDamageToVictim_DamagePath` with `$2B00` plus `$12 |= $1000`; the operand is the child's `$10` flags word, not a priority. (d) **No digits for bosses (`$12 & $20`) or damage of 1000 or more.** (e) **The digit value is in the child's `$28`**, written by the caller after the spawn, and copied to the absolute scratch word `$0000` (not the actor's own `$00/$01`). (f) The victim slot is never revalidated (hazard) | FIXED |
| Q4 | P | The instructions and operands are annotated; the name misleads | NOFIX (see R-I041-1) |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | `SpawnAttackTrailEffect` and the sibling `AttackTrailShort_unused` suggest a weapon trail; both draw damage digits | PROPOSED (R-I041-1) |
| Q7 | M | E1 + E2; the slot-reuse hazard and the `$2F00` / `$2B00` difference were not run | DEFERRED-EVIDENCE (OQ-I041-5, OQ-I041-6) |

### File 3: actors/hidden_red_jewel.asm (Bank 00)

Evidence: E1 (the whole file; `TestEventFlag_0200` / `SetEventFlag_0200` in `flag_helpers`; `GiveItem` and `GiveItemToPlayer`; `item_get_dialog_table` for item `$01`), E2 (the 16 spawn records read from `scene_actors` with their types; the seven `JML` sites in `gs2B_seth`, `nvAE_stone_girl2`, `wa79_lance`, `fr32_creep`, `eu95_ann`, `sc01_fisherman`, `ec0A_right_guard`; scene folders from the spawn tables), E3 (`actors-player-rewards.md`, `event-flags.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A paragraph header and one comment | FIXED (block note with the 16-scene flag table, 6 part notes, 18 comments) |
| Q2 | M | The header did not say that the flag index is `$0E + $80` or where the full-inventory target is reused | FIXED |
| Q3 | M | (a) **Flag index `$80..$8F` on base `$0200`** (bytes `$0A50-$0A51`) with one distinct value per scene, now tabulated. (b) **The flag is not tested at spawn**: the actor is always placed and does nothing once the flag is set. (c) **A failed `GiveItem` leaves the flag clear**, so the jewel can be taken later. (d) **`GiveItem` prints nothing**; the strings are the script's own. (e) The old "Native village and Euro mansion" list of NPC users was incomplete: seven NPC scripts jump into `HiddenRedJewelInventoryFull` (Seth, stone girl, Lance, Creep, Ann, fisherman, right guard) | FIXED |
| Q4 | P | Mnemonics and operands are as annotated | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | `loc_00C6A5` is the shared RTL and the two dialog strings are named by address | PROPOSED (R-I041-2) |
| Q7 | M | E1 + E2; chest records use bit 7 of the flag byte as the end sentinel (`scene_chest_table` note), so chest flag ids stay below `$80` and cannot collide with `$80-$8F`; what the metasprite looks like was not checked | DEFERRED-EVIDENCE (OQ-I041-7) |

### Shared gate (I041)

`npm run merge -- plans/extracted-audit/edits/I041.json --dry-run` first reported 3 block notes (all updated), 29 part notes (24 new, 5 updated) and 319 comments (242 new, 76 updated, 1 unchanged), with ten warnings that the comments containing the word `RTS` match the `CreditPositionLookup` transform; that transform is scoped to its own block, so the warnings are false positives and the extracted text is unchanged. After the real merge, `npm run extract:lt` and the repeated dry run reported 0 files to change. I then added the words "plus two dialog strings" to the jewel block note (spec regenerated, merged again, round trip 0 changes). `npm run rebuild` finished successfully and `artifacts/crc.json` reads checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged).

Docs that repeat the old claims (not edited, `docs/` is outside the allowed folder): `docs/code/bank03/mode7-and-cutscenes.md` lines 54 and 97 (`M7SEL = $80` as "repeat playfield", `$03A940` entry) and line 99 ("queue 4 HDMA channels"); `docs/unused-mode7-boss-analysis.md` lines 35 (the three "actor fields" `$B6` rotation angle / `$B8` / `$BC`), 79-81 (`STA $00BC,Y` into "the thinker's" fields, which would write at the thinker slot instead of the global words), 477 and 619 (`M7SEL = $80` repeat); `docs/cop/families/hdma_dma.md` line 210 (names `QueueHdmaChannel` for this file, which uses `QueueDma`); `docs/code/bank00/functions-combat-defeat.md` lines 343-370 (SpawnAttackTrailEffect described as a weapon-swing afterimage trail "spaced across the attack arc", invoked from weapon scripts); `docs/code/bank00/README.md` lines 671 ("16-frame hit trail") and 899; `docs/code/bank03/sprite-rendering.md` lines 170, 215 and 248 ("weapon trail particles"); `docs/code/bank04-npc-actors.md` line 405 ("Red Jewel fanfare" for `hidden_red_jewel`; it is the full-inventory message used by the NPCs).

Suggested commit message: `audit(I041): document mode7_perspective (global $B6/$B8/$BC, 8.8 divisor accumulator, sign table, QueueDma registers, M7SEL transparent, spawners), SpawnAttackTrailEffect as the damage-number actor, hidden_red_jewel flag range and 16 placements`

Please commit when you're ready.
