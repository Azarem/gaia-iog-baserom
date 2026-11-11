# Mesen2 test harness (server 0.5.0)

What this folder is: a working, tested way to drive the `mesen2-mcp` server 0.5.0 from a script, one finished scenario (B2 single-tile sweep), the phase-0 matrix and the 0.5.0 probe. It exists so that a session can prove "the tools work today" before it spends time on a question, and so that results are reproducible (same inputs, same numbers, on both ROMs).

The plan is [../../mesen2-investigation-plan.md](../../mesen2-investigation-plan.md); the verified tool facts are in its section 1. The server gaps are in [../../mesen2-mcp-enhancement-requests.md](../../mesen2-mcp-enhancement-requests.md) (section 12 for 0.5.0).

## Files

| File | Role |
|------|------|
| `mcp_client.py` | Stdio JSON-RPC client for the server. `Mesen(host=..., args=[...])`, `.call(tool, **args)` (parsed JSON or text; raises `McpError` on `isError`), `.try_call`, `.tools()`, helpers `.mem/.u8/.u16/.poke/.shot`, `.close()` (sends `stop`). Default host: `C:\Work\mesen2-mcp\McpHost\bin\Release\net8.0\MesenMcpHost.dll`. Hardened in phase 4: a reader thread so the timeout of every request really applies, and tolerance of a `Content-Length` header line or several JSON objects glued on one line (the `--mcp-rom` framing bug, T-20). |
| `a_common.py` | Shared Python helpers for the Campaign A scenarios: `open_session()` (server with both flags), `quick_warp`, `actor_table(m)` (live actors from the list head `$56`, in list order; `live_only=False` also returns stale slots), `label_addresses(m, names)` (raises on a missing label), `run_experiment(m, info, name, code, frames, prefix, state=S01R, pre=None)` (load state, checked run, raw JSON with Lua text and screenshot reply), `rom_bank_to_entry_bank` (entry bank byte = HiROM mirror: `$08` reads `$88`). |
| `mcp_client.py` `run_script_checked` | `run_script` that raises `ScriptRunError` on a Lua error row (the server returns `isError:false`, T-24), on a `stopReason` other than `script_done`, or on a run without a result; prints a warning when the 100,000-byte script output cap was hit (T-31, MCP-43). Use it for every scripted run. |
| `scenario_a1_flag_census.py`, `scenario_a3_forced_bits.py` | Campaign A1/A2 census sessions and A3 forced-bit experiments. |
| `scenario_a4_followup.py` | K1-K5: kill, drop, pickup, last-enemy reward, damage-number child, laborer, `$0100` on the player. `--only K1b,K5` runs a subset. One session, 18 runs (about 50 s). |
| `scenario_a4_events.py` | `ds` Dark Space warp, `fw` forced walk, `talk:T0` / `talk:T2` dialogue text. One fresh server session per experiment (hazard 26 of the plan). |
| `view_run.py` | `view_run.py A4_K1b_gem_pickup_control 380 440 both`: prints the stored log / sampled rows of a run in a frame window. |
| `explore_a4.py` | Live actors of a scene with HP, stats pointer and extended flags (confirm what the source says a slot holds; read `extracted/` first). |
| `decode_flag_census.py`, `view_compact.py`, `view_merged.py`, `view_reads.py` | Offline decoders and readers of the A1/A2 census files. |
| `scenario_b2_special_tiles.py` | B2 scenario: paint one collision tile type next to the player, hold right, record the trajectory. `--rom`, `--tag O\|R-plain\|R-tagged`, `--out`, `--repeat`. Builds its own state when missing. |
| `phase0_matrix.py` | H0, H1, H3 and H4 on O and R-plain (about 40 s). Writes `raw/phase0_matrix_<date>.json`, `raw/screenshots/H3_*.png`, `raw/H4_*`. |
| `probe_050.py` | The 0.5.0 feature and defect probe: `--sessions 12345` (default; letters of the `SESSIONS` table), `--tag`, `--out`. Covers JSON shapes and edge cases of the memory tools, argument validation, breakpoints and events, stepping, access summary, Lua errors and sandbox, quick warp, `rewind`, watchdog, startup flags (each starts its own host), concurrency of `get_server_status`, recording and replay, CDL, PPU, `compare_runs`. About 50 s; writes `raw/probe_050_<date><tag>.json`. Its cleanup deletes the files it writes outside the results dir (`C:\Work\escape_probe.*`). |
| `../kit/lib/a_census.lua` | `acen.run{frames, outFile, writes, reads, bot, timeline, input, tick, at, execs, refill, final}`. `input = function(n)` returns a button table (nil falls through to `timeline`, then `bot`); `tick = function(n)` runs every frame after `at`; `execs = {Name = cpuAddress}` counts executions; `control36Writes` in the result is the positive control. Output is written in chunks of 3,000 bytes (the script output cap is 100,000 bytes). |
| `../kit/lib/a_actors.lua` | `aact.*`, include with `includes:["a_census","a_actors"]`: `ent`, `hp`, `iframes`, `setf` / `clrf(slot, off, mask)`, `inList(slot)`, `live()`, `findEntry(lo, hi)`, `tracker(from, emit)` (NEW / CHG lines), `motion()`. Written for the A4 scenarios; they use it. |
| `../kit/lib/gaia_kit.lua` | The only module in the repo's kit folder. Project Lua kit (`requires: mesen_kit, iog_kit`, both found in the server's own `lua/lib`): `gaia.addr`, `gaia.log` (200-line cap), `gaia.coll.*` (paged collision index), `gaia.player()`, `gaia.hold/release`, `gaia.trial{setup,hold,frames,sample,final}`, and the W1 census `gaia.watch{{name, lo, hi, kinds, bits}}` / `gaia.once` / `gaia.censusRows()` (logs each unique `name kind K:PC` once; PC is the address after the accessing instruction; tested: write `$36` reports `80:8381`). |

The vendored copies of `mesen_kit`, `iog_kit` and `recipes/` and `verify_kit.py` were deleted in phase 4: `--mcp-lib-dir` takes several folders now (MCP-21) and the server's modules are searched first.

## Starting the server

Host: `C:\Work\mesen2-mcp\McpHost\bin\Release\net8.0\MesenMcpHost.dll` (0.6.0 since 2026-10-30; the harness and the probes below were written against 0.5.0 and need nothing from 0.6.0 except the boot tools). The `net8.0\win-x64\` folder next to it holds a **stale 0.4.0 build**; never register it. Run with `dotnet <dll> <flags>`.

```text
--mcp-lib-dir=<repo>\plans\extracted-audit\mesen2-results\kit\lib
--mcp-results-dir=<repo>\plans\extracted-audit\mesen2-results\raw
```

Without `--mcp-results-dir` the results go to `%LOCALAPPDATA%\Mesen2Mcp\results`. Without `--mcp-lib-dir` the `gaia_kit` include is not found (a missing folder is ignored without a warning). **Do not use `--mcp-rom`** (T-20) or the state startup flags (T-22): load with `load_rom` / `load_state_file`.

**State of Cursor's `mcp.json` on 2026-10-30:** `mesen2-mcp-dev` points at the 0.5.0 DLL with both flags. `mesen2-mcp` and `mesen2-mcp-rebuilt` still point at the stale win-x64 DLL (and the latter uses `--mcp-rom`): fix them or leave them unused. The Cursor namespace `user-mesen2-mcp-dev` is a 0.4.0 process until MCP is reloaded (check for `get_server_status` in the tool list). Use the native tools for one-off checks and this client for anything that repeats or needs a hard timeout.

## Boot-time experiments (server 0.6.0, T-42)

`load_rom` resumes emulation at once, so after `load_rom` + `pause` the game is at about frame 97 and the boot code is gone. From 0.6.0 there are three ways to start at the reset vector; the client passes any argument through, no wrapper is needed:

```python
c.call("load_rom", path=ROM, paused=True)                 # power-cycled, stopped at frame 0 (reply "boot": frameAfter 0, cpu.pc24 32768 on O)
r = c.run_script_checked(code, frames=300, includes=["gaia_kit"])   # script sees the first instruction, `frames` counts from the boot

r = c.run_script_checked(code, frames=300, includes=["gaia_kit"], fromReset="power")   # cold boot in one call (RAM re-initialized, frame counter 0)
r = c.run_script_checked(code, frames=300, fromReset="soft")                           # reset button: WRAM kept, frame counter continues
c.call("reset", mode="soft")                              # leaves the console paused at the reset vector; load a script afterwards
```

A `power` cycle builds a new debugger: scripts loaded earlier and Lua-backed `log`/`count` breakpoints are dropped (`scriptsDropped`); native breakpoints and labels are re-applied. Register `$4200` callbacks on both bank aliases (`kit/lib/c1_adhoc.lua` registers all 128). The reply of a `fromReset` run has `reset` (the CPU state at the vector). Do not read `scene` (`$0644`) before the WRAM clear: it is garbage at frame 0. Reference run (O, 300 frames, `c1.run{...}`): `ResetVector` 1, `SystemInit` 1, `$4200` writes `82:9F47=00` (frame 0), `82:81AC=01` (frame 3), `82:819F=81` (frame 26).

## Running the B2 scenario

```text
cd plans/extracted-audit/mesen2-results/harness
python scenario_b2_special_tiles.py --tag O       --rom "..\..\..\..\rebuilt\Illusion of Gaia.smc"
python scenario_b2_special_tiles.py --tag R-plain --rom "..\..\..\..\rebuilt\Illusion of Gaia - Rebuilt.smc"
```

Each run: loads the ROM, creates `rebuilt/states/<orig|R-plain>_S01r_south-cape-ready.mss` (plus its `.json` sidecar) if missing, runs every case twice, fails if the two runs differ, and writes `raw/B2_special_tiles_<tag>_<yyyymmdd>.json`. Run time about 5 s per ROM. The 0.5.0 re-run is bit-identical to the 0.4.0 data on both ROMs. The tag `R-plain` is only a label: whether the ROM file is plain or tagged is read from `artifacts/crc.json` and the build log (plan 2.1).

## Running the phase 0 matrix and the 0.5.0 probe

```text
cd plans/extracted-audit/mesen2-results/harness
timeout 120 python phase0_matrix.py
timeout 300 python probe_050.py
timeout 120 python probe_050.py --sessions 4 --tag _rewind
```

`phase0_matrix.py` loads O and R-plain, checks identity, boot scenes, state validity (`rom_mismatch`, `no_sidecar`), quick warps to `$08 $0A $15 $24 $E8 $FD $FE` with screenshots, the recipe warp on both ROMs, the native and Lua control counts, and the extended tool rows (trace, dump, events, conditions, SPC callbacks, `step_scanline` with `timeoutMs`, `rewind` last). Run both under a process timeout: the hard watchdog of the server has not been exercised. Results: [../H0-H4_phase0_20261029.md](../H0-H4_phase0_20261029.md) and [../Probe_050_20261030.md](../Probe_050_20261030.md).

## Running the Campaign A follow-up (A4)

```text
cd plans/extracted-audit/mesen2-results/harness
timeout 300 python scenario_a4_followup.py                      # all 18 runs, about 50 s
timeout 300 python scenario_a4_followup.py --only K1b,K5
timeout 300 python scenario_a4_events.py ds fw talk:T0 talk:T2  # one fresh session each
python view_run.py A4_K1_kill_eye_stalker 380 400 both
```

The runs are deterministic: a repeat gives the same logs, exec counts and samples (checked on all 22 A4 runs after the helper refactor). Results go to `raw/A4_<name>_<date>.json` with the Lua text of the run in the `lua` field.

Writing a new scenario: copy the `lua_kill` pattern of `scenario_a4_followup.py` (Lua text with `aact` helpers, `acen.run{... input = ..., tick = ..., final = ...}`), call `run_experiment`, and keep one forced change per run next to a control.

## Rules that this harness enforces

- A state is bound to its ROM by the sidecar SHA-1; `load_state_file` raises `rom_mismatch` for the wrong ROM and `no_sidecar` for a state without one (`requireRomMatch:false` overrides it).
- The quick warp is `sceneNext ($0642) = <scene>` (or `run_recipe warp {quick:true}`) and works from the boot logo, from the title screen `$FC` and from an in-game scene (verified `$01` to `$15`, `$08`, `$24`, `$E8`, `$FD`, `$FE`). The input mask after arrival must be read: `$08` and `$0A` without flag 63 arrive with `0xCFF0`.
- Every result carries a control (a case that must change the outcome) and a repeat (determinism).
- No edit of `extracted/`, `db-us/`, `src/`, `artifacts/`; the only writes are under `mesen2-results/` and `rebuilt/states/`.
- Delete `raw/slots/` and `raw/sub/` after a session that used `slot` or the writeFile probe.
- A script run is not trusted until `run_script_checked` returned (Lua errors and caps are visible only in the log rows).
- Actor liveness is the list walk from `$56`, never "entry word != 0" (freed slots keep their contents); entry bank bytes are HiROM mirrors; extended fields are indexed by the actor id (`kit.r16(0x10026 + slot)` = HP).
- Read `extracted/` before running anything; an exploration script is for confirming what the source already says.
- Fixes to shipped notes, comments and names go into a draft spec (`npm run merge` / `npm run names`, dry-run only), never into the baserom from a harness run; a harness, documentation or game-fact problem is not a tool issue.
