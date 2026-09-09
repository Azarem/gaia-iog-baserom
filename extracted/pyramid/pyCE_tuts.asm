!playerActor                    09AA
!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

pyCE_tuts [
  actor-def < #00, #00, #00, {

  code_0BC3A0:
    LDA #$0180
    TSB $12
    LDA #$1010
    STA $20
    LDA #$0428
    STA $22
    COP [SpawnMarkedAfter] ( @code_0BC529, #$2000 )

  loc_0BC3B6:
    COP [WaitWhileOffscreen] ( #07 )

  code_0BC3B9:
    LDA $10
    BIT #$4000
    BNE loc_0BC3B6
    COP [BranchIfPlayerNear] ( #04, &code_0BC4B1 )
    COP [BranchNearerAxis] ( &code_0BC3CB, &code_0BC417 )
} >
]

code_0BC3CB {
    COP [BranchOnPlayerX] ( #$0000, &code_0BC3D5, &code_0BC3D5, &code_0BC3F6 )
}

code_0BC3D5 {
    COP [LoopInit] ( #02 )
    COP [BranchIfSolidWest] ( &code_0BC465 )
    COP [StageSpriteMoveX] ( #05, #02 )
    COP [AnimOnce]
    COP [BranchIfSolidWest] ( &code_0BC465 )
    COP [StageSpriteMoveX] ( #15, #02 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0BC3F2, &code_0BC417 )
}

code_0BC3F2 {
    COP [LoopNext]
    BRA code_0BC3B9
}

code_0BC3F6 {
    COP [LoopInit] ( #03 )
    COP [BranchIfSolidEast] ( &code_0BC465 )
    COP [StageSpriteMoveX] ( #85, #01 )
    COP [AnimOnce]
    COP [BranchIfSolidEast] ( &code_0BC465 )
    COP [StageSpriteMoveX] ( #95, #01 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0BC413, &code_0BC417 )
}

code_0BC413 {
    COP [LoopNext]
    BRA code_0BC3B9
}

code_0BC417 {
    COP [BranchOnPlayerY] ( #$0000, &code_0BC421, &code_0BC421, &code_0BC443 )
}

code_0BC421 {
    COP [LoopInit] ( #03 )
    COP [BranchIfSolidNorth] ( &code_0BC465 )
    COP [StageSpriteMoveY] ( #04, #02 )
    COP [AnimOnce]
    COP [BranchIfSolidNorth] ( &code_0BC465 )
    COP [StageSpriteMoveY] ( #14, #02 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0BC3CB, &code_0BC43E )
}

code_0BC43E {
    COP [LoopNext]
    JMP $&code_0BC3B9
}

code_0BC443 {
    COP [LoopInit] ( #03 )
    COP [BranchIfSolidSouth] ( &code_0BC465 )
    COP [StageSpriteMoveY] ( #03, #01 )
    COP [AnimOnce]
    COP [BranchIfSolidSouth] ( &code_0BC465 )
    COP [StageSpriteMoveY] ( #13, #01 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0BC3CB, &code_0BC460 )
}

code_0BC460 {
    COP [LoopNext]
    JMP $&code_0BC3B9
}

code_0BC465 {
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0BC475 )
}

code_list_0BC475 [
  &code_0BC47D   ;00
  &code_0BC48A   ;01
  &code_0BC497   ;02
  &code_0BC4A4   ;03
]

code_0BC47D {
    COP [BranchIfSolidWest] ( &code_0BC465 )
    COP [StageSpriteMoveX] ( #05, #02 )
    COP [AnimOnce]
    JMP $&code_0BC3B9
}

code_0BC48A {
    COP [BranchIfSolidEast] ( &code_0BC465 )
    COP [StageSpriteMoveX] ( #95, #01 )
    COP [AnimOnce]
    JMP $&code_0BC3B9
}

code_0BC497 {
    COP [BranchIfSolidNorth] ( &code_0BC465 )
    COP [StageSpriteMoveY] ( #14, #02 )
    COP [AnimOnce]
    JMP $&code_0BC3B9
}

code_0BC4A4 {
    COP [BranchIfSolidSouth] ( &code_0BC465 )
    COP [StageSpriteMoveY] ( #13, #01 )
    COP [AnimOnce]
    JMP $&code_0BC3B9
}

code_0BC4B1 {
    COP [SetEntryExit]
    COP [CardinalToPlayer]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0BC4C1 )
}

code_list_0BC4C1 [
  &code_0BC497   ;00
  &code_0BC4F9   ;01
  &code_0BC4A4   ;02
  &code_0BC4C9   ;03
]

code_0BC4C9 {
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #10 )
    COP [AnimOnce]
    LDA $14
    CLC 
    ADC #$FFD0
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    LDA #$0008
    TSB $10
    COP [MoveToward] ( #11, #03 )
    LDA #$0008
    TRB $10
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    JMP $&code_0BC3B9
}

code_0BC4F9 {
    COP [StageSpriteFrame] ( #86 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #90 )
    COP [AnimOnce]
    LDA $14
    CLC 
    ADC #$0030
    STA $moveXAlt, X
    LDA $16
    STA $moveYAlt, X
    LDA #$0008
    TSB $10
    COP [MoveToward] ( #91, #03 )
    LDA #$0008
    TRB $10
    COP [StageSpriteFrame] ( #92 )
    COP [AnimOnce]
    JMP $&code_0BC3B9
}

code_0BC529 {
    LDY $24
    LDA $0010, Y
    AND #$FFEF
    STA $0010, Y
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    LDY $playerActor
    LDA $0010, Y
    BIT #$0140
    BEQ loc_0BC54A
    RTL 

  loc_0BC54A:
    LDY $24
    LDA $0028, Y
    AND #$000F
    CMP #$0006
    BCC loc_0BC558
    RTL 

  loc_0BC558:
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0BC561 )
}

code_list_0BC561 [
  &code_0BC56D   ;00
  &code_0BC575   ;01
  &code_0BC57D   ;02
  &code_0BC56D   ;03
  &code_0BC575   ;04
  &code_0BC57D   ;05
]

code_0BC56D {
    COP [CardinalToPlayer]
    CMP #$0002
    BEQ loc_0BC597
    RTL 
}

code_0BC575 {
    COP [CardinalToPlayer]
    CMP #$0000
    BEQ loc_0BC597
    RTL 
}

code_0BC57D {
    LDY $24
    LDA $000E, Y
    BIT #$4000
    BNE loc_0BC58F
    COP [CardinalToPlayer]
    CMP #$0003
    BEQ loc_0BC597
    RTL 

  loc_0BC58F:
    COP [CardinalToPlayer]
    CMP #$0001
    BEQ loc_0BC597
    RTL 

  loc_0BC597:
    LDY $24
    LDA $0010, Y
    ORA #$0010
    STA $0010, Y
    RTL 
}