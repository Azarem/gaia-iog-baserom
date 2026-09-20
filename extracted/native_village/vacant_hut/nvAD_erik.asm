; Erik in the vacant hut — exhausted from the journey.
; 
; NPC: "I'm exhausted. I feel like sleeping for days."
; Simple rest dialog as the party recuperates.
---------------------------------------------

---------------------------------------------

nvAD_erik [
  actor-def < #03, #00, #10, {

  code_088BA2:
    COP [BranchOnFlagByte] ( #B2, #01, &code_088BD1 )
    COP [BranchOnFlagByte] ( #AE, #01, &code_088BC3 )
    COP [BranchOnFlagByte] ( #AD, #00, &code_088BD1 )
    COP [SetInteractHandler] ( &code_088BD3 )
    COP [WaitOnFlagByte] ( #AE, #01 )
    COP [StageSpriteLoopMoveY] ( #07, #04, #12 )
    COP [AnimLoop]
} >
]

code_088BC3 {
    COP [SetTilePos] ( #07, #0A )
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
}

code_088BD1 {
    COP [Die]
}

code_088BD3 {
    COP [PrintDialogString] ( &dialogstring_088BD8 )
    RTL 
}

dialogstring_088BD8 `[TPL:A][TPL:3]Erik: I'm exhausted. [N]I feel like sleeping [N]for days.[PAL:0][END]`