; Draco enemy — dragon creature in the Angel Village tunnels (~263 lines).
; 
; Medium enemy with breath attack projectiles. Moves through
; tunnels with directional sprite animation, periodically
; stopping to fire a breath weapon toward the player. Uses
; BranchOnPlayer* for aiming direction.
---------------------------------------------

?INCLUDE 'ActorMidpointCalc'
?INCLUDE 'spriteset_enemies'
?INCLUDE 'StandardEnemyDefeatHandler'

!playerXPos                     09A2
!playerActor                    09AA
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

av6E_draco [
  actor-def < #15, #02, #00, {

  code_0AEF36:
    COP [SolidHighHere]
    LDA #$0001
    TSB $12
    COP [SetDeathCallback] ( @code_0AF06B )
    LDA $14
    STA $7F100C, X
    LDA $16
    STA $7F100E, X
    COP [SpawnAfterFlags] ( @code_0AF032, #$0301 )
    LDA #$0003
    STA $24

  loc_0AEF5A:
    COP [SpawnAfterFlags] ( @code_0AEFF0, #$0202 )
    DEC $24
    BPL loc_0AEF5A
    COP [OrActorFlags] ( #$0020 )

  loc_0AEF69:
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #04, &code_0AEF76 )
    RTL 
} >
]

code_0AEF76 {
    LDA #$0002
    TSB $12
    COP [BranchOnPlayerX] ( #$0000, &code_0AEF87, &code_0AEF87, &code_0AEF85 )
}

code_0AEF85 {
    COP [SetHFlip]
}

code_0AEF87 {
    COP [StageSpriteFrame] ( #16 )
    COP [AnimOnce]
    JSR $&sub_0AFD26
    COP [CallScript] ( &code_0AEFC0 )
    JSR $&sub_0AFD26
    COP [CallScript] ( &code_0AEFC0 )
    COP [BranchIfPlayerNear] ( #04, &code_0AEFA1 )
    BRA loc_0AEF69
}

code_0AEFA1 {
    LDY $playerActor
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    STA $moveYAlt, X
    COP [CallScript] ( &code_0AEFBA )
    COP [ClearHFlip]
    BRA loc_0AEF69
}

code_0AEFBA {
    COP [MoveToward] ( #13, #04 )
    BRA loc_0AEFC4
}

code_0AEFC0 {
    COP [MoveToward] ( #13, #02 )

  loc_0AEFC4:
    COP [StageSpriteLoop] ( #17, #02 )
    COP [AnimLoop]

  loc_0AEFCA:
    LDA $7F100C, X
    STA $moveXAlt, X
    LDA $7F100E, X
    STA $moveYAlt, X
    COP [MoveToward] ( #12, #03 )
    LDA $7F100C, X
    CMP $14
    BNE loc_0AEFCA
    LDA $7F100E, X
    CMP $16
    BNE loc_0AEFCA
    COP [RestoreSavedPtr]
}

code_0AEFF0 {
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    LDA $0E
    STA $26

  loc_0AEFF9:
    COP [SetEntryContinue]
    JSL $@ActorMidpointCalc
    LDY $24
    LDA $000E, Y
    STA $0E
    LDA $0010, Y
    BIT #$0080
    BNE loc_0AF00F
    RTL 

  loc_0AF00F:
    COP [SetEntryContinue]
    JSL $@ActorMidpointCalc
    LDY $24
    LDA $0010, Y
    BIT #$0080
    BEQ loc_0AEFF9
    LDA $0036
    LSR 
    BCC loc_0AF02D
    LDA $26
    ORA #$0200
    STA $0E
    RTL 

  loc_0AF02D:
    LDA $26
    STA $0E
    RTL 
}

code_0AF032 {
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    LDA $0E
    STA $26

  loc_0AF03B:
    LDA $26
    STA $0E
    COP [SetEntryContinue]
    LDY $24
    LDA $0010, Y
    BIT #$0080
    BNE loc_0AF04C
    RTL 

  loc_0AF04C:
    COP [SetEntryContinue]
    LDY $24
    LDA $0010, Y
    BIT #$0080
    BEQ loc_0AF03B
    LDA $0036
    LSR 
    BCC loc_0AF066
    LDA $26
    ORA #$0200
    STA $0E
    RTL 

  loc_0AF066:
    LDA $26
    STA $0E
    RTL 
}

code_0AF06B {
    LDA #$0004
    STA $000E
    LDY $06
    LDA #$0004
    STA $0000

  loc_0AF079:
    LDA #$&loc_0AF0B4
    STA $0000, Y
    LDA $0000
    STA $0008, Y
    CLC 
    ADC #$0008
    STA $0000
    LDA $0006, Y
    TAY 
    DEC $000E
    BPL loc_0AF079
    LDA $14
    PHA 
    LDA $16
    PHA 
    LDA $7F100C, X
    STA $14
    LDA $7F100E, X
    STA $16
    COP [ClearLowHere]
    PLA 
    STA $16
    PLA 
    STA $14
    COP [JumpScript] ( @StandardEnemyDefeatHandler )

  loc_0AF0B4:
    LDA $26
    STA $0E
    COP [PlaySoundCh1] ( #06 )
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [Die]
}
---------------------------------------------

sub_0AFD26 {
    LDY $playerActor
    LDA $16
    SEC 
    SBC $0016, Y
    BPL loc_0AFD35
    SEC 
    ROR 
    BRA loc_0AFD36

  loc_0AFD35:
    LSR 

  loc_0AFD36:
    CLC 
    ADC $16
    STA $moveYAlt, X
    COP [RngByte]
    AND #$001F
    PHA 
    LDA $14
    CMP $playerXPos
    BPL loc_0AFD51
    PLA 
    EOR #$FFFF
    INC 
    BRA loc_0AFD52

  loc_0AFD51:
    PLA 

  loc_0AFD52:
    CLC 
    ADC $14
    STA $moveXAlt, X
    RTS 
}