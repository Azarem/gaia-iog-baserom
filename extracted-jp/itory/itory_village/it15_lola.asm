?INCLUDE 'chunk_008000'

!joypadMaskStd                  065A

---------------------------------------------

h_it15_lola [
  actor-def < #32, #00, #10, {

  code_04E857:
    COP [SetOnInteract] ( &code_04E8C5 )
    COP [SolidHighHere]
    COP [BranchIfFlagByte] ( #47, #01, &code_04E877 )
    COP [BranchIfFlagByte] ( #3B, #01, &code_04E874 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #40, #26, #42, #28, &code_04E87D )
    RTL 
} >
]

code_04E874 {
    COP [SetEntryContinue]
    RTL 
}

code_04E877 {
    COP [SetOnInteract] ( &code_04E8CA )
    BRA code_04E874
}

code_04E87D {
    COP [SetFlagByte] ( #3B )
    LDA #$CFF0
    TSB $joypadMaskStd
    LDA #$0003
    JSL $@chunk_008000.widestring_00C829
    COP [StageSpriteFrame] ( #34 )
    COP [AnimOnce]
    COP [PrintWideString] ( &widestring_04E8CF )
    COP [StageSpriteLoop] ( #32, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #35, #08 )
    COP [AnimLoop]
    COP [PrintWideString] ( &widestring_04E972 )
    COP [StageSpriteLoop] ( #32, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #34, #08 )
    COP [AnimLoop]
    COP [PrintWideString] ( &widestring_04E9D5 )
    COP [SetFlagByte] ( #04 )
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [StageSpriteFrame] ( #32 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
}

code_04E8C5 {
    COP [PrintWideString] ( &widestring_04EA14 )
    RTL 
}

code_04E8CA {
    COP [PrintWideString] ( &widestring_04EA38 )
    RTL 
}

widestring_04E8CF `[TPL:E][TPL:3]ローラ: テム! テム![N]こっちよ![FIN][TPL:4]ビル:[N]無事だったのか,[N]よかった よかった···[FIN][TPL:3]ローラ:[N]あたしたち とても こわい目に[N]あったのよ![FIN]ブラックパンサーとかいう男が[N]兵士を おおぜいつれて[N]やってきて···[FIN][TPL:4]ビル: あやうく[N]殺されるとこじゃった![PAL:0][END]`

widestring_04E972 `[TPL:E][TPL:3]ローラ: おじいさんったら[N]オタオタしちゃって.[FIN]あたしの 毒リンゴパイで[N]兵士たちの オナカをこわして[N]やったのさ.[FIN]そのあいだに やっとこ[N]にげだしたんだよ.[PAL:0][END]`

widestring_04E9D5 `[TPL:F][TPL:3]ローラ: そうそう.[N]リリィ,ご苦労樣でした.[N]それに カレンひめさま まで[N]ごいっしょとは.[PAL:0][END]`

widestring_04EA14 `[TPL:F][TPL:3]ローラ: なんだか[N]イヤな予感がするんですよ.[PAL:0][END]`

widestring_04EA38 `[TPL:F][TPL:3]ローラ:[N]この村には むかしから[N]いい伝えがあってね,[FIN]善なる心をもって[N]ヤミの力をあやつる 子供が現われ,[N]世界を救うために 旅立つだろう··[FIN]その者が 現われるとき,[N]きょだいな すい星が 地のふちを[N]かすめ 大いなるヤミの力が[N]復活するであろう···[FIN]これが イトリー族に伝わる[N]言葉なんだよ.[PAL:0][END]`