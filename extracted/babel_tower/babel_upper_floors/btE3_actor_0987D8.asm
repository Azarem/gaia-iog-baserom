?INCLUDE 'bt_actor_099B1C'

---------------------------------------------

btE3_actor_0987D8 [
  actor-def < #00, #00, #30, {

  code_0987DB:
    COP [SolidHighAbs] ( #29, #38 )
    COP [SolidHighAbs] ( #2A, #38 )
    COP [SpawnMarkedAfterAbs] ( @bt_actor_099B1C, #$02AE, #$0384, #$1800 )
    COP [SpawnMarkedAfterAbs] ( @bt_actor_099B1C, #$02AE, #$0374, #$1800 )
    COP [ExitIfFlagWord] ( #$0179, #01 )
    COP [ClearLowAbs] ( #29, #38 )
    COP [ClearLowAbs] ( #2A, #38 )
    COP [Die]
} >
]