?INCLUDE 'table_0EDA00'

---------------------------------------------

av6B_flame [
  actor-def < #06, #00, #18, {

  code_06D55E:
    COP [AddPosition] ( #09, #03 )
    COP [SetMetasprite] ( @table_0EDA00 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #06 )
    COP [AnimOnce]
    RTL 
} >
]