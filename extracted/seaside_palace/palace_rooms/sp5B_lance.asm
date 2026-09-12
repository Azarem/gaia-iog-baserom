?INCLUDE 'ToggleActorVisibilityFlag'

---------------------------------------------

sp5B_lance [
  actor-def < #04, #00, #10, {

  code_0688F3:
    COP [BranchIfFlagByte] ( #70, #01, &code_068929 )
    COP [SpawnAfterAbsFlags] ( @ToggleActorVisibilityFlag, #$0000, #$0000, #$2800 )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_06892B )

  loc_06890D:
    COP [StageSpriteLoopMoveX] ( #08, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #04, #78 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #09, #04, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #05, #78 )
    COP [AnimLoop]
    BRA loc_06890D
} >
]

code_068929 {
    COP [Die]
}

code_06892B {
    COP [PrintDialogString] ( &dialogstring_068930 )
    RTL 
}

dialogstring_068930 `[TPL:A][TPL:4]Lance: [N]Uhhhn. Uhhhn.[PAL:0][END]`