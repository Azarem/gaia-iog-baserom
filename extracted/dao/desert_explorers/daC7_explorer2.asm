; Desert explorer 2 — shares the Pyramid legend.
; 
; NPC: "There's a strange legend around here. 'The Pyramid
; is not for the living. Only those who've...'" Hints at the
; Pyramid's supernatural nature and entry requirements.
---------------------------------------------

---------------------------------------------

daC7_explorer2 [
  actor-def < #02, #00, #10, {

  code_08A9E0:
    COP [SetInteractHandler] ( &code_08A9E9 )
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
} >
]

code_08A9E9 {
    COP [PrintDialogString] ( &dialogstring_08A9EE )
    RTL 
}

dialogstring_08A9EE `[DEF]There's a strange legend[N]around here.[FIN]"The Pyramid is not for[N] the living. Only those[N] who've transcended the[N] body may enter.ˮ[FIN]These are the words...[N]The Pyramid is a big[N]tomb. The living can't[N]go in? Hmmm...[END]`