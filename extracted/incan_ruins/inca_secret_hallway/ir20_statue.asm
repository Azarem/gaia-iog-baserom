?INCLUDE 'enemy_stats_table'
?INCLUDE 'interaction_handlers'
?INCLUDE 'StandardEnemyDefeatHandler'

!playerFlags                    09AE
!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

ir20_statue [
  actor-def < #1E, #00, #01, {

  code_0A88E1:
    COP [BranchIfFlagByte] ( #B9, #01, &code_0A892F )
    LDA #$&enemy_stats_table
    STA $statsPtr, X
    LDA #$1111
    STA $20
    STA $22
    LDA #$0031
    TSB $12
    COP [OrActorFlags] ( #$0008 )
    COP [SolidHighHere]
    COP [SpawnMarkedAfter] ( @interaction_handlers.push_handler_solid, #$2300 )

  loc_0A8907:
    LDA #$00FF
    STA $currentHp, X
    COP [SetEntryContinue]
    LDA $currentHp, X
    CMP #$00FF
    BNE loc_0A891A
    RTL 

  loc_0A891A:
    LDA $playerFlags
    BIT #$0002
    BNE loc_0A8927
    DEC $24
    BMI loc_0A8907
    RTL 

  loc_0A8927:
    COP [SetFlagByte] ( #B9 )
    COP [JumpScript] ( @StandardEnemyDefeatHandler.EnemyDefeatFlashAndDrop )
} >
]

code_0A892F {
    COP [Die]
}