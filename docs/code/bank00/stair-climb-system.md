# Bank $00 — Psycho Slider Glide System

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00D088`–`$00D2D2` (core) + `$00D58A`–`$00D5BC` (`RestorePlayerControl`)  
**Source file:** `extracted/system/engine/slider_glide.asm`  
**Related:** `extracted/actors/ramps.asm` (`?INCLUDE`s this chunk) · [`camera-scroll-system.md`](camera-scroll-system.md)

## Source of truth

Primary:

| Path | Role |
|------|------|
| `extracted/system/engine/slider_glide.asm` | Triggers, glide routines, lock/unlock helpers, `RestorePlayerControl` |
| `extracted/actors/ramps.asm` | Cross-bank `JSR $&slider_glide.RestorePlayerControl` from ramp completion |
| `extracted/tables/scene_actors.asm` | Static `actor-spawn` rows pointing at trigger labels |
| `extracted/angkor_wat/angkor_outer_east/awB2_stair_climb.asm` | Runtime `JumpFar` into `SliderGlideTriggerNorthMain` |

**Naming:** Section headings use extracted labels (`SliderGlideTriggerWest`, `LockPlayerForClimb`, …). Scene area names below are documentation shorthand tied to `scene_*_actors` tables in `scene_actors.asm`, not separate ROM labels.

**Counts:** **5** live trigger implementations (four directional gates plus `SliderGlideTriggerNorthEntry`); **29** static scene placements in `scene_actors.asm` (counted with `rg` this session); **1** additional runtime entry to `SliderGlideTriggerNorthMain` via `awB2_stair_climb`; **11** unique `scene_*_actors` tables contain at least one spawn; **3** external `RestorePlayerControl` call sites in `ramps.asm` (`RampPlayerClimbNorth`, `RampPlayerClimbSouth`, `RampArcDriver`).

---

## Table of Contents

1. [Architecture](#architecture)
2. [Trigger → lock flow](#trigger--lock-flow)
3. [Shared lock / unlock utilities](#shared-lock--unlock-utilities)
4. [Actor trigger definitions](#actor-trigger-definitions)
5. [Directional glide routines](#directional-glide-routines)
6. [Variable map](#variable-map)
7. [Call reference matrix](#call-reference-matrix)
8. [Block coupling and movability](#block-coupling-and-movability)
9. [Scene usage](#scene-usage)

---

## Architecture

Invisible **slider glide triggers** are `actor-def` entries on Psycho Slider lanes. While Will is in an active **Psycho Slide** (`RunAttackNS` / `RunAttackEW` in `player_character`) through the trigger geometry, each gate:

1. Reads the **player** actor (`LDY $playerActor`) and checks proximity (32-pixel lateral window; exact pixel match on the slide axis).
2. Calls **`IsPlayerSliderSpriteBank`** — carry **clear** only when `$7F0008` (player spriteset bank byte) equals **`$8F`** (bank of `spriteset_will_abilities`, selected at slide start via `SetPlayerSpriteDirect #04`).
3. Validates **`$28`** (animation index) against the **start/loop** pair for that slide direction (not the finish frames).
4. On success, writes the player entry pointer to the matching **`SliderGlide*`** routine and **`JSR $&LockPlayerForClimb`** (trigger context: **`D` = trigger slot**, **`$0E` = glide length parameter**).

Trigger names match **slide direction**: west slide → `SliderGlideTriggerWest` → `SliderGlideWest` (X − 4/frame); east → `SliderGlideEast` (X + 4); north → `SliderGlideNorth` (Y − 4); south → `SliderGlideSouth` (Y + 4).

**Per-frame re-check:** Only **`SliderGlideTriggerNorth`** begins its main path with **`COP [SetEntryHere]`** (`SliderGlideTriggerNorthMain`). The east/west/south triggers return with **`RTL`** after each test; they rely on the actor runner re-invoking the trigger slot (actor-def type byte **`#20`** in the spawn template). **`SliderGlideTriggerNorthEntry`** runs **`COP [NudgePosition] ( #F8, #00 )`** once on the trigger slot, then **`BRA SliderGlideTriggerNorthMain`**.

### Include dependencies

| Include | Purpose |
|---------|---------|
| `player_character` | Player variable labels; `PlayerIdleEntry` target for `RestorePlayerControl` |

---

## Trigger → lock flow

```text
  [Each frame: trigger actor runs]
           |
           v
  +---------------------+
  | Proximity + axis    |
  | (32px lateral win.) |
  +----------+----------+
             | fail -> RTL (no lock)
             v pass
  +---------------------+
  | IsPlayerSliderSpriteBank |
  | CC <= bank $8F      |
  +----------+----------+
             | CS -> RTL
             v
  +---------------------+
  | $28 in {start,loop} |
  | for slide direction |
  +----------+----------+
             | fail -> RTL
             v pass
  +---------------------+
  | STA player $00/$02  |
  | -> SliderGlide*     |
  +----------+----------+
             v
  +---------------------+
  | LockPlayerForClimb  |
  | (trigger $0E ->     |
  |  player statsPtr)   |
  +----------+----------+
             v
  [Player runs SliderGlide* until countdown 0]
             v
  +---------------------+
  | UnlockPlayerAfterClimb |
  +----------+----------+
             v
  +---------------------+
  | RestorePlayerControl   |
  | -> PlayerIdleEntry     |
  +---------------------+
```

---

## Shared lock / unlock utilities

### LockPlayerForClimb — **live**

**Label:** `LockPlayerForClimb` · **Address:** `$00D088`

Called from all **five** trigger code paths after redirecting the player entry pointer.

1. **`$0E << 2`** (trigger parameter) → frame countdown stored in the **player’s** `$7F0020,X` (`statsPtr` reuse).
2. Zero player **`$002C` / `$002E` / `$0008`** (velocity and wait).
3. **`TSB $joypadMaskStd`** with **`$0F00`** (mask D-pad; post-`transforms.json` value in this baserom).
4. **`TSB $playerFlags`** with **`$0800`** (script/ability lock).

### UnlockPlayerAfterClimb — **live**

**Label:** `UnlockPlayerAfterClimb` · **Address:** `$00D0AE`

Called from all **four** `SliderGlide*` routines when the countdown reaches zero.

1. **`STZ $climbStateData`** (`$09E0` — ability damage bonus for the slide; the interrupted slide never runs its normal cleanup).
2. **`TRB $joypadMaskStd`** with **`$CFFC`** (unmask consumed buttons; differs from vanilla after button remap — see `transforms.json` / block note).
3. Player **`$10`**: set bit **`$0008`**, clear bit **`$0200`**.
4. **`TSB $joypadHeld`** with **`$0080`** (consume attack press — remapped attack bit in this baserom).
5. **`TRB $playerFlags`** with **`$0002`**.
6. **`JSR $&RestorePlayerControl`**.

### IsPlayerSliderSpriteBank — **live**

**Label:** `IsPlayerSliderSpriteBank` · **Address:** `$00D204`

Compares **`$7F0008,X`** to **`$8F`**. Carry **clear** = accept; carry **set** = reject. Bank **`$8F`** is shared by **`spriteset_will_abilities`** (row 4, Psycho Slide) and **`spriteset_transform_poses`** (row 5, `sE6_gaia` only); the test does not distinguish them.

### RestorePlayerControl — **live** (shared with ramps)

**Label:** `RestorePlayerControl` · **Address:** `$00D58A`

Resets the player to **`PlayerIdleEntry`**, zeros **`$002C` / `$002E` / `$0008`**, adjusts **`$10`** (`AND #$FDFF`, `ORA #$0008`), **`TRB $joypadMaskStd`** with **`$0F00`**, **`TRB $playerFlags`** with **`$0800`**.

**External callers (ramps.asm):** `RampPlayerClimbNorth`, `RampPlayerClimbSouth`, `RampArcDriver` (east/west climbs finish in the arc child, not in `RampPlayerClimbEast` / `RampPlayerClimbWest` themselves).

---

## Actor trigger definitions

All five are separate **`actor-def`** blocks in `slider_glide.asm`. Spawn counts are **static placements** in `scene_actors.asm` only (plus the **`awB2_stair_climb`** JumpFar noted under North).

| Trigger | Slide anim `$28` | Axis / window | Glide target | Static spawns |
|---------|------------------|---------------|--------------|---------------|
| `SliderGlideTriggerWest` | `$12` / `$13` | exact X; Y in trigger Y−7…Y+`$18` | `SliderGlideWest` | **1** |
| `SliderGlideTriggerEast` | `$15` / `$16` | same as west | `SliderGlideEast` | **1** |
| `SliderGlideTriggerNorthEntry` | (delegates) | Nudge trigger X−8 once | → `SliderGlideTriggerNorthMain` | **1** |
| `SliderGlideTriggerNorth` | `$0F` / `$10` | exact Y; X in trigger X−7…X+`$18` | `SliderGlideNorth` | **14** |
| `SliderGlideTriggerSouth` | `$0C` / `$0D` | exact Y; X in trigger X−7…X+`$18` | `SliderGlideSouth` | **14** |

Geometry note (from block comment): lateral compare is **`trigger − 8 < player ≤ trigger − 8 + $20`** (32 pixels, documented as trigger−7…+`$18` inclusive).

---

## Directional glide routines

All four **`SliderGlide*`** routines (**live**):

1. Once: **`TSB $10`** with **`$2200`**, **`TRB $10`** with **`$0008`**.
2. **`COP [SetEntryHere]`** — multi-frame execution on the **player** slot.
3. Move **`$14`** or **`$16`** by **±4** per frame (no collision test).
4. Decrement **`$7F0020,X`** (`statsPtr` countdown); if non-zero → **`RTL`**.
5. At zero: clear **`$2000`** from **`$10`**, **`COP [StageSpriteFrame]`** with finish frame, **`COP [AnimOnce]`**, **`JSR $&UnlockPlayerAfterClimb`**.

| Routine | Movement | Finish frame operand |
|---------|----------|----------------------|
| `SliderGlideWest` | `$14` − 4 | `#14` |
| `SliderGlideEast` | `$14` + 4 | `#17` |
| `SliderGlideNorth` | `$16` − 4 | `#11` |
| `SliderGlideSouth` | `$16` + 4 | `#0E` |

No sprite animation runs during the glide itself; the slide **loop** frame stays visible until landing.

---

## Variable map

| Location | Role |
|----------|------|
| Trigger **`$0E`** | Glide length units (×4 frames, 4 px/frame → 16 px per unit) — read in **`LockPlayerForClimb`** |
| Player **`$10`** | `$2200` during glide; `$2000` cleared at landing; bit `$0008` collision-aware movement |
| Player **`$14` / `$16`** | Position patched by glide |
| Player **`$28`** | Animation index validated by triggers |
| **`$7F0008,X`** | Spriteset bank byte (`IsPlayerSliderSpriteBank`) |
| **`$7F0020,X`** | Glide frame counter (`statsPtr` reuse) |
| **`$002C` / `$002E` / `$0008`** | Zeroed on lock / restore |
| **`$climbStateData` (`$09E0`)** | Cleared on unlock |
| **`$joypadMaskStd` / `$playerFlags` / `$joypadHeld`** | Lock, unlock, and restore paths (see asm) |

---

## Call reference matrix

| Caller | Callee |
|--------|--------|
| All 5 triggers | `IsPlayerSliderSpriteBank`, `LockPlayerForClimb` |
| All 4 `SliderGlide*` | `UnlockPlayerAfterClimb` |
| `UnlockPlayerAfterClimb` | `RestorePlayerControl` |
| `RampPlayerClimbNorth`, `RampPlayerClimbSouth`, `RampArcDriver` | `slider_glide.RestorePlayerControl` |

---

## Block coupling and movability

| Source | What it says |
|--------|----------------|
| `slider_glide.asm` block note | Block described as **non-movable** because of tight **`$&`** coupling between triggers, glide handlers, and ramp completion |
| `db-us/blocks.json` → **`ramps`** | **`"movable": false`** (explicit) |
| `db-us/blocks.json` → **`slider_glide`** | Partial part map only; **no `movable` key** in the JSON entry checked for this audit |

`ramps.asm` **`?INCLUDE`s** the slider chunk so **`RestorePlayerControl`** resolves at a fixed bank-$00 offset.

---

## Scene usage

Static placements (grep `SliderGlideTrigger` in `extracted/tables/scene_actors.asm`):

| `scene_*_actors` | Triggers placed | Doc area (informal) |
|------------------|-----------------|---------------------|
| `scene_5F_actors` | South ×1 | Mu (Cyclops area) |
| `scene_62_actors` | East, West, North ×1 each | Mu Passage |
| `scene_65_actors` | North, South ×1 each | Mu |
| `scene_70_actors` | North, South ×1 each | Angel Village |
| `scene_72_actors` | `NorthEntry` ×1 | Angel Village |
| `scene_73_actors` | South ×1 | Angel Village |
| `scene_B2_actors` | South ×1 (+ `awB2_stair_climb` JumpFar to north main) | Angkor Wat |
| `scene_B5_actors` | North ×3, South ×3 | Angkor Wat |
| `scene_BC_actors` | North ×3, South ×3 | Angkor Wat |
| `scene_BD_actors` | North ×2, South ×2 | Angkor Wat |
| `scene_E9_actors` | North, South ×1 each | Dracula Mansion |

All rows use the `actor-spawn` form in `scene_actors.asm` (coordinates + type byte + `@slider_glide.<Trigger>`).

---

## Source validation

**Files checked:** `extracted/system/engine/slider_glide.asm`, `extracted/actors/ramps.asm`, `extracted/tables/scene_actors.asm`, `extracted/angkor_wat/angkor_outer_east/awB2_stair_climb.asm`, `db-us/blocks.json` (read-only).

**Verified against:** Trigger geometry and animation constants; `IsPlayerSliderSpriteBank` carry semantics; lock/unlock/`RestorePlayerControl` instruction sequence; finish-frame operands; spawn counts per trigger label; ramp `RestorePlayerControl` call sites; `movable` flags as present in JSON vs asm block note.

**Notes:** Scene area names are informal mappings to `scene_*_actors` IDs, not ROM strings. East/west ramp climbs delegate **`RestorePlayerControl`** to **`RampArcDriver`**, not the east/west climb entry labels themselves.
