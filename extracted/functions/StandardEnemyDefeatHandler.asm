?INCLUDE 'cop_handlers_script'
?INCLUDE 'DarkGemDropSystem'
?INCLUDE 'enemy_clear_reward_table'
?INCLUDE 'EnemyDeathFlash'
?INCLUDE 'reward_actors'
?INCLUDE 'SpawnFieldRevealEffect'
?INCLUDE 'stats_01ABF0'

!sceneCurrent                   0644
!displayModeFlags               09EC
!orbitAngle                     7F0010
!statsPtr                       7F0020
!deathActionIdx                 7F0024
!extendedFlags                  7F002A
!moveScratch1                   7F002C
!moveScratch2                   7F002E

---------------------------------------------

func_00DB8A {
    LDA $statsPtr, X
    CMP #$&stats_01ABF0
    BNE loc_00DB96
    JMP $&code_00DBB6

  loc_00DB96:
    LDA $extendedFlags, X
    BIT #$0080
    BNE code_00DBB6
    SED 
    LDA $0AEE
    SEC 
    SBC #$0001
    STA $0AEE
    CLD 
    LDA $0AEC
    DEC 
    STA $0AEC
    STA $orbitAngle, X
}

code_00DBB6 {
    LDA #$0000
    STA $2C
    STA $2E
    STA $moveScratch1, X
    STA $moveScratch2, X
    COP [PlaySoundCh1] ( #06 )
    COP [SpawnLastRel] ( @EnemyDeathFlash, #00, #00, #$0302 )
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    COP [WaitByte] ( #02 )
    LDA $statsPtr, X
    CMP #$&stats_01ABF0
    BNE loc_00DBE9
    JMP $&code_00DC5F

  loc_00DBE9:
    LDA $extendedFlags, X
    BIT #$0080
    BNE code_00DC5F
    COP [SetDungeonKillFlag]
    LDA $sceneCurrent
    JSL $@cop_handlers_script.TestFlag_0300
    BCS loc_00DC03
    LDA $orbitAngle, X
    BEQ code_00DC13

  loc_00DC03:
    LDA $statsPtr, X
    TAY 
    LDA $0003, Y
    AND #$00FF
    BEQ code_00DC13
    JMP $&func_00DD5B

  code_00DC13:
    LDA #$2000
    TSB $10
    LDA $extendedFlags, X
    BIT #$0008
    BEQ loc_00DC23
    COP [ClearLowHere]

  loc_00DC23:
    LDA $deathActionIdx, X
    BEQ loc_00DC54
    JSL $@cop_handlers_script.TestFlag_0100
    BCS loc_00DC54
    LDA $deathActionIdx, X
    JSL $@cop_handlers_script.SetFlag_0100
    COP [SpawnLastRel] ( @SpawnFieldRevealEffect, #00, #00, #$0342 )
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    PHX 
    LDA $deathActionIdx, X
    TYX 
    STA $deathActionIdx, X
    PLX 

  loc_00DC54:
    LDA $orbitAngle, X
    BNE loc_00DC5D
    JMP $&func_00DD87

  loc_00DC5D:
    COP [Die]
}

code_00DC5F {
    COP [WaitByte] ( #02 )
    LDA #$2000
    TSB $10
    LDA $extendedFlags, X
    BIT #$0008
    BEQ loc_00DC72
    COP [ClearLowHere]

  loc_00DC72:
    COP [WaitByte] ( #05 )
    COP [Die]
}
---------------------------------------------

func_00DD5B {
    DEC 
    BEQ loc_00DD63
    DEC 
    BEQ loc_00DD6F
    BRA loc_00DD7B

  loc_00DD63:
    COP [SpawnLastRel] ( @DarkGemDropSystem.SpawnDarkGemType1, #00, #00, #$0420 )
    JMP $&code_00DC13

  loc_00DD6F:
    COP [SpawnLastRel] ( @DarkGemDropSystem.code_00DF52, #00, #00, #$0420 )
    JMP $&code_00DC13

  loc_00DD7B:
    COP [SpawnLastRel] ( @DarkGemDropSystem.code_00DF7B, #00, #00, #$0420 )
    JMP $&code_00DC13
}
---------------------------------------------

func_00DD87 {
    COP [SetSpritePalette] ( #00 )
    LDY $sceneCurrent
    LDA $&enemy_clear_reward_table, Y
    AND #$00FF
    PHA 
    LDA $sceneCurrent
    JSL $@cop_handlers_script.TestFlag_0300
    BCS loc_00DDB3
    COP [SetSpritePalette] ( #00 )
    LDA $01, S
    BEQ loc_00DDB3
    LDA #$0080
    TSB $displayModeFlags
    PLA 
    DEC 
    BEQ loc_00DDB6
    DEC 
    BEQ loc_00DDCA
    BRA loc_00DDDE

  loc_00DDB3:
    PLA 
    COP [Die]

  loc_00DDB6:
    COP [SpawnLastRel] ( @reward_actors.e_hp_increase, #00, #00, #$1000 )
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    COP [Die]

  loc_00DDCA:
    COP [SpawnLastRel] ( @reward_actors.e_str_increase, #00, #00, #$1000 )
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    COP [Die]

  loc_00DDDE:
    COP [SpawnLastRel] ( @reward_actors.e_def_increase, #00, #00, #$1000 )
    LDA $0012, Y
    ORA #$1000
    STA $0012, Y
    COP [Die]
}