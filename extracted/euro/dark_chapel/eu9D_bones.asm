?INCLUDE 'table_0EDA00'

---------------------------------------------

eu9D_bones [
  actor-def < #02, #00, #10, {

  code_07D23A:
    LDA #$0200
    TSB $12
    COP [SetMetasprite] ( @table_0EDA00 )
    COP [StageSpriteFrame] ( #02 )
    COP [AnimOnce]
    COP [SolidHighHere]
    COP [AddPosition] ( #00, #04 )
    COP [SetEntryContinue]
    RTL 
} >
]