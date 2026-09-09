?INCLUDE 'ToggleActorVisibilityFlag'

---------------------------------------------

sp5B_kara [
  actor-def < #1C, #00, #10, {

  code_068621:
    COP [BranchIfFlagByte] ( #70, #01, &code_068657 )
    COP [SpawnAfterAbsFlags] ( @ToggleActorVisibilityFlag, #$0000, #$0000, #$2800 )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_068659 )

  loc_06863B:
    COP [StageSpriteLoopMoveX] ( #20, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1C, #78 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #21, #04, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1D, #78 )
    COP [AnimLoop]
    BRA loc_06863B
} >
]

code_068657 {
    COP [Die]
}

code_068659 {
    COP [PrintWideString] ( &widestring_06865E )
    RTL 
}

widestring_06865E `[TPL:A][TPL:1]Kara: [N]Will...Where... [N]Where is it...??[PAL:0][END]`