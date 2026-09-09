---------------------------------------------

av6C_harpist [
  actor-def < #18, #00, #10, {

  code_06D127:
    LDA #$0200
    TSB $12
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #18 )
    COP [AnimOnce]
    RTL 
} >
]