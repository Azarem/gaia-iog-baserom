; Utility function that sets the player actor's script entry point to one of four idle-facing variants (South/North/West/East) from player_character based on the A register index.
; 
; Clears movement scratch and frame counter. Called by cutscene actors in Diamond Mine elevator, Incan Ruins Lily escort, Babel Tower Kara/Olman scenes, and others to force a specific idle facing before scripted movement.
---------------------------------------------

?INCLUDE 'player_character'

!playerActor                    09AA
!moveScratch1                   7F002C
!moveScratch2                   7F002E

---------------------------------------------

InitPlayerScriptVariant {
    PHX 
    ASL 
    TAX 
    LDA $@player_idle_entry_table, X
    LDX $playerActor
    STA $0000, X
    SEP #$20
    LDA #$^player_character.IdleStandSouth
    STA $0002, X
    REP #$20
    STZ $0008, X
    STZ $002C, X
    STZ $002E, X
    LDA #$0000
    STA $moveScratch1, X
    STA $moveScratch2, X
    PLX 
    RTL 
}

player_idle_entry_table [
  &player_character.IdleStandSouth   ;00
  &player_character.IdleStandNorth   ;01
  &player_character.IdleStandWest   ;02
  &player_character.IdleStandEast   ;03
]