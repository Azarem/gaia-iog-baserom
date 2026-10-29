# Bank $00 — Thinkers: Palette Cycling & One-Shot Flashes

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00B520`–`$00B808` (live palette thinkers through `oneshot_palette15_grey_fade_in_1F`; three **dead** stubs in `extracted/unused/` ending at `$00B808`)  
**Block type:** `thinker_def` — background processes running in parallel with actors  
**Priority:** All thinkers in this family use thinker-def priority `#08` (filter word `#0800` on `$7F000E`)  
**Related:** [`README.md`](README.md), [`thinkers-hdma.md`](thinkers-hdma.md), [`thinkers-system.md`](thinkers-system.md)

Thinkers are COP-scripted background processes. The **ambient palette** family drives ongoing color animation via `PaletteRestart` / `PaletteStart` / `PaletteStep`, direct `$COLDATA` tint writes, and occasional **spawned child thinkers**. **One-shot** thinkers (palette bundles or fixed `$COLDATA`) run a finite script and `KillThinker`, or are spawned from actor cutscenes at runtime.

---

## Source of truth

Primary extracted files:

| Role | Path |
|------|------|
| Ambient / one-shot thinker scripts | `extracted/thinkers/*.asm`, `extracted/gold_ship/dream/dream_palette_loop.asm`, `extracted/edward_castle/edward_castle/edward_castle_alarm_palette.asm`, `extracted/seaside_palace/palace_fountain/palace_fountain_palette.asm`, `extracted/watermia/watermia/watermia_festival_palette.asm` |
| Scene static spawns | `extracted/tables/scene_thinkers.asm` (256-scene pointer table + `thinker-spawn` lists) |
| Runtime spawns | Actor `.asm` under `extracted/` (`COP [SpawnThinker]` / `SpawnThinkerParam`) |
| Palette COP handlers | `extracted/system/engine/cop_handlers_palette.asm` |
| Bundle data | `extracted/tables/palette_bundles.asm` |
| Dead stubs | `extracted/unused/palette_buffer_clear_unused.asm`, `babel_palette_65_unused.asm`, `palette_loop_flash_unused.asm` |

**Naming:** Section titles use extracted label names (e.g. `ambient_palette_cycler`, `GoldShipWreckPaletteFlag4D`). Scene indices like “slot `#01`” mean **index within that scene’s `thinker-spawn` list** in `scene_thinkers.asm`, not a universal thinker-pool slot ID.

**Counts:** `ambient_palette_cycler` — **59 static scene placements** (counted from `scene_thinkers.asm` this session). Other palette thinkers — counts below are **static scene placements** unless marked **runtime spawn references**. Scene IDs are **hex** as in the pointer table (`;E8` = scene `$E8`).

---

## Palette bundle semantics (source terms)

Palette animation is implemented in `cop_handlers_palette.asm` and `LoadPaletteBundle` / `CopyPaletteBundleFrame` (`hdma_dma_spc`). A **bundle ID** (one byte) selects a row in `palette_bundles`: a sequence of **6-byte sub-entries**. Each sub-entry describes one **strip**: frame count (byte 0), destination and color block layout, and a **wait** value (byte 5) for extra ticks between frames.

Per-thinker state (slot `X`): bundle ID in `animScratch+2` (`$7F0002,X` — for scene spawns this is usually the **`thinker-spawn` parameter byte**), sub-entry index in DP `$0E`, frames remaining in `spritesetPtr` (`$7F0006,X`).

| COP (extracted name) | Effect |
|----------------------|--------|
| `PaletteRestart` | Re-run sub-entry 0 of the bundle ID **already** in `animScratch+2` (does not load a new ID). |
| `PaletteStart` (#bundle) | Store bundle ID in `animScratch+2`, apply sub-entry 0, yield; script resumes on the **next** op (normally `PaletteStep`). |
| `PaletteStep` | Advance one tick of the current strip; yield until the bundle ends, then fall through. |
| `PaletteStartLoop` / `PaletteStepLoop` | Same as Start/Step but repeat the whole bundle for a **pass count** (only used outside this family in combat + one unused stub). |

**Visual interpretation** (backdrop vs CGRAM) depends on each bundle’s destination fields — see block notes on individual one-shot files. Bundles `#18`–`#19`, `#1B`–`#1C`, `#40` target **`backdropColors` `$7F0C00`** (NMI copies to `$COLDATA`); `#1F` writes **CGRAM** at `$F0` (palette 15). Decoded RGB descriptions in thinker headers are **source-derived** from bundle bytes, not re-verified frame-by-frame in this doc.

---

## Overview

| Category | Count | Address range (approx.) | Status |
|----------|-------|---------------------------|--------|
| Ambient / gated / scene palette loops | 9 | `$B520`–`$B754` | **live** |
| One-shot palette / COLDATA flashes | 8 | `$B65E`, `$B6E5`, `$B7CC`–`$B7FE` | **live** |
| Unused palette prototypes | 3 | `$B6FD`, `$B781`, `$B808` | **dead / unreferenced** |

### COP commands used in this family

| Command | Role |
|---------|------|
| `PaletteRestart` | Reset current bundle to sub-entry 0 (`ambient_palette_cycler` every loop) |
| `PaletteStart` | Select bundle ID (immediate operand) and apply first strip |
| `PaletteStep` | Advance palette animation one tick |
| `PaletteStartLoop` / `PaletteStepLoop` | Only in `palette_loop_flash_unused` (**dead**) |
| `BranchOnFlagByte` | Spawn-time or per-frame branches (see each thinker) |
| `WaitOnFlagByte` | Park until an event flag reaches a value (often latch `$FF`) |
| `SetFlagByte` | Set event flag (often `$FF` scene-setup latch) |
| `SpawnThinker` | Launch child thinker (`palette_parent_child`, `watermia_festival_palette`) |
| `KillThinker` | Remove thinker slot (one-shots and failed spawn gates) |

There is **no** `ExitIfFlagByte` opcode in `copdef.json`; gated loops use `WaitOnFlagByte` and `BranchOnFlagByte`.

---

## Ambient palette cycles

### ambient_palette_cycler — **live**

**Address:** `$00B520`

#### Purpose

Minimal infinite palette loop: **`PaletteRestart` then `PaletteStep` every iteration**, then `BRA` (not a one-time restart). The bundle ID is the scene **`thinker-spawn` parameter byte** (stored in `animScratch+2` at spawn); the script never hardcodes a bundle.

#### Algorithm

```text
PaletteCycleLoop:
  PaletteRestart    ; sub-entry 0 of bundle in animScratch+2
  PaletteStep       ; yield until bundle completes
  BRA PaletteCycleLoop
```

#### Scene usage

**59 static scene placements** in `scene_thinkers.asm`. Examples (bundle param → scenes):

| Bundle param | Scene list / notes |
|--------------|-------------------|
| `#3F` | `thinker_spawn_0CE7EA` slot `#00` (shared list; many scenes enter at `+4` or `+8` and skip this record) |
| `#06`, `#07`, `#12` | `thinker_spawn_0CE82E` (scenes `$0D`–`$0F`, `$12`, …) |
| `#01` | `thinker_spawn_0CE98D` slot `#02` (Mu group scenes `$5F`–`$62`, `$64`, `$65`) under `mu_tint_and_wave` |
| `#47`, `#4F`, `#4D`, `#4E` | Watermia-adjacent lists (`thinker_spawn_0CE9BE`, `0CE9D4`, …) |
| `#71` | `thinker_spawn_0CEABA` slot `#01`, scene **`$E8`** (Comet Lair) |
| `#3E`, `#64` | `thinker_spawn_0CEB46` slots `#03`–`04`, scene **`$FF`** (inventory menu) |

Also **one runtime spawn**: `item_use_system.asm` → `SpawnThinkerParam` `#2F`, `@ambient_palette_cycler.PaletteCycleLoop` (not a scene-table entry).

Block note: per-bundle on-screen appearance was **not fully traced**; avoid treating example effect names (torch, water, sky) as verified.

#### Dependencies

None.

---

### flag_gated_palette_warm — **live**

**Address:** `$00B5C0`

#### Purpose

Applies palette bundle **`#02`** (single-strip, 80 colours at index `$30` per `palette_bundles` block note) in a loop, with a **spawn-time-only** gate on event flags **`#1C`** and **`#16`**. If flag `#1C` is set or `#16` is clear at spawn, the thinker **`KillThinker`** immediately and never enters the loop.

#### Algorithm

```text
BranchOnFlagByte #1C == 1 → KillThinker
BranchOnFlagByte #16 == 0 → KillThinker
loop:
  PaletteStart #02
  PaletteStep
  SetFlagByte #FF          ; scene-setup latch
  WaitOnFlagByte #FF, #00  ; until latch cleared
  BRA loop
```

Spawn parameter byte is **ignored** (bundle is immediate `#02`). In scene **`$30`** (Oakton), flag `#1C` is expected already set in extracted data, so the thinker **dies at spawn** (inferred from flag usage, not emulated here).

#### Scene usage

| Scene ID | Thinker list | List slot |
|----------|--------------|-----------|
| **`$01`** | `thinker_spawn_0CE80C+4` (skips `oneshot_coldata_r11g4b2`) | `#03` |
| **`$30`** | `thinker_spawn_0CE80C` | `#03` |

Same list as `oneshot_coldata_r11g4b2` and dual `ambient_palette_cycler` (`#01`, `#3F`).

#### Dependencies

None.

---

### flag_gated_palette_cool — **live**

**Address:** `$00B5DF`

#### Purpose

Same **spawn-time** gate as `flag_gated_palette_warm`, but bundle **`#4C`** (7 colours from index `$19`, single strip). Not a multi-strip ambient cycle.

#### Scene usage

| Scene ID | Entry into `thinker_spawn_0CE7EA` |
|----------|-----------------------------------|
| **`$03`–`$08`** | South Cape interiors (offsets `+4` or `+0` so `flag_gated_palette_cool` is slot `#01` when present) |

#### Dependencies

None.

---

### palette_parent_child — **live**

**Address:** `$00B5FE`

#### Purpose

Parent holds palette bundle **`#03`** at sub-entry 0 and **polls flag `#01` each frame** (`SetEntryHere` + `BranchOnFlagByte`). While flag `#01` is clear, parent yields without stepping. When flag `#01` is set, parent **`SpawnThinker`** **`PaletteParentChildWaveLoop`** (child), stores child slot in **`$7F000A,X`**, **`WaitOnFlagByte #01, #00`**, then **`KillThinker`** on the child slot and restarts at `loc_00B600`.

Child: infinite `PaletteStart #03` / `PaletteStep` until killed. Spawn parameter `#03` matches bundle id but the script **hard-codes `#03`** (parameter is redundant).

#### Scene usage

| Scene ID | List | Slot |
|----------|------|------|
| **`$FD`** | `thinker_spawn_0CEB30` | `#01` |
| **`$FF`** | `thinker_spawn_0CEB46` | `#02` |

Which actors set/clear flag `#01` in those scenes was **not traced**.

#### Dependencies

None.

---

### edward_castle_alarm_palette — **live**

**Address:** `$00B631`

#### Purpose

Alarm atmosphere: loop **`PaletteStart #05` / `PaletteStep`**, plus each iteration writes **`$COLDATA`** bytes **`#$24`** and **`#$42`**. Uses the same **`#FF` latch / `WaitOnFlagByte`** pattern as the flag-gated warm thinker.

**Spawn-time gate:** if flag **`#22`** set or flag **`#21`** clear at spawn → `KillThinker`. The main loop does **not** re-test `#21` / `#22`.

#### Scene usage

| Scene ID | List | Slot |
|----------|------|------|
| **`$0A`** | `thinker_spawn_0CE821` | `#01` |

#### Dependencies

None.

---

### gold_ship_wreck_palette — **live**

**Address:** `$00B671`

#### Purpose

Gold Ship wreck / adrift palette controller. **Phase selected once at spawn** (`BranchOnFlagByte` for `#52` then `#4D`); loops never return to those tests until the thinker is respawned (scene **`$2F`** reloads adrift days).

| Phase | Behaviour |
|-------|-----------|
| Default | `PaletteStart #1A` / `PaletteStep` forever (12-strip cycle on colours `$21`–`$2C`) |
| Flag **`#4D`** at spawn | `GoldShipWreckPaletteFlag4D`: bundle **`#34`** once, then loop bundle **`#33`** while latch **`#FF`** set |
| Flag **`#52`** at spawn | `GoldShipWreckPaletteFlag52`: kill **first two thinkers** in pool order (HDMA band thinkers in these lists), fill `$7F0A40`–`$7F0A5F`, set `$7F0A00`, apply bundle **`#36`**, latch **`#FF`** / wait |

Flags **`#4D`** / **`#52`** are driven by adrift actors (`dc2F_adrift`, etc.) per block note.

#### Scene usage

| Scene ID | List |
|----------|------|
| **`$2B`** | `thinker_spawn_0CE87F` slot `#02` |
| **`$2D`** | `thinker_spawn_0CE8A1` slot `#04` |
| **`$2F`** | `thinker_spawn_0CE890` slot `#02` |

Scene **`$2C`** uses `thinker_spawn_0CE87F+4` and does **not** spawn this thinker.

#### Dependencies

Direct WRAM palette buffer writes on `#52` path (`$7F0A40`, `$7F0A00`).

---

### dream_palette_loop — **live**

**Address:** `$00B6D2`

#### Purpose

Loop bundle **`#35`** with **`SetFlagByte #FF`** and **`WaitOnFlagByte #FF, #00`** each cycle — when latch **`#FF`** clears, the **same loop repeats** (does not fall through to `KillThinker` on that path).

#### Scene usage

| Scene ID | List | Slot |
|----------|------|------|
| **`$2A`** | `thinker_spawn_0CE7FB` | `#00` |

**Note:** `loc_00B6E2` (`KillThinker`) in the same thinker-def block is **unreachable** in the current extracted script (dead tail).

#### Dependencies

None.

---

### palace_fountain_palette — **live**

**Address:** `$00B71E`

#### Purpose

Sets **`$CGADSUB` ← `#$03`** each outer iteration, sets latch **`#FF`**, then **`BranchOnFlagByte #0F`**, **`BranchOnFlagByte #70`** to choose bundle **`#1A`** vs **`#25`**, `PaletteStep`, and loops while **`#FF`** remains set. Flag **`#0F`** triggers **`WaitOnFlagByte #0F, #00`** then resumes (not `KillThinker`).

#### Scene usage

| Scene ID | List | Slot |
|----------|------|------|
| **`$5D`** | `thinker_spawn_0CE984` | `#00` |

#### Dependencies

None.

---

### watermia_festival_palette — **live**

**Address:** `$00B754`

#### Purpose

On **first entry only**, `BranchOnFlagByte #96` may branch to **`WatermiaFestivalPaletteFlash`**: spawn child **`WatermiaFestivalPaletteWave`** (bundle **`#72`**, child ORs **`#$0800`** into `$7F000E,X`), parent loops bundle **`#48`**. Default path loops bundle **`#42`** forever and **never returns** to the `#96` test.

**Inferred:** festival flag **`#96`** must already be set when the thinker first runs, or the scene must respawn thinkers, for the flash path to run mid-visit.

Scene spawn record uses parameter **`#48`**; parent script **hard-codes** `#42` / `#48` / `#72` (parameter not read in the extracted loop).

#### Scene usage

| Scene ID | List | Slot |
|----------|------|------|
| **`$78`**, **`$7F`** | `thinker_spawn_0CE9AC` | `#01` |

#### Dependencies

None.

---

## One-shot palette & COLDATA flashes

One-shots either appear in **`scene_thinkers.asm`** (COLDATA tint thinkers) or are **`SpawnThinker`** from actors (bundle flashes). Bundle one-shots: `PaletteStart` → **`PaletteStep` until the bundle completes** → `KillThinker` (duration = bundle strip timing, not a single Step).

### oneshot_coldata_warm_flash — **live** (scene list)

**Address:** `$00B65E`

Writes **`$COLDATA`** **`#$66`** then **`#$82`** (R6 G6 B2 channel intensities), then `KillThinker`. No palette bundle.

| Scene ID | List | Slot |
|----------|------|------|
| **`$23`** | `thinker_spawn_0CE850` | `#02` |
| **`$27`** | `thinker_spawn_0CE872` | `#00` |

---

### oneshot_coldata_r11g4b2 — **live** (scene list)

**Address:** `$00B6E5`

Three **`$COLDATA`** writes: **`#$2B`**, **`#$44`**, **`#$82`** (R11 G4 B2), then `KillThinker`.

| Scene ID | List | Slot |
|----------|------|------|
| **`$30`** | `thinker_spawn_0CE80C` | `#00` |

Scene **`$01`** enters the same list at **`+4`** and **does not** spawn this thinker.

---

### oneshot_palette_flash_18 — **live** (runtime spawn)

**Address:** `$00B7CC`

Bundle **`#18`**: 32-frame **`backdropColors`** ramp (block note: toward bluish-white). **`KillThinker`** when complete.

| Actor script (extracted) |
|--------------------------|
| `babel_tower/comet_lair/sE8_dark_gaia.asm` |
| `angkor_wat/angkor_shrine_crystal/awBC_blinding_light.asm` |
| `angkor_wat/angkor_pinnacle/awBF_spirit_guide.asm` |
| `mu/mu_altar_room/mu66_rama_spirits.asm` |
| `itory/itory_village/it15_lily.asm` |

---

### oneshot_palette_flash_19 — **live** (runtime spawn)

**Address:** `$00B7D6`

Bundle **`#19`**: paired fade after `#18` (block note: via red to black). Same actors as `#18`, plus **`angkor_wat/future_vision/future_vision_cutscene.asm`** ( **`#19` only** ).

---

### oneshot_backdrop_fade_in_1B — **live** (runtime spawn)

**Address:** `$00B7E0`

Bundle **`#1B`**: 32×5 ticks, **`backdropColors`** black → near-white.

| Actor script |
|--------------|
| `mu/mu_prayer_room/mu63_spirits.asm` |
| `edward_castle/castle_prison/ec0B_cell.asm` |

---

### oneshot_backdrop_fade_out_1C — **live** (runtime spawn)

**Address:** `$00B7EA`

Bundle **`#1C`**: white → black counterpart to `#1B`.

| Actor script |
|--------------|
| `angkor_wat/snake_pit/awB4_snake_pit_entry.asm` |
| `gold_ship/ship_gold/gs2C_descent.asm`, `gs2C_crow_crew.asm` |
| `mu/mu_prayer_room/mu63_spirits.asm` |
| `edward_castle/castle_prison/ec0B_cell.asm` |

---

### oneshot_backdrop_fade_out_fast_40 — **live** (runtime spawn)

**Address:** `$00B7F4`

Bundle **`#40`**: 16×2 ticks fast white → black on **`backdropColors`**.

| Actor script |
|--------------|
| `angel_village/angel_tunnel_rooms/av74_kara.asm` (twice, 60-frame gap) |
| `seaside_palace/palace_fountain/sp5D_fountain.asm` (twice) |

---

### oneshot_palette15_grey_fade_in_1F — **live** (runtime spawn)

**Address:** `$00B7FE`

Bundle **`#1F`**: 8 frames × 16 greys at CGRAM **`$F0`** (palette 15).

| Actor script |
|--------------|
| `itory/moon_tribe_camp/it1A_moon_tribe.asm` |

---

## Unused palette thinkers — **dead / unreferenced**

No `thinker-spawn` or `SpawnThinker` references in extracted tree.

| Label | Address | Summary |
|-------|---------|---------|
| `palette_buffer_clear_unused` | `$00B6FD` | Zero **7 words** (`$7F0A94`+, step `$000E`) per loop; latch **`#FF`**. Unreachable `KillThinker` tail. |
| `babel_palette_65_unused` | `$00B781` | `WaitOnFlagByte #F5`; `PaletteStart #65` / `PaletteStep` / `RTL` loop. |
| `palette_loop_flash_unused` | `$00B808` | `PaletteStartLoop #14, #07` / `PaletteStepLoop`, then `#0B` once, `KillThinker`. |

---

## Companion matrix (palette thinker family)

| Thinker | Status | Key bundle(s) / effect | Static scenes (hex) | Runtime spawns |
|---------|--------|------------------------|---------------------|----------------|
| `ambient_palette_cycler` | live | param = bundle ID | 59 placements (see `scene_thinkers.asm`) | `item_use_system` `#2F` |
| `flag_gated_palette_warm` | live | `#02` | `$01`, `$30` | — |
| `flag_gated_palette_cool` | live | `#4C` | `$03`–`$08` | — |
| `palette_parent_child` | live | `#03` + child | `$FD`, `$FF` | — |
| `edward_castle_alarm_palette` | live | `#05` + COLDATA | `$0A` | — |
| `gold_ship_wreck_palette` | live | `#1A` / `#33`–`#36` | `$2B`, `$2D`, `$2F` | — |
| `dream_palette_loop` | live | `#35` | `$2A` | — |
| `palace_fountain_palette` | live | `#1A` / `#25` | `$5D` | — |
| `watermia_festival_palette` | live | `#42` / `#48` / `#72` | `$78`, `$7F` | — |
| `oneshot_coldata_warm_flash` | live | COLDATA R6G6B2 | `$23`, `$27` | — |
| `oneshot_coldata_r11g4b2` | live | COLDATA R11G4B2 | `$30` | — |
| `oneshot_palette_flash_18` | live | `#18` backdrop | — | Comet Lair, Angkor, Mu, Itory actors |
| `oneshot_palette_flash_19` | live | `#19` backdrop | — | same + `future_vision_cutscene` |
| `oneshot_backdrop_fade_in_1B` | live | `#1B` | — | Mu prayer, EC prison |
| `oneshot_backdrop_fade_out_1C` | live | `#1C` | — | Snake pit, Gold Ship, Mu, EC prison |
| `oneshot_backdrop_fade_out_fast_40` | live | `#40` | — | Angel Tunnel, Palace fountain |
| `oneshot_palette15_grey_fade_in_1F` | live | `#1F` CGRAM | — | Moon Tribe camp |
| `palette_buffer_clear_unused` | dead | WRAM clear | — | — |
| `babel_palette_65_unused` | dead | `#65` | — | — |
| `palette_loop_flash_unused` | dead | `#14` loop + `#0B` | — | — |

---

## Cross-reference: flash pairs (visual — inferred)

| Pair | Bundles | Typical use (inferred) |
|------|---------|-------------------------|
| `#18` + `#19` | backdrop flash in / out | Blinding light, vision events |
| `#1B` + `#1C` | ethereal in / dark out | Spirit rooms, prison |
| `#40` | fast backdrop fade | Kara tunnel, palace fountain cutscene |
| `#1F` | CGRAM grey ramp | Moon Tribe camp |
| COLDATA `#66`/`#82` | fixed add colour | Incan ruins region scenes `$23`, `$27` |
| COLDATA R11G4B2 | fixed add colour | Scene `$30` list head |

---

## Source validation

**Files checked:** All paths listed under Source of truth; full read of each palette thinker `.asm`, `cop_handlers_palette.asm` (handlers `#36`–`#3A`), `scene_thinkers.asm` pointer table and spawn lists for every `@…` reference in this family, and `rg` over `extracted/` for `SpawnThinker` targeting one-shot palette labels.

**Verified against:** Instruction-level control flow (spawn-only vs loop gates), bundle immediates and spawn parameter bytes, scene ID → list mapping from the 256-word pointer table, actor spawn sites for one-shots, zero references for `extracted/unused/` palette stubs.

**Notes:** `ambient_palette_cycler` count = 59 via `rg -c "@ambient_palette_cycler" scene_thinkers.asm`. Several block-note RGB narratives and “story phase” labels remain **inferred**. `dream_palette_loop` / `palette_buffer_clear_unused` contain **unreachable** `KillThinker` tails inside the thinker-def block. Slot indices are **per-scene list ordinals** only. Another editor owns `thinkers-system.md` / `thinkers-hdma.md`; slot wording here matches scene-table convention only.
