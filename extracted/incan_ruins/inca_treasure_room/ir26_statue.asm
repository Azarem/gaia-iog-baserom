; Gold statue of the Inca treasure room (scene $26): same script as ir20_statue without the flag.
; 
; Solid enemy-type actor: it points statsPtr at enemy_stats_table, marks its tile solid and spawns interaction_handlers.push_handler_solid as a child (that child pulls the statue one tile toward the player on a shoulder-button press plus facing). The main loop keeps currentHp at $FF. After a hit: when playerFlags bit $0002 is set it jumps to StandardEnemyDefeatHandler.EnemyDefeatFlashAndDrop, so the statue is destroyed; otherwise it decrements the actor word $24 and restores HP to $FF once the word goes negative. It sets no event flag, so a destroyed statue is back on the next scene load. The script has no form test (push_handler_solid tests only the shoulder buttons and the player's facing; the sg51 statue, which uses the same handler, was pulled as Will; this room was not run).
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
    COP [OrExtraFlags] ( #$0008 )
    COP [MarkSolidHere]
    COP [SpawnAfterMarked] ( @interaction_handlers.push_handler_solid, #$2300 )

  loc_0A88B9:
    LDA #$00FF
    STA $currentHp, X
    COP [SetEntryHere]
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
    COP [JumpFar] ( @StandardEnemyDefeatHandler.EnemyDefeatFlashAndDrop )
} >
]