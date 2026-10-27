---------------------------------------------

h_ec0A_shy_guard [
  actor-def < #1B, #00, #10, {

  code_04C3FD:
    COP [NudgePosition] ( #10, #00 )
    COP [MarkSolidHere]
    LDA #$0200
    TSB $12
    COP [SetInteractHandler] ( &code_04C40F )
    COP [SetEntryHere]
    RTL 
} >
]

code_04C40F {
    COP [PrintDialogString] ( &dialogstring_04C414 )
    RTL 
}

dialogstring_04C414 `[TPL:B][TPL:7]ぼ ぼくは 君のことが···[PAL:0][END]`