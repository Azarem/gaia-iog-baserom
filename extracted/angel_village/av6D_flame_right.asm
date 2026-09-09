---------------------------------------------

av6D_flame_right [
  actor-def < #19, #00, #18, {

  code_06D581:
    COP [ToggleHFlip]
    COP [AddPosition] ( #09, #03 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #99 )
    COP [AnimOnce]
    RTL 
} >
]