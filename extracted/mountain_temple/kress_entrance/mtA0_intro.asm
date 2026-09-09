!joypadMaskStd                  065A

---------------------------------------------

mtA0_intro [
  actor-def < #00, #00, #30, {

  code_07E760:
    COP [BranchIfFlagByte] ( #A7, #01, &code_07E77C )
    COP [SetFlagByte] ( #A7 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_07E77E )
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_07E77C {
    COP [Die]
}

widestring_07E77E `[TPL:F][TPL:0]There's a strange place [N]at the summit [N]of Mt.Kress. [FIN]There are mushrooms [N]many times bigger than  [N]me, and plant stalks [N]are scattered around.[PAL:0][END]`