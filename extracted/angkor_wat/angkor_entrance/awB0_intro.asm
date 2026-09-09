!joypadMaskStd                  065A

---------------------------------------------

awB0_intro [
  actor-def < #00, #00, #30, {

  code_0897E3:
    COP [BranchIfFlagByte] ( #BE, #01, &code_089805 )
    COP [BranchIfFlagByte] ( #B3, #01, &code_089805 )
    COP [SetFlagByte] ( #B3 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_089807 )
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_089805 {
    COP [Die]
}

widestring_089807 `[TPL:B][TPL:0]Through the jungle, [N]three days journey [N]from the native village, [N]there is a huge temple.[PAL:0][END]`