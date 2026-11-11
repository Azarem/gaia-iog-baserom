# I059 - 2026-10-28 - files: system/world_map/WorldMapController.asm, system/world_map/spm_overworld_sprites.sprite.asm, system/world_map/world_map_names.asm
Status: COMPLETE

Spec: [edits/I059.json](../edits/I059.json). Proposals: [renames/I059_renames.md](../renames/I059_renames.md). Questions: [questions/I059_questions.md](../questions/I059_questions.md).

Conventions: verdicts **P/M/F/NA**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 coverage and verbosity, Q2 value, Q3 accuracy, Q4 mnemonic and variable names, Q5 new mnemonic, Q6 naming, Q7 evidence quality. Annotation style as in I049 to I058: aggregated notes, a part note for every label that matters, inline comments only for operands and non-obvious steps.

### system/world_map/WorldMapController.asm (1 actor-def, 2 more actors, 1 thinker-like callback, 3 helper routines, 2 tables, 673 lines before / 623 after, Bank 03 238321-239290, parts: 11 code / 4 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 40-line header, 11 part notes and about 150 comments, but no part notes for the sub-labels, no description of how a trip starts, and the Mode 7 words appear only as raw `$00B6` / `$00B8` / `$00BC` operands | E1 |
| Q2 value | M | The header told the story of a "falling player" and an "iris"; it never said that the map is Mode 7 and that the controller drives the zoom, tilt and rotation words | E1, E2 |
| Q3 accuracy | **F** | (a) **"gravity drop / player falls onto map / altitude / elevation / ascent / expansion"**: `$00B8`, `$00B6` and `$00BC` are the global Mode 7 words of `Mode7PerspectiveUpdate` (starting divisor = zoom, per-scanline divisor growth = perspective, rotation index). The 44-tick loop makes `$B8` fall from `$0400` to about `$34` (a zoom-out); the 93-tick loop grows `$B6` to about `$03F0` (the map tilts into perspective); the route steps change `$BC` (the map rotates); the end of the route flattens `$B6` by `$10` per frame and then dives (`$B8` grows). (b) **"spawn HdmaWindowEffect ... for the iris/spotlight transition"** and the `Iris` wording: it is the BGMODE/COLDATA split of I058 (R-I058-3). (c) **Phase 2 "poll $0D5A: when nonzero the route is active and this actor yields each frame"** is reversed: the actor yields while `$0D5A` is zero (the menu is open) and continues when the chosen handler has set it. (d) **"If no destination: land directly, spawn location name ..."**: the tilt phase and the start name run for every trip; the name is the scene being left (`$0D6F`), the end name is the destination (`$0D6E`). (e) **`$0D6E/$0D6F` "Deferred scene ID (low = ID, high = area flags)"**: `$0D6E` low byte is the destination scene, `$0D6F` the scene being left (written by `ExecuteSceneTransition`; `DeferSceneTransition` stores the low byte only). `$0D5A` is a route id, not a flag. (f) **`$FFF0` mask**: the shipped constant is `$FFFC` (`transforms.json` widens the vanilla `$FFF0`). (g) **`LDA #$2000 / TRB $10` "re-enable Select-related processing"**: bit 13 is the script-driven actor mode that `CopyActorState` forces on; clearing it makes the leader behave like the `$1800` dots. (h) **`STZ $00DA` "shared animation state"**: `$00DA` is the byte count of the sprite-text buffer at `$7F0600` that `pr_text_placement_calc` fills; zeroing it removes the on-screen name. (i) **Route byte meaning** ("Byte 1 step type ... Z movement delta ... elevation"): the three bytes are `movement_delta_table` indices for X (`$00CA`), Y (`$00CC`) and rotation (`$00BC`), then a tick count. (j) **`SetEntryHereAndYield` "SetEntryExit for reentrant landing"** just saves the re-entry point and yields. (k) **"palette thinkers, double-buffered"** is not supported by the code (reason for the second spawn unknown). (l) **`pr_actor_0BCF52`** is `pr_text_placement_calc`. (m) **`LookupMapName` "table end (zero byte)"**: the table has no terminator entry. (n) **companion layouts**: the scan starts at `$0D62`, entry 6 of the table is unreachable, entry 4 duplicates the first five pairs of entry 0 | E1 (the file; `cop_handlers_effects` InitGravity/TickGravity; `mode7_perspective`; `pr_text_placement_calc`; `actor_pool`/`actor_execution` for `$2000` and `$04`/`$06`; `cop_handlers_spawn`), E2 (`scene_lifecycle` for `$0D52`-`$0D6F`; `overworld_exit`, 13 NPC scripts for the staging; `HdmaWindowEffect` header for the menu wait), E3 (`docs/code/bank03/mode7-and-cutscenes.md`) |
| Q4 mnemonic/var names | M | `$00B6`, `$00B8`, `$00BC`, `$00CA`, `$00CC`, `$00DA`, `$0D6C`, `$0D6E`, `$0D6F` and the party array have no mnemonics | PROPOSED R-I059-3 |
| Q5 new mnemonic | M | The Mode 7 words are used by seven files; mnemonics would help all of them (logged, not added) | R-I059-3 |
| Q6 naming | M | Sixteen `loc_03A...` labels in the control flow and three `binary_03A5xx` tables | PROPOSED R-I059-1, R-I059-2 |
| Q7 evidence quality | M | E1 + E2 + E3. The deltas of the two gravity loops were computed by hand (about -970 and about +1,010); nothing was run | E1, E2 (UNVERIFIED-RUNTIME: OQ-I059-1, -2, -4, -5, -6) |

Actions taken: block note rewritten (trip start, state block, Mode 7 words, a 7-step timeline, the sprite animations, key routines); 21 part notes (11 new, 10 rewritten, 1 of them for the world-map names file); 64 inline comments (13 new, 51 rewritten); no mnemonics added.
Deferred: R-I059-1, R-I059-2, R-I059-3 (names, mnemonics), R-I059-5 (docs).
Before/after stats: 673 to 623 lines (`wc -l` of the lt output before, plain count after; the old header and comments were longer); generic labels remaining: 26 (`code_03A2F4`, `loc_03A35C` ... `loc_03A6B6`, `binary_03A511`/`521`/`525`; the control-flow ones are described in part notes, the small branch targets are not).

### system/world_map/spm_overworld_sprites.sprite.asm (1 pointer list of 14 animation sets, 894 lines, parts: 0 code / 17 data)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | F | No block note and no part notes | E1 |
| Q2 value | F | Nothing says what the 14 animations are or who selects them | E1, E2 |
| Q3 accuracy | NA | There was nothing to check | E1 |
| Q4 mnemonic/var names | NA | Data only | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | `sprite_set_00001C` and its siblings are offset names; the 14 sets have no role names | PROPOSED R-I059-4 |
| Q7 evidence quality | M | E1 + E2; the art of each animation was not run | E1, E2 (UNVERIFIED-RUNTIME: OQ-I059-3) |

Findings (carried here and in the `WorldMapController.asm` block note because the file cannot take notes): `scene_meta_00FE` (`scene_meta` line 3001, `spritemap < #$1238, #00, @spm_overworld_sprites >`, with `gfx_overworld_actors` and `pal_overworld_sprites` at colour `$90`) loads it. The animation index is the party-array word that `WorldMapController` writes to actor field `$28`. Animations 0-5: four frames, hold 7. 6: three single-part frames. 7-A: four sets of five frames (hold 7, 9 on one frame); `wa79_neil` fills the array with 7, 8, 9, A, and the menu handlers write `$0D60 := 7` before the Watermia to Euro legs, so these look like one multi-part vehicle. B: three frames of 24-28 parts (leader of the Dao to Over Babel scripted trip). C: same shape, no writer found. D: four frames, hold 9 (leader of the Watermia to South Cape scripted trip). Which character art animations 1-5 are was not checked.
Actions taken: none in this file: **the merge script cannot attach notes to `.sprite.asm` files** (`cannot determine the ROM bank of this file`; the same tooling gap as R-I055-5 and I058).
Deferred: R-I059-4; a tool fix (read the bank from `scene_meta` or accept a `?BANK` for sprite files).
Before/after stats: 894 lines, unchanged; generic labels remaining: all (17).

### system/world_map/world_map_names.asm (1 table of 37 `map-label` entries + 33 strings, 128 lines before / 134 after, Bank 03 242132-242689, parts: 0 code / 1 data table + strings)

| Q | Verdict | Findings | Evidence |
|---|---------|----------|----------|
| Q1 coverage/verbosity | M | A 14-line header with the location list; no part note, no account of who looks the names up | E1 |
| Q2 value | M | It listed place names but never said what the key byte is or when the names appear | E1, E2 |
| Q3 accuracy | **F** | (a) **"Location ID byte (matches WorldMapController position index)"** and **"mapping world map location IDs"**: the byte is a scene id (`sceneCurrent` / `sceneNext`); the controller looks up the scene being left (`$0D6F`) and the destination (`$0D6E` low byte). (b) The header did not say that the table has no terminator entry, that the ids come from two kinds of trips, or that eight ids ($31 $67 $68 $95 $9F $AD $C5 $DE) are used by no trip found in `extracted/` (the old "37 named locations" list was right). (c) The sprite strings are built by `pr_text_placement_calc` (not an OAM-string renderer of its own) | E1 (`LookupMapName`, `pr_text_placement_calc`), E2 (`overworld_exit` exit scenes; 13 NPC trip scripts; `scene_lifecycle`) |
| Q4 mnemonic/var names | NA | None needed | E1 |
| Q5 new mnemonic | NA | None needed | E1 |
| Q6 naming | M | `world_map_names` / `map-label` say "location", not "scene"; two strings with the same text exist at `03B3B9` and `03B3CC` | PROPOSED R-I059-4 |
| Q7 evidence quality | M | E1 + E2; the 8 unused ids were established by search only | E1, E2 |

Actions taken: block note rewritten (format, which ids are looked up, shared names, string format); 1 part note (new); no comments (data); no mnemonics added.
Deferred: R-I059-4.
Before/after stats: 128 to 134 lines; generic labels remaining: 0 for code, 33 `spritestring_...` offset names.

### Iteration summary

- Files: 3 audited (1 not editable by the tooling). Q3: 2 F, 1 NA. Notes written: 2 block notes, 22 part notes (21 + 1), 64 inline comments.
- Patterns: (1) a Mode 7 parameter read as a sprite movement ("falls", "altitude", "elevation", "expansion"); (2) a hypothesis name (iris) carried through two files; (3) a poll condition read backwards (`BNE` at the menu wait); (4) a table key described as a position index when it is a scene id; (5) raw bank-0 words with no mnemonics (`$00B6`, `$00B8`, `$00BC`, `$00CA`, `$00CC`, `$00DA`); (6) a data file the note tooling cannot reach (sprite files, third time).
- Docs repeating old claims (logged in R-I059-5): `docs/code/bank03/radar-and-world-map.md` (the `$0D52/$0D53` wording, `HdmaWindowEffect` as a sine/window effect, the route-step field meaning, the `$FFF0` mask, the "iris" wording).
- Gate: `npm run merge -- plans/extracted-audit/edits/I059.json` (dry-run first), `npm run extract:lt`, the I059 spec dry-run to 0 files to change, `npm run rebuild`: checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged).
- Spec: `plans/extracted-audit/edits/I059.json`.
- Suggested commit message: `Audit I059: world map controller (Mode 7 zoom/tilt/rotation, trip flow), scene-id name table`

Please commit when you're ready.
