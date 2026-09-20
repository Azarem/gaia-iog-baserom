; Conveyor belt controller in the Solid Arm lair (~133 lines).
; 
; Manages automated conveyor movement that carries the player
; through the boss approach corridor. Handles belt speed,
; direction, player attachment, and obstacle timing. Creates
; the mechanical atmosphere of the lair.
---------------------------------------------

!extVelocityX                   0408
!extVelocityY                   040A
!sceneCurrent                   0644
!playerXTile                    09A6
!playerYTile                    09A8

---------------------------------------------

btEA_conveyor_controller [
  actor-def < #00, #00, #20, {

  code_0ADC58:
    PHX 
    SEP #$20
    LDX #$0000

  loc_0ADC5E:
    LDA $@sc_ix_0ADCFE, X
    BNE loc_0ADC69

  loc_0ADC64:
    REP #$20
    PLX 
    COP [Die]

  loc_0ADC69:
    CMP $sceneCurrent
    BEQ loc_0ADC75
    BCS loc_0ADC64
    INX 
    INX 
    INX 
    BRA loc_0ADC5E

  loc_0ADC75:
    REP #$20
    LDA $@sc_ix_0ADCFE+1, X
    SEC 
    SBC #$&sc_ix_0ADCFE
    STA $24
    PLX 
    COP [WaitByte] ( #01 )
    PHX 
    LDX $24
    PHD 
    LDA #$0000
    TCD 
    LDA $playerXTile
    STA $18
    INC 
    STA $1A
    LDA $playerYTile
    STA $1C
    INC 
    STA $1E
    SEP #$20

  loc_0ADC9F:
    LDA $@sc_ix_0ADCFE, X
    BMI loc_0ADCF9
    CMP $1A
    BCS loc_0ADCF1
    LDA $@sc_ix_0ADCFE+1, X
    CMP $1E
    BCS loc_0ADCF1
    LDA $@sc_ix_0ADCFE+2, X
    CMP $18
    BCC loc_0ADCF1
    LDA $@sc_ix_0ADCFE+3, X
    CMP $1C
    BCC loc_0ADCF1
    LDA $@sc_ix_0ADCFE+4, X
    REP #$20
    AND #$00FF
    BIT #$0080
    BEQ loc_0ADCD2
    ORA #$FF00

  loc_0ADCD2:
    CLC 
    ADC $extVelocityX
    STA $extVelocityX
    LDA $@sc_ix_0ADCFE+5, X
    AND #$00FF
    BIT #$0080
    BEQ loc_0ADCE8
    ORA #$FF00

  loc_0ADCE8:
    CLC 
    ADC $extVelocityY
    STA $extVelocityY
    SEP #$20

  loc_0ADCF1:
    INX 
    INX 
    INX 
    INX 
    INX 
    INX 
    BRA loc_0ADC9F

  loc_0ADCF9:
    REP #$20
    PLD 
    PLX 
    RTL 
} >
]
---------------------------------------------

sc_ix_0ADCFE [
  conveyor-index < #55, &sc_data_0ADD05 >   ;00
  conveyor-index < #EA, &conveyor_zone_0ADD0B >   ;01
]
---------------------------------------------

sc_data_0ADD05 [
  conveyor-zone < #02, #04, #16, #0A, #00, #04 >
]

conveyor_zone_0ADD0B [
  conveyor-zone < #03, #07, #04, #09, #00, #04 >   ;00
  conveyor-zone < #07, #06, #08, #08, #00, #FC >   ;01
  conveyor-zone < #0B, #07, #0C, #09, #00, #04 >   ;02
]