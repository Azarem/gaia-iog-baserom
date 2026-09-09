!joypadMaskStd                  065A

---------------------------------------------

h_sc08_erik [
  actor-def < #0B, #00, #10, {

  code_048CC9:
    COP [BranchIfFlagByte] ( #10, #01, &code_048D00 )
    COP [ExitIfFlagByte] ( #10, #01 )
    COP [StageSpriteLoop] ( #0C, #1E )
    COP [AnimLoop]
    COP [PrintWideString] ( &widestring_048D02 )
    COP [SetFlagByte] ( #01 )
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_048D24 )
    COP [StageSpriteMoveX] ( #11, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #0F, #02 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #11, #02, #01 )
    COP [AnimLoop]
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_048D00 {
    COP [Die]
}

widestring_048D02 `[TPL:B][TPL:5]モリス:[N]じゃ 今日も いつもの[N]ところでっ![PAL:0][END]`

widestring_048D24 `[TPL:B][TPL:3]エリック:[N]ボクは いったん 家に帰ってから[N]行くよ.[FIN]早く帰んないと 補習で[N]残されたことが 母ちゃんに[N]ばれちゃう··· テヘヘ.[PAL:0][END]`