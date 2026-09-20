# COP family: Thinkers (spawn / kill)

_Deep-audited ops: `[3B]`, `[3C]`, `[3D]`_ · _Source: [`cop_handlers_thinker.asm`](../../../extracted/system/engine/cop_handlers_thinker.asm)_

[← COP index](../index.md)

## Overview

**Thinkers** are lightweight actors on a separate doubly-linked list (`$005A` / `$005C`) with a LIFO free stack at `$0052`. `[3B]`/`[3C]` allocate via `AllocateSpecialActor`; `[3D]` splices the current actor out and returns the slot to the free stack. Used for palette cyclers, HDMA waves, music loaders, and cutscene helpers.

## Shared state

- `$0052` — Thinker free-stack pointer (indirect store of freed slot addresses)
- `$005A` / `$005C` — Thinker list head / tail
- `$7F0002` (`animScratch+2`) — **Param byte** written by `[3B]`
- `$7F0000` / `$7F0002` — Entry pointer word + bank on new thinker
- `$7F000E` — Cleared on spawn
- `AllocateSpecialActor` — [`actor_pool.asm`](../../../extracted/system/engine/actor_pool.asm)

## Family notes

- **`[3C]`** skips the param byte; entry pointer is the first operand.
- **`[3D]`** does **not** `RTL` — it `RTI`s. Thinker scripts almost always **`COP [KillThinker]` then `RTL`**.
- Spawn copies caller **`animScratch2`** into the new thinker (inherit parent ambient state).

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `3B` | `SpawnThinkerParam` | 21 | `Byte`, `Address` | `SpawnThinkerParam` | Continue |
| `3C` | `SpawnThinker` | 56 | `Address` | `SpawnThinker` | Continue |
| `3D` | `KillThinker` | 29 | — | `KillThinker` | Continue |

**Family call-site total:** 106

## Opcodes

#### COP [3B] — `SpawnThinkerParam` (spawn thinker with parameter)

- **Preferred name:** `SpawnThinkerParam`
- **Handler:** `SpawnThinkerParam` @ [`cop_handlers_palette.asm`](../../../extracted/system/engine/cop_handlers_palette.asm)
- **Usage count:** 21

##### What it does

```asm
SpawnThinkerParam {
    JSR $&actor_pool.AllocateSpecialActor
    TYX
    LDA [$0A]             ; param byte
    INC $0A
    STA $animScratch+2, X
loc_009410:
    LDA [$0A]             ; entry word
    INC $0A
    INC $0A
    STA $0000, X
    LDA [$0A]             ; entry bank
    INC $0A
    STA $0002, X
    ; copy animScratch2 from caller; clear $000E
    RTI
}
```

##### How it is used

Parameterized dispatch (palette bundle id, scene sub-mode). Most common pattern: spawn a `PaletteResetAndKillThinker` with a specific palette index:

```asm
; extracted/system/world_map/WorldMapController.asm — double-buffered palette reset
COP [SpawnThinkerParam] ( #0B, @actor_pool.PaletteResetAndKillThinker )
COP [SpawnThinkerParam] ( #0B, @actor_pool.PaletteResetAndKillThinker )

; extracted/system/inventory/item_use_system.asm — palette cycle on item use
COP [SpawnThinkerParam] ( #2F, @ambient_palette_cycler.PaletteCycleLoop )

; extracted/mu/mu_vampire_lair/mu67_vampires.asm — boss-specific palette reset
COP [SpawnThinkerParam] ( #43, @actor_pool.PaletteResetAndKillThinker )
COP [SpawnThinkerParam] ( #67, @actor_pool.PaletteResetAndKillThinker )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand 1 | `Byte Param` → new thinker `$7F0002` |
| Operand 2 | `Address` far entry (word + bank) |
| Outcome | Continue — thinker runs independently next frame |
| Failure | If allocation fails, behavior matches pool (fail-soft advance) |

---

#### COP [3C] — `SpawnThinker` (spawn thinker)

- **Preferred name:** `SpawnThinker`
- **Handler:** `SpawnThinker` @ [`cop_handlers_palette.asm`](../../../extracted/system/engine/cop_handlers_palette.asm)
- **Usage count:** 56

##### What it does

Same as `[3B]` without reading a param byte — jumps straight to `loc_009410`.

```asm
SpawnThinker {
    JSR $&actor_pool.AllocateSpecialActor
    TYX
    BRA loc_009410
}
```

##### How it is used

Dominant pattern for scene thinkers (ambient dispatcher, sine HDMA, boot logos, dark space Gaia sequences, palette flashes).

```asm
; extracted/watermia/watermia/watermia_festival_palette.asm
COP [SpawnThinker] ( @WatermiaFestivalPaletteWave )

; extracted/itory/moon_tribe_camp/it1A_moon_tribe.asm — one-shot flash
COP [SpawnThinker] ( @oneshot_palette_flash_1F.FlashPalette1F )

; extracted/itory/itory_village/it15_lily.asm — cutscene FX
COP [SpawnThinker] ( @oneshot_palette_flash_18.FlashPalette18 )
COP [SpawnThinker] ( @oneshot_palette_flash_19.FlashPalette19 )

; extracted/gold_ship/adrift/dc2F_adrift.asm — custom ambient
COP [SpawnThinker] ( @code_059BAF )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand | `Address` entry pointer |
| Outcome | Continue |

---

#### COP [3D] — `KillThinker` (unlink and free thinker slot)

- **Preferred name:** `KillThinker`
- **Handler:** `KillThinker` @ [`cop_handlers_palette.asm`](../../../extracted/system/engine/cop_handlers_palette.asm)
- **Usage count:** 29

##### What it does

Unlinks `$0004`/`$0006` from the thinker list (head/tail fixups), then pushes **`X`** (this actor’s slot address) onto the stack at `[$0052]`.

```asm
KillThinker {                      ; cop_handlers_palette.asm:242-279
    TYX 
    LDY $0004, X                   ; Load prev pointer
    BNE loc_009459                 ; Not head → normal splice
    LDY $0006, X                   ; Head removal: next becomes head
    STY $005A
    BEQ loc_00946D
    LDA #$0000
    STA $0004, Y                   ; Clear new head's prev
    BRA loc_00946D

  loc_009459:
    LDA $0006, X                   ; Mid/tail: prev.next = dying.next
    STA $0006, Y
    BNE loc_009466
    STY $005C                      ; Dying was tail: prev becomes new tail
    BRA loc_00946D

  loc_009466:
    TAY 
    LDA $0004, X                   ; next.prev = dying.prev
    STA $0004, Y

  loc_00946D:
    PHD 
    LDA #$0000
    TCD 
    SEP #$20
    DEC $0052                      ; Pre-decrement free-stack pointer ×2
    DEC $0052
    REP #$20
    TXA                            ; Push freed slot onto LIFO stack
    STA [$52]
    PLD 
    LDA $0A
    STA $02, S
    RTI 
}
```

##### How it is used

End of one-shot thinkers (palette flash, coldata tint, credits helper cleanup). Always followed by RTL:

```asm
; extracted/prologue/pr_thinkers.asm — scene prologue cleanup
COP [KillThinker]
RTL 

; extracted/functions/DeathPaletteFadeThinker.asm — death FX done
COP [KillThinker]
RTL 

; extracted/unused/SceneTransPaletteThinker_unused.asm — 3 call sites
COP [KillThinker]
RTL 
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operands | None — always targets **current** actor |
| Outcome | Continue (`RTI`) — script must **`RTL`** to stop executing freed slot |
| Contract | Only call from the thinker’s own script (not from scene actors) |
