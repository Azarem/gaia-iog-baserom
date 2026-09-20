; Will's monologue arriving at the Seaside Palace.
; 
; Narration: "The next thing he knew, Will was standing in a
; huge palace." Will: "I couldn't remember anything..." Also
; references Lilly and Mu. Sets the disorienting atmosphere
; of the vampire palace.
---------------------------------------------

!sceneCurrent                   0644
!joypadMaskStd                  065A

---------------------------------------------

sp5A_monologue [
  actor-def < #00, #00, #30, {

  code_068499:
    LDA #$CFF0
    TSB $joypadMaskStd
    LDA $sceneCurrent
    CMP #$005A
    BEQ loc_0684B9
    CMP #$005F
    BEQ loc_0684CB
    CMP #$0061
    BEQ loc_0684DD

  code_0684B1:
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [Die]

  loc_0684B9:
    COP [BranchIfFlagByte] ( #6E, #01, &code_0684B1 )
    COP [SetFlagByte] ( #6E )
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_0684F5 )
    BRA code_0684B1

  loc_0684CB:
    COP [BranchIfFlagByte] ( #77, #01, &code_0684B1 )
    COP [SetFlagByte] ( #77 )
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_06856E )
    BRA code_0684B1

  loc_0684DD:
    COP [BranchIfFlagByte] ( #7C, #01, &code_0684B1 )
    COP [BranchIfFlagByte] ( #7B, #00, &code_0684B1 )
    COP [SetFlagByte] ( #7C )
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_0685D3 )
    BRA code_0684B1
} >
]

dialogstring_0684F5 `[TPL:A][TPL:0]The next thing he knew, [N]Will was standing in a [N]huge palace. [FIN]Will: I couldn't [N]remember anything since[N]my water landing...[FIN]Is everyone safe?[PAL:0][END]`

dialogstring_06856E `[TPL:F][TPL:0]Will: Lilly and I set [N]foot on Mu. [FIN]They will probably [N]welcome us after waking [N]from a sleep of [N]thousands of years...[PAL:0][END]`

dialogstring_0685D3 `[TPL:E][TPL:2]Lilly: Ah! There's less[N]water than before![FIN]It looks like we can now[N]explore new areas.[END]`

dialogstring_06861B `[PAL:0][END]`