# Campaign A report: actor flag bits (Mesen2, A1 to A4)

Compiled 2026-10-30 from `mesen2-investigation-plan.md` (section 7, Campaign A, and 12.3), `mesen2-question-inventory.md`, and the four result files `A1_flag_write_census`, `A2_flag_read_census`, `A3_forced_bit_experiments`, `A4_followup` (all `_20261030.md`). The raw JSON in `raw/` was used to count runs, not to re-derive results.

ROM: O (original), SHA-1 `38de0c84dd2bc3bdfc0a3d7ab0220c79b70887c3`. State: `rebuilt/states/orig_S01r_south-cape-ready.mss` and scene overrides written by the scripts. Mesen2 MCP 0.5.0. Nothing was applied to `extracted/`, `notes/` or `db-us/` by the campaign.

Sections: 1 Result in one page, 2 Scope and method, 3 Register of the 27 questions, 4 What the four steps showed, 5 Findings by flag bit, 6 Open and new questions, 7 Naming and overlap, 8 Plan and inventory that are out of date, 9 Audit of the two edit specs, 10 Tooling inconsistency found, 11 Proposed `closures.md` rows, 12 Apply order.

---

## 1. Result in one page

| Final status of the 27 ids | Count | Ids |
|----------------------------|------:|-----|
| VERIFIED-RUNTIME, nothing left | 13 | OQ-8, OQ-20, OQ-54, OQ-I022-1, OQ-I023-3, OQ-I025-2, OQ-I026-6, OQ-I027-2, OQ-I032-5, OQ-I044-2, OQ-I047-2, OQ-I053-3, OQ-I054-3 |
| VERIFIED-RUNTIME with a named remainder | 9 | OQ-40, OQ-60, OQ-I025-1, OQ-I025-6, OQ-I030-2, OQ-I036-4, OQ-I037-4, OQ-I041-6, OQ-I049-3 |
| VERIFIED-STATIC (no runtime setter seen, meaning from the code path) | 2 | OQ-38, OQ-I052-5 |
| INCONCLUSIVE (scene or trigger not reached) | 3 | OQ-I023-6, OQ-I026-5, OQ-I033-6 |
| CONTRADICTED | 0 | |

Experiments: 59 Mesen2 sessions (A1 14, A2 12, A3 10, A4 23), about 24,190 + 22,018 + 2,840 + 14,200 frames. The A4 frame total counts only the runs the file describes (K1e and T1 exist in `raw/` but are not described).

What changed in what we believe:

1. **`$10` bit `$0200` on the player is "ignore enemy contact", not "game over", "glide marker" or "ability FX".** Forced on, an enemy standing on Will for 120 frames did no damage (HP 8 to 8); control HP 8 to 1 to 0; cleared again, damage resumed. Readers: `CombatCollision_InnerLoop` mask `$76E0` and `RunInteractionCollision` `$0280`. This closes the five-id reader family (OQ-I023-3, I027-2, I030-2, I032-5, I036-4) and makes the name `SetPlayerGameOverFlag` wrong (rename proposed: `SetPlayerIgnoreContactFlag`).
2. **`$10` bit `$0008` is the collision-aware movement selector** (OQ-20). Cleared on the player, Will walked through a wall that stopped the control run. Not "grounded", not "player-hit".
3. **`$10` bit `$2000` hides the sprite and makes `PlayerIdleEntry` return at once; the player still moves** (OQ-I026-6, OQ-I025-2). Writers seen on the player: `StartForcedWalk+20` and `DarkSpaceMonitorStartWarp+19`; nobody clears it by name after the Dark Space warp, the actor pool rebuild zeroes the slot (OQ-I053-3).
4. **`$10` bit `$0400` on a victim is set only by the inline-lethal path** of `ApplyHitDamageToVictim_DamagePath` (and on drop pickups at spawn, cleared by the body one step later). It removes the actor from the `$35C0` / `$36F0` passes (OQ-8, OQ-I049-3). The old note "standard defeat flag" is wrong: the stagger death never sets it.
5. **`$10` bit `$0100` on the player is the vulnerable stance** (OQ-I025-1): cleared every frame, Will took no damage and the enemy took the hit.
6. **The dialogue clear of `$0800` is needed** (OQ-54): forced on during the text, the calling actor was re-run mid-COP (7 nested `PrintDialogString` in 12 frames).
7. **The world is frozen during the last-enemy reward and the damage digits freeze with the pause** (OQ-I047-2, I054-3, I041-6 pause half). The filter pass runs an actor when bit 12 is set in `$10` **or** `$12`.
8. **The laborer dies to one hit with no `currentHp` replacement**; `$12 $0010` makes the death inline and extendedFlags `$0080` sends it to `EnemyDefeatBossCleanup` (no gem, no counter change).

Real problems found while checking the work (details in sections 7 to 10):

- The question naming overlaps and is inconsistent (section 7). 11 of the 27 ids are compound (two or more independent questions in one id), 13 ids carry an experiment code from another campaign (5 of them have a non-A code as their primary one), and the A4 run codes reuse letters with opposite meanings and collide with plan step ids.
- `edits/mesen2-A_notes.json` had 6 real defects (all fixed in this session, section 9) and cannot be applied in the default `extract` state; it needs `extract:lt` first.
- `merge.ts` and the `gaia-core` docs disagree with the engine about whether commented lines carry a `; {n}` tag (section 10).
- The plan and the inventory still describe Campaign A as it was before A4 (section 8).

---

## 2. Scope and method

- **A1 flag write census.** Write callbacks over the actor slots (`$1000-$1FBF`, `$30` bytes per slot, 84 slots), recording old and new `$10` / `$12` and the PC. 14 sessions: `castoth_will`, `church_cutscene`, `hideout_cutscene`, `mine_exit_warp`, `mine_freedan`, `mine_freedan_abil`, `mine_shadow`, `mine_will`, `mine_will_abil`, `mine_will_die`, `sc_darkspace`, `sc_npc_talk`, `sc_npc_talk_clear0200`, `sc_will_walk`. Scenes `$01`, `$02`, `$08`, `$29`, `$3E`, `$3F`; Will, Freedan, Shadow.
- **A2 flag read census.** Read callbacks over the same range plus the `$0200` forced confirmation. 12 sessions (the A1 list minus `mine_exit_warp` and `sc_npc_talk_clear0200`).
- **A3 forced-bit experiments.** Pairs of atomic runs from the same state, one forced and one control: X1 `$2000` on the player (3 runs), X2 `$2000` on an NPC (2), X3 `$0008` cleared on the player (2), X4 `$0200` forced (2), X4c `$0200` forced then cleared (1).
- **A4 follow-up.** Written to resolve the 15 ids A1 to A3 left INCONCLUSIVE: K1 to K5 (kill, gem, last-enemy reward, damage digits, laborer, `$0100`), T0 / T1 / T2 (dialogue bit), DS (Dark Space warp), FW (forced walk). 23 runs.
- **Positive controls.** Every run reports `control36Writes` (one per NMI), and every forced run has a control that shows the event the forced run changes. Determinism is checked from identical first samples (K1, K1b, K1c, K2, K2c, K3: first hit 371, death 388, gem 392).
- **Limits that apply to every absence claim.** ROM O only; Will in A3 and A4; one enemy type killed (eye stalker); scenes `$01`, `$02`, `$03`, `$3F` (and `$E6`) in A4; no Dark Space warp, forced walk, ramp, Psycho Slider glide, `sp5B` room or Euro shop in A1 to A3.

---

## 3. Register of the 27 questions

"Spec" = whether the shipped note is corrected in `edits/mesen2-A_notes.json` (N) or the docs (D, already edited in `docs/wram-memory-map.md` and the two `docs/code` lines) or the names spec (R).

| ID | Question (short) | Run in | Final | Remainder | Shipped-note action |
|----|------------------|--------|-------|-----------|---------------------|
| OQ-8 | `$10` bits `$0080` / `$0400` in `RunCombatCollision` | A1, A2, A4 K1/K1c/K1d | VERIFIED-RUNTIME. `$0080` = hit reaction active (`ApplyInteractionDamage+168`, `ApplyHitDamageToVictim_DamagePath+159`, cleared by `RunActors_Normal+109`). `$0400` set only by the inline-lethal path (`+223`) | none | N: `combat_collision` comments and block note |
| OQ-20 | `$10` bit 3: "grounded" or "player-hit" | A1, A3 X3 | VERIFIED-RUNTIME: collision-aware movement selector | none | D (`actor-thinker-runtime.md:185`, `data-tables-memory.md:215`, both already fixed), N (`actor_execution` hedge) |
| OQ-38 | `$10` bit 4 in the iframe blink gate | A1, A2 | VERIFIED-STATIC: no writer ran in 24,190 frames; reader routes to `HitInvincibleVictim` | a runtime setter | N (`sprite_composition` comment 57154) |
| OQ-40 | bits 0/1 consumers; `STZ $070F` | A2 | VERIFIED-RUNTIME, coverage-limited: only `SortActorsByDepth+82` reads bits 0/1 | `STZ $070F` not examined | none |
| OQ-54 | Dialogue COPs clear `$10` bit 11 | A3 (not run), A4 T0/T2 | VERIFIED-RUNTIME (forced): the clear is needed | natural caller in the hideout does not carry the bit | N (`cop_handlers_dialog` block note, 43211, 43295) |
| OQ-60 | `$2008` / `$0008` / `$0200` / `$1000` in audio and forced walk | A1 (INCONCLUSIVE), A4 FW | VERIFIED-RUNTIME for `$2000` / `$4000` only | `$0008` and `$0200` transitions not observed (already set / never set); `StartMusic` `$1000` clear not run | N (`player_transition_handlers`) |
| OQ-I022-1 | `$12` bit 1 mirror lock: who sets and clears | A1, A2 | VERIFIED-RUNTIME: setters `dm3D_flayzer2`, `dm3D_flayzer3`, `ir1F_stone_lord5`; cleared by `InitActorPool` and `CopyActorState`; only reader `ProcessAnimFlag` | `awB0_zombie` not reached | N (`cop_handlers_sprite` block note) |
| OQ-I023-3 | Reader of player `$10` bit `$0200` | A2, A3 X4/X4c | VERIFIED-RUNTIME (HP 8 to 8 forced) | none | N, R |
| OQ-I023-6 | `ClimbX` clearing `$0008` while `$2000` set | A3, A4 | INCONCLUSIVE: no climb scene reached | a climb scene | none |
| OQ-I025-1 | player `$10` `$0100` and `$12` `$0001` | A1, A2, A4 K5 | `$0100` VERIFIED-RUNTIME (vulnerable stance); `$12 $0001` INCONCLUSIVE | `$12 $0001` on the player | N (`player_character`) |
| OQ-I025-2 | Setter of player `$2000` | A1 (none ran), A4 DS/FW | VERIFIED-RUNTIME | none | N (`player_character`, `PlayerIdleEntry`) |
| OQ-I025-6 | `$0700` OR-ed into the interacted NPC | A1 (not run), A4 K1g | VERIFIED-RUNTIME for the gem pickup (entry `NpcDespawnStub`, removed next tick with its marked child; `Die` cascades) | a chest-like NPC | N (comment 247068, added in this session) |
| OQ-I026-5 | `ToggleActorVisibilityFlag` flicker, helper lifetime | A3, A4 | INCONCLUSIVE: no `sp5B` room | the `sp5B` rooms | none |
| OQ-I026-6 | `$10` bit `$2000` has two readers | A1, A3 X1/X2 | VERIFIED-RUNTIME: no sprite and no standard movement; the script keeps running | the "flip every tick" part not run | none needed |
| OQ-I027-2 | Reader of `$0200` (Aura Barrier, Spin Dash) | A2 | VERIFIED-RUNTIME | none | N |
| OQ-I030-2 | `$0200` ignores enemy hits in boss defeat | A2, A3 X4/X4c | VERIFIED-RUNTIME (mechanism); defeat context INCONCLUSIVE | who clears it after a boss defeat; persistence across the two `mu67_vampires` callbacks | N (hedged wording in the `SetPlayerGameOverFlag` block note) |
| OQ-I032-5 | Reader of `$0200` (`StopPlayerOnDeath`) | A2 | VERIFIED-RUNTIME (3 deaths) | none | N |
| OQ-I033-6 | `$0E = $2000` priority change on NPCs | A3 (X5 discarded), A4 | INCONCLUSIVE: no Euro shop-queue scene `$91` | scene `$91` | none |
| OQ-I036-4 | Reader of `$0200` (ramps) | A2 | VERIFIED-RUNTIME (readers); ramp writers not run | the four ramp writers | N (ramps comments: "contact skip measured with the bit forced on; this write site not run") |
| OQ-I037-4 | `$12` `$0030` and extendedFlags `$0080` on laborer and kidnapper | A2 (partial), A4 K4 | VERIFIED-RUNTIME (laborer): one hit kills, no `currentHp` write | the Freejia kidnapper | none (the old note was not wrong) |
| OQ-I041-6 | child flags `$0400`; `$1000` only in the second path | A2 (not run), A4 K1/K3 | VERIFIED-RUNTIME for the `$2B00` child (pause freezes it, `$0400` is redundant there); the `$2F00` child never produced | an attack that reaches `PlayerAttackHitTest:570` | none |
| OQ-I044-2 | `$12` bit `$0200` meaning | A1 sc_npc_talk pair | VERIFIED-RUNTIME: scripted actor, `GlobalAmbientDeferToScript` 4 of 4 presses; cleared: `TalkWithSnapshot` | none | D (`wram-memory-map.md` row; the extracted note was already right) |
| OQ-I047-2 | During the stat pickup, do the player and companions run | A4 K2 | VERIFIED-RUNTIME: the player does not run for 126 frames; 1 non-`$1000` actor moved | companions not tested (none in scene) | none (`reward_actors.asm` header is right) |
| OQ-I049-3 | `$10` `$0400` on a drop pickup | A1 (no drop), A4 K1/K1b/K1c | VERIFIED-RUNTIME for the effect: while set, the gem cannot be collected (Will stood on it 88 frames); `DropBodyGem1+12` clears it | why the spawn flags `$0420` carry it | N (`EnemyDropSystem` comments and block note) |
| OQ-I052-5 | player `$10` bit `$0002` | A1 | VERIFIED-STATIC: depth key "front of everything" (`SetPriorityMax`, `SortActorsByDepth+82` `BIT #$0003`) | the slide itself not run | N (comment 50633) |
| OQ-I053-3 | Player hidden after `DarkSpaceEnterWarp`: who clears | A1 (not reached), A3, A4 DS | VERIFIED-RUNTIME: `InitActorPool+54` zeroes the slot at frame 243; `InitActorFromSceneData+166` writes `$C508`; hidden for 135 frames of scene `$E6` | none | N (`sE6_gaia`, `player_transition_handlers`) |
| OQ-I054-3 | Do flash, reveal and pickup need `$12 $1000` | A4 K2/K2f/K2g | VERIFIED-RUNTIME: the flash needs `$12 $1000`; the reward needs bit 12 in `$10` **or** `$12` | none | none in `extracted/` (the question's "need `$12 $1000`" was too narrow) |

Counts: 13 + 9 + 2 + 3 = 27. The A4 file's own tally ("10 VERIFIED-RUNTIME, 2 with an INCONCLUSIVE sub-half, 3 INCONCLUSIVE") names only 4 of the 6 ids that keep a remainder (it omits OQ-I025-6 and OQ-I037-4 from its parenthesis). The table above uses the verdict rows.

---

## 4. What the four steps showed

### A1 flag write census (setters)

- `$0008`: set at spawn and by `HitStaggerMain+14` on enemies; the player's `$0008` never changed outside spawn.
- `$0200` on the player: set by `RangedSetForceY+20`, `StopPlayerOnDeath+21`, `AuraBarrierMain+5`, `SpinDashMain+98`, `RunAttackFlagSetup+5`; cleared by `AuraBarrierEnd+5`, `RunAttackCleanup+5`, `SpinDashAbort+5`, `RangedAttackEast+13`. Not run: `ramps.asm` (4 sites), `slider_glide.asm`, `stair_climb`.
- `$2000`: no write to the player's bit in 24,190 frames; non-player writers `ir1F_stone_lord5`, `dm3D_flayzer3`, `DarkFriarProjectile+19`, `DarkFriarTrailEastWest+36`; `CopyActorState` forces it on 359 times.
- `$0002`: `SetPriorityMax+6` sets (12), `ClearPriorityMax+6` clears (2). `$0001`: `ClearPriorityMin+6` clears (2).
- `$0080`: `ApplyInteractionDamage+168` on the player (19 hits, 16 of them Castoth), `ApplyHitDamageToVictim_DamagePath+159` on victims (10), cleared by `RunActors_Normal+109` (25).
- `$0400`: bulk writes only (no kill in A1). `$0010`: no write at all.
- `$0800`: `e_sc01_pot` sets it; `PrintDialogString+29/+38/+88` save, clear, restore it (12 each).
- `$12`: bit 0 set once per scene entry by `PlayerCharacterDef+13`; bit 1 only by scripts; bit 9 by script code (3 unlabeled `84:` setters, 15 writes); bits 4 to 5 by `EnemyInitBasic+5` and `85:D02F`.

### A2 flag read census (readers)

- `$0200`: `CombatCollision_InnerLoop+17` (`BIT #$76E0`, 11,022 reads), `RunInteractionCollision+40` (`BIT #$2040`, `BIT #$0280`, 18,477), friendly pass `+29` (`BIT #$74E0`, no `$0200`).
- `$0100`: `CombatCollision_NextTarget+19` (`BIT #$0140` after `BIT #$0400`), `InteractionCollision_LoopBody+12` (`$35C0`) and `FriendlyMode+17` (`$3540`).
- `$2000`: `RunActors_Normal+45`, `SortActorsByDepth+82`, `PlayerIdleEntry+32` and others. `$0010`: `DecomposeActorMetasprites+45`, `ApplyHitDamageToVictim_DamagePath+8`.
- Bits 0 and 1 are read by `SortActorsByDepth+82` only. `StartMusic+30` clears `$10` bit 12 (`AND #$EFFF`, not on the player).

### A3 forced-bit experiments

| Run | Result |
|-----|--------|
| X1 `$2000` on the player | sprite gone, walking unchanged (x = 604 at frame 70 in both runs), entry word stays `PlayerIdleEntry` `$C3CA`; clearing restores everything |
| X2 `$2000` on a bird | stays at (138, 306), not drawn; the script keeps running (wait counter and entry word equal the control) |
| X3 `$0008` cleared on the player | Will crosses a wall at x = 168 and never reaches the south exit; `$10` bit 2 stays set the whole time |
| X4 `$0200` forced | 120 frames of contact, HP 8 to 8; control HP 8 to 1 (frame 372) to 0 (436) |
| X4c cleared at 366 | HP 0 at the end: damage resumes |

### A4 follow-up

See the A4 file observations 1 to 12; the table in section 3 carries the verdicts. Two points the A4 file leaves implicit: (a) the T2 positive-control counter is 75 writes for 1,500 frames and the cause was not found, so T2 rests on the exec hook; (b) `K1e` (`swing_at_gem_control`, 310 `control36` writes) and `T1` (300) exist in `raw/` and in the control line but not in the experiment table.

---

## 5. Findings by flag bit

| Word / bit | Verified meaning | Evidence | Open |
|------------|------------------|----------|------|
| `$10 $0008` | collision-aware movement (`ApplyMovementWithCollision` vs `ApplyMovement`) | A3 X3 | `ClimbX` clearing it while `$2000` set |
| `$10 $0080` | hit reaction active, 60-frame counter `$7F0028` on the player | A1, A2 | whether the player's counter is positive |
| `$10 $0100` | player vulnerable stance; excluded from `$35C0` / `$3540` / `$0140` skips | A4 K5 | none |
| `$10 $0200` | ignore enemy contact (`$76E0`, `$0280`) | A3 X4/X4c, A2 | clearer after a boss defeat |
| `$10 $0400` | excluded from `$35C0` and `$36F0`; set by the inline-lethal path and on drop pickups at spawn | A4 K1 to K1d | why `$0420` at spawn |
| `$10 $0700` | despawn tick (`InteractionDamage_NPCChat`) | A4 K1g | chest-like NPC |
| `$10 $0800` | cutscene-active; dialogue clears and restores it | A4 T2 | natural carrier |
| `$10 $1000` | display-filter qualifier, tested in `$10` or `$12` | A4 K2g | `StartMusic` clear |
| `$10 $2000` | hidden and script-driven; player keeps moving | A3 X1/X2, A4 DS/FW | `ClimbX`, `ToggleActorVisibilityFlag` |
| `$10 $0002` | depth key "front of everything" | A1 (static) | slide not run |
| `$10 $0010` | invincible route to `HitInvincibleVictim` | A1 (static) | runtime setter |
| `$12 $0001` | iframe-recovery routing (static); player effect unknown | A1 | player |
| `$12 $0002` | mirror lock | A1, A2 | zombie fight |
| `$12 $0010` / `$0020` | damage immune / boss | A2, A4 K4 | kidnapper |
| `$12 $0200` | scripted actor: talk deferred to its script | A1 | 3 unlabeled setters |
| `$12 $1000` | display-filter qualifier | A4 K2f | none |

The table with sources is in `docs/wram-memory-map.md` section "Actor flag bits".

---

## 6. Open and new questions

### The 15 "New questions" lines of A1 to A4, deduplicated

| # | Raised by | Question | Status | Proposed id |
|---|-----------|----------|--------|-------------|
| 1 | A1 N1 | Which actors run the unlabeled `84:800C`, `84:80B0`, `84:8377` that set `$12` bit 9 (15 writes, scene `$01`)? | open (static first: label the code) | OQ-CA-01 |
| 2 | A1 N2 | Is `85:D02F` (`$12 \|= $0030`, 24 writes) the Diamond Mine laborer? | probable: A4 K4 saw `$12 $0230` on both laborers; not traced | OQ-CA-02 |
| 3 | A1 N3 | What does recovery-iframe mode (`$12 $0001`) do for a flayzer? | open | OQ-CA-03 |
| 4 | A1 N4 | Why did the South Cape portal not work in A1? | answered by A4 DS: it works from one tile south (232, 112) with Up held; the A1 positions were wrong, not a story flag | closed (no id) |
| 5 | A2 N1 | Does `$0100` on the player skip the outer phase-2 loop? | answered by A4 K5 | closed under OQ-I025-1 |
| 6 | A2 N2 | Who clears the player's `$0200` after a boss defeat, and does it survive the two `mu67_vampires` callbacks? | open (second half of OQ-I030-2) | OQ-CA-04 |
| 7 | A2 N3 | Rename the `$0280` comment "game over / iframe-active" | handled by notes spec (comment 246411) | closed |
| 8 | A2 N4 = A4 N4 | What does the player's `$12 $0001` do (`ApplyHitDamageToVictim_DamagePath+300`, recovery `$FFEF` vs `$0011`)? Same question as the `$12 $0001` half of OQ-I025-1 and as A1 N3 | open | OQ-CA-05 (merge A1 N3 into it) |
| 9 | A3 N1 | Which routine moves Will while `$2000` is set (`PlayerIdleEntry` returns at once)? | open (static: `player_move_controller` is a companion actor) | OQ-CA-06 |
| 10 | A3 N2 | Is `$10` bit 2 (`$0004`) set by `ApplyMovement` (simple path) on every step? | open (static) | OQ-CA-07 |
| 11 | A3 N3 | Do cutscene scripts rely on NPC `$2000`; which `$12` bit requests ordinary movement (`RunActors_CopScriptPostTick+9`)? | open (static) | OQ-CA-08 |
| 12 | A4 N1 | Why does `SpawnListAppend` with `$0420` set `$0400` at all? | open: this is the remainder of OQ-I049-3 | keep under OQ-I049-3 |
| 13 | A4 N2 | Which attack reaches `PlayerAttackHitTest:570` (`$2F00` digits)? | open: remainder of OQ-I041-6 | keep under OQ-I041-6 |
| 14 | A4 N3 | Do `SpawnDropGem2` and `SpawnDropByHpTier` also clear `$0400`? | open (static yes) | OQ-CA-09 |
| 15 | A4 N4 | = row 8 | duplicate | OQ-CA-05 |

Result: 15 lines, 3 answered or handled (rows 4, 5, 7), 2 duplicates (row 15 and A1 N3), 2 are remainders of existing ids (rows 12, 13), leaving 9 genuinely new ids (OQ-CA-01 to OQ-CA-09). None of them is in `open-questions.md` or the inventory yet.

### Remainders attached to existing ids

OQ-40 (`STZ $070F`), OQ-60 (`$0008` / `$0200` / `StartMusic`), OQ-I025-6 (chest-like NPC), OQ-I030-2 (boss-defeat context), OQ-I036-4 (ramp writers), OQ-I037-4 (kidnapper), OQ-I047-2 (companions), plus the three INCONCLUSIVE ids. These need a climb scene, the `sp5B` rooms, scene `$91`, a ramp scene, a boss kill, the Freejia scene and a chest or sign.

---

## 7. Naming and overlap

### 7.1 Ids

1. **Three id families with no rule for which is which.** Plain numbers (`OQ-8`, `OQ-20`, `OQ-38`, `OQ-40`, `OQ-54`, `OQ-60`) come from before the iteration ids; `OQ-Innn-n` encode the iteration of origin; `OQ-B001-n` and `OQ-SAN2-n` are others. The six plain ids in Campaign A are not padded and carry no hint of topic. This cannot be renamed (the question files are frozen), so the inventory should carry the alias, not the id.
2. **Compound ids.** 11 of 27 ids hold two or more independent questions, and the result files then invent ad-hoc labels for the halves: `OQ-8 (\`$0400\` half)`, `OQ-I025-1 (\`$0100\` half)`, `OQ-I025-6 (\`$0700\`)`, `OQ-60 (\`$2000\` / \`$4000\`)`, and the A4 count says "VERIFIED-RUNTIME with an INCONCLUSIVE sub-half" without naming it in the table. Parts that A1 to A4 actually distinguished:

| Id | Parts |
|----|-------|
| OQ-8 | a `$0080`, b `$0400` |
| OQ-40 | a bits 0/1 consumers, b `STZ $070F` |
| OQ-60 | a `$2008` cleared at forced-walk start, b `$0008` / `$0200` in `SyncPlayerToCamera`, c `$1000` cleared by `StartMusic`, d conflicting doc wording |
| OQ-I025-1 | a player `$10 $0100`, b player `$12 $0001` |
| OQ-I025-6 | a effect of `$0700` on the tick, b removal versus `Die` deferring for marked children, c chest-like NPC |
| OQ-I030-2 | a mechanism (reader), b boss-defeat clearing, c persistence across `mu67_vampires` |
| OQ-I036-4 | a readers, b ramp writers run |
| OQ-I037-4 | a laborer, b kidnapper, c `currentHp = 1` replacement |
| OQ-I041-6 | a `$0400` of the child flags, b why only the second path ORs `$1000`, c pause behavior |
| OQ-I049-3 | a effect on the pickup, b why the spawn flags carry `$0400` |
| OQ-I054-3 | a flash, b reveal effect, c reward pickup, d world frozen |

Proposal: add one `Parts` table to the inventory (above), refer to `OQ-8.b` in result files, and give every part its own status. The `closures.md` row is then per part (the file's own rule is "one row per verdict").
3. **A result row can bundle ids** (`OQ-I023-3 / OQ-I027-2 / OQ-I030-2 / OQ-I032-5 / OQ-I036-4` in A3), which hides that OQ-I030-2 and OQ-I036-4 are only partly answered (A2 splits them correctly). Write one row per id.
4. **Different spellings of the same id**: `OQ-54` in verdicts, `OQ54` in A4 experiment tags and file names (`A4_OQ54_T0`), `OQ-60` in docs but `OQ-60 (part)` inside the cluster table, `I026-5` without prefix in prose.

### 7.2 Clusters and overlap

The inventory has the right idea (clusters `F10-0200`, `F10-2000`, `F10-0008`, `F10-0080/0400`) but Campaign A shows it is incomplete:

| Problem | Evidence | Fix |
|---------|----------|-----|
| One question counted five times | the `$0200` reader family (OQ-I023-3, I027-2, I030-2, I032-5, I036-4) was answered by one experiment (A3 X4) | keep canonical OQ-I023-3; close the others as duplicates, except the two parts that are not (OQ-I030-2.b/c, OQ-I036-4.b) |
| Same bit, no cluster | OQ-I025-1 (`$0100`), OQ-I041-6, OQ-I049-3 and OQ-8 all turn on `$0100` / `$0400` being in `$35C0` / `$36F0` | add `$0100` to the `F10-0080/0400` cluster, rename it `F10-COMBAT-MASKS` |
| `$2000` cluster too narrow | OQ-I026-5, OQ-I023-6 (script-driven `$2000` with `$0008`), OQ-I025-2, OQ-I053-3 and OQ-60 (c) all concern the player or an actor under `$2000` | add OQ-I026-5 and OQ-I023-6 as members; OQ-I033-6 stays out (its `$0E` word) |
| No cluster for the display filter | OQ-I047-2 and OQ-I054-3 both ask whether the world freezes while `displayModeFlags $0080` is set and which actors run | new cluster `DFILT` (canonical OQ-I054-3), K2 and K2f/g answered both |
| No cluster for `$12` | OQ-I022-1, OQ-I025-1.b, OQ-I037-4, OQ-I044-2, new A1 N3 and A2 N4 | new cluster `F12` listing by bit, sub-keyed like `F12-0001`, `F12-0200` |
| Cluster names use two schemes | `F10-0200` (flag word plus mask) next to `FLAG00`, `DMF`, `LPF`, `CT69`, `UNREF` | pick one pattern: `<word>-<mask>` for flag questions (`F10-0200`, `F12-0001`), a short upper-case topic for the rest |
| Ids filed under another campaign | 13 of the 27 ids carry a non-A code in the inventory "Exp" column: `A2 + G1` (OQ-8), `A2 + W1` (OQ-40), `A3 + N4` (OQ-54), `A3 + N1` (OQ-I025-6, OQ-I026-5), `A2 + N2` (OQ-I030-2), `A3 + F1` (OQ-I033-6), `G1 + A2` (OQ-I037-4, OQ-I041-6), `A1 + G2` (OQ-I049-3), `G2 + A2` (OQ-I047-2, OQ-I054-3), `N3 + A1` (OQ-I053-3). Five of them have the non-A code **first** (primary): OQ-I037-4, OQ-I041-6 (G1), OQ-I047-2, OQ-I054-3 (G2), OQ-I053-3 (N3). The schedule counts those 5 in sessions 6 and 11, so those sessions would redo what A4 did | after this report, mark the A-closed ids in the inventory (mode `X` or `X/part`) and drop the supporting codes that are done; make the A code primary for the 5 |

### 7.3 Experiment codes

| Problem | Evidence |
|---------|----------|
| Step ids and run ids share one namespace and are not distinct in shape | `A1`, `A2`, `A3`, `A4` (steps) vs `X1`..`X4c` (A3 runs) vs `K1`..`K5`, `T0`..`T2`, `DS`, `FW` (A4 runs). The A4 run `T1` (OQ-54 dialogue run) has the same code as the plan step `T1` (Campaign T, tooling decisions, plan section 7); `N1`..`N4` are plan steps and also the "New question N1" labels in the A files; `K`, `X`, `T` are not campaign letters in the plan, but `X`-looking codes read like one |
| Suffix letters mean opposite things | in K1: `b` and `g` are controls/long runs, `c` is forced, `d` is forced and `f` is the control. In K2: `c` is the control, `f` and `g` are forced variants. In X1: the unsuffixed pair is control/forced, `set_then_clear` a third run |
| The A4 K1 series jumps letters | `K1`, `K1b`, `K1c`, `K1d`, `K1e`, `K1f`, `K1g`: K1e is in `raw/` and in the control counter line but has no row in the experiment table; `T1` the same |
| `A1` / `A2` session names are shared | the same 12 session names appear under both prefixes, which is right, but nothing says that the A2 sessions are the A1 scenarios replayed with read callbacks |
| New-question numbers restart in every file | each result file has "New questions 1..n"; "N1" is ambiguous across files |
| Experiment catalogue ids look like campaigns | the plan has Campaigns A, B, C, W, D, E, F, G, M, N, P, R, S/T, V, Z and steps such as A1 to A4, G1, G2, N1 to N4, W1, F1, Z1: the inventory writes `A2 + G1` as if they were peers, though A2 is a step of Campaign A and G1 a step of Campaign G |

Proposal (applies to all later campaigns):

- Run id = `<step>-<name>`, step = the plan id, name = lower-case words: `A3-player-2000`, `A4-kill-eye-stalker`.
- Variants: `-ctl` for the control, `-frc` for the forced run, any other variant a descriptive word (`-cleared-366`, `-no-flash-1000`). Letters (`b`, `c`) are not used.
- New question ids: `OQ-C<campaign letter>-<nn>`, numbered across the whole campaign (`OQ-CA-01` for Campaign A, `OQ-CB-01` for B). The `C` prefix keeps them apart from `OQ-I...` and from the plan's campaign `M` (Menus). Never reused.
- Result rows: one row per `<id>.<part>`.

---

## 8. Plan and inventory that are out of date

| Where | Problem |
|-------|---------|
| Plan section 7 A1 to A3 | Q lists are the pre-run lists: A1 11 ids, A2 11, A3 8 (the A3 list contains OQ-20, OQ-54, OQ-I023-6, OQ-I025-6, OQ-I026-5, OQ-I026-6, OQ-I033-6, OQ-I044-2; the A3 file also reports OQ-I025-2, OQ-I053-3 and the `$0200` family). The A4 list (12 ids) repeats ids from A1 to A3. Nothing lists "the 27 ids Campaign A touched" |
| Plan section 7 A4 | the Q list names 12 ids, the A4 file resolves 15 (it adds OQ-I023-6, OQ-I026-5, OQ-I033-6, which stay INCONCLUSIVE). The status line is correct but is the only place the six named remainders are listed |
| Plan section 12.3 | prompts exist for STEP A1, A2, A3 only; there is no STEP A4 prompt, although A4 closed most of the ids |
| Plan section 9 schedule | session 2 "Flag census" lists `A1, A2, A3` with 22 primary ids; A4 is absent and Campaign A touched 27 ids (22 primary + the 5 in section 7.2) |
| Plan section 0 | records the 0.13 tooling re-verification but nothing about Campaign A results (decision U7, "ids are no longer written into notes", is followed by the notes spec) |
| Inventory modes | all 27 Campaign A ids are still mode `R` (or `R†`); none is marked `X` or `X/part` |
| Inventory totals | `X` = 11, `R` = 295: `X` would rise from 11 to 26 if the 13 full and 2 static ids are closed (more if parts are counted); the priority table (P1 15, P2 113, P3 219) changes with it |
| Inventory clusters | see 7.2 |
| `closures.md` | has 2 B2 rows and no Campaign A rows (Z1 has not run). Proposed rows below |
| `open-questions.md` | the 9 new ids of section 6 are not listed |

---

## 9. Audit of the two edit specs

### 9.1 `edits/mesen2-A_notes.json`

State on checking: valid JSON, 14 files, `merge --dry-run` OK in `extract:lt` state with no warnings. Defects found and fixed in this session:

| # | Defect | Fix |
|---|--------|-----|
| 1 | No spec entry for the `$0400` at `ApplyHitDamageToVictim_DamagePath+223` (the only place the question and the old note disagree) | comment 245854 added |
| 2 | The `$0140` comment said `$0100` was "orb-protected" only | comment 244792 now says `$0100` = the player's vulnerable stance |
| 3 | 5 slider_glide comments still read "slide-active" (the sibling comments were already fixed) | comments 53436, 53830, 53876, 53922, 54697 |
| 4 | `$2000` writers on the player listed only two routines (`StartForcedWalk`, `DarkSpaceMonitorStartWarp`) in four places | extended with `PlayerFallFromHeight`, `PlayerSkyGardenJumpLanding`, `PlayerAuraDescendToFloor` (static, not run) in the `player_character` block note, the `PlayerIdleEntry` part note, comment 181222, and `player_transition_handlers` block note |
| 5 | `SetPlayerGameOverFlag` block note: "most likely" hedge and a measurement that sounded like the boss-defeat sequence had been run | rewritten: "measured: ... 120 frames did no damage; the boss-defeat sequence itself was not run" |
| 6 | "Runtime-verified" / "confirmed" / "runtime test" wording and one blanket tag, against ACTION_PLAN section 6.1 (no history, no blanket tag, "Measured: ..." allowed) | rephrased in `EnemyDropSystem`, `RunActors_PostTick`, ramps, `cop_handlers_dialog` |
| 7 | 31 comment guards used `expectOld` and failed in `extract:lt` (the state the spec requires for the new comments) | converted to `expect` on the instruction text; `_note` and `_apply` rewritten |
| 8 | OQ-I025-6 `$0700` had no note (the existing comment says only "prevents re-interaction") | comment 247068 added |
| 9 | Two comments over the 160-character guideline (245854 at 174, 181222 at 230) | shortened |

Still true, not a defect: the spec applies **before** the names spec, because the names spec renames the file that this spec edits by its old name (`functions/SetPlayerGameOverFlag.asm`). After the rename the extracted file is `SetPlayerIgnoreContactFlag.asm`.

Not added on purpose:

- `StandardEnemyDefeatHandler` flow item 2: "only `$12 $1000`" is narrower than the truth (bit 12 in `$10` or `$12`). The extracted note was not wrong, the question text was. Add if you want the wider statement.
- OQ-I044-2: the extracted note is already right; the `$12 $0200` wording was added to `docs/wram-memory-map.md`.
- OQ-I047-2 / I054-3 / I037-4: shipped notes are correct.

### 9.2 `renames/apply-mesen2-A_names.json`

One entry: `{ "address": 697198, "old": "SetPlayerGameOverFlag", "new": "SetPlayerIgnoreContactFlag", "row": "MESEN-A-1" }`. `npm run names -- ... --dry-run` is OK (1 rename in `bank0A.json`; references in `db-us/blocks.json` 1, `docs/code/bank00/functions-game-over.md` 3, `docs/code/bank0A-dungeon-enemy-actors.md` 6, `docs/code/bank0C-scene-spawn-tables-comet.md` 4, `notes/blockNotes/bank0A.json` 1). I found no other name among the routines the notes spec touches that states a bit meaning Campaign A contradicted (`StopPlayerOnDeath`, `AuraBarrierMain`, `SpinDashMain`, `RunAttackFlagSetup`, `PlayerIdleEntry`, `StartForcedWalk`). The spec is complete for what was verified; the `address` is the `{n}` of the part's first instruction in `extract:lt`.

`npm run names -- --check` reports 19 problems ("not sorted / formatted like the tool writes it" for bank14 to bank17 and others). These exist without this spec and are not touched by it; the check should be clean before the apply so the apply diff is only the one rename.

### 9.3 Other files edited

`docs/wram-memory-map.md`, "Actor flag bits": the `$2000` row now separates the writers seen at runtime from the ones found statically. `docs/code/bank03/actor-thinker-runtime.md:185` and `docs/code/bank00/data-tables-memory.md:215` already carry the OQ-20 correction.

---

## 10. Tooling inconsistency found

`src/merge.ts` (uncommitted work in progress) rejects `expectOld` when the extracted line carries a `; {n}` tag, assuming that commented lines print no tag. The engine prints the tag on commented lines too (`gaia-core/src/rom/extraction/writer.ts`, `emitLineTracking`, lines 481 to 485). The docs disagree with each other:

- `gaia-core/docs/notes-and-comments.md` lines 198 and 1353: no tag on commented lines.
- Lines 1061 and 1147 of the same file: tag plus comment.

Consequence: in `extract:lt` mode every replacement of an existing inline comment fails with "use `expect`", and in plain mode a new comment cannot be placed at all. Workaround used here: `expect` on the instruction text for every comment. Fix needed (not done, because it is a tool change): make `merge.ts` and the docs follow the engine (tagged commented lines accept `expect` and `expectOld`), or make the engine omit the tag on commented lines and update both docs.

---

## 11. Proposed `closures.md` rows (do not append; step Z1 only)

Date 2026-10-30, result file `A1` to `A4` as shown, build mode O, ROM SHA-1 `38de0c84...`, applied: not applied. Grade column follows the A-files.

| ID | Verdict | Grade | Result file |
|----|---------|-------|-------------|
| OQ-8 | `$0080` = hit reaction active; `$0400` set only by the inline-lethal path and drop pickups, removes the actor from `$35C0` / `$36F0` | VERIFIED-RUNTIME | A1, A2, A4 |
| OQ-20 | `$10` bit 3 = collision-aware movement | VERIFIED-RUNTIME | A3 |
| OQ-38 | `$10` bit 4 = invincible route (code path); no runtime setter in 24,190 frames | VERIFIED-STATIC | A1 |
| OQ-54 | the `$0800` clear in `PrintDialogString` prevents re-running the caller mid-COP | VERIFIED-RUNTIME | A4 |
| OQ-I022-1 | `$12` bit 1 mirror lock: setters and clearers listed | VERIFIED-RUNTIME | A1, A2 |
| OQ-I023-3 | `$10` bit `$0200` = ignore enemy contact (and the 4 duplicates: I027-2, I032-5; I030-2.a, I036-4.a) | VERIFIED-RUNTIME | A2, A3 |
| OQ-I025-2 | player `$2000` writers: `StartForcedWalk+20`, `DarkSpaceMonitorStartWarp+19` | VERIFIED-RUNTIME | A4 |
| OQ-I026-6 | `$2000` = no sprite and no standard movement; script still runs | VERIFIED-RUNTIME | A1, A3 |
| OQ-I044-2 | `$12 $0200` = scripted actor, talk deferred | VERIFIED-RUNTIME | A1 |
| OQ-I047-2 | the player does not run during the stat pickup | VERIFIED-RUNTIME | A4 |
| OQ-I052-5 | `$10` bit 1 = depth key "front of everything" | VERIFIED-STATIC | A1 |
| OQ-I053-3 | `InitActorPool+54` zeroes the player slot; no named clearer | VERIFIED-RUNTIME | A4 |
| OQ-I054-3 | flash needs `$12 $1000`; reward needs bit 12 in `$10` or `$12`; world frozen | VERIFIED-RUNTIME | A4 |

Part rows (to add once parts are split): OQ-I025-1.a (`$0100`), OQ-I025-6.a/b (gem pickup path), OQ-I037-4.a/c (laborer), OQ-I041-6.c (pause), OQ-I049-3.a (effect), OQ-I030-2.a, OQ-I036-4.a, OQ-60.a (`$2000` / `$4000`), OQ-40.a, all VERIFIED-RUNTIME with the A-file named in section 3.

---

## 12. Apply order

1. `npm run extract:lt`
2. `npm run merge -- plans/extracted-audit/edits/mesen2-A_notes.json --dry-run`, then without `--dry-run`
3. `npm run names -- --check` (fix the 19 existing problems first or accept them), then `npm run names -- plans/extracted-audit/renames/apply-mesen2-A_names.json --dry-run`, then apply
4. `npm run extract:lt`, `npm run rebuild` (CRC gate unchanged), then `npm run extract` for the committed tree
5. Append the section 11 rows to `closures.md` (Z1), add the 9 new ids to `open-questions.md`, update the inventory and plan (section 8)
6. Fix the `merge.ts` / `gaia-core` docs tag inconsistency (section 10)
