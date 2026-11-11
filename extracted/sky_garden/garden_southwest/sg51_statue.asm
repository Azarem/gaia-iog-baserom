; Movable statue in the garden southwest area (scene $51).
; 
; Movable statue: push_handler_solid pulls it one tile (16 px) toward the player while the player holds L or R (the shoulder pair $0030) on the same row, at least 32 px away and facing it. Observed as Will with no ability item or form needed (from the west and the east side; pulling along the column did not move either statue in the tests). Two placements, at tiles (30,33) and (30,34). Solid; HP resets to $FF every frame. A hit while playerFlags bit $0002 is set (RunAttackFlagSetup: Psycho Slider, Psycho Dash or run attack) jumps to StandardEnemyDefeatHandler and destroys it; any other hit leaves it standing. It reads and writes no event flag and tests no slot position.
---------------------------------------------

?INCLUDE 'enemy_stats_table'
?INCLUDE 'interaction_handlers'
?INCLUDE 'StandardEnemyDefeatHandler'

!playerFlags                    09AE
!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

sg51_statue [
  actor-def < #3D, #00, #01, {

  code_05F8C3:
    LDA #$&enemy_stats_table
    STA $statsPtr, X
    LDA #$0031
    TSB $12
    COP [OrExtraFlags] ( #$0008 )
    COP [MarkSolidHere]
    COP [SpawnAfterMarked] ( @interaction_handlers.push_handler_solid, #$2300 )

  loc_05F8DC:
    COP [SetHitCallback] ( &code_05F8EA )
    COP [SetEntryHere]
    LDA #$00FF
    STA $currentHp, X
    RTL 
} >
]

code_05F8EA {
    LDA $playerFlags
    BIT #$0002
    BEQ loc_05F8DC
    COP [JumpFar] ( @StandardEnemyDefeatHandler )
}