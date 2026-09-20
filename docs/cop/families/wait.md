# COP family: Wait

_Ops: `[DA]`, `[DB]`_ · _Source: `extracted/system/engine/cop_handlers_flow.asm`_

[← COP index](../index.md)

## Overview

Frame-based delays for actor scripts. Both opcodes load a countdown into **`$08`**, save the resume entry (**`$0A`/`$0C` → `$00`/`$02`**), and **`RTL`**. The engine decrements **`$08`** each tick; at zero the actor resumes at the saved entry (the byte **after** the wait COP). **`WaitWord`** reuses the same tail as **`WaitByte`** for delays longer than 255 frames.

## Shared state

| Symbol | Role |
|--------|------|
| `$00` / `$02` | Entry pointer while waiting (post-COP resume) |
| `$08` | Frames remaining (0 = run script) |
| `$0A` / `$0C` | Script cursor during handler execution |

## Family notes

- **`WaitByte ( #00 )`** yields one frame — common between spawns to stagger pool allocation.
- **`WaitByte ( #3B )`** ≈ 1 second at 60 Hz; **`#$77`**, **`#B3`**, **`#EF`** appear heavily in dialog pacing.
- **`WaitWord`** used for multi-second boss/cutscene holds (**`#$0120`**, **`#$01DF`**, **`#$00EF`**).
- Unlike **`JumpAfterDelay` (`[C3]`)**, waits do **not** jump to an arbitrary `@Code` — execution continues linearly after the wait.
- Unlike **`SetEntryHereAndYield` (`[C2]`)**, waits specify an explicit frame count in **`$08`**.

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `DA` | `WaitByte` | 713 | `Byte` | `WaitByte` | Halt |
| `DB` | `WaitWord` | 41 | `Word` | `WaitWord` | Halt |

**Family call-site total:** 754

---

## Opcodes

#### COP [DA] — `WaitByte` (delay 0–255 frames)

- **Handler:** `WaitByte` @ `cop_handlers_flow.asm:602-617`
- **Parameters:** `Byte Frames` (`db-us/copdef.json`)
- **Usage count:** 713

##### What it does

1. Read 8-bit frame count from script.
2. **`STA $08`** — timer for engine tick decrement.
3. **`$0C` → `$02`**, **`$0A` → `$00`** — resume after wait COP.
4. **`PLA PLA RTL`** — yield until **`$08 == 0`**.

##### Handler excerpt

```asm
WaitByte {
    TYX
    LDA [$0A]
    INC $0A
    AND #$00FF

  loc_00ACC9:
    STA $08
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    PLA
    PLA
    RTL
}
```

##### How it is used

Dialog pacing, animation holds, music start delays, chest sync:

```asm
; extracted/ending/ending_comet/sE5_epilogue.asm
COP [WaitByte] ( #B3 )
COP [PrintDialogString] ( &dialogstring_0BD558 )
COP [WaitByte] ( #77 )

; extracted/system/diary_menu/sFA_diary_menu.asm
COP [WaitByte] ( #1D )

; extracted/system/engine/warps_interaction.asm (chest opening sequence)
COP [WaitByte] ( #0B )
```

Dark Gaia fight — mixed short waits in attack loops:

```asm
; extracted/babel_tower/comet_lair/sE8_dark_gaia.asm
COP [WaitByte] ( #3B )
COP [WaitByte] ( #77 )
COP [WaitByte] ( #0E )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand | 1 byte, `$00`–`$FF` |
| Resume PC | First byte **after** `WaitByte` operand |
| **`$08`** | Countdown; shared with **`JumpAfterDelay`** semantics |

##### Relation to similar ops

| Op | Difference |
|----|------------|
| `[DB]` | 16-bit frame count |
| `[C2]` | One-frame yield without **`$08`** |
| `[C3]` | Jump to **`@Code`** after delay, not linear resume |
| `[D2]` | Wait on **flag**, not frame count |

---

#### COP [DB] — `WaitWord` (delay 0–65535 frames)

- **Handler:** `WaitWord` @ `cop_handlers_flow.asm:622-628` (falls into **`loc_00ACC9`**)
- **Parameters:** `Word Frames`
- **Usage count:** 41

##### What it does

Read 16-bit count, branch to shared **`loc_00ACC9`** — identical store-to-**`$08`** / entry save / **`RTL`** path as **`WaitByte`**.

##### Handler excerpt

```asm
WaitWord {
    TYX
    LDA [$0A]
    INC $0A
    INC $0A
    BRA loc_00ACC9
}
```

##### How it is used

Long intro holds and boss phase timing:

```asm
; extracted/babel_tower/comet_lair/sE8_dark_gaia.asm
COP [WaitWord] ( #$01DF )
COP [WaitWord] ( #$012B )

; extracted/ending/ending_new_babel/s89_new_babel.asm
COP [WaitWord] ( #$00EF )
COP [WaitWord] ( #$01DF )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand | 2 bytes little-endian frame count |
| Use when | Delay **> 255** frames (~4.3 s+) |

##### Relation to similar ops

| Op | Difference |
|----|------------|
| `[DA]` | 8-bit count only |
| `[C3]` | Far jump + word delay in one COP |

##### Timing reference (60 fps)

| Frames | Approx. time |
|-------:|--------------|
| `#1D` (29) | ~0.5 s |
| `#3B` (59) | ~1.0 s |
| `#77` (119) | ~2.0 s |
| `#B3` (179) | ~3.0 s |
| `#EF` (239) | ~4.0 s |
| `#$0120` (288) | ~4.8 s |
| `#$01DF` (479) | ~8.0 s |
