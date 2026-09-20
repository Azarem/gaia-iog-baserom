; Seth in the South Cape school after the opening lesson.
; 
; Speaks his line about meeting at the cave, then leaves.
; Part of the post-school cutscene sequence.
---------------------------------------------

---------------------------------------------

sc08_seth [
  actor-def < #13, #00, #18, {

  code_048D71:
    COP [BranchOnFlagByte] ( #10, #01, &code_048D93 )
    COP [WaitOnFlagByte] ( #10, #01 )
    COP [StageSpriteLoop] ( #14, #22 )
    COP [AnimLoop]
    COP [WaitOnFlagByte] ( #01, #01 )
    COP [StageSpriteLoopMoveY] ( #17, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #19, #04, #11 )
    COP [AnimLoop]
} >
]

code_048D93 {
    COP [Die]
}