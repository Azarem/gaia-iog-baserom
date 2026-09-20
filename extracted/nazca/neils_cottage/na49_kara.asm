; Kara at Neil's cottage — conflicts with Neil.
; 
; Extended NPC (~60 lines). "I can't believe it! I don't want to
; breathe the same air as him!" Later: "Cygnus?! Neil: That's
; the Tower of Babel..." Kara's personality clashes with Neil's
; analytical nature. Also references the Tower of Babel.
---------------------------------------------

?BANK 05

!joypadMaskStd                  065A

---------------------------------------------

na49_kara [
  actor-def < #1B, #00, #10, {

  code_05E01B:
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_05E081 )
    COP [WaitOnFlagByte] ( #01, #01 )
    COP [StageSpriteLoopMoveY] ( #1F, #05, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [WaitOnFlagByte] ( #04, #01 )
    COP [StageSpriteLoop] ( #1D, #0A )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #1A, #14 )
    COP [AnimLoop]
    COP [PrintDialogString] ( &dialogstring_05E086 )
    COP [ClearFlagByte] ( #03 )
    COP [WaitOnFlagByte] ( #05, #01 )
    COP [SetSpritePriority] ( #30 )
    COP [StageSpriteLoopMoveX] ( #20, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [WaitOnFlagByte] ( #06, #01 )
    LDA #$EFF0
    TSB $joypadMaskStd
    COP [ClearSolidHere]
    COP [StageSpriteLoopMoveX] ( #21, #02, #01 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [PrintDialogString] ( &dialogstring_05E0C1 )
    COP [SetFlagByte] ( #07 )
    COP [SetEntryHere]
    RTL 
} >
]

code_05E081 {
    COP [PrintDialogString] ( &dialogstring_05E086 )
    RTL 
}

dialogstring_05E086 `[TPL:A][TPL:1]Kara: [N]I can't believe it! [FIN]I don't want to breathe[N]the same air as him![END]`

dialogstring_05E0C1 `[TPL:A][TPL:1]Kara: [N]Cygnus?! [FIN][TPL:6]Neil: That's the [N]Tower of Babel, where [N]Will's father got lost. [FIN]It's in the middle of[N]the ground painting of[N]the big white bird.[END]`