!joypadMaskStd                  065A

---------------------------------------------

gw82_trail_intro [
  actor-def < #00, #00, #30, {

  code_07B532:
    COP [BranchIfFlagByte] ( #9D, #01, &code_07B54E )
    COP [SetFlagByte] ( #9D )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_07B550 )
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_07B54E {
    COP [Die]
}

widestring_07B550 `[TPL:9][TPL:0]I followed Lance's trail [N]to the Great Wall. [FIN]A corridor stretched[N]to the distant horizon.[END]`