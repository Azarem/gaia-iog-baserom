; NPC in Itory couple's house warning about the Incan ruins.
; 
; Dialog about gold hunters who entered the ruins and never returned.
---------------------------------------------

---------------------------------------------

it18_warning_man [
  actor-def < #02, #00, #10, {

  code_04DDB9:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_04DDC2 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_04DDC2 {
    COP [PrintDialogString] ( &dialogstring_04DDC7 )
    RTL 
}

dialogstring_04DDC7 `[TPL:A]Many people have[N]come here to gather[N]Incan gold.[FIN]But many who set foot[N]in the Incan ruins have[N]never returned...[END]`