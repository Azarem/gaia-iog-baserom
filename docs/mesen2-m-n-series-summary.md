# Mesen2 M and N series: title, menus, maps, NPCs and COP probes (M1 to M4, N1 to N4, Z2-b)

Runtime and static investigation of the US ROM title and diary flows, world map and radar, inventory and console text, town interaction and jeweler rewards, Dark Space / Gaia scene `$E6`, cutscenes and game over, and targeted COP semantics. Compiled 2026-11-12 from `plans/extracted-audit/mesen2-results/M1_20261109.md` through `N4_20261109.md`, follow-up `Z2-b_20261111.md`, closure rows in `closures.md`, and apply logs `MS04_apply.md` and `MS05_apply.md`.

**ROM.** Vanilla **O** (`rebuilt/Illusion of Gaia.smc`, SHA-1 `38de0c84dd2bc3bdfc0a3d7ab0220c79b70887c3`, 2,097,152 bytes) is the default for every step. **R-plain** (`rebuilt/Illusion of Gaia - Rebuilt.smc`, SHA-1 `0cfcb55863052af92041107ecc28226d9f89f8aa`, 3,080,192 bytes, `artifacts/crc.json` mode `plain`) runs M1 inventory remap checks, all of M2, and M4 tile `$20`/`$60` on R. After MS04 the tagged rebuilt gate is checksum 222965960, crc -34152415, totalSize 3062205, SHA-1 `90a04067dd5b5284bd9e152ad222df0e65d08979`; the apply passes changed notes only (gate identical).

**Server.** Mesen2 MCP **0.6.0** on M2 (`harness/scenario_m2.py`), N2, N3, N4, and Z2-b (`get_server_status` and report headers). M1 and M3 do not record server version. No step is static-only; N4 and M3 lean on ROM-file scans inside live sessions.

Sections: 1 Result in one page, 2 What was run, 3 Findings, 4 Shipped notes corrected, 5 Rules for patch authors, 6 Where the findings live in the docs, 7 Tools, states and files, 8 Tool and method lessons, 9 Open questions, 10 Apply log.

---

## 1. Result in one page

| Topic | Question | Verdict |
|-------|----------|---------|
| M — field item use after inventory | On R-plain, does closing the inventory with B then holding B use an item? | **No** on R-plain: `ItemUseDispatch` stays 0 with physical B held (`joypadHeld` `$4008`). VERIFIED-RUNTIME (R-plain) |
| M — Lola's Melody replay | Does a second use jump to `code_038C68`? | **No:** replay stops at flag `$40` gate {232406}, "But nothing happened." CONTRADICTED |
| M — max HP item | Is max HP unbounded? | **No:** HUD renderer clamps to `$28` every frame; poke `$7F` rewrites to `$28` within one frame. CONTRADICTED |
| M — boot logo ENIX row | "Row of 11 parts" on palette 4? | **"AN" plus ten letters of "PRODUCTION",** not eleven identical parts. CONTRADICTED |
| M — title "comet" | What does `spm_title_actors` group `$000008` draw? | **Half-lit Earth** (OBJ palette 4), 240 frames in place then 64 frames at 1 px/frame left; not a comet. CONTRADICTED |
| M — title `WaitByte #B3` | How long is the wait? | **180 actor ticks** and **313 NMI frames** (~5.2 s) because the 135-frame brightness fade runs while the wait is armed with no actor tick. CONTRADICTED (shipped "~3 sec"; later session row supersedes "313 ticks" wording without the NMI frame count) |
| M — diary `$0D94` | Does B on the arrangement screen restore the picked slot from `$0D94`? | **No:** new game sets `$0D94` := `$FFFF`; cursor comes from `$0D8C`. CONTRADICTED |
| M — world map Start | Hold or toggle? | **Toggle:** second Start closes overlay at frame 150 after open. VERIFIED-RUNTIME |
| M — route step timing | Does one step equal n frames or n+1? | **n+1 position deltas over n frames;** last delta of step k shares a frame with the first delta of step k+1 (38 routes, 0 exceptions). CONTRADICTED (old "n+1 ticks" if a tick is a frame) |
| M — `PrintNumber` count 5 | Leading zeros on a one-digit value? | **`00003`:** lowest nibble always prints; zeros after the first printed digit print too. VERIFIED-RUNTIME |
| M — font tile `$20` | Blank digit? | **Period glyph;** blank is `$60`. CONTRADICTED |
| M — scene title box | Interior width? | **20 tiles** (border columns 6 and 27); longest vanilla title 18 glyphs, centred in 18 of 20. CONTRADICTED |
| N — statue pull | Push or pull? | **Pull one tile** toward player with L/R held, same row, ≥32 px away, facing statue, as Will. CONTRADICTED ("push", "Freedan only") |
| N — hidden jewel | Visible before pickup? | **Never drawn:** `$10` `$7000` then `$3000` (hidden). VERIFIED-RUNTIME |
| N — jeweler tier 1 | STR/DEF on first reward page? | **Max HP 8→9 only;** STR/DEF words unchanged. VERIFIED-RUNTIME |
| N — south lunge | Hold facing direction during swing? | **Needs a fresh press** of the facing direction (0 of 20 when held). CONTRADICTED |
| N — game over revive | Gem cost? | **Exactly 100 gems** (`>= 100` in code). VERIFIED-RUNTIME |
| N — fireflies `$E6` | Chains 4/6/8/10 down? | **Only (−2,+2) and (−4,+4)** down-left; chains 4/3 and 8/7. CONTRADICTED |
| N — `LoopEnd` count n | Yields per iteration? | **n−1 yields;** last pass exits by RTI with no yield (3 passes → 2 yields). CONTRADICTED |
| M — radar / map art (Z2-b) | Dark Space dot, player cell, reward panel? | **Blue ring** on portal cell; **grey figure** on player cell (`$32E5`); **grey starburst** and label FORCE for reward value 1 (art does not depend on value — SIMULATED poke warp to `$3D`). VERIFIED-RUNTIME / VERIFIED-STATIC |
| M — leader dot on trip | Visible during tilt zoom? | **Hidden until tick 91** after `TiltPhaseStart` (80+ ticks flags `$3800`, sprite count 14 through tick 90). VERIFIED-RUNTIME |

**Counts (this series’ closure rows):** 40 rows name M1–M4, N1–N4, or Z2-b (including MS05 follow-ups). Roughly 25 VERIFIED-RUNTIME or VERIFIED-STATIC outcomes, 18 CONTRADICTED shipped sentences, 15+ INCONCLUSIVE halves left open. The MS04/MS05 passes changed **0 ROM bytes**.

**What changed in what we believe:**

1. **Title and diary UX are measured, not guessed.** The boot logos spell "Nintendo PRESENTS" and ENIX "PRODUCTION"; the title Earth is not a comet; diary erase shuffles hidden sort keys; world-map motion applies n+1 deltas over n frames.
2. **Inventory and stats respect engine clamps.** Max HP never displays above `$28`; closing the inventory with B does not arm item use on the remapped build; Lola's Melody replay is gated by flag `$40`, not a second effect path.
3. **Interaction pulls, it does not push.** Solid statues and the jeweler's first tier match the code paths that were actually run.
4. **Combat presentation facts are numeric.** South lunge timing, confetti bursts (15 of 60), sparkle ellipse (51×36 px, period 42 ticks), revive at 100 gems.
5. **Radar and map dots were art-read** in combat scene `$3D` and on a staged South Cape trip; town Start opens PAUSE, not the radar (`playerFlags` bit 3).

---

## 2. What was run

| Step | Ids-or-topic | Method | Volume |
|------|----------------|--------|--------|
| M1 | Inventory, items, chests, overlay words | Write/exec hooks, R and O states (`orig_S09`, `S01r`, slopes, chests); remap button census on R-plain | 23 question rows; 16 VERIFIED-RUNTIME, 5 INCONCLUSIVE |
| M2 | Boot, title, diary, buttons | Cold boot screenshots (O/R-plain), diary erase/copy/new-game flows, physical-button matrix on `$065E`/`$0656`, soft reset on O | 800-frame boots; 12 buttons × title/diary lists; closure supersedes title wait duration via V1 row |
| M3 | World map, routes, exits | 38 scripted routes + menu census, Edward's Castle `CMP` on `playerYPos`, Start toggle, radar screenshot S10, masked choice ids | 27 menu sites; 4 long routes for `$0D5C` clear; static 38-array ROM scan |
| M4 | Dialog/console/title font | VRAM dumps, template runs `$0F`/`$10`, scene titles, BCD patch for `PrintNumber`, shared-word inventory census | Font hash 1113346293; jingle 73 NMI frames |
| Z2-b | Radar art, map party dots, natural exit | `z2b_kit.lua`: warp+settle, trip ticks, party pokes, Edward's Castle 3 exit attempts | Scene `$3D` radar; N03 trip k=10..100; SIMULATED party/`$28` forces |
| N1 | Doors, jewel, statue, wander AI | Talk paths with physical B on O; L/R pull on `sg51`; scene `$5B` flicker parent; roof-man step timing | 6 VERIFIED-RUNTIME of 21 ids |
| N2 | Lunge, confetti, game over, `$FD` TM | S10 combat, Castoth poke path, staged `$2F` palette, `$FD` register watch, real `$E8` game over | South lunge only among compass directions |
| N3 | Dark Space, `$E6` Gaia | Portal runs, firefly census 1500 frames, BG staging exec counters, disclosed ROM patches for `$89`/`$8C`, projectile VRAM diff | Form poked for Shadow dissolve |
| N4 | COP loops, pan, warps, spawns | Exec hooks on `LoopEnd`, `CameraPanUp`, forced-walk list walk (200 entries), acid spider X-branch sample | 451 chat blocks scanned for yield |

---

## 3. Findings

### 3.1 M — Inventory and items (M1)

- **Item use after close (R-plain).** `GlobalInputHandler` does not consume logical `$0008` from a B-close edge; holding physical B (`$4008`) after arrange/inventory exit gives `ItemUseDispatch` +0 for 1–90 frames (VERIFIED-RUNTIME).
- **Arrange dead branch (R).** Target = equipped slot: swap never runs; equipped index stays 0. Source = equipped: index follows. Neither: index unchanged (VERIFIED-RUNTIME). Arrange hooks on R did not fire; tab index 1 shows "View / Relics" — target phase INCONCLUSIVE on R.
- **Use tab keys.** Select, Start, L, R, A leave tab 0 open; D-pad moves; B/Y/X confirm equipped (type 6). `$0AE8` = form×4 + row + 1; rows 4/8/C omitted (VERIFIED-RUNTIME, bounded).
- **Overlay scratch.** At inventory open: `$06CA`, `$06CC`, `$00B2` = 0; `$00F4`/`$00F8` survive open, cleared at close (VERIFIED-RUNTIME).
- **Lola's Melody.** First use runs `UseItem_LolaMelody_Effect`, sets flag `$40`, prints meadow text; second use branches to `code_038C2B` only (CONTRADICTED path to `code_038C68`).
- **Max HP.** Item `$80` briefly writes `$29`; renderer at `ConsoleStringRenderer` {256806} clamps to `$28` (CONTRADICTED "unbounded"). STR + item `$81`: `$7F` → `$55` in one trial.
- **Chest caller.** `GiveItemToPlayer` with X = `$AFA7` from chest path; item `$86` derails CPU (VERIFIED-RUNTIME, caller only).
- **Statues and names.** Six pedestal actors match table; `$38`–`$3F` strings "Mystery Doll" / "Mystic Statue"; blank-name chest ids 7 of 24 observed; `$16`/`$19` print "You found the Teapot!" (VERIFIED-RUNTIME, partial chest census).

**Buttons (R-plain, this build):** physical A → `$8080` (interact `$8000`, attack `$0080`); physical B → `$4008` (cancel `$4000`, item use `$0008`). Inventory arrange used these masks.

### 3.2 M — Title, boot, diary (M2)

- **Boot logos (O/R-plain).** First logo: 16 sprites, OBJ palette 3, "Nintendo PRESENTS". ENIX palette 4: "AN" + "PRODUCTION" (11 parts). Thinkers die at 64/80 `$36` ticks; soft reset clears `$0A02` bit 0 (VERIFIED-RUNTIME).
- **Title Earth.** 48 parts, palette 4, priority 1; x 80–168, y 7–135 for 240 frames, then 64 frames at −1 px/frame; `TM = $16` brings BG2/3 behind "GAIA" (CONTRADICTED comet notes). Operand `$1800` does not explain palette 4 in OAM (cause untraced).
- **`WaitByte #B3`.** Operand `$B3` (179 decimal + 1): **180 ticks** from actor start; **313 NMI frames** including fade-in without actor ticks (closure row from V1 supersedes M2 report's tick-only reading).
- **`WaitByte #77`.** Exactly **120 ticks** (VERIFIED-RUNTIME).
- **Buttons before game start (O).** Raw pad: B `$8000`, Y `$4000`, A `$0080`, etc. Diary: logical A `$8000` confirm, B `$4000` cancel via `$065E`. After start, Type 1: B `$4000`, A `$8000`; Type 2 swaps B/A/Y roles (VERIFIED-RUNTIME).
- **Buttons R-plain.** B `$4008`, A `$8080`, Y `$0040`, X `$0004`; Type 2: B `$8080`, A `$0040`, Y `$4008` (VERIFIED-RUNTIME).
- **Diary erase.** `LDA $1C; STA $1A; STZ $1C` once: `$1A` `$48`→`$38`, `$1C`→0; `$1A` never read; `$1C` read by `SortActors` only (VERIFIED-RUNTIME). O remap B/Y swap during erase prompt; R-plain does not.
- **Diary copy (O).** Source band alternates screenshots every frame when `$0D96` set (VERIFIED-RUNTIME). R-plain: single screenshot hash 16 frames — INCONCLUSIVE cause.
- **Start Journey pans.** Slot 0 (`$0080`,`$0320`), slot 1 (`$004A`,`$0238`), empty (`$0080`,`$0300`) — match `diary_entry_table` (VERIFIED-RUNTIME).

### 3.3 M — World map, routes, radar (M3, Z2-b)

**M3**

- **Start toggle.** Scene `$0C`: first Start opens radar path; second Start closes at frame 150 (VERIFIED-RUNTIME).
- **Route timing.** Step with ROM count n applies n+1 deltas in n frames; boundary frame shared between steps (example route `$01`: sum romN 240, applies 245) (VERIFIED-RUNTIME; CONTRADICTED "step runs n+1 ticks" as frames).
- **`WaitByte #n`.** `WaitByte #0F` = 16 ticks and `WaitByte #3B` = 60 ticks on the world map (VERIFIED-RUNTIME).
- **Edward's Castle exit.** `playerYPos` reaches `$02D0`; BEQ fires that frame; ±1 actor Y parity still reaches `$02D0` (VERIFIED-RUNTIME).
- **Exit side effects.** `$0D60` := 0 at {51997}; `OverworldExitFinalize` writes `$064A`/`$064B` = `$00`/`$04` (exit/enter fade delays) (VERIFIED-RUNTIME).
- **Quit-only menus.** Staged ids `$09`, `$15`, `$1B` return to origin at frame 329; `RestoreSavedPtr` never runs (VERIFIED-RUNTIME staged).
- **`LookupMapName`.** All 22 staged scene keys found; start scene `$02` → miss index 37 → stall (no NMI 240 frames) (VERIFIED-RUNTIME).
- **`$FE` subroutine steps.** No route array starts with `$FE`; `$0D5C`–`$0D5F` only cleared to 0 (VERIFIED-STATIC + runtime).
- **Party sprites.** Array 7–10: four separate mounted figures (CONTRADICTED "one vehicle"). Enemy legend dot on M3 radar: small blue icon, palette 2 CGRAM `2D7D 7F78 7923 2460` (VERIFIED-RUNTIME).

**Z2-b (closes M map/radar art)**

- **Combat lock vs radar.** Town spawn sets `playerFlags` bit 3 → Start opens PAUSE, not radar (VERIFIED-STATIC). Radar read in scene `$3D` after quick warp + 90 `$36` settle.
- **Markers.** Portal bit 9: tile `$280D`, blue ring (SIMULATED arrival). Player cell: `$32E5`, grey figure; 64 px/cell, viewport −448..640 (VERIFIED-RUNTIME). Reward frame `$32E8`–`$32EB`: grey starburst, label `consolestring_01EAD1` FORCE; code does not vary art by reward value (VERIFIED-RUNTIME value 1 + VERIFIED-STATIC).
- **Leader dot.** After `TiltPhaseStart` {238516}: hidden through tick 90; six sprites at tick 91 (Will from behind) (VERIFIED-RUNTIME). `animScratch2 | $0804` while menu open; forcing word 0 still allows 60/60 poll hits in 60 frames (SIMULATED isolation — bit roles INCONCLUSIVE).
- **Party art `#00`–`#0D`.** Poked arrays: distinct figures for 0–5; pig `#06`; `#0B` yellow biplane, `#0C` with figures, `#0D` glider (SIMULATED). `#07`–`#0A`: four separate mounts (confirms M3 correction).
- **Natural exit N03.** Three attempts (B cancel, A Quit, mash): return to `$0A`, `$36` stall 163–183 frames at load, no APUIO hang (VERIFIED-RUNTIME). M3 staged hang not reproduced.

### 3.4 M — Text and menus (M4)

- **Tile `$20`.** Period glyph O and R; `$40` solid; `$60` transparent (CONTRADICTED blank claim). R transform swaps clear cursor to `$2060` (VERIFIED-RUNTIME what; why INCONCLUSIVE).
- **Dialog pixels.** Value 1 = stroke (CGRAM `$11`), 2 = top/bottom rows (`$12`), 3 = surround (`$13`, 0 in samples) (VERIFIED-RUNTIME).
- **`DrawBox` + cursor.** Leaves `$09A0` = pos + `$82` (VERIFIED-RUNTIME).
- **`PrintNumber`.** Patched count 5 on digit 3 → `00003` on screen (VERIFIED-RUNTIME).
- **Scene title.** Interior **20** tiles; N=18 title uses columns 7–24 with padding (CONTRADICTED 18-tile interior). Banner flag `$00B4` ~140 idle frames (VERIFIED-RUNTIME).
- **Barrel-roast jingle.** 73 NMI frames from sync actor; SPC still playing when dialog opens; reload after dialog close (VERIFIED-RUNTIME).
- **`ComposeDigitSprites_AtCursor`.** Only caller `DiaryDigitDisplay_noref` unreferenced; runtime hooks 0 (INCONCLUSIVE pose shift).

### 3.5 N — Town, doors, combat presentation (N1, N2)

**N1**

- **`push_handler_solid`.** Mask `$0031`; L/R with facing; 16 px one tile; column approach failed in 3 tests (VERIFIED-RUNTIME pull; column INCONCLUSIVE).
- **Hidden jewel.** Never visible; pickup gives item `$01`, flag byte `$0A50` bit 1 (VERIFIED-RUNTIME).
- **Town doors.** Both keep `WaitWhileOffscreen`; on-screen first pass does not occur (VERIFIED-RUNTIME stale note).
- **Scene `$5B` flicker.** Four helpers flip parent `$10` bit `$2000` every frame (VERIFIED-RUNTIME).
- **`sc01_roof_man`.** 16 px per step (1 of 13 NPCs) (VERIFIED-RUNTIME).
- **Stand wait.** `$08` = `$78` → 121 ticks; dialogue does not reset counter (VERIFIED-RUNTIME).
- **Jeweler 8 jewels.** Max HP 8→9; STR/DEF unchanged on measured pages (VERIFIED-RUNTIME).

**Buttons on ROM O (N1, identity map):** interact logical `$8000` = physical **B**. Jeweler talk required B, not A. The remap words of this baserom build (A `$8080`, B `$4008`) do not apply to these runs.

**N2**

- **South lunge.** Follow-up to swing; curve `#46` 6×0, 19×3, 4×1; wall rebound; +1 damage; needs **fresh** facing press (CONTRADICTED hold sentence). Projectile south in `$E8`: 22 ticks, dies on `$4000` in actor flags.
- **Confetti `$FD`.** 60 spawns, **15** pass `AND #$0003` (exact ¼, not "about") (VERIFIED-RUNTIME).
- **Game over sparkles.** Ellipse ~51×36 px, period 42 ticks; not rising (VERIFIED-RUNTIME).
- **Revive.** 100 gems exactly; 0 gems → real game over, form 2, record `$0AF0` (VERIFIED-RUNTIME). Shadow reason for `$E8` still hedged in note.
- **`$FD` layers.** `TM=$13`, `TS=$11`, mask `$02` stable f487–f738 (VERIFIED-RUNTIME).
- **Adrift look.** `$0AA6` staged: blue / `$4D` dusk / `$52` night (VERIFIED-RUNTIME look).
- **Pose `$20`.** Will lying on ground beside Kara when entry poked (CONTRADICTED sprite note).

**N2 input note:** the Mesen label `b` started the attack in one probe (ROM O, identity map: physical B = `$8000`).

### 3.6 N — Dark Space and Gaia (N3)

- **Hidden bit through warp.** Player `$2000` set in Dark Space, through dissolve/fade, cleared by `InitActorPool` in `$E6` (VERIFIED-RUNTIME).
- **Shadow + ability.** `Transform_FreedanToWill` frame 6 for 320 ticks; not `Transform_ShadowToWill` (VERIFIED-RUNTIME, form poked).
- **Fireflies.** Only diagonals (−2,+2) and (−4,+4); chains 4/3 and 8/7; X 2..498; lifetimes 147 or 84 ticks (CONTRADICTED shipped chains/down-only text).
- **BG staging `$86`–`$8F`.** Eight ids seen; `$89`/`$8C` only via disclosed patch at {579728}/{579744} reverted after (VERIFIED-RUNTIME).
- **`$0AAC`.** Hidden pyramid sets 1 for Aura gift; standard portal 0 (VERIFIED-RUNTIME).
- **Dark Gaia projectile.** Tiles `$40`–`$4F`, flame bird in VRAM `$4400` from `misc_fx_1CCA80` only loader {254012} (VERIFIED-RUNTIME + static).

### 3.7 N — COP semantics (N4)

- **`LoopEnd`.** Count n → n−1 yields; final pass RTI without yield (CONTRADICTED "each iteration yields").
- **`CameraPanUp`.** Step 6 toward target 0: positions 18, 12, 6, 0 then resume without store (VERIFIED-RUNTIME).
- **Forced-walk 200 lists.** First bytes `$00`×99, `$02`×99, `$04`×1, `$05`×1; finals `$01`×100, `$03`×75, `$08`×25; rows `$04`/`$05` duplicate `$02`/`$00` (VERIFIED-RUNTIME census + VERIFIED-STATIC).
- **`AllocateActorAfter`.** Child `$04` = spawner, `$06` = spawner's old next (VERIFIED-STATIC).
- **`BranchOnPlayerX`.** One west pick on acid spider (VERIFIED-STATIC + one sample).
- **Layer-1 `$4E` tail.** 120 frames, `WaitByte` site 0 hits (VERIFIED-RUNTIME).
- **`$06AC`.** `$0100` in scenes `$0C`, `$E3`, `$6E` (VERIFIED-RUNTIME). `StageMove` / `MoveToward` / orbit: no calls in probed scenes (INCONCLUSIVE).

---

## 4. Shipped notes corrected

| Place | Old statement | Verdict | New statement |
|-------|---------------|---------|---------------|
| `item_use_system.asm` Lola replay | Jumps to `code_038C68` on replay | CONTRADICTED | Replay stops at flag `$40` gate |
| `inventory_mgmt.asm` max HP | "Unbounded" | CONTRADICTED | Clamped to `$28` by HUD renderer each frame |
| `sFB_boot_logo.asm` | Row of 11 equal parts | CONTRADICTED | "AN" + PRODUCTION letters |
| `spm_title_actors`, `sFC_title_intro` | Comet | CONTRADICTED | Half-lit Earth actor (`TitleEarthSpriteActor` rename) |
| `sFC_title_intro.asm` comment | ~3 s for `WaitByte #B3` | CONTRADICTED | 180 ticks, 313 NMI frames (~5.2 s) |
| `sFA_diary_menu.asm` | Restore cursor from `$0D94` | CONTRADICTED | `$0D94` = `$FFFF` on arrangement; cursor from `$0D8C` |
| `WorldMapController`, `spm_overworld_sprites` | Four vehicle pieces `#07`–`#0A` | CONTRADICTED | Four separate figures with shadows |
| `world_map_*` route notes | Step runs n+1 ticks (frame) | CONTRADICTED | n+1 deltas over n frames; shared boundary frame |
| `ConsoleStringRenderer.asm` | `$20` probably blank | CONTRADICTED | `$20` = period; `$60` blank |
| `DisplaySceneTitle.asm` | 18-tile interior | CONTRADICTED | 20-tile interior, 18 glyphs max |
| `sg51_statue.asm`, `ir26_statue.asm` | Push / Freedan-only | CONTRADICTED | L/R pull toward player as Will |
| `player_character.asm` lunge | Holds facing during swing | CONTRADICTED | Fresh direction press required |
| `sE6_gaia.asm` firefly note | Chains 4/6/8/10, must move down | CONTRADICTED | 4/3 and 8/7 down-left only |
| `cop_handlers_script_control.asm` | Each loop iteration yields | CONTRADICTED | n−1 yields for count n |

Additional MS05 note-only edits: radar/world-map art strings, `interaction_handlers`, `FlickerParentActor`, `npc_wander_ai`, `RadarPlotFriendlyActor` (enemy dot colour). Hand-written doc sentences left outside the MS05 scope are listed in its log (radar tile table, `game-systems.md` title width, movement open-gap rows); the movement rows were corrected in the later documentation pass.

---

## 5. Rules for patch authors

1. **On R-plain, do not treat physical B held after inventory close as safe idle input** — it is item-use logical `$0008` (`$4008` word) without a new edge; only a fresh B press in the field dispatches use (M1, R-plain).
2. **Never raise displayed max HP above `$28` in overlay text** without expecting the HUD clamp to undo it the same frame (M1 `ConsoleStringRenderer` path).
3. **Diary arrangement cancel must read `$0D8C`, not `$0D94`,** when implementing slot restore after failed load (M2).
4. **A world-map route step with operand n applies n + 1 deltas over n frames:** the last delta of a step and the first delta of the next share one frame. Do not budget n + 1 frames per step (M3, 38 routes).
5. **Stage radar from a combat scene or clear `playerFlags` bit 3** — towns spawn with combat lock and Start opens PAUSE, not `RadarScreenSetup` (Z2-b).
6. **Use tile `$60`, not `$20`, for a blank console cell** on both O and R; `$20` is a visible period (M4).
7. **Statue motion hooks belong on the L/R shoulder test (handler mask `$0031`; L `$0020`, R `$0010` on ROM O), facing, and range,** not on Freedan form alone (N1).
8. **Ranged south lunge must sample joypad on the post-swing window with a new edge on the facing direction,** not a held direction from the attack press (N2).
9. **Game-over revive UI must deduct exactly 100 gems** (`>= 100` test); sub-100 stays on real game over path (N2).
10. **`LoopStart` count n means n passes but only n−1 yields** — do not insert work after the final `LoopEnd` expecting another yield (N4).
11. **Button masks in docs and patches must state the build:** on vanilla O with the identity map (title, diary, and the first states), physical B gives `$8000` (interact) and physical A gives `$0080`; on this baserom build (R-plain) physical A gives `$8080` and physical B `$4008`.

---

## 6. Where the findings live in the docs

| Topic | Document |
|-------|----------|
| Remap buttons, combat lock / PAUSE vs radar, diary WRAM, revive flag block | [`wram-memory-map.md`](wram-memory-map.md) (§2 display bits, §2.7 joypad, `$0A80` kill block) |
| Boot logos, diary slots, `TitleEarthSpriteActor` | [`code/bank0B-late-bosses-system-cutscene-actors.md`](code/bank0B-late-bosses-system-cutscene-actors.md) |
| Inventory tabs, masks, `$0AE8` rows | [`code/bank02/inventory-menu.md`](code/bank02/inventory-menu.md), [`code/bank02/inventory-overlay.md`](code/bank02/inventory-overlay.md) |
| World-map controller, routes, radar pipeline (structure; art details in merged notes) | [`code/bank03/radar-and-world-map.md`](code/bank03/radar-and-world-map.md) |
| `PrintNumber`, templates, console VRAM | [`code/bank03/text-and-menus.md`](code/bank03/text-and-menus.md) |
| Music jingle wait, scene title actor | [`code/bank02/game-systems.md`](code/bank02/game-systems.md) |
| Pull handlers, jeweler HP tier, doors | [`code/bank00/actors-combat-interaction.md`](code/bank00/actors-combat-interaction.md) |
| Lunge, ledge attacks, `playerFlags` | [`code/bank02/player-character.md`](code/bank02/player-character.md) |
| Game over, sparkles, revive | [`code/bank00/functions-game-over.md`](code/bank00/functions-game-over.md) |
| Gaia scene, jeweler, Dark Space portal | [`code/bank08-native-dao-pyramid-actors.md`](code/bank08-native-dao-pyramid-actors.md) |
| `LoopEnd` handler, `CameraPanUp` | [`cop/families/script_control.md`](cop/families/script_control.md), [`cop/families/camera.md`](cop/families/camera.md) |
| `LoopEnd` / forced-walk wording in prose docs | [`code/bank02/attack-ability-system.md`](code/bank02/attack-ability-system.md) (verify against MS04 part notes if prose disagrees) |

Merged block/part notes in `extracted/` carry measured numbers where a doc row above is still generic (MS04/MS05 read-back).

---

## 7. Tools, states and files

All under `plans/extracted-audit/mesen2-results/` unless noted.

| Kind | Files |
|------|-------|
| Lua kit (`kit/lib/`) | `m1_kit.lua`, `m2_kit.lua` (+ `harness/scenario_m2.py`), `m3_kit.lua`, `m4_kit.lua`, `n1_kit.lua`, `n2_kit.lua`, `n3_kit.lua`, `n4_kit.lua`, `z2b_kit.lua` |
| Report bodies | `M1_20261109.md` … `N4_20261109.md`, `Z2-b_20261111.md`; optional `*_lua.md` for script dumps |
| Draft specs | `specs/M1_notes.json` … `N4_notes.json`, `Z2-b_notes.json`; merged `edits/MS04.json`, `edits/MS05.json` |
| States (`rebuilt/states/`, `states-index.md`) | `orig_S09_inventory.mss`, `orig_S06_title.mss`, `orig_M2_diary_seeded.mss`, `orig_N03_castle_gate.mss`, `orig_Z2b_s3D_radar.mss`, R diary/title seeds, scene packs for N2/N3/N4 |
| Raw / screenshots | `raw/M1_*`, `M2_*`, `M3_*`, `M4_*`, `N*_*`, `Z2b_*`, `raw/screenshots/M2_*`, `Z2b_*` |
| Apply / closure | `MS04_apply.md`, `MS05_apply.md`; `closures.md` rows dated 2026-11-09, 2026-11-10 (M2 wait), 2026-11-12 (Z2-b) |

---

## 8. Tool and method lessons

- **R-plain SP at frame boundaries** sits in `$04xx–$05xx` during `ComposeAllSprites` stack fill — not a server bug; state H1 `sp` clause fails on R (M2).
- **`expect` not `expectOld`** on commented lines for merge in this baserom (MS04/MS05); tagged `extract:lt` prints `; {n}` on comments.
- **`m1.warp` / quick warp** can return before scene settles — absence counts and input tests are invalid until `$36` advances (`z2b.settle`, T-77).
- **Positive control:** M3 used `INC $36` and route sum identities; M2 used raw pad reads; Z2-b logged `$36` stalls (T-74) on natural exits.
- **SIMULATED art reads** (party poke, dot `$28` force, warp to `$3D`) are tagged separately; natural reach for Freejia menu `$09` remains blocked (T-86).
- **Disclosed ROM patches** only for unreachable Gaia BG ids `$89`/`$8C`, reverted with `revert_rom_changes` (N3).

---

## 9. Open questions

Deduplicated from the eight reports and `open-questions.md` §M/N/Z2-b (use question ids only here):

1. HDMA buffer vs sine tables in `GenHdmaSine` scenes — overlaps `$7E:8900–8CFF`? (M1)
2. R-plain copy-flow band: why no alternation though thinker branches match O? (M2)
3. Title Earth palette 4 vs actor operand `$1800` — what sets final OAM palette? (M2)
4. Staged world-map return APUIO wait — staging vs music state? (M3 / NQ-307)
5. What clamps `playerYPos` to `$02D0` at Edward's Castle exit? (M3)
6. `LookupMapName` miss path — CPU ends in bank `$0B` data; what runs next? (M3)
7. Shared-word indices `$00`, `$03`, `$0D`, `$08` outside inventory census? (M4)
8. Why column pull fails on stacked `sg51` statues? (N1)
9. `SetPlayerIgnoreContactFlag` after natural boss defeat vs entry poke path? (N2)
10. North/west/east lunge and projectiles vs south measurements? (N2)
11. N1 words the attack as "`$0080` = physical A on O". That is the vocabulary of this baserom build; on ROM O the attack test is mask `$8001` (physical B, W1-f), and quick-warp O states keep the identity map, which is why the N2 probe saw `b` start the attack. Not re-measured in N1's scenes. (NQ-203, SA-13)
12. Sparkle sprite gaps at animation restarts — `AnimOnce` ordering? (N2)
13. Who reads `$0AAC` after save/load outside `$E6`? (N3)
14. D1 `$F1` echo failure in Gaia rest — reproduces on second run? (N3 / D1)
15. Scene `$03` forced-walk blocked despite rectangle hit — which flag? (N4)
16. First natural `StageMove` / `MoveToward` / orbit site in play? (N4)
17. Z2-b: roles of `animScratch2` bits 2 and 11 for poll child? (Z2-b)
18. Z2-b: why Freejia quick-warp state ignores movement input? (Z2-b)
19. Full-pool Wind Melody, Arrange on R, and 15 N1 ids never reached — still INCONCLUSIVE at source.

---

## 10. Apply log

| Item | Result |
|------|--------|
| MS04 spec | `plans/extracted-audit/edits/MS04.json` — 107 extracted files, 32 notes files; names `apply-MS04_names.json` (7 entries, `TitleEarthSpriteActor`); **186** closure rows appended (110 name MS04) |
| MS04 gate | SHA-1 `90a04067dd5b5284bd9e152ad222df0e65d08979`, checksum 222965960 — **no ROM byte changed** |
| MS04 M/N highlights | M1 Lola gate + max HP; M2 boot/title/diary; M3 world map + Edward exit; M4 text/title; N1 statue/jewel/doors; N2 lunge/confetti/game over; N3 fireflies/Gaia/Dark Space; N4 `LoopEnd` / pan / warps |
| MS05 spec | `MS05.json` — 29 files, 54 note updates; **11** closure rows (2026-11-12) |
| MS05 gate | Same SHA-1 as MS04 gate — **no ROM byte changed** |
| MS05 M/N | Z2-b radar + party art + leader dot + natural N03 exits; M3 friendly legend dot; N1 interaction/flicker/roof-man notes; `RadarScreenSetup` reward wording reworded |
| Skipped | Many INCONCLUSIVE rows; `MenuSelectionHandler.asm` BLOCKED (W1-e); some doc prose updates left outside the MS05 scope |
| Docs | This summary; CO12 did not retarget most M/N measured sentences in `docs/code/**` |

See `plans/extracted-audit/mesen2-results/MS04_apply.md` and `MS05_apply.md` for per-file edit tables.
