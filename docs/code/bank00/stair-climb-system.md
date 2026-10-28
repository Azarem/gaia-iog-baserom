# Bank $00 — Psycho Slider Glide System

**Bank:** `$00` (mirrored at `$80`)  
**Address range:** `$00D088`–`$00D2D2` (core) + `$00D58A`–`$00D5BC` (shared utility)  
**Size:** ~1,336 bytes, 13 parts  
**File:** `extracted/system/engine/slider_glide.asm`

Invisible **slider glide triggers** sit on Psycho Slider lanes. While Will is in an active **Psycho Slide** (`RunAttackNS` / `RunAttackEW` in `player_character`) through the trigger tile, the trigger validates slide animation frames and the `will_alt` sprite bank (`$8F`), then redirects the player into a **`SliderGlide*`** routine and calls `LockPlayerForClimb`.

**Related:** `extracted/actors/ramps.asm` (slope walk — `?INCLUDE`s this chunk) · [`camera-scroll-system.md`](camera-scroll-system.md) (forced walks during elevation transitions)

---

## Table of Contents

1. [Architecture](#architecture)
2. [Shared Utility Subroutines](#shared-utility-subroutines)
3. [Actor Trigger Definitions](#actor-trigger-definitions)
4. [Directional Glide Functions](#directional-glide-functions)
5. [Variable Map](#variable-map)
6. [Call Reference Matrix](#call-reference-matrix)
7. [External Dependencies](#external-dependencies)
8. [Scene Usage Table](#scene-usage-table)
9. [Statistics](#statistics)

---

## Architecture

Each trigger is a small invisible `actor_def` on a slide axis. Every frame it:

1. Confirms Will is Psycho Sliding through its tile (slide animation index `$28` must be one of the two looping frames for **one** slide direction)
2. Calls `IsPlayerSliderSpriteBank` — carry **clear** when `$7F0008` = `$8F` (`will_alt` bank selected at slide start)
3. Checks **exact** alignment on the slide axis and a **32-pixel** window on the lateral axis (trigger − 7 … trigger + `$18` inclusive)
4. Validates facing / animation codes for that slide direction (see trigger table below)
5. If all pass → overwrites the player entry pointer to the matching `SliderGlide*` routine and calls `LockPlayerForClimb`

Trigger names match **slide direction**: west slide uses `SliderGlideTriggerWest` → `SliderGlideWest` (X − 4/frame), east → `SliderGlideEast` (X + 4), north → `SliderGlideNorth` (Y − 4), south → `SliderGlideSouth` (Y + 4).

### Include Dependencies

| Include | Purpose |
|---------|---------|
| `player_character` | Access to `$player_actor` and player variables |

### Related File

`extracted/actors/ramps.asm` — the ramp (slope walk) system that `?INCLUDE`s this chunk. Both files share `RestorePlayerControl` (`$D58A`) and the `player_character` dependency. The block is marked `movable: false` because of tight `$&` coupling between glide triggers, glide routines, and ramp completion handlers.

---

## Shared Utility Subroutines

### LockPlayerForClimb

**Address:** `$00D088` · **Size:** 38 bytes

#### Description

Called by all five glide triggers when activation conditions are met. Locks the player into the scripted glide:

1. `$0E << 2` → compute glide frame count, store to `$7F0020,X` (player actor)
2. Zero velocity `$002C`/`$002E` and wait counter `$0008` on the player
3. Set joypad mask `$0F00` to block D-pad
4. Set `$player_flags` bit `$0800` (script/ability lock)

#### Algorithm

```
1. LDX $player_actor
2. LDA $0E; ASL A; ASL A → glide frame count
3. STA $7F0020,X
4. STZ $002C,X; STZ $002E,X; STZ $0008,X
5. LDA #$0F00; TRA $joypad_mask_std
6. LDA $player_flags; ORA #$0800; STA $player_flags
7. RTS
```

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | All 5 glide triggers | JSR `$&LockPlayerForClimb` |

---

### UnlockPlayerAfterClimb

**Address:** `$00D0AE` · **Size:** 35 bytes

#### Description

Called when the glide animation finishes (frame counter reaches zero). Restores the player to normal state:

1. `STZ $09E0` — clear Will ability bonus byte used during lunges
2. `TRB $joypad_mask_std` with `$CFF0` — unmask D-pad inputs
3. Set actor flags `$10` bit `$0008`, clear bit `$0200`
4. Set `$0658` bit `$8000`
5. Clear `$player_flags` bit `$0002` (body slam/charge attack)
6. Call `RestorePlayerControl`

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | All 4 directional glide functions | JSR `$&UnlockPlayerAfterClimb` |
| Calls | `RestorePlayerControl` | JSR `$&RestorePlayerControl` |

---

### IsPlayerSliderSpriteBank

**Address:** `$00D204` · **Size:** 20 bytes

#### Description

Psycho Slider gate. Reads `$7F0008,X` (player actor spriteset bank byte) and compares to `$8F`. Returns carry **clear** if `$8F` (`will_alt` — the bank `SetPlayerSpriteDirect #04` selects at slide start), carry **set** otherwise.

Register state: enters/exits with 8-bit A (`SEP #$20` / `REP #$20` implicit on return).

#### Algorithm

```
1. LDX $player_actor
2. LDA $7F0008,X
3. CMP #$8F
4. RTS  ; CC = will_alt bank, CS = not sliding bank
```

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | All 5 glide triggers | JSR `$&IsPlayerSliderSpriteBank` |

---

### RestorePlayerControl

**Address:** `$00D58A` · **Size:** 54 bytes

#### Description

Resets the player actor to normal walking state after a glide or ramp completes. Sets player entry pointer to `PlayerIdleEntry` (normal player state machine in bank `$02`), zeros velocity/wait counter, adjusts actor flags, and unmasks joypad/player_flags.

**Cross-file sharing:** `ramps.asm` calls this via `JSR $&RestorePlayerControl` from ramp completion handlers — this is why `slider_glide` is `movable: false`.

#### Algorithm

```
1. LDX $player_actor
2. LDA #$&PlayerIdleEntry → $7F0000,X  ; Normal player entry
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
| Called by | `RampPlayerClimbEast` (ramp_east) | ramps.asm |
| Called by | `RampPlayerClimbSouth` (ramp_south) | ramps.asm |
| Called by | `RampPlayerClimbNorth` (ramp_north) | ramps.asm |
| Called by | `RampArcDriver` (ramp sprite anim) | ramps.asm |
| Target | `PlayerIdleEntry` | Bank `$02` normal player AI |

---

## Actor Trigger Definitions

### SliderGlideTriggerWest

**Address:** `$00D0D1` · **Size:** 72 bytes

#### Description

**West** Psycho Slide trigger. Requires player animation `$12`/`$13`, **exact** X match with trigger X, and player Y within trigger Y − 7 … trigger Y + `$18`. Redirects to `SliderGlideWest` (X − 4/frame).

- **Valid slide frames:** `$0012` or `$0013`
- **Scene usage:** Mu Passage (`event_def_0CA923`) — actor slot #12/#13

---

### SliderGlideTriggerEast

**Address:** `$00D119` · **Size:** 72 bytes

#### Description

**East** slide trigger. Animation `$15`/`$16`, same X alignment and Y window as west. Redirects to `SliderGlideEast` (X + 4/frame).

- **Valid slide frames:** `$0015` or `$0016`
- **Scene usage:** Mu Passage (`event_def_0CA923`) — actor slot #12

---

### SliderGlideTriggerNorthEntry

**Address:** `$00D161` · **Size:** 9 bytes

#### Description

Thin wrapper — adds position offset (`COP [AddPosition] #F8, #00`) then falls through to `SliderGlideTriggerNorthMain`. Used in Angel Village 72 where the trigger needs a pixel offset before the standard **north** slide proximity check.

- **Scene usage:** Angel Village (`event_def_0CB258`) — actor slot #14

---

### SliderGlideTriggerNorth

**Address:** `$00D16A` · **Size:** 75 bytes

#### Description

**North** slide trigger. Animation `$0F`/`$10`, **exact** Y match with trigger Y, lateral X window ±7…+$18. Redirects to `SliderGlideNorth` (Y − 4/frame).

- **Valid slide frames:** `$000F` or `$0010`
- **Scene usage:** Mu Passage, Angel Village, Angkor Wat, Dracula Mansion — **12+** scene placements

---

### SliderGlideTriggerSouth

**Address:** `$00D1B5` · **Size:** 79 bytes

#### Description

**South** slide trigger. Animation `$0C`/`$0D`, exact Y alignment, lateral X window. Redirects to `SliderGlideSouth` (Y + 4/frame).

- **Valid slide frames:** `$000C` or `$000D`
- **Scene usage:** Mu Cyclops, Angel Village, Angkor Wat temples — **10+** placements

---

## Directional Glide Functions

All four glide routines share the same pattern:

1. Set actor flags: `TSB $10` with `$2200`, `TRB $10` with `$0008`
2. `COP [SetEntryHere]` — allow multi-frame execution
3. Move position 4 pixels per frame along the slide axis (same delta as the active Psycho Slide)
4. Decrement `$7F0020,X` (frame counter); if non-zero → `RTL` (continue next frame)
5. At zero: clear `$2000` from `$10`, stage a sprite frame, `COP [AnimOnce]`, call `UnlockPlayerAfterClimb`

### SliderGlideWest

**Address:** `$00D218` · **Size:** 46 bytes

- **Movement:** Decrements `$14` by 4 each frame (west)
- **End sprite frame:** `#14`

### SliderGlideEast

**Address:** `$00D246` · **Size:** 46 bytes

- **Movement:** Increments `$14` by 4 each frame (east)
- **End sprite frame:** `#17`

### SliderGlideNorth

**Address:** `$00D274` · **Size:** 46 bytes

- **Movement:** Decrements `$16` by 4 each frame (north)
- **End sprite frame:** `#11`

### SliderGlideSouth

**Address:** `$00D2A2` · **Size:** 46 bytes

- **Movement:** Increments `$16` by 4 each frame (south)
- **End sprite frame:** `#0E`

---

## Variable Map

| Address | Size | Name | Used By |
|---------|------|------|---------|
| `$0E` | 2 | Glide length source | `LockPlayerForClimb` (ASL ASL for frame count) |
| `$10` | 2 | Actor flags word 1 | Glide routines (set `$2200`, clear `$0008`) |
| `$14` | 2 | Position X | `SliderGlideWest` / `SliderGlideEast` |
| `$16` | 2 | Position Y | `SliderGlideNorth` / `SliderGlideSouth` |
| `$28` | 2 | Animation index | Slide frame validation on triggers |
| `$7F0008,X` | 1 | Spriteset bank byte | `IsPlayerSliderSpriteBank` (`$8F` = `will_alt`) |
| `$7F0020,X` | 2 | Glide frame counter | `LockPlayerForClimb` → glide routines |
| `$002C,X` | 2 | Velocity X | Zeroed by lock |
| `$002E,X` | 2 | Velocity Y | Zeroed by lock |
| `$0008,X` | 2 | Wait counter | Zeroed by lock |
| `$09E0` | 2 | Will ability bonus byte | Cleared by unlock |
| `$0658` | 2 | Held joypad mask | Bit `$8000` set by unlock |
| `$joypad_mask_std` | 2 | Joypad input mask | `$0F00` set (lock), `$CFF0` cleared (unlock) |
| `$player_flags` | 2 | Player state flags | Bit `$0800` set (lock); bits `$0002`/`$0800`/`$0F00` cleared (unlock) |

---

## Call Reference Matrix

### Internal Calls

| Caller | Callee | Type |
|--------|--------|------|
| All 5 triggers | `IsPlayerSliderSpriteBank` (`$D204`) | JSR `$&` |
| All 5 triggers | `LockPlayerForClimb` (`$D088`) | JSR `$&` |
| All 4 glide funcs | `UnlockPlayerAfterClimb` (`$D0AE`) | JSR `$&` |
| `UnlockPlayerAfterClimb` | `RestorePlayerControl` (`$D58A`) | JSR `$&` |

### External Callers (from ramps.asm)

| Caller | Target | Type |
|--------|--------|------|
| `RampPlayerClimbEast` (ramp_east climb) | `RestorePlayerControl` (`$D58A`) | JSR `$&` |
| `RampPlayerClimbSouth` (ramp_south climb) | `RestorePlayerControl` (`$D58A`) | JSR `$&` |
| `RampPlayerClimbNorth` (ramp_north climb) | `RestorePlayerControl` (`$D58A`) | JSR `$&` |
| `RampArcDriver` (ramp sprite anim) | `RestorePlayerControl` (`$D58A`) | JSR `$&` |

---

## External Dependencies

| Target | Bank | Purpose |
|--------|------|---------|
| `$player_actor` | global WRAM | Player actor slot ID |
| `PlayerIdleEntry` | `$02` | Normal player state machine (set by `RestorePlayerControl`) |
| `player_character` | `$00` | Include for player variable access |
| `ramps.asm` | `$00` | Slope walk system — shares `RestorePlayerControl` |

---

## Scene Usage Table

| Trigger | Scene Count | Areas |
|---------|-------------|-------|
| `SliderGlideTriggerWest` | 2 | Mu Passage |
| `SliderGlideTriggerEast` | 2 | Mu Passage |
| `SliderGlideTriggerNorthEntry` | 1 | Angel Village |
| `SliderGlideTriggerNorth` | 12+ | Mu, Angel Village, Angkor Wat, Dracula Mansion |
| `SliderGlideTriggerSouth` | 10+ | Mu, Angel Village, Angkor Wat, Dracula Mansion |

All triggers are placed as invisible `actor_def` entries in `scene_actors.asm` on Psycho Slider tile lanes.

---

## Statistics

### Code Distribution

| Category | Count | Size |
|----------|-------|------|
| Actor definitions (triggers) | 5 | ~307 bytes |
| Directional glide functions | 4 | ~184 bytes |
| Shared subroutines | 4 | ~147 bytes |
| **Total (core)** | **13 parts** | **~638 bytes** |
| Shared utility (`RestorePlayerControl`) | 1 | 54 bytes (at `$D58A`) |
| Combined with ramps.asm | — | ~1,336 bytes total block |

### Block Properties

| Property | Value |
|----------|-------|
| Block name | `slider_glide` |
| Movable | **false** |
| Reason | Tight `$&` coupling to `ramps.asm` |
| Parts | 13 |
| Cross-file shared sub | `RestorePlayerControl` (4 external callers) |

---

*Source: `extracted/system/engine/slider_glide.asm`, `extracted/actors/ramps.asm`.*
