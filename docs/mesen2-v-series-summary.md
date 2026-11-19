# Mesen2 V series: plan claim cross-check (V1)

Cross-check of twelve plan claims about waits, combat flags, display requests, joypad vocabulary, jeweler rewards, game-over revive, hit stagger, Mode 7 map rendering, stat overflow, and the `$06F2` music-id word. Step V1 re-measures the wait tick rule and the depth-sort hide bit, closes the Mode 7 transparency half left open after E3, and cites earlier Mesen2 sessions for the rest. Compiled 2026-11-12 from `plans/extracted-audit/mesen2-results/V1_20261110.md`, closure rows dated 2026-11-10 in `closures.md`, and apply log `MS04_apply.md`.

ROM: O (vanilla, SHA-1 `38de0c84dd2bc3bdfc0a3d7ab0220c79b70887c3`, 2,097,152 bytes, CRC-32 `1c3848c0`, path `rebuilt/Illusion of Gaia.smc`) for every run in this step. Server: Mesen2 MCP 0.6.0 (`user-mesen2-mcp-dev`). Nine of the twelve claims rely only on cited host results (E3, G1–G3, A3, C4, D1, M3, N1–N2, P1); V1 adds fresh runtime for door and palette waits, depth-sort hide bit `$2000`, title wait wall time, and Mode 7 outside-plane colour.

Sections: 1 Result in one page, 2 What was run, 3 Findings, 4 Shipped notes corrected, 5 Rules for patch authors, 6 Where the findings live in the docs, 7 Tools, states and files, 8 Tool and method lessons, 9 Open questions, 10 Apply log.

---

## 1. Result in one page

| Topic | Question | Verdict |
|-------|----------|---------|
| Door and palette wait ticks | Does `WaitByte #n` (and palette strip seeds) resume after **n + 1** passes of the owning actor or thinker runner? | **Yes.** Door `WaitWhileOffscreen #0A`: **11** passes and **11** NMI frames per interval (170 intervals, five South Cape slots). Palette HDMA seeds: **w + 1** passes for every measured strip (**127** intervals, **0** exceptions). VERIFIED-RUNTIME. |
| Title intro seconds | Is `WaitByte #B3` on the title "about 3 seconds" of wall time? | **No.** **180** runner passes but **313** `$36` frames (~5.2 s at 60 Hz) because a **135**-frame `ScreenEnterTransition` fade runs with no runner pass while the wait is armed. `WaitByte #77`: **120** passes = **120** frames. CONTRADICTED (shipped "~3 sec"). |
| iframe freeze and recovery | Do positive and negative `iframeCounter` values freeze and recover movement as documented? | **Yes.** Victim **+17** / **60** (player); recovery **−12** / **−17** / **−30** (player). VERIFIED-RUNTIME (cited G1, G3). |
| Hittable bit on `$10` | Does actor `$10` bit `$0200` block damage while set? | **Yes.** HP stays **8** with the bit forced; clears to **0** when removed. VERIFIED-RUNTIME (cited A3). |
| Depth-sort hide bit | Does `$10` bit `$2000` drop an actor from `SortActorsByDepth` buffer stores? | **Yes.** Combat bat slot `$1060`: **40** stores per **40** frames before the bit, **0** after; Will stays **40**/**40**. Reader at ROM **247377**–**247380**. VERIFIED-RUNTIME. |
| Display mode flag bits | Are HUD-off bit **14**, full BG3 request bit **0**, and partial bits **4**/**5** as in the C4 campaign? | **Yes** (cited C4). Bit **5** has no setter. VERIFIED-RUNTIME. |
| Button vocabulary | Does physical A feed interact on `$0080` only? | **No** in this baserom: physical **A** → logical **`$8080`** (interact **`$8000`**, attack **`$0080`**); physical **B** → **`$4008`** (cancel **`$4000`**, item use **`$0008`**). Raw JOY1: B **`$8000`**, Y **`$4000`**, Select **`$2000`**, Start **`$1000`**. Plan wording CONTRADICTED; notes fixed via P1. |
| Jeweler Strength page | Does the page that says "Your Strength is raised by one." raise Strength? | **Text says Strength; code raises max HP** (`$0ACA` **8→9**, `$0B22` heal **0→1**). Second-page wording holds. VERIFIED-RUNTIME (cited N1). |
| Revive cost | Does revive cost exactly **100** gems? | **Yes** (150→50, 100→0); **0** gems → no revive. **99** gems not run (`>= 100` test is static). VERIFIED-RUNTIME (cited N2). |
| Hit stagger length | Is player hit stagger "about 17" controller ticks? | **Yes:** **16** ticks after the hit tick (**17** counting the hit frame); **60** without a stagger child. VERIFIED-RUNTIME (cited G3). |
| Mode 7 repeat | Is `M7SEL` **`$80`** (no repeat) on the world map? | **Yes**, written once and held (cited E3). VERIFIED-RUNTIME. |
| Mode 7 transparency | Outside the plane, is `$80` transparent (not tile-0 fill)? | **Yes.** Tile **0** chardata forced to palette colour **1** (white): **`$80`** → black backdrop band; **`$C0`** → white tile-0 fill band. VERIFIED-RUNTIME. |
| Stat-up overflow | Does signed overflow reset stats to **`$55`**? | **Yes:** STR **`$7E→$7F→$55`**, **`$FF→$00`**; DEF **`$7F→$55`**. Max-HP display clamp **`$28`** hides the HP **`$7F`** case in play. VERIFIED-RUNTIME (cited G2). |
| `$06F2` music id | What does `$06F2` hold? | **BGM id from `SpcMusicLoadCmd`**, not an actor slot (**8**/**8** stores = music record operand). VERIFIED-RUNTIME (cited D1). |
| `$06F2` not "now playing" | Is it always the track in use? | **No.** Writers: scene script, `pyCD_jackal` **`$0F`**, Memory Melody **`$0E`**; `StartMusic` / `FadeThenStartMusic` never update it. CONTRADICTED (shipped "current music index", corrected in MS03). |

Counts: **12** claims graded; **VERIFIED-RUNTIME 12** row grades (some claims split across two rows), **CONTRADICTED 3** (title seconds, plan button bit, `$06F2` "current music" — the last applied in MS03). **INCONCLUSIVE 0** in V1. The campaign changed **0 ROM bytes** in V1; MS04 changed notes only.

What changed in what we believe:

1. **A wait operand counts runner passes, not wall seconds.** `WaitByte #n` resumes after **n + 1** `DEC $08` steps in the owning slot; blocking calls inside the same main-loop pass (title fade **135** frames) stretch NMI time without extra passes.
2. **Interact is `$8000`, attack is `$0080`; physical A sets both** in the shipped remap table (`remapA = $8080`), not interact-alone on `$0080`.
3. **Mode 7 `$80` outside the map is backdrop transparency**, confirmed visually once tile **0** is non-black; E3's repeat/no-repeat half was already runtime, transparency was not.
4. **Depth-sort hide (`$10` `$2000`) is measured on a live enemy**, not only on Will in A3.
5. **Jeweler "Strength" is a dialog label over a max-HP reward**, consistent with the first-page "Life Power" wording.

---

## 2. What was run

| Step | Ids-or-topic | Method | Volume |
|------|----------------|--------|--------|
| V1 | Door/palette waits | Exec callbacks on wait re-entry (`town_door.asm` **50695**), palette seeds (**37829**, **254211**), all **14** `DEC $08` sites; `$36` and NMI entry counters; state `orig_S01r_south-cape-ready.mss` (scene `$01`) | Runs **A**/**B**, **390** frames each |
| V1 | Title waits and fade | Cold boot `fromReset: "power"`; marks at **772446** (`#B3`), **772454** (`#77`), **772457**; `ScreenEnterTransition` entry **253074** (run **C2**) | Run **C** **1400** frames, **C2** **600** frames |
| V1 | Depth-sort hide bit | Exec count on sort entry store **247420**; force `$2000` on bat slot `$1060`; state `orig_S10_combat-room-will.mss` (scene `$0C`) | Run **D**, **80** frames |
| V1 | Mode 7 transparency | `e3shot` on world map `orig_S08_world-map.mss`; poke VRAM tile **0** from frame **250**; `M7SEL` **`$80`** vs **`$C0`**; screenshots | Run **E** ×2, **291** frames |
| V1 | Nine cited claims | No emulator session in V1; verdicts taken from E3, G1–G3, A3, C4, D1, M3, N1–N2, P1 as quoted in the report | Static citation only |

All scripts use `run_script` with `includes ["mesen_kit","iog_kit","gaia_kit"]` (run **E** adds `"e3_kit","e3_shot"`), `turbo: true`.

---

## 3. Findings

### 3.1 Door and palette wait ticks

- Shared wait tail `cop_handlers_wait.asm` stores the operand in `$08` (`STA $08`, ROM **44233**); **14** `DEC $08` sites (**10** in `actor_execution.asm` **248615**–**249260**, **4** in `thinker_execution.asm` **250176**–**250328**). Plan rule: `WaitByte #n` = **n + 1** ticks (operand plus one runner pass).
- **Door (run A):** `COP [WaitWhileOffscreen] ( #0A )` at **50695**; five slots **`$1090`–`$1150`**, **34** intervals each, all **`p11/f11`**; **389** NMI frames = **389** `$36` writes.
- **Palette (run B):** **129** seeds, **127** intervals at site **254211** (`hdma_dma_spc.asm` **254211**, `cop_handlers_palette.asm` **37829**); strips with **w = 2, 3, 4, 11** → passes **3, 4, 5, 12** and matching frame deltas; **`nbad 0`**.
- **World map (cited M3):** `WaitByte #0F` → **16** ticks; `#3B` → **60** ticks — same **n + 1** pass rule when the main loop is not blocked.

### 3.2 Title intro seconds

- `sFC_title_intro.asm`: `WaitByte #B3` at **772446**, string at **772449**, `WaitByte #77` at **772454**.
- Run **C** marks (slot **`$1000`**): **B3** at **f36 = 272**, **passes = 243**; after **B3** resume at **f36 = 585**, **passes = 423** (**+180** passes, **+313** frames). Gap **272..407** (**135** frames) with no pass — same frame as **B3** call (**f36 = 272**).
- Run **C2:** `ScreenEnterTransition` entry at **f36 = 2** and **137** with `$064B = 0`, then **f36 = 272** with `$064B = 8` on the **B3** wait call. Static: type **0** fade is **15** steps × (`$064B` + 1) inner `UpdateFrameDialogue` calls = **15 × 9 = 135** frames with **no** runner pass (ROM **253074**–**253652**).
- `WaitByte #77`: mark and resume both at **f36 = 585** / **705** → **+120** passes and **+120** frames (no blocking loop in between). Shipped "~3 sec" for **B3** is wrong; **~2 sec** for **#77** remains fair in NMI frames.

### 3.3 iframe freeze and recovery

- Cited **G1** / **G3:** positive `iframeCounter` on a victim freezes script **+17** frames (non-player) or **60** (player); negative values recover on **−12** / **−17** (victim) or **−30** (player). Player sign behaviour matches `combat_collision.asm` usage. VERIFIED-RUNTIME.

### 3.4 Hittable bit

- Cited **A3:** forcing actor `$10` bit **`$0200`** leaves player HP at **8**; clearing allows damage to **0**. VERIFIED-RUNTIME.

### 3.5 Depth-sort hide bit

- `sprite_composition.asm` **247375**–**247380**: `BIT #$2000` / `BNE` skips buffer build; entry store at **247420**.
- Run **D:** target bat slot **`$1060`** (**4192**), `flagBefore 0000`, `flagAfter 2000`; phase **1** sort stores **`1000=40`**, **`1060=40`**; phase **2** with bit set **`1000=40`**, **`1060=0`** over **40** frames. Player slot **`$1000`** control unchanged.

### 3.6 Display mode bits

- Cited **C4:** bit **14** (`$4000`) = HUD off (`UpdateHUD`, `LoadHudTilemap`); bit **0** = one full BG3 upload (**`$0800`** bytes **`$7F:0200` → VRAM `$7800`**); bits **4** and **5** = same partial upload (**`$0140`** bytes → **`$7840`**); no instruction sets bit **5**. VERIFIED-RUNTIME.

### 3.7 Button vocabulary

- Cited **P1** (this baserom build, R-plain): after remap, physical **A** ORs **`$8080`** into `joypadCurrent`, physical **B** ORs **`$4008`**. Interact tests use **`$8000`**; attack uses **`$0080`**. Plan row "A feeds **`$0080`** interact" is wrong. Shipped notes corrected in MS04 via `P1_notes.json`, not V1.

### 3.8 Jeweler Strength page

- Cited **N1:** at **8** jewels, first page text "Life Power", max HP **`$0ACA`** **8→9**, heal word **`$0B22`** **0→1**; second page "Your Strength is raised by one." with **no** change to STR/DEF words — code still awards max HP. VERIFIED-RUNTIME.

### 3.9 Revive cost

- Cited **N2:** revive spends exactly **100** gems (**150→50**, **100→0**); at **0** gems no revive path. **`>= 100`** threshold not exercised at **99**. VERIFIED-RUNTIME.

### 3.10 Hit stagger length

- Cited **G3:** with stagger child, **16** controller ticks after the hit (**17** including hit frame); without child, **60**. Matches `hit_stagger_controller.asm` / `ApplyPlayerHitstun.asm` notes. VERIFIED-RUNTIME.

### 3.11 Mode 7 repeat and transparency

- Cited **E3:** world map sets `M7SEL = $80` once (frame **161** in that session) — no plane repeat. `mode7_perspective.asm` **48**, **81** agree.
- Run **E** (scene `$FE`, rotation `$BC = $0100` per E3): from frame **250**, tile **0** VRAM high bytes set to palette index **1** (`CG = $7FFF`). **`M7SEL $80`:** backdrop black beyond plane (`fill0 false`); **`$C0`:** white band (`fill0 true`). Screenshots `V1_cl10_m7sel80_tile0white_689.png` / `V1_cl10_m7selC0_tile0white_689.png`. Poke must occur after map upload (first attempt at frame **5** was overwritten).

### 3.12 Stat-up overflow

- Cited **G2:** overflow routes through **`$55`** reset, not cap — STR **`$7E→$7F→$55`**, **`$FF→$00`**; DEF **`$7F→$55`**. Max HP item clamps display to **`$28`** before apply, so HP **`$7F`** reset is unreachable in normal play. VERIFIED-RUNTIME.

### 3.13 `$06F2` music id

- Cited **D1:** `SpcMusicLoadCmd` at pc **166771** stores music record operand **1** into **`$06F2`** (**8**/**8** scene loads). Also written by `pyCD_jackal` (**`$0F`**) and Memory Melody item (**`$0E`**). `StartMusic` / `FadeThenStartMusic` never write it. Shipped "scene's current music index" on `music_actors.asm` was CONTRADICTED; MS03 merge applied. WRAM mnemonic `musicParentActor` is a misnomer (not renamed in V1).

---

## 4. Shipped notes corrected

| Place | Old statement | Verdict | New statement |
|-------|---------------|---------|---------------|
| `sFC_title_intro.asm` block note (`notes/blockNotes/bank0B.json`) | `WaitByte #B3` ≈ **3 seconds** wall time | CONTRADICTED | **180** runner passes, **313** NMI frames (~**5.2** s) because **135** fade frames run inside one main-loop pass |
| Comment **772446** (`notes/comments/bank0B.json`) | `WaitByte #B3` = 180 ticks (**~3 sec**) | CONTRADICTED | **180** ticks; wall time **313** NMI frames when the title enter fade runs during the wait |
| `music_actors.asm` (`$06F2` "current music index") | (from D1, not V1 merge) | CONTRADICTED | BGM id stored by the scene `music` record; scripted music does not update it — MS03 |
| Plan button vocabulary (not extracted) | "A feeds **`$0080`** interact" | CONTRADICTED | Interact **`$8000`**, attack **`$0080`**; physical **A** feeds **`$8080`** in this build — P1 notes |

Other claims left shipped text unchanged in V1 (door **11** ticks, palette extra ticks, Mode 7 "no repeat, no tile-0 fill", stagger/hit notes, jeweler asm comments).

---

## 5. Rules for patch authors

1. **Treat `WaitByte #n` and palette wait seeds as n + 1 runner passes**, counted at the **14** `DEC $08` sites, not as guaranteed NMI frames.
2. **Do not convert wait operands to seconds without checking for blocking main-loop work** (`ScreenEnterTransition` cost **135** NMI frames on the title with `$064B = 8`).
3. **Use actor `$10` bit `$2000` to keep an actor out of the depth-sort buffer**; stores at ROM **247420** stop while the bit is set.
4. **Setting actor `$10` bit `$0200` on the player blocks damage until the bit is cleared** (HP stays 8 with the bit forced).
5. **Request HUD and BG3 work through `displayModeFlags` as in the [C series summary](mesen2-c-series-summary.md)** — bit **14** HUD off, bit **0** full BG3, bit **4** partial rows; bit **5** has no setter.
6. **Document joypad masks with logical bits and physical buttons for the build** — this baserom: physical **A** → **`$8080`**, physical **B** → **`$4008`**; interact **`$8000`**, cancel **`$4000`**, attack **`$0080`**, item **`$0008`**.
7. **Do not assume the jeweler Strength dialog increases STR** — the reward path raises max HP (`$0ACA`).
8. **Revive costs exactly 100 gems** (150→50, 100→0); with 0 gems there is no revive. 99 gems was not run.
9. **Budget the player's hit stagger as 16 controller ticks after the hit tick** (17 counting the hit frame) when a stagger child exists; without one the stun lasts 60.
10. **Keep world-map `M7SEL` at `$80` for backdrop transparency outside the plane** — `$C0` would show tile **0** fill colour.
11. **Expect stat item overflow to land on `$55`**, not clamp at `$7F`, when testing extreme values (HP display clamp may hide one case).
12. **Read `$06F2` only as the scene-record BGM id or fanfare-restore snapshot**, not as "now playing" after `StartMusic`.

---

## 6. Where the findings live in the docs

| Topic | Document |
|-------|----------|
| `WaitByte` / `WaitWhileOffscreen`, tick rule | [`cop-commands-reference.md`](cop-commands-reference.md) (`$DA` / `$27`) |
| Title orchestrator, wait comments | [`code/bank0B-late-bosses-system-cutscene-actors.md`](code/bank0B-late-bosses-system-cutscene-actors.md) (`sFC_title_intro`) |
| Enter transition timing | [`code/bank03/scene-and-hardware.md`](code/bank03/scene-and-hardware.md) (`ScreenEnterTransition`) |
| Actor `$10` flags, hide bit | [`wram-memory-map.md`](wram-memory-map.md#actor-flag-bits-flags10--flags12-verified-with-mesen2) |
| iframe counter, hit-stun gate | [`wram-memory-map.md`](wram-memory-map.md) (`$7F:0028` iframe row), [`code/bank02/player-character.md`](code/bank02/player-character.md) (hit-stun gate) |
| Hit stagger frames | [`code/bank00/actors-combat-interaction.md`](code/bank00/actors-combat-interaction.md) (`HitStaggerMain`) |
| `displayModeFlags` bit table | [`wram-memory-map.md`](wram-memory-map.md#display-mode-flags-reference-09ec) |
| Joypad remap, logical bits | [`wram-memory-map.md`](wram-memory-map.md#29-input-remapping-0da00dc0) (§2.9) |
| Jeweler rewards | [`code/bank08-native-dao-pyramid-actors.md`](code/bank08-native-dao-pyramid-actors.md) (`jeweler_gem`) |
| Revive vs game over | [`code/bank00/functions-game-over.md`](code/bank00/functions-game-over.md) (`GameOverChooseRespawn`) |
| Mode 7 `M7SEL` | [`code/bank03/mode7-and-cutscenes.md`](code/bank03/mode7-and-cutscenes.md) (`Mode7PerspectiveInit`) |
| Stat overflow `$55` | [`code/bank00/actors-combat-interaction.md`](code/bank00/actors-combat-interaction.md) (reward actors) |
| `$06F2` / scene music | [`wram-memory-map.md`](wram-memory-map.md) (`$06F2` row), [`code/bank02/spc-transfer.md`](code/bank02/spc-transfer.md), [`mesen2-d-series-summary.md`](mesen2-d-series-summary.md) |

---

## 7. Tools, states and files

Under `plans/extracted-audit/mesen2-results/` unless noted.

| Kind | Files |
|------|-------|
| Report | `V1_20261110.md` |
| Draft notes | `specs/V1_notes.json` (merged in `edits/MS04.json` with M2/R3 title rows) |
| Save states (`rebuilt/states/`, `states-index.md`) | `orig_S01r_south-cape-ready.mss` (A, B), `orig_S10_combat-room-will.mss` (D), `orig_S08_world-map.mss` (E); `orig_N02_wills_house_after_feast.mss` (discarded depth-sort attempt) |
| Screenshots | `raw/screenshots/V1_cl10_m7sel80_tile0white_689.png`, `V1_cl10_m7selC0_tile0white_689.png` |
| Apply / closures | `MS04_apply.md` (M2+V1 title timing); closure rows **196**–**200** in `closures.md` |
| Harness | Inline Lua in the report (`V1_cl01_door`, `V1_cl01_pal`, `V1_cl01_title`, `V1_cl01_title_fade`, `V1_cl04`, `V1_cl10`); kits `mesen_kit`, `iog_kit`, `gaia_kit`, `e3_kit` / `e3_shot` on run E |

---

## 8. Tool and method lessons

- **A "tick" in wait measurements is one `DEC $08` in the owning slot (D = slot id)**, not one emulator frame; pair pass counts with `$36` writes when quoting seconds.
- **Palette thinkers need all four thinker `DEC $08` sites** — an earlier palette run that counted only actor sites saw zero thinker passes.
- **Title boot needs long frame budgets** — **1400** emulator frames yielded **1139** NMI frames because scene loads run with the NMI off; use `$36`, not raw frame count, for wait deltas.
- **`ScreenEnterTransition` can run entirely inside one main-loop invocation** — **135** consecutive frames with no pass on the waiting title slot.
- **Depth-sort hide tests need a non-player in the render list** — South Cape and Will's house states had only Will visible; combat room bat slot `$1060` worked.
- **Mode 7 VRAM pokes belong after the scene's map upload** — an early poke at frame **5** was cleared; frame **250** readback stuck.
- **`merge` on line-tracked comments uses `expect`, not `expectOld`** — `gaia-core/docs/notes-and-comments.md` wording disagrees with this baserom (see V1 tool note).
- **Positive control:** every run matched `$36` writes to NMI entries within one frame of script start.

---

## 9. Open questions

1. FR20 measured `WaitByte #3B` at **73** `$36` frames, not **60** — same class as the title fade (blocking call with no runner pass)? (NQ-253 → RQ-1.)
2. Which blocking main-loop calls run with **no** actor or thinker pass besides `ScreenEnterTransition`? (NQ-254 → RQ-1.)
3. Do `ScreenEnterTransition` types **1**–**3** (instant, mosaic, wave) stall runners the same way, and which scenes use which type? (NQ-255.)
4. Does anything read `$06F2` besides chest/item fanfare restore paths? Should WRAM mnemonic `musicParentActor` be renamed outside `npm run names`? (NQ-256.)
5. Plan and hard-rule button vocabulary still said interact = `$0080` until the static pass — corrected in SA-30 / doc sweep, not in extracted asm. (NQ-257.)
6. **2-frame mismatch** on title `WaitByte #B3`: **180** passes but **178** NMI frames after subtracting the **135**-frame gap — pass count exact, frame delta may desync from `$36` marks. (V1 report.)

---

## 10. Apply log

| Item | Result |
|------|--------|
| Spec | `specs/V1_notes.json` — block note `sFC_title_intro` + comment **{772446}**; dry-run OK (**2** notes files). Supersedes overlapping **{772446}** draft from M2 in `MS04.json`. |
| Merge step | **MS04** (2026-11-10): `sFC_title_intro.asm:7` and comment **772446** — `WaitByte #B3` = **180** ticks, **313** NMI frames incl. fade (**M2**, **V1**, **R3** row). **0** ROM byte change (gate sha1 `90a04067dd5b5284bd9e152ad222df0e65d08979`). |
| Closures | **5** rows (**CL-01** ticks, **CL-01** seconds, **CL-10** transparent, **CL-06**, **CL-12** current music) in `closures.md`; **CL-01** seconds row supersedes M2 "313 ticks" wording |
| Not from V1 merge | **CL-12** current music → MS03; **CL-06** → `P1_notes.json` in MS04; display-mode and most wait-aligned notes unchanged |
| Names | none (V1); `musicParentActor` mnemonic gap noted |
| Docs | this summary |

See `plans/extracted-audit/mesen2-results/MS04_apply.md` for the full MS04 result table.
