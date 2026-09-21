# COP family: Offscreen

_Deep-audited ops: `[27]`, `[68]`, `[69]`_ · _Source: [`cop_handlers_player_query.asm`](../../../extracted/system/engine/cop_handlers_player_query.asm), [`cop_handlers_offscreen.asm`](../../../extracted/system/engine/cop_handlers_offscreen.asm)_

[← COP index](../README.md)

## Overview

Yield while an actor is off-screen, branch when outside the camera window, or hold script execution until the global frame counter reaches a timeline mark. Credits choreography dominates `[69]` usage.

## Shared state

| Symbol | Role |
|--------|------|
| `$10` bit `$4000` | Actor off-screen flag (engine-maintained) |
| `$08` | Per-actor delay timer (used by `[27]`) |
| `$06D6`–`$06DC` region | Camera offset/bounds (see `BranchIfOffCamera`) |
| `$00E4` | Global frame counter |

## Family notes

- `[68]` script/asm name **`BranchIfOffCamera`**; older docs alias **`BranchIfOffscreen`**.
- `[69]` **`HaltIfMaxFrames`**: `BCC` on `threshold CMP $00E4` means **continue** when `$00E4 ≥ threshold`; **RTL yield** while `$00E4 < threshold`. Legacy “`< Min`” wording is easy to invert.

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `27` | `WaitWhileOffscreen` | 93 | Byte delay | `WaitWhileOffscreen` | Halt or Continue |
| `68` | `BranchIfOffCamera` | 5 | `&Code` | `BranchIfOffCamera` | Branch or Continue |
| `69` | `HaltIfMaxFrames` | 220 | Word threshold | `HaltIfMaxFrames` | Halt or Continue |

**Family call-site total:** 318

## Opcodes

#### COP [27] — `WaitWhileOffscreen`

- **Handler:** `WaitWhileOffscreen` @ [`cop_handlers_player_query.asm`](../../../extracted/system/engine/cop_handlers_player_query.asm)
- **Parameters:** `Byte` frame delay when waiting

##### What it does

If `$10 & $4000 = 0` (on screen): consume delay byte, RTI continue. If off-screen: rewind `$0A` by 2 (re-enter opcode), read delay into `$08`, **RTL** (retry next frame).

```asm
WaitWhileOffscreen {
    TYX
    LDA $10
    BIT #$4000
    BEQ loc_0090E8        ; on-screen → skip delay, continue
    ; rewind $0A, STA $08, RTL
}
```

##### How it is used

NPCs and props that should pause logic until the player scrolls them into view (93 sites — town props, enemies, cutscene extras).

##### Parameters & return contract

| Item | Value |
|------|-------|
| Off-screen | RTL loop with `$08` delay |
| On-screen | Operand consumed, no yield |
| Source examples | `town_door.asm`, `fr32_bg_sprite_*.asm` |

---

#### COP [68] — `BranchIfOffCamera`

- **Aliases:** `BranchIfOffscreen`
- **Handler:** `BranchIfOffCamera` @ [`cop_handlers_metatile.asm`](../../../extracted/system/engine/cop_handlers_metatile.asm)
- **Parameters:** `&Code`

##### What it does

Compares `$14`/`$16` against camera window (`cameraOffsetX/Y` minimum, `cameraBoundsX/Y` maximum). **Inside** window → skip branch operand. **Outside** any bound → RTI to branch target.

```asm
BranchIfOffCamera {
    ; X in [cameraOffsetX, cameraBoundsX), Y in [cameraOffsetY, cameraBoundsY)
    ; inside → skip &Code; outside → RTI branch
}
```

##### How it is used

Despawn when scrolled away, activate when off-camera, credits NPCs exiting the window (5 sites). Pairs with spawn logic for pool management.

##### Parameters & return contract

| Item | Value |
|------|-------|
| Branch when | Actor pixel pos outside camera rect |
| Source examples | `sF7_credits_npc_a.asm`, `ec0F_king_bat.asm` |

---

#### COP [69] — `HaltIfMaxFrames`

- **Aliases:** `HaltIfCounterGte` (continue once counter **≥** threshold)
- **Handler:** `HaltIfMaxFrames` @ [`cop_handlers_metatile.asm`](../../../extracted/system/engine/cop_handlers_metatile.asm)
- **Parameters:** `Word` frame threshold

##### What it does

Compare word operand to `$00E4`. If `$00E4 < threshold`: rewind `$0A` by 4, **RTL**. If `$00E4 ≥ threshold`: RTI continue.

```asm
HaltIfMaxFrames {
    LDA [$0A]             ; threshold
    CMP $00E4
    BCC loc_009E01        ; $00E4 >= threshold → done waiting
    ; rewind, RTL
}
```

##### How it is used

**Credits timeline** — dozens of sequential waits on the player and NPC credit actors:

```asm
; ending/ending_credits/sF7_credits_player.asm
COP [HaltIfMaxFrames] ( #$012C )
COP [HaltIfMaxFrames] ( #$01CC )
COP [HaltIfMaxFrames] ( #$0CA8 )
```

Also yorrick puzzles, torch FX, and any script synchronized to the master frame counter (220 sites).

##### Parameters & return contract

| Item | Value |
|------|-------|
| Wait while | `$00E4 < threshold` |
| Release when | `$00E4 ≥ threshold` |
| Source examples | `sF7_credits_player.asm`, `mtA1_yorrick_ew.asm`, `sF7_credits.asm` |
