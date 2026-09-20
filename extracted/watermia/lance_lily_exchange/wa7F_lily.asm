; Lilly in the lance/lily exchange scene — encourages Lance.
; 
; NPC (~77 lines). "What? You're not yourself. Relax."
; Lance: "You're right..." Lilly supports Lance during his
; confession scene. Emotional character development.
---------------------------------------------

!joypadMaskStd                  065A
!playerActor                    09AA

---------------------------------------------

wa7F_lily [
  actor-def < #24, #00, #10, {

  code_07B1DB:
    COP [NudgePosition] ( #08, #00 )
    LDA #$CFF0
    TSB $joypadMaskStd
    LDY $playerActor
    LDA $0010, Y
    ORA #$2000
    STA $0010, Y
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_07B277 )
    COP [WaitByte] ( #1D )
    COP [SetFlagByte] ( #01 )
    COP [WaitByte] ( #27 )
    COP [PrintDialogString] ( &dialogstring_07B2E4 )
    COP [StageSpriteMoveX] ( #28, #14 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [WaitByte] ( #1D )
    COP [SetFlagByte] ( #02 )
    COP [SpawnAfterOffsetFlags] ( @code_07B1CD, #$FFF7, #$FFF5, #$1002 )
    COP [StageSpriteLoop] ( #39, #1E )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_07B329 )
    COP [SetFlagByte] ( #03 )
    COP [WaitOnFlagByte] ( #04, #01 )
    LDA #$0800
    TSB $10
    COP [StageSpriteLoop] ( #24, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #23, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #25, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #22, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #33, #06 )
    COP [AnimLoop]
    COP [StageSpriteMoveXY] ( #33, #13, #11 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #33, #11, #01 )
    COP [AnimOnce]
    COP [StageSpriteMoveXY] ( #33, #01, #03 )
    COP [AnimOnce]
    COP [SetFlagByte] ( #05 )
    COP [StageSpriteLoopMoveXY] ( #33, #08, #01, #03 )
    COP [AnimLoop]
    COP [Die]
} >
]

dialogstring_07B277 `[DEF][TPL:2]Lilly: What?[FIN]You're not yourself.[N]Relax.[FIN][TPL:4]Lance: [N]You're right. I'm [N]not myself right now. [FIN]This is your birthday[N]present. I hope you[N]like it.[PAL:0][END]`

dialogstring_07B2E4 `[DEF][TPL:2]Lilly: [N]Oh, Lance! A bouquet [N]of roses! [FIN]Rose buds. They'll[N]open up into roses.[END]`

dialogstring_07B329 `[DEF][TPL:2]Lilly:[N]They smell wonderful...[FIN]Thank you.[N]They're beautiful...[FIN][TPL:4]Lance: I have another [N]present. Something I [N]want to tell you... [FIN][TPL:2]Lilly:[N]What?[END]`
---------------------------------------------

code_07B1CD {
    COP [StageSpriteFrame] ( #BA )
    COP [AnimOnce]
    COP [WaitOnFlagByte] ( #04, #01 )
    COP [Die]
}