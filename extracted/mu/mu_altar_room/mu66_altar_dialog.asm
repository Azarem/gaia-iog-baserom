; Altar room dialog — describes the ancient burial ground of Mu.
; 
; Text object: "This looks like an ancient burial ground for
; the people of Mu." Provides context about the altar room's
; significance as a sacred space for the ancient Mu civilization.
---------------------------------------------

!joypadMaskStd                  065A
!cameraBoundsY                  06DC

---------------------------------------------

mu66_altar_dialog [
  actor-def < #00, #00, #30, {

  code_069C88:
    COP [BranchIfPlayerInAbsTiles] ( #20, #00, #30, #10, &code_069CAF )
    COP [BranchOnFlagByte] ( #82, #01, &code_069CAC )
    COP [SetFlagByte] ( #82 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_069CB7 )
    LDA #$CFF0
    TRB $joypadMaskStd
} >
]

code_069CAC {
    COP [SetEntryHere]
    RTL 
}

code_069CAF {
    LDA #$0100
    STA $cameraBoundsY
    COP [Die]
}

dialogstring_069CB7 `[TPL:B][TPL:0]This looks like an [N]ancient burial ground [N]for the people of Mu. [N][PAL:0][END]`