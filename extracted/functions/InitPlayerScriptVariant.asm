?INCLUDE 'player_character'

!playerActor                    09AA
!moveScratch1                   7F002C
!moveScratch2                   7F002E

---------------------------------------------

InitPlayerScriptVariant {
    PHX 
    ASL 
    TAX 
    LDA $@table_00C710, X
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

table_00C710 [
  &player_character.IdleStandSouth   ;00
  &player_character.IdleStandNorth   ;01
  &player_character.IdleStandWest   ;02
  &player_character.IdleStandEast   ;03
]