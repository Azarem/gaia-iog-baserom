; Gold Ship deck crew member 2 — animated patrol NPC.
; 
; Crew member who paces back and forth on deck with a multi-step
; walk animation (frames #05-#09, alternating Y and X movement).
; Pauses at solid positions with idle loop, then resumes patrol.
; Interactable with celebratory dialog about the happy occasion.
---------------------------------------------

---------------------------------------------

gs2C_crew2 [
  actor-def < #04, #00, #10, {

  code_058287:
    COP [SetOnInteract] ( &code_0582C7 )

  loc_05828B:
    COP [StageSpriteMoveY] ( #07, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #08, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #06, #11 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [StageSpriteLoop] ( #05, #3C )
    COP [AnimLoop]
    COP [ClearLowHere]
    COP [StageSpriteMoveY] ( #07, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #09, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #06, #11 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [StageSpriteLoop] ( #04, #3C )
    COP [AnimLoop]
    COP [ClearLowHere]
    BRA loc_05828B
} >
]

code_0582C7 {
    COP [PrintDialogString] ( &dialogstring_0582CC )
    RTL 
}

dialogstring_0582CC `[DEF]It's a happy occasion![N]We have waited for you[N]for such a long time![END]`