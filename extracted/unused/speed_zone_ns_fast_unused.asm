!playerActor                    09AA
!playerSpeedNs                  09B4

---------------------------------------------

speed_zone_ns_fast_unused [
  actor-def < #00, #00, #20, {

  code_00C254:
    LDY $playerActor
    LDA $14
    CLC 
    ADC #$0008
    SEC 
    SBC $0014, Y
    BPL loc_00C267
    EOR #$FFFF
    INC 

  loc_00C267:
    CMP #$0010
    BCC loc_00C26D
    RTL 

  loc_00C26D:
    LDA $16
    SEC 
    SBC $0016, Y
    BPL loc_00C279
    EOR #$FFFF
    INC 

  loc_00C279:
    CMP #$0004
    BCC loc_00C27F
    RTL 

  loc_00C27F:
    LDA #$0007
    STA $playerSpeedNs
    RTL 
} >
]