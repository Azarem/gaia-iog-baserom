?INCLUDE 'spriteset_npc_props'
?INCLUDE 'town_door'

---------------------------------------------

fr32_guide [
  actor-def < #02, #00, #10, {

  code_05B198:
    COP [BranchIfFlagByte] ( #57, #01, &code_05B203 )
    COP [SpawnAfterAbsFlags] ( @code_05B315, #$0278, #$0230, #$1000 )
    COP [BranchIfFlagByte] ( #64, #01, &code_05B1F1 )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [StageSpriteLoopMoveX] ( #08, #04, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #06, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_05B225 )
    COP [ClearFlagByte] ( #02 )
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [StageSpriteMoveX] ( #09, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #07, #02 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #09, #09, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #07, #06, #02 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #09, #11 )
    COP [AnimOnce]
} >
]

code_05B1F1 {
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [SetTilePos] ( #28, #25 )
    COP [SetOnInteract] ( &code_05B21B )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_05B203 {
    COP [SpawnAfterAbsFlags] ( @town_door.code_00C5F6, #$0278, #$0230, #$1000 )
    COP [SetOnInteract] ( &code_05B220 )
    COP [SetTilePos] ( #29, #24 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
}

code_05B21B {
    COP [PrintDialogString] ( &dialogstring_05B2D3 )
    RTL 
}

code_05B220 {
    COP [PrintDialogString] ( &dialogstring_05B2DC )
    RTL 
}

dialogstring_05B225 `[TPL:E]Man: What a cute couple.[N]Have you decided where[N]you're staying tonight?[FIN][TPL:1]Kara: No. [N]Not yet. We're looking [N]for someone. [FIN][TPL:6]Man: Well, well.[N]Why not base your[N]search here?[FIN][TPL:1]Kara: It's settled! [N]I'm exhausted!![PAL:0][END]`

dialogstring_05B2D3 `[DEF]Well, come in.[END]`

dialogstring_05B2DC `[DEF]Recently tourists have[N]avoided this town...[N]Business is terrible.[END]`

code_05B315 {
    COP [SetMetasprite] ( @spriteset_npc_props )
    COP [StageSpriteFrame] ( #01 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [PlaySoundCh2] ( #0E )
    COP [ClearLowHere]
    COP [Die]
}