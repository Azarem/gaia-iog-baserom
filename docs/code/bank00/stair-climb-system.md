# Bank $00 — Stair Trigger & Climb System

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00D088`–`$00D2D2` (core) + `$00D58A`–`$00D5BC` (shared utility)  
**Size:** ~1,336 bytes, 13 parts  
**File:** `extracted/system/chunk_00D088.asm`  
**Block:** `chunk_00D088` in `us/blocks.json` — `movable: false`

Each stair trigger is an invisible `actor_def` at a tile boundary. Every frame it checks player proximity, validates walking state and facing direction, then overwrites the player entry pointer to a climb function and calls `LockPlayerForClimb`.

**Related:** `extracted/actors/ramps.asm` (slope walk — `?INCLUDE`s this chunk) · [`camera-scroll-system.md`](camera-scroll-system.md) (forced walks during elevation transitions)

---

## Table of Contents

1. [Architecture](#architecture)
2. [Shared Utility Subroutines](#shared-utility-subroutines)
3. [Actor Trigger Definitions](#actor-trigger-definitions)
4. [Directional Climb Functions](#directional-climb-functions)
5. [Variable Map](#variable-map)
6. [Call Reference Matrix](#call-reference-matrix)
7. [External Dependencies](#external-dependencies)
8. [Scene Usage Table](#scene-usage-table)
9. [Statistics](#statistics)

---

## Architecture

Each stair trigger is a small invisible `actor_def` placed at a tile boundary. Every frame it:

1. Checks if the player is within X/Y proximity (±8 to ±$20 pixels)
2. Verifies the player is on the same row/column (`$14` or `$16` match)
3. Calls `CheckMoveState` to confirm the player's movement byte is `$8F` (walking)
4. Validates the player's facing direction matches the stair direction (e.g. facing south = `$12`/`$13`)
5. If all pass → overwrites the player's entry pointer to a climb function, calls `LockPlayerForClimb`

### Include Dependencies

| Include | Purpose |
|---------|---------|
| `player_character` | Access to `$player_actor` and player variables |

### Related File

`extracted/actors/ramps.asm` — the ramp (slope walk) system that `?INCLUDE`s this chunk. Both files share `RestorePlayerControl` (`$D58A`) and the `player_character` dependency. The block is marked `movable: false` because of tight `$&` coupling between stair triggers, climb functions, and ramp completion handlers.

---

## Shared Utility Subroutines

### LockPlayerForClimb

| Property | Value |
|----------|-------|
| **Old Name** | `sub_00D088` |
| **New Name** | `LockPlayerForClimb` |
| **Hex Address** | `$00D088` |
| **Decimal Address** | 53384 |
| **Size** | 38 bytes |
| **Type** | Shared subroutine |

#### Description

Called by all five stair triggers when activation conditions are met. Locks the player into the climb animation state:

1. `$0E << 2` → compute climb frame count, store to `$7F0020,X` (player actor)
2. Zero velocity `$002C`/`$002E` and wait counter `$0008` on the player
3. Set joypad mask `$0F00` to block D-pad
4. Set `$player_flags` bit `$0800` (climbing)

#### Algorithm

```
1. LDX $player_actor
2. LDA $0E; ASL A; ASL A → climb frame count
3. STA $7F0020,X
4. STZ $002C,X; STZ $002E,X; STZ $0008,X
5. LDA #$0F00; TRA $joypad_mask_std
6. LDA $player_flags; ORA #$0800; STA $player_flags
7. RTS
```

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | All 5 stair triggers | JSR `$&sub_00D088` |

---

### UnlockPlayerAfterClimb

| Property | Value |
|----------|-------|
| **Old Name** | `sub_00D0AE` |
| **New Name** | `UnlockPlayerAfterClimb` |
| **Hex Address** | `$00D0AE` |
| **Decimal Address** | 53422 |
| **Size** | 35 bytes |
| **Type** | Shared subroutine |

#### Description

Called when the climb animation finishes (frame counter reaches zero). Restores the player to normal state:

1. `STZ $09E0` — clear climb data
2. `TRB $joypad_mask_std` with `$CFF0` — unmask D-pad inputs
3. Set actor flags `$10` bit `$0008`, clear bit `$0200`
4. Set `$0658` bit `$8000`
5. Clear `$player_flags` bit `$0002`
6. Call `RestorePlayerControl` (`sub_00D58A`)

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | All 4 directional climb functions | JSR `$&sub_00D0AE` |
| Calls | `RestorePlayerControl` | JSR `$&sub_00D58A` |

---

### CheckMoveState

| Property | Value |
|----------|-------|
| **Old Name** | `sub_00D204` |
| **New Name** | `CheckMoveState` |
| **Hex Address** | `$00D204` |
| **Decimal Address** | 53764 |
| **Size** | 20 bytes |
| **Type** | Shared subroutine |

#### Description

Validates the player actor is in the "walking" move state. Reads `$7F0008,X` (where X = player actor) and compares to `$8F`. Returns carry **clear** if `$8F` (valid for stair trigger), carry **set** if not.

Register state: enters/exits with 8-bit A (`SEP #$20` / `REP #$20` implicit on return).

#### Algorithm

```
1. LDX $player_actor
2. LDA $7F0008,X
3. CMP #$8F
4. RTS  ; CC = walking, CS = not walking
```

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | All 5 stair triggers | JSR `$&sub_00D204` |

---

### RestorePlayerControl

| Property | Value |
|----------|-------|
| **Old Name** | `sub_00D58A` |
| **New Name** | `RestorePlayerControl` |
| **Hex Address** | `$00D58A` |
| **Decimal Address** | 54666 |
| **Size** | 54 bytes |
| **Type** | Cross-file shared subroutine |

#### Description

Resets the player actor to normal walking state after a climb or ramp completes. Sets player entry pointer to `code_02C3C8` (normal player state machine in bank `$02`), zeros velocity/wait counter, adjusts actor flags, and unmasks joypad/player_flags.

**Cross-file sharing:** `ramps.asm` calls this via `JSR $&sub_00D58A` from ramp completion handlers — this is why `chunk_00D088` is `movable: false`.

#### Algorithm

```
1. LDX $player_actor
2. LDA #$&code_02C3C8 → $7F0000,X  ; Normal player entry
3. STZ $002C,X; STZ $002E,X; STZ $0008,X
4. Adjust $10 flags: OR #$0008, AND #$FDFF
5. Clear $player_flags climb bits
6. LDA #$CFF0; TRB $joypad_mask_std
7. RTS
```

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | `UnlockPlayerAfterClimb` | This chunk |
| Called by | `code_00D4D2` (ramp_east) | ramps.asm |
| Called by | `code_00D550` (ramp_south) | ramps.asm |
| Called by | `loc_00D518` (ramp_north) | ramps.asm |
| Called by | `func_00D5C0` (ramp sprite anim) | ramps.asm |
| Target | `code_02C3C8` | Bank `$02` normal player AI |

---

## Actor Trigger Definitions

### StairTriggerSouth

| Property | Value |
|----------|-------|
| **Old Name** | `actor_00D0D1` (part of chunk) |
| **New Name** | `StairTriggerSouth` |
| **Hex Address** | `$00D0D1` |
| **Decimal Address** | 53457 |
| **Size** | 72 bytes |
| **Type** | `actor_def` + trigger code |

#### Description

South-facing stair trigger. Detects player approaching from the south (walking south, facing `$12`/`$13`). Redirects player to `ClimbSouth` (`func_00D218`).

- **Proximity check:** X range ±$8 to ±$20 pixels from trigger Y, same X row check
- **Valid facing:** `$0012` or `$0013`
- **Scene usage:** Mu Passage (`event_def_0CA923`) — actor slot #12/#13

---

### StairTriggerNorth

| Property | Value |
|----------|-------|
| **Old Name** | `actor_00D119` |
| **New Name** | `StairTriggerNorth` |
| **Hex Address** | `$00D119` |
| **Decimal Address** | 53529 |
| **Size** | 72 bytes |

#### Description

North-facing stair trigger. Detects player approaching from the north (walking north, facing `$15`/`$16`). Redirects to `ClimbNorth` (`func_00D246`).

- **Valid facing:** `$0015` or `$0016`
- **Scene usage:** Mu Passage (`event_def_0CA923`) — actor slot #12

---

### StairTriggerWestEntry

| Property | Value |
|----------|-------|
| **Old Name** | `actor_00D161` |
| **New Name** | `StairTriggerWestEntry` |
| **Hex Address** | `$00D161` |
| **Decimal Address** | 53601 |
| **Size** | 9 bytes |

#### Description

Thin wrapper — adds position offset (`COP [AddPosition] #F8, #00`) then falls through to `StairTriggerWest` code (`code_00D16D`). Used in Angel Village 72 where the trigger needs a pixel offset before the standard west-facing proximity check.

- **Scene usage:** Angel Village (`event_def_0CB258`) — actor slot #14

---

### StairTriggerWest

| Property | Value |
|----------|-------|
| **Old Name** | `actor_00D16A` |
| **New Name** | `StairTriggerWest` |
| **Hex Address** | `$00D16A` |
| **Decimal Address** | 53610 |
| **Size** | 75 bytes |

#### Description

West-facing stair trigger. Detects player approaching from the west (walking west, facing `$0F`/`$10`). Redirects to `ClimbWest` (`func_00D274`). Checks X-axis proximity (±$8 to ±$20) on the actor's Y column.

- **Valid facing:** `$000F` or `$0010`
- **Scene usage:** Mu Passage, Angel Village, Angkor Wat, Dracula Mansion — **12+** scene placements

---

### StairTriggerEast

| Property | Value |
|----------|-------|
| **Old Name** | `actor_00D1B5` |
| **New Name** | `StairTriggerEast` |
| **Hex Address** | `$00D1B5` |
| **Decimal Address** | 53685 |
| **Size** | 79 bytes |

#### Description

East-facing stair trigger. Detects player approaching from the east (walking east, facing `$0C`/`$0D`). Redirects to `ClimbEast` (`func_00D2A2`). Same pattern but on the opposite horizontal axis.

- **Valid facing:** `$000C` or `$000D`
- **Scene usage:** Mu Cyclops, Angel Village, Angkor Wat temples — **10+** placements

---

## Directional Climb Functions

All four climb functions share the same pattern:

1. Set actor flags: `TSB $10` with `$2200` (invisible + priority), `TRB $10` with `$0008`
2. `COP [SetEntryContinue]` — allow multi-frame execution
3. Move position 4 pixels per frame in the climb direction
4. Decrement `$7F0020,X` (frame counter); if non-zero → `RTL` (continue next frame)
5. At zero: clear `$2000` from `$10`, stage a sprite frame, `COP [AnimOnce]`, call `UnlockPlayerAfterClimb`

### ClimbSouth

| Property | Value |
|----------|-------|
| **Old Name** | `func_00D218` |
| **New Name** | `ClimbSouth` |
| **Hex Address** | `$00D218` |
| **Decimal Address** | 53784 |
| **Size** | 46 bytes |

- **Movement:** Decrements `$14` by 4 each frame (move player up/north on screen = climbing south in isometric)
- **End sprite frame:** `#14`

### ClimbNorth

| Property | Value |
|----------|-------|
| **Old Name** | `func_00D246` |
| **New Name** | `ClimbNorth` |
| **Hex Address** | `$00D246` |
| **Decimal Address** | 53830 |
| **Size** | 46 bytes |

- **Movement:** Increments `$14` by 4 each frame
- **End sprite frame:** `#17`

### ClimbWest

| Property | Value |
|----------|-------|
| **Old Name** | `func_00D274` |
| **New Name** | `ClimbWest` |
| **Hex Address** | `$00D274` |
| **Decimal Address** | 53876 |
| **Size** | 46 bytes |

- **Movement:** Decrements `$16` by 4 each frame
- **End sprite frame:** `#11`

### ClimbEast

| Property | Value |
|----------|-------|
| **Old Name** | `func_00D2A2` |
| **New Name** | `ClimbEast` |
| **Hex Address** | `$00D2A2` |
| **Decimal Address** | 53922 |
| **Size** | 46 bytes |

- **Movement:** Increments `$16` by 4 each frame
- **End sprite frame:** `#0E`

---

## Variable Map

| Address | Size | Name | Used By |
|---------|------|------|---------|
| `$0E` | 2 | OAM flags / frame count source | `LockPlayerForClimb` (ASL ASL for count) |
| `$10` | 2 | Actor flags word 1 | Climb functions (set `$2200`, clear `$0008`) |
| `$14` | 2 | Position X | Climb S/N (modify X for elevation) |
| `$16` | 2 | Position Y | Climb W/E (modify Y for elevation) |
| `$28` | 2 | Player facing direction | Trigger direction validation |
| `$7F0008,X` | 1 | Move state byte | `CheckMoveState` (`$8F` = walking) |
| `$7F0020,X` | 2 | Climb frame counter | `LockPlayerForClimb` → climb functions |
| `$002C,X` | 2 | Velocity X | Zeroed by lock |
| `$002E,X` | 2 | Velocity Y | Zeroed by lock |
| `$0008,X` | 2 | Wait counter | Zeroed by lock |
| `$09E0` | 2 | Climb state data | Cleared by unlock |
| `$0658` | 2 | Display flags | Bit `$8000` set by unlock |
| `$joypad_mask_std` | 2 | Joypad input mask | `$0F00` set (lock), `$CFF0` cleared (unlock) |
| `$player_flags` | 2 | Player state flags | Bit `$0800` set (lock); bits `$0002`/`$0800`/`$0F00` cleared (unlock) |

---

## Call Reference Matrix

### Internal Calls

| Caller | Callee | Type |
|--------|--------|------|
| All 5 triggers | `CheckMoveState` (`$D204`) | JSR `$&` |
| All 5 triggers | `LockPlayerForClimb` (`$D088`) | JSR `$&` |
| All 4 climb funcs | `UnlockPlayerAfterClimb` (`$D0AE`) | JSR `$&` |
| `UnlockPlayerAfterClimb` | `RestorePlayerControl` (`$D58A`) | JSR `$&` |

### External Callers (from ramps.asm)

| Caller | Target | Type |
|--------|--------|------|
| `code_00D4D2` (ramp_east climb) | `RestorePlayerControl` (`$D58A`) | JSR `$&` |
| `code_00D550` (ramp_south climb) | `RestorePlayerControl` (`$D58A`) | JSR `$&` |
| `loc_00D518` (ramp_north climb) | `RestorePlayerControl` (`$D58A`) | JSR `$&` |
| `func_00D5C0` (ramp sprite anim) | `RestorePlayerControl` (`$D58A`) | JSR `$&` |

---

## External Dependencies

| Target | Bank | Purpose |
|--------|------|---------|
| `$player_actor` | global WRAM | Player actor slot ID |
| `code_02C3C8` | `$02` | Normal player state machine (set by `RestorePlayerControl`) |
| `player_character` | `$00` | Include for player variable access |
| `ramps.asm` | `$00` | Slope walk system — shares `RestorePlayerControl` |

---

## Scene Usage Table

| Trigger | Scene Count | Areas |
|---------|-------------|-------|
| `StairTriggerSouth` | 2 | Mu Passage |
| `StairTriggerNorth` | 2 | Mu Passage |
| `StairTriggerWestEntry` | 1 | Angel Village |
| `StairTriggerWest` | 12+ | Mu, Angel Village, Angkor Wat, Dracula Mansion |
| `StairTriggerEast` | 10+ | Mu, Angel Village, Angkor Wat, Dracula Mansion |

All triggers are placed as invisible `actor_def` entries in `scene_actors.asm` at tile boundaries where elevation changes occur on the isometric map grid.

---

## Statistics

### Code Distribution

| Category | Count | Size |
|----------|-------|------|
| Actor definitions (triggers) | 5 | ~307 bytes |
| Directional climb functions | 4 | ~184 bytes |
| Shared subroutines | 4 | ~147 bytes |
| **Total (core)** | **13 parts** | **~638 bytes** |
| Shared utility (`RestorePlayerControl`) | 1 | 54 bytes (at `$D58A`) |
| Combined with ramps.asm | — | ~1,336 bytes total block |

### Block Properties

| Property | Value |
|----------|-------|
| Block name | `chunk_00D088` |
| Movable | **false** |
| Reason | Tight `$&` coupling to `ramps.asm` |
| Parts in blocks.json | 13 |
| Cross-file shared sub | `RestorePlayerControl` (4 external callers) |

---

*Source: `us/blocks.json`, `us/names.json`, `docs/code/chunk_008000-analysis.md` §chunk_00D088.*
