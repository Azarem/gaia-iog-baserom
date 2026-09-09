?INCLUDE 'player_character'

!joypadMaskStd                  065A
!playerActor                    09AA
!playerFlags                    09AE

---------------------------------------------

awB3_actor_0898DA [
  actor-def < #00, #00, #30, {

  code_0898DD:
    COP [BranchIfFlagWord] ( #$016E, #01, &code_089928 )
    COP [SetEntryContinue]
    COP [BranchIfPlayerInAbsTiles] ( #6A, #0C, #6F, #0D, &code_0898EF )
    RTL 
} >
]

code_0898EF {
    COP [LoopInit] ( #14 )
    LDA #$CFF0
    TSB $joypadMaskStd
    COP [LoopNext]
    COP [PlaySoundBoth] ( #$0F0F )
    COP [StageBgChange] ( #6E )
    COP [ApplyBgChange]
    COP [SetFlagWord] ( #$016E )
    LDY $playerActor
    SEP #$20
    LDA #$^player_character.ClimbVineEntry
    STA $0002, Y
    REP #$20
    LDA #$&player_character.ClimbVineEntry
    STA $0000, Y
    LDA #$0000
    STA $0008, Y
    STA $002A, Y
    LDA #$0800
    TSB $playerFlags
}

code_089928 {
    COP [Die]
}