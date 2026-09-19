?INCLUDE 'bt_static_sprite'

---------------------------------------------

btE0_crystal_gate_c [
  actor-def < #00, #00, #30, {

  code_09877B:
    COP [SolidHighAbs] ( #49, #18 )
    COP [SolidHighAbs] ( #4A, #18 )
    COP [SpawnMarkedAfterAbs] ( @bt_static_sprite, #$04AE, #$0184, #$1800 )
    COP [SpawnMarkedAfterAbs] ( @bt_static_sprite, #$04AE, #$0174, #$1800 )
    COP [ExitIfFlagWord] ( #$0177, #01 )
    COP [ClearLowAbs] ( #49, #18 )
    COP [ClearLowAbs] ( #4A, #18 )
    COP [Die]
} >
]