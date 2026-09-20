?BANK 00

---------------------------------------------

; COP #6A (script name SetLinkedActorScript) linked-actor entry setter taking one &Code operand. Writes the far script pointer into the linked actor ($06).$0000 and clears that actor's movement staging fields. Does not alter the caller's entry point. Used in ending-credits parade controllers.

SetLinkedEntryPtr {
    TYX 
    LDA [$0A]             ; Read entry pointer word for linked actor
    INC $0A
    INC $0A
    LDY $06               ; Get next linked actor ($06)
    STA $0000, Y          ; Write entry point to linked actor $0000
    LDA #$0000            ; Clear linked actor's movement staging ($08, $2C, $2E)
    STA $0008, Y
    STA $002C, Y
    STA $002E, Y
    LDA $0A
    STA $02, S
    RTI 
}