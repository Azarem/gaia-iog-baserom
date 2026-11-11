# I071 - 2026-10-28 - files: tables/spriteset_shadow_mode.asm, tables/scene_chest_table.asm, tables/inventory_spritemap.asm
Status: COMPLETE

Spec: [edits/I071.json](../edits/I071.json). Proposals: [renames/I071_renames.md](../renames/I071_renames.md). Questions: [questions/I071_questions.md](../questions/I071_questions.md).

Conventions: verdicts **P/M/F/NA**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 coverage and verbosity, Q2 value, Q3 accuracy, Q4 mnemonic and variable names, Q5 new mnemonic, Q6 naming, Q7 evidence quality. Annotation style as in I049 to I070. `inventory_spritemap.asm` is **SAMPLED ~45%** for line-by-line review (the pointer table, the sets of all 77 indices, the first and last groups and the two groups that hide extra data); every count and the byte reconciliation were computed over the whole file. The sprite-set struct is documented once, in the `spriteset_freedan` block note of I063.

The checklist names the second file `scene_barrier_chest_table.asm`; the file (and block) is `scene_chest_table.asm`. The name in the checklist is stale.

### tables/spriteset_shadow_mode.asm (1 table of 3 pointers, 3 frame lists, 23 groups, 273 lines before / 303 after, Bank 17 1556480-1557571, parts: 0 code / 27 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 3-line header and no part notes; no counts, no animation roles | E1 |
| Q2 value | F | Named no animation, no caller and no byte budget | E1 |
| Q3 accuracy | **F** | **"Shadow's special mode sprites ... unique movement and combat modes"**: there is no such mode. The set is body_table row `$08`, and the only code that selects it is `PlayerAuraTransformEntry` (`player_transition_handlers`, entered from `item_use_system.UseItem_Aura` when Shadow uses the Aura item standing still); the frames are the "body turns to water" effect (the item text, `item_description_table` `$24`). The `body_table` part note of I061 claimed that nothing selects row `$08`: also wrong | E1 (`PlayerAuraTransformEntry`, `PlayerAuraBlockedBySolid`, `PlayerAuraLandAnimLoop`, `UseItem_Aura`), E2 (`body_table`) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | `spriteset_shadow_mode` suggests a game mode that does not exist; the Aura item is the context | PROPOSED R-I071-1 |
| Q7 evidence quality | P | Whole file read; the byte arithmetic reconciles (6 + 6 + 220 + 299 + 560 = 1091); all three callers traced. The art and palette were not viewed | E1, E2 (UNVERIFIED-RUNTIME: OQ-I071-1, OQ-I071-2) |

Actions taken: block note rewritten (owner, three animations with callers, byte budget); table part note and 3 set part notes and 2 group part notes (new); `body_table` part note for rows `$04` and `$08` corrected through an `edit` entry; no inline comments (data); no mnemonics added.
Deferred: R-I071-1; OQ-I071-1, OQ-I071-2.
Before/after stats: 273 to 303 lines; generic labels remaining: 26.

### tables/scene_chest_table.asm (1 pointer table of 255, 40 lists with 46 records, 432 lines before / 505 after, Bank 01 109992-110726, parts: 0 code / 41 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 2-line note without the field order or the terminator rule; no counts | E1 |
| Q2 value | F | No reader named, no per-scene content | E1 |
| Q3 accuracy | **F** | (a) **"barrier/chest placement", "event-blocking barrier tiles"**: the table holds chests only; `PlaceOpenedChestTiles` draws opened chests, it writes no barrier. (b) **"flag byte, bit 7 = end sentinel"**: the list ends on a first byte (X) with bit 7 set; bit 7 of the flag byte means "open with the fanfare" (`ChestOpeningActor`). (c) **Content "item ID or tile index for barriers"**: item ID or 0 = flag-only chest (shows "It is empty!"). (d) **"Most scenes point at a $FF"**: 216 of 255 entries share one empty list `chest_entry_01AFA6`, which is a single `$FF` byte. (e) The Y byte is the chest's bottom row, not its position | E1 (`PlaceOpenedChestTiles`, `HandleChestInteraction`, `CheckWarpAndChest`, `ChestOpeningActor`, `radar_map_screen`), E2 (counts over all 255 words and 46 records), E3 (`docs/bank01-data-tables.md` §7 repeats the barrier claim) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | `scene_chest_table` is right; the 40 lists are offset-named `chest_entry_*`, one of them the empty list | PROPOSED R-I071-2 |
| Q7 evidence quality | P | Whole file read; every record decoded and written into the block note (46 rows, 39 scenes); the three readers read in code; the byte count reconciles (734 = 510 for 255 pointers + 46 x 4 for the records + 40 `$FF` terminators). The flag-only chests of scenes `$60`/`$61` and the out-of-sequence flag `$2E` are unexplained | E1, E2 (UNVERIFIED-RUNTIME: OQ-I071-3) |

Actions taken: block note rewritten (record format, the three readers, the chest tile numbers, a full content table of all 46 records, counts, byte check); table part note rewritten and 6 list part notes (`chest_entry_01AFA6`, `01AFA7`, `01AFC9`, `01AFD3`, `01B010`, `01B019`, new); no inline comments (data); no mnemonics added.
Deferred: R-I071-2, R-I071-4 (the stale text in the docs and in `scene_lifecycle`); OQ-I071-3.
Before/after stats: 432 to 505 lines; generic labels remaining: 40.

### tables/inventory_spritemap.asm (1 table of 77 pointers, 77 frame lists, 129 labelled groups, 1296 lines before / 1325 after, Bank 10 1081344-1085191, parts: 0 code / 207 data) SAMPLED ~45%

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 4-line header; no index map, no counts | E1 |
| Q2 value | F | Said nothing about which index shows what | E1 |
| Q3 accuracy | **F** | **"cursor sprites, tab indicators and equipment display"**: indices `$00`-`$3F` are the item icons (the animation index of an `InventorySlotActor` is the item ID in its slot, `$28` hides it), every index except `$41`-`$43` is accounted for in the block note, so no index is left for tab indicators or a cursor. The block also hides 5 groups (see Q6/Q7) that the extraction prints as extra sub-sprites | E1 (`InventoryMenuInit`, `inventory_statue_slot`, `statue_inventory_reward`, `InventoryCounters.patch.asm`), E2 (counts) |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | The 129 groups and 77 lists are offset-named; the groups at `108B67` and `108BAA` swallow 5 unlabelled groups | PROPOSED R-I071-3 |
| Q7 evidence quality | M | Table, all list heads and the byte budget were computed over the whole file (3847 = 154 + 154 + 600 + 1677 + 1267 - 5); the per-group art was not compared with the item names; `$41`-`$43` are not traced | E1, E2 (UNVERIFIED-RUNTIME: OQ-I071-4, OQ-I071-5, OQ-I071-6) |

Actions taken: block note rewritten (index roles, readers, the unlabelled groups, byte check); table part note and 2 set part notes and 2 group part notes (new); no inline comments (data); no mnemonics added.
Deferred: R-I071-3; OQ-I071-4, OQ-I071-5, OQ-I071-6.
Before/after stats: 1296 to 1325 lines; generic labels remaining: 206.

## Iteration summary

Files audited: 3 (one sampled, ~45%). Q3 verdicts: 3 F. Notes written: 3 block notes and 18 part notes, plus an `edit` of the existing `body_table` part note. Six notes files changed (`blockNotes/bank01.json`, `bank10.json`, `bank17.json`; `partNotes/bank01.json`, `bank10.json` (new), `bank17.json`).

Patterns:
- Both purpose claims that failed (`spriteset_shadow_mode`, `scene_chest_table`) were made from the block name, not from a reader: a "mode" that does not exist, and "barrier" for what is a chest list. The code readers were one search away in `extracted/`.
- The hidden-group artefact (the extraction labels only referenced groups and prints every following byte as extra sub-sprites) was first logged for `spriteset_ability_fx` (I067) and is found here in `inventory_spritemap`: the groups at `108B67` and `108BAA` hide 2 and 3 groups. Decoding the 67 and 80 bytes by hand shows that the 13th byte of each group header equals its sub-sprite count (7 of 7 groups: the 2 labelled parents and the 5 hidden ones), which would let the extraction stop at the right place (R-I071-3).
- An earlier note (I061 `body_table`) was corrected by a later iteration; `edit` entries are not repeatable (a re-run reports `find` occurs 0 times).

Docs repeating old claims: `docs/bank01-data-tables.md` lines 21, 199-208 and 692 (`scene_chest_table` as "barrier/chest placement"), `docs/code/README.md` line 241; the comments in `extracted/system/engine/scene_lifecycle.asm` (lines 32, 767, 864) call `PlaceOpenedChestTiles` "place barrier collision tiles". All logged as R-I071-4.

Tooling: `npm run extract:lt` failed (`rm: cannot remove 'extracted/tables': Device or resource busy`, a process had the directory open). The extraction was run directly (`node --env-file=.env.local src/index.ts extract --linetracking`); all 37 table files regenerated. The dry-run of the spec is unchanged except for the `body_table` `edit` entry, which reports an error on a repeat run (expected).

Gate: `npm run rebuild` passed: checksum 223006080, crc 2083230829, totalSize 3062204 (`artifacts/crc.json`), identical to the baseline.

Suggested commit message: `Audit I071: spriteset_shadow_mode, scene_chest_table, inventory_spritemap notes`
