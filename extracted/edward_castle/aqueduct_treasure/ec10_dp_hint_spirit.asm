; Dark Space hint spirit in the aqueduct treasure room.
; 
; Tutorial dialog explaining dark gems and the extra life mechanic
; (collect 100 gems for one life).
---------------------------------------------

?INCLUDE 'spriteset_npc_props'

---------------------------------------------

ec10_dp_hint_spirit [
  actor-def < #04, #00, #10, {

  code_04DD00:
    LDA #$0200
    TSB $12
    COP [SetInteractHandler] ( &code_04DD1B )
    COP [SetMetasprite] ( @spriteset_npc_props )
    COP [StageSprAndHitbox] ( #04 )
    COP [MarkSolidHere]
    COP [SetEntryHere]
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    RTL 
} >
]

code_04DD1B {
    COP [PrintDialogString] ( &dialogstring_04DD20 )
    RTL 
}

dialogstring_04DD20 `[DEF]When you defeat the[N]enemies, a shiny silver[N]Dark Gem will appear.[FIN]If you collect 100 of[N]these, you gain[N]one life...[FIN]Even if you're defeated,[N]you won't have to go[N]back very far...[END]`