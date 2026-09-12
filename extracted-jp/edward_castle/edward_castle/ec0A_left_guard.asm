!joypadMaskStd                  065A

---------------------------------------------

h_ec0A_left_guard [
  actor-def < #1D, #00, #10, {

  code_04BBA7:
    COP [BranchIfFlagByte] ( #21, #01, &code_04BC0B )
    COP [SetOnInteract] ( &code_04BC1D )
    COP [BranchIfFlagByte] ( #3F, #01, &code_04BBBD )
    LDA #$CFF0
    TSB $joypadMaskStd
} >
]

code_04BBBD {
    COP [StageSpriteLoopMoveX] ( #21, #07, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1D, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1A, #08 )
    COP [AnimLoop]
    COP [BranchIfFlagByte] ( #3F, #01, &code_04BBE3 )
    COP [PrintDialogString] ( &dialogstring_04BCC8 )
    COP [SetFlagByte] ( #3F )
    LDA #$CFF0
    TRB $joypadMaskStd
}

code_04BBE3 {
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
    BRA code_04BBBD
}

code_04BC0B {
    COP [SetOnInteract] ( &code_04BC22 )
    COP [SetTilePos] ( #06, #27 )
    COP [SolidHighHere]
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_04BC1D {
    COP [PrintDialogString] ( &dialogstring_04BC27 )
    RTL 
}

code_04BC22 {
    COP [PrintDialogString] ( &dialogstring_04BC5F )
    RTL 
}

dialogstring_04BC27 `[TPL:A]ここは エドワード国王の城です.[N]国王と 会見するならば[N]2階へ 上がってください.[END]`

dialogstring_04BC5F `[TPL:B]あっ. お前はっ![FIN]よく あの ろうやから[N]ぬけ出せたものだな···.[FIN]悪いことは 言わん.[N]この城から 早く にげるんだな.[N]エドワード王に 見つかったら[N]ただごとじゃ すまないぜ.[END]`

dialogstring_04BCC8 `[TPL:A]兵士: ここは エドワード王の城.[N]国王に えっけんに きたのなら[N]名を なのられよ.[FIN][DLG:3,6][SIZ:D,3,0][TPL:0]テムは 門番に[N]エドワード王の手紙を 見せた.[FIN][TPL:A][PAL:0]兵士: 国王の お客樣でしたか.[N]大変 失礼いたしました.[N]どうぞ お入り下さい.[END]`