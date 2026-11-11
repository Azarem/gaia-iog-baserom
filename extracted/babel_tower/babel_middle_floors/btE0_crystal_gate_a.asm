; Crystal gate A of the Babel middle floors (scene $E0): marks the cells (71,38) and (72,38) solid, spawns two bt_static_sprite crystals and waits for $0175, which btF2_neo_castoth (scene $F2) sets when the Neo Castoth fight is won. It then clears the two cells and dies.
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