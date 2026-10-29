# COP family: Gravity (quadratic fall)

_Deep-audited ops: `[63]`, `[64]`_ · _Source: [`cop_handlers_effects.asm`](../../../extracted/system/engine/cop_handlers_effects.asm)_

[← COP index](../README.md)

## Overview

**Quadratic downward motion** for enemies, debris, and world-map drops. **`[63]`** seeds velocity, acceleration shift factor, and landing Y; **`[64]`** integrates one frame via hardware multiply (`tick × (tick/2)` shifted by factor), updates **`moveScratch2`**, and returns **`A = $FFFF`** once the Y delta is not negative, the actor's `$16` is not negative and the actor has moved past the target Y.

## Shared state

- `$7F1010` (`scratch1010`) — Acceleration **right-shift count** (higher = gentler curve)
- `$7F1012` — Initial upward speed v0 (set by `[63]`, never updated by `[64]`)
- `$7F1014` — Tick counter (incremented each `[64]`)
- `$7F001A` (`moveYAlt`) — Target Y (absolute pixels; here `moveYAlt` holds a pixel Y, not a movement index, so a later `StageMoveY` on the same actor overwrites it)
- `$7F002E` (`moveScratch2`) — Per-frame Y delta written for movement apply (`g − v0`, positive = down)
- `$4202` / `$4203` / `$4216` — `WRMPYA` / `WRMPYB` / `RDMPYL` multiply path

## Family notes

- **`[64]`** returns landing status in **A** through the COP exit path — callers **`CMP #$0000` / `BMI`**: the branch is taken when `A = $FFFF` (landed); otherwise they **`SetEntryHereAndYield`** and tick again.
- Target Y from **`[63]`** operand 3 is **offset × 16** added to current **`$16`**; the offset byte is not sign-extended (bit 7 set negates the product: `$16 − byte × 16`). Every observed call uses `#00`.
- World map flight (`WorldMapController.asm`) and garden crash cutscene reuse the same pair for arcs.

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `63` | `InitGravity` | 25 | `Byte`, `Byte`, `Byte` | `InitGravity` | Continue |
| `64` | `TickGravity` | 20 | — | `TickGravity` | Continue (A=status) |

**Family call-site total:** 45

## Opcodes

#### COP [63] — `InitGravity` (set up gravity state)

- **Preferred name:** `InitGravity`
- **Handler:** `InitGravity` @ [`cop_handlers_effects.asm`](../../../extracted/system/engine/cop_handlers_effects.asm)
- **Usage count:** 25

##### What it does

```asm
InitGravity {                           ; cop_handlers_effects.asm:230-266
    TYX 
    LDA [$0A]                           ; Read signed initial upward speed v0
    INC $0A
    AND #$00FF
    BIT #$0080                          ; Sign-extend if negative
    BEQ loc_009CC4
    ORA #$FF00

  loc_009CC4:
    STA $scratch1010+2, X               ; Initial velocity → scratch+2
    LDA [$0A]                           ; Read shift factor
    INC $0A
    AND #$00FF
    STA $scratch1010, X                 ; Shift count → scratch+0
    LDA [$0A]                           ; Read target Y offset byte
    INC $0A
    AND #$00FF
    ASL                                 ; ×16 (ASL ×4); original bit 7 lands in $0800
    ASL 
    ASL 
    ASL 
    BIT #$0800                          ; Original bit 7 set: negate the product (not a sign extension)
    BEQ loc_009CE7
    EOR #$FFFF
    INC 

  loc_009CE7:
    CLC                                 ; Target Y = $16 + offset × 16
    ADC $16
    STA $moveYAlt, X
    LDA #$0000                          ; Zero tick counter
    STA $scratch1010+4, X
    LDA $0A
    STA $02, S
    RTI 
}
```

##### How it is used

World map flight arcs (dominant), shipwreck Erik, viper arena, Nitropede segments:

```asm
; extracted/system/world_map/WorldMapController.asm — fast drop
COP [InitGravity] ( #20, #05, #00 )

; extracted/system/world_map/WorldMapController.asm — gentle landing bounce
COP [InitGravity] ( #00, #06, #00 )

; extracted/gold_ship/ship_wreck/gs2B_erik.asm — shipwreck fall
COP [InitGravity] ( #08, #07, #00 )

; extracted/sky_garden/viper_lair/sg55_viper_arena.asm — rock projectile
COP [InitGravity] ( #00, #09, #00 )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand 1 | `Byte InitSpeed` — signed initial upward speed v0 (sign-extended; positive = up) |
| Operand 2 | `Byte NegLogA` — count of **`LSR`** on multiply result (damping) |
| Operand 3 | `Byte GndTilePos` — offset byte; target Y = current `$16` + byte × 16 (bit 7 set negates the product); `#00` in every observed call |
| WRAM | `moveYAlt`, `scratch1010+0/+2/+4` |
| Outcome | Continue |

---

#### COP [64] — `TickGravity` (apply one gravity frame)

- **Preferred name:** `TickGravity`
- **Handler:** `TickGravity` @ [`cop_handlers_effects.asm`](../../../extracted/system/engine/cop_handlers_effects.asm)
- **Usage count:** 20

##### What it does

Increments tick t; computes **`RDMPYL`** from **`t × (t>>1)`**, shifts right by the factor (g), and stores **`g − v0`** in **`moveScratch2`** (v0 is never updated; the curve is recomputed from t each call). If that delta is not negative, actor **`$16`** is not negative and **`$16`** has passed **`moveYAlt`**, **`RTI` with `A = $FFFF`**; else **`A = $0000`**.

```asm
TickGravity {                           ; cop_handlers_effects.asm:271-320
    TYX 
    LDA $scratch1010, X                 ; Shift factor → Y
    TAY 
    LDA $scratch1010+4, X              ; Increment tick counter
    INC 
    STA $scratch1010+4, X
    SEP #$20
    STA $WRMPYA                         ; tick → WRMPYA
    LSR 
    STA $WRMPYB                         ; tick>>1 → WRMPYB (≈ tick²/2)
    LDA #$00
    XBA 
    REP #$20
    LDA $RDMPYL                         ; Read hardware multiply result

  loc_009D1A:
    DEY                                 ; Right-shift by factor (gentler curve)
    BMI loc_009D20
    LSR 
    BRA loc_009D1A

  loc_009D20:
    PHA 
    LDA $scratch1010+2, X              ; v0 (initial upward speed, never updated)
    SEC 
    SBC $01, S                          ; v0 − g
    STA $01, S
    PLA 
    EOR #$FFFF                          ; Negate: g − v0
    INC 
    STA $moveScratch2, X                ; Y delta → moveScratch2
    BMI loc_009D4A                      ; Delta negative (still rising): not landed
    LDA $16
    BMI loc_009D4A                      ; Actor Y negative: not landed
    LDA $moveYAlt, X                    ; Target − current
    SEC 
    SBC $16
    BCS loc_009D4A                      ; No borrow: target not reached yet
    LDA $0A
    STA $02, S
    LDA #$FFFF                          ; Landed signal
    RTI 

  loc_009D4A:
    LDA $0A
    STA $02, S
    LDA #$0000                          ; Still falling
    RTI 
}
```

##### How it is used

Tight loop until landing flag:

```asm
code_0AC7FD:
    COP [TickGravity]
    CMP #$0000
    BMI loc_0AC808          ; A = $FFFF (landed): leave the loop; otherwise fall through, yield and tick again
    COP [SetEntryHereAndYield]
    BRA code_0AC7FD         ; sg4D_dynapede.asm:356-360
```

Apply **`moveScratch2`** to position in surrounding movement code (enemy-specific).

##### Parameters & contract

| Item | Value |
|------|-------|
| Operands | None |
| Return | **`A = $FFFF`** landed; **`A = $0000`** still in air |
| Outcome | Continue (status via A) |
| Requires | Prior `[63]` on same actor |
