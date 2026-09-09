!joypadMaskStd                  065A

---------------------------------------------

h_sc06_main_soldier [
  actor-def < #1A, #00, #30, {

  code_04A0F5:
    COP [BranchIfFlagByte] ( #1B, #01, &code_04A14B )
    COP [ExitIfFlagByte] ( #04, #01 )
    LDA #$2000
    TRB $10
    COP [SetTilePos] ( #0A, #19 )
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #04, #19, #0E, #1D, &code_04A118 )
    RTL 
} >
]

code_04A118 {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [StageSpriteMoveX] ( #21, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [PrintWideString] ( &widestring_04A14D )
    COP [SetFlagByte] ( #07 )
    COP [ExitIfFlagByte] ( #08, #01 )
    COP [StageSpriteMoveX] ( #21, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #20, #06, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1E, #0A, #11 )
    COP [AnimLoop]
}

code_04A14B {
    COP [Die]
}

widestring_04A14D `[TPL:A]兵士:[N]おひめさま. さがしましたよっ![FIN][TPL:1]カレン:[N]あんた達なんか 知らないわよっ.[N]出てってよっ![FIN][PAL:0][SFX:10]兵士: 何を おっしゃいます.[N]ここで 連れて 帰らなかったら[N]私の 首がとびますっ.[END]`