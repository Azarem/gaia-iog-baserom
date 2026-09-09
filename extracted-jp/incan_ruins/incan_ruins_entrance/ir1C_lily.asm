?INCLUDE 'chunk_008000'

!joypadMaskStd                  065A
!decelStepCounter               09B8
!slopeCurvePtrB                 09BC
!characterForm                  0AD4
!orbitAngle                     7F0010
!orbitDiameter                  7F0012

---------------------------------------------

h_ir1C_lily [
  actor-def < #1D, #00, #10, {

  code_0585D0:
    COP [BranchIfFlagByte] ( #4B, #01, &chunk_058000.code_05867F )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &chunk_058000.widestring_0586B3 )
    COP [SolidHighAbs] ( #06, #19 )
    COP [SolidHighAbs] ( #07, #19 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SpawnAfterFlags] ( @chunk_008000.code_00C94B, #$2000 )
    TXA 
    TYX 
    TAY 
    LDA #$0003
    STA $orbitAngle, X
    LDA #$001A
    STA $orbitDiameter, X
    TXA 
    TYX 
    TAY 
    COP [SetOnInteract] ( #$0000 )
    LDA #$0800
    TSB $10
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [BranchIfFlagByte] ( #01, #01, &chunk_058000.code_058622 )
    RTL 
} >
]

code_058622 {
    LDA #$0800
    TRB $10
    COP [KillNext]
    COP [ClearLowAbs] ( #06, #19 )
    COP [ClearLowAbs] ( #07, #19 )
    COP [ExitIfFlagByte] ( #03, #01 )
    LDA #$0000
    JSL $@chunk_008000.widestring_00C829
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [PrintWideString] ( &chunk_058000.widestring_0588A5 )
    COP [SetFlagByte] ( #02 )
    COP [ExitIfFlagByte] ( #02, #00 )
    LDA $16
    AND #$FFF0
    STA $16
    COP [StageSpriteMoveY] ( #1E, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #1A, #06 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1C, #06 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1B, #14 )
    COP [AnimLoop]
    COP [PrintWideString] ( &chunk_058000.widestring_0589FB )
    COP [SetFlagByte] ( #4B )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [StageSpriteLoopMoveX] ( #20, #04, #12 )
    COP [AnimLoop]
}

code_05867F {
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [SetTilePos] ( #16, #13 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &chunk_058000.code_0586AE )
    LDA $characterForm
    BEQ chunk_058000.loc_0586AB
    LDY $decelStepCounter
    SEP #$20
    LDA #$88
    STA $0002, Y
    REP #$20
    LDA #$EC6A
    STA $0000, Y
    LDA #$0800
    TSB $slopeCurvePtrB

  loc_0586AB:
    COP [SetEntryContinue]
    RTL 
}

code_0586AE {
    COP [PrintWideString] ( &chunk_058000.widestring_0589FB )
    RTL 
}

widestring_0586B3 `[DLG:3,11][SIZ:D,4,0][TPL:2]リリィ:[N]ここが インカのイセキの入口.[FIN]インカっていっても 広くってね,[N]ここは インカ伝說の ナゾが[N]かくされているって いわれる場所.[FIN]あたしが まだ ちっちゃいころ[N]長老樣から こんな話を[N]聞いたことがあるんだけど···[FIN]かつて インカが しゅうげきを[N]受けたとき 祖国をすてて[N]新天地を 求めようという[N]計画があったらしいの.[FIN]しんりゃく者の目を ぬすんで[N]きょだいな船が 建造され,[N]最も 賁重な 黄金細工とともに[N]インカ人達が 乗りこんだというわ.[FIN]でもね その船が出航したという[N]記録は 残ってないんだって···[FIN]たぶん インカにねむる 黄金船[N]っていうのは その船のことなんで[N]しょうね.[FIN]長老樣は これまで イトリー族[N]以外の人に この言い伝えを[N]話したことが ないはず.[FIN]長老樣は テムに 何をさせようと[N]してるんだろ···[PAL:0][END]`

widestring_058886 `[DLG:3,6][SIZ:D,3,0][TPL:2]リリィ:[N]ちょっと どこへ いくのよぉ[END]`

widestring_0588A5 `[DLG:3,6][SIZ:D,3,0][TPL:2]リリィ: なんで あなたが[N]こんな場所に いるのっ![N]あぶないじゃない!![FIN][TPL:1]カレン: ローラおばあさまから[N]この場所を 聞きだして[N]何時間も 待ってたのよっ![FIN]もう おいて いかれたのかと[N]思ったわ. せめて 行き先くらい[N]言ってくれたって いいじゃない![FIN]それに テムは イセキで[N]何かを さがしてるんでしょう?[FIN]テムが がんばってるのに[N]あたしだけ 村で のんびり[N]ごはんなんか 食べてられないわ.[FIN]あたし ここで テムが[N]もどってくるのを 待ってる.[FIN][TPL:2]リリィ: やれやれ.[N]これだもの おじょうさまは···[FIN]わかった. あたしも[N]つきあって ここで 待ってる.[N]それでいいんでしょ?[END]`

widestring_0589FB `[DLG:3,6][SIZ:D,3,0][TPL:2]リリィ:[N]テム. 長老樣の言葉を よく[N]思い出してね.[FIN]┌遺跡の地下の ラライのガケにて[N] 神の息のとどかぬところへ[N] インカの神をおさめよ.[FIN] 谷風が その者を黄金船のもとへ[N] 導くであろう.┘っていう言葉,[N]ちゃんと 覚えてる?[PAL:0][END]`