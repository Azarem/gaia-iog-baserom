?INCLUDE 'dm_func_0ADB6B'

!orbitAngle                     7F0010

---------------------------------------------

dm3D_grundit [
  actor-def < #1A, #00, #22, {

  code_0AAFF8:
    LDA #$0011
    TSB $12
    LDA #$0000
    STA $orbitAngle, X

  code_0AB004:
    COP [WaitWhileOffscreen] ( #08 )
    COP [BranchIfPlayerNear] ( #04, &code_0AB00D )
    RTL 
} >
]

code_0AB00D {
    LDA #$2000
    TRB $10
    COP [LoopInit] ( #05 )
    COP [PlaySoundCh1] ( #2C )
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    COP [LoopNext]
    LDA #$0200
    TRB $10
    COP [SpawnAfterFlags] ( @code_0AB081, #$0200 )
    COP [SpawnAfterFlags] ( @code_0AB098, #$0200 )
    COP [SpawnAfterFlags] ( @code_0AB091, #$0200 )
    COP [SetEntryExit]
    COP [SpawnAfterFlags] ( @code_0AB0AC, #$0200 )
    COP [SpawnMarkedAfter] ( @code_0AB071, #$0301 )
    COP [StageSpriteFrame] ( #2F )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #30 )
    COP [AnimOnce]
    COP [SpawnLastRel] ( @dm_func_0ADB6B, #00, #CE, #$0202 )
    COP [StageSpriteFrame] ( #30 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #31 )
    COP [AnimOnce]
    LDA #$2200
    TSB $10
    COP [WaitByte] ( #77 )
    JMP $&code_0AB004
}

code_0AB071 {
    COP [StageSpriteFrame] ( #2E )
    COP [AnimOnce]
    COP [WaitWord] ( #$00DB )
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    COP [Die]
}

code_0AB081 {
    COP [StageSpriteMoveXY] ( #32, #02, #2A )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #32, #02, #2B )
    COP [AnimOnce]
    COP [Die]
}

code_0AB091 {
    LDA #$4000
    TSB $12
    BRA code_0AB081
}

code_0AB098 {
    COP [AddPosition] ( #00, #06 )
    COP [StageSpriteMoveXY] ( #32, #12, #2A )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #32, #12, #2B )
    COP [AnimOnce]
    COP [Die]
}

code_0AB0AC {
    LDA #$4000
    TSB $12
    BRA code_0AB098
}