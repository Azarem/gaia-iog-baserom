?INCLUDE 'spriteset_enemies'

---------------------------------------------

av70_ramskull [
  actor-def < #1A, #00, #00, {

  code_0AF0CA:
    COP [SolidHighHere]
    LDA #$0011
    TSB $12
    COP [OrActorFlags] ( #$0008 )

  loc_0AF0D5:
    COP [WaitWhileOffscreen] ( #08 )
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #1B, #03 )
    COP [AnimLoop]
    COP [SpawnLastRel] ( @code_0AF102, #FC, #F4, #$0200 )
    COP [SpawnLastRel] ( @code_0AF0FD, #04, #F4, #$0200 )
    COP [StageSpriteLoop] ( #1A, #02 )
    COP [AnimLoop]
    BRA loc_0AF0D5
} >
]

code_0AF0FD {
    LDA #$4000
    TSB $12
}

code_0AF102 {
    COP [OrActorFlags] ( #$0010 )
    COP [SpawnMarkedAfter] ( @code_0AF137, #$2200 )
    LDA #$0002
    STA $0008, Y
    COP [SpawnMarkedAfter] ( @code_0AF137, #$2200 )
    LDA #$0004
    STA $0008, Y
    COP [PlaySoundCh1] ( #1E )
    COP [SetMetasprite] ( @spriteset_enemies )

  loc_0AF128:
    COP [StageSpriteMoveX] ( #08, #04 )
    COP [AnimOnce]
    LDA $10
    BIT #$4000
    BEQ loc_0AF128
    COP [Die]
}

code_0AF137 {
    COP [SetMetasprite] ( @spriteset_enemies )
    COP [SetEntryExit]
    LDA #$2000
    TRB $10
    COP [StageForceMoveXY] ( #04, #00 )

  loc_0AF147:
    COP [ReloadForceMove]
    COP [StageSpriteFrame] ( #26 )
    COP [AnimOnce]
    BRA loc_0AF147
}