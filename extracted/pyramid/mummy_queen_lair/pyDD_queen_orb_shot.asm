; Mummy Queen orb projectile — homing energy attack (~151 lines).
; 
; Projectile child spawned by the queen. Launches from the
; boss position and tracks toward the player using movement
; prediction. Can be blocked by Shadow form's special ability.
; Multiple orbs spawn simultaneously during attack phases.
---------------------------------------------

?BANK 0B

?INCLUDE 'ApplyOrbitalOffsetFromRef'
?INCLUDE 'mummy_queen_angle_table'

!animScratch                    7F0000
!orbitAngle                     7F0010
!orbitDiameter                  7F0012
!currentHp                      7F0026

---------------------------------------------

pyDD_queen_orb_shot {
    COP [WaitByte] ( #07 )
    LDA #$2000
    TRB $10
    LDA #$00B9
    STA $12
    LDA $26
    STA $animScratch+2, X
    LDA $24
    STA $26
    COP [StageSprAndHitbox] ( #0E )

  loc_0BAAC4:
    COP [WaitByte] ( #03 )
    COP [PlaySoundCh1] ( #26 )
    LDY $26
    LDA $0010, Y
    BIT #$2000
    BEQ loc_0BAAC4
    LDA $0026, Y
    AND #$0007
    PHX 
    TAX 
    INC 
    STA $0026, Y
    LDA $@mummy_queen_angle_table, X
    PLX 
    AND #$00FF
    STA $orbitAngle, X
    LDA #$0002
    STA $orbitDiameter, X
    LDA #$0000
    STA $animScratch, X

  loc_0BAAFA:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0BAAFA
    LDA $08
    STA $24
    STZ $08

  loc_0BAB06:
    JSR $&code_0BABAC
    COP [SetEntryHereAndYield]
    LDA $orbitDiameter, X
    CMP #$0080
    BCS loc_0BAB25
    CLC 
    ADC #$0003
    ADC $0B02
    STA $orbitDiameter, X
    DEC $24
    BPL loc_0BAB06
    BRA loc_0BAAFA

  loc_0BAB25:
    LDA $animScratch+2, X
    BNE loc_0BAB60

  loc_0BAB2B:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0BAB2B
    LDA $08
    STZ $08
    STA $24
    JSR $&code_0BABAC
    COP [SetEntryHereAndYield]

  loc_0BAB3C:
    LDA $orbitAngle, X
    CLC 
    ADC #$0002
    CLC 
    ADC $0B02
    STA $orbitAngle, X
    LDA $0036
    LSR 
    BCC loc_0BAB59
    LDA #$2000
    TSB $10
    BRA loc_0BAB2B

  loc_0BAB59:
    LDA #$2000
    TRB $10
    BRA loc_0BAB2B

  loc_0BAB60:
    LDA #$0200
    TRB $10
    COP [SetDeathCallback] ( @code_0BAB98 )
    LDA #$0000
    STA $currentHp, X

  loc_0BAB71:
    COP [AnimOneFrame]
    LDA $2A
    BEQ loc_0BAB71
    LDA $08
    STZ $08
    STA $24

  loc_0BAB7D:
    JSR $&code_0BABAC
    COP [SetEntryHereAndYield]
    LDA $orbitAngle, X
    CLC 
    ADC #$0002
    CLC 
    ADC $0B02
    STA $orbitAngle, X
    DEC $24
    BPL loc_0BAB7D
    BRA loc_0BAB71
}

code_0BAB98 {
    LDA #$0200
    TSB $10
    LDA #$0040
    TRB $10
    LDY $26
    LDA #$0000
    STA $0026, Y
    BRA loc_0BAB3C
}

code_0BABAC {
    LDY $26
    JSL $@ApplyOrbitalOffsetFromRef
    RTS 
}