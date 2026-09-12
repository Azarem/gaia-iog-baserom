---------------------------------------------

daC3_freedom_man [
  actor-def < #05, #00, #10, {

  code_08AB26:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08AB2F )
    COP [SetEntryContinue]
    RTL 
} >
]

code_08AB2F {
    COP [PrintDialogString] ( &dialogstring_08AB34 )
    RTL 
}

dialogstring_08AB34 `[DEF]A freedom movement [N]has started recently. [FIN]The president of Rolek [N]started the labor trade [N]freedom movement. [END]`