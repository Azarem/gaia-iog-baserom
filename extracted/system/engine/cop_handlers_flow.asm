; COP handlers for script control flow, event flags, inventory management, and timer waits (Bank $00, 30 COP handlers).
; 
; Script control flow (14 handlers): SetInteractHandler stores NPC interaction pointers in chatPtr. SetEntryHere/HereAndYield/Far set or save entry points for yielding actors. JumpAfterDelay/NextFrame/Far implement deferred and cross-bank jumps. CallNear/Deferred provide subroutine calls with return PC saved in retPtr1. RestoreSavedPtr/ReturnWithSignal restore deferred call pointers. SetSavedPtr stores return addresses for later restoration. LoopStart/LoopEnd implement counted iteration with separate player (loopCounter/$7F0014) and scene actor (loopCounterActor/$7F2102) loop state.
; 
; Event flag handlers (8): SetFlagByte/Word and ClearFlagByte/Word set or clear bits in the eventFlags bitfield via cop_handlers_flags core routines. BranchOnFlagByte/Word branch based on flag state with a sense operand (0=branch-on-clear, nonzero=branch-on-set). WaitOnFlagByte/Word yield each frame until a flag condition is met by rewinding the entry PC.
; 
; Inventory and state (5): GiveItem calls GiveItemToPlayer with carry-based overflow branching. RemoveItem removes by item ID. BranchIfMissingItem/BranchIfItemEquipped test inventory state. SetDungeonKillFlag records enemy kills in wramFlags.
; 
; Misc (3): SwitchCase dispatches through a word-aligned jump table indexed by a WRAM byte. WaitByte/WaitWord set frame delay timers and yield.
---------------------------------------------

?BANK 00

?INCLUDE 'cop_handlers_flags'
?INCLUDE 'inventory_mgmt'

!inventorySlots                 0AB4
!inventoryEquippedIndex         0AC4
!retPtr1                        7F0004
!chatPtr                        7F000A
!loopCounter                    7F0014
!retPtr2                        7F001E
!enemyNum                       7F0022
!loopStartPcActor               7F2100
!loopCounterActor               7F2102

---------------------------------------------

; COP #C0 (script name SetOnInteract) NPC interaction handler setter taking one &Code operand. Stores the script pointer in the actor chatPtr field ($7F000A), which the interaction system invokes when the player talks to or touches the actor. Used by virtually all NPCs, chests, and inspectable objects.

SetInteractHandler {
    TYX 
    LDA [$0A]             ; Read &Code operand pointer for NPC interaction handler
    INC $0A
    INC $0A
    STA $chatPtr, X       ; Store in chatPtr ($7F000A) — interaction system invokes on player contact
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #C1 with no operands. Saves the current script bank ($0C→$02) and PC ($0A→$00) as the actor entry/resume pointer without yielding.

SetEntryHere {
    TYX 
    LDA $0C               ; Load current script bank to actor $02 (entry bank byte)
    STA $02
    LDA $0A               ; Load script PC to actor $00 (entry resume address)
    STA $00
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #C2 with no operands. Same entry-pointer save as SetEntryHere, then pops the return address and yields via RTL so execution resumes next frame.

SetEntryHereAndYield {
    TYX 
    LDA $0C               ; SetEntryHereAndYield: save bank to $02
    STA $02
    LDA $0A               ; Load PC to $00 as resume entry
    STA $00
    PLA                   ; Pop COP frame and yield RTL — resume next frame at saved $00/$02
    PLA 
    RTL 
}

---------------------------------------------
; COP #C3 with one Address (target) plus one word (frame delay). Sets actor $00/$02 to the target script pointer, stores the delay word in $08, and yields via RTL.

JumpAfterDelay {
    TYX 
    LDA [$0A]             ; Read Address target word → deferred entry pointer $00
    INC $0A
    INC $0A
    STA $00               ; Store target script pointer in actor EntryPtr ($00) for deferred resume
    LDA [$0A]             ; Read bank byte for deferred target
    INC $0A
    AND #$00FF
    STA $02               ; Store bank in entry $02
    LDA [$0A]             ; Read frame delay word operand
    INC $0A
    INC $0A
    STA $08               ; Store delay in timer $08 — actor waits this many frames before resuming
    PLA                   ; Yield RTL — resumes at target entry after $08 timer expires
    PLA 
    RTL 
}

---------------------------------------------
; COP #C4 with one Address operand. Sets $00/$02 to the target entry, zeroes the frame timer ($08), and yields via RTL for a one-frame deferred jump.

JumpNextFrame {
    TYX 
    LDA [$0A]             ; Read Address target → $00 for next-frame jump
    INC $0A
    INC $0A
    STA $00
    LDA [$0A]             ; Read bank byte → $02
    INC $0A
    AND #$00FF
    STA $02
    STZ $08               ; Zero timer: immediate 1-frame deferred jump
    PLA 
    PLA 
    RTL 
}

---------------------------------------------
; COP #E2 with one Address operand (word+bank). Writes the far entry pointer to $00/$02, zeroes $08, and RTI-continues immediately without yielding.

SetEntryFar {
    TYX 
    LDA [$0A]             ; SetEntryFar: read far pointer word → $00
    INC $0A
    INC $0A
    STA $00
    LDA [$0A]             ; Read bank byte → $02
    INC $0A
    AND #$00FF
    STA $02
    STZ $08               ; Zero timer $08 (no delay)
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #C5 with no operands. If retPtr1 ($7F0004) is non-zero, restores it as the script PC and clears retPtr1; otherwise yields via RTL.

RestoreSavedPtr {
    TYX 
    LDA $retPtr1, X       ; retPtr1 nonzero: restore as script PC and clear; zero: no saved return — yield RTL
    BEQ loc_00AA71        ; retPtr1 is zero: no saved return — yield RTL
    STA $02, S            ; Restore retPtr1 as return PC on COP stack
    LDA #$0000            ; Clear retPtr1 after restoring (one-shot)
    STA $retPtr1, X
    RTI 

  loc_00AA71:
    PLA 
    PLA 
    RTL 
}

---------------------------------------------
; COP #E1 with no operands. Restores the deferred call PC from retPtr1 (clearing it); if set, RTI-resumes with A=$FFFF as a non-zero signal to the caller, otherwise yields via RTL.

ReturnWithSignal {
    TYX 
    LDA $retPtr1, X       ; Read retPtr1 for signal-return check
    BEQ loc_00AA88        ; No saved PC → yield RTL
    STA $02, S            ; Restore return PC from retPtr1 to stack for RTI-resume at caller
    LDA #$0000
    STA $retPtr1, X       ; Clear retPtr1 after use
    LDA #$FFFF            ; A=$FFFF: non-zero signal to caller (distinguishes from normal return)
    RTI 

  loc_00AA88:
    PLA 
    PLA 
    RTL 
}

---------------------------------------------
; COP #C6 with one &Code operand. Stores the operand offset as a deferred-return pointer in retPtr1 ($7F0004) for later RestoreSavedPtr/ReturnWithSignal use.

SetSavedPtr {
    TYX 
    LDA [$0A]             ; Read &Code operand and store in retPtr1 ($7F0004) for later RestoreSavedPtr
    INC $0A
    INC $0A
    STA $retPtr1, X
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #C7 with one Address operand (word+bank). Cross-bank jump: writes the far entry to $00/$02 and updates the bank byte on the stack; RTI-resumes immediately at the target.

JumpFar {
    TYX 
    LDA [$0A]             ; JumpFar: read target word → $00 and stack $02,S
    INC $0A
    INC $0A
    STA $00
    STA $02, S
    LDA [$0A]             ; Read bank byte for far jump
    INC $0A
    AND #$00FF
    SEP #$20              ; 8-bit mode: write bank byte to both DP $02 (entry) and $04,S (COP stack frame)
    STA $02
    STA $04, S
    REP #$20
    RTI 
}

---------------------------------------------
; COP #C8 with one &Code operand. Saves the current return PC in retPtr1, then RTI-jumps to the same-bank &Code target.

CallNear {
    TYX 
    LDA [$0A]             ; Read &Code target for near call
    INC $0A
    INC $0A
    STA $02, S
    LDA $0A               ; Load caller return PC in retPtr1 before jumping
    STA $retPtr1, X       ; Save caller PC in retPtr1; restored later via RestoreSavedPtr or ReturnWithSignal
    RTI 
}

---------------------------------------------
; COP #C9 with one &Code operand. Sets $00 to the target &Code offset, saves the return PC in retPtr1, and yields via RTL so the callee runs next frame.

CallNearDeferred {
    TYX 
    LDA [$0A]             ; Read target &Code; save caller's return PC in retPtr1, yield for next-frame execution
    INC $0A
    INC $0A
    STA $00               ; Set $00 to target for next-frame execution
    LDA $0A               ; Load return PC in retPtr1 for later RestoreSavedPtr
    STA $retPtr1, X
    PLA                   ; Yield RTL — callee runs next frame
    PLA 
    RTL 
}

---------------------------------------------
; COP #CA with one byte operand (iteration count). For the player actor (X≥$1000) stores the count in loopCounter ($7F0014) and saves the loop-head PC in retPtr2; for scene actors uses loopCounterActor ($7F2102) and loopStartPcActor ($7F2100).

LoopStart {
    TYX 
    CPX #$1000            ; X ≥ $1000 → player actor (uses loopCounter/$7F0014 and retPtr2)
    BCC loc_00AAF6
    LDA [$0A]             ; Read iteration count byte
    INC $0A
    AND #$00FF
    STA $loopCounter, X   ; Store count in player loopCounter ($7F0014)
    LDA $0A
    STA $retPtr2, X       ; Save loop-head PC in retPtr2 for LoopEnd to jump back
    STA $00
    LDA $0A
    STA $02, S
    RTI 

  loc_00AAF6:
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $loopCounterActor, X ; Scene actor: store count in loopCounterActor ($7F2102)
    LDA $0A
    STA $loopStartPcActor, X ; Save loop-head PC in loopStartPcActor ($7F2100)
    STA $00
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #CB with no operands. Decrements the active loop counter (player or actor variant); if non-zero, restores the saved loop-head PC and yields RTL, otherwise falls through and RTI-continues past the loop.

LoopEnd {
    TYX 
    CPX #$1000            ; X ≥ $1000 = player (loopCounter/$7F0014); else scene actor (loopCounterActor/$7F2102)
    BCC loc_00AB2D
    LDA $loopCounter, X   ; Read player loop counter
    DEC                   ; Decrement; zero → loop exhausted
    BEQ loc_00AB28        ; Counter reached zero: exit loop and continue script
    STA $loopCounter, X   ; Counter nonzero: store decremented count
    LDA $retPtr2, X       ; Restore loop-head PC from retPtr2
    STA $00
    PLA                   ; Yield RTL for next loop iteration
    PLA 
    RTL 

  loc_00AB28:
    LDA $0A
    STA $02, S
    RTI 

  loc_00AB2D:
    LDA $loopCounterActor, X ; Scene actor: read loopCounterActor
    DEC 
    BEQ loc_00AB28
    STA $loopCounterActor, X
    LDA $loopStartPcActor, X ; Restore scene actor loop-head PC from loopStartPcActor
    STA $00
    PLA 
    PLA 
    RTL 
}

---------------------------------------------
; COP #CC with one byte operand (flag index). Calls SetEventFlag to OR the corresponding bit in the eventFlags ($0A00) bitfield.

SetFlagByte {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&cop_handlers_flags.SetEventFlag ; SetFlagByte: call SetEventFlag with byte-indexed flag
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #CD with one word operand (flag index). Calls SetEventFlag with the 16-bit flag number.

SetFlagWord {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    JSR $&cop_handlers_flags.SetEventFlag ; SetFlagWord: call SetEventFlag with word flag index
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #CE with one byte operand. Calls ClearEventFlag on the byte flag index.

ClearFlagByte {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&cop_handlers_flags.ClearEventFlag ; ClearFlagByte: call ClearEventFlag on byte flag
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #CF with one word operand. Calls ClearEventFlag on the word flag index.

ClearFlagWord {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    JSR $&cop_handlers_flags.ClearEventFlag ; ClearFlagWord: call ClearEventFlag on word flag
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #D0 with one byte (flag), one byte (sense), and one &Code operand. Tests the flag via TestEventFlag; the sense byte selects branch-on-set vs branch-on-clear, jumping to the &Code offset when the condition matches.

BranchOnFlagByte {
    TYX 
    LDA [$0A]             ; BranchOnFlagByte: read byte flag index
    INC $0A
    AND #$00FF
    JSR $&cop_handlers_flags.TestEventFlag ; Test flag state via TestEventFlag
    BCS loc_00ABA5
    BCC loc_00AB9A
}

---------------------------------------------
; COP #D1 with one word (flag), one byte (sense), and one &Code operand. Word-indexed variant of BranchOnFlagByte with the same sense-controlled conditional branch.

BranchOnFlagWord {
    TYX 
    LDA [$0A]             ; BranchOnFlagWord: read word flag index
    INC $0A
    INC $0A
    JSR $&cop_handlers_flags.TestEventFlag ; Test flag; BCS/BCC dispatch to sense-byte check below
    BCS loc_00ABA5

  loc_00AB9A:
    LDA [$0A]             ; Sense=0 branches when flag clear; sense≠0 branches when flag set
    INC $0A
    AND #$00FF
    BNE loc_00ABB7
    BRA loc_00ABAE

  loc_00ABA5:
    LDA [$0A]             ; Flag set path: read sense byte
    INC $0A
    AND #$00FF
    BEQ loc_00ABB7

  loc_00ABAE:
    LDA [$0A]             ; Sense condition met: read &Code branch target and jump
    INC $0A
    INC $0A
    STA $02, S
    RTI 

  loc_00ABB7:
    LDA [$0A]             ; Sense not met: skip &Code operand and continue
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #D2 with one byte (flag) and one byte (sense). Saves a rewind entry PC, then yields RTL each frame until TestEventFlag matches the requested sense (set or clear).

WaitOnFlagByte {
    TYX 
    LDA $0A               ; Rewind entry 2 bytes before $0A to re-execute this COP handler each frame
    DEC 
    DEC 
    STA $00
    LDA [$0A]             ; Read byte flag index
    INC $0A
    AND #$00FF
    JSR $&cop_handlers_flags.TestEventFlag ; TestEventFlag: carry reflects flag state
    BCS loc_00ABF4
    BCC loc_00ABE9
}

---------------------------------------------
; COP #D3 with one word (flag) and one byte (sense). Word-indexed variant of WaitOnFlagByte with the same yield-until-match behavior.

WaitOnFlagWord {
    TYX 
    LDA $0A               ; WaitOnFlagWord: save rewind PC
    DEC 
    DEC 
    STA $00
    LDA [$0A]             ; Read word flag index
    INC $0A
    INC $0A
    JSR $&cop_handlers_flags.TestEventFlag ; TestEventFlag for word flag
    BCS loc_00ABF4

  loc_00ABE9:
    LDA [$0A]             ; Check sense byte for yield decision
    INC $0A
    AND #$00FF
    BEQ loc_00AC00        ; Sense matched: advance past operand and RTI (flag condition satisfied)
    BRA loc_00ABFD

  loc_00ABF4:
    LDA [$0A]
    INC $0A
    AND #$00FF
    BNE loc_00AC00

  loc_00ABFD:
    PLA                   ; Sense not matched: yield RTL (recheck next frame)
    PLA 
    RTL 

  loc_00AC00:
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #D4 with one byte (item ID) and one &Code (overflow handler). Calls GiveItemToPlayer; on success (carry clear) skips the overflow branch, on failure (carry set) jumps to the &Code overflow target.

GiveItem {
    TYX 
    LDA [$0A]             ; Read item ID byte for GiveItemToPlayer
    INC $0A
    AND #$00FF
    JSL $@inventory_mgmt.GiveItemToPlayer ; Call GiveItemToPlayer; carry set = inventory full
    BCS loc_00AC1E        ; Carry set = inventory full: jump to overflow &Code handler
    LDA [$0A]             ; Success: skip overflow branch operand
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_00AC1E:
    LDA [$0A]             ; Overflow: read &Code target and jump
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #D5 with one byte operand (item ID). Calls RemoveItemFromInventory and continues.

RemoveItem {
    TYX 
    LDA [$0A]             ; Read item ID byte
    INC $0A
    AND #$00FF
    JSL $@inventory_mgmt.RemoveItemFromInventory ; JSL RemoveItemFromInventory on script item ID byte
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #D6 with one byte (item ID) and one &Code operand. Calls CheckInventoryForItem; branches to the &Code offset when the item is absent (carry clear).

BranchIfMissingItem {
    TYX 
    LDA [$0A]             ; Read item ID for inventory check
    INC $0A
    AND #$00FF
    JSL $@inventory_mgmt.CheckInventoryForItem ; CheckInventoryForItem; carry clear = absent
    BCC loc_00AC51        ; Item absent (carry clear): branch to &Code target
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_00AC51:
    LDA [$0A]             ; Item absent: read &Code branch target and jump
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #D7 with one byte (item ID) and one &Code operand. Compares the operand against inventorySlots[inventoryEquippedIndex]; branches to &Code when the equipped slot matches.

BranchIfItemEquipped {
    TYX 
    LDA [$0A]             ; Read item ID byte for equipped check
    INC $0A
    AND #$00FF
    SEP #$20              ; 8-bit compare: item ID byte vs equipped slot in inventorySlots[equippedIndex]
    LDY $inventoryEquippedIndex ; Load equipped inventory slot index
    CMP $inventorySlots, Y ; Compare item ID against equipped slot
    REP #$20
    BEQ loc_00AC79        ; Match: take branch (item is equipped)
    LDA [$0A]             ; Not equipped: skip branch operand
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_00AC79:
    LDA [$0A]             ; Equipped: read &Code target and jump
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #D8 with no script operands. Reads enemyNum ($7F0022) as a WRAM flag index and calls SetWramFlag when non-zero, recording a dungeon enemy kill.

SetDungeonKillFlag {
    TYX 
    LDA $enemyNum, X      ; SetDungeonKillFlag: enemyNum indexes WRAM kill bitfield
    AND #$00FF            ; Mask to byte
    BEQ loc_00AC8F        ; Zero → no enemy to record, skip
    JSR $&cop_handlers_flags.SetWramFlag ; SetWramFlag: mark enemy kill in dungeon bitfield

  loc_00AC8F:
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #D9 with one word (WRAM address) and one Address (case table base). Reads a byte from the WRAM address, doubles it for a word index, and jumps into the case table in the script bank.

SwitchCase {
    LDA [$0A]             ; Read WRAM address word (switch variable source)
    INC $0A
    INC $0A
    TAX 
    LDA $0000, X          ; Read byte at WRAM address → case index
    AND #$00FF
    ASL                   ; SwitchCase: table index ×2 for word-aligned jump table
    STA $0000
    PHB 
    SEP #$20
    LDA $0C               ; Switch DBR to script bank for table data reads
    PHA 
    PLB 
    REP #$20
    LDA [$0A]             ; Read case table base address from script
    INC $0A
    INC $0A
    CLC 
    ADC $0000             ; Add case base + scaled index for switch target address
    TAX 
    LDA $0000, X          ; Read target script address from table entry
    PLB 
    TYX 
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #DA with one byte operand (frame count). Stores the count in actor $08, saves current entry in $00/$02, and yields via RTL until the timer expires.

WaitByte {
    TYX 
    LDA [$0A]             ; Read frame count byte for wait timer
    INC $0A
    AND #$00FF

  loc_00ACC9:
    STA $08               ; Shared wait path: store frame count in $08, save entry pointer, yield RTL
    LDA $0C               ; Load bank to $02 for entry point
    STA $02
    LDA $0A               ; Load script PC to $00
    STA $00
    PLA                   ; Yield RTL — actor waits until $08 timer expires
    PLA 
    RTL 
}

---------------------------------------------
; COP #DB with one word operand (frame count). Same deferred-wait behavior as WaitByte for delays exceeding 255 frames.

WaitWord {
    TYX 
    LDA [$0A]             ; WaitWord: read frame count word (for delays > 255 frames)
    INC $0A
    INC $0A
    BRA loc_00ACC9
}