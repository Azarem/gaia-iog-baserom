# Slope & Ramp Physics — `slope_ramp_physics.asm`

*Part of the [Bank $02 Documentation Suite](README.md)*

> Terrain-based movement physics with slope detection, speed curves, and deceleration

> **Evidence labels.** Each major section is tagged with the kind of claim it makes: **[ASM]** = directly observed in the extracted asm of this block; **[INFERRED]** = interpretation of behavior that is not literally encoded in the file; **[XREF]** = cross-file / engine-wide convention stated elsewhere (not provable from this file alone). Sections that mix kinds split them into separately tagged bullets or paragraphs. The `.asm` files in `extracted/` are authoritative; where prose and asm comments disagree, the asm wins.

**Source:** [`slope_ramp_physics.asm`](../../../extracted/actors/player/slope_ramp_physics.asm) (ROM `177195`–`178099`, bank `$02`: `$02B42B`–`$02B7B3`)

---

## Overview

*Evidence: [ASM] + [XREF]*

Companion actor spawned by `PlayerCharacterDef` via `COP [SpawnAfter]` (`slope_ramp_physics.SlopePhysicsEntry`). **[ASM]** It does not move the player; it only edits `playerSpeedEw` / `playerSpeedNs` (`$09B2` / `$09B4`) and `playerFlags` bit `$1000`. **[XREF]** `player_move_controller.PlayerMoveController` runs later in the same frame (actor list: `attack_ability_system` → player → `slope_ramp_physics` → `player_move_controller`), scales nonzero speed words by 4, and passes sub-pixel position/velocity to `player_move_main.PlayerMovementTick`.

**[ASM]** Each frame: probe collision at the player's feet with `tile_collision.TileProbeMain`, dispatch through `SlopeTileDispatch` by collision nibble, apply curve samples from WRAM table pointers, clamp with `ClampSpeeds`, and run flat-ground deceleration via `SlopeFlatDecelerate` when not on a handled slope tile.

**Related:** [`player-character.md`](player-character.md) · [`player-movement.md`](player-movement.md) · [`tile-collision.md`](tile-collision.md)

---

## Memory Map

*Evidence: [ASM]*

| Address | Name | Description |
|---------|------|-------------|
| `$02B42B` | `SlopePhysicsEntry` | `COP [SetEntryHere]` entry. Gate on player actor `$0010` bits `$0080` \| `$0040` when `iframeCounter` ≥ 0 → `SlopeFlatDecelerate` only. Moving: probe `(actor $0014, actor $0016 − 8)` → `SlopeTileDispatch`. Types `$06` / `$09`: row below/above probe via `MapCellDown` / `MapCellUp` for `$05` / `$0A`. Stopped with `playerFlags` `$1000`: four-cell probe at `playerXPos` / `playerYPos`. |
| `$02B538` | `SlopeType03Handler` | Type `$03` → `ApplySlopeCurvePosNS` (add from `slopeCurvePtrB`). |
| `$02B53D` | `SlopeType05Handler` | Type `$05` → `ApplySlopeCurveNegEW` (negated `slopeCurvePtrA`). |
| `$02B542` | `SlopeType0AHandler` | Type `$0A` → `ApplySlopeCurvePosEW`. |
| `$02B547` | `SlopeType0CHandler` | Type `$0C` → `ApplySlopeCurveNegNS` (label inside `SlopeType0AHandler` block). |
| `$02B550` | `SlopeFlatExit` | `ClampSpeeds`; clear `slopeFracAccum` / `slopeStepCounter`; `PLD`/`PLX`; fall through to `SlopeFlatDecelerate`. |
| `$02B55B` | `SlopeFlatDecelerate` | EW nonzero → `DecelerateEW` + `RTL`. EW zero → clear `$1000` if set; NS nonzero → `DecelerateNS` + `RTL`. |
| `$02B57C` | `SlopeTileDispatch` | 16 word entries; only `$03`, `$05`, `$0A`, `$0C` nonzero (`DEC`/`PHA`/`RTS` dispatch). |
| `$02B59C` | `ApplySlopeCurveNegEW` | Curve from `$09BA` + `(slopeStepCounter & $0F)×2`, negated, add to `playerSpeedEw`. |
| `$02B5BC` | `ApplySlopeCurvePosEW` | Positive EW curve; shared `SlopeSpeedZeroLatch` sets `$1000` when speed hits 0. |
| `$02B5E2` | `ApplySlopeCurvePosNS` | Positive NS curve from `$09BC`. |
| `$02B5FE` | `ApplySlopeCurveNegNS` | Negated NS curve from `$09BC`. |
| `$02B61E` | `ClampSpeeds` | Clamp `\|playerSpeedEw\|` and (when EW is 0) `\|playerSpeedNs\|` to `maxSpeed* − 1` (`$09C8` / `$09CA`, default max 9 → limit 8). |
| `$02B675` | `DecelerateEW` | Skip if `$1000`. `\|speed\| < 3` → zero EW. Else direction-aware steps from `decelCurvePtr` (`$09C2`) via `ReadDecelerationStep`; joypad `$0100` / `$0200` on `$0656`. |
| `$02B701` | `ReadDecelerationStep` | Word at `decelCurvePtr + (decelStepCounter & $0F)×2`; `INC decelStepCounter` always. |
| `$02B714` | `DecelerateNS` | Mirror of EW; joypad `$0400` / `$0800`; zero-speed path clears `slopeStepCounter` (not `decelStepCounter`). |
| `$02B7A0` | `ReadDecelerationStepNS` | Byte-identical to `ReadDecelerationStep` (same counter and pointer). |

### Shared WRAM Variables

*Evidence: [ASM]*

| Location | Symbol (asm) | Role |
|----------|--------------|------|
| `$09AA` | `playerActor` | Player slot index |
| `$09AE` | `playerFlags` | Bit `$1000` = on-slope / stopped-on-slope latch (this file sets; controller clears when speed nonzero) |
| `$09B2` / `$09B4` | `playerSpeedEw` / `playerSpeedNs` | Axis speed in pixels/frame (controller ×4 for movement) |
| `$09B6` | `slopeStepCounter` | Index into slope curve tables (`& $0F`) |
| `$09B8` | `decelStepCounter` | Index into deceleration curve |
| `$09BA` / `$09BC` | `slopeCurvePtrA` / `slopeCurvePtrB` | Pointers to 16-word EW / NS slope curves |
| `$09C2` | `decelCurvePtr` | Flat deceleration curve pointer |
| `$09C6` | `slopeFracAccum` | Cleared here and by controller when NS speed word is 0; sub-pixel NS slopes live in movement code |
| `$09C8` / `$09CA` | `maxSpeedEw` / `maxSpeedNs` | Clamp ceiling (default 9 → effective max speed 8) |
| `$09A2` / `$09A4` | `playerXPos` / `playerYPos` | Stopped-on-slope probe coordinates |
| `$0656` | `joypadCurrent` | Deceleration direction tests (16-bit) |
| `$7F0028,X` | `iframeCounter` | Negative → slope detection runs despite `$0080`/`$0040` on player `$0010` |

#### Slope Detection & Entry

*Evidence: [ASM]*

### SlopePhysicsEntry

**[ASM]** Per-frame flow:

1. If player `$0010` has bit `$0080` or `$0040` and `iframeCounter,X` is not negative → `JMP SlopeFlatDecelerate` (no tile probe).
2. If `playerSpeedEw \| playerSpeedNs` nonzero: `D=0`, probe pixel X = actor `$0014`, Y = actor `$0016 − $0008`, `JSR tile_collision.TileProbeMain`, index `SlopeTileDispatch` by `A×2`.
3. Handler address 0: if type is `$06` or `$09`, read cell one row **down** then one row **up** (map index in `$00`) for types `$05` / `$0A`; else `SlopeFlatExit`.
4. If both speed words zero and `playerFlags` `$1000`: reset `slopeStepCounter` and `decelStepCounter`; probe at `playerXPos`/`playerYPos` — current cell, `MapCellRight`, `MapCellDown`, `MapCellRight` from below cell; first matching handler wins; else `SlopeFlatExit`.
5. If both speed words zero and `$1000` clear → `SlopeFlatDecelerate`.

**[Runtime-verified, B3]** The moving probe reads pixel (actor X, actor Y − 8) in 263 of 263 traced events; the stopped-latch probe reads (`$09A2`, `$09A4`) = (actor X − 8, actor Y − 16) in 11 of 11 events, and `$1A`/`$1E` equal them. The two probes sample different world points; why is intent, not decidable at run time.

**[Runtime-verified, B3]** On a moving probe that reads `$06` or `$09`, the cell one row **below** is tested first; the cell above is tested only when the one below is not `$05`/`$0A` (a `$0F` below also falls through to the above test). Results are identical for `$06` and `$09`:

| Cell above | Cell below | Cells consulted | Handler |
|------------|------------|-----------------|---------|
| `$00` | `$00` | below, above | `SlopeFlatExit` |
| `$05` / `$0A` | `$00` | below, above | `SlopeType05Handler` / `SlopeType0AHandler` |
| any of `$00`, `$05`, `$0A`, `$0F` | `$05` | below only | `SlopeType05Handler` |
| `$00`, `$05` | `$0A` | below only | `SlopeType0AHandler` |
| `$05` | `$0F` | below, then above | `SlopeType05Handler` |

This matches how the maps are built: `$05`/`$0A` cells form vertical stacks capped by `$06`/`$09` (of 335 `$05` cells the cell below is `$06` in 220; of 311 `$0A` cells it is `$09` in 238), so a probe on a cap finds the slope cell in the row below or above and not to the left or right. See [`wram-memory-map.md` §4.10](../../wram-memory-map.md).

**[Runtime-verified, B4]** Both calls start from `$00`, the index `TileProbeMain` left, not from the X the first call returned: on a `$06` probe at index `$09A0` (Itory, cell (64, 26)) `MapCellDown` returns `X = $09B0` (`$00 + $10`) and the following `MapCellUp` returns `X = $0990` (`$00 − $10`), although X held `$09B0` when it was called. `$00` stays `$09A0` through both calls (12 of 12 sequences, walk and run), and the `$05` handler runs from the cell above in all 12. Not covered: the page-carry case of `MapCellDown` (row stride added to the high byte) and the stopped-latch probe's `$00` handling.

### SlopeFlatDecelerate

**[ASM]** EW speed nonzero → `DecelerateEW`, `RTL` (NS untouched that frame). EW zero → clear `$1000` if set; if NS speed nonzero → `DecelerateNS`, `RTL`.

### SlopeTileDispatch

**[ASM]** 16-entry `.word` table. Populated indices: `$03` → `SlopeType03Handler`, `$05` → `SlopeType05Handler`, `$0A` → `SlopeType0AHandler`, `$0C` → `SlopeType0CHandler`. Dispatch: `DEC` / `PHA` / `RTS` (address in table is the handler entry, not `−1`).

| Type | Handler | Speed axis | Curve |
|------|---------|------------|-------|
| `$03` | `SlopeType03Handler` | `playerSpeedNs` + | `slopeCurvePtrB` |
| `$05` | `SlopeType05Handler` | `playerSpeedEw` − | `slopeCurvePtrA` (negated) |
| `$0A` | `SlopeType0AHandler` | `playerSpeedEw` + | `slopeCurvePtrA` |
| `$0C` | `SlopeType0CHandler` | `playerSpeedNs` − | `slopeCurvePtrB` (negated) |

#### Curve Application

*Evidence: [ASM]*

### ApplySlopeCurveNegEW / ApplySlopeCurvePosEW / ApplySlopeCurvePosNS / ApplySlopeCurveNegNS

**[ASM]** Each reads one word from the appropriate pointer at `(slopeStepCounter & $0F) × 2`, updates one speed word, and on exact zero branches to `SlopeSpeedZeroLatch` (`STZ slopeStepCounter`, `TSB playerFlags #$1000`). Otherwise `INC slopeStepCounter`. Default curve (block note): `$0001` at steps 0, 4, 8, 12.

#### Speed Clamping

*Evidence: [ASM]*

### ClampSpeeds

**[ASM]** EW speed handled first; NS only when EW is zero. Over-max positive speeds clamp to `max−1`; over-max negative speeds clamp to `−(max−1)`.

**[Runtime-verified, B3]** EW 0 / NS +12 → NS 8 (and −12 → −8); EW +5 / NS ±12 → NS unchanged on the traced entries; EW +12 / NS +12 → EW 8, NS stays 12. NS is clamped only when EW is zero. Not traced: why NS drops to 0 in later frames (EW +5 / NS +12: `$09B4` 12 → 0 at frame 3) although `DecelerateNS` does not run.

#### Flat Deceleration

*Evidence: [ASM]*

### DecelerateEW

**[ASM]** Returns immediately if `playerFlags` `$1000`. `\|playerSpeedEw\| < 3` → `STZ playerSpeedEw` (does not reset `decelStepCounter`). For `\|speed\| ≥ 3`: same-direction joypad suppresses decel; opposite direction can apply a second `ReadDecelerationStep` in the same frame. Zero after a step → `DecelResetCounterEW` (`STZ decelStepCounter`).

### DecelerateNS

**[ASM]** Same structure on `playerSpeedNs` with joypad `$0400` (south) / `$0800` (north). When NS speed reaches zero, the code clears `slopeStepCounter` at `loc_02B76C` instead of `decelStepCounter` (the EW path clears `decelStepCounter`).

**[Runtime-verified, B3]** With the deceleration curve patched to 3 at every step (poked speed ±3, `$09B6` = 5, `$09B8` = 4), the reset fires in 4 of 4 cases: after the EW reset `$09B8` is 0, after the NS reset `$09B8` stays 5 and speed is 0, so the NS path leaves the deceleration curve at its position as the asm note says. The `STZ slopeStepCounter` is a no-op on this path (`SlopeFlatExit` has already cleared `$09B6`). With the shipped curve neither reset fires: both axes stop through the `|speed| < 3` snap (`EWSnap` / `NSSnap`), except that NS +5 and run S reach 0 without that hook. Coverage: flat ground only.

---

## See Also

- [`player-movement.md`](player-movement.md) — `PlayerMovementTick` (`$02CFD0`), movement dispatch
- [`tile-collision.md`](tile-collision.md) — `TileProbeMain`, `MapCell*`, `ReadCollisionNibble`
- [`../../cop/README.md`](../../cop/README.md) — COP command semantics
- [`../../actor-organization-analysis.md`](../../actor-organization-analysis.md) — global actor linked list
