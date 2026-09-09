?INCLUDE 'stats_01ABF0'
?INCLUDE 'ToggleActorVisibilityFlag'

!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

sp5A_phantom_ribber [
  actor-def < #00, #00, #01, {

  code_0689A6:
    COP [BranchIfFlagByte] ( #70, #01, &code_068A14 )
    LDA #$00FF
    STA $currentHp, X
    LDA #$&stats_01ABF0+44
    STA $statsPtr, X
    LDA #$0020
    TSB $12
    COP [SetHitCallback] ( &code_0689F3 )

  loc_0689C3:
    COP [LoopInit] ( #04 )
    COP [StageSpriteMoveX] ( #07, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #08, #12 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [StageSpriteLoop] ( #00, #14 )
    COP [AnimLoop]
    COP [LoopInit] ( #04 )
    COP [StageSpriteMoveX] ( #87, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #88, #11 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [StageSpriteLoop] ( #00, #14 )
    COP [AnimLoop]
    BRA loc_0689C3
} >
]

code_0689F3 {
    COP [SpawnAfterAbsFlags] ( @ToggleActorVisibilityFlag, #$0000, #$0000, #$2800 )
    LDA #$1000
    TSB $10
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_068A16 )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_068A14 {
    COP [Die]
}

code_068A16 {
    COP [PrintWideString] ( &widestring_068A1B )
    RTL 
}

widestring_068A1B `[TPL:A][TPL:0]Will: That's odd. [N]Even if I touch it [N]no damage occurs...[PAL:0][END]`