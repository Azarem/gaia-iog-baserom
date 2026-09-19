; Enemy defeat dispatcher for dungeon enemies that tracks remaining enemy count.
; 
; When the last enemy dies ($0AEC = 1), jumps to StandardEnemyDefeatHandler for
; the full area-clear sequence. Otherwise, decrements the dungeon kill counter
; ($0AEC) and BCD display counter ($0AEE), plays death SFX, spawns death flash,
; sets dungeon kill flag, optionally clears collision tile, and spawns a field
; reveal effect if deathActionIdx is set and not already triggered.
---------------------------------------------

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
    LDA $0AEC             ; Remaining enemies in dungeon area
    CMP #$0001
    BNE loc_0AA460        ; Not last → normal death
    LDA #$6000            ; Last enemy: clear movement flags
    TRB $12
    COP [StageForceMoveXY] ( #00, #00 ) ; Halt movement
    LDA #$0000
    STA $moveScratch1, X
    STA $moveScratch2, X
    COP [JumpScript] ( @StandardEnemyDefeatHandler ) ; Full defeat sequence

  loc_0AA460:
    COP [CallScript] ( &code_0AA474 ) ; Non-last death handler
    COP [SpawnAfterFlags] ( @field_reveal_object, #$0020 ) ; Spawn stat gem reveal
    LDA $orbitAngle, X    ; Pass angle to spawned actor
    STA $0026, Y
    COP [Die]
}

---------------------------------------------
; Per-enemy death processing: decrement counters, spawn VFX, check for field reveal

code_0AA474 {
    COP [PlaySoundCh1] ( #03 ) ; Death SFX
    SED                   ; BCD decrement of display counter
    LDA $0AEE
    SEC 
    SBC #$0001
    STA $0AEE
    CLD 
    LDA $0AEC             ; Decrement remaining enemy count
    DEC 
    STA $0AEC
    STA $orbitAngle, X    ; Store for spawned actors
    COP [StageForceMoveXY] ( #00, #00 ) ; Halt movement
    LDA #$0000
    STA $moveScratch1, X
    STA $moveScratch2, X
    COP [SpawnLastRel] ( @EnemyDeathFlash, #00, #00, #$0302 ) ; Spawn death flash VFX
    COP [SetDungeonKillFlag]
    LDA #$2000
    TSB $10               ; Set display flag $2000
    LDA $extendedFlags, X
    BIT #$0008            ; Bit 3: enemy occupies collision tile?
    BEQ loc_0AA4B8
    COP [ClearLowHere]    ; Clear collision at enemy position

  loc_0AA4B8:
    LDA $deathActionIdx, X ; Has a field reveal action?
    BEQ loc_0AA4E0        ; No → skip
    JSL $@cop_handlers_flags.TestFlag_0100 ; Already triggered?
    BCS loc_0AA4E0        ; Yes → skip
    LDA $deathActionIdx, X
    JSL $@cop_handlers_flags.SetFlag_0100 ; Mark as triggered
    COP [SpawnLastRel] ( @SpawnFieldRevealEffect, #00, #00, #$0342 ) ; Spawn reveal effect
    PHX 
    LDA $deathActionIdx, X ; Pass action index to spawned actor
    TYX 
    STA $deathActionIdx, X
    PLX 

  loc_0AA4E0:
    COP [RestoreSavedPtr]
}