# Mesen2 P and S series: input, player flags, abilities, camera, and static checks (P1, P2, P4, S1)

Runtime investigation (P) of the US ROM’s run-to-walk window, joypad remapping and facing tables, Will/Freedan/Shadow ability geometry and damage records, and camera shake, drift, parallax decode, and actor `$12` bit 12. Static investigation (S1) of inventory equip checks, HDMA stride table tail, `InitGravity` operands, dictionary rebuild rules, display-mode consumers, actor `$10` bit `$0200` readers, and related code-only claims. Compiled 2026-11-12 from `plans/extracted-audit/mesen2-results/P1_20261109.md`, `P2_20261109.md`, `P4_20261109.md`, `S1_20261110.md` and the apply log `MS04_apply.md`.

ROM: **P1** used vanilla **O** (`rebuilt/Illusion of Gaia.smc`, SHA-1 `38de0c84dd2bc3bdfc0a3d7ab0220c79b70887c3`) and rebuilt **R-plain** (`rebuilt/Illusion of Gaia - Rebuilt.smc`, SHA-1 `0cfcb55863052af92041107ecc28226d9f89f8aa`). **P2** and **P4** used **O** only (same SHA-1 as above). **S1** did not load a ROM or run the emulator (static reads of `extracted/` only). Server: Mesen2 MCP **0.6.0** for every P step; S1 used no server session.

Sections: 1 Result in one page, 2 What was run, 3 Findings, 4 Shipped notes corrected, 5 Rules for patch authors, 6 Where the findings live in the docs, 7 Tools, states and files, 8 Tool and method lessons, 9 Open questions, 10 Apply log.

---

## 1. Result in one page

| Topic | Question | Verdict |
|-------|----------|---------|
| **P** Run window | When does a second D-pad press start a run? | Second walk entry within **13 frames** of the first (`$040C` counts down from 13); gap 14 fails; cross-direction never runs; first press from standing never runs. E/W run speed **±3**; N/S run mark fires but speed read **0,0** in the sample. VERIFIED-RUNTIME (O and R-plain). |
| **P** Buttons (R-plain) | Physical-to-logical map in this build | Physical **A** → `$8080` (interact `$8000`, attack `$0080`); physical **B** → `$4008` (cancel `$4000`, item use `$0008`); **Y** → `$0040`; **X** → `$0004`; L/R/Start/Select/D-pad pass through. VERIFIED-RUNTIME. |
| **P** Buttons (O Type 1) | After new game (Type 1 remap) | Physical **A** → `$8000` (talk at NPC); physical **B** → `$4000` (item use, no talk). Item use is **not** physical Y here. Shipped “vanilla B interact / Y item” sentences CONTRADICTED. VERIFIED-RUNTIME; CONTRADICTED (notes). |
| **P** Buttons | Logical Y and X in free field | No effect found for `$0040` or `$0004` in scenes `$01` and `$0C` (8-frame holds). INCONCLUSIVE. |
| **P** Facing tables | What does `$0AC8 − 4` select? | Tables 4–7 (`FacingData_*`); 0–3 use `FacingDirectionLookup`; past table end spills; **row 8** reads WRAM `$0100 + frame`, not ROM. VERIFIED-RUNTIME (O and R). |
| **P** Escort tracker | Can facing return **≥ 4**? | Lily scene `$1D`: 10 calls, **A = 2** once and **1** nine times; static list of frames with value 4 exists; which gameplay paths hit them is not traced. INCONCLUSIVE. |
| **P** Wall push cells | North attack collision vs south | Same tile row `(x>>4, y>>4)` as south; unaligned north uses `(x>>4+1, y>>4−2)`. VERIFIED-RUNTIME. |
| **P** Lunge | Force-move and flags | `RangedSetForceX/Y`, `extendedFlags` `$0040`, `actor $10` `$0200`; wall bounce clears flag and `EOR $6000` on `$12`; enemy rebound at `83:C115`. VERIFIED-RUNTIME. |
| **P** Dark Friar fragments | Orbit and “reversal” | Start angles `$00`, `$C0`, `$80`, `$40`; stored velocity sign flips once at diameter 0; fragment keeps direction (**no U-turn**). Shipped “reverse velocity” wording CONTRADICTED. VERIFIED-RUNTIME. |
| **P** Psycho Dash | Player displacement | **52 px** peak in **7** ticks (4,4,7,7,9,9,12), **5** ticks hold, return by replayed deltas (**net 0**); all directions, levels 0 and 1. CONTRADICTED (“not ~54 px”, “delta chain not distance”). VERIFIED-RUNTIME. |
| **P** Ability records | Word 0 and damage byte | Will: word 0 of damage records **never read**; level byte in `$09E0` / `$09E2`; Spin Dash **flight** adds **5/8** (Slider record), not **4/7** (charge-only). CONTRADICTED (Spin Dash 4/7 notes). VERIFIED-RUNTIME + VERIFIED-STATIC. |
| **P** Spin Dash sprites | `StagePlayerSprite #00–#03` | Clears `playerFlags` bit 15; sprite bank **`8F:8000` → `95:8000`**; `spriteset_will_abilities` entries `$00–$03` **not** reached on this path. CONTRADICTED (block note). VERIFIED-RUNTIME. |
| **P** Camera target Y | Player on screen | Actor point **128** lines below top (**Y − `$80`** vs scroll); sprite draws above that point. VERIFIED-RUNTIME (240 unclamped frames). |
| **P** Camera shake | Drift vs recompute | 61 ticks; offsets **−1..+2** per axis applied **after** controller store; **no** accumulation; frozen path (`layerPriorityFlag` `$0200`) ends at original + last offset. VERIFIED-RUNTIME (set path SIMULATED poke). |
| **P** Parallax ratio | X vs Y multiplier | Packed `$0101` / `$0201` give **same** `MulDivide` result on **both** axes; “X one less than Y” CONTRADICTED. VERIFIED-RUNTIME. |
| **P** Actor `$12` bit 12 | Display-filter qualifier | With `displayModeFlags` bit 7 set, only actors with bit 12 in `$12` run; **camera** actor keeps running while player stops. VERIFIED-RUNTIME. |
| **P** Camera drift | Patterned offsets | Danger Slide and Castoth: table offsets applied after controller store, **not** cumulative; `$24` = spawner slot, never `$FFFF` at reached sites. VERIFIED-RUNTIME + VERIFIED-STATIC. |
| **S** Empty equip index | `BranchIfItemEquipped` | Index `$FFFF` → 16-bit read carries into bank → **`$82:0AB3`** (0); no match. VERIFIED-STATIC. |
| **S** HDMA stride table | Entries 03–0C | **No reader**; all 64 config bytes mask to 0–2. VERIFIED-STATIC. |
| **S** `InitGravity` | Nonzero offset operands | **8 of 25** sites use `#01`–`#03` / `#05`; **no** bit 7 set → negation path never runs. Shipped “every call `#00`” CONTRADICTED. VERIFIED-STATIC. |
| **S** `LoopEnd` | Yields per pass | Yields on **every pass but the last** (16 passes → 16 frames). Shipped “each iteration yields” CONTRADICTED. VERIFIED-STATIC. |
| **S** Actor `$10` `$0200` | Readers | Four sites: masks **`$76E0`**, **`$36F0`**, **`$0280`**; friendly pass **`$74E0`** allows `$0200`. Two skip-mask comments incomplete. VERIFIED-STATIC. |

**Counts:** the P verdict tags are per row in the table above. S static — 21 VERIFIED-STATIC, 1 CONTRADICTED (`InitGravity` note); INCONCLUSIVE halves: stride of the `MarkSolid*` indices, padding purpose, boss bit clear, statue push. MS04 changed **0 ROM bytes** (gate SHA-1 `90a04067dd5b5284bd9e152ad222df0e65d08979`).

**What changed in what we believe:**

1. **In this baserom build, physical A is interact + attack and physical B is cancel + item use** — not vanilla O’s A-only-interact / B-item layout; always name **O vs R-plain** when documenting a mask.
2. **The run window is exactly the 13-frame down-counter from the first walk entry**, not a generic “double-tap”; cross-direction and standing first press never open a run.
3. **Psycho Dash moves the player 52 px out and back** via the staged `$36` chain; Dark Friar fragments do not U-turn after the sign flip.
4. **Camera shake and patterned drift add offsets after the controller’s target store**; they do not integrate across frames unless a new mechanism is added.
5. **`InitGravity` is called with nonzero offsets in shipping scenes**, but the bit-7 negation path is dead code in practice.
6. **Actor `$12` bit 12 is the display-filter / overlay-active gate** paired with `displayModeFlags` bit 7, not an unverified camera flag.

---

## 2. What was run

| Step | Ids-or-topic | Method | Volume |
|------|----------------|--------|--------|
| **P1** | Run window, button map, facing row 8, escort tracker | `p1_kit.lua`; exec marks on walk/run/`SetAutoWalkTimer`; `$065E`/`$4218` during 8-frame holds; 36 forced facing calls per ROM; window grid **r = 0..16**, cross-direction pairs; NPC slot `$1450`; escort ~1300–1700 frames in Lily scenes | O + R-plain; states `orig_S01r`, `orig_N01`, `orig_P02`, `R-0cfcb558_*`; `$36` control 165–1177 hits/run |
| **P2** | Abilities, lunge, wall push, art | `p2_kit.lua` + run modules `p2_will`, `p2_df`, `p2_wall`, `p2_lunge`, `p2_auraitem`; watch on damage table ROM 121255–121303; per-tick position logs; VRAM `$8800` vs ROM `misc_fx_1CC000`; screenshots | O only; combat-room states S10/S11/S12; disclosed position/collision/level pokes |
| **P4** | Shake, camera target, drift, ratio, `$12` bit 12 | `p4_kit.lua` + `p4_ledge`, `p4_walk`, `p4_drift`, `p4_ratio`, `p4_bit12`; `MulDivide` marks ROM 60690–60708; 61-frame shake; 240-frame target sample; drift 12 runs across 2 scenes; 40-frame bit-12 filter test | O only; states `orig_P4_s01_freedan_ledge-north`, `orig_N01`, `orig_S13`, drift presets; combat lock cleared for ledge attack (physical **B** on O) |
| **S1** | Inventory, HDMA stride, gravity, dictionaries, flag readers | `rg` + Read on `extracted/`; no emulator; dry-run `specs/S1_notes.json` only | No ROM; addresses from `; {n}` tags |

Positive controls: every P script registered **NMI `INC $36`** and counted one hit per frame (`control36`). Facing order check: `FacingDirectionLookup[0..3]` → 0,1,2,3 carry clear (P1). P4: `INC $36` write callback on every run.

---

## 3. Findings

### 3.1 Run window and auto-walk timer (P1)

- `SetAutoWalkTimer` writes **13** to `$040C`. A walk entry while `$040C >= 0` runs the speed path (`STZ` at tag **181478** on O).
- Measured gaps (O = R-plain for E/W): **r = 10** → `w2 = 0`, run at **13** frames after first walk entry; **r = 11** → `w2 = FFFF`, no run. **r = 0..2** with **h1 = 3**, **h2 = 6** runs. **h1 = 12**, **r = 1** runs; **h1 = 16**, **r = 1** does not (held first press eats the window).
- Cross-direction (**right→left**, etc.): **run = 0**; **right→right** and **left→left** with **r = 1** run at **runT = 4** (E/W speed **±3**).
- Standing first press: `$040C = FFFF` before press; walk opens window but **no** `Run` mark.

### 3.2 Joypad remapping and effects (P1)

Raw JOY1 vs logical `$065E` (`joypadRemapped`):

| Physical | Raw bit | R-plain `$065E` | O Type 1 (`orig_N01`) |
|----------|---------|-------------------|------------------------|
| B | `$8000` | `$4008` | `$4000` |
| A | `$0080` | `$8080` | `$8000` |
| Y | `$4000` | `$0040` | `$0040` |
| X | `$0040` | `$0004` | `$0000` |

- **R** scene `$01`: A → talk (`GlobalAmbientDeferToScript`, defer 1); B → item dispatch. **R** `$0C`: A → `AttackInit`; B → item (no attack).
- **O** Type 1 at NPC: A → `$8000` talk; B → `$4000` item. **O** `$0C`: A attack, B item; second B press once gave **use +0** (unexplained).
- L/R block stance entries (`$A1B0` R, `$CA73` O). Start / Select → overlays; Select + scene `$FF` → inventory.
- Logical **Y (`$0040`)** and **X (`$0004`)**: no marks in free field scenes `$01` / `$0C`.

### 3.3 Facing tables and escort (P1)

- `$0AC8 − 4` indexes form tables: **4** = `FacingData_WillAbilities` (value **4** at frames 24–26, carry set); **5–7** = transform/Freedan/Shadow tables (zeros in sample); **8** reads pointer word **`$0100`** → bytes at **`$0100 + frame`** in low WRAM (e.g. O: `$F4`, `$DC`, `$19`, `$9D` at frames 0–3).
- Row **7** not selected naturally; reached by transient poke. Rows **4–6** seen in natural play (W1-f).
- Escort `EscortFollowPathTracker`: scene `$1D`, 10 logged calls — seed **A = 2** once, moving frames **A = 1** ×9; static frames **`$4A–$4F`**, **`$54–$57`**, Will ability **`$18–$1A`** return **4**.

### 3.4 Wall push, lunge, casting Y (P2)

- North melee uses **`BranchIfSolidSouth`** cell `(x>>4, y>>4)`; north wall sprite **#49**, south **#48**. Unaligned **x = 204**: north wall at **(13,9)**; solid **(12,10)** does not trigger north wall.
- Lunge: **`extendedFlags` `$0040`**, `$09E0 = 1`; wall at painted **(12,9)** north, **(13,9)** south unaligned.
- Dark Friar / Aura Barrier: actor **`$16`** = player **Y word `$0090`** (144); poke to **`$0020`** selects bounded wait branch (one fewer tick when adhoc DMA idle); no natural **`$0020`** spawn without poke.

### 3.5 Dark Friar, Psycho Dash, Spin Dash (P2)

- Fragments at spawn: slots **1210, 1240, 11E0, 11B0**; angles **`$00`, `$C0`, `$80`, `$40`**. After diameter **`$FC` → 0**, position delta sign flips once; velocity then stays signed (**continues same direction**).
- Psycho Dash south L0: peak **(200,196)** = **+52** Y from **(200,144)** at t≈188; return to origin by t≈199; level 1 **`$09E0 = 10`** at peak.
- Spin Dash: after **`LoadAbilityDamageA #1`**, **`$09E0 = 5/8`** (levels 0/1); charge end **`#2`** gives **4/7**. **`StagePlayerSprite`** before launch: **`pf=8001` `sprset=8F:8000`** → after **`8F:8000` → `95:8000`**, **`pf=0001`**.
- Damage watches: three reads per Will cast — index word, **`record+2`**, **`record+4+level`**; **word 0 unread**.

### 3.6 Aura item and art (P2)

- **`SetPlayerSpriteDirect #08`** at ROM **50535** (`80:A03E`): `$0AC8 = 8` through item end.
- Shadow Aura **`$00`**: translucent blue figure → puddle; **`$01`**: small droplets; palette **0**; exit via **`PlayerAuraTransformExit`** / landing **`StagePlayerMoveY #1C`** without restaging row 8.
- Dark Friar VRAM: **1152** bytes from **`misc_fx_1CC000`** at VRAM byte **`$8800`** match ROM byte-for-byte (two frames viewed; 23 groups not all matched).

### 3.7 Camera shake and target (P4)

- Ledge landing: **`DROPLAND`** t=54; **61** `CameraShakeActor` / `CameraShakeFrame` calls; **`tgt − exp`** per tick **−1..+2**; sum **+27 / +26** over 61 ticks; **no** drift after t=115 (target = player-derived value).
- Frozen shake (`$06EE \|= $0200` poke): last tick leaves target at **original + (+1, −1)**; does not restore original.
- Normal play: **120** unclamped frames ×2 scenes; **actor Y − scroll Y = 128** constant; OAM player pieces **16 px above** actor point (Will/Freedan measured).

### 3.8 Drift, parallax, display filter (P4)

- **`CameraDriftPatterned`**: Danger Slide **`$24 = $1090`**; offsets **(0,−1,−2,+1)** Y and **0,1,2** X match table entries, not cumulative. Castoth **`$11E0` / `$1210`** spawner slots.
- **`ComputeScrollDeltas`**: spawn bytes **#11** and **#21** → packed **`$0101`** / **`$0201`**; **`MulDivide` result = target lo/hi** on X and Y (four samples). Scenes **`$23`–`$0A`** list: no sample after harness scene poke (limitation).
- **`$12` bit `$1000`**: with **`displayModeFlags \|= $0080`**, player **X frozen** 200→200 while **camera actor `$1060`** still runs; **560** keep / **80** skip filter decisions; player **`$12 = $0001`**, live filtered slots **`$1030`**, **`$1060`**.

### 3.9 Static inventory and HDMA (S1)

- **`BranchIfItemEquipped`**: 16-bit index with high byte from bank → **`LDA $0AB3,Y`** when equipped index is **`$FFFF`**; **`$0AB3`** holds high byte of Dark Space variant word (**0** in static layout) → no item match.
- **`hdma_entry_stride_by_mode`**: only reader **`ParallaxResolveEntryStride`**; config bytes **`AND #$0007`** → indices **0–2** only; table bytes at indices **3–12** unreachable.

### 3.10 Static gravity, dialogue, collision flags (S1)

- **`InitGravity`**: **25** call sites; **8** immediate offsets **`#01`–`#03`**, **`#05`**; **none** with bit **7** of offset set → **`BIT #$0800` negation** never taken.
- **`dialog_dictionaries`**: rebuild merges **456** words **longest first**, global replace, no word-boundary guard (exact-word strings untouched).
- **`LoopEnd`**: decrements before branch; **last pass does not yield**.
- Actor **`$10` bit `$0200`**: readers **`CombatCollision_InnerLoop`** (`$76E0`), **`RunInteractionCollision`** (`$0280`), plus **`$36F0`** mask; **`$74E0`** friendly path allows `$0200`.
- **Agreed with shipped notes (no note change):** `Bg3TilemapVramDma` bits 0/4/5; HUD bit 14; button wiring in **`system_init`** static listing; drift table words 8–15 unused; choice id mask inert in data.

---

## 4. Shipped notes corrected

| Place | Old statement | Verdict | New statement |
|-------|---------------|---------|---------------|
| `global_ambient_dispatcher.asm` block / comment | Vanilla **B** feeds interact `$8000` | CONTRADICTED | **This build:** physical **A** feeds `$8000` (+ attack `$0080` on R); **O Type 1:** A talk, B item |
| `GlobalInputHandler.asm` | Item use = vanilla **Y** `$4000` | CONTRADICTED | **R-plain / O Type 1:** physical **B** feeds item bit (`$4008` / `$4000`); Y is `$0040` only |
| `body_table.asm` part note (W1-f / P1) | Row 8 reads ROM at start of `FacingData_WillAbilities` | refined | Row 8 reads **WRAM `$0100 + frame`** (stack page bytes) |
| `attack_ability_system.asm` | Dark Friar “velocity reversal” / U-turn | CONTRADICTED | Sign flip once; fragment **keeps direction** |
| `attack_ability_system.asm` | Psycho Dash “not ~54 px” / delta-only ghost | CONTRADICTED | **Player** moves **52 px** out and back via `$36` chain |
| `attack_ability_system.asm` | Spin Dash **4/7** flight damage | CONTRADICTED | **Flight** uses **5/8** (Slider record index at launch) |
| `spriteset_will_abilities.asm` | Spin end uses ability table `#00–#03` | CONTRADICTED | Returns **`95:8000`** normal set; ability **`8F:8000`** override only |
| `camera_scroll.asm` | X multiplier one less than Y for same spawn byte | CONTRADICTED | **Same packed ratio** on both axes in runtime samples |
| `camera_scroll.asm` | `$12` bit 12 meaning unverified | refined | **Display-filter / overlay-active** qualifier with `displayModeFlags` bit 7 |
| `player_character.asm` `CameraShakeFrame` | Offsets −1..+2 (correct) | refined | Measured **61** ticks; **no** accumulation; frozen path end state |
| `camera_scroll_controller.asm` | 128 lines below top | refined | **Actor point** 128 below top; sprite spans measured above point |
| `camera_drift.asm` | `$24` maybe `$FFFF` | refined | **`$24` = spawner slot** at reached sites |
| `cop_handlers_effects.asm` `InitGravity` | Every call offset `#00` | CONTRADICTED | **8/25** calls use **nonzero** offset; negation unused |
| `cop_handlers_inventory.asm` | Equipped wrap “unverified” | CONTRADICTED | **`$FFFF` index → read `$82:0AB3`** |
| `cop_handlers_script_control.asm` | Each `LoopEnd` iteration yields | CONTRADICTED | Yields **all but last** pass |
| `combat_collision.asm` comments | Skip masks omit `$0200` | incomplete | Document **`$76E0` / `$36F0` / `$0280`** paths |
| `dialog_dictionaries.asm` | Substitution rule “not traced” | CONTRADICTED | Longest-first **456-word** merge documented |

MS04 also applied P1 escort frame names and P4 shake part-note measurements; inconclusive halves (logical X/Y, Layer1 parallax room, Gorgon drift, scene `$E8` projectiles, dictionary byte identity vs ROM, boss bit clear) kept prior hedges.

---

## 5. Rules for patch authors

1. **State the build for every button mask.** In **this baserom (R-plain)**, physical **A** feeds logical **`$8080`** and physical **B** feeds **`$4008`**; vanilla **O** after Type 1 uses **A → `$8000`**, **B → `$4000`** for interact/item. Raw pad: **B `$8000`**, **Y `$4000`**, **A `$0080`**, **X `$0040`**, **L `$0020`**, **R `$0010`**, **Select `$2000`**, **Start `$1000`**.
2. **Open the run window only with a second walk entry in the same direction within 13 frames** of the first; do not expect cross-direction or first-press-from-idle to run.
3. **Do not read ability damage table word 0**; only the index word, level pointer, and **`record+4+level`** matter; Spin Dash **flight** damage follows **launch** `LoadAbilityDamageA(1)` (**5/8** measured), not the charge-end **`#2`** load.
4. **Psycho Dash staging moves the player body** by the **`$36`** delta chain (52 px peak); trail actors replay deltas on the player scratch words — not a separate ghost sprite path.
5. **Dark Friar fragments keep their heading after the one sign flip** at zero diameter; do not script a U-turn by toggling stored velocity again without new code.
6. **After Spin Dash, expect sprite bank `95:8000` and cleared `playerFlags` bit 15** — not `spriteset_will_abilities` rows `$00–$03` on the measured path.
7. **Camera shake and `CameraDriftPatterned` add to `cameraTarget*` after the controller store**; offsets do not integrate tick-to-tick; test with **`layerPriorityFlag` `$0200`** if the camera is frozen.
8. **Qualify overlay actors with `$12` bit 12 (`$1000`)** when forcing `displayModeFlags` bit 7 (`$0080`); the camera actor is expected to keep running under the filter.
9. **When documenting `MulDivide` spawn bytes**, do not assume X and Y multipliers differ for the same packed byte pair; verify per scene.
10. **`BranchIfItemEquipped` with empty equipped index reads bank `$82` byte at `$0AB3`** via index carry — patch equipment checks so the indexed read cannot accidentally match a WRAM garbage byte.
11. **`InitGravity` offset byte bit 7 is unused in all 25 shipped sites**; nonzero offsets `#01`–`#05` exist — do not claim “always `#00`”.
12. **`LoopEnd` leaves the final iteration without a yield**; budget one fewer frame than the loop count for COP scripts that chain movement after the loop.
13. **Treat actor `$10` bit `$0200` as ignore-enemy-contact** in collision masks; do not confuse with **`playerFlags` `$0200`** (game over).

---

## 6. Where the findings live in the docs

| Topic | Document |
|-------|----------|
| Remap table, logical X/Y inconclusive | [`wram-memory-map.md`](wram-memory-map.md) (§2.9 Input Remapping) |
| Run-window timer `$040C` | [`code/bank00/system-core.md`](code/bank00/system-core.md) (`UpdateFrameCounters`) |
| Facing helper and form tables | [`code/bank03/field-input-and-items.md`](code/bank03/field-input-and-items.md) (`GetPlayerFacingDirection`) |
| Global input / item dispatch | [`code/bank03/field-input-and-items.md`](code/bank03/field-input-and-items.md) (top of file); [`code/bank02/hardware-and-init.md`](code/bank02/hardware-and-init.md) (`VBlankWaitAndJoypad`) |
| Run, shake, lunge COP names | [`code/bank02/player-character.md`](code/bank02/player-character.md) (`SetAutoWalkTimer`, `CameraShakeFrame`, `RangedSetForce*`) |
| Abilities, fragments, Psycho Dash chain | [`code/bank02/attack-ability-system.md`](code/bank02/attack-ability-system.md) |
| Camera target **`Y − $80`**, layer-1 words | [`code/bank02/camera-scrolling.md`](code/bank02/camera-scrolling.md) (§Variable roles / producers) |
| Drift loops and offset table | [`code/bank00/functions-camera-motion.md`](code/bank00/functions-camera-motion.md) (§Camera drift) |
| Scroll-ratio actors, `MulDivide` | [`code/bank00/camera-scroll-system.md`](code/bank00/camera-scroll-system.md) |
| `$12` bit 12 vs display filter | [`code/bank03/actor-thinker-runtime.md`](code/bank03/actor-thinker-runtime.md) (`RunActors_DisplayFiltered` / `OverlayOnly`) |
| Actor `$10` `$0200` collision masks | [`code/bank03/movement-and-collision.md`](code/bank03/movement-and-collision.md) (`CombatCollision_InnerLoop`) |
| `LoopEnd` yield semantics | [`code/bank00/ramp-launchers.md`](code/bank00/ramp-launchers.md); [`cop/families/script_control.md`](cop/families/script_control.md) (`LoopEnd`) |
| `BranchIfItemEquipped` COP surface | [`cop/families/inventory.md`](cop/families/inventory.md) |
| Camera shake sound rate | [`cop/families/audio.md`](cop/families/audio.md) (cross-ref D1) |

---

## 7. Tools, states and files

All under `plans/extracted-audit/mesen2-results/` unless noted.

| Kind | Files |
|------|-------|
| Lua kits (`kit/lib/`) | **P1:** `p1_kit.lua`; **P2:** `p2_kit.lua`, `p2_will.lua`, `p2_df.lua`, `p2_wall.lua`, `p2_lunge.lua`, `p2_auraitem.lua`; **P4:** `p4_kit.lua`, `p4_ledge.lua`, `p4_walk.lua`, `p4_drift.lua`, `p4_ratio.lua`, `p4_bit12.lua` |
| Draft note specs (`specs/`) | `P1_notes.json`, `P2_notes.json`, `P4_notes.json`, `S1_notes.json`; merged apply `plans/extracted-audit/edits/MS04.json` |
| Save states (`rebuilt/states/`) | P1: `orig_S01r_south-cape-ready.mss`, `orig_N01_sc_first_free.mss`, `orig_P02_before_incan_ruins.mss`, `R-0cfcb558_S01r_*`, `R-0cfcb558_S10r_combat-room-will.mss`; P2: `orig_S10_combat-room-will.mss`, `orig_S11_combat-room-freedan.mss`, `orig_S12_combat-room-shadow.mss`; P4: `orig_P4_s01_freedan_ledge-north.mss`, `orig_S13_slope-field.mss` |
| Raw output (`raw/`) | `P1_window_*`, `P1_btn_*`, `P1_face_*`, `P1_npc_*`, `P1_escort_*`; `P2_pd_trace.txt`, `P2_will.txt`, `P2_df.txt`, `P2_wall.txt`, `P2_lunge.txt`, `P2_auraitem_sink.txt`, `P2_vram_8800.bin`; `P4_ledge_*`, `P4_drift_*`, `P4_b12_*` |
| Script dumps | `P1_20261109_lua.md`, `P2_20261109_lua.md`, `P4_20261109_lua.md` (use for per-call counts) |
| Reports | `P1_20261109.md`, `P2_20261109.md`, `P4_20261109.md`, `S1_20261110.md`, `MS04_apply.md`, `closures.md` (P/S rows) |

---

## 8. Tool and method lessons

- **`m.wait(0)` advances one frame** in the harness (documents gap **r = 0** vs **r = 1** in run-window trials).
- **Combat lock (`playerFlags` `$0008`) strips the attack bit** during `RunActors_Normal`; ledge drop-attack on **O** needs physical **B** (`$8000` raw) with lock cleared — not physical A (`$0080` only in joypad when lock set).
- **Disclosed pokes** (player position, collision paint, `$0AC8`, ability levels, `layerPriorityFlag`, scene words) are logged in raw files; restore actor fields before yielding when extending scripts.
- **`emu.loadSavestate` inside NMI** was required for P2 variant switches (driver reloads state at control hook).
- **Scene-word + teleport harness** failed to move camera target in several scene ids — treat “target stayed 0,0” as a procedure limit unless reproduced from natural entry.
- **Merge `expectOld` vs `extract:lt` tags:** commented lines may still print `; {n}`; use `expect` with instruction text (MS04 tool note).
- **Static S1:** no positive runtime control; contradictions rely on full-site `rg` census (e.g. all **`InitGravity`** operands, all **`hdma_channel_config`** low bits).

---

## 9. Open questions

1. What do logical **`$0040`** (physical Y) and **`$0004`** (physical X on R) do in play? P1 found no consumer in two free-field scenes.
2. Why did the **second B press** on **O** in combat room **`$0C`** fail to dispatch item use while the first succeeded?
3. Does **N/S run speed** read **±3** on open ground when the run mark fires (sample read **0,0**)?
4. Which escort scenes put the player on facing frames **`$4A–$4F` / `$54–$57` / Will `$18–$1A`** while the tracker runs (return value **≥ 4**)?
5. Why does unmodified **Spin Dash** stall at a wall until **`loopCounter`** is poked?
6. Why is the **eighth `$36` chain entry (12)** not applied to the Psycho Dash player position in the trace?
7. What uploads Dark Friar tiles **`$C4`**, **`$C5`**, **`$D5`**, **`$E8`** outside the measured VRAM block?
8. Who sets **`$0AC8 = 3`** (body row 3) in shipping gameplay?
9. **`Projectile*`** actors in scene **`$E8`**: no run (P2); need warp and spawn watch.
10. **`$16 = $0020`** natural spawn for Dark Friar bounded branch — only poke path seen.
11. Does **`Layer1ParallaxRatio`** in viper arena **`$55`** decode like **`ScrollCameraInit`**? P4 did not reach arena from save state.
12. **`CameraDriftPatterned`** at Gorgon **`awB1_gorgon.asm:226`** after quake — only one near mark during scroll-in.
13. **`CameraDriftLoopShip`** and spawn bytes **#41**, **#00**, **#DF** for **`ComputeScrollDeltas`** — not exercised.
14. Do notes that name a **physical button** need separate **O vs R** sentences (ledge attack: O tests **`$8000`**, R tests **`$0080`)?
15. Harness: why several scenes keep camera target **0,0** after scene-word poke with player centred?
16. **S1:** What does **`$82:0AB3`** hold at the five **`BranchIfItemEquipped`** sites in a live session?
17. **S1:** Who clears actor **`$10` bit `$0200`** after boss-defeat sequences that re-apply each tick?
18. **S1:** Per-scene solid-paint operands vs map stride/height (**OQ-26**).
19. **S1:** Do **`stringTypes.json`** and ROM dictionary words stay equal under patch edits; spare bytes after palette bundles **`$77`/`$78`**?
20. **`GetPlayerFacingDirection` during Aura row 8** — natural callers not traced.

---

## 10. Apply log (MS04)

| Item | Result |
|------|--------|
| Merge spec | `plans/extracted-audit/edits/MS04.json` — **107** extracted files; **32** notes JSON files written (P1, P2, P4, S1 among E–W sessions) |
| Gate | `artifacts/crc.json` after rebuild: checksum **222965960**, crc **−34152415**, totalSize **3062205**, SHA-1 **`90a04067dd5b5284bd9e152ad222df0e65d08979`** — **no ROM byte changed** |
| P1 notes | `global_ambient_dispatcher.asm`, `GlobalInputHandler.asm`, `EscortFollowPathTracker.asm` — physical button wording; escort carry frames |
| P2 notes | `attack_ability_system.asm`, `player_character.asm`, spriteset block notes (Dark Friar, Psycho Dash, Spin Dash, Aura art) — **14** comment/part edits in dry-run |
| P4 notes | `camera_scroll.asm`, `camera_scroll_controller.asm`, `camera_drift.asm`, `CameraShakeFrame` part note |
| S1 notes | `cop_handlers_inventory.asm`, `dialog_dictionaries.asm`, `cop_handlers_effects.asm`, `cop_handlers_script_control.asm`, `combat_collision.asm` comments |
| W1-f overlap | `body_table.asm` part note — row 8 WRAM read (same facing fact as P1) |
| Closures | **22** rows in `closures.md` cite **`P1_20261109.md`**, **`P2_20261109.md`**, **`P4_20261109.md`**, or **`S1_20261110.md`** (subset of **186** MS04 rows) |
| Docs | This summary; MS04 listed several **docs** still carrying pre-P wording (`wram-memory-map.md` line 438, `camera-scroll-system.md`, `field-input-and-items.md` Y/B lines, etc.); the later documentation pass corrected `wram-memory-map.md` line 438 and `camera-scroll-system.md` line 39; the `field-input-and-items.md` Y/B lines were not part of that pass |
| Skipped | INCONCLUSIVE rows and “shipped note agrees” S1 static confirmations — no merge |

See `plans/extracted-audit/mesen2-results/MS04_apply.md` for the full per-result table (P1–P4, S1, N4 overlap on `LoopEnd`).
