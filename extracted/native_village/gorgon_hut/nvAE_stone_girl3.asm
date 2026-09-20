; Stone girl statue 3 in the Gorgon Hut — can be restored.
; 
; Same dual-state as stone_girl2. Silent statue that becomes
; a crying human girl when the Gorgon's curse is broken.
---------------------------------------------

---------------------------------------------

nvAE_stone_girl3 [
  actor-def < #36, #00, #10, {

  code_089474:
    COP [SolidHighHere]
    COP [BranchIfFlagByte] ( #C1, #01, &code_08949D )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_0894A9 )
    COP [ExitIfFlagByte] ( #C1, #01 )
    COP [LoopInit] ( #1E )
    COP [StageSpriteFrame] ( #36 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #32 )
    COP [AnimOnce]
    COP [LoopNext]
    LDA #$0200
    TRB $12
} >
]

code_08949D {
    COP [SetOnInteract] ( &code_0894AE )
    COP [StageSpriteFrame] ( #32 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_0894A9 {
    COP [PrintDialogString] ( &dialogstring_0894B3 )
    RTL 
}

code_0894AE {
    COP [PrintDialogString] ( &dialogstring_089509 )
    RTL 
}

dialogstring_0894B3 `[DEF]The statue of the girl[N]stands silently.[END]`

dialogstring_0894D2 `[DEF]Somehow the statue has[N]become a human girl![FIN]A tear comes to[N]the girl's eyes...[END]`

dialogstring_089509 `[DEF]You don't understand...[END]`