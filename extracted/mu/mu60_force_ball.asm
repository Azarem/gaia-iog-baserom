; Force Ball hazard — bouncing energy projectile in Mu.
; 
; Moving hazard that bounces off walls in a predictable pattern.
; Damages the player on contact. Uses velocity vectors with
; wall collision reversal for the bounce physics. Spawned
; by room setup and persists until the player leaves.
---------------------------------------------

?INCLUDE 'interaction_handlers'

!playerXPos                     09A2
!playerYPos                     09A4
!playerSpeedEw                  09B2
!playerSpeedNs                  09B4
!currentHp                      7F0026

---------------------------------------------

mu60_force_ball [
  actor-def < #25, #00, #01, {

  code_069D50:
    COP [BranchIfSolid] ( &code_069E3A )
    LDA #$0021
    TSB $12
    COP [SetSpritePriority] ( #30 )
    COP [SpawnMarkedAfter] ( @interaction_handlers.push_handler_forceball, #$2400 )
    COP [SpawnMarkedBefore] ( @code_069D79, #$2000 )
    COP [SetEntryContinue]
    COP [StageSpriteFrame] ( #25 )
    COP [AnimOnce]
    LDA #$00FF
    STA $currentHp, X
    RTL 
} >
]

code_069D79 {
    COP [SetEntryContinue]
    LDY $06
    LDA $0014, Y
    STA $14
    LDA $0016, Y
    STA $16
    LDA $playerXPos
    CLC 
    ADC #$0008
    CMP $14
    BNE loc_069DAF
    LDA $playerYPos
    CLC 
    ADC #$0010
    CMP $16
    BNE loc_069DAF
    COP [BranchIfSolidWest] ( &code_069DA3 )
    BRA loc_069E1D
}

code_069DA3 {
    COP [BranchIfSolidEast] ( &code_069DA9 )
    BRA loc_069DE3
}

code_069DA9 {
    COP [BranchIfSolidNorth] ( &code_069E00 )
    BRA loc_069DC6

  loc_069DAF:
    COP [CardinalToPlayer]
    CMP #$0000
    BEQ loc_069DC6
    CMP #$0001
    BEQ loc_069DE3
    CMP #$0002
    BEQ code_069E00
    CMP #$0003
    BEQ loc_069E1D
    RTL 

  loc_069DC6:
    LDA $16
    SEC 
    SBC $playerYPos
    SEC 
    SBC #$0010
    CMP #$0010
    BCC loc_069DD6
    RTL 

  loc_069DD6:
    STZ $playerSpeedEw
    LDA #$FFF8
    STA $playerSpeedNs
    COP [PlaySoundCh2] ( #1D )
    RTL 

  loc_069DE3:
    LDA $playerXPos
    CLC 
    ADC #$0008
    SEC 
    SBC $14
    CMP #$0010
    BCC loc_069DF3
    RTL 

  loc_069DF3:
    LDA #$0008
    STA $playerSpeedEw
    STZ $playerSpeedNs
    COP [PlaySoundCh2] ( #1D )
    RTL 
}

code_069E00 {
    LDA $playerYPos
    CLC 
    ADC #$0010
    SEC 
    SBC $16
    CMP #$0010
    BCC loc_069E10
    RTL 

  loc_069E10:
    STZ $playerSpeedEw
    LDA #$0008
    STA $playerSpeedNs
    COP [PlaySoundCh2] ( #1D )
    RTL 

  loc_069E1D:
    LDA $14
    SEC 
    SBC $playerXPos
    SEC 
    SBC #$0008
    CMP #$0010
    BCC loc_069E2D
    RTL 

  loc_069E2D:
    LDA #$FFF8
    STA $playerSpeedEw
    STZ $playerSpeedNs
    COP [PlaySoundCh2] ( #1D )
    RTL 
}

code_069E3A {
    COP [Die]
}