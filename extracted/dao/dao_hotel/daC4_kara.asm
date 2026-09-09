!joypadMaskStd                  065A

---------------------------------------------

daC4_kara [
  actor-def < #1A, #00, #10, {

  code_08A4AE:
    COP [BranchIfFlagByte] ( #D2, #01, &code_08A4CF )
    COP [BranchIfFlagByte] ( #D0, #01, &code_08A4C0 )
    COP [BranchIfFlagByte] ( #BB, #01, &code_08A4CF )
} >
]

code_08A4C0 {
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08A4D1 )
    COP [BranchIfFlagByte] ( #B6, #00, &code_08A4D6 )
    COP [SetEntryContinue]
    RTL 
}

code_08A4CF {
    COP [Die]
}

code_08A4D1 {
    COP [PrintWideString] ( &widestring_08A51E )
    RTL 
}

code_08A4D6 {
    COP [SetFlagByte] ( #B6 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintWideString] ( &widestring_08A4EF )
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [SetEntryContinue]
    RTL 
}

widestring_08A4EF `[TPL:A][TPL:0]A town shining in the [N]desert. We went to Dao.[PAL:0][END]`

widestring_08A51E `[TPL:B][TPL:1]Kara: This place is [N]supposed to be famous [N]for labor merchants. [N]It doesn't look like it.[PAL:0][END]`