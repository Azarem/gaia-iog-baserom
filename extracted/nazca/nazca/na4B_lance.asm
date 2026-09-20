; Lance at Nazca — reflects on life's purpose.
; 
; NPC: "Up until now all I've done is go to school, study, and
; play. Sometimes I wonder if my life has meaning." Lance's
; philosophical moment. Later: "We're working on a puzzle that
; explorers and archeologists have never solved..." Character
; growth through the adventure.
---------------------------------------------

---------------------------------------------

na4B_lance [
  actor-def < #03, #00, #10, {

  code_05EEA4:
    COP [MarkSolidHere]
    COP [WaitOnFlagByte] ( #01, #01 )
    COP [SetInteractHandler] ( &code_05EF23 )
    COP [ClearSolidHere]
    COP [StageSpriteLoopMoveY] ( #06, #0B, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #02, #20 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #05, #20 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #09, #06, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [WaitOnFlagByte] ( #02, #01 )
    COP [ClearSolidHere]
    COP [SetTilePos] ( #11, #09 )
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [WaitOnFlagByte] ( #08, #01 )
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [WaitOnFlagByte] ( #09, #01 )
    COP [SetInteractHandler] ( &code_05EF28 )
    COP [ClearSolidHere]
    COP [StageSpriteLoopMoveY] ( #06, #0B, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #09, #05, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #06, #06, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #09, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [WaitOnFlagByte] ( #0C, #01 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SetEntryHere]
    RTL 
} >
]

code_05EF23 {
    COP [PrintDialogString] ( &dialogstring_05EF2D )
    RTL 
}

code_05EF28 {
    COP [PrintDialogString] ( &dialogstring_05EF98 )
    RTL 
}

dialogstring_05EF2D `[DEF][TPL:4]Lance: [N]Up until now all I've [N]done is go to school, [N]study, and play. [FIN]Sometimes I wonder if[N]my being here isn't[N]all a dream...[PAL:0][END]`

dialogstring_05EF98 `[DEF][TPL:4]Lance: We're working on a [N]puzzle that explorers [N]and archeologists have [N]never solved...[PAL:0][END]`