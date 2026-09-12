---------------------------------------------

h_ec0A_shy_guard [
  actor-def < #1B, #00, #10, {

  code_04C3FD:
    COP [AddPosition] ( #10, #00 )
    COP [SolidHighHere]
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_04C40F )
    COP [SetEntryContinue]
    RTL 
} >
]

code_04C40F {
    COP [PrintDialogString] ( &dialogstring_04C414 )
    RTL 
}

dialogstring_04C414 `[TPL:B][TPL:7]ぼ ぼくは 君のことが···[PAL:0][END]`