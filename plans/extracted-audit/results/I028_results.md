# I028 results

Files: `system/inventory/inventory_menu.asm` (Bank 02), `thinkers/oneshot_palette_flash_1C.asm` (Bank 00), `thinkers/oneshot_palette_flash_1B.asm` (Bank 00).
Spec: [edits/I028.json](../edits/I028.json). New proposals: [renames/I028_renames.md](../renames/I028_renames.md). New questions: [questions/I028_questions.md](../questions/I028_questions.md).

Conventions (unchanged): verdicts **P/M/F/NA**; dispositions **FIXED / PROPOSED / DEFERRED-EVIDENCE / NOFIX**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 comment density, Q2 value, Q3 accuracy, Q4 mnemonic/address accuracy, Q5 mnemonic opportunity, Q6 part naming, Q7 evidence quality.

### File 1: system/inventory/inventory_menu.asm (Bank 02)

Evidence: E1 (the whole file read end to end; `db-us/transforms.json` rules for `inventory_menu`, applied by hand), E2 (`vblank_joypad` and `system_init` for the remap defaults and the `joypadCurrent = remapped - consumed` model; `cop_handlers_input` for `BranchIfPressed`; `inventory_overlay` for the exit flag, `bg1ConfigMode` copy and the `$0006` actor chain; `actor_execution` / `actor_pool` for `SpawnAfterFlags` ordering and the `$10` bits; `flag_helpers` for `TestFlag_0510`; `tables/system_strings` for the menu strings and the discard bit table; `attack_ability_system` for the ability flags), E3 none beyond the older notes.

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Dense, but the shared mechanics (button model, frame model, slot storage) were missing or wrong | FIXED (block note rewritten with a BUTTONS AND FRAME MODEL section, 30 part notes updated, 61 comments: 8 new, 53 updated) |
| Q2 | M | A reader could not tell which physical buttons the masks mean or why `RTL` appears everywhere | FIXED |
| Q3 | **F** | (a) **Button names were the vanilla layout**: the code tests `$8000` (confirm), `$4000` (cancel), `$C000` (either) and `$6000` (cancel or Select); the baserom remap defaults make physical A = `$8080`, B = `$4008`, X = `$0004`, Y = `$0040`, Select = `$2000` (`system_init` + `transforms.json`), so A confirms and B cancels, and X/Y do nothing here. The comments said "B/Y/X ($C040)", "Y/X cancels", "B picks source". (b) **`RTL` is the idle path, not "exit the menu"**: handlers resume at their `SetEntryHere` next frame; the "tab unchanged - exit menu" and "user declined discard - exit tab handler" comments were wrong. The menu closes through `TabCancel`'s `SetFlagByte #00`, which the `inventory_overlay` main loop polls. (c) **Hover previews were described backwards**: `ShowAllItemSlots` SHOWS the 16 slots (`TabHoverUse/Arrange/Discard`), `HideAllItemSlots` hides them (`TabHoverStatus`); the comments said "hide slots" for the first three and "show all slots" for Status. (d) **`TabHoverStatus` rows are not Will/Freedan/Shadow**: row r tests flag `characterForm x 4 + r`, the CURRENT form's ability slots 0-2 (the fourth is never listed). (e) **`inventorySlots` is 16 bytes**, one item ID per slot, no flags: `AND #$FF00` on a 16-bit read keeps the NEXT slot's byte, it does not "preserve high-byte flags". (f) **D-pad consumption is wider than the direction**: Up consumes `$0B00` (Up, Left, Right), Down `$0700`; the old comment called `$0B00` "vertical D-pad bits". (g) **`$1C` is the blink counter** (tab bar and Yes/No), not a "tab-hover debounce/flag"; the grid loops only reset it. (h) **Use tab**: entering it writes `inventoryEquippedIndex = 0` (non-negative placeholder so the cursor shows), it was described as "clear equipped slot"; the tab has no cancel (`$C000` = A or B confirms). (i) **Spawn counter**: `inventoryTabIndex` is the slot actors' spawn counter during the first yield; the second `STZ` is what restores tab 0. (j) **Grid moves**: Left/Right do not wrap within the row (column 3 + 1 = next row, column 0). (k) **Discard**: `itemAbilityIndex` feeds the name string; `CheckItemDiscardable` takes the ID in A; the prompt is "Discard? No / Yes" with the cursor on No (`$28 = 0`); empty/protected slots play SFX `#12`. (l) **`ArrangePerformSwap` equipped tracking**: after `UpdateSlotActorSprite` Y is the slot ACTOR, so `TYA; CMP inventoryEquippedIndex` compares an actor address with a slot index and never matches; only "the source slot was equipped" follows the item (OQ-I028-2). (m) **`ArrangePickTarget`** tests `$8044`, widened by `transforms.json`, so X and Y also confirm the target (OQ-I028-1). (n) The `$2040` blank tile in notes is `$2060` in this baserom (transform on `LDA #`); texts now avoid the literal. (o) `PositionGridCursor`'s second entry `loc_02EA46` has no caller; the "bits 2-3 / 4-5" description referred to the value after the x4 shift | FIXED (all of the above in the notes and comments) |
| Q4 | M | Mask operands were annotated with the wrong buttons; `$0B00` / `$0700` explained incorrectly | FIXED (comments) |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | `StatusCharRow3/2/1` number the rows bottom-up and suggest a character; `code_02E6AA` is the discard attempt; `system_strings.item_table_separator` is the non-discardable bit table | PROPOSED (R-I028-1 to R-I028-3) |
| Q7 | M | E1 + E2 for masks, storage layout, flag tests, strings and the dead equipped branch; the effect of the widened swap mask, the dead branch and the `$2060` tile are static conclusions | DEFERRED-EVIDENCE (OQ-I028-1 to OQ-I028-5) |

### File 2: thinkers/oneshot_palette_flash_1C.asm (Bank 00)

Evidence: E1 (`PaletteStart #1C`, `PaletteStep`, `KillThinker`; bundle `#1C` decoded from the ROM), E2 (`cop_handlers_palette`; spawn sites `mu/mu_prayer_room/mu63_spirits`, `edward_castle/castle_prison/ec0B_cell`, `angkor_wat/snake_pit/awB4_snake_pit_entry`, `gold_ship/ship_gold/gs2C_descent`, `gs2C_crow_crew`), E3 none.

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A two-line note and no comments | FIXED (block note, 2 comments) |
| Q2 | M | "Flash" hid that it is a 160-tick fade | FIXED |
| Q3 | **F** | Bundle `#1C` is one strip of 32 three-byte frames (4 extra ticks, 160 ticks) that drive the backdrop COLDATA triplet (`$7F0C00`): R, G and B fall together from 31 to 0, a white-to-black fade; it is the counterpart of `#1B`. It is only visible while color math is enabled. Spawn sites listed (Mu after `#1B`, Edward prison, Angkor snake pit entry, Gold Ship descent, crow-crew scene) | FIXED |
| Q4 | NA | Bundle ID is a literal | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | "palette flash" names a palette write; it fades the fixed color out | PROPOSED (R-I028-4) |
| Q7 | M | E1 + E2; what the player sees in each scene depends on the scene's color-math setup, not traced | DEFERRED-EVIDENCE (OQ-I028-6) |

### File 3: thinkers/oneshot_palette_flash_1B.asm (Bank 00)

Evidence: E1 (`PaletteStart #1B`, `PaletteStep`, `KillThinker`; bundle `#1B` decoded), E2 (`cop_handlers_palette`; spawn sites `mu63_spirits` (twice) and `ec0B_cell`), E3 none.

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A two-line note and no comments | FIXED (block note, 2 comments) |
| Q2 | M | The note did not say it is a long ramp | FIXED |
| Q3 | **F** | Bundle `#1B` is one strip of 32 three-byte frames (4 extra ticks, 160 ticks) on the backdrop COLDATA triplet: black rising through yellow (red and green climb first, blue stays 0 until the middle) to almost white; it is the fade-in that `#1C` undoes in Mu | FIXED |
| Q4 | NA | Bundle ID is a literal | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | Same naming issue as `#1C` | PROPOSED (R-I028-4) |
| Q7 | M | E1 + E2; scene-level visuals not traced | DEFERRED-EVIDENCE (OQ-I028-6) |

### Shared gate (I028)

`npm run merge -- edits/I028.json --dry-run` first reported five warnings (comment texts containing the `$8000` literal that a `transforms.json` rule could rewrite); the texts were reworded ("confirm bit"), the dry run is clean, the merge applied: 3 block notes, 30 part notes (all updates), 65 comment entries (12 new, 53 updated). The thinker notes for `1B` and `1C` were prepared together with I027 and moved into this spec. A second dry run (after `npm run extract:lt`) reports 0 files to change. `npm run extract:lt` OK and the notes render in `extracted/`. `npm run rebuild` (after I027 and I028): success, `artifacts/crc.json` = checksum 223006080, crc 2083230829, totalSize 3062204.

Patches that touch the same labels (`baserom/collectible-system/RelicMenu.patch.asm`, `baserom/options-menu/EnhancedInvItemPicker.patch.asm`) reference `code_02E47F` / `StatusCharRow*`; they were not read for this iteration and must be checked before any rename in R-I028-2 / R-I028-3.

Suggested commit message: `audit(I028): rewrite inventory_menu button/frame model, hover-preview and slot-storage notes, document the dead equipped-index branch and widened swap mask; rewrite palette fade 1B/1C thinker notes`

Please commit when you're ready.
