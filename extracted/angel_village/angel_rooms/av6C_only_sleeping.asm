---------------------------------------------

av6C_only_sleeping [
  actor-def < #0A, #00, #10, {

  code_06D050:
    COP [SolidHighHere]
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_06D05E )
    COP [SetEntryContinue]
    RTL 
} >
]

code_06D05E {
    COP [PrintDialogString] ( &dialogstring_06D063 )
    RTL 
}

dialogstring_06D063 `[TPL:A][TPL:0]Will: She appears to be [N]sleeping. It's like the [N]spirit's drawn out...[PAL:0][END]`