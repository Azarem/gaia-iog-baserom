; Crystal gate D of the Babel middle floors (scene $E0): marks the cells (15,08) and (16,08) solid, spawns two bt_static_sprite crystals and waits for $0178, which btF5_neo_fanger (scene $F5) sets when the Neo Fanger fight is won. It then clears the two cells and dies. The gate waits on its own flag only. $0178 is also read by btDE_kara_missing.
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