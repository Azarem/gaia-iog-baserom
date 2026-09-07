# Bank $00 — Hardware Math Helpers & Movement Initialization

**Address range:** `$008D25`–`$008FDC`  
**Source file:** `extracted/system/engine/cop_handlers_collision.asm`  
**Related:** [`cop-dispatch.md`](cop-dispatch.md) (COP `$22` MoveToward, `$52` StageMove, `$53` TickMove)

These routines implement the hardware-accelerated math pipeline and smooth-movement state initialization used by IOG's actor movement COPs. All multiply/divide operations use the SNES WRAM-mapped math registers at `$4202`–`$4217`.

---

## SNES Math Register Map

| Register | Address | Role in these routines |
|----------|---------|------------------------|
| `$WRMPYA` | `$4202` | Multiplicand A (8-bit) |
| `$WRMPYB` | `$4203` | Multiplicand B (8-bit) |
| `$RDMPYL` | `$4216` | Product low byte (read after 8-cycle delay) |
| `$RDMPYH` | `$4217` | Product high byte |
| `$WRDIVL` | `$4204` | Dividend low byte |
| `$WRDIVH` | `$4205` | Dividend high byte |
| `$WRDIVB` | `$4206` | Divisor (8-bit) |
| `$RDDIVL` | `$4214` | Quotient low byte (read after pipeline delay) |

---

### ReadMultiplyResult

| Property | Value |
|----------|-------|
| **Old name** | `sub_008D25` |
| **New name** | `ReadMultiplyResult` |
| **Address** | `$008D25` |
| **Size** | 5 bytes |
| **Type** | Leaf subroutine |

#### Description

Provides the mandatory pipeline delay after writing to `$WRMPYB`, then reads the 16-bit product low byte from `$RDMPYL` into Y. The WDC 65C816 hardware multiplier requires approximately 8 cycles between writing `$WRMPYB` and reading `$RDMPYL`; the single `NOP` (2 cycles) combined with the `JSR` overhead and `LDY` absolute addressing satisfies this timing when called from `MultiplyThenDivide`.

#### Algorithm

```
1. NOP                    ; Pipeline delay for hardware multiplier
2. LDY $RDMPYL            ; Product low byte → Y
3. RTS
```

#### Source

```840:844:extracted/system/engine/cop_handlers_collision.asm
ReadMultiplyResult {
    NOP 
    LDY $RDMPYL
    RTS 
}
```

#### Variables

| Location | Direction | Role |
|----------|-----------|------|
| `$WRMPYB` | Input (preset) | Multiplicand B — must be written before call |
| `$WRMPYA` | Input (preset) | Multiplicand A — must be written before call |
| `$RDMPYL` | Read | Product low byte |
| `Y` | Output | Product low byte |

#### Cross-References

| Symbol | Relationship |
|--------|--------------|
| `MultiplyThenDivide` | Sole caller |

---

### ReadDivideResult

| Property | Value |
|----------|-------|
| **Old name** | `sub_008D2A` |
| **New name** | `ReadDivideResult` |
| **Address** | `$008D2A` |
| **Size** | 9 bytes |
| **Type** | Leaf subroutine |

#### Description

Provides the pipeline delay after writing `$WRDIVL`/`$WRDIVB`, then reads the quotient from `$RDDIVL` into A. The hardware divider requires a longer delay than the multiplier; five consecutive `NOP` instructions (10 cycles) plus call overhead ensures a valid result.

#### Algorithm

```
1. NOP × 5               ; Pipeline delay for hardware divider
2. LDA $RDDIVL           ; Quotient low byte → A
3. RTS
```

#### Source

```846:854:extracted/system/engine/cop_handlers_collision.asm
ReadDivideResult {
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    LDA $RDDIVL
    RTS 
}
```

#### Variables

| Location | Direction | Role |
|----------|-----------|------|
| `$WRDIVL` | Input (preset) | Dividend low byte |
| `$WRDIVB` | Input (preset) | Divisor |
| `$RDDIVL` | Read | Quotient low byte |
| `A` | Output | Quotient |

#### Cross-References

| Symbol | Relationship |
|--------|--------------|
| `MultiplyThenDivide` | Sole caller |

---

### MultiplyThenDivide

| Property | Value |
|----------|-------|
| **Old name** | `sub_008D33` |
| **New name** | `MultiplyThenDivide` |
| **Address** | `$008D33` |
| **Size** | 26 bytes |
| **Type** | Combined math helper |

#### Description

Performs a combined 8×8 multiply followed by 16÷8 division in a single call. Computes `(A × step) ÷ (totalSteps − 1)` where the step counter is in `$24` (caller preset in `$WRMPYA`) and the total step count is in `$7F000E,X`. Stores the 8-bit quotient in direct-page `$0000`.

Used by COP `$22` (MoveToward) to compute per-frame pixel velocity along each axis: the distance (`A` = `$7F0018,X` or `$7F001A,X`) times the current step index, divided by the total step count minus one.

#### Algorithm

```
1. STA $WRMPYB              ; Multiplicand B ← distance (8-bit from caller's A)
2. JSR ReadMultiplyResult   ; Y ← ($24 × distance) low byte; $WRMPYA preset by caller
3. STY $WRDIVL              ; Dividend ← product
4. LDA $7F000E,X; DEC       ; Divisor ← total steps − 1
5. STA $WRDIVB
6. BEQ loc_008D49           ; Skip divide if divisor = 0 (avoids div-by-zero)
7. JSR ReadDivideResult     ; A ← quotient
8. STA $0000                ; Store result
9. RTS
```

**Caller contract:** Before `JSR`, the caller must set `$WRMPYA` to the current step index (`$24`) in 8-bit mode.

#### Source

```856:869:extracted/system/engine/cop_handlers_collision.asm
MultiplyThenDivide {
    STA $WRMPYB
    JSR $&ReadMultiplyResult
    STY $WRDIVL
    LDA $7F000E, X
    DEC 
    STA $WRDIVB
    BEQ loc_008D49
    JSR $&ReadDivideResult

  loc_008D49:
    STA $0000
    RTS 
}
```

#### Variables

| Location | Direction | Role |
|----------|-----------|------|
| `A` (input) | Input | 8-bit distance ($7F0018,X or $7F001A,X) |
| `$WRMPYA` | Input (preset) | Current step index ($24) |
| `$WRMPYB` | Write | Distance operand |
| `$RDMPYL` | Read | Intermediate product |
| `$WRDIVL` | Write | Dividend = product |
| `$WRDIVB` | Write | Divisor = `$7F000E,X − 1` |
| `$7F000E,X` | Read | Total step count (low byte) |
| `$0000` | Output | 8-bit quotient |
| `A` (output) | Output | Same quotient (from divide or unchanged on zero divisor) |

#### Cross-References

| Symbol | Relationship |
|--------|--------------|
| `MoveToward` ($008C77 / COP `$22`) | Calls twice per tick — X axis then Y axis |
| `ReadMultiplyResult` | Called internally |
| `ReadDivideResult` | Called internally |

---

### InitSmoothMovement

| Property | Value |
|----------|-------|
| **Old name** | `sub_008D4D` |
| **New name** | `InitSmoothMovement` |
| **Address** | `$008D4D` |
| **Size** | 153 bytes |
| **Type** | Movement initialization |

#### Description

Initializes actor smooth-movement state from script parameters when COP `$22` (MoveToward) begins a new movement. Reads the sprite/animation flag and speed from script args, computes absolute X/Y deltas from the actor's current position to target coordinates already stored in `$7F0018,X` / `$7F001A,X`, determines step count via hardware divide, and sets the movement-active flag.

Called only when `$7F002A,X` bit 1 is clear (actor not already moving). On completion, sets bit 1 to mark the actor as in-motion.

#### Algorithm

```
1. STZ $0004                           ; Clear direction scratch
2. Save $0A − 2 → $00                   ; Rewind pointer for halt/yield resume
3. Read anim/sprite byte from [$0A]:
   - If $FF → use current $28 (no change)
   - Else → ProcessAnimFlag(A)
4. Compute |target_X − actor_X|:
   - $7F0018,X SEC SBC $14
   - If negative → negate (EOR #$FFFF; INC)
   - ROR $0004 (record X sign in carry chain)
   - Cap at $FE if > $FF
   - Store absolute delta → $7F0018,X
5. Compute |target_Y − actor_Y|:
   - Same pattern using $7F001A,X and $16
   - ROR $0004 (record Y sign)
   - Cap at $FE
   - Store → $7F001A,X
6. Select larger delta for step calculation:
   - Compare $7F001A,X vs $7F0018,X; take max in A
7. Read speed from [$0A+1]:
   - JSL UnsignedDivide (Bank $02 $281E8): A ÷ speed
   - INC → $7F000E,X (step count + 1)
   - Speed byte → $7F000F,X
8. Clear movement accumulators:
   - $7F0000,X ← 0 (X sub-pixel accumulator)
   - $7F0002,X ← 0 (frame counter)
   - $24 ← 0 (step index)
   - $2C, $2E ← 0 (per-frame velocity)
9. $7F002A,X OR #$0002 (set moving flag)
10. RTS
```

#### Variables

| Location | Direction | Role |
|----------|-----------|------|
| `$7F0018,X` | In/Out | Input: target X; Output: absolute X distance |
| `$7F001A,X` | In/Out | Input: target Y; Output: absolute Y distance |
| `$7F000E,X` | Write | Step count + 1 (total frames for movement) |
| `$7F000F,X` | Write | Speed parameter from script |
| `$7F0000,X` | Write | X sub-pixel accumulator (cleared) |
| `$7F0001,X` | Write | Y sub-pixel accumulator (implicit via `$7F0000+2`) |
| `$7F0002,X` | Write | Animation/frame wait counter (cleared) |
| `$7F002A,X` | R/W | Bit 1 set = actor is moving |
| `$0004` | Temp | Direction sign bits during computation |
| `$14` / `$16` | Read | Actor current X/Y pixel position |
| `$28` | R/W | Sprite set index (via ProcessAnimFlag) |
| `$0A` | Read | Script argument pointer |
| `$24` | Write | Step index (cleared to 0) |
| `$2C` / `$2E` | Write | Per-frame velocity (cleared) |

#### Cross-References

| Symbol | Relationship |
|--------|--------------|
| `MoveToward` (COP `$22`) | Caller — `JSR $&InitSmoothMovement` when not already moving |
| `ProcessAnimFlag` ($009F5F) | Called for sprite/anim byte processing |
| `UnsignedDivide` (Bank $02 `$281E8`) | Step count = max_delta ÷ speed |
| `MultiplyThenDivide` | Used by MoveToward after init for per-frame velocity |
| `StageMove` (COP `$52`) | Alternative movement init path (does not call this routine) |

---

### HalveMovementDistance

| Property | Value |
|----------|-------|
| **Old name** | `sub_008EF1` |
| **New name** | `HalveMovementDistance` |
| **Address** | `$008EF1` |
| **Size** | 28 bytes |
| **Type** | Movement scaling helper |

#### Description

Halves both X and Y movement distances when the absolute delta exceeds one byte ($FF). Each halving increments a sub-step counter in `$7F000A,X`, allowing COP `$52` (StageMove) to represent large distances using multiple halving passes before computing the final step count.

This is the mechanism behind StageMove's loop that repeatedly LSRs distances > $FF: each iteration calls this routine, doubling the effective precision by trading distance magnitude for sub-step count.

#### Algorithm

```
1. LDA $7F0018,X; LSR → STA $7F0018,X    ; Halve X distance
2. LDA $7F001A,X; LSR → STA $7F001A,X    ; Halve Y distance
3. LDA $7F000A,X; INC → STA $7F000A,X    ; Increment sub-step counter
4. RTS
```

#### Source

```1088:1099:extracted/system/engine/cop_handlers_collision.asm
HalveMovementDistance {
    LDA $7F0018, X
    LSR 
    STA $7F0018, X
    LDA $7F001A, X
    LSR 
    STA $7F001A, X
    LDA $7F000A, X
    INC 
    STA $7F000A, X
    RTS 
}
```

#### Variables

| Location | Direction | Role |
|----------|-----------|------|
| `$7F0018,X` | R/W | X distance — halved in place |
| `$7F001A,X` | R/W | Y distance — halved in place |
| `$7F000A,X` | R/W | Sub-step counter — incremented |

#### Cross-References

| Symbol | Relationship |
|--------|--------------|
| `StageMove` (COP `$52`) | Caller — loop while distance > $FF, and once more if step count overflows |
| `TickMove` (COP `$53`) | Consumer — decrements `$7F000A,X` when primary steps complete |

---

### MovementVelocityCompute

| Property | Value |
|----------|-------|
| **Old name** | `sub_008FDC` |
| **New name** | `MovementVelocityCompute` |
| **Address** | `$008FDC` |
| **Size** | 32 bytes |
| **Type** | Combined math helper (TickMove variant) |

#### Description

Similar to `MultiplyThenDivide` but optimized for COP `$53` (TickMove). Computes per-frame velocity along one axis using inline multiply/divide with a longer NOP pipeline for the divider. Unlike `MultiplyThenDivide`, it reads `$RDMPYL` directly after storing `$WRMPYB` (relying on `$WRMPYA` being preset), sets **carry** before storing the quotient (for the caller's `SBC` accumulation), and does not use the helper subroutines.

The carry flag on exit is significant: the caller (`TickMove`) executes `SBC $7F0000,X` or `SBC $7F0001,X` to subtract the accumulated sub-pixel position from the new velocity quotient, detecting when a whole pixel of movement should be applied.

#### Algorithm

```
1. STA $WRMPYB              ; Distance (8-bit) ← caller's A
2. LDA $7F000E,X; DEC       ; Divisor ← total steps − 1
3. LDY $RDMPYL              ; Read product inline ($WRMPYA preset = $24)
4. STY $WRDIVL              ; Dividend ← product
5. STA $WRDIVB              ; Divisor
6. NOP × 5                  ; Divider pipeline delay (inline, no subroutine)
7. REP #$20; SEC             ; Set carry for caller's SBC
8. LDA $RDDIVL → STA $0000   ; Quotient
9. RTS
```

#### Source

```1218:1235:extracted/system/engine/cop_handlers_collision.asm
MovementVelocityCompute {
    STA $WRMPYB
    LDA $7F000E, X
    DEC 
    LDY $RDMPYL
    STY $WRDIVL
    STA $WRDIVB
    NOP 
    NOP 
    NOP 
    NOP 
    NOP 
    REP #$20
    SEC 
    LDA $RDDIVL
    STA $0000
    RTS 
}
```

#### Variables

| Location | Direction | Role |
|----------|-----------|------|
| `A` (input) | Input | 8-bit axis distance |
| `$WRMPYA` | Input (preset) | Step index ($24) |
| `$WRMPYB` | Write | Distance operand |
| `$RDMPYL` | Read | Product (read without explicit delay — `$WRMPYA` written earlier in TickMove) |
| `$WRDIVL` / `$WRDIVB` | Write | Division operands |
| `$7F000E,X` | Read | Total step count |
| `$0000` | Output | 8-bit quotient |
| `C` | Output | **Set** — caller uses `SBC` for accumulator subtraction |

#### Cross-References

| Symbol | Relationship |
|--------|--------------|
| `TickMove` (COP `$53`) | Caller — Y axis first, then X axis (note reversed order vs MoveToward) |
| `MultiplyThenDivide` | Functional equivalent for MoveToward path |

---

## Movement System Integration

```
  COP $22 MoveToward                    COP $52 StageMove
        │                                     │
        ▼                                     ▼
  InitSmoothMovement                   ProcessAnimFlag
  (first frame only)                   + distance halving loop
        │                                     │
        ▼                                     ▼
  MultiplyThenDivide ×2                HalveMovementDistance
  (X then Y velocity)                  (while delta > $FF)
        │                                     │
        ▼                                     ▼
  Update $7F002C/E (velocity)          Hardware divide → step count
  + $7F0000/1 (accumulators)           + direction flags in $7F000E
        │                                     │
        ▼                                     ▼
  COP $53 TickMove (per-frame)
        │
        ▼
  MovementVelocityCompute ×2
  (Y then X, carry-set SBC)
        │
        ▼
  Apply $7F002C/E → $14/$16
```

### Actor WRAM Movement Fields ($7F0000,X)

| Offset | Size | Field | Set By |
|--------|------|-------|--------|
| `+$0000` | 1 | X sub-pixel accumulator | MoveToward, TickMove |
| `+$0001` | 1 | Y sub-pixel accumulator | MoveToward, TickMove |
| `+$0002` | 1 | Animation frame wait | InitSmoothMovement, StageMove |
| `+$0003` | 1 | Extra frame counter | TickMove |
| `+$000A` | 1 | Sub-step counter (halving) | HalveMovementDistance |
| `+$000E` | 2 | Step count + direction flags | InitSmoothMovement, StageMove |
| `+$000F` | 1 | Speed parameter | InitSmoothMovement |
| `+$0018` | 2 | X distance (pixels) | InitSmoothMovement, StageMove |
| `+$001A` | 2 | Y distance (pixels) | InitSmoothMovement, StageMove |
| `+$002A` | 2 | Extra flags (bit 1 = moving) | InitSmoothMovement |
| `+$002C` | 2 | Per-frame X velocity | MoveToward, TickMove |
| `+$002E` | 2 | Per-frame Y velocity | MoveToward, TickMove |

### `$7F000E,X` Direction Encoding (StageMove path)

| Bit | Mask | Meaning |
|-----|------|---------|
| 14 | `$4000` | X movement is negative (west) |
| 15 | `$8000` | Y movement is negative (north) |
| 0–13 | `$3FFF` | Step count (used by TickMove loop) |

---

## See Also

- [`cop-dispatch.md`](cop-dispatch.md) — COP `$22`, `$52`, `$53` handler entries
- [`utility-tiles-animation.md`](utility-tiles-animation.md) — `ProcessAnimFlag` called during movement init
- [`cop-commands-reference.md`](../../cop-commands-reference.md) — Full MoveToward/StageMove/TickMove operand docs
- Bank $02 `UnsignedDivide` ($281E8) — Step count division in InitSmoothMovement
