# I042 results

Files: `actors/overworld_exit.asm` (Bank 00), `functions/SpawnHitSparkSprites.asm` (Bank 00), `actors/floor_button.asm` (Bank 00).
Spec: [edits/I042.json](../edits/I042.json). New proposals: [renames/I042_renames.md](../renames/I042_renames.md). New questions: [questions/I042_questions.md](../questions/I042_questions.md).

Conventions (unchanged): verdicts **P/M/F/NA**; dispositions **FIXED / PROPOSED / DEFERRED-EVIDENCE / NOFIX**; evidence **E1** code trace, **E2** cross-reference, **E3** docs, **E4** hardware, **E5** runtime (always UNVERIFIED-RUNTIME, no Mesen2 in this session). Q1 comment density, Q2 value, Q3 accuracy, Q4 mnemonic/address accuracy, Q5 mnemonic opportunity, Q6 part naming, Q7 evidence quality.

### File 1: actors/overworld_exit.asm (Bank 00)

Evidence: E1 (the whole file read end to end; `StageWorldMapChoice` and `BranchIfPlayerInAbsTiles` handlers; `WorldMapController` header and arrival code; the `world_map_options` pointer table and the first dialog string of every entry `$00`-`$1B`; `CheckSceneTransition` as described in the `cop_handlers_world_map` header), E2 (all 15 spawn records from `scene_actors`; scene ids resolved to area folders; `SetFlagByte` setters searched for each gate flag; `UseItem_LanceLetter` for flag `$8E`), E3 (`actors-player-rewards.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A paragraph header, 5 inline comments and 15 handlers with no explanation of the numbers | FIXED (block note with flow, exit table and quirks; 46 part notes; 208 comments covering every instruction) |
| Q2 | M | A reader could not tell what a choice id, the start coordinates or the flag gates mean | FIXED |
| Q3 | **F** | (a) **The third operand of `StageWorldMapChoice` is a destination-menu id** into `world_map_options` (dialogs "Quit / Edward's Castle" and so on); all 15 exits, their zones, start positions, gate flags and menus are now tabulated. (b) **Priority order**: where two flags are tested the later-story one comes first (Watermia `$94` before `$8E`, Euro `$AC` before `$9F`, Native Village `$B6` before `$B1`, South Cape `$26` before `$25`). (c) **Flag meanings**: `$8E` = Lance's Letter used, the others are set by the NPC scripts named in the note. (d) **Three menu ids ($09, $15, $1B) are "Quit" only** (Freejia before `$65`, Angel Village before `$8D`, South Cape after `$25`). (e) **Zone test**: `BranchIfPlayerInAbsTiles` tests (player X, player Y - 8), strict at the minimum edge and inclusive at the maximum, in tiles x 16; South Cape and Edward's Castle use a pixel test on `playerYPos` instead (`< $10` and `== $2D0`). (f) The handlers do not "fall through" to the exit handler, they `JMP` to `OverworldExitFinalize`. (g) `$0D60` is the first word of the six-word companion array, and `gfxCacheIdxB := $0400` is set on every path; neither effect was traced | FIXED |
| Q4 | M | Hex scene ids, tile corners and start coordinates were bare operands | FIXED (comments on every compare, jump, zone test and staging call) |
| Q5 | M | `$0D60` is a bare absolute operand in 27 places | PROPOSED (R-I042-4) |
| Q6 | M | The suffixes `East`, `North`, `South`, `Default`, `Enter` on the staging labels are not directions | PROPOSED (R-I042-3) |
| Q7 | M | E1 + E2; whether Edward's Castle row `$2D0` is reachable, what `$0D60` / `gfxCacheIdxB` do and whether flag `$01` is ever cleared were not run | DEFERRED-EVIDENCE (OQ-I042-5 to OQ-I042-8) |

### File 2: functions/SpawnHitSparkSprites.asm (Bank 00)

Evidence: E1 (the whole file; `GiveItemToPlayer` special-item branch; `SpawnListAppend`, `LoopStart` / `LoopEnd`; `oam_digit_compose` for the compose-buffer entry format and cursor), E2 (`rg` for every reference: one spawn site in `inventory_mgmt`; the chest and `GiveItem` operands in `extracted/` searched for item ids `$86` and up), E3 (`field-input-and-items.md` line 392 already says `$86+` spawns it).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A three-line header and no comments | FIXED (block note, 2 part notes, 35 comments) |
| Q2 | M | The header did not say who spawns it or what it draws | FIXED |
| Q3 | **F** | (a) **Two compose-buffer entries per frame** (X - 4 / tile `$327A`, X + 4 / tile `$327B`, both at Y = `$16`), not "four tile entries"; the cursor advances by `$0C`. (b) **Timeline**: 8 frames at the spawn position, then 16 frames rising 1 pixel per frame (24 in all). (c) **Sole spawn site is `GiveItemToPlayer`** for special items with effect index 6 or more (item `$86` and up, which also adds 5 to `hpToHeal` and plays sound `#22`), not "inventory-screen hit feedback" and not critical hits as `functions-combat-defeat.md` says; there is no random scatter and no 4-frame lifetime. (d) The tile attribute `$3200` is the same as the damage digits | FIXED |
| Q4 | P | Mnemonics and operands are as annotated (`oamWriteOffset`, `oamComposeBuffer`) | NOFIX |
| Q5 | NA | `oamWriteOffset` ($00D8) is the existing mnemonic for the compose cursor | NOFIX |
| Q6 | M | The name suggests combat hit sparks; the only caller is an item effect | PROPOSED (R-I042-1) |
| Q7 | M | E1 + E2; reachability of item ids `$86+`, the actor whose position is copied and the look of tiles `$7A/$7B` are open | DEFERRED-EVIDENCE (OQ-I042-1, OQ-I042-2) |

### File 3: actors/floor_button.asm (Bank 00)

Evidence: E1 (the whole file; `SetHitCallback` and the `onHitCallback` dispatch in `combat_collision` at the `$7F1000` read; `$12` bit uses `$0001` / `$0010` / `$0020` in the same file; `MarkSolidHere`; `SetFlagRaw`), E2 (the seven spawn records; the flag readers in `gw83_switch`, `gw85_retractable_gate`, `gw85_short_switch_spear`, `gw85_long_switch_spear`, `gw85_multi_switch_spear`; the scene `$87` spawn list; `enemy_stats_table` entry `$46` for the `+118` hex offset), E3 (`actors-player-rewards.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A paragraph header and no comments | FIXED (block note with the flag-reader table, 3 part notes, 25 comments) |
| Q2 | M | The header hid the trigger mechanism and the flag readers | FIXED |
| Q3 | **F** | (a) **It is hit-triggered and solid, not a pressure plate**: `MarkSolidHere` prevents standing on it and the only trigger is the hit callback dispatched by `combat_collision`; the old text said "when the player or objects land on the plate". (b) **Not pyramid rooms: all seven spawns are in the Great Wall** (scenes `83`, `85`, `87`). (c) **Flag readers found**: in scene `85` the four flags `1`-`4` are waited on and then cleared by `gw85_retractable_gate`, `gw85_short_switch_spear`, `gw85_long_switch_spear` and `gw85_multi_switch_spear` (one-shot triggers); in scene `83` flag `1` is waited on by `gw83_switch`, placed on the same tile; scene `87`'s flag `$0F` has no waiter in its spawn list. (d) **`$12 |= $0031`**: `$0010` stagger-immune, `$0020` boss (no damage digits), `$0001` selects an iframe mode. (e) **The stats pointer is entry `$46` (HP `$14`, ATK `$16`, DEF `$FF`)** because the `+118` offset is hex; `currentHp` is overwritten with `$FF` on every re-arm. (f) The callback becomes the victim's entry address and `onHitCallback` is cleared on each dispatch, which is why the script registers it again | FIXED |
| Q4 | M | `$24` and `$0E` roles were undocumented and the offset `+118` reads like decimal | FIXED (block note, comments) |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | "floor_button" suggests a pressure plate; `loc_00CA1F` is the re-arm step | PROPOSED (R-I042-2) |
| Q7 | M | E1 + E2; the frame images, the scene `87` flag consumer and the iframe-mode choice were not verified | DEFERRED-EVIDENCE (OQ-I042-3, OQ-I042-4) |

### Shared gate (I042)

`npm run merge -- plans/extracted-audit/edits/I042.json --dry-run` reported 3 block notes (all updated), 51 part notes (all new) and 268 comments (263 new, 5 updated). After the real merge, `npm run extract:lt` and the repeated dry run reported 0 files to change. `npm run rebuild` finished successfully and `artifacts/crc.json` reads checksum 223006080, crc 2083230829, totalSize 3062204 (unchanged). The I041 spec was merged a second time in the same session (block note wording only) with the same clean round trip.

Docs that repeat the old claims (not edited, `docs/` is outside the allowed folder): `docs/code/bank00/actors-player-rewards.md` lines 362-380 (floor_button as "pressure plate ... on press", placements "Pyramid, Edward Castle"), lines 384-420 (overworld_exit "Handled Scenes (partial)" table, `$064A` described as "fade mode", `$0D60` as "world map state"); `docs/code/bank00/functions-combat-defeat.md` lines 372-397 (spark described as critical-hit feedback with "randomized scatter offsets" and a "4-frame" lifetime); `docs/code/bank00/README.md` line 672 ("OAM spark entries for critical hits"); `docs/code/bank03/sprite-rendering.md` line 247 ("hit spark/flash sprites"); `docs/code/bank03/field-input-and-items.md` line 392 ("Damage flash" label for item `$86+`, which heals 5 HP).

Suggested commit message: `audit(I042): document overworld_exit (15 exits: zones, gate flags, start positions, world_map_options menu ids), SpawnHitSparkSprites as the item-effect sparkle (two entries, 8+16 frames, GiveItemToPlayer only), floor_button as a solid hit-triggered switch with its Great Wall flag readers`

Please commit when you're ready.
