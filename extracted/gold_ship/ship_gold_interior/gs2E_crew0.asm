---------------------------------------------

gs2E_crew0 [
  actor-def < #03, #00, #10, {

  code_05878F:
    COP [AddPosition] ( #00, #F8 )
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_05879F )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05879F {
    COP [PrintDialogString] ( &dialogstring_0587A4 )
    RTL 
}

dialogstring_0587A4 `[TPL:E]Through the darkness, a [N]bright light is visible [N]in front of the cave... [FIN]As the ship set sail,[N]that light represented the[N]freedom we had just won.[END]`