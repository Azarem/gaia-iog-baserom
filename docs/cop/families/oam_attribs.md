# COP family: OAM attributes

_Ops: `[B2]`, `[B3]`, `[B4]`, `[B5]`, `[B6]`, `[B7]`, `[B8]`, `[B9]`, `[BA]`, `[BB]`_ · _Source: [`cop_handlers_oam_attribs.asm`](../../../extracted/system/engine/cop_handlers_oam_attribs.asm)_

[← COP index](../README.md) · [Sprite staging](sprite_staging.md)

## Overview

Ten opcodes tweak how an actor is **drawn** and how it **collides** with other actors. Four ops (`$B2`–`$B5`) manipulate **collision priority** bits in `$10` (min/max overrides). Two (`$B6`–`$B7`) rewrite **OAM attribute** fields in `$0E` (SNES priority and palette subfields). Four (`$B8`–`$BB`) toggle or set **horizontal/vertical mirror** bits in `$0E`. All are immediate `RTI` continues — no yield.

Handler comments use `SetOamPriority` / `SetOamPalette`; extracted scripts use **`SetSpritePriority`** / **`SetSpritePalette`** (`db-us/copdef.json`).

## Shared state

| Field | Bits | Role |
|-------|------|------|
| `$10` | `$0001` | Collision **minimum** priority override (`$B3` set, `$B5` clear) |
| `$10` | `$0002` | Collision **maximum** priority override (`$B2` set, `$B4` clear) |
| `$0E` | `$3000` | OAM **draw** priority (0–3 in operand; packed into attribute word) |
| `$0E` | `$0E00` | OAM **palette** (0–7 in operand) |
| `$0E` | `$4000` | Horizontal mirror (flip left/right) |
| `$0E` | `$8000` | Vertical mirror |

`$0E` is XOR/merged into the composed OAM entry each frame — these ops change presentation without restaging `$80` animation.

## Family notes

- **Two “priorities”:** `$B2`–`$B5` affect **actor–actor collision** resolution via `$10`. `$B6` affects **BG/OAM layer ordering** only.
- `$B6` / `$B7` **clear** their field mask first (`TRB`), then `XBA` + `TSB` to pack the operand into the high byte of `$0E`.
- Mirror ops only touch `$0E`; they do not change `$12` facing bits (contrast `ProcessAnimFlag` on sprite staging).
- Legacy names: `CollPrioritySetMax/Min`, `CollPriorityClearMax/Min`, `SetSpritePriority/Palette`, `ToggleHFlip/VFlip`, `ClearHFlip`, `SetHFlip` → mirror names above.

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `B2` | `SetPriorityMax` | 14 | (none) | `SetPriorityMax` | Continue |
| `B3` | `SetPriorityMin` | 3 | (none) | `SetPriorityMin` | Continue |
| `B4` | `ClearPriorityMax` | 11 | (none) | `ClearPriorityMax` | Continue |
| `B5` | `ClearPriorityMin` | 1 | (none) | `ClearPriorityMin` | Continue |
| `B6` | `SetSpritePriority` | 106 | `Byte` 0–3 | `SetOamPriority` | Continue |
| `B7` | `SetSpritePalette` | 88 | `Byte` 0–7 | `SetOamPalette` | Continue |
| `B8` | `ToggleHMirror` | 4 | (none) | `ToggleHMirror` | Continue |
| `B9` | `ToggleVMirror` | 10 | (none) | `ToggleVMirror` | Continue |
| `BA` | `ClearHMirror` | 3 | (none) | `ClearHMirror` | Continue |
| `BB` | `SetHMirror` | 23 | (none) | `SetHMirror` | Continue |

**Family call-site total:** 263

## Opcodes

#### COP [B2] — `SetPriorityMax` (collision: prefer winning overlaps)

- **Preferred name:** `SetPriorityMax`
- **Aliases:** `CollPrioritySetMax`
- **Handler:** `SetPriorityMax` @ [`cop_handlers_oam_attribs.asm:704-711`](../../../extracted/system/engine/cop_handlers_oam_attribs.asm)
- **Parameters:** (none)
- **Outcome:** Continue
- **Usage count:** 14

##### What it does

`TSB #$0002` on actor `$10` — actor wins collision priority against actors without max/min overrides.

```asm
SetPriorityMax {
    TYX
    LDA #$0002
    TSB $10
    LDA $0A
    STA $02, S
    RTI
}
```

##### How it is used

Boss phases and invulnerable blinks — Castoth sets max before iframe windows (`incan_ruins/ir29_castoth.asm` uses `ClearPriorityMin` / priority dance nearby). Knight armor enables max during armor shell (`sky_garden/sg4D_knight_armor.asm`).

##### Parameters & contract

| Item | Detail |
|------|--------|
| `$10` | Bit `$0002` set |
| Pairs with | `$B4` to clear |

---

#### COP [B3] — `SetPriorityMin` (collision: defer overlaps)

- **Preferred name:** `SetPriorityMin`
- **Aliases:** `CollPrioritySetMin`
- **Handler:** `SetPriorityMin` @ [`cop_handlers_oam_attribs.asm:716-723`](../../../extracted/system/engine/cop_handlers_oam_attribs.asm)
- **Parameters:** (none)
- **Outcome:** Continue
- **Usage count:** 3

##### What it does

`TSB #$0001` on `$10`.

##### How it is used

Decorations and harmless FX that should not block the player — often cleared again with `$B5` after a cutscene beat.

##### Parameters & contract

| Item | Detail |
|------|--------|
| `$10` | Bit `$0001` set |

---

#### COP [B4] — `ClearPriorityMax`

- **Preferred name:** `ClearPriorityMax`
- **Aliases:** `CollPriorityClearMax`
- **Handler:** `ClearPriorityMax` @ [`cop_handlers_oam_attribs.asm:728-735`](../../../extracted/system/engine/cop_handlers_oam_attribs.asm)
- **Parameters:** (none)
- **Outcome:** Continue
- **Usage count:** 11

##### What it does

`TRB #$0002` on `$10`.

##### How it is used

End of iframe or post-attack cleanup paired with earlier `$B2`.

##### Parameters & contract

| Item | Detail |
|------|--------|
| Effect | Clears max collision override |

---

#### COP [B5] — `ClearPriorityMin`

- **Preferred name:** `ClearPriorityMin`
- **Aliases:** `CollPriorityClearMin`
- **Handler:** `ClearPriorityMin` @ [`cop_handlers_oam_attribs.asm:740-747`](../../../extracted/system/engine/cop_handlers_oam_attribs.asm)
- **Parameters:** (none)
- **Outcome:** Continue
- **Usage count:** 1

##### What it does

`TRB #$0001` on `$10`.

##### How it is used

Castoth and similar bosses restore normal collision after min-priority ghost phase (`ir29_castoth.asm`: `COP [ClearPriorityMin]`).

##### Parameters & contract

| Item | Detail |
|------|--------|
| Effect | Clears min collision override |

---

#### COP [B6] — `SetSpritePriority` (OAM layer priority)

- **Preferred name:** `SetSpritePriority`
- **Aliases:** `SetOamPriority` (handler label)
- **Handler:** `SetOamPriority` @ [`cop_handlers_oam_attribs.asm:752-764`](../../../extracted/system/engine/cop_handlers_oam_attribs.asm)
- **Parameters:** `Byte` value 0–3
- **Outcome:** Continue
- **Usage count:** 106

##### What it does

Clears `$3000` on `$0E`, then merges operand (after `XBA`) into the OAM priority field.

```asm
SetOamPriority {
    TYX
    LDA #$3000
    TRB $0E
    LDA [$0A]
    INC $0A
    AND #$00FF
    XBA
    TSB $0E
    ...
}
```

##### How it is used

Title intro sets priority `#10` (hardware nibble placement via `$0E` packing) — `system/title_screen/sFC_title_intro.asm`:

```asm
COP [SetSpritePriority] ( #10 )
```

Weather particles use high priority so rain draws above playfield (`actors/particle_rain_spawner.asm`: `#30`).

##### Parameters & contract

| Item | Detail |
|------|--------|
| Operand | 0–3 semantic priority; stored in OAM bits 12–13 via `$0E` |
| Not | Collision `$10` bits |

---

#### COP [B7] — `SetSpritePalette` (OAM palette line)

- **Preferred name:** `SetSpritePalette`
- **Aliases:** `SetOamPalette`
- **Handler:** `SetOamPalette` @ [`cop_handlers_oam_attribs.asm:769-781`](../../../extracted/system/engine/cop_handlers_oam_attribs.asm)
- **Parameters:** `Byte` 0–7
- **Outcome:** Continue
- **Usage count:** 88

##### What it does

`TRB #$0E00` then set new palette nibble via `XBA`/`TSB` on `$0E`.

##### How it is used

Status tints and form changes — Yorrick EW/NS variants force palette `#02` (`mountain_temple/mtA1_yorrick_*.asm`). Angkor Wat gorgon / wall-walker flash palette `#0A` during attacks (`awB1_gorgon.asm`, `awB1_wall_walker.asm`).

##### Parameters & contract

| Item | Detail |
|------|--------|
| Operand | Palette index 0–7 |
| Effect | Immediate recolor on next OAM build |

---

#### COP [B8] — `ToggleHMirror` (flip facing left/right)

- **Preferred name:** `ToggleHMirror`
- **Aliases:** `ToggleHFlip`
- **Handler:** `ToggleHMirror` @ [`cop_handlers_oam_attribs.asm:786-794`](../../../extracted/system/engine/cop_handlers_oam_attribs.asm)
- **Parameters:** (none)
- **Outcome:** Continue
- **Usage count:** 4

##### What it does

`EOR #$4000` on `$0E`.

##### How it is used

Alternating facing in idle loops — Castoth (`ir29_castoth.asm`), queen debris (`pyDD_queen_debris.asm`).

##### Parameters & contract

| Item | Detail |
|------|--------|
| `$0E` | Bit `$4000` toggled |

---

#### COP [B9] — `ToggleVMirror`

- **Preferred name:** `ToggleVMirror`
- **Aliases:** `ToggleVFlip`
- **Handler:** `ToggleVMirror` @ [`cop_handlers_oam_attribs.asm:799-807`](../../../extracted/system/engine/cop_handlers_oam_attribs.asm)
- **Parameters:** (none)
- **Outcome:** Continue
- **Usage count:** 10

##### What it does

`EOR #$8000` on `$0E`.

##### How it is used

Rare — upside-down FX or symmetric vertical bob scripts.

##### Parameters & contract

| Item | Detail |
|------|--------|
| `$0E` | Bit `$8000` toggled |

---

#### COP [BA] — `ClearHMirror` (face default / right)

- **Preferred name:** `ClearHMirror`
- **Aliases:** `ClearHFlip`
- **Handler:** `ClearHMirror` @ [`cop_handlers_oam_attribs.asm:812-819`](../../../extracted/system/engine/cop_handlers_oam_attribs.asm)
- **Parameters:** (none)
- **Outcome:** Continue
- **Usage count:** 3

##### What it does

`TRB #$4000` on `$0E`.

##### How it is used

After a mirrored walk cycle, reset facing — Sand Fanger, Draco, Viper armor (`gw8A_sand_fanger.asm`, `angel_village/av6E_draco.asm`, `sg55_viper.asm`).

##### Parameters & contract

| Item | Detail |
|------|--------|
| Effect | Horizontal mirror off |

---

#### COP [BB] — `SetHMirror` (face left)

- **Preferred name:** `SetHMirror`
- **Aliases:** `SetHFlip`
- **Handler:** `SetHMirror` @ [`cop_handlers_oam_attribs.asm:824-831`](../../../extracted/system/engine/cop_handlers_oam_attribs.asm)
- **Parameters:** (none)
- **Outcome:** Continue
- **Usage count:** 23

##### What it does

`TSB #$4000` on `$0E`.

##### How it is used

Dark Gaia comet fight mirrors sprite during approach (`sE8_dark_gaia.asm`: `COP [SetHMirror]` before movement beat).

##### Parameters & contract

| Item | Detail |
|------|--------|
| Effect | Horizontal mirror on |
