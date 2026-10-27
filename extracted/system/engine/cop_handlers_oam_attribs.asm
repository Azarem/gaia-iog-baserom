; COP handlers for actor depth priority, OAM attribute mask and position nudging (42931–43111, Bank 00).
; 
; Ten COP opcodes ($B2–$BB) plus NudgePosition ($BC), all with the standard handler shape: TYX, change one field of the calling actor, then store the operand pointer $0A to the return address on the stack ($02,S) and RTI.
; 
; === DEPTH PRIORITY ($B2–$B5) ===
; 
; Set or clear bits of the actor flag word $10 that override the Y-based sort key of SortActorsByDepth. Bit 1 ($0002, SetPriorityMax) forces key $0000: first OAM index, drawn in front of every other actor. Bit 0 ($0001, SetPriorityMin) forces key $01FE: last OAM index, drawn behind every other actor. Max wins when both are set. Typical use: a falling or flying actor takes Max while airborne (ceiling tiles, seagulls, falling orbs) and drops to Min once it rests on the floor. The only reader of these two bits found in the extracted code is the depth sort; older docs call them 'collision priority', which the code does not support.
; 
; === OAM ATTRIBUTE MASK ($B6–$BB) ===
; 
; Actor word $0E is an XOR mask that DecomposeActorMetasprites applies to every sub-sprite's tile/attribute word (UpdateActorAnimation also reads its flip bits): $3000 = OAM priority (BG layer order), $0E00 = palette, $4000 = H-flip, $8000 = V-flip. SetSpritePriority and SetSpritePalette clear their field, then merge the operand (0–3 / 0–7) shifted into the high byte. The mirror handlers EOR (Toggle), TRB (Clear) or TSB (Set) the flip bit. Script-side names in copdef.json are SetSpritePriority and SetSpritePalette.
; 
; === NUDGE ($BC) ===
; 
; NudgePosition adds two signed byte operands to the actor's pixel position ($14/$16). It is a position operation that happens to sit with the attribute handlers.
---------------------------------------------

?BANK 00

---------------------------------------------

; COP #B2 with no operands. Sets bit $0002 on actor+$10 via TSB: SortActorsByDepth then gives the actor key $0000 (first OAM index), so it draws in front of every other actor.

SetPriorityMax {
    TYX 
    LDA #$0002
    TSB $10               ; Bit 1 → depth key $0000: frontmost
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #B3 with no operands. Sets bit $0001 on actor+$10 via TSB: SortActorsByDepth then gives the actor key $01FE (last OAM index), so it draws behind every other actor unless SetPriorityMax is also set.

SetPriorityMin {
    TYX 
    LDA #$0001
    TSB $10               ; Bit 0 → depth key $01FE: rearmost
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #B4 with no operands. Clears bit $0002 on actor+$10 via TRB, removing the front-most override (Y-based sorting resumes unless bit $0001 is set).

ClearPriorityMax {
    TYX 
    LDA #$0002
    TRB $10
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #B5 with no operands. Clears bit $0001 on actor+$10 via TRB, removing the rear-most override (Y-based sorting resumes unless bit $0002 is set).

ClearPriorityMin {
    TYX 
    LDA #$0001
    TRB $10
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #B6 with one byte operand (0–3). Clears OAM priority bits $3000 in attribute word $0E, then XBA/TSB to pack the value into the high byte.

SetSpritePriority {
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

SetSpritePalette {
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
    LDA $0E
    EOR #$4000            ; Toggle bit 14 (H-flip) of the attribute mask
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
    EOR #$8000            ; Toggle bit 15 (V-flip) of the attribute mask
    STA $0E
    LDA $0A
    STA $02, S
    RTI 
}

---------------------------------------------
; COP #BA with no operands. Clears horizontal mirror bit $4000 on OAM attribute word $0E via TRB.

ClearHMirror {
    TYX 
    LDA #$4000
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
    TSB $0E
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