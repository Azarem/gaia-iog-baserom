; Goldcap enemy — mushroom creature in Angkor Wat (~200 lines).
; 
; Mushroom-type enemy with a defensive golden cap that
; blocks attacks from above. Must be hit from the sides.
; Releases spore projectiles when damaged. Uses directional
; defense checks in hit callbacks.
---------------------------------------------

?BANK 0B

?INCLUDE 'ApplyOrbitalOffsetXY'
?INCLUDE 'aw_spirit_follower'
?INCLUDE 'RandomPlayerOffset'

!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

awB1_goldcap [
  actor-def < #16, #00, #00, {

  code_0BBD90:
    LDA #$0010
    TSB $12
    COP [SpawnAfterMarked] ( @RandomPlayerOffset, #$2000 )
    TYA 
    STA $26
    BRA loc_0BBDA5

  code_0BBDA1:
    COP [MoveToward] ( #FF, #02 )

  loc_0BBDA5:
    LDA $14
    STA $7F100C, X
    STA $moveXAlt, X
    LDA $16
    STA $7F100E, X
    STA $moveYAlt, X
    LDA #$2060
    STA $orbitAngle, X
    COP [StageSpriteFrame] ( #16 )
    COP [AnimOnce]

  loc_0BBDC5:
    COP [WaitWhileOffscreen] ( #08 )

  code_0BBDC8:
    LDA $10
    BIT #$4000
    BNE loc_0BBDC5
    LDA #$0000
    STA $orbitDiameter, X
    COP [LoopStart] ( #FF )
    SEP #$20
    LDA $orbitAngle, X
    CLC 
    ADC $0B02
    CLC 
    ADC #$02
    STA $orbitAngle, X
    LDA $7F0011, X
    CLC 
    ADC $0B02
    CLC 
    ADC #$01
    STA $7F0011, X
    LDA $orbitDiameter, X
    BMI loc_0BBE06
    CLC 
    ADC #$03
    STA $orbitDiameter, X

  loc_0BBE06:
    LDA $7F0013, X
    BMI loc_0BBE13
    CLC 
    ADC #$02
    STA $7F0013, X

  loc_0BBE13:
    REP #$20
    LDA $7F100C, X
    STA $14
    LDA $7F100E, X
    STA $16
    JSL $@ApplyOrbitalOffsetXY
    LDA $7F100C, X
    CMP $moveXAlt, X
    BEQ loc_0BBE43
    BPL loc_0BBE3B
    CLC 
    ADC #$0001
    STA $7F100C, X
    BRA loc_0BBE43

  loc_0BBE3B:
    SEC 
    SBC #$0001
    STA $7F100C, X

  loc_0BBE43:
    LDA $7F100E, X
    CMP $moveYAlt, X
    BEQ loc_0BBE61
    BPL loc_0BBE59
    CLC 
    ADC #$0001
    STA $7F100E, X
    BRA loc_0BBE61

  loc_0BBE59:
    SEC 
    SBC #$0001
    STA $7F100E, X

  loc_0BBE61:
    COP [LoopEnd]
    LDA $10
    BIT #$4000
    BEQ loc_0BBE6D
    JMP $&code_0BBDA1

  loc_0BBE6D:
    LDA #$2200
    TSB $10
    COP [SpawnListAppend] ( @aw_spirit_follower, #00, #00, #$0200 )
    TYA 
    STA $7F100C, X
    LDA $26
    STA $0026, Y
    COP [SpawnListAppend] ( @aw_spirit_follower.code_0BBEF7, #00, #00, #$0200 )
    TYA 
    STA $7F100E, X
    LDA $26
    STA $0026, Y
    COP [WaitWord] ( #$0167 )
    LDA $7F100C, X
    TAY 
    LDA #$&code_0BBF8C
    STA $0000, Y
    LDA $7F100E, X
    TAY 
    LDA #$&code_0BBF8C
    STA $0000, Y
    LDA #$0003
    STA $24
    COP [SetEntryHere]
    LDA $24
    BEQ loc_0BBEBE
    RTL 

  loc_0BBEBE:
    LDA $7F100C, X
    PHD 
    TCD 
    TAX 
    COP [MarkDeath]
    LDA $01, S
    TAX 
    LDA $7F100E, X
    TCD 
    TAX 
    COP [MarkDeath]
    PLA 
    TCD 
    TAX 
    LDA #$2200
    TRB $10
    LDA $14
    STA $7F100C, X
    LDA $16
    STA $7F100E, X
    JMP $&code_0BBDC8
} >
]
---------------------------------------------

code_0BBF8C {
    COP [KillNext]
    LDA $7F100C, X
    TAY 
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    STA $moveYAlt, X
    COP [StageMove] ( #FF, #02, #FF )
    COP [TickMove]
    LDA $7F100C, X
    TAY 
    LDA $0024, Y
    LSR 
    STA $0024, Y

  loc_0BBFB4:
    COP [StageSpriteFrame] ( #17 )
    COP [AnimOnce]
    BRA loc_0BBFB4
}