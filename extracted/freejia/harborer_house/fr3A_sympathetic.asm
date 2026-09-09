---------------------------------------------

fr3A_sympathetic [
  actor-def < #27, #00, #10, {

  code_05C311:
    COP [BranchIfFlagByte] ( #5A, #01, &code_05C325 )
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05C327 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05C325 {
    COP [Die]
}

code_05C327 {
    COP [PrintWideString] ( &widestring_05C32F )
    COP [SetFlagByte] ( #59 )
    RTL 
}

widestring_05C32F `[TPL:A]Please! [N]Don't tell! [FIN]I don't care about myself,[N]I just don't want to get [N]him in trouble...[END]`