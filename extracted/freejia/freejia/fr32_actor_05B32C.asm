---------------------------------------------

fr32_actor_05B32C [
  actor-def < #08, #00, #10, {

  code_05B32F:
    COP [SetSpritePriority] ( #10 )
    COP [AddPosition] ( #FE, #05 )
    COP [SetEntryContinue]
    COP [AnimOneFrame]
    COP [SetEntryContinue]
    RTL 
} >
]