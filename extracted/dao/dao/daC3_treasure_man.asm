---------------------------------------------

daC3_treasure_man [
  actor-def < #1D, #00, #10, {

  code_08B337:
    LDA #$0200
    TSB $12
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_08B349 )
    COP [SetEntryContinue]
    COP [SetEntryContinue]
    COP [AnimOnce]
    RTL 
} >
]

code_08B349 {
    COP [PrintWideString] ( &widestring_08B34E )
    RTL 
}

widestring_08B34E `[DEF]There's a huge pyramid[N]near here.[FIN]Many explorers have come[N]for the treasure, but[N]no one's found it yet.[END]`