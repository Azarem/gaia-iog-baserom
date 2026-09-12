---------------------------------------------

gs2D_kara [
  actor-def < #1B, #00, #10, {

  code_058C06:
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_058C17 )
    COP [ExitIfFlagByte] ( #02, #01 )
    COP [SetOnInteract] ( &code_058C1C )
    COP [SetEntryContinue]
    RTL 
} >
]

code_058C17 {
    COP [PrintDialogString] ( &dialogstring_058C21 )
    RTL 
}

code_058C1C {
    COP [PrintDialogString] ( &dialogstring_058C8F )
    RTL 
}

dialogstring_058C21 `[TPL:A][TPL:1]Kara: They perished [N]waiting for the [N]King's return... [FIN]I can't stand anything[N]that disrupts people's[N]peaceful lives....[PAL:0][END]`

dialogstring_058C8F `[TPL:B][TPL:1]Kara: [N]What . . . ?[PAL:0][END]`