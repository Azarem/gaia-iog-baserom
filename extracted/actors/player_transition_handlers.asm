?INCLUDE 'player_character'
?INCLUDE 'table_0EE000'

!joypadMaskStd                  065A
!layerPriorityFlag              06EE
!playerFlags                    09AE

---------------------------------------------

player_transition_handlers {
    COP [SpawnLastRel] ( @code_00C423, #00, #00, #$0302 )
    COP [Die]
}

code_00C423 {
    COP [PlaySoundCh2] ( #09 )
    COP [SetMetasprite] ( @table_0EE000 )
    COP [StageSpriteFrame] ( #2A )
    COP [AnimOnce]
    COP [Die]

  loc_00C432:
    COP [BranchIfFlagByte] ( #00, #01, &code_00C43D )
    COP [StagePlayerSprite] ( #01 )
    BRA loc_00C440
}

code_00C43D {
    COP [StagePlayerSprite] ( #11 )

  loc_00C440:
    COP [SetEntryContinue]
    COP [AnimOnce]
    BRA loc_00C440

  loc_00C446:
    LDA #$0200
    TSB $10
    COP [SetPlayerBodySprite] ( #04 )

  loc_00C44E:
    COP [StageSpriteFrame] ( #1F )
    COP [AnimOnce]
    BRA loc_00C44E

  loc_00C455:
    LDA #$0200
    TRB $10

  loc_00C45A:
    JML $@player_character.PlayerIdleEntry
}

code_00C45E {
    COP [SetPlayerBodySprite] ( #04 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #20 )
    COP [AnimOnce]
    RTL 
}

code_00C469 {
    JML $@player_character.PlayerIdleEntry
}

code_00C46D {
    COP [SetPlayerBodySprite] ( #04 )
    COP [StageSpriteFrame] ( #20 )
    COP [AnimOnce]
    JML $@player_character.PlayerIdleEntry
}

code_00C479 {
    LDA #$CFF0
    TSB $joypadMaskStd
    LDA #$0800
    TSB $playerFlags
    LDA #$0008
    TRB $10
    LDA #$2200
    TSB $10
    LDA #$0200
    TSB $layerPriorityFlag
    COP [WaitByte] ( #03 )
    COP [AddPosition] ( #00, #80 )
    LDA #$2000
    TRB $10
    COP [LoopInit] ( #08 )
    COP [StagePlayerMoveY] ( #19, #07 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [PlaySoundCh2] ( #2C )
    COP [StagePlayerMoveY] ( #1C, #00 )
    COP [AnimOnce]
    LDA #$0008
    TSB $10
    LDA #$0200
    TRB $10
    LDA #$0200
    TRB $layerPriorityFlag
    LDA #$CFF0
    TRB $joypadMaskStd
    STZ $08
    JML $@player_character.PlayerIdleEntry
}

code_00C4D1 {
    LDA #$0008
    TRB $10
    LDA #$2200
    TSB $10
    COP [AddPosition] ( #00, #C0 )
    COP [SetEntryExit]
    LDA #$0200
    TSB $layerPriorityFlag
    COP [WaitByte] ( #03 )
    COP [AddPosition] ( #00, #40 )
    LDA #$2000
    TRB $10
    COP [ToggleVFlip]
    COP [AddPosition] ( #00, #E0 )
    COP [StagePlayerMoveY] ( #1A, #08 )
    COP [AnimOnce]
    COP [LoopInit] ( #03 )
    COP [StagePlayerMoveY] ( #1B, #08 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [StagePlayerMoveY] ( #1B, #04 )
    COP [AnimOnce]
    COP [StagePlayerMoveY] ( #1B, #04 )
    COP [AnimOnce]
    COP [StagePlayerMoveY] ( #1B, #02 )
    COP [AnimOnce]
    COP [StagePlayerMoveY] ( #1B, #02 )
    COP [AnimOnce]
    COP [ToggleVFlip]
    COP [AddPosition] ( #00, #20 )
    COP [StagePlayerSprite] ( #1E )
    COP [AnimOnce]
    COP [StagePlayerMoveY] ( #1E, #01 )
    COP [AnimOnce]
    COP [StagePlayerMoveY] ( #1E, #03 )
    COP [AnimOnce]
    COP [PlaySoundCh2] ( #2C )
    COP [StagePlayerSprite] ( #1F )
    COP [AnimOnce]
    LDA #$0008
    TSB $10
    LDA #$0200
    TRB $10
    LDA #$0200
    TRB $layerPriorityFlag
    STZ $08
    JML $@player_character.PlayerIdleEntry
}

code_00C557 {
    LDA #$0800
    TSB $playerFlags
    LDA #$0008
    TRB $10
    LDA #$0200
    TSB $10
    COP [SetPlayerBodySprite] ( #08 )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    LDA $14
    STA $24
    LDA $16
    STA $26
    LDA $16
    AND #$FFF0
    STA $16

  loc_00C57E:
    COP [BranchIfSolid] ( &code_00C58C )
    LDA $16
    CLC 
    ADC #$0010
    STA $16
    BRA loc_00C57E
}

code_00C58C {
    COP [BranchIfSolidTypeSouth] ( #04, &code_00C5A1 )
    LDA $24
    STA $14
    LDA $26
    STA $16
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    JMP $&code_00C5E3
}

code_00C5A1 {
    LDA $24
    STA $14
    LDA $26
    STA $16
    LDA #$2000
    TSB $10

  code_00C5AE:
    LDA $16
    AND #$000F
    BNE loc_00C5BA
    COP [BranchIfSolidType] ( #04, &code_00C5C1 )

  loc_00C5BA:
    INC $16
    COP [SetEntryExitNow] ( @code_00C5AE )
}

code_00C5C1 {
    LDA #$2000
    TRB $10
    LDA #$0002
    TSB $10

  loc_00C5CB:
    COP [StageSpriteMoveY] ( #02, #01 )
    COP [AnimOnce]
    COP [BranchIfSolidType] ( #00, &code_00C5D8 )
    BRA loc_00C5CB
}

code_00C5D8 {
    LDA #$0002
    TRB $10
    COP [StagePlayerMoveY] ( #1C, #00 )
    COP [AnimOnce]
}

code_00C5E3 {
    LDA #$0008
    TSB $10
    LDA #$0200
    TRB $10
    STZ $08
    JML $@player_character.PlayerIdleEntry
}