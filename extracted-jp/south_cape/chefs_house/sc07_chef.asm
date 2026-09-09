---------------------------------------------

h_sc07_chef [
  actor-def < #05, #00, #10, {

  code_04907D:
    COP [SetOnInteract] ( &code_049086 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_049086 {
    COP [PrintWideString] ( &widestring_04908B )
    RTL 
}

widestring_04908B `[TPL:A]うーん いいにおいだ.[N]家には カマドがないから こうして[N]ツボで 料理をするのさ.[END]`