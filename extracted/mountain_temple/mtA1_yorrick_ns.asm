---------------------------------------------

mtA1_yorrick_1 [
  actor-def < #02, #00, #00, {

  code_0B9D12:
    COP [SetSpritePalette] ( #02 )
    LDA #$0011
    TSB $12

  loc_0B9D1A:
    COP [WaitWhileOffscreen] ( #09 )

  loc_0B9D1D:
    LDA $10
    BIT #$4000
    BNE loc_0B9D1A
    COP [BranchOnPlayerY] ( #$0000, &code_0B9DEC, &code_0B9D2E, &code_0B9D2E )
} >
]

code_0B9D2E {
    COP [BranchIfPlayerInRelTiles] ( #FF, #00, #01, #08, &code_0B9D44 )

  loc_0B9D36:
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #02, #02, #01 )
    COP [AnimLoop]
    BRA loc_0B9D53
}

code_0B9D44 {
    COP [CallScript] ( &code_0B9D86 )
    COP [StageSpriteLoop] ( #02, #02 )
    COP [AnimLoop]
    BRA loc_0B9D36

  loc_0B9D50:
    COP [WaitWhileOffscreen] ( #0A )

  loc_0B9D53:
    LDA $10
    BIT #$4000
    BNE loc_0B9D50
    COP [BranchOnPlayerY] ( #$0000, &code_0B9E22, &code_0B9D64, &code_0B9D64 )
}

code_0B9D64 {
    COP [BranchIfPlayerInRelTiles] ( #FF, #00, #01, #08, &code_0B9D7A )

  loc_0B9D6C:
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #02, #02, #02 )
    COP [AnimLoop]
    BRA loc_0B9D1D
}

code_0B9D7A {
    COP [CallScript] ( &code_0B9D86 )
    COP [StageSpriteLoop] ( #02, #02 )
    COP [AnimLoop]
    BRA loc_0B9D6C
}

code_0B9D86 {
    COP [StageSpriteLoop] ( #1A, #06 )
    COP [AnimLoop]
    COP [SpawnAfterRelFlags] ( @code_0B9DA9, #$FFFD, #$FFF8, #$0202 )
    COP [SpawnAfterRelFlags] ( @code_0B9DA9, #$0004, #$FFF8, #$0202 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0B9DA9 {
    COP [PlaySoundCh1] ( #1D )
    COP [SetSpritePalette] ( #02 )
    COP [OrActorFlags] ( #$0010 )
    COP [StageSpriteMoveY] ( #20, #03 )
    COP [AnimOnce]
    LDA #$0002
    TRB $10

  loc_0B9DBE:
    COP [StageSpriteMoveY] ( #20, #03 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0B9DBE
    COP [Die]
}
---------------------------------------------

mtA1_yorrick_2 [
  actor-def < #03, #00, #00, {

  code_0B9DD0:
    COP [SetSpritePalette] ( #02 )
    LDA #$0011
    TSB $12

  loc_0B9DD8:
    COP [WaitWhileOffscreen] ( #09 )

  loc_0B9DDB:
    LDA $10
    BIT #$4000
    BNE loc_0B9DD8
    COP [BranchOnPlayerY] ( #$0000, &code_0B9DEC, &code_0B9DEC, &code_0B9D2E )
} >
]

code_0B9DEC {
    COP [BranchIfPlayerInRelTiles] ( #FF, #F8, #01, #00, &code_0B9E02 )

  loc_0B9DF4:
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #03, #02, #01 )
    COP [AnimLoop]
    BRA loc_0B9E11
}

code_0B9E02 {
    COP [CallScript] ( &code_0B9E44 )
    COP [StageSpriteLoop] ( #03, #02 )
    COP [AnimLoop]
    BRA loc_0B9DF4

  loc_0B9E0E:
    COP [WaitWhileOffscreen] ( #0A )

  loc_0B9E11:
    LDA $10
    BIT #$4000
    BNE loc_0B9E0E
    COP [BranchOnPlayerY] ( #$0000, &code_0B9E22, &code_0B9E22, &code_0B9D64 )
}

code_0B9E22 {
    COP [BranchIfPlayerInRelTiles] ( #FF, #F8, #01, #00, &code_0B9E38 )

  loc_0B9E2A:
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #03, #02, #02 )
    COP [AnimLoop]
    BRA loc_0B9DDB
}

code_0B9E38 {
    COP [CallScript] ( &code_0B9E44 )
    COP [StageSpriteLoop] ( #03, #02 )
    COP [AnimLoop]
    BRA loc_0B9E2A
}

code_0B9E44 {
    COP [StageSpriteLoop] ( #1B, #06 )
    COP [AnimLoop]
    COP [SpawnAfterRelFlags] ( @code_0B9E67, #$FFFD, #$FFF8, #$0200 )
    COP [SpawnAfterRelFlags] ( @code_0B9E67, #$0004, #$FFF8, #$0200 )
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0B9E67 {
    COP [PlaySoundCh1] ( #1D )
    COP [SetSpritePalette] ( #02 )
    COP [OrActorFlags] ( #$0010 )
    COP [StageSpriteMoveY] ( #20, #04 )
    COP [AnimOnce]
    LDA #$0002
    TRB $10

  loc_0B9E7C:
    COP [StageSpriteMoveY] ( #20, #04 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0B9E7C
    COP [Die]
}