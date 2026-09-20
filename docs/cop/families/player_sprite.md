# COP family: Player sprite

_Deep-audited ops: `[8E]`, `[8F]`, `[90]`, `[91]`, `[92]`, `[93]`, `[94]`, `[95]`, `[96]`, `[97]`, `[98]`_ · _Source: [`cop_handlers_player_sprite.asm`](../../../extracted/system/engine/cop_handlers_player_sprite.asm)_

[← COP index](../index.md)

## Overview

Eleven opcodes for **Will / Freedan / Shadow** sprite staging, axis movement setup, one-shot animation ticks, and **wall-type–gated** walk animation. They mirror the generic `$80`–`$89` sprite staging model, but animation indices are resolved through **`SetActorBody`** (current `characterForm` → `body_table`) except where noted. Wall ops (`$94` + `$96`–`$98`) implement ice-ramp / wall-slide style movement: stage a walk with an expected collision **type**, then advance frames only while the player holds a direction button and the probed tile matches that type.

**Handler source:** `extracted/system/engine/cop_handlers_player_sprite.asm` (bank `$00`).

## Shared state

| Symbol | Address | Role |
|--------|---------|------|
| `characterForm` | `$0AD4` | 0=Will, 1=Freedan, 2=Shadow — selects `body_table` row in `SetActorBody` |
| `body_table` | ROM | 6-byte entries: spriteset ptr + bank byte per body index |
| `$28` / `$2A` | actor | Animation index / frame counter (cleared on stage) |
| `$2C` / `$2E` | actor | X / Y axis frame durations after `AnimFrameLookup` |
| `moveXAlt` / `moveYAlt` | `$7F0018,X` / `$7F001A,X` | Per-axis movement deltas for staged walk |
| `playerWallType` | `$09B0` | Collision **type** byte saved by `$94`; compared by `$96`–`$98` |
| `joypadCurrent` | `$0656` | Held buttons; `$96`–`$98` compare operand **Word** mask here |
| `playerFlags` | `$09AE` | Bit `$8000` set by `$8E` (direct body-table override active) |
| `$10` | actor | Bit `$0004` set on solid/type `$0F` tile during wall anim probe |

## Family notes

- **`$8F`–`$92`, `$94`, `$95`** call `SetActorBody` so one script works for all three forms; **`$8E`** indexes `body_table` from the script byte directly and sets `playerFlags` `$8000`.
- **`$8F`–`$94`** cache script bank/PC in `$00`/`$02` and **`RTI`** — same deferred staging pattern as `StagePlayerSprite` / `StageSpriteMove*`.
- **`$93` (`RunPlayerAnim`)** is the player-specific **`AnimOnce`**: one `UpdateActorAnimation` per tick; **`RTL`** until the sequence completes (carry set).
- **`$94` must precede `$96`–`$98`** in the same walk loop so `playerWallType` is defined.
- **`$96`–`$98`** are live (not unused). Operand is a **joypad button mask** (`Word`), not map context. `$0656` in the handler file is **`joypadCurrent`**, not a map ID.
- Extracted ASM uses **`StagePlayerSprite` / `StagePlayerMoveX|Y|XY`** names from `db-us/copdef.json`; handlers are named `StagePlayerSpr*`.

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `8E` | `SetPlayerSpriteDirect` | 24 | `Byte BodyIdx` | `SetPlayerSpriteDirect` | Continue |
| `8F` | `StagePlayerSprite` | 93 | `Byte Anim` | `StagePlayerSpr` | Continue (deferred stage) |
| `90` | `StagePlayerMoveX` | 2 | `Byte Anim`, `Byte XStep` | `StagePlayerSprX` | Continue (deferred stage) |
| `91` | `StagePlayerMoveY` | 21 | `Byte Anim`, `Byte YStep` | `StagePlayerSprY` | Continue (deferred stage) |
| `92` | `StagePlayerMoveXY` | 9 | `Byte Anim`, `Byte XStep`, `Byte YStep` | `StagePlayerSprXY` | Continue (deferred stage) |
| `93` | `RunPlayerAnim` | 8 | (none) | `RunPlayerAnim` | **Halt** until anim done |
| `94` | `StagePlayerSprWall` | 0 | `Byte Anim`, `Byte XStep`, `Byte YStep`, `Byte WallType` | `StagePlayerSprWall` | Continue (deferred stage) |
| `95` | `StagePlayerSprFromDP` | 8 | (none) | `StagePlayerSprFromDP` | Continue (deferred stage) |
| `96` | `WallAnimHere` | 0 | `Word JoyMask` | `WallAnimHere` | Continue or **Halt** (anim) |
| `97` | `WallAnimNorth` | 0 | `Word JoyMask` | `WallAnimNorth` | Continue or **Halt** (anim) |
| `98` | `WallAnimSouth` | 0 | `Word JoyMask` | `WallAnimSouth` | Continue or **Halt** (anim) |

**Family call-site total:** 165

**Legacy copdef / wiki aliases (grep both when hunting call sites):** `SetPlayerBodySprite`, `AnimPlayerOnce`, `StagePlayerMoveXYWall`, `StagePlayerSpriteFromBank`, `WallCheckCurrent`, `WallCheckNorth`, `WallCheckSouth`.

---

## Opcodes

#### COP [8E] — `SetPlayerSpriteDirect` (body table index → spriteset, no `SetActorBody`)

- **Preferred name:** `SetPlayerSpriteDirect`
- **Aliases:** `SetPlayerBodySprite`
- **Handler:** `SetPlayerSpriteDirect` @ [`cop_handlers_player_sprite.asm:29-53`](../../../extracted/system/engine/cop_handlers_player_sprite.asm)
- **Pairs with:** Form-specific idle/walk scripts that must force a **raw** `body_table` row (credits poses, Freedan reveal, Dark Gaia sequences)

##### What it does (exact semantics)

1. Read one byte from script → treat as **`body_table` index** (not animation `$28` index).
2. Compute `index × 6`, load spriteset word + bank byte into `$7F0006,X` / `$7F0008,X`; cache offset in `$7F000E,X` and raw index in `$0AC8`.
3. Set **`playerFlags` bit `$8000`** (direct override — `GetPlayerFacingDirection` may use alt tables).
4. Advance script PC and **`RTI`**.

Does **not** call `SetActorBody` or write `$28`.

```asm
SetPlayerSpriteDirect {
    TYX
    SEP #$20
    LDA [$0A]             ; body_table index
    STA $0AC8
    ; … index × 6 → body_table …
    LDA #$8000
    TSB $playerFlags
    INC $0A
    LDA $0A
    STA $02, S
    RTI
}
```

##### How it is used in source

**Credits / showcase** — cycle many animation indices, then force a fixed body row for portrait poses (`ending/ending_credits/sF7_credits_player.asm`):

```asm
COP [StagePlayerSprite] ( #00 )
…
COP [SetPlayerSpriteDirect] ( #04 )
```

**Cutscene static poses** — Freedan reveal and “frozen” dialogue sprites (`actors/player_transition_handlers.asm`, `system/dark_space/sE6_gaia.asm`) repeat `SetPlayerSpriteDirect ( #04 )` or `( #05 )` before a tight `StageSpriteFrame` / `AnimOnce` loop.

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand | 1 byte — `body_table` index |
| WRAM | `$0AC8`, `$7F0006,X`, `$7F0008,X`, `$7F000E,X`, `playerFlags` `$8000` |
| Script resume | Next byte after operand |

---

#### COP [8F] — `StagePlayerSprite` (stage player anim via current form)

- **Preferred name:** `StagePlayerSprite` (copdef) / handler `StagePlayerSpr`
- **Aliases:** (none common)
- **Handler:** `StagePlayerSpr` @ [`cop_handlers_player_sprite.asm:58-72`](../../../extracted/system/engine/cop_handlers_player_sprite.asm)
- **Params:** `Byte Anim` — animation index stored to **`$28`**, `$2A` cleared

##### What it does

Read anim byte → **`$28`**, **`SetActorBody`**, save `$0A`/`$0C` to `$00`/`$02`, patch COP return PC, **`RTI`**. Movement engine applies the staged anim on the deferred path (same as generic stage sprite).

##### How it is used in source

Dominant opcode in **`actors/player/player_character.asm`** — idle facing dispatch (`#00`–`#03`, Shadow `#10`–`#12`), ladder/shimmy helpers, vine climb setup. Also **credits auto-walk** (`ending/ending_credits/sF7_credits_player.asm`), **space flight / epilogue** (`babel_tower/`, `ending/ending_comet/sE5_epilogue.asm`), and **shared transition library** (`actors/player_transition_handlers.asm`).

Example — idle row selection by form (`player_character.asm`):

```asm
COP [BranchOnFlagByte] ( #00, #01, &ShadowSouthIdle )
COP [StagePlayerSprite] ( #00 )   ; Will south idle
…
COP [StagePlayerSprite] ( #10 )     ; Shadow south idle
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand | 1 byte — animation index for current `characterForm` |
| Side effects | `$28`, `$2A`, spriteset via `SetActorBody`; `$00`/`$02` saved |
| Outcome | Continue (staging completes on engine entry) |

---

#### COP [90] — `StagePlayerMoveX` (stage + X axis duration)

- **Handler:** `StagePlayerSprX` @ [`cop_handlers_player_sprite.asm:77-97`](../../../extracted/system/engine/cop_handlers_player_sprite.asm)
- **Params:** `Byte Anim`, `Byte XStep` → `moveXAlt`, `$2C` via `AnimFrameLookup`

##### What it does

Same as `$8F`, plus read **X step** byte → `$7F0018,X`, lookup frame duration → **`$2C`**.

##### How it is used in source

Rare; **credits horizontal walk** (`sF7_credits_player.asm`):

```asm
loc_09E026:
    COP [StagePlayerMoveX] ( #0E, #02 )
    COP [AnimOnce]
    BRA loc_09E026
```

**Epilogue** (`ending/ending_comet/sE5_epilogue.asm`) uses a single X staging step before idle sprite.

##### Parameters & contract

| Item | Value |
|------|-------|
| Operands | Anim index, X movement delta (same encoding as `StageMoveX`) |
| Actor RAM | `$28`, `$2C`, `moveXAlt` |
| Typical pair | Generic **`AnimOnce`** or **`RunPlayerAnim`** in cutscenes; wall loops use `$94`+`$96`–`$98` |

---

#### COP [91] — `StagePlayerMoveY` (stage + Y axis duration)

- **Handler:** `StagePlayerSprY` @ [`cop_handlers_player_sprite.asm:102-122`](../../../extracted/system/engine/cop_handlers_player_sprite.asm)
- **Params:** `Byte Anim`, `Byte YStep` → `moveYAlt`, **`$2E`**

##### What it does

Y-axis counterpart to `$90`.

##### How it is used in source

**Vertical scripted motion** — vine climb entry, ladder landings, Babel/epilogue climbs (`player_character.asm`, `babel_tower/comet_lair/sE8_dark_gaia.asm`, `btE4_kara.asm`, `na49_neil.asm`):

```asm
COP [StagePlayerMoveY] ( #19, #07 )
COP [AnimOnce]
…
COP [StagePlayerMoveY] ( #1C, #00 )   ; ladder landing
COP [AnimOnce]
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Operands | Anim index, Y delta |
| Actor RAM | `$28`, `$2E`, `moveYAlt` |

---

#### COP [92] — `StagePlayerMoveXY` (stage + both axes)

- **Handler:** `StagePlayerSprXY` @ [`cop_handlers_player_sprite.asm:127-153`](../../../extracted/system/engine/cop_handlers_player_sprite.asm)
- **Params:** `Byte Anim`, `Byte XStep`, `Byte YStep`

##### What it does

Combines `$90` and `$91` in one COP: both `AnimFrameLookup` results → `$2C` and `$2E`.

##### How it is used in source

**Ladder / shimmy entry** — initial pose with diagonal or horizontal nudge (`player_character.asm`):

```asm
COP [StagePlayerMoveXY] ( #26, #00, #1B )   ; ladder south entry
COP [AnimOnce]
…
COP [StagePlayerMoveXY] ( #33, #51, #00 )   ; shimmy right entry
COP [AnimOnce]
```

**Ramps** (`actors/ramps.asm`) stage diagonal approach anims before ramp physics.

##### Parameters & contract

| Item | Value |
|------|-------|
| Operands | Anim, X step, Y step |
| Use when | Both axes need frame durations in one script beat |

---

#### COP [93] — `RunPlayerAnim` (player `AnimOnce`)

- **Preferred name:** `RunPlayerAnim`
- **Aliases:** `AnimPlayerOnce`
- **Handler:** `RunPlayerAnim` @ [`cop_handlers_player_sprite.asm:158-173`](../../../extracted/system/engine/cop_handlers_player_sprite.asm)
- **Outcome:** **Halt** — yields **`RTL`** until `UpdateActorAnimation` reports complete (carry set)

##### What it does

```asm
RunPlayerAnim {
    TYX
    JSL UpdateActorAnimation
    BCC loc_00A116        ; still animating → RTL
    LDA #$0000
    STA $2C
    STA $2E               ; clear axis timers when done
    LDA $0A
    STA $02, S
    RTI
  loc_00A116:
    PLA
    PLA
    RTL
}
```

Unlike **`AnimOnce`** on generic actors, this runs in the **player handler bank** after `$8F`–`$95` staging.

##### How it is used in source

**Forced walk / warp scroll** (`system/engine/forced_walk.asm`) — every cardinal forced-walk step:

```asm
JSR ReadDirSprite_YVelocity    ; fills DP $0000 with sprite index
COP [StagePlayerSprFromDP]
COP [RunPlayerAnim]
```

Pair with **`StagePlayerSprFromDP`** or any stage op that sets `$28` before the anim tick.

##### Parameters & contract

| Item | Value |
|------|-------|
| Operands | none |
| Clears on success | `$2C`, `$2E` |
| Contrast | **`AnimOnce`** (`$89`) for NPCs; **`RunPlayerAnim`** for player body table |

---

#### COP [94] — `StagePlayerSprWall` (XY stage + save wall type)

- **Aliases:** `StagePlayerMoveXYWall`
- **Handler:** `StagePlayerSprWall` @ [`cop_handlers_player_sprite.asm:178-208`](../../../extracted/system/engine/cop_handlers_player_sprite.asm)
- **Params:** `Byte Anim`, `Byte XStep`, `Byte YStep`, **`Byte WallType`**

##### What it does

Identical to **`$92`**, plus fourth byte → **`playerWallType` (`$09B0`)** for subsequent **`$96`–`$98`** probes.

##### How it is used in source

Call sites are concentrated in **player movement / wall-slide script loops** (bank `$00` player actor). They often appear without symbolic names in older extracts; search ROM audits for COP **`$94`** / id **148**. Pattern:

```asm
COP [StagePlayerSprWall] ( #anim, #xStep, #yStep, #wallType )
; loop:
COP [WallAnimHere] ( #$0101 )    ; example: hold B + direction mask
; or WallAnimNorth / WallAnimSouth for corner tiles
```

See **`$96`–`$98`** for probe geometry.

##### Parameters & contract

| Item | Value |
|------|-------|
| Fourth byte | Collision layer **type** (not solid nibble alone) |
| Prerequisite for | `$96`, `$97`, `$98` |
| WRAM | `$09B0` until next `$94` |

---

#### COP [95] — `StagePlayerSprFromDP` (stage anim from DP `$0000`)

- **Aliases:** `StagePlayerSpriteFromBank` (misleading legacy name)
- **Handler:** `StagePlayerSprFromDP` @ [`cop_handlers_player_sprite.asm:213-226`](../../../extracted/system/engine/cop_handlers_player_sprite.asm)

##### What it does

**`LDA $0000`** (direct page) → **`$28`**, then `SetActorBody` and deferred PC save — **no script byte consumed** for anim index.

##### How it is used in source

**Forced walk** (`forced_walk.asm`) — `ReadDirSprite_*Velocity` helpers store the next walk sprite index in **`$0000`** before staging:

```asm
JSR ReadDirSprite_YVelocity
COP [StagePlayerSprFromDP]
COP [RunPlayerAnim]
```

Same pattern for all four `ForcedWalk*` handlers (8× **`StagePlayerSprFromDP`** + **`RunPlayerAnim`** pairs in that file).

##### Parameters & contract

| Item | Value |
|------|-------|
| Script operands | none |
| Input | Low byte of **`DP $0000`** must be set by native helper before COP |
| Output | Same deferred staging as `$8F` |

---

#### COP [96] — `WallAnimHere` (wall type at feet + joypad gate)

- **Aliases:** `WallCheckCurrent`
- **Handler:** `WallAnimHere` @ [`cop_handlers_player_sprite.asm:231-272`](../../../extracted/system/engine/cop_handlers_player_sprite.asm)
- **Params:** **`Word JoyMask`** — compared to **`joypadCurrent` (`$0656`)**
- **Outcome:** Skip anim ( **`RTI`**, continue script) if mask mismatch, misaligned, or wrong tile; **`RTL`** while anim runs; set **`$10` bit `$0004`** on blocked `$F0` / type `$0F`

##### What it does

1. If **`(joypadCurrent & JoyMask) ≠ JoyMask`**, skip to end (no anim).
2. Require **`$16 & $000F = 0`** (16px Y grid alignment).
3. **`TileCollisionQuery`** at actor **`($14, $16)`**.
4. If solid nibble or type **`$0F`** → set wall-contact flag **`$10:$0004`**, skip anim.
5. If tile type **= `playerWallType`**, call **`UpdateActorAnimation`**; **`RTL`** until complete.

##### How it is used in source

Used inside **player wall-slide / ice ramp** loops together with **`$94`**. Operand masks match **`BranchIfPressed`** conventions (e.g. **`#$0101`** run + direction). These ops have 0 ROM call sites in the current extract — they exist in the dispatch table but no extracted script references them.

##### Parameters & contract

| Item | Value |
|------|-------|
| Probe position | Actor X/Y (feet cell) |
| Requires | Prior **`$94`** setting **`playerWallType`** |
| Not | Map context / `$0656` as scene ID |

---

#### COP [97] — `WallAnimNorth` (probe one tile north)

- **Aliases:** `WallCheckNorth`
- **Handler:** `WallAnimNorth` @ [`cop_handlers_player_sprite.asm:277-320`](../../../extracted/system/engine/cop_handlers_player_sprite.asm)
- **Params:** `Word JoyMask`

##### What it does

Same as **`$96`**, but collision sample at **`Y − $10`** (one metatile north). Used when wall interaction is tied to **north-facing** collision types (`$09` family) on the tile above the player.

##### How it is used in source

East/west movement through **north-wall columns** (`player_move_east.asm` documents `$09` handlers native-side; script side uses **`WallAnimNorth`** in the player COP loop). Pair with **`StagePlayerSprWall`** when **`WallType`** matches the north probe.

##### Parameters & contract

| Item | Value |
|------|-------|
| Probe | **`$001C = $16 − $10`**, **`$0018 = $14`** |
| Otherwise | Identical gating to **`$96`** |

---

#### COP [98] — `WallAnimSouth` (probe one tile south)

- **Aliases:** `WallCheckSouth`
- **Handler:** `WallAnimSouth` @ [`cop_handlers_player_sprite.asm:325-368`](../../../extracted/system/engine/cop_handlers_player_sprite.asm)
- **Params:** `Word JoyMask`

##### What it does

Same as **`$96`**, but sample at **`Y + $10`**. Used for **south-wall** (`$06`) slide animations.

##### How it is used in source

Complements **`$97`** in cardinal movement scripts; same **`$94` + loop** structure as other wall ops.

##### Parameters & contract

| Item | Value |
|------|-------|
| Probe | **`$001C = $16 + $10`** |
| Joypad / alignment / type rules | Same as **`$96`** |

---

## Related generic ops

| Generic | Player family | Difference |
|---------|---------------|------------|
| `StageSprite` (`$80`) | `StagePlayerSprite` (`$8F`) | `SetActorBody` + shared form scripts |
| `AnimOnce` (`$89`) | `RunPlayerAnim` (`$93`) | Player bank handler; clears `$2C`/`$2E` |
| `StageMoveXY` (`$85`) | `StagePlayerMoveXY` (`$92`) | Body table + player movement fields |
