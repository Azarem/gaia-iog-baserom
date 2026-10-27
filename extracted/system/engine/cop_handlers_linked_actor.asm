; COP handler for SetLinkedEntryPtr ($6A), the only linked-actor operation (40454–40482, Bank 00).
; 
; Retargets the actor that follows the caller in the actor list (nextActorLink, $06): writes a new 16-bit script pointer into that actor's entryPtr and clears its waitCounter ($08) and velocity ($2C/$2E). The caller's own entry pointer is not touched, and the caller keeps running after the operand.
; 
; Usage: all 164 call sites are in ending/ending_credits (sF7_credits*.asm), where a director actor alternates HaltIfMaxFrames with SetLinkedEntryPtr to step a linked child (Will's sprite, marchers) through animation scripts on a frame timeline. The caller must already have a valid $06 link.
---------------------------------------------

?BANK 00

---------------------------------------------

; COP $6A (SetLinkedEntryPtr) with one &Code operand: point the next-linked actor ($06) at a new script.
; 
; Only the 16-bit word at the linked actor's $00/$01 is replaced (the 2-byte operand is a same-bank pointer; its bank byte $02 is left as it was), and its waitCounter ($08) and moveX/moveY ($2C/$2E) are zeroed so the new script starts on the linked actor's next tick with no pending wait or velocity. The caller's script pointer is advanced past the operand and the COP returns via RTI, so the caller continues immediately.
; 
; Y = linked actor's DP base; $0000,Y works as that actor's DP because DBR=$81 mirrors low WRAM.

SetLinkedEntryPtr {
    TYX 
    LDA [$0A]             ; 2-byte &Code operand (same-bank script pointer)
    INC $0A
    INC $0A
    LDY $06               ; Y = linked actor (nextActorLink)
    STA $0000, Y          ; Linked actor's $00/$01 ← new entry; bank byte $02 unchanged
    LDA #$0000            ; Cancel linked actor's pending wait ($08) and velocity ($2C/$2E)
    STA $0008, Y
    STA $002C, Y
    STA $002E, Y
    LDA $0A               ; Patch COP return PC on the stack past the operand so RTI resumes the caller
    STA $02, S
    RTI 
}