; Crystal gate D in the Babel middle floors.
; 
; Fourth crystal-locked gate. All four must be opened
; to reach the upper floors.
---------------------------------------------

?INCLUDE 'bt_static_sprite'

---------------------------------------------

btE0_crystal_gate_d [
  actor-def < #00, #00, #30, {

  code_0987AB:
    COP [MarkSolidAbs] ( #15, #08 )
    COP [MarkSolidAbs] ( #16, #08 )
    COP [SpawnAfterAbsMarked] ( @bt_static_sprite, #$016E, #$0084, #$1800 )
    COP [SpawnAfterAbsMarked] ( @bt_static_sprite, #$016E, #$0074, #$1800 )
    COP [WaitOnFlagWord] ( #$0178, #01 )
    COP [ClearSolidAbs] ( #15, #08 )
    COP [ClearSolidAbs] ( #16, #08 )
    COP [Die]
} >
]