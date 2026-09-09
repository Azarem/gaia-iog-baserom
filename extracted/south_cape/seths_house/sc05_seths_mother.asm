---------------------------------------------

sc05_seths_mother [
  actor-def < #14, #00, #10, {

  code_049102:
    COP [SetOnInteract] ( &code_04910B )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    RTL 
} >
]

code_04910B {
    COP [PrintWideString] ( &widestring_049110 )
    RTL 
}

widestring_049110 `[TPL:B]Seth's mother:[N]It's no joke![N]That man![FIN]I put up with it for[N]Seth's sake, but if it[N]weren't for him, I'd have[N]left long ago![END]`