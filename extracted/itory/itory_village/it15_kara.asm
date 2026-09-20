; Kara in Itory Village -- arrival and departure scenes.
; 
; Multi-state dialog: arrives complaining about sore feet,
; later decides to accompany Will, then says goodbye.
---------------------------------------------

!joypadMaskStd                  065A

---------------------------------------------

it15_kara [
  actor-def < #12, #00, #10, {

  code_04E06D:
    COP [BranchOnFlagByte] ( #4B, #01, &code_04E110 )
    COP [BranchOnFlagByte] ( #37, #01, &code_04E112 )
    COP [BranchOnFlagByte] ( #2B, #00, &code_04E08B )
    COP [BranchOnFlagByte] ( #3B, #01, &code_04E110 )
    COP [SetTilePos] ( #41, #27 )
    BRA loc_04E0F1
} >
]

code_04E08B {
    COP [BranchOnFlagByte] ( #26, #00, &code_04E110 )
    COP [WaitOnFlagByte] ( #01, #01 )
    COP [LoopStart] ( #10 )
    LDA $16
    SEC 
    SBC #$0010
    STA $16
    COP [LoopEnd]
    COP [WaitOnFlagByte] ( #02, #01 )
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_04E124 )
    COP [SetFlagByte] ( #03 )
    LDA #$0800
    TSB $10
    COP [StageSpriteMoveX] ( #19, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #16, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #19, #01 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #16, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #19, #06, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #16, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #19, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #17, #05, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #19, #11 )
    COP [AnimOnce]

  loc_04E0F1:
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    LDA #$0800
    TRB $10
    COP [WaitOnFlagByte] ( #05, #01 )
    COP [PrintDialogString] ( &dialogstring_04E175 )
    COP [StageSpriteLoopMoveY] ( #17, #04, #02 )
    COP [AnimLoop]
    LDA #$CFF0
    TRB $joypadMaskStd
}

code_04E110 {
    COP [Die]
}

code_04E112 {
    COP [SetTilePos] ( #49, #27 )
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_04E11F )
    COP [SetEntryHere]
    RTL 
}

code_04E11F {
    COP [PrintDialogString] ( &dialogstring_04E196 )
    RTL 
}

dialogstring_04E124 `[TPL:E][TPL:1]Kara: [N]I can't help it. [N]My feet hurt. [FIN][TPL:2]Lilly: Oh, OK.[N]Well, come with me.[N]I'll show you my house.[PAL:0][END]`

dialogstring_04E175 `[TPL:E][TPL:1]Kara: Lilly, wait. [N]I'll go, too.[PAL:0][END]`

dialogstring_04E196 `[TPL:E][TPL:1]Kara: I know you [N]don't need me.....[PAL:0][END]`