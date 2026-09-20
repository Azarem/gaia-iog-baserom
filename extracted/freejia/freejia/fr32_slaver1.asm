; Slave trader 1 in Freejia — searching for escaped laborer.
; 
; Patrolling NPC who says: "Where'd he go..." Part of the
; labor escape subplot. Walks a route searching for the
; laborer who escaped.
---------------------------------------------

---------------------------------------------

fr32_slaver1 [
  actor-def < #1D, #00, #10, {

  code_05B819:
    COP [BranchIfFlagByte] ( #5A, #01, &code_05B839 )
    COP [SolidHighHere]
    COP [SetOnInteract] ( &code_05B83B )

  code_05B825:
    COP [StageSpriteFrame] ( #21 )
    COP [AnimOnce]
    COP [BranchIfFlagByte] ( #5A, #00, &code_05B825 )
    COP [ClearLowHere]
    COP [StageSpriteLoopMoveX] ( #20, #04, #02 )
    COP [AnimLoop]
} >
]

code_05B839 {
    COP [Die]
}

code_05B83B {
    COP [PrintDialogString] ( &dialogstring_05B840 )
    RTL 
}

dialogstring_05B840 `[DEF]Where'd he go...[END]`