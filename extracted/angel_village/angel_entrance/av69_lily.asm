; Lilly at the Angel Village entrance — urges the party forward.
; 
; NPC. Lilly: "Will, let's go." Brief encouragement to
; explore the village.
---------------------------------------------

!moveXAlt                       7F0018
!moveYAlt                       7F001A

---------------------------------------------

av69_lily [
  actor-def < #23, #00, #10, {

  code_06C1B5:
    COP [BranchIfFlagByte] ( #8D, #01, &av69_lily_destroy )
    COP [BranchIfFlagByte] ( #75, #01, &av69_lily_destroy )
    COP [ExitIfFlagByte] ( #01, #01 )
    COP [StageSpriteMoveY] ( #27, #12 )
    COP [AnimOnce]
    COP [StageSpriteMoveX] ( #28, #12 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #22 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_06C224 )
    COP [SetFlagByte] ( #02 )
    COP [ExitIfFlagByte] ( #03, #01 )
    COP [StageSpriteFrame] ( #24 )
    COP [AnimOnce]
    COP [PrintDialogString] ( &dialogstring_06C23C )
    COP [SetFlagByte] ( #04 )
    COP [LoopInit] ( #02 )
    COP [StageSpriteLoop] ( #24, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #23, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #25, #04 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #22, #04 )
    COP [AnimLoop]
    COP [LoopNext]
    COP [StageSpriteLoop] ( #33, #04 )
    COP [AnimLoop]
    LDA #$02A8
    STA $moveXAlt, X
    LDA #$0060
    STA $moveYAlt, X
    COP [MoveToward] ( #33, #01 )
} >
]

av69_lily_destroy {
    COP [Die]
}

dialogstring_06C224 `[TPL:A][TPL:2]Lilly: [N]Will, let's go. [END]`

dialogstring_06C23C `[TPL:A][TPL:2]Lilly: Why are[N]you so grouchy...[FIN][TPL:4]Lance: [N]Maybe she's just tired. [N]Let her be for now.[PAL:0][END]`