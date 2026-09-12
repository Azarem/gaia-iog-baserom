---------------------------------------------

fr37_caution [
  actor-def < #0A, #00, #10, {

  code_05BD02:
    COP [SetOnInteract] ( &code_05BD0B )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_05BD0B {
    COP [PrintDialogString] ( &dialogstring_05BD10 )
    RTL 
}

dialogstring_05BD10 `[TPL:A]Listen to me carefully. [N]You'd better not go [N]on the back streets. [FIN]Just as a rose has[N]thorns, a pretty town[N]has another side.[END]`