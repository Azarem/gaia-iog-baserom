# Mesen2 G series: combat, hits, rewards and enemy census (G1 to G4, Z2-a)

Runtime and static investigation of the US ROM combat pipeline: which routines handle player and enemy hits, gate flags on actor `$10`, ability damage records, iframe counter sign, defeat rewards and drops, the actor pool at capacity, hit stun and knockback, and which enemy stat rows load in play. The follow-up session Z2-a attempted a natural Castoth defeat for boss-reward ids that stay open elsewhere. Compiled 2026-11-12 from `plans/extracted-audit/mesen2-results/G1_20261108.md`, `G2_20261109.md`, `G3_20261109.md`, `G4_20261109.md`, `Z2-a_20261111.md`, closure rows in `closures.md`, and apply logs `MS04_apply.md` and `MS05_apply.md`.

ROM: O (vanilla US, SHA-1 `38de0c84dd2bc3bdfc0a3d7ab0220c79b70887c3`, size 2,097,152, CRC-32 `1c3848c0`) for every run and state load (`romCheck: match` on all listed states). Server: Mesen2 MCP 0.6.0 for G2, G3, G4 and Z2-a; G1 does not record a server version in its result file. G4 adds Python drivers (`g4_sweep.py`, `g4_tier.py`) on the same server; its `g4.static` decode is ROM-only (no emulator). Rebuilt ROM R was not exercised. MS04 and MS05 merges changed notes only; the post-MS04 gate SHA-1 is `90a04067dd5b5284bd9e152ad222df0e65d08979` (no ROM byte change).

Sections: 1 Result in one page, 2 What was run, 3 Findings, 4 Shipped notes corrected, 5 Rules for patch authors, 6 Where the findings live in the docs, 7 Tools, states and files, 8 Tool and method lessons, 9 Open questions, 10 Apply log.

---

## 1. Result in one page

| Topic | Question | Verdict |
|-------|----------|---------|
| Combat phases | What are phase 1 and phase 2 of `RunCombatCollision`, and where do player attacks go? | **Phase 1** (`CombatCollision_EnemyLoop`, ROM 244729) is the chain reaction: stunned victims with `$0080` in `$10` call `PlayerAttackHitTest` (245085). **Phase 2** (244819) is the source pass: actors with `$0400` call `ApplyHitDamageToVictim` (245075). Every measured player attack, the hit switch and the laborer use phase 2 on the player as source (`$1000`, `$8408` / `$8608`); no fresh player swing entered phase 1. VERIFIED-RUNTIME. Shipped "Player attacks enemy (`PlayerAttackHitTest`)" and swapped phase labels CONTRADICTED |
| Victim `$0080` / source `$0400` | What do the hit-reaction and source-class bits mean? | `$0080` in `$10` is the victim hit-reaction flag (`ApplyHitDamageToVictim` / `ApplyInteractionDamage` set it; cleared when the iframe counter finishes). `$0400` marks an attacking source (player `$8408`/`$8608`, Dark Friar / Aura `$0600`). Idle player is `$8508` (`$0100` keeps it out of phase 2). VERIFIED-RUNTIME |
| Damage formula (player slot) | Does the player actor add `$09E2`? | **No.** Slot `$1000` skips the `$09E2` add; Dark Friar uses `$09E2` = 5, Aura orbitals 0 (damage 2 per hit). VERIFIED-RUNTIME + VERIFIED-STATIC |
| Ability records | Which table bytes matter for damage? | The loaded record byte at +2/+3 (level index) is what runs use; record word 0 is never read. Aura Barrier record is never loaded. Launched Spin Dash uses Psycho Slider record (index 1, `$09E0` = 5 at level 0), not the Spin Dash row. Earthquaker (`LedgeJumpDropLand`) not run. VERIFIED-RUNTIME (level 0); Earthquaker INCONCLUSIVE |
| Iframe counter sign | What does positive vs negative `iframeCounter` mean? | **+17** (bit 0 clear on `$12`): non-player victim frozen (`tick=false` 17 frames). **-17** (bit 0 set, hit switch): recovery with `tick=true`. Player contact: +60 then -30, both tick. VERIFIED-RUNTIME |
| Laborer / iframe route | Diamond Mine laborer first hit? | HP 1, lethal inline, no HUD (`$12` bit `$0020`); `$12` bit 0 routes -17 vs +17 for switch vs bat. VERIFIED-RUNTIME. Kidnapper scene `$32` not hit (music-load stall) INCONCLUSIVE |
| Kill flags (`wramFlags`) | Do dungeon kill bits survive room changes? | **Yes** (`$0C` → `$0D` → `$0C`: killed bat stays dead). Cleared only on a **real** game over (< 100 gems); revive (≥ 100 gems) keeps flags. VERIFIED-RUNTIME |
| `EnemyDefeatDispatch` not-last | What happens when `$0AEC` = 0 at a kill? | Child spawns with item **`$83`**; BCD counter wraps to word **`$9999`**, not `$99`. Last kill (`$0AEC` = 1) `JumpFar`s to `StandardEnemyDefeatHandler`. Reachability of `$0AEC` = 0 at a natural kill INCONCLUSIVE |
| Stat +1 items | STR/DEF overflow reset and Max HP cap? | STR/DEF +1: `$7E`→`$7F`, `$7F`→`$55`, `$FF`→`$00`. Max HP +1 clamps to **`$28`** before the item runs (`$7F` poke becomes 28 then +1). VERIFIED-RUNTIME |
| Boss clear handler | Where does `boss_clear_reward_handler` store the range? | `STA $0004` / `STA $000E` are **absolute** engine WRAM (`$0004`/`$0005`, `$000E`); handler slot `$04` and the actor list unchanged (10 slots, prev links 0 mismatches). Scene `$29` poke: +5 max HP, +4 STR, +5 DEF from unclaimed tiers. VERIFIED-RUNTIME |
| Game over (`$E8`) | Shadow form on death in Incan boss arena? | Real game over with < 100 gems: **form 2** (Shadow), save record `$0AF0`, `sceneNext` = `$08`. ≥ 100 gems: revive at last-warp `$0AF4`, HP = max/2, gems − 100, flags kept. Same death in `$0C`: form 0. VERIFIED-RUNTIME (records poked) |
| Drops and tier rewards | Heal id, table percents, room clears? | Heal `$86`+ only from drop pickup with sparkle at pickup; nine drop groups match table (768-byte exact sweep, 0 mismatches). Tier samples: `$0C`/`$71` max HP +1, `$6D` STR +1, `$BA`/`$CC` DEF +1; death flash needs `$12` bit `$1000`. Pickup filter freezes player 0 px in 162 frames. VERIFIED-RUNTIME (5 of 87 tiered scenes sampled) |
| `$0AE4` HUD timer | Which stores are read? | Stored 25, 60, 30, 0 at `80:8286`–`82BD`; only **60** and **0** read in ~3000 frames in `$0C`. VERIFIED-RUNTIME |
| Actor pool full | Hit stun, Wind Flute, ramp at 84/84 free? | `ApplyPlayerHitstun` / flute / ramp spawn return Y = **`$1FC0`**; stores hit sentinel `$1FC0–$1FEF`, **no** stagger child: player stands **60** ticks, mask 0. Flute: `displayModeFlags` `$0080` **1800** frames, no controller. Ramp: orbit diameter on wrong actor, **8 px/frame** to map edge. VERIFIED-RUNTIME (pool poked; max natural live **56**/84). `ApplyInteractionDamage` skips sentinel writes |
| Stagger / knockback | Stun length and wall cut-short? | **16** controller skips after hit tick (+ hit frame); release 16 frames after spawn (scripted t=111→127). Wall-stopped slide (37 px, not ×16): cut-short zeros `$2E` and `$08` on victim. Full 48 px slide keeps chain. VERIFIED-RUNTIME; cut-short purpose INCONCLUSIVE |
| Thinker pool | Failed spawn / empty lists? | Failed `AllocateSpecialActor` writes new entry on **caller** slot (rewritten next yield). Sole thinker killed: `$5C` = freed slot. Sole actor unlinked: `$56` = 0, `$58` = `$1000`. `$5A`/`$5C` zeroed at scene init. VERIFIED-RUNTIME + VERIFIED-STATIC |
| Hit sounds | Player stun vs contact? | Scripted `ApplyPlayerHitstun`: `#07` all forms. Contact: `#07` Will, `#08` Freedan/Shadow. VERIFIED-RUNTIME |
| Knockback tier ≥ 2 | Any hit victim use tier 2+? | **No** in 233 finished scenes: tier writes 0, 1, copy, or `$0C` (diary menu only, 130 stores); stagger tier read **0** times. VERIFIED-RUNTIME |
| Enemy stat census | Rows loaded vs table? | **62** spawn-used rows load at runtime (1,317 spawn resolves = static count); **16** rows never loaded (0 of 1,559 stores). Gem type per row matches table; drop rates from G2. VERIFIED-STATIC + VERIFIED-RUNTIME |
| Castoth natural defeat (Z2-a) | Boss death callback and reward? | Body HP stayed **40**; death callback / helper exec counts **0**. Boss-reward catch-up not observed. INCONCLUSIVE; N2 forced-entry evidence stays SIMULATED |

Counts: 20 topic rows. Shipped extracted notes: **MS04** applied combat, reward, pool and stagger corrections (see section 4); **MS05** applied `wramFlags` measurement only. The campaign changed **0 ROM bytes** on the gated rebuild.

What changed in what we believe:

1. **Player attacks are evaluated in phase 2**, not as the old "phase 1 player attack test". Phase 1 only chains off victims already in hit-reaction.
2. **Ability damage follows the record byte actually loaded**, not the nominal ability name: Spin Dash damage uses the Slider record; Aura Barrier table is unused at runtime.
3. **Defeat economics:** kill bits persist across rooms; only a non-revive game over clears them. Counter-arena not-last kills drop item `$83` and use a `$9999` BCD wrap.
4. **Pool exhaustion is a hard hazard:** sentinel slot `$1FC0` absorbs spawns without unlinking the lists, but gameplay soft-locks (60-tick stand, stuck flute overlay, runaway ramp).
5. **Knockback tiers 2–3 exist only in data and the diary menu**, not on any hittable actor in the shipped game.
6. **Castoth natural defeat remains unmeasured** for the boss `$0200` clear and post-boss reward chain (Z2-a stopped after hazard tuning failures).

---

## 2. What was run

| Step | Ids-or-topic | Method | Volume |
|------|--------------|--------|--------|
| G1 | Hit paths, gate flags, abilities, iframes | `g1_kit.lua`: exec/write/read callbacks on `RunCombatCollision`, `ApplyHitDamageToVictim`, `PlayerAttackHitTest`, `ApplyInteractionDamage`, ability records; `g1.trial` / `g1.warp` on S10/S11/S12/S12b plus warps to `$3F`, `$32` | Scenes `$0C`, `$83`, `$3F` (+ failed `$32`); ~21 raw logs; forms Will/Freedan/Shadow; attack via `sched` (Mesen key `b`; ROM O identity map, physical B = `$8000`) |
| G2 | Death, drops, tiers, game over, boss handler | `g2_kit.lua`, `g2_runs.lua`, `g2_static.lua`; drop farm 900 random + 768 exact sweep; kill-all samples in 5 tiered scenes; boss scene `$29` with `playerFlags` `$0020` poked | ~12,000 frames; states S07/S09/S10 and warps; disclosed item/record pokes on K4 and game-over runs |
| G3 | Pool full, stun, knockback, thinkers | `g3_kit.lua`, `g3_hit.lua`, `g3_runs.lua`; disclosed free-list fill to 84 slots at hit/flute/ramp/thinker entry; walker self-test on actor/thinker lists | Scenes `$0C`, `$24`, `$83`, `$85`, `$FB`→`$FC`, `$2A`; ~12,000 frames; archer scripted hit + bat wall knockback |
| G4 | Stat row census, knockback tier | `g4_kit.lua`, `g4_runs.lua`; `g4_sweep.py` 255 scene warps with per-slot `statsPtr` / tier callbacks; `g4_tier.py` on diary state; `g4.static` ROM decode | 233 scenes finished; 1,317 spawn resolves; 1,559 row stores logged; 21 scenes derailed CPU; diary 130 tier `$0C` stores |
| Z2-a | Natural Castoth body defeat | `z2a_kit.lua` planner bot; exec counters on death callback 695326 and helper 697198/697204; inputs only from `orig_Z2a_castoth_hands_down.mss` | ~2,286 frames in R1–R5 tuned runs (~10,300 session total); 2 player deaths used of budget 3 |

G1 finishes with static reads of `combat_collision.asm`, `attack_ability_system.asm` and spawn tables. G4 pairs the sweep with `enemy_stats_table.asm` and every `STA $statsPtr,X` site (57 stores, 40 files).

---

## 3. Findings

### 3.1 Hit routing and damage (G1)

- **Phase 1 gate** (244729): requires victim `$10` with `$0080`, `$0040` clear, `$12 & $0010` clear, non-negative iframe counter → `PlayerAttackHitTest`. Measured gate skips: `iframeNeg` at counter -12; `immune12_0010` for hit switch `$0180`; `dead0040` at `$00C0`.
- **Phase 2** (244819): sources with `$0400` without `$0140` build a hit box and call `ApplyHitDamageToVictim` for overlaps.
- **Damage:** `ApplyHitDamageToVictim`: `max(1, STR + (source == $1000 ? 0 : $09E2) + $09E0 − DEF) + characterForm`. Chain: `chainDamage / 2 + 1` in `PlayerAttackHitTest`; victim gets `chainDamage / 2`.
- **Attack path table** (level 0, scene `$0C` unless noted): Will melee 1 HP; Psycho Dash/Slider/Spin 6 (`$09E0` 5); Freedan melee 2; Dark Friar projectile 7 (`$09E2` 5); Aura orbital 2 (`$09E2` 0, no record load); Shadow melee 3; hit switch HP `$FF`→`$FE`, counter -17; laborer HP 1→0 inline lethal `$05C0`, no HUD; bat contact via `ApplyInteractionDamage`, player +60/-30.
- **Slot reuse:** inline-lethal victim slot reused **5** frames after hit (G1 poke); **4** ticks in G3 bat run with damage number still bound to `$24`.
- **Child flags:** `$2F00` in `PlayerAttackHitTest` (245351); `$2B00` on damage path with `$1000` OR into child `$12` (tags 245765, 245822).
- **Callbacks:** `ApplyPlayerHitstun` (50071) never ran in G1 (no enemy attack on player). Contact uses `ApplyInteractionDamage` (246752).

### 3.2 Iframes and HUD bits (G1, G3)

- **Iframe sign:** positive counter = freeze (+17 victims); negative = recovery (-17 switch, -12 after freeze, -30 player after +60).
- **`$12` bit `$0020`:** skips HUD register updates (`hudMax=0` laborer).
- **`$12` bit `$0001`:** set → -17 iframe assignment; clear → +17 (bats).

### 3.3 Abilities (G1)

- Loaders `LoadAbilityDamageA` / `B` read only bytes +2/+3; word 0 at `$D9AD`/`AE`, `$D9B3/B4`, `$D9B9/BA` never `RECREAD`.
- Callers at level 0: Dash/Slider/Dark Friar/Spin Dash launch use index 1 Slider record for Spin (`$09E0` 5). No caller loads Aura Barrier record (index unused). Freedan index 2 Earthquaker only at `LedgeJumpDropLand` (182013), not executed.

### 3.4 Defeat, drops and rewards (G2)

- **Counters:** `$0AEC` / `$0AEE` zeroed at scene entry (`83:DDA4` / `DDA7`); +1 per spawned enemy with nonzero enemy number (`83:CF99` / `CFA4`).
- **K3 dive bats:** nine not-last kills spawn `field_reveal_object` with `$26` 8..1, item `$83`; at `$0AEC` = 1, STR +1 tier 2 via standard handler.
- **Drop table:** group 0 thresholds 103/93/45/15 per 256 bytes (40.2/36.3/17.6/5.9%); groups `$10` and `$20` as in G2 verdict table; 0 mismatches vs `EnemyDropSystem` header.
- **Gems:** type 1/2 → fixed ids `$83`/`$84`; type ≥3 → HP-tier table; type 0 skips gem path (`$BA`: 1 of 5 kills on gem path).
- **`SetSpritePalette #00`:** clears `$0E00` on victim `$0E` (`$2600`→`$2000`); victim already hidden (tag 56711).
- **`$0AE4`:** writers 25/60/30/0; readers only 60 and 0 paths in measured HUD window.

### 3.5 Game over and boss reward (G2)

- **`game_over_sequence`:** `$E8` Will 0/99 gems → form 2, dest save entry `;00` (`$08`), `wramFlags` cleared; 100/150 gems → revive entry `;03` (`$04`), HP half, gems reduced, flags kept; `$0C` contrast → form 0.
- **`boss_clear_reward_handler`:** slot `$10F0`; engine `$0004` holds scene/tier bytes `0C`/`29` then `01`/`02` during grant; list head `$56` unchanged.

### 3.6 Pool full, stun and knockback (G3)

- **Fill method:** all 84 free-list words zeroed from `[$4E]`, sentinel `$FFFF`, `$0DBC` = 84 at function entry (disclosed poke).
- **`ApplyPlayerHitstun` full pool:** Y=`$1FC0`, ghost writes to `$1FE8`/`$1FEC`/`$1FEE`/`$7F:1FEA`, joypad mask 0, **60**-tick positive counter in place, no `STAGGER-START`.
- **Archer scripted hit (pool OK):** stagger **16** frames (`RELEASE-PLAYER` t=127 from t=111); then counter -30.
- **Wind Flute:** child Y=`$1FC0`, `displayModeFlags` `$0080` held 1800 frames, no `CONTROLLER-ENTRY`, player idle `ent=C4C8`.
- **Ramp west:** `STORE-ORBITDIAMETER` targets wrong actor (`$19F0`); player x 1008→2048 in 146 frames at 8 px/frame until scene change.
- **Wall knockback:** 48 px north slide keeps `$2E=B180`; 37 px blocked path `CUT-SHORT-V` at tag 55621, `$2E` and `$08` zeroed on victim `$1060`.
- **Thinker spawn failure:** `SPAWNTHINKER-after-alloc` carry=1; entry on slot `$1000` rewritten to `D64A` by next yield.
- **Empty lists after boot scene census:** `KILLTHINKER-SOLE` leaves `$5C=$0F20`; `UNLINK-SOLE` leaves `$58=$1000`, count 0 until next init (`83:CEA7` zeroes `$56–$59`).

### 3.7 Enemy stat rows and tiers (G4)

- Table 110 rows at ROM 109552 (`$01:ABF0`); byte +3 = gemDropType.
- **Never loaded (16 rows):** `$06 $07 $09 $1F $20 $21 $22 $38 $39 $3B $40 $41 $4B $52 $53 $59` — no spawn record, no code operand, 0 stores in sweep.
- **Gem buckets (spawn-used):** 18 type-1 rows, 19 type-2, 10 type-3; row `$11` gem 3 via code only (`sp5A_phantom_ribber`, `ec12_skull_chaser`).
- **Tier writers:** 0 init, 1 player/`mu5F_cyclops`, copy in stagger child setup, `$0C` diary `DiaryStartSlotLoop` (779122) only — not on victims. Stagger tier read site 55463: 0 hits in sweep + diary control.

### 3.8 Castoth attempt (Z2-a)

- State `orig_Z2a_castoth_hands_down.mss`: both hands down (`$00F0` = 3), body slot `$1090` HP 40, player (182, 208).
- **Vulnerability window:** body `$0200` clear in flag word from frame 192 for 332 frames (set again at 524) in long runs.
- **Movement cap:** player cannot stand above y = **176** (four Up holds end at y=176).
- **Hazard pattern:** tuned runs lose **7** HP in one frame before first `attackFrames`; exec deathCb=0 through `Z2a_body5`.
- **Static (Castoth callback):** `func_0A9C1E` gates on `playerFlags` `$0200`, spawns helper and effect, then `StandardEnemyDefeatHandler` (ROM 695326–695407). VERIFIED-STATIC only for this path in Z2-a.

---

## 4. Shipped notes corrected

| Place | Old statement | Verdict | New statement |
|-------|---------------|---------|---------------|
| `combat_collision.asm` block / part notes | Phase 1 = player attack test; phase 2 = enemy-hits-player; player attacks via `PlayerAttackHitTest` | CONTRADICTED | Phase 1 = stunned-victim chain; phase 2 = sources with `$0400`; player attacks use `ApplyHitDamageToVictim` |
| `enemy_stats_table.asm` block note | Which routine handles which attack untraced | CONTRADICTED | All measured player attacks and switch/laborer use `ApplyHitDamageToVictim`; chain-only `PlayerAttackHitTest` |
| `attack_ability_system.asm` + `ability_damage_tables.asm` | "Aura Barrier 5/9", "Spin Dash 4/7" as used values | CONTRADICTED | Loaded record byte wins; Aura record unused; Spin Dash launch uses Slider index 1 |
| `EnemyInitBasic.asm`, `hit_switch.asm` | HP replacement / iframe pick untraced | stale → measured | Laborer HP 1 no table replace; iframe sign from `$12` bit 0 |
| `EnemyDefeatDispatch.asm` | BCD wrap `$FFFF` / `$99` | CONTRADICTED | Not-last path drops item `$83`; wrap word `$9999` |
| `boss_clear_reward_handler.asm` | Stores range in actor `$04` | CONTRADICTED | `STA $0004` / `$000E` are engine absolute addresses; actor list unchanged |
| `inventory_mgmt.asm` | STR/DEF unbounded | refined | Measured overflow resets; max HP clamp `$28` before +1 item |
| `game_over_sequence.asm` | Shadow form on `$E8` "presumably" | refined | Measured gem threshold 100, save vs revive records |
| `ApplyPlayerHitstun.asm`, `hit_stagger_controller.asm`, `cop_handlers_thinker.asm`, `SpawnDamageNumberEffect.asm`, `item_use_system.asm`, `ramps.asm` | "not traced" / analysis only | stale → measured | Pool-full sentinel, 16-tick stagger, thinker spawn clobber, slot reuse timing, flute/ramp consequences |
| `hit_stagger_controller.asm` | Only listed writers for knockback tier | CONTRADICTED | Diary menu also writes `$0C`; still no tier ≥2 on victims |
| `StandardEnemyDefeatHandler.asm` comment 56711 | Palette clear effect untraced | refined | Clears `$0E00`; victim already hidden |
| `flag_helpers.asm` / `CheckEnemyDefeatedFlag` (MS05) | "no reset at ordinary scene changes" | refined (MS05) | Killed enemy stays dead across rooms; game over vs revive behaviour stated |

---

## 5. Rules for patch authors

1. **Treat fresh player swings as phase-2 `ApplyHitDamageToVictim` hits**, not `PlayerAttackHitTest`. Use phase 1 only when you intentionally chain from a victim already in `$0080` hit-reaction.
2. **Index ability damage through the record byte your loader actually reads**; do not assume the ability name matches the table row (Spin Dash launch uses Slider record index 1; Aura Barrier record is never loaded for orbitals).
3. **When the hitter is slot `$1000`, do not add `$09E2`** to damage; still add `$09E0` from the loaded ability byte.
4. **Respect iframe counter sign:** `$12` bit 0 clear → +17 freeze on enemies; set → -17 recovery. Player contact uses +60 then -30 unless a stagger child exists (then 16-tick stagger, -30 after).
5. **Never exhaust the actor free list in gameplay.** A failed spawn lands on sentinel **`$1FC0`**, corrupts `$1FC0–$1FEF`, and skips stagger/flute/ramp controllers; restore pool head before spawn-heavy overlay code.
6. **Do not store boss reward metadata in the handler actor’s `$04`.** The shipped handler uses engine **`$0004` / `$000E`** as scratch across its `JSR` chain without yielding.
7. **Dungeon kill flags in `$0A80–$0A9F` persist across room loads.** Clear them only via the real game-over path (< 100 gems) or explicit `ClearAllWramFlags`; a revive must keep prior kills.
8. **Knockback tier on victims stays 0 or 1 in play.** Tier 2–3 table entries and the diary’s `$0C` write do not affect combat knockback; do not read high tiers expecting longer slides.

---

## 6. Where the findings live in the docs

| Topic | Document |
|-------|----------|
| `RunCombatCollision` phases, damage formula, actor `$10` flags | [`code/bank03/movement-and-collision.md`](code/bank03/movement-and-collision.md) (`combat_collision` section) |
| Hit stagger, knockback cut-short, pool-full stun | [`code/bank00/actors-combat-interaction.md`](code/bank00/actors-combat-interaction.md) |
| Defeat pipeline, `EnemyDefeatDispatch`, drops | [`code/bank00/functions-combat-defeat.md`](code/bank00/functions-combat-defeat.md) |
| Boss catch-up, tier rewards, `field_reveal_object` | [`code/bank00/actors-player-rewards.md`](code/bank00/actors-player-rewards.md) |
| Game over forms, revive records | [`code/bank00/functions-game-over.md`](code/bank00/functions-game-over.md) |
| Dungeon dispatch enemies, kill-counter branch | [`code/bank0A-dungeon-enemy-actors.md`](code/bank0A-dungeon-enemy-actors.md) |
| `$09E0` / `$09E2`, `wramFlags`, actor flag bits | [`wram-memory-map.md`](wram-memory-map.md) (§2.2 actor flags, `$0A80` row) |
| Enemy stat table layout, gemDropType | [`structs-reference.md`](structs-reference.md), [`code/bank00/data-tables-memory.md`](code/bank00/data-tables-memory.md) |
| `$0AE4` enemy HP HUD countdown | [`code/bank00/system-core.md`](code/bank00/system-core.md) (`UpdateHUD` steps) |
| Castoth callback layout (static) | [`code/bank0B-late-bosses-system-cutscene-actors.md`](code/bank0B-late-bosses-system-cutscene-actors.md) (scene `$29` actors) |

---

## 7. Tools, states and files

All under `plans/extracted-audit/mesen2-results/` unless noted.

| Kind | Files |
|------|-------|
| Lua kit (`kit/lib/`) | `g1_kit.lua`, `g2_kit.lua`, `g2_runs.lua`, `g2_static.lua`, `g3_kit.lua`, `g3_hit.lua`, `g3_runs.lua`, `g4_kit.lua`, `g4_runs.lua`, `z2a_kit.lua` |
| Python harness | `harness/g4_sweep.py`, `harness/g4_tier.py`, `harness/a_common.py` (G4 session) |
| Draft note specs (`specs/`) | `G1_notes.json`, `G2_notes.json`, `G3_notes.json`, `G4_notes.json`; merged in `plans/extracted-audit/edits/MS04.json`; MS05 touch via `edits/MS05.json` for `flag_helpers` only |
| Save states (`rebuilt/states/`, `states-index.md`) | `orig_S10_combat-room-will.mss`, `orig_S11_combat-room-freedan.mss`, `orig_S12_combat-room-shadow.mss`, `orig_S12b_great-wall-83-will.mss`, `orig_S05_gold-ship-flute.mss`, `orig_S14_ramp-scene.mss`, `orig_G3_s83_freedan.mss`, `orig_G3_s83_shadow.mss`, `orig_S07_diary.mss`, `orig_Z2a_castoth_hands_down.mss`, `orig_P03_before_castoth.mss` |
| Raw output (`raw/`) | `G1_*.txt` (21 logs), `G2_*` (kills, drop farm, game over, boss), `G3_*.txt`, `G4_sweep_*` / `G4_tier_diary.json`, `G4_static_rows.txt` |
| Reports | `G1_20261108.md`–`G4_20261109.md`, `Z2-a_20261111.md`, `MS04_apply.md`, `MS05_apply.md`, relevant `closures.md` rows |

---

## 8. Tool and method lessons

- **Time axis:** G1–G3 treat `INC $36` (NMI parity) as the frame counter in raw logs; `control36` must equal the requested frames for a valid run.
- **Disclosed pool fill:** Free-list exhaustion is only proven via the poke that sets `[$4E]=FFFF` and `count=84`; natural scenes peaked at **56** live actors (scene `$85`). Label pool-full rows SIMULATED where the method poked the list.
- **Warp hazard:** `g1.warp` / `g2.warper` into scripted scenes can stall in `SpcMusicLoadCmd` (kidnapper `$32`, empty G1 raw). Failures return `hasResult:false` with no raw file.
- **G4 sweep:** Per-scene warp from a savestate hook at ROM 32779 (T-62); 22 scene ids derail the CPU when warped cold—those scenes have **no** enemy spawns, so spawn-path census still covers all 101 spawning scenes.
- **G2 harness fixes:** Enemy filter requires `enemyNum != 0`; `finish` must not overwrite `cnt`; drop-farm seed `seed | 1` collides for adjacent seeds.
- **G3 callbacks:** WRAM ghost addresses print with bit 16 set (`11FE8` = `$1FE8`); read logs accordingly.
- **Z2-a:** Input-only bot with `stopHP` abort; earlier kit versions overwritten—only `body2..5` and `reach` invocations preserved verbatim. T-82/T-83 tool rows filed from Z2-a (`-- requires:` parentheses; sidecar blob size).
- **Apply gates:** MS04/MS05 verified `extract:lt` + `rebuild` with unchanged `artifacts/crc.json` on the tagged gate SHA-1 above.

---

## 9. Open questions

1. Kidnapper (`$32`) and extendedFlags `$0080` on laborer: first hit and flag meaning need a state after Freejia script control (G1 INCONCLUSIVE).
2. Earthquaker record at `LedgeJumpDropLand` (Freedan index 2) not executed (G1 INCONCLUSIVE).
3. Which enemies call `ApplyPlayerHitstun` on the player, and does heavy hit (`$8001`) change the counter (G1/G3)?
4. Enemy projectiles as `$0400` phase-2 sources (G1; ties to duplicate cluster on Aura/projectile `$0400` in `open-questions.md`).
5. Actor at entry `E15B` reusing inline-lethal slot after 5 frames—is it the standard defeat effect (G1)?
6. Stale `$09E2` after a Dark Friar cast when Aura orbitals hit (G1; no prior cast in run).
7. `$0400` effect on damage-number actors (`$2F00` vs `$2B00` looked identical) (G1).
8. Natural `EnemyDefeatDispatch` with `$0AEC` = 0 at kill—no scene with zero counter at dispatch yet (G2).
9. Spawn-flag `$0400` on drop body before `TRB $10`; gem blink frame count (G2 INCONCLUSIVE).
10. `field_reveal_object` rise trajectory—only spawn with `$26` logged (G2).
11. Which code sets `playerFlags` `$0020` per boss arena without a poke (G2)?
12. Engine `$0004`/`$000E` scratch across a COP yield elsewhere (G2).
13. East knockback 384→376 vs west 272→248—wall push-out? (G3)
14. Thinker spawn when list empty and `$5C` stale (G3 / `OQ-17` (e)).
15. Damage number following a **moving** slot occupant (G3).
16. Natural actor pool hitting 84 slots (G3; busiest 56).
17. Why 23 scene warps derail CPU after `g2.warper` (G4); code-named stat rows `$31` `$37` `$47` etc. at runtime (G4).
18. Purpose of 16 unloaded stat rows that still carry gem types (G4).
19. Castoth natural defeat: body damage from y=176, Psycho Dash reach, boulder impact vs ring as 7-point source (`OQ-I030-2` boss half, FR30 catch-up; Z2-a INCONCLUSIVE, N2 forced path SIMULATED).
20. HP-tier boundary at HP 4 vs 5 for drop group selection (G2 new question).

---

## 10. Apply log

| Item | Result |
|------|--------|
| MS04 spec | `plans/extracted-audit/edits/MS04.json` (union of `G1_notes.json`–`G4_notes.json` with E–W series); dry-run OK with length warnings |
| MS04 merge (G rows) | Applied to `combat_collision.asm`, `enemy_stats_table.asm`, `attack_ability_system.asm`, `ability_damage_tables.asm`, `player_character.asm`, `hit_switch.asm`, `EnemyInitBasic.asm`, `EnemyDefeatDispatch.asm`, `boss_clear_reward_handler.asm`, `inventory_mgmt.asm`, `game_over_sequence.asm`, `StandardEnemyDefeatHandler.asm`, `ApplyPlayerHitstun.asm`, `hit_stagger_controller.asm`, `SpawnDamageNumberEffect.asm`, `item_use_system.asm` (`UseItem_WindFlute`), `ramps.asm`, `cop_handlers_thinker.asm`, `actor_pool.asm` (`UnlinkActor`) |
| MS04 gate | Checksum 222965960, crc -34152415, totalSize 3062205, sha1 `90a04067dd5b5284bd9e152ad222df0e65d08979`; **no ROM byte changed** |
| MS04 closures | 186 rows appended (23 name G1–G4 result files in the G combat/reward block) |
| MS05 spec | `edits/MS05.json`; G-related: `flag_helpers.asm` block + `CheckEnemyDefeatedFlag` part for `OQ-67` |
| MS05 skipped (G) | `OQ-53` (`UpdateHUD` comments already correct); `OQ-I041-5` hidden jewel; D1 overlap `ApplyPlayerHitstun` sound (already correct) |
| MS05 gate | Tagged rebuild identical to MS04 gate SHA-1 above |
| MS05 closures | 2 rows reference `G2_20261109.md` (OQ-67 applied; OQ-53/I041-5/I046-1 skipped) |
| Z2-a | No spec; ids remain INCONCLUSIVE per `MS05_apply.md` |
| Docs | This summary; runtime sentences live in the section 6 documents; some `docs/` lines were left outside the MS04 scope and are listed in its log |
| Names | No G-series name changes in MS04/MS05 |

See `plans/extracted-audit/mesen2-results/MS04_apply.md` and `MS05_apply.md` for full per-file tables.
