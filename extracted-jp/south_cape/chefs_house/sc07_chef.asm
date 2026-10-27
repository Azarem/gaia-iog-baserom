---------------------------------------------

h_sc07_chef [
  actor-def < #05, #00, #10, {

  code_04907D:
    COP [SetInteractHandler] ( &code_049086 )
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
} >
]

code_049086 {
    COP [PrintDialogString] ( &dialogstring_04908B )
    RTL 
}

dialogstring_04908B `[TPL:A]うーん いいにおいだ.[N]家には カマドがないから こうして[N]ツボで 料理をするのさ.[END]`