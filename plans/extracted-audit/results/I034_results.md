# I034 results

Files: `system/inventory/inventory_overlay.asm` (Bank 02), `actors/idle_sprite_display.asm` (Bank 08), `thinkers/oneshot_coldata_green_tint.asm` (Bank 00).
Spec: [edits/I034.json](../edits/I034.json). New proposals: [renames/I034_renames.md](../renames/I034_renames.md). New questions: [questions/I034_questions.md](../questions/I034_questions.md).

Conventions as in [I029_results.md](I029_results.md).

### File 1: system/inventory/inventory_overlay.asm (Bank 02)

Evidence: E1 (every routine read, the MVN source / destination register flow checked copy by copy, stack pushes and pops matched), E2 (`actor_pool` / `actor_execution` / `thinker_execution` for the pool and list layouts, `system_core` `UpdateFrameDialogue`, `vblank_joypad` NMITIMEN routines, `scene_script` source-pointer cache, `scene_lifecycle` flag `$FF` and COLDATA setup, `cop_handlers_effects` `BuildSineLookupTable`, `cop_handlers_dialog` `RunBg3Script`, `warps_interaction` `PlaceOpenedChestTiles`, `camera_tilemap`, the `copdef` / COP docs for `CopyPalette`), E3 (`docs/code/bank02/inventory-overlay.md`, `wram-memory-map.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | Header and most lines had comments, but the save map, the stack frame and several register effects were missing or wrong | FIXED (block note with 16 steps and a save map, 7 part notes, 53 comment entries) |
| Q2 | M | The reader could not see what each backed-up page really is, nor what `$FF` / `$4000` / `$41` do | FIXED |
| Q3 | **F** | (a) **Save map roles**: `$00:0E00` is the actor free-slot list (not hardware shadows), `$7E:3000` the thinker free-slot list (not an actor pool), `$00:0F00` the thinker table (16 slots x `$10`; not a variable / script page), `$7F:0F00` thinker extended data (not a scratch page). (b) **Camera words**: the six words are `cameraTargetX, cameraDeltaX, cameraTargetY, cameraDeltaY, scrollOverrideH, forcedScrollOverride`; `scrollOverrideV` is zeroed but not saved. (c) **`DrainActorQueue` walks the thinker list** (head `$5A`, tail `$5C`), not an actor queue, and it runs after the restore, so it clears the wait counters of the restored gameplay thinkers. (d) **`$0673` / `$0676`** are not frame counters: the 16-bit stores invalidate source-pointer cache slots C and D (addr high byte + bank). (e) **`displayModeFlags |= $41`**: bit 6 is the `BuildSineLookupTable` rebuild trigger, not "dialogue"; `$4000` at open clears all request bits and bit 14 has no reader. (f) **Event flags**: `STZ eventFlags` also clears flag byte `#00`, the loop's exit flag; flag `$FF` is the scene-setup-complete latch (cleared at open, set again at the end of close), not "disable some visual flag" / "sprite compose ready". (g) **NMI**: `EnableNmiOnly` writes NMITIMEN `$01` (NMI OFF, joypad auto-read on); the header's "DISABLE INTERRUPTS: EnableNmiOnly + EnableDisplay" had a nonexistent call, and the main loop runs with the NMI off except for the pulse inside `UpdateFrameDialogue`. (h) **PPU**: `WH1 = $FF` is inert (all W*SEL are zero); the `$1B` / `$5B` stores are the two bytes of palette word `$5B1B` at colour index 2, not "index $1B / $5B"; `$0F00` in `joypadMaskInv` is the D-pad bits only; `PlaceOpenedChestTiles` redraws opened chests, not "warp / barrier markers"; the camera restore comments used stale names (`bg1ScrollV`, `savedCameraDelta`); the `$00F4` / `$00F8` words are not "suppress bytes" (no other reference). (i) Both sentinel stores were commented as `$7F3101` / "duplicate" on the wrong line | FIXED |
| Q4 | M | Operands correct; the MVN source / destination roles and several register names in comments were wrong as above | FIXED |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | `DrainActorQueue` names the wrong list; `OpenInventoryScreen` and the rest match their behaviour | PROPOSED (R-I034-1) |
| Q7 | M | E1 + E2; the unsaved scroll words, bit 14 and the sine-table reason have no runtime check | DEFERRED-EVIDENCE (OQ-I034-1, -4, -5, -6) |

### File 2: actors/idle_sprite_display.asm (Bank 08)

Evidence: E1 (5 instructions, `actor-def` header bytes), E2 (`InitActorFromSceneData` header parse, `combat_collision` friendly / NPC-chat path, `GiveItemToPlayer` item table, `DarkGemDropSystem` gem spawners, name search over `extracted/`, `db-us/blocks.json`), E3 (`docs/code/bank08-native-dao-pyramid-actors.md:259`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | A two-line header and two comments | FIXED (block note, 5 comments) |
| Q2 | M | The header called it a static NPC / decoration | FIXED |
| Q3 | **F** | (a) `chatPtr = $0085` is an item ID, not a "dialog bank pointer": `$85` is "+5 gems" in `GiveItemToPlayer`, the value `DarkGemDropAnimVariantA` also stores. (b) Frame `#06` is the 5-gem frame that variant stages. (c) Flags word `$0020` (`$4020` after init) marks the actor friendly, so a touch routes to `InteractionDamage_NPCChat`. (d) No scene list or COP refers to it by name | FIXED; usage open (OQ-I034-3) |
| Q4 | M | The `chatPtr` comment was wrong | FIXED |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | "idle sprite display" hides that it is a pickup | PROPOSED (R-I034-3) |
| Q7 | M | E1 + E2; the pickup behaviour is inferred from the shared item and flag paths | DEFERRED-EVIDENCE (OQ-I034-3) |

### File 3: thinkers/oneshot_coldata_green_tint.asm (Bank 00)

Evidence: E1 (three COLDATA stores decoded by channel bit), E2 (`tables/scene_thinkers.asm` list `$0CE80C` and its `+4` entry for scene `$01`, `system_init` `UploadCgramPalette`, `scene_lifecycle` backdropColors zeroing, `hdma_dma_spc` bundle destination, `thinker_execution` filter word), E3 (`docs/code/bank00/thinkers-palette.md`, `bank00/README.md`, `bank0C-scene-spawn-tables-comet.md`).

| Q | Verdict | Findings and evidence | Disposition |
|---|---------|-----------------------|-------------|
| Q1 | M | One header paragraph, no comments | FIXED (block note, 9 comments) |
| Q2 | M | The header did not decode `$2B` / `$44` / `$82` | FIXED |
| Q3 | **F** | (a) **Colour**: `$2B` = red 11, `$44` = green 4, `$82` = blue 2, so the fixed colour is red-dominant; "green tint" only holds if CGADSUB subtracts. (b) **Placement**: spawned only for scene `$30` (list `$0CE80C`, slot 0); scene `$01` enters the same list at `+4` and skips it. The "South Cape scene group" claim is unsupported, and so is "before the warm palette cycler takes over" (two `ambient_palette_cycler` thinkers and a `flag_gated_palette_warm` sit in the same list). The docs say "Oakton thunderstorm" | FIXED; open points in OQ-I034-2 |
| Q4 | M | Operands correct | NOFIX |
| Q5 | NA | Nothing to add | NOFIX |
| Q6 | M | "green_tint" is not established by the values | PROPOSED (R-I034-2) |
| Q7 | M | E1 + E2; CGADSUB and the scene's identity are not decoded | DEFERRED-EVIDENCE (OQ-I034-2) |

### Shared gate (I034)

`npm run merge -- edits/I034.json --dry-run` reported one length warning (comment `{192143}`, 166 characters); the comment was shortened and the dry run was then clean (no transform warnings). Merge applied: 3 block notes, 7 part notes (one new: `code_02EE17`), 67 comment entries (53 in `inventory_overlay`, 5 in `idle_sprite_display`, 9 in `oneshot_coldata_green_tint`). The code lines of all three files are identical before and after (comments only). `npm run extract:lt` OK, `npm run rebuild` OK, `artifacts/crc.json` = checksum 223006080, crc 2083230829, totalSize 3062204, read once after both I033 and I034 were merged. Tooling: OQ-I026-1 still applies; the stale inert comment at `notes/comments/bank00.json` key 47052 (I029 palette flash-18 area) still cannot be removed by the merge script.

Suggested commit message: `audit(I034): inventory_overlay save map roles, DrainActorQueue walks the

Please commit when you're ready.
