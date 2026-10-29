; COP script-control handlers (Bank $00): interaction handler, resume entry, jumps, calls and loops (COP #C0–#CB, #E1, #E2).
; 
; An actor script resumes from the entry pointer in its DP: $00/$01 = offset, $02 = bank. SetEntryHere and SetEntryHereAndYield save the position after themselves; JumpAfterDelay, JumpNextFrame, SetEntryFar and JumpFar write a target. Yielding handlers pop the COP frame and RTL (the actor resumes next frame at $00/$02); the others RTI back into the stream. SetEntryFar only changes the entry and keeps running; JumpFar also jumps.
; 
; Call/return uses a single slot, retPtr1 ($7F0004), so calls do not nest. SetSavedPtr stores an explicit &Code operand; CallNear and CallNearDeferred store the address after their own operand and jump to the target. RestoreSavedPtr and ReturnWithSignal jump back to the slot and clear it, or yield when it is empty (ReturnWithSignal also returns A = $FFFF).
; 
; Loops: LoopStart saves the count and the loop-head PC, LoopEnd decrements the count and, until it reaches zero, sets $00 to the loop head and yields (so at least one frame per iteration). A count of 0 would wrap to 65536 iterations (no guard). Pooled actors (X ≥ $1000) keep the count and head in their own fields loopCounter ($7F0014) and retPtr2 ($7F001E). Thinkers (X < $1000) use the arrays loopCounterActor ($7F2102) and loopStartPcActor ($7F2100) indexed by X; those two mnemonic names say 'Actor' but they are the thinker variants (rename proposal 90).
; 
; SetInteractHandler (#C0, 322 uses in scripts) stores a &Code pointer in chatPtr ($7F000A), the routine the interaction system runs when the player talks to or touches the actor.
---------------------------------------------

?BANK 00

!retPtr1                        7F0004
!chatPtr                        7F000A
!loopCounter                    7F0014
!retPtr2                        7F001E
!loopStartPcActor               7F2100
!loopCounterActor               7F2102

---------------------------------------------

; COP #C0 with one &Code operand. Stores it in the actor's chatPtr ($7F000A), the routine the interaction system runs when the player talks to or touches the actor. Used by NPCs, chests and inspectable objects (322 uses). The copdef name is SetInteractHandler; 'SetOnInteract' is only a stale name in the docs.

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
    STA $02               ; Entry bank → $02 (16-bit store: $03 also receives stack junk from $0D, OQ-69)
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
    STA $02               ; Entry bank → $02 (16-bit store, see SetEntryHere)
    LDA $0A               ; Load PC to $00 as resume entry
    STA $00
    PLA                   ; Pop COP frame and yield RTL — resume next frame at saved $00/$02
    PLA 
    RTL 
}

---------------------------------------------
; COP #C3 with one Address (target) plus one word (delay count n). Sets actor $00/$02 to the target script pointer, stores n in $08 and yields via RTL. The script resumes at the target n + 1 ticks later (the WaitByte rule; 0 = next tick).

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
    LDA [$0A]             ; Read delay count word operand (n)
    INC $0A
    INC $0A
    STA $08               ; Store n in timer $08: the actor resumes at the target n + 1 ticks later
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
; COP #E2 with one Address operand (word + bank). Writes the far entry pointer to $00/$02 and zeroes $08, then RTI-continues in the current stream without yielding. Unlike JumpFar it does not jump: the new entry only takes effect the next time the actor resumes.

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
; COP #CA with one byte operand (iteration count). Stores the count and the loop-head PC (the address after the operand) and sets $00 to the loop head.
; 
; Pooled actors (X ≥ $1000) use loopCounter ($7F0014) and retPtr2 ($7F001E); thinkers (X < $1000) use loopCounterActor ($7F2102) and loopStartPcActor ($7F2100).

LoopStart {
    TYX 
    CPX #$1000            ; X ≥ $1000 = pooled actor (fields $7F0014/$7F001E); X < $1000 = thinker (arrays $7F2100/$7F2102)
    BCC loc_00AAF6
    LDA [$0A]             ; Read iteration count byte
    INC $0A
    AND #$00FF
    STA $loopCounter, X   ; Pooled actor: count in loopCounter ($7F0014)
    LDA $0A
    STA $retPtr2, X       ; Pooled actor: loop-head PC in retPtr2 for LoopEnd
    STA $00
    LDA $0A
    STA $02, S
    RTI 

  loc_00AAF6:
    LDA [$0A]
    INC $0A
    AND #$00FF
    STA $loopCounterActor, X ; Thinker: count in loopCounterActor ($7F2102)
    LDA $0A
    STA $loopStartPcActor, X ; Thinker: loop-head PC in loopStartPcActor ($7F2100)
    STA $00
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #CB with no operands. Decrements the loop counter (pooled-actor or thinker variant). At zero it continues past the loop with RTI; otherwise it stores the count, sets $00 to the saved loop head and yields via RTL, so each iteration ends with a yield.

LoopEnd {
    TYX 
    CPX #$1000            ; X ≥ $1000 = pooled actor (loopCounter/retPtr2); else thinker (loopCounterActor/loopStartPcActor)
    BCC loc_00AB2D
    LDA $loopCounter, X   ; Pooled actor: read loopCounter
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
    LDA $loopCounterActor, X ; Thinker: read loopCounterActor
    DEC 
    BEQ loc_00AB28
    STA $loopCounterActor, X
    LDA $loopStartPcActor, X ; Thinker: restore the loop-head PC from loopStartPcActor
    STA $00
    PLA 
    PLA 
    RTL 
}