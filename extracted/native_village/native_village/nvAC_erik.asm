; Erik of the Native Village (scene $AC): follows the state order of nvAC_kara. $B6 or $CF set: dies. $B2 set: stands at tile (12,0B) with the fixed text below. $AF set (Hamlet scene): stands at tile (0A,10), waits for scratch $05, spawns the event sprite code_0881AE, changes frame and installs the fixed text. $AD set: dies. $AC set: stands at tile (0B,11) until $AD is set, then walks away. All clear: waits for $AC (set by Kara), waits 32 ticks (WaitByte #1F) and walks to the standing state.
; 
; Fixed text: 'This tribe is so small. They have lost so many to starvation. Brothers, sisters... husbands, wives... How do they cope?'.
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