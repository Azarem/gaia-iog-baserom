# COP family: BG rearrange

_Deep-audited ops: `[32]`, `[33]`, `[34]`_

[← COP index](../index.md)

## Overview

Stage and apply background **event block** tilemap/palette swaps (doors opening, walls breaking, dark-space reveals). `[32]` loads metadata via `LookupEventBlock`; `[33]` animates until complete; `[34]` uses the actor’s death-action index instead of an explicit operand.

## Shared state

| Symbol | Role |
|--------|------|
| Event block table | `$81D3CE` + 8×index (via `event_blocks`) |
| Staging buffer | `$96`–`$A4` (engine scratch during lookup) |
| `$7F0024,X` (`deathActionIdx`) | Index for `[34]` |
| `$06F8` | SFX queue — forced to `$0F0F` during `[34]` lookup |

## Family notes

- Production pattern is **`[32]` (index) then `[33]`** — apply always yields frames through `AnimateEventBlock` + `UpdateFrameDialogue`.
- Actor list **death action** metadata is sugar for “on death: `[34]` + `[33]`” (same index as a manual `[32]`).
- Dark-space Gaia (`sE6_gaia.asm`) chains many index pairs for sequential room reveals.

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `32` | `StageBgChange` | 102 | Byte BgChg | `StageBgChange` | Continue |
| `33` | `ApplyBgChange` | 103 | (none) | `ApplyBgChange` | Halt (multi-frame) |
| `34` | `StageBgChangeFromDeathIdx` | 1 | (none) | `StageBgChangeFromDeathIdx` | Continue |

**Family call-site total:** 206

## Opcodes

#### COP [32] — `StageBgChange`

- **Handler:** `StageBgChange` @ `extracted/system/engine/cop_handlers_palette.asm`
- **Parameters:** `Byte` event-block index

##### What it does

Reads index, calls `JSL LookupEventBlock` (queues tile/palette diff into engine buffers), RTI. Does **not** draw to the screen yet.

```asm
StageBgChange {
    TYX
    LDA [$0A]
    INC $0A
    AND #$00FF
  loc_00931F:
    JSL $@event_blocks.LookupEventBlock
    RTI
}
```

##### How it is used

Doors, switches, lithographs, mine collapses — always followed by `[33]`:

```asm
; system/dark_space/sE6_gaia.asm
COP [StageBgChange] ( #88 )
COP [ApplyBgChange]
COP [StageBgChange] ( #8A )
COP [ApplyBgChange]
```

Ending changed-world sequence and Babel comet lair use the same pairing.

##### Parameters & return contract

| Item | Value |
|------|-------|
| Index | Event block row in `$81D3CE` table |
| Must pair | `[33]` on next script beat |
| Source examples | `sE6_gaia.asm:215+`, `av75_voice_doors.asm`, `it19_breakable_wall.asm` |

---

#### COP [33] — `ApplyBgChange`

- **Handler:** `ApplyBgChange` @ `cop_handlers_palette.asm`
- **Parameters:** (none)

##### What it does

One full `UpdateFrameRender` + `UpdateFrameDialogue`, then loop: `AnimateEventBlock` until carry set (animation complete), calling `UpdateFrameDialogue` between steps. RTI when finished — may occupy many frames.

```asm
ApplyBgChange {
    JSL UpdateFrameRender
    loc_009335:
    JSL AnimateEventBlock
    BCS done
    JSL UpdateFrameDialogue
    BRA loc_009335
}
```

##### How it is used

103 sites — every staged BG change in the game. Item use (`item_use_system.asm`) and field reveal FX call the pair when revealing hidden passages.

##### Parameters & return contract

| Item | Value |
|------|-------|
| Preconditions | Prior `[32]` or `[34]` staging |
| Outcome | Blocks script until animation completes |
| Source examples | `SpawnFieldRevealEffect.asm`, `ending_changed_world/s90_changed_world.asm` |

---

#### COP [34] — `StageBgChangeFromDeathIdx`

- **Handler:** `StageBgChangeFromDeathIdx` @ `cop_handlers_palette.asm`
- **Parameters:** (none)

##### What it does

Loads `$7F0024,X` as the event index, pushes `$0F0F` to `$06F8`, falls through to `loc_00931F` (same as `[32]`).

##### How it is used

Single explicit script call site; primary use is **death-action wiring** on actors that break walls or open floors when defeated. Manual scripts almost always use `[32]` with an immediate index instead.

##### Parameters & return contract

| Item | Value |
|------|-------|
| Index source | Actor `deathActionIdx` at spawn/list setup |
| SFX | Both channels queued `$0F` during lookup |
| Follow with | `[33]` in death script or engine callback |
