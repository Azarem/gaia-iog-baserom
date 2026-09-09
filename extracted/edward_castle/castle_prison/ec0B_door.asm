---------------------------------------------

ec0B_door [
  actor-def < #00, #00, #10, {

  code_04DB15:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_04DB24 )
    COP [ExitIfFlagByte] ( #24, #01 )
    COP [Die]
} >
]

code_04DB24 {
    COP [PrintWideString] ( &widestring_04DB2D )
    COP [SetFlagByte] ( #02 )
    COP [Die]
}

widestring_04DB2D `[DLG:3,12][SIZ:D,3][TPL:0]Will: [N]It's locked...[PAL:0][END]`