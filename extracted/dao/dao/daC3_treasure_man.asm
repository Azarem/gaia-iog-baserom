; Pyramid treasure NPC — warns about the Pyramid.
; 
; Says: "There's a huge pyramid near here. Many explorers
; have come for the treasure, but no one's found it."
; Foreshadows the Pyramid dungeon chapter.
---------------------------------------------

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
    COP [PrintDialogString] ( &dialogstring_08B34E )
    RTL 
}

dialogstring_08B34E `[DEF]There's a huge pyramid[N]near here.[FIN]Many explorers have come[N]for the treasure, but[N]no one's found it yet.[END]`