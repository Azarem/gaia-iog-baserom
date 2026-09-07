# Bank $00 — Thinkers: Palette Cycling & One-Shot Flashes

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00B520`–`$00B7FE` (plus unused stubs through `$00B808`)  
**Block type:** `thinker_def` — background processes running in parallel with actors  
**Priority:** All thinkers in this family use priority `#08`  
**Related:** [`bank00-upper-analysis.md`](../bank00-upper-analysis.md), [`thinkers-hdma.md`](thinkers-hdma.md), [`thinkers-system.md`](thinkers-system.md)

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

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00B520` |
| **New Name** | `ambient_palette_cycler` |
| **Hex Address** | `$00B520` |
| **Decimal Address** | 46368 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/thinkers/ambient_palette_cycler.asm` |

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

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00B5C0` |
| **New Name** | `flag_gated_palette_warm` |
| **Hex Address** | `$00B5C0` |
| **Decimal Address** | 46528 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/thinkers/flag_gated_palette_warm.asm` |

#### Purpose

Warm-toned palette cycler (bundle `#02`) gated by scene flags `#1C` and `#16`. Runs the warm ambient loop only while both gate conditions hold; otherwise self-terminates via `KillThinker`.

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
| Oakton House | 48 (`thinker_0CE80C` slot `#03`) | Warm interior glow during/after storm sequence |

Paired in `thinker_0CE80C` with `oneshot_coldata_green_tint` (slot `#00`) and dual `ambient_palette_cycler` layers.

#### Dependencies

None.

---

### flag_gated_palette_cool

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00B5DF` |
| **New Name** | `flag_gated_palette_cool` |
| **Hex Address** | `$00B5DF` |
| **Decimal Address** | 46559 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/thinkers/flag_gated_palette_cool.asm` |

#### Purpose

Cool-toned palette cycler (bundle `#4C`) using the same dual-flag gate pattern as `flag_gated_palette_warm`. Provides blue/cool ambient for early overworld maps before the warm Oakton transition.

#### Algorithm

Identical control flow to `flag_gated_palette_warm`, but uses palette bundle `#4C` instead of `#02`.

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Early overworld | 1 (`thinker_0CE7EA` slot `#01`) | South Cape / Edward Castle exterior cool ambient |

#### Dependencies

None.

---

### palette_parent_child

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00B5FE` |
| **New Name** | `palette_parent_child` |
| **Hex Address** | `$00B5FE` |
| **Decimal Address** | 46590 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/thinkers/palette_parent_child.asm` |

#### Purpose

Parent thinker for bundle `#03` that spawns a child thinker when flag `#01` is set. The parent holds the initial palette state; the child (`code_00B62A`) runs an independent infinite `PaletteStart #03` / `PaletteStep` loop. When flag `#01` clears, the parent kills the child and restarts its own cycle.

#### Algorithm

```
parent (loc_00B600):
  PaletteStart #03
  SetEntryContinue
  if flag #01 == 1 → spawn child @code_00B62A
  RTL

child (code_00B62A):
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

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00B631` |
| **New Name** | `edward_castle_alarm_palette` |
| **Hex Address** | `$00B631` |
| **Decimal Address** | 46641 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/edward_castle/edward_castle/edward_castle_alarm_palette.asm` |

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

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00B671` |
| **New Name** | `incan_ruins_transform_palette` |
| **Hex Address** | `$00B671` |
| **Decimal Address** | 46705 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/thinkers/incan_ruins_transform_palette.asm` |

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

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00B6D2` |
| **New Name** | `dream_palette_loop` |
| **Hex Address** | `$00B6D2` |
| **Decimal Address** | 46802 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/gold_ship/dream/dream_palette_loop.asm` |

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

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00B71E` |
| **New Name** | `palace_fountain_palette` |
| **Hex Address** | `$00B71E` |
| **Decimal Address** | 46878 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/seaside_palace/palace_fountain/palace_fountain_palette.asm` |

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

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00B754` |
| **New Name** | `watermia_festival_palette` |
| **Hex Address** | `$00B754` |
| **Decimal Address** | 46932 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/watermia/watermia/watermia_festival_palette.asm` |

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

One-shot thinkers apply a single palette step or COLDATA tint, then immediately `KillThinker`. They are **not** placed in scene thinker tables — actor scripts spawn them via `COP [SpawnThinker]` during cutscenes.

### oneshot_coldata_warm_flash

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00B65E` |
| **New Name** | `oneshot_coldata_warm_flash` |
| **Hex Address** | `$00B65E` |
| **Decimal Address** | 46686 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/thinkers/oneshot_coldata_warm_flash.asm` |

#### Purpose

Instant warm color addition via `$COLDATA` writes (`#$66`, `#$82`), producing a brief orange/golden screen tint. No palette bundle involved — pure PPU color math.

#### Scene Usage

| Scene | Index | Placement |
|-------|-------|-----------|
| Incan Ruins | 34 (`thinker_0CE850` slot `#02`) | Scene-load warm flash |
| Larai Cliff | 29 (`thinker_0CE872` slot `#00`) | Cliff-edge warm tint on entry |

Also spawnable from actor scripts at runtime.

#### Dependencies

None.

---

### oneshot_coldata_green_tint

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00B6E5` |
| **New Name** | `oneshot_coldata_green_tint` |
| **Hex Address** | `$00B6E5` |
| **Decimal Address** | 46821 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/thinkers/oneshot_coldata_green_tint.asm` |

#### Purpose

Instant green storm tint via three `$COLDATA` writes (`#$2B`, `#$44`, `#$82`). Used for the Oakton thunderstorm's sickly green lightning atmosphere.

#### Scene Usage

| Scene | Index | Context |
|-------|-------|---------|
| Oakton storm | 48 (`thinker_0CE80C` slot `#00`) | One-shot green overlay at scene load |

#### Dependencies

None.

---

### oneshot_palette_flash_18

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00B7CC` |
| **New Name** | `oneshot_palette_flash_18` |
| **Hex Address** | `$00B7CC` |
| **Decimal Address** | 47052 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/thinkers/oneshot_palette_flash_18.asm` |

#### Purpose

Single-step white flash using palette bundle `#18`. Paired with `oneshot_palette_flash_19` (bundle `#19`) for flash-on / flash-off transitions.

#### Scene Usage (actor-spawned)

| Location | Actor Script |
|----------|-------------|
| Comet Lair | `sE8_actor_0CEEAA.asm` |
| Angkor blinding light | `awBC_blinding_light.asm` |
| Angkor spirit guide | `awBF_spirit_guide.asm` |
| Mu altar spirits | `mu66_rama_spirits.asm` |
| Itory Village (Lily) | `it15_lily.asm` |

#### Dependencies

None.

---

### oneshot_palette_flash_19

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00B7D6` |
| **New Name** | `oneshot_palette_flash_19` |
| **Hex Address** | `$00B7D6` |
| **Decimal Address** | 47062 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/thinkers/oneshot_palette_flash_19.asm` |

#### Purpose

Complement flash to bundle `#18` — applies palette bundle `#19` (return-to-normal / inverse white). Always spawned immediately after flash `#18` in cutscene scripts.

#### Scene Usage

Same locations as `oneshot_palette_flash_18` (paired spawn).

#### Dependencies

None.

---

### oneshot_palette_flash_1B

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00B7E0` |
| **New Name** | `oneshot_palette_flash_1B` |
| **Hex Address** | `$00B7E0` |
| **Decimal Address** | 47072 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/thinkers/oneshot_palette_flash_1B.asm` |

#### Purpose

Spirit/prayer room flash using palette bundle `#1B` — a softer, ethereal white-violet transition distinct from the harsh `#18`/`#19` pair.

#### Scene Usage (actor-spawned)

| Location | Actor Script |
|----------|-------------|
| Mu prayer room | `mu63_spirits.asm` |
| Edward Castle prison | `ec0B_cell.asm` |

#### Dependencies

None.

---

### oneshot_palette_flash_1C

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00B7EA` |
| **New Name** | `oneshot_palette_flash_1C` |
| **Hex Address** | `$00B7EA` |
| **Decimal Address** | 47082 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/thinkers/oneshot_palette_flash_1C.asm` |

#### Purpose

Dungeon/spirit flash using palette bundle `#1C` — darker, more sinister color shift than `#1B`. Used for underground and supernatural encounters.

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

### oneshot_palette_flash_40

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00B7F4` |
| **New Name** | `oneshot_palette_flash_40` |
| **Hex Address** | `$00B7F4` |
| **Decimal Address** | 47092 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/thinkers/oneshot_palette_flash_40.asm` |

#### Purpose

Strong color shift flash using palette bundle `#40`. Produces a dramatic, saturated palette snap used for Angel Tunnel revelations and Palace fountain events.

#### Scene Usage (actor-spawned)

| Location | Actor Script |
|----------|-------------|
| Angel Tunnel (Kara) | `av74_kara.asm` |
| Palace Fountain | `sp5D_fountain.asm` |

#### Dependencies

None.

---

### oneshot_palette_flash_1F

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00B7FE` |
| **New Name** | `oneshot_palette_flash_1F` |
| **Hex Address** | `$00B7FE` |
| **Decimal Address** | 47102 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/thinkers/oneshot_palette_flash_1F.asm` |

#### Purpose

Moon Tribe camp flash using palette bundle `#1F` — cool lunar/silver tint for Itory Moon Tribe sequences.

#### Scene Usage (actor-spawned)

| Location | Actor Script |
|----------|-------------|
| Itory Moon Tribe camp | `it1A_moon_tribe.asm` |

#### Dependencies

None.

---

## Unused Palette Thinkers

### palette_buffer_clear_unused

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00B6FD` |
| **New Name** | `palette_buffer_clear_unused` |
| **Hex Address** | `$00B6FD` |
| **Decimal Address** | 46845 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/unused/palette_buffer_clear_unused.asm` |

#### Purpose

Clears 14 words at `$7F0A94`–`$7F0AA1` each loop iteration, gated by flag `#FF`. Appears to be a palette buffer reset utility that was superseded by COP palette commands. No scene references.

#### Dependencies

None.

---

### babel_palette_65_unused

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00B781` |
| **New Name** | `babel_palette_65_unused` |
| **Hex Address** | `$00B781` |
| **Decimal Address** | 46977 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/unused/babel_palette_65_unused.asm` |

#### Purpose

Cut Babel Tower effect — single-step palette bundle `#65` gated on flag `#F5`. Would have provided a unique Babel ascent palette transition. Removed from final scene tables.

#### Dependencies

None.

---

### palette_loop_flash_unused

| Property | Value |
|----------|-------|
| **Old Name** | `thinker_00B808` |
| **New Name** | `palette_loop_flash_unused` |
| **Hex Address** | `$00B808` |
| **Decimal Address** | 47112 |
| **Self-Contained** | Yes |
| **ASM File** | `extracted/unused/palette_loop_flash_unused.asm` |

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
| COLDATA green | `#2B`/`#44`/`#82` | Storm sickliness | Oakton thunderstorm |
