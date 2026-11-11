# Mesen2 MCP server: enhancement requests from the IOG audit investigation

Server: `C:/Work/mesen2-mcp` (C#, .NET 8, stdio JSON-RPC; tools in `UI/Mcp/McpToolService.cs`, runner flags in `UI/Mcp/McpServerRunner.cs`, Lua API in `Core/Debugger/LuaApi.cpp`). Registered in `C:\Users\azare\.cursor\mcp.json` as `mesen2-mcp` (`dotnet .../MesenMcpHost.dll`, `MESEN_MCP_DEBUG=1`).

Consumer: [mesen2-investigation-plan.md](mesen2-investigation-plan.md) (358 open questions, 14 sessions, about 45 experiments). This file lists what the plan needs from the server and does not get today. Each request has a problem with evidence, a proposal, an acceptance test and the experiments it unblocks. Priorities:

| Pri | Meaning |
|-----|---------|
| **P0** | A defect or a missing fact that makes a result untrustworthy or forces a hand step on every session. Fix before the plan's sessions 2-14. |
| **P1** | Removes a recurring workaround, or makes a whole experiment family cheap. |
| **P2** | Convenience, or only a few P3 questions benefit. |

Evidence tags: **S** = read in the server source on 2026-10-29 (re-read the cited method before implementing: line numbers are not given on purpose); **R** = observed at runtime on 2026-10-28 (plan §1); **D** = from Mesen2 docs or the Lua API source, not exercised.

**Status (2026-10-30): MCP-01 to MCP-30, B-04 and B-05 landed (0.4.0, then 0.5.0) and were exercised against the IOG ROMs (sections 9 and 12). Open: MCP-31 to MCP-42 (section 12), led by the P0 `--mcp-rom` framing bug MCP-31.** Sections 1 to 7 keep the original problem statements as written; section 8 lists what shipped.

Nothing in this file changes the baserom. Section 5 lists the few requests that belong to the baserom (`src/`), because the repo rules say to extend the tool rather than script around it.

---

## 1. Summary

| ID | Pri | Title | Unblocks (plan experiment) |
|----|-----|-------|---------------------------|
| MCP-01 | P0 | `get_cdl_data` fails (AOT JSON) and has no range or summary mode | R1, R2, S-rows that read CDL |
| MCP-02 | P0 | `get_rom_info` lacks hash, CRC and size; a ROM identity is needed for save states | H0, H1 (every session) |
| MCP-03 | P0 | Save states carry no ROM identity; `load_state_file` accepts a state from another build | H1 (hazard 1) |
| MCP-04 | P0 | `step_instruction` is asynchronous and returns no state; `advance_frame` misreports on a break | C1, B3, any stepped proof |
| MCP-05 | P0 | Script results: no per-script log cursor, no structured result, no unload, no atomic "run N frames and return" | all Lua experiments |
| MCP-06 | P1 | Native `set_breakpoints` has no condition, no hit list, no non-halting mode | A1, A2, W1, C2 (as a Lua fallback) |
| MCP-07 | P1 | Memory types not exposed: CGRAM, SPC RAM, DSP, OAM decode; no file dump | E1, E2, D2, F1 |
| MCP-08 | P1 | Lua cannot write files (`io`/`os` off); large results have no exit | R1, R2, E2, B1 |
| MCP-09 | P1 | Frame-exact input sequences and input recording/replay | B2, B3, B4, P1, M1, M2 |
| MCP-10 | P1 | Fast-forward and run-until (frames, condition, timeout) | R2 (about 40 000 frames), G2 (kill loops) |
| MCP-11 | P1 | `take_screenshot` is a folder poll; no crop, scale, layer or in-memory path | F1, E-family, M-family |
| MCP-12 | P1 | Structured PPU/DMA/HDMA state and decoded OAM | E1, E4, F1, F2, F3 |
| MCP-13 | P1 | Label import and address conversion (names to CPU addresses and back) | every PC-to-routine mapping |
| MCP-14 | P1 | Counter and CDL tools by named ranges (native R1) | R1, UNREF rows |
| MCP-15 | P1 | Ship a verified Lua kit and the warp state machine as recipes | H2, H3, W1, A1 |
| MCP-16 | P2 | Memory snapshot and diff | M1 (OQ-I034-4/5/6), N-family |
| MCP-17 | P2 | Execution trace with filter, window and file output | B3, C1, N4 |
| MCP-18 | P2 | Event subscription (breakpoint, state loaded, script log) | all long runs |
| MCP-19 | P2 | Two-ROM session (original and rebuilt side by side) | M2, P1, V1 |
| MCP-20 | P2 | Capability report and tool self-test | H4 |

Totals: 5 P0, 10 P1, 5 P2. Suggested order is in section 6.

---

## 2. P0 requests

### MCP-01 `get_cdl_data` fails; add range and summary modes
- **Problem (R, S).** The call fails with `JsonSerializerOptions ... TypeInfoResolver`. Cause: `UI/UI.csproj` sets `IsAotCompatible=true` and `JsonSerializerIsReflectionEnabledByDefault=false`, and `ToolGetCdlData` builds a list payload (one `(byte)flag` per ROM byte) whose type the source-generated serializer context does not know. Even when it serializes, one entry per ROM byte (2 MB to 3 MB) is not a usable response.
- **Proposal.**
  1. Register the payload types in the `JsonSerializerContext` (or return a typed record).
  2. Change the tool to `get_cdl_data {type, start?, length?, format}` with `format = "summary" | "ranges" | "bytes_base64"`. `summary` returns counts of code, data, jump target, sub entry, drawn, read and unreached bytes. `ranges` returns merged `[start, end, flags]` runs (so a 2 MB ROM becomes a few thousand rows). `bytes_base64` is the raw flag bytes for a window of at most 64 KB.
  3. Add `reset_cdl`, `save_cdl {path}` and `load_cdl {path}` so a coverage run can be archived and unioned (the plan's R1 needs "the union of several sessions").
- **Acceptance.** After 300 frames on the original ROM, `get_cdl_data {format:"ranges"}` returns a non-empty list whose code runs include the NMI entry offset `0x967C` and whose total code bytes equal `get_cdl_statistics`. `save_cdl` then `reset_cdl` then `load_cdl` returns the same totals.
- **Unblocks.** R1 (coverage), the UNREF member rows, "never read" claims for tables. Lua `emu.getCdlData` still works (plan §1.2) but returns millions of table entries and costs a script round trip per query.

### MCP-02 `get_rom_info` has no hash, CRC or size
- **Problem (S).** `get_rom_info` returns no hash, no CRC and no file size. The plan's H0 asks for "CRC, size and path in the results file", and every result has to name the exact ROM. The Lua call `emu.getRomInfo()` returns `name`, `path` and `fileSha1Hash`, so the data exists in the core.
- **Proposal.** Return `{path, fileSizeBytes, fileSha1, fileCrc32, prgRomSizeBytes, header: {mapMode, speed, title, checksum, complement}, hasHeaderBytes}`. Add the same object to the `load_rom` response, so a session never needs a second call.
- **Acceptance.** For `rebuilt/Illusion of Gaia - Rebuilt.smc` (3,080,192 bytes on disk; `artifacts/crc.json` says `totalSize` 3,062,204, which is the content size, not the file size) the response shows 3,080,192 and a SHA-1 that equals `sha1sum` of the file.
- **Unblocks.** H0, H1 and MCP-03. Interim workaround: the Lua call above, from a one-line script.

### MCP-03 Save states carry no ROM identity
- **Problem (R).** Plan §1.3 hazard 1: a state from an older build loads without error and derails the game (DBR `$AB`, SP `$7FFD`, PC `$40:4044`); every watch on that session returned zero hits and looked like a broken callback. One session was lost to this. The tool cannot tell a stale state from a good one.
- **Proposal.**
  1. `save_state_file {path, note?}` writes a sidecar `<path>.json` with the ROM SHA-1, ROM path, frame count, `sceneCurrent`-style free-form `meta` object passed by the caller, and the server version.
  2. `load_state_file {path, requireRomMatch = true}` compares the sidecar SHA-1 with the loaded ROM and returns an error (`code: "rom_mismatch"`, both hashes) instead of loading. `requireRomMatch=false` keeps today's behaviour. A state with no sidecar loads only with `requireRomMatch=false`.
  3. `list_states {dir}` returns each state with its sidecar fields and a `valid` flag for the loaded ROM. This replaces the hand-maintained `rebuilt/states/INDEX.md` (plan §5) with something that cannot drift.
- **Acceptance.** Save a state on ROM A, load ROM B, `load_state_file` returns `rom_mismatch`. Rebuild with an unchanged gate (same `crc.json`), the new ROM has the same SHA-1 (the gate promises identical bytes), the state loads.
- **Unblocks.** H1 and every `R_` state. It also removes the plan's "all `R_` states are stale after every rebuild" rule: validity becomes a hash comparison.

### MCP-04 Stepping tools are asynchronous and report no state
- **Problem (S).** `ToolStepInstruction` posts the step and returns immediately without registers; `ToolAdvanceFrame` waits on `_stepDoneEvent` and that event is also set when a breakpoint (`CodeBreak`) fires, so `framesAdvanced` can be wrong after a break. A script that does `step_instruction` then `get_emulator_state` races the emulator.
- **Proposal.** Make the step family synchronous and uniform: `step_instruction {count?, over?}`, `step_scanline`, `step_cpu_cycles` and `advance_frame` all wait for completion or a break and return `{stopReason: "done"|"breakpoint"|"timeout"|"error", framesAdvanced, instructionsExecuted, frame, cpu: {k,pc,a,x,y,sp,d,dbr,ps}}`. Add `timeoutMs`.
- **Acceptance.** Set an exec breakpoint at `0x967C`, `advance_frame 5` reports `stopReason: "breakpoint"` and `framesAdvanced < 5`; `step_instruction count=3` returns three distinct PC values in the returned state without a second call.
- **Unblocks.** C1 (the "prove or refute the NMI race by stepping inside the window" step), B3, any stepped check. Until then the plan does not rely on `step_instruction` (it uses Lua callbacks).

### MCP-05 Script I/O: cursor, result, unload, run-once
- **Problem (S, R).** `get_script_log` returns everything since the last clear, shared by all scripts; there is no `unload_script`; scripts stack and persist until `load_rom` (plan §1.3 hazards 2 and 3); the only output channel is `emu.log` text, capped by hand at 200 lines. Every experiment costs several MCP round trips (`load_script`, `advance_frame`, `get_script_log`, `clear`).
- **Proposal.**
  1. `list_scripts`, `unload_script {name}`; `load_script` returns a stable `scriptId`.
  2. `get_script_log {name?, sinceSeq?, max?}` returns `{entries:[{seq, frame, script, text}], nextSeq, dropped}`; the server keeps a ring (default 5 000 lines) and counts what it dropped.
  3. A Lua call `emu.mcp.result(table)` stores a JSON result (one per script, replaced on each call) and a tool `get_script_result {name}` returns it. Histograms, `K:PC` tables and 358-row verdict lists then travel as data, not as capped text.
  4. `run_script {name?, code, frames, timeoutMs, unloadAfter = true}`: load, advance the given number of frames, return log and result, unload. This is the atomic form of one experiment.
- **Acceptance.** `run_script` with the plan's H4 matrix script and `frames: 180` returns the three counters in `result` in one call; a second call with a different script leaves no callback of the first one running (verified by the first script's counter not increasing).
- **Unblocks.** Everything in Campaigns A to W. Cuts the round trips of a W1 batch from about 8 to 1.

---

## 3. P1 requests

### MCP-06 Native breakpoints: condition, hits, non-halting mode
- **Problem (S).** `ToolSetBreakpoints` builds each breakpoint with an empty `Condition`; a hit halts emulation; there is no hit history. Plan §1.1 therefore routes every watch through Lua.
- **Proposal.** `set_breakpoints` accepts per item `{type, start, end, kinds:[read|write|exec], condition?, action: "break"|"count"|"log", maxLogged?}`. `get_breakpoint_hits {id?, sinceSeq?}` returns `{pc, k, frame, value, address, a, x, y}` rows. The `count` action never halts; the `condition` uses Mesen's debugger expression syntax (for example `(value & 0x0200) != 0 && (oldvalue & 0x0200) == 0`; check the exact syntax with `get_capabilities`).
- **Acceptance.** A `count` breakpoint on WRAM `0x36` write grows by about 60 per 60 frames while the emulator keeps running; a condition `value == 0x55` logs only the matching writes.
- **Unblocks.** A1/A2/W1 without a Lua script, and a cross-check of the Lua results (a second, independent mechanism for positive controls).

### MCP-07 Memory types and decoded dumps
- **Problem (S, R).** `ResolveMemoryType` and `GetSupportedMemoryTypeNames` are hard-coded. CGRAM, SPC RAM and DSP registers are not reachable by MCP at all (plan §2.3 lists them as "not exposed"); OAM and VRAM are raw bytes. A palette question (about 40 rows in E2) needs 512 bytes of CGRAM; a sprite question needs decoded sprites.
- **Proposal.**
  1. `list_memory_types` generated from the `MemoryType` enum, with size per type. Add every SNES type (`snesCgRam`, `snesSpriteRam`, `snesVideoRam`, `spcRam`, `spcDspRegisters`, `snesRegister`, `snesSaveRam`) to `read_memory`/`write_memory`/`read_word`/`write_word`.
  2. `read_memory` gets `format = "hex" | "bytes" | "words_le" | "base64"` and a hard cap of 64 KB per call; `dump_memory {type, start, length, path}` writes any size to a file under the results folder (see MCP-08) and returns the SHA-1.
  3. `get_palette_info` (exists) gains `{first, count, format: "rgb555"|"rgb888"}` and returns all 256 colours with the palette index; today the plan has to call it as the CGRAM workaround.
- **Acceptance.** `read_memory {type:"snesCgRam", start:0, length:512}` returns 512 bytes that match the `get_palette_info` colours; a write to `snesCgRam` is visible in the next screenshot.
- **Unblocks.** E1, E2, E4 (palette and HDMA scenes), D2 (SPC RAM, DSP), M4 (VRAM font dump), F1.

### MCP-08 Result files: a sandboxed write path for scripts and tools
- **Problem (S).** `ScriptAllowIoOsAccess` is false, so Lua `io`, `os` and `require` are disabled. A script cannot save a 200-scene census; the only exits are the log and MCP-05's result object.
- **Proposal.** A server option `--mcp-results-dir=<dir>` (default `plans/extracted-audit/mesen2-results/raw/` of the calling repo, or an absolute path given at startup). When set, the Lua table `emu.mcp` gets `writeFile(relativeName, text, append)` that refuses `..`, absolute paths and names with a drive letter; nothing else of `io`/`os` is enabled. Tools that produce large output (`dump_memory`, `save_cdl`, trace export, screenshots) write there too and return the path and SHA-1.
- **Acceptance.** `emu.mcp.writeFile('t.txt','x')` creates `<results-dir>/t.txt`; `emu.mcp.writeFile('../x','y')` returns an error and writes nothing; `io.open` is still nil.
- **Unblocks.** R2 (one line per scene), R1 (coverage tables), E2 (bundle table), B1 (collision census); the verbatim script and raw log required by the result template (plan §8).

### MCP-09 Frame-exact input sequences and replay
- **Problem (S, R).** `set_input` is a persistent override; there is no timed sequence. Running a button for exactly N frames needs `set_input`, `advance_frame N`, `clear_input` (three calls) and no hold of the input across a state load. Frame-exact double taps (OQ-I025-3, run window) and menu navigation are hard to reproduce. The Lua route `emu.setInput` inside an `inputPolled` callback is used by the repository's bootstrap script (`tools/lua/iog_bootstrap.lua`) but is not exposed as a tool.
- **Proposal.**
  1. `play_input {sequence:[{frames, buttons:[..]}...], port?, thenPause}`: executes inside the emulation loop with exact frame timing and returns when done (uses the `inputPolled` hook).
  2. `record_input {start|stop, path}` and `play_input_file {path}` store and replay a button log with the starting state's SHA-1 in the header (MCP-03). Optionally map this onto Mesen2's own movie recorder.
  3. `set_input` accepts `frames` (auto-release) and a `mask` alias for each physical button.
- **Acceptance.** `play_input` with `[{frames:2, buttons:["right"]},{frames:11, buttons:[]},{frames:2, buttons:["right"]}]` from `S01` produces the same player X on two runs; a recorded 600-frame walk replays to the same final `posX`/`posY`.
- **Unblocks.** B2, B3, B4, P1 (double-tap window), M1 and M2 (menu sequences), G2 (repeat attack to kill 200 enemies).

### MCP-10 Fast-forward and run-until
- **Problem (R, S).** R2 warps through 200+ scenes at 180 frames each (about 40 000 frames) and G2 runs kill loops. `advance_frame` runs at emulator speed with video, audio and input disabled by default (`McpServerRunner` sets NoVideo, NoAudio, NoInput) but no throughput figure is reported and there is no turbo or timeout parameter.
- **Proposal.** `advance_frame {frames, turbo?, timeoutMs?}` returns `elapsedMs` and `framesPerSecond`; `turbo` removes the frame limiter. `run_until {condition, maxFrames, timeoutMs}` where `condition` is one of: Lua expression (evaluated each frame, with the kit helpers), `memoryEquals {type,address,size,value,mask}`, `breakpoint`, `pcEquals`. Return the same fields as MCP-04.
- **Acceptance.** `advance_frame 36000 turbo` completes in under two minutes and returns `framesPerSecond`; `run_until memoryEquals sceneCurrent == 0x0001` after a warp write stops on the load frame.
- **Unblocks.** R2 (the whole sweep in a few calls instead of one per scene), warp waiting in H3, G2/G3 loops.

### MCP-11 Screenshots without a folder poll
- **Problem (S).** `ToolTakeScreenshot` triggers a capture and polls the screenshot folder for the file. This is a race on a slow disk and ties the result to the folder setting. Many P3 questions are "what does it look like" and need crops of a region, not 512x448 of everything.
- **Proposal.** Use the in-core screen buffer (`GetScreenBuffer`, the Lua `emu.getScreenBuffer` path) and return PNG bytes in-process. Add `{crop:{x,y,w,h}, scale, path?, layers?}`. `layers` can be `["bg1","bg2","bg3","obj"]` (render with the other layers off by temporarily masking `TM`/`TS` in a copy of the PPU state, or use the debugger tilemap and sprite viewers' renderers). Name the file from the frame count and a caller label so the plan's screenshot paths are deterministic.
- **Acceptance.** Two screenshots taken one frame apart return distinct frame numbers in the response; `layers:["obj"]` of a scene with a HUD and an NPC shows only sprites.
- **Unblocks.** E-family, F1 and F2 (isolating sprites), M1 (name box), M4 (text boxes).

### MCP-12 Structured PPU, DMA and HDMA state; decoded OAM
- **Problem (S, R).** Display questions (E1, E4) need TM, TS, CGWSEL, CGADSUB, window registers, BGMODE, Mode 7 registers and the HDMA channel set at one instant. Today the plan builds these from `get_emulator_state` and Lua `getState` keys; HDMA channel tables and OAM are not available as structured data.
- **Proposal.** `get_ppu_state` (every PPU register as a named field plus derived values: layer enable, color math mode, window logic, Mode 7 matrix), `get_dma_state` (channels 0-7: control, B-bus register, source, indirect bank, line counter, enabled flags, HDMA active), `get_oam {decoded:true}` (128 sprites: x, y, tile, name table, palette, priority, flips, size, on-screen flag), `get_tilemap_info` (exists; add per-BG scroll and base addresses).
- **Acceptance.** In scene `$01` the response shows `BGMODE`, and `get_oam` lists Will's sprites at the on-screen position that matches `posX` minus the camera; in a scene with an HDMA effect, `get_dma_state` shows the channel enabled and `$66` (`hdmaEnableMask`) agrees.
- **Unblocks.** E1, E3 (Mode 7 registers), E4, F1/F2/F3 (read tile and palette values straight from OAM), W12SEL/WOBJSEL rows (OQ-I031-3).

### MCP-13 Label import and address conversion
- **Problem (S, R).** `get_label_address` exists but no labels are loaded. The plan maps a callback `K:PC` to a routine by hand (`rg -n "; \{offset\}"` in the `extract:lt` output). Names have been changing under the audit (IT-04 renamed 37, IT-36 to IT-48 rename several hundred more), so a name list kept in the plan goes stale.
- **Proposal.**
  1. `load_labels {path, format: "mlb"|"sym"|"json", replace}`: Mesen2 reads `.mlb` label files natively. The baserom would export `db-us/names/bankNN.json` plus `artifacts/master-lookup.json` to that format (section 5, B-02).
  2. `resolve_address {cpu?, prgOffset?, wram?}` returns `{cpu, prgOffset, label, labelOffset, bankAlias}` in both directions, and a bulk form `resolve_addresses [..]` (a W1 log has dozens of `K:PC` values).
  3. `get_callstack`, `get_disassembly` and trace output use the labels.
- **Acceptance.** After `load_labels` of the exported file, `resolve_address {cpu:"80:8381"}` returns `NmiHandler` (or the current name) with the offset; `get_callstack` inside an NMI callback shows names.
- **Unblocks.** The PC-to-routine step of every W1/A1/A2/G1 result. Label exports are regenerated after each names iteration, so the mapping never lags the files.

### MCP-14 Counters and CDL by named ranges (native R1)
- **Problem (S, D).** R1 asks for exec counts and CDL flags of hundreds of labels (UNREF rows, about 120 palette bundles). The plan does this in a Lua loop over `emu.getAccessCounters`, which returns a table of one entry per ROM byte.
- **Proposal.** `get_access_summary {type, ranges:[{name,start,end}], counters:[exec|read|write], cdl:true, nonzeroOnly?}` returns per range: exec/read/write counts (total and first/last clock), CDL flags union, and a verdict hint (`never_accessed`). `reset_access_counters` is exposed as a tool (the Lua `emu.resetAccessCounters` is unverified, plan §1.2). Allow `ranges` to be a file path (a JSON list the baserom exports).
- **Acceptance.** For ranges `{NmiHandler}` and a range of unreachable bytes, the response gives a positive exec count for the first and `never_accessed` for the second.
- **Unblocks.** R1 and all UNREF/PBUNDLE reachability rows in one call per session.

### MCP-15 Verified Lua kit and recipes shipped with the server
- **Problem (S).** The repository already has a warp state machine with an end-to-end test (`tools/lua/iog_bootstrap.lua`, `iog_warp_probe.lua`, `tools/mcp_iog_e2e_test.py`) but the plan has to paste the kit and a short warp recipe into every script because `load_script` takes one string. A thin recipe is the wrong one for scenes that need the scene-title dismissal and the input lock (plan H3).
- **Proposal.** Ship `tools/lua/lib/mesen_kit.lua` (capped log, `once`, byte/word helpers, `watch(lo,hi,kind,fn)`, bit-change watch, ring buffer, CGRAM dump, `pcLabel`) and `iog_kit.lua` (the warp state machine with `warp{scene, x, y, facing, flags}`, event-flag setter, scene-title dismissal, form/HP/item setters). `load_script` gets `includes:["mesen_kit","iog_kit"]`, resolved from the server's lib folder, so scripts stay short. Add `list_recipes` and `run_recipe {name, args}` for the ones used as is (`warp`, `census_pc`, `exec_coverage`).
- **Acceptance.** `run_recipe warp {scene:1}` reaches `sceneCurrent == 1` with the title banner gone and `joypadMaskStd` (`$065A`) clear; the H4 matrix from the plan runs from a 10-line script plus the includes.
- **Unblocks.** H2, H3, and every experiment's first step. It removes the largest source of copy errors in the plan.

---

## 4. P2 requests

### MCP-16 Memory snapshot and diff
- **Problem.** Several questions ask what an action overwrites (OQ-I034-4 inventory cache slots, OQ-I034-5 sine tables, OQ-I034-6 thinker waits, OQ-I042-6 exit side effects). Today this is a hand-written Lua copy loop.
- **Proposal.** `snapshot_memory {name, type, ranges?}` and `diff_snapshots {a, b, ranges?, maxRows}` returning changed runs `[start, end, oldHex, newHex]`. A WRAM snapshot is 128 KB, so keep a small number in memory.
- **Acceptance.** Snapshot before and after opening the inventory in `S09` and the diff lists `$0AB4`-area changes and no change in `$7F:C000-$DFFF` (collision layer).

### MCP-17 Execution trace with window, filter and file output
- **Problem (S).** `get_execution_trace` is unverified and its filter set is unknown. B3, C1 and N4 need "the instructions between two events", for example the stores to `$7F0C09` and `$7F0C07` and any NMI in between.
- **Proposal.** `start_trace {pcRanges?, condition?, maxLines, path}` and `stop_trace` write to the results folder in the Mesen trace format with registers, flags and the frame number; `get_execution_trace` returns the last N lines from a ring. Triggered mode: start on an exec breakpoint, stop on another.
- **Acceptance.** A trace started at the first and stopped at the second adhoc-DMA store write shows whether `NmiHandler` entry lies between them.

### MCP-18 Event subscription
- **Problem (S).** `McpServerRunner` already emits `notifications/mesen/event`. Check whether the event set is documented and selectable; a client that does not poll otherwise never sees a break.
- **Proposal.** `subscribe_events {types:[breakpointHit, romLoaded, stateLoaded, frameEnd?, scriptLog, error]}` with a documented payload per type. A coarse `frameEnd` every N frames is enough.
- **Acceptance.** After `run_until`/`advance_frame` with a count breakpoint, one `breakpointHit` event arrives with the same fields as MCP-06's hit row.

### MCP-19 Two ROMs in one session
- **Problem (R).** M2, P1 and V1 compare the original and the rebuilt ROM (button remap, `SceneMetaLoad`, dictionary). The server holds one ROM; every comparison is a `load_rom` with a state swap, and per-ROM script state is wiped.
- **Proposal.** Either named sessions (`load_rom {slot:"orig"|"rebuilt"}`, every tool takes `slot`) or documented support for two server entries (`mesen2-orig`, `mesen2-rebuilt`) with separate `--mcp-savestatepath` folders (section 5, C-01 is the configuration half). Native `compare_runs {inputFile, watch:[...]}` that plays the same input on both and reports the first divergence of a watched value is a stretch goal.
- **Acceptance.** The same `play_input` file produces different `joypadMaskStd` bits for the remapped button on the two slots in one conversation.

### MCP-20 Capability report and tool self-test
- **Problem (R).** The plan's H4 spends a session discovering which of `emu.write`, `emu.setInput`, SPC callbacks, `emu.createSavestate` and `step_instruction` work. `get_capabilities` exists but its content is not defined as a contract.
- **Proposal.** `get_capabilities` returns `{serverVersion, mesenVersion, tools:[{name, status}], lua:{functions:[..]}, flags:{video, audio, input, scriptIo}, limits:{maxReadBytes, logRing}}`. `self_test` loads an embedded 64 KB test ROM (or any loaded ROM) and runs the H4 matrix (write callback, read callback, exec callback, `emu.write`, `setInput` in `inputPolled`, savestate round trip, CDL, breakpoint) and returns pass/fail per feature.
- **Acceptance.** `self_test` on the loaded IOG ROM reports the same pass/fail table as the plan's H4 results file.

---

## 5. Requests outside the MCP server

These belong to the baserom or the configuration. Per the repo rules the baserom side is a change to `src/` with documentation, not a throwaway script, so it needs the user's go-ahead.

| ID | Where | Request | Why |
|----|-------|---------|-----|
| B-01 | baserom `src/` (`rebuild`) | Option to write the ROM to a named path (for example `rebuilt/variants/tagged.smc` and `rebuilt/variants/plain.smc`) and print its SHA-1, plus `crc.json` mode field (IT-26 / IT-27 may already add the mode field). | Until IT-27 makes the plain and tagged builds identical, the button-remap rows (OQ-I044-4, OQ-I057-1, OQ-I028-1) must be run on both (plan §2.1). Today `rebuild` always overwrites `rebuilt/Illusion of Gaia - Rebuilt.smc`. |
| B-02 | baserom `src/` | `export labels` command: `names/bankNN.json` and `artifacts/master-lookup.json` to Mesen2 `.mlb` (one file per ROM variant: original keyed by decimal offset, rebuilt by master-lookup). | Source for MCP-13. Regenerated after every names iteration. |
| B-03 | baserom `src/` (an export command) | Export the valid scene id list and, where known, the event flags a scene needs, as one JSON file that the Lua kit can embed. | R2 and B1 iterate over scene ids; the plan currently says "the 200+ ids from the scene table" and each agent would have to derive the list. |
| C-01 | `C:\Users\azare\.cursor\mcp.json` | Add a second entry (`mesen2-mcp-rebuilt`) with its own `--mcp-savestatepath=` and `--mcp-rom=` once MCP-19 is not available. Keep `--mcp-video` off by default and use it only for screenshot sessions. | Two-ROM comparisons without losing script state. |
| C-02 | `mcp.json` / docs | Document `--mcp-savestateslot=` and `--mcp-savestatepath=` in the plan's H1 once MCP-03 lands. | State library location. |

---

## 6. Suggested order

1. **Week 1 (before session 2):** MCP-02, MCP-03, MCP-05, MCP-01, MCP-04. These make results trustworthy (ROM identity, stale states, race-free stepping) and cut the per-experiment cost.
2. **Week 2:** MCP-13 with B-02, MCP-15, MCP-10, MCP-08. After these the W1/A1/R2 sessions are one to three calls each.
3. **Then as the matching campaign comes up:** MCP-09 (B and P campaigns), MCP-07 and MCP-12 and MCP-11 (E, F, M), MCP-14 (R1), MCP-06.
4. **Optional:** MCP-16 to MCP-20.

Minimum viable set if time is short: MCP-02, MCP-03, MCP-05 and MCP-13. Everything else has a workaround in the plan (Lua callbacks, `rg` on the `extract:lt` output), at the cost of more calls and more hand mapping.

---

## 7. How the plan degrades without each request

| Request | Workaround used in the plan today |
|---------|-----------------------------------|
| MCP-01 | Lua `emu.getCdlData`, `emu.getAccessCounters`; `get_cdl_statistics` for totals |
| MCP-02 | `emu.getRomInfo().fileSha1Hash` in a one-line script; file size from the shell |
| MCP-03 | Manual `states/INDEX.md` with the ROM SHA-1; validity test after every load (H1 rule 3) |
| MCP-04 | Lua exec callbacks only; no stepping proof |
| MCP-05 | Capped `emu.log`, reuse script names, `load_rom` to wipe |
| MCP-06 | Lua `addMemoryCallback` |
| MCP-07 | `emu.read` on `snesCgRam` inside a script; `get_palette_info` |
| MCP-08 | Log lines, split into 200-line chunks, copied into the result file |
| MCP-09 | `set_input` / `advance_frame` / `clear_input` triplets; `emu.setInput` in `inputPolled` (used by the bootstrap script) |
| MCP-10 | One `advance_frame` per scene; accept the wall-clock |
| MCP-11 | `take_screenshot` full frame, crop by eye |
| MCP-12 | Lua `getState` keys, `read_memory` on `ppu` and `oam` |
| MCP-13 | `rg -n "; \{offset\}"` over the `extract:lt` output; `artifacts/master-lookup.json` |
| MCP-14 | A Lua loop over the counters (plan §6.2) |
| MCP-15 | Paste the kit and the bootstrap text into each script |

## 8. Status (server 0.4.0)

All requests are implemented in `C:/Work/mesen2-mcp` (full tool reference: its `README.md`, behaviour per feature: `MCP_TOOLS_CONTRACT.md`). Tests: `tools/mcp_p0_test.py`, `mcp_week2_test.py`, `mcp_week3_test.py`, `mcp_iog_e2e_test.py`.

| Id | Tools |
|----|-------|
| MCP-01 | `get_cdl_data` (summary, ranges, bytes), `reset_cdl`, `save_cdl`, `load_cdl` |
| MCP-02, 03 | `get_rom_info` / `load_rom` hash fields; `save_state_file` sidecar, `load_state_file` (`rom_mismatch`), `list_states` |
| MCP-04, 05 | Synchronous stepping with `stopReason` and `cpu`; `run_script`, `get_script_result`, `get_script_log` cursor, `list_scripts`, `unload_script` |
| MCP-06 | `set_breakpoints` (`condition`, `action: break|count|log`), `get_breakpoint_hits` |
| MCP-07 | `list_memory_types`, `read_memory` (types and formats), `dump_memory`, `get_palette_info` |
| MCP-08 | `emu.mcp.writeFile`, results folder (`--mcp-results-dir=`) |
| MCP-09 | `play_input`, `record_input`, `play_input_file`, `set_input` (`buttons`, `mask`, `frames`) |
| MCP-10 | `turbo` on stepping tools, `run_until` |
| MCP-11 | `take_screenshot` (in-process; crop, scale, path, label, layers) |
| MCP-12 | `get_ppu_state`, `get_dma_state`, `get_oam`, `get_tilemap_info` |
| MCP-13 | `load_labels`, `list_labels`, `resolve_address`, `resolve_addresses` |
| MCP-14 | `get_access_summary`, `reset_access_counters` |
| MCP-15 | `includes: ["mesen_kit", "iog_kit"]`, `list_recipes`, `run_recipe` (`warp`, `census_pc`, `exec_coverage`) |
| MCP-16 | `snapshot_memory`, `diff_snapshots`, `list_snapshots`, `delete_snapshot` |
| MCP-17 | `start_trace`, `stop_trace`, `trace_between` |
| MCP-18 | `subscribe_events` |
| MCP-19 | `slot` on every tool, `list_slots`, `switch_slot`, `compare_runs` |
| MCP-20 | `get_capabilities`, `self_test` |

Baserom items (documented in `docs/mesen2-exports.md`): B-01 `npm run rebuild -- <in> <out.smc> --artifacts-dir=<dir> --mode=<tagged|plain>` (prints the SHA-1; `crc.json` gains `mode` and `sha1`); B-02 `npm run export -- labels` (`artifacts/labels/iog-original.mlb`, `iog-rebuilt.mlb`; load with `load_labels`); B-03 `npm run export -- scenes` (`artifacts/scenes.json`, flags from `db-us/scene-flags.json`). C-01: the `mesen2-mcp-rebuilt` entry exists in the user `mcp.json`; C-02: the startup flags are in the server README (`--mcp-savestatepath=<file>` loads a state file, `--mcp-savestateslot=<1-10>` a numbered slot).

Changes the plan should take into account:
- `--mcp-savestatepath=` takes a **state file**, not a folder. Keep the state library under `rebuilt/states/` and pass files to `load_state_file`.
- `emu.createSavestate` works only inside an exec memory callback (the server's statement). Verified: a save at the third NMI exec and a `emu.loadSavestate` at the tenth NMI, both inside the callback, restored `$36` from 115 to 108 (+1 frame later 109).
- The native Lua log keeps 500 rows; a script that logs more than 500 rows in one frame loses rows. Use `emu.mcp.result` or `emu.mcp.writeFile` for bulk output.

---

## 9. Verification of server 0.4.0 (2026-10-29, win-x64 build, against the IOG ROMs)

Run through `mesen2-results/harness/mcp_client.py` in phase 2 and again in phase 3 (DLL rebuilt 2026-10-29 21:35, same version string 0.4.0; the Cursor registration `user-mesen2-mcp-dev` is now correct, T-01 resolved, 81 tools = 80 + `mcp_auth`). Evidence: `mesen2-results/tool-issues.md`, `B2_special_tiles_20261029.md`, `harness/README.md`. All 80 tools are present; `self_test` passes 17/17.

| Request | Verified | Evidence |
|---------|----------|----------|
| MCP-01 | yes | `get_cdl_data` `summary` (`counts`: code 22,414, data 227,108, unreached 1,848,510 of 2,097,152 in a short South Cape session), `ranges` (paged with `nextStart`, `flagMask`), `get_cdl_statistics` agrees on `codeBytes` |
| MCP-02 | yes | `load_rom`/`get_rom_info` return `fileSha1`, `fileCrc32`, `fileSizeBytes`, header; O = `38de0c84...`, R = `795c7a8c...` |
| MCP-03 | yes | sidecar `<state>.json`, `list_states` `valid`, `rom_mismatch` for the wrong ROM, and (phase 3) `no_sidecar` for a state without one (override: `requireRomMatch:false`); frame counter and meta are in the sidecar |
| MCP-04 | yes | `step_instruction count=5 over=true` returns `instructionsExecuted: 5` and `pcs: ["82:8051","00:800B","80:82F8",...]`; `advance_frame` returns `stopReason: "breakpoint"` with a `break` object and `framesAdvanced: 1` |
| MCP-05 | yes | `run_script`, `load_script`/`list_scripts`/`unload_script`, `get_script_log {name, max, sinceSeq}`, `get_script_result`. `emu.mcp.done()` only in a callback (T-04) |
| MCP-06 | yes | `action: count|log|break` (`halt` is rejected, T-18), `condition` (count/log: Lua names `value`, `oldvalue`, `address`, `pc`; break: native expression; both verified), `get_breakpoint_hits`: count write `$36` = 119 in 120 frames, count exec ROM offset 33528 = 119, log of `$09EC` writes with `pcHex`; halting exec works at `snesMemory 0x8082F8` and `snesPrgRom 33528` (T-06 on the alias) |
| MCP-07 | yes | `read_memory` on `snesCgRam`, `snesVideoRam`, `spcRam`, `snesSpriteRam`, `snesPrgRom`, `snesMemory`; formats `bytes`, `words_le`, `base64`, `hex`; `list_memory_types`; `dump_memory` verified (8,192 bytes at `0x1C000`, SHA-1 in the reply) |
| MCP-08 | yes (partial) | `--mcp-results-dir` honoured by screenshots, traces, recordings, slot states; `emu.mcp.writeFile(name, text, append?)` verified (the file appears in the results dir; `io`/`os` nil) |
| MCP-09 | yes | `play_input` (25 frames, `segmentsPlayed`), `record_input` start/stop with `startState`, `play_input_file`: a 50-frame replay ended on identical `posX`, `posY` and `$36` |
| MCP-10 | yes | `turbo` 180 to 370 fps; `run_until` with `lua` (includes inside `condition`, T-08), `pcEquals`, `memoryEquals` (met false returns `stopReason: "done"`) |
| MCP-11 | yes | `take_screenshot` with `layers:["obj"]`, `crop`, `scale`, `label`, `returnImage:false`; files `screenshots/<label>_<frame>.png` with SHA-1 |
| MCP-12 | yes | `get_ppu_state` (`derived`: bgMode, layers, colorMath, oam), `get_oam {onlyOnScreen, first, count}`, `get_palette_info {first,count,format}`, `get_tilemap_info`, `get_dma_state` keys |
| MCP-13 | yes | `load_labels` (`.mlb`, `replace`), `resolve_address`, labels in `get_disassembly` (`NmiHandler:`) and `get_callstack` (`MainLoop`, `VBlankWaitAndJoypad+0x10`, `NmiVector`) |
| MCP-14 | yes | `get_access_summary` rows by `label` or `start`/`end`: `NmiHandler` (16 bytes) `exec: 960` in 60 frames (the sum of 16 per-byte counters of 60; phase 2's "sum" reading was right, phase 3's "first byte" reading came from passing `{start, length}`, which counts one byte: T-15 corrected, T-29), `execBytes 16`, `execFirstByte 60` in 0.5.0; `verdict: accessed`, `cdlFlags 53`; an untouched range `never_accessed` |
| MCP-15 | yes (with T-03) | `includes` by module name, `list_recipes`, `run_recipe warp {scene:10, flags:[63]}` reached `$0A` in 359 frames from an in-game state and 358 from a fresh boot |
| MCP-16 | yes | `snapshot_memory` (SHA-1) and `diff_snapshots` with `ranges` and `maxRows` |
| MCP-17 | yes | `trace_between` wrote `8082F8  378    8082F8 PHP  A:0002 X:0000 ... P:nvMxdIzC` lines; `start_trace`/`stop_trace` verified (`pcRanges`, `maxLines`, `useLabels`, trimmed file with SHA-1); `get_execution_trace` returns no rows when paused |
| MCP-18 | yes | `subscribe_events {types, frameEvery}`: nine event types listed in the reply; count breakpoints emit 178 payload-free `breakpoint_hit` notifications in 65 frames (`breakpointId -1, address 0`), see MCP-29 |
| MCP-19 | yes | `load_rom {slot}`, `list_slots`, `switch_slot`, `compare_runs` between slots `O` and `R` with `startStates` and `watch` (found a one-frame shift of `displayModeFlags` bit 3 on a `B` press, positions identical for 90 frames); T-10 |
| MCP-20 | yes | `get_capabilities`, `self_test` 17/17 |

Verified in phase 3 as well: `set_cpu_state` (`x`, `y`), `get_profiler_data`, `get_timing_info`, `get_tilemap_size`, `step_cpu_cycles`, `revert_rom_changes`, Lua SPC exec and read callbacks (`emu.cpuType.spc` on `spcRam`: 7,001 hits in 8 frames), count and halting conditions, the `no_sidecar` refusal of `load_state_file`.

Verified as **defective**: `rewind` (T-13, T-14: the distance is not what `seconds` says and the session's Lua SPC callbacks stay dead afterwards) and one hang of `step_scanline` (T-12). (Both statuses changed in 0.5.0: section 12.) Exercised in phase 4: `record_input` plus `play_input_file` (replay identical), `get_cdl_data` summary; still not exercised: `get_cdl_data` after `load_cdl`, `speed` of `play_input_file`, HDMA tools beyond `get_dma_state` keys.

---

## 10. New requests found while building the harness

| ID | Pri | Where | Request | Evidence |
|----|-----|-------|---------|----------|
| MCP-21 | P1 | server | Accept several lib folders (`--mcp-lib-dir` repeatable, or `;`-separated) and let `includes`/`run_recipe` search project folders after the server's own. A recipe folder next to the project kit should also be searched. | T-03: a project kit (`gaia_kit.lua`) and the shipped `mesen_kit`, `iog_kit` and `recipes/` cannot be on the path together; today they are copied (3 modules + 3 recipes) and drift when the server changes. |
| MCP-22 | P1 | server + `mcp.json` | (a) Default `--mcp-results-dir` to a folder outside OneDrive (or `<cwd>/mesen2-results`). (b) Print the effective lib dir, results dir and server version in `get_capabilities`. (c) Put the `win-x64` build where `mcp.json` points, or make `net8.0\` the self-contained output, so the registered path is the current one. | T-01, T-02: the registered DLL was 0.1.0 while the tests run on 0.4.0. |
| MCP-23 | P2 | server docs | Document that `emu.mcp.done()` and `kit.finish()` work only in a callback, or allow them at script load (end the run at once). | T-04 |
| MCP-24 | P2 | server | Return JSON from `read_word`, `write_word`, `write_memory` as `{value, hex}` (or document the text form). `read_memory format:"bytes"` returns an object `{"bytes":[...]}`: document it next to the other formats. | T-05 |
| MCP-25 | P2 | server | In `get_breakpoint_hits` add the memory-type offset (WRAM offset, PRG offset) next to the CPU alias address (a WRAM write by code running with DBR `$81` is reported as `0x8109EC`). For exec breakpoints on `snesMemory`, document that the bank alias is part of the address (`$00:82F8` and `$80:82F8` are different breakpoints) and recommend `snesPrgRom`. | T-06 |
| MCP-26 | P1 | `iog_kit` / recipe | `warp` option `quick = true` (write `sceneNext` only, keep the default spawn, set the listed flags first, wait for the scene and the banner) and let `x`, `y` be optional. Today `warp` always writes `warpDest*` with Edward's Castle defaults (x `0x60`, y `0x370`), so a scene other than `$0A` needs known coordinates. Document that quick warp does not work from the title (`$FC`). | T-07: quick warp reached `$15` (spawn 728, 688) and `$08` (88, 176) from South Cape in 300 frames with no coordinates. |
| MCP-27 | P0 | server | **`timeoutMs` must be honoured and a hung stepping call must not kill the host.** `step_scanline count=10` blocked 251 s (default `timeoutMs` 10000) and the host then closed stdout; the call returned at once in about 25 isolated trials, so the cause is session state. Add a watchdog thread per call (return `{error:{code:"timeout"}}` and pause), and log the last three tool calls in the host log. Also: `step_scanline` reports `framesAdvanced: 0` (document, or report scanlines advanced). Document `get_access_summary.exec` for a multi-byte range (T-15). | T-12, T-15 |
| MCP-28 | P1 | server | **`rewind`**: make `seconds` mean what it says (or return the frames rewound), and keep Lua callbacks alive: after a `rewind` every Lua SPC exec callback registered later got 0 hits and the same script ran 90 times slower (3.7-8.8 s instead of 0.04 s). If the rewind buffer needs normal speed, say so in the reply (`rewindAvailableFrames`) and refuse instead of moving 3 frames. | T-13, T-14 |
| MCP-29 | P2 | server | `subscribe_events`: do not emit `breakpoint_hit` for `count`/`log` breakpoints (or carry the breakpoint name and the real address/value). Today they flood the client with events whose `breakpointId` is -1 and `address` 0. | phase 3 matrix |
| MCP-30 | P2 | server | `get_capabilities` should work without a ROM (it fails with "No ROM is running"); `get_label_address` should return JSON (`{address, hex}`) like the other tools (MCP-24). | T-16 |
| B-04 | P1 | baserom `src/` | `npm run export -- labels --master-lookup=<file> --out=<file.mlb>` (the `exportLabels` API already has the option) so a variant build with `--artifacts-dir=temp/plain` gets its own label file. | T-09 |
| B-05 | P2 | baserom docs | State in `docs/mesen2-exports.md` that a ROM and `crc.json` built before B-01 have no `mode`/`sha1`; a session that needs a mode must re-run `npm run rebuild`. Ask the user to re-run it now: the main R ROM (16:32) is older than the newest `extracted/` edits. | T-09 |

Priorities for the plan: MCP-21 and MCP-26 save the most work (every session starts with a warp); MCP-22 removes the setup step of a session. Everything else has a workaround recorded in `tool-issues.md`.

## 11. Status of section 10 (server 0.5.0)

Implemented in `C:/Work/mesen2-mcp` (behaviour: its `MCP_TOOLS_CONTRACT.md`, section "server 0.5.0"; test: `tools/mcp_week4_test.py`, 45 checks). Set `mcp-version.txt` to 0.5.0 (the registered build must be rebuilt in Release and the client restarted).

| Id | Done | Notes |
|----|------|-------|
| MCP-21 | yes | `--mcp-lib-dir=<dir>[;<dir>...]`, repeatable. Modules `<dir>/*.lua`, recipes `<dir>/recipes/*.lua`; searched after the server's own `lua/lib`, first match wins. `list_recipes` merges and shows `dir` per entry. Point it at the folder that holds `gaia_kit.lua` (and its `recipes/` folder). |
| MCP-22 | yes | (a) default results folder `%LOCALAPPDATA%\Mesen2Mcp\results`; (b) `get_capabilities` shows `serverVersion`, `resultsDir`, `resultsDirCloudSynced`, `libDirs`, `hostPath`; (c) the host project builds to `McpHost/bin/<Configuration>/net8.0/` for every RuntimeIdentifier (no `net8.0/win-x64/` any more). |
| MCP-23 | yes | `emu.mcp.done()` and `kit.finish()` also work at script load (the run ends at once, `script_done`). |
| MCP-24 | yes | `read_word`, `write_word`, `write_memory` return JSON `{value, hex, ...}`; `read_memory format:"bytes"` is documented as `{memoryType, address, length, truncated, bytes[]}`. **Breaking for text parsers** (`"0x1234 (4660)"`). |
| MCP-25 | yes | `get_breakpoint_hits` rows have `memType`, `absType`, `absOffset`, `wramOffset`, `prgOffset`, `sramOffset`, `pcPrgOffset`, `pcWramOffset`. Alias semantics and the `snesPrgRom` / `snesWorkRam` recommendation are in the README. `kit.wramOffset(addr)` for Lua callbacks (T-11). |
| MCP-26 | yes | `warp` option `quick = true` (writes `sceneNext` only, default spawn, flags set first, waits for scene and banner); x/y optional (a scene other than `$0A` without x/y uses quick automatically). Verified from the title: scene `$15` and `$08` reached from a fresh start. |
| MCP-27 | yes | Per-call watchdog (`timeoutMs` + 15 s, else 120 s): `{error:{code:"timeout"}}`, emulator paused, last calls on stderr and in `recentCalls`; other calls get `busy` until the stuck call ends; `get_server_status` shows it. `step_scanline` reports `scanlinesAdvanced`/`scanline`. `get_access_summary` rows add `execBytes`, `execFirstByte`, `hottest` and the description explains that `exec` is the sum of per-byte counters and only opcode bytes are marked (T-15). The 251 s hang itself could not be reproduced; the watchdog turns it into an error. |
| MCP-28 | yes | Cause found: the sub-10-second path started the hold-to-rewind mode and never stopped it, so the core stayed in rewind mode (slow frames, 90x slower scripts, dead callbacks, 3-31 frame moves). `rewind {seconds\|frames, allowPartial?}` now uses only the instant 10 s / 1 min history jumps and replays the surplus forward: it lands exactly `seconds * fps` frames earlier (checked: 3 s = 180 frames, 45 frames = 45). It replies `framesRewound`, `frameBefore`, `frameAfter`, and refuses with `rewind_unavailable` / `rewind_insufficient_history` (`rewindAvailableFrames`; the state is restored). Lua exec callbacks and speed are normal afterwards (tested). |
| MCP-29 | yes | `breakpoint_hit` is sent only for halting breakpoints and exception breaks (step completions and temporary breakpoints were the `-1`/address 0 events). Count/log breakpoints send their own event with `breakpointId`, `name`, `count`, `newHits`. |
| MCP-30 | yes | `get_capabilities` and `list_recipes` work without a ROM; `get_label_address` returns `{label, address, hex, memoryType, cpuAddress, cpuAddressHex, length}`. |
| B-04 | yes | `npm run export -- labels --master-lookup=<file> --out=<file.mlb>` writes only the rebuilt labels of that lookup (see `docs/mesen2-exports.md`). |
| B-05 | yes (docs) | `docs/mesen2-exports.md` says that a ROM/`crc.json` built before B-01 lacks `mode`/`sha1`. **Action for you: run `npm run rebuild` again** (the main R ROM is older than the newest `extracted/` edits), then `npm run export -- labels`. |

### Tool issues T-01..T-19 after 0.5.0

| Issue | Status |
|-------|--------|
| T-01, T-02 | fixed by MCP-22 (build location; `get_capabilities` shows the version and folders). |
| T-03 | fixed by MCP-21. |
| T-04 | fixed by MCP-23. |
| T-05 | fixed by MCP-24 (JSON). |
| T-06, T-11 | fixed by MCP-25 (offsets in hits, `kit.wramOffset`, alias note). |
| T-07 | superseded by T-17; quick warp is now an option (MCP-26). |
| T-08 | fixed: `run_until` accepts `includes` at the top level (and inside `condition`). |
| T-09 | B-04 and B-05 (re-run `npm run rebuild`). |
| T-10 | by design, documented: `load_rom {slot}` makes the slot active; call `switch_slot` first. |
| T-12 | not reproducible; guarded by the watchdog (MCP-27). |
| T-13, T-14 | fixed by MCP-28. |
| T-15 | documented, plus `execBytes`, `execFirstByte`, `hottest`. |
| T-16 | fixed by MCP-30. |
| T-17, T-19 | informational (quick warp from the title works; states without a sidecar need `requireRomMatch:false`). |
| T-18 | `action:"halt"` is accepted as an alias of `break`. |

---

## 12. Verification of server 0.5.0 and new requests (2026-10-30)

Run with `harness/probe_050.py` (five sessions, about 50 s) and `harness/phase0_matrix.py` against `C:\Work\mesen2-mcp\McpHost\bin\Release\net8.0\MesenMcpHost.dll` (built 00:23, `get_capabilities` 0.5.0, Mesen 2.1.0, 81 tools incl. `get_server_status`, `self_test` 17/17). Data: `mesen2-results/raw/probe_050_20261030.json`, `phase0_matrix_20261030.json`; write-up: `mesen2-results/Probe_050_20261030.md`. The B2 scenario re-run on both ROMs is bit-identical to the 0.4.0 data.

### 12.1 Section 11 checked

| Id | Result on the build | Remark |
|----|---------------------|--------|
| MCP-21 | verified | `;`-separated and repeated `--mcp-lib-dir` both work; `list_recipes` shows `dir`; `gaia_kit` chains `mesen_kit` and `iog_kit` from the server's folder; the vendored copies were deleted. A **missing** lib dir is ignored silently (MCP-36) |
| MCP-22 | **partial** | (a) default results dir `%LOCALAPPDATA%\Mesen2Mcp\results` verified; (b) `get_capabilities` fields verified; (c) the build lands in `net8.0\`, but the old `net8.0\win-x64\` folder stays with a 0.4.0 DLL and `mcp.json` entries `mesen2-mcp` and `mesen2-mcp-rebuilt` still point at it (MCP-41) |
| MCP-23 | verified | `done()` and `kit.finish()` at load end the run with `script_done` |
| MCP-24 | verified | JSON from `read_word`, `write_word`, `write_memory`, `get_label_address`; the harness client adapted |
| MCP-25 | **partial** | `kit.wramOffset` verified (`0x81065A` gives `0x065A`, `0x7F0001` gives `0x10001`). The offset fields of `get_breakpoint_hits` carry the CPU alias, not the offset, for mirrored accesses (T-21, MCP-32) |
| MCP-26 | verified | `quick:true` and auto-quick; from the title (frame 420) too. `ok:true` can still mean a locked joypad (MCP-42) |
| MCP-27 | verified except the hard watchdog | `timeoutMs` honoured (`advance_frame` huge frames with 800 ms gave `timeout` at 0.81 s; `step_scanline` and `run_until` too); `get_server_status`; `scanlinesAdvanced`; `execBytes`/`execFirstByte`/`hottest`. A Lua `while true do end` is cut by the script limit and not by the watchdog; nothing hung, so the 120 s path was not reached. `get_server_status` cannot answer during a call (T-25, MCP-37) |
| MCP-28 | verified | exact distance (`seconds:2` gives 120, `frames:30` gives 30), refusals, `allowPartial`, SPC callbacks alive. Slow: 4.7 to 9 s (T-28, MCP-39) |
| MCP-29 | verified | halting events carry `source/address/value`; count events `{name, count, newHits}`; step completions send nothing |
| MCP-30 | verified | `get_capabilities` without a ROM; JSON label address |
| B-04, B-05 | not run | `rebuilt/Illusion of Gaia - Rebuilt.smc` is still the 16:32 build of 2026-10-29: **re-run `npm run rebuild`** |

### 12.2 New defects and requests

| ID | Pri | Where | Request | Evidence |
|----|-----|-------|---------|----------|
| MCP-31 | **P0** | server | **Frame the stdio output correctly under `--mcp-rom`.** The `game_loaded` notification is written before the first request, with `Content-Length:` framing and no newline, glued to the `initialize` reply; the reader and writer in `McpTypes.cs` (`McpStdioTransport`) disagree. Use one framing for every message (newline-delimited, as the replies are), emit startup events only after `initialize`, and add a test to `mcp_smoke_test.py` that starts the host with `--mcp-rom`. | T-20 |
| MCP-32 | P1 | server | Make `absOffset`/`wramOffset`/`prgOffset`/`sramOffset` in `get_breakpoint_hits` real offsets: resolve the CPU address through the mapper (mirror, bank `$80` to `$00`, `$7E/$7F`). Today `0x8109EC` gives `wramOffset 8456684` and an exec hit at `$80:82F8` gives `prgOffset 8422136`; only `pcPrgOffset` is right. Add a test for a mirrored write. | T-21 |
| MCP-33 | P1 | server | **Validate arguments.** Reject a wrong type, a non-positive `frames`/`count`, an out-of-range `write_word` (above `0xFFFF`) or byte (above 255), unknown keys of `set_cpu_state`, `start > end` and a bad `condition` of a count breakpoint, `record_input startState:true`, and a `read_memory` above the 65,536 limit (return `truncated:true`); report both `frames` and `seconds` of `rewind` as an error. Today each succeeds silently with a coerced value. | T-27 |
| MCP-34 | P1 | server | **Script failures must be visible.** Return `stopReason: script_error`, `isError:true` and `errors:[{line,message}]` for a syntax error or a runtime error; stop the script after the first runtime error in a callback (or after N), and deduplicate repeated messages (one `re:1: boom` per frame today). Report the "Maximum execution time exceeded" cut as `script_timeout`. | T-24 |
| MCP-35 | P2 | server | `revert_rom_changes` must undo only ROM writes (or be renamed and documented as "undo every write"). It counted every `write_word` and restored an older WRAM value. | T-23 |
| MCP-36 | P2 | server | **Startup failures must be reported, not fatal and silent.** A missing state file or slot, both state flags, an invalid `--mcp-savestateslot` and a missing `--mcp-lib-dir` folder should go to stderr and to `startupWarning` in `get_capabilities` as well as `get_rom_info`; the host must stay up. | T-22 |
| MCP-37 | P2 | server | Answer `get_server_status` (and `get_capabilities` fields that do not touch the emulator) on the reader thread while a call is running, so a client can see `busy`, `stuckTool` and `stuckForMs` during the call that is stuck. Optionally a `cancel` tool. | T-25 |
| MCP-38 | P2 | server | Apply one path policy: `dump_memory`, `take_screenshot`, `save_state_file`, `record_input` and `trace_between` accept an absolute path outside the results dir (files were written to `C:\Work\escape_probe.*`); refuse it, or accept it only under an allow-list given as a flag. | T-26 |
| MCP-39 | P2 | server | Speed up `rewind`: with the 30-frame granularity known, jump to the nearest older checkpoint and replay forward at turbo speed (today 4.7 to 9 s for 30 to 120 frames, growing with the session). Report `elapsedMs`. | T-28 |
| MCP-40 | P2 | server | `get_access_summary`: accept `{start, length}` (or reject `length` without a `label`), and fail with a real error for an unknown `label`/`type` instead of an `error` row with `unresolved:1`. | T-15, T-29 |
| MCP-41 | P3 | build + `mcp.json` | Delete the stale `net8.0\win-x64\` output (a build step or `.gitignore` note), point all three `mcp.json` entries at `net8.0\MesenMcpHost.dll`, and have `mcp_smoke_test.py` check the DLL path in `get_capabilities.hostPath` against the registered one. The README tool count (80) is now 81. | T-30 |
| MCP-43 | P2 | server | **`writeFile` over the log cap.** The native script log buffer (100,000 bytes) is shared by every `writeFile` of one run. When a write does not fit: (1) fail that call with a message that names the cap ("script output buffer full: 100000 of 100000 bytes used") instead of the JSON error `'0x01' is invalid within a JSON string`; (2) never report success to the script (`calls 20 bytes 600000 errs {}` with no file written); (3) put the truncation warning, and a `filesWritten` entry with `truncated:true` and the bytes kept, in the `run_script` reply even when the log has more than 500 rows. Better: let `writeFile` stream to the results dir without the cap (the cap protects the log, not files). | T-31 |
| MCP-42 | P3 | `iog_kit` recipe | Add `inputLocked` (`$065A != 0`) and `bannerShown` to the `warp` result and return `ok:false, reason:"input_locked"` when the joypad is locked after the wait (scene `$08` and `$0A` without flag 63 give `ok:true, inputMask 0xCFF0`). | phase-4 H3 |

Order of work: MCP-31 (blocks every `--mcp-rom` registration), then MCP-33 and MCP-34 (silent failures produce wrong results without a sign), then MCP-32. The harness client already works around MCP-31, MCP-33 (callers check replies) and MCP-34 (reads `log.entries`).

### 12.3 Improvements without a defect

- `get_server_status` in `self_test` output and in `mcp_smoke_test.py` so a stale host is detected at once (a missing tool means 0.4.0).
- `get_capabilities` should list `startupWarning` and the registered `args`.
- A `run_script` option `failOnError` (default true once MCP-34 lands).
- `take_screenshot` could return the SHA-1 of the PNG so a harness can compare frames without opening files.

## 12. Status of T-31 and T-36 (server 0.5.1)

| ID | Status | What changed |
|---|---|---|
| T-31 | Done | The 100000-byte cap was the managed read buffer of the native script log, not the log itself (the native log keeps the last 500 rows). The server now reads it with a 4 MB buffer. `emu.mcp.writeFile` queues data in the script and flushes about 48 KB per frame; `run_script` keeps advancing frames after the requested count (within `timeoutMs`) until the queue is empty. Tested: 60 KB, 150 KB and 600 KB text files and a 25 KB binary file in one run arrive complete (byte-exact). The reply has `writes` (`writeCalls`, `bytesQueued`, `bytesWritten`, `bytesPending`, `complete`, `warnings`) and `logTruncated`. A script that logs 500 or more rows between harvests, or a run that ends with data still queued, is reported in `writes.warnings`. The misleading "'0x01' is invalid within a JSON string" error is gone (a cut row is now counted and named). |
| T-36 | Documented | README "Lua scripting", `MCP_TOOLS_CONTRACT.md` and the `mesen_kit.lua` header describe: full effective address (mask with `& 0xFFFF` or `kit.wramOffset`), the callback runs before the write, the PC is the address after the accessing instruction, direct-page access reported at the effective address. The `$7F0000-$7F00FF` bus-type no-hit result is not explained; the docs say to use the `snesWorkRam` callback type for `$7F`. |

Workaround that is no longer needed: chunking `writeFile` output to 3000 bytes or checking byte counts by hand. Check `writes.complete` instead.

## 13. Status of MCP-42 and MCP-43 (server 0.5.2)

| ID | Status | What changed |
|---|---|---|
| MCP-43 | Done (cap removed) | The 100,000-byte cap no longer exists (see T-31 above): `writeFile` is queued and streamed to the results dir without a size limit, so it no longer fails for size, and `true` means the data is queued. When data is still queued at the end of a run, or a row was cut off (4 MB log overflow), `filesWritten` has an entry with `truncated: true` and the bytes kept, and `writes.warnings` says so, whatever the number of log rows. |
| MCP-42 | Done | The `warp` result has `inputLocked` (`$065A != 0`) and `bannerShown`. After the settle wait it waits up to `unlockWait` frames (default 60) for the joypad; if it is still locked the result is `ok: false, reason: "input_locked"` (also `error`). Tested: scene `$08` with `unlockWait: 0` returns `inputMask 0xCFF0` and `ok: false`; with the default wait it unlocks and is `ok: true`. |

## 14. Status of T-42 (server 0.6.0)

| ID | Status | What changed |
|---|---|---|
| T-42 | Done | `reset` never did anything (it sent a shortcut the core ignores); it now works. `reset {mode: "soft"\|"power"}` stops the console before the first boot instruction (soft = reset button, WRAM kept, frame counter continues; power = cold boot, RAM re-initialized, frame counter 0). `load_rom {paused: true}` loads, power-cycles and stops at frame 0. `run_script` / `run_recipe` take `fromReset: "power"\|"soft"`; the script is loaded at the reset vector, `frames` counts from the boot, and the reply has `reset` (CPU state at the vector). Tested: a script after `load_rom {paused:true}` and one after `fromReset:"power"` see identical boot runs (903 exec callbacks in frame 1, first at `$00:8000`). Notes: a power cycle drops loaded scripts (new debugger); `$4200` is written at `$80:4200` in this game, so register both bank aliases. Re-run the boot-time `NMITIMEN` census with `run_script {fromReset:"power", frames:N}`. |
