; Worried mother NPC in Freejia.
; 
; Says: "Mothers are always worrying about things. I was afraid
; you'd been kidnapped." Reflects the town's awareness of the
; labor trade threat to children.
---------------------------------------------

---------------------------------------------

fr36_mother [
  actor-def < #0C, #00, #10, {

  code_05BB4A:
    COP [SetInteractHandler] ( &code_05BB6A )

  loc_05BB4E:
    COP [StageSpriteLoopMoveX] ( #10, #07, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0A, #06 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #11, #07, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoop] ( #0A, #06 )
    COP [AnimLoop]
    BRA loc_05BB4E
} >
]

code_05BB6A {
    COP [PrintDialogString] ( &dialogstring_05BB6F )
    RTL 
}

dialogstring_05BB6F `[TPL:A]Mothers are always[N]worrying about things.[FIN]I was afraid you'd been[N]kidnapped by someone, or[N]had been wounded...[FIN]My mother suffered[N]like that.[END]`