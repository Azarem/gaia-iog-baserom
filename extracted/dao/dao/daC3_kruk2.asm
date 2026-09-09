---------------------------------------------

daC3_kruk2 [
  actor-def < #1A, #00, #10, {

  code_08AC26:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_08AC38 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
} >
]

code_08AC38 {
    COP [PrintWideString] ( &widestring_08AC3D )
    RTL 
}

widestring_08AC3D `[DEF]Kiaaa...Kiaaa...[END]`