?INCLUDE 'sE6_gaia'

!joypadMaskStd                  065A
!playerActor                    09AA
!playerFlags                    09AE
!characterForm                  0AD4

---------------------------------------------

ec13_lily [
  actor-def < #22, #00, #10, {

  code_09BF93:
    COP [BranchIfFlagByte] ( #3A, #01, &code_09C037 )
    COP [WaitByte] ( #01 )
    COP [StartMusic] ( #1B )
    COP [WaitByte] ( #3B )
    COP [AddPosition] ( #08, #00 )
    LDA $characterForm
    BEQ loc_09BFD9
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_09C06C )
    LDA #$CFF0
    TRB $joypadMaskStd
    LDY $playerActor
    LDA #$*sE6_gaia.func_08F37D
    STA $0002, Y
    LDA #$&sE6_gaia.func_08F37D
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags

  loc_09BFD9:
    COP [SetEntryContinue]
    COP [BranchIfPlayerNear] ( #03, &code_09BFE1 )
    RTL 
} >
]

code_09BFE1 {
    COP [SetFlagByte] ( #3A )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [PrintDialogString] ( &dialogstring_09C0A8 )
    COP [PlaySoundBoth] ( #$1616 )
    COP [WaitByte] ( #EF )
    COP [PrintDialogString] ( &dialogstring_09C226 )
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

code_09C037 {
    LDA $characterForm
    BEQ loc_09C06A
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_09C06C )
    LDA #$CFF0
    TRB $joypadMaskStd
    LDY $playerActor
    LDA #$*sE6_gaia.func_08F37D
    STA $0002, Y
    LDA #$&sE6_gaia.func_08F37D
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    LDA #$0800
    TSB $playerFlags

  loc_09C06A:
    COP [Die]
}

dialogstring_09C06C `[TPL:B]When the enemies are [N]destroyed,[N]Will can return to[N]his original shape...[END]`

dialogstring_09C0A8 `[DEF][TPL:2]Girl: I saw you!![N]But I'm surprised![N]You can change[N]your shape like me![FIN]I'm Lilly. An Itory [N]girl protected by [N]the Flower Spirit. [FIN]How... How do you know[N]a melody you could only[N]have heard from us?[FIN][TPL:0]Will: I learned it [N]from Grandma Lola. [N]She hummed it whenever [N]she was upset. [FIN][TPL:2]Lilly: I have had [N]some of her pie. It [N]tastes rather unusual,[N]doesn't it? [FIN][TPL:0]Will: You know  [N]my grandmother?! [FIN][TPL:2]Lilly: Actually,[N]she asked me to[N]rescue you![PAL:0][END]`

dialogstring_09C226 `[DEF][TPL:2]Lilly:[N]The Elder is calling...[N]I have to go.[FIN]Lilly: [N]We'll meet again! [N]Goodbye, Will![PAL:0][END]`