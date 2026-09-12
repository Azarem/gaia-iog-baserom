---------------------------------------------

h_ec0B_ball [
  actor-def < #00, #00, #10, {

  code_04D565:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_04D571 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_04D571 {
    COP [PrintDialogString] ( &dialogstring_04D57A )
    COP [SetFlagByte] ( #04 )
    COP [Die]
}

dialogstring_04D57A `[TPL:E][TPL:0]テム: この鉄球には だれかが[N]つながれていたんだろうな···[PAL:0][END]`