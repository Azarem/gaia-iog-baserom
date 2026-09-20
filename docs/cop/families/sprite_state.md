# COP family: Sprite state

_Ops: `[55]`, `[56]`_ · _Source: `extracted/system/engine/cop_handlers_sprite.asm`_

[← COP index](../index.md) · [Sprite animation](sprite_anim.md) · [Sprite staging](sprite_staging.md)

## Overview

Two opcodes for **reinitializing** and **stepping** a secondary animation path that reads frame data through **`$24`** (spriteset base / scratch pointer) and uploads tiles via **VRAM DMA** (`$00B2` pending flag). This pipeline is distinct from the usual `$88` + `$80` + `$89` metasprite path driven by `UpdateActorAnimation`.

Typical use: lightweight FX actors (particles, ambient sprites) that call `SetMetasprite`, then `$55`/`$56` instead of staging/AnimOnce.

**Legacy script names (comments / old docs):** `$55` = `ResetSpriteInit` → **`ResetSpriteState`**; `$56` = `LoadSpriteAnimGlobal` → **`AdvanceSpriteAnim`**.

## Shared state

| Symbol / WRAM | Role |
|---------------|------|
| `$28` | Animation **sequence** index (table of pointers into frame data) |
| `$2A` | Frame index within sequence (incremented each successful `$56` step) |
| `$24` | Word operand from `$55` — spriteset / table base used with `$00B0` DMA staging |
| `$7F0006,X` / `$7F0008,X` | Metasprite pointer + bank (from `$88`; `$56` reads bank from `$7F0008`) |
| `$7F0000,X` (`animScratch`) | Tile destination base for DMA source calculation |
| `$00B2` | Nonzero while VRAM DMA pending — `$56` yields until clear |
| `$00B0`, `$00AC`, `$00AE` | DMA staging addresses / size |

## Family notes

- **`$55` then `$56`:** Reset index and pointer, then advance frames until sequence sentinel (negative word) resets `$2A` and continues script.
- **`$56` yield rule:** If DMA busy, **`RTL`** without advancing `$2A`; retry next tick.
- Not interchangeable with **`AnimOnce`** — different table layout (4-byte frame entries, DMA tile pull) and `$24`-centric addressing.

## Usage statistics

| Op | Name (script) | Uses | Params | Handler | Outcome |
|----|---------------|-----:|--------|---------|---------|
| `55` | `ResetSpriteState` | 4 | `Byte`, `Word` | `ResetSpriteState` | Continue |
| `56` | `AdvanceSpriteAnim` | 4 | (none) | `AdvanceSpriteAnim` | Halt while DMA pending; Continue on frame step |

**Family call-site total:** 8

## Opcodes

#### COP [55] — `ResetSpriteState` (reset anim index + frame + table pointer)

- **Handler:** `ResetSpriteState` @ `extracted/system/engine/cop_handlers_sprite.asm:25-42`
- **Legacy name:** `ResetSpriteInit`
- **Parameters:** `Byte` anim index, `Word` pointer (stored to `$24`)
- **Outcome:** Continue
- **Usage count:** 4

##### What it does

Sets `$28` from the first byte, clears **`$2A`**, stores the word operand in **`$24`**, then saves script bank and PC like other COP handlers.

```asm
ResetSpriteState {
    TYX
    LDA [$0A]             ; animation index
    INC $0A
    AND #$00FF
    STA $28
    STZ $2A               ; frame 0
    LDA [$0A]             ; spriteset / table pointer word
    INC $0A
    INC $0A
    STA $24
    LDA $0C
    STA $02
    LDA $0A
    STA $00               ; entry cache
    STA $02, S
    RTI
}
```

Line-by-line:

1. **Anim index → `$28`** — selects which sequence pointer in the metasprite set table (used by `$56`).
2. **`STZ $2A`** — always restart from first frame of sequence.
3. **Word → `$24`** — base for DMA setup in `$56` (combined with `$7F0006` indexing).
4. **Script bookkeeping** — same `$00`/`$02`/`$02,S` pattern as staging handlers.

Does **not** call DMA or change `$7F0006` — `$88` (`SetMetasprite`) usually runs immediately before this pair.

##### How it is used

Snake pit FX (`extracted/angkor_wat/snake_pit/awB4_snake_pit_fx.asm`):

```asm
COP [SetMetasprite] ( @spriteset_particle_fx )
COP [ResetSpriteState] ( #00, #$2020 )
COP [AdvanceSpriteAnim]
RTL
```

Freejia laborer NPC (`extracted/freejia/freejia/fr32_laborer_npc.asm`):

```asm
COP [ResetSpriteState] ( #00, #$3FE0 )
COP [AdvanceSpriteAnim]
...
COP [ResetSpriteState] ( #01, #$3FF0 )
COP [AdvanceSpriteAnim]
```

Gold ship adrift FX (`extracted/gold_ship/adrift/dc2F_adrift_fx.asm`):

```asm
COP [ResetSpriteState] ( #00, #$2010 )
COP [AdvanceSpriteAnim]
```

##### Parameters & contract

| Item | Detail |
|------|--------|
| Byte | Initial `$28` (sequence index) |
| Word | Stored in **`$24`** — not the same as `$7F0006` but used together in `$56` |
| Follow-up | One or more **`AdvanceSpriteAnim`** (`$56`) or script `RTL` |

##### Relations

- **`$88`:** Sets `$7F0006`/`$7F0008`; `$55` sets `$28`/`$2A`/`$24` for the DMA path.
- **`$80` / `$89`:** Metasprite composition path — different handlers and table interpretation.

---

#### COP [56] — `AdvanceSpriteAnim` (step global/table animation + DMA tile)

- **Handler:** `AdvanceSpriteAnim` @ `cop_handlers_sprite.asm:47-113`
- **Legacy name:** `LoadSpriteAnimGlobal`
- **Parameters:** none
- **Outcome:** Halt while `$00B2` DMA pending; Continue (`RTI`) when a frame is staged; **`RTI`** when sequence ends (negative sentinel)
- **Usage count:** 4

##### What it does

1. If **`$00B2 ≠ 0`**, DMA still in flight → pop COP frame, **`RTL`** (yield).
2. Otherwise save bank, set **`$00B0`** from **`$24`**, switch DBR to **`$7F0008,X`**, index sequence via **`$28 * 2 + spritesetPtr`**, use **`$2A`** as frame index (4 bytes per frame).
3. Read frame word; if **negative** (`BMI`), end of sequence → **`STZ $2A`**, **`RTI`**.
4. Else compute ROM tile source from metasprite header + **`animScratch`**, set **`$00B2`** to `$20` or `$80` transfer size, **`RTL`** (DMA scheduled; script continues next tick).

```asm
AdvanceSpriteAnim {
    TYX
    LDA $00B2
    BEQ loc_0099FE
    PLA                   ; DMA pending → yield
    PLA
    RTL

  loc_0099FE:
    PHB
    LDA $24
    STA $00B0
    SEP #$20
    LDA $7F0008, X
    PHA
    PLB
    REP #$20
    LDA $28
    ASL
    CLC
    ADC $spritesetPtr, X
    TAY
    LDA $2A
    INC $2A                 ; advance for next call
    ASL
    ASL
    CLC
    ADC $0000, Y
    TAY
    LDA $0000, Y
    BMI loc_009A5F          ; end sentinel
    ; … build DMA from metasprite entry …
    STA $00B2               ; mark pending
    PLB
    PLA
    PLA
    RTL

  loc_009A5F:
    STZ $2A
    PLB
    LDA $0A
    STA $02, S
    RTI
}
```

##### How it is used

Always appears right after `$55` in the same init block (see examples under `$55`). Scripts may call `$56` once per actor tick from a persistent entry (`RTL` after first frame) or chain multiple `$56` invocations across frames until the sequence sentinel fires.

##### Parameters & contract

| Item | Detail |
|------|--------|
| Preconditions | `$88` + `$55` (or equivalent init of `$7F0006`, `$28`, `$24`) |
| `$2A` | Incremented each successful frame; cleared on sentinel |
| Yield | **`RTL`** when DMA busy or after scheduling DMA |
| Completion | Negative frame word → `$2A` cleared, script **`RTI`** continues |

##### Relations

- **`$89` / `$8B`:** Use `UpdateActorAnimation` on staged `$28` — no `$00B2` DMA gate.
- **`$8B`:** Also single-step, but same metasprite pipeline as `$89`, not `$56`’s table walk.
