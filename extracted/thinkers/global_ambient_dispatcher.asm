?INCLUDE 'GetPlayerFacingDirection'
?INCLUDE 'sprite_composition'

!joypadCurrent                  0656
!joypadHeld                     0658
!playerActor                    09AA
!chatPtr                        7F000A
!animScratch2                   7F000E

---------------------------------------------

global_ambient_dispatcher [
  thinker-def < #00, #08, {

  code_00BF8B:
    COP [SwitchCase] ( #$0AD4, &code_list_00BF91 )
} >
]

code_list_00BF91 [
  &code_00BF99   ;00
  &code_00BFA0   ;01
  &code_00BFA7   ;02
  &code_00BFAE   ;03
]

code_00BF99 {
    COP [PaletteStart] ( #0B )
    COP [PaletteStep]
    BRA loc_00BFB5
}

code_00BFA0 {
    COP [PaletteStart] ( #0C )
    COP [PaletteStep]
    BRA loc_00BFB5
}

code_00BFA7 {
    COP [PaletteStart] ( #23 )
    COP [PaletteStep]
    BRA loc_00BFB5
}

code_00BFAE {
    COP [PaletteStart] ( #0C )
    COP [PaletteStep]
    BRA loc_00BFB5

  loc_00BFB5:
    LDA $animScratch2, X
    AND #$F7FF
    STA $animScratch2, X
    COP [SetEntryExit]
    PHD 
    LDA #$0000
    TCD 
    LDA $joypadCurrent
    BIT #$8000
    BEQ loc_00BFD2
    JMP $&code_00BFD4

  loc_00BFD2:
    PLD 
    RTL 
}

code_00BFD4 {
    JSL $@GetPlayerFacingDirection
    BCC loc_00BFDC
    PLD 
    RTL 

  loc_00BFDC:
    STA $09EE
    LDY $playerActor
    PHP 
    REP #$20
    AND #$00FF
    BEQ loc_00BFF2
    DEC 
    BEQ loc_00C00C
    DEC 
    BEQ loc_00C026
    BRA loc_00C040

  loc_00BFF2:
    LDA $0014, Y
    STA $18
    LDA $0016, Y
    INC 
    STA $1C
    JSR $&code_00C133
    BEQ loc_00C05A
    LDA $0016, X
    SEC 
    SBC $1C
    BMI loc_00C05D
    BRA loc_00C06A

  loc_00C00C:
    LDA $0014, Y
    STA $18
    LDA $0016, Y
    DEC 
    STA $1C
    JSR $&code_00C133
    BEQ loc_00C05A
    LDA $1C
    SEC 
    SBC $0016, X
    BMI loc_00C05D
    BRA loc_00C06A

  loc_00C026:
    LDA $0014, Y
    DEC 
    STA $18
    LDA $0016, Y
    STA $1C
    JSR $&code_00C133
    BEQ loc_00C05A
    LDA $18
    SEC 
    SBC $0014, X
    BMI loc_00C05D
    BRA loc_00C06A

  loc_00C040:
    LDA $0014, Y
    INC 
    STA $18
    LDA $0016, Y
    STA $1C
    JSR $&code_00C133
    BEQ loc_00C05A
    LDA $0014, X
    SEC 
    SBC $18
    BMI loc_00C05D
    BRA loc_00C06A

  loc_00C05A:
    PLP 
    PLD 
    RTL 

  loc_00C05D:
    LDA $chatPtr, X
    BNE loc_00C066
    JMP $&code_00C0DE

  loc_00C066:
    TXA 
    TCD 
    BRA loc_00C07F

  loc_00C06A:
    LDA #$8000
    TSB $joypadHeld
    LDA $chatPtr, X
    BEQ loc_00C0EA
    TXA 
    TCD 
    LDA $12
    BIT #$0200
    BEQ loc_00C097

  loc_00C07F:
    SEP #$20
    PHK 
    PEA $&code_00C0DE-1
    LDA $02
    PHA 
    REP #$20
    LDA $chatPtr, X
    DEC 
    PHA 
    LDA #$8000
    TSB $joypadHeld
    RTL 

  loc_00C097:
    SEP #$20
    LDA #$7E
    STA $0404
    LDY #$3410
    LDA #$00
    STA $0405
    REP #$20
    LDA #$002F
    JSR $0402
    TDC 
    TAX 
    SEP #$20
    LDA #$7F
    STA $0405
    REP #$20
    LDA #$002F
    JSR $0402
    TDC 
    TAX 
    JSR $&code_00C182
    STA $28
    STZ $2A
    JSL $@sprite_composition.UpdateActorAnimation
    SEP #$20
    PHK 
    PEA $&code_00C0ED-1
    LDA $02
    PHA 
    REP #$20
    LDA $chatPtr, X
    DEC 
    PHA 
    RTL 
}

code_00C0DE {
    LDA #$8000
    TRB $joypadCurrent
    LDA #$8000
    TSB $joypadHeld

  loc_00C0EA:
    PLP 
    PLD 
    RTL 
}

code_00C0ED {
    TXY 
    LDA $06
    PHA 
    SEP #$20
    LDA #$7E
    STA $0405
    LDX #$3410
    LDA #$00
    STA $0404
    REP #$20
    LDA #$002F
    JSR $0402
    TDC 
    TAY 
    SEP #$20
    LDA #$7F
    STA $0404
    REP #$20
    LDA #$002F
    JSR $0402
    TDC 
    TAX 
    LDA $06
    BNE loc_00C123
    LDA $01, S
    STA $06

  loc_00C123:
    PLA 
    LDA #$8000
    TRB $joypadCurrent
    LDA #$8000
    TSB $joypadHeld
    PLP 
    PLD 
    RTL 
}

code_00C133 {
    LDA #$0020
    STA $02
    STZ $00
    STZ $04
    LDA $0056
    BRA loc_00C144

  loc_00C141:
    LDA $0006, X

  loc_00C144:
    TAX 
    BEQ loc_00C17F
    LDA $0010, X
    BIT #$1000
    BEQ loc_00C141
    LDA $0014, X
    SEC 
    SBC $18
    BPL loc_00C15B
    EOR #$FFFF
    INC 

  loc_00C15B:
    CMP #$0010
    BCS loc_00C141
    STA $00
    LDA $0016, X
    SEC 
    SBC $1C
    BPL loc_00C16E
    EOR #$FFFF
    INC 

  loc_00C16E:
    CMP #$0010
    BCS loc_00C141
    ADC $00
    CMP $02
    BCS loc_00C141
    STA $02
    STX $04
    BRA loc_00C141

  loc_00C17F:
    LDX $04
    RTS 
}

code_00C182 {
    LDA $09EE
    AND #$00FF
    BIT #$0002
    BNE loc_00C193
    INC 
    AND #$0001
    BRA loc_00C199

  loc_00C193:
    INC 
    AND #$0001
    INC 
    INC 

  loc_00C199:
    STA $09EE
    LDA $28
    DEC 
    DEC 
    AND #$FFF8
    INC 
    INC 
    CLC 
    ADC $09EE
    RTS 
}