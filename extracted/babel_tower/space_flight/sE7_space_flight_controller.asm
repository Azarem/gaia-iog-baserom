?INCLUDE 'spriteset_enemies'

!playerActor                    09AA
!playerFlags                    09AE
!characterForm                  0AD4
!TM                             212C
!TS                             212D
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

sE7_space_flight_controller [
  actor-def < #00, #10, #29, {

  code_0CEDC8:
    COP [SpawnAfter] ( @code_0CEE9B )
    LDA #$0002
    STA $characterForm
    LDY $playerActor
    LDA #$&code_0CED4C
    STA $0000, Y
    LDA #$*code_0CED4C
    STA $0002, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags
    COP [SetEntryContinue]
    COP [RngByte]
    AND #$0007
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0CEDFE )
} >
]

code_list_0CEDFE [
  &code_0CEE0E   ;00
  &code_0CEE0E   ;01
  &code_0CEE17   ;02
  &code_0CEE17   ;03
  &code_0CEE20   ;04
  &code_0CEE20   ;05
  &code_0CEE29   ;06
  &code_0CEE29   ;07
]

code_0CEE0E {
    COP [SpawnAfterFlags] ( @code_0CEE3E, #$0902 )
    BRA loc_0CEE32
}

code_0CEE17 {
    COP [SpawnAfterFlags] ( @code_0CEE43, #$0902 )
    BRA loc_0CEE32
}

code_0CEE20 {
    COP [SpawnAfterFlags] ( @code_0CEE48, #$0902 )
    BRA loc_0CEE32
}

code_0CEE29 {
    COP [SpawnAfterFlags] ( @code_0CEE4D, #$0902 )
    BRA loc_0CEE32

  loc_0CEE32:
    COP [RngByte]
    AND #$0007
    CLC 
    ADC #$0010
    STA $08
    RTL 
}

code_0CEE3E {
    COP [StageSprAndHitbox] ( #00 )
    BRA loc_0CEE50
}

code_0CEE43 {
    COP [StageSprAndHitbox] ( #01 )
    BRA loc_0CEE50
}

code_0CEE48 {
    COP [StageSprAndHitbox] ( #02 )
    BRA loc_0CEE50
}

code_0CEE4D {
    COP [StageSprAndHitbox] ( #03 )

  loc_0CEE50:
    COP [OrActorFlags] ( #$0080 )
    LDA #$0030
    TSB $12
    COP [RngByte]
    STA $14
    CMP #$006A
    BCC loc_0CEE67
    CMP #$008A
    BCC loc_0CEE99

  loc_0CEE67:
    LDA #$FFC0
    STA $16
    LDA #$0000
    STA $moveXAlt, X
    LDA $0410
    LSR 
    BCS loc_0CEE82
    LDA #$000B
    STA $moveYAlt, X
    BRA loc_0CEE89

  loc_0CEE82:
    LDA #$0009
    STA $moveYAlt, X

  loc_0CEE89:
    COP [ReloadForceMove]
    COP [StageSpriteFrame] ( #FF )
    COP [AnimOnce]
    LDA $16
    BMI loc_0CEE89
    CMP #$0180
    BCC loc_0CEE89

  loc_0CEE99:
    COP [Die]
}

code_0CEE9B {
    SEP #$20
    LDA #$15
    STA $TM
    LDA #$00
    STA $TS
    REP #$20
    RTL 
}
---------------------------------------------

code_0CED4C {
    LDA #$0008
    TRB $10
    COP [StagePlayerSprite] ( #1B )
    LDA $0E
    ORA #$8000
    STA $0E
    LDA #$007A
    STA $14
    LDA #$00BB
    STA $16
    LDA #$0384
    STA $26

  loc_0CED6A:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0CED6A
    LDA $08
    STZ $08
    STA $24

  loc_0CED76:
    COP [SetEntryExit]
    DEC $26
    BMI loc_0CED82
    DEC $24
    BPL loc_0CED76
    BRA loc_0CED6A

  loc_0CED82:
    COP [StagePlayerMoveY] ( #1B, #08 )
    COP [AnimOnce]
    COP [SpawnAfterFlags] ( @code_0CEDAB, #$0300 )
    LDA $16
    BPL loc_0CED82
    BPL loc_0CED99
    EOR #$FFFF
    INC 

  loc_0CED99:
    CMP #$0030
    BCC loc_0CED82
    COP [QueueMapChange] ( #E8, #$0000, #$0000, #80, #$2100 )
    COP [SetEntryContinue]
    RTL 
}

code_0CEDAB {
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [RngByte]
    AND #$000F
    SEC 
    SBC #$0008
    CLC 
    ADC $14
    STA $14
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [Die]
}