?BANK 00

---------------------------------------------

; COP #B2 with no operands. Sets bit $0002 on actor+$10 via TSB to assign maximum draw priority.

SetPriorityMax {
    TYX 
    LDA #$0002
    TSB $10               ; SetPriorityMax: TSB $0002 on $10
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #B3 with no operands. Sets bit $0001 on actor+$10 via TSB to assign minimum draw priority.

SetPriorityMin {
    TYX 
    LDA #$0001
    TSB $10               ; SetPriorityMin: TSB $0001 on $10
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #B4 with no operands. Clears bit $0002 on actor+$10 via TRB to remove maximum-priority override.

ClearPriorityMax {
    TYX 
    LDA #$0002
    TRB $10               ; ClearPriorityMax: TRB $0002
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #B5 with no operands. Clears bit $0001 on actor+$10 via TRB to remove minimum-priority override.

ClearPriorityMin {
    TYX 
    LDA #$0001
    TRB $10               ; ClearPriorityMin: TRB $0001
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #B6 with one byte operand (0–3). Clears OAM priority bits $3000 in attribute word $0E, then XBA/TSB to pack the value into the high byte.

SetOamPriority {
    TYX 
    LDA #$3000            ; TRB #$3000: clear OAM priority bits 12–13 before set
    TRB $0E
    LDA [$0A]
    INC $0A
    AND #$00FF
    XBA                   ; XBA: shift 0–3 value from low byte to high byte for OAM field
    TSB $0E               ; TSB: merge new priority into attribute word $0E
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #B7 with one byte operand (0–7). Clears palette bits $0E00 in $0E, then XBA/TSB to set the 4-bit OAM palette subfield.

SetOamPalette {
    TYX 
    LDA #$0E00
    TRB $0E               ; Clear existing palette bits $0E00 before setting
    LDA [$0A]
    INC $0A
    AND #$00FF
    XBA                   ; XBA: shift palette value to high byte for OAM attribute field
    TSB $0E               ; TSB: merge palette into $0E attribute word
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #B8 with no operands. EORs bit $4000 on OAM attribute word $0E to flip horizontal mirroring.

ToggleHMirror {
    TYX 
    LDA $0E               ; ToggleHMirror: EOR $4000 on $0E
    EOR #$4000            ; EOR $4000: toggle horizontal mirror bit
    STA $0E
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #B9 with no operands. EORs bit $8000 on OAM attribute word $0E to flip vertical mirroring.

ToggleVMirror {
    TYX 
    LDA $0E
    EOR #$8000            ; EOR $8000: toggle vertical mirror bit
    STA $0E
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #BA with no operands. Clears horizontal mirror bit $4000 on OAM attribute word $0E via TRB.

ClearHMirror {
    TYX 
    LDA #$4000            ; ClearHMirror: TRB $4000
    TRB $0E
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #BB with no operands. Sets horizontal mirror bit $4000 on OAM attribute word $0E via TSB.

SetHMirror {
    TYX 
    LDA #$4000
    TSB $0E               ; SetHMirror: TSB $4000
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #BC with two signed byte operands (delta X, delta Y). Sign-extends each byte and adds the offsets to the actor's pixel position at $14/$16.

NudgePosition {
    TYX 
    LDA [$0A]             ; Read signed X offset byte
    INC $0A
    AND #$00FF
    BIT #$0080            ; Test sign bit for 8→16 extension
    BEQ loc_00A849
    ORA #$FF00

  loc_00A849:
    CLC 
    ADC $14               ; Add signed offset to actor X position ($14)
    STA $14
    LDA [$0A]             ; Read signed Y offset byte
    INC $0A
    AND #$00FF
    BIT #$0080            ; Test Y sign bit
    BEQ loc_00A85D
    ORA #$FF00

  loc_00A85D:
    CLC 
    ADC $16               ; Add signed offset to actor Y position ($16)
    STA $16
    LDA $0A
    STA $02, S
    RTI 
}