; Snake pit entry of Angkor Wat (scene $B4). Each time the player stands at pixel (0578,0010) the actor writes player_character.loc_02C63B into the player's entry word (the fall), sets bit $0200 and clears bit $0008 of the player's flags $10, zeroes the player's $08 and $2A and sets playerFlags $0800. The first time ($B5 clear) it also sets $B5, writes TM = $15, CGADSUB = $A1 and COLDATA = $FF, waits 179 frames and spawns oneshot_backdrop_fade_out_1C. Afterwards it polls the buttons of mask $0F01: inside tiles (3D,0C)-(43,1B) or (43,06)-(5D,1B) it plays sound ch2 $08 every 8 frames.
---------------------------------------------

?INCLUDE 'oneshot_backdrop_fade_out_1C'
?INCLUDE 'player_character'

!frameCounter                   0036
!playerActor                    09AA
!playerFlags                    09AE
!TM                             212C
!CGADSUB                        2131
!COLDATA                        2132

---------------------------------------------

awB4_snake_pit_entry [
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
    COP [BranchOnFlagByte] ( #B5, #01, &code_089988 )
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
    COP [SpawnThinker] ( @oneshot_backdrop_fade_out_1C.FadeBackdropOut1C )
}

code_089988 {
    COP [SetEntryHere]
    COP [BranchIfPressed] ( #$0F01, &code_089991 )
    RTL 
}

code_089991 {
    COP [BranchIfPlayerInAbsTiles] ( #3D, #0C, #43, #1B, &code_0899A2 )
    COP [BranchIfPlayerInAbsTiles] ( #43, #06, #5D, #1B, &code_0899A2 )
    RTL 
}

code_0899A2 {
    LDA $frameCounter
    AND #$0007
    BEQ loc_0899AB
    RTL 

  loc_0899AB:
    COP [PlaySoundCh2] ( #08 )
    RTL 
}