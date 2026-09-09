?INCLUDE 'nv_actor_0881A5'

---------------------------------------------

nvAC_erik [
  actor-def < #04, #00, #10, {

  code_088549:
    COP [BranchIfFlagByte] ( #B6, #01, &code_0885A1 )
    COP [BranchIfFlagByte] ( #CF, #01, &code_0885A1 )
    COP [BranchIfFlagByte] ( #B2, #01, &code_0885C5 )
    COP [BranchIfFlagByte] ( #AF, #01, &code_0885A3 )
    COP [BranchIfFlagByte] ( #AD, #01, &code_0885A1 )
    COP [BranchIfFlagByte] ( #AC, #01, &code_088589 )
    COP [ExitIfFlagByte] ( #AC, #01 )
    COP [WaitByte] ( #1F )
    COP [StageSpriteLoopMoveXY] ( #08, #08, #02, #14 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #08, #02 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #07, #04, #02 )
    COP [AnimLoop]
} >
]

code_088589 {
    COP [SetTilePos] ( #0B, #11 )
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #AD, #01 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #07, #05, #02 )
    COP [AnimLoop]
}

code_0885A1 {
    COP [Die]
}

code_0885A3 {
    COP [SetTilePos] ( #0A, #10 )
    COP [StageSpriteFrame] ( #2F )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [SpawnAfterFlags] ( @nv_actor_0881A5.code_0881AE, #$1002 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_0885D7 )
    COP [SetEntryContinue]
    RTL 
}

code_0885C5 {
    COP [SetTilePos] ( #12, #0B )
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_0885D7 )
    COP [SetEntryContinue]
    RTL 
}

code_0885D7 {
    COP [PrintWideString] ( &widestring_0885DC )
    RTL 
}

widestring_0885DC `[TPL:E][TPL:3]Erik: This tribe is so [N]small. They have lost [N]so many to starvation. [FIN]Brothers, sisters... [N]husbands, wives... [N]How do they cope?[PAL:0][END]`