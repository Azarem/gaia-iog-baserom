!gfxCacheIdxA                   0648
!joypadMaskStd                  065A
!slopeCurvePtrA                 09BA
!INIDISP                        2100
!orbitAngle                     7F0010

---------------------------------------------

h_sc06_bill [
  actor-def < #02, #00, #10, {

  code_049119:
    COP [BranchIfFlagByte] ( #21, #01, &code_049283 )
    COP [BranchIfFlagByte] ( #1C, #01, &code_049276 )
    COP [BranchIfFlagByte] ( #3E, #01, &code_04926E )
    COP [BranchIfFlagByte] ( #1B, #01, &code_0491DE )
    COP [BranchIfFlagByte] ( #16, #01, &code_049140 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_049285 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_049140 {
    COP [SetTilePos] ( #08, #09 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_04928A )
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [WaitByte] ( #1D )
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #59 )
    COP [PrintWideString] ( &widestring_0493A6 )
    COP [StartMusic] ( #06 )
    COP [WriteApuIo1] ( #0A )
    COP [WaitByte] ( #59 )
    COP [SetFlagByte] ( #05 )
    COP [StageSpriteLoop] ( #05, #10 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #02, #10 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #04, #10 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #02, #10 )
    COP [AnimLoop]
    COP [PrintWideString] ( &widestring_0493DA )
    COP [SetOnInteract] ( #$0000 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetFlagByte] ( #06 )
    LDA #$0800
    TSB $10
    COP [ClearLowHere]
    COP [StageSpriteMoveY] ( #06, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #08, #05, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #07, #12 )
    COP [AnimOnce]
    COP [SetTilePos] ( #03, #19 )
    COP [StageSpriteMoveY] ( #06, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #09, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    LDA #$0800
    TRB $10
    COP [ExitIfFlagByte] ( #1B, #01 )
    LDA #$1000
    TSB $12
    COP [FadeThenStartMusic] ( #1C )
    COP [StageSpriteLoopMoveX] ( #09, #05, #11 )
    COP [AnimLoop]
    LDA #$CFF0
    TRB $joypadMaskStd
}

code_0491DE {
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SetTilePos] ( #0A, #1A )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_0492A8 )
    COP [ExitIfFlagByte] ( #0A, #01 )
    COP [PrintWideString] ( &widestring_049428 )
    COP [StageSpriteMoveX] ( #08, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [PrintWideString] ( &widestring_04944D )
    COP [StageSpriteMoveX] ( #09, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SetFlagByte] ( #0B )

  loc_049212:
    COP [SetOnInteract] ( &code_0492AD )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #03, #17, #04, #19, &code_049221 )
    RTL 
}

code_049221 {
    LDA #$CFF0
    TSB $joypadMaskStd
    LDA #$0800
    TSB $10
    COP [LoopInit] ( #09 )
    LDA #$0800
    STA $slopeCurvePtrA
    COP [LoopNext]
    LDA #$000F
    STA $orbitAngle, X

  code_04923E:
    LDA $orbitAngle, X
    DEC 
    BMI loc_049257
    STA $orbitAngle, X
    SEP #$20
    STA $INIDISP
    REP #$20
    COP [SetEntryDelayExit] ( @code_04923E, #$0003 )

  loc_049257:
    LDA #$0001
    STA $gfxCacheIdxA
    COP [QueueMapChange] ( #06, #$0000, #$0200, #00, #$3120 )
    LDA #$CFF0
    TRB $joypadMaskStd
    RTL 
}

code_04926E {
    COP [SetTilePos] ( #0A, #1A )
    COP [SolidHighHere]
    BRA loc_049212
}

code_049276 {
    COP [SetTilePos] ( #0A, #1A )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_049298 )
    COP [SetEntryContinue]
    RTL 
}

code_049283 {
    COP [Die]
}

code_049285 {
    COP [PrintWideString] ( &widestring_0492B2 )
    RTL 
}

code_04928A {
    COP [PrintWideString] ( &widestring_049326 )
    COP [SetFlagByte] ( #03 )
    LDA #$CFF0
    TSB $joypadMaskStd
    RTL 
}

code_049298 {
    COP [BranchIfFlagByte] ( #35, #01, &code_0492A3 )
    COP [PrintWideString] ( &widestring_049637 )
    RTL 
}

code_0492A3 {
    COP [PrintWideString] ( &widestring_04959E )
    RTL 
}

code_0492A8 {
    COP [PrintWideString] ( &widestring_0493F8 )
    RTL 
}

code_0492AD {
    COP [PrintWideString] ( &widestring_0494CB )
    RTL 
}

widestring_0492B2 `[TPL:B][TPL:4]ビル:[N]おお おかえり. こんな時間に[N]帰ってくるところをみると[N]また 残されたんじゃな.[FIN]わっはっは. 結構.結構.[N]男の子は 勉強ができんでも[N]活発なほうが たのもしい[N]もんじゃて.[PAL:0][END]`

widestring_049326 `[TPL:B][TPL:4]ビル:[N]いやはや.[N]久びさに 大声で歌ったわい.[FIN]ローラばあさんは むかし 酒場の[N]歌ひめを やっとったんじゃ.[FIN]わしは ばあさんの 美しい声と心に[N]ほれて プロポーズ したんじゃよ.[N]ふぁっ ふぁっ ふぁっ.[PAL:0][END]`

widestring_0493A6 `[TPL:8][TPL:1][DLY:0]いやーーーーーーーーーっ!!![FIN][PAL:0][DLY:1][SFX:10]ー階から 悲鳴が ひびきわたった![END]`

widestring_0493DA `[TPL:9][TPL:4]ビル:[N]さっきの子の 悲鳴じゃっ!![PAL:0][END]`

widestring_0493F8 `[TPL:A][TPL:4]ビル: まったく じょうだんの[N]好きな娘じゃよ.[N]ふぁっ ふぁっ ふぁっ.[PAL:0][END]`

widestring_049428 `[PAU:1E][TPL:A][TPL:4]ビル: わしは[N]むかし 建築家じゃったからな.[PAL:0][END]`

widestring_04944D `[TPL:A][TPL:4]あの城の 地下には[N]ろうやがあってな.[FIN]しゅうじんが かんたんに[N]ぬけ出せないよう 複雑なしくみに[N]なって おるのじゃよ.[FIN]しかし わしの作った ろうやで[N]日々 人が さばかれていくのは[N]複雑な心境じゃな···[PAL:0][END]`

widestring_0494CB `[TPL:A][TPL:4]ビル: なあ テム.[N]近ごろ ローラばあさんの料理って[N]おかしなものばかりだと 思わんか?[FIN]夕べは ミソごはん.[N]その前は サシミのカレーあえじゃ.[N]食べるほうは たまらんわい···[FIN]人は 年老いて[N]どうにもならん問題が 身のまわりに[N]あると ボケ始めると言うが,[FIN]ばあさんは 何か わしらに言えない[N]なやみを かかえとるんじゃ[N]なかろうか···[PAL:0][END]`

widestring_04959E `[TPL:B][TPL:4]ビル:[N]水しょうの指輪···[N]うーむ 聞いたことも ないな.[FIN]お前の父 オールマンの 残した[N]荷物にも そんなものは[N]なかったし···[FIN]とにかく エドワード城へ[N]行ってみたら どうじゃ?[N]昨日の おひめ樣にも会えるしの.[N]ふぁっ ふぁっ ふぁっ.[PAL:0][END]`

widestring_049637 `[TPL:A][TPL:4]ビル: おはよう.[N]今朝も ローラばあさんの パイを[N]食べさせられたよ··· トホホ[PAL:0][END]`