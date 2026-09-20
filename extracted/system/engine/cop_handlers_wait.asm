?BANK 00

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