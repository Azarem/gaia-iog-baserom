; Pushable gold statue in the Inca treasure room — variant of ir20_statue.
; 
; Same mechanics as the secret hallway statue: solid enemy with
; push_handler_solid, $FF HP, requires Freedan's power to move.
; No destruction flag — stays as a movable obstacle.
---------------------------------------------

?INCLUDE 'enemy_stats_table'
?INCLUDE 'interaction_handlers'
?INCLUDE 'StandardEnemyDefeatHandler'

!playerFlags                    09AE
!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

ir26_statue [
  actor-def < #1E, #00, #01, {

  code_0A8899:
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

  loc_0A88B9:
    LDA #$00FF
    STA $currentHp, X
    COP [SetEntryContinue]
    LDA $currentHp, X
    CMP #$00FF
    BNE loc_0A88CC
    RTL 

  loc_0A88CC:
    LDA $playerFlags
    BIT #$0002
    BNE loc_0A88D9
    DEC $24
    BMI loc_0A88B9
    RTL 

  loc_0A88D9:
    COP [JumpScript] ( @StandardEnemyDefeatHandler.EnemyDefeatFlashAndDrop )
} >
]