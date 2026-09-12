?INCLUDE 'chunk_008000'

!joypadMaskStd                  065A

---------------------------------------------

h_sc06_lily [
  actor-def < #36, #00, #30, {

  code_04A86D:
    COP [BranchIfFlagByte] ( #26, #01, &code_04A904 )
    COP [BranchIfFlagByte] ( #25, #01, &code_04A906 )
    COP [BranchIfFlagByte] ( #21, #00, &code_04A94B )
    COP [ExitIfFlagByte] ( #01, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    LDA #$2000
    TRB $10
    COP [StageSpriteLoopMoveY] ( #36, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #36, #03, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #36, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #22, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #24, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #23, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #25, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #22, #3C )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    LDA #$0002
    JSL $@chunk_008000.dialogstring_00C829
    COP [SetEntryExit]
    COP [PrintDialogString] ( &dialogstring_04A97D )
    COP [SetFlagByte] ( #02 )
    COP [ExitIfFlagByte] ( #02, #00 )
    COP [StageSpriteLoop] ( #22, #28 )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_04A9B1 )
    COP [StageSpriteLoop] ( #25, #28 )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_04A9E3 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_04A94D )
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [SetOnInteract] ( &code_04A955 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_04A904 {
    COP [Die]
}

code_04A906 {
    COP [SetTilePos] ( #08, #1B )
    LDA #$2000
    TRB $10
    COP [SetOnInteract] ( &code_04A95A )
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #04, #01 )
    COP [ClearLowHere]
    COP [StageSpriteMoveY] ( #27, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #29, #11 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [StageSpriteMoveX] ( #29, #13 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_04ABF8 )
    COP [ClearFlagByte] ( #02 )
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [PrintDialogString] ( &dialogstring_04AC1C )
    COP [ClearFlagByte] ( #03 )
    COP [SetEntryContinue]
    RTL 
}

code_04A94B {
    COP [Die]
}

code_04A94D {
    COP [PrintDialogString] ( &dialogstring_04AAC6 )
    COP [SetFlagByte] ( #04 )
    RTL 
}

code_04A955 {
    COP [PrintDialogString] ( &dialogstring_04AB12 )
    RTL 
}

code_04A95A {
    COP [PrintDialogString] ( &dialogstring_04AB41 )
    COP [DialogueOptions] ( #02, #02, &code_list_04A964 )
}

code_list_04A964 [
  &code_04A96A   ;00
  &code_04A96F   ;01
  &code_04A96A   ;02
]

code_04A96A {
    COP [PrintDialogString] ( &dialogstring_04AB6B )
    RTL 
}

code_04A96F {
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [PrintDialogString] ( &dialogstring_04AB9C )
    COP [SetFlagByte] ( #04 )
    RTL 
}

dialogstring_04A97D `[TPL:E][TPL:2]リリィ:[N]ご安心あれ,おふたりさん.[FIN][TPL:0]テム:[N]あ. 君は さっきの···[PAL:0][END]`

dialogstring_04A9B1 `[TPL:E][TPL:2]リリィ: イトリー族の村.[FIN][TPL:1]カレン:[N]そんな村,きいたこともないわ![END]`

dialogstring_04A9E3 `[TPL:E][TPL:2]リリィ: 当然よ. あたしの村には[N]結界がはってあって ふつうの[N]人間には 見えやしないもんねっ.[FIN]リリィ:[N]さあ 行こっ. テム![FIN][TPL:0]テム: うん![FIN][TPL:1]カレン:[N]あたしも ついて行く![FIN][TPL:2]リリィ:[N]おひめさまには キケンだよっ.[FIN][TPL:1]カレン: 絕対に ついて行くもん![N]これで あたし ほんとに[N]自由になれるのねっ!![FIN][TPL:2]リリィ:[N]これだもの おじょうさまったら.[PAL:0][END]`

dialogstring_04AAC6 `[TPL:E][TPL:2]リリィ:[N]あたしの村へ 行くまえに[N]町のみんなに 会ってきたら?[FIN]しばらく ここへは もどって[N]こられないかも しれないわよ.[PAL:0][END]`

dialogstring_04AB12 `[TPL:E][TPL:2]リリィ: えっ? もういいの?[N]ちょっとは 町のようすを[N]ながめてきたら?[PAL:0][END]`

dialogstring_04AB41 `[TPL:B][TPL:2]リリィ:[N]旅立つ 決心は できたわけね?[N][PAL:0] はい[N] いいえ`

dialogstring_04AB6B `[CLR][TPL:2]リリィ:[N]そうね.[N]じゃ 旅立つ 心がまえができたら[N]ここへ もどってきて.[PAL:0][END]`

dialogstring_04AB9C `[CLR][TPL:1]カレン:[N]この先 何か すてきなことが[N]待っているような 気がする.[FIN][TPL:2]リリィ:[N]いいえ これからが[N]苦労の連続だわ きっと···.[N]ふうぅっ···.[END]`

dialogstring_04ABF8 `[TPL:A][TPL:2]リリィ:[N]そっちこそ[N]お城の外へ 出たことがあるの?[END]`

dialogstring_04AC1C `[TPL:A][TPL:2]リリィ:[N]なんですって,世間知らずっ![FIN]リリィ:[N]テムは あたしの おともだち.[N]わかったわね?[END]`