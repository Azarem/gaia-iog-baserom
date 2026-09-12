---------------------------------------------

fr35_slave3 [
  actor-def < #27, #00, #10, {

  code_05C3FB:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05C409 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05C409 {
    COP [PrintDialogString] ( &dialogstring_05C40E )
    RTL 
}

dialogstring_05C40E `[TPL:A]I don't believe in the [N]spirits.[FIN]If there were spirits,[N]things like status [N]wouldn't matter....[END]`