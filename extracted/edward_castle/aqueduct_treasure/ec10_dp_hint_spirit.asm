?INCLUDE 'table_0EDA00'

---------------------------------------------

ec10_dp_hint_spirit [
  actor-def < #04, #00, #10, {

  code_04DD00:
    LDA #$0200
    TSB $12
    COP [SetOnInteract] ( &code_04DD1B )
    COP [SetMetasprite] ( @table_0EDA00 )
    COP [StageSprAndHitbox] ( #04 )
    COP [SolidHighHere]
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    RTL 
} >
]

code_04DD1B {
    COP [PrintWideString] ( &widestring_04DD20 )
    RTL 
}

widestring_04DD20 `[DEF]When you defeat the[N]enemies, a shiny silver[N]Dark Gem will appear.[FIN]If you collect 100 of[N]these, you gain[N]one life...[FIN]Even if you're defeated,[N]you won't have to go[N]back very far...[END]`