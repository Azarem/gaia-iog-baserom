; Erik in the Gorgon Hut — comments on the labor traders.
; 
; NPC: "The traders knew there was no food here, and led the
; children away. A terrible story." Erik's reaction to the
; Native Village's exploitation by slavers.
---------------------------------------------

---------------------------------------------

nvAE_erik [
  actor-def < #03, #00, #30, {

  code_089733:
    COP [BranchOnFlagByte] ( #B6, #01, &code_089771 )
    COP [BranchOnFlagByte] ( #CF, #01, &code_08975A )
    COP [WaitOnFlagByte] ( #BF, #01 )
    COP [WaitOnFlagByte] ( #C0, #01 )
    COP [WaitOnFlagByte] ( #C1, #01 )
    COP [WaitByte] ( #59 )
    LDA #$2000
    TRB $10
    COP [StageSpriteLoopMoveY] ( #07, #03, #02 )
    COP [AnimLoop]
} >
]

code_08975A {
    COP [SetTilePos] ( #08, #0A )
    LDA #$2000
    TRB $10
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [SetInteractHandler] ( &code_089773 )
    COP [SetEntryHere]
    RTL 
}

code_089771 {
    COP [Die]
}

code_089773 {
    COP [PrintDialogString] ( &dialogstring_089778 )
    RTL 
}

dialogstring_089778 `[DEF][TPL:3]Erik: The traders [N]knew there was no food [N]here, and led [N]the children away. [FIN]A terrible story.[PAL:0][END]`