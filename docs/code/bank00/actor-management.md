# Bank $00 — Actor Allocation & Lifecycle Management

**Bank:** `$00` (mirrored at `$80` for FastROM access)  
**Address range:** `$00A608`–`$00B519` (death cleanup, unlink, allocators, pool, palette helper)  
**ASM files:** `extracted/system/engine/actor_pool.asm`, `cop_handlers_lifecycle.asm`, `cop_handlers_movement.asm` (partial)

This page documents how Illusion of Gaia **allocates**, **links**, **copies state between**, and **recycles** actor slots in the doubly-linked actor list. The actor pool, predecessor/successor pointers, and parent-child marking (`$7F001C`) underpin every spawn, death, and thinker COP in the engine.

**Related:** [`direction-collision.md`](direction-collision.md), [`event-flags.md`](event-flags.md), [`readme.md`](readme.md), [`../../cop/index.md`](../../cop/index.md)

---

## Overview

| Category | Functions | Address Span | Approx. Size |
|----------|-----------|--------------|--------------|
| Death / unlink | 2 | `$00A608`–`$00AF73` | ~193 bytes |
| Actor index resolve | 1 | `$00B125`–`$00B13C` | 17 bytes |
| Spawn / allocate | 5 | `$00B15D`–`00B29D`, `$00B501` | ~250 bytes |
| State copy / mark | 2 | `$00B1CB`–`$00B279` | ~176 bytes |
| Pool / cleanup | 2 | `$00B501`–`$00B519` | ~31 bytes |
| **Total (this document)** | **11** | | **~667 bytes** |

### Actor List Model

```
$0056 ──→ [Actor A] ←→ [Actor B] ←→ [Actor C] ←── $0058
              ↑ $04/$06 doubly-linked          ↑
              └── $7F001C = parent DP (marked children)

Free pool: ($4E) stack — IDs pushed on death, popped on alloc
$0DBC — active actor count
$005C — thinker list head (special actors via AllocateSpecialActor)
```

Each actor occupies a **64-byte direct-page-aligned slot**; the slot index (e.g. `$1FC0`) serves as the actor ID returned in **Y**.

---

## Death & Unlink

### UnlinkActor

**Address:** `$AF40` · **Size:** 79 bytes

#### Description

Removes the **current actor** (direct page in **X**) from the **doubly-linked actor list** and returns its slot to the free pool via `ReturnActorSlot`. Handles four topology cases: head-of-before-list, head-of-after-list, middle node, and solo node.

#### Algorithm

| Step | Operation | Detail |
|------|-----------|--------|
| 1 | `LDY $0004,X` | Load predecessor |
| 2 | **No predecessor** (`Y=0`) | This actor was before-list head → `LDY $0006,X` / `STY $0056`; if successor exists, zero its `$04` |
| 3 | **Has predecessor** | Link pred's `$06` to this actor's `$06`; if no successor, update `$0058` to pred; else patch successor's `$04` |
| 4 | `JSR ReturnActorSlot` | Push ID back onto free pool, decrement count |
| 5 | `RTS` | Caller responsible for halting script / RTI |

#### Variables

| Address | Role |
|---------|------|
| `$0004,X` | Predecessor actor ID (`$04` DP offset) |
| `$0006,X` | Successor actor ID |
| `$0056` | Before-list head pointer |
| `$0058` | After-list head pointer |
| `($4E)` | Free actor ID pool |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | COP `$A7` `MarkDeath` | Deferred death when no marked children |
| Called by | COP `$E0` `Die` | Immediate death when no marked children |
| Called by | COP `$A8` `KillPrev` | Unlinks predecessor |
| Called by | COP `$A9` `KillNext` | Unlinks successor |
| Calls | `ReturnActorSlot` | Recycle slot |

---

### DieNow_UnlinkChildren

**Address:** `$A608` · **Size:** 153 bytes

#### Description

Extended death path when the dying actor has **marked children** — `$0012` bit **`$0040`** set (parent flag). Walks the **entire doubly-linked list** forward and backward, collecting all actors whose **`$7F001C,X`** (parent link) matches the dying actor's ID, then **batch-unlinks** them while repairing list heads.

Entered via **`PEA $&DieNow_UnlinkChildren-1`** from COP `$A7`/`$E0` when the parent bit is set; the pushed address causes a synthetic return into the cleanup routine after `PLD`.

#### Algorithm

| Phase | Operation | Detail |
|-------|-----------|--------|
| **Entry** | `PLA`/`TAX`/`TCD`/`PLA`×2/`RTL` skip | Restore DP; fall through to `loc_00A60E` |
| **Save ID** | `STX $0000` | Dying actor ID |
| **Walk back** | Follow `$0004` chain | Unlink any actor where `$7F001C = dying ID`; stop at list start |
| **Walk forward** | Follow `$0006` chain | Same parent-ID filter |
| **Batch free** | Loop `$0004` → `$0006` | `JSR ReturnActorSlot` for each collected child |
| **Repair heads** | If `$0002=0` | Update `$0056`, zero solo `$04` |
| | If `$0004=0` | Update `$0058`, zero solo `$06` |
| | Else | Patch predecessor/successor `$04`/`$06` links |
| **Return** | Restore caller DP | Return to COP handler via `RTS` |

The routine stores the backward-walk endpoint in **`$0002`** and forward endpoint in **`$0004`** during the scan phase.

#### Variables

| Address | Role |
|---------|------|
| `$0000` | Dying actor ID (saved) |
| `$0002` | Backward-scan link endpoint |
| `$0004` | Forward-scan link endpoint / repair pointer |
| `$0012` bit `$0040` | Parent/marked-child flag (entry condition) |
| `$7F001C,X` | Parent actor DP link on child |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | COP `$A7` `MarkDeath` | When `$12 & $0040` |
| Called by | COP `$E0` `Die` | When `$12 & $0040` |
| Calls | `ReturnActorSlot` | Per-child slot recycle |

---

## Actor Index Resolution

### ResolveActorIndex

**Address:** `$B125` · **Size:** 17 bytes

#### Description

Maps an **8-bit actor list index** (from COP script bytecode) to a **WRAM actor direct-page ID**. Used when scripts refer to actors by sequential spawn order rather than raw DP address.

#### Algorithm

| Step | Operation | Detail |
|------|-----------|--------|
| 1 | `SEP #$20` / `XBA` | Swap to low byte in A |
| 2 | `LDA #$30` | Stride multiplier (48 decimal — actor list entry size) |
| 3 | `JSL $@SignedMultiply` | `index × $30` via hardware multiply (`$0281D1`) |
| 4 | `REP #$20` / `CLC` / `ADC #$1000` | Base `$1000` + offset |
| 5 | `TAY` / `RTS` | Actor ID in Y |

#### Variables

| Address | Role |
|---------|------|
| A (input) | 8-bit actor list index from script |
| Y (output) | Resolved actor direct-page ID (e.g. `$1Fxx`) |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | COP `$20` | `BranchIfActorNear` |
| Called by | COP `$29` | `BranchIfActorAt` |
| Calls | `SignedMultiply` (`$0281D1`) | Hardware `WRMPY` multiply |

---

## Allocation

### AllocateActorBefore

**Address:** `$B15D` · **Size:** 44 bytes

#### Description

Allocates a new actor from the free pool and inserts it **immediately before** the current actor in the doubly-linked list (closer to `$0056` head). Copies full state from the current actor via `CopyActorState`.

#### Algorithm

| Step | Operation | Detail |
|------|-----------|--------|
| 1 | `PHD` / `TCD #$0000` | Zero page for allocator |
| 2 | `JSL ActorPoolAllocator` | New ID in Y; **BCS** → failed alloc, `RTS` |
| 3 | Link | New `$06` = current X; new `$04` = current's `$04`; current's `$04` = new Y |
| 4 | Head update | If new `$04=0`, `STY $0056`; else patch pred's `$06` = new Y |
| 5 | `JSR CopyActorState` | Clone current → new |
| 6 | `PLD` / `RTS` | |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | COP `$99` `SpawnBefore` | |
| Called by | COP `$9A` `SpawnBeforeParam` | |
| Called by | COP `$A1` `SpawnBeforeMarked` | + `MarkChildActor` |
| Calls | `ActorPoolAllocator`, `CopyActorState` | |

---

### AllocateActorAfter

**Address:** `$B189` · **Size:** 44 bytes

#### Description

Allocates and inserts **after** the current actor (toward `$0058` tail). Mirror of `AllocateActorBefore` with `$04`/`$06` roles swapped.

#### Algorithm

| Step | Operation | Detail |
|------|-----------|--------|
| 1 | `JSL ActorPoolAllocator` | On failure, `RTS` with carry |
| 2 | Link | New `$04` = current X; new `$06` = current's `$06`; current's `$06` = new Y |
| 3 | Head update | If new `$06=0`, `STY $0058`; else patch succ's `$04` |
| 4 | `JSR CopyActorState` | |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | COP `$9B`–`$A4` | All spawn-after variants |
| Called by | COP `$04`/`$05` | Music thinkers |
| Called by | COP `$3B`/`$3C` | Thinker spawn (via `AllocateSpecialActor` path) |
| Called by | COP `$19` | List splice |
| Calls | `ActorPoolAllocator`, `CopyActorState` | Highest-volume allocator (~14 call sites) |

---

### AllocateSpecialActor

**Address:** `$B27B` · **Size:** 36 bytes

#### Description

Allocates a **thinker** (special non-sprite actor) via bank `$03` **`ThinkerPoolAlloc`**, then links it into the **thinker list** at **`$005C`** rather than the main actor chain. Zeros the thinker's wait counter and successor pointer.

#### Algorithm

| Step | Operation | Detail |
|------|-----------|--------|
| 1 | `PHD` / `TCD #$0000` | |
| 2 | `JSL ThinkerPoolAlloc` | Thinker allocator; **BCS** → fail |
| 3 | `LDX $005C` | Current thinker list head |
| 4 | Link | New `$04` = old head X; new `$06` = 0; new `$08` = 0; old head's `$06` = new Y |
| 5 | `STY $005C` | New head |
| 6 | `PLD` / `RTS` | |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | COP `$3B` `SpawnThinkerParam` | |
| Called by | COP `$3C` `SpawnThinker` | |
| Calls | `ThinkerPoolAlloc` (`$03CE8F`) | Bank `$03` thinker pool |

---

### ActorPoolAllocator

**Address:** `$B501` · **Size:** 24 bytes

#### Description

Core **free-list pop** for actor slots. Reads the next available actor ID from **`($4E)`**. Negative ID (`BMI`) means **pool exhausted**. On success, clears the pool entry, advances **`$4E` by 2**, increments **`$0DBC`** (active count), returns ID in **A/Y** with **carry clear**.

#### Algorithm

| Step | Operation | Detail |
|------|-----------|--------|
| 1 | `LDA ($4E)` | Peek next free ID |
| 2 | `BMI loc_00B514` | `$FFFF` or negative → exhausted |
| 3 | `TAY` | Save ID |
| 4 | `STA ($4E)` with 0 | Consume entry (mark empty) |
| 5 | `INC $4E` ×2 | Advance pool pointer |
| 6 | `INC $0DBC` | Active count++ |
| 7 | `CLC` / `RTL` | Success — ID in A/Y |
| **Fail** | `LDY #$1FC0` / `SEC` / `RTL` | Sentinel ID, carry set |

#### Variables

| Address | Role |
|---------|------|
| `$4E` | Free pool stack pointer (word index into pool table) |
| `($4E)` | Next free actor ID (word) |
| `$0DBC` | Active actor count |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | `AllocateActorBefore` / `AllocateActorAfter` | Primary consumers |
| Called by | COP `$A5`/`$A6` | Direct spawn |
| Called by | COP `$19` | List append |

---

## Slot Recycle & State Copy

### ReturnActorSlot

**Address:** `$B1B5` · **Size:** 22 bytes

#### Description

Returns an actor slot to the **free pool** — inverse of `ActorPoolAllocator`. Temporarily sets **D=0** for `$4E`/`$0DBC` access.

#### Algorithm

| Step | Operation | Detail |
|------|-----------|--------|
| 1 | `TCD #$0000` | Save caller DP implicitly via prior PHD in unlink paths |
| 2 | `SEP #$20` | |
| 3 | `DEC $4E` ×2 | Retract pool pointer |
| 4 | `DEC $0DBC` | Active count-- |
| 5 | `REP #$20` | |
| 6 | `TXA` / `STA ($4E)` | Store freed actor ID (X = actor being unlinked) |
| 7 | `TCD` / `RTS` | Restore D register from A (caller DP) |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | `UnlinkActor` | Single-actor death |
| Called by | `DieNow_UnlinkChildren` | Batch child cleanup |

---

### MarkChildActor

**Address:** `$B1CB` · **Size:** 15 bytes

#### Description

Records a **parent link** on a newly spawned child actor. Stores the **current actor's direct-page value** into **`$7F001C,X`** of the child (**Y**), but only if the child's parent field is currently zero (does not overwrite existing parent).

#### Algorithm

| Step | Operation | Detail |
|------|-----------|--------|
| 1 | `LDA $7F001C,X` | Check child (Y→X via `TYX`) parent field |
| 2 | `BNE skip` | Already has parent — don't overwrite |
| 3 | `TDC` | Current actor DP → A |
| 4 | `STA $7F001C,X` | Store parent link |
| 5 | `TDC` / `TAX` | Restore caller DP to X |

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | COP `$A1`–`$A4` | Marked spawn variants |

---

### CopyActorState

**Address:** `$B1DA` · **Size:** 161 bytes

#### Description

**Full actor state clone** from current actor (**X**) to target (**Y**). Transfers render/collision flags, position, animation, body/map pointers, and selectively zeroes extended WRAM fields so the child starts with a clean script/wait/interaction state.

#### Copied Fields

| Source (current X) | Destination (target Y) | Transform |
|--------------------|------------------------|-----------|
| `$000E` | `$000E,Y` | Direct copy (OAM XOR flags) |
| `$0010` | `$0010,Y` | `ORA #$2000` / `AND #$F7FC` — set "newly spawned", clear collision bits |
| `$0012` | `$0012,Y` | `AND #$EFFF` — clear interact-enable bit |
| `$0014`/`$0016` | `$0014,Y`/`$0016,Y` | Position |
| `$0028`/`$002A` | `$0028,Y`/`$002A,Y` | Animation state |
| X (self) | `$0024,Y` | Source actor ID reference |
| `$7F0006`/`$7F0008` | `$7F0006,Y`/`$7F0008,Y` | Sprite pointer + bank |
| `$7F000C` | `$7F000C,Y` | Map header pointer |
| `$7F0020` | `$7F0020,Y` | Rearrange index |

#### Zeroed Fields

Always cleared on target:

| Field | Purpose |
|-------|---------|
| `$7F001C` | Parent link (unless later set by `MarkChildActor`) |
| `$002C`/`$002E` | Velocity |
| `$7F002C`/`$7F002E` | Computed velocity |
| `$0008` | Frame wait counter |
| `$7F000A` | Interaction handler pointer |
| `$7F002A` | Extended flags |

If **`$scene_current ≠ $FF`**, also zeroes callback table **`$7F1000`–`$7F101E`** (spawn/halt/interact/death callback slots). Scene `$FF` preserves callbacks — used for special global actors.

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Called by | `AllocateActorBefore` | |
| Called by | `AllocateActorAfter` | |

---

## Palette Thinker Cleanup

### PaletteResetAndKillThinker

**Address:** `$B519` · **Size:** 7 bytes (+ COP bytecode)

#### Description

Inline **COP bytecode stub** used as a thinker cleanup entry point. Emits three COP commands then **`RTL`**:

1. **`PaletteRestart`** — reset palette animation state
2. **`PaletteStep`** — advance one palette frame
3. **`KillThinker`** — remove thinker from `$005C` list

Spawned by music/effect COPs (`$04`/`$05`) as the thinker's exit script when palette cycling completes.

#### Algorithm

```asm
COP [PaletteRestart]
COP [PaletteStep]
COP [KillThinker]
RTL
```

No register setup — relies on thinker COP entrancy state.

#### Cross-References

| Direction | Symbol | Notes |
|-----------|--------|-------|
| Adjacent to | `ActorPoolAllocator` (`$B501`) | Allocator ends where this begins |
| Used by | Music COP `$04`/`$05` | Palette thinker lifecycle |

---

## Quick Reference

| Name | Address | Size | Primary Callers |
|------|---------|------|-----------------|
| `UnlinkActor` | `$AF40` | 79 | COP `$A7`/`$A8`/`$A9`/`$E0` |
| `DieNow_UnlinkChildren` | `$A608` | 153 | COP `$A7`/`$E0` (parent bit) |
| `ResolveActorIndex` | `$B125` | 17 | COP `$20`/`$29` |
| `AllocateActorBefore` | `$B15D` | 44 | COP `$99`/`$9A`/`$A1` |
| `AllocateActorAfter` | `$B189` | 44 | COP `$9B`–`$A4`, `$04`/`$05` |
| `ReturnActorSlot` | `$B1B5` | 22 | Unlink paths |
| `MarkChildActor` | `$B1CB` | 15 | COP `$A1`–`$A4` |
| `CopyActorState` | `$B1DA` | 161 | Both allocators |
| `AllocateSpecialActor` | `$B27B` | 36 | COP `$3B`/`$3C` |
| `ActorPoolAllocator` | `$B501` | 24 | Allocators, COP `$A5`/`$A6`/`$19` |
| `PaletteResetAndKillThinker` | `$B519` | 7 | Music palette thinkers |

---

## Memory Map (Actor Lifecycle)

| Address | Size | Name | Used By |
|---------|------|------|---------|
| `$004E` | 2 | Free pool pointer | `ActorPoolAllocator`, `ReturnActorSlot` |
| `$0056` | 2 | Actor list head (before) | `AllocateActorBefore`, `UnlinkActor` |
| `$0058` | 2 | Actor list head (after) | `AllocateActorAfter`, `UnlinkActor` |
| `$005C` | 2 | Thinker list head | `AllocateSpecialActor` |
| `$0DBC` | 2 | Active actor count | Pool alloc/return |
| `$7F001C,X` | 2 | Parent actor link | `MarkChildActor`, `DieNow_UnlinkChildren` |
| `$scene_current` | 2 | Current scene ID | `CopyActorState` callback zero gate |
