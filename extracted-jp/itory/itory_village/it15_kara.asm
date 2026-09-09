!joypadMaskStd                  065A

---------------------------------------------

h_it15_kara [
  actor-def < #12, #00, #10, {

  code_04D986:
    COP [BranchIfFlagByte] ( #4B, #01, &code_04DA29 )
    COP [BranchIfFlagByte] ( #37, #01, &code_04DA2B )
    COP [BranchIfFlagByte] ( #2B, #00, &code_04D9A4 )
    COP [BranchIfFlagByte] ( #3B, #01, &code_04DA29 )
    COP [SetTilePos] ( #41, #27 )
    BRA loc_04DA0A
} >
]

code_04D9A4 {
    COP [BranchIfFlagByte] ( #26, #00, &code_04DA29 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [LoopInit] ( #10 )
    LDA $16
    SEC 
    SBC #$0010
    STA $16
    COP [LoopNext]
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    COP [PrintWideString] ( &widestring_04DA3D )
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

  loc_04DA0A:
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    LDA #$0800
    TRB $10
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [PrintWideString] ( &widestring_04DA9D )
    COP [StageSpriteLoopMoveY] ( #17, #04, #02 )
    COP [AnimLoop]
    LDA #$CFF0
    TRB $joypadMaskStd
}

code_04DA29 {
    COP [Die]
}

code_04DA2B {
    COP [SetTilePos] ( #49, #27 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_04DA38 )
    COP [SetEntryContinue]
    RTL 
}

code_04DA38 {
    COP [PrintWideString] ( &widestring_04DAC0 )
    RTL 
}

widestring_04DA3D `[TPL:E][TPL:1]カレン:[N]しょうがないでしょ.[N]本当に 足が痛かったんだから.[FIN][TPL:2]リリィ: まあ いいわ.[N]とにかく ついてきてちょうだい.[N]あたしの家に 案内するから.[PAL:0][END]`

widestring_04DA9D `[TPL:E][TPL:1]カレン: リリィまってよ.[N]あたしも 行くわ.[PAL:0][END]`

widestring_04DAC0 `[TPL:E][TPL:1]カレン: ふんっ. なによっ.[N]どうせ あたしはじゃまものよっ![PAL:0][END]`