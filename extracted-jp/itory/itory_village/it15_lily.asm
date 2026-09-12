?INCLUDE 'chunk_008000'

!joypadMaskStd                  065A
!cameraTargetY                  06C2
!cameraBoundsY                  06DC
!decelStepCounter               09B8
!CGWSEL                         2130
!CGADSUB                        2131

---------------------------------------------

h_it15_lily [
  actor-def < #1A, #00, #10, {

  code_04DBB8:
    COP [BranchIfFlagByte] ( #2B, #00, &code_04DBCB )
    COP [BranchIfFlagByte] ( #3B, #01, &code_04DCDE )
    COP [SetTilePos] ( #41, #26 )
    JMP $&code_04DCAA
} >
]

code_04DBCB {
    COP [BranchIfFlagByte] ( #26, #00, &code_04DCDE )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_04DCE7 )
    LDA #$6000
    TRB $joypadMaskStd
    LDA #$1000
    TRB $10

  code_04DBE9:
    COP [SetEntryContinue]
    COP [BranchIfFlagByte] ( #40, #01, &code_04DBF8 )
    COP [BranchIfButton] ( #$0F01, &code_04DCE0 )
    RTL 
}

code_04DBF8 {
    LDA #$1000
    TSB $10
    LDA #$EFF0
    TSB $joypadMaskStd
    SEP #$20
    LDA #$80
    STA $CGWSEL
    LDA #$03
    STA $CGADSUB
    REP #$20
    COP [SpawnThinker] ( @chunk_008000.code_00B879 )
    COP [WaitByte] ( #7F )
    COP [SetFlagByte] ( #01 )
    COP [LoopInit] ( #10 )
    LDA $cameraTargetY
    SEC 
    SBC #$0010
    STA $cameraTargetY
    LDY $decelStepCounter
    LDA $0016, Y
    SEC 
    SBC #$0010
    STA $0016, Y
    LDA $16
    SEC 
    SBC #$0010
    STA $16
    COP [LoopNext]
    LDA #$0300
    STA $cameraBoundsY
    COP [ClearFlagByte] ( #01 )
    COP [WaitByte] ( #3B )
    COP [SpawnThinker] ( @chunk_008000.code_00B883 )
    COP [WaitByte] ( #9D )
    COP [WaitByte] ( #59 )
    COP [PrintDialogString] ( &dialogstring_04DD7F )
    COP [SetFlagByte] ( #02 )
    COP [ExitIfFlagByte] ( #03, #01 )
    LDA #$EFF0
    TRB $joypadMaskStd
    COP [SetFlagByte] ( #2B )
    LDA #$0800
    TSB $10
    COP [StageSpriteMoveY] ( #1E, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #21, #01 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #1E, #02, #01 )
    COP [AnimLoop]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [StageSpriteLoopMoveX] ( #21, #06, #01 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #1E, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #21, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1F, #06, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #21, #11 )
    COP [AnimOnce]
}

code_04DCAA {
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    LDA #$0800
    TRB $10
    COP [ExitIfFlagByte] ( #04, #01 )
    LDA #$0001
    JSL $@chunk_008000.dialogstring_00C829
    COP [StageSpriteFrame] ( #1A )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_04DE03 )
    LDA #$0800
    TSB $10
    COP [StageSpriteLoopMoveY] ( #1F, #02, #12 )
    COP [AnimLoop]
    COP [SetFlagByte] ( #05 )
    COP [StageSpriteLoopMoveY] ( #1F, #04, #12 )
    COP [AnimLoop]
}

code_04DCDE {
    COP [Die]
}

code_04DCE0 {
    COP [PrintDialogString] ( &dialogstring_04DD52 )
    JMP $&code_04DBE9
}

dialogstring_04DCE7 `[TPL:E][TPL:2]リリィ: ここが あたしの村.[N]っていっても 家も 何にもなくて[N]びっくりしたでしょ?[FIN]テム. エドワード城の地下で[N]あたしを 呼んだときのメロディを[N]ふいてみてくれる?[PAL:0][END]`

dialogstring_04DD52 `[TPL:E][TPL:2]リリィ:[N]テム. どこにいくの?[N]ここで メロディをふいてよっ.[PAL:0][END]`

dialogstring_04DD7F `[TPL:E][TPL:2]リリィ:[N]おどろいた?[FIN]このイトリー村には 結界があって[N]ふつうの人には 見えないの.[FIN]しかし おじょうさまにも[N]困ったものよねぇ···[FIN]山道じゃ 足が痛いだの[N]のどがかわいた だのって[N]耳が おかしくなりそうだったわ.[PAL:0][END]`

dialogstring_04DE03 `[TPL:E][TPL:2]リリィ: だってさあ[N]勝手についてくるんだもん.[FIN]テム. この家が あたしの家なの.[N]村を 見物したければしてもいいけど[N]あとで ここへ もどってきてね.[PAL:0][END]`