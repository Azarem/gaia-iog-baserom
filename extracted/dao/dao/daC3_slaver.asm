---------------------------------------------

daC3_slaver [
  actor-def < #1D, #00, #10, {

  code_08B2F0:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08B302 )
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
} >
]

code_08B302 {
    COP [PrintWideString] ( &widestring_08B307 )
    RTL 
}

widestring_08B307 `[DEF]Hey, hey.[N]This isn't a show!![N]Get out of here![END]`