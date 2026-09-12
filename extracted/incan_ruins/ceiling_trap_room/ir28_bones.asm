---------------------------------------------

ir28_bones [
  actor-def < #2E, #01, #10, {

  code_09C8A0:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_09C8AE )
    COP [SetEntryContinue]
    RTL 
} >
]

code_09C8AE {
    COP [PrintDialogString] ( &dialogstring_09C8B3 )
    RTL 
}

dialogstring_09C8B3 `[DEF][TPL:0]An explorer who sought [N]the Incan Gold Ship...? [FIN]He lost his life in [N]a trap... [END]`