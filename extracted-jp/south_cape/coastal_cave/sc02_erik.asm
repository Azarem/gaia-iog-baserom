!joypadMaskStd                  065A

---------------------------------------------

h_sc02_erik [
  actor-def < #0A, #00, #10, {

  code_04B543:
    COP [BranchIfFlagByte] ( #4C, #01, &code_04B5FE )
    COP [SetOnInteract] ( &code_04B624 )
    COP [BranchIfFlagByte] ( #20, #01, &code_04B5EE )
    COP [BranchIfFlagByte] ( #16, #01, &code_04B5F1 )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [SetFlagByte] ( #16 )
    COP [SetFlagByte] ( #04 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #59 )
    COP [PrintWideString] ( &widestring_04B63E )
    COP [StageSpriteLoopMoveY] ( #0F, #03, #02 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0B )
    COP [AnimOnce]
    COP [WaitByte] ( #3B )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [PrintWideString] ( &widestring_04B667 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [SetFlagByte] ( #03 )
    COP [WaitByte] ( #B3 )
    COP [ClearFlagByte] ( #03 )
    COP [PrintWideString] ( &widestring_04B6CB )
    COP [StartMusic] ( #1C )
    COP [WaitByte] ( #77 )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [StageSpriteLoopMoveX] ( #11, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #0F, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #10, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #0A )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [ExitIfFlagByte] ( #05, #01 )
    COP [SetOnInteract] ( &code_04B629 )
    COP [ExitIfFlagByte] ( #06, #01 )
    COP [CallScript] ( &code_04B600 )
    COP [SetOnInteract] ( &code_04B62E )
    COP [ExitIfFlagByte] ( #08, #01 )
    COP [CallScript] ( &code_04B600 )
    COP [PrintWideString] ( &widestring_04B84E )
    COP [SetFlagByte] ( #09 )
} >
]

code_04B5EE {
    COP [SetEntryContinue]
    RTL 
}

code_04B5F1 {
    COP [SetTilePos] ( #08, #09 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_04B62E )
    JMP $&code_04B5EE
}

code_04B5FE {
    COP [Die]
}

code_04B600 {
    COP [StageSpriteLoopMoveY] ( #0A, #04, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #0A, #04, #03 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0A, #10 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #0A, #04, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #0A, #04, #03 )
    COP [AnimLoop]
    COP [RestoreSavedPtr]
}

code_04B624 {
    COP [PrintWideString] ( &widestring_04B7A4 )
    RTL 
}

code_04B629 {
    COP [PrintWideString] ( &widestring_04B7CD )
    RTL 
}

code_04B62E {
    COP [BranchIfFlagByte] ( #21, #01, &code_04B639 )
    COP [PrintWideString] ( &widestring_04B7FC )
    RTL 
}

code_04B639 {
    COP [PrintWideString] ( &widestring_04B826 )
    RTL 
}

widestring_04B63E `[DLG:3,6][SIZ:D,3,0]とつぜん 血相をかえた[N]エリックが とびこんできた![PAU:28][CLD]`

widestring_04B667 `[TPL:A][TPL:3]エリック: はぁ はぁ···[N]ニュースっ! 大ニュースだあっ![FIN]エドワード城の 王女が[N]行方不明に なったんだってっ![N]なんでも この町へきたらしいよ![PAL:0][END]`

widestring_04B6CB `[TPL:B][TPL:4]ロブ: なんだよ.[N]そんなに あわてて 飛びこんで[N]くるから もっと すごいことが[N]起こったのかと 思ったぜ.[FIN]それに 王女って あの[N]わがまま娘の カレンだろ.[N]あんなヤツの どこがいいんだっ?[FIN][TPL:3]エリック:[N]そりゃそうだけど[N]王女をさがすために この町へ[N]兵士たちが やってくるよ.[FIN]エドワード城の 兵士って[N]かっこいいじゃない?[N]ぼくは それが 見たいだけだい.[PAL:0][END]`

widestring_04B7A4 `[TPL:A][TPL:3]エリック:[N]ちぇっ. みんなびっくりするかと[N]思ったのに···[PAL:0][END]`

widestring_04B7CD `[TPL:A][TPL:3]エリック:[N]こないだは はなれたところから[N]石像を 動かしたんだよね.[PAL:0][END]`

widestring_04B7FC `[TPL:A][TPL:3]エリック:[N]いいなあ. ぼくも そんな力が[N]使えたらなあ···[PAL:0][END]`

widestring_04B826 `[TPL:A][TPL:3]エリック:[N]どうしたの?[N]何か いつものテムとちがうよ.[PAL:0][END]`

widestring_04B84E `[TPL:A][TPL:3]エリック:[N]ふぅ. 言葉も出ないよ···[FIN]ねぇ. モリス.[N]こういうのを チョウノウリョクって[N]言うんでしょ?[PAL:0][END]`