; Itory Village NPC continuing the ancient legend.
; 
; Dialog about disease and famine increasing across the world.
---------------------------------------------

---------------------------------------------

it15_fable_woman [
  actor-def < #0B, #00, #10, {

  code_04DF0F:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_04DF1D )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_04DF1D {
    COP [PrintDialogString] ( &dialogstring_04DF22 )
    RTL 
}

dialogstring_04DF22 `[DEF]Then, all around the[N]world, disease and[N]famine began to[N]increase...[FIN]This planet had always[N]been peaceful.[END]`