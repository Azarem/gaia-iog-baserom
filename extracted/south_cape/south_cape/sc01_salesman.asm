---------------------------------------------

sc01_salesman [
  actor-def < #0C, #00, #10, {

  code_0481F0:
    COP [SetOnInteract] ( &code_0482CD )
    COP [SetEntryContinue]
    COP [SolidHighHere]
    COP [WaitByte] ( #EF )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #0E, #01, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #10, #0D, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #0F, #01, #12 )
    COP [AnimLoop]
    COP [SolidHighHere]
    COP [StageSpriteLoop] ( #0B, #78 )
    COP [AnimLoop]
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #0E, #01, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #10, #07, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #0E, #04, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #11, #01, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #11, #03, #11, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #11, #01, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #0E, #0B, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #11, #04, #11 )
    COP [AnimLoop]
    COP [SolidHighHere]
    COP [StageSpriteLoop] ( #0B, #78 )
    COP [AnimLoop]
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #10, #06, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #10, #04, #12, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #10, #06, #12 )
    COP [AnimLoop]
    COP [SolidHighHere]
    COP [StageSpriteLoop] ( #0B, #78 )
    COP [AnimLoop]
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #10, #06, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #0E, #01, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #10, #05, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #0F, #01, #12 )
    COP [AnimLoop]
    COP [SolidHighHere]
    COP [StageSpriteLoop] ( #0B, #78 )
    COP [AnimLoop]
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveY] ( #0E, #01, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #11, #0C, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #0E, #01, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_0482D2 )
    COP [SolidHighHere]
    LDA #$0200
    TSB $12
    COP [SetEntryContinue]
    RTL 
} >
]

code_0482CD {
    COP [PrintWideString] ( &widestring_0482D7 )
    RTL 
}

code_0482D2 {
    COP [PrintWideString] ( &widestring_04835C )
    RTL 
}

widestring_0482D7 `[DEF]Salesman: I travel[N]around to people's[N]houses selling weapons[N]used to fight demons.[FIN]We may live in troubled[N]times, but I won't sell[N]a weapon to a child.[END]`

widestring_04835C `[DEF]Salesman:[N]Hmmm...[END]`