?INCLUDE 'oneshot_palette_flash_1C'
?INCLUDE 'player_character'

!playerActor                    09AA
!playerFlags                    09AE
!TM                             212C
!CGADSUB                        2131
!COLDATA                        2132

---------------------------------------------

awB4_actor_08992A [
  actor-def < #00, #00, #30, {

  code_08992D:
    COP [BranchIfPlayerAt] ( #$0578, #$0010, &code_089937 )
    BRA code_089988
} >
]

code_089937 {
    LDY $playerActor
    LDA $0010, Y
    AND #$FFF7
    ORA #$0200
    STA $0010, Y
    SEP #$20
    LDA #$^player_character.loc_02C63B
    STA $0002, Y
    REP #$20
    LDA #$&player_character.loc_02C63B
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002A, Y
    LDA #$0800
    TSB $playerFlags
    COP [BranchIfFlagByte] ( #B5, #01, &code_089988 )
    COP [SetFlagByte] ( #B5 )
    SEP #$20
    LDA #$15
    STA $TM
    LDA #$A1
    STA $CGADSUB
    LDA #$FF
    STA $COLDATA
    REP #$20
    COP [WaitByte] ( #B3 )
    COP [SpawnThinker] ( @oneshot_palette_flash_1C.code_00B7EC )
}

code_089988 {
    COP [SetEntryContinue]
    COP [BranchIfButton] ( #$0F01, &code_089991 )
    RTL 
}

code_089991 {
    COP [BranchIfPlayerInAbsTiles] ( #3D, #0C, #43, #1B, &code_0899A2 )
    COP [BranchIfPlayerInAbsTiles] ( #43, #06, #5D, #1B, &code_0899A2 )
    RTL 
}

code_0899A2 {
    LDA $0036
    AND #$0007
    BEQ loc_0899AB
    RTL 

  loc_0899AB:
    COP [PlaySoundCh2] ( #08 )
    RTL 
}