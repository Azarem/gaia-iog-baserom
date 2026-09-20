# COP family: Actor death

_Deep-audited ops: `[A7]`, `[A8]`, `[A9]`, `[E0]`_ · _Source: [`cop_handlers_lifecycle.asm`](../../../extracted/system/engine/cop_handlers_lifecycle.asm), [`cop_handlers_flow.asm`](../../../extracted/system/engine/cop_handlers_flow.asm)_

[← COP index](../index.md)

## Overview

Four opcodes remove actors from the scene doubly-linked list (`$04` / `$06`, heads `$0056` / `$0058`). **`Die`** is the normal terminal opcode (`halt` in copdef — script ends with **`RTL`**). **`MarkDeath`** supports deferred teardown and **borrowed-actor** contexts (inventory cursors, multi-slot boss scripts). **`KillPrev`** / **`KillNext`** unlink the **adjacent** list neighbor while restoring the caller’s direct page.

Shared heavy lifting: **`UnlinkActor`** (single slot) and **`DieNow_UnlinkChildren`** / **`loc_00A60E`** (when spawner flag **`$12` bit `$0040`** — marked children from **`$A1`–`$A4`**).

## Shared state

| Symbol / address | Role |
|------------------|------|
| `UnlinkActor` | Patch `$04`/`$06`, update `$0056`/`$0058`, `ReturnActorSlot` |
| `$04` / `$06` | Previous / next actor DP links |
| `$12` bit `$0040` | Parent has marked children → cascade path |
| `$7F001C,X` | `parentId` — cascade walk matches dying actor ID |
| `$0056` / `$0058` | List head / tail during batch unlink |

## Family notes

- **`$E0` vs `$A7`:** Cutscene one-shots and NPC despawn almost always **`Die`**. Boss pieces that must finish an anim frame or explosion beat use **`MarkDeath`**.
- **`$0040` cascade:** Both **`MarkDeath`** and **`Die`** branch to **`loc_00A60E`** when the **dying** actor’s `$12` has bit `$0040`, unlinking contiguous children whose **`parentId`** matches.
- After **`Die`**, the current actor script **does not resume** (copdef **`halt: true`**).
- **`KillPrev` / `KillNext`** only target **immediate** `$04` / `$06` neighbors — not arbitrary actor IDs.

## Usage statistics

| Op | Name | Uses | Params | Handler | Outcome |
|----|------|-----:|--------|---------|---------|
| `A7` | `MarkDeath` | 7 | (none) | `MarkDeath` | Continue* |
| `A8` | `KillPrev` | 17 | (none) | `KillPrev` | Continue |
| `A9` | `KillNext` | 75 | (none) | `KillNext` | Continue |
| `E0` | `Die` | 665 | (none) | `Die` | Exit actor |

**Family call-site total:** 764

\* **`MarkDeath`:** Script **`RTI`** may continue after the opcode (including **`MarkDeathResumeHandler`** after child cascade). Actor slot is unlinked via **`UnlinkActor`** / cascade path; callers that **`TCD`** into another slot before **`MarkDeath`** (inventory) restore their own DP afterward. Engine docs describe scheduling as **after the next `RTL`** when finishing the current tick cleanly — prefer **`MarkDeath`** over **`Die`** when the frame must complete.

## Opcodes

#### COP [A7] — `MarkDeath` (unlink with optional child cascade)

- **Preferred name:** `MarkDeath`
- **Handler:** `MarkDeath` @ [`cop_handlers_lifecycle.asm:363-374`](../../../extracted/system/engine/cop_handlers_lifecycle.asm)
- **Resume helper:** `MarkDeathResumeHandler` @ [`cop_handlers_lifecycle.asm:381-388`](../../../extracted/system/engine/cop_handlers_lifecycle.asm)
- **Parameters:** (none)
- **Usage count:** 7

##### What it does (exact semantics)

With **X** = current actor (direct page):

1. **`PHD`** — save spawner DP for cascade path.
2. If **`$12 & $0040`**: push **`MarkDeathResumeHandler−1`**, **`BRA loc_00A60E`** — walk list, free marked children by **`parentId`**, repair head/tail, then **`RTS`** into resume handler → **`RTI`** (script PC unchanged at `$0A`).
3. Else **`JSR UnlinkActor`** — remove **this** actor from the list and recycle the slot (same helper as immediate death).

```asm
MarkDeath {
    TYX
    PHD
    LDA $12
    BIT #$0040
    BEQ loc_00A5EC
    PEA $&MarkDeathResumeHandler-1
    BRA loc_00A60E

  loc_00A5EC:
    JSR $&actor_pool.UnlinkActor
}

MarkDeathResumeHandler {
    PLA
    TAX
    TCD
    LDA $0A
    STA $02, S
    RTI
}
```

Child cascade core (shared with **`Die`**) begins at **`loc_00A60E`** in **`DieNow_UnlinkChildren`**: backward/forward scans on **`$04`/`$06`**, **`ReturnActorSlot`** for matching **`parentId`**, then pointer repair (head / tail / mid-splice cases). See **`docs/code/bank00/actor-management.md`** (`DieNow_UnlinkChildren`).

##### How it is used in source

**Inventory item arrange** — switch DP to the source cursor actor, kill it, restore menu actor:

```asm
; extracted/system/inventory/inventory_menu.asm
PHX
PHD
LDA $2C
TAX
TCD
COP [MarkDeath]
PLD
PLX
JMP $&code_02E544
```

**Gold cap / multi-body boss** — tear down auxiliary slots while keeping director script on another actor:

```asm
; extracted/angkor_wat/awB1_goldcap.asm
PHD
TCD
TAX
COP [MarkDeath]
; ... restore other actor context ...
```

**Attack system** — drop guided projectile without halting the attack actor (`KillSpawnedProjectile` in bank `$02` docs).

##### Parameters & contract

| Item | Value |
|------|-------|
| Opcode | `$A7` (copdef id 167) |
| Asm form | `COP [MarkDeath]` |
| Operand size | 0 |
| `$0040` set | Cascade children, then **`MarkDeathResumeHandler`** → Continue |
| `$0040` clear | **`UnlinkActor`** on current actor |
| vs **`Die`** | Does not use copdef **`halt`**; used when tick/frame must complete or caller swaps DP |
| Pairs with | **`$A1`–`$A4`** marked spawns |

---

#### COP [A8] — `KillPrev` (unlink previous neighbor)

- **Preferred name:** `KillPrev`
- **Handler:** `KillPrev` @ [`cop_handlers_lifecycle.asm:507-519`](../../../extracted/system/engine/cop_handlers_lifecycle.asm)
- **Parameters:** (none)
- **Usage count:** 17

##### What it does

1. Load **`$04`** (previous actor DP id).
2. **`TCD` / `TAX`** — context switch to that actor.
3. **`JSR UnlinkActor`** — remove it from the list.
4. Restore saved DP (**`PLA` / `TCD` / `TAX`**), patch COP return PC, **`RTI`**.

Caller script **continues**; only the **`$04`** neighbor is destroyed.

```asm
KillPrev {
    PHY
    LDA $04
    TCD
    TAX
    JSR $&actor_pool.UnlinkActor
    PLA
    TCD
    TAX
    LDA $0A
    STA $02, S
    RTI
}
```

##### How it is used in source

Zombie boss tears down **`SpawnBeforeMarked`** pieces (they sit in **`$04`** relative to the body):

```asm
; extracted/angkor_wat/awB0_zombie.asm
COP [KillPrev]
COP [KillPrev]
COP [KillPrev]
```

Use when the target was spawned **`SpawnBefore`** / **`SpawnBeforeMarked`** so it is the immediate predecessor in the execution chain.

##### Parameters & contract

| Item | Value |
|------|-------|
| Opcode | `$A8` |
| Target | Actor at **`$04`**, not arbitrary ID |
| Outcome | Continue |
| Risk | **`$04` = 0`** → **`TCD` #0** / undefined behavior; scripts must guarantee a prev link |

---

#### COP [A9] — `KillNext` (unlink next neighbor)

- **Preferred name:** `KillNext`
- **Handler:** `KillNext` @ [`cop_handlers_lifecycle.asm:524-536`](../../../extracted/system/engine/cop_handlers_lifecycle.asm)
- **Parameters:** (none)
- **Usage count:** 75

##### What it does

Same pattern as **`KillPrev`**, but follows **`$06`** (next actor).

```asm
KillNext {
    PHY
    LDA $06
    TCD
    TAX
    JSR $&actor_pool.UnlinkActor
    PLA
    TCD
    TAX
    LDA $0A
    STA $02, S
    RTI
}
```

##### How it is used in source

**Marked after-spawns** and UI cursors (second arrange cursor):

```asm
; extracted/babel_tower/comet_lair/sE8_dark_gaia.asm
COP [KillNext]

; extracted/system/inventory/inventory_menu.asm
ArrangeCancelTarget {
    COP [KillNext]
}

; extracted/angkor_wat/awB1_gorgon.asm — repeated teardown of trailing segments
COP [KillNext]
```

Pairs naturally with **`SpawnAfterMarked`** / **`SpawnAfter`** children linked at **`$06`**.

##### Parameters & contract

| Item | Value |
|------|-------|
| Opcode | `$A9` |
| Target | Actor at **`$06`** |
| Outcome | Continue |

---

#### COP [E0] — `Die` (immediate death, script halt)

- **Preferred name:** `Die`
- **Handler:** `Die` @ [`cop_handlers_lifecycle.asm:393-404`](../../../extracted/system/engine/cop_handlers_lifecycle.asm)
- **Parameters:** (none)
- **Usage count:** 665

##### What it does (exact semantics)

1. **`PHD`**, test **`$12 & $0040`**.
2. If set: **`PEA DieNow_UnlinkChildren−1`**, **`BRA loc_00A60E`** — cascade-free children, then fall through to **`DieNow_UnlinkChildren`** entry which **`RTL`** (ends actor tick / script).
3. Else: **`JSR UnlinkActor`**, then fall into shared exit that **`RTL`**.

copdef marks **`halt: true`** — after **`Die`**, execution does not resume at the next script byte on a later frame.

```asm
Die {
    TYX
    PHD
    LDA $12
    BIT #$0040
    BEQ loc_00A605
    PEA $&DieNow_UnlinkChildren-1
    BRA loc_00A60E

  loc_00A605:
    JSR $&actor_pool.UnlinkActor
}

DieNow_UnlinkChildren {
    PLA
    TAX
    TCD
    PLA
    PLA
    RTL
    ; loc_00A60E: child batch unlink ...
}
```

##### How it is used in source

**Default despawn** — intro actors, defeated enemies, cutscene extras, flag-gated one-shots:

```asm
; extracted/system/title_screen/sFC_title_intro.asm
TitlePaletteFadeStep {
    COP [PaletteStart] ( #2D )
    COP [PaletteStep]
    COP [Die]
}
```

**Branch-gated lifetime**:

```asm
COP [BranchOnFlagByte] ( #8D, #00, &done )
; ... alive logic ...
done:
    COP [Die]
```

**Standard enemy defeat** (`StandardEnemyDefeatHandler.asm`) — flash FX, drops, then **`Die`**.

Dark Gaia / boss scripts interleave **`Die`** on phase segments after **`SpawnListAppend`** helpers complete.

##### Parameters & contract

| Item | Value |
|------|-------|
| Opcode | `$E0` (copdef id 224) |
| Asm form | `COP [Die]` |
| Operand size | 0 |
| Outcome | **Exit actor** — slot freed, script halted |
| `$0040` set | Children with matching **`parentId`** removed first |
| vs **`MarkDeath`** | Immediate halt; no **`MarkDeathResumeHandler`** continue path |
| Typical pairing | Scene actors spawned with **`$9C`/`$A0`/`$A5`** without marked children |

##### Relation to spawn family

| Spawn op | Death teardown |
|----------|----------------|
| **`$A1`–`$A4`** marked | Prefer **`$E0`/`$A7`** on parent (cascade) or **`$A8`/`$A9`** on known neighbor |
| **`$A5`/`$A6`** tail append | Usually **`$E0`** on helper; parent uses **`$A9`** if helper is **`$06`** |
| **`$99`–`$A0`** unmarked | **`$E0`** on self; neighbors unaffected |
