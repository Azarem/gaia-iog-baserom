---------------------------------------------

it15_fable_man [
  actor-def < #03, #00, #10, {

  code_04DEB6:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_04DEC4 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_04DEC4 {
    COP [PrintWideString] ( &widestring_04DEC9 )
    RTL 
}

widestring_04DEC9 `[DEF]It's said that a messenger[N]appeared here when the[N]ancient world was about[N]to be destroyed.[END]`