---------------------------------------------

h_sc01_sympathetic_woman [
  actor-def < #14, #00, #10, {

  code_0488D0:
    COP [SetOnInteract] ( &code_04892C )
    COP [SolidHighHere]
    COP [WaitByte] ( #EF )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #19, #0C, #11 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #17, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    COP [DrawMetatileAbs] ( #15, #24, #F9 )
    LDA #$0200
    TSB $12
    COP [StageSpriteFrame] ( #3A )
    COP [AnimOnce]
    LDA #$0200
    TRB $12
    COP [StageSpriteMoveY] ( #2E, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #30, #0C, #12 )
    COP [AnimLoop]
    LDA #$0200
    TSB $12
    COP [StageSpriteFrame] ( #3B )
    COP [AnimOnce]
    LDA #$0200
    TRB $12
    COP [DrawMetatileAbs] ( #09, #25, #F8 )
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_04892C {
    COP [PrintWideString] ( &widestring_048931 )
    RTL 
}

widestring_048931 `[DEF]あたしゃ モリスが かわいそうで[N]しかたがないよ.[FIN]每日 あんな 夫婦げんかを[N]みせられてちゃ 子供も[N]たまんないよね.[END]`

widestring_048977 `ざが┌ぅ`