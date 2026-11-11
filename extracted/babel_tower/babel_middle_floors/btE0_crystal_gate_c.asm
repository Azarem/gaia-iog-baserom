; Crystal gate C of the Babel middle floors (scene $E0): marks the cells (49,18) and (4A,18) solid, spawns two bt_static_sprite crystals and waits for $0177, which btF4_neo_female_vampire (scene $F4) sets when the Neo Vampires fight is won. It then clears the two cells and dies.
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