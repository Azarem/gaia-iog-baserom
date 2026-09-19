?INCLUDE 'bt_static_sprite'

---------------------------------------------

btE0_actor_098748 [
  actor-def < #00, #00, #30, {

  code_09874B:
    COP [SolidHighAbs] ( #0D, #28 )
    COP [SolidHighAbs] ( #0E, #28 )
    COP [SpawnMarkedAfterAbs] ( @bt_static_sprite, #$00EE, #$0284, #$1800 )
    COP [SpawnMarkedAfterAbs] ( @bt_static_sprite, #$00EE, #$0274, #$1800 )
    COP [ExitIfFlagWord] ( #$0176, #01 )
    COP [ClearLowAbs] ( #0D, #28 )
    COP [ClearLowAbs] ( #0E, #28 )
    COP [Die]
} >
]