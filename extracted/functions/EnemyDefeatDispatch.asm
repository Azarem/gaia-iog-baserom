?INCLUDE 'cop_handlers_flags'
?INCLUDE 'EnemyDeathFlash'
?INCLUDE 'field_reveal_object'
?INCLUDE 'SpawnFieldRevealEffect'
?INCLUDE 'StandardEnemyDefeatHandler'

!orbitAngle                     7F0010
!deathActionIdx                 7F0024
!extendedFlags                  7F002A
!moveScratch1                   7F002C
!moveScratch2                   7F002E

---------------------------------------------

EnemyDefeatDispatch {
    LDA $0AEC
    CMP #$0001
    BNE loc_0AA460
    LDA #$6000
    TRB $12
    COP [StageForceMoveXY] ( #00, #00 )
    LDA #$0000
    STA $moveScratch1, X
    STA $moveScratch2, X
    COP [JumpScript] ( @StandardEnemyDefeatHandler )

  loc_0AA460:
    COP [CallScript] ( &code_0AA474 )
    COP [SpawnAfterFlags] ( @field_reveal_object, #$0020 )
    LDA $orbitAngle, X
    STA $0026, Y
    COP [Die]
}

code_0AA474 {
    COP [PlaySoundCh1] ( #03 )
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
    COP [StageForceMoveXY] ( #00, #00 )
    LDA #$0000
    STA $moveScratch1, X
    STA $moveScratch2, X
    COP [SpawnLastRel] ( @EnemyDeathFlash, #00, #00, #$0302 )
    COP [SetDungeonKillFlag]
    LDA #$2000
    TSB $10
    LDA $extendedFlags, X
    BIT #$0008
    BEQ loc_0AA4B8
    COP [ClearLowHere]

  loc_0AA4B8:
    LDA $deathActionIdx, X
    BEQ loc_0AA4E0
    JSL $@cop_handlers_flags.TestFlag_0100
    BCS loc_0AA4E0
    LDA $deathActionIdx, X
    JSL $@cop_handlers_flags.SetFlag_0100
    COP [SpawnLastRel] ( @SpawnFieldRevealEffect, #00, #00, #$0342 )
    PHX 
    LDA $deathActionIdx, X
    TYX 
    STA $deathActionIdx, X
    PLX 

  loc_0AA4E0:
    COP [RestoreSavedPtr]
}