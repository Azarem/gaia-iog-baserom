?INCLUDE 'chunk_008000'
?INCLUDE 'table_0EE000'

!joypadMaskStd                  065A
!gemCount                       0AD6
!chatPtr                        7F000A

---------------------------------------------

h_ec0B_cell [
  actor-def < #23, #00, #38, {

  code_04CCD2:
    COP [BranchIfFlagByte] ( #24, #01, &code_04CDDB )
    COP [SpawnLastRel] ( @code_04D49C, #00, #00, #$2000 )
    COP [SolidHighAbs] ( #0E, #11 )
    COP [SolidHighAbs] ( #0F, #11 )
    LDA #$0800
    TRB $10
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_04CEEC )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [ExitIfFlagByte] ( #04, #01 )
    LDA #$1000
    TRB $10
    COP [SetEntryDelayExit] ( @code_04CD1E, #$04B0 )
    LDA #$1000
    TSB $10
} >
]

code_04CD1E {
    COP [PrintWideString] ( &widestring_04D0A7 )
    COP [SpawnAfterAbsFlags] ( @code_04CE13, #$0108, #$FFD0, #$1002 )
    COP [ExitIfFlagByte] ( #01, #01 )
    LDA #$1000
    TRB $10
    COP [SetEntryDelayExit] ( @code_04CD42, #$0258 )
    LDA #$1000
    TSB $10
}

code_04CD42 {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [PrintWideString] ( &widestring_04D0F7 )
    COP [WaitByte] ( #1D )
    COP [SpawnThinker] ( @chunk_008000.code_00B88D )
    COP [WaitByte] ( #BF )
    COP [PrintWideString] ( &widestring_04D178 )
    COP [SpawnThinker] ( @chunk_008000.code_00B897 )
    COP [WaitByte] ( #BF )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [PrintWideString] ( &widestring_04D1C6 )
    COP [DialogueOptions] ( #02, #02, &code_list_04CD73 )
}

code_list_04CD73 [
  &code_04CD79   ;00
  &code_04CD79   ;01
  &code_04CD79   ;02
]

code_04CD79 {
    COP [PrintWideString] ( &widestring_04D284 )
    COP [SpawnAfterAbsFlags] ( @code_04CEC5, #$00B8, #$FF70, #$0020 )
    COP [SetEntryContinue]
    LDA $gemCount
    BNE loc_04CD90
    RTL 

  loc_04CD90:
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_04D2E0 )
    LDA #$1000
    TRB $10
    COP [SetEntryDelayExit] ( @code_04CDA3, #$012C )
}

code_04CDA3 {
    LDA #$1000
    TSB $10
    LDA #$2000
    TRB $10
    COP [PrintWideString] ( &widestring_04CF5A )
    COP [StageSpriteLoopMoveY] ( #27, #06, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #29, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #27, #12 )
    COP [AnimOnce]
    COP [SpawnAfterRelFlags] ( @code_04CDDD, #$0000, #$FFF0, #$1000 )
    COP [ExitIfFlagByte] ( #23, #01 )
    COP [StageSpriteLoopMoveY] ( #26, #0E, #01 )
    COP [AnimLoop]
}

code_04CDDB {
    COP [Die]
}

code_04CDDD {
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @table_0EE000 )
    COP [SetOnInteract] ( &code_04CDF6 )
    COP [StageSpriteFrame] ( #00 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #23, #01 )
    COP [Die]
}

code_04CDF6 {
    COP [PrintWideString] ( &widestring_04CF6A )
    COP [GiveItem] ( #02, &code_04CE0F )
    COP [SetFlagByte] ( #23 )
    LDA #$0080
    TSB $09FA
    COP [MusicAndText] ( #17, @widestring_04D08C )
    RTL 
}

code_04CE0F {
    JML $@chunk_008000.code_00CAD3
}

code_04CE13 {
    LDA #$0800
    TRB $10
    COP [SetOnInteract] ( #$0000 )
    LDA #$0200
    TSB $12
    COP [StageSpriteLoopMoveY] ( #2A, #03, #07 )
    COP [AnimLoop]
    COP [PlaySoundCh1] ( #1D )
    COP [StageSpriteMoveY] ( #2A, #35 )
    COP [AnimOnce]
    COP [CollPriorityClearMax]
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_04CE3C )
    COP [SetEntryContinue]
    RTL 
}

code_04CE3C {
    COP [PrintWideString] ( &widestring_04CE47 )
    COP [SetFlagByte] ( #01 )
    COP [ClearLowHere]
    COP [Die]
}

widestring_04CE47 `[DLG:3,11][SIZ:D,3,0]テムは パンを ちょっぴり[N]かじってみた.[FIN]それは カチカチに かたまっていて[N]今まで食べた どんな食べ物よりも[N]おいしくなかった.[FIN]ローラおばあちゃんの パイが[N]なぜか ひどくなつかしく[N]感じられた···[END]`

code_04CEC5 {
    COP [SetMetasprite] ( @table_0EE000 )
    LDA #$0085
    STA $chatPtr, X
    COP [StageSpriteMoveY] ( #06, #07 )
    COP [AnimOnce]
    COP [SpawnMarkedAfter] ( @chunk_008000.code_00E24C, #$2300 )
    COP [StageSpriteMoveY] ( #06, #35 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    RTL 
}

widestring_04CEEC `[DLG:3,11][SIZ:D,3,0][TPL:0]テム:[N]なぜ ぼくは こんな目に[N]会わなければ ならないのだろう.[FIN]そして ぼくは これから[N]どうなってしまうのだろう.[FIN]とにかく ここから ぬけ出す[N]方法を 考えなくては···.[PAL:0][END]`

widestring_04CF5A `[TPL:C]ブヒ ブヒッ[PAU:28][CLD]`

widestring_04CF6A `[DLG:3,11][SIZ:D,4,0][TPL:0]テム:[N]このブタは たしか[N]カレンの ペットだっけ···[FIN]おや?[N]しっぽに 手紙と カギが[N]くくりつけてある···.[FIN][TPL:F][PAL:0]手紙は こんな 内容だった.[FIN][TPL:1]┌テムが ろうやに入れられたって[N] 聞いて ビックリしちゃった.[FIN] お父樣に くってかかったけど[N] あたしの言うことなんか ちっとも[N] 聞いてくれないの···.[FIN] あたし もう こんなところに[N] いるのは いやっ.[N] 今夜 城をぬけ出すことにする.[FIN] テムも これで[N] 自由になってねっ.┘[N]            カレン[PAL:0][FIN]`

widestring_04D08C `[CLR][SFX:0][DLY:9]ろうごくのカギを 手に入れた![PAU:FF][END]`

widestring_04D0A7 `[DLG:3,12][SIZ:D,2,0]天井にあいた穴から[N]兵士の 低い声がひびく.[FIN][DLG:3,12][SIZ:D,2,0]今日の配給のパンだ.[N]水は コケでも すするんだな.[END]`

widestring_04D0F7 `[DLG:3,11][SIZ:D,3,0][TPL:0]時が ゆっくりと 流れてゆき[N]やがて 長い長いー日が終った.[FIN]しゅうじんの やり場のない[N]気持ちが 痛いほど[N]わかってしまう···.[FIN]ここを ぬけだす 方法も[N]見つからぬまま ぼくは[N]浅いねむりについた.[PAL:0][END]`

widestring_04D178 `[PAU:78][DLG:3,11][SIZ:D,3,0]うつろな耳に 笛から[N]なつかしい声が ひびく···[FIN][TPL:E][TPL:4]笛:[N]テム···.[FIN]笛:[N]わたしは おまえの父だ,テム.[END]`

widestring_04D1C6 `[PAU:3C][TPL:E][TPL:0]テム:[N]父さん···?[FIN][TPL:4]笛:[N]大きくなったなあ[N]かわいい ぼうずだったのに.[FIN]ローラおばあちゃんの パイは[N]おいしいかい?[FIN][TPL:0]テム:[N]父さん! どこにいるの?![FIN][TPL:4]笛:[N]今は 言えない···[FIN][TPL:F][TPL:4]おまえに ーつ たのみがある.[N]聞いてくれるか?[N][PAL:0] はい,お父さんのたのみなら[N] いやだ,ボクを見すてたくせに!`

widestring_04D284 `[CLD][TPL:F][TPL:4][CLR]笛:[N]どうか,お父さんを[N]手助けに きてほしい···.[FIN]わたしも まえに このろうやに[N]つながれていたことが あるのだ.[N]ほら 左がわのカベを 見なさい.[END]`

widestring_04D2E0 `[DEF][TPL:0]テム:[N]···これは?[FIN][TPL:4]笛:[N]ビルおじいちゃんから なにか[N]聞いてないかい?[FIN][TPL:0]テム:[N]おじいちゃん?[N]建築家だったんでしょ?··[FIN][TPL:4]笛:[N]おじいちゃんはね,[N]その石の 秘密を知っているのだ.[FIN][TPL:0]テム:[N]石のひみつ···?[FIN][TPL:4]笛:[N]おまえは これから[N]少しだけ こわい目にあうことに[N]なるよ.[FIN][TPL:0]テム:[N]こわいこと···?[FIN][TPL:4]笛:[N]敵が 残した石を 拾いなさい.[N]そこには すい星のちからが[N]ふくまれている.[FIN]そのちからは きっと おまえに[N]味方するだろう···[FIN]そして 世界中の 遺跡をめぐり[N]ミステリードールとよばれる 人形を[N]さがしなさい.[FIN]すい星が 近くなればなるほど[N]まものの力は 強くなる···[FIN]テム···[N]時間がない·· 急ぐのだ···[N]まずは インカの遺跡へ···[FIN][PAL:0][SFX:10]笛の声は だんだん 小さくなり[N]やがて 聞こえなくなった.[END]`

code_04D49C {
    COP [AdhocVramDma] ( @gfx_000000+A00, #$4700, #$0200 )
    COP [SetEntryExit]
    COP [BranchIfFlagByte] ( #00, #00, &code_04D49C )
    RTL 
}