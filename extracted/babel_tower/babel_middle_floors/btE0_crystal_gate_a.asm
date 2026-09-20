; Crystal gate A in the Babel middle floors.
; 
; Gate that opens when the corresponding crystal is collected.
; Small script that checks crystal flag and toggles passage.
---------------------------------------------

?INCLUDE 'bt_static_sprite'

---------------------------------------------

btE0_crystal_gate_a [
  actor-def < #00, #00, #30, {

  code_09871B:
    COP [MarkSolidAbs] ( #71, #38 )
    COP [MarkSolidAbs] ( #72, #38 )
    COP [SpawnAfterAbsMarked] ( @bt_static_sprite, #$072E, #$0384, #$1800 )
    COP [SpawnAfterAbsMarked] ( @bt_static_sprite, #$072E, #$0374, #$1800 )
    COP [WaitOnFlagWord] ( #$0175, #01 )
    COP [ClearSolidAbs] ( #71, #38 )
    COP [ClearSolidAbs] ( #72, #38 )
    COP [Die]
} >
]