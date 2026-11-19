# Mesen2 R series: unreferenced labels, warp reach and ROM pointer scans (R1 to R3)

Runtime coverage and static ROM scans for dead code, unreachable scene ids, save and forced-walk warps, and unreferenced actors, tables and strings in the US retail ROM. Compiled 2026-11-12 from `plans/extracted-audit/mesen2-results/R1_20261109.md`, `R2_20261109.md`, `R3_20261110.md`, closure rows in `closures.md` (including `CO03_close_R1_F2.md`), and the apply log `MS04_apply.md`.

ROM: O (vanilla US, SHA-1 `38de0c84dd2bc3bdfc0a3d7ab0220c79b70887c3`, `rebuilt/Illusion of Gaia.smc`, 2,097,152 bytes) for R1 and for all R2 runs except the no-record and `$F9` comparisons. R2 also loads R-plain (`rebuilt/Illusion of Gaia - Rebuilt.smc`, SHA-1 `0cfcb55863052af92041107ecc28226d9f89f8aa`, 3,080,192 bytes). R3 reads the O file only (no Mesen2 session; full 2 MiB byte search). Server: Mesen2 MCP 0.6.0 with `--mcp-lib-dir` and `--mcp-results-dir` under `mesen2-results` for R1 and R2. The MS04 merge gate on the tagged rebuild is SHA-1 `90a04067dd5b5284bd9e152ad222df0e65d08979` (checksum 222965960; **no ROM byte changed** by the note pass).

Sections: 1 Result in one page, 2 What was run, 3 Findings, 4 Shipped notes corrected, 5 Rules for patch authors, 6 Where the findings live in the docs, 7 Tools, states and files, 8 Tool and method lessons, 9 Open questions, 10 Apply log.

---

## 1. Result in one page

| Topic | Question | Verdict |
|-------|----------|---------|
| UNREF execution census | Do the named unreferenced labels, strings and thinker lists ever execute or get intentional reads under broad play coverage? | **83 of 115 R1 range rows** are VERIFIED-RUNTIME negatives (controls fired, static pointer prelude found no reference). **32 rows INCONCLUSIVE** (index tables with possible RAM operands, compressed assets, or superset ranges). |
| North movement dead probe | Does `NorthProbeRedirect` change state the north chain uses? | **No.** 153 entries execute; in **5 of 5** probed entries (scene `$01`) the `$00` word, SP, D, DBR and M/X match at entry and at `loc_02D208` (ROM 184840); only X (+`$10`), A and carry differ and `MapCellLeft` reloads from `$00`. VERIFIED-RUNTIME. |
| DrawMetatileStream COP path | Are `DrawMetatileStream` and its delay variant reachable? | **Never executed** (CDL none); no script site sets `extendedFlags` bit 2. VERIFIED-RUNTIME + VERIFIED-STATIC. |
| Idle 5-gem actor | Is `idle_sprite_display` used? | **Never executed or read** in coverage; R3 finds **no ROM pointer** to the block. Touch pickup **INCONCLUSIVE** (never spawned). VERIFIED-RUNTIME / VERIFIED-STATIC (+ INCONCLUSIVE touch). |
| Camera drift table tail | Are words 8–15 of `camera_drift_offsets` read? | **Never** (read 0 in R1; index masked to 3 bits at 53254 and 53300). VERIFIED-RUNTIME + VERIFIED-STATIC. |
| Diary `_noref` engine | Do the nine `_noref` diary routines run? | **Never executed or read** in diary sessions; R3 finds **no caller pointer**. VERIFIED-RUNTIME + VERIFIED-STATIC. |
| Title palette step | Does `TitlePaletteStep_noref` run? | **Never executed** on title (9,000 cold-boot frames); R3: **no spawn operand or pointer**, prior routine ends in RTL. VERIFIED-RUNTIME + VERIFIED-STATIC. |
| Sprite index “unused” rows | Are transform poses `$04`/`$0C`/`$11` and npc props `$03`/`$09` ever selected? | **Not in coverage** (CDL none on those pointer rows). **INCONCLUSIVE** — zero does not prove absence when index can come from RAM. |
| Dark Space compressed sprites | What uses `spm_darkspace_sprites` animations `#04`–`#09`? | **INCONCLUSIVE** — Quintet-LZ file; 17,532 ROM reads are decompression, not index selection. |
| Move chains `$4C`–`$4E` | Are those `move_chain_table` entries used? | **Never selected** in coverage; **`[$21]`** (2 reads) and **`[$3D]`** (92 reads) **were**. VERIFIED-RUNTIME + INCONCLUSIVE. |
| Scene id sweep | What happens for every `sceneNext` id `$01`–`$FF`? | **231 of 255** complete load on O; **24** hang (NMI stuck at 17); **`$F9`** polls SPC port 0 forever on O, loads on R. VERIFIED-RUNTIME. |
| Save warps | Which warps set save-point data and game-over respawn? | **23 save warps** in **14 scenes**, all fired; `ExecuteWarp` writes `$0AF4`/`$0AF6` for all warps, `$0AF0`/`$0AF2` only for save warps. Game over: **0 gems → scene `$1B`**, **100 gems → `$22`**. VERIFIED-RUNTIME. |
| Forced-walk pan lists | Does runtime pan match `forced_walk_pan_table`? | **`$06E0` matches static index on 88 of 88** tried entries; on **20 resting-camera** entries travel equals list total; pan stops at list end or camera bound. VERIFIED-RUNTIME. |
| Extended warp step codes | What do `warp_def_03` codes `$04`/`$05` do? | Same step words and pan as `$02`/`$00` but **Y offset +328 / −304 px** vs +264 / −240. VERIFIED-RUNTIME + VERIFIED-STATIC (`walk_step_table` rows match `$02`/`$00`). |
| No-record scene ids | Can the 25 ids without `scene_meta` load? | **No** on O (23 hang in scan loop, `$09`/`$80` run stray bytes); **R crashes 25 of 25**. VERIFIED-RUNTIME + VERIFIED-STATIC. |
| Shared event pointer ids | Do the 16 ids at `scene_event_0C8200` show TEST MAP? | **No** reachable path; written on O they hang or stray-code (`$F9` stalls at `82:8BAC`). VERIFIED-RUNTIME + VERIFIED-STATIC. |
| Flag `$FF` readers | Who tests thinker flag `$FF` outside thinkers? | **Nobody** — 36 static sites are all `thinker-def`; **5,071** runtime tests in 231 scenes are thinker slots only. VERIFIED-STATIC + VERIFIED-RUNTIME. |
| Overworld exit flag `$01` | Is flag `$01` still set when scene `$15` starts? | **Never** — `ClearSceneState` clears flags `$00`–`$0F`; **255 of 255** sweep arrivals read 0 at `$01`. CONTRADICTED (standing “exit disabled” wording). |
| LoadBgTiles mode 3 | Does any scene use whole-page mode 3 or bit-7-only layer load? | **0 executions** in 231 scenes; static operands 0×255 / 62× mode 1 / 2× mode 2. VERIFIED-RUNTIME + VERIFIED-STATIC. |
| Display presets | Which preset runs per scene? | **229 of 229** loaded scenes match static first-command byte; **44 of 47** presets used (`$09`, `$27`, `$29` unused); mode 7 only in **`$59` `$C0` `$FE` `$8C` `$8D`**. VERIFIED-RUNTIME. |
| Parallax thinker types | Which `parallax_scroll_table` types spawn? | Exactly **20 shipped types** in **80** scenes that spawn the thinker; types **`$09` `$0C` `$0D` `$0F`–`$1A`** never spawn; **`$04` `$22`** have no `SpawnThinkerParam` site. VERIFIED-RUNTIME + VERIFIED-STATIC. |
| World map staging ids | Are menu choice ids `$00`, `$1C`–`$26` or routes `$0E`–`$10`, `$23`–`$25` staged? | **Never** — operands are literals `$01`–`$1B` and listed routes only; no nonzero `$0D58`/`$0D5A` in 255 scene loads. VERIFIED-STATIC. |
| ROM pointer scan (R3) | Do unreferenced actors lack any 16/24-bit ROM pointer? | **`idle_sprite_display`**, **`camera_delta_oscillator`**, **`unused_particle_rain_spawner`**, **`dialog_string_scanner`**, **`debug_man`**, nine diary `_noref` pieces, six strings **`01E82B`–`01E85C`**, three thinker lists — **no pointer** outside assets or self-references. VERIFIED-STATIC. |
| Shadow Status strings | Are Shadow placeholder console strings dead? | **Four placeholders read** in form-2 Status probe (SIMULATED: `$0AD4` = 2, `$0AA2` = `$7777`); **`ability_description_table[0C]`** never read; flags **`$0518`–`$051A`** reachability INCONCLUSIVE. |

Counts: **R1** 83 VERIFIED-RUNTIME, 32 INCONCLUSIVE (115 verdict rows); **R2** 17 VERIFIED-RUNTIME, 7 VERIFIED-STATIC, 1 CONTRADICTED, 3 INCONCLUSIVE (28 rows, 12 ids); **R3** 12 VERIFIED-STATIC, 2 INCONCLUSIVE, 0 runtime. Shipped notes: **1 CONTRADICTED** standing sentence (`overworld_exit` flag `$01`), several “not traced” lines replaced in MS04; **0 ROM bytes** changed.

What changed in what we believe:

1. **Dead code is provable only with controls plus a pointer scan.** R1’s 1,099 named ranges and R3’s full-ROM search close most UNREF items; animation-index zeros alone never prove absence.
2. **`NorthProbeRedirect` runs but the `MapCellDown` / `ReadCollisionNibble` pair is dead** in the measured entries — north-wall logic does not depend on it.
3. **Save-point warps are exactly the 23 byte-9 bit-7 entries**; game-over respawn uses `$0AF0` on a real death and the last warp pointer on a 100-gem revive.
4. **Twenty-five `sceneNext` values and sixteen shared-event ids are not real scenes** — they hang, execute stray bytes, or (on R) crash; only documented ids belong in tools or patches.
5. **Scene loading never uses `SceneCmd_LoadBgTiles` mode 3 or the orphan layer path** — those handlers exist only as unreachable interpreter branches.
6. **The second half of `camera_drift_offsets` and `TitlePaletteStep_noref` are inert** — the table index mask and the lack of any spawn pointer respectively.

---

## 2. What was run

| Step | Ids-or-topic | Method | Volume |
|------|----------------|--------|--------|
| R1 | UNREF group, move/sprite tables, palette bundles, forced-walk east/west, thinkers | CDL union over **133 legs** (~**417,544** frames, **393,974** NMI entries): cold boot, recorded early game, **100** W1-style sessions, **31** scene-id sweeps (600/150 frames per id × 3 forms), **20** probes (`thinker_full` ×228 scenes, north data-flow, Status tab per form, drops, sparkle reader); static `r1_static.py` pointer prelude on O; `get_access_summary` on **1,099** ranges | 1,099 range rows in report |
| R2 | Scene sweep, warps, forced walk, game over, no-record ids | **255** `sceneNext` writes from S01r (700 NMI cap, post 180); **255** flag-poke loads; **32** warp fires; **88** forced-walk entries; **2** game-over paths; **25** no-record ids × O and R; static `r2_static.py` decode of meta, warps, presets, flags | 231 scenes completed load on O |
| R3 | Unreferenced labels (pointer proof) | Full **2,097,152**-byte search per label (24-bit LE, 16-bit same-bank, `rg` on `extracted/` / `baserom/`); output `raw/R3_scan_20261110.txt` | **No emulator** |

R1 legs used existing `rebuilt/states/orig_*` saves (South Cape ready, progress **P00**–**P18**, combat, diary, inventory, credits). R2 fixed states: `orig_S01r_south-cape-ready.mss` (O) and `R-0cfcb558_S01r_south-cape-ready.mss` (R). Warp probes on **O** used **physical A** pulses while a banner or dialog blocked the main loop.

---

## 3. Findings

### 3.1 R1 execution coverage and UNREF census

- **Union CDL:** code **85,252** bytes, data **1,652,119** bytes (**4.1 %** code) of PRG; “data” includes block-move reads, not table-proof alone.
- **Verdict rule:** a zero exec/read is VERIFIED-RUNTIME only with (a) control row in the same family, (b) coverage listed, (c) static prelude (`R1_static.txt`, same patterns as R3) showing no pointer; index-table zeros stay INCONCLUSIVE if RAM can supply the index.
- **Positive controls:** `NmiHandler` every leg; `camera_scroll_controller` **177** legs; `GiveItemToPlayer` **8** entries; `DiaryMainMenuEntry` diary paths; `TileQueryGate` **51** starts for metatile COP family.
- **Block-move false touch:** scene **`$AA`** block move at `$82:0406` reads thinker list bytes without parsing lists; `SpawnSceneThinkers` only reads the high byte of a 16-bit load across a prior list’s `$FF` (`$83:D802` / `D812` / `D840` / `D846`) — explains stray CDL on `thinker_spawn_0CE9EA` / `0CEA45`.
- **Opcode fetch false read:** **82** reads of ROM **56579** (`SpawnItemSparkleEffect`) are `LDA [$0A]` in `CopDispatch` at `$80:847B` fetching the COP word at **56578**; same pattern likely for the single read of `ForcedWalkWest` (**60483**).

**Representative UNREF rows (runtime unless noted):**

| Label / topic | ROM offset (dec.) | Exec | Read | Verdict |
|---------------|-------------------|------|------|---------|
| Six `consolestring_01E82B`–`01E85C` | 124971–125032 | 0 | 0 | VERIFIED-RUNTIME; R3: no pointer |
| Three thinker lists `0CE8E6` / `0CE9EA` / `0CEA45` | 846054–846417 | 0 | 4–105 | VERIFIED-RUNTIME (never parsed as lists); R3: no table word |
| `idle_sprite_display` | 589055–589077 | 0 | 0 | VERIFIED-RUNTIME; R3: no spawn pointer |
| `camera_delta_oscillator` | 570743–570769 | 0 | 0 | VERIFIED-RUNTIME; R3: no pointer (header `$88:B577`) |
| `unused_particle_rain_spawner` + children | 774827–774917 | 0 | 0 | VERIFIED-RUNTIME; R3: only child spawn at 774852 |
| `dialog_string_scanner` | 778693–778806 | 0 | 0 | VERIFIED-RUNTIME; R3: no pointer |
| `debug_man` / entry / interact | 781856–782880 | 0 | 0 | VERIFIED-RUNTIME; R3: no pointer |
| `CameraDeadBoundsX` / `Y` | 60232–60280 | 0 | 0 | VERIFIED-RUNTIME (controller ran); stubs are `LDA` + `BRA` after unreachable branch |
| `camera_drift_offsets` words 0–7 / 8–15 | 53352–53383 | — | 1859 / 0 | VERIFIED-RUNTIME (mask 3 bits, `camera_drift.asm:22`) |
| Nine diary `_noref` + helpers + `diary_cursor_menu_table` | 781318–783013 | 0 | 0 | VERIFIED-RUNTIME; R3: no external pointer |
| `TitlePaletteStep_noref` | 772519–772525 | 0 | 0 | VERIFIED-RUNTIME; R3: no pointer |
| `DrawMetatileStream` + delay + bit-2 branch | 38659–38894 | 0 | 0 | VERIFIED-RUNTIME |
| `ForcedWalkWest` / `East` | 60483–60650 | 0 | 0–1 | VERIFIED-RUNTIME (no east/west forced walks in data; static parse) |
| `NorthProbeRedirect` | 184888–184894 | 1071 (153 starts) | 0 | VERIFIED-RUNTIME (dead pair) |
| `SceneCmd_LoadBgTiles` mode 3 path + `Load4bppPage` + `DmaLowVramTileset` | 165107–166268 | 0 | 0 | VERIFIED-RUNTIME (228 scene loads × forms + menus) |

**Index / compressed rows (INCONCLUSIVE unless pointer read):**

- `spriteset_transform_poses` body row 5: **`$04` `$0C` `$11`** never selected; **15 of 16** other indices read; **`$0A`** also never selected in forced `Transform_*` entry (script precondition not reproduced).
- `spriteset_npc_props`: **`$03` `$09`** never; **8 of 9** others read; **`$0A`** never (`btE4_kara` scene not reached).
- `spm_darkspace_sprites` (ROM **1910209**–**1910775**): **17,532** reads, **0** exec — compressed; scene **`$10`** actor animation index needs WRAM breakpoint, not PRG counters.
- `move_chain_table`: **`[$21]`** 2 pointer reads, **`[$3D]`** 92; **`[$4C]`–`[$4E]`** 0; **53 of 80** other chains read, **27** never; users not identified.
- `spriteset_pickups_effects`: **26 of 63** pointer reads; **37** never; per-actor `Stage*` census not done.
- Shadow Status: placeholders at **124481**–**124627** read under SIMULATED form 2; **`01E7C8`** (`ability_description_table[0C]`) read **0**; superset ranges **`01E655`** / **`01E6D4`** INCONCLUSIVE.

### 3.2 R2 scene sweep, warps and metadata

**O sweep (`$0642` writes):**

- **255 of 255** ids accepted at NMI **17**; **231** finished load; **24** never completed (NMI count **17**): ids including **`48` `4A` `57` `76` `77` `81` `84` `9E` `9F` `AA` `AB` `AF` `C1` `C2` `CA` `CB` `EB`–`EF` `F1` `F8` `F9`**.
- **`$F9` on O:** CPU at **`82:8BAC`–`8BB0`** reads **`$2140`**, SPC answers **`$01`** for **4300** frames (BGM command **`$17`** in script runs first). **R loads `$F9`** (404 frames, 6 actors, preset **`$00`**). INCONCLUSIVE why O stalls.
- **Flag poke:** same 255 ids with flags **`$00`–`$0F`** forced **`$FFFF`** before load — flag **`$FF`** tested **5,071** times, all thinker **`D` = `$0F00`–`$FFFF`**.

**Warps and game over (O):**

- Static: **200** pan lists, **543** warps, **200** forced-walk warps; byte-6 high nibble **`$8`** north ×100, **`$4`** south ×100; **23** save entries (bit 7 of byte 9) in scenes **`1A` `1C` `24` `4C`×4 `5E` `6B` `88` `B1` `B7` `CC`×7 `DF` `E1`–`E3`**.
- Runtime: **32 of 32** warp entries fired; **88 of 88** forced walks; **`$06E0`** equals static pan index **88 of 88**; camera travel equals list total on **20** resting-camera samples; **`warp_def_03`** codes **`$04`/`$05`**: step **`$1409`/`$1209`**, list **`$00`**, Y offset **+328/−304** px.
- **Game over:** 0 gems → staged scene **`$1B`** (last save warp destination); 100 gems → **`$22`**, paid 100 gems, HP **4/8**.

**No-record and shared-event ids:**

- **25** ids without `scene_meta` record: none is a warp target or **`QueueMapChange`** operand (**138** sites decoded). On **O**, **`$09`** / **`$80`** execute stray bytes; others hang at **`82:8CFF`**. On **R**, all **25** crash (`sceneCurrent` → **`$73xx`**, NMI **19**, SP **`$4212`**, PC **`00:0676`** or **`80:9389`**).
- **16** ids sharing pointer **`scene_event_0C8200`**: no legitimate loader path; same hang/stray/`$F9` stall behaviour as sweep.

**Display / tile load:**

- Static: command **`$03`** modes **0×255, 1×62, 2×2**; layer operands **`$01`/`$02` only**.
- Runtime: mode-3 entry (**165107**), **`Load4bppPage`**, **`JMP DmaLowVramTileset`**, **`DmaLowVramTileset`** — **0** fires in **231** scenes; positive controls in scenes **`$02` `$15` `$21` `$5A` `$8C` `$E6` `$F7` `$FD`**.
- Presets: **229/229** match static; unused **`$09` `$27` `$29`**; mode 7 scenes **`$59` `$C0` `$FE` `$8C` `$8D`**.

**Parallax / world map:**

- **`parallax_scroll_table` types `$09` `$0C` `$0D` `$0F`–`$1A`**: no spawn; type **`$0F`** only in unreferenced list **`thinker_spawn_0CE9EA`**.
- **80** scenes spawn `scanline_band_hdma_thinker` with exactly **20** table types; scene **`$84`** listed but has no record.
- World map: literals **`$01`–`$1B`** choices; routes **`$01`–`$0D` `$11`–`$22`** only; **`$0D58`/`$0D5A`** stores only from three COP handlers + two clears.

**Overworld exit:**

- Flag **`$01`** at **`$0A02`**: **0** at arrival in **255/255** scene starts including **`$15`** — extends W1-c **`ClearSceneState`** (164/164). CONTRADICTED prior “exit disabled while flag set” as a persistent state.

### 3.3 R3 ROM pointer scans (static)

Method: for each label, search all ROM alignments for 24-bit LE pointer to header, entry (**K+3**), and in-block addresses; same-bank 16-bit words; `rg` name reference in source. Offsets are decimal HiROM (bank \| 0x80 in high byte of CPU address).

| Label | CPU entry | p24 / p16 result |
|-------|-----------|------------------|
| `idle_sprite_display` | `$88:FD02` | No code pointer; 15 same-bank words in compressed gap **518439**–**557056** |
| `camera_delta_oscillator` | `$88:B57A` | **0** hits outside assets |
| `unused_particle_rain_spawner` | `$8B:D2AE` | Only child spawn operand at **774852** |
| `dialog_string_scanner` | `$8B:E1C8` | Coincidence in `bgm_blessing_of_nature` data only |
| `debug_man` | `$8B:EE23` | **0**; single 24-bit hit inside asset |
| Diary `_noref` block | `$8B:...` | No 24-bit or same-bank entry pointer; menu engine operands only internal |
| `TitlePaletteStep_noref` | `$8B:...` | **0**; predecessor ends RTL **772518** |
| Strings **01E82B**–**01E85C** | bank `$01` | **0** table pointers |
| Thinker lists **0CE8E6** / **0CE9EA** / **0CEA45** | bank `$83` | **0** of 256 `scene_thinkers` words |
| `camera_drift_offsets` **D078**–**D087** | `$00:D078` | No reader besides masked index in `camera_drift.asm` |

**Static only (Shadow reachability):** indexes **9**–**11** need form **2** and flags **`$0518`–`$051A`**; **`AbilitySceneTable`** grants only low bits **`$01`–`$40`**; no `SetFlagWord` operand for **`$0518`–`$051A`** found — runtime play not observed (INCONCLUSIVE).

### 3.4 Union handed from R2 to R1

R2’s sweep reached **`SceneScriptMain`**, mode-0 tile paths, and **`FindCurrentScene`** scan (**`82:8CFF`**) for every loaded id — material R1’s CDL union did not get from natural play alone. Scene **`$AA`** as `sceneCurrent` in R1’s Will sweep is explained: O never finishes loading **`$AA`**; the block move at **`82:0406`** is stray code, not a normal load.

---

## 4. Shipped notes corrected

| Place | Old statement | Verdict | New statement |
|-------|---------------|---------|---------------|
| `player_move_ns.asm:36` block note | “Everything here is UNVERIFIED-RUNTIME” for the north redirect chain | CONTRADICTED (stale) | Dead `MapCellDown` pair verified in 5 entries; arithmetic unchanged |
| `scene_warps.asm:19` | “Not traced: which warp uses which pan list.” | CONTRADICTED | Pan list index measured for 88 entries; static decode of all 200 lists |
| `scene_warps.asm:23` | “not traced: what the walk does” with save/revive | incomplete | Save vs revive pointers; `warp_def_03` aliases with larger Y offset |
| `scene_meta.asm:11` | (no behaviour for invalid ids) | refined | 25 no-record ids hang or stray; R crashes |
| `scene_actors.asm:16` | partial reachability | refined | 16 shared-event ids unreachable; TEST MAP never appears |
| `scene_script.asm` / `SceneCmd_LoadBgTiles` part | modes described but not usage-proof | refined | Mode 3 and orphan layer path never selected in 231 scenes |
| `display_preset_table.asm:1` | no use list | refined | 44/47 presets used; mode-7 scene list |
| `scanline_band_hdma_thinker.asm:57` | “53 of 81 scenes” | CONTRADICTED | 80 scenes spawn thinker ( `$84` cannot load); 20 types only |
| `overworld_exit.asm:210` / block QUIRKS | flag `$01` disables exit as standing state | CONTRADICTED | Cleared on every scene setup; 255/255 at `$15` arrival |
| `camera_delta_oscillator.asm:5` | “unused or spawned from data” | CONTRADICTED (spawn half) | No ROM pointer; data spawn excluded |
| `sFC_title_intro.asm:77` (`TitlePaletteStep_noref`) | “UNVERIFIED-RUNTIME whether anything reaches it” | CONTRADICTED | No pointer; never runs |
| `camera_drift.asm:22` | last 8 words unreferenced (already correct) | confirmed | R1 read 0 on words 8–15; R3 no other reader |

Docs called out in R3 for a non-merge fix: `docs/code/bank00/data-tables-memory.md` **`camera_drift_offsets`** — the live text already states only the first eight words are read (MS04 listed this as still wrong at apply time; the bank00 doc now matches R3).

---

## 5. Rules for patch authors

1. **Treat a zero exec count on a sprite or move index as inconclusive** unless a pointer scan (R3 method) also finds no ROM reference and you are not relying on a RAM-built index.
2. **Do not patch north-wall logic assuming `NorthProbeRedirect`’s `MapCellDown` path matters** — the measured entries leave the chained state unchanged at `loc_02D208`.
3. **Stage game-over respawn only through the 23 save warps** — they alone write `$0AF0`/`$0AF2`; every warp still updates `$0AF4`/`$0AF6`.
4. **Never queue `sceneNext` to an id without a `scene_meta` record** — on retail O the load hangs or runs stray code; on the rebuilt ROM it crashes.
5. **Do not call `SceneCmd_LoadBgTiles` mode 3 or the bit-7-only layer path from new scene data** — no retail scene uses them; handlers are dead interpreter branches.
6. **Index `camera_drift_offsets` with at most three bits** — only words 0–7 are read; words 8–15 are padding.
7. **Do not spawn `idle_sprite_display`, `camera_delta_oscillator`, diary `_noref` routines, or `TitlePaletteStep_noref` without new pointers** — the ROM contains no spawn table or JSL/JMP reference to them.
8. **Do not gate overworld exit on flag `$01` staying set across loads** — `ClearSceneState` clears flags `$00`–`$0F` every setup; test the flag only inside the same scene frame window if needed.
9. **For Quintet-LZ sprite files, use WRAM or animation-index breakpoints** — PRG read counters during decompression do not show which animation index was selected.
10. **When probing warps from a test harness on ROM O, pulse physical A** to release a banner or dialog that blocks the main loop, and place the player on the trigger rectangle by a RAM write. The pad layout of this baserom build differs (physical A feeds `$8080`, physical B `$4008`), so name the build.

---

## 6. Where the findings live in the docs

| Topic | Document |
|-------|----------|
| `NorthProbeRedirect` dead pair | [`code/bank02/player-movement.md`](code/bank02/player-movement.md) (`NorthProbeRedirect`, north dispatcher) |
| Forced walk, pan table, `$06E0`, extended step codes | [`code/bank00/camera-scroll-system.md`](code/bank00/camera-scroll-system.md) (Forced Walk Functions) |
| Save / revive warp pointers `$0AF0`–`$0AF6` | [`wram-memory-map.md`](wram-memory-map.md), [`code/bank02/game-systems.md`](code/bank02/game-systems.md) (ExecuteWarp) |
| Scene meta, invalid ids, presets | [`code/bank0D-scene-meta.md`](code/bank0D-scene-meta.md), [`structs-reference.md`](structs-reference.md) (`display-preset`, `scene-meta`) |
| `SceneCmd_ConfigDisplay` / presets / mode 7 scenes | [`code/bank02/scene-script.md`](code/bank02/scene-script.md) |
| Parallax thinker types | [`code/bank0C-scene-spawn-tables-comet.md`](code/bank0C-scene-spawn-tables-comet.md), [`bank01-data-tables.md`](bank01-data-tables.md) (`parallax_scroll_table`) |
| `camera_drift_offsets` (8 words live) | [`code/bank00/data-tables-memory.md`](code/bank00/data-tables-memory.md) (`camera_drift_offsets`) |
| Player flags at spawn, flag `$01` | [`wram-memory-map.md`](wram-memory-map.md) (actor flags / spawn) |
| COP warp / save bit | [`cop-commands-reference.md`](cop-commands-reference.md) (scene transition queue) |

---

## 7. Tools, states and files

All under `plans/extracted-audit/mesen2-results/` unless noted.

| Kind | Files |
|------|-------|
| Lua kits | `kit/lib/a_census.lua` (R1 leg wrapper `acen.run`), `e2.sweep` template in `R1_20261109_lua.md`, `kit/lib/r2_kit.lua`, `r2w_kit.lua` |
| Python harness | `harness/r1_run.py`, `r1_static.py`, `r1_hits.py`, `r1_ranges.py`, `r1_probe*.py`, `r1_report.py`; `harness/r2_sweep.py`, `r2_static.py`, `r2_warp.py`, `r2_fw.py`, `r2_probes.py`; `harness/mcp_client.py` |
| Draft note specs | `specs/R1_notes.json`, `R2_notes.json`, `R3_notes.json`; merged in `plans/extracted-audit/edits/MS04.json` |
| Save states | `rebuilt/states/orig_*` (R1 legs), `orig_S01r_south-cape-ready.mss`, `R-0cfcb558_S01r_south-cape-ready.mss` (R2) |
| Raw output | `raw/R1_table.md`, `R1_acc.json`, `R1_legs.json`, `R1_cdl_union.cdl`, `R1_static.txt`, `R1_probe_*.json`; `raw/R2_sweep.md`, `R2_static.txt/json`, `R2_O_sweep_meta.json`, `R2_R_noid.md`; `raw/R3_scan_20261110.txt`, `R3_helpers/` |
| Reports | `R1_20261109.md`, `R1_20261109_lua.md`, `R2_20261109.md`, `R2_20261109_lua.md`, `R3_20261110.md`, `CO03_close_R1_F2.md`, `MS04_apply.md`, `closures.md` (R rows) |

---

## 8. Tool and method lessons

- **CDL “data” ≠ logical table read** — block moves and coprocessor word fetches set data flags without executing the target range; always correlate reader PC (e.g. `$82:0406`, `$80:847B`).
- **`get_access_summary` `exec` sums bytes in range** — high totals on controllers are not per-frame rates; use `execFirstByte` for entry counts.
- **Separate MCP sessions after `e2.sweep`** — a following `run_script` without `e2.sweep` can finish with `done` and no result (T-80); R1 batches use one Python process per leg.
- **Duplicate `start` in `get_access_summary`** — two ranges sharing one start collapse to the shorter length (T-81); R1’s `R1_ranges.json` keeps unique starts (1,099).
- **APU port debug reads ≠ CPU reads** — R2’s F9 probe saw `emu.read(0x2140)` as 0 while the CPU loop read `$01`; identify stalls from CPU disassembly, not side-effect-free peek.
- **Warp placement:** `y = ry*16+16` was required for warp hits; `y = ry*16+8` failed (fixed in `r2_warp.py`).
- **Pointer scan before negative runtime claims** — R1’s prelude and R3’s full-ROM search are mandatory for UNREF code; animation tables additionally need operand census for RAM indices.
- **R3 is static only** — no server, no CDL; it closes “spawned from data” only when a 24-bit actor pointer would be required.

---

## 9. Open questions

1. Which routine runs the block move at `$82:0406` when scene `$AA` appears, and what WRAM span does it copy?
2. Which `Transform_*` path stages animation `$0A` of `spriteset_transform_poses` (forced entry of seven routines never selected it)?
3. Does natural play set Shadow ability bits 8–10 of `$0AA2` so Status tab shows the placeholder strings without a poke?
4. Which actors select Freedan animations `$1D`–`$29` / `$3E`–`$4B` and Shadow’s unread rows (vine, ladder, ledge states not reached)?
5. What animation indices `#04`–`#09` of `spm_darkspace_sprites` do scene `$10` actors use (needs `$28` breakpoint or decompressed WRAM reads)?
6. Is the single read of `ForcedWalkWest` (ROM 60483) the same `CopDispatch` word-fetch artifact as `SpawnItemSparkleEffect`?
7. Why does scene `$F9` stall on O at `LDA $2140` / `BNE` (`82:8BAC`) while R loads it — role of BGM command `$17`?
8. What bytes does R execute when `scene_meta_list` yields pointer `$0000` (`Y = $0000 − $3A`) before `sceneCurrent` becomes `$73xx`?
9. Where do stray scripts for ids `$09` and `$80` on O originate (matched byte address), and why does `$09` leave collision type `$0E`?
10. What does forced-walk camera travel equal for pan lists `$03` `$08` `$0A` `$0C` `$0D` `$0F` when the camera is at rest before the walk?
11. Why does scene `$FB` run its script twice in ~287 frames?
12. Do event flags `$0518`–`$051A` ever set during play or debug paths (Shadow Status reachability)?
13. Which compressed asset occupies ROM **518439**–**557056** (no `files.json` entry between `gw85_spin_dash_gate` and `nvAC_bones`)?
14. Why do `warp_def_03` entries use stream codes `$04`/`$05` instead of `$02`/`$00` when step words and pans match?

---

## 10. Apply log (MS04)

| Item | Result |
|------|--------|
| Specs | `edits/MS04.json` (includes `R1_notes.json`, `R2_notes.json`, `R3_notes.json` overlaps with W1 and others) |
| Merge | R1: **1** block note (`player_move_ns.asm`); R2: **5** files (`scene_meta`, `scene_actors`, `scene_warps`, `scene_script`, `display_preset_table`); R3: **1** block note (`camera_delta_oscillator.asm`); `TitlePaletteStep_noref` via M2/V1 row |
| Gate | `artifacts/crc.json` after rebuild: checksum **222965960**, crc **-34152415**, totalSize **3062205**, sha1 **`90a04067dd5b5284bd9e152ad222df0e65d08979`** — **no ROM byte changed** |
| Closures | **19** rows name `R1_20261109.md`, `R2_20261109.md`, or `R3_20261110.md` (12 census rows 2026-11-09/10, **7** CO-03 rows 2026-11-11 for north redirect, sprite indices, move chains, dark-space sprites, pickup effects) |
| Docs | This summary; bank docs in section 6 (some doc sentences were left outside the MS04 scope and are listed in its log) |
| Names | None for R series |

See `plans/extracted-audit/mesen2-results/MS04_apply.md` for the full MS04 result table (107 extracted files).
