!joypadMaskStd                  065A

---------------------------------------------

sc06_main_soldier [
  actor-def < #1A, #00, #30, {

  code_04A363:
    COP [BranchIfFlagByte] ( #1B, #01, &code_04A3B9 )
    COP [ExitIfFlagByte] ( #04, #01 )
    LDA #$2000
    TRB $10
    COP [SetTilePos] ( #0A, #19 )
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #04, #19, #0E, #1D, &code_04A386 )
    RTL 
} >
]

code_04A386 {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [StageSpriteMoveX] ( #21, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_04A3BB )
    COP [SetFlagByte] ( #07 )
    COP [ExitIfFlagByte] ( #08, #01 )
    COP [StageSpriteMoveX] ( #21, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #20, #06, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1E, #0A, #11 )
    COP [AnimLoop]
}

code_04A3B9 {
    COP [Die]
}

dialogstring_04A3BB `[TPL:B]Soldier: Princess! I've[N]been looking for you![FIN][TPL:1]Kara: [N]I don't know you.[N]Be gone![FIN][PAL:0][SFX:10]Soldier: What are you [N]saying? If I don't take [N]you home,[N]I'll lose my head? [END]`