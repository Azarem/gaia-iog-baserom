---------------------------------------------

h_ec0B_door [
  actor-def < #00, #00, #10, {

  code_04D4B1:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_04D4C0 )
    COP [ExitIfFlagByte] ( #24, #01 )
    COP [Die]
} >
]

code_04D4C0 {
    COP [PrintWideString] ( &widestring_04D4C9 )
    COP [SetFlagByte] ( #02 )
    COP [Die]
}

widestring_04D4C9 `[DLG:3,12][SIZ:D,3,0][TPL:0]テム:[N]カギが かかっている···[PAL:0][END]`