# Mesen2 W1 series: player movement, scene WRAM, flags, `$7F` scratch and actor census findings (W1-a to W1-g)

Runtime and static address census on the US vanilla ROM: engine DP movement flags, scene-transition and scroll WRAM, event flag `#00` and dungeon kill flags, `$7F` low WRAM (collision tables, thinker pages, palette staging), decompress/sort buckets and menu staging words, `body_table` / `SetPlayerSpriteDirect` selection, and per-slot actor scratch (`$0024`, `$0026`, escort ring, difficulty). Compiled 2026-11-12 from `plans/extracted-audit/mesen2-results/W1-a_20261107.md` through `W1-g_20261108.md`, `closures.md` rows that name those files, and apply logs `MS04_apply.md` and `MS05_apply.md`.

ROM: **O** (vanilla US cartridge dump, SHA-1 `38de0c84dd2bc3bdfc0a3d7ab0220c79b70887c3`, 2,097,152 bytes) for every W1 session. Server: Mesen2 MCP `user-mesen2-mcp-dev` **0.6.0** (`harness/a_common.py` / per-batch `w1*_session.py`, isolated server per run). No step used rebuilt ROM **R**; census offsets match `extract:lt` tags on **O**. W1-e’s `displayModeFlags` bit-0 confirm reuses eleven sessions only as a cross-check (same conclusion as the C4 run, not a separate C-session).

Sections: 1 Result in one page, 2 What was run, 3 Findings, 4 Shipped notes corrected, 5 Rules for patch authors, 6 Where the findings live in the docs, 7 Tools, states and files, 8 Tool and method lessons, 9 Open questions, 10 Apply log.

---

## 1. Result in one page

| Topic | Question | Verdict |
|-------|----------|---------|
| Vertical gate bits `$0800` / `$0400` on `$AA` | Are they ever set before north/south dispatch? | **`TSB $AB` with `#$08` / `#$04`** (offsets 186399, 187513, 187599 and east-wall sites) ran **309 times** in 9 scenes; gates at 184350 / 184362 read the word. Shipped “never set” is **CONTRADICTED**. Whether a set bit **skips** dispatch in play: **0** gate hits with the matching bit (**INCONCLUSIVE**; 276/277 setter ticks had `$24 = 0`). VERIFIED-RUNTIME + INCONCLUSIVE |
| `$AB` bits 2 / 3 | Any reader? | Read through **16-bit `LDA $AA`** at the vertical gates and `AutoAlignEW_*`. Bit **7**: 407 sets, **0** tests (note stays). CONTRADICTED (bits 2/3) + VERIFIED-STATIC (bit 7) |
| Parallax band accumulators `$0750-$0760` | Cleared on scene change? | **`ParallaxClearBandAccumulators`** clears **`$0720-$074F` only**; **`$0750-$0760` keep prior-scene values** at spawn (snapshots at 47245 / 47248). VERIFIED-RUNTIME |
| DP `$5E` / `$60` leftover writes | Consumed? | **`ParallaxThinkerEntry`** stores **`$60 = 1` / `$5E = 0`**; **no read pairs** with those writers over 38,055 thinker ticks. VERIFIED-RUNTIME |
| `$00DC` | Any reader? | **Write-only** in 81,242 frames: **`STZ $00DC`** at 255073, **151** dialogue opens, **26** scenes. VERIFIED-RUNTIME |
| `forcedScrollOverride` `$06C8` | Any reader? | **`WriteBgScroll`** reads **3,320** times; BG HOFS equals **`$06C8 & $03FF`** on **1,952 / 1,952** override passes. CONTRADICTED (“no reader”) |
| `$06F0` / `$06F1` | Constant default actor word? | Low byte never written; **`SceneCmd_ConfigDisplay`** stores **`$06F1`** (85 writes); **`InitActorFromSceneData`** ORs into flags at **989** spawns. CONTRADICTED |
| Event flag `$FF` | Who tests it? | Set/cleared in **`ClearSceneState`**; **14,685** `$80` tests from **thinker slots only** in the 63-scene census (actor-slot tests of `$FF`: **INCONCLUSIVE** outside that set). VERIFIED-RUNTIME + INCONCLUSIVE |
| Event flag `#00` idle family | Shadow form vs flag? | Flag **#00** selects idle sprites **`#10`-`#13`** (anim **`$11`**), clear path **`#00`-`#03`**, **Will and Shadow alike** (116 idle runs, 23 scenes). CONTRADICTED (“Shadow idle”) |
| Dungeon kill `enemyNum` 0 | Stays dead on re-entry? | **No bit set**; **`$1B`**: **6** enemies after **5** kills, **`$0A80-$0AA7` zero**. CONTRADICTED |
| Flag `$01` at scene `$15` setup | Standing “exit disabled” state? | **`ClearSceneState`** zeroes flags **`$00-$0F`** every setup (**164 / 164**); forced `#01` cleared before Itory exit fired. CONTRADICTED |
| `field_reveal_object` child `$26` | Zero for mystic ball / wall walker? | **Nonzero** (`$0001`, `$000B`, `$0006`, `$0012`); child uses **`FieldRevealFromActorStats`** (**4 / 4**). CONTRADICTED |
| `$7F:0000-$01FF` | Actor `animScratch` at map base? | **Collision flag tables** via **`[$3E]` / `[$42]`**; mnemonic-named slot accesses land at **`$7F1000+`**, not **`$7F:0000`**. VERIFIED-RUNTIME |
| `$7F0B22` / `$7F0B24` | Mode 7 flags only? | **Palette staging** for CGRAM **`$91` / `$92`**; **`UploadCgramPalette` DMA** reads them (**351,020** byte callbacks). VERIFIED-RUNTIME |
| `$090E` / `$0910` menu stores | OAM overlay data? | **16 + 16** byte writes, **0** reads; values **`(tile AND $03FF) × 8 + $6000`**. Shipped OAM wording **CONTRADICTED**; **`MenuSelectionHandler.asm` merge BLOCKED** |
| Decompress → sort order | Dirty buckets possible? | **525** decompress calls: **380** clear-before-sort, **145** chain to another decompress, **0** sort-first; **0** dirty words at **90,430** `BuildFinalList` entries. **`Decompress` COP** is a **third `ClearActorRenderList` caller**. VERIFIED-RUNTIME |
| `body_table` row 7 (`spriteset_shadow_fx`) | Reachable via COP `#8E`? | **No write of 7** to **`$0AC8`** (operands **4, 5, 6, 8** only); row **7 never drawn** in **123,038** frames. VERIFIED-RUNTIME |
| Row 8 (Aura transform) | Facing while row 8 active? | **`SetPlayerSpriteDirect #08`**; facing byte from **stack page** WRAM, observed **`$DC`**. VERIFIED-RUNTIME |
| Spawner field `$0024` | Initial value read back? | **35** instructions in **16** routines read **`$24`** after **`CopyActorState`** (**84,108** reads of one hot site). CONTRADICTED |
| Escort ring `$7EDF00-$7EDF7F` | Tracker-exclusive? | Also **decompress**, tilemap fills, **boot DMA**, credits copy, etc. CONTRADICTED |
| `pyCC_blaster` speed | Always 1? | **Second** projectile stores **speed 3** (**7** runs, scene **`$D6`**). CONTRADICTED |
| `$0B14` boot init `$003C` | Any runtime reader? | **No read** in **112,358** frames (**INCONCLUSIVE** for unvisited paths). INCONCLUSIVE |

Counts: **22** topics in the table (**13** VERIFIED-RUNTIME, **10** CONTRADICTED in whole or part, **5** INCONCLUSIVE halves, **0** SIMULATED in this series). Shipped notes: **MS04** applied **27** extracted note / comment / name edits across W1 rows; **1** target (**`MenuSelectionHandler.asm`**) **BLOCKED** (MS05 still blocked). **0 ROM bytes** changed in apply gates.

What changed in what we believe:

1. **Vertical movement gates are not inert.** Bits **`$0400` / `$0800`** of **`$AA`** are set on wall/slope paths and read before north/south dispatch; the old “always passes” note came from a source search gap, not from runtime.
2. **Scroll override and actor default flags are live WRAM.** **`$06C8`** feeds **`WriteBgScroll`**; **`$06F1`** from display presets is ORed into every spawn’s actor flags; **`$06F0`** is not a writable “properties” byte.
3. **Event flag `#00` is a pose / idle family switch**, not a Shadow-form switch. The inventory overlay saves and restores the flag byte; dungeon **`wramFlags`** obey kill bits except **`enemyNum` 0**.
4. **`$7F:0000-$01FF` is collision data, not the actor scratch map.** Thinker scratch is **`$7F3000+` slot**; actor extended clear is **`$7F0E00-$7F0EFF`** each setup.
5. **Depth-sort buckets must be cleared after every decompress**, including the **`Decompress` COP** path. Menu cursor “OAM” stores are **dead graphics-address writes**.
6. **`body_table` row 7 is unused** in measured play; row **8** (Aura) uses **stack-page** facing. **`$0024`** is a real spawner reference; **`$7EDF00`** is shared WRAM, not escort-only.

---

## 2. What was run

| Step | Ids-or-topic | Method | Volume |
|------|----------------|--------|--------|
| W1-a | Engine DP: `$AA`/`$AB`, `$5E-$64`, `$DC`, `$0720-$0761` | Memory callbacks per byte; `w1a_kit.lua` + `w1a_session.py`; static `rg` prelude; 42 scripted sessions + boot + `natural_fr10` | **44** runs, **81,242** session frames, **9** scenes with gate setters |
| W1-b | Scene WRAM: `$06A0`, `$06C8`, `$06F0`, `$06F2`, `$0404`, `$0D6E`, sprite cache, `$06CC` | Same census engine as W1-a; **11** follow-up probe runs with `--mask` | **57** runs, **89,656** main frames (+ **15,602** follow-up), **63** scenes |
| W1-c | Flags: event `#00`, `wramFlags`, `$0AEC` counters, Itory `$01` | W1-a/b session table plus kill / world-map / game-over pokes; flag and spawn watches | **108** runs, **131,278** frames |
| W1-d | `$7F` scratch bands, ramp/glide/reveal/inventory pokes | `w1d_kit.lua` + merge reports; extra **`t_reveal_*`**, **`t_kill_*`**, **`t_glide_s`**, **`t_inv_scroll`** sessions | **57** runs, **109,058** frames, **69** scenes |
| W1-e | `$0B14`, `$0648`, `$090E`/`$0910`, curve ptrs, `$0200-$02FF`, display bit 0 | `w1e_session.py`; second **`_dm`** pass watches **`$09EC-$09ED`** | **54** + **11** runs, **112,358** + **14,300** frames |
| W1-f | `$0AC8`, `$0AD4`, player spriteset ptr, facing tables | `w1f_kit.lua`; **8** ability/menu bots + **FORCED** `sE6_gaia` transform entries; ROM **O** button map (physical **B** = attack **`$8000`**, **Y** = item **`$4000`**) | **55** runs, **123,038** frames, **51** scenes in batch f |
| W1-g | All slots `$0024`/`$0026`, `$0B02`, `$7EDF00-$7EDF7F` | `w1g_kit.lua`; **32** batch-g sessions (escort + smooth_follow callers) + shared table | **79** runs, **225,488** frames, **93** scenes with hits |

Every state-based run used **`rebuilt/states/orig_*`**, H1 health check (120 frames after load), and unchanged low DP **`$00-$94`**. Static census: full **`extracted/`** operand search before each batch.

---

## 3. Findings

### 3.1 Movement DP and parallax (W1-a)

- **`$AA` bits `$0800` / `$0400`:** Set via **`TSB $AB`** (#`$08` / `#$04`) at 186339, 186399, 187513, 187599 (and east-wall companions). Cleared next tick by **`STZ $AA`** at 184286. Probed **277** setter ticks at gates 184350 / 184362.
- **`$AB` bits 2 and 3:** Consumed by the same **16-bit `LDA $AA`** gates; **`$AB` bit 7** set on diagonal wall paths, **never tested** (407 sets).
- **`$0720-$0761`:** **`ParallaxComputeBandValue`** writes accumulators; clear routine 47305 touches **`$0720-$074F` only**. Stale **`$0750-$0760`** documented at spawns in **`$E5`**, **`$1D`**, **`$2D`**, **`$2E`**, **`$FD`** (example words in the result file snapshots).
- **`$5E` / `$60`:** Boot **`wram-init`** at 171642; thinker entry 47290 / 47295 writes **`$60=1`**, **`$5E=0`** with **no paired read**.
- **`$DC`:** Only **`OpenDialogueBox_Body`** clears **`$00DC`** (255073); **no CPU read** in the census window.

### 3.2 Scene, scroll and transition WRAM (W1-b)

- **`$06A0`:** Single boot write **`$C000`**; all **`$0080`/`$0082`** map readers see **`$00`/`$C0`**.
- **`LoadPlayerGraphics`:** Skips scenes **`$FE`**, **`$F7`**, **`$8C`** only (68/77 uploads).
- **`$0404` stub bank:** **`$7F`** on all palette copies measured; **`$7E`/`$7F`** on DMA helpers.
- **Flag `$FF`:** Set in **`ClearSceneState`**, cleared on inventory open; **14,685** thinker tests with mask **`$80`**.
- **`$0D6E`:** Normal path = scene just left (**79** writes); world map deferral stores destination **`$0A`** once on **`$01→$FE→$0A`** replay.
- **`$09CC`/`$09CE`:** Player sprite cache; **`CheckPlayerSpriteCache`** / **`DecomposePlayerSprites`** only writers in census.
- **`$06CC`:** Vertical scroll override flag word; **always zero** written/read in census (no vertical override scene found).
- **`$06F0`/`$06F1`:** **`$06F1`** from display preset byte **+4** bits 4–5; ORed at **`InitActorFromSceneData+41`**.
- **`layerPriorityFlag` bit 12:** Set/cleared by **`SceneCmd_ConfigDisplay+219`**; priority compose path in **7** scenes (`$59`, `$8C-$8F`, `$C0`, `$FE`).
- **`$06C8`:** Writers **`Layer1DriftUnbounded`**, **`ScrollCameraInit`**; reader **`WriteBgScroll+5`** (**3,320** reads); masked value **equals** BG HOFS store on every override pass.
- **`$7F0600` compose vs dialog:** No overlap in **`$FE`** name phase (measured frame ranges).

### 3.3 Event flag `#00` and dungeon flags (W1-c)

- **Idle / shimmer:** Flag **`#00`** drives **`IdleStand*Flagged`** and anim **`$11`**; **`ShadowShimmerActive`** sees flag set in all **26** `scene_flag_init` scenes.
- **Setters / clears:** **`scene_flag_init`**, **`sc01_fisherman`**, inventory loop; **`ClearSceneState`** clears **`$00-$0F`** each load.
- **Kills:** Nonzero **`enemyNum`** sets dungeon bit, survives room change; cleared on **world map** (**32** byte stores) and **real game over** (not revive).
- **`enemyNum` 0:** **`SetWramFlag`** COP **never** runs; enemies respawn.
- **`$0AA0`:** Outside **`ClearAllWramFlags`** range; survives world map / game over clears.
- **Boss reward latch:** Forced Castoth run: **`SetWramFlag_Offset100`** → **`$0AA0`** **00→01**; Castoth entry **`STZ`** pair zeroes counters after test.
- **Itory flag `$01`:** Cleared at **`$15` setup**; block note “unrelated scripts leave it set” is wrong as a **standing** state.

### 3.4 `$7F` scratch, reveal and inventory (W1-d)

- **Collision tables:** **`BuildMetatileFlagTable`** / **`FillCollisionFromLayer0`** / **`OverlayCollisionFromLayer1`** use **`$7F0000+`** via **`[$3E]`/`[$42]`** (hundreds of thousands of accesses).
- **`$7F0E00-$7F0EFF`:** Zeroed **`InitActorPool`** every setup including **`$FF`**; no other access in **109,058** frames.
- **`$7F3000-$7F30FF`:** Per-thinker page **`$7F2100 + slot`** (loop PC, counter, +4 word for credits HDMA etc.).
- **`field_reveal_object`:** Tier **`$FFFF`** stores **not reached** from mystic ball / wall walker; child **`$26`** = enemies remaining.
- **Ramp lock:** With **`statsPtr := $0000`**, only **`RampArcDriver`** (+ copies) read player **`statsPtr`** afterward.
- **`$7F0C00-$7F0C02`:** Uploaded to **COLDATA**; writers **`ClearSceneState`**, palette bundle copies, inventory restore; four direct scene **`STA`** sites **not executed** in **`t_fade`**.
- **Inventory open:** **`$06CA`/`$06CC`** poked values **not restored**; **`$00B2`** = VRAM DMA size; circle-window thinker params **`$00F4`/`$00F8`** zeroed.

### 3.5 Transitions, menu staging and sort buckets (W1-e)

- **`gfxCacheIdxA`:** Boot **`$0404`** init **never consumed** (first read after **`ClearSceneState`** zero at frame 26).
- **`$090E`/`$0910`:** Eight world-map cancels wrote **`$6D60` / `$6DE0`**; **zero reads**.
- **`$09BE`/`$09C0`/`$09C4`:** Not read on executed **EW** slope paths; **NS** routines **0** executions (**INCONCLUSIVE**).
- **`$0200-$02FF`:** Decompress fills dictionary; **`ClearActorRenderList`** after **every** measured decompress chain; **`Decompress` COP** (39348) confirmed **14/14** credits clears.
- **`displayModeFlags` bit 0:** Consumer **`Bg3TilemapVramDma`** (176184) on menu redraw (**_dm** run).

### 3.6 Body table and facing (W1-f)

- **`$0AC8` writes:** Only **`SetPlayerSpriteDirect`** (**34** writes: rows **4, 5, 6, 8**).
- **Row 8:** **`PlayerAuraTransformEntry`** → **`#08`**; **`GetPlayerFacingDirection`** with carry set, byte from **`$84:0101`** (stack page), e.g. **`$DC`**.
- **Rows 4–6:** **`FacingData`** tables at **`($0AC8-4)×2`**; rows **5–6** all-zero tables reached (row **5** partly via **FORCED** `Transform_*` entries).
- **Row 3 / row 7:** **No** measured selector (**INCONCLUSIVE** for saved **`characterForm` 3** load).
- **Buttons (ROM O):** Attack tests **`$8001`** (physical **B** **`$8000`**); item use **`BIT #$4000`** (physical **Y**). Extracted **`$0081` / “physical A attack”** text is **transform build** (`transforms.json`), not **O**.

### 3.7 Actor `$0024`, escort ring and speeds (W1-g)

- **`$0024`:** **`CopyActorState`** initial spawner slot → **35** reader sites (e.g. **`StandardEnemyDefeatHandler`**, depth sort, interaction).
- **Scene `$FF` skip:** Control vs patched **`InitActorPool`** identical over **42** spawns (**INCONCLUSIVE** for nonzero-at-spawn case).
- **`smooth_follow_child` speeds:** **`$0001`** ec0C ribber, **`$0003`** second **pyCC** shot, **`$0002`** awB1, **`$0004`/`+$0B02`** pyDD mummy queen.
- **`$0B02`:** **0** in normal play; **one** boot writer; difficulty offset for pyDD when poked.
- **`$7EDF40-$7EDF45`:** Tracker setup writes **ninth** entries; **reads only `$7EDF00-$7EDF3F`** (**1,016** moves, **6** trackers).
- **Lily seed 4:** Table row **3**, idle anim **`$1C`**.

---

## 4. Shipped notes corrected

| Place | Old statement | Verdict | New statement |
|-------|---------------|---------|---------------|
| `player_move_main.asm` / west / east / south block notes | Bits `$0800` / `$0400` of `$AA` never set | CONTRADICTED | `TSB $AB` sets them; gates read `$AA`; cleared each movement tick |
| `player_move_west.asm` / `player_move_east.asm` comments | No reader for `$AB` bits 2 / 3 | CONTRADICTED | Read via 16-bit `LDA $AA` at vertical gates |
| `thinkers/scanline_band_hdma_thinker.asm` block note | (partial) | refined | `$0750-$0760` retain values across parallax scene changes |
| `sprite_composition.asm` / `camera_scroll.asm` / `layer1_scroll_actors.asm` | No reader / no setter for `$06C8` or bit 12 | CONTRADICTED | `WriteBgScroll` reads `$06C8`; `SceneCmd_ConfigDisplay` sets bit 12 |
| `actor_execution.asm` `InitActorFromSceneData` | `$06F0` never written | CONTRADICTED | `$06F1` from display preset ORed into spawn flags |
| `scene_lifecycle.asm` comment on flag `$FF` | Thinker-only test “inferred” | refined | Measured: thinker slots only in 63-scene census |
| `inventory_overlay.asm` comment on `$06CC` | Unnamed word | refined | `scrollOverrideV` + 2 / BG2 vertical override slot |
| `player_character.asm` idle comments / `SetPlayerIdleFacing.asm` | Shadow byte chooses idle row | CONTRADICTED | Event flag `#00` chooses `#10`-`#13` vs `#00`-`#03` for all forms |
| `StandardEnemyDefeatHandler.asm` | `enemyNum` kill “stays dead” always | CONTRADICTED | `enemyNum` 0 sets no `wramFlags` bit |
| `overworld_exit.asm` | Flag `$01` may stand from other scripts | CONTRADICTED | Cleared on every scene setup including `$15` |
| `field_reveal_object.asm` block note | Child `$26 = 0` for mystic ball / wall walker | CONTRADICTED | Child `$26` = enemies remaining; tier path not taken |
| `mode7_perspective.asm` / `actor_execution.asm` comments | No reader for palette / `$7F0E00` | refined | DMA reads staging words; `$7F0E00` page is init-only clear |
| `sprite_composition.asm` `ClearActorRenderList` | Callers: scene + inventory only | refined | Third caller: `Decompress` COP handler |
| `MenuSelectionHandler.asm` block / part / comments | Values are OAM sprite data | CONTRADICTED | Graphics CHR addresses; nothing reads them — **merge BLOCKED** |
| `tables/body_table.asm` part note | (row 8 facing) | refined | Row 8 uses stack-page facing byte (`$DC` observed) |
| `actor_pool.asm` comment | Reader of initial `$0024` unknown | CONTRADICTED | 16 routines consume spawner slot |
| `smooth_follow_child.asm` / `EscortFollowPathTracker.asm` | pyCC speed 1 only; exclusive `$7EDF00` | CONTRADICTED | Speed 3 on second shot; many engines share `$7EDF00-$7EDF7F` |

Doc sentences left for later passes (not merged in MS04): `docs/code/bank02/player-movement.md` says “no setter” for `$AA` gate bits; other stale lines in dungeon and camera docs are listed in **`MS04_apply.md`** §Items outside scope. The later documentation pass edited the camera and movement docs only where its log says so.

---

## 5. Rules for patch authors

1. **Do not assume `$AA` bits `$0400` / `$0800` are always clear.** Patch movement that depends on skipping north/south dispatch must account for wall and diagonal paths that set them via **`TSB $AB`**.
2. **After parallax band scenes, treat `$0750-$0760` as stale** unless your code clears them. **`ParallaxClearBandAccumulators` does not reset those words.**
3. **Use `$06C8` and `$06C9` bit 15 as the live forced horizontal scroll pair** when hooking camera code; **`WriteBgScroll`** masks to **`$03FF`** and applies the override on every measured pass.
4. **OR display-preset bits into spawn flags through the existing `$06F1` path**; do not write `$06F0` expecting a standalone “default properties” byte.
5. **Branch idle and shimmer logic on event flag `#00`, not on `characterForm`.** The inventory overlay saves and restores the byte across menu open.
6. **Only call `SetDungeonKillFlag` for enemies with a nonzero `enemyNum`.** Room repopulation ignores kills when the number is 0.
7. **Assume `ClearSceneState` clears event flags `$00-$0F` on every load** before testing warp gates such as Itory flag `$01`.
8. **Do not spawn `field_reveal_object` tier items through mystic ball or wall walker without zeroing child `$26` yourself**; known spawners pass the remaining-enemy count.
9. **Treat `$7F:0000-$01FF` as collision flag storage**, not actor **`animScratch`**. Actor slot fields live at **`$7F1000+` index**.
10. **Always follow `QuintetLzDecompress` with `ClearActorRenderList`** (or an equivalent bucket zero) before the next depth sort; the **`Decompress` COP** already does this in the shipped handler.
11. **Do not read `$090E` / `$0910` expecting menu cursor OAM.** Stores are cosmetic tile-address copies; merge cannot fix **`MenuSelectionHandler.asm`** until the tool refusal for that file is fixed.
12. **Do not reference `body_table` row 7 in new COP `#8E` sites** unless you add a new selector; no shipped operand uses row 7.
13. **Preserve spawner slot `$0024` when cloning actors** if downstream logic (defeat handlers, reveal children, sort keys) must know the parent slot.
14. **Before sharing `$7EDF00-$7EDF7F`, check all current users** (decompress, tilemaps, boot fill, escort tracker). Overlap corrupts unrelated engines.
15. **Button masks (state the ROM build).** On **vanilla ROM O** (all W1 runs): physical **B** = **`$8000`** (attack / interact tests), physical **Y** = **`$4000`** (item use), physical **A** = **`$0080`** in the harness table. On the **baserom rebuilt** image: physical **A** = logical **`$8080`** (interact **`$8000`** + attack **`$0080`**), physical **B** = **`$4008`** (cancel **`$4000`** + item use **`$0008`**). Raw JOY1: **B** = **`$8000`**, **Y** = **`$4000`**, **Select** = **`$2000`**, **Start** = **`$1000`**.

---

## 6. Where the findings live in the docs

| Topic | Document |
|-------|----------|
| Movement flag word `$AA` / `$AB`, scroll overrides, `$06F0`, display-related spawn bits, dungeon `wramFlags`, event flag `#00` scratch | [`wram-memory-map.md`](wram-memory-map.md) (§2 table, Display Mode Flags Reference, Event & WRAM Flags) |
| Idle `*Flagged` handlers, transitions, ladder/shimmy rows | [`code/bank02/player-character.md`](code/bank02/player-character.md) |
| COP idle staging and flag `#00` example | [`cop/families/player_sprite.md`](cop/families/player_sprite.md) |
| `$0D6E`, `$06F2`, `ClearSceneState` script order | [`code/bank02/scene-script.md`](code/bank02/scene-script.md), [`code/bank03/scene-and-hardware.md`](code/bank03/scene-and-hardware.md) |
| `forcedScrollOverride` reader and writers | [`code/bank00/camera-scroll-system.md`](code/bank00/camera-scroll-system.md) |
| Dungeon kill bits, `ClearAllWramFlags`, `$0AA0` | [`code/bank00/event-flags.md`](code/bank00/event-flags.md) |
| `$7F0E00` / `$7F3000` thinker pages | [`code/bank03/actor-thinker-runtime.md`](code/bank03/actor-thinker-runtime.md) |
| `ReadMenuSelection` / `$090E` wording | [`code/bank03/text-and-menus.md`](code/bank03/text-and-menus.md) |
| Decompress bucket `$0200-$02FF`, `ClearActorRenderList` stage | [`code/bank03/sprite-rendering.md`](code/bank03/sprite-rendering.md) |
| `body_table` row / facing | [`code/bank00/data-tables-memory.md`](code/bank00/data-tables-memory.md), [`cop-commands-reference.md`](cop-commands-reference.md) |
| Spawner field `$0024` in defeat / clone flows | [`code/bank00/actors-combat-interaction.md`](code/bank00/actors-combat-interaction.md), [`code/bank00/actor-management.md`](code/bank00/actor-management.md) |
| Parallax accumulators `$0720-$0760` (stale high words) | [`mesen2-e-series-summary.md`](mesen2-e-series-summary.md) (E4 band thinker apply cross-ref) |

---

## 7. Tools, states and files

All under `plans/extracted-audit/mesen2-results/` unless noted.

| Kind | Files |
|------|-------|
| Lua kit (`kit/lib/`) | `w1a_kit.lua`, `w1d_kit.lua` (shared census; `slotShift` for field watches), `w1e_kit.lua`, `w1f_kit.lua`, `w1g_kit.lua`; builds on `gaia_kit`, `a_census`, `a_actors` |
| Python harness | `w1a_session.py`, `w1b_session.py`, `w1c_session.py`, `w1d_session.py`, `w1d_merge.py`, `w1e_session.py`, `w1e_report.py`, `w1f_session.py`, `w1f_extra.py`, `w1f_report.py`, `w1g_session.py`, `w1g_extra.py`, `w1g_report.py`, `a_common.py` |
| Draft note specs (`specs/`) | `W1-a_notes.json` through `W1-g_notes.json`, `W1-e_notes_MenuSelectionHandler.json` (refused); merged in `plans/extracted-audit/edits/MS04.json` |
| Names | `plans/extracted-audit/renames/apply-MS04_names.json` (5 W1-c idle renames) |
| Save states | `rebuilt/states/orig_*` (H1-checked; indexed in `states-index.md`); drivers reference `orig_S06_title`, `orig_S01r_south-cape-ready`, presets `orig_P**`, chest `orig_C1_*`, etc. |
| Raw output (`raw/`) | `W1a_*_20261107.json` / `W1a_report.md`; `W1b_*`; `W1c_*`; `W1d_*` / `W1d_merged.json`; `W1e_*` / `W1e_dm_*`; `W1f_*`; `W1g_*` / `W1g_aggregate.json` |
| Reports | `W1-a_20261107.md` … `W1-g_20261108.md`, `MS04_apply.md`, `MS05_apply.md`, `closures.md` (W1 rows), `CO12_docs.md` |

---

## 8. Tool and method lessons

- **PC attribution:** Callbacks report the address **after** the accessing instruction; harness maps through **`; {n}`** tags to the instruction that ends at that PC.
- **Last-writer pairing:** Read callbacks record the last byte writer in the run (“init” if none); used to prove **`$5E`/`$60`** leftovers are orphaned and **`gfxCacheIdxA`** boot init is dead.
- **DMA read storms:** Watching DMA-fed buffers can yield millions of hits (T-49); kits must compress or narrow the window. Boot WRAM fill can masquerade as CPU writers—check PC and frame.
- **Forced deaths / callback entries:** Killing callback-bearing enemies in **`$82`/`$8A`** resets the session (T-50); natural kills in other scenes worked for reveal and kill-flag tests.
- **`emu.read` inside callbacks:** Reading `snesMemory` / `snesPrgRom` from a memory callback can hang the host (T-48).
- **ROM O vs rebuilt input map:** The first W1-f runs pressed physical **A** for attack and **B** for item use (the vocabulary of the extracted text) and fired nothing on ROM O until the remap words were read: **B** attacks, **Y** uses the item.
- **State discipline:** No W1 run wrote save states; pokes after load stayed in disposable sessions. Low engine DP **`$80-$82`** (collision map pointer) was never touched by design.
- **Merge guard:** `MenuSelectionHandler.asm` is a transforms artifact—`merge` refuses all note edits there; still blocked after the last apply pass.
- **Chunked input:** `natural_fr10` and long warps rely on frame chunks to stay under client timeouts (~120 s).

---

## 9. Open questions

Deduplicated from the seven W1 reports and `open-questions.md` (NQ-258–NQ-301); question ids appear only here.

1. Does any play path keep vertical velocity **`$24` ≠ 0** when bits 2/3 setters run so a north/south gate can skip dispatch? (NQ-258, NQ-261; gate-effect half of OQ-I029-3)
2. Which HDMA setups in **`$E7` / `$F7`** read **`$0720-$0749`** via bank aliases? (NQ-259)
3. Does quick warp **`$0642 = $E7`** need a flag beyond the preset table? (NQ-260)
4. Why **`ParallaxThinkerEntry`** writes unused **`$60 = 1` / `$5E = 0`? (NQ-262)
5. Where is **`Layer1DriftUnbounded`** spawned for scene **`$58`**? (NQ-263)
6. Do non-thinker actor scripts test flag **`$FF`** outside the 63-scene census? (NQ-270; later R2 sweep partially answers—see closures)
7. What pose do sprites **`#10`-`#13`** show in the 26 flag scenes? (NQ-271)
8. Which spawn route reaches **`field_reveal_object`** tier items with child **`$26 = 0`? (NQ-277)
9. Which code reads **`$0B14`**? (NQ-286)
10. Do NS slope routines (177642, 177670, 178080) touch only direct curve pointers **`$09BC` / `$09C2`? (NQ-287)
11. Can **`GetPlayerFacing_BaseBodyFallback`** run if no save restores **`characterForm` bit 15? (NQ-290)
12. What code path sets **`body_table` row 3? (NQ-292 / row 3 half)
13. Does scene **`$FF`** inventory skip matter when **`extendedFlags`/callback fields are nonzero at spawn? (NQ-296)
14. Runtime effect of **`gw8A_sand_fanger`** projectile speed store at 756099? (NQ-297)
15. Remaining static readers of **`$0B02`** (orb shot, stone guard, unused boss) under live difficulty values?

---

## 10. Apply log

| Item | Result |
|------|--------|
| Merge spec | `plans/extracted-audit/edits/MS04.json` (107 files union; W1 pieces from `specs/W1-*_notes.json`) |
| Names | `plans/extracted-audit/renames/apply-MS04_names.json` — 5 idle renames (`IdleStand*Flagged`, `PlayerIdleFlaggedAnim`, etc.) |
| Gate (MS04) | `npm run rebuild` after merge: checksum **222965960**, crc **-34152415**, totalSize **3062205**, sha1 **`90a04067dd5b5284bd9e152ad222df0e65d08979`** — **no ROM byte change** |
| W1 notes applied | **W1-a:** 4 movement + band thinker files; **W1-b/e:** sprite, camera, lifecycle, inventory comments; **W1-c:** player idle + `scene_flag_init` + Castoth + `ClearSceneState` + **5 names**; **W1-d:** `field_reveal_object`, mode7/actor comments; **W1-f:** `body_table` part note; **W1-g:** `actor_pool`, escort / smooth_follow block notes |
| W1 blocked | **`MenuSelectionHandler.asm`** (W1-e): merge refused — MS04 and **MS05** (2026-11-12 closure row); IT-28 / IT-30 |
| W1 skipped in MS04 | Verdict rows marked INCONCLUSIVE or “shipped note agrees” in `closures.md` (e.g. glide lock, many W1-d halves, W1-e menu doc-only) |
| Closures | **26** `closures.md` rows cite **`W1-a` … `W1-g`** result files (2026-11-07/08 apply; one **2026-11-12** MS05 blocker row for menu OAM wording) |
| Docs | This summary; some hand-written docs were left outside the MS04 scope and are listed in its log; the later documentation pass (`CO12_docs.md`) corrected part of them |
| Procedure | Dry-run merge/names → apply → `extract:lt` → `rebuild` → read-back per **MS04_apply.md** |

See **`plans/extracted-audit/mesen2-results/MS04_apply.md`** for the per-result-id file:line table (rows **W1-a** through **W1-g**).
