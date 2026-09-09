?INCLUDE 'bt_actor_099B1C'

---------------------------------------------

btE0_actor_098778 [
  actor-def < #00, #00, #30, {

  code_09877B:
    COP [SolidHighAbs] ( #49, #18 )
    COP [SolidHighAbs] ( #4A, #18 )
    COP [SpawnMarkedAfterAbs] ( @bt_actor_099B1C, #$04AE, #$0184, #$1800 )
    COP [SpawnMarkedAfterAbs] ( @bt_actor_099B1C, #$04AE, #$0174, #$1800 )
    COP [ExitIfFlagWord] ( #$0177, #01 )
    COP [ClearLowAbs] ( #49, #18 )
    COP [ClearLowAbs] ( #4A, #18 )
    COP [Die]
} >
]