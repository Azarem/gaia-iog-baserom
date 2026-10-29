# Bank $00 — Hardware Math Helpers & Movement Initialization

**Address range:** `$008D25`–`$008FDC` (helpers in this file; COP handlers span wider)  
**Source file:** `extracted/system/engine/cop_handlers_movement.asm`  
**Related:** [`cop-dispatch.md`](cop-dispatch.md) (COP `$22` MoveToward, `$52` StageMove, `$53` TickMove) · Bank `$02` `extracted/system/engine/hardware_math.asm` (`UnsignedDivide` used by init)

## Source of truth

| Path | Role |
|------|------|
| `extracted/system/engine/cop_handlers_movement.asm` | `ReadMultiplyResult`, `ReadDivideResult`, `MultiplyThenDivide`, `InitSmoothMovement`, `HalveMovementDistance`, `MovementVelocityCompute`; COP handlers `MoveToward`, `StageMove`, `TickMove` |
| `extracted/system/engine/hardware_math.asm` | Shared SNES math register timing notes; `UnsignedDivide` for step count |
| `corpus/sfcwiki/registers.md` / SNES dev references | `$4202`–`$4206` inputs, `$4214`–`$4217` results |

**Naming:** WRAM fields use extracted equates (`animScratch` = `$7F0000`, `animScratch2` = `$7F000E`, `moveXAlt` = `$7F0018`, `chatPtr` = `$7F000A`, `extendedFlags` = `$7F002A`, `moveScratch1/2` = `$7F002C`/`$7F002E`). Direct-page **`$24`** is the per-movement **tick index** (not an actor offset).

**Counts:** **3** COP handlers in the smooth-move family (`MoveToward`, `StageMove`, `TickMove`); **2** divide latency wrappers (`ReadDivideResult`, inline 5×`NOP` in `MovementVelocityCompute`); **32** static `StageMove` script sites with third operand **`$FF`** (per file block note — not re-counted this session).

---

## SNES math registers (this file)

| Register | Address | Role in these routines |
|----------|---------|------------------------|
| `$WRMPYA` | `$4202` | Multiplicand A (8-bit) — preset to tick **`$24`** before axis math |
| `$WRMPYB` | `$4203` | Multiplicand B — written with axis distance byte to **start** multiply |
| `$WRDIVL` | `$4204` | Dividend low — product low byte or staged distance |
| `$WRDIVB` | `$4206` | Divisor (8-bit) — **`animScratch2` low byte − 1** for interpolation |
| `$RDDIVL` | `$4214` | Quotient low byte (after divide latency) |
| `$RDMPYL` | `$4216` | Product low byte (after multiply latency) |

**Timing (source-derived):** Block notes in `cop_handlers_movement.asm` and `hardware_math.asm` state **~8 machine cycles** after writing **`$WRMPYB`** before **`$RDMPYL`** is valid, and **~16 cycles** after writing **`$WRDIVB`** before **`$RDDIVL`** is valid. This file uses **`ReadMultiplyResult`** (1×`NOP` + call overhead) and **`ReadDivideResult`** (5×`NOP` + overhead). **`MovementVelocityCompute`** relies on **`DEC` / `LDY $RDMPYL`** between **`$WRMPYB`** and the product read, and **5×`NOP`** after **`$WRDIVB`**.

---

## Register math helpers

### ReadMultiplyResult — **live**

**Address:** `$8D25`

Waits for the hardware multiplier, then **`LDY $RDMPYL`**. **Sole caller:** `MultiplyThenDivide`.

### ReadDivideResult — **live**

**Address:** `$8D2A`

Five **`NOP`**s, then **`LDA $RDDIVL`**. **Sole caller:** `MultiplyThenDivide`.

### MultiplyThenDivide — **live**

**Address:** `$8D33`

Computes **cumulative** pixels moved by the current tick: **`($24 × distance) ÷ (animScratch2_low − 1)`**, 8-bit quotient in **`A`** and direct-page **`$0000`**.

```
STA $WRMPYB
JSR ReadMultiplyResult    ; Y = product low
STY $WRDIVL
LDA animScratch2, X
DEC
STA $WRDIVB
BEQ skip_divide           ; divisor 0 → skip ReadDivideResult
JSR ReadDivideResult
skip_divide:
STA $0000
RTS
```

**Divisor zero:** When **`animScratch2` low byte** is **1**, **`DEC`** → **0**, divide is skipped; **`A`** is **0** at **`STA $0000`** (no hardware divide). Matches block note: distance smaller than speed can yield **0** movement for that axis.

**Caller contract:** Caller preset **`$WRMPYA`** to **`$24`** (8-bit) and passes **distance byte in `A`** before **`JSR`**.

**Used by:** **`MoveToward`** — twice per tick (X axis, then Y axis).

### MovementVelocityCompute — **live**

**Address:** `$8FDC`

Same math as **`MultiplyThenDivide`**, inlined for **`TickMove`**: **`STA $WRMPYB`**, read **`$RDMPYL`** into **`$WRDIVL`**, **`$WRDIVB` = animScratch2_low − 1**, **5×`NOP`**, then **`REP #$20` / `SEC` / `LDA $RDDIVL` → `$0000`**. **`SEC`** is intentional: **`TickMove`** follows with **`SBC`** on accumulators.

**No zero-divisor guard** — **`StageMove`** is expected to leave a tick limit ≥ 2 when halving completes.

**Used by:** **`TickMove`** — **Y axis first**, then **X** (opposite order from **`MoveToward`**).

---

## Movement initialization (COP `$22`)

### InitSmoothMovement — **live**

**Address:** `$8D4D` · **Caller:** **`MoveToward`** when **`extendedFlags` bit 1 (`$0002`)** is clear.

1. Rewind script pointer **`$0A − 2`** into **`$00`** for yield resume.
2. Animation byte from script (**`$FF`** → keep current **`$28`**); else **`ProcessAnimFlag`**.
3. Convert **`moveXAlt` / `moveYAlt`** from targets to **absolute deltas** vs **`$14` / `$16`**, cap each at **`$FE`**, record sign via **`ROR $0004`** chain.
4. **`UnsignedDivide`**: larger delta ÷ speed → frame count; store **`frames + 1`** in **`animScratch2` low byte**.
5. Store direction sign byte from **`$0005`** into **`$7F000F,X`** (high byte of the **`animScratch2`** word at **`$7F000E`** — bits used by **`MoveToward`** as word **`$4000` / `$8000`** via **`ASL`** tests).
6. Zero **`animScratch`**, **`animScratch+2`**, tick **`$24`**, **`$2C`**, **`$2E`**; set **`extendedFlags` bit 1**.

**Not used by** **`StageMove`** (separate setup path in the same file).

---

## Distance halving (COP `$52` setup)

### HalveMovementDistance — **live**

**Address:** `$8EF1`

**LSR** both **`moveXAlt`** and **`moveYAlt`**, **`INC chatPtr`**. Called from **`StageMove`** loop while the larger distance high byte ≠ 0, and once more when speed **`≥ $80`** (extra pass per block note).

---

## Stage vs tick semantics (COP `$52` / `$53`)

### StageMove — **live** (COP `$52`)

- Computes **|dx|/|dy|**, sets **direction bits** in **`animScratch2`** (**`$4000`** = west, **`$8000`** = north).
- Halving loop + hardware divide (**`WRDIVL` / `WRDIVB`**, read **`$RDDIVL`**) → frame count **+1** ORed into **`animScratch2`**.
- Third operand → **`animScratch+3`** high byte; **`$FF`** everywhere in extracted scripts → bit 7 set → **`TickMove`** skips cap countdown (per block note).
- Zeros accumulators and **`$24`**; does **not** call **`InitSmoothMovement`**.

### TickMove — **live** (COP `$53`)

Per frame while **`$24` < (animScratch2 & `$3FFF)`**:

1. **`MovementVelocityCompute`** on **Y**, then **X** — subtract previous **`animScratch+1` / `animScratch`** accumulators → signed **`moveScratch2` / `moveScratch1`**.
2. Optional **`animScratch+3`** cap; animation wait on **`animScratch+2`** via **`UpdateActorAnimation`** spin.
3. **`INC $24`**, **`RTL`**.

**TickMoveComplete:** If **`chatPtr` ≠ 0**, decrement pass counter, reset accumulators and **`$24`**, loop for another halved pass; else save resume PC and **`RTL`**.

---

## Actor movement state (`$7F0000,X`)

```text
  +0000  animScratch      X sub-pixel accumulator (byte)
  +0001  animScratch+1    Y sub-pixel accumulator (byte)
  +0002  animScratch+2    Animation sub-frame / wait (low); high byte = StageMove duration cap
  +0003  animScratch+3    TickMove cap counter (byte); $FF high → no cap (bit 7)
  +000A  chatPtr          Halving-pass counter (StageMove / TickMoveComplete)
  +000E  animScratch2     WORD: low = tick limit; high = direction bits ($4000/$8000)
  +0018  moveXAlt         WORD: abs X distance (pixels) after setup
  +001A  moveYAlt         WORD: abs Y distance (pixels) after setup
  +002A  extendedFlags    bit 1 ($0002) = MoveToward smooth move active
  +002C  moveScratch1     Per-frame signed X velocity (→ ApplyMovement chain)
  +002E  moveScratch2     Per-frame signed Y velocity
```

Direct-page **`$24`**: tick index shared by **`MoveToward`**, **`StageMove`**, **`TickMove`**.

---

## Which path uses which helper

| Helper / behavior | MoveToward (`$22`) | StageMove (`$52`) | TickMove (`$53`) |
|-------------------|-------------------|-------------------|------------------|
| `InitSmoothMovement` | First entry only | No | No |
| `MultiplyThenDivide` | Each tick, X then Y | No | No |
| `HalveMovementDistance` | No | While \|Δ\| > 255 | No (consumes via `chatPtr`) |
| `MovementVelocityCompute` | No | No | Each tick, Y then X |
| Hardware divide on setup | Via `UnsignedDivide` (bank `$02`) | Inline `$WRDIVL`/`$WRDIVB` | No |
| `extendedFlags` bit 1 | Set/clear | No | No |
| `chatPtr` halving passes | No | Increment | Decrement on complete |

---

## Integration flow

```text
  COP $22 MoveToward                    COP $52 StageMove
        |                                     |
        v                                     v
  InitSmoothMovement                   ProcessAnimFlag + |dx|/|dy|
  (extendedFlags bit 1)                HalveMovementDistance loop
        |                                     |
        v                                     v
  MultiplyThenDivide x2                  HW divide -> animScratch2
  per tick (X, Y)                        + chatPtr passes
        |                                     |
        v                                     v
  moveScratch1/2 -> ApplyMovement        COP $53 TickMove (per frame)
        |                                     |
        +------------------+------------------+
                           v
                 MovementVelocityCompute x2
                 (Y, X) + SBC accumulators
                           v
                 moveScratch1/2 -> ApplyMovement
```

---

## See also

- [`cop-dispatch.md`](cop-dispatch.md) — handler table entries
- [`utility-tiles-animation.md`](utility-tiles-animation.md) — `ProcessAnimFlag`
- [`../../cop/README.md`](../../cop/README.md) — COP operand documentation
- `hardware_math.asm` — `UnsignedDivide`, global multiply/divide timing notes

---

## Source validation

**Files checked:** `extracted/system/engine/cop_handlers_movement.asm`, `extracted/system/engine/hardware_math.asm`, `corpus/sfcwiki/registers.md`.

**Verified against:** Instruction-level multiply/divide sequence and NOP counts; **`MultiplyThenDivide`** zero-divisor branch; **`MovementVelocityCompute`** order and **`SEC`**; **`InitSmoothMovement`** field writes and **`$7F000F`** direction byte; **`StageMove`/`TickMove`** halving and **`chatPtr`** pass logic; WRAM equates at top of asm file.

**Notes:** **`MoveToward`** applies movement through the shared ApplyMovement / velocity chain after setting **`moveScratch1/2`** (not shown in the helper subs alone). StageMove third-operand **`$FF`** count taken from file block note, not re-enumerated here. **`WRDIVH` / `RDMPYH`** are not read in these helpers (8-bit quotient / product low only).
