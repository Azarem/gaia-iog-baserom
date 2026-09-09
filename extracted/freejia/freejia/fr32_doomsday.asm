---------------------------------------------

fr32_doomsday [
  actor-def < #35, #00, #10, {

  code_05BE58:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05BE66 )
    COP [SetEntryContinue]
    RTL 
} >
]

code_05BE66 {
    COP [PrintWideString] ( &widestring_05BE6B )
    RTL 
}

widestring_05BE6B `[DEF]Soon a great power will [N]come from above... Then [N]mankind will die out. [FIN]I don't know who made[N]the prediction, but it's[N]all a lie! I do this[N]to forget.[END]`