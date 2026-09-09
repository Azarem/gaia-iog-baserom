---------------------------------------------

fr3C_imas [
  actor-def < #28, #00, #10, {

  code_05BEE9:
    COP [BranchIfFlagByte] ( #6A, #01, &code_05BEFD )
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05BEFF )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05BEFD {
    COP [Die]
}

code_05BEFF {
    COP [PrintWideString] ( &widestring_05BF04 )
    RTL 
}

widestring_05BF04 `[DEF][TPL:5]I am Imas. I was[N]brought here by boat[N]from far-off Asia.[FIN]We are a hunting tribe.[N]When we're hungry[N]we hunt for food.[FIN]All of the animals here[N]have fallen victim[N]to an unknown disease...[PAL:0][END]`