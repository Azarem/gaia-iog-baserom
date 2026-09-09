!playerActor                    09AA
!playerSpeedEw                  09B2
!playerSpeedNs                  09B4

---------------------------------------------

speed_zone_ew_slow [
  actor-def < #00, #00, #20, {

  code_00C1E2:
    LDY $playerActor
    LDA $14
    CLC 
    ADC #$0008
    SEC 
    SBC $0014, Y
    BPL loc_00C1F5
    EOR #$FFFF
    INC 

  loc_00C1F5:
    CMP #$0010
    BCC loc_00C1FB
    RTL 

  loc_00C1FB:
    LDA $16
    CLC 
    ADC #$0008
    SEC 
    SBC $0016, Y
    BPL loc_00C20B
    EOR #$FFFF
    INC 

  loc_00C20B:
    CMP #$0010
    BCC loc_00C211
    RTL 

  loc_00C211:
    LDA #$FFF9
    STA $playerSpeedEw
    RTL 
} >
]
---------------------------------------------

speed_zone_ew_fast [
  actor-def < #00, #00, #20, {

  code_00C21B:
    LDY $playerActor
    LDA $14
    CLC 
    ADC #$0008
    SEC 
    SBC $0014, Y
    BPL loc_00C22E
    EOR #$FFFF
    INC 

  loc_00C22E:
    CMP #$0010
    BCC loc_00C234
    RTL 

  loc_00C234:
    LDA $16
    CLC 
    ADC #$0008
    SEC 
    SBC $0016, Y
    BPL loc_00C244
    EOR #$FFFF
    INC 

  loc_00C244:
    CMP #$0010
    BCC loc_00C24A
    RTL 

  loc_00C24A:
    LDA #$0007
    STA $playerSpeedEw
    RTL 
} >
]
---------------------------------------------

speed_zone_ns_slow [
  actor-def < #00, #00, #20, {

  code_00C289:
    LDY $playerActor
    LDA $14
    CLC 
    ADC #$0008
    SEC 
    SBC $0014, Y
    BPL loc_00C29C
    EOR #$FFFF
    INC 

  loc_00C29C:
    CMP #$0010
    BCC loc_00C2A2
    RTL 

  loc_00C2A2:
    LDA $16
    SEC 
    SBC $0016, Y
    BPL loc_00C2AE
    EOR #$FFFF
    INC 

  loc_00C2AE:
    CMP #$0004
    BCC loc_00C2B4
    RTL 

  loc_00C2B4:
    LDA #$FFF9
    STA $playerSpeedNs
    RTL 
} >
]