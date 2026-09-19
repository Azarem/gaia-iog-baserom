; Itory Village NPC who tells an ancient legend.
; 
; Dialog about a messenger appearing when the ancient world
; was about to be destroyed.
---------------------------------------------

---------------------------------------------

it15_fable_man [
  actor-def < #03, #00, #10, {

  code_04DEB6:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_04DEC4 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_04DEC4 {
    COP [PrintDialogString] ( &dialogstring_04DEC9 )
    RTL 
}

dialogstring_04DEC9 `[DEF]It's said that a messenger[N]appeared here when the[N]ancient world was about[N]to be destroyed.[END]`