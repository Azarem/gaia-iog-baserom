# IT-02 apply: timing wording, `WaitByte` n + 1 (PLAN F02)

Mechanism: `npm run merge` only. Spec: `plans/extracted-audit/audit-of-audit/IT02_spec.json` (one spec; 11 files; block and part notes by `edit` ops, comments with `expect` guards). Because the notes use `edit` ops, re-running the spec reports an error instead of `=unchanged`.

## Rule, re-derived before editing

- Runner (`system/engine/actor_execution.asm`): the script-driven path and the plain path of every `RunActors_*` pass do `DEC $08` / `BPL <skip>` / `STZ $08` / dispatch (lines 144-146, 180-182, 265-267, 301-303, 389-394, 428-430, 532-534, 547-549, 629-631, 644-646). `A` is 16-bit there (`LDA $10` / `BIT #$2000` precede it), so `BPL` tests bit 15 of the whole word. A stored `n` is skipped while `n - k >= 0`, i.e. for `n` passes, and the script resumes on pass `n + 1`. Stored `0` resumes on the next pass.
- `WaitByte` / `WaitWord` (`cop_handlers_wait.asm`): `STA $08` in the shared tail `WaitStoreAndYield`, then the resume address goes to `$00`/`$02` and the handler returns with `RTL`. The handler header already says "a count of N resumes N+1 ticks later (0 = next tick)".
- `JumpAfterDelay` (`cop_handlers_script_control.asm`) and `WaitWhileOffscreen` (`cop_handlers_player_query.asm`) store their operand in `$08` the same way (`STA $08`, `PLA`, `PLA`, `RTL`), so they obey the same rule.
- `SetEntryHereAndYield` does not touch `$08` (checked), so the `$08 := $78` / `$08 := 3` stores of `npc_wander_ai` and `camera_drift` survive the caller's yield.
- Palette bundles: the sum quoted in `attack_ability_system.asm:1585` (holds 0,2,3,... = 62 ticks for 14 frames) already counts `wait + 1` per frame, so the rule holds there too.

## Items

| finding id | file:line (live, after merge) | status | note |
|---|---|---|---|
| N-4 | `warps_interaction.asm:52` (block note step 6) | APPLIED | "WaitByte #0B (12 ticks)". |
| N-4 (same fault, not listed) | `warps_interaction.asm:54` (block note, ChestDialogueActor) | APPLIED | "WaitByte #48 (73 ticks)". The finding named only lines 52, 509, 522, 529; this block-note line stated "waits 72 frames" for the same `WaitByte #48`. |
| N-4 (same fault, not listed) | `warps_interaction.asm:463` (inline, tag 174099) | APPLIED | "after its 73-tick delay". Same `WaitByte #48` of `ChestDialogueActor`. |
| N-4 | `warps_interaction.asm:509` (inline, tag 174216) | APPLIED | `WaitByte #0B = 12 ticks`. |
| N-4 | `warps_interaction.asm:522` (`ChestDialogueActor` part note) | APPLIED | `COP [WaitByte] ( #48 )`: 73 ticks (operand + 1). |
| N-4 | `warps_interaction.asm:529` (inline, tag 174227) | APPLIED | `WaitByte #48 = 73 ticks`. |
| A07-14 | `warps_interaction.asm:647` (`InitWarpTable` part note) | APPLIED | First byte of each entry is the X tile (bit 7 clear); stride 12; the walk stops at the first byte with bit 7 set (`LDA $0000,X` / `BMI`, lines 659-660); every list uses `$FF`. Checked against `scene_warps.asm:5`. |
| N-4 | `music_actors.asm:122` (`MusicJingleWaitFinal` part note) | APPLIED | "waits 2 ticks (COP WaitByte #01)". |
| N-4 | `music_actors.asm:125` (inline, tag 172250) | APPLIED | `WaitByte #01 = 2 ticks`. |
| N-4 (same file, not listed) | `music_actors.asm:12`, `:16` (block note), `:45` (`MusicJingleActor` part note) | APPLIED | `WaitByte(1)` became "WaitByte #01 (2 ticks)"; "waits $48 (72) frames" became "does WaitByte #48 (73 ticks)". The same `WaitByte #01` / `#48` operands as the target lines. |
| N-4 (same file, not listed) | `music_actors.asm:138` (`MusicRenderSync` part note), `:141` (inline, tag 172261) | APPLIED | "Waits 73 ticks via COP [WaitByte] ( #48 )"; inline keeps its hedge "(inferred: the jingle plays meanwhile)". |
| N-4 / A02-04 | `item_use_system.asm:1826` (`FluteRestoreMusicPhase` part note) | APPLIED | "WaitByte #01 (2 ticks)". Lines 1745 and 1848 were already right. No comment placed on the CMP lines at 388 / 463. |
| A01 F4 / V09 | `cop_handlers_script_control.asm:64`, `:79` (tag 43563), `:76` (tag 43557) | APPLIED | `JumpAfterDelay`: operand named "delay count n"; stored in `$08`; the script resumes at the target `n + 1` ticks later (0 = next tick). Line 76 only renames "frame delay" to "delay count". |
| A01 F4 | `cop_handlers_player_query.asm:112` (`WaitWhileOffscreen` part note) | APPLIED | "(delay count n)"; the test repeats `n + 1` ticks later (the WaitByte rule). |
| A01 F4 (same handler, not listed) | `cop_handlers_player_query.asm:126`, `:127` (tags 37091, 37093) | APPLIED | `:127` said "re-execute next frame" for a yield that waits `n + 1` ticks; now "the COP re-executes when the wait counter runs out". |
| A02-04 | `player_character.asm:653` (inline, tag 182079) | APPLIED | `WaitWord #$01DF = 480 ticks` (`$01DF` = 479 skipped passes, resumes on pass 480). |
| A02-04 (same fault, not listed) | `player_character.asm:16` (block note) | APPLIED | "sets playerFlags $0010 for 480 ticks, WaitWord #$01DF". |
| A03-09 | `RandomPlayerOffset.asm:4` (block note), `:26` (inline, tag 720257) | APPLIED | Checked against the runner: `$08 = $3C` skips 60 passes, runs again on the 61st tick; "hops every 61 ticks". While rewriting the sentence the clause "as the older header said" was dropped (history narration). The blanket `UNVERIFIED-RUNTIME` line was left for the hygiene sweep. |
| A04-02 | `hit_switch.asm:10` (block note, two places), `:68` (`HitSwitchTriggered` part note), `:75` (inline, tag 51768) | APPLIED | `WaitByte #0F` = 16 ticks in all four places. |
| A04-03 | `npc_wander_ai.asm:14` (block note), `:100` (`NpcWanderStageStand` part note), `:106` (inline, tag 51059) | APPLIED | `$08 := $78`: 120 skipped passes, 121 ticks. |
| A04-03 | `camera_drift.asm:21` (block note), `:89` (`CameraDriftPatterned` part note), `:166` (`loc_00D05B` part note), `:171` (inline, tag 53343) | APPLIED | `$08 := 3`: runs 4 ticks apart; runs at ticks 0, 4 and 8, the third ends in `Die`. The old "lives about 9 frames" is replaced by the 8-tick span; the offsets count (3 Y + 3 X) is unchanged. `:166` is a part note above the sub-label `loc_00D05B` (it is the same text as the finding's "wait 3 frames"). |
| A04 §6 (b) | `town_door.asm:27` (inline, tag 50695) | APPLIED | Provable from code: `WaitWhileOffscreen` does `STA $08` with the operand `#0A` (= 10) and yields (`cop_handlers_player_query.asm:126-128`), so the op re-runs 11 ticks later, not every 10 passes. The comment now says so. |

Applied: 31 rows (34 notes and comments in 11 files). DISPUTED: none. SKIPPED: none. BLOCKED: none.

## Verification only

| check | result |
|---|---|
| (a) `PaletteStep` "wait 2 each": `shadow_shimmer.asm:6, 101`, `global_ambient_dispatcher.asm:5, 81` | NOT-VERIFIED as an error, no text changed. Bundle `#23` (`palette_bundle_1691B7`) has eight single-frame sub-entries with the wait byte `#02`; bundle `#24` alternates `#00` and `#01`. `LoadPaletteBundle` stores sub-entry byte 5 in `$08` (`hdma_dma_spc.asm:220-223`) and `PaletteStep` re-seeds it (`cop_handlers_palette.asm`, `loc_0093BD`), so each frame is held `wait + 1` ticks (3 for `#23`, 1 and 2 alternating for `#24`). The notes say "wait 2" / "waits 0 and 1", which names the data field `wait` ("extra ticks between frames" in `palette_bundles.asm` and `hdma_dma_spc.asm`), not a tick count. That is not provably wrong; a reader can still take it as 2 ticks. Candidate for IT-18 / IT-22: add "(3 ticks per strip)". |
| (a) `SpawnItemSparkleEffect.asm` | The live file carries no `PaletteStep` or "wait 2" text (rg for `wait`, `tick`, `Palette` finds only `:10` and `:42`, unrelated). Nothing to change. |
| (b) `town_door.asm` `WaitWhileOffscreen ( #0A )` | Error proven from the handler and the runner: 11 ticks. Fixed (row above). |
| (c) `SetAutoWalkTimer` run window (`player_character.asm:12, 294-308, 475-477`) | Static trace says **13 later passes**, not 14. Main loop order is `UpdateFrameCounters` then `RunActors_Normal` (`system_core.asm:223, 232-233`). `SetAutoWalkTimer` stores 13 in pass F. In pass F+k `UpdateFrameCounters` runs first (`LDA $invincibilityTimer / BMI / DEC / STA`, `:510-513`) and the player script's test (`LDA $invincibilityTimer / BMI`, e.g. `WalkSouth` `:296-297`) follows. The test sees `13 - k`, non-negative for k = 1..13; at k = 14 the DEC takes 0 to `$FFFF` and the test finds the window closed. The timer holds 14 non-negative values (13..0), but the value 13 is never seen by a test in a later pass. So "13 frames" is right if "frames" means later main-loop passes. The count assumes the test runs after `UpdateFrameCounters` in the same pass (true for the main loop; `rg UpdateFrameCounters extracted/` finds one call site, `system_core.asm:232`, so the other frame loops never decrement the timer). Report only: no text changed. Optional wording for a later iteration: "the 13 passes after the one that sets it". Not a runtime claim. |

## Dry-run summary

```
system/engine/warps_interaction.asm: block +0 ~1 -0 =0, parts +0 ~2 -0 =0, comments +0 ~3 -0 =0
system/engine/music_actors.asm: block +0 ~1 -0 =0, parts +0 ~3 -0 =0, comments +0 ~2 -0 =0
system/inventory/item_use_system.asm: block +0 ~0 -0 =0, parts +0 ~1 -0 =0, comments +0 ~0 -0 =0
system/engine/cop_handlers_script_control.asm: block +0 ~0 -0 =0, parts +0 ~1 -0 =0, comments +0 ~2 -0 =0
system/engine/cop_handlers_player_query.asm: block +0 ~0 -0 =0, parts +0 ~1 -0 =0, comments +0 ~2 -0 =0
actors/player/player_character.asm: block +0 ~1 -0 =0, parts +0 ~0 -0 =0, comments +0 ~1 -0 =0
functions/RandomPlayerOffset.asm: block +0 ~1 -0 =0, parts +0 ~0 -0 =0, comments +0 ~1 -0 =0
actors/hit_switch.asm: block +0 ~1 -0 =0, parts +0 ~1 -0 =0, comments +0 ~1 -0 =0
functions/npc_wander_ai.asm: block +0 ~1 -0 =0, parts +0 ~1 -0 =0, comments +0 ~1 -0 =0
functions/camera_drift.asm: block +0 ~1 -0 =0, parts +0 ~2 -0 =0, comments +0 ~1 -0 =0
actors/town_door.asm: block +0 ~0 -0 =0, parts +0 ~0 -0 =0, comments +0 ~1 -0 =0
[DRY RUN] 9 notes file(s) would change; nothing written.
OK
```

No warnings (no transform pattern matched any comment). The real run reported the same counts and wrote `notes/blockNotes/bank00.json`, `bank02.json`, `bank0A.json`; `notes/partNotes/bank00.json`, `bank02.json`, `bank03.json`; `notes/comments/bank00.json`, `bank02.json`, `bank0A.json`.

## Gate

`npm run extract:lt`, then `npm run rebuild` (separate commands): `artifacts/crc.json` = checksum 223006080, crc 2083230829, totalSize 3062204. Equal to the baseline. Every changed line was read back in the re-extracted files (table above).

## Found outside scope (not changed)

- `warps_interaction.asm:659` (inline, tag 174438): "Walk standard entries until byte 0 = $FF terminator"; the instruction is `BMI` (any byte with bit 7 set ends the list). Same fact as A07-14, not in the F02 list.
- `gs2C_rain_spawner.asm:3` ("Loops every $0F frames") with `COP [WaitByte] ( #0F )` at line 19: 16 ticks. Not in the IT-02 list; for the IT-18 sweep.
- `garden_crash_cutscene.asm:117` ("Phase 2 - Signal + scroll (60 frames)"): not checked whether it is a `WaitByte`; for the IT-18 sweep.
- `town_door.asm:7` (block note): "Every later frame resumes there". While the door is off-screen the op only re-runs every 11 ticks; the sentence holds only for an on-screen door. Not changed (the finding covered only the `#0A` comment).
- `hit_switch.asm:1, 10` and `npc_wander_ai.asm:13, 16`, `camera_drift.asm:13`: history narration ("formerly named", "The old text ... is wrong", "the old note said") remains; hygiene sweep IT-12. `RandomPlayerOffset.asm:5` keeps the blanket `UNVERIFIED-RUNTIME` tag (policy 6.1; IT-12).
- `future_vision_cutscene.asm:82, 136` (`#77` = 120 ticks, not 119): not edited, as instructed (carried forward).
