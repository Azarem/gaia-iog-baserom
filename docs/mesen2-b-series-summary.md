# Mesen2 B series: collision, special tiles, ramps, glide and wall snaps (B1 to B5, Z2-c)

Runtime and static investigation of the US ROM collision layer, quadrant tile types (`$06` / `$09`, slopes, ramps), scene-built versus post-load rewrites, player movement probes, ramp launchers, slider glides, boosters and wall-snap geometry. Compiled 2026-11-12 from `plans/extracted-audit/mesen2-results/B1_20261030.md`, `B2_special_tiles_20261029.md`, `B2_20261030.md`, `B3_20261030.md`, `B4_20261030.md`, `B5_20261030.md`, `B_addendum_20261030.md`, `Z2-c_20261111.md`, `CO02_close_B.md`, and apply logs `MS01_apply.md` and `MS05_apply.md`.

ROM: O (vanilla, SHA-1 `38de0c84dd2bc3bdfc0a3d7ab0220c79b70887c3`) for B1 through B4, most of B5, B3 and Z2-c. B2 and `B2_special_tiles` also ran R builds (`2e4a88a3de6dd4bdefc23c0dd626b953c18fe808` R-b2; `795c7a8cb8924766d5c378ac1d92364d127e1d2a` R-plain on 2026-10-29). B5 session BA-43 compared O against R-b2 on the display-mode pulse. Server: Mesen2 MCP 0.5.2 for B1–B5 (October 2026); 0.6.0 for Z2-c. `CO02_close_B.md` is bookkeeping only (no emulator). The apply passes changed notes and docs only; rebuild gates report no ROM byte change (`MS01`: sha1 `2e4a88a3…`; `MS05`: sha1 `90a04067…`).

Sections: 1 Result in one page, 2 What was run, 3 Findings, 4 Shipped notes corrected, 5 Rules for patch authors, 6 Where the findings live in the docs, 7 Tools, states and files, 8 Tool and method lessons, 9 Open questions, 10 Apply log.

---

## 1. Result in one page

| Topic | Question | Verdict |
|-------|----------|---------|
| Collision data flow | Does the low nibble of every cell match the metatile flag table after load? | **Yes** in 209 of 214 single-layer scenes (510,976 cells, 0 mismatches); bit 9 never stays set on a used metatile word. VERIFIED-RUNTIME |
| Quadrant meaning | What are `$06` and `$09`? | **Diagonal-edge masks** (`$06` = top-right + bottom-left, `$09` = top-left + bottom-right); 145 scenes each, staircase edges and tower chamfers. Old WRAM table rows calling them south/north walls are **CONTRADICTED**. VERIFIED-RUNTIME |
| Post-load layer | Who changes the layer after `RebuildCollisionLayer`? | **Five scenes** (`$55`, `$6B`, `$78`, `$D6`, `$D7`) via COP collision ops, actor code and `CollisionLayerRenderer` (up to 2,208 cells). Dual-layer overlay: nonzero layer-1 flag wins (0 mismatches in 9 scenes). VERIFIED-RUNTIME |
| Map modulus | What is `$069A`? | **Byte count of the map index stream** = (bounds X / 16) × (bounds Y / 16) in all 228 rows; 83 scenes have a non-power-of-two bound so `AND bounds−1` is not universally exact. VERIFIED-RUNTIME |
| Column refresh wrap | What does `CameraFullRefresh` render at widths 768 / 1024 / 1280? | Measured refresh pairs and hidden-half hashes: stride-5 width 1280 keeps columns 16–31 stale at arrival but **scroll-left corrects** column by column (0 visible stale in 122 frames). Other widths 256 / 512 / 1536 / 2048 not run. VERIFIED-RUNTIME (partial; positions SIMULATED) |
| Player on `$06` / `$09` | Push on a single painted tile on the player's row? | **16 px north** (`$06`) or **16 px south** (`$09`) at 2 px per frame for 8 frames; row above/below has no effect. VERIFIED-RUNTIME |
| Actor pair patterns | `CheckActorOnSpecialTile` paired cells with flag `$0008`? | Paired `$06` or `$00`+$09` layouts **exit with carry set**; every variant with carry clear fails. NPC test **SIMULATED** (bit forced). Player uses separate handlers. VERIFIED-RUNTIME / SIMULATED |
| FineAdjustXEast teleport | When does X wrap to 7 at `$02` = 17? | Needs a **vertical `$06` pair** and **odd probe Y** (185–191); painted control teleports ~360 px west. Real-map walks on `$53` / `$70` / `$6B` never reach `$02` > 15 (solid left cell cancels the slide). VERIFIED-RUNTIME (mechanism); INCONCLUSIVE (normal play reach) |
| Wall snap choice | Why `SouthWallSouthInteract` uses `SnapYNorthCollision`? | With `$24` = 0 the snap lands on the **next row line** (same as finishing a south step); `SnapYSouthCollision` would pull 16 px north. Intent undecidable. VERIFIED-RUNTIME |
| `$03` / `$0C` columns | Diagonal slope names versus motion? | **Vertical only**: `$03` pushes south, `$0C` north; `slopeFracAccum` gives ~56% speed at `$24` = −8. Which diagonal a name means is not settled. VERIFIED-RUNTIME (partial) |
| Ramp stage-2 equality | When does the east/west ramp fire stage 2 on the ramp coordinate? | When a **wall or slope stops the player on the coordinate** (191/192 Great Wall, 16/16 Itory pocket); on open ground 3/16; 7–12 px short **waits** with no timeout; 16+ px disarms. VERIFIED-RUNTIME |
| Ramp launch arc | How far and how long? | Type 1: **64** locked frames, first free frame **519–520** px from launch X (dy 0, peak 204). Type 3: **32** frames, **263–264** px (dy +8, peak 50). N/S loops **9** frames / 64 px or **5** / 32 px; anims `$24`/`$21`/`$1E`/`$19`. VERIFIED-RUNTIME |
| Booster | When does the large ramp boost fire? | Once per approach inside a **32-px** box, re-arms after **> 48** px away; writes **`playerSpeedEw` only**; with NS-only speed EW becomes +1 for one frame. VERIFIED-RUNTIME |
| Slider glide | South / north triggers? | **112 px / 28** frames or **128 px / 32** frames plus 16 finish frames, landing on a free row (24/32 south, 24/24 north). East/west on scene `$62`: **128** px, **48** locked frames, lateral window −7..+24 (B5). VERIFIED-RUNTIME (partial on E/W name) |
| Slope probe order | `MapCellDown` / `MapCellUp` on `$06` / `$09`? | Below tested first; returns `$00±$10` relative to `$00` unchanged; `$05` below reached the handler 12/12 (moving probe). Stopped latch stores index after `MapCellDown` with page carry (`$04F7`→`$0907`). VERIFIED-RUNTIME |
| Parked scratch `$24` | Where is `$24` parked at function entry? | **`$05,S`** for listed east/west routines (24/24, 66/66, …); contract text in `player_move_west.asm` is correct. VERIFIED-RUNTIME |
| Deceleration counters | Do reset hooks fire on shipped curve? | **0/13** on the shipped curve; **4/4** when the EW curve is patched to 3 and counters poked (flat ground). NS clearing EW counter after EW reset looks like copy slip (intent open). VERIFIED-RUNTIME (patched) |
| Speed clamp | `ClampSpeeds` vs NS? | EW clamped always; NS clamped **only when EW is zero** (EW +5 / NS +12 leaves NS at 12). Later NS→0 without `DecelerateNS` is the **wall snap**. VERIFIED-RUNTIME |
| Corner snap `$05` | Does `WestRampUp` corner arithmetic run on real maps? | **`$53`**, **`$23`**, **`$4F`**: 18–19 `WestRampUp` ticks, 1–2 corner snaps per 50-tick east walk into a `$05` column with solid east neighbours. Supersedes “synthetic stair only”. VERIFIED-RUNTIME (SIMULATED arrival) |
| `$0A` corner snap | Net motion against a wall? | `$26` gains 8,4,4 sub-pixels; player slides **south 2 px/tick** along the wall. VERIFIED-RUNTIME |
| Published probe bytes | Do vertical probes read `$14`/`$16` between phases? | **CONTRADICTED premise**; tick writes `$1014–$1017` between phases with no reads until rewrite; readers listed (camera, interaction, depth sort). VERIFIED-RUNTIME |
| World map NMI | Does scene `$FE` advance `$36`? | **0** `NmiHandler` execs and **0** `$36` writes in 100 frames (NMI off). VERIFIED-RUNTIME |
| Slope flag bit | When is `playerFlags` `$1000` set on stacks? | From stack depth **`d` ≥ 8** on `$03`/`$0C` columns (`$09AE` bit `$10`). VERIFIED-RUNTIME |

Counts: **50 closure rows** in `closures.md` name these reports (October–November 2026 rows; later rows supersede earlier INCONCLUSIVE halves where noted). Shipped notes: **dozens of sentences** narrowed or corrected (collision types, ramps, glide, movement, scene build); **`docs/wram-memory-map.md`** collision table rewritten. The campaign changed **0 ROM bytes** on the measured apply gates.

What changed in what we believe:

1. **The collision low nibble is a quadrant mask**, not a facing-specific wall type; `$06` and `$09` are the two diagonal-edge cells, and `$0F` is the common fully flagged cell, not merely an out-of-bounds sentinel.
2. **The layer is one merged map at `$7F:C000`**, rebuilt from metatile flags, overlaid in nine dual-layer scenes, then patched in five single-layer scenes by scripts and actors.
3. **Player wall slides and ramp corners are measurable**: teleport-to-X=7 needs a `$06` pair and odd Y; real maps usually stop the slide earlier; `WestRampUp` corner snap runs on real `$05` columns in several rooms.
4. **Ramp equality and glide distances are statistics**, not guaranteed by step size—walls and slope cells stop the player on the ramp coordinate; south/north glides are 112/128 px plus 16 finish frames; east/west glides are 128 px in the drained Mu scene.
5. **NS speed hitting zero against a solid row is the wall snap**, not mysterious deceleration; the between-phase publish of probe positions is real and has named readers.

---

## 2. What was run

| Step | Ids-or-topic | Method | Volume |
|------|--------------|--------|--------|
| B1 | Layer census, data-flow check | Quick warp all 228 scene ids; per scene 6 frames, `gaia.coll.census` + `verifyFlow`; 223 valid rows; adjacency counts; 290 screenshots beside `$06`/`$09` cells; states S13/S14 | 538,112 cells; 510,976 compared in flow check |
| B2 special | Single-tile player push | Paint one cell south of player on S01r; east hold 40 frames; types `$06` `$09` `$05` `$0A` `$0F`; O and R-plain twice each | 16 cases × 2 ROMs |
| B2 | Synthetic walks, wall slides, ramps | `b2_kit` trials on S01r (O and R-b2); painted geometry for slopes, snaps, flags; hooks on ramp corners | Multi-suite per id; R agrees on every sampled frame |
| B3 | Natural terrain, COP forge, pairs | S13 Itory slopes; S14 Great Wall; `wprobe` / `wcorner` / `dir` suites; decel curve ROM patch with restore; forged COP programs for `AdvanceMapY` and rectangles; NPC with `$10` bit `$0008` forced | 26 raw suite lines; COP cases on disposable state |
| B4 | Ramps, glide, booster, MapCell | States S14b–S14g; equality approaches Great Wall + Itory; launch arcs; animation index hooks; booster scene `$22`; slider scene `$B5`; `MapCellDown` moving probe | 38 final raw rows; each case twice |
| B5 | Addendum, 44 numbered checks | Layer write watch; dual-layer overlay check; Mu `$62` drained + glide E/W; hitbox type sweep; `$B5` third triggers; stopped latch; header census 228 scenes; iframe stepping; display-mode O vs R-b2 | States S14h/S14i/S14g + B4 states |
| Z2-c | Real-map wrap, pairs, `$05` corner | `z2c_kit`; warps to `$01` `$D5` `$23` `$0A` `$53` `$70` `$6B` `$4F`; column VRAM hashes; 135 south walks on real `$06` pair; east walks into `$05` columns | 3 new save states; server 0.6.0 |
| CO02 | Note specs from B reports | Read live `extracted/`; `CO02_notes.json` dry-run; merged later in MS05 | No emulator |

Every runtime step used a **`$36` write positive control** (or documented why not, e.g. scene `$FE`). Static preludes (`extracted/` reads, layer dumps) back absence claims where the session did not run.

---

## 3. Findings

### 3.1 Collision layer and types (B1, B5)

- Layer base **`$7F:C000`** (DP `$80–$82` points here during play): 256-byte pages, 16×16 cells, index `(((ty>>4)*stride + (tx>>4)) << 8) | ((ty&15)<<4) | (tx&15)`, stride = `$0693`.
- **`BuildMetatileFlagTable`** lifts metatile word bit 9 into the flag table nibble (bit 0 = first tile of the 2×2 metatile); **`FillCollisionFromLayer0`** copies into the layer; **`OverlayCollisionFromLayer1`** replaces when layer-1 flag ≠ 0 (nine dual-layer scenes, `$06EF` bit 0).
- Type census over 223 scenes: `$0F` 265,381 cells; `$0E` 87,605 (three quadrants, solid); `$06` 3,347 / `$09` 3,238; `$05`/`$0A` stacks capped by `$06`/`$09` (220/238 south neighbours).
- Five scenes diverge from the flag table after load (writers traced in B5): COP **`MarkCollisionRect`** / **`ClearCollisionRect`** (`$80:B303`…), **`MarkSolidAbs`** / **`ClearTypeAbs`**, **`av6C_portrait3`**, **`CollisionLayerRenderer`** at `$09:BBB1` (17,472 writes on `$D7`).
- Scene **`$FE`** (world map): NMI disabled → **no `$36`** increments.

### 3.2 Player on special tiles (B2 special, B2, B3, B5)

- **Single cell on player's row**: `$06` → 16 px north at 2 px/frame × 8; `$09` → 16 px south; must be same row as feet.
- **`FineAdjustXEast`**: reached with **`$02` = 17**; X becomes **7** (~360 px west) with a **two-row `$06` stack** and odd Y 185–191; even Y or Y ≥ 192 slide without teleport; **`FineAdjustXWest`** on `$09` does not wrap.
- **`WallSlidePushDown`**: **`$02`** = east-probe depth into `$09` cell (8 at X 366, +2/tick thereafter); first push equals depth.
- **`SouthWallSouthInteract`**: ends in **`SnapYNorthCollision`** with `$24` = 0 → next row line (+16 px south when flush).
- **`$03` / `$0C` columns**: vertical push only; **`NorthSlopeLeft`** filtered through **`slopeFracAccum`** (~56% at `$24` = −8).
- **`CheckActorOnSpecialTile`**: paired patterns verified with **`$10` bit `$0008`** on an existing NPC (SIMULATED); not called by the player controller.
- **Real-map pair walks (Z2-c)**: scene **`$53`** pair (26,52–54): 135 south walks, **`$02` ≤ 15**, stop with left foot on solid `$0E`; painted open pair control reaches 17 and teleports.

### 3.3 Slopes, ramps and probes (B2, B3, B4, B5, Z2-c)

- **Parked `$24`**: at **`$05,S`** for `CancelVerticalPhase`, `AutoAlignNS_East`, `ComputeWallSlidePush`, `AutoAlignYToGrid` (S+5 → `$06,S` after PHP), and S+3 for ramp descend routines (24/24 or 12/12 hits).
- **Moving probe** at **(actor X, actor Y − 8)**; **stopped latch** at **(actor X − 8, actor Y − 16)** (263/263 and 11/11 events).
- **`MapCellDown` / `MapCellUp`**: test **below first**; return `$00 + $10` / `$00 − $10`; stopped phase stores **`$00`** after `MapCellDown` (page carry example `$04F7` + down = `$0907`).
- **East/west dispatch**: `FindSlopeForEastMove` / `FindSlopeForWestMove` hooks match shipped operands (`$05` A=5 P=`$27`, `$0A` A=10 P=`$26`, flat A=0 P=`$A4`).
- **Ramp equality (B4)**: stage-2 fires when stopped on ramp coordinate by wall/slope; **7–12 px** short waits indefinitely in measured band; **16 px** disarms.
- **Launch (B4)**: EW lock **64** (type 1) / **32** (type 3) frames; land **519–520** or **263–264** px from launch X; N/S loops **9/5** frames, **64/32** px.
- **Booster (B4)**: **32-px** gate, **48-px** re-arm; only **`$09B2`** written.
- **Glide (B4, B5)**: south/north measured on scene **`$B5`**; east/west **128 px**, **48** locked frames, dy −7..+24 on drained Mu **`$62`**; `$B5` third triggers south **144** px / 52 frames, north **160** / 56.
- **`WestRampUp` corner (B3, B5, Z2-c)**: Itory natural east walks **0** corner hits in 5 cases; **synthetic `$05` stair against wall** and **real columns** in **`$53`/`$23`/`$4F`** reach corner label **186943** (1–2 fires per walk).

### 3.4 Speed, publish and COP collision (B3, B5)

- **`ClampSpeeds`**: NS examined only if EW is zero (EW 0 / NS +12 → NS 8; EW +5 / NS +12 → NS stays 12).
- **Deceleration reset hooks**: 0 fires on shipped curve; fire when curve patched and counters set (flat ground only).
- **Speed writers (Shadow scene `$15`)**: `SnapYSouthCollision`, slope curves, `DecelerateEW`, walk run entry points; NS zeroed by wall snap (`$82:D3FD` / `D0C2`).
- **Between-phase publish**: **`$1014–$1017`** written mid-tick; readers include **`BranchIfPlayerNear`**, tile branch COPs, **`CameraScrollUpdate`**, **`PlayerMoveSync`**, **`RunInteractionCollision`**, **`SortActorsByDepth`**, **`DecomposeActorMetasprites`**.
- **`AdvanceMapY`**: failure when a horizontal **page edge** is crossed mid-rectangle (e.g. stride 5 start (15,3) second row at (31,4) not (15,4)); **`$069A`** equals map byte count.
- **`TileCollisionQuery`**: paint uses **`y >> 4`**; hitbox **Y offset −16** in 16/16 Y phases at −16 (census **306** headers `F8 F0 01 01`, Y −32 in five scenes; banks **`$7E`** and **`$8E`**).
- **`BranchIfBehindWall`**: single merged layer; layer-aware actor bit selects paths with identical visibility outcome (code read, not run).
- **`PlayerFallFromHeight`**: Y **unchanged** from frame 43 through 150 at tested entries (432 / 288 cases).
- **Iframe counter**: stepped in **`RunActors_Normal`** at **`$83:CB46`/`CB4F`** (not bank `$82` as first traced).

### 3.5 Camera column wrap (Z2-c)

- At right-edge arrival, camera target **clamped to bounds − 256**.
- Refresh column sequences: width **768** `32..47` then `16..31`; **1024** `48..63` then `0..15`; **1280** `64..79` then `16..31` (hidden half stale at arrival for 1280; scroll-left fixes hashes column-wise).
- Stride values **256, 512, 1536, 2048** not measured (stride-7 scenes do not exist in dump).

---

## 4. Shipped notes corrected

| Place | Old statement | Verdict | New statement |
|-------|---------------|---------|---------------|
| `docs/wram-memory-map.md` collision rows | `$06` / `$09` as south/north walls; `$0F` as out-of-bounds only | CONTRADICTED | Diagonal-edge quadrant masks; `$0F` is the common full cell; measured census and geometry |
| `tile_collision_physics.asm` block | Types `$06`/`$09` not traced to a purpose | CONTRADICTED / narrowed | Diagonal edges; pair-pattern measured results retained with “why (+X,+Y)” still open |
| `player_move_*` block notes and comments | “wall-like”, “undecoded wall type”, blanket UNVERIFIED-RUNTIME | CONTRADICTED | Diagonal-edge wording; measured pushes, depths, parked `$24`, publish behaviour |
| `scene_script.asm` parts | Overlay and flag-table phrasing incomplete | narrowed | 209/214 match; five post-load scenes and nine overlay scenes measured |
| `cop_handlers_collision.asm` `AdvanceMapY` | Page of last tile “inferred” | CONTRADICTED | Measured A/page behaviour and rectangle failure modes |
| `ramps.asm` block | Static arc estimates; equality “not checked” | CONTRADICTED | Measured arcs, loops, equality statistics and short-distance wait bands |
| `large_ramps.asm` block | Booster UNVERIFIED-RUNTIME | CONTRADICTED | 32-px gate, 48-px re-arm, EW-only write |
| `slider_glide.asm` block | No measured glide lengths | narrowed | South/north px and frames; east/west from B5 on `$62` |
| `slope_ramp_physics.asm` block | Open questions on probe order, clamp, stopped probe | narrowed | Below-first order, clamp cases, two probe points, stopped index store |
| `player_move_south.asm` `FineAdjustXEast` | Wrapped X without conditions | narrowed | Pair + odd Y; real maps do not reach `$02` > 15; painted control documented |
| `player_move_ramps.asm` block | `$05` corner only on synthetic stair | CONTRADICTED by Z2-c | Corner reached on scenes `$53`, `$23`, `$4F`; natural Itory stair still 0 hits |
| `camera_tilemap.asm` `CameraFullRefresh` | Wrap modulus inferred; on-screen wrap open | narrowed | Per-width refresh sequence and 1280 scroll-left behaviour |
| `player_transition_handlers.asm` | Fall Y not checked; `$04` terrain vague | narrowed | Exact landing Y; `$04` in ten pyramid/mine scenes |

Dry-run items listed in `CO02_close_B.md` that did not ship until **MS05** include ramp short-distance bands, scene room names in `large_ramps.asm`, and NorthEntry glide facts left partial by B5 itself.

---

## 5. Rules for patch authors

1. **Treat collision types `$06` and `$09` as diagonal-edge quadrant masks**, not facing-specific walls; actor pair tests use `CheckActorOnSpecialTile` with flag `$0008`, while the player uses `player_move_*` handlers directly.
2. **Do not assume the built collision layer is final** in scenes `$55`, `$6B`, `$78`, `$D6`, `$D7`, or in dual-layer scenes without reading the merged layer rules (`$06EF` bit 0, layer-1 nonzero wins).
3. **Staging adhoc or probe reads must respect the below-then-above rule** on `$06`/`$09` (`MapCellDown` before `MapCellUp`); stopped-on-slope code paths store the down-probe index separately from the moving probe at Y−8.
4. **Ramp stage-2 equality is not a free invariant**: patch authors placing custom ramps must allow walls or slope cells to stop the player on the ramp coordinate, or expect waits when the approach stops 7–12 px short.
5. **Booster and slope speed hooks write `playerSpeedEw` only**; do not expect `playerSpeedNs` to receive the booster impulse; re-arm requires the player to leave a 48-px radius.
6. **Slider glides clear attack collision (`$10` bit `$0008`) and move 4 px/frame without tile tests** in the glide routine; do not rely on wall collision during the glide phase when extending Psycho Slider behaviour.
7. **`FineAdjustXEast` X=7 teleport requires a vertical `$06` pair and odd probe Y**; a single `$06` cell or even Y will not reproduce the wrap—test with painted pairs before assuming real-map geometry will fire it.
8. **Use `ClampSpeeds` logic when poking speeds**: NS clamp applies only when EW is zero; an NS drop to zero against a solid row is wall snap, not `DecelerateNS`.
9. **Camera full refresh wrap is width-dependent**; patches that scroll non-power-of-two maps (stride 5/7) should not assume the hidden nametable half matches neighbours until the camera scrolls across those columns (measured on width 1280).
10. **Button masks in this baserom build**: physical **A** feeds logical **`$8080`** (interact `$8000`, attack `$0080`); physical **B** feeds **`$4008`** (cancel `$4000`, item use `$0008`). Name the build when documenting input; vanilla O uses different remaps (see C series summary).

---

## 6. Where the findings live in the docs

| Topic | Document |
|-------|----------|
| Quadrant mask, type table, `$069A`, post-load scenes | [`wram-memory-map.md`](wram-memory-map.md) (§4.10 Collision Layer) |
| Layer build, overlay, flag table | [`code/bank02/scene-script.md`](code/bank02/scene-script.md), [`code/bank02/tile-collision.md`](code/bank02/tile-collision.md) |
| Movement handlers, wall slides, snaps | [`code/bank02/player-movement.md`](code/bank02/player-movement.md) |
| Slope physics, probes, clamp, MapCell | [`code/bank02/slope-ramp-physics.md`](code/bank02/slope-ramp-physics.md) |
| Ramp watch, arcs, equality, placement | [`code/bank00/ramp-launchers.md`](code/bank00/ramp-launchers.md) |
| Slider triggers and glide lengths | [`code/bank00/slider-glide-system.md`](code/bank00/slider-glide-system.md) |
| `CameraFullRefresh`, wrap modulus, column strips | [`code/bank02/camera-scrolling.md`](code/bank02/camera-scrolling.md) |
| COP paint, `AdvanceMapY`, hitbox headers | [`cop/families/collision_paint.md`](cop/families/collision_paint.md) (referenced from B3; collision COP behaviour also in extracted `cop_handlers_collision.asm` notes) |
| Fall landing and hidden-player flag | [`wram-memory-map.md`](wram-memory-map.md) (playerFlags bit `$2000`), [`code/bank00/actors-player-rewards.md`](code/bank00/actors-player-rewards.md) (`PlayerFallFromHeight`) |
| Iframe counter in main loop | [`code/bank02/player-character.md`](code/bank02/player-character.md) |
| Scene counts and ramp tables | [`code/bank00/data-tables-memory.md`](code/bank00/data-tables-memory.md), [`bank01-data-tables.md`](bank01-data-tables.md) |

---

## 7. Tools, states and files

All under `plans/extracted-audit/mesen2-results/` unless noted.

| Kind | Files |
|------|-------|
| Lua kit modules (`kit/lib/`) | `gaia_kit.lua` (`coll.census`, `coll.verifyFlow`, trials); `b2_kit.lua`, `b3_kit.lua`, `b4_kit.lua`; `z2c_kit.lua` (Z2-c) |
| Python harness (`harness/`) | `scenario_b1_census.py`, `b1_report.py`, `b1_adjacency.py`, `b1_states.py`; `scenario_b2_special_tiles.py`, `scenario_b2.py`; `scenario_b3.py`; `scenario_b4.py`, `b4_states.py`; `b5_common.py`, `b5_ba01.py`–`b5_ba44.py`, `b5_layers.py`, `scenario_b5.py`, `scenario_b5w.py` |
| Draft / apply specs (`specs/`, `edits/`) | `B1_notes.json`, `B3_notes.json`, `B4_notes.json`, `CO02_notes.json`, `Z2-c_notes.json`; applied merges `MS01` → `B4_notes.json`; `MS05.json` (CO02 + Z2-c union) |
| Save states (`rebuilt/states/`, `states-index.md`) | `orig_S01r_south-cape-ready.mss`; `orig_S13_slope-field.mss`, `orig_S14_ramp-scene.mss`; `orig_S14b`–`S14g` (B4); `orig_S14h_mu62-drained.mss`, `orig_S14i_*`, `orig_Z2c_s53_corner-pair.mss`, `orig_Z2c_s23_corner.mss`, `orig_Z2c_sD5_right-edge.mss` |
| Raw output (`raw/`) | `B1_census_O_*.json`, `B1_flow_O_*.json`, `B1_adjacency_O.json`; `B2_*`, `B2_special_tiles_*`; `raw/B3/`, `raw/B4/`, `raw/B5/`, `raw/Z2c_*`; screenshots `raw/screenshots/B1_*`, `Z2c_*` |
| Reports | `B1_20261030.md` through `B5_20261030.md`, `B2_special_tiles_20261029.md`, `B_addendum_20261030.md`, `Z2-c_20261111.md`, `CO02_close_B.md`, `closures.md` (50 B-series rows), `MS01_apply.md`, `MS05_apply.md` |

---

## 8. Tool and method lessons

- **Paged collision index** is mandatory: flat `row*stride+col` formulas mis-index; use the B1/B2 kit form with stride `$0693` and 256-byte pages.
- **Quick warp** must wait the full scene load (~300 frames) and confirm `$0644` before reading the layer; short waits leave the previous map in WRAM.
- **Positive control**: count writes to **`$36`** each run; scene **`$FE`** legitimately fails—do not treat that row as a broken control.
- **Painted cells** isolate one type without a level editor; pair controls must reset collision bytes before the next scene load so saved states stay clean.
- **Forged COP programs** in a disposable actor slot exercise `AdvanceMapY` and rectangle paint without polluting real scenes; X must equal actor slot before every COP.
- **ROM patch for decel curve** must be restored and verified (`curveRestored`) so rebuild gates stay clean.
- **Server 0.5.2 vs 0.6.0**: Z2-c uses `warpFast` and reliable state sidecars; banner wait on scene **`$D5`** without dismissing game-over timing wastes frames (T-89).
- **R vs O on display-mode bit 3**: holding **physical B** while moving right shifts the pulse pattern by one frame on R-b2 only (cause not traced); document build when comparing HUD timing.
- **Dual-layer scene `$62`**: drained-state collision matches gameplay layer for glides; base-layer census alone is misleading.
- **Merge hygiene**: `B4_notes.json` and combined specs must not re-merge prefix sentences already applied; `player_move_west` full-text B3 spec would revert later edits—do not re-apply `B3_notes.json` wholesale.

---

## 9. Open questions

1. Why does `CheckActorOnSpecialTile` require the (+X,+Y) neighbour for the paired pattern (carry logic traced; motivation not)?
2. Why do west and east handler files use opposite “north”/“south” naming words (naming only)?
3. Which probe results on natural terrain reach which handler entry points (write-trace on S13/S14/South Cape not run)?
4. Whether individual quadrant bits within a single cell resolve at runtime for `$03`/`$08`/`$0C`/`$05`/`$0A` (type-level sweep done; per-quadrant solid not).
5. Whether a dropped pickup on a `$0E` row uses the same probe rules as the player (no drop test).
6. Whether aura landing scan terminates in rooms with no `$04` floor tile (213 scenes lack `$04`).
7. Other map widths for `CameraFullRefresh` `AND #$0100` wrap (256, 512, 1536, 2048) and whether the one-frame-late entering column on width 1280 ever appears on screen (PPU scroll not read reliably).
8. Whether any real door route places the player on an odd-Y `$06` pair or on Itory `$05` stair for a natural corner snap (open floors reached by poke only).
9. Why the between-phase publish of `$1014–$1017` sits between movement phases (readers known).
10. East/west slider “stair” naming and **`NorthEntry`** glide 52 px on scene `$72` (nudge not confirmed).
11. Climb animation pose content for indices `$21`/`$24`/`$19`/`$1E` (indices and loop lengths measured only).
12. Booster suite on scene **`$41`**, flat-ground booster gate, scene **`$21`** ramp blocked 16 px short, and 1–6 px / 13–15 px ramp short bands (partially measured at 7–12 px).
13. Whether clearing attack bit `$0008` during slider glide changes outcome (glides run without that A/B comparison).
14. Who calls `CheckActorOnSpecialTile` on a moving NPC in gameplay (0 calls in 1,500 idle frames on two towns).
15. R-b2 one-frame delay of `displayModeFlags` bit 3 after **physical B** while holding right (O unchanged).
16. Credits scene **`$F7`** `$06`/`$09` pairs and other map widths (Z2-c INCONCLUSIVE halves).

---

## 10. Apply log

| Step | What wrote | Extracted / docs | Gate |
|------|------------|-------------------|------|
| B1 / B3 (pre-MS01) | `B1_notes.json`, `B3_notes.json` applied in tree before MS01 | `tile_collision_physics.asm`, `camera_tilemap.asm`, movement blocks, `wram-memory-map.md` §4.10 | prior tagged build |
| **MS01** (2026-10-30) | `specs/B4_notes.json` → merge | `ramps.asm`, `large_ramps.asm`, `slider_glide.asm`, `slope_ramp_physics.asm`; new/updated docs `ramp-launchers.md`, `slider-glide-system.md` path peers, `tile-collision.md`, `slope-ramp-physics.md`, `data-tables-memory.md`, `bank01-data-tables.md`, README indexes | sha1 `2e4a88a3de6dd4bdefc23c0dd626b953c18fe808` unchanged |
| **CO02** (2026-11-11) | `CO02_notes.json` dry-run only; 29 closure rows drafted | Not applied until MS05 | sha1 `90a04067…` gate (no note change at CO02) |
| **MS05** (2026-11-12) | `edits/MS05.json` (CO02 B corrections + Z2-c; drops superseded `player_move_ramps` CO02 sentence) | 29 extracted files: scene_script, cop collision/flags, all `player_move_*`, `player_move_ramps`, `camera_tilemap` comment 175102, transition handlers; 11 new closure rows naming MS05 | sha1 `90a04067dd5b5284bd9e152ad222df0e65d08979` unchanged |
| This file | Series summary | `docs/mesen2-b-series-summary.md` | documentation only |

Counts: **MS01** — 4 block notes + 8 doc files; **MS05** — 54 note updates across 13 notes files for the B-related slice (full MS05 includes non-B items). **Closures**: 50 rows cite B-series result files (including Z2-c and the MS05 application row); October rows for B4-only ids remain alongside November superseding rows for paired-pattern and corner geometry.

Remaining note gaps called out in sources: **`B_addendum` BA-N1–N4** blanket UNVERIFIED lines on three `player_move_*` blocks (partial facts in B5 §3 but no merge); **`player_move_ramps.asm`** still says crossing arithmetic of some ramp routines is not traced; **`docs/code/bank02/player-movement.md`** carried the old `FineAdjustXEast` wording after MS05 and was corrected in the later documentation pass.
