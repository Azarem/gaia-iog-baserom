; Left competitor in the Watermia gambling house.
; 
; NPC who cheers: "You can still do it!!" During the Russian
; Glass gambling mini-game. Reacts to the game's progress.
---------------------------------------------

?INCLUDE 'wa7B_competitor_right'

---------------------------------------------

wa7B_competitor_left [
  actor-def < #05, #00, #10, {

  code_07A0F3:
    LDA #$0200
    TSB $12
    COP [SpawnAfterRelFlags] ( @wa7B_competitor_right.code_07A192, #$0010, #$0000, #$1000 )
    COP [SpawnAfterRelFlags] ( @wa7B_competitor_right.code_07A192, #$000C, #$FFF6, #$1000 )
    COP [SpawnAfterRelFlags] ( @wa7B_competitor_right.code_07A192, #$0018, #$0008, #$1000 )
    COP [SpawnAfterRelFlags] ( @wa7B_competitor_right.code_07A192, #$0020, #$0002, #$1000 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_07A12D )
    COP [SetEntryContinue]
    RTL 
} >
]

code_07A12D {
    COP [PrintDialogString] ( &dialogstring_07A132 )
    RTL 
}

dialogstring_07A132 `[TPL:A]You can still do it!![END]`