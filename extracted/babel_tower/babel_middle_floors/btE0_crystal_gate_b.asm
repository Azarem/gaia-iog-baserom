; Crystal gate B of the Babel middle floors (scene $E0): marks the cells (0D,28) and (0E,28) solid, spawns two bt_static_sprite crystals and waits for $0176, which btF3_neo_viper (scene $F3) sets when the Neo Viper fight is won. It then clears the two cells and dies.
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