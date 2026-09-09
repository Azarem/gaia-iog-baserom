---------------------------------------------

fr32_honest_life [
  actor-def < #35, #00, #10, {

  code_05BE11:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05BE1F )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05BE1F {
    COP [PrintWideString] ( &widestring_05BE24 )
    RTL 
}

widestring_05BE24 `[DEF]A life lived[N]honestly. A life[N]of fun and laughter.[END]`