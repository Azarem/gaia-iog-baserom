# Mesen2 F series: sprite sets, player poses and hidden groups (F1 to F3)

Runtime and static investigation of the US ROM player spriteset tables (`spriteset_will`, `spriteset_freedan`, `spriteset_shadow`, body row 4 and row 8), the residual Freedan frame list at `$0E:86AE`, embedded sprite groups that no frame record names, and the Aura orbital hit rectangles against group header bytes. Compiled 2026-11-12 from `plans/extracted-audit/mesen2-results/F1_20261108.md`, `F2_20261108.md`, `F3_20261108.md`, closure rows in `closures.md`, the apply log `MS04_apply.md`, hidden-group bookkeeping `CO03_close_R1_F2.md`, and extractor follow-up `CO08_IT33.md` / `CO08_IT34.md`.

ROM: O (vanilla US, SHA-1 `38de0c84dd2bc3bdfc0a3d7ab0220c79b70887c3`, file `rebuilt/Illusion of Gaia.smc`) for every session. Server: Mesen2 MCP **0.6.0** (`user-mesen2-mcp-dev`). F1 and F2 are full runtime runs on South Cape scene `$01`. F3 runs inside the G1 combat harness on scene `$0C` (Freedan, Aura cast). The hidden-group trio (`spriteset_transform_poses`, `spriteset_will_abilities`, `spriteset_pickups_effects`, `inventory_spritemap`) was **not** run at runtime in F2 (static census only); IT-33 / IT-34 later fixed extraction and notes for those bytes.

Sections: 1 Result in one page, 2 What was run, 3 Findings, 4 Shipped notes corrected, 5 Rules for patch authors, 6 Where the findings live in the docs, 7 Tools, states and files, 8 Tool and method lessons, 9 Open questions, 10 Apply log.

---

## 1. Result in one page

| Topic | Question | Verdict |
|-------|----------|---------|
| Will ramp poses | What do `StagePlayerMoveXY` indices `$19` / `$1E` / `$21` / `$24` draw? | Front arms-out (south), back one-arm-up (north), left reach (west), right flute-behind-shoulder (east); 2 / 3 / 3 / 3 frames. VERIFIED-RUNTIME |
| Will cycle length | How many animation ticks per ramp cycle? | `$19` hold list `1,1` → **4 ticks**; `$1E` / `$21` / `$24` lists `1,2,2` → **8 ticks**; matches `ramps.asm:30` 4+1 and 8+1 moving frames. VERIFIED-STATIC + VERIFIED-RUNTIME |
| Will stand / idle sets | What do `$04`–`$07` and `$10`–`$17` show? | `$04`–`$07` use a second metasprite set (mp 8854, 8BF6, 8FBB, 93F6); `$10`–`$13` cycle the idle groups of `$00`–`$03` in 6 / 3 / 6 / 6 frames; `$14`–`$17` cycle the `$04`–`$07` groups with the same lengths. VERIFIED-RUNTIME |
| Hold pose row 4 `$20` | Is body row 4 frame `$20` a body, and is it Freedan-only? | **Lying ground pose** (two 16×16 sprites, head left) on palette 0 of the **current form** (Will colours in form 0, Freedan in form 1); not a form-change graphic. VERIFIED-RUNTIME |
| Hold pose note | Does shipped text deny the pose is a body? | **`spriteset_will_abilities.asm:16`** "does not look like a body pose" is **CONTRADICTED**. VERIFIED-RUNTIME |
| Freedan table shapes | First frame of each Freedan index? | Standing mirrors of `$00`–`$03`, 4-frame `$14`–`$17`, sword landing `$1C`, cape back views `$1D`–`$1F` / `$26`–`$29`, dive/lunge left and right `$20`–`$25`, sword compass `$3E`–`$41`, one-frame `$4A` / `$4B`. Call sites for many indices not matched. VERIFIED-RUNTIME |
| Shadow table shapes | Shadow indices `$19`–`$35`? | Splash cluster `$19`–`$1B` (group 148E5D); 11-frame reform `$1C`; shared standing body 148D96 on `$1D`/`$1F`/`$20`/`$22`/`$23`/`$25` (hold 31); streaks `$21`/`$24`; palette 0 **alternates two colour sets** frame to frame. VERIFIED-RUNTIME |
| Shadow climb | Static body while climbing? | **Not run** (no vine/ladder session). INCONCLUSIVE |
| Aura body row 8 | Sequences `$00` / `$01` / `$02` and palettes? | `$00` 20-frame flatten-to-water; `$01` plays backwards to standing body; `$02` blue water ball cycling three groups; palettes 0 on `$00`/`$01`, palette 2 on two 8×8 groups in `$02`. VERIFIED-RUNTIME (forced entry scripts) |
| Aura exit | Where does the sequence end? | Abort → `PlayerAuraTransformExit` → Shadow body set (`$94`, anim `$10`); landing → `StagePlayerMoveY #1C` then same exit with Shadow `$1C` splash frames; row 8 not restaged. VERIFIED-RUNTIME |
| Freedan lone set | What is `$0E:86AE`? | Frame list of index **`$4B`** (table word at ROM offset 950422); one record hold 0 → group `$0E:C393` (9 sprites, sword low, facing left); terminates with `$FFFF`. VERIFIED-RUNTIME + VERIFIED-STATIC |
| Freedan `$4B` staging | Does gameplay select `$4A` / `$4B`? | No immediate COP operand `#4A` / `#4B` on the player; computed `$28` writes not traced; only the force wrote `$28` = `$4B`. INCONCLUSIVE |
| Hidden groups (nine) | Do frame records point at embedded groups? | **No label and no frame record** names `0FCF65`, `0FD5E8`, `0F8BF5`, `0EEEB8`, or the five `inventory_spritemap` addresses; addresses appear only in comments or not at all in `extracted/`. VERIFIED-STATIC; computed pointers and runtime display INCONCLUSIVE |
| Extractor | Were "rows inside a group" extractor bugs? | The count-bounded `sprite-part[@N]` struct prints real 20 B / 69 B groups; old text overran ROM by one byte per hidden group. VERIFIED-STATIC |
| Aura orbital hit box | Which header bytes matter? | Second pass uses bytes **8–11** (body box): **555/555** rect matches DP vs ROM formula; bat **−2 HP** per hit; bytes **4–7** read **0** times over 538 orbital passes; `PlayerAttackHitTest` **0** calls on orbitals (98 calls, all bat as victim). VERIFIED-RUNTIME |
| Group 0 rectangle | Measured Aura group 0 body box? | X −4..+4, Y −8..+14 (`$FC $08 $F8 $16`). VERIFIED-RUNTIME |
| Body vs extents | Why taller than art? | Body box **1–6 px taller** than extents in all 12 groups; design reason not observable. INCONCLUSIVE (numbers VERIFIED-STATIC) |

Tags are per row in the table above. **INCONCLUSIVE** halves: climb, stager, hidden runtime, box-height reason, hidden pointers. Notes and comments only in MS04; **0 ROM bytes** changed at gate checksum 222965960 (`MS04_apply.md`).

What changed in what we believe:

1. **Animation forcing must reset the tick counter.** Poking only `$28` / `$2A` leaves the idle loop stuck; `$08 = 0`, `$24 = 0`, and index/frame each frame end matches `UpdateActorAnimation` output (175/175 metasprite `MATCH` rows).
2. **Body row 4 frame `$20` is a lying-down hold pose**, shared across forms, used by `PlayerPoseHold` callers—not a Freedan-reveal graphic.
3. **Index `$4B` is real art** at `$0E:86AE`, reachable by table index or by sliding the spriteset pointer to row 0 = `$86AE`; no gameplay stager found yet.
4. **Embedded groups are real ROM data**, not mis-read sub-sprites; the extractor now emits them as separate `sprite-group` blocks.
5. **Aura orbitals damage through the body box (bytes 8–11)**, not the default tile box (bytes 4–7); the `$0400` actor flag routes them to combat phase 2.

---

## 2. What was run

| Step | Ids-or-topic | Method | Volume |
|------|----------------|--------|--------|
| F1 | Player tables Will / Freedan / Shadow; body row 4; Aura row 8 | `f1_kit.lua`: warp South Cape `$01`, form pokes; per-frame force on slot `$1000`; OAM vs ROM group compare; script redirect for Aura; PNG crops + contact sheets; `$36` write callback | 9 runs, 175 `MATCH` rows, state `orig_S01r_south-cape-ready.mss` |
| F2 | Freedan index `$4B` / set `$0E:86AE` | `f2_kit.lua`: three 8-frame trials (control, table pointer `+$96`, `$28` = `$4B`); OAM part vote; exec count on `UpdateActorAnimation` at 248405 | 1 run × 3 trials, 9/9 parts each; same state |
| F2 (static) | Hidden-group trio | `rg` / ROM read; no emulator; closure pass on the nine groups | 9 group addresses, no frame-record hits |
| F3 | Aura orbital rectangles | `g1f3_kit.lua` inside G1: scene `$0C`, Freedan + flag pokes; natural, moved bat, forced boundary scan; header read callbacks on `snesMemory` aliases 9000–91BA; static 12-group ROM dump | 3 runs × 480 post frames; 555 rect checks, 538 orbital passes, 85 forced hits |

Positive controls: F1 `$36` once per frame (e.g. Will 229 writes in 229 frames); F2 idle north group 9/9 OAM formula; F3 501 `$36` writes in 480 NMI frames on H1.

---

## 3. Findings

### 3.1 Forcing player animation (F1)

- `UpdateActorAnimation` (`sprite_composition.asm:885`, ROM 248405) runs only when the actor tick in `$24` has expired in the idle loop (`player_character.asm` `loc_02C4BD`). The kit sets `$08 = 0`, `$24 = 0`, `$28` = index, `$2A` = frame **at every frame end**.
- Entry-script poses bypass the tick: `PlayerPoseHold` (50270) and Aura handlers get bank/entry words in `$00`/`$02` like live callers (`dc31_rescuer.asm:25-31` bytes at 371578: bank `$0080`, entry `$C45E`).
- Metasprite check: live pointer at `$7F:000C` compared to ROM group + 4 for each forced frame.

### 3.2 Will table (F1)

| Index | Frames (ticks) | Shape (frame 0) |
|-------|----------------|-----------------|
| `$19` | 2 | Front, arms out (`mp` 997B); list holds 1,1 → 4 ticks |
| `$1E` | 3 | Back, one arm up (9AE6); 8 ticks with 1,2,2 |
| `$21` | 3 | Lean left, reach (9F63) |
| `$24` | 3 | Lean right, flute behind shoulder (A1A3) |
| `$04`–`$07` | 1 each | Stand N/S/W/E on second group set (8854, 8BF6, 8FBB, 93F6) |
| `$10`–`$13` | 6/3/6/6 cycles | Idle groups of `$00`–`$03` (875C, 8B3C, 8EA7, 92E2) |
| `$14`–`$17` | 6/3/6/6 | Same cycle lengths on `$04`–`$07` groups |

### 3.3 Freedan table (F1, F2)

- F1 viewed frame 0 (and full cycles where listed) for `$00`–`$07`, `$14`–`$17`, `$1C`–`$29`, `$3E`–`$41`, `$4A`, `$4B` on South Cape bridge, form Freedan (`$0AD4` = 1).
- **`$4B` list** at `$0E:86AE` (offset 951982): bytes `00 00 | 93 C3 | FF FF` — hold 0, group `$C393`, terminator; table word at 950422 = `$86AE` (`F2_20261108.md`).
- Runtime: `$28` = `$4B` **or** spriteset pointer `$7F:1006` = `$8096` (table base `$8000` + 2×`$4B`) with `$28` = 0 both yield `mp` `$C397`, group `$C393`, 9 OAM rows priority 2 in crop (tile words priority 0, host `$0E` = `$2000`).
- Group `$C393` (offset 967571): extents 21/12 × 44/0, 9 parts; same pose as F1 still `$4B` left-facing sword low.

### 3.4 Shadow table and Aura row 8 (F1)

- Shadow: splash triple `$19`–`$1B`; 11-frame `$1C` reform; standing 148D96 on six indices with hold 31; palette 0 flickers blue/gold vs cyan/green on the same group.
- **`spriteset_shadow_aura_body`** (body_table row 8, offset 121201): `$00` shrinking water (20 frames); `$01` reverse to stand; `$02` water ball; forced via `PlayerAuraTransformEntry` (50519) and redirect to `PlayerAuraLandOnSolid` (50625).
- Landing exit: `PlayerAuraLandComplete` → `StagePlayerMoveY #1C` → Shadow bank `$94` splash; abort exit: bank `$94`, anim `$10`, `playerFlags` `$0008`, `$0AC8` stays 8.

### 3.5 Hold pose body row 4 (F1)

- `spriteset_will_abilities` index `$20`: four identical frames, 32×16 px lying figure; Freedan form uses same layout, Freedan colours.
- Doc phrase **"Freedan reveal"** in `docs/cop/families/player_sprite.md:65,102` does not match the measured pose (still not rewritten in MS04).

### 3.6 Hidden sprite groups (F2 static; extractor struct and note rewrite)

- F2 scope excluded runtime for three question families; the closure pass documents **nine** embedded groups with no `sprite_group_*` label and no `sprite-set` reference in frame lists.
- Locations (ROM offsets): `0FCF65`, `0FD5E8` inside `sprite_group_0FCF27` / `0FD5AA`; `0F8BF5` in `spriteset_will_abilities`; `0EEEB8` inside `sprite_group_0EEE5E`; five words in `inventory_spritemap` (`$10:8B82`, `8B96`, `8BBE`, `8BD2`, `8BE6`).
- Extractor: struct `sprite-part[@12]`; hidden groups print as full groups (example `0EEEB8`: 13-byte header + 1 sub-sprite = 20 B; ROM at `0EEEB1` verified).
- Notes: block and part notes describe the second groups at those addresses; the "extractor artefact" prose is removed (extracted tables, not `docs/`).

### 3.7 Aura orbital hit rectangles (F3)

- Scene `$0C`, Freedan, sim flags `$0AA2` = `$7777`; cast via the held attack button (physical **B**, `$8000`, ROM O) then **physical L** (`$0020`) in the harness (`sched` in the report). Ability entry uses the scripted barrier path, not a separate mask test here.
- Orbitals spawn with `$10` = `$0600` (`$0400` source). Second pass (`combat_collision.asm`) builds victim rect from group bytes 8–11 at `metaspritePtr`+4..+7.
- Measurements: rectMatch **555/555**; bat HP 3→1→0 on forced hits; boundary scan 28 points, rule `(xv - e20) < R` etc.; all 12 `spriteset_aura` groups displayed.
- Header dump (body box vs extents height delta **dH** 1–6): e.g. g0 at `$17903C` ext 8×16, body 8×22, dH 6; bytes 4–7 all `$F8 $F0 $01 $01`.
- `PlayerAttackHitTest` path (bytes 4–7) never invoked for orbitals; 5,114–5,794 reads of other header bytes as positive control.

---

## 4. Shipped notes corrected

| Place | Old statement | Verdict | New statement |
|-------|---------------|---------|---------------|
| `spriteset_will_abilities.asm:16` (block note) | "does not look like a body pose" | CONTRADICTED | Row 4 frame `$20` is the player lying on the ground (two 16×16 sprites); `PlayerPoseHold` holds this frame |
| `spriteset_shadow_aura_body.asm:13` | art / palette / exit "not viewed" | stale | Measured 20-frame flatten, reverse abort, `$02` ball, palette 0/2, exits to Shadow body `$1C` or idle |
| `spriteset_shadow.asm:9` | shapes partial | refined | Full index-shape table for splash, standing, streaks, palette alternation |
| `spriteset_freedan.asm:35` part note | sites not traced | refined | First-frame shapes for listed indices; `$4A`/`$4B` rows added (`$4B` = `$0E:86AE`) |
| `spriteset_aura.asm` block / `sprite_group_17903C` part | default attack box, reader untraced | refined | Orbitals use body bytes 8–11 in phase 2; bytes 4–7 unused for orbitals; group 0 rect measured |
| `attack_ability_system.asm` comment 178745 | (damage path) | refined | Tied to orbital second-pass rectangle |
| Hidden-group notes | "extractor artefact", false row claims | CONTRADICTED | Second `sprite-group` at measured size; no frame list points at it |
| `docs/cop/families/player_sprite.md:65,102` | "Freedan reveal" for row-4 static poses | CONTRADICTED | The doc still says "Freedan reveal"; the pose is the form-neutral lying body |
| `gs2D_lily.asm:1` | reveal wording | unverified | Scene not played; note left |

---

## 5. Rules for patch authors

1. **To preview a player animation index, clear the tick and poke index and frame every frame end:** `$08 = 0`, `$24 = 0`, then `$28` and `$2A` on the actor slot; poking `$28` alone does not advance lists held longer than one tick.
2. **Use `PlayerPoseHold` (body row 4, frame `$20`) for a cutscene lying pose**; the graphic follows `characterForm` palette 0, not a Freedan-only sheet.
3. **`SetPlayerSpriteDirect` / body row 4 is not a Freedan transform**; do not document row-4 holds as reveal graphics without a separate form change.
4. **Selecting a frame list by table address:** either set `$28` to the index or add `2 × index` to the spriteset pointer in `$7F:0006` and run with `$28 = 0` (Freedan `$4B` / `$86AE` pattern).
5. **Do not assume indices `$4A` or `$4B` run in normal play** without finding a computed `$28` writer; no immediate player COP operand exists.
6. **Hidden groups inside a labelled `sprite-group` are real groups** with the current extractor; size them with `sprite-part[@count]` and expect separate labels, not extra rows under the parent header.
7. **Patch Aura-style orbitals with `$0400` on the source and size hit damage using group bytes 8–11**; bytes 4–7 are for the `PlayerAttackHitTest` path, which orbitals do not take.

---

## 6. Where the findings live in the docs

| Topic | Document |
|-------|----------|
| `sprite-set` / `sprite-group` header layout (bytes 0–11, terminators) | [`structs-reference.md`](structs-reference.md#sprite-set--sprite-group--sprite-part) |
| Actor `$28`, spriteset pointer `$7F:0006` / bank `$7F:0008` | [`code/bank00/data-tables-memory.md`](code/bank00/data-tables-memory.md) (§3 actor slot) |
| `UpdateActorAnimation`, metasprite decomposition | [`code/bank03/sprite-rendering.md`](code/bank03/sprite-rendering.md) |
| Player COP staging and `body_table` rows | [`cop/families/player_sprite.md`](cop/families/player_sprite.md) |
| `PlayerPoseHold`, body row 4 | [`code/bank00/actors-player-rewards.md`](code/bank00/actors-player-rewards.md) |
| Aura barrier, orbital spawner (context for F3 scene) | [`code/bank02/attack-ability-system.md`](code/bank02/attack-ability-system.md) |
| `spriteset_aura` include / projectile child | [`code/bank02/player-character.md`](code/bank02/player-character.md) |

Measured tables for Will, Freedan, Shadow, Aura, and hidden groups live in **`extracted/tables/spriteset_*.asm`** block and part notes updated by MS04 and the hidden-group note pass (not duplicated here).

---

## 7. Tools, states and files

All under `plans/extracted-audit/mesen2-results/` unless noted.

| Kind | Files |
|------|-------|
| Lua kit modules (`kit/lib/`) | `f1_kit.lua` (force, OAM, PNG), `f2_kit.lua` (Freedan `$4B` trials), `g1f3_kit.lua` (orbital header callbacks) |
| Result reports | `F1_20261108.md`, `F2_20261108.md`, `F3_20261108.md`; script dump `F1_20261108_lua.md` |
| Draft note specs (`specs/`) | `F1_notes.json`, `F2_notes.json`, `F3_notes.json`; merged in `edits/MS04.json` |
| Closeout | `CO03_close_R1_F2.md`, `CO08_IT33.md`, `CO08_IT34.md` |
| Save state | `rebuilt/states/orig_S01r_south-cape-ready.mss` (South Cape `$01`; indexed in `states-index.md`) |
| Raw output (`raw/`) | `F1_*_oam.txt`, `raw/screenshots/F1_*.png`, `F2_oam.txt`, `F2_*.png`, `F3_natural_0C.txt`, `F3_natural_ai_0C.txt`, `F3_forced_0C.txt` |
| Apply | `MS04_apply.md` |

---

## 8. Tool and method lessons

- **Idle-loop gating:** without `$24 = 0`, forced indices show `NOMATCH` or frozen frames; the discarded F1 probe phase left `raw/F1_probe*` / `F1_dbg_*` (not evidence).
- **Table-pointer trick (F2):** moving `$7F:0006` by `2 × index` with `$28 = 0` must run after a control trial so a stale metasprite cannot masquerade as success; count `UpdateActorAnimation` entries with X = host slot.
- **OAM vs group priority:** player crop showed priority 2 on all nine parts while tile words carried priority 0 and `$0E` = `$2000`; reconcile before using priority in patches (open).
- **Read callbacks:** group header reads during combat require **`snesMemory` bank aliases** (`$17`/`$57`/…:9000–91BA); `snesPrgRom` callbacks missed CPU reads (T-61).
- **PNG from Lua:** large contact sheets can hit MCP timeout after the run completes; OAM text may be missing (`F1_auraD`, T-60) while per-index PNGs remain valid.
- **F3 harness:** `g1f3_kit` `stage == "done"` guard fixes post-`kit.finish` errors from an earlier revision.
- **Hidden groups:** static closure is **absence of frame-record names**, not proof no computed pointer ever targets the address (R3 byte scan did not include those addresses).

---

## 9. Open questions

Deduplicated from the three reports, `open-questions.md`, and CO-03:

1. What drives Shadow palette 0 alternating blue/gold vs cyan/green on the standing body group, and at what rate?
2. Which script stages each Freedan / Will index among `$1D`, `$1F`, `$20`, `$22`, `$23`, `$25`–`$29` now that shapes are known (`OQ-I063-2`)?
3. Which indices do vine and ladder climbs use for Will, Freedan and Shadow; is Shadow static standing or splash while climbing (`OQ-I066-5`)?
4. Is there a terrain-type `$04` floor where the Aura item runs the natural `$02` → `$1C` landing sequence (`OQ-I052-4`)?
5. What reads `$0AC8` after Aura exit while it stays 8?
6. Does `gs2D_lily` show `PlayerPoseHold` as Will or Freedan in scene?
7. Does any code write `$28` = `$4A` or `$4B` through a computed store (`OQ-I063-5`)?
8. How do host `$0E`, tile priority bits, and OAM priority combine (player nine-wide priority 2 case; `OQ-I033-6`)?
9. Which actors besides orbitals carry `$10 & $0400` as second-pass damage sources (`OQ-8`)?
10. Do four orbitals (`$0B1E`) or mirrored orbitals change the body rectangle (`OQ-I066-4`)?
11. Which routine refreshes victim bytes `$20`–`$23` each frame for the bat during phase 2?
12. For `OQ-I067-5`, `OQ-I069-4`, `OQ-I071-5`: does any computed pointer or runtime sequence display the nine embedded groups (static census only so far)?

---

## 10. Apply log (MS04 and follow-up)

| Item | Result |
|------|--------|
| Merge spec | `plans/extracted-audit/edits/MS04.json` (includes `F1_notes.json`, `F2_notes.json`, `F3_notes.json` among 107 files) |
| F notes applied | `spriteset_will_abilities.asm:16`; `spriteset_shadow_aura_body.asm:13`; `spriteset_shadow.asm:9`; `spriteset_freedan.asm` part (`$4A`/`$4B`); `spriteset_aura.asm` + `sprite_group_17903C`; `attack_ability_system.asm` comment 178745; related G1 dark friar / freedan_fx rows in same pass |
| Gate (MS04) | After merge + names: checksum **222965960**, crc **-34152415**, totalSize **3062205**, sha1 `90a04067dd5b5284bd9e152ad222df0e65d08979`; **no ROM byte change** |
| Closures (F rows) | **14** rows in `closures.md` citing `F1_20261108.md` / `F2_20261108.md` / `F3_20261108.md` (includes 2026-11-08 apply rows and 2026-11-11 hidden-group static rows) |
| Docs | `docs/cop/families/player_sprite.md` lines 65 and 102 still say "Freedan reveal" (left outside the MS04 scope) |
| Hidden groups (post-MS04) | **IT-33** extractor + **IT-34** `IT34.json` note rewording (`spriteset_will_abilities`, `spriteset_pickups_effects`, `spriteset_transform_poses`, `inventory_spritemap`); separate gate in `open-questions.md` after IT-33 |
| This summary | `docs/mesen2-f-series-summary.md` |

See `plans/extracted-audit/mesen2-results/MS04_apply.md` for the full MS04 result table; see `CO03_close_R1_F2.md` for closure disagreement on F2 hidden-group runtime grade vs closeout plan text.
