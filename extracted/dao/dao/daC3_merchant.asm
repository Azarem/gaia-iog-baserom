; Carpet merchant in Dao — sells fine goods.
; 
; NPC: "I have fine goods for sale today. You've never seen
; carpets this nice." Standard merchant dialog for the
; desert trading town.
---------------------------------------------

---------------------------------------------

daC3_merchant [
  actor-def < #05, #00, #10, {

  code_08A89E:
    COP [SetInteractHandler] ( &code_08A8B2 )
    COP [MarkSolidHere]
    COP [WaitByte] ( #EF )
    COP [ClearSolidHere]
    COP [StageSpriteLoopMoveX] ( #08, #40, #12 )
    COP [AnimLoop]
    COP [Die]
} >
]

code_08A8B2 {
    COP [PrintDialogString] ( &dialogstring_08A8B7 )
    RTL 
}

dialogstring_08A8B7 `[DEF]Merchant:[N]I have fine goods for[N]sale today. You've never[N]seen carpets this nice.[END]`