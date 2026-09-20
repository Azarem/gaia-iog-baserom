; Yorrick enemy (east-west variant) in the Mountain Temple (~201 lines).
; 
; Skull enemy that patrols east-west corridors. Bounces
; off walls and reverses direction. Damages on contact.
; The east-west variant has horizontal movement priority.
---------------------------------------------

---------------------------------------------

mtA1_yorrick_3 [
  actor-def < #04, #00, #00, {

  code_0B9E8E:
    COP [SetSpritePalette] ( #02 )
    LDA #$0011
    TSB $12

  loc_0B9E96:
    COP [WaitWhileOffscreen] ( #09 )

  loc_0B9E99:
    LDA $10
    BIT #$4000
    BNE loc_0B9E96
    COP [BranchOnPlayerX] ( #$0000, &code_0B9EAA, &code_0B9EAA, &code_0B9F74 )
} >
]

code_0B9EAA {
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [BranchIfPlayerInRelTiles] ( #F8, #FF, #00, #01, &code_0B9EC5 )

  loc_0B9EB7:
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #04, #02, #01 )
    COP [AnimLoop]
    BRA loc_0B9ED4
}

code_0B9EC5 {
    COP [CallScript] ( &code_0B9F0C )
    COP [StageSpriteLoop] ( #04, #02 )
    COP [AnimLoop]
    BRA loc_0B9EB7

  loc_0B9ED1:
    COP [WaitWhileOffscreen] ( #0A )

  loc_0B9ED4:
    LDA $10
    BIT #$4000
    BNE loc_0B9ED1
    COP [BranchOnPlayerX] ( #$0000, &code_0B9EE5, &code_0B9EE5, &code_0B9FAF )
}

code_0B9EE5 {
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [BranchIfPlayerInRelTiles] ( #F8, #FF, #00, #01, &code_0B9F00 )

  loc_0B9EF2:
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #04, #02, #02 )
    COP [AnimLoop]
    BRA loc_0B9E99
}

code_0B9F00 {
    COP [CallScript] ( &code_0B9F0C )
    COP [StageSpriteLoop] ( #04, #02 )
    COP [AnimLoop]
    BRA loc_0B9EF2
}

code_0B9F0C {
    COP [StageSpriteLoop] ( #1C, #06 )
    COP [AnimLoop]
    COP [SpawnAfterRelFlags] ( @code_0B9F2F, #$FFFA, #$FFF8, #$0202 )
    COP [SpawnAfterRelFlags] ( @code_0B9F2F, #$FFFA, #$FFF6, #$0202 )
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0B9F2F {
    COP [PlaySoundCh1] ( #1D )
    COP [SetSpritePalette] ( #02 )
    COP [OrActorFlags] ( #$0010 )
    COP [StageSpriteMoveX] ( #20, #04 )
    COP [AnimOnce]
    LDA #$0002
    TRB $10

  loc_0B9F44:
    COP [StageSpriteMoveX] ( #20, #04 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0B9F44
    COP [Die]
}
---------------------------------------------

mtA1_yorrick_4 [
  actor-def < #04, #00, #00, {

  code_0B9F56:
    COP [SetHFlip]
    COP [SetSpritePalette] ( #02 )
    LDA #$0011
    TSB $12

  loc_0B9F60:
    COP [WaitWhileOffscreen] ( #09 )

  loc_0B9F63:
    LDA $10
    BIT #$4000
    BNE loc_0B9F60
    COP [BranchOnPlayerX] ( #$0000, &code_0B9EAA, &code_0B9F74, &code_0B9F74 )
} >
]

code_0B9F74 {
    COP [StageSpriteFrame] ( #84 )
    COP [AnimOnce]
    COP [BranchIfPlayerInRelTiles] ( #00, #FF, #08, #01, &code_0B9F8F )

  loc_0B9F81:
    COP [StageSpriteFrame] ( #84 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #84, #02, #01 )
    COP [AnimLoop]
    BRA loc_0B9F9E
}

code_0B9F8F {
    COP [CallScript] ( &code_0B9FD6 )
    COP [StageSpriteLoop] ( #84, #02 )
    COP [AnimLoop]
    BRA loc_0B9F81

  loc_0B9F9B:
    COP [WaitWhileOffscreen] ( #0A )

  loc_0B9F9E:
    LDA $10
    BIT #$4000
    BNE loc_0B9F9B
    COP [BranchOnPlayerX] ( #$0000, &code_0B9EE5, &code_0B9FAF, &code_0B9FAF )
}

code_0B9FAF {
    COP [StageSpriteFrame] ( #84 )
    COP [AnimOnce]
    COP [BranchIfPlayerInRelTiles] ( #00, #FF, #08, #01, &code_0B9FCA )

  loc_0B9FBC:
    COP [StageSpriteFrame] ( #84 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #84, #02, #02 )
    COP [AnimLoop]
    BRA loc_0B9F63
}

code_0B9FCA {
    COP [CallScript] ( &code_0B9FD6 )
    COP [StageSpriteLoop] ( #84, #02 )
    COP [AnimLoop]
    BRA loc_0B9FBC
}

code_0B9FD6 {
    COP [StageSpriteLoop] ( #9C, #06 )
    COP [AnimLoop]
    COP [SpawnAfterRelFlags] ( @code_0B9FF9, #$0006, #$FFF8, #$0202 )
    COP [SpawnAfterRelFlags] ( @code_0B9FF9, #$0006, #$FFF6, #$0202 )
    COP [StageSpriteFrame] ( #84 )
    COP [AnimOnce]
    COP [RestoreSavedPtr]
}

code_0B9FF9 {
    COP [PlaySoundCh1] ( #1D )
    COP [SetSpritePalette] ( #02 )
    COP [OrActorFlags] ( #$0010 )
    COP [StageSpriteMoveX] ( #20, #03 )
    COP [AnimOnce]
    LDA #$0002
    TRB $10

  loc_0BA00E:
    COP [StageSpriteMoveX] ( #20, #03 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0BA00E
    COP [Die]
}