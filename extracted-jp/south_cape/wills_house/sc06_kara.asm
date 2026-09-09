?INCLUDE 'chunk_008000'

!joypadMaskStd                  065A

---------------------------------------------

h_sc06_kara [
  actor-def < #12, #00, #30, {

  code_049B8D:
    COP [BranchIfFlagByte] ( #1B, #01, &code_049C7E )
    COP [BranchIfFlagByte] ( #3D, #01, &code_049C80 )
    COP [BranchIfFlagByte] ( #16, #00, &code_049C7E )
    COP [ExitIfFlagByte] ( #01, #01 )
    LDA #$2000
    TRB $10
    COP [StageSpriteLoopMoveY] ( #16, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #19, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #15 )
    COP [AnimOnce]
    COP [PrintWideString] ( &widestring_049C92 )
    LDA #$0002
    JSL $@chunk_008000.widestring_00C829
    COP [StageSpriteMoveX] ( #19, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveY] ( #17, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #19, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #12, #3C )
    COP [AnimLoop]
    LDA #$0001
    JSL $@chunk_008000.widestring_00C829
    COP [SetEntryExit]
    COP [PrintWideString] ( &widestring_049CE6 )
    COP [SetFlagByte] ( #02 )
    COP [StageSpriteLoopMoveX] ( #19, #03, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #13 )
    COP [AnimOnce]
    LDA #$0003
    JSL $@chunk_008000.widestring_00C829
    COP [SetEntryExit]
    COP [PrintWideString] ( &widestring_049D33 )
    COP [StageSpriteLoop] ( #14, #10 )
    COP [AnimLoop]
    COP [PrintWideString] ( &widestring_049D74 )
    COP [StageSpriteLoop] ( #13, #18 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #14, #18 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #12, #18 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #14, #1E )
    COP [AnimLoop]
    COP [SolidHighHere]
    COP [PrintWideString] ( &widestring_049DF6 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetFlagByte] ( #3D )

  loc_049C38:
    COP [SetOnInteract] ( &code_049C8D )
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [ClearLowHere]
    COP [SetTilePos] ( #0D, #19 )
    COP [StageSpriteFrame] ( #14 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #07, #01 )
    COP [StageSpriteLoop] ( #15, #1E )
    COP [AnimLoop]
    COP [PrintWideString] ( &widestring_049E86 )
    COP [SetFlagByte] ( #08 )
    COP [WaitByte] ( #1F )
    COP [StageSpriteLoopMoveX] ( #15, #E0, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #13, #A0, #11 )
    COP [AnimLoop]
    COP [SetFlagByte] ( #09 )
    COP [PrintWideString] ( &widestring_049F16 )
    COP [StageSpriteLoopMoveY] ( #16, #04, #11 )
    COP [AnimLoop]
    COP [SetFlagByte] ( #1B )
} >
]

code_049C7E {
    COP [Die]
}

code_049C80 {
    COP [SetTilePos] ( #0A, #19 )
    COP [SolidHighHere]
    LDA #$2000
    TRB $10
    BRA loc_049C38
}

code_049C8D {
    COP [PrintWideString] ( &widestring_049E81 )
    RTL 
}

widestring_049C92 `[TPL:A][TPL:1]カレン:[N]あらあら ペギーちゃん.[N]知らない人を いじめちゃダメよ.[FIN]あなた,ここの家の子?[FIN][TPL:0]テム:[N]むっ··· そうだけど?[PAL:0][END]`

widestring_049CE6 `[TPL:9][TPL:1]カレン:[N]なんだか さえない身なりね.[FIN][TPL:0]テム:[N]わるかったな![FIN][TPL:1]カレン: お父さまは?[N]お母さまは? いないのね.[PAL:0][END]`

widestring_049D33 `[DLG:3,13][SIZ:D,2,0][TPL:1]カレン:[N]この絵が ご両親?[FIN][TPL:0]テム: そうだよ.[N]父さんは 探険に 行って···[PAL:0][END]`

widestring_049D74 `[TPL:A][TPL:1]カレン: 知ってるわよ.[N]オールマン探険隊でしょ,[N]そうなんしたのよね.[FIN][TPL:0]テム:[N]いつか きっと 帰ってくるさ.[FIN][TPL:1]カレン:[N]おこったの?[N]···ちがうわね.[FIN]悲しませたのね,あたしったら··[N]ごめんなさい···[PAL:0][END]`

widestring_049DF6 `[TPL:A][TPL:1]カレン:[N]ところで この家,[N]ピアノも ないのね.[FIN][TPL:0]テム: ないよっ,そんなもの![N]でも,ローラおばあちゃんは[N]ものすごく歌が うまいんだぞ.[FIN][::][TPL:1]カレン:[N]歌なら 今 2階で歌ってるわよ.[N]二人とも声が大きいのなんの.[PAL:0][END]`

widestring_049E81 `[TPL:A][JMP:&sc06_kara.widestring_049DF6+M]`

widestring_049E86 `[TPL:A][TPL:7]カレン: 人ちがいでしょっ.[N]あたしは 花売り娘のボボンゴって[N]いうのよ.[FIN][PAL:0]兵士: おひめさま![N]そんな [TPL:7]真っ赤な[PAL:0]ウソに[N]だまされると 思ってるんですかっ.[FIN]これは 国王の ご命皮なのです.[N]力づくでも 連れて帰りますよ![END]`

widestring_049F16 `[TPL:B][TPL:1]カレン:[N]ウソついて ごめんね.[N]あたしは エドワード城の カレン.[FIN]テムって 言ったかしら?[N]あなたとは 初めて会うっていう[N]気がしないのよね.[N]なんだか いいお友達になれそう.[PAL:0][END]`