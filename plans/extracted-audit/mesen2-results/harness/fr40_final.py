#!/usr/bin/env python3
"""Assemble FR40_20261106.md from the hand-written sections below and the tables written by fr40_md.py (raw/FR40_md_*.md)."""
import collections
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import fr40  # noqa: E402

RES = os.path.abspath(os.path.join(HERE, ".."))
RAW = fr40.RAW


def rd(name):
    return open(os.path.join(RAW, name), encoding="utf-8").read()


T = json.load(open(os.path.join(RAW, "FR40_scene_table.json"), encoding="utf-8"))
VERD = json.load(open(os.path.join(RES, "specs", "FR40_flag_verdicts.json"), encoding="utf-8"))
SPEC = json.load(open(os.path.join(RES, "specs", "FR40_scene-flags.json"), encoding="utf-8"))

cls = collections.Counter(v["class"] for v in T.values())
sv = collections.Counter(v["sceneVerdict"] for v in T.values())
fv = collections.Counter(v["verdict"] for v in VERD)


def ids(pred):
    return ", ".join(f"${int(k):02X}" for k, v in sorted(T.items(), key=lambda kv: int(kv[0])) if pred(v))


up = [v for v in VERD if v["verdict"] == "VERIFIED-RUNTIME"]
inc = [v for v in VERD if v["verdict"] == "INCONCLUSIVE"]
con = [v for v in VERD if v["verdict"] == "CONTRADICTED"]
grade_rows = "\n".join(
    f"| {v['flag']} (${v['flag']:X}) | {', '.join('$%02X' % s for s in v['scope']['scenes'])} | {v['expectGrade']} | VERIFIED-RUNTIME | {v['queueId']} |" for v in up)
inc_rows = "\n".join(f"| {v['flag']} (${v['flag']:X}) | {', '.join('$%02X' % s for s in v['scope']['scenes'])} | forced: {v['effects']['set'][:200]} control: {v['effects']['clear'][:200]} |" for v in inc)

selfadv = ids(lambda v: v["class"] == "cutscene" and v["gnone"]["left"])
permanent = "$E5, $F0, $F7, $FC, $FD, $FE"

md = f"""# FR40 Scene entry sweep (228 scenes, quick warp, natural entries, draft flags)
ROM: O
SHA-1: 38de0c84dd2bc3bdfc0a3d7ab0220c79b70887c3   file size: 2097152 (`C:\\Work\\gaia-iog-baserom\\rebuilt\\Illusion of Gaia.smc`, CRC-32 1c3848c0)   crc.json: checksum 222990002 / crc -575332819 / totalSize 3062205, mode "plain" (this describes the R-plain build, not O: it is not used here)   mode source: SHA-1 and size equal the O rows of `states-index.md`; `fileSha1` of the loaded ROM is asserted at the start of every session (`fr40.open_o`).
Server: Mesen2 MCP 0.6.0 (the Python client `harness/mcp_client.py` spawns its own server process with `--mcp-lib-dir=kit\\lib` and `--mcp-results-dir=raw`); every trial is one atomic `run_script` with `includes: ["fr40_kit"]`.
State: `rebuilt/states/orig_S01r_south-cape-ready.mss` (valid: H1 test passed yes at the start and at the end of the step: `cpu.k` 130, `sp` 505, scene `$01`, 119 `$36` writes in 120 frames; ROM SHA-1 equal to the index row yes). The state is loaded fresh before every trial; no state was saved. Story state of S01r: flags 2 and 255 set (WRAM `$0A00` = `04`, `$0A1F` = `80`), nothing else.
Line tracking: the `; {{n}}` tags in `extracted/` are ROM file offsets (decimal) on O.

## Static prelude
- Scene load: `ClearSceneState` runs `STX $eventFlags` at ROM offset 253291 (`system/engine/scene_lifecycle.asm:799`); the exec callback on it marks a scene load. Flags `$0000-$000F` are cleared by it, so every flag written before a warp is outside that range (the lowest flag written is 16).
- Warp inputs: `warpDestX/Y` (`$064C/$064E`), `warpFacing` (`$0650`, bit 7 = save warp), `warpScrollParams` (`$0652`), then `sceneNext` (`$0642`) last. The 543 scene-warp rows of `extracted/tables/scene_warps.asm` (12 bytes each: destination scene, x, y, facing, scroll) give the destinations; `raw/FR40_warp_dest.json` holds them per destination scene (distinct x, y, facing, scroll tuples = the "natural entries", variants `n0`, `n1`, ...). The actor position is x+8, y+16.
- Lock indicators: `joypadMaskStd` `$065A` (B `$8000`, Y `$4000`, Select `$2000`, Start `$1000`, Up `$0800`, Down `$0400`, Left `$0200`, Right `$0100`, A `$0080`, X `$0040`, L `$0020`, R `$0010`; direction bits all set = locked; `$CFF0`, `$EFF0`, `$FFF0` lock the directions, `$7000` and `$F0F0` do not), `playerFlags` `$09AE` (`$0800` script lock, `$0200` game over), `displayModeFlags` `$09EC` (`$2000` dialogue mode, `$4000` title/logo/credits scenes). A message box keeps `$065A` at 0 while it holds the player.
- Guard script of scene `$0A`: `extracted/edward_castle/edward_castle/ec0A_left_guard.asm:19` `TSB $joypadMaskStd` with `#$CFFC` ({{311290}}) when flag `$3F` is clear, `:31` `PrintDialogString` ({{311318}}), `:32` `SetFlagByte #3F` ({{311322}}), `:34` `TRB $joypadMaskStd` ({{311328}}).
- Draft: `plans/flags/results/specs/FL32_scene-flags.json` (228 entries: 148 free, 76 cutscene, 1 locked-until-flag, 3 unknown; 44 single flags and one three-flag set). Shipped: `db-us/scene-flags.json` holds scene `$0A` only (flag 63, note at line 4).

## Script
Kit `kit/lib/fr40_kit.lua` (`-- requires: fr20_kit`, verbatim in `FR40_20261106_lua.md`): `fr40.arrive{{scene, set, watch, input, dest, stopFree, tag}}` (flags written first, `sceneNext` last; waits for the load mark and `sceneCurrent == scene`; dismisses the banner flag `$00B4` with physical A pulses; then watches `watch` frames; free = mask 0, playerFlags `$0800` clear, no dialogue mode, still in the scene; `releaseN` = first watch frame of 20 free frames) and `fr40.move{{}}` (20 frames of each of down, up, left, right with 8 frames gap). Nothing in it writes the low direct page `$00-$94`; flag writes use `emu.write`. Harness (Python, `harness/`): `fr40.py` (`h1`, `a`, `b`, `c`, `t`), `fr40_n.py` (natural entries), `fr40_g.py` (long watch, A pulses, draft flags and subsets at the first blocked natural entry), `fr40_g2.py` (600 frames, no early stop), `fr40_g3.py` (7000 frames, A pulses), analysis `fr40_an.py`, `fr40_cls.py`, `fr40_report.py`, `fr40_md.py`, `fr40_final.py` (these write only the result files). Every trial row (call line, arrival and end state, timeline, direction test, flag diffs, screenshot path) is in `raw/FR40_rows.jsonl` (1194 rows), screenshots `raw/screenshots/FR40_s<ID>_<variant>_*.png` (367).
Call forms (full text in `FR40_20261106_lua.md`):
```lua
fr40.arrive{{scene=10,set={{}},watch=60,input="none",tag="s0A_a"}}                                   -- step (a), quick warp
fr40.arrive{{scene=8,set={{}},watch=1500,input="mashA",tag="s08_g_mash",stopFree=40,dest={{440,128,0,4608}}}} -- A pulses, full warp
fr40.arrive{{scene=10,set={{63}},watch=60,input="none",tag="s0A_g_draft",dest={{96,880,3,17456}}}}        -- draft flags
fr40.move{{}}
```
Buttons: physical A pulsed 2 frames of every 12 (the game maps physical A to the interact bit `$0080`); the banner is dismissed with 3-frame A pulses; the direction test holds the D-pad (down `$0400`, up `$0800`, left `$0200`, right `$0100`). Frames are emulated frames; the NMI counter agrees (`d36` = 1501 `$36` writes in a 1500-frame watch).

## Positive control
Standing control (scene `$0A` quick warp without and with flag `$3F` = 63) before and after each of the 8 batches of step (a) and at the end of the step (`raw/FR40_h1_end.txt`, row variants `ctl_without63` / `ctl_with63`, 17 runs each, all PASS): without the flag `$065A` = `$CFF0` at arrival and 60 frames later and the player does not move; with the flag `$065A` = 0 and the player moves in three directions. Every flag trial has its own control: the same arrival without flags (`g_none`, `g_mash`) shows the lock that the forced run (`g_draft`, `g_sub*`) removes, or the reverse.

## Coverage
- All 228 ids of `artifacts/scenes.json` (`db-us/groups.json`): step (a) quick warp, 60 frames after the banner, direction test, screenshot (variant `a`, 228 trials). No scene fails to load, no script error, no crash (`cpu.k` 130 / `sp` sane at the end of every trial; `error` empty in all 1194 rows).
- Natural entries: every distinct destination of the scene-warp rows that lead into a scene (variants `n0...`, 505 trials, 60 frames, direction test; a destination (0,0) and a destination whose arrival ends in game over are not used as reference entries). The 30 scenes with no incoming scene-warp row (cutscene and ending scenes started by scripts, `$2A`, `$2F`, `$DD`, `$E8`, `$FF`, ...) use the quick warp only.
- Wall landings: 33 scenes retried with the warp-table destinations (variants `spawn*`, 39 trials).
- Long watch (1500 frames, no input; then A pulses; some with 7000 frames) at the first blocked entry of 86 scenes: variants `long_*`, `g_*`, `g2_*`, `g3_*`; draft flags and every proper subset of the draft flags (`draft`, `g_draft`, `g_sub*`: scene `$06` only, 6 trials).
- Story state: the S01r flags only (flags 2 and 255); the arrival tests cover first visits. A claim "free" holds for these entries and for the first 60 frames after the banner; locks that start later are reported only where a long watch saw them (`$0E`, `$13`, `$5B`, `$BB`, `$BD`, `$E3`, and the in-scene locks listed in the notes).
- Trials: 1194 rows, about 66 minutes of server time. No game-state save.

## Observations (raw, 40 lines)
```
{rd('FR40_md_obs.md')}
```

## Summary
Classes (228 scenes): free {cls['free']} (8 of them INCONCLUSIVE for the draft flag claim, as are 4 of the needs-spawn-position scenes), cutscene {cls['cutscene']}, needs-spawn-position {cls['needs-spawn-position']}, locked-until-flag 0, unreachable 0.
- **cutscene ({cls['cutscene']})**: the arrival locks the joypad or opens a message box. 41 scenes hold the player in a message box that closes only after A is pressed; 10 release by themselves (e.g. `$29` after 171 frames, `$55` after 82, `$BB` and `$BD` after 74, `$E8` after 95, `$F2`-`$F6` after about 680); {len([1 for v in T.values() if v['class']=='cutscene' and v['gnone']['left']])} load another scene by themselves ({selfadv}); 7 load another scene after A pulses; `$E5` and `$F0` do not end within 7000 frames and `$F7`, `$FC`, `$FD`, `$FE` not within 1500 (credits, ending, world map, menu); `$0E`, `$13` (delayed locks) and `$FF` (menu scene, the player does not move) are the remaining three.
- **locked-until-flag (0)**: no scene keeps the player locked until a flag is set. Scene `$0A`, the only locked-until-flag entry of the draft and of `db-us/scene-flags.json`, ends its lock: the joypad mask is `$CFF0` for 239 frames, then a message box (`displayModeFlags` `$2001`, mask 0) waits for A; with A pulses the player is free at frame 278 and the script sets flag 63 itself.
- **needs-spawn-position ({cls['needs-spawn-position']})**: the quick warp position (88,160) lands in a wall (31 scenes) or ends in game over after 45 and 54 frames (`$A6`, `$B2`); the working x, y, facing and scroll are in the list below.
- Minimal flag sets (draft flags, forced run, control run, each in the same state): 31 flag-scope rows VERIFIED-RUNTIME, 2 CONTRADICTED (`$29` flag 1280, `$55` flag 1281: the lock stays), 12 INCONCLUSIVE (the control arrival is free from the S01r story state, so the flag cannot show a difference; scene `$06` flags 29 and 37 do not free the Hamlet lock).
- Scene verdict rows: VERIFIED-RUNTIME {sv['VERIFIED-RUNTIME'] - 1}, CONTRADICTED 1 (shipped note of scene `$0A`), INCONCLUSIVE {sv['INCONCLUSIVE']}. Flag verdict rows: VERIFIED-RUNTIME {fv['VERIFIED-RUNTIME']}, CONTRADICTED {fv['CONTRADICTED']}, INCONCLUSIVE {fv['INCONCLUSIVE']}.

## Scene table (one row per scene; "No input" and "A pulses" report the first long run at the entry used)
{rd('FR40_md_scenes.md')}

## Verdicts
{rd('FR40_md_verdicts.md')}

## Lists
{rd('FR40_md_lists.md')}

Draft flags tried on scenes whose arrival the draft calls a cutscene but that is free from the S01r story state (INCONCLUSIVE; "tried" = the draft flag set, arrival 60 frames plus direction test, compared with the unforced arrival, which is free): {', '.join(f"${s:02X}" for s in [0x15, 0x5D, 0x61, 0x67, 0x6A, 0x79, 0x7D, 0x8A, 0xAD, 0xBF])}; `$E0` with flag 212 (`$D4`) set (actor list 21 to 23, mask 0, free); `$06` with flag 22 set (Hamlet lock appears, flag 61 frees it, flags 29 and 37 do not). Scene `$79` with flag 145 set opens a message box at arrival (mask `$CFF0`, `displayModeFlags` `$2001`) while the unforced arrival is free. The preconditions of these draft locks are story states that need flag presets (FR50).

## Registry grade changes (flag, scope, old grade, new grade, queue item)
| Flag | Scenes | Old grade | New grade | Queue |
|---|---|---|---|---|
{grade_rows}

CONTRADICTED flag scopes: {', '.join(f"flag {v['flag']} scene ${v['scope']['scenes'][0]:02X} ({v['queueId']})" for v in con)} (grade stays {', '.join(sorted(set(v['expectGrade'] for v in con)))}; the arrival lock of the boss intro does not depend on the boss reward flag as the draft says).
INCONCLUSIVE flag scopes (grade unchanged):
| Flag | Scenes | What was tried / observed |
|---|---|---|
{inc_rows}

## Shipped text now shown wrong
- `db-us/scene-flags.json:4` (scene `$0A`): "Without it the guard actor locks the joypad (joypadMaskStd $065A stays nonzero)." Measured: `$065A` = `$CFF0` for 239 frames, then 0 while a message box (`displayModeFlags` bit `$2000`) holds the player until A is pressed; with A pulses the player is free at frame 278 and flag 63 is set by the script. The generated copy is `docs/flags/README.md:322`. The replacement is in `specs/FR40_scene-flags.json` entry 10 with `expectOld` "{SPEC['10']['expectOld']}".
- The draft (not shipped) entries `$29` (flag 1280) and `$55` (flag 1281) of `specs/FL32_scene-flags.json` name flags that do not free the arrival; the draft entries for `$0E`, `$13`, `$5B`, `$BB`, `$BD`, `$E3` ("free") and for the ten story-conditional scenes are listed in the draft table above.

## Tool issues
None: no server or Lua-API defect was found (no row added to `tool-issues.md`). Harness-side points (not logged): a held direction closes an open message box (the direction test starts after the watch, so a box that waits for A can be closed by the test itself; the long runs use no direction input); `releaseN` is the first watch frame of a free run, so a scene with a delayed lock reports `releaseN` 1.

## Notes spec
- `specs/FR40_scene-flags.json`: {len(SPEC)} entries (flags, entry, note, source `Mesen2 FR40`, grade VERIFIED-RUNTIME, `names` where a draft flag is verified, `expectOld` for scene 10). Not in the spec: the 12 INCONCLUSIVE scenes (`$06`, `$15`, `$5D`, `$61`, `$67`, `$6A`, `$79`, `$7D`, `$8A`, `$AD`, `$BF`, `$E0`). `needs-spawn-position` scenes are written as entry `free` with the full-warp x, y, facing and scroll in the note (the format of plan 3.2 has no spawn field). It is applied with `npm run flags -- scene-flags <spec>` in the apply pass; that command is outside the allowed list of this step, so it was not run.
- `specs/FR40_flag_verdicts.json`: {len(VERD)} rows ({fv['VERIFIED-RUNTIME']} VERIFIED-RUNTIME, {fv['CONTRADICTED']} CONTRADICTED, {fv['INCONCLUSIVE']} INCONCLUSIVE).
- No merge spec and no names spec: no shipped comment in `extracted/` or label is wrong (the guard script `ec0A_left_guard.asm` carries no comment about the lock). `npm run merge` and `npm run names` were not needed, so no dry-run result exists.

## New questions
1. Which flag or state skips the boss intro locks of scenes `$29` (Castoth) and `$55` (Viper), if any? The lock ends by itself at frame 171 and 82; flags 1280 and 1281 do not remove it.
2. Why does the entry from the scene-warp destination x=88 y=64 of scene `$0E` repeat 17-frame `$0F00` locks, end in game over at frame 197 and load scene `$20` (`$13`: a message box at frame 59 from the destination x=120 y=80)? Are these the forced-walk or trap entries?
3. Which scripts lock the arrival in `$5B` (entry x=48 y=912), `$BB` (four entries), `$BD`, `$E3` (entry x=120 y=400)? The draft finds no entry lock.
4. What kills the player at arrival in `$6E` (x=912 y=640) and `$70` (x=624 and 672, y=368), where `playerFlags` `$0200` is set at frame 0, in `$D2` (x=192 y=912, frame 46) and in the quick warps of `$A6` (frame 45) and `$B2` (frame 54)?
5. What does the scene-warp row from `warp_def_29` to scene `$2C` with destination (0,0) mean? The arrival there lands in a solid cell and the joypad is locked.
6. Sky Garden scenes `$4D-$54` hold `playerFlags` `$0800` at arrival while the player walks in three directions. Is bit `$0800` a lock there?
7. Which story flags make the draft arrival locks of `$15`, `$5D`, `$61`, `$67`, `$6A`, `$79` (flag 145 opens a message box), `$7D`, `$8A`, `$AD`, `$BF`, `$E0` appear (presets for FR50)?
8. The plan 3.2 entry format has no field for the full-warp spawn position of the 33 needs-spawn-position scenes (and for entries that differ per source scene): should the exporter learn `spawn` and per-entry notes?

## Recommended next step
Apply pass for `specs/FR40_scene-flags.json` and `specs/FR40_flag_verdicts.json` (`npm run flags` dry-run first), then FR50 (checkpoint presets) with the story flags of the 12 INCONCLUSIVE scenes as its first targets.
"""
open(os.path.join(RES, "FR40_20261106.md"), "w", encoding="utf-8").write(md)
print(len(md))
