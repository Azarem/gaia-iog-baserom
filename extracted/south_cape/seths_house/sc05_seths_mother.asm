; Seth's mother NPC -- the other side of the arguing parents.
; 
; Dialog about putting up with Seth's father for Seth's sake.
; Part of the family conflict theme.
---------------------------------------------

---------------------------------------------

sc05_seths_mother [
  actor-def < #14, #00, #10, {

  code_049102:
    COP [SetInteractHandler] ( &code_04910B )
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
} >
]

code_04910B {
    COP [PrintDialogString] ( &dialogstring_049110 )
    RTL 
}

dialogstring_049110 `[TPL:B]Seth's mother:[N]It's no joke![N]That man![FIN]I put up with it for[N]Seth's sake, but if it[N]weren't for him, I'd have[N]left long ago![END]`