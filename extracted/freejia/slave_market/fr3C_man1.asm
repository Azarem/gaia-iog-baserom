---------------------------------------------

fr3C_man1 [
  actor-def < #03, #00, #10, {

  code_05C231:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05C23A )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05C23A {
    COP [PrintDialogString] ( &dialogstring_05C23F )
    RTL 
}

dialogstring_05C23F `[TPL:B]When I think of myself[N]in your position,[N]I shudder.[FIN]I've no time to worry[N]about what people think,[N]it's hard enough just [N]taking care of myself.[END]`