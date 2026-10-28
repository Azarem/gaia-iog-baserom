# Bank $00 — Thinkers: Palette Cycling & One-Shot Flashes

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00B520`–`$00B7FE` (plus unused stubs through `$00B808`)  
**Block type:** `thinker_def` — background processes running in parallel with actors  
**Priority:** All thinkers in this family use priority `#08`  
**Related:** [`README.md`](README.md), [`thinkers-hdma.md`](thinkers-hdma.md), [`thinkers-system.md`](thinkers-system.md)

Thinkers are COP-scripted background processes. The palette family drives ambient color animation via `PaletteRestart` / `PaletteStart` / `PaletteStep` COP commands, direct `$COLDATA` tint writes, and occasional child-thinker spawning. One-shot flashes are spawned by actor cutscene scripts for brief visual transitions.

---

## Overview

| Category | Count | Address Range |
|----------|-------|---------------|
| Palette cycling (ambient / gated / scene-specific) | 9 | `$B520`–`$B754` |
| One-shot palette flashes | 8 | `$B65E`, `$B6E5`, `$B7CC`–`$B7FE` |
| Unused palette thinkers | 3 | `$B6FD`, `$B781`, `$B808` |

### COP Commands Used

| Command | Role in palette thinkers |
|---------|--------------------------|
| `PaletteRestart` | Reset palette animation index to bundle start |
| `PaletteStart` | Begin stepping through a named palette bundle |
| `PaletteStep` | Advance one frame of the current bundle |
| `PaletteStartLoop` | Begin a counted sub-loop within a bundle |
| `PaletteStepLoop` | Step within a palette sub-loop |
| `BranchIfFlagByte` / `ExitIfFlagByte` | Gate transitions on scene event flags |
| `SetFlagByte` | Signal phase completion to other scripts |
| `SpawnThinker` | Launch a child thinker (parent/child pattern) |
| `KillThinker` | Terminate self (one-shots and gated exits) |

---

## Palette Cycling Family

### ambient_palette_cycler

**Address:** `$00B520`

#### Purpose

Generic infinite palette loop — the most-used thinker in the game. Each scene entry passes a palette bundle index as the thinker's first parameter (e.g. `thinker < #3F, @ambient_palette_cycler >`). On entry the thinker calls `PaletteRestart` once, then loops forever on `PaletteStep`, cycling through the bundle's color keyframes.

#### Algorithm

```
PaletteRestart          ; reset animation state for this slot's bundle
loop:
  PaletteStep           ; advance one frame
  BRA loop              ; infinite ambient cycle
```

The bundle index is **not** hardcoded in the script — it comes from the scene thinker table's first byte. This single 8-byte thinker serves dozens of distinct ambient effects (torch flicker, water shimmer, sky gradients) by varying only the bundle parameter.

#### Scene Usage

Present in the majority of field scenes via `scene_thinkers.asm`. Examples:

| Scene | Bundle Param | Notes |
|-------|-------------|-------|
| Early overworld (`thinker_0CE7EA`) | `#3F`, `#06`, `#07`, `#12` | Multi-layer ambient on South Cape / Edward region |
| Mu rooms (`thinker_0CE98D`) | `#01` | Secondary ambient under `mu_tint_and_wave` |
| Watermia region | `#47`, `#4F`, `#4D`, `#4E` | Festival and town variants |
| Comet Lair (`thinker_0CEABA`) | `#71` | Eerie blue ambient |
| Inventory (`thinker_0CEB46`) | `#3E`, `#64` | Menu backdrop palettes |

Also referenced as the default ambient slot in `thinker_0CE82E`, `thinker_0CE8F9`–`thinker_0CE93A` (Mountain Temple / Great Wall corridor sets), and many more entries in the 256-scene pointer table.

#### Dependencies

None — no `?INCLUDE`, no external symbol references.

---

### flag_gated_palette_warm

**Address:** `$00B5C0`

#### Purpose

Warm palette step (bundle `#02`) with a **spawn-time** gate on flags `#1C` and `#16`. If the gate fails at spawn, the thinker never enters its loop (`KillThinker`). The loop itself does not re-check story flags each frame.

#### Algorithm

```
if flag #1C == 1 OR flag #16 == 0 → KillThinker
loop:
  PaletteStart #02
  PaletteStep
  SetFlagByte #FF
  ExitIfFlagByte #FF == 0 → exit loop iteration
  BRA loop
```

Flag `#FF` acts as an internal phase latch — set each step, checked for external override to break the loop.

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| South Cape (`$01`) | `thinker_0CE7EA` | Pre–Oakton storm ambient |
| Oakton (`$30`) | `thinker_0CE80C` slot `#03` | Warm interior (paired with storm COLDATA) |

Paired in `thinker_0CE80C` with `oneshot_coldata_r11g4b2` (slot `#00`) and dual `ambient_palette_cycler` layers.

#### Dependencies

None.

---

### flag_gated_palette_cool

**Address:** `$00B5DF`

#### Purpose

Seven-colour palette step (bundle `#4C`, colours from index `$19`) using the same spawn-time dual-flag gate as `flag_gated_palette_warm`. Not a full-palette cycle.

#### Algorithm

Identical control flow to `flag_gated_palette_warm`, but uses palette bundle `#4C` instead of `#02`.

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| South Cape interiors (`$03`–`$08`) | One slot each in `thinker_0CE7F*` blocks | Lance's, Eric's, Seth's, Will's, Chef's houses, church |

#### Dependencies

None.

---

### palette_parent_child

**Address:** `$00B5FE`

#### Purpose

Parent thinker for bundle `#03` that spawns a child thinker when flag `#01` is set. The parent holds the initial palette state; the child (`PaletteParentChildWaveLoop`) runs an independent infinite `PaletteStart #03` / `PaletteStep` loop. When flag `#01` clears, the parent kills the child and restarts its own cycle.

#### Algorithm

```
parent (loc_00B600):
  PaletteStart #03
  SetEntryHere
  if flag #01 == 1 → spawn child @PaletteParentChildWaveLoop
  RTL

child (PaletteParentChildWaveLoop):
  loop: PaletteStart #03 → PaletteStep → BRA loop

on flag #01 clear:
  kill child, restart parent at loc_00B600
```

The parent stores the child's thinker index at `$7F000A,X` for later termination.

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Statue inventory | `$FD` (`thinker_0CEB30` slot `#01`) | Animated palette layer during statue collection screen |
| Inventory menu | `$FF` (`thinker_0CEB46` slot `#02`) | Secondary palette animation in item menu |

#### Dependencies

None.

---

### edward_castle_alarm_palette

**Address:** `$00B631`

#### Purpose

Red-alert palette effect for Edward Castle's alarm sequence. Cycles palette bundle `#05` while simultaneously writing red tint values to `$COLDATA` (`#$24` then `#$42`) each frame, producing a pulsing red emergency atmosphere.

#### Algorithm

```
if flag #22 == 1 OR flag #21 == 0 → KillThinker
loop:
  PaletteStart #05
  PaletteStep
  COLDATA ← #$24, #$42    ; red color addition
  SetFlagByte #FF
  ExitIfFlagByte #FF == 0
  BRA loop
```

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Edward Castle | 10 (`thinker_0CE821` slot `#01`) | Alarm/red-alert state during castle infiltration |

#### Dependencies

None.

---

### incan_ruins_transform_palette

**Address:** `$00B671`

#### Purpose

Multi-phase palette transformer for Angkor Wat / Incan Ruins sequences. Progresses through three visual states driven by flags `#4D` (mid-game transform) and `#52` (final crystal phase):

1. **Default:** Infinite loop on bundle `#1A` (ruins ambient)
2. **Phase 2** (flag `#4D`): Alternates bundles `#34` and `#33` with internal `#FF` latch
3. **Phase 3** (flag `#52`): Kills adjacent thinker slots, fills WRAM palette buffer `$7F0A40`–`$7F0A5F` with `#$1421`, sets `$7F0A00` ← `#$1442`, cycles bundle `#36`

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Incan Ruins exterior | 34 (`thinker_0CE87F`) | Ruins exploration |
| Incan Ruins interior | 35 (`thinker_0CE890`) | Inner chambers |
| Angkor complex | 36 (`thinker_0CE8A1`) | Multi-parallax ruin layout |

#### Dependencies

None. Phase 3 uses direct WRAM palette buffer writes (`$7F0A40`, `$7F0A00`) rather than COP palette commands.

---

### dream_palette_loop

**Address:** `$00B6D2`

#### Purpose

Dream-sequence palette cycler using bundle `#35`. Sets flag `#FF` each step; when flag `#FF` is externally cleared (`ExitIfFlagByte`), the thinker falls through to `KillThinker` and terminates — allowing the Gold Ship dream scene to exit the surreal color loop.

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Gold Ship dream | 42 (`thinker_0CE7FB` slot `#00`) | Tim's dream aboard the Gold Ship |

#### Dependencies

None.

---

### palace_fountain_palette

**Address:** `$00B71E`

#### Purpose

Seaside Palace fountain room effect. Sets `$CGADSUB` ← `#$03` (color math: add subscreen to main) and alternates between palette bundles `#1A` and `#25` based on flags `#0F` and `#70`. Flag `#0F` triggers an exit path via `ExitIfFlagByte`.

#### Algorithm

```
loop:
  SetFlagByte #FF
  CGADSUB ← #$03
  if flag #0F → exit branch
  if flag #70 == 0 → PaletteStart #1A else #25
  PaletteStep
  if flag #FF == 1 → restart loop
```

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Palace Fountain | 93 (`thinker_0CE984` slot `#00`) | Kara's fountain room at Seaside Palace |

#### Dependencies

None.

---

### watermia_festival_palette

**Address:** `$00B754`

#### Purpose

Watermia town palette controller. Default state loops bundle `#42` (normal town ambient). When flag `#96` is set (festival begins), spawns a child thinker running bundle `#72` with thinker flag `$0800` set on `$7F000E,X` (priority/behavior bit), while the parent switches to bundle `#48`.

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Watermia | 120 (`thinker_0CE9AC` slot `#01`) | Pre- and post-festival town atmosphere |

#### Dependencies

None.

---

## One-Shot Palette Flashes

Some one-shot thinkers are spawned from actor scripts (`COP [SpawnThinker]`); others are listed directly in `scene_thinkers` tables. Palette bundle flashes run the full bundle via `PaletteStep` each frame until the script finishes (typically 32 frames), then `KillThinker`.

### oneshot_coldata_warm_flash

**Address:** `$00B65E`

#### Purpose

Fixed warm tint via two `$COLDATA` writes (`#$66` → R6 G6, `#$82` → B2). Nothing in this thinker reverts the colour; visibility depends on scene colour-math registers. No palette bundle involved.

#### Scene Usage

| Scene ID | Thinker list | Slot |
|----------|--------------|------|
| `$23` | `$0CE850` | `#02` |
| `$27` | `$0CE872` | `#00` |

#### Dependencies

None.

---

### oneshot_coldata_r11g4b2

**Address:** `$00B6E5`

#### Purpose

Fixed colour via three `$COLDATA` writes (`#$2B` R11, `#$44` G4, `#$82` B2). The on-screen hue depends on CGADSUB add/subtract mode; the values alone are red-dominant.

#### Scene Usage

| Scene ID | Thinker list | Slot |
|----------|--------------|------|
| `$30` | `$0CE80C` | `#00` |

#### Dependencies

None.

---

### oneshot_palette_flash_18

**Address:** `$00B7CC`

#### Purpose

32-frame COLDATA backdrop fade-in using palette bundle `#18` (black → bluish white). Paired with `oneshot_palette_flash_19` (bundle `#19`, red-tinted fade-out to black over 32 frames).

#### Scene Usage (actor-spawned)

| Location | Actor Script |
|----------|-------------|
| Comet Lair | `sE8_dark_gaia.asm` |
| Angkor blinding light | `awBC_blinding_light.asm` |
| Angkor spirit guide | `awBF_spirit_guide.asm` |
| Mu altar spirits | `mu66_rama_spirits.asm` |
| Itory Village (Lily) | `it15_lily.asm` |

#### Dependencies

None.

---

### oneshot_palette_flash_19

**Address:** `$00B7D6`

#### Purpose

32-frame complement to bundle `#18` — plays palette bundle `#19` (backdrop triplets fade through red to black). Usually spawned immediately after flash `#18` in cutscene scripts; `future_vision_cutscene` can spawn it alone.

#### Scene Usage

Same locations as `oneshot_palette_flash_18` (paired spawn).

#### Dependencies

None.

---

### oneshot_backdrop_fade_in_1B

**Address:** `$00B7E0`

#### Purpose

Backdrop **fade in** via bundle `#1B`: 32 three-byte `COLDATA` steps (160 ticks) from black through yellow to near-white. Requires scene color math enabled; not a CGRAM palette write.

#### Scene Usage (actor-spawned)

| Location | Actor Script |
|----------|-------------|
| Mu prayer room | `mu63_spirits.asm` |
| Edward Castle prison | `ec0B_cell.asm` |

#### Dependencies

None.

---

### oneshot_backdrop_fade_out_1C

**Address:** `$00B7EA`

#### Purpose

Backdrop **fade out** via bundle `#1C`: 32 frames (160 ticks) white → black on the fixed-color triplet. Counterpart to `#1B` fade-in.

#### Scene Usage (actor-spawned)

| Location | Actor Script |
|----------|-------------|
| Snake Pit | `awB4_actor_08992A.asm` |
| Gold Ship descent | `gs2C_descent.asm`, `gs2C_crow_crew.asm` |
| Mu prayer room | `mu63_spirits.asm` (paired with `#1B`) |
| Castle prison | `ec0B_cell.asm` (paired with `#1B`) |

#### Dependencies

None.

---

### oneshot_backdrop_fade_out_fast_40

**Address:** `$00B7F4`

#### Purpose

Fast backdrop fade out via bundle `#40`: 16 frames (32 ticks) white → black on `COLDATA`. Used for Angel Tunnel (Kara) and Palace fountain cutscenes (often spawned twice with a 60-frame gap).

#### Scene Usage (actor-spawned)

| Location | Actor Script |
|----------|-------------|
| Angel Tunnel (Kara) | `av74_kara.asm` |
| Palace Fountain | `sp5D_fountain.asm` |

#### Dependencies

None.

---

### oneshot_palette15_grey_fade_in_1F

**Address:** `$00B7FE`

#### Purpose

Palette 15 grey ramp via bundle `#1F`: 8 frames × 16 colors at CGRAM `$F0` (64 ticks), grey values rising from near-black to light grey — not a backdrop/COLDATA effect.

#### Scene Usage (actor-spawned)

| Location | Actor Script |
|----------|-------------|
| Itory Moon Tribe camp | `it1A_moon_tribe.asm` |

#### Dependencies

None.

---

## Unused Palette Thinkers

### palette_buffer_clear_unused

**Address:** `$00B6FD`

#### Purpose

Clears 14 words at `$7F0A94`–`$7F0AA1` each loop iteration, gated by flag `#FF`. Appears to be a palette buffer reset utility that was superseded by COP palette commands. No scene references.

#### Dependencies

None.

---

### babel_palette_65_unused

**Address:** `$00B781`

#### Purpose

Cut Babel Tower effect — single-step palette bundle `#65` gated on flag `#F5`. Would have provided a unique Babel ascent palette transition. Removed from final scene tables.

#### Dependencies

None.

---

### palette_loop_flash_unused

**Address:** `$00B808`

#### Purpose

Composite one-shot: runs a 7-step sub-loop on bundle `#14` via `PaletteStartLoop`/`PaletteStepLoop`, then applies bundle `#0B` and self-terminates. No scene or actor references — likely a discarded transition effect prototype.

#### Dependencies

None.

---

## Cross-Reference: Flash Pairs

| Pair | Bundles | Visual Effect | Typical Use |
|------|---------|---------------|-------------|
| `#18` + `#19` | White flash → restore | Blinding light / vision events | Angkor, Comet Lair, Mu altar |
| `#1B` + `#1C` | Ethereal → dark shift | Spirit manifestation | Mu prayer, Castle prison |
| `#40` | Strong saturated snap | Dramatic revelation | Angel Tunnel, Palace fountain |
| `#1F` | Lunar silver | Moon Tribe magic | Itory camp |
| COLDATA warm | `#66`/`#82` | Golden warmth | Incan Ruins, Larai Cliff |
| COLDATA R11G4B2 | `#2B`/`#44`/`#82` | Fixed backdrop tint | Scene `$30` thinker list |

---

*Source: `extracted/thinkers/` and related scene-specific thinker ASM in `extracted/`.*
