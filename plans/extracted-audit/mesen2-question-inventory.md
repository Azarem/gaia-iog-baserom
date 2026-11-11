# Outstanding question inventory (for the Mesen2 investigation)

Companion to [mesen2-investigation-plan.md](mesen2-investigation-plan.md). This file lists **every** `OQ-` row found in `plans/extracted-audit/questions/` (358 IDs in 57 files, as of iteration I072), the experiment that is meant to answer it, how it can be answered, and a priority.

The question text, static evidence and suggested check stay in the frozen `questions/*.md` files. This inventory only adds routing. When a question is closed, append it to `mesen2-results/closures.md` (plan section 8.2); `open-questions.md` (audit-of-audit IT-35) links to that file.

**Revision 2026-10-29.** Corrected with `audit-of-audit/A12_findings.md` (A12-08, A12-09, A12-10, section 4, section 8) and the apply files IT-01 to IT-16:
- 8 rows the first version listed as open are answered (OQ-5, OQ-7, OQ-22, OQ-I027-5, OQ-I029-1, OQ-I029-4, OQ-I054-1, OQ-I055-4) and OQ-I063-4 is a duplicate of an answered row: mode `X`.
- The hidden-group trio (OQ-I067-5, OQ-I069-4, OQ-I071-5) is static plus the extractor fix (IT-33/IT-34): mode `S`.
- Rows with a static pointer carry `†` after the mode (A12 section 8 plus OQ-I060-2 from IT-09): confirm at runtime, do not rediscover. Five of them (the `$0200` reader family) moved from P1 to P2 for that reason.
- The cluster table is rebuilt from A12 section 4 (8 errors fixed, 3 method-only groups, 2 missing duplicates added).
- Section heading counts and the priority totals are corrected (the old priority totals summed to 357).
- Topics that named retired labels use the live names (appendix A of the plan).
- Counts of the **first** version are kept in the "Changes" table at the end so the diff is auditable.

## How to read the tables

| Column | Meaning |
|--------|---------|
| **ID** | The `OQ-` ID exactly as in the source file. |
| **Topic** | A short paraphrase. The source file has the full wording. |
| **Exp** | Experiment code(s) from the plan. The first code is the primary one. A code after `+` is a supporting experiment. |
| **Mode** | `R` = needs the emulator. `R+S` = a static prelude (grep, decode, ROM scan) first, then a runtime confirmation. `S` = answerable without the emulator. `D` = a decision or tooling fix, not an observation. `X` = already answered or closed (by an iteration, see the plan section 0 and A12). A trailing `†` = a static pointer exists (A12 section 8): the runtime job is to confirm it. |
| **Pri** | `P1` = changes the meaning of a widely used flag, field or routine, or is cheap and unblocks many others. `P2` = changes one routine's note or a named piece. `P3` = cosmetic, visual identification of rarely used assets, or dead-code confirmation. |

## Totals

| Mode | Count |
|------|------:|
| `R` runtime only | 295 |
| `R+S` static prelude, then runtime | 37 |
| `S` static only (incl. the 3 hidden-group ids) | 10 |
| `D` decision / tooling | 5 |
| `X` answered or closed | 11 |
| **All IDs** | **358** |

`†` rows (static pointer, confirm only) are inside `R` / `R+S`: OQ-23, I034-1, I057-4, I035-6, I023-3, I027-2, I030-2, I032-5, I036-4, I044-4, I037-2, I037-3, I042-1, I049-6 (half), I050-5, I051-1, I060-2, I060-3, I065-3.

| Priority | Count |
|----------|------:|
| P1 | 15 |
| P2 | 113 |
| P3 | 219 |
| answered or closed (no priority) | 11 |
| **All IDs** | **358** |

The ID list in this file was diffed against the ID list of `questions/*.md`: the two sets are identical (358 / 358, none missing, none extra); A12 section 2 confirms the total.

## Duplicate and overlap clusters

Answering the **canonical** row answers every member. Do the canonical experiment once, then cite the result under each member ID.

| Cluster | Canonical | Members |
|---------|-----------|---------|
| **CT69** Collision types `$06` / `$09` | OQ-16 | OQ-I029-5, OQ-I030-3, OQ-I032-4, OQ-I033-4, OQ-I040-4, OQ-SAN2-2 (direction half), OQ-I039-2, OQ-I039-3 |
| **ADHOC** adhoc DMA trigger-before-size order | OQ-45 | OQ-64, OQ-I022-4 |
| **F10-0200** player `$10` bit `$0200` readers (static answer exists, RC-01: confirm only) | OQ-I023-3 | OQ-I027-2, OQ-I030-2, OQ-I032-5, OQ-I036-4, OQ-60 (part) |
| **F10-2000** actor `$10` bit `$2000` | OQ-I026-6 | OQ-I025-2, OQ-I053-3, OQ-60 (part). OQ-I033-6 is **not** a member (it asks about the `$0E` priority word, not `$10` bit `$2000`; A12-09) |
| **F10-0008** actor `$10` bit `$0008` | OQ-20 | OQ-I023-6, OQ-60 (part) |
| **F10-0080/0400** `$0080`/`$0400` in combat | OQ-8 | OQ-I041-6, OQ-I049-3 |
| **FLAG00** per-scene event flag `#00` ("Shadow shimmer") | OQ-I030-1 | OQ-I048-1, OQ-I052-1. OQ-I048-5 is **not** a member (it asks about playerSpeedEw/Ns, not a scene flag; A12-09) |
| **AA-BITS** `$AA` bits `$0800`/`$0400` never set | OQ-I029-3 | OQ-I045-1 |
| **DMF** displayModeFlags consumers (RC-03: bits 0/4/5/14 are named) | OQ-23 | OQ-42, OQ-51, OQ-I034-1, OQ-I057-4, OQ-6 (remainder) |
| **LPF** layerPriorityFlag bit 12 / `$06EF` | OQ-36 | OQ-12, OQ-I059-5 |
| **HDR411** sprite-group header bytes 4-11 | OQ-I055-4 | OQ-I063-4 (duplicate). **Answered** (mode `X`). OQ-I066-4 splits: the reader half is answered, the damage-box half stays open (R) |
| **PBUNDLE** palette bundle appearance (**method only**: one shared procedure, but each id needs its own capture, not a copied answer) | OQ-I060-5 | OQ-I027-6, OQ-I028-6, OQ-I029-6, OQ-I031-4, OQ-I036-6, OQ-I040-3, OQ-I044-1. Not members: OQ-I060-6 (a static padding question, mode `S`) and OQ-I026-4 (stays OPEN, its own question) |
| **UNREF** unreferenced pieces / reachability (**method only**: same reachability procedure, per-piece answers) | OQ-I072-3 | OQ-I023-5, OQ-I034-3, OQ-I038-4, OQ-I039-4, OQ-I045-4, OQ-I048-4, OQ-I049-1, OQ-I049-7, OQ-I050-5, OQ-I057-2, OQ-I057-5, OQ-I067-4, OQ-I068-2. The hidden-group trio (OQ-I067-5, OQ-I069-4, OQ-I071-5) left this cluster: mode `S`, IT-33/34 |
| **DUP-29** | OQ-29 | OQ-I065-3 (same question; static half also `†`) |
| **DUP-B001-1** | OQ-B001-1 | OQ-I056-7 |
| **TOOL-LT** `extract:lt` vs `extract` ROM mismatch | OQ-I026-1 | OQ-49 |
| **TOOL-MSH** MenuSelectionHandler cannot take notes | OQ-I024-1 | OQ-59 |
| **GEM** gem anim blink | OQ-I049-5 | OQ-I051-7 |
| **CAM** camera targets recomputed (**method only**) | OQ-I050-2 | OQ-I049-4, OQ-I050-4, OQ-I025-7. OQ-SAN2-1 is not a member |
| **UPLOAD-31** DecompressGfxToVram / VRAM re-upload | OQ-31 | none. OQ-1 (LoadBgTiles cache-slot invalidation) is **not** a duplicate of OQ-31 (PaletteStep re-calls the decompressor): different mechanisms, answer each (A12-09) |

## B001 + legacy file `I001-I020_open-questions.md` (71 IDs)

| ID | Topic | Exp | Mode | Pri |
|----|-------|-----|------|-----|
| OQ-B001-1 | Which actor selects `spm_darkspace_sprites` anims #04-#09 | F1 + R1 | R+S | P3 |
| OQ-B001-2 | Overworld sprite anims #07-#0A one vehicle? | F1 + M3 | R | P3 |
| OQ-1 | Why LoadBgTiles modes invalidate neighbouring cache slots | W1 + E1 | R | P3 |
| OQ-2 | `$7F:0000-01FF` dual use (collision flags vs scratch) | W1 | R | P2 |
| OQ-3 | Tilemap word bit 9 as collision flag | B1 | R | P3 |
| OQ-4 | ReloadMapLayer1 reads `$0080` not `$06A0` | W1 | R | P3 |
| OQ-5 | display_preset_table records +8/+9 discarded | — | X | — |
| OQ-6 | Who sets `$09ED` bit 7 (sprite DMA suppress) | C4 | R | P3 |
| OQ-7 | Wrong comment in inventory_overlay (queued I034) | — | X | — |
| OQ-8 | actor `$10` bits `$0080`/`$0400` in RunCombatCollision | A2 + G1 | R | P1 |
| OQ-9 | Which actor is slot `$1000` in the bonus term | G1 | R | P3 |
| OQ-10 | 1-based music IDs; IDs `$0D`/`$17` | D1 + S1 | R+S | P2 |
| OQ-11 | Readers of scene_flag_table bytes `$40-$D0` | W1 | R | P3 |
| OQ-12 | `$7F0200-09FF` BG3 buffer overlaps `$7F0600` | W1 | R | P2 |
| OQ-13 | LoadPlayerGraphics skip scenes, `$0404` bank, flag `$FF` | W1 + R2 | R | P3 |
| OQ-14 | `$0D6E` two meanings; `$09CC/$09CE/$06CC` roles | W1 | R | P3 |
| OQ-15 | InitActorPool zeroes `$7F0E00`; what is `$7F3000` | W1 | R | P3 |
| OQ-16 | Collision tile types `$06` and `$09` | B1 + B2 | R | P1 |
| OQ-17 | AllocateSpecialActor failure; KillThinker `$5C`; `$5A` init | G3 + W1 | R | P3 |
| OQ-18 | `$06F0` default actor properties writer | W1 | R | P3 |
| OQ-19 | BranchIfItemEquipped with `$FFFF` | S1 | S | P3 |
| OQ-20 | `$10` bit 3: grounded or player-hit | A1 + A3 | R | P1 |
| OQ-21 | parallax_speed_config 03-0C reachable (bit 7 part resolved I009) | S1 | S | P3 |
| OQ-22 | Facing code order (0=S or 0=N) | — | X | — |
| OQ-23 | Consumer of displayModeFlags bit 0 | C4 | R† | P2 |
| OQ-24 | Y-row inconsistency (row-1 vs pixel>>4) | B2 | R | P2 |
| OQ-25 | AdvanceMapY page crossing | B2 + S1 | R+S | P3 |
| OQ-26 | Unchecked MarkSolid index ≥ `$4000` | S1 | S | P3 |
| OQ-27 | PrintNumber over 4 digits; `$00DC` | M4 + W1 | R | P3 |
| OQ-28 | `$0AC8-4` selects FacingData tables | P1 | R | P3 |
| OQ-29 | Chest fanfare tracks; `$06F2` is current music | D1 | R | P2 |
| OQ-30 | Warp byte 9 bit 7 "save warp" scenes | S1 + R2 | R+S | P2 |
| OQ-31 | PaletteStep re-calls DecompressGfxToVram each frame | E2 + W1 | R | P3 |
| OQ-32 | SetupHdmaChannel carry; channel range | E4 | R | P3 |
| OQ-33 | PrintBcdNumber tile `$20` blank? | M4 | R | P3 |
| OQ-34 | DrawBox cursor spacing | M4 | R | P3 |
| OQ-35 | ComposeDigits_Continuation shift | M4 | R | P3 |
| OQ-36 | What sets layerPriorityFlag bit 12 | W1 | R | P2 |
| OQ-37 | Map screen is Start toggle? | M3 | R | P3 |
| OQ-38 | actor `$10` bit 4 in iframe blink gate | A1 | R | P2 |
| OQ-39 | Item re-trigger on closing inventory | M1 | R | P3 |
| OQ-40 | `$10` bits 0/1 consumers; STZ `$070F` | A2 + W1 | R | P3 |
| OQ-41 | `$069A/$069C` wrap modulus power of two | B1 | R | P3 |
| OQ-42 | Requester of partial BG3 upload; hudDisableFlag setters | C4 | R | P2 |
| OQ-43 | ComputeFollowStep loopCounter 0 / ≥16 | S1 + N1 | R+S | P3 |
| OQ-44 | Aim 8 px above target; chatPtr bit 15 users | N1 | R | P3 |
| OQ-45 | AdhocVramDma trigger-before-size race | C1 | R | P2 |
| OQ-46 | InitGravity negation | S1 | S | P3 |
| OQ-47 | CameraPanUp/Left clamp path | N4 | R | P3 |
| OQ-48 | MusicRenderSync waits `$48` frames | D1 + M4 | R | P3 |
| OQ-49 | extract:lt vs extract ROM mismatch | T1 | D | P2 |
| OQ-50 | Warmboot byte `$0100` vestigial | C3 | R | P3 |
| OQ-51 | displayModeFlags bit 13 reader | C4 | R | P2 |
| OQ-52 | `$09BE/$09C0/$09C4` readers | W1 | R | P3 |
| OQ-53 | enemyHealthTimer 25 / 30 dead | W1 + G2 | R | P3 |
| OQ-54 | Dialogue COPs clear `$10` bit 11 | A3 + N4 | R | P3 |
| OQ-55 | StageMove speed ≥ `$80` | N4 | R | P3 |
| OQ-56 | MoveToward distance < speed | N4 | R | P3 |
| OQ-57 | Camera scroll actor ratios; `$12` bit 12; `$06C8` | P4 + W1 | R | P3 |
| OQ-58 | DisplaySceneTitle centering; longest title | M4 + S1 | R+S | P3 |
| OQ-59 | MenuSelectionHandler note tooling | T1 | D | P3 |
| OQ-60 | `$10` bits `$2008`/`$0008`/`$0200`/`$1000` in audio + forced walk | A1 | R | P1 |
| OQ-61 | SpcCheckMusicReady has no fade logic | — | X | — |
| OQ-62 | QueueVisibleTileVram flag contract | N4 + W1 | R | P3 |
| OQ-63 | Radar icon meanings / colours | M3 | R | P3 |
| OQ-64 | RadarScreenSetup trigger-before-size | — | X | — |
| OQ-65 | CopyActorState spawner slot in `$24` | W1 | R | P3 |
| OQ-66 | UnlinkActor leaves `$58` stale | G3 + W1 | R | P3 |
| OQ-67 | Lifetime of wramFlags `$0A80-$0A9F` | G2 + W1 | R | P2 |
| OQ-68 | WramFlag_Offset100 reaches `$0AA0` | S1 + W1 | R+S | P3 |
| OQ-69 | SetEntryHere stray `$03`; LoopStart count 0 | N4 + S1 | R+S | P3 |

Notes: OQ-61 and OQ-64 are closed (I021 and I022). OQ-64's residual question lives on as OQ-I022-4. OQ-21's bit-7 part is resolved, so only the static remainder is open.

## I021 - I030 (55 IDs)

| ID | Topic | Exp | Mode | Pri |
|----|-------|-----|------|-----|
| OQ-I021-1 | Decompressor dictionary `$7E:0200` vs sort buckets | W1 | R | P2 |
| OQ-I021-2 | FadeThenStartMusic: does `$F1` fade audibly | D2 | R | P2 |
| OQ-I021-3 | `$F2` / `$F0` command names in SpcMusicLoadCmd | D2 + S1 | R+S | P2 |
| OQ-I021-4 | Runtime thinkers lacking animScratch2 bit 11 | W1 + S1 | R+S | P3 |
| OQ-I022-1 | `$12` bit 1 mirror lock setter/clearer | A1 | R | P3 |
| OQ-I022-2 | SpcBlockTransfer first-chunk destination | D3 | S | P3 |
| OQ-I022-3 | Loader resets DSP/echo? | D2 | R | P3 |
| OQ-I022-4 | adhocVramDma writers running with NMI on | C1 + C2 | R | P3 |
| OQ-I023-1 | What the 29 glide triggers do | B4 | R | P3 |
| OQ-I023-2 | Reader of player statsPtr `$7F0020` after glide | W1 | R | P3 |
| OQ-I023-3 | Reader of player `$10` bit `$0200` (confirm RC-01) | A2 | R† | P2 |
| OQ-I023-4 | item_use DrawMetatileHere coordinates | M1 | R | P3 |
| OQ-I023-5 | WorldMapStream3/4 dead; extendedFlags bit 2 | R1 + S1 | R+S | P3 |
| OQ-I023-6 | ClimbX clearing `$10` bit `$0008` while `$2000` set | A3 | R | P3 |
| OQ-I024-1 | MenuSelectionHandler notes wrong, cannot be edited | T1 | D | P3 |
| OQ-I024-2 | Consumers of `$0B14`, `$5E/$60/$62`, `$0648` init values | W1 | R | P3 |
| OQ-I024-3 | Readers of `$090E/$0910` | W1 | R | P3 |
| OQ-I024-4 | MEMSEL set then reset; SPC upload at slow speed | C3 | R | P3 |
| OQ-I024-5 | DispatchEastMove calls ProbeLeftTiles - naming (live label: FindSlopeForEastMove) | B3 | R | P3 |
| OQ-I024-6 | Writers/format of `$7F0C00-02` (COLDATA bytes) | W1 + E1 | R | P2 |
| OQ-I025-1 | Player `$10` bit `$0100` and `$12` bit `$0001` | A1 + A2 | R | P1 |
| OQ-I025-2 | Setter of player `$10` bit `$2000` | A1 | R | P1 |
| OQ-I025-3 | Double-tap run window of 13 frames | P1 | R | P1 |
| OQ-I025-4 | AttackNorth uses BranchIfSolidSouth | P2 | R | P2 |
| OQ-I025-5 | Lunge (Ranged*) and scene `$E8` Projectile* actors | P2 + N2 | R | P3 |
| OQ-I025-6 | Bits `$0700` ORed into interacted NPC `$10` | A3 + N1 | R | P2 |
| OQ-I025-7 | CameraShakeFrame drift | P4 | R | P2 |
| OQ-I026-1 | extract:lt vs extract ROM (tooling) | T1 | D | P2 |
| OQ-I026-2 | Lola's Melody replay in Itory (scene `$15`) | M1 + W1 | R | P2 |
| OQ-I026-3 | WindFlute with full actor pool | G3 + M1 | R | P3 |
| OQ-I026-4 | Palette bundles `$10` / `$0E` (death fade) | E2 | R | P3 |
| OQ-I026-5 | ToggleActorVisibilityFlag flicker, helper lifetime | A3 + N1 | R | P3 |
| OQ-I026-6 | Actor `$10` bit `$2000` two readers | A1 + A3 | R | P1 |
| OQ-I027-1 | `$16 == $0020` wait split in AuraBarrier / DarkFriar | P2 | R | P2 |
| OQ-I027-2 | Reader of player `$10` bit 9 (confirm RC-01) | A2 | R† | P2 |
| OQ-I027-3 | Dark Friar fragment directions | P2 | R | P3 |
| OQ-I027-4 | Psycho Dash displacement | P2 | R | P2 |
| OQ-I027-5 | ability_anim_tables note rewrite | — | X | — |
| OQ-I027-6 | Bundle `#1F` and `#40` flashes (Moon Tribe, Kara) | E2 | R | P3 |
| OQ-I028-1 | Arrange confirm mask `$8044` (X/Y confirm) | M1 | R | P2 |
| OQ-I028-2 | ArrangePerformSwap equip cursor | M1 | R | P2 |
| OQ-I028-3 | UseItemTab leaves slot 0 as equipped? | M1 | R | P2 |
| OQ-I028-4 | Tile `$2060` blank | M4 | R | P3 |
| OQ-I028-5 | ComputeAbilityIndex "+1" | M1 + S1 | R+S | P3 |
| OQ-I028-6 | Fixed-colour ramps `#1B` / `#1C` | E1 | R | P3 |
| OQ-I029-1 | `$05`/`$0A` west-walk direction; names backwards? | — | X | — |
| OQ-I029-2 | Stack word `$05,S` in DiagClearReturnFlags (live label: CancelVerticalPhase) | B3 | R | P2 |
| OQ-I029-3 | `$AA` bits `$0800/$0400`, `$AB` bits 2/3/7 dead | W1 | R | P2 |
| OQ-I029-4 | DiagPushRight direction (live label: WallSlidePushDown) | — | X | — |
| OQ-I029-5 | Collision types `$06` / `$09` (CT69) | B1 + B2 | R | P1 |
| OQ-I029-6 | Flash `#18` / `#19` colours | E2 | R | P3 |
| OQ-I030-1 | Meaning of event flag `#00` (FLAG00) | W1 + N1 | R | P1 |
| OQ-I030-2 | Player `$10` bit `$0200` ignores enemy hits in boss defeat (confirm RC-01) | A2 + N2 | R† | P2 |
| OQ-I030-3 | Which real maps hit `$06`/`$09` (CT69) | B1 | R | P1 |
| OQ-I030-4 | slope_ramp_physics MapCellDown/Up probe | B4 | R | P3 |

## I031 - I040 (57 IDs, plus the 2 sanity rows)

| ID | Topic | Exp | Mode | Pri |
|----|-------|-----|------|-----|
| OQ-I031-1 | Credits window variant 1 look | E4 | R | P3 |
| OQ-I031-2 | Mu lair (scene 67) window 1 enable | E4 + W1 | R | P3 |
| OQ-I031-3 | W12SEL `$33` / WOBJSEL `$03` meaning | E4 + S1 | R+S | P3 |
| OQ-I031-4 | ambient_palette_cycler bundles | E2 | R | P3 |
| OQ-I031-5 | EnemyDeathFlash anim #01 and `$2000` | F1 + G2 | R | P3 |
| OQ-I032-1 | DecelerateNS resets slopeStepCounter | B3 | R | P2 |
| OQ-I032-2 | ClampSpeeds NS only when EW is zero | B3 | R | P2 |
| OQ-I032-3 | Moving vs stopped slope probe points | B3 | R | P2 |
| OQ-I032-4 | `$06`/`$09` cell below/above (CT69) | B1 + B3 | R | P1 |
| OQ-I032-5 | Reader of player `$10` bit `$0200` (confirm RC-01) | A2 | R† | P2 |
| OQ-I032-6 | sine_hdma_slow_wave scenes `$32`, `$E9/$EA` | E4 | R | P3 |
| OQ-I033-1 | FineAdjustXEast with `$02 > 16` | B2 | R | P2 |
| OQ-I033-2 | SouthWallSouthInteract snap | B2 | R | P2 |
| OQ-I033-3 | Slope types `$03`/`$0C` diagonal | B2 | R | P2 |
| OQ-I033-4 | `$06`/`$09` diagonal wall pieces (CT69) | B2 | R | P1 |
| OQ-I033-5 | Scenes `$23`, `$27` fixed colour | E1 | R | P3 |
| OQ-I033-6 | `$0E = $2000` priority change on NPCs | A3 + F1 | R | P2 |
| OQ-I034-1 | displayModeFlags bit 14 (DMF) | C4 | R† | P2 |
| OQ-I034-2 | Scene `$30` tint add or subtract | E1 | R | P3 |
| OQ-I034-3 | idle_sprite_display used? 5 gems? | R1 + R3 | R+S | P3 |
| OQ-I034-4 | Inventory cache slots; zeroed words | W1 + M1 | R | P2 |
| OQ-I034-5 | Inventory scene overwrites sine tables | M1 + W1 | R | P3 |
| OQ-I034-6 | Thinker wait counters zeroed at close | M1 | R | P3 |
| OQ-I035-1 | Parallax table types on screen | E4 | R | P3 |
| OQ-I035-2 | Why `$0060 = 1`, `$005E = 0` left behind | W1 | R | P3 |
| OQ-I035-3 | Parallax accumulator clear range | E4 + W1 | R | P3 |
| OQ-I035-4 | Table type `$20` window (scene `$C3`) | E4 | R | P3 |
| OQ-I035-5 | BG3 vertical scroll steps in inventory | M1 + E1 | R | P3 |
| OQ-I035-6 | Reader of hpToHeal `$0B22` | W1 | R† | P2 |
| OQ-I035-7 | parallax_scroll_table unselected entries | R2 + S1 | R+S | P3 |
| OQ-I036-1 | Ramp exact-equality trigger | B4 | R | P2 |
| OQ-I036-2 | Ramp launch distance and landing | B4 | R | P2 |
| OQ-I036-3 | StagePlayerMoveXY anim indices | F1 + B4 | R | P3 |
| OQ-I036-4 | Reader of player `$10` bit `$0200` (confirm RC-01) | A2 | R† | P2 |
| OQ-I036-5 | flag_gated_palette replays? | E2 + N1 | R | P3 |
| OQ-I036-6 | Bundles `$02`, `$4C` appearance | E2 | R | P3 |
| OQ-I036-7 | Full pool breaks east/west climb | G3 | R | P3 |
| OQ-I037-1 | Statue / block pull toward player | N1 | R | P2 |
| OQ-I037-2 | LoopEnd yields once per pass | N4 | R† | P2 |
| OQ-I037-3 | BranchOnPlayerX/Y operand order | N4 + S1 | R+S† | P2 |
| OQ-I037-4 | `$12` OR `$0030`, extendedFlags `$0080` (laborer, kidnapper) | G1 + A2 | R | P2 |
| OQ-I037-5 | RandomPlayerOffset rerun after wait | N1 | R | P3 |
| OQ-I038-1 | Column-crossing Y formulas | B2 | R | P2 |
| OQ-I038-2 | Corner-snap Y compensation | B2 | R | P2 |
| OQ-I038-3 | ActorMidpointCalc with `$06 = 0` | N4 | R | P3 |
| OQ-I038-4 | camera_delta_oscillator spawned? | R1 + R3 | R+S | P3 |
| OQ-I038-5 | EastRampDown samples top row | B2 | R | P3 |
| OQ-I039-1 | slopeFracAccum slowdown ~56 % | B2 | R | P2 |
| OQ-I039-2 | SouthWallNudge conditions (CT69) | B2 | R | P2 |
| OQ-I039-3 | SnapYNorthCollision push 1..16 px | B2 | R | P2 |
| OQ-I039-4 | NorthProbeRedirect pair dead? | R1 | R | P3 |
| OQ-I039-5 | `$09AF` bit `$10` effect | B2 | R | P3 |
| OQ-I039-6 | SpawnDebrisBurst count and `$0302` | N1 | R | P3 |
| OQ-I040-1 | large_ramp_booster once per approach | B4 | R | P3 |
| OQ-I040-2 | Booster NS-only gate increments EW | B4 | R | P3 |
| OQ-I040-3 | Palette flag `#01` scenes `$FD/$FF`, bundle `#03` | E2 + M3 | R | P3 |
| OQ-I040-4 | East wall-slide push directions (CT69) | B2 | R | P2 |
| OQ-SAN2-1 | CameraShakeActor sound `#15` each tick | P4 + D1 | R | P2 |
| OQ-SAN2-2 | FineAdjustXWest direction after fix (CT69) | B2 | R | P2 |

## I041 - I050 (53 IDs)

| ID | Topic | Exp | Mode | Pri |
|----|-------|-----|------|-----|
| OQ-I041-1 | `$7F0B22` / `$7F0B24` | W1 | R | P2 |
| OQ-I041-2 | Mode 7 maths vs picture | E3 | R | P2 |
| OQ-I041-3 | Mode 7 HDMA tables collide with staging buffers | E3 + W1 | R | P2 |
| OQ-I041-4 | Divisor overflow path taken? | E3 | R | P3 |
| OQ-I041-5 | Damage number after victim slot reuse | G1 + G3 | R | P3 |
| OQ-I041-6 | Child flags `$0400`; `$1000` only in second path | G1 + A2 | R | P2 |
| OQ-I041-7 | Hidden jewel appearance / hide after pickup | F1 + N1 | R | P3 |
| OQ-I042-1 | Hit sparkle reachable | G2 + R1 | R† | P3 |
| OQ-I042-2 | Tiles `$7A/$7B` appearance | F1 | R | P3 |
| OQ-I042-3 | floor_button flag `$0F` consumer, scene 87 | N1 + W1 | R | P2 |
| OQ-I042-4 | `$12` bit `$0001` (not bit 1) iframe mode; HUD bar for HP `$FF` | G1 | R | P3 |
| OQ-I042-5 | Edward's Castle exit `Y == $2D0` | M3 | R | P2 |
| OQ-I042-6 | Exit side effects `$0D60`, gfxCacheIdxB | M3 + W1 | R | P3 |
| OQ-I042-7 | Flag `$01` left set at Itory | W1 + R2 | R | P2 |
| OQ-I042-8 | "Quit only" menus reachable | M3 | R | P3 |
| OQ-I043-1 | town_door first pass AnimOnce | N1 | R | P3 |
| OQ-I044-1 | Gold Ship flags `$4D`/`$52`, palette phases | E2 + N2 | R | P3 |
| OQ-I044-2 | Flags12 bit `$0200` meaning | A1 + A3 | R | P2 |
| OQ-I044-3 | Yielding chat routine and restore | N4 | R | P3 |
| OQ-I044-4 | A button feeds interact bit in this build | P1 | R† | P2 |
| OQ-I045-1 | `$AA` bits `$0800/$0400` set? (AA-BITS) | W1 | R | P2 |
| OQ-I045-2 | Rain drop survival and lifetime | N1 | R | P3 |
| OQ-I045-3 | Position publish between phases | B3 | R | P3 |
| OQ-I045-4 | particle_rain_spawner reachable | R1 + R3 | R+S | P3 |
| OQ-I045-5 | Orbit angle `$40` = east? | N4 | R | P3 |
| OQ-I046-1 | Hitstun sound `#07` vs `#08` | G3 + D1 | R | P3 |
| OQ-I046-2 | Hitstun with full pool | G3 | R | P3 |
| OQ-I046-3 | Cut-short slide zeroes chain | G3 | R | P3 |
| OQ-I046-4 | EnemyDefeatDispatch with `$0AEC = 0` | G2 | R | P3 |
| OQ-I046-5 | Actors with knockback tier ≥ 2 | G4 + S1 | R+S | P3 |
| OQ-I046-6 | Three-enemy gem drop sequence | G2 | R | P3 |
| OQ-I047-1 | iframeCounter stops movement | G3 + B3 | R | P2 |
| OQ-I047-2 | Pickup pass: player and companions still run | G2 + A2 | R | P2 |
| OQ-I047-3 | Statue sprite pedestal pixels | M1 | R | P3 |
| OQ-I048-1 | Shimmer fast cycle in 26 scenes (FLAG00) | N1 + W1 | R | P2 |
| OQ-I048-2 | Statue ceremony PPU writes persist | E1 + N2 | R | P3 |
| OQ-I048-3 | Confetti burst count | N2 | R | P3 |
| OQ-I048-4 | dialog_string_scanner reachable | R1 + R3 | R+S | P3 |
| OQ-I048-5 | playerSpeedEw/Ns zero when walking | B3 | R | P2 |
| OQ-I049-1 | debug_man ever spawned | R1 + R3 | R+S | P3 |
| OQ-I049-2 | debug_man 21 destinations load | N2 + H3 | R | P3 |
| OQ-I049-3 | Drop pickup `$10` bit `$0400` | A1 + G2 | R | P2 |
| OQ-I049-4 | Camera vertical target Y-`$80` | P4 | R | P3 |
| OQ-I049-5 | Gem pickup blink (GEM) | F1 + G2 | R | P3 |
| OQ-I049-6 | Drop probabilities (static half †) | G2 | R† | P2 |
| OQ-I049-7 | camera_scroll_controller `$EB48/$EB74` executed | R1 | R | P3 |
| OQ-I050-1 | Stat-up reset `$7F` to `$55` in play | G2 + M1 | R | P2 |
| OQ-I050-2 | camera_drift offsets survive (CAM) | P4 | R | P2 |
| OQ-I050-3 | NPC wander step length | N1 | R | P3 |
| OQ-I050-4 | `$24 = $FFFF` in CameraDriftPatterned | P4 | R | P3 |
| OQ-I050-5 | binary_00D068 last 8 words used | R1 + R3 | R+S† | P3 |
| OQ-I050-6 | Heal sparkle position per GiveItemToPlayer caller | G2 + M1 | R | P3 |
| OQ-I050-7 | NPC skips 120-frame wait | N1 | R | P3 |

## I051 - I060 (64 IDs)

| ID | Topic | Exp | Mode | Pri |
|----|-------|-----|------|-----|
| OQ-I051-1 | effect_velocity_init integration every frame | N4 + P4 | R† | P2 |
| OQ-I051-2 | Reader of forcedScrollOverride `$06C8` | W1 | R | P2 |
| OQ-I051-3 | boss_clear_reward_handler uses `$04` as scratch | W1 + G2 | R | P2 |
| OQ-I051-4 | Reader of `$7F0010` `$FFFF` | W1 | R | P3 |
| OQ-I051-5 | Room-tier stat item scene flag set? | G2 | R | P2 |
| OQ-I051-6 | Collision byte `$0E` in drop probe | B1 | R | P3 |
| OQ-I051-7 | Gem anims `$09/$0A/$0B`, lifetime (GEM) | F1 + G2 | R | P3 |
| OQ-I052-1 | Flag `#00` in PlayerIdleAnimLoop (FLAG00) | W1 + F1 | R | P2 |
| OQ-I052-2 | Body table entry 4 frame `$20` | F1 | R | P3 |
| OQ-I052-3 | Fall landing position | N2 + B3 | R | P3 |
| OQ-I052-4 | Terrain type `$04`; scan terminates | B1 | R | P2 |
| OQ-I052-5 | Player `$10` bit `$0002` | A1 | R | P2 |
| OQ-I052-6 | SpawnFieldRevealEffect rise and dstX | N1 + G2 | R | P3 |
| OQ-I052-7 | GetPlayerFacingDirection ≥ 4 | P1 + W1 | R | P3 |
| OQ-I052-8 | Ring entry 9 `$7EDF40` read | W1 + N1 | R | P3 |
| OQ-I052-9 | Spark frame `$2A` | F1 | R | P3 |
| OQ-I053-1 | smooth_follow_child keeps heading | N1 | R | P3 |
| OQ-I053-2 | Callers' speeds and `$0B02` | N1 + W1 | R | P3 |
| OQ-I053-3 | Player hidden after DarkSpaceEnterWarp | N3 + A1 | R | P2 |
| OQ-I053-4 | Dao portal priority vs walls | F1 + E1 | R | P3 |
| OQ-I053-5 | Anim `#1C` same picture in two places | F1 | R | P3 |
| OQ-I053-6 | Game-over sparkle spiral | N2 + F1 | R | P3 |
| OQ-I053-7 | Game over in scene `$E8` respawns as Shadow | N2 + G2 | R | P2 |
| OQ-I054-1 | Boot logo OBJ palettes | — | X | — |
| OQ-I054-2 | Init of `$0AEC` / `$0AEE` | G2 + W1 | R | P2 |
| OQ-I054-3 | Effects need `$12 $1000` with displayModeFlags `$0080` | G2 + A2 | R | P2 |
| OQ-I054-4 | SetSpritePalette `#00` at EnemyStatBonusReward head | G2 | R | P3 |
| OQ-I054-5 | Enemies by gem type; real drop rates | G4 + G2 | R+S | P2 |
| OQ-I055-1 | Logo sprite groups and palette-4 parts | M2 + F1 | R | P3 |
| OQ-I055-2 | Colour effect finishes while logo visible | M2 | R | P3 |
| OQ-I055-3 | Event flag `$10` cleared by soft reset | M2 + C3 | R | P3 |
| OQ-I055-4 | Header bytes 4-11 read (HDR411) | — | X | — |
| OQ-I055-5 | AnimLoop ends after exactly 120 ticks | M2 | R | P3 |
| OQ-I056-1 | Will ability transform when player is Shadow | N3 | R | P2 |
| OQ-I056-2 | FireflyParticle direction and X range | N3 | R | P3 |
| OQ-I056-3 | BG changes `$86-$8F` pictures | N3 + F1 | R | P3 |
| OQ-I056-4 | globalScriptIndex = 1 only in the pyramid | N3 + W1 | R | P2 |
| OQ-I056-5 | GaiaContinueJourney fades to `$0E` while room plays `$16` | N3 + D1 | R | P2 |
| OQ-I056-6 | Scene `$09` reachable | R2 | R | P3 |
| OQ-I056-7 | Dark Space anims #04-#09 (B001-1) | F1 + R1 | R | P3 |
| OQ-I056-8 | diary_entry_table camera vs map position | M2 + E3 | R | P3 |
| OQ-I056-9 | rebuild failure after extract:lt | T1 | D | P2 |
| OQ-I057-1 | Button Type 1/2 under the remap (needs rebuilt ROM) | P1 + M2 | R | P1 |
| OQ-I057-2 | Unreferenced debug routines | R1 + R3 | R+S | P3 |
| OQ-I057-3 | Highlight bands look | E4 + M2 | R | P3 |
| OQ-I057-4 | displayModeFlags bit 14 in scene `$FA` (DMF) | C4 | R† | P2 |
| OQ-I057-5 | TitlePaletteFadeStep reachable | R1 + R3 | R+S | P3 |
| OQ-I057-6 | DiaryEraseExecute `$1C → $1A` | M2 | R | P3 |
| OQ-I058-1 | World map below boundary row | E3 + M3 | R | P3 |
| OQ-I058-2 | sprite_group_000008 comet | M2 + F1 | R | P3 |
| OQ-I059-1 | animScratch2 OR `$0804` on child | M3 | R | P3 |
| OQ-I059-2 | Palette reset thinker spawned twice | M3 + E2 | R | P3 |
| OQ-I059-3 | World-map animations 1-5, 7-D | M3 + F1 | R | P3 |
| OQ-I059-4 | `$B8` at zoom-out start | E3 + M3 | R | P3 |
| OQ-I059-5 | Name text path in `$FE` (LPF) | M3 + W1 | R | P2 |
| OQ-I059-6 | Leader dot animation during zoom-out | M3 | R | P3 |
| OQ-I059-7 | LookupMapName miss | M3 + S1 | R+S | P3 |
| OQ-I059-8 | `$FE` second route path `$0D5C`, `$0D5E` | M3 + W1 | R | P3 |
| OQ-I060-1 | Menu ids `$00`, `$1C-$26` never staged | R2 + W1 | R | P2 |
| OQ-I060-2 | Route step n or n+1 ticks (static: n+1, IT-09) | M3 | R† | P3 |
| OQ-I060-3 | Choice id mask `$1F` | M3 | R† | P3 |
| OQ-I060-4 | Instruction after DialogueOptions reached | M3 + N4 | R | P3 |
| OQ-I060-5 | Remaining ~120 palette bundles (PBUNDLE) | E2 + R1 | R+S | P3 |
| OQ-I060-6 | Empty one-byte bundles are padding | S1 | S | P3 |

## I061 - I072 (56 IDs)

| ID | Topic | Exp | Mode | Pri |
|----|-------|-----|------|-----|
| OQ-I061-1 | Who reaches body_table rows `$03`, `$08` | W1 + P2 | R | P2 |
| OQ-I061-2 | direction_velocity_table repeats; step codes | N4 + S1 | R+S | P3 |
| OQ-I061-3 | 16 scene ids sharing scene_event_0C8200 loadable | R2 | R | P3 |
| OQ-I062-1 | Tile-streaming high byte `$0A` | F1 + N1 | R | P3 |
| OQ-I062-2 | Ability damage record word 0; climb damage byte | G1 + P2 | R | P2 |
| OQ-I062-3 | ApplyMovementWithCollision chain advance | N4 | R | P2 |
| OQ-I062-4 | Which of 85 chains used | R1 + S1 | R+S | P3 |
| OQ-I063-1 | Shared words `$00`, `$03`, `$0D` never selected | M4 + R1 | R | P3 |
| OQ-I063-2 | Freedan table anim indices | F1 + R1 | R | P3 |
| OQ-I063-3 | snake_pit_fx also puts OAM sprite | F1 | R | P3 |
| OQ-I063-4 | Header bytes 4-11 (HDR411; duplicate of OQ-I055-4) | — | X | — |
| OQ-I063-5 | Lone set `0E86AE` | F2 + S1 | R+S | P3 |
| OQ-I064-1 | Extended warp pan lists per warp | R2 + S1 | R+S | P2 |
| OQ-I064-2 | Freejia tile streams `$3FE0/$3FF0` | F1 + W1 | R | P3 |
| OQ-I064-3 | Will flute frames | M1 + F1 | R | P3 |
| OQ-I064-4 | Will table anims `$04-$07`, `$14-$17` | F1 + R1 | R | P3 |
| OQ-I065-1 | Speaker template glyph vs outline colour | M4 | R | P3 |
| OQ-I065-2 | Scenes without scene_meta record loadable | R2 | R | P2 |
| OQ-I065-3 | musicParentActor `$06F2` is BGM id (duplicate of OQ-29) | D1 + W1 | R† | P2 |
| OQ-I065-4 | Unused LoadBgTiles mode 3 / FullGraphics paths | R2 + R1 | R | P3 |
| OQ-I065-5 | Spritemap second operand / size word | S1 + F1 | R+S | P3 |
| OQ-I065-6 | Template `$10` duplicates `$0F` | M4 | R | P3 |
| OQ-I066-1 | 16 unreferenced stats rows | G4 + W1 | R+S | P2 |
| OQ-I066-2 | Which attacks use which hit path | G1 | R | P1 |
| OQ-I066-3 | OBSEL name base `$4000` | E1 + F1 | R | P3 |
| OQ-I066-4 | Aura body boxes hurt enemies (HDR411: reader half answered, damage half open) | F3 + G1 | R | P2 |
| OQ-I066-5 | Shadow one-frame lists `$19-$1B` etc. | F1 + R1 | R | P3 |
| OQ-I067-1 | Blank-name items shown through GiveItemToPlayer | M1 + M4 | R | P2 |
| OQ-I067-2 | Items `$15-$19` all "Teapot" | M1 + S1 | R+S | P2 |
| OQ-I067-3 | spriteset_will_projectile tiles (scene `$E8`) | F1 + N3 | R | P3 |
| OQ-I067-4 | spriteset_ability_fx anims `$04`, `$0C`, `$11` unused | R1 + F1 | R | P3 |
| OQ-I067-5 | Orphan groups `0FCF65`, `0FD5E8` (hidden groups) | IT-33/34 | S | P3 |
| OQ-I068-1 | npc_props anims `$02,$05,$07,$0A` | F1 | R | P3 |
| OQ-I068-2 | npc_props `$03`, `$09` unused | R1 | R | P3 |
| OQ-I068-3 | Scenes per display preset; mode-7 presets | R2 + S1 | R+S | P2 |
| OQ-I068-4 | Forced-walk stream bytes `$04`/`$05` | R2 + N4 | R | P3 |
| OQ-I068-5 | ForcedWalkEast/West reachable | R1 + W1 | R | P3 |
| OQ-I069-1 | spriteset_shadow_fx / body row `$07` | W1 + R1 | R | P3 |
| OQ-I069-2 | Other spriteset_enemies anims | F1 + R1 | R | P3 |
| OQ-I069-3 | spriteset_freedan_fx groups | F1 + P2 | R | P3 |
| OQ-I069-4 | Group `0EEEB8` staged (hidden group) | IT-33/34 | S | P3 |
| OQ-I070-1 | Dictionary substitution rule (rebuild) | S1 + T1 | S | P2 |
| OQ-I070-2 | spriteset_dark_friar groups, VRAM layout | P2 + F1 | R | P3 |
| OQ-I070-3 | 87 reward-tier scenes reachable; boss ranges | G2 + S1 | R+S | P2 |
| OQ-I071-1 | Shadow Aura animations | F1 + P2 | R | P3 |
| OQ-I071-2 | Aura palette and exit | F1 + P2 | R | P3 |
| OQ-I071-3 | Flag-only chests scenes `$60/$61`, flag `$2E` | M1 + W1 | R | P2 |
| OQ-I071-4 | Inventory sprite sets `$40-$43` | M1 + F1 | R | P3 |
| OQ-I071-5 | Five hidden groups at `$10:8B82...` | IT-33/34 | S | P3 |
| OQ-I071-6 | `$37` shares group with statues `$38/$39` | M1 | R | P3 |
| OQ-I072-1 | Index `$38-$3F`: Mystic Statue or Mystery Doll | M1 + M4 | R | P2 |
| OQ-I072-2 | `$18` Will, `$25` Lola's Letter discardable | M1 | R | P2 |
| OQ-I072-3 | Unreferenced strings and thinker lists (UNREF) | R1 + R3 | R+S | P3 |
| OQ-I072-4 | Spin Dash StagePlayerSprite override resolves | P2 | R | P2 |
| OQ-I072-5 | `$20` hold pose | F1 + N2 | R | P3 |
| OQ-I072-6 | Untraced spriteset_will_alt indices | R1 + P2 | R | P3 |

## Quick filters

### P1 (do first)

OQ-8, OQ-16, OQ-20, OQ-60, OQ-I025-1, OQ-I025-2, OQ-I025-3, OQ-I026-6, OQ-I029-5, OQ-I030-1, OQ-I030-3, OQ-I032-4, OQ-I033-4, OQ-I057-1, OQ-I066-2.

These 15 IDs need about **five** distinct investigations: A1 (flag-bit census, covers OQ-8, 20, 60 and the `$2000` / `$0100` rows), B1+B2 (collision types), W1 (event flag `#00`), M2 on the plain build (button remap, OQ-I057-1), G1 (hit paths). The `$0200` reader family (OQ-I023-3, I027-2, I030-2, I032-5, I036-4) was demoted to P2: the answer is static (RC-01), A2 only confirms it. OQ-22 (facing) is answered.

### Static-only rows (no emulator needed)

OQ-19, OQ-21, OQ-26, OQ-46, OQ-I022-2, OQ-I060-6, OQ-I070-1, the hidden-group trio OQ-I067-5, OQ-I069-4, OQ-I071-5 (IT-33/34), plus the static preludes marked `R+S`. Run these during the harness session as `rg` / decode work while waiting for frames. The `†` rows are runtime confirmations of a static answer: read the A12 pointer first.

### Decision / tooling rows

OQ-49 (= OQ-I026-1), OQ-59 (= OQ-I024-1), OQ-I056-9, OQ-I070-1 (decode part). These are not observations. They need a change in `gaia-core`, a baserom `transforms.json` entry, or a merge spec. Plan campaigns S1 and T1 hand them to audit-of-audit IT-35 and IT-26/27/30.

### Answered or closed (mode `X`)

OQ-5, OQ-7, OQ-22, OQ-61, OQ-64, OQ-I027-5, OQ-I029-1, OQ-I029-4, OQ-I054-1, OQ-I055-4, OQ-I063-4. Two more are partly resolved: OQ-6 (I012) and OQ-21 (I009). OQ-I066-4 is half answered (HDR411 reader half).

## Changes from the first version

| Item | First version | Now | Source |
|------|---------------|-----|--------|
| Heading counts (I021-I030 / I031-I040 / I051-I060 / I061-I072) | 56 / 53 / 63 / 60 | 55 / 57 (+2 sanity) / 64 / 56 | row count per section |
| Mode `R` / `R+S` / `S` / `D` / `X` | 302 / 39 / 8 / 7 / 2 | 295 / 37 / 10 / 5 / 11 | rows in this file |
| Priority P1 / P2 / P3 / closed | 21 / 112 / 222 / 2 (sum 357) | 15 / 113 / 219 / 11 (sum 358) | rows in this file |
| Answered rows | OQ-61, OQ-64 | + OQ-5, 7, 22, I027-5, I029-1, I029-4, I054-1, I055-4, I063-4 | A12-08 and the apply files |
| Hidden-group trio | `R` / `R+S` | `S` | IT-33/34 |
| `$0200` reader family | P1 | P2, `†` | A12 section 8 (RC-01) |
| F10-2000, FLAG00 | included OQ-I033-6, OQ-I048-5 | removed | A12-09 |
| PBUNDLE | included OQ-I026-4, OQ-I060-6 | removed, marked method only | A12-09 |
| UNREF, CAM | exact-duplicate semantics | method only; member lists corrected | A12-09 |
| UPLOAD | OQ-31 = OQ-1 | split | A12-09 |
| Missing duplicates | none | OQ-29 = OQ-I065-3, OQ-B001-1 = OQ-I056-7 | A12 section 4 |
| OQ-I042-4 | "bit 1" | `$0001` | A12 |
| Retired labels in topics | old names | live names (OQ-I024-5, OQ-I029-2, OQ-I029-4) | plan appendix A |
