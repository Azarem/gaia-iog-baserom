; Gold Ship deck crew member 3 — another pacing NPC.
; 
; Similar patrol animation to crew2 but uses different sprite
; frames (#0C-#11). Walks a route and pauses at solid positions.
; Provides crew dialog.
---------------------------------------------

---------------------------------------------

gs2C_crew3 [
  actor-def < #0D, #00, #10, {

  code_058308:
    COP [SetInteractHandler] ( &code_058348 )

  loc_05830C:
    COP [StageSpriteMoveY] ( #0E, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #11, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #0F, #12 )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [StageSpriteLoop] ( #0C, #3C )
    COP [AnimLoop]
    COP [ClearSolidHere]
    COP [StageSpriteMoveY] ( #0E, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #10, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #0F, #12 )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [StageSpriteLoop] ( #0D, #3C )
    COP [AnimLoop]
    COP [ClearSolidHere]
    BRA loc_05830C
} >
]

code_058348 {
    COP [PrintDialogString] ( &dialogstring_05834D )
    RTL 
}

dialogstring_05834D `[DEF]The Queen is in her [N]stateroom. Please show [N]her that you're OK. [END]`