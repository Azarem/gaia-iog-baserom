?INCLUDE 'player_move_main'

!extVelocityX                   0408
!extVelocityY                   040A
!playerActor                    09AA
!playerFlags                    09AE
!playerSpeedEw                  09B2
!playerSpeedNs                  09B4
!slopeFracAccum                 09C6
!iframeCounter                  7F0028

---------------------------------------------

PlayerMoveController {
    LDA $14
    ASL 
    ASL 
    STA $14
    LDA $16
    ASL 
    ASL 
    STA $16
    COP [SetEntryContinue]
    PHX 
    LDX $playerActor
    LDA $0010, X
    BIT #$0080
    BEQ loc_02B2C0
    LDA $iframeCounter, X
    BMI loc_02B2C0
    PLX 
    RTL 

  loc_02B2C0:
    PLX 
    LDA $playerFlags
    BIT #$0A00
    BEQ loc_02B2D0
    STZ $extVelocityX
    STZ $extVelocityY
    RTL 

  loc_02B2D0:
    LDY $playerActor
    LDA $14
    LSR 
    LSR 
    CMP $0014, Y
    BEQ loc_02B2E3
    LDA $0014, Y
    ASL 
    ASL 
    STA $14

  loc_02B2E3:
    LDA $16
    LSR 
    LSR 
    CMP $0016, Y
    BEQ loc_02B2F3
    LDA $0016, Y
    ASL 
    ASL 
    STA $16

  loc_02B2F3:
    LDA $playerFlags
    BIT #$3000
    BEQ loc_02B300
    LDA #$0000
    BRA loc_02B303

  loc_02B300:
    JSR $&JoypadToVelocity

  loc_02B303:
    PHA 
    LDA $14
    STA $0022
    STZ $0020
    LDA $playerSpeedEw
    BNE loc_02B327
    LDA $01, S
    AND #$00FF
    BIT #$0080
    BEQ loc_02B31E
    ORA #$FF00

  loc_02B31E:
    CLC 
    ADC $extVelocityX
    STA $0020
    BRA loc_02B336

  loc_02B327:
    ASL 
    ASL 
    CLC 
    ADC $extVelocityX
    STA $0020
    LDA #$1000
    TRB $playerFlags

  loc_02B336:
    STZ $extVelocityX
    STZ $0024
    LDA $16
    STA $0026
    LDA $playerSpeedNs
    BNE loc_02B360
    STZ $slopeFracAccum
    LDA $01, S
    XBA 
    AND #$00FF
    BIT #$0080
    BEQ loc_02B357
    ORA #$FF00

  loc_02B357:
    CLC 
    ADC $extVelocityY
    STA $0024
    BRA loc_02B36F

  loc_02B360:
    ASL 
    ASL 
    CLC 
    ADC $extVelocityY
    STA $0024
    LDA #$1000
    TRB $playerFlags

  loc_02B36F:
    STZ $extVelocityY
    PLA 
    LDY $playerActor
    LDA $0010, Y
    BIT #$0008
    BNE loc_02B394
    LDA $0020
    CLC 
    ADC $0022
    STA $0022
    LDA $0024
    CLC 
    ADC $0026
    STA $0026
    BRA loc_02B39C

  loc_02B394:
    STX $000A
    TXY 
    JSL $@player_move_main.PlayerMovementTick

  loc_02B39C:
    LDY $playerActor
    LDA $0022
    STA $14
    LSR 
    LSR 
    STA $0014, Y
    LDA $0026
    STA $16
    LSR 
    LSR 
    STA $0016, Y
    LDA $0010, Y
    AND #$FFFB
    PHA 
    LDA $10
    AND #$0004
    ORA $01, S
    STA $0010, Y
    PLA 
    RTL 
}

JoypadToVelocity {
    PHP 
    SEP #$20
    LDA $0657
    BIT #$02
    BNE loc_02B3E3
    BIT #$01
    BNE loc_02B400
    BIT #$08
    BNE loc_02B41D
    BIT #$04
    BNE loc_02B424
    LDA #$00
    XBA 
    LDA #$00
    BRA loc_02B3FE

  loc_02B3E3:
    BIT #$0C
    BEQ loc_02B3F9
    BIT #$08
    BNE loc_02B3F2
    LDA #$06
    XBA 
    LDA #$FA
    BRA loc_02B3FE

  loc_02B3F2:
    LDA #$FA
    XBA 
    LDA #$FA
    BRA loc_02B3FE

  loc_02B3F9:
    LDA #$00
    XBA 
    LDA #$F8

  loc_02B3FE:
    PLP 
    RTS 

  loc_02B400:
    BIT #$0C
    BEQ loc_02B416
    BIT #$08
    BNE loc_02B40F
    LDA #$06
    XBA 
    LDA #$06
    BRA loc_02B41B

  loc_02B40F:
    LDA #$FA
    XBA 
    LDA #$06
    BRA loc_02B41B

  loc_02B416:
    LDA #$00
    XBA 
    LDA #$08

  loc_02B41B:
    PLP 
    RTS 

  loc_02B41D:
    LDA #$F8
    XBA 
    LDA #$00
    PLP 
    RTS 

  loc_02B424:
    LDA #$08
    XBA 
    LDA #$00
    PLP 
    RTS 
}