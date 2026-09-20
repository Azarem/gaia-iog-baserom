; South Cape NPC who mentions the approaching comet.
; 
; Flag-gated dialog with two branches: before and after the castle
; summons. Provides foreshadowing about the comet.
---------------------------------------------

---------------------------------------------

sc01_astronomer [
  actor-def < #02, #00, #10, {

  code_048852:
    COP [SetInteractHandler] ( &code_0488F6 )
    COP [MarkSolidHere]
    COP [WaitByte] ( #EF )
    COP [ClearSolidHere]
    COP [StageSpriteLoopMoveY] ( #07, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #09, #03, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #09, #04, #11, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #09, #05, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #06, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #09, #02, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [WaitByte] ( #EF )
    COP [ClearSolidHere]
    COP [StageSpriteLoopMoveX] ( #08, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveY] ( #07, #12 )
    COP [AnimOnce]
    COP [StageSpriteLoopMoveX] ( #08, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #07, #0C, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #08, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveXY] ( #08, #03, #12, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #08, #06, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveY] ( #07, #05, #12 )
    COP [AnimLoop]
    COP [StageSpriteLoopMoveX] ( #09, #06, #11 )
    COP [AnimLoop]
    COP [StageSpriteFrame] ( #05 )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [WaitByte] ( #EF )
    COP [ClearSolidHere]
    COP [StageSpriteLoopMoveY] ( #07, #02, #12 )
    COP [AnimLoop]
    COP [StageSpriteMoveX] ( #09, #11 )
    COP [AnimOnce]
    COP [StageSpriteFrame] ( #04 )
    COP [AnimOnce]
    COP [MarkSolidHere]
    COP [SetEntryHere]
    RTL 
} >
]

code_0488F6 {
    COP [PrintDialogString] ( &dialogstring_0488FB )
    RTL 
}

dialogstring_0488FB `[DEF]My astronomer friend[N]said something very[N]strange: a star is[N]approaching the Earth.[END]`