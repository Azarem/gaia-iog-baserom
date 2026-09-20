?BANK 00

!extendedFlags                  7F002A
!onHitCallback                  7F1000
!onDodgeCallback                7F1002
!onDeathCallback                7F1004
!onCollideCallback              7F1008
!scratch1010                    7F1010

---------------------------------------------

; COP #57 with one &Code plus one byte (bank). Stores the word pointer in onDeathCallback ($7F1004) and the bank byte in $7F1006 for the actor's death script hook.

SetDeathCallback {
    TYX 
    LDA [$0A]             ; SetDeathCallback: read pointer word
    INC $0A
    INC $0A
    STA $onDeathCallback, X ; Store to onDeathCallback ($7F1004)
    LDA [$0A]             ; Read bank byte for death callback
    INC $0A
    AND #$00FF
    STA $7F1006, X        ; Store bank to $7F1006
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #58 with one &Code operand. Stores the script pointer in onHitCallback ($7F1000) for hit-event dispatch.

SetHitCallback {
    TYX 
    LDA [$0A]             ; Read hit callback pointer and store to $7F1000
    INC $0A
    INC $0A
    STA $onHitCallback, X
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #59 with one &Code operand. Stores the script pointer in onDodgeCallback ($7F1002) for dodge-event dispatch.

SetDodgeCallback {
    TYX 
    LDA [$0A]             ; Read dodge callback pointer and store to $7F1002
    INC $0A
    INC $0A
    STA $onDodgeCallback, X
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #5A with one &Code operand. Stores the script pointer in onCollideCallback ($7F1008) for collision-event dispatch.

SetCollideCallback {
    TYX 
    LDA [$0A]             ; Read collide callback pointer and store to $7F1008
    INC $0A
    INC $0A
    STA $onCollideCallback, X
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #5E with one &Code operand. Stores the script pointer in scratch1010+6 ($7F1016) for custom actor callbacks.

SetCustomCallback {
    TYX 
    LDA [$0A]             ; Read custom callback pointer and store to $7F1016
    INC $0A
    INC $0A
    STA $scratch1010+6, X
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #5B with one word operand. ORs the value into the actor's extendedFlags word at $7F002A.

OrExtraFlags {
    TYX 
    LDA [$0A]             ; Read flags word and OR into extendedFlags ($7F002A)
    INC $0A
    INC $0A
    ORA $extendedFlags, X
    STA $extendedFlags, X
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #5C with one word operand. ANDs the value with the actor's extendedFlags word at $7F002A.

AndExtraFlags {
    TYX 
    LDA [$0A]             ; Read flags word and AND with extendedFlags ($7F002A)
    INC $0A
    INC $0A
    AND $extendedFlags, X
    STA $extendedFlags, X
    LDA $0A
    STA $02, S
    RTI 
}