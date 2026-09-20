; Right competitor in the Watermia gambling house.
; 
; NPC who groans: "Uhnn..." Reacts to losing during the
; Russian Glass gambling mini-game.
---------------------------------------------

---------------------------------------------

wa7B_competitor_right [
  actor-def < #24, #00, #10, {

  code_07A149:
    LDA #$0200
    TSB $12
    COP [SpawnAfterOffsetFlags] ( @code_07A192, #$FFEE, #$FFF4, #$1000 )
    COP [SpawnAfterOffsetFlags] ( @code_07A192, #$FFF4, #$0008, #$1000 )
    COP [SpawnAfterOffsetFlags] ( @code_07A192, #$FFE8, #$0000, #$1000 )
    COP [SpawnAfterOffsetFlags] ( @code_07A192, #$FFE0, #$FFF6, #$1000 )
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_07A183 )
    COP [SetEntryHere]
    RTL 
} >
]

code_07A183 {
    COP [PrintDialogString] ( &dialogstring_07A188 )
    RTL 
}

dialogstring_07A188 `[TPL:A]Uhnn...[END]`

code_07A192 {
    COP [StageSpriteFrame] ( #23 )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
}