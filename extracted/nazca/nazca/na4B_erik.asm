; Erik at Nazca — scared but curious.
; 
; Multi-state NPC. Initially: "It's scary... I'll stay with
; Neil." Later: "What's going to happen? It's exciting!"
; Erik's evolving reaction from fear to excitement about
; the Nazca discoveries.
---------------------------------------------

---------------------------------------------

na4B_erik [
  actor-def < #0B, #00, #10, {

  code_05F1FC:
    COP [MarkSolidHere]
    COP [WaitOnFlagByte] ( #01, #01 )
    COP [SetInteractHandler] ( &code_05F269 )
    COP [ClearSolidHere]
    COP [StageSpriteLoopMoveY] ( #0F, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #10, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [WaitOnFlagByte] ( #02, #01 )
    COP [ClearSolidHere]
    COP [SetTilePos] ( #14, #09 )
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_05F26E )
    COP [WaitOnFlagByte] ( #08, #01 )
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [WaitOnFlagByte] ( #09, #01 )
    COP [SetInteractHandler] ( &code_05F273 )
    COP [ClearSolidHere]
    COP [StageSpriteLoopMoveY] ( #0E, #09, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #11, #05, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #0E, #07, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #0E, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
} >
]

code_05F269 {
    COP [PrintDialogString] ( &dialogstring_05F278 )
    RTL 
}

code_05F26E {
    COP [PrintDialogString] ( &dialogstring_05F29F )
    RTL 
}

code_05F273 {
    COP [PrintDialogString] ( &dialogstring_05F2C7 )
    RTL 
}

dialogstring_05F278 `[DEF][TPL:3]Erik: [N]It's scary... I'll stay [N]with Neil.[PAL:0][END]`

dialogstring_05F29F `[DEF][TPL:3]Erik: [N]What's going to [N]happen? It's exciting![PAL:0][END]`

dialogstring_05F2C7 `[DEF][TPL:3]Erik:[N]What's going to[N]happen... It's exciting![PAL:0][END]`