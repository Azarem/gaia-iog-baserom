; Will's inner monologue upon entering the Diamond Mine and Sky Garden.
; 
; Locks joypad, checks which scene is active: scene $3E (mine entrance)
; shows the "Diamond Mine was quiet as a tomb" narration with flag $6A;
; scene $4C (Sky Garden return) shows the "strange garden floating in
; the sky" narration with flag $6B. Each plays once per visit. Flags
; prevent repeat showings.
---------------------------------------------

!sceneCurrent                   0644
!joypadMaskStd                  065A

---------------------------------------------

dm3E_intro [
  actor-def < #00, #00, #30, {

  code_05F99F:
    LDA #$CFF0
    TSB $joypadMaskStd
    LDA $sceneCurrent
    CMP #$003E
    BEQ loc_05F9BA
    CMP #$004C
    BEQ loc_05F9CC

  code_05F9B2:
    LDA #$CFF0
    TRB $joypadMaskStd
    COP [Die]

  loc_05F9BA:
    COP [BranchOnFlagByte] ( #6A, #01, &code_05F9B2 )
    COP [SetFlagByte] ( #6A )
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_05F9DE )
    BRA code_05F9B2

  loc_05F9CC:
    COP [BranchOnFlagByte] ( #6B, #01, &code_05F9B2 )
    COP [SetFlagByte] ( #6B )
    COP [WaitByte] ( #1D )
    COP [PrintDialogString] ( &dialogstring_05FA59 )
    BRA code_05F9B2
} >
]

dialogstring_05F9DE `[TPL:B][TPL:0]Will: [N]The Diamond Mine was [N]as quiet as a tomb. [FIN]A chill ran down Will's [N]spine when he heard the [N]screams from the [N]back of the cave.[PAL:0][END]`

dialogstring_05FA59 `[TPL:F][TPL:0]Will: There's a strange[N]garden floating in the [N]sky over Nazca... [FIN]On the ground, Neil and [N]my friends look like [N]tiny ants going [N]back and forth. [FIN]Could the paintings[N]be an airport[N]for the Sky Garden?[PAL:0][END]`