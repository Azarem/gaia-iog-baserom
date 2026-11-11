; Crystal gate of the Babel upper floors (scene $E3): marks the cells (29,38) and (2A,38) solid, spawns two bt_static_sprite crystals and waits for $0179, which btF6_neo_queen (scene $F6) sets when the Neo Queen fight is won, just before it queues scene $E3. It then clears the two cells and dies.
---------------------------------------------

?INCLUDE 'bt_static_sprite'

---------------------------------------------

btE3_crystal_gate [
  actor-def < #00, #00, #30, {

  code_0987DB:
    COP [MarkSolidAbs] ( #29, #38 )
    COP [MarkSolidAbs] ( #2A, #38 )
    COP [SpawnAfterAbsMarked] ( @bt_static_sprite, #$02AE, #$0384, #$1800 )
    COP [SpawnAfterAbsMarked] ( @bt_static_sprite, #$02AE, #$0374, #$1800 )
    COP [WaitOnFlagWord] ( #$0179, #01 )
    COP [ClearSolidAbs] ( #29, #38 )
    COP [ClearSolidAbs] ( #2A, #38 )
    COP [Die]
} >
]