---------------------------------------------

av70_flame_center [
  actor-def < #18, #00, #18, {

  code_06D592:
    COP [AddPosition] ( #09, #03 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    RTL 
} >
]