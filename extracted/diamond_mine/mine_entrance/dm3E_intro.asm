; Will's inner monologue on first entering the Diamond Mine and the Sky Garden.
; 
; Locks the joypad ($CFFC) and branches on sceneCurrent. Scene $3E (mine entrance) plays the "Diamond Mine was as quiet as a tomb" narration under flag $6A; scene $4C (Sky Garden) plays the "strange garden floating in the sky over Nazca" narration under flag $6B. With the flag clear the actor sets it, waits #1D ticks and prints the dialog; with it set, or in any other scene, the actor unlocks the joypad and dies. Both flags are persistent and never cleared, so each narration plays once per game. The Freejia slave market actors also read $6A.
---------------------------------------------

!sceneCurrent                   0644
!joypadMaskStd                  065A

---------------------------------------------

dm3E_intro [
  actor-def < #00, #00, #30, {

  code_05F99F:
    LDA #$CFFC
    TSB $joypadMaskStd
    LDA $sceneCurrent
    CMP #$003E
    BEQ loc_05F9BA
    CMP #$004C
    BEQ loc_05F9CC

  code_05F9B2:
    LDA #$CFFC
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