---------------------------------------------

fr3C_man2 [
  actor-def < #04, #00, #10, {

  code_05C2B0:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05C2B9 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05C2B9 {
    COP [PrintDialogString] ( &dialogstring_05C2BE )
    RTL 
}

dialogstring_05C2BE `[TPL:E]These laborers are the[N]same age as you.[FIN]Remember.There are[N]people everywhere[N]who live this way.[END]`