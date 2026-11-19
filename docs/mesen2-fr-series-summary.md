# Mesen2 FR series: event flag registry runtime verification (FR00 to FR50)

Runtime and static investigation of the US ROM event-flag array, scene-load lifecycle, per-area flag effects, scene arrival locks, and checkpoint presets. Compiled 2026-11-12 from `plans/extracted-audit/mesen2-results/FR00_20261104.md` through `FR50_20261106.md`, `closures.md` FR rows, `MS04_apply.md`, and `plans/flags/results/CO09_flag_apply.md`.

ROM: O (vanilla US, SHA-1 `38de0c84dd2bc3bdfc0a3d7ab0220c79b70887c3`, 2 097 152 bytes, HiROM FastROM) for every session. Server: Mesen2 MCP 0.6.0 (Mesen 2.1.0 where noted), `--mcp-lib-dir` = `kit\lib`, `--mcp-results-dir` = `raw`; FR40 and FR50 spawn the server via `harness/mcp_client.py`. No session is static-only: each report pairs a static prelude with Mesen2 runs; only helper census and song-layout style work live outside this series. The rebuilt R-plain image was not executed.

Sections: 1 Result in one page, 2 What was run, 3 Findings, 4 Shipped notes corrected, 5 Rules for patch authors, 6 Where the findings live in the docs, 7 Tools, states and files, 8 Tool and method lessons, 9 Open questions, 10 Apply log.

---

## 1. Result in one page

| Topic | Question | Verdict |
|-------|----------|---------|
| Scene-load scratch | Does every scene load zero flags `$0000`–`$000F` (`$0A00`–`$0A01`) and leave `$0A02`+ unchanged? | **Yes:** single `STX $eventFlags` at offset 253291 per warp; kill block and tail bytes stay `FFFF` when pre-filled. VERIFIED-RUNTIME. Natural door exits not traced: INCONCLUSIVE |
| Inventory overlay | Does the menu save, zero and restore scratch and toggle flag `$FF`? | **Yes:** `STZ` at 191792, clear bit 7 at 191819, menu `SetFlagByte #00` on cancel, restore 192094, `SetFlagByte #FF` at 192190 (+2 frames). Forced flag `#00` closes overlay without the menu COP. VERIFIED-RUNTIME |
| Kill block | Does an ordinary scene change keep `$0A80`–`$0A9F`? | **Yes** on warp to `$15` / `$24`. World map entry and real game over zero the block (FR30); save/load not run: INCONCLUSIVE |
| New Game milestones | Does Start-button New Game set M01 flag `$F4`? | **No** on the continuous route; first story flag is `$10` at frame 2919. Title idle path sets `$F4` at frame 3481. CONTRADICTED (Start route); idle path VERIFIED-RUNTIME |
| Edward Castle statues | Are scene `$0E` statues inspect-only when flag `$21` is set? | **No:** both states are solid push blocks (`$F0`); flag `$21` only adds `chatPtr` `$8853`. CONTRADICTED |
| Solid Arm / Gem | When is flag `$E8` set and does Gem despawn? | **Before** intro dialog (offset 587597, after lock + `WaitWord #$0120`), not after a fight; Gem absent in six scenes when set. VERIFIED-RUNTIME |
| Diamond Block | Where does item `$07` place? | **Tile X `$0E` only** (e.g. `(0E,19)`); X `$0F` prints failure. Scene `$25` is Inca Ruins entryway. CONTRADICTED |
| Inca hallway statue | Does `ir20_statue` use a position test for flag `$B9`? | **No position test;** simulated hit with `playerFlags` bit `$0002` sets `$B9` and removes the statue. CONTRADICTED (SIMULATED poke) |
| Euro Erasquez | Does holding the Teapot set flag `$9F`? | **Inverted:** with Teapot, text only; **without** Teapot sets `$9F` and Mt. Kress hint. CONTRADICTED |
| Vader barriers | Do barriers require Shadow form? | **No:** Will-form sword hit (physical B) drives both upper and lower barriers. CONTRADICTED |
| Scene `$0A` arrival | Does flag `$3F` leave the joypad locked forever? | **No:** mask `$CFF0` for **239** frames, then message box; physical A frees at frame **278**; flag `$3F` makes arrival free. CONTRADICTED (`scene-flags.json` "stays nonzero") |
| Boss intro locks | Do flags 1280 / 1281 free Castoth / Viper intros? | **No:** scene `$29` free at frame 171 / 1280 clear; scene `$55` at frame 82 — lock timing unchanged with boss-reward flags set. CONTRADICTED (draft effect text) |
| Preset Castoth | Does preset 3 put the player in Shadow at scene `$29`? | **Will stays form 0** for 1500 frames; transform lives in `btF2_neo_castoth` (scene `$F2`). CONTRADICTED |
| Sky Garden preset | Does scene `$58` release after descent? | **Relock persists** (still locked at frame 600); FR40 never frees in `$58`. CONTRADICTED |
| Dark Gaia preset | Does preset 18 lock joypad and require Shadow form? | **`playerFlags` `$0800` clears** at frame 95; **joypadMaskStd never written**; natural arrival is Shadow, preset is Will. CONTRADICTED |
| Engine domains | World map clears kill bits; tomb byte `$0A9F`; layer/event blocks | FR30: VERIFIED-RUNTIME on measured halves (18+ domain rows); many items of the lifecycle, table and name groups INCONCLUSIVE |
| Scene census | How many of 228 scenes have measured arrival class? | **215** scene rows VERIFIED-RUNTIME; **12** INCONCLUSIVE (need story presets); **0** true locked-until-flag entries | VERIFIED-RUNTIME |
| Flag registry | Runtime grades applied? | **31** registry fragments + **9** FRV verdict files applied 2026-11-11 (registry re-check); **687** indices, **916** meanings, **228** scene entries, **19** presets | VERIFIED-STATIC (tool output) + VERIFIED-RUNTIME (FR sessions) |

Counts: hundreds of per-flag and per-scene measurements; **11** shipped extracted note merges from FR contradictions (MS04); **0** ROM bytes changed in the mesen2 note passes. Registry and `db-us/scene-flags.json` scene `$0A` note awaited separate `npm run flags` apply at FR40 write time; the live registry already carries the scene-arrival and preset corrections.

What changed in what we believe:

1. **Scene scratch (`$0A00`–`$0A01`) is ephemeral.** Every load wipes it; the inventory snapshots it; flag `$FF` is a setup latch, not “scene done forever.”
2. **Kill bits (`$0A80`–`0A9F`) outlive rooms** but not the world map or a gemless game over.
3. **Many shipped “form gate” and “inspect statue” sentences are wrong.** Edward Castle statues, Vader barriers, Erasquez Teapot logic, and Diamond Block tile lists are corrected at runtime.
4. **Arrival is cutscene-gated, not flag-gated.** Scene `$0A` releases after a timed lock plus A; boss-reward flags do not skip boss-intro timers.
5. **Checkpoint presets are approximate.** Four of nineteen preset narratives contradict replay; natural `orig_N03` differs from preset 1 on flags 16 and 39.
6. **New Game routing splits M01.** Idle title attract sets `$F4`; Start New Game does not.

---

## 2. What was run

| Step | Ids-or-topic | Method | Volume |
|------|----------------|--------|--------|
| FR00 | Scene-load and overlay lifecycle, kit helpers | Write/exec callbacks on `$0A00`–`0AB3`, warp to `$15`/`$24`/`$08`, inventory overlay from `orig_S01r_south-cape-ready.mss`; `gaia.flags.*` positive controls | 4 experiments + helper table |
| FR10 | Early-game route, flag setter census | `record_input` chain 25 legs, 20 079 frames (`FR10_early_game.input`); setter timeline to Edward Castle gate | 1 continuous route + standing controls |
| FR20 | South Cape, Edward Castle flags | `fr20_kit` per trial: poke flags, quick warp, 700-frame watches; states N01–N03, title S06 | 24 queue halves, scene-entry feed rows |
| FR21 | Itory, Inca Ruins, Moon Tribe, ship flags | `fr21_kit` batches `fr21_b*.py`; SIMULATED boss defeat / statue hit where noted | 25 items (23 VR, 1 contradicted, 1 inconclusive) |
| FR22 | Diamond Mine, Sky Garden, Mu, palace flags | `fr22_kit`; physical **B** sword hits on `dm3F_switch`; Mu spirit interact grid | 13 queue items with halves; 14 scenes in entry table |
| FR23 | Angel Village, Euro, Watermia flags | `fr23_kit`; Teapot tiles, glass game, Neil parents to `Die` | 21 verdict rows; 14 scenes in entry table |
| FR24 | Rolek, Angkor Wat, Pyramid, ending flags | `fr24_kit` batches; Will-form barrier hits; orb latches via poked Freedan anim | 28 VERIFIED-RUNTIME + 1 INCONCLUSIVE (epilogue stall) |
| FR30 | Engine flag domains, flag tables | `fr30_kit` + `fr30_*.py`: forced flags, world map, overlay, tomb byte, chests, radar, boss rows | ~40 observation lines; part of the lifecycle, reward and table groups |
| FR40 | All scene arrivals, draft flag scope | `fr40_kit` quick warp 228 scenes; long runs with **physical A** pulse pattern; minimal flag sets from S01r | 228-scene table; 31 flag-scope rows; 12 inconclusive scenes |
| FR50 | 19 checkpoint presets | `fr50_kit` from S01r: flags, items, form, gems; control vs forced; 20 saved `orig_P00`–`P18` states | 19 presets × (control + treatment); inventory screenshots presets 2 and 14 |

---

## 3. Findings

### 3.1 Flag lifecycle and helpers (FR00, FR30)

- **`ClearSceneState`** (`scene_lifecycle.asm`, `STX $eventFlags` offset **253291**) writes **`$0000`** to **`$0A00`–`$0A01`** once per measured warp; **`$0A02`–`$0A03`** and **`$0A80`** stay **`FFFF`** when pre-seeded. Flag **0** in scene `$15` is re-set by the scene at frame 563 after the clear.
- **Flag `$FF` (bit 7 of `$0A1F`):** cleared at 253423 (`STA $eventFlagsF8toFF`); set again by `COP SetFlagByte #FF` at 253564 — **168** frames after warp in `$15`/`$24`, **52** in `$08`. Overlay: clear 191819, set 192190 (**65** frames open + **2** after restore).
- **Inventory:** pushes/pops the scratch word; **`SetFlagByte #00`** at `inventory_menu.asm` offset **191678** is the menu cancel exit; forcing bit 0 of `$0A00` inside the overlay closes without that COP (frame 442 → scene `$01` at 444).
- **Kill block (FR30):** ordinary loads keep **`$0A80`–`$0A9F`**; **`ClearAllWramFlags`** at world-map entry (**238336**) and **`GameOverClearFlagsLoop`** on real death zero **only** that range; revive with ≥100 gems keeps it. Save/load: INCONCLUSIVE.
- **Tomb nibble (FR30):** byte **`$0A9F`** bit tests: **`$3F`** fires pyramid secret, **`$3E`/`$7F`/`$00`** do not.
- **Kit helpers** `gaia.flags.get/set/clear/dump/diff`, `gaia.flagwatch`, `gaia.execMarks`: VERIFIED-RUNTIME in FR00 controls.

### 3.2 Early-game route and prologue (FR10, FR20)

- **Continuous New Game:** no M01 **`$F4`** before **`$10`** at frame **2919** (offset **297683**); **`$16`** frame **6904**; **`$1C`** frame **15884**; **`$3F`** frame **20619** (`ec0A_left_guard.asm` offset **311322**).
- **Title idle:** **`$F4`** set frame **3481** (offset **772466**), queues scene **`$8C`**.
- **Prologue chain (FR20):** `$F4` → scenes **`$8C`–`$8F`** with visit counters **`$017C`–`$017F`**, second pass clears `$F4` and reaches title **`$FC`**.
- **Scene `$08` lesson:** with **`$10`** clear, joypad lock **`$CFF0`** at **297638**, clears after dialog; sets **`$10`**. With **`$10`** set, priest only.
- **Scene `$06` night:** **`$1C`**/`$1D`** lock **`$CFF0`**, **`WaitByte #3B`** counted **73** parity-counter (`$36`) frames from lock to **`$1D`** set (not 60 ticks).
- **`$0A01` bit 7:** only the thinker at **`8B:D03C`** reads it (10 reads, no actor).

### 3.3 Edward Castle and South Cape actors (FR20, FR21)

- **Flag `$21`:** torch spawns, guard positions, alarm thinker in **`WaitOnFlagByte #FF`** (724 polls / 700 frames), Kara escort when **`$22`** clear.
- **`ec0E_statue`:** collision **`$F0`** and push handler **with and without** `$21`; inspect pointer only when set.
- **`$E8`:** **`sEA_solid_arm`** sets at **587597** (~261 frames after lock, 1 frame before intro dialog); Gem gone in scenes **`$01 $32 $6B $7B $9B $C3`** when set.
- **Prison / roast / throne:** **`$46`** roast path without prison (barrel **`$46`**); **`$0113`**, door **`$42`**, cellar **`$22`** partly INCONCLUSIVE (no item-menu bot).

### 3.4 Itory, Inca, Moon Tribe (FR21, FR22)

- **Diamond Block:** **`UseItem_DiamondBlock`** sets **`$2F`** only at **X = `$0E`** (offsets **231800** vs **231737** failure path).
- **Castoth row:** simulated **`enemiesRemaining = 0`** sets **`$0175`** and queues **`$E0`**; helper on scene **`$29`** not observed live.
- **`ir20_statue`:** **`$B9`** on simulated sword state (**`playerFlags $0002`**), not position.
- **Mu maps:** **`$7B`/`$7E`** choose half-map drain; Statue of Hope **`$80`/`$81`** on pedestals 1/2; Erik/vampire **`$86`/`$87`** box sequence scene **`$67`**.
- **Mine collapse:** laborer counter in byte **`$0A01`**; **fourth distinct** `dm3F_switch` hit sets **`$0121`** (offset **381054**); repeated hits on one switch counted once in 1000 frames (INCONCLUSIVE half).

### 3.5 Euro, Watermia, late world (FR23, FR24)

- **`eu92_erasquez`:** Teapot held → dialog only; **no** Teapot → **`$9F`** set (**513973**).
- **Neil parents:** fall through to **`COP Die`** at **516634** / **516884** when Teapot used in tile box (**`$A8`** set).
- **Vader barriers (`$D6`):** scratch **`$0F`** scene **214** — Will **physical B** hit swaps rows (**574327**…); with **`$0F`** set, hits ignored (**574316** only). No `characterForm` test.
- **Angkor / Babel / epilogue:** extensive **`$B5`–`$D2`**, stone girls **`$BF`–`$C1`**, elevator pose scratch scene **225** — **`WaitWord #$00EF`** = **240** frames (not 239). Epilogue **`$DB`** second dialog stalls at frame **1106** under quick warp: INCONCLUSIVE.

### 3.6 Engine tables and boss bits (FR30)

- **Layer/event blocks **`$0106`**, **`$0119`**, **`$0120`**, etc.:** forced loads copy metatile strips; **`$0120`** reload nuance documented (same-scene reload keeps copy).
- **Chest indices 513, 520, 640, 641:** open once behaviours VERIFIED-RUNTIME.
- **Radar skip 780–782** and **boss presence 1280/1281:** actor swap halves verified; **`playerFlags $0020`** link to real boss kill not run.
- **Expose bit 1025:** forced **`$0A80 := $02`** removes one mudpit; **`$01`** nibble wrong in queue text.

### 3.7 Scene arrival sweep (FR40)

- **228 scenes:** **121 free**, **74 cutscene**, **33 needs-spawn-position** (default warp **(88,160)** often in wall), **0** locked-until-flag.
- **`joypadMaskStd` `$065A`:** common pattern **`$CFF0`** then **`displayModeFlags` bit `$2000`** message box; **physical A** (2 frames per 12) advances text in long runs.
- **Scene `$0A`:** **239**-frame **`$CFF0`**, free frame **278** with A; flag **`$3F`** → free arrival (mask **0**).
- **Scene `$29`:** **`$EFF0`** **171** frames, self-release; flag **1280** does not remove lock.
- **Scene `$0E`:** warp **(88,64)** → repeating **`$0F00`** locks, game over frame **197**, reload **`$20`**.
- **Flags 1280/1281:** CONTRADICTED against draft “skip intro” text.

### 3.8 Checkpoint presets (FR50)

- **14** presets VERIFIED-RUNTIME, **4** CONTRADICTED (**3** Castoth Shadow, **5** Sky Garden release, **15** Mummy Queen lock, **18** joypad + form), **11** INCONCLUSIVE (Sand Fanger zones).
- **Preset 1 vs `orig_N03`:** matches inventory except flags **16** and **39** (natural has both set).
- **Form at `$E8`:** writing **`$0AD4 = 2`** before load spawns **`shadow_shimmer`** and palette **8** diff; Freedan **1** shows no visible change at `$E8` (INCONCLUSIVE for Freedan display).

---

## 4. Shipped notes corrected

| Place | Old statement | Verdict | New statement |
|-------|---------------|---------|----------------|
| `docs/code/bank0A-dungeon-enemy-actors.md` (ec0E) | Push if `#21` clear; inspect if set | CONTRADICTED | Always push blocks; `$21` adds inspect `chatPtr` only |
| `notes/blockNotes/bank0A.json` `ec0E_statue` | Statue inspection actor / push branch | CONTRADICTED | Solid push block both states (MS04 applied) |
| `jeweler_gem.asm` block note + comment 577187 | `$E8` after Solid Arm fight | CONTRADICTED | Set before intro dialog, no fight required (MS04) |
| `item_use_system.asm` `UseItem_DiamondBlock` | Tiles `$0E`–`$0F`; Diamond Mine scene `$25` | CONTRADICTED | **X `$0E` only**; scene `$25` is Inca Ruins entryway (MS04) |
| `ir20_statue.asm` block note | Position check for `$B9` | CONTRADICTED | HP / attack-state gate, no position test (MS04) |
| `it1A_lily.asm` comment 324877 | (implicit both answers differ) | refined | Both Yes/No fall through to ruins move (MS04 comment) |
| `eu92_erasquez.asm` block note | Teapot ⇒ set `$9F` | CONTRADICTED | Inverted: **without** Teapot sets `$9F` (MS04) |
| `eu95_neils_father/mother` block notes | (spawn death timing) | refined | Fall through to `Die` at sequence end (MS04) |
| `pyD6_vader_barrier_*.asm` block notes | Shadow form gate | CONTRADICTED | No form test; Will sword hit drives barrier (MS04) |
| `db-us/scene-flags.json` scene 10 | Guard lock “stays nonzero” | CONTRADICTED | Timed lock + box; release at frame 278 with A; flag `$3F` frees |
| `docs/code/bank07-watermia-euro-actors.md:241` | Erasquez Teapot test | CONTRADICTED | Same inversion as registry fix (not in MS04 merge) |

Draft-only fixes (flag-analysis drafts, not merged in MS04): preset notes (Castoth Shadow, Sky Garden release, Mummy Queen, Dark Gaia joypad); scene-flag rows for flags 1280/1281; many Itory, Diamond Mine, Sky Garden and Mu note drafts are superseded or pending.

---

## 5. Rules for patch authors

1. **Treat flags `$0000`–`$000F` as scene scratch.** They zero on every `ClearSceneState` and the inventory overlay temporarily clears them; do not store cross-scene progress there without save semantics.
2. **Persist kill-state in `$0A80`–`$0A9F` across room reloads**, but clear expectations when the player opens the world map or dies without enough gems; do not assume a warp clears kill bits.
3. **Respect the flag `$FF` latch.** Scene setup clears bit 7 of `$0A1F` until the script sets `$FF` again; thinkers such as the Edward alarm park on `WaitOnFlagByte #FF`.
4. **Do not gate Edward Castle statue collision on flag `$21`.** Patch only dialogue/interaction when mirroring shipped behaviour.
5. **Place the Diamond Block only on tile column `$0E`** in the Inca Ruins entryway (scene `$25`); other columns show failure text and do not set `$2F`.
6. **When documenting Erasquez, invert the Teapot test:** holding the Teapot blocks the `$9F` set; the hint path runs without it.
7. **Vader corridor barriers respond to combat hits in Will form (the attack button, physical B on ROM O),** not to `characterForm` alone; Shadow-form-only patches will not match the ROM.
8. **Model scene `$0A` arrival as timed lock + dialog,** not permanent lock until flag `$3F`; flag `$3F` skips the guard lock entirely.
9. **Boss reward flags 1280 and 1281 remove boss actors in presets but do not shorten intro joypad timers** on scenes `$29` and `$55`.
10. **Checkpoint presets omit flags 16 and 39 on “after castle letter”** and mis-state Shadow/joypad on presets 3, 5, 15, and 18; use natural saves or fix presets before trusting form or mask at bosses.
11. **On ROM O in harness-style tests, pulse physical A to advance arrival message boxes and use physical B (`$8000`) for sword strikes** such as the mine switches and the Vader barriers. Name the ROM build when documenting button masks: in this baserom build physical A feeds `$8080` and physical B `$4008`.

---

## 6. Where the findings live in the docs

| Topic | Document |
|-------|----------|
| Event flag array, scratch, kill block, save span | [`wram-memory-map.md`](wram-memory-map.md) §2.7 Event & WRAM Flags |
| Registry overview, domains D1–D7, CLI | [`flags/README.md`](flags/README.md), [`flags/_intro.md`](flags/_intro.md), [`flags/system.md`](flags/system.md) |
| Per-area flag meanings and FR evidence lines | [`flags/edward_castle.md`](flags/edward_castle.md) (`$21`, ec0E), [`flags/incan_ruins.md`](flags/incan_ruins.md), [`flags/euro.md`](flags/euro.md), [`flags/pyramid.md`](flags/pyramid.md), other [`flags/*.md`](flags/) pages from `npm run flags -- docs` |
| Scene load / `ClearSceneState` | [`code/bank02/scene-script.md`](code/bank02/scene-script.md), [`code/bank02/game-systems.md`](code/bank02/game-systems.md), [`code/bank02/utility-functions.md`](code/bank02/utility-functions.md) |
| Inventory overlay flag save/restore | [`code/bank02/inventory-overlay.md`](code/bank02/inventory-overlay.md) |
| `playerFlags` masks (combat lock, script lock) | [`wram-memory-map.md`](wram-memory-map.md) Player Flags Reference |
| Castle dungeon actors (`ec0E` statues) | [`code/bank0A-dungeon-enemy-actors.md`](code/bank0A-dungeon-enemy-actors.md) |
| Euro actors (Erasquez Teapot) | [`code/bank07-watermia-euro-actors.md`](code/bank07-watermia-euro-actors.md) |

Live data: `db-us/flags.json`, `db-us/scene-flags.json`, `db-us/flag-presets.json` (grades and scene 10 entry as re-checked in the registry apply). Generated pages under `docs/flags/` mirror the registry.

---

## 7. Tools, states and files

All under `plans/extracted-audit/mesen2-results/` unless noted.

| Kind | Files |
|------|-------|
| Lua kit (`kit/lib/`) | `gaia_kit.lua` (flags, watches, exec marks), `fr10_kit.lua`, `fr10_steps.lua`, `fr20_kit.lua` … `fr50_kit.lua` (chain includes prior kits) |
| Python harness (`harness/`) | `flag_census.py` (FR00), `fr10.py`, `fr20_lib.py` + `fr21_b*.py` … `fr24_b*.py`, `fr30_*.py`, `mcp_client.py` (FR40/50 server) |
| Draft specs (`specs/`) | `FR00_flag_verdicts.json`, `FR10_flag_verdicts.json`, `FR20_notes.json`, `FR21_notes.json`, `FR23_notes.json`, `FR24_notes.json`, `FR40_scene-flags.json`, `FR40_flag_verdicts.json`, `FR50_presets_verdicts.json`, per-session `FR*_flag_verdicts.json` |
| Save states (`rebuilt/states/`) | `orig_S01r_south-cape-ready.mss` (FR00, FR40, FR50), `orig_N01`–`N03`, `orig_S06_title`, `orig_P00`–`P18`, natural milestone states referenced in reports |
| Raw output (`raw/`) | `FR00_*_20261104.json`, `FR10_chain_sigs.json`, `FR10_early_game.input`, per-trial `FR20_FL*` / `FR21_*` / … JSON and screenshots (`FR50_inv_p*.png`) |
| Reports | `FR00_20261104.md` … `FR50_20261106.md`, `closures.md` (21 FR rows), `MS04_apply.md`, `plans/flags/results/CO09_flag_apply.md`, `plans/flags/results/apply/APPLY_20261111.md` |

---

## 8. Tool and method lessons

- **Script `emu.write` / MCP `write_memory` do not fire memory callbacks** (FR00); use exec marks or read-back for script pokes. Callback PCs point **after** the store instruction; subtract instruction length to name the writer.
- **Quick warp vs natural entry:** FR40 measures quick warp from S01r; twelve scenes need story presets (FR50) before flag-gated arrivals can be discriminated.
- **Message-box direction test:** FR40 long runs avoid held directions during “A pulse” patterns because the movement probe can dismiss dialog.
- **`load_state_file` + immediate `take_screenshot` can be black** (FR10 T-43); advance a frame before capture.
- **`record_input` records MCP input only**; FR10 replays Lua-generated legs through `play_input`, with `1:-` pad frames to keep `$36` aligned.
- **SIMULATED pokes** (boss HP, statue hit, vampire counts) prove setter logic but do not upgrade real combat paths; keep grade SIMULATED or qualify findings.
- **Flag kit positive controls** (`gaia.flagwatch`, warp all-`FF` / control pokes) back every “only one writer in window” claim in FR00.
- **Preset replay:** writing form word `$0AD4` before load is enough for Shadow shimmer at `$E8`; jewel/gem words matched natural only at preset 1 in the samples taken.
- **Registry apply:** `npm run flags` consumes fragments once; dry-run `+0 ~0 =N` means already applied. Flag note merge specs from the flag-analysis rows are mostly superseded by wait-notation fixes—do not blindly re-merge the old flag note JSON.

---

## 9. Open questions

Deduped from FR reports and `open-questions.md` (NQ ids for tracking only):

1. NQ-105: Do natural door exits use the same single `STX $eventFlags` path, and is there a load path that skips it?
2. NQ-106: Why does `ClearSceneState` take 168 frames to set `$FF` in some scenes but 52 in `$08`?
3. NQ-107 / OQ-I036-5: Do palette/HDMA thinkers gated on `$FF` replay after inventory open/close?
4. NQ-108: Which route sets optional flag `$20` (`sc_cave_friends_idle`)?
5. NQ-109: Does Start New Game ever set `$F4`, or is M01 idle-only?
6. NQ-110–NQ-112: Prologue `$8C`–`$8F` flags, castle interior M05 flags, and the 261 never-written bits on later routes.
7. NQ-113–NQ-118: Item-menu button on vanilla O; `WaitByte #3B` = 73 `$36` frames; cellar helper press; thinker WRAM list; idle sprite family reader; scene `$0B` tile `(14,17)`.
8. NQ-119–NQ-122: Real sword hit setting `playerFlags $0002`; Diamond Block warp to `$2A`; Castoth `$011F` writer.
9. NQ-123–NQ-127: Mu interact strike target; mine switch hit counting; scene `$58` scratch clear; idle sprite reader; real vampire kills vs poke.
10. NQ-128–NQ-132: `fireplace_journal` spawn; moving pad gate; Euro actor diff names; glass direction; reload with `$A8`.
11. NQ-133–NQ-137: Freedan orb action; other forms on Vader barriers; epilogue `$E5` stall; flight to `$DC`; Angkor fade screenshot.
12. NQ-138–NQ-142: Same-scene reload layer copy; flag chest collision owner; real Castoth `$0020`; scene `$65` BG2; overlay `$FF` restore.
13. NQ-143–NQ-150 / RQ-2: Natural-door arrival survey for boss locks, death arrivals, Sky Garden `$0800`, warp row `warp_def_29`, preset gaps for twelve FR40 scenes, exporter `spawn` field.
14. NQ-151–NQ-155: Flags 16/39 before castle; Sand Fanger zone path; preset 2–18 vs natural flag lists; jewel/equip words; Shadow palette timing vs natural.
15. NQ-253 / RQ-1: `WaitByte #3B` measured 73 parity frames — reconcile with operand +1 tick rule.

---

## 10. Apply log

| Item | Result |
|------|--------|
| MS04 merge (`edits/MS04.json`) | **FR20:** `ec0E_statue.asm`, `jeweler_gem.asm` block notes **APPLIED**. **FR21:** `UseItem_DiamondBlock`, `ir20_statue`, `it1A_lily` comment **APPLIED**. **FR23:** `eu92_erasquez`, `eu95_neils_father/mother` **APPLIED**. **FR24:** `pyD6_vader_barrier_upper/lower` **APPLIED**. Gate after MS04: checksum **222965960**, ROM unchanged. |
| MS04 skipped | **FR00, FR10, FR22, FR30, FR40, FR50** registry/scene-flag/preset JSON → `npm run flags` (outside merge/names). **FR22** wrong notes only in unapplied FL10/FL24/FL25 drafts. |
| Flag registry **APPLY_20261111** + **CO09** (2026-11-12) | **31** registry fragments + **9** FRV files re-verified **+0 ~0**; **687** indices, **916** meanings, **228** scenes, **19** presets; `docs/flags/` regenerated byte-identical. **0** surviving `FL*_notes.json` rows to merge (wait-notation supersession). Gate: checksum **222966885**, sha1 `c5c17400…`. **0** ROM bytes changed in CO09. |
| `db-us/scene-flags.json` scene `$0A` | FR40 `expectOld` spec **not** applied in MS04; live entry class **cutscene**, flag **63** per CO09 (contradiction handled in registry apply). |
| Closures | **21** dated rows name FR00–FR50 in `closures.md` (2026-11-04 through 2026-11-06; FR40/50 rows 2026-11-06). |
| Docs | This summary; generated `docs/flags/*`; `wram-memory-map.md` event-flag paragraph includes FR00/FR30 kill-block measurements. The later documentation pass corrected the `ec0E` lines of `bank0A-dungeon-enemy-actors.md` and found `bank07-watermia-euro-actors.md:241` already correct (`CO12_docs.md`). |
| Names | No FR-driven renames in MS04. `FL30_names.json` retired; idle **Flagged** names live in `names/bank02.json` (CO09). |

See `plans/extracted-audit/mesen2-results/MS04_apply.md` and `plans/flags/results/CO09_flag_apply.md` for procedure detail and open CO09 items (preset 1 note patch, flag 16 on presets 2–18, evidence pointer typos).
