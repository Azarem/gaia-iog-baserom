# Mesen2 A series: actor Flags10 / Flags12 census and forced-bit experiments (A1 to A4)

Runtime and static investigation of actor flag words at DP offsets `$10` and `$12`: a write census, a read census, paired forced-bit experiments on Will and one NPC, and follow-up runs for kills, drops, the last-enemy reward, pause, the Diamond Mine laborer, the vulnerable stance, dialogue bit `$0800`, Dark Space entry and forced walk. Compiled 2026-11-12 from `plans/extracted-audit/mesen2-results/A_campaign_report_20261030.md`, `A1_flag_write_census_20261030.md`, `A2_flag_read_census_20261030.md`, `A3_forced_bit_experiments_20261030.md`, `A4_followup_20261030.md`, closure rows in `closures.md` (including `CO01_close_A.md`), and `open-questions.md` §5 (Campaign A new-question rows).

ROM: O (vanilla US), SHA-1 `38de0c84dd2bc3bdfc0a3d7ab0220c79b70887c3`. Mesen2 MCP **0.5.0** for every session (A1–A4); no rebuilt ROM. Base state: `rebuilt/states/orig_S01r_south-cape-ready.mss` (South Cape, Will, scene `$01`); mine and ability runs poke `$0642` and `$0AA2`/`$0AA3` at frame 2. The campaign itself changed no `extracted/`, `notes/`, or ROM bytes; note and name specs live under `plans/extracted-audit/edits/mesen2-A_notes.json` and `renames/apply-mesen2-A_names.json` for a separate apply pass.

Sections: 1 Result in one page, 2 What was run, 3 Findings, 4 Shipped notes corrected, 5 Rules for patch authors, 6 Where the findings live in the docs, 7 Tools, states and files, 8 Tool and method lessons, 9 Open questions, 10 Apply log.

---

## 1. Result in one page

| Topic | Question | Verdict |
|-------|----------|---------|
| `$10` bit 3 (`$0008`) | "Grounded" or collision-aware movement? | **Collision-aware movement selector** (`ApplyMovementWithCollision` vs `ApplyMovement`). Cleared on Will, he crossed the wall that stopped the control at x 168 (reached x 84). Set at every spawn (A1). VERIFIED-RUNTIME (SIMULATED on the player). |
| `$10` bit 4 (`$0010`) | Invincible / iframe blink gate | Routes to `HitInvincibleVictim`; blink suppressed at `DecomposeActorMetasprites+45`. **No writer** in 24,190 A1 frames; meaning from code path only. VERIFIED-STATIC. |
| `$10` bits 0 and 1 | Collision consumers besides depth sort? | **Only** `SortActorsByDepth+82` (`BIT #$0003`, 116,438 reads); no collision/tile/hitbox test in 22,018 A2 frames (12 sessions). Coverage-limited. VERIFIED-RUNTIME. `STZ $070F` in the player tile DMA list **not examined**. INCONCLUSIVE. |
| `$10` bit 7 (`$0080`) | Hit-reaction flag | Set on the player by `ApplyInteractionDamage+168` (19), on victims by `ApplyHitDamageToVictim_DamagePath+159` (10); cleared by `RunActors_Normal+109` (25). VERIFIED-RUNTIME. |
| `$10` bit 9 (`$0200`) | "Game over", glide marker, or ignore contact? | **Ignore enemy contact**: `CombatCollision_InnerLoop+17` (`BIT #$76E0`) and `RunInteractionCollision+40` (`BIT #$0280`). Forced 120 frames on Will: HP 8→8; control 8→1 (f372)→0 (f436). Friendly pass `$74E0` does not skip `$0200`. VERIFIED-RUNTIME (SIMULATED). |
| `$10` bit 10 (`$0400`) | "Standard defeat flag" | On victims: set **only** on the inline-lethal path (`ApplyHitDamageToVictim_DamagePath+223`, pc `83:C063`) when `playerFlags $0010` or victim `$12 $0010`; normal stagger death never sets it. Drops spawn with `$0420`; `DropBodyGem1+12` clears `$0400` one step later. While forced, gem cannot be collected (88 frames). VERIFIED-RUNTIME. |
| `$10` bit 11 (`$0800`) | Dialogue COP must clear cutscene bit? | Forced on during text: `PrintDialogString` **7 times in 12 frames** (f118–130) vs once in the control. Natural hideout caller had bit clear (save/clear/restore no-op). VERIFIED-RUNTIME (SIMULATED). |
| `$10` bit 8 (`$0100`) | Player "visibility" / climb? | **Vulnerable stance**: set by `PlayerIdleEntry+22` (738), cleared by block/attack paths (A1). Cleared every frame next to enemy: Will HP 8 for 160 frames, enemy took hit; control died. VERIFIED-RUNTIME (SIMULATED). |
| `$10` bit 13 (`$2000`) | Hidden / script-driven | No sprite, no standard movement (`RunActors_Normal+45`, `SortActorsByDepth+82`); script keeps running (bird wait/entry match control). On Will: hidden sprite, walking unchanged (`PlayerIdleEntry` returns at once). Writers on player: `StartForcedWalk+20`, `DarkSpaceMonitorStartWarp+19`; cleared by `SyncPlayerToCamera+24` or `InitActorPool+54` (Dark Space: hidden 135 frames of scene `$E6`). VERIFIED-RUNTIME (SIMULATED effect; natural writers in A4). |
| `$10` bit 1 (`$0002`) | Depth "front of everything" | `SetPriorityMax` (12 sets); `SortActorsByDepth+82` depth key. Landing slide sets same bit (static). Slide runtime not checked in A1. VERIFIED-STATIC. |
| `$10` bit 12 (`$1000`) | Display-filter qualifier | Stat reward runs when bit 12 set in `$10` **or** `$12` (K2g). `StartMusic+30` clears `$10` bit 12 twice (non-player); audio effect not run. VERIFIED-RUNTIME (reward); INCONCLUSIVE (`StartMusic` on player). |
| `$10` `$0700` | NPC chat despawn | Pickup: `InteractionDamage_NPCChat` → entry `NpcDespawnStub`, `$10 \|= $0700` f433; removed with marked child next tick. Chest-like NPC not run. VERIFIED-RUNTIME (pickup path). |
| `$12` bit 1 (`$0002`) | Mirror lock | Set only by scripts (`dm3D_flayzer2`, `dm3D_flayzer3`, `ir1F_stone_lord5`); cleared by `InitActorPool`, `CopyActorState`; reader `ProcessAnimFlag+20/+36` (2,994 reads, bit clear on player). `awB0_zombie` not reached. VERIFIED-RUNTIME. |
| `$12` bit 9 (`$0200`) | Scripted talk | Bit set → `GlobalAmbientDeferToScript` 4/4 presses; cleared on same NPC → `GlobalAmbientTalkWithSnapshot` + restore, 0 `DeferToScript`. VERIFIED-RUNTIME (SIMULATED cleared half). |
| `$12` bit 0 (`$0001`) | On the player | Set once per scene by `PlayerCharacterDef+13` (17); no reader ran on player; victim recovery sign known from later G1 (closure row). INCONCLUSIVE on player. |
| `$12` `$0010` / `$0020` | Laborer / boss bits | Laborer HP 1, one hit dies inline (`$0400`, `$0040`), boss cleanup, no gem; `$0AEC` unchanged (24). Kidnapper not run. VERIFIED-RUNTIME (laborer). |
| Last-enemy reward | World frozen? | Player fixed 126 frames (`displayModeFlags $0080`); flash needs `$12 $1000` (K2f). Digits freeze with Start (K3). VERIFIED-RUNTIME. |
| Bits 0/1 only depth | Any other reader? | Same as row 3. | |
| Forced walk `$2008`/`$0008` | Audio / grounded comments | Walker clears own `$2008` (`forced_walk.asm:39`); `SyncPlayerToCamera` copies with `$0008` set, `$0200` cleared. `$0008`/`$0200` transitions on player not observed in FW run. VERIFIED-RUNTIME (`$2000`/`$4000`); INCONCLUSIVE transitions. |
| Slider glide + `$0008` | ClimbX while `$2000` | No glide reached in A4; question targets Psycho Slider glide (`slider_glide.asm:277-290`), not a climb scene. INCONCLUSIVE. |
| `$0E = $2000` (OAM attr) | Shop NPC priority | A3 X5 discarded; no scene `$91` queue run. INCONCLUSIVE. |
| `ToggleActorVisibilityFlag` | Per-frame flip | `sp5B` rooms not entered in A1–A4; flip-on-parent answered later on scene `$5B` helpers (closure cites N1). INCONCLUSIVE in A sessions. |
| Companion during reward | Companion actors in the reward sequence | No companions in scene `$3F`. INCONCLUSIVE. |
| `$2F00` damage child | Pause vs `$2B00` | Pause on `$2B00` child measured; `$2F00` path never spawned (17 `PlayerAttackHitTest` calls only overlap test). INCONCLUSIVE (`$2F00`). |

Counts: **27** investigation ids touched; **13** close with no named remainder in the campaign tally, **9** VERIFIED-RUNTIME with a named remainder, **2** VERIFIED-STATIC only, **3** INCONCLUSIVE end-to-end (`ClimbX`/glide, `sp5B`, Euro shop `$0E`). Shipped notes: the campaign report lists multiple CONTRADICTED hedges ("grounded", "game over" on `$0200`, "standard defeat" on `$0400`, `SetPlayerGameOverFlag` name, dialogue "inferred", ability-FX wording on Aura/Spin Dash). **0 ROM bytes** changed in the investigation runs.

What changed in what we believe:

1. **`$10` bit `$0200` is "ignore enemy contact", not game over, glide marker, or generic ability FX.** Five reader questions collapse to `CombatCollision_InnerLoop` and `RunInteractionCollision`; the old helper name `SetPlayerGameOverFlag` is wrong (`playerFlags $0200` is game over).
2. **`$10` bit `$0008` picks collision-aware movement**, not "grounded" or "player-hit".
3. **`$10` bit `$2000` hides the sprite and skips standard movement/thinking paths but does not stop the player** (`PlayerIdleEntry` returns at once; `PlayerMoveController` still advances position). Pool rebuild clears it after Dark Space.
4. **`$10` bit `$0400` marks inline-lethal victims and transient drop exclusion**, not every defeat; stagger deaths use `$0080`/`$0040` without `$0400`.
5. **`$10` bit `$0100` is the vulnerable stance** for combat masks; clearing it makes Will a damage source without attack input (K5).
6. **Display filter and dialogue bits are coupled to freeze semantics:** reward needs bit 12 in `$10` or `$12`; flash needs `$12 $1000`; `PrintDialogString` must clear `$0800` on the caller.

---

## 2. What was run

| Step | Ids or topic | Method | Volume |
|------|----------------|--------|--------|
| A1 | Write census: setters of `$10`/`$12` | Memory write callbacks on actor slots `$1000`–`$1FBF` fields `$10`–`$13`, all 128 DBR aliases; 14 sessions, `scenario_a1_flag_census.py`, decode via `decode_flag_census.py` | 24,190 frames; scenes `$01`, `$02`, `$08`, `$29`, `$3E`, `$3F`; Will/Freedan/Shadow |
| A2 | Read census; `$0200` reader confirmation | Same harness `--reads`; 12 sessions (A1 list minus two talk/warp sessions); merged `A2_merged_20261030.json` (1,716 PC rows field 10) | 22,018 frames; up to 939,436 reads/session |
| A3 | Forced bits X1–X4c | Paired control/forced `run_script` from identical state; `scenario_a3_forced_bits.py`, `kit/lib/a_census.lua` | ROM O; `$01` (X1,X2), `$3F` (X3,X4,X4c); 59–546 frames/run |
| A4 | Kills, reward, pause, laborer, `$0100`, dialogue COP clear of `$10` bit 11, DS, FW | `scenario_a4_followup.py`, `scenario_a4_events.py`, write census on key runs; exec counters | Scenes `$01`, `$02`, `$03`, `$3F`; 310–1,500 frames/run; one enemy type killed |

Positive controls: `control36Writes` ≈ frame count every session (A1: 1,099–3,136; A3: 59–376; A4: 300–1,347). Forced-bit pairs match through the frame before the poke (A3). A4 kill timing deterministic (first hit f371, death f388, gem f392).

Coverage limits (every absence claim is bounded by this): no ramp, Psycho Slider glide, `sp5B` visibility helpers, Euro shop `$91`, Freejia kidnapper, chest-like `$0700` NPC, boss-defeat natural sequence, `SpawnDropGem2` / `SpawnDropByHpTier`, or full gem-type matrix.

---

## 3. Findings

### 3.1 Write census (A1)

Slot geometry: **48 bytes ($30)** per actor; player slot `$1000`. Census logs PC after instruction (subtract length for opcode site), scene, slot, old/new.

- **`$0008`:** `InitActorFromSceneData` (17), `CopyActorState` (163), `HitStaggerMain+14` (19 on enemies), `dm3D_flayzer3` toggles; player `$0008` never written outside spawn in 24,190 frames.
- **Player `$0200`:** `RangedSetForceY+20` (8), `StopPlayerOnDeath+21` (3 deaths), `AuraBarrierMain+5` (2) / `AuraBarrierEnd+5` (2), `SpinDashMain+98` (1), `RunAttackFlagSetup+5` (1) / `RunAttackCleanup+5` (1) / `SpinDashAbort+5` (1), `RangedAttackEast+13` (8). Ramp/slider/stair writers **not executed**.
- **Non-player `$2000`:** `CopyActorState` forces on 359×; `InitActorFromSceneData` 113×; script toggles on Castoth/flayzer; cleared `SpawnAfterFlags` / `InitActorPool`. **Zero** player `$2000` writes in A1.
- **`$0080`:** player hits 19 (`ApplyInteractionDamage+168`); victims 10 (`ApplyHitDamageToVictim_DamagePath+159`); clear 25 (`RunActors_Normal+109`).
- **`$0400`:** bulk spawn/copy only in A1 — **no defeat write** (no kill).
- **`$0010` bit 4:** **no write** in 24,190 frames.
- **`$0800`:** `e_sc01_pot` (8); dialogue save/clear/restore 12× each at `PrintDialogString+29/+38/+88`.
- **`$12`:** bit 0 `PlayerCharacterDef+13` (17×/scene); bit 1 scripts only; bit 9 script setters including unlabeled `84:800C` / `84:80B0` / `84:8377` (15 writes scene `$01`); bits 4–5 `EnemyInitBasic+5`, `85:D02F` (24× scene `$3F`).

### 3.2 Read census (A2)

Distinct readers for campaign bits (field `$10`, executions / player executions):

| Bit | Site | Mask / test | n / pl |
|-----|------|-------------|--------|
| `$0200` | `CombatCollision_InnerLoop+17` | `#$76E0` | 11,022 / 3,412 |
| `$0200` | `RunInteractionCollision+40` | `#$2040`, `#$0280` | 18,477 / 18,477 |
| `$0200` | `CombatCollision_InnerLoop+29` (friendly) | `#$74E0` | 1,557 / 384 |
| `$0100` | `CombatCollision_NextTarget+19` | `#$0400`, `#$0140` | 61,621 / 18,316 |
| `$0100` | interaction passes | `#$35C0` / `#$3540` | 54,210 / 16,846; 7,347 / 1,458 |
| `$2000` | `RunActors_Normal+45` | `#$2000` | 528,648 / 18,511 |
| `$2000` | `SortActorsByDepth+82` | `#$2000` | 116,438 / 20,363 |
| `$2000` | `PlayerIdleEntry+32` | `#$2000` | 738 / 738 |
| `$0003` | `SortActorsByDepth+82` only | `#$0003` | 116,438 |

`StartMusic+30` (`AND #$EFFF` on `$10`) ran **2×**, not on player. No executed read tested bits 0/1 of `$10` outside depth sort.

### 3.3 Forced-bit experiments (A3)

| Run | Poke | Measured effect |
|-----|------|-----------------|
| X1 player `$2000` | f10 `\|=` | Sprite hidden; x=604 f70 both runs; entry stays `PlayerIdleEntry` `$C3CA` vs walk `$C59B` control; clear f40 restores draw |
| X2 NPC `$2000` | f12, slot `$12D0` bird | Position frozen (138,306); not drawn; `wt` and entry `$809D` match control — script alive |
| X3 clear `$0008` | f346 `&= $FFF7` | Control stops x168, south exit f440; forced x84 through wall, bit 2 (`$0004`) stays set, scene `$3F` at end |
| X4 / X4c `$0200` | f346–465 hold; X4c clear f366 | Contact 120 frames: HP 8 forced vs 8→1→0 control; clearing resumes damage |

Not run in A3: the forced clear of `$10` bit 11 by dialogue COPs, glide, `$0700`, `sp5B`, `$0E` priority (X5 discarded — sprites behind building).

### 3.4 Follow-up (A4)

**Kill path (K1):** f371 hit → victim `$4000→$0080`; f388 `StandardEnemyDefeatHandler` with `$00C0` (no victim `$0400` on stagger path); gem slot `$1720` with spawn `$0420`, `DropBodyGem1+12` clears `$0400` once.

**Inline lethal (K1d):** `playerFlags $0010` forced → death f371; `$0400` from `ApplyHitDamageToVictim_DamagePath+223` (`83:C063`).

**Gem (K1b/K1c):** `$0400` forced on pickup → 88 frames no collection (`$35C0` mask).

**Pickup (K1g):** f433 `$0720` (`$0700`), `NpcDespawnStub`, gone f434 with marked child.

**Last enemy (K2):** `$0AEC` 1→0 f389; filter `$0080` f392; player x294 fixed until ~f405 in control; reward qualifies with `$10` bit 12 alone (K2g); flash delayed without `$12 $1000` (K2f, reveal ~f658 vs f408).

**Laborer (K4):** slots `$1750`/`$1780`, `$12 $0230`, one hit HP 0, inline `$0400`, boss cleanup, no gem.

**Vulnerable stance (K5):** clear `$0100` each frame → Will HP 8, enemy damaged f371 without attack input.

**Dialogue (follow-up T2):** 7 nested `PrintDialogString` in 12 frames with caller `$0800` forced.

**Dark Space (DS):** `DarkSpaceMonitorStartWarp+19` sets player `$2000` f21; `InitActorPool+54` zeroes slot f243; respawn `$C508` f244.

**Forced walk (FW):** `StartForcedWalk+20` sets `$2000` 4×; `$4000` from `SortActors_OffScreen+5`, cleared `SortActorsByDepth+141` / `SyncPlayerToCamera+24`; **not** by `StartForcedWalk` (closure supersedes A4 verdict row wording).

### 3.5 Cross-cutting flag meanings (by bit)

Narrative aliases for patch authors:

- **`$0200`:** combat and interaction skip masks; set on death, Aura, Spin Dash, lunge, ramps/slider in source (ramps/slider writers not run in A1–A2).
- **`$0400`:** removal from `$35C0` and `$36F0`; lethal-only on victims; spawn on gems for one-body-tick exclusion.
- **`$2000`:** `RunActors_Normal+45` script branch; depth sort skip; player still moves via movement companion.
- **`$0800`:** `RunActors_CutsceneOnly+12` filter; dialogue triplet save/clear/restore on caller.

---

## 4. Shipped notes corrected

The campaign prepared `edits/mesen2-A_notes.json` (14 files, extract:lt + `expect` guards) and `renames/apply-mesen2-A_names.json` (`SetPlayerGameOverFlag` → `SetPlayerIgnoreContactFlag`). Docs edits already landed for the `$0008` collision switch and the flag table. Representative contradictions the spec targets:

| Place | Old statement | Verdict | New statement |
|-------|---------------|---------|---------------|
| `docs/code/bank03/actor-thinker-runtime.md` (pre-fix) | "grounded" for `$0008` | CONTRADICTED | collision-aware movement (doc updated) |
| `docs/code/bank00/data-tables-memory.md` (pre-fix) | "player-hit" for `$0008` | CONTRADICTED | collision-aware movement (doc updated) |
| `actor_execution.asm` part note | hedge on `$0008` | CONTRADICTED | collision-aware movement selector |
| `attack_ability_system.asm`, ramps, `StopPlayerOnDeath.asm` | "ability FX", "game over", unknown ramp readers | CONTRADICTED | ignore enemy contact; named reader masks |
| `SetPlayerGameOverFlag` block / name | implies game over on `$10` `$0200` | CONTRADICTED | `SetPlayerIgnoreContactFlag`; bit ignores contact |
| `combat_collision.asm` | "standard defeat flag" for `$0400` | CONTRADICTED | inline-lethal and drop spawn only; stagger path differs |
| `player_character.asm` | "visibility" / "climb" for `$0100`; "ability-hijacked" for `$2000` | CONTRADICTED | vulnerable stance; hidden/script-driven with named writers |
| `sprite_composition.asm:570` | "meaning not traced" bit 4 | CONTRADICTED | invincible route / blink gate (static) |
| `cop_handlers_dialog.asm` | dialogue `$0800` clear "inferred" | CONTRADICTED | measured need when bit forced (7 re-entries / 12 frames) |
| `EnemyDropSystem.asm` | why `$0400` on spawn untraced | narrowed | effect while set; reason still open |
| `player_transition_handlers.asm` | "grounded" on forced-walk copy | CONTRADICTED | `$2008` cleared on walker; copy sets `$0008`, clears `$0200` on player |

`global_ambient_dispatcher.asm` for `$12 $0200` was already correct (no note change). Laborer, reward header, and several combat flow notes were already right (A4).

---

## 5. Rules for patch authors

1. **Treat `$10` bit `$0008` as the collision pipeline switch.** Clear it only when you intend wall-passing movement (`ApplyMovement`); keep it set for normal tile collision. It is not a "grounded" or player-hit flag.
2. **Treat `$10` bit `$0200` as "ignore enemy contact" on the actor that carries it**, using the same masks as `CombatCollision_InnerLoop` (`$76E0`) and `RunInteractionCollision` (`$0280`). Do not confuse it with `playerFlags $0200` (game over). Prefer the `SetPlayerIgnoreContactFlag` name for the boss helper.
3. **Expect `$10` bit `$0400` to keep actors out of interaction and player attack-test passes.** On victims, set it only on inline-lethal damage, not on stagger deaths. On drops, the body clears it one tick after spawn before collection works.
4. **Keep `$10` bit `$0100` set on the idle player** if enemy contact should damage Will; block, attack, Spin Dash, and run attack clear it. A player without it can damage enemies by body contact alone (mask skips).
5. **When hiding the player with `$10` bit `$2000`, movement can continue** (`PlayerIdleEntry` returns immediately; sprite omitted). Clear via `SyncPlayerToCamera+24` after forced walk or rely on `InitActorPool+54` after warps that rebuild the pool — do not assume an unnamed clearer.
6. **Set `$10` bit `$0800` on dialogue callers and let `PrintDialogString` clear/restore it.** Forcing it back on during text re-enters the COP; patch overlays that run during dialogue must not leave it set on the caller.
7. **Qualify display-filter actors with bit 12 in `$10` or `$12`.** Death flash needs `$12 $1000`; the stat reward runs with `$10` bit 12 alone. Overlay code must not assume `$12` only.
8. **Do not set `$10` bit `$0700` on interactables that must survive the tick** unless you intend immediate despawn via `NpcDespawnStub`.
9. **Use `$12` bit `$0200` when the actor's own script must own talk** (`GlobalAmbientDeferToScript`); clear it for snapshot talk/restore behavior.
10. **Bits 0 and 1 of `$10` are depth-sort keys only** in the executed corpus; do not invent collision semantics for them without new evidence.
11. **Before COP from actor code, X must equal the actor slot ID** and preserve engine DP state (`$80`–`$82` collision pointer, etc.) across overlay work — unchanged by this series but required when poking flags from patches.

---

## 6. Where the findings live in the docs

| Topic | Document |
|-------|----------|
| Full `$10`/`$12` bit table, evidence tags | [`wram-memory-map.md`](wram-memory-map.md) (§2.11 "Actor flag bits") |
| Combat masks `$76E0` / `$74E0` / `$35C0` / `$36F0`, bit meanings in combat | [`code/bank03/movement-and-collision.md`](code/bank03/movement-and-collision.md) |
| Actor slot layout, pointer to flag table | [`code/bank00/data-tables-memory.md`](code/bank00/data-tables-memory.md) |
| Thinker overview, bits 3 / 8 / 9 / 11 / 13 | [`code/bank03/actor-thinker-runtime.md`](code/bank03/actor-thinker-runtime.md) |
| Player idle, vulnerable stance, abilities clearing `$0100` | [`code/bank02/player-character.md`](code/bank02/player-character.md) |
| Hit stagger, child `$0400` on player victim | [`code/bank00/actors-combat-interaction.md`](code/bank00/actors-combat-interaction.md) |
| Game over vs ignore-contact helper naming | [`code/bank00/functions-game-over.md`](code/bank00/functions-game-over.md) |
| Boss `SetPlayerIgnoreContactFlag` spawn pattern | [`code/bank0A-dungeon-enemy-actors.md`](code/bank0A-dungeon-enemy-actors.md), [`code/bank0C-scene-spawn-tables-comet.md`](code/bank0C-scene-spawn-tables-comet.md) |
| `SyncPlayerToCamera` / forced walk flag copy | [`code/bank00/camera-scroll-system.md`](code/bank00/camera-scroll-system.md) |
| Scripted talk bit `$12` `$0200` | [`code/bank00/thinkers-system.md`](code/bank00/thinkers-system.md) (GlobalAmbient flow) |

---

## 7. Tools, states and files

All under `plans/extracted-audit/mesen2-results/` unless noted.

| Kind | Files |
|------|-------|
| Lua (`kit/lib/`) | `a_census.lua` (census + forced-bit `acen.run`), `a_actors.lua` (A4 live-list helpers) |
| Python harness (`harness/`) | `scenario_a1_flag_census.py`, `scenario_a3_forced_bits.py`, `scenario_a4_followup.py`, `scenario_a4_events.py`, `decode_flag_census.py`, `view_reads.py`, `explore_a4.py`, `mcp_client.py` |
| Draft note/name specs (`plans/extracted-audit/`) | `edits/mesen2-A_notes.json`, `renames/apply-mesen2-A_names.json` |
| State | `rebuilt/states/orig_S01r_south-cape-ready.mss` |
| Raw output (`raw/`) | `A1_merged_20261030.json`, `A2_merged_20261030.json`, `A1_A2_scripts_20261030.lua.txt`, `A3_X*_20261030.json`, `A3_scripts_20261030.lua.txt`, `A4_*_20261030.json`, `A4_merged_20261030.json`, `screenshots/A3_*`, `screenshots/A4_*` |
| Reports | `A1_flag_write_census_20261030.md` … `A4_followup_20261030.md`, `A_campaign_report_20261030.md`, `CO01_close_A.md`, `closures.md` rows 248–259 and 307–308 |

---

## 8. Tool and method lessons

- **Write/read callbacks** on actor slots must cover all 128 program-bank aliases; decode uses `decode_flag_census.py` with `file:line` = block start, not instruction line.
- **Forced-bit protocol:** paired runs, identical seed/bot until poke; first samples must match; use `kit.w16` on slot+`$10`, never low DP.
- **Absence claims** need positive control: `control36Writes` ≈ frames; known readers (`SortActorsByDepth+82`, etc.) must appear in census output.
- **RPC timeout:** first A2 session hit 300 s; client raised to 1800 s and re-ran per session (`A2_run_log_20261030.txt`).
- **A4 actor lists:** initial stale-slot counters mis-counted movement; live-list walk (`a_actors.lua`) repeated runs with identical events (T-38 freed slots retain fields).
- **Extended HP / iframe addressing:** `currentHp` at `0x10026 + slot`, iframe at `0x10028 + slot` (slot = actor DP base).
- **Campaign did not merge notes:** `mesen2-A_notes.json` requires `extract:lt` and `expect` on instructions because tagged comment lines reject `expectOld` (campaign §10); **do not re-merge** the `cop_handlers_sprite` entry twice (hazard noted in the A close-out).
- **Input / buttons.** The A runs used the vanilla O ROM from `orig_S01r`, whose pad map is the identity map: physical B gives `$8000` (the interact press in the A1 run and the melee press), physical A gives `$0080`. In this baserom build physical A feeds logical `$8080` (interact `$8000`, attack `$0080`) and physical B feeds `$4008` (cancel `$4000`, item use `$0008`). Name the build whenever a button is stated.

---

## 9. Open questions

Deduplicated from Campaign A §6 and `open-questions.md` §5 (NQ rows); disposition notes in parentheses.

1. **NQ-001:** Which actors run unlabeled `84:800C`, `84:80B0`, `84:8377` that set `$12` bit 9 (15 writes, scene `$01`)? (STATIC SA-01)
2. **NQ-002:** Is `85:D02F` (`$12 \|= $0030`, 24 writes) the Diamond Mine laborer? (STATIC SA-02; A4 saw `$12 $0230` on laborers)
3. **Who clears the player's `$10` `$0200` after a boss defeat**, and does it survive the two `mu67_vampires` callbacks? (NQ-006 / remainder of boss-defeat half)
4. **NQ-008 / NQ-003 merged:** What does the player's `$12 $0001` do at `ApplyHitDamageToVictim_DamagePath+300`? Victim recovery sign known; **player effect INCONCLUSIVE**.
5. **NQ-009:** Which routine moves Will while `$10` `$2000` is set and `PlayerIdleEntry` returns at once? (STATIC SA-04)
6. **NQ-010:** Does `ApplyMovement` set `$10` bit 2 (`$0004`) every step when `$0008` is clear? (STATIC SA-05)
7. **NQ-011:** Which `$12` bit requests ordinary movement for a `$2000` NPC (`RunActors_CopScriptPostTick+9`)? (STATIC SA-06)
8. **Why does `SpawnListAppend` with `$0420` set `$0400` at spawn** when the body clears it before touch? (NQ-012 / OQ-I049-3 reason half)
9. **Which attack reaches `PlayerAttackHitTest:570` for `$2F00` digits?** (NQ-013)
10. **NQ-014:** Do `SpawnDropGem2` and `SpawnDropByHpTier` clear `$0400` at the same step as `DropBodyGem1`? (STATIC SA-07)
11. **Psycho Slider glide:** does clearing `$0008` matter while `$2000` is set (`slider_glide.asm`)? No A-series glide run; comparison still open (INCONCLUSIVE).
12. **`ToggleActorVisibilityFlag` / `sp5B` rooms** — not entered in A1–A4 (INCONCLUSIVE here).
13. **`$0E = $2000` OAM attribute** on shop-queue NPCs — scene `$91` not measured (INCONCLUSIVE).
14. **Chest-like NPC** for `$0700` behavior — only gem pickup measured.
15. **Freejia kidnapper** (`$12` bits 4–5) — laborer only in A4.
16. **`STZ $070F`** purpose in player tile DMA list — not examined.
17. **Forced-walk / `StartMusic`:** effect of `StartMusic+30` clearing `$10` bit 12 on non-player actors; `$0008`/`$0200` transitions on player during `SyncPlayerToCamera` — not observed in FW run.
18. **Companions frozen during stat reward** — no companions in test scene.
19. **Runtime setter for `$10` bit 4 (`$0010`)** — none seen in 24,190 frames.
20. **`awB0_zombie` mirror-lock case** — not reached.

---

## 10. Apply log

| Item | Result |
|------|--------|
| Investigation apply | **None** during A1–A4 (campaign report: no merge/names in the campaign itself) |
| Note spec | `plans/extracted-audit/edits/mesen2-A_notes.json` — 14 files, dry-run OK in extract:lt; **user apply** per campaign §12 (not recorded in MS01–MS05) |
| Names spec | `plans/extracted-audit/renames/apply-mesen2-A_names.json` — 1 rename (`SetPlayerIgnoreContactFlag`); apply after notes spec |
| Docs (in-repo) | `wram-memory-map.md` Actor flag bits; `actor-thinker-runtime.md:185`; `data-tables-memory.md:215` (campaign §9.3) |
| Closures | **12** rows appended 2026-11-11 (CO01, `closures.md` 248–259); **2** supersession rows 307–308 (`OQ-I025-6`, `OQ-I049-3` from A4) with **not applied** notes |
| Gate | Investigation runs: **0 ROM bytes**; CO01 baseline unchanged (no extract/rebuild in CO01) |
| Hazards | Do not re-merge `mesen2-A_notes.json` `cop_handlers_sprite` block (duplicate-append risk, CO01 §5) |
| Overlap | MS04 and other applies touch combat notes (`OQ-8` G1 row) — wording may differ on `$0400` "source class" vs inline-lethal victim; reconcile before repeating either sentence |

See `plans/extracted-audit/mesen2-results/CO01_close_A.md` for closure bookkeeping and unmatched spec disposition. Proposed closure table also in `A_campaign_report_20261030.md` §11 (superseded by written rows for the 12-id CO01 package).
