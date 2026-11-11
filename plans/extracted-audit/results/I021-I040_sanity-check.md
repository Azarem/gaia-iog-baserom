# Sanity check of iterations I021–I040 — 2026-10-27

Scope: the 60 files of I021–I040 (29 of them still contained surviving original comments), their notes under `notes/`, the ledgers, and the gate. Method: scripted structure, notes, code-integrity and reference scans; targeted greps for phrases that later iterations corrected; then a line-by-line re-read of every surviving ORIGINAL comment in the audited files (1,708 comments) by read-only subagents in two rounds. **Every subagent candidate was re-checked by me against the code before anything was applied**; subagent claims were wrong often enough that none was applied on trust. Fixes were applied only through `npm run merge` (spec below); verification only through `extract:lt` and `rebuild`.

Companion files: [I021_results.md](I021_results.md) … [I040_results.md](I040_results.md), [../renames/sanity-I021-I040_renames.md](../renames/sanity-I021-I040_renames.md), [../questions/sanity-I021-I040_questions.md](../questions/sanity-I021-I040_questions.md), template: [I001-I020_sanity-check.md](I001-I020_sanity-check.md).

## Verdict

Structure, ledgers and code are sound: no instruction, operand or label changed anywhere, and the ROM CRC is unchanged. The first-pass notes (block notes, part notes, the comments rewritten during each iteration) held up. The defects were in the **surviving original comments next to rewritten ones**: 73 comments plus 5 part notes and 1 block note contradicted the iteration's own findings, were attached to the wrong instruction, or described the other branch path. All are fixed. Nothing is left open from this pass except the follow-ups listed under "Observations".

## Checks that passed

- **Structure:** each of I021–I040 has a results section (Q1–Q7 for every file), an `edits/I0nn.json`, a `renames/I0nn_renames.md`, a `questions/I0nn_questions.md`, and a ticked checklist line. File lists match `checklist.md` (60 files, 0 missing, 0 duplicated).
- **Ledger integrity:** rename IDs (`R-I0nn-k`) and open-question IDs (`OQ-I0nn-k`) are unique and contiguous per iteration; every ID cited inside a note or comment exists.
- **Notes match the asm:** all 20 specs applied cleanly when replayed on the freshly extracted tree (0 changes) before the corrections below. `ingest:dry` after the corrections reports exactly the baseline set (the unmerged `MenuSelectionHandler` proposal, OQ-59, and the two bank-key quirks `bank0B` / `bank09`); the new corrections add nothing to it.
- **Code integrity:** plain `npm run extract` equals `HEAD` for all 909 files (comments, tags and `---` stripped). The 5 files that differ between plain `extract` and `extract:lt` are the known OQ-I026-1 (multi-line `transforms.json` regexes do not match when `; {addr}` tags sit between the lines): `sEA_solid_arm`, `pyDD_teleporter`, `pyD7_sliding_wall`, `sFA_diary_menu`, `item_use_system`. Not an audit effect.
- **Identifiers cited in notes exist** (labels, DP/WRAM names; only shorthand like `loc_` forms differ).
- **Gate after the corrections:** `npm run extract:lt`, then `npm run rebuild`: `artifacts/crc.json` = checksum 223006080 / crc 2083230829 / totalSize 3062204 (unchanged). Re-running the sanity spec in dry-run mode reports 0 changes (idempotent). All 73 corrected comments were read back from the extracted `.asm` and match the spec text.

## Defects found and fixed (spec `edits/sanity-I021-I040.json`)

Counts: **73 comments, 5 part notes, 1 block note, 20 files.** Grouped by cause; each group lists its tags.

| # | Cause | Where (tags in `{}`) | Problem → fix |
|---|-------|----------------------|---------------|
| 1 | **`WaitByte(n)` = n+1 ticks, stated as n** | `attack_ability_system` {179197} {179221} {179269} {179346}; `hdma_dma_spc` {254472}, block note, part `SpcTransferMusicData`; `item_use_system` {237717}, part `FluteMusicActorController` | "Wait 7 frames" and "one-frame delay" for `WaitByte #07` / `#01`. `RunActors_*` decrements `$08` and resumes when it goes negative, so the delays are 8 and 2 ticks (`cop_handlers_wait` says so; the I021 and I026 notes did not carry it over) |
| 2 | **`TileProbeMain` carry = nonzero type, not "blocked"** | `tile_collision` {188704} {188720} {188826} {188835} {188872} {188908} {188978} {189022} {189098} {189157} {189165} | Eleven comments said "blocked / blocking" for a carry that is set for any nonzero type (slopes, ladders, wall types), contradicting the I030 block note. Reworded; {188720} also drops the "passable override" reading (it is a row-above test that can only add a block) |
| 3 | **Comment describes the other branch or the wrong instruction** | `cop_handlers_sprite` {40879} {40931} {40950} (on `BCC`, text described the carry-set fall-through); `player_move_diag` {188360} (on `BCC`, text described the fall-through); `map_coords` {176534} {176538} ("Right cell" after `MapCellDown`); `vblank_joypad` {163974} {163986} (the `AND #$1F` is on the high byte, two lines later); `player_character` {183340} (comment for the north slider sits on the end of the south slider); `hdma_gradient_thinker` {392663} | Reworded to say which path each instruction takes |
| 4 | **Stale versus the iteration's own findings** | `spc_transfer` {168161} {168163} {168187} {168189} {168193} {168200} {168221} {168237}; `hdma_dma_spc` {254148} {254424} {254503} {254532}; `player_move_south` {186010}; `player_move_diag` {187341} {187817} {188167} {187835}; `player_move_ramps` {186687} {186953}; `player_move_south` {185650}; `map_coords` {176542} {176625} | `spc_transfer`: the surviving comments still described "sub-blocks / finalizer / bank wrap" instead of the sample-library chunk walk (bit 7 = empty slot, `$2A` = chunks left to skip, `[$4A],Y` reads the library at `$C5`). `hdma_dma_spc`: `$F0` was "transfer-start" (it is CmdStop), sub-entry is 6 mixed bytes (not three words), `SpcBlockTransfer` is the IPL byte protocol (not DMA), the `music_pointer_array` offset is (ID−1)×3. Player-move: `FineAdjustXWest` moves EAST (comment said west), the dual-wall snaps round to 16-px lines (the old text said 8-px grid / "sub-column"), `EastRampUp` descends (Y grows with X), `ClearSpeedNS_3` applies no movement, the MapCellDown in the Y-straddle path starts from the future-TL cell, and the dual-wall branch comments pointed to the wrong `code_` targets. `map_coords`: "(right movement)" on {176542} and "(left movement)" on {176625} are wrong: `ProbeRightTiles` is called only by `DispatchDiagDownLeft`, `ProbeLeftTiles` only by `DispatchEastMove` (this completes R-I039-4 item 5) |
| 5 | **"movement sub-state" for actor `+$08`** | `player_move_diag` {187456}; `player_move_east` {186253}; `player_move_ns` {184549} | `+$0008` is the wait counter that `RunActors_*` decrements; reworded |
| 6 | **Wrong field, flag or unit named** | `player_character` {181203} ($0800 is the script/ability lock, not "block state"), {181934} ($08 is the staged frame's hold time moved to $24); `slope_ramp_physics` {177579} (the curve negation pushes the west slope toward negative EW speed, not "deceleration"); `attack_ability_system` {179689} (bit `$4000` is off-screen, not a wall) and {178660} (clears the attack-request bit, it does not free the player: `$0800` stays set until `PlayerIdleEntry`) and {178681} (kills the palette FX actor); `item_use_system` {230634} ("SpawnLastRel": it is `SpawnListAppend`), {236338} (`STA $0024,Y` is the spawned actor's field, not the current DP), {231920} (Wind Melody fallback: scene mismatch or flag `$01` branch); `inventory_overlay` {192006} (NMI is on only for the fade-in wait) and {192210} (`DEC` is accumulator-implied, not `DEC $00EA`); `inventory_menu` {190170}; `QuintetLzDecompress` {164667} (mask `>= $10` = 5 or more bits left); `hdma_gradient_thinker` {392801} (bit 0 of `chatPtr`, not frame parity) | One-line rewrites |
| 7 | **`cop_handlers_sprite` operand text** | {39394} {39398} {40651} {40696} {40807} {40815}; `cop_handlers_player_sprite` {41200} | `ResetSpriteState` second operand is the VRAM word address (the spriteset-pointer text was left from the original); `StageSpriteLoopMove*` operands are anim byte, repeat count and movement *index* (not "distance"); bit 7 of the anim byte selects the mirrored variant, not a "direction-aware mode" |
| 8 | **Part / block notes** | part `AttackSystemEntry` (two sentences); part `TrailPositionInit`; part `DiagPushRight` | `AttackSystemEntry` still said `CheckAttackChargeable` "gates charge progression via hitstun/death/combo state" (it tests `playerFlags $8000` and the body animation index) and that fragments run "until wall contact" (they die when off-screen, flag `$4000`). `TrailPositionInit` seeds the FIFO with the **follower's own** `$14/$16` and is called by the shared follower entry, not "the player position when the attack begins". `DiagPushRight` still said `player_move_east` describes the push as upward, but I040 rewrote those notes; now says the east notes agree (UNVERIFIED-RUNTIME, OQ-I029-4 stays open) |

## Candidates examined and rejected (no change)

Kept here so a later reviewer does not re-raise them.

- **"Diameter 0 to 64" in the Aura Barrier block note** was flagged as wrong; it is correct (`CMP #$0040` is 64 decimal).
- **Grouped comments**: a comment on the first instruction of a group (`SEP #$20` / `REP #$20` + pushes; `LDX #$..` before the `MVN` it describes; `PHP` + `SEP`; the `LDA`/`TCD` pair) is the established style of this codebase; not changed (about 15 candidates).
- **`item_use_system` {231846}** (Gold Ship scene / flag test on an `LDA`), **{236063}** (flag chain), **{237490}**, **{237520}** (`musicParentActor` meaning not provable), **{237728}**; **`player_character`** {182097} (the "shake for $26 frames" text is right, `ClimbDropLand` stores `$3C` there; the sound re-entry question is OQ-SAN2-1), {182916}, {183052}, {183257}; **`WestRampUp`** {186758} ("ascend": the `$05` surface does rise toward east and `$26` decreases, so the word is right here); **`player_move_east`** {186208} {187096}, **`player_move_ns`** {184511}; **`inventory_menu`** {190930} {191266} {191345}; **`stair_climb`** {53716}, **`cop_handlers_metatile`** {38691}.
- Subagent claims that mixed up units were rejected after checking the code (quarter-pixel `$22/$26` versus whole-pixel actor `$14/$16`).

## Revisions to earlier result documents

The results files are not edited. Where they state something this pass revised:

| Document | Statement | Revised to |
|----------|-----------|------------|
| [I021_results.md](I021_results.md) Q3 (f) | "`COP WaitByte #01` is a one-frame delay" | A two-tick delay (N+1); still not an SPC acknowledgment |
| [I039_renames.md](../renames/I039_renames.md) R-I039-4 item 5 | `ProbeLeftTiles` / `ProbeRightTiles` are "used by both horizontal dispatchers" | Each is called by exactly one dispatcher (`DispatchEastMove` and `DispatchDiagDownLeft` respectively); the inline "left/right movement" comments are fixed here, so item 5 is DONE |
| [I029_results.md](I029_results.md) Q3 / `OQ-I029-4` | DiagPushRight direction contradicts `player_move_east` | Unchanged and still open, but the east notes were rewritten in I040 and now agree with the arithmetic (down); the part note says so |
## Observations, deliberately not changed

- `MenuSelectionHandler` PROPOSED spec (OQ-59) is still unmerged; it is the only non-sanity item in `ingest:dry`.
- Cross-file items outside I021–I040, left for the iteration that owns the file (details in the questions and renames files):
  - `system_core` block note item 3 and the comment on `STA $MEMSEL` ("Enable FastROM"): `InitHardwareRegisters` writes `MEMSEL = 0` last, so boot leaves SlowROM until `sFB_boot_logo` enables it (already documented in I024 Q3(f) and its open question; the `system_core` text is the stale side).
  - `dm3F_laborer` line 3 says `displayModeFlags ($0E)`: `$0E` is the actor's own DP field, not WRAM `$09EC` (iteration I148).
  - `player_move_main` {184936}: "X sub-tile in right half (CheckSubTileAlignX carry)" does not say which carry value that is (carry set = straddling); check in I045.
- `extracted/` is currently `extract:lt`-tagged (every instruction carries `; {addr}`). Run a plain `npm run extract` if untagged files are wanted before committing; the OQ-I026-1 five-file difference then disappears.
- Earlier specs `edits/I021.json` … `edits/I040.json` are one-shot records: replaying them now would overwrite the 73 corrected comments with the older text. Replay `sanity-I021-I040.json` last if the notes are ever rebuilt from the specs.

## Process notes for the next range

- Rewriting a routine's block and part notes without re-reading its surviving inline comments leaves contradictions behind. For I041+ run the survivor check at the end of each iteration (list the untouched original comments of the audited files and test them against the new notes).
- Facts that bite repeatedly and should be in every reviewer's head: `WaitByte(n)` = n+1 ticks; `BCC` branches on carry **clear**; `TileProbe*` carry = nonzero type; hex literals in comments (`$40` is 64).

## Suggested commit message

```
audit(sanity I021-I040): fix 73 stale/misattached comments and 5 notes (WaitByte N+1, TileProbe carry, SPC chunk walk, player-move snaps), add sanity ledgers
```

Please commit when you're ready.
