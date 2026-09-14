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
    COP [OrActorFlags] ( #$0008 )
    COP [SolidHighHere]
    COP [SpawnMarkedAfter] ( @interaction_handlers.push_handler_solid, #$2300 )

  loc_05F8DC:
    COP [SetHitCallback] ( &code_05F8EA )
    COP [SetEntryContinue]
    LDA #$00FF
    STA $currentHp, X
    RTL 
} >
]

code_05F8EA {
    LDA $playerFlags
    BIT #$0002
    BEQ loc_05F8DC
    COP [JumpScript] ( @StandardEnemyDefeatHandler )
}