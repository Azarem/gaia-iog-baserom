; Erik trapped in the palace rooms — frightened in darkness.
; 
; NPC: "What is this place? Dark and lonely. Mother, save me..."
; Erik's vulnerability in the palace. Each party member is
; separated and trapped in different rooms.
---------------------------------------------

?INCLUDE 'ToggleActorVisibilityFlag'

---------------------------------------------

sp5B_erik [
  actor-def < #0C, #00, #10, {

  code_068879:
    COP [BranchOnFlagByte] ( #70, #01, &code_0688AF )
    COP [SpawnAfterAbsFlags] ( @ToggleActorVisibilityFlag, #$0000, #$0000, #$2800 )
    LDA #$0200
    TSB $12
    COP [SetInteractHandler] ( &code_0688B1 )

  loc_068893:
    COP [StageSpriteLoopMoveX] ( #10, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0C, #78 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #11, #04, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0D, #78 )
    COP [AnimLoop]
    BRA loc_068893
} >
]

code_0688AF {
    COP [Die]
}

code_0688B1 {
    COP [PrintDialogString] ( &dialogstring_0688B6 )
    RTL 
}

dialogstring_0688B6 `[TPL:A][TPL:3]Erik: What is this [N]place? Dark and lonely. [N]Mother, save me...[PAL:0][END]`