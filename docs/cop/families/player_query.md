# COP family: Player query

_Deep-audited ops: `[28]`, `[29]`, `[2A]`, `[2B]`, `[2C]`, `[2D]`, `[2E]`, `[2F]`, `[30]`, `[31]`, `[35]`, `[48]`, `[49]`_

[← COP index](../index.md)

## Overview

Thirteen opcodes for **spatial and facing queries** against the player (or another actor): exact position match, 3-way axis branches, nearer-axis choice, 8-way octant direction, 4-way cardinal dominance, player facing dispatch, and **character form** guard. Most opcodes **branch** by patching the COP return PC (`$02,S`); **`$2D`**, **`$2E`**, **`$35`**, and **`$48`** leave a numeric result in **`A`** and continue.

**Handler sources:**

- `extracted/system/engine/cop_handlers_spatial.asm` — `$28`–`$31`, `$35`
- `extracted/system/engine/cop_handlers_lifecycle.asm` — `$48`, `$49`
- `extracted/system/engine/cop_handlers_solid.asm` — `ComputeDirectionToPlayer` (internal, used by `$2D`–`$30`)
- `extracted/system/engine/GetPlayerFacingDirection.asm` — `$31`, `$48`

## Shared state

| Symbol | Address | Role |
|--------|---------|------|
| `playerActor` | `$09AA` | WRAM pointer to player slot |
| `$14` / `$16` | actor | This actor pixel X / Y |
| `$0014` / `$0016`,Y | actor Y | Player (or target) position via index |
| `characterForm` | `$0AD4` | 0=Will, 1=Freedan, 2=Shadow (`$49`) |
| `$0028`, player | anim frame | Input to **`GetPlayerFacingDirection`** |
| `$0018` / `$001C` | DP | Reference point for direction math |

## Family notes

- **`$2A` / `$2B`** use **three** `&Code` operands (west/north, east/south, here) plus one **`Word` threshold** — compare **absolute** ΔX or ΔY vs threshold; zero delta always picks **center**.
- **`$2C`** compares **|ΔY|** vs **|ΔX|**; **`$2C` operand[0]`** = nearer **Y** axis, **`[1]`** = nearer **X** (or equal).
- **`$2D` / `$2E`** return **8-way octant in `A` (0–7)** via `ComputeDirectionToPlayer` (also in **`Y`** before handler moves it to **`A`** on RTI).
- **`$35` (`CardinalToPlayer`)** returns **`A = 0 N, 1 E, 2 S, 3 W`** — **not** the same encoding as **`GetPlayerFacing`** (0=S, 1=N, 2=W, 3=E).
- **`$31`** reads **four** `&Code` words (South, North, West, East order for facing 0–3). Invalid facing (≥4) skips all eight bytes.
- **`$2F`** has **zero** extracted call sites; **`$30`** is used (canal worm octant attacks).
- **`$49`** branches when **`characterForm ≠ operand`** (skip branch when form **matches**).

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `28` | `BranchIfPlayerAt` | 35 | `Word X`, `Word Y`, `&Code` | `BranchIfPlayerAt` | Branch or Continue |
| `29` | `BranchIfActorAt` | 2 | `Byte AcNum`, `Word X`, `Word Y`, `&Code` | `BranchIfActorAt` | Branch or Continue |
| `2A` | `BranchOnPlayerX` | 90 | `Word Dist`, `&Code W`, `&Code E`, `&Code Here` | `BranchOnPlayerX` | Branch (3-way) |
| `2B` | `BranchOnPlayerY` | 65 | `Word Dist`, `&Code N`, `&Code S`, `&Code Here` | `BranchOnPlayerY` | Branch (3-way) |
| `2C` | `BranchNearerAxis` | 42 | `&Code NearY`, `&Code NearX` | `BranchNearerAxis` | Branch (2-way) |
| `2D` | `DirToPlayer` | 9 | (none) | `DirToPlayer` | Continue (`A` = octant) |
| `2E` | `DirToPlayerFrom` | 1 | `Byte OffX`, `Byte OffY` | `DirToPlayerFrom` | Continue (`A` = octant) |
| `2F` | `BranchIfDirToPlayer` | 0 | `Byte Dir`, `&Code` | `BranchIfDirToPlayer` | Branch or Continue |
| `30` | `BranchIfDirToPlayerFrom` | 8 | `Byte OffX`, `Byte OffY`, `Byte Dir`, `&Code` | `BranchIfDirToPlayerFrom` | Branch or Continue |
| `31` | `BranchOnPlayerFacing` | 0 | `&Code S`, `&Code N`, `&Code W`, `&Code E` | `BranchOnPlayerFacing` | Branch (4-way) |
| `35` | `CardinalToPlayer` | 15 | (none) | `CardinalToPlayer` | Continue (`A` = N/E/S/W) |
| `48` | `GetPlayerFacing` | 6 | (none) | `GetPlayerFacing` | Continue (`A` = facing) |
| `49` | `BranchIfBodyNe` | 0 | `Byte Body`, `&Code` | `BranchIfBodyNe` | Branch or Continue |

**Family call-site total:** 273

---

## Opcodes

#### COP [28] — `BranchIfPlayerAt` (exact player pixel match)

- **Handler:** `BranchIfPlayerAt` → shared `loc_009105` @ `cop_handlers_spatial.asm:131-176`
- **Params:** `Word PosX`, `Word PosY`, `&Code`

##### What it does

Load **`playerActor` → Y**, compare **`$0014,$0016,Y`** to operands **exactly**. On match, branch to **`&Code`**; else skip the branch word and continue.

```asm
BranchIfPlayerAt {
    TYX
    LDY $playerActor
    BRA loc_009105    ; shared with BranchIfActorAt
; loc_009105: CMP player X, then Y, then take &Code or skip
}
```

##### How it is used in source

**Triggers and platforms** — wait until the player stands on precise coordinates (elevator, switches, cutscene marks):

```asm
; diamond_mine/mine_elevator/dm43_elevator.asm
COP [BranchIfPlayerAt] ( #$0048, #$0080, &code_0AA5CE )

; edward_castle/aqueduct_hall/ec0F_rusty_switch.asm
COP [BranchIfPlayerAt] ( #$00D8, #$0298, &code_0A899D )

; mu/mu_vampire_lair/mu67_vampires.asm — two tile columns, same handler
COP [BranchIfPlayerAt] ( #$0180, #$0060, &func_0AFA48 )
COP [BranchIfPlayerAt] ( #$0180, #$01E0, &func_0AFA48 )
```

Often paired with **`SetEntryHere`** / **`RTL`** polling loops so the actor wakes each frame until the player steps on the spot.

##### Parameters & contract

| Item | Value |
|------|-------|
| Match | **Exact** pixel X and Y (not tile-rounded) |
| On fail | Consumes X, Y, and branch operands without jumping |
| WRAM | Read-only on player position |

---

#### COP [29] — `BranchIfActorAt` (exact position for scene actor)

- **Handler:** `BranchIfActorAt` @ `cop_handlers_spatial.asm:140-176`
- **Params:** `Byte AcNum`, `Word PosX`, `Word PosY`, `&Code`

##### What it does

Read **`AcNum`**, **`ResolveActorIndex`** → **Y**, then same compare as **`$28`**.

##### How it is used in source

**Sky Garden underside switches** — test whether **another actor** (e.g. pushable `#03`) is on a pressure tile:

```asm
; sky_garden/garden_west_underside/sg54_pressure_switch.asm
COP [BranchIfActorAt] ( #03, #$0348, #$02E0, &code_05F75F )

; sky_garden/garden_southwest_underside/sg52_switch.asm
COP [BranchIfActorAt] ( #03, #$0258, #$0330, &code_05F6EB )
```

##### Parameters & contract

| Item | Value |
|------|-------|
| `AcNum` | Scene actor index (resolved via movement helper) |
| Compare target | That actor’s `$14`/`$16`, not the player |

---

#### COP [2A] — `BranchOnPlayerX` (3-way horizontal separation)

- **Handler:** `BranchOnPlayerX` @ `cop_handlers_spatial.asm:181-206`
- **Params:** `Word Dist`, `&Code West`, `&Code East`, `&Code Here`

##### What it does

Compute **`player.X − actor.X`**:

| Condition | Branch target |
|-----------|----------------|
| ΔX = 0 | **Here** (operand index +4) |
| \|ΔX\| ≤ **Dist** | **Here** |
| ΔX < −Dist (player left) | **West** (+2) |
| ΔX > +Dist (player right) | **East** (+6) |

Uses **`LDA [$0A], Y`** with Y = 2, 4, or 6 relative to operand block start.

##### How it is used in source

**Chase / patrol AI** — pick horizontal chase before vertical (`pyramid/pyCE_tuts.asm`, `pyD2_haunt.asm`, `angkor_wat/awB0_zombie.asm`, `awB1_gorgon.asm`):

```asm
COP [BranchOnPlayerX] ( #$0000, &code_0BC3D5, &code_0BC3D5, &code_0BC3F6 )
```

**Dist = 0** collapses to “player strictly west / east / same column” (common in shipped scripts). **`pyCC_mystic_ball.asm`** uses non-zero **`#$0020`** thresholds for ranged behavior.

##### Parameters & contract

| Item | Value |
|------|-------|
| Threshold | Unsigned pixel distance |
| Operand order | West, East, Here (same as copdef) |

---

#### COP [2B] — `BranchOnPlayerY` (3-way vertical separation)

- **Handler:** `BranchOnPlayerY` @ `cop_handlers_spatial.asm:211-236`
- **Params:** `Word Dist`, `&Code North`, `&Code South`, `&Code Here`

##### What it does

Same algorithm as **`$2A`** on **`player.Y − actor.Y`** (north = player above, south = below).

##### How it is used in source

Often **after `$2A`** in the same AI state (`pyCE_tuts.asm`):

```asm
COP [BranchOnPlayerY] ( #$0000, &code_0BC421, &code_0BC421, &code_0BC443 )
```

**Mystic ball** (`pyCC_mystic_ball.asm`) uses **`#$0018`** / **`#$0010`** bands; **zip fly** (`awB0_zip_fly.asm`) combines with **`BranchNearerAxis`**.

##### Parameters & contract

| Item | Value |
|------|-------|
| Symmetric to | **`$2A`** on Y axis |

---

#### COP [2C] — `BranchNearerAxis` (chase on closer axis)

- **Handler:** `BranchNearerAxis` @ `cop_handlers_spatial.asm:241-274`
- **Params:** `&Code NearY`, `&Code NearX`

##### What it does

Compare **|ΔY|** vs **|ΔX|** to player. If **|ΔY| < |ΔX|** → **`NearY`**; else → **`NearX`** (including equal).

##### How it is used in source

**Standard chase template** — after **`BranchIfPlayerNear`**, split movement:

```asm
; pyramid/pyCE_tuts.asm
COP [BranchIfPlayerNear] ( #04, &code_0BC4B1 )
COP [BranchNearerAxis] ( &code_0BC3CB, &code_0BC417 )
; NearY path → BranchOnPlayerX loops; NearX path → BranchOnPlayerY loops
```

Same structure in **`awB0_zombie.asm`**, **`awB1_gorgon.asm`**, **`mtA0_acid_spider.asm`**, **`pyD2_haunt.asm`**.

##### Parameters & contract

| Item | Value |
|------|-------|
| No threshold word | Pure axis dominance |
| Typical pairing | **`$2A`/`$2B`** on the chosen axis |

---

#### COP [2D] — `DirToPlayer` (8-way octant to player)

- **Handler:** `DirToPlayer` @ `cop_handlers_spatial.asm:279-290`
- **Params:** none
- **Returns:** **`A = 0..7`** octant (N, NE, E, SE, S, SW, W, NW per `ComputeDirectionToPlayer`)

##### What it does

Set reference **`($0018,$001C) = (actor.$14, actor.$16)`**, call **`ComputeDirectionToPlayer`**, return octant in **`A`**.

##### How it is used in source

**Octant dispatch tables** — **`angkor_wat/awB0_zip_fly.asm`**:

```asm
COP [DirToPlayer]
AND #$0007
STA $0000
COP [SwitchCase] ( #$0000, &code_list_0BB128 )
```

Enemies store octant in scratch then **`SwitchCase`** into directional attack/move routines.

##### Parameters & contract

| Item | Value |
|------|-------|
| Side effects | None on script PC beyond continue |
| Contrast **`$35`** | Octant (8) vs cardinal dominant axis (4) |

---

#### COP [2E] — `DirToPlayerFrom` (8-way from offset point)

- **Handler:** `DirToPlayerFrom` @ `cop_handlers_spatial.asm:375-404`
- **Params:** signed **`Byte OffX`**, **`Byte OffY`**

##### What it does

Sign-extend offsets, add to actor position, then **`ComputeDirectionToPlayer`**.

##### How it is used in source

**Single call** in extracted tree (audit count 1); useful when the logical “source” of the direction is **ahead of** the actor sprite (mouth, turret). Pattern matches **`$30`** without branching.

##### Parameters & contract

| Item | Value |
|------|-------|
| Offsets | Signed bytes (tile-ish steps in script space) |
| Returns | Octant in **`A`**, same as **`$2D`** |

---

#### COP [2F] — `BranchIfDirToPlayer` (branch on octant match)

- **Handler:** `BranchIfDirToPlayer` @ `cop_handlers_spatial.asm:409-435`
- **Params:** `Byte Dir`, `&Code`
- **Uses:** 0 (no extracted symbolic call sites)

##### What it does

Compute octant actor→player; if **`Dir`** matches, branch; else skip **`Dir` + &Code** (3 bytes).

##### How it is used in source

No **`COP [BranchIfDirToPlayer]`** in current extracted ASM; prefer **`$2D` + `SwitchCase`** (zip fly) or **`$30`** (canal worm). Opcode remains valid in dispatch table for ROM compatibility.

##### Parameters & contract

| Item | Value |
|------|-------|
| `Dir` | Expected octant 0–7 |
| On mismatch | Advance PC past branch target |

---

#### COP [30] — `BranchIfDirToPlayerFrom` (octant from offset)

- **Handler:** `BranchIfDirToPlayerFrom` @ `cop_handlers_spatial.asm:440-484`
- **Params:** `Byte OffX`, `Byte OffY`, `Byte Dir`, `&Code`

##### What it does

Direction from **`(actor + offset)`** to player; branch if equal to **`Dir`**.

##### How it is used in source

**Canal worm** — eight attack quadrants from a point above the sprite (`edward_castle/ec0D_canal_worm.asm`):

```asm
COP [BranchIfDirToPlayerFrom] ( #00, #F0, #04, &code_0A80D1 )
COP [StageSpriteFrame] ( #23 )
COP [AnimOnce]
…
COP [BranchIfDirToPlayerFrom] ( #00, #F0, #03, &code_0A818E )
```

**`#F0`** on Y is a signed **−16** pixel bias (probe one tile north of actor feet).

##### Parameters & contract

| Item | Value |
|------|-------|
| Offsets | Sign-extended bytes added to **`$14`/`$16`** |
| Typical **`Dir`** | 0–7 matching worm segment graphics |

---

#### COP [31] — `BranchOnPlayerFacing` (4-way player facing dispatch)

- **Handler:** `BranchOnPlayerFacing` @ `cop_handlers_spatial.asm:489-525`
- **Params:** four **`&Code`**: **South, North, West, East** (for **`GetPlayerFacing`** 0–3)

##### What it does

**`JSL GetPlayerFacingDirection`** → if 0..3, jump to matching operand; if invalid, skip **8** bytes of targets.

```asm
BranchOnPlayerFacing {
    TYX
    JSL GetPlayerFacingDirection
    BEQ loc_009300    ; 0 → operand 0 (South)
    DEC
    BEQ loc_009305    ; 1 → North
    …
}
```

**Facing encoding (`$48` / `$31`):** **0 = South, 1 = North, 2 = West, 3 = East** (animation-frame lookup).

##### How it is used in source

Handler exists in the dispatch table at slot `$31` but has 0 ROM call sites — no extracted script references `COP [BranchOnPlayerFacing]`. Use when the same COP script must fork on **which way Will is facing** (push blocks, ladder entries, attack-adjacent dialog). Search audits for COP **`$31`** / id **49** when symbolic names are absent.

Contrast: **`GetPlayerFacing`** in **`player_character.asm`** feeds a **14×7 idle dispatch table**, not four **`&Code`** labels.

##### Parameters & contract

| Item | Value |
|------|-------|
| Operand count | **4× `&Code`** (8 bytes) — copdef fixed |
| Invalid facing | Skip all targets, continue |
| Same helper as | **`$48`** |

---

#### COP [35] — `CardinalToPlayer` (dominant cardinal toward player)

- **Handler:** `CardinalToPlayer` @ `cop_handlers_spatial.asm:295-363` + epilogue **`code_009230`**
- **Params:** none
- **Returns:** **`A = 0 N, 1 E, 2 S, 3 W`** (dominant axis by |Δ|)

##### What it does

RTS-trick routine compares |ΔX| vs |ΔY| with sign handling; **`TYA`** passed through epilogue to **`A`** on **`RTI`**.

##### How it is used in source

**Tutorial enemies** (`pyramid/pyCE_tuts.asm`, **`pyCC_mystic_ball.asm`**, **`awB0_zombie.asm`**) — store direction then pick sprite / movement:

```asm
COP [CardinalToPlayer]
; A used immediately or stored to $0000 for table dispatch
```

Often followed by **`StageSpriteMove*`** or **`SwitchCase`**.

##### Parameters & contract

| Item | Value |
|------|-------|
| Encoding | **0=N, 1=E, 2=S, 3=W** (≠ **`GetPlayerFacing`**) |
| No branch | Script must **`SwitchCase`** or compare **`A`** |

---

#### COP [48] — `GetPlayerFacing` (query facing, no branch)

- **Handler:** `GetPlayerFacing` @ `cop_handlers_lifecycle.asm:205-211`
- **Params:** none
- **Returns:** **`A = 0 S, 1 N, 2 W, 3 E`**

##### What it does

Save script PC, **`JSL GetPlayerFacingDirection`**, **`RTI`** with facing in **`A`**.

```asm
GetPlayerFacing {
    TYX
    LDA $0A
    STA $02, S
    JSL GetPlayerFacingDirection
    RTI
}
```

##### How it is used in source

**Player idle matrix** (`actors/player/player_character.asm`):

```asm
COP [GetPlayerFacing]
AND #$0003
STA $24
; ×14 row offset into PlayerIdleDispatchTable
```

**Combat** (`system/engine/combat_collision.asm`, **`attack_ability_system.asm`**) — aim knockback / palettes by facing.

Native **`JSL GetPlayerFacingDirection`** also appears in **`great_wall/gw82_archer.asm`**, **`babel_tower/btE4_kara.asm`** where COP overhead is unnecessary.

##### Parameters & contract

| Item | Value |
|------|-------|
| Does not branch | Caller uses **`A`** |
| Transformed player | **`playerFlags` bit 15** → alt lookup path in helper |

---

#### COP [49] — `BranchIfBodyNe` (branch if player form ≠ expected)

- **Handler:** `BranchIfBodyNe` @ `cop_handlers_lifecycle.asm:216-235`
- **Params:** `Byte Body`, `&Code` — **Body** 0=Will, 1=Freedan, 2=Shadow

##### What it does

If **`characterForm ≠ Body`**, branch to **`&Code`**; if **equal**, skip branch word and continue.

##### How it is used in source

Handler exists in the dispatch table at slot `$49` but has 0 ROM call sites in the current extract. Logic sometimes uses **`BranchOnFlagByte`** on form flags instead.

Example pattern:

```asm
COP [BranchIfBodyNe] ( #01, &FreedanOnlyPath )   ; branch when NOT Freedan (i.e. Will or Shadow)
; fall through when Freedan
```

##### Parameters & contract

| Item | Value |
|------|-------|
| Branch when | **`$0AD4 ≠ Body`** |
| Continue when | Form **matches** operand |
| Related | Native **`LDA characterForm`** checks in attack system |

---

## Direction encodings (quick reference)

| API | Values | Use |
|-----|--------|-----|
| **`GetPlayerFacing` / `$31`** | 0=S, 1=N, 2=W, 3=E | Animation-facing / player scripts |
| **`CardinalToPlayer` (`$35`)** | 0=N, 1=E, 2=S, 3=W | Enemy chase toward player |
| **`DirToPlayer` (`$2D`)** | 0–7 octant | **`SwitchCase`** attack sectors |
| **`ComputeDirectionToPlayer`** | Internal 0–7 | Shared by **`$2D`–`$30`** |

## Related ops (other families)

| Op | Name | When to use instead |
|----|------|---------------------|
| `$33` | `BranchIfPlayerNear` | Radius tile distance, not exact pixel |
| `$44` / `$45` | `BranchIfPlayerInRelTiles` / `AbsTiles` | Rectangle regions |
| `$34` | `MoveToward` | Step toward player without branch |
