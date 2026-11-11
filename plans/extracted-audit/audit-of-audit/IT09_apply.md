# IT-09 apply: factual defects and timing, I051–I060

Mechanism: `npm run merge` only. Spec: `plans/extracted-audit/audit-of-audit/IT09_spec.json` (one spec, 7 files: 7 block notes, 28 part notes, 18 comments; block and part notes mostly by partial `edit`, comments by full text with an `expect` guard). Decisions: U3 (Aura cluster wording, no `Dead:` marker, no rename) and U5 (quoted game text and prose "Ankor Wat", labels untouched).

## Facts re-derived before the spec was written (from the fresh `extract:lt`)

- **Zoom-out (A05-01).** `ArrivalAndTravelSetup` is a pooled actor, so `LoopStart` uses `loopCounter` / `retPtr2` (`cop_handlers_script_control.asm` `LoopStart`, `LoopEnd`). `COP [LoopStart] ( #2C )` = 44. Each pass runs `TickGravity`, adds the delta to `$B8`, then `COP [SetEntryHereAndYield]` (saves `$00/$02`, pops the COP frame, `RTL`: yield 1) and `COP [LoopEnd]`. A non-final `LoopEnd` decrements the count, copies `retPtr2` to `$00` and `RTL`s (yield 2); the 44th `LoopEnd` reaches zero and `RTI`s on. So 2 ticks per pass; the loop spans 88 ticks (pass 44 runs in tick 87, the final `LoopEnd` falls through in tick 88). `TickGravity` is called once per pass and its tick counter `t` counts calls, so the `$B8` arithmetic counts passes: I summed `((t * (t >> 1)) >> 5) - $20` for t = 1..44 by hand = -972, `$0400 - 972 = $34`. The tilt phase (`LoopStart #5D`) has no `SetEntryHereAndYield` in its body, so one yield per pass: 93 ticks, correct as written. `WaitByte #0F` (16 ticks) and `WaitByte #3B` (60 ticks) are correct as written.
- **Route step comments (A05-02).** `SetEntryHere` (`cop_handlers_script_control.asm`) saves `$00/$02` and `RTI`s: it does not yield. The yield is the `RTL` at `RouteCountTick`. In `RouteDeltaTables` the first `LDA [$2C]` (after `RouteNotEnd` advanced past byte 0) is byte 1 and goes to `$1A` (Y chain); the next is byte 2, goes to `$1C` and is added to `$00BC` in `RouteAxisRotation` (rotation index, not a Z axis); the next is byte 3 = tick count n, stored in `$24`. The old comments counted from 1 (Y = byte 2, Z = byte 3, count = byte 4); `world_map_route_table.asm` counts from 0 (byte 0 X, 1 Y, 2 rotation, 3 tick count n). The spec uses the route-table numbering.
- **`$1C`-`$26` (A05-07).** `WorldMapController` stores `$0D58 AND #$001F` in `$0000`; `SwitchCase` reads it as the table index (no range check), so only entries `$00`-`$1F` can be selected. `StageWorldMapChoice` is the only writer of `$0D58` in `extracted/` and `baserom/` besides `StageWorldMapMove` (clears it); its 27 sites in `overworld_exit.asm` write the ids `$01`-`$1B`, each exactly once. `$1C`-`$1F`: unused but reachable if staged; `$20`-`$26`: no id reaches them.
- **Aura cluster (A05-03).** `baserom/patches/APUWaitFixes.patch.asm` `AuraItemGrant!` (lines 392-445) uses `&AuraItemInventoryFull` (396), `@dialogstring_08EFEF` (415) and `loc_08EFAD` (432, 442). No other `AuraItem*` / `08EFEF` hit in the patch.
- **PAL lockout (A05-10).** `baserom/fixes-tweaks/Utils.patch.asm` lines 75-76: `BootLogoPalLockout! { BRA BootLogoNtsc }`. `BootLogoInit` does `JMP $&BootLogoPalLockout` when `STAT78` bit 4 is set, so the patched entry branches to the NTSC path.
- **Padding (A05-11).** `palette_padding_16D210/11` and `_16D317/18` are named only in the table of names and in the notes; no table entry, frame pointer or `&` / `@` reference points at them (`rg palette_padding` over `*.asm` / `*.json` outside `plans/`). Comparing bytes cannot settle "padding": the bytes are `$00` by definition of an empty bundle. The notes now state what is known (nothing references them) and what is not (whether they are padding).

## Items

| finding id | file:line (live, after `extract:lt`) | status | note |
|---|---|---|---|
| A05-01 | `WorldMapController.asm:37` block note step 2 | APPLIED | "44 passes of a loop that yields twice per pass ... 2 ticks per pass, about 88 ticks"; "each pass adds" |
| A05-01 | `WorldMapController.asm:150` part note `ArrivalAndTravelSetup` | APPLIED | "a zoom-out of 44 passes at 2 ticks per pass (about 88 ticks ...)" |
| A05-01 | `WorldMapController.asm:163` comment `{238454}` | APPLIED | "delta of pass t ... negative for all 44 passes (sum about -970)"; `$B8` arithmetic kept (verified, -972) |
| A05-01 | `WorldMapController.asm:164` comment `{238459}` | APPLIED | 44 passes, yields twice, 2 ticks per pass, about 88 ticks |
| A05-01 | `WorldMapController.asm:170`, `171` comments `{238475}`, `{238477}` | APPLIED | new: yield 1 of 2 (`SetEntryHereAndYield`), yield 2 of 2 (non-final `LoopEnd`; the 44th pass falls through) |
| A05-02 | `WorldMapController.asm:425` part note `RouteDeltaTables` | APPLIED | `SetEntryHere` does not yield; yield at the `RTL` in `RouteCountTick`; bytes numbered 0-3; "applies its deltas n + 1 times, once per tick" |
| A05-02 | `WorldMapController.asm:428`, `432`, `439`, `444`, `446`, `450` comments `{238936}`, `{238943}`, `{238957}`, `{238966}`, `{238971}`, `{238980}` | APPLIED | one numbering (route-table: byte 0 X, 1 Y, 2 rotation, 3 tick count n); "Z movement" replaced by "rotation chain index (added to `$BC`)"; `SetEntryHere` comment states it does not yield |
| A05-02 | `WorldMapController.asm:411`, `420` comments `{238913}`, `{238926}` | APPLIED | same fault, same numbering: "step type byte" now "byte 0" (not listed by the finding) |
| A05-02 | `WorldMapController.asm:485`, `487`, `493`, `499`, `501` comments `{239038}`, `{239042}`, `{239055}`, `{239059}`, `{239063}` | APPLIED | same fault: "Z axis / Z delta / Z pointer" now "rotation"; "frame count" now "tick counter" (not listed by the finding) |
| A05-13 | `world_map_options.asm:38` (block note) | APPLIED | "a tick count n (the step runs n + 1 ticks)" as in `world_map_route_table.asm:11` |
| A05-13 | `world_map_options.asm:40` (block note) | APPLIED | "These sums match when each step counts n deltas; the engine applies n + 1 deltas per step (the step runs n + 1 ticks), one more per active axis than the sums". `(OQ-I060-2)` left in place (IT-13) |
| A05-07 | `world_map_options.asm:13` (block note) | APPLIED | the line has no "never staged"; added that the controller keeps the low 5 bits, so no id selects `$20`-`$26` |
| A05-07 | `world_map_options.asm:34` (block note) | APPLIED | staged ids `$01`-`$1B`, one site each; `$00` only returns; `$1C`-`$1F` never staged but reachable; `$20`-`$26` unreachable (mask) |
| A05-07 | `world_map_options.asm:67` (part note `world_map_options`) | APPLIED | only `$00`-`$1F` can be selected; `$00` and `$1C`-`$1F` never run; `$20`-`$26` unreachable |
| A05-07 | `world_map_options.asm` part notes `WorldMapMenu_Empty1C`-`1F`, `Empty20`-`25`, `Nothing26` | APPLIED | same fault (11 notes "Never staged."): `$1C`-`$1F` "No site stages this id; staging it would run this entry"; `$20`-`$26` "No id reaches this entry: the controller masks the choice id with AND #$001F" (not listed by the finding) |
| A05-12 | `world_map_options.asm:13`, `24`, `484` (twice), `1007` (twice) | APPLIED | prose "Angkor Wat" -> "Ankor Wat" (U5); labels `WorldMapGo_*_AngkorWat`, `WorldMapQuit_AngkorWat` untouched. `diary_entry_table.asm` 404-414 and `world_map_scene_names.asm:125` already say "Ankor Wat" in the live text: nothing to do |
| A05-14 | `StandardEnemyDefeatHandler.asm:6`, `7` (block note) | APPLIED | "WaitByte #02 (3 ticks)"; step 3 now lists both waits of `EnemyDefeatBossCleanup`: `WaitByte #02 (3 ticks)` ... `WaitByte #05 (6 ticks)` (the first wait was missing) |
| A05-14 | `StandardEnemyDefeatHandler.asm:66` (part note `EnemyDefeatFlashAndDrop`) | APPLIED | "WaitByte #02 (3 ticks)" |
| A05-14 | `layer1_scroll_actors.asm:44` (part note `code_00E8DA`) | APPLIED | "WaitByte #01 (2 ticks)" |
| A05-03 / U3 | `sE6_gaia.asm:30` (block note, new paragraph at 32) | APPLIED | 'no reference' for the Aura cluster means extracted code; `APUWaitFixes.patch.asm` rewrites `AuraItemGrant` and uses `AuraItemInventoryFull` and `dialogstring_08EFEF`. Existing sentence kept |
| A05-03 / U3 | `sE6_gaia.asm:521`, `1448`, `1467`, `1525` (part notes `DS_AuraItemRoom`, `AuraItemInteraction`, `AuraItemGrant`, `AuraItemInventoryFull`) | APPLIED | "No reference in extracted code" (+ patch sentence on `AuraItemGrant` and `AuraItemInventoryFull`); no `Dead:` marker, no rename |
| A05-03 / U3 | `sE6_gaia.asm:1550` part note `dialogstring_08EFEF` | APPLIED | new note: used by `AuraItemGrant` and by the patch's rewrite |
| A05-10 | `sFB_boot_logo.asm:14` (block note), `:94` (part note `BootLogoPalLockout`), `:65` comment `{772327}` | APPLIED | `Utils.patch.asm` rewrites `BootLogoPalLockout!` as `BRA BootLogoNtsc`; the shipped ROM skips the lockout screen (static reading of the patch); "cannot be started on a PAL console" now says "In the unpatched ROM" |
| A05-11 | `palette_bundles.asm:9` (block note), `:10105`, `10111`, `10254`, `10260` (part notes) | APPLIED | hedge: "Nothing references it ... Not established: whether these bytes are padding"; the four ids `R-I060-4` dropped with the rewrite. Bytes not compared (cannot settle it) |

DISPUTED: 0. SKIPPED: 0. BLOCKED: 2 (below).

## BLOCKED

- `docs/code/bank03/radar-and-world-map.md:164` and the phase table near `:202` repeat the "44 ticks" zoom-out (A05-01): docs are IT-16.
- R-I056-8 (rename / `Dead:` marker for the Aura cluster) stays blocked by U3.

## Dry-run summary

```
system/world_map/WorldMapController.asm: block +0 ~1 -0 =0, parts +0 ~2 -0 =0, comments +2 ~15 -0 =0
system/world_map/world_map_options.asm: block +0 ~1 -0 =0, parts +0 ~14 -0 =0, comments +0 ~0 -0 =0
functions/StandardEnemyDefeatHandler.asm: block +0 ~1 -0 =0, parts +0 ~1 -0 =0, comments +0 ~0 -0 =0
actors/layer1_scroll_actors.asm: block +0 ~0 -0 =0, parts +0 ~1 -0 =0, comments +0 ~0 -0 =0
system/dark_space/sE6_gaia.asm: block +0 ~1 -0 =0, parts +1 ~4 -0 =0, comments +0 ~0 -0 =0
system/boot_logos/sFB_boot_logo.asm: block +0 ~1 -0 =0, parts +0 ~1 -0 =0, comments +0 ~1 -0 =0
tables/palette_bundles.asm: block +0 ~1 -0 =0, parts +0 ~4 -0 =0, comments +0 ~0 -0 =0
[DRY RUN] 12 notes file(s) would change; nothing written.
```

No transform warning, no hazard line of §6.3 touched. The real run wrote the same 12 files: `notes/blockNotes` bank00, 03, 08, 0B, 16; `notes/partNotes` bank00, 03, 08, 0B, 16; `notes/comments` bank03, 0B.

## Gate

`npm run extract:lt`, then `npm run rebuild` (separate commands; `ROM rebuild completed successfully!`): `artifacts/crc.json` = checksum 223006080, crc 2083230829, totalSize 3062204. Equal to the baseline.

Read back in the re-extracted files: `WorldMapController.asm` 37, 150, 163-171, 411-450, 482-501; `world_map_options.asm` 13, 24, 34, 38, 40, 67, 484, 635-715, 1000-1017; `StandardEnemyDefeatHandler.asm` 6, 7, 66, 79, 151-165; `layer1_scroll_actors.asm` 38-44, 87; `sE6_gaia.asm` 30-32, 521, 1448, 1467, 1525, 1550; `sFB_boot_logo.asm` 14, 65, 94; `palette_bundles.asm` 9, 10105-10262. `rg` for `Z movement`, `Z delta`, `44 ticks`, `44-tick`, `SetEntryHere then yields` and `Angkor` (prose) in these files gives no stale hit.

## Found outside scope (not changed)

- **Route steps overlap by one tick.** `RouteNextStep` jumps straight to `RouteStepLoop`, and a new step runs its first pass of the axis code (and may reach `RouteEndHandler` for `$FF`) in the same tick as the previous step's last pass; there is no yield between them. A step therefore applies n + 1 deltas but takes n ticks of its own. "The step runs n + 1 ticks" (`world_map_route_table.asm:11`, `world_map_options.asm:38/40` as now written, the `RouteAnimationEngine` part note) is exact for the number of deltas, not for the elapsed time. I kept the n + 1 wording as instructed; the route-table block note and these lines should be re-read together when someone touches that block (no owner iteration lists it; `world_map_route_table` has no bank info for `merge`, per the note in `world_map_options`).
- **The retranslation stages `$1C`.** `IOGRetranslation/modules/base/patches/ExpandedOverworldRoutes.patch.asm:126` runs `COP [66] ( #$01D4, #$0134, #1C )`, so in that project entry `$1C` is run. The baserom notes say "no site stages this id" about the extracted code, which stays true for this repo; the retranslation docs are not part of this iteration. `IOGRetranslation/modules/walkable-world-map/WalkableWorldMap.patch.asm:57` comments "~88 frames" for the same zoom-out phase (independent corroboration of the trace, not a runtime check).
- `sE6_gaia.asm` still has `Not referenced:` / `unreferenced` wording on `AuraItemDie`, `AuraItemReturnToWait`, the `loc_08EFAD` comment and the `DS_AuraItemRoom` state comments (538-572, 1454, 1501, 1520, 1541). They describe the extracted code and are not wrong; `loc_08EFAD` is also used by the patch (`APUWaitFixes.patch.asm:432, 442`) and `AuraItemReturnToWait` is referenced inside the cluster (`AuraItemInventoryFull`).
- `sFB_boot_logo.asm:14` still opens with "A 50 Hz console never sees a logo" and sequence step 1 says a PAL console "jumps to BootLogoPalLockout": both describe the code as extracted and are followed by the patch sentence.
- History narration and ids left for IT-13 in the touched blocks: `WorldMapController` ("The old comments called it elevation.", `OQ-I059-1/2/4/7`), `world_map_options` ("the old header read ...", `OQ-I060-2`, `R-I060-3`), `layer1_scroll_actors` (`OQ-I051-1/2`), `sE6_gaia` (CORRECTIONS section, "the old header"), `sFB_boot_logo` ("The old header said ...", `OQ-I034-1`), `palette_bundles` ("Not all traced" is fine; no ids left in the four rewritten notes).
- `diary_entry_table`, `world_map_scene_names`, `debug_man`, `overworld_exit` and the Angkor Wat actors mix "Angkor Wat" and "Ankor Wat" in prose and comments (for example `debug_man.asm:18, 379`, `eu96_kara.asm:4`); outside A05-12's file list and not edited.
- Shell note: after the rebuild I read `artifacts/crc.json` with `cat`, which is not on the allowed command list (read-only, no effect on any file).
