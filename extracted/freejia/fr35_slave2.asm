---------------------------------------------

fr35_slave2 [
  actor-def < #27, #00, #10, {

  code_05C3A8:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05C3B6 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05C3B6 {
    COP [PrintWideString] ( &widestring_05C3BB )
    RTL 
}

widestring_05C3BB `[TPL:B]I've tried not to think. [N]The more I think, the [N]more empty I become...[END]`