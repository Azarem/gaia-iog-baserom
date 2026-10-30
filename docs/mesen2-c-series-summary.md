# Mesen2 C series: NMI, boot and display-mode findings (C1 to C4)

Runtime investigation of the NMI/VBlank plumbing of the US ROM: the adhoc VRAM DMA block, every writer of `NMITIMEN`, the boot sequence (`MEMSEL`, the `$0100` byte, the boot-logo flag), and the bits of `displayModeFlags`. Compiled 2026-10-30 from `plans/extracted-audit/mesen2-results/C1_20261030.md`, `C2_20261030.md`, `C3_20261030.md`, `C4_20261030.md` and the apply log `MS02_apply.md`.

ROM: O (vanilla, SHA-1 `38de0c84dd2bc3bdfc0a3d7ab0220c79b70887c3`) for every run. Server: Mesen2 MCP 0.5.2 (C1 main runs) and 0.6.0 (C1 boot addendum, C2, C3, C4). Rebuilt ROM R (SHA-1 `2e4a88a3de6dd4bdefc23c0dd626b953c18fe808`) was not used; the apply pass changed notes only and the R rebuild is byte-identical (gate below).

Sections: 1 Result in one page, 2 What was run, 3 Findings, 4 Shipped notes corrected, 5 Rules for patch authors, 6 Where the findings live in the docs, 7 Tools, states and files, 8 Tool and method lessons, 9 Open questions, 10 Apply log.

---

## 1. Result in one page

| Id | Question | Verdict |
|----|----------|---------|
| OQ-45 | Is there an NMI window between the destination and size stores of the adhoc VRAM DMA? | **No window in the shipped game.** 27 of 27 pairs (11 radar, 16 COP): 0 NMIs, 0 `$36` writes, NMI disabled at both stores. The old sentence "writers must store the size first" described a rule the code does not follow; both writers store the destination first. VERIFIED-RUNTIME. The six other COP callers were not run (INCONCLUSIVE at runtime) |
| OQ-I022-4 | Who writes `NMITIMEN` (`$4200`), and can actors run with the NMI on? | **Exactly three writers**: `EnableNmiAndJoypad` (`$81`), `DisableNmiKeepJoypad` (`$01`), the boot register table (`$00`). 15,812 writes in 16 runs. Actors run with `$01` in all 4,284 `RunActors_Normal` entries, **except the first `UpdateFrameDialogue` pass after a scene load (16 of 19 loads) which runs with `$81`**. Three shipped comments ("NMI-only mode", "Enable NMI ...") were wrong. VERIFIED-RUNTIME |
| OQ-I024-4 | `MEMSEL` written twice at boot: which timing runs where? | **Three `$420D` writes** (1, 0, 1). FastROM timing is live only for the 76-row register loop (0.05 frame); the whole upload and the first scene loads run SlowROM until `BootLogoInit` (frame 84). The SPC upload takes the same master clocks under FastROM (it waits on the SPC handshake). Intent of the first write: INCONCLUSIVE |
| OQ-50 | What does the `$0100` / `$83` check in `SystemInit` do? | **Nothing.** Both outcomes leave `Y = 0`; the boot is identical frame by frame with `$83`, `$00`, `$5A`, 150 and random values. `$0100` is never written during boot. Whether anything sets `$83` during play: INCONCLUSIVE (not run) |
| OQ-I055-3 | Does a reset skip the first boot logo (event flag `$10`)? | **No.** The boot WRAM clear zeroes `$0A02` in frame 0, so the Nintendo logo always plays first (two cases tested). VERIFIED-RUNTIME |
| OQ-6, OQ-42 | `hudDisableFlag` bit 7 and the partial BG3 upload bits | **Bit 15 of the word has no setter**; forced, it freezes the BG3 upload with the requests kept pending. **Bit 5 has no setter**; bit 4 is requested only by `UpdateHUD`. Both bits upload `$0140` bytes to VRAM `$7840-$7983`. VERIFIED-STATIC + VERIFIED-RUNTIME |
| OQ-23† | Who consumes bit 0? | **`Bg3TilemapVramDma`**: `$0800` bytes `$7F:0200` -> VRAM `$7800` in the first NMI after the request, once per request. VERIFIED-RUNTIME |
| OQ-51 | Who reads bit 13 (dialogue mode)? | **One reader: the Mu bomb countdown** (`mu67_bomb.asm:145-147`); it pauses while the bit is set (timer frozen 360 frames). Four shipped "no reader" notes were wrong. VERIFIED-RUNTIME |
| OQ-I034-1†, OQ-I057-4† | Bit 14 in the inventory and in the diary | **Bit 14 = HUD off** (`hudDisableFlag` bit 6), read by `UpdateHUD` and `LoadHudTilemap`; the inventory's `$4000` store is cleared by `SceneCmd_ConfigDisplay` two frames later; the diary never shows the HUD while it is set. VERIFIED-RUNTIME |

Counts: 11 ids. Shipped notes: 9 sentences CONTRADICTED (the store-order rule in 2 places, "Enable NMI" at `system_core.asm:350`, "NMI-only" in 2 places, "no reader of bit 13" in 4 places), the others refined or stale (section 4). The campaign changed **0 ROM bytes**.

What changed in what we believe:

1. **The adhoc DMA is safe only because the NMI is off during actor code.** The destination store arms the transfer; the writers rely on that, not on the store order. This is a property of NMITIMEN, not of the DMA code.
2. **`$01` is "NMI off, joypad on".** Nothing in the engine is "NMI-only". The NMI is enabled only for the VBlank wait at the end of a pass, plus one accidental pass after every scene load.
3. **The boot is SlowROM until frame 84.** The first `MEMSEL = 1` is cancelled by the register table's last row; `BootLogoInit` is the real FastROM enable. FastROM from reset would save only 4 of 84 frames.
4. **`displayModeFlags` is a request-bit word with a HUD-switch high byte.** Bit 13 is not "no reader"; bit 14 is not "unused"; bit 15 and bit 5 are dead; bit 3 is the player-tile DMA request, not a dialogue flag.
5. **A reset gives the Nintendo logo again.** Event flags do not survive a reset because the boot clears WRAM.

---

## 2. What was run

| Step | Ids | Method | Volume |
|------|-----|--------|--------|
| C1 | OQ-45, OQ-I022-4 | Write callbacks on the adhoc block (`$7F:0C03-$0C0A`), exec counters on `NmiHandler` and `$36`, and on `$4200` at all 128 bank aliases; the hardware NMI-enable bit read at every store; scenarios: radar screen (Start), credits `$F7` (16 COP stagings), inventory, Dark Space warp, two chests, a forced-NMI sensitivity run; boot census with server 0.6.0 (addendum) | 27 trigger/size pairs; 119 `UpdateFrameFull` entries; 300 frames of cold boot |
| C2 | OQ-I022-4 | Same `$4200` census as C1 with call-site attribution (caller, offset, NMITIMEN before the call), 16 scenarios: cold boot to the title and diary (700, 1,500 frames), main loop, scene loads `$15 $08 $FA $FE $F7 $E6`, radar, Select inventory, town PAUSE, two chests (one with a music change) | 15,812 writes, 4,284 `RunActors_Normal` entries, 19 scene loads |
| C3 | OQ-I024-4, OQ-50, OQ-I055-3 | Three cold boots (440, 440, 120 frames), six soft resets with the `$0100` byte or `$0A02` poked before the reset (`$83`, `$00`, `$5A`, kept, flag set at the title, flag set by the game in the second logo); callbacks on `$420D` (all aliases), APUIO, `INIDISP`, `$0100`, `$0A02`, `sceneNext`; master-clock timing with and without the `MEMSEL = 0` table row | 15 boots in all |
| C4 | OQ-6, OQ-23†, OQ-42, OQ-51, OQ-I034-1†, OQ-I057-4† | Write/read callbacks on `$09EC`-`$09ED` with old/new per bit; forced bits 0/4/5/15 with marker words in the staging buffer and VRAM read-back; bit 13 forced during the Mu bomb countdown; natural runs in title, diary, South Cape (HUD, PAUSE, inventory), church (dialogue), Mu `$67`, `$E8`, Herb chest, credits, world map; HUD screenshots with bit 14 set and clear | ~9,000 frames, 10 scenes |

All four steps finish with a static census (`rg` over `extracted/` and `baserom/`) so that absence claims ("no other writer of `$4200`", "no instruction sets bit 15") are backed by both a runtime control and a full source search.

---

## 3. Findings

### 3.1 Adhoc VRAM DMA (C1, C2)

- Block `$7F:0C03` (source word), `$0C05` (bank), `$0C07` (**destination word, also the pending flag**), `$0C09` (size). `DmaAdhocVramBlock` runs the transfer when the destination is nonzero and zeroes it; cleared 1 NMI after staging in 26 of 27 cases, 2 NMIs once (the first NMI skipped the block: `dmaSkipFlag` or `displayModeFlags` bit 3).
- Two writers only: `RadarScreenSetup` (offset 229567, destination store at `$83:80EC`, size at `$83:80F3`) and the `AdhocVramDma` COP handler (`$80:98F6` / `$80:9900`). `ClearSceneState`'s `STX $0C07` writes low WRAM with DBR `$81`, not `$7F:0C07`. Boot-time stores seen at `$82:9F30` are the WRAM zero-fill DMA, not a CPU writer.
- Both writers store destination then size. No NMI between the stores: NMITIMEN last written `$01`, hardware enable clear at both stores, scanlines of the stores include 241-260 (the actor pass crosses VBlank without an NMI).
- The COP handler had 35 entries in the credits run, 19 of them Phase B polls; one entry ran with NMITIMEN `$81` (a poll or the first staging, undecided).

### 3.2 NMITIMEN (C1, C2)

- Writers: `$82:819B` (`EnableNmiAndJoypad`, `$81`), `$82:81A8` (`DisableNmiKeepJoypad`, `$01`), `$82:9F44` (`InitHardwareRegisters`, `NMITIMEN = 0` row, boot only). Store counts equal the call-site counts.
- `MainLoop` disables at +4 and enables at +98 every pass, so NMITIMEN is `$81` only during the VBlank wait. Actors, collision, `GlobalInputHandler`, `RadarScreenSetup` all ran with `$01`.
- `ExecuteSceneTransition` ends with `EnableNmiAndJoypad` (19 of 19) and nothing disables it before the enter transition, so the first `UpdateFrameDialogue` pass runs `RunActors_CutsceneOnly` with `$81` in 16 of 19 loads (every run that loads a scene shows it). The other 3 loads are not analysed.
- `UpdateFrameFull` (run from the NMI during a blocking music upload) disables the NMI first (119 of 119 see `$81`), then enables at the end.
- Boot: `$00` at frame 0, `$01` from frame 3, first `$81` at frame 26, first NMI at frame 27.
- The full caller table (counts and NMITIMEN before each call) is in [`code/bank02/hardware-and-init.md`](code/bank02/hardware-and-init.md#nmitimen-state-by-caller-measured).

### 3.3 Boot, MEMSEL, `$0100`, boot-logo flag (C3)

| Frame | Event |
|------:|-------|
| 0 | reset vector; `MEMSEL = 1` (`$80:8027`), register loop, table row `MEMSEL = 0`, WRAM clear (`$0A02` -> 0) |
| 3-7 | SPC engine upload (6,045 APUIO writes, 1,585,758 master clocks, SlowROM) |
| 7 | `$0100` read; first `ExecuteSceneTransition` with `sceneNext = 0` |
| 26-27 | `sceneNext = $FB`; scene `$FB` current; first NMI |
| 59-65 | scene `$FB` music upload (SlowROM) |
| **84** | **`BootLogoInit`: `MEMSEL = 1`** (FastROM from here) |
| 85-100 | Nintendo logo fades in |
| 203 | flag `$10` set, scene `$FB` reloaded |
| 223 | second logo (ENIX), `MEMSEL = 1` written again |
| 343 | flag cleared, `sceneNext = $FC` |
| 360 | title |

- **Determinism.** Two cold boots agree on every mark frame; Mesen2 randomises WRAM at power-on (the `$0100` and `$0A02` before the clear differ), the boot does not care.
- **`$0100`.** Read once at `$80:803E`; only `$83` takes the `BEQ`, which skips the second `LDY #$0000`; both paths load `Y = 0`. Master clock at `BootLogoInit` differs by at most 48 clocks across cases. `dialog_string_scanner.asm:79` is the only writer found in `extracted/` (scratch). Not a save marker, whatever the old name `sramMagicByte` suggests.
- **`MEMSEL`.** FastROM from reset would save 4 of 84 frames, all inside the first scene load. `memoryManager.cpuSpeed` at a callback is the speed of the previous bus access; use `internalRegisters.enableFastRom`.
- **Event flag `$10`.** `$0A02` bit 0. Zeroed by the boot WRAM clear in frame 0 (`$82:9F30`, DMA), before any scene is chosen; set at frame 203 by the set routine (`$80:B0D4`) and cleared at frame 343 (`$80:B0F7`).

### 3.4 displayModeFlags (C4)

The per-bit table (setters, clearers, readers, measured effect) is in [`wram-memory-map.md` Display Mode Flags Reference](wram-memory-map.md#display-mode-flags-reference-09ec). The short version:

| Bit | Role |
|-----|------|
| 0 | full BG3 upload request (`$0800` bytes `$7F:0200` -> VRAM `$7800`), one DMA per request, many setter sites (dialogue renderer, scene load, HUD loader, inventory, PAUSE close, title / diary / credits) |
| 3 | player-tile DMA request (`sprite_composition` sets, `DmaPlayerTilesToVram` / `UpdateFrameDialogue` clear) |
| 4 | partial BG3 upload (`$0140` bytes -> `$7840-$7983`), requested only by `UpdateHUD` |
| 5 | same as 4, no setter |
| 6 | sine-table rebuild request, set by the inventory close |
| 7 | display filter mode (chest, stat reward, music jingle, ~20 actors) |
| 13 | dialogue mode, read only by the Mu bomb countdown |
| 14 (`$09ED` bit 6) | HUD off: `UpdateHUD` and `LoadHudTilemap` return at once; stale numbers stay on screen |
| 15 (`$09ED` bit 7) | BG3 upload gate: no setter; forced, uploads are suspended and stay pending |

Other measurements: the idle diary (state `$4000`) requests nothing in 300 frames; HUD with bit 14 set stays stale after an HP/gem change and is redrawn through bit 4 after the clear; the inventory store of `$4000` is undone two frames later by the scene display command; the Herb chest holds `$0080` for one frame; the church dialogue sets and clears bit 13 four times; the credits scene sets `$4001` (`sF7_credits`, offset 644718); bit 6 stays set 300 frames in South Cape after an inventory visit.

---

## 4. Shipped notes corrected

| Place | Old statement | Verdict | New statement |
|-------|---------------|---------|---------------|
| `hdma_dma_spc.asm:27` block note | "Writers must store the size before the destination" | CONTRADICTED | both writers store the destination first; safe because no NMI can run between the stores; a writer that can run with the NMI on must store the size first |
| `radar_map_screen.asm:76` comment | "writers should store the size first" | CONTRADICTED | NMI is off here, so the NMI cannot run before the size store |
| `cop_handlers_vram.asm:24` | "... but the NMI fires on a nonzero destination" | narrowed | no NMI between the stores; the first dialogue pass after a load has no such protection |
| `system_core.asm:350` comment | "Enable NMI for partial V-Blank" | CONTRADICTED | the call is `DisableNmiKeepJoypad` (NMITIMEN `$01`); the enable is at the end |
| `GlobalInputHandler.asm:113`, `:146` | "NMI-only mode" | CONTRADICTED | `$01` = NMI off, joypad auto-read on |
| `scene_lifecycle.asm:178` | "... a chain of VBlank sync/NMI enable calls" | incomplete | chain ends with `EnableNmiAndJoypad`, NMITIMEN `$81` into the enter transition |
| `system_core.asm:141`, `:169` | "stays SlowROM until ..." | refined | exact FastROM span and the measured upload time |
| `system_core.asm:144` | `$0100` check, both outcomes `Y = 0` | refined | value after cold boot and reset, identical boot measured |
| `sFB_boot_logo.asm:8` | flag survives the reload | refined | a reset clears it too |
| `camera_tilemap.asm:871`, `:875` | upload suppressed by bit 7 / bits 4 and 5 | refined | pending-and-resume behaviour, no setter for bit 15 or bit 5, measured VRAM range |
| `DialogStringRenderer.asm:142` | "consumer not traced" | stale | `Bg3TilemapVramDma` uploads `$0800` bytes to VRAM `$7800` |
| `cop_handlers_dialog.asm:59`, `:75`, `:122`, `:126` | "no reader of this bit" (bit 13) | CONTRADICTED | the Mu bomb countdown reads it |
| `inventory_overlay.asm:116` | bit 14 = HUD off | refined | cleared again two frames later by `SceneCmd_ConfigDisplay` |

Doc statements corrected in the same pass: `wram-memory-map.md` (`$09EC` row listed "bit `$0008` = special BG3" and "bit `$08` = dialogue display"; `$0100` "save validity marker"), `system-core.md` (boot steps 6-11 mislabelled, "Clear `$09EC` bit 8 = exit dialogue mode"), `dialog.md` (three "no reader" statements), `nmi-handler.md` ("main loop typically has NMI enabled", "special BG3 path").

---

## 5. Rules for patch authors

1. **Staging an adhoc DMA from an actor is safe; from anywhere that can run with NMITIMEN `$81` store the size before the destination.** Never assume the order protects you in the first dialogue pass after a scene load.
2. **Never rely on `$01` meaning NMI on.** To wait for VBlank with the NMI off, poll RDNMI (`VBlankWaitAndJoypad` does). A routine that enables the NMI and returns leaves it on for the caller.
3. **Request BG3 uploads by setting bit 0 (full) or bit 4 (rows 2-6) after writing `bg3TilemapBuffer`;** the next NMI uploads once. Do not set bit 5 or bit 15 of the word without a reason: bit 5 has no caller and bit 15 freezes all BG3 uploads (it can be used as a deliberate freeze, and the requests are kept).
4. **To hide the HUD, set `displayModeFlags` bit 14 (`$4000`, usually with `$0001`).** The HUD already on screen stays; redraw needs the bit cleared and a stat change. The scene display command clears the bit whenever it runs.
5. **Do not use bit 13 as a general "dialogue is open" flag**: its only reader is the Mu bomb countdown. Only `DialogueOptions` and `PrintDialogString` set it; `PrintDialogStringAlt` and the console-string runner do not, so a patch that tests it would miss those texts.
6. **Event flags and everything else in WRAM are cleared by a reset;** the boot logo flag logic needs no special handling.
7. **A boot-time patch cannot assume FastROM before frame 84.** Hooks in `SystemInit`, the first scene loads and the SPC upload run SlowROM; timing-sensitive code there should not assume 3.58 MHz.
8. **Button masks.** In the vanilla O build the inventory's logical cancel `$4000` is the physical Y button; the baserom's remapped build makes it B. State the build when documenting a mask.

---

## 6. Where the findings live in the docs

| Topic | Document |
|-------|----------|
| Bit table of `$09EC` / `$09ED`, adhoc DMA block, `$0100`, event-flag reset | [`wram-memory-map.md`](wram-memory-map.md) (Display Mode Flags Reference, §2.2, §4.3, `$0A00` row) |
| NMITIMEN writers and call sites, `MEMSEL` measured | [`code/bank02/hardware-and-init.md`](code/bank02/hardware-and-init.md) |
| Boot steps and timeline, `UpdateHUD`, `UpdateFrameDialogue`, `UpdateFrameFull` | [`code/bank00/system-core.md`](code/bank00/system-core.md) |
| NMI flow, adhoc timing, BG3 upload step | [`code/bank00/nmi-handler.md`](code/bank00/nmi-handler.md) |
| `Bg3TilemapVramDma` measured | [`code/bank02/camera-scrolling.md`](code/bank02/camera-scrolling.md) |
| Inventory open/close and `$4000` | [`code/bank02/inventory-overlay.md`](code/bank02/inventory-overlay.md), [`code/bank02/scene-script.md`](code/bank02/scene-script.md) |
| Dialogue bit 13 | [`cop/families/dialog.md`](cop/families/dialog.md), [`code/bank06-late-midgame-actors.md`](code/bank06-late-midgame-actors.md) |
| `AdhocVramDma` COP | [`cop/families/vram_memory.md`](cop/families/vram_memory.md), [`code/bank03/scene-and-hardware.md`](code/bank03/scene-and-hardware.md) |
| PAUSE and Select NMITIMEN | [`code/bank03/field-input-and-items.md`](code/bank03/field-input-and-items.md) |
| Boot logos | [`code/bank0B-late-bosses-system-cutscene-actors.md`](code/bank0B-late-bosses-system-cutscene-actors.md) |

---

## 7. Tools, states and files

All under `plans/extracted-audit/mesen2-results/` unless noted.

| Kind | Files |
|------|-------|
| Lua instrumentation modules (`kit/lib/`) | `c1_adhoc.lua` (store order against the NMI, `$4200` writers by PC), `c2_nmitimen.lua` (caller attribution, NMITIMEN before each call), `c3_boot.lua` (boot timeline, `$420D`/APUIO/`$0100`/`$0A02`), `c4_dmf.lua` (`$09EC`/`$09ED` callbacks, per-bit timeline, VRAM read-back) |
| Python harness (`harness/`) | `scenario_c2.py`, `scenario_c3.py`, `c2_report.py`, `c2_disasm.py`, `c3_probe.py`, `mcp_client.py` (starts the 0.6.0 server with the two path flags) |
| Draft note specs (`specs/`) | `C1_notes.json`, `C2_notes.json`, `C3_notes.json`, `C4_notes.json`; merged apply spec `plans/extracted-audit/edits/MS02.json` |
| Save states (`rebuilt/states/`, listed in `states-index.md`) | `orig_C1_chest-0E.mss`, `orig_C1_chest-1D-fanfare.mss` (C1), `orig_S06_title.mss`, `orig_S07_diary.mss`, `orig_S09_inventory.mss` (C4) |
| Raw output (`raw/`) | `C1_*`, `C2_<scenario>_20261030.json` (16), `C2_report_20261030.txt`, `C3_<case>_20261030.json`, `C4_*`; screenshots `raw/screenshots/C3_*.png` (logos), `C4_*.png` (HUD with bit 14 set/clear) |
| Reports | `C1_20261030.md` to `C4_20261030.md`, `MS02_apply.md`, `closures.md` rows |

---

## 8. Tool and method lessons

- **Callback model.** Memory callbacks run before the access and report the PC after the instruction (subtract the instruction length for the accessor). RMW instructions (`TSB`/`TRB`) and 16-bit loads appear as readers of both bytes, so a setter shows up in a reader list. DMA writes also fire callbacks, with the PC of the trigger store (the boot WRAM fill looks like a CPU adhoc writer; identify it by PC and frame).
- **Positive controls.** Every absence claim ("no other writer", "no NMI between the stores") was backed by a control that proves the callbacks fire: NMI exec count against `$36` writes, call-site counts against store counts.
- **Random power-on WRAM.** Mesen2 randomises WRAM; `$0644`, `$0100`, `$0A02` are garbage before the boot clear. Never use them as a key before frame 1.
- **`internalRegisters.enableNmi` and `.enableFastRom`** give the hardware NMI-enable bit and the `MEMSEL` bit at the instant of a callback; `memoryManager.cpuSpeed` is the previous access.
- **Server 0.6.0 features** (`load_rom paused`, `run_script fromReset`, `reset mode`, `get_server_status`) fixed the 0.5.x problem that scripts attached 97 frames after `load_rom`. The Cursor-registered namespace in this workspace is a stale 0.4.0-era schema without them; runs went through `harness/mcp_client.py`. Environment issue, not a server defect.
- **Input.** In `c4.run` the `input` hook (setting input on `inputPolled`) did not deliver Start to the title; `gaia.hold` / `gaia.release` from the per-frame `at` table did. A flaw of the module, not a server defect. `run_script` rejects unknown arguments (`wordCap` belongs inside `c4.run{}`).
- **Soft reset advances the frame counter by 1**; read WRAM back at the reset vector before trusting a "kept" value.
- **Buttons.** B closes nothing in the vanilla O inventory; use Y (`$4000`).
- **A forced bit shows only in the word timeline, by design** (script writes do not trigger callbacks); a natural setter does.

---

## 9. Open questions

From the four reports, deduplicated:

1. Which actors can run `AdhocVramDma` with the NMI enabled, if any? Are any COP stagings made in the first (NMI-on) `UpdateFrameDialogue` pass after a scene load? Is the one NMI-on credits entry a poll or a stage?
2. Which 3 of the 19 scene loads do not run `RunActors_CutsceneOnly` with the NMI on, and why?
3. Why does one credits transfer wait 2 NMIs (`dmaSkipFlag` or bit 3 at that frame)? Which scenes call the handler with the pending flag already set (the 19 of 35 polls)?
4. What happens between scene `$FB` current (frame 27) and `BootLogoInit` (frame 84), and is the one `INIDISP = $00` frame at 26 visible?
5. Is the first `MEMSEL = 1` deliberate? Does anything set `$0100` = `$83` during play, and does a reset after a dialogue (the scanner leaves hit offset + 1 there) behave like the controls?
6. Which on-screen elements occupy BG3 rows 2-6 (VRAM `$7840-$7983`), and what do the two other `UpdateHUD` bit-4 sites (`system_core.asm:466`, `:482`) redraw?
7. Bit 7 (display filter): which per-frame dispatcher tests it in a chest pickup, which actors keep running (`RunActors_Normal` at 248591 was not executed in the chest run)?
8. Does the sine-table rebuild (bit 6) run after an inventory visit in a `GenHdmaSine` scene, and does `cop_handlers_effects.asm:726-728` clear it?
9. What sets flag `#02` (the start of the bomb countdown) in scene `$67`, and does natural dialogue overlap the countdown? Only the forced bit was measured.
10. Reach the NMITIMEN call sites never run: the three diary pairs, `radar_map_screen.asm:84-86`, `gs2C_crow_crew.asm:40`, `sFC_title_start_handler.asm:66`.
11. Why did one early `pause_town` run recognise no Start press?
12. The logo order is now measured (Nintendo with "PRESENTS" first, ENIX second); the M2 step (OQ-I055-1, OQ-I055-2, OQ-I055-5) can reuse `scenario_c3.py` and the frame table above.

The three `UNVERIFIED-RUNTIME` lines noted in `B_addendum_20261030.md` (BA-N1 to BA-N3) are unrelated to this series and remain open.

---

## 10. Apply log (MS02)

| Item | Result |
|------|--------|
| Specs validated | each of C1 to C4 dry-run OK; C1 and C2 overlap in two entries, resolved by the merged `edits/MS02.json` |
| Merge | 11 extracted files, 8 notes files written; one warning (comment 191778 is 217 characters) |
| Gate | `artifacts/crc.json` identical to the baseline: checksum 222977929, crc -524441819, totalSize 3062193, sha1 `2e4a88a3de6dd4bdefc23c0dd626b953c18fe808`; **no ROM byte changed** |
| Extraction | `extract:lt` -> `rebuild` -> read-back of all 15 edits -> `extract` (plain) -> `rebuild` |
| Names | no names spec; `names --check` still reports 12 pre-existing formatting problems in other bank files |
| Closures | 17 rows appended to `closures.md` |
| Docs | 14 existing docs updated, this document added |
| Open item overlap | ACTION_PLAN IT-19 touches the same three extracted places; measured sentences must be kept |

See `plans/extracted-audit/mesen2-results/MS02_apply.md` for the per-edit table.
