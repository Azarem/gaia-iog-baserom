; Crystal gate B in the Babel middle floors.
; 
; Second crystal-locked gate. Same mechanics as gate A
; with a different flag condition.
---------------------------------------------

?INCLUDE 'bt_static_sprite'

---------------------------------------------

btE0_crystal_gate_b [
  actor-def < #00, #00, #30, {

  code_09874B:
    COP [MarkSolidAbs] ( #0D, #28 )
    COP [MarkSolidAbs] ( #0E, #28 )
    COP [SpawnAfterAbsMarked] ( @bt_static_sprite, #$00EE, #$0284, #$1800 )
    COP [SpawnAfterAbsMarked] ( @bt_static_sprite, #$00EE, #$0274, #$1800 )
    COP [WaitOnFlagWord] ( #$0176, #01 )
    COP [ClearSolidAbs] ( #0D, #28 )
    COP [ClearSolidAbs] ( #0E, #28 )
    COP [Die]
} >
]