; Imas in the Freejia slave market — enslaved villager from Asia.
; 
; Says: "I am Imas. I was brought here by boat from far-off Asia.
; We are a hunting people..." Provides backstory about the
; international scope of the labor trade. One of three named
; slaves (with Remus and Sam) from the Diamond Mine.
---------------------------------------------

---------------------------------------------

fr3C_imas [
  actor-def < #28, #00, #10, {

  code_05BEE9:
    COP [BranchOnFlagByte] ( #6A, #01, &code_05BEFD )
    LDA #$0200
    TSB $12
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_05BEFF )
    COP [SetEntryHere]
    RTL 
} >
]

code_05BEFD {
    COP [Die]
}

code_05BEFF {
    COP [PrintDialogString] ( &dialogstring_05BF04 )
    RTL 
}

dialogstring_05BF04 `[DEF][TPL:5]I am Imas. I was[N]brought here by boat[N]from far-off Asia.[FIN]We are a hunting tribe.[N]When we're hungry[N]we hunt for food.[FIN]All of the animals here[N]have fallen victim[N]to an unknown disease...[PAL:0][END]`