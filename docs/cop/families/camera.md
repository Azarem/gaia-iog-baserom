# COP family: Camera pan (directional scroll wait)

_Deep-audited ops: `[DC]`, `[DD]`, `[DE]`, `[DF]`_ · _Source: `cop_handlers_effects.asm`_

[← COP index](../index.md)

## Overview

Four **directional camera scroll wait loops** that nudge `$06BE` (`cameraTargetX`) / `$06C2` (`cameraTargetY`) until a bound is reached. Each frame decrements actor **`$2A`**; at underflow, **`CameraScrollStepLookup`** (`cop_handlers_movement.asm`) loads delay + step from the table pointed to by **`$06E0`** / index **`$06E2`**. Step magnitude is **`$2B` low nibble**.

These are **not** general-purpose cutscene pans — they anchor the **forced-walk warp pipeline** (`warps_interaction.asm` → `StartForcedWalk` → `forced_walk.asm`).

## Shared state

- `$06BE` / `$06C2` — Camera target X/Y (scroll position)
- `$06D6` / `$06D8` — `cameraOffsetX` / `cameraOffsetY` (north/west limits)
- `$06DA` / `$06DC` — `cameraBoundsX` / `cameraBoundsY` (east/south limits)
- `$06E0` — `scrollStepTableBase` — pointer to speed/delay table (set before pan)
- `$06E2` — `scrollStepIndex` — cursor into table (reset to 0 before pan)
- `$2A` — Frame delay countdown (per actor)
- `$2B` — Current scroll step (low nibble = pixels per tick)
- `CameraScrollStepLookup` — Returns carry **set** when table exhausted (early RTI continue)

## Family notes

- **Aliases:** extracted scripts use **`CameraPanDown`** etc.; legacy docs say **`PanCameraDown`** — same handlers (`cop_dispatch.asm` `[DC]`–`[DF]`).
- Caller must **`STZ $2A`**, point **`$06E0`** at a `forced_walk_sequence_table` entry, and usually **`COP [SetEntryHere]`** before the pan so re-entry yields correctly.
- On boundary hit, handler **`RTI`s** (script continues). While scrolling, handler **`RTL`s** (yield same COP next frame).
- Usage counts include **all warp-driven forced walks** that invoke the directional actor (not only literal `COP [CameraPan*]` text — the canonical site is one COP per `ForcedWalk*` actor in `forced_walk.asm`).

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `DC` | `CameraPanDown` | 1 | — | `CameraPanDown` | Halt |
| `DD` | `CameraPanUp` | 1 | — | `CameraPanUp` | Halt |
| `DE` | `CameraPanRight` | 1 | — | `CameraPanRight` | Halt |
| `DF` | `CameraPanLeft` | 1 | — | `CameraPanLeft` | Halt |

**Family call-site total:** 4

## Opcodes

#### COP [DC] — `CameraPanDown` (scroll south)

- **Preferred name:** `CameraPanDown`
- **Aliases:** `PanCameraDown`
- **Handler:** `CameraPanDown` @ `extracted/system/engine/cop_handlers_effects.asm`
- **Usage count:** 1

##### What it does

```asm
CameraPanDown {                     ; cop_handlers_effects.asm:374-412
    TYX 
    LDA $2A                         ; Read frame delay counter
    AND #$00FF
    DEC                             ; Decrement; negative → reload step
    BMI loc_00ACF0
    SEP #$20
    STA $2A
    REP #$20
    BRA loc_00ACFE

  loc_00ACF0:
    REP #$20
    JSR $&cop_handlers_movement.CameraScrollStepLookup
    BCC loc_00ACFC                  ; Carry clear = valid step
    LDA $0A                         ; Carry set = table exhausted → resume
    STA $02, S
    RTI 

  loc_00ACFC:
    STA $2A                         ; Reload frame delay

  loc_00ACFE:
    LDA $2B                         ; $2B low nibble = pixels per tick
    AND #$000F
    CLC 
    ADC $cameraTargetY              ; Scroll south
    STA $cameraTargetY
    CMP $cameraBoundsY              ; South boundary
    BPL loc_00AD12                  ; Reached → resume script
    PLA                             ; Not there yet — yield
    PLA 
    RTL 

  loc_00AD12:
    LDA $0A
    STA $02, S
    RTI 
}
```

##### How it is used

```asm
STZ $2A
COP [SetEntryHere]
COP [CameraPanDown]                  ; system/engine/forced_walk.asm:51 — ForcedWalkSouth
JSR $&ApplyScrollOffset
```

Extended warps across the world map and dungeon exits (via `StartForcedWalk` → south default when no N/E/W bit in sequence ID).

##### Parameters & contract

| Item | Value |
|------|-------|
| Operands | None |
| Preconditions | `$06E0` → scroll table; `$06E2` = 0; `$2A` = 0 |
| Stop condition | `$06C2 ≥ cameraBoundsY` |
| Outcome | Halt until bound, then Continue |

---

#### COP [DD] — `CameraPanUp` (scroll north)

- **Preferred name:** `CameraPanUp`
- **Aliases:** `PanCameraUp`
- **Handler:** `CameraPanUp` @ `extracted/system/engine/cop_handlers_effects.asm`
- **Usage count:** 1

##### What it does

Subtracts step from `$06C2` toward **`cameraOffsetY`**. Uses absolute-value fixup when subtraction wraps.

```asm
CameraPanUp {
    ; … same $2A / CameraScrollStepLookup prologue …
    SBC $cameraTargetY    ; subtract step
    ; clamp / compare cameraOffsetY
    RTL or RTI
}
```

##### How it is used

```asm
COP [CameraPanUp]                    ; forced_walk.asm:88 — ForcedWalkNorth
```

Warp sequences with **bit 7** set in the walk sequence byte select north forced walk.

##### Parameters & contract

| Item | Value |
|------|-------|
| Stop condition | `$06C2 ≤ cameraOffsetY` |
| Outcome | Halt until bound |

---

#### COP [DE] — `CameraPanRight` (scroll east)

- **Preferred name:** `CameraPanRight`
- **Aliases:** `PanCameraRight`
- **Handler:** `CameraPanRight` @ `extracted/system/engine/cop_handlers_effects.asm`
- **Usage count:** 1

##### What it does

Adds step to **`$06BE`** until **`cameraBoundsX`**.

```asm
CameraPanRight {
    ADC $cameraTargetX
    CMP $cameraBoundsX
    BPL done_rti
    RTL
}
```

##### How it is used

```asm
COP [CameraPanRight]                 ; forced_walk.asm:162 — ForcedWalkEast
```

East forced walk when sequence ID has **bit 4** (`StartForcedWalk` decode).

##### Parameters & contract

| Item | Value |
|------|-------|
| Stop condition | `$06BE ≥ cameraBoundsX` |

---

#### COP [DF] — `CameraPanLeft` (scroll west)

- **Preferred name:** `CameraPanLeft`
- **Aliases:** `PanCameraLeft`
- **Handler:** `CameraPanLeft` @ `extracted/system/engine/cop_handlers_effects.asm`
- **Usage count:** 1

##### What it does

Subtracts step from **`$06BE`** toward **`cameraOffsetX`** (mirror of `[DD]` on X axis).

```asm
CameraPanLeft {
    SBC $cameraTargetX
    CMP $cameraOffsetX
    ; RTL until at west bound
}
```

##### How it is used

```asm
COP [CameraPanLeft]                  ; forced_walk.asm:125 — ForcedWalkWest
```

West forced walk when sequence ID has **bit 5**.

##### Parameters & contract

| Item | Value |
|------|-------|
| Stop condition | `$06BE ≤ cameraOffsetX` |

##### Forced-walk integration (all four)

| Step | Action |
|------|--------|
| 1 | Warp handler sets `$06E0` from `forced_walk_sequence_table` |
| 2 | `STZ $2A`, `STZ $06E2`, mask joypad |
| 3 | `COP [SetEntryHere]` + directional pan op |
| 4 | `ApplyScrollOffset`, refresh player sprite, `SyncPlayerToCamera`, `COP [Die]` |

Credits use a **separate** thinker pan (`DiaryCameraPan` / `crF7_credits_camera_pan.asm`) — not these COPs.
