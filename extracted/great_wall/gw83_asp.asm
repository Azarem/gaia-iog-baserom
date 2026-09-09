?INCLUDE 'ApplyPlayerHitstun'
?INCLUDE 'StandardEnemyDefeatHandler'

!joypadCurrent                  0656
!joypadMaskStd                  065A
!playerXPos                     09A2
!playerYPos                     09A4
!playerActor                    09AA
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!collisionLayer                 7FC000

---------------------------------------------

gw83_asp [
  actor-def < #13, #00, #00, {

  code_0B9426:
    STZ $24

  loc_0B9428:
    COP [WaitWhileOffscreen] ( #0A )

  code_0B942B:
    LDA $10
    BIT #$4000
    BNE loc_0B9428
    LDA $playerXPos
    CLC 
    ADC #$0008
    SEC 
    SBC $14
    BMI loc_0B945F
    LDA $24
    AND #$0040
    BNE loc_0B9456
    COP [StageSpriteFrame] ( #93 )
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #05, &code_0B9547 )
    INC $24
    COP [SetEntryExitNow] ( @code_0B942B )

  loc_0B9456:
    STZ $24
    COP [StageSpriteFrame] ( #94 )
    COP [AnimOnce]
    BRA code_0B942B

  loc_0B945F:
    LDA $24
    AND #$0040
    BNE loc_0B9477
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #05, &code_0B950A )
    INC $24
    COP [SetEntryExitNow] ( @code_0B942B )

  loc_0B9477:
    STZ $24
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    BRA code_0B942B

  code_0B9480:
    COP [RngByte]
    AND #$0007
    STA $08
    COP [SetEntryExit]
    JSR $&code_0B9638
    BPL loc_0B9492
    EOR #$FFFF
    INC 

  loc_0B9492:
    CMP #$0040
    BCC loc_0B949A
    LDA #$0040

  loc_0B949A:
    EOR #$FFFF
    INC 
    CLC 
    ADC $14
    STA $moveXAlt, X
    LDA #$0008
    TSB $10
    COP [MoveToward] ( #15, #01 )
    LDA #$0008
    TRB $10

  code_0B94B3:
    COP [BranchOnPlayerX] ( #$0000, &code_0B94BD, &code_0B94BD, &code_0B942B )
} >
]

code_0B94BD {
    COP [BranchIfPlayerInRelTiles] ( #FB, #FF, #00, #00, &code_0B957A )
    BRA code_0B9480

  code_0B94C7:
    COP [RngByte]
    AND #$0007
    STA $08
    COP [SetEntryExit]
    JSR $&code_0B9638
    BPL loc_0B94D9
    EOR #$FFFF
    INC 

  loc_0B94D9:
    CMP #$0040
    BCC loc_0B94E1
    LDA #$0040

  loc_0B94E1:
    CLC 
    ADC $14
    STA $moveXAlt, X
    LDA #$0008
    TSB $10
    COP [MoveToward] ( #95, #01 )
    LDA #$0008
    TRB $10

  code_0B94F6:
    COP [BranchOnPlayerX] ( #$0000, &code_0B942B, &code_0B9500, &code_0B9500 )
}

code_0B9500 {
    COP [BranchIfPlayerInRelTiles] ( #00, #FF, #05, #00, &code_0B959C )
    BRA code_0B94C7
}

code_0B950A {
    COP [RngByte]
    AND #$0003
    STA $08
    COP [SetEntryExit]
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #1D )
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]
    COP [SpawnMarkedAfter] ( @code_0B96B1, #$2000 )
    LDA #$4000
    TSB $12
    LDA #$0008
    TSB $10
    COP [StageSpriteMoveXY] ( #1B, #48, #49 )
    COP [AnimOnce]
    LDA #$4000
    TRB $12
    LDA #$0008
    TRB $10
    COP [KillNext]
    JMP $&code_0B9480
}

code_0B9547 {
    COP [RngByte]
    AND #$0003
    STA $08
    COP [SetEntryExit]
    COP [StageSpriteFrame] ( #94 )
    COP [AnimOnce]
    COP [PlaySoundCh1] ( #1D )
    COP [StageSpriteFrame] ( #97 )
    COP [AnimOnce]
    COP [SpawnMarkedAfter] ( @code_0B964E, #$2000 )
    LDA #$0008
    TSB $10
    COP [StageSpriteMoveXY] ( #9B, #48, #49 )
    COP [AnimOnce]
    LDA #$0008
    TRB $10
    COP [KillNext]
    JMP $&code_0B94C7
}

code_0B957A {
    COP [StageSpriteFrame] ( #16 )
    COP [AnimOnce]
    COP [SpawnMarkedAfter] ( @code_0B96B1, #$2000 )
    LDA #$4000
    TSB $12
    COP [StageSpriteMoveXY] ( #1B, #48, #49 )
    COP [AnimOnce]
    LDA #$4000
    TRB $12
    COP [KillNext]
    JMP $&code_0B94B3
}

code_0B959C {
    COP [StageSpriteFrame] ( #96 )
    COP [AnimOnce]
    COP [SpawnMarkedAfter] ( @code_0B964E, #$2000 )
    LDA #$0008
    TSB $10
    COP [StageSpriteMoveXY] ( #9B, #48, #49 )
    COP [AnimOnce]
    LDA #$0008
    TRB $10
    COP [KillNext]
    JMP $&code_0B94F6
}

code_0B95BE {
    LDA #$8000
    TSB $joypadMaskStd
    COP [SetDeathCallback] ( @code_0B962D )

  loc_0B95C9:
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    BRA loc_0B95C9
}

code_0B95D0 {
    COP [SetDeathCallback] ( $000000 )
    LDA #$0200
    TRB $10
    LDA $14
    CLC 
    ADC $26
    STA $moveXAlt, X
    LDA $16
    CLC 
    ADC $26
    STA $moveYAlt, X
    LDA #$0010
    TRB $12
    LDA #$0008
    TSB $10
    COP [MoveToward] ( #1A, #02 )
    COP [StageSpriteMoveXY] ( #1A, #47, #45 )
    COP [AnimOnce]
    LDA #$0008
    TRB $10

  code_0B9606:
    COP [SetEntryExit]

  loc_0B9608:
    COP [BranchIfOffscreen] ( &code_0B9606 )
    COP [BranchIfSolid] ( &code_0B9613 )
    JMP $&code_0B942B
}

code_0B9613 {
    PHX 
    TYX 
    LDA $collisionLayer, X
    PLX 
    AND #$00FF
    BIT #$000F
    BNE loc_0B9625
    JMP $&code_0B942B

  loc_0B9625:
    COP [StageSpriteMoveY] ( #1A, #01 )
    COP [AnimOnce]
    BRA loc_0B9608
}

code_0B962D {
    LDA #$8000
    TRB $joypadMaskStd
    COP [JumpScript] ( @StandardEnemyDefeatHandler )
}

code_0B9638 {
    LDA $playerYPos
    CLC 
    ADC #$0010
    STA $moveYAlt, X
    LDA $playerXPos
    CLC 
    ADC #$0008
    SEC 
    SBC $14
    RTS 
}

code_0B964E {
    LDY $playerActor
    LDA $0010, Y
    BIT #$0040
    BEQ loc_0B965C
    COP [SetEntryContinue]
    RTL 

  loc_0B965C:
    BIT #$2280
    BEQ loc_0B9662
    RTL 

  loc_0B9662:
    LDA #$0000
    JSR $&code_0B9820
    CLC 
    ADC #$0014
    BPL loc_0B9672
    EOR #$FFFF
    INC 

  loc_0B9672:
    CMP #$0003
    BCC loc_0B9678
    RTL 

  loc_0B9678:
    LDA $0016, Y
    SEC 
    SBC #$0004
    SEC 
    SBC $001C
    BPL loc_0B9689
    EOR #$FFFF
    INC 

  loc_0B9689:
    CMP #$000B
    BCC loc_0B968F
    RTL 

  loc_0B968F:
    PHY 
    LDA #$0001
    LDY #$0004
    JSL $@ApplyPlayerHitstun
    PLY 
    LDA $0012, Y
    ORA #$0010
    STA $0012, Y
    LDA #$&code_0B95BE
    JSR $&code_0B97F8
    BCC loc_0B96AD
    RTL 

  loc_0B96AD:
    STZ $2C
    BRA loc_0B970C
}

code_0B96B1 {
    LDY $playerActor
    LDA $0010, Y
    BIT #$0040
    BEQ loc_0B96BF
    COP [SetEntryContinue]
    RTL 

  loc_0B96BF:
    BIT #$2280
    BEQ loc_0B96C5
    RTL 

  loc_0B96C5:
    LDA #$0013
    JSR $&code_0B9820
    SEC 
    SBC #$0010
    BPL loc_0B96D5
    EOR #$FFFF
    INC 

  loc_0B96D5:
    CMP #$0003
    BCC loc_0B96DB
    RTL 

  loc_0B96DB:
    LDA $0016, Y
    SEC 
    SBC #$0004
    SEC 
    SBC $001C
    BPL loc_0B96EC
    EOR #$FFFF
    INC 

  loc_0B96EC:
    CMP #$000B
    BCC loc_0B96F2
    RTL 

  loc_0B96F2:
    PHY 
    LDA #$0001
    LDY #$0004
    JSL $@ApplyPlayerHitstun
    PLY 
    LDA #$&code_0B95BE
    JSR $&code_0B97F8
    BCC loc_0B9707
    RTL 

  loc_0B9707:
    LDA #$0001
    STA $2C

  loc_0B970C:
    LDA $0012, Y
    AND #$9FFF
    ORA #$0002
    STA $0012, Y
    PHX 
    LDX $playerActor
    LDA $0014, Y
    SEC 
    SBC $0014, X
    BPL loc_0B9729
    EOR #$FFFF
    INC 

  loc_0B9729:
    STA $14
    LDA $0016, Y
    SEC 
    SBC $0016, X
    BPL loc_0B9738
    EOR #$FFFF
    INC 

  loc_0B9738:
    STA $16
    PLX 
    STZ $2A
    STZ $28
    COP [SetEntryContinue]
    LDY $playerActor
    LDA $0010, Y
    BIT #$2040
    BEQ loc_0B974F
    JMP $&code_0B97CF

  loc_0B974F:
    LDA $28
    INC 
    STA $28
    CMP #$0078
    BCC loc_0B9765
    STZ $28
    LDA #$8001
    LDY #$0004
    JSL $@ApplyPlayerHitstun

  loc_0B9765:
    PHX 
    LDX $playerActor
    LDY $24
    LDA $2C
    BEQ loc_0B977D
    LDA $joypadCurrent
    BIT #$0100
    BEQ loc_0B9787
    INC $2A
    STZ $2C
    BRA loc_0B9787

  loc_0B977D:
    LDA $joypadCurrent
    BIT #$0200
    BEQ loc_0B9787
    INC $2C

  loc_0B9787:
    LDA $2A
    CMP #$0004
    BCS loc_0B97CC
    LDA $2C
    BNE loc_0B97AF
    LDA $000E, Y
    ORA #$4000
    STA $000E, Y
    LDA $0014, X
    SEC 
    SBC $14
    STA $0014, Y
    LDA $0016, X
    SEC 
    SBC $16
    STA $0016, Y
    PLX 
    RTL 

  loc_0B97AF:
    LDA $000E, Y
    AND #$BFFF
    STA $000E, Y
    LDA $0014, X
    CLC 
    ADC $14
    STA $0014, Y
    LDA $0016, X
    SEC 
    SBC $16
    STA $0016, Y
    PLX 
    RTL 

  loc_0B97CC:
    PLX 
    COP [SetEntryExit]
}

code_0B97CF {
    LDY $24
    LDA #$&code_0B95D0
    JSR $&code_0B97F8
    BCS loc_0B97F0
    LDA $0012, Y
    AND #$BFFD
    STA $0012, Y
    LDA $playerYPos
    CLC 
    ADC #$0010
    SEC 
    SBC $0016, Y
    STA $0026, Y

  loc_0B97F0:
    LDA #$8000
    TRB $joypadMaskStd
    COP [Die]
}

code_0B97F8 {
    PHA 
    LDA $0010, Y
    BIT #$0040
    BNE loc_0B981B
    SEP #$20
    LDA $0002, Y
    CMP #$8B
    BNE loc_0B981B
    REP #$20
    PLA 
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002C, Y
    CLC 
    RTS 

  loc_0B981B:
    REP #$20
    PLA 
    SEC 
    RTS 
}

code_0B9820 {
    CLC 
    ADC $playerXPos
    STA $0018
    LDA $playerYPos
    CLC 
    ADC #$0004
    STA $001C
    LDY $24
    LDA $0014, Y
    SEC 
    SBC $0018
    RTS 
}