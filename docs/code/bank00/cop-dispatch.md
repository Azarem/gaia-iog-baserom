# Bank $00 — COP Bytecode Dispatch Engine

**Address range:** `$00846C`–`$00864D` (one unreferenced constant byte at `$00846C`, then the dispatcher, the table and a 3-byte trailer)  
**Source files:** `extracted/system/engine/cop_dispatch.asm`, `extracted/system/engine/system_core.asm`  
**Related:** [`../../cop/README.md`](../../cop/README.md), [`system-core.md`](system-core.md)

This document covers the native-mode COP (`$02`) dispatch machinery at the heart of IOG's actor and thinker scripting system. Every script instruction — movement, collision, spawning, dialogue, palette, DMA — routes through this 24-byte dispatcher and its associated jump table.

> This document is based on the **extracted ROM** (`extracted/**/*.asm`, `db-us/copdef.json`, `db-us/names/bank00.json`), not on original developer source comments (the original source is not available). Prose that goes beyond what an instruction shows is marked "inferred".

## Source of truth

| File | Used for |
|------|----------|
| `extracted/system/engine/cop_dispatch.asm` | `CopDispatch` instructions, `cop_dispatch_table` (227 words), `cop_table_sentinel`, the 30 `?INCLUDE 'cop_handlers_*'` lines |
| `extracted/system/engine/system_core.asm` | `CopVector`, `OamFillE0_unused`, `OamFillConstant_unused` |
| `extracted/system/engine/cop_handlers_*.asm` (30 files) | Handler exit patterns (`RTI` vs `PLA; PLA; RTL`), the per-handler register use (`TYX`) |
| `extracted/system/engine/actor_execution.asm`, `thinker_execution.asm` | How actor/thinker runners set `D`/`X` and call script code (the "COP entrancy" assumptions) |
| `db-us/copdef.json` | Opcode ids and names (209 entries) |
| `db-us/names/bank00.json` | Decimal → label addresses used below |

**Naming:** `CopVector`, `CopDispatch`, `cop_dispatch_table`, `cop_table_sentinel`, `OamFillE0_unused`, `OamFillConstant_unused` and every handler label (`GenHdmaSine` … `SetEntryFar`) are extracted labels. The "Old ASM label (historical)" column is carried over from earlier revisions of this document (auto-generated names such as `code_list_008485`); those names are not present in the current extracted source. Opcode category groupings in this document are documentation-only (derived from which `cop_handlers_*` file a handler lives in).

**Counts:** "entries" always means *words in `cop_dispatch_table`*, counted from `cop_dispatch.asm`: 110 + 18 + 99 = **227 words**, of which **209 are valid** (110 + 99) and 18 are `#$0000`.

---

## Overview

| Component | Address | Extracted label | Old ASM label (historical) | Size |
|-----------|---------|-----------------|----------------------------|------|
| Unreferenced fill constant (`$E0`) | `$00846C` | `OamFillConstant_unused` (in `system_core.asm`, not `cop_dispatch.asm`) | `byte_00846C` | 1 byte |
| Dispatch entry | `$00846D` | `CopDispatch` | `CopDispatch` | 24 bytes (instruction-counted) |
| Primary jump table | `$008485` | `cop_dispatch_table` (words 0–109) | `code_list_008485` | 220 bytes (110 entries, opcodes `$00`–`$6D`) |
| Unimplemented gap | `$008561` | `cop_dispatch_table` (words 110–127) | — | 36 bytes (18 `#$0000` entries, opcodes `$6E`–`$7F`) |
| Extended jump table | `$008585` | `cop_dispatch_table` (words 128–226) | — | 198 bytes (99 entries, opcodes `$80`–`$E2`) |
| Table trailer | `$00864B` | `cop_table_sentinel` | `byte_00864B` | 3 bytes (`NOP; BRA`) |

`$00846C` and `$00864B` are the only addresses in this range that the names file pins explicitly besides `CopDispatch` (`$00846D`) and `cop_dispatch_table` (`$008485`); the table-region boundaries (`$008561`, `$008585`) are computed from the entry counts (110 × 2 = 220 = `$DC`; 18 × 2 = 36 = `$24`; 99 × 2 = 198 = `$C6`).

The COP interrupt enters the game through `CopVector` (extracted label at `$008007`, name `CopVector` in `db-us/names/bank00.json`):

```110:112:extracted/system/engine/system_core.asm
CopVector {
    JML $@cop_dispatch.CopDispatch
}
```

(`CopVector` sits in the vector-stub area next to `ResetVector` and `NmiVector`; the hardware COP vector word itself is not part of any extracted `.asm` file, so which stub the cartridge's native COP vector points at is the standard SNES arrangement rather than something this doc can show from source.)

---

## Entry State (All COP Handlers)

State at the first instruction of a handler (the instruction right after `JMP ($&cop_dispatch_table, X)`). Rows are marked **source** (visible in `CopDispatch` or the COP hardware behaviour) or **caller assumption** (set up by the actor/thinker runner before the script was entered; `CopDispatch` does not enforce it).

| Register / Location | Value at handler entry | Basis |
|---------------------|------------------------|-------|
| `m` (accumulator width) | 0 (16-bit) | **source** — `REP #$20` is the first instruction of `CopDispatch` |
| `x` (index width) | 0 (16-bit) | **caller assumption** — `CopDispatch` never changes it, but `TXY`/`TAX`/`JMP (abs,X)` only work as intended with 16-bit index registers. The runners `TAX` slot addresses of `$0F00` and above, which only fits in a 16-bit index register |
| `I` flag | 1 (set) | **hardware** — the native-mode COP interrupt sets I (and clears D); `CopDispatch` doesn't touch P. Other P bits keep their values from the interrupted code |
| `D` (direct page) | Slot address of the running actor/thinker | **caller assumption** — runners do `TCD`/`TAX` with the slot address before calling the script (`actor_execution.asm`, `thinker_execution.asm`). Actor slots are `$30` bytes each starting at `$1000` (`$1000`, `$1030`, …); thinker slots are `$10` bytes each starting at `$0F00`. There is **no** `ID × $80` scaling |
| `X` | **`opcode × 2`** (table index) | **source** — `ASL; TAX` just before the jump. It is **not** the actor slot at this point; every handler that needs the slot starts with `TYX` (e.g. `SetInteractHandler`, `SetEntryHere`, `Die`, `BranchIfPressed`) |
| `Y` | Slot address (same value that `D` has) | **source** — `TXY` as the second instruction of `CopDispatch` (X still held the slot from the runner) |
| `A` | `opcode × 2` | **source** — `TAX` doesn't alter A; handlers overwrite it freely |
| `$0A` (DP, 16-bit) | Pointer to the **first operand byte** (opcode byte already consumed) | **source** — `STA $0A` of `pushedPC − 1`, then `INC $0A` |
| `$0C` | Script bank | **source** — 16-bit `LDA $04,S` / `STA $0C`; `$0D` gets an unrelated stack byte and is unused |
| `$02,S` | Return PC (the byte after the opcode, i.e. the first operand) | **source** — COP pushes PC+2 and the opcode sits at pushed PC − 1 (the COP "signature byte") |
| `DBR` | `$81` by engine convention | **inferred** — `CopDispatch` doesn't set it, and `JMP (abs,X)` takes its table bank from the program bank, not DBR |
| Flags (N, V, Z, C) | Undefined | `AND #$00FF`, `ASL` etc. have disturbed them |

The `X`/`D` rule in the project's patch notes ("X must equal the actor slot before every COP") follows from this: `CopDispatch` copies X into Y and each handler restores it with `TYX`, so the *script code between COPs* must keep X (and D) equal to the slot address.

**Stack frame layout** (native mode, 16-bit `S`, at the first instruction of `CopDispatch`; S points at the next free byte so offsets start at 1):

| Offset | Size | Contents |
|--------|------|----------|
| `$01,S` | 1 | Processor status `P` pushed by the interrupt |
| `$02,S` | 2 | Return address `PC` (little-endian: low at `$02,S`, high at `$03,S`) — address of the byte *after* the COP signature byte |
| `$04,S` | 1 | Program bank `PBR` of the interrupted code (the script bank) |

`CopDispatch` loads `$02,S`, decrements it (`DEC`) to reach the signature byte — which is the handler opcode — and stores the result in `$0A`; it then reads that byte through `[$0A]`, increments `$0A` past it and jumps. Handlers read operands through `[$0A]` with post-increment. Before returning to the script they either write `$0A` into `$02,S` (then `RTI`) or discard the 4-byte frame with `PLA; PLA` (16-bit pops) and `RTL` back to the runner.

---

## Handler Exit Conventions

All **209** valid handlers (`$00`–`$6D`, `$80`–`$E2`) end in one of the patterns below (verified by reading the `cop_handlers_*` files; the handful of exceptions are noted in each handler's block note):

| Exit Type | Implementation | Effect |
|-----------|----------------|--------|
| **Continue** | `LDA $0A` → `STA $02,S` → `RTI` | Resume the script at the updated operand pointer, i.e. the next instruction |
| **Branch** | Taken: `LDA [$0A]` → `STA $02,S` → `RTI` (new PC = the `&Code` operand). Not taken: step `$0A` over the operand word, then as *Continue* | Same-bank jump inside the script bank (`$0C`) |
| **Halt / Yield** | Save the resume pointer (`$0A` → actor `$00`, bank `$0C` → `$02`; some handlers also arm `$08`), then `PLA; PLA; RTL` | Discards the 4-byte COP frame and returns to the actor/thinker runner (`RTL`); the script resumes from `$00/$02` on a later tick |
| **Kill** | `Die` (`$E0`): `TYX`, `PHD`, unlink (directly, or via `DieExit` after a child-cascade), then `PLA; TAX; TCD; PLA; PLA; RTL` | The runner continues past the removed slot |

**Branch operand encoding:** Conditional branch COPs embed a single `&Code` word. Taken → that address becomes the new `$02,S`. Not taken → skip the word and continue. There is no second "else" operand — fallthrough is implicit (e.g. `BranchIfPressed` in `cop_handlers_input.asm`).

**Halt/yield detail — the resume pointer differs per handler:**

- `SetEntryHereAndYield` (`$C2`), `WaitByte`/`WaitWord` (`$DA`/`$DB`, shared tail `WaitStoreAndYield`) store the **next** instruction as the entry pointer; the wait handlers also load the tick count into `$08`.
- `WaitForButton`/`WaitForRelease` (`$3E`/`$3F`) store `$0A − 4` (opcode + operand) into `$00`, so *the same COP re-executes* next frame until the button test passes. This "re-run until the condition clears" pattern is specific to handlers that rewind; it is not applied by the dispatcher itself.
- `JumpAfterDelay`/`JumpNextFrame`/`CallNearDeferred` store a *target* in `$00` instead of the next instruction.

On a yield, the runner sees `RTL` as a return from the script "subroutine" it entered with its `PHK; PEA …-1; RTL` trick (`actor_execution.asm` header, "COP SCRIPT DISPATCH").

---

## Opcode Table Structure

The dispatch table is a single contiguous word array indexed by `(opcode × 2)`:

```
JMP ($&cop_dispatch_table, X)    ; X = opcode × 2
```

### Layout

`cop_dispatch_table` is one **same-bank (bank `$00`) indirect jump table**: `JMP (abs,X)` takes the 16-bit pointer at `table + X` and jumps to it in the current program bank, so every entry is a short (`&`) handler label and every handler must live in bank `$00`.

| Region | Address Range | Opcodes | Entries (words) | Status |
|--------|---------------|---------|-----------------|--------|
| Primary table | `$008485`–`$008560` | `$00`–`$6D` | 110 | Valid handlers |
| Unimplemented gap | `$008561`–`$008584` | `$6E`–`$7F` | 18 | All `#$0000` |
| Extended table | `$008585`–`$00864A` | `$80`–`$E2` | 99 | Valid handlers |
| **Total** | `$008485`–`$00864A` | `$00`–`$E2` | **227** (454 bytes) | **209 valid + 18 `#$0000`** |
| Trailer | `$00864B`–`$00864D` | `$E3`+ would index here | — | `cop_table_sentinel` (`NOP; BRA`), see below |

Arithmetic check: 110 + 18 + 99 = 227 words; 110 + 99 = 209 valid. Opcode ids and handler names in the table match `db-us/copdef.json` (the file header in `cop_dispatch.asm` states the same: "All 209 table ids match db-us/copdef.json ids"). `copdef.json` has 209 entries; the 18 gap opcodes have no copdef entry.

**Why `$80` works without a second table:** there is no second table. The array is contiguous and opcode `$80` simply lands at `table + $80 × 2 = $8485 + $0100 = $8585`, i.e. the first word after the 18-word gap. The gap exists only to keep the opcode → word index mapping linear.

**The gap is "unimplemented", not guarded:** the 18 `#$0000` words (opcodes `$6E`–`$7F`) make `JMP ($&cop_dispatch_table, X)` load the pointer `$0000` and transfer control to `$00:0000`, which is WRAM (RAM executed as code). The source states no script uses them; they are not gameplay behaviour and not a deliberate trap. This doc does not claim the engine treats them specially. `docs/cop/families/invalid_ops.md` covers the opcode-side view.

**Opcodes `$E3`–`$FF`:** the table ends at `$00864A`. Opcode `$E3` indexes `$00864B`, where the 16-bit pointer read comes from the bytes of `cop_table_sentinel` itself (`EA 80` → pointer `$80EA`) rather than from a handler address; higher opcodes read whatever bytes follow. See the sentinel section.

### Primary Table ($00–$6D)

| Op | Handler | Op | Handler | Op | Handler | Op | Handler |
|----|---------|----|---------|----|---------|----|---------|
| `$00` | GenHdmaSine | `$1C` | BranchIfSolidTypeSouth | `$38` | PaletteStartLoop | `$54` | SetScratchPointer |
| `$01` | QueueHdma | `$1D` | BranchIfSolidTypeWest | `$39` | PaletteStep | `$55` | SetTileStreamAnim |
| `$02` | QueueHdmaDirect | `$1E` | BranchIfSolidTypeEast | `$3A` | PaletteStepLoop | `$56` | AdvanceSpriteAnim |
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
| `$0E` | ClearSolidOffset | `$2A` | BranchOnPlayerX | `$46` | CopyPosToPrev | `$62` | BranchIfCollisionTypeEq |
| `$0F` | MarkSolidAbs | `$2B` | BranchOnPlayerY | `$47` | CopyPosToNext | `$63` | InitGravity |
| `$10` | ClearSolidAbs | `$2C` | BranchNearerAxis | `$48` | GetPlayerFacing | `$64` | TickGravity |
| `$11` | ClearCollisionHere | `$2D` | DirToPlayer | `$49` | BranchIfBodyNe | `$65` | StageWorldMapMove |
| `$12` | ClearTypeAbs | `$2E` | DirToPlayerFrom | `$4A` | ResumeAfterSnap | `$66` | StageWorldMapChoice |
| `$13` | BranchIfSolidHere | `$2F` | BranchIfDirToPlayer | `$4B` | DrawMetatileAbs | `$67` | StageWorldMapMoveIds |
| `$14` | BranchIfSolidOffset | `$30` | BranchIfDirToPlayerFrom | `$4C` | DrawMetatileHere | `$68` | BranchIfOffCamera |
| `$15` | BranchIfSolidNorth | `$31` | BranchOnPlayerFacing | `$4D` | DrawMetatileStream | `$69` | HaltIfMaxFrames |
| `$16` | BranchIfSolidSouth | `$32` | StageBgChange | `$4E` | DrawMetatileStreamDelay | `$6A` | SetLinkedEntryPtr |
| `$17` | BranchIfSolidWest | `$33` | ApplyBgChange | `$4F` | AdhocVramDma | `$6B` | PrintDialogStringAlt |
| `$18` | BranchIfSolidEast | `$34` | StageBgChangeFromDeathIdx | `$50` | CopyPalette | `$6C` | InitSpiral |
| `$19` | MusicAndText | `$35` | CardinalToPlayer | `$51` | Decompress | `$6D` | SpiralStep |
| `$1A` | BranchIfSolidType | `$36` | PaletteRestart | `$52` | StageMove | | |
| `$1B` | BranchIfSolidTypeNorth | `$37` | PaletteStart | `$53` | TickMove | | |

### Unimplemented Gap ($6E–$7F)

18 consecutive `#$0000` words (`cop_dispatch.asm`, entries `;6E`–`;7F`). These opcodes have **no** entry in `db-us/copdef.json` (copdef ids run `0`–`226` with exactly 209 entries, none in `110`–`127`) and no handler. The table slot holds the pointer value `$0000`, so dispatching one transfers control to `$00:0000` — undefined behaviour; no extracted script uses them (see [`../../cop/families/invalid_ops.md`](../../cop/families/invalid_ops.md)). They are **not gameplay behaviour**.

### Extended Table ($80–$E2)

| Op | Handler | Op | Handler | Op | Handler | Op | Handler |
|----|---------|----|---------|----|---------|----|---------|
| `$80` | StageSpriteFrame | `$A0` | SpawnAfterAbsFlags | `$C0` | SetInteractHandler | `$E0` | Die |
| `$81` | StageSpriteMoveX | `$A1` | SpawnBeforeMarked | `$C1` | SetEntryHere | `$E1` | ReturnWithSignal |
| `$82` | StageSpriteMoveY | `$A2` | SpawnAfterMarked | `$C2` | SetEntryHereAndYield | `$E2` | SetEntryFar |
| `$83` | StageSpriteMoveXY | `$A3` | SpawnAfterAbsMarked | `$C3` | JumpAfterDelay | | |
| `$84` | StageSpriteLoop | `$A4` | SpawnAfterOffsetMarked | `$C4` | JumpNextFrame | | |
| `$85` | StageSpriteLoopMoveX | `$A5` | SpawnListAppend | `$C5` | RestoreSavedPtr | | |
| `$86` | StageSpriteLoopMoveY | `$A6` | SpawnListAppendSpr | `$C6` | SetSavedPtr | | |
| `$87` | StageSpriteLoopMoveXY | `$A7` | MarkDeath | `$C7` | JumpFar | | |
| `$88` | SetMetasprite | `$A8` | KillPrev | `$C8` | CallNear | | |
| `$89` | AnimOnce | `$A9` | KillNext | `$C9` | CallNearDeferred | | |
| `$8A` | AnimLoop | `$AA` | StageMoveX | `$CA` | LoopStart | | |
| `$8B` | AnimOneFrame | `$AB` | StageMoveY | `$CB` | LoopEnd | | |
| `$8C` | WaitForAnimFrame | `$AC` | StageMoveXY | `$CC` | SetFlagByte | | |
| `$8D` | StageSprAndHitbox | `$AD` | SetMoveNegateX | `$CD` | SetFlagWord | | |
| `$8E` | SetPlayerSpriteDirect | `$AE` | SetMoveNegateY | `$CE` | ClearFlagByte | | |
| `$8F` | StagePlayerSprite | `$AF` | SetMoveNegateXY | `$CF` | ClearFlagWord | | |
| `$90` | StagePlayerMoveX | `$B0` | ApplyMoveToChild | `$D0` | BranchOnFlagByte | | |
| `$91` | StagePlayerMoveY | `$B1` | ReloadMoveChains | `$D1` | BranchOnFlagWord | | |
| `$92` | StagePlayerMoveXY | `$B2` | SetPriorityMax | `$D2` | WaitOnFlagByte | | |
| `$93` | RunPlayerAnim | `$B3` | SetPriorityMin | `$D3` | WaitOnFlagWord | | |
| `$94` | StagePlayerSprWall | `$B4` | ClearPriorityMax | `$D4` | GiveItem | | |
| `$95` | StagePlayerSprFromDP | `$B5` | ClearPriorityMin | `$D5` | RemoveItem | | |
| `$96` | WallAnimHere | `$B6` | SetSpritePriority | `$D6` | BranchIfHasItem | | |
| `$97` | WallAnimNorth | `$B7` | SetSpritePalette | `$D7` | BranchIfItemEquipped | | |
| `$98` | WallAnimSouth | `$B8` | ToggleHMirror | `$D8` | SetDungeonKillFlag | | |
| `$99` | SpawnBefore | `$B9` | ToggleVMirror | `$D9` | SwitchCase | | |
| `$9A` | SpawnBeforeFlags | `$BA` | ClearHMirror | `$DA` | WaitByte | | |
| `$9B` | SpawnAfter | `$BB` | SetHMirror | `$DB` | WaitWord | | |
| `$9C` | SpawnAfterFlags | `$BC` | NudgePosition | `$DC` | CameraPanDown | | |
| `$9D` | SpawnAfterOffset | `$BD` | RunBg3Script | `$DD` | CameraPanUp | | |
| `$9E` | SpawnAfterOffsetFlags | `$BE` | DialogueOptions | `$DE` | CameraPanRight | | |
| `$9F` | SpawnAfterAbs | `$BF` | PrintDialogString | `$DF` | CameraPanLeft | | |

Full per-opcode parameter documentation: [`docs/cop/README.md`](../../cop/README.md).

---

### OamFillConstant_unused (dead — formerly documented as `wram_fill_constant`)

**Address:** `$846C` · **Size:** 1 byte · **Value:** `$E0` · **Defined in:** `extracted/system/engine/system_core.asm` (not `cop_dispatch.asm`) · **Status:** dead data

#### Description

A single data byte holding the fill value `$E0` (sprite Y = 224, just below the 224-line display). Its only reference is `OamFillE0_unused` (`$008438`), a routine with **no caller anywhere in `extracted/`** (`system_core.asm` notes this twice). That routine uses DMA fixed-source mode to fill 512 bytes of the OAM staging buffer at WRAM `$000422` with this constant. The byte merely sits directly in front of `CopDispatch`; it has no relationship to COP dispatch. Treat it as unused/cut or debug code (inferred).

The previous doc name `wram_fill_constant` is **not** an extracted label — use `OamFillConstant_unused`.

#### Cross-References

| Symbol | Relationship |
|--------|--------------|
| `OamFillE0_unused` ($008438) | Loads `^OamFillConstant_unused` into `$A1B0` and `&OamFillConstant_unused` into `$A1T0L` as the DMA source (no callers) |

---

### CopDispatch

**Address:** `$846D` · **Size:** 24 bytes

#### Description

Central dispatch engine for the COP bytecode instruction set. Every actor and thinker script instruction routes through this 24-byte routine. It is reached via the native COP vector (`CopVector` → `JML $@cop_dispatch.CopDispatch`) whenever a script executes a `COP #opcode` instruction (the signature byte is the handler opcode) in native mode.

The routine is deliberately minimal: it extracts execution context from the native-mode stack frame, reads the opcode byte, and indirect-jumps through the dispatch table. All semantic work is delegated to individual handlers.

#### Algorithm

```
1. REP #$20              ; 16-bit accumulator
2. TXY                   ; Y ← X (slot address from the runner; handlers restore with TYX)
3. LDA $04,S → STA $0C   ; Script bank (16-bit load; $0D receives an unused stack byte)
4. LDA $02,S; DEC → $0A  ; $0A ← address of the COP signature byte (= pushed PC − 1)
5. LDA [$0A]; INC $0A    ; Read opcode (16-bit read, high byte junk); advance past it
6. AND #$00FF            ; Mask to low byte
7. ASL; TAX              ; A = X = opcode × 2 (table index)
8. JMP ($&cop_dispatch_table, X)
```

Instruction-counted size: `REP`(2) + `TXY`(1) + `LDA d,S`(2) + `STA dp`(2) + `LDA d,S`(2) + `DEC`(1) + `STA dp`(2) + `LDA [dp]`(2) + `INC dp`(2) + `AND #`(3) + `ASL`(1) + `TAX`(1) + `JMP (abs,X)`(3) = 24 bytes, which matches the `$00846D`→`$008485` span.

#### Source

```51:65:extracted/system/engine/cop_dispatch.asm
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
| `$0C` | Script bank (output) — from stack `$04,S` (`$0D` clobbered with an unrelated stack byte, unused) |
| `$02,S` | Input — return PC; unchanged until the handler writes it |
| `$04,S` | Input — return bank byte |
| `X` | Input — slot address from the runner; **overwritten with `opcode × 2`** |
| `Y` | Output — slot address preserved from entry (`TXY`) |
| `A` | Output — `opcode × 2` |

#### Cross-References

| Symbol | Relationship |
|--------|--------------|
| `CopVector` ($008007) | `JML $@cop_dispatch.CopDispatch` — entry from the COP vector |
| `cop_dispatch_table` ($008485) | Indirect jump target |
| All COP handlers | Callees via jump table |
| `RunActors_Normal` and the other `RunActors_*` / `RunThinkers_*` runners (bank `$03`) | Set `D`/`X` to the slot and call the script by pushing a return address and `RTL`-ing into it; COP instructions in that script reach `CopDispatch` |

---

### cop_dispatch_table

**Address:** `$8485`–`$864A` · **Size:** 454 bytes (227 words)

#### Description

One contiguous 227-word table of same-bank (`&`, 16-bit) handler addresses, indexed by `opcode × 2` from `CopDispatch`. In the extracted source it is a single `cop_dispatch_table [ … ]` block (`cop_dispatch.asm` lines 70–298); the "primary" / "extended" split is only a documentation convenience. Entry order is opcode order, one entry per opcode from `$00` to `$E2`:

1. **Primary** (`$008485`): 110 entries for opcodes `$00`–`$6D`
2. **Gap** (`$008561`): 18 `#$0000` entries for opcodes `$6E`–`$7F`
3. **Extended** (`$008585`): 99 entries for opcodes `$80`–`$E2`

#### Table Entry Format

| Field | Size | Content |
|-------|------|---------|
| Offset | 2 bytes | `&cop_handlers_<file>.<Handler>` — address of the handler within bank `$00` (the dispatcher's `JMP (abs,X)` keeps the program bank) |

Unimplemented entries are `#$0000` (literal `$0000` pointers).

#### Cross-References

| Symbol | Relationship |
|--------|--------------|
| `CopDispatch` | Indexer — `JMP ($&cop_dispatch_table, X)` |
| 209 handler routines | Targets across 30 `cop_handlers_*.asm` files (see [COP index](../../cop/README.md) for full list) |
| `db-us/copdef.json` | Declarative opcode metadata (names, operand types) |

---

### cop_table_sentinel

**Address:** `$864B` · **Size:** 3 bytes · **Raw bytes:** `$EA $80 $FD` (`NOP`; `BRA` with displacement `$FD` = −3, back to the `NOP`)

#### Description

A 3-byte `NOP` / `BRA` loop placed immediately after the last table entry (opcode `$E2`). The extracted source comments say plainly that it is **not an effective guard**: an opcode ≥ `$E3` doesn't *run* the loop, it *indexes past* the table, and `JMP (abs,X)` then reads the sentinel's own code bytes as a pointer (opcode `$E3` reads `EA 80` → `$80EA`, higher opcodes read whatever follows). So the loop is only reached if something jumps to `$00864B` directly. No script in the extracted ROM uses opcodes `$E3`+ (see [`invalid_ops.md`](../../cop/families/invalid_ops.md)).

This is trailing padding/guard-style code, not a callable handler.

#### Cross-References

| Symbol | Relationship |
|--------|--------------|
| `cop_dispatch_table` | Immediately precedes this sentinel |
| `GenHdmaSine` / `$00` handler | First table entry at `$008485` |

---

## Dispatch Flow Diagram

Function / stack flow from script to handler and back (actor case; thinkers use the same path through `RunThinkers_*`):

```text
  Runner (RunActors_* / RunThinkers_*, bank $03)
    D = X = slot address;  push return → RunActors_..._Next/PostTick
    push script entry − 1; RTL  ──────────────►  script bytecode (bank $0C)
                                                        │  COP #opcode
                                                        ▼
   hardware pushes  PBR, PC+2, P   (S → $01:P  $02:PC  $04:PBR)
   P.I = 1, P.D = 0
                                                        │
                                                        ▼
  CopVector ($008007)       JML $@cop_dispatch.CopDispatch
                                                        │
                                                        ▼
  CopDispatch ($00846D, 24 bytes)
    REP #$20 ; TXY (Y = slot)
    $0C = $04,S  (bank)        $0A = $02,S − 1  (signature byte = opcode)
    opcode = [$0A] ; $0A++     X = opcode × 2
    JMP ($&cop_dispatch_table, X)
                                                        │
                                                        ▼
  Handler (one of 209, all bank $00)       TYX  → X = slot again
    reads operands via [$0A], $0A++
        ├─ Continue / Branch ─ STA $02,S ; RTI ───────────► next COP in script
        ├─ Yield ───────────── set $00/$02 (+ $08) ; PLA PLA RTL ─► runner (_Next)
        └─ Die ─────────────── unlink slot(s) ; PLA TAX TCD PLA PLA RTL ─► runner
```

## Opcode → Handler Category Call Graph

Documentation-only categories, assigned from the `cop_handlers_*` file that contains each handler (so the grouping is source-derived even though the category names are not extracted labels). Opcode lists come from `cop_dispatch_table`; handler counts per file sum to 209.

```text
COP #op ─► CopDispatch ─► cop_dispatch_table[op × 2] ─► cop_handlers_<file>.<Handler>
```

| Category | Opcodes (handler file, count) |
|----------|-------------------------------|
| **Movement** | `$20`–`$24`, `$43`, `$4A`, `$52`, `$53` (`movement`, 9); `$AA`–`$B1` (`force_move`, 8); `$BC` NudgePosition (`oam_attribs`) |
| **Collision (paint / query / branch)** | `$0B`–`$18`, `$1A`–`$1F`, `$42` (`collision`, 21); `$5D`, `$62` (`actor_flags`, 2) |
| **Spawning / lifetime** | `$99`–`$A6` (`spawn`, 14); `$3B`–`$3D` (`thinker`, 3); `$A7`–`$A9`, `$E0` (`actor_death`, 4); `$6A` (`linked_actor`, 1) |
| **Flags / inventory / state** | `$CC`–`$D3` (`scene_flags`, 8); `$D4`–`$D7` (`inventory`, 4); `$D8`, `$D9` (`dungeon_switch`, 2); `$5B`, `$5C` (`callbacks`, extra-flag bits) |
| **Animation / sprite / palette** | `$55`, `$56`, `$80`–`$8D` (`sprite`, 16); `$8E`–`$98` (`player_sprite`, 11); `$B2`–`$BB` (`oam_attribs`); `$36`–`$3A` (`palette`, 5) |
| **Map / scene / BG change** | `$26` QueueMapChange (`player_query`); `$32`–`$34` (`bg_rearrange`, 3); `$65`–`$67` (`world_map`, 3); `$4B`–`$4E` (`metatile`, 4) |
| **Interaction / dialogue / input** | `$C0` SetInteractHandler (`script_control`); `$57`–`$5A`, `$5E` (`callbacks`, 7 with `$5B`/`$5C`); `$6B`, `$BD`–`$BF` (`dialog`, 4); `$3E`–`$41` (`input`, 4); `$D6`/`$D7` item tests |
| **Player / actor queries & branches** | `$25`, `$27`–`$31`, `$35` (`player_query`, 14 incl. `$26`); `$44`–`$49` (`actor_query`, 6) |
| **Script control / waiting** | `$C1`–`$CB`, `$E1`, `$E2` (`script_control`, 14 incl. `$C0`); `$DA`, `$DB` (`wait`, 2); `$68`, `$69` (`offscreen`, 2) |
| **Audio** | `$04`–`$0A`, `$19` (`audio`, 8) |
| **HDMA / DMA / VRAM** | `$00`–`$03` (`hdma_dma`, 4); `$4F`, `$50`, `$51`, `$54` (`vram`, 4); `$5F`–`$61` sine HDMA (`effects`) |
| **Effects / camera** | `$63`, `$64` gravity; `$6C`, `$6D` spiral; `$DC`–`$DF` CameraPan{Down,Up,Right,Left} (all `effects`, 11 total with sine HDMA) |

Per-handler detail and operand layouts: [`docs/cop/README.md`](../../cop/README.md) and the family pages under `docs/cop/families/`.

---

## See Also

- [`../../cop/README.md`](../../cop/README.md) — Full handler catalog with operands
- [`utility-math-movement.md`](utility-math-movement.md) — Movement helpers called by `$22`/`$52`/`$53`
- [`utility-tiles-animation.md`](utility-tiles-animation.md) — Tile/animation helpers called by `$4B`–`$4E`, `$80`–`$92`

## Source validation

- **Source files checked:**
  - `extracted/system/engine/cop_dispatch.asm` (dispatcher instructions, all 227 table words, sentinel, header note)
  - `extracted/system/engine/system_core.asm` (`CopVector`, `OamFillE0_unused`, `OamFillConstant_unused`)
  - `extracted/system/engine/cop_handlers_script_control.asm`, `cop_handlers_input.asm`, `cop_handlers_wait.asm`, `cop_handlers_actor_death.asm` (exit patterns, `TYX`)
  - `extracted/system/engine/actor_execution.asm`, `thinker_execution.asm` (runner → script call pattern, slot sizes)
  - `db-us/copdef.json`, `db-us/names/bank00.json`
- **Verified against:**
  - actual labels — every one of the 209 opcode/handler rows in the two tables above was diffed against the `;NN` comments in `cop_dispatch_table` (identical); `$DD` is `CameraPanUp`
  - actual table data — 110 + 18 + 99 = 227 words, 209 valid; copdef has 209 entries (ids `0`–`226`)
  - actual call sites — exit patterns confirmed in the handler files listed
- **Notes:**
  - counts are entries (table words), not call sites
  - the only dead item in this range is `OamFillConstant_unused` (and its caller-less routine `OamFillE0_unused`); the `$6E`–`$7F` gap and `cop_table_sentinel` are non-gameplay
  - register-state rows marked "caller assumption" or "inferred" are not enforced by `CopDispatch`; the "category" groupings are documentation-only

*Source: [`extracted/system/engine/cop_dispatch.asm`](../../../extracted/system/engine/cop_dispatch.asm), [`extracted/system/engine/system_core.asm`](../../../extracted/system/engine/system_core.asm)*
