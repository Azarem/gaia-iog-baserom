!gfxCacheIdxB                   064A
!joypadMaskStd                  065A

---------------------------------------------

h_sc08_priest [
  actor-def < #35, #00, #10, {

  code_048A04:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_048A4E )
    COP [SolidHighHere]
    COP [BranchIfFlagByte] ( #10, #00, &code_048A18 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_048A18 {
    LDA #$CFF0
    TSB $joypadMaskStd
    LDA #$0400
    STA $gfxCacheIdxB
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_048A5E )
    COP [WaitByte] ( #3B )
    COP [LoopInit] ( #06 )
    COP [PlaySoundBoth] ( #$0909 )
    COP [SetEntryDelayExit] ( @code_048A3C, #$001E )
}

code_048A3C {
    COP [LoopNext]
    COP [WaitByte] ( #3B )
    COP [PrintWideString] ( &widestring_048B54 )
    COP [WaitByte] ( #3B )
    COP [SetFlagByte] ( #10 )
    COP [SetEntryContinue]
    RTL 
}

code_048A4E {
    COP [BranchIfFlagByte] ( #21, #01, &code_048A59 )
    COP [PrintWideString] ( &widestring_048BDD )
    RTL 
}

code_048A59 {
    COP [PrintWideString] ( &widestring_048C21 )
    RTL 
}

widestring_048A5E `[DLG:3,6][SIZ:D,3,0][TPL:0]ぼくの名前は テム.[FIN]父さんと バベルの塔へ[N]探険に行ってから ちょうど 1年の[N]月日が流れた.[FIN]父さんと 隊員たちは そうなんし[N]この町へ 無事に もどったのは[N]ぼくだけ···[FIN]父さんが 死んだなんて 今だに[N]信じられない.[N]いや 信じるつもりもない···[FIN]ぼくは 大きくなったら 探険家に[N]なって 世界中を かけめぐる[N]つもりだ.[FIN]そうすれば どこかで 父さんに[N]会えるような 気がするんだ···[END]`

widestring_048B54 `[DEF]神父:[N]今日の 授業は ここまでに[N]しましょう.[FIN]4人とも 今度は 残されないように[N]がんばるのですよ.[FIN]それから 近ごろ 町の外に 化物が[N]姿を 見せるようになりました.[N]遠出するときは 親と いっしょに[N]行くようにしなさい.[END]`

widestring_048BDD `[DEF]さあ テム.[N]お前も いっしょに いのりなさい.[FIN][DLY:2]おお 神よ.[N]世界が 永遠に かがやきつづけ[N]ますように···[END]`

widestring_048C21 `[DEF]なんですか. テム.[N]人の顔を しげしげと見て···[FIN]また 何か たくらんでるんじゃ[N]ないでしょうね···[END]`