# Mesen2 investigation plan for the outstanding audit questions

Scope: the 358 `OQ-` questions in `plans/extracted-audit/questions/` (through iteration I072). After the corrections of the audit of the audit (A12, section 0), 11 are answered or closed, 5 are tooling decisions, 10 are static-only and 332 need the emulator in whole or in part. The per-ID routing (experiment, mode, priority, duplicate groups, static pointers) is in [mesen2-question-inventory.md](mesen2-question-inventory.md). This file says **how** to run the experiments with the `mesen2-mcp` server and gives an **agent prompt for every step** (section 12). What the server still lacks is in [mesen2-mcp-enhancement-requests.md](mesen2-mcp-enhancement-requests.md) (`MCP-nn` ids are cited below).

Nothing in sessions 1-14 edits notes or names. A finding goes back through the closure step Z1 (section 8): the verdict is recorded by ID, and a note or comment change goes through `npm run merge -- <spec.json>` (dry-run first, then `npm run extract:lt`, then `npm run rebuild`); a name change through `npm run names -- <spec.json>`. No ad-hoc scripts for notes, comments or names.

---

## 0. What changed in this revision (read this first)

Source: `plans/extracted-audit/audit-of-audit/` (`report.md`, `A12_findings.md`, `ACTION_PLAN.md`, `IT01`-`IT16_apply.md`), checked on 2026-10-29. The experiment codes (`H0`-`H5`, `A1`-`T1`) are unchanged, because IT-35 takes the experiment letters from this file; `H6`, `V1` and `Z1` are new.

| # | Change | Why (source) |
|---|--------|--------------|
| 0.1 | Inventory corrected: 8 answered rows (OQ-5, 7, 22, I027-5, I029-1, I029-4, I054-1, I055-4) plus OQ-I063-4 (duplicate of I055-4) leave the runtime list; the hidden-group trio (OQ-I067-5, I069-4, I071-5) is static; 8 cluster errors fixed; 3 groups are "method only"; heading counts fixed; priority totals fixed (they summed to 357) | A12-08, A12-09, A12-10, §4 |
| 0.2 | **Static-first rows** (`†`): the readers of actor `$10` bit `$0200`, the `displayModeFlags` bits 0/4/5/14, `$0B22` and others already have a static pointer; the runtime job is to **confirm**, not to discover | A12 §8, RC-01, RC-08, RC-09, RC-14; IT-12 notes already say "not traced" or state the static answer |
| 0.3 | **S1 and T1 are not Mesen2 sessions**: IT-35 writes `static-answers.md` and `open-questions.md`; the tooling rows are IT-26, IT-27, IT-28, IT-30 | ACTION_PLAN IT-26..IT-35 |
| 0.4 | **Build mode matters.** Until IT-27 is DONE the tagged build (`extract:lt` + `rebuild`, the gate build) and the plain build (`extract` + `rebuild`) differ: ten transform rules fire only in the plain build. Any experiment that touches the diary menu, the Inca statue branches in `item_use_system`, the teleporter, the sliding wall or the solid arm must say which build it ran | A15, ACTION_PLAN §6.3, report G-1 |
| 0.5 | ROM validity is now a **hash comparison** (SHA-1), not "stale after every rebuild": the audit gate promises byte-identical output, so an `R_` state survives a rebuild that keeps the same gate | ACTION_PLAN §6.2, IT04_apply gate |
| 0.6 | Labels change under the audit (IT-04 renamed 37; IT-36 to IT-48 rename several hundred). Experiments record **ROM offsets**, not names; appendix A maps the old names used in earlier drafts to the live ones (for example `DiagClearReturnFlags` is now `CancelVerticalPhase`) | IT04_apply, `renames/apply-I021-I040_map.json` |
| 0.7 | Timing convention: `WaitByte #n` = **n+1 ticks** everywhere; button vocabulary: physical vs logical bits (`transforms.json:755-758`) | IT-02, A12 RC-18, ACTION_PLAN §6.1 |
| 0.8 | Closure path rewritten: ids are no longer written into notes (decision U7); closures go into `mesen2-results/closures.md`, `open-questions.md` (IT-35) links to it; shipped text says "not traced" until a runtime result replaces it with a plain statement | ACTION_PLAN §6.1, IT-23..IT-25 |
| 0.9 | H0: `get_rom_info` now returns SHA-1, CRC-32 and size (0.12); H3: the warp recipe is the server's `iog_kit` `warp` (state machine of `iog_bootstrap.lua`); B1: collision layer layout corrected; C4: OQ-I026-3 removed (it is G3); the NMI exec control address is ROM-specific (1.3 item 8) | MCP source reading, `docs/wram-memory-map.md`, `db-us/names/bank00.json` |
| 0.10 | New campaign `V1`: runtime confirmation of the highest-value static claims of the audit (report §12 asks for "a few E5 confirmations") | report P-11, §8.8, §12 |
| 0.11 | Session counts recomputed per primary experiment (they overlapped and summed to 450 for 358 ids) | inventory rg counts |
| 0.13 | **Tooling re-verified against server 0.5.0** (run 2026-10-30, DLL `net8.0\MesenMcpHost.dll` built 00:23): section 1 (watchdog and `get_server_status`, exact `rewind`, JSON shapes, quick warp option, lib-dir list, events, startup flags, hazards 15-19), H0/H4 (81 tools, range definition, rewind and SPC rows), 1.4 (vendored kit removed, client hardened, `probe_050.py`), prompts (0.5.0). Result: `mesen2-results/Probe_050_20261030.md`; requests MCP-21 to MCP-30 verified, new defects T-20 to T-30 and requests MCP-31 to MCP-42 | `mesen2-results/tool-issues.md`, request file section 12 |
| 0.14 | **Server 0.6.0: boot-time observation (T-42).** `load_rom {paused:true}`, `run_script` / `run_recipe` `{fromReset: "power"\|"soft"}` and a working `reset {mode}` let a script see the first boot instruction; added to 1.0 (version, health check), 1.1 (ROM and session, Scripts), 1.3 (hazard 5, new hazard 28), C2 and C3 procedures, the step prompts (C2, C3, header, hard rule 3). Verified 2026-10-30: `load_rom {paused:true}` gives `boot.frameAfter 0`, `boot.cpu.pc24 32768`; a script run from there sees `ResetVector` and `SystemInit` once and the first `$4200` write at frame 0 (`$82:9F47` = `$00`) | `mesen2-results/tool-issues.md` T-42, request file section 14, `mesen2-results/C1_20261030.md` section 11 |
| 0.12 | **Tooling rewritten against server 0.4.0** (run 2026-10-29): section 1 (all tools exist and were exercised; setup, flags, hazards 1, 5-8 rewritten, 1.4 harness), 2.1 (ROM identities), 2.4 and B1/B2 (collision layer is **paged**; the old `0x1C000 + row*stride + col` formula was wrong), H0-H4 pass criteria (boot logo `$FB` lasts until about frame 300-350, so "`$FB` at frame 700" was wrong; the title is `$FC`), S06 (title is `$FC`, not `$FA`), 6.x (use the server tools instead of hand-written loops), 12 (prompts and common block). First experiment run: B2 single-tile sweep (`mesen2-results/B2_special_tiles_20261029.md`) | `mesen2-results/tool-issues.md`, request file sections 9 and 10 |

Relation to IT-35: it reads this plan and the inventory as input. Its rule "never edit `mesen2-question-inventory.md`" applied to that iteration; the corrections of 0.1 are made here so that IT-35 finds a consistent routing table. IT-35's step 2(d) (corrections to the old inventory) then only has to check the list above.

---

## 1. What was verified about the tool chain

Status tags: **verified** = run on 2026-10-29 (phases 2 and 3; phase 3 used the DLL rebuilt at 21:35) against server **0.4.0** (phases 2 and 3) and again against **0.5.0** (phase 4, 2026-10-30, `net8.0\MesenMcpHost.dll`, 81 tools: the 80 plus `get_server_status`) with the harness of 1.4; unless a row says 0.5.0 the fact holds on both; **source** = read in `C:/Work/mesen2-mcp`, not run; **not exercised** = exists, not tried yet. Everything the earlier draft called broken, asynchronous or missing (`get_cdl_data`, hash in `get_rom_info`, state identity, `step_instruction`, script unload, conditional breakpoints, input sequences, `run_until`, layer screenshots, labels, recipes) has landed and works; the request file ([mesen2-mcp-enhancement-requests.md](mesen2-mcp-enhancement-requests.md) section 9) has the matrix.

### 1.0 Setup before any session

1. **Server.** Host `C:\Work\mesen2-mcp\McpHost\bin\Release\net8.0\MesenMcpHost.dll` (**0.6.0** since 2026-10-30; 0.5.x lacks `load_rom {paused}`, `fromReset` and a working `reset`, so boot-time experiments need 0.6.0 or later; since 0.5.0 the build always lands in `net8.0\`, so the old `net8.0\win-x64\` folder holds a **stale 0.4.0 build**: never register it). Required `args`: that DLL path plus `--mcp-lib-dir=C:\Work\gaia-iog-baserom\plans\extracted-audit\mesen2-results\kit\lib` (the server's own `lua/lib` is searched first, then this folder; `;` or a repeated flag adds more) and `--mcp-results-dir=C:\Work\gaia-iog-baserom\plans\extracted-audit\mesen2-results\raw` (the default is now `%LOCALAPPDATA%\Mesen2Mcp\results`, no longer OneDrive). Reload MCP after editing. **State of `mcp.json` on 2026-10-30:** `mesen2-mcp-dev` points at the 0.5.0 DLL with both flags; `mesen2-mcp` and `mesen2-mcp-rebuilt` still point at the **stale win-x64 DLL**, and `mesen2-mcp-rebuilt` uses `--mcp-rom=`, which breaks the stdio framing on every host version (T-20: do not use `--mcp-rom` with Cursor until MCP-31 is fixed; load the ROM with `load_rom`). A Cursor session started before the rebuild keeps the 0.4.0 process: the namespace `user-mesen2-mcp-dev` has no `get_server_status` until MCP is reloaded, so look for that tool first.
2. **Two ways to drive the server.** Native Cursor tools (`user-mesen2-mcp-dev`, good for one-off checks) or `mesen2-results/harness/mcp_client.py` (1.4; scripted matrices, hard timeouts, JSON results). The tools and arguments are the same. Use the Python client for anything that repeats, and run it under a process timeout (T-12).
3. **Health check (1 minute):** `load_rom` O first (**`get_capabilities` errors with "No ROM is running" before a ROM is loaded**, T-16), `pause`, `get_capabilities` (version 0.6.0 or later, `mesenVersion` 2.1.0, `scriptIo: false`, `libDirs`, `resultsDir`), `self_test` (expect 17/17), `get_rom_info` (SHA-1 `38de0c84...`), `get_server_status` (`busy: false`), `tools/list` count 81. Since 0.5.0 `get_capabilities` and `list_recipes` also work before any ROM is loaded (`romLoaded: false`).
4. **Headless by default.** Video, audio and input are off and turbo is on: 180 to 370 frames per second. The frame counter in replies is the emulator's frame count; a loaded state restores its own count.

### 1.1 MCP tools (all verified on 0.4.0 and 0.5.0 unless noted)

Every stepping tool (`advance_frame`, `step_instruction`, `step_scanline`, `step_cpu_cycles`, `run_until`, `play_input`, `run_script`, `run_recipe`) is synchronous and returns `{stopReason, framesAdvanced, frame, cpu{k,pc,pc24,a,x,y,sp,d,dbr,ps,psFlags}, framesPerSecond}`; `stopReason` is `done`, `breakpoint`, `condition`, `script_done`, `frames`, **`timeout`** (0.5.0: `timeoutMs` is honoured, the call returns the state reached and the emulator is paused; verified with `advance_frame`, `step_scanline` and `run_until`) or an error code. Arguments are **not type-checked** (hazard 17).

| Group | Tools | Facts |
|-------|-------|-------|
| ROM and session | `load_rom {path, slot?, paused?}`, `get_rom_info`, `pause`, `resume`, `reset {mode?}`, `stop`, `list_slots`, `switch_slot`, `get_capabilities`, `self_test` | `load_rom` returns `rom{fileSha1, fileCrc32, fileSizeBytes, header}`, **resumes** emulation (call `pause`) and wipes scripts and the log. **0.6.0 (T-42): `load_rom {path, paused: true}`** does not resume: without a state the console is power-cycled and stopped before its first boot instruction (reply `boot{mode:"power", frameBefore:0, frameAfter:0, paused:true, cpu{pc24:32768 ...}}`, verified on O: the reset vector is `$00:8000`), so the next `run_script` sees the whole boot. **`reset {mode:"soft"\|"power"}`** (it did nothing before 0.6.0) leaves the console paused at the reset vector: `soft` = reset button (WRAM kept, frame counter continues), `power` = cold boot (RAM re-initialized, frame counter 0). A power cycle builds a new debugger: loaded scripts and Lua-backed `log`/`count` breakpoints are dropped (`scriptsDropped`), native breakpoints and labels stay. Load the script **after** the reset (or use `fromReset`, below). Use `power` for "from a cold boot" and `soft` for the reset-button questions (OQ-50, OQ-I055-3). With `slot` a second ROM loads next to the first and the new slot becomes **active** (`switch_slot` back; the old slot's state is written to `<results>/slots/`). `stop` ends the server process. |
| Memory | `read_memory {address, length, type, format}`, `write_memory`, `read_word`, `write_word`, `dump_memory`, `list_memory_types` | Types: `workRam` (offset into 128 KB: `$7E:0642` = `0x642`, `$7F:C000` = `0x1C000`), `prgRom`/`snesPrgRom`, `snesMemory` (24-bit CPU address), `snesCgRam`, `snesVideoRam`, `snesSpriteRam`, `spcRam`. Formats: `bytes` returns `{"bytes":[...]}`, `words_le` `{"words":[...]}`, `base64` `{"data":...}`, `hex` or none plain text. Use decimal integers in JSON. **0.5.0 returns JSON** from `read_word` `{memoryType, address, value, hex}`, `write_word` `{..., value, hex, readBack, verified}` and `write_memory` `{written, bytes, verified, value?, hex?}` (0.4.0 returned text). A `read_memory` longer than 65,536 bytes is silently cut to 65,536. Writes are **not range-checked** (T-27): a word above `0xFFFF` wraps (`70000` wrote `0x1170`), a byte above 255 is clamped to 255, `-1` becomes `0xFFFF`. `write_memory` into `snesPrgRom` works (patch the ROM in memory; `revert_rom_changes` undoes it, but see hazard 16). `dump_memory` refuses `..` in `path` but accepts an absolute path (so do `take_screenshot` and `save_state_file`): the sandbox applies to relative names only. |
| Input | `set_input {buttons, frames, mask}`, `clear_input`, `get_input`, `play_input {sequence:[{frames, buttons}]}`, `record_input {action:start\|stop, path, startState?}`, `play_input_file {path}` | Button names: a b x y l r up down left right select start. A recorded file carries the ROM SHA-1. Replay is **deterministic** (50-frame walk: same `posX`, `posY`, `$36`). |
| States | `save_state_file {path, note?, meta?}`, `load_state_file {path}`, `list_states {dir}` | `save_state_file` writes `<path>.json` (ROM SHA-1, CRC, frame, server version, `meta`). `load_state_file` raises `rom_mismatch` for another ROM (no state loads silently into the wrong build any more). `list_states` reports `valid` per state for the loaded ROM. |
| Breakpoints | `set_breakpoints [{callbackType: exec\|read\|write, startAddress, endAddress, memType, action: break\|count\|log, condition?, name, maxLogged}]` (**`break`**, not `halt`: T-18), `get_breakpoint_hits`, `clear_breakpoints` | `count` never halts. Verified controls: write `$36` count 119 in 120 frames; exec at `snesPrgRom` 33528 count 119; `log` of `$09EC` writes returns `pcHex`, regs, frame. `action: "halt"` is accepted as an alias of `break` on 0.5.0 (0.4.0 rejected it). `get_breakpoint_hits {id?, sinceSeq?, max?, reset?}` reports the CPU alias the code used (a WRAM write from DBR `$81` shows as `address 0x8109EC`) and, on 0.5.0, the fields `absType`, `absOffset`, `wramOffset`/`prgOffset`, `pcPrgOffset`: **the pc offsets are right, the offsets of the accessed address are wrong whenever the code used a mirror** (`wramOffset` 8456684 = `0x8109EC` instead of `0x09EC`; an exec hit on `snesPrgRom` has `prgOffset` 8422136 instead of 33528; only direct-page accesses below `0x2000` are right; T-21): compute the offset yourself (`kit.wramOffset(addr)` in Lua, `addr & 0xFFFF` for `$0000-$1FFF`). A `count`/`log` breakpoint with `start > end` or an invalid `condition` is accepted silently (an invalid condition on a `break` is refused with `invalid_condition`). A halting exec breakpoint works at `snesMemory 0x8082F8` and `snesPrgRom 33528`; `$00:82F8` never fires (alias, see 1.3 item 4). Conditions: a `count`/`log` condition is translated to Lua and sees `value`, `oldvalue`, `address`, `pc` (verified: `(value & 1) == 0` on a `$36` write counted 49 in 100 frames); a halting `break` condition uses native Mesen expressions (verified: `value == 0x55` on a `$36` write halted after 135 frames, `stopReason: breakpoint`; `value` is the **byte** written and the break lands before the store, so `$36` still read `0x0154` afterwards). |
| Run control | `run_until {condition, maxFrames}` | `condition` = `{type:"lua", expr, includes:[...]}`, `{type:"pcEquals", pc:"80:82F8"}` or `{type:"memoryEquals", address, size, value, mask}`. `includes` goes **inside** the condition. A condition that is not met returns `stopReason: done`, `met: false`. |
| Stepping | `step_instruction {count, over}`, `step_scanline`, `step_cpu_cycles`, `rewind` | `step_instruction` returns `instructionsExecuted` and `pcs` (`["82:8051","00:800B","80:82F8"]`). `step_scanline {count, timeoutMs}` returns at once with `framesAdvanced: 0` for a step inside a frame and (0.5.0) adds `scanlinesRequested`/`scanlinesAdvanced` (`count 0` or negative still steps one scanline). It **hung once for 251 s** on 0.4.0 (T-12, never reproduced); on 0.5.0 a huge count with `timeoutMs 800` returned `stopReason: timeout` after 0.81 s. `step_cpu_cycles` works (returns the new `cpu` block). `set_cpu_state {state:{cpu:{x,y}}}` works (also `a`). **`rewind`**: 0.4.0 was broken (it moved 3 or 31 frames for `seconds:2` and killed Lua SPC callbacks afterwards: T-13, T-14). **0.5.0 `rewind {seconds | frames, allowPartial?}` lands exactly** (`framesRewound` 120 for `seconds:2`, 30 for `frames:30`; reply `{requestedFrames, framesRewound, frameBefore, frameAfter, jumps[], forwardFrames, partial, rewindAvailableFrames, granularityFrames: 30}`); errors `rewind_unavailable` (under about 60 frames of history), `rewind_insufficient_history` (`rewindAvailableFrames`; the state is restored) and `invalid_argument` (outside 1 frame to 1 hour). `allowPartial` rewinds as far as possible (verified: 280 frames back to the load point). SPC callbacks work afterwards. It is **slow**: it jumps back in 10 s steps and replays forward, so it cost 4.7 to 9 s here (30 to 120 frames back after 400 to 600 frames) and grows with the session length (T-28); when both arguments are given `frames` wins silently. For repeated time travel use states. |
| Inspection | `get_emulator_state`, `get_callstack`, `get_disassembly {address (24-bit), rowCount}`, `set_cpu_state`, `get_execution_trace`, `trace_between {startPc, stopPc, path, maxFrames, maxLines}`, `start_trace`/`stop_trace` | With labels loaded, `get_disassembly` prints labels and real instructions (it works now) and `get_callstack` names routines (`MainLoop`, `VBlankWaitAndJoypad+0x10`, `NmiVector`). `trace_between` writes lines like `8082F8  378    8082F8 PHP  A:0002 X:0000 ... P:nvMxdIzC`. **`start_trace {path, pcRanges:[["80:82F8","80:8380"]], maxLines, useLabels}` / `stop_trace` verified**: advance frames between them; the file is trimmed to `maxLines` (`trimmedToMaxLines: true`, 40 lines, SHA-1 returned). `get_execution_trace` returned empty rows (`{'rows': []}`) in a paused session: use `start_trace` instead. `get_profiler_data` returns a table of `{address, exclusiveCycles, inclusiveCycles, callCount, ...}`; `get_timing_info` returns `fps` 60.0988, `frameCount`, `scanlineCount`, `masterClock`. `set_cpu_state {state:{cpu:{a}}}` changes the register. |
| Labels | `load_labels {path, replace}`, `list_labels`, `resolve_address`, `resolve_addresses`, `get_label_address`, `get_prg_rom_offset`, `get_chr_rom_offset` | Load `artifacts/labels/iog-original.mlb` for O, `iog-rebuilt.mlb` for the main R ROM (3510 / 3509 labels). `get_prg_rom_offset 0x8082F8` returns `0x82F8 (33528)`. `get_label_address NmiHandler` returns JSON on 0.5.0: `{label, address: 33528, hex: "0x82F8", cpuAddress: 8422136, memoryType: "snesPrgRom", length}` on O and `address 38524` on R (0.4.0 returned the text `"0x82F8 (33528)"`). The arguments of `resolve_address` are `cpu`, `prgOffset`, `offset`, `wram`, `label` (not `address`). |
| Coverage | `get_cdl_data {format: summary\|ranges\|bytes, flagMask, maxRows, start, length}`, `get_cdl_statistics`, `reset_cdl`, `save_cdl`, `load_cdl`, `get_access_summary {type, ranges:[{name, label \| start,end \| length}]}`, `reset_access_counters` | `ranges` rows are `[start, end, flags]`, paged by `nextStart`. `get_access_summary` returns per range `exec/read/write` totals, first/last stamp, `verdict` (`accessed` / `never_accessed`) and CDL flags. **`exec` is the sum of the per-byte exec counters of the range** (the 16-byte `NmiHandler` range gave `exec 960` = 16 bytes x 60 frames, with `execBytes 16`, `execFirstByte 60`, `hottest {offset, exec}`; a 301-byte range gave 14,340 over 203 touched bytes). Use `execFirstByte` as the entry rate and `hottest` to find the loop. A range given as `{start, length}` is read as **one byte** (`length` counts only together with `label`; give `{start, end}`): that, not the emulator, produced the phase-3 reading "exec 60, bytesTouched 1" (T-15, T-29). A range with an unknown `label` returns a row with `error` and `unresolved: 1` instead of failing. `dump_memory {type, start, length, path}` verified (8,192 bytes of the collision layer at `0x1C000`, SHA-1 returned). |
| Snapshots | `snapshot_memory {name, type, start, length}`, `diff_snapshots {a, b:"current", ranges, maxRows}`, `list_snapshots`, `delete_snapshot` | A diff returns `[start, end, oldHex, newHex]` runs. |
| PPU and screen | `get_ppu_state`, `get_oam {onlyOnScreen, first, count}`, `get_palette_info {first, count, format}`, `get_tilemap_info`, `get_dma_state`, `take_screenshot {layers, crop, scale, label, returnImage}` | `get_ppu_state.derived` has `bgMode`, layer lists, `colorMath`, `oam`. `take_screenshot` is in-process: PNG at `<results>/screenshots/<label>_<frame>.png`, with `layers:["obj"]`, `crop:{x,y,w,h}` and `scale`; headless it renders from the PPU buffer. |
| Scripts | `run_script {code, frames, includes, name, turbo, fromReset?}`, `load_script`, `unload_script`, `list_scripts`, `get_script_log {name, max, sinceSeq}`, `get_script_result`, `list_recipes`, `run_recipe {name, args, frames, fromReset?}` | `run_script` is the atomic form of an experiment: load, run N frames, return `log.entries[]`, `result`, `stopReason`, unload. **0.6.0: `fromReset: "power"` (also `true`) or `"soft"`** resets first, loads the script at the reset vector and counts `frames` from the boot (frame 0 on `power`); the reply has `reset{cpu ...}`. `load_rom {paused:true}` followed by a `run_script` without `fromReset` gives the same run (verified identical, request file section 14). `run_recipe` takes `fromReset` too. A `power` cycle unloads every other script. Register memory callbacks on **both** bank aliases of `$4200` (`$00:4200` and `$80:4200`); the boot code and the NMI helpers write it at `$82:xxxx` PCs (below). Recipes: `warp`, `census_pc`, `exec_coverage` (found only if `recipes/` is inside `--mcp-lib-dir`). |
| Server health (0.5.0) | `get_server_status` | `{serverVersion, uptimeSeconds, busy, stuckTool, stuckForMs, romLoaded, paused, recentCalls[5]}`. Every call has a watchdog (`timeoutMs` + 15 s, else 120 s; four times that for `compare_runs`, `self_test`, `play_input*`, `trace_between`); on expiry the call returns `{error:{code:"timeout", tool, limitMs, paused, recentCalls}}`, pauses the emulator, and later calls get `busy` until the stuck one ends. **Not usable from one pipe while a call runs**: the host reads requests one at a time, so a `get_server_status` sent during a call is answered only when that call ends (measured: a 2.5 s call and a status request sent 0.4 s later both completed at 2.5 s, T-25). The soft `timeoutMs` path was verified; the hard watchdog was not (nothing hung). A Lua loop `while true do end` is cut by the script limit ("Maximum execution time (1 seconds) exceeded." in the log, `stopReason: done`, no error flag). |
| Two ROMs | `compare_runs {inputFile, slots, startStates, watch:[{address, size, name}], frames, maxDivergences}`, `subscribe_events` | `compare_runs` plays one recording on two slots and returns the first divergences of the watched values. Verified O against R: positions identical for 90 frames; `displayModeFlags` bit 3 shifted by one frame (frame 51 vs 52). `subscribe_events {types, frameEvery}` verified: types `breakpointHit`, `emulationStopped`, `error`, `frameEnd`, `gamePaused`, `gameResumed`, `romLoaded`, `scriptLog`, `stateLoaded`; notifications arrive as JSON-RPC `notifications/mesen/event` with `params.event` (`game_loaded`, `breakpoint_hit`, ...). 0.4.0 sent a payload-free `breakpoint_hit` (`breakpointId -1, address 0`) for every count hit (178 in 65 frames). **0.5.0** sends halting-breakpoint events with `source`, `address`, `value`, `operationType`, and rate-limited count/log events `{breakpointId, action, name, callbackType, count, newHits, frame}` (4 in 60 frames); `frame_end` arrives every `frameEvery` frames; `step_instruction` and the internal temporary breakpoints send nothing. |

Defects and surprises found while testing are in `mesen2-results/tool-issues.md` (T-01 to T-42); the requests are MCP-21 to MCP-43 and B-04/B-05 in the request file (its section 11 has the 0.5.0 verification, section 14 the 0.6.0 boot tools of T-42).

**Startup flags (0.5.0, verified):** `--mcp-rom=<file>` preloads a ROM but **breaks the stdio framing** (T-20): the `game_loaded` event is written before the first request, with `Content-Length` framing and no newline, so a newline-delimited client reads `Content-Length: 87`, an empty line, and then the event glued to the `initialize` reply (`mcp_client.py` now copes; Cursor may not). `--mcp-savestatepath=<file>` loads a state after the ROM, also one without a sidecar; a state of another ROM is refused and reported as `startupWarning` in **`get_rom_info`** (not in `get_capabilities`). A **missing** state file, a missing slot (`--mcp-savestateslot=3`) or both state flags make the host exit before it answers, with nothing useful on stderr (T-22). A missing `--mcp-lib-dir` folder is ignored without a warning; the results folder is created on first write.

### 1.2 Lua API facts (Mesen2, **Lua 5.4**: `&`, `|`, `~`, `<<`, `>>`, `//` all work; verified)

Lua `io`, `os` and `require` are **disabled**: a script cannot write a file with them. Output goes through `emu.log` (the server keeps a ring of 5,000 rows; the native Lua log keeps 500 per frame), `emu.mcp.result(table)` (one JSON result per script, up to about 90 KB, returned by `run_script` as `result` and by `get_script_result`) and `emu.mcp.writeFile(name, text, append?)` (**verified**: the file appears under the results dir; `io` and `os` are `nil`). `includes: ["gaia_kit"]` pulls modules **by name** from `--mcp-lib-dir` (a `-- requires:` header chains `mesen_kit` and `iog_kit`). `emu.mcp.done()` and `kit.finish(result)` end the run; on 0.5.0 they also work **at script load** (the run ends at once with `stopReason: script_done`, `framesAdvanced: 0`; 0.4.0 raised "This function cannot be called outside a callback"). A script error does **not** set `isError`: a syntax error returns `stopReason: done` with the message only in `log.entries` (`se:1: syntax error near 'is'`), and a runtime error in a frame callback repeats every frame (`re:1: boom` three times in three frames) while the run continues (T-24): always read `log.entries` and `hasResult`. `kit.wramOffset(addr)` (0.5.0, `mesen_kit`) converts the CPU address a callback received into a WRAM offset (`0x81065A` gives `0x065A`, `0x7F0001` gives `0x10001`, `0x80C000` gives `nil`). Sandbox facts: `io`, `os`, `package` and `loadstring` are `nil`; `dofile` and `loadfile` exist but raise "I/O functions are disabled by default for security"; `load`, `debug`, `collectgarbage` and `getmetatable` are present.

| Call | Status | Facts |
|------|--------|-------|
| `emu.addMemoryCallback(fn, emu.callbackType.exec/read/write, lo, hi, emu.cpuType.snes, emu.memType.X)` | verified for all three kinds | With `snesWorkRam` the addresses are WRAM offsets; with `snesPrgRom` they are ROM file offsets; with `snesMemory` they are 24-bit CPU addresses (see 2.3). |
| `fn(addr, value)` | verified | For `write`, `value` is the new byte. **The callback runs before the write, so `emu.read(addr, snesWorkRam)` inside it returns the old byte** (probe: `$36` old `$54`, new `$55`). This gives bit-transition detection for free. |
| `emu.getState()` | verified | Keys `cpu.pc`, `cpu.k`, `cpu.dbr`, `cpu.d`, `cpu.sp`, `cpu.a`, `cpu.x`, `cpu.y`, `cpu.ps`, `frameCount`, and many `spc.*` (`spc.pc` is the SPC program counter). |
| SPC callbacks | **verified** | `emu.addMemoryCallback(fn, emu.callbackType.exec, 0x0000, 0xFFFF, emu.cpuType.spc, emu.memType.spcRam)` fires: 7,001 hits in 8 frames at South Cape, the first three SPC PCs `05C0, 05C2, 05C3` (read from `emu.getState()['spc.pc']`); read callbacks on `$F4-$F7` (the APU ports as the SPC sees them) fire too. **Never after a `rewind`** (T-13: 0 hits, 90 times slower). |
| **PC reported inside a memory callback** | verified | It is the address of the instruction **after** the one that made the access. `INC $36` at `$80:837F` (2 bytes) reported `K=$80 PC=$8381`. To find the culprit, take the instruction that ends at the reported PC. For jumps/branches the reported PC may be the target, so cross-check with the `.asm`. |
| 16-bit accesses | verified by design | A 16-bit store fires **two** byte callbacks (low byte, high byte). Flag words such as actor `$10` need the high byte (`addr & 0x3F == 0x11`) for bits 8-15. |
| `emu.read(addr, memType, signed)`, `emu.read16` | verified | Work for `snesWorkRam`, `snesCgRam`, `spcRam`. |
| `emu.write(addr, value, memType)`, `emu.write16` | verified (the kit's `kit.w8/w16` and the warp recipe use them) | Writes WRAM. The painted collision tiles of B2 are written this way. |
| `emu.addEventCallback(fn, emu.eventType.endFrame)` | verified | Use for per-frame sampling. |
| `emu.addEventCallback(fn, emu.eventType.inputPolled)` + `emu.setInput(tbl, port)` | verified (`gaia.hold` uses it; the B2 trial holds `right` for 40 frames) | Event types: `codeBreak, endFrame, inputPolled, irq, nmi, reset, scriptEnded, startFrame, stateLoaded, stateSaved`. |
| `emu.log(str)` | verified | Goes to `get_script_log` and to the `log.entries[]` of `run_script`. |
| `emu.getRomInfo()` | verified | Returns `name`, `path`, `fileSha1Hash`. The MCP `get_rom_info` returns the same hash (`fileSha1`) without a script. |
| `emu.getCdlData(emu.memType.snesPrgRom)` | verified | Table indexed from 0 with one flags byte per ROM byte. Prefer the MCP `get_cdl_data` (`summary`, `ranges`): it does not cost a table of 2 million entries. |
| `emu.getAccessCounters(memType, counterType)` | verified | **Argument order is `(memType, counterType)`** (the wrong order raises "Invalid counter type"). Counter types: `emu.counterType.readCount/writeCount/execCount/lastReadClock/lastWriteClock/lastExecClock`. Table indexed from 0. For named ranges use `get_access_summary` (1.1). |
| `emu.resetAccessCounters()` | the MCP tool `reset_access_counters` exists; the Lua call was not run | |
| `emu.createSavestate()` / `emu.loadSavestate(s)` | verified inside an exec callback | The state is a string. Saved at the third NMI exec (`$36` 108), loaded at the tenth (`$36` 115): execution resumed from the saved point (`$36` 109 one frame later). Use it for "try N variants from one state" (6.3). |
| `emu.memType.*` | verified names | `snesWorkRam`, `snesPrgRom`, `snesMemory`, `snesCgRam`, `snesVideoRam`, `snesSpriteRam`, `spcRam`, ... (`list_memory_types` lists every type with its size). `read_memory` reaches all of them now (the "not exposed" note of the earlier draft is obsolete). |
| `emu.convertAddress` | not exercised | The MCP `get_prg_rom_offset` / `resolve_address` do the job. |

### 1.3 Hazards found the hard way

1. **A save state from an older ROM build derails the game.** `rebuilt/ws-test-south-cape.mss` loaded fine, but the game later ran off into garbage (DBR `$AB`, SP `$7FFD`/`$8001`, PC `$40:4044`). Every watch test taken on that session returned zero hits, which looked like "the callback does not work". The callbacks work (section 1.2). Since 0.4.0 `load_state_file` refuses a state whose sidecar SHA-1 differs (`rom_mismatch`). A state **without** a sidecar (`ws-test-south-cape.mss`, `orig_S01_south-cape-start.mss`) is now refused with `no_sidecar` (phase 3; `requireRomMatch:false` overrides it): re-create it with `save_state_file`.
2. **Log floods.** An uncapped `emu.log` per frame produced thousands of lines. Use `gaia.log` (200-line cap) or return a table with `kit.finish(result)`; the server ring holds 5,000 rows.
3. **Scripts persist and stack** (`load_script`). Reuse names, `unload_script`, or use `run_script`, which unloads on exit.
4. **Alias-specific CPU watchpoints.** `snesMemory` callbacks and breakpoints match the **bank alias the code used**. Writes to PPU registers were counted at `$00:21xx` (boot code) 35,688 times but at `$81:21xx` (NMI, DBR `$81`) only 143 times in 30 frames; an exec breakpoint at `$00:82F8` never halts because the NMI runs at `$80:82F8`; `get_breakpoint_hits` reports a WRAM write from DBR `$81` as `0x8109EC`. Prefer `snesWorkRam` (offsets) and `snesPrgRom` (file offsets), which match every alias; read `pcHex` of a hit to find the routine. The `addr` argument that a `snesWorkRam` callback receives is still the **CPU address used** (`0x81065A` for a read of `$065A` by code with DBR `$81`; `0x0036` for a direct-page write): mask it with `& 0xFFFF` before comparing (T-11).
5. `load_rom` resumes the emulator and wipes scripts. Call `pause` right after it. With `slot` it also switches the active slot (1.1). **Exception (0.6.0): `load_rom {paused:true}` does not resume and stops at frame 0.** Any experiment about boot code (`InitHardwareRegisters`, the first `NMITIMEN` write, `MEMSEL`, the first APUIO write) must start from `load_rom {paused:true}` or `run_script {fromReset:"power"}`: a plain `load_rom` + `pause` arrives at about frame 97 (measured in C1) and has already missed all of it.
6. **Plain versus tagged build.** The ROM at `rebuilt/Illusion of Gaia - Rebuilt.smc` is whatever the last `rebuild` produced. After `npm run extract:lt` it is the **tagged** build; ten multi-line `transforms.json` rules (diary menu, `item_use_system` Inca statue compares, `pyDD_teleporter`, `pyD7_sliding_wall`, `sEA_solid_arm`, `diary_menu_window_dma`) fire only in the **plain** build. A result on the tagged ROM about those blocks describes the vanilla instruction, not the shipped build. Record the mode in every R result (section 3). The problem disappears when IT-27 is DONE. **Today's file:** the main R ROM (SHA-1 `795c7a8c...`, built 2026-10-29 16:32:01) is **plain** (`crc.json` totalSize 3,062,189, extracted asm has no `; {n}` tags). It is older than the newest `extracted/` edits (for example `tile_collision_physics.asm`, 16:41) and was built before `crc.json` gained `mode`/`sha1`; ask the user to re-run `npm run rebuild` when a result must match the current source. `rebuilt/variants/plain.smc` (SHA-1 `2e4a88a3...`, 17:53) differs from the main file in 70,099 bytes and has no artifacts, so no label file matches it.
7. **File size is not `totalSize`.** The rebuilt ROM file is 3,080,192 bytes; `artifacts/crc.json` `totalSize` is the content size (3,062,189 for the plain build). Use the SHA-1 (`get_rom_info.fileSha1`) as the ROM identity.
8. **The NMI exec control address is ROM-specific.** On O the NMI handler is `NmiHandler` at ROM offset 33528 (`$80:82F8`): exec count 179 in 180 frames, and `0x967C` fires 0 times. On the rebuilt ROM `NmiHandler` is at `0x967C` (`artifacts/master-lookup.json`: `"NMIHANDLER": "00967C"`): there 33528 fires 0 times and `0x967C` once per frame. The earlier "`0x967C` is the NMI" claim holds for R only. Use the label (`resolve_address` after `load_labels`) or the `INC $36` write, never a hard-coded offset across the two ROMs. Controls that fired on O: write `$36` 179, read `$656` 1074, nmi event 179.
9. **Names are moving.** See 0.6 and appendix A.
10. **The Cursor MCP registration** is current since phase 3 (`user-mesen2-mcp-dev`, 81 tools). If a session offers fewer than 80 Mesen tools, the registration is stale: fix `mcp.json` (1.0) before working.
11. **Quick warp works from the boot logo, the title and in game** (phase 3: from `$FC` at frames 450, 700 and 1200 on O it reached `$01`; the earlier "does nothing from the title" no longer holds, T-17). Still check `sceneCurrent` afterwards; if a warp fails `run_recipe warp` can time out, so start the recipe from a clean state.
12. **`$09A2/$09A4` are not the actor position.** `iog.state()` and the warp recipe use `$09A2/$09A4` (player x, y); the actor fields `$1014/$1016` are 8 and 16 px larger (South Cape spawn: `$1014/$1016` = 664/752).
13. **`rewind` on 0.4.0 poisoned the session** (T-13, T-14: 0 SPC callback hits, scripts 90 times slower, wrong distance). **Fixed in 0.5.0** (exact distance, SPC callbacks alive: 7,001 hits right after a rewind; one matrix run saw 5,586 over the same 8 frames after a rewind, not explained). It is slow (4.7 to 9 s): use states for repeated jumps.
14. **`step_scanline` hung once for 251 s on 0.4.0** (T-12, never reproduced). 0.5.0 has a watchdog and honours `timeoutMs`, but keep every harness under a process timeout (`timeout 300 python ...`) anyway: the hard watchdog has not been exercised.
15. **`--mcp-rom` breaks the stdio framing** (T-20; 1.0). Load the ROM with `load_rom`. A missing startup state, slot, or both state flags kill the host silently (T-22).
16. **`revert_rom_changes` also undoes WRAM writes.** It reports "Performed N undo operation(s)" and N counted every `write_word`/`write_memory` of the session: after `poke(0x0ACE, 7)` a `revert_rom_changes` restored the older value (`0x0008`). Never call it in a session that depends on poked WRAM; patched ROM bytes come back with it (T-23).
17. **Arguments are not validated.** `advance_frame frames:"ten"`, `0` and `-5` all advance **one** frame; `record_input startState:true` is read as the empty string and the replay later fails with `no_start_state`; `step_scanline count:0` steps a scanline; `set_cpu_state` ignores unknown keys; `get_access_summary` ignores `length` next to `start`; `rewind` with both `frames` and `seconds` uses `frames`. Check every reply instead of trusting a call that "succeeded" (T-27, T-29).
18. **`ok: true` of the warp recipe does not mean the player is free.** Scene `$08` returned `ok:true, inputMask 0xCFF0` (the church dialogue was already running) and `$0A` without flag 63 returns `ok:true, inputMask 0xCFF0`. Read `inputMask` (`$065A`) and the screenshot.
19. **Offsets in `get_breakpoint_hits` are wrong for mirrored accesses** (T-21, 1.1): compute them from `address` yourself.
20. **The script output cap is 100,000 bytes per run** (T-31, MCP-43), shared by every `writeFile` and `emu.log` row of the run. A census file written in one piece loses its tail without an error that names the cap. Write in chunks of at most 3,000 bytes (`a_census.lua` does), keep `final.log` rows compact (a few thousand rows), and compare `filesWritten` with the expected size. `Mesen.run_script_checked` prints the cap warning.
21. **Lua errors are silent** (T-24, MCP-34): `run_script` returns `isError:false` for a syntax or runtime error. Use `Mesen.run_script_checked` (harness): it raises on a Lua error row, on a `stopReason` other than `script_done`, and on a run without a result.
22. **Callback timing.** A memory callback receives the full effective address (mask with `& 0xFFFF`; a banked access reports 24 bits), runs **before** the store (`emu.read` inside it returns the old byte) and sees the PC of the **next** instruction (subtract the instruction length). The counted writes of `$36` per NMI are the positive control (`control36Writes`).
23. **Freed actor slots are not cleared.** A dead actor keeps its entry word, flags and position until the slot is reused or the pool is rebuilt. "Entry word != 0" counts dead actors (the `live` and `filt` columns of the first A4 samples did). Walk the list from `$56` through `+6` (`aact.live`, `a_common.actor_table`). `docs/wram-memory-map.md` section 2.11.
24. **Actor entry bank bytes are HiROM mirrors**: ROM bank `$08` reads `$88`, `$0A` -> `$8A`, `$00` -> `$80`, `$03` -> `$83` (`a_common.rom_bank_to_entry_bank`). A test against the plain bank finds nothing.
25. **Extended actor fields are addressed with the actor id as the index**: `$7F0026,X` with `X = $1210` is `$7F:1236`; in Lua `kit.r16(0x10026 + slot)` is the HP of a slot.
26. **One server session per bot-driven experiment.** A second bot-driven run in the same session (the OQ-54 text script, T-41) did not reach its scene while WRAM/SRAM after `load_state_file` matched the first run; cause unknown. `scenario_a4_events.py` opens a fresh session per experiment; the 18 `input`-driven runs of `scenario_a4_followup.py` share one without problem.
27. **Read `extracted/` before you run anything.** Most "where is X" questions are answered by the source (a Dark Space is an actor spawned from `extracted/tables/scene_actors.asm`; a warp is a row of `scene_warps.asm`; an enemy's HP is a row of `enemy_stats_table.asm`). An exploratory scan script is not an experiment: find the object statically, then run one scenario against it.
28. **Boot-time census from a cold boot (0.6.0, verified on O).** `run_script {fromReset:"power", frames:300, includes:[...]}` with the C1 module saw: `ResetVector` (32768) and `SystemInit` (32788) once each, the first `$4200` write `82:9F47` = `$00` at frame 0 (the `NMITIMEN` row of `PpuRegisterInitTable`; the callback PC is the address after the store), the first `$01` write at frame 3 (`82:81AC`, `DisableNmiKeepJoypad`) and the first `$81` write at frame 26 (`82:819F`, `EnableNmiAndJoypad`); a "store" to `$7F:0C07` and `$7F:0C09` from one PC (`82:9F30`) at frame 1, NMITIMEN 0, value 0: a DMA (channel 0 to WMDATA, source `$81:C455`, fired by `STA $420B` in `InitSystemVariables`) zeroing WRAM; memory callbacks fire for DMA writes too, with the PC next to the trigger, so a census cannot tell a DMA write from a CPU store except by PC and frame. `scene` (`$0644`) reads garbage before the clear (7513 at frame 0): do not use it as a boot-time key. Frames 0-96 are invisible to every other way of starting (T-42).

### 1.4 The working harness (use it, extend it, do not rewrite it)

`plans/extracted-audit/mesen2-results/harness/README.md` explains it. Pieces:

| Piece | Path | Use |
|-------|------|-----|
| Python client | `harness/mcp_client.py` | `with Mesen(args=[...]) as m: m.call("load_rom", path=...)`. Parses JSON or text results, raises `McpError` on `isError`. Helpers `m.u8/u16/poke/mem/shot`. Hardened in phase 4: a reader thread so `timeout` is really honoured, tolerant of a `Content-Length` header or two JSON objects on one line (T-20), host default `net8.0\MesenMcpHost.dll`. A Cursor agent calls the same tools directly; use the client for repeated runs. |
| Lua kit | `kit/lib/gaia_kit.lua` | `gaia.log` (capped), `gaia.addr`, `gaia.coll.index/get/set/probeTile` (paged collision layer, 2.4), `gaia.player()`, `gaia.hold/release`, `gaia.trial{setup, hold, frames, sample, final}` (one trial from a loaded state, returns the samples with `kit.finish`). |
| Server modules | (none in the repo) | Since 0.5.0 `mesen_kit`, `iog_kit` and the recipes come from the server's own `lua/lib`; `--mcp-lib-dir` adds the project folder after it (MCP-21 done). The vendored copies and `verify_kit.py` were deleted. |
| Matrices | `harness/phase0_matrix.py`, `harness/probe_050.py` | `phase0_matrix.py`: H0, H1, H3, H4 on O and R (about 40 s, `raw/phase0_matrix_<date>.json`). `probe_050.py [--sessions 12345]`: the 0.5.0 feature and defect probe (shapes and edge cases, watchdog, startup flags, follow-ups, regression of recording/compare_runs/snapshots/CDL/PPU; about 50 s, `raw/probe_050_<date>.json`). Both run under `timeout`. |
| Finished scenario | `harness/scenario_b2_special_tiles.py` | Builds `S01r` for a ROM, runs 16 cases twice, writes `raw/B2_special_tiles_<tag>_<date>.json`. Pattern for every B-family test: **state, paint or poke, hold, sample, control, repeat, compare O and R**. |
| Actor Lua helpers | `kit/lib/a_actors.lua` (`includes:["a_census","a_actors"]`) | `aact.ent/hp/iframes`, `aact.setf/clrf(slot, off, mask)` (forced bits), `aact.inList(slot)` / `aact.live()` (list walk from `$56`), `aact.findEntry(lo, hi)`, `aact.tracker(from, emit)` (NEW / CHG lines for entries and `$10`/`$12`), `aact.motion()` (moved / filtered / live counts over the live list). |
| Census Lua | `kit/lib/a_census.lua` | `acen.run{frames, outFile, writes, reads, bot, timeline, input=function(n), tick=function(n), at={[n]=fn}, execs={Name=addr}, refill, final}`. `input` returns a button table or nil (nil falls through to timeline / bot); `tick` runs every frame after `at`. Result keys: `control36Writes`, `execCounts`, `stats`, `samples`, `final`. |
| Python helpers | `harness/a_common.py` | `open_session`, `quick_warp`, `actor_table(m)` (live list), `label_addresses(m, names)` (raises on a missing label), `run_experiment(m, info, name, code, frames, prefix, state, pre)` (load state, checked run, store raw JSON + screenshot), `rom_bank_to_entry_bank`. |
| Checked run | `Mesen.run_script_checked` in `harness/mcp_client.py` | `run_script` that raises `ScriptRunError` on a Lua error row, a wrong `stopReason` or a missing result and prints a cap warning (hazards 20 and 21). |
| Campaign A scenarios | `harness/scenario_a1_flag_census.py`, `scenario_a3_forced_bits.py`, `scenario_a4_followup.py` (K1-K5), `scenario_a4_events.py` (`ds`, `fw`, `talk:T0`, `talk:T2`), `view_run.py` (reader), `decode_flag_census.py` | Pattern: one atomic `run_script` per experiment from a state file, a control run and a forced run that differ in one thing, results in `raw/`. |
| First result | `B2_special_tiles_20261029.md` | Template filled in (8.1). |

Pattern of a trial script (use it for every physics question):

```lua
gaia.trial{ frames = 40, hold = {"right"},
  setup  = function() --[[ clear cells, paint the tile under test, place the player, zero the speeds ]] end,
  sample = function() local p = gaia.player(); return {p.x, p.y, p.sEw, p.sNs, p.flags10} end,
  final  = function() return {} end }
```

Rules the harness proved: every case gets a control (an unpainted run, a solid-tile run that must stall) and a repeat that must be identical; run the same script on O and R and diff the samples; the quick warp builds the base state in about 350 frames, so build the state once and `load_state_file` per trial.

---

## 2. Address model

### 2.1 Two ROMs, two build modes

| ROM | File | Use it for | Addresses |
|-----|------|-----------|-----------|
| **Original** `O` (2,097,152 bytes) | `rebuilt/Illusion of Gaia.smc` | **Default.** Every behaviour question about vanilla game logic. | The decimal key in `db-us/names/bankNN.json` and the decimal in the `; {n}` line tags of `extract:lt` output **are** the ROM file offsets. No lookup needed. |
| **Rebuilt** `R` (3,080,192 bytes on disk) | `rebuilt/Illusion of Gaia - Rebuilt.smc` | Questions about things the baserom changes: the button remap (OQ-I057-1, OQ-I044-4, OQ-I028-1), `transforms.json` effects, the `SceneMetaLoad` patch (OQ-I065-2), dictionary rebuild (OQ-I070-1). | Look up the label in `artifacts/master-lookup.json` (label in upper case to hex PRG offset, e.g. `"COPYSIBLINGFOLLOWSTATE": "008000"`). Use `artifacts/file-layout.json` for file starts. |

Identities measured 2026-10-29 (`get_rom_info`):

| Tag | File | Size | SHA-1 | CRC-32 | Notes |
|-----|------|-----:|-------|--------|-------|
| O | `rebuilt/Illusion of Gaia.smc` | 2,097,152 | `38de0c84dd2bc3bdfc0a3d7ab0220c79b70887c3` | `1c3848c0` | HiROM FastROM, header checksum `0xBEA9`. Label file `artifacts/labels/iog-original.mlb` (3510). |
| R main | `rebuilt/Illusion of Gaia - Rebuilt.smc` | 3,080,192 | `795c7a8cb8924766d5c378ac1d92364d127e1d2a` | `c426ee65` | **Plain** build (see below). Label file `artifacts/labels/iog-rebuilt.mlb` (3509) matches it. Built 16:32:01 on 2026-10-29. |
| R variant | `rebuilt/variants/plain.smc` | 3,080,192 | `2e4a88a3de6dd4bdefc23c0dd626b953c18fe808` | - | Built 17:53; 70,099 bytes differ from R main; no artifacts, so no label file. |

R has a **mode**: `tagged` (after `extract:lt` + `rebuild`; the audit gate: `artifacts/crc.json` checksum 223006080, crc 2083230829, totalSize 3062204) or `plain` (after `extract` + `rebuild`; `crc.json` today: checksum 222967024, crc -1004081563, totalSize 3062189). Rules:
1. Every R result records the SHA-1, the mode and the `crc.json` triple next to it. How to tell the mode: `crc.json` `mode` (present only for builds made after B-01, see `docs/mesen2-exports.md`), otherwise the `; {n}` tags in `extracted/` at the time of the build (absent = plain) and the `totalSize`; the newest `GATE:` line of `audit-of-audit/ACTION_PLAN.md`; otherwise ask the user. Never run `extract`, `extract:lt` or `rebuild` in an investigation step. A tagged and a plain file for the experiment is built by the user with `npm run extract:lt && npm run rebuild -- extracted rebuilt/variants/tagged.smc --artifacts-dir=temp/tagged` and the plain counterpart (`docs/mesen2-exports.md`).
2. Experiments that touch a plain-only block (1.3 item 6) run on R-plain until IT-27 is DONE. Everything else may use R-tagged.
3. After IT-27 plain and tagged are identical and the question disappears.

Both ROMs boot and take the debug warp (section 4, H3): verified. Bank `$00` code looks unmoved between them, but code later in the ROM moves in the rebuilt ROM, so never reuse an address list across the two.

### 2.2 HiROM CPU address to ROM offset

`offset = (bank << 16) | (address & 0xFFFF)` for banks `$C0-$FF` (and `$80-$BF` when the address is `>= $8000`; the low half of `$80-$BF` maps WRAM/registers). Example: CPU `$80:837F` is ROM offset `0x837F`. `get_prg_rom_offset` does the same conversion.

### 2.3 Memory types to use

| Target | memType (Lua) | MCP `type` | Address meaning |
|--------|---------------|------------|-----------------|
| WRAM (`$7E:0000-$7F:FFFF`) | `emu.memType.snesWorkRam` | `workRam` | `$7E:xxxx` = `0xxxxx`, `$7F:xxxx` = `0x10000 + xxxx` |
| ROM | `emu.memType.snesPrgRom` | `prgRom` | file offset |
| CPU address space | (callbacks) `emu.memType.snesMemory` | `snesMemory` | 24-bit CPU address; **bank-alias specific** (1.3 item 4) |
| VRAM | `emu.memType.snesVideoRam` | `snesVideoRam` | byte address (word address x 2); verified read at `0x2000` |
| OAM | `emu.memType.snesSpriteRam` | `snesSpriteRam` (decoded: `get_oam`) | byte offset |
| CGRAM | `emu.memType.snesCgRam` | `snesCgRam` (decoded: `get_palette_info`) | byte offset (colour `n` at `2n`); verified |
| SPC RAM / DSP | `emu.memType.spcRam` / `spcDspRegisters` | `spcRam` | ARAM offset; verified read |

### 2.4 Key WRAM addresses (offsets; checked against `docs/wram-memory-map.md` and `iog_bootstrap.lua`)

| Name | Offset | Name | Offset |
|------|--------|------|--------|
| `frameCounter` | `0x0036` (DP `$36`) | `sceneNext` | `0x0642` (0 = idle) |
| `sceneCurrent` | `0x0644` (boot logo = `$FB`, verified) | `warpDestX/Y` | `0x064C/0x064E` |
| `warpFacing` | `0x0650` (bit 7 = save warp) | `warpScrollParams` | `0x0652` (0 = normal bounds) |
| `joypadCurrent` | `0x0656` | `joypadMaskStd` | `0x065A` (nonzero = scripted input lock) |
| scene-title wait flag | `0x00B4` (nonzero = banner waits for a button) | `musicParentActor` = BGM id | `0x06F2` |
| `displayModeFlags` | `0x09EC` (word; high byte `0x09ED` = `hudDisableFlag`) | `playerActor` | `0x09AA` (value `$1000`, verified) |
| `playerX/Y` | `0x09A2/0x09A4` (8 and 16 px **less** than the actor position `0x1014/0x1016`) | `playerHp / maxHp` | `0x0ACE / 0x0ACA` |
| `characterForm` | `0x0AD4` | `invEquippedIdx` | `0x0AC4` |
| item slots | `0x0AB4-0x0AC3` | `event flags` | `0x0A00-0x0AFF`: flag `#n` = byte `0x0A00 + (n >> 3)`, bit `n & 7` (this is the convention of the server's bootstrap script, which sets flag `$3F`; H3 confirms it) |
| actor slot fields | base `0x1000 + 0x30*k` (k = 0..83; `$30` bytes per slot, verified in Campaign A, T-37) | collision layer | WRAM `0x1C000` (`$7F:C000`), paged, see below; an index of `$4000` or more is out of range |
| `mapBoundsX / mapBoundsY` | `0x0692 / 0x0696` (South Cape: `$0300` / `$0400` pixels, confirmed at run time) | `mapRowStrideL0` | `0x0693` (page width in pages; South Cape = 3) |
| player `posX` | `0x1014` (verified: `664` at South Cape start) | player `$10` flags | `0x1010` (word) |
| actor count | `0x0DBC` | body-table row | `0x0AC8` |

**Collision layer (confirmed statically and at run time on 2026-10-29; the earlier formula `0x1C000 + row*stride + col` was wrong).** WRAM `0x1C000` holds 256-byte **pages** of 16 x 16 cells (a cell is 16 x 16 pixels), pages in row-major order:

`index = (((ty >> 4) * stride + (tx >> 4)) << 8) | ((ty & 15) << 4) | (tx & 15)`, byte at `0x1C000 + index`

with `tx, ty` in cells, `stride = $0693`. South Cape: stride 3, a 48 x 64 cell grid (bounds `$0300` x `$0400` pixels). The `[$80]` pointer is `7F:C000` (`LDA [$80], Y`). The **low nibble** of the byte is the base type `$00-$0F`; a nonzero **high nibble** is a dynamic block mark that `ReadCollisionNibble` prefers (the cell is then treated as solid at once). `$069A/$069C` (both `$0C00` in South Cape) are something else. `gaia.coll.index/get/set` in the kit implement this. South Cape facts for tests: open room cells (19-27, 7-13), corridor rows 46-47 columns 11-41, type `$06` 16 cells and `$09` 18 cells in diagonal staircases.

Actor field offsets (slot-relative): `+08 waitCounter`, `+0E oamXorFlags`, `+10 Flags10`, `+12 Flags12`, `+14 posX`, `+16 posY`, `+20..23 hitbox W/E/N/S`, `+24/+26 scratch`, `+28 sprIdx`, `+2A sprFrame`, `+2C/+2E move`. Player facing: 0 = down, 1 = up, 2 = left, 3 = right.

---

## 3. Conventions used by every experiment

| Item | Rule |
|------|------|
| **Experiment ID** | `H0-H6` harness; `A1-A3` flag bits; `B1-B4` collision and movement; `C1-C4` engine/DMA/display flags; `W1` generic address census; `D1-D3` audio; `E1-E4` display; `F1-F3` sprites; `G1-G4` combat; `M1-M4` menus and text; `N1-N4` actors and scripts; `P1,P2,P4` player and camera; `R1-R3` reachability; `S1` static (owned by IT-35); `T1` tooling (owned by IT-26..IT-30); `V1` claim confirmations; `Z1` closure. |
| **Evidence grade** | `VERIFIED-RUNTIME` (observed, with a positive control), `VERIFIED-STATIC` (read from ROM bytes), `CONTRADICTED` (observation disagrees with the current note: quote the note, file:line), `INCONCLUSIVE` (state what is missing). Ladder: E1 code trace, E2 cross-reference, E3 docs, E4 hardware docs, **E5 runtime**. |
| **ROM tag** | Every result names the ROM (`O` original, `R` rebuilt with mode `tagged` or `plain`), its SHA-1 and the state file used. |
| **Positive control** | Every watch is paired with a control that is certain to fire (for example the `INC $36` write in the NMI). A zero-hit result without a firing control in the same run is discarded. |
| **Absence claims** | "Never written / never read / never executed" needs a coverage statement: scenes visited, frames, forms, and which of them could reach the code. Without it the grade is `INCONCLUSIVE`. |
| **Static first** | Before the run, `rg` the extracted code for the question's static evidence. Rows marked `†` in the inventory have a static pointer: confirm or refute it. |
| **Ticks** | `WaitByte #n` / `WaitWord` / `$08` counters = n+1 ticks. Measure in NMI frames (`frameCounter` `$36` deltas) and report the observed count next to n+1. |
| **Buttons** | Name the logical bit and the physical button. Physical (`vblank_joypad.asm`): B `$8000`, Y `$4000`, Start `$1000`, Select `$2000`. Logical bits of this build (`transforms.json:755-758`): `remapB $4008`, `remapA $8080`, `remapY $0040`, `remapX $0004`; the interact bit `$0080` is fed by A, cancel `$4000` by B. |
| **Words** | "slot" (actor / thinker / palette / VRAM), "group" (music room / sprite header / drop), "frame" (animation frame / tick / NMI frame): say which. |
| **Log cap** | Max 200 lines per script. Summaries every 60 frames, not per frame. |
| **Output file** | `plans/extracted-audit/mesen2-results/<exp>_<yyyymmdd>.md` (section 8.1). |

---

## 4. Phase 0 - harness (do this first, about one session)

Nothing else starts until H0-H4 pass. Each step has a prompt in section 12.

### H0 - Bring-up and ROM identity

1. `load_rom` (original), `pause` (`get_capabilities` fails before a ROM is loaded, T-16 on 0.4.0; it works without a ROM since 0.5.0), then `get_capabilities` (expect server 0.6.0 or later, Mesen 2.1.0, 81 tools) and `self_test` (expect 17/17). If the version is older, stop: 1.0.
2. The `load_rom` reply carries `rom{fileSha1, fileCrc32, fileSizeBytes}`: compare with the table in 2.1 (SHA-1 `38de0c84...`).
3. Boot check: `advance_frame 120`: `read_word 0x644` is `0x00FB` (boot logos). `advance_frame` to frame 400: `0x00FC` (title). Verified (phase 3 matrix): `$FB` at frame 121 on both ROMs; `$FC` is reached within frame 360 on O and within frame 311 on R (10-frame polling), so "`$FB` at frame 700" (the earlier criterion) is **wrong**. After `advance_frame 700` the frame counter reads 701.
4. Repeat 2 and 3 for the rebuilt ROM (SHA-1 `795c7a8c...`). Pass: both reach `$FC`. (`mesen2-results/harness/phase0_matrix.py` runs H0, H1, H3 and H4 on both ROMs in about 40 s and writes `raw/phase0_matrix_<date>.json`; use it instead of doing 2-4 by hand.)
5. Record, per ROM: path, file size, SHA-1, CRC-32, the `artifacts/crc.json` triple (and `mode`/`sha1` if present), the build mode of R (section 2.1), the newest `GATE:` line.

### H1 - State library and the validity test

**Why:** hazard 1 in section 1.3. A state is only valid for the exact ROM file. Since server 0.4.0 the server enforces it.

Rules:
1. States live in `rebuilt/states/` (already git-ignored). Name: `<O|R>_<id>_<description>.mss`, for example `orig_S01r_south-cape-ready.mss`. R states carry the mode: `R-tagged_...` or `R-plain_...`. Create every state with `save_state_file` (it writes the `<state>.json` sidecar with the ROM SHA-1, CRC, frame, and a `meta` object: pass `{scene, flags, form}`).
2. The index is `plans/extracted-audit/mesen2-results/states-index.md` (versioned; the states folder is not): one row per state with ROM tag, **ROM SHA-1**, mode, scene id, event flags written, form, how it was made, date. `list_states {dir}` reports the same facts from the sidecars with a `valid` flag for the loaded ROM; the index adds the recipe. A rebuild that keeps the gate numbers keeps the SHA-1, so the state survives; a changed SHA-1 invalidates every `R` row.
3. **Validity test**: `load_state_file` must succeed (a wrong ROM raises `rom_mismatch`; verify once per ROM pair by loading the R state into O). A state **without** a sidecar is refused (`no_sidecar`, verified): re-create it, or pass `requireRomMatch:false` knowingly and then do the scene check below. Then `advance_frame 120` and check `cpu.k` in `$80-$BF` or `$C0-$CF`, `cpu.sp` in `$0100-$01FF` and `sceneCurrent` equal to the expected id. If a check fails mark the row stale (do not delete a file you did not create).
4. Two clean states exist: `orig_S01r_south-cape-ready.mss` and `R-plain_S01r_south-cape-ready.mss`.

### H2 - Lua kit (include, do not paste)

The kit is a set of modules in `mesen2-results/kit/lib/` (the folder passed as `--mcp-lib-dir`): the project's `gaia_kit` (the only file there); `mesen_kit`, `iog_kit` and the recipes come from the server's own `lua/lib` (0.5.0). A script says `includes: ["gaia_kit"]` in `run_script` (the `requires:` header pulls the other two). What the modules give you:

| Module | Functions |
|--------|-----------|
| `mesen_kit` (`kit`) | `kit.r8/r16(addr, memType?, signed?)`, `kit.w8/w16(addr, v, memType?)` (default memType WRAM), `kit.setBit/getBit`, `kit.onFrame(fn)` / `kit.off(handle)`, `kit.machine{...}` (state machine), `kit.pulse/stopPulse` (button pulses), `kit.topCounts`, `kit.finish(result)` |
| `iog_kit` (`iog`) | `iog.setEventFlag(id)`, `iog.getEventFlag(id)`, `iog.state()`, `iog.warp{scene, x, y, facing, scroll, flags, delay, dismissBanner}` |
| `gaia_kit` (`gaia`) | `gaia.log` (200-line cap), `gaia.addr` (named WRAM offsets), `gaia.coll.index/get/set/probeTile`, `gaia.player()`, `gaia.hold/release`, `gaia.trial{...}`, `gaia.watch{...}` / `gaia.once` / `gaia.censusRows()` (W1) |

Minimal script (the pattern of every experiment):

```lua
-- run_script {includes:["gaia_kit"], frames:300, turbo:true}
gaia.watch{
  {name='CONTROL frame36', lo=0x36, hi=0x36, kinds={'write'}},        -- must fire
  {name='forcedScroll',    lo=0x06C8, hi=0x06C9},
}
kit.onFrame(function(f) if kit.r16(0x36) % 300 == 0 then kit.finish({rows = gaia.censusRows()}) end end)
```

Test: South Cape, 300 frames: `CONTROL frame36 write 80:8381` (14 hits in the first 15 frames), `joypadMask read 82:818B`. To add a helper put it in `gaia_kit.lua` (project) or ask for it in the server (never edit the server's modules). Per-frame traces: return a table with `kit.finish`; print nothing per frame. CGRAM and VRAM dumps: `read_memory` with `snesCgRam`/`snesVideoRam`, or `get_palette_info`; no helper needed.

### H3 - Debug warp and flag recipes

Two warps exist; both **verified** on 2026-10-29.

**Quick warp** (no code, no coordinates): `write_word 0x642 = <scene id>`, `advance_frame 240-300`. Works from the boot logo (about frame 100), **from the title screen `$FC`** (phase 3: frames 450, 700 and 1200, each landed on `$01`; the earlier "does nothing from the title" is obsolete, T-17) and from an in-game scene. The player lands on the scene's default spawn, the scene banner flag `$00B4` is `0xE0` until A is pressed (`set_input buttons ["a"] frames 2`, `advance_frame 4`, repeat until `$B4 == 0`). No event flags are set. Measured (phase 3, from the South Cape state, 300 frames, then the banner dismissed with A): spawn actor position and `joypadMaskStd $065A` after the warp/after the banner are in the table below. South Cape `$01` spawn actor (664, 752).

| Scene | Spawn (x, y) | Mask on arrival | Banner `$B4` | Mask after A | Screenshot (`raw/screenshots/`) |
|-------|--------------|-----------------|--------------|--------------|--------------------------------|
| `$08` Church | 88, 176 | `CFF0` | `E0` | `0000` | `H3_scene_08_713.png` |
| `$0A` Edward's Castle | 88, 160 | `CFF0` | `E0` | `CFF0` (the guard lock: needs flag 63) | `H3_scene_0A_713.png` |
| `$15` Itory Village | 728, 688 | `0000` | `E0` | `0000` | `H3_scene_15_713.png` |
| `$24` | 88, 160 | `0000` | none | `0000` | `H3_scene_24_707.png` |
| `$E8` | 136, 224 | `0000` | none | `0000` | `H3_scene_E8_707.png` |
| `$FD` | 48, 48 | `FFF0` | none | `FFF0` (input locked by design) | `H3_scene_FD_707.png` |
| `$FE` | 14424, 56 | `FFF0` | none | `FFF0` (input locked by design) | `H3_scene_FE_707.png` |

Screenshots read in phase 3: `$08` the church interior with four characters and a **dialogue box already open** (the scene script starts at once, so the mask reads `0000` while a message is up: do not use `$065A` alone to decide that the player is free); `$0A` the castle room with Will and the princess; `$15` the stair path above Itory; `$24` a stone-wall dungeon corridor; `$E8` the planet-horizon scene (sky and a sphere, Will at the bottom); `$FD` a blue stone tower with pillars and a small figure at the top left; `$FE` the world map with the scroll at the top-left corner (black above and left of the map).

The recipe (full warp) is the way to unlock `$0A`: `run_recipe warp {scene:10, flags:[63]}` ends with mask `0000`; the same recipe without the flag ends with `CFF0` and stays there 60 frames later. This is how `S01r` was built (about 377 frames in all).

**Full warp** (`run_recipe warp {scene, x, y, facing, scroll, flags[], delay, dismissBanner}` or `iog.warp{...}` in a script; it is the state machine of `iog_bootstrap.lua`): wait for `sceneNext == 0`, set the event flags (flag `#n` = `0x0A00 + (n >> 3)` bit `n & 7`; Edward's Castle needs `$3F`, otherwise the guard locks the joypad), write `warpDestX $064C`, `warpDestY $064E`, `warpFacing $0650` (bit 7 = save warp), `warpScrollParams $0652`, then `sceneNext $0642 = id` **last**; wait for `sceneCurrent == id`; dismiss the banner with A pulses; check `joypadMaskStd $065A == 0`. The recipe **always** writes `warpDest*` (defaults x `0x60`, y `0x370` = Edward's Castle), so on 0.4.0 any other scene needed `x` and `y`. **0.5.0 adds `quick: true`** (write `sceneNext` only, keep the default spawn, set `flags` first; `x`, `y`, `facing`, `scroll` ignored) and switches to it **automatically** for a scene other than `$0A` given without `x` and `y`. Verified from the South Cape state: `{scene:21, quick:true}` 350 frames, player (720, 672), `ok`; `{scene:8}` (auto quick) 293 frames, `inputMask 0xCFF0` (dialogue running, hazard 18); `{scene:10, quick:true, flags:[63]}` 359 frames, mask `0000`, player (80, 144); from the title (frame 420) `{scene:1, quick:true}` 493 frames, `ok`. `{scene:10, flags:[63]}` took 358 frames from a fresh boot and 359 from the South Cape state on O and **230 frames on R-plain** (R boots faster), and returned `{scene:10, x:96, y:880, hp:8, maxHp:8, inputMask:0, banner:0, ok:true}`; the actor position is then (104, 896). Start it from a clean state: after a failed quick warp from the title it timed out (`warp_timeout`).

Scene ids: `db-us/groups.json` (also `artifacts/scenes.json`, 228 ids, and `db-us/scene-flags.json`).

Caveats to settle in H3:
- Scenes that dump the player in a wall need the spawn position (`warpDest*`): read it from a quick warp (spawn actor `$1014/$1016` minus 8/16 gives `x`/`y` for the recipe).
- Record the flags each state needs in `states-index.md`.
- Changing form (`0x0AD4`), HP (`0x0ACE`) and item slots (`0x0AB4...`) with `write_word` is the cheap way to get Freedan, Shadow, abilities and items. Validate each by screenshot.

Pass: reach `$01`, `$0A`, `$15`, `$24`, `$E8`, `$FD`, `$FE` and confirm the scene id, `$065A == 0` where the player is expected to move, and a plausible screenshot for each. **Done (phase 3, `phase0_matrix.py`, O):** `$01`, `$08`, `$0A`, `$15`, `$24`, `$E8`, `$FD`, `$FE` by quick warp, `$0A` by recipe (O and R-plain, with and without flag 63). **Left for a session:** the quick warp on R, and the recipe for scenes that need coordinates. The seven screenshots were read (descriptions above).

### H4 - Positive controls (the "do the tools work today" matrix)

Run once per ROM from `S01r`, keep the output in the results file. The first control set uses **native count breakpoints** (independent of Lua), the second the Lua callbacks; the two must agree.

```text
set_breakpoints [
 {callbackType:"write", startAddress:54,    endAddress:54,    memType:"snesWorkRam", action:"count", name:"w36"},
 {callbackType:"read",  startAddress:1622,  endAddress:1623,  memType:"snesWorkRam", action:"count", name:"r656"},
 {callbackType:"exec",  startAddress:<NMI>, endAddress:<NMI>, memType:"snesPrgRom",  action:"count", name:"nmi"} ]
advance_frame 120 turbo;  get_breakpoint_hits;  clear_breakpoints
```

`<NMI>` is the offset of `NmiHandler` **for this ROM**: 33528 on O, `0x967C` (38524) on R main (1.3 item 8); get it with `load_labels` + `get_label_address NmiHandler`. Same controls in Lua: `gaia.watch{ {name='w36', lo=0x36, hi=0x36, kinds={'write'}}, {name='r656', lo=0x656, hi=0x657, kinds={'read'}} }` and an exec callback on the NMI offset.

Pass criteria (all must hold): the `w36` and `nmi` counts equal the number of frames advanced (verified on O: 119 in 120 frames; 179 in 180 for the Lua callbacks); the exec count of the **other** ROM's NMI offset is 0 (this proves the offset is ROM-specific); `r656` grows.

Measured 2026-10-29 (phase 3, `harness/phase0_matrix.py`, `raw/phase0_matrix_20261029.json`), from `S01r`, 120 frames:

| Control | O (NMI 33528) | R-plain (NMI 38524) |
|---------|---------------|---------------------|
| native count write `$36` | 119 | 119 |
| native count read `$656-$657` | 2,067 | 2,543 |
| native count exec at the ROM's NMI offset | 119 | 119 |
| native count exec at the **other** ROM's NMI offset | 0 | 0 |
| `get_access_summary` 16-byte NMI range, 60 frames | `exec 60`, `bytesTouched 1` | `exec 60`, `bytesTouched 1` |
| Lua callbacks to the next multiple of 120 (`$36`) | w36 14, nmi 14, event 14, r656 242 | w36 71, nmi 71, event 71, r656 1,515 |

The Lua and native counts agree (each run stops at a different frame, so only the w36 = nmi = event equality counts). The `$656` read count differs between the ROMs (2,067 and 2,543 in 120 frames, same scene, different build): a code or timing difference, not a tool difference.

Matrix of the tool features (status measured 2026-10-29 on O and R-plain; no difference found between the ROMs):

| # | Feature | Result |
|---|---------|--------|
| a | `emu.write` into WRAM | works (B2 paints tiles; the warp recipe writes flags) |
| b | native halting exec breakpoint at the NMI | works: `advance_frame` returns `stopReason: breakpoint`, `framesAdvanced: 1`, `cpu.pc24 = 0x8082F8`; `snesMemory $00:82F8` never fires (alias) |
| c | `emu.setInput` in `inputPolled` | works (`gaia.hold`) |
| d | `emu.getAccessCounters` / `get_access_summary` | works (`NmiHandler` row `accessed`) |
| e | ROM hash | `get_rom_info.fileSha1` and `emu.getRomInfo().fileSha1Hash` |
| f | `emu.createSavestate`/`loadSavestate` | works inside an exec callback (1.2) |
| g | `get_emulator_state`, `get_callstack` | work (`cpu` block with `PC`, `K`, `DBR`, `PS` string; callstack with labels) |
| h | `step_instruction` then `get_emulator_state` | synchronous: no race; `pcs` lists the stepped PCs |
| i | `take_screenshot` twice, one frame apart | distinct `frame`/`renderedFrame` and file names (`<label>_<frame>.png`) |
| j | SPC: `emu.getState()` keys `spc.*`, an exec callback with `emu.cpuType.spc` on `spcRam`; `read_memory spcRam` | works: 7,001 SPC exec hits in 8 frames, PCs `05C0/05C2/05C3`; `$F4-$F7` read callbacks fire; **0 hits after `rewind`** (T-13) |
| k | `record_input`/`play_input_file` determinism, `compare_runs` O vs R | works (1.1) |
| l | `step_cpu_cycles`, `set_cpu_state {x,y}`, `get_timing_info`, `get_tilemap_size`, `get_profiler_data` | work |
| m | `start_trace`/`stop_trace` with `pcRanges` and `maxLines` | works (`H4_trace.txt`, 40 lines, SHA-1 in the reply) |
| n | `dump_memory` of `0x1C000`, 8192 bytes | works (`H4_collision_layer.bin`, SHA-1 `2c0f5a...`) |
| o | `emu.mcp.writeFile`, `io`/`os` nil | works / confirmed |
| p | `subscribe_events` | works (0.5.0: named, rate-limited count events; 0.4.0: payload-free, 1.1) |
| q | count breakpoint with condition; halting breakpoint with condition | work (`(value & 1) == 0` counted 49 in 100 frames; `value == 0x55` halted after 135 frames) |
| r | `revert_rom_changes` | works ("Performed 1 undo operation(s)") |
| s | `rewind` | 0.5.0 **works** (`framesRewound` 120 for `seconds:2`, SPC callbacks alive after it, 9 s at frame 617); 0.4.0 was broken (T-13, T-14) |
| t | `step_scanline` | returns at once; one 251 s hang on 0.4.0 (T-12); `timeoutMs` honoured on 0.5.0 |
| u | `get_execution_trace` | returns no rows when paused; use `start_trace` |

Experiments that depend on a failed feature fall back to the verified alternative given in each experiment. Add each failure to `tool-issues.md`.

### H5 - Results capture

Exists (2026-10-29) in `plans/extracted-audit/mesen2-results/`: `states-index.md`, `closures.md` (append-only: date, id, verdict, grade, result file, build mode, ROM SHA-1), `tool-issues.md` (T-01 to T-30), `kit/lib/` (only `gaia_kit.lua`), `harness/` and `raw/` (JSON data, screenshots, traces; set `--mcp-results-dir` to it). Each session creates `mesen2-results/<exp>_<yyyymmdd>.md` with the template of section 8.1 (`B2_special_tiles_20261029.md` is a filled example). Delete `raw/slots/` and `raw/sub/` after a session that used `slot` or the writeFile probe (T-10).

### H6 - State library build

Build the `S` states of section 5 that the next sessions need: quick warp where no flags are needed, the recipe `warp` where they are, `save_state_file` with `meta {scene, flags, form}`, the validity test of H1 on each, and a row in `states-index.md`. Per state about 400 frames, so a batch of ten takes under a minute of emulation.

---

## 5. State library (build once, reuse)

IDs are for the original ROM unless prefixed `R-tagged_` / `R-plain_`. An `R` state is valid while the ROM SHA-1 is unchanged.

| State | Recipe | Used by |
|-------|--------|---------|
| `S00_boot` | `load_rom`, pause, frame 0 | C3, M2 |
| `S01_south-cape-start` | quick warp to `$01`, 240 frames, banner dismissed, 30 frames (**exists** for O and R-plain as `S01r_south-cape-ready`; the older `orig_S01_south-cape-start.mss` has no sidecar) | A1, A2, B2, P1 |
| `S02_new-game-church` | Warp to `$08` (the new-game start) | M2, P1 |
| `S03_itory-village` | Warp to `$15` | M1, N1 |
| `S04_edward-castle` | Warp to `$0A` with flag `$3F` | M3 |
| `S05_gold-ship` | Warp to `$24` | M1, G3 |
| `S06_title` | Cold boot, wait until `sceneCurrent == $00FC` (about frame 350; `$FA` is the **diary menu**, not the title) | M2 |
| `S07_diary` | Title -> diary screen (scene `$FA`), by input; the quick warp does not work from the title | M2 |
| `S08_world-map` | Scene `$FE` | M3, E3 |
| `S09_inventory` | Open inventory from `S01` | M1 |
| `S10_combat-room` | A scene with enemies, full HP, Will | G1, G2, A1 |
| `S11_freedan` | `S10` with `characterForm` set to Freedan | P2, A1 |
| `S12_shadow` | `S10` with form set to Shadow | P2, A1 |
| `S13_slope-field` | Natural slope scene found by B1 | B3, B4 |
| `S14_ramp-scene` | Great Wall / ramp scene found by B1 | B4 |
| `S14b_ir21-ns-ramps` ... `S14g_scB5-glide` | Six scene-spawn states made by B4 (`$21` N/S ramps, `$22` booster, `$41` boosters (unused), `$62` Mu, `$A1` N/S ramps, `$B5` glide); see `mesen2-results/states-index.md` | B4, B-addendum |
| `S15_darkspace` | Dark Space room `$E6` | N3 |
| `S16_comet-lair` | Scene `$E8` | N2, N3, G2 |
| `S17_statue-ceremony` | Scene `$FD` | E1, N2 |
| `S18_chest-room` | Scene with a chest (`$60`/`$61` for the empty ones) | M1, D1 |
| `S19_hdma-scenes` | One state per HDMA scene named in the E4 list | E4 |
| `R-<mode>_S01`, `_S09`, `_S08` | Rebuilt-ROM copies of `S01`, `S09`, `S08` | P1, M1, M2 |

---

## 6. Generic techniques (referenced by many experiments)

### 6.1 W1 - Address R/W census by PC (answers "who reads or writes X?")

About 60 questions ask "who reads/writes address X". One script handles a whole batch. Run it during a 5-10 minute play session that visits towns, a dungeon with enemies, a menu, a chest, a warp and a cutscene. Save the scene list visited in the result.

For actor flag censuses: the slot stride is `$30` (84 slots, `$1000`-`$1F90`); a freed slot keeps its old contents, so group writes by slot only together with the scene and the entry word at the time (the census records `slot0`, `scene0` and `form0` of the first hit); `control36Writes` (the `$36` write count) is the positive control of every `acen.run` and must be about one per frame.

Run it as `run_script {includes:["gaia_kit"], frames:N, turbo:true}` (for a long play session use `load_script` and `advance_frame`/`play_input` in several calls, then `get_script_log {name}`). Edit the watch list only:

```lua
gaia.watch{
  {name='CONTROL frame36', lo=0x36,   hi=0x36,   kinds={'write'}},   -- must fire
  {name='forcedScroll',    lo=0x06C8, hi=0x06C9},                    -- read and write
  {name='layerPrio',       lo=0x06EF, hi=0x06EF},
  {name='AA',              lo=0x00AA, hi=0x00AB},
}
-- end the run with the table: kit.finish({rows = gaia.censusRows()}) from a frame callback,
-- or read the log lines (each unique "name kind K:PC" is logged once, counts accumulate).
```

Flag **bits**: `gaia.watch{{name='dmf bit3', lo=0x09EC, hi=0x09EC, kinds={'write'}, bits=0x08}}` logs only writes that change a bit of `bits` (old `~` new). Without a tool-side filter, `kit.r8(a)` inside a write callback is the old byte (the callback runs before the write).

Native alternative (no Lua, independent control): `set_breakpoints` with `action:"log"` (`pcHex`, registers, frame per hit, `maxLogged`) and `action:"count"`; `get_breakpoint_hits`. Use the Lua census to find unique PCs and the count breakpoints to confirm the totals. For routine reachability use `get_access_summary` (6.2). `run_recipe census_pc {top, sampleEvery}` samples the PC at every frame end (where the main loop spends time), it is not an access census.

Post-process: for each logged `K:PC`, take the instruction that **ends** at that PC (`80:8381` after `INC $36` at `80:837F`). With labels loaded (`load_labels` of `artifacts/labels/iog-original.mlb`), `resolve_address {cpu:"80:8381"}` names the routine (and `get_disassembly {address}` shows the code around it). The instruction itself: `rg -n "; \{<offset>\}"` in the `extract:lt` output, where `<offset>` is the decimal ROM offset (labels change, so record the offset first). A write that never appears in a long, varied session is evidence (not proof) of "never written". An **absence** claim needs the session coverage statement in the result. If the `; {n}` tags are not in `extracted/`, say so and ask the user to run `npm run extract:lt`; do not run it in an investigation step. The callback `addr` can be a CPU alias (`0x81065A`): mask with `& 0xFFFF` (T-11).

### 6.2 R1 - Execution coverage (answers "is this routine ever executed?")

After a long session (or the union of several sessions), ask the server for the counters of named ranges instead of looping in Lua:

```text
get_access_summary {type:"prgRom", ranges:[{name:"NmiHandler", label:"NmiHandler", length:16},
                                          {name:"particle_rain_spawner", start:<decimal offset>, length:<n>}, ...]}
-> rows {name, start, end, exec, read, write, bytesTouched, verdict: accessed|never_accessed, cdlFlags, cdlCodeBytes, cdlDataBytes}
get_cdl_data {format:"ranges", flagMask:1}      # merged runs of code (flag 1); `summary` for totals
save_cdl {path} / load_cdl {path} / reset_cdl   # archive a run, union several runs
```

Address source: the label's decimal key in `db-us/names/bankNN.json` (original ROM), or `label` with the label file loaded. Counters accumulate from `load_rom` (`reset_access_counters` clears them). The `exec` figure is a sum over the range's bytes: use it for "zero or not", and a count breakpoint for rates. Lists of hundreds of ranges: one call per 100 rows; keep only `never_accessed` rows (the dead-code candidates) in the result. The recipe `run_recipe exec_coverage {start, stop, top, minHits}` (CPU address range, default `$00:8000-$00:FFFF`) lists the addresses executed in its window.

A zero count over a broad session is evidence of "not reached", **not** proof. Combine with the static pointer scan (R3). The CDL data flag adds a data-read flag, useful for tables ("never read" claims). The UNREF, CAM and PBUNDLE groups share the **method**, not the object: record a verdict **per member id** (A12 §4).

### 6.3 Variant trials from one state

For physics questions: `load_state_file`, one `run_script` with `gaia.trial{setup, hold, frames, sample, final}` (the trial pokes, holds buttons for exactly N frames, samples each frame and returns the table), change one variable, repeat. Keep a table of (variable, outcome) in the result. Always add a control trial and run each trial twice (the result must be identical); run the same script on O and R and diff the samples (the harness does this: `scenario_b2_special_tiles.py`). For input sequences that are not a held button use `play_input {sequence}` or `record_input`/`play_input_file` (deterministic). To run many variants inside one script, `emu.createSavestate()` in an exec callback and `emu.loadSavestate(s)` (verified, 1.2).

### 6.4 Visual capture

`take_screenshot {label, layers, crop, scale, returnImage:false}` for the picture (the PNG path is in the reply; `layers:["obj"]` isolates sprites; use `returnImage:false` in loops). For exact values: `get_palette_info {first, count, format:"rgb555"}` or `read_memory type:"snesCgRam"`, `get_ppu_state` (decoded registers: layers, color math, windows, OAM mode), `get_tilemap_info`, `get_dma_state` (HDMA channels), `get_oam {onlyOnScreen}` (decoded sprites), `read_memory type:"snesVideoRam"` / `"snesSpriteRam"`. Always record the scene id and frame.

### 6.5 Static-first prelude

Every experiment starts with `rg`/`Read` on the static evidence named in the question file (and the `†` pointer of the inventory, if any), and on the `extracted/` source of the object under test: scene actor rows, warp rows, stats rows and the handler that is supposed to react. Do not write a scanning or exploration script to find something the source already names; a scan is only for confirming at runtime what the source says a slot holds (`harness/explore_a4.py`). Write the static finding in the result before the run. A runtime result that agrees with a static finding is `VERIFIED-RUNTIME` and upgrades the note from "static" to "observed"; one that disagrees is `CONTRADICTED`.

---

## 7. Experiment catalogue

Each entry: **Q** = question IDs (regenerated from the inventory `Exp` column on 2026-10-29; `†` = static pointer exists, confirm only), **State**, **Instrument**, **Procedure**, **Evidence**. Anything not obvious from the question's own "static evidence" and "suggested check" columns is spelled out. Read the question file for the full wording of each ID.

### Campaign A - Actor flag bits

#### A1 - Flag write census (setters)
- **Q:** OQ-20, OQ-38, OQ-60, OQ-I022-1, OQ-I025-1, OQ-I025-2, OQ-I026-6, OQ-I044-2, OQ-I049-3, OQ-I052-5, OQ-I053-3. The census also sees the setters of `$0080`/`$0400` (OQ-8) and `$0700` (OQ-I025-6): log them too.
- **State:** `S01`, `S10`, `S11`, `S12`, plus a boss room and one cutscene room.
- **Instrument:** write callbacks over all actor slots, high byte and low byte of `+10` and `+12`: `addMemoryCallback(fn, write, 0x1000, 0x1FFF, ..., WR)` with a filter on `a & 0x3F`. For each hit compute `changed = old ~ new` and log only changes that touch a bit in the question's list. Group by (bit, PC, setting/clearing).
- **Procedure:** run `W1`-style: 5 minutes of play covering walk, attack (A button), each form's ability, take damage, kill an enemy, open a chest, talk to an NPC, warp, die. Run it twice, once per form of the player (Will, Freedan, Shadow).
- **Evidence:** a table `bit | setter routine (offset) | clearer routine | context`. This answers every "who sets bit X" question and half of the "what does it mean" ones, because the setter context names the meaning. Known static meanings to compare with (A12 RC-01..RC-06): `$10` `$0200` = player not hittable; `$2000` = hidden from the depth sort / script-driven path; `$0008` = collision-aware movement (OQ-20 asks about "grounded or player-hit"); `$12` bits listed in RC-06.

#### A2 - Flag read census (readers) and confirmations
- **Q:** OQ-8, OQ-40, OQ-I023-3†, OQ-I027-2†, OQ-I030-2†, OQ-I032-5†, OQ-I036-4†, OQ-I037-4, OQ-I041-6, OQ-I047-2, OQ-I054-3. (The five `†` ids are the `$0200` reader family: readers are `combat_collision.asm` about 333 `BIT #$76E0`, 340 `BIT #$74E0`, 1207 `BIT #$0280` per A12 RC-01.)
- **Instrument:** read callbacks on the same range. A read callback cannot tell which bit is tested, so log the unique PCs of readers of `+10` high byte, then map each PC to the instruction and check whether it is `AND #$0200`/`BIT #$0200`-style. The static job is done for `$0200`; the runtime job is to find readers the static search missed (indexed or `LDA [..]` reads) and the other rows' readers.
- **Confirmation (the `†` family):** in `S10`, set `$10 |= $0200` on the player (`write_word 0x1010`), let an enemy touch Will for 120 frames: expected no damage and no hit-stun; clear the bit and repeat as the control. Also watch the boss-defeat case (OQ-I030-2) once.
- **Evidence:** reader list per bit. A bit with writers but zero readers across the session is the "set and never read" answer.

#### A3 - Forced bit experiments
- **Q:** OQ-20, OQ-54, OQ-I023-6, OQ-I025-6, OQ-I026-5, OQ-I026-6, OQ-I033-6, OQ-I044-2.
- **Procedure:** from a quiet state, `write_word` the bit on/off on a chosen NPC or on the player, `advance_frame 30`, screenshot, compare. Examples: `$10 |= $2000` on a visible NPC (does it vanish? that is "hidden" or "script-driven"), `$0E = $2000` before and after (OQ-I033-6: a different word, the OAM attribute priority bits), `$10 |= $0700` on a talked-to NPC (OQ-I025-6).
- **Evidence:** before/after screenshots and the actor's next 30 frames of `$10`.

#### A4 - Follow-up (run 2026-10-30; results in `mesen2-results/A4_followup_20261030.md`)
- **Q:** OQ-8 (`$0400`), OQ-54, OQ-60, OQ-I025-1, OQ-I025-2, OQ-I025-6, OQ-I037-4, OQ-I041-6, OQ-I047-2, OQ-I049-3, OQ-I053-3, OQ-I054-3.
- **Method:** `scenario_a4_followup.py` (kill an eye stalker and the laborer, drop and pickup, last-enemy reward, damage-number child, `$0100` on the player) and `scenario_a4_events.py` (Dark Space warp, forced walk, dialogue text). Control and forced runs differ in one forced bit.
- **Status:** campaign A is done except three INCONCLUSIVE ids: OQ-I023-6 (no `ClimbX` glide reached: needs a climb scene), OQ-I026-5 (needs the `sp5B` rooms), OQ-I033-6 (needs the Euro shop queue, scene `$91`), and the named sub-halves: OQ-I041-6 (`$2F00` child of `PlayerAttackHitTest`), OQ-I025-1 (`$12 $0001` on the player), OQ-60 (`$0008` / `$0200` transitions of the forced walk, `StartMusic`), OQ-I049-3 (why the spawn flags carry `$0400`), OQ-I025-6 (a chest-like NPC) and OQ-I037-4 (the Freejia kidnapper). Shipped-note corrections of campaign A are in `edits/mesen2-A_notes.json` and `renames/apply-mesen2-A_names.json` (for the user to apply; the campaign applied nothing).

### Campaign B - Collision and movement

#### B1 - Collision census across scenes
- **Q:** OQ-3, OQ-16, OQ-41, OQ-I029-5, OQ-I030-3, OQ-I032-4, OQ-I051-6, OQ-I052-4.
- **Static prelude:** the layout is settled (section 2.4, confirmed 2026-10-29): WRAM `0x1C000` in **256-byte pages of 16 x 16 cells**, `index = (((ty>>4)*stride + (tx>>4)) << 8) | ((ty&15)<<4) | (tx&15)`, `stride = $0693`, **low nibble = base type, high nibble = dynamic block mark**, bounds `$0692/$0696` in pixels (cells = bounds / 16). Not a row-major array. Read the index math once more in `tile_collision_physics.asm` for the record.
- **Procedure:** for a list of scene ids (`artifacts/scenes.json`, `db-us/groups.json`, in batches), warp (quick warp from the previous scene, 300 frames, or the recipe where flags matter), dismiss the banner, then one `run_script` with `gaia.coll.get(tx, ty)` over `(bounds/16) x (bounds/16)` cells builds **two** histograms: low nibble (16 values) and high nibble (dynamic marks). Return one table row per scene with `kit.finish`: `scene, w, h, stride, counts of low-nibble types $03 $04 $05 $06 $09 $0A $0C $0E`, plus the bounds words for OQ-41 (power-of-two wrap). South Cape result for reference: `$06` 16 cells, `$09` 18 cells.
- **Evidence:** the **list of scenes** where `$06`/`$09` occur, with cell coordinates of the first ten. Take a screenshot with the player moved next to the first `$06` and `$09` tile. This is the key enabler for B2/B3 and for OQ-I030-3. About 400 frames per scene at 200 to 370 frames per second, so a batch of 20 scenes takes about 40 seconds.
- **Note:** warping without proper flags may land on empty rooms. The collision layer is built from the scene data, so the census works even when the story state is wrong.

#### B2 - Synthetic terrain walking tests
- **Q:** OQ-16, OQ-24, OQ-25, OQ-I029-5, OQ-I033-1..4, OQ-I038-1, OQ-I038-2, OQ-I038-5, OQ-I039-1..3, OQ-I039-5, OQ-I040-4 (magnitude half; the push **direction** is answered statically, `player_move_east.asm:26`: `$09` pushes south, `$06` north), OQ-SAN2-2 (same). OQ-I029-1 and OQ-I029-4 are answered (renamed `WestRampAscend`/`WestRampDescend`, `WallSlidePushDown`); use them only as positive controls for the direction.
- **Idea:** the collision layer is in RAM, so write exactly the tiles under test next to the player in `S01r` and walk into them. No need to find a natural slope. Write the **low** nibble for a base type; leave the high nibble `0` unless the test is about dynamic marks.
- **Working harness (done once, reuse it):** `harness/scenario_b2_special_tiles.py` + `kit/lib/gaia_kit.lua`. Open room of South Cape: cells (19-27, 7-13); the player starts at cell (21, 10), actor position (344, 176), 2 px per frame east. Result: `B2_special_tiles_20261029.md`.
- **Procedure:**
  1. `load_state_file` `S01r` (O or R-plain). In `setup`, clear a 6 x 4 cell area around the test cell to `$00` with `gaia.coll.set(tx, ty, v)` (the layer is paged: 2.4; never `0x1C000 + row*stride + col`).
  2. Paint the test pattern (for example `$06` top-left and `$09` bottom-left for OQ-I029-5/I033-4, or a `$05` / `$0A` diagonal for the slope tests).
  3. Place the player by writing `$1014`/`$1016` (actor position; `$09A2/$09A4` are 8 and 16 smaller) and zero `$09B2/$09B4`; hold the direction with `gaia.hold` for N frames (`gaia.trial`).
  4. Per frame `sample` returns `posX, posY, speedEw, speedNs, $1010` (extend with `$22, $24, $26, $AA, $AB, $09B6, $09B8, $09C6` for the controller internals). The trial returns the table; nothing is printed per frame.
  5. Repeat for each direction and variant, each trial **twice** (identical) and on O and R. Controls: no paint (straight line) and a `$0F` solid tile (must stall, flag `$1010` bit 2 set).
- **Evidence:** trajectory per test (px per frame, which axis). Compare with the arithmetic in each question's "static evidence" to confirm or contradict. Spot check the result against a natural slope found in B1.
- **Scope warning:** the **player** has its own movement code (`player_move_*.asm`). `CheckActorOnSpecialTile` (`tile_collision_physics.asm`, about line 992; probes (actorX-8, actorY-16) >> 4, skipped when either value is 16-aligned) is called by the `TileCollision_Move*` routines of ordinary actors: a pattern test of OQ-16, OQ-I029-5 and OQ-I033-4 needs a **non-player actor with actor flag `$0008`** on the painted pattern, not the player. Done so far (single tile, player): `$06` on the player's row pushes 16 px north (2 px per frame for 8 frames), `$09` 16 px south, `$0F` stalls, rows above and below do nothing; identical on O and R-plain.

#### B3 - Movement trace on natural terrain
- **Q:** OQ-I024-5, OQ-I029-2, OQ-I032-1..4, OQ-I045-3, OQ-I047-1, OQ-I048-5, OQ-I052-3.
- **Instrument:** exec callbacks on the labelled routines using the **decimal keys** of `db-us/names/bankNN.json`: `DecelerateNS` 177940, `ClampSpeeds` 177694, `DispatchEastMove` 186076, `CancelVerticalPhase` 188666 (the old `DiagClearReturnFlags`), `FindSlopeForEastMove` 176571 (the old `ProbeLeftTiles`), `FindSlopeForWestMove` 176488. Log registers (`cpu.a`, `cpu.x`, `cpu.y`, `cpu.sp`) and the stack word `emu.read` at `sp+5` for OQ-I029-2.
- **Procedure:** in `S13` walk onto and off the slope in each direction, stop mid-slope, run. The exec log shows which probe routine runs and with what operand. OQ-I024-5 asks whether `DispatchEastMove` calls the "left" probe: the live name is `FindSlopeForEastMove`; check that the call direction matches its new name.

#### B4 - Ramps, glide, booster
- **Q:** OQ-I023-1, OQ-I030-4, OQ-I036-1..3, OQ-I040-1, OQ-I040-2.
- **State:** `S14` (Great Wall style ramp scene), a glide trigger scene (OQ-I023-1: find via the `slider_glide` scene list in the code docs).
- **Procedure:** approach each ramp at walk and run speed, log the equality check outcome (OQ-I036-1) and the landing `posX/posY` after the launch (OQ-I036-2). For the booster, log `playerSpeedEw` per frame while the player crosses the trigger (OQ-I040-1/2). The glide: log start and end position and which collision rows are crossed.

### Campaign C - Engine, DMA, display flags

#### C1 - Adhoc VRAM DMA ordering (ADHOC group)
- **Q:** OQ-45, OQ-I022-4 (OQ-64 is closed).
- **Instrument:** write callbacks on WRAM `$7F0C07` (offset `0x10C07`) and `$7F0C09` (`0x10C09`), exec callback on the NMI control of H4. Record, for every pair, the NMI count between the trigger write and the size write, and the value last written to `$4200` bit 7 (NMITIMEN is write-only: track it with a write callback on `$4200` via `snesMemory`, both `$00:` and `$81:` aliases).
- **Procedure:** play through the radar/map screen (`RadarScreenSetup` 229567: open it with Start), an inventory open, a Dark Space entry and a chest. Count windows where an NMI lands between the stores. `step_instruction` is synchronous now (it returns `pcs`), so a stepped proof inside the window is possible: break on the first store (`set_breakpoints` halting exec, or `run_until pcEquals`), then `step_instruction {count, over:false}` and read `pcs`; the trace of `trace_between {startPc, stopPc}` between the two stores shows whether an NMI entry lies between them.
- **Evidence:** zero windows in N occurrences means the NMI is disabled during the stores (the I022 reading); any hit confirms the hazard.

#### C2 - NMITIMEN and VBlankWait
- **Q:** OQ-I022-4 (callers with NMI enabled).
- **Instrument:** write callback on `$4200` (use `snesMemory` with the alias `$81:4200` and the `$00:4200` alias both; the module `kit/lib/c1_adhoc.lua` registers all 128 aliases `$00-$3F` and `$80-$BF`). Log the unique PCs with the value written.
- **Boot half (0.6.0):** run the same census with `run_script {fromReset:"power", frames:300}` (or `load_rom {paused:true}` first): the script then sees the boot writes that a plain `load_rom` + `pause` misses (T-42). Done once on O (plan 1.3 item 28): `82:9F47` = `$00` (frame 0), `82:81AC` = `$01` (frame 3), `82:819F` = `$81` (frame 26). Callers of `EnableNmiAndJoypad` by PC still need a run per scene family.

#### C3 - Boot, reset, MEMSEL, SRAM
- **Q:** OQ-50, OQ-I024-4, OQ-I055-3.
- **Procedure:** from a cold boot (`run_script {fromReset:"power", frames:200, includes:[...]}`; frame 0 is the first boot instruction, so the first 200 frames start at the reset vector) log writes to `$420D` (MEMSEL) with PC and frame, compare with the SPC upload duration (count frames between the first APUIO write and the boot logo). For OQ-50 set `$0100` to `$83` and to another value in WRAM, then `reset {mode:"soft"}` (WRAM is kept; `power` would clear it), load the script and see whether `SystemInit` (32788) takes a different path (log the first `sceneNext` write). OQ-I055-3: set event flag `$10`, `reset {mode:"soft"}`, and check that the first logo is skipped or shown. Order per case: write the WRAM bytes, then either `reset {mode:"soft"}` followed by `run_script` without `fromReset`, or in one call `run_script {fromReset:"soft"}` (WRAM survives a soft reset, so the pokes stay). Do not poke before a `power` reset: it re-initializes RAM and drops loaded scripts.

#### C4 - displayModeFlags bits (DMF group)
- **Q:** OQ-6, OQ-23†, OQ-42, OQ-51, OQ-I034-1†, OQ-I057-4†. (OQ-I026-3 is G3, not C4.)
- **Static pointers (RC-08, RC-09):** bits 0, 4, 5 are read by `Bg3TilemapVramDma` (176184; mask `$31`; bit 0 full `$0800`-byte upload, bits 4/5 partial `$0140` bytes, cleared after the transfer); bit 14 = `hudDisableFlag` bit 6, read by `UpdateHUD` (33286) and the HUD routine; bit 15 gates the BG3 upload. OQ-42 (writers of bits 4/5) and OQ-51 (bit 13) were never searched statically: IT-35 does that first.
- **Instrument:** write callback on `0x09EC-0x09ED` for setters (changed bits via `old ~ new`) and read callbacks for readers; log bit, PC, scene. Bits of interest: 0, 4, 5, 7, 13, 14 (`$0001`, `$0010`, `$0020`, `$0080`, `$2000`, `$4000`).
- **Procedure:** play title -> inventory -> dialogue (to set bit 13) -> map -> boss. Confirm bit 14: compare the screen with and without it in scene `$FA` by forcing the bit via `write_word` (HUD off); confirm bit 0/4/5 by forcing each and watching the next NMI's BG3 DMA (`Bg3TilemapVramDma` exec and VRAM bytes).

### Campaign W - Generic census

#### W1 - Address census
Template in 6.1. **Batches** (each is one script run, so do the batch together). Ids whose primary experiment is not W1 are answered by that experiment; W1 covers the rest.

| Batch | WATCH list | Questions |
|-------|-----------|-----------|
| W1-a Engine DP scratch | `$00AA/$00AB`, `$005E-$0062`, `$00DC`, `$0720-$0760` | OQ-I029-3, OQ-I045-1, OQ-27, OQ-I035-2, OQ-I035-3, OQ-I024-2 |
| W1-b Scene and flags | `$06A0`, `$06C8`, `$06EF`, `$06F0`, `$06F2`, `$0402/$0404`, `$0D6E`, `$09CC/$09CE`, `$06CC` | OQ-4, OQ-13, OQ-14, OQ-18, OQ-36, OQ-12, OQ-57, OQ-I051-2, OQ-I059-5, OQ-I065-3† |
| W1-c Event/flag bytes | `$0A00` bit 0, `$0A80-$0AA7`, `$0AEC/$0AEE` | OQ-I030-1, OQ-I052-1, OQ-I048-1 (same event flag `#00`), OQ-67, OQ-68, OQ-I042-7, OQ-I054-2 |
| W1-d `$7F` scratch | `$7F0000-$7F01FF`, `$7F0010`, `$7F0020`, `$7F0200-$7F09FF`, `$7F0B22/24`, `$7F0C00-02`, `$7F0E00`, `$7F3000` | OQ-2, OQ-15, OQ-I023-2, OQ-I051-4, OQ-I041-1, OQ-I024-6, OQ-I034-4 |
| W1-e Unknown readers | `$0B14`, `$0648`, `$090E/$0910`, `$09BE-$09C4`, `$0200-$02FF` (decompressor dictionary vs sort bucket) | OQ-I024-2, OQ-I024-3, OQ-52, OQ-I021-1 |
| W1-f Body table users | `$0AC8` writes (which body-table row is selected) | OQ-I061-1, OQ-I069-1, OQ-28 |
| W1-g Actor scratch | `$24/$26` of spawned actors (spawner slot), `$0B02`, `$7EDF40` | OQ-65, OQ-I053-2, OQ-I052-8 |

`$0B22` (OQ-I035-6†) is not a W1 row any more: its reader is `UpdateHUD` (`system_core.asm` about 416-423, RC-14); put `$0B22` in the batch only as a confirmation (`hpToHeal` decrements while HP rises). `$7F0B22` (OQ-I041-1) is a different word.

For ROM-side "who reads this table" questions (OQ-11 scene_flag_table range, OQ-I055-4 is answered) use `emu.callbackType.read` with `snesPrgRom` and the table's offset range.

### Campaign D - Audio

#### D1 - APU port log
- **Q:** OQ-10, OQ-29, OQ-48, OQ-I046-1, OQ-I056-5, OQ-I065-3† (answered statically: `$06F2` is the BGM id stored by `SpcMusicLoadCmd` 166765; confirm), OQ-SAN2-1.
- **Instrument:** write callbacks on `$2140-$2143` with `snesMemory` aliases `$00:` and `$81:` (both) or tap the SPC side. Log `frame, port, value, scene`. Add a sound-ID decode from `docs/audio/bgm-track-listing.md`.
- **Procedure:** open a chest (OQ-29), take damage as each form (OQ-I046-1, expect `#07` Will, `#08` others), watch camera shake (OQ-SAN2-1: count `#15` per tick), scene changes (OQ-10, check IDs `$0D`/`$17`). Read `$06F2` at each music start (the `†` confirmation).

#### D2 - SPC-side trace
- **Q:** OQ-I021-2, OQ-I021-3, OQ-I022-3.
- **Instrument:** `emu.addMemoryCallback(..., emu.cpuType.spc, emu.memType.spcRam)` exec callbacks on the engine's command handlers (`CmdFadeOut`, `CmdStop`, `CmdF2`, with addresses from `docs/audio/spc-disassembly.md`), plus reads of `spc.*` state (fade counters `$30/$31`). `emu.getState()['spc.pc']` and SPC exec callbacks are verified (1.2; they stop after a `rewind`, T-13). Use a narrow range (the handler addresses), not `0x0000-0xFFFF`: a full-range callback fires about 900 times per frame.
- **Evidence:** order and timing of `$F1`, `$01`, `$F0`, `$F2` as seen by the SPC, and whether the DSP volume actually ramps.

#### D3 - Static transfer parse
- **Q:** OQ-I022-2. Parse the music/sample block headers from the ROM (`S`), no runtime. Owned by IT-35's static list; do not schedule a session for it.

### Campaign E - Display, palette, Mode 7

#### E1 - Display state dump
- **Q:** OQ-1, OQ-I024-6, OQ-I028-6, OQ-I033-5, OQ-I034-2, OQ-I035-5, OQ-I048-2, OQ-I053-4, OQ-I066-3.
- **Instrument:** `get_emulator_state` for PPU registers (TM, TS, CGWSEL, CGADSUB, COLDATA via `$7F0C00-02`, window regs), screenshot, CGRAM dump, `hdmaEnableMask` `$66`.
- **Procedure:** warp (H3) to each scene in the questions, wait 120 frames, capture (`get_ppu_state`, `get_dma_state`, `take_screenshot`). For OQ-I028-6 step each scene and log `COLDATA`/`CGADSUB` writes per frame (write callbacks on `$2131/$2132` with both aliases). For OQ-I048-2 compare PPU registers at three points in scene `$FD`.

#### E2 - Palette bundles
- **Q:** OQ-31, OQ-I026-4, OQ-I027-6, OQ-I029-6, OQ-I031-4, OQ-I036-5, OQ-I036-6, OQ-I040-3, OQ-I044-1, OQ-I059-2, OQ-I060-5. (OQ-I060-6 is a static padding question, not part of this group; OQ-I026-4 stays open because I029 gives a partial answer.) One run of E2 answers the members whose bundle it covers: record a verdict per bundle and per id (method group, A12 §4).
- **Method:** (1) decode all bundles statically using the `cop_handlers_palette` bundle model (sub-entry lists) to a table of `bundle id -> CGRAM range, colour count, frame count`; (2) at runtime, find the scenes that start each bundle (exec callback on `PaletteStart` 37732 logging the bundle id and scene), then capture CGRAM before and after (`get_palette_info` or `emu.read` on `snesCgRam`). For the "never staged" bundles use R1 over the bundle's data offset (read counters).
- **Evidence:** a table of bundle id, colours, scenes. This closes the ~120-bundle OQ-I060-5 as far as reachable.

#### E3 - Mode 7 and the world map
- **Q:** OQ-I041-2, OQ-I041-3, OQ-I041-4, OQ-I056-8, OQ-I058-1, OQ-I059-4.
- **Procedure:** `S08` world map. Log the Mode 7 matrix words `$C2-$CD` and `$B6/$B8/$BC` per frame during the zoom-out (OQ-I059-4: first-frame `$B8`; the zoom-out is about 44 passes of 2 ticks, IT-09), check the HDMA tables (`$7E7000`, `$7E7800`, `$7E8000`) for overlap with staging buffers by write callbacks on those ranges and their PCs (OQ-I041-3). Screenshot the area below the boundary row (OQ-I058-1). For OQ-I041-4 count exec of the divisor-overflow labels with R1. Also read `M7SEL` (`$211A`) in the Mode 7 scene: the audit claims `$80` = transparent outside (report §8.8).

#### E4 - HDMA, windows, parallax, credits
- **Q:** OQ-32, OQ-I031-1..3, OQ-I032-6, OQ-I035-1, OQ-I035-3, OQ-I035-4, OQ-I057-3.
- **State:** one `S19` state per scene: credits (`sF7_credits`), dream, Mu vampire lair, scene `$32`, `$E9/$EA`, `$C3`, title.
- **Instrument:** snapshots every 30 frames of W12SEL/WOBJSEL/TMW/TSW/CGWSEL/CGADSUB, HDMA channel enable `$66`, and the first 16 bytes of each active HDMA table. Screenshots at the same moments.

### Campaign F - Sprites and graphics

#### F1 - Animation forcing
- **Q:** the 26 inventory rows whose first experiment is F1 (P3 visual), plus supporting rows: OQ-B001-1, OQ-B001-2 (OQ-I056-7 is its duplicate), OQ-I031-5, OQ-I033-6, OQ-I036-3, OQ-I041-7, OQ-I042-2, OQ-I049-5 (OQ-I051-7 duplicate), OQ-I051-7, OQ-I052-1, OQ-I052-2, OQ-I052-9, OQ-I053-4, OQ-I053-5, OQ-I053-6, OQ-I055-1, OQ-I056-3, OQ-I058-2, OQ-I059-3, OQ-I062-1, OQ-I063-2, OQ-I063-3, OQ-I064-2, OQ-I064-3, OQ-I064-4, OQ-I065-5, OQ-I066-3, OQ-I066-5, OQ-I067-3, OQ-I067-4, OQ-I068-1, OQ-I069-2, OQ-I069-3, OQ-I070-2, OQ-I071-1, OQ-I071-2, OQ-I071-4, OQ-I072-5.
- **Method:** pick a **host actor** that is already on screen and uses the sprite set (an NPC for `npc_props`, the player for body tables, an enemy for `spriteset_enemies`). In an `endFrame` callback hold the actor's `sprIdx` (`+28`) and `sprFrame` (`+2A`) at the test index, then screenshot. This only works if the host's VRAM tiles are loaded, so choose host scenes that use the set (the questions name them). For the player tables use the `characterForm` writes from H3, then write the animation index and let the engine stage it.
- **Evidence:** one screenshot per index, annotated with the host scene. Where the set is not loaded in any scene, mark `NOT-VISIBLE`. Stop after one attempt per scene (priority P3).

#### F2 - Residual hidden-group row
- **Q:** OQ-I063-5 (lone set `0E86AE`). The hidden-group trio (OQ-I067-5, OQ-I069-4, OQ-I071-5; 9 hidden groups in 4 files) is **static**: no frame list points at them, and IT-33/IT-34 fix the extractor. Do not build an orphan viewer for them.
- **Method (OQ-I063-5 only):** write the set's address into a host actor's frame pointer (confirm the field in `docs/code/bank00/data-tables-memory.md`), judge by OAM and screenshot. If the host's tiles do not match, use the OAM dump alone.

#### F3 - Header-byte consumers (reduced)
- **Q:** none left of its own. OQ-I055-4 and OQ-I063-4 are answered (B001); the reader half of OQ-I066-4 is answered, its **damage half** (do Aura body boxes hurt enemies) is run in G1. Keep this code only for the G1 cross-check: compare the actual hit rectangle with header bytes 8-11 of the Aura group.

### Campaign G - Combat and rewards

#### G1 - Hit and damage paths
- **Q:** OQ-8, OQ-9, OQ-I037-4, OQ-I041-5, OQ-I041-6, OQ-I042-4, OQ-I062-2, OQ-I066-2, OQ-I066-4 (damage half).
- **Instrument:** exec callbacks on `RunCombatCollision` 244708, `CombatCollision_EnemyLoop` 244729, `PlayerAttackHitTest` 245085, `ApplyHitDamageToVictim` 245543 (player hits actor), `ApplyPlayerHitstun` 50071, `HitStaggerMain` 55415 (decimal keys of `names/bank00.json` and `bank03.json`). `EnemyHitPlayerHandler` is not a live label: the enemy-hits-player pass is inside `RunCombatCollision`. In each callback log the attacker slot, victim slot, both `$10`/`$12`, the damage value computed, and the sign of `iframeCounter` (`$7F0028`; positive = hit-stun, negative = recovery: A12 RC-07).
- **Procedure:** from `S10`/`S11`/`S12` use every attack and ability once. This reveals which attack goes through which path (OQ-I066-2), which hitter is slot `$1000` (OQ-9), whether `$0400`/`$0080` appear as the documented gates (OQ-8; RC-04, RC-05).

#### G2 - Death, rewards, drops
- **Q:** OQ-53, OQ-67, OQ-I042-1†, OQ-I046-4, OQ-I046-6, OQ-I047-2, OQ-I049-3, OQ-I049-5 (OQ-I051-7 duplicate), OQ-I049-6† (half), OQ-I050-1, OQ-I050-6, OQ-I051-3, OQ-I051-5, OQ-I052-6, OQ-I053-7, OQ-I054-2, OQ-I054-3, OQ-I054-4, OQ-I054-5, OQ-I070-3.
- **Procedure:** (a) log `$0AEC/$0AEE` writes per scene on entry (init) and on every kill. (b) Kill 200 enemies of one type in a loop (write their HP to 1 and hit) to estimate the drop rates for OQ-I049-6 and OQ-I054-5 (compare with the nine percentages recomputed in I049). (c) For OQ-I053-7 die in scene `$E8` and log the next `sceneNext`, form and `$0AF0/$0AF2`. (d) For OQ-I051-3 watch `$04`/`$06` of the reward handler's slot and the actor-list head `$56` before and after the handler runs. (e) OQ-I070-3 uses static tier tables plus a kill-everything pass in a sample of the 87 scenes.

#### G3 - Pool-full, hitstun, knockback
- **Q:** OQ-17, OQ-66, OQ-I026-3, OQ-I036-7, OQ-I041-5, OQ-I046-1..3, OQ-I047-1.
- **Method:** fill the actor pool by writing spawn requests or use a scene with a lot of actors; when `actorPoolPtr` (`$4E`) reaches the end (`Y = $1FC0` case) do the action under test (take a hit, use the item, climb the ramp). Watch for corruption in the actor list (`$56/$58` and the `+04/+06` links) with an `endFrame` consistency walker that follows the list and logs a cycle or a dangling link. Count the ticks of a hit-stun (the notes say about 17).

#### G4 - Enemy stat rows
- **Q:** OQ-I046-5, OQ-I054-5, OQ-I066-1.
- **Method:** static decode of the stats table first (gem type byte `+3`, knockback tier `$7F101C` source, which rows are referenced by any actor; IT-22 already counts unused rows), then a runtime write callback on `statsPtr` stores to see which rows are really loaded.

### Campaign M - Menus, text

#### M1 - Inventory and items
- **Q:** OQ-39, OQ-I023-4, OQ-I026-2, OQ-I026-3, OQ-I028-1..3, OQ-I028-5, OQ-I034-4..6, OQ-I035-5, OQ-I047-3, OQ-I050-1, OQ-I050-6, OQ-I064-3, OQ-I067-1, OQ-I067-2, OQ-I071-3, OQ-I071-4, OQ-I071-6, OQ-I072-1, OQ-I072-2.
- **Procedure:** `S09` inventory. Arrange: in the target phase press X, Y, A in turn and read `$0AB4` (OQ-I028-1; **R ROM**; the arrange mask `$8044` uses the logical bits), equip slot S and arrange against T/S and read `$0AC4` (OQ-I028-2), enter the Use tab and leave via other buttons (OQ-I028-3), give each item id `$00-$40` with the item-slot write (H3) and screenshot the name box (OQ-I067-1, OQ-I067-2, OQ-I072-1: this also answers the "Mystic Statue vs Mystery Doll" text). Use Lola's Melody twice in `$15` while logging `$0A00`-byte `0x01/0x0E` flags (OQ-I026-2). For OQ-I072-2 try to discard each item to see which are protected. Item use touches `item_use_system` (plain-only transform sites: Inca statue compares): record the build mode.

#### M2 - Title, boot, diary
- **Q:** OQ-I055-1, OQ-I055-2, OQ-I055-3, OQ-I055-5, OQ-I056-8, OQ-I057-1, OQ-I057-3, OQ-I057-6, OQ-I058-2. (OQ-I054-1, the boot-logo OBJ palettes, is answered by I055.)
- **Procedure:** cold boot, record screenshots every 8 frames for the first 400 frames (logo timing, OQ-I055-2/5; the animation loop of 120 ticks follows the n+1 rule), dump OBJ palettes 0/1. Diary: create, erase, copy a slot and log `$0D94` (OQ-I057-6). **OQ-I057-1: run on R-plain** (the diary remap sites are plain-only transforms; on R-tagged you would test the vanilla code). Log which button feeds which action on title/diary and compare with the original ROM.

#### M3 - World map, routes, exits
- **Q:** OQ-37, OQ-63, OQ-B001-2, OQ-I040-3, OQ-I042-5, OQ-I042-6, OQ-I042-8, OQ-I058-1, OQ-I059-1..8, OQ-I060-1..4 (OQ-I060-3 is a `†` static pointer: the choice id mask `$1F`).
- **Procedure:** `S08`. Run each route and log `$0D58` (choice id) writes with PC (OQ-I060-1: which ids ever appear), tick counts of each route step (OQ-I060-2: the audit's static reading is n+1 ticks per step; measure it, IT-09), `LookupMapName` 239250 exec with the scene id (OQ-I059-7). Edward's Castle (OQ-I042-5): walk to the exit tile and log the player Y every frame on the approach; if Y never equals `$2D0` and the exit still fires, the notes are wrong.

#### M4 - Text and console renderers
- **Q:** OQ-27, OQ-33, OQ-34, OQ-35, OQ-48, OQ-58, OQ-I028-4, OQ-I063-1, OQ-I065-1, OQ-I065-6, OQ-I067-1, OQ-I072-1.
- **Procedure:** VRAM tile dump of the BG3 font (`read_memory type:"snesVideoRam"` or `dump_memory`), tilemap rows for boxes (OQ-34), scene title for the longest title string (OQ-58), CGRAM entries of the speaker templates (OQ-I065-1), a talk to NPCs that use template `$10` vs `$0F` (OQ-I065-6).

### Campaign N - Actors and scripts

#### N1 - NPC and actor behaviours
- **Q:** OQ-43, OQ-44, OQ-I025-6, OQ-I026-5, OQ-I030-1, OQ-I036-5, OQ-I037-1, OQ-I037-5, OQ-I039-6, OQ-I041-7, OQ-I042-3, OQ-I043-1, OQ-I045-2, OQ-I048-1, OQ-I050-3, OQ-I050-7 (the 120-tick wait is `WaitByte #$77`-style n+1: measure), OQ-I052-6, OQ-I052-8, OQ-I053-1, OQ-I053-2, OQ-I062-1.
- **Method:** go to the scene named in each question, log the actor's slot (`+14/+16/+08/+10` per frame, ring buffer) around the interaction and compare with the static trace in the question. Spawn tests (statue pull, hidden jewel, rain) use a normal scene visit; for non-referenced actors use R1 first. Teleporter, sliding wall and solid arm are plain-only transform blocks: record the build mode.

#### N2 - Cutscenes and bosses
- **Q:** OQ-I025-5, OQ-I030-2, OQ-I044-1, OQ-I048-2, OQ-I048-3, OQ-I049-2, OQ-I052-3, OQ-I053-6, OQ-I053-7, OQ-I072-5.
- **Method:** states `S16`, `S17`; screenshot sequences, PPU snapshots and actor counts per 30 frames; confetti burst count by counting live actors of the confetti type per frame (OQ-I048-3).

#### N3 - Dark Space and Gaia
- **Q:** OQ-I053-3, OQ-I056-1..5, OQ-I067-3.
- **State:** `S15`. Check the Shadow transform dispatch with `characterForm = Shadow` and each Will ability (OQ-I056-1), log `globalScriptIndex` writes (OQ-I056-4), music ids via D1 (OQ-I056-5).

#### N4 - COP semantic probes
- **Q:** OQ-47, OQ-54, OQ-55, OQ-56, OQ-62, OQ-69, OQ-I037-2†, OQ-I037-3†, OQ-I038-3, OQ-I044-3, OQ-I045-5, OQ-I051-1†, OQ-I060-4, OQ-I061-2, OQ-I062-3, OQ-I068-4.
- **Method:** most are about corner cases of one COP. Use the **debug actor technique**: write a tiny COP script into free WRAM (`$7E:2000` region is unsafe; use an unused thinker/actor slot's script area), spawn an actor that runs it and observe the effect. The script bytes come from `docs/cop/families/*.md` and the game's `copdef.json`, **not** from invention. If the COP format is not fully understood for a case, mark `INCONCLUSIVE` and rely on exec traces of existing scripts that already hit the corner case (for example OQ-I037-3 = trace an existing `BranchOnPlayerX` use, move left and right, read which branch is taken). The COP register rule applies to every probe: **X = D = actor slot id before each COP**.

### Campaign P - Player and camera

#### P1 - Input and facing
- **Q:** OQ-28, OQ-I025-3, OQ-I044-4†, OQ-I052-7, OQ-I057-1 (with M2). (OQ-22, facing order, is answered: 0 = down, 1 = up, 2 = left, 3 = right; use it as the positive control.)
- **Procedure:** OQ-I025-3: tap the faced direction twice, frames apart, and log `$040C` and the speed; the audit's static count of the walk/run window is 13 or 14 states (IT-22 item 4): measure the largest gap that still triggers a run. OQ-I044-4 / OQ-I057-1: on the **rebuilt** ROM press each physical button once and log `$0656` (`joypadCurrent`) bits, the raw joypad (`$4218/$4219` through a read callback) and what the game does; record the physical-to-logical map and compare with the original ROM. OQ-I057-1 is diary-related: R-plain (see M2).

#### P2 - Abilities
- **Q:** OQ-I025-4, OQ-I025-5, OQ-I027-1, OQ-I027-3, OQ-I027-4, OQ-I061-1, OQ-I062-2, OQ-I069-3, OQ-I070-2, OQ-I071-1, OQ-I071-2, OQ-I072-4, OQ-I072-6.
- **Procedure:** states `S11`, `S12`. Fire each ability at upgrade levels 0/1/2 (set the ability level byte). Log player pos before/after (Psycho Dash, OQ-I027-4), `$16` at spawn (OQ-I027-1), Dark Friar fragment velocities (OQ-I027-3), body-table row selection via the `$0AC8` writes (W1-f).

#### P4 - Camera
- **Q:** OQ-57, OQ-I025-7, OQ-I049-4, OQ-I050-2, OQ-I050-4, OQ-I051-1†, OQ-SAN2-1. (CAM group: method only. OQ-SAN2-1 is the shake **sound**, not a camera question.)
- **Procedure:** log `cameraTargetX/Y` and the player position per frame during a vine drop landing (shake, OQ-I025-7: does the target drift?), during normal play (OQ-I049-4: the vertical offset, compare player screen Y with 112), and in the scenes with `camera_drift` (OQ-I050-2).

### Campaign R - Reachability

#### R1 - Execution coverage
See 6.2. Run a long coverage session on the **original ROM**: play from new game to the first dungeon boss with all menus, plus warps to every scene in the scene table (R2) for 10 seconds each, plus the title, diary, credits, game over. Then dump the exec/CDL results for the label lists named in the inventory under `UNREF`, `PBUNDLE`, and every "never referenced" question. Output: a table `label | exec count | CDL flags | verdict` and the total coverage from `get_cdl_statistics`. **UNREF is a method group**: record a verdict per member id (OQ-I072-3, I023-5, I034-3, I038-4, I039-4, I045-4, I048-4, I049-1, I049-7, I050-5, I057-2, I057-5, I067-4, I068-2).

#### R2 - Scene sweep
Write a driver script that warps through every scene id (use the scene table length) in a loop: for each id set `0x642`, advance 180 frames, log `sceneCurrent` after, whether the scene loaded (the id changed), the PPU mode, the music id, the display preset byte, the actor count `$0DBC`, and the collision census (B1). One line per scene. This single sweep answers OQ-13, OQ-30, OQ-I035-7, OQ-I042-7, OQ-I056-6, OQ-I060-1, OQ-I061-3, OQ-I064-1, OQ-I065-2, OQ-I065-4, OQ-I068-3, OQ-I068-4 and feeds R1. Return one table row per scene with `kit.finish` (about 90 KB per result, so roughly 20 to 40 scenes per `run_script`; quick-warp each scene from the previous one, 300 frames) or write lines with `emu.mcp.writeFile` once H4 has confirmed it.

#### R3 - ROM pointer scans (static)
For each "unreferenced" label, scan the ROM for a 16-bit or 24-bit pointer to it (little-endian) and for `JSL/JSR/JMP` operands, in both the original ROM and the extracted `.asm`. A hit in non-code data (a table) is "referenced through data". Use `rg` over `extracted/` and a byte search of the ROM. Read-only, no emulator. Its members: OQ-I034-3, I038-4, I045-4, I048-4, I049-1, I050-5, I057-2, I057-5, I072-3 (the hidden-group trio left this list).

### Campaign S / T - Static and tooling (not Mesen2 sessions)

#### S1 - Static checks
OQ-19, OQ-21, OQ-26, OQ-46, OQ-I022-2, OQ-I060-6, OQ-I070-1 (dictionary rule), the `†` pointers of A12 §8, and the static halves of the `R+S` rows. **Owner: IT-35** (`static-answers.md`). A Mesen2 agent does the static half of its own rows (6.5) and does not duplicate IT-35.

#### T1 - Tooling decisions
OQ-49 / OQ-I026-1 (plain vs tagged, IT-27), OQ-59 / OQ-I024-1 (MenuSelectionHandler, IT-30), OQ-I056-9 (`rm -rf` / rebuild failure, IT-26). OQ-7 and OQ-I027-5 are answered. These need a change in `gaia-core` or the baserom (see the ACTION_PLAN iterations); no Mesen2 work, except that IT-27's outcome decides section 2.1.

### Campaign V - Confirmation of audit claims

#### V1 - Claims that were only ever read from the code
Source: report §12 ("a few E5 confirmations would raise confidence in the whole static record"), §8.8, A12 RC-xx, IT-02/IT-09/IT-22. Ids `CL-nn` are local to this plan (they are not questions and never enter shipped text). Each claim names the experiment it rides on, so most cost nothing extra.

| Claim | What to observe | Rides on | Source |
|-------|-----------------|----------|--------|
| CL-01 `WaitByte #n` = n+1 ticks | frames between two effects of a script with a known operand (3 sites: pick from `IT02_apply.md`, a town door and a palette step) | M3, N1 | IT-02, IT-22 item 4 |
| CL-02 `iframeCounter` sign: positive = hit-stun (victims freeze), negative = recovery | `$7F0028` of a victim and of Will during and after a hit; does the victim tick | G1, G3 | A12-03, RC-07 |
| CL-03 actor `$10` `$0200` = player not hittable | forcing it on Will in `S10` (see A2) | A2 | RC-01 |
| CL-04 `$10` `$2000` hides from the depth sort | forcing it on an NPC (see A3) | A3 | RC-02 |
| CL-05 `displayModeFlags` bit 14 = HUD off; bit 0 = full BG3 upload; bits 4/5 = partial | forcing each bit | C4 | RC-08, RC-09 |
| CL-06 button vocabulary: A feeds `$0080` interact, B feeds `$4000` cancel in this build | one press per physical button on R | P1 | RC-18 |
| CL-07 Jeweler: at 8 jewels the text says Strength +1 but the code raises max HP | talk to the jeweler with 8 jewels, read `$0ACA` and the strength byte before/after | M1 or N1 (needs the scene of `jeweler_gem`) | report §8.8 (I043) |
| CL-08 Revive costs 100 gems | game over with 100+ gems, read the gem counter before/after the continue | N2 | report §8.8 (I053) |
| CL-09 hit-stagger stun is about 17 ticks | count NMI frames of a victim's freeze | G3 | report §8.8 (I046) |
| CL-10 `M7SEL = $80` (transparent outside) in the Mode 7 scene | read `$211A` (shadow value) and screenshot beyond the plane | E3 | report §8.8 (I041) |
| CL-11 stat-up `$55` is a reset at signed overflow `$7F`, not a cap | write STR to `$7E` and use a stat-up | G2 | report §8.8 (I050) |
| CL-12 `$06F2` is the BGM id | read at each music start | D1 | RC-12 |

A confirmed claim needs no edit. A contradicted claim is a note error: the result file quotes the note (file:line) and Z1 writes the correction through `merge` and adds it to `ERRATA.md` of the audit-of-audit (IT-53).

### Campaign Z - Closure

#### Z1 - Apply verdicts (the only step that edits the baserom)
See section 8.2 and the prompt in section 12. It runs after the matching result files exist, **never while an ACTION_PLAN iteration that owns the same file is open**, and always ends with the gate.

---

## 8. Result template and the path back into the audit

### 8.1 Result file

`plans/extracted-audit/mesen2-results/<exp>_<yyyymmdd>.md`:

```markdown
# <exp> <title>
ROM: O | R-tagged | R-plain
SHA-1: <40 hex>   file size: <bytes>   crc.json: <checksum/crc/totalSize>   mode source: <where the mode was read>
State: <file> (valid: H1 test passed yes/no; ROM SHA-1 equal to the index row yes/no)
Static prelude: <what rg/Read found, file:line>
Script: <verbatim Lua>
Positive control: <what fired, how often>
Coverage: <scenes, frames, forms, buttons>
Observations:
- <raw log lines, trimmed to 40>
Verdicts:
| ID | Verdict (plain sentence) | Grade | Note shipped today (file:line, if any) | Action |
|----|--------------------------|-------|----------------------------------------|--------|
| OQ-I029-5 | $06 = ... (a verdict with two halves gets one row per half: the VERIFIED half and the INCONCLUSIVE half, each with its own action) | VERIFIED-RUNTIME | tile_collision_physics.asm:57 "not traced to a purpose" | merge: replace sentence |
Tool issues: <rows added to tool-issues.md; only server or Lua-API defects. A game fact, a wrong doc or a harness bug is fixed in `docs/` (spec for the apply pass) or in `harness/` and `kit/lib/`, not logged here>
Notes spec: <path of the draft merge spec and names spec written for the apply pass; dry-run result>
New questions: <text; ids are assigned by Z1>
```

### 8.2 Closing a question (step Z1)

1. Append one row per verdict to `mesen2-results/closures.md` (append-only: date, id, verdict, grade, result file, build mode, SHA-1). `open-questions.md` (IT-35) links to this file; do not edit frozen question files.
2. Find the shipped sentence: ids are **not** in shipped text any more (the audit removed them). Locate by topic with `rg -n "Not traced|not traced|no reader found" extracted notes` plus the file hint in A12 §3 ("cited in" column, 147 ids) or the question file.
3. Write one `merge` spec (`edits/MS<NN>.json`, format of `gaia-core/docs/notes-and-comments.md` §"Notes Merge"), `npm run merge -- <spec> --dry-run`, apply, `npm run extract:lt`, `npm run rebuild` (two separate commands), compare with the newest `GATE:` line. Obey ACTION_PLAN §6.1 (style) and §6.3 (hazard keys that must stay empty; `$8000` text in `combat_collision` and `actor_execution`; `MenuSelectionHandler.asm` is refused on purpose).
4. Names: `npm run names -- <spec> --dry-run`, then apply; `npm run names -- --check`.
5. Text rules for what Z1 writes: state what the code does now, in present tense; no history; no ids (OQ, R, IT, CL); keep a hedge only on a specific untraced claim; waits as operand and ticks; buttons as bit plus physical button; "slot", "group", "frame" with their meaning. A runtime result may be stated as fact ("measured: ...") without a blanket `UNVERIFIED-RUNTIME` tag.
6. New questions found during a session get new `OQ-` ids in `open-questions.md` (not in a new iteration question file, which the audit retired as a registry).
7. Write `mesen2-results/MS<NN>_apply.md` (spec path, dry-run summary, gate numbers, items skipped or blocked, files changed). No git commit: tell the user "Please commit when you're ready" with a suggested message.

### 8.3 Evidence in notes

An E5 verdict upgrades a note from "static reading" to "observed": the note may say "measured" with the number. Never cite the result file, the build mode or the SHA-1 in shipped text.

---

## 9. Session schedule

"Primary ids" are the inventory rows whose **first** experiment code belongs to the session (after the A12 corrections), so the column adds up (344 ids with a runtime or static-prelude task; the other 14 are the 11 answered or closed and the 3 hidden-group ids). Supporting uses of an experiment are not counted again.

| # | Session | Experiments | Primary ids | States made |
|---|---------|-------------|------------:|-------------|
| 1 | Harness | H0-H6 | 0 (enables all) | S00-S03 and the index |
| 2 | Flag census | A1, A2, A3 (+ W1-b on the same play) | 22 | S10-S12 |
| 3 | Collision census and terrain | B1, then B2 | 23 | S13, S14 |
| 4 | Movement traces | B3, B4 | 13 | - |
| 5 | Address census | W1-a to W1-g | 34 | - |
| 6 | Combat and rewards | G1, G2, G3, G4 (+ V1 CL-02, CL-09, CL-11) | 31 | - |
| 7 | Engine, DMA, flags | C1-C4, D1, D2 | 17 | - |
| 8 | Scene sweep + coverage | R2, R1 (and R3 static in parallel) | 26 | - |
| 9 | Menus, text, title | M1, M2, M4, P1 (R-plain for the diary remap) | 40 | `R-*` states |
| 10 | Display and palette | E1, E2, E4 | 24 | S19 |
| 11 | World map, cutscenes, Dark Space | M3, N2, N3, E3 (+ V1 CL-01, CL-08, CL-10) | 31 | S15-S17 |
| 12 | Sprite identification | F1, F2, P2, P4 | 41 | - |
| 13 | NPC and COP probes | N1, N4 (+ V1 CL-07) | 26 | - |
| 14 | Handoff, not Mesen2 | S1 (IT-35), T1 (IT-26..IT-30), D3 (IT-35) | 16 | - |
| 15 | Closure | Z1, after each of sessions 2-13 | - | - |

Dependencies: 1 before everything; 3 before 4; 8 before the "unreferenced" rows elsewhere (so those can say "never executed in coverage run X"); 2 before 6 (flag meanings help interpret combat); **IT-35 before the sessions that contain `†` rows (2, 5, 7, 8, 9, 13)** if you want the static answers first, otherwise treat `†` rows as "confirm only"; **IT-27 before session 9 and the plain-only blocks of sessions 11 and 13**, or run those parts on R-plain.

Order within a session: static prelude (grep and decode) while frames run, because many `R+S` rows have their static half unfinished.

---

## 10. Risks and guardrails

| Risk | Guardrail |
|------|-----------|
| Stale state derails the run | Sidecar SHA-1 (`rom_mismatch`), H1 validity test, states indexed by ROM SHA-1; states without a sidecar are not used. |
| False "never happens" from zero hits | Positive control, session coverage statement, grade `INCONCLUSIVE` unless coverage is broad. |
| Callback PC off by one instruction | Always map the PC to the instruction that **ends** there. Verified rule (section 1.2). |
| Alias mismatches | Prefer `snesWorkRam` / `snesPrgRom`. When using `snesMemory`, register both `$00:` and `$80/$81:` aliases. |
| Writing WRAM breaks the game | Do it only in disposable states, and re-run the validity test. Never save a poked state as a library state unless noted in `states-index.md`. |
| Mesen2 MCP quirks (stale Cursor registration, `--mcp-rom` framing, alias addresses and wrong hit offsets, unchecked arguments, script errors without `isError`; `tool-issues.md` T-01 to T-42; T-42 fixed in 0.6.0) | Follow 1.0 and 1.3. Log each new defect in `tool-issues.md` with its `MCP-nn`. |
| Script flood | Kit log cap. Reuse script names. `load_rom` clears all. |
| COP experiments with invented formats | Only use formats from `copdef.json` / family docs. Otherwise trace existing scripts. X = D = actor slot id before every COP. |
| Questions that depend on game version differences | Tag ROM O/R(mode) in every result. Remap-related answers apply to R only. |
| **Wrong build mode** (plain-only transform sites tested on the tagged ROM) | Section 2.1 and 1.3 item 6; M2 diary on R-plain; record the mode. |
| **Names changed since the question was written** | Record offsets; appendix A; look names up live. |
| **Closure collides with an open audit iteration** | Z1 checks the Progress log and the file ownership (ACTION_PLAN §6.4); skip and list as BLOCKED if the owner iteration is not DONE. |
| Persistent DP state corrupted by a poke (`$80-$82` collision pointer, `$30`, `$34`, `$36`, `$84-$94`) | Do not write low DP; if a probe must, save and restore through the state. A frozen actor after a poke means the pointer at `$80` was hit. |
| Time sink on P3 visual items | Priorities in the inventory. Stop a P3 item after one attempt per scene and mark `NOT-VISIBLE`. |
| Spending runtime on `†` rows that a static check settles | 6.5; run IT-35 first when possible. |

---

## 11. Definition of done

- Phase 0 complete with the H4 matrix recorded for both ROMs, the NMI control reconciled, and `states-index.md` populated.
- All 15 P1 ids have a verdict, with an evidence grade (the 21 of the old count minus OQ-22 answered and the five `$0200`-family ids demoted to P2 "confirm").
- P2 rows (113): 80 % with a verdict, the rest listed as `INCONCLUSIVE` with the reason.
- R1 coverage run archived with its exec/CDL tables, and every UNREF member id has its own verdict.
- V1: each `CL-nn` confirmed, contradicted (with the note quoted) or inconclusive.
- Results written under `mesen2-results/`, every closure appended to `closures.md`, and any note/name change applied through `merge` / `names` in a Z1 run with `extract:lt` and `rebuild` matching the newest `GATE:` line.
- `tool-issues.md` complete, so the MCP requests can be re-ranked from evidence.

---

## 12. Agent prompts

Use: paste the **Common block** first, then one **step prompt**. Each step prompt names the plan sections it relies on; the agent reads them. Steps are independent unless a prompt says "needs". The prompts do not repeat the catalogue; they fix scope, inputs, outputs and stop rules.

### 12.1 Common block (paste above every step prompt)

```text
You are running one step of the Mesen2 investigation for Illusion of Gaia (US). Workspace: c:\Work\gaia-iog-baserom (the baserom). Before anything else read, in this order: plans/extracted-audit/mesen2-investigation-plan.md sections 0, 1, 2, 3, 6 and the section for your step; plans/extracted-audit/mesen2-question-inventory.md (the rows and flags for your ids); the question text of each of your ids in plans/extracted-audit/questions/*.md (search by id; read the static evidence and suggested check). Emulator: the Mesen2 MCP server 0.6.0 or later (namespace user-mesen2-mcp-dev; call GetDynamicTools for the schemas before the first call, and do not call a tool whose schema you have not read). First call get_server_status (works before a ROM is loaded; get_capabilities too since 0.5.0): if the server is older than 0.6.0 (steps C2 boot half and C3 need it: load_rom paused, run_script fromReset, reset mode) or lacks get_server_status, the Cursor registration is stale (plan 1.0): do not guess, drive the server with plans/extracted-audit/mesen2-results/harness/mcp_client.py (plan 1.4) or stop and tell me. Server flags needed: --mcp-lib-dir=<repo>\plans\extracted-audit\mesen2-results\kit\lib and --mcp-results-dir=<repo>\plans\extracted-audit\mesen2-results\raw. Prefer run_script with includes ["gaia_kit"] (plan H2) over pasted Lua.

HARD RULES
1. Write only under plans/extracted-audit/mesen2-results/ (results, raw logs, screenshots, kit, harness, draft specs in mesen2-results/specs/) and rebuilt/states/ (save states). Fixes to shipped notes, comments or names are NOT made in an investigation step: write them as a draft merge spec (`specs/<STEP>_notes.json`) and names spec (`specs/<STEP>_names.json`), check them with `npm run merge -- <spec> --dry-run` and `npm run names -- <spec> --dry-run` (read-only; the only npm run commands allowed) and leave the apply pass (Z1) to the user. Never edit extracted/, notes/, db-us/, baserom/, docs/, src/, artifacts/, us/, the audit files (questions/, results/, renames/, edits/, audit-of-audit/) or the inventory/plan. Never run npm run merge, names, extract, extract:lt or rebuild in an investigation step (only Z1 edits the baserom). Do not delete files you did not create.
2. No git write command (commit, push, tag, merge, rebase, reset, revert). git status/diff/log only. No throwaway script (.py/.mjs/.js/.sh/PowerShell) to edit notes, comments, names, blocks.json/files.json or docs. Lua scripts for the emulator are expected: they go verbatim into the result file.
3. ROM identity. First calls of the session: load_rom the ROM named in your step, pause (for a boot experiment use load_rom {paused:true} instead, which stops at frame 0, and run_script {fromReset:"power"}; see plan 1.3 items 5 and 28), then run the validity test of plan H1 on every state you load. Record in the result: ROM tag (O, R-tagged or R-plain), file path, file size, SHA-1 and CRC-32 (the load_rom / get_rom_info reply; compare with plan 2.1), artifacts/crc.json (mode and sha1 fields if present), where you read the build mode (crc.json mode, else the totalSize and the missing "; {n}" tags, the newest GATE: line of plans/extracted-audit/audit-of-audit/ACTION_PLAN.md, or ask me). A save state is valid only for the exact ROM file loaded: load_state_file refuses another ROM (rom_mismatch) and a state without a .json sidecar is not used. If a check fails, mark the state stale in mesen2-results/states-index.md and rebuild it from the recipe. A NMI exec control address is ROM-specific (plan 1.3 item 8): resolve it from the loaded labels.
4. Positive control in every run: a watch that must fire (the INC $36 write in the NMI; the NMI exec control of H4). A zero-hit result without a firing control in the same run is INCONCLUSIVE.
5. Addresses, not names. Names are being renamed by the audit. Record decimal ROM offsets (the number in the "; {n}" tag of npm run extract:lt output, or the key in db-us/names/bankNN.json). To map a callback K:PC to a routine, take the instruction that ENDS at the reported PC (callbacks report the address after the access) and find it with rg -n "; \{<offset>\}" in extracted/. If the tags are absent, say so and ask me to run extract:lt; do not run it. Look a label up with rg -n "\"<label>\"" db-us/names, then rg -n -w <label> extracted; appendix A of the plan maps old names to live ones.
6. Static first (plan 6.5). rg the extracted code for the static evidence before you run. Ids marked † in the inventory have a static pointer: confirm or refute it, do not rediscover it.
7. Verdict vocabulary: VERIFIED-RUNTIME, VERIFIED-STATIC, CONTRADICTED (quote the shipped note, file:line), INCONCLUSIVE (say what is missing). A claim of absence needs a coverage statement (scenes, frames, forms, buttons).
8. Ticks: WaitByte #n = n+1 ticks; measure in NMI frames ($36 deltas) and report the observed count beside n+1. Buttons: give the logical bit and the physical button (physical B $8000, Y $4000, Start $1000, Select $2000; this build remaps to remapB $4008, remapA $8080, remapY $0040, remapX $0004; interact $0080 is fed by A, cancel $4000 by B).
9. Output cap: at most 200 log lines per script (use the kit); at most 40 raw lines pasted in the result. Reuse script names; load_rom wipes scripts.
10. Stop rules: if the same action fails twice with the same symptom, change the hypothesis or stop and report; after four failures stop. Log each tool (server or Lua API) defect in mesen2-results/tool-issues.md; a documentation error, a game fact or a harness bug is fixed in the harness or goes into the draft specs, never logged as a tool issue (date, tool, call, symptom, workaround, related MCP-nn of plans/extracted-audit/mesen2-mcp-enhancement-requests.md). Never fake or infer a result to fill a gap.
11. COP rules: never invent COP formats (db-us/copdef.json, docs/cop/families/*.md, handler asm); X = D = actor slot id before every COP; do not write the low direct page ($00-$94) except in a disposable state (DP $80-$82 is the collision pointer).
12. Text you draft for later note changes: present tense, what the code does now, no history, no OQ/R/IT/CL ids, no blanket UNVERIFIED-RUNTIME; "not traced" only for a specific untraced claim; waits as operand and ticks; buttons as bit plus physical button; "slot", "group", "frame" with their meaning; accumulator-implied mnemonics bare (LSR, not LSR A).

DELIVERABLE for every step: plans/extracted-audit/mesen2-results/<STEP>_<yyyymmdd>.md using the template of plan section 8.1, plus the draft specs above when a shipped note is wrong (an existing inline comment is replaced with `{"text": ..., "expectOld": "<substring of the stored comment>"}`, a sentence of a block or part note with `{edit:[{find, with}]}`) (one verdict row per id; ids in a duplicate group get their own row, method groups get a verdict per member). Final message to me: counts of VERIFIED-RUNTIME / CONTRADICTED / INCONCLUSIVE, every shipped note now shown wrong (file:line), new questions (text only), tool issues, and the step you recommend next. Do not claim a step is done if its pass criterion was not met.
```

### 12.2 Phase 0 prompts

```text
STEP H0 (bring-up and ROM identity). Plan: section 4 H0, 1.0, 2.1, 1.3 items 6-8. Needs: nothing.
1. get_capabilities (version 0.5.0, 81 tools) and self_test (17/17); record both. If they fail, stop (plan 1.0).
2. load_rom (absolute path) c:\Work\gaia-iog-baserom\rebuilt\Illusion of Gaia.smc, pause; the reply carries fileSha1, fileCrc32, fileSizeBytes: compare with the table of plan 2.1 and record any difference (a different SHA-1 means the ROM was rebuilt: say so). advance_frame 120: read_word 0x644 (workRam) is 0x00FB; advance to frame 400: 0x00FC.
3. Repeat with c:\Work\gaia-iog-baserom\rebuilt\Illusion of Gaia - Rebuilt.smc. For R also record artifacts/crc.json (mode and sha1 fields if present), the newest GATE: line and the last DONE iteration in the Progress log of audit-of-audit/ACTION_PLAN.md, and the build mode (tagged or plain; plan 2.1). If the mode cannot be established, ask me before continuing. Note whether the R file is older than the newest extracted/ edit (git status, file times) and tell me if a rebuild is needed.
4. load_labels artifacts/labels/iog-original.mlb (O) or iog-rebuilt.mlb (R), then get_label_address NmiHandler: record the NMI offset of each ROM (33528 on O, 0x967C on R).
Pass: both ROMs reach 0xFC, the identity table is complete and matches 2.1 (or the difference is reported). Write mesen2-results/H0_<date>.md. states-index.md already exists: add rows only for states you create.
```

```text
STEP H1 (state library rules and the validity test). Plan: section 4 H1, 1.3 item 1. Needs: H0.
1. Write the procedure as a short checklist in mesen2-results/kit/validity_test.md: load_state_file succeeds (a wrong ROM raises rom_mismatch); advance_frame 120; cpu.k in $80-$BF or $C0-$CF; cpu.sp in $0100-$01FF; sceneCurrent equals the expected id.
2. Test it: rebuilt/states/orig_S01r_south-cape-ready.mss on O (expect PASS, scene $01); the same file on the rebuilt ROM (expect rom_mismatch: record the error text); R-plain_S01r_south-cape-ready.mss on R (PASS) and on O (rom_mismatch); list_states on rebuilt/states (valid flags). Then a state WITHOUT a sidecar (orig_S01_south-cape-start.mss) on O: record that the server accepts it unchecked and run the checklist. Do not use rebuilt/ws-test-south-cape.mss except to record its failure signature once.
3. Update states-index.md for every state you validated (status column).
Pass: two PASS and two rom_mismatch results documented, and the no-sidecar case described. Do not continue to other states in this step.
```

```text
STEP H2 (Lua kit). Plan: section 4 H2, 1.2, 1.4. Needs: H0, H1.
The kit exists: mesen2-results/kit/lib/gaia_kit.lua (project) on top of the server's mesen_kit and iog_kit (0.5.0, from its own lua/lib; check with get_capabilities libDirs). Test every function of the table in plan H2 with run_script includes ["gaia_kit"] in South Cape (state S01r): kit.r8/r16/w8/w16, kit.setBit/getBit, kit.onFrame/off, kit.pulse, kit.finish, iog.state, gaia.log (cap 200: log 250 lines and confirm the cap row), gaia.coll.index/get/set (write a cell, read it back, confirm with get_ppu_state or a walk), gaia.player, gaia.hold/release (hold right for 20 frames: x grows), gaia.trial, gaia.watch/once/censusRows (control: write $36 reports 80:8381). Add to kit/lib/gaia_kit.lua only helpers that a later step truly needs (a ring buffer, a CGRAM dump) and test each; never edit the server's mesen_kit.lua / iog_kit.lua / recipes (ask for a server change instead: request file).
Pass: every helper ran with a firing control and the log cap held. Write the result file.
```

```text
STEP H3 (warps). Plan: section 4 H3, 1.3 items 11-12, 2.4. Needs: H0, H2.
The warp exists (run_recipe warp / iog.warp, plan H3). Do not rewrite it. If you need a variant, put it in kit/lib/gaia_kit.lua.
1. Quick warp: from the boot logo (about frame 100) write_word 0x642 = 1, advance_frame 240, dismiss the banner ($B4 -> 0 with A pulses via set_input), on both ROMs (expect scene $01, $1014/$1016 = 664/752). Also check once that the same write does nothing from the title ($FC) and record it.
2. For $0A (flag $3F), $15, $24, $E8, $FD, $FE: quick warp from an in-game state first (record the default spawn $1014/$1016, joypadMaskStd, banner flag, screenshot with take_screenshot label, returnImage false); where the scene is not reachable or the player is stuck, use run_recipe warp {scene, x, y, flags} with x, y = the spawn minus (8, 16). Repeat $01 and $0A on the rebuilt ROM.
3. Event-flag convention (flag #n = byte 0x0A00 + (n>>3), bit n&7): in a disposable state at $0A run the recipe with flags [63] and with flags [] and report the difference (the guard locks the pad without $3F: joypadMaskStd $065A != 0).
Pass: all listed scenes reached on O, a plausible screenshot each, $01 and $0A on R, and the flag convention confirmed. Save a state per scene with save_state_file (meta: scene, flags, form) and add the rows (flags and spawn) to states-index.md.
```

```text
STEP H4 (positive controls and the tool matrix). Plan: section 4 H4, 1.1, 1.2, 1.3 items 4 and 8. Needs: H2, H3.
Run the native-count control set of plan H4 from S01r once per ROM (NMI offset: 33528 on O, 0x967C on R; from get_label_address NmiHandler), then the same controls in Lua with gaia.watch and an exec callback. Pass: write $36 and NMI exec counts equal the frames advanced on both mechanisms; the other ROM's NMI offset reads 0.
Then the matrix (a)-(k) of plan H4 on both ROMs. The O column is filled in the plan: re-run it and note every difference on R. Items to measure that the plan marks open: (j) an SPC exec callback with emu.cpuType.spc on emu.memType.spcRam and its PC (D2 depends on it); the exec counter of get_access_summary for an NMI range versus the count breakpoint (calibrate: how does exec relate to the number of NMIs?); set_cpu_state on X, Y and a flag; rewind (what does it restore?); dump_memory of 0x1C000, 8192 bytes (SHA-1 in the reply); subscribe_events with breakpointHit; start_trace/stop_trace on an NMI range; emu.mcp.writeFile; get_profiler_data; get_timing_info.
Pass: every row has a status (works / fails / differs) on both ROMs with the evidence line, every failure names the fallback and is added to tool-issues.md with the MCP-nn it supports.
```

```text
STEP H5 (results capture). Plan: section 4 H5, 8.1. Needs: H0.
The structure exists under plans/extracted-audit/mesen2-results/ (states-index.md, closures.md, tool-issues.md with T-01 to T-11, kit/lib, harness/, raw/). Add template.md with the result template of plan 8.1, check that each file's first lines say who appends, and add a raw/.gitignore-style note to README only if raw/ would hold large files (screenshots, per-slot states: tell me, do not edit .gitignore). Do not touch any other folder.
Pass: template.md exists, every file has its header row, harness/README.md matches what you ran.
```

```text
STEP H6 (state library build). Plan: section 5, 4 H1, H3. Needs: H1, H3, H4.
Build the states S00, S01 (S01r exists for O and R-plain: validate), S02, S03, S04, S05, S06, S07, S08, S09 on the original ROM (quick warp from an in-game state where no flags are needed, run_recipe warp where they are; plan H3); then the other S-states only when asked. Per state: warp, banner dismissed, 30 frames, validity test, save_state_file rebuilt/states/orig_<id>_<name>.mss with meta {scene, flags, form}, row in states-index.md (SHA-1, flags written, form, how made). S06 is scene $FC from a cold boot (about frame 350); S07 (diary, scene $FA) is reached from the title by input: record the button sequence with record_input. Repeat S01, S08, S09 on the rebuilt ROM with the mode in the file name (R-tagged_ or R-plain_) once H0 has fixed the mode.
Pass: each state loads, passes the validity test twice (load, test, load, test) and has an index row.
```

### 12.3 Campaign A prompts

```text
STEP A1 (flag write census). Plan: section 7 A1, 6.1. Ids: OQ-20, OQ-38, OQ-60, OQ-I022-1, OQ-I025-1, OQ-I025-2, OQ-I026-6, OQ-I044-2, OQ-I049-3, OQ-I052-5, OQ-I053-3 (also log setters of $0080/$0400 for OQ-8 and $0700 for OQ-I025-6). ROM: O. States: S01, S10, S11, S12, a boss room, a cutscene room. Needs: H2, H4, H6.
Static first: for each id read the question and rg the extracted code for the bit mask and the stores to actor +$10/+$12 (RC-01 to RC-06 of audit-of-audit/A12_findings.md section 5 are the current static readings).
Run: write callbacks over WRAM 0x1000-0x1FFF, filter a & 0x3F in {0x10,0x11,0x12,0x13}, compute changed = old ~ new, log only changes that touch a bit of the id list; group by (bit, offset of the instruction that ends at the PC, set or clear, scene). Play the 5-minute coverage of the plan (walk, attack with A, each form's ability, take damage, kill an enemy, open a chest, talk, warp, die), once per form (Will, Freedan, Shadow). Control: INC $36 write.
Deliver: the table bit | setter offset and routine | clearer | context | count, a coverage statement, and a verdict per id (a bit with no setter in the session: INCONCLUSIVE with the coverage, not "never set").
```

```text
STEP A2 (flag read census and confirmations). Plan: section 7 A2. Ids: OQ-8, OQ-40, OQ-I023-3†, OQ-I027-2†, OQ-I030-2†, OQ-I032-5†, OQ-I036-4†, OQ-I037-4, OQ-I041-6, OQ-I047-2, OQ-I054-3. ROM: O. States: S10, a boss room. Needs: H2, H4, H6.
Static first: the readers of actor $10 bit $0200 are combat_collision.asm about lines 333 (BIT #$76E0), 340 (BIT #$74E0) and 1207 (BIT #$0280): re-read them and state the claim you will confirm.
Run: (1) read callbacks on 0x1010-0x1011 style fields of all slots; log unique reader PCs and map each to its instruction; list those not in the static evidence. (2) Confirmation: in S10 set $10 |= $0200 on the player (write_word 0x1010) and let an enemy touch Will for 120 frames: record HP, hit-stun, iframeCounter; clear the bit and repeat as the control; do the boss-defeat case of OQ-I030-2 once if the boss room is available.
Deliver: reader list per bit, the confirmation table, verdict per id (the five † ids: VERIFIED-RUNTIME if the bit makes Will unhittable and the static readers match, CONTRADICTED with the note quoted otherwise).
```

```text
STEP A3 (forced bit experiments). Plan: section 7 A3. Ids: OQ-20, OQ-54, OQ-I023-6, OQ-I025-6, OQ-I026-5, OQ-I026-6, OQ-I033-6, OQ-I044-2. ROM: O. States: S01, S03, S10. Needs: H2, H6. Do A1 first if you can: it names the setters.
For each id: pick a visible actor or the player, write the bit on and off with write_word (low DP excluded), advance 30 frames, take a screenshot, log the actor's next 30 frames of $10 and $12; always run the control (same actor, bit untouched). OQ-I033-6 concerns $0E (OAM attribute priority $2000/$3000), not actor $10: test the word the question names. Do not leave a poked state in the library.
Deliver: before/after screenshots (paths), the observed effect in one plain sentence per id, and a verdict per id.
```

### 12.4 Campaign B prompts

```text
STEP B1 (collision census). Plan: section 7 B1, 2.4. Ids: OQ-3, OQ-16, OQ-41, OQ-I029-5, OQ-I030-3, OQ-I032-4, OQ-I051-6, OQ-I052-4. ROM: O. Needs: H2, H3, H4.
Static prelude first: read tile_collision_physics.asm index math and plan 2.4 "Collision layer": the layer is WRAM 0x1C000 in 256-byte pages of 16 x 16 cells, index = (((ty>>4)*stride + (tx>>4)) << 8) | ((ty&15)<<4) | (tx&15), stride = $0693, low nibble base type, high nibble dynamic mark, bounds $0692/$0696 in pixels. It is NOT a row-major array. If the code disagrees with this, use the code and say so.
Run: for the scene ids of artifacts/scenes.json (and db-us/groups.json), in batches of about 20: quick warp (300 frames; the recipe warp where flags matter), banner dismissed, then one run_script with includes ["gaia_kit"] that reads every cell with gaia.coll.get over (bounds/16)^2 and returns a row per scene with kit.finish: scene, width, height, stride, counts of low-nibble types $03 $04 $05 $06 $09 $0A $0C $0E, high-nibble nonzero count, $0692 and $0696 (OQ-41). For the first ten cells of type $06 and $09 record coordinates; take a screenshot with the player next to the first of each (write $1014/$1016, 30 frames, take_screenshot). South Cape is the reference row: $06 16 cells, $09 18 cells, stride 3.
Deliver: the scene census table (put the full table in mesen2-results/raw/B1_census.md), the list of scenes with $06/$09, S13 and S14 candidates (a natural slope scene and a ramp scene; create the states), verdicts for the ids (OQ-I030-3: which real maps hit $06/$09).
```

```text
STEP B2 (synthetic terrain walking tests). Plan: section 7 B2. Ids: OQ-16, OQ-24, OQ-25, OQ-I029-5, OQ-I033-1, OQ-I033-2, OQ-I033-3, OQ-I033-4, OQ-I038-1, OQ-I038-2, OQ-I038-5, OQ-I039-1, OQ-I039-2, OQ-I039-3, OQ-I039-5, OQ-I040-4 (magnitude half only), OQ-SAN2-2 (same). Answered (positive controls only): OQ-I029-1, OQ-I029-4 and the push direction of I040-4/SAN2-2 (player_move_east.asm:26: $09 pushes south, $06 north). ROM: O. State: S01. Needs: B1 for the stride, H2, H4.
Static first: for each id read the arithmetic in the question's static evidence and compute the expected trajectory before running.
Harness first: run harness/scenario_b2_special_tiles.py (or its Lua through run_script) on O and confirm that it reproduces mesen2-results/B2_special_tiles_20261029.md (control dx +80; $0F stalls; $06 row 0 dy -16; $09 row 0 dy +16). Copy the script to a new name for your tests; do not change the original.
Run per test: load S01r; in gaia.trial setup clear a 6 x 4 cell area around the test cell with gaia.coll.set (paged layer: plan 2.4, never 0x1C000 + row*stride + col), paint the pattern (low nibble = type, high nibble 0), place the player (0x1014/0x1016, speeds 0x09B2/0x09B4 zero), hold the direction with gaia.hold for N frames; sample posX, posY, speeds and $1010 per frame (add $22, $24, $26, $AA, $AB, $09B6, $09B8, $09C6 when a question asks for them); return the table with kit.finish. Each trial twice (identical) and on O and R; a control trial with no paint and a $0F control. Keep a table (variable, outcome). Run the direction controls (I029-1/I029-4) first: if they disagree with the notes, stop and report before running the rest.
Scope: the player does not call CheckActorOnSpecialTile (plan 7 B2 scope warning): the pair-pattern ids (OQ-16, OQ-I029-5, OQ-I033-4) need a non-player actor with flag $0008; find one in South Cape, or mark those ids INCONCLUSIVE with the reason.
Deliver: the trajectory table, expected vs observed, verdict per id.
```

```text
STEP B3 (movement trace on natural terrain). Plan: section 7 B3. Ids: OQ-I024-5, OQ-I029-2, OQ-I032-1, OQ-I032-2, OQ-I032-3, OQ-I032-4, OQ-I045-3, OQ-I047-1, OQ-I048-5, OQ-I052-3. ROM: O. State: S13 (from B1). Needs: B1, H2, H4.
Instrument by decimal key (names/bank02.json): DecelerateNS 177940, ClampSpeeds 177694, DispatchEastMove 186076, CancelVerticalPhase 188666, FindSlopeForEastMove 176571, FindSlopeForWestMove 176488 (verify each key still exists; renames continue). Exec callbacks log A, X, Y, SP and the stack word at SP+5 (OQ-I029-2). Walk onto and off the slope in each direction, stop mid-slope, run. OQ-I024-5: check that DispatchEastMove calls the east-move probe under its current name.
Deliver: which routine ran with which operand per action, verdict per id.
```

```text
STEP B4 (ramps, glide, booster). Plan: section 7 B4. Ids: OQ-I023-1, OQ-I030-4, OQ-I036-1, OQ-I036-2, OQ-I036-3, OQ-I040-1, OQ-I040-2. ROM: O. States: S14 and a glide scene (OQ-I023-1: find the scene from the slider_glide notes and docs/code). Needs: B1.
Approach each ramp at walk and run speed; log the equality check outcome (OQ-I036-1), the landing posX/posY after the launch (OQ-I036-2); log playerSpeedEw per frame across the booster trigger (OQ-I040-1/2); for glide record start and end position and the collision rows crossed. Run each case twice.
Deliver: tables per ramp, verdict per id.
```

### 12.5 Campaign C prompts

```text
STEP C1 (adhoc VRAM DMA ordering). Plan: section 7 C1, AGENTS.md "IOG Adhoc DMA Register Map". Ids: OQ-45, OQ-I022-4 (OQ-64 is closed). ROM: O. Needs: H2, H4 (the NMI control).
Static first: list every writer of $7F0C07 and $7F0C09 and of $4200 in extracted/ (offsets), and the order of the stores at each writer.
Run: write callbacks on WRAM 0x10C07 and 0x10C09 and on $4200 (snesMemory, both $00: and $81: aliases), exec callback on the NMI control. For each trigger/size pair record the NMI count between the stores and the last NMITIMEN bit 7 written. Cover the radar/map screen (Start), an inventory open, a Dark Space entry and a chest. Do not use step_instruction as proof.
Deliver: windows with an NMI between the stores (zero or the list), the NMI-enabled writers (OQ-I022-4: PCs), verdict per id, and the coverage statement.
```

```text
STEP C2 (NMITIMEN callers). Plan: section 7 C2. Id: OQ-I022-4. ROM: O. Run together with C1 if the session allows. Boot half: run_script {fromReset:"power"} (server 0.6.0 or later) sees the writes before frame 97; C1 (2026-10-30) already has the first three PCs.
Write callback on $4200 (snesMemory $81:4200 and $00:4200): unique PCs and values written; separate the callers that enable NMI from those that disable it. Map each PC to its instruction and routine.
Deliver: table of PCs (offset, routine, value), verdict.
```

```text
STEP C3 (boot, reset, MEMSEL, SRAM). Plan: section 7 C3. Ids: OQ-50, OQ-I024-4, OQ-I055-3. ROM: O (R for nothing). State: S00.
OQ-I024-4: from cold boot (run_script {fromReset:"power"}, server 0.6.0 or later; frame 0 = first boot instruction) log writes to $420D with PC and frame (first 200 frames); count frames between the first APUIO ($2140) write and the boot logo. OQ-50: set $0100 to $83 and to another value, call reset {mode:"soft"} (WRAM kept), record whether SystemInit (key 32788) takes a different path (first sceneNext write, frame). OQ-I055-3: set event flag $10 (byte 0x0A02 bit 0), reset {mode:"soft"}, check whether the first logo is skipped or shown. Use disposable states. A plain load_rom + pause arrives at about frame 97 and misses the boot: do not use it for this step.
Deliver: log tables and a verdict per id.
```

```text
STEP C4 (displayModeFlags bits). Plan: section 7 C4. Ids: OQ-6, OQ-23†, OQ-42, OQ-51, OQ-I034-1†, OQ-I057-4†. ROM: O. States: S06, S09, S01. Needs: H2, H4. Prefer to run after IT-35 (static-answers.md) when it exists: read it first and skip what it settled except for confirmation.
Static first: Bg3TilemapVramDma (key 176184, camera_tilemap.asm about 880-892, mask $31); bit 14 = hudDisableFlag bit 6 read by UpdateHUD (key 33286, system_core.asm about 394-401); search the stores to displayModeFlags ($09EC/$09ED) for OQ-42 and OQ-51 and list the writers by offset.
Run: write callbacks on 0x09EC-0x09ED (changed bits via old ~ new, bit, offset, scene) and read callbacks; play title, inventory, dialogue (bit 13), map, boss. Confirmations: force bit 14 in scene $FA and compare screenshots (HUD off); force bits 0, 4, 5 and watch the next NMI's BG3 DMA and the VRAM bytes.
Deliver: per bit: setters, readers, effect observed; verdict per id.
```

### 12.6 Campaign W prompts

```text
STEP W1-<batch> (address census; run once per batch a..g). Plan: section 7 W1 (batch table), 6.1. ROM: O. Needs: H2, H4. Replace <batch> and use that row of the plan's table for the WATCH list and the ids. Ids marked † are confirmations (OQ-I065-3†). 
Static first: for each watched address rg the extracted code for readers and writers and write them down with offsets.
Run: the W1 template (plan 6.1, gaia.watch) with the watch list set to the batch, read and write callbacks; control: INC $36 write (reports 80:8381). Play a 5-10 minute session that visits a town, a dungeon with enemies, a menu, a chest, a warp and a cutscene (list the scenes visited). For flag bytes use the bit-change variant.
Post-process: every logged K:PC to the instruction ending at the PC, its offset and routine; compare with the static list; the new ones are the findings.
Deliver: per watched address a table of readers and writers (offset, routine, count), the coverage statement, verdict per id. A watch with no hits is INCONCLUSIVE unless the coverage reaches the code path; say which path.
```

### 12.7 Campaign D prompts

```text
STEP D1 (APU port log). Plan: section 7 D1. Ids: OQ-10, OQ-29, OQ-48, OQ-I046-1, OQ-I056-5, OQ-I065-3† (confirm: $06F2 is the BGM id stored by SpcMusicLoadCmd, key 166765), OQ-SAN2-1. ROM: O. States: S18, S01, S16, N3's S15. Needs: H2, H4, docs/audio/bgm-track-listing.md.
Run: write callbacks on $2140-$2143 (snesMemory, both aliases) logging frame, port, value, scene; decode sound ids with the track listing. Open a chest (OQ-29), take damage as each form (OQ-I046-1: expect #07 Will, #08 others), watch camera shake (OQ-SAN2-1: count #15 per tick), scene changes (OQ-10: ids $0D/$17), read $06F2 at every music start. OQ-48: count frames MusicRenderSync (key 172261) waits.
Deliver: the port log summary per context, verdict per id.
```

```text
STEP D2 (SPC-side trace). Plan: section 7 D2. Ids: OQ-I021-2, OQ-I021-3, OQ-I022-3. ROM: O. Needs: H4 items (j) and (k) passed. If SPC callbacks or spc.* state do not work, stop and report INCONCLUSIVE with the tool issue.
Using docs/audio/spc-disassembly.md pick the SPC addresses of the command handlers (fade-out, stop, $F2, $F0, $F1) and the fade counters; exec callbacks with emu.cpuType.spc / spcRam; trigger FadeThenStartMusic (key 34633) in a scene change; log the order and timing of $F1, $01, $F0, $F2 as seen by the SPC and read the DSP master volume registers per 4 frames (spcDspRegisters).
Deliver: the sequence, whether the volume ramps audibly (DSP values), verdict per id.
```

```text
STEP D3 (static transfer parse). Owner: IT-35 (static answers). Do not run a Mesen2 session. If asked to do it anyway: id OQ-I022-2; read the SPC block headers from the ROM with rg and Read using docs/audio/spc-engine.md and corpus/games/iog/project-docs/spc-transfer.md; state the destination of the first chunk with the offset and bytes you read; grade VERIFIED-STATIC. Write mesen2-results/D3_<date>.md.
```

### 12.8 Campaign E prompts

```text
STEP E1 (display state dump). Plan: section 7 E1, 6.4. Ids: OQ-1, OQ-I024-6, OQ-I028-6, OQ-I033-5, OQ-I034-2, OQ-I035-5, OQ-I048-2, OQ-I053-4, OQ-I066-3. ROM: O. Needs: H3, H4.
For each scene named by the question: full warp, 120 frames, then capture: get_emulator_state PPU fields (TM, TS, CGWSEL, CGADSUB, COLDATA from $7F0C00-02, window registers), a screenshot, a CGRAM dump of the affected range, $66. OQ-I028-6: step each scene logging writes to $2131/$2132 (both aliases) per frame. OQ-I048-2: compare PPU registers at three points of scene $FD. State the register values in hex.
Deliver: one table per scene, screenshots, verdict per id.
```

```text
STEP E2 (palette bundles). Plan: section 7 E2. Ids: OQ-31, OQ-I026-4, OQ-I027-6, OQ-I029-6, OQ-I031-4, OQ-I036-5, OQ-I036-6, OQ-I040-3, OQ-I044-1, OQ-I059-2, OQ-I060-5 (OQ-I060-6 is static, not here). ROM: O. Needs: H2, H4. Read docs and the cop_handlers_palette notes first.
(1) Static: decode every bundle with the bundle model of cop_handlers_palette (sub-entry lists) to a table bundle id -> CGRAM range, colour count, frame count. (2) Runtime: exec callback on PaletteStart (key 37732) logging bundle id and scene; capture CGRAM before and after for each bundle reached; for never-staged bundles use R1 counters over the bundle's data offsets. Method group: one run, a verdict per bundle and per id.
Deliver: the bundle table (mesen2-results/raw/E2_bundles.md), per-id verdicts, bundles never reached with the coverage statement.
```

```text
STEP E3 (Mode 7 and the world map). Plan: section 7 E3. Ids: OQ-I041-2, OQ-I041-3, OQ-I041-4, OQ-I056-8, OQ-I058-1, OQ-I059-4 (and claim CL-10: M7SEL). ROM: O. State: S08. Needs: H4.
Log the Mode 7 matrix words $C2-$CD and $B6/$B8/$BC per frame through the zoom-out (first-frame $B8 for OQ-I059-4; also count the passes and ticks per pass: the audit reads about 44 passes of 2 ticks); write callbacks on the HDMA table ranges ($7E7000, $7E7800, $7E8000) with their PCs against the staging buffers (OQ-I041-3); screenshot the area below the boundary row (OQ-I058-1); R1 counters on the divisor-overflow labels (OQ-I041-4); read M7SEL shadow ($211A through the write callback value) and screenshot beyond the plane (CL-10).
Deliver: tables and screenshots, verdict per id and for CL-10.
```

```text
STEP E4 (HDMA, windows, parallax, credits). Plan: section 7 E4. Ids: OQ-32, OQ-I031-1, OQ-I031-2, OQ-I031-3, OQ-I032-6, OQ-I035-1, OQ-I035-3, OQ-I035-4, OQ-I057-3. ROM: O. States: S19 per scene (credits, dream, Mu lair, $32, $E9/$EA, $C3, title). Needs: H3.
Per scene, every 30 frames for 300 frames: W12SEL, WOBJSEL, TMW, TSW, CGWSEL, CGADSUB (write callbacks keep the last value), $66, the first 16 bytes of each active HDMA table, a screenshot. OQ-32: which channels SetupHdmaChannel_Direct/_Indirect (names/bank03.json) use and the carry result.
Deliver: per scene tables, screenshots, verdict per id.
```

### 12.9 Campaign F prompts

```text
STEP F1 (animation forcing). Plan: section 7 F1. Ids: the F1 rows of the inventory (list in plan F1; P3 visual). ROM: O. Needs: H3, H6. Take the ids in groups of one sprite set at a time; stop an id after one attempt per host scene and mark NOT-VISIBLE.
For each id: find the sprite set and the indices from the question; choose a host actor on screen that uses the set (NPC for npc_props, the player for body tables with characterForm set per H3, an enemy for spriteset_enemies); in an endFrame callback hold the host's sprIdx (+28) and sprFrame (+2A) at the test index; screenshot (crop by eye), read OAM for tile and palette. Never leave a poked state in the library.
Deliver: one screenshot per index with the host scene, a one-line description, verdict per id (NOT-VISIBLE where the set is not loaded anywhere). Process 8 ids per run; say which are left.
```

```text
STEP F2 (residual hidden-group row). Plan: section 7 F2. Id: OQ-I063-5 (lone set 0E86AE). The hidden-group trio (OQ-I067-5, OQ-I069-4, OQ-I071-5) is static: do not run it. ROM: O. Needs: F1.
Write the set's address into a host actor's frame pointer (confirm the field in docs/code/bank00/data-tables-memory.md), judge by OAM and screenshot; if the host tiles do not match use the OAM dump alone.
Deliver: the OAM values and a verdict. If the set cannot be shown, INCONCLUSIVE with the reason.
```

```text
STEP F3 (header-byte cross-check, run inside G1). Plan: section 7 F3, G1. Id: OQ-I066-4 (damage half). No separate session. Compare the hit rectangle observed in G1 for the Aura body boxes with header bytes 8-11 of the Aura sprite group (read the group bytes from the ROM). Verdict goes in G1's result file; this prompt exists so the cross-check is not forgotten.
```

### 12.10 Campaign G prompts

```text
STEP G1 (hit and damage paths). Plan: section 7 G1. Ids: OQ-8, OQ-9, OQ-I037-4, OQ-I041-5, OQ-I041-6, OQ-I042-4, OQ-I062-2, OQ-I066-2, OQ-I066-4 (damage half; also the F3 cross-check). ROM: O. States: S10, S11, S12. Needs: A1/A2 results if they exist, H2, H4.
Exec callbacks by decimal key: RunCombatCollision 244708, CombatCollision_EnemyLoop 244729, PlayerAttackHitTest 245085, ApplyHitDamageToVictim 245543 (player hits actor), ApplyPlayerHitstun 50071, HitStaggerMain 55415 (verify keys; EnemyHitPlayerHandler is not a label, the pass is inside RunCombatCollision). In each log attacker slot, victim slot, both $10 and $12, the damage computed, iframeCounter ($7F0028) sign. Use every attack and ability once per form. Record which path each attack takes (OQ-I066-2) and the claim CL-02 (positive iframeCounter = victim frozen, negative = recovery).
Deliver: attack-to-path table, flags at the gates, verdict per id and CL-02.
```

```text
STEP G2 (death, rewards, drops). Plan: section 7 G2. Ids: OQ-53, OQ-67, OQ-I042-1†, OQ-I046-4, OQ-I046-6, OQ-I047-2, OQ-I049-3, OQ-I049-5, OQ-I049-6† (half), OQ-I050-1, OQ-I050-6, OQ-I051-3, OQ-I051-5, OQ-I052-6, OQ-I053-7, OQ-I054-2, OQ-I054-3, OQ-I054-4, OQ-I054-5, OQ-I070-3; claim CL-11. ROM: O. States: S10, S16. Needs: A1, G1.
(a) $0AEC/$0AEE writes per scene entry and kill. (b) Kill about 200 enemies of one type (set HP to 1, hit): drop counts per item id, compare with the nine percentages in the I049 result. (c) OQ-I053-7: die in scene $E8; log the next sceneNext, form, $0AF0/$0AF2. (d) OQ-I051-3: watch $04/$06 of the reward handler's slot and $56 around the handler. (e) OQ-I070-3: static tier tables, then a kill-all pass in a sample of scenes. (f) CL-11: STR to $7E, use a stat-up. Item use and chest code may sit in plain-only blocks: record the build mode.
Deliver: tables, rates with sample sizes, verdict per id and CL-11. Do not report a rate from fewer than 100 trials.
```

```text
STEP G3 (pool-full, hitstun, knockback). Plan: section 7 G3. Ids: OQ-17, OQ-66, OQ-I026-3, OQ-I036-7, OQ-I041-5, OQ-I046-1, OQ-I046-2, OQ-I046-3, OQ-I047-1 and claims CL-02, CL-09. ROM: O. States: S05, S10, S14. Needs: G1.
Fill the actor pool (spawn requests or a crowded scene) until actorPoolPtr ($4E) reaches the end; then take a hit, use the Wind Flute, climb the ramp. An endFrame walker follows the actor list ($56/$58 and +04/+06 links) and logs a cycle or dangling link. Count the NMI frames of a hit-stun (CL-09: the notes say about 17).
Deliver: tables, verdict per id and per claim.
```

```text
STEP G4 (enemy stat rows). Plan: section 7 G4. Ids: OQ-I046-5, OQ-I054-5, OQ-I066-1. ROM: O. Needs: H2.
Static: decode the stats table (gem type +3, knockback tier source, rows referenced by any spawn record; IT-22 may have counted the unused rows: read IT22_apply.md first). Runtime: a write callback on statsPtr stores across a coverage session to see which rows are loaded.
Deliver: row table, the rows never loaded with the coverage statement, verdict per id.
```

### 12.11 Campaign M prompts

```text
STEP M1 (inventory and items). Plan: section 7 M1. Ids: OQ-39, OQ-I023-4, OQ-I026-2, OQ-I026-3, OQ-I028-1, OQ-I028-2, OQ-I028-3, OQ-I028-5, OQ-I034-4, OQ-I034-5, OQ-I034-6, OQ-I035-5, OQ-I047-3, OQ-I050-1, OQ-I050-6, OQ-I064-3, OQ-I067-1, OQ-I067-2, OQ-I071-3, OQ-I071-4, OQ-I071-6, OQ-I072-1, OQ-I072-2. ROM: O, and R for OQ-I028-1 (arrange mask $8044 uses logical bits). States: S09, S03. Needs: H3, H6.
Run the procedure of plan M1 per id. Give each item id $00-$40 through the item-slot write and screenshot the name box (OQ-I067-1/I067-2/I072-1; this answers "Mystic Statue vs Mystery Doll"). Use memory snapshots (read 0x0AB4-0x0AC3 and the cache and sine-table ranges named by OQ-I034-4/5/6 before and after opening the inventory). Item use runs through item_use_system (plain-only transform sites: Inca statue compares): record the build mode for any item-use result.
Deliver: tables and screenshots, verdict per id. Process the ids in two runs if needed.
```

```text
STEP M2 (title, boot, diary). Plan: section 7 M2, 2.1. Ids: OQ-I055-1, OQ-I055-2, OQ-I055-3, OQ-I055-5, OQ-I056-8, OQ-I057-1, OQ-I057-3, OQ-I057-6, OQ-I058-2. ROM: O, and **R-plain** for OQ-I057-1 (the diary remap sites are plain-only transforms; on R-tagged you would test the vanilla code). If only R-tagged exists, run the rest and list OQ-I057-1 as BLOCKED until IT-27 is DONE or you get a plain ROM. Needs: H3, H6.
Cold boot: screenshot every 8 frames for the first 400 frames (logo timing; the 120-tick loop follows n+1). Diary: create, erase, copy a slot; log $0D94 (OQ-I057-6). OQ-I057-1: press each physical button on title and diary on both ROMs; log $0656, raw joypad ($4218/$4219 via read callback) and the effect; record the physical-to-logical table.
Deliver: tables and screenshots, verdict per id, build mode on every R row.
```

```text
STEP M3 (world map, routes, exits). Plan: section 7 M3. Ids: OQ-37, OQ-63, OQ-B001-2, OQ-I040-3, OQ-I042-5, OQ-I042-6, OQ-I042-8, OQ-I058-1, OQ-I059-1, OQ-I059-2, OQ-I059-3, OQ-I059-4, OQ-I059-5, OQ-I059-6, OQ-I059-7, OQ-I059-8, OQ-I060-1, OQ-I060-2, OQ-I060-3†, OQ-I060-4 and claim CL-01 (n+1 ticks per route step). ROM: O. States: S08, S04. Needs: H3, H6.
Run each route; log $0D58 (choice id) writes with PC (OQ-I060-1: which ids ever appear); count NMI frames per route step (the audit reads n+1 per step, IT-09: report observed vs n+1); LookupMapName (key 239250) with the scene id (OQ-I059-7); Edward's Castle exit: log player Y per frame on the approach (OQ-I042-5; if Y never equals $2D0 and the exit fires, the note is wrong). Overlap rows with E3 (I058-1, I059-4) are answered once; cite the result under both ids.
Deliver: tables, verdict per id, CL-01.
```

```text
STEP M4 (text and console renderers). Plan: section 7 M4. Ids: OQ-27, OQ-33, OQ-34, OQ-35, OQ-48, OQ-58, OQ-I028-4, OQ-I063-1, OQ-I065-1, OQ-I065-6, OQ-I067-1, OQ-I072-1. ROM: O. Needs: H3.
VRAM tile dump of the BG3 font (read_memory type "ppu"; font fills $6000-$6FFF), tilemap rows for boxes (OQ-34), the longest scene title (OQ-58), CGRAM entries of the speaker templates (OQ-I065-1), talks to NPCs with template $10 vs $0F (OQ-I065-6), numbers over 4 digits (OQ-27: $00DC).
Deliver: dumps in raw/, screenshots, verdict per id.
```

### 12.12 Campaign N prompts

```text
STEP N1 (NPC and actor behaviours). Plan: section 7 N1. Ids: OQ-43, OQ-44, OQ-I025-6, OQ-I026-5, OQ-I030-1, OQ-I036-5, OQ-I037-1, OQ-I037-5, OQ-I039-6, OQ-I041-7, OQ-I042-3, OQ-I043-1, OQ-I045-2, OQ-I048-1, OQ-I050-3, OQ-I050-7, OQ-I052-6, OQ-I052-8, OQ-I053-1, OQ-I053-2, OQ-I062-1; claim CL-07 if the jeweler scene is reached. ROM: O (plain-only blocks: teleporter, sliding wall, solid arm: record the mode). Needs: A1, R1, H3.
Per id: go to the scene the question names, ring-buffer the actor slot (+14/+16/+08/+10) around the interaction, compare with the static trace. OQ-I050-7: the NPC's wait is n+1 ticks: measure. For non-referenced actors run R1 first. Group ids by scene to minimize warps.
Deliver: per-id observation, verdict, CL-07 result.
```

```text
STEP N2 (cutscenes and bosses). Plan: section 7 N2. Ids: OQ-I025-5, OQ-I030-2, OQ-I044-1, OQ-I048-2, OQ-I048-3, OQ-I049-2, OQ-I052-3, OQ-I053-6, OQ-I053-7, OQ-I072-5 and claim CL-08 (revive costs 100 gems). ROM: O. States: S16, S17. Needs: H3.
Screenshot sequences, PPU snapshots and live-actor counts every 30 frames; confetti burst count by counting live actors of the confetti type (OQ-I048-3); game over with 100+ gems, read the gem counter before and after the continue (CL-08).
Deliver: tables, verdict per id and CL-08.
```

```text
STEP N3 (Dark Space and Gaia). Plan: section 7 N3. Ids: OQ-I053-3, OQ-I056-1, OQ-I056-2, OQ-I056-3, OQ-I056-4, OQ-I056-5, OQ-I067-3. ROM: O. State: S15. Needs: H3, D1 for music ids.
Set characterForm = Shadow and test each Will ability (OQ-I056-1); log globalScriptIndex ($0AAC) writes (OQ-I056-4: value 1 only in the pyramid); music ids through D1 (OQ-I056-5); Firefly direction (OQ-I056-2).
Deliver: tables and screenshots, verdict per id.
```

```text
STEP N4 (COP semantic probes). Plan: section 7 N4. Ids: OQ-47, OQ-54, OQ-55, OQ-56, OQ-62, OQ-69, OQ-I037-2†, OQ-I037-3†, OQ-I038-3, OQ-I044-3, OQ-I045-5, OQ-I051-1†, OQ-I060-4, OQ-I061-2, OQ-I062-3, OQ-I068-4. ROM: O. Needs: H3, docs/cop/index.md and the family docs.
Rule: never invent COP bytes. For each id first look for an existing script that hits the corner case and trace it (exec callbacks, X = D = slot id). Only if none exists and the COP format is fully documented in db-us/copdef.json plus the family doc, build a probe script in an unused actor slot's script area. Otherwise INCONCLUSIVE with the reason.
Deliver: per id the trace, the observed branch or effect, verdict.
```

### 12.13 Campaign P prompts

```text
STEP P1 (input and facing). Plan: section 7 P1. Ids: OQ-28, OQ-I025-3, OQ-I044-4†, OQ-I052-7, OQ-I057-1 (with M2, R-plain). OQ-22 is answered (0 down, 1 up, 2 left, 3 right): use it as the positive control. ROM: O and R. States: S01, R-<mode>_S01. Needs: H3.
OQ-I025-3: tap the faced direction twice with N frames between (N from 8 to 16) and log $040C and the speed: report the largest gap that still triggers a run (the audit's static count is 13 or 14 states). OQ-I044-4 and OQ-I057-1: press each physical button once on the rebuilt ROM and log $0656, the raw joypad (read callback on $4218/$4219) and what the game does; make the physical-to-logical table and compare with the original ROM. OQ-28: write $0AC8 values 4-7 and observe the FacingData table in use (GetPlayerFacingDirection key 258250). OQ-I052-7: facing results >= 4.
Deliver: tables, verdict per id, CL-06.
```

```text
STEP P2 (abilities). Plan: section 7 P2. Ids: OQ-I025-4, OQ-I025-5, OQ-I027-1, OQ-I027-3, OQ-I027-4, OQ-I061-1, OQ-I062-2, OQ-I069-3, OQ-I070-2, OQ-I071-1, OQ-I071-2, OQ-I072-4, OQ-I072-6. ROM: O. States: S11, S12. Needs: H3, W1-f.
Fire each ability at upgrade levels 0/1/2 (set the ability level byte). Log player position before/after (Psycho Dash), $16 at spawn (OQ-I027-1), Dark Friar fragment velocities (OQ-I027-3), the $0AC8 writes (body-table row selection).
Deliver: per-ability tables, verdict per id.
```

```text
STEP P4 (camera). Plan: section 7 P4. Ids: OQ-57, OQ-I025-7, OQ-I049-4, OQ-I050-2, OQ-I050-4, OQ-I051-1†, OQ-SAN2-1 (shake sound; D1 owns it). ROM: O. Needs: H3. CAM group: method only, a verdict per member.
Log cameraTargetX/Y and the player position per frame during a vine-drop landing (OQ-I025-7), in normal play (OQ-I049-4: compare player screen Y with 112) and in scenes with camera_drift (OQ-I050-2, OQ-I050-4: $24 = $FFFF).
Deliver: tables, verdict per id.
```

### 12.14 Campaign R prompts

```text
STEP R1 (execution coverage). Plan: section 7 R1, 6.2. Ids (UNREF is a method group: one verdict per member): OQ-I072-3, OQ-I023-5, OQ-I034-3, OQ-I038-4, OQ-I039-4, OQ-I045-4, OQ-I048-4, OQ-I049-1, OQ-I049-7, OQ-I050-5, OQ-I057-2, OQ-I057-5, OQ-I067-4, OQ-I068-2, plus the "never executed or read" rows of B001-1/I056-7, I042-1, I060-5, I062-4, I063-1, I063-2, I064-4, I065-4, I066-5, I068-5, I069-1, I069-2, I072-6. ROM: O. Needs: R2 (run it first or together), R3 static results, H2.
Method: long coverage session on the original ROM (new game to the first dungeon boss with menus, warps to every scene for 10 seconds each, title, diary, credits, game over). For every label take its decimal key from db-us/names/bankNN.json and call get_access_summary {type:"prgRom", ranges:[{name, start, length}...]} (100 ranges per call; keep the never_accessed rows) and get_cdl_data {format:"summary"|"ranges"}; archive the CDL with save_cdl (path under mesen2-results/raw) and union runs with load_cdl. Add get_cdl_statistics totals. The exec figure of get_access_summary is a sum over the range's bytes: do not report it as a rate.
Deliver: table label | offset | exec count | CDL flags | verdict per id; coverage statement (scenes, frames); a zero count is INCONCLUSIVE unless R3 also found no reference.
```

```text
STEP R2 (scene sweep). Plan: section 7 R2. Ids: OQ-13, OQ-30, OQ-I035-7, OQ-I042-7, OQ-I056-6, OQ-I060-1, OQ-I061-3, OQ-I064-1, OQ-I065-2, OQ-I065-4, OQ-I068-3, OQ-I068-4. ROM: O (and R for OQ-I065-2: scene_meta lookup differs between the ROMs). Needs: H3, B1 recipe.
Driver script: for each scene id (from db-us/groups.json and the scene table length) set $0642, advance 180 frames, log sceneCurrent, whether the id changed, PPU mode, BGM id ($06F2), display preset byte, actor count $0DBC, and the B1 histogram. One line per scene; at most 20 scenes per call under the log cap; keep the lines in raw/R2_sweep.md. Reset between scenes by load_state_file of S00 or a fresh warp.
Deliver: the sweep table, scenes that failed to load, verdict per id, and the union coverage handed to R1.
```

```text
STEP R3 (ROM pointer scans, static). Plan: section 7 R3. Ids: OQ-I034-3, OQ-I038-4, OQ-I045-4, OQ-I048-4, OQ-I049-1, OQ-I050-5, OQ-I057-2, OQ-I057-5, OQ-I072-3. No emulator. For each unreferenced label take its key and CPU address; rg extracted/ for JSL/JSR/JMP/&label/@label/$&label/$@label references; byte-search the ROM (rebuilt/Illusion of Gaia.smc) for the 16-bit and 24-bit little-endian pointers; a hit in a table is "referenced through data": name the table. Record each search pattern.
Deliver: per label the references found (file:line or table + offset) or none, verdict per id (VERIFIED-STATIC). No edits.
```

### 12.15 Static, tooling, claims and closure

```text
STEP S1 (static checks). Owner: IT-35 (audit-of-audit/ACTION_PLAN.md). Not a Mesen2 session. If you are asked to run it: ids OQ-19, OQ-21 (remainder), OQ-26, OQ-46, OQ-I022-2, OQ-I060-6, OQ-I070-1 and the dagger pointers of A12 section 8 (OQ-23, OQ-I034-1, OQ-I057-4, OQ-I035-6, the OQ-I023-3 family, OQ-I044-4, OQ-I037-2, OQ-I037-3, OQ-I051-1, OQ-I042-1, OQ-I049-6, OQ-I050-5, OQ-I060-3). Use only rg and Read; for each id write answer (2-4 sentences), evidence file:line, and what remains open, or "not settled" and why. Write mesen2-results/S1_<date>.md. Do not edit notes. Check that open-questions.md and static-answers.md of IT-35 do not already exist; if they do, read them instead and stop.
```

```text
STEP T1 (tooling decisions). Owner: audit-of-audit iterations IT-26 (OQ-I056-9), IT-27 (OQ-49 / OQ-I026-1), IT-30 (OQ-59 / OQ-I024-1). Not a Mesen2 session. If asked for status: read the Progress log and the IT<NN>_apply.md files, report which are DONE, the newest GATE: line, and whether plain and tagged builds are now identical (that decides plan section 2.1). OQ-7 and OQ-I027-5 are answered. Write nothing but mesen2-results/T1_<date>.md.
```

```text
STEP V1 (claim confirmations). Plan: section 7 V1. Claims: CL-01 to CL-12 (table in the plan). Each claim rides on an experiment: run it inside that experiment's session and cite the result here; this prompt covers only claims whose experiment did not run. ROM: as the claim's row says (R-plain for anything about diary or item-use compares). Needs: the host experiment's states.
For each claim: re-read the audit source (file:line named in the table), state the prediction in one sentence BEFORE the run, run the observation, report observed vs predicted, grade. A contradicted claim: quote the shipped note (file:line) and give the corrected plain sentence in the deliver table; do not edit anything.
Deliver: mesen2-results/V1_<date>.md with one row per claim, prediction, observation, grade, shipped text affected.
```

```text
STEP Z1 (closure: the only step that edits the baserom). Plan: section 8.2. Input: the result files you are told to close (list their names), plus mesen2-results/closures.md.
Preconditions (check first, stop and report if one fails): (1) read audit-of-audit/ACTION_PLAN.md Progress log and section 6; no iteration that owns the files you will touch is open (ownership 6.4); (2) git status --short in gaia-iog-baserom is understood (list what is already modified; do not stage or revert it); (3) the newest GATE: line is known.
Steps: (a) For each VERIFIED-RUNTIME or CONTRADICTED verdict append a row to closures.md. (b) For each, find the shipped sentence (ids are gone from shipped text: rg -n "Not traced|not traced|no reader found" extracted notes plus the A12 'cited in' hint) and decide: replace with the plain observed statement, correct a wrong note, or leave it. (c) Write one merge spec edits/MS<NN>.json following gaia-core/docs/notes-and-comments.md "Notes Merge"; respect ACTION_PLAN 6.1 (style) and 6.3 (hazard keys; $8000 text in combat_collision and actor_execution; MenuSelectionHandler refused). Names: one npm run names spec per gaia-core docs. Dry-run both and show me the summary BEFORE applying. (d) Apply; npm run extract:lt, then npm run rebuild (separate commands); compare artifacts/crc.json with the newest GATE: line; a difference means stop and report the numbers and the last file changed. (e) Read back every changed line in extracted/. (f) npm run names -- --check. (g) Write mesen2-results/MS<NN>_apply.md: table result id | file:line | status APPLIED / DISPUTED / SKIPPED / BLOCKED | note; spec path; dry-run summary; gate numbers; items outside scope.
Rules: no ids (OQ, R, IT, CL) and no paths into plans/ in shipped text; present tense; no blanket UNVERIFIED-RUNTIME; hedge only on a specific untraced claim. No git write command; end with "Please commit when you're ready" and a suggested message.
```

---

## Appendix A - Names used in earlier drafts and their live equivalents

Names are looked up in `db-us/names/bankNN.json` (decimal key = original-ROM offset). Verified 2026-10-29. Re-check before use: renames IT-36 to IT-48 are still to come.

| Earlier name | Live name (key) | Source |
|--------------|-----------------|--------|
| `DiagClearReturnFlags` | `CancelVerticalPhase` (188666) | `renames/apply-I021-I040_map.json` |
| `ProbeLeftTiles` / `ProbeRightTiles` | `FindSlopeForEastMove` (176571) / `FindSlopeForWestMove` (176488) | same |
| `DiagPushRight` | `WallSlidePushDown` (188587) | same |
| `DiagAutoAlignNS` | `EastWallPushUp` (186351) | same |
| `DiagRampUpLeft` and the west ramp pair | `WestRampAscend` (187985), `WestRampDescend` (187635) | `names/bank02.json` |
| `StagePlayerSpriteMoveX/Y/XY` | `StagePlayerMoveX/Y/XY` (41089 / 41127 / 41165) | IT04_apply |
| `EnemyHitPlayerHandler` | no label: the pass is inside `RunCombatCollision` (244708), `CombatCollision_EnemyLoop` (244729); player hitstun `ApplyPlayerHitstun` (50071) | `names/bank03.json`, `bank00.json` |
| `SetupHdmaChannel` | `SetupHdmaChannel_Indirect` (254295) / `SetupHdmaChannel_Direct` (254323) | `names/bank03.json` |
| `CrystalBallAutoUse` | `UseItem_CrystalBall` (233459) is the nearest live label (check the rebuild-error question's own text) | `names/bank03.json` |
| `QueueDma` (COP `$02`) | `QueueHdmaDirect` | IT04_apply |
| `ResolveFollowDirection` | `ResolveFacingFromAxisBase` | IT04_apply |
| `FacingData_WillAlt` | `FacingData_WillAbilities` (258431) | IT04_apply |
| `VBlankWait`, `DrawBox`, `PrintNumber` | local labels in `extracted/` (not in the names files): search `extracted/` | rg |
| `DecompressGfxToVram`, `SpcCheckMusicReady` | no live label found in the names files or `extracted/`: search by the routine's behaviour in the question text | rg |

Labels used by the prompts and present today (key): `NmiHandler` 33528, `SystemInit` 32788, `UpdateHUD` 33286, `PaletteStart` 37732, `PaletteStep` 37802, `FadeThenStartMusic` 34633, `AdhocVramDma` 39096, `DmaAdhocVramBlock` 258512, `RadarScreenSetup` 229567, `LookupMapName` 239250, `GetPlayerFacingDirection` 258250, `SpcMusicLoadCmd` 166765, `Bg3TilemapVramDma` 176184, `MusicRenderSync` 172261, `DisplaySceneTitle` 172315, `DecelerateNS` 177940, `ClampSpeeds` 177694, `DispatchEastMove` 186076, `PlayerAttackHitTest` 245085, `ApplyHitDamageToVictim` 245543, `HitStaggerMain` 55415, `SpawnDebrisBurst` 51640, `CameraShakeFrame` 182110, `AttackSystemEntry` 178099, `RunActors_Normal` 248565, `AllocateSpecialActor` 45691, `ComputeFollowStep` 60956.

## Appendix B - Audit facts the experiments compare against

| Item | Fact (static, from the audit) | Source |
|------|-------------------------------|--------|
| Waits | `WaitByte #n` / `WaitWord` / `$08` counters = n+1 ticks | IT-02, report H-5 |
| Route steps | a world-map route step runs n+1 ticks | IT-09 |
| Walk/run window | 13 or 14 states (to be counted with the tick rule) | IT-22 item 4 |
| Actor `$10` `$0200` | player not hittable; readers `combat_collision.asm` about 333, 340, 1207 | RC-01 |
| Actor `$10` `$2000` | hidden from the depth sort / script-driven path; `$0E` `$2000/$3000` is a different word | RC-02 |
| `$0008` | three unrelated words (actor bit 3, `playerFlags` combat lock, logical use-item button) | RC-03 |
| `$0080`, `$0400` | hit marker with signed `iframeCounter`; `$0400` has at least two roles | RC-04, RC-05 |
| `iframeCounter` `$7F0028` | positive = hit-stun (victims freeze), negative = recovery; combat skips victims with a negative counter | RC-07 |
| `displayModeFlags` | bit 0 full BG3 upload, bits 4/5 partial; bit 14 = `hudDisableFlag` bit 6 = HUD off; bit 15 = BG3 upload gate | RC-08, RC-09 |
| `playerFlags` | `$0008` combat lock, `$0200` game over, `$0800` script lock, `$2000` guard stance | RC-10, AGENTS.md |
| Facing | 0 = down, 1 = up, 2 = left, 3 = right | RC-11 |
| `$06F2` | BGM id (stored by `SpcMusicLoadCmd`); name `musicParentActor` is a misnomer | RC-12 |
| `hpToHeal` `$0B22` | recovery counter read by `UpdateHUD`; `$7F0B22` is another word | RC-14 |
| `gfxCacheIdxA/B` `$0648/$064A` | scene-transition speed and type at two sites | RC-15 |
| Buttons | physical B `$8000`, Y `$4000`, Start `$1000`, Select `$2000`; logical `remapB $4008`, `remapA $8080`, `remapY $0040`, `remapX $0004` | RC-18 |
| `$AA` `$0800/$0400` | tested, no setter in `extracted/` | RC-19 |
| Types `$06`/`$09` | "wall-like, undecoded"; east-move push `$09` south, `$06` north | RC-20 |
