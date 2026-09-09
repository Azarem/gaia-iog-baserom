?INCLUDE 'bt_actor_099B1C'

---------------------------------------------

btE0_actor_0987A8 [
  actor-def < #00, #00, #30, {

  code_0987AB:
    COP [SolidHighAbs] ( #15, #08 )
    COP [SolidHighAbs] ( #16, #08 )
    COP [SpawnMarkedAfterAbs] ( @bt_actor_099B1C, #$016E, #$0084, #$1800 )
    COP [SpawnMarkedAfterAbs] ( @bt_actor_099B1C, #$016E, #$0074, #$1800 )
    COP [ExitIfFlagWord] ( #$0178, #01 )
    COP [ClearLowAbs] ( #15, #08 )
    COP [ClearLowAbs] ( #16, #08 )
    COP [Die]
} >
]