# Mesen2 E series: display, HDMA, Mode 7 and palette findings (E1 to E4)

Runtime and static investigation of the US ROM display path: scene display presets and fixed-colour math, palette bundles and backdrop ramps, Mode 7 perspective and the world-map split, HDMA channel allocation, circle windows, parallax band thinkers, and VRAM source-cache invalidation. Compiled 2026-11-12 from `plans/extracted-audit/mesen2-results/E1_20261031.md`, `E2_20261106.md`, `E3_20261108.md`, `E4_20261108.md`, apply logs `MS04_apply.md` and `MS05_apply.md`, and matching rows in `closures.md`.

ROM: O (vanilla, SHA-1 `38de0c84dd2bc3bdfc0a3d7ab0220c79b70887c3`, file size 2,097,152) for every run. Server: Mesen2 MCP `mesen2-csharp-mcp` 0.6.0 on E2, E3 and E4; E1 does not record a server version in its report. All four steps are emulator-backed; E2 additionally decodes all 128 palette bundles statically before the scene sweep. Rebuilt ROM R was not run in this series; MS04 and MS05 changed notes (and one MS04 names entry) only, with no ROM byte change at the MS04 gate.

Sections: 1 Result in one page, 2 What was run, 3 Findings, 4 Shipped notes corrected, 5 Rules for patch authors, 6 Where the findings live in the docs, 7 Tools, states and files, 8 Tool and method lessons, 9 Open questions, 10 Apply log.

---

## 1. Result in one page

| Topic | Question | Verdict |
|-------|----------|---------|
| Fixed colour (scenes `$23`, `$27`) | Does a subtract-masked fixed colour persist? | R6 G6 B2 (`$08C6`) with CGADSUB `$A2`; `$7F0C00-02` stay 0 for 500 / 1000 NMI frames. VERIFIED-RUNTIME |
| Fixed colour (scene `$30`) | Does tint survive cyclers? | R11 G4 B2 (`$088B`) with CGADSUB `$83` for 1800 frames; cyclers touch CGRAM, not `$7F0C00-02`. VERIFIED-RUNTIME |
| Backdrop ramps `#1B` / `#1C` | Where do tagged triplets run? | Scenes `$63`, `$0B`, `$B4`, `$2C` descent and crow crew; ~155-160 frames; crow child darkens with TM `$15` / COLDATA `$E0` until flag `$4F` (interaction sets `$4F`, not `$4C`). VERIFIED-RUNTIME (pokes disclosed) |
| Tagged backdrop writer | Who writes `$7F0C00-02`? | Bits 5/6/7 tag R/G/B; only nonzero writer in ramps is `CopyPaletteBundleFrame` RAM stub (pc 197638). VERIFIED-RUNTIME |
| Scene `$FD` display | Does TM/TS/`$66` hold still? | TM `$13` / TS `$11` / `$66` = `$02` for 200 frames; only scroll and brightness move. VERIFIED-RUNTIME |
| Inventory HDMA | What does `$66` bit 1 do? | Enables HDMA channel 1 to `$2112` (BG3 V-scroll); visible in inventory. VERIFIED-RUNTIME |
| Dao portal OAM | Why priority 3? | Dao spawns all sprites at priority 3; `$3000` draws the portal in front of the wall; `$2000` hides it behind the wall. VERIFIED-RUNTIME (poke on slot `$10C0`) |
| Freedan Aura Barrier VRAM | OBSEL and upload? | Adhoc DMA uploads `misc_fx_1CC480` (48 tiles) to VRAM `$4400`; no `$2101` write during cast; Shadow Aura item does neither. VERIFIED-RUNTIME (pokes) |
| Source cache (mode 0) | When does `STZ $0670` / `$067F` run? | When a mode-0 window exceeds `$2000` bytes (overlaps slot `$066F` VRAM). VERIFIED-RUNTIME |
| Source cache (mode 1) | When does `STZ $0673` / `$0676` run? | Never in 72 scene loads (mode 1 only at page `$50`). INCONCLUSIVE (coverage) |
| Palette decompress | Does `PaletteStep` decompress? | 0 hits on `Decompress` (39291) in 1,315 frames; handlers only JSL `LoadPaletteBundle` / `CopyPaletteBundleFrame`. VERIFIED-RUNTIME |
| Bundle census | How many bundles run? | 128 entries / 1,200 sub-entries; 65 started at runtime, 63 not (22 unreferenced statically). VERIFIED-STATIC + VERIFIED-RUNTIME |
| Ambient bundle `$13` | Which scenes? | Starts in `$1D $20 $25 $26 $27 $28`, not only `$1D` and `$27`. CONTRADICTED (shipped note) |
| Oakton palette gate | Select replay? | Flag `$16` set and `$1C` clear: one Select open/close replays `#02` / `#4C` once per visit. VERIFIED-RUNTIME |
| Mode 7 zoom / rotate | How do `$B6`–`$B8` / `$BC` behave? | `$B8` = `$80` → `M7A` 255; larger divisor zooms in; positive `$B6` zooms toward bottom; increasing `$BC` rotates clockwise; four overflow paths taken, no visible step. VERIFIED-RUNTIME |
| Mode 7 HDMA tables | Rewritten after fill? | No CPU writes to `$7E7000-$8FFF` after first fill in `$FE` `$8C` `$59` `$C0`; 50 / 54 / 38 stale nonzero data words remain. VERIFIED-RUNTIME; CONTRADICTED (“data word 0”) |
| World-map zoom-out | Start and end `$B8`? | Init overwrites first pass; effective start `$0400`; ends `$54` (sum −940, not ~`$34` / −970). VERIFIED-RUNTIME; CONTRADICTED (hand counts) |
| Diary camera | Mode 7 pan? | Scene `$FA` is Mode 1 (BG1 scroll); targets within 12 px of map for 11/15 comparables. CONTRADICTED (“Mode 7 camera”); VERIFIED-STATIC (offsets) |
| World-map split | Below boundary? | Mode 1 black panel with BG3 text; boundary off screen at step 37. VERIFIED-RUNTIME; intent INCONCLUSIVE |
| `M7SEL` outside plane | `$80` vs `$00`? | `$80` shows backdrop black outside 1024×1024; `$80` vs `$C0` pixels identical (tile 0 black). VERIFIED-RUNTIME; transparent vs tile 0 INCONCLUSIVE |
| HDMA channel bind | Allocation rule? | Next channel from `$68` (first bind = ch 1); 14,657 binds in 228 scenes used channels 1–5 only; carry clear on all; 7th-bind carry INCONCLUSIVE |
| Credits circle window | Shape and growth? | Filled oval to radius `$3F` (lines 96–158, x `$42`–`$BE`); radius `$FFFF` for 300 frames then +1/frame to `$3F`. VERIFIED-RUNTIME |
| Mu colour window | Where is setup? | `code_0AF53D` (718141) spawned from `mu67_male_vampire`; WOBJSEL `$30`, CGWSEL `$22`, CGADSUB `$03`. VERIFIED-RUNTIME; natural lair look INCONCLUSIVE |
| Parallax band types | What was seen? | Types `$02 $05 $06 $07 $08 $24 $20` on screen; thinker writes one register; type `$20` rectangle cuts BG1; gap lines = 1 px window at x = 0. VERIFIED-RUNTIME |
| Diary menu bands | Appearance and overlap? | Band = black main screen with BG3 text; copy row flickers every second frame; last HDMA channel on a line wins. VERIFIED-RUNTIME |

Counts: 24 topics above. Shipped extracted notes: 14+ sentences CONTRADICTED or stale across E2–E4 (ambient `$13` scenes, mode-7 “data word 0”, world-map `$B8` math, diary Mode 7 wording, Mu window “not in actors”, band “not checked”, and others in section 4). The campaign changed **0 ROM bytes** at the MS04 rebuild gate.

What changed in what we believe:

1. **Backdrop ramps are bundle-driven tagged triplets**, not mystery COLDATA stores; the crow crew child holds a dark fixed colour until flag `$4F`, then the lookout spawns `#1C`.
2. **Palette bundles are not compressed at step time**; `PaletteStep` only loads and copies frames. Most bundles never start in a flagless sweep (65/128).
3. **Mode 7 HDMA tables are fill-once scratch** reused from the decompressor; leftover nonzero words are normal. World-map zoom math and diary pan targets are now measured.
4. **The diary menu scrolls BG1 in Mode 1**, not a Mode 7 matrix; “Mode 7 camera” language in notes was wrong.
5. **HDMA channels 1–5 exhaust practical load** (≤5 binds/frame in 228 scenes); circle windows invert W12SEL/WOBJSEL for iris effects; parallax bands depend on display presets written at scene load.
6. **Dao portal visibility is OAM priority**, not different tiles; Freedan Barrier uploads FX tiles to `$4400` without touching OBSEL.

---

## 2. What was run

| Step | Ids-or-topic | Method | Volume |
|------|----------------|--------|--------|
| E1 | Display presets, ramps, `$FD`, inventory HDMA, Dao portal, Aura VRAM, source-cache STZ | `kit/lib/e1_display.lua`, `e1_cache.lua`, `e1_aura.lua`; per-scene register snapshots and write callbacks on cache STZ sites; state `orig_S01r_south-cape-ready.mss` plus warps | 72 scene loads for cache watch; ramp and colour scenes; inventory S09 pair; Dao `$C3` / `$1E`; Aura scene `$3F` |
| E2 | Palette bundles, death fade, flashes, Oakton gate, wreck palettes, world-map reset thinkers | `kit/lib/e2_palette.lua`; exec on `PaletteStep` path; `$36`/NMI control; 228-scene sweep + 15 targeted scenarios (`harness/e2_run.py` after server T-44/T-45) | 1,315+ NMI frames in targeted runs; 4,930 `$36` writes per 29-scene chunk; 65 bundles started |
| E3 | Mode 7 matrix, HDMA tables, split effect, diary pan, `M7SEL` | `kit/lib/e3_mode7.lua`; state `orig_S08_world-map.mss`, warps `$8C` `$59` `$C0`, diary S07 for 36 entries; write/exec callbacks, screenshots | Route run 932 frames; rotation 1,300 frames; fill census in four Mode-7-update scenes |
| E4 | HDMA bind sweep, circle windows, parallax bands, diary DMA | `kit/lib/e4_kit.lua`, `harness/e4_*.py`; 13 scene samples × 300 frames; 228-scene bind sweep (90 NMI post-arrival); parallax chain `$2B`→`$E5`→`$2B`→`$2D` | 14,657 HDMA binds; credits oval 96 frames; dream/Mu with disclosed pokes |

Positive controls: every step arms `$36` write callbacks and NMI entry exec (offset 33528) and matches NMI hits to frame parity except one extra `$36` per scene load in E4’s sweep.

---

## 3. Findings

### 3.1 Scene display, ramps and backdrop tags (E1)

- Scenes `$23` and `$27`: COLDATA fixed colour `$08C6`, CGADSUB `$A2`, set once (pcs 46695, 46700); `UploadCgramPalette` copies zero triplets from `$7F0C00-02` every NMI (stores 171533 / 171540 / 171547).
- Scene `$30`: CGADSUB `$83`, fixed `$088B`, persists 1800 NMI frames while CGRAM cyclers animate `$21-$2C` and `$E2-$E4`; bundle `$3F` targets CGRAM `$E2`, not backdrop RAM.
- Ramps `#1B` / `#1C`: 32 frames × 5 ticks (~155–160 NMI frames) of tagged triplets (`$2D 4D 8D` style); darken layers selected by subtract mask. Crow crew: child `code_05857A` writes TM `$15`, CGADSUB `$A1`, COLDATA `$E0` each frame until flag `$4F`; `#1C` after `$4F`, not before.
- Tagged format: bits 5/6/7 of byte 0 select R/G/B; low 5 bits intensity. Nonzero `$7F0C00-02` only from `CopyPaletteBundleFrame` stub at pc 197638 in ramp runs.
- Scene `$FD` (Statue Inventory flyby): TM `$13`, TS `$11`, colour mask `$02`, `$66` = `$02` stable 200 frames; BG2 scroll and brightness animate.
- Inventory: `$66` bit 1 enables HDMA channel 1 to `$2112` (BG3 vertical scroll); seven-step table visible when bit set (S09 state).

### 3.2 Portals, Aura VRAM, source cache (E1)

- Dao (`$C3`): all on-screen sprites OAM priority 3; portal attribute `$3000`. Poking slot `$10C0` to `$2000` hides portal behind wall. Standard portal scene `$1E`: priority 2 throughout.
- Freedan Barrier: at cast, adhoc block writes dest `$4400`, size `$0600`, source ROM `misc_fx_1CC480` (`$9C:C480`); VRAM matches ROM 1536/1536 bytes; OBSEL name base `$4000`, no `$2101` write during cast.
- Shadow Aura item: no OBSEL change, no `$4400` upload (uses `spriteset_shadow_aura_body`).
- Mode 0: `STZ $0670` (pc 165038) and `STZ $067F` (pc 165175) fire when mode-0 window size > `$2000` bytes (`SceneCmd_LoadBgTiles` invalidates overlapping slot).
- Mode 1: `STZ $0673` / `STZ $0676` never fired in 72 monitored loads; mode 1 only seen at page `$50`.

### 3.3 Palette bundles (E2)

- Static decode: 128 bundles, 1,200 sub-entries, 834 distinct frame arrays; 14 backdrop sub-entries in 11 bundles; header counts match `palette_bundles.asm`.
- `PaletteStep` never calls `Decompress` (entry 39291): 0 hits, 100 distinct PCs in `LoadPaletteBundle` / `CopyPaletteBundleFrame` ranges only.
- Death: bundle `$10` — 8 frames, 32 ticks, 16 words `$81-$90`; bundle `$0E` — 15 words `$F1-$FF`, 1 tick; pale blue terminus colours measured.
- Flash `#18` scene `$BC`: 128 ticks, CGADSUB `$21`; `#19` scene `$C0`: CGWSEL `$82`, CGADSUB `$01`, 143 ticks (static 128).
- Kara `#40` scene `$74`: two flashes 60 ticks apart, 32 ticks each, CGADSUB `$21`.
- Ambient records: 59 placements, 33 bundle ids, 32 played in sweep; bundle `$47` only in scene `$84` spawn list (not in 228-id sweep).
- Oakton: flag `$16` without `$1C` replays `#02` (80 colours `$30-$7F`, 1 tick) and `#4C` (`$19-$1F` black → brown/red-orange) once per Select open/close in South Cape interiors.
- Bundle `#03`: 8 frames × 2 colours `$CE-$CF`, 32 ticks/pass; starts only in `$FD` and `$FF`; restarts every pass with flag `#01` set (9 starts / 240 ticks).
- Gold-ship wreck: default `#1A`; flag `$4D` → `#34` then `#33`; flag `$52` → `#36` and kills `scanlineInit` slots `$0F00`/`$0F10`.
- World map `$FE`: two `PaletteResetAndKillThinker` thinkers (slots `$0F20`, `$0F30`) both run 16 ticks, 0 colour changes each.

### 3.4 Mode 7, world map, diary (E3)

- `$B8` divisor: `$80` → `M7A` 255; `$0400` → 31; perspective `$B6` = `$039A`, `$B8` = `$AE`: `M7A` 188 line 0 → 33 line 223. Rotation: `$BC` +32 → `M7B` +149, `M7C` −149 (clockwise on screen).
- HDMA tables at `$7E7000`, `$7800`, `$8000`: filled once per scene; no post-fill CPU writes in `$FE` `$8C` `$59` `$C0`; 50 / 54 / 38 nonzero data words immediately after fill (decompressor leftovers).
- Overflow labels `ov1`–`ov4` all taken on menu trip and scripted rotation; second differences at overflow lines ≤ elsewhere (no visible step).
- World-map zoom-out: Init stores `$0400` after first pass adds to zero; 44 `ADC` passes, effective 43 deltas, final `$B8` = `$54`, sum −940.
- `WorldMapSplitEffect`: below boundary row, BGMODE `$09` with BG3 text; black panel via COLDATA subtract; boundary leaves 224-line field at step 37.
- `M7SEL` `$80` once at n=161 (rom 239945); outside plane black with `$80`, repeating map with `$00`; cutscenes use `$00`.
- Diary: BGMODE 1, `cameraTargetX/Y` pan BG1; 35 table-driven targets settled; 11 of 15 comparable sites within 12 px of world-map start (South Cape +44 px X, Diamond Mine +40 px Y worst).

### 3.5 HDMA channels, windows, parallax, diary bands (E4)

- `SetupHdmaChannel_*`: next channel from `$68` (starts `$02` after reset); 14,657 binds → channels 1–5 only (max 5/frame); carry clear on every bind; channel-7 carry case not observed.
- Credits (`$F7`): oval window WH0/WH1 smooth edge; radius `$FFFF` for first 300 frames then +1 to `$3F` (~62 frames).
- Mu setup `mu_color_window_setup` (was `code_0AF53D`): WOBJSEL `$30`, CGWSEL `$22`, CGADSUB `$03` at pcs 718145–718155; forced circle shows colour math only inside disk.
- Dream (`$2A`): W12SEL `$33` inverts BG1/BG2 to circle; WOBJSEL `$03` hides sprites outside; iris centre (~`$88`, `$160`), leaves screen ~18 frames after radius growth.
- Sine ripple (`$32`, `$E9`, `$EA`): indirect BG1HOFS table period 64 lines, 8 consecutive scroll values (7 px span); `$06C0`/`$06C4` drift each frame.
- Parallax thinker: types `$02`–`$08`, `$20`, `$24` observed; only one PPU register per thinker write — TM, TMW, CGWSEL from `ConfigDisplay` at scene load (pc 166538 region).
- `ParallaxClearBandAccumulators`: clears `$0720-$074E`; `$0750-$760` retain prior scene values.
- Type `$20` scene `$C3`: window rectangle WH0 `$60`–`$9F`, 48 lines; gap entries `$0000` create 1-pixel window at x = 0 (not harmless).
- Diary menu: inside highlight band, main black + BG3 text; copy-source band toggles every frame (6,975 px differ row 150–180 between consecutive frames); three direct tables share WH — last channel per line wins (tab cursor 0 hides slot-1 band).

---

## 4. Shipped notes corrected

| Place | Old statement | Verdict | New statement |
|-------|---------------|---------|---------------|
| `gs2C_crow_crew.asm` block note | Child handles storm `#1C` before flag `$4F`; interaction sets `$4C` | CONTRADICTED | Child darkens until `$4F`; lookout spawns `#1C` after `$4F`; interaction sets `$4F` |
| `ambient_palette_cycler.asm:5` | Bundle `$13` in scenes `$1D` and `$27` only | CONTRADICTED | Also `$20 $25 $26 $28` |
| `flag_gated_palette_warm.asm:10`, `flag_gated_palette_cool.asm:10` | Oakton Select path “was not checked” | stale | One Select open/close replays gated bundles |
| `palette_parent_child.asm:7` | World map / inventory “not traced” | stale | `#03` runs in `$FD` and `$FF`; `$FE` does not start it |
| `mode7_perspective.asm` | HDMA row “data word 0”; tables shared with decompress only unproven | CONTRADICTED | Leftover nonzero words after fill; no post-fill writes in four scenes |
| `WorldMapController.asm` | End zoom about `$34`, sum about −970 | CONTRADICTED | Ends `$54`, 43 effective deltas sum −940; first pass overwritten |
| `diary_entry_table.asm`, `sFA_diary_menu.asm` | “Mode 7 camera” / Mode 7 centre | CONTRADICTED | Diary is Mode 1 BG1 scroll to table targets |
| `WorldMapSplitEffect.asm:16` | Split look “not observed” | stale | Measured black Mode-1 panel with BG3 text below boundary |
| `hdma_circle_window_thinker.asm:13` | Mu window setup “not in extracted actors” | CONTRADICTED | Spawn at 717306 → `mu_color_window_setup` |
| `hdma_circle_window_thinker.asm:33` | Credits window shape “not verified” | stale | Filled oval measured; radius growth timed |
| `scanline_band_hdma_thinker.asm:65` | Runtime band types “not checked” | stale | Seven types seen; preset supplies other registers |
| `diary_menu_window_dma.asm:3` | Band look “not observed” | stale | Black band with BG3 text; 30 Hz flicker on copy row |

`spriteset_aura.asm` OBSEL sentence updated via MS04 (F-series merge row; measured Barrier upload). `palette_bundles.asm` block note counts updated in MS05 (65 started, 22 unreferenced listed).

---

## 5. Rules for patch authors

1. **Tag backdrop colours through palette bundles** (`#1B`/`#1C` and kin): the engine copies `$7F0C00-02` to COLDATA each NMI; do not expect cyclers or fixed-colour scenes to rewrite nonzero triplets unless a bundle frame does.
2. **Do not treat `PaletteStep` as a decompress entry point.** Animation is `LoadPaletteBundle` + `CopyPaletteBundleFrame` only; patch authors adding bundles must keep the existing 6-byte sub-entry layout.
3. **Assume 63 palette bundles are unreachable** in a flagless quick-warp test; gate checks at spawn (`flag_gated_palette_*`, story flags, inventory scenes) matter before relying on a bundle id.
4. **Oakton interior palette replay needs event flag `$16` set and `$1C` clear at thinker spawn** (tested at spawn only); one Select open/close cycle per visit, not continuous replay.
5. **Mode 7 HDMA tables at `$7E7000` / `$7800` / `$8000` are single-fill buffers.** Do not clear them expecting zero data words; later frames overwrite computationally. Only four shipped scenes run `Mode7PerspectiveUpdate`.
6. **World-map zoom-out starts at effective `$B8` = `$0400` on the second controller pass** (Init overwrites the first add). Hand-tuned deltas must match 43 steps ending at `$54`, not `$34`.
7. **Diary location pans use `cameraTargetX/Y` as BG1 scroll in Mode 1.** Do not upload Mode 7 matrix values for diary menu patches; offsets up to ~44 px from map icons can be intentional framing.
8. **HDMA channel allocation uses the next bit in `$68` (channels 1–5 seen in practice).** Plan at most five binds per frame unless you prove a sixth scene; never assume channel 0.
9. **Circle / iris windows need matching W12SEL inversion and WOBJSEL sprite masking** (credits `$33` / dream `$03`; Mu colour window uses WOBJSEL `$30` and CGWSEL `$22`).
10. **Parallax band thinkers write one scanline register per record;** set TM, TMW, CGWSEL, and CGADSUB in the scene display preset, not in the thinker. **`ParallaxClearBandAccumulators` does not zero `$0750-$760`.**
11. **Type `$20` gap lines are active 1-pixel windows at x = 0**, not no-ops. **`STZ $0670` / `$067F`** after large mode-0 BG loads invalidate source-cache slots when the staging window exceeds `$2000` bytes.
12. **Dao portal visibility is OAM priority `$3000`, not different CHR.** Freedan Barrier patches must preserve adhoc DMA to VRAM `$4400` or retarget orbital sprites explicitly; OBSEL need not change if base stays `$4000`.
13. **Button masks depend on the build.** In ROM O the attack button is physical **B** (`$8000`) and item use is physical **Y** (`$4000`). In this baserom build physical **A** feeds `$8080` (interact `$8000`, attack `$0080`) and physical **B** feeds `$4008` (cancel `$4000`, item use `$0008`). State the build when documenting input in display or inventory tests.

---

## 6. Where the findings live in the docs

| Topic | Document |
|-------|----------|
| `hdmaEnableMask`, mode-7 WRAM layout, adhoc DMA block | [`wram-memory-map.md`](wram-memory-map.md) |
| `SceneCmd_LoadBgTiles` cache slots `$066C-$067F` | [`code/bank02/scene-script.md`](code/bank02/scene-script.md) (Cache-and-diff, LoadBgTiles) |
| Palette bundle semantics, backdrop `$7F0C00`, ambient/gated thinkers | [`code/bank00/thinkers-palette.md`](code/bank00/thinkers-palette.md) |
| COP palette ops | [`cop/families/palette.md`](cop/families/palette.md) |
| `SetupHdmaChannel_*`, channel table | [`code/bank03/scene-and-hardware.md`](code/bank03/scene-and-hardware.md), [`cop/families/hdma_dma.md`](cop/families/hdma_dma.md) |
| Sine HDMA thinkers, slow wave | [`code/bank00/thinkers-hdma.md`](code/bank00/thinkers-hdma.md) |
| World map controller, split effect, zoom timeline | [`code/bank03/radar-and-world-map.md`](code/bank03/radar-and-world-map.md) |
| `mode7_perspective`, `IrisCircleEffect` | [`code/bank03/mode7-and-cutscenes.md`](code/bank03/mode7-and-cutscenes.md) |
| Parallax band table types | [`bank01-data-tables.md`](bank01-data-tables.md) (parallax_scroll_table), [`dmap-inventory-bg.md`](dmap-inventory-bg.md) |
| Inventory BG3 HDMA (related display bit) | [`dmap-inventory-bg.md`](dmap-inventory-bg.md) |

---

## 7. Tools, states and files

All paths under `plans/extracted-audit/mesen2-results/` unless noted.

| Kind | Files |
|------|-------|
| Lua kit (`kit/lib/`) | `e1_display.lua`, `e1_cache.lua`, `e1_aura.lua`; `e2_palette.lua`; `e3_mode7.lua`; `e4_kit.lua` |
| Python harness | `harness/e2_run.py`, `e2_targets.py`, `e2_xref.py`; `harness/e4_run.py`, `e4_report.py`, `e4_png.py`, `e4_view.py`; `harness/mcp_client.py` (0.6.0 DLL, E2 after T-44/T-45) |
| Draft specs (`specs/`) | `E1_notes.json`, `E2_notes.json`, `E3_notes.json`, `E4_notes.json`, `E4_names.json`; merged `plans/extracted-audit/edits/MS04.json` |
| Save states (`rebuilt/states/`) | `orig_S01r_south-cape-ready.mss` (E1/E2/E4 warps); `orig_S08_world-map.mss`, `orig_S07_diary.mss` (E3); `orig_E4_*` set (dream, credits, Mu P09, parallax scenes, etc.) |
| Raw output | `raw/E2_bundles.md`, `E2_static.txt`, `E4_scene_tables.md`, `E4_ident.json`, `E4_sw0`–`sw7`; per-run logs `E1_*`, `E3_*`, `E4_sample_*.json`; screenshots `raw/screenshots/E3_*`, `E4_*`, `E1_*` |
| Reports | `E1_20261031.md`, `E2_20261106.md`, `E3_20261108.md`, `E4_20261108.md` (+ `_lua.md` companions) |

---

## 8. Tool and method lessons

- **`get_dma_state` at frame end is unreliable** for HDMA enable (`hdmaEnableMask` 0); E1 logged `$420C` / `$4310-$4327` directly. E3 notes stale DMA snapshots (T-53).
- **Reload state before every run** (T-51): `run_script` does not replace a prior load; E3/E4 treat each scenario as load-then-run.
- **Server failover:** E2 continued through `mcp_client.py` when the Cursor-registered 0.6.0 server timed out or disconnected (T-44, T-45). Lua syntax errors in an include may not abort until timeout (T-46).
- **Parallel load hazards** (T-52, T-54): do not overlap `load_state_file` with script attachment; black screenshots during fade-in cost a retry (T-43, T-55).
- **E4 callback limits:** Lua callback errors can be silent; 1 s limits with `getPixel` affect circle diffs (T-56–T-59). `emu.getState()` may not expose all CGWSEL clip/prevent bits — decode from write callbacks.
- **PPU register pokes via `snesMemory` work** for `M7SEL`, `$BC`, `$B8` probes (E3).
- **Sweep determinism:** E2’s eight sweep chunks produced byte-identical aggregate files when rerun with R1 dumps.
- **Disclosed pokes must stay in reports:** flags, warp coordinates, diary slot words, Mu circle parameters, Dao portal attribute — closures mark these VERIFIED-RUNTIME with poke disclosure; do not treat a poked path as the only natural route.
- **Input for the Aura cast on ROM O:** hold the attack button (physical **B**, `$8000`) for the attack-triggered Barrier; the item button (physical **Y**) for the Shadow Aura item. The baserom build maps the buttons differently; cite the build.

---

## 9. Open questions

From the four reports and `open-questions.md` (deduplicated):

1. NQ-071: With all flags clear, does `flag_gated_palette_warm` still end at the `$16` gate in Oakton (not observed directly on natural arrival)?
2. NQ-072: Who writes zero to `$7F0C00-02` every NMI in fixed-colour scenes (stores at 171533 / 171540 / 171547), and which scenes besides ramps ever set nonzero tagged triplets?
3. NQ-073: Why does chained quick warp `$08` → `$09` hang (garbage direct page)?
4. NQ-076: Which shipped scene performs mode-1 `LoadBgTiles` with page bits 3/5 set so `STZ $0673` / `$0676` would fire?
5. NQ-077: Does the standard portal in scene `$1E` sit behind a wall at priority `$3000` (only Dao tested)?
6. NQ-078: Why do thinkers in scene `$1A` stop stepping ~50 ticks after a forced flag `$2A` warp; does the Moon Tribe dialog complete bundle `#1F` naturally?
7. NQ-079: Which CGRAM rows `$19-$1F` does bundle `#4C` affect in South Cape interiors; does “cool” label fit measured red-orange?
8. NQ-080: Which sprites use OBJ palette 7 on the game-over screen after bundles `$10` / `$0E`?
9. NQ-081: Why does flash `#19` run 143 ticks in `$C0` vs static 128?
10. NQ-082: Is scene id `$84` reachable (only home of ambient bundle `$47`)?
11. NQ-083: Which gates block flash spawns in scenes `$15`, `$66`, `$BF`, `$E8` when only their flags are set?
12. NQ-084: In scene `$BC`, do death-fade bundles `$10` / `$0E` starting five frames after `#18` imply an accidental game-over sequence?
13. NQ-085: What runs in the 12-frame gap between world-map `ArrivalAndTravelSetup` passes with no NMI (busy scene load)?
14. NQ-086: Are diary camera offsets (>12 px for South Cape, Diamond Mine, Angel Village) deliberate framing or table slips?
15. NQ-087: Does natural SRAM fill after Dark Space save write the slot scene ids `DiaryCameraPan` expects?
16. NQ-088: Should `DiaryMenuVBlankHandler` documentation say BG1 scroll only (never Mode 7 in diary)?
17. NQ-089: Which vampire state in Mu raises the iris radius; what does the lair look like during natural growth?
18. NQ-090: Dao A/B pixels outside the type-`$20` rectangle — HOFS timing vs window edge?
19. NQ-091: Do any type `$05` / `$24` records read accumulator words `$0758` / `$0760`?
20. NQ-092: Does any scene bind 6–7 HDMA channels in one frame (diary over parallax)?
21. NQ-093: Natural diary copy flow: cursor values for `$0D92` / `$0D96` and visibility of slot-2 band?
22. E1 Mu `$7E` rectangle variant and snake-pit spawn position for `$B4` (not in open-questions table; still open in E1 report).
23. E3: Can `$80` vs `$C0` outside-plane pixels be distinguished if tile 0 were not black?

---

## 10. Apply log

| Item | Result |
|------|--------|
| **MS04** (2026-11-10) | Merge `edits/MS04.json` (107 files); names `apply-MS04_names.json` (7 entries, includes `mu_color_window_setup`). Gate unchanged: sha1 `90a04067dd5b5284bd9e152ad222df0e65d08979`. |
| E1 in MS04 | `gs2C_crow_crew.asm` block note (ramp / flag `$4F`) |
| E2 in MS04 | `palette_parent_child.asm`, `flag_gated_palette_warm.asm`, `flag_gated_palette_cool.asm`, `ambient_palette_cycler.asm`; **also merged on same step:** `WorldMapController.asm`, `mode7_perspective.asm`, `WorldMapSplitEffect.asm`, diary files (see E3 row in MS04 table — same apply batch) |
| E3 in MS04 | `WorldMapSplitEffect.asm`, `mode7_perspective.asm`, `WorldMapController.asm`, `diary_entry_table.asm`, `sFA_diary_menu.asm` comments |
| E4 in MS04 | `hdma_circle_window_thinker.asm`, `scanline_band_hdma_thinker.asm`, `sine_hdma_slow_wave.asm`, `diary_menu_window_dma.asm`, `mu67_vampires.asm` part note + rename |
| E1/E2 not merged in MS04 | `spriteset_aura.asm` (F3), `scene_script.asm` cache comments (need line tags), `mu63_spirits` / `awB4` headers |
| **MS05** (2026-11-12) | `palette_bundles.asm` block note: 65/128 started, 22 unreferenced ids listed, 41 referenced-but-not-reached |
| Closures | 25 rows cite `E1_20261031.md`–`E4_20261108.md` (26 including 2026-11-12 `OQ-I060-5` split row); 186 rows appended on MS04 pass overall |
| Docs | This summary; some `docs/` sentences were left outside the MS04 scope and are listed in its log |

See `plans/extracted-audit/mesen2-results/MS04_apply.md` and `MS05_apply.md` for full per-file tables and blocked items (`MenuSelectionHandler.asm` unrelated).
