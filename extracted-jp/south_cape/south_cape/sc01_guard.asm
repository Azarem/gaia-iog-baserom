!playerSpeedEw                  09B2

---------------------------------------------

h_sc01_guard [
  actor-def < #02, #00, #10, {

  code_0484DA:
    COP [BranchIfFlagByte] ( #27, #01, &code_048541 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    LDA $playerSpeedEw
    CMP #$00B0
    BCS loc_048519
    COP [ClearLowHere]
    COP [SolidHighOffset] ( #FF, #FF )
    COP [SolidHighOffset] ( #FE, #FF )
    COP [StageSpriteMoveX] ( #08, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #07, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #08, #14 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #35, #01, &code_04851A )
    COP [SetOnInteract] ( &code_04854A )
    COP [SetEntryContinue]

  loc_048519:
    RTL 
} >
]

code_04851A {
    COP [SetOnInteract] ( &code_04854F )
    COP [ExitIfFlagByte] ( #27, #01 )
    COP [ClearLowAbs] ( #17, #06 )
    COP [ClearLowAbs] ( #18, #06 )
    COP [StageSpriteMoveX] ( #09, #13 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #06, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #09, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
}

code_048541 {
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_048557 )
    COP [SetEntryContinue]
    RTL 
}

code_04854A {
    COP [PrintWideString] ( &widestring_04855C )
    RTL 
}

code_04854F {
    COP [PrintWideString] ( &widestring_0485BC )
    COP [SetFlagByte] ( #27 )
    RTL 
}

code_048557 {
    COP [PrintWideString] ( &widestring_0485F1 )
    RTL 
}

widestring_04855C `[DEF]こらこら. 近ごろ 町の外には[N]化物が うろついているんだぜ.[FIN]教会の 神父さまから 注意を[N]受けてないのかい?[N]むやみに 町の外へでちゃ[N]ダメだってこと.[END]`

widestring_0485BC `[DEF]えっ? エドワード国王に[N]呼び出されて 城へ行くって?[N]じゃ 気をつけていくんだよ.[END]`

widestring_0485F1 `[DEF]気をつけてな.[END]`