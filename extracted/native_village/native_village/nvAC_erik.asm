; Erik in the Native Village — moved by the tribe's suffering.
; 
; Extended NPC (~75 lines). "This tribe is so small. They have
; lost so many to starvation. Brothers, sisters..." Erik's
; empathy for the village's losses.
---------------------------------------------

?INCLUDE 'nv_village_event_sprite'

---------------------------------------------

nvAC_erik [
  actor-def < #04, #00, #10, {

  code_088549:
    COP [BranchOnFlagByte] ( #B6, #01, &code_0885A1 )
    COP [BranchOnFlagByte] ( #CF, #01, &code_0885A1 )
    COP [BranchOnFlagByte] ( #B2, #01, &code_0885C5 )
    COP [BranchOnFlagByte] ( #AF, #01, &code_0885A3 )
    COP [BranchOnFlagByte] ( #AD, #01, &code_0885A1 )
    COP [BranchOnFlagByte] ( #AC, #01, &code_088589 )
    COP [WaitOnFlagByte] ( #AC, #01 )
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
    COP [MarkSolidHere]
    COP [WaitOnFlagByte] ( #AD, #01 )
    COP [ClearSolidHere]
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
    COP [MarkSolidHere]
    COP [WaitOnFlagByte] ( #05, #01 )
    COP [SpawnAfterFlags] ( @nv_village_event_sprite.code_0881AE, #$1002 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SetInteractHandler] ( &code_0885D7 )
    COP [SetEntryHere]
    RTL 
}

code_0885C5 {
    COP [SetTilePos] ( #12, #0B )
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_0885D7 )
    COP [SetEntryHere]
    RTL 
}

code_0885D7 {
    COP [PrintDialogString] ( &dialogstring_0885DC )
    RTL 
}

dialogstring_0885DC `[TPL:E][TPL:3]Erik: This tribe is so [N]small. They have lost [N]so many to starvation. [FIN]Brothers, sisters... [N]husbands, wives... [N]How do they cope?[PAL:0][END]`