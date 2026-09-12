?INCLUDE 'chunk_008000'

!joypadMaskStd                  065A
!APUIO1                         2141

---------------------------------------------

h_sc06_lola [
  actor-def < #0B, #00, #10, {

  code_049676:
    COP [BranchIfFlagByte] ( #21, #01, &code_0497CA )
    COP [BranchIfFlagByte] ( #1C, #01, &code_049779 )
    COP [BranchIfFlagByte] ( #3E, #01, &code_04976C )
    COP [BranchIfFlagByte] ( #1B, #01, &code_049745 )
    COP [BranchIfFlagByte] ( #16, #01, &code_04969D )
    COP [SetOnInteract] ( &code_0497CC )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_04969D {
    COP [SetTilePos] ( #07, #09 )
    COP [SolidHighHere]
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [SetOnInteract] ( &code_0497D1 )
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [StageSpriteLoop] ( #0D, #1E )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_04983B )
    COP [SetFlagByte] ( #04 )
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [WaitByte] ( #0B )
    COP [StageSpriteLoop] ( #0D, #10 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0A, #10 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0C, #10 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0A, #10 )
    COP [AnimLoop]
    COP [SetOnInteract] ( #$0000 )
    COP [ExitIfFlagByte] ( #06, #01 )
    LDA #$0800
    TSB $10
    COP [WaitByte] ( #3F )
    COP [ClearLowHere]
    COP [StageSpriteMoveY] ( #0E, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #10, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #0F, #12 )
    COP [AnimOnce]
    COP [SetTilePos] ( #03, #19 )
    COP [LoopInit] ( #02 )
    COP [StageSpriteMoveY] ( #0E, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #11, #11 )
    COP [AnimOnce]
    COP [LoopNext]
    COP [StageSpriteFrame] ( #0D )
    COP [AnimOnce]
    LDA #$0800
    TRB $10
    COP [ExitIfFlagByte] ( #1B, #01 )
    LDA #$1000
    TSB $12
    COP [StageSpriteLoopMoveX] ( #11, #03, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #0F, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #11, #04, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #0E, #02, #11 )
    COP [AnimLoop]
}

code_049745 {
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [SetTilePos] ( #0C, #1B )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_0497D6 )
    COP [ExitIfFlagByte] ( #0B, #01 )
    COP [PrintDialogString] ( &dialogstring_049971 )
    COP [SetFlagByte] ( #3E )
    LDA #$CFF0
    TRB $joypadMaskStd

  loc_049765:
    COP [SetOnInteract] ( &code_0497E4 )
    COP [SetEntryContinue]
    RTL 
}

code_04976C {
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [SetTilePos] ( #0C, #1B )
    COP [SolidHighHere]
    BRA loc_049765
}

code_049779 {
    COP [SetTilePos] ( #0C, #1B )
    COP [SetOnInteract] ( &code_0497E9 )
    COP [SolidHighHere]
    COP [StageSpriteFrame] ( #0C )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #35, #01, &code_0497C7 )
    COP [SetEntryContinue]
    COP [BranchIfNoItem] ( #09, &code_049796 )
    RTL 
}

code_049796 {
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [SetFlagByte] ( #35 )
    COP [StartMusic] ( #19 )
    COP [WaitByte] ( #59 )
    COP [PrintDialogString] ( &dialogstring_049B0E )
    COP [SetEntryContinue]
    SEP #$20
    LDA $APUIO1
    REP #$20
    AND #$00FF
    CMP #$00FF
    BEQ loc_0497BB
    RTL 

  loc_0497BB:
    COP [StartMusic] ( #1C )
    COP [WaitByte] ( #59 )
    LDA #$FFF0
    TRB $joypadMaskStd
}

code_0497C7 {
    COP [SetEntryContinue]
    RTL 
}

code_0497CA {
    COP [Die]
}

code_0497CC {
    COP [PrintDialogString] ( &dialogstring_049802 )
    RTL 
}

code_0497D1 {
    COP [PrintDialogString] ( &dialogstring_0498B6 )
    RTL 
}

code_0497D6 {
    COP [PrintDialogString] ( &dialogstring_049901 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [SetFlagByte] ( #0A )
    RTL 
}

code_0497E4 {
    COP [PrintDialogString] ( &dialogstring_049973 )
    RTL 
}

code_0497E9 {
    COP [BranchIfFlagByte] ( #35, #01, &code_0497F9 )
    COP [PrintDialogString] ( &dialogstring_0499D7 )
    COP [GiveItem] ( #09, &code_0497FE )
    RTL 
}

code_0497F9 {
    COP [PrintDialogString] ( &dialogstring_049B6F )
    RTL 
}

code_0497FE {
    JML $@chunk_008000.code_00CAD3
}

dialogstring_049802 `[DEF][TPL:3]ローラ:[N]おや テム. おかえり.[N]夕食まで 時間があるから[N]外で 遊んでおいで.[PAL:0][END]`

dialogstring_04983B `[TPL:A][TPL:3]ローラ: おーほっほほほーっ.[N]いやだねぇ おまえさん![N]今ごろ そんなことを もちだして.[FIN]そうだ! テム.[N]聞いて おどろいちゃいけないよ.[FIN]さっきまで ここで いっしょに[N]歌っていた 女の子はね···[PAL:0][END]`

dialogstring_0498B6 `[TPL:B][TPL:3]ローラ: おかえり テム.[N]あたしったら オペラを歌ってたら[N]時の立つのもわすれて···[N]夕ごはん できてないのよ.[PAL:0][END]`

dialogstring_049901 `[TPL:A][TPL:3]ローラ:[N]エドワード城って言えば[N]地下に 広大な水路があってね.[FIN]その迷宮の水路を 作ったのは[N]何をかくそうこの人なんだよ テム.[FIN][TPL:0]テム:[N]ええっ! ほんとに?[PAL:0][END]`

dialogstring_049971 `[PAU:40]`

dialogstring_049973 `[TPL:A][TPL:3]ローラ:[N]さて. かた苦しい話はやめて[N]そろそろ 夕ごはんにしましょ.[FIN]おいしい パイを やいたからね.[N]さあ 二人とも 二階で[N]テーブルに ついていておくれ.[PAL:0][END]`

dialogstring_0499D7 `[TPL:B][TPL:3]ローラ:[N]おはよう テム.[N]お前に エドワード国王から[N]手紙が 届いているよ.[FIN][PAL:0][DLG:3,6][SIZ:D,4,0]手紙には こんなことが[N]書かれていた.[FIN][TPL:B][TPL:4]オールマンの 所持品である[N]水しょうの指輪を[N]エドワード城まで 持参されたし.[N]        国王 エドワード[FIN][TPL:3]ローラ:[N]この手紙を 見たときから[N]なんだか 悪い虫が さわぐんだよ.[FIN]そうだ. テム.[N]おまじないを ーつ 教えておくわ.[N]困ったときに このメロディーを[N]ふけば きっと のりきれるからね.[FIN]ローラは 不思議なメロディを[N]口ずさんだ.[PAL:0][END]`

dialogstring_049B0E `[TPL:A][TPL:0][SFX:0][DLY:5]それは すてきな メロディだった.[N][PAU:78][CLR]はじめて 聞いたはずなのに[N]なんだか とっても なつかしい[N]感じがした.[PAU:F0][CLR][PAL:0]ローラの メロディをおぼえた![PAU:FF][CLD]`

dialogstring_049B6F `[TPL:B][TPL:3]ローラ:[N]気をつけて いくんだよ.[PAL:0][END]`