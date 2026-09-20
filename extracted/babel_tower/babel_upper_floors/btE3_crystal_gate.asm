; Crystal gate in the Babel upper floors.
; 
; Upper-level gate with crystal key requirement. Same
; mechanics as the middle floor gates.
---------------------------------------------

?INCLUDE 'bt_static_sprite'

---------------------------------------------

btE3_crystal_gate [
  actor-def < #00, #00, #30, {

  code_0987DB:
    COP [SolidHighAbs] ( #29, #38 )
    COP [SolidHighAbs] ( #2A, #38 )
    COP [SpawnMarkedAfterAbs] ( @bt_static_sprite, #$02AE, #$0384, #$1800 )
    COP [SpawnMarkedAfterAbs] ( @bt_static_sprite, #$02AE, #$0374, #$1800 )
    COP [ExitIfFlagWord] ( #$0179, #01 )
    COP [ClearLowAbs] ( #29, #38 )
    COP [ClearLowAbs] ( #2A, #38 )
    COP [Die]
} >
]