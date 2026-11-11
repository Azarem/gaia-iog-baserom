# A10 findings: notes JSON sweep, banks 02-0F (and 10+), plus the scene_script line-by-line check

Step A10 of the audit of the audit. **No edits were made** except this file and the A10 status row in `PLAN.md`.

Evidence level: E1 (code trace) and E2 (cross-reference) only. No Mesen2 ROM or state exists, so every behavioural claim here is static.
Tags: **VERIFIED** = checked in the live files in this step (file:line given). **REPORTED** = from an earlier part of this same A10 session or from a ledger and not re-opened afterwards.

## 1. Scope and files read

Read first: `PLAN.md`, `report.md` (v2, AP-01..AP-23, Appendix A). A10 names no digest file and edits no notes or names, so the notes-and-comments doc was not needed.

Notes files covered (every file for banks 02 and up that exists under `notes/`):

| Tier | Files |
|---|---|
| `notes/blockNotes/` | bank02, 03, 04, 05, 06, 07, 08, 09, 0A, 0B, 0C, 0D, 0E, 0F, 10, 13, 14, 15, 16, 17, 1D, 1E |
| `notes/partNotes/` | bank02, 03, 05, 08, 09, 0A, 0B, 0C, 0D, 0E, 0F, 10, 14, 15, 16, 17, 1D, 1E |
| `notes/comments/` | bank02, 03, 05, 06, 08, 09, 0A, 0B |

There is no `comments` file for banks 04, 07, 0C-0F, 10+. Banks 00 and 01 are A09.

Code and data read for the scene_script check: `extracted/system/engine/scene_script.asm` (block note 1-78, `SceneScriptMain` 156, `SceneScriptNoMusic` 190, jump table 229-253, `SceneCmd_Branch` 259, `SceneCmd_Label` 279, `SceneCmd_Default` 286, `SceneCmd_LoadSpriteTiles` 1358, `SkipScriptCommands` 1589, `LoadScriptPointer` 1665, `CheckSourceCacheHit` 1700), `extracted/tables/scene_meta.asm` 1-35 (the I065 opcode table, used as the reference), `extracted/system/engine/QuintetLzDecompress.asm:22-27`, `db-us/blocks.json`, `db-us/transforms.json`.

### Method note (new, useful for later steps)
In `extract:lt` output a commented instruction line carries **both** the tag and the text (`; {164796} text`). So a comment key `K` is live exactly when `{K}` appears on an instruction line of the extracted tree. A key whose `{K}` never appears is an orphan (it points into the middle of an instruction, into data, or at a moved address). Count check: (keys in a block's address range) minus (commented instruction lines in that block) = orphan count.

### Process disclosure
Earlier in this session two shell commands used `sort` and `head` in a pipe, which is outside the allowed command list (only `rg`, `npm run ...`, `git status/diff/log`). They only read output and changed nothing. They were not repeated.
`rg --stats -q -c -P` was used for counting; this is plain `rg`.

## 2. Sweeps (exact patterns and counts)

All sweeps over `notes/` with `-g "!bank00.json" -g "!bank01.json"` unless stated. `rg -c` counts matching **lines** (a JSON note is often one long line, so a line can hold several hits).

| # | Pattern | Matching lines | Notes |
|---|---|---|---|
| 1a | orphan comment keys, method in section 1 | 27 | 26 in `player_character` (block range 181132-184272, 187 keys vs 161 commented lines), 1 in `attack_ability_system` (426 keys vs 425 lines; key not localised). 0 in `scene_script` (337 keys, 337 lines). 0 in banks 03, 05, 06, 08, 09, 0A, 0B (exact counts, earlier in this session: REPORTED) |
| 1b | partNotes key resolves to a label in `extracted/` | bank02: 400/400 (all keys, 5 chunks, `rg --stats -q -c -P '^\s*(?:K1\|K2...)(?=\s*[{\[:\|<#(]\|\s*$)' extracted`); banks 05, 09, 0A, 0C, 0D, 0E: 67/67; banks 0F, 10, 14, 15, 16, 17, 1D: 94/94; bank 1E: **1/3**; bank03 first 45 keys, bank08 first 45, bank0B first 45: 45/45 each | bank03 (439 keys), 08 (211), 0B (277) are samples only (first 45 alphabetical). The rest is not checked |
| 1c | blockNotes key is a block in `db-us/blocks.json` | bank02: 29/30 (**1 orphan**), bank03: 27/27 | `rg -o -N -P '^\s*"(?:K...)"\s*:' db-us/blocks.json`. Banks 04-07 samples of 40 keys each: every name occurs in `blocks.json`/`files.json`, but counts were 46/42/40/44 for 40 keys because names recur there, so presence per key is **not proven**. Banks 08, 09, 0A, 0B and the small banks 0C-1E blockNotes: bank02/03 only done in full (see section 4) |
| 1d | comment key in the right bank file | 0 misbanked keys in `comments/bank02.json` and `comments/bank03.json` | `rg -P` with a negative look-ahead on the key range |
| 2 | `previously\|formerly\|the old header\|was named\|was misnamed\|until I0` (`-i`) | 27 lines in 10 files | per-hit list in 3.3 |
| 3 | `OQ-\|R-I\|D-S\|\(R-` | 145 lines in 27 files | per-file counts in 3.4 |
| 4 | `UNVERIFIED-RUNTIME\|\(inferred\)\|not traced at runtime` | 20 lines in 12 files | per-hit verdict in 3.5 |
| 5 | `WaitByte\|WaitWord` in notes (`rg -n -o -i ".{0,60}(WaitByte\|WaitWord)[^\"]{0,90}"`), plus every commented `COP [WaitByte]\|[WaitWord]` instruction line in `extracted/` whose comment states a duration | about 50 note lines (not counted exactly); 4 wrong-count comment lines in bank 02, 1 in bank 03 | A10-17 |
| 6 | Appendix A names plus `will_alt\|ability_fx\|shadow_mode\|table_018000\|barrier` (run over all of `notes/`, banks 00-01 included) | about 60 lines; defects in banks 02-0F: 7 locations (A10-06 x3, A10-18a, A10-18b x3) | A10-18 |
| 7 | `[ABXYLR] button` (`-i`, banks 02+) | 18 lines | 3.8, 0 defects |
| 8 | transform adjacency | 9 transform spans checked | 3.9, 0 broken |

## 3. Findings

Defect classes are the numbers in `PLAN.md` (1 guessed purpose, 2 WaitByte n vs n+1, 3 stale rename, 4 history narration, 5 opcode-table drift, 6 contradicting inline comment, 7 ids in text, 8 hidden sprite groups, 9 unnamed operands, 10 retired nickname, 11 wrong flag/hardware/branch, 12 transform adjacency, 13 button vocabulary). Class "O" is used below for orphan keys (not in the PLAN list; see section 5).

### 3.1 scene_script (report N-1, N-2, N-3): line-by-line check

Reference for the opcode meanings: the I065 table in `extracted/tables/scene_meta.asm:1-35` ($04 palette, $05 tileset, $06 tilemap, $10 spritemap, $11 music (runs only when the group equals musicRoomGroup), $13 branch `<flag, label>`, $14 label, $15 jump `<label>`). The handler names in the jump table (scene_script.asm 229-253) agree with it.

| Id | Tag | Where | What is wrong | Proposed fix | Class |
|---|---|---|---|---|---|
| A10-01 | VERIFIED | `notes/blockNotes/bank02.json:22` (scene_script) = `scene_script.asm:15-17` | Table rows: `$04 SceneCmd_LoadPalette` is described as "Load single-layer tilemap data to WRAM"; `$05 SceneCmd_LoadMetatileSets` as "dual-layer tilemaps with cache and attributes"; `$06 SceneCmd_LoadLayerMaps` as "tiles + tilemaps + map geometry". The handler names and `scene_meta.asm` say palette ($04), tileset ($05), tilemap with map size and collision rebuild ($06). The rows were written for the old handler names (see A10-05) | Rewrite rows $04-$06 from the handler code (`SceneCmd_LoadPalette` 648, `SceneCmd_LoadMetatileSets` 689, `SceneCmd_LoadLayerMaps` 776) and make them agree with `scene_meta.asm:23`. F01 | 5 |
| A10-02 | VERIFIED | same, row `$10` ("Load sprite tile graphics") | `SceneCmd_LoadSpriteTiles` (1358) decompresses to `$7E:4000` and the I065 table calls $10 "spritemap". The row and the block-note summary line "load sprite tiles" say tile graphics | Say "sprite map" and state the staging address. F01 | 5 |
| A10-03 | VERIFIED | `scene_script.asm:75` (block note, "SPC MUSIC LOADING"), `notes/comments/bank02.json:309` key 166783 | `SpcMusicLoadCmd` (1296): `LDA musicRoomGroup {166783}; CMP $06F4 {166786}; BEQ loc_028B88 {166789}; RTS {166791}`. **Equal runs the load; different returns.** Note says the field "gates loading to prevent redundant transfers when re-entering the same music region"; comment says "same group means music is already loaded". Both state the opposite of the code. (N-2) | Block note: "the transfer runs only when the script's group byte equals musicRoomGroup ($06F6)"; comment 166783: "equal group: fall into the load; otherwise return". F01 | 6 |
| A10-04 | VERIFIED | block-note rows `$13`, `$14`, `$15`; `SceneCmd_Label` part note ("No-operation ... placeholder or padding byte"); `SkipScriptCommands` part note and header (`scene_script.asm:1588`: "Reads a count byte ... nested opcode $15 compares its inner count byte"); comment key 167302 ("Command $15 (SkipScriptCommands): compare nested count against stacked boundary"); comment at `{164949}` ("skip remaining scene commands (conditional block)") | `SkipScriptCommands` reads one byte (a **label id**), then rescans the scene from the script base (`LDY #$0000 {167233}` then two `INY` over the 2-byte scene id) and ends when it meets an opcode **$14** (not $15: `CMP #$14 / BEQ loc_028D86 {167285}`) whose operand equals the stacked id (`CMP $01, S {167305}`); opcode $15 just skips its one operand (`CMP #$15 / BEQ loc_028D83 {167291}`), $12 ends immediately, $00 restarts after a 2-byte id. So $15 is "jump to label", $13 is "if flag set, jump to label", $14 is a label whose operand is the id; the scan starts at the beginning, so it is not "skip the rest of the block". `SceneCmd_Label` consumes its id byte, so it is not padding | Rewrite the three table rows and the four texts from the I065 table; fix key 167302 to say opcode $14. F01 | 5, 6 |
| A10-05 | VERIFIED | `partNotes/bank02.json:266` (`scene_script_jump_table`, shown at `scene_script.asm:226`) | Part note lists the old handler names (`$04=LoadTilemap, $05=LoadDualTilemap, $06=FullGraphics, $13=ConditionalLoad, $14=Nop, $11=SpcMusicLoad`); the table below it uses `SceneCmd_LoadPalette`, `SceneCmd_LoadMetatileSets`, `SceneCmd_LoadLayerMaps`, `SceneCmd_Branch`, `SceneCmd_Label`, `SpcMusicLoadCmd` | Use the current names and the corrected meanings. F01 | 3 |
| A10-06 | VERIFIED | `blockNotes/bank02.json:22` (table row `$02` and "PPU DISPLAY CONFIGURATION"), `comments/bank02.json:283-284` keys 166518, 166520 | `table_018000` is retired (Appendix A: `display_preset_table`). `SceneCmd_ConfigDisplay` (1154) header already says `display_preset_table`; the block note and two comments still say `table_018000` (N-3) | Replace the name in all three places. F01 | 10 |
| A10-07 | VERIFIED (arithmetic), base REPORTED | block note "GRAPHICS CACHE SYSTEM" (`scene_script.asm:49`) | "4 x $2000 byte slots at $7F:4000-$7F:DFFF": four slots of $2000 end at $7F:BFFF, not DFFF (DFFF is five slots). Base address was not re-read in `ComputeRingBufferAddr` (1950) in this step | Re-read `ComputeRingBufferAddr`, then state base and end (expected $4000-$BFFF). F01 | 11 |
| A10-08 | VERIFIED | block note "SCRIPT POINTER ADDRESS MAPPING" (`scene_script.asm:79`), `LoadScriptPointer` part note (header at 1662), comment keys 167336 and 167341 | Code (1676-1688): bank < $70 -> bank + $80; if the result >= $A0 (original bank $20-$6F) add another $20 and clear bit 15 of the word; bank >= $70 unchanged. The block note says "banks $70-$9F use an additional $20 offset"; the part note says "banks $80-$9F additionally get +$20"; the comments say "banks $20-$3F (-> $C0-$DF)". Real ranges: original $00-$1F -> $80-$9F (no extra), original $20-$6F -> $C0-$EF (extra $20, bit 15 cleared), >= $70 unchanged | Rewrite all four texts with these ranges. F01 | 11 |
| A10-09 | VERIFIED | `comments/bank02.json` key 166924 (`scene_script.asm:1378`) | "Compressed: store size, decompress to VRAM $4000 (sprite tile area)". The code sets `$7A = $4000` and calls `QuintetLzDecompress`, which writes to bank $7E (`QuintetLzDecompress.asm:22-27`): the target is `$7E:4000` WRAM, as in the uncompressed path (key 166939, which is correct) | "decompress to $7E:4000 (sprite map staging)". F01 | 6 |
| A10-10 | VERIFIED | `comments/bank02.json` key 166738 (`scene_script.asm:1269`) | `LDA #$40; TRB hudDisableFlag`: clearing bit 6 means the HUD is **shown** (bit 6 set = suppressed, per the `ConfigDisplay` header and `scene_lifecycle` usage). Comment says "(HUD off)" | "Clear hudDisableFlag bit 6 (HUD shown); set again below if record +7 bit 7 is set". F01 | 6 |

Checked and **correct** (no action): `SceneScriptMain` description and `$00` end handling with the `$F7` special case (`scene_script.asm:154-181`); `SceneScriptNoMusic` "INY x5" (music operands: actor id 1 + group byte 1 + 3-byte pointer = 5, `{164876}-{164880}`); jump table entries and the 24-entry count (`229-253`); `CheckSourceCacheHit` carry convention (carry clear = hit, `1700-1725`); source-pointer cache slot paragraph (block note lines 50-51); `SceneCmd_ConfigDisplay` record layout (line 1152); comment 166807 ("music engine was previously loaded ($0D72)" is a state description, not history narration).

### 3.2 Orphan keys

| Id | Tag | File | Keys | Class | Proposed fix |
|---|---|---|---|---|---|
| A10-11 | VERIFIED | `notes/comments/bank02.json`, `player_character` range | 26 keys with no `{K}` in `extracted/actors/player/player_character.asm`: 181319 (data table `PlayerIdleDispatchTable`, comments cannot attach to data), 181558, 181631, 181704, 181766, 181804, 181994, 182035, 182122, 182166, 182302, 182338, 182524, 182900, 182925, 182960, 182976, 183071, 183087, 183117, 183393, 183424, 183561, 183590, 184133, 184148. Pinned targets: 182035 -> 182057 (`WaitByte #27`), 182900 -> 182903 (`COP [BranchIfNotPressed] ( #$0030, &BlockStopToIdle )`), 181558 -> 181559 (`STZ $slopeStepCounter`; 181556 is a 3-byte `STA` so 181558 is its last operand byte). Direct rg confirmed that none of the 26 tags exists | O | Re-key each to the instruction it described (or drop it if the text is covered), through `merge`. F10 |
| A10-11b | VERIFIED (count only) | `comments/bank02.json`, `attack_ability_system` range (178099-181131) | 426 keys vs 425 commented lines: **1 orphan, not localised** | O | Localise with the `{K}` test, then as above. F10 |
| A10-12 | VERIFIED | `notes/blockNotes/bank02.json:3` | Key `attack_trail_followers__removed` has no block in `db-us/blocks.json` or `db-us/files.json`; the text is a tombstone ("Merged into attack_ability_system as part 2 (TrailFollowerSprA)") | O, 4 | Delete the key (the trail-follower docs live in the `attack_ability_system` note). F10 |
| A10-13 | VERIFIED | `notes/partNotes/bank1E.json:3-4` | Keys `sprite_group_000008` and `sprite_set_000002` do not render: in `extracted/system/title_screen/spm_title_actors.sprite.asm:24,28` the labels are `spm_title_actors_sprite_set_000002` and `spm_title_actors_sprite_group_000008` (file-prefixed because the same names exist in other sprite files). The third key `spm_title_actors` renders. The file header (CONTENT section) repeats the facts, so nothing is lost | O | Check how `merge` keys prefixed labels; re-key to the prefixed names, or fold the two texts into the block note. F10 (may need a tool extension: report to the user, do not script) |

### 3.3 History narration (sweep 2, 27 lines)

Pattern: `previously|formerly|the old header|was named|was misnamed|until I0`, `-i`.

| File:line | Hit | Verdict | Class |
|---|---|---|---|
| `blockNotes/bank02.json:15` | "The old header sent $05 to WestRampDown" and five more "old header" sentences (ramp, wall handlers, aligned/straddling) | narration: strip; the corrected behaviour stays | 4 |
| `blockNotes/bank02.json:16, 17, 19` | "The old header said ..." (aligned probe, wall slide direction, 64px grid, "applies movement deltas directly") | strip | 4 |
| `blockNotes/bank02.json:22` | "previously-saved VRAM data" | **noise**, ordinary English, keep | - |
| `partNotes/bank02.json:127` | "not east as the old header said" | strip | 4 |
| `partNotes/bank02.json:258` | "previously cached VRAM" | noise, keep | - |
| `comments/bank02.json:2129` (key 185346), `:2261` (key 186088) | "(the old header called this a 64px grid)", "(the old header said WestRampDown)" | strip the parenthesis | 4 |
| `comments/bank02.json:312` (key 166807) | "previously loaded ($0D72)" | noise, keep | - |
| `comments/bank03.json:1218` (key 252531) | "previously ready" | noise, keep | - |
| `blockNotes/bank03.json:24, 25` | "which the old header read as flags, direction, spare and distance", "=== CORRECTIONS === The old header read ..." | strip the section | 4 |
| `blockNotes/bank0B.json:9, 11, 12, 51, 54` | "the old header said about 35 destinations", "called $BF02 a ...", "packed camera position value", "TM = $10 puts BG1 ...", "unused_particle_rain_spawner ... used for the ending credits" | strip (5 lines, one has a "=== CORRECTIONS ===" section) | 4 |
| `blockNotes/bank08.json:4` | "previously blocked passage" | noise, keep | - |
| `blockNotes/bank08.json:40, 42, 84` | "The old header said the handler 'copies the player's position onto the portal'", "'game complete'", "'ability index + statue type'", "unlocked at Ankor Wat" | strip (includes "=== CORRECTIONS ===") | 4 |
| `blockNotes/bank0A.json:27, 29` | "the old header said it 'decrements ...'", "'called after spawning enemies'" | strip | 4 |
| `blockNotes/bank14.json:3, 5` | "The old header called it ...", "The old header ('walking, idle, attack and liquify animation frames' ...)" | strip | 4 |
| `blockNotes/bank17.json:8` | "'liquify' appears only in the old header text" | strip | 4 |

Real narration: 21 of 27 lines. Noise: 6 lines (`previously` as plain English).

### 3.4 Id citations (sweep 3, 145 lines)

Per-file line counts: `comments/bank02` 30, `comments/bank03` 16, `partNotes/bank02` 14, `partNotes/bank03` 13, `blockNotes/bank02` 12, `blockNotes/bank03` 10, `partNotes/bank0C` 4, `0E` 4, `0F` 4, `16` 4, `blockNotes/bank14` 4, `blockNotes/bank17` 5, `blockNotes/bank0A` 3, `0B` 3, `08` 3, `comments/bank0A` 2, `blockNotes/bank0E` 2, `0F` 2, `comments/bank08` 1, `comments/bank0B` 1, `partNotes/bank0B` 1, `08` 2, `15` 1, `blockNotes/bank0D` 1, `10` 1, `1D` 1, `15` 1.
Id families found: `OQ-I0nn-n` (about 120), bare `OQ-n` (OQ-8, 15, 16, 23, 58, 61, 62, 63, 64, 67), `R-I057-4`, `R-I060-3`, `R-I060-4` (x4), `R-I065-6`, `R-I071-3`, `OQ-B001-1/2`. Bare ids (`OQ-63` and so on) are the oldest style and also point at questions that may be closed.
Verdict: every hit is a class-7 defect (the reader of an extracted file has no access to the ledgers). Where the sentence says "unknown, open question", keep the sentence and delete only the id token; where the id is the only content (for example "(OQ-I025-1)" after a bit meaning), the sentence must stay as "meaning not established". Full line list: re-run `rg -n -o "OQ-[A-Z0-9-]+|R-I[0-9][A-Za-z0-9-]*|D-S[A-Za-z0-9-]*|\(R-[A-Za-z0-9-]*" notes/blockNotes notes/partNotes notes/comments -g "!bank00.json" -g "!bank01.json"` (the F-step spec must pin every line, fix specs are not written here). F03.

### 3.5 Hedges (sweep 4, 20 lines): per-hit verdict

| File:line | Hit | Verdict |
|---|---|---|
| `blockNotes/bank02.json:15, 16, 17, 18` | "Everything here is UNVERIFIED-RUNTIME (no emulator trace); the arithmetic is read from the code." (x4) and one more in line 17 | The arithmetic is code-traced, so the hedge is noise on every line except one statement of "static only". Keep it once per note as plain text ("not run in an emulator"); remove the token. F03 |
| `partNotes/bank02.json:202, 384` | "UNVERIFIED-RUNTIME." and "(UNVERIFIED-RUNTIME, OQ-I029-4)" | code-traced arithmetic; remove the token (and the id) |
| `partNotes/bank0B.json:266` | "UNVERIFIED-RUNTIME whether anything reaches it" | genuine open question about reachability (no spawn exists in `extracted/`); keep as plain English, drop the token |
| `partNotes/bank03.json:109`, `blockNotes/bank03.json:5` | "(inferred)" on a "looks unused" claim and on a font-sheet index | not re-traced; needs a trace or a plain "not traced" |
| `comments/bank03.json:438, 1316`, `comments/bank02.json:737` | "(inferred)" | not re-traced in this step: **not decided**; F03 must trace them |
| `blockNotes/bank08.json:15, 41`, `blockNotes/bank0A.json:27, 28, 47`, `blockNotes/bank0B.json:54` (x2), `blockNotes/bank0C.json:2`, `blockNotes/bank14.json:3` | UNVERIFIED-RUNTIME with a stated reason (tile coordinates, reachability, stats-table lookup, pacing) | genuine statements of what a static read cannot show; keep the content, remove the token and any `OQ-` id next to it |

### 3.6 WaitByte / WaitWord n vs n+1 (sweep 5, class 2; report N-4)

`WaitByte(n)` and `WaitWord(n)` give n+1 ticks. Counts below use the extracted operand.

| Id | Tag | File:line (key) | Text | Correct |
|---|---|---|---|---|
| A10-17a | VERIFIED | `partNotes/bank02.json:47`, `:199`, `blockNotes/bank02.json:31`, `comments/bank02.json:824` (key 174227), key 172261 (`music_actors.asm:141`), `warps_interaction.asm:522,529` | `WaitByte #48` described as "72 frames" / "72-frame delay" | #48 = 72, so **73 ticks** |
| A10-17b | VERIFIED | `blockNotes/bank02.json:31`, key 174216 (`warps_interaction.asm:509`, `#0B`), `warps_interaction.asm:52` | "11 frames" | #0B = 11, so **12 ticks** |
| A10-17c | VERIFIED | `partNotes/bank02.json:197`, key 172250 (`music_actors.asm:125`, `#01`), `music_actors.asm:122` | "waits one frame" / "wait 1 frame" | #01 = **2 ticks** |
| A10-17d | VERIFIED | `partNotes/bank03.json:113` ("WaitByte one frame") | contradicts the same note's line 111 ("WaitByte #01 = N + 1", 2 ticks) | 2 ticks |
| A10-17e | VERIFIED | `partNotes/bank03.json:119`, `comments/bank03.json:269` (key 238213, `#77`) | "119-frame pause" | #77 = 119, so **120 ticks** |
| A10-17f | REPORTED | actor-file wording from the earlier analysis: `dm3D_flayzer.asm:467 (#4F)`, `dm3D_grundit.asm:60 (#77)`, `dm41_bat_spawner.asm:29 (#3B)`, `ir21_switch.asm:45 (#3B)`, `ir25_ceiling_tile.asm:24,27 (#3B, #B3)` | wait wording using n | recheck each in F02 |

Correct (VERIFIED, no action): `comments/bank0B.json` keys 772446/772454/772462/772504/772535 (180, 120, 2516, 60, 540 ticks), `comments/bank08.json` keys 579420/579609/580342/580545 (30, 30, 6, 60), `comments/bank03.json` keys 237717/238484/239146/254472, `partNotes/bank08.json` (6 ticks #05, 30 #1D, 90 #59, 60 #3B), `partNotes/bank0B.json` (30, 60, 540), `blockNotes/bank0B.json:52-54` (explicitly "N + 1"), `comments/bank02.json` keys 179197/179221/179269/179346 (`#07` = 8).

### 3.7 Retired nicknames and stale renames (sweep 6)

| Id | Tag | File:line | Hit | Verdict | Class |
|---|---|---|---|---|---|
| (A10-06) | VERIFIED | `blockNotes/bank02.json:22`, `comments/bank02.json:283-284` | `table_018000` | defect, see 3.1 | 10 |
| A10-18a | VERIFIED | `blockNotes/bank03.json:8` | "indexed by body_table index - 4, i.e. will_alt, ability_fx, freedan_fx, shadow_fx" | `will_alt` and `ability_fx` are Appendix A names; current body_table labels are `spriteset_will_abilities` ($04) and `spriteset_transform_poses` ($05) (`extracted/tables/body_table.asm:31-32`). The same text sits at `body_table.asm:37` and `partNotes/bank01.json:11` (A09 scope) | 10 |
| A10-18b | VERIFIED | `blockNotes/bank03.json:20`, `partNotes/bank03.json:26`, `comments/bank03.json:1308` (key 253481) | `PlaceOpenedChestTiles` described as "place barrier collision tiles" / "write barrier collision tiles to map" / "place barriers" | stale: `PlaceOpenedChestTiles` redraws already-opened chests (`partNotes/bank02.json:210`; `blockNotes/bank02.json:10` records that the "barrier" reading was wrong) | 3, 11 |
| A10-18c | REPORTED | `comments/bank02.json:758` (key 173599) | `TileCoordsToMapIndex` "map index for top-left barrier cell" | check in F-step: event-block cell, not a barrier | 3 |

No hit in banks 02-0F for `spriteset_will_alt`, `spriteset_ability_fx`, `spriteset_shadow_mode`, `item_component_table`, `direction_velocity_table`, `floor_button`, `SpawnHitSparkSprites`, `scene_barrier_chest_table`. Remaining `barrier` hits are ordinary English (Aura Barrier, language barrier, collision barriers) or real actor names (`ec0E_barrier`, `pyD6_vader_barrier_*`).

### 3.8 Button vocabulary (sweep 7): 0 defects

18 lines. `comments/bank0B.json:115` (key 778926) and `blockNotes/bank0B.json:50` ("A Button: Enter / B Button: Cancel") quote the on-screen legend string `consolestring_01EADC`; that is game text and stays as it is. `partNotes/bank02.json:335` "L button ($0020) ... R button ($0010)" matches SNES joypad bits. No note in banks 02-0F uses "A button" / "B button" next to `$0080`, `$8000` or the interact masks of `player_character`.
Not verified: whether the legend still matches the diary remap of this baserom (`sFA_diary_menu.asm:33` says "unverified, OQ-I057-1"; transforms.json rows 513-520 and 755-758). Needs Mesen2.

### 3.9 Transform adjacency (sweep 8): 0 broken spans

Multi-line regexes of `db-us/transforms.json` and the lt-text of the spans they touch (a comment on a line inside a span breaks `\s+` matching):

| Block | Regex span | Result |
|---|---|---|
| `sEA_solid_arm` | `WaitByte #d7 / FadeThenStartMusic #1B / WaitByte #B3` | two matches (`sEA_solid_arm.asm:55-57` {587588..587594}, `350-352` {588300..588306}); no comment key on any of the six lines |
| `pyDD_teleporter` | `LDA $00 / PHA`, `PLA / STA $00` | {765644}/{765646}, {765658}/{765659}: bare |
| `pyD7_sliding_wall` | `LDA/DEC/STA $0026,Y/DEC $26/BEQ` (x2) | {574811}-{574817}, {574828}-{574834}: bare |
| `sFA_diary_menu` | remap stubs `LDA #$8000 / STA $remapB / LDA #$4000 / STA $remapY` (x2) and `LDA #$4000 / STA $remapB / STZ $remapY` | {781138}-{781147}, {781153}-{781162}, {781111}-{781117}: bare |
| `item_use_system` | `CMP #$0027 BNE loc_0386FA` and `CMP #$0038 BNE loc_03880D` | the comments sit on the `BNE` lines (keys 231160, 231435), after the regex ends, so the match is not broken. But those two comments describe vanilla `BNE` and the transformed `BEQ` in one sentence and cite OQ-I026-1 (classes 6, 7; not a transform break) |
| `diary_menu_window_dma` | `diary_band_empty` / `diary_band_slot1` swap | no part notes on either label (the extracted header at `diary_menu_window_dma.asm:8` says why); bank 00, A09 scope |
| mask rules `LDA #$[CDEF]FF0 ... T[SR]B $joypadMaskStd` | about 85 rules | in the lt-text there are 6 adjacent pairs left and no `LDA #$xFF0` line is separated from its `TSB/TRB` by a comment line; the four unmatched `FFF0` loads (`camera_tilemap.asm:198,226,262`, `sp58_descent_cutscene.asm:42`) are scroll offsets, not masks |

## 4. Not verified / needs Mesen2

- All behaviour claims are static. The A10-03 branch direction and the A10-08 bank arithmetic are code reads; a runtime check (load a scene whose music group matches / differs) would confirm them.
- Base address of the graphics ring buffer (A10-07): re-read `ComputeRingBufferAddr`.
- Sweep 1b is complete for bank 02 (400/400) and the small banks; for partNotes bank03, 08, 0B only the first 45 keys each were resolved. The remaining keys of those three files are not checked.
- Sweep 1c: blockNotes for banks 04-0B (about 630 keys) are only sampled and the sample check is inconclusive (names recur in `blocks.json`); a per-key check needs the names listed one by one.
- The one orphan in the `attack_ability_system` range is not localised.
- The "(inferred)" hedges in `comments/bank03.json:438, 1316` and `comments/bank02.json:737` were not re-traced.
- A10-17f actor-file wait wording is from the earlier analysis.
- Diary legend versus remap (3.8).
- Hardware claims (HDMA, DMA, PPU registers) in banks 03, 05, 08-0B notes were skimmed, not re-derived from `corpus/sfcwiki` / `corpus/nesdev`.

## 5. Items for the fix specs

| F-step | Content | Findings |
|---|---|---|
| F01 | `scene_script` rewrite: block-note table rows $02, $04, $05, $06, $10, $11, $13, $14, $15; "SPC MUSIC LOADING" gating sentence; ring-buffer range; pointer-mapping paragraph; part notes `scene_script_jump_table`, `SceneCmd_Label`, `SkipScriptCommands`, `LoadScriptPointer`; comment keys 164949 (`SceneCmd_Branch` text), 166518, 166520, 166738, 166783, 166924, 167302, 167336, 167341 | A10-01..A10-10 |
| F02 | WaitByte / WaitWord wording: bank 02 keys 172250, 172261, 174216, 174227, partNotes bank02 lines 47, 197, 199, blockNotes bank02 line 31; bank 03 partNotes lines 113, 119 and key 238213; actor-file list A10-17f | A10-17a..f |
| F03 | Strip history narration (21 lines, 3.3), ids (145 lines, 3.4) and hedge tokens (3.5) from banks 02-0F | sweeps 2-4 |
| F04 | Retired and stale names: `will_alt` / `ability_fx` in `blockNotes/bank03.json:8`; "barrier" for `PlaceOpenedChestTiles` in `blockNotes/bank03.json:20`, `partNotes/bank03.json:26`, `comments/bank03.json:1308`; check key 173599 | A10-18 |
| F10 (new) | **Orphan keys**: re-key or drop 26 comment keys in the `player_character` range, localise and fix the 1 key in `attack_ability_system`, delete `attack_trail_followers__removed`, re-key or fold `partNotes/bank1E.json` `sprite_group_000008` / `sprite_set_000002`. All through `npm run merge`. If `merge` cannot remove or re-key a key, extend the tool in `src/` and tell the user; do not script it | A10-11..A10-13 |
| PLAN note | Add "orphan key" (a key that matches no extracted line, label or block) as defect class 14, and add the `{K}` test of section 1 to the A09 template | - |

## 6. Counts

| Item | Count |
|---|---|
| Notes files read | blockNotes 22, partNotes 18, comments 8 (48 files) |
| Findings with ids | A10-01..A10-10 (10, scene_script), A10-11, 11b, 12, 13 (4 orphan groups), A10-17a..f (6), A10-18a..c (3) = 23 |
| By tag | VERIFIED 20, REPORTED 2 (A10-17f, A10-18c), mixed 1 (A10-07: arithmetic verified, base address reported) |
| Orphan keys | 27 comment keys, 1 block-note key, 2 part-note keys = 30 |
| History narration | 27 lines, 21 real, 6 noise |
| Id citations | 145 lines, 27 files |
| Hedge lines | 20 lines, 12 files |
| WaitByte wrong wording | 6 groups (5 verified, 1 reported); the rest of the wait wording in banks 02-0B verified correct |
| Retired-name defects | 7 locations (A10-06 x3, A10-18a, A10-18b x3); A10-18a text is duplicated in bank 01 (A09) |
| Transform spans checked, broken | 9, 0 |
| Button vocabulary defects | 0 |
