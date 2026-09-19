?INCLUDE 'bt_static_sprite'

---------------------------------------------

btE0_actor_098718 [
  actor-def < #00, #00, #30, {

  code_09871B:
    COP [SolidHighAbs] ( #71, #38 )
    COP [SolidHighAbs] ( #72, #38 )
    COP [SpawnMarkedAfterAbs] ( @bt_static_sprite, #$072E, #$0384, #$1800 )
    COP [SpawnMarkedAfterAbs] ( @bt_static_sprite, #$072E, #$0374, #$1800 )
    COP [ExitIfFlagWord] ( #$0175, #01 )
    COP [ClearLowAbs] ( #71, #38 )
    COP [ClearLowAbs] ( #72, #38 )
    COP [Die]
} >
]