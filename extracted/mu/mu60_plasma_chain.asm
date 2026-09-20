; Plasma Chain enemy — linked energy orbs that sweep across rooms.
; 
; Chain of connected energy projectiles that rotate or sweep
; in an arc pattern. The chain links follow the head node
; using offset calculations. Damages on contact with any
; segment. Used in the corridor rooms of Mu.
---------------------------------------------

?INCLUDE 'enemy_stats_table'

!playerActor                    09AA
!metaspritePtr                  7F000C
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!moveXAlt                       7F0018
!moveYAlt                       7F001A
!statsPtr                       7F0020

---------------------------------------------

mu60_plasma_chain [
  actor-def < #2C, #00, #20, {

  code_0AE946:
    COP [BranchIfSolidHere] ( &code_0AE970 )
    LDA #$&enemy_stats_table
    STA $statsPtr, X
    COP [SpawnAfterFlags] ( @code_0AE972, #$0200 )
    COP [SpawnAfterFlags] ( @code_0AEA0D, #$0200 )
    COP [SpawnAfterFlags] ( @code_0AEA0D, #$0200 )
    COP [SpawnAfterFlags] ( @code_0AEA0D, #$0200 )
    COP [SetEntryHere]
    RTL 
} >
]

code_0AE970 {
    COP [Die]
}

code_0AE972 {
    LDA $14
    STA $orbitAngle, X
    LDA $16
    STA $orbitDiameter, X
    COP [StageSprAndHitbox] ( #2C )

  code_0AE981:
    COP [WaitWhileOffscreen] ( #08 )
    COP [SetEntryHere]
    COP [BranchIfPlayerNear] ( #05, &code_0AE9D5 )
    COP [RngByte]
    AND #$007F
    SEC 
    SBC #$0040
    CLC 
    ADC $orbitAngle, X
    STA $moveXAlt, X
    COP [RngByte]
    AND #$007F
    SEC 
    SBC #$0040
    CLC 
    ADC $orbitDiameter, X
    STA $moveYAlt, X
    COP [MoveToward] ( #2C, #02 )
    COP [StageSpriteLoop] ( #2C, #04 )
    COP [AnimLoop]
    LDA $orbitAngle, X
    STA $moveXAlt, X
    LDA $orbitDiameter, X
    STA $moveYAlt, X
    COP [MoveToward] ( #2C, #01 )
    COP [StageSpriteLoop] ( #2C, #04 )
    COP [AnimLoop]
    BRA code_0AE981
}

code_0AE9D5 {
    LDY $playerActor
    LDA $0014, Y
    STA $moveXAlt, X
    LDA $0016, Y
    STA $moveYAlt, X
    COP [MoveToward] ( #2C, #02 )
    COP [StageSpriteLoop] ( #2C, #04 )
    COP [AnimLoop]
    LDA $orbitAngle, X
    STA $moveXAlt, X
    LDA $orbitDiameter, X
    STA $moveYAlt, X
    COP [MoveToward] ( #2C, #01 )
    COP [StageSpriteLoop] ( #2C, #04 )
    COP [AnimLoop]
    JMP $&code_0AE981
}

code_0AEA0D {
    COP [StageSprAndHitbox] ( #2C )
    LDA #$0100
    TSB $12

  loc_0AEA15:
    PHX 
    LDY $04
    LDX $06
    LDA $0014, Y
    CLC 
    ADC $0014, X
    LSR 
    STA $14
    LDA $0016, Y
    CLC 
    ADC $0016, X
    LSR 
    STA $16
    LDA $0018, X
    STA $18
    LDA $001A, X
    STA $1A
    LDA $001C, X
    STA $1C
    LDA $001E, X
    STA $1E
    LDX $06
    LDA $metaspritePtr, X
    PLX 
    STA $metaspritePtr, X
    COP [SetEntryHereAndYield]
    BRA loc_0AEA15
}