---------------------------------------------

fr3A_harborer [
  actor-def < #02, #00, #10, {

  code_05BC59:
    COP [BranchIfFlagByte] ( #5A, #01, &code_05BC68 )
    COP [SetOnInteract] ( &code_05BC6A )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_05BC68 {
    COP [Die]
}

code_05BC6A {
    COP [PrintDialogString] ( &dialogstring_05BC6F )
    RTL 
}

dialogstring_05BC6F `[TPL:A]There was nothing he[N]could do about being[N]found.[FIN]He's the laborer[N]who ran away yesterday.[FIN]I should tell the labor[N]traders.[FIN]I was prepared[N]for the worst[N]when I did it.[END]`