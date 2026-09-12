?INCLUDE 'sc02_card'

!joypadMaskStd                  065A

---------------------------------------------

h_sc02_lance [
  actor-def < #32, #00, #10, {

  code_04AD66:
    COP [BranchIfFlagByte] ( #4C, #01, &code_04AE69 )
    COP [SolidHighHere]
    LDA #$0200
    TSB $12
    COP [BranchIfFlagByte] ( #20, #01, &code_04AE5D )
    COP [BranchIfFlagByte] ( #16, #01, &code_04AE53 )
    COP [SetOnInteract] ( &code_04AE8F )
    LDA #$0800
    TSB $10

  code_04AD88:
    COP [StageSpriteFrame] ( #32 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #03, #00, &code_04AD88 )
    LDA #$0800
    TRB $10
    LDA #$0200
    TRB $12
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #03, #00 )
    COP [SetOnInteract] ( &code_04AE97 )
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [SetOnInteract] ( &code_04AE9C )
    COP [ExitIfFlagByte] ( #06, #01 )
    COP [CallScript] ( &code_04AE6B )
    COP [SetOnInteract] ( &code_04AEBC )
    COP [ExitIfFlagByte] ( #07, #01 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StageSpriteMoveX] ( #08, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveY] ( #06, #03, #11 )
    COP [AnimLoop]
    COP [LoopInit] ( #04 )
    COP [StageSpriteMoveX] ( #09, #11 )
    COP [AnimOnce]
    COP [StageSpriteLoop] ( #03, #1E )
    COP [AnimLoop]
    COP [SpawnAfterRelFlags] ( @sc02_card.code_04ACCA, #$0000, #$FFF0, #$1001 )
    COP [PlaySoundCh2] ( #2C )
    COP [LoopNext]
    COP [StageSpriteLoopMoveX] ( #08, #04, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #07, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #09, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_04AFE7 )
    COP [SetOnInteract] ( &code_04AEC4 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [ExitIfFlagByte] ( #08, #01 )
    COP [SetOnInteract] ( #$0000 )
    COP [PrintDialogString] ( &dialogstring_04B014 )
    COP [CallScript] ( &code_04AE6B )
    COP [ExitIfFlagByte] ( #0A, #01 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_04B02E )
    COP [StageSpriteLoop] ( #05, #1E )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_04B066 )
    COP [SetFlagByte] ( #0B )
    COP [ClearFlagByte] ( #04 )
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_04AE53 {
    LDA #$0800
    TSB $10
    LDA #$0200
    TSB $12
}

code_04AE5D {
    COP [SetOnInteract] ( &code_04AEA1 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #32 )
    COP [AnimOnce]
    RTL 
}

code_04AE69 {
    COP [Die]
}

code_04AE6B {
    COP [StageSpriteLoopMoveY] ( #05, #04, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #05, #04, #03 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #05, #10 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #05, #04, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #05, #04, #03 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_04AE8F {
    COP [SetFlagByte] ( #01 )
    COP [PrintDialogString] ( &dialogstring_04AECC )
    RTL 
}

code_04AE97 {
    COP [PrintDialogString] ( &dialogstring_04AF1E )
    RTL 
}

code_04AE9C {
    COP [PrintDialogString] ( &dialogstring_04AF52 )
    RTL 
}

code_04AEA1 {
    COP [BranchIfFlagByte] ( #25, #01, &code_04AEB7 )
    COP [BranchIfFlagByte] ( #1C, #01, &code_04AEB2 )
    COP [PrintDialogString] ( &dialogstring_04B096 )
    RTL 
}

code_04AEB2 {
    COP [PrintDialogString] ( &dialogstring_04B0C5 )
    RTL 
}

code_04AEB7 {
    COP [PrintDialogString] ( &dialogstring_04B0FC )
    RTL 
}

code_04AEBC {
    COP [PrintDialogString] ( &dialogstring_04AF80 )
    COP [SetFlagByte] ( #07 )
    RTL 
}

code_04AEC4 {
    COP [PrintDialogString] ( &dialogstring_04AFE7 )
    COP [SetFlagByte] ( #07 )
    RTL 
}

dialogstring_04AECC `[TPL:A][TPL:4]ロブ:[N]なんだよ テム.[N]おそかったじゃんかっ.[FIN]今 モリスと ブラックジャックの[N]勝負をしてるんだ.[N]ちょっと 待ってくれ.[PAL:0][END]`

dialogstring_04AF1E `[TPL:A][TPL:4]ロブ:[N]テムも,そんなところに いないで[N]エリックの となりの席に行けよ.[PAL:0][END]`

dialogstring_04AF52 `[TPL:A][TPL:4]ロブ:[N]たしか 笛を バトンみたいに[N]まわして ひきよせるんだよな.[PAL:0][END]`

dialogstring_04AF80 `[TPL:A][TPL:4]ロブ:[N]よし. 今度は トランプ当てを[N]やってもらおうぜ.[FIN]オレが 4枚のカードを 裹返しに[N]おくから ダイヤのエースだと[N]思うものを 拾いあげてくれ.[PAL:0][END]`

dialogstring_04AFE7 `[TPL:A][TPL:4]ロブ:[N]さあ. ダイヤのエースだと[N]思うものを 拾ってくれ.[PAL:0][END]`

dialogstring_04B014 `[TPL:A][TPL:4]ロブ:[N]おおっ. あたったあっ!![PAL:0][END]`

dialogstring_04B02E `[TPL:A][TPL:4]ロブ: 学者モリスの言うことは[N]むずかしくて オレには よく[N]わかんねーや.[PAL:0][END]`

dialogstring_04B066 `[TPL:A][TPL:4]ロブ:[N]モリス. カード出したついでに[N]もう ひと勝負しようぜ.[PAL:0][END]`

dialogstring_04B096 `[TPL:A][TPL:4]ロブ:[N]おれは モリスと もうひと勝負[N]したら 帰ることにするよ.[PAL:0][END]`

dialogstring_04B0C5 `[TPL:A][TPL:4]ロブ:[N]今日は 教会の勉強も 休みだし··[N]何か 面白いことねえかなあ.[PAL:0][END]`

dialogstring_04B0FC `[TPL:A][TPL:4]ロブ:[N]どうしたんだ? テム.[N]うかない顔して.[FIN]何か おれたちに言えない[N]なやみでも あるのか?[PAL:0][END]`