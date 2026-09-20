; Moon Tribe spirit at Nazca — ominous appearance.
; 
; NPC: "Ku ku ku..." The Moon Tribe's characteristic laugh.
; Brief mysterious appearance hinting at the alien connection
; to the Nazca lines and Sky Garden.
---------------------------------------------

!joypadMaskStd                  065A

---------------------------------------------

na4B_spirit [
  actor-def < #32, #00, #30, {

  code_05F2F2:
    COP [WaitOnFlagByte] ( #06, #01 )
    COP [WaitOnFlagByte] ( #07, #01 )
    LDA #$2000
    TRB $10
    LDA #$0200
    TSB $12
    COP [LoopStart] ( #03 )

  loc_05F307:
    COP [StageSpriteFrame] ( #32 )
    COP [AnimOnce]
    COP [BranchIfPlayerNear] ( #02, &code_05F313 )
    BRA loc_05F307
} >
]

code_05F313 {
    COP [NudgePosition] ( #70, #00 )
    COP [LoopEnd]
    LDA #$FFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #13 )
    COP [PrintDialogString] ( &dialogstring_05F349 )
    LDA #$FFF0
    TRB $joypadMaskStd
    COP [SetFlagByte] ( #02 )
    COP [StageSpriteLoopMoveXY] ( #32, #02, #11, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #32, #02, #01, #02 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #32, #0D, #03, #04 )
    COP [AnimLoop]
    COP [Die]
}

dialogstring_05F349 `[DEF]Ku ku ku...[END]`