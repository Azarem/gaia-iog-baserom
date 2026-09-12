!joypadMaskStd                  065A

---------------------------------------------

ec0A_left_guard [
  actor-def < #1D, #00, #10, {

  code_04BFE7:
    COP [BranchIfFlagByte] ( #21, #01, &code_04C04B )
    COP [SetOnInteract] ( &code_04C05D )
    COP [BranchIfFlagByte] ( #3F, #01, &code_04BFFD )
    LDA #$CFF0
    TSB $joypadMaskStd
} >
]

code_04BFFD {
    COP [StageSpriteLoopMoveX] ( #21, #07, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1D, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1A, #08 )
    COP [AnimLoop]
    COP [BranchIfFlagByte] ( #3F, #01, &code_04C023 )
    COP [PrintDialogString] ( &dialogstring_04C115 )
    COP [SetFlagByte] ( #3F )
    LDA #$CFF0
    TRB $joypadMaskStd
}

code_04C023 {
    COP [StageSpriteLoop] ( #1C, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #20, #1B, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1C, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1A, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1D, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #21, #14, #11 )
    COP [AnimLoop]
    BRA code_04BFFD
}

code_04C04B {
    COP [SetOnInteract] ( &code_04C062 )
    COP [SetTilePos] ( #06, #27 )
    COP [SolidHighHere]
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_04C05D {
    COP [PrintDialogString] ( &dialogstring_04C067 )
    RTL 
}

code_04C062 {
    COP [PrintDialogString] ( &dialogstring_04C0AF )
    RTL 
}

dialogstring_04C067 `[TPL:A]This is King Edward's[N]castle.[FIN]Go to the second[N]floor if you want to[N]meet King Edward.[END]`

dialogstring_04C0AF `[TPL:B]Ah! It's you![FIN]You've escaped[N]from the prison...[FIN]Trust what I say. Run[N]from this castle. It'd[N]be terrible if King[N]Edward found you here.[END]`

dialogstring_04C115 `[TPL:A]Soldier: This is King[N]Edward's castle. I must[N]report this intrusion.[FIN][DLG:3,6][SIZ:D,3][TPL:0]Will shows the letter[N]to the guard.[FIN][TPL:A][PAL:0]Soldier: A guest of the[N]King? I'm sorry, you[N]may pass.[END]`