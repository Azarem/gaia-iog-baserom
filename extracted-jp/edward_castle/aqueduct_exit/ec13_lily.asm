!joypadMaskStd                  065A
!decelStepCounter               09B8
!slopeCurvePtrB                 09BC
!characterForm                  0AD4

---------------------------------------------

h_ec13_lily [
  actor-def < #22, #00, #10, {

  code_04FA04:
    COP [BranchIfFlagByte] ( #3A, #01, &code_04FAA8 )
    COP [WaitByte] ( #01 )
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [AddPosition] ( #08, #00 )
    LDA $characterForm
    BEQ loc_04FA4A
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_04FADD )
    LDA #$CFF0
    TRB $joypadMaskStd
    LDY $decelStepCounter
    LDA #$0088
    STA $0002, Y
    LDA #$EC6A
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $slopeCurvePtrB

  loc_04FA4A:
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #03, &code_04FA52 )
    RTL 
} >
]

code_04FA52 {
    COP [SetFlagByte] ( #3A )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [PrintDialogString] ( &dialogstring_04FB00 )
    COP [PlaySoundBoth] ( #$1616 )
    COP [WaitByte] ( #EF )
    COP [PrintDialogString] ( &dialogstring_04FC46 )
    COP [WaitByte] ( #3B )
    COP [StageSpriteLoop] ( #24, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #23, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #25, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #22, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #36, #08 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #36, #02, #14 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #36, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #36, #06, #02 )
    COP [AnimLoop]
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [Die]
}

code_04FAA8 {
    LDA $characterForm
    BEQ loc_04FADB
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_04FADD )
    LDA #$CFF0
    TRB $joypadMaskStd
    LDY $decelStepCounter
    LDA #$0088
    STA $0002, Y
    LDA #$EC6A
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $slopeCurvePtrB

  loc_04FADB:
    COP [Die]
}

dialogstring_04FADD `[TPL:A]敵の気配が消え[N]テムの変身が 解けてゆく···[END]`

dialogstring_04FB00 `[DEF][TPL:2]少女: 見ーちゃった![N]しかし おっどろいた![N]あたしみたいに 変身できる人が[N]いるんだね.[FIN]あたしは リリィ.[N]花の精に 守られてくらす[N]イトリー族の 女の子.[FIN]ところで あなた···[N]私たちにしか聞こえない[N]メロディーを どうしてしってるの?[FIN][TPL:0]テム:[N]ローラおばあちゃんから[N]教わったんだよ.[N]本当に困ったときに ふけって.[FIN][TPL:2]リリィ: ローラおばあちゃんには[N]とんでもない味のパイを[N]ごちそうになった.[FIN][TPL:0]テム:[N]おばあちゃんを 知ってるの!?[FIN][TPL:2]リリィ: ウフフ···[N]じつは ローラにたのまれて[N]あなたを たすけにきたんだもん![PAL:0][END]`

dialogstring_04FC46 `[DEF][TPL:2]リリィ:[N]あっ. 長老さまが呼んでる···[N]あたし 行かなくちゃ.[FIN]リリィ:[N]あとで きっとまた 会えるわ.[N]じゃあネ,テム![PAL:0][END]`