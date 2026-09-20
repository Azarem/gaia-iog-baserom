# COP family: Palette animation

_Deep-audited ops: `[36]`, `[37]`, `[38]`, `[39]`, `[3A]`_ · _Source: [`cop_handlers_palette.asm`](../../../extracted/system/engine/cop_handlers_palette.asm)_

[← COP index](../index.md)

## Overview

**Palette bundle playback** from bank `$16` (`LoadPaletteBundle` / `DecompressGfxToVram` in `hdma_dma_spc.asm`). Start ops load frame 0 and **yield** (`RTL`); step ops advance frames on subsequent thinker/actor entries until the bundle exhausts (then `RTI` continues the script).

## Shared state

- `$168000` — Palette bundle index / header table (bank `$16`)
- `$7F0000` (`animScratch`) — Current frame pointer during stepping
- `$7F0004` (`retPtr1`) — Outer **repeat count** for `[38]` / `[3A]`
- `$7F0006` (`spritesetPtr`) — Per-frame **delay counter** between palette advances
- `$7F000E` — Frame index reset on `[37]`/`[38]` entry paths
- `LoadPaletteBundle` — Advance bundle cursor; **carry set** = sequence finished
- `DecompressGfxToVram` — Apply staged palette/GFX to CGRAM path

## Family notes

- **`[37]` + `[39]`** is the common loop: start bundle, re-enter script at `[39]` each frame (thinker tick or `SetEntryHereAndYield`).
- **`[38]` + `[3A]`** add **`retPtr1` replays** — entire bundle reruns N times (dream sequence, alarm flashes).
- **`[36]`** is `[37]` with bundle ID forced to **0** (restart global ambient slot).
- Almost always run from **thinkers** spawned via `[3B]`/`[3C]`; field scenes also hit bundles through `global_ambient_dispatcher`.

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `36` | `PaletteRestart` | 2 | — | `PaletteRestart` | Halt |
| `37` | `PaletteStart` | 84 | `Byte` | `PaletteStart` | Halt |
| `38` | `PaletteStartLoop` | 3 | `Byte`, `Byte` | `PaletteStartLoop` | Halt |
| `39` | `PaletteStep` | 85 | — | `PaletteStep` | Halt / Continue |
| `3A` | `PaletteStepLoop` | 3 | — | `PaletteStepLoop` | Halt / Continue |

**Family call-site total:** 177

## Opcodes

#### COP [36] — `PaletteRestart` (restart bundle 0)

- **Preferred name:** `PaletteRestart`
- **Handler:** `PaletteRestart` @ [`cop_handlers_palette.asm`](../../../extracted/system/engine/cop_handlers_palette.asm)
- **Usage count:** 2

##### What it does

Branches into the shared `[37]` path with **bundle ID 0** — resets frame index, loads bundle, decompresses frame 0, yields.

```asm
PaletteRestart {
    TYX
    BRA loc_009370        ; shared tail of PaletteStart
}
```

##### How it is used

Hard reset of the default ambient palette stream (boot / scene re-entry).

```asm
COP [PaletteRestart]              ; prologue/pr_thinkers.asm, title paths
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operands | None (implicit bundle **#0**) |
| Outcome | Halt — pops COP frame and `RTL`; script must re-enter at `[39]` |

---

#### COP [37] — `PaletteStart` (start palette bundle)

- **Preferred name:** `PaletteStart`
- **Handler:** `PaletteStart` @ [`cop_handlers_palette.asm`](../../../extracted/system/engine/cop_handlers_palette.asm)
- **Usage count:** 84

##### What it does

```asm
PaletteStart {
    TYX
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $animScratch+2, X   ; bundle ID
loc_009370:
    STZ $0E                 ; frame index ← 0
    JSL LoadPaletteBundle
    JSL DecompressGfxToVram
    LDA $0A
    STA $00
    PLA
    PLA
    RTL                     ; yield
}
```

Stores bundle ID in `$7F0002`, applies first frame to VRAM/CGRAM staging.

##### How it is used

Character form tints, boss phase colors, boot logos, festival lighting, attack ability flashes.

```asm
COP [PaletteStart] ( #0B )
COP [PaletteStep]                  ; thinkers/global_ambient_dispatcher.asm:37-38 — Will tint
COP [PaletteStart] ( #65 )         ; babel_tower/comet_lair/sE8_dark_gaia.asm — boss palette
COP [PaletteStart] ( #1F )         ; thinkers/oneshot_palette_flash_1F.asm
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand | `Byte BundleId` — index into `$168000` bundle table |
| Outcome | Halt (yield) |
| Pairs with | `[39] PaletteStep` on re-entry |

---

#### COP [38] — `PaletteStartLoop` (start bundle with repeat count)

- **Preferred name:** `PaletteStartLoop`
- **Handler:** `PaletteStartLoop` @ [`cop_handlers_palette.asm`](../../../extracted/system/engine/cop_handlers_palette.asm)
- **Usage count:** 3

##### What it does

Like `[37]`, plus stores **`retPtr1`** from second operand before the first load/yield.

```asm
PaletteStartLoop {
    ; bundle ID → animScratch+2
    ; repeat count → retPtr1
    JSL LoadPaletteBundle
    JSL DecompressGfxToVram
    RTL
}
```

##### How it is used

Looping ambient color cycles (dream palette, gold ship sequences).

```asm
COP [PaletteStartLoop] ( #xx, #yy )
COP [PaletteStepLoop]
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand 1 | `Byte BundleId` |
| Operand 2 | `Byte Iters` — outer loops after each full bundle pass |
| Pairs with | `[3A] PaletteStepLoop` |

---

#### COP [39] — `PaletteStep` (advance one palette frame)

- **Preferred name:** `PaletteStep`
- **Handler:** `PaletteStep` @ [`cop_handlers_palette.asm`](../../../extracted/system/engine/cop_handlers_palette.asm)
- **Usage count:** 85

##### What it does

Decrements `$7F0006` delay; when zero, calls `LoadPaletteBundle`:

- **Carry clear** — more frames: decompress and `RTL` (yield again).
- **Carry set** — bundle done: `RTI` (script continues past step op).

```asm
PaletteStep {
    LDA $spritesetPtr, X
    DEC
    BNE delay_path
    JSL LoadPaletteBundle
    BCC exhausted         ; carry set → RTI continue script
    ; … DecompressGfxToVram … RTL
}
```

##### How it is used

Every thinker palette tick; paired with `[37]` on first entry.

```asm
COP [PaletteStart] ( #0C )
COP [PaletteStep]                  ; global_ambient_dispatcher — Freedan path
COP [PaletteStep]                  ; ending/ending_changed_world/s90_changed_world.asm (long sequences)
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operands | None (state from prior `[37]`/`[38]`) |
| Outcome | Halt while animating; **Continue** when bundle completes |
| Delay | `$7F0006` initialized by bundle header |

---

#### COP [3A] — `PaletteStepLoop` (advance with outer repeat)

- **Preferred name:** `PaletteStepLoop`
- **Handler:** `PaletteStepLoop` @ [`cop_handlers_palette.asm`](../../../extracted/system/engine/cop_handlers_palette.asm)
- **Usage count:** 3

##### What it does

Same delay/frame logic as `[39]`, but when `LoadPaletteBundle` exhausts the bundle, **decrements `retPtr1`** and restarts from frame 0 if repeats remain.

```asm
PaletteStepLoop {
    ; on bundle end:
    LDA $retPtr1, X
    DEC
    BEQ done_rti
    STA $retPtr1, X
    BRA reload_bundle
}
```

##### How it is used

```asm
COP [PaletteStartLoop] ( #bundle, #count )
COP [PaletteStepLoop]              ; gold_ship/dream/dream_palette_loop.asm
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operands | None |
| Outcome | Halt until all frames **and** repeat count consumed, then Continue |
| Requires | Prior `[38]` to set `retPtr1` |
