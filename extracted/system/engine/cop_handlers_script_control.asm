?BANK 00

!retPtr1                        7F0004
!chatPtr                        7F000A
!loopCounter                    7F0014
!retPtr2                        7F001E
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