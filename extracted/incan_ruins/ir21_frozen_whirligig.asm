---------------------------------------------

ir21_frozen_whirligig [
  actor-def < #1B, #00, #00, {

  code_0A99C6:
    LDA #$0010
    TSB $12
    COP [AddPosition] ( #08, #08 )
    COP [StageSpriteFrame] ( #1B )
    COP [AnimOnce]
    COP [SetEntryContinue]
    RTL 
} >
]