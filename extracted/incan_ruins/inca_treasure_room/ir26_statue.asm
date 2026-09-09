?INCLUDE 'interaction_handlers'
?INCLUDE 'StandardEnemyDefeatHandler'
?INCLUDE 'stats_01ABF0'

!playerFlags                    09AE
!statsPtr                       7F0020
!currentHp                      7F0026

---------------------------------------------

ir26_statue [
  actor-def < #1E, #00, #01, {

  code_0A8899:
    LDA #$&stats_01ABF0
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
    COP [JumpScript] ( @StandardEnemyDefeatHandler.code_00DBB6 )
} >
]