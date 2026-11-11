; Kara at the Dao hotel (scene $C4). $D2 set: dies. $D0 set: stays. $BB set with $D0 clear: dies (she is with the party in the Pyramid). Otherwise she stands solid with 'This place is supposed to be famous for labor merchants. It doesn't look like it.'. When $B6 is clear (first visit) she sets $B6 at once, locks the player ($CFFC), prints 'A town shining in the desert. We went to Dao.' and unlocks.
---------------------------------------------

!joypadMaskStd                  065A

---------------------------------------------

daC4_kara [
  actor-def < #1A, #00, #10, {

  code_08A4AE:
    COP [BranchOnFlagByte] ( #D2, #01, &code_08A4CF )
    COP [BranchOnFlagByte] ( #D0, #01, &code_08A4C0 )
    COP [BranchOnFlagByte] ( #BB, #01, &code_08A4CF )
} >
]

code_08A4C0 {
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_08A4D1 )
    COP [BranchOnFlagByte] ( #B6, #00, &code_08A4D6 )
    COP [SetEntryHere]
    RTL 
}

code_08A4CF {
    COP [Die]
}

code_08A4D1 {
    COP [PrintDialogString] ( &dialogstring_08A51E )
    RTL 
}

code_08A4D6 {
    COP [SetFlagByte] ( #B6 )
    LDA #$CFFC
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_08A4EF )
    LDA #$CFFC
    TRB $joypadMaskStd
    COP [SetEntryHere]
    RTL 
}

dialogstring_08A4EF `[TPL:A][TPL:0]A town shining in the [N]desert. We went to Dao.[PAL:0][END]`

dialogstring_08A51E `[TPL:B][TPL:1]Kara: This place is [N]supposed to be famous [N]for labor merchants. [N]It doesn't look like it.[PAL:0][END]`