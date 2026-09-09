---------------------------------------------

daC3_kruk1 [
  actor-def < #1A, #00, #10, {

  code_08ABFA:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_08AC0C )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
} >
]

code_08AC0C {
    COP [PrintWideString] ( &widestring_08AC11 )
    RTL 
}

widestring_08AC11 `[DEF]Kiaaa...Kiaaa...[END]`