# Bank $00 — COP Bytecode Dispatch Engine

**Address range:** `$00846C`–`$00864D`  
**Source files:** `extracted/system/engine/cop_dispatch.asm`, `extracted/system/engine/system_core.asm`  
**Related:** [`cop-commands-reference.md`](../../cop-commands-reference.md), [`chunk_008000-analysis.md`](../chunk_008000-analysis.md)

This document covers the native-mode COP (`$02`) dispatch machinery at the heart of IOG's actor and thinker scripting system. Every script instruction — movement, collision, spawning, dialogue, palette, DMA — routes through this 24-byte dispatcher and its associated jump tables.

---

## Overview

| Component | Address | Old ASM Label | New Name | Size |
|-----------|---------|---------------|----------|------|
| WRAM fill constant | `$00846C` | `byte_00846C` | **wram_fill_constant** | 1 byte |
| Dispatch entry | `$00846D` | `CopDispatch` | **CopDispatch** | 24 bytes |
| Primary jump table | `$008485` | `code_list_008485` | **cop_dispatch_table** | 220 bytes (110 entries) |
| Invalid gap | `$008561` | — | *(no handler)* | 36 bytes (18 entries) |
| Extended jump table | `$008585` | — | **cop_dispatch_table** (cont.) | 198 bytes (99 entries) |
| Table sentinel | `$00864B` | `byte_00864B` | **cop_table_sentinel** | 3 bytes |

The SNES native COP vector at `$FFE4` (mapped through bank `$00`) points here via `CopVector`:

```24:26:extracted/system/engine/system_core.asm
CopVector {
    JML $@CopDispatch
}
```

---

## Entry State (All COP Handlers)

When control reaches a handler, the dispatcher guarantees this machine state:

| Register / Location | Value | Notes |
|---------------------|-------|-------|
| `m` | 0 | 16-bit accumulator |
| `x` | 0 | 16-bit index registers |
| `i` | 1 | 8-bit stack operations |
| `D` | Actor DP base | `$0000` + (ActorID × `$80`) |
| `DBR` | `$81` | Script/data bank for actor bytecode |
| `X` | Actor ID | Same value as `D` offset index |
| `Y` | Actor ID | Saved by `TXY` at dispatch entry; restored by some handlers |
| `$0A` | Arg pointer | Points to **first argument byte** (opcode byte already consumed) |
| `$0C` | Script bank | Return bank byte from stack frame `$04,S` |
| `$02,S` | Return PC | Points **past** the COP instruction and its inline operands |
| `A` | Clobbered | Contains `(opcode & $FF) × 2` at dispatch; handlers reuse freely |
| Flags | Clobbered | Not preserved across dispatch |

**Stack frame layout** (native mode, after COP fires):

| Offset | Contents |
|--------|----------|
| `$04,S` | Return bank (script bank byte) |
| `$02,S` | Return address (16-bit, in return bank) |
| `$01,S` | Return address high / PBR (native mode return) |

The dispatcher computes `$0A` as `$02,S − 1`, so it points at the COP opcode byte, reads it, increments past it, then jumps to the handler. Handlers read further operands via `[ $0A ]` with post-increment.

---

## Handler Exit Conventions

All 172 valid handlers ($00–$6D, $80–$E2) exit through one of four patterns:

| Exit Type | Implementation | Effect |
|-----------|----------------|--------|
| **Continue** | `LDA $0A` → `STA $02,S` → `RTI` | Resume at updated arg pointer; fall through to next COP |
| **Branch** | `LDA [$0A]` (or offset variant) → `STA $02,S` → `RTI` | Jump to `&Code` address in current script bank |
| **Halt / Yield** | Store `$0A` → `$00` (and sometimes `$08`); `PLA; PLA; RTL` | Return to actor engine; script resumes next frame from saved `$00` |
| **Kill** | Unlink actor from list; `RTL` / `RTS` | Actor removed; used by `$E0` (Die) and spawn cleanup |

**Branch operand encoding:** Conditional branch COPs embed a single `&Code` word. Taken → that address becomes the new `$02,S`. Not taken → skip the word and continue. There is no second "else" operand — fallthrough is implicit.

**Halt/yield detail:** The engine saves `$0A` into the actor's `$00` (EntryPtr low) before returning, so the same COP re-executes until its wait condition clears (animation frame, button press, DMA completion, etc.).

---

## Opcode Table Structure

The dispatch table is a single contiguous word array indexed by `(opcode × 2)`:

```
JMP ($&cop_dispatch_table, X)    ; X = opcode × 2
```

### Layout

| Region | Address Range | Opcodes | Entries | Status |
|--------|---------------|---------|---------|--------|
| Primary table | `$008485`–`$008560` | `$00`–`$6D` | 110 | Valid handlers |
| Invalid gap | `$008561`–`$008584` | `$6E`–`$7F` | 18 | All `#$0000` — crash if reached |
| Extended table | `$008585`–`$00864A` | `$80`–`$E2` | 99 | Valid handlers |
| Sentinel | `$00864B`–`$00864D` | `$E3`+ | 1.5 | `NOP; BRA` infinite loop |

**Why `$80` works without a separate table:** Opcode `$80` × 2 = `$0100`. Added to table base `$8485`, the index wraps/lands at `$8585` — exactly where the extended entries begin. Opcodes `$6E`–`7F` fall into the `#$0000` gap and will jump to address `$0000` if ever executed.

### Primary Table ($00–$6D)

| Op | Handler | Op | Handler | Op | Handler | Op | Handler |
|----|---------|----|---------|----|---------|----|---------|
| `$00` | GenHdmaSine | `$1C` | BranchIfTypeSouth | `$38` | PaletteStartLoop | `$54` | SetScratchPointer |
| `$01` | QueueHdma | `$1D` | BranchIfTypeWest | `$39` | PaletteStep | `$55` | ResetSpriteState |
| `$02` | QueueDma | `$1E` | BranchIfTypeEast | `$3A` | PaletteStepLoop | `$56` | AdvanceSpriteAnim |
| `$03` | QueueHdmaChannel | `$1F` | BranchIfNotOnGridline | `$3B` | SpawnThinkerParam | `$57` | SetDeathCallback |
| `$04` | StartMusic | `$20` | BranchIfActorNear | `$3C` | SpawnThinker | `$58` | SetHitCallback |
| `$05` | FadeThenStartMusic | `$21` | BranchIfPlayerNear | `$3D` | KillThinker | `$59` | SetDodgeCallback |
| `$06` | PlaySoundCh2 | `$22` | MoveToward | `$3E` | WaitForButton | `$5A` | SetCollideCallback |
| `$07` | PlaySoundCh1 | `$23` | RngByte | `$3F` | WaitForRelease | `$5B` | OrExtraFlags |
| `$08` | PlaySoundBoth | `$24` | RngMod | `$40` | BranchIfPressed | `$5C` | AndExtraFlags |
| `$09` | WriteApuIo1 | `$25` | SetTilePos | `$41` | BranchIfNotPressed | `$5D` | BranchIfBehindWall |
| `$0A` | WriteApuIo0 | `$26` | QueueMapChange | `$42` | SetCollisionAbs | `$5E` | SetCustomCallback |
| `$0B` | MarkSolidHere | `$27` | WaitWhileOffscreen | `$43` | SnapToGrid | `$5F` | InitSineHdma |
| `$0C` | ClearSolidHere | `$28` | BranchIfPlayerAt | `$44` | BranchIfPlayerInRelTiles | `$60` | TickSineHdma |
| `$0D` | MarkSolidOffset | `$29` | BranchIfActorAt | `$45` | BranchIfPlayerInAbsTiles | `$61` | BindSineHdma |
| `$0E` | ClearSolidOffset | `$2A` | BranchOnPlayerX | `$46` | CopyPosToPrev | `$62` | BranchIfCollisionTypeNe |
| `$0F` | MarkSolidAbs | `$2B` | BranchOnPlayerY | `$47` | CopyPosToNext | `$63` | InitGravity |
| `$10` | ClearSolidAbs | `$2C` | BranchNearerAxis | `$48` | GetPlayerFacing | `$64` | TickGravity |
| `$11` | ClearCollisionHere | `$2D` | DirToPlayer | `$49` | BranchIfBodyNe | `$65` | StageWorldMapMove |
| `$12` | ClearTypeAbs | `$2E` | DirToPlayerFrom | `$4A` | ResumeAfterSnap | `$66` | StageWorldMapChoice |
| `$13` | BranchIfSolidHere | `$2F` | BranchIfDirToPlayer | `$4B` | DrawMetatileAbs | `$67` | StageWorldMapMoveIds |
| `$14` | BranchIfSolidOffset | `$30` | BranchIfDirToPlayerFrom | `$4C` | DrawMetatileHere | `$68` | BranchIfOffCamera |
| `$15` | BranchIfSolidNorth | `$31` | BranchOnPlayerFacing | `$4D` | WorldMapStream3 | `$69` | HaltIfMaxFrames |
| `$16` | BranchIfSolidSouth | `$32` | StageBgChange | `$4E` | WorldMapStream4 | `$6A` | SetLinkedEntryPtr |
| `$17` | BranchIfSolidWest | `$33` | ApplyBgChange | `$4F` | AdhocVramDma | `$6B` | PrintWideStringAlt |
| `$18` | BranchIfSolidEast | `$34` | StageBgChangeFromDeathIdx | `$50` | CopyPalette | `$6C` | InitSpiral |
| `$19` | MusicAndText | `$35` | CardinalToPlayer | `$51` | Decompress | `$6D` | SpiralStep |
| `$1A` | BranchIfTypeHere | `$36` | PaletteRestart | `$52` | StageMove | | |
| `$1B` | BranchIfTypeNorth | `$37` | PaletteStart | `$53` | TickMove | | |

### Invalid Gap ($6E–$7F)

18 consecutive `#$0000` words. These opcodes are listed as phantom entries in `us/copdef.json` but have no handlers. Dispatching any of them performs `JMP ($0000)` — an immediate crash.

### Extended Table ($80–$E2)

| Op | Handler | Op | Handler | Op | Handler | Op | Handler |
|----|---------|----|---------|----|---------|----|---------|
| `$80` | StageSpr | `$A0` | SpawnAfterAbsFlags | `$C0` | SetInteractHandler | `$E0` | Die |
| `$81` | StageSprX | `$A1` | SpawnBeforeMarked | `$C1` | SetEntryHere | `$E1` | ReturnWithSignal |
| `$82` | StageSprY | `$A2` | SpawnAfterMarked | `$C2` | SetEntryHereAndYield | `$E2` | SetEntryFar |
| `$83` | StageSprXY | `$A3` | SpawnAfterAbsMarked | `$C3` | JumpAfterDelay | | |
| `$84` | StageSprLoop | `$A4` | SpawnAfterOffsetMarked | `$C4` | JumpNextFrame | | |
| `$85` | StageSprLoopX | `$A5` | SpawnListAppend | `$C5` | RestoreSavedPtr | | |
| `$86` | StageSprLoopY | `$A6` | SpawnListAppendSpr | `$C6` | SetSavedPtr | | |
| `$87` | StageSprLoopXY | `$A7` | MarkDeath | `$C7` | JumpFar | | |
| `$88` | SetMetasprite | `$A8` | KillPrev | `$C8` | CallNear | | |
| `$89` | AnimOnce | `$A9` | KillNext | `$C9` | CallNearDeferred | | |
| `$8A` | AnimLoop | `$AA` | StageMoveX | `$CA` | LoopStart | | |
| `$8B` | AnimOneFrame | `$AB` | StageMoveY | `$CB` | LoopEnd | | |
| `$8C` | WaitForAnimFrame | `$AC` | StageMoveXY | `$CC` | SetFlagByte | | |
| `$8D` | StageSprAndHitbox | `$AD` | ForceDirSW | `$CD` | SetFlagWord | | |
| `$8E` | SetPlayerSpriteDirect | `$AE` | ForceDirNE | `$CE` | ClearFlagByte | | |
| `$8F` | StagePlayerSpr | `$AF` | ForceDirBoth | `$CF` | ClearFlagWord | | |
| `$90` | StagePlayerSprX | `$B0` | ApplyMoveToChild | `$D0` | BranchOnFlagByte | | |
| `$91` | StagePlayerSprY | `$B1` | ReloadMoveDurations | `$D1` | BranchOnFlagWord | | |
| `$92` | StagePlayerSprXY | `$B2` | SetPriorityMax | `$D2` | WaitOnFlagByte | | |
| `$93` | RunPlayerAnim | `$B3` | SetPriorityMin | `$D3` | WaitOnFlagWord | | |
| `$94` | StagePlayerSprWall | `$B4` | ClearPriorityMax | `$D4` | GiveItem | | |
| `$95` | StagePlayerSprFromDP | `$B5` | ClearPriorityMin | `$D5` | RemoveItem | | |
| `$96` | WallAnimHere | `$B6` | SetOamPriority | `$D6` | BranchIfMissingItem | | |
| `$97` | WallAnimNorth | `$B7` | SetOamPalette | `$D7` | BranchIfItemEquipped | | |
| `$98` | WallAnimSouth | `$B8` | ToggleHMirror | `$D8` | SetDungeonKillFlag | | |
| `$99` | SpawnBefore | `$B9` | ToggleVMirror | `$D9` | SwitchCase | | |
| `$9A` | SpawnBeforeFlags | `$BA` | ClearHMirror | `$DA` | WaitByte | | |
| `$9B` | SpawnAfter | `$BB` | SetHMirror | `$DB` | WaitWord | | |
| `$9C` | SpawnAfterFlags | `$BC` | NudgePosition | `$DC` | CameraPanDown | | |
| `$9D` | SpawnAfterOffset | `$BD` | RunBg3Script | `$DD` | CameraPanUp | | |
| `$9E` | SpawnAfterOffsetFlags | `$BE` | DialogueOptions | `$DE` | CameraPanRight | | |
| `$9F` | SpawnAfterAbs | `$BF` | PrintWideString | `$DF` | CameraPanLeft | | |

Full per-opcode parameter documentation: [`cop-commands-reference.md`](../../cop-commands-reference.md).

---

### wram_fill_constant

| Property | Value |
|----------|-------|
| **Old name** | `byte_00846C` |
| **New name** | `wram_fill_constant` |
| **Address** | `$00846C` |
| **Size** | 1 byte |
| **Value** | `$E0` |

#### Description

A single data byte holding the fill value `$E0`. Referenced exclusively by the unreferenced `FillWramBlock` routine at `$008438`, which DMA-fills 512 bytes at WRAM `$000422` with this constant. No live code path calls `FillWramBlock` — it appears to be a debug or cut feature.

#### Cross-References

| Symbol | Relationship |
|--------|--------------|
| `FillWramBlock` ($008438) | Loads `^wram_fill_constant` into `$A1B0`, `&wram_fill_constant` into `$A1T0L` for DMA source |

---

### CopDispatch

| Property | Value |
|----------|-------|
| **Old name** | `CopDispatch` |
| **New name** | `CopDispatch` |
| **Address** | `$00846D` |
| **Size** | 24 bytes |
| **Type** | Code (interrupt dispatch) |

#### Description

Central dispatch engine for the COP bytecode instruction set. Every actor and thinker script instruction routes through this 24-byte routine. It is reached via the native COP vector (`CopVector` → `JML $00846D`) whenever a script executes a `$02` COP instruction in native mode.

The routine is deliberately minimal: it extracts execution context from the native-mode stack frame, reads the opcode byte, and indirect-jumps through the dispatch table. All semantic work is delegated to individual handlers.

#### Algorithm

```
1. REP #$20              ; 16-bit accumulator
2. TXY                   ; Y ← Actor ID (preserve for handlers)
3. LDA $04,S → STA $0C   ; Script return bank
4. LDA $02,S; DEC → $0A   ; ArgPtr ← address of COP opcode byte
5. LDA [$0A]; INC $0A     ; Read opcode; advance past it
6. AND #$00FF             ; Mask to low byte
7. ASL; TAX               ; X ← opcode × 2 (table index)
8. JMP ($&cop_dispatch_table, X)
```

#### Source

```9:23:extracted/system/engine/cop_dispatch.asm
CopDispatch {
    REP #$20
    TXY 
    LDA $04, S
    STA $0C
    LDA $02, S
    DEC 
    STA $0A
    LDA [$0A]
    INC $0A
    AND #$00FF
    ASL 
    TAX 
    JMP ($&cop_dispatch_table, X)
}
```

#### Variables

| Location | Role |
|----------|------|
| `$0A` | Argument pointer (output) — first operand byte |
| `$0C` | Script bank (output) — from stack `$04,S` |
| `$02,S` | Input — return PC; unchanged until handler writes it |
| `$04,S` | Input — return bank byte |
| `X` | Input — Actor ID at entry; overwritten with table index |
| `Y` | Output — Actor ID preserved from entry |

#### Cross-References

| Symbol | Relationship |
|--------|--------------|
| `CopVector` ($008404) | `JML $@CopDispatch` — hardware entry |
| `cop_dispatch_table` ($008485) | Indirect jump target |
| All COP handlers | Callees via jump table |
| `run_actors_03CAF5` (Bank $03) | Top-level actor executor that triggers COP entrancy |

---

### cop_dispatch_table

| Property | Value |
|----------|-------|
| **Old name** | `code_list_008485` |
| **New name** | `cop_dispatch_table` |
| **Address** | `$008485`–`$00864A` |
| **Size** | 454 bytes (227 words) |
| **Type** | Code reference table |

#### Description

Primary and extended COP dispatch jump tables. Each entry is a 16-bit same-bank (`$&`) address of a handler routine. The table is indexed by `(opcode × 2)` from `CopDispatch`.

The table spans three logical regions concatenated in ROM:

1. **Primary** ($008485): 110 entries for opcodes `$00`–`$6D`
2. **Gap** ($008561): 18 `#$0000` entries for opcodes `$6E`–`$7F`
3. **Extended** ($008585): 99 entries for opcodes `$80`–`$E2`

The contiguous layout exploits address arithmetic: opcode `$80` indexes to `$8585` automatically, avoiding a second dispatch path.

#### Table Entry Format

| Field | Size | Content |
|-------|------|---------|
| Offset | 2 bytes | `$&HandlerLabel` — handler address within Bank $00 |

Invalid entries contain `#$0000`, causing a jump to `$0000` if dispatched.

#### Cross-References

| Symbol | Relationship |
|--------|--------------|
| `CopDispatch` | Indexer — `JMP ($&cop_dispatch_table, X)` |
| 209 handler routines | Targets across `cop_handlers_collision.asm`, `cop_handlers_actors.asm`, `cop_handlers_script.asm` |
| `us/copdef.json` | Declarative opcode metadata (names, operand types) |

---

### cop_table_sentinel

| Property | Value |
|----------|-------|
| **Old name** | `byte_00864B` / `cop_table_sentinel` |
| **New name** | `cop_table_sentinel` |
| **Address** | `$00864B` |
| **Size** | 3 bytes |
| **Raw bytes** | `$EA $80 $FD` (NOP; BRA −2) |

#### Description

Infinite loop sentinel immediately following the last valid table entry (opcode `$E2`). If execution ever reaches `$00864B` — whether by dispatching opcode `$E3+` or jumping past the table — the CPU spins in `NOP; BRA cop_table_sentinel` rather than running off into undefined memory.

This is padding/guard code, not a callable handler.

#### Cross-References

| Symbol | Relationship |
|--------|--------------|
| `cop_dispatch_table` | Immediately precedes this sentinel |
| `GenHdmaSine` / `$00` handler | First table entry at `$008485` |

---

## Dispatch Flow Diagram

```
  COP $02 in script
        │
        ▼
  CopVector (HW vector)
        │
        ▼
  CopDispatch ($846D)
    ├─ Save ActorID → Y
    ├─ $0C ← return bank
    ├─ $0A ← opcode address
    ├─ Read opcode; advance $0A
    └─ JMP table[opcode]
        │
        ▼
  Handler ($00–$6D or $80–$E2)
    ├─ Continue → RTI
    ├─ Branch   → RTI (new PC)
    ├─ Halt     → RTL (yield)
    └─ Kill     → RTL (unlink)
        │
        ▼
  Actor engine (Bank $03)
```

---

## See Also

- [`cop-commands-reference.md`](../../cop-commands-reference.md) — Full handler catalog with operands
- [`utility-math-movement.md`](utility-math-movement.md) — Movement helpers called by `$22`/`$52`/`$53`
- [`utility-tiles-animation.md`](utility-tiles-animation.md) — Tile/animation helpers called by `$4B`–`4E`, `$80`–`92`
