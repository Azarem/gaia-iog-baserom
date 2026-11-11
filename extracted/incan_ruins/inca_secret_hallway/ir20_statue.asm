; Pushable gold statue in the Inca secret hallway — blocks passage.
; 
; Solid enemy-type actor with $FF HP and push_handler_solid interaction.
; Every frame the actor compares its HP with $FF. When the HP is still $FF it returns. When the HP differs (a hit landed since the previous frame) it reads playerFlags: with bit $0002 set it sets flag $B9 and jumps to StandardEnemyDefeatHandler (EnemyDefeatFlashAndDrop); with the bit clear it decrements its scratch word $24 and restores the HP to $FF. There is no position test. Measured with an HP poke: bit $0002 set destroys the statue and sets $B9; bit clear resets the HP and changes nothing else. What sets playerFlags bit $0002 during a real hit is not traced. Uses enemy_stats_table entry 0.
---------------------------------------------

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
    COP [BranchOnFlagByte] ( #B9, #01, &code_0A892F )
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

  loc_0A8907:
    LDA #$00FF
    STA $currentHp, X
    COP [SetEntryHere]
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
    COP [JumpFar] ( @StandardEnemyDefeatHandler.EnemyDefeatFlashAndDrop )
} >
]

code_0A892F {
    COP [Die]
}