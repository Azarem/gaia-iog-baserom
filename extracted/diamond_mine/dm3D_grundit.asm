; Grundit enemy — burrowing ground creature that spawns tracking mines.
; 
; Waits offscreen, wakes when player is within 4 tiles. Plays digging
; SFX (#2C), animates emerging from ground, then spawns 4 directional
; mine projectiles and a marker child. Also spawns a dm_follower_behavior
; child that chases the player using the smooth_follow system. After
; spawning, displays above-ground sprite and waits $77 frames before
; returning to sleep. Mine projectiles move in diagonal pairs.
---------------------------------------------

?INCLUDE 'dm_follower_behavior'

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
    COP [LoopStart] ( #05 )
    COP [PlaySoundCh1] ( #2C )
    COP [StageSpriteFrame] ( #2D )
    COP [AnimOnce]
    COP [LoopEnd]
    LDA #$0200
    TRB $10
    COP [SpawnAfterFlags] ( @code_0AB081, #$0200 )
    COP [SpawnAfterFlags] ( @code_0AB098, #$0200 )
    COP [SpawnAfterFlags] ( @code_0AB091, #$0200 )
    COP [SetEntryHereAndYield]
    COP [SpawnAfterFlags] ( @code_0AB0AC, #$0200 )
    COP [SpawnAfterMarked] ( @code_0AB071, #$0301 )
    COP [StageSpriteFrame] ( #2F )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #30 )
    COP [AnimOnce]
    COP [SpawnListAppend] ( @dm_follower_behavior, #00, #CE, #$0202 )
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
    COP [NudgePosition] ( #00, #06 )
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