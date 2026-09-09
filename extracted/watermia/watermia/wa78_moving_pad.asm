!playerActor                    09AA
!metaspritePtr                  7F000C

---------------------------------------------

wa78_moving_pad [
  actor-def < #1F, #01, #03, {

  code_079FA1:
    COP [AddPosition] ( #08, #00 )
    COP [ExitIfFlagByte] ( #8D, #01 )
    COP [SpawnBefore] ( @actor_079E22 )
    COP [SetEntryExit]
    STZ $26
    COP [ClearAllHere]
    COP [ClearLowHere]

  loc_079FB6:
    COP [WaitByte] ( #77 )
    JSL $@code_07A018
    COP [StageSpriteLoopMoveY] ( #1F, #84, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1F, #84, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1F, #84, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1F, #84, #02 )
    COP [AnimLoop]
    JSL $@code_07A041
    LDA $26
    DEC 
    BEQ loc_079FE6
    COP [SetEntryExit]
    COP [KillNext]

  loc_079FE6:
    COP [WaitByte] ( #77 )
    JSL $@code_07A018
    COP [StageSpriteLoopMoveY] ( #1F, #84, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1F, #84, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1F, #84, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1F, #84, #01 )
    COP [AnimLoop]
    JSL $@code_07A041
    LDA $26
    DEC 
    BEQ loc_079FB6
    COP [SetEntryExit]
    COP [KillNext]
    BRA loc_079FB6
} >
]

code_07A018 {
    LDA $26
    BNE loc_07A020
    PHB 
    PLA 
    PLA 
    RTL 

  loc_07A020:
    DEC 
    BEQ loc_07A036
    COP [SpawnAfterFlags] ( @code_07A05F, #$2000 )
    LDY $playerActor
    LDA $0010, Y
    AND #$FFF7
    STA $0010, Y

  loc_07A036:
    COP [SolidHighHere]
    LDY $04
    LDA #$0001
    STA $0026, Y
    RTL 
}

code_07A041 {
    LDA $26
    DEC 
    BEQ loc_07A052
    LDY $playerActor
    LDA $0010, Y
    ORA #$0008
    STA $0010, Y

  loc_07A052:
    LDY $04
    LDA #$0000
    STA $0026, Y
    COP [ClearAllHere]
    COP [ClearLowHere]
    RTL 
}

code_07A05F {
    LDY $24
    LDA $0014, Y
    PHA 
    SEC 
    SBC $14
    LDY $playerActor
    CLC 
    ADC $0014, Y
    STA $0014, Y
    PLA 
    STA $14
    LDY $24
    LDA $0016, Y
    PHA 
    SEC 
    SBC $16
    LDY $playerActor
    CLC 
    ADC $0016, Y
    STA $0016, Y
    PLA 
    STA $16
    RTL 
}
---------------------------------------------

actor_079E22 {
    STZ $18
    STZ $1A
    STZ $1C
    STZ $1E
    PHX 
    PHB 
    SEP #$20
    LDA $7F0008, X
    PHA 
    PLB 
    REP #$20
    LDA $metaspritePtr, X
    TAX 
    LDA $0000, X
    SEP #$20
    EOR #$FF
    INC 
    STA $1C
    XBA 
    EOR #$FF
    INC 
    STA $1E
    LDA $0004, X
    EOR #$FF
    INC 
    STA $18
    LDA $0006, X
    EOR #$FF
    INC 
    STA $1A
    REP #$20
    PLB 
    PLX 

  code_079E5F:
    COP [SetEntryContinue]
    LDA $26
    BEQ loc_079E68
    JMP $&code_079F0D

  loc_079E68:
    LDY $24
    LDA $0014, Y
    SEC 
    SBC $1C
    STA $0018
    LDA $0014, Y
    CLC 
    ADC $1C
    STA $001A
    LDA $0016, Y
    SEC 
    SBC $1E
    STA $001C
    LDA $0016, Y
    CLC 
    ADC $1E
    STA $001E
    LDY $playerActor
    LDA $0014, Y
    CLC 
    ADC #$0008
    CMP $0018
    BCC loc_079F04
    LDA $0014, Y
    SEC 
    SBC #$0008
    CMP $001A
    BCS loc_079F04
    LDA $0016, Y
    CMP $001C
    BCC loc_079F04
    LDA $0016, Y
    SEC 
    SBC #$0010
    CMP $001E
    BCS loc_079F04
    LDY $24
    LDA #$0000
    STA $0026, Y
    JSR $&code_079F77
    LDY $playerActor
    LDA $0014, Y
    SEC 
    SBC #$0008
    CMP $0018
    BCS loc_079ED8
    RTL 

  loc_079ED8:
    LDA $0014, Y
    CLC 
    ADC #$0008
    CMP $001A
    BCC loc_079EE5
    RTL 

  loc_079EE5:
    LDA $0016, Y
    SEC 
    SBC #$0010
    CMP $001C
    BCS loc_079EF2
    RTL 

  loc_079EF2:
    LDA $0016, Y
    CMP $001E
    BCC loc_079EFB
    RTL 

  loc_079EFB:
    LDY $24
    LDA #$0002
    STA $0026, Y
    RTL 

  loc_079F04:
    LDY $24
    LDA #$0001
    STA $0026, Y
    RTL 
}

code_079F0D {
    COP [SetEntryContinue]
    LDA $26
    BNE loc_079F16
    JMP $&code_079E5F

  loc_079F16:
    LDY $24
    LDA $0026, Y
    DEC 
    BNE loc_079F1F
    RTL 

  loc_079F1F:
    JSR $&code_079F77
    LDY $playerActor
    LDA $0014, Y
    SEC 
    SBC #$0008
    CMP $0018
    BCS loc_079F3B
    LDA $0018
    CLC 
    ADC #$0008
    STA $0014, Y

  loc_079F3B:
    LDA $0014, Y
    CLC 
    ADC #$0008
    CMP $001A
    BCC loc_079F51
    LDA $001A
    SEC 
    SBC #$0008
    STA $0014, Y

  loc_079F51:
    LDA $0016, Y
    SEC 
    SBC #$0010
    CMP $001C
    BCS loc_079F67
    LDA $001C
    CLC 
    ADC #$0010
    STA $0016, Y

  loc_079F67:
    LDA $0016, Y
    CMP $001E
    BCS loc_079F70
    RTL 

  loc_079F70:
    LDA $001E
    STA $0016, Y
    RTL 
}

code_079F77 {
    LDY $24
    LDA $0014, Y
    SEC 
    SBC $18
    STA $0018
    LDA $0014, Y
    CLC 
    ADC $18
    STA $001A
    LDA $0016, Y
    SEC 
    SBC $1A
    STA $001C
    LDA $0016, Y
    CLC 
    ADC $1A
    STA $001E
    RTS 
}