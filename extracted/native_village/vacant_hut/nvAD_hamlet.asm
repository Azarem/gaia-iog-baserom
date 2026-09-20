; Hamlet in the vacant hut — happy oinking.
; 
; NPC: "Oink oink." Hamlet is content in the hut.
; Light moment after the emotional village scenes.
---------------------------------------------

---------------------------------------------

nvAD_hamlet [
  actor-def < #13, #00, #10, {

  code_088C11:
    COP [BranchOnFlagByte] ( #B2, #01, &code_088C40 )
    COP [BranchOnFlagByte] ( #AE, #01, &code_088C32 )
    COP [BranchOnFlagByte] ( #AD, #00, &code_088C40 )
    COP [SetInteractHandler] ( &code_088C42 )
    COP [WaitOnFlagByte] ( #AE, #01 )
    COP [StageSpriteLoopMoveY] ( #17, #0C, #12 )
    COP [AnimLoop]
} >
]

code_088C32 {
    COP [SetTilePos] ( #08, #08 )
    COP [StageSpriteFrame] ( #12 )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
}

code_088C40 {
    COP [Die]
}

code_088C42 {
    COP [PrintDialogString] ( &dialogstring_088C47 )
    RTL 
}

dialogstring_088C47 `[TPL:8]Oink oink.[END]`