; Will's pet animal in his house.
; 
; Small ambient actor. Minimal dialog.
---------------------------------------------

---------------------------------------------

sc06_wills_pet [
  actor-def < #1A, #00, #30, {

  code_04A432:
    COP [BranchIfFlagByte] ( #1B, #01, &code_04A45F )
    COP [ExitIfFlagByte] ( #04, #01 )
    LDA #$2000
    TRB $10
    COP [SetTilePos] ( #09, #1A )
    COP [StageSpriteFrame] ( #1D )
    COP [AnimOnce]
    COP [ExitIfFlagByte] ( #08, #01 )
    COP [WaitByte] ( #3F )
    COP [StageSpriteLoopMoveX] ( #20, #03, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #1E, #09, #11 )
    COP [AnimLoop]
} >
]

code_04A45F {
    COP [Die]
}