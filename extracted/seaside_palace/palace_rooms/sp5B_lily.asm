!joypadMaskStd                  065A

---------------------------------------------

sp5B_lily [
  actor-def < #24, #00, #10, {

  code_068688:
    COP [BranchIfFlagByte] ( #6F, #01, &code_068707 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #02, &code_068696 )
    RTL 
} >
]

code_068696 {
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #0F )
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [PrintDialogString] ( &dialogstring_068709 )
    COP [StageSpriteMoveX] ( #28, #03 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_068721 )
    COP [StageSpriteLoopMoveX] ( #28, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_068765 )
    COP [WaitByte] ( #3B )
    COP [StageSpriteLoop] ( #24, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #23, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #25, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #22, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #33, #08 )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_06882D )
    COP [StageSpriteLoopMoveX] ( #33, #03, #02 )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_06885B )
    COP [SetFlagByte] ( #6F )
    LDA #$0000
    STA $0688
    LDA #$CFF0
    TRB $joypadMaskStd
}

code_068707 {
    COP [Die]
}

dialogstring_068709 `[TPL:A][TPL:2]Lilly:[N]Waaah!![PAU:14][PAL:0][CLD]`

dialogstring_068721 `[TPL:A][TPL:2]Lilly: Hey... [N]You scared me!! [FIN]I practically had a [N]heart attack!! [END]`

dialogstring_068765 `[TPL:A][TPL:2]Lilly: I saw Erik in [N]the other room, but [N]something's strange. [FIN]His body is half[N]transparent. I can[N]see through it.[FIN]And he seems to be[N]unconscious, as if his[N]spirit is lost...[FIN]Let's stick together. [N]We don't know what [N]will happen.[PAL:0][END]`

dialogstring_06882D `[TPL:A][TPL:2]Lilly: [N]I'll borrow Will's [N]pocket for a while.[PAL:0][END]`

dialogstring_06885B `[PAU:1E][TPL:9][TPL:2]Lilly:[N]Well, let's go.[PAL:0][END]`