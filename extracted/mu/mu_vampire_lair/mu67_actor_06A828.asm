---------------------------------------------

mu67_actor_06A828 [
  actor-def < #03, #00, #30, {

  code_06A82B:
    COP [ExitIfFlagByte] ( #88, #01 )
    COP [WaitByte] ( #1D )
    LDA #$2000
    TRB $10
    COP [StageSpriteLoopMoveY] ( #07, #02, #02 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #03 )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
} >
]