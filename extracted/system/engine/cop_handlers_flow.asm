; COP handlers for script pointer management, dialogue rendering, jumps, calls, and loops (Bank $00, 19 handlers).
; 
; PrintDialogString/PrintDialogStringAlt render dialogue text via DialogStringRenderer with frame update, joypad masking, and display mode flag management. SetInteractHandler stores a script pointer in the actor chatPtr field for NPC interaction.
; 
; SetEntryHere/HereAndYield/Far write the current or specified script pointer to the actor entry fields. SetSavedPtr/RestoreSavedPtr manage a secondary pointer in retPtr1 for nested calls. ReturnWithSignal restores from retPtr1 with A=$FFFF as a signal.
; 
; JumpAfterDelay sets entry pointer and frame delay. JumpNextFrame sets entry pointer with zero delay. JumpFar jumps cross-bank. CallNear saves the return PC in retPtr1. CallNearDeferred saves return PC and yields. LoopStart/LoopEnd implement counted loops with separate player (loopCounter) and actor (loopCounterActor) counters. SwitchCase reads a WRAM byte and dispatches through a word-aligned jump table.
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
    LDA [$0A]
    INC $0A
    INC $0A
    STA $chatPtr, X
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #C1 with no operands. Saves the current script bank ($0C→$02) and PC ($0A→$00) as the actor entry/resume pointer without yielding.

SetEntryHere {
    TYX 
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #C2 with no operands. Same entry-pointer save as SetEntryHere, then pops the return address and yields via RTL so execution resumes next frame.

SetEntryHereAndYield {
    TYX 
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    PLA 
    PLA 
    RTL 
}

---------------------------------------------
; COP #C3 with one Address (target) plus one word (frame delay). Sets actor $00/$02 to the target script pointer, stores the delay word in $08, and yields via RTL.

JumpAfterDelay {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $00               ; JumpAfterDelay: save resume PC in actor $00 (EntryPtr)
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $02
    LDA [$0A]
    INC $0A
    INC $0A
    STA $08
    PLA 
    PLA 
    RTL 
}

---------------------------------------------
; COP #C4 with one Address operand. Sets $00/$02 to the target entry, zeroes the frame timer ($08), and yields via RTL for a one-frame deferred jump.

JumpNextFrame {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $00
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $02
    STZ $08
    PLA 
    PLA 
    RTL 
}

---------------------------------------------
; COP #E2 with one Address operand (word+bank). Writes the far entry pointer to $00/$02, zeroes $08, and RTI-continues immediately without yielding.

SetEntryFar {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $00
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $02
    STZ $08
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #C5 with no operands. If retPtr1 ($7F0004) is non-zero, restores it as the script PC and clears retPtr1; otherwise yields via RTL.

RestoreSavedPtr {
    TYX 
    LDA $retPtr1, X
    BEQ loc_00AA71
    STA $02, S
    LDA #$0000
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
    LDA $retPtr1, X
    BEQ loc_00AA88
    STA $02, S            ; ReturnWithSignal: restore deferred call PC from retPtr1
    LDA #$0000
    STA $retPtr1, X
    LDA #$FFFF            ; RTI with A=$FFFF: signal non-zero return to caller script
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
    LDA [$0A]
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
    LDA [$0A]
    INC $0A
    INC $0A
    STA $00
    STA $02, S
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    STA $02
    STA $04, S
    REP #$20
    RTI 
}

---------------------------------------------
; COP #C8 with one &Code operand. Saves the current return PC in retPtr1, then RTI-jumps to the same-bank &Code target.

CallNear {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    LDA $0A
    STA $retPtr1, X       ; CallNear: save return PC in $7F0004 for nested calls
    RTI 
}

---------------------------------------------
; COP #C9 with one &Code operand. Sets $00 to the target &Code offset, saves the return PC in retPtr1, and yields via RTL so the callee runs next frame.

CallNearDeferred {
    TYX 
    LDA [$0A]             ; CallNearDeferred: yield; callee resumes next frame
    INC $0A
    INC $0A
    STA $00
    LDA $0A
    STA $retPtr1, X
    PLA 
    PLA 
    RTL 
}

---------------------------------------------
; COP #CA with one byte operand (iteration count). For the player actor (X≥$1000) stores the count in loopCounter ($7F0014) and saves the loop-head PC in retPtr2; for scene actors uses loopCounterActor ($7F2102) and loopStartPcActor ($7F2100).

LoopStart {
    TYX 
    CPX #$1000
    BCC loc_00AAF6
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $loopCounter, X
    LDA $0A
    STA $retPtr2, X
    STA $00
    LDA $0A
    STA $02, S
    RTI 

  loc_00AAF6:
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $loopCounterActor, X ; Per-actor loop counter stored at $7F2102
    LDA $0A
    STA $loopStartPcActor, X
    STA $00
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #CB with no operands. Decrements the active loop counter (player or actor variant); if non-zero, restores the saved loop-head PC and yields RTL, otherwise falls through and RTI-continues past the loop.

LoopEnd {
    TYX 
    CPX #$1000            ; LoopEnd: CPX #$1000 selects player vs actor loop state
    BCC loc_00AB2D
    LDA $loopCounter, X
    DEC 
    BEQ loc_00AB28
    STA $loopCounter, X
    LDA $retPtr2, X
    STA $00
    PLA 
    PLA 
    RTL 

  loc_00AB28:
    LDA $0A
    STA $02, S
    RTI 

  loc_00AB2D:
    LDA $loopCounterActor, X
    DEC 
    BEQ loc_00AB28
    STA $loopCounterActor, X
    LDA $loopStartPcActor, X
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
    JSR $&cop_handlers_flags.SetEventFlag
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
    JSR $&cop_handlers_flags.SetEventFlag
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
    JSR $&cop_handlers_flags.ClearEventFlag
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
    JSR $&cop_handlers_flags.ClearEventFlag
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #D0 with one byte (flag), one byte (sense), and one &Code operand. Tests the flag via TestEventFlag; the sense byte selects branch-on-set vs branch-on-clear, jumping to the &Code offset when the condition matches.

BranchOnFlagByte {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&cop_handlers_flags.TestEventFlag
    BCS loc_00ABA5
    BCC loc_00AB9A
}

---------------------------------------------
; COP #D1 with one word (flag), one byte (sense), and one &Code operand. Word-indexed variant of BranchOnFlagByte with the same sense-controlled conditional branch.

BranchOnFlagWord {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    JSR $&cop_handlers_flags.TestEventFlag ; TestEventFlag; BCS/BCC encodes branch polarity in operand
    BCS loc_00ABA5

  loc_00AB9A:
    LDA [$0A]
    INC $0A
    AND #$00FF
    BNE loc_00ABB7
    BRA loc_00ABAE

  loc_00ABA5:
    LDA [$0A]
    INC $0A
    AND #$00FF
    BEQ loc_00ABB7

  loc_00ABAE:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 

  loc_00ABB7:
    LDA [$0A]
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
    LDA $0A
    DEC 
    DEC 
    STA $00
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSR $&cop_handlers_flags.TestEventFlag
    BCS loc_00ABF4
    BCC loc_00ABE9
}

---------------------------------------------
; COP #D3 with one word (flag) and one byte (sense). Word-indexed variant of WaitOnFlagByte with the same yield-until-match behavior.

WaitOnFlagWord {
    TYX 
    LDA $0A
    DEC 
    DEC 
    STA $00
    LDA [$0A]
    INC $0A
    INC $0A
    JSR $&cop_handlers_flags.TestEventFlag ; WaitOnFlagWord: yield loop until event flag matches sense
    BCS loc_00ABF4

  loc_00ABE9:
    LDA [$0A]
    INC $0A
    AND #$00FF
    BEQ loc_00AC00
    BRA loc_00ABFD

  loc_00ABF4:
    LDA [$0A]
    INC $0A
    AND #$00FF
    BNE loc_00AC00

  loc_00ABFD:
    PLA 
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
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSL $@inventory_mgmt.GiveItemToPlayer
    BCS loc_00AC1E
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_00AC1E:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #D5 with one byte operand (item ID). Calls RemoveItemFromInventory and continues.

RemoveItem {
    TYX 
    LDA [$0A]
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
    LDA [$0A]
    INC $0A
    AND #$00FF
    JSL $@inventory_mgmt.CheckInventoryForItem
    BCC loc_00AC51
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_00AC51:
    LDA [$0A]
    INC $0A
    INC $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #D7 with one byte (item ID) and one &Code operand. Compares the operand against inventorySlots[inventoryEquippedIndex]; branches to &Code when the equipped slot matches.

BranchIfItemEquipped {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF
    SEP #$20
    LDY $inventoryEquippedIndex
    CMP $inventorySlots, Y
    REP #$20
    BEQ loc_00AC79
    LDA [$0A]
    INC $0A
    INC $0A
    LDA $0A
    STA $02, S
    RTI 

  loc_00AC79:
    LDA [$0A]
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
    AND #$00FF
    BEQ loc_00AC8F
    JSR $&cop_handlers_flags.SetWramFlag

  loc_00AC8F:
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #D9 with one word (WRAM address) and one Address (case table base). Reads a byte from the WRAM address, doubles it for a word index, and jumps into the case table in the script bank.

SwitchCase {
    LDA [$0A]
    INC $0A
    INC $0A
    TAX 
    LDA $0000, X
    AND #$00FF
    ASL                   ; SwitchCase: table index ×2 for word-aligned jump table
    STA $0000
    PHB 
    SEP #$20
    LDA $0C
    PHA 
    PLB 
    REP #$20
    LDA [$0A]
    INC $0A
    INC $0A
    CLC 
    ADC $0000             ; Add case base + scaled index for switch target address
    TAX 
    LDA $0000, X
    PLB 
    TYX 
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #DA with one byte operand (frame count). Stores the count in actor $08, saves current entry in $00/$02, and yields via RTL until the timer expires.

WaitByte {
    TYX 
    LDA [$0A]
    INC $0A
    AND #$00FF

  loc_00ACC9:
    STA $08
    LDA $0C
    STA $02
    LDA $0A
    STA $00
    PLA 
    PLA 
    RTL 
}

---------------------------------------------
; COP #DB with one word operand (frame count). Same deferred-wait behavior as WaitByte for delays exceeding 255 frames.

WaitWord {
    TYX 
    LDA [$0A]
    INC $0A
    INC $0A
    BRA loc_00ACC9
}