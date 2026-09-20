; Crystal gate C in the Babel middle floors.
; 
; Third crystal-locked gate.
---------------------------------------------

?INCLUDE 'bt_static_sprite'

---------------------------------------------

btE0_crystal_gate_c [
  actor-def < #00, #00, #30, {

  code_09877B:
    COP [MarkSolidAbs] ( #49, #18 )
    COP [MarkSolidAbs] ( #4A, #18 )
    COP [SpawnAfterAbsMarked] ( @bt_static_sprite, #$04AE, #$0184, #$1800 )
    COP [SpawnAfterAbsMarked] ( @bt_static_sprite, #$04AE, #$0174, #$1800 )
    COP [WaitOnFlagWord] ( #$0177, #01 )
    COP [ClearSolidAbs] ( #49, #18 )
    COP [ClearSolidAbs] ( #4A, #18 )
    COP [Die]
} >
]