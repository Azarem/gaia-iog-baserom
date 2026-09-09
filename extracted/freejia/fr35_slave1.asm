---------------------------------------------

fr35_slave1 [
  actor-def < #27, #00, #10, {

  code_05C378:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05C386 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05C386 {
    COP [PrintWideString] ( &widestring_05C38B )
    RTL 
}

widestring_05C38B `[TPL:9]Soon we will be sent [N]away...[END]`