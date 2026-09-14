?INCLUDE 'enemy_stats_table'
?INCLUDE 'StandardEnemyDefeatHandler'

!playerXPos                     09A2
!playerYPos                     09A4
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

pyD2_haunt [
  actor-def < #0A, #00, #01, {

  code_0BC187:
    COP [SetDeathCallback] ( @code_0BC2C2 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #03, &code_0BC194 )
    RTL 
} >
]

code_0BC194 {
    COP [BranchIfSolidOffset] ( #00, #01, &code_0BC1A0 )
    COP [StageSpriteMoveY] ( #0A, #01 )
    COP [AnimOnce]
}

code_0BC1A0 {
    LDA #$0100
    TRB $10
    BRA code_0BC1B4
}

pyD5_haunt2 [
  actor-def < #07, #00, #00, {

  code_0BC1AA:
    COP [SetDeathCallback] ( @code_0BC2C2 )

  loc_0BC1AF:
    COP [SetEntryExit]
    COP [WaitWhileOffscreen] ( #08 )

  code_0BC1B4:
    LDA $14
    SEC 
    SBC $playerXPos
    BPL loc_0BC1C0
    EOR #$FFFF
    INC 

  loc_0BC1C0:
    CMP #$0100
    BCS loc_0BC1AF
    LDA $16
    SEC 
    SBC $playerYPos
    BPL loc_0BC1D1
    EOR #$FFFF
    INC 

  loc_0BC1D1:
    CMP #$0100
    BCS loc_0BC1AF
    COP [BranchNearerAxis] ( &code_0BC1DC, &code_0BC228 )
} >
]

code_0BC1DC {
    COP [BranchOnPlayerX] ( #$0000, &code_0BC1E6, &code_0BC1E6, &code_0BC207 )
}

code_0BC1E6 {
    COP [LoopInit] ( #03 )
    COP [BranchIfSolidWest] ( &code_0BC276 )
    COP [StageSpriteMoveX] ( #0C, #02 )
    COP [AnimOnce]
    COP [BranchIfSolidWest] ( &code_0BC276 )
    COP [StageSpriteMoveX] ( #18, #02 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0BC203, &code_0BC228 )
}

code_0BC203 {
    COP [LoopNext]
    BRA code_0BC1B4
}

code_0BC207 {
    COP [LoopInit] ( #03 )
    COP [BranchIfSolidEast] ( &code_0BC276 )
    COP [StageSpriteMoveX] ( #8C, #01 )
    COP [AnimOnce]
    COP [BranchIfSolidEast] ( &code_0BC276 )
    COP [StageSpriteMoveX] ( #98, #01 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0BC224, &code_0BC228 )
}

code_0BC224 {
    COP [LoopNext]
    BRA code_0BC1B4
}

code_0BC228 {
    COP [BranchOnPlayerY] ( #$0000, &code_0BC232, &code_0BC232, &code_0BC254 )
}

code_0BC232 {
    COP [LoopInit] ( #03 )
    COP [BranchIfSolidNorth] ( &code_0BC276 )
    COP [StageSpriteMoveY] ( #0B, #02 )
    COP [AnimOnce]
    COP [BranchIfSolidNorth] ( &code_0BC276 )
    COP [StageSpriteMoveY] ( #17, #02 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0BC24F, &code_0BC1DC )
}

code_0BC24F {
    COP [LoopNext]
    JMP $&code_0BC1B4
}

code_0BC254 {
    COP [LoopInit] ( #03 )
    COP [BranchIfSolidSouth] ( &code_0BC276 )
    COP [StageSpriteMoveY] ( #0A, #01 )
    COP [AnimOnce]
    COP [BranchIfSolidSouth] ( &code_0BC276 )
    COP [StageSpriteMoveY] ( #16, #01 )
    COP [AnimOnce]
    COP [BranchNearerAxis] ( &code_0BC271, &code_0BC1DC )
}

code_0BC271 {
    COP [LoopNext]
    JMP $&code_0BC1B4
}

code_0BC276 {
    COP [SetEntryExit]
    COP [RngByte]
    AND #$0003
    STA $0000
    COP [SwitchCase] ( #$0000, &code_list_0BC286 )
}

code_list_0BC286 [
  &code_0BC28E   ;00
  &code_0BC29B   ;01
  &code_0BC2A8   ;02
  &code_0BC2B5   ;03
]

code_0BC28E {
    COP [BranchIfSolidWest] ( &code_0BC276 )
    COP [StageSpriteMoveX] ( #18, #02 )
    COP [AnimOnce]
    JMP $&code_0BC1B4
}

code_0BC29B {
    COP [BranchIfSolidEast] ( &code_0BC276 )
    COP [StageSpriteMoveX] ( #8C, #01 )
    COP [AnimOnce]
    JMP $&code_0BC1B4
}

code_0BC2A8 {
    COP [BranchIfSolidNorth] ( &code_0BC276 )
    COP [StageSpriteMoveY] ( #0B, #02 )
    COP [AnimOnce]
    JMP $&code_0BC1B4
}

code_0BC2B5 {
    COP [BranchIfSolidSouth] ( &code_0BC276 )
    COP [StageSpriteMoveY] ( #0A, #01 )
    COP [AnimOnce]
    JMP $&code_0BC1B4
}

code_0BC2C2 {
    COP [SpawnAfterFlags] ( @code_0BC2E4, #$0000 )
    COP [StageSpriteFrame] ( #0E )
    COP [AnimOnce]
    COP [JumpScript] ( @StandardEnemyDefeatHandler )

  loc_0BC2D3:
    ORA $0000
    LDA $14
    STA $7F100C, X
    LDA $16
    STA $7F100E, X
    BRA loc_0BC334
}

code_0BC2E4 {
    COP [OrActorFlags] ( #$0090 )
    LDA #$&enemy_stats_table+134
    STA $statsPtr, X
    LDA $&enemy_stats_table+134
    AND #$00FF
    STA $currentHp, X
    LDA $14
    STA $7F100C, X
    LDA $16
    STA $7F100E, X
    COP [StageSprAndHitbox] ( #0D )
    COP [WaitByte] ( #17 )
    COP [PlaySoundBoth] ( #$0606 )
    COP [LoopInit] ( #03 )
    COP [StageForceMoveY] ( #0C )
    COP [LoopNext]
    COP [LoopInit] ( #03 )
    COP [StageForceMoveY] ( #08 )
    COP [LoopNext]
    COP [LoopInit] ( #03 )
    COP [StageForceMoveY] ( #04 )
    COP [LoopNext]
    COP [LoopInit] ( #03 )
    COP [StageForceMoveY] ( #02 )
    COP [LoopNext]
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]

  loc_0BC334:
    COP [BranchIfOffscreen] ( &code_0BC342 )

  loc_0BC338:
    COP [WaitWhileOffscreen] ( #15 )

  loc_0BC33B:
    LDA $10
    BIT #$4000
    BNE loc_0BC338
}

code_0BC342 {
    LDA $7F100C, X
    SEC 
    SBC $playerXPos
    BPL loc_0BC350
    EOR #$FFFF
    INC 

  loc_0BC350:
    CMP #$0070
    BCS loc_0BC396
    LDA $7F100E, X
    SEC 
    SBC $playerYPos
    BPL loc_0BC363
    EOR #$FFFF
    INC 

  loc_0BC363:
    CMP #$0070
    BCS loc_0BC396
    COP [RngByte]
    AND #$003F
    CLC 
    ADC $playerXPos
    SEC 
    SBC #$001F
    STA $moveXAlt, X
    LDA $0410
    LSR 
    LSR 
    LSR 
    AND #$001F
    SEC 
    SBC #$000F
    CLC 
    ADC $playerYPos
    CLC 
    ADC #$0010
    STA $moveYAlt, X
    COP [MoveToward] ( #FF, #02 )

  loc_0BC396:
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    BRA loc_0BC33B
}